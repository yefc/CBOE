<%
Response.expires=0
'Copyright CambridgeSoft Corporation 1998-2001 all rights reserved
if Not Session("UserValidated" & "cheminv") = 1 then
	response.redirect "login.asp?dbname=cheminv&formgroup=containers_form_group&perform_validate=0"
end if
if Request.QueryString("TB") <> "" then
	Session("ssTab") = Request("TB").QueryString
end if
dbkey = Request("dbname")
formgroup = Request("formgroup")
if( IsEmpty( formgroup ) ) then
    formgroup = Session("formgroup")
end if
formmode = Request("formmode")
if( IsEmpty( formmode ) ) then
    formmode = Session("formmode")
end if
returnaction = Request("returnaction")
'if Not IsEmpty(Session("ssTab")) AND (formgroup <> "substances_form_group" or formgroup <> "substances_np_form_group") AND formgroup <> "global_substanceselect_form_group" then

'-- set default search tab
if isEmpty(Session("ssTab")) and Application("DEFAULT_SEARCH_TAB") <> "" then
    Session("ssTab") = Application("DEFAULT_SEARCH_TAB")
end if
if isEmpty(Session("ssTab")) then
    Session("ssTab") = "simple"    
end if

if Not IsEmpty(Session("ssTab")) AND formgroup <> "substances_form_group" AND formgroup <> "substances_np_form_group" AND formgroup <> "global_substanceselect_form_group" and formgroup <> "global_substanceselect_np_form_group" then
	Select Case lcase(Session("ssTab"))
		Case "substructure"
			formgroup = "base_form_group"
		Case "advanced","simple"
			formgroup = "containers_np_form_group"
		Case "batches"
			if Session("isCDP") = "TRUE" then
				formgroup = "batches_form_group"	
			else
				formgroup = "batches_np_form_group"	
			end if
		Case "plate"
			if Session("isCDP") = "TRUE" then
				formgroup = "plates_form_group"	
			else
				formgroup = "plates_np_form_group"	
			end if
		Case "global"
			if Session("isCDP") = "TRUE" then
				formgroup = "gs_form_group"
			else
				formgroup = "gs_np_form_group"
			end if		
	End Select
Else	
	if formgroup = "" then 
		formgroup = "containers_np_form_group"
		Session("ssTab") = "simple"
	end if
End if

if formgroup = "global_substanceselect_form_group" then
	if Session("isCDP") <> "TRUE" then
		formgroup = "global_substanceselect_np_form_group"	
	end if
end if

ShowBanner = Request.QueryString("ShowBanner")
if IsEmpty(Showbanner) then Showbanner = "True"

if IsEmpty(Request.QueryString("GotoCurrentLocation")) then
	Session("CurrentLocation" & dbkey & formgroup) = ""
	response.redirect "default.asp?formgroup=" & formgroup & "&dataaction=db&dbname=" & dbkey & "&Showbanner=" & Showbanner & "&formmode=" & formmode & "&returnaction=" & returnaction
End if

response.redirect "default.asp?formgroup=" & formgroup & "&dataaction=list&dbname=" & dbkey & "&Showbanner=" & Showbanner & "&formmode=" & formmode & "&returnaction=" & returnaction

%>