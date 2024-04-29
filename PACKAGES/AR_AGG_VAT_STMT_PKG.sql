--------------------------------------------------------
--  DDL for Package AR_AGG_VAT_STMT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_AGG_VAT_STMT_PKG" AUTHID CURRENT_USER
-- $Header: araggvatstmtps.pls 120.0 2007/12/13 10:03:17 sgudupat noship $
-- ****************************************************************************
-- Copyright (c)  2000  Oracle Solution Services (India)   Product Development
-- All rights reserved
-- ****************************************************************************
--
-- PROGRAM NAME
--  araggvatstmtps.pls
--
-- DESCRIPTION
--  This script creates the package specification of ar_agg_vat_stmt_pkg.
--  This package is used to generate Aggregate VAT Statement.
--
-- USAGE
--
-- DEPENDENCIES
--   None.
--
-- CALLED BY
--   DataTemplate Extract in Aggregate VAT Statement.
--
--
-- LAST UPDATE DATE   10-JAN-2007
--   Date the program has been modified for the last time
--
-- HISTORY
-- =======
--
-- VERSION   DATE           AUTHOR(S)         DESCRIPTION
-- -------   -----------    --------------    ---------------------------------
-- 1.00      10-JAN-2007    Sandeep            Creation
--
-- ****************************************************************************
AS
  P_LEDGER_ID   NUMBER;
  P_ORG_ID      NUMBER;
  P_PERIOD_FROM VARCHAR2(30);
  P_PERIOD_TO   VARCHAR2(30);
  P_REPORT_TYPE VARCHAR2(30);

  FUNCTION get_rate(p_invoice_currency_code IN VARCHAR2
                 ,p_ship_date_actual IN DATE
                 ,p_exchange_rate_type IN VARCHAR2)
RETURN NUMBER;

END AR_AGG_VAT_STMT_PKG;

/
