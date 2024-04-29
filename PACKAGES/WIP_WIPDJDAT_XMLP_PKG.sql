--------------------------------------------------------
--  DDL for Package WIP_WIPDJDAT_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_WIPDJDAT_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: WIPDJDATS.pls 120.1 2008/01/31 12:13:05 npannamp noship $ */
  P_CONC_REQUEST_ID NUMBER := 0;

  P_ORG_ID NUMBER;

  P_ASSEMBLY VARCHAR2(2000);

  P_CMPL_LOCATOR VARCHAR2(500);

  P_BILL_REF VARCHAR2(500);

  p_item_flex_num number;

  P_ROUTING_REF VARCHAR2(500);

  P_MTL_VAL_ACCT VARCHAR2(700);

  P_MTL_OH_VAL_ACCT VARCHAR2(700);

  P_RES_VAL_ACCT VARCHAR2(700);

  P_OUT_PROC_VAL_ACCT VARCHAR2(700);

  P_OH_VAL_ACCT VARCHAR2(700);

  P_MTL_VARIANCE VARCHAR2(700);

  P_STD_COST_VARIANCE VARCHAR2(700);

  P_RES_VARIANCE VARCHAR2(700);

  P_OUT_PROC_VARIANCE VARCHAR2(700);

  P_OH_VARIANCE VARCHAR2(700);

  P_COMPONENT_ITEM VARCHAR2(500);

  P_SUPPLY_LOCATOR VARCHAR2(500);

  P_SALES_ORDER VARCHAR2(500);

  P_ITEM_GRP_BY VARCHAR2(300);

  P_FROM_JOB VARCHAR2(240);

  P_TO_JOB VARCHAR2(240);

  P_FROM_ASSEMBLY VARCHAR2(850);

  P_TO_ASSEMBLY VARCHAR2(850);

  P_FROM_START_DATE DATE;

  P_TO_START_DATE DATE;

  P_STATUS_LIMITER NUMBER;

  P_CLASS_LIMITER VARCHAR2(10);

  P_SO_ORDER_BY VARCHAR2(300);

  P_ITEM_WHERE VARCHAR2(10300);

  P_QTY_PRECISION NUMBER;

  CHART_OF_ACCOUNTS_ID_DEF NUMBER;

  P_DEBUG NUMBER;

  P_OUTER VARCHAR2(32767) := '(+)';

  P_SCHEDULE_GROUP_FROM VARCHAR2(30);

  P_SCHEDULE_GROUP_TO VARCHAR2(30);

  P_SORT_BY NUMBER;

  P_SG_OUTER VARCHAR2(5) := '(+)';

  P_OE_ONT_INSTALLED VARCHAR2(3) := 'OE';

  P_FND_ATTACHMENTS VARCHAR2(2000);

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION JOB_LIMITER RETURN CHARACTER;

  FUNCTION DATE_LIMITER RETURN CHARACTER;

  FUNCTION C_ASSEMBLY_LIMITERFORMULA RETURN VARCHAR2;

  FUNCTION AFTERPFORM RETURN BOOLEAN;

  FUNCTION C_ORDER_BYFORMULA RETURN VARCHAR2;

  FUNCTION C_LIMITER RETURN VARCHAR2;

END WIP_WIPDJDAT_XMLP_PKG;


/
