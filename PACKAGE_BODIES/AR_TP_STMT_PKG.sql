--------------------------------------------------------
--  DDL for Package Body AR_TP_STMT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_TP_STMT_PKG" AS
-- $Header: ARSTMTRPTPB.pls 120.2 2008/03/05 13:54:33 sgudupat noship $
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
--   ARSTMTRPTPB.pls
--
-- DESCRIPTION
-- This script creates the package body of AR_TP_STMT_PKG
-- This package is used for Supplier/Customer Statement Reports.
--
-- USAGE
--   To install        sqlplus <apps_user>/<apps_pwd> @ARSTMTRPTPB.pls
--   To execute        sqlplus <apps_user>/<apps_pwd> AR_TP_STMT_PKG.
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
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
PROCEDURE set_to_receivables
IS
BEGIN
--****************************************************
-- Based on P_REPORTING_LEVEL the data will be filtered
-- else we receive all the Org Specific information
-- those are accesible for the Responsibility.
--****************************************************
--  IF P_ORG_ID IS NOT NULL THEN
--    gc_org_id := ' AND rct.org_id  = :P_ORG_ID ';
--    gc_rcpt_org_id := ' AND acr.org_id = :P_ORG_ID ';
--  END IF;

  IF P_REPORTING_LEVEL = 1000 THEN
  -- Implies Reporting Level is Ledger
    gc_reporting_entity := ' AND hou.set_of_books_id  = :P_REPORTING_ENTITY_ID ';
    gc_org_id := ' AND gled.ledger_id  = :P_REPORTING_ENTITY_ID ';
    gc_rcpt_org_id := ' AND gled.ledger_id = :P_REPORTING_ENTITY_ID ';
  ELSIF P_REPORTING_LEVEL = 3000 THEN
  -- Implies Reporting Level is Operating Unit
    gc_reporting_entity := ' AND hou.organization_id  = :P_REPORTING_ENTITY_ID ';
    gc_org_id := ' AND rct.org_id  = :P_REPORTING_ENTITY_ID ';
    gc_rcpt_org_id := ' AND acr.org_id = :P_REPORTING_ENTITY_ID ';
  ELSIF P_REPORTING_LEVEL = 2000 THEN
  -- Implies Reporting Level is Legal Entity
--    gc_reporting_entity := ' AND hou.organization_id  = :P_REPORTING_ENTITY_ID ';
    gc_org_id := ' AND rct.legal_entity_id  = :P_REPORTING_ENTITY_ID ';
    gc_rcpt_org_id := ' AND acr.legal_entity_id = :P_REPORTING_ENTITY_ID ';
  END IF;
  IF PG_DEBUG in ('Y', 'C') THEN
    arp_util.debug('gc_reporting_entity : ' || gc_reporting_entity);
    arp_util.debug('gc_org_id : ' || gc_org_id);
    arp_util.debug('gc_rcpt_org_id : ' || gc_rcpt_org_id);
  END IF;
--****************************************************
-- Based on P_CUST_CLASS the data will be filtered
-- else we will fetch all the Customers of any Customer Class
--****************************************************
  IF P_CUST_CLASS IS NOT NULL THEN
    gc_cust_class := ' AND hca.customer_class_code = :P_CUST_CLASS ';
  END IF;
  IF PG_DEBUG in ('Y', 'C') THEN
    arp_util.debug('gc_cust_class : ' || gc_cust_class);
  END IF;
--****************************************************
-- Based on P_CUST_CATEGORY the data will be filtered
-- else we will fetch all the Customers of any Customer Category
--****************************************************
  IF P_CUST_CATEGORY IS NOT NULL THEN
    gc_cust_category := ' AND hpar.category_code = :P_CUST_CATEGORY ';
  END IF;
  IF PG_DEBUG in ('Y', 'C') THEN
    arp_util.debug('gc_cust_category : ' || gc_cust_category);
  END IF;
--****************************************************
-- Based on P_CURRENCY the data will be filtered
-- else we receive the information for all Currencies
--****************************************************
  IF P_CURRENCY <> 'ANY' THEN
    gc_currency := ' AND rct.invoice_currency_code = :P_CURRENCY ';
    gc_rcpt_currency := ' AND acr.currency_code = :P_CURRENCY ';
  END IF;
  IF PG_DEBUG in ('Y', 'C') THEN
    arp_util.debug('gc_currency : ' || gc_currency);
    arp_util.debug('gc_rcpt_currency : ' || gc_rcpt_currency);
  END IF;
--****************************************************
-- Based on P_ACCOUNTED the data will be filtered
-- for 'Accounted' --> Only Accounted Records will be fetched
-- for 'Unaccounted' --> Only Unaccounted Records will be fetched
-- for 'Both' --> Both Accounted/Unaccounted Records will be fetched
--****************************************************
  IF P_ACCOUNTED = 'ACCOUNTED' THEN
    gc_accounted := ' AND rctld.posting_control_id <> -3 ';
    gc_rcpt_accounted := ' AND acrh.posting_control_id <> -3 ';
    gc_adj_accounted := ' AND aa.posting_control_id <> -3 ';
	gc_app_accounted := ' AND ara.posting_control_id <> -3 ';
  ELSIF P_ACCOUNTED = 'UNACCOUNTED' THEN
    gc_accounted := ' AND rctld.posting_control_id = -3 ';
    gc_rcpt_accounted := ' AND acrh.posting_control_id = -3 ';
    gc_adj_accounted := ' AND aa.posting_control_id = -3 ';
	gc_app_accounted := ' AND ara.posting_control_id = -3 ';
  END IF;
  IF PG_DEBUG in ('Y', 'C') THEN
    arp_util.debug('gc_accounted : ' || gc_accounted);
    arp_util.debug('gc_rcpt_accounted : ' || gc_rcpt_accounted);
    arp_util.debug('gc_adj_accounted : ' || gc_adj_accounted);
    arp_util.debug('gc_app_accounted : ' || gc_app_accounted);
  END IF;
--****************************************************
-- Based on P_INCOMPLETE_TRX the data will be filtered
-- for 'Y' --> Pick all Transactions (Complete/Incomplete)
-- for 'N' --> Pick Only Completed Transactions
--****************************************************
  IF P_INCOMPLETE_TRX = 'N' THEN
    gc_incomplete_trx := ' AND rct.complete_flag = ''Y'' ';
  END IF;
  IF PG_DEBUG in ('Y', 'C') THEN
    arp_util.debug('gc_incomplete_trx : ' || gc_incomplete_trx);
  END IF;
END set_to_receivables;
--**********************************************************
-- Before Report function used to obtain the Dynamic Queries
-- Based on the Input Parameter Values
--**********************************************************
FUNCTION beforereport RETURN BOOLEAN
IS
BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
    arp_util.debug('P_REPORTING_LEVEL       : '||P_REPORTING_LEVEL);
    arp_util.debug('P_REPORTING_ENTITY_ID   : '||P_REPORTING_ENTITY_ID);
    arp_util.debug('P_REPORTING_ENTITY_NAME : '||P_REPORTING_ENTITY_NAME);
    arp_util.debug('P_FROM_DOC_DATE         : '||P_FROM_DOC_DATE);
    arp_util.debug('P_TO_DOC_DATE           : '||P_TO_DOC_DATE);
    arp_util.debug('P_FROM_GL_DATE          : '||P_FROM_GL_DATE);
    arp_util.debug('P_TO_GL_DATE            : '||P_TO_GL_DATE);
    arp_util.debug('P_FROM_CUST_NAME        : '||P_FROM_CUST_NAME);
    arp_util.debug('P_TO_CUST_NAME          : '||P_TO_CUST_NAME);
    arp_util.debug('P_CURRENCY              : '||P_CURRENCY);
    arp_util.debug('P_CUST_CATEGORY         : '||P_CUST_CATEGORY);
    arp_util.debug('P_CUST_CLASS            : '||P_CUST_CLASS);
    arp_util.debug('P_INCOMPLETE_TRX        : '||P_INCOMPLETE_TRX);
    arp_util.debug('P_ACCOUNTED             : '||P_ACCOUNTED);
  END IF;
  set_to_receivables();
--****************************************************
-- Based on P_FROM_CUST_NAME and P_TO_CUST_NAME the
-- data will be filtered else we receive the information
-- for all the Customers
--****************************************************
  IF P_FROM_CUST_NAME IS NOT NULL AND P_TO_CUST_NAME IS NOT NULL THEN
    gc_customer_name := ' AND hpar.party_name >= :P_FROM_CUST_NAME
                          AND hpar.party_name <= :P_TO_CUST_NAME ';
  ELSIF P_FROM_CUST_NAME IS NULL AND P_TO_CUST_NAME IS NOT NULL THEN
    gc_customer_name := ' AND hpar.party_name <= :P_TO_CUST_NAME ';
  ELSIF P_FROM_CUST_NAME IS NOT NULL AND P_TO_CUST_NAME IS NULL THEN
    gc_customer_name := ' AND hpar.party_name >= :P_FROM_CUST_NAME ';
  ELSE
    gc_customer_name := ' AND 1 = 1 ';
  END IF;
  IF PG_DEBUG in ('Y', 'C') THEN
    arp_util.debug('gc_customer_name : ' || gc_customer_name);
  END IF;
  RETURN (TRUE);
END beforereport;
--**********************************************************
-- Balance forward function used to obtain the Opening Balance
-- Of a Customer at Site Level
--**********************************************************

FUNCTION balance_brought_forward (p_in_cust_account_id IN NUMBER
                                 ,p_in_site_use_id     IN NUMBER
                                 ,p_in_org_id          IN NUMBER)
RETURN NUMBER
IS
  ln_amount NUMBER := 0;
BEGIN
  SELECT SUM(DECODE(trx_type,'R',-1*accounted_amount,accounted_amount)) amount
  INTO ln_amount
  FROM (SELECT 'T'                    trx_type
      ,SUM(NVL(rctld.acctd_amount,0)) accounted_amount
 FROM  ra_customer_trx          rct
      ,ra_cust_trx_line_gl_dist_all rctld
	  ,ra_cust_trx_types_all    rctt
 WHERE rct.customer_trx_id     = rctld.customer_trx_id
   AND rct.cust_trx_type_id       = rctt.cust_trx_type_id
   AND rct.org_id                 = rctt.org_id
   AND rctld.latest_rec_flag   = 'Y'
   AND rctld.account_class     = 'REC'
   AND rctt.post_to_gl = 'Y'
   AND rctt.type IN ('CB','INV','DM','CM','BR','DEP')
   AND rctld.gl_date < TO_DATE(P_FROM_GL_DATE,'RRRR/MM/DD HH24:MI:SS')
   AND rct.bill_to_customer_id = p_in_cust_account_id
   AND rct.bill_to_site_use_id  = p_in_site_use_id
   AND rct.org_id = p_in_org_id
   AND rct.invoice_currency_code = NVL2(P_CURRENCY,DECODE(P_CURRENCY,'ANY',rct.invoice_currency_code,P_CURRENCY),rct.invoice_currency_code)
   AND rct.complete_flag = DECODE(P_INCOMPLETE_TRX,'N','Y', rct.complete_flag)
   AND ( (P_ACCOUNTED = 'ACCOUNTED' AND rctld.posting_control_id <> -3 )
     OR (P_ACCOUNTED = 'UNACCOUNTED' AND rctld.posting_control_id = -3 )
	 OR (P_ACCOUNTED = 'BOTH'))
UNION ALL
SELECT 'R'                      trx_type
      ,SUM(NVL(acr.amount * NVL(acr.exchange_rate,1),0)) accounted_amount
 FROM  ar_cash_receipts          acr
      ,ar_cash_receipt_history_all acrh
 WHERE acr.cash_receipt_id     = acrh.cash_receipt_id
   AND acr.org_id              = acrh.org_id
   AND acrh.first_posted_record_flag = 'Y'
   AND acrh.gl_date < TO_DATE(P_FROM_GL_DATE,'RRRR/MM/DD HH24:MI:SS')
   AND acr.pay_from_customer = p_in_cust_account_id
   AND acr.customer_site_use_id  = p_in_site_use_id
   AND acr.org_id = p_in_org_id
   AND acr.currency_code = NVL2(P_CURRENCY,DECODE(P_CURRENCY,'ANY',acr.currency_code,P_CURRENCY),acr.currency_code)
   AND ( (P_ACCOUNTED = 'ACCOUNTED' AND acrh.posting_control_id <> -3 )
      OR (P_ACCOUNTED = 'UNACCOUNTED' AND acrh.posting_control_id = -3 )
	  OR (P_ACCOUNTED = 'BOTH'))
UNION ALL
SELECT 'RE'                      trx_type
      ,SUM(NVL(acr.amount * NVL(acr.exchange_rate,1),0)) accounted_amount
 FROM  ar_cash_receipts          acr
      ,ar_cash_receipt_history_all acrh
 WHERE acr.cash_receipt_id     = acrh.cash_receipt_id
   AND acr.org_id              = acrh.org_id
   AND acr.reversal_date IS NOT NULL
   AND acrh.current_record_flag = 'Y'
   AND acrh.gl_date < TO_DATE(P_FROM_GL_DATE,'RRRR/MM/DD HH24:MI:SS')
   AND acr.pay_from_customer = p_in_cust_account_id
   AND acr.customer_site_use_id  = p_in_site_use_id
   AND acr.org_id = p_in_org_id
   AND acr.currency_code = NVL2(P_CURRENCY,DECODE(P_CURRENCY,'ANY',acr.currency_code,P_CURRENCY),acr.currency_code)
   AND ( (P_ACCOUNTED = 'ACCOUNTED' AND acrh.posting_control_id <> -3 )
       OR (P_ACCOUNTED = 'UNACCOUNTED' AND acrh.posting_control_id = -3 )
	   OR (P_ACCOUNTED = 'BOTH'))
UNION ALL
SELECT 'A'                         trx_type
      ,SUM(NVL(aa.acctd_amount,0)) accounted_amount
 FROM  ar_adjustments           aa
      ,ra_customer_trx_all      rct
	  ,ra_cust_trx_types_all    rctt
 WHERE rct.customer_trx_id     = aa.customer_trx_id
   AND rct.org_id              = aa.org_id
   AND rct.cust_trx_type_id    = rctt.cust_trx_type_id
   AND rct.org_id              = rctt.org_id
   AND aa.status = 'A' -- For approved Adjustments
   AND aa.gl_date < TO_DATE(P_FROM_GL_DATE,'RRRR/MM/DD HH24:MI:SS')
   AND rct.bill_to_customer_id = p_in_cust_account_id
   AND rct.bill_to_site_use_id  = p_in_site_use_id
   AND rct.org_id  = p_in_org_id
   AND rctt.post_to_gl         = 'Y' -- Only Postable to GL are picked
   AND rctt.type  IN ('CB','INV','DM','CM','BR','DEP') -- Guarantees are not picked
   AND rct.invoice_currency_code = NVL2(P_CURRENCY,DECODE(P_CURRENCY,'ANY',rct.invoice_currency_code,P_CURRENCY),rct.invoice_currency_code)
   AND rct.complete_flag = DECODE(P_INCOMPLETE_TRX,'N','Y', rct.complete_flag)
   AND ( (P_ACCOUNTED = 'ACCOUNTED' AND aa.posting_control_id <> -3)
      OR (P_ACCOUNTED = 'UNACCOUNTED' AND aa.posting_control_id = -3)
	  OR (P_ACCOUNTED = 'BOTH'))
UNION ALL
SELECT 'RE'                               trx_type
      ,SUM(ara.acctd_amount_applied_from) accounted_amount
FROM  ar_cash_receipts               acr
     ,ar_receivable_applications_all ara
     ,ar_receivables_trx_all         art
WHERE acr.cash_receipt_id        = ara.cash_receipt_id
  AND acr.org_id                 = ara.org_id
  AND ara.receivables_trx_id     = art.receivables_trx_id
  AND ara.org_id                 = art.org_id
  AND ara.gl_date < TO_DATE(P_FROM_GL_DATE,'RRRR/MM/DD HH24:MI:SS')
  AND acr.pay_from_customer = p_in_cust_account_id
  AND acr.customer_site_use_id  = p_in_site_use_id
  AND acr.org_id = p_in_org_id
  AND art.type  = 'WRITEOFF'
  AND acr.currency_code = NVL2(P_CURRENCY,DECODE(P_CURRENCY,'ANY',acr.currency_code,P_CURRENCY),acr.currency_code)
  AND ( (P_ACCOUNTED = 'ACCOUNTED' AND ara.posting_control_id <> -3)
     OR (P_ACCOUNTED = 'UNACCOUNTED' AND ara.posting_control_id = -3)
	 OR (P_ACCOUNTED = 'BOTH')));
  RETURN (NVL(ln_amount,0));
END balance_brought_forward;

FUNCTION contact_details(p_owner_table_id IN NUMBER
                        ,p_contact_type IN VARCHAR2)
RETURN VARCHAR2
IS
  lc_cust_phone_number VARCHAR2(1000);
  lc_primary_flag      VARCHAR2(1);
BEGIN
  IF p_contact_type <> 'FAX' THEN
  BEGIN
    SELECT REPLACE(LTRIM(hcp.phone_area_code||'-'||
                   hcp.phone_country_code||'-'||
                   hcp.phone_number,'-'),'--','-')
          ,hcp.primary_flag
    INTO   lc_cust_phone_number
          ,lc_primary_flag
    FROM   hz_contact_points hcp
    WHERE  hcp.status = 'A'
    AND    hcp.owner_table_id = p_owner_table_id
    AND    hcp.contact_point_type = 'PHONE'
    AND    hcp.phone_line_type IN ('GEN','PHONE','MOBILE')
    AND    hcp.primary_flag = 'Y';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      SELECT REPLACE(LTRIM(hcp.phone_area_code||'-'||
                   hcp.phone_country_code||'-'||
                   hcp.phone_number,'-'),'--','-')
            ,hcp.primary_flag
      INTO   lc_cust_phone_number
            ,lc_primary_flag
      FROM   hz_contact_points hcp
      WHERE  hcp.contact_point_id = (SELECT MIN(hcp1.contact_point_id)
                                     FROM   hz_contact_points hcp1
                                     WHERE  hcp1.status = 'A'
                                     AND    hcp1.owner_table_id = p_owner_table_id
                                     AND    hcp1.contact_point_type = 'PHONE'
                                     AND    hcp1.phone_line_type IN ('GEN','PHONE','MOBILE'));
  END;
  ELSE
  BEGIN
    SELECT REPLACE(LTRIM(hcp.phone_area_code||'-'||
                   hcp.phone_country_code||'-'||
                   hcp.phone_number,'-'),'--','-')
          ,hcp.primary_flag
    INTO   lc_cust_phone_number
          ,lc_primary_flag
    FROM   hz_contact_points hcp
    WHERE  hcp.status = 'A'
    AND    hcp.owner_table_id = p_owner_table_id
    AND    hcp.contact_point_type = 'PHONE'
    AND    hcp.phone_line_type = 'FAX'
    AND    hcp.primary_flag = 'Y';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      SELECT REPLACE(LTRIM(hcp.phone_area_code||'-'||
                   hcp.phone_country_code||'-'||
                   hcp.phone_number,'-'),'--','-')
            ,hcp.primary_flag
      INTO   lc_cust_phone_number
            ,lc_primary_flag
      FROM   hz_contact_points hcp
      WHERE  hcp.contact_point_id = (SELECT MIN(hcp1.contact_point_id)
                                     FROM   hz_contact_points hcp1
                                     WHERE  hcp1.status = 'A'
                                     AND    hcp1.owner_table_id = p_owner_table_id
                                     AND    hcp1.contact_point_type = 'PHONE'
                                     AND    hcp1.phone_line_type  = 'FAX');
  END;
  END IF;
RETURN (lc_primary_flag||lc_cust_phone_number);
END contact_details;

END AR_TP_STMT_PKG;

/
