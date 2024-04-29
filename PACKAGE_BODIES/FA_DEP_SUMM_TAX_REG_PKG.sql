--------------------------------------------------------
--  DDL for Package Body FA_DEP_SUMM_TAX_REG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_DEP_SUMM_TAX_REG_PKG" 
-- $Header: FADSTRPB.pls 120.1.12010000.2 2009/07/19 08:17:17 glchen ship $
-- ****************************************************************************************
-- Copyright (c)  2000  Oracle Solution Services (India)     Product Development
-- All rights reserved
-- ****************************************************************************************
--
-- PROGRAM NAME
--  FADSTRPB.pls
--
-- DESCRIPTION
--  This script creates the package body of FA_DEP_SUMM_TAX_REG_PKG.
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

--=====================================================================
--=====================================================================

FUNCTION beforereport RETURN BOOLEAN
IS
  ld_period_close_date    DATE;
  ld_calender_close_date  DATE;
  ld_fiscal_start_date    DATE;
BEGIN
--*********************************************************
--To select company Name
--*********************************************************
BEGIN
  SELECT fsc.company_name
  INTO   gc_company_name
  FROM 	 fa_system_controls fsc;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    gc_company_name := NULL;
  WHEN TOO_MANY_ROWS THEN
    gc_company_name := NULL;
END;

--*********************************************************
--To select Functional Currency
--*********************************************************
BEGIN
  SELECT gl.currency_code
  INTO   gc_currency_code
  FROM 	 fa_book_controls fbc
        ,gl_ledgers       gl
  WHERE  fbc.book_type_code      = P_BOOK
  AND    fbc.set_of_books_id = gl.ledger_id;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    gc_currency_code := NULL;
  WHEN TOO_MANY_ROWS THEN
    gc_currency_code := NULL;
END;

--*********************************************************
--To Fetch Column Name, value set for segment 'Tax Group'
--*********************************************************
BEGIN
  SELECT fsav.application_column_name
        ,fifs.flex_value_set_id
  INTO   gc_major_category
 	,gn_maj_cat_value_set_id
  FROM   fnd_segment_attribute_values fsav
	,fnd_id_flex_segments         fifs
  WHERE  fifs.segment_name    = 'Tax Group'
  --fsav.segment_attribute_type  = 'BASED_CATEGORY'
  AND    fsav.attribute_value         = 'Y'
  AND    fsav.id_flex_code            = 'CAT#'
  AND    fsav.id_flex_num             = 101
  AND	 fifs.application_column_name = fsav.application_column_name
  AND 	 fifs.id_flex_num             = fsav.id_flex_num
  AND    fifs.id_flex_code            = fsav.id_flex_code;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    gc_major_category := NULL;
    gn_maj_cat_value_set_id := NULL;
  WHEN TOO_MANY_ROWS THEN
    gc_major_category := NULL;
    gn_maj_cat_value_set_id := NULL;
END;

--*********************************************************
--To Fetch Column Name for segment 'Asset Type'
--*********************************************************
  /*SELECT fsav.application_column_name
  INTO   gc_minor_category
  FROM   fnd_segment_attribute_values fsav
  WHERE  segment_attribute_type = 'MINOR_CATEGORY'
  AND    attribute_value        = 'Y'
  AND    id_flex_code           = 'CAT#';
*/
BEGIN
  SELECT fifs.application_column_name
  INTO   gc_minor_category
  FROM   fnd_id_flex_segments fifs
  WHERE  fifs.segment_name  = 'Asset Type'
  AND    fifs.id_flex_num   = 101
  AND    fifs.id_flex_code  = 'CAT#';
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    gc_minor_category := NULL;
  WHEN TOO_MANY_ROWS THEN
    gc_minor_category := NULL;
END;

--*********************************************************
--To Fetch Period Counter, Period Close Date, Fiscal year,
--Calendar Period Close Date  for the Period Chosen
--*********************************************************
BEGIN
  SELECT fdp.period_counter
        ,NVL(fdp.period_close_date,sysdate)
        ,fdp.fiscal_year
        ,fdp.calendar_period_close_date
  INTO   gn_period_counter
        ,ld_period_close_date
        ,gc_fiscal_year
        ,ld_calender_close_date
  FROM   fa_deprn_periods      fdp
  WHERE  fdp.book_type_code = P_BOOK
  AND    fdp.period_name    = P_PERIOD1;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    gn_period_counter      := NULL;
    ld_period_close_date   := NULL;
    gc_fiscal_year         := NULL;
    ld_calender_close_date := NULL;
  WHEN TOO_MANY_ROWS THEN
    gn_period_counter      := NULL;
    ld_period_close_date   := NULL;
    gc_fiscal_year         := NULL;
    ld_calender_close_date := NULL;
END;

  gc_pcd     := ' TO_DATE('''||ld_period_close_date||''',''DD-MON-YYYY'')';
  gc_cal_pcd := ' TO_DATE('''||ld_calender_close_date||''',''DD-MON-YYYY'')';

--*********************************************************
--To Fetch fiscal start date for the period chosen
--*********************************************************
BEGIN
  SELECT ffy.start_date
  INTO   ld_fiscal_start_date
  FROM   fa_book_controls     fbc
        ,fa_fiscal_year	      ffy
  WHERE  fbc.book_type_code   = P_BOOK
  AND    ffy.fiscal_year      = gc_fiscal_year
  AND    ffy.fiscal_year_name = fbc.fiscal_year_name;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    ld_fiscal_start_date := NULL;
  WHEN TOO_MANY_ROWS THEN
    ld_fiscal_start_date := NULL;
END;
  gc_fiscal_start_date := ' TO_DATE('''||ld_fiscal_start_date||''',''DD-MON-YYYY'')';
  RETURN (TRUE);

END beforereport;

FUNCTION company_name RETURN VARCHAR2
IS
BEGIN
RETURN (gc_company_name);
END company_name;


FUNCTION currency_code RETURN VARCHAR2
IS
BEGIN
RETURN (gc_currency_code);
END currency_code;

END FA_DEP_SUMM_TAX_REG_PKG;

/
