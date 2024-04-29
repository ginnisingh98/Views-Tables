--------------------------------------------------------
--  DDL for Package QA_QLTPLCHR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_QLTPLCHR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: QLTPLCHRS.pls 120.0 2007/12/24 10:37:17 krreddy noship $ */
  P_ORGANIZATION_ID NUMBER;

  P_PLAN_TYPE_DESC_LIMITER VARCHAR2(1000) := ' ';

  P_PLAN_TYPE_DESC VARCHAR2(250);

  P_PLAN_LIMITER VARCHAR2(1000) := ' ';

  P_PLAN VARCHAR2(30);

  P_PLAN_ENABLED VARCHAR2(30);

  P_PLAN_ENABLED_LIMITER VARCHAR2(1000) := ' ';

  P_ORG_LIMITER VARCHAR2(1000) := ' ';

  P_PLAN_ENABLED_FLAG NUMBER;

  P_PLAN_ENABLED_MEANING VARCHAR2(80);

  P_PLAN_TYPE_MEANING VARCHAR2(80);

  P_CONC_REQUEST_ID NUMBER;

  FUNCTION C_DEFAULT_VALUE_NUMFORMULA(DATATYPE_NUM IN NUMBER
                                     ,DEFAULT_VALUE IN VARCHAR2) RETURN NUMBER;

  FUNCTION P_PLANVALIDTRIGGER RETURN BOOLEAN;

  FUNCTION AFTERPFORM RETURN BOOLEAN;

  FUNCTION TRANSLLATE(ENABLED_MEANING IN VARCHAR2) RETURN NUMBER;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

END QA_QLTPLCHR_XMLP_PKG;


/