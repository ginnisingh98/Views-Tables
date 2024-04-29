--------------------------------------------------------
--  DDL for Package Body ICX_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_DRT_PKG" AS
/* $Header: ICX_DRT_PKG.plb 120.0.12010000.8 2018/04/30 04:15:48 krsethur noship $ */
  g_debug         CONSTANT VARCHAR2(1)  := NVL(fnd_profile.value('AFLOG_ENABLED'), 'N');
  g_pkg_name      CONSTANT VARCHAR2(30) := 'ICX_DRT_PKG';
  g_module_prefix CONSTANT VARCHAR2(50) := 'icx.plsql.' || g_pkg_name || '.';
  g_gdpr_ex       EXCEPTION;
  PRAGMA EXCEPTION_INIT( g_gdpr_ex, -20001 );

-- Post Processing function to handle attribute masking for HR Person
-- This is workaround as we can't have multiple where conditions in
-- excel metadata from HR.
  PROCEDURE icx_hr_post(
      person_id IN NUMBER )
  IS
    l_api_name  VARCHAR2(30) := 'icx_hr_post';
    p_person_id NUMBER       := person_id;
  BEGIN
    IF (g_debug = 'Y' AND fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_procedure, g_module_prefix || l_api_name, 'Start');
    END IF;

    UPDATE po_requisition_lines_all
    SET suggested_vendor_phone  = NULL,
      suggested_vendor_location = NULL,
      supplier_duns             = NULL
    WHERE vendor_id            IN
      (SELECT pav.vendor_id
      FROM ap_suppliers pav
      WHERE pav.employee_id = p_person_id
      );

    IF (g_debug = 'Y' AND fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_procedure, g_module_prefix || l_api_name, 'End');
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    IF (g_debug = 'Y' AND fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_procedure, g_module_prefix ||
        l_api_name, 'Exception : sqlcode :'|| SQLCODE || ' Error Message : ' || sqlerrm);
    END IF;
    raise_application_error( -20001, 'Exception at ' || g_module_prefix ||
      l_api_name || ' : sqlcode :'|| SQLCODE || ' Error Message : ' || sqlerrm);
  END icx_hr_post;
-- Post Processing function to handle attribute masking for TCA Person
-- This is workaround as we can't have multiple where conditions in
-- excel metadata from HR.
  PROCEDURE icx_tca_post(
      person_id IN NUMBER )
  IS
    l_api_name  VARCHAR2(30) := 'icx_tca_post';
    p_person_id NUMBER       := person_id;
  BEGIN
    IF (g_debug = 'Y' AND fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_procedure, g_module_prefix || l_api_name, 'Start');
    END IF;
    IF (g_debug = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix ||
        l_api_name, 'updating icx_cat_fav_list_lines_tlp..');
    END IF;
    UPDATE icx_cat_fav_list_lines_tlp
    SET suggested_vendor_contact       = NULL,
      suggested_vendor_contact_phone   = NULL
    WHERE suggested_vendor_contact_id IN
      (SELECT vendor_contact_id
      FROM ap_supplier_contacts pvc,
        hz_parties hp
      WHERE pvc.per_party_id = hp.party_id
      AND hp.party_type      = 'PERSON'
      AND hp.party_id        = p_person_id
      );
    IF (g_debug = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix ||
        l_api_name, 'updating po_requisition_lines_all -1..');
    END IF;
    UPDATE po_requisition_lines_all
    SET suggested_vendor_name=NULL,
        suggested_vendor_contact_email = NULL,
      suggested_vendor_contact         = NULL,
      suggested_vendor_phone  = NULL
    WHERE vendor_contact_id           IN
      (SELECT vendor_contact_id
      FROM ap_supplier_contacts pvc,
        hz_parties hp
      WHERE pvc.per_party_id = hp.party_id
      AND hp.party_type      = 'PERSON'
      AND hp.party_id        = p_person_id
      );
    IF (g_debug = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix ||
        l_api_name, 'updating po_requisition_lines_all -2..');
    END IF;
    UPDATE po_requisition_lines_all
    SET suggested_vendor_phone  = NULL,
      suggested_vendor_location = NULL,
      supplier_duns             = NULL
    WHERE vendor_id            IN
      (SELECT pav.vendor_id
      FROM ap_suppliers pav,
        hz_parties hp
      WHERE pav.party_id = hp.party_id
      AND hp.party_id    = p_person_id
      AND hp.party_type  = 'PERSON'
      );
    IF (g_debug = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix ||
        l_api_name, 'updating PO_REQ_HEADERS_EXT_B..');
    END IF;

  EXCEPTION
  WHEN OTHERS THEN
    IF (g_debug = 'Y' AND fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_procedure, g_module_prefix ||
        l_api_name, 'Exception : sqlcode :'|| SQLCODE || ' Error Message : ' || sqlerrm);
    END IF;
    raise_application_error( -20001, 'Exception at ' || g_module_prefix ||
      l_api_name || ' : sqlcode :'|| SQLCODE || ' Error Message : ' || sqlerrm);
  END icx_tca_post;
-- DRC Procedure for person type : HR
-- Does validation if passed in HR person can be masked by validating all
-- rules and passes back the out variable p_process_tbl which contains a
-- table of record of errors/warnings/successs
  PROCEDURE icx_hr_drc(
      person_id IN NUMBER,
      p_entity_type IN VARCHAR2 DEFAULT 'HR',
      result_tbl OUT nocopy per_drt_pkg.result_tbl_type )
  IS
    l_cnt       NUMBER       := 0;
    l_api_name  VARCHAR2(30) := 'icx_per_drc';
    p_person_id NUMBER       := person_id;
  BEGIN
    IF (g_debug = 'Y' AND fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_procedure, g_module_prefix || l_api_name, 'Start');
    END IF;
    -- Rule#3 PROC-IP-03: Has active shopping carts for Person type : Employee(Requester)
    IF (g_debug = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix ||
        l_api_name, 'Rule#3 PROC-IP-03: Has active shopping carts for Person type : Employee(Requester)');
    END IF;
    SELECT COUNT(*)
    INTO l_cnt
    FROM po_requisition_headers_all prh,
      po_requisition_lines_all prl
    WHERE prh.requisition_header_id                 = prl.requisition_header_id
    AND NVL(prh.authorization_status,'INCOMPLETE') IN ('SYSTEM_SAVED', 'INCOMPLETE')
    AND prl.to_person_id                            = p_person_id;
    IF(l_cnt                                        > 0) THEN
      per_drt_pkg.add_to_results (person_id => p_person_id , entity_type => p_entity_type , status => 'E' ,
        msgcode => 'ICX_DRT_ACTIVE_CART_REQUESTER' , msgaplid => 178 , result_tbl => result_tbl);
    END IF;
    -- Rule#4 : PROC-IP-04 : If Open approved requisition exists that is not in cancel/finally closed but not yet delivered.
    IF (g_debug = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix || l_api_name,
        'Rule#4 : PROC-IP-04 : If Open approved requisition exists that is not in cancel/finally closed but not yet delivered.');
    END IF;
    SELECT COUNT(*)
    INTO l_cnt
    FROM po_requisition_headers_all prh,
      po_requisition_lines_all prl
    WHERE prh.requisition_header_id                = prl.requisition_header_id
    AND prh.conformed_header_id                   IS NULL
    AND NVL(prh.authorization_status,'INCOMPLETE') = 'APPROVED'
    AND source_type_code                           = 'VENDOR'
    AND prl.to_person_id                           = p_person_id
    AND prl.line_location_id                      IS NOT NULL
    AND EXISTS
      (SELECT 'open shipment exists'
      FROM po_line_locations_all poll
      WHERE poll.line_location_id           = prl.line_location_id
      AND NVL(poll.closed_code,'OPEN') NOT IN ('CLOSED', 'FINALLY CLOSED')
      )
    AND NVL(prl.cancel_flag,'N')        <> 'Y'
    AND NVL(prl.closed_code,'OPEN') NOT IN ( 'CLOSED', 'FINALLY CLOSED' );
    IF(l_cnt                             > 0) THEN
      per_drt_pkg.add_to_results (person_id => p_person_id , entity_type => p_entity_type , status => 'E' ,
        msgcode => 'ICX_DRT_REQUESTER_OPEN' , msgaplid => 178 , result_tbl => result_tbl);
    END IF;
    -- Rule#5 : PROC-IP-06 : Requisitions assigned to buyers but PO not yet created.
    IF (g_debug = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix || l_api_name,
        'Rule#5 : PROC-IP-06 : Requisitions assigned to buyers but PO not yet created.');
    END IF;
    SELECT COUNT(*)
    INTO l_cnt
    FROM po_requisition_headers_all prh,
      po_requisition_lines_all prl
    WHERE prh.requisition_header_id                = prl.requisition_header_id
    AND NVL(prh.authorization_status,'INCOMPLETE') = 'APPROVED'
    AND source_type_code                           = 'VENDOR'
    AND prl.SUGGESTED_BUYER_ID                     = p_person_id
    AND prl.line_location_id                      IS NULL;
    IF(l_cnt                                       > 0) THEN
      per_drt_pkg.add_to_results (person_id => p_person_id , entity_type => p_entity_type , status => 'E' ,
        msgcode => 'ICX_DRT_BUYER_NOT_ACTIVE' , msgaplid => 178 , result_tbl => result_tbl);
    END IF;

    -- Rule#6 : PROC-IP-10 : Set as default requester in iProcurement preferences.
    IF (g_debug = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix || l_api_name,
        'Rule#6 : PROC-IP-10 : Set as default requester in iProcurement preferences.');
    END IF;
    SELECT COUNT(*)
    INTO l_cnt
    FROM fnd_profile_options po,
      fnd_profile_option_values pv
    WHERE po.profile_option_name = 'POR_DEFAULT_REQUESTER_ID'
    AND po.profile_option_id     = pv.profile_option_id
    AND pv.profile_option_value  =TO_CHAR(p_person_id);
    IF(l_cnt                                       > 0) THEN
      per_drt_pkg.add_to_results (person_id => p_person_id , entity_type => p_entity_type , status => 'E' ,
        msgcode => 'ICX_DRT_REQUESTER_PROFILE' , msgaplid => 178 , result_tbl => result_tbl);
    END IF;

    --Bug#27892950 : Added constraints for person supplier(moved from TCA)
    -- Rule#1 : PROC-IP-01 Has active shopping carts for Person type : Supplier
    IF (g_debug = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix || l_api_name,
        'Rule#1 : PROC-IP-01 Has active shopping carts for Person type : Person Supplier');
    END IF;
    SELECT COUNT(*)
    INTO l_cnt
    FROM po_requisition_headers_all prh,
      po_requisition_lines_all prl
    WHERE prh.requisition_header_id                 = prl.requisition_header_id
    AND NVL(prh.authorization_status,'INCOMPLETE') IN ('SYSTEM_SAVED','INCOMPLETE')
    AND prl.vendor_id                              IN
      (SELECT vendor_id
      FROM po_vendors
      WHERE employee_id = p_person_id
      );
    IF(l_cnt > 0) THEN
      per_drt_pkg.add_to_results (person_id => p_person_id , entity_type => p_entity_type , status => 'W' ,
        msgcode => 'ICX_DRT_ACTIVE_VENDOR' , msgaplid => 178 , result_tbl => result_tbl);
    END IF;

    -- Rule#7 : PROC-IP-07 : Active Punch-out content zone exists on supplier name
    IF (g_debug = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix || l_api_name,
        'PROC-IP-07 : Active Punch-out content zone exists on supplier name');
    END IF;
    SELECT COUNT(*)
    INTO l_cnt
    FROM ICX_CAT_PUNCHOUT_ZONE_DETAILS zones
    WHERE zones.vendor_id IN
      (SELECT vendor_id
      FROM po_vendors
      WHERE employee_id = p_person_id
      );
    IF(l_cnt > 0) THEN
      per_drt_pkg.add_to_results (person_id => p_person_id , entity_type => p_entity_type , status => 'W' ,
        msgcode => 'ICX_DRT_ACTIVE_CONTENT_ZONE' , msgaplid => 178 , result_tbl => result_tbl);
    END IF;
    -- Rule#8 : PROC-IP-08 : Active smart form exists on supplier name
    IF (g_debug = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix || l_api_name,
        'PROC-IP-08 : Active smart form exists on supplier name');
    END IF;
    SELECT COUNT(*)
    INTO l_cnt
    FROM POR_NONCAT_TEMPLATES_ALL_B smart_forms
    WHERE smart_forms.supplier_id IN
      (SELECT vendor_id
      FROM po_vendors
      WHERE employee_id = p_person_id
      );
    IF(l_cnt > 0) THEN
      per_drt_pkg.add_to_results (person_id => p_person_id , entity_type => p_entity_type , status => 'W' ,
        msgcode => 'ICX_DRT_ACTIVE_SMART_FORM_1' , msgaplid => 178 , result_tbl => result_tbl);
    END IF;

    --Bug#27892950 : End

    -- if no warning/errors so far, record success to process_tbl
    IF(result_tbl.count < 1) THEN
      IF (g_debug       = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement, g_module_prefix || l_api_name,
          ' Record success to process_tbl.');
      END IF;
      per_drt_pkg.add_to_results (person_id => p_person_id , entity_type => p_entity_type , status => 'S' ,
        msgcode => NULL, msgaplid => 178 , result_tbl => result_tbl);
    END IF;
    IF (g_debug = 'Y' AND fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_procedure, g_module_prefix || l_api_name, 'End');
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    IF (g_debug = 'Y' AND fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_procedure, g_module_prefix || l_api_name,
        'Exception : sqlcode :'|| SQLCODE || ' Error Message : ' || sqlerrm);
    END IF;
    per_drt_pkg.add_to_results (person_id => p_person_id , entity_type => p_entity_type , status => 'E' ,
      msgcode => 'ICX_DRT_DRC_UNEXPECTED' , msgaplid => 178 , result_tbl => result_tbl);
  END icx_hr_drc;

--Call overloaded icx_hr_drc
  PROCEDURE icx_hr_drc(
      person_id IN NUMBER,
      result_tbl OUT nocopy per_drt_pkg.result_tbl_type )
  IS
  BEGIN
    icx_hr_drc(person_id,'HR',result_tbl);
  END icx_hr_drc;

-- DRC Procedure for person type : TCA
-- Does validation if passed in TCA Party ID can be masked by validating all
-- rules and passes back the out variable p_process_tbl which contains a
-- table of record of errors/warnings/successs
  PROCEDURE icx_tca_drc(
      person_id IN NUMBER,
      p_entity_type IN VARCHAR2 DEFAULT 'TCA',
      result_tbl OUT nocopy per_drt_pkg.result_tbl_type )
  IS
    l_cnt       NUMBER       := 0;
    l_api_name  VARCHAR2(30) := 'icx_tca_drc';
    p_person_id NUMBER       := person_id;
  BEGIN
    IF (g_debug = 'Y' AND fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_procedure, g_module_prefix || l_api_name, 'Start');
    END IF;
    -- Rule#1 : PROC-IP-01 Has active shopping carts for Person type : Supplier
    IF (g_debug = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix || l_api_name,
        'Rule#1 : PROC-IP-01 Has active shopping carts for Person type : Supplier');
    END IF;
    SELECT COUNT(*)
    INTO l_cnt
    FROM po_requisition_headers_all prh,
      po_requisition_lines_all prl
    WHERE prh.requisition_header_id                 = prl.requisition_header_id
    AND NVL(prh.authorization_status,'INCOMPLETE') IN ('SYSTEM_SAVED','INCOMPLETE')
    AND prl.vendor_id                              IN
      (SELECT pav.vendor_id
      FROM ap_suppliers pav,
        hz_parties hp
      WHERE pav.party_id = hp.party_id
      AND hp.party_id    = p_person_id
      AND hp.party_type  = 'PERSON'
      );
    IF(l_cnt > 0) THEN
      per_drt_pkg.add_to_results (person_id => p_person_id , entity_type => p_entity_type , status => 'W' ,
        msgcode => 'ICX_DRT_ACTIVE_VENDOR' , msgaplid => 178 , result_tbl => result_tbl);
    END IF;
    -- Rule#2 : PROC-IP-02 : Has active shopping carts for Person type : Supplier Contact
    IF (g_debug = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix || l_api_name,
        'Rule#2 : PROC-IP-02 : Has active shopping carts for Person type : Supplier Contact');
    END IF;
    SELECT COUNT(*)
    INTO l_cnt
    FROM po_requisition_headers_all prh,
      po_requisition_lines_all prl
    WHERE prh.requisition_header_id                 = prl.requisition_header_id
    AND NVL(prh.authorization_status,'INCOMPLETE') IN ('SYSTEM_SAVED','INCOMPLETE')
    AND prl.vendor_contact_id                      IN
      (SELECT vendor_contact_id
      FROM ap_supplier_contacts pvc,
        hz_parties hp
      WHERE pvc.per_party_id = hp.party_id
      AND hp.party_type      = 'PERSON'
      AND hp.party_id        = p_person_id
      );
    IF(l_cnt > 0) THEN
      per_drt_pkg.add_to_results (person_id => p_person_id , entity_type => p_entity_type , status => 'W' ,
        msgcode => 'ICX_DRT_ACTIVE_VENDOR_CONTACT' , msgaplid => 178 , result_tbl => result_tbl);
    END IF;
    -- Rule#7 : PROC-IP-07 : Active Punch-out content zone exists on supplier name
    IF (g_debug = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix || l_api_name,
        'PROC-IP-07 : Active Punch-out content zone exists on supplier name');
    END IF;
    SELECT COUNT(*)
    INTO l_cnt
    FROM ICX_CAT_PUNCHOUT_ZONE_DETAILS zones
    WHERE zones.vendor_id IN
      (SELECT pav.vendor_id
      FROM ap_suppliers pav,
        hz_parties hp
      WHERE pav.party_id = hp.party_id
      AND hp.party_id    = p_person_id
      AND hp.party_type  = 'PERSON'
      );
    IF(l_cnt > 0) THEN
      per_drt_pkg.add_to_results (person_id => p_person_id , entity_type => p_entity_type , status => 'W' ,
        msgcode => 'ICX_DRT_ACTIVE_CONTENT_ZONE' , msgaplid => 178 , result_tbl => result_tbl);
    END IF;
    -- Rule#8 : PROC-IP-08 : Active smart form exists on supplier name
    IF (g_debug = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix || l_api_name,
        'PROC-IP-08 : Active smart form exists on supplier name');
    END IF;
    SELECT COUNT(*)
    INTO l_cnt
    FROM POR_NONCAT_TEMPLATES_ALL_B smart_forms
    WHERE smart_forms.supplier_id IN
      (SELECT pav.vendor_id
      FROM ap_suppliers pav,
        hz_parties hp
      WHERE pav.party_id = hp.party_id
      AND hp.party_id    = p_person_id
      AND hp.party_type  = 'PERSON'
      );
    IF(l_cnt > 0) THEN
      per_drt_pkg.add_to_results (person_id => p_person_id , entity_type => p_entity_type , status => 'W' ,
        msgcode => 'ICX_DRT_ACTIVE_SMART_FORM_1' , msgaplid => 178 , result_tbl => result_tbl);
    END IF;
    -- Rule#9 : PROC-IP-09 : Active smart form exists on supplier contact
    IF (g_debug = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix || l_api_name,
        'PROC-IP-09 : Active smart form exists on supplier contact');
    END IF;
    SELECT COUNT(*)
    INTO l_cnt
    FROM POR_NONCAT_TEMPLATES_ALL_B smart_forms
    WHERE smart_forms.supplier_contact_id IN
      (SELECT vendor_contact_id
      FROM ap_supplier_contacts pvc,
        hz_parties hp
      WHERE pvc.per_party_id = hp.party_id
      AND hp.party_type      = 'PERSON'
      AND hp.party_id        = p_person_id
      );
    IF(l_cnt > 0) THEN
      per_drt_pkg.add_to_results (person_id => p_person_id , entity_type => p_entity_type , status => 'W' ,
        msgcode => 'ICX_DRT_ACTIVE_SMART_FORM_2' , msgaplid => 178 , result_tbl => result_tbl);
    END IF;

    -- if no warning/errors so far, record success to process_tbl
    IF(result_tbl.count < 1) THEN
      IF (g_debug       = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement, g_module_prefix || l_api_name,
          'Record success to process_tbl');
      END IF;
      per_drt_pkg.add_to_results (person_id => p_person_id , entity_type => p_entity_type , status => 'S' ,
        msgcode => NULL , msgaplid => 178 , result_tbl => result_tbl);
    END IF;
    IF (g_debug = 'Y' AND fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_procedure, g_module_prefix || l_api_name, 'End');
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    IF (g_debug = 'Y' AND fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_procedure, g_module_prefix || l_api_name,
        'Exception : sqlcode :'|| SQLCODE || ' Error Message : ' || sqlerrm);
    END IF;
    per_drt_pkg.add_to_results (person_id => p_person_id , entity_type => p_entity_type , status => 'E' ,
      msgcode => 'ICX_DRT_DRC_UNEXPECTED' , msgaplid => 178 , result_tbl => result_tbl);
  END icx_tca_drc;

-- Call overloaded icx_tca_drc
  PROCEDURE icx_tca_drc(
      person_id IN NUMBER,
      result_tbl OUT nocopy per_drt_pkg.result_tbl_type )
  IS
  BEGIN
    icx_tca_drc(person_id,'TCA', result_tbl);
  END icx_tca_drc;

-- DRC Procedure for person type : FND
-- Does validation if passed in FND Userid can be masked by validating all
-- rules and passes back the out variable p_process_tbl which contains a
-- table of record of errors/warnings/successs
  PROCEDURE icx_fnd_drc(
      person_id IN NUMBER,
      result_tbl OUT nocopy per_drt_pkg.result_tbl_type )
  IS
    l_api_name  VARCHAR2(30) := 'icx_fnd_drc';
    p_person_id NUMBER       := person_id;
    l_per_id    NUMBER       := 0;
    l_tca_id    NUMBER       :=0;
  BEGIN
    IF (g_debug = 'Y' AND fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_procedure, g_module_prefix || l_api_name, 'Start');
    END IF;
    BEGIN
      SELECT fu.employee_id
      INTO l_per_id
      FROM fnd_user fu
      WHERE fu.user_id = p_person_id;
    EXCEPTION
      WHEN OTHERS THEN
        l_per_id := 0;
    END;
    IF (g_debug      = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix || l_api_name,
        'Validate for Employee : ' || l_per_id );
    END IF;
    IF(l_per_id <> 0) THEN
      icx_hr_drc(l_per_id, 'FND', result_tbl);
    END IF;
    BEGIN
      SELECT DISTINCT hp.party_id
      INTO l_tca_id
      FROM fnd_user fu,
        ap_supplier_contacts pvc,
        hz_parties hp
      WHERE fu.person_party_id = pvc.per_party_id(+)
      AND pvc.per_party_id     = hp.party_id(+)
      AND hp.party_type        = 'PERSON'
      AND fu.user_id           = p_person_id;
      IF (g_debug              = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement, g_module_prefix || l_api_name,
          'Validate for TCA : ' || l_tca_id );
      END IF;
      IF(l_tca_id <> 0) THEN
        icx_tca_drc(l_tca_id, 'FND', result_tbl);
      END IF;
    EXCEPTION
    WHEN OTHERS THEN
      IF (g_debug = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement, g_module_prefix || l_api_name,
          'No Supplier contact for FND User');
      END IF;
    END;
    -- if no warning/errors so far, record success to process_tbl
    IF(result_tbl.count < 1) THEN
      IF (g_debug       = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement, g_module_prefix || l_api_name,
          'Record success to process_tbl');
      END IF;
      per_drt_pkg.add_to_results (person_id => p_person_id , entity_type => 'FND' , status => 'S' ,
        msgcode => NULL , msgaplid => 178 , result_tbl => result_tbl);
    END IF;
    IF (g_debug = 'Y' AND fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_procedure, g_module_prefix || l_api_name, 'End');
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    IF (g_debug = 'Y' AND fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_procedure, g_module_prefix || l_api_name,
        'Exception : sqlcode :'|| SQLCODE || ' Error Message : ' || sqlerrm);
    END IF;
    per_drt_pkg.add_to_results (person_id => p_person_id , entity_type => 'FND' , status => 'E' ,
      msgcode => 'ICX_DRT_DRC_UNEXPECTED' , msgaplid => 178 , result_tbl => result_tbl);
  END icx_fnd_drc;
END icx_drt_pkg;

/
