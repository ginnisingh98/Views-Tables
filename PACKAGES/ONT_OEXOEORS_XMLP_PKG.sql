--------------------------------------------------------
--  DDL for Package ONT_OEXOEORS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ONT_OEXOEORS_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: OEXOEORSS.pls 120.2 2008/05/05 12:42:31 dwkrishn noship $ */
  P_CONC_REQUEST_ID NUMBER;

  P_SOB_ID NUMBER;
  --added as fix
  P_RETURN_DATE_LOW_V varchar2(40);
  P_RETURN_DATE_HIGH_V varchar2(40);
  P_EXP_REC_DATE_LOW_V varchar2(40);
  P_EXP_REC_DATE_HIGH_V varchar2(40);

  P_EXP_REC_DATE_LOW DATE;

  P_EXP_REC_DATE_HIGH DATE;

  P_RETURN_TYPE VARCHAR2(30);

  P_ORDER_BY VARCHAR2(30);

  P_RETURN_NUM_LOW VARCHAR2(32767);

  P_RETURN_NUM_HIGH VARCHAR2(32767);

  P_CUSTOMER_NAME_LOW VARCHAR2(360);

  P_CUSTOMER_NUMBER_LOW VARCHAR2(50);

  P_ITEM_FLEX_CODE VARCHAR2(32767);

  P_ORGANIZATION_ID VARCHAR2(32767);
--added as fix
  P_ORGANIZATION_ID_V  VARCHAR2(32767);
  P_RETURN_DAYS_HIGH NUMBER;

  P_RETURN_DAYS_LOW NUMBER;

  P_OPEN_RETURNS_ONLY VARCHAR2(50);

  P_PRINT_DESCRIPTION VARCHAR2(50);

  P_REC_DAYS_LOW NUMBER;

  P_REC_DAYS_HIGH NUMBER;

  P_RETURN_DATE_LOW DATE;

  P_RETURN_DATE_HIGH DATE;

  P_WAREHOUSE VARCHAR2(60);

  P_USE_FUNCTIONAL_CURRENCY VARCHAR2(32767);

  --LP_OPEN_RETURNS_ONLY VARCHAR2(500);
  LP_OPEN_RETURNS_ONLY VARCHAR2(500):=' ';

  --LP_REC_DAYS VARCHAR2(500);
  LP_REC_DAYS VARCHAR2(500):= ' ';

  --LP_RETURN_DAYS VARCHAR2(500);
  LP_RETURN_DAYS VARCHAR2(500):= ' ';

  --LP_RETURN_DATE VARCHAR2(500);
  LP_RETURN_DATE VARCHAR2(500):=' ';

  --LP_EXP_REC_DATE VARCHAR2(500);
  LP_EXP_REC_DATE VARCHAR2(500):=' ';

  --LP_RETURN_NUM VARCHAR2(500);
  LP_RETURN_NUM VARCHAR2(500):= ' ';

  --LP_RETURN_TYPE VARCHAR2(500);
  LP_RETURN_TYPE VARCHAR2(500):=' ';

  --LP_WAREHOUSE VARCHAR2(500);
  LP_WAREHOUSE VARCHAR2(500):=' ';

  --LP_CUSTOMER_NUMBER VARCHAR2(500);
  LP_CUSTOMER_NUMBER VARCHAR2(500):=' ';

  --LP_CUSTOMER_NAME VARCHAR2(500);
  LP_CUSTOMER_NAME VARCHAR2(500):=' ';

  P_ITEM_STRUCTURE_NUM NUMBER;

  P_CUSTOMER_NAME_HIGH VARCHAR2(360);

  P_CUSTOMER_NUMBER_HIGH VARCHAR2(50);

  P_RETURN_LINE_TYPE VARCHAR2(30);

  P_LINE_CATEGORY VARCHAR2(30);

  --LP_RETURN_LINE_TYPE VARCHAR2(500);
  LP_RETURN_LINE_TYPE VARCHAR2(500):=' ';

  --LP_LINE_CATEGORY VARCHAR2(500);
  LP_LINE_CATEGORY VARCHAR2(500):= ' ';

  P_ENABLE_TRACE VARCHAR2(5);

  L_ORDER_TYPE VARCHAR2(30);

  L_LINE_TYPE VARCHAR2(30);

  RP_DUMMY_ITEM VARCHAR2(2000);

  C_AUTHORIZED_AMOUNT NUMBER;

  RP_REPORT_NAME VARCHAR2(240);

  RP_SUB_TITLE VARCHAR2(80);

  RP_COMPANY_NAME VARCHAR2(50);

  RP_FUNCTIONAL_CURRENCY VARCHAR2(20);

  RP_DATA_FOUND VARCHAR2(300);

  RP_ITEM_FLEX_ALL_SEG VARCHAR2(500) := 'SI.SEGMENT1';

  RP_PRINT_DESCRIPTION VARCHAR2(80);

  RP_RETURN_NUMBER_RANGE VARCHAR2(100);

  RP_EXP_REC_DATE_RANGE VARCHAR2(100);

  RP_RETURN_DATE_RANGE VARCHAR2(100);

  RP_OPEN_RETURNS_ONLY VARCHAR2(80);

  RP_USE_FUNCTIONAL_CURRENCY VARCHAR2(80);

  RP_CUST_NAME_RANGE VARCHAR2(60);

  RP_CUST_NO_RANGE VARCHAR2(60);

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION P_ORGANIZATION_IDVALIDTRIGGER RETURN BOOLEAN;

  FUNCTION P_ITEM_FLEX_CODEVALIDTRIGGER RETURN BOOLEAN;

  FUNCTION P_SOB_IDVALIDTRIGGER RETURN BOOLEAN;

  FUNCTION P_USE_FUNCTIONAL_CURRENCYVALID RETURN BOOLEAN;

  FUNCTION C_ACTUAL_RECEIPT_DAYS(QTY_AUTHORIZED IN NUMBER
                                ,RECEIPT_DAYS IN NUMBER) RETURN NUMBER;

  FUNCTION C_ACTUAL_RETURN_DAYS(QTY_AUTHORIZED IN NUMBER
                               ,RETURN_DAYS IN NUMBER) RETURN NUMBER;

  FUNCTION AFTERPFORM RETURN BOOLEAN;

  FUNCTION C_DATA_NOT_FOUNDFORMULA(CURRENCY2 IN VARCHAR2) RETURN NUMBER;

  FUNCTION C_ORDER_COUNTFORMULA RETURN NUMBER;

  FUNCTION RP_ORDER_BYFORMULA RETURN VARCHAR2;

  FUNCTION C_MASTER_ORGFORMULA RETURN NUMBER;

  FUNCTION RP_DUMMY_ITEM_P RETURN VARCHAR2;

   FUNCTION C_AUTHORIZED_AMOUNT_P(currency2 varchar2,authorized_amount number,conversion_type_code varchar2,return_date date,conversion_rate number) RETURN NUMBER;


  FUNCTION RP_REPORT_NAME_P RETURN VARCHAR2;

  FUNCTION RP_SUB_TITLE_P RETURN VARCHAR2;

  FUNCTION RP_COMPANY_NAME_P RETURN VARCHAR2;

  FUNCTION RP_FUNCTIONAL_CURRENCY_P RETURN VARCHAR2;

  FUNCTION RP_DATA_FOUND_P RETURN VARCHAR2;

  FUNCTION RP_ITEM_FLEX_ALL_SEG_P RETURN VARCHAR2;

  FUNCTION RP_PRINT_DESCRIPTION_P RETURN VARCHAR2;

  FUNCTION RP_RETURN_NUMBER_RANGE_P RETURN VARCHAR2;

  FUNCTION RP_EXP_REC_DATE_RANGE_P RETURN VARCHAR2;

  FUNCTION RP_RETURN_DATE_RANGE_P RETURN VARCHAR2;

  FUNCTION RP_OPEN_RETURNS_ONLY_P RETURN VARCHAR2;

  FUNCTION RP_USE_FUNCTIONAL_CURRENCY_P RETURN VARCHAR2;

  FUNCTION RP_CUST_NAME_RANGE_P RETURN VARCHAR2;

  FUNCTION RP_CUST_NO_RANGE_P RETURN VARCHAR2;

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

function BeforeReport return boolean;

FUNCTION ITEM_DSPFORMULA(ITEM_IDENTIFIER_TYPE IN VARCHAR2,INVENTORY_ITEM_ID1 IN NUMBER,ORDERED_ITEM_ID IN NUMBER,ORDERED_ITEM IN VARCHAR2,C_ORGANIZATION_ID IN VARCHAR2,C_INVENTORY_ITEM_ID IN VARCHAR2)  return Char ;

END ONT_OEXOEORS_XMLP_PKG;


/
