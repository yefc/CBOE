<!--#INCLUDE VIRTUAL = "/cheminv/gui/guiUtils.asp"-->
<!--#INCLUDE VIRTUAL = "/cheminv/api/apiUtils.asp"-->
<!--#INCLUDE VIRTUAL = "/cfserverasp/source/display_func_vbs.asp"-->
<!--#INCLUDE VIRTUAL = "/cfserverasp/source/utility_func_vbs.asp"-->
<%
'Prevent page from being cached
Response.ExpiresAbsolute = Now()

Dim httpResponse
Dim FormData
Dim ServerName
ReportName = Request("ReportName")
Report_ID = Request("Report_ID")
QueryName = Request("QueryName")
HitlistID = Request("HitListID")
ContainerList = Request("ContainerList")
ContainerID = Request("ContainerID")
if ContainerID = "0" then ContainerID = ""
LocationID = Request("LocationID")
CompoundID = Request("CompoundID")
ReportFormat = Request("ReportFormat")
isCustomReport = Request("isCustomReport")
ReportTypeID = Request("ReportTypeID")
ShowInList = Request("ShowInList")
PlateID = Request("PlateID")
if PlateID = "0" then PlateID = ""
PlateList = Request("PlateList")

If ReportFormat = "" then ReportFormat = Application("DefaultReportFormat")

ServerName = Request.ServerVariables("Server_Name")
Credentials = "&CSUserName=" & Session("UserName" & "cheminv") & "&CSUSerID=" & Session("UserID" & "cheminv")
'Response.Write Credentials
'Response.end
if Session("INV_CREATE_LOCATION" & dbkey) then 
  userfilter=0
else
  userfilter=1
end if
if Len(HitlistID) > 0 then  
	ReportFunction = "CreateSearchResultsReport.asp"
	FormData = "ReportFormat=" & ReportFormat & "&ShowInList=" & ShowInList & "&HitListID=" & HitListID & "&ReportName=" & ReportName & Credentials
	'if bRunReport then httpResponse = CShttpRequest2("POST", ServerName, "/cheminv/api/CreateSearchResultsReport.asp", "ChemInv", FormData)
	if ShowInList = "plates" then
		If ReportName = "" then ReportName = Application("DefaultPlateSearchReport")
		ReportTypeID = 6
	else
		If ReportName = "" then ReportName = Application("DefaultContainerSearchReport")
		ReportTypeID = 2
	end if
elseif Len(ContainerList) > 0 then
	If ReportName = "" then ReportName = Application("DefaultLabelReport")
	ReportFunction = "CreateContainerReport.asp"
	FormData = "ReportFormat=" & ReportFormat & "&ContainerList=" & ContainerList & "&ReportName=" & ReportName & Credentials
	
	'if bRunReport then httpResponse = CShttpRequest2("POST", ServerName, "/cheminv/api/CreateContainerReport.asp", "ChemInv", FormData)
	ReportTypeID = 1
elseif (Len(LocationID) > 0) OR (Len(CompoundID) >0) OR (Len(ContainerID) > 0) OR (Len(PlateID) > 0) then
	ReportFunction = "CreateLocationReport.asp"
	FormData = "ReportFormat=" & ReportFormat & "&LocationID=" & LocationID & "&CompoundID=" & CompoundID & "&ShowInList=" & ShowInList & "&ContainerID=" & ContainerID & "&PlateID=" & PlateID & "&ReportName=" & ReportName & Credentials
	'if bRunReport then httpResponse = CShttpRequest2("POST", ServerName, "/cheminv/api/CreateLocationReport.asp", "ChemInv", FormData)
	if ShowInList = "plates" then
		If ReportName = "" then ReportName = Application("DefaultPlateLocationReport")
		ReportTypeID = 5
	else
		If ReportName = "" then ReportName = Application("DefaultContainerLocationReport")
		ReportTypeID = 3
	end if
elseif isCustomReport= "1" then
	ReportFunction = "CreateCustomReport.asp"
	for each field in Request.form
	   FormData = FormData & "&" & field & "=" & request(field)
    next
    FormData = Request.Form & Credentials & "&userfilter=" & userfilter
    'FormData = FormData & Credentials
	'FormData = FormData & "&Report_ID=" & Report_ID & Credentials
	'Response.write Formdata
Else
	Response.Write "Error: Either HitlistID or ContainerList or LocationID required"
	Response.end
End if	

If ReportFormat = "" then ReportFormat = "NULL"
If ReportName = "" then ReportName = "NULL"
If Report_ID = "" then Report_ID = 0
'Response.Write reportFunction & "<BR>"
'Response.write Formdata & "<BR>"
'Response.End
sendTimeout = 300 * 1000
receiveTimeout = 300 * 1000
if (ReportFormat <> "NULL" AND ReportName <> "NULL" AND Report_ID <> 0 AND Request.Form("doit")= "1") then
	httpResponse = CShttpRequest3("POST", ServerName, "/cheminv/api/" & ReportFunction , "ChemInv", FormData, sendTimeout, receiveTimeout)
'Response.Write httpResponse
'Response.end
End if

%>

<html>
<head>
<title><%=Application("appTitle")%> -- Create a Report</title>
<!--#INCLUDE VIRTUAL = "/cheminv/gui/dateFormat_js.asp"-->
<script LANGUAGE="javascript" src="/cheminv/Choosecss.js"></script>
<!--#INCLUDE VIRTUAL = "/cfserverasp/source/navbar_js.js"-->
<script LANGUAGE="javascript" src="/cheminv/gui/validation.js"></script>
<script language="JavaScript">
<!--Hide JavaScript
	window.focus();
	
	function validateReportID (ReportID) {
		if (ReportID=='NULL' || ReportID=='') {
			alert('Please select a report.');
			return false;
		} else {
			return true;
		}
	}
//-->

</script>
</head>
<body>

<%If InStr(1,httpResponse,"Error") = 0 Then%>
	<table border="0" cellspacing="0" cellpadding="2" width="600" align="left">
		<tr>
			<td valign="top" align="left">
				<img src="<%=Application("NavButtonGifPath")%>cheminventory_banner.gif" border="0">
			</td>
			<td align="right" valign="top">
			
				<%if NOT isEmpty(ReportTypeID) then	%>
				  <a class="MenuLink" HREF="#" onclick="if (top.DisplayFrame.location.href == 'about:blank'){history.go(-2)}else{history.go(-1)}; top.DisplayFrame.location.href='about:blank'; return false;">Back</a> |
				<%end if%>
				<a class="MenuLink" href="Close" onclick="parent.close(); return false">Close</a>
			</td>
		</tr>
		<tr>
			<td colspan="2" valign="top" align="right">
				<form name="cows_input_form" action="CreateReport_action.asp" method="POST" onsubmit="top.DisplayFrame.location.href='processing.html'">
				<input type="hidden" name="HitListID" value="<%=HitlistID%>">
				<input type="hidden" name="ContainerList" value="<%=ContainerList%>">
				<input type="hidden" name="ContainerID" value="<%=ContainerID%>">
				<input type="hidden" name="CompoundID" value="<%=CompoundID%>">
				<input type="hidden" name="LocationID" value="<%=LocationID%>">
				<input type="hidden" name="isCustomReport" value="<%=isCustomReport%>">
				<input type="hidden" name="ReportTypeID" value="<%=ReportTypeID%>">
				<input type="hidden" name="ShowInList" value="<%=ShowInList%>">
				<input type="hidden" name="PlateID" value="<%=PlateID%>">
				<input type="hidden" name="PlateList" value="<%=PlateList%>">
				<table border="0" cellspacing="0" cellpadding="0">
					<tr>
					<%Dim Conn%>
					<%if isempty(ReportTypeID) then%>					
							<%
							firstpage = 1
							Response.write ShowPicklist("Select a report type:", "ReportTypeID", "", "SELECT ReportTypeDesc AS DisplayText, ReportType_ID AS value FROM " &  Application("CHEMINV_USERNAME") & ".inv_Reporttypes")
							%>
						</td>
						<td>
							<input type="hidden" value="0" name="doit">
							<input type="submit" value="Go" name="submit">
						</td>
					</tr>
					<tr>
						<td colspan="2" align="right"> 
						&nbsp;	
						</td>
					</tr>
					<%elseif Report_ID=0 then%>	
					<%firstpage=0%>
						<td align="right" nowrap>
							Select a report layout:&nbsp;
						</td>
						<td align="left">
							<%
							if InStr(ReportTypeID,",") then
							  Response.write ShowRPTSelectBox("Report_ID", Report_ID, "SELECT ReportDisplayName AS DisplayText, ID AS value FROM " &  Application("CHEMINV_USERNAME") & ".inv_Reports WHERE ReportType_ID =" & right(ReportTypeID,len(ReportTYpeID)-1))
							else
							  Response.write ShowRPTSelectBox("Report_ID", Report_ID, "SELECT ReportDisplayName AS DisplayText, ID AS value FROM " &  Application("CHEMINV_USERNAME") & ".inv_Reports WHERE ReportType_ID =" & ReportTypeID)
							end if
							%>
						</td>
						<td>
							<input type="hidden" value="0" name="doit">
							<input type="submit" value="Go" name="submit" onclick="return validateReportID(document.cows_input_form.Report_ID.value);">
						</td>
					</tr>
					<tr>
						<td colspan="2" align="right"> 
						&nbsp;	
						</td>
					</tr>
					<%else%>
					<%firstpage=0%>
					<tr>
						<td>
							&nbsp;
						</td>
						<td>
							<input type="hidden" value="<%=Report_ID%>" name="Report_ID">	
							<%'Response.end%>
							<input TYPE="text" SIZE="30" Maxlength="50" NAME="ReportDisplayName" STYLE="background-color:#d3d3d3;" VALUE="<%=GetListFromSQL("SELECT ReportDisplayName FROM " & Application("CHEMINV_USERNAME") & ".inv_Reports WHERE ID=" & Report_ID)%>" READONLY>
							<input TYPE="hidden" NAME="QueryName" VALUE="<%=GetListFromSQL("SELECT QueryName FROM " & Application("CHEMINV_USERNAME") & ".inv_Reports WHERE ID=" & Report_ID)%>">
							<input TYPE="hidden" NAME="ReportName" VALUE="<%=GetListFromSQL("SELECT ReportName FROM " & Application("CHEMINV_USERNAME") & ".inv_Reports WHERE ID=" & Report_ID)%>">
							</td>
						<td>
							&nbsp;
						</td>	
					</tr>
					<%desc=GetListFromSQL("SELECT Report_Desc FROM " & Application("CHEMINV_USERNAME") & ".inv_Reports WHERE ID=" & Report_ID)%>
					<%if desc <> NULL then%>
					<tr>
					  <td colspan="2">
					    &nbsp;<br>
					    <i><%desc%></i>
					    <br>&nbsp;
					  </td>
					</tr>
					<%end if%>
					<%=GenerateInputElements(Report_ID)%>
					<tr>
						<td align="right" nowrap>
							Select a report format:&nbsp;
						</td>
						<td align="left">
							<%
							Response.write ShowRPTSelectBox("ReportFormat", ReportFormat, "SELECT FormatDisplayName AS DisplayText, ReportFormat AS value FROM " & Application("CHEMINV_USERNAME") & ".inv_ReportFormats WHERE Available = 1")
							%>
						</td>
						<td>
							<input type="hidden" value="1" name="doit">
							<input type="submit" value="Go" name="submit">
						</td>	
					</tr>
					<%end if%>
				</table>
				</form>
			</td>
		</tr>
	</table>
		<%if (ReportFormat <> "NULL" AND ReportName <> "NULL") then%>	
			<script LANGUAGE="javascript">top.DisplayFrame.location.href = "DisplayReport.asp?ReportFormat=<%=ReportFormat%>&ReportURL=<%=httpResponse%>";</script>
		<%else%>
			<script LANGUAGE="javascript">top.DisplayFrame.location.href = "about:blank";</script>
		<%end if%>
<%Else

	Response.Write "<table border=0 width=""90%""><tr><td><BR><BR><CENTER><P><CODE>" & httpResponse & "</CODE></P>"
	Response.Write "<SPAN class=""GuiFeedback"">Report could not be created</SPAN></td></tr></table></center>"			
%>
	<script LANGUAGE="javascript">top.DisplayFrame.location.href = "about:blank";</script>
<%End if%>		
</body>
</html>
<%'****************************************************************************************
'*	PURPOSE: Generate an input form element with header for each parameter in the report 
'*	INPUT: Report_ID
'*	OUTPUT: form elements with header for each of the parameters defined for the form
'****************************************************************************************
Function GenerateInputElements(Report_ID)
	Dim html,DisplayName,i,iRecFirst,iRecLast,ParamNames
	html = ""
	ParamNames=GetArrayFromSQL("SELECT ParamName,ParamType,isrequired, ParamDisplayName FROM " &  Application("CHEMINV_USERNAME") & ".inv_ReportParams WHERE Report_ID=" & Report_ID)
	'ParamNames=GetArrayFromSQL("SELECT ParamName,ParamType,isrequired, ParamDisplayName FROM CHEMINVDB2.inv_ReportParams WHERE Report_ID=12")

	if isArray(ParamNames) then
	  iRecFirst = LBound(ParamNames, 2)
	  iRecLast = UBound(ParamNames, 2)	  
	  For i = iRecFirst To iRecLast
	    if Rtrim(ParamNames(1,i))="start_date" OR Rtrim(ParamNames(1,i))="end_date" then
	      if ParamNames(2,i)= "0" then
			html = html &"<tr><td align=right>" & Rtrim(ParamNames(3,i)) & ": </td>"
		  else
			html = html &"<tr><td align=right><font color=red>" & Rtrim(ParamNames(3,i)) & ": </font></td>"
		  end if
	      html = html & "<td>" & getShowInputField("", "", Rtrim(ParamNames(1,i)) & "_field_" & Rtrim(ParamNames(0,i)), "DATE_PICKER:TEXT", "15") & "</td></tr>"
	    else
	  	  if ParamNames(2,i)= "0" then
			html = html &"<tr><td align=right>" & Rtrim(ParamNames(3,i)) & ": </td>"
		  else
			html = html &"<tr><td align=right><font color=red>" & Rtrim(ParamNames(3,i)) & ": </font></td>"
		  end if
        	html = html & "<td><input required TYPE=""text"" SIZE=""20"" Maxlength=""50"" NAME=""" & "field_" & Rtrim(ParamNames(0,i)) & """></td></tr>"
 		end if
	  Next
	end if
	GenerateInputElements = html
	'GenerateInputElements = Application("CHEMINV_USERNAME")
End function%>