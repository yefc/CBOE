-- Copyright Cambridgesoft corp 2001-2002 all rights reserved.
-- This script creates roles for ChemACX database login

-- NOTE THIS SCRIPT MUST BE RUN FROM THE COMMAND LINE VERSION OF SQLPLUS
-- This script will not run from SQLPlus Worksheet

DECLARE
	n NUMBER;
BEGIN
	select count(*) into n from user_tables where table_name = Upper('CHEMACX_PRIVILEGES');
	if n = 1 then
		execute immediate '
		DROP TABLE CHEMACX_PRIVILEGES CASCADE CONSTRAINTS';
	end if;
END;
/


CREATE TABLE  CHEMACX_PRIVILEGES (
	ROLE_INTERNAL_ID NUMBER(8,0) not null,
	BROWSE_ACX NUMBER(1,0) null,
	BUY_ACX NUMBER(1,0) null,
	constraint CHEMACX_PRIVILEGES_PK primary key (ROLE_INTERNAL_ID) ) 
;
	
--#########################################################
--CREATE ROLES
--#########################################################

--ROLE creation script for ChemACX/Oracle version Copyright Cambridgesoft corp 1999-2000 all rights reserved

Connect &&InstallUser/&&sysPass@&&serverName

--CREATE_MASTER_ROLES
--ACX_BROWSER
DECLARE
	n NUMBER;
BEGIN
	select count(*) into n from dba_roles where role = Upper('ACX_BROWSER');
	if n = 1 then
		execute immediate '
			DROP ROLE ACX_BROWSER';
	end if;
END;				
/

	CREATE ROLE ACX_BROWSER NOT IDENTIFIED;
	REVOKE "ACX_BROWSER" FROM "SYSTEM";
	GRANT CSS_USER TO "ACX_BROWSER";
--ACX_BUYER
DECLARE
	n NUMBER;
BEGIN
	select count(*) into n from dba_roles where role = Upper('ACX_BUYER');
	if n = 1 then
		execute immediate '
			DROP ROLE ACX_BUYER';
	end if;
END;
/

	CREATE ROLE ACX_BUYER NOT IDENTIFIED;
	REVOKE "ACX_BUYER" FROM "SYSTEM";
	GRANT CSS_USER TO "ACX_BUYER";

	GRANT "CONNECT" TO "ACX_BROWSER";
	GRANT "CONNECT" TO "ACX_BUYER";
	GRANT ACX_BROWSER TO "ACX_BUYER";


Connect &&schemaName/&&schemaPass@&&serverName
	GRANT SELECT ON SUBSTANCE TO ACX_BROWSER;
	GRANT SELECT ON "PRODUCT" TO ACX_BROWSER;
	GRANT SELECT ON PACKAGE TO ACX_BROWSER;
	GRANT SELECT ON ACX_SYNONYM TO ACX_BROWSER;
	GRANT SELECT ON SUPPLIER TO ACX_BROWSER;
	GRANT SELECT ON PROPERTYALPHA TO ACX_BROWSER;
	GRANT SELECT ON PROPERTYCLASSALPHA TO ACX_BROWSER;
	GRANT SELECT ON SUPPLIERADDR TO ACX_BROWSER;
	GRANT SELECT ON SUPPLIERPHONEID TO ACX_BROWSER;
	GRANT SELECT,INSERT,DELETE,UPDATE ON SHOPPINGCART TO ACX_BROWSER;
	GRANT SELECT ON PACKAGESIZECONVERSION TO ACX_BROWSER;
	GRANT SELECT ON MSDX TO ACX_BROWSER;
	--SYAN added 3/29/2004 to support parameterized IN clause
	GRANT EXECUTE ON STR2TBL TO ACX_BROWSER;
	GRANT EXECUTE ON MYTABLETYPE TO ACX_BROWSER;
	
Connect &&securitySchemaName/&&securitySchemaPass@&&serverName

grant execute on GrantOnCoreTableToAllRoles to &&schemaname;
	
delete from security_roles where ROLE_NAME Like 'ACX_BROWSER';
delete from security_roles where ROLE_NAME Like 'ACX_BUYER';
commit;

--PRIVELEGE_TABLES
delete  from privilege_tables where TABLE_SPACE = Upper('&&tablespaceName');
commit;

INSERT INTO PRIVILEGE_TABLES (PRIVILEGE_TABLE_NAME,APP_NAME,TABLE_SPACE) values('CHEMACX_PRIVILEGES','ChemACX',Upper('&&tablespaceName'));

--ACX_Browser
INSERT INTO SECURITY_ROLES (ROLE_ID,PRIVILEGE_TABLE_INT_ID,ROLE_NAME)values(SECURITY_ROLES_SEQ.NEXTVAL,PRIVILEGE_TABLES_seq.CURRVAL,'ACX_BROWSER');
INSERT INTO CHEMACX_PRIVILEGES(ROLE_INTERNAL_ID,BROWSE_ACX,BUY_ACX) VALUES (SECURITY_ROLES_SEQ.CURRVAL, '1','0');

--ACX_BUYER
INSERT INTO SECURITY_ROLES (ROLE_ID,PRIVILEGE_TABLE_INT_ID,ROLE_NAME)values(SECURITY_ROLES_SEQ.NEXTVAL,PRIVILEGE_TABLES_seq.CURRVAL,'ACX_BUYER');
INSERT INTO CHEMACX_PRIVILEGES(ROLE_INTERNAL_ID,BROWSE_ACX,BUY_ACX) VALUES (SECURITY_ROLES_SEQ.CURRVAL, '1','1');
Commit;



DELETE FROM CS_SECURITY.OBJECT_PRIVILEGES WHERE Schema = Upper('&&SchemaName');

-- BROWSE_ACX PRIVS
INSERT INTO CS_SECURITY.OBJECT_PRIVILEGES VALUES ('BROWSE_ACX', 'SELECT', '&&SchemaName', 'SUBSTANCE');
INSERT INTO CS_SECURITY.OBJECT_PRIVILEGES VALUES ('BROWSE_ACX', 'SELECT', '&&SchemaName', 'PRODUCT');
INSERT INTO CS_SECURITY.OBJECT_PRIVILEGES VALUES ('BROWSE_ACX', 'SELECT', '&&SchemaName', 'PACKAGE');
INSERT INTO CS_SECURITY.OBJECT_PRIVILEGES VALUES ('BROWSE_ACX', 'SELECT', '&&SchemaName', 'ACX_SYNONYM');
INSERT INTO CS_SECURITY.OBJECT_PRIVILEGES VALUES ('BROWSE_ACX', 'SELECT', '&&SchemaName', 'SUPPLIER');
INSERT INTO CS_SECURITY.OBJECT_PRIVILEGES VALUES ('BROWSE_ACX', 'SELECT', '&&SchemaName', 'PROPERTYALPHA');
INSERT INTO CS_SECURITY.OBJECT_PRIVILEGES VALUES ('BROWSE_ACX', 'SELECT', '&&SchemaName', 'PROPERTYCLASSALPHA');
INSERT INTO CS_SECURITY.OBJECT_PRIVILEGES VALUES ('BROWSE_ACX', 'SELECT', '&&SchemaName', 'SUPPLIERADDR');
INSERT INTO CS_SECURITY.OBJECT_PRIVILEGES VALUES ('BROWSE_ACX', 'SELECT', '&&SchemaName', 'SUPPLIERPHONEID');
INSERT INTO CS_SECURITY.OBJECT_PRIVILEGES VALUES ('BROWSE_ACX', 'SELECT', '&&SchemaName', 'SHOPPINGCART');
INSERT INTO CS_SECURITY.OBJECT_PRIVILEGES VALUES ('BROWSE_ACX', 'INSERT', '&&SchemaName', 'SHOPPINGCART');
INSERT INTO CS_SECURITY.OBJECT_PRIVILEGES VALUES ('BROWSE_ACX', 'UPDATE', '&&SchemaName', 'SHOPPINGCART');
INSERT INTO CS_SECURITY.OBJECT_PRIVILEGES VALUES ('BROWSE_ACX', 'DELETE', '&&SchemaName', 'SHOPPINGCART');
INSERT INTO CS_SECURITY.OBJECT_PRIVILEGES VALUES ('BROWSE_ACX', 'SELECT', '&&SchemaName', 'PACKAGESIZECONVERSION');
INSERT INTO CS_SECURITY.OBJECT_PRIVILEGES VALUES ('BROWSE_ACX', 'SELECT', '&&SchemaName', 'MSDX');

Connect &&schemaName/&&schemaPass@&&serverName

--- Grant all object permissions to CS_SECURITY
GRANT SELECT ON SUBSTANCE TO CS_SECURITY WITH GRANT OPTION;
GRANT SELECT ON "PRODUCT" TO CS_SECURITY WITH GRANT OPTION;
GRANT SELECT ON PACKAGE TO CS_SECURITY WITH GRANT OPTION;
GRANT SELECT ON ACX_SYNONYM TO CS_SECURITY WITH GRANT OPTION;
GRANT SELECT ON SUPPLIER TO CS_SECURITY WITH GRANT OPTION;
GRANT SELECT ON PROPERTYALPHA TO CS_SECURITY WITH GRANT OPTION;
GRANT SELECT ON PROPERTYCLASSALPHA TO CS_SECURITY WITH GRANT OPTION;
GRANT SELECT ON SUPPLIERADDR TO CS_SECURITY WITH GRANT OPTION;
GRANT SELECT ON SUPPLIERPHONEID TO CS_SECURITY WITH GRANT OPTION;
GRANT SELECT ON SHOPPINGCART TO CS_SECURITY WITH GRANT OPTION;
GRANT INSERT ON SHOPPINGCART TO CS_SECURITY WITH GRANT OPTION;
GRANT UPDATE ON SHOPPINGCART TO CS_SECURITY WITH GRANT OPTION;
GRANT DELETE ON SHOPPINGCART TO CS_SECURITY WITH GRANT OPTION;
GRANT SELECT ON PACKAGESIZECONVERSION TO CS_SECURITY WITH GRANT OPTION;
GRANT SELECT ON MSDX TO CS_SECURITY WITH GRANT OPTION;