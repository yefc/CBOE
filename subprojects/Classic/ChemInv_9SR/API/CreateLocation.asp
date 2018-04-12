<%@ EnableSessionState=False Language=VBScript%>
<!--#INCLUDE VIRTUAL = "/cfserverasp/source/ado.inc"-->
<!--#INCLUDE VIRTUAL = "/cfserverasp/source/server_const_vbs.asp"-->
<!--#INCLUDE VIRTUAL = "/cheminv/api/apiUtils.asp"-->
<Script RUNAT="Server" Language="VbScript">
Dim Conn
Dim Cmd
Dim strError
Dim bWriteError
Dim PrintDebug
Dim LocationID
Dim ParentID
Dim LocationName
Dim LocationDesc

bDebugPrint = false	
bWriteError = False
strError = "Error:CreateLocation<BR>"

ParentID = Request("ParentID")
Barcode = Request("Barcode")
BarcodeDescID = Request("BarcodeDescID")
LocationName = Request("LocationName")
LocationDesc = Request("LocationDesc")
LocationTypeID = Request("LocationTypeID")
GridFormatID = Request("GridFormatID")
PlateTypeList = Request("PlateTypeList")
LocationOwnerID = Request("LocationOwnerID")
AllowContainers = Request("AllowContainers")

' Redirect to help page if no parameters are passed
If Len(Request.QueryString) = 0 AND Len(Request.Form)= 0 then
	Response.Redirect "/cheminv/help/admin/apiCreateLocation.htm"
	Response.end
End if

'Echo the input parameters if requested
If NOT isEmpty(Request.QueryString("Echo")) then
	Response.Write "FormData = " & Request.form & "<BR>QueryString = " & Request.QueryString
	Response.end
End if

' Check for required parameters
If IsEmpty(ParentID) then
	strError = strError & "ParentID is a required parameter<BR>"
	bWriteError = True
End if
If IsEmpty(LocationName) then
	strError = strError & "LocationName is a required parameter<BR>"
	bWriteError = True
End if

' Optional parameters
if IsEmpty(Barcode) OR Barcode = "" then Barcode = NULL
if IsEmpty(BarcodeDescID) or BarcodeDescID = "" then BarcodeDescID = NULL
if IsEmpty(LocationDesc) then LocationDesc = NULL
if IsEmpty(LocationTypeID) then LocationTypeID = NULL
if IsEmpty(GridFormatID) OR GridFormatID = "" then GridFormatID = NULL
if IsEmpty(PlateTypeList) OR PlateTypeList = "" then PlateTypeList = "0"
If isEmpty(LocationOwnerID) or LocationOwnerID = "" then LocationOwnerID = NULL

If bWriteError then
	' Respond with Error
	Response.Write strError
	Response.end
End if

' Set up and ADO command
Call GetInvCommand(Application("CHEMINV_USERNAME") & ".CreateLocation", adCmdStoredProc)

' Code generated by QueryProcParams.asp helper page
Cmd.Parameters.Append Cmd.CreateParameter("RETURN_VALUE",adNumeric, adParamReturnValue, 0, NULL)
Cmd.Parameters("RETURN_VALUE").Precision = 9
Cmd.Parameters.Append Cmd.CreateParameter("PBarcode",200, 1, 4000, Barcode)
Cmd.Parameters.Append Cmd.CreateParameter("PBARCODEDESCID",131, 1, 0, BarcodeDescID)
Cmd.Parameters("PBARCODEDESCID").Precision = 9
Cmd.Parameters.Append Cmd.CreateParameter("PPARENTID",131, 1, 0, ParentID)
Cmd.Parameters("PPARENTID").Precision = 9
Cmd.Parameters.Append Cmd.CreateParameter("PNAME",200, 1, 50, LocationName)
Cmd.Parameters.Append Cmd.CreateParameter("PLOCATIONTYPEID",131, 1, 0, LocationTypeID)
Cmd.Parameters("PLOCATIONTYPEID").NumericScale = 0
Cmd.Parameters("PLOCATIONTYPEID").Precision = 9
Cmd.Parameters.Append Cmd.CreateParameter("PDESC",200, 1, 255, LocationDesc)
Cmd.Parameters.Append Cmd.CreateParameter("PGRIDFORMATID",131, 1, 0, GridFormatID)
Cmd.Parameters("PGRIDFORMATID").NumericScale = 0
Cmd.Parameters("PGRIDFORMATID").Precision = 9
Cmd.Parameters.Append Cmd.CreateParameter("PALLOWEDPLATETYPELIST",200, 1, 4000, PlateTypeList)
Cmd.Parameters.Append Cmd.CreateParameter("PLOCATIONOWNER",200, 1, 50,LocationOwnerID)

if bDebugPrint then
	For each p in Cmd.Parameters
		Response.Write p.name & " = " & p.value & "<BR>"
	Next	
Else
	Call ExecuteCmd(Application("CHEMINV_USERNAME") & ".CreateLocation")
End if

' Return the newly created LocationID
Response.Write Cmd.Parameters("RETURN_VALUE")

'Clean up
Conn.Close
Set Conn = Nothing
Set Cmd = Nothing
</SCRIPT>
