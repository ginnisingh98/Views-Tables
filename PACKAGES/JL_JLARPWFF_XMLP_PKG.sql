--------------------------------------------------------
--  DDL for Package JL_JLARPWFF_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_JLARPWFF_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: JLARPWFFS.pls 120.1 2007/12/25 16:35:47 dwkrishn noship $ */
  P_DEBUG_SWITCH VARCHAR2(1);

  P_CONC_REQUEST_ID NUMBER := 0;

  P_MIN_PRECISION NUMBER;

  P_START_DATE DATE;

  P_END_DATE DATE;

  P_JURISDICTION_TYPE VARCHAR2(50);

  P_WITHHOLDING_TYPE_FROM VARCHAR2(30);

  P_WITHHOLDING_TYPE_TO VARCHAR2(30);

  P_INCLUDE_FOREIGN_SUPP VARCHAR2(30);

  P_DOCUMENT_CODE VARCHAR2(6);

  P_LOCATION_ID NUMBER;

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

  FUNCTION GET_BASE_CURR_DATA RETURN BOOLEAN;

  FUNCTION CUSTOM_INIT RETURN BOOLEAN;

  FUNCTION GET_COVER_PAGE_VALUES RETURN BOOLEAN;

  FUNCTION GET_NLS_STRINGS RETURN BOOLEAN;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION GET_COMPANY_NAME RETURN BOOLEAN;

  FUNCTION CF_WHT_AGENT_NUMFORMULA(COMP_PRIMARY_ID_NUMBER IN VARCHAR2
                                  ,COMP_TAX_AUTHORITY_ID IN NUMBER
                                  ,COMP_TAX_AUTHORITY_TYPE IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION CF_SUPP_INSCRIPTIONFORMULA(SUPP_PRIMARY_ID_NUMBER IN VARCHAR2
                                     ,SUPP_TAX_AUTHORITY_ID IN NUMBER
                                     ,SUPP_TAX_AUTHORITY_TYPE IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION CF_AMT_IN_EXCESSFORMULA RETURN VARCHAR2;

  FUNCTION CF_DOCUMENT_AMTFORMULA(DOCUMENT_AMOUNT IN NUMBER) RETURN VARCHAR2;

  FUNCTION CF_FEDERAL_RECFORMULA(DOCUMENT_DATE IN DATE
                                ,DOCUMENT_NUMBER IN VARCHAR2
                                ,CF_DOCUMENT_AMT IN VARCHAR2
                                ,DGI_TAX_TYPE_CODE IN VARCHAR2
                                ,DGI_TAX_REGIME_CODE IN VARCHAR2
                                ,WITHHOLDING_CODE IN VARCHAR2
                                ,CF_TAXABLE_AMT IN VARCHAR2
                                ,SUPPLIER_CONDITION_CODE IN VARCHAR2
                                ,CF_WH_AMT IN VARCHAR2
                                ,CF_EXEMPT_PERC IN VARCHAR2
                                ,BULLETIN_ISSUE_DATE IN VARCHAR2
                                ,SUPP_TAX_IDENTIFICATION_TYPE IN VARCHAR2
                                ,CUIT_NUMBER IN VARCHAR2
                                ,CF_CERT_NUM IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION CF_PROV_RECFORMULA(DOCUMENT_DATE IN DATE
                             ,DOCUMENT_NUMBER IN VARCHAR2
                             ,CF_DOCUMENT_AMT IN VARCHAR2
                             ,DGI_TAX_TYPE_CODE IN VARCHAR2
                             ,DGI_TAX_REGIME_CODE IN VARCHAR2
                             ,WITHHOLDING_CODE IN VARCHAR2
                             ,CF_TAXABLE_AMT IN VARCHAR2
                             ,SUPPLIER_CONDITION_CODE IN VARCHAR2
                             ,CF_WH_AMT IN VARCHAR2
                             ,CF_EXEMPT_PERC IN VARCHAR2
                             ,BULLETIN_ISSUE_DATE IN VARCHAR2
                             ,SUPP_TAX_IDENTIFICATION_TYPE IN VARCHAR2
                             ,CUIT_NUMBER IN VARCHAR2
                             ,CF_CERT_NUM IN VARCHAR2
                             ,CF_WHT_AGENT_NUM IN VARCHAR2
                             ,CF_SUPP_INSCRIPTION IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION CF_ZONAL_RECFORMULA(DGI_TAX_REGIME_CODE IN VARCHAR2
                              ,CUIT_NUMBER IN VARCHAR2
                              ,CF_AMT_IN_EXCESS IN VARCHAR2
                              ,DOCUMENT_DATE IN DATE
                              ,CF_WH_AMT IN VARCHAR2
                              ,CF_CERT_NUM IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION CF_TAXABLE_AMTFORMULA(DOCUMENT_AMOUNT IN NUMBER) RETURN VARCHAR2;

  FUNCTION CF_WH_AMTFORMULA(WITHHOLDING_AMOUNT IN NUMBER) RETURN VARCHAR2;

  FUNCTION CF_SPACEFORMULA RETURN VARCHAR2;

  FUNCTION CF_CERT_NUMFORMULA(CERTIFICATE_NUMBER IN NUMBER) RETURN VARCHAR2;

  FUNCTION CF_EXEMPT_PERCFORMULA(EXEMPTION_PERCENTAGE IN NUMBER) RETURN VARCHAR2;

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

END JL_JLARPWFF_XMLP_PKG;



/