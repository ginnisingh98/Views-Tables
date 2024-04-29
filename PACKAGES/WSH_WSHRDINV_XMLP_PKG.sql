--------------------------------------------------------
--  DDL for Package WSH_WSHRDINV_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_WSHRDINV_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: WSHRDINVS.pls 120.3.12010000.3 2009/12/01 11:16:14 gbhargav ship $ */
  P_DELIVERY_ID NUMBER;

  P_TRIP_STOP_ID NUMBER;

  P_DEPARTURE_DATE_HIGH DATE;
  LP_DEPARTURE_DATE_HIGH DATE;

  P_DEPARTURE_DATE_LOW DATE;

  P_FREIGHT_CODE VARCHAR2(30);

  P_ITEM_DISPLAY VARCHAR2(1);

  P_ITEM_FLEX_CODE VARCHAR2(32767);

  LP_STRUCTURE_NUM VARCHAR2(128);

  P_ORGANIZATION_ID NUMBER;

  H_REPORT_ID NUMBER;

  H_WAREHOUSE_NAME VARCHAR2(240);

  RP_DATA_FOUND NUMBER;

  P_PRINT_CUST_ITEM VARCHAR2(1);

  H_EIN VARCHAR2(150);

  LP_TRIP_STOP_ID VARCHAR2(250) := ' ';

  LP_DELIVERY_ID VARCHAR2(128) := ' ';

  LP_DEPARTURE_DATE VARCHAR2(250) := ' ';

  P_CURRENCY_CODE VARCHAR2(15);

  LP_FREIGHT_CODE VARCHAR2(128) := ' ';

  LP_ORGANIZATION_ID VARCHAR2(128) := ' ';

  P_ITEM_COST NUMBER;

  P_EXTENDED_COST NUMBER;

  P_EXPORT_TXT VARCHAR2(300);

  P_MODULE_NAME VARCHAR2(32767);

  P_HEADER_NAME VARCHAR2(32767);

  P_LINE_NAME VARCHAR2(32767);

  P_CONC_REQUEST_ID NUMBER := 0;

  C_DELIVERY_DETAIL_ID VARCHAR2(40);

  CP_SHIP_TO_ADDR1 VARCHAR2(240);

  CP_SHIP_TO_ADDR2 VARCHAR2(240);

  CP_SHIP_TO_ADDR3 VARCHAR2(240);

  CP_SHIP_TO_ADDR4 VARCHAR2(240);

  CP_SHIP_TO_CITY_STATE VARCHAR2(185);

  CP_SHIP_TO_COUNTRY VARCHAR2(120);

  CP_ITEM_COST NUMBER;

  CP_EXTENDED_COST NUMBER;

  P_STANDALONE VARCHAR2(1);  --STANDALONE CHANGES
  FUNCTION AFTERPFORM RETURN BOOLEAN;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION C_ITEM_DISPFORMULA(CUSTOMER_ITEM_ID1 IN NUMBER
                             ,INVENTORY_ITEM_ID1 IN NUMBER
                             ,ORGANIZATION_ID1 IN NUMBER
                             ,ITEM_DESCRIPTION IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION C_NUM_BOXESFORMULA(DELIVERY_ID3 IN NUMBER
                             ,NUM_LPN IN NUMBER) RETURN NUMBER;

  FUNCTION C_DATA_FOUNDFORMULA(DELIVERY_ID3 IN NUMBER) RETURN NUMBER;

  FUNCTION LP_STOP_IDVALIDTRIGGER RETURN BOOLEAN;

  FUNCTION C_SHIP_VIAFORMULA(DELIVERY_ID3 IN NUMBER
                            ,SHIP_VIA IN VARCHAR2
                            ,ORGANIZATION_ID1 IN NUMBER) RETURN CHAR;

  FUNCTION H_WAREHOUSE_NAMEVALIDTRIGGER RETURN BOOLEAN;

  FUNCTION BEFOREPFORM RETURN BOOLEAN;

  FUNCTION F_SHIP_TO_CUST_NAMEFORMULA(SHIP_TO_SITE_USE_ID IN NUMBER) RETURN CHAR;

  FUNCTION CF_CONTACT_NAMEFORMULA(SHIP_TO_CONTACT_ID IN NUMBER) RETURN CHAR;

  FUNCTION CF_CUSTOMER_NAMEFORMULA RETURN CHAR;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION BEFOREREPORT0008 RETURN BOOLEAN;

  FUNCTION CF_1FORMULA RETURN CHAR;

  FUNCTION CF_EINFORMULA0007 RETURN CHAR;

  FUNCTION CF_COMMODITY_CLASSFORMULA(INVENTORY_ITEM_ID1 IN NUMBER
                                    ,ORGANIZATION_ID1 IN NUMBER) RETURN CHAR;

  FUNCTION CP_SHIP_TO_ADDR1_P RETURN VARCHAR2;

  FUNCTION CP_SHIP_TO_ADDR2_P RETURN VARCHAR2;

  FUNCTION CP_SHIP_TO_ADDR3_P RETURN VARCHAR2;

  FUNCTION CP_SHIP_TO_ADDR4_P RETURN VARCHAR2;

  FUNCTION CP_SHIP_TO_CITY_STATE_P RETURN VARCHAR2;

  FUNCTION CP_SHIP_TO_COUNTRY_P RETURN VARCHAR2;

  FUNCTION CP_ITEM_COST_P RETURN NUMBER;

  FUNCTION CP_EXTENDED_COST_P RETURN NUMBER;

  PROCEDURE PUT(NAME IN VARCHAR2
               ,VAL IN VARCHAR2);

  FUNCTION DEFINED(NAME IN VARCHAR2) RETURN BOOLEAN;

  PROCEDURE GET(NAME IN VARCHAR2
               ,VAL OUT NOCOPY VARCHAR2);

  FUNCTION VALUE(NAME IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION SAVE_USER(X_NAME IN VARCHAR2
                    ,X_VALUE IN VARCHAR2) RETURN BOOLEAN;

  FUNCTION SAVE(X_NAME IN VARCHAR2
               ,X_VALUE IN VARCHAR2
               ,X_LEVEL_NAME IN VARCHAR2
               ,X_LEVEL_VALUE IN VARCHAR2
               ,X_LEVEL_VALUE_APP_ID IN VARCHAR2) RETURN BOOLEAN;

  PROCEDURE GET_SPECIFIC(NAME_Z IN VARCHAR2
                        ,USER_ID_Z IN NUMBER
                        ,RESPONSIBILITY_ID_Z IN NUMBER
                        ,APPLICATION_ID_Z IN NUMBER
                        ,VAL_Z OUT NOCOPY VARCHAR2
                        ,DEFINED_Z OUT NOCOPY BOOLEAN);

  FUNCTION VALUE_SPECIFIC(NAME IN VARCHAR2
                         ,USER_ID IN NUMBER
                         ,RESPONSIBILITY_ID IN NUMBER
                         ,APPLICATION_ID IN NUMBER) RETURN VARCHAR2;

  PROCEDURE INITIALIZE(USER_ID_Z IN NUMBER
                      ,RESPONSIBILITY_ID_Z IN NUMBER
                      ,APPLICATION_ID_Z IN NUMBER
                      ,SITE_ID_Z IN NUMBER);

  PROCEDURE PUTMULTIPLE(NAMES IN VARCHAR2
                       ,VALS IN VARCHAR2
                       ,NUM IN NUMBER);

 function C_ext_cost_fmtFormula(source_code varchar2, source_line_id number, unit_of_measure varchar2,
source_uom varchar2, shipped_quantity number, inventory_item_id1 number) return VARCHAR2; -- Bug 9166141  line_id changed to source_line_id

 function C_item_cost_fmtFormula(source_code varchar2, source_line_id number, unit_of_measure varchar2,
source_uom varchar2, inventory_item_id1 number) return VARCHAR2; -- Bug 9166141  line_id changed to source_line_id

END WSH_WSHRDINV_XMLP_PKG;


/
