--------------------------------------------------------
--  DDL for Package PQH_PQHUSUCE_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_PQHUSUCE_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PQHUSUCES.pls 120.1 2007/12/07 06:58:50 vjaganat noship $ */
  P_BUSINESS_GROUP_ID NUMBER;

  P_CONC_REQUEST_ID NUMBER;

  P_PERSON_ID NUMBER;

  CP_BUSINESS_GROUP_NAME VARCHAR2(240);

  CP_BODY_TEXT VARCHAR2(2000);

  CP_FACULTY_MEMBER_NAME VARCHAR2(240);

  CP_ACADEMIC_MANAGER_NAME VARCHAR2(240);

  CP_EMPLOYEE_ID VARCHAR2(22);

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION CP_BUSINESS_GROUP_NAME_P RETURN VARCHAR2;

  FUNCTION CP_BODY_TEXT_P RETURN VARCHAR2;

  FUNCTION CP_FACULTY_MEMBER_NAME_P RETURN VARCHAR2;

  FUNCTION CP_ACADEMIC_MANAGER_NAME_P RETURN VARCHAR2;

  FUNCTION CP_EMPLOYEE_ID_P RETURN VARCHAR2;

  FUNCTION_DESC VARCHAR2(240);

  FUNCTION GET_BUSINESS_GROUP(P_BUSINESS_GROUP_ID IN NUMBER) RETURN VARCHAR2;

END PQH_PQHUSUCE_XMLP_PKG;

/