--------------------------------------------------------
--  DDL for Package Body PO_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_DRT_PKG" AS
 /* $Header: PO_DRT_PKG.plb 120.0.12010000.9 2018/07/17 10:11:50 adevadul noship $ */

  g_debug         CONSTANT VARCHAR2(1)  := NVL(fnd_profile.value('AFLOG_ENABLED'), 'N');
  g_pkg_name      CONSTANT VARCHAR2(30) := 'PO_DRT_PKG';
  g_module_prefix CONSTANT VARCHAR2(50) := 'po.plsql.' || g_pkg_name || '.';


-- DRC procedure for person type : HR
-- Does validation if passed in HR person can be masked by validating all
-- rules and return 'S' for Success, 'W' for Warning and 'E' for Error
PROCEDURE po_hr_drc (
    person_id     IN NUMBER,
    result_tbl   OUT NOCOPY per_drt_pkg.result_tbl_type
) IS
    l_cnt NUMBER := 0;
    l_api_name VARCHAR2(30) := 'po_hr_drc';
    l_process_tbl per_drt_pkg.result_tbl_type;
    p_person_id NUMBER := person_id;
  BEGIN

    IF ( g_debug = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level )
    THEN
        fnd_log.string(fnd_log.level_statement,g_module_prefix || l_api_name,'Start');
    END IF;

    -- Rule#1 : Has Open Purchase Orders for Person type : Employee/Buyer
    BEGIN
      SELECT 1 INTO l_cnt
      FROM po_headers_all ph
      WHERE ph.agent_id = p_person_id
      AND   ph.type_lookup_code in ('STANDARD','BLANKET','PLANNED','CONTRACT')
        AND nvl(ph.closed_code,'OPEN') <> 'FINALLY CLOSED'
		    AND ROWNUM=1;
    EXCEPTION
      WHEN OTHERS THEN
        l_cnt :=0;
    END;

    -- Log Error/Warning to l_process_tbl
    if(l_cnt > 0) THEN
      per_drt_pkg.add_to_results (person_id => p_person_id,
                                  entity_type => 'HR',
                                  status => 'E',
                                  msgcode => 'PO_DRT_OPEN_BUYER_EXISTS',
                                  msgaplid => 201,
                                  result_tbl => l_process_tbl);
    END IF;

    -- Rule#2 : Has Open Purchase Orders for Person type : Employee/Receiver
    BEGIN
      SELECT 1 INTO l_cnt
      FROM po_headers_all ph,
           po_line_locations_all pll, po_distributions_all pd
      WHERE pll.shipment_type in ('STANDARD','BLANKET','SCHEDULED')
          AND   pll.line_location_id = pd.line_location_id
          AND   ph.po_header_id = pll.po_header_id
          AND   pd.deliver_to_person_id = p_person_id
          AND   nvl(pll.cancel_flag, 'N') <> 'Y'
          AND   nvl(pll.closed_code,'OPEN') NOT IN  ('CLOSED','FINALLY CLOSED')
          AND   ROWNUM =1;

    EXCEPTION
      WHEN OTHERS THEN
        l_cnt :=0;
    END;

    -- Log Error/Warning to l_process_tbl
    IF(l_cnt                               > 0) THEN
      per_drt_pkg.add_to_results (person_id => p_person_id,
                                  entity_type => 'HR',
                                  status => 'E',
                                  msgcode => 'PO_DRT_OPEN_RECEIVER_EXISTS',
                                  msgaplid => 201,
                                  result_tbl => l_process_tbl);

    END IF;

    -- Rule#3 : Has PDFs generated for this User
    BEGIN
      SELECT 1 INTO  l_cnt
      FROM po_headers_all ph
      WHERE ph.agent_id = p_person_id
          AND   nvl(ph.closed_code,'OPEN') = 'FINALLY CLOSED'
          AND   ROWNUM=1;
    EXCEPTION
      WHEN OTHERS THEN
        l_cnt :=0;
    END;

    -- Log Error/Warning to l_process_tbl

    IF(l_cnt                               > 0) THEN
      per_drt_pkg.add_to_results (person_id => p_person_id,
                                  entity_type => 'HR',
                                  status => 'W',
                                  msgcode => 'PO_DRT_PDF_EXISTS',
                                  msgaplid => 201,
                                  result_tbl => l_process_tbl);
    END IF;

    -- Rule#5 : Employee Marked as Active Buyer
    BEGIN
      SELECT 1 INTO l_cnt
      FROM po_agents
      where Agent_id = p_person_id
      and nvl(END_DATE_ACTIVE, sysdate+1) > sysdate
	    AND ROWNUM=1;
    EXCEPTION
      WHEN OTHERS THEN
        l_cnt :=0;
    END;

    -- Log Error/Warning to l_process_tbl
    IF(l_cnt                               > 0) THEN
      per_drt_pkg.add_to_results (person_id => p_person_id,
                                  entity_type => 'HR',
                                  status => 'W',
                                  msgcode => 'PO_DRT_IS_ACTIVE_AGENT',
                                  msgaplid => 201,
                                  result_tbl => l_process_tbl);
    END IF;


    -- Rule#6 : Employee exists in PO Employee Hierarchy
    BEGIN
      SELECT 1 INTO  l_cnt
      FROM   po_employee_hierarchies_all  where EMPLOYEE_ID = p_person_id or SUPERIOR_ID = p_person_id
      AND ROWNUM=1;
    EXCEPTION
      WHEN OTHERS THEN
        l_cnt :=0;
    END;

    -- Log Error/Warning to l_process_tbl

    IF(l_cnt                               > 0) THEN
      per_drt_pkg.add_to_results (person_id => p_person_id,
                                  entity_type => 'HR',
                                  status => 'W',
                                  msgcode => 'PO_DRT_IN_EMP_HIERARCHY',
                                  msgaplid => 201,
                                  result_tbl => l_process_tbl);
    END IF;

     -- Rule#7 : Employee as Supplier exists in PO
     BEGIN
    SELECT Count(*) INTO l_cnt
    FROM po_headers_all ph
    WHERE
   ph.type_lookup_code in ('STANDARD','BLANKET','PLANNED','CONTRACT')
          AND   nvl(ph.closed_code,'OPEN') <> 'FINALLY CLOSED'
          and    ph.vendor_Id in (select Vendor_id from po_vendors where employee_id = p_person_id)
          and    ROWNUM = 1;
    EXCEPTION
      WHEN OTHERS THEN
        l_cnt :=0;
    END;

    -- Log Error/Warning to l_process_tbl
    IF(l_cnt                               > 0) THEN
      per_drt_pkg.add_to_results (person_id => p_person_id,
                                  entity_type => 'HR',
                                  status => 'E',
                                  msgcode => 'PO_DRT_OPEN_SUP_EXISTS',
                                  msgaplid => 201,
                                  result_tbl => l_process_tbl);
    END IF;

    -- if no warning/errors so far, record success to process_tbl
    IF  ( l_process_tbl.Count < 1 )
    THEN
      per_drt_pkg.add_to_results (person_id => p_person_id,
                                  entity_type => 'HR',
                                  status => 'S',
                                  msgcode => NULL,
                                  msgaplid => 201,
                                  result_tbl => l_process_tbl);
    END IF;

    result_tbl := l_process_tbl;
    IF  ( g_debug = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level )
    THEN
        fnd_log.string(fnd_log.level_statement,g_module_prefix || l_api_name,'End');
    END IF;

end po_hr_drc;

-- DRC procedure for person type : TCA
-- Does validation if passed in TCA Party ID can be masked by validating all
-- rules and return 'S' for Success, 'W' for Warning and 'E' for Error
   PROCEDURE po_tca_drc(
      person_id IN NUMBER,
      result_tbl OUT nocopy per_drt_pkg.result_tbl_type )
  IS
    l_cnt      NUMBER       := 0;
    l_api_name VARCHAR2(30) := 'po_tca_drc';
    l_process_tbl per_drt_pkg.result_tbl_type;
    p_person_id NUMBER := person_id;
  BEGIN

    IF (g_debug = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix || l_api_name, 'Start');
    END IF;

  -- Rule#1 : Has Open POs for this Vendor Contact Id
  BEGIN
    SELECT 1 INTO l_cnt
    FROM po_headers_all ph
    WHERE ph.type_lookup_code in ('STANDARD','BLANKET','PLANNED','CONTRACT')
           AND  nvl(ph.closed_code,'OPEN') <> 'FINALLY CLOSED'
          AND   ph.vendor_contact_id IN (
            SELECT pvc.vendor_contact_id
            FROM ap_supplier_contacts pvc, hz_parties hp
            WHERE pvc.per_party_id = hp.party_id
                  AND   hp.party_type = 'PERSON'
                  AND   hp.party_id = p_person_id)
		              AND ROWNUM=1;
  EXCEPTION
    WHEN OTHERS THEN
      l_cnt :=0;
  END;

    -- Log Error/Warning to l_process_tbl
    IF(l_cnt > 0) THEN
      per_drt_pkg.add_to_results (person_id => p_person_id,
                                  entity_type => 'TCA',
                                  status => 'E',
                                  msgcode => 'PO_DRT_OPEN_SUPCON_EXISTS',
                                  msgaplid => 201,
                                  result_tbl => l_process_tbl);
    END IF;

    -- Rule#2 : Has active Vednor for Person type : Supplier
    BEGIN
      SELECT 1 INTO  l_cnt
      FROM po_headers_all ph
      WHERE ph.type_lookup_code in ('STANDARD','BLANKET','PLANNED','CONTRACT')
           AND  nvl(ph.closed_code,'OPEN') <> 'FINALLY CLOSED'
            AND   ph.vendor_id IN (
              SELECT pv.vendor_id
              FROM ap_suppliers pv, hz_parties hp
              WHERE pv.party_id = hp.party_id
                    AND   hp.party_type = 'ORGANIZATION'
                    AND   hp.party_id = p_person_id
                                              )
            AND ROWNUM=1;
    EXCEPTION
      WHEN OTHERS THEN
        l_cnt :=0;
    END;
    -- Log Error/Warning to l_process_tbl
    IF(l_cnt                               > 0) THEN
      per_drt_pkg.add_to_results (person_id => p_person_id,
                                  entity_type => 'TCA',
                                  status => 'E',
                                  msgcode => 'PO_DRT_OPEN_SUP_EXISTS',
                                  msgaplid => 201,
                                  result_tbl => l_process_tbl);
    END IF;

    -- Rule#3 : Has PDFs generated for this User
    BEGIN
/* Bug 28182080 - Performacne issue
      SELECT 1 INTO l_cnt
      FROM po_headers_all ph
      WHERE ph.type_lookup_code in ('STANDARD','BLANKET','PLANNED','CONTRACT')
              AND ( ph.vendor_id IN (
                  SELECT pv.vendor_id
                  FROM ap_suppliers pv, hz_parties hp
                  WHERE pv.party_id = hp.party_id
                        AND   hp.party_type = 'ORGANIZATION'
                        AND   hp.party_id = p_person_id )
              OR
                          ph.vendor_contact_id IN (
              SELECT pvc.vendor_contact_id
              FROM ap_supplier_contacts pvc, hz_parties hp
              WHERE pvc.per_party_id = hp.party_id
                    AND   hp.party_type = 'PERSON'
                      AND   hp.party_id = p_person_id )
              AND   nvl(ph.closed_code,'OPEN') = 'FINALLY CLOSED'
                      )
		        AND ROWNUM=1; */

        SELECT count(1) INTO  l_cnt
        FROM dual
        WHERE EXISTS (
                SELECT 1
                FROM po_headers_all ph
                WHERE ph.type_lookup_code IN (
                    'STANDARD','BLANKET','PLANNED','CONTRACT')
                      AND   nvl(ph.closed_code,'OPEN') = 'FINALLY CLOSED'
                      AND   ph.vendor_id IN (
                    SELECT pv.vendor_id
                    FROM ap_suppliers pv, hz_parties hp
                    WHERE pv.party_id = hp.party_id
                          AND   hp.party_type = 'ORGANIZATION'
                          AND   hp.party_id = p_person_id)
                UNION
                SELECT 1
                FROM po_headers_all ph
                WHERE ph.type_lookup_code IN (
                    'STANDARD','BLANKET','PLANNED','CONTRACT')
                      AND   nvl(ph.closed_code,'OPEN') = 'FINALLY CLOSED'
                      AND   ph.vendor_contact_id IN (
                    SELECT pvc.vendor_contact_id
                    FROM ap_supplier_contacts pvc, hz_parties hp
                    WHERE pvc.per_party_id = hp.party_id
                          AND   hp.party_type = 'PERSON'
                          AND   hp.party_id = p_person_id)
            );

    EXCEPTION
      WHEN OTHERS THEN
        l_cnt :=0;
    END;

    -- Log Error/Warning to l_process_tbl
    IF(l_cnt                               > 0) THEN
      per_drt_pkg.add_to_results (person_id => p_person_id,
                                  entity_type => 'TCA',
                                  status => 'W',
                                  msgcode => 'PO_DRT_PDF_EXISTS',
                                  msgaplid => 201,
                                  result_tbl => l_process_tbl);
    END IF;


    -- if no warning/errors so far, record success to process_tbl
    IF(l_process_tbl.Count  < 1) THEN
      per_drt_pkg.add_to_results (person_id => p_person_id,
                                  entity_type => 'TCA',
                                  status => 'S',
                                  msgcode => NULL,
                                  msgaplid => 201,
                                  result_tbl => l_process_tbl);
    END IF;

    result_tbl := l_process_tbl;
    IF (g_debug    = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix || l_api_name, 'End');
    END IF;
  END po_tca_drc;


-- DRC procedure for person type : FND
-- Does validation if passed in FND Userid can be masked by validating all
-- rules and return 'S' for Success, 'W' for Warning and 'E' for Error
  PROCEDURE po_fnd_drc(
      person_id IN NUMBER,
      result_tbl OUT nocopy per_drt_pkg.result_tbl_type )
  IS
    l_cnt      NUMBER       := 0;
    l_api_name VARCHAR2(30) := 'po_fnd_drc';
    p_person_id NUMBER := person_id;

    l_vendor_id  NUMBER     := 0;
    l_vendor_contact_id NUMBER := 0;
    l_employee_id  NUMBER :=0;

    l_process_tbl per_drt_pkg.result_tbl_type;
  BEGIN
    IF (g_debug = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix || l_api_name, 'Start');
    END IF;

    -- Rule#1 : Has Open Purchase Orders for Person type : FND User/Buyer
    BEGIN
      SELECT 1 INTO l_cnt
      FROM po_headers_all ph, fnd_user fu
      WHERE ph.agent_id = fu.employee_id
            AND   fu.user_id = p_person_id
            AND   ph.type_lookup_code in ('STANDARD','BLANKET','PLANNED','CONTRACT')
            AND   nvl(ph.closed_code,'OPEN') <> 'FINALLY CLOSED'
		        AND   ROWNUM=1;
    EXCEPTION
      WHEN OTHERS THEN
        l_cnt :=0;
    END;

    -- Log Error/Warning to l_process_tbl
    if(l_cnt > 0) THEN
      per_drt_pkg.add_to_results (person_id => p_person_id,
                                  entity_type => 'FND',
                                  status => 'E',
                                  msgcode => 'PO_DRT_OPEN_BUYER_EXISTS',
                                  msgaplid => 201,
                                  result_tbl => l_process_tbl);
    END IF;

    -- Rule#2 : Has Open Purchase Orders for Person type : FND User/Vendor Contact
    BEGIN
      SELECT 1 INTO l_cnt
      FROM po_headers_all ph,
            fnd_user fu,
            ap_supplier_contacts pvc
      WHERE ph.type_lookup_code in ('STANDARD','BLANKET','PLANNED','CONTRACT')
             AND  nvl(ph.closed_code,'OPEN') <> 'FINALLY CLOSED'
            AND   ph.vendor_contact_id = pvc.vendor_contact_id
            AND   pvc.per_party_id = fu.person_party_id
            AND   fu.user_id = p_person_id
            AND   ROWNUM=1;
    EXCEPTION
      WHEN OTHERS THEN
        l_cnt :=0;
    END;

    -- Log Error/Warning to l_process_tbl
    if(l_cnt > 0) THEN
      per_drt_pkg.add_to_results (person_id => p_person_id,
                                  entity_type => 'FND',
                                  status => 'E',
                                  msgcode => 'PO_DRT_OPEN_SUPCON_EXISTS',
                                  msgaplid => 201,
                                  result_tbl => l_process_tbl);
    END IF;

    -- Rule#3 : Has Open Purchase Orders for Person type : FND User/Vendor
    BEGIN
      SELECT 1 INTO l_cnt
      FROM po_headers_all ph,
            fnd_user fu, ap_suppliers pv
      WHERE  ph.type_lookup_code in ('STANDARD','BLANKET','PLANNED','CONTRACT')
            AND   nvl(ph.closed_code,'OPEN') <> 'FINALLY CLOSED'
            AND   ph.vendor_id = pv.vendor_id
            AND   pv.party_id = fu.person_party_id
            AND   fu.user_id = p_person_id
            AND   ROWNUM=1;
    EXCEPTION
      WHEN OTHERS THEN
        l_cnt :=0;
    END;
    -- Log Error/Warning to l_process_tbl
    if(l_cnt > 0) THEN
      per_drt_pkg.add_to_results (person_id => p_person_id,
                                  entity_type => 'FND',
                                  status => 'E',
                                  msgcode => 'PO_DRT_OPEN_SUP_EXISTS',
                                  msgaplid => 201,
                                  result_tbl => l_process_tbl);
    END IF;


    -- if no warning/errors so far, record success to process_tbl
    IF(l_process_tbl.Count < 1) THEN
      per_drt_pkg.add_to_results (person_id => p_person_id,
                                  entity_type => 'FND',
                                  status => 'S',
                                  msgcode => NULL,
                                  msgaplid => 201,
                                  result_tbl => l_process_tbl);
    END IF;
    result_tbl := l_process_tbl;
    IF (g_debug    = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix || l_api_name, 'End');
    END IF;
  END po_fnd_drc;

    PROCEDURE PO_HR_POST (
        person_id IN NUMBER) IS
        l_api_name   VARCHAR2(30) := 'po_hr_post';
    BEGIN
        IF ( g_debug = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level )
        THEN
            fnd_log.string(fnd_log.level_statement,g_module_prefix || l_api_name,'Start');
        END IF;
    END PO_HR_POST;

     PROCEDURE PO_FND_POST (
        person_id IN NUMBER) IS
        l_api_name   VARCHAR2(30) := 'po_fnd_post';
    BEGIN
        IF ( g_debug = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level )
        THEN
            fnd_log.string(fnd_log.level_statement,g_module_prefix || l_api_name,'Start');
        END IF;
    END PO_FND_POST;

    PROCEDURE PO_TCA_POST (
        person_id IN NUMBER) IS
        l_api_name   VARCHAR2(30) := 'po_tca_post';
    BEGIN
        IF ( g_debug = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level )
        THEN
            fnd_log.string(fnd_log.level_statement,g_module_prefix || l_api_name,'Start');
        END IF;
    END PO_TCA_POST;

 -- Procedure does validation for passed in HR person can be masked by validating all
  -- rules and passes back the out variable result_tbl which contains a
  -- table of record of errors/warnings/success
  PROCEDURE PPCC_DRC_Person(person_id in number,
                              orig_person_id IN NUMBER,
                              orig_entity_type IN VARCHAR2,
                              process_tbl IN OUT NOCOPY per_drt_pkg.result_tbl_type)
  IS
    l_api_name VARCHAR2(30) := 'PPCC_DRC_Person';
    l_count    NUMBER       := 0;
	l_statement VARCHAR2(2000);
	l_proc_plan_prod_exists NUMBER := 0;
  BEGIN
    IF (g_debug = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix || l_api_name, 'Start');
    END IF;

/* Commented for bug 27873460
    SELECT  Count(*) INTO l_count
	FROM    po_proc_plan_line ppl
		   ,po_proc_plan_header pph
		   ,pa_projects_all ppa
		   ,pa_project_statuses pps
	WHERE   ppl.proc_plan_id = pph.proc_plan_id
	AND     ppl.agent_id = person_id
	AND     pph.project_id = ppa.project_id
	AND     pps.project_status_code = ppa.project_status_code
	AND     pps.project_system_status_code NOT IN ('CLOSED','PENDING_PURGE','PARTIALLY_PURGED'
												  ,'PURGED','PENDING_CLOSE');
*/

    l_statement := '    SELECT  Count(*)
						FROM    po_proc_plan_line ppl
							   ,po_proc_plan_header pph
							   ,pa_projects_all ppa
							   ,pa_project_statuses pps
						WHERE   ppl.proc_plan_id = pph.proc_plan_id
						AND     ppl.agent_id = :person_id
						AND     pph.project_id = ppa.project_id
						AND     pps.project_status_code = ppa.project_status_code
						AND     pps.project_system_status_code NOT IN (''CLOSED'',''PENDING_PURGE'',''PARTIALLY_PURGED''
																	  ,''PURGED'',''PENDING_CLOSE'') ';

   SELECT Count(1)
   INTO l_proc_plan_prod_exists
   FROM    sys.all_objects
   WHERE   object_name = 'PO_PROC_PLAN_LINE';


	IF l_proc_plan_prod_exists > 0 THEN

		EXECUTE IMMEDIATE l_statement INTO l_count USING person_id;

	END IF;

    IF l_count>0 THEN
      per_drt_pkg.add_to_results (person_id => orig_person_id,
                                  entity_type => orig_entity_type,
                                  status => 'W',
                                  msgcode => 'PO_DRT_PROC_PLAN_EXISTS',
                                  msgaplid => 201,
                                  result_tbl => process_tbl);
    END IF;

    IF (g_debug    = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix || l_api_name, 'End');
    END IF;

  EXCEPTION
  WHEN OTHERS THEN
    IF (g_debug = 'Y' AND fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_procedure, g_module_prefix || l_api_name,
        'Exception : sqlcode :'|| SQLCODE || ' Error Message : ' || sqlerrm);
    END IF;
    per_drt_pkg.add_to_results (person_id => orig_person_id,
                                  entity_type => orig_entity_type,
                                  status => 'E',
                                  msgcode => 'PO_DRT_DRC_UNEXPECTED',
                                  msgaplid => 201,
                                  result_tbl => process_tbl);
  END PPCC_DRC_Person;

  -- DRC procedure for the Procurement Plan Lines
  -- This will be called from the PO_HR_DRC procedure
  PROCEDURE PPCC_HR_DRC(person_id in number,
                          result_tbl IN OUT NOCOPY per_drt_pkg.result_tbl_type)
  IS
    l_api_name VARCHAR2(30) := 'PPCC_HR_DRC';
    l_party_id NUMBER;
    orig_person_id NUMBER := person_id;
  BEGIN
    IF (g_debug = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix || l_api_name, 'Start');
    END IF;

    PPCC_DRC_Person(orig_person_id,
                    orig_person_id,
                    'HR',
                    result_tbl);

    IF (g_debug    = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix || l_api_name, 'End');
    END IF;
  END PPCC_HR_DRC;


  -- DRC procedure for the Procurement Plan Lines
  -- This will be called from the PO_TCA_DRC procedure
  PROCEDURE PPCC_TCA_DRC(person_id in number,
                          result_tbl IN OUT NOCOPY per_drt_pkg.result_tbl_type)
  IS
    l_api_name VARCHAR2(30) := 'PPCC_TCA_DRC';
    l_hr_person_id NUMBER;
    orig_person_id NUMBER := person_id;
  BEGIN
    IF (g_debug = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix || l_api_name, 'Start');
    END IF;

    BEGIN
      SELECT person_id INTO l_hr_person_id FROM per_all_people_f WHERE party_id = orig_person_id AND ROWNUM=1;
    EXCEPTION
    WHEN No_Data_Found THEN
      l_hr_person_id := -1;
    END;

    IF l_hr_person_id <> -1 THEN
      PPCC_DRC_Person(l_hr_person_id,
                        orig_person_id,
                        'TCA',
                        result_tbl);
    END IF;

    IF (g_debug    = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix || l_api_name, 'End');
    END IF;
  END PPCC_TCA_DRC;


  -- DRC procedure for the Procurement Plan Lines
  -- This will be called from the PO_FND_DRC procedure
  PROCEDURE PPCC_FND_DRC(person_id in number,
                          result_tbl IN OUT NOCOPY per_drt_pkg.result_tbl_type)
  IS
    l_api_name VARCHAR2(30) := 'PPCC_FND_DRC';
    l_hr_person_id NUMBER;
    orig_person_id NUMBER := person_id;
  BEGIN
    IF (g_debug = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix || l_api_name, 'Start');
    END IF;

    BEGIN
      SELECT
        employee_id INTO l_hr_person_id
      FROM
        fnd_user
      WHERE user_id = orig_person_id AND ROWNUM=1;
    EXCEPTION
    WHEN No_Data_Found THEN
      l_hr_person_id := -1;

    END;

    IF l_hr_person_id <> -1 THEN
      PPCC_DRC_Person(l_hr_person_id,
                        orig_person_id,
                        'FND',
                        result_tbl);
    END IF;


    IF (g_debug    = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix || l_api_name, 'End');
    END IF;
  END PPCC_FND_DRC;

END po_drt_pkg;

/
