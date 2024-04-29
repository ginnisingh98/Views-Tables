--------------------------------------------------------
--  DDL for Package AP_CHECK_PAYMT_SUPP_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_CHECK_PAYMT_SUPP_RPT_PKG" 
-- $Header: AP_CHECKPAYMTSUPPS.pls 120.1.12000000.1 2007/10/24 18:03:57 sgudupat noship $
--*************************************************************************
-- Copyright (c)  2000    Oracle                 Product Development
-- All rights reserved
--*************************************************************************
--
-- HEADER
--  Source control header
--
-- PROGRAM NAME
--   AP_CHECK_PAYMT_SUPP_RPT_PKG
--
-- DESCRIPTION
-- This script creates the package specification of AP_CHECK_PAYMT_SUPP_RPT_PKG
-- This package AUTHID CURRENT_USER is used to report on AP Check payments to Suppliers.
--
-- USAGE
--   To install        sqlplus <apps_user>/<apps_pwd> @AP_CHECKPAYMTSUPPS.pls
--   To execute        sqlplus <apps_user>/<apps_pwd> AP_CHECK_PAYMT_SUPP_RPT_PKG.
--
-- PROGRAM LIST        DESCRIPTION
-- beforereport        This function is used to dynamically get the
--                     WHERE clause in SELECT statement.
-- DEPENDENCIES
-- None
--
-- CALLED BY
-- AP Check Payments to Suppliers Report.
--
-- LAST UPDATE DATE    08-Feb-2007
-- Date the program has been modified for the last time.
--
-- HISTORY
-- =======
--
-- VERSION DATE        AUTHOR(S)       DESCRIPTION
-- ------- ----------- --------------- --------------------------------------
-- Draft1A 08-Feb-2007 Rakesh Pulla     Initial Creation
-- Draft1B 16-Feb-2007 Rakesh Pulla     Updated as per the Ref # 23464
-- Draft1C 12-Jul-2007 Rakesh Pulla     Incorporated the product team review comments.
-- Draft1D 12-Jul-2007 Rakesh Pulla     Replaced CHCK with CHECK as suggested by the product team.
--************************************************************************
AS

P_VNDR_NUMBER_FROM       NUMBER(15);
P_VNDR_NUMBER_TO         NUMBER(15);
P_CHECK_DATE_FROM        DATE;
P_CHECK_DATE_TO          DATE;
P_CHECK_DUE_DATE_FROM    DATE;
P_CHECK_DUE_DATE_TO      DATE;
P_CURRENCY               VARCHAR2(15);
P_CHECK_STAT             VARCHAR2(80);
GC_WHERE                 VARCHAR2(1000):='1=1';
GC_ATTRIBUTE_COL         VARCHAR2(80);
GC_ATTRIBUTE             VARCHAR2(50);

FUNCTION beforereport RETURN BOOLEAN;

END AP_CHECK_PAYMT_SUPP_RPT_PKG;

 

/
