--------------------------------------------------------
--  DDL for Package PA_PAXMGTSD_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PAXMGTSD_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAXMGTSDS.pls 120.0 2008/01/02 11:38:41 krreddy noship $ */
  PROJ NUMBER;

  PA_PERIOD VARCHAR2(40);

  P_DEBUG_MODE VARCHAR2(3);

  P_CONC_REQUEST_ID NUMBER;

  P_RULE_OPTIMIZER VARCHAR2(3);

  COST_BGT_CODE VARCHAR2(30);

  REV_BGT_CODE VARCHAR2(30);

  TASK NUMBER;

  TASK_MGR NUMBER;

  TASK_ORG NUMBER;

  C_SUM_RPT_TOTALS VARCHAR2(5);

  C_COMPANY_NAME_HEADER VARCHAR2(50);

  C_NO_DATA_FOUND VARCHAR2(80);

  C_ORG VARCHAR2(60);

  C_PROJ_NUM VARCHAR2(30);

  C_PROJ_NAME VARCHAR2(30);

  C_MGR VARCHAR2(30);

  C_START_DATE VARCHAR2(20);

  C_END_DATE VARCHAR2(20);

  C_COST_BGT_NAME VARCHAR2(30);

  C_REV_BGT_NAME VARCHAR2(30);

  C_COST_BGT_CODE VARCHAR2(30);

  C_REV_BGT_CODE VARCHAR2(30);

  C_TASK_NUM VARCHAR2(30);

  C_TASK_NAME VARCHAR2(30);

  FUNCTION GET_COVER_PAGE_VALUES RETURN BOOLEAN;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION GET_COMPANY_NAME RETURN BOOLEAN;

  FUNCTION NO_DATA_FOUND_FUNC RETURN BOOLEAN;

  FUNCTION GET_PERIOD(SD IN DATE) RETURN VARCHAR2;

  FUNCTION PERIOD_NAMEFORMULA RETURN VARCHAR2;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION C_TASK_ACTUAL_COSTFORMULA RETURN NUMBER;

  FUNCTION C_ACT_PER_REVFORMULA(RESOURCE_LIST_MEMBER_ID IN NUMBER
                               ,TASK_ID3 IN NUMBER
                               ,PERIOD_NAME IN VARCHAR2
                               ,PROJECT_ID2 IN NUMBER) RETURN NUMBER;

  FUNCTION GET_PERIOD_AMT(X_TYPE IN VARCHAR2
                         ,X_RSRC_LIST_MEMBER_ID IN NUMBER
                         ,X_TASK_ID IN NUMBER
			 ,PERIOD_NAME IN VARCHAR2
			 ,PROJECT_ID2 IN NUMBER) RETURN NUMBER;

  FUNCTION C_ACT_PER_COSTFORMULA(RESOURCE_LIST_MEMBER_ID1 IN NUMBER
                                ,TASK_ID5 IN NUMBER
                                ,PERIOD_NAME IN VARCHAR2
                                ,PROJECT_ID2 IN NUMBER) RETURN NUMBER;

  FUNCTION C_ACT_PER_REV_SUMFORMULA(C_ACT_PER_REV IN NUMBER
                                   ,MEMBER_LEVEL2 IN NUMBER) RETURN NUMBER;

  FUNCTION GET_RSRC_NAME_DISP(X_ALIAS IN VARCHAR2
                             ,X_LEVEL IN NUMBER) RETURN VARCHAR2;

  FUNCTION C_ACT_PER_COST_SUMFORMULA(C_ACT_PER_COST IN NUMBER
                                    ,MEMBER_LEVEL1 IN NUMBER) RETURN NUMBER;

  FUNCTION GET_PERIOD_AMT_SUM(X_AMT IN NUMBER
                             ,X_LEVEL IN NUMBER) RETURN NUMBER;

  FUNCTION C_SUM_RPT_TOTALSFORMULA(PARENT_TASK_ID IN NUMBER) RETURN VARCHAR2;

  FUNCTION CHECK_SUM_RPT_TOTALS(PARENT_TASK_ID IN NUMBER) RETURN VARCHAR2;

  FUNCTION C_RPT_BGT_COST_SUMFORMULA(BGT_COST_SUM IN NUMBER) RETURN NUMBER;

  FUNCTION GET_REPORT_LINE_TOTAL(X_AMOUNT IN NUMBER) RETURN NUMBER;

  FUNCTION C_RPT_ACT_COST_SUMFORMULA(ACT_COST_SUM IN NUMBER) RETURN NUMBER;

  FUNCTION C_RPT_ACT_PER_COST_SUMFORMULA(C_ACT_PER_COST_SUM IN NUMBER) RETURN NUMBER;

  FUNCTION C_RPT_ACT_REV_SUMFORMULA(ACT_REV_SUM IN NUMBER) RETURN NUMBER;

  FUNCTION C_RPT_ACT_PER_REV_SUMFORMULA(C_ACT_PER_REV_SUM IN NUMBER) RETURN NUMBER;

  FUNCTION C_RPT_BGT_REV_SUMFORMULA(BGT_REV_SUM IN NUMBER) RETURN NUMBER;

  FUNCTION CF_CURRENCY_CODEFORMULA RETURN CHAR;

  FUNCTION C_COMPANY_NAME_HEADER_P RETURN VARCHAR2;

  FUNCTION C_NO_DATA_FOUND_P RETURN VARCHAR2;

  FUNCTION C_ORG_P RETURN VARCHAR2;

  FUNCTION C_PROJ_NUM_P RETURN VARCHAR2;

  FUNCTION C_PROJ_NAME_P RETURN VARCHAR2;

  FUNCTION C_MGR_P RETURN VARCHAR2;

  FUNCTION C_START_DATE_P RETURN DATE;

  FUNCTION C_END_DATE_P RETURN DATE;

  FUNCTION C_COST_BGT_NAME_P RETURN VARCHAR2;

  FUNCTION C_REV_BGT_NAME_P RETURN VARCHAR2;

  FUNCTION C_COST_BGT_CODE_P RETURN VARCHAR2;

  FUNCTION C_REV_BGT_CODE_P RETURN VARCHAR2;

  FUNCTION C_TASK_NUM_P RETURN VARCHAR2;

  FUNCTION C_TASK_NAME_P RETURN VARCHAR2;

END PA_PAXMGTSD_XMLP_PKG;

/