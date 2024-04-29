--------------------------------------------------------
--  DDL for Package ONT_OEXOEACK_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ONT_OEXOEACK_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: OEXOEACKS.pls 120.1 2007/12/25 07:12:49 npannamp noship $ */
  P_CONC_REQUEST_ID NUMBER;

  P_SOB_ID NUMBER;

  P_ORDER_NUM_LOW VARCHAR2(32767);

  P_ORDER_NUM_HIGH VARCHAR2(32767);

  P_BILL_TO_CUSTOMER_NAME_LO VARCHAR2(360);

  P_BILL_TO_CUSTOMER_NAME_HI VARCHAR2(360);

  P_ITEM_FLEX_CODE VARCHAR2(32767);

  P_ORG_ID VARCHAR2(32767);

  P_SCHEDULE_DATE_LOW DATE;

  P_SCHEDULE_DATE_HIGH DATE;

  P_ORDER_DATE_LOW DATE;

  P_ORDER_DATE_HIGH DATE;

  P_SALESREP VARCHAR2(240);

  P_CREATED_BY VARCHAR2(100);

  P_SHIP_TO_CUSTOMER_NAME_LO VARCHAR2(360);

  P_SHIP_TO_CUSTOMER_NAME_HI VARCHAR2(360);

  P_BOOKED_STATUS VARCHAR2(32767);

  LP_BOOKED_STATUS VARCHAR2(300):=' ';

  LP_ORDER_DATE VARCHAR2(800):=' ';

  LP_BILL_TO_CUSTOMER_NAME VARCHAR2(800):=' ';

  LP_SHIP_TO_CUSTOMER_NAME VARCHAR2(800):=' ';

  LP_ORDER_NUM VARCHAR2(800):=' ';

  LP_SCHEDULE_DATE VARCHAR2(800):=' ';

  P_PRINT_DESCRIPTION VARCHAR2(32767);

  LP_SALESREP VARCHAR2(1000):=' ';

  LP_CREATED_BY VARCHAR2(1000):=' ';

  P_ITEM_STRUCTURE_NUM NUMBER;

  P_PROFILE_NAME VARCHAR2(50);

  P_OPEN_ORDERS VARCHAR2(32767);

  LP_OPEN_ORDERS VARCHAR2(240):=' ';

  P_ORDER_TYPE NUMBER;

  LP_ORDER_TYPE VARCHAR2(200):=' ';

  LP_UNIT_OF_MEASURE VARCHAR2(200) := 'uom.unit_of_measure';

  LP_LANGUAGE_WHERE VARCHAR2(200) := 'and 1 = 1';

  MLS_FLAG VARCHAR2(1);

  ATT_COLUMN_NAME VARCHAR2(40);

  P_FUNCTIONAL_CURRENCY VARCHAR2(30);

  P_DEL_TO_CUSTOMER_NAME_LO VARCHAR2(360);

  P_DEL_TO_CUSTOMER_NAME_HI VARCHAR2(360);

  LP_DEL_TO_CUSTOMER_NAME VARCHAR2(800):=' ';

  P_ORDER_CATEGORY VARCHAR2(50);

  P_LINE_CATEGORY VARCHAR2(50);

  LP_ORDER_CATEGORY VARCHAR2(200):=' ';

  LP_LINE_CATEGORY VARCHAR2(200):=' ';

  LP_REQUEST_DATE VARCHAR2(800):=' ';

  LP_PROMISE_DATE VARCHAR2(800):=' ';

  P_REQUEST_DATE_HIGH DATE;

  P_REQUEST_DATE_LOW DATE;

  P_PROMISE_DATE_HIGH DATE;

  P_PROMISE_DATE_LOW DATE;

  P_SHOW_HDR_ATTACH VARCHAR2(32767);

  P_SHOW_BODY_ATTACH VARCHAR2(32767);

  P_SHOW_FTR_ATTACH VARCHAR2(32767);

  P_USER_LANG VARCHAR2(32767);

  P_MASTER_ORG_ID VARCHAR2(40);

  P_ENABLE_TRACE VARCHAR2(5);

  P_CHARGE_PERIODICITY VARCHAR2(32767);

  RP_DUMMY_ITEM VARCHAR2(2000);

  RP_REPORT_NAME VARCHAR2(240);

  RP_SUB_TITLE VARCHAR2(80);

  RP_COMPANY_NAME VARCHAR2(50);

  RP_FUNCTIONAL_CURRENCY VARCHAR2(20);

  RP_DATA_FOUND VARCHAR2(300);

  RP_ITEM_FLEX_ALL_SEG VARCHAR2(2000) := 'SI.SEGMENT1';

  RP_PRINT_DESCRIPTION VARCHAR2(100);

  RP_CURR_PROFILE VARCHAR2(50) := 'STANDARD';

  RP_ITEM_FLEX_SEG_VAL VARCHAR2(2000);

  RP_TAX_TOTAL_ROUNDED NUMBER;

  RP_LINE_CHARGE_TOTAL_ROUNDED NUMBER;

  RP_HDR_CHARGE_TOTAL_ROUNDED NUMBER;

  RP_HDR_CHARGE_TOTAL NUMBER;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION P_ITEM_FLEX_CODEVALIDTRIGGER RETURN BOOLEAN;

  FUNCTION AFTERPFORM RETURN BOOLEAN;

  FUNCTION C_LINE_SHIP_TO_CUSTFORMULA(LINE_SHIP_TO_ORG_ID IN NUMBER
                                     ,HDR_SHIP_TO_ORG_ID IN NUMBER
                                     ,LINE_S_CITY_ST_ZIP IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION C_DATA_NOT_FOUNDFORMULA(ORDER_NUMBER IN NUMBER) RETURN NUMBER;

  FUNCTION C_EXTENDED_PRICEFORMULA(SELLING_PRICE IN NUMBER
                                  ,C_PRECISION IN NUMBER
                                  ,PRICING_QUANTITY IN NUMBER
                                  ,LINE_CATEGORY_CODE IN VARCHAR2
                                  ,ORDERED_QUANTITY IN NUMBER) RETURN NUMBER;

  FUNCTION S_TAX_TOTAL_DSPFORMULA RETURN VARCHAR2;

  FUNCTION C_PRECISIONFORMULA(CURRENCY1 IN VARCHAR2) RETURN NUMBER;

  PROCEDURE POPULATE_MLS_LEXICALS;

  FUNCTION C_USE_CURRENCYFORMULA(C_BASE_CURRENCY IN VARCHAR2
                                ,CURRENCY1 IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION C_BASE_CURRENCYFORMULA RETURN VARCHAR2;

  FUNCTION C_GL_CONV_RATEFORMULA(CURRENCY1 IN VARCHAR2
                                ,C_BASE_CURRENCY IN VARCHAR2
                                ,CONVERSION_RATE IN NUMBER
                                ,ORDER_DATE IN DATE
                                ,CONVERSION_TYPE_CODE IN VARCHAR2) RETURN NUMBER;

  FUNCTION C_LINE_BILL_TO_CUSTFORMULA(LINE_BILL_TO_ORG_ID IN NUMBER
                                     ,HDR_BILL_TO_ORG_ID IN NUMBER
                                     ,LINE_B_CITY_ST_ZIP IN VARCHAR2) RETURN CHAR;

  FUNCTION C_LINE_DEL_TO_CUSTFORMULA(LINE_DEL_TO_ORG_ID IN NUMBER
                                    ,HDR_DEL_TO_ORG_ID IN NUMBER
                                    ,LINE_D_CITY_ST_ZIP IN VARCHAR2) RETURN CHAR;

  FUNCTION C_LINE_SALESREPFORMULA(LINE_SALESREP IN VARCHAR2
                                 ,SALES_PERSON IN VARCHAR2) RETURN CHAR;

  FUNCTION C_LINE_POFORMULA(LINE_PO IN VARCHAR2
                           ,PURCHASE_ORDER IN VARCHAR2) RETURN CHAR;

  FUNCTION C_LINE_TYPEFORMULA(LINE_TYPE_ID IN NUMBER
                             ,LINE_TYPE IN VARCHAR2) RETURN CHAR;

  FUNCTION C_LINE_FREIGHT_TERMSFORMULA(LINE_FREIGHT_TERMS IN VARCHAR2
                                      ,FREIGHT_TERMS IN VARCHAR2) RETURN CHAR;

  FUNCTION C_LINE_FOBFORMULA(LINE_FOB IN VARCHAR2
                            ,FOB IN VARCHAR2) RETURN CHAR;

  FUNCTION C_LINE_CARRIERFORMULA(LINE_CARRIER IN VARCHAR2
                                ,CARRIER IN VARCHAR2) RETURN CHAR;

  FUNCTION C_FC_EXTEND_PRICEFORMULA(C_GL_CONV_RATE IN NUMBER
                                   ,SVC_EXTENDED_PRICE IN NUMBER
                                   ,C_PRECISION IN NUMBER) RETURN NUMBER;

  FUNCTION C_FC_SALE_PRICEFORMULA(C_GL_CONV_RATE IN NUMBER
                                 ,SVC_SELLING_PRICE IN NUMBER) RETURN NUMBER;

  FUNCTION C_LINE_AGREEMENTFORMULA(LINE_AGREEMENT IN VARCHAR2
                                  ,AGREEMENT IN VARCHAR2) RETURN CHAR;

  FUNCTION C_LINE_TERMSFORMULA(LINE_TERM IN VARCHAR2
                              ,PAYMENT_TERMS IN VARCHAR2) RETURN CHAR;

  FUNCTION C_FMT_TAX_ON_LINEFORMULA(LINE_CATEGORY_CODE IN VARCHAR2
                                   ,C_TOTAL_LINE_TAX IN NUMBER
                                   ,C_PRECISION IN NUMBER) RETURN NUMBER;

  FUNCTION C_LINE_CATEGORYFORMULA(LINE_CATEGORY_CODE IN VARCHAR2) RETURN CHAR;

  FUNCTION C_LINE_CHARGEFORMULA(LINE_CHARGE IN NUMBER
                               ,C_PRECISION IN NUMBER) RETURN NUMBER;

  FUNCTION C_MASTER_ORGFORMULA RETURN CHAR;

  FUNCTION CF_1FORMULA(S_TAX_TOTAL IN NUMBER
                      ,S_LINE_CHARGE IN NUMBER
                      ,S_EXTENDED_PRICE IN NUMBER
                      ,S_SVC_EXTENDED_PRICE IN NUMBER
                      ,S_HEADER_CHARGE IN NUMBER
                      ,C_PRECISION IN NUMBER) RETURN NUMBER;

  FUNCTION C_TAX_ON_LINEFORMULA(LINE_CATEGORY_CODE IN VARCHAR2
                               ,C_TOTAL_LINE_TAX IN NUMBER
                               ,C_PRECISION IN NUMBER) RETURN NUMBER;

  FUNCTION C_ORDERED_QUANTITY(LINE_CATEGORY_CODE IN VARCHAR2
                             ,ORDERED_QUANTITY IN NUMBER) RETURN NUMBER;

  FUNCTION C_TOTAL_LINE_TAXFORMULA(TAX_ON_LINE IN NUMBER
                                  ,S_TOTAL_SVC_TAX IN NUMBER) RETURN NUMBER;

  FUNCTION C_SVC_TAXFORMULA(TAX_ON_SVC_LINE IN NUMBER
                           ,C_PRECISION IN NUMBER) RETURN NUMBER;

  FUNCTION C_CHARGE_PERIODICITYFORMULA(CHARGE_PERIODICITY_CODE IN VARCHAR2) RETURN CHAR;

  FUNCTION G_GRAND_TOTALFORMULA(CHARGE_PERIODICITY_CODE IN VARCHAR2
                               ,C_TAX_TOTAL IN NUMBER
                               ,C_LINE_RECUR_CHARGE IN NUMBER
                               ,CF_EXTENDED_PRICE IN NUMBER
                               ,C_SVC_EXTENDED_PRICE IN NUMBER
                               ,C_HEADER_CHARGE_PERIODICITY IN NUMBER
                               ,C_PRECISION IN NUMBER) RETURN NUMBER;

  FUNCTION G_PRECISIONFORMULA(CURRENCY1 IN VARCHAR2) RETURN NUMBER;

  FUNCTION C_HEADER_CHARGE_PERIODICITYFOR(CHARGE_PERIODICITY_CODE IN VARCHAR2
                                         ,C_HEADER_CHARGE IN NUMBER
                                         ,C_PRECISION IN NUMBER) RETURN NUMBER;

  FUNCTION C_HEADER_CHARGEFORMULA(HEADER_ID IN NUMBER) RETURN NUMBER;

  FUNCTION C_ACCEPT_REQUIREDFORMULA(CONTINGENCY_ID IN NUMBER) RETURN CHAR;

  FUNCTION C_BILL_CONTACTFORMULA(INVOICE_TO_CONTACT_ID IN NUMBER) RETURN CHAR;

  FUNCTION C_SHIP_CONTACTFORMULA(SHIP_TO_CONTACT_ID IN NUMBER) RETURN CHAR;

  FUNCTION C_DEL_CONTACTFORMULA(DELIVER_TO_CONTACT_ID IN NUMBER) RETURN CHAR;

  FUNCTION RP_DUMMY_ITEM_P RETURN VARCHAR2;

  FUNCTION RP_REPORT_NAME_P RETURN VARCHAR2;

  FUNCTION RP_SUB_TITLE_P RETURN VARCHAR2;

  FUNCTION RP_COMPANY_NAME_P RETURN VARCHAR2;

  FUNCTION RP_FUNCTIONAL_CURRENCY_P RETURN VARCHAR2;

  FUNCTION RP_DATA_FOUND_P RETURN VARCHAR2;

  FUNCTION RP_ITEM_FLEX_ALL_SEG_P RETURN VARCHAR2;

  FUNCTION RP_PRINT_DESCRIPTION_P RETURN VARCHAR2;

  FUNCTION RP_CURR_PROFILE_P RETURN VARCHAR2;

  FUNCTION RP_ITEM_FLEX_SEG_VAL_P RETURN VARCHAR2;

  FUNCTION RP_TAX_TOTAL_ROUNDED_P RETURN NUMBER;

  FUNCTION RP_LINE_CHARGE_TOTAL_ROUNDED_P RETURN NUMBER;

  FUNCTION RP_HDR_CHARGE_TOTAL_ROUNDED_P RETURN NUMBER;

  FUNCTION RP_HDR_CHARGE_TOTAL_P RETURN NUMBER;

  FUNCTION IS_FIXED_RATE(X_FROM_CURRENCY IN VARCHAR2
                        ,X_TO_CURRENCY IN VARCHAR2
                        ,X_EFFECTIVE_DATE IN DATE) RETURN VARCHAR2;

  PROCEDURE GET_RELATION(X_FROM_CURRENCY IN VARCHAR2
                        ,X_TO_CURRENCY IN VARCHAR2
                        ,X_EFFECTIVE_DATE IN DATE
                        ,X_FIXED_RATE IN OUT NOCOPY BOOLEAN
                        ,X_RELATIONSHIP IN OUT NOCOPY VARCHAR2);

  FUNCTION GET_EURO_CODE RETURN VARCHAR2;

  FUNCTION GET_RATE(X_FROM_CURRENCY IN VARCHAR2
                   ,X_TO_CURRENCY IN VARCHAR2
                   ,X_CONVERSION_DATE IN DATE
                   ,X_CONVERSION_TYPE IN VARCHAR2) RETURN NUMBER;

  FUNCTION GET_RATE(X_SET_OF_BOOKS_ID IN NUMBER
                   ,X_FROM_CURRENCY IN VARCHAR2
                   ,X_CONVERSION_DATE IN DATE
                   ,X_CONVERSION_TYPE IN VARCHAR2) RETURN NUMBER;

  FUNCTION CONVERT_AMOUNT(X_FROM_CURRENCY IN VARCHAR2
                         ,X_TO_CURRENCY IN VARCHAR2
                         ,X_CONVERSION_DATE IN DATE
                         ,X_CONVERSION_TYPE IN VARCHAR2
                         ,X_AMOUNT IN NUMBER) RETURN NUMBER;

  FUNCTION CONVERT_AMOUNT(X_SET_OF_BOOKS_ID IN NUMBER
                         ,X_FROM_CURRENCY IN VARCHAR2
                         ,X_CONVERSION_DATE IN DATE
                         ,X_CONVERSION_TYPE IN VARCHAR2
                         ,X_AMOUNT IN NUMBER) RETURN NUMBER;

  FUNCTION GET_DERIVE_TYPE(SOB_ID IN NUMBER
                          ,PERIOD IN VARCHAR2
                          ,CURR_CODE IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION RATE_EXISTS(X_FROM_CURRENCY IN VARCHAR2
                      ,X_TO_CURRENCY IN VARCHAR2
                      ,X_CONVERSION_DATE IN DATE
                      ,X_CONVERSION_TYPE IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;
  FUNCTION F_PERIODICITYFORMATTRIGGER RETURN VARCHAR2;

END ONT_OEXOEACK_XMLP_PKG;


/