CREATE TABLE "INV_SYNONYMS"(
	"SYNONYM_ID" NUMBER(9) NOT NULL, 
	"COMPOUND_ID_FK" NUMBER(9) NOT NULL, 
	"SUBSTANCE_NAME" VARCHAR2(255) NOT NULL, 
  "RID" NUMBER(12) NOT NULL,  
	"CREATOR" VARCHAR2(30) DEFAULT RTRIM(user) NOT NULL, 
	"TIMESTAMP" DATE DEFAULT sysdate NOT NULL,   
  CONSTRAINT "INV_SYNONYMS_PK" 
		PRIMARY KEY("SYNONYM_ID") USING INDEX,  
  CONSTRAINT "INV_SYNONYM_NAME_U" 
		UNIQUE("COMPOUND_ID_FK", "SUBSTANCE_NAME") USING INDEX TABLESPACE &&indexTableSpaceName, 
  CONSTRAINT "INV_SYN_COMPOUND_FK" 
		FOREIGN KEY("COMPOUND_ID_FK") 
		REFERENCES "INV_COMPOUNDS"("COMPOUND_ID")
    ON DELETE CASCADE
	)
; 
create sequence SEQ_INV_Synonyms INCREMENT BY 1 START WITH 1;

CREATE OR REPLACE TRIGGER "TRG_INV_SYNONYMS_ID" 
    BEFORE INSERT 
    ON "INV_SYNONYMS" 
    FOR EACH ROW 
    begin
		if :new.Synonym_ID is null then
			select seq_Inv_Synonyms.nextval into :new.Synonym_id from dual;
		end if;
end;
/

