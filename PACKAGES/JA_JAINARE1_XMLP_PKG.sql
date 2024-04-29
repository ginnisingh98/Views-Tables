--------------------------------------------------------
--  DDL for Package JA_JAINARE1_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JA_JAINARE1_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: JAINARE1S.pls 120.1 2007/12/25 16:12:59 dwkrishn noship $ */
  P_CUSTOMER_TRX_ID NUMBER;

  P_BOND_DATE DATE;

  P_BOND_NO VARCHAR2(25);

  P_EX_AUTH_ADDRESS VARCHAR2(100);

  P_EX_POSTAL_ADDRESS VARCHAR2(100);

  P_LOCATION_ID NUMBER;

  P_ORGANIZATION_ID NUMBER;

  P_ORG_ID NUMBER;

  P_SUP_EX_ADDRESS VARCHAR2(100);

  P_CUSTOMER_TRX_ID1 NUMBER;

  P_CONC_REQUEST_ID NUMBER;

  CP_CLOSING_BAL NUMBER;

  CP_DEBIT_AMOUNT NUMBER;

  CP_OPENING_BAL NUMBER;

  CP_NULL VARCHAR2(1);

  CP_EXCISE_CESS_AMOUNT NUMBER;

  CP_EXCISE_SH_CESS_AMOUNT NUMBER;

  FUNCTION CF_CITYFORMULA RETURN CHAR;

  FUNCTION CF_LEGAL_ENTITYFORMULA RETURN CHAR;

  FUNCTION CF_DESTINATION_COUNTRYFORMULA(SHIP_TO_SITE_USE_ID IN NUMBER) RETURN CHAR;

  FUNCTION CP_NULLFORMULA RETURN CHAR;

  FUNCTION CF_QTY_OF_GOODSFORMULA(QUANTITY IN NUMBER
                                 ,REQUESTED_QUANTITY_UOM IN VARCHAR2) RETURN CHAR;

  FUNCTION CF_TAX_RATEFORMULA(DELIVERY_ID IN NUMBER
                             ,INVENTORY_ITEM_ID IN NUMBER) RETURN NUMBER;

  FUNCTION CF_VALUEFORMULA(DELIVERY_ID IN NUMBER
                          ,ORDER_HEADER_ID IN NUMBER
                          ,ORDER_LINE_ID IN NUMBER
                          ,QUANTITY IN NUMBER
                          ,CF_SET_OF_BOOKS_ID IN NUMBER
                          ,CF_FUN_CURR IN VARCHAR2) RETURN CHAR;

  FUNCTION CF_SET_OF_BOOKS_IDFORMULA RETURN NUMBER;

  FUNCTION CF_FUN_CURRFORMULA(CF_SET_OF_BOOKS_ID IN NUMBER) RETURN CHAR;

  FUNCTION CF_PACKINGFORMULA RETURN CHAR;

  FUNCTION CF_FUNC_TAX_AMOUNTFORMULA(DELIVERY_ID IN NUMBER
                                    ,INVENTORY_ITEM_ID IN NUMBER) RETURN NUMBER;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION CF_BALANCESFORMULA(ORDER_HEADER_ID IN NUMBER
                             ,REGISTER_ID IN NUMBER
                             ,ORDER_LINE_ID IN NUMBER
                             ,CUSTOMER_TRX_ID IN NUMBER
                             ,DELIVERY_ID IN NUMBER
                             ,TRX_NUMBER IN VARCHAR2) RETURN NUMBER;

  FUNCTION CP_CLOSING_BAL_P RETURN NUMBER;

  FUNCTION CP_DEBIT_AMOUNT_P RETURN NUMBER;

  FUNCTION CP_OPENING_BAL_P RETURN NUMBER;

  FUNCTION CP_NULL_P RETURN VARCHAR2;

  FUNCTION CP_EXCISE_CESS_AMOUNT_P RETURN NUMBER;

  FUNCTION CP_EXCISE_SH_CESS_AMOUNT_P RETURN NUMBER;

END JA_JAINARE1_XMLP_PKG;



/
