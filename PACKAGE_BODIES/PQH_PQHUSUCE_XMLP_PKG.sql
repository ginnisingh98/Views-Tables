--------------------------------------------------------
--  DDL for Package Body PQH_PQHUSUCE_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_PQHUSUCE_XMLP_PKG" AS
/* $Header: PQHUSUCEB.pls 120.2 2007/12/07 06:59:03 vjaganat noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
    L_EMPID VARCHAR2(240);
    L_LNAME VARCHAR2(150);
    L_TITLE VARCHAR2(240);
    L_EMAIL VARCHAR2(240);
    L_BODY_TEXT2 VARCHAR2(20);
    L_BODY_TEXT3 VARCHAR2(20);
    L_BODY_TEXT4 VARCHAR2(20);
    L_BODY_TEXT5 VARCHAR2(20);
    L_BODY_TEXT6 VARCHAR2(20);
    L_BODY_TEXT7 VARCHAR2(20);
    L_BODY_TEXT8 VARCHAR2(20);
    L_REGARDS VARCHAR2(100);
    L_HIREDATE DATE;
    L_MANAGER_ID NUMBER;
  BEGIN
    --HR_STANDARD.EVENT('BEFORE REPORT');
    CP_BUSINESS_GROUP_NAME := GET_BUSINESS_GROUP(P_BUSINESS_GROUP_ID);
    L_MANAGER_ID := PQH_TENURE_DETAIL.GETPERSONSUPERVISOR(P_PERSON_ID);
    PQH_TENURE_DETAIL.GETPERSONINFO(P_PERSON_ID
                                   ,CP_EMPLOYEE_ID
                                   ,CP_FACULTY_MEMBER_NAME
                                   ,L_LNAME
                                   ,L_TITLE
                                   ,L_EMAIL
                                   ,L_HIREDATE);
    PQH_TENURE_DETAIL.GETPERSONINFO(L_MANAGER_ID
                                   ,L_EMPID
                                   ,CP_ACADEMIC_MANAGER_NAME
                                   ,L_LNAME
                                   ,L_TITLE
                                   ,L_EMAIL
                                   ,L_HIREDATE);
    PQH_TENURE_DETAIL.GETREPORTBODYTEXT('CE'
                                       ,L_REGARDS
                                       ,CP_BODY_TEXT
                                       ,L_BODY_TEXT2
                                       ,L_BODY_TEXT3
                                       ,L_BODY_TEXT4
                                       ,L_BODY_TEXT5
                                       ,L_BODY_TEXT6
                                       ,L_BODY_TEXT7
                                       ,L_BODY_TEXT8);
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    --HR_STANDARD.EVENT('AFTER REPORT');
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION CP_BUSINESS_GROUP_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_BUSINESS_GROUP_NAME;
  END CP_BUSINESS_GROUP_NAME_P;

  FUNCTION CP_BODY_TEXT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_BODY_TEXT;
  END CP_BODY_TEXT_P;

  FUNCTION CP_FACULTY_MEMBER_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_FACULTY_MEMBER_NAME;
  END CP_FACULTY_MEMBER_NAME_P;

  FUNCTION CP_ACADEMIC_MANAGER_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_ACADEMIC_MANAGER_NAME;
  END CP_ACADEMIC_MANAGER_NAME_P;

  FUNCTION CP_EMPLOYEE_ID_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_EMPLOYEE_ID;
  END CP_EMPLOYEE_ID_P;

  FUNCTION GET_BUSINESS_GROUP(P_BUSINESS_GROUP_ID IN NUMBER) RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
    X0 := HR_REPORTS.GET_BUSINESS_GROUP(P_BUSINESS_GROUP_ID);
    RETURN X0;
  END GET_BUSINESS_GROUP;

END PQH_PQHUSUCE_XMLP_PKG;

/
