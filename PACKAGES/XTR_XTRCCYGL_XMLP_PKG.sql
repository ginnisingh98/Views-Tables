--------------------------------------------------------
--  DDL for Package XTR_XTRCCYGL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XTR_XTRCCYGL_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: XTRCCYGLS.pls 120.1 2007/12/28 12:43:17 npannamp noship $ */
  P_GROUPBY VARCHAR2(40);

  P_REALIZED_FLAG VARCHAR2(40);
  P_REALIZED_FLAG_T VARCHAR2(40);
  P_BATCH_ID_FROM NUMBER;

  P_BATCH_ID_TO NUMBER;

  P_DATE_FROM VARCHAR2(32767);
  P_DATE_FROM_T VARCHAR2(32767);
  P_DATE_TO VARCHAR2(32767);
  P_DATE_TO_T VARCHAR2(32767);
  P_CURRENCY VARCHAR2(40);

  P_DEAL_TYPE VARCHAR2(40);

  P_PORTFOLIO VARCHAR2(40);

  P_COMPANY VARCHAR2(40);

  P_CONC_REQUEST_ID NUMBER;

  P_SQL_TRACE NUMBER;

  Z2COMPANY VARCHAR2(300);

  Z2PORTFOLIO VARCHAR2(300);

  Z2DEAL_TYPE VARCHAR2(300);

  Z2DEAL_SUBTYPE VARCHAR2(300);

  Z2PRODUCT_TYPE VARCHAR2(300);

  Z2REFERENCE VARCHAR2(300);

  Z2PRDEND VARCHAR2(300);

  Z2BUY VARCHAR2(300);

  Z2SELL VARCHAR2(300);

  Z2REPORT_PRD VARCHAR2(300);

  Z2REVAL_CCY VARCHAR2(300);

  Z2CCY VARCHAR2(300);

  Z2AMOUNT VARCHAR2(300);

  Z2TRANS VARCHAR2(300);

  Z2BEGIN VARCHAR2(300);

  Z2END VARCHAR2(300);

  Z2TOTAL VARCHAR2(300);

  Z2FAIR_VALUE VARCHAR2(300);

  Z2GAIN_LOSS VARCHAR2(300);

  P_FACTOR VARCHAR2(32767);

  P_UNIT NUMBER := 1;

  P_PRODUCT_TYPE VARCHAR2(40);

  Z2REALIZED_FLAG VARCHAR2(300);

  Z2END_OF_REPORT VARCHAR2(300);

  Z2NO_DATA_FOUND VARCHAR2(300);

  Z1FACTOR VARCHAR2(300);

  Z1REAL_UNREAL VARCHAR2(300);

  Z1DATE_FROM VARCHAR2(300);

  Z1DATE_TO VARCHAR2(300);

  Z1BATCH_ID_FROM VARCHAR2(300);

  Z1BATCH_ID_TO VARCHAR2(300);

  Z1PARA_GROUPING VARCHAR2(500);

  P_USER_DEAL_TYPE VARCHAR2(30);

  P_USER_DEAL_SUBTYPE VARCHAR2(30);

  P_USER_COMPANY VARCHAR2(30);

  P_USER_FACTOR VARCHAR2(32767);

  P_USER_GROUPBY VARCHAR2(50);

  Z2START VARCHAR2(300);

  Z2GL_RATE VARCHAR2(300);

  Z2SOB_CCY VARCHAR2(300);

  P_USER_DATE_FROM VARCHAR2(32767);

  P_USER_DATE_TO VARCHAR2(32767);

  Z2CCY_SHT VARCHAR2(80);

  Z2PERIOD VARCHAR2(300);

  Z1REPHEAD_REAL VARCHAR2(1000);

  Z1REPHEAD_UNREAL VARCHAR2(1000);

  FUNCTION AFTERPFORM RETURN BOOLEAN;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION C_DATEFORMATFORMULA(C_DATEFORMAT IN VARCHAR2) RETURN CHAR;

  FUNCTION CO_SHT_NAMEFORMULA(COMPANY IN VARCHAR2) RETURN CHAR;

  FUNCTION C_REPORT_NAMEFORMULA RETURN CHAR;

  FUNCTION USER_DEAL_SUBTYPEFORMULA(DEAL_SUBTYPE_P IN VARCHAR2
                                   ,DEAL_TYPE_P IN VARCHAR2) RETURN CHAR;

  FUNCTION USER_DEAL_TYPEFORMULA(DEAL_TYPE_P IN VARCHAR2) RETURN CHAR;

  FUNCTION FAIR_VALUEFORMULA(COMPANY_P IN VARCHAR2
                            ,REF_NUMBER_P IN VARCHAR2
                            ,PERIOD_END_P IN DATE
                            ,BATCH_ID_P IN NUMBER
                            ,DEAL_TYPE IN VARCHAR2) RETURN NUMBER;

  FUNCTION BEGIN_RATEFORMULA(COMPANY IN VARCHAR2
                            ,REF_NUMBER_p IN VARCHAR2
                            ,PERIOD_START_P IN DATE
                            ,DEAL_TYPE IN VARCHAR2) RETURN NUMBER;

  FUNCTION END_RATEFORMULA(COMPANY_P IN VARCHAR2
                          ,REF_NUMBER_p IN VARCHAR2
                          ,PERIOD_END_p IN DATE
                          ,DEAL_TYPE IN VARCHAR2) RETURN NUMBER;

  FUNCTION REPORT_PRDFORMULA(C_DATEFORMAT IN VARCHAR2) RETURN CHAR;

  FUNCTION SOB_CCYFORMULA(COMPANY IN VARCHAR2) RETURN CHAR;

  FUNCTION FAIR_VALUE_RNDFORMULA(REVAL_CCY IN VARCHAR2
                                ,FAIR_VALUE IN NUMBER) RETURN NUMBER;

  FUNCTION GAIN_LOSS_RNDFORMULA(REVAL_CCY IN VARCHAR2
                               ,GAIN_LOSS IN NUMBER) RETURN NUMBER;

  FUNCTION BASE_AMT_RNDFORMULA(REVAL_CCY IN VARCHAR2
                              ,BASE_AMOUNT IN NUMBER) RETURN NUMBER;

END XTR_XTRCCYGL_XMLP_PKG;


/
