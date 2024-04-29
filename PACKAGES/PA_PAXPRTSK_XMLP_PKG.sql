--------------------------------------------------------
--  DDL for Package PA_PAXPRTSK_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PAXPRTSK_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAXPRTSKS.pls 120.0 2008/01/02 11:52:32 krreddy noship $ */
  DISPLAY_SUBTASKS VARCHAR2(1);

  C_DISPLAY_SUBTASKS VARCHAR2(1);

  TOP_TASK_ID NUMBER;

  C_TOP_TASK_ID NUMBER;

  DISPLAY_SUBTASK_DETAILS VARCHAR2(1);

  C_DISPLAY_SUBTASK_DETAILS VARCHAR2(1);



  PROJ NUMBER;

  P_CONC_REQUEST_ID NUMBER;

  P_DEBUG_MODE VARCHAR2(3);

  P_RULE_OPTIMIZER VARCHAR2(3);

  P_COSTING VARCHAR2(3);

  C_COMPANY_NAME_HEADER VARCHAR2(50);

  C_PROJECT_NAME VARCHAR2(30);

  C_PROJECT_NUMBER VARCHAR2(30);

  C_NO_DATA_FOUND VARCHAR2(80);

  C_TASK_ID NUMBER;

  C_TASK_NAME VARCHAR2(30);

  C_TASK_NUMBER VARCHAR2(30);

  C_DISPLAY_ST_DET VARCHAR2(40);

  C_DISPLAY_SUB VARCHAR2(40);

  FUNCTION GET_COVER_PAGE_VALUES RETURN BOOLEAN;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION GET_COMPANY_NAME RETURN BOOLEAN;

  FUNCTION NO_DATA_FOUND_FUNC RETURN BOOLEAN;

  FUNCTION G_PARENTGROUPFILTER RETURN BOOLEAN;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION G_SUBTASK_DETAILGROUPFILTER(DIRECT IN VARCHAR2) RETURN BOOLEAN;

  FUNCTION G_JOB_BILL_RATESGROUPFILTER(DIRECT IN VARCHAR2) RETURN BOOLEAN;

  FUNCTION G_JOB_TITLE_ORGROUPFILTER(DIRECT IN VARCHAR2) RETURN BOOLEAN;

  FUNCTION G_JOB_ASSGN_ORGROUPFILTER(DIRECT IN VARCHAR2) RETURN BOOLEAN;

  FUNCTION G_LABOR_MULTGROUPFILTER(DIRECT IN VARCHAR2) RETURN BOOLEAN;

  FUNCTION G_NL_BILL_RATESGROUPFILTER(DIRECT IN VARCHAR2) RETURN BOOLEAN;

  FUNCTION G_EMP_BILL_RATESGROUPFILTER(DIRECT IN VARCHAR2) RETURN BOOLEAN;

  FUNCTION CF_JOB_REASONFORMULA(JOB_DISC_REASON IN VARCHAR2) RETURN CHAR;

  FUNCTION CF_NL_REASONFORMULA(NL_DISC_REASON IN VARCHAR2) RETURN CHAR;

  FUNCTION CF_EMP_REASONFORMULA(RATE_DISC_REASON_CODE IN VARCHAR2) RETURN CHAR;

  FUNCTION CF_REVENUE_ACCRUAL_MTHFORMULA(REVENUE_ACCRUAL_METHOD IN VARCHAR2
                                        ,PROJECT_ID1 IN NUMBER) RETURN CHAR;

  FUNCTION CF_INV_MTHFORMULA(INVOICE_METHOD IN VARCHAR2
                            ,PROJECT_ID1 IN NUMBER) RETURN CHAR;

  FUNCTION CF_CUSTOMER_NUMBERFORMULA(CUSTOMER_ID1 IN NUMBER
                                    ,PROJECT_ID1 IN NUMBER) RETURN CHAR;

  FUNCTION CF_CUSTOMER_NAMEFORMULA(CUSTOMER_ID1 IN NUMBER
                                  ,PROJECT_ID1 IN NUMBER) RETURN CHAR;

  FUNCTION C_COMPANY_NAME_HEADER_P RETURN VARCHAR2;

  FUNCTION C_PROJECT_NAME_P RETURN VARCHAR2;

  FUNCTION C_PROJECT_NUMBER_P RETURN VARCHAR2;

  FUNCTION C_NO_DATA_FOUND_P RETURN VARCHAR2;

  FUNCTION C_TASK_ID_P RETURN NUMBER;

  FUNCTION C_TASK_NAME_P RETURN VARCHAR2;

  FUNCTION C_TASK_NUMBER_P RETURN VARCHAR2;

  FUNCTION C_DISPLAY_ST_DET_P RETURN VARCHAR2;

  FUNCTION C_DISPLAY_SUB_P RETURN VARCHAR2;

  FUNCTION GET_CURRENCY_CODE RETURN VARCHAR2;

  FUNCTION ROUND_CURRENCY_AMT(X_AMOUNT IN NUMBER) RETURN NUMBER;

  FUNCTION CURRENCY_FMT_MASK(X_LENGTH IN NUMBER) RETURN VARCHAR2;

  FUNCTION RPT_CURRENCY_FMT_MASK(X_ORG_ID IN NUMBER
                                ,X_LENGTH IN NUMBER) RETURN VARCHAR2;

END PA_PAXPRTSK_XMLP_PKG;

/