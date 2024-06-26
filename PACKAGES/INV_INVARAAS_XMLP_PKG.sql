--------------------------------------------------------
--  DDL for Package INV_INVARAAS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_INVARAAS_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: INVARAASS.pls 120.1 2007/12/25 09:57:43 dwkrishn noship $ */
  P_SORT_ID VARCHAR2(40);
  ORG_ID VARCHAR2(40);
  GROUP_ID VARCHAR2(40);
  SORT_ORDER_CLAUSE VARCHAR2(40);
  P_CONC_REQUEST_ID NUMBER := 0;
  P_QTY_PRECISION NUMBER;
  P_CBO_FLAG NUMBER;
  P_TRACE_FLAG NUMBER;
  FUNCTION C_ORDERBYFORMULA RETURN VARCHAR2;
  FUNCTION C_FORMATTEDCURRENCYCODEFORMULA(CURRENCY_CODE IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION BEFOREREPORT RETURN BOOLEAN;
  FUNCTION AFTERREPORT RETURN BOOLEAN;
  FUNCTION AFTERPFORM RETURN BOOLEAN;
  qty_precision varchar2(100);
END INV_INVARAAS_XMLP_PKG;


/
