--------------------------------------------------------
--  DDL for Package AR_TP_STMT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_TP_STMT_PKG" AUTHID CURRENT_USER AS
-- $Header: ARSTMTRPTPS.pls 120.0 2008/02/12 15:56:26 sgudupat noship $
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
--   ARSTMTRPTPS.pls
--
-- DESCRIPTION
-- This script creates the package specification of AR_TP_STMT_PKG
-- This package is used for Supplier/Customer Statement Reports.
--
-- USAGE
--   To install        sqlplus <apps_user>/<apps_pwd> @ARSTMTRPTPS.pls
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
P_FROM_CUST_NAME        VARCHAR2(100);
P_TO_CUST_NAME          VARCHAR2(100);
P_CURRENCY              VARCHAR2(100);
P_CUST_CATEGORY         VARCHAR2(100);
P_CUST_CLASS            VARCHAR2(100);
P_INCOMPLETE_TRX        VARCHAR2(100);
P_ACCOUNTED             VARCHAR2(100);

/*========================================
Lexical Variables to obtain dynamic values
=========================================*/
gc_org_id         VARCHAR2(1000) := ' AND 1 = 1 ';
gc_rcpt_org_id    VARCHAR2(1000) := ' AND 1 = 1 ';
gc_cust_class     VARCHAR2(1000) := ' AND 1 = 1 ';
gc_cust_category  VARCHAR2(1000) := ' AND 1 = 1 ';
gc_currency       VARCHAR2(1000) := ' AND 1 = 1 ';
gc_rcpt_currency  VARCHAR2(1000) := ' AND 1 = 1 ';
gc_accounted      VARCHAR2(1000) := ' AND 1 = 1 ';
gc_rcpt_accounted VARCHAR2(1000) := ' AND 1 = 1 ';
gc_adj_accounted  VARCHAR2(1000) := ' AND 1 = 1 ';
gc_incomplete_trx VARCHAR2(1000) := ' AND 1 = 1 ';
gc_customer_name  VARCHAR2(1000) := ' AND 1 = 1 ';
gc_app_accounted  VARCHAR2(1000) := ' AND 1 = 1 ';
gc_reporting_entity VARCHAR2(1000) := ' AND 1 = 1 ';
/*=========================================
Public Functions
=========================================*/

FUNCTION beforereport RETURN BOOLEAN;
FUNCTION balance_brought_forward (p_in_cust_account_id IN NUMBER
                                 ,p_in_site_use_id     IN NUMBER
                                 ,p_in_org_id          IN NUMBER)
RETURN NUMBER;
FUNCTION contact_details(p_owner_table_id IN NUMBER
                        ,p_contact_type IN VARCHAR2)
RETURN VARCHAR2;

END AR_TP_STMT_PKG;

/
