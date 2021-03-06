--Copyright 1999-2010 CambridgeSoft Corporation. All rights reserved

CREATE OR REPLACE PACKAGE COEDB.ConfigurationManager
AS
    PROCEDURE RetrieveConfiguration(ADescription IN VARCHAR2, AClassName OUT VARCHAR2, AConfiguration OUT CLOB);
    FUNCTION RetrieveParameter(ADescription IN VARCHAR2, AParameter IN VARCHAR2) RETURN CLOB;
    PROCEDURE UpdateParameter(ADescription IN VARCHAR2, AParameter IN VARCHAR2, AValue VARCHAR2);
    PROCEDURE InsertConfiguration(ADescription IN VARCHAR2, AClassName IN VARCHAR2, AConfiguration IN CLOB);
    PROCEDURE UpdateConfiguration(ADescription IN VARCHAR2, AClassName IN VARCHAR2, AConfiguration IN CLOB);
    PROCEDURE DeleteConfiguration(ADescription IN VARCHAR2);
    PROCEDURE CreateOrUpdateParameter(ADescription IN VARCHAR2, AParameterGroup IN VARCHAR2, AParamName IN VARCHAR2, AParamValue IN VARCHAR2, AParamDescription IN VARCHAR2, AControlType IN VARCHAR2, AAllowedValues IN VARCHAR2, AIsAdmin IN VARCHAR2);
    
    Debuging Constant boolean:=False;

    eGenericException Constant Number:=-20000;
    eNoRowsReturned Constant Number:=-20020;
    eParameterNonexistent Constant Number:=-20021;

    eRetrieveConfiguration Constant Number:=-20001;
    eInsertConfiguration Constant Number:=-20002;
    eUpdateConfiguration Constant Number:=-20003;
    eDeleteConfiguration Constant Number:=-20004;

    eRetrieveParameter Constant Number:=-20005;
    eUpdateParameter Constant Number:=-20006;
    eCreateParameter Constant Number:=-20007;
    eGroupNoneexistent Constant Number:=-20008;
    
END ConfigurationManager;
/

CREATE OR REPLACE PACKAGE BODY COEDB.ConfigurationManager
IS
    PROCEDURE InsertLog(ALogProcedure CLOB,ALogComment CLOB) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        INSERT INTO LOG(LogProcedure,LogComment) VALUES($$plsql_unit||'.'||ALogProcedure,ALogComment);
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN NULL; --If logs don't work then don't stop
    END;

    PROCEDURE RetrieveConfiguration(ADescription IN VARCHAR2, AClassName OUT VARCHAR2, AConfiguration OUT CLOB) IS
    BEGIN
        SELECT CC.ClassName, CC.ConfigurationXML.getClobVal()
            INTO AClassName,AConfiguration
            FROM CoeConfiguration  CC
            WHERE UPPER(CC.Description)=UPPER(ADescription);

    EXCEPTION
        WHEN OTHERS THEN
        BEGIN
            $if ConfigurationManager.Debuging $then InsertLog('RetrieveConfiguration','Error eetrieving a configuration. '||chr(10)||DBMS_UTILITY.FORMAT_ERROR_STACK); $end null;
            RAISE_APPLICATION_ERROR(eRetrieveConfiguration, 'Error retrieving a configuration.'||chr(10)||DBMS_UTILITY.FORMAT_ERROR_STACK);
        END;
    END;

    --Example: RetrieveParameter('Registration','Registration/applicationSettings/groups/add[@name="MISC"]/settings/add[@name="SameBatchesIdentity"]/@value');
    FUNCTION RetrieveParameter(ADescription IN VARCHAR2, AParameter IN VARCHAR2) RETURN CLOB IS
        LValue CLOB;
    BEGIN
        SELECT Extract(CC.ConfigurationXML,AParameter).GetClobVal()
            INTO LValue
            FROM CoeConfiguration CC
            WHERE UPPER(CC.Description)=UPPER(ADescription);

        IF LValue IS NULL THEN
            RAISE_APPLICATION_ERROR(eParameterNonexistent, 'Parameter non-existent.');
        END IF;

        RETURN LValue;

    EXCEPTION
        WHEN OTHERS THEN
        BEGIN
            $if ConfigurationManager.Debuging $then InsertLog('RetrieveParameter','Error retrieving a configuration parameter.'||chr(10)||DBMS_UTILITY.FORMAT_ERROR_STACK); $end null;
            RAISE_APPLICATION_ERROR(eRetrieveParameter, 'Error retrieving a configuration parameter.'||chr(10)||DBMS_UTILITY.FORMAT_ERROR_STACK);
        END;
    END;

    --Example: COEDB.ConfigurationManager.UpdateParameter('Registration','Registration/applicationSettings/groups/add[@name="MISC"]/settings/add[@name="SameBatchesIdentity"]','<add name="SameBatchesIdentity" value="False"></add>');
    PROCEDURE UpdateParameter(ADescription IN VARCHAR2, AParameter IN VARCHAR2, AValue VARCHAR2) IS
    BEGIN
        UPDATE COECONFIGURATION
            SET CONFIGURATIONXML=UpdateXML(CONFIGURATIONXML,AParameter,XmlType(AValue))
            WHERE DESCRIPTION='Registration';
    EXCEPTION
        WHEN OTHERS THEN
        BEGIN
            $if ConfigurationManager.Debuging $then InsertLog('UpdateParameter','Error updating a configuration parameter.'||chr(10)||DBMS_UTILITY.FORMAT_ERROR_STACK); $end null;
            RAISE_APPLICATION_ERROR(eUpdateParameter, 'Error updating a configuration parameter.'||chr(10)||DBMS_UTILITY.FORMAT_ERROR_STACK);
        END;
    END;

    PROCEDURE InsertConfiguration(ADescription IN VARCHAR2, AClassName IN VARCHAR2, AConfiguration IN CLOB) IS
    BEGIN
        INSERT INTO CoeConfiguration(Description,ClassName,ConfigurationXML) VALUES(ADescription,AClassName,XmlType(AConfiguration));
    EXCEPTION
        WHEN OTHERS THEN
        BEGIN
            $if ConfigurationManager.Debuging $then InsertLog('InsertConfiguration','Error inserting a configuration.'||chr(10)||DBMS_UTILITY.FORMAT_ERROR_STACK); $end null;
            RAISE_APPLICATION_ERROR(eRetrieveParameter, 'Error inserting a configuration.'||chr(10)||DBMS_UTILITY.FORMAT_ERROR_STACK);
        END;
    END;

    PROCEDURE UpdateConfiguration(ADescription IN VARCHAR2, AClassName IN VARCHAR2, AConfiguration IN CLOB) IS
    BEGIN
        IF AClassName IS NOT NULL THEN
            UPDATE CoeConfiguration SET ClassName=AClassName WHERE UPPER(Description)=UPPER(ADescription);
        END IF;
        IF AConfiguration IS NOT NULL THEN
            UPDATE CoeConfiguration SET ConfigurationXML=XmlType(AConfiguration) WHERE UPPER(Description)=UPPER(ADescription);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
        BEGIN
            $if ConfigurationManager.Debuging $then InsertLog('UpdateConfiguration','Error updating a configuration.'||chr(10)||DBMS_UTILITY.FORMAT_ERROR_STACK); $end null;
            RAISE_APPLICATION_ERROR(eUpdateConfiguration, 'Error updating a configuration.'||chr(10)||DBMS_UTILITY.FORMAT_ERROR_STACK);
        END;
    END;

    PROCEDURE DeleteConfiguration(ADescription IN VARCHAR2) IS
    BEGIN
        DELETE CoeConfiguration WHERE UPPER(Description)=UPPER(ADescription);
    EXCEPTION
        WHEN OTHERS THEN
        BEGIN
            $if ConfigurationManager.Debuging $then InsertLog('DeleteConfiguration','Error brief description.'||chr(10)||DBMS_UTILITY.FORMAT_ERROR_STACK); $end null;
            RAISE_APPLICATION_ERROR(eDeleteConfiguration, 'Error deleting a configuration.'||chr(10)||DBMS_UTILITY.FORMAT_ERROR_STACK);
        END;
    END;
	
	-- Generates the xmlType snipet for a new configuration setting
    FUNCTION NewParameterNode(AParamName IN VARCHAR2, AParamValue IN VARCHAR2, AParamDescription IN VARCHAR2, AControlType IN VARCHAR2, AAllowedValues IN VARCHAR2, AIsAdmin IN VARCHAR2) RETURN xmlType IS
      LNewParam XMLTYPE;
      msg VARCHAR(32000);
         
    BEGIN
        -- Create the xml node for new parameter 
        SELECT XMLELEMENT("add",
               XMLATTRIBUTES(  AParamName as "name",
                              AParamValue as "value",
                              AControlType as "controlType",
                              AAllowedValues as "allowedValues",
                              AParamDescription as "description",
                              AIsAdmin as "isAdmin")) INTO LNewParam
        FROM dual;
    RETURN  LNewParam;     
        
    EXCEPTION
        WHEN OTHERS THEN
        BEGIN
            msg:= 'Unknown error in NewParameterNode';
            $if ConfigurationManager.Debuging $then InsertLog('NewParameterNode', msg ||chr(10)||DBMS_UTILITY.FORMAT_ERROR_STACK); $end null;
            RAISE_APPLICATION_ERROR(-20000, msg ||chr(10)||DBMS_UTILITY.FORMAT_ERROR_STACK);
        END;
    END;
    
    -- updates an existing system configuration setting (parameter) on the system configuration xml stored in COEConfiguration table
    -- ADescription is the description column from the COEConfiguration table (ie. Registration)
    -- AParameterGroup is the group where the parameter should be added
    -- The rest of the parameters correspond to the attributes of the entry in the configuration xml
    PROCEDURE UpdateParameterNode(ADescription IN VARCHAR2, AParameterGroup IN VARCHAR2, AParamName IN VARCHAR2, AParamValue IN VARCHAR2, AParamDescription IN VARCHAR2, AControlType IN VARCHAR2, AAllowedValues IN VARCHAR2, AIsAdmin IN VARCHAR2) IS
      LNewParam XMLTYPE;
      LParameterPath VARCHAR2(2000);
      msg VARCHAR(32000);
         
    BEGIN
        -- Create the xml node for new parameter
        LNewParam := NewParameterNode(AParamName, AParamValue, AParamDescription, AControlType, AAllowedValues, AIsAdmin); 
        
        -- Update the configuration with the updated parameter
        LParameterPath:= ADescription ||'/applicationSettings/groups/add[@name="'|| AParameterGroup || '"]/settings/add[@name="'|| AParamName ||'"]';        
        UPDATE CoeConfiguration CC
            SET CC.ConfigurationXML = updateXML(CC.ConfigurationXML,
                                      LParameterPath,
                                      LNewParam)
            WHERE UPPER(CC.Description)=UPPER(ADescription);   
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            msg:= ADescription || ' configuration entry not found in COEConfiguration table.';
            $if ConfigurationManager.Debuging $then InsertLog('UpdateParameterNode', msg ||chr(10)||DBMS_UTILITY.FORMAT_ERROR_STACK); $end null;
            RAISE_APPLICATION_ERROR(-20000, msg ||chr(10)||DBMS_UTILITY.FORMAT_ERROR_STACK);
        WHEN OTHERS THEN
        BEGIN
            msg:= 'Unkown error updating configuration parameter '|| AParamName;
            $if ConfigurationManager.Debuging $then InsertLog('UpdateParameterNode', msg ||chr(10)||DBMS_UTILITY.FORMAT_ERROR_STACK); $end null;
            RAISE_APPLICATION_ERROR(-20000, msg ||chr(10)||DBMS_UTILITY.FORMAT_ERROR_STACK);
        END;
    END;
    
    
    -- Allows adding a system configuration setting (parameter) to the system configuration xml stored in COEConfiguration table
    -- ADescription is the description column from the COEConfiguration table (ie. Registration)
    -- AParameterGroup is the group where the parameter should be added
    -- The rest of the parameters correspond to the attributes of the entry in the configuration xml
    PROCEDURE CreateParameter(ADescription IN VARCHAR2, AParameterGroup IN VARCHAR2, AParamName IN VARCHAR2, AParamValue IN VARCHAR2, AParamDescription IN VARCHAR2, AControlType IN VARCHAR2, AAllowedValues IN VARCHAR2, AIsAdmin IN VARCHAR2) IS
      LNewParam XMLTYPE;
      LPathToGroup VARCHAR2(2000);
      LGroupNode XMLTYPE;
      msg VARCHAR(32000);
         
    BEGIN
        -- Create the xml node for new parameter
        LNewParam := NewParameterNode(AParamName, AParamValue, AParamDescription, AControlType, AAllowedValues, AIsAdmin); 
        
        -- Get the group node to be updated
        LPathToGroup := ADescription ||'/applicationSettings/groups/add[@name="'|| AParameterGroup || '"]/settings';
        SELECT  Extract(CC.ConfigurationXML,LPathToGroup||'/add')
            INTO  LGroupNode
            FROM CoeConfiguration CC
            WHERE UPPER(CC.Description)=UPPER(ADescription);
        if LGroupNode is null then 
           RAISE_APPLICATION_ERROR(eGroupNoneexistent,'Requested configuration group ('|| AParameterGroup ||') not found in '|| ADescription ||' configuration settings.');
        end if;   
        -- Add the new parameter to the group node
        SELECT XMLELEMENT("settings",xmlConcat(LGroupNode, LNewParam)) into LGroupNode from dual;
        
        -- Update the configuration with the updated group node
        UPDATE CoeConfiguration CC
            SET CC.ConfigurationXML = updateXML(CC.ConfigurationXML,
                                      LPathToGroup,
                                      LGroupNode)
            WHERE UPPER(CC.Description)=UPPER(ADescription);   
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            msg:= ADescription || ' configuration entry not found in COEConfiguration table.';
            $if ConfigurationManager.Debuging $then InsertLog('CreateParameter', msg ||chr(10)||DBMS_UTILITY.FORMAT_ERROR_STACK); $end null;
            RAISE_APPLICATION_ERROR(eCreateParameter, msg ||chr(10)||DBMS_UTILITY.FORMAT_ERROR_STACK);
        WHEN OTHERS THEN
        BEGIN
            msg:= 'Unkown Error creating a configuration parameter.';
            $if ConfigurationManager.Debuging $then InsertLog('CreateParameter', msg||chr(10)||DBMS_UTILITY.FORMAT_ERROR_STACK); $end null;
            RAISE_APPLICATION_ERROR(-20000, msg ||chr(10)||DBMS_UTILITY.FORMAT_ERROR_STACK);
        END;
    END;
    
    FUNCTION GetParameter(ADescription IN VARCHAR2, AParameterGroup IN VARCHAR2, AParamName IN VARCHAR2) RETURN XMLType IS
        LParamNode XMLTYPE;
        LParameterPath VARCHAR2(2000);
        msg VARCHAR(32000); 
    BEGIN 
       LParameterPath:= ADescription ||'/applicationSettings/groups/add[@name="'|| AParameterGroup || '"]/settings/add[@name="'|| AParamName ||'"]';
       SELECT Extract(CC.ConfigurationXML, LParameterPath)
            INTO LParamNode 
            FROM CoeConfiguration CC
            WHERE UPPER(CC.Description)=UPPER(ADescription);
            
        RETURN LParamNode;
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
            msg:= ADescription || ' configuration entry not found in COEConfiguration table.';
            $if ConfigurationManager.Debuging $then InsertLog('GetParameter', msg ||chr(10)||DBMS_UTILITY.FORMAT_ERROR_STACK); $end null;
            RAISE_APPLICATION_ERROR(eCreateParameter, msg ||chr(10)||DBMS_UTILITY.FORMAT_ERROR_STACK);
        WHEN OTHERS THEN
        BEGIN
            msg:= 'Unknown error retrieving configuration parameter: '||ADescription||'/'||AParameterGroup||'/'||AParamName; 
            $if ConfigurationManager.Debuging $then InsertLog('GetParameter',msg ||chr(10)||DBMS_UTILITY.FORMAT_ERROR_STACK); $end null;
            RAISE_APPLICATION_ERROR(eCreateParameter, msg||chr(10)||DBMS_UTILITY.FORMAT_ERROR_STACK);
        END;   
    END;
    
    
    -- Upserts a system configuration setting (parameter) to the system configuration xml stored in COEConfiguration table
    -- ADescription is the description column from the COEConfiguration table (ie. Registration)
    -- AParameterGroup is the group where the parameter should be added
    -- The rest of the parameters correspond to the attributes of the entry in the configuration xml
    PROCEDURE CreateOrUpdateParameter(ADescription IN VARCHAR2, AParameterGroup IN VARCHAR2, AParamName IN VARCHAR2, AParamValue IN VARCHAR2, AParamDescription IN VARCHAR2, AControlType IN VARCHAR2, AAllowedValues IN VARCHAR2, AIsAdmin IN VARCHAR2) IS
      LParam XMLTYPE;
      msg VARCHAR(32000);   
    BEGIN
        LParam:= GetParameter(ADescription, AParameterGroup, AParamName);
        if LParam is null then
          CreateParameter(ADescription, AParameterGroup, AParamName, AParamValue, AParamDescription, AControlType, AAllowedValues, AIsAdmin);
        else
          UpdateParameterNode(ADescription, AParameterGroup, AParamName, AParamValue, AParamDescription, AControlType, AAllowedValues, AIsAdmin);
        end if;
    EXCEPTION
        WHEN OTHERS THEN
        BEGIN
            msg:= 'Unkown error in CreatingOrUpdate configuration parameter.';
            $if ConfigurationManager.Debuging $then InsertLog('CreateParameter', msg||chr(10)||DBMS_UTILITY.FORMAT_ERROR_STACK); $end null;
            RAISE_APPLICATION_ERROR(-20000, msg ||chr(10)||DBMS_UTILITY.FORMAT_ERROR_STACK);
        END;
    END;

END;
/