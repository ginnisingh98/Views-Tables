--------------------------------------------------------
--  DDL for Package PA_PAXACMPT_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PAXACMPT_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAXACMPTS.pls 120.0 2008/01/02 11:11:33 krreddy noship $ */
  P_RULE_OPTIMIZER VARCHAR2(3);

  P_DEBUG_MODE VARCHAR2(3);

  P_CONC_REQUEST_ID NUMBER;

  P_PROJECT_NUM_FROM VARCHAR2(25);

  P_PROJECT_NUM_TO VARCHAR2(25);

  P_MODE VARCHAR2(1);

  P_ACTUAL_COST_FLAG VARCHAR2(1);

  P_SYSTEM_LINKAGE_FUNCTION VARCHAR2(30);

  P_REVENUE_FLAG VARCHAR2(1);

  P_BUDGETS_FLAG VARCHAR2(1);

  P_BUDGET_TYPE_CODE VARCHAR2(30);

  P_COMMITMENT_FLAG VARCHAR2(1);

  P_BILLABLE VARCHAR2(8);

  P_CAPITAL VARCHAR2(13);

  P_GROUP_ID NUMBER;

  P_SUMM_CONTEXT VARCHAR2(25);

  P_DELETE_TMP_TABLE VARCHAR2(1);

  P_GEN_REP VARCHAR2(1);

  P_THROUGH_DATE DATE;

  P_PROJECT_TYPE VARCHAR2(32767);

  C_COMPANY_NAME_HEADER VARCHAR2(50);

  C_NO_DATA_FOUND VARCHAR2(80);

  C_DUMMY_DATA NUMBER;

  C_RETCODE NUMBER;

  C_ACTUAL_COST_FLAG VARCHAR2(32767);

  C_REVENUE_FLAG VARCHAR2(32767);

  C_BUDGETS_FLAG VARCHAR2(32767);

  C_COMMITMENT_FLAG VARCHAR2(32767);

  CP_ROUND_CURRENCY NUMBER;

  FUNCTION GET_COVER_PAGE_VALUES RETURN BOOLEAN;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION GET_COMPANY_NAME RETURN BOOLEAN;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION FMT(NUMBER_IN IN NUMBER) RETURN VARCHAR2;

  FUNCTION GET_PARAMETER_VALUES RETURN BOOLEAN;

  FUNCTION CF_BORCFORMULA(PROJECT_TYPE_CLASS_CODE IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION C_FMT_MASKFORMULA RETURN VARCHAR2;

  FUNCTION CF_EXCEPTION_MSGFORMULA(SUM_EXCEPTION_CODE IN VARCHAR2) RETURN CHAR;

  FUNCTION CF_LINE_EXCEPTIONFORMULA(CMT_REJECTION_CODE IN VARCHAR2) RETURN CHAR;

  FUNCTION C_GEN_REPFORMULA RETURN CHAR;

  FUNCTION C_COMPANY_NAME_HEADER_P RETURN VARCHAR2;

  FUNCTION C_NO_DATA_FOUND_P RETURN VARCHAR2;

  FUNCTION C_DUMMY_DATA_P RETURN NUMBER;

  FUNCTION C_RETCODE_P RETURN NUMBER;

  FUNCTION C_ACTUAL_COST_FLAG_P RETURN VARCHAR2;

  FUNCTION C_REVENUE_FLAG_P RETURN VARCHAR2;

  FUNCTION C_BUDGETS_FLAG_P RETURN VARCHAR2;

  FUNCTION C_COMMITMENT_FLAG_P RETURN VARCHAR2;

  FUNCTION CP_ROUND_CURRENCY_P RETURN NUMBER;

END PA_PAXACMPT_XMLP_PKG;

/