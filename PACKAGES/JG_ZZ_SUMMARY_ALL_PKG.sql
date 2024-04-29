--------------------------------------------------------
--  DDL for Package JG_ZZ_SUMMARY_ALL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JG_ZZ_SUMMARY_ALL_PKG" 
-- $Header: jgzzsummaryalls.pls 120.6.12010000.4 2010/01/03 11:20:27 pakumare ship $
-- +======================================================================+
-- | Copyright (c) 1996 Oracle Corporation Redwood Shores, California, USA|
-- |                       All rights reserved.                           |
-- +======================================================================+
-- NAME:        JG_ZZ_SUMMARY_ALL_PKG
--
-- DESCRIPTION: This Package AUTHID CURRENT_USER is the default Package containing the Procedures
--              used by SUMMARY-ALL Extract
--
-- NOTES:
--
-- Change Record:
-- ===============
-- Version   Date        Author                     Remarks
-- =======  ===========  =========================  =======================+
-- DRAFT 1A 04-Feb-2006  Balachander Ganesh         Initial draft version
-- DRAFT 1B 21-Feb-2006  Balachander Ganesh         Updated with Review
--                                                  comments from IDC
-- DRAFT 1C 22-Feb-2006  Suresh Pasupunuri          Included the code for RTP
-- DRAFT 1C 27-Feb-2006  Suresh Pasupunuri	    sum_fixedformula, sum_other_formula,
--						    cf_total_vat_chargedformula, vat_total_chargedformula,
--						    cf_vat_total_inputformula functions are removed.
-- DRAFT 1D 23-Mar-2006	 Suresh Pasupunuri	    Added a function JEITPSSR_AMOUNT_TO_PAY for calculating
--						    the AMOUNT_TO_PAY for Italy Payables Summary VAT Report.
-- DRAFT 1E 03-Apr-2006	 Suresh Pasupunuri	    Added one new flag bit TEMP_FLAG. Usage in JEITPSSR_AMOUNT_TO_PAY
--							 function.
-- DRAFT 1F 29-Jan-2009  Rahul Kumar            Added one new function JEITPSSR_AMOUNT_TO_PAY_UPDATE.
-- +=======================================================================+
AS
  P_TRN_NUM             VARCHAR2(100);
  P_VAT_REP_ENTITY_ID   NUMBER;
  P_VAR_ON_PURCHASES    NUMBER;
  P_VAR_ON_SALES        NUMBER;
  P_PERIOD              VARCHAR2(100);
  P_VAT_BOX             VARCHAR2(100);
  P_VAT_TRX_TYPE_LOW    VARCHAR2(100);
  P_VAT_TRX_TYPE_HIGH   VARCHAR2(100);
  P_VAT_TRX_TYPE        VARCHAR2(100);
  P_REPORT_FORMAT       VARCHAR2(1);
  P_SOURCE              VARCHAR2(10);
  P_DOC_NAME            VARCHAR2(100);
  P_DOC_SEQ_VALUE       VARCHAR2(100);
  P_REPORT_NAME         VARCHAR2(20);
  P_LOCATION            VARCHAR2(100);
  L_ERR_MSG             VARCHAR2(5000);
  P_FUNC_CURR           VARCHAR2(10);
  P_LEGAL_ENTITY_NAME   VARCHAR2(240);
  P_BOX_FROM            VARCHAR2(10);
  P_BOX_TO              VARCHAR2(10);
  P_LEGAL_ENTITY_ID     NUMBER;
  P_DEBUG_FLAG          VARCHAR2(1) := 'Y';
  P_DETAIL_SUMMARY      VARCHAR2(30);
  P_FIRST_PAGE_NUM      NUMBER;
  TEMP_FLAG		NUMBER := 0;  --Flag variable for function JEITPSSR_AMOUNT_TO_PAY
 -- IL VAT Reporting 2010 - ER
  l_vat_rep_status_id	NUMBER;
  l_vat_aggregation_limit_amt NUMBER;
  g_precision           NUMBER;
  l_ledger_id           NUMBER;


  FUNCTION before_report
    RETURN BOOLEAN;
  FUNCTION a_real_tax_amount(p_payment_amt  IN NUMBER
                           , p_tax_amount   IN NUMBER
                           , p_cust_trx_id  IN NUMBER)
    RETURN NUMBER;
  FUNCTION a_real_invoice_amount(p_payment_amt    IN NUMBER
                               , p_invoice_amount IN NUMBER
                               , p_cust_trx_id    IN NUMBER)
    RETURN NUMBER;
  FUNCTION a_total_invoices(p_cust_trx_id IN NUMBER)
    RETURN NUMBER;

  FUNCTION get_report_format
    RETURN VARCHAR2;

  FUNCTION get_location_name
    RETURN VARCHAR2;

  FUNCTION get_start_exempt_limit
    RETURN NUMBER;

  FUNCTION get_adjustment_exempt_limit
    RETURN NUMBER;

  FUNCTION get_old_debit_vat
  RETURN NUMBER;

  PROCEDURE jebeva06(p_vat_rep_entity_id    IN    NUMBER
                    ,p_period               IN    VARCHAR2
                    ,p_vat_box              IN    VARCHAR2
                    ,p_vat_trx_type_low     IN    VARCHAR2
                    ,p_vat_trx_type_high    IN    VARCHAR2
                    ,p_source               IN    VARCHAR2
                    ,p_doc_name             IN    VARCHAR2
                    ,p_doc_seq_value        IN    VARCHAR2
                    ,x_err_msg              OUT NOCOPY  VARCHAR2);

  PROCEDURE jeptavat(p_vat_rep_entity_id    IN    NUMBER
                    ,p_period               IN    VARCHAR2
                    ,p_location             IN    VARCHAR2
                    ,x_err_msg              OUT NOCOPY  VARCHAR2);

  PROCEDURE jeptpvat(p_vat_rep_entity_id    IN    NUMBER
                    ,p_period               IN    VARCHAR2
                    ,p_location             IN    VARCHAR2
                    ,x_err_msg              OUT NOCOPY  VARCHAR2);

  PROCEDURE jeitpssr(p_vat_rep_entity_id    IN    NUMBER
                    ,p_period               IN    VARCHAR2
                    ,p_var_on_purchases     IN    NUMBER
                    ,p_var_on_sales         IN    NUMBER
                    ,x_err_msg              OUT  NOCOPY  VARCHAR2);

  FUNCTION JEITPSSR_AMOUNT_TO_PAY(A_TOT_TOT_TAX_AMT_SUM IN  NUMBER,
				  B_TOT_TAX_AMT_SUM IN  NUMBER,
				  D_TOT_TAX_AMT_SUM IN  NUMBER,
				  D_VAT_REC_SUM IN  NUMBER,
				  C_VAT_REC_SUM IN  NUMBER,
				  C_VAT_NON_RECC_SUM IN  NUMBER) RETURN NUMBER;
  FUNCTION JEILR835_INV_NUM( p_str IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION JEITPSSR_AMOUNT_TO_PAY_UPDATE(AMOUNT_TO_PAY IN NUMBER) RETURN BOOLEAN;

END JG_ZZ_SUMMARY_ALL_PKG;

/
