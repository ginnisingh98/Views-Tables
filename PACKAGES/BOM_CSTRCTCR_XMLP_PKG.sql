--------------------------------------------------------
--  DDL for Package BOM_CSTRCTCR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_CSTRCTCR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: CSTRCTCRS.pls 120.0 2007/12/24 09:53:34 dwkrishn noship $ */
  COMPARISON_OPT NUMBER;

  COST_TYPE_ID1 NUMBER;

  COST_TYPE_ID2 NUMBER;

  ORG_ID NUMBER;

  REPORT_SORT_OPT NUMBER;

  COLUMN1 VARCHAR2(40) := 'cost_element';
--Added
  PID_FLEX_NUM NUMBER;

  QTY_PRECISION varchar2(100);

  P_FLEXDATA_ITEM VARCHAR2(850);

  P_WHERE_ITEM VARCHAR2(850) := '1 = 1';

  P_FROM_ITEM VARCHAR2(80);

  P_TO_ITEM VARCHAR2(80);

  P_FLEXDATA_CAT VARCHAR2(850);

  P_CONC_REQUEST_ID NUMBER := 0;

  P_WHERE_CAT VARCHAR2(850) := '1 = 1';

  P_FROM_CAT VARCHAR2(80);

  P_TO_CAT VARCHAR2(80);

  P_STRUCT_NUM NUMBER;

  P_CATEGORY_SET NUMBER;

  MIN_PERC_DIFF NUMBER;

  MIN_AMT_DIFF NUMBER;

  MIN_UNIT_COST NUMBER;

  P_VIEW_COST NUMBER;

  P_TRACE VARCHAR2(2);

  --P_PRECISION NUMBER;
  P_PRECISION NUMBER := 0;

  --P_EXT_PRECISION NUMBER;
  P_EXT_PRECISION NUMBER := 5;

  P_HINT VARCHAR2(200);

  P_TABLE_ORDER VARCHAR2(300) := 'mtl_categories_kfv mc, mtl_item_categories mic, cst_item_costs cic,  mtl_system_items_vl msi, cst_detail_cost_view cdcv';

  CREATE_WHERE_ITEM1 varchar2(200) := '   ';
  CREATE_WHERE_ITEM2 varchar2(200) := '   ';

  CREATE_WHERE_CAT1 varchar2(200) := '   ';
  CREATE_WHERE_CAT2 varchar2(200) := '   ';

  FUNCTION TOT_PER_CHANGEFORMULA(TOT_ITEM_COST1 IN NUMBER
                                ,TOT_ITEM_COST2 IN NUMBER
                                ,TOT_DIFFERENCE IN NUMBER) RETURN NUMBER;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION DISP_CURRENCYFORMULA(CURR_CODE_SAVED IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION MIN_PERC_DIFF_SAVEDFORMULA(EXT_PRECISION_SAVED IN VARCHAR2) RETURN NUMBER;

  FUNCTION MIN_AMT_DIFF_SAVEDFORMULA(EXT_PRECISION_SAVED IN VARCHAR2) RETURN NUMBER;

  FUNCTION MIN_UNIT_COST_SAVEDFORMULA(EXT_PRECISION_SAVED IN VARCHAR2) RETURN NUMBER;

  FUNCTION COLUMN1_TITLE_HDRFORMULA(COLUMN1_TITLE_SAVED IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION AFTERPFORM RETURN BOOLEAN;

END BOM_CSTRCTCR_XMLP_PKG;


/
