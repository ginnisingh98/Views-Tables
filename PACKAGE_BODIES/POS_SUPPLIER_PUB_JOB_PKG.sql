--------------------------------------------------------
--  DDL for Package Body POS_SUPPLIER_PUB_JOB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_SUPPLIER_PUB_JOB_PKG" AS
    /* $Header: POSSPPBJB.pls 120.0.12010000.4 2012/04/03 17:35:35 dalu noship $ */

  PROCEDURE publish_supp_event_job(ERRBUFF			OUT NOCOPY VARCHAR2,
                                   RETCODE			OUT NOCOPY NUMBER,
                                   p_from_date  IN VARCHAR2,
                                   p_to_date    IN VARCHAR2,
                                   p_hours      IN NUMBER ) AS

        partyid_list           pos_tbl_number;
        p_publication_event_id NUMBER;
        p_published_by         NUMBER := fnd_global.user_id;
        p_publish_detail       VARCHAR2(25) := fnd_global.login_id;
        l_from_date            DATE;
        l_to_date              DATE;
        l_event_key            NUMBER := NULL;

    BEGIN

        -- Input Parameters Check
        IF p_hours IS NULL THEN
            IF p_from_date IS NOT NULL THEN
                IF p_to_date IS NOT NULL THEN
                 -- FROM and TO dates are not null
                    l_from_date := to_date(p_from_date,'yyyy/mm/dd hh24:mi:ss');
                    l_to_date   := to_date(p_to_date,'yyyy/mm/dd hh24:mi:ss');
                ELSE
                    -- TO date is null
                    l_from_date := to_date(p_from_date,'yyyy/mm/dd hh24:mi:ss');
                    l_to_date   := SYSDATE;
                END IF;
            ELSE
                -- FROM Date is null
                IF p_to_date IS NOT NULL THEN
                    l_from_date := to_date('01/01/1900 01:00:00','mm/dd/yyyy hh24:mi:ss');
                    l_to_date   := to_date(p_to_date,'yyyy/mm/dd hh24:mi:ss');
                ELSE
                  select actual_completion_date INTO   l_from_date from (
                    select actual_completion_date from fnd_concurrent_requests req,
                    FND_CONCURRENT_PROGRAMS prg where req.concurrent_program_id = prg.concurrent_program_id
                    and prg.concurrent_program_name = 'POSSUPPUBJOB' and actual_completion_date is not null
                    order by actual_completion_date desc) where rownum=1;
                    l_to_date   := SYSDATE;
                    fnd_file.put_line(fnd_file.log,'FROM Date is taken from the Last Run Date of the Concurrent Program');
                END IF;
            END IF;
        ELSE
            -- HOURS parameter is not null
            l_from_date := SYSDATE - p_hours / 24;
            l_to_date   := SYSDATE;
            fnd_file.put_line(fnd_file.log,'HOURS parameter is Not Null: Fetching all the Parties modified within '||p_hours||' hour(s)');
        END IF;

          l_from_date := to_date(to_char(l_from_date,'MM/DD/YYYY HH24:MI:SS'),'MM/DD/YYYY HH24:MI:SS');
          l_to_date   := to_date(to_char(l_to_date,'MM/DD/YYYY HH24:MI:SS'),'MM/DD/YYYY HH24:MI:SS');

          fnd_file.put_line(fnd_file.log,'Parameters passed to the Program are as below:');
          fnd_file.put_line(fnd_file.log,'-----------------------------------------------');
          fnd_file.put_line(fnd_file.log,'FROM DATE:'||to_char(l_from_date,'MM/DD/YYYY HH24:MI:SS'));
          fnd_file.put_line(fnd_file.log,'TO DATE:'||to_char(l_to_date,'MM/DD/YYYY HH24:MI:SS'));

        -- Begin Bug 13833924/12765249
        SELECT party_id
        BULK COLLECT
        INTO   partyid_list
        FROM   (SELECT party_id
                FROM   ap_suppliers
                WHERE  last_update_date BETWEEN l_from_date AND l_to_date
                UNION
                SELECT ap.party_id
                FROM   hz_parties hz,
                       ap_suppliers ap
                WHERE  hz.party_id = ap.party_id
                AND    hz.last_update_date BETWEEN l_from_date AND l_to_date
                UNION
                SELECT ap.party_id
                FROM   ap_supplier_sites_all aps,
                       ap_suppliers          ap
                WHERE  aps.vendor_id = ap.vendor_id
                AND    aps.last_update_date BETWEEN l_from_date AND l_to_date
                UNION
                SELECT ap.party_id
                FROM   hz_locations          hz,
                       ap_suppliers          ap,
                       ap_supplier_sites_all ss
                WHERE  ss.vendor_id = ap.vendor_id
                AND    hz.location_id = ss.location_id
                AND    hz.last_update_date BETWEEN l_from_date AND l_to_date
                UNION
                SELECT ap.party_id
                FROM   pos_bus_class_attr    pbca,
                       ap_suppliers          ap
                WHERE  pbca.vendor_id = ap.vendor_id
                AND    pbca.last_update_date BETWEEN l_from_date AND l_to_date
                UNION
                SELECT ap.party_id
                FROM   iby_pmt_instr_uses_all  instr,
                       iby_external_payees_all payee,
                       ap_suppliers ap
                WHERE  instr.ext_pmt_party_id = payee.ext_payee_id
                AND    payee.payee_party_id = ap.party_id
                AND    instr.last_update_date BETWEEN l_from_date AND l_to_date
                UNION
                SELECT ap.party_id
                FROM   iby_external_payees_all payee,
                       ap_suppliers            ap
                WHERE  payee.payee_party_id = ap.party_id
                AND    payee.last_update_date BETWEEN l_from_date AND l_to_date
                UNION
                SELECT ap.party_id
                FROM   zx_party_tax_profile  tax,
                       ap_suppliers          ap
                WHERE  tax.party_id = ap.party_id
                AND    tax.last_update_date BETWEEN l_from_date AND l_to_date
                UNION
                SELECT ap.party_id
                FROM   ap_supplier_contacts  apsc,
                       ap_suppliers          ap,
                       ap_supplier_sites_all sa
                WHERE  sa.vendor_id = ap.vendor_id
                AND    apsc.vendor_site_id = sa.vendor_site_id
                AND    apsc.last_update_date BETWEEN l_from_date AND l_to_date
                UNION
                SELECT ap.party_id
                FROM   pos_sup_products_services ps,
                       ap_suppliers              ap
                WHERE  ps.vendor_id = ap.vendor_id
                AND    ps.last_update_date BETWEEN l_from_date AND l_to_date

                UNION
                SELECT ap.party_id
                FROM   hz_organization_profiles bapr,
                       hz_organization_profiles brpr,
                       hz_parties               bp,
                       hz_party_sites           s,
                       iby_account_owners       ow,
                       hz_parties               br,
                       ap_suppliers             ap,
                       iby_ext_bank_accounts    eb,
                       hz_code_assignments      branchca,
                       hz_contact_points        branchcp
                WHERE  eb.bank_id = bp.party_id(+)
                AND    eb.bank_id = bapr.party_id(+)
                AND    eb.branch_id = br.party_id(+)
                AND    eb.branch_id = brpr.party_id(+)
                AND    eb.ext_bank_account_id = ow.ext_bank_account_id
                AND    ow.primary_flag(+) = 'Y'
                AND    nvl(ow.end_date, SYSDATE + 10) > SYSDATE
                AND    ow.account_owner_party_id = ap.party_id
                AND    (br.party_id = s.party_id(+))
                AND    (s.identifying_address_flag(+) = 'Y')
                AND    (branchcp.owner_table_name(+) = 'HZ_PARTIES')
                AND    (branchcp.owner_table_id(+) = eb.branch_id)
                AND    (branchcp.contact_point_type(+) = 'EFT')
                AND    (nvl(branchcp.status(+), 'A') = 'A')
                AND    (branchca.class_category(+) =
                      'BANK_INSTITUTION_TYPE')
                AND    (branchca.owner_table_name(+) = 'HZ_PARTIES')
                AND    (branchca.owner_table_id(+) = eb.branch_id)
                AND    eb.last_update_date BETWEEN l_from_date AND l_to_date

                UNION
                SELECT ap.party_id
                FROM   ap_suppliers ap,
                       pos_supp_prof_ext_b ext
                WHERE  ap.party_id = ext.party_id
                AND    ext.last_update_date BETWEEN l_from_date AND l_to_date);

        -- End Bug 13833924/12765249

        if partyid_list.count>0 then

           fnd_file.put_line(fnd_file.log,'Total Number of Published Parties: Count:'||partyid_list.count);
           p_publication_event_id := get_curr_supp_pub_event_id;
           fnd_file.put_line(fnd_file.log,'Publication event Id:'||p_publication_event_id);
           --Calling the Supplier Publish Package
           pos_supp_pub_raise_event_pkg.get_bo_and_insert(partyid_list,
                                                          p_publication_event_id,
                                                          p_published_by,
                                                          p_publish_detail);

         --Calling the workflow section to raise the workflow event
         l_event_key := pos_supp_pub_raise_event_pkg.raise_publish_supplier_event(p_publication_event_id);
       else
         fnd_file.put_line(fnd_file.log,'-------------------------------------------------------------------------------');
         fnd_file.put_line(fnd_file.log,'MESSAGE:** No Party IDs are available to Publish in the given date range **');
         fnd_file.put_line(fnd_file.log,'-------------------------------------------------------------------------------');

        end if;

    EXCEPTION
        WHEN OTHERS THEN
            fnd_file.put_line(fnd_file.log,'EXCEPTION :' || SQLCODE ||'Error Message :'|| SQLERRM);

    END publish_supp_event_job;
----------------------------------------------
    FUNCTION get_curr_supp_pub_event_id RETURN NUMBER IS
    BEGIN
        SELECT pos_supp_pub_event_s.nextval
        INTO   g_curr_supp_publish_event_id
        FROM   dual;

        RETURN g_curr_supp_publish_event_id;

    EXCEPTION
        WHEN OTHERS THEN
            RETURN - 1;
    END;

------------------------------------------------
END pos_supplier_pub_job_pkg;

/
