--------------------------------------------------------
--  DDL for Package BOM_CSTRLIVR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_CSTRLIVR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: CSTRLIVRS.pls 120.0 2007/12/24 10:06:45 dwkrishn noship $ */
  P_ORG_ID NUMBER;

  P_COST_GROUP_OPTION_ID NUMBER;

  P_COST_GROUP_ID NUMBER;

  P_SORT_OPTION NUMBER;

  P_ITEM_FROM VARCHAR2(800);

  P_ITEM_TO VARCHAR2(800);

  P_CATEGORY_SET NUMBER;

  P_CAT_NUM NUMBER;

  P_CAT_FROM VARCHAR2(800);

  P_CAT_TO VARCHAR2(800);

  P_CURRENCY_CODE VARCHAR2(15);

  P_EXCHANGE_RATE_CHAR NUMBER;

  P_QTY_PRECISION NUMBER;

  P_TRACE VARCHAR2(1);

  PV_ORGANIZATION_NAME VARCHAR2(240);

  PV_SORT_OPTION VARCHAR2(80);

  PV_CATEGORY_SET_NAME VARCHAR2(30);

  PV_CURRENCY_CODE VARCHAR2(50);

  PV_EXCHANGE_RATE NUMBER := 1;

  PV_COST_GROUP_OPTION VARCHAR2(80);

  PV_SPECIFIC_COST_GROUP VARCHAR2(32767);

  P_CONC_REQUEST_ID NUMBER := 0;

  P_CAT_SEG VARCHAR2(2400);

  P_CAT_WHERE VARCHAR2(2400);

  P_ITEM_SEG VARCHAR2(2400);

  P_ITEM_WHERE VARCHAR2(2400);

  PV_ROUND_UNIT NUMBER;

  P_ORD_ID VARCHAR2(40);

  P_ZERO_COST_LAYERS NUMBER;

  PV_REPORT_OPTION VARCHAR2(80);

  P_RPT_OPTION NUMBER;

  P_VIEW_COST NUMBER;

  P_ZERO_COST_WHERE VARCHAR2(2400) := '1=1';

  P_ZERO_QTY_WHERE VARCHAR2(2400) := '1=1';

  P_ZERO_QTY_LAYERS NUMBER;

  PV_ZERO_COST_LAYER VARCHAR2(32767);

  PV_ZERO_QTY_LAYER VARCHAR2(32767);

  P_EXT_PREC NUMBER;

  FUNCTION CF_ORDERFORMULA(CATEGORY IN VARCHAR2) RETURN CHAR;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION BEFOREPFORM RETURN BOOLEAN;

  FUNCTION AFTERPFORM RETURN BOOLEAN;

  FUNCTION BETWEENPAGE RETURN BOOLEAN;

  FUNCTION P_ITEM_WHEREVALIDTRIGGER RETURN BOOLEAN;

END BOM_CSTRLIVR_XMLP_PKG;


/
