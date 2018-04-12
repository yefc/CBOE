CREATE TABLE "INV_REQUEST_STATUS"(
	"REQUEST_STATUS_ID" NUMBER(4) NOT NULL,
	"REQUEST_STATUS_NAME" VARCHAR2(50) NOT NULL,
    CONSTRAINT "INV_REQUEST_STATUS_PK"
		PRIMARY KEY("REQUEST_STATUS_ID") USING INDEX TABLESPACE &&indexTableSpaceName);

CREATE SEQUENCE SEQ_INV_REQUEST_STATUS INCREMENT BY 1 START WITH 1000 MAXVALUE 99999 MINVALUE 1 NOCYCLE NOCACHE ORDER;

CREATE OR REPLACE TRIGGER "TRG_INV_REQUEST_STATUS_ID"
    BEFORE INSERT
    ON "INV_REQUEST_STATUS"
    FOR EACH ROW
    begin
		if :new.REQUEST_STATUS_ID is null then
			select seq_INV_REQUEST_STATUS.nextval into :new.REQUEST_STATUS_ID from dual;
		end if;
end;
/