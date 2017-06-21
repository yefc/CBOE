﻿using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Net.Http;
using System.Threading.Tasks;
using System.Web.Http;
using System.Xml;
using System.Web.UI;
using System.IO;
using System.Text;
using System.Web;
using System.Globalization;
using Microsoft.Web.Http;
using Newtonsoft.Json.Linq;
using Swashbuckle.Swagger.Annotations;
using CambridgeSoft.COE.Framework.COEFormService;
using CambridgeSoft.COE.Framework.COETableEditorService;
using CambridgeSoft.COE.Framework.Common;
using CambridgeSoft.COE.Framework.Common.Messaging;
using CambridgeSoft.COE.Framework.Controls.COETableManager;
using CambridgeSoft.COE.Registration.Services.Types;
using CambridgeSoft.COE.RegistrationAdmin.Services;
using PerkinElmer.COE.Registration.Server.Code;
using PerkinElmer.COE.Registration.Server.Models;
using CambridgeSoft.COE.RegistrationAdmin.Services.Common;
using CambridgeSoft.COE.Framework.COEDataViewService;

namespace PerkinElmer.COE.Registration.Server.Controllers
{
    [ApiVersion(Consts.apiVersion)]
    public class ConfigurationController : RegControllerBase
    {
        #region Util methods

        private static int SaveColumnValues(string tableName, JObject data, bool creating)
        {
            COETableEditorBOList.NewList().TableName = tableName;
            var idField = COETableEditorUtilities.getIdFieldName(tableName);
            var idFieldValue = creating ? null : data[idField].ToString();
            var tableEditorBO = creating ? COETableEditorBO.New() : COETableEditorBO.Get(int.Parse(idFieldValue));
            var columns = tableEditorBO.Columns;

            foreach (var column in columns)
                UpdateColumnValue(tableName, column, data);

            tableEditorBO.Columns = columns;
            foreach (var column in columns)
            {
                if (!COETableEditorUtilities.GetIsUniqueProperty(tableName, column.FieldName)) continue;
                if (!tableEditorBO.IsUniqueCheck(tableName, column.FieldName, column.FieldValue.ToString(), idField, idFieldValue))
                    throw new RegistrationException(string.Format("{0} should be unique", column.FieldName));
            }
            // Validate if view [VW_PICKLISTDOMAIN] Note : Add more to the list if contains SQL filters for update
            if (tableName.Equals(COETableManager.ValidateSqlQuery.VW_PICKLISTDOMAIN.ToString(), StringComparison.OrdinalIgnoreCase))
            {
                foreach (var column in columns)
                {
                    var columnName = column.FieldName;
                    if (columnName.Equals("EXT_TABLE", StringComparison.OrdinalIgnoreCase)
                        || columnName.Equals("EXT_ID_COL", StringComparison.OrdinalIgnoreCase)
                        || columnName.Equals("EXT_DISPLAY_COL", StringComparison.OrdinalIgnoreCase)
                        || columnName.Equals("EXT_SQL_FILTER", StringComparison.OrdinalIgnoreCase)
                        || columnName.Equals("EXT_SQL_SORTORDER", StringComparison.OrdinalIgnoreCase))
                    {
                        var columnValue = column.FieldValue.ToString();
                        if (!string.IsNullOrEmpty(columnValue))
                            COETableEditorBO.Get(tableName, columns);
                        break;
                    }
                }
            }
            try
            {
                tableEditorBO = tableEditorBO.Save();
            }
            catch (Exception ex)
            {
                if (ex.Message.Contains("ORA-00001"))
                    throw new RegistrationException("The value provided already exists");
                else
                    throw;
            }
            return tableEditorBO.ID;
        }

        private static void UpdateColumnValue(string tableName, Column column, JObject data)
        {
            var columnName = column.FieldName;
            var columnValue = (string)data[columnName];
            if (columnValue == null)
            {
                var defaultValue = COETableEditorUtilities.getDefaultValue(tableName, column.FieldName);
                column.FieldValue = !string.IsNullOrEmpty(defaultValue) ? defaultValue : null;
            }
            else if (COETableEditorUtilities.getIsStructure(tableName, column.FieldName))
            {
                column.FieldValue = ChemistryHelper.ConvertToCdx(columnValue);
            }
            else if (column.FieldType == DbType.Double)
            {
                double value;
                if (!double.TryParse(columnValue, out value))
                    throw new RegistrationException(string.Format("{0} needs a valid number", columnName));
                else
                    column.FieldValue = value;
            }
            else if (column.FieldType == DbType.Boolean)
            {
                bool value;
                if (!bool.TryParse(columnValue, out value))
                    throw new RegistrationException(string.Format("{0} needs a valid boolean value", columnName));
                else
                    column.FieldValue = value;
            }
            else if (column.FieldType == DbType.DateTime)
            {
                DateTime value;
                if (!DateTime.TryParse(columnValue, out value))
                    throw new RegistrationException(string.Format("{0} needs a valid date-time value", columnName));
                else
                    column.FieldValue = value;
            }
            else
            {
                column.FieldValue = columnValue;
            }
        }

        #endregion

        #region Custom tables
        private JArray GetTableConfig(string tableName)
        {
            // Returns the field configuration
            var config = new JArray();
            // COETableEditorUtilities.getColumnList returns the column lists
            var columns = COETableEditorUtilities.getColumnList(tableName);
            var idFieldName = COETableEditorUtilities.getIdFieldName(tableName);
            foreach (var column in columns)
            {
                var fieldName = column.FieldName;
                var lookupTableName = COETableEditorUtilities.getLookupTableName(tableName, fieldName);
                var lookupColumns = COETableEditorUtilities.getLookupColumnList(tableName, fieldName);
                var label = COETableEditorUtilities.GetAlias(tableName, fieldName);
                if (!string.IsNullOrEmpty(lookupTableName)) fieldName = lookupColumns[1].FieldName;
                if (label == null) label = fieldName;
                var columnObj = new JObject(
                    new JProperty("name", fieldName),
                    new JProperty("label", label),
                    new JProperty("type", column.FieldType.ToString())
                );
                if (fieldName.Equals(idFieldName)) columnObj.Add(new JProperty("idField", true));
                if (!string.IsNullOrEmpty(lookupTableName))
                {
                    columnObj.Add("lookup", ExtractData(string.Format("SELECT {0},{1} FROM {2}", lookupColumns[0].FieldName, lookupColumns[1].FieldName, lookupTableName)));
                }
                config.Add(columnObj);
            }
            // TODO: Structure lookup needs additional information
            // This should also return user authorization
            // Refer to routines like COETableEditorUtilities.HasDeletePrivileges and COETableEditorUtilities.HasEditPrivileges
            return config;
        }

        private bool CheckCustomPropertyName(ConfigurationRegistryRecord configurationBO, int formId, string propertyId)
        {
            if (string.IsNullOrEmpty(propertyId)) return false;
            var propertyName = propertyId.Replace("Property", string.Empty);
            var batchFormIngoreFields = new string[] { "FORMULA_WEIGHT", "BATCH_FORMULA", "PERCENT_ACTIVE" };
            if (formId == COEFormHelper.BATCHSUBFORMINDEX && batchFormIngoreFields.Contains(propertyName)) return false;
            var propertyList = formId == COEFormHelper.MIXTURESUBFORMINDEX ? configurationBO.PropertyList :
                formId == COEFormHelper.COMPOUNDSUBFORMINDEX ? configurationBO.CompoundPropertyList :
                formId == COEFormHelper.STRUCTURESUBFORMINDEX ? configurationBO.StructurePropertyList :
                formId == COEFormHelper.BATCHSUBFORMINDEX ? configurationBO.BatchPropertyList :
                configurationBO.BatchComponentList;
            var propertyListEnumerable = (IEnumerable<Property>)propertyList;
            return propertyListEnumerable.FirstOrDefault(p => p.Name == propertyName) != null;
        }

        private bool PutCustomFormData(ConfigurationRegistryRecord configurationBO, int formId, FormGroup.Form form, FormElementData formElementData)
        {
            bool found = false;
            if (form != null)
            {
                string controlStyle = RegAdminUtils.GetDefaultControlStyle(formElementData.ControlType, FormGroup.DisplayMode.Edit);
                var formElements = form.EditMode;
                foreach (var element in formElements)
                {
                    if (!element.Name.Equals(formElementData.Name)) continue;
                    found = true;

                    element.DisplayInfo.Type = formElementData.ControlType;
                    element.Label = formElementData.Label;
                    element.DisplayInfo.CSSClass = formElementData.CssClass;
                    element.DisplayInfo.Visible = formElementData.Visible == null || formElementData.Visible.Value;
                    if (element.DisplayInfo.Type == "CambridgeSoft.COE.Framework.Controls.COEFormGenerator.COELink")
                    {
                        if (element.BindingExpression.Contains("SearchCriteria"))
                            element.DisplayInfo.Type = "CambridgeSoft.COE.Framework.Controls.COEFormGenerator.COETextBox";
                    }

                    if (element.ConfigInfo["COE:fieldConfig"] != null && element.ConfigInfo["COE:fieldConfig"]["COE:CSSClass"] != null && !string.IsNullOrEmpty(controlStyle))
                        element.ConfigInfo["COE:fieldConfig"]["COE:CSSClass"].InnerText = controlStyle;

                    string defaultTextMode = formElementData.ControlType.Contains("COETextArea") ? "MultiLine" : string.Empty;
                    if (element.ConfigInfo["COE:fieldConfig"] != null && element.ConfigInfo["COE:fieldConfig"]["COE:TextMode"] != null)
                        element.ConfigInfo["COE:fieldConfig"]["COE:TextMode"].InnerText = defaultTextMode;
                    break;
                }

                formElements = form.AddMode;
                foreach (var element in formElements)
                {
                    if (!element.Name.Equals(formElementData.Name)) continue;
                    found = true;
                    element.DisplayInfo.Type = formElementData.ControlType;
                    element.Label = formElementData.Label;
                    element.DisplayInfo.CSSClass = formElementData.CssClass;
                    element.DisplayInfo.Visible = formElementData.Visible == null || formElementData.Visible.Value;
                    if (element.DisplayInfo.Type == "CambridgeSoft.COE.Framework.Controls.COEFormGenerator.COELink")
                    {
                        if (element.BindingExpression.Contains("SearchCriteria"))
                            element.DisplayInfo.Type = "CambridgeSoft.COE.Framework.Controls.COEFormGenerator.COETextBox";
                    }
                    break;
                }

                formElements = form.ViewMode;
                foreach (var element in formElements)
                {
                    if (!element.Name.Equals(formElementData.Name)) continue;
                    found = true;
                    element.DisplayInfo.Type = formElementData.ControlType;
                    element.Label = formElementData.Label;
                    element.DisplayInfo.CSSClass = formElementData.CssClass;
                    element.DisplayInfo.Visible = formElementData.Visible == null || formElementData.Visible.Value;
                    if (!element.DisplayInfo.Type.Contains("DropDownList") && !element.DisplayInfo.Type.Contains("DatePicker"))
                    {
                        if (!element.DisplayInfo.Type.Contains("NumericTextBox"))
                            element.DisplayInfo.Type += "ReadOnly";
                        else
                        {
                            if (element.ConfigInfo["COE:fieldConfig"] != null && element.ConfigInfo["COE:fieldConfig"]["COE:ReadOnly"] != null)
                                element.ConfigInfo["COE:fieldConfig"]["COE:ReadOnly"].InnerText = bool.TrueString;
                            else
                                element.ConfigInfo.FirstChild.AppendChild(element.ConfigInfo.OwnerDocument.CreateElement("COE:ReadOnly", element.ConfigInfo.NamespaceURI)).InnerText = bool.TrueString;
                        }
                    }
                    break;
                }

                formElements = form.LayoutInfo;
                foreach (var element in formElements)
                {
                    if (!element.Name.Equals(formElementData.Name)) continue;

                    found = true;

                    if (!string.IsNullOrEmpty(element.DisplayInfo.Assembly))
                        break;

                    element.Label = formElementData.Label;
                    element.DisplayInfo.Type = formElementData.ControlType;
                    element.DisplayInfo.Visible = formElementData.Visible.HasValue ? (bool)formElementData.Visible : false;
                    element.DisplayInfo.CSSClass = formElementData.CssClass;

                    if (formElementData.ControlType == "CambridgeSoft.COE.Framework.Controls.COEFormGenerator.COELink")
                    {
                        if (element.BindingExpression.Contains("SearchCriteria"))
                            element.DisplayInfo.Type = "CambridgeSoft.COE.Framework.Controls.COEFormGenerator.COETextBox";
                    }

                    if (element.ConfigInfo["COE:fieldConfig"] != null && element.ConfigInfo["COE:fieldConfig"]["COE:CSSClass"] != null && !string.IsNullOrEmpty(controlStyle))
                        element.ConfigInfo["COE:fieldConfig"]["COE:CSSClass"].InnerText = controlStyle;

                    string defaultTextMode = formElementData.ControlType.Contains("COETextArea") ? "MultiLine" : string.Empty;
                    if (element.ConfigInfo["COE:fieldConfig"] != null && element.ConfigInfo["COE:fieldConfig"]["COE:TextMode"] != null)
                        element.ConfigInfo["COE:fieldConfig"]["COE:TextMode"].InnerText = defaultTextMode;

                    break;
                }
            }
            return found;
        }

        private List<FormElementData> GetCustomFormData(ConfigurationRegistryRecord configurationBO, string group, FormGroup.Form form, List<FormGroup.FormElement> formElement, int groupIndex)
        {
            var data = new List<FormElementData>();
            foreach (var element in formElement)
            {
                if (!CheckCustomPropertyName(configurationBO, form.Id, element.Id)) continue;
                var name = element.Id.Replace("Property", string.Empty);
                if (string.IsNullOrEmpty(element.DisplayInfo.Assembly))
                {
                    FormElementData formElementData = new FormElementData(group, element);
                    UpdateFormElementDetails(formElementData, element.Name, configurationBO, groupIndex);
                    data.Add(formElementData);
                }
            }
            return data;
        }

        private void UpdateFormElementDetails(FormElementData formElementData, string propertyName, ConfigurationRegistryRecord configurationBO, int groupIndex)
        {
            string propertyType = string.Empty;
            string propertySubType = string.Empty;

            switch (groupIndex)
            {
                case COEFormHelper.MIXTURESUBFORMINDEX:
                    foreach (Property prop in configurationBO.PropertyList)
                    {
                        if (prop.Name == propertyName)
                        {
                            propertyType = prop.Type;
                            if (!string.IsNullOrEmpty(prop.SubType)) propertySubType = prop.SubType;
                        }
                    }
                    break;

                case COEFormHelper.COMPOUNDSUBFORMINDEX:

                    foreach (Property prop in configurationBO.CompoundPropertyList)
                    {
                        if (prop.Name == propertyName)
                        {
                            propertyType = prop.Type;
                            if (!string.IsNullOrEmpty(prop.SubType)) propertySubType = prop.SubType;
                        }
                    }
                    break;

                case COEFormHelper.STRUCTURESUBFORMINDEX:

                    foreach (Property prop in configurationBO.StructurePropertyList)
                    {
                        if (prop.Name == propertyName)
                        {
                            propertyType = prop.Type;
                            if (!string.IsNullOrEmpty(prop.SubType)) propertySubType = prop.SubType;
                        }
                    }
                    break;

                case COEFormHelper.BATCHSUBFORMINDEX:

                    foreach (Property prop in configurationBO.BatchPropertyList)
                    {
                        if (prop.Name == propertyName)
                        {
                            propertyType = prop.Type;
                            if (!string.IsNullOrEmpty(prop.SubType)) propertySubType = prop.SubType;
                        }
                    }
                    break;

                case COEFormHelper.BATCHCOMPONENTSUBFORMINDEX:
                case COEFormHelper.BATCHCOMPONENTSEARCHFORM:
                    foreach (Property prop in configurationBO.BatchComponentList)
                    {
                        if (prop.Name == propertyName)
                        {
                            propertyType = prop.Type;
                            if (!string.IsNullOrEmpty(prop.SubType)) propertySubType = prop.SubType;
                        }
                    }
                    break;
            }

            formElementData.Type = propertyType;
            formElementData.ControlTypeOptions = new List<KeyValuePair<string, string>>();
            formElementData.ControlEnabled = true;
            switch (propertyType)
            {
                case "NUMBER":
                case "TEXT":
                    if (!string.IsNullOrEmpty(propertySubType))
                    {
                        if (propertySubType == "URL")
                        {
                            formElementData.ControlEnabled = false;
                            formElementData.ControlTypeOptions.Add(new KeyValuePair<string, string>("URL", "CambridgeSoft.COE.Framework.Controls.COEFormGenerator.COELink"));
                        }
                    }
                    else
                    {
                        if (propertyType == "NUMBER")
                        {
                            formElementData.ControlTypeOptions.Add(new KeyValuePair<string, string>("NumericTextBox", "CambridgeSoft.COE.Framework.Controls.COEFormGenerator.COENumericTextBox"));
                        }

                        formElementData.ControlTypeOptions.Add(new KeyValuePair<string, string>("TextBox", "CambridgeSoft.COE.Framework.Controls.COEFormGenerator.COETextBox"));
                        formElementData.ControlTypeOptions.Add(new KeyValuePair<string, string>("TextArea", "CambridgeSoft.COE.Framework.Controls.COEFormGenerator.COETextArea"));

                    } break;
                case "BOOLEAN":
                    formElementData.ControlTypeOptions.Add(new KeyValuePair<string, string>("CheckBox", "CambridgeSoft.COE.Framework.Controls.COEFormGenerator.COECheckBox"));
                    break;
                case "DATE":
                    formElementData.ControlTypeOptions.Add(new KeyValuePair<string, string>("DatePicker", "CambridgeSoft.COE.Framework.Controls.COEFormGenerator.COEDatePicker"));
                    break;
                case "PICKLISTDOMAIN":
                    formElementData.ControlTypeOptions.Add(new KeyValuePair<string, string>("unmodifiable", "CambridgeSoft.COE.Framework.Controls.COEFormGenerator.COEDropDownList"));
                    formElementData.ControlEnabled = false;
                    break;
            }
        }

        private List<FormElementData> GetCustomFormData(ConfigurationRegistryRecord configurationBO, string group, FormGroup.Form form, int groupIndex)
        {
            var data = new List<FormElementData>();

            if (form != null)
            {
                if (form.LayoutInfo.Count > 0)
                    data.AddRange(GetCustomFormData(configurationBO, group, form, form.LayoutInfo, groupIndex));
                if (form.AddMode.Count > 0)
                    data.AddRange(GetCustomFormData(configurationBO, group, form, form.AddMode, groupIndex));
                if (form.EditMode.Count > 0)
                    data.AddRange(GetCustomFormData(configurationBO, group, form, form.EditMode, groupIndex));
                if (form.ViewMode.Count > 0)
                    data.AddRange(GetCustomFormData(configurationBO, group, form, form.ViewMode, groupIndex));
            }
            return data;
        }

        [HttpGet]
        [Route(Consts.apiPrefix + "custom-tables")]
        [SwaggerOperation("GetCustomTables")]
        [SwaggerResponse(200, type: typeof(JArray))]
        [SwaggerResponse(400, type: typeof(Exception))]
        [SwaggerResponse(401, type: typeof(Exception))]
        [SwaggerResponse(500, type: typeof(Exception))]
        public async Task<IHttpActionResult> GetCustomTables()
        {
            return await CallMethod(() =>
            {
                var tableList = new JArray();
                var tables = COETableEditorUtilities.getTables();
                foreach (var key in tables.Keys)
                {
                    var table = new JObject(
                        new JProperty("tableName", key),
                        new JProperty("label", tables[key])
                    );
                    tableList.Add(table);
                }
                return tableList;
            });
        }

        [HttpGet]
        [Route(Consts.apiPrefix + "custom-tables/{tableName}")]
        [SwaggerOperation("GetCustomTableRows")]
        [SwaggerResponse(200, type: typeof(JObject))]
        [SwaggerResponse(400, type: typeof(Exception))]
        [SwaggerResponse(401, type: typeof(Exception))]
        [SwaggerResponse(500, type: typeof(Exception))]
        public async Task<IHttpActionResult> GetCustomTableRows(string tableName, bool? configOnly = false)
        {
            return await CallMethod(() =>
            {
                var config = GetTableConfig(tableName);
                var rows = new JArray();
                if (configOnly != null && !configOnly.Value)
                {
                    COETableEditorBOList.NewList().TableName = tableName;
                    var dt = COETableEditorBOList.getTableEditorDataTable(tableName);
                    foreach (DataRow dr in dt.Rows)
                    {
                        var p = new JObject();
                        foreach (DataColumn dc in dt.Columns)
                            p.Add(new JProperty(dc.ColumnName, dc.ColumnName.Equals("structure", StringComparison.OrdinalIgnoreCase) ? "fragment/" + dr[0].ToString() : dr[dc]));
                        rows.Add(p);
                    }
                }
                return new JObject(
                    new JProperty("config", config),
                    new JProperty("rows", rows)
                );
            });
        }

        [HttpGet]
        [Route(Consts.apiPrefix + "custom-tables/{tableName}/{id}")]
        [SwaggerOperation("GetCustomTableRow")]
        [SwaggerResponse(200, type: typeof(JObject))]
        [SwaggerResponse(400, type: typeof(Exception))]
        [SwaggerResponse(401, type: typeof(Exception))]
        [SwaggerResponse(404, type: typeof(Exception))]
        [SwaggerResponse(500, type: typeof(Exception))]
        public async Task<IHttpActionResult> GetCustomTableRow(string tableName, int id)
        {
            return await CallMethod(() =>
            {
                COETableEditorBOList.NewList().TableName = tableName;
                var dt = COETableEditorBOList.getTableEditorDataTable(tableName);
                var idField = COETableEditorUtilities.getIdFieldName(tableName);
                var selected = dt.Select(string.Format("{0}={1}", idField, id));
                if (selected == null || selected.Count() == 0)
                    throw new IndexOutOfRangeException(string.Format("Cannot find the entry ID, {0}, in {1}", id, tableName));

                var dr = selected[0];
                var data = new JObject();
                foreach (DataColumn dc in dt.Columns)
                    data.Add(new JProperty(dc.ColumnName, dc.ColumnName.Equals("structure", StringComparison.OrdinalIgnoreCase) ? "fragment/" + dr[0].ToString() : dr[dc]));
                return data;
            });
        }

        [HttpPost]
        [Route(Consts.apiPrefix + "custom-tables/{tableName}")]
        [SwaggerOperation("CreateCustomTableRow")]
        [SwaggerResponse(201, type: typeof(JObject))]
        [SwaggerResponse(400, type: typeof(Exception))]
        [SwaggerResponse(401, type: typeof(Exception))]
        [SwaggerResponse(500, type: typeof(Exception))]
        public async Task<IHttpActionResult> CreateCustomTableRow(string tableName, JObject data)
        {
            return await CallMethod(() =>
            {
                if (!COETableEditorUtilities.HasAddPrivileges(tableName))
                    throw new UnauthorizedAccessException(string.Format("Not allowed to add entries to {0}", tableName));
                var id = SaveColumnValues(tableName, data, true);
                return new ResponseData(id, null, null, null);
            });
        }

        [HttpPut]
        [Route(Consts.apiPrefix + "custom-tables/{tableName}/{id}")]
        [SwaggerOperation("UpdateCustomTableRow")]
        [SwaggerResponse(200, type: typeof(ResponseData))]
        [SwaggerResponse(400, type: typeof(Exception))]
        [SwaggerResponse(401, type: typeof(Exception))]
        [SwaggerResponse(404, type: typeof(Exception))]
        [SwaggerResponse(500, type: typeof(Exception))]
        public async Task<IHttpActionResult> UpdateCustomTableRow(string tableName, int id, JObject data)
        {
            return await CallMethod(() =>
            {
                if (!COETableEditorUtilities.HasEditPrivileges(tableName))
                    throw new UnauthorizedAccessException(string.Format("Not allowed to edit entries from {0}", tableName));
                SaveColumnValues(tableName, data, false);
                return new ResponseData(id, null, null, null);
            });
        }

        [HttpDelete]
        [Route(Consts.apiPrefix + "custom-tables/{tableName}/{id}")]
        [SwaggerOperation("DeleteCustomTableRow")]
        [SwaggerResponse(200, type: typeof(ResponseData))]
        [SwaggerResponse(400, type: typeof(Exception))]
        [SwaggerResponse(401, type: typeof(Exception))]
        [SwaggerResponse(404, type: typeof(Exception))]
        [SwaggerResponse(500, type: typeof(Exception))]
        public async Task<IHttpActionResult> DeleteCustomTableRow(string tableName, int id)
        {
            return await CallMethod(() =>
            {
                if (!COETableEditorUtilities.HasDeletePrivileges(tableName))
                    throw new UnauthorizedAccessException(string.Format("Not allowed to delete entries from {0}", tableName));
                COETableEditorBOList.NewList().TableName = tableName;
                // TODO: Should check if id is present.
                // If not, throw error 404.
                COETableEditorBO.Delete(id);
                return new ResponseData(id, null, null, null);
            });
        }

        #endregion

        #region Addins

        [HttpGet]
        [Route(Consts.apiPrefix + "addins")]
        [SwaggerOperation("GetAddins")]
        [SwaggerResponse(200, type: typeof(List<AddinData>))]
        [SwaggerResponse(400, type: typeof(Exception))]
        [SwaggerResponse(401, type: typeof(Exception))]
        [SwaggerResponse(500, type: typeof(Exception))]
        public async Task<IHttpActionResult> GetAddins()
        {
            return await CallMethod(() =>
            {
                var addinList = new List<AddinData>();
                var configurationBO = ConfigurationRegistryRecord.NewConfigurationRegistryRecord();

                int counter = 0;
                foreach (AddIn addin in configurationBO.AddInList)
                {
                    AddinData addinData = new AddinData();
                    addinData.Name = string.IsNullOrEmpty(addin.FriendlyName) ? counter.ToString() : addin.FriendlyName;
                    addinData.AddIn = addin.IsNew ? addin.ClassNameSpace + "." + addin.ClassName : addin.ClassName;
                    addinData.ClassName = addin.ClassName;
                    addinData.ClassNamespace = string.IsNullOrEmpty(addin.ClassNameSpace) ? string.Empty : addin.ClassNameSpace;
                    addinData.Assembly = addin.Assembly;
                    addinData.Enable = addin.IsEnable;
                    addinData.Required = addin.IsRequired;
                    addinData.Configuration = addin.AddInConfiguration;

                    addinData.Events = new List<AddinEvent>();
                    foreach (Event evt in addin.EventList)
                        addinData.Events.Add(new AddinEvent(evt.EventName, evt.EventHandler));

                    addinList.Add(addinData);
                    counter++;
                }

                return addinList;
            });
        }

        [HttpDelete]
        [Route(Consts.apiPrefix + "addins/{name}")]
        [SwaggerOperation("DeleteAddin")]
        [SwaggerResponse(200, type: typeof(ResponseData))]
        [SwaggerResponse(400, type: typeof(Exception))]
        [SwaggerResponse(401, type: typeof(Exception))]
        [SwaggerResponse(404, type: typeof(Exception))]
        [SwaggerResponse(500, type: typeof(Exception))]
        public async Task<IHttpActionResult> DeleteAddin(string name)
        {
            return await CallMethod(() =>
            {
                if (string.IsNullOrWhiteSpace(name))
                    throw new RegistrationException("Invalid addin name");
                var configurationBO = ConfigurationRegistryRecord.NewConfigurationRegistryRecord();
                bool found = false;
                foreach (AddIn addin in configurationBO.AddInList)
                {
                    if (!addin.FriendlyName.Equals(name)) continue;
                    found = true;
                    configurationBO.AddInList.Remove(addin);
                    configurationBO.Save();
                    break;
                }
                if (!found)
                    throw new IndexOutOfRangeException(string.Format("The addin, {0}, was not found", name));
                return new ResponseData(message: string.Format("The addin, {0}, was deleted successfully!", name));
            });
        }

        [HttpPost]
        [Route(Consts.apiPrefix + "addins")]
        [SwaggerOperation("CreateAddin")]
        [SwaggerResponse(201, type: typeof(AddinData))]
        [SwaggerResponse(400, type: typeof(Exception))]
        [SwaggerResponse(401, type: typeof(Exception))]
        [SwaggerResponse(500, type: typeof(Exception))]
        public async Task<IHttpActionResult> CreateAddin(AddinData data)
        {
            return await CallMethod(() =>
            {
                if (string.IsNullOrEmpty(data.Name))
                    throw new RegistrationException("Invalid addin name");

                var configurationBO = ConfigurationRegistryRecord.NewConfigurationRegistryRecord();

                // check addin with friendly name already exist
                foreach (AddIn addin in configurationBO.AddInList)
                {
                    if (addin.FriendlyName.Equals(data.Name))
                    {
                        throw new RegistrationException(string.Format("The addin {0} with same name already exists.", data.Name));
                    }
                }

                // check addin configuration is valid
                XmlDocument xml = new XmlDocument();
                try
                {
                    xml.LoadXml(data.Configuration);
                }
                catch
                {
                    throw new RegistrationException(string.Format("The addin {0}'s configuration is not valid.", data.Name));
                }
                if (xml.DocumentElement.FirstChild.Name == "AddInConfiguration")
                    throw new RegistrationException(string.Format("The addin {0}'s configuration is not valid.", data.Name));

                // get all events
                EventList eventList = EventList.NewEventList();
                foreach (PerkinElmer.COE.Registration.Server.Models.AddinEvent evtItem in data.Events)
                {
                    Event evt = Event.NewEvent(evtItem.EventName, evtItem.EventHandler, true);
                    eventList.Add(evt);
                }

                AddIn addIn = AddIn.NewAddIn(data.Assembly, data.ClassName, data.Name, eventList, data.Configuration, data.ClassNamespace, true, false);

                configurationBO.AddInList.Add(addIn);
                configurationBO.Save();

                return new ResponseData(message: string.Format("The addin, {0}, was saved successfully!", data.Name));
            });
        }

        [HttpPut]
        [Route(Consts.apiPrefix + "addins")]
        [SwaggerOperation("UpdateAddin")]
        [SwaggerResponse(200, type: typeof(AddinData))]
        [SwaggerResponse(400, type: typeof(Exception))]
        [SwaggerResponse(401, type: typeof(Exception))]
        [SwaggerResponse(404, type: typeof(Exception))]
        [SwaggerResponse(500, type: typeof(Exception))]
        public async Task<IHttpActionResult> UpdateAddin(AddinData data)
        {
            return await CallMethod(() =>
            {
                if (string.IsNullOrWhiteSpace(data.Name))
                    throw new RegistrationException("Invalid addin name");

                var configurationBO = ConfigurationRegistryRecord.NewConfigurationRegistryRecord();
                bool found = false;
                foreach (AddIn addin in configurationBO.AddInList)
                {
                    if (!addin.FriendlyName.Equals(data.Name)) continue;
                    found = true;
                    addin.BeginEdit();

                    addin.Assembly = data.Assembly;
                    addin.IsEnable = data.Enable;
                    addin.AddInConfiguration = data.Configuration;

                    // clear existing events, if any
                    List<Event> markedEventsForDeletion = new List<Event>();
                    if (addin.EventList.Count > 0)
                    {
                        foreach (Event evt in addin.EventList)
                            markedEventsForDeletion.Add(evt);

                        foreach (Event evt in markedEventsForDeletion)
                            addin.EventList.Remove(evt);
                    }

                    // add new events
                    foreach (AddinEvent evtData in data.Events)
                    {
                        Event evt = Event.NewEvent(evtData.EventName, evtData.EventHandler, true);
                        addin.EventList.Add(evt);
                    }

                    addin.ApplyEdit();
                    configurationBO.Save();

                    break;
                }
                if (!found)
                    throw new IndexOutOfRangeException(string.Format("The addin, {0}, was not found", data.Name));

                return new ResponseData(message: string.Format("The addin, {0}, was updated successfully!", data.Name));
            });
        }

        #endregion

        #region Forms

        [HttpGet]
        [Route(Consts.apiPrefix + "forms")]
        [SwaggerOperation("GetForms")]
        [SwaggerResponse(200, type: typeof(List<FormElementData>))]
        [SwaggerResponse(400, type: typeof(Exception))]
        [SwaggerResponse(401, type: typeof(Exception))]
        [SwaggerResponse(500, type: typeof(Exception))]
        public async Task<IHttpActionResult> GetForms()
        {
            return await CallMethod(() =>
            {
                var configurationBO = ConfigurationRegistryRecord.NewConfigurationRegistryRecord();
                string[] customFromGroupsIds = RegAdminUtils.GetRegCustomFormGroupsIds();
                var formList = new List<FormElementData>();
                foreach (string formGroupId in customFromGroupsIds)
                {
                    var formBO = COEFormBO.Get(Convert.ToInt32(formGroupId));
                    var detailsForms = formBO.COEFormGroup.DetailsForms;
                    var listForms = formBO.COEFormGroup.ListForms;
                    var queryForms = formBO.COEFormGroup.QueryForms;
                    var group = GetPropertyTypeLabel(ConfigurationRegistryRecord.PropertyListType.PropertyList);
                    formList.AddRange(GetCustomFormData(configurationBO, group, formBO.TryGetForm(detailsForms, 0, COEFormHelper.MIXTURESUBFORMINDEX), COEFormHelper.MIXTURESUBFORMINDEX));
                    group = GetPropertyTypeLabel(ConfigurationRegistryRecord.PropertyListType.Compound);
                    formList.AddRange(GetCustomFormData(configurationBO, group, formBO.TryGetForm(detailsForms, 0, COEFormHelper.COMPOUNDSUBFORMINDEX), COEFormHelper.COMPOUNDSUBFORMINDEX));
                    group = GetPropertyTypeLabel(ConfigurationRegistryRecord.PropertyListType.Structure);
                    formList.AddRange(GetCustomFormData(configurationBO, group, formBO.TryGetForm(detailsForms, 0, COEFormHelper.STRUCTURESUBFORMINDEX), COEFormHelper.STRUCTURESUBFORMINDEX));
                    group = GetPropertyTypeLabel(ConfigurationRegistryRecord.PropertyListType.Batch);
                    formList.AddRange(GetCustomFormData(configurationBO, group, formBO.TryGetForm(detailsForms, 0, COEFormHelper.BATCHSUBFORMINDEX), COEFormHelper.BATCHSUBFORMINDEX));
                    group = GetPropertyTypeLabel(ConfigurationRegistryRecord.PropertyListType.BatchComponent);
                    formList.AddRange(GetCustomFormData(configurationBO, group, formBO.TryGetForm(detailsForms, 0, COEFormHelper.BATCHCOMPONENTSUBFORMINDEX), COEFormHelper.BATCHCOMPONENTSUBFORMINDEX));
                    formList.AddRange(GetCustomFormData(configurationBO, group, formBO.TryGetForm(queryForms, 0, COEFormHelper.BATCHCOMPONENTSEARCHFORM), COEFormHelper.BATCHCOMPONENTSEARCHFORM));

                }
                return formList.GroupBy(d => d.Name).Select(g => g.First());
            });
        }

        [HttpPut]
        [Route(Consts.apiPrefix + "forms")]
        [SwaggerOperation("UpdateCustomForm")]
        [SwaggerResponse(200, type: typeof(ResponseData))]
        [SwaggerResponse(400, type: typeof(Exception))]
        [SwaggerResponse(401, type: typeof(Exception))]
        [SwaggerResponse(404, type: typeof(Exception))]
        [SwaggerResponse(500, type: typeof(Exception))]
        public async Task<IHttpActionResult> UpdateCustomForm(FormElementData formElementData)
        {
            return await CallMethod(() =>
            {
                bool found = false;
                var configurationBO = ConfigurationRegistryRecord.NewConfigurationRegistryRecord();
                string[] customFromGroupsIds = RegAdminUtils.GetRegCustomFormGroupsIds();
                foreach (string formGroupId in customFromGroupsIds)
                {
                    bool formGroupUpdated = false;
                    var formBO = COEFormBO.Get(Convert.ToInt32(formGroupId));
                    var detailsForms = formBO.COEFormGroup.DetailsForms;
                    var listForms = formBO.COEFormGroup.ListForms;
                    var queryForms = formBO.COEFormGroup.QueryForms;
                    if (PutCustomFormData(configurationBO, formBO.ID, formBO.TryGetForm(detailsForms, 0, COEFormHelper.MIXTURESUBFORMINDEX), formElementData))
                        formGroupUpdated = true;
                    if (PutCustomFormData(configurationBO, formBO.ID, formBO.TryGetForm(listForms, 0, COEFormHelper.MIXTURESEARCHFORM), formElementData))
                        formGroupUpdated = true;
                    if (PutCustomFormData(configurationBO, formBO.ID, formBO.TryGetForm(queryForms, 0, COEFormHelper.MIXTURESEARCHFORM), formElementData))
                        formGroupUpdated = true;
                    if (PutCustomFormData(configurationBO, formBO.ID, formBO.TryGetForm(detailsForms, 0, COEFormHelper.COMPOUNDSUBFORMINDEX), formElementData))
                        formGroupUpdated = true;
                    if (PutCustomFormData(configurationBO, formBO.ID, formBO.TryGetForm(queryForms, 0, COEFormHelper.COMPOUNDSEARCHFORM), formElementData))
                        formGroupUpdated = true;
                    if (PutCustomFormData(configurationBO, formBO.ID, formBO.TryGetForm(detailsForms, 0, COEFormHelper.STRUCTURESUBFORMINDEX), formElementData))
                        formGroupUpdated = true;
                    if (PutCustomFormData(configurationBO, formBO.ID, formBO.TryGetForm(queryForms, 0, COEFormHelper.STRUCTURESEARCHFORM), formElementData))
                        formGroupUpdated = true;
                    if (PutCustomFormData(configurationBO, formBO.ID, formBO.TryGetForm(detailsForms, 0, COEFormHelper.BATCHSUBFORMINDEX), formElementData))
                        formGroupUpdated = true;
                    if (PutCustomFormData(configurationBO, formBO.ID, formBO.TryGetForm(queryForms, 0, COEFormHelper.BATCHSEARCHFORM), formElementData))
                        formGroupUpdated = true;
                    if (PutCustomFormData(configurationBO, formBO.ID, formBO.TryGetForm(detailsForms, 0, COEFormHelper.BATCHCOMPONENTSUBFORMINDEX), formElementData))
                        formGroupUpdated = true;
                    if (PutCustomFormData(configurationBO, formBO.ID, formBO.TryGetForm(queryForms, 0, COEFormHelper.BATCHCOMPONENTSEARCHFORM), formElementData))
                        formGroupUpdated = true;
                    if (PutCustomFormData(configurationBO, formBO.ID, formBO.TryGetForm(queryForms, 0, COEFormHelper.TEMPORARYBASEFORM), formElementData))
                        formGroupUpdated = true;
                    if (PutCustomFormData(configurationBO, formBO.ID, formBO.TryGetForm(queryForms, 0, COEFormHelper.TEMPORARYCHILDFORM), formElementData))
                        formGroupUpdated = true;
                    found = found || formGroupUpdated;
                    if (formGroupUpdated)
                        formBO.Save();
                }
                if (!found)
                    throw new IndexOutOfRangeException(string.Format("The form-element, {0}, was not found", formElementData.Name));
                return new ResponseData(null, null, string.Format("The form-elements was updated successfully!"), null);
            });
        }
        #endregion

        #region Properties
        [HttpGet]
        [Route(Consts.apiPrefix + "properties")]
        [SwaggerOperation("GetProperties")]
        [SwaggerResponse(200, type: typeof(List<PropertyData>))]
        [SwaggerResponse(400, type: typeof(Exception))]
        [SwaggerResponse(401, type: typeof(Exception))]
        [SwaggerResponse(500, type: typeof(Exception))]
        public async Task<IHttpActionResult> GetProperties()
        {
            return await CallMethod(() =>
            {
                var propertyArray = new List<PropertyData>();
                var configurationBO = ConfigurationRegistryRecord.NewConfigurationRegistryRecord();
                var propertyTypes = Enum.GetValues(typeof(ConfigurationRegistryRecord.PropertyListType)).Cast<ConfigurationRegistryRecord.PropertyListType>();
                foreach (var propertyType in propertyTypes)
                {
                    configurationBO.SelectedPropertyList = propertyType;
                    var propertyList = configurationBO.GetSelectedPropertyList;
                    if (propertyList == null) continue;
                    var properties = (IEnumerable<Property>)propertyList;
                    foreach (var property in properties)
                    {
                        PropertyData propertyData = new PropertyData();
                        propertyData.Name = property.Name;
                        propertyData.GroupName = propertyType.ToString();
                        propertyData.GroupLabel = GetPropertyTypeLabel(propertyType);
                        propertyData.Type = property.Type;
                        propertyData.PickListDisplayValue = string.IsNullOrEmpty(property.PickListDisplayValue) ? string.Empty : property.PickListDisplayValue;
                        propertyData.PickListDomainId = string.IsNullOrEmpty(property.PickListDomainId) ? string.Empty : property.PickListDomainId;
                        propertyData.Value = property.Value;
                        propertyData.DefaultValue = property.DefaultValue;
                        propertyData.Precision = string.IsNullOrEmpty(property.Precision) ? string.Empty : property.Precision;
                        propertyData.SortOrder = property.SortOrder;
                        propertyData.SubType = property.SubType;
                        propertyData.FriendlyName = property.FriendlyName;
                        propertyData.Editable = (property.Type == "NUMBER" || property.Type == "TEXT") ? true : false;
                        propertyData.ValidationRules = new List<ValidationRuleData>();

                        foreach (CambridgeSoft.COE.Registration.Services.Types.ValidationRule rule in property.ValRuleList)
                        {
                            ValidationRuleData ruleData = new ValidationRuleData();
                            ruleData.Name = rule.Name;
                            ruleData.Min = string.IsNullOrEmpty(rule.MIN) ? string.Empty : rule.MIN;
                            ruleData.Max = string.IsNullOrEmpty(rule.MAX) ? string.Empty : rule.MAX;
                            ruleData.MaxLength = rule.MaxLength;
                            ruleData.Error = string.IsNullOrEmpty(rule.Error) ? string.Empty : rule.Error;
                            ruleData.DefaultValue = rule.DefaultValue;
                            ruleData.Parameters = new List<ValidationParameter>();

                            foreach (CambridgeSoft.COE.Registration.Services.BLL.Parameter param in rule.Parameters)
                                ruleData.Parameters.Add(new ValidationParameter(param.Name, param.Value));

                            propertyData.ValidationRules.Add(ruleData);
                        }

                        propertyArray.Add(propertyData);
                    }
                }
                return propertyArray;
            });
        }

        [HttpPost]
        [Route(Consts.apiPrefix + "properties")]
        [SwaggerOperation("CreateProperties")]
        [SwaggerResponse(201, type: typeof(ResponseData))]
        [SwaggerResponse(400, type: typeof(Exception))]
        [SwaggerResponse(401, type: typeof(Exception))]
        [SwaggerResponse(500, type: typeof(Exception))]
        public async Task<IHttpActionResult> CreateProperties(PropertyData data)
        {
            return await CallMethod(() =>
            {
                if (string.IsNullOrWhiteSpace(data.Name))
                    throw new RegistrationException("Invalid property name");
                if (string.IsNullOrWhiteSpace(data.FriendlyName))
                    throw new RegistrationException("Invalid property FriendlyName");
                if (string.IsNullOrWhiteSpace(data.Type))
                    throw new RegistrationException("Invalid property type");

                var configurationBO = ConfigurationRegistryRecord.NewConfigurationRegistryRecord();

                bool reserved = data.Name.ToUpper().Equals("DATE") ? true : data.Name.ToUpper().Equals("NUMBER") ? true :
                    data.Name.ToUpper().Equals("TEXT") ? true : data.Name.ToUpper().Equals("BOOLEAN") ? true :
                    data.Name.ToUpper().Equals("PICKLISTDOMAIN") ? true : configurationBO.DatabaseReservedWords.Contains(data.Name.ToUpper()) ? true : false;
                if (reserved)
                    throw new RegistrationException(string.Format("Property name '{0}' is a reserved keyword.", data.Name));

                bool duplicateExists = false;
                if (configurationBO.PropertyList.CheckExistingNames(data.Name.ToUpper(), true) || configurationBO.PropertyColumnList.Contains(data.Name.ToUpper()))
                    duplicateExists = true;
                else if (configurationBO.BatchPropertyList.CheckExistingNames(data.Name.ToUpper(), true) || configurationBO.BatchPropertyColumnList.Contains(data.Name.ToUpper()))
                    duplicateExists = true;
                else if (configurationBO.BatchComponentList.CheckExistingNames(data.Name.ToUpper(), true) || configurationBO.BatchComponentColumnList.Contains(data.Name.ToUpper()))
                    duplicateExists = true;
                else if (configurationBO.CompoundPropertyList.CheckExistingNames(data.Name.ToUpper(), true) || configurationBO.CompoundPropertyColumnList.Contains(data.Name.ToUpper()))
                    duplicateExists = true;
                else if (configurationBO.StructurePropertyList.CheckExistingNames(data.Name.ToUpper(), true) || configurationBO.StructurePropertyColumnList.Contains(data.Name.ToUpper()))
                    duplicateExists = true;

                if (duplicateExists)
                    throw new RegistrationException(string.Format("The property '{0}' already exists.", data.Name));

                // set defaut values (These default values are hard coded in the UI in old Reg app)
                switch (data.Type.ToUpper())
                {
                    case "INTEGER":
                        data.Type = ConfigurationRegistryRecord.PropertyTypeEnum.Number.ToString().ToUpper();
                        data.Precision = string.IsNullOrEmpty(data.Precision) ? "9.0" : data.Precision;
                        break;
                    case "FLOAT":
                        data.Type = ConfigurationRegistryRecord.PropertyTypeEnum.Number.ToString().ToUpper();
                        data.Precision = string.IsNullOrEmpty(data.Precision) ? "8.6" : data.Precision;
                        break;
                    case "URL":
                        data.Type = ConfigurationRegistryRecord.PropertyTypeEnum.Text.ToString().ToUpper();
                        data.SubType = "URL";
                        data.Precision = string.IsNullOrEmpty(data.Precision) ? "200" : data.Precision;
                        break;
                    case "NUMBER":
                        data.Precision = string.IsNullOrEmpty(data.Precision) ? "8.0" : data.Precision;
                        break;
                    case "TEXT":
                        data.Precision = string.IsNullOrEmpty(data.Precision) ? "200" : data.Precision;
                        break;
                }

                // if comma is given as a decimal separator, replce it with .
                data.Precision = data.Precision.Replace(",", ".");

                // below code will make sure that the input is a valid decimal numbe
                // example , if 10 is given as input, it will return 10.0
                double precision;
                if (!double.TryParse(data.Precision, NumberStyles.Number, CultureInfo.InvariantCulture, out precision))
                    throw new RegistrationException("Property precision is not a valid input.");
                data.Precision = precision.ToString();

                var propertyTypes = Enum.GetValues(typeof(ConfigurationRegistryRecord.PropertyListType)).Cast<ConfigurationRegistryRecord.PropertyListType>();
                bool found = false;
                foreach (var propertyType in propertyTypes)
                {
                    if (!propertyType.ToString().Equals(data.GroupName)) continue;

                    configurationBO.SelectedPropertyList = propertyType;
                    var propertyList = configurationBO.GetSelectedPropertyList;
                    if (propertyList == null) continue;
                    found = true;

                    string prefix = string.Empty;
                    switch (configurationBO.SelectedPropertyList)
                    {
                        case ConfigurationRegistryRecord.PropertyListType.PropertyList:
                            prefix = RegAdminUtils.GetRegistryPrefix();
                            break;
                        case ConfigurationRegistryRecord.PropertyListType.Batch:
                            prefix = RegAdminUtils.GetBatchPrefix();
                            break;
                        case ConfigurationRegistryRecord.PropertyListType.Compound:
                            prefix = RegAdminUtils.GetComponentPrefix();
                            break;
                        case ConfigurationRegistryRecord.PropertyListType.BatchComponent:
                            prefix = RegAdminUtils.GetBatchComponentsPrefix();
                            break;
                        case ConfigurationRegistryRecord.PropertyListType.Structure:
                            prefix = RegAdminUtils.GetStructurePrefix();
                            break;
                    }

                    ConfigurationProperty confProperty = ConfigurationProperty.NewConfigurationProperty(
                        prefix + data.Name.ToUpper(),
                        data.Name.ToUpper(),
                        data.Type,
                        string.IsNullOrEmpty(data.Precision) ? "1" : data.Precision,
                        true,
                        string.IsNullOrEmpty(data.SubType) ? string.Empty : data.SubType,
                        data.PickListDomainId);
                    configurationBO.GetSelectedPropertyList.AddProperty(confProperty);

                    switch (configurationBO.SelectedPropertyList)
                    {
                        case ConfigurationRegistryRecord.PropertyListType.PropertyList:
                            if (string.IsNullOrEmpty(data.FriendlyName))
                                configurationBO.PropertiesLabels[0].Add(prefix + data.Name.ToUpper(), data.Name);
                            else
                                configurationBO.PropertiesLabels[0].Add(prefix + data.Name.ToUpper(), data.FriendlyName);
                            break;
                        case ConfigurationRegistryRecord.PropertyListType.Compound:
                            if (string.IsNullOrEmpty(data.FriendlyName))
                                configurationBO.PropertiesLabels[1].Add(prefix + data.Name.ToUpper(), data.Name);
                            else
                                configurationBO.PropertiesLabels[1].Add(prefix + data.Name.ToUpper(), data.FriendlyName);
                            break;
                        case ConfigurationRegistryRecord.PropertyListType.Batch:
                            if (string.IsNullOrEmpty(data.FriendlyName))
                                configurationBO.PropertiesLabels[2].Add(prefix + data.Name.ToUpper(), data.Name);
                            else
                                configurationBO.PropertiesLabels[2].Add(prefix + data.Name.ToUpper(), data.FriendlyName);
                            break;

                        case ConfigurationRegistryRecord.PropertyListType.BatchComponent:
                            if (string.IsNullOrEmpty(data.FriendlyName))
                                configurationBO.PropertiesLabels[3].Add(prefix + data.Name.ToUpper(), data.Name);
                            else
                                configurationBO.PropertiesLabels[3].Add(prefix + data.Name.ToUpper(), data.FriendlyName);
                            break;
                        case ConfigurationRegistryRecord.PropertyListType.Structure:
                            if (string.IsNullOrEmpty(data.FriendlyName))
                                configurationBO.PropertiesLabels[4].Add(prefix + data.Name.ToUpper(), data.Name);
                            else
                                configurationBO.PropertiesLabels[4].Add(prefix + data.Name.ToUpper(), data.FriendlyName);
                            break;
                    }

                    break;
                }

                if (found)
                    configurationBO.Save();
                else
                    throw new RegistrationException(string.Format("The property '{0}' not saved.", data.Name));

                return new ResponseData(message: string.Format("The property, {0}, was saved successfully!", data.Name));
            });
        }

        [HttpPut]
        [Route(Consts.apiPrefix + "properties")]
        [SwaggerOperation("UpdateProperties")]
        [SwaggerResponse(200, type: typeof(ResponseData))]
        [SwaggerResponse(400, type: typeof(Exception))]
        [SwaggerResponse(401, type: typeof(Exception))]
        [SwaggerResponse(404, type: typeof(Exception))]
        [SwaggerResponse(500, type: typeof(Exception))]
        public async Task<IHttpActionResult> UpdateProperties(PropertyData data)
        {
            return await CallMethod(() =>
            {
                if (string.IsNullOrWhiteSpace(data.Name))
                    throw new RegistrationException("Invalid property name");

                var configurationBO = ConfigurationRegistryRecord.NewConfigurationRegistryRecord();
                var propertyTypes = Enum.GetValues(typeof(ConfigurationRegistryRecord.PropertyListType)).Cast<ConfigurationRegistryRecord.PropertyListType>();
                ConfigurationProperty selectedProperty = null;
                foreach (var propertyType in propertyTypes)
                {
                    configurationBO.SelectedPropertyList = propertyType;
                    var propertyList = configurationBO.GetSelectedPropertyList;
                    if (propertyList == null) continue;
                    var properties = (IEnumerable<Property>)propertyList;
                    foreach (var property in properties)
                    {
                        if (!property.Name.Equals(data.Name)) continue;
                        selectedProperty = (ConfigurationProperty)property;
                        break;
                    }

                    if (selectedProperty != null)
                        break;
                }

                if (selectedProperty == null)
                    throw new RegistrationException(string.Format("The property, {0}, was not found", data.Name));

                selectedProperty.BeginEdit();

                if (!selectedProperty.Precision.Equals(data.Precision))
                {
                    switch (selectedProperty.Type)
                    {
                        case "NUMBER":
                            if (data.Precision.Contains(".") || data.Precision.Contains(","))
                                selectedProperty.Precision = data.Precision;
                            else
                                selectedProperty.Precision = data.Precision + ".0";

                            selectedProperty.Precision = RegAdminUtils.ConvertPrecision(selectedProperty.Precision, true);
                            break;
                        case "TEXT":
                            selectedProperty.Precision = data.Precision;
                            break;
                    }
                }

                if (selectedProperty.PrecisionIsUpdate)
                {
                    ValidationRuleList valRulesToDelete = selectedProperty.ValRuleList.Clone();
                    foreach (CambridgeSoft.COE.Registration.Services.Types.ValidationRule valRule in valRulesToDelete)
                        selectedProperty.ValRuleList.RemoveValidationRule(valRule.ID);
                    ((ConfigurationProperty)selectedProperty).AddDefaultRule();
                }

                selectedProperty.ApplyEdit();
                configurationBO.Save();

                return new ResponseData(message: string.Format("The property, {0}, was updated successfully!", data.Name));
            });
        }

        [HttpDelete]
        [Route(Consts.apiPrefix + "properties/{name}")]
        [SwaggerOperation("DeleteProperties")]
        [SwaggerResponse(201, type: typeof(ResponseData))]
        [SwaggerResponse(400, type: typeof(Exception))]
        [SwaggerResponse(401, type: typeof(Exception))]
        [SwaggerResponse(404, type: typeof(Exception))]
        [SwaggerResponse(500, type: typeof(Exception))]
        public async Task<IHttpActionResult> DeleteProperties(string name)
        {
            return await CallMethod(() =>
            {
                if (string.IsNullOrEmpty(name))
                    throw new RegistrationException("Invalid property name");
                var configurationBO = ConfigurationRegistryRecord.NewConfigurationRegistryRecord();

                var propertyTypes = Enum.GetValues(typeof(ConfigurationRegistryRecord.PropertyListType)).Cast<ConfigurationRegistryRecord.PropertyListType>();
                bool found = false;
                foreach (var propertyType in propertyTypes)
                {
                    configurationBO.SelectedPropertyList = propertyType;
                    var propertyList = configurationBO.GetSelectedPropertyList;
                    if (propertyList == null) continue;
                    var properties = (IEnumerable<Property>)propertyList;
                    foreach (var property in properties)
                    {
                        if (!property.Name.Equals(name)) continue;

                        found = true;
                        int index = propertyList.GetPropertyIndex(name);
                        propertyList.RemoveAt(index);

                        switch (configurationBO.SelectedPropertyList)
                        {
                            case ConfigurationRegistryRecord.PropertyListType.PropertyList:
                                configurationBO.PropertiesLabels[0].Remove(name);
                                break;
                            case ConfigurationRegistryRecord.PropertyListType.Compound:
                                configurationBO.PropertiesLabels[1].Remove(name);
                                break;
                            case ConfigurationRegistryRecord.PropertyListType.Batch:
                                configurationBO.PropertiesLabels[2].Remove(name);
                                break;

                            case ConfigurationRegistryRecord.PropertyListType.BatchComponent:
                                configurationBO.PropertiesLabels[3].Remove(name);
                                break;
                            case ConfigurationRegistryRecord.PropertyListType.Structure:
                                configurationBO.PropertiesLabels[4].Remove(name);
                                break;
                        }

                        configurationBO.Save();
                        break;
                    }
                }

                if (!found)
                    throw new IndexOutOfRangeException(string.Format("The property, {0}, was not found", name));
                return new ResponseData(message: string.Format("The property, {0}, was deleted successfully!", name));
            });
        }

        #endregion

        #region Settings
        [HttpGet]
        [Route(Consts.apiPrefix + "settings")]
        [SwaggerOperation("GetSettings")]
        [SwaggerResponse(200, type: typeof(List<SettingData>))]
        [SwaggerResponse(400, type: typeof(Exception))]
        [SwaggerResponse(401, type: typeof(Exception))]
        [SwaggerResponse(500, type: typeof(Exception))]
        public async Task<IHttpActionResult> GetSettings()
        {
            return await CallMethod(() =>
            {
                var settingList = new List<SettingData>();
                var currentApplicationName = RegUtilities.GetApplicationName();
                var appConfigSettings = FrameworkUtils.GetAppConfigSettings(currentApplicationName, true);
                var groups = appConfigSettings.SettingsGroup;
                foreach (var group in groups)
                {
                    var settings = group.Settings;
                    foreach (var setting in settings)
                    {
                        bool isAdmin;
                        if (bool.TryParse(setting.IsAdmin, out isAdmin) && isAdmin) continue;
                        settingList.Add(new SettingData(group, setting));
                    }
                }
                return settingList;
            });
        }

        [HttpPut]
        [Route(Consts.apiPrefix + "settings")]
        [SwaggerOperation("UpdateSetting")]
        [SwaggerResponse(200, type: typeof(ResponseData))]
        [SwaggerResponse(400, type: typeof(Exception))]
        [SwaggerResponse(401, type: typeof(Exception))]
        [SwaggerResponse(404, type: typeof(Exception))]
        [SwaggerResponse(500, type: typeof(Exception))]
        public async Task<IHttpActionResult> UpdateSetting([FromBody] SettingData data)
        {
            return await CallMethod(() =>
            {
                var settingInfo = "The setting {0} in {1}";
                var currentApplicationName = RegUtilities.GetApplicationName();
                var appConfigSettings = FrameworkUtils.GetAppConfigSettings(currentApplicationName, true);
                var groupName = (string)data.GroupName;
                if (string.IsNullOrEmpty(groupName))
                    throw new RegistrationException("The setting group must be specified");
                var settingName = (string)data.Name;
                if (string.IsNullOrEmpty(settingName))
                    throw new RegistrationException("The setting name must be specified");
                var settingValue = (string)data.Value;
                if (settingValue == null)
                    throw new RegistrationException("The setting value must be specified");
                bool found = false, updated = false;
                var groups = appConfigSettings.SettingsGroup;
                foreach (var group in groups)
                {
                    if (!group.Name.Equals(groupName)) continue;
                    var settings = group.Settings;
                    foreach (var setting in settings)
                    {
                        bool isAdmin;
                        if (bool.TryParse(setting.IsAdmin, out isAdmin) && isAdmin) continue;
                        if (!setting.Name.Equals(settingName)) continue;
                        found = true;
                        if (!setting.Value.Equals(settingValue))
                        {
                            updated = true;
                            setting.Value = settingValue;
                        }
                        break;
                    }
                    if (found) break;
                }
                if (!found)
                    throw new IndexOutOfRangeException(string.Format("{0} was not found", settingInfo));
                if (!updated)
                    throw new IndexOutOfRangeException("No change is required");
                FrameworkUtils.SaveAppConfigSettings(currentApplicationName, appConfigSettings);
                return new ResponseData(null, null, string.Format("{0} was updated successfully!", settingInfo), null);
            });
        }

        #endregion

        #region XML forms

        [HttpGet]
        [Route(Consts.apiPrefix + "xml-forms")]
        [SwaggerOperation("GetXmlForms")]
        [SwaggerResponse(200, type: typeof(List<XmlFormData>))]
        [SwaggerResponse(400, type: typeof(Exception))]
        [SwaggerResponse(401, type: typeof(Exception))]
        [SwaggerResponse(500, type: typeof(Exception))]
        public async Task<IHttpActionResult> GetXmlForms()
        {
            return await CallMethod(() =>
            {
                var xmlFormList = new List<XmlFormData>();
                var configRegRecord = ConfigurationRegistryRecord.NewConfigurationRegistryRecord();
                var formGroupTypes = Enum.GetValues(typeof(COEFormHelper.COEFormGroups));
                foreach (COEFormHelper.COEFormGroups formGroupType in formGroupTypes)
                {
                    configRegRecord.COEFormHelper.Load(formGroupType);
                    xmlFormList.Add(new XmlFormData(formGroupType.ToString(), configRegRecord.FormGroup.ToString()));
                }
                return xmlFormList;
            });
        }

        [HttpPut]
        [Route(Consts.apiPrefix + "xml-forms")]
        [SwaggerOperation("UpdateXmlForm")]
        [SwaggerResponse(200, type: typeof(ResponseData))]
        [SwaggerResponse(400, type: typeof(Exception))]
        [SwaggerResponse(401, type: typeof(Exception))]
        [SwaggerResponse(404, type: typeof(Exception))]
        [SwaggerResponse(500, type: typeof(Exception))]
        public async Task<IHttpActionResult> UpdateXmlForm(XmlFormData data)
        {
            return await CallMethod(() =>
            {
                var configRegRecord = ConfigurationRegistryRecord.NewConfigurationRegistryRecord();
                var formGroupTypes = Enum.GetValues(typeof(COEFormHelper.COEFormGroups));
                if (string.IsNullOrEmpty(data.Name))
                    throw new RegistrationException("Invalid form-group name");
                bool found = false;
                foreach (COEFormHelper.COEFormGroups formGroupType in formGroupTypes)
                {
                    if (!data.Name.Equals(formGroupType.ToString())) continue;
                    found = true;
                    configRegRecord.COEFormHelper.Load(formGroupType);
                    configRegRecord.COEFormHelper.SaveFormGroup(data.Data);
                    break;
                }
                if (!found)
                    throw new IndexOutOfRangeException(string.Format("The form-group, {0}, was not found", data.Name));
                return new ResponseData(null, null, string.Format("The form-group, {0}, was updated successfully!", data.Name), null);
            });
        }

        #endregion

        #region Configuration

        private void ExportConfigurationSettings(string currentExportDir)
        {
            XmlDocument confSettingsXml = new XmlDocument();
            var configRegRecord = ConfigurationRegistryRecord.NewConfigurationRegistryRecord();
            confSettingsXml.AppendChild(confSettingsXml.CreateElement("configurationSettings"));
            confSettingsXml.FirstChild.InnerXml = configRegRecord.GetConfigurationSettingsXml();
            WriteFile(currentExportDir, Consts.CONFIGSETTINGSFILENAME, true, confSettingsXml.OuterXml);
        }

        private void ExportCustomProperties(string currentExportDir)
        {
            var configurationBO = ConfigurationRegistryRecord.NewConfigurationRegistryRecord();
            WriteFile(currentExportDir, Consts.COEOBJECTCONFIGFILENAME, true, configurationBO.ExportCustomizedProperties());
        }

        private void ExportForms(string currentExportDir)
        {
            string formsDir = currentExportDir + "\\" + Consts.COEFORMSFOLDERNAME;
            Directory.CreateDirectory(formsDir);
            foreach (COEFormBO coeFormBO in COEFormBOList.GetCOEFormBOList(null, null, COEAppName.Get(), null, true))
            {
                COEFormBO toExport = COEFormBO.Get(coeFormBO.ID);
                WriteFile(formsDir, coeFormBO.ID.ToString(), true, toExport.COEFormGroup.ToString());
            }
        }

        private void ExportDataViews(string currentExportDir)
        {
            string dataViewDir = currentExportDir + "\\" + Consts.COEDATAVIEWSFOLDERNAME;
            Directory.CreateDirectory(dataViewDir);
            foreach (COEDataViewBO coeDV in COEDataViewBOList.GetDataviewListForApplication(COEAppName.Get()))
            {
                WriteFile(dataViewDir, coeDV.ID.ToString(), true, coeDV.COEDataView.ToString());
            }
        }

        private void ExportTables(List<string> tableNames, string currentExportDir)
        {
            string tablesDir = currentExportDir + "\\" + Consts.COETABLESFORLDERNAME;
            var configurationBO = ConfigurationRegistryRecord.NewConfigurationRegistryRecord();
            Directory.CreateDirectory(tablesDir);
            int tableNamePrefix = 1;
            foreach (string tableName in tableNames)
            {
                WriteFile(tablesDir, string.Format("{0:000}", tableNamePrefix++) + " - " + tableName, true, configurationBO.GetTable(tableName));
            }
        }

        private void WriteFile(string dir, string fileName, bool outputFormatted, string content)
        {
            XmlDocument document = new XmlDocument();
            if (fileName.Contains(".xml"))
            {
                fileName = fileName.Replace(".xml", string.Empty);
            }
            using (XmlTextWriter tw = new XmlTextWriter(dir + "\\" + fileName + ".xml", Encoding.UTF8))
            {
                tw.Formatting = outputFormatted ? Formatting.Indented : Formatting.None;
                document.LoadXml(content);
                document.Save(tw);
            }
        }

        [HttpGet]
        [Route(Consts.apiPrefix + "configuration-paths")]
        [SwaggerOperation("GetConfigurationPath")]
        [SwaggerResponse(200, type: typeof(JObject))]
        [SwaggerResponse(400, type: typeof(Exception))]
        [SwaggerResponse(401, type: typeof(Exception))]
        [SwaggerResponse(500, type: typeof(Exception))]
        public async Task<IHttpActionResult> GetConfigurationPath()
        {
            return await CallMethod(() =>
            {
                string FixedInstallPath = "Registration";
                Page page = new Page();
                string AppRootInstallPath = page.Server.MapPath(string.Empty).Remove(page.Server.MapPath(string.Empty).IndexOf(FixedInstallPath) + FixedInstallPath.Length);
                string AppDrive = HttpContext.Current.Server.MapPath(string.Empty).Remove(2);
                string CurrentDate = DateTime.Now.ToString("yy-MM-dd HH_mm_ss");
                var exportPath = AppDrive + Consts.EXPORTFILESPATH + CurrentDate;
                var importPath = AppRootInstallPath + Consts.IMPORTFILESPATH;
                return new JObject(
                        new JProperty("ExportPath", exportPath),
                        new JProperty("ImportPath", importPath));
            });
        }

        [HttpPost]
        [Route(Consts.apiPrefix + "configuration-export")]
        [SwaggerOperation("ExportConfiguration")]
        [SwaggerResponse(200, type: typeof(ResponseData))]
        [SwaggerResponse(400, type: typeof(Exception))]
        [SwaggerResponse(401, type: typeof(Exception))]
        [SwaggerResponse(500, type: typeof(Exception))]
        public async Task<IHttpActionResult> ExportConfiguration(ExportConfigurationData data)
        {
            return await CallMethod(() =>
            {
                Directory.CreateDirectory(data.ExportDir);
                ExportConfigurationSettings(data.ExportDir);
                ExportCustomProperties(data.ExportDir);
                ExportForms(data.ExportDir);
                ExportDataViews(data.ExportDir);
                if (data.SelectNone != true)
                    ExportTables(data.TableNames, data.ExportDir);
                return new ResponseData(message: string.Format("The configuration was exported successfully!"));
            });
        }

        [HttpPost]
        [Route(Consts.apiPrefix + "configuration-import")]
        [SwaggerOperation("ImportConfiguration")]
        [SwaggerResponse(201, type: typeof(ResponseData))]
        [SwaggerResponse(400, type: typeof(Exception))]
        [SwaggerResponse(401, type: typeof(Exception))]
        [SwaggerResponse(500, type: typeof(Exception))]
        public async Task<IHttpActionResult> ImportConfiguration(ImportConfigurationData data)
        {
            return await CallMethod(() =>
            {
                string FixedInstallPath = "Registration";
                Page page = new Page();
                var configurationBO = ConfigurationRegistryRecord.NewConfigurationRegistryRecord();
                string AppRootInstallPath = page.Server.MapPath(string.Empty).Remove(page.Server.MapPath(string.Empty).IndexOf(FixedInstallPath) + FixedInstallPath.Length);
                configurationBO.ImportCustomization(AppRootInstallPath, data.ServerPath, data.ForceImport);
                return new ResponseData(message: string.Format("The configuration was imported successfully!"));
            });
        }
        #endregion
    }
}
