--------------------------------------------------------
--  DDL for Package JE_JEHUIAGE_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JE_JEHUIAGE_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: JEHUIAGES.pls 120.1 2007/12/25 16:55:02 dwkrishn noship $ */
  P_DEBUG_SWITCH VARCHAR2(1);

  P_CONC_REQUEST_ID NUMBER := 0;

  P_MIN_PRECISION NUMBER;

  P_FLEXDATA VARCHAR2(600);

  P_LEDGER_ID NUMBER;

  P_SORT_OPTION VARCHAR2(32767);

  P_SUMMARY_OPTION VARCHAR2(15);

  P_FORMAT_OPTION VARCHAR2(32767);

  P_AMOUNT_DUE_LOW NUMBER;

  P_AMOUNT_DUE_HIGH NUMBER;

  P_INVOICE_TYPE VARCHAR2(30);

  P_VENDOR_ID VARCHAR2(30);

  P_PERIOD_TYPE VARCHAR2(50);

  P_ORDER_BY VARCHAR2(1000) := 'order by 2,8,10,17,19,23,15';

  P_VENDOR_PREDICATE VARCHAR2(100):=' ';

  P_TRACE_SWITCH VARCHAR2(1);

  P_AMT_DUE_LOW VARCHAR2(40);

  P_AMT_DUE_HIGH VARCHAR2(40);

  P_AMOUNT_PREDICATE VARCHAR2(200);

  SORT_BY_ALTERNATE VARCHAR2(5);

  P_REPORT_TYPE VARCHAR2(32767);

  P_SELECT_CHECK_NUMBER VARCHAR2(200) := 'to_char(c.check_number)';

  P_CHECK_AMOUNT_PREDICATE VARCHAR2(200):=' ';

  P_LEGAL_ENTITY_ID NUMBER;

  P_LEDGER_NAME NUMBER;

  P_LEGAL_ENTITY_NAME NUMBER;

  C_BASE_CURRENCY_CODE VARCHAR2(15);

  C_BASE_PRECISION NUMBER;

  C_BASE_MIN_ACCT_UNIT NUMBER;

  C_BASE_DESCRIPTION VARCHAR2(240);

  C_COMPANY_NAME_HEADER VARCHAR2(50);

  C_REPORT_START_DATE DATE;

  C_NLS_YES VARCHAR2(80);

  C_NLS_NO VARCHAR2(80);

  C_NLS_ALL VARCHAR2(80);

  C_NLS_NO_DATA_EXISTS VARCHAR2(240);

  C_REPORT_RUN_TIME VARCHAR2(8);

  C_CHART_OF_ACCOUNTS_ID NUMBER;

  C_VENDOR_NAME_SELECT VARCHAR2(240);

  C_INVOICE_TYPE_SELECT VARCHAR2(80);

  C_MINDAYS NUMBER;

  C_MAXDAYS NUMBER;

  C_INV_DUE_1_HEAD_1 VARCHAR2(15);

  C_INV_DUE_1_HEAD_2 VARCHAR2(15);

  C_INV_DUE_2_HEAD_1 VARCHAR2(15);

  C_INV_DUE_2_HEAD_2 VARCHAR2(15);

  C_INV_DUE_3_HEAD_1 VARCHAR2(15);

  C_INV_DUE_3_HEAD_2 VARCHAR2(15);

  C_INV_DUE_4_HEAD_1 VARCHAR2(15);

  C_INV_DUE_4_HEAD_2 VARCHAR2(15);

  C_INV_DUE_1_RANGE_FR NUMBER;

  C_INV_DUE_1_RANGE_TO NUMBER;

  C_INV_DUE_2_RANGE_FR NUMBER;

  C_INV_DUE_2_RANGE_TO NUMBER;

  C_INV_DUE_3_RANGE_FR NUMBER;

  C_INV_DUE_3_RANGE_TO NUMBER;

  C_INV_DUE_4_RANGE_FR NUMBER;

  C_INV_DUE_4_RANGE_TO NUMBER;

  C_HEAD_INVOICE_TYPE VARCHAR2(80);

  C_HEAD_SORT_OPTION VARCHAR2(80);

  C_HEAD_VENDOR_NAME VARCHAR2(240);

  C_REP_DATA_CONVERTED VARCHAR2(1);

  C_NLS_END_OF_REPORT VARCHAR2(80);

  C_HEAD_SUMMARY_OPTION VARCHAR2(80);

  C_HEAD_FORMAT_OPTION VARCHAR2(80);

  C_HEAD_LEDGER_NAME VARCHAR2(30);

  C_HEAD_LEGAL_ENTITY_NAME VARCHAR2(80) := ':C_NLS_ALL';

  FUNCTION GET_BASE_CURR_DATA RETURN BOOLEAN;

  FUNCTION CUSTOM_INIT RETURN BOOLEAN;

  FUNCTION GET_COVER_PAGE_VALUES RETURN BOOLEAN;

  FUNCTION GET_NLS_STRINGS RETURN BOOLEAN;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION GET_COMPANY_NAME RETURN BOOLEAN;

  FUNCTION SET_ORDER_BY RETURN BOOLEAN;

  FUNCTION GET_PERIOD_INFO RETURN BOOLEAN;

  FUNCTION C_CONTACT_LINEFORMULA(C_CONTACT_SITE_ID IN NUMBER) RETURN VARCHAR2;

  FUNCTION C_PERCENT_REMAININGFORMULA(C_AMT_DUE_ORIGINAL IN NUMBER
                                     ,C_AMT_DUE_REMAINING IN NUMBER) RETURN NUMBER;

  FUNCTION C_INV_DUE_AMT_1FORMULA(C_DAYS_PAST_DUE IN NUMBER
                                 ,C_AMT_DUE_REMAINING IN NUMBER) RETURN NUMBER;

  FUNCTION C_INV_DUE_AMT_2FORMULA(C_DAYS_PAST_DUE IN NUMBER
                                 ,C_AMT_DUE_REMAINING IN NUMBER) RETURN NUMBER;

  FUNCTION C_INV_DUE_AMT_3FORMULA(C_DAYS_PAST_DUE IN NUMBER
                                 ,C_AMT_DUE_REMAINING IN NUMBER) RETURN NUMBER;

  FUNCTION C_INV_DUE_AMT_4FORMULA(C_DAYS_PAST_DUE IN NUMBER
                                 ,C_AMT_DUE_REMAINING IN NUMBER) RETURN NUMBER;

  FUNCTION C_PER_V_INV_AMT_1FORMULA(C_SUM_V_INV_AMT_1 IN NUMBER
                                   ,C_SUM_V_DUE_REMAINING IN NUMBER) RETURN NUMBER;

  FUNCTION C_PER_V_INV_AMT_2FORMULA(C_SUM_V_INV_AMT_2 IN NUMBER
                                   ,C_SUM_V_DUE_REMAINING IN NUMBER) RETURN NUMBER;

  FUNCTION C_PER_V_INV_AMT_3FORMULA(C_SUM_V_INV_AMT_3 IN NUMBER
                                   ,C_SUM_V_DUE_REMAINING IN NUMBER) RETURN NUMBER;

  FUNCTION C_PER_V_INV_AMT_4FORMULA(C_SUM_V_INV_AMT_4 IN NUMBER
                                   ,C_SUM_V_DUE_REMAINING IN NUMBER) RETURN NUMBER;

  FUNCTION C_CHECK_DATA_CONVERTEDFORMULA(C_DATA_CONVERTED IN VARCHAR2) RETURN NUMBER;

  FUNCTION C_PER_INV_DUE_AMT_1FORMULA(C_SUM_INV_DUE_AMT_1 IN NUMBER
                                     ,C_SUM_AMT_REMAINING IN NUMBER) RETURN NUMBER;

  FUNCTION C_PER_INV_DUE_AMT_2FORMULA(C_SUM_INV_DUE_AMT_2 IN NUMBER
                                     ,C_SUM_AMT_REMAINING IN NUMBER) RETURN NUMBER;

  FUNCTION C_PER_INV_DUE_AMT_3FORMULA(C_SUM_INV_DUE_AMT_3 IN NUMBER
                                     ,C_SUM_AMT_REMAINING IN NUMBER) RETURN NUMBER;

  FUNCTION C_PER_INV_DUE_AMT_4FORMULA(C_SUM_INV_DUE_AMT_4 IN NUMBER
                                     ,C_SUM_AMT_REMAINING IN NUMBER) RETURN NUMBER;

  FUNCTION C_PGBRK_DATA_CONVERTEDFORMULA(C_SUM_DATA_CONVERTED IN NUMBER) RETURN VARCHAR2;

  FUNCTION C_V_DATA_CONVERTEDFORMULA(C_SUM_V_DATA_CONVERTED IN NUMBER) RETURN VARCHAR2;

  FUNCTION C_TOT_PER_INV_DUE_1FORMULA(C_TOT_INV_DUE_AMT_1 IN NUMBER
                                     ,C_TOT_AMT_REMAINING IN NUMBER) RETURN NUMBER;

  FUNCTION C_TOT_PER_INV_DUE_2FORMULA(C_TOT_INV_DUE_AMT_2 IN NUMBER
                                     ,C_TOT_AMT_REMAINING IN NUMBER) RETURN NUMBER;

  FUNCTION C_TOT_PER_INV_DUE_3FORMULA(C_TOT_INV_DUE_AMT_3 IN NUMBER
                                     ,C_TOT_AMT_REMAINING IN NUMBER) RETURN NUMBER;

  FUNCTION C_TOT_PER_INV_DUE_4FORMULA(C_TOT_INV_DUE_AMT_4 IN NUMBER
                                     ,C_TOT_AMT_REMAINING IN NUMBER) RETURN NUMBER;

  FUNCTION CF_SYSDATEFORMULA RETURN CHAR;

  FUNCTION CF_DUE_DATEFORMULA(C_DUE_DATE IN VARCHAR2) RETURN CHAR;

  FUNCTION CHECK_AP_PROFILE RETURN BOOLEAN;

  PROCEDURE SORT_BY_ALTERNATE_P;

  FUNCTION C_BASE_CURRENCY_CODE_P RETURN VARCHAR2;

  FUNCTION C_BASE_PRECISION_P RETURN NUMBER;

  FUNCTION C_BASE_MIN_ACCT_UNIT_P RETURN NUMBER;

  FUNCTION C_BASE_DESCRIPTION_P RETURN VARCHAR2;

  FUNCTION C_COMPANY_NAME_HEADER_P RETURN VARCHAR2;

  FUNCTION C_REPORT_START_DATE_P RETURN DATE;

  FUNCTION C_NLS_YES_P RETURN VARCHAR2;

  FUNCTION C_NLS_NO_P RETURN VARCHAR2;

  FUNCTION C_NLS_ALL_P RETURN VARCHAR2;

  FUNCTION C_NLS_NO_DATA_EXISTS_P RETURN VARCHAR2;

  FUNCTION C_REPORT_RUN_TIME_P RETURN VARCHAR2;

  FUNCTION C_CHART_OF_ACCOUNTS_ID_P RETURN NUMBER;

  FUNCTION C_VENDOR_NAME_SELECT_P RETURN VARCHAR2;

  FUNCTION C_INVOICE_TYPE_SELECT_P RETURN VARCHAR2;

  FUNCTION C_MINDAYS_P RETURN NUMBER;

  FUNCTION C_MAXDAYS_P RETURN NUMBER;

  FUNCTION C_INV_DUE_1_HEAD_1_P RETURN VARCHAR2;

  FUNCTION C_INV_DUE_1_HEAD_2_P RETURN VARCHAR2;

  FUNCTION C_INV_DUE_2_HEAD_1_P RETURN VARCHAR2;

  FUNCTION C_INV_DUE_2_HEAD_2_P RETURN VARCHAR2;

  FUNCTION C_INV_DUE_3_HEAD_1_P RETURN VARCHAR2;

  FUNCTION C_INV_DUE_3_HEAD_2_P RETURN VARCHAR2;

  FUNCTION C_INV_DUE_4_HEAD_1_P RETURN VARCHAR2;

  FUNCTION C_INV_DUE_4_HEAD_2_P RETURN VARCHAR2;

  FUNCTION C_INV_DUE_1_RANGE_FR_P RETURN NUMBER;

  FUNCTION C_INV_DUE_1_RANGE_TO_P RETURN NUMBER;

  FUNCTION C_INV_DUE_2_RANGE_FR_P RETURN NUMBER;

  FUNCTION C_INV_DUE_2_RANGE_TO_P RETURN NUMBER;

  FUNCTION C_INV_DUE_3_RANGE_FR_P RETURN NUMBER;

  FUNCTION C_INV_DUE_3_RANGE_TO_P RETURN NUMBER;

  FUNCTION C_INV_DUE_4_RANGE_FR_P RETURN NUMBER;

  FUNCTION C_INV_DUE_4_RANGE_TO_P RETURN NUMBER;

  FUNCTION C_HEAD_INVOICE_TYPE_P RETURN VARCHAR2;

  FUNCTION C_HEAD_SORT_OPTION_P RETURN VARCHAR2;

  FUNCTION C_HEAD_VENDOR_NAME_P RETURN VARCHAR2;

  FUNCTION C_REP_DATA_CONVERTED_P RETURN VARCHAR2;

  FUNCTION C_NLS_END_OF_REPORT_P RETURN VARCHAR2;

  FUNCTION C_HEAD_SUMMARY_OPTION_P RETURN VARCHAR2;

  FUNCTION C_HEAD_FORMAT_OPTION_P RETURN VARCHAR2;

  FUNCTION C_HEAD_LEDGER_NAME_P RETURN VARCHAR2;

  FUNCTION C_HEAD_LEGAL_ENTITY_NAME_P RETURN VARCHAR2;

END JE_JEHUIAGE_XMLP_PKG;



/
