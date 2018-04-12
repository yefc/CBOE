CREATE TABLE "INV_GRID_STORAGE"(
	"GRID_STORAGE_ID" NUMBER(9) NOT NULL,
	"GRID_FORMAT_ID_FK" NUMBER(9) NOT NULL, 
    "LOCATION_ID_FK" NUMBER(16), 
    "CONTAINER_ID_FK" NUMBER(16), 
    "PLATE_ID_FK" NUMBER(16), 
    CONSTRAINT "INV_GRIDSTOR_GRIDFORMAT_FK" 
		FOREIGN KEY("GRID_FORMAT_ID_FK") 
		REFERENCES "INV_GRID_FORMAT"("GRID_FORMAT_ID")
		ON DELETE CASCADE, 
    CONSTRAINT "INV_GRIDSTOR_LOCATIONID_FK" 
		FOREIGN KEY("LOCATION_ID_FK") 
		REFERENCES "INV_LOCATIONS"("LOCATION_ID")
		ON DELETE CASCADE, 
    CONSTRAINT "INV_GRIDSTOR_PLATEID" 
		FOREIGN KEY("PLATE_ID_FK") 
		REFERENCES "INV_PLATES"("PLATE_ID"), 
    CONSTRAINT "INV_GRID_STORAGE_PK" 
    PRIMARY KEY("GRID_STORAGE_ID") USING INDEX TABLESPACE &&indexTableSpaceName
	)
;  

create sequence SEQ_INV_GRID_STORAGE INCREMENT BY 1 START WITH 1000;

create or replace trigger TRG_GRID_STORAGE_ID BEFORE INSERT ON INV_GRID_STORAGE FOR EACH ROW 
begin
if :new.GRID_STORAGE_ID is null then
  select SEQ_INV_GRID_STORAGE.nextval into :new.GRID_STORAGE_ID from dual;
end if;
end;
/

CREATE INDEX STORAGE_GRID_FORMAT_ID_FK_IDX ON INV_GRID_STORAGE(GRID_FORMAT_ID_FK) TABLESPACE &&indexTableSpaceName;
CREATE INDEX STORAGE_LOCATION_ID_FK_IDX ON INV_GRID_STORAGE(LOCATION_ID_FK) TABLESPACE &&indexTableSpaceName;
CREATE INDEX STORAGE_PLATE_ID_FK_IDX ON INV_GRID_STORAGE(PLATE_ID_FK) TABLESPACE &&indexTableSpaceName;
