CREATE OR REPLACE TRIGGER TRG_AUDIT_INV_LOCATIONS_AI0
  AFTER INSERT
  ON inv_locations
  FOR EACH ROW
DECLARE
  raid number(10);
BEGIN
 	SELECT seq_audit.NEXTVAL INTO raid FROM dual;
  audit_trail.record_transaction
    (raid, 'INV_LOCATIONS', :NEW.rid, 'I');
END;
/