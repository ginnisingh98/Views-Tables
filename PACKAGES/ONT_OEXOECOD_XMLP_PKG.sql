--------------------------------------------------------
--  DDL for Package ONT_OEXOECOD_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ONT_OEXOECOD_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: OEXOECODS.pls 120.2 2008/05/05 09:02:57 dwkrishn noship $ */
  P_SOB_ID NUMBER;

  P_ORDER_BY VARCHAR2(30);

  P_CONC_REQUEST_ID NUMBER;

  P_ORDER_TYPE_LO VARCHAR2(30);

  P_ORDER_TYPE_HI VARCHAR2(30);

  P_ORDER_NUM_LO VARCHAR2(32767);

  P_ORDER_NUM_HI VARCHAR2(32767);

  P_CUSTOMER_LO VARCHAR2(50);

  P_CUSTOMER_HI VARCHAR2(50);

  P_SALESREP_LO VARCHAR2(240);

  P_SALESREP_HI VARCHAR2(240);

  P_OPEN_ORDERS VARCHAR2(32767);

  P_SALES_CREDITS VARCHAR2(30);

  P_ADJUSTMENTS VARCHAR2(30);

  P_FUNCTIONAL_CURRENCY VARCHAR2(30);

  P_ENTERED_BY_LO VARCHAR2(100);

  P_ENTERED_BY_HI VARCHAR2(100);

  P_ORGANIZATION_ID NUMBER;

  P_ORDER_CATEGORY VARCHAR2(30);

  LP_ORDER_CATEGORY VARCHAR2(500) := ' ';

  LP_ORDER_TYPE VARCHAR2(200) := ' ';

  LP_CUSTOMER_NAME VARCHAR2(200) := ' ';

  LP_SALESREP_NAME VARCHAR2(240) := ' ';

  LP_ENTERED_BY VARCHAR2(200) := ' ';

  LP_LINE_TYPE VARCHAR2(200) := ' ';

  P_PRINT_DESCRIPTION VARCHAR2(32767);

  P_CUST_NUM_LO VARCHAR2(30);

  P_CUST_NUM_HI VARCHAR2(30);

  P_ORDER_DATE_HI DATE;
  P_ORDER_DATE_HI_T VARCHAR2(30);

  P_ORDER_DATE_LO DATE;
  P_ORDER_DATE_LO_T VARCHAR2(30);

  LP_ORDER_DATE VARCHAR2(200) := ' ';

  P_LINE_TYPE_HI VARCHAR2(30);

  P_LINE_TYPE_LO VARCHAR2(30);

  P_ITEM_FLEX_CODE VARCHAR2(32767);

  P_ITEM_STRUCTURE_NUM NUMBER;

  P_LINE_CATEGORY VARCHAR2(30);

  LP_LINE_CATEGORY VARCHAR2(40) := ' ';

  LP_CUSTOMER_NUMBER VARCHAR2(200) := ' ';

  LP_LINE_TYPE_WHERE VARCHAR2(200) := ' ';

  LP_ORDER_NUM VARCHAR2(800) := ' ';

  LP_ORDER_BY VARCHAR2(200) := ' ';

  P_ENABLE_TRACE VARCHAR2(5);

  P_CHARGE_PERIODICITY VARCHAR2(32767);

  L_ORDER_TYPE_LOW VARCHAR2(30);

  L_ORDER_TYPE_HIGH VARCHAR2(30);

  L_LINE_TYPE_LOW VARCHAR2(30);

  L_LINE_TYPE_HIGH VARCHAR2(30);

  P_END_CUST VARCHAR2(30);

  CP_STD_PRECISION NUMBER;

  CP_EXT_PRECISION NUMBER;

  CP_MIN_ACCT_UNIT NUMBER;

  LP_ORGANIZATION_ID number;

  CP_COMMITMENT NUMBER;

  CP_LINE_COMMITMENT NUMBER;

  RP_CURR_PROFILE VARCHAR2(50) := 'STANDARD';

  RP_ITEM_FLEX_ALL_SEG VARCHAR2(2000) := 'SI.SEGMENT1';

  RP_ITEM_FLEX_SEG_VAL VARCHAR2(2000);

function BeforeReport return boolean;

  FUNCTION C_ORDER_BY_DISPLAYFORMULA RETURN VARCHAR2;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION C_ORDER_NUM_WHERE RETURN VARCHAR2;

  FUNCTION GET_SOB_NAME RETURN VARCHAR2;

  FUNCTION C_OPEN_ORDERS_DISPLAYFORMULA RETURN VARCHAR2;

  FUNCTION CONTACT_PHONE(CONTACT_ID IN NUMBER) RETURN VARCHAR2;

  FUNCTION C_BASE_CURRENCYFORMULA RETURN VARCHAR2;

  FUNCTION C_SALES_CREDITS_DISPLAYFORMULA RETURN VARCHAR2;

  FUNCTION C_ADJUSTMENTS_DISPLAYFORMULA RETURN VARCHAR2;

  FUNCTION C_FUNCTIONAL_CURRENCY_DISPFORM RETURN VARCHAR2;

  FUNCTION C_GL_CONV_RATEFORMULA(CURRENCY1 IN VARCHAR2
                                ,C_BASE_CURRENCY IN VARCHAR2
                                ,CONVERSION_RATE IN NUMBER
                                ,ORDER_DATE IN DATE
                                ,CONVERSION_TYPE_CODE IN VARCHAR2) RETURN NUMBER;

  FUNCTION C_FC_ORDER_VALUEFORMULA(C_GL_CONV_RATE IN NUMBER
                                  ,HEADER_ID IN NUMBER) RETURN NUMBER;

  FUNCTION C_FC_HDR_PA_AMOUNTFORMULA(C_GL_CONV_RATE IN NUMBER
                                    ,HDR_PA_AMOUNT IN NUMBER) RETURN NUMBER;

  FUNCTION C_FC_LIST_PRICEFORMULA(C_GL_CONV_RATE IN NUMBER
                                 ,LIST_PRICE IN NUMBER) RETURN NUMBER;

  FUNCTION C_FC_SELLING_PRICEFORMULA(C_GL_CONV_RATE IN NUMBER
                                    ,SELLING_PRICE IN NUMBER) RETURN NUMBER;

  FUNCTION C_FC_EXTENDED_PRICEFORMULA(C_GL_CONV_RATE IN NUMBER
                                     ,EXTENDED_PRICE IN NUMBER) RETURN NUMBER;

  FUNCTION C_FC_L_PA_AMOUNTFORMULA(C_GL_CONV_RATE IN NUMBER
                                  ,L_PA_AMOUNT IN NUMBER) RETURN NUMBER;

  FUNCTION C_OPEN_ORDERS_WHERE RETURN VARCHAR2;

  FUNCTION C_USE_CURRENCYFORMULA(C_BASE_CURRENCY IN VARCHAR2
                                ,CURRENCY1 IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION RP_ORDER_CATEGORYFORMULA RETURN VARCHAR2;

  FUNCTION AFTERPFORM RETURN BOOLEAN;

  FUNCTION C_FC_TAXFORMULA(C_GL_CONV_RATE IN NUMBER
                          ,TAX_ON_LINE IN NUMBER) RETURN NUMBER;

  FUNCTION C_FC_LINE_CHARGEFORMULA(C_GL_CONV_RATE IN NUMBER
                                  ,LINE_CHARGE IN NUMBER) RETURN NUMBER;

  FUNCTION C_LINE_BILL_TO_CUSTFORMULA(LINE_BILL_TO_ORG_ID IN NUMBER
                                     ,INVOICE_TO_ORG_ID IN NUMBER
                                     ,L_BILL_ADDRESS IN VARCHAR2) RETURN CHAR;

  FUNCTION C_LINE_SHIP_TO_CUSTFORMULA(LINE_SHIP_TO_ORG_ID IN NUMBER
                                     ,HDR_SHIP_SITE_USE_ID IN NUMBER
                                     ,L_SHIP_ADDRESS IN VARCHAR2) RETURN CHAR;

  FUNCTION C_LINE_AGREEMENTFORMULA(LINE_AGREEMENT IN VARCHAR2
                                  ,AGREEMENT1 IN VARCHAR2) RETURN CHAR;

  FUNCTION C_LINE_POFORMULA(LINE_PO IN VARCHAR2
                           ,PURCHASE_ORDER IN VARCHAR2) RETURN CHAR;

  FUNCTION C_LINE_TERMSFORMULA(LINE_TERMS IN VARCHAR2
                              ,TERMS1 IN VARCHAR2) RETURN CHAR;

  FUNCTION C_ITEM_REVISIONFORMULA(ITEM_REVISION IN VARCHAR2) RETURN CHAR;

  FUNCTION P_ITEM_FLEX_CODEVALIDTRIGGER RETURN BOOLEAN;

  FUNCTION C_FC_EXTEND_PRICEFORMULA(C_GL_CONV_RATE IN NUMBER
                                   ,SVC_EXTENDED_PRICE IN NUMBER) RETURN NUMBER;

  FUNCTION C_FC_SALE_PRICEFORMULA(C_GL_CONV_RATE IN NUMBER
                                 ,SVC_SELLING_PRICE IN NUMBER) RETURN NUMBER;

  FUNCTION C_FMT_EXTEND_PRICEFORMULA(C_FC_EXTEND_PRICE IN NUMBER) RETURN NUMBER;

  FUNCTION RP_LINE_CATEGORYFORMULA RETURN VARCHAR2;

  FUNCTION RP_ITEM_DISPLAYFORMULA RETURN VARCHAR2;

  FUNCTION C_FC_AMOUNTFORMULA(C_GL_CONV_RATE IN NUMBER
                             ,AMOUNT IN NUMBER
                             ,C_USE_CURRENCY IN VARCHAR2) RETURN NUMBER;

  FUNCTION C_MASTER_ORGFORMULA RETURN CHAR;

  FUNCTION C_SHIP_HDR_ADDRESS4FORMULA(S_ADDRESS4 IN VARCHAR2
                                     ,HDR_SHIP_SITE_USE_ID IN NUMBER) RETURN CHAR;

  FUNCTION C_BILL_HDR_ADDRESS4FORMULA(B_ADDRESS4 IN VARCHAR2
                                     ,INVOICE_TO_ORG_ID IN NUMBER) RETURN CHAR;

  FUNCTION CF_HDR_PERCENTFORMULA(PREPAID_AMOUNT IN NUMBER
                                ,C_FC_ORDER_VALUE IN NUMBER) RETURN NUMBER;

  FUNCTION CF_LINE_PERCENTFORMULA(PREPAID_AMOUNT1 IN NUMBER
                                 ,C_FC_ORDER_VALUE IN NUMBER) RETURN NUMBER;

  FUNCTION C_CHARGE_PERIODICITYFORMULA(CHARGE_PERIODICITY_CODE IN VARCHAR2) RETURN CHAR;

  FUNCTION CF_INITIAL_DUE_TOTALFORMULA(HEADER_ID IN NUMBER) RETURN NUMBER;

  FUNCTION CF_INITIAL_DUE_BALANCEFORMULA(CF_INITIAL_DUE_TOTAL IN NUMBER
                                        ,CS_PREPAID_AMOUNT IN NUMBER) RETURN NUMBER;

  FUNCTION CF_AUTHORIZED_AMOUNTFORMULA(HEADER_ID IN NUMBER) RETURN NUMBER;

  FUNCTION CF_LINE_INITIAL_DUE_TOTALFORMU(HEADER_ID IN NUMBER
                                         ,LINE_ID IN NUMBER) RETURN NUMBER;

  FUNCTION CF_LINE_INITIAL_DUE_BALFORMULA(CF_LINE_INITIAL_DUE_TOTAL IN NUMBER) RETURN NUMBER;

  FUNCTION CF_LINE_AUTHORIZED_AMOUNTFORMU(LINE_ID IN NUMBER) RETURN NUMBER;

  FUNCTION CF_END_CUSTOMERFORMULA(END_CUSTOMER_ID IN NUMBER) RETURN CHAR;

  FUNCTION CF_END_CUSTOMER_ADDRESS1FORMUL(END_CUSTOMER_SITE_USE_ID IN NUMBER) RETURN CHAR;

  FUNCTION CF_END_CUSTOMER_ADDRESS5FORMUL(END_CUSTOMER_SITE_USE_ID IN NUMBER) RETURN CHAR;

  FUNCTION CF_END_CUSTOMER_CONTACTFORMULA(END_CUSTOMER_CONTACT_ID IN NUMBER) RETURN CHAR;

  FUNCTION CF_END_CUSTOMER_COUNTRYFORMULA(END_CUSTOMER_SITE_USE_ID IN NUMBER) RETURN CHAR;

  FUNCTION CF_END_CUSTOMER_NUMBERFORMULA(END_CUSTOMER_ID IN NUMBER) RETURN NUMBER;

  FUNCTION CF_IB_CURRENT_ADDRESS1FORMULA(IB_CURRENT_LOCATION IN VARCHAR2
                                        ,L_SHIP_ADDRESS IN VARCHAR2
                                        ,L_BILL_ADDRESS IN VARCHAR2
                                        ,DELIVER_TO_ORG_ID IN NUMBER
                                        ,HEADER_ID IN NUMBER
                                        ,END_CUSTOMER_SITE_USE_ID IN NUMBER) RETURN CHAR;

  FUNCTION CF_IB_CURRENT_ADDRESS5FORMULA(IB_CURRENT_LOCATION IN VARCHAR2
                                        ,SHIP_TO_ADDRESS5 IN VARCHAR2
                                        ,INVOICE_TO_ADDRESS5 IN VARCHAR2
                                        ,DELIVER_TO_ORG_ID IN NUMBER
                                        ,HEADER_ID IN NUMBER
                                        ,END_CUSTOMER_SITE_USE_ID IN NUMBER) RETURN CHAR;

  FUNCTION CF_IB_INSTALLED_AT_ADDRESS1FOR(IB_INSTALLED_AT_LOCATION IN VARCHAR2
                                         ,L_SHIP_ADDRESS IN VARCHAR2
                                         ,L_BILL_ADDRESS IN VARCHAR2
                                         ,DELIVER_TO_ORG_ID IN NUMBER
                                         ,HEADER_ID IN NUMBER
                                         ,END_CUSTOMER_SITE_USE_ID IN NUMBER) RETURN CHAR;

  FUNCTION CF_INSTALLED_AT_ADDRESS5FORMUL(IB_INSTALLED_AT_LOCATION IN VARCHAR2
                                         ,SHIP_TO_ADDRESS5 IN VARCHAR2
                                         ,INVOICE_TO_ADDRESS5 IN VARCHAR2
                                         ,DELIVER_TO_ORG_ID IN NUMBER
                                         ,HEADER_ID IN NUMBER
                                         ,END_CUSTOMER_SITE_USE_ID IN NUMBER) RETURN CHAR;

  FUNCTION CF_IB_OWNERFORMULA(IB_OWNER IN VARCHAR2
                             ,HEADER_ID IN NUMBER
                             ,END_CUSTOMER_ID IN NUMBER) RETURN CHAR;

  FUNCTION CF_END_DISPLAYFORMULA RETURN CHAR;

  FUNCTION CP_STD_PRECISION_P RETURN NUMBER;

  FUNCTION CP_EXT_PRECISION_P RETURN NUMBER;

  FUNCTION CP_MIN_ACCT_UNIT_P RETURN NUMBER;

  FUNCTION CP_COMMITMENT_P RETURN NUMBER;

  FUNCTION CP_LINE_COMMITMENT_P RETURN NUMBER;

  FUNCTION RP_CURR_PROFILE_P RETURN VARCHAR2;

  FUNCTION RP_ITEM_FLEX_ALL_SEG_P RETURN VARCHAR2;

  FUNCTION RP_ITEM_FLEX_SEG_VAL_P RETURN VARCHAR2;

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
  FUNCTION ITEM_DSPFORMULA
  (
  ITEM_IDENTIFIER_TYPE IN VARCHAR,
  C_MASTER_ORG IN VARCHAR,
  INVENTORY_ITEM_ID_T IN NUMBER,
  ORDERED_ITEM_ID_T IN NUMBER,
  ORDERED_ITEM IN varchar2,
SI_ORGANIZATION_ID in number,
SI_INVENTORY_ITEM_ID in number
  )
RETURN CHAR ;
END ONT_OEXOECOD_XMLP_PKG;


/
