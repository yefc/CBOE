<%@ EnableSessionState="False" Language=VBScript %>

<!--#INCLUDE VIRTUAL = "/cfserverasp/source/ado.inc"-->
<!--#INCLUDE VIRTUAL = "/cheminv/gui/xml_utils.asp"-->
<!--#INCLUDE VIRTUAL = "/cheminv/api/apiUtils.asp"-->
<!--#INCLUDE VIRTUAL = "/cheminv/gui/guiUtils.asp"-->
<!--#INCLUDE VIRTUAL = "/cheminv/api/GetCreateContainer_parameters.asp"-->
<!--#INCLUDE VIRTUAL = "/cheminv/api/GetUpdateContainer_parameters.asp"-->
<!--#INCLUDE VIRTUAL = "/cfserverasp/source/cs_security/cs_security_login_utils_vbs.asp"-->

<Script RUNAT="Server" Language="VbScript">

Sub	CreateOrReplaceText(byref theDOM, byRef parentNode, byval text)
    Dim nodes
    Dim node
    Dim newChild

    set nodes = parentNode.SelectNodes("text()")
    for each node in nodes
        parentNode.RemoveChild(node)
    next
    set newChild = theDOM.createTextNode(text)
    set node = parentNode.firstchild
    if node is nothing then
        parentNode.appendChild newChild
    else
        parentnode.insertbefore newchild,node
    end if
End Sub

Function GetContainerIDFromBarcode(barcode)
    Dim sql
    Dim Cmd
    Dim RS
    If IsBlank(barcode) then 
        GetContainerIDFromBarcode = ""
    Else  
        sql = " SELECT CONTAINER_ID FROM " & Application("CHEMINV_USERNAME") & ".INV_CONTAINERS WHERE BARCODE=:BARCODE"
        Set Cmd = GetCommand(Conn, SQL, adCmdText)
        Cmd.Parameters.Append Cmd.CreateParameter("BARCODE", 200, 1, 2000, barcode)
        Set RS = Cmd.Execute
        If not (RS.BOF and RS.EOF) Then
            GetContainerIDFromBarcode = CStr(RS("CONTAINER_ID"))
        Else
            GetContainerIDFromBarcode = ""    
        End If 
        RS.close
        Set Cmd = Nothing
    End If
End Function

Function GetLocationIDFromBarcode(barcode)
    Dim sql
    Dim Cmd
    Dim RS
    If IsBlank(barcode) then 
        GetLocationIDFromBarcode = ""
    Else  
        sql = " SELECT LOCATION_ID_FK FROM " & Application("CHEMINV_USERNAME") & ".INV_CONTAINERS WHERE BARCODE=:BARCODE"
        Set Cmd = GetCommand(Conn, SQL, adCmdText)
        Cmd.Parameters.Append Cmd.CreateParameter("BARCODE", 200, 1, 2000, barcode)
        Set RS = Cmd.Execute
        If not (RS.BOF and RS.EOF) Then
            GetLocationIDFromBarcode = CStr(RS("LOCATION_ID_FK"))
        Else
            GetLocationIDFromBarcode = ""    
        End If 
        RS.close
        Set Cmd = Nothing
    End If
End Function

Function GetContainerStatusIDFromBarcode(barcode)
    Dim sql
    Dim Cmd
    Dim RS
    If IsBlank(barcode) then 
        GetLocationIDFromBarcode = ""
    Else  
        sql = " SELECT CONTAINER_STATUS_ID_FK FROM " & Application("CHEMINV_USERNAME") & ".INV_CONTAINERS WHERE BARCODE=:BARCODE"
        Set Cmd = GetCommand(Conn, SQL, adCmdText)
        Cmd.Parameters.Append Cmd.CreateParameter("BARCODE", 200, 1, 2000, barcode)
        Set RS = Cmd.Execute
        If not (RS.BOF and RS.EOF) Then
            GetContainerStatusIDFromBarcode = CStr(RS("CONTAINER_STATUS_ID_FK"))
        Else
            GetContainerStatusIDFromBarcode = ""    
        End If 
        RS.close
        Set Cmd = Nothing
    End If
End Function
Function GetContainerTypeIDFromBarcode(barcode)
    Dim sql
    Dim Cmd
    Dim RS
    If IsBlank(barcode) then 
        GetLocationIDFromBarcode = ""
    Else  
        sql = " SELECT CONTAINER_TYPE_ID_FK FROM " & Application("CHEMINV_USERNAME") & ".INV_CONTAINERS WHERE BARCODE=:BARCODE"
        Set Cmd = GetCommand(Conn, SQL, adCmdText)
        Cmd.Parameters.Append Cmd.CreateParameter("BARCODE", 200, 1, 2000, barcode)
        Set RS = Cmd.Execute
        If not (RS.BOF and RS.EOF) Then
            GetContainerTypeIDFromBarcode = CStr(RS("CONTAINER_TYPE_ID_FK"))
        Else
            GetContainerTypeIDFromBarcode = ""    
        End If 
        RS.close
        Set Cmd = Nothing
    End If
End Function
Function GetContainerUOMIDFromBarcode(barcode)
    Dim sql
    Dim Cmd
    Dim RS
    If IsBlank(barcode) then 
        GetContainerUOMIDFromBarcode = ""
    Else  
        sql = " SELECT UNIT_OF_MEAS_ID_FK FROM " & Application("CHEMINV_USERNAME") & ".INV_CONTAINERS WHERE BARCODE=:BARCODE"
        Set Cmd = GetCommand(Conn, SQL, adCmdText)
        Cmd.Parameters.Append Cmd.CreateParameter("BARCODE", 200, 1, 2000, barcode)
        Set RS = Cmd.Execute
        If not (RS.BOF and RS.EOF) Then
            GetContainerUOMIDFromBarcode = CStr(RS("UNIT_OF_MEAS_ID_FK"))
        Else
            GetContainerUOMIDFromBarcode = ""    
        End If 
        RS.close
        Set Cmd = Nothing
    End If
End Function
Function GetRegAndBatchNumber(byVal containerID, byRef regNumber, byRef batchNumber)
    Dim sql
    Dim Cmd
    Dim RS
    If IsBlank(containerid) then 
        GetRegAndBatchNumber = False
    Else  
        sql = "SELECT B.REGNUMBER AS REG_NUM, C.BATCH_NUMBER_FK AS BATCH_NUM, B.REGID AS REGID"
        sql = sql & " FROM " & Application("CHEMINV_USERNAME") & ".INV_CONTAINERS C," & Application("CHEMINV_USERNAME") & ".INV_VW_REG_BATCHES B"
        sql = sql & " WHERE C.CONTAINER_ID=:CONTAINERID AND B.REGID=C.REG_ID_FK"
        Set Cmd = GetCommand(Conn, SQL, adCmdText)
        Cmd.Parameters.Append Cmd.CreateParameter("CONTAINERID", 200, 1, 2000, containerID)
        Set RS = Cmd.Execute
        If not (RS.BOF and RS.EOF) Then
            regNumber = CStr(RS("REG_NUM"))
            RegId = CStr(RS("REGID"))
            batchNumber = CStr(RS("BATCH_NUM"))
            GetRegAndBatchNumber = True
        Else
            GetRegAndBatchNumber = False   
        End If 
        RS.Close
        Set Cmd = Nothing
    End If
End Function

Sub MarkListDeleted (byRef RegDoc, byRef listParent, byVal elementNames)
' RegDoc is the reg XML, listParent is the parent node of the list parameter, e.g. the PropertyList node, 
' elementNames is a comma-separated list of the names elements under the node, e.g. "Project,ProjectID"
    Dim arrElementNames
    Dim topElementName
    Dim listNode


    arrElementNames  = split(elementNames,",")
    topElementName = arrElementNames(0)
    for each listNode in listParent.selectNodes(topElementName)
        if IsNull(listNode.getAttribute("update")) _
          and IsNull(listNode.getAttribute("insert")) _
          and IsNull(listNode.getAttribute("delete")) then
            listNode.setAttribute "delete","yes"
        end if
    next
End Sub

Sub AddToList(byRef RegDoc, byRef listParent, byVal elementNames, byVal listValue, byVal bIsUpdate)
' RegDoc is the reg XML, listParent is the parent node of the list parameter, e.g. the PropertyList node,
' elementNames is a comma-separated list of the names elements under the node, e.g. "Project,ProjectID"
' listValue is the actual value being added to the bottom element, e.g. the project ID.
    Dim arrElementNames
    Dim topElementName
    Dim elementName
    Dim valuePath
    Dim valueNode
    Dim child
    Dim parent
    Dim attr

    arrElementNames= split(elementNames,",")
    topElementName = arrElementNames(0)
    valuePath = ""
    for each elementName in arrElementNames
       if valuePath <> "" then
           valuePath = valuePath & "/"
       end if
       valuePath = valuePath & elementName
    next
    valuePath = valuePath & "[.=""" & listValue & """]"
    set valueNode = listParent.selectSingleNode (valuePath)
    if valueNode is nothing then
        set parent = listParent
        for each elementName in arrElementNames
            Set child = RegDoc.CreateElement(elementName)
            parent.AppendChild(child)
            if bIsUpdate then
                child.setAttribute "insert","yes"
            end if
            set parent = child
        next
        child.text = listvalue
    elseif bIsUpdate then
        set child = valueNode
        for each elementName in arrElementNames
            child.removeAttribute("delete")
            Set child = child.parentNode
        next
    end if     
End Sub

Function InterpretRegResponse(byVal regResponse, byRef message, byRef regID, byRef batchNumber)
    Dim xmlResponse
    Dim node
    Dim action
    
    set xmlResponse = Server.CreateObject("Msxml2.DOMDocument")
    xmlResponse.async = false
    xmlResponse.loadXML(regResponse)

    set node = xmlResponse.selectSingleNode("/ReturnList/ActionDuplicateTaken")
    if node is nothing then
        regID = ""
        batchNumber = ""
        message = "Unknown Registry response: " & regResponse
        InterpretRegResponse = "?"
    else
        action = node.text
        set node = xmlResponse.selectSingleNode("/ReturnList/RegID")
        regID = node.text
        set node = xmlResponse.selectSingleNode("/ReturnList/BatchNumber")
        batchNumber = node.text
        select case ucase(action)
            'Not a duplicate, new compound and batch created
            case "N"
                message = "New compound registered, RegID=" & regID & ", BatchNumber=" & batchNumber 
                InterpretRegResponse = "N"
            'Batch created
            case "B"
                message = "New batch created, RegID=" & regID & ", BatchNumber=" & batchNumber 
                InterpretRegResponse = "B"
            'Temporary (not in use)
            'case "T"
            '	message = "Temporary compound created, RegID=" & regID & ", BatchNumber=" & batchNumber 
            '	InterpretRegResponse = "T"
            'Duplicate compound
            case "D"
                message = "Duplicate compound registered RegID=" & regID & ", BatchNumber=" & batchNumber 
                InterpretRegResponse = "D"
            'Unknown
            case else
                regID = ""
                batchNumber = ""
                message = "Unknown Registry action returned: " & regResponse
                InterpretRegResponse = "?"
        end select
    end if
    'CBOE-1159 if chemical Warning exists add it as error node: ASV 10JUL13
    set node = xmlResponse.selectSingleNode("/ReturnList/RedBoxWarning")
    if not (node is Nothing) then
        message = message & " " & node.text
    End if
End Function

' For debugging
Function SafeStr(str)
    If IsNull(str) then
        SafeStr = ""
    Else
        SafeStr = CStr(str)
    End If
End Function

Server.ScriptTimeout = 3600 '1 hour timeout
Dim Conn
Dim Cmd
Dim isCommit
Dim aValuePairs
Dim strReturn
Dim RegId

bDebugPrint = False
bWriteError = False
bFailure = false
strError = "Error:<BR>"

LocationID = NULL
UOMID = NULL
QtyMax = NULL
QtyInitial = NULL
ContainerTypeID = NULL
ContainerStatusID = NULL
actionType = NULL
Response.Expires = -1

RegServerName = Application("RegServerName")
InvServerName = Application("InvServerName")

isCommit = true

'-- base64_cdx for empty structure
INVMTCDX = "VmpDRDAxMDAEAwIBAAAAAAAAAAAAAAAAAAAAAAMAEAAAAENoZW1EcmF3IDYuMC4xCAAMAAAAbXl0ZXN0LmNkeAADMgAIAP///////wAAAAAAAP//AAAAAP////8AAAAA//8AAAAA/////wAAAAD/////AAD//wEJCAAAAFkAAAAEAAIJCAAAAKcCAAAXAgIIEAAAAAAAAAAAAAAAAAAAAAAAAwgEAAAAeAAECAIAeAAFCAQAAJoVAAYIBAAAAAQABwgEAAAAAQAICAQAAAACAAkIBAAAswIACggIAAMAYAC0AAMACwgIAAQAAADwAAMADQgAAAAIeAAAAwAAAAEAAQAAAAAACwARAAAAAAALABEDZQf4BSgAAgAAAAEAAQAAAAAACwARAAEAZABkAAAAAQABAQEABwABJw8AAQABAAAAAAAAAAAAAAAAAAIAGQGQAAAAAAJAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAEAhAAAAD+/wAA/v8AAAIAAAACAAABJAAAAAIAAwDkBAUAQXJpYWwEAOQEDwBUaW1lcyBOZXcgUm9tYW4BgAEAAAAEAhAAAAD+/wAA/v8AAAIAAAACAA8IAgABABAIAgABABYIBAAAACQAGAgEAAAAJAAAAAAA"
REGMTCDX = "VmpDRDAxMD"

'This XML load should be moved where it is done less often

sURL = Server.MapPath("\cheminv\config\invloader.xml")
Set oFieldXML = CreateObject("MSXML2.DOMDocument")
oFieldXML.async = False
oFieldXML.load sURL
If Len(oFieldXML.xml) = 0 then
    Response.Write "Error: Could not load invloader.xml<BR>"
    Response.end
End if

'Create the parser object
dim xmlDoc
set xmlDoc = Server.CreateObject("Msxml2.DOMDocument")
xmlDoc.async = false

'Load ActionBatchFile if exists or request object
xmlDoc.load(request)

Set root = xmlDoc.documentElement
AddAttributeToElement xmlDoc, root, "timeStamp", CStr(Now())
AddAttributeToElement xmlDoc, root, "actionType", action
'CSBR ID     : 128893
'Modified by : sjacob
'Comments    : Adding code to authenticate LDAP users.
'Start of change
RegUserName = root.getAttribute("CSUSERNAME")
RegPwd = root.getAttribute("CSUSERID")
' Set Cred. for Create Substance
CSUserName = root.getAttribute("CSUSERNAME")
CSUserID = root.getAttribute("CSUSERID")

IsLDAPUser = IsValidLDAPUser(CSUserName, CSUserID)
If IsLDAPUser = 1 Then
    CSUserID = GeneratePwd(CSUserName)
End If
'End of change

'To check if Registration option is selected
'CSBR 126952 : sjacob
RegisterCompounds = root.getAttribute("REGISTERCOMPOUNDS")
If RegisterCompounds then
    sURL = Server.MapPath("\cheminv\config\invloader.xml")
    Set FieldXML = CreateObject("MSXML2.DOMDocument")
    FieldXML.async = False
    FieldXML.load sURL

    If Len(FieldXML.xml) = 0 then
        Response.Write "Error: Could not load invloader.xml<BR>"
        Response.end
    End if
End If

' Set ID expected by GetCreateContainer_cmd
CurrentUserID = root.getAttribute("CSUSERID")

' get update status
update = root.getAttribute("UPDATE")
updatecompound = root.getattribute("UPDATECOMPOUNDS")

' Get the connection
GetSessionlessInvConnection()

' Find existing containers, set their CONTAINERID
If update = "ALL" or update = "NONNULL" then
    For Each actionNode In root.SelectNodes("CREATECONTAINER")
       barcode = actionNode.SelectSingleNode("OPTIONALPARAMS/BARCODE").text
       sLocationId = actionNode.getattribute("LOCATIONID")
       sContainerStatusID = actionNode.getattribute("CONTAINERSTATUSID")
       sContainerTypeID = actionNode.getattribute("CONTAINERTYPEID")
       sContainerUOMID = actionNode.getattribute("UOMID")
       If sLocationId="-1" then
            sLocationId = GetLocationIDFromBarcode(barcode)
       end if
       If sContainerStatusID = "" then
            sContainerStatusID = GetContainerStatusIDFromBarcode(barcode)
       end if
       If sContainerTypeID = "" then
            sContainerTypeID = GetContainerTypeIDFromBarcode(barcode)
       end if
       If sContainerUOMID = "" then
            sContainerUOMID = GetContainerUOMIDFromBarcode(barcode)
       end if     
       containerID = GetContainerIDFromBarcode(barcode)
       If Not IsBlank(containerID) then
           AddAttributeToElement xmlDoc, actionNode, "UPDATE_CONTAINERID", containerId
       End If
       If Not IsBlank(sLocationId) then
           actionNode.setattribute "LOCATIONID", sLocationId
       End If
       If Not IsBlank(sContainerStatusID) then
           actionNode.setattribute "CONTAINERSTATUSID", sContainerStatusID
       End If
       If Not IsBlank(sContainerTypeID) then
           actionNode.setattribute "CONTAINERTYPEID", sContainerTypeID
       End If
       If Not IsBlank(sContainerUOMID) then
           actionNode.setattribute "UOMID", sContainerUOMID
       End If
    Next 
End If

'Process CREATESUBSTANCE Tags
For Each actionNode In root.SelectNodes("CREATESUBSTANCE")
    'Response.Write("In Create Substance")
    FormData = ""
    For Each reqAttrib In actionNode.Attributes
        '-- InvLoader 9.1 is adding substance name as an attribute and as a sub-element of CREATESUBSTANCE so for now i'll check for it here and not add it twice
        if reqAttrib.NodeName <> "SUBSTANCE_NAME" then
            FormData = FormData & "&inv_compounds." & reqAttrib.NodeName & "=" & Server.URLEncode(reqAttrib.text)
        end if
    Next
    FormData = FormData & "&inv_compounds.substance_name=" & Server.URLEncode(actionNode.SelectSingleNode("substanceName").text) 
    strucData = actionNode.SelectSingleNode("structure").text 
    if Len(strucData) > 0 then
        FormData = FormData & "&inv_compounds.structure=" & Server.URLEncode(strucData)
    else
        FormData = FormData & "&inv_compounds.structure=" & Server.URLEncode(INVMTCDX)
        'FormData = FormData & "&inv_compounds.structure="
    end if
    FormData = Right(FormData, Len(FormData)-1)
    ServerName = Application("InvServerName")
    'CSBR-156006: SJ
    Credentials = "&CSUserName=" & Server.URLEncode(CSUserName) & "&CSUserID=" & Server.URLEncode(CSUserID)
    'Target = "/cheminv/api/CreateSubstance.asp?ResolveConflictsLater=1&RegisterIfConflicts=true&action=" & action
    Target = "/cheminv/api/CreateSubstance.asp?action=" & action
    
    FormData = FormData & Credentials & "&ResolveConflictsLater=1&RegisterIfConflicts=true"
    'FormData = FormData & Credentials
    'logaction(formData)
    sendTO = 5*60*1000
    receiveTO = 5*60*1000
    httpResponse = CShttpRequest3("POST", ServerName, Target, "ChemInv", FormData, sendTO, receiveTO)
    
    firstQuote = InStr(1,httpResponse,"""")
    secondQuote = InStr(firstQuote +1,httpResponse,"""")
    cID = Mid(httpResponse, firstQuote + 1 , SecondQuote - firstQuote - 1)
    
    Select Case true
        Case inStr(1,httpResponse,"<DUPLICATESUBSTANCE") > 0
            result = "WARNING"
            message = "Duplicate substance created CompoundID= " & cID
        Case inStr(1,httpResponse,"<NEWSUBSTANCE") > 0
            result = "SUCCEEDED"
            message = "New substance created " & cID
        Case inStr(1,httpResponse,"<EXISTINGSUBSTANCE") > 0
            result = "SUCCEEDED"
            message = "Existing substance used CompoundID= " & cID
        Case inStr(1,httpResponse,"<CONFLICTINGSUBSTANCES") > 0
            result = "SUCCEEDED"
            message = "Conflicting substance created, CompoundID= " & cID
        Case else
            Response.Write "Error while creating inventory substance.<BR>"
            Response.Write httpResponse & "<BR><BR>"
    End Select
    CreateOrReplaceNode xmlDoc, "RETURNVALUE", actionNode, message, "RESULT", result
    Set returnValueNode = actionNode.SelectSingleNode("RETURNVALUE")
    AddAttributeToElement xmlDoc, returnValueNode, "COMPOUNDID", cID
    packageID = ActionNode.SelectSingleNode("./@PACKAGEID").text
    Set MatchingNode = root.SelectSingleNode("CREATECONTAINER[@ID='" & packageID & "']")
    AddAttributeToElement xmlDoc, MatchingNode, "CompoundID", cID
    actionNode.removeChild(actionNode.SelectSingleNode("structure"))
    'Response.Write(packageID)
    Response.Write ""
    Response.Flush
        
Next 

' Process REGISTERSUBSTANCE Tags
' ------------------------------
'Only if Registration is selected.
'CSBR 126952 : sjacob
If RegisterCompounds Then
    Dim soapClient
    Dim headerHandler
    Dim strXMLTemplate
    Dim xmlReg
    Dim nodes
    Dim node
    Dim structNode
    Dim strDupFlag
    Dim strXMLResponse
    Dim oSelection
    Dim sRLS
    Dim bNewReg 
    '  Set up SOAP client
    set soapClient = Server.CreateObject("MSSOAP.SoapClient30")
    set headerHandler = Server.CreateObject("COEHeaderServer.COEHeaderHandler")
    'CSBR ID     : 128893
    'Modified by : sjacob
    'Comments    : Changed the CsUsername and CsUserId to RegUserName and RegPwd.
    headerHandler.UserName = RegUserName
    headerHandler.Password = RegPwd
    set soapClient.HeaderHandler = headerHandler
    soapClient.ClientProperty("ServerHTTPRequest") = True
    call soapClient.MSSoapInit(Application("SERVER_TYPE") & RegServerName & "/COERegistration/webservices/COERegistrationServices.asmx?wsdl")
    soapClient.ConnectorProperty("Timeout") = 120000    ' sets timeout to 120 secs
    'Get registration XML template
    strXMLTemplate = soapClient.RetrieveNewRegistryRecord()
    'strXMLTemplate = soapClient.SetModuleName(strXMLTemplate, "INVLOADER") 'CBOE-1159 method for adding module name in xml template : ASV 10JUL13

    for each actionNode in root.SelectNodes("REGISTERSUBSTANCE")
        bNewReg = True
        ' Find the matching container node, to save results
        packageID = ActionNode.SelectSingleNode("./@PACKAGEID").text
        Set MatchingNode = root.SelectSingleNode("CREATECONTAINER[@ID='" & packageID & "']")

        ' Find out if we are updating an existing compound
        containerID = MatchingNode.getAttribute("UPDATE_CONTAINERID")
        if not IsBlank(containerID) then
            if not GetRegAndBatchNumber(ContainerID,regNumber,batchNumber) then
                Response.Write "Error:Failed to find Registration compound for Container ID " & CStr(ContainerID)
                response.End
            else
                bUpdateReg = True
            end if
        else
            bUpdateReg = False
        end if
    ' kfd debug -----------------
    '    Response.write vbCrLf & "bUpdateReg: " & SafeStr(bUpdateReg) & ", updatecompound " & SafeStr(updatecompound) & ", ContainerID: " & SafeStr(ContainerID) & ", regNumber: " & SafeStr(regNumber) & ", batchNumber: " & SafeStr(batchNumber) & vbCrLf & vbCrLf
    '    Response.flush
    ' ---------------------------
        if (not bUpdateReg) or (bUpdateReg and (updatecompound = "ALL" or updatecompound = "NONNULL")) then
        
            bUpdateNonnull = bUpdateReg and (updatecompound = "NONNULL")
        'Create the registration XML
            set xmlReg = Server.CreateObject("Msxml2.DOMDocument")
            xmlReg.async = false
            if bUpdateReg then
                bNewReg = False
                strXMLRecord = soapClient.RetrieveRegistryRecord(regNumber)
                xmlReg.loadXML(strXMLRecord)
                set oBatch = xmlReg.SelectSingleNode("/MultiCompoundRegistryRecord/BatchList/Batch[./BatchNumber='" & batchNumber & "']")
                RegStatus = xmlReg.selectSingleNode("/MultiCompoundRegistryRecord/StatusID").text
                If RegStatus="4" Then 'CSBR 166392 SJ Checking if the record is Locked.
                    bUpdateReg = False   
                End If
            else
                xmlReg.loadXML(strXMLTemplate)
                set oBatch = xmlReg.SelectSingleNode("/MultiCompoundRegistryRecord/BatchList/Batch")
                'CSBR-165570: For creating containers and register compounds in Registry when RLS=BATCH
                set NodeRLS = xmlReg.SelectSingleNode("MultiCompoundRegistryRecord")
                sRLS = NodeRLS.getAttribute("ActiveRLS")
                If sRLS = "BatchLevelProjects" Then
                    CreateNode xmlReg, "ProjectList", oBatch, "", "", ""
                End If
            end if   

            'RAG
           ' Set Module Name, 'CBOE-1159 method for adding module name in xml template RAG
            set regnode = xmlReg.SelectSingleNode("MultiCompoundRegistryRecord")
            
            if not (regnode is Nothing) then
                for each actionAttr in regnode.Attributes
                    strAttrName = UCase(actionAttr.Name)
                     
                    if strAttrName = "MODULENAME" then
                         actionAttr.Value = "INVLOADER"
                    end if
                next
            end if    

        'Remove the validation nodes
            Set oSelection = xmlReg.selectNodes("//validationRuleList")
            oSelection.removeAll()

        'Remove the AddIn nodes
            Set oSelection = xmlReg.selectNodes("/MultiCompoundRegistryRecord/AddIns")
            oSelection.removeAll()
           
        'Transfer actionNode parameters into xmlReg document
            for each actionElem in actionNode.SelectNodes("*")
                strElemName = UCase(actionElem.nodeName)
                strElemText = actionElem.text
                ' Process special nodes
                if strElemName = "REGPARAMETER" then
                    select case strElemText 
                        case "B","D","N"
                            strDupFlag = strElemText    ' Add New (B)atch, Add New Compound (D)uplicate, Ignore Compound (N)ot store
                        case else
                            Response.write "Illegal DupFlag " & strElemText
                            Response.end
                    end select

                elseif strElemName = "STRUCTURE" then
                    set node = xmlReg.SelectSingleNode("/MultiCompoundRegistryRecord/ComponentList/Component/Compound/BaseFragment/Structure/Structure")
                    if not (node is Nothing) then
                        if not ((strElemText = "No Structure" or strElemText = "") and bUpdateNonnull) then
                            set node1 = xmlReg.SelectSingleNode("/MultiCompoundRegistryRecord/ComponentList/Component/Compound/BaseFragment/Structure/StructureID")
                            if strElemText = "No Structure" or strElemText = "" then
                                CreateOrReplaceText xmlReg,node,""
                                CreateOrReplaceText xmlReg,node1,"-2"
                            else
                                CreateOrReplaceText xmlReg,node,strElemText
                                CreateOrReplaceText xmlReg,node1,node1.nodetypedvalue
                            end if
                        end if
                    end if

                else
                    ' kfd debug -----------------
                    ' Response.write vbCrLf & "Processing: " & strElemName & " value: " & strElemText & vbCrLf
                    ' ---------------------------
                    set oFieldNode = oFieldXML.SelectSingleNode("/invloader/regfields/regfield[@name='" & strElemName & "']")
                    if not oFieldNode is nothing then
                        strFieldType = oFieldNode.GetAttribute("type")
                        if strFieldType = "BATCH" then
                            set node = oBatch.SelectSingleNode(oFieldNode.text)
                        else
                            set node = xmlReg.SelectSingleNode(oFieldNode.text)
                        end if
                        if not node is nothing then
                            if node.TagName = "BatchComponentFragment" then 'CSBR 162116 SJ Appending the Fragment,Equivalents to the xmlReg
                               set node1 = xmlReg.SelectSingleNode("/MultiCompoundRegistryRecord/BatchList/Batch/BatchComponentList/BatchComponent/BatchComponentFragmentList")
                               for each subnode in node1.SelectNodes("*")
                                   if subnode.SelectSingleNode("Equivalents") Is Nothing then
                                      set node = subnode  
                                      exit for 
                                   end if
                                next
                            end if
                             
                             'SMathur CSBR-167768 - appending the Indenter, InputText to XmlReg
                             ' for Reg identifier
                             If node.tagName = "Identifier" And strFieldType <> "BATCH" Then 
                               Set node1 = xmlReg.selectSingleNode("/MultiCompoundRegistryRecord/IdentifierList")
                               For Each subnode In node1.selectNodes("*")
                                   If subnode.selectSingleNode("InputText") Is Nothing Then
                                      Set node = subnode
                                      Exit For
                                   End If
                                Next
                            End If
                            ' for Batch identifier
                            If node.tagName = "Identifier" And strFieldType = "BATCH" Then  
                               Set node1 = xmlReg.selectSingleNode("/MultiCompoundRegistryRecord/BatchList/Batch/IdentifierList")
                               For Each subnode In node1.selectNodes("*")
                                   If subnode.selectSingleNode("Batch_InputText") Is Nothing Then
                                      Set node = subnode
                                      Exit For
                                   End If
                                Next
                           End If
                            ' for Structure identifier
                           If node.tagName = "Identifier" And strFieldType = "COMPOUND" Then
                               Set node1 = xmlReg.selectSingleNode("/MultiCompoundRegistryRecord/ComponentList/Component/Compound/BaseFragment/Structure/IdentifierList")
                               For Each subnode In node1.selectNodes("*")
                                   If subnode.selectSingleNode("Structure_InputText") Is Nothing Then
                                     Set node = subnode
                                     Exit For
                                  End If
                                Next
                          End If
                          
                           ' for Component identifier
                           If node.tagName = "Identifier" And strFieldType = "COMPOUND" Then
                               Set node1 = xmlReg.selectSingleNode("/MultiCompoundRegistryRecord/ComponentList/Component/Compound/IdentifierList")
                               For Each subnode In node1.selectNodes("*")
                                   If subnode.selectSingleNode("Component_InputText") Is Nothing Then
                                     Set node = subnode
                                     Exit For
                                  End If
                                Next
                          End If
                            strFieldListElement = oFieldNode.GetAttribute("listelement")
                            if IsBlank(strFieldListElement) then
                                ' Simple attribute
                                if not (IsBlank(strElemText) and bUpdateNonnull) then
                                    CreateOrReplaceText  xmlReg,node,strElemText
                                    if bUpdateReg then
                                        node.setAttribute "update","yes"
                                    end if
                                end if
                            else
                                ' List attribute
                                if not (IsBlank(strElemText) and bUpdateNonnull) then
                                    if bUpdate then
                                        MarkListDeleted xmlReg,node,strFieldListElement
                                    end if
                                    if not IsBlank(strElemText) then
                                        AddToList xmlReg,node,strFieldListElement,strElemText,bUpdateReg
                                    end if
                                end if
                            end if
                        end if
                    end if
                end if
            next
           'SMathur CSBR-167768 -Add order index for  Identifier for reg, batch and Fragment level
            Set node1 = xmlReg.selectSingleNode("/MultiCompoundRegistryRecord/IdentifierList")
            count = 1
            For Each subnode In node1.selectNodes("Identifier")
                Set obj1 = xmlReg.createElement("OrderIndex")
                obj1.text = count
                subnode.appendChild obj1
                count = count + 1
             Next

            ' for batch identifier
            Set node1 = xmlReg.selectSingleNode("/MultiCompoundRegistryRecord/BatchList/Batch/IdentifierList")
            count = 1   
            For Each subnode In node1.selectNodes("Identifier")
                Set obj1 = xmlReg.createElement("OrderIndex")
                obj1.text = count
                subnode.appendChild obj1
                count = count + 1

            Next

            ' for Structure identifier
            Set node1 = xmlReg.selectSingleNode("/MultiCompoundRegistryRecord/ComponentList/Component/Compound/BaseFragment/Structure/IdentifierList")
            count = 1
            For Each subnode In node1.selectNodes("Identifier")
                Set obj1 = xmlReg.createElement("OrderIndex")
                obj1.text = count
                subnode.appendChild obj1
                count = count + 1
            Next
            
            ' for Component identifier
            Set node1 = xmlReg.selectSingleNode("/MultiCompoundRegistryRecord/ComponentList/Component/Compound/IdentifierList")
            count = 1
            For Each subnode In node1.selectNodes("Identifier")
                Set obj1 = xmlReg.createElement("OrderIndex")
                obj1.text = count
                subnode.appendChild obj1
                count = count + 1
            Next

            'replace custom tags for batch and fragment level
            xmlReg.loadXML (Replace(xmlReg.xml, "Batch_InputText", "InputText"))
            xmlReg.loadXML (Replace(xmlReg.xml, "Structure_InputText", "InputText"))
            xmlReg.loadXML (Replace(xmlReg.xml, "Component_InputText", "InputText"))
            
           
            if bUpdateReg then
                strRegFull = xmlReg.xml
                set oSelection = xmlReg.SelectNodes("/MultiCompoundRegistryRecord/BatchList/Batch[not(BatchNumber='" & batchNumber & "')]")
                oSelection.RemoveAll
                xmlReg.loadXML(strRegFull)
                strXMLResponse = soapClient.UpdateRegistryRecord(xmlReg.xml)
            else
                RegResult = ""
                If bNewReg Then
                    'Send the reg document off to be registered
                    on error resume next
                    strXMLResponse = soapClient.CreateRegistryRecord(xmlReg.xml,strDupFlag)
                    regaction = InterpretRegResponse(strXMLResponse, message, regIDReturned, batchNumberReturned)
                    if regIDReturned =0 and batchNumberReturned = 1 then
                        RegResult = "CompoundNotAdded"
                    end if
                End If
            end if         
            
            if regaction = "?" then
                result = "WARNING"
            else
                result = "SUCCEEDED"
            end if

            CreateOrReplaceNode xmlDoc, "RETURNVALUE", actionNode, message, "RESULT", result
            set returnValueNode = actionNode.SelectSingleNode("RETURNVALUE")
            AddAttributeToElement xmlDoc, returnValueNode, "REGID", cStr(regIDReturned)
            AddAttributeToElement xmlDoc, returnValueNode, "BATCHNUMBER", batchNumberReturned
            AddAttributeToElement xmlDoc, MatchingNode, "REGID", cStr(regIDReturned)
            AddAttributeToElement xmlDoc, MatchingNode, "BATCHNUMBER", batchNumberReturned
            actionNode.removeChild(actionNode.SelectSingleNode("structure"))
           ' CSBR-168047  Smathur - Adding details in the logfile 
            if (result = "WARNING" or err.number > 0 or RegResult = "CompoundNotAdded") then               
                CreateOrReplaceNode xmlDoc, "INPUTVALUES", actionNode, "", "", ""
                 set Inputvaluenode = actionNode.SelectSingleNode("INPUTVALUES")
                 sPackageID = actionNode.getattribute("PACKAGEID")
                 Set ParentContainerNode = root.SelectSingleNode("CREATECONTAINER[@ID='" & sPackageID & "']")
                 Set node = xmlDoc.createElement("INPUTVALUES")
                 For x = 0 To (ParentContainerNode.Attributes.length - 1)
                    sAttrName = ParentContainerNode.Attributes.Item(x).nodeName  
                    sAttrVal=ParentContainerNode.Attributes.Item(x).nodeValue
                    AddAttributeToElement xmlDoc, Inputvaluenode, sAttrName, sAttrVal
                 next
                 for each ContainerActionNode in ParentContainerNode.SelectNodes("OPTIONALPARAMS/*")
                    sAttrName = UCase(ContainerActionNode.nodeName)
                    sAttrVal = ContainerActionNode.text
                    if sAttrVal <>"" then
                        AddAttributeToElement xmlDoc, Inputvaluenode, sAttrName, sAttrVal
                    end if               
                next
                AddAttributeToElement xmlDoc, ParentContainerNode, "RegError", "1"
            end if
            Response.Write ""
            Response.Flush
    
        end if

    Next 
End If

' GetSessionlessInvConnection()

'Process MOVECONTAINER Tags
set actionNodeList = root.SelectNodes("MOVECONTAINER")
if actionNodeList.length > 0 then
    Set GetPrimaryKeyCmd = Server.CreateObject("ADODB.Command")
    Set GetPrimaryKeyCmd.ActiveConnection = Conn
    GetPrimaryKeyCmd.CommandType = adCmdStoredProc
    GetPrimaryKeyCmd.CommandText = Application("CHEMINV_USERNAME") & ".GETPRIMARYKEYIDS"
    Set PKReturnValueParam = GetPrimaryKeyCmd.CreateParameter("RETURN_VALUE", adVarChar, adParamReturnValue, 32000, NULL)
    GetPrimaryKeyCmd.Parameters.Append PKReturnValueParam
    Set TableNameParam = GetPrimaryKeyCmd.CreateParameter("PTABLENAME", adVarChar, adParamInput, 1, "")
    GetPrimaryKeyCmd.Parameters.Append TableNameParam
    Set TableValuesParam = GetPrimaryKeyCmd.CreateParameter("PTABLEVALUES", adVarChar, adParamInput, 1, "")
    GetPrimaryKeyCmd.Parameters.Append TableValuesParam
    GetPrimaryKeyCmd.Prepared = true

    Set MoveContainerCmd = Server.CreateObject("ADODB.Command")
    Set MoveContainerCmd.ActiveConnection = Conn
    MoveContainerCmd.CommandType = adCmdStoredProc
    MoveContainerCmd.CommandText = Application("CHEMINV_USERNAME") & ".MOVECONTAINER"
    Set MCReturnValueParam = MoveContainerCmd.CreateParameter("RETURN_VALUE", adVarChar, adParamReturnValue, 8000, NULL)
    MoveContainerCmd.Parameters.Append MCReturnValueParam
    Set LocationIDParam = MoveContainerCmd.CreateParameter("PLOCATIONID", adVarChar, adParamInput, 1, "")
    MoveContainerCmd.Parameters.Append LocationIDParam
    Set ContainerIDParam = MoveContainerCmd.CreateParameter("PCONTAINERID", adVarChar, adParamInput, 1, "")
    MoveContainerCmd.Parameters.Append ContainerIDParam
    MoveContainerCmd.Prepared = true

    For Each actionNode In actionNodeList
        ContainerID = null
        LocationID = null
        message = ""
        For Each reqAttrib In actionNode.Attributes
            if reqAttrib.NodeName = "CONTAINER_BARCODE" then
                ContainerBarcode = CnvString(reqAttrib.text)
                TableNameParam.size = Len("inv_containers")
                TableNameParam.value = "inv_containers"	        
                TableValuesParam.size = Len(ContainerBarcode)
                TableValuesParam.value = ContainerBarcode
                strReturn = ExecuteOracleFunction( GetPrimaryKeyCmd, "GETPRIMARYKEYIDS" )
                if strReturn <> "" then
                    message = strReturn
                else
                    if (instr(PKReturnValueParam.value,"Error") > 0) then
                        message = PKReturnValueParam.value
                    elseif (PKReturnValueParam.value <> "NOT FOUND") then	                    
                        aValuePairs = split(PKReturnValueParam.value, "=")
                        if UBound(aValuePairs) > 0 then
                            ContainerID = aValuePairs(1)
                        end if
                    end if
                end if
            elseif reqAttrib.NodeName = "LOCATION_BARCODE" then
                LocationBarcode = CnvString(reqAttrib.text)
                TableNameParam.size = Len("inv_locations")
                TableNameParam.value = "inv_locations"
                TableValuesParam.size = Len(LocationBarcode)
                TableValuesParam.value = LocationBarcode
                strReturn = ExecuteOracleFunction( GetPrimaryKeyCmd, "GETPRIMARYKEYIDS" )
                if strReturn <> "" then
                    message = strReturn
                else
                    if (instr(PKReturnValueParam.value,"Error") > 0) then
                        message = PKReturnValueParam.value
                    elseif (PKReturnValueParam.value <> "NOT FOUND") then
                        aValuePairs = split(PKReturnValueParam.value, "=")
                        if UBound(aValuePairs) > 0 then
                            LocationID = aValuePairs(1)
                        end if
                    end if
                end if
            end if
        Next
        
        if not IsNull(ContainerID) and not IsNull(LocationID) then
            LocationIDParam.size = Len(LocationID)
            LocationIDParam.value = LocationID
            ContainerIDParam.size = Len(ContainerID)
            ContainerIDParam.value = ContainerID
            strReturn = ExecuteOracleFunction( MoveContainerCmd, "MOVECONTAINER" )
            if strReturn <> "" then
                result = "FAILED"
                message = strReturn
            else            
                if (instr(MCReturnValueParam.value,"Error") > 0) then
                    result = "FAILED"
                    message =  MCReturnValueParam.value
                else
                    result = "SUCCEEDED"
                    message = "Container moved"
                end if
            end if
        else
            result = "FAILED"		    
        end if	
        
        CreateOrReplaceNode xmlDoc, "RETURNVALUE", actionNode, message, "RESULT", result
        Set returnValueNode = actionNode.SelectSingleNode("RETURNVALUE")
        Response.Write ""
        Response.Flush
    Next 
    
    set GetPrimaryKeyCmd = nothing
    set MoveContainerCmd = nothing

end if      ' if actionNodeList.length > 0 then


' Process CREATECONTAINER Tags
' ----------------------------

'The following vars are expected by the GetOrderContainer_cmd but are reset later as params
DueDate="1/1/2000"
Project="1"
Job="1"
DeliveryLocationID="1"
ActionNodeName = "CREATECONTAINER"

bIsFirst = True
lastCommandText = "not a command"

Set Cmd = Server.CreateObject("ADODB.Command")
Set Cmd.ActiveConnection = Conn
Cmd.CommandType = adCmdStoredProc

For Each actionNode In root.SelectNodes(ActionNodeName)

    ' TODO generalize to other actions
    actionName = actionNode.NodeName

    ' Find out if we are updating an existing container
    if update = "ALL" or update = "NONNULL" then
        containerID = actionNode.getAttribute("UPDATE_CONTAINERID")
        bUpdateCont = not IsBlank(containerID)
        bUpdateContAll = bUpdateCont and (update="ALL")
    end if
   
    if bUpdateCont then
        if update="ALL" then
            CommandText = Application("CHEMINV_USERNAME") & ".UpdateAllContainerFields"
        else
            CommandText = Application("CHEMINV_USERNAME") & ".UpdateNonnullContainerFields"
        end if
    else
        CommandText = Application("CHEMINV_USERNAME") & ".CreateContainer"
    end if
    Cmd.CommandText = CommandText

    if bIsFirst or lastCommandText <> CommandText then
        if not bIsFirst then Call DeleteParameters()
        if bUpdateCont then
            Call GetUpdateContainer_parameters()
        else
            Call GetCreateContainer_parameters()
        end if
    end if
    bIsFirst = False
    lastCommandText = CommandText
' kfd debug -----------------
'    Response.write vbCrLf & "Cmd.CommandText " & vbCrLf & Cmd.CommandText & vbCrLf & vbCrLf
'    Response.flush
' ---------------------------
    
    if bUpdateCont then
        Cmd.Parameters("pCONTAINERID") = ContainerID
        if update="ALL" then   'CSBR 167408 SJ Sending the regid and batchnumber so that the Regbatch id and structure will not be removed.
            if GetRegAndBatchNumber(ContainerID,null,null) then
                cmd.Parameters("PREGID") = RegId
                cmd.Parameters("PBATCHNUMBER") = batchNumber
            end if
        end if
    end if
   RegError = ""
    'Loop the required params
    for each reqAttrib In actionNode.Attributes
        if reqAttrib.NodeName = "RegError" then 
            RegError = CnvString(reqAttrib.text)
        end if
        if reqAttrib.NodeName <> "UPDATE_CONTAINERID" and reqAttrib.NodeName <> "ID" and reqAttrib.NodeName <> "RegError" then   ' exclude operational attributes
            if not (bUpdateCont and (reqAttrib.NodeName = "INITIALQTY" or reqAttrib.NodeName = "NUMCOPIES")) then     ' exclude non-edit fields
                pname= "P" & UCase(reqAttrib.NodeName)
                if pname = "PREGID" then    'CSBR 167509 SJ If dup action is Ignore compound then regid and batchnumber parameters will have null values.
                    if reqAttrib.text = "0" then
                        RegId = reqAttrib.text
                        Cmd.Parameters(pname) = null
                    else
                        RegId = reqAttrib.text
                        Cmd.Parameters(pname) = CnvString(reqAttrib.text)
                    end if
                elseif pname = "PBATCHNUMBER" then
                    if RegId = 0 then
                        Cmd.Parameters(pname) = null
                    else
                        Cmd.Parameters(pname) = CnvString(reqAttrib.text)    
                    end if  
                else
                    if reqAttrib.text <> ""  then
                        Cmd.Parameters(pname) = CnvString(reqAttrib.text)
                    end if
                end if
            end if
        end if
    next ' required Attribute

    Cmd.Parameters("pCurrentUserID") = ucase(CSUserName)
    
    'Loop optional attributes
    For Each optAttrib In actionNode.selectNodes("./OPTIONALPARAMS/*")
        if not (bUpdateCont and optAttrib.NodeName = "NUMCOPIES") then     ' exclude non-edit fields
        ' kfd debug -----------------
        '    Response.write "Parameter (opt) " & UCase(optAttrib.NodeName) & "=" & CnvString(optAttrib.text) & vbCrLf 
        '    Response.flush
        ' ---------------------------
            Cmd.Parameters("P" & UCase(optAttrib.NodeName)) = CnvString(optAttrib.text)
        end if
    Next ' optional attribute

    if bDebugPrint then
        For each p in Cmd.Parameters
            Response.Write p.name & " = " & p.value & vbcrlf
        Next
        Response.write "<HR>"
    Else
       if  bUpdateCont or (ActionNodeName ="CREATECONTAINER" and RegError <> "1") then 
            Call ExecuteCmd(CommandText)
            returnCode =  Cstr(Cmd.Parameters("RETURN_VALUE"))

            if returnCode > 0 then
                result = "SUCCEEDED"
                message = "ContainerID " & returnCode
            Else
                bFailure = true
                result = "FAILED"
                message = Application(returnCode)
            End if
            CreateOrReplaceNode xmlDoc, "RETURNVALUE", actionNode, message, "RESULT", result
            Set returnValueNode = actionNode.SelectSingleNode("RETURNVALUE")
            AddAttributeToElement xmlDoc, returnValueNode, "CONTAINERID", returnCode
            CreateOrReplaceNode xmlDoc, "RETURNCODE", actionNode, returnCode, "", null
            actionNode.removeChild(actionNode.SelectSingleNode("OPTIONALPARAMS"))
       End if 
    End if
    bIsFirst = false
    
    Response.Write ""
    Response.Flush	
Next ' actionNode

AddAttributeToElement xmlDoc, root, "ErrorsFound", Cstr(bFailure)
Root.removeAttribute ("CSUSERNAME")
Root.removeAttribute ("CSUSERID")
Root.removeAttribute ("REGUSER")
Root.removeAttribute ("REGPWD")

Response.Write(xmlDoc.xml)

Set oXMLHTTP = Nothing

Sub DeleteParameters()
    for i = 0 to (Cmd.Parameters.Count-1)
        Cmd.Parameters.Delete(i)
    next
end sub


'-------------------------------------------------------------------------------
' Name: LogAction(inputstr)
' Type: Sub
' Purpose:  writes imformation to a output file 
' Inputs:   inputstr  as string - variable to output
' Returns:	none
' Comments: writes informtion to /inetput/cfwlog.txt file
'-------------------------------------------------------------------------------
Sub LogAction(ByVal inputstr)
        on error resume next
        filepath = Application("ServerDrive") & "\" & Application("ServerRoot") & "\cfwlog.txt"
        Set fs = Server.CreateObject("Scripting.FileSystemObject")
        Set a = fs.OpenTextFile(filepath, 8, True)  
        a.WriteLine Now & ": " & inputstr
        a.WriteLine " "
        a.close
End Sub

Function ExecuteOracleFunction(objCommand, strName)
    Dim strReturn
    strReturn = ""
    On Error Resume Next
    objCommand.Execute
    If Err then
        Select Case True
            Case inStr(Err.description,"ORA-20003") > 0
                strReturn = strName & ": Cannot execute invalid Oracle procedure."
            Case inStr(Err.description,"access violation") > 0
                strReturn = strName & ": Current user is not allowed to execute Oracle procedure."
            Case Else
                strReturn = strName & ": " & Err.description
        End Select		
    End if
    on error goto 0
    
    ExecuteOracleFunction = strReturn
End function
    

</SCRIPT>

