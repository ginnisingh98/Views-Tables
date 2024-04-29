--------------------------------------------------------
--  DDL for Package Body POS_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_DRT_PKG" AS
 /* $Header: POS_DRT_PKG.plb 120.0.12010000.4 2018/06/20 10:50:07 ramkandu noship $ */

  g_debug         CONSTANT VARCHAR2(1)  := NVL(fnd_profile.value('AFLOG_ENABLED'), 'N');
  g_pkg_name      CONSTANT VARCHAR2(30) := 'POS_DRT_PKG';
  g_module_prefix CONSTANT VARCHAR2(50) := 'pos.plsql.' || g_pkg_name || '.';
  g_gdpr_ex       EXCEPTION;
  PRAGMA EXCEPTION_INIT( g_gdpr_ex, -20001 );

-- Print log when debug enabled

 procedure print_log(p_module varchar2, p_message varchar2) is
   begin
       if (nvl(fnd_profile.value('AFLOG_ENABLED'),'N') = 'Y') then
           if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
               fnd_log.string(log_level => fnd_log.level_statement,
                               module    => p_module,
                               message   => p_message);
           end if;
       end if;
   end;

   -- DRC Procedure for person type : HR
   -- Does validation if passed in HR person can be masked by validating all
   -- rules and passes back the out variable p_process_tbl which contains a
   -- table of record of errors/warnings/successs

    PROCEDURE pos_hr_drc (
        person_id IN NUMBER,
        result_tbl OUT nocopy per_drt_pkg.result_tbl_type
    ) IS
    l_cnt      NUMBER       := 0;
    l_api_name VARCHAR2(30) := 'pos_hr_drc';
    p_person_id NUMBER      := person_id;

    BEGIN
    print_log( g_module_prefix || l_api_name, 'Start');

    -- Rule#10 PROC-ISP-10: This person is part of internal scoring team Person type : Employee(Buyer)
    print_log( g_module_prefix || l_api_name, '  -- Rule#10 PROC-ISP-10: This person is part of internal scoring team Person type : Employee(Buyer)');

    select count(*)
    into   l_cnt
    from   pon_scoring_team_members pst, pon_auction_headers_all pah
    where  pah.auction_header_id = pst.auction_header_id
    and    pst.user_id in ( select user_id from fnd_user where employee_id = p_person_id)
    and    pah.auction_status not in ('DELETED', 'CANCELLED', 'AUCTION_CLOSED', 'AMENDED', 'APPLIED');

    print_log( g_module_prefix || l_api_name, ' Count for user in scoring team :'||l_cnt);

    IF(l_cnt                              > 0) THEN
      per_drt_pkg.add_to_results (person_id => p_person_id , entity_type => 'HR' , status => 'W' ,
        msgcode => 'POS_DRT_SCORING_TEAM_EXISTS' , msgaplid => 177 , result_tbl => result_tbl);
    END IF;


    -- Rule#10 PROC-ISP-10: This person is part of internal evaluation team Person type : Employee(Buyer)
    print_log( g_module_prefix || l_api_name, '   -- Rule#10 PROC-ISP-10: This person is part of internal evaluation team Person type : Employee(Buyer)');

    select count(*)
    into   l_cnt
    from   pon_evaluation_team_members pet, pon_auction_headers_all pah
    where  pah.auction_header_id = pet.auction_header_id
    and    pet.user_id in ( select user_id from fnd_user where employee_id = p_person_id)
    and    pah.auction_status not in ('DELETED', 'CANCELLED', 'AUCTION_CLOSED', 'AMENDED', 'APPLIED');

    print_log( g_module_prefix || l_api_name, ' Count for user in evaluation team :'||l_cnt);

    IF(l_cnt                              > 0) THEN
      per_drt_pkg.add_to_results (person_id => p_person_id , entity_type => 'HR' , status => 'W' ,
        msgcode => 'POS_DRT_EVAL_TEAM_EXISTS' , msgaplid => 177 , result_tbl => result_tbl);
    END IF;
    -- if no warning/errors so far, record success to result_tbl
     IF(result_tbl.count < 1) THEN
       print_log( g_module_prefix || l_api_name, ' Record success to result_tbl');
       per_drt_pkg.add_to_results (person_id => p_person_id , entity_type => 'HR' , status => 'S' ,
        msgcode => NULL , msgaplid => 177 , result_tbl => result_tbl);
     END IF;
     print_log( g_module_prefix || l_api_name, 'End');

    EXCEPTION
    WHEN OTHERS THEN
       print_log( g_module_prefix || l_api_name,
       'Exception : sqlcode :'|| SQLCODE || ' Error Message : ' || sqlerrm);
       per_drt_pkg.add_to_results (person_id => p_person_id , entity_type => 'HR' , status => 'E' ,
        msgcode => 'POS_DRT_DRC_UNEXPECTED' , msgaplid => 177 , result_tbl => result_tbl);
    END pos_hr_drc;


-- DRC Procedure for person type : TCA
-- Does validation if passed in TCA Party ID can be masked by validating all
-- rules and passes back the out variable p_process_tbl which contains a
-- table of record of errors/warnings/successs

    PROCEDURE pos_tca_drc (
        person_id IN NUMBER,
        result_tbl OUT nocopy per_drt_pkg.result_tbl_type
    ) IS
      l_cnt      NUMBER       := 0;
      l_api_name VARCHAR2(30) := 'pos_tca_drc';
      p_person_id NUMBER      := person_id;
    BEGIN

    print_log( g_module_prefix || l_api_name, 'Start');

    -- Rule#9 PROC-ISP-09: Pending Change Requests exists for this contact : TCA Party (Supplier Contact)
    print_log( g_module_prefix || l_api_name, '  -- Rule#9 PROC-ISP-09: Pending Change Requests exists for this contact : TCA Party (Supplier Contact)');

    select count(*)
    into l_cnt
    from pos_contact_requests
    where contact_party_id = p_person_id
    and request_status = 'PENDING';

    print_log( g_module_prefix || l_api_name, ' Count for contact change requests :'||l_cnt);

    IF(l_cnt                              > 0) THEN
      per_drt_pkg.add_to_results (person_id => p_person_id , entity_type => 'TCA' , status => 'E' ,
        msgcode => 'POS_DRT_PENDING_CNTC_CHG' , msgaplid => 177 , result_tbl => result_tbl);
    END IF;


    -- Rule#8 PROC-ISP-08: Pending Change Requests exists for this contact address : TCA Party (Supplier Contact)
    print_log( g_module_prefix || l_api_name, '  -- Rule#8 PROC-ISP-08: Pending Change Requests exists for this contact address : TCA Party (Supplier Contact)');

    select count(*)
    into l_cnt
    from pos_address_requests
    where party_site_id in (select party_site_id
                            from hz_party_sites
                            where party_id = p_person_id)
    and request_status = 'PENDING';

    print_log( g_module_prefix || l_api_name, ' Count for address change requests :'||l_cnt);

    IF(l_cnt                              > 0) THEN
      per_drt_pkg.add_to_results (person_id => p_person_id , entity_type => 'TCA' , status => 'E' ,
        msgcode => 'POS_DRT_PENDING_ADDR_CHG' , msgaplid => 177 , result_tbl => result_tbl);
    END IF;

    -- Rule#11 PROC-ISP-11: Pending Change Requests exist for the bank accounts of this contact: TCA Party (Supplier Contact)
    print_log( g_module_prefix || l_api_name, '  -- Rule#11 PROC-ISP-11: Pending Change Requests exist for the bank accounts of this contact : TCA Party (Supplier Contact)');

    SELECT Count(*) INTO l_cnt
    FROM IBY_TEMP_EXT_BANK_ACCTS temp
    WHERE temp.temp_ext_bank_acct_id IN
    (select req.temp_ext_bank_acct_id
    FROM POS_ACNT_GEN_REQ req, fnd_user usr
    where req.created_by =  usr.user_id
    AND usr.person_party_id = p_person_id)
    AND temp.status IN ('CORRECTED', 'NEW', 'IN_VERIFICATION', 'VERIFICATION_FAILED', 'CHANGE_PENDING');

    print_log( g_module_prefix || l_api_name, ' Count for bank account change requests :'||l_cnt);

    IF(l_cnt                              > 0) THEN
      per_drt_pkg.add_to_results (person_id => p_person_id , entity_type => 'TCA' , status => 'E' ,
        msgcode => 'POS_DRT_PENDING_BANK_CHG' , msgaplid => 177 , result_tbl => result_tbl);
    END IF;

   -- Rule#4 PROC-ISP-04: Pending PO Change Requests from this contact exist : TCA Party (Supplier Contact)
   -- Rule#5 PROC-ISP-05: Pending Agreement Change Requests from this contact exist : TCA Party (Supplier Contact)
    print_log( g_module_prefix || l_api_name, '  -- Rule#4 PROC-ISP-04: Pending PO Change Requests from this contact exist : TCA Party (Supplier Contact)');

    select count(*)
    into l_cnt
    from po_change_requests pcr,fnd_user usr
    where pcr.initiator = 'SUPPLIER' and
    pcr.request_status = 'PENDING' and
    pcr.created_by = usr.user_id and
    usr.person_party_id = p_person_id;

    print_log( g_module_prefix || l_api_name, ' Count for response pending change requests :'||l_cnt);

    IF(l_cnt                              > 0) THEN
      per_drt_pkg.add_to_results (person_id => p_person_id , entity_type => 'TCA' , status => 'W' ,
        msgcode => 'POS_DRT_PENDING_PO_CHG' , msgaplid => 177 , result_tbl => result_tbl);
    END IF;

   -- Rule#5 PROC-ISP-05: Pending Agreement Change Requests where person is a contact : TCA Party (Supplier Contact)
    print_log( g_module_prefix || l_api_name, '-- Rule#5 PROC-ISP-05: Pending Agreement Change Requests where person is a contact : TCA Party (Supplier Contact)');

                  select count(*)
                  into l_cnt
                  from po_change_requests pcr,
                  po_headers_all poh,
                  ap_supplier_contacts cont
                  where pcr.initiator = 'SUPPLIER' and
                        pcr.request_status = 'PENDING' and
                        pcr.document_header_id  = poh.po_header_id and
                        poh.type_lookup_code = 'BLANKET' and
                        poh.vendor_contact_id = cont.vendor_contact_id and
                        cont.per_party_id = p_person_id;

    print_log( g_module_prefix || l_api_name, ' Count for  pending Agreement change requests where person is a contact :'||l_cnt);

    IF(l_cnt                              > 0) THEN
      per_drt_pkg.add_to_results (person_id => p_person_id , entity_type => 'TCA' , status => 'W' ,
        msgcode => 'POS_DRT_PENDING_AGRMNT_CHG' , msgaplid => 177 , result_tbl => result_tbl);
    END IF;



    -- Rule#2 PROC-ISP-02: Pending PO Ack from this contact exist : TCA Party (Supplier Contact)
    print_log( g_module_prefix || l_api_name, ' -- Rule#2 PROC-ISP-02: Pending PO Ack from this contact exist : TCA Party (Supplier Contact)');

        select count(*)
        into l_cnt
        from po_headers_all pha
        where
        pha.vendor_contact_id in (select vendor_contact_id
                                  from ap_supplier_contacts
                                  where per_party_id = p_person_id) and
        nvl(pha.cancel_flag,'N') = 'N'
        and nvl(pha.frozen_flag,'N') = 'N'
        and nvl(pha.closed_code,'OPEN') = 'OPEN'
        and nvl(pha.user_hold_flag,'N') = 'N'
        and ( ( pha.authorization_status = 'APPROVED' and
                pha.acceptance_required_flag IN ('Y', 'D'))
            );

    print_log( g_module_prefix || l_api_name, ' Pending PO Acknowledgement count :'||l_cnt);

    IF(l_cnt                              > 0) THEN
      per_drt_pkg.add_to_results (person_id => p_person_id , entity_type => 'TCA' , status => 'W' ,
        msgcode => 'POS_DRT_PENDING_PO_ACK' , msgaplid => 177 , result_tbl => result_tbl);
    END IF;

    -- Rule#3 PROC-ISP-03: Pending PO signature from this contact exist : TCA Party (Supplier Contact)
    print_log( g_module_prefix || l_api_name, '  -- Rule#3 PROC-ISP-03: Pending PO signature from this contact exist : TCA Party (Supplier Contact)');

        select count(*)
        into l_cnt
        from po_headers_all pha
        where
        pha.vendor_contact_id in (select vendor_contact_id
                                  from ap_supplier_contacts
                                  where per_party_id = p_person_id) and
        nvl(pha.cancel_flag,'N') = 'N'
        and nvl(pha.frozen_flag,'N') = 'N'
        and nvl(pha.closed_code,'OPEN') = 'OPEN'
        and nvl(pha.user_hold_flag,'N') = 'N'
        and ( ( pha.authorization_status = 'PRE-APPROVED' and
                pha.pending_signature_flag = 'Y'
                 )
            );

    print_log( g_module_prefix || l_api_name, ' Pending PO Signature count :'||l_cnt);

    IF(l_cnt                              > 0) THEN
      per_drt_pkg.add_to_results (person_id => p_person_id , entity_type => 'TCA' , status => 'W' ,
        msgcode => 'POS_DRT_PENDING_PO_SIGN' , msgaplid => 177 , result_tbl => result_tbl);
    END IF;



    -- Rule#6 PROC-ISP-06: Pending ASN requests from this contact exist : TCA Party (Supplier Contact)
    print_log( g_module_prefix || l_api_name, '  -- Rule#6 PROC-ISP-06: Pending ASN requests from this contact exist : TCA Party (Supplier Contact)');

    select count(*)
    into l_cnt
    from rcv_headers_interface rhi,fnd_user usr
    where rhi.asn_type IN ( 'ASN', 'ASBN') and
    rhi.processing_status_code = 'PENDING' and
    rhi.created_by = usr.user_id and
    usr.person_party_id = p_person_id;

    print_log( g_module_prefix || l_api_name, ' Count for ASN submissions pending processing :'||l_cnt);

    IF(l_cnt                              > 0) THEN
      per_drt_pkg.add_to_results (person_id => p_person_id , entity_type => 'TCA' , status => 'W' ,
        msgcode => 'POS_DRT_PENDING_ASN' , msgaplid => 177 , result_tbl => result_tbl);
    END IF;


    -- Rule#7 PROC-ISP-07: Pending ASN Cancel requests from this contact exist : TCA Party (Supplier Contact)
    print_log( g_module_prefix || l_api_name, ' -- Rule#7 PROC-ISP-07: Pending ASN Cancel requests from this contact exist : TCA Party (Supplier Contact)');

    select count(*)
    into l_cnt
    from rcv_transactions_interface rti,fnd_user usr
    where rti.transaction_type = 'CANCEL' and
    rti.processing_status_code = 'PENDING' and
    rti.created_by = usr.user_id and
    usr.person_party_id = p_person_id;

    print_log( g_module_prefix || l_api_name, ' Count for ASN cancellations pending  :'||l_cnt);

    IF(l_cnt                              > 0) THEN
      per_drt_pkg.add_to_results (person_id => p_person_id , entity_type => 'TCA' , status => 'W' ,
        msgcode => 'POS_DRT_PENDING_ASN_CANCEL' , msgaplid => 177 , result_tbl => result_tbl);
    END IF;

    -- if no warning/errors so far, record success to result_tbl
     IF(result_tbl.count < 1) THEN
       print_log( g_module_prefix || l_api_name, ' Record success to result_tbl');
       per_drt_pkg.add_to_results (person_id => p_person_id , entity_type => 'TCA' , status => 'S' ,
        msgcode => NULL , msgaplid => 177 , result_tbl => result_tbl);
     END IF;
     print_log( g_module_prefix || l_api_name, 'End');

    EXCEPTION
    WHEN OTHERS THEN
       print_log( g_module_prefix || l_api_name,
       'Exception : sqlcode :'|| SQLCODE || ' Error Message : ' || sqlerrm);
       per_drt_pkg.add_to_results (person_id => p_person_id , entity_type => 'TCA' , status => 'E' ,
        msgcode => 'POS_DRT_DRC_UNEXPECTED' , msgaplid => 177 , result_tbl => result_tbl);
    END pos_tca_drc;

-- DRC Procedure for person type : FND
-- Does validation if passed in FND Userid can be masked by validating all
-- rules and passes back the out variable p_process_tbl which contains a
-- table of record of errors/warnings/successs

       PROCEDURE pos_fnd_drc (
        person_id       IN NUMBER,
        result_tbl   OUT NOCOPY per_drt_pkg.result_tbl_type
    ) IS

       l_api_name      VARCHAR2(30) := 'pos_fnd_drc';
        p_person_id NUMBER       := person_id;
    BEGIN

       print_log( g_module_prefix || l_api_name, 'Start');

    -- if no warning/errors so far, record success to process_tbl
     IF(result_tbl.count < 1) THEN
       print_log( g_module_prefix || l_api_name, ' Record success to result_tbl');
       per_drt_pkg.add_to_results (person_id => p_person_id , entity_type => 'FND' , status => 'S' ,
        msgcode => NULL , msgaplid => 177 , result_tbl => result_tbl);
     END IF;
     print_log( g_module_prefix || l_api_name, 'End');

    EXCEPTION
    WHEN OTHERS THEN
       print_log( g_module_prefix || l_api_name,
       'Exception : sqlcode :'|| SQLCODE || ' Error Message : ' || sqlerrm);
       per_drt_pkg.add_to_results (person_id => p_person_id , entity_type => 'FND' , status => 'E' ,
        msgcode => 'POS_DRT_DRC_UNEXPECTED' , msgaplid => 177 , result_tbl => result_tbl);

    END pos_fnd_drc;

END pos_drt_pkg;

/
