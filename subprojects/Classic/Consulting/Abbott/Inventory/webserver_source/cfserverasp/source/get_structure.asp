<%' Copyright 1999-2003 CambridgeSoft Corporation. All rights reserved
'DO NOT EDIT THIS FILE%>

<!--#INCLUDE VIRTUAL = "/cfserverasp/source/ado.inc"-->
<!--#INCLUDE VIRTUAL = "/cfserverasp/source/server_const_vbs.asp"-->
<!--#INCLUDE VIRTUAL = "/cfserverasp/source/search_func_vbs.asp"-->

<%on error resume next
	
	dbkey = request("dbname")
	formgroup= request("formgroup")
	table_name = request("table_name")
	column_name = request("column_name")
	mime_type = request("mime_type")
	unique_id = request("unique_id")
	base_column_name = request("base_column_name")

	set DataConn = getNewConnection(dbkey, formgroup, "base_connection")
	set cmd = server.CreateObject("adodb.command")
	set rs = server.CreateObject("adodb.recordset")

	cmd.ActiveConnection =  DataConn
	cmd.CommandType = adCmdText
	
	sql = "select " & column_name & " from " & table_name & " where " & base_column_name & "=?"
	cmd.CommandText = sql
	cmd.Parameters.Append cmd.CreateParameter("pID", 5, 1, 0, unique_id) 
	RS.Open cmd
	

	Set Field = RS.Fields(column_name)
	datatype = Field.type
	Select Case datatype
		case 205 'longvarbinary
			response.ContentType= "chemical/x-cdx"
			'Write the stream out
			BlockSize = 4096
			FileLength = Field.ActualSize
			NumBlocks = FileLength / BlockSize
			LeftOver = FileLength Mod BlockSize
			Response.Flush	
			Response.BinaryWrite  Field.GetChunk(LeftOver)
			For intLoop = 1 To NumBlocks
				Response.BinaryWrite Field.GetChunk(BlockSize)
			Next
			Response.end
		case 201, 203 'longvarchar
			
			response.ContentType= "chemical/x-cdx"
			BlockSize = 4096
			FileLength = Field.ActualSize
			NumBlocks = FileLength / BlockSize
			LeftOver = FileLength Mod BlockSize
			
			For intLoop = 1 To NumBlocks
				if str <> "" then
					str =str & Field.GetChunk(BlockSize)
				else
					str = Field.GetChunk(BlockSize)
				end if
			Next
			str =  str & Field.GetChunk(LeftOver)
			
			Response.clear
			Response.write str
			Response.end
	end select
	
	DataConn.close
	rs.Close
	
%>