--------------------------------------------------------
--  DDL for Package AP_TP_STMT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_TP_STMT_PKG" AUTHID CURRENT_USER AS
-- $Header: APTPSTMTPS.pls 120.0 2008/03/06 11:41:25 sgudupat noship $
/*===========================================================================+
--*************************************************************************
-- Copyright (c)  2000    Oracle                 Product Development
-- All rights reserved
--*************************************************************************
--
-- HEADER
--  Source control header
--
-- PROGRAM NAME
--   ARTPSTMTPS.pls
--
-- DESCRIPTION
-- This script creates the package specification of AP_TP_STMT_PKG
-- This package is used for Supplier/Customer Statement Reports.
--
-- USAGE
--   To install        sqlplus <apps_user>/<apps_pwd> @APTPSTMTPS.pls
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

/*=========================================
Variables to Hold the Parameter Values
=========================================*/
P_REPORTING_LEVEL       VARCHAR2(30);
P_REPORTING_ENTITY_ID   NUMBER;
P_REPORTING_ENTITY_NAME VARCHAR2(100);
P_FROM_DOC_DATE         VARCHAR2(30);
P_TO_DOC_DATE           VARCHAR2(30);
P_FROM_GL_DATE          VARCHAR2(30);
P_TO_GL_DATE            VARCHAR2(30);
P_FROM_SUPP_NAME        VARCHAR2(100);
P_TO_SUPP_NAME          VARCHAR2(100);
P_CURRENCY              VARCHAR2(100);
P_PAY_GROUP             VARCHAR2(100);
P_VEND_TYPE             VARCHAR2(100);
P_UNVALIDATED_TRX       VARCHAR2(100);
P_UNAPPROVED_TRX        VARCHAR2(100);
P_ACCOUNTED             VARCHAR2(100);

/*========================================
Lexical Variables to obtain dynamic values
=========================================*/
gc_org_id           VARCHAR2(1000) := ' AND 1 = 1 ';
gc_reporting_entity VARCHAR2(1000) := ' AND 1 = 1 ';
gc_pmt_org_id       VARCHAR2(1000) := ' AND 1 = 1 ';
gc_currency         VARCHAR2(1000) := ' AND 1 = 1 ';
gc_pmt_currency     VARCHAR2(1000) := ' AND 1 = 1 ';
gc_supplier_name    VARCHAR2(1000) := ' AND 1 = 1 ';
gc_pay_group        VARCHAR2(1000) := ' AND 1 = 1 ';
gc_vend_type        VARCHAR2(1000) := ' AND 1 = 1 ';
gc_pmt_accounted    VARCHAR2(1000) := ' AND 1 = 1 ';
gc_unapproved_trx   VARCHAR2(1000) := ' AND 1 = 1 ';
gc_validate_inv     VARCHAR2(3000) := ' AND 1 = 1 ';
/*=========================================
Public Functions
=========================================*/

FUNCTION beforereport RETURN BOOLEAN;
FUNCTION invoice_validate_status (p_in_inv_id IN NUMBER) RETURN VARCHAR2;
FUNCTION balance_brought_forward (p_in_vendor_id      IN NUMBER
                                 ,p_in_vendor_site_id IN NUMBER
                                 ,p_in_org_id         IN NUMBER)
RETURN NUMBER;
END AP_TP_STMT_PKG;

/
