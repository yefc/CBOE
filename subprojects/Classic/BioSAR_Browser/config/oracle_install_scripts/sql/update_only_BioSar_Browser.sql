


--#########################################################
--this add biosar_browser_privileges table to the cs_security schemas and creates 
--standard roles used by biosar browser.
--#########################################################


		
Connect &&InstallUser/&&sysPass@&&serverName
--biosardb must be a power user

	GRANT SELECT ANY TABLE TO "BIOSARDB";
--biosar_admin doesn't need all these privileges
	REVOKE SELECT ANY TABLE FROM BIOSAR_BROWSER_ADMIN;
	REVOKE CREATE USER FROM BIOSAR_BROWSER_ADMIN;
	REVOKE DROP USER FROM  BIOSAR_BROWSER_ADMIN;
	REVOKE ALTER USER FROM BIOSAR_BROWSER_ADMIN;
	REVOKE CREATE ROLE FROM BIOSAR_BROWSER_ADMIN;
	REVOKE ALTER ANY ROLE FROM BIOSAR_BROWSER_ADMIN;
	REVOKE DROP ANY ROLE FROM BIOSAR_BROWSER_ADMIN;
	REVOKE GRANT ANY ROLE FROM BIOSAR_BROWSER_ADMIN;
	REVOKE GRANT ANY PRIVILEGE FROM BIOSAR_BROWSER_ADMIN;
			

				
Connect &&InstallUser/&&sysPass@&&serverName
			REVOKE SELECT ANY TABLE FROM BIOSAR_BROWSER_USER_ADMIN;
			REVOKE ALTER USER FROM BIOSAR_BROWSER_USER_ADMIN;
			REVOKE CREATE ROLE FROM BIOSAR_BROWSER_USER_ADMIN;
			REVOKE ALTER ANY ROLE FROM BIOSAR_BROWSER_USER_ADMIN;
			
			REVOKE DROP ANY ROLE FROM BIOSAR_BROWSER_USER_ADMIN;
			REVOKE GRANT ANY ROLE FROM BIOSAR_BROWSER_USER_ADMIN;
				


Grant BROWSER to BIOSAR_ADMIN;
Grant INV_Browser to BIOSAR_ADMIN;



GRANT BROWSER TO BIOSAR_USER_ADMIN;
Grant INV_Browser to BIOSAR_ADMIN;


GRANT BROWSER TO BIOSAR_USER;
Grant INV_Browser to BIOSAR_USER;
 

GRANT BROWSER TO BIOSAR_USER_BROWSER;
Grant INV_Browser to BIOSAR_USER_BROWSER;

Connect &&InstallUser/&&sysPass@&&serverName

-- point users to new centralized temporary tablespace  

alter user BIOSAR_ADMIN default tablespace &&tableSpaceName temporary tablespace &&tempTableSpaceName;
alter user BIOSAR_USER_ADMIN default tablespace &&tableSpaceName temporary tablespace &&tempTableSpaceName;
alter user BIOSAR_USER default tablespace &&tableSpaceName temporary tablespace &&tempTableSpaceName;
alter user BIOSAR_USER_BROWSER default tablespace &&tableSpaceName temporary tablespace &&tempTableSpaceName;

Connect &&securitySchemaName/&&securitySchemaPass@&&serverName

INSERT INTO &&securitySchemaName..OBJECT_PRIVILEGES VALUES ('SEARCH_USING_FORMGROUP', 'SELECT', 'BIOSARDB', 'DB_QUERY');
INSERT INTO &&securitySchemaName..OBJECT_PRIVILEGES VALUES ('SEARCH_USING_FORMGROUP', 'DELETE', 'BIOSARDB', 'DB_QUERY');
INSERT INTO &&securitySchemaName..OBJECT_PRIVILEGES VALUES ('SEARCH_USING_FORMGROUP', 'INSERT', 'BIOSARDB', 'DB_QUERY');
INSERT INTO &&securitySchemaName..OBJECT_PRIVILEGES VALUES ('SEARCH_USING_FORMGROUP', 'UPDATE', 'BIOSARDB', 'DB_QUERY');
INSERT INTO &&securitySchemaName..OBJECT_PRIVILEGES VALUES ('SEARCH_USING_FORMGROUP', 'SELECT', 'BIOSARDB', 'DB_QUERY_ITEM');
INSERT INTO &&securitySchemaName..OBJECT_PRIVILEGES VALUES ('SEARCH_USING_FORMGROUP', 'DELETE', 'BIOSARDB', 'DB_QUERY_ITEM');
INSERT INTO &&securitySchemaName..OBJECT_PRIVILEGES VALUES ('SEARCH_USING_FORMGROUP', 'INSERT', 'BIOSARDB', 'DB_QUERY_ITEM');
INSERT INTO &&securitySchemaName..OBJECT_PRIVILEGES VALUES ('SEARCH_USING_FORMGROUP', 'UPDATE', 'BIOSARDB', 'DB_QUERY_ITEM');
INSERT INTO &&securitySchemaName..OBJECT_PRIVILEGES VALUES ('SEARCH_USING_FORMGROUP', 'SELECT', 'BIOSARDB', 'USER_SETTINGS');
INSERT INTO &&securitySchemaName..OBJECT_PRIVILEGES VALUES ('SEARCH_USING_FORMGROUP', 'DELETE', 'BIOSARDB', 'USER_SETTINGS');
INSERT INTO &&securitySchemaName..OBJECT_PRIVILEGES VALUES ('SEARCH_USING_FORMGROUP', 'INSERT', 'BIOSARDB', 'USER_SETTINGS');
INSERT INTO &&securitySchemaName..OBJECT_PRIVILEGES VALUES ('SEARCH_USING_FORMGROUP', 'UPDATE', 'BIOSARDB', 'USER_SETTINGS');



commit;