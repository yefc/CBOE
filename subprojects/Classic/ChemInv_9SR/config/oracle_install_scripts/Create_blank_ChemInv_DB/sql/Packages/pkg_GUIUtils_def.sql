CREATE OR REPLACE PACKAGE "GUIUTILS"      AS
   TYPE  CURSOR_TYPE IS REF CURSOR;

	 PROCEDURE GETKEYCONTAINERATTRIBUTES
	    (pContainerIDList IN  varchar2:=NULL,
	     pContainerBarcodeList IN varchar2:=NULL,
	     O_RS OUT CURSOR_TYPE);

  PROCEDURE GETKEYPLATEATTRIBUTES
	    (pPlateIDList IN  varchar2:=NULL,
	     pPlateBarcodeList IN varchar2:=NULL,
	     O_RS OUT CURSOR_TYPE);

	 FUNCTION GETLOCATIONPATH
	     (pLocationID IN inv_locations.location_id%type) return varchar2;

	 PROCEDURE GETRECENTLOCATIONS(pContainerID IN inv_containers.container_id%type,
  				pNumRows in integer:=5,
				O_RS OUT CURSOR_TYPE);

	FUNCTION GETPARENTPLATEIDS (pPlateID inv_plates.plate_id%TYPE) RETURN varchar2;

	FUNCTION GETPARENTPLATEBARCODES (pPlateID inv_plates.plate_id%TYPE) RETURN varchar2;

	FUNCTION GETPARENTPLATELOCATIONIDS(pPlateID inv_plates.plate_id%TYPE) RETURN varchar2;

	FUNCTION GETPARENTWELLIDS (pWellID inv_wells.well_id%TYPE) RETURN varchar2;

	FUNCTION GETPARENTWELLLABELS (pWellID inv_wells.well_id%TYPE) RETURN varchar2;

	FUNCTION GETPARENTWELLNAMES (pWellID inv_wells.well_id%TYPE) RETURN varchar2;

	FUNCTION GETPARENTPLATEIDS2 (pWellID inv_wells.well_id%TYPE) RETURN varchar2;

	FUNCTION GETPARENTPLATELOCATIONIDS2(pWellID inv_wells.well_id%TYPE) RETURN varchar2;

	FUNCTION GETPARENTPLATEBARCODES2 (pWellID inv_wells.well_id%TYPE) RETURN varchar2;

	/* Returns the sum of qty_available for all child containers of the given container */
	FUNCTION GETBATCHAMOUNTSTRING (pContainerID inv_containers.container_id%TYPE) RETURN varchar2;
  
	FUNCTION IS_NUMBER(p VARCHAR2) RETURN NUMBER;
	
		  PROCEDURE GetRootNodes
	    (p_selectedID IN NUMBER,
	     p_assetType IN VARCHAR2,
	     O_RS OUT CURSOR_TYPE) ;
						
		  PROCEDURE GetLineage
	    (p_rootID IN NUMBER,
	     p_assetType IN VARCHAR2,
	     O_RS OUT CURSOR_TYPE) ;
END GUIUTILS;
/
show errors;


