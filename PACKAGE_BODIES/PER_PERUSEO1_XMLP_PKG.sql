--------------------------------------------------------
--  DDL for Package Body PER_PERUSEO1_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PERUSEO1_XMLP_PKG" AS
/* $Header: PERUSEO1B.pls 120.1 2008/01/07 13:26:43 srikrish noship $ */
  --G_FILE_TYPE TEXT_IO.FILE_TYPE;

  G_IL_FEIN VARCHAR2(10);

  G_FILE_NAME VARCHAR2(30);

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
    L_DUMMY VARCHAR2(1);
    TEST_YEAR DATE;
    TEST_YEAR1 DATE;
    L_LOCATION_CODE VARCHAR2(60);
    L_LOCATION_ID NUMBER(15);
    L_BUFFER VARCHAR2(1000);
    G_DELIMITER VARCHAR2(1) := ',';
    G_EOL VARCHAR2(1) := FND_GLOBAL.LOCAL_CHR(10);
        temp boolean;
  BEGIN
    --HR_STANDARD.EVENT('BEFORE REPORT');
      temp := P_REPORT_YEARVALIDTRIGGER;

    C_ALL_TOTAL := 0;
    CP_PREV_YEAR_FILED := TO_CHAR(TO_NUMBER(P_REPORT_YEAR - 1));
    P_PAYROLL_PERIOD_DATE_START_T := FND_DATE.CANONICAL_TO_DATE(P_PAYROLL_PERIOD_DATE_START);
    P_PAYROLL_PERIOD_DATE_END_T := FND_DATE.CANONICAL_TO_DATE(P_PAYROLL_PERIOD_DATE_END);
    C_PAYROLL_PERIOD_DATE_START := P_PAYROLL_PERIOD_DATE_START_T;
    C_PAYROLL_PERIOD_DATE_END := P_PAYROLL_PERIOD_DATE_END_T;
    C_REPORT_MODE := P_REPORT_MODE;
    C_REPORT_YEAR := P_REPORT_YEAR;
    C_BUSINESS_GROUP_NAME := GET_BUSINESS_GROUP(P_BUSINESS_GROUP_ID);
    /*SRW.MESSAGE('35'
               ,'previous year ' || CP_PREV_YEAR_FILED)*/NULL;
    SELECT
      PGH.NAME,
      PGV.VERSION_NUMBER,
      PGN.ENTITY_ID,
      PGN.HIERARCHY_NODE_ID
    INTO C_HIERARCHY_NAME,C_HIERARCHY_VERSION_NUM,C_PARENT_ORG_ID,C_PARENT_NODE_ID
    FROM
      PER_GEN_HIERARCHY PGH,
      PER_GEN_HIERARCHY_VERSIONS PGV,
      PER_GEN_HIERARCHY_NODES PGN
    WHERE PGH.HIERARCHY_ID = P_HIERARCHY_ID
      AND PGH.HIERARCHY_ID = PGV.HIERARCHY_ID
      AND PGV.HIERARCHY_VERSION_ID = P_HIERARCHY_VERSION_ID
      AND PGN.HIERARCHY_VERSION_ID = PGV.HIERARCHY_VERSION_ID
      AND PGN.NODE_TYPE = 'PAR';
    SELECT
      COUNT('h_node')
    INTO C_NO_OF_ESTABLISHMENTS
    FROM
      PER_GEN_HIERARCHY_NODES PGHN
    WHERE PGHN.HIERARCHY_VERSION_ID = P_HIERARCHY_VERSION_ID
      AND PGHN.NODE_TYPE = 'EST';
    /*SRW.MESSAGE('10'
               ,'number of establishments: ' || C_NO_OF_ESTABLISHMENTS)*/NULL;
    BEGIN
      SELECT
        null
      INTO L_DUMMY
      FROM
        HR_ALL_ORGANIZATION_UNITS
      WHERE ORGANIZATION_ID = C_PARENT_ORG_ID
        AND LOCATION_ID is not null;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('PER'
                            ,'PER_75228_ORG_LOC_MISSING');
        /*SRW.MESSAGE('10'
                   ,FND_MESSAGE.GET)*/NULL;
        RAISE;
    END;
    BEGIN
      SELECT
        null
      INTO L_DUMMY
      FROM
        HR_ORGANIZATION_INFORMATION
      WHERE ORGANIZATION_ID = C_PARENT_ORG_ID
        AND ORG_INFORMATION_CONTEXT = 'EEO_Spec';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('PER'
                            ,'PER_75229_EEO_CLASS_MISSING');
        /*SRW.MESSAGE('10'
                   ,FND_MESSAGE.GET)*/NULL;
        RAISE;
    END;
    BEGIN
      SELECT
        null
      INTO L_DUMMY
      FROM
        HR_LOCATION_EXTRA_INFO HLEI1,
        HR_LOCATION_EXTRA_INFO HLEI2,
        PER_GEN_HIERARCHY_NODES PGN,
        HR_LOCATIONS_ALL ELOC
      WHERE PGN.HIERARCHY_VERSION_ID = P_HIERARCHY_VERSION_ID
        AND PGN.NODE_TYPE = 'EST'
        AND ELOC.LOCATION_ID = PGN.ENTITY_ID
        AND HLEI1.LOCATION_ID = ELOC.LOCATION_ID
        AND HLEI1.INFORMATION_TYPE = 'EEO-1 Specific Information'
        AND HLEI1.LEI_INFORMATION_CATEGORY = 'EEO-1 Specific Information'
        AND HLEI2.LOCATION_ID = ELOC.LOCATION_ID
        AND HLEI2.INFORMATION_TYPE = 'Establishment Information'
        AND HLEI2.LEI_INFORMATION_CATEGORY = 'Establishment Information';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('PER'
                            ,'PER_75230_EST_CLASS_MISSING');
        /*SRW.MESSAGE('10'
                   ,FND_MESSAGE.GET)*/NULL;
        RAISE;
      WHEN OTHERS THEN
        NULL;
    END;
    BEGIN
      SELECT
        ELOC.LOCATION_ID,
        ELOC.LOCATION_CODE
      INTO L_LOCATION_ID,L_LOCATION_CODE
      FROM
        HR_LOCATION_EXTRA_INFO HLEI1,
        PER_GEN_HIERARCHY_NODES PGN,
        HR_LOCATIONS_ALL ELOC
      WHERE PGN.HIERARCHY_VERSION_ID = P_HIERARCHY_VERSION_ID
        AND PGN.NODE_TYPE = 'EST'
        AND ELOC.LOCATION_ID = PGN.ENTITY_ID
        AND HLEI1.LOCATION_ID = ELOC.LOCATION_ID
        AND HLEI1.INFORMATION_TYPE = 'EEO-1 Archive Information'
        AND HLEI1.LEI_INFORMATION_CATEGORY = 'EEO-1 Archive Information';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        /*SRW.MESSAGE('20'
                   ,'Either (1) there are no establishments within your hierarchy with the extra')*/NULL;
        /*SRW.MESSAGE('20'
                   ,'information type EEO-1 Archive Information attatched - in which case ')*/NULL;
        /*SRW.MESSAGE('20'
                   ,'please attatch to appropriate responsibility in the information security screen.')*/NULL;
        /*SRW.MESSAGE('20'
                   ,'                                                                                ')*/NULL;
        /*SRW.MESSAGE('20'
                   ,'or (2) the extra information type EEO-1 Archive Information exists for location ')*/NULL;
        /*SRW.MESSAGE('20'
                   ,L_LOCATION_CODE || 'but does not yet contain data.  If this is your first time to file  ')*/NULL;
        /*SRW.MESSAGE('20'
                   ,'(ie if this is a report type 9) then do not worry about this.  ')*/NULL;
        /*SRW.MESSAGE('20'
                   ,'However if you filed last year then the EIT will have to be filled with last years')*/NULL;
        /*SRW.MESSAGE('20'
                   ,'totals, either manually or by running the report for last year in final mode.')*/NULL;
      WHEN OTHERS THEN
        NULL;
    END;
    BEGIN
      BEGIN
        SELECT
          '1',
          ELOC.LOCATION_ID,
          ELOC.LOCATION_CODE
        INTO L_DUMMY,L_LOCATION_ID,L_LOCATION_CODE
        FROM
          HR_LOCATION_EXTRA_INFO HLEI1,
          PER_GEN_HIERARCHY_NODES PGN,
          HR_LOCATIONS_ALL ELOC
        WHERE PGN.HIERARCHY_VERSION_ID = P_HIERARCHY_VERSION_ID
          AND PGN.NODE_TYPE = 'EST'
          AND ELOC.LOCATION_ID = PGN.ENTITY_ID
          AND HLEI1.LOCATION_ID = ELOC.LOCATION_ID
          AND HLEI1.INFORMATION_TYPE = 'EEO-1 Specific Information'
          AND HLEI1.LEI_INFORMATION_CATEGORY = 'EEO-1 Specific Information'
          AND HLEI1.LEI_INFORMATION9 = 'Y';
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
        WHEN OTHERS THEN
          NULL;
      END;
      /*SRW.MESSAGE('444'
                 ,'l_dummy, l_location_id, l_location_code ' || L_DUMMY || ' ' || L_LOCATION_ID || ' ' || L_LOCATION_CODE)*/NULL;
      IF L_DUMMY = '1' THEN
        BEGIN
          SELECT
            2
          INTO L_DUMMY
          FROM
            HR_LOCATION_EXTRA_INFO
          WHERE LEI_INFORMATION1 = CP_PREV_YEAR_FILED
            AND LEI_INFORMATION_CATEGORY = 'EEO-1 Archive Information';
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            /*SRW.MESSAGE('555'
                       ,'l_dummy, l_location_id, l_location_code ' || L_DUMMY || ' ' || L_LOCATION_ID || ' ' || L_LOCATION_CODE)*/NULL;
            /*SRW.MESSAGE('30'
                       ,'                                         ')*/NULL;
            /*SRW.MESSAGE('30'
                       ,'The extra information type EEO-1 Archive Information exists for ' || L_LOCATION_CODE)*/NULL;
            /*SRW.MESSAGE('30'
                       ,'but does not contain data for last years totals.    ')*/NULL;
            /*SRW.MESSAGE('30'
                       ,'                                          ')*/NULL;
            /*SRW.MESSAGE('30'
                       ,'As you filed last year then this EIT will have to be filled with last years')*/NULL;
            /*SRW.MESSAGE('30'
                       ,'totals, either manually or by running the report for last year in final mode.')*/NULL;
            /*SRW.MESSAGE('30'
                       ,'                                          ')*/NULL;
            /*SRW.MESSAGE('30'
                       ,'To do this without encountering this error again, set the reported previously field')*/NULL;
            /*SRW.MESSAGE('30'
                       ,'under location/extra info/EEO-1 Specific Data to No and then run the report in  ')*/NULL;
            /*SRW.MESSAGE('30'
                       ,'Final mode for last years dates.')*/NULL;
            /*SRW.MESSAGE('30'
                       ,'                                          ')*/NULL;
            /*SRW.MESSAGE('30'
                       ,'Then set the Reported Previously field back to Yes and run the report for ')*/NULL;
            /*SRW.MESSAGE('30'
                       ,'this year as normal')*/NULL;
            /*SRW.MESSAGE('30'
                       ,'                                          ')*/NULL;
          WHEN OTHERS THEN
            NULL;
        END;
      END IF;
    END;
    IF P_AUDIT_REPORT = 'Y' THEN
      --OPEN;
      L_BUFFER := 'Person Id' || G_DELIMITER || 'Last Name' ||
      G_DELIMITER || 'First Name' || G_DELIMITER || 'Employee Number' ||
      G_DELIMITER || 'Gender' || G_DELIMITER || 'Ethnic Origin' || G_DELIMITER ||
      'Assignment Id' || G_DELIMITER || 'Job Id' || G_DELIMITER || 'Job Name' || G_DELIMITER ||
      'Location Id' || G_DELIMITER || 'Location Code' || G_DELIMITER || G_EOL;
      --PUT(L_BUFFER);
      FND_FILE.PUT_LINE(FND_FILE.LOG,L_BUFFER);
    END IF;
    RETURN TRUE;
  END BEFOREREPORT;

  FUNCTION P_REPORT_YEARVALIDTRIGGER RETURN BOOLEAN IS
  BEGIN
    IF P_PAYROLL_PERIOD_DATE_END_T IS NOT NULL THEN
      P_REPORT_YEAR := TO_CHAR(FND_DATE.CANONICAL_TO_DATE(P_PAYROLL_PERIOD_DATE_END_T)
                              ,'YYYY');
    ELSE
      P_REPORT_YEAR := TO_CHAR(SYSDATE
                              ,'YYYY');
    END IF;
    RETURN (TRUE);
  END P_REPORT_YEARVALIDTRIGGER;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    --HR_STANDARD.EVENT('AFTER REPORT');
    FND_FILE.PUT_LINE(1
                     ,'Total employees of the establishments: ' || C_ALL_TOTAL);
    FND_FILE.PUT_LINE(1
                     ,' ');
    IF P_AUDIT_REPORT = 'Y' THEN
      --CLOSE;
      null;
    END IF;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION CF_SET_DEFAULTSFORMULA RETURN NUMBER IS
    CURSOR C_DEFAULTS IS
      SELECT
        ORG_INFORMATION1,
        ORG_INFORMATION2,
        ORG_INFORMATION3,
        ORG_INFORMATION4,
        ORG_INFORMATION5,
        ORG_INFORMATION6,
        ORG_INFORMATION8,
        ORG_INFORMATION9,
        ORG_INFORMATION11,
        ORG_INFORMATION12
      FROM
        HR_ORGANIZATION_INFORMATION
      WHERE ORGANIZATION_ID = C_PARENT_ORG_ID
        AND ORG_INFORMATION_CONTEXT = 'VETS_EEO_Dup';
    L_DEFAULT C_DEFAULTS%ROWTYPE;
  BEGIN
    OPEN C_DEFAULTS;
    FETCH C_DEFAULTS
     INTO L_DEFAULT;
    IF C_DEFAULTS%NOTFOUND THEN
      NULL;
    ELSE
      C_DEF_SIC := L_DEFAULT.ORG_INFORMATION1;
      C_DEF_NAICS := NVL(L_DEFAULT.ORG_INFORMATION2
                        ,L_DEFAULT.ORG_INFORMATION1);
      C_DEF_GRE := L_DEFAULT.ORG_INFORMATION3;
      C_DEF_DUNS := L_DEFAULT.ORG_INFORMATION4;
      C_DEF_GOV_CON := L_DEFAULT.ORG_INFORMATION5;
      C_DEF_APPRENT := L_DEFAULT.ORG_INFORMATION6;
      C_DEF_ACTIV_1 := UPPER(LTRIM(RTRIM(L_DEFAULT.ORG_INFORMATION8)));
      C_DEF_ACTIV_2 := UPPER(LTRIM(RTRIM(L_DEFAULT.ORG_INFORMATION9)));
      C_DEF_ACTIV_3 := UPPER(LTRIM(RTRIM(L_DEFAULT.ORG_INFORMATION11)));
      C_DEF_ACTIV_4 := UPPER(LTRIM(RTRIM(L_DEFAULT.ORG_INFORMATION12)));
    END IF;
    CLOSE C_DEFAULTS;
    RETURN NULL;
  END CF_SET_DEFAULTSFORMULA;

  FUNCTION C_TOT_EMPSFORMULA(EST_NODE_ID IN NUMBER
                            ,AFFILIATED IN VARCHAR2
                            ,EST_REP_NAME IN VARCHAR2) RETURN NUMBER IS
    L_COUNT_EMPS NUMBER := 0;
  BEGIN
    SELECT
      COUNT(PEO.PERSON_ID)
    INTO L_COUNT_EMPS
    FROM
      PER_ALL_ASSIGNMENTS_F ASS,
      PER_ALL_PEOPLE_F PEO,
      PER_JOBS_VL JOB
    WHERE PEO.PERSON_ID = ASS.PERSON_ID
      AND PEO.PER_INFORMATION1 is not NULL
      AND JOB.JOB_INFORMATION_CATEGORY = 'US'
      AND P_PAYROLL_PERIOD_DATE_START_T <= NVL(JOB.DATE_TO
       ,P_PAYROLL_PERIOD_DATE_END_T)
      AND P_PAYROLL_PERIOD_DATE_END_T >= JOB.DATE_FROM
      AND JOB.JOB_INFORMATION1 is not NULL
      AND ASS.JOB_ID = JOB.JOB_ID
      AND PEO.EFFECTIVE_START_DATE = (
      SELECT
        MAX(PEO1.EFFECTIVE_START_DATE)
      FROM
        PER_PEOPLE_F PEO1
      WHERE P_PAYROLL_PERIOD_DATE_START_T <= PEO1.EFFECTIVE_END_DATE
        AND P_PAYROLL_PERIOD_DATE_END_T >= PEO1.EFFECTIVE_START_DATE
        AND PEO.PERSON_ID = PEO1.PERSON_ID
        AND PEO1.CURRENT_EMPLOYEE_FLAG = 'Y' )
      AND ASS.EFFECTIVE_START_DATE = (
      SELECT
        MAX(ASS1.EFFECTIVE_START_DATE)
      FROM
        PER_ALL_ASSIGNMENTS_F ASS1
      WHERE P_PAYROLL_PERIOD_DATE_START_T <= ASS1.EFFECTIVE_END_DATE
        AND P_PAYROLL_PERIOD_DATE_END_T >= ASS1.EFFECTIVE_START_DATE
        AND ASS.PERSON_ID = ASS1.PERSON_ID
        AND ASS1.ASSIGNMENT_TYPE = 'E'
        AND ASS1.PRIMARY_FLAG = 'Y' )
      AND ASS.ASSIGNMENT_TYPE = 'E'
      AND ASS.PRIMARY_FLAG = 'Y'
      AND ASS.BUSINESS_GROUP_ID = P_BUSINESS_GROUP_ID
      AND PEO.BUSINESS_GROUP_ID = P_BUSINESS_GROUP_ID
      AND JOB.BUSINESS_GROUP_ID = P_BUSINESS_GROUP_ID
      AND EXISTS (
      SELECT
        'X'
      FROM
        HR_ORGANIZATION_INFORMATION HOI1,
        HR_ORGANIZATION_INFORMATION HOI2
      WHERE TO_CHAR(ASS.ASSIGNMENT_STATUS_TYPE_ID) = HOI1.ORG_INFORMATION1
        AND HOI1.ORG_INFORMATION_CONTEXT = 'Reporting Statuses'
        AND HOI1.ORGANIZATION_ID = P_BUSINESS_GROUP_ID
        AND ASS.EMPLOYMENT_CATEGORY = HOI2.ORG_INFORMATION1
        AND HOI2.ORGANIZATION_ID = P_BUSINESS_GROUP_ID
        AND HOI2.ORG_INFORMATION_CONTEXT = 'Reporting Categories' )
      AND P_PAYROLL_PERIOD_DATE_START_T <= ASS.EFFECTIVE_END_DATE
      AND P_PAYROLL_PERIOD_DATE_END_T >= ASS.EFFECTIVE_START_DATE
      AND ASS.LOCATION_ID in (
      SELECT
        DISTINCT
        PGN.ENTITY_ID
      FROM
        PER_GEN_HIERARCHY_NODES PGN
      WHERE PGN.HIERARCHY_VERSION_ID = P_HIERARCHY_VERSION_ID
        AND ( PGN.HIERARCHY_NODE_ID = C_TOT_EMPSFORMULA.EST_NODE_ID
      OR PGN.PARENT_HIERARCHY_NODE_ID = C_TOT_EMPSFORMULA.EST_NODE_ID )
        AND PGN.NODE_TYPE in ( 'EST' , 'LOC' ) );
    /*SRW.MESSAGE(99
               ,'est_node_id         : ' || EST_NODE_ID)*/NULL;
    /*SRW.MESSAGE(99
               ,'l_couunt_emps       : ' || L_COUNT_EMPS)*/NULL;
    IF L_COUNT_EMPS > 99 THEN
      C_100_EMPS := 'Y';
    ELSE
      C_100_EMPS := 'N';
    END IF;
    CP_TOT_EMPS := L_COUNT_EMPS;
    CP_REPORT_YEAR := P_REPORT_YEAR;
    C_AFFILIATED := AFFILIATED;
    IF CP_REPORT_TYPE = 'Headquarters Report - Type 3' OR CP_TOT_EMPS > P_MINIMUM_NO_OF_EMPLOYEES OR CP_REPORT_TYPE = 'Single Establishment Employer Report - Type 1' THEN
      C_ALL_TOTAL := C_ALL_TOTAL + L_COUNT_EMPS;
      FND_FILE.PUT_LINE(1
                       ,CP_REPORT_TYPE);
      FND_FILE.PUT_LINE(1
                       ,'Establishment reporting name: ' || EST_REP_NAME);
      FND_FILE.PUT_LINE(1
                       ,'Total employees             : ' || L_COUNT_EMPS);
      FND_FILE.PUT_LINE(1
                       ,' ');
    END IF;
    RETURN (L_COUNT_EMPS);
  END C_TOT_EMPSFORMULA;

  FUNCTION CF_SET_EST_ACTIVFORMULA(EST_NODE_ID IN NUMBER) RETURN NUMBER IS
    CURSOR C_EST_ACT IS
      SELECT
        NVL(HLEI.LEI_INFORMATION5
           ,C_DEF_ACTIV_1),
        NVL(HLEI.LEI_INFORMATION6
           ,C_DEF_ACTIV_2),
        NVL(HLEI.LEI_INFORMATION7
           ,C_DEF_ACTIV_3),
        NVL(HLEI.LEI_INFORMATION8
           ,C_DEF_ACTIV_4)
      FROM
        HR_LOCATION_EXTRA_INFO HLEI,
        PER_GEN_HIERARCHY_NODES PGHN
      WHERE HLEI.INFORMATION_TYPE = 'EEO-1 Specific Information'
        AND HLEI.LEI_INFORMATION_CATEGORY = 'EEO-1 Specific Information'
        AND HLEI.LOCATION_ID = PGHN.ENTITY_ID
        AND PGHN.PARENT_HIERARCHY_NODE_ID = C_PARENT_NODE_ID
        AND PGHN.HIERARCHY_NODE_ID = EST_NODE_ID
        AND PGHN.NODE_TYPE = 'EST';
    L_EST_ACT_1 VARCHAR2(60) := NULL;
    L_EST_ACT_2 VARCHAR2(60) := NULL;
    L_EST_ACT_3 VARCHAR2(60) := NULL;
    L_EST_ACT_4 VARCHAR2(60) := NULL;
  BEGIN
    OPEN C_EST_ACT;
    FETCH C_EST_ACT
     INTO L_EST_ACT_1,L_EST_ACT_2,L_EST_ACT_3,L_EST_ACT_4;
    C_EST_ACTIV_1 := UPPER(LTRIM(RTRIM(L_EST_ACT_1)));
    C_EST_ACTIV_2 := UPPER(LTRIM(RTRIM(L_EST_ACT_2)));
    C_EST_ACTIV_3 := UPPER(LTRIM(RTRIM(L_EST_ACT_3)));
    C_EST_ACTIV_4 := UPPER(LTRIM(RTRIM(L_EST_ACT_4)));
    RETURN NULL;
  END CF_SET_EST_ACTIVFORMULA;

  FUNCTION C_TOT_CATFORMULA(C_TOT_HLMALE IN NUMBER
                           ,C_TOT_HLFEMALE IN NUMBER
                           ,C_TOT_TMRACESMALE IN NUMBER
                           ,C_TOT_TMRACESFEMALE IN NUMBER
                           ,C_TOT_WMALE IN NUMBER
                           ,C_TOT_BMALE IN NUMBER
                           ,C_TOT_HMALE IN NUMBER
                           ,C_TOT_AMALE IN NUMBER
                           ,C_TOT_IMALE IN NUMBER
                           ,C_TOT_WFEMALE IN NUMBER
                           ,C_TOT_BFEMALE IN NUMBER
                           ,C_TOT_HFEMALE IN NUMBER
                           ,C_TOT_AFEMALE IN NUMBER
                           ,C_TOT_IFEMALE IN NUMBER) RETURN NUMBER IS
    L_TOT_CAT NUMBER(10);
  BEGIN
    L_TOT_CAT := C_TOT_HLMALE + C_TOT_HLFEMALE + C_TOT_TMRACESMALE + C_TOT_TMRACESFEMALE + C_TOT_WMALE + C_TOT_BMALE + C_TOT_HMALE + C_TOT_AMALE + C_TOT_IMALE + C_TOT_WFEMALE + C_TOT_BFEMALE + C_TOT_HFEMALE + C_TOT_AFEMALE + C_TOT_IFEMALE;
    RETURN (L_TOT_CAT);
  END C_TOT_CATFORMULA;

  FUNCTION CF_SET_REPFORMULA(HEADQUARTERS IN VARCHAR2
                            ,EST_UNIT IN VARCHAR2) RETURN NUMBER IS
  BEGIN
    IF C_NO_OF_ESTABLISHMENTS = 1 THEN
      CP_REPORT_TYPE := 'Single Establishment Employer Report - Type 1';
    ELSIF C_NO_OF_ESTABLISHMENTS > 1 AND HEADQUARTERS = 'Y' THEN
      CP_REPORT_TYPE := 'Headquarters Report - Type 3';
    ELSIF EST_UNIT IS NULL THEN
      CP_REPORT_TYPE := 'Establishment Report - Type 9';
    ELSE
      CP_REPORT_TYPE := 'Establishment Report - Type 4';
    END IF;
    CP_PAYROLL_PERIOD_DATE_START := C_PAYROLL_PERIOD_DATE_START;
    CP_PAYROLL_PERIOD_DATE_END := C_PAYROLL_PERIOD_DATE_END;
    RETURN NULL;
  END CF_SET_REPFORMULA;

  FUNCTION CF_SET_CURR_HWFORMULA(ESTAB_STATE IN VARCHAR2
                                ,CONS_JOB_CATEGORY_CODE IN VARCHAR2
                                ,EST_NODE_ID IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF ESTAB_STATE = 'HI' THEN
      SELECT
        COUNT('person'),
        COUNT(DECODE(PEO.SEX
                    ,'M'
                    ,1
                    ,NULL)),
        COUNT(DECODE(PEO.SEX
                    ,'F'
                    ,1
                    ,NULL))
      INTO CP_HW_CAT,CP_HW_MALE,CP_HW_FEMALE
      FROM
        PER_ALL_PEOPLE_F PEO,
        PER_ALL_ASSIGNMENTS_F ASS,
        PER_JOBS_VL JOB
      WHERE PEO.PERSON_ID = ASS.PERSON_ID
        AND PEO.PER_INFORMATION1 is not NULL
        AND JOB.JOB_INFORMATION_CATEGORY = 'US'
        AND P_PAYROLL_PERIOD_DATE_START_T <= NVL(JOB.DATE_TO
         ,P_PAYROLL_PERIOD_DATE_END_T)
        AND P_PAYROLL_PERIOD_DATE_END_T >= JOB.DATE_FROM
        AND JOB.JOB_INFORMATION1 = CONS_JOB_CATEGORY_CODE
        AND ASS.JOB_ID = JOB.JOB_ID
        AND ASS.BUSINESS_GROUP_ID = P_BUSINESS_GROUP_ID
        AND PEO.BUSINESS_GROUP_ID = P_BUSINESS_GROUP_ID
        AND JOB.BUSINESS_GROUP_ID = P_BUSINESS_GROUP_ID
        AND PEO.EFFECTIVE_START_DATE = (
        SELECT
          MAX(PEO1.EFFECTIVE_START_DATE)
        FROM
          PER_ALL_PEOPLE_F PEO1
        WHERE P_PAYROLL_PERIOD_DATE_START_T <= PEO1.EFFECTIVE_END_DATE
          AND P_PAYROLL_PERIOD_DATE_END_T >= PEO1.EFFECTIVE_START_DATE
          AND PEO.PERSON_ID = PEO1.PERSON_ID
          AND PEO1.CURRENT_EMPLOYEE_FLAG = 'Y' )
        AND ASS.EFFECTIVE_START_DATE = (
        SELECT
          MAX(ASS1.EFFECTIVE_START_DATE)
        FROM
          PER_ALL_ASSIGNMENTS_F ASS1
        WHERE P_PAYROLL_PERIOD_DATE_START_T <= ASS1.EFFECTIVE_END_DATE
          AND P_PAYROLL_PERIOD_DATE_END_T >= ASS1.EFFECTIVE_START_DATE
          AND ASS.PERSON_ID = ASS1.PERSON_ID
          AND ASS1.ASSIGNMENT_TYPE = 'E'
          AND ASS1.PRIMARY_FLAG = 'Y' )
        AND ASS.ASSIGNMENT_TYPE = 'E'
        AND ASS.PRIMARY_FLAG = 'Y'
        AND EXISTS (
        SELECT
          'X'
        FROM
          HR_ORGANIZATION_INFORMATION HOI1,
          HR_ORGANIZATION_INFORMATION HOI2
        WHERE TO_CHAR(ASS.ASSIGNMENT_STATUS_TYPE_ID) = HOI1.ORG_INFORMATION1
          AND HOI1.ORG_INFORMATION_CONTEXT = 'Reporting Statuses'
          AND HOI1.ORGANIZATION_ID = P_BUSINESS_GROUP_ID
          AND ASS.EMPLOYMENT_CATEGORY = HOI2.ORG_INFORMATION1
          AND HOI2.ORGANIZATION_ID = P_BUSINESS_GROUP_ID
          AND HOI2.ORG_INFORMATION_CONTEXT = 'Reporting Categories' )
        AND ASS.LOCATION_ID in (
        SELECT
          DISTINCT
          PGN.ENTITY_ID
        FROM
          PER_GEN_HIERARCHY_NODES PGN
        WHERE ( PGN.HIERARCHY_NODE_ID = EST_NODE_ID
        OR PGN.PARENT_HIERARCHY_NODE_ID = EST_NODE_ID )
          AND PGN.HIERARCHY_VERSION_ID = P_HIERARCHY_VERSION_ID
          AND PGN.NODE_TYPE in ( 'EST' , 'LOC' ) );
    ELSE
      NULL;
    END IF;
    RETURN (NULL);
  END CF_SET_CURR_HWFORMULA;

  FUNCTION CF_SET_AUD_HWFORMULA(ESTAB_STATE IN VARCHAR2
                               ,EST_NODE_ID IN NUMBER) RETURN NUMBER IS
    HW_AUD_TOT VARCHAR2(10);
    HW_AUD_MALE VARCHAR2(10);
    HW_AUD_FEMALE VARCHAR2(10);
  BEGIN
    IF ESTAB_STATE = 'HI' THEN
      BEGIN
        SELECT
          LEI_INFORMATION3 P_TOTAL,
          TO_NUMBER((LEI_INFORMATION4 + LEI_INFORMATION5 + LEI_INFORMATION6 + LEI_INFORMATION7 + LEI_INFORMATION8 + LEI_INFORMATION14 + LEI_INFORMATION16)) TOTALMALE,
          TO_NUMBER((LEI_INFORMATION9 + LEI_INFORMATION10 + LEI_INFORMATION11 + LEI_INFORMATION12 + LEI_INFORMATION13 + LEI_INFORMATION15 + LEI_INFORMATION17)) TOTALFEM
        INTO HW_AUD_TOT,HW_AUD_MALE,HW_AUD_FEMALE
        FROM
          HR_LOCATION_EXTRA_INFO LEI
        WHERE LEI_INFORMATION1 = CP_PREV_YEAR_FILED
          AND TO_CHAR(LEI.LOCATION_ID) in (
          SELECT
            DISTINCT
            PGN.ENTITY_ID
          FROM
            PER_GEN_HIERARCHY_NODES PGN
          WHERE PGN.HIERARCHY_VERSION_ID = P_HIERARCHY_VERSION_ID
            AND ( PGN.HIERARCHY_NODE_ID = EST_NODE_ID
          OR PGN.PARENT_HIERARCHY_NODE_ID = EST_NODE_ID )
            AND PGN.NODE_TYPE in ( 'EST' , 'LOC' ) );
        CP_HW_AUD_TOT := NULL;
        CP_HW_AUD_MALE := NULL;
        CP_HW_AUD_FEMALE := NULL;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          FND_MESSAGE.SET_NAME('PER'
                              ,'PER_75230_EST_CLASS_MISSING');
          /*SRW.MESSAGE('10'
                     ,FND_MESSAGE.GET)*/NULL;
          /*SRW.MESSAGE('20'
                     ,'message will talk about how there needs to be eit set up and assigned to resp')*/NULL;
          /*SRW.MESSAGE('30'
                     ,'also will suggest running report for previous year to fill in the figures.')*/NULL;
        WHEN OTHERS THEN
          NULL;
      END;
    END IF;
    RETURN NULL;
  END CF_SET_AUD_HWFORMULA;

  FUNCTION CF_100_EMPSFORMULA RETURN CHAR IS
    L_COUNT_EMPS NUMBER := 0;
  BEGIN
    SELECT
      COUNT('ass')
    INTO L_COUNT_EMPS
    FROM
      PER_ALL_ASSIGNMENTS_F ASS,
      PER_ALL_PEOPLE_F PEO,
      PER_JOBS_VL JOB
    WHERE PEO.PERSON_ID = ASS.PERSON_ID
      AND PEO.PER_INFORMATION1 is not NULL
      AND JOB.JOB_INFORMATION_CATEGORY = 'US'
      AND P_PAYROLL_PERIOD_DATE_START_T <= NVL(JOB.DATE_TO
       ,P_PAYROLL_PERIOD_DATE_END_T)
      AND P_PAYROLL_PERIOD_DATE_END_T >= JOB.DATE_FROM
      AND JOB.JOB_INFORMATION1 is not null
      AND ASS.JOB_ID = JOB.JOB_ID
      AND ASS.BUSINESS_GROUP_ID = P_BUSINESS_GROUP_ID
      AND ASS.ASSIGNMENT_TYPE = 'E'
      AND ASS.PRIMARY_FLAG = 'Y'
      AND ASS.EFFECTIVE_START_DATE = (
      SELECT
        MAX(ASS1.EFFECTIVE_START_DATE)
      FROM
        PER_ALL_ASSIGNMENTS_F ASS1
      WHERE P_PAYROLL_PERIOD_DATE_START_T <= ASS1.EFFECTIVE_END_DATE
        AND P_PAYROLL_PERIOD_DATE_END_T >= ASS1.EFFECTIVE_START_DATE
        AND ASS.PERSON_ID = ASS1.PERSON_ID
        AND ASS1.ASSIGNMENT_TYPE = 'E'
        AND ASS1.PRIMARY_FLAG = 'Y' )
      AND EXISTS (
      SELECT
        'X'
      FROM
        HR_ORGANIZATION_INFORMATION HOI1,
        HR_ORGANIZATION_INFORMATION HOI2
      WHERE TO_CHAR(ASS.ASSIGNMENT_STATUS_TYPE_ID) = HOI1.ORG_INFORMATION1
        AND HOI1.ORG_INFORMATION_CONTEXT = 'Reporting Statuses'
        AND HOI1.ORGANIZATION_ID = P_BUSINESS_GROUP_ID
        AND ASS.EMPLOYMENT_CATEGORY = HOI2.ORG_INFORMATION1
        AND HOI2.ORGANIZATION_ID = P_BUSINESS_GROUP_ID
        AND HOI2.ORG_INFORMATION_CONTEXT = 'Reporting Categories' )
      AND P_PAYROLL_PERIOD_DATE_START_T <= ASS.EFFECTIVE_END_DATE
      AND P_PAYROLL_PERIOD_DATE_END_T >= ASS.EFFECTIVE_START_DATE
      AND ASS.LOCATION_ID in (
      SELECT
        DISTINCT
        ENTITY_ID
      FROM
        PER_GEN_HIERARCHY_NODES
      WHERE HIERARCHY_VERSION_ID = P_HIERARCHY_VERSION_ID );
    IF L_COUNT_EMPS >= 100 THEN
      RETURN ('Y');
    ELSE
      RETURN ('N');
    END IF;
  END CF_100_EMPSFORMULA;

  FUNCTION CF_CREATEUPD_ARCHEITFORMULA(EST_NODE_ID IN NUMBER
                                      ,C_TOT_CAT IN NUMBER
                                      ,C_TOT_WMALE IN NUMBER
                                      ,C_TOT_BMALE IN NUMBER
                                      ,C_TOT_HMALE IN NUMBER
                                      ,C_TOT_AMALE IN NUMBER
                                      ,C_TOT_IMALE IN NUMBER
                                      ,C_TOT_WFEMALE IN NUMBER
                                      ,C_TOT_BFEMALE IN NUMBER
                                      ,C_TOT_HFEMALE IN NUMBER
                                      ,C_TOT_AFEMALE IN NUMBER
                                      ,C_TOT_IFEMALE IN NUMBER
                                      ,C_TOT_HLMALE IN NUMBER
                                      ,C_TOT_HLFEMALE IN NUMBER
                                      ,C_TOT_TMRACESMALE IN NUMBER
                                      ,C_TOT_TMRACESFEMALE IN NUMBER) RETURN NUMBER IS
    P_UPDATE VARCHAR2(1) := 'C';
    L_LOCATION_ID VARCHAR2(60);
    L_LOCATION_CODE VARCHAR2(50);
    L_LOCATION_EXTRA_INFO_ID NUMBER := NULL;
    L_OBJECT_VERSION_NUMBER NUMBER := NULL;
    L_EIT_COUNT NUMBER := 0;
    L_MIN_YEAR VARCHAR2(4) := NULL;
  BEGIN
    IF CP_REPORT_TYPE = 'Establishment Report - Type 4' AND CP_TOT_EMPS <= P_MINIMUM_NO_OF_EMPLOYEES THEN
      NULL;
    ELSE
      IF P_REPORT_MODE = 'F' THEN
        BEGIN
          SELECT
            ELOC.LOCATION_ID,
            ELOC.LOCATION_CODE
          INTO L_LOCATION_ID,L_LOCATION_CODE
          FROM
            PER_GEN_HIERARCHY_NODES PGN,
            HR_LOCATIONS_ALL ELOC
          WHERE ( HIERARCHY_NODE_ID = EST_NODE_ID
          OR PARENT_HIERARCHY_NODE_ID = EST_NODE_ID )
            AND HIERARCHY_VERSION_ID = P_HIERARCHY_VERSION_ID
            AND PGN.NODE_TYPE = 'EST'
            AND ELOC.LOCATION_ID = PGN.ENTITY_ID;
        END;
        BEGIN
          SELECT
            'U',
            LOCATION_EXTRA_INFO_ID
          INTO P_UPDATE,L_LOCATION_EXTRA_INFO_ID
          FROM
            HR_LOCATION_EXTRA_INFO
          WHERE LEI_INFORMATION1 = P_REPORT_YEAR
            AND LEI_INFORMATION_CATEGORY = 'EEO-1 Archive Information'
            AND LOCATION_ID = L_LOCATION_ID;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            P_UPDATE := 'C';
            /*SRW.MESSAGE('20'
                       ,'                      ')*/NULL;
            /*SRW.MESSAGE('20'
                       ,'need to create new eit for location ' || L_LOCATION_ID || ' ' || L_LOCATION_CODE)*/NULL;
          WHEN OTHERS THEN
            NULL;
        END;
        IF P_UPDATE = 'U' THEN
          /*SRW.MESSAGE('10'
                     ,'p_update ' || P_UPDATE || ' location_id to update is ' || L_LOCATION_ID || ' ' || L_LOCATION_CODE)*/NULL;
          /*SRW.MESSAGE('20'
                     ,' p_location_extra_info_id to delete for update is ' || L_LOCATION_EXTRA_INFO_ID)*/NULL;
          BEGIN
            SELECT
              OBJECT_VERSION_NUMBER
            INTO L_OBJECT_VERSION_NUMBER
            FROM
              HR_LOCATION_EXTRA_INFO
            WHERE LOCATION_EXTRA_INFO_ID = L_LOCATION_EXTRA_INFO_ID;
          END;
          /*SRW.MESSAGE('25'
                     ,'object version number to delete for update is ' || L_OBJECT_VERSION_NUMBER)*/NULL;
          BEGIN
            HR_LOCATION_EXTRA_INFO_API.DELETE_LOCATION_EXTRA_INFO(P_VALIDATE => FALSE
                                                                 ,P_LOCATION_EXTRA_INFO_ID => L_LOCATION_EXTRA_INFO_ID
                                                                 ,P_OBJECT_VERSION_NUMBER => L_OBJECT_VERSION_NUMBER);
          END;
          COMMIT;
          P_UPDATE := 'C';
        END IF;
        IF P_UPDATE = 'C' THEN
          /*SRW.MESSAGE('21'
                     ,'p_update ' || P_UPDATE || ' location_id ' || L_LOCATION_ID)*/NULL;
          /*SRW.MESSAGE('22'
                     ,'need to create new eit')*/NULL;
          BEGIN
            HR_LOCATION_EXTRA_INFO_API.CREATE_LOCATION_EXTRA_INFO(P_VALIDATE => FALSE
                                                                 ,P_LOCATION_ID => L_LOCATION_ID
                                                                 ,P_INFORMATION_TYPE => 'EEO-1 Archive Information'
                                                                 ,P_LEI_INFORMATION_CATEGORY => 'EEO-1 Archive Information'
                                                                 ,P_LEI_INFORMATION1 => P_REPORT_YEAR
                                                                 ,P_LEI_INFORMATION2 => P_CONC_REQUEST_ID
                                                                 ,P_LEI_INFORMATION3 => C_TOT_CAT
                                                                 ,P_LEI_INFORMATION4 => C_TOT_WMALE
                                                                 ,P_LEI_INFORMATION5 => C_TOT_BMALE
                                                                 ,P_LEI_INFORMATION6 => C_TOT_HMALE
                                                                 ,P_LEI_INFORMATION7 => C_TOT_AMALE
                                                                 ,P_LEI_INFORMATION8 => C_TOT_IMALE
                                                                 ,P_LEI_INFORMATION9 => C_TOT_WFEMALE
                                                                 ,P_LEI_INFORMATION10 => C_TOT_BFEMALE
                                                                 ,P_LEI_INFORMATION11 => C_TOT_HFEMALE
                                                                 ,P_LEI_INFORMATION12 => C_TOT_AFEMALE
                                                                 ,P_LEI_INFORMATION13 => C_TOT_IFEMALE
                                                                 ,P_LEI_INFORMATION14 => C_TOT_HLMALE
                                                                 ,P_LEI_INFORMATION15 => C_TOT_HLFEMALE
                                                                 ,P_LEI_INFORMATION16 => C_TOT_TMRACESMALE
                                                                 ,P_LEI_INFORMATION17 => C_TOT_TMRACESFEMALE
                                                                 ,P_LOCATION_EXTRA_INFO_ID => L_LOCATION_EXTRA_INFO_ID
                                                                 ,P_OBJECT_VERSION_NUMBER => L_OBJECT_VERSION_NUMBER);
          END;
          COMMIT;
          /*SRW.MESSAGE('23'
                     ,'                                                                          ')*/NULL;
          /*SRW.MESSAGE('23'
                     ,'eit created for location_id ' || L_LOCATION_ID || ' year ' || P_REPORT_YEAR)*/NULL;
          /*SRW.MESSAGE('24'
                     ,'out params: location_extra_info_id  is ' || L_LOCATION_EXTRA_INFO_ID)*/NULL;
          /*SRW.MESSAGE('25'
                     ,'object version number is ' || L_OBJECT_VERSION_NUMBER)*/NULL;
          /*SRW.MESSAGE('25'
                     ,'grand total is ' || C_TOT_CAT)*/NULL;
          /*SRW.MESSAGE('23'
                     ,'                                                                          ')*/NULL;
        END IF;
        BEGIN
          BEGIN
            SELECT
              count(*)
            INTO L_EIT_COUNT
            FROM
              HR_LOCATION_EXTRA_INFO LEI
            WHERE LOCATION_ID = L_LOCATION_ID
              AND INFORMATION_TYPE = 'EEO-1 Archive Information';
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              NULL;
            WHEN OTHERS THEN
              NULL;
          END;
          IF L_EIT_COUNT > 4 THEN
            BEGIN
              SELECT
                MIN(LEI_INFORMATION1)
              INTO L_MIN_YEAR
              FROM
                HR_LOCATION_EXTRA_INFO LEI
              WHERE LOCATION_ID = L_LOCATION_ID
                AND INFORMATION_TYPE = 'EEO-1 Archive Information';
            END;
            BEGIN
              SELECT
                LOCATION_EXTRA_INFO_ID,
                OBJECT_VERSION_NUMBER
              INTO L_LOCATION_EXTRA_INFO_ID,L_OBJECT_VERSION_NUMBER
              FROM
                HR_LOCATION_EXTRA_INFO LEI
              WHERE LEI_INFORMATION1 = L_MIN_YEAR
                AND INFORMATION_TYPE = 'EEO-1 Archive Information'
                AND LOCATION_ID = L_LOCATION_ID;
            END;
            BEGIN
              HR_LOCATION_EXTRA_INFO_API.DELETE_LOCATION_EXTRA_INFO(P_VALIDATE => FALSE
                                                                   ,P_LOCATION_EXTRA_INFO_ID => L_LOCATION_EXTRA_INFO_ID
                                                                   ,P_OBJECT_VERSION_NUMBER => L_OBJECT_VERSION_NUMBER);
            END;
            /*SRW.MESSAGE('999999'
                       ,' there are over 4 Archive EITs for location id ' || L_LOCATION_ID || ' so deleting for year ' || L_MIN_YEAR)*/NULL;
          END IF;
        END;
      END IF;
    END IF;
    RETURN (NULL);
  END CF_CREATEUPD_ARCHEITFORMULA;

  FUNCTION CF_AUDIT_REPORT(CONS_JOB_CATEGORY_CODE IN VARCHAR2
                          ,EST_NODE_ID IN NUMBER) RETURN NUMBER IS
    CURSOR C_PERSONS IS
      SELECT
        PEO.PERSON_ID,
        PEO.FIRST_NAME,
        PEO.LAST_NAME,
        PEO.SEX,
        PEO.PER_INFORMATION1 ETHNIC,
        PEO.EMPLOYEE_NUMBER,
        ASS.ASSIGNMENT_ID,
        ASS.LOCATION_ID,
        HL.LOCATION_CODE,
        JOB.NAME JOB_NAME,
        ASS.JOB_ID
      FROM
        PER_ALL_PEOPLE_F PEO,
        PER_ALL_ASSIGNMENTS_F ASS,
        PER_JOBS_VL JOB,
        HR_LOCATIONS_ALL HL
      WHERE PEO.PERSON_ID = ASS.PERSON_ID
        AND PEO.PER_INFORMATION1 is not null
        AND PEO.PER_INFORMATION_CATEGORY = 'US'
        AND JOB.JOB_INFORMATION_CATEGORY = 'US'
        AND P_PAYROLL_PERIOD_DATE_START_T <= NVL(JOB.DATE_TO
         ,P_PAYROLL_PERIOD_DATE_END_T)
        AND P_PAYROLL_PERIOD_DATE_END_T >= JOB.DATE_FROM
        AND JOB.JOB_INFORMATION1 = CONS_JOB_CATEGORY_CODE
        AND ASS.JOB_ID = JOB.JOB_ID
        AND PEO.EFFECTIVE_START_DATE = (
        SELECT
          MAX(PEO1.EFFECTIVE_START_DATE)
        FROM
          PER_PEOPLE_F PEO1
        WHERE P_PAYROLL_PERIOD_DATE_START_T <= PEO1.EFFECTIVE_END_DATE
          AND P_PAYROLL_PERIOD_DATE_END_T >= PEO1.EFFECTIVE_START_DATE
          AND PEO.PERSON_ID = PEO1.PERSON_ID
          AND PEO1.CURRENT_EMPLOYEE_FLAG = 'Y' )
        AND ASS.EFFECTIVE_START_DATE = (
        SELECT
          MAX(ASS1.EFFECTIVE_START_DATE)
        FROM
          PER_ASSIGNMENTS_F ASS1
        WHERE P_PAYROLL_PERIOD_DATE_START_T <= ASS1.EFFECTIVE_END_DATE
          AND P_PAYROLL_PERIOD_DATE_END_T >= ASS1.EFFECTIVE_START_DATE
          AND ASS.PERSON_ID = ASS1.PERSON_ID
          AND ASS1.ASSIGNMENT_TYPE = 'E'
          AND ASS1.PRIMARY_FLAG = 'Y' )
        AND ASS.ASSIGNMENT_TYPE = 'E'
        AND ASS.PRIMARY_FLAG = 'Y'
        AND ASS.BUSINESS_GROUP_ID = P_BUSINESS_GROUP_ID
        AND PEO.BUSINESS_GROUP_ID = P_BUSINESS_GROUP_ID
        AND JOB.BUSINESS_GROUP_ID = P_BUSINESS_GROUP_ID
        AND EXISTS (
        SELECT
          'X'
        FROM
          HR_ORGANIZATION_INFORMATION HOI1,
          HR_ORGANIZATION_INFORMATION HOI2
        WHERE TO_CHAR(ASS.ASSIGNMENT_STATUS_TYPE_ID) = HOI1.ORG_INFORMATION1
          AND HOI1.ORG_INFORMATION_CONTEXT = 'Reporting Statuses'
          AND HOI1.ORGANIZATION_ID = P_BUSINESS_GROUP_ID
          AND ASS.EMPLOYMENT_CATEGORY = HOI2.ORG_INFORMATION1
          AND HOI2.ORGANIZATION_ID = P_BUSINESS_GROUP_ID
          AND HOI2.ORG_INFORMATION_CONTEXT = 'Reporting Categories' )
        AND HL.LOCATION_ID = ASS.LOCATION_ID
        AND ASS.LOCATION_ID in (
        SELECT
          DISTINCT
          PGN.ENTITY_ID
        FROM
          PER_GEN_HIERARCHY_NODES PGN
        WHERE PGN.HIERARCHY_VERSION_ID = P_HIERARCHY_VERSION_ID
          AND ( PGN.HIERARCHY_NODE_ID = EST_NODE_ID
        OR PGN.PARENT_HIERARCHY_NODE_ID = EST_NODE_ID )
          AND PGN.NODE_TYPE in ( 'EST' , 'LOC' ) )
      ORDER BY
        LAST_NAME;
    L_BUFFER VARCHAR2(2000);
    G_DELIMITER VARCHAR2(1) := ',';
    G_EOL VARCHAR2(1) := FND_GLOBAL.LOCAL_CHR(10);
  BEGIN
    IF P_AUDIT_REPORT = 'Y' THEN
      IF (CP_REPORT_TYPE = 'Establishment Report - Type 4' OR CP_REPORT_TYPE = 'Establishment Report - Type 9') AND CP_TOT_EMPS <= P_MINIMUM_NO_OF_EMPLOYEES THEN
        RETURN NULL;
      ELSE
        FOR per IN C_PERSONS LOOP
          L_BUFFER := PER.PERSON_ID || G_DELIMITER || PER.LAST_NAME || G_DELIMITER || NVL(PER.FIRST_NAME
                         ,' ') || G_DELIMITER || NVL(PER.EMPLOYEE_NUMBER
                         ,' ') || G_DELIMITER || NVL(PER.SEX
                         ,' ') || G_DELIMITER || NVL(PER.ETHNIC
                         ,' ') || G_DELIMITER || PER.ASSIGNMENT_ID || G_DELIMITER || NVL(PER.JOB_ID
                         ,' ') || G_DELIMITER || NVL(PER.JOB_NAME
                         ,' ') || G_DELIMITER || NVL(PER.LOCATION_ID
                         ,' ') || G_DELIMITER || NVL(PER.LOCATION_CODE
                         ,' ') || G_DELIMITER || G_EOL;
          --PUT(L_BUFFER);
          FND_FILE.PUT_LINE(FND_FILE.LOG,L_BUFFER);
        END LOOP;
      END IF;
    END IF;
    RETURN NULL;
  END CF_AUDIT_REPORT;

  FUNCTION C_DEF_SIC_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_DEF_SIC;
  END C_DEF_SIC_P;

  FUNCTION C_DEF_NAICS_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_DEF_NAICS;
  END C_DEF_NAICS_P;

  FUNCTION C_DEF_GRE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_DEF_GRE;
  END C_DEF_GRE_P;

  FUNCTION C_DEF_DUNS_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_DEF_DUNS;
  END C_DEF_DUNS_P;

  FUNCTION C_DEF_GOV_CON_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_DEF_GOV_CON;
  END C_DEF_GOV_CON_P;

  FUNCTION C_DEF_APPRENT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_DEF_APPRENT;
  END C_DEF_APPRENT_P;

  FUNCTION C_DEF_ACTIV_1_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_DEF_ACTIV_1;
  END C_DEF_ACTIV_1_P;

  FUNCTION C_DEF_ACTIV_2_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_DEF_ACTIV_2;
  END C_DEF_ACTIV_2_P;

  FUNCTION C_DEF_ACTIV_3_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_DEF_ACTIV_3;
  END C_DEF_ACTIV_3_P;

  FUNCTION C_DEF_ACTIV_4_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_DEF_ACTIV_4;
  END C_DEF_ACTIV_4_P;

  FUNCTION CP_REPORT_YEAR_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_REPORT_YEAR;
  END CP_REPORT_YEAR_P;

  FUNCTION CP_TOT_EMPS_P RETURN NUMBER IS
  BEGIN
    RETURN CP_TOT_EMPS;
  END CP_TOT_EMPS_P;

  FUNCTION C_100_EMPS_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_100_EMPS;
  END C_100_EMPS_P;

  FUNCTION C_EST_ACTIV_1_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_EST_ACTIV_1;
  END C_EST_ACTIV_1_P;

  FUNCTION C_EST_ACTIV_2_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_EST_ACTIV_2;
  END C_EST_ACTIV_2_P;

  FUNCTION C_EST_ACTIV_3_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_EST_ACTIV_3;
  END C_EST_ACTIV_3_P;

  FUNCTION C_EST_ACTIV_4_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_EST_ACTIV_4;
  END C_EST_ACTIV_4_P;

  FUNCTION C_AFFILIATED_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_AFFILIATED;
  END C_AFFILIATED_P;

  FUNCTION CP_PAYROLL_PERIOD_DATE_START_P RETURN DATE IS
  BEGIN
    RETURN CP_PAYROLL_PERIOD_DATE_START;
  END CP_PAYROLL_PERIOD_DATE_START_P;

  FUNCTION CP_PAYROLL_PERIOD_DATE_END_P RETURN DATE IS
  BEGIN
    RETURN CP_PAYROLL_PERIOD_DATE_END;
  END CP_PAYROLL_PERIOD_DATE_END_P;

  FUNCTION CP_REPORT_TYPE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_REPORT_TYPE;
  END CP_REPORT_TYPE_P;

  FUNCTION CP_HW_AUD_MALE_P RETURN NUMBER IS
  BEGIN
    RETURN CP_HW_AUD_MALE;
  END CP_HW_AUD_MALE_P;

  FUNCTION CP_HW_AUD_FEMALE_P RETURN NUMBER IS
  BEGIN
    RETURN CP_HW_AUD_FEMALE;
  END CP_HW_AUD_FEMALE_P;

  FUNCTION CP_HW_AUD_TOT_P RETURN NUMBER IS
  BEGIN
    RETURN CP_HW_AUD_TOT;
  END CP_HW_AUD_TOT_P;

  FUNCTION CP_HW_CAT_P RETURN NUMBER IS
  BEGIN
    RETURN CP_HW_CAT;
  END CP_HW_CAT_P;

  FUNCTION CP_HW_FEMALE_P RETURN NUMBER IS
  BEGIN
    RETURN CP_HW_FEMALE;
  END CP_HW_FEMALE_P;

  FUNCTION CP_HW_MALE_P RETURN NUMBER IS
  BEGIN
    RETURN CP_HW_MALE;
  END CP_HW_MALE_P;

  FUNCTION C_BUSINESS_GROUP_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_BUSINESS_GROUP_NAME;
  END C_BUSINESS_GROUP_NAME_P;

  FUNCTION C_HIERARCHY_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_HIERARCHY_NAME;
  END C_HIERARCHY_NAME_P;

  FUNCTION C_HIERARCHY_VERSION_NUM_P RETURN NUMBER IS
  BEGIN
    RETURN C_HIERARCHY_VERSION_NUM;
  END C_HIERARCHY_VERSION_NUM_P;

  FUNCTION C_PARENT_ORG_ID_P RETURN NUMBER IS
  BEGIN
    RETURN C_PARENT_ORG_ID;
  END C_PARENT_ORG_ID_P;

  FUNCTION C_PARENT_NODE_ID_P RETURN NUMBER IS
  BEGIN
    RETURN C_PARENT_NODE_ID;
  END C_PARENT_NODE_ID_P;

  FUNCTION CP_PREV_YEAR_FILED_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_PREV_YEAR_FILED;
  END CP_PREV_YEAR_FILED_P;

  FUNCTION C_PRIOD_END_DATE_P RETURN DATE IS
  BEGIN
    RETURN C_PRIOD_END_DATE;
  END C_PRIOD_END_DATE_P;

  FUNCTION C_ALL_TOTAL_P RETURN NUMBER IS
  BEGIN
    RETURN C_ALL_TOTAL;
  END C_ALL_TOTAL_P;

  FUNCTION C_NO_OF_ESTABLISHMENTS_P RETURN NUMBER IS
  BEGIN
    RETURN C_NO_OF_ESTABLISHMENTS;
  END C_NO_OF_ESTABLISHMENTS_P;

  FUNCTION C_PAYROLL_PERIOD_DATE_START_P RETURN DATE IS
  BEGIN
    RETURN C_PAYROLL_PERIOD_DATE_START;
  END C_PAYROLL_PERIOD_DATE_START_P;

  FUNCTION C_PAYROLL_PERIOD_DATE_END_P RETURN DATE IS
  BEGIN
    RETURN C_PAYROLL_PERIOD_DATE_END;
  END C_PAYROLL_PERIOD_DATE_END_P;

  FUNCTION C_REPORT_MODE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_REPORT_MODE;
  END C_REPORT_MODE_P;

  FUNCTION C_REPORT_YEAR_P RETURN NUMBER IS
  BEGIN
    RETURN C_REPORT_YEAR;
  END C_REPORT_YEAR_P;

     FUNCTION GET_BUSINESS_GROUP(P_BUSINESS_GROUP_ID IN NUMBER) RETURN VARCHAR2 IS
       X0 VARCHAR2(2000);
     BEGIN
       begin
       	X0 := HR_REPORTS.GET_BUSINESS_GROUP(P_BUSINESS_GROUP_ID);
       end;
       RETURN X0;
     END GET_BUSINESS_GROUP;


END PER_PERUSEO1_XMLP_PKG;

/
