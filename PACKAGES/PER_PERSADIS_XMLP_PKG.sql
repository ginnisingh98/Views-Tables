--------------------------------------------------------
--  DDL for Package PER_PERSADIS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PERSADIS_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PERSADISS.pls 120.0 2007/12/24 13:21:04 amakrish noship $ */
  P_BUSINESS_GROUP_ID NUMBER;

  P_CONC_REQUEST_ID NUMBER;

  L_ORG_CONDITION VARCHAR2(2000);

  L_TYPE_CONDITION VARCHAR2(2000);

  P_DISABILITY_TYPE VARCHAR2(40);

  P_DATE DATE;
/*added as fix*/
  P_DATE_T DATE;
  P_ORG_ID NUMBER;

  L_EMP_OFFICE_CONDITION VARCHAR2(2000);

  P_EMP_OFFICE VARCHAR2(30);

  P_ORG_STRUCTURE_ID NUMBER;

  P_ORG_STRUCTURE_VERSION_ID NUMBER;

  P_DISABILITY_STATUS VARCHAR2(40);

  L_STATUS_CONDITION VARCHAR2(2000);

  CP_1 NUMBER := 0;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION CF_BUSINESS_GROUPFORMULA RETURN VARCHAR2;

  FUNCTION CF_LEGISLATION_CODEFORMULA RETURN VARCHAR2;

  FUNCTION CF_CURRENCY_FORMAT_MASKFORMULA(CF_LEGISLATION_CODE IN VARCHAR2) RETURN VARCHAR2;

  PROCEDURE SET_CURRENCY_FORMAT_MASK;

  FUNCTION P_BUSINESS_GROUP_IDVALIDTRIGGE RETURN BOOLEAN;

  FUNCTION CF_ORGFORMULA RETURN CHAR;

  FUNCTION CF_DIS_TYPEFORMULA RETURN CHAR;

  FUNCTION AFTERPFORM RETURN BOOLEAN;

  FUNCTION CF_EMP_OFFICEFORMULA RETURN CHAR;

  FUNCTION CF_1FORMULA RETURN NUMBER;

  FUNCTION CF_HIERARCHYFORMULA RETURN CHAR;

  FUNCTION CF_VERSIONFORMULA RETURN NUMBER;

  FUNCTION CF_DIS_STATUSFORMULA RETURN CHAR;

  FUNCTION CP_1_P RETURN NUMBER;

END PER_PERSADIS_XMLP_PKG;

/
