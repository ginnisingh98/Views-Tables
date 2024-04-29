--------------------------------------------------------
--  DDL for Package Body PER_PERUSHIR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PERUSHIR_XMLP_PKG" AS
/* $Header: PERUSHIRB.pls 120.1 2008/03/31 10:14:13 amakrish noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
   -- HR_STANDARD.EVENT('BEFORE REPORT');
    C_END_OF_TIME := END_OF_TIME;
    C_BUSINESS_GROUP_NAME := GET_BUSINESS_GROUP(P_BUSINESS_GROUP_ID);
    IF P_MEDICAL_AVAIL = 'Y' THEN
      C_MEDICAL_AVAIL := 'Yes';
    ELSIF P_MEDICAL_AVAIL = 'N' THEN
      C_MEDICAL_AVAIL := 'No';
    ELSE
      C_MEDICAL_AVAIL := NULL;
    END IF;
    IF P_TAX_UNIT_ID IS NOT NULL THEN
      C_TAX_UNIT := GET_ORG_NAME(P_TAX_UNIT_ID
                                ,P_BUSINESS_GROUP_ID);
    END IF;
    IF P_STATE_CODE IS NOT NULL THEN
      C_STATE_NAME := GET_STATE_NAME(P_STATE_CODE);
    END IF;

--P_REPORT_DATE_T := to_char(to_date(P_REPORT_DATE,'YYYY/MM/DD HH24:MI:SS'),'DD-MON-YYYY');
P_REPORT_DATE_T := to_char(to_date(P_REPORT_DATE,'YYYY/MM/DD HH24:MI:SS'),'YYYY/MM/DD');

IF P_REPORT_MODE Is null THEN
P_REPORT_MODE:='F';
End IF;

IF P_STATE_CODE IN ('HI','IA','KY','MT','NM','OR','RI','TX','MD') THEN
 	Flag1 := 1;
ELSE
	Flag1 := 0;
END IF;

IF P_STATE_CODE IN ('TX','OR','MD') THEN
	Flag2 := 1;
ELSE
	Flag2 := 0;
END IF;



    RETURN (TRUE);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
    WHEN OTHERS THEN
      RETURN NULL;

  END BEFOREREPORT;

  FUNCTION C_EMPLOYEE_ADDRESSFORMULA(PERSON_ID IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      L_EMPLOYEE_ADDRESS VARCHAR2(2000) := NULL;
      L_PERSON_ID NUMBER(15);
    BEGIN
      L_PERSON_ID := PERSON_ID;
      GET_EMPLOYEE_ADDRESS(L_PERSON_ID
                          ,L_EMPLOYEE_ADDRESS);
      RETURN (L_EMPLOYEE_ADDRESS);
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
    RETURN NULL;
  END C_EMPLOYEE_ADDRESSFORMULA;

  FUNCTION C_CONTACT_NAMEFORMULA(NEW_HIRE_CONTACT_ID IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      L_PERSON_ID NUMBER(15);
      L_BUSINESS_GROUP_ID NUMBER(15);
      L_REPORT_DATE DATE;
      L_CONTACT_NAME VARCHAR2(240);
      L_CONTACT_TITLE VARCHAR2(160);
      L_CONTACT_PHONE VARCHAR2(60);
    BEGIN
      L_PERSON_ID := NEW_HIRE_CONTACT_ID;
      L_REPORT_DATE := FND_DATE.CANONICAL_TO_DATE(P_REPORT_DATE);
      L_BUSINESS_GROUP_ID := P_BUSINESS_GROUP_ID;
      PER_NEW_HIRE_PKG.GET_NEW_HIRE_CONTACT(L_PERSON_ID
                                           ,L_BUSINESS_GROUP_ID
                                           ,L_REPORT_DATE
                                           ,L_CONTACT_NAME
                                           ,L_CONTACT_TITLE
                                           ,L_CONTACT_PHONE);
      SET_LOCATION('Entered c_person_dets'
                  ,5);
      TRACE('Contact name => ' || L_CONTACT_NAME);
      SET_LOCATION('Leaving c_contact_name'
                  ,10);
      RETURN (L_CONTACT_NAME);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        TRACE('Error is found in c_contact_name');
    END;
    RETURN NULL;
  END C_CONTACT_NAMEFORMULA;

  FUNCTION C_SALARYFORMULA(ASSIGNMENT_ID IN NUMBER) RETURN NUMBER IS
  BEGIN
    DECLARE
      L_BUSINESS_GROUP_ID NUMBER(15);
      L_REPORT_DATE DATE;
      L_SALARY NUMBER;
    BEGIN
      SET_LOCATION('Entered c_salary formula'
                  ,5);
      IF P_STATE_CODE = 'TX' OR P_STATE_CODE = 'OR' OR P_STATE_CODE = 'MD' THEN
        L_BUSINESS_GROUP_ID := P_BUSINESS_GROUP_ID;
        L_REPORT_DATE := FND_DATE.CANONICAL_TO_DATE(P_REPORT_DATE);
        L_SALARY := GET_SALARY(L_BUSINESS_GROUP_ID
                              ,ASSIGNMENT_ID
                              ,L_REPORT_DATE);
        SET_LOCATION('Leaving c_salary formula'
                    ,10);
        IF P_STATE_CODE = 'TX' OR P_STATE_CODE = 'MD' THEN
          RETURN (L_SALARY);
        ELSE
          RETURN (L_SALARY / 12);
        END IF;
      ELSE
        SET_LOCATION('Leaving c_salary formula'
                    ,15);
        RETURN (NULL);
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
      WHEN OTHERS THEN
        NULL;
    END;
    RETURN NULL;
  END C_SALARYFORMULA;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
   -- HR_STANDARD.EVENT('AFTER REPORT');


    SET_LOCATION('Entered after report trigger'
                ,5);
    P_OUTPUT_NEW_HIRE_NULL;
    SET_LOCATION('Entered after report trigger'
                ,10);


    IF P_REPORT_MODE = 'F' THEN

      P_UPDATE_STATUS;
    END IF;


    SET_LOCATION('Leaving after report trigger'
                ,15);
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      SET_LOCATION('Error found in after report trigger'
                  ,20);
      TRACE('The error message is ' || SQLERRM);
      RETURN NULL;
  END AFTERREPORT;

  FUNCTION G_TAX_UNIT_HEADERGROUPFILTER RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END G_TAX_UNIT_HEADERGROUPFILTER;

  FUNCTION G_NEW_HIRESGROUPFILTER RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END G_NEW_HIRESGROUPFILTER;

  FUNCTION C_TAX_UNIT_ADDRESSFORMULA(LOCATION_ID IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      L_TAX_UNIT_ADDRESS VARCHAR2(2000);
      L_LOCATION_ID NUMBER(15);
    BEGIN
      L_LOCATION_ID := LOCATION_ID;
      GET_ADDRESS(L_LOCATION_ID
                 ,L_TAX_UNIT_ADDRESS);
      RETURN (L_TAX_UNIT_ADDRESS);
    EXCEPTION
      WHEN OTHERS THEN
        TRACE('the error is ' || TO_CHAR(SQLCODE) || SQLERRM);
    END;
    RETURN NULL;
  END C_TAX_UNIT_ADDRESSFORMULA;

  PROCEDURE P_UPDATE_STATUS IS
  BEGIN
    DECLARE
      CURSOR C_PERSON_ID IS
        SELECT
          PPF.PERSON_ID,
          PPF.LAST_NAME,
          PPF.FIRST_NAME
        FROM
          PER_ALL_PEOPLE_F PPF,
          PER_ALL_ASSIGNMENTS_F PAF,
          HR_SOFT_CODING_KEYFLEX HSCF,
          HR_LOCATIONS_ALL HL,
          PER_JOBS JOB,
          PER_PERIODS_OF_SERVICE PPS
        WHERE PPS.PERSON_ID = PPF.PERSON_ID
          AND FND_DATE.CANONICAL_TO_DATE(P_REPORT_DATE) between PPS.DATE_START
          AND NVL(PPS.ACTUAL_TERMINATION_DATE
           ,C_END_OF_TIME)
          AND FND_DATE.CANONICAL_TO_DATE(P_REPORT_DATE) between PPF.EFFECTIVE_START_DATE
          AND PPF.EFFECTIVE_END_DATE
          AND PPF.PERSON_ID = PAF.PERSON_ID
          AND FND_DATE.CANONICAL_TO_DATE(P_REPORT_DATE) between PAF.EFFECTIVE_START_DATE
          AND PAF.EFFECTIVE_END_DATE
          AND HSCF.SEGMENT1 = TO_CHAR(P_TAX_UNIT_ID)
          AND PAF.SOFT_CODING_KEYFLEX_ID = HSCF.SOFT_CODING_KEYFLEX_ID
          AND PAF.ASSIGNMENT_TYPE = 'E'
          AND PAF.PRIMARY_FLAG = 'Y'
          AND PAF.LOCATION_ID = HL.LOCATION_ID
          AND HL.REGION_2 = NVL(P_STATE_CODE
           ,HL.REGION_2)
          AND PAF.JOB_ID = job.job_id (+)
          AND FND_DATE.CANONICAL_TO_DATE(P_REPORT_DATE) between NVL(JOB.DATE_FROM
           ,FND_DATE.CANONICAL_TO_DATE(P_REPORT_DATE))
          AND NVL(JOB.DATE_TO
           ,C_END_OF_TIME)
          AND PPF.BUSINESS_GROUP_ID = P_BUSINESS_GROUP_ID
          AND PPF.PER_INFORMATION_CATEGORY = 'US'
          AND PPS.DATE_START <= FND_DATE.CANONICAL_TO_DATE(P_REPORT_DATE)
          AND PPF.PER_INFORMATION7 = 'INCL'
        UNION
        SELECT
          PPF.PERSON_ID,
          PPF.LAST_NAME,
          PPF.FIRST_NAME
        FROM
          PER_ALL_PEOPLE_F PPF,
          PER_ALL_ASSIGNMENTS_F PAF,
          HR_SOFT_CODING_KEYFLEX HSCF,
          HR_LOCATIONS_ALL HL,
          PER_JOBS JOB,
          PER_PERIODS_OF_SERVICE PPS
        WHERE PPS.PERSON_ID = PPF.PERSON_ID
          AND FND_DATE.CANONICAL_TO_DATE(P_REPORT_DATE) between PPF.EFFECTIVE_START_DATE
          AND PPF.EFFECTIVE_END_DATE
          AND PPS.ACTUAL_TERMINATION_DATE IS NOT NULL
          AND PPF.PERSON_ID = PAF.PERSON_ID
          AND not exists (
          SELECT
            1
          FROM
            PER_PERIODS_OF_SERVICE PPS2
          WHERE PPF.PERSON_ID = PPS2.PERSON_ID
            AND FND_DATE.CANONICAL_TO_DATE(P_REPORT_DATE) between PPS2.DATE_START
            AND NVL(PPS2.ACTUAL_TERMINATION_DATE
             ,C_END_OF_TIME) )
          AND PPS.DATE_START = PAF.EFFECTIVE_START_DATE
          AND HSCF.SEGMENT1 = TO_CHAR(P_TAX_UNIT_ID)
          AND PAF.SOFT_CODING_KEYFLEX_ID = HSCF.SOFT_CODING_KEYFLEX_ID
          AND PAF.ASSIGNMENT_TYPE = 'E'
          AND PAF.PRIMARY_FLAG = 'Y'
          AND PAF.LOCATION_ID = HL.LOCATION_ID
          AND HL.REGION_2 = NVL(P_STATE_CODE
           ,HL.REGION_2)
          AND PAF.JOB_ID = job.job_id (+)
          AND FND_DATE.CANONICAL_TO_DATE(P_REPORT_DATE) between NVL(JOB.DATE_FROM
           ,FND_DATE.CANONICAL_TO_DATE(P_REPORT_DATE))
          AND NVL(JOB.DATE_TO
           ,C_END_OF_TIME)
          AND PPF.BUSINESS_GROUP_ID = P_BUSINESS_GROUP_ID
          AND PPF.PER_INFORMATION_CATEGORY = 'US'
          AND PPS.DATE_START <= FND_DATE.CANONICAL_TO_DATE(P_REPORT_DATE)
          AND PPF.PER_INFORMATION7 = 'INCL'
        ORDER BY
          2,
          3;
      V_PERSON_ID PER_PEOPLE_F.PERSON_ID%TYPE;
      V_LAST_NAME PER_PEOPLE_F.LAST_NAME%TYPE;
      V_FIRST_NAME PER_PEOPLE_F.FIRST_NAME%TYPE;
    BEGIN

      SET_LOCATION('Entered p_update_status'
                  ,5);
      IF C_PERSON_ID%ISOPEN THEN
        CLOSE C_PERSON_ID;
      END IF;
      OPEN C_PERSON_ID;
      LOOP
        FETCH C_PERSON_ID
         INTO
           V_PERSON_ID
           ,V_LAST_NAME
           ,V_FIRST_NAME;
        UPDATE
          PER_PEOPLE_F
        SET
          PER_INFORMATION7 = 'DONE'
        WHERE PERSON_ID = V_PERSON_ID
          AND PER_INFORMATION7 = 'INCL';
        EXIT WHEN C_PERSON_ID%NOTFOUND;
      END LOOP;
      SET_LOCATION('p_update_status'
                  ,10);
      CLOSE C_PERSON_ID;
      COMMIT;
      SET_LOCATION('Leaving p_update_status'
                  ,15);



    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
    END;
  END P_UPDATE_STATUS;

  FUNCTION C_CONTACT_TITLEFORMULA(NEW_HIRE_CONTACT_ID IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      L_PERSON_ID NUMBER(15);
      L_BUSINESS_GROUP_ID NUMBER(15);
      L_REPORT_DATE DATE;
      L_CONTACT_NAME VARCHAR2(240);
      L_CONTACT_TITLE VARCHAR2(160);
      L_CONTACT_PHONE VARCHAR2(60);
    BEGIN
      L_PERSON_ID := NEW_HIRE_CONTACT_ID;
      L_REPORT_DATE := FND_DATE.CANONICAL_TO_DATE(P_REPORT_DATE);
      L_BUSINESS_GROUP_ID := P_BUSINESS_GROUP_ID;
      PER_NEW_HIRE_PKG.GET_NEW_HIRE_CONTACT(L_PERSON_ID
                                           ,L_BUSINESS_GROUP_ID
                                           ,L_REPORT_DATE
                                           ,L_CONTACT_NAME
                                           ,L_CONTACT_TITLE
                                           ,L_CONTACT_PHONE);
      SET_LOCATION('Entered c_contact_title'
                  ,5);
      TRACE('Contact title => ' || L_CONTACT_TITLE);
      SET_LOCATION('Leaving c_contact_title'
                  ,10);
      RETURN (L_CONTACT_TITLE);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        TRACE('no data found error in c_contact_title');
    END;
    RETURN NULL;
  END C_CONTACT_TITLEFORMULA;

  FUNCTION C_CONTACT_PHONEFORMULA(NEW_HIRE_CONTACT_ID IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      L_PERSON_ID NUMBER(15);
      L_BUSINESS_GROUP_ID NUMBER(15);
      L_REPORT_DATE DATE;
      L_CONTACT_NAME VARCHAR2(240);
      L_CONTACT_TITLE VARCHAR2(160);
      L_CONTACT_PHONE VARCHAR2(60);
    BEGIN
      L_PERSON_ID := NEW_HIRE_CONTACT_ID;
      L_REPORT_DATE := FND_DATE.CANONICAL_TO_DATE(P_REPORT_DATE);
      L_BUSINESS_GROUP_ID := P_BUSINESS_GROUP_ID;
      PER_NEW_HIRE_PKG.GET_NEW_HIRE_CONTACT(L_PERSON_ID
                                           ,L_BUSINESS_GROUP_ID
                                           ,L_REPORT_DATE
                                           ,L_CONTACT_NAME
                                           ,L_CONTACT_TITLE
                                           ,L_CONTACT_PHONE);
      SET_LOCATION('Entered c_contact_phone'
                  ,5);
      TRACE('Contact phone => ' || L_CONTACT_PHONE);
      SET_LOCATION('Leaving c_contact_phone'
                  ,10);
      RETURN (L_CONTACT_PHONE);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        TRACE('no data found error in c_contact_phone');
    END;
    RETURN NULL;
  END C_CONTACT_PHONEFORMULA;

  FUNCTION BETWEENPAGE RETURN BOOLEAN IS
  BEGIN
    SET_LOCATION('Entered between page trigger'
                ,5);
    RETURN (TRUE);
  END BETWEENPAGE;

  PROCEDURE P_OUTPUT_NEW_HIRE_NULL IS
  BEGIN
    DECLARE
      CURSOR C_PERSON_ID IS
        SELECT
          PPF.PERSON_ID,
          PPF.LAST_NAME,
          PPF.FIRST_NAME,
          SUBSTR(PPF.MIDDLE_NAMES
                ,1
                ,1) MIDDLE_NAME,
          PPF.NATIONAL_IDENTIFIER,
          PPF.DATE_OF_BIRTH,
          PPS.DATE_START
        FROM
          PER_ALL_PEOPLE_F PPF,
          PER_ALL_ASSIGNMENTS_F PAF,
          HR_SOFT_CODING_KEYFLEX HSCF,
          HR_LOCATIONS_ALL HL,
          PER_JOBS JOB,
          PER_PERIODS_OF_SERVICE PPS
        WHERE PPS.PERSON_ID = PPF.PERSON_ID
          AND FND_DATE.CANONICAL_TO_DATE(P_REPORT_DATE) between PPS.DATE_START
          AND NVL(PPS.ACTUAL_TERMINATION_DATE
           ,C_END_OF_TIME)
          AND FND_DATE.CANONICAL_TO_DATE(P_REPORT_DATE) between PPF.EFFECTIVE_START_DATE
          AND PPF.EFFECTIVE_END_DATE
          AND PPF.PERSON_ID = PAF.PERSON_ID
          AND FND_DATE.CANONICAL_TO_DATE(P_REPORT_DATE) between PAF.EFFECTIVE_START_DATE
          AND PAF.EFFECTIVE_END_DATE
          AND HSCF.SEGMENT1 = TO_CHAR(P_TAX_UNIT_ID)
          AND PAF.SOFT_CODING_KEYFLEX_ID = HSCF.SOFT_CODING_KEYFLEX_ID
          AND PAF.ASSIGNMENT_TYPE = 'E'
          AND PAF.PRIMARY_FLAG = 'Y'
          AND PAF.LOCATION_ID = HL.LOCATION_ID
          AND HL.REGION_2 = NVL(P_STATE_CODE
           ,HL.REGION_2)
          AND PAF.JOB_ID = job.job_id (+)
          AND FND_DATE.CANONICAL_TO_DATE(P_REPORT_DATE) between NVL(JOB.DATE_FROM
           ,FND_DATE.CANONICAL_TO_DATE(P_REPORT_DATE))
          AND NVL(JOB.DATE_TO
           ,C_END_OF_TIME)
          AND PPF.BUSINESS_GROUP_ID = P_BUSINESS_GROUP_ID
          AND PPF.PER_INFORMATION_CATEGORY = 'US'
          AND PPS.DATE_START <= FND_DATE.CANONICAL_TO_DATE(P_REPORT_DATE)
          AND PPF.PER_INFORMATION7 is NULL
        UNION
        SELECT
          PPF.PERSON_ID,
          PPF.LAST_NAME,
          PPF.FIRST_NAME,
          SUBSTR(PPF.MIDDLE_NAMES
                ,1
                ,1) MIDDLE_NAME,
          PPF.NATIONAL_IDENTIFIER,
          PPF.DATE_OF_BIRTH,
          PPS.DATE_START
        FROM
          PER_ALL_PEOPLE_F PPF,
          PER_ALL_ASSIGNMENTS_F PAF,
          HR_SOFT_CODING_KEYFLEX HSCF,
          HR_LOCATIONS_ALL HL,
          PER_JOBS JOB,
          PER_PERIODS_OF_SERVICE PPS
        WHERE PPS.PERSON_ID = PPF.PERSON_ID
          AND FND_DATE.CANONICAL_TO_DATE(P_REPORT_DATE) between PPF.EFFECTIVE_START_DATE
          AND PPF.EFFECTIVE_END_DATE
          AND PPS.ACTUAL_TERMINATION_DATE IS NOT NULL
          AND PPF.PERSON_ID = PAF.PERSON_ID
          AND not exists (
          SELECT
            1
          FROM
            PER_PERIODS_OF_SERVICE PPS2
          WHERE PPF.PERSON_ID = PPS2.PERSON_ID
            AND FND_DATE.CANONICAL_TO_DATE(P_REPORT_DATE) between PPS2.DATE_START
            AND NVL(PPS2.ACTUAL_TERMINATION_DATE
             ,C_END_OF_TIME) )
          AND PPS.DATE_START = PAF.EFFECTIVE_START_DATE
          AND HSCF.SEGMENT1 = TO_CHAR(P_TAX_UNIT_ID)
          AND PAF.SOFT_CODING_KEYFLEX_ID = HSCF.SOFT_CODING_KEYFLEX_ID
          AND PAF.ASSIGNMENT_TYPE = 'E'
          AND PAF.PRIMARY_FLAG = 'Y'
          AND PAF.LOCATION_ID = HL.LOCATION_ID
          AND HL.REGION_2 = NVL(P_STATE_CODE
           ,HL.REGION_2)
          AND PAF.JOB_ID = job.job_id (+)
          AND FND_DATE.CANONICAL_TO_DATE(P_REPORT_DATE) between NVL(JOB.DATE_FROM
           ,FND_DATE.CANONICAL_TO_DATE(P_REPORT_DATE))
          AND NVL(JOB.DATE_TO
           ,C_END_OF_TIME)
          AND PPF.BUSINESS_GROUP_ID = P_BUSINESS_GROUP_ID
          AND PPF.PER_INFORMATION_CATEGORY = 'US'
          AND PPS.DATE_START <= FND_DATE.CANONICAL_TO_DATE(P_REPORT_DATE)
          AND PPF.PER_INFORMATION7 is NULL
        ORDER BY
          2,
          3;
      V_PERSON_ID PER_ALL_PEOPLE_F.PERSON_ID%TYPE;
      V_LAST_NAME PER_ALL_PEOPLE_F.LAST_NAME%TYPE;
      V_FIRST_NAME PER_ALL_PEOPLE_F.FIRST_NAME%TYPE;
      V_MIDDLE_NAME PER_ALL_PEOPLE_F.MIDDLE_NAMES%TYPE;
      V_SSN PER_ALL_PEOPLE_F.NATIONAL_IDENTIFIER%TYPE;
      V_DOB PER_ALL_PEOPLE_F.DATE_OF_BIRTH%TYPE;
      V_DATE_START PER_PERIODS_OF_SERVICE.DATE_START%TYPE;
      V_HEADER NUMBER;
      V_BUFFER VARCHAR2(120);
      V_BOOLEAN BOOLEAN;
    BEGIN
      SET_LOCATION('Entered p_output_new_hire_null'
                  ,10);
      V_HEADER := 0;
      IF C_PERSON_ID%ISOPEN THEN
        CLOSE C_PERSON_ID;
      END IF;
      OPEN C_PERSON_ID;
      FETCH C_PERSON_ID
       INTO
         V_PERSON_ID
         ,V_LAST_NAME
         ,V_FIRST_NAME
         ,V_MIDDLE_NAME
         ,V_SSN
         ,V_DOB
         ,V_DATE_START;
      WHILE C_PERSON_ID%FOUND LOOP

        IF V_HEADER = 0 THEN
          V_BOOLEAN := FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING'
                                                           ,'');
          FND_FILE.PUT_LINE(1
                           ,'Warning : The New Hire field of the following employees on people form is blank.');
          FND_FILE.PUT_LINE(1
                           ,'Warning : Please update the New Hire field.');
          FND_FILE.PUT_LINE(1
                           ,' ');
          FND_FILE.PUT_LINE(1
                           ,'Last Name                 First Name          MI SSN         Hire Date DOB      ');
          FND_FILE.PUT_LINE(1
                           ,'------------------------ -------------------- -- ----------- --------- ---------');
          V_BUFFER := RPAD(V_LAST_NAME
                          ,24
                          ,' ') || RPAD(' '
                          ,1
                          ,' ') || RPAD(NVL(V_FIRST_NAME
                              ,' ')
                          ,20
                          ,' ') || RPAD(' '
                          ,1
                          ,' ') || RPAD(NVL(V_MIDDLE_NAME
                              ,' ')
                          ,2
                          ,' ') || RPAD(' '
                          ,1
                          ,' ') || RPAD(NVL(V_SSN
                              ,' ')
                          ,11
                          ,' ') || RPAD(' '
                          ,1
                          ,' ') || RPAD(TO_DATE(V_DATE_START
                                  ,'DD-MON-RRRR')
                          ,9
                          ,' ') || RPAD(' '
                          ,1
                          ,' ') || RPAD(TO_DATE(V_DOB
                                  ,'DD-MON-RRRR')
                          ,9
                          ,' ');
          FND_FILE.PUT_LINE(1
                           ,V_BUFFER);
          V_HEADER := 1;
        ELSE
          V_BUFFER := RPAD(V_LAST_NAME
                          ,24
                          ,' ') || RPAD(' '
                          ,1
                          ,' ') || RPAD(NVL(V_FIRST_NAME
                              ,' ')
                          ,20
                          ,' ') || RPAD(' '
                          ,1
                          ,' ') || RPAD(NVL(V_MIDDLE_NAME
                              ,' ')
                          ,2
                          ,' ') || RPAD(' '
                          ,1
                          ,' ') || RPAD(NVL(V_SSN
                              ,' ')
                          ,11
                          ,' ') || RPAD(' '
                          ,1
                          ,' ') || RPAD(TO_DATE(V_DATE_START
                                  ,'DD-MON-RRRR')
                          ,9
                          ,' ') || RPAD(' '
                          ,1
                          ,' ') || RPAD(TO_DATE(V_DOB
                                  ,'DD-MON-RRRR')
                          ,9
                          ,' ');
          FND_FILE.PUT_LINE(1
                           ,V_BUFFER);
        END IF;
        FETCH C_PERSON_ID
         INTO
           V_PERSON_ID
           ,V_LAST_NAME
           ,V_FIRST_NAME
           ,V_MIDDLE_NAME
           ,V_SSN
           ,V_DOB
           ,V_DATE_START;
      END LOOP;
      FND_FILE.PUT_LINE(1
                       ,' ');
      SET_LOCATION('p_output_new_hire_null'
                  ,100);
      CLOSE C_PERSON_ID;
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
    END;
  END P_OUTPUT_NEW_HIRE_NULL;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION C_BUSINESS_GROUP_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_BUSINESS_GROUP_NAME;
  END C_BUSINESS_GROUP_NAME_P;

  FUNCTION C_REPORT_SUBTITLE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_REPORT_SUBTITLE;
  END C_REPORT_SUBTITLE_P;

  FUNCTION C_TAX_UNIT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_TAX_UNIT;
  END C_TAX_UNIT_P;

  FUNCTION C_STATE_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_STATE_NAME;
  END C_STATE_NAME_P;

  FUNCTION C_MEDICAL_AVAIL_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_MEDICAL_AVAIL;
  END C_MEDICAL_AVAIL_P;

  FUNCTION C_END_OF_TIME_P RETURN DATE IS
  BEGIN
    RETURN C_END_OF_TIME;
  END C_END_OF_TIME_P;
  FUNCTION GET_BUSINESS_GROUP(P_BUSINESS_GROUP_ID IN NUMBER) RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
    X0 := HR_REPORTS.GET_BUSINESS_GROUP(P_BUSINESS_GROUP_ID);
    RETURN X0;
  END GET_BUSINESS_GROUP;



  FUNCTION END_OF_TIME RETURN DATE IS
    X0 DATE;
  BEGIN
    X0 := HR_GENERAL.END_OF_TIME;
    RETURN X0;
  END END_OF_TIME;

  FUNCTION GET_ORG_NAME(P_ORGANIZATION_ID IN NUMBER
                       ,P_BUSINESS_GROUP_ID IN NUMBER) RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
    X0 := HR_US_REPORTS.GET_ORG_NAME(P_ORGANIZATION_ID,P_BUSINESS_GROUP_ID);
    RETURN X0;
  END GET_ORG_NAME;

FUNCTION GET_STATE_NAME(P_STATE_CODE IN VARCHAR2) RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
    X0 := HR_US_REPORTS.GET_STATE_NAME(P_STATE_CODE);
    RETURN X0;
  END GET_STATE_NAME;

 PROCEDURE GET_EMPLOYEE_ADDRESS(P_PERSON_ID IN NUMBER
                                ,P_ADDRESS OUT NOCOPY VARCHAR2) IS
  BEGIN
    HR_US_REPORTS.GET_EMPLOYEE_ADDRESS(P_PERSON_ID, P_ADDRESS);

  END GET_EMPLOYEE_ADDRESS;

  PROCEDURE SET_LOCATION(PROCEDURE_NAME IN VARCHAR2
                        ,STAGE IN NUMBER) IS
  BEGIN
    HR_UTILITY.SET_LOCATION(PROCEDURE_NAME, STAGE);
  END SET_LOCATION;

PROCEDURE TRACE(TRACE_DATA IN VARCHAR2) IS
  BEGIN
 HR_UTILITY.TRACE(TRACE_DATA);
  END TRACE;

FUNCTION GET_SALARY(P_PAY_BASIS_ID IN NUMBER
                     ,P_ASSIGNMENT_ID IN NUMBER) RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
    X0 := HR_GENERAL.GET_SALARY(P_PAY_BASIS_ID, P_ASSIGNMENT_ID);
    RETURN X0;
  END GET_SALARY;

  FUNCTION GET_SALARY(P_BUSINESS_GROUP_ID IN NUMBER
                     ,P_ASSIGNMENT_ID IN NUMBER
                     ,P_REPORT_DATE IN DATE) RETURN NUMBER IS
    X0 NUMBER;
  BEGIN
    X0 := HR_US_REPORTS.GET_SALARY(P_BUSINESS_GROUP_ID, P_ASSIGNMENT_ID, P_REPORT_DATE);
    RETURN X0;
  END GET_SALARY;

PROCEDURE GET_ADDRESS(P_LOCATION_ID IN NUMBER
                       ,P_ADDRESS OUT NOCOPY VARCHAR2) IS
  BEGIN
HR_US_REPORTS.GET_ADDRESS(P_LOCATION_ID, P_ADDRESS);
  END GET_ADDRESS;

END PER_PERUSHIR_XMLP_PKG;

/
