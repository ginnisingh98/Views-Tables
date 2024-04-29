--------------------------------------------------------
--  DDL for Package AP_BAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_BAL_PKG" 
-- $Header: APPREBCPS.pls 120.4.12010000.2 2009/09/23 23:33:11 vinaik ship $
-- ****************************************************************************************
-- Copyright (c)  2000  Oracle Solution Services (India)     Product Development
-- All rights reserved
-- ****************************************************************************************
--
-- PROGRAM NAME
--  APPREBCPS.pls
--
-- DESCRIPTION
--  This script creates the package specification of AP_PREPAY_BAL_PKG.
--  This package AUTHID CURRENT_USER is used to generate Prepayment Balance Report.
--
-- USAGE
--   To install        How to Install
--   To execute        How to Execute

-- DEPENDENCIES
--   None.
--
--PROGRAM LIST
--NAME               USAGE
--
--  get_ledger_name  Used to obtain the Ledger Name for which the report is running
--
--  get_no_of_holds  Used to obtain the number of holds for a particular Prepayment
--
--  beforereport     Used to initialize the dynamic variable based on the input
--                   obtained from parameters.
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
--
-- ****************************************************************************************
AS

/*=========================================
Variables to Hold the Parameter Values
=========================================*/
ORG_ID_PARAM        NUMBER;
COA_ID_PARAM        NUMBER;
FROM_DATE_PARAM     VARCHAR2(30);
TO_DATE_PARAM       VARCHAR2(30);
PERIOD_FROM_PARAM   VARCHAR2(30);
PERIOD_TO_PARAM     VARCHAR2(30);
CURR_CODE_PARAM     VARCHAR2(30);
ACCOUNT_FROM_PARAM  NUMBER;
ACCOUNT_TO_PARAM    NUMBER;
/*SUPPLIER_FROM_PARAM VARCHAR2(30);Bug 8923633 */
/*SUPPLIER_TO_PARAM   VARCHAR2(30);Bug 8923633 */
SUPPLIER_FROM_PARAM AP_SUPPLIERS.VENDOR_NAME%TYPE;/*Bug 8923633 */
SUPPLIER_TO_PARAM   AP_SUPPLIERS.VENDOR_NAME%TYPE;/*Bug 8923633 */
PAID_ONLY_PARAM     VARCHAR2(30);
POSTED_ONLY_PARAM   VARCHAR2(30);
DUMMY_PARAM         NUMBER;

/*=========================================
Variables to obtain dynamic values
=========================================*/

gc_currency     VARCHAR2(100);
gc_status       VARCHAR2(1000);
gc_org_where    VARCHAR2(100);
gc_ledger_name  VARCHAR2(40);

--gc_select_clause VARCHAR2(5000);
gc_from_clause  VARCHAR2(5000);
gc_where_clause VARCHAR2(5000);
gc_supplier     VARCHAR2(1000);
gc_pre_amt_appl VARCHAR2(1000);
gc_additional_where  VARCHAR2(1000);

gd_from_date    DATE;
gd_to_date      DATE;

/*=========================================
Public Functions
=========================================*/

FUNCTION beforereport RETURN BOOLEAN;
FUNCTION description(p_seg_value IN VARCHAR2,p_seg_type IN VARCHAR2) RETURN VARCHAR2;
FUNCTION get_no_of_holds(p_invoice_id IN NUMBER) RETURN NUMBER;
FUNCTION get_settlement_date(p_invoice_id IN NUMBER,p_line_number IN NUMBER) RETURN DATE;
FUNCTION prepay_amt_applied(p_invoice_id IN NUMBER,p_inv_date IN DATE) RETURN NUMBER;

END AP_BAL_PKG;

/
