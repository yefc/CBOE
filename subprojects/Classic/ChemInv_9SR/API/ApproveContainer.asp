<%@ EnableSessionState=False Language=VBScript%>
<!--#INCLUDE VIRTUAL = "/cfserverasp/source/ado.inc"-->
<!--#INCLUDE VIRTUAL = "/cfserverasp/source/server_const_vbs.asp"-->
<!--#INCLUDE VIRTUAL = "/cheminv/api/apiUtils.asp"-->
<Script RUNAT="Server" Language="VbScript">
Dim Conn
Dim Cmd
Dim strError
Dim bWriteError
Dim bDebugPrint

bDebugPrint = false
bWriteError = False
strError = "Error:ApproveContainer<BR>"

ApprovedContainerIDList = Request("ApprovedContainerIDList")
RejectedContainerIDList = Request("RejectedContainerIDList")
StatusApproved = Request("StatusApproved")
StatusDefault = Request("StatusDefault")

' Redirect to help page if no parameters are passed
If Len(Request.QueryString) = 0 AND Len(Request.Form)= 0 then
	Response.Redirect "/cheminv/help/admin/api/ApproveContainer.htm"
	Response.end
End if

'Echo the input parameters if requested
If NOT isEmpty(Request.QueryString("Echo")) then
	Response.Write "FormData = " & Request.form & "<BR>QueryString = " & Request.QueryString
	Response.end
End if

' Check for required parameters
If IsEmpty(ApprovedContainerIDList) and IsEmpty(RejectedContainerIDList) then
	strError = strError & "Either ApprovedContainerIDList or RejectedContainerIDList is a required parameter<BR>"
	bWriteError = True
End if
If IsEmpty(StatusApproved) then
	strError = strError & "StatusApproved is a required parameter<BR>"
	bWriteError = True
End if
If IsEmpty(StatusDefault) then
	strError = strError & "StatusDefault is a required parameter<BR>"
	bWriteError = True
End if

If bWriteError then
	' Respond with Error
	Response.Write strError
	Response.end
End if

' Set up and ADO command
Call GetInvCommand(Application("CHEMINV_USERNAME") & ".Approvals.ApproveAndRejectContainers", adCmdStoredProc)
Cmd.Parameters.Append Cmd.CreateParameter("RETURN_VALUE",200, adParamReturnValue, 2000, NULL)
Cmd.Parameters("RETURN_VALUE").Precision = 9			
Cmd.Parameters.Append Cmd.CreateParameter("PAPPROVEDCONTAINERIDLIST",200, adParamInput, 2000, ApprovedContainerIDList) 
Cmd.Parameters.Append Cmd.CreateParameter("PAPPROVEDSTATUSIDFK",adNumeric, 1, 0, StatusApproved)
Cmd.Parameters.Append Cmd.CreateParameter("PREJECTEDCONTAINERIDLIST",200, adParamInput, 2000, RejectedContainerIDList) 
Cmd.Parameters.Append Cmd.CreateParameter("PREJECTEDSTATUSIDFK",adNumeric, 1, 0, StatusDefault)
if bDebugPrint then
	For each p in Cmd.Parameters
		Response.Write p.name & " = " & p.value & "<BR>"
	Next	
Else
	Call ExecuteCmd(Application("CHEMINV_USERNAME") & ".Approvals.ApproveAndRejectContainers")
End if

' Return code
Response.Write Cmd.Parameters("RETURN_VALUE")

'Clean up
Conn.Close
Set Conn = Nothing
Set Cmd = Nothing
</SCRIPT>
