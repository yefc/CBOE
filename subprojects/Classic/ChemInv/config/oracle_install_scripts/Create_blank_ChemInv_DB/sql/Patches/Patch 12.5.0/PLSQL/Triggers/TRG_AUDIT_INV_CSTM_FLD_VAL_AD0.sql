CREATE OR REPLACE TRIGGER TRG_AUDIT_INV_CSTM_FLD_VAL_AD0
  before delete
  on INV_CUSTOM_CPD_FIELD_VALUES
  for each row
declare
  raid number(10);
  compound_rid inv_compounds.rid%TYPE;

begin
  select seq_audit.nextval into raid from dual;
  select rid into compound_rid from inv_compounds where compound_id = :old.COMPOUND_ID_FK;

  audit_trail.record_transaction
    (raid, 'INV_CUSTOM_CPD_FIELD_VALUES', compound_rid, 'D');

  audit_trail.check_val(raid, 'CUSTOM_CPD_FIELD_VALUE_ID', :new.CUSTOM_CPD_FIELD_VALUE_ID, :old.CUSTOM_CPD_FIELD_VALUE_ID);
  audit_trail.check_val(raid, 'PICKLIST_ID_FK', :new.PICKLIST_ID_FK, :old.PICKLIST_ID_FK);
  audit_trail.check_val(raid, 'CUSTOM_FIELD_ID_FK', :new.CUSTOM_FIELD_ID_FK, :old.CUSTOM_FIELD_ID_FK);
  audit_trail.check_val(raid, 'COMPOUND_ID_FK', :new.COMPOUND_ID_FK, :old.COMPOUND_ID_FK);
end;
/
