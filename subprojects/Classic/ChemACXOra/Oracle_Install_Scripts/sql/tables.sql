
-- Create new table version.  
create table Version (
	ACXVersion varchar2(50) NOT NULL,
	MSDXVersion varchar2(50) NOT NULL
	)   PCTFREE 5 PCTUSED 40
; 


-- Create new table SYNONYM.  
create table ACX_SYNONYM (
	SYNONYMID NUMBER(10,0) not null,
	NAME VARCHAR2(250) not null,
	SYNONYMTYPE VARCHAR2(10) not null,
	SUPPLIERID NUMBER(9,0) null,
	CSNUM NUMBER(9,0) null,
	DATECREATED DATE null,
	SUPPLIERNAME VARCHAR2(255) null,
	ACX_ID VARCHAR2(50) null)   PCTFREE 5 PCTUSED 40
; 

-- Create new table SUPPLIERPHONEID.
create table SUPPLIERPHONEID (
	SUPPLIERPHONEID NUMBER(10,0) not null,
	COUNTRYCODE VARCHAR2(6) null,
	AREACODE VARCHAR2(5) null,
	PHONENUM VARCHAR2(50) null,
	TYPE VARCHAR2(50) null,
	LOCATION VARCHAR2(150) null,
	SUPPLIERID NUMBER(9,0) not null)   PCTFREE 5 PCTUSED 40
; 

-- Create new table SUPPLIERADDR.  
create table SUPPLIERADDR (
	SUPPLIERADDRID NUMBER(10,0) not null,
	ADDR1 NVARCHAR2(50) null,
	ADDR2 NVARCHAR2(50) null,
	CITY VARCHAR2(50) null,
	STATE VARCHAR2(15) null,
	CODE VARCHAR2(50) null,
	COUNTRY VARCHAR2(50) null,
	TYPE VARCHAR2(50) null,
	SUPPLIERID NUMBER(9,0) not null) PCTFREE 5 PCTUSED 40	
; 

-- Create new table SUPPLIER. 
create table SUPPLIER (
	SUPPLIERID NUMBER(9,0) not null,
	SUPPLIERTYPE NUMBER(3,0) not null,
	NAME VARCHAR2(255) not null,
	SHORTNAME VARCHAR2(50) not null,
	SUPPLIERCODE VARCHAR2(50) null,
	SORTORDER NUMBER(9,0) not null,
	LOGOPATH VARCHAR2(50) null,
	LOGO BLOB null,
	ORDERFROM NUMBER(9,0) not null) 
	LOB (logo) STORE AS(
		DISABLE STORAGE IN ROW NOCACHE CHUNK 2K PCTVERSION 10 
		TABLESPACE &&msdxLobsTableSpaceName
		STORAGE (INITIAL &&msdxlob NEXT &&msdxlob)
	)
	PCTFREE 5 PCTUSED 40
; 

-- Create new table SUBSTANCE.  
create table SUBSTANCE (
	CSNUM NUMBER(10,0) not null,
	CAS VARCHAR2(50) null,
	FEMA VARCHAR2(5) null,
	MOL_ID NUMBER(9,0) null,
	SYNONYMID NUMBER(9,0) null,
	DATECREATED DATE null,
	SUPPLIERNAME VARCHAR2(255) null,
	ACX_ID VARCHAR2(50) not null,
	SUPPLIERID NUMBER(9,0) null,
	hasproducts VARCHAR2(2) not null, 
	hasmsds VARCHAR2(2) not null, 
	numProducts number(5,0),
	BASE64_CDX clob)
	LOB (BASE64_CDX) STORE AS(
		DISABLE STORAGE IN ROW NOCACHE CHUNK 2K PCTVERSION 10
		TABLESPACE &&lobsTableSpaceName
		STORAGE (INITIAL &&lobB64cdx NEXT &&lobB64cdx)
	)  PCTFREE 5 PCTUSED 40 	
; 

-- Create new table PROPERTYCLASSALPHA.
create table PROPERTYCLASSALPHA (
	PROPERTYCLASSALPHAID NUMBER(10,0) not null,
	CLASSNAME VARCHAR2(50) not null)  PCTFREE 5 PCTUSED 40
; 

-- Create new table PROPERTYALPHA.
create table PROPERTYALPHA (
	PROPERTY VARCHAR2(50) not null,
	"VALUE" NVARCHAR2(250) not null,
	PRODUCTID NUMBER(9,0) not null)  PCTFREE 5 PCTUSED 40
; 

-- Create new table PRODUCT.
create table PRODUCT (
	PRODUCTID NUMBER(10,0) not null,
	SUPPLIERID NUMBER(9,0) not null,
	PRODNAME VARCHAR2(250) not null,
	PRODDESCRIP NVARCHAR2(255) null,
	CATALOGNUM VARCHAR2(50) null,
	CONCENTRATIONPCT NUMBER null,
	CONCENTRATIONTAG VARCHAR2(15) null,
	DATECREATED DATE null,
	MOL_ID NUMBER(9,0) null,
	CSNUM NUMBER(9,0) not null,
	PRODCLAIMEDMW VARCHAR2(10) null,
	PRODCLAIMEDFORMULA VARCHAR2(100) null,
	CHEMCLASSID NUMBER(9,0) not null,
	NUMTOSKIP NUMBER(9,0) not null,
	ISWWW VARCHAR2(2) null,
	PICTURE VARCHAR2(50) null,
	ISPICTURE VARCHAR2(2) not null,
	EXTENDED_DESCRIPTION VarChar2(2000) null,
	ACX_ID VARCHAR2(50) not null,
	hasmsds VARCHAR2(2))  PCTFREE 5 PCTUSED 40
; 

-- Create new table PACKAGE. 
create table PACKAGE (
	PACKAGEID NUMBER(10,0) not null,
	SUPPLIERID NUMBER(9,0) not null,
	SUPPLIERNAME VARCHAR2(255) null,
	PRODUCTID NUMBER(9,0) not null,
	"SIZE" VARCHAR2(20) null,
	CONTAINER VARCHAR2(50) null,
	CATALOG2NUM VARCHAR2(50) null,
	PRICE VARCHAR2(50) null,
	CURRENCY VARCHAR2(50) null,
	CSYMBOL VARCHAR2(50) null,
	PRICE_URL VARCHAR2(255) null,
	DATECREATED DATE null,
	ISPRICECD VARCHAR2(2) null,
	ISPRICEWWW VARCHAR2(2) null,
	ISECOMM VARCHAR2(2) null,
	DISCPRICE VARCHAR2(50) null,
	SAVINGS VARCHAR2(50) null,
	NAME VARCHAR2(255) not null,
	CATALOGNUM VARCHAR2(50) null) PCTFREE 5 PCTUSED 40
; 


CREATE TABLE MSDX(
	IDAutoNumber Number(9,0) not null,
	VendorID NUMBER(5,0),
	CatalogNum varchar2(50),
	ProductID Number(9,0) not null,
	CAS varchar2(15),
	msdxBlob BLOB not null
	)
	LOB (msdxBlob) STORE AS(
		DISABLE STORAGE IN ROW NOCACHE CHUNK 16K PCTVERSION 10 
		TABLESPACE &&msdxLobsTableSpaceName
		STORAGE (INITIAL &&msdxlob NEXT &&msdxlob)
	) PCTFREE 5 PCTUSED 40
;

CREATE TABLE PACKAGESIZECONVERSION(
	ID NUMBER(9,0) not null,
	SIZE_FK VARCHAR2(255) not null,
	CONTAINER_QTY_MAX NUMBER not null,
	UNIT_OF_MEASURE VARCHAR2(255) not null,
	CONTAINER_UOM VARCHAR2(255) not null,
	CONTAINER_COUNT NUMBER not null,
	CONTAINER_UOM_ID_FK NUMBER(9) not null
	)  PCTFREE 5 PCTUSED 40
;

CREATE TABLE SHOPPINGCART(
	CSUserName VARCHAR2(50) not null, 
	WddxPacket CLOB, 
	LastUpdate DATE);
