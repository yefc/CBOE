<%@ EnableSessionState=True Language=VBScript%>
<%
QS = Request.QueryString
'ft = Request("ft")
'if ft = "" then ft = "std"
if Request("filter") = "true" then
	dispSrc = "CycleCounts_display.asp?" & QS
Else
	dispSrc = "blank.html"
End if	
	
%>
<html>
<head>
<title><%=Application("appTitle")%> -- Manage Cycle Counts</title>
<SCRIPT LANGUAGE=javascript>
<!--
window.focus()
//-->
</SCRIPT>

</head>

<frameset rows="180,*">
		<frame name="ActionFrame" src="CycleCounts_filter.asp?<%=QS%>" MARGINWIDTH="1" MARGINHEIGHT="1" SCROLLING="no">
		<frame name="DisplayFrame" src="<%=dispSrc%>" MARGINWIDTH="1" MARGINHEIGHT="1" SCROLLING="auto">
</frameset>

</html>
