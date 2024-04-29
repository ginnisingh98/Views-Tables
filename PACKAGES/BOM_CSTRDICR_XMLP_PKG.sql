--------------------------------------------------------
--  DDL for Package BOM_CSTRDICR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_CSTRDICR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: CSTRDICRS.pls 120.0 2007/12/24 09:54:52 dwkrishn noship $ */
  P_ORG_ID VARCHAR2(40);
  P_STRUCT_NUM VARCHAR2(40);
  P_SELECT_ITEM VARCHAR2(850);
  P_SELECT_CAT VARCHAR2(850);
  P_WHERE_ITEM VARCHAR2(850) := '1 = 1';
  P_FROM_ITEM VARCHAR2(240);
  P_TO_ITEM VARCHAR2(240);
  P_FROM_CAT VARCHAR2(240);
  P_TO_CAT VARCHAR2(240);
  P_WHERE_CAT VARCHAR2(850) := '1 = 1';
  P_CONC_REQUEST_ID NUMBER := 0;
  P_CST_TYPE VARCHAR2(40);
  P_CATEGORY_SET NUMBER;
  REPORT_SORT_OPT NUMBER;
  SHOW_ELEM_SUM NUMBER;
  P_QTY_PRECISION NUMBER;
  P_VIEW_COST NUMBER;
  P_TRACE_FLAG NUMBER;
  FORMAT_MASK VARCHAR2(100);
  L_ITEM_FLEX_NUM number;
  FUNCTION BEFOREREPORT RETURN BOOLEAN;
  FUNCTION AFTERREPORT RETURN BOOLEAN;
  FUNCTION DISP_CURRENCYFORMULA(CURR_CODE_SAVED IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION ORDER_FUNC(C_FLEXPAD_ITEM IN VARCHAR2
                     ,C_FLEXPAD_CAT IN VARCHAR2
                     ,UOM IN VARCHAR2) RETURN CHARACTER;
  FUNCTION C_FLEXPAD_ITEMFORMULA(C_ITEM_NUM_FLEX IN VARCHAR2
                                ,C_FLEXPAD_ITEM IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION C_FLEXPAD_CATFORMULA(C_CAT_FLEX IN VARCHAR2
                               ,C_FLEXPAD_CAT IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION AFTERPFORM RETURN BOOLEAN;
END BOM_CSTRDICR_XMLP_PKG;


/