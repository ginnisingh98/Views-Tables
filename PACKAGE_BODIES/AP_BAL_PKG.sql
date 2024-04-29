--------------------------------------------------------
--  DDL for Package Body AP_BAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_BAL_PKG" 
-- $Header: APPREBCPB.pls 120.12.12010000.5 2009/10/25 16:46:14 wjharris ship $
-- ****************************************************************************************
-- Copyright (c)  2000  Oracle Solution Services (India)     Product Development
-- All rights reserved
-- ****************************************************************************************
--
-- PROGRAM NAME
--  APPREBCPB.pls
--
-- DESCRIPTION
--  This script creates the package body of AP_PREPAY_BAL_PKG.
--  This package is used to generate Prepayment Balance Report.
--
-- USAGE
--   To install        How to Install
--   To execute        How to Execute
--
--PROGRAM LIST
--NAME            USAGE
--
--  get_ledger_name  Used to obtain the Ledger Name for which the report is running
--
--  get_no_of_holds  Used to obtain the number of holds for a particular Prepayment
--
--  beforereport  Used to initialize the dynamic variable based on the input
--                obtained from parameters.
--
-- DEPENDENCIES
--   None.
--
-- CALLED BY
--   DataTemplate Extract in Prepayment Balance Report (CZech).
--
--
-- LAST UPDATE DATE   27-Mar-2007
--   Date the program has been modified for the last time
--
-- HISTORY
-- =======
--
-- VERSION   DATE           AUTHOR(S)          DESCRIPTION
-- -------   -----------    ---------------    ------------------------------------
-- 1.00      27-Mar-2007    Sandeep Kumar G.   Creation
-- |  History
-- |   23-Sep-2009 wjharris   Bug B 8973431/8935239 - FUNCTION description() :
-- |                          remove table gl_code_combinations from join
--
-- ****************************************************************************************
AS

--=====================================================================
FUNCTION get_no_of_holds(p_invoice_id IN NUMBER)
RETURN NUMBER
IS
  ln_count NUMBER;
BEGIN
  BEGIN
    SELECT COUNT(1)
    INTO   ln_count
    FROM   AP_HOLDS ah
    WHERE  ah.invoice_id = p_invoice_id
    AND    NVL(ah.status_flag,'X') <> 'R'; --Added the Condition Based on the Bug 6473102
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      ln_count := 0;
  END;
  RETURN (ln_count);
END get_no_of_holds;

--=====================================================================
--=====================================================================
FUNCTION get_settlement_date(p_invoice_id IN NUMBER
                            ,p_line_number IN NUMBER)
RETURN DATE
IS
ld_settlement_date DATE;
BEGIN
  BEGIN
   SELECT MAX(AVPFPV.accounting_date)
     INTO ld_settlement_date
     FROM ap_view_prepays_fr_prepay_v AVPFPV
    WHERE AVPFPV.prepay_id = p_invoice_id
      AND AVPFPV.prepay_line_number = p_line_number;
   EXCEPTION
   WHEN no_data_found THEN
     ld_settlement_date := NULL;
  END;
  RETURN ld_settlement_date;
END get_settlement_date;

--=====================================================================
--=====================================================================
FUNCTION description(p_seg_value IN VARCHAR2,p_seg_type IN VARCHAR2)
RETURN VARCHAR2
IS
v_value_desc VARCHAR2(240);  -- Bug 8814452 , Increasing the size to
                             -- sync. with fnd_flex_values_vl.description
BEGIN
  BEGIN
  IF p_seg_type LIKE '%SEGMENT%' THEN
    SELECT DISTINCT ffv.description
    INTO v_value_desc
    FROM
         -- gl_code_combinations gcc, .. B 8973431/8935239 .... remove table from join
        fnd_id_flex_structures ffs
        ,fnd_id_flex_segments fseg
        ,fnd_flex_values_vl   ffv
    --WHERE gcc.chart_of_accounts_id = ffs.id_flex_num   .. B 8973431/8935239
    --AND ffs.id_flex_num = fseg.id_flex_num   .. B 8973431/8935239
    WHERE ffs.id_flex_num = fseg.id_flex_num   -- B 8973431/8935239
    AND ffs.id_flex_code = fseg.id_flex_code
    AND fseg.application_column_name = p_seg_type
    AND fseg.flex_value_set_id = ffv.flex_value_set_id
    AND ffs.id_flex_code = 'GL#'
    --AND gcc.chart_of_accounts_id = (SELECT chart_of_accounts_id   .. B 8973431/8935239
    AND ffs.id_flex_num = (SELECT chart_of_accounts_id   -- B 8973431/8935239
                                       FROM gl_access_sets
                                      WHERE access_set_id = fnd_profile.value('GL_ACCESS_SET_ID'))
    AND ffv.flex_value = p_seg_value;
  ELSE
      SELECT ffv.description
      INTO   v_value_desc
      FROM   fnd_descr_flex_col_usage_vl fdfcu
            ,fnd_flex_values_vl          ffv
      WHERE  fdfcu.flex_value_set_id = ffv.flex_value_set_id
        AND  fdfcu.application_id = 200
        AND  fdfcu.descriptive_flexfield_name = 'AP_INVOICES'
        AND  fdfcu.descriptive_flex_context_code ='Global Data Elements'
        AND  fdfcu.application_column_name = p_seg_type
        AND  ffv.flex_value  = p_seg_value;
  END IF;
EXCEPTION
        WHEN NO_DATA_FOUND THEN
        v_value_desc := NULL;
END;
        RETURN v_value_desc;
END description;

--=====================================================================
--=====================================================================
FUNCTION beforereport RETURN BOOLEAN
IS
ld_param_from_date  DATE;
ld_param_to_date    DATE;
ld_period_from_date DATE;
ld_period_to_date   DATE;
BEGIN
  BEGIN
    SELECT gled.name
    INTO gc_ledger_name
    FROM gl_ledgers gled
        ,gl_access_set_norm_assign gasna
   WHERE gasna.access_set_id     = FND_PROFILE.VALUE('GL_ACCESS_SET_ID')
     AND gled.ledger_id          = gasna.ledger_id
     AND gled.ledger_category_code = 'PRIMARY';
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    gc_ledger_name := NULL;
  END;

  /*--*************************************************
  -- Used for DATE Conditions
  --*************************************************/
  IF FROM_DATE_PARAM IS NULL THEN
   ld_param_from_date := SYSDATE;
   ld_param_to_date   := SYSDATE;
  ELSIF FROM_DATE_PARAM IS NOT NULL AND TO_DATE_PARAM IS NULL THEN
   ld_param_from_date := TO_DATE(FROM_DATE_PARAM,'YYYY/MM/DD HH24:MI:SS');
   ld_param_to_date   := TO_DATE(FROM_DATE_PARAM,'YYYY/MM/DD HH24:MI:SS');
  ELSE
   ld_param_from_date := TO_DATE(FROM_DATE_PARAM,'YYYY/MM/DD HH24:MI:SS');
   ld_param_to_date   := TO_DATE(TO_DATE_PARAM,'YYYY/MM/DD HH24:MI:SS');
  END IF;

  IF PERIOD_FROM_PARAM IS NULL AND PERIOD_TO_PARAM IS NULL THEN
   ld_period_from_date := SYSDATE;
   ld_period_to_date   := SYSDATE;
  ELSE
   SELECT gps.start_date
      INTO   ld_period_from_date
      FROM   gl_period_statuses gps
      WHERE  gps.period_name     = PERIOD_FROM_PARAM
      AND    gps.application_id  = 200
      AND    gps.set_of_books_id = FND_PROFILE.VALUE('GL_SET_OF_BKS_ID');

   SELECT gps.end_date
      INTO   ld_period_to_date
      FROM   gl_period_statuses gps
      WHERE  gps.period_name     = PERIOD_TO_PARAM
      AND    gps.application_id  = 200
      AND    gps.set_of_books_id = FND_PROFILE.VALUE('GL_SET_OF_BKS_ID');
  END IF;

  IF ld_param_from_date <= ld_period_from_date THEN
    gd_from_date := ld_param_from_date;
  ELSE
    gd_from_date := ld_period_from_date;
  END IF;

 --Made changes as per the Bug 6473102
  IF PERIOD_TO_PARAM IS NOT NULL THEN
    gd_to_date := ld_period_to_date;
  ELSIF ld_param_to_date >= ld_period_to_date AND TO_DATE_PARAM IS NOT NULL THEN
    gd_to_date := ld_param_to_date;
  ELSIF ld_param_to_date < ld_period_to_date AND ld_period_to_date <> SYSDATE THEN
    gd_to_date := ld_period_to_date;
  ELSE
    gd_to_date := ld_param_to_date;
  END IF;

  /*--*************************************************
  -- Used for Currency Code Conditions
  --*************************************************/
  IF CURR_CODE_PARAM IS NOT NULL AND curr_code_param <> 'ANY' THEN
    gc_currency := ' AND ai.invoice_currency_code = :CURR_CODE_PARAM ';
  ELSE
    gc_currency := ' AND 1 = 1 ';
  END IF;
  fnd_file.put_line(fnd_file.log,'gc_currency::'||gc_currency);

  /*--*************************************************
  -- Used for Posted Only (Y/N) Conditions
  --*************************************************/

 -- gc_from_clause := ' ,ap_checks_all        ac ';
  IF POSTED_ONLY_PARAM = 'Y' THEN
/*
gc_from_clause := gc_from_clause ||' ,gl_import_references gir '
                    ||' ,gl_je_headers        gjh ';
    gc_status      := ' AND gir.gl_sl_link_id = xal.gl_sl_link_id '
                    ||' AND gir.gl_sl_link_table = xal.gl_sl_link_table '
                    ||' AND gir.je_header_id = gjh.je_header_id '
                    ||' AND xal.ledger_id = gjh.ledger_id '
                    ||' AND gjh.status = ''P''';
  --gc_status := ' AND xah.gl_transfer_status_code = ''Y'' ';
    gc_select_clause := ' gjh.status ';
*/
    --gc_status      := ' AND gjh.status = ''P''';
    gc_status := ' AND xah.gl_transfer_status_code = ''Y'' ';
  ELSE
    gc_status := ' AND 1 = 1 ';
 --   gc_select_clause := ' NULL ';
  END IF;
  fnd_file.put_line(fnd_file.log,'gc_status::'||gc_status);
/*--*************************************************
--Dynamic WHERE based on supplier_from_param and supplier_to_param parameter
--*************************************************/
  IF supplier_from_param IS NOT NULL AND supplier_to_param IS NOT NULL THEN
    IF supplier_from_param < supplier_to_param THEN
      gc_supplier := ' AND POV.vendor_name BETWEEN :supplier_from_param AND :supplier_to_param ';
    ELSE
      gc_supplier := ' AND POV.vendor_name BETWEEN :supplier_to_param AND :supplier_from_param ';
    END IF;
  ELSIF supplier_from_param IS NOT NULL AND supplier_to_param IS NULL THEN
      gc_supplier := ' AND POV.vendor_name = :supplier_from_param';
  ELSE
 gc_supplier := ' AND 1 = 1';
  END IF;
/*--*************************************************
  -- These are mainly used to confirm which part of the query should result the
  -- output and which sould not. This is decided based on the P_PAID parameter.
  -- If the Parameter returns 'Y' then only Paid records will display hence only
  -- first Query will result the output. If the P_PAID returns 'N' then both paid
  -- and Unpaid records needs to be displayed hence both the records results the
  -- data.
--*************************************************/
-- Commented the Code based on the Bug# 6497821
/*
    gc_pre_amt_appl := '  NVL(avprpv.prepay_amount_applied,0) pre_amt_appl_fr_curr '
                     ||' ,NVL(avprpv.prepay_amount_applied,0) * NVL(ai.exchange_rate,1) pre_amt_appl_fn_curr';
    gc_from_clause := ' ap_invoice_payments_all      aip '||
                      ' ,ap_checks_all                ac '||
                      ' ,(SELECT avprpv.org_id    org_id
                                ,avprpv.prepay_id prepay_id
                    ,avprpv.prepay_line_number    prepay_line_number
                    ,avprpv.prepay_amount_applied prepay_amount_applied
              FROM   ap_view_prepays_fr_prepay_v  avprpv
              WHERE  NVL(avprpv.accounting_date,:gd_from_date) <= :gd_from_date)  avprpv ';
    gc_where_clause := ' AND  ai.invoice_id = aip.invoice_id(+) '
                     ||' AND  aip.check_id  = ac.check_id(+) '
                     ||' AND  ail.invoice_id = avprpv.prepay_id(+) '
                     ||' AND  ail.line_number = avprpv.prepay_line_number(+) '
                     ||' AND  ail.org_id = avprpv.org_id(+) ';
*/
  gc_where_clause := ' AND 1 = 1 ';
  IF PAID_ONLY_PARAM = 'Y' THEN
    gc_where_clause := gc_where_clause ||' AND  ai.payment_status_flag = ''Y''';
  END IF;

/*--*************************************************
  -- Used for Report Specific conditions
  -- DUMMY_PARAM = 2 => Advances in Selected Currency Report
  --                    where it doesn't require TAX data
  -- DUMMY_PARAM = 3 => AP Prepayment Balance Report
  --                    where it require only ACTUAL Balance type data
  --                    Also must not display the Cancelled Prepayments/Invoices
--*************************************************/
  IF DUMMY_PARAM = 2 THEN
    gc_additional_where := ' AND ail.line_type_lookup_code NOT IN (''TAX'') ';
  ELSIF DUMMY_PARAM = 3 THEN
    gc_additional_where := ' AND ail.line_type_lookup_code NOT IN (''TAX'') '
                         ||' AND ai.cancelled_date IS NULL ';
  ELSE
    gc_additional_where := ' AND 1 = 1 ';
  END IF;

/*--*************************************************
  -- Identify whether the report must run for Single
  -- Operating unit or multiple based on P_ORG_ID
--*************************************************/
  IF ORG_ID_PARAM IS NOT NULL THEN
    gc_org_where := ' AND ai.org_id = :ORG_ID_PARAM ';
  ELSE
    gc_org_where := ' AND 1 = 1';
  END IF;
  fnd_file.put_line(fnd_file.log,'gc_org_where::'||gc_org_where);
  RETURN TRUE;
END beforereport;

FUNCTION PREPAY_AMT_APPLIED(p_invoice_id IN NUMBER,p_inv_date IN DATE)
RETURN NUMBER
IS
ln_inv_amt_ent  NUMBER;
BEGIN

SELECT NVL(sum(NVL(xdl.unrounded_ENTERED_dR,0)-NVL(xdl.unrounded_entered_cr,0)),0)
  INTO   ln_inv_amt_ent
  FROM   ap_invoices              ai
        ,ap_invoice_distributions aid
        ,ap_invoice_distributions aidinv
        ,ap_invoices              aiinv
        ,xla_ae_headers           xah --Perf 7511696 events replaced with headers
        ,xla_ae_lines             xal
        ,xla_distribution_links   xdl
  WHERE  ai.invoice_id=p_invoice_id
  AND    ai.invoice_date <= p_inv_date
  AND    aid.invoice_id=ai.invoice_id
  AND    aid.line_type_lookup_code='ITEM'
  AND    aidinv.prepay_distribution_id=aid.invoice_distribution_id
  AND    aiinv.invoice_id=aidinv.invoice_id
  AND    xah.event_type_code IN ('PREPAYMENT APPLIED','PREPAYMENT UNAPPLIED')
  AND    xah.event_id=aidinv.accounting_event_id
  AND    xdl.event_id=xah.event_id
  AND    xah.ae_header_id=xdl.ae_header_id
  AND    xah.ae_header_id=xal.ae_header_id
  AND    xal.ae_line_num=xdl.ae_line_num
  AND    xal.accounting_class_code='LIABILITY'
  AND    xah.application_id=200
  AND    xdl.application_id=200
  AND    xal.application_id=200;

  RETURN (ln_inv_amt_ent);
END PREPAY_AMT_APPLIED;

END AP_BAL_PKG;

/
