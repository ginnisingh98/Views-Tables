--------------------------------------------------------
--  DDL for Package AR_WL_REW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_WL_REW_PKG" AUTHID CURRENT_USER AS
-- $Header: ARWLREWS.pls 120.0.12010000.1 2008/08/29 20:44:37 tthangav noship $
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
--   ARWLREWS.pls
--
-- DESCRIPTION
-- This script creates the package specification of AR_WL_REW_PKG
-- This package is used for Cash Application work load review report.
--
-- USAGE
--   To install        sqlplus <apps_user>/<apps_pwd> @ARWLREWS.pls
--   To execute        sqlplus <apps_user>/<apps_pwd> AR_WL_REW_PKG.
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
-- LAST UPDATE DATE    25-Jul-2008
-- Date the program has been modified for the last time.
--
-- HISTORY
-- =======
--
-- VERSION DATE        AUTHOR(S)       DESCRIPTION
-- ------- ----------- --------------- --------------------------------------
--         25-Jul-2008 Thirumalaisamy   Initial Creation
+===========================================================================*/

/*=========================================
Variables to Hold the Parameter Values
=========================================*/
p_org_id                 VARCHAR2(100);
p_cash_appln_owner_from  VARCHAR2(100);
p_cash_appln_owner_to    VARCHAR2(100);
p_recpt_date_from        DATE;
p_recpt_date_to          DATE;
p_cust_from              VARCHAR2(100);
p_cust_to                VARCHAR2(100);
p_work_item_status_from  VARCHAR2(30);
p_work_item_status_to    VARCHAR2(30);
p_assgn_date_from        DATE;
p_assgn_date_to          DATE;
p_detail                 VARCHAR2(30);

/*========================================
Lexical Variables to obtain dynamic values
=========================================*/
gc_org_id             VARCHAR2(1000) := ' AND 1 = 1 ';
gc_cash_appln_owner   VARCHAR2(1000) := ' AND 1 = 1 ';
gc_recpt_date         VARCHAR2(1000) := ' AND 1 = 1 ';
gc_cust               VARCHAR2(1000) := ' AND 1 = 1 ';
gc_work_item_status   VARCHAR2(1000) := ' AND 1 = 1 ';
gc_assgn_date         VARCHAR2(1000) := ' AND 1 = 1 ';
gc_detail             VARCHAR2(1000) := ' AND 1 = 1 ';
/*=========================================
Public Functions
=========================================*/

FUNCTION beforereport RETURN BOOLEAN;

END AR_WL_REW_PKG;

/
