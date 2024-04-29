--------------------------------------------------------
--  DDL for Package AP_PREPAY_TRAK_REP_TURK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_PREPAY_TRAK_REP_TURK_PKG" AUTHID CURRENT_USER AS
-- $Header: APPPTRPS.pls 120.3 2007/10/31 06:46:56 sgudupat noship $
-- ****************************************************************************************
-- Copyright (c)  2000  Oracle Solution Services (India)     Product Development
-- All rights reserved
-- ****************************************************************************************
--
-- PROGRAM NAME
-- APPPTRPS.pls
--
-- DESCRIPTION
--  This script creates the package body of APPPTRPS.pls.
--  This package is used to generate Prepayment Tracking Report for Turkey.
--
-- USAGE
--   To install        How to Install
--   To execute        How to Execute
--
-- DEPENDENCIES
--   None.
--
--
-- LAST UPDATE DATE   26-JAN-2007
--   Date the program has been modified for the last time
--
-- HISTORY
-- =======
--
-- VERSION DATE        AUTHOR(S)         DESCRIPTION
-- ------- ----------- ---------------   ------------------------------------
-- 1.0    26-JAN-2007 Pgollu M Creation
--
--****************************************************************************************

/*=========================================
Variables to Hold the Parameter Values
=========================================*/
gd_date_from 			DATE;
gd_date_to 				DATE;
P_INVOICE_FROM			VARCHAR2(30);
P_INVOICE_TO			VARCHAR2(30);
P_SUPPLIER_FROM         VARCHAR2(50);
P_SUPPLIER_TO           VARCHAR2(50);
P_CURRENCY              VARCHAR2(15);
P_VENDOR_TYPE           VARCHAR2(30);
P_ORG_ID				NUMBER;
P_PREPAY_STATUS         VARCHAR2(30);


/*=========================================
Constants to obtain dynamic values
=========================================*/

c_lex_invoice_date 		VARCHAR2(900);
c_lex_supplier			VARCHAR2(200);
c_lex_currency			VARCHAR2(200);
c_lex_vendor_type       VARCHAR2(200);
gc_org_where       		VARCHAR2(100);
c_lex_prepay_status     VARCHAR2(200);

/*=========================================
Public Functions
=========================================*/

FUNCTION beforeReport  RETURN BOOLEAN;
FUNCTION date_close(prepay_inv_num IN VARCHAR2
					, prepay_line_number_param IN NUMBER
					,prepay_amount_remaining IN NUMBER) RETURN DATE;
END AP_PREPAY_TRAK_REP_TURK_PKG;

/
