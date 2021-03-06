CREATE TABLE INV_ORDER_CONTAINERS(
	ORDER_ID_FK NUMBER(16),
	CONTAINER_ID_FK NUMBER(16),
	"RID" NUMBER(10) NOT NULL, 
	"CREATOR" VARCHAR2(30) DEFAULT RTRIM(user) NOT NULL, 
	"TIMESTAMP" DATE DEFAULT sysdate NOT NULL,   
	PRIMARY KEY(ORDER_ID_FK, CONTAINER_ID_FK),
	CONSTRAINT "INV_ORDERCON_ORDERID_FK"
		FOREIGN KEY("ORDER_ID_FK")
    REFERENCES "INV_ORDERS"("ORDER_ID")	
    ON DELETE CASCADE,
	CONSTRAINT "INV_ORDERCON_CONTAINERID_FK"
		FOREIGN KEY("CONTAINER_ID_FK")
	  REFERENCES "INV_CONTAINERS"("CONTAINER_ID")
  	ON DELETE CASCADE)
  ORGANIZATION INDEX;

CREATE INDEX INV_ORDERCON_CONTAINERID ON INV_ORDER_CONTAINERS(CONTAINER_ID_FK) TABLESPACE &&indexTableSpaceName;
