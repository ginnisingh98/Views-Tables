--------------------------------------------------------
--  DDL for Package Body IGI_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_DRT_PKG" AS
/* $Header: igidrtapi.pkb 120.0.12010000.8 2018/06/25 09:12:45 yanasing noship $ */
  g_debug   CONSTANT VARCHAR2(1)  := NVL(fnd_profile.value('AFLOG_ENABLED'), 'N');
  g_package CONSTANT VARCHAR2(50) := 'po.plsql.igi_drt_pkg.';

-- DRC procedure for person type : TCA
-- Does validation if passed in TCA Party ID can be masked by validating all
-- rules and return 'S' for Success, 'W' for Warning and 'E' for Error
  PROCEDURE debug
  (
    p_module IN VARCHAR2,
    p_messge IN VARCHAR2
  )
  IS
  BEGIN
    IF (g_debug = 'Y' AND fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_statement, g_package || p_module, p_messge);
    END IF;
  END;

  PROCEDURE igi_tca_drc
  (
    person_id IN NUMBER,
    result_tbl OUT nocopy per_drt_pkg.result_tbl_type
  )
  IS
    l_index       NUMBER       := 0; -- for process_tbl index
    l_cnt         NUMBER       := 0;
    l_module_name VARCHAR2(30) := 'igi_tca_drc';
    l_process_tbl per_drt_pkg.result_tbl_type;
    p_person_id NUMBER := person_id;
  BEGIN

    debug(l_module_name, 'Start');

    l_cnt := 0;
    -- Rule#1 : CIS Vendor still active.
    BEGIN
    SELECT 1
      INTO l_cnt
      FROM dual
     WHERE EXISTS (SELECT 1
                     FROM IGI_CIS_VERIFY_LINES_H cl,
                          IGI_CIS_VERIFY_HEADERS_H ch
                    WHERE vendor_id IN(SELECT vendor_id
                                         FROM ap_suppliers
                                        WHERE party_id IN (SELECT party_id
                                                             FROM hz_parties
                                                            WHERE party_id = p_person_id))
                      AND ch.header_id = cl.header_id
                      AND ch.request_status_code <> 'C');
    EXCEPTION
    WHEN OTHERS THEN
        l_cnt := 0;
    END;

    debug(l_module_name, 'IGI_CIS_VERIFY_HEADERS_H Count: '||l_cnt);

    IF l_cnt = 0 THEN
        debug(l_module_name, 'Inside IGI_CIS_VERIFY_HEADERS_T counts');
        BEGIN
        SELECT 1
          INTO l_cnt
          FROM DUAL
         WHERE EXISTS (SELECT 1
                         FROM IGI_CIS_VERIFY_LINES_T cl,IGI_CIS_VERIFY_HEADERS_T ch
                        WHERE vendor_id IN (SELECT vendor_id
                                              FROM AP_SUPPLIERS
                                             WHERE PARTY_ID IN (SELECT PARTY_ID
                                                                  FROM HZ_PARTIES
                                                                 WHERE PARTY_ID=P_PERSON_ID))
                          AND CH.HEADER_ID=CL.HEADER_ID
                          AND EXISTS (SELECT 1
                                        FROM IGI_CIS_VERIFY_HEADERS_H VH
                                       WHERE VH.HEADER_ID=CL.HEADER_ID
                                         AND VH.REQUEST_STATUS_CODE <> 'C'));
        EXCEPTION
        WHEN OTHERS THEN
            l_cnt:=0;
        END;
        debug(l_module_name, 'IGI_CIS_VERIFY_HEADERS_T Count: '||l_cnt);
    END IF;
    -- Log Error/Warning to l_process_tbl
    IF(l_cnt > 0) THEN
      debug(l_module_name, 'Active supplier exists in CIS Subcontractor Verification Process');
      l_index                             := l_index+1;
      l_process_tbl(l_index).person_id    := p_person_id;
      l_process_tbl(l_index).entity_type  := 'TCA';
      l_process_tbl(l_index).status       := 'E';
      l_process_tbl(l_index).msgcode      := 'IGI_DRT_ACTIVE_SUPPLIER_EXISTS';
      --l_process_tbl(l_index).msgtext      := fnd_message.get_string('IGI','IGI_DRT_ACTIVE_SUPPLIER_EXISTS');
      l_process_tbl(l_index).msgaplid     := 8400;
    END IF;

    l_cnt := 0;
    -- Rule#2 : Open CIS Transctions still exist.
    debug(l_module_name, 'CIS Transactions Check');
    BEGIN
    SELECT 1
      INTO l_cnt
      FROM dual
     WHERE EXISTS (SELECT 1
                     --from dual);
                     FROM IGI_CIS_MTH_RET_LINES_H_ALL cl,
                          IGI_CIS_MTH_RET_HDR_H_ALL ch
                    where cl.vendor_id in (select vendor_id
                                             from ap_suppliers
                                            where party_id in (select party_id
                                                                 from hz_parties
                                                                where party_id=p_person_id))
                      and ch.header_id=cl.header_id
                      --and ch.request_status_code = 'C'
                      and NVL(ch.status,'WORKING')='WORKING');
    EXCEPTION
    WHEN OTHERS THEN
        l_cnt:=0;
    END;
    debug(l_module_name, 'CIS Open transactions count in IGI_CIS_MTH_RET_HDR_H_ALL table '|| l_cnt);
    IF l_cnt = 0 THEN
        debug(l_module_name, 'Inside CIS T Tables count check');
        BEGIN
        SELECT 1
          INTO l_cnt
          FROM DUAL
         WHERE EXISTS(SELECT 1
                        FROM IGI_CIS_MTH_RET_LINES_T_ALL cl,
                             IGI_CIS_MTH_RET_HDR_T_ALL ch
                       WHERE cl.vendor_id IN (SELECT vendor_id
                                                FROM ap_suppliers
                                               WHERE party_id IN (SELECT party_id
                                                                    FROM hz_parties
                                                                   WHERE party_id=p_person_id))
                         AND ch.header_id=cl.header_id
                         AND EXISTS (SELECT 1
                                       FROM IGI_CIS_MTH_RET_HDR_H_ALL vh
                                      WHERE vh.header_id=cl.header_id
                                        --AND vh.request_status_code = 'C'
                                        AND NVL(vh.status,'WORKING')='WORKING') );
                         --AND ch.request_status_code = 'C');
        EXCEPTION
        WHEN OTHERS THEN
            l_cnt:=0;
        END;
        debug(l_module_name, 'CIS Open transactions count in IGI_CIS_MTH_RET_HDR_T_ALL table '|| l_cnt);
        /*IF l_cnt = 0 THEN
            debug(l_module_name, 'Inside CIS PAY_H table check');
            BEGIN
            SELECT 1
              INTO l_cnt
              FROM DUAL
             WHERE EXISTS(SELECT 1
                            FROM IGI_CIS_MTH_RET_PAY_H_ALL
                           WHERE vendor_id IN (SELECT vendor_id
                                                 FROM ap_suppliers
                                                WHERE party_id IN (SELECT party_id
                                                                     FROM hz_parties
                                                                    WHERE party_id = p_person_id))
               AND NVL(status,'WORKING')='WORKING');
            EXCEPTION
            WHEN OTHERS THEN
                l_cnt:=0;
            END;
            debug(l_module_name, 'CIS Open transactions count in IGI_CIS_MTH_RET_PAY_H_ALL table '|| l_cnt);*/
            IF l_cnt = 0 THEN
                debug(l_module_name, 'Inside CIS PAY_T table check');
                BEGIN
                    SELECT 1
                      INTO l_cnt
                      FROM DUAL
                     WHERE EXISTS(SELECT 1
                                    FROM IGI_CIS_MTH_RET_PAY_T_ALL
                                   WHERE vendor_id IN (SELECT vendor_id
                                                         FROM ap_suppliers
                                                        WHERE party_id IN (SELECT party_id
                                                                             FROM hz_parties
                                                                            WHERE party_id = p_person_id)));
                EXCEPTION
                WHEN OTHERS THEN
                    l_cnt:=0;
                END;
                debug(l_module_name, 'CIS Open transactions count in IGI_CIS_MTH_RET_PAY_T_ALL table '|| l_cnt);
                IF l_cnt=0 THEN
                    debug(l_module_name, 'Inside CIS version table check');
                    BEGIN
                        SELECT 1
                          INTO l_cnt
                          FROM DUAL
                         WHERE EXISTS ( SELECT 1
                                          FROM IGI_CIS_MTH_RET_PAY_VER
                                         WHERE vendor_id IN (SELECT vendor_id
                                                               FROM ap_suppliers
                                                              WHERE party_id IN (SELECT party_id
                                                                                   FROM hz_parties
                                                                                  WHERE party_id = p_person_id)));
                    EXCEPTION
                    WHEN OTHERS THEN
                        l_cnt:=0;
                    END;
                    debug(l_module_name, 'CIS Open transactions count in IGI_CIS_MTH_RET_PAY_VER table '|| l_cnt);

                    debug(l_module_name, 'Checking any invoice payments exist for the current period which needs to be submitted for CIS');
                    IF l_cnt=0 THEN
                        debug(l_module_name, 'inside invoice payments check');
                        BEGIN
                            SELECT 1
                              INTO l_cnt
                              FROM ap_invoice_payments_all ap,
                                   (SELECT aop.period_name, aop.start_date, aop.end_date
                                      FROM AP_OTHER_PERIODS aop
                                     WHERE aop.period_type = NVL(fnd_profile.VALUE('IGI_CIS2007_CALENDAR'),'Monthly')
                                       AND SYSDATE BETWEEN aop.start_date AND aop.end_date
                                  ORDER BY aop.period_year DESC, aop.period_num DESC) pd
                             WHERE ap.invoice_id IN (SELECT invoice_id
                                                       FROM ap_invoices_all
                                                      WHERE vendor_id IN (SELECT vendor_id
                                                                            FROM ap_suppliers
                                                                           WHERE party_id IN (SELECT party_id
                                                                                                FROM hz_parties
                                                                                               WHERE party_id = p_person_id)
                                                                             AND cis_enabled_flag = 'Y'
                                                                             AND vendor_type_lookup_code IN ('PARTNERSHIP','SOLETRADER','COMPANY','TRUST')
                                                                             AND SYSDATE BETWEEN NVL(START_DATE_ACTIVE,SYSDATE) AND NVL(END_DATE_ACTIVE,SYSDATE)))
                               AND accounting_date BETWEEN pd.start_date AND pd.end_date;
                        EXCEPTION
                        WHEN OTHERS THEN
                            l_cnt:=0;
                        END;
                    END IF;
                END IF;
            END IF;
       -- END IF;
    END IF;
    -- Log Error/Warning to l_process_tbl
    IF(l_cnt > 0) THEN
      debug(l_module_name, 'Open Transactions exists in CIS monthly returns. hence cant delete data');
      l_index                             := l_index+1;
      l_process_tbl(l_index).person_id    := p_person_id;
      l_process_tbl(l_index).entity_type  := 'TCA';
      l_process_tbl(l_index).status       := 'E';
      l_process_tbl(l_index).msgcode      := 'IGI_DRT_ACTIVE_CIS_TXN_EXISTS';
      --l_process_tbl(l_index).msgtext      := fnd_message.get_string('IGI','IGI_DRT_ACTIVE_CIS_TXN_EXISTS');
      l_process_tbl(l_index).msgaplid     := 8400;
    END IF;


    l_cnt := 0;
    -- Rule#4 : Active Standing Charges still exist.
    debug(l_module_name, 'checking igi_rpi_standing_charges_all count');
    BEGIN
	/*   added for bug 28206910 */
		select count(*) into l_cnt
		from igi_rpi_standing_charges_all rsc where upper(nvl(status,'INCOMPLETE'))='ACTIVE'
		and EXISTS (SELECT 1
		FROM hz_cust_accounts,
		hz_parties
		WHERE hz_cust_accounts.party_id = hz_parties.party_id
		AND nvl(hz_cust_accounts.status,   'A') = 'A'
		and hz_parties.party_id =p_person_id
		AND hz_cust_accounts.cust_account_id = nvl(rsc.BILL_TO_CUSTOMER_ID,-1) );

/*   for bug 28206910
 SELECT 1
      INTO l_cnt
      FROM dual
     WHERE EXISTS (SELECT 1
                     FROM IGI_RA_ADDRESSES_ALL
                    WHERE address_id IN(SELECT hcas.cust_acct_site_id
                                          FROM hz_cust_accounts_all hca,
                                               hz_cust_acct_sites_all hcas
                                         WHERE hca.cust_account_id = hcas.cust_account_id
                                           AND hca.party_id = p_person_id));*/
    EXCEPTION
    WHEN OTHERS THEN
        l_cnt:=0;
    END;
    debug(l_module_name, 'igi_rpi_standing_charges_all table count :'||l_cnt);
    -- Log Error/Warning to l_process_tbl
    IF(l_cnt > 0) THEN
      debug(l_module_name, 'Open transactions exists in Standing Charges');
      l_index                             := l_index+1;
      l_process_tbl(l_index).person_id    := p_person_id;
      l_process_tbl(l_index).entity_type  := 'TCA';
      l_process_tbl(l_index).status       := 'E';
      l_process_tbl(l_index).msgcode      := 'IGI_DRT_ACTIVE_SC_EXISTS';
      --l_process_tbl(l_index).msgtext      := fnd_message.get_string('IGI','IGI_DRT_ACTIVE_SC_EXISTS');
      l_process_tbl(l_index).msgaplid     := 8400;
    END IF;

    result_tbl := l_process_tbl;
    debug(l_module_name, 'End');
  END igi_tca_drc;

END igi_drt_pkg;

/
