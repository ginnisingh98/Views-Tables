--------------------------------------------------------
--  DDL for Package Body PQH_PQHUSNTT_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_PQHUSNTT_XMLP_PKG" AS
/* $Header: PQHUSNTTB.pls 120.1 2007/12/07 06:57:22 vjaganat noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
    L_LNAME VARCHAR2(150);
    L_TITLE VARCHAR2(240);
    L_EMPID VARCHAR2(30);
    L_TENURE_STATUS VARCHAR2(50);
    L_COMPLETE_YEAR VARCHAR2(2);
    L_COMPLETE_MONTH VARCHAR2(2);
    L_STATUS_DATE VARCHAR2(50);
    L_TENURE_DATE VARCHAR2(50);
    L_REMAIN_YEAR VARCHAR2(2);
    L_REMAIN_MONTH VARCHAR2(2);
    L_BODY_TEXT5 VARCHAR2(2);
    L_BODY_TEXT6 VARCHAR2(2);
    L_BODY_TEXT7 VARCHAR2(2);
    L_BODY_TEXT8 VARCHAR2(2);
    L_HIREDATE DATE;
    L_MANAGER_ID NUMBER;
  BEGIN
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    CP_BUSINESS_GROUP_NAME := GET_BUSINESS_GROUP(P_BUSINESS_GROUP_ID);
    CP_LOGGED_USER_NAME := FND_PROFILE.VALUE('USERNAME');
    L_MANAGER_ID := PQH_TENURE_DETAIL.GETPERSONSUPERVISOR(P_PERSON_ID);
    CP_ACADEMIC_MANAGER_ADDRESS := PQH_TENURE_DETAIL.GETPERSONADDRESS(L_MANAGER_ID
                                                                     ,P_BUSINESS_GROUP_ID);
    CP_FACULTY_MEMBER_ADDRESS := PQH_TENURE_DETAIL.GETPERSONADDRESS(P_PERSON_ID
                                                                   ,P_BUSINESS_GROUP_ID);
    PQH_TENURE_DETAIL.GETPERSONINFO(P_PERSON_ID
                                   ,L_EMPID
                                   ,CP_FACULTY_MEMBER_NAME
                                   ,CP_FACULTY_MEMBER_LNAME
                                   ,CP_FACULTY_MEMBER_TITLE
                                   ,CP_FACULTY_MEMBER_EMAIL
                                   ,CP_CONTRACT_START_DATE);
    PQH_TENURE_DETAIL.GETPERSONINFO(L_MANAGER_ID
                                   ,L_EMPID
                                   ,CP_ACADEMIC_MANAGER_NAME
                                   ,L_LNAME
                                   ,L_TITLE
                                   ,CP_ACADEMIC_MANAGER_EMAIL
                                   ,L_HIREDATE);
    PQH_TENURE_DETAIL.GETREPORTBODYTEXT('TT'
                                       ,CP_REGARDS
                                       ,CP_BODY_TEXT1
                                       ,CP_BODY_TEXT2
                                       ,CP_BODY_TEXT3
                                       ,CP_BODY_TEXT4
                                       ,L_BODY_TEXT5
                                       ,L_BODY_TEXT6
                                       ,L_BODY_TEXT7
                                       ,L_BODY_TEXT8);
    PQH_TENURE_DETAIL.GETPERSONTENURE(P_PERSON_ID
                                     ,L_TENURE_STATUS
                                     ,L_STATUS_DATE
                                     ,L_TENURE_DATE
                                     ,L_REMAIN_YEAR
                                     ,L_REMAIN_MONTH
                                     ,L_COMPLETE_YEAR
                                     ,L_COMPLETE_MONTH);
    CP_BODY_TEXT1 := REPLACE(CP_BODY_TEXT1
                            ,'COLLEGE_UNIVERSITY_NAME'
                            ,CP_BUSINESS_GROUP_NAME);
    CP_BODY_TEXT2 := REPLACE(CP_BODY_TEXT2
                            ,'TENURE_DATE'
                            ,L_TENURE_DATE);
    CP_BODY_TEXT2 := REPLACE(CP_BODY_TEXT2
                            ,'MIN_SERVICE_YEARS'
                            ,L_REMAIN_YEAR);
    CP_BODY_TEXT2 := REPLACE(CP_BODY_TEXT2
                            ,'MIN_SERVICE_MONTHS'
                            ,L_REMAIN_MONTH);
    CP_BODY_TEXT4 := REPLACE(CP_BODY_TEXT4
                            ,'COLLEGE_UNIVERSITY_NAME'
                            ,CP_BUSINESS_GROUP_NAME);

    CP_BODY_TEXT1 := REPLACE(CP_BODY_TEXT1
                            ,fnd_global.local_chr(38)
                            ,'');
    CP_BODY_TEXT2 := REPLACE(CP_BODY_TEXT2
                            ,fnd_global.local_chr(38)
                            ,'');
    CP_BODY_TEXT4 := REPLACE(CP_BODY_TEXT4
                            ,fnd_global.local_chr(38)
                            ,'');

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

  FUNCTION CP_BODY_TEXT1_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_BODY_TEXT1;
  END CP_BODY_TEXT1_P;

  FUNCTION CP_FACULTY_MEMBER_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_FACULTY_MEMBER_NAME;
  END CP_FACULTY_MEMBER_NAME_P;

  FUNCTION CP_FACULTY_MEMBER_EMAIL_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_FACULTY_MEMBER_EMAIL;
  END CP_FACULTY_MEMBER_EMAIL_P;

  FUNCTION CP_FACULTY_MEMBER_ADDRESS_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_FACULTY_MEMBER_ADDRESS;
  END CP_FACULTY_MEMBER_ADDRESS_P;

  FUNCTION CP_FACULTY_MEMBER_TITLE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_FACULTY_MEMBER_TITLE;
  END CP_FACULTY_MEMBER_TITLE_P;

  FUNCTION CP_ACADEMIC_MANAGER_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_ACADEMIC_MANAGER_NAME;
  END CP_ACADEMIC_MANAGER_NAME_P;

  FUNCTION CP_ACADEMIC_MANAGER_EMAIL_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_ACADEMIC_MANAGER_EMAIL;
  END CP_ACADEMIC_MANAGER_EMAIL_P;

  FUNCTION CP_ACADEMIC_MANAGER_ADDRESS_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_ACADEMIC_MANAGER_ADDRESS;
  END CP_ACADEMIC_MANAGER_ADDRESS_P;

  FUNCTION CP_LOGGED_USER_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_LOGGED_USER_NAME;
  END CP_LOGGED_USER_NAME_P;

  FUNCTION CP_CONTRACT_START_DATE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_CONTRACT_START_DATE;
  END CP_CONTRACT_START_DATE_P;

  FUNCTION CP_FACULTY_MEMBER_LNAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_FACULTY_MEMBER_LNAME;
  END CP_FACULTY_MEMBER_LNAME_P;

  FUNCTION CP_REGARDS_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_REGARDS;
  END CP_REGARDS_P;

  FUNCTION CP_BODY_TEXT2_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_BODY_TEXT2;
  END CP_BODY_TEXT2_P;

  FUNCTION CP_BODY_TEXT3_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_BODY_TEXT3;
  END CP_BODY_TEXT3_P;

  FUNCTION CP_BODY_TEXT4_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_BODY_TEXT4;
  END CP_BODY_TEXT4_P;

  FUNCTION GET_BUSINESS_GROUP(P_BUSINESS_GROUP_ID IN NUMBER) RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
    X0 := HR_REPORTS.GET_BUSINESS_GROUP(P_BUSINESS_GROUP_ID);
    RETURN X0;
  END GET_BUSINESS_GROUP;

END PQH_PQHUSNTT_XMLP_PKG;

/
