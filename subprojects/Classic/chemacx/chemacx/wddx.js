 function wddxSerializer_serializeValue(obj) { var bSuccess = true; if (typeof(obj) == "string") { this.serializeString(obj); } else if (typeof(obj) == "number") { this.write("<number>" + obj + "</number>"); } else if (typeof(obj) == "boolean") { this.write("<boolean value='" + obj + "'/>"); } else if (typeof(obj) == "object") { if (obj == null) { this.write("<string></string>"); } else if (typeof(obj.wddxSerialize) == "function") { bSuccess = obj.wddxSerialize(this); } else if ( typeof(obj.join) == "function" && typeof(obj.reverse) == "function" && typeof(obj.sort) == "function" && typeof(obj.length) == "number") { this.write("<array length='" + obj.length + "'>"); for (var i = 0; bSuccess && i < obj.length; ++i) { bSuccess = this.serializeValue(obj[i]); } this.write("</array>"); } else if ( typeof(obj.getTimezoneOffset) == "function" && typeof(obj.toGMTString) == "function") { this.write(	"<dateTime>" + (obj.getYear() < 100 ? 1900+obj.getYear() : obj.getYear()) + "-" + (obj.getMonth() + 1) + "-" + obj.getDate() + "T" + obj.getHours() + ":" + obj.getMinutes() + ":" + obj.getSeconds()); if (this.useTimezoneInfo) { this.write(this.timezoneString); } this.write("</dateTime>"); } else { if (typeof(obj.wddxSerializationType) == 'string') { this.write('<struct type="'+ obj.wddxSerializationType +'">') } else { this.write("<struct>"); } for (var prop in obj) { if (prop != 'wddxSerializationType') { bSuccess = this.serializeVariable(prop, obj[prop]); if (! bSuccess) { break; } } } this.write("</struct>"); } } else { bSuccess = false; } return bSuccess; } function wddxSerializer_serializeString(s) { this.write("<string>"); for (var i = 0; i < s.length; ++i) { this.write(this.et[s.charAt(i)]); } this.write("</string>"); } function wddxSerializer_serializeStringOld(s) { this.write("<string><![CDATA["); pos = s.indexOf("]]>"); if (pos != -1) { startPos = 0; while (pos != -1) { this.write(s.substring(startPos, pos) + "]]>]]&gt;<![CDATA["); startPos = pos + 3; if (startPos < s.length) { pos = s.indexOf("]]>", startPos); } else { pos = -1; } } this.write(s.substring(startPos, s.length)); } else { this.write(s); } this.write("]]></string>"); } function wddxSerializer_serializeVariable(name, obj) { var bSuccess = true; if (typeof(obj) != "function") { this.write("<var name='" + (this.preserveVarCase ? name : name.toLowerCase()) + "'>"); bSuccess = this.serializeValue(obj); this.write("</var>"); } return bSuccess; } function wddxSerializer_write(str) { this.wddxPacket += str; } function wddxSerializer_serialize(rootObj) { this.wddxPacket = ""; this.write("<wddxPacket version='0.9'><header/><data>"); var bSuccess = this.serializeValue(rootObj); this.write("</data></wddxPacket>"); if (bSuccess) { return this.wddxPacket; } else { return null; } } function WddxSerializer() { if (navigator.appVersion != "" && navigator.appVersion.indexOf("MSIE 3.") == -1) { var et = new Array(); var n2c = new Array(); var c2n = new Array(); for (var i = 0; i < 256; ++i) { var d1 = Math.floor(i/64); var d2 = Math.floor((i%64)/8); var d3 = i%8; var c = eval("\"\\" + d1.toString(10) + d2.toString(10) + d3.toString(10) + "\""); n2c[i] = c; c2n[c] = i; if (i < 32 && i != 9 && i != 10 && i != 13) { var hex = i.toString(16); if (hex.length == 1) { hex = "0" + hex; } et[n2c[i]] = "<char code='" + hex + "'/>"; } else if (i < 128) { et[n2c[i]] = n2c[i]; } else { et[n2c[i]] = "&#x" + i.toString(16) + ";"; } } et["<"] = "&lt;"; et[">"] = "&gt;"; et["&"] = "&amp;"; this.n2c = n2c; this.c2n = c2n; this.et = et; this.serializeString = wddxSerializer_serializeString; } else { this.serializeString = wddxSerializer_serializeStringOld; } var tzOffset = (new Date()).getTimezoneOffset(); if (tzOffset >= 0) { this.timezoneString = '-'; } else { this.timezoneString = '+'; } this.timezoneString += Math.floor(Math.abs(tzOffset) / 60) + ":" + (Math.abs(tzOffset) % 60); this.preserveVarCase = false; this.useTimezoneInfo = true; this.serialize = wddxSerializer_serialize; this.serializeValue = wddxSerializer_serializeValue; this.serializeVariable = wddxSerializer_serializeVariable; this.write = wddxSerializer_write; } function wddxRecordset_getRowCount() { var nRowCount = 0; for (var col in this) { if (typeof(this[col]) == "object") { nRowCount = this[col].length; break; } } return nRowCount; } function wddxRecordset_addColumn(name) { var nLen = this.getRowCount(); var colValue = new Array(nLen); for (var i = 0; i < nLen; ++i) { colValue[i] = null; } this[this.preserveFieldCase ? name : name.toLowerCase()] = colValue; } function wddxRecordset_addRows(n) { for (var col in this) { var nLen = this[col].length; for (var i = nLen; i < nLen + n; ++i) { this[col][i] = null; } } } function wddxRecordset_getField(row, col) { return this[this.preserveFieldCase ? col : col.toLowerCase()][row]; } function wddxRecordset_setField(row, col, value) { this[this.preserveFieldCase ? col : col.toLowerCase()][row] = value; } function wddxRecordset_wddxSerialize(serializer) { var colNamesList = ""; var colNames = new Array(); var i = 0; for (var col in this) { if (typeof(this[col]) == "object") { colNames[i++] = col; if (colNamesList.length > 0) { colNamesList += ","; } colNamesList += col; } } var nRows = this.getRowCount(); serializer.write("<recordset rowCount='" + nRows + "' fieldNames='" + colNamesList + "'>"); var bSuccess = true; for (i = 0; bSuccess && i < colNames.length; i++) { var name = colNames[i]; serializer.write("<field name='" + name + "'>"); for (var row = 0; bSuccess && row < nRows; row++) { bSuccess = serializer.serializeValue(this[name][row]); } serializer.write("</field>"); } serializer.write("</recordset>"); return bSuccess; } function wddxRecordset_dump(escapeStrings) { var nRows = this.getRowCount(); var colNames = new Array(); var i = 0; for (var col in this) { if (typeof(this[col]) == "object") { colNames[i++] = col; } } var o = "<table border=1><tr><td><b>RowNumber</b></td>"; for (i = 0; i < colNames.length; ++i) { o += "<td><b>" + colNames[i] + "</b></td>"; } o += "</tr>"; for (var row = 0; row < nRows; ++row) { o += "<tr><td>" + row + "</td>"; for (i = 0; i < colNames.length; ++i) { var elem = this.getField(row, colNames[i]); if (escapeStrings && typeof(elem) == "string") { var str = ""; for (var j = 0; j < elem.length; ++j) { var ch = elem.charAt(j); if (ch == '<') { str += "&lt;"; } else if (ch == '>') { str += "&gt;"; } else if (ch == '&') { str += "&amp;"; } else { str += ch; } } o += ("<td>" + str + "</td>"); } else { o += ("<td>" + elem + "</td>"); } } o += "</tr>"; } o += "</table>"; return o; } function WddxRecordset() { this.preserveFieldCase = false; if (typeof(wddxRecordsetExtensions) == "object") { for (var prop in wddxRecordsetExtensions) { this[prop] = wddxRecordsetExtensions[prop] } } this.getRowCount = wddxRecordset_getRowCount; this.addColumn = wddxRecordset_addColumn; this.addRows = wddxRecordset_addRows; this.getField = wddxRecordset_getField; this.setField = wddxRecordset_setField; this.wddxSerialize = wddxRecordset_wddxSerialize; this.dump = wddxRecordset_dump; if (WddxRecordset.arguments.length > 0) { var cols = WddxRecordset.arguments[0]; var nLen = WddxRecordset.arguments.length > 1 ? WddxRecordset.arguments[1] : 0; for (var i = 0; i < cols.length; ++i) { var colValue = new Array(nLen); for (var j = 0; j < nLen; ++j) { colValue[j] = null; } this[cols[i]] = colValue; } } } function registerWddxRecordsetExtension(name, func) { if (typeof(name) == "string" && typeof(func) == "function") { if (typeof(wddxRecordsetExtensions) != "object") { wddxRecordsetExtensions = new Object(); } wddxRecordsetExtensions[name] = func; } } 
