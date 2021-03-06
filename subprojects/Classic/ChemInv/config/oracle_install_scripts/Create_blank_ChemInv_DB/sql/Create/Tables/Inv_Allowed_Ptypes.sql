CREATE TABLE "INV_ALLOWED_PTYPES"(
	"PLATE_TYPE_ID_FK" NUMBER(9) NOT NULL,
	"LOCATION_ID_FK" NUMBER(9) NOT NULL,
	CONSTRAINT PTYPES_LOCATIONS_FK
		FOREIGN KEY (LOCATION_ID_FK)
		REFERENCES INV_LOCATIONS (LOCATION_ID)
		ON DELETE CASCADE,
	CONSTRAINT PTYPES_PLATE_TYPE_FK
		FOREIGN KEY (PLATE_TYPE_ID_FK)
		REFERENCES INV_PLATE_TYPES (PLATE_TYPE_ID)
		ON DELETE CASCADE
	)
;
CREATE INDEX INV_ALWD_PTYPES_LOCATIONID_IDX ON INV_ALLOWED_PTYPES(LOCATION_ID_FK) TABLESPACE &&indexTableSpaceName;
CREATE INDEX INV_ALWD_PTYPES_PTYPEID_IDX ON INV_ALLOWED_PTYPES(PLATE_TYPE_ID_FK) TABLESPACE &&indexTableSpaceName;

