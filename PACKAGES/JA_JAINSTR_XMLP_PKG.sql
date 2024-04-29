--------------------------------------------------------
--  DDL for Package JA_JAINSTR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JA_JAINSTR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: JAINSTRS.pls 120.1 2007/12/25 16:32:09 dwkrishn noship $ */
  P_CONC_REQUEST_ID NUMBER;

  P_ORG_ID NUMBER;

  P_PRIMARY_REGNO VARCHAR2(240);

  P_FROM_DATE DATE;

  P_TO_DATE DATE;

   LP_FROM_DATE varchar2(25);

  LP_TO_DATE varchar2(25);

  P_DEBUG_FLAG VARCHAR2(1);

  P_LOCATION_ID NUMBER;

  CP_GROSS_INVOICE_AMOUNT NUMBER;

  CP_TAXABLE_BASIS NUMBER;

  CP_SERVICE_TAX_AMOUNT NUMBER;

  CP_CESS_AMOUNT NUMBER;

  CP_SERVICE_TAX_PAY NUMBER;

  CP_SH_CESS_AMOUNT NUMBER;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION CF_RECEIPT_AMOUNTFORMULA(INVOICE_ID IN NUMBER) RETURN NUMBER;

  FUNCTION CF_1FORMULA(INVOICE_ID_1 IN NUMBER
                      ,ORG_ID1 IN NUMBER
                      ,SERVICE_BASIS IN NUMBER
                      ,SERVICE_REC_AMOUNT IN NUMBER
                      ,CESS_REC_AMOUNT IN NUMBER
                      ,SERVICE_PAYABLE_AMOUNT IN NUMBER
                      ,CESS_PAYABLE_AMOUNT IN NUMBER) RETURN CHAR;

  FUNCTION CF_SERVICE_TYPEFORMULA(SERVICE_REF_ID IN NUMBER) RETURN CHAR;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION P_TO_DATEVALIDTRIGGER RETURN BOOLEAN;

  FUNCTION CP_GROSS_INVOICE_AMOUNT_P RETURN NUMBER;

  FUNCTION CP_TAXABLE_BASIS_P RETURN NUMBER;

  FUNCTION CP_SERVICE_TAX_AMOUNT_P RETURN NUMBER;

  FUNCTION CP_CESS_AMOUNT_P RETURN NUMBER;

  FUNCTION CP_SERVICE_TAX_PAY_P RETURN NUMBER;

  FUNCTION CP_SH_CESS_AMOUNT_P RETURN NUMBER;

END JA_JAINSTR_XMLP_PKG;



/