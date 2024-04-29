--------------------------------------------------------
--  DDL for Package INV_INVORGES_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_INVORGES_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: INVORGESS.pls 120.1 2007/12/25 10:44:01 dwkrishn noship $ */
  P_CONC_REQUEST_ID NUMBER;

  P_LEGAL_ENTITY_NAME VARCHAR2(240);

  CP_RESPONSIBILITY VARCHAR2(200);

  CP_REQUEST_TIME VARCHAR2(30);

  CP_APPLICATION VARCHAR2(240);

  CP_REQUESTED_BY VARCHAR2(100);

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION CP_RESPONSIBILITY_P RETURN VARCHAR2;

  FUNCTION CP_REQUEST_TIME_P RETURN VARCHAR2;

  FUNCTION CP_APPLICATION_P RETURN VARCHAR2;

  FUNCTION CP_REQUESTED_BY_P RETURN VARCHAR2;

END INV_INVORGES_XMLP_PKG;


/
