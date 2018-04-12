<%@ LANGUAGE=VBScript%>
<%Response.expires=0
'Copyright 1998-2001 CambridgeSoft Corporation All Rights Reserved
'DO NOT EDIT THIS FILE
if not dbkey <> "" then dbkey=request("dbname")
if Not Session("UserValidated" & dbkey) = 1 then  response.redirect "/" & Application("Appkey") & "/logged_out.asp"%>


<html>

<head>
<!--#INCLUDE VIRTUAL = "/cfserverasp/source/cows_func_js.asp"-->
<!--#INCLUDE FILE = "../../source/secure_nav.asp"-->

<%

Session( "ListLocation" & dbkey & formgroup ) = Session( "CurrentLocation" & dbkey & formgroup )
table_name = request("table_name")
access_override = Request.QueryString("limit_access")
table_name = Request("table_name")
if table_name <> "" then
Session("table_name") = table_name
else
table_name = Session("table_name")
end if



if not Session("access_override" & table_name) <> "" then
 Session("access_override" & table_name) = Request.QueryString("limit_access")
end if
%>

<%
formmode = UCase(request("formmode"))
%>


<script laungage = "javascript">
var table_name = "<%=table_name%>"
</script>
<title>Manage Security Tables</title>

</head>

<body <%=Application("BODY_BACKGROUND")%>>
<!--#INCLUDE FILE = "../../source/app_vbs.asp"-->
<table border="1" cellpadding="0" cellspacing="0"><TR>

<!--#INCLUDE VIRTUAL = "/cfserverasp/source/header_vbs.asp"-->
<input type = "hidden" name = "table_name" value = "<%=table_name%>">

<%if not UCase(Request.QueryString("limit_access")) = "WORKGROUP" then%>

<script language="javascript">
	table_name = "<%=table_name%>"
	
	if ((table_name.toLowerCase() == "people")&& (Add_People_Table.toLowerCase()=="true")){
		getFormViewLink('new', "/<%=Application("AppKey")%>/cs_security/manage_tables/manage_tables_result_form.asp",0,'add_record', "&table_name=" + "people")
	
	}
	
	if ((table_name.toLowerCase() == "sites")&& (Edit_Sites_Table.toLowerCase()=="true")){
		getFormViewLink('new', "/<%=Application("AppKey")%>/cs_security/manage_tables/manage_tables_result_form.asp",0,'add_record', "&table_name=" + "sites")
		}
	
	</script>
<%end if%>

<%if Not Session( "fEmptyRecordset" & dbkey & formgroup ) = True  then


	Select case UCase(table_name)
		Case "PEOPLE"
			relfields = "ID;2,Oracle User ID;0,Chemist Code;2,First Name;2,Last Name;2,Supervisor/Workgroup;2,Site ID;2,Active;2"

		Case Else
			relfields = GetTableVal(dbkey, table_name, kTableRelFields)
		
	end select
	relfields_array = split(relfields, ",", -1)%>

	<%for i = 0 to UBound(relfields_array)
	temp_array = split(relfields_array(i), ";", -1)
	if instr(temp_array(0), ".")> 0 then
		new_array = split(temp_array(0), ".", -1)
		fieldname = new_array(1)
	else
		fieldname =temp_array(0)
	end if 
	if err.number > 0 then response.write "<strong>" & fieldname & "</strong>" %>
    <td><%="<strong>" & fieldname &  "</strong>"%></td>
   <%next%>
   
   <%Select case UCase(table_name)
		Case "PEOPLE"
			relfields = "People.Person_ID;2,People.User_ID;0,People.User_Code;2,People.First_Name;2,People.Last_Name;2,People.Supervisor_Internal_ID;2,People.Site_ID;2,People.Active;2"
		Case Else
			relfields = GetTableVal(dbkey, table_name, kTableRelFields)
		
	end select
	relfields_array = split(relfields, ",", -1)%>
  </tr>
 

<%end if

%>
<!--#INCLUDE VIRTUAL ="/cfserverasp/source/recordset_vbs.asp"-->

<%'BaseID represents the primary key for the recordset from the base array for the current row
'BaseActualIndex is the actual id for the index the record is at in the array
'BaseRunningIndex if the id based on the number shown in list view
'BastTotalRecords is the recordcount for the array
'BaseRS (below is the recordset that is pulled for each record generated
'on error resume next
	Set DataConn = GetNewConnection(dbkey, formgroup, "base_connection")
	if DataConn.State=0 then ' assume user has been logged out
		DoLoggedOutMsg()
	end if
	uniqueid = BaseID
	commit_type = "full_commit_ns"
	
	baseid_name = GetTableVal(dbkey, table_name, kPrimaryKey)
	
	Select Case UCase(table_Name)
		Case Else
			sql = "Select * from " & table_name & " where " & baseid_name& "= " & BaseID
	End select
	Set BaseRS = DataConn.Execute(sql)

	
%>
	<script language ="javascript">
		function getLink(field_val,force_formmode){
		var  commit_type = "full_commit_ns"
		var uniqueid = "<%=baseid%>"
		getFormViewLink(field_val, "/<%=Application("AppKey")%>/cs_security/manage_tables/manage_tables_result_form.asp", <%=BaseActualIndex%>,force_formmode,uniqueid, "&limit_access=" + "<%=Request.querystring("limit_access")%>" + "&table_name=" + table_name)
	}
</script>

<tr>


<%for i = 0 to UBound(relfields_array)
	value = ""
	link_value = ""
	temp_array = split(relfields_array(i), ";", -1)
	if instr(temp_array(0), ".")> 0 then
		new_array = split(temp_array(0), ".", -1)
		fieldname = new_array(1)
	else
		fieldname =temp_array(0)
	end if 
	if Not (BaseRS.BOF AND BaseRS.EOF)then
			value = BaseRS(fieldname)
		else
			value = ""
	end if
%>
	<td>
	<%
	if i = 0 then
	Select Case UCase(table_name)
		
		Case "PEOPLE"
			if (Session("Edit_People_Table" & dbkey)= True OR Session("Add_WorkGroup" & dbkey) = true OR Session("Edit_WorkGroup_Table" & dbkey))then
				bEdit = True
			end if
		Case "SITES"
			if Session("Edit_Sites_Table" & dbkey)= True then
				bEdit = True
			end if
		
		end Select

		if bEdit = True then 
			bEditTable = True 
		else 
			bEditTable = False
		end if
		
		if bEditTable = True then%>
		<script language="javascript">
			link_value = "<%=value%>"
			if(link_value.length > 0 ){
				getLink(link_value, "edit_record")
			}
			else{
				document.write('')
			}
		</script>
		<%else
		Response.write value
		end if
	else

		if Not value <> "" then
			value = "&nbsp;"
		end if

		if UCase(fieldname) = "ACTIVE" then
		if not isNull(value) then
			value = CBool(value)
			end if
		end if
		Response.Write value
   end if%>
</td>

<%next%>

</TR>

<%'if err.number > 0 then Response.Write err.description
CloseRS(BaseRS)
CloseConn(DataConn)
%>   

<!--#INCLUDE VIRTUAL ="/cfserverasp/source/recordset_footer_vbs.asp"-->
</table>



</body>
</html>























