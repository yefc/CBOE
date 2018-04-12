<%@ Language=VBScript %>
<!--#INCLUDE VIRTUAL = "/cheminv/gui/GetLocationAttributes.asp"-->
<!--#INCLUDE VIRTUAL = "/cheminv/gui/guiUtils.asp"-->
<!--#INCLUDE VIRTUAL = "/cheminv/api/apiUtils.asp"-->

<%
LocationID = Request("LocationID")
if isEmpty(LocationID) then  LocationID = Session("CurrentLocationID")
if isEmpty(LocationID) then LocationID = "0"
LocationText = "Location"
FormatText = "Grid Format"

if LocationID <> "" then
	DataLocationID = LocationID
	Session("CurrentLocationID") = LocationID
else
	DataLocationID = Session("CurrentLocationID")
end if

'Response.Write("Request Location: " & LocationID & ", Session LocationID: " & Session("CurrentLocationID") & ":" & DataLocationID & "<br>")
Call GetInvConnection()
SQL="SELECT LOCATION_ID FROM " &  Application("CHEMINV_USERNAME") & ".inv_Locations WHERE LOCATION_TYPE_ID_FK=27" 
Dim racks
Set RS= Conn.Execute(SQL)
IF Not RS.EOF  THEN
    RS.MoveFirst
    While NOT RS.EOF
        racks=racks & "," & RS("LOCATION_ID")
        RS.movenext
    Wend
End if
SourceLocationID = LocationID
str = Session("CurrentLocationName")
start = InStrRev(str,"\")
SourceLocationName = Mid(str, start+1, Len(str)-start) 
%>
<html>
<head>

<title><%=Application("appTitle")%> -- Move Inventory <%=LocationText%></title>
<script language="javascript" type="text/javascript" src="/cheminv/Choosecss.js"></script>
<script language="javascript" type="text/javascript" src="/cheminv/utils.js"></script>
<script language="javascript" type="text/javascript" src="/cheminv/gui/validation.js"></script>
<script language="javascript" type="text/javascript">
<!--Hide JavaScript
	window.focus();
	var DialogWindow;

	function ValidateMove(){
        var racks="<%=racks%>";
		var bWriteError = false;
		var errmsg = "Please fix the following problems:\r";
		
		// LocationID is required
		if (document.form1.LocationID.value.length == 0) {
			errmsg = errmsg + "- Location to move is required.\r";
			bWriteError = true;
		}
		//cannot move a location storage within a grid format.
		else{
		    if(IsChildGridLocation(document.form1.LocationID.value)==1) {
		        errmsg = errmsg + " - Cannot move a location storage within a grid format.\r";
		        bWriteError = true;
		    }
		}

       	// Destination is required
		if (document.form1.ParentID.value.length == 0) {
			errmsg = errmsg + "- Destination is required.\r";
			bWriteError = true;
		}
		// Cannot move a location to a destination which is a rack. 
		if ((isaRackLocation(document.form1.ParentID.value)==1) && (isaRackLocation(document.form1.LocationID.value)!=1)){
			errmsg = errmsg + "Cannot move a location to a Rack.\r";
			bWriteError = true;
		}
		
		if (bWriteError){
			alert(errmsg);
		}
		else{
			document.form1.target = window.name;
			document.form1.submit();
		}
	}

-->
</script>
</head>
<%

'SourceLocationID = LocationID
SourceLocationID = DataLocationID
str = Session("CurrentLocationName")
start = InStrRev(str,"\")
SourceLocationName = Mid(str, start+1, Len(str)-start) 
 
%>
<body>
<center>
<form name="form1" xaction="echo.asp" action="MoveLocation_action.asp" method="POST" target="this.window">
<% 
'-- If this location is in a Grid location display error
isaGridElement = cint(isGridElement(LocationID))
if isaGridElement > 0 then 
%>

<br /><br />
<span class="GuiFeedback">You cannot move or delete a location within a grid format.</span><br><br>
<%=GetOkButton()%>
<% else %>
<table border="0">
	<tr>
		<td colspan="2">
			<span class="GuiFeedback">Move an inventory <%=lCase(LocationText)%> and all of its contents.</span><br><br>
		</td>
	</tr>
	<tr>
		<td align="right" nowrap>
			<span class="required"><%=LocationText%> to move: <%=GetBarcodeIcon()%></span>
		</td>
		<td>
		<%
		tempLocationID = LocationID
		LocationID = DataLocationID
		%>
			<%ShowLocationPicker8 "document.form1", "LocationID", "lpLocationBarCode_1", "lpLocationName_1", 10, 30, false,"",false%> 
		<%
		LocationID = tempLocationID
		%>
		</td>
	</tr>
	<tr class="moveTo">
		<td align="right" nowrap>
			<span class="required" title="LocationID of the destination">Destination Location: <%=GetBarcodeIcon()%></span>
		</td>
		<td>
			<%ShowLocationPicker5 "document.form1", "ParentID", "lpLocationBarCode_2", "lpLocationName_2", 10, 30, false, Session("DefaultLocation"),false%> 
			
		</td>
	</tr>
	<tr>
		<td colspan="2" align="right"> 
			<%=GetCancelButton()%>&nbsp;<a HREF="#" onclick="ValidateMove(); return false;"><img SRC="/cheminv/graphics/sq_btn/ok_dialog_btn.gif" border="0"></a>
		</td>
	</tr>	
</table>	
<% end if %>
</form>
</center>
</body>
</html>
