CREATE TABLE "INV_UNIT_CONVERSION_FORMULA"(
	"FROM_UNIT_ID_FK" NUMBER(4) not null,
	"TO_UNIT_ID_FK" NUMBER(4) not null,
	"OPERATION" VARCHAR2(50),
	"INTERMED_UNIT_ID_FK" NUMBER(4),
	CONSTRAINT "FROM_UNIT_ID_FK" 
		FOREIGN KEY ("FROM_UNIT_ID_FK")
		REFERENCES "INV_UNITS" ("UNIT_ID") ON DELETE CASCADE,
	CONSTRAINT "TO_UNIT_ID_FK" 
		FOREIGN KEY ("TO_UNIT_ID_FK")
		REFERENCES "INV_UNITS" ("UNIT_ID") ON DELETE CASCADE,
	CONSTRAINT "INTERMED_UNIT_ID_FK"
		FOREIGN KEY ("INTERMED_UNIT_ID_FK")
		REFERENCES "INV_UNITS" ("UNIT_ID") ON DELETE CASCADE
	);

