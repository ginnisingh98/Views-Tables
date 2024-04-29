--------------------------------------------------------
--  DDL for Package Body AP_TURNOVER_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_TURNOVER_RPT_PKG" AS
-- $Header: APTURNOVERRPTPB.pls 120.1 2008/05/27 14:45:09 rapulla noship $
-- ****************************************************************************************
-- Copyright (c)  2000  Oracle Corporation    Product Development
-- All rights reserved
-- ****************************************************************************************
--
-- PROGRAM NAME
-- APTURNOVERRPTPB.pls
--
-- DESCRIPTION
--  This script creates the package body of AP_TURNOVER_RPT_PKG.
--  This package is used to generate AP Turnover Report.
--
-- USAGE
--   To install        How to Install
--   To execute        How to Execute
--
-- DEPENDENCIES
--   None.
--
--
-- LAST UPDATE DATE   21-FEB-2007
--   Date the program has been modified for the last time
--
-- HISTORY
-- =======
--
-- VERSION DATE        AUTHOR(S)         DESCRIPTION
-- ------- ----------- ---------------   ------------------------------------
-- 1.0    21-FEB-2007 Praveen Gollu Creation
--
--****************************************************************************************
FUNCTION beforeReport
RETURN BOOLEAN
IS
BEGIN
  IF SUPPLIER_FROM_PARAM IS NOT NULL AND SUPPLIER_TO_PARAM IS NOT NULL THEN
    IF SUPPLIER_FROM_PARAM <= SUPPLIER_TO_PARAM THEN
      gc_supplier_where:='AND UPPER(asup.vendor_name) BETWEEN UPPER(:SUPPLIER_FROM_PARAM) AND UPPER(:SUPPLIER_TO_PARAM)';
    ELSE
      gc_supplier_where:='AND UPPER(asup.vendor_name) BETWEEN UPPER(:SUPPLIER_TO_PARAM) AND UPPER(:SUPPLIER_FROM_PARAM)';
    END IF;
  END IF;

  IF LEDGER_ID_PARAM IS NOT NULL THEN
  SELECT name
    INTO gc_ledger_name
	FROM gl_ledgers
   WHERE ledger_id = LEDGER_ID_PARAM;
  ELSE
         gc_ledger_name :=' ';
  END IF;

  IF OU_FROM_PARAM <= OU_TO_PARAM THEN
    gc_operunit_where:='AND UPPER(hou.name) BETWEEN UPPER(:OU_FROM_PARAM) AND UPPER(:OU_TO_PARAM)';
  ELSE
    gc_operunit_where:='AND UPPER(hou.name) BETWEEN UPPER(:OU_TO_PARAM) AND UPPER(:OU_FROM_PARAM)';
  END IF;

  IF REPORT_TYPE_PARAM = 1 THEN
    gc_orderby:='ORDER BY 1,2,4,9,10';
  ELSE
    gc_orderby:='ORDER BY 1,9,10,2,4';
  END IF;

  IF CURRENCY_PARAM IS NOT NULL THEN
    gc_currency_where:='AND ai.invoice_currency_code= :CURRENCY_PARAM';
  END IF;

  IF PRPMT_PROCESSING_PARAM=2 THEN
    gc_prepay_invoice_select := ' ai.gl_date ';

    gc_prepay_invoice_from := ' gl_code_combinations gcc';

    gc_prepay_where := ' gcc.code_combination_id=xal.code_combination_id';
    gc_prepay_invoice_where := gc_prepay_where ;--||' AND   gcc.code_combination_id = :ACCOUNT_ID';

  ELSIF PRPMT_PROCESSING_PARAM=1 THEN
    gc_prepay_invoice_select := ' (CASE WHEN asps.recon_accounting_flag=''Y''';
    gc_prepay_invoice_select := gc_prepay_invoice_select ||' THEN ac.cleared_date';
    gc_prepay_invoice_select := gc_prepay_invoice_select ||' WHEN asps.recon_accounting_flag=''N''';
    gc_prepay_invoice_select := gc_prepay_invoice_select ||' AND asps.when_to_account_pmt=''ALWAYS''';
    gc_prepay_invoice_select := gc_prepay_invoice_select ||' THEN ac.check_date END) ';

    gc_prepay_invoice_from := gc_prepay_invoice_from ||' ap_invoice_payments   aip';
    gc_prepay_invoice_from := gc_prepay_invoice_from ||' ,ap_checks            ac';
    gc_prepay_invoice_from := gc_prepay_invoice_from ||' ,ap_system_parameters asps';
    gc_prepay_invoice_from := gc_prepay_invoice_from ||' ,gl_code_combinations gcc';
--************************
--WHERE Clause
--************************
    gc_prepay_where := ' aip.invoice_id=ai.invoice_id';
    gc_prepay_where := gc_prepay_where ||' AND ac.check_id=aip.check_id';
    gc_prepay_where := gc_prepay_where ||' AND asps.org_id=ai.org_id';
    gc_prepay_where := gc_prepay_where ||' AND gcc.code_combination_id=xal.code_combination_id';
    gc_prepay_where := gc_prepay_where ||' AND (CASE WHEN asps.recon_accounting_flag=''Y''';
    gc_prepay_where := gc_prepay_where ||' THEN ac.cleared_date';
    gc_prepay_where := gc_prepay_where ||' WHEN asps.recon_accounting_flag=''N''';
    gc_prepay_where := gc_prepay_where ||' THEN ac.check_date END) IS NOT NULL';
    gc_prepay_invoice_where := gc_prepay_where ;--||' AND gcc.code_combination_id = :ACCOUNT_ID';

    END IF;
  RETURN TRUE;
END beforeReport;

FUNCTION get_summary_mask_account(Acct_num IN VARCHAR2) RETURN VARCHAR2
IS
    lc_stat     VARCHAR2(100);
    lc_var      VARCHAR2(1) :='*';
    ln_count    NUMBER :=0;
    lv_acc_summ_mask VARCHAR2(100);
    ln_length NUMBER;
    CURSOR cu_Acctnum IS
    SELECT TRIM ( SUBSTR ( acc_num
                       , INSTR (acc_num, '-', 1, LEVEL) + 1
                       , INSTR (acc_num, '-', 1, LEVEL + 1)
                        -INSTR ( acc_num, '-', 1, LEVEL)- 1
                         )) AS account_segments
         , TRIM ( SUBSTR ( sum_mask
                         , INSTR ( sum_mask, '.', 1, LEVEL) + 1
                         , INSTR ( sum_mask, '.', 1, LEVEL + 1)
                           - INSTR ( sum_mask, '.', 1, LEVEL)- 1
                         )) AS summary_mask
      FROM ( SELECT '-' || Acct_num || '-' acc_num
                  , '.' || SUMMARY_MASK_PARAM || '.' sum_mask
              FROM DUAL )
CONNECT BY LEVEL <= LENGTH ( acc_num ) - LENGTH ( REPLACE ( acc_num, '-', '')) - 1;
BEGIN
IF REPORT_LEVEL_PARAM =4 OR REPORT_LEVEL_PARAM =5 OR REPORT_LEVEL_PARAM =6 THEN
IF SUMMARY_MASK_PARAM IS NOT NULL THEN
     FOR lcu_Acctnum IN cu_Acctnum
       LOOP
            IF lcu_Acctnum.summary_mask = 'T' THEN
                SELECT LENGTH(lcu_Acctnum.account_segments) into ln_length from dual;
                lc_stat := NULL;
                FOR i IN 1..ln_length LOOP
                lc_stat := lc_stat||lc_var;
                END LOOP;
            ELSIF lcu_Acctnum.summary_mask = 'D' THEN
                lc_stat := lcu_Acctnum.account_segments;
            END IF;
            ln_count := ln_count+1;
            IF ln_count=1 THEN
                lv_acc_summ_mask := lc_stat;
            ELSIF ln_count > 1 THEN
                lv_acc_summ_mask := lv_acc_summ_mask||'-'||lc_stat;
            END IF;
        END LOOP;
ELSIF SUMMARY_MASK_PARAM IS NULL THEN
        lv_acc_summ_mask := Acct_num;
END IF;
RETURN(lv_acc_summ_mask);

ELSE
RETURN(Acct_num);
END IF;
END get_summary_mask_account;

FUNCTION opening_balance(p_in_sup_id       IN NUMBER
                        ,p_in_sup_site_id  IN NUMBER
                        ,p_in_curr         IN VARCHAR2
                        ,p_in_code_comb_id IN NUMBER
                        ,p_in_orgs_id IN NUMBER) RETURN NUMBER
IS
  lc_payment_query VARCHAR2(3000);
BEGIN
BEGIN
    SELECT SUM(NVL(xdl.unrounded_accounted_dr,0)-NVL(xdl.unrounded_accounted_cr,0))
INTO gn_open_payment_balance
  FROM  ap_invoices aia
        ,ap_invoice_payments aip
		,ap_checks ac
		,ap_payment_history aph
		,ap_lookup_codes alc
		,ap_system_parameters asps
		,xla_events xe
		,xla_distribution_links xdl
		,xla_ae_lines xal
		,xla_ae_headers xah
		,gl_code_combinations gcc
 WHERE  aia.vendor_id             = p_in_sup_id
   AND  aia.org_id                = p_in_orgs_id
   AND  aia.vendor_site_id        = p_in_sup_site_id
   AND  aia.invoice_currency_code = p_in_curr
   AND  aia.invoice_id   = aip.invoice_id
   AND  aia.gl_date      < TO_DATE(PERIOD_START_DATE_PARAM)
   AND  aip.check_id     = ac.check_id
   AND  ac.check_id      = aph.check_id
   AND  alc.lookup_type  = 'PAYMENT TYPE'
   AND  asps.org_id      = aia.org_id
   AND  alc.lookup_code  = ac.payment_type_flag
   AND  aph.accounting_event_id = xe.event_id
   AND  xe.application_id = 200
   AND  xe.event_id      = xdl.event_id
   AND  xdl.application_id      = 200
   AND  aph.accounting_event_id = xdl.event_id
   AND  xdl.source_distribution_type = 'AP_PMT_DIST'
   AND  xdl.applied_to_source_id_num_1 = aia.invoice_id
   AND  xdl.ae_header_id       =  xal.ae_header_id
   AND  xal.application_id = 200
   AND  xdl.ae_line_num    = xal.ae_line_num
   AND  xdl.accounting_line_code NOT IN ('AP_LIAB_AWT_PMT')
   AND  xdl.applied_to_entity_code = 'AP_INVOICES'
   AND  xal.ae_header_id   = xah.ae_header_id
   AND  xah.application_id = 200
   AND  xah.ledger_id      = LEDGER_ID_PARAM
   AND  xdl.rounding_class_code = 'LIABILITY'
   AND  gcc.code_combination_id   = xal.code_combination_id
   AND  gcc.code_combination_id   = p_in_code_comb_id
   AND ((PRPMT_PROCESSING_PARAM = 2)
        OR (PRPMT_PROCESSING_PARAM = 1
          AND (aia.invoice_type_lookup_code  IN ('CREDIT','DEBIT','STANDARD','AWT','EXPENSE REPORT','MIXED')
        OR (aia.invoice_type_lookup_code  = 'PREPAYMENT'
       AND (CASE WHEN asps.recon_accounting_flag='Y'
                 THEN ac.cleared_date
                 WHEN asps.recon_accounting_flag='N'
                 THEN ac.check_date END) IS NOT NULL))));
EXCEPTION
  WHEN NO_DATA_FOUND THEN
       gn_open_payment_balance:=0;
END;
--for standard invoice
  BEGIN
  SELECT SUM(NVL(xal.accounted_cr,0)-NVL(xal.accounted_dr,0))
    INTO gn_open_invoice_balance
    FROM ap_invoices               ai
        ,xla_transaction_entities xte
        ,xla_events               xe
        ,xla_ae_headers           xah
        ,xla_ae_lines             xal
        ,gl_code_combinations     gcc
  WHERE ai.set_of_books_id        = LEDGER_ID_PARAM
    AND ai.vendor_id              = p_in_sup_id
    AND ai.org_id                 = p_in_orgs_id
    AND ai.vendor_site_id         = p_in_sup_site_id
    AND ai.invoice_currency_code  = p_in_curr
    AND ai.gl_date                < PERIOD_START_DATE_PARAM
    AND ai.invoice_type_lookup_code  IN ('CREDIT','DEBIT','STANDARD','AWT','EXPENSE REPORT','MIXED')
    AND xte.source_id_int_1       = ai.invoice_id
    AND xte.application_id        = 200
    AND xe.application_id         = 200
    AND xah.application_id        = 200
    AND xal.application_id        = 200
    AND xte.entity_code           = 'AP_INVOICES'
    AND xe.entity_id              = xte.entity_id
    AND xah.entity_id             = xte.entity_id
	AND xe.event_type_code      NOT IN ('PREPAYMENT UNAPPLIED','PREPAYMENT APPLIED')
    AND xah.event_id              = xe.event_id
    AND xal.ae_header_id          = xah.ae_header_id
    AND ai.invoice_id            = NVL(xal.upg_tax_reference_id1,ai.invoice_id)
    AND xal.accounting_class_code = 'LIABILITY'
    AND xal.ledger_id             = ai.set_of_books_id
    AND gcc.code_combination_id   = xal.code_combination_id
    AND gcc.code_combination_id   = p_in_code_comb_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      gn_open_invoice_balance:=0;
  END;
  g_open_balance :=NVL(gn_open_payment_balance,0)-NVL(gn_open_invoice_balance,0);
  RETURN(NVL(g_open_balance,0));
END opening_balance;

END AP_TURNOVER_RPT_PKG;

/
