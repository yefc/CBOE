<%@ Language=VBScript %>
<%'Copyright 1999-2003 CambridgeSoft Corporation. All rights reserved

'DO NOT EDIT THIS FILE%>

<%

	' Option Explicit

	' Set up the page attributes...
	Response.Buffer = True
	Response.Expires = 0
	
	Dim sThisStep
	Dim oConn, oCmd, oRS
	Dim sSQL, sCmd
	Dim i

	' Rest all variables to default values	
	if Request.QueryString("Reset") = "True" Then
		Session("DE_StepNumber") = "One"
		Session("DE_LastStepNumber") = ""
		Session("DE_BatchID") = ""
		Session("DE_ExperimentType") = ""
		Session("DE_ExperimentTypeName") = ""
		Response.Redirect("/<%=Application("AppKey")%>/analytics/AddExperiment.asp")
	end if
	
	' Go back to the previous step if possible!
	if Request.QueryString("Previous") = "True" Then
		Session("DE_StepNumber") = Session("DE_LastStepNumber")
		Response.Redirect("/<%=Application("AppKey")%>/analytics/AddExperiment.asp")
	end if
	
	' Set the default value for the first time into the application
	if Session("DE_StepNumber") = "" Then
		Session("DE_StepNumber") = "One"
	end if
	
	' Get a copy of the Session variable which will be updated by the various steps...
	sThisStep = Session("DE_StepNumber")
	
	Set oConn = Server.CreateObject("ADODB.Connection")
	Set oCmd = Server.CreateObject("ADODB.Command")
	Set oRS = Server.CreateObject("ADODB.Recordset")
	
	oConn.ConnectionString = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=D:\NAP\NAP.mdb;User ID=;Password=;"
	oConn.Open
	
	oCmd.ActiveConnection = oConn
	oCmd.CommandType = adCmdText
%>
<HTML>
<HEAD>
<META NAME="GENERATOR" Content="Microsoft Visual Studio 6.0">
<!--#INCLUDE VIRTUAL = "/cfserverasp/source/cows_func_js.asp"-->
</HEAD>
<body <%=Application("BODY_BACKGROUND") & """ bgProperties=fixed"%>>

<!--#INCLUDE VIRTUAL = "/cfserverasp/source/header_vbs.asp"-->
<%
'	if Request.QueryString("Previous") = "True" Then
'		Response.Write "Request.QueryString          : " & Request.QueryString & "<BR>"
'		Response.Write "Request.Form                 : " & Request.Form & "<BR>"
'		Response.Write "Session(""DE_StepNumber"")        : " & Session("DE_StepNumber") & "<BR>"
'		Response.Write "Session(""DE_LastStepNumber"")    : " & Session("DE_LastStepNumber") & "<BR>"
'	end if
%>
<% if Request.QueryString("Debug") = "True" Then %>
<P>
Request.QueryString          : "<%=Request.QueryString%>"<BR>
Request.Form                 : "<%=Request.Form %>"<BR>
Session("DE_StepNumber")        : "<%=Session("DE_StepNumber") %>"<BR>
Session("DE_LastStepNumber")    : "<%=Session("DE_LastStepNumber") %>"<BR>
Session("DE_BatchID")           : "<%=Session("DE_BatchID") %>"<BR>
Session("DE_ExperimentType")    : "<%=Session("DE_ExperimentType") %>"<BR>
Session("DE_ExperimentTypeName"): "<%=Session("DE_ExperimentTypeName") %>"<BR>
</P>
<% end if %>
<%
	If sThisStep = "One" Then
		' Update the LAST STEP variable at this point.
		Session("DE_LastStepNumber") = "One"
%>
<P><CENTER><H2>Step 1 of 4</H2><BR><H3>Provide a Batch ID and choose an Experiment Type</H3></CENTER></P>
<FORM METHOD="Post" ACTION="/<%=Application("AppKey")%>/analytics/AddExperiment.asp" ID="FormStep1" NAME="FormStep1">
Batch Number: <INPUT TYPE="text" NAME="CompoundID" VALUE="" SIZE="10"><BR>
Experiment  : <SELECT NAME="ExperimentType" SIZE="1">
<%
		oCmd.CommandText = "SELECT experiment_type_id, experiment_type_name from ExperimentType ; "
		Set oRS = oCmd.Execute
	
		if oRS.EOF=True and oRS.BOF=True then
			Response.Write "<FONT FACE=""Arial"" COLOR=""Red"" SIZE=""3"">No experiment types found</FONT><BR>"
		else
			' Set up the SELECT choices...
			i=0
			do while not oRS.EOF
				if i=0 then
					Response.Write "<OPTION SELECTED VALUE=" & oRS("experiment_type_id").Value & ">" & oRS("experiment_type_name").Value & "</OPTION>"
				else
					Response.Write "<OPTION VALUE=" & oRS("experiment_type_id").Value & ">" & oRS("experiment_type_name").Value & "</OPTION>"
				end if
				i=i+1
				oRS.MoveNext
			loop
		end if
		oRS.Close
		Set oRS = Nothing
		oConn.Close
		Set oConn = Nothing
		Set oCmd = Nothing
%>
</SELECT>
<INPUT TYPE="Submit" ID="Submit" NAME="Submit" VALUE="Submit">
<INPUT TYPE="Reset" ID="Reset" NAME="Reset" VALUE="Reset">
</FORM>
<%
		' Update the StepNumber variable here
		Session("DE_StepNumber") = "Two"
	elseif sThisStep = "Two" then
		' Update the LAST STEP variable at this point.
		Session("DE_LastStepNumber") = "One"
		
		' Now we check the Compound/Batch ID that has been submitted and
		' ensure that this is a valid entry in the database - otherwise we do not accept
		' the data and return the user to to the first screen
		Dim iCompoundID, iExperimentID
		
		' Pick up the BatchID from the form - or if we did a "Previous" get it from Storage
		if Request.Form("CompoundID") = "" then
			if Session("DE_BatchID") = "" then
				Response.Write "<FONT FACE=""Arial"" COLOR=""Red"" SIZE=""3"">Error: No BatchID specified.</FONT>"
				Response.Write "<P>Click <A HREF="""&  Application("appkey") & "/analytics/AddExperiment.asp?Reset=True"">here</A> to continue.</P>"
				
				if oRS.State = adStateOpen then oRS.Close
				Set oRS = Nothing
				Set oCmd = Nothing
				oConn.Close
				Set oConn = Nothing
				Response.End
			else
				iCompoundID = CLng(Session("DE_BatchID"))
			end if
		else
			iCompoundID = CLng(Request.Form("CompoundID"))
			Session("DE_BatchID") = Request.Form("CompoundID")
		end if
		
		sCmd = "SELECT MOL_ID, BATCH_ID, SUBSTANCE_ID, RO_NO FROM MolTable WHERE BATCH_ID = " & iCompoundID
		oCmd.CommandText = sCmd
		Set oRS = oCmd.Execute
		
		if oRS.EOF = True and oRS.BOF=True Then
			' No records found - not a valid Batch ID
			Response.Write "<FONT FACE=""Arial"" COLOR=""Red"" SIZE=""3"">Error: Batch ID " & Request.Form("CompoundID") & " is not valid for this database.</FONT>"
			Response.Write "<P>Click <A HREF="""&  Application("appkey") & "/analytics/AddExperiment.asp?Reset=True"">here</A> to continue.</P>"

			if oRS.State = adStateOpen then oRS.Close
			Set oRS = Nothing
			Set oCmd = Nothing
			oConn.Close
			Set oConn = Nothing
			Response.End
		else
			' Pick up the ExperimentTypeID from the form - or if we did a "Previous" get it from Storage
			if Request.Form("ExperimentType") = "" then
				if Session("DE_ExperimentType") = "" then
					Response.Write "<FONT FACE=""Arial"" COLOR=""Red"" SIZE=""3"">Error: No ExperimentType specified.</FONT>"
					Response.Write "<P>Click <A HREF="""&  Application("appkey") & "/analytics/AddExperiment.asp?Reset=True"">here</A> to continue.</P>"
					
					if oRS.State = adStateOpen then oRS.Close
					Set oRS = Nothing
					Set oCmd = Nothing
					oConn.Close
					Set oConn = Nothing
					Response.End
				else
					iExperimentID = CLng(Session("DE_ExperimentType"))
				end if
			else
				iExperimentID = CLng(Request.Form("ExperimentType"))
				Session("DE_ExperimentType") = Request.Form("ExperimentType")
			end if

			oRS.Close
			sCmd = "SELECT experiment_type_name FROM ExperimentType WHERE experiment_type_id = " & iExperimentID
			oCmd.CommandText = sCmd
			Set oRS = oCmd.Execute
			if oRS.EOF = True and oRS.BOF=True Then
				Response.Write "<FONT FACE=""Arial"" COLOR=""Red"" SIZE=""3"">Error Finding Experiment Type Name from ID</FONT><BR>"
				Response.Write "<P>Click <A HREF="""&  Application("appkey") & "/analytics/AddExperiment.asp?Reset=True"">here</A> to continue.</P>"

				if oRS.State = adStateOpen then oRS.Close
				Set oRS = Nothing
				Set oCmd = Nothing
				oConn.Close
				Set oConn = Nothing
				Response.End
			else
				Session("DE_ExperimentTypeName") = oRS("experiment_type_name").Value
				oRS.Close
			end if
		end if		
	
%>
<P><CENTER><H2>Step 2 of 4</H2><BR><H3>Enter experimental data</H3></CENTER></P>
<FORM ACTION="/<%=Application("AppKey")%>/analytics/AddExperiment.asp" ID="Form3" METHOD="POST">
<TABLE WIDTH="600" BORDER="1" BGCOLOR="Silver" BORDERCOLOR="Navy" CELLSPACING="1" CELLPADDING="2">
<TR>
<TH COLSPAN="2"><FONT FACE="Arial" SIZE="3" COLOR="White">Batch ID: "<%=Session("DE_BatchID") %>"</FONT></TH>
<TH COLSPAN="2"><FONT FACE="Arial" SIZE="3" COLOR="White">Experiment Type: "<%=Session("DE_ExperimentTypeName") %>"</FONT></TH>
</TR>
<TR>
	<TD WIDTH="50%"><FONT FACE="Arial" SIZE="2" COLOR="Black">Date</FONT></TD><TD><INPUT TYPE="Text" NAME="ExperimentDate" VALUE="<% Response.Write Date %>" SIZE="10"></TD>
	<TD WIDTH="50%"><FONT FACE="Arial" SIZE="2" COLOR="Black">Location</FONT></TD><TD><INPUT TYPE="Text" NAME="ExperimentLocation" VALUE="<Where?>" SIZE="20"></TD>
</TR><TR>
	<TD WIDTH="50%"><FONT FACE="Arial" SIZE="2" COLOR="Black">Reference</FONT></TD><TD><INPUT TYPE="Text" NAME="ExperimentReference" VALUE="<Reference>" SIZE="20"></TD>
	<TD WIDTH="50%"><FONT FACE="Arial" SIZE="2" COLOR="Black">Comment</FONT></TD><TD><INPUT TYPE="Text" NAME="ExperimentComment" VALUE="<Comment>" SIZE="30"></TD>
</TR>
</TABLE>
<%	
		' Enclose the whole of the Parameters and Results table with an enclosing TABLE
		Response.Write "<TABLE WIDTH=""600"" BORDER=""1"" BGCOLOR=""Silver"" BORDERCOLOR=""Navy"" CELLSPACING=""1"" CELLPADDING=""2"">"
		Response.Write "<TR><TD WIDTH=""50%"" VALIGN=""top"">"
		
		' Now look up what the parameters should be...
		sCmd = "SELECT ExperimentType.experiment_type_id, ParameterType.parameter_type_id, ExperimentType.experiment_type_name, ParameterType.parameter_type_name, ParameterType.parameter_type_units"
		sCmd = sCmd & " FROM ParameterType INNER JOIN (ExperimentType INNER JOIN ExperimentTypeParameters ON ExperimentType.experiment_type_id = ExperimentTypeParameters.experiment_type_id) ON ParameterType.parameter_type_id = ExperimentTypeParameters.parameter_type_id"
		sCmd = sCmd & " WHERE ExperimentType.experiment_type_id = " & CLng(Session("DE_ExperimentType"))
		sCmd = sCmd & " ORDER BY ExperimentType.experiment_type_id, ParameterType.parameter_type_id ;"
		oCmd.CommandText = sCmd
	
		Set oRS = oCmd.Execute

		' Now look at the parameters defined for this experiment and set up the input table
		if oRS.EOF=True and oRS.BOF=True then
			Response.Write "<FONT FACE=""Arial"" COLOR=""Red"" SIZE=""3"">No data found on experiment_type " & CLng(Session("DE_ExperimentType")) & "</FONT><BR>"
			Response.Write "sCmd was: """ & sCmd & """<BR>"
		else
			' Get the parameter values
			i=1
			Response.Write "<TABLE BORDER=""0"">"
			Response.Write "<TR><TH COLSPAN=""3""><FONT FACE=""Arial"" SIZE=""3"" COLOR=""Navy"">Parameters</FONT></TH></TR>"
			do while not oRS.EOF = True
				Response.Write "<TR><TD WIDTH=""25%""><FONT FACE=""Arial"" SIZE=""2"" COLOR=""Black"">" & oRS("parameter_type_name").value & "&nbsp;</FONT></TD>"
				Response.Write "<TD WIDTH=""65%""><INPUT TYPE=""Text"" NAME=""Param_" & oRS("parameter_type_id").Value & """ SIZE=""20""></TD>"
				Response.Write "<TD WIDTH=""10%""><FONT FACE=""Arial"" SIZE=""2"" COLOR=""Black"">" & oRS("parameter_type_units").Value & "&nbsp;</FONT></TD></TR>"
				i=i+1
				oRS.MoveNext
			loop
			
			Response.Write "</TABLE>"
		end if

		Response.Write "</TD><TD WIDTH=""50%"" VALIGN=""top"">" ' This is the enclosing table for results and Parameters
		
		' Now look up what the RESULTS should be...
		sCmd = "SELECT ExperimentType.experiment_type_id, ResultType.result_type_id, ExperimentType.experiment_type_name, ResultType.result_type_name, ResultType.result_type_units"
		sCmd = sCmd & " FROM ResultType INNER JOIN (ExperimentType INNER JOIN ExperimentTypeResults ON ExperimentType.experiment_type_id = ExperimentTypeResults.experiment_type_id) ON ResultType.result_type_id = ExperimentTypeResults.result_type_id"
		sCmd = sCmd & " WHERE ExperimentType.experiment_type_id = " & CLng(Session("DE_ExperimentType"))
		sCmd = sCmd & " ORDER BY ExperimentType.experiment_type_id, ResultType.result_type_id ;"
		oCmd.CommandText = sCmd
	
		Set oRS = oCmd.Execute

		' Now look at the Results defined for this experiment and set up the rest of the input table
		if oRS.EOF=True and oRS.BOF=True then
			Response.Write "<FONT FACE=""Arial"" COLOR=""Red"" SIZE=""3"">No data found on experiment_type " & CLng(Session("DE_ExperimentType")) & "</FONT><BR>"
			Response.Write "sCmd was: """ & sCmd & """<BR>"
		else
			' Get the result values
			i=1
			Response.Write "<TABLE BORDER=""0"">"
			Response.Write "<TR><TH COLSPAN=""3""><FONT FACE=""Arial"" SIZE=""3"" COLOR=""Navy"">Results</FONT></TH></TR>"
			do while not oRS.EOF = True
				Response.Write "<TR><TD WIDTH=""25%""><FONT FACE=""Arial"" SIZE=""2"" COLOR=""Black"">" & oRS("result_type_name").value & "&nbsp;</FONT></TD>"
				Response.Write "<TD WIDTH=""65%""><INPUT TYPE=""Text"" NAME=""Result_" & oRS("result_type_id").Value & """ SIZE=""20""></TD>"
				Response.Write "<TD WIDTH=""10%""><FONT FACE=""Arial"" SIZE=""2"" COLOR=""Black"">" & oRS("result_type_units").Value & "&nbsp;</FONT></TD></TR>"
				i=i+1
				oRS.MoveNext
			loop
			Response.Write "</TABLE>"
		end if

		Response.Write "</TD></TR></TABLE>" ' This is the enclosing table for Results and Parameters

		Response.Write "<P><INPUT TYPE=""Submit"" ID=""Submit"" NAME=""Submit"" VALUE=""Submit""></P>"
		Response.Write "</FORM>"

		oRS.Close
		Set oRS = Nothing
		oConn.Close
		Set oConn = Nothing
		Set oCmd = Nothing

		' Update the Step Number variable
		Session("DE_StepNumber") = "Three"
	elseif sThisStep = "Three" then
		' Update the LAST STEP variable at this point.
		Session("DE_LastStepNumber") = "Two"

		Response.Write "<P><CENTER><H2>Step 3 of 4</H2><BR><H3>Process the data</H3></CENTER></P>"

		' At this stage we have got Parameters and Results being passed in as part
		' of the Request.Form object - they are identified as "Param_<ID>" - need to
		' parse these off the Request.Form...
		Dim x, spID, seID
		Dim sLocation, sDate, sComment, sReference

		' Make sure we don't have any problem with NULL strings
		sLocation = Request.Form("ExperimentLocation") & ""
		sDate = Request.Form("ExperimentDate") & ""
		sComment = Request.Form("ExperimentComment") & ""
		sReference = Request.Form("ExperimentReference") & ""

		' First we need to insert a new experiment into the Experiments table and
		' retrieve the resulting experiment_id
		sCmd = "INSERT INTO [Experiments](experiment_type_id, experiment_batch_id, experiment_location, experiment_date, experiment_comment, experiment_reference) VALUES ( "
		sCmd = sCmd & CLng(Session("DE_ExperimentType")) & ", " & CLng(Session("DE_BatchID"))
		sCmd = sCmd & ", '" & sLocation & "', #" & sDate & "#, '" & sComment & "', '" & sReference & "' ) ;"
		oCmd.CommandText = sCmd
		
		' Response.Write "<BR>sCmd: """ & sCmd & """<BR>"
		
		oCmd.Execute
		
		' Perhaps we should use the ADO updateabe recordset object to do this as we can then retrieve
		' the ID more easily...
		sCmd = "SELECT MAX(experiment_id) AS theID FROM Experiments ; "
		oCmd.CommandText = sCmd
		Set oRS = oCmd.Execute
		' seID = CLng(oRS("theID").Value)
		seID = oRS("theID").Value
		' Response.Write "New Experiment ID: " & seID & "<BR>"
		Session("DE_ExperimentID") = seID
		
		For Each x In Request.Form
			' Response.Write "Form element " & x & ": " & Request.Form(x) & "<BR>"
			
			if Left(x, 6) = "Param_" then
				' Get the Parameter ID from the string
				spID = Mid(x, 7)
			
				' Response.Write "Parameter ID: " & spID & "<BR>"
				' Response.Write "Experiment ID: " & seID & "<BR>"
				' Response.Write "Parameter Value: " & Request.Form(x) & "<BR>"
				
				' Add a record to the Parameters Table with all of the data as specified...
				
				if Request.Form(x) = "" then
					Response.Write "<FONT FACE=""Arial"" COLOR=""Red"" SIZE=""3"">Error: No value provided for " & x & " You must provide a value for all Parameters</FONT><BR>"
				else
					sCmd = "INSERT INTO [Parameters](parameter_type_id, parameter_value, parameter_experiment_id ) VALUES ( "
					sCmd = sCmd & CLng(spID) & ", '" & Request.Form(x) & "', " & seID & " ) ;"
					oCmd.CommandText = sCmd
					oCmd.Execute
				
					Response.Write "<FONT FACE=""Arial"" COLOR=""Green"" SIZE=""2"">Added data for " & x & " to Parameters table</FONT><BR>"
				end if
			elseif Left(x, 7) = "Result_" then
				' Get the Result ID from the string
				spID = Mid(x, 8)
			
				' Response.Write "Result ID: " & spID & "<BR>"
				' Response.Write "Experiment ID: " & seID & "<BR>"
				' Response.Write "Result Value: " & Request.Form(x) & "<BR>"
				
				' Add a record to the Results Table with all of the data as specified...
				if Request.Form(x) = "" then
					Response.Write "<FONT FACE=""Arial"" COLOR=""Red"" SIZE=""3"">Error: No value provided for " & x & " You must provide a value for all Results</FONT><BR>"
				else
					sCmd = "INSERT INTO [Results](result_type_id, result_value, result_experiment_id ) VALUES ( "
					sCmd = sCmd & CLng(spID) & ", '" & Request.Form(x) & "', " & seID & " ) ;"
					oCmd.CommandText = sCmd
					oCmd.Execute
				
					Response.Write "<FONT FACE=""Arial"" COLOR=""Green"" SIZE=""2"">Added data for " & x & " to Results table</FONT><BR>"
				end if
			end if
		next

		if oRS.State = adStateOpen Then oRS.Close
		Set oRS = Nothing
		Set oCmd = Nothing
		oConn.Close
		Set oConn= Nothing
		
		' Update the step number variable
		Session("DE_StepNumber") = "Four"
		
		' Automatically step to the results display
		' Response.Redirect("/<%=Application("AppKey")%>/analytics/AddExperiment.asp")
	elseif sThisStep = "Four" then
		' Update the LAST STEP variable at this point. Need to step back to Step 2 at this point.
		Session("DE_LastStepNumber") = "Two"

		Response.Write "<P><CENTER><H2>Step 4 of 4</H2><BR><H3>Data entry complete</H3></CENTER></P>"

		' This is the end of the line - now we should display the results of having added this data to 
		' the various tables..
		
		' sCmd = "SELECT Experiments.experiment_id, Experiments.experiment_batch_id, ExperimentType.experiment_type_name, ResultType.result_type_name, Results.result_value, ResultType.result_type_units, ParameterType.parameter_type_name, Parameters.parameter_value, ParameterType.parameter_type_units"
		' sCmd= sCmd & " FROM ResultType INNER JOIN ((ParameterType INNER JOIN ((ExperimentType INNER JOIN Experiments ON ExperimentType.experiment_type_id = Experiments.experiment_type_id) INNER JOIN [Parameters] ON Experiments.experiment_id = Parameters.parameter_experiment_id) ON ParameterType.parameter_type_id = Parameters.parameter_type_id) INNER JOIN Results ON Experiments.experiment_id = Results.result_experiment_id) ON ResultType.result_type_id = Results.result_type_id"
		' sCmd= sCmd & " WHERE Experiments.experiment_id = " & Session("DE_ExperimentID") & " ;"
		
		sCmd = "SELECT Experiments.experiment_batch_id, Experiments.experiment_id, ExperimentType.experiment_type_name, Experiments.experiment_date, Experiments.experiment_location, Experiments.experiment_comment, Experiments.experiment_reference"
		sCmd = sCmd & " FROM ExperimentType INNER JOIN Experiments ON ExperimentType.experiment_type_id = Experiments.experiment_type_id"
		sCmd = sCmd & " WHERE Experiments.experiment_id = " & Session("DE_ExperimentID") & " ;"
		oCmd.CommandText = sCmd
		Set oRS = oCmd.Execute
		
		if oRS.BOF = True and oRS.EOF = True Then
			Response.Write "<FONT FACE=""Arial"" COLOR=""Red"" SIZE=""3"">Error - no details found for Experiment ID: " & Session("DE_ExperimentID") & "</FONT><BR>"
		else
			' Display the header information...
			Response.Write "<P><TABLE BORDER=""1""><TR>"
			Response.Write "<TH>Batch ID</TH>"
			Response.Write "<TH>Experiment ID</TH>"
			Response.Write "<TH>Experiment Type</TH>"
			Response.Write "<TH>Date</TH>"
			Response.Write "<TH>Location</TH>"
			Response.Write "<TH>Reference</TH>"
			Response.Write "<TH>Comment</TH></TR>"
			Response.Write "<TD>" & oRS("experiment_batch_id").Value & "</TD>"
			Response.Write "<TD>" & oRS("experiment_id").Value & "</TD>"
			Response.Write "<TD>" & oRS("experiment_type_name").Value & "</TD>"
			Response.Write "<TD>" & oRS("experiment_date").Value & "</TD>"
			Response.Write "<TD>" & oRS("experiment_location").Value & "</TD>"
			Response.Write "<TD>" & oRS("experiment_reference").Value & "</TD>"
			Response.Write "<TD>" & oRS("experiment_comment").Value & "</TD></TR>"
			Response.Write "</TABLE></P>"
		end if
		
		oRS.Close
		Set oRS = Nothing

		Response.Write "<P><TABLE BORDER=""1""><TR><TH>Parameters</TH><TH>Results</TH></TR><TR><TD>"
		
		' Get the Parameter information using the correct Experiment ID
		sCmd = "SELECT Experiments.experiment_id, ParameterType.parameter_type_name, Parameters.parameter_value, ParameterType.parameter_type_units"
		sCmd = sCmd & " FROM ParameterType INNER JOIN (Experiments INNER JOIN [Parameters] ON Experiments.experiment_id = Parameters.parameter_experiment_id) ON ParameterType.parameter_type_id = Parameters.parameter_type_id"
		sCmd = sCmd & " WHERE Experiments.experiment_id = " & Session("DE_ExperimentID") & " ;"
		oCmd.CommandText = sCmd
		Set oRS = oCmd.Execute
		
		if oRS.BOF = True and oRS.EOF = True Then
			Response.Write "<FONT FACE=""Arial"" COLOR=""Red"" SIZE=""3"">Error - no Parameters found for Experiment ID: " & Session("DE_ExperimentID") & "</FONT><BR>"
		else
			' get the results and display in a Tabular form...
			Response.Write "<TABLE BORDER=""1""><TR>"
			Response.Write "<TH>Parameter</TH>"
			Response.Write "<TH>Value</TH>"
			Response.Write "</TR>"
			do while not oRS.EOF = True
				'Get the data for this row
				Response.Write "<TR>"
				Response.Write "<TD>" & oRS("parameter_type_name").Value & "</TD>"
				Response.Write "<TD>" & oRS("parameter_value").Value & "</TD>"
				Response.Write "</TR>"
				oRS.MoveNext
			loop
			
			Response.Write "</TABLE>"
		end if

		Response.Write "</TD><TD>"
		
		if oRS.State = adStateOpen Then oRS.Close
		Set oRS = Nothing

		' Get the Result information using the correct Experiment ID
		sCmd = "SELECT Experiments.experiment_id, ResultType.result_type_name, Results.result_value, ResultType.result_type_units"
		sCmd = sCmd & " FROM ResultType INNER JOIN (Experiments INNER JOIN [Results] ON Experiments.experiment_id = Results.result_experiment_id) ON ResultType.result_type_id = Results.result_type_id"
		sCmd = sCmd & " WHERE Experiments.experiment_id = " & Session("DE_ExperimentID") & " ;"
		oCmd.CommandText = sCmd
		Set oRS = oCmd.Execute
		
		if oRS.BOF = True and oRS.EOF = True Then
			Response.Write "<FONT FACE=""Arial"" COLOR=""Red"" SIZE=""3"">Error - no Results found for Experiment ID: " & Session("DE_ExperimentID") & "</FONT><BR>"
		else
			' get the results and display in a Tabular form...
			Response.Write "<TABLE BORDER=""1""><TR>"
			Response.Write "<TH>Result</TH>"
			Response.Write "<TH>Value</TH>"
			Response.Write "</TR>"
			do while not oRS.EOF = True
				'Get the data for this row
				Response.Write "<TR>"
				Response.Write "<TD>" & oRS("result_type_name").Value & "</TD>"
				Response.Write "<TD>" & oRS("result_value").Value & "</TD>"
				Response.Write "</TR>"
				oRS.MoveNext
			loop
			
			Response.Write "</TABLE>"
		end if

		Response.Write "</TD></TR></TABLE></P>"

		'Response.Write "<P><A HREF="""&  Application("appkey") & "/analytics/Giv_Test.asp?BatchID=" & Session("DE_BatchID") & """>Review All Batch Data</A></P>"
		if oRS.State = adStateOpen Then oRS.Close
		Set oRS = Nothing

		Set oCmd = Nothing
		oConn.Close
		Set oConn= Nothing

		' Update the Step Number variable
		Session("DE_StepNumber") = "Done"

	elseif sThisStep = "Done" then
		' Reset the Session
		Response.Redirect "/" & Application("appkey") & "/analytics/AddExperiment.asp?Reset=True"
		
		' Really we need to return to the ResultList page here...
	else
		' No records found - not a valid Batch ID
		Response.Write "<FONT FACE=""Arial"" COLOR=""Red"" SIZE=""3"">Error: Undefined step number!</FONT>"
		Response.Write "<P>Click <A HREF="""&  Application("appkey") & "/analytics/AddExperiment.asp?Reset=True"">here</A> to continue.</P>"
	end if
%>
<%
'	Response.Write "Session(""DE_StepNumber"")        : " & Session("DE_StepNumber") & "<BR>"
'	Response.Write "Session(""DE_LastStepNumber"")    : " & Session("DE_LastStepNumber") & "<BR>"
'	Response.Write "sThisStep                         : " & sThisStep & "<BR>"
%>

<TABLE><TR><TH COLSPAN="3">Navigation</TH></TR>
<TR><TD><A HREF="/<%=Application("appkey")%>/analytics/AddExperiment.asp?reset=True">Reset</A></TD>
<TD><A HREF="/<%=Application("appkey")%>/analytics/AddExperiment.asp?Previous=True">Go to previous stage</A></TD>
<TD><A HREF="/<%=Application("appkey")%>/analytics/AddExperiment.asp">Go to next stage</A></TD>
</TR></TABLE>
<!--#INCLUDE VIRTUAL = "/cfserverasp/source/input_form_footer_vbs.asp"-->
</BODY>
</HTML>
