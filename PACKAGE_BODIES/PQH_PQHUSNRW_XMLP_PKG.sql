--------------------------------------------------------
--  DDL for Package Body PQH_PQHUSNRW_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_PQHUSNRW_XMLP_PKG" AS
/* $Header: PQHUSNRWB.pls 120.1 2007/12/07 06:57:09 vjaganat noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
    L_LNAME VARCHAR2(150);
    L_TITLE VARCHAR2(240);
    L_REVIEW_DATE VARCHAR2(20);
    L_EMPID VARCHAR2(30);
    L_BODY_TEXT3 VARCHAR2(20);
    L_BODY_TEXT4 VARCHAR2(20);
    L_BODY_TEXT5 VARCHAR2(20);
    L_BODY_TEXT6 VARCHAR2(20);
    L_BODY_TEXT7 VARCHAR2(20);
    L_BODY_TEXT8 VARCHAR2(20);
    L_HIREDATE DATE;
    L_MANAGER_ID NUMBER;
    CURSOR EMP_REVU_CUR IS
      SELECT
        TO_CHAR(MIN(PE.DATE_START)
               ,'DD-MON-YYYY')
      FROM
        PER_ALL_ASSIGNMENTS_F PAF,
        PER_EVENTS PE,
        HR_LOOKUPS HR,
        PER_ALL_PEOPLE_F PAP
      WHERE PE.ASSIGNMENT_ID = PAF.ASSIGNMENT_ID
        AND PAP.PERSON_ID = PAF.PERSON_ID
        AND PE.TYPE = HR.LOOKUP_CODE
        AND SYSDATE BETWEEN PAF.EFFECTIVE_START_DATE
        AND PAF.EFFECTIVE_END_DATE
        AND SYSDATE BETWEEN PAP.EFFECTIVE_START_DATE
        AND PAP.EFFECTIVE_END_DATE
        AND PE.EMP_OR_APL = 'E'
        AND HR.LOOKUP_TYPE = 'EMP_INTERVIEW_TYPE'
        AND PE.EVENT_OR_INTERVIEW = 'I'
        AND PE.DATE_START BETWEEN P_START_DATE
        AND P_END_DATE
        AND PAP.PERSON_ID = P_PERSON_ID
        AND PE.BUSINESS_GROUP_ID + 0 = P_BUSINESS_GROUP_ID;
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
    PQH_TENURE_DETAIL.GETREPORTBODYTEXT('RW'
                                       ,CP_REGARDS
                                       ,CP_BODY_TEXT1
                                       ,CP_BODY_TEXT2
                                       ,L_BODY_TEXT3
                                       ,L_BODY_TEXT4
                                       ,L_BODY_TEXT5
                                       ,L_BODY_TEXT6
                                       ,L_BODY_TEXT7
                                       ,L_BODY_TEXT8);
    OPEN EMP_REVU_CUR;
    FETCH EMP_REVU_CUR
     INTO
       L_REVIEW_DATE;
    CLOSE EMP_REVU_CUR;
    CP_BODY_TEXT1 := REPLACE(CP_BODY_TEXT1
                            ,fnd_global.local_chr(10)
                            ,'');
    CP_BODY_TEXT2 := REPLACE(CP_BODY_TEXT2
                            ,fnd_global.local_chr(10)
                            ,'');
    CP_BODY_TEXT1 := REPLACE(CP_BODY_TEXT1
                            ,'REVIEW_DATE'
                            ,L_REVIEW_DATE);
    CP_BODY_TEXT1 := REPLACE(CP_BODY_TEXT1
                            ,fnd_global.local_chr(38)
                            ,'');
    P_START_DATE_T := to_char(P_START_DATE,'DD-MON-YYYY');
    P_END_DATE_T := to_char(P_END_DATE,'DD-MON-YYYY');

    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
   -- HR_STANDARD.EVENT('AFTER REPORT');
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


  FUNCTION GET_BUSINESS_GROUP(P_BUSINESS_GROUP_ID IN NUMBER) RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
    X0 := HR_REPORTS.GET_BUSINESS_GROUP(P_BUSINESS_GROUP_ID);
    RETURN X0;
  END GET_BUSINESS_GROUP;

END PQH_PQHUSNRW_XMLP_PKG;

/