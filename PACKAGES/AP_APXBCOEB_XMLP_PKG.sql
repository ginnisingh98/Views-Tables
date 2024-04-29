--------------------------------------------------------
--  DDL for Package AP_APXBCOEB_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_APXBCOEB_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: APXBCOEBS.pls 120.0 2007/12/27 07:29:24 vjaganat noship $ */
  P_DEBUG_SWITCH VARCHAR2(1);

  P_CONC_REQUEST_ID NUMBER := 0;

  P_MIN_PRECISION NUMBER;

  P_FLEXDATA VARCHAR2(600);

  P_SET_OF_BOOKS_ID NUMBER;

  P_START_DATE DATE;

  P_END_DATE DATE;

    AA_P_START_DATE varchar2(50);

  AA_P_END_DATE varchar2(50);

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

  C_CHART_OF_ACCOUNTS_ID NUMBER;

  C_NLS_END_OF_REPORT VARCHAR2(100);

  FUNCTION GET_BASE_CURR_DATA RETURN BOOLEAN;

  FUNCTION CUSTOM_INIT RETURN BOOLEAN;

  FUNCTION GET_COVER_PAGE_VALUES RETURN BOOLEAN;

  FUNCTION GET_NLS_STRINGS RETURN BOOLEAN;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION GET_COMPANY_NAME RETURN BOOLEAN;

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

  FUNCTION C_CHART_OF_ACCOUNTS_ID_P RETURN NUMBER;

  FUNCTION C_NLS_END_OF_REPORT_P RETURN VARCHAR2;

END AP_APXBCOEB_XMLP_PKG;


/
