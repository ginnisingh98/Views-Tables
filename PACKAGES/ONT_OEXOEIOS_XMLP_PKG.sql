--------------------------------------------------------
--  DDL for Package ONT_OEXOEIOS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ONT_OEXOEIOS_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: OEXOEIOSS.pls 120.1 2007/12/25 07:18:17 npannamp noship $ */
  P_CONC_REQUEST_ID NUMBER := 0;

  P_SOB_ID NUMBER;

  P_ORDER_TYPE_LOW VARCHAR2(30);

  P_ORDER_TYPE_HIGH VARCHAR2(30);

  P_ORDER_BY VARCHAR2(100);

  P_ORDER_NUM_LOW VARCHAR2(32767);

  P_ORDER_NUM_HIGH VARCHAR2(32767);

  P_CUSTOMER_NAME_LOW VARCHAR2(360);

  P_CUSTOMER_NAME_HIGH VARCHAR2(360);

  P_ORG_ID VARCHAR2(32767);

  P_SALESREP_LOW VARCHAR2(240);

  P_SALESREP_HIGH VARCHAR2(240);

  P_OPEN_ORDERS_ONLY VARCHAR2(3);

  P_COUNTRY VARCHAR2(80);

  LP_COUNTRY VARCHAR2(1000);

  LP_SALESREP VARCHAR2(1000);

  LP_ORDER_NUM VARCHAR2(1000);

  LP_CUSTOMER_NAME VARCHAR2(1000);

  LP_ORDER_TYPE VARCHAR2(1000);

  P_INVOICE_LINE_CONTEXT VARCHAR2(50);

  LP_OPEN_ORDERS_ONLY VARCHAR2(240);

  P_USE_FUNCTIONAL_CURRENCY VARCHAR2(32767);

  L_ORDER_TYPE_LOW VARCHAR2(30);

  L_ORDER_TYPE_HIGH VARCHAR2(30);

  C_INV_ORDER_AMT NUMBER := 0;

  C_BALANCE_DUE NUMBER := 0;

  C_CREDIT_AMOUNT NUMBER := 0;

  C_AMOUNT NUMBER := 0;

  RP_REPORT_NAME VARCHAR2(240);

  RP_SUB_TITLE VARCHAR2(80);

  RP_COMPANY_NAME VARCHAR2(50);

  RP_FUNCTIONAL_CURRENCY VARCHAR2(20);

  RP_DATA_FOUND VARCHAR2(300);

  RP_ORDER_NUMBER_RANGE VARCHAR2(500);

  RP_SALESREP_RANGE VARCHAR2(500);

  RP_CUSTOMER_NAME_RANGE VARCHAR2(500);

  RP_ORDER_TYPE_RANGE VARCHAR2(500);

  RP_OPEN_ORDERS_ONLY VARCHAR2(80);

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION AFTERPFORM RETURN BOOLEAN;

  FUNCTION C_DATA_NOT_FOUNDFORMULA(CURRENCY1 IN VARCHAR2) RETURN NUMBER;

  FUNCTION RP_CURR_LABELFORMULA RETURN VARCHAR2;

  FUNCTION C_ORDER_COUNTFORMULA RETURN NUMBER;

  FUNCTION C_LINE_COUNTFORMULA(HEADER_ID1 IN NUMBER) RETURN NUMBER;

  FUNCTION C_COMPUTE_AMOUNTSFORMULA(TRX_ID IN NUMBER
                                   ,CURRENCY1 IN VARCHAR2
                                   ,INV_ORDER_AMT IN NUMBER
                                   ,CONVERSION_TYPE_CODE IN VARCHAR2
                                   ,ORDER_DATE IN DATE
                                   ,C_PRECISION IN NUMBER
                                   ,CONVERSION_RATE IN NUMBER) RETURN NUMBER;

  FUNCTION RP_USE_FUNCTIONAL_CURRENCYFORM RETURN VARCHAR2;

  FUNCTION C_ORDER_AMOUNTFORMULA(CURRENCY1 IN VARCHAR2
                                ,ORDER_AMOUNT IN NUMBER
                                ,CONVERSION_TYPE_CODE IN VARCHAR2
                                ,ORDER_DATE IN DATE
                                ,C_PRECISION IN NUMBER
                                ,CONVERSION_RATE IN NUMBER) RETURN NUMBER;

  FUNCTION BEFOREPFORM RETURN BOOLEAN;

  FUNCTION C_PRECISIONFORMULA(CURRENCY1 IN VARCHAR2) RETURN NUMBER;

  FUNCTION C_INV_ORDER_AMT_P RETURN NUMBER;

  FUNCTION C_BALANCE_DUE_P RETURN NUMBER;

  FUNCTION C_CREDIT_AMOUNT_P RETURN NUMBER;

  FUNCTION C_AMOUNT_P RETURN NUMBER;

  FUNCTION RP_REPORT_NAME_P RETURN VARCHAR2;

  FUNCTION RP_SUB_TITLE_P RETURN VARCHAR2;

  FUNCTION RP_COMPANY_NAME_P RETURN VARCHAR2;

  FUNCTION RP_FUNCTIONAL_CURRENCY_P RETURN VARCHAR2;

  FUNCTION RP_DATA_FOUND_P RETURN VARCHAR2;

  FUNCTION RP_ORDER_NUMBER_RANGE_P RETURN VARCHAR2;

  FUNCTION RP_SALESREP_RANGE_P RETURN VARCHAR2;

  FUNCTION RP_CUSTOMER_NAME_RANGE_P RETURN VARCHAR2;

  FUNCTION RP_ORDER_TYPE_RANGE_P RETURN VARCHAR2;

  FUNCTION RP_OPEN_ORDERS_ONLY_P RETURN VARCHAR2;

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

END ONT_OEXOEIOS_XMLP_PKG;



/
