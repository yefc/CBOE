CREATE OR REPLACE VIEW INV_VW_WELL_FORMAT ( WELL_ID,
WELL_FORMAT_ID_FK, CONCENTRATION, CONC_UNIT_FK, PLATE_FORMAT_ID_FK,
GRID_POSITION_ID, GRID_FORMAT_ID_FK, ROW_INDEX, COL_INDEX,
ROW_NAME, COL_NAME, NAME, SORT_ORDER
 ) AS SELECT
	INV_WELLS.WELL_ID,
	INV_WELLS.WELL_FORMAT_ID_FK,
	INV_WELLS.CONCENTRATION,
	INV_WELLS.CONC_UNIT_FK,
	INV_WELLS.PLATE_FORMAT_ID_FK,
	INV_GRID_POSITION.GRID_POSITION_ID,
	INV_GRID_POSITION.GRID_FORMAT_ID_FK,
	INV_GRID_POSITION.ROW_INDEX,
	INV_GRID_POSITION.COL_INDEX,
	INV_GRID_POSITION.ROW_NAME,
	INV_GRID_POSITION.COL_NAME,
	INV_GRID_POSITION.NAME,
	INV_GRID_POSITION.SORT_ORDER
     FROM INV_WELLS, INV_GRID_POSITION
    WHERE GRID_POSITION_ID_FK = GRID_POSITION_ID
    AND plate_id_fk is null
    ORDER BY INV_GRID_POSITION.SORT_ORDER;

