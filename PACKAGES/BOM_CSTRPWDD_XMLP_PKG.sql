--------------------------------------------------------
--  DDL for Package BOM_CSTRPWDD_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_CSTRPWDD_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: CSTRPWDDS.pls 120.0 2007/12/24 10:15:25 dwkrishn noship $ */
  P_STRUCT_NUM VARCHAR2(15);

  P_CLASS_CODE VARCHAR2(10);

  P_ASSEMBLY_ID NUMBER;

  P_CURRENCY_CODE VARCHAR2(15);

  P_CONC_REQUEST_ID NUMBER;

  P_FLEXDATA VARCHAR2(850);

  P_ASSY_FLEX VARCHAR2(850);

  P_QUANTITY_PRECISION NUMBER;

  P_DEPARTMENT NUMBER;

  P_LINE NUMBER;

  P_TRANS_TYPE NUMBER;

  P_ACTIVITY NUMBER;

  P_DEBUG NUMBER;

  P_LIMIT_ENTITY VARCHAR2(900) := '1=1';

  P_EXCHANGE_RATE NUMBER;

  P_CURRENCY_PRECISION NUMBER;

  P_RATE_PRECISION NUMBER;

  P_COST_GROUP_ID NUMBER;

  P_COST_TYPE_ID NUMBER;

  P_PERIOD_ID NUMBER;

  P_ACCT_HI VARCHAR2(900);

  P_ACCT_LO VARCHAR2(900);

  P_WHERE_ACCT VARCHAR2(900);

  P_LIMIT_CLASSES VARCHAR2(900) := '1=1';

  P_JOB NUMBER;

  CP_RESPONSIBILITY VARCHAR2(220);

  CP_REQUEST_TIME VARCHAR2(50);

  CP_APPLICATION VARCHAR2(300);

  CP_REQUESTED_BY VARCHAR2(120);

  CP_LEGAL_ENTITY VARCHAR2(80);

  CP_COST_GROUP VARCHAR2(20);

  CP_COST_TYPE VARCHAR2(20);

  CP_WIP_ENTITY_NAME_COV VARCHAR2(300);

  CP_LINE_CODE_COV VARCHAR2(20);

  CP_TXN_TYPE_COV VARCHAR2(100);

  CP_DEPARTMENT_CODE_COV VARCHAR2(20);

  CP_ACTIVITY_COV VARCHAR2(25);

  CP_PERIOD_NAME VARCHAR2(25);

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION C_SUBTITLE_CURRENCYFORMULA RETURN VARCHAR2;

  FUNCTION C_ACCT_DESCRIPFORMULA(C_FLEXDATA IN VARCHAR2
                                ,ACCOUNT IN VARCHAR2
                                ,C_ACCT_DESCRIP IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION C_FLEX_SORTFORMULA(C_FLEXDATA IN VARCHAR2
                             ,ACCOUNT IN VARCHAR2
                             ,C_FLEX_SORT IN VARCHAR2) RETURN VARCHAR2;

  --PROCEDURE FORMAT_QUANTITY(P_PRECISION IN NUMBER);

  FUNCTION CLASS(R_CLASS IN VARCHAR2
                ,D_CLASS IN VARCHAR2) RETURN CHARACTER;

  FUNCTION C_ACCT_TOTAL_RFORMULA(C_ACCT_TOTAL IN NUMBER) RETURN NUMBER;

  FUNCTION C_JOB_TOTAL_RFORMULA(C_JOB_TOTAL IN NUMBER) RETURN NUMBER;

  FUNCTION C_EXT_COST_RFORMULA(EXTENDED_COST IN NUMBER) RETURN NUMBER;

  FUNCTION C_REPT_TOTAL_RFORMULA(C_REPT_TOTAL IN NUMBER) RETURN NUMBER;

  FUNCTION CP_RESPONSIBILITY_P RETURN VARCHAR2;

  FUNCTION CP_REQUEST_TIME_P RETURN VARCHAR2;

  FUNCTION CP_APPLICATION_P RETURN VARCHAR2;

  FUNCTION CP_REQUESTED_BY_P RETURN VARCHAR2;

  FUNCTION CP_LEGAL_ENTITY_P RETURN VARCHAR2;

  FUNCTION CP_COST_GROUP_P RETURN VARCHAR2;

  FUNCTION CP_COST_TYPE_P RETURN VARCHAR2;

  FUNCTION CP_WIP_ENTITY_NAME_COV_P RETURN VARCHAR2;

  FUNCTION CP_LINE_CODE_COV_P RETURN VARCHAR2;

  FUNCTION CP_TXN_TYPE_COV_P RETURN VARCHAR2;

  FUNCTION CP_DEPARTMENT_CODE_COV_P RETURN VARCHAR2;

  FUNCTION CP_ACTIVITY_COV_P RETURN VARCHAR2;

  FUNCTION CP_PERIOD_NAME_P RETURN VARCHAR2;

END BOM_CSTRPWDD_XMLP_PKG;


/
