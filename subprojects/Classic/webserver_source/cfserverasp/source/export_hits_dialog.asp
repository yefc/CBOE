<%'Copyright 1999-2003 CambridgeSoft Corporation. All rights reserved
'DO NOT EDIT THIS FILE%>
<html>
<%export =  Request.QueryString("export")%>

<head>
<!--#INCLUDE VIRTUAL = "/cfserverasp/source/cows_func_vbs.asp" -->
<!--#INCLUDE VIRTUAL = "/cfserverasp/source/manage_user_settings_vbs.asp"-->
<!--#INCLUDE VIRTUAL = "/cfserverasp/source/utility_func_vbs.asp"-->

<script LANGUAGE="javascript" src="/cfserverasp/source/Choosecss.js"></script>

<% 
'stop

dbkey = request("dbname")
formgroup = request("formgroup")
formmode = request("formmode")
templateAction =  request("templateAction")
ExportInfo = GetFormGroupVal(dbkey, formgroup,kSDFileFields)
templateName = request("templateName")
session("bShowStruc")=""
exportmode = request("export")
if not UCASE(exportmode) = "PREPAREEXPORT" then
	if not templateName <> "" then 
		'wipe out session variables if there is no template name. assume the call is from the search results window
		session("export_hits_display_names")=""
		session("export_hits_table_display_names")=""
		Set Session("ExportTemplateDict")= nothing
		Session("ExportTemplateDict")=""
		savedTemplateNames = getSavedTemplates()

	else
		savedTemplateNames = getSavedTemplates()
		'get template from dictionary. if templanteName is TEMP then session("export_hits_display_names") was saved in the export_hits_templates_dialog.asp page
		if not UCase(templateName) = "TEMP" then
			
			templateValue = Session("ExportTemplateDict").Item(templateName)
			tempArray = split(templateValue, ":|:", -1)
			session("export_hits_display_names") = tempArray(2)
		end if
	end if
end if

if INSTR(UCase(ExportInfo), "ALT_FORMGROUP:")> 0 then
	ExportInfo_temp=split(exportinfo, ":", -1)
	'set the HitlistID for the alt_formgroup to be the same as the original formgroup
	Session("HitListID" & dbkey & ExportInfo_temp(1)) = Session("HitListID" & dbkey & formgroup)
	formgroup =ExportInfo_temp(1)
	ExportInfo = GetFormGroupVal(dbkey, formgroup,kSDFileFields)
end if

if ExportInfo <> "" then
	theArray = Split(ExportInfo, ";", -1)
	
	on Error resume next
	if UBound(theArray) = 1 then
		'get maximum number of export
		MaxExportInfo = theArray(1)
		MaxExportInfo_Array = Split(MaxExportInfo, ":", -1)
		MaxExportNumber = MaxExportInfo_Array(1)
		
		'get export table information
		ExportTypeInfo = theArray(0)
		ExportTypeInfoArray = Split(theArray(0), ":", -1)
		ExportType = ExportTypeInfoArray(0)
		ExportTables = ExportTypeInfoArray(1)
		
		Select case UCase(ExportTables)
			Case "BASE_TABLE"
					ExportTables =getBaseTable(dbkey, formgroup, "basetable")
			Case "ALL"
				'leave as ALL so other routines can be flagged
			Case Else
				If Not UCASE(ExportType) = "VIEW" then
					if UCase(formgroup) = "REG_CTRBT_COMMIT_FORM_GROUP" or UCase(formgroup)="REVIEW_REGISTER_FORM_GROUP" then
						
						ExportTables = "TEMPORARY_STRUCTURES"
						
					else
						basetable = getBaseTable(dbkey, formgroup, "basetable")
						ExportTables = checkForBasetable(dbkey, formgroup, ExportTables, basetable) 'be sure the basetable is in there
					end if
				else
					ExportTables = ExportTypeInfoArray(1) 'leave the table name as it is since it is a view
				end if
		End Select
	else
		ExportTypeInfo = theArray(0)
		ExportTypeInfoArray = Split(theArray(0), ":", -1)
		ExportType = ExportTypeInfoArray(0)
		ExportTables = ExportTypeInfoArray(1)
		
		Select case UCase(ExportTables)
			Case "BASE_TABLE"
				ExportTables =getBaseTable(dbkey, formgroup, "basetable")
			Case "ALL"
				'leave as ALL so other routines can be flagged
			Case Else
				If Not UCASE(ExportType) = "VIEW" then
					if UCase(formgroup) = "REG_CTRBT_COMMIT_FORM_GROUP" or UCase(formgroup)="REVIEW_REGISTER_FORM_GROUP" then
						
						ExportTables = "TEMPORARY_STRUCTURES"
					else
						basetable = getBaseTable(dbkey, formgroup, "basetable")
						ExportTables = checkForBasetable(dbkey, formgroup, ExportTables, basetable)
					end if
				else
					ExportTables = ExportTypeInfoArray(1)
				end if
				
		End Select
		
		MaxExportNumber = ""
	end if
	if err.number <> 0 then
		Response.Write "Error in SDFileFields for "&  UCase(formgroup) & " : " & err.number & err.description
	end if
	
else
	
	ExportType = "TABLES"
	ExportTables =getBaseTable(dbkey, formgroup, "basetable")
	MaxExportNumber = ""
end if

Select Case UCase(ExportType)
	Case "VIEW"
		ViewTableName = ExportTables
		returnValue = GetFieldNamesFromTable(dbkey, formgroup, ExportTables)
		if Instr(returnValue,"ERROR_IN_VIEW")> 0 then
			Response.Write ViewTableName & " is not a valid view. The export was aborted"
			Response.end
		else
			relfields= returnValue
		end if
	Case ELSE
		if Session("bypass_ini" & dbkey & formgroup) = True then
			if UCase(formmode) = "EDIT" then
				relfields =GetFormGroupVal(dbkey, formgroup,kRelDetailFields)
			
			end if
			if UCase(formmode) = "LIST" then
				relfields =GetFormGroupVal(dbkey, formgroup,kRelListFields)
			end if
		else
			relfields =GetFormGroupVal(dbkey, formgroup,kRelFields)
		end if
End Select
relfieldsarray = split(relfields, ",", -1)
Dim i
for i = 0 to UBound(relfieldsarray) 'first go through and remove structure, molweight, formula, row_ids
	on error resume next
	test1 = split(relfieldsarray(i), ";", -1) 'break off datatype
	fullfieldname_test = test1(0)
	
	if InStr(fullfieldname_test, ":&") > 0 then 'check for alias specifiers and split off
		fullfieldname_test2 = Split(fullfieldname_test, ":&", -1)
		fullfieldname = fullfieldname_test2(0)
	else
		fullfieldname = fullfieldname_test
	end if
	test2 = split(fullfieldname, ".",-1) 'check fieldname for exluded items
	if UBound(test2) = 2 then
		tablename = test2(0) & "." & test2(1)
		fieldname = test2(2)
	else
		tablename = test2(0)
		fieldname = test2(1)
	end if
	
	if Not(UCase(fieldname)="STRUCTURE" or UCase(fieldname)="MOLWEIGHT" or UCASE(fieldname)="FORMULA" or UCASE(fieldname)="ROW_IDS" or UCASE(fieldname)="MOL_ID") then
		testItem= tablename & "." & fieldname
		if isAllowedTable(ExportTables, tablename) = True then
			if IsNotListDup(fullfieldname_list,testItem)= True then
				if IsNotGUIHidden(ExportType, testItem) = True then
					if fullfieldname_list <> "" then
						fullfieldname_list = fullfieldname_list & "," & testItem
					else
						fullfieldname_list = testItem
					end if
				end if 
			end if
		End if
	end if
Next

fullfieldname_list= getAllDisplayNames(dbkey, formgroup,formmode, fullfieldname_list)
'determine if basetable has structure so that the structure, mw and formula entries are output.
StrucUniqueID = GetTableVal(dbkey, basetable,kStrucFieldID)
'LJB 3/2005 set session variables that can be picked up by export_hits_templates_dialog.asp
if Not StrucUniqueID = "NULL" or StrucUniqueID = "" then
	bShowStruc = 1 
else
	bShowStruc = 0 
end if
'add structure displaystate
fullfieldname_list = "CS_STRUC_DATA|exp_struc_data|"& bShowStruc & "," & fullfieldname_list
'LJB 3/2005 Store field display names in a session variable to be used when export is performed.
if Not session("export_hits_display_names")<> "" then
	session("export_hits_display_names") = fullfieldname_list
else
	fullfieldname_list = session("export_hits_display_names")
end if
'fields_array = Split(fullfieldname_list, ",", -1)
basetable = GetBaseTable(dbkey, formgroup, "basetable")
tables_string=getTablesString2(dbkey, formgroup, fullfieldname_list)
If Not UCase(ExportType) = "VIEW" then
	if Not(UCase(formgroup) = "REG_CTRBT_COMMIT_FORM_GROUP" or UCase(formgroup)="REVIEW_REGISTER_FORM_GROUP") then
		tables_string=checkForBasetable(dbkey, formgroup, tables_string, basetable)
	end if
end if




tables_string=getTablesDisplayString(dbkey, formgroup,formmode, tables_string)
'LJB 3/2005 Store table display names in a session variable to be used when export is performed.
if Not session("export_hits_table_display_names")<> "" then
	session("export_hits_table_display_names") = tables_string
else
	tables_string = session("export_hits_table_display_names")
end if
Function checkForBasetable(dbkey, formgroup, ExportTables, basetable)
	bBaseFound = false
	theArray = Split(ExportTables, ",", -1)
	Dim i
	for i = 0 to UBound(theArray)
		if UCase(basetable) = UCase(theArray(i)) then
			bBaseFound = true
			exit for
		end if
	next
	if ExportTables <> "" then
		if bBaseFound = true then
			theReturn = ExportTables
		else
			theReturn = basetable & "," & ExportTables
		end if
	else
		theReturn = basetable
	end if
	checkForBasetable =theReturn
End Function

Function getFieldNamesFromTable(dbkey, formgroup, tablename)
	on error resume next
	Dim DataConn
	Dim RS
	Dim oField
	Set DataConn = GetNewConnection(dbkey, formgroup, "base_connection")
	sql = "SELECT * FROM " & tablename & " WHERE NULL = NULL"
	Set RS = DataConn.Execute(sql)
	For each oField in RS.Fields
		if theList <> "" then
			theList = theList &  "," & tablename & "." & oField.Name
		else
			theList = tablename & "." & oField.Name
		end if
	Next
	if err.number <> 0 then
		theReturn = "ERROR_IN_VIEW: " & err.number & err.description
	else
		theReturn = theList
	end if
	getFieldNamesFromTable= theReturn
End Function

Function isAllowedTable(ExportTables, tablename)
	if Not UCase(ExportTables) = "ALL" then
		on error resume next
		bAllowExport = False
		theArray = Split(ExportTables, ",", -1)
		Dim i
		for i = 0 to UBound(theArray)
			if UCase(Trim(tablename)) = UCase(Trim(theArray(i))) then
				bAllowExport = true
				exit for
			end if
		next
	else
		bAllowExport = True
	end if

	isAllowedTable=bAllowExport
End Function 

Function IsNotGUIHidden(ExportType, testItem)
	bShowItem=true

	if UCase(ExportType) = "VIEW" then
		bShowItem=true
		IsNotGUIHidden = bShowItem
		exit function
	end if

	on error resume next
	if Application("GUI_FIELDS_TO_HIDE")<> "" then
		thearray = Split(APPLICATION("GUI_FIELDS_TO_HIDE"), ",", -1)
		dim i
		for i = 0 to UBound(thearray)
			If inStr(thearray(i), ".")> 0 then
				if UCase(testItem) = UCase(thearray(i)) then
					bShowItem = false
					exit for
				end if
			else
				testItem2= split(testItem, ".", -1)
				
				if UBound(testItem2) = 2 then
					if UCase(testItem2(2)) = UCase(thearray(i)) then
						bShowItem = false
						exit for
					end if
				else
					if UCase(testItem2(1)) = UCase(thearray(i)) then
						bShowItem = false
						exit for
					end if
				end if
			end if
		next
	end if
	IsNotGUIHidden = bShowItem
	
End Function 

Function IsNotListDup(current_list, new_item)
	if current_list <> "" then
		bIsNotDup = true
		thearray = Split(current_list, ",", -1)
		Dim i
		for i = 0 to UBound(thearray)
			if UCase(thearray(i)) = UCase(new_item)then
				bIsNotDup = false
				exit for
			end if
		next
	else
		bIsNotDup = true
	end if
	IsNotListDup = bIsNotDup
end Function 

Function getAllDisplayNames(dbkey, formgroup,formmode, item_list)
		Dim i
		Dim temp_array
		Dim display_name_temp
		Dim display_nam
		Dim theReturnList
		temp_array = split(item_list, ",", -1)
		for i = 0 to UBound(temp_array)
		test_value = temp_array(i)
	
			display_name = getLabelNameFromDict(dbkey, formgroup, formmode,test_value)
			
			if not display_name <> "" then
				display_name_temp = split(test_value, ".", -1)
				display_name = display_name_temp(Ubound(display_name_temp))
			end if
			if theReturnList <> "" then
				theReturnList = theReturnList & "," & display_name & "|" & test_value & "|" & "0"
			else
				theReturnList = display_name & "|" & test_value & "|" & "0"
			end if
	Next
	
	getAllDisplayNames = theReturnList
End Function

Function getTablesDisplayString(dbkey, formgroup, formmode, inputStr)
		Dim temp_array
		Dim test_value
		Dim display_name
		Dim theReturnList
		Dim i
		temp_array = split(inputStr, ",", -1)
		
		for i = 0 to UBound(temp_array)
			test_value = temp_array(i)
			on error resume next
			display_name = getTableNameFromDict(dbkey, formgroup, formmode, test_value)
			if not display_name <> "" then
				display_name_temp = split(test_value, ".", -1)
				display_name = display_name_temp(Ubound(display_name_temp))
			end if
			if theReturnList <> "" then
				theReturnList = theReturnList & "," & display_name & "|" & test_value
			else
				theReturnList = display_name & "|" & test_value
			end if
	Next
	
	getTablesDisplayString = theReturnList
End Function



Function getTablesString2(dbkey, formgroup, inputStr)
	
	inputArray = split(inputStr, ",", -1)
	basetable = getBaseTable(dbkey, formgroup, "basetable")
	for i = 0 to Ubound(inputArray)
		temp_item = split(inputArray(i), "|")
		current_item = temp_item(1)
		if inStr(current_item, ";")> 0 then
			item_split1=Split(current_item, ";", -1)
			item_split2 =Split(item_split1(0), ".", -1)
			if UBound(item_split2) =2 then
				table_name = Trim(item_split2(0)) & "." & Trim(item_split2(1))
			else
				table_name = Trim(item_split2(0))
			end if
			if Not UCase(table_name) = UCase(basetable) then
				if Not UCase(table_name) = UCase("exp_struc_data") then
					if all_names <> "" then
						all_names = all_names & "," & table_name
					else
						 all_names = table_name 
					end if
				end if
			end if
		else
			item_split2 =Split(current_item, ".", -1)
			if UBound(item_split2) =2 then
				table_name = Trim(item_split2(0)) & "." & Trim(item_split2(1))
			else
				table_name = Trim(item_split2(0))
			end if
			if Not UCase(table_name) = UCase(basetable) then
				if Not UCase(table_name) = UCase("exp_struc_data") then
					if all_names <> "" then
						all_names = all_names & "," & table_name
					else
						 all_names = table_name 
					end if
				end if
			end if
			
		end if
	next
	final_string = RemoveDups(all_names)
	getTablesString2=final_string
	
end function 

'LJB 3/2005 get all saved templates for this form group. Create a dictionary so additional calls to the database are not made if any template logic is performed
function getSavedTemplates()
	if Application("ENABLE_EXPORT_TEMPLATES")="1" then
		if not isObject(Session("ExportTemplateDict")) then
			set myDict = Server.CreateObject("Scripting.Dictionary")
			Set TemplateNamesRS=getCurrentSettingsRS(dbkey, formgroup, Session("USER_SETTINGS_ID" & dbkey), "SDFEXPORTTEMPLATE" &  Session("USER_SETTINGS_ID" & dbkey) & UCase(dbkey) &  UCase(formgroup) & ":", "LIKE")
			
			if Not (TemplateNamesRS.BOF and TemplateNamesRS.EOF) then
				Do while not TemplateNamesRS.EOF
					template = TemplateNamesRS("Setting_Value").value
					temp = split(template, ":|:",-1)
					if not myDict.Exists(temp(0)) then myDict.Add temp(0), template
					tempoption_entry = temp(0) & ": " & temp(1)
					option_entry = TruncateString(tempoption_entry,30)
					if savedTemplateNames <> "" then
						savedTemplateNames = savedTemplateNames & "<option value=""" & temp(0) & """>" & option_entry & "</option>"
					else
						savedTemplateNames = "<option value=""" & temp(0) & """>" & option_entry & "</option>"
					end if
					TemplateNamesRS.MoveNext
				 loop
				 TemplateNamesRS.close
				
			 else
				 savedTemplateNames=""
			 end if
			 
			 Set Session("ExportTemplateDict") = myDict
			
		else
			
			vItemArray =Session("ExportTemplateDict").Items
			For i =0 to Session("ExportTemplateDict").Count -1
				TemplateValue= vItemArray(i)
				temp = split(TemplateValue, ":|:", -1)
				tempoption_entry = temp(0) & ": " & temp(1)
				option_entry = TruncateString(tempoption_entry,30)
				if savedTemplateNames <> "" then
					savedTemplateNames = savedTemplateNames & "<option value=""" & temp(0) & """>" & option_entry & "</option>"
				else
					savedTemplateNames = "<option value=""" & temp(0) & """>" & option_entry & "</option>"
				end if
			next
		end if
	else
		savedTemplateNames=""
	end if
	getSavedTemplates = savedTemplateNames
end function

Function TruncateString(strText, Length)
	Dim str
	
	if len(strText) > Length then 
		str = str & left(strText, Length-3) & "..."
	else
		str = strText
	end if
	
	TruncateString = str
End function				
%>

<script language="JavaScript">
MainWindow = opener
var exporttest = "<%=export%>"
var bshowstruct = "<%=bShowStruc%>"
var allfields
//allfields = MainWindow.relational_fields
var basetable = MainWindow.base_table
var dbname = MainWindow.dbname
var actionpath = MainWindow.action_form_path
var w = self
var fields = ""
var formmode= "<%=formmode%>"
var templateAction= "<%=templateAction%>"
var formgroup = "<%=formgroup%>"

function doExport(){
	//LJB 3/2005post back to this page and call new prepareexport case for gathering checkbox state and creating session and dictionary variables for export
	var exportaction = 'prepareexport'
	var actiontemp = '/<%=Application("appkey")%>/export_hits.asp?export=' + exportaction + '&dbname=' + dbname + '&formgroup=' + formgroup + '&formmode=' + formmode
	document.exporthits.action = actiontemp
	//actiontemp = actionpath + '?dataaction=export_hits&dbname=' + dbname + '&formgroup=' + MainWindow.formgroup + "&formmode=" + formmode
	//document.exporthits.action = actiontemp
	document.exporthits.submit()
}

//LJB 3/2005 load export_hits_template_dialog.asp for creating and managing export templates
function doManageTemplates(theForm){
	var manage_template_mode = theForm.export_hits_templates.options[theForm.export_hits_templates.selectedIndex].value;
	if( manage_template_mode != 'placeholder'){
		if ((manage_template_mode=='edit')||(manage_template_mode=='manage')){
			var userid="<%=Session("UserID" & dbname)%>"
			var actiontemp = '/<%=Application("appkey")%>/export_hits.asp?manage_template_mode=' + manage_template_mode + '&dbname=' + dbname + '&formgroup=' + formgroup + '&formmode=' + formmode
			document.exporthits.action = actiontemp
			document.exporthits.method = 'post';
			document.exporthits.submit();
			
		}else{
			if (manage_template_mode =='default'){
				var actiontemp ='/<%=Application("appkey")%>/export_hits.asp?dbname=' + dbname + '&formgroup=' + formgroup + '&formmode=' + formmode
				document.exporthits.action = actiontemp
				document.exporthits.method = 'post';
				document.exporthits.submit();
			
			}else{
				var actiontemp ='/<%=Application("appkey")%>/export_hits.asp?templatename=' + manage_template_mode + '&dbname=' + dbname + '&formgroup=' + formgroup + '&formmode=' + formmode
				document.exporthits.action = actiontemp
				document.exporthits.method = 'post';
				document.exporthits.submit();
			}
		}
	}
}



</script>

<title>Export Hits</title>

<script language="javascript">
var exporttest = "<%=export%>"

function checkAllBoxes(){
if (exporttest == ""){
	f = document.exporthits
	for (i=0;i<f.length;i++){
		var e = f.elements[i]
		if (e.type == "checkbox"){
		
		e.checked = true
		
		}
	}
}
}

function clearAllCheckBoxes(){
if (exporttest == ""){
	f = document.exporthits
	for (i=0;i<f.length;i++){
		var e = f.elements[i]
		if (e.type == "checkbox"){
		
		e.checked = false
		
		}
	}
}
}

</script>
</head>

<body>


<%exportTask = Request.QueryString("export")
	if Trim(exportTask) ="" then 
		exportTask="DIALOG"
		'wipe out session dictionary used for export. This should be wiped after each exort, this is a extra safegaurd
		if isObject(session("export_hits_display_names_DICT")) then
			set session("export_hits_display_names_DICT") = nothing
		end if
		session("export_hits_display_names_DICT")=""
		'wipe out sessio variable containing field names for export. This should be wiped after each exort, this is a extra safegaurd
		session("all_export_fields") =""
end if
	Select case UCase(exportTask) 

		case "DIALOG"
			'LJB 3/2005  Show standard export dialog
		%>
				<!--webbot bot="HTMLMarkup" TAG="XBOT" StartSpan --><INPUT type="hidden" name="DataAction" value="export_hits"><!--webbot BOT="HTMLMarkup" endspan -->
				<table><tr><td valign="top"><a HREF="javascript:doExport()" border="0">
				<img SRC="<%=Application("NavButtonGifPath") & "OK.gif"%>" border="0"></a> </td><td valign="top"><a HREF="javascript:window.close()" alt="proceed with export"><img SRC="<%=Application("NavButtonGifPath") & "Cancel.gif"%>" border="0" alt="close window without changes"></a></td>
				<td valign="top"><a href="javascript:clearAllCheckBoxes()"><img SRC="<%=Application("NavButtonGifPath") & "Clear_all_btn.gif"%>" border="0" alt="clear all checkboxes"></a></td><td valign="top"><a href="javascript:checkAllBoxes()"><img SRC="<%=Application("NavButtonGifPath") & "Select_all_btn.gif"%>" border="0" alt="select all checkboxes"></a></td>
				</tr></table>

				<script language="javascript">
				var allfields = "<%=fullfieldname_list%>"
				
				var enable_export_templates = "<%=Application("ENABLE_EXPORT_TEMPLATES")%>"

				var alltables = "<%=tables_string%>"
				var flat_file_export = "<%=Application("ALLOW_FLAT_SDFILE_EXPORT")%>"
				var rd_file_export = "<%=Application("ALLOW_RDFILE_EXPORT")%>"

				var export_template_select =""
				if (enable_export_templates == '1'){
					export_template_select = "<select name='export_hits_templates' onChange=doManageTemplates(this.form)><option value='placeholder'>--Select Template Action--</option><option value='edit'>Create New Template</option><option value='manage'>Manage Templates</option><option value='default'>Use Defaults</option><option value='placeholder'>--Saved Templates--</option><%=Replace(savedTemplateNames, """", "\""")%></select>";
				}
				
				myarray = allfields.split(",")
				mytables = alltables.split(",")
				document.write('Choose an output format, select the fields to export and click OK. <strong>')
				document.write('<form name = "exporthits" method = "post" action = "">')
				
				document.write('<table valign="top"><tr><td>');
				document.write('<input type="radio" checked value="SDFile" name="File_Ouput_Type">Nested SDFile')
				
				if (flat_file_export=="1"){
					document.write('&nbsp;<input type="radio" name="File_Ouput_Type" value="Flat_SDFile" >Flat SDFile')
					document.forms["exporthits"].File_Ouput_Type[1].click();
				}
				if  (rd_file_export=="1"){
					//SYAN added on 9/28/2005 to fix CSBR-59638
					document.write('&nbsp;<input type="radio" value="RDFile" name="File_Ouput_Type">RDFile</td>')
					//End of SYAN modification
				}
				
				
				if (enable_export_templates == '1'){
					document.write('<td>&nbsp;&nbsp;&nbsp;Export Templates</td></tr><tr><td>&nbsp;</td><td>&nbsp;&nbsp;&nbsp;' + export_template_select)
				} 
				
				document.write('</td></tr></table>');
				
				
				document.write("<p align=center><b>Template Name:</b>&nbsp;<%=Request.QueryString("templatename")%></p>")
				document.write('<table border = "1" width = 100%><tr><td><table border = "0"><tr>')
				document.write('<td width="100" valign="middle"  height="20"><strong>&nbsp;</strong></td>')
				document.write('<td width="100" valign="middle"  height="20"><strong>&nbsp;</strong>')
				document.write('</td><td width="100" valign="middle" height="20" align="center" ><strong>')
				document.write('Export</strong></td></tr>')
				strucDisplay = myarray[0].split("|")
				var checkedState = ""
				var bcheckstate =  strucDisplay[2]
			
				if (bcheckstate == 1){
					checkedState = " checked"
				}else{
					checkedState= ""
				}
			
				document.write ('<tr><td>&nbsp;</td><td width="225" valign="top"  height="30">STRUCTURE,MW,FORMULA</td>')
				document.write ('<td width="100" valign="top" align= "center" height="30"><input type="checkbox" ' + checkedState + ' name="exp_struc_data_checkbox" value="checked"></td></tr>')
				

				for (i=0;i<mytables.length;i++){
					var current_table_temp = mytables[i].split("|")
					var current_table = current_table_temp[1]
					var display_table_name = current_table_temp[0]
					document.write('<tr><td colspan="3"><font size="2"><b>' + display_table_name.toUpperCase() + '</b></font></td></tr>')
					
					for (j=1;j<myarray.length;j++){
					do_output = false
						temp_display =  myarray[j].split("|")
						display_name = temp_display[0]
						bcheckstate = temp_display[2]
						
						if (bcheckstate == 1){
							checkedState = " checked"
						}else{
							checkedState= ""
						}
						temp2 = temp_display[1].split(".")
						if (temp2.length == 3){
							test_table = temp2[0] + '.' + temp2[1]
							if ( test_table.toLowerCase() == current_table.toLowerCase()){
								displayval =display_name
								
								hiddenval =  temp_display[1].toUpperCase()
								do_output = true
							}
						}else{
							if (temp2[0].toLowerCase() == current_table.toLowerCase()){
									displayval =display_name
								
								hiddenval = temp_display[1].toUpperCase()
								do_output = true
							}
						}
						
						if(do_output == true){
							document.write('<tr><td>&nbsp;</td><td width="225" valign="top"  height="30">' + displayval + '</td><td width="100" valign="top" align= "center" height="30"><input type="checkbox" ' + checkedState + ' name="' + hiddenval + '_checkbox" value="checked"> ')
						
						}
					}
				}
				document.write ('<input type = "hidden" name="ExportType" value = "<%=ExportType%>">')
				document.write ('<input type = "hidden" name="MaxExportNumber" value = "<%=MaxExportNumber%>">')

				document.write ('</form></td></tr></table></td></tr></table>')
				</script>
		<%case "PREPAREEXPORT"
				'LJB 3/2005  Get checkbox state for fields and create session and dictionary objects to be used by form_action_vbs.asp and sdfile_output_vbs.asp
				
				'wipe out session dictionary used for export. This should be wiped after each exort, this is a extra safegaurd
				if isObject(session("export_hits_display_names_DICT")) then
					set session("export_hits_display_names_DICT") = nothing
				end if
				session("export_hits_display_names_DICT")=""
				'wipe out sessio variable containing field names for export. This should be wiped after each exort, this is a extra safegaurd
				session("all_export_fields") =""
				
				'get current export checkbox settings and add to session variable for export
				temp = split(session("export_hits_display_names"), ",", -1)
				set myDict = server.CreateObject("scripting.dictionary")
				for i = 0 to UBound(temp)
					temp1 = split(temp(i), "|", -1)
					fieldname = temp1(1)
					displayname = temp1(0)
					
					checkedstate = request(fieldname & "_checkbox")
					if checkedstate = "checked" then
						bchecked=1
					else
						bchecked = 0
					end if
					
					'create a dictionary of only the fields that have been selected for export
					
					if bchecked = 1 then
						if not UCase(fieldname) = UCase("exp_struc_data") then
							if Not myDict.Exists(fieldname) then
								myDict.Add UCase(fieldname), displayname
							end if
						
							if all_export_fields <> "" then
								all_export_fields = all_export_fields & "," & fieldname
							else
								all_export_fields =  fieldname
							end if
						end if
					end if
				next	
				'reset 
				'update session variable with display names for use by export 
				set session("export_hits_display_names_DICT")=myDict
				'update session variable with actual fields names for exprot
				session("all_export_fields") = all_export_fields
				ExportType = request("exporttype")
				MaxExportNumber = request("MaxExportNumber")
				OutputType = request("File_Ouput_Type")
				
				export_structure_data = request("exp_struc_data_checkbox")
				if export_structure_data = "checked" then
					export_structure_data="CS_OUTPUT_STRUC_DATA"
				end if
				appendvars = "&export_structure_data=" & export_structure_data & "&exporttype=" & ExportType & "&MaxExportNumber=" & MaxExportNumber & "&File_Ouput_Type=" & OutputType
				actionPath ="/" & Application("appkey") & "/" & dbkey  & "/" & dbkey & "_action.asp?dataaction=export_hits&dbname=" & dbkey & "&formgroup=" & formgroup & "&formmode=" & formmode & appendvars
				Response.redirect actionPath
		case "COMPLETE" 
				'wipe out session dictionary used for export. These should be wiped out after each export, but this is a safeguard
				if isObject(session("export_hits_display_names_DICT")) then
					set session("export_hits_display_names_DICT") = nothing
				end if
				session("export_hits_display_names_DICT")=""
				session("all_export_fields") =""
				session("export_hits_display_names")=""%>
				<a HREF="<%=Session("filepath")%>">Click to Download</a>
		<%End Select%> 
</p>
</body>
</html>
