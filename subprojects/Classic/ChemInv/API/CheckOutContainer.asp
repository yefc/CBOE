<%@ EnableSessionState=False Language=VBScript%>
<!--#INCLUDE VIRTUAL = "/cfserverasp/source/ado.inc"-->
<!--#INCLUDE VIRTUAL = "/cfserverasp/source/server_const_vbs.asp"-->
<!--#INCLUDE VIRTUAL = "/cheminv/api/apiUtils.asp"-->
<!--#INCLUDE VIRTUAL = "/cheminv/gui/guiUtils.asp"-->
<Script RUNAT="Server" Language="VbScript">
Dim LocationID
Dim ContainerID
Dim Conn
Dim Cmd

Dim strError
Dim bWriteError
Response.Expires = -1
bDebugPrint = false
bWriteError = False
strError = "Error:CheckOutContainer<BR>"
dateFormat = Application("DATE_FORMAT")

LocationID = Request("LocationID")
ContainerID = Request("ContainerID")
CurrentUserID = Request("CurrentUserID")
DefaultLocationID = Request("DefaultLocationID")
OwnerID = Request("OwnerID")
ContainerStatusID = Request("ContainerStatusID")
Action = Request("Action")
UseDefaultLocation = Request("UseDefaultLocation")

'for each key in Request.Form
'	Response.Write key & "=" & request(key) & "<BR>"
'next
'Response.End

' Redirect to help page if no parameters are passed
if Len(Request.QueryString) = 0 AND Len(Request.Form)= 0 then
	Response.Redirect "/cheminv/help/admin/api/CheckOutContainer.htm"
	Response.end
End if

If UseDefaultLocation = "ON" then   'Fixing Bug CSBR-75414 
	UseDefaultLocation = "1"
else
	UseDefaultLocation = "0"
end if

' Check for required parameters
if IsEmpty(LocationID) then
	strError = strError & "LocationID is a required parameter<BR>"
	bWriteError = True
End if
if IsEmpty(ContainerID) then
	strError = strError & "ContainerID is a required parameter<BR>"
	bWriteError = True
End if

' Respond with Error
if bWriteError then
	Response.Write strError
	Response.end
End if

' Initialize optional parameters
if CurrentUserID = "" then CurrenUserID = NULL
If DefaultLocationID = "" then DefaultLocationID = NULL
if OwnerID = "" then OwnerID = NULL
if ContainerStatusID = "" then ContainerStatusID = NULL

' Set up and ADO command
if UseDefaultLocation = "1" then
	Call GetInvCommand(Application("CHEMINV_USERNAME") & ".CheckInDefaultLocation", adCmdStoredProc)
else
    Call GetInvCommand(Application("CHEMINV_USERNAME") & ".CheckOutContainer", adCmdStoredProc)
end if
' Code generated by QueryProcParams.asp helper page
Cmd.Parameters.Append Cmd.CreateParameter("RETURN_VALUE",adNumeric, adParamReturnValue, 0, NULL)
Cmd.Parameters("RETURN_VALUE").Precision = 9
Cmd.Parameters.Append Cmd.CreateParameter("PLOCATIONID",200, 1, 4000, LocationID)
Cmd.Parameters("PLOCATIONID").Precision = 9
Cmd.Parameters.Append Cmd.CreateParameter("PCONTAINERID",200, 1, 4000, ContainerID)
Cmd.Parameters("PCONTAINERID").Precision = 9
Cmd.Parameters.Append Cmd.CreateParameter("PCURRENTUSERID",200, 1, 50, CurrentUserID)
Cmd.Parameters.Append Cmd.CreateParameter("POWNERID",200, 1, 50, OwnerID)
if UseDefaultLocation <> "1" then
Cmd.Parameters.Append Cmd.CreateParameter("PDEFAULTLOCATIONID",131, 1, 0, DefaultLocationID)
end if
Cmd.Parameters.Append Cmd.CreateParameter("PCONTAINERSTATUSID",131, 1, 0, ContainerStatusID)
if bDebugPrint then
	For each p in Cmd.Parameters
		Response.Write p.name & " = " & p.value & "<BR>"
	Next	
Else
	if UseDefaultLocation = "1" then	    
		Call ExecuteCmd(Application("CHEMINV_USERNAME") & ".CheckInDefaultLocation")
	else	    
	    Call ExecuteCmd(Application("CHEMINV_USERNAME") & ".CheckOutContainer")
	end if
End if

NewLocationID = Cmd.Parameters("RETURN_VALUE")

'insert into inv_container_checkin_details if necessary
if Action = "in" and Application("ShowCheckInDetails") then 
	UserIDFK = Request("User_ID_FK")
	Field1 = iif(Request("iField_1")="",null,Request("iField_1"))
	Field2 = iif(Request("iField_2")="",null,Request("iField_2"))
	Field3 = iif(Request("iField_3")="",null,Request("iField_3"))
	Field4 = iif(Request("iField_4")="",null,Request("iField_4"))
	Field5 = iif(Request("iField_5")="",null,Request("iField_5"))
	Field6 = iif(Request("iField_6")="",null,Request("iField_6"))
	Field7 = iif(Request("iField_7")="",null,Request("iField_7"))
	Field8 = iif(Request("iField_8")="",null,Request("iField_8"))
	Field9 = iif(Request("iField_9")="",null,Request("iField_9"))
	Field10 = iif(Request("iField_10")="",null,Request("iField_10"))
	Date1 = iif(Request("iDate_1")="",null,ConvertStrToDate(dateFormat,Request("iDate_1")))
	Date2 = iif(Request("iDate_2")="",null,ConvertStrToDate(dateFormat,Request("iDate_2")))
	Date3 = iif(Request("iDate_3")="",null,ConvertStrToDate(dateFormat,Request("iDate_3")))

	Call GetInvCommand(Application("CHEMINV_USERNAME") & ".InsertCheckInDetails", adCmdStoredProc)
	Cmd.Parameters.Append Cmd.CreateParameter("RETURN_VALUE",adNumeric, adParamReturnValue, 0, NULL)
	Cmd.Parameters("RETURN_VALUE").Precision = 9
    Cmd.Parameters.Append Cmd.CreateParameter("PCONTAINERID",200, 1, 4000,ContainerID) 
	Cmd.Parameters("PCONTAINERID").Precision = 9
	Cmd.Parameters.Append Cmd.CreateParameter("PUSERIDFK",200, 1, 50, UserIDFK)
	Cmd.Parameters.Append Cmd.CreateParameter("PFIELD1",200, 1, 2000, Field1)
	Cmd.Parameters.Append Cmd.CreateParameter("PFIELD2",200, 1, 2000, Field2)
	Cmd.Parameters.Append Cmd.CreateParameter("PFIELD3",200, 1, 2000, Field3)
	Cmd.Parameters.Append Cmd.CreateParameter("PFIELD4",200, 1, 2000, Field4)
	Cmd.Parameters.Append Cmd.CreateParameter("PFIELD5",200, 1, 2000, Field5)
	Cmd.Parameters.Append Cmd.CreateParameter("PFIELD6",200, 1, 2000, Field6)
	Cmd.Parameters.Append Cmd.CreateParameter("PFIELD7",200, 1, 2000, Field7)
	Cmd.Parameters.Append Cmd.CreateParameter("PFIELD8",200, 1, 2000, Field8)
	Cmd.Parameters.Append Cmd.CreateParameter("PFIELD9",200, 1, 2000, Field9)
	Cmd.Parameters.Append Cmd.CreateParameter("PFIELD10",200, 1, 2000, Field10)
	Cmd.Parameters.Append Cmd.CreateParameter("PDATE1",135, 1, 2000, Date1)
	Cmd.Parameters.Append Cmd.CreateParameter("PDATE2",135, 1, 2000, Date2)
	Cmd.Parameters.Append Cmd.CreateParameter("PDATE3",135, 1, 2000, Date3)
	if bDebugPrint then
		For each p in Cmd.Parameters
			Response.Write p.name & " = " & p.value & "<BR>"
		Next	
		Response.End
	Else
		Call ExecuteCmd(Application("CHEMINV_USERNAME") & ".InsertCheckInDetails")
	End if
	NewContainerCheckInDetailsID = Cmd.Parameters("RETURN_VALUE")
	'Response.Write NewContainerCheckInDetailsID
	'Response.Write err.Description & "<BR>"
	

end if

' Return the new LocationID
Response.Write NewLocationID

'Clean up
Conn.Close
Set Conn = Nothing
Set Cmd = Nothing
</SCRIPT>
