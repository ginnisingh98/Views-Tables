--------------------------------------------------------
--  DDL for Package CE_BNK_STMT_IMP_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CE_BNK_STMT_IMP_RPT_PKG" AUTHID CURRENT_USER
-- $Header: CEBNKSTMTIMPS.pls 120.1.12010000.2 2008/08/10 14:25:45 csutaria ship $
--*************************************************************************
-- Copyright (c)  2000    Oracle Solution Services (India)  Product Development
-- All rights reserved
--*************************************************************************
--
--
-- PROGRAM NAME
--  CEBNKSTMTIMPS.pls
--
-- DESCRIPTION
--   This script creates the package specification of CEBNKSTMTIMPS.
--   This package is used by the 'Bank Statement Import Validation - Israel' report.
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
-- LAST UPDATE DATE   20-DEC-2006
--
--
-- HISTORY
-- =======
--
-- VERSION DATE        AUTHOR(S)         DESCRIPTION
-- ------- ----------- ---------------   ------------------------------------
-- Draft1A 20-DEC-2006 Harsh Poddar  Draft Version
--************************************************************************

AS
    p_bank_branch_id              NUMBER;
    p_bank_account_id             VARCHAR2(50);
    p_statement_num		          VARCHAR2(50);
    gc_bank_branch_name           VARCHAR2(300);
    gc_bank_account_num           VARCHAR2(30);
    gc_status_current		      VARCHAR2(30);
    gc_status_latest		      VARCHAR2(30);
    gc_control_totals		      VARCHAR2(1500);
    gc_from_and_where		      VARCHAR2(500);
    gn_total_cr			          NUMBER;
    gn_total_dr		              NUMBER;

    lc_uploaded_select_columns    VARCHAR2(500);
    lc_uploaded_where_conditions  VARCHAR2(500);
    lc_uploaded_group_by	      VARCHAR2(200);
    lc_latest_bank_acc_num        VARCHAR2(50);
    lc_latest_bank_acc_from       VARCHAR2(50);
    lc_latest_bank_acc_where	  VARCHAR2(1000);

  FUNCTION beforeReportTrigger RETURN BOOLEAN;

END CE_BNK_STMT_IMP_RPT_PKG;

/
