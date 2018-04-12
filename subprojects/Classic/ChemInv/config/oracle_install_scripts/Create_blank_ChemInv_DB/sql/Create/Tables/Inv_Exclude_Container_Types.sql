CREATE TABLE "INV_EXCLUDE_CONTAINER_TYPES"(
    "CONTAINER_TYPE_ID_FK" NUMBER(9), 
    "LOCATION_ID_FK" NUMBER(9) NOT NULL, 
    CONSTRAINT "EX_CON_TYPE_FK" 
		FOREIGN KEY("CONTAINER_TYPE_ID_FK") 
		REFERENCES "INV_CONTAINER_TYPES"("CONTAINER_TYPE_ID")
		ON DELETE CASCADE, 
    CONSTRAINT "EX_CON_TYPE_FK2" 
		FOREIGN KEY("LOCATION_ID_FK") 
		REFERENCES "INV_LOCATIONS"("LOCATION_ID")
		ON DELETE CASCADE
	)
; 

CREATE INDEX XCL_CONTAINER_TYPE_ID_FK_IDX ON INV_EXCLUDE_CONTAINER_TYPES(CONTAINER_TYPE_ID_FK) TABLESPACE &&indexTableSpaceName;
CREATE INDEX XCL_LOCATION_ID_FK_IDX ON INV_EXCLUDE_CONTAINER_TYPES(LOCATION_ID_FK) TABLESPACE &&indexTableSpaceName;

