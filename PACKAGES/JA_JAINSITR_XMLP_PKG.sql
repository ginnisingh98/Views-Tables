--------------------------------------------------------
--  DDL for Package JA_JAINSITR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JA_JAINSITR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: JAINSITRS.pls 120.1 2007/12/25 16:28:52 dwkrishn noship $ */
  CUSTOMERS NUMBER;

  SUPPLEMENTARY_TYPE VARCHAR2(40);

  INVOICE_NO VARCHAR2(40);

  SITE_USE_ID NUMBER;

  PROCESS_DATE DATE;

  P_CONC_REQUEST_ID NUMBER;

  SERIAL_NUMBER NUMBER;

  FUNCTION SERIAL_FFORMULA RETURN NUMBER;

  FUNCTION EXCISE_TAXFORMULA(L_CUSTOMER_TRX_ID IN NUMBER
                            ,L_SUPP_INV_TYPE IN VARCHAR2) RETURN NUMBER;

  FUNCTION CF_5FORMULA(L_CUSTOMER_TRX_ID IN NUMBER
                      ,L_SUPP_INV_TYPE IN VARCHAR2) RETURN NUMBER;

  FUNCTION CSTFORMULA(L_CUSTOMER_TRX_ID IN NUMBER
                     ,L_SUPP_INV_TYPE IN VARCHAR2) RETURN NUMBER;

  FUNCTION OTHERS_FORMULA(L_CUSTOMER_TRX_ID IN NUMBER
                         ,L_SUPP_INV_TYPE IN VARCHAR2) RETURN NUMBER;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION SERIAL_NUMBER_P RETURN NUMBER;

END JA_JAINSITR_XMLP_PKG;



/