<%'Copyright 1999-2003 CambridgeSoft Corporation. All rights reserved%>
<%'DO NOT EDIT THIS FILE%>
<!--#INCLUDE VIRTUAL = "/cfserverasp/source/manage_user_settings_vbs.asp"-->
<!--#INCLUDE VIRTUAL = "/cfserverasp/source/marked_hits_vbs.asp"-->

<%'access the ini file if the application variables are not yet set. Will only happen one time after an applicaiton has been restarted.

if Application("CD_PLUGIN_THRESHOLD") = "" then
	Application.Lock
	Application("CD_PLUGIN_THRESHOLD")=GetINIValue( "optional", "GLOBALS", "CD_PLUGIN_THRESHOLD", "chemoffice", "chemoffice")
	if (Application("CD_PLUGIN_THRESHOLD")="INIEmpty" or Application("CD_PLUGIN_THRESHOLD") = "NULL" or Application("CD_PLUGIN_THRESHOLD") = "") then
		Application("CD_PLUGIN_THRESHOLD")="5.1"
	end if
	Application.UnLock
end if

'SYAN added on 12/12/2003 to fix CSBR-35466
if Application("DATE_FORMAT") = "" then
	Application.Lock
	Application("DATE_FORMAT") = GetINIValue("optional", "GLOBALS", "DATE_FORMAT", "web_app", "cfserver")
	if (Application("DATE_FORMAT") = "INIEmpty" or Application("DATE_FORMAT") = "NULL" or Application("DATE_FORMAT") = "") then
		Application("DATE_FORMAT") = "8"
	end if
	Application.UnLock
end if

'SYAN added on 2/18/2004 to turn CDAX version alerting on and off
if Application("ALERT_CDAX_VERSION") = "" then
	Application.Lock
	Application("ALERT_CDAX_VERSION") = GetINIValue("optional", "GLOBALS", "ALERT_CDAX_VERSION", "chemoffice", "chemoffice")
	if (Application("ALERT_CDAX_VERSION") = "INIEmpty" or UCase(Application("ALERT_CDAX_VERSION")) = "NULL" or Application("ALERT_CDAX_VERSION") = "") then
		Application("ALERT_CDAX_VERSION") = "NULL"
	end if
	Application.UnLock
end if

'DGB move to app_startup_vbs.asp
'if Application("ALLOW_FLAT_SDFILE_EXPORT") = "" then
'	Application.Lock
'	Application("ALLOW_FLAT_SDFILE_EXPORT")=GetINIValue( "optional", "GLOBALS", "ALLOW_FLAT_SDFILE_EXPORT", "web_app", "cfserver")
'	if (Application("ALLOW_FLAT_SDFILE_EXPORT")="INIEmpty" or Application("ALLOW_FLAT_SDFILE_EXPORT") = "NULL" or Application("ALLOW_FLAT_SDFILE_EXPORT") = "") then
'		Application("ALLOW_FLAT_SDFILE_EXPORT")="0"
'	end if
'	Application.UnLock
'end if


if Application("CD_PLUGIN_DOWNLOAD_PATH") = "" then
	Application.Lock
	Application("CD_PLUGIN_DOWNLOAD_PATH")=GetINIValue( "optional", "GLOBALS", "CD_PLUGIN_DOWNLOAD_PATH", "chemoffice", "chemoffice")
	if (Application("CD_PLUGIN_DOWNLOAD_PATH")="INIEmpty" or Application("CD_PLUGIN_DOWNLOAD_PATH") = "NULL" or Application("CD_PLUGIN_DOWNLOAD_PATH") = "") then
		Application("CD_PLUGIN_DOWNLOAD_PATH")="/chemoffice/chemoffice_download.asp"
	end if
	Application.UnLock
end if
if Application("HIGHLIGHT_REQUIRED_FIELDS") = "" then
	Application.Lock
	Application("HIGHLIGHT_REQUIRED_FIELDS")=GetINIValue( "optional", "GLOBALS", "HIGHLIGHT_REQUIRED_FIELDS", "web_app", "cfserver")
	if (Application("HIGHLIGHT_REQUIRED_FIELDS")="INIEmpty" or Application("HIGHLIGHT_REQUIRED_FIELDS") = "NULL" or Application("HIGHLIGHT_REQUIRED_FIELDS") = "") then
		Application("HIGHLIGHT_REQUIRED_FIELDS")="0"
	end if
	Application.UnLock
end if

if Application("FIELD_SPLIT_CHARACTER") = "" then
	Application.Lock
	Application("FIELD_SPLIT_CHARACTER")=GetINIValue( "optional", "GLOBALS", "FIELD_SPLIT_CHARACTER", "web_app", "cfserver")
	if (Application("FIELD_SPLIT_CHARACTER")="INIEmpty" or Application("FIELD_SPLIT_CHARACTER") = "NULL" or Application("FIELD_SPLIT_CHARACTER") = "") then
		Application("FIELD_SPLIT_CHARACTER")=";"
	end if
	Application.UnLock
end if
if Application("HIGHLIGHT_BACKGROUND") = "" then
	Application.Lock
	Application("HIGHLIGHT_BACKGROUND")=GetINIValue( "optional", "GLOBALS", "HIGHLIGHT_BACKGROUND", "web_app", "cfserver")
	if (Application("HIGHLIGHT_BACKGROUND")="INIEmpty" or Application("HIGHLIGHT_BACKGROUND") = "NULL" or Application("HIGHLIGHT_BACKGROUND") = "") then
		Application("HIGHLIGHT_BACKGROUND")="border=""1"" bordercolor =""#cc0033"""
	end if
	Application.UnLock
end if
if Application("BRACKET_IN_STRUC_HANDLING") = "" then
	Application.Lock
	Application("BRACKET_IN_STRUC_HANDLING")=GetINIValue( "optional", "GLOBALS", "BRACKET_IN_STRUC_HANDLING", "web_app", "cfserver")
	if (Application("BRACKET_IN_STRUC_HANDLING")="INIEmpty" or Application("BRACKET_IN_STRUC_HANDLING") = "NULL" or Application("BRACKET_IN_STRUC_HANDLING") = "") then
		Application("BRACKET_IN_STRUC_HANDLING")="WARN"
	end if
	Application.UnLock
end if


if Application("ADJUST_NETSCAPE_WIDTHS")="" then
	Application.Lock
	Application("ADJUST_NETSCAPE_WIDTHS")=GetINIValue( "optional", "GLOBALS", "ADJUST_NETSCAPE_WIDTHS", "web_app", "cfserver")
	if (Application("ADJUST_NETSCAPE_WIDTHS")="INIEmpty" or Application("ADJUST_NETSCAPE_WIDTHS") = "NULL" or Application("ADJUST_NETSCAPE_WIDTHS") = "") then
		Application("ADJUST_NETSCAPE_WIDTHS")=0
	end if
	Application.UnLock
end if

if Application("ALWAYS_DISPLAY_ALERTS")="" then
	Application.Lock
	Application("ALWAYS_DISPLAY_ALERTS")=GetINIValue( "optional", "GLOBALS", "ALWAYS_DISPLAY_ALERTS", "web_app", "cfserver")
	if (Application("ALWAYS_DISPLAY_ALERTS")="INIEmpty" or Application("ALWAYS_DISPLAY_ALERTS") = "NULL" or Application("ALWAYS_DISPLAY_ALERTS") = "") then
		Application("ALWAYS_DISPLAY_ALERTS")=1
	end if
	Application.UnLock
end if


if Application("DISPLAY_GIFS_ONLY_LIST_NS")="" then
	Application.Lock
	Application("DISPLAY_GIFS_ONLY_LIST_NS")=GetINIValue( "optional", "GLOBALS", "DISPLAY_GIFS_ONLY_LIST_NS", "web_app", "cfserver")
	if (Application("DISPLAY_GIFS_ONLY_LIST_NS")="INIEmpty" or Application("DISPLAY_GIFS_ONLY_LIST_NS") = "NULL" or Application("DISPLAY_GIFS_ONLY_LIST_NS") = "") then
		Application("DISPLAY_GIFS_ONLY_LIST_NS")="0"
	end if
	Application.UnLock
end if

if Application("DISPLAY_GIFS_ONLY_FORM_NS")="" then
	Application.Lock
	Application("DISPLAY_GIFS_ONLY_FORM_NS")=GetINIValue( "optional", "GLOBALS", "DISPLAY_GIFS_ONLY_FORM_NS", "web_app", "cfserver")
	if (Application("DISPLAY_GIFS_ONLY_FORM_NS")="INIEmpty" or Application("DISPLAY_GIFS_ONLY_FORM_NS") = "NULL" or Application("DISPLAY_GIFS_ONLY_FORM_NS") = "") then
		Application("DISPLAY_GIFS_ONLY_FORM_NS")="0"
	end if
	Application.UnLock
end if

if Application("DISPLAY_GIFS_ONLY_LIST_NS6")="" then
	Application.Lock
	Application("DISPLAY_GIFS_ONLY_LIST_NS6")=GetINIValue( "optional", "GLOBALS", "DISPLAY_GIFS_ONLY_LIST_NS6", "web_app", "cfserver")
	if (Application("DISPLAY_GIFS_ONLY_LIST_NS6")="INIEmpty" or Application("DISPLAY_GIFS_ONLY_LIST_NS6") = "NULL" or Application("DISPLAY_GIFS_ONLY_LIST_NS6") = "") then
		Application("DISPLAY_GIFS_ONLY_LIST_NS6")="0"
	end if
	Application.UnLock
end if

if Application("DISPLAY_GIFS_ONLY_FORM_NS6")="" then
	Application.Lock
	Application("DISPLAY_GIFS_ONLY_FORM_NS6")=GetINIValue( "optional", "GLOBALS", "DISPLAY_GIFS_ONLY_FORM_NS6", "web_app", "cfserver")
	if (Application("DISPLAY_GIFS_ONLY_FORM_NS6")="INIEmpty" or Application("DISPLAY_GIFS_ONLY_FORM_NS6") = "NULL" or Application("DISPLAY_GIFS_ONLY_FORM_NS6") = "") then
		Application("DISPLAY_GIFS_ONLY_FORM_NS6")="0"
	end if
	Application.UnLock
end if

if Application("DISPLAY_GIFS_ONLY_LIST_IE")="" then
	Application.Lock
	Application("DISPLAY_GIFS_ONLY_LIST_IE")=GetINIValue( "optional", "GLOBALS", "DISPLAY_GIFS_ONLY_LIST_IE", "web_app", "cfserver")
	if (Application("DISPLAY_GIFS_ONLY_LIST_IE")="INIEmpty" or Application("DISPLAY_GIFS_ONLY_LIST_IE") = "NULL" or Application("DISPLAY_GIFS_ONLY_LIST_IE") = "") then
		Application("DISPLAY_GIFS_ONLY_LIST_IE")="0"
	end if
	Application.UnLock
end if


if Application("DISPLAY_GIFS_ONLY_FORM_IE")="" then
	Application.Lock
	Application("DISPLAY_GIFS_ONLY_FORM_IE")=GetINIValue( "optional", "GLOBALS", "DISPLAY_GIFS_ONLY_FORM_IE", "web_app", "cfserver")
	if (Application("DISPLAY_GIFS_ONLY_FORM_IE")="INIEmpty" or Application("DISPLAY_GIFS_ONLY_FORM_IE") = "NULL" or Application("DISPLAY_GIFS_ONLY_FORM_IE") = "") then
		Application("DISPLAY_GIFS_ONLY_FORM_IE")="0"
	end if
	Application.UnLock
end if

if Application("DIRECT_KEYWORD_SUPPORT")="" then
	Application.Lock
	Application("DIRECT_KEYWORD_SUPPORT")=GetINIValue( "optional", "GLOBALS", "DIRECT_KEYWORD_SUPPORT", "web_app", "cfserver")
	if (Application("DIRECT_KEYWORD_SUPPORT")="INIEmpty" or Application("DIRECT_KEYWORD_SUPPORT") = "NULL" or Application("DIRECT_KEYWORD_SUPPORT") = "") then
		Application("DIRECT_KEYWORD_SUPPORT")=true
	end if
	Application.UnLock
end if

if Application("USE_ANIMATED_GIF")="" then
	Application.Lock
	Application("USE_ANIMATED_GIF")=GetINIValue( "optional", "GLOBALS", "USE_ANIMATED_GIF", "web_app", "cfserver")
	if (Application("USE_ANIMATED_GIF")="INIEmpty" or Application("USE_ANIMATED_GIF") = "NULL" or Application("USE_ANIMATED_GIF") = "") then
		Application("USE_ANIMATED_GIF")=1
	end if
	Application.UnLock
end if

if Application("ANIMATED_GIF_PATH")="" then
	Application.Lock
	Application("ANIMATED_GIF_PATH")=GetINIValue( "optional", "GLOBALS", "ANIMATED_GIF_PATH", "web_app", "cfserver")
	if (Application("ANIMATED_GIF_PATH")="INIEmpty" or Application("ANIMATED_GIF_PATH") = "NULL" or Application("ANIMATED_GIF_PATH") = "") then
		Application("ANIMATED_GIF_PATH")="/cfserverasp/source/graphics/processing_Ybvl_Ysh_grey.gif"
	end if
	Application.UnLock
end if

if Application("FORMAT_FORMULA")="" then
	Application.Lock
	Application("FORMAT_FORMULA")=GetINIValue( "optional", "GLOBALS", "FORMAT_FORMULA", "web_app", "cfserver")
	if (Application("FORMAT_FORMULA")="INIEmpty" or Application("FORMAT_FORMULA") = "NULL" or Application("FORMAT_FORMULA") = "") then
		Application("FORMAT_FORMULA")=1
	end if
	Application.UnLock
end if
if Application("BODY_BACKGROUND")="" then
	Application.Lock
	Body_Background=GetINIValue( "optional", "GLOBALS", "BODY_BACKGROUND", "web_app", "cfserver")
	if (Body_Background="INIEmpty" or Body_Background = "NULL" or Body_Background = "") then
		final_Background="background=""/CFServerAsp/Source/graphics/Fine_Speckled.gif"""
	else
		if (inStr(Body_Background, ".gif")>0) then
			final_Background= "background=" & QuotedString(Body_Background)
		else
			final_Background= "bgcolor=" & QuotedString(Body_Background)
		end if
	end if
	Application("BODY_BACKGROUND")=final_Background
	Application.UnLock
end if






if Application("ENABLE_SEARCH_LOGGING") = "" then
	Application.Lock
	Application("ENABLE_SEARCH_LOGGING")=GetINIValue( "optional", "GLOBALS", "ENABLE_SEARCH_LOGGING", "web_app", "cfserver")
	if (Application("ENABLE_SEARCH_LOGGING")="INIEmpty" or Application("ENABLE_SEARCH_LOGGING") = "NULL" or Application("ENABLE_SEARCH_LOGGING") = "") then
		Application("ENABLE_SEARCH_LOGGING")=0
	end if
	Application.UnLock
end if

'!DGB 05/12/02


if Application("POST_MARKED_HITS_TARGET_MENU_NAME") = "" then
	Application.Lock
	Application("POST_MARKED_HITS_TARGET_MENU_NAME")=GetINIValue( "optional", "GLOBALS", "POST_MARKED_HITS_TARGET_MENU_NAME", "web_app", "cfserver")
	if (Application("POST_MARKED_HITS_TARGET_MENU_NAME")="INIEmpty" or Application("POST_MARKED_HITS_TARGET_MENU_NAME") = "NULL" or Application("POST_MARKED_HITS_TARGET_MENU_NAME") = "") then
		Application("POST_MARKED_HITS_TARGET_MENU_NAME")=""
	end if
	Application.UnLock
end if



if Application("POST_MARKED_HITS_PAGE") = "" then
	Application.Lock
	Application("POST_MARKED_HITS_PAGE")=GetINIValue( "optional", "GLOBALS", "POST_MARKED_HITS_PAGE", "web_app", "cfserver")
	if (Application("POST_MARKED_HITS_PAGE")="INIEmpty" or Application("POST_MARKED_HITS_PAGE") = "NULL" or Application("POST_MARKED_HITS_PAGE") = "") then
		Application("POST_MARKED_HITS_PAGE")=""
	end if
	Application.UnLock
end if

if Application("POST_MARKED_SEND_TO_PAGE") = "" then
	Application.Lock
	Application("POST_MARKED_SEND_TO_PAGE")=GetINIValue( "optional", "GLOBALS", "POST_MARKED_SEND_TO_PAGE", "web_app", "cfserver")
	if (Application("POST_MARKED_SEND_TO_PAGE")="INIEmpty" or Application("POST_MARKED_SEND_TO_PAGE") = "NULL" or Application("POST_MARKED_SEND_TO_PAGE") = "") then
		Application("POST_MARKED_SEND_TO_PAGE")=""
	end if
	Application.UnLock
end if

if Application("POST_MARKED_SUPPORTED_FORMGROUPS") = "" then
	Application.Lock
	Application("POST_MARKED_SUPPORTED_FORMGROUPS")=GetINIValue( "optional", "GLOBALS", "POST_MARKED_SUPPORTED_FORMGROUPS", "web_app", "cfserver")
	if (Application("POST_MARKED_SUPPORTED_FORMGROUPS")="INIEmpty" or Application("POST_MARKED_SUPPORTED_FORMGROUPS") = "NULL" or Application("POST_MARKED_SUPPORTED_FORMGROUPS") = "") then
		Application("POST_MARKED_SUPPORTED_FORMGROUPS")=""
	end if
	Application.UnLock
end if

'ExactSearchSettings

if Application("EXTRA_FRAGS_OK") = "" then
	Application.Lock
	Application("EXTRA_FRAGS_OK")=GetINIValue( "optional", "DUPLICATE_CHECKING", "EXTRA_FRAGS_OK", "web_app", "cfserver")
	if (Application("EXTRA_FRAGS_OK")="INIEmpty" or Application("EXTRA_FRAGS_OK") = "NULL" or Application("EXTRA_FRAGS_OK") = "") then
		Application("EXTRA_FRAGS_OK")="0"
	end if
	Application.UnLock
end if

if Application("EXTRA_FRAGS_OK_IF_RXN") = "" then
	Application.Lock
	Application("EXTRA_FRAGS_OK_IF_RXN")=GetINIValue( "optional", "DUPLICATE_CHECKING", "EXTRA_FRAGS_OK_IF_RXN", "web_app", "cfserver")
	if (Application("EXTRA_FRAGS_OK_IF_RXN")="INIEmpty" or Application("EXTRA_FRAGS_OK_IF_RXN") = "NULL" or Application("EXTRA_FRAGS_OK_IF_RXN") = "") then
		Application("EXTRA_FRAGS_OK_IF_RXN")="1"
	end if
	Application.UnLock
end if

if Application("FRAGS_CAN_OVERLAP") = "" then
	Application.Lock
	Application("FRAGS_CAN_OVERLAP")=GetINIValue( "optional", "DUPLICATE_CHECKING", "FRAGS_CAN_OVERLAP", "web_app", "cfserver")
	if (Application("FRAGS_CAN_OVERLAP")="INIEmpty" or Application("FRAGS_CAN_OVERLAP") = "NULL" or Application("FRAGS_CAN_OVERLAP") = "") then
		Application("FRAGS_CAN_OVERLAP")="0"
	end if
	Application.UnLock
end if


if Application("MATCH_TET_STEREO") = "" then
	Application.Lock
	Application("MATCH_TET_STEREO")=GetINIValue( "optional", "DUPLICATE_CHECKING", "MATCH_TET_STEREO", "web_app", "cfserver")
	if (Application("MATCH_TET_STEREO")="INIEmpty" or Application("MATCH_TET_STEREO") = "NULL" or Application("MATCH_TET_STEREO") = "") then
		Application("MATCH_TET_STEREO")="1"
	end if
	Application.UnLock
end if

if Application("MATCH_DB_STEREO") = "" then
	Application.Lock
	Application("MATCH_DB_STEREO")=GetINIValue( "optional", "DUPLICATE_CHECKING", "MATCH_DB_STEREO", "web_app", "cfserver")
	if (Application("MATCH_DB_STEREO")="INIEmpty" or Application("MATCH_DB_STEREO") = "NULL" or Application("MATCH_DB_STEREO") = "") then
		Application("MATCH_DB_STEREO")="1"
	end if
	Application.UnLock
end if

if Application("HIT_ANY_CHARGE_CARBON") = "" then
	Application.Lock
	Application("HIT_ANY_CHARGE_CARBON")=GetINIValue( "optional", "DUPLICATE_CHECKING", "HIT_ANY_CHARGE_CARBON", "web_app", "cfserver")
	if (Application("HIT_ANY_CHARGE_CARBON")="INIEmpty" or Application("HIT_ANY_CHARGE_CARBON") = "NULL" or Application("HIT_ANY_CHARGE_CARBON") = "") then
		Application("HIT_ANY_CHARGE_CARBON")="1"
	end if
	Application.UnLock
end if


if Application("RXN_HIT_RXN_CENTER") = "" then
	Application.Lock
	Application("RXN_HIT_RXN_CENTER")=GetINIValue( "optional", "DUPLICATE_CHECKING", "RXN_HIT_RXN_CENTER", "web_app", "cfserver")
	if (Application("RXN_HIT_RXN_CENTER")="INIEmpty" or Application("RXN_HIT_RXN_CENTER") = "NULL" or Application("RXN_HIT_RXN_CENTER") = "") then
		Application("RXN_HIT_RXN_CENTER")="1"
	end if
	Application.UnLock
end if

if Application("HIT_ANY_CHARGE_HETERO") = "" then
	Application.Lock
	Application("HIT_ANY_CHARGE_HETERO")=GetINIValue( "optional", "DUPLICATE_CHECKING", "HIT_ANY_CHARGE_HETERO", "web_app", "cfserver")
	if (Application("HIT_ANY_CHARGE_HETERO")="INIEmpty" or Application("HIT_ANY_CHARGE_HETERO") = "NULL" or Application("HIT_ANY_CHARGE_HETERO") = "") then
		Application("HIT_ANY_CHARGE_HETERO")="1"
	end if
	Application.UnLock
end if

if Application("IDENTITY") = "" then
	Application.Lock
	Application("IDENTITY")=GetINIValue( "optional", "DUPLICATE_CHECKING", "IDENTITY", "web_app", "cfserver")
	if (Application("IDENTITY")="INIEmpty" or Application("IDENTITY") = "NULL" or Application("IDENTITY") = "") then
		Application("IDENTITY")="0"
	end if
	Application.UnLock
end if

if Application("RELATIVE_TET_STEREO") = "" then
	Application.Lock
	Application("RELATIVE_TET_STEREO")=GetINIValue( "optional", "DUPLICATE_CHECKING", "RELATIVE_TET_STEREO", "web_app", "cfserver")
	if (Application("RELATIVE_TET_STEREO")="INIEmpty" or Application("RELATIVE_TET_STEREO") = "NULL" or Application("RELATIVE_TET_STEREO") = "") then
		Application("RELATIVE_TET_STEREO")="0"
	end if
	Application.UnLock
end if

if Application("ABSOLUTE_HITS_REL") = "" then
	Application.Lock
	Application("ABSOLUTE_HITS_REL")=GetINIValue( "optional", "DUPLICATE_CHECKING", "ABSOLUTE_HITS_REL", "web_app", "cfserver")
	if (Application("ABSOLUTE_HITS_REL")="INIEmpty" or Application("ABSOLUTE_HITS_REL") = "NULL" or Application("ABSOLUTE_HITS_REL") = "") then
		Application("ABSOLUTE_HITS_REL")="0"
	end if
	Application.UnLock
end if

if Application("TAUTOMER") = "" then
	Application.Lock
	Application("TAUTOMER")=GetINIValue( "optional", "DUPLICATE_CHECKING", "TAUTOMER", "web_app", "cfserver")
	if (Application("TAUTOMER")="INIEmpty" or Application("TAUTOMER") = "NULL" or Application("TAUTOMER") = "") then
		Application("TAUTOMER")="0"
	end if
	Application.UnLock
end if

if Application("LOOSEDELOCALIZATION") = "" then
	Application.Lock
	Application("LOOSEDELOCALIZATION")=GetINIValue( "optional", "DUPLICATE_CHECKING", "LOOSEDELOCALIZATION", "web_app", "cfserver")
	if (Application("LOOSEDELOCALIZATION")="INIEmpty" or Application("LOOSEDELOCALIZATION") = "NULL" or Application("LOOSEDELOCALIZATION") = "") then
		Application("LOOSEDELOCALIZATION")="0"
	end if
	Application.UnLock
end if

'CSBR# - 119688
'Done by - Soorya Anwar
'Date -  19-Jan-2011
'Purpose - The default value for MARKED_HITS_MAX is set to 10000 instead of "1000". 
if Application("MARKED_HITS_MAX") = "" then
	Application.Lock
	Application("MARKED_HITS_MAX")=GetINIValue( "optional", "GLOBALS", "MARKED_HITS_MAX", "web_app", "cfserver")
	if (Application("MARKED_HITS_MAX")="INIEmpty" or Application("MARKED_HITS_MAX") = "NULL" or Application("MARKED_HITS_MAX") = "") then
		Application("MARKED_HITS_MAX")=10000 'End of Change
	end if
	Application.UnLock
end if

if Application("NON_CHEMICAL_SUBMIT") = "" then
	Application.Lock
	Application("NON_CHEMICAL_SUBMIT")=GetINIValue( "optional", "GLOBALS", "NON_CHEMICAL_SUBMIT", "web_app", "cfserver")
	if (Application("NON_CHEMICAL_SUBMIT")="INIEmpty" or Application("NON_CHEMICAL_SUBMIT") = "NULL" or Application("NON_CHEMICAL_SUBMIT") = "") then
		Application("NON_CHEMICAL_SUBMIT")="DISALLOW"
	end if
	Application.UnLock
end if

if Application("RESIZE_GIFS") = "" then
	Application.Lock
	Application("RESIZE_GIFS")=GetINIValue( "optional", "GLOBALS", "RESIZE_GIFS", "web_app", "cfserver")
	if (Application("RESIZE_GIFS")="INIEmpty" or Application("RESIZE_GIFS") = "NULL" or Application("RESIZE_GIFS") = "") then
		Application("RESIZE_GIFS")=1
	end if
	Application.UnLock
end if
if Application("Use_Session_Record_Counts") = "" then
	Application.Lock
	Application("Use_Session_Record_Counts")=GetINIValue( "optional", "GLOBALS", "Use_Session_Record_Counts", "web_app", "cfserver")
	if (Application("Use_Session_Record_Counts")="INIEmpty" or Application("Use_Session_Record_Counts") = "NULL" or Application("Use_Session_Record_Counts") = "") then
		Application("Use_Session_Record_Counts")=0
	end if
	Application.UnLock
end if

if Application("ALLOW_EDIT_VIEW") = "" then
	Application.Lock
	Application("ENABLE_DETAIL_VIEW")=GetINIValue( "optional", "GLOBALS", "ENABLE_DETAIL_VIEW", "web_app", "cfserver")
	if (Application("ENABLE_DETAIL_VIEW")="INIEmpty" or Application("ENABLE_DETAIL_VIEW") = "NULL" or Application("ENABLE_DETAIL_VIEW") = "") then
		Application("ENABLE_DETAIL_VIEW")=1
	end if
	Application.UnLock
end if
if Application("BLANK_CDX") = "" then
	Application.Lock
		AppPath = Application("TempFileDirectory" & request("dbname")) & "mt.cdx"
		Application("BLANK_CDX") = EncodeBlankCDX(AppPath)
	Application.UnLock
end if

if Application("SEARCH_PREF_DEFAULTS") = "" then
	Application.Lock
		Application("SEARCH_PREF_DEFAULTS")=GetINIValue( "optional", "GLOBALS", "SEARCH_PREF_DEFAULTS", "web_app", "cfserver")
		if (Application("SEARCH_PREF_DEFAULTS")="INIEmpty" or Application("SEARCH_PREF_DEFAULTS") = "NULL" or Application("SEARCH_PREF_DEFAULTS") = "") then
			Application("SEARCH_PREF_DEFAULTS")="S1:true,S2:true,S3:true,S4:true,S5:true,S6:90,S7:true,S8:true,S9:true,S10:true,S11:false,S12:false,S13:false"
		end if
	Application.UnLock
end if

if Application("DISABLE_CORE_RS_LOOPING") = "" then
	Application.Lock
		Application("DISABLE_CORE_RS_LOOPING")=GetINIValue( "optional", "GLOBALS", "DISABLE_CORE_RS_LOOPING", "web_app", "cfserver")
		if (Application("DISABLE_CORE_RS_LOOPING")="INIEmpty" or Application("DISABLE_CORE_RS_LOOPING") = "NULL" or Application("DISABLE_CORE_RS_LOOPING") = "") then
			Application("DISABLE_CORE_RS_LOOPING")=0
		end if
	Application.UnLock
end if

if Application("SHOW_RETRIEVE_ALL_BTN") = "" then
	Application.Lock
		Application("SHOW_RETRIEVE_ALL_BTN")=GetINIValue( "optional", "GLOBALS", "SHOW_RETRIEVE_ALL_BTN", "web_app", "cfserver")
		if (Application("SHOW_RETRIEVE_ALL_BTN")="INIEmpty" or Application("SHOW_RETRIEVE_ALL_BTN") = "NULL" or Application("SHOW_RETRIEVE_ALL_BTN") = "") then
			Application("SHOW_RETRIEVE_ALL_BTN")=1
		end if
	Application.UnLock
end if

if Application("NO_GUI_SEARCH_PREF_DEFAULTS") = "" then
	Application.Lock
		Application("NO_GUI_SEARCH_PREF_DEFAULTS")=GetINIValue( "optional", "GLOBALS", "NO_GUI_SEARCH_PREF_DEFAULTS", "web_app", "cfserver")
		if (Application("NO_GUI_SEARCH_PREF_DEFAULTS")="INIEmpty" or Application("NO_GUI_SEARCH_PREF_DEFAULTS") = "NULL" or Application("NO_GUI_SEARCH_PREF_DEFAULTS") = "") then
			Application("NO_GUI_SEARCH_PREF_DEFAULTS")="S1:true,S2:true,S3:true,S4:true,S5:true,S6:90,S7:true,S8:true,S9:true,S10:true,S11:true,S12:false,S13:false"
		end if
	Application.UnLock
end if

If Not Application("USER_SETTINGS_TABLE_CHECKED") <> "" then
	CheckUserSettingsTableExists request("dbname"), request("formgroup")
	Application.Lock
		Application("USER_SETTINGS_TABLE_CHECKED") = "done"
	Application.UnLock
End if
dbkey = request("dbname")
formgroup =request("formgroup")
User_ID = getUserSettingsID(dbkey, formgroup)

if Session("SetGlobalSearchUserSettingsIDs" & dbkey & "start_check") = "" then
	' Populate the Session("USER_SETTINGS_ID" & dbkey) variables for all dbkeys in 
	' a global search formgroup
	SetGlobalSearchUserSettingsIDs()
	Session("SetGlobalSearchUserSettingsIDs" & dbkey & "start_check") = "done"
End if
' DGB to fix CSBR-60700
' note that now preferences are picked up everytime the form opens
' so they are formgroup specific.
'if Not Session("UserPrefs" & dbkey & User_ID & "start_check") <> "" then
	defaultListView =GetFormGroupVal(dbkey, formgroup, kNumListView)
	currentSearchPrefs = selectCurrentSettings(dbkey, formgroup, User_ID, "SEARCHPREFS" & dbkey & formgroup)
	if currentSearchPrefs = -1 then
		currentSearchPrefs= ""
	end if
	if not currentSearchPrefs <> ""  then
		Session("SearchPrefs" & dbkey )=Application("SEARCH_PREF_DEFAULTS")
	else
		Session("SearchPrefs" & dbkey ) = currentSearchPrefs
	end if
	
	currentDisplayPrefs = selectCurrentSettings(dbkey, formgroup, User_ID, "USERRESULTSPREFS" & dbkey & formgroup)
	if currentDisplayPrefs = -1 then
		currentDisplayPrefs= ""
	end if
	if not currentDisplayPrefs <> ""  then
		Session("UserResultsPrefs" & dbkey ) = "list"
	else
		Session("UserResultsPrefs" & dbkey ) = currentDisplayPrefs
	end if
	'SYAN modified on 6/30/2005 to fix CSBR-55823
	' added & forgroup
	currentNumDisplayPrefs = selectCurrentSettings(dbkey, formgroup, User_ID, "USERNUMLISTVIEW" & dbkey & formgroup)
	'End of SYAN modification
	
	if currentNumDisplayPrefs = -1 then
		currentNumDisplayPrefs= ""
	end if
	if not currentNumDisplayPrefs <> ""  then
		'stop
		if defaultListView <> "" then
			'stop
			Session("UserNumListView" & dbkey ) = defaultListView
		else
			'stop
			Session("UserNumListView" & dbkey ) = "5"
		end if
	else
		Session("UserNumListView" & dbkey ) = currentNumDisplayPrefs
	end if
	'Session("UserPrefs" & dbkey & User_ID & "start_check") = "done"
'end if

if Application("UseCSSecurityApp") = "" then
	Application("UseCSSecurityApp")=GetINIValue( "optional", "CS_SECURITY", "USE_CS_SECURITY_APP", "web_app", "cfserver")
	if (Application("UseCSSecurityApp")="INIEmpty" or Application("UseCSSecurityApp") = "NULL" or Application("UseCSSecurityApp") = "") then
		Application("UseCSSecurityApp")="0"
	end if
end if

if Ucase(Application("ForceHTTPS")) = "TRUE" then
	if Request.ServerVariables("HTTPS") = "off" then   
                method = Request.ServerVariables("REQUEST_METHOD") 
                srvname = Request.ServerVariables("SERVER_NAME") 
   	            'CSBR# 139459
	            'Purpose: To append portnumber to the hostname, if a non-standard port number is used.
	            portNumber = Request.ServerVariables("SERVER_PORT")
                if portNumber <> "80" then
	                srvname = srvname & ":" & portNumber 
	            end if
	            'End of change             
                scrname = Request.ServerVariables("SCRIPT_NAME") 
                sRedirect = "https://" & srvname & scrname 
                sQString = Request.Querystring 
                if Len(sQString) > 0 Then sRedirect = sRedirect & "?" & sQString 
                Response.Redirect(sRedirect)
    	end if
end if
if Application("Expire_User_Setting_Days") = "" then
	Application("Expire_User_Setting_Days")=GetINIValue( "optional", "GLOBALS", "Expire_User_Setting_Days", "web_app", "cfserver")
	if (Application("Expire_User_Setting_Days")="INIEmpty" or Application("Expire_User_Setting_Days") = "NULL" or Application("Expire_User_Setting_Days") = "") then
		Application("Expire_User_Setting_Days")="365"
	end if
end if


If Application("DeleteOldUserSettings") = "" then
	deleteOldUserSettings dbkey, formgroup,Application("Expire_User_Setting_Days")
	Application("DeleteOldUserSettings")="done"
end if	

Application("FORMGROUP_UNIQUE_IDENTIFIER")=GetINIValue( "optional", "GLOBALS", "FORMGROUP_UNIQUE_IDENTIFIER", "web_app", "cfserver")
if (Application("FORMGROUP_UNIQUE_IDENTIFIER")="INIEmpty" or Application("FORMGROUP_UNIQUE_IDENTIFIER") = "NULL" or Application("FORMGROUP_UNIQUE_IDENTIFIER") = "") then
	Application("FORMGROUP_UNIQUE_IDENTIFIER")= "FORMGROUP_NAME"
end if
			
if Not OverrideManageHits = true then
	if  Application("allow_hitlist_management") then
		if Not Session("SavedHitLists" & dbkey & formgroup & USER_ID & "start_check") <> "" then
			Session("HitListExists" & dbkey & formgroup) = GetUserHitlists(dbkey, formgroup, USER_ID, false)
			Session("SavedHitLists" & dbkey & formgroup & USER_ID & "start_check")  = "done"
		end if
		if Not Session("HitListHistory" & dbkey & formgroup & USER_ID & "start_check") <> "" then
			Session("HitListHistoryExists" & dbkey & formgroup) = GetUserHitlists(dbkey, formgroup, USER_ID, true)
			Session("HitListHistory" & dbkey & formgroup & USER_ID & "start_check")  = "done"
		end if
	end if
end if

if Not OverrideManageHits = true then
	if Not Session("MarkedHits" & dbkey & formgroup & USER_ID & "start_check") <> "" then
		'!DGB! get marked hits from CSDOHitlist
		if Not OverrideManageHits = true then
			markedHitListID = GetMarkedCSDOHitListID(dbkey, formgroup, user_id)
			Session("MarkedHits" & dbkey & formgroup) = GetHitlistAsString(dbkey, formgroup, markedHitlistID, "USER")
		end if
		Session("MarkedHits" & dbkey & formgroup & USER_ID & "start_check") = "done"
	else
		currentMarkedHits = Session("MarkedHits" & dbkey & formgroup)
	end if
end if
'biosar formgroups


if Application("ALLOW_FORMGROUP_MANAGEMENT") = "" then
	Application.Lock
	Application("ALLOW_FORMGROUP_MANAGEMENT")=GetINIValue( "optional", "GLOBALS", "ALLOW_FORMGROUP_MANAGEMENT", "web_app", "cfserver")
	if (Application("ALLOW_FORMGROUP_MANAGEMENT")="INIEmpty" or Application("ALLOW_FORMGROUP_MANAGEMENT") = "NULL" or Application("ALLOW_FORMGROUP_MANAGEMENT") = "") then
		Application("ALLOW_FORMGROUP_MANAGEMENT")="0"
	end if
	Application("ALLOW_PUBLIC_FORMGROUPS")=GetINIValue( "optional", "GLOBALS", "ALLOW_PUBLIC_FORMGROUPS", "web_app", "cfserver")
	if (Application("ALLOW_PUBLIC_FORMGROUPS")="INIEmpty" or Application("ALLOW_PUBLIC_FORMGROUPS") = "NULL" or Application("ALLOW_PUBLIC_FORMGROUPS") = "") then
		Application("ALLOW_PUBLIC_FORMGROUPS")="0"
	end if
	Application.UnLock
end if

'Save Query

if Not OverrideManageQueries  = true then

		
		' Create and or initialize the queries tables
			if not Application("QT_Initialized") = "done" then
				AppInitQueryTables()
			end if
		
	else
		if Not Session("HistoryDeleted" & dbkey) <> "" then
			' Initialize queries for this session by removing expired queries
			SessInitQueryTables()
			
		end if
	
end if
if Not OverrideManageQueries  = true then
	if  Application("ALLOW_QUERY_MANAGEMENT") = 1 then
		if Not Session("SavedQueries" & dbkey & formgroup & USER_ID & "start_check") <> "" then
			setSavedQueryExists dbkey, formgroup, USER_ID
			Session("SavedQueries" & dbkey & formgroup & USER_ID & "start_check")  = "done"
		end if
		if Not Session("QueryHistory" & dbkey & formgroup & USER_ID & "start_check") <> "" then
			setSavedHistoryExists dbkey, formgroup, USER_ID
			Session("QueryHistory" & dbkey & formgroup & USER_ID & "start_check")  = "done"
		end if
	end if
end if

	If Not Session("MenuBarLoaded" & dbkey) <> "" then
		BuildMenuDictionary()
		Session("MenuBarLoaded" & dbkey) = "done"
	End if
' !DGB! 11/21/02
' Controls which global search dbs are selected by default
if Application("selectedGlobalSearchDBs") = "" then
	Application.Lock
	Application("selectedGlobalSearchDBs")=GetINIValue( "optional", "GLOBALS", "SELECTED_GLOBALSEARCH_DBS", "web_app", "cfserver")
	if (Application("selectedGlobalSearchDBs")="INIEmpty" or Application("selectedGlobalSearchDBs") = "NULL" or Application("selectedGlobalSearchDBs") = "") then
		Application("selectedGlobalSearchDBs")= Application("GlobalSearchDBs")
	end if
	Application.UnLock
end if

' !DGB! 10/21/03
' Controls whether query form is restored during refine operation
if Application("RestoreQueryOnRefine") = "" then
	Application.Lock
	Application("RestoreQueryOnRefine")=GetINIValue( "optional", "GLOBALS", "RESTORE_QUERY_ON_REFINE", "web_app", "cfserver")
	if Application("RestoreQueryOnRefine")="INIEmpty" or Application("RestoreQueryOnRefine") = "NULL" or Application("RestoreQueryOnRefine") = "" then
		Application("RestoreQueryOnRefine")= false		
	end if
	Application.UnLock
end if


' !DGB! 10/21/03
' Checks hit counts and prevents insert into hitlist table.  (expensive but allows blocking large hitlists)
if Application("TooManyHitsWarningThreshHold") = "" then
	Application.Lock
	Application("TooManyHitsWarningThreshHold")=GetINIValue( "optional", "GLOBALS", "TOO_MANY_HITS_WARNING_THRESHHOLD", "web_app", "cfserver")
	if Application("TooManyHitsWarningThreshHold")="INIEmpty" or Application("TooManyHitsWarningThreshHold") = "NULL" or Application("TooManyHitsWarningThreshHold") = "" then
		Application("TooManyHitsWarningThreshHold")= 0		
	else
		Application("TooManyHitsWarningThreshHold") = Clng(Application("TooManyHitsWarningThreshHold"))
	end if
	Application.UnLock
end if

' !DGB! 10/21/03
' Checks hit counts and prevents display.  Full hitlist is saved.
if Application("TooManyHitsMaximumRetrievable") = "" then
	Application.Lock
	Application("TooManyHitsMaximumRetrievable")=GetINIValue( "optional", "GLOBALS", "TOO_MANY_HITS_MAXIMUM_RETRIEVABLE", "web_app", "cfserver")
	if Application("TooManyHitsMaximumRetrievable")="INIEmpty" or Application("TooManyHitsMaximumRetrievable") = "NULL" or Application("TooManyHitsMaximumRetrievable") = "" then
		Application("TooManyHitsMaximumRetrievable")= 0		
	else
		Application("TooManyHitsMaximumRetrievable")=Clng(Application("TooManyHitsMaximumRetrievable"))
	end if
	Application.UnLock
end if
' !DGB! 10/21/03
' Checks hit counts and prevents display.  Full hitlist is saved.
'LJB 4/12/2004 duplicate variable name to match what some applications are using. Both TooManyHitsMaximumRetrievable and TOO_MANY_HITS_MAXIMUM_RETRIEVABLE store the same value
if Application("TOO_MANY_HITS_MAXIMUM_RETRIEVABLE") = "" then
	Application.Lock
	Application("TOO_MANY_HITS_MAXIMUM_RETRIEVABLE")=GetINIValue( "optional", "GLOBALS", "TOO_MANY_HITS_MAXIMUM_RETRIEVABLE", "web_app", "cfserver")
	if Application("TOO_MANY_HITS_MAXIMUM_RETRIEVABLE")="INIEmpty" or Application("TOO_MANY_HITS_MAXIMUM_RETRIEVABLE") = "NULL" or Application("TOO_MANY_HITS_MAXIMUM_RETRIEVABLE") = "" then
		Application("TOO_MANY_HITS_MAXIMUM_RETRIEVABLE")= 0		
	else
		Application("TOO_MANY_HITS_MAXIMUM_RETRIEVABLE")=Clng(Application("TOO_MANY_HITS_MAXIMUM_RETRIEVABLE"))
		dbnamestring = Split(Application("DBNames"), ",", -1)
		For i = 0 to UBound(dbnamestring)
			dbkey = dbnamestring(i)	
			Application("MAXHITS" & dbkey) = 0
		next
	end if
	Application.UnLock
end if

'LJB 4/6/2004 Checks if leading hint should be use.
if Application("USE_LEADING_HINT") = "" then
	Application.Lock
	Application("USE_LEADING_HINT")=GetINIValue( "optional", "GLOBALS", "USE_LEADING_HINT", "web_app", "cfserver")
	if Application("USE_LEADING_HINT")="INIEmpty" or Application("USE_LEADING_HINT") = "NULL" or Application("USE_LEADING_HINT") = "" then
		Application("USE_LEADING_HINT")= 0		
	end if
	Application.UnLock
end if

%>
