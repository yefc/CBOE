<%IF CBool(Application("SHOW_ACX_LOOKUP_LINK")) then %>
<a href="#" onclick="document.acxPost.submit();return false" class="MenuLink">ACX Lookup</a>
<%end if%>
<%
bMSDXShowLink = false
if CBool(Application("SHOW_MSDX_LOOKUP_LINK")) AND (Application("ACXServerName") <> "NULL") then
	If isNull(SupplierID) then SupplierID = 0	
	if len(CAS)>0 OR (len(SupplierCatNum) >0  AND CLng(SupplierID) > 0) then
		bHasMSDX = -1
		if Application("MSDX_LOOK_AHEAD") then bHasMSDX = HasMSDX(CAS, SupplierID, SupplierCatNum)
		Response.Write "<BR>"
		ShowMSDXLink CAS, SupplierID, SupplierCatNum, bHasMSDX
	End if	
End if
bMSDSShowLink = false
if CBool(Application("SHOW_MSDS_LOOKUP_LINK")) AND (Application("ACXServerName") <> "NULL") then
	If isNull(SupplierID) then SupplierID = 0	
	if len(CAS)>0 OR (len(SupplierCatNum) >0  AND CLng(SupplierID) > 0) then
		bHasMSDS = -1
		if Application("MSDS_LOOK_AHEAD") then bHasMSDS = HasMSDS(CAS, SupplierID, SupplierCatNum)
		Response.Write "<BR>"
		ShowMSDSLink CAS, SupplierID, SupplierCatNum, bHasMSDS
	End if	
End if
%>
<BR>



