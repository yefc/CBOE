<script language = "javascript">
//Copyright 2001-2002 CambridgeSoft Corporation All Rights Reserved%>
//PURPOSE OF FILE: TO add custom javascript functions to an applciation
//All form files generated by the wizard have a #INCLUDE for this file. Add the #INCLUDE to form files
//that you might add to the application.



//////////////////////////////////////////////////////////////////////////////////////////
// Displays the zoom button and calls ACX_doStructureZoom() when clicked
//
function ACX_getStrucZoomBtn(fullSrucFieldName, BaseID, gifWidth, gifHeight, gifName){
	var outputval = ""
	if (!gifName) gifName = "zoom_btn.gif"
	var buttonGifPath = button_gif_path + gifName
	var params = "&quot;" + fullSrucFieldName + "&quot;," + BaseID 
	
	if(typeof gifWidth != "undefined"){
		params +=  "," + gifWidth + "," + gifHeight	  
	}
	outputval = '<A HREF ="Show Structure in larger window" onclick="ACX_doStructureZoom(' + params + ');return false;"><IMG SRC="' +  buttonGifPath + '" BORDER="0"></A>'
	document.write (outputval)
}

//////////////////////////////////////////////////////////////////////////////////////////
// Pops up a window with zoom_structure.asp in it
//
function ACX_doStructureZoom(fullSrucFieldName, BaseID, gifWidth, gifHeight){
	var z = ""
	var attribs = 'width=450,height=450,left=0,top=0,xpos=0,ypos=0,status=no,resizable=yes';
	var url = app_Path + "/zoom_structure.asp?baseid="+ BaseID + "&dbname=" + dbname + "&fullSrucFieldName=" + fullSrucFieldName;
	
	if ((typeof gifWidth != "undefined") && (gifWidth > 0)){
		url += "&gifWidth=" + gifWidth + "&gifHeight=" + gifHeight;
	}
	
	if (z.name == null){
		z = window.open(url,"zoom_structure", attribs);
		z.name = "zoom_structure"
	}
	else{
		z.focus()
	}
}

//////////////////////////////////////////////////////////////////////////////////////////
// Generic Cookie Reader Function
//
function ReadCookie(cookiename){
		var allcookies = document.cookie;
		var  pos = allcookies.indexOf(cookiename + "=");
		if (pos != -1){
			var start = pos + cookiename.length + 1;
			var end = allcookies.indexOf(";",start);  
			if (end == -1){
				end= allcookies.length;
			}
			var cookiestr = unescape(allcookies.substring(start,end));
			var out = cookiestr;
			return out;
		}
		else { 
			var out = "";
			return out;
		}
	}
	
//Prints the most important frame/s
function InvPrintCurrentPage(){
	if (MainWindow.formmode == "edit"){ 
	MainWindow.parent.focus();
	}
	else{
	MainWindow.focus();
	}
	window.print();
}

</script>



