--------------------------------------------------------
--  DDL for Package BOM_CSTRUSIA_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_CSTRUSIA_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: CSTRUSIAS.pls 120.0 2007/12/24 10:20:11 dwkrishn noship $ */
  P_CONC_REQUEST_ID VARCHAR2(32767) := '0';

  P_ORG_ID NUMBER;

  P_CURRENCY_CODE VARCHAR2(15);

  P_SORT_OPTION NUMBER;

  P_ITEM_FROM VARCHAR2(1350);

  P_ITEM_TO VARCHAR2(1350);

  P_CATEGORY_SET NUMBER:=3;

  P_CAT_NUM NUMBER:=101;

  P_ORGANIZATION VARCHAR2(240);

  ROUND_UNIT NUMBER:=1;

  P_ITEM_SEG VARCHAR2(2400);

  P_CAT_SEG VARCHAR2(2400);

  P_SORT_BY VARCHAR2(80);



  P_CAT_SET_NAME VARCHAR2(40);

  P_ACCT_SEG1 VARCHAR2(2400);

  P_ACCT_SEG2 VARCHAR2(2400);

  P_ACCT_SEG3 VARCHAR2(2400);

  P_ACCT_SEG4 VARCHAR2(2400);

  P_ACCT_SEG5 VARCHAR2(2400);

  P_GL_NUM NUMBER:=101;

  P_ITEM_RANGE VARCHAR2(80);

  P_RANGE_OPTION NUMBER:=1;

  EXT_PREC NUMBER:=0;

  P_RPT_ONLY NUMBER;

  P_DEL_SNAPSHOT NUMBER;

  P_UPDATE_ID NUMBER;

  P_ADJ_ACCOUNT NUMBER:=0;

  P_ACCT_SEG6 VARCHAR2(2400);

  P_ITEM NUMBER;

  P_CAT NUMBER;

  P_QTY_PRECISION NUMBER;

  QTY_PRECISION varchar2(50);

  P_UPDATE_DATE DATE;

  P_UPDATE_DESC VARCHAR2(240);

  P_COST_TYPE VARCHAR2(10);

  P_COST_TYPE_ID NUMBER;

  P_TRACE VARCHAR2(1);

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  function g_filter1 return boolean;

  function g_filter2 return boolean;

  function g_filter3 return boolean;

  function g_filter4 return boolean;

  FUNCTION SI_SI_ADJFORMULA(SI_SI_MTL IN NUMBER
                           ,SI_SI_MOH IN NUMBER
                           ,SI_SI_RES IN NUMBER
                           ,SI_SI_OSP IN NUMBER
                           ,SI_SI_OVH IN NUMBER) RETURN NUMBER;

  FUNCTION ORG_ADJFORMULA(SI_ORG_MTL IN NUMBER
                         ,SI_ORG_MOH IN NUMBER
                         ,SI_ORG_RES IN NUMBER
                         ,SI_ORG_OSP IN NUMBER
                         ,SI_ORG_OVH IN NUMBER
                         ,IC_ORG_MTL IN NUMBER
                         ,IC_ORG_MOH IN NUMBER
                         ,IC_ORG_RES IN NUMBER
                         ,IC_ORG_OSP IN NUMBER
                         ,IC_ORG_OVH IN NUMBER) RETURN NUMBER;

  FUNCTION REP_ADJFORMULA(SI_REP_MTL IN NUMBER
                         ,SI_REP_MOH IN NUMBER
                         ,SI_REP_RES IN NUMBER
                         ,SI_REP_OSP IN NUMBER
                         ,SI_REP_OVH IN NUMBER
                         ,IC_REP_MTL IN NUMBER
                         ,IC_REP_MOH IN NUMBER
                         ,IC_REP_RES IN NUMBER
                         ,IC_REP_OSP IN NUMBER
                         ,IC_REP_OVH IN NUMBER) RETURN NUMBER;

  FUNCTION IC_ORDERFORMULA(IC_ITEM_NUMBER IN VARCHAR2
                          ,IC_CATEGORY IN VARCHAR2
                          ,IC_ITEM_SEG IN VARCHAR2
                          ,IC_CAT_SEG IN VARCHAR2
                          ,IC_ITEM_PSEG IN VARCHAR2
                          ,IC_CAT_PSEG IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION IC_CAT_PSEGFORMULA(IC_CATEGORY IN VARCHAR2
                             ,IC_CAT_SEG IN VARCHAR2
                             ,IC_CAT_PSEG IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION IC_ITEM_PSEGFORMULA(IC_ITEM_NUMBER IN VARCHAR2
                              ,IC_ITEM_SEG IN VARCHAR2
                              ,IC_ITEM_PSEG IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION SI_ITEM_PSEGFORMULA(SI_ITEM_NUMBER IN VARCHAR2
                              ,SI_ITEM_SEG IN VARCHAR2
                              ,SI_ITEM_PSEG IN VARCHAR2) RETURN VARCHAR2;

END BOM_CSTRUSIA_XMLP_PKG;


/
