--------------------------------------------------------
--  DDL for Package Body AR_AGG_VAT_STMT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_AGG_VAT_STMT_PKG" 
-- $Header: araggvatstmtpb.pls 120.0 2007/12/13 10:03:40 sgudupat noship $
-- ****************************************************************************
-- Copyright (c)  2000  Oracle Solution Services (India)    Product Development
-- All rights reserved
-- ****************************************************************************
--
-- PROGRAM NAME
--  araggvatstmtpb.pls
--
-- DESCRIPTION
--  This script creates the package Body of ar_agg_vat_stmt_pkg.
--  This package is used to generate Aggregate VAT Statement.
--
-- USAGE
--
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
FUNCTION get_rate(p_invoice_currency_code IN VARCHAR2
                 ,p_ship_date_actual IN DATE
                 ,p_exchange_rate_type IN VARCHAR2)
RETURN NUMBER
IS
  l_rate NUMBER;
BEGIN
  IF p_exchange_rate_type IS NULL OR p_ship_date_actual IS NULL THEN
    l_rate := 1;
  ELSE
    l_rate := GL_CURRENCY_API.GET_RATE(P_LEDGER_ID
                                      ,p_invoice_currency_code
                                      ,p_ship_date_actual
                                      ,p_exchange_rate_type);
  END IF;
  RETURN(l_rate);
END get_rate;

END AR_AGG_VAT_STMT_PKG;

/
