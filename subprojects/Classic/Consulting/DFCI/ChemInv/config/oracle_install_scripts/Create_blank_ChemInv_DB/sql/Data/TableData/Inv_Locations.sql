--' Add application locations: Root,On Order, Disposed, Trash, Missing
INSERT INTO INV_LOCATIONS (LOCATION_ID, PARENT_ID, DESCRIPTION, LOCATION_TYPE_ID_FK, LOCATION_NAME, LOCATION_DESCRIPTION, LOCATION_BARCODE, OWNER_ID_FK, ALLOWS_CONTAINERS, ADDRESS_ID_FK, RID, CREATOR)
		      	VALUES (0, NULL, NULL, 504, 'Root', 'Root Location', '0', NULL, NULL, NULL, 1001, 'SYSTEM');
INSERT INTO INV_LOCATIONS (LOCATION_ID, PARENT_ID, DESCRIPTION, LOCATION_TYPE_ID_FK, LOCATION_NAME, LOCATION_DESCRIPTION, LOCATION_BARCODE, OWNER_ID_FK, ALLOWS_CONTAINERS, ADDRESS_ID_FK, RID, CREATOR)
			VALUES (1, 0, NULL, 501, 'On Order', 'On Order Location', '1', NULL, NULL, NULL, 1, 'SYSTEM');
INSERT INTO INV_LOCATIONS (LOCATION_ID, PARENT_ID, DESCRIPTION, LOCATION_TYPE_ID_FK, LOCATION_NAME, LOCATION_DESCRIPTION, LOCATION_BARCODE, OWNER_ID_FK, ALLOWS_CONTAINERS, ADDRESS_ID_FK, RID, CREATOR)
			VALUES (2, 0, NULL, 6, 'Disposed', 'Disposed Location', '2', NULL, NULL, NULL, 2, 'SYSTEM');
INSERT INTO INV_LOCATIONS (LOCATION_ID, PARENT_ID, DESCRIPTION, LOCATION_TYPE_ID_FK, LOCATION_NAME, LOCATION_DESCRIPTION, LOCATION_BARCODE, OWNER_ID_FK, ALLOWS_CONTAINERS, ADDRESS_ID_FK, RID, CREATOR)
			VALUES (3, 0, NULL, 502, 'Trash Can', 'Trash Can Location', '3', NULL, NULL, NULL, 3, 'SYSTEM');
INSERT INTO INV_LOCATIONS (LOCATION_ID, PARENT_ID, DESCRIPTION, LOCATION_TYPE_ID_FK, LOCATION_NAME, LOCATION_DESCRIPTION, LOCATION_BARCODE, OWNER_ID_FK, ALLOWS_CONTAINERS, ADDRESS_ID_FK, RID, CREATOR)
			VALUES (4, 0, NULL, 506, 'Missing', 'Missing Location', '4', NULL, NULL, NULL, 4, 'SYSTEM');
commit;