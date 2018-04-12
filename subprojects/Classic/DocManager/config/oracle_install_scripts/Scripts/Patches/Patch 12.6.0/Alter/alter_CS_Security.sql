INSERT INTO "COEDB"."OBJECT_PRIVILEGES" (PRIVILEGE_NAME, PRIVILEGE, SCHEMA, OBJECT_NAME) VALUES ('SEARCH_DOCS', 'SELECT', 'DOCMGR', 'DOCMGR_EXTERNAL_LINKS');

INSERT INTO "COEDB"."OBJECT_PRIVILEGES" (PRIVILEGE_NAME, PRIVILEGE, SCHEMA, OBJECT_NAME) VALUES ('SEARCH_DOCS', 'UPDATE', 'DOCMGR', 'DOCMGR_EXTERNAL_LINKS');


INSERT INTO "COEDB"."OBJECT_PRIVILEGES" (PRIVILEGE_NAME, PRIVILEGE, SCHEMA, OBJECT_NAME) VALUES ('SEARCH_DOCS', 'INSERT', 'DOCMGR', 'DOCMGR_EXTERNAL_LINKS');

INSERT INTO "COEDB"."OBJECT_PRIVILEGES" (PRIVILEGE_NAME, PRIVILEGE, SCHEMA, OBJECT_NAME) VALUES ('SEARCH_DOCS', 'DELETE', 'DOCMGR', 'DOCMGR_EXTERNAL_LINKS');

commit;

--' grant roles based on privs
begin
	FOR role_rec IN (SELECT role_name FROM security_roles WHERE privilege_table_int_id = (SELECT privilege_table_id FROM privilege_tables WHERE privilege_table_name = '&&privTableName'))
	LOOP
		GrantPrivsToRole(role_rec.role_name);
	END LOOP;
end;
/