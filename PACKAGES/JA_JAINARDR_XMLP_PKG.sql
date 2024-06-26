--------------------------------------------------------
--  DDL for Package JA_JAINARDR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JA_JAINARDR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: JAINARDRS.pls 120.1 2007/12/25 16:12:29 dwkrishn noship $ */
  P_ORG_ID NUMBER;
  P_CUSTOMER_ID NUMBER;
  P_CUSTOMER_TYPE VARCHAR2(30);
  P_START_DATE DATE;
  P_END_DATE DATE;
  P_START_DATE1 VARCHAR2(30);
  P_END_DATE1 VARCHAR2(30);
  P_COLUMN_VALUE VARCHAR2(30);
  P_CHART_OF_ACCOUNTS_ID NUMBER;
  P_CUSTOMER_ID2 NUMBER;
  P_CONC_REQUEST_ID NUMBER;
  OP_TOT_CR NUMBER := 0;
  CL_TOT_CR NUMBER := 0;
  TRAN_OPEN_BAL_CR NUMBER;
  FUNC_OPEN_BAL_DR NUMBER := 0;
  FUNC_OPEN_BAL_CR NUMBER;
  CP_EXCISE_INV_NO VARCHAR2(20);
  TRAN_CR_AMT NUMBER;
  FUNC_DR_AMT NUMBER;
  FUNC_CR_AMT NUMBER;
  TRAN_CLOSING_BAL_CR NUMBER := 0;
  FUNC_CLOSING_BAL_DR NUMBER := 0;
  FUNC_CLOSING_BAL_CR NUMBER;
  ADD1 VARCHAR2(60);
  ADD2 VARCHAR2(60);
  ADD3 VARCHAR2(60);
  COUNTRY VARCHAR2(60);
  LOC_NAME VARCHAR2(60);
  FUNCTION BEFOREPFORM RETURN BOOLEAN;
  FUNCTION OPEN_BAL_TRFORMULA(CUSTOMER_ID IN NUMBER
                             ,CURR_CODE IN VARCHAR2) RETURN NUMBER;
  FUNCTION FUNC_OPEN_BALFORMULA RETURN NUMBER;
  FUNCTION CF_1FORMULA(CUSTOMER_ID2 IN NUMBER
                      ,CURR_CODE1 IN VARCHAR2) RETURN NUMBER;
  FUNCTION CF_1FORMULA0031(CUSTOMER_TRX_ID_1 IN NUMBER) RETURN CHAR;
  FUNCTION ACCOUNT_CODEFORMULA(ACCOUNT_ID IN NUMBER) RETURN CHAR;
  FUNCTION CF_1FORMULA0034(CUSTOMER_ID IN NUMBER) RETURN CHAR;
  FUNCTION CF_1FORMULA0037(TYPE IN VARCHAR2
                          ,AMOUNT IN NUMBER
                          ,AMOUNT_OTHER_CURRENCY IN NUMBER
                          ,REMARKS IN VARCHAR2) RETURN NUMBER;
  FUNCTION CF_1FORMULA0040 RETURN CHAR;
  FUNCTION DESCRIPTIONFORMULA(ACCOUNT_ID IN NUMBER) RETURN CHAR;
  FUNCTION CF_1FORMULA0038(FUNC_OP_BAL_TOT_DR IN NUMBER
                          ,FUNC_OP_BAL_TOT_CR IN NUMBER) RETURN NUMBER;
  FUNCTION CL_TOT_DRFORMULA(FUNC_CL_BAL_DR IN NUMBER
                           ,FUNC_CL_BAL_CR IN NUMBER) RETURN NUMBER;
  FUNCTION CF_1FORMULA0057(CS_1 IN NUMBER
                          ,CS_2 IN NUMBER) RETURN NUMBER;
  FUNCTION CF_EXCISE_INVFORMULA(CUSTOMER_TRX_ID_1 IN NUMBER) RETURN NUMBER;
  FUNCTION BEFOREREPORT RETURN BOOLEAN;
  FUNCTION AFTERREPORT RETURN BOOLEAN;
  FUNCTION OP_TOT_CR_P RETURN NUMBER;
  FUNCTION CL_TOT_CR_P RETURN NUMBER;
  FUNCTION TRAN_OPEN_BAL_CR_P RETURN NUMBER;
  FUNCTION FUNC_OPEN_BAL_DR_P RETURN NUMBER;
  FUNCTION FUNC_OPEN_BAL_CR_P RETURN NUMBER;
  FUNCTION CP_EXCISE_INV_NO_P RETURN VARCHAR2;
  FUNCTION TRAN_CR_AMT_P RETURN NUMBER;
  FUNCTION FUNC_DR_AMT_P RETURN NUMBER;
  FUNCTION FUNC_CR_AMT_P RETURN NUMBER;
  FUNCTION TRAN_CLOSING_BAL_CR_P RETURN NUMBER;
  FUNCTION FUNC_CLOSING_BAL_DR_P RETURN NUMBER;
  FUNCTION FUNC_CLOSING_BAL_CR_P RETURN NUMBER;
  FUNCTION ADD1_P RETURN VARCHAR2;
  FUNCTION ADD2_P RETURN VARCHAR2;
  FUNCTION ADD3_P RETURN VARCHAR2;
  FUNCTION COUNTRY_P RETURN VARCHAR2;
  FUNCTION LOC_NAME_P RETURN VARCHAR2;
  V_LAST_PAGE VARCHAR2(1) := 'F';
  LAST_PAGE NUMBER := 0;
  VALIDATION_FLAG VARCHAR2(1) := 'N';
  PREV_PAGE NUMBER := 0;
  LV_INV_CLASS CONSTANT AR_PAYMENT_SCHEDULES_ALL.CLASS%TYPE DEFAULT 'INV';
  LV_DM_CLASS CONSTANT AR_PAYMENT_SCHEDULES_ALL.CLASS%TYPE DEFAULT 'DM';
  LV_CM_CLASS CONSTANT AR_PAYMENT_SCHEDULES_ALL.CLASS%TYPE DEFAULT 'CM';
  LV_DEP_CLASS CONSTANT AR_PAYMENT_SCHEDULES_ALL.CLASS%TYPE DEFAULT 'DEP';
  LV_REC_ACCOUNT_CLASS CONSTANT RA_CUST_TRX_LINE_GL_DIST_ALL.ACCOUNT_CLASS%TYPE DEFAULT 'REC';
  LV_REV_STATUS CONSTANT AR_CASH_RECEIPT_HISTORY_ALL.STATUS%TYPE DEFAULT 'REVERSED';
  LV_ACT_STATUS CONSTANT AR_CASH_RECEIPT_HISTORY_ALL.STATUS%TYPE DEFAULT 'ACTIVITY';
  LV_LOSS_SOURCE_TYPE CONSTANT AR_DISTRIBUTIONS_ALL.SOURCE_TYPE%TYPE DEFAULT 'EXCH_LOSS';
  LV_GAIN_SOURCE_TYPE CONSTANT AR_DISTRIBUTIONS_ALL.SOURCE_TYPE%TYPE DEFAULT 'EXCH_GAIN';
END JA_JAINARDR_XMLP_PKG;



/
