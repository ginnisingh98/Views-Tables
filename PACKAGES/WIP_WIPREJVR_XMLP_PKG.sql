--------------------------------------------------------
--  DDL for Package WIP_WIPREJVR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_WIPREJVR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: WIPREJVRS.pls 120.1 2008/01/31 12:37:11 npannamp noship $ */
  REPORT_SORT_OPT NUMBER;

  ORG_ID NUMBER;

  P_CONC_REQUEST_ID NUMBER := 0;

  P_FLEXDATA_ITEM VARCHAR2(850);

  P_WHERE_ITEM VARCHAR2(850) := '1 = 1';

  P_FROM_ITEM VARCHAR2(80);

  P_TO_ITEM VARCHAR2(80);

  JOB_FROM VARCHAR2(80);

  JOB_TO VARCHAR2(80);

  CLASS_FROM VARCHAR2(80);
  p_item_flex_num number;

  CLASS_TO VARCHAR2(80);

  REPORT_RUN_OPT NUMBER;

  GROUP_ID NUMBER;

  P_FLEXDATA_ACCT VARCHAR2(850);

  STATUS_TYPE NUMBER;

  P_ORDER_FLEX VARCHAR2(850);

  P_QTY_PRECISION NUMBER;

  SUBMITTED_BY VARCHAR2(4);

  PER_START_DATE DATE;

  PER_SCHD_CLS_DATE DATE;

  LPER_START_DATE varchar2(12);

  LPER_SCHD_CLS_DATE varchar2(12);

  P_STRUCT_NUM NUMBER;

  P_DEBUG NUMBER;

  P_OUTER VARCHAR2(32767) := '(+)';

  P_SUBSELECT VARCHAR2(1000);

  ORG_NAME VARCHAR2(240);

  PRECISION NUMBER := 0;

  EXT_PRECISION NUMBER := 0;

  CURRENCY_CODE VARCHAR2(15) := 'USD';

  REPORT_OPTION VARCHAR2(80);

  STATUS_TYPE_NAME VARCHAR2(80);

  REPORT_SORT_BY_AFT VARCHAR2(80) := ', ml_class_type.meaning';

  CLASS_TYPE_NAME VARCHAR2(80);

  WHERE_JOB VARCHAR2(240) := '1 = 1';

  REPORT_SORT_BY_BEF VARCHAR2(80) := 'wp.wip_entity_name,';

  WHERE_CLASS VARCHAR2(80) := '1 = 1';

  REPORT_SORT VARCHAR2(80);

  FUNCTION DISP_CURRENCYFORMULA RETURN VARCHAR2;

  FUNCTION ORG_NAME_HDRFORMULA RETURN VARCHAR2;

  FUNCTION TOT_CST_INC_APP_CSTFORMULA(TOT_ACT_ISS_STD IN NUMBER
                                     ,TOT_RES_APP_COST IN NUMBER
                                     ,TOT_RES_OVR_APP_COST IN NUMBER
                                     ,TOT_MV_OVR_APP_COST IN NUMBER) RETURN NUMBER;

  FUNCTION TOT_JOB_BALANCE_CSTFORMULA(TOT_CST_INC_APP_CST IN NUMBER
                                     ,TOT_SCP_AND_COMP_CST IN NUMBER
                                     ,TOT_CLOSE_TRX_CST IN NUMBER) RETURN NUMBER;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION AFTERPFORM RETURN BOOLEAN;

  FUNCTION ORG_NAME_P RETURN VARCHAR2;

  FUNCTION PRECISION_P RETURN NUMBER;

  FUNCTION EXT_PRECISION_P RETURN NUMBER;

  FUNCTION CURRENCY_CODE_P RETURN VARCHAR2;

  FUNCTION REPORT_OPTION_P RETURN VARCHAR2;

  FUNCTION STATUS_TYPE_NAME_P RETURN VARCHAR2;

  FUNCTION REPORT_SORT_BY_AFT_P RETURN VARCHAR2;

  FUNCTION CLASS_TYPE_NAME_P RETURN VARCHAR2;

  FUNCTION WHERE_JOB_P RETURN VARCHAR2;

  FUNCTION REPORT_SORT_BY_BEF_P RETURN VARCHAR2;

  FUNCTION WHERE_CLASS_P RETURN VARCHAR2;

  FUNCTION REPORT_SORT_P RETURN VARCHAR2;

END WIP_WIPREJVR_XMLP_PKG;


/