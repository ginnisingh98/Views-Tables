--------------------------------------------------------
--  DDL for Package Body GL_OPEN_BAL_REVAL_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_OPEN_BAL_REVAL_RPT_PKG" AS
-- $Header: glxobrvb.pls 120.0.12000000.1 2007/10/23 15:50:40 sgudupat noship $
--*************************************************************************
-- Copyright (c)  2000    Oracle Corporation
-- All rights reserved
--*************************************************************************
--
--
-- PROGRAM NAME
--  glxobrvb.pls
--
-- DESCRIPTION
--  This script creates the package body of GL_OPEN_BAL_REVAL_RPT_PKG
--  This package is used for builidng all the  necessary PL/SQL Logic for the
--  report "GL Open Balances Revaluation"
--
-- USAGE
--   To install       How to Install
--   To execute       How to Execute
--
-- PROGRAM LIST         DESCRIPTION
--
-- DEPENDENCIES
--
-- CALLED BY
--   All the public functions are used in the data template GLOPNBALRVLRPT.xml
--
-- LAST UPDATE DATE   26-FEB-2007
--
-- HISTORY
-- =======
--
-- VERSION DATE        AUTHOR(S)       DESCRIPTION
-- ------- ----------- --------------- ------------------------------------
-- Draft1A 26-FEB-2007 Thirupathi Rao V  Draft Version
--
--*************************************************************************
-- Global Type and variable for caching revaluation rate
TYPE rvl_conv_rate_cache_tbl_type IS TABLE OF NUMBER INDEX BY VARCHAR2(40);
gn_rvl_convrate_cache_tbl rvl_conv_rate_cache_tbl_type;
--
FUNCTION beforereport RETURN BOOLEAN IS
BEGIN
  -- Populate start and end dates into global variables
  SELECT
        MAX(CASE gp.period_name WHEN period_from_param THEN gp.start_date END)
       ,MAX(CASE gp.period_name WHEN period_to_param THEN gp.end_date END)
  INTO
        gd_start_date
       ,gd_end_date
  FROM
        gl_periods gp
       ,gl_ledgers gll
  WHERE
            gll.ledger_id=ledger_id_param
        AND gp.period_set_name =gll.period_set_name
        AND gp.period_name IN (period_from_param,period_to_param);
  --build the where clause for security by access set
  gc_access_where:= gl_access_set_security_pkg.get_security_clause
                 (ACCESS_SET_ID_PARAM
                  ,'R'
                  ,'LEDGER_COLUMN'
                  ,'LEDGER_ID'
                  ,'gb'
                  ,'SEG_COLUMN'
                  ,null
                  ,'gcc'
                  ,NULL);
  IF gc_access_where IS NULL THEN
     gc_access_where:= '1 = 1';
  END IF;
  --Build currency where clause
  IF currency_param IS NOT NULL THEN
    gc_currency_where:= 'gjh.currency_code=:currency_param';
  ELSE
    gc_currency_where:='1=1';
  END IF;
  RETURN TRUE;
END beforereport;
--
--
FUNCTION get_reval_conversion_rate ( p_code_combination_id IN NUMBER
                                    ,p_account             IN VARCHAR2
                                    ,p_currency            IN VARCHAR2) RETURN NUMBER IS
  ln_reval_conversion_rate     NUMBER;
  ln_reval_header_id           PLS_INTEGER;
  lc_reval_rate_cache_pk       VARCHAR2(40);
BEGIN
  lc_reval_rate_cache_pk:=p_code_combination_id||'-'||p_currency;
  -- If the reavaluation rate for the given CCID and currency is already calculated then return the value
  -- else calculate
  IF gn_rvl_convrate_cache_tbl.exists(lc_reval_rate_cache_pk) THEN
    RETURN(gn_rvl_convrate_cache_tbl(lc_reval_rate_cache_pk));
  END IF;
  -- Find the header ID of the latest revalued entry
  SELECT   MAX(gjh.je_header_id)
  INTO     ln_reval_header_id
  FROM
            gl_je_headers gjh
           ,gl_je_lines   gjl
  WHERE
	           gjh.status = 'P'
           AND gjh.actual_flag = 'A'
           AND gjh.ledger_id = ledger_id_param
           AND gjh.je_source = 'Revaluation'
           AND gjl.je_header_id = gjh.je_header_id
           AND gjl.code_combination_id = p_code_combination_id
           AND gjh.currency_code=p_currency
           AND gjh.period_name=period_to_param;
  -- If there is no revaluation entry exists in the period period_to_param for the CCID and currency input
  -- display the message in the log file
  IF ln_reval_header_id IS NULL THEN
    gl_message.write_log ('GL_REVAL_ENTRY_NOT_FOUND'
	                      ,3
                          ,'ACCT'
                          ,p_account
                          ,'CURRENCY'
                          ,p_currency
                          ,'PERIOD'
                          ,period_to_param
                         );
    gn_rvl_convrate_cache_tbl(lc_reval_rate_cache_pk):=NULL;
    RETURN(NULL);
  ELSE
    -- Get the revaluation rate for the header ID  and cache it
    SELECT currency_conversion_rate
    INTO ln_reval_conversion_rate
    FROM gl_je_headers
    WHERE je_header_id=ln_reval_header_id;
    gn_rvl_convrate_cache_tbl(lc_reval_rate_cache_pk):=ln_reval_conversion_rate;
    RETURN(ln_reval_conversion_rate);
  END IF;
END get_reval_conversion_rate;
--
--
FUNCTION get_data_access_set_name RETURN VARCHAR2 IS
  lc_access_set_name VARCHAR2(30);
  BEGIN
    SELECT name
    INTO lc_access_set_name
    FROM gl_access_sets
    WHERE access_set_id=access_set_id_param;
	RETURN(lc_access_set_name);
  END get_data_access_set_name;
--
--
FUNCTION  get_ledger_name	RETURN VARCHAR2 IS
  lc_ledger_name VARCHAR2(30);
  BEGIN
    SELECT name
    INTO lc_ledger_name
    FROM gl_ledgers
    WHERE ledger_id=ledger_id_param;
  RETURN(lc_ledger_name);
  END get_ledger_name;
--
END GL_OPEN_BAL_REVAL_RPT_PKG;

/
