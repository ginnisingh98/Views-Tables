--------------------------------------------------------
--  DDL for Package XTR_XTRMTCPY_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XTR_XTRMTCPY_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: XTRMTCPYS.pls 120.1 2007/12/28 12:57:31 npannamp noship $ */
  REPORT_DATE2 DATE;
X VARCHAR2(30);
  REPORT_NOS VARCHAR2(30);
  REPORT_SHORT_NAME VARCHAR2(80);
  REPORT_GROUP VARCHAR2(32767);
  USE_DEFAULTS VARCHAR2(1);
  CPARTY_CODE VARCHAR2(7);
  COMPANY_CODE VARCHAR2(7);
  DEAL_TYPE1 VARCHAR2(7);
  DEAL_SUBTYPE VARCHAR2(7);
  PRODUCT_TYPE VARCHAR2(10);
  CURRENCY_CODE VARCHAR2(15);
  FROM_DATE DATE;
  TO_DATE1 DATE;
  AS_PRINCIPAL VARCHAR2(1);
  CLIENT_CODE VARCHAR2(7);
  Z1REPORT_NOS VARCHAR2(300);
  Z2PRODUCT VARCHAR2(300);
  Z2AMT_TYPE VARCHAR2(300);
  Z2RATE VARCHAR2(300);
  Z2CCY VARCHAR2(300);
  Z2AMOUNT VARCHAR2(300);
  Z2HCE_AMOUNT VARCHAR2(300);
  Z1PARAMETERS VARCHAR2(300);
  Z1COMPANY VARCHAR2(300);
  Z1CPARTY VARCHAR2(300);
  Z1DEAL_TYPE VARCHAR2(300);
  Z1SUBTYPE VARCHAR2(300);
  Z1CLIENT VARCHAR2(300);
  Z1CURRENCY VARCHAR2(300);
  Z1DATE_FROM VARCHAR2(300);
  Z1TO VARCHAR2(300);
  Z2VALUE_DATE VARCHAR2(300);
  Z2DEAL_REF VARCHAR2(300);
  Z2DEAL_TYPE_SUB VARCHAR2(300);
  Z2END_OF_REPORT VARCHAR2(300);
  Z2PAGE VARCHAR2(300);
  Z2REPORT VARCHAR2(300);
  Z2REQUESTED_BY VARCHAR2(300);
  P_CPARTY VARCHAR2(7);
  P_COMPANY VARCHAR2(7);
  P_DEAL_TYPE VARCHAR2(7);
  P_DEAL_SUBTYPE VARCHAR2(7);
  P_PRODUCT_TYPE VARCHAR2(10);
  P_CURRENCY VARCHAR2(15);
  P_PERIOD_FROM VARCHAR2(32767);
  P_PERIOD_TO VARCHAR2(32767);
  P_AS_PRINCIPAL VARCHAR2(1);
  P_CLIENT VARCHAR2(7);
  P_PORTFOLIO VARCHAR2(32767);
  CPARTY_CODE2 VARCHAR2(7);
  DEAL_TYPE2 VARCHAR2(7);
  DEAL_SUBTYPE2 VARCHAR2(7);
  PRODUCT_TYPE2 VARCHAR2(10);
  CURRENCY2 VARCHAR2(15);
  FROM_DATE2 VARCHAR2(32767);
  TO_DATE2 VARCHAR2(32767);
  AS_PRINCIPAL2 VARCHAR2(1);
  CLIENT_CODE2 VARCHAR2(7);
  COMPANY_CODE2 VARCHAR2(7);
  REPORT_SHORT_NAME2 VARCHAR2(240);
  P_CONC_REQUEST_ID NUMBER;
  COMPANY_NAME_HEADER VARCHAR2(70);
  P_SQL_TRACE VARCHAR2(32767);
  P_DISPLAY_DEBUG VARCHAR2(32767);
  REPORT_DATE VARCHAR2(100);
  Z1AS_PRINCIPAL VARCHAR2(300);
  Z1PRODUCT_TYPE VARCHAR2(300);
  P_FACTOR VARCHAR2(10);
  AMT_UNIT2 NUMBER;
  LP_FACTOR_DESC VARCHAR2(32767);
  Z1P_FACTOR VARCHAR2(300);
  Z1PORTFOLIO VARCHAR2(300);
  PORTFOLIO VARCHAR2(32767);
  PORTFOLIO2 VARCHAR2(32767);
  COMPANY_NAME VARCHAR2(256);
  CPARTY_NAME VARCHAR2(256);
  CP_PARA VARCHAR2(30);
  --added
  P_PERIOD_FROM1 VARCHAR2(30);
  P_PERIOD_TO1 VARCHAR2(30);
  --FUNCTION CPARTY_NAME1FORMULA RETURN VARCHAR2;
  FUNCTION CPARTY_NAME1FORMULA(CPARTY varchar2) RETURN VARCHAR2;
  FUNCTION CPARTY_NAMEFORMULA RETURN VARCHAR2;
  FUNCTION COMPANY_NAME1FORMULA(COMPANY varchar2) RETURN VARCHAR2;
  FUNCTION COMPANY_NAMEFORMULA RETURN VARCHAR2;
  FUNCTION CF_SET_PARAFORMULA RETURN VARCHAR2;
  FUNCTION BEFOREREPORT RETURN BOOLEAN;
  FUNCTION AFTERREPORT RETURN BOOLEAN;
  FUNCTION AFTERPFORM RETURN BOOLEAN;
  FUNCTION COMPANY_NAME_P RETURN VARCHAR2;
  FUNCTION CPARTY_NAME_P RETURN VARCHAR2;
  FUNCTION CP_PARA_P RETURN VARCHAR2;
END XTR_XTRMTCPY_XMLP_PKG;


/
