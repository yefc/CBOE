using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Text;
using System.Windows.Forms;
using CambridgeSoft.COE.DataLoader.Core;
using System.Diagnostics;
using System.IO;
using System.Threading;
using System.Text.RegularExpressions;
using System.Data.OleDb;
using CambridgeSoft.DataLoaderGUI.Properties;
using CambridgeSoft.DataLoaderGUI.Common;
using CambridgeSoft.DataLoaderGUI.Forms;
using CambridgeSoft.COE.DataLoader.Core.Workflow;

namespace CambridgeSoft.DataLoaderGUI.Controls
{
    public partial class ImportOption : UIBase
    {
        private JobParameters _job;
        private string _xmlPath;
        private string _userName;
        private string _password;
        private TargetActionType _targetActionType;
        private string _FullFilePath;
        private string _strFilePath;
        private bool _backToFront = false;
        private bool _skipflag = false;
        private Process[] p;
        private Mutex mut = new Mutex();
        public JobParameters JOB
        {
            set { this._job = value; }
        }
        public string UserName
        {
            set { this._userName = value; }
        }
        public string Password
        {
            set { this._password = value; }
        }
        public string FullFilePath
        {
            set { this._FullFilePath = value; }
        }
        public string StrFilePath
        {
            set { this._strFilePath = value; }
        }
        public string XmlPath
        {
            set { this._xmlPath = value; }
        }

        public bool OptionPanelEnabled
        {
            set { this._OptionPanel.Enabled = value; }
        }

        public bool ResultVisable
        {
            set
            {
                _ResultLabel.Visible = value;
                _ResultRichTextBox.Visible = false;
            }
        }

        public bool BackToFront
        {
            get { return _backToFront; }
        }

        public bool Skipflag
        {
            set { _skipflag = value; }
        }

        public ImportOption()
        {
            InitializeComponent();
            Controls.Add(AcceptButton);
            Controls.Add(CancelButton);
            AcceptButton.Click += new EventHandler(AcceptButton_Click);
            CancelButton.Click += new EventHandler(CancelButton_Click);
            _ResultLabel.Visible = false;
            _ResultRichTextBox.Visible = false;
        }

        private void AcceptButton_Click(object sender, EventArgs e)
        {
            try
            {
                base.Cursor = Cursors.WaitCursor;
                if (AcceptButton.Text == "Exit")
                {
                    OnAccept();
                }

                string strFile = _FullFilePath;
                if (!System.IO.File.Exists(strFile))
                {
                    MessageBox.Show("Input file error.", Resources.Message_Title, MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return;
                }

                if (!System.IO.File.Exists(_xmlPath))
                {
                    MessageBox.Show("Mapping file error.", Resources.Message_Title, MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return;
                }

                this._OptionPanel.Enabled = false;

                if (_ImportTempRadioButton.Checked == true)
                {
                    _targetActionType = TargetActionType.ImportTemp;
                }
                else if (_ImportRegDupNoneRadioButton.Checked == true)
                {
                    _targetActionType = TargetActionType.ImportRegDupNone;
                }
                else if (_ImportRegDupAsTempRadioButton.Checked == true)
                {
                    _targetActionType = TargetActionType.ImportRegDupAsTemp;
                }
                else if (_ImportRegDupAsCreateNewRadioButton.Checked == true)
                {
                    _targetActionType = TargetActionType.ImportRegDupAsCreateNew;
                }
                else if (_ImportRegDupAsCreateNewBatchRadioButton.Checked == true)
                {
                    _targetActionType = TargetActionType.ImportRegDupAsNewBatch;
                }
                _ResultLabel.Visible = false;
                _ResultRichTextBox.Visible = false;
                if (AcceptButton.Text == "Next")
                {
                    ExecuteCOEDataLoader();
                }

            }
            catch (Exception ex)
            {
                string message = ex.Message + "\n" + ex.StackTrace;
                Trace.WriteLine(DateTime.Now, "Time ");
                Trace.WriteLine(message, "ImportOption");
                Trace.Flush();
                MessageBox.Show(ex.Message, Resources.Message_Title, MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }
            finally
            {
                base.Cursor = Cursors.Default;
            }

            AcceptButton.Text = "Exit";
            AcceptButton.TextAlign = ContentAlignment.MiddleCenter;
            AcceptButton.Image = null;
        }

        private void CancelButton_Click(object sender, EventArgs e)
        {
            OnCancel();
        }

        private void _ImportAnotherFile_Click(object sender, EventArgs e)
        {
            _backToFront = true;
            OnAccept();
        }

        private void ExecuteCOEDataLoader(int j)
        {
            if (_skipflag)
            {
                string strFile = _strFilePath;
                bool boolflag = _job.DataSourceInformation.HasHeaderRow;

                if (strFile.ToLower().EndsWith(".txt"))
                {
                    if (boolflag)
                    {
                        string[] strText = System.IO.File.ReadAllLines(strFile);
                        string headerText = strText[0].ToString();

                        string[] strTextSplit = System.IO.File.ReadAllLines(_FullFilePath);
                        if (strTextSplit[0].ToString() != strText[0].ToString())
                        {
                            string cont = System.IO.File.ReadAllText(_FullFilePath);
                            string headerTexts = headerText + "\r" + cont;
                            System.IO.File.Delete(_FullFilePath);

                            FileStream fsas = new FileStream(_FullFilePath, FileMode.OpenOrCreate, FileAccess.ReadWrite, FileShare.ReadWrite);
                            StreamWriter swa = new StreamWriter(fsas);

                            swa.WriteLine(headerTexts);
                            swa.Close();
                            fsas.Close();
                        }
                    }
                }

                if (strFile.ToLower().EndsWith(".xls") ||
                    strFile.ToLower().EndsWith(".xlsx"))
                {
                    if (boolflag)
                    {
                        string strHead = "NO";
                        if (_job.DataSourceInformation.HasHeaderRow)
                        { strHead = "NO"; }
                        else
                        {
                            strHead = "YES";
                        }
                        string strCon = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + strFile + ";Extended Properties=\"Excel 8.0;HDR=" + strHead + ";IMEX=1\"";
                        OleDbConnection myConn = new OleDbConnection(strCon);
                        string sheetname = _job.DataSourceInformation.TableName;
                        string strCom = " SELECT * FROM [" + sheetname + "$]";
                        myConn.Open();

                        OleDbDataAdapter myCommand = new OleDbDataAdapter(strCom, myConn);
                        DataSet ds = new DataSet();
                        myCommand.Fill(ds);
                        myConn.Close();
                        string headerText = "";

                        for (int k = 0; k < ds.Tables[0].Columns.Count; k++)
                        {
                            headerText += ds.Tables[0].Rows[0][k].ToString() + "\t";
                        }

                        string[] strTextSplit = System.IO.File.ReadAllLines(_FullFilePath);

                        if (strTextSplit[0].ToString() != headerText)
                        {
                            headerText = headerText.Trim();
                            string cont = System.IO.File.ReadAllText(_FullFilePath);
                            string headerTexts = headerText + "\r" + cont;
                            System.IO.File.Delete(_FullFilePath);

                            FileStream fsas = new FileStream(_FullFilePath, FileMode.OpenOrCreate, FileAccess.ReadWrite, FileShare.ReadWrite);
                            StreamWriter swa = new StreamWriter(fsas);

                            swa.WriteLine(headerTexts);
                            swa.Close();
                            fsas.Close();
                        }
                    }
                }
            }

            JobArgumentInfo jobArgsTemp = new JobArgumentInfo();
            jobArgsTemp.ActionType = _targetActionType;
            jobArgsTemp.DataFile = _FullFilePath;
            jobArgsTemp.MappingFile = _xmlPath;

            if (_FullFilePath.ToLower().EndsWith(".xls") ||
                _FullFilePath.ToLower().EndsWith(".xlsx"))
            {
                jobArgsTemp.TableOrWorksheet = _job.DataSourceInformation.TableName;
                jobArgsTemp.HasHeader = _job.DataSourceInformation.HasHeaderRow;
                jobArgsTemp.FileType = SourceFileType.MSExcel;
            }
            else if (_FullFilePath.ToLower().EndsWith(".txt"))
            {
                jobArgsTemp.HasHeader = _job.DataSourceInformation.HasHeaderRow;
                if (_job.DataSourceInformation.FileType == SourceFileType.MSExcel)
                {
                    jobArgsTemp.Delimiters = new string[] { "\\t" };
                    jobArgsTemp.FileType = SourceFileType.CSV;
                }
                else
                {
                    jobArgsTemp.Delimiters = (_job.DataSourceInformation.FieldDelimiters[0].ToString().Equals("\t") ? new string[] { "\\t" } :
                   new string[] { _job.DataSourceInformation.FieldDelimiters[0].ToString() });
                    jobArgsTemp.FileType = SourceFileType.CSV;
                }
            }
            else
            {
                jobArgsTemp.FileType = _job.DataSourceInformation.FileType;
            }
            jobArgsTemp.UserName = _userName;
            jobArgsTemp.Password = _password;
            jobArgsTemp.RangeBegin = _job.ActionRanges[0].RangeBegin + 1;
            jobArgsTemp.RangeEnd = _job.ActionRanges[0].RangeEnd + 1;
            JobParameters job = JobArgumentInfo.ProcessArguments(jobArgsTemp);
            if (!string.IsNullOrEmpty(System.Configuration.ConfigurationManager.AppSettings["CslaDataPortalUrl"]))
            {
                job.UserName = jobArgsTemp.UserName;
                job.Password = jobArgsTemp.Password;
            }
            JobExecutor objJobExecutor = new JobExecutor();
            objJobExecutor.DoUnattendedJob(job);
        }

        private void ExecuteCOEDataLoader()
        {
            JobArgumentInfo jobArgsTemp = new JobArgumentInfo();
            jobArgsTemp.ActionType = _targetActionType;
            jobArgsTemp.DataFile = _FullFilePath;
            jobArgsTemp.MappingFile = _xmlPath;

            if (_FullFilePath.ToLower().EndsWith(".xls") ||
                _FullFilePath.ToLower().EndsWith(".xlsx"))
            {
                jobArgsTemp.TableOrWorksheet = _job.DataSourceInformation.TableName;
                jobArgsTemp.HasHeader = _job.DataSourceInformation.HasHeaderRow;
                jobArgsTemp.FileType = SourceFileType.MSExcel;
            }
            else if (_FullFilePath.ToLower().EndsWith(".txt"))
            {
                jobArgsTemp.HasHeader = _job.DataSourceInformation.HasHeaderRow;
                if (_job.DataSourceInformation.FileType == SourceFileType.MSExcel)
                {
                    jobArgsTemp.Delimiters = new string[] { "\\t" };
                    jobArgsTemp.FileType = SourceFileType.CSV;
                }
                else
                {
                    jobArgsTemp.Delimiters = (_job.DataSourceInformation.FieldDelimiters[0].ToString().Equals("\t") ? new string[] { "\\t" } :
                    new string[] { _job.DataSourceInformation.FieldDelimiters[0].ToString() });
                    jobArgsTemp.FileType = SourceFileType.CSV;
                }
            }
            else
            {
                jobArgsTemp.FileType = _job.DataSourceInformation.FileType;
            }
            jobArgsTemp.UserName = _userName;
            jobArgsTemp.Password = _password;
            jobArgsTemp.RangeBegin = _job.ActionRanges[0].RangeBegin + 1;
            jobArgsTemp.RangeEnd = _job.ActionRanges[0].RangeEnd + 1;
            JobParameters job = JobArgumentInfo.ProcessArguments(jobArgsTemp);
            if (!string.IsNullOrEmpty(System.Configuration.ConfigurationManager.AppSettings["CslaDataPortalUrl"]))
            {
                job.UserName = jobArgsTemp.UserName;
                job.Password = jobArgsTemp.Password;
            }
            JobExecutor jobexe = new JobExecutor();
            jobexe.DoUnattendedJob(job);

            _ResultLabel.Visible = true;
            _ResultRichTextBox.Visible = false;
            StringBuilder ResultMessage = new StringBuilder();
            //ResultMessage.Append(string.Format(Resources.LogSum_ExpectedRange, objJobExecutor.TotalRecordsCount, jobArgsTemp.RangeBegin, objJobExecutor.TotalRecordsCount, (objJobExecutor.TotalRecordsCount + 1 - jobArgsTemp.RangeBegin)));
            //ResultMessage.Append(System.Environment.NewLine);
            //ResultMessage.Append(string.Format(Resources.LogSum_Invalid, objJobExecutor.InvalidRecordsCount));
            //ResultMessage.Append(System.Environment.NewLine);
            //ResultMessage.Append(string.Format(Resources.ImportedResult, (objJobExecutor.TemporalRecordsCount + objJobExecutor.PermanentRecordsCount), objJobExecutor.TemporalRecordsCount, objJobExecutor.PermanentRecordsCount));
            do
            {
                System.Threading.Thread.Sleep(100);
                ResultMessage.Append("TemporalRecords  : " + jobexe.JobResult.TemporalRecordsCount.ToString());
                ResultMessage.Append("PermanentRecords  : " + jobexe.JobResult.PermanentRecordsCount.ToString());
                ResultMessage.Append("InvalidRecords  : " + jobexe.JobResult.InvalidRecordsCount.ToString());

            } while (jobexe.JobResult.ThreadComplete < jobexe.JobResult.ThreadCount);

            //using Resources.MatchingRegistrations and importResult[i].Message we can cound the duplicates found in the Import process.
            _ResultLabel.Text = ResultMessage.ToString();
        }

        public void AuthorizeUser()
        {
            //these two permisions dictate access to the temporary Registry
            bool hasRegTempPermission = (
                Csla.ApplicationContext.User.IsInRole("ADD_COMPOUND_TEMP")
                || Csla.ApplicationContext.User.IsInRole("REGISTER_TEMP")
            );

            _ImportTempRadioButton.Enabled = hasRegTempPermission;
            //these two permisions dictate access to the permanent Registry
            bool hasRegPermPermission = (
                Csla.ApplicationContext.User.IsInRole("ADD_COMPONENT")
                || Csla.ApplicationContext.User.IsInRole("EDIT_COMPOUND_REG")
                || Csla.ApplicationContext.User.IsInRole("REGISTER_DIRECT")
            );

            _ImportRegDupNoneRadioButton.Enabled = hasRegPermPermission;
            _ImportRegDupAsTempRadioButton.Enabled = hasRegPermPermission;
            _ImportRegDupAsCreateNewRadioButton.Enabled = hasRegPermPermission;
            _ImportRegDupAsCreateNewBatchRadioButton.Enabled = hasRegPermPermission;

            if (hasRegTempPermission == false && hasRegPermPermission == false)
            {
                AcceptButton.Text = "Exit";
                AcceptButton.Image = null;
                AcceptButton.TextAlign = ContentAlignment.MiddleCenter;
                _ResultLabel.Visible = true;
                _ResultRichTextBox.Visible = false;
                _ResultLabel.Text = "Insufficient privileges for requested operation.";
            }
        }
    }

    public class FIleLastTimeComparer : IComparer<FileInfo>
    {
        #region IComparer<FileInfo>
        public int Compare(FileInfo x, FileInfo y)
        {
            return x.LastWriteTime.CompareTo(y.LastWriteTime);
        }
        #endregion
    }
}
