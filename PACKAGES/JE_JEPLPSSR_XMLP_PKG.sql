--------------------------------------------------------
--  DDL for Package JE_JEPLPSSR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JE_JEPLPSSR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: JEPLPSSRS.pls 120.1 2007/12/25 16:58:23 dwkrishn noship $ */
  P_DEBUG_SWITCH VARCHAR2(1);

  P_CONC_REQUEST_ID NUMBER;

  P_LEDGER_ID NUMBER;

  P_TRACE_SWITCH VARCHAR2(1);

  P_REPORT_CURRENCY VARCHAR2(15);

  P_START_DATE date;

  LP_START_DATE date;

  --lp_start_date varchar2(30);

  P_SUPPLIER_NAME_FROM VARCHAR2(240);

  P_SUPPLIER_NAME_TO VARCHAR2(240);

  P_COUNTRY_CODE VARCHAR2(32767);

  P_SUPPLIER_TAX_ID VARCHAR2(30);

  P_MIN_PRECISION NUMBER;

  P_END_DATE DATE;

  LP_END_DATE DATE;

  --LP_END_DATE varchar2(30);

  P_DOCUMENT_CATEGORY VARCHAR2(32767);

  P_POSTED VARCHAR2(3);

  P_APPROVED VARCHAR2(10);

  P_WHERE VARCHAR2(100);

  P_PARAMETERS_DESC VARCHAR2(100);

  CP_PARAMETERS_DESC VARCHAR2(100);

  P_WHERE_CAT VARCHAR2(100):=' ';

  P_LEDGER_NAME VARCHAR2(70);

  P_VENDOR_ID NUMBER;

  P_REPORT_CURRENCY_DISP VARCHAR2(25);

  P_REPORTING_LEVEL VARCHAR2(30);

  P_REPORTING_ENTITY_ID NUMBER;

  P_ORG_WHERE_POSIT VARCHAR2(2000);

  P_ORG_WHERE_AI VARCHAR2(2000);

  P_ORG_WHERE_AID VARCHAR2(2000);

  P_ORG_WHERE_ALC VARCHAR2(2000);

  P_ORG_WHERE_AC VARCHAR2(2000);

  P_REPORTING_ENTITY_NAME VARCHAR2(50);

  P_REPORTING_LEVEL_NAME VARCHAR2(50);

  P_ORG_WHERE_AIP VARCHAR2(2000);

  P_ORG_WHERE_AI2 VARCHAR2(2000);

  P_ORG_WHERE_AID2 VARCHAR2(2000);

  P_CHECK_LEDGER_IN_SP VARCHAR2(10);

  P_PARTIAL_LEDGER_MSG VARCHAR2(240);

  CP_TEXT VARCHAR2(200);

  CP_REF_TRANS_NUM VARCHAR2(15);

  CP_REF_TRANS_TYPE VARCHAR2(32767);

  C_NLS_YES VARCHAR2(80);

  C_NLS_NO VARCHAR2(80);

  C_NLS_ALL VARCHAR2(25);

  C_NLS_NO_DATA_EXISTS VARCHAR2(240);

  C_NLS_VOID VARCHAR2(25);

  C_NLS_NA VARCHAR2(25);

  C_NLS_END_OF_REPORT VARCHAR2(100);

  C_REPORT_START_DATE DATE;

  C_COMPANY_NAME_HEADER VARCHAR2(50);

  C_BASE_CURRENCY_CODE VARCHAR2(15);

  C_BASE_PRECISION NUMBER;

  C_BASE_MIN_ACCT_UNIT NUMBER;

  C_BASE_DESCRIPTION VARCHAR2(240);

  C_CHART_OF_ACCOUNTS_ID NUMBER;

  APPLICATIONS_TEMPLATE_REPORT VARCHAR2(1);

  CP_CREATE_AWT_DISTS_TYPE VARCHAR2(32767);

  LP_SUPPLIER VARCHAR2(1000);

  CP_DATE4_FORMAT VARCHAR2(20);

  CP_MESSAGE VARCHAR2(300);

  CP_REPORT_CURRENCY VARCHAR2(32767);

  CP_REPORT_CURR_DISP VARCHAR2(20);

  CP_SUPPLIER_NAME_FROM VARCHAR2(240);

  CP_SUPPLIER_NAME_TO VARCHAR2(240);

  CP_POSTED_FLAG VARCHAR2(32767);

  CP_APPROVED_FLAG VARCHAR2(32767);

  CP_LEDGER_NAME VARCHAR2(50);

  CP_SUPPLIER_TAX_ID VARCHAR2(30);

  CP_DOCUMENT_CATEGORY VARCHAR2(100);

  CP_TITLE VARCHAR2(240);

  CP_PARTIAL_LEDGER_MSG VARCHAR2(240);

  FUNCTION GET_BASE_CURR_DATA RETURN BOOLEAN;

  FUNCTION GET_COVER_PAGE_VALUES RETURN BOOLEAN;

  FUNCTION GET_NLS_STRINGS RETURN BOOLEAN;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION CF_REF_TRANS_DATEFORMULA(TRANS_TYPE IN VARCHAR2
                                   ,TRANS_ID IN NUMBER) RETURN DATE;

  FUNCTION CF_AMOUNT_CURRENCYFORMULA(TRANS_AMT IN NUMBER
                                    ,TRANS_BASE_AMT IN NUMBER) RETURN NUMBER;

  FUNCTION CF_AMOUNT_DUE_CURRENCYFORMULA(TRANS_TYPE IN VARCHAR2
                                        ,TRANS_ID IN NUMBER
                                        ,TRANS_AMT IN NUMBER
                                        ,TRANS_BASE_AMT IN NUMBER
                                        ,SECTION IN VARCHAR2
                                        ,CF_TRX_PRECISION IN NUMBER) RETURN NUMBER;

  FUNCTION CF_SUPP_BBFORMULA(VENDOR_ID IN NUMBER
                            ,GROUP_CURRENCY IN VARCHAR2
                            ,CF_GROUP_PRECISION IN NUMBER) RETURN NUMBER;

  FUNCTION CF_GROUP_PRECISIONFORMULA(GROUP_CURRENCY IN VARCHAR2) RETURN NUMBER;

  FUNCTION CF_REMAIN_BALANCEFORMULA(CF_SUPP_BB IN NUMBER
                                   ,CS_AMOUNT_APPLIED IN NUMBER) RETURN NUMBER;

  FUNCTION CF_TRX_PRECISIONFORMULA(TRANS_CURRENCY IN VARCHAR2) RETURN NUMBER;

  FUNCTION CF_ENDING_BALANCEFORMULA(CF_SUPP_BB IN NUMBER
                                   ,CS_ACCUM_BALANCE IN NUMBER) RETURN NUMBER;

  FUNCTION ACCEPT_PARAMETERS RETURN BOOLEAN;

  FUNCTION CF_AMOUNT_TO_APPLYFORMULA(SECTION IN VARCHAR2
                                    ,RELATE_TRANS_TYPE IN VARCHAR2
                                    ,CF_AMOUNT_CURRENCY IN NUMBER
                                    ,CF_AMOUNT_DUE_CURRENCY IN NUMBER) RETURN NUMBER;

  FUNCTION CF_1FORMULA(TRANS_ID IN NUMBER) RETURN CHAR;

  FUNCTION CF_TRANS_DATEFORMULA(TRANS_DATE IN DATE) RETURN CHAR;

  FUNCTION CF_REF_TRANS_DATE1FORMULA(REF_TRANS_DATE IN DATE) RETURN CHAR;

  FUNCTION CF_START_DATEFORMULA RETURN CHAR;

  FUNCTION CF_END_DATEFORMULA RETURN CHAR;

  FUNCTION CF_COVER_START_DATEFORMULA RETURN CHAR;

  FUNCTION CF_COVER_END_DATEFORMULA RETURN CHAR;

  FUNCTION CF_TEXTFORMULA(DESCRIPTION1 IN VARCHAR2
                         ,GROUP_CURRENCY IN VARCHAR2
                         ,CF_AMT_DUE_DSP IN VARCHAR2) RETURN CHAR;

  FUNCTION CF_AMOUNT_DUEFORMULA(VENDOR_ID IN NUMBER
                               ,VENDOR_SITE_ID IN NUMBER
                               ,CF_ENDING_BALANCE IN NUMBER) RETURN NUMBER;

  FUNCTION CF_VENDOR_CHECKFORMULA(VENDOR_ID IN NUMBER) RETURN NUMBER;

  FUNCTION CF_POSTED_ONLYFORMULA RETURN CHAR;

  FUNCTION CF_APPROVED_ONLYFORMULA RETURN CHAR;

  FUNCTION CF_GROUP_CURRFORMULA(GROUP_CURRENCY IN VARCHAR2) RETURN CHAR;

  FUNCTION CP_TEXTFORMULA(CF_TEXT IN VARCHAR2) RETURN CHAR;

  FUNCTION AFTERPFORM RETURN BOOLEAN;

  FUNCTION CF_ORG_NAMEFORMULA(ORGANIZATION_ID IN NUMBER) RETURN CHAR;

  FUNCTION P_CHECK_LEDGER_IN_SPVALIDTRIGG RETURN BOOLEAN;

  FUNCTION P_PARTIAL_LEDGER_MSGVALIDTRIGG RETURN BOOLEAN;

  FUNCTION CP_TEXT_P RETURN VARCHAR2;

  FUNCTION CP_REF_TRANS_NUM_P RETURN VARCHAR2;

  FUNCTION CP_REF_TRANS_TYPE_P RETURN VARCHAR2;

  FUNCTION C_NLS_YES_P RETURN VARCHAR2;

  FUNCTION C_NLS_NO_P RETURN VARCHAR2;

  FUNCTION C_NLS_ALL_P RETURN VARCHAR2;

  FUNCTION C_NLS_NO_DATA_EXISTS_P RETURN VARCHAR2;

  FUNCTION C_NLS_VOID_P RETURN VARCHAR2;

  FUNCTION C_NLS_NA_P RETURN VARCHAR2;

  FUNCTION C_NLS_END_OF_REPORT_P RETURN VARCHAR2;

  FUNCTION C_REPORT_START_DATE_P RETURN DATE;

  FUNCTION C_COMPANY_NAME_HEADER_P RETURN VARCHAR2;

  FUNCTION C_BASE_CURRENCY_CODE_P RETURN VARCHAR2;

  FUNCTION C_BASE_PRECISION_P RETURN NUMBER;

  FUNCTION C_BASE_MIN_ACCT_UNIT_P RETURN NUMBER;

  FUNCTION C_BASE_DESCRIPTION_P RETURN VARCHAR2;

  FUNCTION C_CHART_OF_ACCOUNTS_ID_P RETURN NUMBER;

  FUNCTION APPLICATIONS_TEMPLATE_REPORT_P RETURN VARCHAR2;

  FUNCTION CP_CREATE_AWT_DISTS_TYPE_P RETURN VARCHAR2;

  FUNCTION LP_SUPPLIER_P RETURN VARCHAR2;

  FUNCTION CP_DATE4_FORMAT_P RETURN VARCHAR2;

  FUNCTION CP_MESSAGE_P RETURN VARCHAR2;

  FUNCTION CP_REPORT_CURRENCY_P RETURN VARCHAR2;

  FUNCTION CP_REPORT_CURR_DISP_P RETURN VARCHAR2;

  FUNCTION CP_SUPPLIER_NAME_FROM_P RETURN VARCHAR2;

  FUNCTION CP_SUPPLIER_NAME_TO_P RETURN VARCHAR2;

  FUNCTION CP_POSTED_FLAG_P RETURN VARCHAR2;

  FUNCTION CP_APPROVED_FLAG_P RETURN VARCHAR2;

  FUNCTION CP_LEDGER_NAME_P RETURN VARCHAR2;

  FUNCTION CP_SUPPLIER_TAX_ID_P RETURN VARCHAR2;

  FUNCTION CP_DOCUMENT_CATEGORY_P RETURN VARCHAR2;

  FUNCTION CP_TITLE_P RETURN VARCHAR2;

  FUNCTION CP_PARTIAL_LEDGER_MSG_P RETURN VARCHAR2;

  FUNCTION CONVERT(P_YES_NO IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION  CUSTOM_INIT RETURN BOOLEAN;

END JE_JEPLPSSR_XMLP_PKG;



/
