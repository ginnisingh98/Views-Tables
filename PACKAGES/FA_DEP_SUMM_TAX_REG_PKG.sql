--------------------------------------------------------
--  DDL for Package FA_DEP_SUMM_TAX_REG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_DEP_SUMM_TAX_REG_PKG" AUTHID CURRENT_USER
-- $Header: FADSTRPS.pls 120.1.12010000.2 2009/07/19 08:17:55 glchen ship $
-- ****************************************************************************************
-- Copyright (c)  2000  Oracle Solution Services (India)     Product Development
-- All rights reserved
-- ****************************************************************************************
--
-- PROGRAM NAME
--  FADSTRPS.pls
--
-- DESCRIPTION
--  This script creates the package specification of FA_DEP_SUMM_TAX_REG_PKG.
--  This package is used to generate Depreciation Summary Tax Register for Russia.
--
-- USAGE
--   To install        How to Install
--   To execute        How to Execute
--
-- PROGRAM           DESCRIPTION
-- beforereport      Used to assign values for the variables used
--                   for dynamic query.
-- currency_code     Used to obtain the Currency Code
-- company_code      Used to obtain the Company Code
--
-- DEPENDENCIES
--   None.
--
-- CALLED BY
--   DataTemplate Extract in Depreciation Summary Tax Register (Russia).
--
--
-- LAST UPDATE DATE   04-JAN-2007
--   Date the program has been modified for the last time
--
-- HISTORY
-- =======
--
-- VERSION   DATE           AUTHOR(S)          DESCRIPTION
-- -------   -----------    ---------------    ------------------------------------
-- 1.00      24-JAN-2007    Sandeep Kumar G.   Creation
--
-- ****************************************************************************************
AS

/*=========================================
Variables to Hold the Parameter Values
=========================================*/

P_BOOK          fa_books.book_type_code%TYPE;
P_PERIOD1       fa_deprn_periods.period_name%TYPE;

/*=========================================
Lexical Variables to obtain dynamic values
=========================================*/

gc_major_category       VARCHAR2(50);
gc_minor_category       VARCHAR2(50);
gn_maj_cat_value_set_id NUMBER;
gn_period_counter       NUMBER;
gc_pcd                  VARCHAR2(50);
gc_fiscal_year          VARCHAR2(50);
gc_cal_pcd              VARCHAR2(50);
gc_fiscal_start_date    VARCHAR2(50);

gc_company_name         VARCHAR2(50);
gc_currency_code        VARCHAR2(50);

/*=========================================
Public Functions
=========================================*/

FUNCTION company_name  RETURN VARCHAR2;
FUNCTION currency_code RETURN VARCHAR2;
FUNCTION beforereport  RETURN BOOLEAN;


END FA_DEP_SUMM_TAX_REG_PKG;

/
