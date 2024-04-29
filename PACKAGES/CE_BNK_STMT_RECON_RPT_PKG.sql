--------------------------------------------------------
--  DDL for Package CE_BNK_STMT_RECON_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CE_BNK_STMT_RECON_RPT_PKG" AUTHID CURRENT_USER
-- $Header: CEBNKSTMTRECONS.pls 120.0.12010000.2 2008/08/10 14:25:55 csutaria ship $
--*************************************************************************
-- Copyright (c)  2000    Oracle Solution Services (India)  Product Development
-- All rights reserved
--*************************************************************************
--
--
-- PROGRAM NAME
--  CEBNKSTMTRECONS.pls
--
-- DESCRIPTION
--   This script creates the package specification of CEBNKSTMTRECONS.
--   This package is used by the 'Israel - Bank Statement Reconciliation' report.
--
-- USAGE
--   To execute			   This can be applied by running this script at SQL*Plus.
--
--  PROGRAM LIST                   DESCRIPTION
--
--  beforeReportTrigger            It is a public function which is run just after the
--                                 queries are parsed and before queries are executed.
--
-- DEPENDENCIES
--   None
--
-- CALLED BY
--   None
--
-- LAST UPDATE DATE   10-FEB-2007
--
--
-- HISTORY
-- =======
--
-- VERSION DATE        AUTHOR(S)         DESCRIPTION
-- ------- ----------- ---------------   ------------------------------------
-- Draft1A 10-FEB-2007 Harsh Poddar  Draft Version
--************************************************************************

AS
    P_BANK_ACCOUNT_ID              NUMBER;
    P_ACC_PERIOD_FROM              VARCHAR2(50);
    P_ACC_PERIOD_TO		   VARCHAR2(50);
    P_CLOSE_BALANCE		   NUMBER;
    gc_bank_account_name           VARCHAR2(30);
    gc_currency_code		   VARCHAR2(5);
    gc_from_date                   VARCHAR2(30);
    gc_to_date			   VARCHAR2(30);
    gn_sob_id			   NUMBER;
    gc_trx_type_payment		   VARCHAR2(30);
    gc_trx_type_receipt		   VARCHAR2(30);
    gc_origin_accounted		   VARCHAR2(30);
    gc_origin_bank_stmt		   VARCHAR2(30);

  FUNCTION beforeReportTrigger RETURN BOOLEAN;

END CE_BNK_STMT_RECON_RPT_PKG;

/
