--------------------------------------------------------
--  DDL for Package AP_TURNOVER_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_TURNOVER_RPT_PKG" AUTHID CURRENT_USER AS
-- $Header: APTURNOVERRPTPS.pls 120.1 2008/05/27 14:43:52 rapulla noship $
-- ****************************************************************************************
-- Copyright (c)  2000  Oracle Corporation    Product Development
-- All rights reserved
-- ****************************************************************************************
--
-- PROGRAM NAME
-- APTURNOVERRPTPS.pls
--
-- DESCRIPTION
--  This script creates the package specification of AP_TURNOVER_RPT_PKG.
--  This package is used to generate AP Turnover Report.
--
-- USAGE
--   To install        How to Install
--   To execute        How to Execute
--
-- DEPENDENCIES
--   None.
--
--  beforereport        It is a public function used to intialize global variables
--                                which will be used to build the quries in the Data Template Dynamically
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

/*=========================================
Variables to Hold the Parameter Values
=========================================*/
LEDGER_ID_PARAM          NUMBER;
LEDGER_NAME_PARAM        VARCHAR2(30);
COA_ID_PARAM             NUMBER;
COA_ID_SUMRY_MASK_PARAM  NUMBER;
REPORT_TYPE_PARAM        NUMBER;
DUMMY_REPORT_TYPE_PARAM  VARCHAR2(240);
OU_FROM_PARAM            VARCHAR2(240);
OU_TO_PARAM              VARCHAR2(240);
PERIOD_START_DATE_PARAM  DATE;
PERIOD_END_DATE_PARAM    DATE;
SUPPLIER_FROM_PARAM      VARCHAR2(240);
SUPPLIER_TO_PARAM        VARCHAR2(240);
ACCT_FROM_PARAM          VARCHAR2(200);
ACCT_TO_PARAM            VARCHAR2(200);
CURRENCY_PARAM           VARCHAR2(15);
SHOW_OP_CURRENCY_PARAM   VARCHAR2(5);
REPORT_LEVEL_PARAM       NUMBER;
DUMMY_REPORT_LEVEL_PARAM VARCHAR2(240);
PRPMT_PROCESSING_PARAM   VARCHAR2(50);
SUMMARY_MASK_PARAM       VARCHAR2(50);

/*=========================================
Global Variables
=========================================*/
gc_supplier_where        VARCHAR2(500) := ' AND 1 = 1 ';
gc_currency_where        VARCHAR2(500) := ' AND 1 = 1 ';
gc_operunit_where        VARCHAR2(800) := ' AND 1 = 1 ';
gc_ledger_name           VARCHAR2(50);

gc_prepay_invoice_from   VARCHAR2(1000);
gc_prepay_invoice_select VARCHAR2(1000);
gc_prepay_invoice_where  VARCHAR2(1000);
gc_prepay_where          VARCHAR2(1000);
gn_open_payment_balance  NUMBER(20) := 0;
gn_open_invoice_balance  NUMBER(20) := 0;
g_open_balance           NUMBER(20) := 0;
gc_orderby               VARCHAR2(30);

/*=========================================
Public Functions
=========================================*/

FUNCTION beforeReport  RETURN BOOLEAN;
FUNCTION get_summary_mask_account(Acct_num IN VARCHAR2) RETURN VARCHAR2;
FUNCTION opening_balance(p_in_sup_id       IN NUMBER
                        ,p_in_sup_site_id  IN NUMBER
                        ,p_in_curr         IN VARCHAR2
                        ,p_in_code_comb_id IN NUMBER
                        ,p_in_orgs_id      IN NUMBER) RETURN NUMBER;
END AP_TURNOVER_RPT_PKG;

/
