--------------------------------------------------------
--  DDL for Package BOM_BOMRDRTG_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_BOMRDRTG_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: BOMRDRTGS.pls 120.1 2008/01/06 10:09:11 nchinnam noship $ */
  P_ORG_ID VARCHAR2(40);

  P_BOM_OR_ENG VARCHAR2(40);

  P_CONC_REQUEST_ID NUMBER := 0;

  P_ALT_OPTION VARCHAR2(80);

  P_DISPLAY_OPTION VARCHAR2(80);

  P_EFF_DATE VARCHAR2(32767);

  P_EFF_DATE1 VARCHAR2(32767);

  P_ALTERNATE VARCHAR2(40);

  P_DETAIL VARCHAR2(40);

  P_RPT_SELECTION VARCHAR2(40);

  P_ITEM VARCHAR2(240);

  P_ASSEMBLY VARCHAR2(650);

  P_STRUCT_ASSY VARCHAR2(15);

  P_COMMON VARCHAR2(650);

  P_STRUCT_COMMON VARCHAR2(15);

  P_LOCATOR VARCHAR2(650);

  P_STRUCT_LOCATOR VARCHAR2(15);

  P_ASSY_ORDER VARCHAR2(800);

  P_ITEM_FROM VARCHAR2(240);

  P_ITEM_TO VARCHAR2(240);

  P_CAT_FROM VARCHAR2(240);

  P_CAT_TO VARCHAR2(240);

  P_CAT_SET VARCHAR2(40);

  P_CAT_STRUCT VARCHAR2(40);

  P_ASSY_BETWEEN VARCHAR2(480);

  P_CAT_BETWEEN VARCHAR2(480);

  P_ORG_NAME VARCHAR2(60);

  P_DISPLAY_OPTION_CHAR VARCHAR2(80);

  P_ALT_OPTION_CHAR VARCHAR2(80);

  P_RPT_SELECTION_CHAR VARCHAR2(80);

  P_DETAIL_CHAR VARCHAR2(80);

  P_PRV_INST_CNT NUMBER;

  P_PRV_RSC_CNT NUMBER;

  P_SPECIFIC_ITEM_FLEX VARCHAR2(80);

  P_REVISION VARCHAR2(40);

  P_CAT_SET_NAME VARCHAR2(40);

  P_DTL_SUM_CHAR VARCHAR2(80);

  P_CURRENCY_CODE VARCHAR2(15);

  P_QTY_PRECISION NUMBER;

  P_DEBUG VARCHAR2(2);

  P_MSG_BUF VARCHAR2(80);

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

END BOM_BOMRDRTG_XMLP_PKG;



/