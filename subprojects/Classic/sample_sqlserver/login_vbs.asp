<%	'Copyright 1999-2003 CambridgeSoft Corporation. All rights reserved
Function DoUserValidate(dbkey, formgroup, appType, baseTable, UserName)
	Session("Edit_ID_Restrictions" & dbkey)= ""
	Session("LoginErrorMessage" & dbkey)= ""
	Set DataConn = GetConnection(dbkey, formgroup, basetable)
	if UCase(appType) = "REGISTRATION" then
		privTable= Application("AppKey") & "_Privileges"
		isValidUser = 0
		isValidUser = ValidateUser(dbkey, DataConn)
		if isValidUser>0 then
			roles_id_str = GetGrantedRoles(dbkey, DataConn,privTable)
			if roles_id_str <> "" then 
				isOk = SetPrivilegeFlags(dbkey, DataConn, roles_id_str)
				if isOk = "" then
					isOK = SetRestrictEdit(dbkey, DataConn, UserName)
					if isOk = "" then
						fullyValidated = 1
					else
						Session("LoginErrorMessage" & dbkey) = isOk
						fullyValidated = 0
					end if
				else
					Session("LoginErrorMessage" & dbkey) = isOk
				end if
				
			else
				fullyValidated = 0
				Session("LoginErrorMessage" & dbkey) = "no chemical registration roles assigned to user"
			end if
		else
			fullyValidated = 0
		end if
	Else ' non_reg system
		isValidUser = -1
		isValidUser = ValidateUser(dbkey, DataConn)
		if isValidUser > 0 then
			fullyValidated = 1
		end if
	end if
	
	

	
	DoUserValidate=fullyValidated
End Function

Function ValidateUser(dbkey, ByRef DataConn)
	Session("LoginErrorMessage" & dbkey) = ""	
	userValid = -1 'assume failed
	if DataConn.State = 1 then
		userValid = 1
	else
		userValid = -1
		Session("LoginErrorMessage" & dbkey) = "Invalid User Name or User ID"	
	end if
		ValidateUser = userValid
End Function


Function GetGrantedRoles(byVal dbkey, ByRef DataConn, ByVal privName)

	GetSecurityLevel = 0	' assume failure
	' look for user in security table
	Set secRst = Server.CreateObject("ADODB.Recordset")	
	secRst.CursorType = adOpenForwardOnly
	secRst.LockType = adLockReadOnly
	'get role names from security levels table
	'secSQL = "Select * from security_roles, privilege_tables where security_roles.privilege_table_int_id = privilege_tables.privilege_table_id AND Upper(privilege_tables.privilege_table_name) ='" & UCase(privName) & "' order by security_roles.role_id desc"
	secSQL = "Select * from security_roles, privilege_tables where security_roles.privilege_table_int_id = privilege_tables.privilege_table_id AND Upper(privilege_tables.privilege_table_name) ='" & UCase(privName) & "' order by security_roles.role_id desc"
	
	on error resume next
	secRst.Open secSQL, DataConn
	if DataConn.Errors.Count > 0 then
	Session("LoginErrorMessage" & dbkey)= "user does not have any access to chemical registration tables"
	exit function
	end if
	on error goto 0
	if NOT (secRst.BOF AND secRst.EOF)then
		secRst.MoveFirst
		Do While Not secRst.EOF
			if sec_level_str <> "" then
				sec_level_str  = sec_level_str & "," & secRst("Role_Name")
			else
				sec_level_str  = secRst("Role_Name")
			end if
			sec_level_array = split(sec_level_str, ",", -1)
		secRst.MoveNext
		loop
		secRst.Close
	end if
	'get roles_granted from oracle user_role_privs table AND determine highest level granted
	rol_name = ""
	for i = 0 to UBound(sec_level_array)
	secSQL = "Select * from user_role_privs where Upper(username)='" & UCase(Session("UserName" & dbkey)) & "' AND Upper(Granted_Role) =" & "'" & UCase(sec_level_array(i)) & "'"
	on error resume next
		Set secRst = DataConn.Execute(secSQL)
		if DataConn.Errors.Count > 0 then
			Session("LoginErrorMessage" & dbkey)= "user does not have any access to chemical registration tables"
		exit function
		end if
		on error goto 0
		if Not (secRst.BOF AND secRst.EOF) then
			secRst.MoveFirst
			if role_list <> "" then
				role_list = role_list & "," & "'" & secRst("Granted_Role") & "'"
			else
				role_list = "'" & secRst("Granted_Role") & "'"
			end if
			secRst.close
		end if
	next
	'convert list to IDS
	if inStr(role_list, ",")> 0 then
		secSQL ="select * from security_roles where Upper(role_name) in (" & UCase(role_list) & ")"
	else
		secSQL ="select * from security_roles where Upper(role_name) = " & UCase(role_list)
	end if
	on error resume next
	Set secRst = DataConn.Execute(secSQL)
		if DataConn.Errors.Count > 0 then
			Session("LoginErrorMessage" & dbkey)= "user does not have any access to chemical registration tables"
		exit function
		end if
		on error goto 0
		if Not (secRst.BOF AND secRst.EOF) then
			secRst.MoveFirst
			Do While Not secRst.EOF
				if role_id_list <> "" then
					role_id_list = role_id_list & ","  & secRst("role_id")
				else
					role_id_list =  secRst("role_id")
				end if
				secRst.MoveNext
			loop
			secRst.close
		end if
	if Not role_id_list <> "" then
		Session("LoginErrorMessage" & dbkey)= "no role is assigned for to the user name entered"
	end if
	CloseRS(secRst)	
	GetGrantedRoles = role_id_list
End Function



Sub SetDefaultFlags(dbkey, ByRef DataConn)
	secSQL = "Select * from " & Application("AppKey") & "_Privileges"
	Set RS = DataConn.Execute(secSQL)
		if Not(RS.BOF AND RS.EOF) THEN
			for each field in rs.fields
				theVarName = field.name
				Session(theVarName & dbkey)= False
			next
			RS.close
		end if
	Set RS = Nothing

End Sub
Function SetPrivilegeFlags(dbkey,ByRef DataConn, roles_granted_ids)
	ErrorsOccurred = ""
	SetDefaultFlags dbkey, DataConn
	roles_granted_ids_array=split(roles_granted_ids, ",", -1)
	For i = 0 to UBound(roles_granted_ids_array)	
		secSQL = "Select * from " & Application("AppKey") & "_Privileges  where role_internal_id=" & roles_granted_ids_array(i)
		Set RS = DataConn.Execute(secSQL)
		if Not(RS.BOF AND RS.EOF) THEN
			for each field in rs.fields
				theVarName = field.name
				theValue = field.value
					If CBool(RS(theVarName))= True then 
						Session(theVarName & dbkey)= True
					end if
					'VarDump dbkey, roles_granted_ids_array(i),theVarName,Session(theVarName & dbkey)
			next
			RS.close
		else
		ErrorsOccurred = "role_name not valid:  " & secSQL
		end if
	next	
	SetPrivilegeFlags=ErrorsOccurred	
End Function



Sub VarDump(dbkey, role_id, theVarName, theValue)
		Response.write role_id & ":" & theVarName & ":" & theValue
end sub


function SetRestrictEdit(dbkey, DataConn, UserName)
	ErrorsOccurred= ""
	theIDs = -1 ' assume no edit
	if Session("Edit_Scope_All" & dbkey) = True then
		theIDS = 0
		ErrorsOccurred = ""
		Session("EditRestrictIDs" & dbkey)= theIDs
		SetRestrictEdit = ErrorsOccurred
		exit function
	end if

	if Session("Edit_Scope_Supervisor" & dbkey) = True then
	
		secSQL = "Select person_id from people where Upper(user_id)='" & UCase(UserName) & "'"
		Set RSp = DataConn.Execute(secSQL)
		
		If Not (RSp.BOF AND RSp.EOF) then
			selfID = RSp("person_id")
			RSp.Close
		else
			ErrorsOccurred = "No user found in peoples table for user name: " & UserName
			Session("EditRestrictIDs" & dbkey)= theIDs
			SetRestrictEdit = ErrorsOccurred
			exit function
		end if
		secSQL = "Select person_id from people where supervisor_internal_id =" & selfID
		Set RSp = DataConn.Execute(secSQL)
		If Not (RSp.BOF AND RSp.EOF) then
			theIDs =""
			RSp.MoveFirst
			Do While Not RSp.EOF
				userID = RSp("person_id")
				if not CInt(userID) = CInt(selfID) then
					if theIDS <> "" then
						theIDs = theIDS & "," & userID
					else
						theIDS = userID
					end if
				end if
				RSp.MoveNext
			loop
				if theIDS <> "" then
					theIDs = theIDS & "," & selfID
				else
					theIDS = selfID
				end if
			RSp.Close
		else
			theIDS = selfID			
		end if
		Set RSp = Nothing
		Session("EditRestrictIDs" & dbkey)= theIDs
		SetRestrictEdit = ErrorsOccurred
		exit function
	end if
	
	if Session("Edit_Scope_Self" & dbkey) = True then
		secSQL = "Select person_id from people where Upper(user_id)='" & UCase(UserName) & "'"
		Set RSp = DataConn.Execute(secSQL)
		If Not (RSp.BOF AND RSp.EOF) then
			RSp.MoveFirst
			theIDs = RSp("person_id") 
			RSp.Close
		else
			ErrorsOccurred = "No person found in peoples table having user name: " & UserName
		end if
		Set RSp = Nothing
		Session("EditRestrictIDs" & dbkey)= theIDs
		SetRestrictEdit = ErrorsOccurred
		exit function
	end if
Session("EditRestrictIDs" & dbkey)= theIDs
SetRestrictEdit=ErrorsOccurred
end function 


%>

