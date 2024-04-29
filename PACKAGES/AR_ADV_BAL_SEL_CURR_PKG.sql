--------------------------------------------------------
--  DDL for Package AR_ADV_BAL_SEL_CURR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_ADV_BAL_SEL_CURR_PKG" AUTHID CURRENT_USER AS
-- $Header: ARADVBALPKGS.pls 120.2.12000000.1 2007/10/24 18:52:43 sgudupat noship $
--*****************************************************************************
-- Copyright (c)  2000    Oracle Solution Services (India)  Product Development
-- All rights reserved
--*****************************************************************************
--
--
-- PROGRAM NAME
--  ARADVBALPKGS.pls
--
-- DESCRIPTION
--   This script creates the package specification of AR_ADV_BAL_SEL_CURR_PKG.
--   This package is used by the 'Balance of Advances Received in Selected currency-slovakia' report.
--
-- USAGE
--
--   To execute           This can be applied by running this script at SQL*Plus.
--
--  PROGRAM LIST          DESCRIPTION
--
--  beforeReportTrigger   It is a public function which is run just after the
--                        queries are parsed and before queries are executed.
--
-- DEPENDENCIES
--   None
--
-- CALLED BY
--   DataTemplate Extract in 'Balance of Advances Received in Selected currency-slovakia' report.
--
-- LAST UPDATE DATE   17-FEB-2007
--
--
-- HISTORY
-- =======
--
-- VERSION DATE               AUTHOR(S)            DESCRIPTION
-- ------- ----------- ----------------- ------------------------------------
-- Draft1A 17-FEB-2007     Mallikarjun Gupta   Initial version
--***************************************************************************

-------Parameters in Data Template-------------------

P_ACCESS_SET_ID        NUMBER;
P_LEDGER_NAME          VARCHAR2(30);
P_LEDGER_ID            NUMBER;
P_CHART_OF_ACCOUNTS_ID NUMBER;
P_COMMITMENT_DATE      VARCHAR2(30);
P_AS_OF_DATE           VARCHAR2(30);
P_CURRENCY_TYPE        VARCHAR2(30);
P_CURRENCY_VALUE       VARCHAR2(30);
P_CURRENCY_CODE        VARCHAR2(30);
P_ASSGN_ACC_TO         VARCHAR2(30);
P_FORMAT               VARCHAR2(30);
P_SORT_BY              VARCHAR2(30);
P_INCL_TRANS_STMT      VARCHAR2(30);
P_CONTROL_SEGMENT      VARCHAR2(30);
P_CONTROL_SEGMENT_LOW  VARCHAR2(30);
P_CONTROL_SEGMENT_HIGH VARCHAR2(30);
P_ACCOUNT_SEGMENT_LOW  VARCHAR2(30);
P_ACCOUNT_SEGMENT_HIGH VARCHAR2(30);
P_COMMITMENT_LOW       VARCHAR2(30);
P_COMMITMENT_HIGH      VARCHAR2(30);
P_CUSTOMER_NUMBER_LOW  VARCHAR2(30);
P_CUSTOMER_NUMBER_HIGH VARCHAR2(30);

----Global Variables-----

gc_ctrl_seg fnd_id_flex_segments.segment_name%TYPE;
gc_func_currency  gl_ledgers.currency_code%TYPE;
gc_currency_code_where VARCHAR2(300) := ' 1 = 1 ';

FUNCTION BEFOREREPORT RETURN BOOLEAN;
END AR_ADV_BAL_SEL_CURR_PKG;

 

/
