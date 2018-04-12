<%@ EnableSessionState=True Language=VBScript%>
<!--#INCLUDE VIRTUAL = "/cfserverasp/source/ado.inc"-->
<!--#INCLUDE VIRTUAL = "/cheminv/api/apiUtils.asp"-->
<!--#INCLUDE VIRTUAL = "/cheminv/gui/guiUtils.asp"-->
<!--#INCLUDE VIRTUAL = "/cfserverasp/source/cs_security/cs_security_login_utils_vbs.asp" -->
<%
if not Session("IsFirstRequest") then 
	StoreASPSessionID()
else
	Session("IsFirstRequest") = false
	Response.Write("<html><body onload=""window.location.reload()"">&nbsp;<form name=""form1""></form></body></html>")	
end if

CSUserName=ucase(Session("UserName" & "cheminv")) 
CSUserID= Session("UserID" & "cheminv")

if CSUserName = "" or CSUserID = "" then
	response.write "<BR>No credentials found."
	response.end
end if
%>

<html>
<head>
<meta NAME="GENERATOR" Content="Microsoft Visual Studio 6.0">
<title><%=Application("appTitle")%> -- Recieve Ordered Containers</title>
<script LANGUAGE="javascript" src="/cheminv/Choosecss.js"></script>
<script LANGUAGE="javascript" src="/cheminv/utils.js"></script>
<script LANGUAGE="javascript">

function Deliver(elm){
	var tempCSUserName= "<%=Session("UserName" & "cheminv")%>";
	var tempCSUserID= "<%=Server.URLEncode(CryptVBS(lcase(Session("UserID" & "cheminv")),Session("UserName" & "cheminv")))%>"
	var ID = elm.name.substring(4,elm.name.length);
	var locationid = document.all["LOCT" + ID].value;
	var locationidsource = document.all["LOCS" + ID].value;
	if (locationidsource) {
	locationidsource=locationidsource.replace("*","");
	}
	var compoundid = document.all["COMP" + ID].value;
	var oldamount = document.all["OLDA" + ID].value;
	var amount = document.all["NEWA" + ID].value * document.all["CONV" + ID].value;
	var httpResponse ="";
	
	var msg="";


	if (document.all["Approve"].checked && document.all["DELI" + ID].checked) {

	var strURL = "http://" + serverName + "/cheminv/api/DFCI_BulkMove.asp?compoundID=" + compoundid + "&LocationIdSource=" + locationidsource + "&LocationId=" + locationid + "&qty=" + amount; 	
	strURL = strURL + "&tempCSUserId=" + tempCSUserID + "&tempCSUserName=" + tempCSUserName;
	//alert(strURL);
	var httpResponse = JsHTTPGet(strURL);
	//alert("JSHTTP= " + httpResponse);

	
	document.all["status_" + ID].style.fontWeight="bold";
	if (httpResponse >= 0){
		//change the bkgrnd color and lock the input box
		elm.style.backgroundColor="lightyellow";
		elm.disabled = true;
		document.all["NEWA" + ID].disabled=true;
		document.all["LOCS" + ID].disabled=true;
		document.all["DELI" + ID].disabled=true;
		document.all["status_" + ID].innerHTML=amount + " Sent";	
		document.all["status_" + ID].style.color="green";
		document.all["status_" + ID].title = "Supply has been moved to Destination.";
	}
	else{
		switch(httpResponse) 
		{
			case "-9000":
			msg="No compound matches";
			break;
			case "-9001":
			msg="Multiple compound matches";
			break;
			case "-9005":
			msg="Insufficient supply";
			break;
			case "-9004":
			msg="No location match"
			break;
			default:
			msg="Error"
		}	
		document.all["status_" + ID].innerHTML=msg;
		document.all["status_" + ID].style.color="red";
	}
}

}

function doIt(){
	var s="";
	var elms = document.form1.elements;
	for (var i=0;i<elms.length; i++){
	if ((elms[i].name.substr(0,4)=="PARL")) {
		if ((elms[i].value.length > 0) && (!elms[i].disabled)) Deliver(elms[i]);
		}	
	}
}

</script>


</head>
<body>
<%
Dim Conn
Dim Cmd
Dim RS

bDebugPrint = false
bWriteError = False
strError = "Error:BulkMove_display.asp<BR>"

locationID = Request("ilocationID")
if locationID = "" then locationID = NULL

NDC = Request("NDC")
if NDC = "" then NDC = NULL

drugname= request("drugname")
if drugname = "" then drugname = NULL

BumpUp = Request("BumpUp")

if BumpUP = "" then bumpUp=0

If bWriteError then
	' Respond with Error
	Response.Write strError
	Response.end
End if

Response.Expires = -1
Call GetInvCommand("{CALL " & Application("CHEMINV_USERNAME") & ".REQUESTS.DFCI_GetBulkQty(?,?,?)}", adCmdText)	
Cmd.Parameters.Append Cmd.CreateParameter("pLocationID",131, 1, 0, LocationID)
Cmd.Parameters.Append Cmd.CreateParameter("pNDC",200, 1, 50, NDC)
Cmd.Parameters.Append Cmd.CreateParameter("pDrugName",200, 1, 50, DrugName)

if bDebugPrint then
	For each p in Cmd.Parameters
		Response.Write p.name & " = " & p.value & "<BR>"
	Next
Else
	Cmd.Properties ("PLSQLRSet") = TRUE  
	Set RS = Cmd.Execute
	Cmd.Properties ("PLSQLRSet") = FALSE

'Response.Write RS.getString()
'Response.End

caption = "Enter the source, amount to transfer, and check the deliver box for each applicable item. Check the ""Deliver Checked Items"" box to enable the transfer.Press OK to submit the changes:"
disable2 = "disabled"

If (RS.EOF AND RS.BOF) then
	Response.Write ("<BR><BR><span class=""GUIFeedback"">&nbsp;&nbsp;&nbsp;No matching combinations found</Span>")
	Response.end
End if
%>


	<br>
	<p><span class="GUIFeedback"><%=Caption%></span></p>
	<form name="form1" action="deliver_request_action.asp" method="POST">
	<table border="1">
	<tr>
		<td colspan="13" align="center">
		Deliver Checked Items <input type=checkbox name="Approve" value="Yes"> <br><BR>			
			<a href="#" onclick="doIt()"><img border="0" src="../graphics/ok_dialog_btn.gif"></a>
		</td>
	</tr>
	<tr>
		<th>
			Sell Units Transferred
		</th>
		<th>
			Source Location
		</th>
		<th>
			NDC
		</th>
		<th>
			Drug Name
		</th>
		<th>
			Package Size
		</th>
		<th> Sell Units to Transfer </th>
		<th> Destination </th>
		<th>
			Deliver?
		</th>
	
	</tr>	
<%	
		While (Not RS.EOF)
			
 			NDC = RS("NDC").value
			CompoundId = Rs("Compound_Id")
			CompoundName = Rs("Substance_Name") 
			packagesize=RS("Package_Size").value
			containerqtymax=CDbl(RS("container_qty_max").value)
			containercount=CInt(RS("container_count").value)				
			uom=rs("UOM").value
%>

			<span id="R<%=ContainerID%>" style="background-color:green"> 
			
			<tr>
				<td align="left"> <span title id="status_<%=compoundid%>"></span>
					<input type=hidden name="PARL<%= compoundid%>" value="<%=compoundid%>">
					<input type=hidden name="CONV<%= compoundid%>" value="<%=containerqtymax%>">
					</td>	
				
				<% 
				' Generate picklist sql
				PicklistSql="select sum(qty_available) total, decode(location_type_id_fk,1003,'*','')||location_name || ',' ||sum(qty_available)/container_qty_max || ' Sell Unit' || case when sum(qty_available)/container_qty_max>1 then 's' else '' end  as displaytext,  decode(location_type_id_fk,1003,'*','')||location_id as value from inv_locations, inv_containers, inv_units,inv_compounds, chemacxdb.packagesizeconversion psc where psc.size_fk=inv_compounds.package_size and inv_compounds.compound_id=inv_containers.compound_id_Fk and inv_containers.container_status_id_fk = 1 and inv_locations.location_id=inv_containers.location_id_fk and inv_units.unit_id=inv_containers.unit_of_meas_id_fk and compound_id="&compoundid


				if not LocationId=Null then
					PicklistSql=PickListSql & " and location_id= " & LocationId 
				end if
				PicklistSql=PickListSql & " group by location_name, container_qty_max, location_type_id_fk, location_id, unit_abreviation order by 1"

				%>
				<%= ShowPickList("", "LOCS"&compoundid, "",PicklistSql)%>
				
				<td align="left">
					<%=NDC%>
				<input type=hidden name="NDCC<%=compoundid%>" value="<%=NDC%>">
				</td>
				<td align="left">
					<%=CompoundName%>
					<input type=hidden name="COMP<%=compoundid%>" value="<%=CompoundId%>">
				</td>

				<td align="center">
				<%=PackageSize%>
				</td>

				<td align="left">
					<input type=text size=9 name="NEWA<%=compoundid%>" value="<%=Cdbl(qtyrequired)/containercount%>">
					<input type=hidden name="OLDA<%=compoundid%>" value="<%=Cdbl(qtyrequired)/containercount%>">
				</td>
				<%
					if request("targetlocationid")<>"" then
					targetSQL = " and location_type_id = " & request("targetlocationid")
					else
					targetSQL = ""
					end if
				%>
				<%= ShowPickList2("", "LOCT"&compoundid, request("targetlocationid"), "select location_id as value, location_name as displaytext from inv_locations, inv_location_types where location_type_id_fk=location_type_id " & targetSQL & " order by location_name", 25, " ","","")%>

				<td align="center">
				<input type=CheckBox name="DELI<%=compoundid%>" value="OK">
				</td>
				</tr>

			</span>

			<%rs.MoveNext
		Wend%>
			<tr>
				<td colspan="13" align="center">
					<a href="#" onclick="doIt();"><img border="0" src="../graphics/ok_dialog_btn.gif"></a>
				</td>
			</tr>
	</table>
<%	

	RS.Close
	Conn.Close
	Set RS = nothing
	Set Cmd = nothing
	Set Conn = nothing
End if
%>
</form>
</body>
</html>



