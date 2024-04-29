--------------------------------------------------------
--  DDL for Package Body XXAH_SUPP_MASS_UPDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXAH_SUPP_MASS_UPDATE_PKG" as
   /***************************************************************************
   *                           IDENTIFICATION
   *                           ==============
   * NAME              : XXAH_SUPP_MASS_UPDATE_PKG
   * DESCRIPTION       : PACKAGE TO Supplier Update Conversion
   ****************************************************************************
   *                           CHANGE HISTORY
   *                           ==============
   * DATE             VERSION     DONE BY
   * 17-Jan-2017        1.0       Sunil Thamke     Initial
   ****************************************************************************/
gv_request_id                     fnd_concurrent_requests.request_id%TYPE:= Fnd_Global.conc_request_id;
gv_commit_flag                    VARCHAR2(1);
gv_api_msg                        VARCHAR2(2000);


PROCEDURE P_MAIN (errbuf  OUT VARCHAR2,
                  retcode OUT NUMBER)
IS

   lv_bank_id                      NUMBER;
   lv_branch_id                    NUMBER;
      lv_account_id                   NUMBER;

CURSOR c_supp_rec
IS
select rowid, a.* from xxah_ps_ebs_supp_bank_update a
where conversion_status = 'V'
  and request_id = gv_request_id;

BEGIN
    fnd_global.Apps_initialize (user_id => fnd_global.user_id,
                                resp_id => fnd_global.resp_id,
                                resp_appl_id => fnd_global.resp_appl_id);
FND_FILE.PUT_LINE(FND_FILE.LOG,'Executing Validation');
            P_VENDOR_VALIDATE;
            FND_FILE.PUT_LINE(FND_FILE.LOG,'Validation complete');
    FOR i IN c_supp_rec
        LOOP
        gv_api_msg := NULL;
        gv_commit_flag    := NULL;
        lv_branch_id      := NULL;
            P_UPDATE_SUPPLIER(i.OLD_SUPPLIER_NAME,
                            i.NEW_SUPPLIER_NAME,
                            i.ora_party_id,
                            i.vat_registration_num,
                            i.DUNS_NUMBER) ;
            IF gv_commit_flag = 'Y' THEN
                P_UPDATE_VENDOR (i.rowid, i.ora_vendor_id,
                                            i.PO_MATCH, i.SIC_CODE,
                                            i.supp_currency_code,
                                            i.ora_pay_group_code,
                                            i.ora_term_id,
                                            trunc(i.SUPPLIER_INACTIVATION_DATE));
            END IF;

            IF gv_commit_flag = 'Y' THEN
            P_UPDATE_SUPPLIER_SITE(i.ORA_VENDOR_SITE_ID,
                            i.SUPPLIER_SITE_NAME_NEW ,
                            upper(i.SITE_CURRENCY_CODE) ,
                            i.ORA_SS_PAY_GROUP_CODE ,
                            i.RETAINAGE_RATE,
                            i.SITE_INACTIVATION_DATE,
                            i.PURCHASING_FLAG,
                            i.PAY_SITE_FLAG,
                            i.PRIMARY_PAY_SITE_FLAG,
                            i.PRIMARY_EMAIL_ADDRESS,
                            i.PRIMARY_CONTACT_NAME_GIVEN,
                            i.PRIMARY_CONTACT_NAME_FAMILY,
                            i.PRIMARY_CONTACT_EMAIL,
                            i.PRIMARY_CONTACT_PHONE_WORK,
                            i.PRIMARY_CONTACT_PH_WORK_AREA,
                            i.PRIMARY_CONTACT_PHONE_MOBILE,
                            i.PRIMARY_CONTACT_PHONE_FAX,
                            i.PRIMARY_WORK_COUNTRY_CODE,
                            i.PEOPLESOFT_INTERCOMPANY,
                            i.ora_inv_term_id);
            END IF;
            --
            --
                IF gv_commit_flag = 'Y' AND (i.VAT_REGISTRATION_NUM IS NOT NULL OR  i.TAX_CLASSIFICATION_CODE IS NOT NULL) THEN
            P_TAX_CLASSIFICATION(i.ora_party_id,
                    i.VAT_REGISTRATION_NUM,
                    i.TAX_CLASSIFICATION_CODE);
                    END IF;
            --
            --
            IF gv_commit_flag = 'Y' THEN
            IF (i.ADDRESS_LINE1 IS NOT NULL) THEN
                    P_UPDATE_ADDRESS(i.ora_location_id,
                        i.ADDRESS_LINE1,
                        i.ADDRESS_LINE2,
                        i.ADDRESS_LINE3,
                        i.ADDRESS_LINE4,
                        i.CITY,
                        i.ZIP_CODE,
                        i.STATE,
                        i.COUNTY,
                        i.COUNTRY,
                        i.PROVINCE);
            END IF;
            END IF;
            --

--
IF i.ADDRESS_STATUS IS NOT NULL AND gv_commit_flag = 'Y'THEN
ADDRESS_STATUS(i.ORA_PARTY_SITE_ID, i.ADDRESS_STATUS);
END IF;
--
            --
            IF i.INVOICE_EMAIL IS NOT NULL AND gv_commit_flag <> 'N'
               THEN
                        --<Create EMAIL on Contact Point>--
                  P_CREATE_EMAIL_CONTACT_POINT (i.ORA_PARTY_SITE_ID,
                                          i.INVOICE_EMAIL
                                         );
            END IF;
            --
             FND_FILE.PUT_LINE(FND_FILE.LOG,'**013');

            --
            IF (i.CONTENT_GROUP IS NOT NULL OR i.leaf_commodity IS NOT NULL) AND gv_commit_flag <> 'N'  THEN
            BEGIN
               p_uda (       i.ORA_PARTY_ID,
                      'XXAH_COUPA_CONTENT',
                      'Coupa Content Group',
                      i.CONTENT_GROUP,
                      i.leaf_commodity,
                      'SUPP_ADDR_SITE_LEVEL',
                      i.ora_party_site_id,
                      i.ora_vendor_site_id
                     );
            END;
            END IF;


            --
            --
            IF i.PEOPLESOFT_INTERCOMPANY IS NOT NULL AND gv_commit_flag = 'Y' THEN
               BEGIN
                  FND_FILE.PUT_LINE(FND_FILE.LOG,'--<Updating PeopleSoft Intercompany Number>--');
               p_uda (i.ora_party_id,
                      'XXAH_PSFT_Intercompany',
                      'PeopleSoft Intercompany Number',
                      i.PEOPLESOFT_INTERCOMPANY,
                      NULL,
                      'SUPP_LEVEL',
                      NULL,
                      NULL
                     );
                END;
            END IF;
            --

--
            --<Registration Number>--
            IF i.STD_ID_QUAL_SUPP IS NOT NULL AND gv_commit_flag = 'Y' THEN

            BEGIN
               p_uda (i.ora_party_id,
                      'XXAH_STD_QUAL_SUPP',
                      'Registration Type',
                      i.STD_ID_QUAL_SUPP,
                      i.STD_ID_NUM_SUPP,
                      'SUPP_LEVEL',
                      i.ORA_PARTY_SITE_ID,
                      i.ORA_VENDOR_SITE_ID
                     );
            END;
            END IF;
--

--
            --<Registration Number site>--
            IF i.STD_ID_QUAL_SITE IS NOT NULL AND gv_commit_flag = 'Y' THEN

            BEGIN
               p_uda (i.ora_party_id,
                      'XXAH_STD_QUAL_SITE',
                      'Registration Type Site',
                      i.STD_ID_QUAL_SITE,
                      i.STD_ID_NUM_SITE,
                      'SUPP_ADDR_SITE_LEVEL',
                      i.ORA_PARTY_SITE_ID,
                      i.ORA_VENDOR_SITE_ID
                     );
            END;
            END IF;
--

--
    --<Remit To Supplier site>--
        IF i.remit_supplier_name IS NOT NULL AND gv_commit_flag = 'Y' THEN
             p_uda (i.ora_party_id,
                              'XXAH_REMIT_TO_SUPP',
                              'Remit To Supplier',
                               i.remit_supplier_name,
                               i.remit_supplier_site,
                              --l_vendor_name,
                              --l_vendor_site_name,
                              'SUPP_ADDR_SITE_LEVEL',
                                i.ORA_PARTY_SITE_ID,
                              i.ORA_VENDOR_SITE_ID
                             );
        END IF;
--

            --
                lv_bank_id := NULL;
            IF i.bank_name is not null and i.bank_number is not null AND i.BANK_ACCOUNT_NUM_INACTIVATION IS NULL AND gv_commit_flag = 'Y' THEN
              -----------------------<Create Bank>--------------------------------
              p_create_bank (i.bank_name,
                             i.bank_name,
                             i.bank_number,
                             i.ISO_TERRITORY_CODE,
                             NULL,
                             lv_bank_id
                            );
             END IF;

            -----------------------<Create Branch>--------------------------------
            --
            IF lv_bank_id IS NOT NULL and i.bank_branch_name IS NOT NULL AND i.BANK_ACCOUNT_NUM_INACTIVATION IS NULL AND gv_commit_flag = 'Y'THEN
                p_create_branch (lv_bank_id,
                          i.bank_branch_name,
                          NULL,
                          i.eft_swift_code,
                          lv_branch_id);
            END IF;
            --

            -----------------------<Create account>--------------------------------
            --
            IF lv_branch_id IS NOT NULL AND i.bank_account_number IS NOT NULL
            AND i.BANK_ACCOUNT_NUM_INACTIVATION IS NULL
AND gv_commit_flag = 'Y'
            THEN
                p_create_bank_acct (lv_bank_id,
                                    lv_branch_id,
                                    i.ORA_PARTY_ID,
                                    i.bank_account_name,
                                    i.bank_account_number,
                                    i.ISO_TERRITORY_CODE,
                                    i.ORA_VENDOR_SITE_ID,
                                    i.ORA_PARTY_SITE_ID,
                                    lv_account_id,
                                    i.iban,
                                    i.check_digits,
                                    i.operating_unit_id,
                                    i.bank_priority
                                   );
            END IF;
            --

            IF i.BANK_ACCOUNT_NUM_INACTIVATION IS NOT NULL AND gv_commit_flag = 'Y' THEN
                        FND_FILE.PUT_LINE(FND_FILE.LOG,'Bank Inactive');
                P_END_EXT_BANK_ACCOUNTS(i.EXTERNAL_BANK_ACCOUNT_ID, i.ORA_PARTY_ID, i.BANK_ACCOUNT_NUM_INACTIVATION,
                i.ORA_VENDOR_SITE_ID,
                i.ORA_PARTY_SITE_ID
                );
                        FND_FILE.PUT_LINE(FND_FILE.LOG,'Bank END Inactive');
            END IF;


            --
            fnd_file.put_line(fnd_file.LOG,'gv_commit_flag '||gv_commit_flag);
            IF gv_commit_flag <> 'N' THEN
            update xxah_ps_ebs_supp_bank_update
                set conversion_status='P'
                where
                rowid = i.rowid;
                commit;

                ELSE
                ROLLBACK;
                NULL;
                          p_write_log(i.rowid, gv_api_msg);

            END IF;


        END LOOP;
     p_report;

END P_MAIN;

PROCEDURE P_VENDOR_VALIDATE
IS
l_vendor_id                     ap_suppliers.vendor_id%TYPE;
l_party_id                    hz_parties.party_id%TYPE;
l_object_version_number        hz_parties.object_version_number%TYPE;
l_vendor_name                ap_suppliers.vendor_name%TYPE;
l_vendor_site_id            ap_supplier_sites_all.vendor_site_id%TYPE;
l_location_id                ap_supplier_sites_all.location_id%TYPE;
l_party_site_id                ap_supplier_sites_all.party_site_id%TYPE;
l_error_flag                varchar2(1);
l_error_log                    varchar2(240);
l_territory_code            fnd_territories.TERRITORY_CODE%TYPE;
l_iso_territory_code         fnd_territories.TERRITORY_CODE%TYPE;
l_email    varchar2(240);
l_xxah_supplier_type_att        POS_XXAH_SUPPLIER_TY_AGV.XXAH_SUPPLIER_TYPE_ATT%TYPE;
l_leaf_commodity                xxah_ps_ebs_supp_bank_update.leaf_commodity%TYPE;
l_content_group                    xxah_ps_ebs_supp_bank_update.content_group%TYPE;
l_count    NUMBER;
l_terms_id                        ap_terms.term_id%TYPE;
l_sp_terms_id            ap_terms.term_id%TYPE;
l_new_vendor_name               ap_suppliers.vendor_name%TYPE;
l_pay_group_code                ap_suppliers.pay_group_lookup_code%TYPE;
l_ss_pay_group_code                ap_supplier_sites_all.pay_group_lookup_code%TYPE;
x_valid            BOOLEAN;
l_tax_class_code        ZX_PARTY_TAX_PROFILE.TAX_CLASSIFICATION_CODE%TYPE;

CURSOR c_get_supplier_id IS
select rowid, a.* from xxah_ps_ebs_supp_bank_update a
          where nvl(a.conversion_status,'N') = 'N'
          and a.supplier_type='NFR'
          ORDER BY OLD_SUPPLIER_NAME;

    BEGIN
        FOR r_get_supplier_id IN c_get_supplier_id
            LOOP
                l_vendor_id                 := NULL;
                l_vendor_name                 := NULL;
                l_object_version_number        := NULL;
                l_party_id                    := NULL;
                l_vendor_site_id            := NULL;
                l_location_id               := NULL;
                l_error_log                    := NULL;
                l_error_flag                 := NULL;
                l_party_site_id                := NULL;
                l_territory_code            := NULL;
                l_iso_territory_code        := NULL;
                l_email                        := NULL;
                l_xxah_supplier_type_att    := NULL;
                l_leaf_commodity            := NULL;
                l_content_group                := NULL;
                l_count                        := NULL;
                l_terms_id             := NULL;
                l_sp_terms_id            := NULL;
                l_new_vendor_name    := NULL;
                l_pay_group_code            := NULL;
                l_ss_pay_group_code            := NULL;
                l_tax_class_code        := NULL;

            BEGIN
                FND_FILE.PUT_LINE(FND_FILE.LOG,'Validating Supplier > '|| r_get_supplier_id.old_supplier_name );
                FND_FILE.PUT_LINE(FND_FILE.LOG,'Validating Site > '|| r_get_supplier_id.SUPPLIER_SITE_NAME );
                --
                BEGIN
                        --<Check supplier exists or not>-
                        SELECT aps.vendor_id,
                               aps.vendor_name,
                               hzp.party_id
                        INTO   l_vendor_id, l_vendor_name, l_party_id
                        FROM   ap_suppliers aps,
                               hz_parties hzp,
                               pos_xxah_supplier_ty_agv xxah
                        WHERE  aps.party_id = hzp.party_id
                               AND aps.party_id = xxah.party_id
                               AND xxah.xxah_supplier_type_att = 'NFR'
                               AND Upper(aps.vendor_name) = Upper(r_get_supplier_id.old_supplier_name);
                FND_FILE.PUT_LINE(FND_FILE.LOG,'vendor_name - '||l_vendor_name||' vendor_id - '|| l_vendor_id||' party_id - '|| l_party_id);


                    IF l_vendor_id is not null then
                    l_error_flag := 'N';
                    END IF;

                    EXCEPTION
                        WHEN OTHERS THEN
                        --
                        BEGIN
                            --<Check non NFR supplier exists or not>-
                                SELECT aps.vendor_id,
                                       xxah.xxah_supplier_type_att
                                INTO   l_vendor_id, l_xxah_supplier_type_att
                                FROM   ap_suppliers aps,
                                       hz_parties hzp,
                                       pos_xxah_supplier_ty_agv xxah
                                WHERE  aps.party_id = hzp.party_id
                                       AND aps.party_id = xxah.party_id
                                       AND Upper(aps.vendor_name) = Upper(r_get_supplier_id.old_supplier_name);

                                IF l_vendor_id IS NOT NULL THEN
                                        l_error_flag := 'Y';
                                        l_error_log := l_error_log||'//P_VENDOR_VALIDATE Supplier Type is not NFR!!! And Type is '||l_xxah_supplier_type_att;
                                    ELSE
                                        l_error_flag := 'Y';
                                        l_error_log := l_error_log||'//P_VENDOR_VALIDATE Supplier Not Found !!! ';
                                END IF;
                            EXCEPTION
                            WHEN OTHERS THEN
                            l_error_flag := 'Y';
                            l_error_log := l_error_log||'//Supplier Not Found';
                            NULL;
                        END;
                        --
                    NULL;
                    END;
                    --

                    --
                                --<Check New supplier exists or not>-
BEGIN
                        SELECT aps.vendor_name
                        INTO   l_new_vendor_name
                        FROM   ap_suppliers aps,
                               hz_parties hzp,
                               pos_xxah_supplier_ty_agv xxah
                        WHERE  aps.party_id = hzp.party_id
                               AND aps.party_id = xxah.party_id
                               AND xxah.xxah_supplier_type_att = 'NFR'
                               AND Upper(aps.vendor_name) = Upper(r_get_supplier_id.NEW_SUPPLIER_NAME);
IF l_new_vendor_name IS NOT NULL THEN
           l_error_flag := 'Y';
           l_error_log := l_error_log||'//P_VENDOR_VALIDATE new supplier site already exists';
END IF;
                    EXCEPTION
                        WHEN OTHERS THEN
                        NULL;
END;
                    --

--
        IF l_vendor_id IS NOT NULL THEN
                --Get Supplier Site ID
                --
                IF r_get_supplier_id.SUPPLIER_SITE_NAME is NOT NULL THEN
                BEGIN

                FND_FILE.PUT_LINE(FND_FILE.LOG,'l_vendor_id '||l_vendor_id);

                    select apss.vendor_site_id, apss.party_site_id, apss.location_id
                    into l_vendor_site_id, l_party_site_id, l_location_id
                        from ap_suppliers aps, AP_SUPPLIER_SITES_ALL  apss
                        where aps.vendor_id = apss.vendor_id
                    AND aps.vendor_id = l_vendor_id
                    and (INACTIVE_DATE is  null OR INACTIVE_DATE > sysdate)
                    and apss.org_id=83
                    AND upper(apss.vendor_site_code) = upper(r_get_supplier_id.SUPPLIER_SITE_NAME);
                    EXCEPTION
                        WHEN OTHERS THEN
                        l_error_flag := 'Y';
                        l_error_log := l_error_log||'//P_VENDOR_VALIDATE supplier site not fount';
                        NULL;
                    END;
                END IF;
                --

                --
                IF r_get_supplier_id.COUNTRY IS NOT NULL THEN
                BEGIN
                    SELECT territory_code
                    INTO   l_territory_code
                    FROM   fnd_territories
                    WHERE  territory_code = r_get_supplier_id.country
                           AND obsolete_flag = 'N';

                IF l_territory_code IS NULL THEN
                        l_error_flag := 'Y';
                        l_error_log := l_error_log||'//P_VENDOR_VALIDATE Invalid Country';
                END IF;
                  EXCEPTION
                        WHEN OTHERS THEN
                        l_error_flag := 'Y';
                        l_error_log := l_error_log||'//P_VENDOR_VALIDATE Invalid Country - not found ';
                        NULL;
                END;
                END IF;
                --

                         --
                IF r_get_supplier_id.ISO_TERRITORY_CODE IS NOT NULL THEN
                BEGIN
                    SELECT territory_code
                    INTO   l_iso_territory_code
                    FROM   fnd_territories
                    WHERE  territory_code = r_get_supplier_id.ISO_TERRITORY_CODE
                           AND obsolete_flag = 'N';

                IF l_iso_territory_code IS NULL THEN
                        l_error_flag := 'Y';
                        l_error_log := l_error_log||'//Invalid ISO_TERRITORY_CODE';
                END IF;
                  EXCEPTION
                        WHEN OTHERS THEN
                        l_error_flag := 'Y';
                        l_error_log := l_error_log||'//Invalid ISO_TERRITORY_CODE';
                        NULL;
                END;
                END IF;
                --

                --
                IF r_get_supplier_id.PO_MATCH IS NOT NULL THEN
                    IF r_get_supplier_id.PO_MATCH not in ('2-way match','3-way match','4-way match') THEN
                        l_error_flag := 'Y';
                        l_error_log := l_error_log||'//P_VENDOR_VALIDATE Invalid PO_MATCH';
                    END IF;
                END IF;
                --
    --
    IF r_get_supplier_id.leaf_commodity IS NOT NULL THEN
        BEGIN
            SELECT flex_value
            INTO   l_leaf_commodity
            FROM   fnd_flex_values_vl ffv,
                   fnd_flex_value_sets ffvs
            WHERE  ffvs.flex_value_set_id = ffv.flex_value_set_id
                   AND flex_value_set_name = 'XXAH_LEAF_COMMODITY'
                   AND flex_value = r_get_supplier_id.leaf_commodity
                   AND ffv.enabled_flag = 'Y'
                   AND Trunc(SYSDATE) BETWEEN Nvl(start_date_active, Trunc(SYSDATE)) AND
                                                  Nvl(end_date_active, To_date('31-DEC-4721'
                                                                       ,
                                                                       'DD-MON-YYYY'));

            IF l_leaf_commodity IS NULL THEN
                l_error_flag := 'Y';
                l_error_log := l_error_log||'//P_VENDOR_VALIDATE Invalid XXAH_LEAF_COMM: ';
            END IF;
            EXCEPTION
            WHEN OTHERS THEN
                l_error_flag := 'Y';
                l_error_log := l_error_log||'//P_VENDOR_VALIDATE Invalid XXAH_LEAF_COMM: ';
        END;
    END IF;
    --

    --
    IF r_get_supplier_id.CONTENT_GROUP IS NOT NULL THEN
        BEGIN
            SELECT flex_value
            INTO   l_content_group
            FROM   fnd_flex_values_vl ffv,
                   fnd_flex_value_sets ffvs
            WHERE  ffvs.flex_value_set_id = ffv.flex_value_set_id
                   AND flex_value_set_name = 'XXAH_COUPA_CONTENT_GROUP'
                   AND flex_value = r_get_supplier_id.content_group
                   AND ffv.enabled_flag = 'Y'
                   AND Trunc(SYSDATE) BETWEEN Nvl(start_date_active, Trunc(SYSDATE)) AND
                                                  Nvl(end_date_active, To_date('31-DEC-4721'
                                                                       ,
                                                                       'DD-MON-YYYY'));
            IF l_content_group IS NULL THEN
                                    l_error_flag := 'Y';
                            l_error_log := l_error_log||'//P_VENDOR_VALIDATE Invalid CONTENT_GROUP';
            END IF;
            EXCEPTION
            WHEN OTHERS THEN
            l_error_flag := 'Y';
            l_error_log := l_error_log||'//P_VENDOR_VALIDATE Invalid CONTENT_GROUP';
        END;
    END IF;
    --
     --
 -- Check terms_name present or not.
 --
If r_get_supplier_id.supp_payment_term IS NOT NULL THEN
    BEGIN
    SELECT term_id
        INTO   l_terms_id
        FROM   AP_TERMS_TL
        WHERE     Upper(name) = Upper(r_get_supplier_id.supp_payment_term)
        AND    language = userenv('LANG')
        AND    sysdate < nvl(end_date_active, sysdate+1);

    EXCEPTION
           WHEN OTHERS THEN
            l_error_flag := 'Y';
            l_error_log := l_error_log||'//Invalid Supplier Payment terms '||r_get_supplier_id.supp_payment_term;
     END;
END IF;
--

If r_get_supplier_id.SITE_PAYMENT_TERM IS NOT NULL THEN
    BEGIN
    SELECT term_id
        INTO   l_sp_terms_id
        FROM   AP_TERMS_TL
        WHERE     Upper(name) = Upper(r_get_supplier_id.SITE_PAYMENT_TERM)
        AND    language = userenv('LANG')
        AND    sysdate < nvl(end_date_active, sysdate+1);

    EXCEPTION
           WHEN OTHERS THEN
            l_error_flag := 'Y';
            l_error_log := l_error_log||'//Invalid SITE_PAYMENT_TERM terms '||r_get_supplier_id.SITE_PAYMENT_TERM;
     END;
END IF;



--<Supplier Pay Group>--
IF r_get_supplier_id.SUPP_PAYMENT_GROUP_CODE IS NOT NULL THEN
BEGIN
SELECT lookup_code
into l_pay_group_code
                FROM po_lookup_codes
                WHERE lookup_type = 'PAY GROUP'
                AND upper(DISPLAYED_FIELD) = upper(r_get_supplier_id.SUPP_PAYMENT_GROUP_CODE)
                AND enabled_flag = 'Y'
                AND nvl(inactive_date,sysdate+1) > sysdate;
    EXCEPTION
           WHEN OTHERS THEN
            l_error_flag := 'Y';
            l_error_log := l_error_log||'//P_VENDOR_VALIDATE Invalid PAY GROUP';

END;
END IF;
--

--<Supplier Site Pay Group>--
IF r_get_supplier_id.SITE_PAYMENT_GROUP_CODE IS NOT NULL THEN
BEGIN
SELECT lookup_code
into l_ss_pay_group_code
                FROM po_lookup_codes
                WHERE lookup_type = 'PAY GROUP'
                AND upper(DISPLAYED_FIELD) = upper(r_get_supplier_id.SITE_PAYMENT_GROUP_CODE)
                AND enabled_flag = 'Y'
                AND nvl(inactive_date,sysdate+1) > sysdate;
    EXCEPTION
           WHEN OTHERS THEN
            l_error_flag := 'Y';
            l_error_log := l_error_log||'//P_VENDOR_VALIDATE Supplier site Invalid PAY GROUP';

END;
END IF;
--

--
    IF r_get_supplier_id.retainage_rate is NOT NULL THEN
        IF (r_get_supplier_id.retainage_rate <  0    OR
           r_get_supplier_id.retainage_rate >  100) THEN
        l_error_flag     :=     'Y';
        l_error_log     :=     l_error_log||'//P_VENDOR_VALIDATE Invalid retainage_rate';
        END IF;
    END IF;
--
--<Supplier Invoice_Currency_Code>--
IF r_get_supplier_id.SUPP_CURRENCY_CODE is not null THEN
      val_currency_code(r_get_supplier_id.SUPP_CURRENCY_CODE,
                        x_valid);
      IF NOT x_valid THEN
        l_error_flag     :=     'Y';
        l_error_log     :=     l_error_log||'//P_VENDOR_VALIDATE Supplier Invalid Invoice_Currency_Code';
       END IF;
END IF;
--

--
--<Supplier Site Invoice_Currency_Code>--
IF r_get_supplier_id.SITE_CURRENCY_CODE is not null THEN
      val_currency_code(upper(r_get_supplier_id.SITE_CURRENCY_CODE),
                        x_valid);
      IF NOT x_valid THEN
        l_error_flag     :=     'Y';
        l_error_log     :=     l_error_log||'//P_VENDOR_VALIDATE Supplier Site Invalid Invoice_Currency_Code';
       END IF;
END IF;
--

--
IF r_get_supplier_id.TAX_CLASSIFICATION_CODE IS NOT NULL THEN
BEGIN
SELECT LOOKUP_CODE
    into l_tax_class_code
  FROM (SELECT LOOKUP_CODE,
               MEANING
          FROM ZX_INPUT_CLASSIFICATIONS_V
         WHERE     LOOKUP_TYPE = 'ZX_INPUT_CLASSIFICATIONS'
               AND ENABLED_FLAG = 'Y'
               AND SYSDATE BETWEEN START_DATE_ACTIVE
                               AND NVL (END_DATE_ACTIVE, SYSDATE)
        UNION
        SELECT LOOKUP_CODE,
               MEANING
          FROM ZX_INPUT_CLASSIFICATIONS_V
         WHERE     LOOKUP_TYPE = 'ZX_WEB_EXP_TAX_CLASSIFICATIONS'
               AND ENABLED_FLAG = 'Y'
               AND SYSDATE BETWEEN START_DATE_ACTIVE
                               AND NVL (END_DATE_ACTIVE, SYSDATE)
        UNION
        SELECT LOOKUP_CODE,
               MEANING
          FROM ZX_OUTPUT_CLASSIFICATIONS_V
         WHERE     LOOKUP_TYPE = 'ZX_OUTPUT_CLASSIFICATIONS'
               AND ENABLED_FLAG = 'Y'
               AND SYSDATE BETWEEN START_DATE_ACTIVE
                               AND NVL (END_DATE_ACTIVE, SYSDATE)) QRSLT
 WHERE ( (    UPPER (LOOKUP_CODE) LIKE UPPER ( r_get_supplier_id.TAX_CLASSIFICATION_CODE)
          AND (   LOOKUP_CODE LIKE r_get_supplier_id.TAX_CLASSIFICATION_CODE
               OR LOOKUP_CODE LIKE r_get_supplier_id.TAX_CLASSIFICATION_CODE
               OR LOOKUP_CODE LIKE r_get_supplier_id.TAX_CLASSIFICATION_CODE
               OR LOOKUP_CODE LIKE r_get_supplier_id.TAX_CLASSIFICATION_CODE)));

                   EXCEPTION
           WHEN OTHERS THEN
            l_error_flag := 'Y';
            l_error_log := l_error_log||'//Invalid TAX_CLASSIFICATIONS_CODE';
END;
END IF;
--


--
END IF;--IF l_vendor_id IS NOT NULL THEN
--



IF l_error_flag = 'Y' THEN
  UPDATE xxah_ps_ebs_supp_bank_update
  SET    conversion_status = 'E' ,
         error_log = l_error_log ,
         request_id = gv_request_id
  WHERE  ROWID = r_get_supplier_id.ROWID;
  COMMIT;
  FND_FILE.put_line(fnd_file.log,'Error Record - '  ||r_get_supplier_id.supplier_site_name);
  FND_FILE.put_line(fnd_file.log,'Error > '||l_error_log);

  ELSE
  UPDATE xxah_ps_ebs_supp_bank_update
  SET    ora_vendor_id             =     l_vendor_id ,
         ora_vendor_name         =     l_vendor_name ,
         ora_party_id             =     l_party_id ,
         ora_vendor_site_id     =     l_vendor_site_id ,
         ora_party_site_id         =     l_party_site_id ,
         ora_location_id         =     l_location_id ,
         ora_term_id             =     l_terms_id,
         ora_inv_term_id            =    l_sp_terms_id,
         ora_pay_group_code     =     l_pay_group_code,
         ora_ss_pay_group_code    =    l_ss_pay_group_code,
         conversion_status         = 'V' ,
         request_id = gv_request_id
  WHERE  ROWID = r_get_supplier_id.ROWID;
  COMMIT;
  FND_FILE.put_line(fnd_file.log,'Valid Record - '  ||r_get_supplier_id.supplier_site_name);
END IF;


EXCEPTION
WHEN OTHERS THEN
FND_FILE.PUT_LINE(FND_FILE.LOG,'Error - P_VENDOR_VALIDATE '||SQLCODE||' -ERROR- '||SQLERRM);
NULL;
END;
FND_FILE.PUT_LINE(FND_FILE.LOG,'+---------------------------------------------------------------------------+');

        END LOOP;

    EXCEPTION
WHEN OTHERS THEN
FND_FILE.PUT_LINE(FND_FILE.LOG,'Error - P_VENDOR_VALIDATE '||SQLCODE||' -ERROR- '||SQLERRM);

END P_VENDOR_VALIDATE;

PROCEDURE P_UPDATE_VENDOR(p_row_id IN VARCHAR2,
                        p_vendor_id IN NUMBER,
                        p_po_match IN VARCHAR2,
                        p_sic_code IN VARCHAR2,
                        p_invoice_currency_code IN VARCHAR2,
                        p_pay_group_code IN VARCHAR2,
                        p_terms_id IN NUMBER,
                        p_end_date_active IN DATE)
IS
  p_api_version          NUMBER;
  p_init_msg_list        VARCHAR2(200);
  p_commit               VARCHAR2(200);
  p_validation_level     NUMBER;
  x_return_status        VARCHAR2(200);
  x_msg_count            NUMBER;
  x_msg_data             VARCHAR2(200);
  lr_vendor_rec          apps.ap_vendor_pub_pkg.r_vendor_rec_type;
  lr_existing_vendor_rec ap_suppliers%ROWTYPE;
  l_msg                  VARCHAR2(200);
     l_inspection_required_flag      VARCHAR2 (1):=NULL;
   l_receipt_required_flag         VARCHAR2 (1):=NULL;
        lv_inspection_required_flag      VARCHAR2 (1):=NULL;
   lv_receipt_required_flag         VARCHAR2 (1):=NULL;
   l_rowid                VARCHAR2(200);
ln_msg_index_out         NUMBER    := NULL;
l_api_msg VARCHAR2(2000);

l_end_date_active            ap_suppliers.end_date_active%TYPE;
l_sic_code                    ap_suppliers.STANDARD_INDUSTRY_CLASS%TYPE;
l_invoice_currency_code        ap_suppliers.invoice_currency_code%TYPE;
lv_terms_id                    AP_TERMS.TERM_ID%TYPE;
l_pay_group_lookup_code            ap_suppliers.pay_group_lookup_code%TYPE;
l_update_flag        VARCHAR2(1);

BEGIN

  -- Initialize apps session
  fnd_global.apps_initialize(user_id => fnd_global.user_id,
                             resp_id => fnd_global.resp_id,
                             resp_appl_id => fnd_global.resp_appl_id);

  -- Assign Basic Values
  p_api_version      := 1.0;
  p_init_msg_list    := FND_API.G_FALSE;--fnd_api.g_true;
  p_commit           := FND_API.G_FALSE;--fnd_api.g_true;
  p_validation_level := fnd_api.g_valid_level_full;

  -- gather vendor details

  l_inspection_required_flag    := NULL;
  l_receipt_required_flag       := NULL;
    lv_inspection_required_flag    := NULL;
  lv_receipt_required_flag       := NULL;
  l_api_msg                        := NULL;
  l_rowid                        := NULL;
  l_end_date_active                := NULL;
  l_update_flag                    := NULL;
  l_sic_code                    := NULL;
  l_invoice_currency_code        := NULL;
  lv_terms_id                    := NULL;
  l_pay_group_lookup_code        := NULL;

  select ROWID into l_rowid from xxah_ps_ebs_supp_bank_update
    where rowid = p_row_id
    and ora_vendor_id = p_vendor_id
            and request_id = gv_request_id;

  BEGIN
    SELECT *
      INTO lr_existing_vendor_rec
      FROM ap_suppliers asa
     WHERE asa.vendor_id = p_vendor_id;
  EXCEPTION
    WHEN OTHERS THEN
    NULL;
    FND_FILE.put_line(FND_FILE.LOG,'Unable to derive the supplier  information for vendor id:' ||p_vendor_id);
  END;

            --<Match Approval Level>--
      IF p_po_match        = '2-way match'
      THEN
         l_inspection_required_flag     := 'N';
         l_receipt_required_flag         := 'N';
      ELSIF p_po_match    = '3-way match'
      THEN
         l_inspection_required_flag     := 'N';
         l_receipt_required_flag         := 'Y';
      ELSIF p_po_match    = '4-way match'
      THEN
         l_inspection_required_flag        := 'Y';
         l_receipt_required_flag         := 'Y';
      --ELSE
         --l_inspection_required_flag     := NULL;
         --l_receipt_required_flag         := NULL;
      END IF;

      BEGIN
          select /* nvl(inspection_required_flag,'X'), nvl(receipt_required_flag, 'X'), trunc(end_date_active), STANDARD_INDUSTRY_CLASS, invoice_currency_code,
          terms_id, pay_group_lookup_code*/
           nvl(inspection_required_flag,'X'), nvl(receipt_required_flag, 'X'), trunc(end_date_active), nvl(STANDARD_INDUSTRY_CLASS,'X'),nvl(invoice_currency_code,'X'),
          nvl(terms_id,1), nvl(pay_group_lookup_code,'X')
            into lv_inspection_required_flag, lv_receipt_required_flag, l_end_date_active, l_sic_code, l_invoice_currency_code   ,
lv_terms_id , l_pay_group_lookup_code
          from ap_suppliers
          where vendor_id = p_vendor_id;
          EXCEPTION
            WHEN OTHERS THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG,'Error lv_inspection_required_flag '||SQLCODE||' -ERROR- '||SQLERRM);
      END;

      lr_vendor_rec.vendor_id                   := lr_existing_vendor_rec.vendor_id;

      IF (p_po_match   = '2-way match' OR
        p_po_match    = '3-way match' OR
        p_po_match    = '4-way match')
        AND ( l_inspection_required_flag <> lv_inspection_required_flag OR l_receipt_required_flag <> lv_receipt_required_flag )
        THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG,'--update Match Approval Level');

        l_update_flag := 'Y';
      lr_vendor_rec.inspection_required_flag     := l_inspection_required_flag;
      lr_vendor_rec.receipt_required_flag         := l_receipt_required_flag;
      END IF;

      IF p_end_date_active IS NOT NULL AND nvl(l_end_date_active,to_date('31-DEC-4721','DD-MON-YYYY')) <> p_end_date_active THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,'--update inactive date');
        l_update_flag    := 'Y';
        lr_vendor_rec.end_date_active    :=     p_end_date_active;
      END IF;

           FND_FILE.PUT_LINE(FND_FILE.LOG,'--p_sic_code'||p_sic_code||' l_sic_code '||l_sic_code);
    IF p_sic_code IS NOT NULL AND l_sic_code <> p_sic_code THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG,'--update SIC');
        l_update_flag    := 'Y';
        lr_vendor_rec.SIC_Code    := p_sic_code;
    END IF;

    IF p_invoice_currency_code IS NOT NULL AND nvl(l_invoice_currency_code,'A') <> p_invoice_currency_code  THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG,'--update invoice currency code');
        l_update_flag    := 'Y';
        lr_vendor_rec.invoice_currency_code := p_invoice_currency_code;
    END IF;

    IF p_terms_id IS NOT NULL AND nvl(lv_terms_id,'1') <> p_terms_id  THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG,'--update Terms');
        l_update_flag := 'Y';
        lr_vendor_rec.terms_id := p_terms_id;
    END IF;

     IF p_pay_group_code IS NOT NULL AND nvl(l_pay_group_lookup_code,'1') <> p_pay_group_code  THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG,'--update Pay Group');
        l_update_flag := 'Y';
        lr_vendor_rec.pay_group_lookup_code := p_pay_group_code;
    END IF;

IF l_update_flag = 'Y' THEN
 FND_FILE.PUT_LINE(FND_FILE.LOG,'--Updating supplier po match/inactive date ');
  ap_vendor_pub_pkg.update_vendor(p_api_version      => p_api_version,
                                  p_init_msg_list    => p_init_msg_list,
                                  p_commit           => p_commit,
                                  p_validation_level => p_validation_level,
                                  x_return_status    => x_return_status,
                                  x_msg_count        => x_msg_count,
                                  x_msg_data         => x_msg_data,
                                  p_vendor_rec       => lr_vendor_rec,
                                  p_vendor_id        => p_vendor_id);
                                 --commit;
    FND_FILE.put_line(FND_FILE.LOG,'--status => '||x_return_status);

  IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
      ROLLBACK;
    gv_commit_flag := 'N';
    FOR i IN 1 .. x_msg_count
        LOOP
            fnd_msg_pub.get (p_msg_index          => i,
                          p_data               => x_msg_data,
                          p_encoded            => 'F',
                          p_msg_index_out      => ln_msg_index_out
                         );
            fnd_message.set_encoded (x_msg_data);
            l_api_msg := l_api_msg||' / '||( 'Msg'|| TO_CHAR(i)|| ': '|| x_msg_data);
        END LOOP;
        FND_FILE.put_line(FND_FILE.LOG,'The API P_UPDATE_VENDOR call failed with error ' || l_api_msg);
        gv_api_msg := gv_api_msg||l_api_msg;
  ELSE
    NULL;
    --commit;
     gv_commit_flag := 'Y';
  END IF;
END IF;

EXCEPTION
   WHEN OTHERS
   THEN
      ROLLBACK;
FND_FILE.PUT_LINE(FND_FILE.LOG,'+---------------------------------------------------------------------------+');
FND_FILE.PUT_LINE(FND_FILE.LOG,'Error -P_UPDATE_VENDOR '||SQLCODE||' -ERROR- '||SQLERRM);
FND_FILE.PUT_LINE(FND_FILE.LOG,'+---------------------------------------------------------------------------+');
END P_UPDATE_VENDOR;

PROCEDURE P_UPDATE_SUPPLIER(p_old_supplier_name IN VARCHAR2,
                            p_new_supplier_name IN VARCHAR2,
                            p_party_id IN NUMBER,
                            p_vat_registration_num IN VARCHAR2,
                            p_duns_number IN VARCHAR2)
                            IS

l_vendor HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE;
v_return_status VARCHAR2(2000);
v_msg_count NUMBER;
v_msg_data VARCHAR2(2000);
v_profile_id NUMBER;
V_OBJECT NUMBER :=1;
l_party_id  hz_parties.party_id%type;
l_object_version_number hz_parties.object_version_number%type;
v_uan_status        VARCHAR2(1);
l_msg_index_out         NUMBER    := NULL;
l_api_msg VARCHAR2(2000);
        l_api_error_flag        VARCHAR2(1);
        l_api_error_msg            VARCHAR2(2000);


l_msg_data                   varchar2 (20000);
l_return_status              varchar2 (100);
l_msg_count                  number;

l_count_sn    NUMBER;
l_vat_count    NUMBER;
l_vendor_rec                     ap_vendor_pub_pkg.r_vendor_rec_type;
l_vendor_name            ap_suppliers.vendor_name%TYPE;
l_vat_registration_num    ap_suppliers.vat_registration_num%TYPE;
l_duns_number            hz_parties.duns_number%TYPE;
l_update_supplier_flag    VARCHAR2(50);

BEGIN

v_uan_status:= NULL;
        l_api_error_flag    := NULL;
        l_api_error_msg     := NULL;
        gv_commit_flag      := 'Y';
        l_object_version_number := NULL;
        l_vendor_name        := NULL;
        l_vat_registration_num    := NULL;
        l_duns_number        := NULL;
        l_update_supplier_flag    := NULL;

--fnd_file.put_line(fnd_file.log,'Start For Loop ');
fnd_file.put_line(fnd_file.log,'Old Supplier Name => '||p_old_supplier_name ||' '||' New Supplier Name => '||p_new_supplier_name);

select VENDOR_NAME, VAT_REGISTRATION_NUM
into
l_vendor_name,
l_vat_registration_num
 from ap_suppliers
where party_id = p_party_id;

    --
    IF p_new_supplier_name IS NOT NULL AND l_vendor_name <> p_new_supplier_name THEN
        l_update_supplier_flag := 'Y';
        l_vendor.organization_name    := p_new_supplier_name;
                FND_FILE.PUT_LINE(FND_FILE.LOG,'--update new supplier name');
    END IF;
    --
--
    IF p_vat_registration_num IS NOT NULL AND l_vat_registration_num <> p_vat_registration_num THEN
        l_update_supplier_flag := 'Y';
        l_vendor.tax_reference    := p_vat_registration_num    ;
        FND_FILE.PUT_LINE(FND_FILE.LOG,'--update vat registration num');
    END IF;
--

 select hzp.object_version_number, hzp.DUNS_NUMBER
                into l_object_version_number, l_duns_number
                    from hz_parties hzp
                where PARTY_ID = p_party_id
                AND status = 'A';

    IF p_duns_number IS NOT NULL AND nvl(l_duns_number,'1') <> p_duns_number THEN
        l_update_supplier_flag := 'Y';
        l_vendor.duns_number_c := p_duns_number;
        FND_FILE.PUT_LINE(FND_FILE.LOG,'--update DUNS number');
    END IF;

--
IF l_update_supplier_flag = 'Y' THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG,'3');



l_vendor.party_rec.party_id := p_party_id;
v_object := l_object_version_number;
--
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Updating supplier name/vat registration num');

HZ_PARTY_V2PUB.update_organization (
p_init_msg_list => fnd_api.g_true, --FND_API.G_FALSE,
p_organization_rec => l_vendor ,
p_party_object_version_number => v_object,
x_profile_id => v_profile_id,
x_return_status => v_return_status,
x_msg_count => v_msg_count,
x_msg_data => v_msg_data
);
FND_FILE.PUT_LINE(FND_FILE.LOG,'Updation complete');

fnd_file.put_line(fnd_file.log,'--NEW_SUPPLIER_NAME => '||v_return_status);

select count(*) into l_count_sn from ap_suppliers where upper(vendor_name) = upper(p_new_supplier_name);
IF l_count_sn = 1 then
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Supplier name updated with new supplier name '||l_count_sn);
    --commit;
    else
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Supplier name NOT updated with new supplier name!!! '||l_count_sn);
END IF;

if (v_return_status <> 'S') then
    ROLLBACK;
    gv_commit_flag := 'N';
--fnd_file.put_line(fnd_file.log,l_msg_data);
l_api_msg := NULL;
IF v_msg_count >= 1 THEN
FOR i IN 1..v_msg_count LOOP
                    fnd_msg_pub.get(p_msg_index     => i,
                                    p_data          => v_msg_data,
                                    p_encoded       => 'F',
                                    p_msg_index_out => l_msg_index_out);
                    fnd_message.set_encoded(v_msg_data);
l_api_msg := l_api_msg||' / '||( 'Msg'|| TO_CHAR(i)|| ': '|| v_msg_data);
FND_FILE.PUT_LINE(FND_FILE.LOG,'+---------------------------------------------------------------------------+');
FND_FILE.PUT_LINE(FND_FILE.LOG,'Error - NEW_SUPPLIER_NAME -ERROR- '||l_api_msg);
FND_FILE.PUT_LINE(FND_FILE.LOG,'+---------------------------------------------------------------------------+');
END LOOP;
l_api_error_flag     :=    'Y';
l_api_error_msg     :=    '//Update NEW_SUPPLIER_NAME : '||l_api_msg;
END IF;
end if;

END IF;
fnd_file.put_line(fnd_file.LOG,'+---------------------------------------------------------------------------+');
EXCEPTION
WHEN OTHERS THEN
FND_FILE.PUT_LINE(FND_FILE.LOG,'+---------------------------------------------------------------------------+');
FND_FILE.PUT_LINE(FND_FILE.LOG,'Error - P_UPDATE_SUPPLIER '||SQLCODE||' -ERROR- '||SQLERRM);
FND_FILE.PUT_LINE(FND_FILE.LOG,'+---------------------------------------------------------------------------+');

END P_UPDATE_SUPPLIER;

PROCEDURE P_UPDATE_SUPPLIER_SITE(
    p_vendor_site_id             IN NUMBER,
    p_ss_vendor_site_code         IN VARCHAR2,
    p_ss_invoice_currency         IN VARCHAR2,
    p_ss_pay_group_code         IN VARCHAR2,
    p_ss_retainage_rate         IN NUMBER,
    p_ss_inactive_date            IN DATE,
    p_ss_purchasing_site_flag    IN VARCHAR2,
    p_ss_pay_site_flag            IN VARCHAR2,
    p_ss_primary_pay_site_flag    IN VARCHAR2,
    p_ss_email_address           IN VARCHAR2,
    p_attribute1                IN VARCHAR2,
    p_attribute2     IN VARCHAR2,
    p_attribute3     IN VARCHAR2,
    p_attribute4     IN VARCHAR2,
    p_attribute5     IN VARCHAR2,
    p_attribute6     IN VARCHAR2,
    p_attribute7     IN VARCHAR2,
    p_attribute8     IN VARCHAR2,
    p_attribute10    IN VARCHAR2,
    p_ss_term_id    IN NUMBER
    )
IS
  p_api_version               NUMBER;
  p_init_msg_list             VARCHAR2(200);
  p_commit                    VARCHAR2(200);
  p_validation_level          NUMBER;
  x_return_status             VARCHAR2(200);
  x_msg_count                 NUMBER;
  x_msg_data                  VARCHAR2(200);
  lr_vendor_site_rec          apps.ap_vendor_pub_pkg.r_vendor_site_rec_type;
  lr_existing_vendor_site_rec ap_supplier_sites_all%ROWTYPE;
l_msg_index_out   NUMBER    := NULL;
  l_rowid                      VARCHAR2(200);
   l_api_msg VARCHAR2(2000);
l_ss_update        VARCHAR2(1);

BEGIN
    l_rowid    := NULL;
    l_ss_update    := NULL;

  -- Initialize apps session
  fnd_global.apps_initialize(user_id => fnd_global.user_id,
                             resp_id => fnd_global.resp_id,
                             resp_appl_id => fnd_global.resp_appl_id);

  -- Assign Basic Values
  p_api_version      := 1.0;
  p_init_msg_list    := FND_API.G_FALSE;--fnd_api.g_true;
  p_commit           := FND_API.G_FALSE;--fnd_api.g_true;
  p_validation_level := fnd_api.g_valid_level_full;

  BEGIN
    SELECT *
      INTO lr_existing_vendor_site_rec
      FROM ap_supplier_sites_all assa
     WHERE assa.vendor_site_id = p_vendor_site_id;
  EXCEPTION
    WHEN OTHERS THEN
    NULL;
      FND_FILE.put_line(FND_FILE.LOG,'Unable to derive the supplier site information for site id:' ||p_vendor_site_id);

  END;

  -- Assign Vendor Site Details
  lr_vendor_site_rec.vendor_site_id   := lr_existing_vendor_site_rec.vendor_site_id;
  FND_FILE.put_line(FND_FILE.LOG,'vendor_site_id '||lr_vendor_site_rec.vendor_site_id);
  lr_vendor_site_rec.last_update_date := SYSDATE;
  lr_vendor_site_rec.last_updated_by  := fnd_global.user_id;
  lr_vendor_site_rec.vendor_id        := lr_existing_vendor_site_rec.vendor_id;
  lr_vendor_site_rec.org_id           := lr_existing_vendor_site_rec.org_id;




    IF p_ss_term_id IS NOT NULL AND upper(p_ss_term_id) <> upper(lr_existing_vendor_site_rec.terms_id) THEN
        l_ss_update := 'Y';
        lr_vendor_site_rec.terms_id    :=    p_ss_term_id;
        FND_FILE.put_line(FND_FILE.LOG,'--update terms_id'||lr_existing_vendor_site_rec.terms_id||' '||p_ss_term_id);
    END IF;

    IF p_ss_vendor_site_code IS NOT NULL AND upper(p_ss_vendor_site_code) <> upper(lr_existing_vendor_site_rec.vendor_site_code) THEN
        l_ss_update := 'Y';
        lr_vendor_site_rec.vendor_site_code    :=    p_ss_vendor_site_code;
        FND_FILE.put_line(FND_FILE.LOG,'--update vendor_site_code'||lr_existing_vendor_site_rec.vendor_site_code||' '||p_ss_vendor_site_code);
    END IF;

    IF p_ss_invoice_currency IS NOT NULL AND p_ss_invoice_currency <> nvl(lr_existing_vendor_site_rec.invoice_currency_code,'A') THEN
        l_ss_update := 'Y';
        lr_vendor_site_rec.invoice_currency_code    :=    p_ss_invoice_currency;
        FND_FILE.put_line(FND_FILE.LOG,'--update invoice_currency_code');
    END IF;

    IF p_ss_pay_group_code IS NOT NULL AND p_ss_pay_group_code <> nvl(lr_existing_vendor_site_rec.invoice_currency_code,'A') THEN
        l_ss_update := 'Y';
        lr_vendor_site_rec.pay_group_lookup_code    :=    p_ss_pay_group_code;
        FND_FILE.put_line(FND_FILE.LOG,'--update pay_group_lookup_code');
    END IF;

    IF p_ss_retainage_rate IS NOT NULL AND p_ss_retainage_rate <> nvl(lr_existing_vendor_site_rec.retainage_rate,0) THEN
        l_ss_update := 'Y';
        lr_vendor_site_rec.retainage_rate    :=    p_ss_retainage_rate;
        FND_FILE.put_line(FND_FILE.LOG,'--update retainage_rate');
    END IF;

    IF p_ss_inactive_date IS NOT NULL AND p_ss_inactive_date <> nvl(lr_existing_vendor_site_rec.INACTIVE_DATE,to_date('31-DEC-4721','DD-MON-YYYY')) THEN
        l_ss_update := 'Y';
        lr_vendor_site_rec.INACTIVE_DATE    :=    p_ss_inactive_date;
        FND_FILE.put_line(FND_FILE.LOG,'--update inactive_date');
    END IF;

    IF p_ss_purchasing_site_flag IS NOT NULL AND p_ss_purchasing_site_flag <> nvl(lr_existing_vendor_site_rec.PURCHASING_SITE_FLAG,'X') THEN
        l_ss_update := 'Y';
        lr_vendor_site_rec.PURCHASING_SITE_FLAG    :=    p_ss_purchasing_site_flag;
        FND_FILE.put_line(FND_FILE.LOG,'--update purchasing_site_flag');
    END IF;

    IF p_ss_pay_site_flag IS NOT NULL AND p_ss_pay_site_flag <> nvl(lr_existing_vendor_site_rec.PAY_SITE_FLAG,'X') THEN
        l_ss_update := 'Y';
        lr_vendor_site_rec.PAY_SITE_FLAG    :=    p_ss_pay_site_flag;
        FND_FILE.put_line(FND_FILE.LOG,'--update pay_site_flag');
    END IF;

    IF p_ss_pay_site_flag IS NOT NULL AND p_ss_pay_site_flag <> nvl(lr_existing_vendor_site_rec.PAY_SITE_FLAG,'X') THEN
        l_ss_update := 'Y';
        lr_vendor_site_rec.PAY_SITE_FLAG    :=    p_ss_pay_site_flag;
        FND_FILE.put_line(FND_FILE.LOG,'--update pay_site_flag');
    END IF;

    IF p_ss_primary_pay_site_flag IS NOT NULL AND p_ss_primary_pay_site_flag <> nvl(lr_existing_vendor_site_rec.PRIMARY_PAY_SITE_FLAG,'X') THEN
        l_ss_update := 'Y';
        lr_vendor_site_rec.PRIMARY_PAY_SITE_FLAG    :=    p_ss_primary_pay_site_flag;
        FND_FILE.put_line(FND_FILE.LOG,'--update primary_pay_site_flag');
    END IF;

          FND_FILE.put_line(FND_FILE.LOG,'--p_ss_email_address '||p_ss_email_address);
    IF p_ss_email_address IS NOT NULL AND p_ss_email_address <> nvl(lr_existing_vendor_site_rec.EMAIL_ADDRESS,'X') THEN
        l_ss_update := 'Y';
        lr_vendor_site_rec.EMAIL_ADDRESS    :=    p_ss_email_address;
        FND_FILE.put_line(FND_FILE.LOG,'--update email_address');
    END IF;

    IF p_attribute1 IS NOT NULL AND p_attribute1 <> nvl(lr_existing_vendor_site_rec.attribute1,'X') THEN
        l_ss_update := 'Y';
        lr_vendor_site_rec.attribute1    :=    p_attribute1;
        FND_FILE.put_line(FND_FILE.LOG,'--update Primary Contact Name Given');
    END IF;

    IF p_attribute2 IS NOT NULL AND p_attribute2 <> nvl(lr_existing_vendor_site_rec.attribute2,'X') THEN
        l_ss_update := 'Y';
        lr_vendor_site_rec.attribute2    :=    p_attribute2;
        FND_FILE.put_line(FND_FILE.LOG,'--update Primary Contact Name Family');
    END IF;

    IF p_attribute3 IS NOT NULL AND p_attribute3 <> nvl(lr_existing_vendor_site_rec.attribute3,'X') THEN
        l_ss_update := 'Y';
        lr_vendor_site_rec.attribute3    :=    p_attribute3;
        FND_FILE.put_line(FND_FILE.LOG,'--update Primary Contact Email');
    END IF;

    IF p_attribute4 IS NOT NULL AND p_attribute4 <> nvl(lr_existing_vendor_site_rec.attribute4,'X') THEN
        l_ss_update := 'Y';
        lr_vendor_site_rec.attribute4    :=    p_attribute4;
        FND_FILE.put_line(FND_FILE.LOG,'--update Primary Contact Phone Work');
    END IF;

    IF p_attribute5 IS NOT NULL AND p_attribute5 <> nvl(lr_existing_vendor_site_rec.attribute5,'X') THEN
        l_ss_update := 'Y';
        lr_vendor_site_rec.attribute5    :=    p_attribute5;
        FND_FILE.put_line(FND_FILE.LOG,'--update Primary Contact Phone Work Area');
    END IF;

    IF p_attribute6 IS NOT NULL AND p_attribute6 <> nvl(lr_existing_vendor_site_rec.attribute6,'X') THEN
        l_ss_update := 'Y';
        lr_vendor_site_rec.attribute6    :=    p_attribute6;
        FND_FILE.put_line(FND_FILE.LOG,'--update Primary Contact Phone Mobile');
    END IF;

    IF p_attribute7 IS NOT NULL AND p_attribute7 <> nvl(lr_existing_vendor_site_rec.attribute7,'X') THEN
        l_ss_update := 'Y';
        lr_vendor_site_rec.attribute7    :=    p_attribute7;
        FND_FILE.put_line(FND_FILE.LOG,'--update Primary Contact Phone Fax');
    END IF;

    IF p_attribute8 IS NOT NULL AND p_attribute8 <> nvl(lr_existing_vendor_site_rec.attribute8,'X') THEN
        l_ss_update := 'Y';
        lr_vendor_site_rec.attribute8    :=    p_attribute8;
        FND_FILE.put_line(FND_FILE.LOG,'--update Primary Contact Country Code');
    END IF;

    IF p_attribute10 IS NOT NULL AND p_attribute10 <> nvl(lr_existing_vendor_site_rec.attribute10,'X') THEN
        l_ss_update := 'Y';
        lr_vendor_site_rec.attribute10    :=    p_attribute10;
        FND_FILE.put_line(FND_FILE.LOG,'--update People Soft Number');
    END IF;

    IF l_ss_update = 'Y' THEN

  AP_VENDOR_PUB_PKG.UPDATE_VENDOR_SITE(p_api_version      => p_api_version,
                                       p_init_msg_list    => p_init_msg_list,
                                       p_commit           => p_commit,
                                       p_validation_level => p_validation_level,
                                       x_return_status    => x_return_status,
                                       x_msg_count        => x_msg_count,
                                       x_msg_data         => x_msg_data,
                                       p_vendor_site_rec  => lr_vendor_site_rec,
                                       p_vendor_site_id   => p_vendor_site_id
                                       );

  FND_FILE.put_line(FND_FILE.LOG,'--UPDATE_VENDOR_SITE => '||x_return_status);

  IF x_return_status =  fnd_api.g_ret_sts_success  THEN
    NULL;
    gv_commit_flag := 'Y';
  ELSE
         gv_commit_flag := 'N';
        ROLLBACK;
    FOR i IN 1 .. x_msg_count
    LOOP
      fnd_msg_pub.get(p_msg_index     => i,
                      p_data          => x_msg_data,
                      p_encoded       => 'F',
                      p_msg_index_out => l_msg_index_out);
      fnd_message.set_encoded(x_msg_data);
      l_api_msg := l_api_msg||' / '||( 'Msg'|| TO_CHAR(i)|| ': '|| x_msg_data);
    END LOOP;
         FND_FILE.put_line(FND_FILE.LOG,'Error P_UPDATE_SUPPLIER_SITE : ' || l_api_msg);
         gv_api_msg := gv_api_msg||l_api_msg;
  END IF;

  END IF;

EXCEPTION
   WHEN OTHERS
   THEN
      ROLLBACK;
FND_FILE.PUT_LINE(FND_FILE.LOG,'Error -P_UPDATE_SUPPLIER_SITE '||SQLCODE||' -ERROR- '||SQLERRM);

END P_UPDATE_SUPPLIER_SITE;

PROCEDURE P_UPDATE_ADDRESS(p_add_location_id IN NUMBER,
                            p_address_line1 IN VARCHAR2,
                            p_address_line2 IN VARCHAR2,
                            p_address_line3 IN VARCHAR2,
                            p_address_line4 IN VARCHAR2,
                            p_city IN VARCHAR2,
                            p_postal_code IN VARCHAR2,
                            p_state IN VARCHAR2,
                            p_county IN VARCHAR2,
                            p_country IN VARCHAR2,
                            p_province IN VARCHAR2)
IS
    p_location_rec          HZ_LOCATION_V2PUB.LOCATION_REC_TYPE;
    p_object_version_number NUMBER;
    lx_return_status         VARCHAR2(2000);
    lx_msg_count             NUMBER;
    lx_msg_data              VARCHAR2(2000);
    x_return_status         VARCHAR2(2000);
    x_msg_count             NUMBER;
    x_msg_data              VARCHAR2(2000);
    l_api_msg VARCHAR2(2000);
    ln_msg_index_out         NUMBER    := NULL;
    l_rowid                      VARCHAR2(200);
    l_changed_flag varchar2(1) := 'N';
        l_old_location_rec    HZ_LOCATION_V2PUB.LOCATION_REC_TYPE;

BEGIN
-- Setting the Context --
    l_rowid        := NULL;

fnd_global.apps_initialize ( user_id      => FND_GLOBAL.USER_ID
                            ,resp_id      => FND_GLOBAL.RESP_ID
                            ,resp_appl_id => FND_GLOBAL.RESP_APPL_ID);

p_object_version_number := null;

   -- Get old records.
    hz_location_v2pub.get_location_rec (
        p_location_id                        => p_add_location_id,
        x_location_rec                       => l_old_location_rec,
        x_return_status                      => lx_return_status,
        x_msg_count                          => lx_msg_count,
        x_msg_data                           => lx_msg_data);

       IF (p_address_line1 IS NOT NULL AND
            NVL(l_old_location_rec.address1, fnd_api.g_miss_char) <> p_address_line1)
        OR (p_address_line2 IS NOT NULL AND
            NVL(l_old_location_rec.address2, fnd_api.g_miss_char) <> p_address_line2)
        OR (p_address_line3 IS NOT NULL AND
            NVL(l_old_location_rec.address3, fnd_api.g_miss_char) <> p_address_line3)
        OR (p_address_line4 IS NOT NULL AND
            NVL(l_old_location_rec.address4, fnd_api.g_miss_char) <> p_address_line4)
        OR (p_country IS NOT NULL AND
            NVL(l_old_location_rec.country, fnd_api.g_miss_char) <> p_country)
        OR (p_city IS NOT NULL AND
               NVL(l_old_location_rec.city, fnd_api.g_miss_char) <> p_city)
        OR (p_state IS NOT NULL AND
               NVL(l_old_location_rec.state, fnd_api.g_miss_char) <>p_state)
        OR (p_postal_code IS NOT NULL AND
            NVL(l_old_location_rec.postal_code, fnd_api.g_miss_char) <> p_postal_code)
        OR (p_county IS NOT NULL AND
        NVL(l_old_location_rec.county, fnd_api.g_miss_char) <> p_county)
         OR (p_province IS NOT NULL AND
        NVL(l_old_location_rec.province, fnd_api.g_miss_char) <> p_province)
    then
        l_changed_flag := 'Y';
    end if;

    BEGIN
        SELECT Max(HZL.object_version_number)
        INTO   p_object_version_number
        FROM   hz_locations HZL
        WHERE  HZL.location_id = p_add_location_id;
        EXCEPTION
        WHEN OTHERS THEN
        l_api_msg := l_api_msg||'update address location not found.';
    END;

    -- Initializing the Mandatory API parameters
    p_location_rec.location_id         := p_add_location_id;
    p_location_rec.country             := p_country;
    p_location_rec.address1            := p_address_line1;
    p_location_rec.address2            := p_address_line2;
    p_location_rec.address3            := p_address_line3;
    p_location_rec.address4            := p_address_line4;
    p_location_rec.city                := p_city;
    p_location_rec.postal_code        := p_postal_code;
    p_location_rec.state            := p_state;
    p_location_rec.county            := UPPER(p_county);
    p_location_rec.province            := p_province;

    IF l_changed_flag = 'Y' THEN
            fnd_file.put_line(fnd_file.log,'--updating address');
                hz_location_v2pub.update_location
                            (p_init_msg_list           => FND_API.G_FALSE,
                             --p_commit                   => FND_API.G_FALSE,
                             p_location_rec            => p_location_rec,
                             p_object_version_number   => p_object_version_number,
                             x_return_status           => x_return_status,
                             x_msg_count               => x_msg_count,
                             x_msg_data                => x_msg_data);
        fnd_file.put_line(fnd_file.log,'--update_location => '||x_return_status);
        --commit;
                IF x_return_status <> fnd_api.g_ret_sts_success THEN
                        ROLLBACK;
                        fnd_file.put_line(fnd_file.log,'!!Rollback Executed!!');
                        gv_commit_flag := 'N';

                      FOR i IN 1 .. x_msg_count
                        LOOP
                         fnd_msg_pub.get (p_msg_index          => i,
                                          p_data               => x_msg_data,
                                          p_encoded            => 'F',
                                          p_msg_index_out      => ln_msg_index_out
                                         );
                         fnd_message.set_encoded (x_msg_data);
                        l_api_msg := l_api_msg||' / '||( 'Msg'|| TO_CHAR(i)|| ': '|| x_msg_data);
                      END LOOP;
                    FND_FILE.put_line(FND_FILE.LOG,'Error P_UPDATE_ADDRESS : ' || l_api_msg);
                    gv_api_msg := gv_api_msg || l_api_msg;
                    else
                    gv_commit_flag := 'Y';

                END IF;
    END IF;
EXCEPTION
WHEN OTHERS THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Error - P_UPDATE_ADDRESS '||SQLCODE||' -ERROR- '||SQLERRM);
    gv_api_msg := '//P_UPDATE_ADDRESS '||SQLERRM;

END P_UPDATE_ADDRESS;

PROCEDURE P_CREATE_BANK (
   p_bank_name             IN       VARCHAR2,
   p_alternate_bank_name   IN       VARCHAR2,
   p_bank_number           IN       VARCHAR2,
   p_country_code          IN       VARCHAR2,
   p_description           IN       VARCHAR2,
   p_bank_id               OUT      NUMBER
)
IS
   p_init_msg_list       VARCHAR2 (200);
   x_bank_id             NUMBER;
   x_return_status       VARCHAR2 (200);
   x_msg_count           NUMBER;
   x_msg_data            VARCHAR2 (200);
   p_count               NUMBER;
   x_end_date            DATE;
   l_count_short_bname   NUMBER;
   l_error_flag          VARCHAR2 (1);
   l_error_msg           VARCHAR2 (2000);
   lv_api_msg            VARCHAR2 (2000);
   ln_msg_index_out      NUMBER          := NULL;
BEGIN
   p_init_msg_list := fnd_api.g_true;
   lv_api_msg := NULL;
   p_bank_id := NULL;
   --<Check Bank Exist>--
   ce_bank_pub.check_bank_exist (p_country_code      => p_country_code,
                                 p_bank_name         => p_bank_name,
                                 p_bank_number       => p_bank_number,
                                 x_bank_id           => x_bank_id,
                                 x_end_date          => x_end_date
                                );

   IF x_bank_id IS NOT NULL
   THEN
      l_error_flag := 'Y';
      l_error_msg := '//Bank Already Exists';
      p_bank_id := x_bank_id;
      fnd_file.put_line (fnd_file.LOG, '//Bank Already Exists '||x_bank_id);
   END IF;

   IF x_bank_id IS NULL
   THEN
      fnd_global.apps_initialize (user_id           => fnd_global.user_id,
                                  resp_id           => fnd_global.resp_id,
                                  resp_appl_id      => fnd_global.resp_appl_id
                                 );
      fnd_file.put_line (fnd_file.LOG, 'creating bank');

      ce_bank_pub.create_bank (p_init_msg_list            => p_init_msg_list,
                               p_country_code             => p_country_code,
                               p_bank_name                => p_bank_name,
                               p_bank_number              => p_bank_number,
                               p_alternate_bank_name      => p_alternate_bank_name,
                               --p_short_bank_name          => p_short_bank_name,
                               p_description              => p_description,
                               x_bank_id                  => x_bank_id,
                               x_return_status            => x_return_status,
                               x_msg_count                => x_msg_count,
                               x_msg_data                 => x_msg_data
                              );
      fnd_file.put_line (fnd_file.LOG, 'bank_id '||x_bank_id);

      IF (x_return_status <> fnd_api.g_ret_sts_success)
      THEN
         ln_msg_index_out := NULL;
         gv_commit_flag := 'N';

         FOR i IN 1 .. x_msg_count
         LOOP
            fnd_msg_pub.get (p_msg_index          => i,
                             p_data               => x_msg_data,
                             p_encoded            => 'F',
                             p_msg_index_out      => ln_msg_index_out
                            );
            fnd_message.set_encoded (x_msg_data);
            lv_api_msg :=
                  lv_api_msg
               || ' / '
               || ('Msg' || TO_CHAR (i) || ': ' || x_msg_data);
            fnd_file.put_line (fnd_file.LOG,
                               'Error at Bank API : ' || i || ', '
                               || x_msg_data
                              );
         END LOOP;

         ROLLBACK;
         gv_api_msg := gv_api_msg || lv_api_msg;

         fnd_file.put_line (fnd_file.LOG,
                            'Bank NOT Created! and rollback executed'
                           );
      ELSE
         p_bank_id := x_bank_id;
         gv_commit_flag := 'Y';
         fnd_file.put_line (fnd_file.LOG, '--Bank Created'||p_bank_id);
      END IF;            --if (x_return_status <>  fnd_api.g_ret_sts_success )
   END IF;  --IF x_bank_id IS NULL

   EXCEPTION
WHEN OTHERS THEN
FND_FILE.PUT_LINE(FND_FILE.LOG,'+---------------------------------------------------------------------------+');
FND_FILE.PUT_LINE(FND_FILE.LOG,'Error - P_CREATE_BANK '||SQLCODE||' -ERROR- '||SQLERRM);
FND_FILE.PUT_LINE(FND_FILE.LOG,'+---------------------------------------------------------------------------+');
END P_CREATE_BANK;

PROCEDURE P_CREATE_BRANCH (
   p_bank_id            IN       NUMBER,
   p_branch_name        IN       VARCHAR2,
   p_branch_number      IN       VARCHAR2,
   p_bic                IN       VARCHAR,
   p_branch_id          OUT      NUMBER
)
IS
   p_init_msg_list           VARCHAR2 (200);
   p_branch_type             VARCHAR2 (200);
   p_alternate_branch_name   VARCHAR2 (200);
   p_description             VARCHAR2 (200);
   p_rfc_identifier          VARCHAR2 (200);
   x_branch_id               NUMBER          := NULL;
   x_return_status           VARCHAR2 (200);
   x_msg_count               NUMBER;
   x_msg_data                VARCHAR2 (200);
   p_count                   NUMBER;
   x_end_date                DATE;
   lv_branch_number          NUMBER;
   l_error_flag              VARCHAR2 (1);
   l_error_msg               VARCHAR2 (2000);
   lv_api_msg                VARCHAR2 (2000);
   ln_msg_index_out          NUMBER          := NULL;
   l_bic                     VARCHAR2 (1);
BEGIN
   p_init_msg_list := fnd_api.g_true;
   p_alternate_branch_name := p_branch_name;
   p_description := p_branch_name;
   p_branch_type := 'ABA';
   p_rfc_identifier := 'AFC';

   BEGIN
      ce_bank_pub.check_branch_exist (p_bank_id            => p_bank_id,
                                      p_branch_name        => p_branch_name,
                                      p_branch_number      => p_branch_number,
                                      x_branch_id          => x_branch_id,
                                      x_end_date           => x_end_date
                                     );
   END;

   IF x_branch_id IS NOT NULL
   THEN
      l_error_flag := 'Y';
      l_error_msg := '//Branch Already Exists';
      fnd_file.put_line (fnd_file.LOG, '//Branch Already Exists');
      p_branch_id := x_branch_id;
   END IF;

   ce_validate_bankinfo.ce_validate_bic (x_bic_code           => p_bic,
                                         p_init_msg_list      => p_init_msg_list,
                                         x_msg_count          => x_msg_count,
                                         x_msg_data           => x_msg_data,
                                         x_return_status      => x_return_status
                                        );

   IF (x_return_status <> fnd_api.g_ret_sts_success)
   THEN
      ln_msg_index_out := NULL;

      FOR i IN 1 .. x_msg_count
      LOOP
         fnd_msg_pub.get (p_msg_index          => i,
                          p_data               => x_msg_data,
                          p_encoded            => 'F',
                          p_msg_index_out      => ln_msg_index_out
                         );
         fnd_message.set_encoded (x_msg_data);
         lv_api_msg :=
            lv_api_msg || ' / '
            || ('Msg' || TO_CHAR (i) || ': ' || x_msg_data);
         fnd_file.put_line (fnd_file.LOG,
                               'Error at CE_VALIDATE_BIC : '
                            || i
                            || ', '
                            || x_msg_data
                           );
      END LOOP;

      l_error_flag := 'Y';
      l_error_msg := l_error_msg || '//CE_VALIDATE_BIC API : ' || lv_api_msg;
      fnd_file.put_line (fnd_file.LOG, 'BIC Invalid');
   ELSE
      l_bic := 'V';
   END IF;               --if (x_return_status <>  fnd_api.g_ret_sts_success )

   IF x_branch_id IS NULL AND l_bic = 'V'
   THEN
      x_msg_count := NULL;
      x_msg_data := NULL;
      x_return_status := NULL;
      ce_bank_pub.create_bank_branch
                         (p_init_msg_list              => p_init_msg_list,
                          p_bank_id                    => p_bank_id,
                          p_branch_name                => p_branch_name,
                          p_branch_number              => p_branch_number,
                          p_branch_type                => p_branch_type,
                          p_alternate_branch_name      => p_alternate_branch_name,
                          p_description                => p_description,
                          p_bic                        => p_bic,
                          --p_eft_number          =>  p_bic,
                          p_rfc_identifier             => p_rfc_identifier,
                          x_branch_id                  => x_branch_id,
                          x_return_status              => x_return_status,
                          x_msg_count                  => x_msg_count,
                          x_msg_data                   => x_msg_data
                         );

      IF x_branch_id IS NOT NULL
      THEN
         p_branch_id := x_branch_id;
         fnd_file.put_line (fnd_file.LOG, '--Branch Created');
      END IF;

      IF (x_return_status <> fnd_api.g_ret_sts_success)
      THEN
         ln_msg_index_out := NULL;
          gv_commit_flag := 'N';

         FOR i IN 1 .. x_msg_count
         LOOP
            fnd_msg_pub.get (p_msg_index          => i,
                             p_data               => x_msg_data,
                             p_encoded            => 'F',
                             p_msg_index_out      => ln_msg_index_out
                            );
            fnd_message.set_encoded (x_msg_data);
            lv_api_msg :=
                  lv_api_msg
               || ' / '
               || ('Msg' || TO_CHAR (i) || ': ' || x_msg_data);
            fnd_file.put_line (fnd_file.LOG,
                                  'Error at Branch API : '
                               || i
                               || ', '
                               || x_msg_data
                              );
         END LOOP;
         gv_api_msg := gv_api_msg || lv_api_msg;

         ROLLBACK;

         fnd_file.put_line (fnd_file.LOG,
                            'Bank NOT Created! and rollback executed ' ||lv_api_msg
                           );
      ELSE
         p_branch_id := x_branch_id;
         gv_commit_flag := 'Y';

      END IF;            --if (x_return_status <>  fnd_api.g_ret_sts_success )
   END IF;                      --IF x_branch_id IS NULL and  l_bic = 'V' THEN

   EXCEPTION
WHEN OTHERS THEN
FND_FILE.PUT_LINE(FND_FILE.LOG,'+---------------------------------------------------------------------------+');
FND_FILE.PUT_LINE(FND_FILE.LOG,'Error -P_CREATE_BRANCH '||SQLCODE||' -ERROR- '||SQLERRM);
FND_FILE.PUT_LINE(FND_FILE.LOG,'+---------------------------------------------------------------------------+');
END P_CREATE_BRANCH;

PROCEDURE P_CREATE_BANK_ACCT (
   p_bank_id            IN       NUMBER,
   p_branch_id          IN       NUMBER,
   p_party_id           IN       NUMBER,
   p_account_name       IN       VARCHAR2,
   p_account_num        IN       VARCHAR2,
   p_territory_code     IN       VARCHAR,
   p_supp_site_id       IN       NUMBER,
   p_partysite_id       IN       NUMBER,
   p_account_id         OUT      NUMBER,
   p_iban               IN       VARCHAR2,
   p_check_digits       IN       VARCHAR2,
   p_ou_id              IN       NUMBER,
   p_priority           IN       NUMBER
)
IS
   l_bank_acct_rec          apps.iby_ext_bankacct_pub.extbankacct_rec_type;
   out_mesg                 apps.iby_fndcpt_common_pub.result_rec_type;
   l_acct                   NUMBER;
   l_assign                 apps.iby_fndcpt_setup_pub.pmtinstrassignment_tbl_type;
   l_payee_rec              apps.iby_disbursement_setup_pub.payeecontext_rec_type;
   l_return_status          VARCHAR2 (30);
   l_msg_count              NUMBER;
   l_msg_data               VARCHAR2 (3000);
   l_msg_dummy              VARCHAR2 (3000);
   l_output                 VARCHAR2 (3000);
   l_bank_id                NUMBER;
   l_branch_id              NUMBER;
   l_bank                   VARCHAR2 (1000);
   l_acct_owner_party_id    NUMBER;
   l_supplier_site_id       NUMBER;
   l_party_site_id          NUMBER;
   l_msg_index              NUMBER := 0;
   v_return_status          VARCHAR2 (20);
   v_msg_count              NUMBER;
   v_msg_data               VARCHAR2 (500);
   l_currency_code          VARCHAR2 (10);
   ln_partyid               NUMBER;
   ln_ext_bank_account_id   NUMBER;
   p_instrument             iby_fndcpt_setup_pub.pmtinstrument_rec_type;
   p_payee                  iby_disbursement_setup_pub.payeecontext_rec_type;
   l_assg_attr              iby_fndcpt_setup_pub.pmtinstrassignment_rec_type;
   l_assg_id                NUMBER;
   l_response               iby_fndcpt_common_pub.result_rec_type;
   l_joint_acct_owner_id    NUMBER;
   p_assignment_attribs     iby_fndcpt_setup_pub.pmtinstrassignment_rec_type;
   l_result_rec             iby_fndcpt_common_pub.result_rec_type;
   x_assign_id              NUMBER;
   x_return_status          VARCHAR2 (10);
   x_msg_count              NUMBER;
   x_msg_data               VARCHAR2 (256);
   x_response_rec           iby_fndcpt_common_pub.result_rec_type;
   l_error_flag             VARCHAR2 (1);
   l_error_msg              VARCHAR2 (2000);
   lv_api_msg               VARCHAR2 (2000);
   ln_msg_index_out         NUMBER := NULL;
   l_priority               NUMBER;
BEGIN

   fnd_global.apps_initialize (user_id           => fnd_global.user_id,
                               resp_id           => fnd_global.resp_id,
                               resp_appl_id      => fnd_global.resp_appl_id
                              );

   BEGIN
      ln_partyid := NULL;
      ln_ext_bank_account_id := NULL;
  fnd_file.put_line (fnd_file.LOG,'*1');

      SELECT MAX (ext_bank_account_id)
        INTO ln_ext_bank_account_id
        FROM iby_ext_bank_accounts
       WHERE bank_account_num = p_account_num
         AND country_code = p_territory_code
         AND bank_id = p_bank_id
         AND branch_id = p_branch_id
         AND end_date IS NULL;
   EXCEPTION
      WHEN OTHERS
      THEN
         NULL;
         ln_ext_bank_account_id := NULL;
   END;
  fnd_file.put_line (fnd_file.LOG,'ext_bank_account_id'||ln_ext_bank_account_id);

   IF ln_ext_bank_account_id IS NULL
   THEN
      l_bank_acct_rec.bank_id := p_bank_id;
      l_bank_acct_rec.branch_id := p_branch_id;
      l_bank_acct_rec.country_code := p_territory_code;
      l_bank_acct_rec.bank_account_name := p_account_name;
      l_bank_acct_rec.bank_account_num := p_account_num;
      l_bank_acct_rec.acct_owner_party_id := p_party_id;
      l_bank_acct_rec.currency := NULL;   -- BANK Account Currency Code is not required
      l_bank_acct_rec.object_version_number := 1.0;
      l_bank_acct_rec.start_date := SYSDATE;
      l_bank_acct_rec.iban := p_iban;
      l_bank_acct_rec.check_digits := p_check_digits;

      fnd_file.put_line (fnd_file.LOG,'Creating Bank Account.');
      apps.iby_ext_bankacct_pub.create_ext_bank_acct
                                     (p_api_version            => 1.0,
                                      p_init_msg_list          => fnd_api.g_true,
                                      p_ext_bank_acct_rec      => l_bank_acct_rec,
                                      p_association_level      => 'SS',
                                      p_supplier_site_id       => p_supp_site_id,
                                      p_party_site_id          => p_partysite_id,
                                      p_org_id                 => p_ou_id,
                                      p_org_type               => 'OPERATING_UNIT',
                                      x_acct_id                => l_acct,
                                      x_return_status          => l_return_status,
                                      x_msg_count              => l_msg_count,
                                      x_msg_data               => l_msg_data,
                                      x_response               => out_mesg
                                     );
      fnd_file.put_line (fnd_file.LOG,'Created.');

      IF (l_return_status <> fnd_api.g_ret_sts_success)
      THEN
         ln_msg_index_out := NULL;
            gv_commit_flag := 'N';
         FOR i IN 1 .. l_msg_count
         LOOP
            fnd_msg_pub.get (p_msg_index          => i,
                             p_data               => l_msg_data,
                             p_encoded            => 'F',
                             p_msg_index_out      => ln_msg_index_out
                            );
            fnd_message.set_encoded (l_msg_data);
            lv_api_msg :=
                  lv_api_msg
               || ' / '
               || ('Msg' || TO_CHAR (i) || ': ' || l_msg_data);
            fnd_file.put_line (fnd_file.LOG,
                                  'Error at bank_acct API : '
                               || i
                               || ', '
                               || l_msg_data
                              );
         END LOOP;

         ROLLBACK;

                  gv_api_msg := gv_api_msg || lv_api_msg;
         fnd_file.put_line (fnd_file.LOG,
                            'Bank Account NOT Created! and rollback executed'||lv_api_msg
                           );
      ELSE
         --COMMIT;
         p_account_id := l_acct;
            gv_commit_flag := 'Y';
         fnd_file.put_line (fnd_file.LOG, '--Account Created');
      END IF;            --if (l_return_status <>  fnd_api.g_ret_sts_success )
   ELSE
      BEGIN

         iby_ext_bankacct_pub.add_joint_account_owner
                             (p_api_version              => 1.0,
                              p_init_msg_list            => fnd_api.g_true,
                              p_bank_account_id          => ln_ext_bank_account_id,
                              p_acct_owner_party_id      => p_party_id,
                              x_joint_acct_owner_id      => l_joint_acct_owner_id,
                              x_return_status            => l_return_status,
                              x_msg_count                => l_msg_count,
                              x_msg_data                 => l_msg_data,
                              x_response                 => l_result_rec
                             );
         IF (l_return_status <> fnd_api.g_ret_sts_success)
         THEN
            ln_msg_index_out := NULL;
            gv_commit_flag := 'N';
            FOR i IN 1 .. l_msg_count
            LOOP
               fnd_msg_pub.get (p_msg_index          => i,
                                p_data               => l_msg_data,
                                p_encoded            => 'F',
                                p_msg_index_out      => ln_msg_index_out
                               );
               fnd_message.set_encoded (l_msg_data);
               lv_api_msg :=
                     lv_api_msg
                  || ' / '
                  || ('Msg' || TO_CHAR (i) || ': ' || l_msg_data);
               fnd_file.put_line (fnd_file.LOG,
                                     'Error at bank_acct API : '
                                  || i
                                  || ', '
                                  || l_msg_data
                                 );
            END LOOP;
         gv_api_msg := gv_api_msg || lv_api_msg;
            ROLLBACK;

            fnd_file.put_line
                            (fnd_file.LOG,
                             'Bank Account NOT Created! and rollback executed'||lv_api_msg
                            );
         ELSE
                gv_commit_flag := 'Y';
         END IF;         --if (l_return_status <>  fnd_api.g_ret_sts_success )
      END;

      IF l_return_status = fnd_api.g_ret_sts_success
      THEN
         IF p_priority IS NULL
         THEN
            BEGIN
               SELECT MAX (piu.order_of_preference) priority
                 INTO l_priority
                 FROM apps.ap_suppliers sup,
                      apps.ap_supplier_sites_all ss,
                      apps.ap_supplier_sites_all ss2,
                      apps.iby_external_payees_all epa,
                      apps.iby_pmt_instr_uses_all piu,
                      apps.iby_ext_bank_accounts eba
                WHERE sup.vendor_id = ss.vendor_id
                  AND ss.vendor_site_id = epa.supplier_site_id
                  AND ss2.vendor_id = sup.vendor_id
                  AND ss2.vendor_site_code = ss.vendor_site_code
                  AND epa.ext_payee_id = piu.ext_pmt_party_id
                  AND piu.instrument_id = eba.ext_bank_account_id
                  AND sup.party_id = p_party_id
                  AND ss.vendor_site_id = p_supp_site_id;
            EXCEPTION
               WHEN OTHERS
               THEN
                  fnd_file.put_line(fnd_file.LOG,'+---------------------------------------------------------------------------+');
                  fnd_file.put_line(fnd_file.LOG,'Error - priority '|| SQLCODE|| ' -ERROR- '|| SQLERRM);
                  fnd_file.put_line(fnd_file.LOG,'+---------------------------------------------------------------------------+');
            END;
         END IF;

         BEGIN
            p_payee.supplier_site_id         := p_supp_site_id;
            p_payee.party_id                 := p_party_id;
            p_payee.party_site_id             := p_partysite_id;
            p_payee.payment_function         := 'PAYABLES_DISB';
            p_payee.org_id                     := p_ou_id;
            p_payee.org_type                 := 'OPERATING_UNIT';
            p_instrument.instrument_id         := ln_ext_bank_account_id;
            p_instrument.instrument_type     := 'BANKACCOUNT';
            p_assignment_attribs.start_date := SYSDATE;
           -- p_assignment_attribs.priority     := NVL (p_priority, l_priority + 1);
            p_assignment_attribs.instrument := p_instrument;
            x_msg_count     := 0;
            x_msg_data         := NULL;
            x_return_status := NULL;
            x_response_rec     := NULL;
            iby_disbursement_setup_pub.set_payee_instr_assignment
                               (p_api_version             => 1.0,
                                p_init_msg_list           => fnd_api.g_true,
                                p_commit                  => fnd_api.g_true,
                                x_return_status           => x_return_status,
                                x_msg_count               => x_msg_count,
                                x_msg_data                => x_msg_data,
                                p_payee                   => p_payee,
                                p_assignment_attribs      => p_assignment_attribs,
                                x_assign_id               => x_assign_id,
                                x_response                => x_response_rec
                               );

            IF (x_return_status <> fnd_api.g_ret_sts_success)
            THEN
               ln_msg_index_out := NULL;
                gv_commit_flag := 'N';
               FOR i IN 1 .. x_msg_count
               LOOP
                  fnd_msg_pub.get (p_msg_index          => i,
                                   p_data               => x_msg_data,
                                   p_encoded            => 'F',
                                   p_msg_index_out      => ln_msg_index_out
                                  );
                  fnd_message.set_encoded (x_msg_data);
                  lv_api_msg :=
                        lv_api_msg
                     || ' / '
                     || ('Msg' || TO_CHAR (i) || ': ' || x_msg_data);
                  fnd_file.put_line
                              (fnd_file.LOG,
                                  'Error at SET_PAYEE_INSTR_ASSIGNMENT API : '
                               || i
                               || ', '
                               || x_msg_data
                              );
               END LOOP;
         gv_api_msg := gv_api_msg || lv_api_msg;

               ROLLBACK;
               fnd_file.put_line(fnd_file.LOG,'Bank Account NOT Created! and rollback executed'||lv_api_msg);
            ELSE
               p_account_id := ln_ext_bank_account_id;
                gv_commit_flag := 'Y';
         fnd_file.put_line (fnd_file.LOG, '--Account Attached to Site');
            END IF;      --if (x_return_status <>  fnd_api.g_ret_sts_success )
         EXCEPTION
            WHEN OTHERS
            THEN
                FND_FILE.PUT_LINE(FND_FILE.LOG,'+---------------------------------------------------------------------------+');
                FND_FILE.PUT_LINE(FND_FILE.LOG,'Error occurred during procedure P_CREATE_BANK_ACCT '||SQLCODE||' -ERROR- '||SQLERRM);
                FND_FILE.PUT_LINE(FND_FILE.LOG,'+---------------------------------------------------------------------------+');

               NULL;
         END;
      END IF;                 --IF l_return_status = fnd_api.g_ret_sts_success
   END IF;                               --IF ext_bank_account_id is NULL THEN


EXCEPTION
WHEN OTHERS THEN
FND_FILE.PUT_LINE(FND_FILE.LOG,'+---------------------------------------------------------------------------+');
FND_FILE.PUT_LINE(FND_FILE.LOG,'Error - P_CREATE_BANK_ACCT'||SQLCODE||' -ERROR- '||SQLERRM);
FND_FILE.PUT_LINE(FND_FILE.LOG,'+---------------------------------------------------------------------------+');

END P_CREATE_BANK_ACCT;

PROCEDURE P_END_EXT_BANK_ACCOUNTS(p_ext_bank_account_id IN NUMBER, p_party_id IN NUMBER, p_end_date IN DATE, p_supplier_site_id IN NUMBER, p_party_site_id IN NUMBER)
IS
  p_api_version        NUMBER;
  p_init_msg_list      VARCHAR2(200);
  p_ext_bank_acct_rec  apps.iby_ext_bankacct_pub.extbankacct_rec_type;
  lr_ex_bk_acnt        iby_ext_bank_accounts%ROWTYPE;
  x_return_status      VARCHAR2(200);
  x_msg_count          NUMBER;
  x_msg_data           VARCHAR2(200);
  x_response           apps.iby_fndcpt_common_pub.result_rec_type;
  lv_bank_acct_name    VARCHAR2(100);
  lv_new_bank_acct_num VARCHAR2(100);
  l_msg                VARCHAR2(200);
--BEGIN
  /*-- Initialize apps session
   fnd_global.apps_initialize (user_id           => fnd_global.user_id,
                               resp_id           => fnd_global.resp_id,
                               resp_appl_id      => fnd_global.resp_appl_id
                              );

    --input values

  -- get ext bank account details
  BEGIN
  FND_FILE.PUT_LINE(FND_FILE.LOG,'*1');
    SELECT *
      INTO lr_ex_bk_acnt
      FROM IBY_EXT_BANK_ACCOUNTS
     WHERE EXT_BANK_ACCOUNT_ID = p_ext_bank_account_id;
     FND_FILE.PUT_LINE(FND_FILE.LOG,'*2');
  EXCEPTION
    WHEN OTHERS THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Unable to derive the external bank details:' ||
                           SQLERRM);
  END;

  -- Assign API parameters
  p_api_version                             := 1.0;
  p_init_msg_list                           := fnd_api.g_true;
  p_ext_bank_acct_rec.bank_account_id       := lr_ex_bk_acnt.ext_bank_account_id;
  p_ext_bank_acct_rec.bank_account_num      := lr_ex_bk_acnt.bank_account_num;
  p_ext_bank_acct_rec.bank_account_name     := lr_ex_bk_acnt.bank_account_name;
  p_ext_bank_acct_rec.object_version_number := lr_ex_bk_acnt.object_version_number;
  p_ext_bank_acct_rec.end_date                := p_end_date;
 FND_FILE.PUT_LINE(FND_FILE.LOG,'ending bank account');
  iby_ext_bankacct_pub.update_ext_bank_acct(p_api_version       => p_api_version,
                                            p_init_msg_list     => p_init_msg_list,
                                            p_ext_bank_acct_rec => p_ext_bank_acct_rec,
                                            x_return_status     => x_return_status,
                                            x_msg_count         => x_msg_count,
                                            x_msg_data          => x_msg_data,
                                            x_response          => x_response);

  FND_FILE.PUT_LINE(FND_FILE.LOG,'X_RETURN_STATUS = ' || x_return_status);
  FND_FILE.PUT_LINE(FND_FILE.LOG,'X_MSG_COUNT = ' || x_msg_count);
  FND_FILE.PUT_LINE(FND_FILE.LOG,'X_MSG_DATA = ' || x_msg_data);

  IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
              gv_commit_flag := 'N';
    FOR i IN 1 .. fnd_msg_pub.count_msg LOOP
      l_msg := fnd_msg_pub.get(p_msg_index => i,
                               p_encoded   => fnd_api.g_false);
        FND_FILE.PUT_LINE(FND_FILE.LOG,'The API call failed with error ' || l_msg);
    END LOOP;
           gv_api_msg := gv_api_msg || l_msg;
  ELSE
        FND_FILE.PUT_LINE(FND_FILE.LOG,'The API call ended with SUCESSS status');
                gv_commit_flag := 'Y';
  END IF;*/

      xAssignID                     NUMBER;
    xReturnStatus                 VARCHAR2 ( 2000 );
    xMsgCount                     NUMBER ( 5 );
    xMsgData                      VARCHAR2 ( 2000 );
    pPayee                        IBY_DISBURSEMENT_SETUP_PUB.PAYEECONTEXT_REC_TYPE;
    pAssignmentAttribs            IBY_FNDCPT_SETUP_PUB.PMTINSTRASSIGNMENT_REC_TYPE;
    xResponse                     IBY_FNDCPT_COMMON_PUB.RESULT_REC_TYPE;
    pInstrument                   IBY_FNDCPT_SETUP_PUB.PMTINSTRUMENT_REC_TYPE;
    vInstrumentID                 NUMBER;
    vBankName                     VARCHAR2 ( 100 );
    vVendorName                   VARCHAR2 ( 100 );
    vSupplierPartyID              NUMBER;                          -- EXISTING SUPPLIERS/CUSTOMER PARTY_ID
    vBankID                       NUMBER;                   -- EXISTING BANK PARTY ID
    vBankBranchID                 NUMBER;                 -- EXISTING BRANCH PARTY ID
    vOBJECT_VERSION_NUMBER        NUMBER;
    ln_sup_org_id                NUMBER;
BEGIN

    -- SELECT EXISTING Branch PARTY ID to create Branch
    /*BEGIN
        SELECT bank_party_id, branch_party_id
          INTO vBankID, vBankBranchID
          FROM ce_bank_branches_v
         WHERE UPPER ( bank_name ) = UPPER ( vBankName );  -- Replace with your Bank Name
    EXCEPTION
        WHEN OTHERS
        THEN
            vBankID                 := 0;
            vBankBranchID           := 0;
            DBMS_OUTPUT.put_line(     'Exception while fetching Bank Branch Details '
                                    || SQLERRM
                                );
    END;*/

    -- SELECT EXISTING Supplier

    ln_sup_org_id:= NULL;
    vInstrumentID    := NULL;
    vOBJECT_VERSION_NUMBER    := NULL;
    vSupplierPartyID    := NULL;

    BEGIN
        SELECT ext_bank_account_id, OBJECT_VERSION_NUMBER
          INTO vInstrumentID, vOBJECT_VERSION_NUMBER
          FROM iby_ext_bank_accounts
         WHERE EXT_BANK_ACCOUNT_ID = p_ext_bank_account_id;
          FND_FILE.PUT_LINE(FND_FILE.LOG,'vInstrumentID '||vInstrumentID);
    EXCEPTION
        WHEN OTHERS
        THEN
            vInstrumentID                  := 0;
            FND_FILE.PUT_LINE(FND_FILE.LOG,
                                          'Exception while fetching Supplier Details '
                                        || SQLERRM
                                     );
    END;

    -- SELECT EXISTING Supplier
    BEGIN
        SELECT party_id
          INTO vSupplierPartyID
          FROM ap_suppliers
         WHERE party_id = p_party_id;    -- Replace with your Supplier Name
         FND_FILE.PUT_LINE(FND_FILE.LOG,'vSupplierPartyID '||vSupplierPartyID);
    EXCEPTION
        WHEN OTHERS
        THEN
            vSupplierPartyID              := 0;
            FND_FILE.PUT_LINE(FND_FILE.LOG,    'Exception while fetching Supplier Details '
                                        || SQLERRM
                                     );
    END;

             SELECT org_id
            INTO ln_sup_org_id
            FROM ap_supplier_sites_all
            WHERE VENDOR_SITE_ID= p_supplier_site_id;

FND_FILE.PUT_LINE(FND_FILE.LOG,'p_supplier_site_id '||p_supplier_site_id||' p_party_site_id '||p_party_site_id);
    pInstrument.instrument_type    := 'BANKACCOUNT';
    pInstrument.instrument_id      := vInstrumentID;
    --pAssignmentAttribs.start_date  := SYSDATE;
     pAssignmentAttribs.end_date  := p_end_date;
    pAssignmentAttribs.instrument  := pInstrument;
    pPayee.party_id                := vSupplierPartyID;
    pPayee.Supplier_Site_id          := p_supplier_site_id;
    pPayee.Party_Site_id        := p_party_site_id;
    pPayee.org_id              := ln_sup_org_id;
    pPayee.org_type           := 'OPERATING_UNIT';
    --pInstrument.OBJECT_VERSION_NUMBER    := vOBJECT_VERSION_NUMBER;
  -- EXISTING SUPPLIERS/CUSTOMER PARTY_ID -- which is party_id of the supplier
    pPayee.payment_function        := 'PAYABLES_DISB';
     FND_FILE.PUT_LINE(FND_FILE.LOG,'Supplier Bank End starts');

    IBY_DISBURSEMENT_SETUP_PUB.SET_PAYEE_INSTR_ASSIGNMENT
                            ( p_api_version                  => 1.0
                             ,p_init_msg_list                => fnd_api.g_false
                             ,p_commit                       => fnd_api.g_true
                             ,x_return_status                => xReturnStatus
                             ,x_msg_count                    => xMsgCount
                             ,x_msg_data                     => xMsgData
                             ,p_payee                        => pPayee
                             ,p_assignment_attribs           => pAssignmentAttribs
                             ,x_assign_id                    => xAssignID
                             ,x_response                     => xResponse
                            );
                           -- commit;
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'xReturnStatus             :' || xReturnStatus );
    --FND_FILE.PUT_LINE(FND_FILE.LOG, 'xResponse.Result_Code     :' || xResponse.result_code );
   --FND_FILE.PUT_LINE(FND_FILE.LOG, 'xResponse.Result_Category :' || xResponse.result_category);
    --FND_FILE.PUT_LINE(FND_FILE.LOG, 'xResponse.Result_Message  :' || xResponse.result_message);

    IF xReturnStatus = fnd_api.g_ret_sts_success
    THEN
     gv_commit_flag := 'Y';
         FND_FILE.PUT_LINE(FND_FILE.LOG,'Supplier Bank End : '||xResponse.result_code);
    ELSE
        IF xMsgCount > 1
        THEN
            gv_commit_flag := 'N';
            FOR i IN 1 .. xMsgCount
            LOOP
      l_msg := fnd_msg_pub.get(p_msg_index => i,
                               p_encoded   => fnd_api.g_false);
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Bank End API call failed with error ' || l_msg);

            END LOOP;

           gv_api_msg := gv_api_msg || l_msg;
        END IF;

        ROLLBACK;
    END IF;
EXCEPTION
    WHEN OTHERS
    THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'P_END_EXT_BANK_ACCOUNTS Error..' || SQLERRM );

END P_END_EXT_BANK_ACCOUNTS;

PROCEDURE P_UDA (
   ln_party_id            IN   NUMBER,
   lv_attr_group_name     IN   VARCHAR2,
   lv_attr_display_name   IN   VARCHAR2,
   ln_attr_value_str1     IN   VARCHAR2,
   ln_attr_value_str2     IN   VARCHAR2,
   p_data_level           IN   VARCHAR2,
   p_data_level_1         IN   NUMBER,
   p_data_level_2         IN   NUMBER
)
IS
   ln_attr_num                    NUMBER                        := NULL;
   ln_msg_index_out               NUMBER                        := NULL;
   lv_failed_row_id_list          VARCHAR2 (100)                := NULL;
   ldt_attr_date                  DATE                          := NULL;
   ln_attr_value_str              VARCHAR2 (50)                 := NULL;
   lv_pk_column_values            ego_col_name_value_pair_array := ego_col_name_value_pair_array();
   lv_attributes_row_table        ego_user_attr_row_table;
   lv_attributes_row_table1       ego_user_attr_row_table;
   lv_attributes_data_table       ego_user_attr_data_table;
   lv_attributes_data_table1      ego_user_attr_data_table;
   lv_class_code                  ego_col_name_value_pair_array := ego_col_name_value_pair_array();
   l_pk_column_name_value_pairs   ego_col_name_value_pair_array := ego_col_name_value_pair_array();
   lv_return_status               VARCHAR2 (10)                 := NULL;
   ln_msg_count                   NUMBER                        := 0;
   lv_msg_data                    VARCHAR2 (1000)               := NULL;
   ln_errorcode                   NUMBER                        := 0;
   lv_attr_name                   VARCHAR2 (50);
   lv_attr_group_id               NUMBER;
   l_data_level_1                 NUMBER;
   l_data_level_2                 NUMBER;
   l_vendor_id                       NUMBER;
   l_vendor_site_id                  NUMBER;
   l_party_site_id                  NUMBER;
   l_ego_col_name                  VARCHAR2 (30);
   l_extension_id            NUMBER;
   l_c_ext_attr1             VARCHAR2 (30);
   l_c_ext_attr2             VARCHAR2 (30);
  l_msg                VARCHAR2(200);

BEGIN
   fnd_global.apps_initialize (user_id           => fnd_global.user_id,
                               resp_id           => fnd_global.resp_id,
                               resp_appl_id      => fnd_global.resp_appl_id
                              );
l_extension_id    := NULL;
l_c_ext_attr1    := NULL;
l_c_ext_attr2    := NULL;

   BEGIN
      SELECT egoattributeeo.attr_name, ext.attr_group_id
        INTO lv_attr_name, lv_attr_group_id
        FROM ego_attrs_v egoattributeeo, ego_fnd_dsc_flx_ctx_ext ext
       WHERE egoattributeeo.application_id = ext.application_id
         AND egoattributeeo.attr_group_type = ext.descriptive_flexfield_name
         AND egoattributeeo.attr_group_name = ext.descriptive_flex_context_code
         AND egoattributeeo.application_id = 177
         AND egoattributeeo.attr_group_type = 'POS_SUPP_PROFMGMT_GROUP'
         AND egoattributeeo.attr_group_name = lv_attr_group_name
         AND egoattributeeo.attr_display_name = lv_attr_display_name;
           fnd_file.put_line(fnd_file.LOG,'lv_attr_group_id '||lv_attr_group_id||' lv_attr_name '||lv_attr_name);
   EXCEPTION
      WHEN OTHERS
      THEN
         fnd_file.put_line(fnd_file.LOG,'+---------------------------------------------------------------------------+');
         fnd_file.put_line (fnd_file.LOG,
                               'lv_attr_group_name '
                            || lv_attr_group_name
                            || ' lv_attr_display_name '
                            || lv_attr_display_name
                           );
         fnd_file.put_line (fnd_file.LOG,
                               'Error at ego_attrs_v '
                            || SQLCODE
                            || ' -ERROR- '
                            || SQLERRM
                           );
         fnd_file.put_line(fnd_file.LOG,'+---------------------------------------------------------------------------+');
   END;



   lv_pk_column_values.EXTEND (1);
   lv_pk_column_values (1) :=
                         ego_col_name_value_pair_obj ('PARTY_ID', ln_party_id);
   lv_class_code.EXTEND (1);
   lv_class_code (1) :=
                ego_col_name_value_pair_obj ('CLASSIFICATION_CODE', 'BS:BASE');
--
IF lv_attr_group_name = 'XXAH_COUPA_CONTENT'
   THEN

            IF ln_attr_value_str1 IS NOT NULL AND ln_attr_value_str2 IS NOT NULL THEN
      lv_attributes_data_table :=
         ego_user_attr_data_table
            (ego_user_attr_data_obj
                                  (row_identifier            => 1,
                                   attr_name                 => 'XXAH_COUPA_CONTENT',
                                   attr_value_str            => TRIM(ln_attr_value_str1),
                                   attr_value_num            => NULL,
                                   attr_value_date           => NULL,
                                   attr_disp_value           => NULL,
                                   attr_unit_of_measure      => NULL,
                                   user_row_identifier       => 1
                                  ),
             ego_user_attr_data_obj (row_identifier            => 1,
                                     attr_name                 => 'XXAH_LEAF_COMM',
                                     attr_value_str            => ln_attr_value_str2,
                                     attr_value_num            => ln_attr_num,
                                     attr_value_date           => ldt_attr_date,
                                     attr_disp_value           => NULL,
                                     attr_unit_of_measure      => NULL,
                                     user_row_identifier       => 1
                                    )
            );
            ELSIF ln_attr_value_str1 IS NOT NULL AND ln_attr_value_str2 IS  NULL THEN

                lv_attributes_data_table :=
         ego_user_attr_data_table
            (ego_user_attr_data_obj
                                  (row_identifier            => 1,
                                   attr_name                 => 'XXAH_COUPA_CONTENT',
                                   attr_value_str            => TRIM(ln_attr_value_str1),
                                   attr_value_num            => NULL,
                                   attr_value_date           => NULL,
                                   attr_disp_value           => NULL,
                                   attr_unit_of_measure      => NULL,
                                   user_row_identifier       => 1
                                  ));
                    ELSIF ln_attr_value_str1 IS  NULL AND ln_attr_value_str2 IS NOT NULL THEN
                      lv_attributes_data_table :=
         ego_user_attr_data_table
            (   ego_user_attr_data_obj (row_identifier            => 1,
                                     attr_name                 => 'XXAH_LEAF_COMM',
                                     attr_value_str            => ln_attr_value_str2,
                                     attr_value_num            => ln_attr_num,
                                     attr_value_date           => ldt_attr_date,
                                     attr_disp_value           => NULL,
                                     attr_unit_of_measure      => NULL,
                                     user_row_identifier       => 1
                                    )
            );
END IF;
   END IF;


   --
      IF lv_attr_group_name = 'XXAH_REMIT_TO_SUPP'
   THEN

   BEGIN
       select asa.vendor_id, assa.vendor_site_id , assa.party_site_id
            into l_vendor_id, l_vendor_site_id , l_party_site_id
        from ap_suppliers asa,
            ap_supplier_sites_all assa
    where asa.vendor_id = assa.vendor_id
            AND    asa.vendor_name = ln_attr_value_str1
            AND assa.vendor_site_code = ln_attr_value_str2;
EXCEPTION
WHEN OTHERS THEN
FND_FILE.PUT_LINE(FND_FILE.LOG,'Error - XXAH_REMIT_TO_SUPP '||SQLCODE||' -ERROR- '||SQLERRM);
END;
FND_FILE.PUT_LINE(FND_FILE.LOG,'Remit_To_Supplier '||l_vendor_id||' Remit_To_Supp_Site  '||l_vendor_site_id||' party_id ' ||ln_party_id);
      lv_attributes_data_table :=
         ego_user_attr_data_table
            (ego_user_attr_data_obj
                                  (row_identifier            => 1,
                                   attr_name                 => 'Remit_To_Supplier',
                                   attr_value_str            => l_vendor_id,--ln_attr_value_str,--TRIM(ln_attr_value_str1),
                                   attr_value_num            => NULL,
                                   attr_value_date           => NULL,
                                   attr_disp_value           => NULL,
                                   attr_unit_of_measure      => NULL,
                                   user_row_identifier       => 1
                                  ),
             ego_user_attr_data_obj (row_identifier            => 1,
                                     attr_name                 => 'Remit_To_Supp_Site',
                                     attr_value_str            => l_vendor_site_id,--ln_attr_value_str2,
                                     attr_value_num            => NULL,
                                     attr_value_date           => NULL,
                                     attr_disp_value           => NULL,
                                     attr_unit_of_measure      => NULL,
                                     user_row_identifier       => 1
                                    ),
                         ego_user_attr_data_obj (row_identifier => 1,
                                     attr_name                 => 'From_Date',
                                     attr_value_str            => NULL,
                                     attr_value_num            => NULL,
                                     attr_value_date           => trunc(sysdate),
                                     attr_disp_value           => NULL,
                                     attr_unit_of_measure      => NULL,
                                     user_row_identifier       => 1
                                    )
            );
            FND_FILE.PUT_LINE(FND_FILE.LOG,'COMPLETE Remit_To_Supplier');
   END IF;
   --
--

   IF lv_attr_group_name = 'XXAH_Supplier_Type'
   THEN
      lv_attributes_data_table :=
         ego_user_attr_data_table
            (ego_user_attr_data_obj
                                  (row_identifier            => 1,
                                   attr_name                 => lv_attr_name,
                                   attr_value_str            => TRIM(ln_attr_value_str1),
                                   attr_value_num            => NULL,
                                   attr_value_date           => NULL,
                                   attr_disp_value           => NULL,
                                   attr_unit_of_measure      => NULL,
                                   user_row_identifier       => 1
                                  )
            );
   END IF;


    IF lv_attr_group_name = 'XXAH_PSFT_Intercompany'
   THEN
   fnd_file.put_line(fnd_file.LOG,'Before API XXAH_PSFT_Intercompany '||ln_attr_value_str1);
      lv_attributes_data_table :=
         ego_user_attr_data_table
            (ego_user_attr_data_obj
                                  (row_identifier            => 1,
                                   attr_name                 => 'XXAH_PeopleSoft_INT',
                                   attr_value_str            => TRIM(ln_attr_value_str1),
                                   attr_value_num            => NULL,
                                   attr_value_date           => NULL,
                                   attr_disp_value           => NULL,
                                   attr_unit_of_measure      => NULL,
                                   user_row_identifier       => 1
                                  )
            );
   END IF;


   IF lv_attr_group_name = 'XXAH_STD_QUAL_SUPP'
   THEN

   SELECT psp.EXTENSION_ID, psp.C_EXT_ATTR1
   into l_extension_id, l_c_ext_attr1
  FROM APPS.pos_supp_prof_ext_b psp,
       APPS.ego_attr_groups_v egv,
       EGO.EGO_DATA_LEVEL_B edl
 WHERE     c_ext_attr1 IS NOT NULL
       --and c_ext_attr2 is not null
       AND psp.ATTR_GROUP_ID = egv.ATTR_GROUP_ID
       AND psp.DATA_LEVEL_ID = edl.DATA_LEVEL_ID
       AND edl.DATA_LEVEL_NAME = 'SUPP_LEVEL'
       AND psp.last_update_date IS NOT NULL
       AND psp.party_id = ln_party_id
       AND psp.ATTR_GROUP_ID = lv_attr_group_id
       AND psp.C_EXT_ATTR1 = TRIM(ln_attr_value_str1);

       fnd_file.put_line(fnd_file.LOG,'l_extension_id '||l_extension_id||'  l_c_ext_attr1 '||l_c_ext_attr1||' ln_attr_value_str2 '||ln_attr_value_str2);

BEGIN
       select C_EXT_ATTR2
        into l_c_ext_attr2
        from pos_supp_prof_ext_b
       where EXTENSION_ID = l_extension_id
       AND C_EXT_ATTR2 = ln_attr_value_str2 ;
   EXCEPTION
      WHEN OTHERS
      THEN
        l_c_ext_attr2    := NULL;
END;

              fnd_file.put_line(fnd_file.LOG,'l_c_ext_attr2 '||l_c_ext_attr2);

       IF l_c_ext_attr2 IS NULL THEN

      lv_attributes_data_table :=
         ego_user_attr_data_table
            (ego_user_attr_data_obj
                                  (row_identifier            => 1,
                                   attr_name                 => 'XXAH_REG_TYPE',
                                   attr_value_str            => TRIM(ln_attr_value_str1),
                                   attr_value_num            => NULL,
                                   attr_value_date           => NULL,
                                   attr_disp_value           => NULL,
                                   attr_unit_of_measure      => NULL,
                                   user_row_identifier       => 1
                                  ),
             ego_user_attr_data_obj
                   (row_identifier            => 1,
                    attr_name                 => 'XXAH_REG_NUM',
                    attr_value_str            => ln_attr_value_str2,
                    attr_value_num            => ln_attr_num,
                    attr_value_date           => ldt_attr_date,
                    attr_disp_value           => NULL,
                    attr_unit_of_measure      => NULL,
                    user_row_identifier       => 1
                   )
            );
            END IF;
   END IF;

   ------------------------------RFC-027 --------------
   IF lv_attr_group_name = 'XXAH_STD_QUAL_SITE'
   THEN
                 fnd_file.put_line(fnd_file.LOG,'updating Registration Numbers site level'||ln_attr_value_str1||'/'||ln_attr_value_str2);
                 FND_FILE.PUT_LINE(FND_FILE.LOG,' party_id ' ||ln_party_id);
      lv_attributes_data_table :=
         ego_user_attr_data_table
            (ego_user_attr_data_obj
                                  (row_identifier            => 1,
                                   attr_name                 => 'XXAH_REG_TYPE_SITE',
                                   attr_value_str            => TRIM(ln_attr_value_str1),
                                   attr_value_num            => NULL,
                                   attr_value_date           => NULL,
                                   attr_disp_value           => NULL,
                                   attr_unit_of_measure      => NULL,
                                   user_row_identifier       => 1
                                  ),
             ego_user_attr_data_obj
                   (row_identifier            => 1,
                    attr_name                 => 'XXAH_REG_NUM_SITE',
                    attr_value_str            => ln_attr_value_str2,
                    attr_value_num            => ln_attr_num,
                    attr_value_date           => ldt_attr_date,
                    attr_disp_value           => NULL,
                    attr_unit_of_measure      => NULL,
                    user_row_identifier       => 1
                   )
            );
            fnd_file.put_line(fnd_file.LOG,'--END updating Registration Numbers--');
   END IF;
   ------------------------------RFC 027 --------------

   lv_attributes_row_table :=
      ego_user_attr_row_table
         (ego_user_attr_row_obj
                    (row_identifier         => 1,
                     attr_group_id          => lv_attr_group_id,
                     attr_group_app_id      => 177,
                     attr_group_type        => 'POS_SUPP_PROFMGMT_GROUP',
                     attr_group_name        => lv_attr_group_name,
                     data_level             => p_data_level,
                     data_level_1           => 'N',
                     data_level_2           => p_data_level_1,
                     data_level_3           => p_data_level_2,
                     data_level_4           => NULL,
                     data_level_5           => NULL,
                     transaction_type       => ego_user_attrs_data_pvt.g_update_mode
                    )
         );
   --Supplier uda updation started
   pos_vendor_pub_pkg.process_user_attrs_data
                         (p_api_version                      => 1.0,
                          p_attributes_row_table             => lv_attributes_row_table,
                          p_attributes_data_table            => lv_attributes_data_table,
                          p_pk_column_name_value_pairs       => lv_pk_column_values,
                          p_class_code_name_value_pairs      => lv_class_code,
                          x_failed_row_id_list               => lv_failed_row_id_list,
                          x_return_status                    => lv_return_status,
                          x_errorcode                        => ln_errorcode,
                          x_msg_count                        => ln_msg_count,
                          x_msg_data                         => lv_msg_data
                         );

   IF lv_return_status = fnd_api.g_ret_sts_success
   THEN
        gv_commit_flag := 'Y';
        commit;
                 FND_FILE.PUT_LINE(FND_FILE.LOG,'UDA updated '|| lv_attr_group_name);
   ELSE
      fnd_file.put_line (fnd_file.LOG,'Error Message UDA Data  : ' || lv_msg_data);


      FOR i IN 1 .. ln_msg_count
      LOOP
         fnd_msg_pub.get (p_msg_index          => i,
                          p_data               => lv_msg_data,
                          p_encoded            => 'F',
                          p_msg_index_out      => ln_msg_index_out
                         );
         fnd_message.set_encoded (lv_msg_data);

         fnd_file.put_line (fnd_file.LOG,
                            'Inside Error Loop P_UDA : ' || i || ', ' || lv_msg_data
                           );
      END LOOP;
gv_commit_flag := 'N';
       gv_api_msg := gv_api_msg || lv_msg_data;
      ROLLBACK;
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
FND_FILE.PUT_LINE(FND_FILE.LOG,'+---------------------------------------------------------------------------+');
FND_FILE.PUT_LINE(FND_FILE.LOG,'Error -P_UDA '||SQLCODE||' -ERROR- '||SQLERRM);
FND_FILE.PUT_LINE(FND_FILE.LOG,'+---------------------------------------------------------------------------+');
      ROLLBACK;
END P_UDA;

PROCEDURE P_TAX_CLASSIFICATION(    lv_PARTY_ID IN NUMBER,
                                lv_vat_registration_num    IN VARCHAR2,
                                lv_TAX_CLASSIFICATION_CODE IN VARCHAR2 )
IS

 l_party_tax_profile_id zx_party_tax_profile.party_tax_profile_id%type;
 l_return_status VARCHAR2(1);
 l_debug_info                  VARCHAR2(500);
   l_msg_count      NUMBER;
  l_msg_data       VARCHAR2(2000);
       ln_msg_index_out               NUMBER                        := NULL;
     l_api_msg VARCHAR2(2000);
l_tax_classification_code    ZX_PARTY_TAX_PROFILE.TAX_CLASSIFICATION_CODE%TYPE;
l_rep_registration_number    ZX_PARTY_TAX_PROFILE.rep_registration_number%TYPE;
l_update_tax        VARCHAR2(1);

 BEGIN
    L_PARTY_TAX_PROFILE_ID         := NULL;
    l_tax_classification_code    := NULL;
    l_update_tax                := NULL;
    l_rep_registration_number    := NULL;
FND_FILE.PUT_LINE(FND_FILE.LOG,'Tax Classification code/vat_registration_num');


       BEGIN

       SELECT --PROCESS_FOR_APPLICABILITY_FLAG, ALLOW_OFFSET_TAX_FLAG,
       TAX_CLASSIFICATION_CODE,
       REP_REGISTRATION_NUMBER,
           PARTY_TAX_PROFILE_ID
         INTO --l_auto_tax_calc_flag,l_offset_tax_flag,
         l_tax_classification_code,
         l_rep_registration_number,
           l_party_tax_profile_id
            FROM ZX_PARTY_TAX_PROFILE
            WHERE PARTY_ID = lv_PARTY_ID
            AND PARTY_TYPE_CODE = 'THIRD_PARTY'
            AND ROWNUM = 1;

          EXCEPTION
            WHEN OTHERS THEN
               L_PARTY_TAX_PROFILE_ID := NULL;

               FND_FILE.PUT_LINE(FND_FILE.LOG,'No data returned from ZX_PARTY_TAX_PROFILE for party_id = '||lv_party_id);
       END;

       IF lv_tax_classification_code IS NOT NULL AND lv_tax_classification_code <> nvl(l_tax_classification_code,'X') THEN
            l_update_tax := 'Y';
       END IF;

       IF lv_vat_registration_num IS NOT NULL AND lv_vat_registration_num <>  nvl(l_rep_registration_number,'X') THEN
            l_update_tax := 'Y';
       END IF;
       FND_FILE.PUT_LINE(FND_FILE.LOG,'l_update_tax '||l_update_tax);
IF L_PARTY_TAX_PROFILE_ID IS NOT NULL AND l_update_tax = 'Y' THEN

FND_FILE.PUT_LINE(FND_FILE.LOG,'P_TAX_CLASSIFICATION_CODE : '||lv_TAX_CLASSIFICATION_CODE);
FND_FILE.PUT_LINE(FND_FILE.LOG,'L_PARTY_TAX_PROFILE_ID : '||L_PARTY_TAX_PROFILE_ID);
FND_FILE.PUT_LINE(FND_FILE.LOG,'P_REP_REGISTRATION_NUMBER : '||lv_vat_registration_num);

          ZX_PARTY_TAX_PROFILE_PKG.update_row (
          P_PARTY_TAX_PROFILE_ID => L_PARTY_TAX_PROFILE_ID,
           P_COLLECTING_AUTHORITY_FLAG => null,
           P_PROVIDER_TYPE_CODE => null,
           P_CREATE_AWT_DISTS_TYPE_CODE => null,
           P_CREATE_AWT_INVOICES_TYPE_COD => null,
           P_TAX_CLASSIFICATION_CODE => nvl(lv_tax_classification_code, l_tax_classification_code),
           P_SELF_ASSESS_FLAG => null,
           P_ALLOW_OFFSET_TAX_FLAG => null,
           P_REP_REGISTRATION_NUMBER => nvl(lv_vat_registration_num, l_rep_registration_number),
           P_EFFECTIVE_FROM_USE_LE => null,
           P_RECORD_TYPE_CODE => null,
           P_REQUEST_ID => null,
           P_ATTRIBUTE1 => null,
           P_ATTRIBUTE2 => null,
           P_ATTRIBUTE3 => null,
           P_ATTRIBUTE4 => null,
           P_ATTRIBUTE5 => null,
           P_ATTRIBUTE6 => null,
           P_ATTRIBUTE7 => null,
           P_ATTRIBUTE8 => null,
           P_ATTRIBUTE9 => null,
           P_ATTRIBUTE10 => null,
           P_ATTRIBUTE11 => null,
           P_ATTRIBUTE12 => null,
           P_ATTRIBUTE13 => null,
           P_ATTRIBUTE14 => null,
           P_ATTRIBUTE15 => null,
           P_ATTRIBUTE_CATEGORY => null,
           P_PARTY_ID => lv_PARTY_ID,
           P_PROGRAM_LOGIN_ID => null,
           P_PARTY_TYPE_CODE => null,
           P_SUPPLIER_FLAG => null,
           P_CUSTOMER_FLAG => null,
           P_SITE_FLAG => null,
           P_PROCESS_FOR_APPLICABILITY_FL => null,
           P_ROUNDING_LEVEL_CODE => null,
           P_ROUNDING_RULE_CODE => null,
           P_WITHHOLDING_START_DATE => null,
           P_INCLUSIVE_TAX_FLAG => null,
           P_ALLOW_AWT_FLAG => null,
           P_USE_LE_AS_SUBSCRIBER_FLAG => null,
           P_LEGAL_ESTABLISHMENT_FLAG => null,
           P_FIRST_PARTY_LE_FLAG => null,
           P_REPORTING_AUTHORITY_FLAG => null,
           X_RETURN_STATUS => l_return_status,
           P_REGISTRATION_TYPE_CODE => null,
           P_COUNTRY_CODE => null
           );
           --commit;
  FND_FILE.PUT_LINE(FND_FILE.LOG,'--TAX_CLASSIFICATION_CODE => '||l_return_status);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
          ROLLBACK;
        gv_commit_flag := 'N';
    END IF;
END IF;

EXCEPTION
   WHEN OTHERS
   THEN
      ROLLBACK;
FND_FILE.PUT_LINE(FND_FILE.LOG,'+---------------------------------------------------------------------------+');
FND_FILE.PUT_LINE(FND_FILE.LOG,'Error -P_TAX_CLASSIFICATION '||SQLCODE||' -ERROR- '||SQLERRM);
FND_FILE.PUT_LINE(FND_FILE.LOG,'+---------------------------------------------------------------------------+');

end P_TAX_CLASSIFICATION;


PROCEDURE P_CREATE_EMAIL_CONTACT_POINT( p_party_site_id IN NUMBER, p_email_address IN VARCHAR2 )
IS
p_contact_point_rec             hz_contact_point_v2pub.contact_point_rec_type;
    p_email_rec                   hz_contact_point_v2pub.email_rec_type;
    x_contact_point_id            NUMBER;
    x_return_status                 VARCHAR2(200);
    x_msg_count                    NUMBER;
    x_msg_data                      VARCHAR2(200);
    l_email_address        hz_contact_points.EMAIL_ADDRESS%TYPE;
    l_obj_num            hz_contact_points.object_version_number%TYPE;
    l_phone_rec     hz_contact_points.PHONE_NUMBER%TYPE;
    l_contact_point_id    hz_contact_points.contact_point_id%TYPE;

begin

    BEGIN
     l_email_address    := NULL;
     l_obj_num             := NULL;
     l_contact_point_id    := NULL;
      FND_FILE.PUT_LINE(FND_FILE.LOG,'**14');

    SELECT CONTACT_POINT_ID, EMAIL_ADDRESS, object_version_number into l_contact_point_id, l_email_address, l_obj_num
      FROM hz_contact_points
     WHERE     owner_table_id = p_party_site_id
           AND owner_table_name = 'HZ_PARTY_SITES'
           AND primary_flag = 'Y'
           AND status = 'A';
           --AND EMAIL_ADDRESS = p_email_address;
           EXCEPTION
       WHEN OTHERS   THEN
       l_email_address    := NULL;
    END;
      FND_FILE.PUT_LINE(FND_FILE.LOG,'**15');
      FND_FILE.PUT_LINE(FND_FILE.LOG,'l_email_address '||l_email_address);

  p_contact_point_rec.owner_table_id        := p_party_site_id;
  p_email_rec.email_address                 := p_email_address;
  p_contact_point_rec.contact_point_type    := 'EMAIL';
  p_contact_point_rec.owner_table_name      := 'HZ_PARTY_SITES';
  p_email_rec.email_format                  := 'MAILTEXT';
      FND_FILE.PUT_LINE(FND_FILE.LOG,'**16');


   IF l_email_address IS NULL THEN
     p_contact_point_rec.created_by_module     := 'HZ_CPUI';
        fnd_file.put_line (fnd_file.LOG, 'p_party_site_id '||p_party_site_id||' p_email_address '||p_email_address);
            fnd_file.put_line (fnd_file.LOG,'Creating Contact Details  Email ');

hz_contact_point_v2pub.create_email_contact_point (
   'T',
    p_contact_point_rec        ,
    p_email_rec                ,
    x_contact_point_id         ,
    x_return_status            ,
    x_msg_count                ,
    x_msg_data
  );
    fnd_file.put_line (fnd_file.LOG, 'x_msg_count '||x_msg_count||' x_return_status '||x_return_status);

    ELSIF l_email_address <> p_email_address THEN

      p_contact_point_rec.contact_point_id      := l_contact_point_id;

    fnd_file.put_line (fnd_file.LOG,'Updating Contact Details  Email ');
     HZ_CONTACT_POINT_V2PUB.update_email_contact_point
  (        'T'
  , p_contact_point_rec
  , p_email_rec
  , l_obj_num
  , x_return_status
  , x_msg_count
  , x_msg_data
  );

    END IF;

   IF (x_return_status = fnd_api.g_ret_sts_success) THEN
    COMMIT;

ELSif x_msg_count >= 1 THEN
    ROLLBACK;
    FOR i IN 1 .. x_msg_count
    LOOP
      x_msg_data := fnd_msg_pub.get( p_msg_index => i, p_encoded => 'F');
      fnd_file.put_line (fnd_file.LOG, i|| ' - '|| x_msg_data);
    END LOOP;
END IF;
END P_CREATE_EMAIL_CONTACT_POINT;

PROCEDURE ADDRESS_STATUS(p_party_site_id IN NUMBER, p_status IN VARCHAR2)
IS
  l_party_site_rec hz_party_site_v2pub.PARTY_SITE_REC_TYPE;
  l_obj_num        NUMBER;
  l_return_status  VARCHAR2(1);
  l_msg_count      NUMBER;
  l_msg_data       VARCHAR2(2000);
BEGIN
  l_party_site_rec.party_site_id            := p_party_site_id;
  l_party_site_rec.status := p_status;
  l_obj_num                                 :=  NULL;
  FND_FILE.PUT_LINE(FND_FILE.LOG,'p_party_site_id '||p_party_site_id);

  select object_version_number
  into l_obj_num
  from HZ_PARTY_SITES
  where PARTY_SITE_ID = p_party_site_id;

  FND_FILE.PUT_LINE(FND_FILE.LOG,'l_obj_num '||l_obj_num);

  hz_party_site_v2pub.update_party_site
  ( p_init_msg_list         =>  FND_API.G_FALSE
  , p_party_site_rec        =>  l_PARTY_SITE_REC
  , p_object_version_number => l_obj_num
  , x_return_status         => l_return_status
  , x_msg_count             => l_msg_count
  , x_msg_data              => l_msg_data
  ) ;
  commit;
 FND_FILE.PUT_LINE(FND_FILE.LOG,'Ret Status:' || l_return_status);
END;


PROCEDURE Val_Currency_Code(p_currency_code IN         VARCHAR2,
                            x_valid         OUT NOCOPY BOOLEAN
                            )
IS
  l_count          NUMBER := 0;

BEGIN
  x_valid := TRUE;

  IF p_currency_code IS NOT NULL THEN
     SELECT COUNT(*)
     INTO   l_count
     FROM   fnd_currencies_vl
     WHERE  currency_code = p_currency_code
     AND    enabled_flag = 'Y'
     AND    currency_flag = 'Y'
     AND    TRUNC(NVL(start_date_active, SYSDATE)) <= TRUNC(SYSDATE)
     AND    TRUNC(NVL(end_date_active, SYSDATE))>= TRUNC(SYSDATE);

     IF l_count < 1 THEN
    x_valid    := FALSE;
     END IF;
   END IF;

END Val_Currency_Code;

PROCEDURE p_write_log ( p_row_id VARCHAR2, p_message IN VARCHAR2 )
IS
  PRAGMA autonomous_transaction;
BEGIN
FND_FILE.put_line(FND_FILE.LOG,'Executing   PRAGMA autonomous_transaction!!');

  UPDATE xxah_ps_ebs_supp_bank_update
  SET    conversion_status = 'E' ,
         error_log = p_message
  WHERE  ROWID = p_row_id;
  commit;
  FND_FILE.put_line(FND_FILE.LOG,'Commit Executed!!');

END p_write_log;


PROCEDURE p_report
IS
CURSOR c_rec
IS
select * from xxah_ps_ebs_supp_bank_update
where request_id = gv_request_id
ORDER BY CONVERSION_STATUS DESC;

l_success_header VARCHAR2(1):='N';
l_fail_header VARCHAR2(1):='N';
l_scnt    NUMBER:=0;
l_fcnt    NUMBER:=0;
l_acnt    NUMBER:=0;


BEGIN
    FOR r_rec IN c_rec
        LOOP
            IF r_rec.CONVERSION_STATUS = 'P' THEN
                IF l_success_header = 'N' THEN
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'+---------------------------------------------------------------------------+');
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'| XXAH: Supplier and Sites Update API Program                    |');
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'+---------------------------------------------------------------------------+');
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Success Record');
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'SR NO | OLD_SUPPLIER_NAME | NEW_SUPPLIER_NAME |ORA_VENDOR_ID | ORA_VENDOR_SITE_ID  ');
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'+---------------------------------------------------------------------------+');
                l_success_header := 'Y';
                END IF;
                l_scnt := l_scnt + 1;
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, l_scnt||' | '|| r_rec.OLD_SUPPLIER_NAME ||' | '|| r_rec.NEW_SUPPLIER_NAME ||' | '||r_rec.ORA_VENDOR_ID ||' | '|| r_rec.ORA_VENDOR_SITE_ID            );

            END IF;

                IF r_rec.CONVERSION_STATUS = 'E' THEN
                IF l_fail_header = 'N' THEN
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'+---------------------------------------------------------------------------+');
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Failed Record');
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'SR NO | OLD_SUPPLIER_NAME | NEW_SUPPLIER_NAME |ORA_VENDOR_ID | ORA_VENDOR_SITE_ID | ERROR_LOG ');
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'+---------------------------------------------------------------------------+');
                l_fail_header := 'Y';
                END IF;
                l_fcnt := l_fcnt + 1;
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, l_fcnt ||' | '|| r_rec.OLD_SUPPLIER_NAME ||' | '|| r_rec.NEW_SUPPLIER_NAME ||' | '||r_rec.ORA_VENDOR_ID ||' | '|| r_rec.ORA_VENDOR_SITE_ID ||' | '||trim(r_rec.ERROR_LOG));
            END IF;
            l_acnt := l_acnt + 1;
        END LOOP;
FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'+---------------------------------------------------------------------------+');
FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Total Records => '||    l_acnt);
FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Success Records => '|| l_scnt);
FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Failed Records => '|| l_fcnt);
FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'+---------------------------------------------------------------------------+');

END p_report;

end XXAH_SUPP_MASS_UPDATE_PKG; 

/
