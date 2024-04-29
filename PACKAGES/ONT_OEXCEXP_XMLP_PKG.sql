--------------------------------------------------------
--  DDL for Package ONT_OEXCEXP_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ONT_OEXCEXP_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: OEXCEXPS.pls 120.1 2007/12/25 07:09:35 npannamp noship $ */
  P_CUSTOMER_NAME_HIGH VARCHAR2(360);

  P_CUSTOMER_NAME_LOW VARCHAR2(360);

  P_CUST_NUMBER_HIGH VARCHAR2(30);

  P_CUST_NUMBER_LOW VARCHAR2(30);

  P_CR_CHECK_RULE_ID NUMBER;

  P_PROF_CLASS_LOW VARCHAR2(40);

  P_PROF_CLASS_HIGH VARCHAR2(40);

  P_CONC_REQUEST_ID NUMBER;

  P_ORG_ID NUMBER;

  P_ORDER_BY VARCHAR2(40);

  P_RETURN_STATUS VARCHAR2(1);

  P_REPORT_BY_OPTION VARCHAR2(30);

  P_SPECIFIC_PARTY_ID NUMBER;

  P_SPEC_PARTY_NUM_ID NUMBER;

  P_PARTY_NAME_LOW VARCHAR2(360);

  P_PARTY_NAME_HIGH VARCHAR2(360);

  P_PARTY_NUMBER_LOW VARCHAR2(30);

  P_PARTY_NUMBER_HIGH VARCHAR2(30);

  P_PARTY_NAME VARCHAR2(360);

  CP_TOTAL_EXPOSURE NUMBER;

  CP_BASE_CURRENCY VARCHAR2(5);

  CP_CUST_LIMIT_GRAND_TOTAL NUMBER;

  CP_CUST_EXPOSURE_GRAND_TOTAL NUMBER;

  CP_CUST_AVAILABLE_GRAND_TOTAL NUMBER;

  CP_SITE_TOTAL_EXPOSURE NUMBER;

  CP_BASE_CURRENCY1 VARCHAR2(5);

  CP_UNCHECKED_EXPOSURE NUMBER;

  CP_PARTY_EXP_GRAND_TOTAL NUMBER;

  CP_PARTY_BASE_CURRENCY VARCHAR2(15);

  CP_PARTY_NAME_TOTAL_EXP VARCHAR2(360);

  CP_PARTY_NAME_UNCHECK VARCHAR2(360);

  CP_PARTY_SUM_GRAND_AVAIL NUMBER := 0;

  CP_BASE_CURRENCY_D VARCHAR2(30);

  CP_EXPOSURE_TOTAL_D NUMBER;

  CP_PARTY_DTL_GRAND_TOTAL_AVAIL NUMBER := 0;

  CP_BASE_CURRENCY_CUST VARCHAR2(30);

  CP_TOTAL_UNCHECKED_EXP_CUST NUMBER := 0;

  CP_TOTAL_AVAIL_PARTY_CUST NUMBER;

  CP_EXP_AND_UNCHECKED NUMBER;

  CP_CUSTOMER_LOW VARCHAR2(380);

  CP_CUSTOMER_HIGH VARCHAR2(380);

  CP_PROF_CLASS_LOW VARCHAR2(30);

  CP_PROF_CLASS_HIGH VARCHAR2(30);

  CP_CUST_NUM_LOW VARCHAR2(30);

  CP_CUST_NUM_HIGH VARCHAR2(30);

  CP_OPERATING_UNIT VARCHAR2(240);

  CP_REPORT_OPTION VARCHAR2(80);

  CP_HIERARCHY_NAME VARCHAR2(200);

  CP_PARTY_NAME VARCHAR2(360);

  CP_PARTY_NUMBER VARCHAR2(30);

  CP_CHECK_RULE VARCHAR2(240);

  RP_COMPANY_NAME VARCHAR2(240);

  FUNCTION CF_GET_RULE_NAMEFORMULA RETURN NUMBER;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION CF_GET_TOTAL_EXPOSUREFORMULA(CS_BASE_EXPOSURE_SUM IN NUMBER
                                       ,UNCHECKED_EXPOSURE IN NUMBER) RETURN NUMBER;

  FUNCTION CF_GET_OPER_UNITFORMULA RETURN NUMBER;

  FUNCTION CF_GET_BASE_CURRFORMULA(BASE_CURRENCY2 IN VARCHAR2) RETURN NUMBER;

  FUNCTION CF_GET_SITE_TOTAL_EXPFORMULA(CS_SITE_EXPOSURE_SUM IN NUMBER
                                       ,D_UNCHECKED_EXPOSURE IN NUMBER) RETURN NUMBER;

  FUNCTION CF_GET_BASE_CURRENCY1FORMULA(D_BASE_CURRENCY IN VARCHAR2) RETURN NUMBER;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION CF_GET_LIMIT_G_TOTALFORMULA(D_CUSTOMER_ID IN NUMBER) RETURN NUMBER;

  FUNCTION CF_GET_EXP_G_TOTALFORMULA(D_CUSTOMER_ID IN NUMBER) RETURN NUMBER;

  FUNCTION CF_GET_AVAIL_G_TOTALFO(D_CUSTOMER_ID IN NUMBER) RETURN NUMBER;

  FUNCTION AFTERPFORM RETURN BOOLEAN;

  FUNCTION CF_PARTY_GET_TOTALSFORMULA(CS_PARTY_BASE_CUR_EXPOSURE_SUM IN NUMBER
                                     ,UNCHECKED_EXPOSURE_P IN NUMBER) RETURN NUMBER;

  FUNCTION CF_GET_PARTY_BASE_CURRENCYFORM(BASE_CURRENCY_P IN VARCHAR2) RETURN NUMBER;

  FUNCTION CF_GET_REPORT_OPTIONFORMULA RETURN NUMBER;

  FUNCTION CF_GET_BASE_CUR_DFORMULA(BASE_CURRENCY_D IN VARCHAR2) RETURN NUMBER;

  FUNCTION CF_GET_EXPOSURE_TOTAL_DFORMULA(CS_EXPOSURE_SUM_D IN NUMBER
                                         ,UNCHECKED_EXPOSURE_D IN NUMBER) RETURN NUMBER;

  FUNCTION CF_GET_HIERARCHY_NAMEFORMULA RETURN NUMBER;

  FUNCTION CF_GET_B_CURRENCY_CUSTFORMULA(BASE_CURRENCY_CUST IN VARCHAR2) RETURN NUMBER;

  FUNCTION CF_GET_EXP_AND_UNCHFORMULA(BASE_EXPOSURE_CUST IN NUMBER) RETURN NUMBER;

  FUNCTION CF_GET_PARTY_NAME_TOTALFORMULA(PARTY_NAME IN VARCHAR2) RETURN NUMBER;

  FUNCTION CF_GET_PARTY_NAME_UNFORMULA(PARTY_NAME IN VARCHAR2) RETURN NUMBER;

  FUNCTION CF_GET_PARTY_NAMEFORMULA RETURN NUMBER;

  PROCEDURE GET_HIERARCHY;

  FUNCTION CF_TOTAL_UNCHECKED_EXP_CUSTFOR(CS_TOTAL_EXP_AND_UNCH IN NUMBER
                                         ,UNCHECKED_EXPOSURE_CUST IN NUMBER) RETURN NUMBER;

  FUNCTION CF_TOTAL_AVAIL_PARTY_CUSTFORMU(CS_TOTAL_OVERALL_CUST IN NUMBER) RETURN NUMBER;

  FUNCTION CF_PARTY_SUM_GRAND_AVAILFORMUL(CS_PARTY_BASE_CUR_OVERALL_SUM IN NUMBER) RETURN NUMBER;

  FUNCTION CF_PARTY_DTL_GRAND_TOTAL_AVAIL(CS_OVERALL_LIMIT_SUM_D IN NUMBER) RETURN NUMBER;

  FUNCTION CP_PARTY_NAMEFORMULA RETURN CHAR;

  FUNCTION CP_TOTAL_EXPOSURE_P RETURN NUMBER;

  FUNCTION CP_BASE_CURRENCY_P RETURN VARCHAR2;

  FUNCTION CP_CUST_LIMIT_GRAND_TOTAL_P RETURN NUMBER;

  FUNCTION CP_CUST_EXPOSURE_GRAND_TOTAL_P RETURN NUMBER;

  FUNCTION CP_CUST_AVAILABLE_GRAND_TOT_P RETURN NUMBER;

  FUNCTION CP_SITE_TOTAL_EXPOSURE_P RETURN NUMBER;

  FUNCTION CP_BASE_CURRENCY1_P RETURN VARCHAR2;

  FUNCTION CP_UNCHECKED_EXPOSURE_P RETURN NUMBER;

  FUNCTION CP_PARTY_EXP_GRAND_TOTAL_P RETURN NUMBER;

  FUNCTION CP_PARTY_BASE_CURRENCY_P RETURN VARCHAR2;

  FUNCTION CP_PARTY_NAME_TOTAL_EXP_P RETURN VARCHAR2;

  FUNCTION CP_PARTY_NAME_UNCHECK_P RETURN VARCHAR2;

  FUNCTION CP_PARTY_SUM_GRAND_AVAIL_P RETURN NUMBER;

  FUNCTION CP_BASE_CURRENCY_D_P RETURN VARCHAR2;

  FUNCTION CP_EXPOSURE_TOTAL_D_P RETURN NUMBER;

  FUNCTION CP_PARTY_DTL_GRAND_TOTAL_AVAI RETURN NUMBER;

  FUNCTION CP_BASE_CURRENCY_CUST_P RETURN VARCHAR2;

  FUNCTION CP_TOTAL_UNCHECKED_EXP_CUST_P RETURN NUMBER;

  FUNCTION CP_TOTAL_AVAIL_PARTY_CUST_P RETURN NUMBER;

  FUNCTION CP_EXP_AND_UNCHECKED_P RETURN NUMBER;

  FUNCTION CP_CUSTOMER_LOW_P RETURN VARCHAR2;

  FUNCTION CP_CUSTOMER_HIGH_P RETURN VARCHAR2;

  FUNCTION CP_PROF_CLASS_LOW_P RETURN VARCHAR2;

  FUNCTION CP_PROF_CLASS_HIGH_P RETURN VARCHAR2;

  FUNCTION CP_CUST_NUM_LOW_P RETURN VARCHAR2;

  FUNCTION CP_CUST_NUM_HIGH_P RETURN VARCHAR2;

  FUNCTION CP_OPERATING_UNIT_P RETURN VARCHAR2;

  FUNCTION CP_REPORT_OPTION_P RETURN VARCHAR2;

  FUNCTION CP_HIERARCHY_NAME_P RETURN VARCHAR2;

  FUNCTION CP_PARTY_NAME_P RETURN VARCHAR2;

  FUNCTION CP_PARTY_NUMBER_P RETURN VARCHAR2;

  FUNCTION CP_CHECK_RULE_P RETURN VARCHAR2;

  FUNCTION RP_COMPANY_NAME_P RETURN VARCHAR2;

  FUNCTION M_HIERARCHYFORMATTRIGGER RETURN VARCHAR2;

  FUNCTION M_9FORMATTRIGGER RETURN NUMBER;

  FUNCTION M_6FORMATTRIGGER RETURN VARCHAR2;

  END ONT_OEXCEXP_XMLP_PKG;


/