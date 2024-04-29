--------------------------------------------------------
--  DDL for Package Body JG_ZZ_AUDIT_AR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JG_ZZ_AUDIT_AR_PKG" 
-- $Header: jgzzauditarb.pls 120.9.12010000.2 2009/08/27 16:37:46 rshergil ship $
--*************************************************************************************
-- | Copyright (c) 1996 Oracle Corporation Redwood Shores, California, USA         |
-- |                       All rights reserved.                                    |
--*************************************************************************************
--
--
-- PROGRAM NAME
--  JGZZ_AUDITARB.pls
--
-- DESCRIPTION
--  Script to Create package specification for AUDIT-AR Report
--
-- HISTORY
-- =======
--
-- VERSION     DATE           AUTHOR(S)             DESCRIPTION
-- -------   -----------    ---------------       -----------------------------------------------------------
-- DRAFT 1A    18-Jan-2005    Murali V              Initial draft version
-- DRAFT 1B    21-Feb-2006    Manish Upadhyay       Modified as per the Review comments.
-- 120.1       01-MAR-2006    brathod               Reference to jgzz_common_pkg changed to jg_zz_common_pkg
-- 120.3       26-APR-2006    brathod               Bug: 5189166.  Modified to correct code for Unit Testing.
-- 120.4       15-MAY-2006    Vijay Shankar         Bug: 5125654.  Rectified the issues that occured during Unit Testing.
-- 120.5       18-jul-2006    Aparajita Das         Bug: 5225958.  UT bug fix.
-- 120.6       04-Aug-2005    Venkataramanan S      Bug 5194991 : Incorporated the reprint functionality
--***********************************************************************************************************
AS

  gv_debug constant boolean := false;


FUNCTION BeforeReport
RETURN BOOLEAN
IS
BEGIN
  DECLARE

    l_precision             NUMBER := 0;

    --JEBEVA17 Annual VAT Audit Report
    /*  Brathod, Updated the cursor to remove usage of hz_cust_account_sites by removing outer join.
        Directly using jg_zz_vat_trx_details.billing_tp_site_id to joing with hps.party_site_id
    */
    CURSOR c_jgbevat IS
    SELECT JZVTD.doc_seq_value                                    BE_DOC_SEQ_VALUE
          ,SUBSTR(JZVTD.billing_tp_name,1,25)                     CUSTOMER_NAME
          ,SUBSTR(HZL.address1,1,18)                              ADDRESS1
          ,SUBSTR(JZVTD.billing_tp_number,1,24)                   CUSTOMER_NUMBER
          ,SUBSTR(HZL.postal_code,1,4)                            POSTAL_CODE
          ,SUBSTR(HZL.city,1,22)                                  CITY
          ,JZVTD.trx_class_mng                                    CLASS
          ,JZVTD.trx_number                                       DOC_NUMBER
          ,JZVTD.trx_type_mng                                     INVOICE_TYPE
          ,JZVTD.trx_date                                         DOCUMENT_DATE
          ,JZVTD.gl_date                                          GL_DATE
          ,JZVTD.billing_tp_site_tax_reg_num                      TAX_REFERENCE
          ,ROUND(NVL(JZVTD.taxable_amt_funcl_curr, taxable_amt)
           +NVL(JZVTD.tax_amt_funcl_curr, tax_amt), l_precision)               TOTAL_AMOUNT
          ,ROUND(NVL(JZVTD.taxable_amt_funcl_curr, taxable_amt), l_precision)  TAXABLE_AMOUNT
          ,ROUND(NVL(JZVTD.tax_amt_funcl_curr, tax_amt), l_precision)          TAX_AMOUNT
    FROM   jg_zz_vat_trx_details    JZVTD
          ,jg_zz_vat_rep_status     JZVRS
          ,hz_cust_acct_sites_all   HZCAS
          ,hz_party_sites           HPS
          ,hz_locations             HZL
          ,ra_customer_trx_all      RCTA
          ,ra_cust_trx_types        RTT
    WHERE  JZVTD.reporting_status_id                      = JZVRS.reporting_status_id
    AND    JZVRS.vat_reporting_entity_id                  = p_vat_rep_entity_id
    AND    JZVRS.source                                   = 'AR'
    AND    JZVRS.tax_calendar_year                        = p_year
    AND    JZVTD.billing_tp_address_id                    = HZCAS.cust_acct_site_id
    AND    HZCAS.party_site_id                            = HPS.party_site_id (+)
    AND    HPS.location_id                                = HZL.location_id (+)
    AND    SUBSTR(JZVTD.billing_tp_site_tax_reg_num,1,2)  = 'BE'
    AND    JZVTD.trx_id                                   = RCTA.customer_trx_id
    AND    (
              p_customer_name_from IS NULL
              OR
              ( JZVTD.billing_tp_name BETWEEN
                p_customer_name_from AND NVL(p_customer_name_to,JZVTD.billing_tp_name)
              )
           )
    AND    RTT.cust_trx_type_id                         =  JZVTD.trx_type_id
    AND    RTT.type                                     IN ('INV','CM','DM')
    AND    NVL(UPPER(RCTA.interface_header_context),'X') <> 'CONTRA'
    ;

    --JECZAREX Czech Export Tax Report
    /* brathod, Modified cursor to remove usage of fnd_lookups and jg_zz_vat_box_allocs. */
    CURSOR c_jgczvat IS
    SELECT JZVTD.doc_seq_value                             CZ_DOC_SEQ_VALUE
          ,JZVTD.functional_currency_code                  FUNCTIONAL_CURRENCY_CODE
          ,JZVTD.TAX_RATE_CODE_VAT_TRX_TYPE_MNG            VAT_BOX
          ,JZVTD.TAX_RATE_VAT_TRX_TYPE_DESC                VAT_BOX_DESC
          ,JZVTD.trx_description                           TRANSACTION_DESC
          ,JZVTD.trx_number                                DOC_NUMBER
          ,JZVTD.tax_invoice_date                          TAX_DATE
          ,JZVTD.accounting_date                           GL_DATE
          ,NVL(JZVTD.taxable_amt_funcl_curr,taxable_amt)   TAXABLE_AMOUNT
    FROM   jg_zz_vat_trx_details    JZVTD
          ,jg_zz_vat_rep_status     JZVRS
          ,ra_customer_trx_all      RCTA
    WHERE  JZVTD.reporting_status_id                      = JZVRS.reporting_status_id
    AND    JZVRS.vat_reporting_entity_id                  = p_vat_rep_entity_id
    AND    JZVRS.tax_calendar_period                      = p_period
    AND    JZVTD.trx_id                                   = RCTA.customer_trx_id
    AND    JZVRS.source                                   = 'AR'
    AND    JZVTD.trx_line_class  IN ('INVOICE','CREDIT_MEMO','DEBIT_MEMO')
    -- bug 8616974 - start
    --AND    (p_tax_type is null or JZVTD.tax_type_code = p_tax_type)
    AND    (p_tax_type is null or JZVTD.reporting_code = p_tax_type)
    -- bug 8616974 - end
    AND    NVL(UPPER(RCTA.interface_header_context),'X') <> 'CONTRA'
    ;

    --AUDIT-AR
    CURSOR c_jgzzaudar IS
    SELECT JZVTD.doc_seq_value                                      AR_DOC_SEQ_VALUE
          ,SUBSTR(JZVTD.billing_tp_name,1,25)                       CUSTOMER_NAME
          ,SUBSTR(HZ.address1,1,18)                                 ADDRESS1
          ,SUBSTR(JZVTD.billing_tp_number,1,24)                     CUSTOMER_NUMBER
          ,SUBSTR(HZ.postal_code,1,4)                               POSTAL_CODE
          ,SUBSTR(HZ.city,1,22)                                     CITY
          ,JZVTD.trx_class_mng                                      CLASS
          ,JZVTD.trx_number                                         DOC_NUMBER
          ,JZVTD.trx_type_mng                                       INVOICE_TYPE
          ,JZVTD.billing_tp_site_tax_reg_num                        TAX_REFERENCE
          ,JZVTD.functional_currency_code                           FUNCTIONAL_CURRENCY_CODE
         ,JZVTD.TAX_RATE_CODE_VAT_TRX_TYPE_MNG                      VAT_BOX
          ,JZVTD.TAX_RATE_VAT_TRX_TYPE_DESC                         VAT_BOX_DESC
          ,JZVTD.trx_description                                    TRANSACTION_DESC
          ,JZVTD.trx_date                                           DOCUMENT_DATE
          ,JZVTD.accounting_date                                    GL_DATE
          ,JZVTD.tax_invoice_date                                   TAX_DATE
          ,(NVL(JZVTD.taxable_amt_funcl_curr, taxable_amt)
           +NVL(JZVTD.tax_amt_funcl_curr, tax_amt))                 TOTAL_AMOUNT
          ,NVL(JZVTD.taxable_amt_funcl_curr, taxable_amt)           TAXABLE_AMOUNT
          ,NVL(JZVTD.tax_amt_funcl_curr, tax_amt)                   TAX_AMOUNT
    FROM   jg_zz_vat_trx_details    JZVTD
          ,jg_zz_vat_rep_status     JZVRS
          ,hz_locations             HZ
          ,hz_party_sites           HPS
          ,ra_customer_trx_all      RCTA
    WHERE  JZVTD.reporting_status_id                      = JZVRS.reporting_status_id
    AND    JZVRS.vat_reporting_entity_id                  = p_vat_rep_entity_id
    AND    JZVRS.source                                   = 'AR'
    AND    JZVRS.tax_calendar_period                      = p_period
    AND    JZVTD.billing_tp_site_id                       = HPS.party_site_id (+)
    AND    HZ.location_id (+)                             = HPS.location_id
    AND    JZVTD.trx_id                                   = RCTA.customer_trx_id
    AND    JZVTD.trx_line_class           IN ('INVOICE','CREDIT_MEMO','DEBIT_MEMO')
    AND    NVL(UPPER(RCTA.interface_header_context),'X') <> 'CONTRA'
    ;

    -- Record count check
    CURSOR c_count
    IS
    SELECT COUNT(*)
    FROM   jg_zz_vat_trx_gt;

    l_rec_count             NUMBER;
    lc_curr_code            VARCHAR2(50);
    lc_rep_entity_name      jg_zz_vat_trx_details.rep_context_entity_name%TYPE;
    ln_legal_entity_id      NUMBER;
    ln_taxpayer_id          jg_zz_vat_trx_details.taxpayer_id%TYPE;
    lc_company_name         xle_registrations.registered_name%TYPE;
    lc_registration_number  xle_registrations.registration_number%TYPE;
    lc_country              hz_locations.country%TYPE;
    lc_address1             hz_locations.address1%TYPE;
    lc_address2             hz_locations.address2%TYPE;
    lc_address3             hz_locations.address3%TYPE;
    lc_address4             hz_locations.address4%TYPE;
    lc_city                 hz_locations.city%TYPE;
    lc_postal_code          hz_locations.postal_code%TYPE;
    lc_contact              hz_parties.party_name%TYPE;
    lc_phone_number         hz_contact_points.phone_number%TYPE;
    -- Added for Glob-006 ER
    l_province                      VARCHAR2(120);
    l_comm_num                      VARCHAR2(30);
    l_vat_reg_num                   VARCHAR2(50);


    lc_tax_registration     jg_zz_vat_rep_status.tax_registration_number%TYPE;
    ld_period_start_date    jg_zz_vat_rep_status.period_start_date%TYPE      ;
    ld_period_end_date      jg_zz_vat_rep_status.period_end_date%TYPE        ;
    lc_status               VARCHAR2(25);

    t_total_amount          NUMBER := 0;

    REPORT_LIMIT_REACHED    EXCEPTION;
    AMOUNT_LIMIT_REACHED    EXCEPTION;

  BEGIN

    -- Call to common pack for Header Info.
    -- Calling this package first because, currency_code is needed for getting precision
    if gv_debug then fnd_file.put_line(fnd_file.log,'Calling common pack Procedure FUNCT_CURR_LEGAL'); end if;

    /* changed from JGZZ_COMMON_PKG to JG_ZZ_COMMON_PKG */
    JG_ZZ_COMMON_PKG.funct_curr_legal(lc_curr_code         -- x_func_curr_code      O VARCHAR2
                                    ,lc_rep_entity_name   -- x_rep_entity_name     O VARCHAR2
                                    ,ln_legal_entity_id   -- x_legal_entity_id     O NUMBER
                                    ,ln_taxpayer_id       -- x_taxpayer_id         O NUMBER
                                    ,p_vat_rep_entity_id  -- pn_vat_rep_entity_id  I NUMBER
                                    ,p_period             -- pv_period_name        I VARCHAR2 DEFAULT NULL
                                    ,p_year               -- pn_period_year        I NUMBER   DEFAULT NULL
                                    );

    SELECT precision
    INTO  l_precision
    FROM  fnd_currencies_vl
    WHERE currency_code = lc_curr_code;

    IF p_report_name = 'JEBEVA17' THEN

      if gv_debug then
        fnd_file.put_line(fnd_file.log,'Insert JEBEVA17 Annual VAT Audit Report Info');
      end if;

      l_rec_count:=0;
      t_total_amount := 0;
      FOR r_jgbevat IN c_jgbevat
      LOOP
        INSERT INTO jg_zz_vat_trx_gt
        (jg_info_v1                          -- BE_DOC_SEQ_VALUE
        ,jg_info_v2                          -- CUSTOMER_NAME
        ,jg_info_v3                          -- ADDRESS1
        ,jg_info_v4                          -- CUSTOMER_NUMBER
        ,jg_info_v5                          -- POSTAL_CODE
        ,jg_info_v6                          -- CITY
        ,jg_info_v7                          -- CLASS
        ,jg_info_v8                          -- DOC_NUMBER
        ,jg_info_v9                          -- INVOICE_TYPE
        ,jg_info_d1                          -- DOCUMENT_DATE
        ,jg_info_d2                          -- GL_DATE
        ,jg_info_v10                         -- TAX_REFERENCE
        ,jg_info_n1                          -- TOTAL_AMOUNT
        ,jg_info_n2                          -- TAXABLE_AMOUNT
        ,jg_info_n3                          -- TAX_AMOUNT
        ) VALUES
        (r_jgbevat.be_doc_seq_value
        ,r_jgbevat.customer_name
        ,r_jgbevat.address1
        ,r_jgbevat.customer_number
        ,r_jgbevat.postal_code
        ,r_jgbevat.city
        ,r_jgbevat.class
        ,r_jgbevat.doc_number
        ,r_jgbevat.invoice_type
        ,r_jgbevat.document_date
        ,r_jgbevat.gl_date
        ,r_jgbevat.tax_reference
        ,r_jgbevat.total_amount
        ,r_jgbevat.taxable_amount
        ,r_jgbevat.tax_amount
        );
      l_rec_count := l_rec_count + 1;

      -- Raise error if count reaches 999999
      IF l_rec_count >= 999999 THEN
        RAISE REPORT_LIMIT_REACHED;
      END IF;

      t_total_amount := t_total_amount + r_jgbevat.total_amount;
      IF t_total_amount >= 9999999999999999 THEN
        RAISE AMOUNT_LIMIT_REACHED;
      END IF;

      END LOOP;
    ELSIF p_report_name = 'JECZAREX' THEN
      if gv_debug then fnd_file.put_line(fnd_file.log,'Insert JECZAREX Czech Export Tax Report Info'); end if;

      l_rec_count:=0;
      FOR r_jgczvat IN c_jgczvat
      LOOP
        INSERT INTO jg_zz_vat_trx_gt
        (jg_info_v1                             -- CZ_DOC_SEQ_VALUE
        ,jg_info_v2                             -- FUNCTIONAL_CURRENCY_CODE
        ,jg_info_v3                             -- VAT_BOX
        ,jg_info_v4                             -- VAT_BOX_DESC
        ,jg_info_v5                             -- TRANSACTION_DESC
        ,jg_info_v8                             -- DOC_NUMBER
        ,jg_info_d1                             -- TAX_DATE
        ,jg_info_d2                             -- GL_DATE
        ,jg_info_n2                             -- TAXABLE_AMOUNT
        ) VALUES
        (r_jgczvat.cz_doc_seq_value
        ,r_jgczvat.functional_currency_code
        ,r_jgczvat.vat_box
        ,r_jgczvat.vat_box_desc
        ,r_jgczvat.transaction_desc
        ,r_jgczvat.doc_number
        ,r_jgczvat.tax_date
        ,r_jgczvat.gl_date
        ,r_jgczvat.taxable_amount
        );
      END LOOP;
    ELSIF NVL(p_report_name,'AUDIT-AR') = 'AUDIT-AR' THEN
      if gv_debug then fnd_file.put_line(fnd_file.log,'Insert AUDIT-AR Info'); end if;

      l_rec_count:=0;
      FOR r_jgzzaudar IN c_jgzzaudar
      LOOP
        INSERT INTO jg_zz_vat_trx_gt
          (jg_info_v1                           -- AR_DOC_SEQ_VALUE
          ,jg_info_v2                           -- CUSTOMER_NAME
          ,jg_info_v3                           -- ADDRESS1
          ,jg_info_v4                           -- CUSTOMER_NUMBER
          ,jg_info_v5                           -- POSTAL_CODE
          ,jg_info_v6                           -- CITY
          ,jg_info_v7                           -- CLASS
          ,jg_info_v8                           -- DOC_NUMBER
          ,jg_info_v9                           -- INVOICE_TYPE
          ,jg_info_v10                          -- TAX_REFERENCE
          ,jg_info_v11                          -- FUNCTIONAL_CURRENCY_CODE
          ,jg_info_v12                          -- VAT_BOX
          ,jg_info_v13                          -- VAT_BOX_DESC
          ,jg_info_v14                          -- TRANSACTION_DESC
          ,jg_info_d1                           -- DOCUMENT_DATE
          ,jg_info_d2                           -- GL_DATE
          ,jg_info_d3                           -- TAX_DATE
          ,jg_info_n1                           -- TOTAL_AMOUNT
          ,jg_info_n2                           -- TAXABLE_AMOUNT
          ,jg_info_n3                           -- TAX_AMOUNT
          ) VALUES
          (r_jgzzaudar.ar_doc_seq_value
          ,r_jgzzaudar.customer_name
          ,r_jgzzaudar.address1
          ,r_jgzzaudar.customer_number
          ,r_jgzzaudar.postal_code
          ,r_jgzzaudar.city
          ,r_jgzzaudar.class
          ,r_jgzzaudar.doc_number
          ,r_jgzzaudar.invoice_type
          ,r_jgzzaudar.tax_reference
          ,r_jgzzaudar.functional_currency_code
          ,r_jgzzaudar.vat_box
          ,r_jgzzaudar.vat_box_desc
          ,r_jgzzaudar.transaction_desc
          ,r_jgzzaudar.document_date
          ,r_jgzzaudar.gl_date
          ,r_jgzzaudar.tax_date
          ,r_jgzzaudar.total_amount
          ,r_jgzzaudar.taxable_amount
          ,r_jgzzaudar.tax_amount
          );
      END LOOP;
    END IF;
    if gv_debug then fnd_file.put_line(fnd_file.log,'Global temp table records check'); end if;

    OPEN  c_count;
    FETCH c_count INTO p_rec_count;
    CLOSE c_count;

    if gv_debug then fnd_file.put_line(fnd_file.log,'Calling common pack Procedure TAX_REGISTRATION'); end if;

        /* changed from JGZZ_COMMON_PKG to JG_ZZ_COMMON_PKG */
    JG_ZZ_COMMON_PKG.tax_registration(lc_tax_registration  -- x_tax_registration    O VARCHAR2
                                    ,ld_period_start_date -- x_period_start_date   O DATE
                                    ,ld_period_end_date   -- x_period_end_date     O DATE
                                    ,lc_status            -- x_status              O VARCHAR2
                                    ,p_vat_rep_entity_id  -- pn_vat_rep_entity_id  I NUMBER
                                    ,p_period             -- pv_period_name        I VARCHAR2 DEFAULT NULL
                                    ,p_year               -- pn_period_year        I NUMBER   DEFAULT NULL
                                    ,'AR'                 -- pv_source             I VARCHAR2
                                    );

    if gv_debug then fnd_file.put_line(fnd_file.log,'Calling common pack Procedure COMPANY_DETAIL'); end if;

        /* changed from JGZZ_COMMON_PKG to JG_ZZ_COMMON_PKG */

   jg_zz_common_pkg.company_detail(x_company_name            => lc_company_name
                                  ,x_registration_number    => lc_registration_number
                                  ,x_country                => lc_country
                                  ,x_address1               => lc_address1
                                  ,x_address2               => lc_address2
                                  ,x_address3               => lc_address3
                                  ,x_address4               => lc_address4
                                  ,x_city                   => lc_city
                                  ,x_postal_code            => lc_postal_code
                                  ,x_contact                => lc_contact
                                  ,x_phone_number           => lc_phone_number
                                  ,x_province               => l_province
                                  ,x_comm_number            => l_comm_num
                                  ,x_vat_reg_num            => l_vat_reg_num
                                  ,pn_legal_entity_id       => ln_legal_entity_id
                                  ,p_vat_reporting_entity_id => P_VAT_REP_ENTITY_ID);


    lc_status := JG_ZZ_VAT_REP_UTILITY.get_period_status(pn_vat_reporting_entity_id => p_vat_rep_entity_id
                                                                 ,pv_tax_calendar_period => p_period
                                                                 ,pv_tax_calendar_year => p_year
                                                                 ,pv_source => NULL
                                                                 ,pv_report_name => p_report_name);


    if gv_debug then fnd_file.put_line(fnd_file.log,'Calling common pack Inserting Header Info'); end if;

    INSERT INTO jg_zz_vat_trx_gt    (jg_info_v1             -- curr_code
                                    ,jg_info_v2             -- entity_name
                                    ,jg_info_v3             -- taxpayer_id
                                    ,jg_info_v4             -- company_name
                                    ,jg_info_v5             -- registration_number
                                    ,jg_info_v6             -- country
                                    ,jg_info_v7             -- address1
                                    ,jg_info_v8             -- address2
                                    ,jg_info_v9             -- address3
                                    ,jg_info_v10            -- address4
                                    ,jg_info_v11            -- city
                                    ,jg_info_v12            -- postal_code
                                    ,jg_info_v13            -- contact
                                    ,jg_info_v14            -- phone_number
				    ,jg_info_v15            -- reporting mode
                                    ,jg_info_v30            -- Header record indicator
                                    ,jg_info_d1             -- start_date
                                    ,jg_info_d2             -- end_date
                                    )
                             VALUES (lc_curr_code           -- curr_code
                                    ,lc_company_name        -- lc_rep_entity_name     -- entity_name
                                    ,ln_taxpayer_id         -- ln_taxpayer_id         -- taxpayer_id
                                    ,lc_company_name        -- company_name
                                    ,lc_tax_registration    -- registration_number
                                    ,lc_country             -- country
                                    ,lc_address1            -- address1
                                    ,lc_address2            -- address2
                                    ,lc_address3            -- address3
                                    ,lc_address4            -- address4
                                    ,lc_city                -- city
                                    ,lc_postal_code         -- postal_code
                                    ,lc_contact             -- contact
                                    ,lc_phone_number        -- phone_number
				    ,lc_status              -- reporting mode
                                    ,'H'                    -- Header record indicator
                                    ,ld_period_start_date   -- start_date
                                    ,ld_period_end_date     -- end_date
                                    );

    RETURN (TRUE);
  EXCEPTION
    /*UT TEST
    WHEN NO_DATA_FOUND THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,'No data found during Before Report Trigger');
      RETURN (FALSE); */

  WHEN REPORT_LIMIT_REACHED THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Number of records exceeded the report limit.');
    RETURN (FALSE);

  WHEN AMOUNT_LIMIT_REACHED THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Amount Overflow, total amount or tax has exceeded the limit.');
    RETURN (FALSE);

  WHEN OTHERS THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Error in beforeReport trigger of JG_ZZ_AUDIT_AR_PKG package. Error-' || SQLCODE || SUBSTR(SQLERRM,1,200));
    RETURN (FALSE);
  END;

  RETURN (TRUE);

EXCEPTION
   WHEN OTHERS THEN
     RETURN (FALSE);
END BeforeReport;

END JG_ZZ_AUDIT_AR_PKG;

/
