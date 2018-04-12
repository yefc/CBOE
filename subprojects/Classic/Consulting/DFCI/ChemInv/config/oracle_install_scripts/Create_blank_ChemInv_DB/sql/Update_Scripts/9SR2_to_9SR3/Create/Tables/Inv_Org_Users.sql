CREATE TABLE "INV_ORG_USERS"(
	"ORG_USER_ID" NUMBER NOT NULL,
	"USER_ID_FK" VARCHAR2(100) not null,
	"ORG_UNIT_ID_FK" NUMBER(4) not null,
    CONSTRAINT "INV_ORG_USER_ID_PK"
		PRIMARY KEY("ORG_USER_ID") USING INDEX TABLESPACE &&indexTableSpaceName,
	CONSTRAINT "INV_ORG_USERS_UNIT_ID_FK" 
		FOREIGN KEY ("ORG_UNIT_ID_FK")
		REFERENCES "INV_ORG_UNIT" ("ORG_UNIT_ID"),
	CONSTRAINT "INV_ORG_USER_ID_FK" 
		FOREIGN KEY ("USER_ID_FK")
		REFERENCES "PEOPLE" ("USER_ID")
	);

CREATE SEQUENCE SEQ_INV_ORG_USER_ID INCREMENT BY 1 START WITH 1;

CREATE OR REPLACE TRIGGER "TRG_INV_ORG_USER_ID"
    BEFORE INSERT
    ON "INV_ORG_USERS"
    FOR EACH ROW
BEGIN
	if :new.org_user_id is null then
		select SEQ_INV_ORG_USER_ID.nextval into :new.org_user_id from dual;
	end if;
END;
/
	