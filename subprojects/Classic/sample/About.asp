<%@ LANGUAGE=VBScript%>
<HTML>
	<HEAD>
		<title>About</title>
		<%'Copyright 1999-2003 CambridgeSoft Corporation. All rights reserved
'DO NOT EDIT THIS FILE
dbkey = request("dbname")%>
	</HEAD>
	<body>
		<table border="1" bgcolor="#efefef" width="537">
			<tr>
				<td width="632"><table border="0" cellspacing="3" cellpadding="3" height="112" width="517">
						<tr>
							<td height="55" width="501" valign="center" align="left"><p align="left"><!--#INCLUDE VIRTUAL = "/cfserverasp/source/server_about_header.htm" --></p>
								<hr>
							</td>
						</tr>
						<tr>
							<td nowrap valign="center" align="left" width="501"></td>
						</tr>
						<tr>
							<td width="501"><table width="504">
									<TR>
										<TD vAlign="top" noWrap align="left" width="255" height="38">
											<P align="left"><FONT face="Arial"><STRONG>ChemOffice WebServer Version:</STRONG></FONT>&nbsp;
											</P>
										</TD>
										<TD vAlign="top" align="left" width="266"><%=Application("COWSVersion") %></TD>
									</TR>
									<tr>
										<td nowrap width="255" valign="top" align="left" rowspan="2"><font face="Arial"><strong>Application 
													Info: </strong></font>
										</td>
										<td valign="top" align="left" height="19" width="266"><font face="Arial"><%=Application("AboutWindow" & dbkey)%></font></td>
									
									
										<tr></tr><tr>
										<td nowrap width="255" valign="top" align="left" rowspan="2"><font face="Arial"></font>
										</td>
										<TD vAlign="center" noWrap align="left" width="266"><FONT face="Arial"><% if Application("DBType") = "RXN" then 
        Response.Write " Reactions: " 
        else 
        Response.Write " Compounds: "
        end if%>
												<%=Application("DBRecordCount"  & dbkey)%>
											</FONT>
										</TD>
									</TR>
								</table>
							</td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
	</body>
</HTML>
