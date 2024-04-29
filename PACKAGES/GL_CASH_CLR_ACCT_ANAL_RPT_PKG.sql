--------------------------------------------------------
--  DDL for Package GL_CASH_CLR_ACCT_ANAL_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_CASH_CLR_ACCT_ANAL_RPT_PKG" AUTHID CURRENT_USER AS
/* $Header: glxccaas.pls 120.0.12010000.2 2009/04/29 09:57:24 kmotepal ship $ */

  --
  -- Report parameters
  --
  data_access_set_id_param         VARCHAR2(30);
  ledger_id_param                  VARCHAR2(15);
  coa_id_param                     NUMBER(30);
 -- acct_param                       VARCHAR2(50);--Commented as part of bug8446559
  acct_param                       VARCHAR2(240);--Added as part of bug8446559
  ccid_param                       VARCHAR2(50);
  period_from_param                VARCHAR2(15);
  period_to_param                  VARCHAR2(15);
  rept_type_param                  VARCHAR2(20);

  --
  -- Global variables declaration. These variables are used for dynamically
  -- builiding the queries in the report.
  --
  gc_ap_uncleared_query            VARCHAR2(2500);
  gc_ap_cleared_query              VARCHAR2(2500);
  gc_gl_uncleared_query            VARCHAR2(2500);
  gn_effective_period_num_from     NUMBER;
  gn_effective_period_num_to       NUMBER;
  gc_access_where                  VARCHAR2(250);

  --
  -- Function
  --   before_report
  -- Purpose
  --   Used for dynamically builiding the queries in the report
  -- Notes
  --
  FUNCTION before_report    RETURN BOOLEAN;

  --
  -- Function
  --   access_set_name
  -- Purpose
  --   Used to retrieve the access set name
  -- Notes
  --
  FUNCTION access_set_name  RETURN VARCHAR2;

  --
  -- Function
  --   ledger_name
  -- Purpose
  --   Used to retrieve the ledger name
  -- Notes
  --
  FUNCTION  ledger_name      RETURN VARCHAR2;

END GL_CASH_CLR_ACCT_ANAL_RPT_PKG;

/
