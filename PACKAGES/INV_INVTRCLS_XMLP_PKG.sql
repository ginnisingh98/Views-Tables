--------------------------------------------------------
--  DDL for Package INV_INVTRCLS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_INVTRCLS_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: INVTRCLSS.pls 120.1 2007/12/25 11:06:35 dwkrishn noship $ */
  P_ORG_ID NUMBER;
  P_CONC_REQUEST_ID NUMBER := 0;
  P_STRUCT_NUM NUMBER;
  P_CONDITION VARCHAR2(40);
  P_SORT_ID NUMBER;
  P_CLOSE_DATE DATE;
  P_CLOSE_DATE_T VARCHAR2(40);
  C_STD_PRECISION VARCHAR2(40);
  FUNCTION BEFOREREPORT RETURN BOOLEAN;
  FUNCTION AFTERREPORT RETURN BOOLEAN;
  FUNCTION C_CURRENCY_CODEFORMULA(R_CURRENCY_CODE IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION C_ORDER_BYFORMULA RETURN VARCHAR2;
END INV_INVTRCLS_XMLP_PKG;


/