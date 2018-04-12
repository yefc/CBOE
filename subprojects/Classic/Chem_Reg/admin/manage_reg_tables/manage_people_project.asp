<%@ LANGUAGE=VBScript %>
<%	Response.expires=0
'Copyright 1999-2003 CambridgeSoft Corporation. All rights reserved
'DO NOT EDIT THIS FILE

if not dbkey <> "" then dbkey=request("dbname")
formgroup= request("formgroup")
if Not Session("UserValidated" & dbkey) = 1 then  response.redirect "/" & Application("Appkey") & "/logged_out.asp"%>

<html>
<head>
<!--#INCLUDE VIRTUAL = "/cfserverasp/source/cows_func_js.asp"-->
<!--#INCLUDE FILE = "../../cs_security/admin_utils_js.js"-->
<!--#INCLUDE FILE = "../../cs_security/admin_utils_vbs.asp"-->
<!--#INCLUDE FILE = "../../source/secure_nav.asp"-->
<!--#INCLUDE FILE = "../../source/app_vbs.asp"-->
<!--#INCLUDE FILE = "../../source/app_js.js"-->
<%
formmode = UCase(request("formmode"))
%>


<script language="javascript">
	formmode = "<%=formmode%>"
	var w_current_list =  ""
	var orig_current_list =  w_current_list
	var w_avail_list = ""
	var unique_id = ""

</script>

<title>Manage People_Project Table</title>
</head>

<body <%=Application("BODY_BACKGROUND")%> onload="fill_project_user_lists()">
<!--#INCLUDE VIRTUAL = "/cfserverasp/source/header_vbs.asp"-->

<%
Session("fEmptyRecordset" & dbkey & formgroup) = False

	on error resume next
	if formmode = "ADD_RECORD" then
		bAdd = true
		bUpdate = false
		bEditWG = true
		bEditUserID = true
	else
		bAdd = false
		bUpdate = true
	end if
	
	uniqueid = request("unique_id")
	commit_type = "full_commit_ns"
	table_name = request("table_name")
	
	if Not table_name <> "" then
		Response.Write "no_table_name"
		Response.End
	end if
	
		'rebuild rs with full regdb access so no projects are hidden form the admin
		storeSessionUser = Session("UserName" & dbkey)
		storeSessionPWD = Session("UserID" & dbkey)
		Session("UserName" & dbkey) = Application("REG_USERNAME")
		Session("UserID" & dbkey) =  Application("REG_PWD")
		Set DataConn = GetNewConnection(dbkey, formgroup, "base_connection")
		Session("UserName" & dbkey) = storeSessionUser
		Session("UserID" & dbkey) = storeSessionPWD
	

	if DataConn.State=0 then ' assume user has been logged out
		'DoLoggedOutMsg()
	end if
	if bUpdate = true then
		sql = "Select * from projects where project_internal_id =" & uniqueid
		Set BaseRS = DataConn.Execute(sql)
	end if
	yes_no_list = ":,0:No,1:Yes"
	

%>
<script language="javascript">
	unique_id = "<%=uniqueid%>"
</script>
<%if bUpdate = true then
	ActiveFlag_TEXT= CBool(BaseRS("Active"))
	ActiveFlag_VAL = BaseRS("Active")
else
	ActiveFlag_TEXT= True
	ActiveFlag_VAL = "1"
end if
ActiveFlag_LIST="1:True,0:False"%>


<table border = 0>
<input type="hidden" name="Return_Location" value="<%=Session("ListLocation" & dbkey & formgroup)%>">
<%if bUpdate = true then%>
<tr><td <%=td_caption_bgcolor%>>ID</td><td <%=td_bgcolor%>><%ShowResult dbkey, formgroup, BaseRS,"Projects.Project_Internal_ID", "raw_no_edit", "0", "30"%></td></tr>
<%end if
if CBOOL(Application("PROJECTS_NAMED_OWNER")) = True  then%>
<tr><td <%=td_caption_bgcolor%>>Owner Name</td><td <%=td_bgcolor%>><%ShowResult dbkey, formgroup, BaseRS,"Projects.Project_Name", "raw", "isValid(this,22)", "30"%></td></tr>
<%else%>
<tr><td <%=td_caption_bgcolor%>>Project Name</td><td <%=td_bgcolor%>><%ShowResult dbkey, formgroup, BaseRS,"Projects.Project_Name", "raw", "isValid(this,22)", "30"%></td></tr>

<%end if%>
<tr><td <%=td_caption_bgcolor%>>Active</td><td <%=td_bgcolor%>><%ShowLookUpList dbkey, formgroup,BaseRS,"Projects.Active",ActiveFlag_LIST,  ActiveFlag_VAL,ActiveFlag_TEXT,0,false,"value","1"%></td></tr>

<%	priv_table = Application("PRIV_TABLE_NAME")

	'SYAN modified on 11/28/2005 to fix CSBR-58112
	all_users_list = ListAllUsersOrdered(dbkey, formgroup, DataConn, priv_table, "person_id", "user_id", "last_name", "first_name", "people.last_name")
	current_project_users_list = GetCurrentProjectUsers(dbkey, formgroup,  DataConn,  "person_id", "user_id", "last_name", "first_name", "people.last_name", uniqueid)
	'End of SYAN modification
%>
<script language="javascript">
	w_current_list =  "<%=current_project_users_list%>"
	orig_current_list =  w_current_list
	w_avail_list = "<%=all_users_list%>"
	user_name = "<%=user_name%>"
</script>

<td width="436" nowrap colspan="2">
<table border="0" width="100%" ID="Table1">
  <tr>
    <td width="20%">Available Users
    </td>
    <td width="20%">
    </td>
    <td width="20%">Current Project Bound Users 
    </td>
  </tr>
  <tr>
    <td width="20%">
    <select name="users" width = "220" size = "6" ID="Select1">
    </select>
        <input type = "hidden" value = "" name = "users_hidden" ID="Hidden1">

    </td>
    <td width="20%">
      <table border="0" width="100%" ID="Table2">
        <tr>
          <td width="100%">
<a
    href="javascript:addCurrentUserList()"><img
    SRC="/<%=Application("AppKey")%>/graphics/add_role_btn.gif" BORDER="0"></a>
          </td>
        </tr>
        <tr>
          <td width="100%">
<a
    href="javascript:removeCurrentUserList()"><img
    SRC="/<%=Application("appkey")%>/graphics/remove_role_btn.gif" BORDER="0"></a>
          </td>
        </tr>
      </table>
    </td>
    <td width="20%"><select name="current_users"  width = "220" size = "6" ID="Select2">
    </select>
    <input type = "hidden" value = "" name = "current_users_hidden" ID="Hidden2">
    <input type = "hidden" value = "<%=users_list%>"name = "original_users_hidden" ID="Hidden3">

    </td>
  </tr>
</table>
</td>

</table>
<%response.write "</form>"%>

 <form name="nav_variables" method="post" Action="<%=Session("CurrentLocation" & dbkey & formgroup)%>" ID="Form1">
<input type = "hidden" name = "RecordRange" Value =  "<%=Session("RecordRange" & dbkey & formgroup)%>" ID="Hidden4">
<input type = "hidden" name = "CurrentRecord" Value =  "<%=Session("RecordRange" & dbkey & formgroup)%>" ID="Hidden5">
<input type = "hidden" name = "AtStart" Value =  "<%=Session("AtStart" & dbkey & formgroup)%>" ID="Hidden6">
<input type = "hidden" name = "AtEnd" Value =  "<%=Session("AtEnd" & dbkey & formgroup)%>" ID="Hidden7">
<input type = "hidden" name = "Base_RSRecordCount" Value =  "<%=Session("Base_RSRecordCount" & dbkey & formgroup)%>" ID="Hidden8">
<input type = "hidden" name = "TotalRecords" Value =  "<%=Session("Base_RSRecordCount" & dbkey & formgroup)%>" ID="Hidden9">
<input type = "hidden" name = "PagingMove" Value =  "<%=Session("PagingMove" & dbkey & formgroup)%>" ID="Hidden10">
<input type = "hidden" name = "CommitType" Value = "<%=commit_type%>" ID="Hidden11">
<input type = "hidden" name = "TableName" Value =  "<%=table_name%>" ID="Hidden12">
<input type = "hidden" name = "UniqueID" Value =  "<%=uniqueid%>" ID="Hidden13">
<input type = "hidden" name = "CurrentIndex" Value =  "<%=currentindex%>" ID="Hidden14">
<input type = "hidden" name = "BaseActualIndex" Value =  "<%=BaseActualIndex%>" ID="Hidden15">

</form>
<script language="javascript">
	<%=Application("nav_bar_window")%>.location.replace("/<%=Application("appkey")%>/navbar.asp?formgroup=manage_reg_tables_form_group&dbname=<%=dbkey%>&formmode=<%=formmode%>")
</script>

</body>
</html>