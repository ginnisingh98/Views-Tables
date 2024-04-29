--------------------------------------------------------
--  DDL for Package JL_JLARPCFF_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_JLARPCFF_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: JLARPCFFS.pls 120.1 2007/12/25 16:33:21 dwkrishn noship $ */
  P_BOOK_TYPE_CODE VARCHAR2(40);

  P_CONC_REQUEST_ID NUMBER := 0;

  P_START_DATE DATE;

  P_END_DATE DATE;

  P_TAX_TYPE VARCHAR2(25);

  P_TRANSACTION_LETTER_FROM VARCHAR2(30);

  P_TRANSACTION_LETTER_TO VARCHAR2(30);

  P_LEGAL_ENTITY_ID NUMBER;

  P_LEGAL_ENTITY_NAME VARCHAR2(240);

  P_REPORTING_ENTITY_ID NUMBER;

  P_REPORTING_LEVEL VARCHAR2(32767);

  P_RETCODE VARCHAR2(32767);

  P_SET_OF_BOOKS_ID NUMBER;

  P_ERRBUF VARCHAR2(2000);

  C_ORGANISATION_NAME VARCHAR2(30);

  C_BASE_MIN_ACCT_UNIT NUMBER;

  C_BASE_CURRENCY_CODE VARCHAR2(15);

  C_BASE_PRECISION NUMBER := 2;

  C_BASE_DESCRIPTION VARCHAR2(240);

  PROCEDURE GET_BASE_CURR_DATA;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  PROCEDURE RAISE_ORA_ERR(ERRNO IN VARCHAR2);

  PROCEDURE RAISE_ERR(ERRNO IN VARCHAR2
                     ,MSGNAME IN VARCHAR2);

  FUNCTION CF_ACC_DATEFORMULA(INVOICE_ID IN NUMBER
                             ,TAX_RATE_ID IN NUMBER) RETURN DATE;

  FUNCTION CF_CITI_RECFORMULA(CF_ACC_DATE IN DATE
                             ,CF_TAX_AMOUNT IN NUMBER
                             ,DOCUMENT_TYPE IN VARCHAR2
                             ,DOCUMENT_NUM IN VARCHAR2
                             ,DOCUMENT_DATE IN DATE
                             ,CUIT_NUMBER IN VARCHAR2
                             ,SUP_NAME IN VARCHAR2) RETURN CHAR;

  FUNCTION CF_TAX_AMOUNTFORMULA(TAX_AMOUNT IN NUMBER) RETURN NUMBER;

  FUNCTION CF_SPACEFORMULA RETURN VARCHAR2;

  FUNCTION POPULATE_TRL RETURN BOOLEAN;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION C_ORGANISATION_NAME_P RETURN VARCHAR2;

  FUNCTION C_BASE_MIN_ACCT_UNIT_P RETURN NUMBER;

  FUNCTION C_BASE_CURRENCY_CODE_P RETURN VARCHAR2;

  FUNCTION C_BASE_PRECISION_P RETURN NUMBER;

  FUNCTION C_BASE_DESCRIPTION_P RETURN VARCHAR2;

END JL_JLARPCFF_XMLP_PKG;



/