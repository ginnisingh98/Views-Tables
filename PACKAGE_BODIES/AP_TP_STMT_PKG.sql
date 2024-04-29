--------------------------------------------------------
--  DDL for Package Body AP_TP_STMT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_TP_STMT_PKG" AS
-- $Header: APTPSTMTPB.pls 120.1.12010000.3 2010/03/05 13:32:08 ansethur ship $
/*===========================================================================+
--*************************************************************************
-- Copyright (c)  2000    Oracle                 Product Development
-- All rights reserved
--*************************************************************************
--
-- HEADER
--  Source control Body
--
-- PROGRAM NAME
--   APARTPSTMTPB.pls
--
-- DESCRIPTION
-- This script creates the package body of AP_TP_STMT_PKG
-- This package is used for Supplier Statement Reports.
--
-- USAGE
--   To install        sqlplus <apps_user>/<apps_pwd> @APTPSTMTPB.pls
--   To execute        sqlplus <apps_user>/<apps_pwd> AP_TP_STMT_PKG.
--
-- PROGRAM LIST        DESCRIPTION
--
-- BEFOREREPORT        This function is used to dynamically get the
--                     WHERE clause in SELECT statement.
--
-- DEPENDENCIES
-- None
--
-- CALLED BY
--
--
-- LAST UPDATE DATE    03-Sep-2007
-- Date the program has been modified for the last time.
--
-- HISTORY
-- =======
--
-- VERSION DATE        AUTHOR(S)       DESCRIPTION
-- ------- ----------- --------------- --------------------------------------
-- Draft1A 03-Sep-2007 Sandeep Kumar G Initial Creation
+===========================================================================*/

--=====================================================================
--=====================================================================
PROCEDURE set_to_payables
IS
BEGIN
FND_FILE.put_line(FND_FILE.log,'In Set to Payables');
--****************************************************
-- Based on P_REPORTING_ENTITY_ID the data will be filtered
-- else we receive all the Org Specific information
-- those are accesible for the Responsibility.
--****************************************************
  IF P_REPORTING_LEVEL = 1000 THEN
  -- Implies Reporting Level is Ledger
    gc_reporting_entity := ' AND hro.set_of_books_id  = :P_REPORTING_ENTITY_ID ';
    gc_org_id := ' AND gled.ledger_id  = :P_REPORTING_ENTITY_ID ';
    gc_pmt_org_id := ' AND gled.ledger_id  = :P_REPORTING_ENTITY_ID ';
  ELSIF P_REPORTING_LEVEL = 3000 THEN
  -- Implies Reporting Level is Operating Unit
    gc_reporting_entity := ' AND hro.organization_id  = :P_REPORTING_ENTITY_ID ';
    gc_org_id := ' AND ai.org_id  = :P_REPORTING_ENTITY_ID ';
    gc_pmt_org_id := ' AND ac.org_id = :P_REPORTING_ENTITY_ID ';
  END IF;

--****************************************************
-- Based on P_VEND_TYPE the data will be filtered
-- else we will fetch all the Supplier Types
--****************************************************
  IF P_VEND_TYPE IS NOT NULL THEN
    gc_vend_type := ' AND asup.vendor_type_lookup_code = :P_VEND_TYPE ';
  END IF;
FND_FILE.put_line(FND_FILE.log,'gc_vend_type := '||gc_vend_type);
--****************************************************
-- Based on P_PAY_GROUP the data will be filtered
-- else Suppliers irrespective of their Pay Group will be picked
--****************************************************
  IF P_PAY_GROUP IS NOT NULL THEN
    gc_pay_group := ' AND asup.pay_group_lookup_code = :P_PAY_GROUP ';
  END IF;
FND_FILE.put_line(FND_FILE.log,'gc_pay_group := '||gc_pay_group);
--****************************************************
-- Based on P_CURRENCY the data will be filtered
-- else we receive the information for all Currencies
--****************************************************
  IF P_CURRENCY <> 'ANY' THEN
    gc_currency := ' AND ai.invoice_currency_code = :P_CURRENCY ';
    gc_pmt_currency := ' AND ac.currency_code = :P_CURRENCY ';
  END IF;
--****************************************************
-- Based on P_ACCOUNTED the data will be filtered
-- for 'Accounted' --> Only Accounted Records will be fetched
-- for 'Unaccounted' --> Only Unaccounted Records will be fetched
-- for 'Both' --> Both Accounted/Unaccounted Records will be fetched
--****************************************************
  IF P_ACCOUNTED = 'ACCOUNTED' THEN
    gc_pmt_accounted := ' AND aip.posted_flag = ''Y'' ';
  ELSIF P_ACCOUNTED = 'UNACCOUNTED' THEN
    gc_pmt_accounted := ' AND aip.posted_flag = ''N'' ';
  END IF;
--****************************************************
-- Based on P_UNVALIDATED_TRX the data will be filtered
-- for 'Y' --> Pick all Transactions (Validated/Unvalidated)
-- for 'N' --> Pick Only Validated Transactions
--****************************************************
  IF P_UNVALIDATED_TRX = 'N' THEN
    gc_validate_inv := ' AND ai.invoice_id IN  ';
    gc_validate_inv :=  gc_validate_inv||' (SELECT i.invoice_id';
    gc_validate_inv :=  gc_validate_inv||' FROM ap_invoices_all i, ap_invoice_distributions d';
    gc_validate_inv :=  gc_validate_inv||' WHERE d.invoice_id = i.invoice_id';
    gc_validate_inv :=  gc_validate_inv||' AND i.invoice_id = ai.invoice_id';
     gc_validate_inv :=  gc_validate_inv||' AND d.posted_flag IN (''N'', ''Y'')';  --Included correct validation status , Bug9397505
     gc_validate_inv :=  gc_validate_inv||' AND i.validation_request_id IS NULL';
     gc_validate_inv :=  gc_validate_inv||' AND (   ';
     gc_validate_inv :=  gc_validate_inv||' NOT EXISTS (';
     gc_validate_inv :=  gc_validate_inv||' SELECT ''Unreleased Hold exists''';
     gc_validate_inv :=  gc_validate_inv||' FROM ap_holds h';
     gc_validate_inv :=  gc_validate_inv||' WHERE h.invoice_id = i.invoice_id';
     gc_validate_inv :=  gc_validate_inv||' AND h.hold_lookup_code IN';
     gc_validate_inv :=  gc_validate_inv||' (''QTY ORD'', ''QTY REC'', ''AMT ORD'', ''AMT REC'',';
     gc_validate_inv :=  gc_validate_inv||' ''QUALITY'', ''PRICE'', ''TAX DIFFERENCE'',';
     gc_validate_inv :=  gc_validate_inv||' ''CURRENCY DIFFERENCE'', ''REC EXCEPTION'',';
     gc_validate_inv :=  gc_validate_inv||' ''TAX VARIANCE'', ''PO NOT APPROVED'', ''PO REQUIRED'',';
     gc_validate_inv :=  gc_validate_inv||' ''MAX SHIP AMOUNT'', ''MAX RATE AMOUNT'',';
     gc_validate_inv :=  gc_validate_inv||' ''MAX TOTAL AMOUNT'', ''TAX AMOUNT RANGE'',';
     gc_validate_inv :=  gc_validate_inv||' ''MAX QTY ORD'', ''MAX QTY REC'', ''MAX AMT ORD'',';
     gc_validate_inv :=  gc_validate_inv||' ''MAX AMT REC'', ''CANT CLOSE PO'', ''CANT TRY PO CLOSE'',';
     gc_validate_inv :=  gc_validate_inv||' ''LINE VARIANCE'')';
     gc_validate_inv :=  gc_validate_inv||' AND h.release_lookup_code IS NULL)))';
  END IF;
--****************************************************
-- Based on P_UNAPPROVED_TRX the data will be filtered
-- The Parameter says to Pick Only Approved Invoices or All
-- for 'Y' --> Pick all Transactions (Unapproved/Approved/Approval Not Required)
-- for 'N' --> Pick Only Approved/Approval Not Required Transactions
--****************************************************
  IF P_UNAPPROVED_TRX = 'N' THEN
    gc_unapproved_trx := ' AND ai.wfapproval_status IN (''ACCEPT'',''APPROVED'',''MANUALLY APPROVED'',''NOT REQUIRED'',''WFAPPROVED'',''ACKNOWLEDGE'',''CANCEL'',''CANCELLED'') ';
  END IF;
END set_to_payables;

--=====================================================================
--=====================================================================
FUNCTION beforereport RETURN BOOLEAN
IS
BEGIN
    set_to_payables();
-- The Parameters that are common to both the Modules are set here
--****************************************************
-- Based on P_FROM_SUPP_NAME and P_TO_SUPP_NAME the
-- data will be filtered else we receive the information
-- for all the Customers
--****************************************************
  IF P_FROM_SUPP_NAME IS NOT NULL AND P_TO_SUPP_NAME IS NOT NULL THEN
    gc_supplier_name := ' AND asup.vendor_name >= :P_FROM_SUPP_NAME
                          AND asup.vendor_name <= :P_TO_SUPP_NAME ';
  ELSIF P_FROM_SUPP_NAME IS NULL AND P_TO_SUPP_NAME IS NOT NULL THEN
    gc_supplier_name := ' AND asup.vendor_name <= :P_TO_SUPP_NAME ';
  ELSIF P_FROM_SUPP_NAME IS NOT NULL AND P_TO_SUPP_NAME IS NULL THEN
    gc_supplier_name := ' AND asup.vendor_name >= :P_FROM_SUPP_NAME ';
  END IF;
  RETURN (TRUE);
END beforereport;

--=====================================================================
--=====================================================================
FUNCTION invoice_validate_status (p_in_inv_id IN NUMBER)
RETURN VARCHAR2
IS
  ln_inv_id NUMBER;
BEGIN
  SELECT count(1)
    INTO ln_inv_id
    FROM (SELECT i.invoice_id invoice_id
  FROM ap_invoices_all i, ap_invoice_distributions d
 WHERE d.invoice_id = i.invoice_id
   AND i.invoice_id = p_in_inv_id
   AND d.posted_flag IN ('N', 'Y')  --Included correct validation status , Bug9397505
   AND i.validation_request_id IS NULL
   AND (  NOT EXISTS (
              SELECT 'Unreleased Hold exists'
                FROM ap_holds h
               WHERE h.invoice_id = i.invoice_id
                 AND h.hold_lookup_code IN
                        ('QTY ORD', 'QTY REC', 'AMT ORD', 'AMT REC',
                         'QUALITY', 'PRICE', 'TAX DIFFERENCE',
                         'CURRENCY DIFFERENCE', 'REC EXCEPTION',
                         'TAX VARIANCE', 'PO NOT APPROVED', 'PO REQUIRED',
                         'MAX SHIP AMOUNT', 'MAX RATE AMOUNT',
                         'MAX TOTAL AMOUNT', 'TAX AMOUNT RANGE',
                         'MAX QTY ORD', 'MAX QTY REC', 'MAX AMT ORD',
                         'MAX AMT REC', 'CANT CLOSE PO', 'CANT TRY PO CLOSE',
                         'LINE VARIANCE')
                 AND h.release_lookup_code IS NULL)));
  IF ln_inv_id <> 0 THEN
  --Bug9252303: Added quotes to sync the return value with return type.
  --Bug9397505 : changed Y/N to 1/0 to support rft format.
  RETURN ('Y');
  ELSE
  RETURN ('N');
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN('N');
END invoice_validate_status;
--=====================================================================
--=====================================================================
FUNCTION balance_brought_forward (p_in_vendor_id      IN NUMBER
                                 ,p_in_vendor_site_id IN NUMBER
                                 ,p_in_org_id         IN NUMBER)
RETURN NUMBER
IS
  ln_amount NUMBER;
BEGIN
  SELECT SUM(DECODE(transaction_type,'P',-1*accounted_amount,accounted_amount)) amount
  INTO ln_amount
  FROM
    (     SELECT 'I'  transaction_type
           ,SUM(NVL(ai.invoice_amount * NVL(ai.exchange_rate,1),0)) accounted_amount
     FROM  ap_invoices ai
     WHERE ai.vendor_id = p_in_vendor_id
     AND   ai.vendor_site_id = p_in_vendor_site_id
     AND   ai.invoice_type_lookup_code  <> 'PREPAYMENT'  --Bug9252303
     AND   ai.gl_date < TO_DATE(P_FROM_GL_DATE,'RRRR/MM/DD HH24:MI:SS')
     AND   ai.invoice_currency_code = NVL2(P_CURRENCY,DECODE(P_CURRENCY,'ANY',ai.invoice_currency_code,P_CURRENCY),ai.invoice_currency_code)
     AND   ai.org_id = p_in_org_id
     AND   ((AP_TP_STMT_PKG.invoice_validate_status(ai.invoice_id) = 'Y'    --'Y' Bug9252303
        AND P_UNVALIDATED_TRX = 'N')
        OR P_UNVALIDATED_TRX = 'Y')
     AND  AP_INVOICES_PKG.get_posting_status(ai.invoice_id)
                             = DECODE(P_ACCOUNTED,'ACCOUNTED','Y'
                                                 ,'UNACCOUNTED','N'
                                             ,AP_INVOICES_PKG.get_posting_status(ai.invoice_id))
     AND ((P_UNAPPROVED_TRX = 'N'
     AND ai.wfapproval_status IN ('ACCEPT','APPROVED','MANUALLY APPROVED','NOT REQUIRED','WFAPPROVED','ACKNOWLEDGE','CANCEL','CANCELLED'))
     OR (P_UNAPPROVED_TRX = 'Y' ))
     UNION ALL
     SELECT 'P' transaction_type
           ,SUM(NVL(aip.amount * NVL(aip.exchange_rate,1),0)) accounted_amount
     FROM   ap_invoice_payments aip
           ,ap_checks ac
     WHERE aip.check_id = ac.check_id
     AND   ac.vendor_id = p_in_vendor_id
     AND   ac.vendor_site_id = p_in_vendor_site_id
     AND   ac.check_date < TO_DATE(P_FROM_DOC_DATE,'RRRR/MM/DD HH24:MI:SS')
     AND   aip.accounting_date < TO_DATE(P_FROM_GL_DATE,'RRRR/MM/DD HH24:MI:SS')
     AND   ac.org_id = p_in_org_id
     AND   ac.currency_code = NVL2(P_CURRENCY,DECODE(P_CURRENCY,'ANY',ac.currency_code,P_CURRENCY),ac.currency_code)
     AND ((P_ACCOUNTED = 'ACCOUNTED' AND aip.posted_flag = 'Y')
              OR (P_ACCOUNTED = 'UNACCOUNTED' AND aip.posted_flag = 'N')
         OR (P_ACCOUNTED = 'BOTH'))
	--Bug9252303: Commented below query that selects prepayment applications.
    /* UNION ALL
     SELECT 'A' transaction_type
           ,SUM((NVL(aid.amount,0)* NVL(ai.exchange_rate,1))*-1) amount_applied
     FROM   ap_invoices ai
           ,ap_invoice_distributions_all aid
           ,ap_invoices aipre
           ,ap_invoice_distributions_all aidpre
     WHERE ai.invoice_id = aid.invoice_id
     AND   aid.prepay_distribution_id = aidpre.invoice_distribution_id
     AND   aipre.invoice_id = aidpre.invoice_id
     AND   aid.accounting_date < TO_DATE(P_FROM_GL_DATE,'RRRR/MM/DD HH24:MI:SS')
     AND   ai.vendor_id = p_in_vendor_id
     AND   ai.vendor_site_id = p_in_vendor_site_id
     AND   ai.invoice_currency_code = NVL2(P_CURRENCY,DECODE(P_CURRENCY,'ANY',ai.invoice_currency_code,P_CURRENCY),ai.invoice_currency_code)
     AND   ai.org_id = p_in_org_id
     AND   ai.wfapproval_status NOT IN ('CANCEL','CANCELLED')
     AND  AP_INVOICES_PKG.get_posting_status(ai.invoice_id)
                             = DECODE(P_ACCOUNTED,'ACCOUNTED','Y'
                                                  ,'UNACCOUNTED','N'
                                                  ,AP_INVOICES_PKG.get_posting_status(ai.invoice_id))
     AND ((P_UNAPPROVED_TRX = 'N'
     AND ai.wfapproval_status IN ('ACCEPT','APPROVED','MANUALLY APPROVED','NOT REQUIRED','WFAPPROVED','ACKNOWLEDGE'))
     OR (P_UNAPPROVED_TRX = 'Y' ))*/
    );
  RETURN (NVL(ln_amount,0));
END balance_brought_forward;

END AP_TP_STMT_PKG;

/
