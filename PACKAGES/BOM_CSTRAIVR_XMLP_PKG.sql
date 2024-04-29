--------------------------------------------------------
--  DDL for Package BOM_CSTRAIVR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_CSTRAIVR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: CSTRAIVRS.pls 120.0 2007/12/24 09:52:53 dwkrishn noship $ */
  P_CONC_REQUEST_ID VARCHAR2(32767) := '0';

  P_ORG_ID VARCHAR2(40);

  P_CURRENCY_CODE VARCHAR2(15);

  P_EXCHANGE_RATE NUMBER := 1;

  P_SORT_OPTION NUMBER;

  P_ITEM_FROM VARCHAR2(800);

  P_ITEM_TO VARCHAR2(800);

  P_CATEGORY_SET NUMBER;

  P_CAT_NUM NUMBER;

  P_CAT_FROM VARCHAR2(800);

  P_CAT_TO VARCHAR2(800);

  P_NEG_QTY NUMBER;

  P_ZERO_COST NUMBER;

  P_ORGANIZATION VARCHAR2(240);

  ROUND_UNIT NUMBER;

  P_ITEM_SEG VARCHAR2(2400) := 'MSI.description||MSI.description||MSI.description||MSI.segment1||MSI.segment2||MSI.segment3';

  P_CAT_SEG VARCHAR2(2400) := 'MC.attribute1||MC.attribute2||MC.attribute3||MC.attribute4||MC.attribute5||MC.description||MC.segment1';

  P_ITEM_WHERE VARCHAR2(2400);

  P_CAT_WHERE VARCHAR2(2400);

  P_SORT_BY VARCHAR2(80);

  P_CAT_SET_NAME VARCHAR2(40);

  P_GL_NUM NUMBER;

  P_DETAIL_LEVEL VARCHAR2(80);

  P_COST_TYPE_ID NUMBER;

  P_DEF_COST_TYPE NUMBER :=1 ;

  P_COST_TYPE VARCHAR2(10);

  P_TRACE VARCHAR2(1);

  P_EXT_PREC NUMBER := 5;

  P_QTY_WHERE VARCHAR2(1440);

  P_EXP_ITEM NUMBER;

  P_QTY_PRECISION NUMBER;

  P_CURRENCY_DSP VARCHAR2(50);

  P_VIEW_COST NUMBER;

  P_EXP_SUBINV NUMBER;

  P_RPT_MODE NUMBER;

  P_COST_ORG_ID NUMBER;

  P_EXCHANGE_RATE_CHAR VARCHAR2(38);

  P_AS_OF_DATE VARCHAR2(30);

  P_AS_OF_DATE1 VARCHAR2(30);

  P_TITLE VARCHAR2(240);

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION CATEGORY_PSEGFORMULA(CATEGORY IN VARCHAR2
                               ,CATEGORY_SEGMENT IN VARCHAR2
                               ,CATEGORY_PSEG IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION ITEM_PSEGFORMULA(ITEM_NUMBER IN VARCHAR2
                           ,ITEM_SEGMENT IN VARCHAR2
                           ,ITEM_PSEG IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION ITEM_TOTAL_QUANTITYFORMULA(STK_QUANTITY IN NUMBER
                                     ,INT_QUANTITY IN NUMBER
                                     ,RCV_QUANTITY IN NUMBER) RETURN NUMBER;

  FUNCTION ITEM_TOTAL_VALUEFORMULA(ITEM_STK_VALUE IN NUMBER
                                  ,ITEM_INT_VALUE IN NUMBER
                                  ,ITEM_RCV_VALUE IN NUMBER) RETURN NUMBER;

  FUNCTION CAT_TOTAL_VALUEFORMULA(CAT_STK_VALUE IN NUMBER
                                 ,CAT_INT_VALUE IN NUMBER
                                 ,CAT_RCV_VALUE IN NUMBER) RETURN NUMBER;

  FUNCTION C_ORDERFORMULA(ITEM_NUMBER IN VARCHAR2
                         ,ITEM_SEGMENT IN VARCHAR2
                         ,ITEM_PSEG IN VARCHAR2
                         ,CATEGORY IN VARCHAR2
                         ,CATEGORY_SEGMENT IN VARCHAR2
                         ,CATEGORY_PSEG IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION REP_TOTAL_VALUEFORMULA(REP_STK_VALUE IN NUMBER
                                 ,REP_INT_VALUE IN NUMBER
                                 ,REP_RCV_VALUE IN NUMBER) RETURN NUMBER;

  FUNCTION P_TITLEVALIDTRIGGER RETURN BOOLEAN;

END BOM_CSTRAIVR_XMLP_PKG;


/