-- Copyright Cambridgesoft corp 2001 all rights reserved.

-- Drop cs_security database.
-- This script drops the table spaces and database owner for the cs_security database.

-- NOTE THIS SCRIPT MUST BE RUN FROM THE COMMAND LINE VERSION OF SQLPLUS
-- This script will not run from SQLPlus Worksheet!

SPOOL ON
spool sql\log_drop_cs_security.txt

@@parameters.sql
@@prompts.sql
CONNECT &&InstallUser/&&sysPass@&&serverName;
@@drops.sql

spool off;
exit


