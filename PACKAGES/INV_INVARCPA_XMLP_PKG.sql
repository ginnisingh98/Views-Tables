--------------------------------------------------------
--  DDL for Package INV_INVARCPA_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_INVARCPA_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: INVARCPAS.pls 120.1 2007/12/25 10:01:45 dwkrishn noship $ */
  P_CONC_REQUEST_ID NUMBER := 0;

  ORGANIZATION_ID VARCHAR2(40);

  P_SORT_OPTION NUMBER;

  P_QTY_PRECISION NUMBER;

  P_LOCATOR_STRUC_NUM NUMBER;

  P_LOCATOR_FLEXSQL VARCHAR2(1000);

  P_HEADERID NUMBER;

  P_CBO_FLAG NUMBER;

  P_TRACE_FLAG NUMBER;

  P_SERIAL_DISPLAY NUMBER;

  P_WMS_INSTALLED VARCHAR2(6) := 'FALSE';

  FUNCTION C_FORMATTEDCURRENCYCODEFORMULA(CURRENCY_CODE IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION C_ORDERBYFORMULA RETURN VARCHAR2;

  FUNCTION AFTERPFORM RETURN BOOLEAN;

  FUNCTION CF_OUTERMOST_LPNFORMULA(CONTAINER_ENABLED_FLAG IN NUMBER
                                  ,OUTERMOST_LPN_ID IN NUMBER) RETURN CHAR;

  FUNCTION CF_PARENT_LPNFORMULA(CONTAINER_ENABLED_FLAG IN NUMBER
                               ,PARENT_LPN_ID IN NUMBER) RETURN CHAR;

  FUNCTION CF_COST_GROUPFORMULA(COST_GROUP_ID IN NUMBER) RETURN CHAR;

END INV_INVARCPA_XMLP_PKG;


/
