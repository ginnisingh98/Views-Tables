--------------------------------------------------------
--  DDL for Package INV_INVTRHAN_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_INVTRHAN_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: INVTRHANS.pls 120.2 2008/01/08 06:49:37 dwkrishn noship $ */
  P_STRUCT_NUM VARCHAR2(15);
  P_ITEM_FLEX VARCHAR2(900):= '(MSI.SEGMENT1||''\n''||MSI.SEGMENT2||''\n''||MSI.SEGMENT3||''\n''||MSI.SEGMENT4||''\n''||MSI.SEGMENT5||''\n''||MSI.SEGMENT6||''\n''||MSI.SEGMENT7||''\n''||MSI.SEGMENT8||''\n''||MSI.SEGMENT9||''\n''||MSI.SEGMENT10||''\n''||
  MSI.SEGMENT11||''\n''||MSI.SEGMENT12||''\n''||MSI.SEGMENT13||''\n''||MSI.SEGMENT14||''\n''||MSI.SEGMENT15||''\n''||MSI.SEGMENT16||''\n''||MSI.SEGMENT17||''\n''||MSI.SEGMENT18||''\n''||MSI.SEGMENT19||''\n''||MSI.SEGMENT20)';
  P_STYPE1 NUMBER := 1;
  P_Stype1_1 NUMBER := 1;
  P_STYPE2 NUMBER := 2;
 P_STYPE2_1 NUMBER := 2;
  P_STYPE3 NUMBER := 3;
P_STYPE3_1 NUMBER := 3;
  P_STYPE4 NUMBER := 5;
  P_STYPE4_1 NUMBER := 5;
  P_STYPE5 NUMBER := 6;
  P_SELECTION NUMBER;
  P_HIST_DATE VARCHAR2(40);
  P_hist_date_1 VARCHAR2(40);
  P_SORT_ID NUMBER;
  P_ORG_ID NUMBER;
  P_CONC_REQUEST_ID NUMBER := 0;
  P_CAT_FLEX VARCHAR2(900) := '(MC.SEGMENT1||''\n''||MC.SEGMENT2||''\n''||MC.SEGMENT3||''\n''||MC.SEGMENT4||''\n''||MC.SEGMENT5||''\n''||MC.SEGMENT6||''\n''||MC.SEGMENT7||''\n''||MC.SEGMENT8||''\n''||MC.SEGMENT9||''\n''||MC.SEGMENT10||''\n''||
  MC.SEGMENT11||''\n''||MC.SEGMENT12||''\n''||MC.SEGMENT13||''\n''||MC.SEGMENT14||''\n''||MC.SEGMENT15||''\n''||MC.SEGMENT16||''\n''||MC.SEGMENT17||''\n''||MC.SEGMENT18||''\n''||MC.SEGMENT19||''\n''||MC.SEGMENT20)';
  P_WHERE_CAT VARCHAR2(2400):= '1=1';
  P_CAT_HI VARCHAR2(900);
  P_CAT_LO VARCHAR2(900);
  P_CAT_SET_ID NUMBER;
  P_SUBINV_HI VARCHAR2(40);
  P_SUBINV_LO VARCHAR2(40);
  P_ITEM_LO VARCHAR2(900);
  P_ITEM_HI VARCHAR2(900);
  P_WHERE_ITEM VARCHAR2(2400):= '1=1';
  P_CAT_STRUCT_NUM VARCHAR2(15);
  P_VIEW_PUT VARCHAR2(40);
  P_VIEW VARCHAR2(40) := 'txn_analysis_view';
  P_CAT_SORT VARCHAR2(900);
  P_ITEM_ORDER VARCHAR2(900):=1;
  P_QTY_PRECISION NUMBER;
  P_OPTIMIZER_FLAG NUMBER;
  P_TRACE_FLAG NUMBER;
  P_CONSIGNED NUMBER;
  P_CG_LO VARCHAR2(32767);
  P_WMS_ENABLED VARCHAR2(5);
  P_COST_GROUP_ID NUMBER;
  P_CG_HI VARCHAR2(32767);
  P_PJM_ENABLED VARCHAR2(5);
  P_WMS_PJM_ENABLED VARCHAR2(5);
  P_VIEW_PUTVALIDTRIGGER_1 VARCHAR2(100);
  FUNCTION AFTERREPORT RETURN BOOLEAN;
  FUNCTION C_TARGET_QTY_VALFORMULA(C_COST_TYPE IN NUMBER
                                  ,ASS_INV IN NUMBER
                                  ,TARGET_QTY IN NUMBER
                                  ,CUR_QTY_VAL_OLD IN NUMBER
                                  ,CUR_QTY_VAL IN NUMBER
                                  ,SOURCE_TYPE1 IN NUMBER
                                  ,SOURCE_TYPE2 IN NUMBER
                                  ,SOURCE_TYPE3 IN NUMBER
                                  ,SOURCE_TYPE4 IN NUMBER
                                  ,SOURCE_TYPE5 IN NUMBER
                                  ,OTHER IN NUMBER
                                  ,ITEM_ID IN NUMBER
                                  ,SUBINVENTORY IN VARCHAR2
                                  ,C_STD_PREC IN NUMBER) RETURN NUMBER;
  FUNCTION C_FROM_CATFORMULA RETURN VARCHAR2;
  FUNCTION C_WHERE_CATFORMULA RETURN VARCHAR2;
  FUNCTION C_SOURCE_TYPE1FORMULA RETURN VARCHAR2;
  FUNCTION C_SOURCE_TYPE2FORMULA RETURN VARCHAR2;
  FUNCTION C_SOURCE_TYPE3FORMULA RETURN VARCHAR2;
  FUNCTION C_SOURCE_TYPE4FORMULA RETURN VARCHAR2;
  FUNCTION C_SOURCE_TYPE5FORMULA RETURN VARCHAR2;
  FUNCTION C_WHERE_SUBINVFORMULA RETURN VARCHAR2;
  FUNCTION C_CAT_SET_NAMEFORMULA RETURN VARCHAR2;
  FUNCTION C_CHANGE_VALFORMULA(C_TARGET_QTY_VAL IN NUMBER
                              ,CUR_QTY_VAL IN NUMBER) RETURN NUMBER;
  FUNCTION BEFOREREPORT RETURN BOOLEAN;
  FUNCTION C_CHANGE_QTYFORMULA(CUR_QTY IN NUMBER
                              ,TARGET_QTY IN NUMBER) RETURN NUMBER;
  FUNCTION AFTERPFORM RETURN BOOLEAN;
--  FUNCTION P_VIEW_PUTVALIDTRIGGER RETURN BOOLEAN;
  FUNCTION P_VIEW_PUTVALIDTRIGGER RETURN VARCHAR2;
  FUNCTION C_CURRENCY_CODEFORMULA(CURRENCY_CODE_REP IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION BEFOREPFORM RETURN BOOLEAN;
  FUNCTION C_CAT_PADFORMULA(C_CAT_PAD IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION CUR_QTY_VALFORMULA(ASS_INV IN NUMBER
                             ,CUR_QTY_VAL_OLD IN NUMBER
                             ,SOURCE_TYPE1 IN NUMBER
                             ,SOURCE_TYPE2 IN NUMBER
                             ,SOURCE_TYPE3 IN NUMBER
                             ,SOURCE_TYPE4 IN NUMBER
                             ,OTHER IN NUMBER) RETURN NUMBER;
  FUNCTION C_COST_TYPEFORMULA RETURN NUMBER;
  FUNCTION C_OTHERSFORMULA(OTHER IN NUMBER
                          ,C_COST_TYPE IN NUMBER
                          ,ITEM_ID IN NUMBER
                          ,SUBINVENTORY IN VARCHAR2
                          ,TARGET_QTY IN NUMBER
                          ,SOURCE_TYPE1 IN NUMBER
                          ,SOURCE_TYPE2 IN NUMBER
                          ,SOURCE_TYPE3 IN NUMBER
                          ,SOURCE_TYPE4 IN NUMBER
                          ,C_STD_PREC IN NUMBER
                          ,CUR_QTY_VAL IN NUMBER) RETURN NUMBER;
  FUNCTION C_SOURCE_TYPE1_CFORMULA(SOURCE_TYPE1 IN NUMBER
                                  ,C_COST_TYPE IN NUMBER
                                  ,ITEM_ID IN NUMBER
                                  ,SUBINVENTORY IN VARCHAR2
                                  ,TARGET_QTY IN NUMBER
                                  ,C_SOURCE_TYPE2_C IN NUMBER
                                  ,C_SOURCE_TYPE3_C IN NUMBER
                                  ,C_SOURCE_TYPE4_C IN NUMBER
                                  ,OTHER IN NUMBER
                                  ,CUR_QTY_VAL IN NUMBER) RETURN NUMBER;
  FUNCTION C_SOURCE_TYPE2_CFORMULA(SOURCE_TYPE2 IN NUMBER
                                  ,C_COST_TYPE IN NUMBER
                                  ,ITEM_ID IN NUMBER
                                  ,SUBINVENTORY IN VARCHAR2
                                  ,TARGET_QTY IN NUMBER
                                  ,SOURCE_TYPE1 IN NUMBER
                                  ,SOURCE_TYPE3 IN NUMBER
                                  ,SOURCE_TYPE4 IN NUMBER
                                  ,OTHER IN NUMBER
                                  ,CUR_QTY_VAL IN NUMBER) RETURN NUMBER;
  FUNCTION C_SOURCE_TYPE3_CFORMULA(SOURCE_TYPE3 IN NUMBER
                                  ,C_COST_TYPE IN NUMBER
                                  ,ITEM_ID IN NUMBER
                                  ,SUBINVENTORY IN VARCHAR2
                                  ,TARGET_QTY IN NUMBER
                                  ,SOURCE_TYPE1 IN NUMBER
                                  ,SOURCE_TYPE2 IN NUMBER
                                  ,SOURCE_TYPE4 IN NUMBER
                                  ,OTHER IN NUMBER
                                  ,CUR_QTY_VAL IN NUMBER) RETURN NUMBER;
  FUNCTION C_SOURCE_TYPE4_CFORMULA(SOURCE_TYPE4 IN NUMBER
                                  ,C_COST_TYPE IN NUMBER
                                  ,ITEM_ID IN NUMBER
                                  ,SUBINVENTORY IN VARCHAR2
                                  ,TARGET_QTY IN NUMBER
                                  ,SOURCE_TYPE1 IN NUMBER
                                  ,SOURCE_TYPE2 IN NUMBER
                                  ,SOURCE_TYPE3 IN NUMBER
                                  ,OTHER IN NUMBER
                                  ,CUR_QTY_VAL IN NUMBER) RETURN NUMBER;
  FUNCTION C_SOURCE_TYPE5_CFORMULA(SOURCE_TYPE5 IN NUMBER) RETURN NUMBER;
END INV_INVTRHAN_XMLP_PKG;



/
