INSERT INTO INV_REPORTS(ID,REPORTDISPLAYNAME,REPORTNAME,REPORTTYPE_ID, REPORTSQL, QUERYNAME) 
VALUES (15,'Custom Parameter Report', 'rptTestParameterReport', 4, 'select * from cheminvdb2.inv_locations','qryTestParameterReport');
commit;