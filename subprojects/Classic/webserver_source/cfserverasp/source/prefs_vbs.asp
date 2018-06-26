<%' Copyright 1999-2003 CambridgeSoft Corporation. All rights reserved
'DO NOT EDIT THIS FILE

on error resume next%>
<html>

<head>

<!--#INCLUDE VIRTUAL = "/cfserverasp/source/ado.inc"-->
<!--#INCLUDE VIRTUAL = "/cfserverasp/source/server_const_vbs.asp"-->
<!--#INCLUDE VIRTUAL = "/cfserverasp/source/manage_user_settings_vbs.asp"-->
<!--#INCLUDE VIRTUAL = "/cfserverasp/source/manage_queries.asp"-->

<script LANGUAGE="javascript" src="/cfserverasp/source/Choosecss.js"></script>

<%
if Application("CsCartridgeMajorVersion") = "" then 
	CsCartridgeMajorVersion = 0
else
	CsCartridgeMajorVersion = Application("CsCartridgeMajorVersion")
	CsCartridgeBuildNumber = Application("CsCartridgeBuildNumber")
end if

isTautomerSupport = false
isLooseDelocalizationSupport = false
isImplicitHSupport = false
if CsCartridgeMajorVersion > 2 then
	' Tautomer support added in cartridge 9.0.0.1
	isTautomerSupport = true
	if (CsCartridgeMajorVersion = 9 and CsCartridgeBuildNumber > 200) then
		' Loose delocalization added with 9.0.0.200 and deprecated with v 11
		    
		isLooseDelocalizationSupport = true
	end if
	if (CsCartridgeMajorVersion > 9) Or (CsCartridgeMajorVersion = 9 and CsCartridgeBuildNumber >= 198) then
		'Ignore Implicit Hydrogen added with 9.0.0.198
		isImplicitHSupport = true
	end if		
end if

	
dbkey = request("dbname")
formgroup = request("formgroup")
pref_formgroups = Application("Prefs_FormGroups")
buttonpath =Application("NavButtonGifPath") 

' DGB deprecate tge bshow71Flags variable.
bshow71Flags ="true"
'if (Application("MOLSERVER_VERSION") = "7.1" AND NOT  Application("MOLSERVER_VERSION")<> "") then
'	bshow71Flags = "true"
'	
'end if

'if Application("MOLSERVER_VERSION") = "8" then
'	bshow71Flags = "true"
'end if

User_ID = getUserSettingsID(dbkey, formgroup)
	currentSearchPrefs = selectCurrentSettings(dbkey, formgroup, User_ID, "SEARCHPREFS" & dbkey & formgroup)
	
	if currentSearchPrefs = -1 then
		currentSearchPrefs= ""
	end if
	if not currentSearchPrefs <> ""  then
		Session("SearchPrefs" & dbkey )=Application("SEARCH_PREF_DEFAULTS")
	else
		Session("SearchPrefs" & dbkey ) = currentSearchPrefs
	end if
	currentDisplayPrefs = selectCurrentSettings(dbkey, formgroup, User_ID, "USERRESULTSPREFS" & dbkey & formgroup)
	if currentDisplayPrefs = -1 then
		currentDisplayPrefs= ""
	end if
	if not currentDisplayPrefs <> ""  then
		Session("UserResultsPrefs" & dbkey ) = "list"
	else
		Session("UserResultsPrefs" & dbkey ) = currentDisplayPrefs
	end if
	
	currentNumDisplayPrefs = selectCurrentSettings(dbkey, formgroup, User_ID, "USERNUMLISTVIEW" & dbkey & formgroup)
	if currentNumDisplayPrefs = -1 then
		currentNumDisplayPrefs= ""
	end if
	if not currentNumDisplayPrefs <> ""  then
		' DGB Get the default from forgroup array
		fgArray = Application(formgroup & dbkey) 
		if isArray(fgArray) then	
			defaultListView = fgArray(14)
			' DGB remember the application default
			Session("fgDefaultNumListView" & dbkey) = defaultListView
		else
			defaultListView = ""
		end if
		if defaultListView <> "" then
			Session("UserNumListView" & dbkey ) = defaultListView
		else
			Session("UserNumListView" & dbkey ) = "5"
		end if
	else
		Session("UserNumListView" & dbkey ) = currentNumDisplayPrefs
	end if
	
prefs_array = Split(Session("SearchPrefs" & dbkey ), ",", -1)
	for i = 0 to UBound(prefs_array)
		temp_array= split(prefs_array(i), ":", -1)
		
		Session("Prefs" & temp_array(0) & dbkey) =  temp_array(1)
	next
	

if instr( Application("Prefs_FormGroups"), formgroup)> 0 or Application("Prefs_FormGroups")= "" then
	show_prefs = "true"
else
	show_prefs = "false"
end if

'SYAN added on 2/27/2006 to fix CSBR-64278
'stop
currentDrawPref = selectCurrentSettings(dbkey, formgroup, User_ID, "DrawPref" & dbkey)
if currentDrawPref = -1 then
	Session("DrawPref" & dbkey) = "CDAX"
else
	Session("DrawPref" & dbkey) = currentDrawPref
end if
'End of SYAN modification
'response.write Request.Cookies("UserNumListView" & "reg")
%>

<script language="javascript">
bshow71Flags = "<%=bshow71Flags%>"
show_prefs="<%=show_prefs%>"
dbname = "<%=dbkey%>"

var appkey = "<%=Application("appkey")%>"
formgroup="<%=formgroup%>"
theOpener = opener
var lastListNum = ""
var formmode = "<%=request("formmode")%>"
function getButtons(){
Buttonpath = new String
Buttonpath ="<%=buttonpath%>"
	if (show_prefs=="true"){ 
		varButtons = ""
		varButtons = '<a HREF="#" onclick="setValues(true)"><img SRC="' + Buttonpath + 'ok_dialog_btn.gif" name="I1"  alt="Apply settings and close dialog" border = 0></a>'
		//DGB Remove the Apply button.  It causes problems when Apply and Ok are clicked sequentially.
		//varButtons = varButtons + '<a HREF="#" onClick="setValues()"><img SRC="' + Buttonpath + 'apply_dialog_btn.gif" name="I1"  alt="Apply settings and keep dialog box open." border = 0></a>'
		varButtons = varButtons + '<a HREF="javascript:setDefaults();doReload()"><img SRC="' + Buttonpath + 'use_defaults_dialog_btn.gif" name="I1"  alt"Reset default preferences and close dialog." border = 0></a>'
		varButtons = varButtons + '<a HREF="javascript:window.close()"><img SRC="' + Buttonpath + 'cancel_dialog_btn.gif" name="I1" alt="Close dialog without changes." border = 0></a>'
	}
	else
	{	varButtons = ""
		varButtons = '<a HREF="javascript:window.close()"><img SRC="' + Buttonpath + 'cancel_dialog_btn.gif" name="I1" alt="Close dialog without changes." border = 0></a>'
		varButtons = varButtons + "<br><br>"
	}
	document.write (varButtons)
}

function doReload(){
	this.location.reload(true)
}
function setCookie(name, value){
	dbkey = "<%=dbkey%>"
	//formgroup = "<%=formgroup%>"
	if (value == "false"){
		value = "0"}
	if(value == "true"){
		value = "1"}
	var nextyear = new Date()
	nextyear.setFullYear(nextyear.getFullYear() +1);
	document.cookie = name + dbkey + "="  + escape(value) + "; expires=" + nextyear.toGMTString() + "; path=/" + appkey
	return true

}

function getCookie(name){
	dbkey = "<%=dbkey%>"
	//formgroup = "<%=formgroup%>"
	var cname = name + dbkey  + "=";
	
	var dc= document.cookie;
	
	if(dc.length > 0){
		begin = dc.indexOf(cname);
			if(begin != -1){
				begin += cname.length;
				end = dc.indexOf(";", begin);
					if(end == -1) end = dc.length;
						 var temp = unescape(dc.substring(begin, end));
						 if (temp == "0"){
							temp = "false"}
						 if (temp =="1"){
							temp = "true"}
						 theResult = temp
						 
						  return theResult
						
						
			}
		}
	return null;	
}



function getCheckboxValS1(name, defaultvalue){
	if (show_prefs=="true"){
		var cval = new String
		cval = "<%=Session("PrefsS1" & dbkey)%>"
		if (cval == "true"){
			cval = true}
		else if(cval == "false"){
			cval = false
		}
		else{
			cval = defaultvalue}
		
		theName = eval("document.prefs.S1")
		theName.checked = cval	
	}
}
function getCheckboxValS2(name, defaultvalue){
	if (show_prefs=="true"){
		var cval = new String
		cval = "<%=Session("PrefsS2" & dbkey)%>"
		
		if (cval == "true"){
			cval = true}
		else if(cval == "false"){
			cval = false
		}
		else{
			cval = defaultvalue}
		
		theName = eval("document.prefs.S2")
		theName.checked = cval	
	}
}
function getCheckboxValS3(name, defaultvalue){
	if (show_prefs=="true"){
		var cval = new String
		cval = "<%=Session("PrefsS3" & dbkey)%>"
		if (cval == "true"){
			cval = true}
		else if(cval == "false"){
			cval = false
		}
		else{
			cval = defaultvalue}
		
		theName = eval("document.prefs.S3")
		theName.checked = cval	
	}
}
function getCheckboxValS4(name, defaultvalue){
	if (show_prefs=="true"){
		var cval = new String
		cval = "<%=Session("PrefsS4" & dbkey)%>"
		if (cval == "true"){
			cval = true}
		else if(cval == "false"){
			cval = false
		}
		else{
			cval = defaultvalue}
		
		theName = eval("document.prefs.S4")
		theName.checked = cval	
	}
}
function getCheckboxValS5(name, defaultvalue){
	if (show_prefs=="true"){
		var cval = new String
		cval = "<%=Session("PrefsS5" & dbkey)%>"
		if (cval == "true"){
			cval = true}
		else if(cval == "false"){
			cval = false
		}
		else{
			cval = defaultvalue}
		
		theName = eval("document.prefs.S5")
		theName.checked = cval	
	}
}
function getCheckboxValS7(name, defaultvalue){
	if (show_prefs=="true"){
		var cval = new String
		cval = "<%=Session("PrefsS7" & dbkey)%>"
		if (cval == "true"){
			cval = true}
		else if(cval == "false"){
			cval = false
		}
		else{
			cval = defaultvalue}
		
		theName = eval("document.prefs.S7")
		theName.checked = cval	
	}
}
function getCheckboxValS8(name, defaultvalue){
	if (show_prefs=="true"){
		var cval = new String
		cval = "<%=Session("PrefsS8" & dbkey)%>"
		if (cval == "true"){
			cval = true}
		else if(cval == "false"){
			cval = false
		}
		else{
			cval = defaultvalue}
		
		theName = eval("document.prefs.S8")
		theName.checked = cval	
	}
}
function getCheckboxValS9(name, defaultvalue){
	if (show_prefs=="true"){
		var cval = new String
		cval = "<%=Session("PrefsS9" & dbkey)%>"
		if (cval == "true"){
			cval = true}
		else if(cval == "false"){
			cval = false
		}
		else{
			cval = defaultvalue}
		
		theName = eval("document.prefs.S9")
		theName.checked = cval	
	}
}
function getCheckboxValS10(name, defaultvalue){
	if (show_prefs=="true"){
		var cval = new String
		cval = "<%=Session("PrefsS10" & dbkey)%>"
		if (cval == "true"){
			cval = true}
		else if(cval == "false"){
			cval = false
		}
		else{
			cval = defaultvalue}
		
		theName = eval("document.prefs.S10")
		theName.checked = cval	
	}
}
function getCheckboxValS11(name, defaultvalue){
	if (show_prefs=="true"){
		var cval = new String
		cval = "<%=Session("PrefsS11" & dbkey)%>"
		if (cval == "true"){
			cval = true}
		else if(cval == "false"){
			cval = false
		}
		else{
			cval = defaultvalue}
		
		theName = eval("document.prefs.S11")
		theName.checked = cval	
	}
}
function getCheckboxValS12(name, defaultvalue){
	if (show_prefs=="true"){
		var cval = new String
		cval = "<%=Session("PrefsS12" & dbkey)%>"
		if (cval == "true"){
			cval = true}
		else if(cval == "false"){
			cval = false
		}
		else{
			cval = defaultvalue}
		
		theName = eval("document.prefs.S12")
		theName.checked = cval	
	}
}
function getCheckboxValS13(name, defaultvalue){
	if (show_prefs=="true"){
		var cval = new String
		cval = "<%=Session("PrefsS13" & dbkey)%>"
		if (cval == "true"){
			cval = true}
		else if(cval == "false"){
			cval = false
		}
		else{
			cval = defaultvalue}
		
		theName = eval("document.prefs.S13")
		theName.checked = cval	
	}
}
<% if isTautomerSupport then %>
function getCheckboxValS14(name, defaultvalue){
	if (show_prefs=="true"){
		var cval = new String
		cval = "<%=Session("PrefsS14" & dbkey)%>"
		if (cval == "true"){
			cval = true}
		else if(cval == "false"){
			cval = false
		}
		else{
			cval = defaultvalue}
		
		theName = eval("document.prefs.S14")
		theName.checked = cval	
	}
}
<% end if%>
<% if isLooseDelocalizationSupport then %>
function getCheckboxValS15(name, defaultvalue){
	if (show_prefs=="true"){
		var cval = new String
		cval = "<%=Session("PrefsS15" & dbkey)%>"
		if (cval == "true"){
			cval = true}
		else if(cval == "false"){
			cval = false
		}
		else{
			cval = defaultvalue}
		
		theName = eval("document.prefs.S15")
		theName.checked = cval	
	}
}
<% end if%>
<% if isImplicitHSupport then %>
function getCheckboxValS16(name, defaultvalue){
	if (show_prefs=="true"){
		var cval = new String
		cval = "<%=Session("PrefsS16" & dbkey)%>"
		if (cval == "true"){
			cval = true}
		else if(cval == "false"){
			cval = false
		}
		else{
			cval = defaultvalue}
		theName = eval("document.prefs.S16")
		theName.checked = cval	
	}
}
<% end if%>

function getResultsDisplayVal(defaultvalue){
	if (show_prefs=="true"){
		var cval = new String
		cval = "<%=Session("UserResultsPrefs" & dbkey)%>"
		if ((cval == "")||(cval==null)){
		cval = defaultvalue
		
		}
		for(i=0;i<document.prefs.UserResultsPrefs.length;i++){
			if (document.prefs.UserResultsPrefs[i].value == cval){
				document.prefs.UserResultsPrefs[i].checked = true
			}
		}
	}
}

//SYAN added on 2/6/2006 to enable ISIS draw editing
function getDrawPref(defaultvalue){
	if (show_prefs == "true"){
		var cval = new String
		cval = "<%=Session("DrawPref" & dbkey)%>"
		if ((cval == "")||(cval==null)){
			cval = defaultvalue
		}
		for(i=0; i<document.prefs.DrawPref.length; i++){
			if (document.prefs.DrawPref[i].value == cval){
				document.prefs.DrawPref[i].checked = true
			}
		}
	}
}
//End of SYAN modification
function setResultsDisplayVal(){
	var theReturn
	if (show_prefs=="true"){
		var cval = new String
		if(document.prefs.UserResultsPrefs[0].checked){
			theReturn =  "edit"
		}
		else{
			theReturn= "list"
		}
	}
	return theReturn
}
//SYAN added on 2/6/2006 to enable ISIS editing
function setDrawPref(){
	var theReturn
	if (show_prefs=="true"){
		var cval = new String
		if(document.prefs.DrawPref[0].checked){
			theReturn =  "CDAX"
		}
		else{
			theReturn= "ISIS"
		}
	}
	return theReturn
}
//End of SYAN modification
function getNumListView(defaultvalue){
	if (show_prefs=="true"){
		var cval = new String
		cval = "<%=Session("UserNumListView" & dbkey)%>"
		lastListNum = cval
	
		if((cval == "") || (cval == null) ||(cval == "undefined")){
			//document.prefs.NumListViewButton.checked = false
			document.prefs.NumListViewText.value = defaultvalue	
			document.prefs.NumListViewText_Orig.value = defaultvalue	
		}
		else {
			if (cval == "all_records"){
				//document.prefs.NumListViewButton.checked = true
				document.prefs.NumListViewText.value = "99"
				document.prefs.NumListViewText.focus()
			} 
			else{
				//document.prefs.NumListViewButton.checked = false
				document.prefs.NumListViewText.value = cval 
				document.prefs.NumListViewText_Orig.value = cval 
				document.prefs.NumListViewText.focus()
			}
		}
	}
}
function getTextArea( name, defaultvalue){
	if (show_prefs=="true"){

		var cval =  "<%=Session("PrefsS6" & dbkey)%>"
		if (cval == null){
			cval = defaultvalue;
		}
		document.prefs.S6.value = cval
	}
}



function setDefaults(){
	MainWindow = opener
	theWindow =MainWindow.UserInfoWindow
	var thePrefs = window.document.prefs
	var search_prefs_list
	var display_prefs
	var num_display_prefs
	var num_display_orig
	var bListViewChange
	if (show_prefs=="true"){
		
		display_prefs =  "list"
		num_display_prefs =  "<%=Session("fgDefaultNumListView" & dbkey)%>"
		num_display_orig = thePrefs.NumListViewText_Orig.value 
		if ((num_display_prefs != num_display_orig) && (formmode.toLowerCase() == "list")) {
			bListViewChange = "true"
		}else{
			bListViewChange = "false"
		}
		//MATCH_TET_STEREO =  PrefsS1
		//MATCH_TET_DB =  PrefsS2
		//HIT_ANY_CHARGE_CARBON = PrefsS3
		//RXN_HIT_RXN_CENTER =  PrefsS4
		//HIT_ANY_CHARGE_HETERO =  PrefsS5
		//SIM_SEARCH_THRESHOLD = PrefsS6
		//FULL_STRUCTURE_SIMILARITY = PrefsS7
		//EXTRA_FRAGS_OK = PrefsS8
		//EXTRA_FRAGS_OK_IF_RXN = PrefsS9
		//FRAGS_CAN_OVERLAP = PrefsS10
		//IDENTITY = PrefsS11
		//RELATIVE_TET_STEREO = PrefsS12
		//ABSOLUTE_HITS_REL = PrefsS13
		//TAUTOMER = PrefS14
		
		search_prefs_list = "S1:1,"
		search_prefs_list = search_prefs_list + "S2:1,"
		search_prefs_list = search_prefs_list + "S3:1,"
		search_prefs_list = search_prefs_list + "S4:1,"
		search_prefs_list = search_prefs_list + "S5:1,"
		search_prefs_list = search_prefs_list + "S6:90,"
		search_prefs_list = search_prefs_list + "S7:1,"
		search_prefs_list = search_prefs_list + "S8:0,"
		search_prefs_list = search_prefs_list + "S9:1,"
		search_prefs_list = search_prefs_list + "S10:1,"
		if (bshow71Flags == "true"){
			search_prefs_list = search_prefs_list + "S11:0,"
			search_prefs_list = search_prefs_list + "S12:0,"
			search_prefs_list = search_prefs_list + "S13:0,"
			search_prefs_list = search_prefs_list + "S14:0,"	
			search_prefs_list = search_prefs_list + "S15:0,"
			search_prefs_list = search_prefs_list + "S16:0"	
		}
		else{
			search_prefs_list = search_prefs_list + "S11:0,"
			search_prefs_list = search_prefs_list + "S12:0,"
			search_prefs_list = search_prefs_list + "S13:0,"
			search_prefs_list = search_prefs_list + "S14:0,"
			search_prefs_list = search_prefs_list + "S15:0,"
			search_prefs_list = search_prefs_list + "S16:0"
		}
			
	//theWindow.setUserInfoCookie("UserAction" + MainWindow.dbname + MainWindow.formgroup,"SetUserPrefs")
	var UserInfoActionVal = "SetUserPrefs";
	MainWindow.UserInfoWindow.location.replace(MainWindow.app_Path + "/user_info.asp?dbname=" + dbname + "&formgroup=" + formgroup  + "&SearchPrefs=" + search_prefs_list+ "&UserResultsPrefs=" + display_prefs + "&UserNumListView=" + num_display_prefs + "&ListViewChanged=" + bListViewChange  + "&UserInfoActionVal=" + UserInfoActionVal)
	

	
	}
	
}
function setValues(bclose){
	MainWindow = opener
	theWindow =MainWindow.UserInfoWindow
	var thePrefs = window.document.prefs
	var search_prefs_list
	var display_prefs
	var num_display_prefs
	var num_display_orig
	var bListViewChange
	//SYAN added on 2/6/2006 to enable ISIS editing
	var draw_editing_pref
	//End of SYAN modification
	
	if (!checkNumVal()) return false;
	if (!checkSimVal()) return false;
	if (show_prefs=="true"){
		
		display_prefs =  setResultsDisplayVal()
		num_display_prefs = thePrefs.NumListViewText.value 
		num_display_orig = thePrefs.NumListViewText_Orig.value 
		
		//SYAN added on 2/6/2006 to enable ISIS editing
	<%if Application("SHOW_ISIS_PREF") = "1" then%>
		draw_editing_pref = setDrawPref()
	<%End if%>
		//End of SYAN modification
		//DGB Change View when either formmode or display num changes
		if (((num_display_prefs != num_display_orig) || (formmode.toLowerCase() != display_prefs))&& (formmode.toLowerCase() != "search")) {
			bListViewChange = "true"
		}else{
			bListViewChange = "false"
		}
		
		//MATCH_TET_STEREO =  PrefsS1
		//MATCH_TET_DB =  PrefsS2
		//HIT_ANY_CHARGE_CARBON = PrefsS3
		//RXN_HIT_RXN_CENTER =  PrefsS4
		//HIT_ANY_CHARGE_HETERO =  PrefsS5
		//SIM_SEARCH_THRESHOLD = PrefsS6
		//FULL_STRUCTURE_SIMILARITY = PrefsS7
		//EXTRA_FRAGS_OK = PrefsS8
		//EXTRA_FRAGS_OK_IF_RXN = PrefsS9
		//FRAGS_CAN_OVERLAP = PrefsS10
		//IDENTITY = PrefsS11
		//RELATIVE_TET_STEREO = PrefsS12
		//ABSOLUTE_HITS_REL = PrefsS13
		//TAUTOMER = PrefsS14
		
		search_prefs_list = "S1:" + thePrefs.S1.checked + ","
		search_prefs_list = search_prefs_list + "S2:" + thePrefs.S2.checked + ","
		search_prefs_list = search_prefs_list + "S3:" + thePrefs.S3.checked + ","
		search_prefs_list = search_prefs_list + "S4:" + thePrefs.S4.checked + ","
		search_prefs_list = search_prefs_list + "S5:" + thePrefs.S5.checked + ","
		search_prefs_list = search_prefs_list + "S6:" + thePrefs.S6.value + ","
		search_prefs_list = search_prefs_list + "S7:" + thePrefs.S7.checked + ","
		search_prefs_list = search_prefs_list + "S8:" + thePrefs.S8.checked + ","
		search_prefs_list = search_prefs_list + "S9:" + thePrefs.S9.checked + ","
		search_prefs_list = search_prefs_list + "S10:" + thePrefs.S10.checked + ","
		if (bshow71Flags == "true"){
			// identity is explicitly set to false. Will be overrriden by identity 
			//search drop down and by no_gui or dup_check settings
			search_prefs_list = search_prefs_list + "S11:false,"
			search_prefs_list = search_prefs_list + "S12:" + thePrefs.S12.checked + ","
			search_prefs_list = search_prefs_list + "S13:" + thePrefs.S13.checked + ","
<% if isTautomerSupport then %>
			search_prefs_list = search_prefs_list + "S14:" + thePrefs.S14.checked + ","
<%end if%>
<% if isLooseDelocalizationSupport then %>
			search_prefs_list = search_prefs_list + "S15:" + thePrefs.S15.checked + ","
<%end if%>
<% if isImplicitHSupport then %>
			search_prefs_list = search_prefs_list + "S16:" + thePrefs.S16.checked 
<%end if%>
		}else{
			search_prefs_list = search_prefs_list + "S11:0,"
			search_prefs_list = search_prefs_list + "S12:0,"
			search_prefs_list = search_prefs_list + "S13:0,"
<% if isTautomerSupport then %>			
			search_prefs_list = search_prefs_list + "S14:0,"
<% end if%>
<% if isLooseDelocalizationSupport then %>			
			search_prefs_list = search_prefs_list + "S15:0,"
<% end if%>
<% if isImplictHSupport then %>			
			search_prefs_list = search_prefs_list + "S16:0"
<% end if%>
		}	 	
	//theWindow.setUserInfoCookie("UserAction" + MainWindow.dbname + MainWindow.formgroup,"SetUserPrefs")
	var UserInfoActionVal = "SetUserPrefs";
	//SYAN modified on 2/6/2006 to enable ISIS editing
	//MainWindow.UserInfoWindow.location.replace(MainWindow.app_Path + "/user_info.asp?dbname=" + dbname + "&formgroup=" + formgroup  + "&SearchPrefs=" + search_prefs_list+ "&UserResultsPrefs=" + display_prefs + "&UserNumListView=" + num_display_prefs + "&ListViewChanged=" + bListViewChange)
	MainWindow.UserInfoWindow.location.replace(MainWindow.app_Path + "/user_info.asp?dbname=" + dbname + "&formgroup=" + formgroup  + "&SearchPrefs=" + search_prefs_list+ "&UserResultsPrefs=" + display_prefs + "&DrawPref=" + draw_editing_pref + "&UserNumListView=" + num_display_prefs + "&ListViewChanged=" + bListViewChange + "&UserInfoActionVal=" + UserInfoActionVal)
	MainWindow.location.reload(true);
	
	//End of SYAN modification

	
	}
	if (bclose) window.close();
}

function setButtonValues(){
	if (show_prefs=="true"){
		defaultNum = "<%=defaultNum%>"
		getNumListView(defaultNum)
		getResultsDisplayVal("list")
		
		//SYAN added on 2/6/2006 to enable ISIS draw editing
	<%if Application("SHOW_ISIS_PREF") = "1" then%>
		getDrawPref("CDAX")
	<%End if%>
		//End of SYAN modification
		//MATCH_TET_STEREO =  PrefsS1
		getCheckboxValS1('S1', true)
		//MATCH_TET_DB =  PrefsS2
		getCheckboxValS2('S2', true)
		//HIT_ANY_CHARGE_CARBON = PrefsS3
		getCheckboxValS3('S3', true)
		//RXN_HIT_RXN_CENTER =  PrefsS4
		getCheckboxValS4('S4', true)
		//HIT_ANY_CHARGE_HETERO =  PrefsS5
		getCheckboxValS5('S5', true)
		//SIM_SEARCH_THRESHOLD = PrefsS6
		getTextArea('S6', '90')
		//FULL_STRUCTURE_SIMILARITY = PrefsS7
		getCheckboxValS7('S7', false)
		//EXTRA_FRAGS_OK = PrefsS8
		getCheckboxValS8('S8', false)
		//EXTRA_FRAGS_OK_IF_RXN = PrefsS9
		getCheckboxValS9('S9', true)
		//FRAGS_CAN_OVERLAP = PrefsS10
		getCheckboxValS10('S10', true)
		if (bshow71Flags == "true"){
			//IDENTITY = PrefsS11
			// deprecated identity preference
			//getCheckboxValS11('S11', false)
			//RELATIVE_TET_STEREO = PrefsS12
			getCheckboxValS12('S12', false)
			//ABSOLUTE_HITS_REL = PrefsS13
			getCheckboxValS13('S13', false)
			//TAUTOMER = PrefsS14
<% if isTautomerSupport then %>
			getCheckboxValS14('S14', false)
<% end if%>
		//LOOSEDELOCALIZATION
<% if isLooseDelocalizationSupport then %>
			getCheckboxValS15('S15', false)
<% end if%>
		//INGONREIMPLICITH
<% if isImplicitHSupport then %>
			getCheckboxValS16('S16', false)
<% end if%>						
		}
	}

}

function setNumList(){
	if (show_prefs=="true"){
		theVal = document.prefs.NumListViewText.value
		setCookie("UserNumListView", theVal) 
			
	}
}

function checkNumVal(){
	if (show_prefs=="true"){

		theVal = document.prefs.NumListViewText.value
		correctNum = isPosInteger(theVal)
		if (!correctNum){
			alert("Please enter a positive integer between 1 and 99.")
			getNumListView("<%=defaultNum%>")
			document.prefs.NumListViewText.focus()
			return false;
		}
		else{
			if((theVal > 99)||(theVal < 1)){
				alert("Please enter a positive integer between 1 and 99.")
				
				getNumListView("<%=defaultNum%>")
				document.prefs.NumListViewText.focus()
				return false;
			}
			
		}
	}
	return true;
}
function checkNumBtnVal(){
	if (show_prefs=="true"){

		defaultNum = "<%=defaultNum%>"
		document.prefs.NumListViewText.value = 	defaultNum
		document.prefs.NumListViewText.focus()
	
	}
}
function checkSimVal(){
	if (show_prefs=="true"){

	theVal = document.prefs.S6.value
	correctNum = isPosInteger(theVal)
	correctRange = inRange(theVal)
	
		if ((!correctNum) || (!correctRange)){
			alert("Please enter a positive value between 20 and 100.")	
			getTextArea('S6', '90')
			document.prefs.S6.focus()
			return false;
		}
	}
	return true;
}

function inRange(inputVal){
		if (show_prefs=="true"){

			if (inputVal.length > 0){
				if ((inputVal < 20) || (inputVal > 100)){
			
					return false
				}
				return true
			}
		return false	
		}

}
function isPosInteger(inputVal){
	if (show_prefs=="true"){
		if (inputVal.length > 0){
			var inputStr = inputVal.toString()	
			for(var i=0; i<inputStr.length; i++){
				var oneChar = inputStr.charAt(i)
				if(i == 0 && oneChar == "-"){
					return false
				}				
				if(oneChar < "0" || oneChar > "9") {
					return false
				}
			}	
		return true	
		}
	return false	
	}
	

}
</script>


<title>Preferences</title>
</head>

<body  <%=Application("BODY_BACKGROUND")%> onLoad="setButtonValues();">
<script language="javascript">
getButtons();
</script>
<%if show_prefs = "true" then%>
<br/><br/>
<form name="prefs" action method="Post">
  <table border="1" width="379" bordercolor="#0A1492">
    <tr>
      <td><table border="0" width="100%">
        <tr>
          <td width="100%"><table border="1" width="366">
            <tr>
              <td width="340" colspan="2" bgcolor="#0A1492"><font color="#FFFFFF" face="verdana" size="2"><strong>Display
              Preferences</strong></font></td>
            </tr>
           <% If CBool(Application ("ENABLE_DETAIL_VIEW")) = true or NOT Application ("ENABLE_DETAIL_VIEW")<> ""then %>
            <tr>
              <td width="205"><font face="verdana" size="1">Results Display</font></td>
              <td width="145"><input type="radio" value="edit" name="UserResultsPrefs"><font face="verdana" size="1">Form<input type="radio" value="list"
              name="UserResultsPrefs">List</font></td>
            </tr>
            <%else%>
            <input type  = "hidden" name = "UserResultsPrefs" value = "list">
            <%end if%>
            <tr>
              <td width="205"><font face="verdana" size="1">Number Displayed in List View<br>
                (Maximum of 99)</font></td>
              <td width="145" valign="middle"><input type="text" value="5" name="NumListViewText"
              onChange="checkNumVal()" size="3"><font face="verdana" size="1">Records&nbsp;</font></td>
			<input type  = "hidden" name = "NumListViewText_Orig" value = "">
            </tr>
            <!--SYAN added on 2/6/2006 to add ISIS Draw Editing Preference-->  
            <%if Application("SHOW_ISIS_PREF") = "1" then%>    
            <tr>
				<td width="340" colspan="2" bgcolor="#0A1492"><font color="#FFFFFF" face="verdana" size="2">
					<strong>Draw Editing Preferences</strong></font>
				</td>
            </tr>
            
			<tr><td><font face="verdana" size="1">Edit Structure With</font></td>
				<td width="145"><input type="radio" value="CDAX" name="DrawPref"><font face="verdana" size="1">ChemDraw ActiveX
								<input type="radio" value="ISIS" name="DrawPref">ISIS</font>
				</td>
			</tr>
			
			<%end if%>
			
			<!--End of SYAN modification-->
          </table>
          </td>
        </tr>
      </table>
      <table border="0" width="100%">
        <tr>
          <td width="100%"><table border="1" width="100%">
            <tr>
              <td width="66%" colspan="2" bgcolor="#0A1492"><font color="#FFFFFF" face="Verdana" size="2"><strong>Search
              Preferences</strong></font></td>
            </tr>
            
            <tr>
              <td width="40%"><font face="verdana" size="1">Hit any charge on heteroatom</font></td>
              <td width="26%"><input type="checkbox" name="S5" value=" "></td>
            </tr>
            <tr>
              <td width="40%"><font face="verdana" size="1">Reaction query must hit reaction center</font></td>
              <td width="26%"><input type="checkbox" name="S4" value=" "></td>
            </tr>
            <tr>
              <td width="40%"><font face="verdana" size="1">Hit any charge on carbon</font></td>
              <td width="26%"><input type="checkbox" name="S3" value=" "></td>
            </tr>
             <tr>
              <td width="40%"><font face="verdana" size="1">Permit Extraneous Fragments in Full Structure(exact) Searches </font></td>
              <td width="26%"><input type="checkbox" name="S8" value=" " ID=></td>
            </tr>
             <tr>
              <td width="40%"><font face="verdana" size="1">Permit Extraneous Fragments in Reaction Full Structure(exact) Searches </font></td>
              <td width="26%"><input type="checkbox" name="S9" value=" "></td>
            </tr>
             <tr>
              <td width="40%"><font face="verdana" size="1">Query Fragments Can Overlap in Target </font></td>
              <td width="26%"><input type="checkbox" name="S10" value=" "></td>
            </tr>
            <%if isTautomerSupport then%>
             <tr>
              <td width="40%"><font face="verdana" size="1">Tautomeric</font></td>
              <td width="26%"><input type="checkbox" name="S14" value=" " ></td>
            </tr>
            <%end if%>
            <%if isLooseDelocalizationSupport then%>
             <tr>
              <td width="40%"><font face="verdana" size="1">Loose Delocalization</font></td>
              <td width="26%"><input type="checkbox" name="S15" value=" " ></td>
            </tr>
            <%end if%>
            <%if isImplicitHSupport then%>
             <tr>
              <td width="40%"><font face="verdana" size="1">Ignore Implicit Hydrogens</font></td>
              <td width="26%"><input type="checkbox" name="S16" value=" " ></td>
            </tr>
            <%end if%>
            <tr>
              <td width="40%"><font face="verdana" size="1">Similarity search (20-100%)</font></td>
              <td width="26%"><font face="verdana" size="1"><input type="text" value="90" name="S6" size="4" onChange="checkSimVal()">%</font></td>
            </tr>
            <tr>
              <td width="40%"><font face="verdana" size="1">Full Structure Similarity </font></td>
              <td width="26%"><input type="checkbox" name="S7" value=" "></td>
            </tr>
            <%
            'EXTRA_FRAGS_OK = PrefsS8
    'EXTRA_FRAGS_OK_IF_RXN = PrefsS9
    'HIT_ANY_CHARGE_CARBON = PrefsS3
    'HIT_ANY_CHARGE_HETERO = PrefsS5
    'FRAGS_CAN_OVERLAP = PrefsS10
    'MATCH_TET_DB = PrefsS2
    'MATCH_TET_STEREO = PrefsS1
    'RXN_HIT_RXN_CENTER = PrefsS4
    'ABSOLUTE_HITS_REL = PrefsS13
    'RELATIVE_TET_STEREO = PrefsS12
    'IDENTITY = PrefsS11
    'TAUTOMER = PrefsS14
    'LOOSEDELOCALIZATION = PrefsS15
    'IGNOREIMPLICITH= PrefsS16
    %>
             <tr><td colspan="2"><font face="verdana" size="1"><b>Stereochemistry Options</b></font></td></tr>
             <tr>
              <td width="40%"><font face="verdana" size="1">Match tetrahedral stereo</font></td>
              <td width="26%"><input type="checkbox" name="S1" value=" "></td>
            </tr>
            <tr>
              <td width="40%"><font face="verdana" size="1">Match double bond stereo</font></td>
              <td width="26%"><input type="checkbox" name="S2" value=" "></td>
            </tr>
            
           <%if bShow71Flags = "true" then%>
           
            <tr>
              <td width="40%"><font face="verdana" size="1">Thick Bonds Represent Relative Stereochemistry </font></td>
              <td width="26%"><input type="checkbox" name="S12" value=" "></td>
            </tr>
            <!--<tr>
              <td width="40%"><font face="verdana" size="1"><small>Absolute Relative Stereochemistry </small></font></td>
              <td width="26%"><input type="checkbox" name="S13" value=" " ></td>
            </tr>-->
            <input type = "hidden" name = "S13" value = "0">
            <%end if%>
          </table>
          </td>
        </tr>
      </table>
      </td>
    </tr>
  </table>
</form>
<%else
Response.Write "There are no preference settings for this feature"
end if%>
</body>
</html>
