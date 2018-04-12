<%@ EnableSessionState=False Language=VBScript%>
<!--#INCLUDE VIRTUAL = "/cfserverasp/source/ado.inc"-->
<!--#INCLUDE VIRTUAL = "/cfserverasp/source/server_const_vbs.asp"-->
<!--#INCLUDE VIRTUAL = "/cheminv/api/apiUtils.asp"-->
<!--#INCLUDE VIRTUAL = "/cfserverasp/source/cs_security/cs_security_login_utils_vbs.asp" -->
<Script RUNAT="Server" Language="VbScript">
Dim Conn
Dim Cmd
Dim strError
Dim bWriteError
Dim PrintDebug

bDebugPrint = false
bWriteError = False
strError = "Error:Update Par Level<BR>"

CsUserName =Request("tempCsUserName") 
CsUserID = URLDecode(CryptVBS(request("tempCsUserID"),CsUserName))
CAS=Request("CAS")
CompoundID = Request("CompoundID")
LocationId = Request("LocationId")
Frequency = Request("Frequency")

if IsEmpty(CompoundId) then
CompoundId=null
end if

if IsEmpty(CAS) then
CAS=null
end if


CsUserName = Application("CHEMINV_USERNAME") 
CsUserID = Application("CHEMINV_PWD")


' Redirect to help page if no parameters are passed
If Len(Request.QueryString) = 0 AND Len(Request.Form)= 0 then
	Response.Redirect "/cheminv/help/admin/api/CreateSynonym.htm"
	Response.end
End if


'Echo the input parameters if requested
If NOT isEmpty(Request.QueryString("Echo")) then
	Response.Write "FormData = " & Request.form & "<BR>QueryString = " & Request.QueryString
	Response.end
End if

' Check for required parameters
If IsEmpty(CompoundID) and IsEmpty(CAS) then
	strError = strError & "Either CompoundID or CAS is a required parameter<BR>"
	bWriteError = True
End if

If IsEmpty(LocationId) then
	strError = strError & "LocationId is a required parameter<BR>"
	bWriteError = True
End if

If IsEmpty(Frequency) then
	strError = strError & "Frequency is a required parameter<BR>"
	bWriteError = True
End if

If bWriteError then
	' Respond with Error
	Response.Write strError
	Response.end
End if

if IsEmpty(CompoundId) then
CompoundId=null
end if

if IsEmpty(CAS) then
CAS=null
end if

' Set up and ADO command
Call GetInvCommand(Application("CHEMINV_USERNAME") & ".Requests.DFCI_CYCLECOUNTFREQUENCY", adCmdStoredProc)
Cmd.Parameters.Append Cmd.CreateParameter("RETURN_VALUE",adNumeric, adParamReturnValue, 0, NULL)
Cmd.Parameters("RETURN_VALUE").Precision = 9	
Cmd.Parameters.Append Cmd.CreateParameter("PCAS",200, adParamInput, 400 , CAS) 
Cmd.Parameters.Append Cmd.CreateParameter("PLocationID",200, adParamInput, 12, LocationID)
Cmd.Parameters("PLocationID").Precision = 9
Cmd.Parameters.Append Cmd.CreateParameter("PCOMPOUNDID",200, adParamInput, 12, CompoundID) 
Cmd.Parameters("PCOMPOUNDID").Precision = 9 	
Cmd.Parameters.Append Cmd.CreateParameter("PFREQUENCY",adNumeric, adParamInput, , Frequency) 
Cmd.Parameters("PFREQUENCY").Precision = 9

if bDebugPrint then
	For each p in Cmd.Parameters
		Response.Write p.name & " = " & p.value & "<BR>"
	Next	
Else
	Call ExecuteCmd(Application("CHEMINV_USERNAME") & ".Requests.DFCI_CYCLECOUNTFREQUENCY")
End if

' Return code
Response.Write Cmd.Parameters("RETURN_VALUE")

'Clean up
Conn.Close
Set Conn = Nothing
Set Cmd = Nothing

'Function to Decode the encrypted string 
Function URLDecode(str) 
	str = Replace(str, "+", " ") 
    For i = 1 To Len(str) 
		sT = Mid(str, i, 1) 
        If sT = "%" Then 
			If i+2 < Len(str) Then 
				sR = sR & _ 
                Chr(CLng("&H" & Mid(str, i+1, 2))) 
                i = i+2 
            End If 
        Else 
			sR = sR & sT 
        End If 
   Next 
   URLDecode = sR 
End Function 
</SCRIPT>
