prompt 'creating chemical structure indexes...'

Connect &&schemaName/&&schemaPass@&&serverName

DECLARE
	PROCEDURE createCartridgeIndex(iName IN varchar2, tName IN varchar2, fName IN varchar2) IS
			n NUMBER;
		BEGIN
			select count(*) into n from user_indexes where Upper(index_name) = iName AND Upper(table_owner)= '&&schemaName';
			if n = 1 then
				execute immediate 'DROP INDEX '||iName||' force';
			end if;
			execute immediate 'CREATE INDEX '||iName|| ' ON ' || tName || '('||fName||') 
								indexType is cscartridge.moleculeindextype
								PARAMETERS(''TABLESPACE=&&cscartTableSpaceName,FULLEXACT=INDEX'')';
		END createCartridgeIndex;
BEGIN
	createCartridgeIndex('mx', 'structures', 'base64_cdx');
	createCartridgeIndex('mx2', 'temporary_structures', 'base64_cdx');
END;
/



