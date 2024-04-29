--------------------------------------------------------
--  DDL for Package XTR_XTRDDHTY_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XTR_XTRDDHTY_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: XTRDDHTYS.pls 120.1 2007/12/28 12:47:16 npannamp noship $ */
  P_COMPANY VARCHAR2(7);

  P_RISK_TYPE VARCHAR2(30);

  P_HEDGE_TYPE VARCHAR2(30);

  P_OBJECTIVE VARCHAR2(30);

  P_STRATEGY VARCHAR2(30);

  P_HEDGE_STATUS VARCHAR2(30);

  P_AS_OF_DATE VARCHAR2(40);
  P_AS_OF_DATE_1 VARCHAR2(40);

  REPORT_NAME VARCHAR2(300);

  P_CONC_REQUEST_ID NUMBER;

  RP_COMPANY_NAME VARCHAR2(32767);

  RP_HEDGE_STATUS VARCHAR2(80);

  RP_STRATEGY_NAME VARCHAR2(80);

  Z1AMOUNT VARCHAR2(300);

  Z1AS_OF_DATE VARCHAR2(300);

  Z1CCY VARCHAR2(300);

  Z1COMPANY VARCHAR2(300);

  Z1DER_DISCL VARCHAR2(300);

  Z1END_DATE VARCHAR2(300);

  Z1EQUI VARCHAR2(300);

  Z1FACTOR VARCHAR2(300);

  Z1HEDGE VARCHAR2(300);

  Z1HEDGE_INST VARCHAR2(300);

  Z1HEDGE_ITEM VARCHAR2(300);

  Z1HEDGE_TYPE VARCHAR2(300);

  Z1HSTGY_TOTAL VARCHAR2(300);

  Z1HTYPE_TOTAL VARCHAR2(300);

  Z1NUMBER VARCHAR2(300);

  Z1OBJECTIVE VARCHAR2(300);

  Z1OBJECTIVE_DESC VARCHAR2(300);

  Z1PARAMETERS VARCHAR2(300);

  Z1POLICY_REF VARCHAR2(300);

  Z1RISK_TYPE VARCHAR2(300);

  Z1START_DATE VARCHAR2(300);

  Z1STRATEGY VARCHAR2(300);

  Z1STRATEGY_NAME VARCHAR2(300);

  Z2END_OF_REPORT VARCHAR2(300);

  Z2HEDGE_STATUS VARCHAR2(300);

  Z2NO_DATA_FOUND VARCHAR2(300);

  Z2STRATEGY VARCHAR2(300);

  P_REPORT_CCY VARCHAR2(15);

  Z1REPORT_CCY VARCHAR2(300);

  Z2REPORT_DATE VARCHAR2(300);

  Z2PAGE VARCHAR2(300);

  P_FACTOR NUMBER;

  RP_FACTOR VARCHAR2(80);

  RP_RISK_TYPE VARCHAR2(80);

  RP_OBJECTIVE VARCHAR2(80);

  RP_HEDGE_TYPE VARCHAR2(80);

  Z1GT_SYSDATE VARCHAR2(300);

  P_UNIT NUMBER;

  P_DATE DATE;

  Z1CUR_HEDGE VARCHAR2(300);

  Z1ITEM_AMOUNT VARCHAR2(300);

  Z1INST_AMOUNT VARCHAR2(300);

  CP_NO_GL_RATE VARCHAR2(2000);

  CP_NOT_CURRENT VARCHAR2(2000);

  FUNCTION HITEM_AMTFORMULA(HEDGE_NO IN NUMBER
                           ,HEDGE_APPROACH IN VARCHAR2
                           ,HEDGE_AMOUNT IN NUMBER) RETURN NUMBER;

  FUNCTION HINST_AMTFORMULA(CHINST_AMT IN NUMBER) RETURN NUMBER;

  FUNCTION HITEM_RCCYFORMULA(COMPANY_CODE IN VARCHAR2
                            ,HEDGE_CURRENCY IN VARCHAR2
                            ,HITEM_AMT IN NUMBER) RETURN NUMBER;

  FUNCTION HINST_RCCYFORMULA(COMPANY_CODE IN VARCHAR2
                            ,HEDGE_CURRENCY IN VARCHAR2
                            ,HINST_AMT IN NUMBER) RETURN NUMBER;

  FUNCTION AFTERPFORM RETURN BOOLEAN;

  FUNCTION GET_EQU_AMT(X_COMPANY_CODE IN VARCHAR2
                      ,X_BASE_CCY IN VARCHAR2
                      ,X_BASE_AMT IN NUMBER) RETURN NUMBER;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION COMPANY_NAMEFORMULA(COMPANY_CODE IN VARCHAR2) RETURN CHAR;

  FUNCTION HEDGE_TYPE_DSPFORMULA(HEDGE_TYPE IN VARCHAR2) RETURN CHAR;

  FUNCTION OBJECTIVE_NAMEFORMULA(OBJECTIVE_CODE IN VARCHAR2) RETURN CHAR;

  FUNCTION OBJECTIVE_DESCFORMULA(OBJECTIVE_CODE IN VARCHAR2) RETURN CHAR;

  FUNCTION RISK_TYPE_DSPFORMULA(RISK_TYPE IN VARCHAR2) RETURN CHAR;

  FUNCTION STARFORMULA(HEDGE_STATUS IN VARCHAR2) RETURN CHAR;

  FUNCTION RPT_CCYFORMULA(COMPANY_CODE IN VARCHAR2) RETURN CHAR;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION CHINST_AMTFORMULA(HEDGE_NO IN NUMBER) RETURN NUMBER;

  FUNCTION CP_NO_GL_RATE_P RETURN VARCHAR2;

  FUNCTION CP_NOT_CURRENT_P RETURN VARCHAR2;


END XTR_XTRDDHTY_XMLP_PKG;


/
