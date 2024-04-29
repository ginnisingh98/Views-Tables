--------------------------------------------------------
--  DDL for Package PQH_PQHUSNRW_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_PQHUSNRW_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PQHUSNRWS.pls 120.1 2007/12/07 06:56:56 vjaganat noship $ */
  P_BUSINESS_GROUP_ID NUMBER;

  P_CONC_REQUEST_ID NUMBER;

  P_PERSON_ID NUMBER;

  P_NOTIFICATION_TYPE VARCHAR2(32767);

  P_START_DATE DATE;

  P_END_DATE DATE;

  P_START_DATE_T VARCHAR2(40);

  P_END_DATE_T VARCHAR2(40);

  CP_BUSINESS_GROUP_NAME VARCHAR2(240);

  CP_BODY_TEXT1 VARCHAR2(2000);

  CP_FACULTY_MEMBER_NAME VARCHAR2(240);

  CP_FACULTY_MEMBER_EMAIL VARCHAR2(240);

  CP_FACULTY_MEMBER_ADDRESS VARCHAR2(1000);

  CP_FACULTY_MEMBER_TITLE VARCHAR2(240);

  CP_ACADEMIC_MANAGER_NAME VARCHAR2(240);

  CP_ACADEMIC_MANAGER_EMAIL VARCHAR2(240);

  CP_ACADEMIC_MANAGER_ADDRESS VARCHAR2(1000);

  CP_LOGGED_USER_NAME VARCHAR2(240);

  CP_CONTRACT_START_DATE VARCHAR2(20);

  CP_FACULTY_MEMBER_LNAME VARCHAR2(150);

  CP_REGARDS VARCHAR2(100);

  CP_BODY_TEXT2 VARCHAR2(2000);

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION CP_BUSINESS_GROUP_NAME_P RETURN VARCHAR2;

  FUNCTION CP_BODY_TEXT1_P RETURN VARCHAR2;

  FUNCTION CP_FACULTY_MEMBER_NAME_P RETURN VARCHAR2;

  FUNCTION CP_FACULTY_MEMBER_EMAIL_P RETURN VARCHAR2;

  FUNCTION CP_FACULTY_MEMBER_ADDRESS_P RETURN VARCHAR2;

  FUNCTION CP_FACULTY_MEMBER_TITLE_P RETURN VARCHAR2;

  FUNCTION CP_ACADEMIC_MANAGER_NAME_P RETURN VARCHAR2;

  FUNCTION CP_ACADEMIC_MANAGER_EMAIL_P RETURN VARCHAR2;

  FUNCTION CP_ACADEMIC_MANAGER_ADDRESS_P RETURN VARCHAR2;

  FUNCTION CP_LOGGED_USER_NAME_P RETURN VARCHAR2;

  FUNCTION CP_CONTRACT_START_DATE_P RETURN VARCHAR2;

  FUNCTION CP_FACULTY_MEMBER_LNAME_P RETURN VARCHAR2;

  FUNCTION CP_REGARDS_P RETURN VARCHAR2;

  FUNCTION CP_BODY_TEXT2_P RETURN VARCHAR2;

  FUNCTION_DESC VARCHAR2(240);

  FUNCTION GET_BUSINESS_GROUP(P_BUSINESS_GROUP_ID IN NUMBER) RETURN VARCHAR2;

END PQH_PQHUSNRW_XMLP_PKG;

/