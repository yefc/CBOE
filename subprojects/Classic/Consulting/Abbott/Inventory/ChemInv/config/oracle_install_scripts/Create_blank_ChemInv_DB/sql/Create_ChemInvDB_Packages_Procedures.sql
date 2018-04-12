-- Copyright Cambridgesoft Corp 2001-2005 all rights reserved
-- This script creates the packages, stored procedures, and functions needed for the ChemInv application and API.
-- They must be run on an existing ChemInvDB schema. 

@@packages\pkg_StringUtils_def.sql;
@@packages\pkg_StringUtils_Body.sql;
@@packages\pkg_Reservations_def.sql;
@@packages\pkg_Reservations_Body.sql;
@@packages\pkg_XMLUtils_def.sql;
@@packages\pkg_XMLUtils_Body.sql;
@@packages\pkg_ChemCalcs_def.sql;
@@packages\pkg_ChemCalcs_body.sql;
@@functions\f_SolvatePlates.sql
@@packages\pkg_PlateChem_def.sql;
@@packages\pkg_PlateChem_body.sql;

@@functions\f_IsContainerTypeAllowed.sql
@@functions\f_ExcludeContainerTypes.sql
@@functions\f_GetCompoundID.sql
@@functions\f_IsDuplicateCompound.sql
@@functions\f_UpdateContainerStatus.sql
@@functions\f_EnableGridForLocation.sql
@@functions\f_CheckoutContainer.sql
@@functions\f_AssignPlateTypesToLocation.sql
@@functions\f_RetireContainer.sql
@@functions\f_GetLocationPath.sql
@@functions\f_CreateContainer.sql
@@functions\f_CopyContainer.sql
@@functions\f_CopyPlate.sql
@@functions\f_UpdateContainer.sql
@@functions\f_CreateLocation.sql
@@functions\f_DeleteContainer.sql
@@functions\f_GetGridID.sql
@@functions\f_GetGridFormatID.sql
@@functions\f_DeleteLocationGrid.sql
@@functions\f_DeleteLocation.sql
@@functions\f_GetCompoundIDFromName.sql
@@functions\f_MoveContainer.sql
@@functions\f_MoveLocation.sql
@@functions\f_SubstanceNameExists.sql
@@functions\f_UpdateAllContainerFields.sql
@@functions\f_UpdateContainerQtyRemaining.sql
@@functions\f_GetGridStorageID.sql
@@functions\f_UpdateLocation.sql
@@procedures\proc_InsertIntoCustomChemOrder.sql
@@functions\f_OrderContainer.sql
@@functions\f_ReorderContainer.sql
@@functions\f_SelectHazmatData.sql
@@functions\f_SelectSubstanceHazmatData.sql
@@procedures\proc_InsertHazmatData.sql
@@procedures\proc_UpdateHazmatData.sql
@@procedures\proc_InsertSubstanceHazmatData.sql
@@procedures\proc_UpdateSubstanceHazmatData.sql
@@functions\f_CreateTableRow.SQL
@@functions\f_DeleteTableRow.sql
@@functions\f_DeletePlates.sql
@@functions\f_GetPKColumn.sql
@@functions\f_MovePlates.sql
@@functions\f_RetirePlate.sql
@@functions\f_UpdatePlateAttributes.sql
@@functions\f_UpdateTable.sql
@@functions\f_UpdateWell.sql
--@@procedures\proc_InsertXMLDoc.sql
--@@procedures\proc_InsertXSTL.sql
@@functions\f_CreatePlateXML.sql
@@functions\f_CreatePlateMap.sql
@@functions\f_IsPlateTypeAllowed.sql   
@@functions\f_IsTrashLocation.sql
@@functions\f_EmptyTrash.sql
@@functions\f_LookUpValue.sql
@@functions\f_UpdateAddress.sql
@@functions\f_CertifyContainer.sql
@@functions\f_InsertCheckInDetails.sql

-- procedures from Alter_Cheminv_Plate_Procs.sql
@@functions\f_CreateGridFormat.sql
@@functions\f_CreatePhysPlateType.sql
@@functions\f_DeletePhysPlateType.sql
@@functions\f_UpdatePhysPlateType.sql
@@functions\f_UpdateWellFormat.sql
@@functions\f_DeletePlateFormat.sql
@@functions\f_UpdatePlateFormat.sql
@@functions\f_CreatePlateFormat.sql
@@functions\f_DeletePlate.sql
@@functions\f_AssignLocationToGrid.sql
@@functions\f_GetNumberOfCompoundWells.sql
@@functions\f_IsGridLocation.sql
@@functions\f_IsFrozenLocation.sql
@@functions\f_MovePlate.sql        

@@packages\pkg_Approvals_def.sql
@@packages\pkg_Approvals_Body.sql
@@packages\pkg_Requests_def.sql;
@@packages\pkg_Requests_Body.sql;
@@packages\pkg_Compounds_def.sql;
@@packages\pkg_Compounds_Body.sql;
@@packages\pkg_GUIUtils_def.sql;
@@packages\pkg_GUIUtils_Body.sql;
@@packages\pkg_Links_def.sql;
@@packages\pkg_Links_Body.sql;
@@packages\pkg_PlateSettings_def.sql;
@@packages\pkg_PlateSettings_Body.sql;
@@packages\pkg_Reformat_def.sql;
@@packages\pkg_Reformat_body.sql;
@@packages\pkg_REPORTS_DEF.sql
@@packages\pkg_REPORTS_Body.sql
@@packages\pkg_REPORTPARAMS_DEF.sql
@@packages\pkg_REPORTPARAMS_Body.sql
/

-- triggers that require packages
@@triggers\trg_molar_calcs.sql
@@triggers\trg_inv_well_cmpds_molar_calcs.sql
@@triggers\trg_molar_conc.sql
