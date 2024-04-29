--------------------------------------------------------
--  DDL for Package JL_JLCOGLCM_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_JLCOGLCM_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: JLCOGLCMS.pls 120.1 2007/12/25 16:48:55 dwkrishn noship $ */
  P_DEBUG_SWITCH VARCHAR2(1);

  P_CONC_REQUEST_ID NUMBER := 0;

  P_MIN_PRECISION NUMBER;

  P_FLEXDATA VARCHAR2(600);

  P_SET_OF_BOOKS_ID NUMBER;

  P_TRACE_SWITCH VARCHAR2(1);

  P_LITERAL_FROM VARCHAR2(40);

  P_LITERAL_TO VARCHAR2(40);

  P_REPORT_YEAR VARCHAR2(40);

  P_MAG_MEDIA_STATUS VARCHAR2(32767);

  P_REPORT_TITLE VARCHAR2(60);

  C_NLS_YES VARCHAR2(80);

  C_NLS_NO VARCHAR2(80);

  C_NLS_ALL VARCHAR2(25);

  C_NLS_NO_DATA_EXISTS VARCHAR2(240);

  C_NLS_VOID VARCHAR2(25);

  C_NLS_NA VARCHAR2(25);

  C_NLS_END_OF_REPORT VARCHAR2(100);

  C_REPORT_START_DATE DATE;

  COMPANY_NAME VARCHAR2(240);

  C_BASE_CURRENCY_CODE VARCHAR2(15);

  C_BASE_PRECISION NUMBER;

  C_BASE_MIN_ACCT_UNIT NUMBER;

  C_BASE_DESCRIPTION VARCHAR2(240);

  C_CHART_OF_ACCOUNTS_ID NUMBER;

  APPLICATIONS_TEMPLATE_REPORT VARCHAR2(1);

  C_ACCOUNT_START VARCHAR2(1000) := '(r.segment1_low||''.''||r.segment3_low)';

  C_ACCOUNT_END VARCHAR2(1000) := '(r.segment1_high||''.''||r.segment3_high)';

  FUNCTION GET_BASE_CURR_DATA RETURN BOOLEAN;

  FUNCTION CUSTOM_INIT RETURN BOOLEAN;

  FUNCTION GET_COVER_PAGE_VALUES RETURN BOOLEAN;

  FUNCTION GET_NLS_STRINGS RETURN BOOLEAN;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION GET_COMPANY_NAME RETURN BOOLEAN;

  FUNCTION CF_1FORMULA RETURN VARCHAR2;

  FUNCTION C_NLS_YES_P RETURN VARCHAR2;

  FUNCTION C_NLS_NO_P RETURN VARCHAR2;

  FUNCTION C_NLS_ALL_P RETURN VARCHAR2;

  FUNCTION C_NLS_NO_DATA_EXISTS_P RETURN VARCHAR2;

  FUNCTION C_NLS_VOID_P RETURN VARCHAR2;

  FUNCTION C_NLS_NA_P RETURN VARCHAR2;

  FUNCTION C_NLS_END_OF_REPORT_P RETURN VARCHAR2;

  FUNCTION C_REPORT_START_DATE_P RETURN DATE;

  FUNCTION COMPANY_NAME_P RETURN VARCHAR2;

  FUNCTION C_BASE_CURRENCY_CODE_P RETURN VARCHAR2;

  FUNCTION C_BASE_PRECISION_P RETURN NUMBER;

  FUNCTION C_BASE_MIN_ACCT_UNIT_P RETURN NUMBER;

  FUNCTION C_BASE_DESCRIPTION_P RETURN VARCHAR2;

  FUNCTION C_CHART_OF_ACCOUNTS_ID_P RETURN NUMBER;

  FUNCTION APPLICATIONS_TEMPLATE_REPORT_P RETURN VARCHAR2;

  FUNCTION C_ACCOUNT_START_P RETURN VARCHAR2;

  FUNCTION C_ACCOUNT_END_P RETURN VARCHAR2;

END JL_JLCOGLCM_XMLP_PKG;



/