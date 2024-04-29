--------------------------------------------------------
--  DDL for Package ZX_ZXXINUTR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_ZXXINUTR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: ZXXINUTRS.pls 120.1.12010000.1 2008/07/28 13:28:02 appldev ship $ */
  P_DEBUG_SWITCH VARCHAR2(1);

  P_CONC_REQUEST_ID NUMBER := 0;

  P_MIN_PRECISION NUMBER := 0;

  P_FLEXDATA VARCHAR2(600);

  P_SET_OF_BOOKS_ID NUMBER;

  P_ORDERBY VARCHAR2(40);

  P_REPORT_BASIS VARCHAR2(40);

  P_CURR_CODE VARCHAR2(40);

  P_START_DATE DATE;
  P_START_DATE_D varchar2(40);

  P_END_DATE DATE;
  P_END_DATE_D varchar2(40);

  P_TAX_PARAM VARCHAR2(40);
  P_TAX_PARAM_DISP VARCHAR2(40);

  P_INV_STATUS VARCHAR2(40);
  P_INV_STATUS_D VARCHAR2(40);

  P_SUMMARY_FLAG VARCHAR2(1);
  P_SUMMARY_FLAG_D VARCHAR2(1);

  P_REPORTING_ENTITY_ID NUMBER;

  P_REPORTING_LEVEL VARCHAR2(200);

  P_ORG_WHERE_V VARCHAR2(2000);

  P_ORG_WHERE_VS VARCHAR2(2000):= ' ';

  P_ORG_WHERE_I VARCHAR2(2000):= ' ';

  P_ORG_WHERE_D VARCHAR2(2000):= ' ';

  P_ORG_WHERE_B VARCHAR2(2000):= ' ';

  P_ORG_WHERE_T VARCHAR2(2000);

  P_LEVEL_NAME VARCHAR2(200);

  P_ENTITY_NAME VARCHAR2(240);

  P_ORG_WHERE_H VARCHAR2(2000):=' ';

  P_ORG_WHERE_D2 VARCHAR2(2000);

  P_SQL_TRACE VARCHAR2(2);

  C_OLD_VENDOR_ID NUMBER := 0;

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

  C_NLS_REPORT_BASIS VARCHAR2(80);

  C_NLS_INV_STATUS VARCHAR2(80);

  C_NLS_ORDERBY VARCHAR2(80);

  C_NLS_TAX_PARAM VARCHAR2(80);

  C_NLS_END_OF_REPORT VARCHAR2(100);

  FUNCTION GET_BASE_CURR_DATA RETURN BOOLEAN;

  FUNCTION CUSTOM_INIT RETURN BOOLEAN;

  FUNCTION GET_COVER_PAGE_VALUES RETURN BOOLEAN;

  FUNCTION GET_NLS_STRINGS RETURN BOOLEAN;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION GET_COMPANY_NAME RETURN BOOLEAN;

  FUNCTION CALCULATE_RUN_TIME RETURN BOOLEAN;

  FUNCTION ITEM_AMOUNT(C_INVOICE_ID IN NUMBER
                      ,C_TAX_NAME IN VARCHAR2
                      ,C_INVOICE_TAX_ID IN NUMBER) RETURN NUMBER;

  FUNCTION TAX_AMOUNT(C_TAXABLE_AMOUNT IN NUMBER
                     ,C_TAX_RATE IN NUMBER) RETURN NUMBER;

  FUNCTION AFTERPFORM RETURN BOOLEAN;

  FUNCTION C_OLD_VENDOR_ID_P RETURN NUMBER;

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

  FUNCTION C_NLS_REPORT_BASIS_P RETURN VARCHAR2;

  FUNCTION C_NLS_INV_STATUS_P RETURN VARCHAR2;

  FUNCTION C_NLS_ORDERBY_P RETURN VARCHAR2;

  FUNCTION C_NLS_TAX_PARAM_P RETURN VARCHAR2;

  FUNCTION C_NLS_END_OF_REPORT_P RETURN VARCHAR2;

END ZX_ZXXINUTR_XMLP_PKG;


/
