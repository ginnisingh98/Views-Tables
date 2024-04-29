--------------------------------------------------------
--  DDL for Package Body OKC_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_DRT_PKG" AS
/* $Header: OKCDRTPB.pls 120.0.12010000.4 2018/05/15 09:29:42 kkolukul noship $ */
  g_debug         CONSTANT VARCHAR2(1)  := NVL(fnd_profile.value('AFLOG_ENABLED'), 'N');
  g_pkg_name      CONSTANT VARCHAR2(30) := 'OKC_DRT_PKG';
  g_module_prefix CONSTANT VARCHAR2(50) := 'okc.plsql.' || g_pkg_name || '.';

/* --
--- Implement helper procedure add record corresponding to an error/warning/error
--
PROCEDURE add_to_results(
    person_id   IN NUMBER ,
    entity_type IN VARCHAR2 ,
    status      IN VARCHAR2 ,
    msgcode     IN VARCHAR2 ,
    msgaplid    IN NUMBER ,
    result_tbl  IN OUT NOCOPY per_drt_pkg.process_tbl_type)
IS
  n NUMBER(15);
BEGIN
  n                         := result_tbl.count + 1;
  result_tbl(n).person_id   := person_id;
  result_tbl(n).entity_type := entity_type;
  result_tbl(n).status      := status;
  result_tbl(n).msgcode     := msgcode;
  hr_utility.set_message(msgaplid,msgcode);
  result_tbl(n).msgtext := hr_utility.get_message();
END add_to_results;         */

-- DRC Procedure for person type : HR
-- Does validation if passed in HR person can be masked by validating all
-- rules and passes back the out variable p_process_tbl which contains a
-- table of record of errors/warnings/successs
  PROCEDURE okc_hr_drc(
      person_id IN NUMBER,
      result_tbl OUT nocopy per_drt_pkg.result_tbl_type )
  IS
    l_cnt      NUMBER       := 0;
    l_api_name VARCHAR2(30) := 'okc_hr_drc';

  BEGIN

    IF (g_debug = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix || l_api_name, 'Evaluate rule -- Rule#1 CONT-OKC-4: Is an internal contact on pending approval/signature contracts');
    END IF;

    -- Rule#1 CONT-OKC-4: Is an internal contact on pending approval/signature contracts
    SELECT COUNT(*)
    INTO l_cnt
    FROM okc_rep_party_contacts orpc, okc_rep_contracts_all orca
    WHERE orca.contract_id   = orpc.contract_id
    AND NVL(orca.contract_status_code,'DRAFT') IN ('PENDING_APPROVAL', 'PENDING_SIGNATURE')
    AND orpc.party_role_code = 'INTERNAL_ORG'
    AND orpc.contact_id      = person_id;

    IF (g_debug = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix || l_api_name, 'Person is an internal contact on Pending approval/signature contracts: '|| l_cnt);
    END IF;

    IF(l_cnt > 0) THEN
      per_drt_pkg.add_to_results (person_id => person_id , entity_type => 'HR' , status => 'E' ,
      msgcode => 'OKC_DRT_PEND_INT_CONTACT' , msgaplid => 510 , result_tbl => result_tbl);
    END IF;

    -- Rule#2 CONT-OKC-12: Is an internal contact on active contracts
    IF (g_debug = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix || l_api_name, 'Evaluate rule -- Rule#2 CONT-OKC-12: Is an internal contact on active contracts');
    END IF;

    SELECT COUNT(*)
    INTO l_cnt
    FROM okc_rep_party_contacts orpc, okc_rep_contracts_all orca
    WHERE orca.contract_id   = orpc.contract_id
    AND NVL(orca.contract_status_code,'DRAFT') IN ('APPROVED', 'SIGNED' )
    AND orpc.party_role_code = 'INTERNAL_ORG'
    AND orpc.contact_id      = person_id;

    IF (g_debug = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix || l_api_name, 'Person is an internal contact on active contracts: '|| l_cnt);
    END IF;

    IF(l_cnt > 0) THEN
      per_drt_pkg.add_to_results (person_id => person_id , entity_type => 'HR' , status => 'W' ,
      msgcode => 'OKC_DRT_ACTIVE_INT_CONTACT' , msgaplid => 510 , result_tbl => result_tbl);
    END IF;

    -- Rule#3 : CONT-OKC-10 : Contracts with open deliverables where the person is either an internal_party_contact or Escalation contact or requester.
    IF (g_debug = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix || l_api_name, 'Evaluate rule -- Rule#3 : CONT-OKC-10 : Contracts with open deliverables
                     where the person is either an internal_party_contact or Escalation contact or requester.');
    END IF;

    SELECT COUNT(*)
    INTO l_cnt
    FROM okc_deliverables d
    WHERE d.deliverable_status NOT IN ('CANCELLED', 'COMPLETED', 'INACTIVE')       --other statuses open, rejected, submited, failed to perform
    AND manage_yn = 'Y'
    AND (d.internal_party_contact_id  = person_id
      OR d.escalation_assignee = person_id
      OR d.requester_id = person_id);

    IF (g_debug = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix || l_api_name, 'Person is a contact on open deliverables : '|| l_cnt);
    END IF;

    IF(l_cnt > 0) THEN
      per_drt_pkg.add_to_results (person_id => person_id , entity_type => 'HR' , status => 'E' ,
      msgcode => 'OKC_DRT_ACTIVE_DEL_CONTACT' , msgaplid => 510 , result_tbl => result_tbl);
    END IF;

     -- Rule#4 : CONT-OKC-14 : Contracts have generated PDF documents which may have personal information.

    IF (g_debug = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix || l_api_name, 'Evaluate rule --  Rule#4 : CONT-OKC-14 : Contracts have generated
                                                                         PDF documents which may have personal information.');
    END IF;

    SELECT COUNT(*)
    INTO l_cnt
    FROM okc_rep_party_contacts orpc, okc_rep_contracts_all orca  , okc_contract_docs d
    WHERE orca.contract_id   = orpc.contract_id
    AND orpc.party_role_code = 'INTERNAL_ORG'
    AND d.business_document_id = orca.contract_id
    AND d.business_document_type = orca.contract_type
    AND (d.business_document_version  = orca.contract_version_num OR d.business_document_version = '-99')
    AND orpc.contact_id      = person_id;

    IF (g_debug = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix || l_api_name, 'Person is a contact on openrepository contracts with attachments : '|| l_cnt);
    END IF;

    IF(l_cnt > 0) THEN
      per_drt_pkg.add_to_results (person_id => person_id , entity_type => 'HR' , status => 'W' ,
      msgcode => 'OKC_DRT_INT_CON_PDF' , msgaplid => 510 , result_tbl => result_tbl);
    END IF;

    -- if no warning/errors so far, record success to process_tbl
    IF(result_tbl.count < 1) THEN
      IF (g_debug       = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement, g_module_prefix || l_api_name,
          ' Record success to process_tbl.');
      END IF;
      per_drt_pkg.add_to_results (person_id => person_id , entity_type => 'HR' , status => 'S' ,
        msgcode => NULL, msgaplid =>  510, result_tbl => result_tbl);
    END IF;
    IF (g_debug = 'Y' AND fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_procedure, g_module_prefix || l_api_name, 'End');
    END IF;

  EXCEPTION
  WHEN OTHERS THEN
    IF (g_debug = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix ||
        l_api_name, 'Exception : sqlcode :'|| SQLCODE || ' Error Message : ' || sqlerrm);
    END IF;
    per_drt_pkg.add_to_results (person_id => person_id , entity_type => 'HR' , status => 'E' ,
               msgcode => 'OKC_DRT_DRC_UNEXPECTED' , msgaplid => 510 , result_tbl => result_tbl);
  END okc_hr_drc;

-- DRC Procedure for person type : TCA
-- Does validation if passed in TCA Party ID can be masked by validating all
-- rules and passes back the out variable p_process_tbl which contains a
-- table of record of errors/warnings/successs
PROCEDURE okc_tca_drc(
      person_id IN NUMBER,
      result_tbl OUT nocopy per_drt_pkg.result_tbl_type )
  IS

    l_cnt      NUMBER       := 0;
    l_api_name VARCHAR2(30) := 'okc_tca_drc';

  BEGIN
    IF (g_debug = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix || l_api_name, 'Start');
    END IF;

    -- Rule#1 : CONT-OKC-07 Has active contracts for Person Party (Partner)
     IF (g_debug = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix || l_api_name, ' Rule#1 : CONT-OKC-07 Has active contracts for Person Party (Partner)');
    END IF;

    SELECT COUNT(*)
    INTO l_cnt
    FROM okc_rep_contracts_all orca,
      okc_rep_contract_parties orcp,
      hz_parties hp
    WHERE orca.contract_id = orcp.contract_id
    AND NVL(orca.contract_status_code,'DRAFT') NOT IN ('DRAFT','REJECTED', 'TERMINATED', 'CANCELED')
    AND orcp.party_id = hp.party_id
    AND orcp.PARTY_ROLE_CODE = 'PARTNER_ORG'
    AND hp.party_id    = person_id
    AND party_type IN ('PERSON');

    IF (g_debug = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix || l_api_name, 'No.Of contracts where the person is a party on active contracts: '|| l_cnt);
    END IF;

    IF(l_cnt > 0) THEN
      per_drt_pkg.add_to_results (person_id => person_id , entity_type => 'TCA' , status => 'E' ,
      msgcode => 'OKC_DRT_ACTIVE_PER_PARTY' , msgaplid => 510 , result_tbl => result_tbl);
    END IF;

    -- Rule#2 : CONT-OKC-05 Has active contracts for Person Supplier
     IF (g_debug = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix || l_api_name, ' Rule#2 : CONT-OKC-05 Has active contracts for Person Supplier');
    END IF;

    SELECT COUNT(*)
    INTO l_cnt
    FROM okc_rep_contracts_all orca,
      okc_rep_contract_parties orcp
    WHERE orca.contract_id = orcp.contract_id
    AND NVL(orca.contract_status_code,'DRAFT') NOT IN ('DRAFT','REJECTED', 'TERMINATED', 'CANCELED')
    AND orcp.party_id IN
      (SELECT pav.vendor_id
      FROM ap_suppliers pav,
        hz_parties hp
      WHERE pav.party_id = hp.party_id
      AND hp.party_id    = person_id
      AND hp.party_type  = 'PERSON');

    IF (g_debug = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix || l_api_name, 'No.Of contracts where the person is a supplier party on active contracts: '|| l_cnt);
    END IF;

    IF(l_cnt > 0) THEN
      per_drt_pkg.add_to_results (person_id => person_id , entity_type => 'TCA' , status => 'E' ,
      msgcode => 'OKC_DRT_ACTIVE_PER_SUPP' , msgaplid => 510 , result_tbl => result_tbl);
    END IF;

      -- Rule#3 : CONT-OKC-06 Has active contracts for Person customer
     IF (g_debug = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix || l_api_name, ' Rule#3 : CONT-OKC-06 Has active contracts for Person customer');
    END IF;

    SELECT COUNT(*)
    INTO l_cnt
    FROM okc_rep_contracts_all orca,
      okc_rep_contract_parties orcp,
      hz_parties hp
    WHERE orca.contract_id = orcp.contract_id
    AND NVL(orca.contract_status_code,'DRAFT') NOT IN ('DRAFT','REJECTED', 'TERMINATED', 'CANCELED')
    AND orcp.party_id = hp.party_id
    AND orcp.PARTY_ROLE_CODE = 'CUSTOMER_ORG'
    AND hp.party_id    = person_id
    AND party_type IN ( 'PERSON');

    IF (g_debug = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix || l_api_name, 'No.Of contracts where the person is a customer party on active contracts: '|| l_cnt);
    END IF;

    IF(l_cnt > 0) THEN
      per_drt_pkg.add_to_results (person_id => person_id , entity_type => 'TCA' , status => 'E' ,
      msgcode => 'OKC_DRT_ACTIVE_PER_CUST' , msgaplid => 510 , result_tbl => result_tbl);
    END IF;

    -- Rule#4 :  CONT-OKC-02 Supplier contact on contracts in Pending approval or Signature process
     IF (g_debug = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix || l_api_name, ' Rule#4 :  CONT-OKC-02 Supplier contact on contracts in Pending approval or Signature process');
    END IF;

    SELECT COUNT(*)
    INTO l_cnt
    FROM okc_rep_contracts_all orca,
      okc_rep_party_contacts orpc
    WHERE orca.contract_id = orpc.contract_id
    AND NVL(orca.contract_status_code,'DRAFT')  IN ('PENDING_APPROVAL','PENDING_SIGNATURE')
    AND orpc.PARTY_ROLE_CODE IN ('SUPPLIER_ORG')
    AND orpc.contact_id IN (SELECT ven.vendor_contact_id
                     FROM po_vendor_contacts ven, hz_parties hz
                     WHERE ven.PER_PARTY_ID = hz.party_id
                     AND hz.party_id = person_id);

    IF (g_debug = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix || l_api_name, 'No.Of contracts where the person is a supplier contact on active contracts: '|| l_cnt);
    END IF;

    IF(l_cnt > 0) THEN
      per_drt_pkg.add_to_results (person_id => person_id , entity_type => 'TCA' , status => 'E' ,
      msgcode => 'OKC_DRT_ACTIVE_SUPP_CONTACT' , msgaplid => 510 , result_tbl => result_tbl);
    END IF;

    -- Rule#5 :  CONT-OKC-03 Customer contact on contracts in Pending approval or Signature process
    IF (g_debug = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix || l_api_name, ' Rule#5 :  CONT-OKC-03 Customer contact on contracts in Pending approval or Signature process');
    END IF;

    SELECT COUNT(*)
    INTO l_cnt
    FROM okc_rep_contracts_all orca,
      okc_rep_party_contacts orpc
    WHERE orca.contract_id = orpc.contract_id
    AND NVL(orca.contract_status_code,'DRAFT')  IN ('PENDING_APPROVAL','PENDING_SIGNATURE')
    AND orpc.PARTY_ROLE_CODE in ('PARTNER_ORG', 'CUSTOMER_ORG')
    AND orpc.contact_id IN (SELECT hr.party_id
                      FROM hz_parties hz, hz_relationships hr
                     WHERE hr.object_type = 'ORGANIZATION'
                     AND hr.object_table_name = 'HZ_PARTIES'
                     AND hr.subject_type = 'PERSON'
                     AND hz.party_id = hr.subject_id
                     AND hz.party_id = person_id);

    IF (g_debug = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix || l_api_name, 'No.Of contracts where the person is a customer or partner contact on active contracts: '|| l_cnt);
    END IF;

    IF(l_cnt > 0) THEN
      per_drt_pkg.add_to_results (person_id => person_id , entity_type => 'TCA' , status => 'E' ,
      msgcode => 'OKC_DRT_ACTIVE_CUST_CONTACT' , msgaplid => 510 , result_tbl => result_tbl);
    END IF;

        -- Rule#6 :  CONT-OKC-8 Contacts with open deliverables.
     IF (g_debug = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix || l_api_name, ' Rule#6 :  CONT-OKC-08 Contacts with Pending Deliverables');
    END IF;

    SELECT COUNT(*)
    INTO l_cnt
    FROM okc_deliverables d
    WHERE d.deliverable_status NOT IN ('CANCELLED', 'COMPLETED', 'INACTIVE')       --other statuses open, rejected, submited, failed to perform
    AND manage_yn = 'Y'
    AND (d.external_party_contact_id  = person_id
      OR d.external_party_id = person_id);

    IF (g_debug = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix || l_api_name, 'No.Of deliverables where the person is a contact: '|| l_cnt);
    END IF;

    IF(l_cnt > 0) THEN
      per_drt_pkg.add_to_results (person_id => person_id , entity_type => 'TCA' , status => 'E' ,
      msgcode => 'OKC_DRT_ACTIVE_DEL_CONTACT' , msgaplid => 510 , result_tbl => result_tbl);
    END IF;

     -- Rule#7 :  CONT-OKC-15 Person Supplier - Has generated PDF documents which may have personal information.

     IF (g_debug = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix || l_api_name, ' Rule#7 :  CONT-OKC-15 Person Supplier
                                                            - Has generated PDF documents which may have personal information.');
    END IF;

    SELECT COUNT(orca.contract_id)
    INTO l_cnt
    FROM okc_rep_contracts_all orca,
      okc_rep_contract_parties orcp,
      okc_contract_docs d
    WHERE orca.contract_id = orcp.contract_id
    AND d.business_document_id = orca.contract_id
    AND d.business_document_type = orca.contract_type
    AND (d.business_document_version  = orca.contract_version_num OR d.business_document_version = '-99')
    AND orcp.party_id IN
      (SELECT pav.vendor_id
      FROM ap_suppliers pav,
        hz_parties hp
      WHERE pav.party_id = hp.party_id
      AND hp.party_id    = person_id
      AND hp.party_type  = 'PERSON');


    IF (g_debug = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix || l_api_name, 'No.Of contracts where the person is a supplier party and has documents: '|| l_cnt);
    END IF;

    IF(l_cnt > 0) THEN
      per_drt_pkg.add_to_results (person_id => person_id , entity_type => 'TCA' , status => 'W' ,
      msgcode => 'OKC_DRT_PER_SUPP_PDF' , msgaplid => 510 , result_tbl => result_tbl);
    END IF;

     -- Rule#8 :  CONT-OKC-16 Person Customer - Has generated PDF documents which may have personal information.

     IF (g_debug = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix || l_api_name, ' Rule#8 :  CONT-OKC-16 Person Customer
                                                            - Has generated PDF documents which may have personal information.');
    END IF;

    SELECT COUNT(*)
    INTO l_cnt
    FROM okc_rep_contracts_all orca,
      okc_rep_contract_parties orcp,
      hz_parties hp,
      okc_contract_docs d
    WHERE orca.contract_id = orcp.contract_id
    AND orcp.party_id = hp.party_id
    AND orcp.PARTY_ROLE_CODE in ('PARTNER_ORG', 'CUSTOMER_ORG')
    AND party_type IN ( 'PERSON')
    AND  d.business_document_id = orca.contract_id
    AND d.business_document_type = orca.contract_type
    AND (d.business_document_version  = orca.contract_version_num OR d.business_document_version = '-99')
    AND hp.party_id    = person_id;

    IF (g_debug = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix || l_api_name, 'No.Of contracts where the person is a party and has documents: '|| l_cnt);
    END IF;

    IF(l_cnt > 0) THEN
      per_drt_pkg.add_to_results (person_id => person_id , entity_type => 'TCA' , status => 'W' ,
      msgcode => 'OKC_DRT_PER_CUST_PDF' , msgaplid => 510 , result_tbl => result_tbl);
    END IF;

    -- Rule#9 : CONT-OKC-17 Supplier Contact	Has generated PDF documents which may have personal information.

     IF (g_debug = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix || l_api_name, ' Rule#9 : CONT-OKC-17 Supplier Contact	Has generated PDF documents which may have personal information.');
    END IF;

    SELECT COUNT(*)
    INTO l_cnt
    FROM okc_rep_contracts_all orca,
      okc_rep_party_contacts orpc,
      okc_contract_docs d
    WHERE orca.contract_id = orpc.contract_id
    AND d.business_document_id = orca.contract_id
    AND d.business_document_type = orca.contract_type
    AND (d.business_document_version  = orca.contract_version_num OR d.business_document_version = '-99')
    AND orpc.PARTY_ROLE_CODE IN ('SUPPLIER_ORG')
    AND orpc.contact_id IN (SELECT ven.vendor_contact_id
                     FROM po_vendor_contacts ven, hz_parties hz
                     WHERE ven.PER_PARTY_ID = hz.party_id
                     AND hz.party_id = person_id);

    IF (g_debug = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix || l_api_name, 'Rule#10 : No.of contracts that have generated PDF documents which may have personal information. '|| l_cnt);
    END IF;

    IF(l_cnt > 0) THEN
      per_drt_pkg.add_to_results (person_id => person_id , entity_type => 'TCA' , status => 'W' ,
      msgcode => 'OKC_DRT_SUPP_CON_PDF' , msgaplid => 510 , result_tbl => result_tbl);
    END IF;

    -- Rule#10 : CONT-OKC-18 Party Contact	Has generated PDF documents which may have personal information.

     IF (g_debug = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix || l_api_name, ' Rule#10 : CONT-OKC-18 Party Contact	Has generated PDF documents which may have personal information.');
    END IF;

    SELECT COUNT(*)
    INTO l_cnt
    FROM okc_rep_contracts_all orca,
      okc_rep_party_contacts orpc
    WHERE orca.contract_id = orpc.contract_id
    AND orpc.PARTY_ROLE_CODE in ('PARTNER_ORG', 'CUSTOMER_ORG')
    AND orpc.contact_id IN (SELECT hr.party_id
                      FROM hz_parties hz, hz_relationships hr
                     WHERE hr.object_type = 'ORGANIZATION'
                     AND hr.object_table_name = 'HZ_PARTIES'
                     AND hr.subject_type = 'PERSON'
                     AND hz.party_id = hr.subject_id
                     AND hz.party_id = person_id);

    IF (g_debug = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix || l_api_name, 'Rule#10 : No.of contracts that have generated PDF documents which may have personal information. '|| l_cnt);
    END IF;

    IF(l_cnt > 0) THEN
      per_drt_pkg.add_to_results (person_id => person_id , entity_type => 'TCA' , status => 'W' ,
      msgcode => 'OKC_DRT_CUST_CON_PDF' , msgaplid => 510 , result_tbl => result_tbl);
    END IF;

-- if no warning/errors so far, record success to process_tbl
    IF(result_tbl.count < 1) THEN
      IF (g_debug       = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(fnd_log.level_statement, g_module_prefix || l_api_name,
          'Record success to process_tbl');
      END IF;
      per_drt_pkg.add_to_results (person_id => person_id , entity_type => 'TCA' , status => 'S' ,
        msgcode => NULL , msgaplid => 510 , result_tbl => result_tbl);
    END IF;
    IF (g_debug = 'Y' AND fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_procedure, g_module_prefix || l_api_name, 'End');
    END IF;

  EXCEPTION
  WHEN OTHERS THEN
    IF (g_debug = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix ||
        l_api_name, 'Exception : sqlcode :'|| SQLCODE || ' Error Message : ' || sqlerrm);
    END IF;
   per_drt_pkg.add_to_results (person_id => person_id , entity_type => 'TCA' , status => 'E' ,
               msgcode => 'OKC_DRT_DRC_UNEXPECTED' , msgaplid => 510 , result_tbl => result_tbl);
END okc_tca_drc;

-- DRC Procedure for person type : FND
-- Does validation if passed in FND Userid can be masked by validating all
-- rules and passes back the out variable p_process_tbl which contains a
-- table of record of errors/warnings/successs
  PROCEDURE okc_fnd_drc(
      person_id IN NUMBER,
      result_tbl OUT nocopy per_drt_pkg.result_tbl_type )
  IS
    l_index    NUMBER       := 0; -- for process_tbl index
    l_cnt      NUMBER       := 0;
    l_api_name VARCHAR2(30) := 'okc_fnd_drc';

  BEGIN
    IF (g_debug = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix || l_api_name, 'Start');
    END IF;

      -- Rule#1 CONT-OKC-01: Has contracts in Pending Approval or Pending Signature
    IF (g_debug = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
               fnd_log.string(fnd_log.level_statement, g_module_prefix || l_api_name, 'Rule#1 CONT-OKC-01: Has contracts in Pending Approval or Pending Signature' );
     END IF;
    SELECT COUNT(*)
    INTO l_cnt
    FROM okc_rep_contracts_all orca
    WHERE NVL(orca.contract_status_code,'DRAFT') IN ('PENDING_APPROVAL', 'PENDING_SIGNATURE' )
    AND orca.OWNER_ID  = person_id;

     IF (g_debug = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
               fnd_log.string(fnd_log.level_statement, g_module_prefix || l_api_name, 'No.of contracts in Pending Approval or Pending Signature for this person as contract Administrator: '||l_cnt );
     END IF;


    IF(l_cnt > 0) THEN
      per_drt_pkg.add_to_results (person_id => person_id , entity_type => 'FND' , status => 'E' ,
        msgcode => 'OKC_DRT_PEND_APP_SIG_ADMIN' , msgaplid => 510 , result_tbl => result_tbl);
     END IF;

  -- Rule#2 CONT-OKC-01: Has active contracts
  IF (g_debug = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_statement, g_module_prefix || l_api_name, 'Rule#1 CONT-OKC-01: Has contracts in Approved or Signed status' );
  END IF;

    SELECT COUNT(*)
    INTO l_cnt
    FROM okc_rep_contracts_all orca
    WHERE NVL(orca.contract_status_code,'DRAFT') IN ('APPROVED', 'SIGNED')
    AND orca.OWNER_ID  = person_id;

     IF (g_debug = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
               fnd_log.string(fnd_log.level_statement, g_module_prefix || l_api_name, 'No.of contracts in Approved or  Signed status for this contract: '|| l_cnt );
     END IF;

    IF(l_cnt > 0) THEN
      per_drt_pkg.add_to_results (person_id => person_id , entity_type => 'FND' , status => 'E' ,
        msgcode => 'OKC_DRT_APP_SIG_ADMIN' , msgaplid => 510 , result_tbl => result_tbl);
     END IF;

     -- Rule#3 CONT-OKC-13: Has generated PDF documents which may have personal information.

  IF (g_debug = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_statement, g_module_prefix || l_api_name, 'Rule#1 CONT-OKC-13: Has generated PDF documents which may have personal information.' );
  END IF;

   SELECT COUNT(*)
   INTO l_cnt
    FROM okc_contract_docs d , okc_rep_contracts_all orca
    WHERE d.business_document_id = orca.contract_id
    AND d.business_document_type = orca.contract_type
    AND (d.business_document_version  = orca.contract_version_num OR d.business_document_version = '-99')
    AND orca.owner_id = person_id;

     IF (g_debug = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
               fnd_log.string(fnd_log.level_statement, g_module_prefix || l_api_name, 'No.of contracts where the person is admin and has attachments: '|| l_cnt );
     END IF;

    IF(l_cnt > 0) THEN
      per_drt_pkg.add_to_results (person_id => person_id , entity_type => 'FND' , status => 'W' ,
        msgcode => 'OKC_DRT_CON_ADMIN_PDF' , msgaplid => 510 , result_tbl => result_tbl);
     END IF;

       -- Rule#4 CONT-OKC-17: User has been setup as Library Administrator/ Approver.

  IF (g_debug = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
    fnd_log.string(fnd_log.level_statement, g_module_prefix || l_api_name, 'Rule#1 CONT-OKC-17: User has been setup as Library Administrator/ Approver.' );
  END IF;

    SELECT Count(*)
    INTO l_cnt
    FROM HR_ORGANIZATION_INFORMATION hr, fnd_user fu
    WHERE hr.ORG_INFORMATION_CONTEXT = 'OKC_TERMS_LIBRARY_DETAILS'
    AND (fu.user_name = org_information2
          OR fu.user_name = org_information3
          OR fu.user_name = org_information6
          OR fu.user_name = org_information7)
    AND fu.user_id = person_id;

     IF (g_debug = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
               fnd_log.string(fnd_log.level_statement, g_module_prefix || l_api_name, 'The person is setup as Contract Terms Library Administrator / Approver: '|| l_cnt );
     END IF;

    IF(l_cnt > 0) THEN
      per_drt_pkg.add_to_results (person_id => person_id , entity_type => 'FND' , status => 'E' ,
        msgcode => 'OKC_DRT_LIB_ADMIN' , msgaplid => 510 , result_tbl => result_tbl);
     END IF;

-- if no warning/errors so far, record success to process_tbl
    IF(result_tbl.count < 1) THEN
      per_drt_pkg.add_to_results (person_id => person_id , entity_type => 'FND' , status => 'S' ,
        msgcode => NULL , msgaplid => 510 , result_tbl => result_tbl);
    END IF;

    IF (g_debug    = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix || l_api_name, 'End');
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    IF (g_debug = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_module_prefix ||
        l_api_name, 'Exception : sqlcode :'|| SQLCODE || ' Error Message : ' || sqlerrm);
    END IF;
   per_drt_pkg.add_to_results (person_id => person_id , entity_type => 'FND' , status => 'E' ,
                 msgcode => 'OKC_DRT_DRC_UNEXPECTED' , msgaplid => 510 , result_tbl => result_tbl);
  END okc_fnd_drc;
END okc_drt_pkg;

/
