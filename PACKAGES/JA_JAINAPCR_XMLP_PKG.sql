--------------------------------------------------------
--  DDL for Package JA_JAINAPCR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JA_JAINAPCR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: JAINAPCRS.pls 120.1 2007/12/25 16:11:27 dwkrishn noship $ */
  P_FROM_DATE DATE;
  P_FROM_DATE_V VARCHAR2(11);
  P_TO_DATE DATE;
  P_TO_DATE_V VARCHAR2(11);
  P_VENDOR_ID NUMBER;
  P_VENDOR_NO VARCHAR2(40);
  P_VENDOR_TYPE_LOOKUP_CODE VARCHAR2(25);
  P_CHART_OF_ACCTS_ID NUMBER;
  P_ORG_ID NUMBER;
  P_VENDOR_SITE_ID NUMBER;
  P_CONC_REQUEST_ID NUMBER;
  P_VENDOR_SITE_CODE2 VARCHAR2(15);
  P_ORG_ID1 NUMBER;
  P_SEGMENT2 NUMBER;
  FUNCTION CF_PO_NOFORMULA(P_PO_DISTRIBUTION_ID IN NUMBER) RETURN VARCHAR2;
  FUNCTION CF_ORGNFORMULA(P_PO_DISTRIBUTION_ID IN NUMBER) RETURN VARCHAR2;
  FUNCTION CF_LOCNFORMULA(P_PO_DISTRIBUTION_ID IN NUMBER) RETURN VARCHAR2;
  FUNCTION CF_DR_REFORMULA(ORG_ID IN NUMBER
                          ,INVOICE_TYPE_LOOKUP_CODE IN VARCHAR2
                          ,ACCT_DR IN NUMBER
                          ,EXCHANGE_RATE_TYPE IN VARCHAR2
                          ,INVOICE_CURRENCY_CODE IN VARCHAR2
                          ,EXCHANGE_DATE IN DATE
                          ,EXCHANGE_RATE IN NUMBER
                          ,DR_VAL IN NUMBER) RETURN NUMBER;
  FUNCTION CF_CR_REFORMULA(ORG_ID IN NUMBER
                          ,INVOICE_TYPE_LOOKUP_CODE IN VARCHAR2
                          ,ACCT_CR IN NUMBER
                          ,EXCHANGE_RATE_TYPE IN VARCHAR2
                          ,INVOICE_CURRENCY_CODE IN VARCHAR2
                          ,EXCHANGE_DATE IN DATE
                          ,EXCHANGE_RATE IN NUMBER
                          ,CR_VAL IN NUMBER) RETURN NUMBER;
  FUNCTION CF_BATCHFORMULA(P_BATCH_ID IN NUMBER) RETURN VARCHAR2;
  FUNCTION CF_ADDRFORMULA(P_INVOICE_NUM IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION CF_ACCOUNTFORMULA(CCID IN NUMBER) RETURN VARCHAR2;
  FUNCTION DEBIT_BALANCE(CAL_DATE IN DATE) RETURN NUMBER;
  FUNCTION CREDIT_BALANCE(CAL_DATE IN DATE) RETURN NUMBER;
  FUNCTION CF_V_NAMEFORMULA RETURN VARCHAR2;
  FUNCTION CF_P_SOBFORMULA RETURN VARCHAR2;
  FUNCTION CF_TOTAL_CRFORMULA(VENDOR_SITE_CODE2 IN VARCHAR2
                             ,SEGMENT2 IN VARCHAR2
                             ,ORG_ID1 IN NUMBER) RETURN NUMBER;
  FUNCTION CF_TOTAL_DRFORMULA(VENDOR_SITE_CODE2 IN VARCHAR2
                             ,SEGMENT2 IN VARCHAR2
                             ,ORG_ID1 IN NUMBER) RETURN NUMBER;
  FUNCTION CF_CLOSING_BAL_CRFORMULA0070(VENDOR_SITE_CODE2 IN VARCHAR2
                                       ,SEGMENT2 IN VARCHAR2
                                       ,ORG_ID1 IN NUMBER) RETURN NUMBER;
  FUNCTION CF_CLOSING_BAL_DRFORMULA0072(VENDOR_SITE_CODE2 IN VARCHAR2
                                       ,SEGMENT2 IN VARCHAR2
                                       ,ORG_ID1 IN NUMBER) RETURN NUMBER;
  FUNCTION CF_TOTAL_CR1FORMULA(CF_TOTAL_CR IN NUMBER
                              ,CF_TOTAL_DR IN NUMBER) RETURN NUMBER;
  FUNCTION CF_TOTAL_DR1FORMULA(CF_TOTAL_DR IN NUMBER
                              ,CF_TOTAL_CR IN NUMBER) RETURN NUMBER;
  FUNCTION CF_CLOSING_BAL_CR1FORMULA0076(CF_CLOSING_BAL_CR IN NUMBER
                                        ,CF_CLOSING_BAL_DR IN NUMBER) RETURN NUMBER;
  FUNCTION CF_CLOSING_BAL_DR1FORMULA0078(CF_CLOSING_BAL_DR IN NUMBER
                                        ,CF_CLOSING_BAL_CR IN NUMBER) RETURN NUMBER;
  FUNCTION CF_1FORMULA(CF_TOTAL_CR1 IN NUMBER
                      ,CS_2 IN NUMBER
                      ,CS_1 IN NUMBER
                      ,CF_TOTAL_DR1 IN NUMBER) RETURN NUMBER;
  FUNCTION CF_2FORMULA(CS_3 IN NUMBER
                      ,CS_4 IN NUMBER) RETURN NUMBER;
  FUNCTION BEFOREREPORT RETURN BOOLEAN;
  FUNCTION AFTERREPORT RETURN BOOLEAN;
END JA_JAINAPCR_XMLP_PKG;



/