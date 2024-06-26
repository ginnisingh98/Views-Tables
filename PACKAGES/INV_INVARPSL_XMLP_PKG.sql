--------------------------------------------------------
--  DDL for Package INV_INVARPSL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_INVARPSL_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: INVARPSLS.pls 120.1 2007/12/25 10:09:30 dwkrishn noship $ */
  P_ORG_ID NUMBER;

  P_CONC_REQUEST_ID NUMBER := 0;

  P_STRUCT_NUM NUMBER;

  P_CAT_STRUCT_NUM NUMBER := 101;

  P_ITEM_FLEX VARCHAR2(800);

  P_CAT_FLEX VARCHAR2(800);

  P_CATEGORY_SET_ID NUMBER;

  P_LOC_FLEX VARCHAR2(800);

  P_CONDITION VARCHAR2(40) :='and 1=1';

  P_SORT_OPTION NUMBER;

  P_ORDER_ITEM VARCHAR2(300);

  P_ORDER_CAT VARCHAR2(300);

  P_PHYS_INV_ID NUMBER;

  P_QTY_PRECISION NUMBER;

  P_CBO_FLAG NUMBER;

  P_TRACE_FLAG NUMBER;

  P_WMS_INSTALLED VARCHAR2(32767) := 'FALSE';

  FUNCTION C_TOTAL_VALUEFORMULA(QUANTITY IN NUMBER
                               ,COST IN NUMBER
                               ,C_STD_PREC IN NUMBER) RETURN NUMBER;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION C_ORDER_BYFORMULA RETURN VARCHAR2;

  FUNCTION C_CAT_SET_NAMEFORMULA RETURN VARCHAR2;

  FUNCTION C_PHYS_INV_NAMEFORMULA RETURN VARCHAR2;

  FUNCTION C_CURRENCY_CODEFORMULA(R_CURRENCY_CODE IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION AFTERPFORM RETURN BOOLEAN;

  FUNCTION GET_P_STRUCT_NUM RETURN BOOLEAN;

  FUNCTION CF_OUTERMOST_LPNFORMULA(OUTERMOST_LPN_ID IN NUMBER) RETURN CHAR;

  FUNCTION CF_PARENT_LPNFORMULA(PARENT_LPN_ID IN NUMBER) RETURN CHAR;

  FUNCTION CF_COST_GROUPFORMULA(COST_GROUP_ID IN NUMBER) RETURN CHAR;

END INV_INVARPSL_XMLP_PKG;


/
