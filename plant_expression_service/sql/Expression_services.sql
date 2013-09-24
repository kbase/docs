Given EO ID to list GSM IDs
 
SELECT DISTINCT s.sid_extern AS 'GSM_ID'
FROM sample s, eo e
WHERE s.eoid=e.eoid AND e.eoid_extern in (<list_of_eoid>)

Given PO ID to list GSM IDs
 
SELECT DISTINCT s.sid_extern AS 'GSM_ID'
FROM sample s, Po P
WHERE s.poid=p.eoid AND p.poid_extern in (<list_of_poid>)

Given EO ID to EO description
 
SELECT eoid_extern AS 'EO_ID', eo_desc AS 'EO_Description'
FROM eo
WHERE eoid_extern in (<list_of_eoid>)

Given PO ID to PO description

SELECT poid_extern AS 'PO_ID', po_anatomy AS 'PO_Anatomy'
FROM po
WHERE poid_extern in (<list_of_poid>)
