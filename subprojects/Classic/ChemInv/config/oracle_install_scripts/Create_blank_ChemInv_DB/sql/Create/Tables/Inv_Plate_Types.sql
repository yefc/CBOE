CREATE TABLE "INV_PLATE_TYPES"(
	"PLATE_TYPE_ID" NUMBER(9) NOT NULL, 
	"PLATE_TYPE_NAME" VARCHAR2(50), 
    "MAX_FREEZE_THAW" NUMBER(4), 
    CONSTRAINT "INV_PLATE_TYPES_PK" 
		PRIMARY KEY("PLATE_TYPE_ID") USING INDEX TABLESPACE &&indexTableSpaceName
	)
;

create sequence SEQ_INV_PLATE_TYPES INCREMENT BY 1 START WITH 1000;

create or replace trigger TRG_PLATE_TYPE_ID BEFORE INSERT ON INV_PLATE_TYPES FOR EACH ROW 
begin
if :new.PLATE_TYPE_ID is null then
  select SEQ_INV_PLATE_TYPES.nextval into :new.PLATE_TYPE_ID from dual;
end if;
end;
/
