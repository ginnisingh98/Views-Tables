--------------------------------------------------------
--  DDL for Package WIP_WIPREDAT_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_WIPREDAT_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: WIPREDATS.pls 120.1 2008/01/31 12:33:38 npannamp noship $ */
  P_CONC_REQUEST_ID NUMBER := 0;

  P_ORG_ID NUMBER;

  P_CMPL_LOCATOR VARCHAR2(500);

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

  P_FROM_ASSEMBLY VARCHAR2(850);

  P_TO_ASSEMBLY VARCHAR2(850);

  P_TO_LINE VARCHAR2(40);

  P_FROM_LINE VARCHAR2(40);

  P_ITEM_GRP_BY VARCHAR2(500);

  P_FROM_START_DATE DATE;

  P_TO_START_DATE DATE;

  P_QTY_PRECISION NUMBER;

  CHART_OF_ACCOUNTS_ID_DEF NUMBER;

  P_STATUS_LIMITER VARCHAR2(240);

  P_DEBUG VARCHAR2(1);

  function get_precision(qty_precision in number) return VARCHAR2;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION LINE_LIMITER RETURN CHARACTER;

  FUNCTION ASSEMBLY_LIMITER RETURN CHARACTER;

  FUNCTION FUS_DATE_LIMITER RETURN CHARACTER;

  FUNCTION C_STATUS_LIMITERFORMULA RETURN VARCHAR2;

  FUNCTION AFTERPFORM RETURN BOOLEAN;

END WIP_WIPREDAT_XMLP_PKG;


/