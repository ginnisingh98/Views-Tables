--------------------------------------------------------
--  DDL for Package Body AR_ADV_BAL_SEL_CURR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_ADV_BAL_SEL_CURR_PKG" AS
-- $Header: ARADVBALPKGB.pls 120.2.12000000.1 2007/10/24 18:52:51 sgudupat noship $
--*****************************************************************************
-- Copyright (c)  2000    Oracle Solution Services (India)  Product Development
-- All rights reserved
--*****************************************************************************
--
--
-- PROGRAM NAME
--  ARADVBALPKGB.pls
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
FUNCTION beforereport RETURN BOOLEAN IS
BEGIN

  SELECT gl.currency_code
  INTO   gc_func_currency
  FROM   gl_ledgers                 gl
        ,gl_access_set_norm_assign  gasna
  WHERE  gasna.access_set_id     = fnd_profile.VALUE('GL_ACCESS_SET_ID')
  AND    gl.ledger_id            = gasna.ledger_id
  AND    gl.ledger_category_code = 'PRIMARY';

---pl\sql bolck to get control segment name
---for the given control segment number

  SELECT FSEG.segment_name
  INTO   gc_ctrl_seg
  FROM   fnd_id_flex_structures   fst
        ,fnd_id_flex_segments     fseg
  WHERE  fst.id_flex_code     =  fseg.id_flex_code
  AND    fst.id_flex_num      =  fseg.id_flex_num
  AND    fst.application_id   =  fseg.application_id
  AND    fseg.id_flex_code    =  'GL#'
  AND    fseg.id_flex_num     =  P_CHART_OF_ACCOUNTS_ID
  AND    fseg.application_id  =  101
  AND    fseg.segment_num     =  P_CONTROL_SEGMENT;

----build the where clause for CURRENCY CODE WHERE
  fnd_file.put_line(fnd_file.log,'P_CURRENCY_TYPE'||P_CURRENCY_TYPE);
  IF P_CURRENCY_TYPE = 'Selected Currency' THEN
    gc_currency_code_where:=' TRX.invoice_currency_code   = :P_CURRENCY_CODE ';
  ELSIF P_CURRENCY_TYPE = 'All Currencies' THEN
    gc_currency_code_where:=' 1 = 1 ';
  ELSE
    gc_currency_code_where:=' TRX.invoice_currency_code not in (:gc_func_currency)';
  END IF;
  fnd_file.put_line(fnd_file.log,'gc_currency_code_where'||gc_currency_code_where);

RETURN TRUE;
END beforereport;

END AR_ADV_BAL_SEL_CURR_PKG;

/
