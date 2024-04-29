--------------------------------------------------------
--  DDL for Package Body FA_CIP_STAT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_CIP_STAT_PKG" AS
-- $Header: FAWIPSTATPB.pls 120.1.12010000.2 2009/07/19 08:14:32 glchen ship $
-- ****************************************************************************************
-- Copyright (c)  2000  Oracle Solution Services (India)     Product Development
-- All rights reserved
-- ****************************************************************************************
--
-- PROGRAM NAME
-- FAWIPSTATPB.pls
--
-- DESCRIPTION
--  This script creates the package body of FA_CIP_STAT_PKG.
--  This package is used to generate FA CIP Statistics for the central Statistical Office (KSH) (Hungary).
--
-- USAGE
--   To install        How to Install
--   To execute        How to Execute
--
-- DEPENDENCIES
--   None.
--
--
-- LAST UPDATE DATE   26-JAN-2007
--   Date the program has been modified for the last time
--
-- HISTORY
-- =======
--
-- VERSION DATE        AUTHOR(S)         DESCRIPTION
-- ------- ----------- ---------------   ------------------------------------
-- 1.0    26-JAN-2007 Praveen Gollu M Creation
--
--****************************************************************************************

FUNCTION BookFormula RETURN VARCHAR2 IS
BEGIN

DECLARE
  lc_book       VARCHAR2(15);
  ln_accounting_flex_structure NUMBER(15);
  lc_currency_code VARCHAR2(15);
  ln_precision  NUMBER(15);
  lc_distribution_source_book VARCHAR2(15);
BEGIN
  SELECT 	BC.book_type_code
			,BC.accounting_flex_structure
			,SOB.currency_code
			,CUR.precision
			,BC.distribution_source_book
  INTO  	lc_book
			,ln_accounting_flex_structure
			,lc_currency_code
			,ln_precision
			,lc_distribution_source_book
  FROM   	fa_book_controls BC
			,gl_sets_of_books SOB
			,fnd_currencies CUR
  WHERE  	BC.book_type_code = P_BOOK
  AND    	SOB.set_of_books_id = BC.set_of_books_id
  AND    	SOB.currency_code = CUR.currency_code;

  gn_accounting_flex_structure:=ln_accounting_flex_structure;
  gc_currency_code := lc_currency_code;
  gn_precision := ln_precision;
  gc_distribution_source_book := lc_distribution_source_book;
  RETURN(lc_book);
END;
RETURN NULL;
END;

FUNCTION Period1Formula RETURN VARCHAR2 IS
BEGIN

DECLARE
  lc_period_name VARCHAR2(15);
  ld_period_POD  DATE;
  ln_period_pc	NUMBER;
BEGIN
  SELECT 	FDP.period_name
			,FDP.period_open_date
			,FDP.period_counter
  INTO   	lc_period_name
			,ld_period_POD
			,ln_period_pc
  FROM   	fa_deprn_periods FDP
  WHERE  	FDP.book_type_code = P_BOOK
  AND    	FDP.period_name    = P_PERIOD1;
  gd_period1_pod := ld_period_POD;
  gn_period1_pc := ln_period_pc;
  RETURN(lc_period_name);
END;
RETURN NULL;
END;

FUNCTION Period2Formula RETURN VARCHAR2 IS
BEGIN

DECLARE
  lc_period_name  VARCHAR2(15);
  ld_period_PCD   DATE;
  ln_period_pc	NUMBER;
BEGIN
  SELECT 	FDP.period_name
			,NVL(FDP.period_close_date, SYSDATE)
			,FDP.period_counter
    INTO   	lc_period_name
			,ld_period_PCD
			,ln_period_pc
    FROM   	fa_deprn_periods FDP
    WHERE  	FDP.book_type_code = P_BOOK
    AND    	FDP.period_name = P_PERIOD2;
gd_Period2_PCD := ld_period_PCD;
gn_period2_pc := ln_period_pc;
RETURN(lc_period_name);
END;
RETURN NULL;
END;

--Functions to refer Oracle report placeholders--

 FUNCTION Accounting_Flex_Structure_p RETURN NUMBER IS
	BEGIN
	 RETURN gn_accounting_flex_structure;
	 END;
 FUNCTION DISTRIBUTION_SOURCE_BOOK_p RETURN VARCHAR2 IS
	BEGIN
	 RETURN gc_distribution_source_book;
	 END;
END FA_CIP_STAT_PKG ;

/
