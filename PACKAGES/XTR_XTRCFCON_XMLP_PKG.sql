--------------------------------------------------------
--  DDL for Package XTR_XTRCFCON_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XTR_XTRCFCON_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: XTRCFCONS.pls 120.1 2007/12/28 12:46:41 npannamp noship $ */
  REPORT_DATE2 DATE;

  REPORT_SHORT_NAME VARCHAR2(240);

  USE_DEFAULTS VARCHAR2(1);

  CURRENCY_CODE VARCHAR2(15);

  DAY_WEEK_MONTH VARCHAR2(1);

  SETTLE_FROM_DATE DATE;

  SETTLE_TO_DATE DATE;

  EXP_TYPES VARCHAR2(40);

  INCL_CCY_OPT VARCHAR2(40);

  Z2CASHFLOWS VARCHAR2(100);

  Z2NET_EXPOSURE VARCHAR2(100);

  Z1TO VARCHAR2(100);

  Z2NET_CASHFLOW VARCHAR2(100);

  Z2NUMBER_OF VARCHAR2(100);

  Z2AC_BALANCE VARCHAR2(100);

  Z1SUMMARISE_BY_DAY_WEEK_MONTH VARCHAR2(100);

  Z1EXP_TYPES VARCHAR2(100);

  Z1PARAMETERS VARCHAR2(100);

  Z1CURRENCY VARCHAR2(100);

  Z1INCLUDE_CCY_OPTION VARCHAR2(100);

  Z2CCY VARCHAR2(100);

  Z2DATE_OR VARCHAR2(100);

  Z2WEEK_MONTH VARCHAR2(100);

  Z2ENDING VARCHAR2(100);

  Z2NET_TOTALS VARCHAR2(100);

  Z2CURRENT_CASH_DEPOSITS VARCHAR2(600);

  Z2NET_FX VARCHAR2(100);

  Z2NET_MM VARCHAR2(100);

  Z1SUMMARISED VARCHAR2(100);

  Z1SETTLE_FROM VARCHAR2(100);

  Z2END_OF_REPORT VARCHAR2(100);

  Z2PAGE VARCHAR2(100);

  P_CURRENCY VARCHAR2(15);

  P_EXPOSURE_TYPE VARCHAR2(40);

  P_INCLUDE_FX_OPTION_BUY_SELL VARCHAR2(40);

  P_SUMMARIZE_BY VARCHAR2(10);

  P_PERIOD_FROM DATE;

  P_PERIOD_TO DATE;

  P_SQL_TRACE VARCHAR2(32767);

  P_DISPLAY_DEBUG VARCHAR2(32767);

  CURRENCY2 VARCHAR2(15);

  EXP_TYPES2 VARCHAR2(40);

  INCL_CCY_OPT2 VARCHAR2(40);

  DAY_WEEK_MONTH2 VARCHAR2(10);

  SETTLE_FROM_DATE2 DATE;

  SETTLE_TO_DATE2 DATE;

  P_CONC_REQUEST_ID NUMBER;

  COMPANY_NAME_HEADER VARCHAR2(80);

  REPORT_SHORT_NAME2 VARCHAR2(240);

  REPORT_DATE VARCHAR2(100);

  P_1 VARCHAR2(1000):=' ';

  Z1INCL_IND_EXP VARCHAR2(100);

  P_FACTOR VARCHAR2(10);

  AMT_UNIT2 NUMBER;

  L_AMT_UNIT2 NUMBER;

  LP_FACTOR_DESC VARCHAR2(100);

  Z1P_FACTOR VARCHAR2(100);

  ZRCURRENT_CASH_DEPOSIT NUMBER;

  Z2CURRENT_CASH_DEPOSITS_MSG VARCHAR2(2000);

  OPEN_BAL NUMBER;

  ROLLING_BAL NUMBER;

  CP_PARA VARCHAR2(32767);

  LP_PERIOD_FROM varchar2(20);

  LP_PERIOD_TO varchar2(20);

  FUNCTION ROLLING_BAL1FORMULA RETURN VARCHAR2;

  FUNCTION ROLLING_BALFORMULA RETURN NUMBER;

  FUNCTION OPEN_BAL1FORMULA(ccy varchar2) RETURN VARCHAR2;

  FUNCTION OPEN_BALFORMULA RETURN NUMBER;

  FUNCTION CF_SET_PARAFORMULA RETURN VARCHAR2;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION AFTERPFORM RETURN BOOLEAN;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION BEFOREPFORM RETURN BOOLEAN;

  FUNCTION BETWEENPAGE RETURN BOOLEAN;

  FUNCTION OPEN_BAL_P RETURN NUMBER;

  FUNCTION ROLLING_BAL_P RETURN NUMBER;

  FUNCTION CP_PARA_P RETURN VARCHAR2;

END XTR_XTRCFCON_XMLP_PKG;


/