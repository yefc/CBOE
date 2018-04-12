-- Copyright Cambridgesoft Corp 2001-2007 all rights reserved

--#########################################################
-- Alter cs_security schema for Inventory 10 SR1
-- Creates and grants to default ChemInv Roles and populates CS_SECURITY tables
--######################################################### 

prompt '#########################################################'
prompt 'Altering the cs_security schema...'
prompt '#########################################################'

--' Grant all cheminvdb2 object permissions to CS_SECURITY   
Connect &&schemaName/&&schemaPass@&&serverName



-- new tables
GRANT SELECT,INSERT,UPDATE,DELETE ON "&&SchemaName".INV_LABEL_PRINTERS TO CS_SECURITY WITH GRANT OPTION;
GRANT SELECT,INSERT,UPDATE,DELETE ON "&&SchemaName".INV_FORECAST TO CS_SECURITY WITH GRANT OPTION;
GRANT SELECT,INSERT,UPDATE,DELETE ON "&&SchemaName".TRANSACTION_RECORD TO CS_SECURITY WITH GRANT OPTION;
GRANT SELECT,INSERT,UPDATE,DELETE ON "&&SchemaName".INV_PROTOCOL TO CS_SECURITY WITH GRANT OPTION;
GRANT SELECT,INSERT,UPDATE,DELETE ON "&&SchemaName".INV_PROTOCOL_PI TO CS_SECURITY WITH GRANT OPTION;

-- new sps 
GRANT EXECUTE ON "&&SchemaName".DFCI_INVENTORYUPDATE to CS_SECURITY WITH GRANT OPTION;
GRANT EXECUTE ON "&&SchemaName".DFCI_INVENTORYUPDATE_IDS to CS_SECURITY WITH GRANT OPTION;
GRANT EXECUTE ON "&&SchemaName".CREATEORUPDATEPROTOCOL to CS_SECURITY WITH GRANT OPTION;
GRANT EXECUTE ON "&&SchemaName".CREATEORUPDATEPROTOCOLPI to CS_SECURITY WITH GRANT OPTION;
GRANT EXECUTE ON "&&SchemaName".GENABCFEED to CS_SECURITY WITH GRANT OPTION;

GRANT EXECUTE ON "&&SchemaName".DFCI_CYCLECOUNTUPDATE to CS_SECURITY WITH GRANT OPTION;

-- Chemacx table



--' Create cs_security objects and data for Inventory 
connect &&securitySchemaName/&&securitySchemaPass@&&serverName;

--#########################################################
-- Object_Privileges
--######################################################### 
--' insert inventory entries
--' INV_BROWSE_ALL PRIVS
INSERT INTO CS_SECURITY.OBJECT_PRIVILEGES VALUES ('INV_BROWSE_ALL', 'SELECT', '&&SchemaName', 'INV_LABEL_PRINTERS');
INSERT INTO CS_SECURITY.OBJECT_PRIVILEGES VALUES ('INV_BROWSE_ALL', 'SELECT', '&&SchemaName', 'INV_FORECAST');
INSERT INTO CS_SECURITY.OBJECT_PRIVILEGES VALUES ('INV_BROWSE_ALL', 'SELECT', '&&SchemaName', 'TRANSACTION_RECORD');

INSERT INTO CS_SECURITY.OBJECT_PRIVILEGES VALUES ('INV_REORDER_CONTAINER', 'SELECT', '&&SchemaName', 'INV_PROTOCOL');
INSERT INTO CS_SECURITY.OBJECT_PRIVILEGES VALUES ('INV_REORDER_CONTAINER', 'INSERT', '&&SchemaName', 'INV_PROTOCOL');
INSERT INTO CS_SECURITY.OBJECT_PRIVILEGES VALUES ('INV_REORDER_CONTAINER', 'UPDATE', '&&SchemaName', 'INV_PROTOCOL');
INSERT INTO CS_SECURITY.OBJECT_PRIVILEGES VALUES ('INV_REORDER_CONTAINER', 'SELECT', '&&SchemaName', 'INV_PROTOCOL_PI');
INSERT INTO CS_SECURITY.OBJECT_PRIVILEGES VALUES ('INV_REORDER_CONTAINER', 'INSERT', '&&SchemaName', 'INV_PROTOCOL_PI');
INSERT INTO CS_SECURITY.OBJECT_PRIVILEGES VALUES ('INV_REORDER_CONTAINER', 'UPDATE', '&&SchemaName', 'INV_PROTOCOL_PI');
INSERT INTO CS_SECURITY.OBJECT_PRIVILEGES VALUES ('INV_REORDER_CONTAINER', 'EXECUTE', '&&SchemaName', 'GENABCFEED');
INSERT INTO CS_SECURITY.OBJECT_PRIVILEGES VALUES ('INV_REORDER_CONTAINER', 'EXECUTE', '&&SchemaName', 'DFCI_INVENTORYUPDATE');
INSERT INTO CS_SECURITY.OBJECT_PRIVILEGES VALUES ('INV_REORDER_CONTAINER', 'EXECUTE', '&&SchemaName', 'DFCI_INVENTORYUPDATE_IDS');
INSERT INTO CS_SECURITY.OBJECT_PRIVILEGES VALUES ('INV_REORDER_CONTAINER', 'EXECUTE', '&&SchemaName', 'CREATEORUPDATEPROTOCOL');
INSERT INTO CS_SECURITY.OBJECT_PRIVILEGES VALUES ('INV_REORDER_CONTAINER', 'EXECUTE', '&&SchemaName', 'CREATEORUPDATEPROTOCOLPI');

INSERT INTO CS_SECURITY.OBJECT_PRIVILEGES VALUES ('INV_BROWSE_ALL', 'SELECT', '&&ACXSchemaName', 'PACKAGE');
INSERT INTO CS_SECURITY.OBJECT_PRIVILEGES VALUES ('INV_BROWSE_ALL', 'SELECT', '&&ACXSchemaName', 'PACKAGESIZECONVERSION');
INSERT INTO CS_SECURITY.OBJECT_PRIVILEGES VALUES ('INV_REORDER_CONTAINER', 'EXECUTE', '&&SchemaName', 'DFCI_CYCLECOUNTUPDATE');


commit;


@@..\..\Alter\Cs_Security\GrantPrivsToRole.sql
commit;

--' grant roles based on privs
begin
	FOR role_rec IN (SELECT role_name FROM security_roles WHERE privilege_table_int_id = (SELECT privilege_table_id FROM privilege_tables WHERE privilege_table_name = '&&privTableName'))
	LOOP		
		GrantPrivsToRole(role_rec.role_name);
	END LOOP;
end;
/
