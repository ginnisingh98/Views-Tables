--------------------------------------------------------
--  DDL for Package PSB_PSBRPWDS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_PSBRPWDS_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PSBRPWDSS.pls 120.0 2008/01/07 10:53:46 vijranga noship $ */
  P_BUDGET_GROUP_ID NUMBER;

  P_SET_OF_BOOKS_ID NUMBER;

  P_DISTRIBUTION_RULE_ID NUMBER;

  P_CONC_REQUEST_ID NUMBER;

  CP_DISTRIBUTION_RULE_ID NUMBER;

  CP_SET_OF_BOOKS_NAME VARCHAR2(30);

  CP_TOP_BUDGET_GROUP_NAME VARCHAR2(50);

  CP_NO_DATA_FOUND VARCHAR2(50);

  CP_END_OF_REPORT VARCHAR2(50);

  CP_DISTRIBUTION_RULE_NAME VARCHAR2(30);

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION BETWEENPAGE RETURN BOOLEAN;

  FUNCTION BEFOREPFORM RETURN BOOLEAN;

  FUNCTION CF_DISTRIBUTION_RULE_IDFORMULA(RULE_ID IN NUMBER) RETURN NUMBER;

  FUNCTION AFTERPFORM RETURN BOOLEAN;

  FUNCTION CP_DISTRIBUTION_RULE_ID_P RETURN NUMBER;

  FUNCTION CP_SET_OF_BOOKS_NAME_P RETURN VARCHAR2;

  FUNCTION CP_TOP_BUDGET_GROUP_NAME_P RETURN VARCHAR2;

  FUNCTION CP_NO_DATA_FOUND_P RETURN VARCHAR2;

  FUNCTION CP_END_OF_REPORT_P RETURN VARCHAR2;

  FUNCTION CP_DISTRIBUTION_RULE_NAME_P RETURN VARCHAR2;

END PSB_PSBRPWDS_XMLP_PKG;






/