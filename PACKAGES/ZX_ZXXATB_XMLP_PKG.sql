--------------------------------------------------------
--  DDL for Package ZX_ZXXATB_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_ZXXATB_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: ZXXATBS.pls 120.1.12010000.1 2008/07/28 13:27:58 appldev ship $ */
  P_CONC_REQUEST_ID NUMBER := 0;

  P_ORDER_BY VARCHAR2(50);

  P_SET_OF_BOOKS_ID NUMBER;

  P_CURRENCY_CODE VARCHAR2(32767);

  P_START_TRX_DATE DATE;

  P_END_TRX_DATE DATE;

  LP_START_TRX_DATE VARCHAR2(500);

  LP_END_TRX_DATE VARCHAR2(500);

  P_REPORTING_LEVEL VARCHAR2(32767);

  P_REPORTING_CONTEXT VARCHAR2(32767);

  LP_REP_CONTEXT_WH VARCHAR2(2000);

  P_TAX_INVOICE_DATE_LOW DATE;

  P_TAX_INVOICE_DATE_HIGH DATE;

  P_SOB_ID NUMBER;

  RP_COMPANY_NAME VARCHAR2(50);

  RP_REPORT_NAME VARCHAR2(80);

  RP_DATA_FOUND VARCHAR2(300);

  RP_REPORT_CURRENCY VARCHAR2(20);

  RP_TRX_DATE VARCHAR2(100);

  RPD_AMOUNT_OUTSTANDING VARCHAR2(17);

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION REPORT_NAMEFORMULA(FUNCTIONAL_CURRENCY IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION C_DATA_NOT_FOUNDFORMULA(INVOICE_NUMBER IN VARCHAR2) RETURN NUMBER;

  FUNCTION AFTERPFORM RETURN BOOLEAN;

  FUNCTION RP_COMPANY_NAME_P RETURN VARCHAR2;

  FUNCTION RP_REPORT_NAME_P RETURN VARCHAR2;

  FUNCTION RP_DATA_FOUND_P RETURN VARCHAR2;

  FUNCTION RP_REPORT_CURRENCY_P RETURN VARCHAR2;

  FUNCTION RP_TRX_DATE_P RETURN VARCHAR2;

  FUNCTION RPD_AMOUNT_OUTSTANDING_P RETURN VARCHAR2;

END ZX_ZXXATB_XMLP_PKG;


/
