--------------------------------------------------------
--  DDL for Package MRP_MRPRPSST_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_MRPRPSST_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: MRPRPSSTS.pls 120.2 2007/12/25 08:34:55 nchinnam noship $ */
  P_ORG_ID NUMBER;

  P_FLEXDATA_ITEM VARCHAR2(750);

  P_CONC_REQUEST_ID NUMBER := 0;

  P_STRUCT_NUM VARCHAR2(15);

  P_SORT NUMBER;

  P_LOW_ITEM VARCHAR2(240);
  format_string VARCHAR2(20);

  P_HIGH_ITEM VARCHAR2(240);

  P_CAT_SET VARCHAR2(22);

  P_LOW_CAT VARCHAR2(240);

  P_HIGH_CAT VARCHAR2(240);

  P_SCHED_NAME VARCHAR2(10);

  P_ITEM_RANGE VARCHAR2(750);

  P_CAT_RANGE VARCHAR2(750);

  P_ORDER_BY VARCHAR2(300);

  P_DEBUG VARCHAR2(1);

  P_PRECISION NUMBER := 2;

  P_CURRENCY_CODE VARCHAR2(15);

  P_SCHED_VERSION NUMBER;

  P_START_DATE DATE;
  LP_START_DATE varchar2(11);

  P_WEEKS NUMBER;

  P_PERIODS NUMBER;

  P_CAT_STRUCT VARCHAR2(22);

  P_SCHED_TYPE NUMBER;

  P_QUERY_ID NUMBER;

  P_CAL_CODE VARCHAR2(10);

  P_CAL_EXCEPTION_SET_ID NUMBER;

  P_PERIODS_ACTUAL NUMBER;

  P_QTY_PRECISION VARCHAR2(40);

  P_CURRENCY_DESC VARCHAR2(80);

  P_SCHED_TYPE_DESC VARCHAR2(80);

  P_SCHED_VERSION_DESC VARCHAR2(80);

  P_CAT_STRUCT_NUM NUMBER;

  P_REPORT_MULTIORG NUMBER;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION C_PERIOD_DELTAFORMULA(C_ACTUAL_SUM IN NUMBER
                                ,C_SCHED_SUM IN NUMBER) RETURN NUMBER;

  FUNCTION C_SCHED_COSTFORMULA(C_SCHED_SUM IN NUMBER
                              ,C_ITEM_COST IN NUMBER) RETURN NUMBER;

  FUNCTION C_PERIOD_DELTA_COSTFORMULA(C_PERIOD_DELTA IN NUMBER
                                     ,C_ITEM_COST IN NUMBER) RETURN NUMBER;

  FUNCTION C_PERIOD_DELTA_CUM_COSTFORMULA(C_PERIOD_DELTA_CUM IN NUMBER
                                         ,C_ITEM_COST IN NUMBER) RETURN NUMBER;

  FUNCTION C_ACTUAL_COSTFORMULA(C_ACTUAL_SUM IN NUMBER
                               ,C_ITEM_COST IN NUMBER) RETURN NUMBER;

  FUNCTION C_SCHED_VERSIONFORMULA RETURN VARCHAR2;

  FUNCTION C_SORTFORMULA RETURN VARCHAR2;

  FUNCTION C_CAT_SETFORMULA RETURN VARCHAR2;

  FUNCTION C_CATEGORY_FROMFORMULA RETURN VARCHAR2;

  FUNCTION C_CATEGORY_WHEREFORMULA RETURN VARCHAR2;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION C_P_MULTIORG_MPSFORMULA RETURN NUMBER;

  FUNCTION C_ORDER_BYFORMULA RETURN VARCHAR2;

  FUNCTION C_P_REPORT_MULTIORGFORMULA RETURN VARCHAR2;

  FUNCTION C_P_USE_MULTIORG_PLANFORMULA RETURN NUMBER;

  /*PROCEDURE MRP_WEEKS_MONTHS(ARG_QUERY_ID IN NUMBER
                            ,ARG_USER_ID IN NUMBER
                            ,ARG_WEEKS IN NUMBER
                            ,ARG_PERIODS IN NUMBER
                            ,ARG_START_DATE IN DATE
                            ,ARG_ORG_ID IN NUMBER);*/

  PROCEDURE MRP_WEEKS_MONTHS(ARG_QUERY_ID IN NUMBER
                            ,ARG_USER_ID IN NUMBER
                            ,ARG_WEEKS IN NUMBER
                            ,ARG_PERIODS IN NUMBER
                            ,ARG_START_DATE IN DATE
                            ,ARG_ORG_ID IN NUMBER);

END MRP_MRPRPSST_XMLP_PKG;


/