<%@ LANGUAGE="VBSCRIPT" %>
<%
Response.Expires = 0

if Request.QueryString("ManageTracing")=1 then server.transfer "/cfserverasp/source/Tracing.asp"
%>
<%'Copyright 1999-2003 CambridgeSoft Corporation. All rights reserved
'DO NOT EDIT THIS FILE%>
<!--#INCLUDE VIRTUAL = "/cfserverasp/source/ado.inc"-->
<!--#INCLUDE VIRTUAL = "/cfserverasp/source/server_const_vbs.asp"-->
<!--#INCLUDE VIRTUAL = "/cfserverasp/source/manage_user_settings_vbs.asp"-->
<!--#INCLUDE VIRTUAL = "/cfserverasp/source/marked_hits_vbs.asp"-->
<!--#INCLUDE VIRTUAL = "/cfserverasp/source/user_prefs_vbs.asp"-->
<!--#INCLUDE VIRTUAL = "/cfserverasp/source/hitlist_management_func_vbs.asp"-->
<!--#INCLUDE VIRTUAL = "/cfserverasp/source/manage_queries.asp"-->
<!--#INCLUDE VIRTUAL = "/cfserverasp/source/search_func_vbs.asp"-->
<!--#INCLUDE VIRTUAL = "/cfserverasp/source/cs_security/cs_security_login_utils_vbs.asp"-->

<%'Restamp credential cookies
UserName = Request.Cookies("CS_SEC_UserName")
UserID = Request.Cookies("CS_SEC_UserID")
if Len(UserName) > 0 then ProlongCookie "CS_SEC_UserName", UserName, Application("CookieExpiresMinutes")
if Len(UserID) > 0 then ProlongCookie "CS_SEC_UserID", UserID, Application("CookieExpiresMinutes")
'Create the ASP session tracking cookie
StoreASPSessionID()
%>

<html>
<head>
<script language = "javascript">

var appkey = "<%=Application("appkey")%>"
var theWindow
if (!<%=Application("mainwindow")%>.mainFrame){
	theWindow = <%=Application("mainwindow")%>
}
else{
	theWindow = <%=Application("mainwindow")%>.mainFrame
}

theUserInfoWindow=<%=Application("user_info_window")%>


if (theWindow != null) {
	formmode = theWindow.formmode
}
else {
	formmode = null
}

if (formmode == null){
	formmode = "search"
	dbname = '<%=Request.QueryString("dbname")%>'
	formgroup = '<%=Request.QueryString("formgroup")%>'
	formgroupflag = ""
}
else{
	gs_base_db=theWindow.the_gs_base_db
	gs_search_dbs=theWindow.the_gs_dbs
	dbname=theWindow.dbname
	formgroup=theWindow.formgroup
	formgroupflag=theWindow.formgroupflag
}
doSaveQuery = ""
doreload = ""
var doreload = "<%=request.querystring("do_reload")%>"
if (doreload == "true"){
}

function setUserInfoCookie(name, value){
	document.cookie = name + "="  + escape(value)
	return true
}


</script>
<%
dbkey = Request("dbname")
formgroup = request("formgroup")
hitID = request("hitid")
MarkedHitsActionText = "MarkedHitsAction" & dbkey & formgroup
UserAction = "UserAction" & dbkey & formgroup
action = Request.Cookies("UserAction" & dbkey & formgroup)
DoSetNullAction()
formmode = request("formmode")
Select Case UCase(action)
	
	Case "DOMARKHIT"
		DoMarkHit dbkey, formgroup, hitid
		DoReloadNavbar()
		DoSetNullAction()
		'SYAN added on 11/9/2004 to fix CSBR-46772
		if UCase(dbkey) = "REG" then
			ReloadMainFrame()
		end if
		'End of SYAN modification

	Case "DOMARKALL"
		DoMarkAllHits dbkey, formgroup
		DoSetNullAction()
		ReloadMainFrame()
		ReloadUserFrame()
	Case "DOUNMARKHIT"
		DoUnMarkHit dbkey, formgroup, hitid
		DoReloadNavbar()
		DoSetNullAction()
		'SYAN added on 11/9/2004 to fix CSBR-46772
		if UCase(dbkey) = "REG" then
			ReloadMainFrame()
		end if
		'End of SYAN modification
	Case "DOCLEARMARKED"
		Session("MarkedHitsShown" & dbkey & formgroup) = false
		DoClearMarked dbkey,formgroup
		DoSetNullAction()
		ReloadMainFrame()
		ReloadUserFrame()
	Case "SETUSERPREFS"
		SetSearchPrefs dbkey, formgroup
		UserResultsPrefs dbkey, formgroup
		UserNumListView dbkey, formgroup

		if request("ListViewChanged") = "true" then
			'DGB Need to figure out the list/form page names
			temp_result = GetFormGroupVal(dbkey, formgroup, kResultFormPath)
			if instr(temp_result, ";")>0 then
				result_forms = split(temp_result, ";", -1)
				result_list_view = result_forms(0)
				if Left(result_list_view, 1) = "/" then
				test_array = split(result_list_view, "/", -1)
					if Not (UCase(test_array(1)) = UCase(Application("appkey"))) then
						result_list_view = "/" & Application("appkey")&  result_list_view
					end if
				end if
				result_form_view = result_forms(1)
				if Left(result_form_view, 1) = "/" then
					test_array = split(result_form_view, "/", -1)
					if Not (UCase(test_array(1)) = UCase(Application("appkey"))) then
						result_form_view = "/" & Application("appkey")&  result_form_view
					end if
				end if
			else
				if Left(temp_result, 1) = "/" then
					test_array = split(temp_result, "/", -1)
					if Not (UCase(test_array(1)) = UCase(Application("appkey"))) then
						temp_result = "/" & Application("appkey")&  temp_result
					end if
				end if
				result_list_view = temp_result
				result_form_view = replace(result_list_view, "_result_list.asp", "_form.asp")
			end if
			
			if Request.QueryString("UserResultsPrefs") = "edit" then
				formName = result_form_view
				formPath = Application("AppPathHTTP")& "/" & dbkey & "/" & formName & "?formgroup=" & formgroup & "&dbname=" & dbkey & "&formmode=edit" 
				ShowFormView(formPath)
			else
				formName = result_list_view
				formPath = Application("AppPathHTTP")& "/" & dbkey & "/" & formName & "?formgroup=" & formgroup & "&dbname=" & dbkey & "&formmode=list"  
				ShowListView(formPath)
			end if
		end if
		DoSetNullAction()
End Select

Function DoSetNullAction()
%><script language = "javascript">
	setUserInfoCookie("<%="UserAction" & dbkey & formgroup%>", "")
</script>
<%
End Function

Function ReloadMainFrame()
%><script language = "javascript">
	theWindow.location.replace("<%=Session("CurrentLocation" & dbkey & formgroup)%>")
</script>
<%
End Function

Function ShowListView(formPath)
%><script language = "javascript">
	currentRecord = theWindow.document.forms["nav_variables"].elements["CurrentRecord"].value
	theWindow.location.replace("<%=formPath%>" + "&indexvalue=" + currentRecord)
</script>
<%
End Function

Function ShowFormView(formPath)
%><script language = "javascript">
	theWindow.goFormView("<%=formPath%>", 1)
</script>
<%
End Function

Function ReloadUserFrame()
%><script language = "javascript">
	theUserInfoWindow.location.replace("<%=Application("AppPathHTTP")%>" + "/user_info.asp?dbname=" + dbname + "&formgroup=" + formgroup + "&formmode=" + formmode)
</script>
<%
End Function

Function DoReloadNavbar()
%><script language = "javascript">
	theWindow.reloadNavBar()

</script>
<%
End Function


%>


<script language = "javascript">


function doShowMarkedHits(dbname){
	var formgroup = "<%=formgroup%>"
	var actiontemp = theWindow.action_form_path + '?dataaction=' + 'show_marked' + '&dbname=' + dbname + '&formgroup=' + formgroup 
	document.user_info.action = actiontemp
	document.user_info.target = "main"
	document.user_info.submit()
	}
	
function doShowLastList(dbname){
	var formgroup = "<%=formgroup%>"
	theUserInfoWindow.location.replace("<%=Application("AppPathHTTP")%>" + "/user_info.asp?dbname=" + dbname + "&formgroup=" + formgroup + "&formmode=" + formmode)
	var actiontemp = theWindow.action_form_path + '?dataaction=' + 'show_last_list' + '&dbname=' + dbname + '&formgroup=' + formgroup
	document.user_info.action = actiontemp
	document.user_info.target = "main"
	document.user_info.submit()
	}
function doClearMarkedHits(dbname){
	var formgroup = "<%=formgroup%>"
	setUserInfoCookie("UserAction" + dbname + formgroup,"doClearMarked")
	theUserInfoWindow.location.reload(true)
	}

function getButton(buttonname){
	var formgroup = "<%=formgroup%>"
	var dbkey = "<%=dbkey%>"
	displayname = getUserInfoCookie("DisplayName" + dbkey + formgroup)
	outputval = "Marked hits for" + displayname
	show_markedhelpstr	= "show marked hits"
	var buttonGifPath = "<%=Application("NavButtonGifPath")%>"		
	var buttonImage = buttonGifPath + buttonName + "_btn.gif"	
	//create button
	helpstr = eval(buttonname + "helpstr")
	outputval ='<A HREF = "#" onclick= doSavedQueryWindow("'
	outputval = outputval + 'show'
	outputval = outputval + '")'
	outputval = outputval + ' onMouseOver="status=' 
	outputval = outputval + '&quot;' + helpstr + '&quot;'
	outputval = outputval + '; return true;"><IMG SRC="' + buttonImage + '" BORDER="0"></A>'
	outputval = outputval + '<nobr>'
	document.write (outputval + "<br>")
}

function getQueriesButton(buttonname){
	outputval = ""
	show_querieshelpstr	= "show all saved queries"
	var buttonGifPath = "<%=Application("NavButtonGifPath")%>"	
	var buttonImage = buttonGifPath + buttonname + "_btn.gif"	
	//create button
	helpstr = eval(buttonname + "helpstr")
	outputval ='<A HREF = "#" onclick= doSavedQueryWindow(&quot;'
	outputval = outputval + 'show'
	outputval = outputval + '&quot;)'
	outputval = outputval + ' onMouseOver="status=' 
	outputval = outputval + '&quot;' + helpstr + '&quot;'
	outputval = outputval + '; return true;"><IMG SRC="' + buttonImage + '" BORDER="0"></A>'
	outputval = outputval + '<nobr>'
	document.write (outputval)
}

!theWindow.MarkedHitsbuttonname ? MarkedHitsbuttonname = "show_marked" : MarkedHitsbuttonname = theWindow.MarkedHitsbuttonname;
!theWindow.ShowLastbuttonname ? ShowLastbuttonname = "show_last_list" : ShowLastbuttonname = theWindow.ShowLastbuttonname;
!theWindow.ClearHitsbuttonname ? ClearHitsbuttonname = "clear_marked" : ClearHitsbuttonname = theWindow.ClearHitsbuttonname;


function getMarkedHitsButton(buttonname, db){
	dbname = db
	var formgroup = "<%=formgroup%>"
	outputval = ""
	show_markedhelpstr	= "show all marked hits"
	var buttonGifPath = "<%=Application("NavButtonGifPath")%>"	
	var buttonImage = buttonGifPath + MarkedHitsbuttonname + "_btn.gif"	
	//create button
	var current_hits = "<%=Session("MarkedHits" & dbkey & formgroup)%>"
	var temparray = current_hits.split(",")
	helpstr = eval(buttonname + "helpstr") + '. ' +  temparray.length + ' currently marked.' 
	outputval = outputval + '&nbsp;<font size=-1>' + temparray.length + ' marked</font><br>'
	outputval = outputval + '<A HREF = "#" onclick= doShowMarkedHits(&quot;'
	outputval = outputval + db
	outputval = outputval + '&quot;)'
	outputval = outputval + ' onMouseOver="status=' 
	outputval = outputval + '&quot;' + helpstr + '&quot;'
	outputval = outputval + '; return true;"><IMG SRC="' + buttonImage + '" BORDER="0"></A>'
	outputval = outputval + '<nobr>'
	document.write (outputval)
}

function getShowLastListButton(buttonname, db){
	formmode = "<%=request("formmode")%>"
	
		dbname = db
		outputval = ""
		show_last_listhelpstr	= "show the hit list available prior to showing marked hits."
		var buttonGifPath = "<%=Application("NavButtonGifPath")%>"		
		var buttonImage = buttonGifPath + ShowLastbuttonname + "_btn.gif"	
		//create button
		helpstr = eval(buttonname + "helpstr")
		outputval = '<A HREF = "#" onclick= doShowLastList(&quot;'
		outputval = outputval + db
		outputval = outputval + '&quot;)'
		outputval = outputval + ' onMouseOver="status=' 
		outputval = outputval + '&quot;' + helpstr + '&quot;'
		outputval = outputval + '; return true;"><IMG SRC="' + buttonImage + '" BORDER="0"></A>'
		outputval = outputval + '<nobr>'
		document.write (outputval)
}

function getClearHitsButton(buttonname, db){
	outputval = ""
	clear_markedhelpstr	= "remove all records from marked hit list"
	var buttonGifPath = "<%=Application("NavButtonGifPath")%>"	
	var buttonImage = buttonGifPath + ClearHitsbuttonname + "_btn.gif"	
	//create button
	helpstr = eval(buttonname + "helpstr")
	outputval ='<A HREF = "#" onclick= doClearMarkedHits(&quot;'
	outputval = outputval + db
	outputval = outputval + '&quot;)'
	outputval = outputval + ' onMouseOver="status=' 
	outputval = outputval + '&quot;' + helpstr + '&quot;'
	outputval = outputval + '; return true;"><IMG SRC="' + buttonImage + '" BORDER="0"></A>'
	outputval = outputval + '<nobr>'
	document.write (outputval + "<br>")


}

function getPostMarkedHitsButton(formgroup){
	outputval = ""
	helpstr	= "Post the marked hits"
	var bAllowButton = false
	var supportedFormgroups = "<%=Application("POST_MARKED_SUPPORTED_FORMGROUPS")%>"
	if (supportedFormgroups == ""){
			bAllowButton = true
	}
	else{
		var temp_array = supportedFormgroups.split(",")
		for (i=0;i<temp_array.length;i++){
			if (temp_array[i].toLowerCase() == formgroup.toLowerCase()){
				bAllowButton = true
			}
		}
	}
	 
	if (bAllowButton == true){
		var gifName = "<%=Application("POST_MARKED_HITS_IMAGE")%>";
		var buttonGifPath = "<%=Application("NavButtonGifPath")%>"	
		var buttonImage = buttonGifPath + gifName;
		var sentTo = "<%=Application("POST_MARKED_SEND_TO_PAGE")%>";
		//create button
		if (sentTo.length > 0){  
			outputval ='<A target="_new" HREF = "<%=Application("POST_MARKED_HITS_PAGE")%>" ' 
			outputval = outputval + ' onMouseOver="status=' 
			outputval = outputval + '&quot;' + helpstr + '&quot;'
			outputval = outputval + '; return true;"><IMG SRC="' + buttonImage + '" BORDER="0"></A>'
			outputval = outputval + '<nobr>'
			document.write (outputval + "<br>")
		}
	}
}

</script>
<title>User Information</title>
</head>

<body <%=Application("BODY_BACKGROUND")%>>

<form name ="user_info" action = "" method = "POST">
<input type= "hidden" name = "currentlist" value = "">
</form>
<script language = "javascript">
	var formgroup = "<%=formgroup%>"
	var formmode = "<%=request("formmode")%>"
	var dbkey = "<%=dbkey%>"
	if (formgroupflag == "GLOBAL_SEARCH"){
	thedb = gs_base_db}
	else if (formgroupflag == "REG_COMMIT"){
	thedb = dbname & "reg"}
	else {thedb = dbname}
	var stored_hits = ""
	
	db = dbname
	
		overridebuttons = false
		if (overridebuttons == false){
			stored_hits = "<%=Session("MarkedHits" & dbkey &  formgroup)%>"
			if (stored_hits == -1){
				stored_hits = ""
			}
			
			markedShown ="<%=Session("MarkedHitsShown" & dbkey &  formgroup)%>"
			var numstored = ""
				if ((stored_hits != "")&&(stored_hits != null) ){
					temp = stored_hits.split(",")
					numstored = temp.length
					if(numstored > 0){
						//document.write ("<br>")
						if(formgroupflag=="GLOBAL_SEARCH"){
							if((formmode.toLowerCase() !="search")&&(formmode.toLowerCase() !="refine")){

								//document.write ('<font size = -1><small>' + "<%=Application("DisplayName" & dbkey) %>" + '<br>')
								
								//getMarkedHitsButton("show_marked",db)
								//document.write ("<br>")
								
									if(markedShown.toLowerCase() == "true"){
										getShowLastListButton("show_last_list",db)
									}else{
									//getClearHitsButton("clear_marked",db)
									}
									
							}else{
							<%'Session("MarkedHitsShown" & dbkey & formgroup) = false%>
							
							}
						}
						else{
							//getMarkedHitsButton("show_marked",db)
							document.write ("<br>")
							
						
							if((markedShown.toLowerCase() == "true")&&((formmode.toLowerCase() !="search")&&(formmode.toLowerCase() !="")&&(formmode.toLowerCase() !="refine"))){
								//getShowLastListButton("show_last_list",db)
							}else{
								//getClearHitsButton("clear_marked",db)
								<%'Session("MarkedHitsShown" & dbkey & formgroup) = false%>
								
							}
						}
						
						//getPostMarkedHitsButton(formgroup);	
					}
				}	
		}
		
		//Save Query buttons 
		
		var excludeButtonList = "<%=Application("EXCLUDE_BUTTONS_FROM_USER_INFO")%>"

		if (!excludeButtonList){
			excludeButtonList = ""
		}
		else{	
			excludeButtonList = excludeButtonList.toLowerCase()
		}
		
		function doManageQueries(manage_query_mode, dbname, formgroup){
			fullpath = '/<%=Application("appkey")%>/save_query.asp?manage_query_mode=' + manage_query_mode + '&dbname=' + dbname + '&formgroup=' + formgroup + '&target_window=' + theWindow.name
			var w = ""
			if (w.name == null){
				var w = window.open(fullpath,"manage_queries","width=450,height=300,status=no,resizable=yes");
				w.focus()}
			else{
				w.focus()
			}
		}
		
		var queries
		queries = ""
		if(formmode.toLowerCase() == "search"){
			if (excludeButtonList.indexOf("restore_query") == -1) queries = queries + '<a href="javascript:doManageQueries(&quot;restore_query&quot;,dbname, formgroup)"><img SRC="/<%=Application("AppKey")%>/graphics/restore_query_btn.gif" BORDER="0"></a>'
			if (excludeButtonList.indexOf("manage_queries") == -1) queries = queries + '<a href="javascript:doManageQueries(&quot;manage_queries&quot;,dbname, formgroup)"><img SRC="/<%=Application("AppKey")%>/graphics/manage_queries_btn.gif" BORDER="0"></a>'
		}
		if(formmode.toLowerCase() == "edit"){
			if (excludeButtonList.indexOf("save_query") == -1) queries = queries + '<a href="javascript:doManageQueries(&quot;save_query&quot;,dbname, formgroup)"><img SRC="/<%=Application("AppKey")%>/graphics/save_query_btn.gif" BORDER="0"></a>'
			if (excludeButtonList.indexOf("restore_query") == -1)  queries = queries + '<a href="javascript:doManageQueries(&quot;restore_query&quot;,dbname, formgroup)"><img SRC="/<%=Application("AppKey")%>/graphics/restore_query_btn.gif" BORDER="0"></a>'
			if (excludeButtonList.indexOf("manage_queries") == -1) queries = queries + '<a href="javascript:doManageQueries(&quot;manage_queries&quot;,dbname, formgroup)"><img SRC="/<%=Application("AppKey")%>/graphics/manage_queries_btn.gif" BORDER="0"></a>'

		}
		if(formmode.toLowerCase() == "list"){
			if (excludeButtonList.indexOf("save_query") == -1) queries = queries + '<a href="javascript:doManageQueries(&quot;save_query&quot;,dbname, formgroup)"><img SRC="/<%=Application("AppKey")%>/graphics/save_query_btn.gif" BORDER="0"></a>'
			if (excludeButtonList.indexOf("restore_query") == -1)  queries = queries + '<a href="javascript:doManageQueries(&quot;restore_query&quot;,dbname, formgroup)"><img SRC="/<%=Application("AppKey")%>/graphics/restore_query_btn.gif" BORDER="0"></a>'
			if (excludeButtonList.indexOf("manage_queries") == -1) queries = queries + '<a href="javascript:doManageQueries(&quot;manage_queries&quot;,dbname, formgroup)"><img SRC="/<%=Application("AppKey")%>/graphics/manage_queries_btn.gif" BORDER="0"></a>'
			
		}
		//document.write (queries)


		function doManagehitlists(manage_hitlist_mode, dbname, formgroup){
			fullpath = '/<%=Application("appkey")%>/save_query.asp?manage_hitlist_mode=' + manage_hitlist_mode + '&dbname=' + dbname + '&formgroup=' + formgroup + '&target_window=' + theWindow.name
			var w = ""
			if (w.name == null){
				var w = window.open(fullpath,"manage_hitlists","width=450,height=300,status=no,resizable=yes");
				w.focus()}
			else{
				w.focus()
			}
		}
		
		var hitlists
		hitlists = ""
		if(formmode.toLowerCase() == "search"){
			if (excludeButtonList.indexOf("restore_hitlists") == -1) hitlists = hitlists + '<a href="javascript:doManagehitlists(&quot;restore_hitlist&quot;,dbname, formgroup)"><img SRC="/<%=Application("AppKey")%>/graphics/manage_hitlists_btn.gif" alt="Restore list" BORDER="0"></a>'
			if (excludeButtonList.indexOf("manage_hitlists") == -1) hitlists = hitlists + '<a href="javascript:doManagehitlists(&quot;manage_hitlists&quot;,dbname, formgroup)"><img SRC="/<%=Application("AppKey")%>/graphics/manage_hitlists_btn.gif" alt="Manage lists" BORDER="0"></a>'
		}
		if((formmode.toLowerCase() == "edit")||(formmode.toLowerCase() == "list")){
			if (excludeButtonList.indexOf("save_hitlist") == -1) hitlists = hitlists + '<a href="javascript:doManagehitlists(&quot;save_hitlist&quot;,dbname, formgroup)"><img SRC="/<%=Application("AppKey")%>/graphics/save_hitlist_btn.gif" BORDER="0" alt="Save hit list"></a>'
			if (excludeButtonList.indexOf("restore_hitlists") == -1) hitlists = hitlists + '<a href="javascript:doManagehitlists(&quot;restore_hitlist&quot;,dbname, formgroup)"><img SRC="/<%=Application("AppKey")%>/graphics/manage_hitlists_btn.gif" alt="Restore list" BORDER="0"></a>'
			if (excludeButtonList.indexOf("manage_hitlists") == -1) hitlists = hitlists + '<a href="javascript:doManagehitlists(&quot;manage_hitlists&quot;,dbname, formgroup)"><img SRC="/<%=Application("AppKey")%>/graphics/manage_hitlists_btn.gif" alt="Manage lists" BORDER="0"></a>'

		}
		//document.write (hitlists)
</script>


</body>
</html>
