--------------------------------------------------------
--  DDL for Package BOM_CSTRTVHA_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_CSTRTVHA_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: CSTRTVHAS.pls 120.0 2007/12/24 10:19:18 dwkrishn noship $ */
  P_HIST_DATE VARCHAR2(40);

  P_ORG_ID NUMBER;

  P_COST_GROUP_OPTION_ID NUMBER;

  P_SORT_OPTION NUMBER;

  P_CAT_SET_ID NUMBER;

  P_CAT_STRUCT_NUM VARCHAR2(15);

  P_CAT_LO VARCHAR2(900);

  P_CAT_HI VARCHAR2(900);

  P_CONC_REQUEST_ID NUMBER := 0;

  P_ITEM_LO VARCHAR2(900);

  P_ITEM_HI VARCHAR2(900);

  P_STYPE1 NUMBER;

  P_STYPE2 NUMBER;

  P_STYPE3 NUMBER;

  P_STYPE4 NUMBER;

  P_CAT_SEG VARCHAR2(800);

  P_ITEM_SEG VARCHAR2(800);

  PV_STYPE1 VARCHAR2(30);

  PV_STYPE2 VARCHAR2(30);

  PV_STYPE3 VARCHAR2(30);

  PV_STYPE4 VARCHAR2(30);

  PV_ORGANIZATION_NAME VARCHAR2(240);

  PV_SORT_OPTION VARCHAR2(80);

  PV_CATEGORY_SET_NAME VARCHAR2(30);

  PV_HIST_DATE DATE;

  PV_CURRENCY_CODE VARCHAR2(15);

  P_ITEM_WHERE VARCHAR2(2400);

  P_CAT_WHERE VARCHAR2(2400);

  PV_STD_PREC NUMBER;

  P_MAIN_QUERY VARCHAR2(1000);

  P_INTRANSIT NUMBER;

  P_CG VARCHAR2(10);

  P_TITLE VARCHAR2(240);

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION CF_ORDERFORMULA(CATEGORY IN VARCHAR2) RETURN CHAR;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION CF_1FORMULA(NEWVAL IN NUMBER
                      ,OLDVAL IN NUMBER
                      ,S1VAL IN NUMBER
                      ,S2VAL IN NUMBER
                      ,S3VAL IN NUMBER
                      ,S4VAL IN NUMBER) RETURN NUMBER;

END BOM_CSTRTVHA_XMLP_PKG;



/
