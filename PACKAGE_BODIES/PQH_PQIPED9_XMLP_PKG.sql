--------------------------------------------------------
--  DDL for Package Body PQH_PQIPED9_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_PQIPED9_XMLP_PKG" AS
/* $Header: PQIPED9B.pls 120.3 2008/03/28 12:13:39 amakrish noship $ */
  FUNCTION LINEFORMULA RETURN NUMBER IS
    TEMP_NUM NUMBER;
  BEGIN
    TEMP_NUM := LINE_NUM;
    LINE_NUM := LINE_NUM + 1;
    RETURN TEMP_NUM;
  END LINEFORMULA;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
    L_QUERY_TEXT VARCHAR2(2000);
    L_FR VARCHAR2(2000);
    L_FT VARCHAR2(2000);
    L_PR VARCHAR2(2000);
    L_PT VARCHAR2(2000);
    L_YEAR VARCHAR2(4);
    L_MONTH VARCHAR2(3);
    L_DAY VARCHAR2(2);
    L_YEAR_AGO VARCHAR2(4);
    LINE VARCHAR2(1);
    SC VARCHAR2(2000);
    L_NR_MEN NUMBER(10) := 0;
    L_NR_WMEN NUMBER(10) := 0;
    L_BNH_MEN NUMBER(10) := 0;
    L_BNH_WMEN NUMBER(10) := 0;
    L_AMAI_MEN NUMBER(10) := 0;
    L_AMAI_WMEN NUMBER(10) := 0;
    L_AP_MEN NUMBER(10) := 0;
    L_AP_WMEN NUMBER(10) := 0;
    L_H_MEN NUMBER(10) := 0;
    L_H_WMEN NUMBER(10) := 0;
    L_WNH_MEN NUMBER(10) := 0;
    L_WNH_WMEN NUMBER(10) := 0;
    L_UR_MEN NUMBER(10) := 0;
    L_UR_WMEN NUMBER(10) := 0;
    L_TOT_MEN NUMBER(10) := 0;
    L_TOT_WMEN NUMBER(10) := 0;
    L_TMR_BNH_MEN NUMBER(10) := 0;
    L_TMR_BNH_WMEN NUMBER(10) := 0;
    L_TMR_AMAI_MEN NUMBER(10) := 0;
    L_TMR_AMAI_WMEN NUMBER(10) := 0;
    L_TMR_AP_MEN NUMBER(10) := 0;
    L_TMR_AP_WMEN NUMBER(10) := 0;
    L_TMR_H_MEN NUMBER(10) := 0;
    L_TMR_H_WMEN NUMBER(10) := 0;
    L_TMR_WNH_MEN NUMBER(10) := 0;
    L_TMR_WNH_WMEN NUMBER(10) := 0;
    L_TMR_UR_MEN NUMBER(10) := 0;
    L_TMR_UR_WMEN NUMBER(10) := 0;
    CURSOR GET_LINE1_COUNTS IS
      SELECT
        '1' JCODE,
        COUNT(DECODE(PQH_NR_ALIEN_PKG.GET_COUNT_NR_ALIEN(PEO.PERSON_ID
                                                        ,P_REPORT_DATE)
                    ,'1'
                    ,DECODE(PEO.SEX
                          ,'M'
                          ,1
                          ,NULL)
                    ,NULL)) NRMEN,
        COUNT(DECODE(PQH_NR_ALIEN_PKG.GET_COUNT_NR_ALIEN(PEO.PERSON_ID
                                                        ,P_REPORT_DATE)
                    ,'1'
                    ,DECODE(PEO.SEX
                          ,'F'
                          ,1
                          ,NULL)
                    ,NULL)) NRWMEN,
        COUNT(DECODE(PQH_NR_ALIEN_PKG.GET_COUNT_NR_ALIEN(PEO.PERSON_ID
                                                        ,P_REPORT_DATE)
                    ,NULL
                    ,(DECODE(PEO.PER_INFORMATION1
                          ,'2'
                          ,DECODE(PEO.SEX
                                ,'M'
                                ,1
                                ,NULL)
                          ,NULL)))) BNHMEN,
        COUNT(DECODE(PQH_NR_ALIEN_PKG.GET_COUNT_NR_ALIEN(PEO.PERSON_ID
                                                        ,P_REPORT_DATE)
                    ,NULL
                    ,(DECODE(PEO.PER_INFORMATION1
                          ,'2'
                          ,DECODE(PEO.SEX
                                ,'F'
                                ,1
                                ,NULL)
                          ,NULL)))) BNHWMEN,
        COUNT(DECODE(PQH_NR_ALIEN_PKG.GET_COUNT_NR_ALIEN(PEO.PERSON_ID
                                                        ,P_REPORT_DATE)
                    ,NULL
                    ,(DECODE(PEO.PER_INFORMATION1
                          ,'6'
                          ,DECODE(PEO.SEX
                                ,'M'
                                ,1
                                ,NULL)
                          ,NULL)))) AM_ALMEN,
        COUNT(DECODE(PQH_NR_ALIEN_PKG.GET_COUNT_NR_ALIEN(PEO.PERSON_ID
                                                        ,P_REPORT_DATE)
                    ,NULL
                    ,(DECODE(PEO.PER_INFORMATION1
                          ,'6'
                          ,DECODE(PEO.SEX
                                ,'F'
                                ,1
                                ,NULL)
                          ,NULL)))) AM_ALWMEN,
        COUNT(DECODE(PQH_NR_ALIEN_PKG.GET_COUNT_NR_ALIEN(PEO.PERSON_ID
                                                        ,P_REPORT_DATE)
                    ,NULL
                    ,(DECODE(PEO.PER_INFORMATION1
                          ,'4'
                          ,DECODE(PEO.SEX
                                ,'M'
                                ,1
                                ,NULL)
                          ,'5'
                          ,DECODE(PEO.SEX
                                ,'M'
                                ,1
                                ,NULL)
                          ,NULL)))) APMEN,
        COUNT(DECODE(PQH_NR_ALIEN_PKG.GET_COUNT_NR_ALIEN(PEO.PERSON_ID
                                                        ,P_REPORT_DATE)
                    ,NULL
                    ,(DECODE(PEO.PER_INFORMATION1
                          ,'4'
                          ,DECODE(PEO.SEX
                                ,'F'
                                ,1
                                ,NULL)
                          ,'5'
                          ,DECODE(PEO.SEX
                                ,'F'
                                ,1
                                ,NULL)
                          ,NULL)))) APWMEN,
        COUNT(DECODE(PQH_NR_ALIEN_PKG.GET_COUNT_NR_ALIEN(PEO.PERSON_ID
                                                        ,P_REPORT_DATE)
                    ,NULL
                    ,(DECODE(PEO.PER_INFORMATION1
                          ,'3'
                          ,DECODE(PEO.SEX
                                ,'M'
                                ,1
                                ,NULL)
                          ,'9'
                          ,DECODE(PEO.SEX
                                ,'M'
                                ,1
                                ,NULL)
                          ,NULL)))) HMEN,
        COUNT(DECODE(PQH_NR_ALIEN_PKG.GET_COUNT_NR_ALIEN(PEO.PERSON_ID
                                                        ,P_REPORT_DATE)
                    ,NULL
                    ,(DECODE(PEO.PER_INFORMATION1
                          ,'3'
                          ,DECODE(PEO.SEX
                                ,'F'
                                ,1
                                ,NULL)
                          ,'9'
                          ,DECODE(PEO.SEX
                                ,'F'
                                ,1
                                ,NULL)
                          ,NULL)))) HWMEN,
        COUNT(DECODE(PQH_NR_ALIEN_PKG.GET_COUNT_NR_ALIEN(PEO.PERSON_ID
                                                        ,P_REPORT_DATE)
                    ,NULL
                    ,(DECODE(PEO.PER_INFORMATION1
                          ,'1'
                          ,DECODE(PEO.SEX
                                ,'M'
                                ,1
                                ,NULL)
                          ,NULL)))) WNHMEN,
        COUNT(DECODE(PQH_NR_ALIEN_PKG.GET_COUNT_NR_ALIEN(PEO.PERSON_ID
                                                        ,P_REPORT_DATE)
                    ,NULL
                    ,(DECODE(PEO.PER_INFORMATION1
                          ,'1'
                          ,DECODE(PEO.SEX
                                ,'F'
                                ,1
                                ,NULL)
                          ,NULL)))) WNHWMEN,
        COUNT(DECODE(PQH_NR_ALIEN_PKG.GET_COUNT_NR_ALIEN(PEO.PERSON_ID
                                                        ,P_REPORT_DATE)
                    ,NULL
                    ,(DECODE(PEO.PER_INFORMATION1
                          ,NULL
                          ,DECODE(PEO.SEX
                                ,'M'
                                ,1
                                ,NULL)
                          ,NULL)))) URMEN,
        COUNT(DECODE(PQH_NR_ALIEN_PKG.GET_COUNT_NR_ALIEN(PEO.PERSON_ID
                                                        ,P_REPORT_DATE)
                    ,NULL
                    ,(DECODE(PEO.PER_INFORMATION1
                          ,NULL
                          ,DECODE(PEO.SEX
                                ,'F'
                                ,1
                                ,NULL)
                          ,NULL)))) URWMEN
      FROM
        PER_ALL_PEOPLE_F PEO,
        PER_ALL_ASSIGNMENTS_F PAF,
        PER_ASSIGNMENT_STATUS_TYPES AST,
        PER_PEOPLE_EXTRA_INFO PPET,
        PER_JOBS JOB,
        HR_LOOKUPS HL
      WHERE PAF.PERSON_ID = PPET.PERSON_ID
        AND PAF.PERSON_ID = PEO.PERSON_ID
        AND PEO.CURRENT_EMPLOYEE_FLAG = 'Y'
        AND PPET.PEI_INFORMATION_CATEGORY = 'PQH_TENURE_STATUS'
        AND PQH_EMPLOYMENT_CATEGORY.GET_SERVICE_START_DATE(PAF.PERIOD_OF_SERVICE_ID) BETWEEN CP_HIRE_DATE
        AND P_REPORT_DATE
        AND FND_DATE.CANONICAL_TO_DATE(PPET.PEI_INFORMATION2) <= P_REPORT_DATE
        AND PPET.PEI_INFORMATION1 = '01'
        AND PPET.PEI_INFORMATION1 IS NOT NULL
        AND PAF.PRIMARY_FLAG = 'Y'
        AND PAF.ASSIGNMENT_TYPE = 'E'
        AND PAF.ASSIGNMENT_STATUS_TYPE_ID = AST.ASSIGNMENT_STATUS_TYPE_ID
        AND AST.PER_SYSTEM_STATUS <> 'TERM_ASSIGN'
        AND PQH_EMPLOYMENT_CATEGORY.IDENTIFY_EMPL_CATEGORY(PAF.EMPLOYMENT_CATEGORY
                                                    ,CP_FR
                                                    ,CP_FT
                                                    ,CP_PR
                                                    ,CP_PT) = 'FR'
        AND HL.LOOKUP_CODE = JOB.JOB_INFORMATION8
        AND HL.LOOKUP_TYPE = 'US_IPEDS_JOB_CATEGORIES'
        AND JOB.JOB_INFORMATION_CATEGORY = 'US'
        AND HL.LOOKUP_CODE in ( '1' , '2' , '3' )
        AND PAF.JOB_ID = JOB.JOB_ID
        AND PAF.ORGANIZATION_ID IN (
        SELECT
          ORGANIZATION_ID
        FROM
          HR_ALL_ORGANIZATION_UNITS
        WHERE BUSINESS_GROUP_ID = P_BUSINESS_GROUP_ID )
      GROUP BY
        '1';
    CURSOR GET_LINE1_TMRACES_COUNTS IS
      SELECT
        COUNT(DECODE(PEI.PEI_INFORMATION5
                    ,'2'
                    ,DECODE(PEO.SEX
                          ,'M'
                          ,1
                          ,NULL)
                    ,NULL)) BNHMEN,
        COUNT(DECODE(PEI.PEI_INFORMATION5
                    ,'2'
                    ,DECODE(PEO.SEX
                          ,'F'
                          ,1
                          ,NULL)
                    ,NULL)) BNHWMEN,
        COUNT(DECODE(PEI.PEI_INFORMATION5
                    ,'6'
                    ,DECODE(PEO.SEX
                          ,'M'
                          ,1
                          ,NULL)
                    ,NULL)) AM_ALMEN,
        COUNT(DECODE(PEI.PEI_INFORMATION5
                    ,'6'
                    ,DECODE(PEO.SEX
                          ,'F'
                          ,1
                          ,NULL)
                    ,NULL)) AM_ALWMEN,
        COUNT(DECODE(PEI.PEI_INFORMATION5
                    ,'4'
                    ,DECODE(PEO.SEX
                          ,'M'
                          ,1
                          ,NULL)
                    ,'5'
                    ,DECODE(PEO.SEX
                          ,'M'
                          ,1
                          ,NULL)
                    ,NULL)) A_PMEN,
        COUNT(DECODE(PEI.PEI_INFORMATION5
                    ,'4'
                    ,DECODE(PEO.SEX
                          ,'F'
                          ,1
                          ,NULL)
                    ,'5'
                    ,DECODE(PEO.SEX
                          ,'F'
                          ,1
                          ,NULL)
                    ,NULL)) A_PWMEN,
        COUNT(DECODE(PEI.PEI_INFORMATION5
                    ,'3'
                    ,DECODE(PEO.SEX
                          ,'M'
                          ,1
                          ,NULL)
                    ,'9'
                    ,DECODE(PEO.SEX
                          ,'M'
                          ,1
                          ,NULL)
                    ,NULL)) HMEN,
        COUNT(DECODE(PEI.PEI_INFORMATION5
                    ,'3'
                    ,DECODE(PEO.SEX
                          ,'F'
                          ,1
                          ,NULL)
                    ,'9'
                    ,DECODE(PEO.SEX
                          ,'F'
                          ,1
                          ,NULL)
                    ,NULL)) HWMEN,
        COUNT(DECODE(PEI.PEI_INFORMATION5
                    ,'1'
                    ,DECODE(PEO.SEX
                          ,'M'
                          ,1
                          ,NULL)
                    ,NULL)) WNHMEN,
        COUNT(DECODE(PEI.PEI_INFORMATION5
                    ,'1'
                    ,DECODE(PEO.SEX
                          ,'F'
                          ,1
                          ,NULL)
                    ,NULL)) WNHWMEN,
        COUNT(DECODE(PEI.PEI_INFORMATION5
                    ,NULL
                    ,DECODE(PEO.SEX
                          ,'M'
                          ,1
                          ,NULL)
                    ,NULL)) URMEN,
        COUNT(DECODE(PEI.PEI_INFORMATION5
                    ,NULL
                    ,DECODE(PEO.SEX
                          ,'F'
                          ,1
                          ,NULL)
                    ,NULL)) URWMEN
      FROM
        PER_ALL_PEOPLE_F PEO,
        PER_ALL_ASSIGNMENTS_F PAF,
        PER_ASSIGNMENT_STATUS_TYPES AST,
        PER_PEOPLE_EXTRA_INFO PPET,
        PER_JOBS JOB,
        HR_LOOKUPS HL,
        PER_PEOPLE_EXTRA_INFO PEI
      WHERE PAF.PERSON_ID = PPET.PERSON_ID
        AND PAF.PERSON_ID = PEO.PERSON_ID
        AND PEO.CURRENT_EMPLOYEE_FLAG = 'Y'
        AND PEO.PER_INFORMATION1 = '13'
        AND PEO.PERSON_ID = pei.person_id (+)
        AND ( PEI.INFORMATION_TYPE = 'PER_US_ADDL_ETHNIC_CAT'
      OR ( PEI.INFORMATION_TYPE <> 'PER_US_ADDL_ETHNIC_CAT'
        AND not exists (
        SELECT
          1
        FROM
          PER_PEOPLE_EXTRA_INFO PEI2
        WHERE PEI2.INFORMATION_TYPE = 'PER_US_ADDL_ETHNIC_CAT'
          AND PEI2.PERSON_ID = PEI.PERSON_ID )
        AND PEI.PERSON_EXTRA_INFO_ID = (
        SELECT
          MAX(PEI1.PERSON_EXTRA_INFO_ID)
        FROM
          PER_PEOPLE_EXTRA_INFO PEI1
        WHERE PEI1.PERSON_ID = PEI.PERSON_ID ) )
      OR ( not exists (
        SELECT
          PERSON_EXTRA_INFO_ID
        FROM
          PER_PEOPLE_EXTRA_INFO PEI3
        WHERE PEI3.PERSON_ID = PEI.PERSON_ID ) ) )
        AND PPET.PEI_INFORMATION_CATEGORY = 'PQH_TENURE_STATUS'
        AND PQH_EMPLOYMENT_CATEGORY.GET_SERVICE_START_DATE(PAF.PERIOD_OF_SERVICE_ID) BETWEEN CP_HIRE_DATE
        AND P_REPORT_DATE
        AND FND_DATE.CANONICAL_TO_DATE(PPET.PEI_INFORMATION2) <= P_REPORT_DATE
        AND PPET.PEI_INFORMATION1 = '01'
        AND PPET.PEI_INFORMATION1 IS NOT NULL
        AND PAF.PRIMARY_FLAG = 'Y'
        AND PAF.ASSIGNMENT_TYPE = 'E'
        AND PAF.ASSIGNMENT_STATUS_TYPE_ID = AST.ASSIGNMENT_STATUS_TYPE_ID
        AND AST.PER_SYSTEM_STATUS <> 'TERM_ASSIGN'
        AND PQH_EMPLOYMENT_CATEGORY.IDENTIFY_EMPL_CATEGORY(PAF.EMPLOYMENT_CATEGORY
                                                    ,CP_FR
                                                    ,CP_FT
                                                    ,CP_PR
                                                    ,CP_PT) = 'FR'
        AND HL.LOOKUP_CODE = JOB.JOB_INFORMATION8
        AND HL.LOOKUP_TYPE = 'US_IPEDS_JOB_CATEGORIES'
        AND JOB.JOB_INFORMATION_CATEGORY = 'US'
        AND HL.LOOKUP_CODE in ( '1' , '2' , '3' )
        AND PAF.JOB_ID = JOB.JOB_ID
        AND PAF.ORGANIZATION_ID IN (
        SELECT
          ORGANIZATION_ID
        FROM
          HR_ALL_ORGANIZATION_UNITS
        WHERE BUSINESS_GROUP_ID = P_BUSINESS_GROUP_ID );
    CURSOR GET_LINE2_COUNTS IS
      SELECT
        '2' JCODE,
        COUNT(DECODE(PQH_NR_ALIEN_PKG.GET_COUNT_NR_ALIEN(PEO.PERSON_ID
                                                        ,P_REPORT_DATE)
                    ,'1'
                    ,DECODE(PEO.SEX
                          ,'M'
                          ,1
                          ,NULL)
                    ,NULL)) NRMEN,
        COUNT(DECODE(PQH_NR_ALIEN_PKG.GET_COUNT_NR_ALIEN(PEO.PERSON_ID
                                                        ,P_REPORT_DATE)
                    ,'1'
                    ,DECODE(PEO.SEX
                          ,'F'
                          ,1
                          ,NULL)
                    ,NULL)) NRWMEN,
        COUNT(DECODE(PQH_NR_ALIEN_PKG.GET_COUNT_NR_ALIEN(PEO.PERSON_ID
                                                        ,P_REPORT_DATE)
                    ,NULL
                    ,(DECODE(PEO.PER_INFORMATION1
                          ,'2'
                          ,DECODE(PEO.SEX
                                ,'M'
                                ,1
                                ,NULL)
                          ,NULL)))) BNHMEN,
        COUNT(DECODE(PQH_NR_ALIEN_PKG.GET_COUNT_NR_ALIEN(PEO.PERSON_ID
                                                        ,P_REPORT_DATE)
                    ,NULL
                    ,(DECODE(PEO.PER_INFORMATION1
                          ,'2'
                          ,DECODE(PEO.SEX
                                ,'F'
                                ,1
                                ,NULL)
                          ,NULL)))) BNHWMEN,
        COUNT(DECODE(PQH_NR_ALIEN_PKG.GET_COUNT_NR_ALIEN(PEO.PERSON_ID
                                                        ,P_REPORT_DATE)
                    ,NULL
                    ,(DECODE(PEO.PER_INFORMATION1
                          ,'6'
                          ,DECODE(PEO.SEX
                                ,'M'
                                ,1
                                ,NULL)
                          ,NULL)))) AM_ALMEN,
        COUNT(DECODE(PQH_NR_ALIEN_PKG.GET_COUNT_NR_ALIEN(PEO.PERSON_ID
                                                        ,P_REPORT_DATE)
                    ,NULL
                    ,(DECODE(PEO.PER_INFORMATION1
                          ,'6'
                          ,DECODE(PEO.SEX
                                ,'F'
                                ,1
                                ,NULL)
                          ,NULL)))) AM_ALWMEN,
        COUNT(DECODE(PQH_NR_ALIEN_PKG.GET_COUNT_NR_ALIEN(PEO.PERSON_ID
                                                        ,P_REPORT_DATE)
                    ,NULL
                    ,(DECODE(PEO.PER_INFORMATION1
                          ,'4'
                          ,DECODE(PEO.SEX
                                ,'M'
                                ,1
                                ,NULL)
                          ,'5'
                          ,DECODE(PEO.SEX
                                ,'M'
                                ,1
                                ,NULL)
                          ,NULL)))) APMEN,
        COUNT(DECODE(PQH_NR_ALIEN_PKG.GET_COUNT_NR_ALIEN(PEO.PERSON_ID
                                                        ,P_REPORT_DATE)
                    ,NULL
                    ,(DECODE(PEO.PER_INFORMATION1
                          ,'4'
                          ,DECODE(PEO.SEX
                                ,'F'
                                ,1
                                ,NULL)
                          ,'5'
                          ,DECODE(PEO.SEX
                                ,'F'
                                ,1
                                ,NULL)
                          ,NULL)))) APWMEN,
        COUNT(DECODE(PQH_NR_ALIEN_PKG.GET_COUNT_NR_ALIEN(PEO.PERSON_ID
                                                        ,P_REPORT_DATE)
                    ,NULL
                    ,(DECODE(PEO.PER_INFORMATION1
                          ,'3'
                          ,DECODE(PEO.SEX
                                ,'M'
                                ,1
                                ,NULL)
                          ,'9'
                          ,DECODE(PEO.SEX
                                ,'M'
                                ,1
                                ,NULL)
                          ,NULL)))) HMEN,
        COUNT(DECODE(PQH_NR_ALIEN_PKG.GET_COUNT_NR_ALIEN(PEO.PERSON_ID
                                                        ,P_REPORT_DATE)
                    ,NULL
                    ,(DECODE(PEO.PER_INFORMATION1
                          ,'3'
                          ,DECODE(PEO.SEX
                                ,'F'
                                ,1
                                ,NULL)
                          ,'9'
                          ,DECODE(PEO.SEX
                                ,'F'
                                ,1
                                ,NULL)
                          ,NULL)))) HWMEN,
        COUNT(DECODE(PQH_NR_ALIEN_PKG.GET_COUNT_NR_ALIEN(PEO.PERSON_ID
                                                        ,P_REPORT_DATE)
                    ,NULL
                    ,(DECODE(PEO.PER_INFORMATION1
                          ,'1'
                          ,DECODE(PEO.SEX
                                ,'M'
                                ,1
                                ,NULL)
                          ,NULL)))) WNHMEN,
        COUNT(DECODE(PQH_NR_ALIEN_PKG.GET_COUNT_NR_ALIEN(PEO.PERSON_ID
                                                        ,P_REPORT_DATE)
                    ,NULL
                    ,(DECODE(PEO.PER_INFORMATION1
                          ,'1'
                          ,DECODE(PEO.SEX
                                ,'F'
                                ,1
                                ,NULL)
                          ,NULL)))) WNHWMEN,
        COUNT(DECODE(PQH_NR_ALIEN_PKG.GET_COUNT_NR_ALIEN(PEO.PERSON_ID
                                                        ,P_REPORT_DATE)
                    ,NULL
                    ,(DECODE(PEO.PER_INFORMATION1
                          ,NULL
                          ,DECODE(PEO.SEX
                                ,'M'
                                ,1
                                ,NULL)
                          ,NULL)))) URMEN,
        COUNT(DECODE(PQH_NR_ALIEN_PKG.GET_COUNT_NR_ALIEN(PEO.PERSON_ID
                                                        ,P_REPORT_DATE)
                    ,NULL
                    ,(DECODE(PEO.PER_INFORMATION1
                          ,NULL
                          ,DECODE(PEO.SEX
                                ,'F'
                                ,1
                                ,NULL)
                          ,NULL)))) URWMEN
      FROM
        PER_ALL_PEOPLE_F PEO,
        PER_ALL_ASSIGNMENTS_F PAF,
        PER_ASSIGNMENT_STATUS_TYPES AST,
        PER_PEOPLE_EXTRA_INFO PPET,
        PER_JOBS JOB,
        HR_LOOKUPS HL
      WHERE PAF.PERSON_ID = PPET.PERSON_ID
        AND PAF.PERSON_ID = PEO.PERSON_ID
        AND PEO.CURRENT_EMPLOYEE_FLAG = 'Y'
        AND PPET.PEI_INFORMATION_CATEGORY = 'PQH_TENURE_STATUS'
        AND PQH_EMPLOYMENT_CATEGORY.GET_SERVICE_START_DATE(PAF.PERIOD_OF_SERVICE_ID) BETWEEN CP_HIRE_DATE
        AND P_REPORT_DATE
        AND FND_DATE.CANONICAL_TO_DATE(PPET.PEI_INFORMATION2) <= P_REPORT_DATE
        AND PPET.PEI_INFORMATION1 in ( '02' , '04' )
        AND PPET.PEI_INFORMATION1 IS NOT NULL
        AND PAF.PRIMARY_FLAG = 'Y'
        AND PAF.ASSIGNMENT_TYPE = 'E'
        AND PAF.ASSIGNMENT_STATUS_TYPE_ID = AST.ASSIGNMENT_STATUS_TYPE_ID
        AND AST.PER_SYSTEM_STATUS <> 'TERM_ASSIGN'
        AND PQH_EMPLOYMENT_CATEGORY.IDENTIFY_EMPL_CATEGORY(PAF.EMPLOYMENT_CATEGORY
                                                    ,CP_FR
                                                    ,CP_FT
                                                    ,CP_PR
                                                    ,CP_PT) = 'FR'
        AND HL.LOOKUP_CODE = JOB.JOB_INFORMATION8
        AND HL.LOOKUP_TYPE = 'US_IPEDS_JOB_CATEGORIES'
        AND JOB.JOB_INFORMATION_CATEGORY = 'US'
        AND HL.LOOKUP_CODE in ( '1' , '2' , '3' )
        AND PAF.JOB_ID = JOB.JOB_ID
        AND PAF.ORGANIZATION_ID IN (
        SELECT
          ORGANIZATION_ID
        FROM
          HR_ALL_ORGANIZATION_UNITS
        WHERE BUSINESS_GROUP_ID = P_BUSINESS_GROUP_ID )
      GROUP BY
        '2';
    CURSOR GET_TMR_LINE2_COUNTS IS
      SELECT
        COUNT(DECODE(PEI.PEI_INFORMATION5
                    ,'2'
                    ,DECODE(PEO.SEX
                          ,'M'
                          ,1
                          ,NULL)
                    ,NULL)) BNHMEN,
        COUNT(DECODE(PEI.PEI_INFORMATION5
                    ,'2'
                    ,DECODE(PEO.SEX
                          ,'F'
                          ,1
                          ,NULL)
                    ,NULL)) BNHWMEN,
        COUNT(DECODE(PEI.PEI_INFORMATION5
                    ,'6'
                    ,DECODE(PEO.SEX
                          ,'M'
                          ,1
                          ,NULL)
                    ,NULL)) AM_ALMEN,
        COUNT(DECODE(PEI.PEI_INFORMATION5
                    ,'6'
                    ,DECODE(PEO.SEX
                          ,'F'
                          ,1
                          ,NULL)
                    ,NULL)) AM_ALWMEN,
        COUNT(DECODE(PEI.PEI_INFORMATION5
                    ,'4'
                    ,DECODE(PEO.SEX
                          ,'M'
                          ,1
                          ,NULL)
                    ,'5'
                    ,DECODE(PEO.SEX
                          ,'M'
                          ,1
                          ,NULL)
                    ,NULL)) A_PMEN,
        COUNT(DECODE(PEI.PEI_INFORMATION5
                    ,'4'
                    ,DECODE(PEO.SEX
                          ,'F'
                          ,1
                          ,NULL)
                    ,'5'
                    ,DECODE(PEO.SEX
                          ,'F'
                          ,1
                          ,NULL)
                    ,NULL)) A_PWMEN,
        COUNT(DECODE(PEI.PEI_INFORMATION5
                    ,'3'
                    ,DECODE(PEO.SEX
                          ,'M'
                          ,1
                          ,NULL)
                    ,'9'
                    ,DECODE(PEO.SEX
                          ,'M'
                          ,1
                          ,NULL)
                    ,NULL)) HMEN,
        COUNT(DECODE(PEI.PEI_INFORMATION5
                    ,'3'
                    ,DECODE(PEO.SEX
                          ,'F'
                          ,1
                          ,NULL)
                    ,'9'
                    ,DECODE(PEO.SEX
                          ,'F'
                          ,1
                          ,NULL)
                    ,NULL)) HWMEN,
        COUNT(DECODE(PEI.PEI_INFORMATION5
                    ,'1'
                    ,DECODE(PEO.SEX
                          ,'M'
                          ,1
                          ,NULL)
                    ,NULL)) WNHMEN,
        COUNT(DECODE(PEI.PEI_INFORMATION5
                    ,'1'
                    ,DECODE(PEO.SEX
                          ,'F'
                          ,1
                          ,NULL)
                    ,NULL)) WNHWMEN,
        COUNT(DECODE(PEI.PEI_INFORMATION5
                    ,NULL
                    ,DECODE(PEO.SEX
                          ,'M'
                          ,1
                          ,NULL)
                    ,NULL)) URMEN,
        COUNT(DECODE(PEI.PEI_INFORMATION5
                    ,NULL
                    ,DECODE(PEO.SEX
                          ,'F'
                          ,1
                          ,NULL)
                    ,NULL)) URWMEN
      FROM
        PER_ALL_PEOPLE_F PEO,
        PER_ALL_ASSIGNMENTS_F PAF,
        PER_ASSIGNMENT_STATUS_TYPES AST,
        PER_PEOPLE_EXTRA_INFO PPET,
        PER_JOBS JOB,
        HR_LOOKUPS HL,
        PER_PEOPLE_EXTRA_INFO PEI
      WHERE PAF.PERSON_ID = PPET.PERSON_ID
        AND PAF.PERSON_ID = PEO.PERSON_ID
        AND PEO.CURRENT_EMPLOYEE_FLAG = 'Y'
        AND PEO.PER_INFORMATION1 = '13'
        AND PEO.PERSON_ID = pei.person_id (+)
        AND ( PEI.INFORMATION_TYPE = 'PER_US_ADDL_ETHNIC_CAT'
      OR ( PEI.INFORMATION_TYPE <> 'PER_US_ADDL_ETHNIC_CAT'
        AND not exists (
        SELECT
          1
        FROM
          PER_PEOPLE_EXTRA_INFO PEI2
        WHERE PEI2.INFORMATION_TYPE = 'PER_US_ADDL_ETHNIC_CAT'
          AND PEI2.PERSON_ID = PEI.PERSON_ID )
        AND PEI.PERSON_EXTRA_INFO_ID = (
        SELECT
          MAX(PEI1.PERSON_EXTRA_INFO_ID)
        FROM
          PER_PEOPLE_EXTRA_INFO PEI1
        WHERE PEI1.PERSON_ID = PEI.PERSON_ID ) )
      OR ( not exists (
        SELECT
          PERSON_EXTRA_INFO_ID
        FROM
          PER_PEOPLE_EXTRA_INFO PEI3
        WHERE PEI3.PERSON_ID = PEI.PERSON_ID ) ) )
        AND PPET.PEI_INFORMATION_CATEGORY = 'PQH_TENURE_STATUS'
        AND PQH_EMPLOYMENT_CATEGORY.GET_SERVICE_START_DATE(PAF.PERIOD_OF_SERVICE_ID) BETWEEN CP_HIRE_DATE
        AND P_REPORT_DATE
        AND FND_DATE.CANONICAL_TO_DATE(PPET.PEI_INFORMATION2) <= P_REPORT_DATE
        AND PPET.PEI_INFORMATION1 in ( '02' , '04' )
        AND PPET.PEI_INFORMATION1 IS NOT NULL
        AND PAF.PRIMARY_FLAG = 'Y'
        AND PAF.ASSIGNMENT_TYPE = 'E'
        AND PAF.ASSIGNMENT_STATUS_TYPE_ID = AST.ASSIGNMENT_STATUS_TYPE_ID
        AND AST.PER_SYSTEM_STATUS <> 'TERM_ASSIGN'
        AND PQH_EMPLOYMENT_CATEGORY.IDENTIFY_EMPL_CATEGORY(PAF.EMPLOYMENT_CATEGORY
                                                    ,CP_FR
                                                    ,CP_FT
                                                    ,CP_PR
                                                    ,CP_PT) = 'FR'
        AND HL.LOOKUP_CODE = JOB.JOB_INFORMATION8
        AND HL.LOOKUP_TYPE = 'US_IPEDS_JOB_CATEGORIES'
        AND JOB.JOB_INFORMATION_CATEGORY = 'US'
        AND HL.LOOKUP_CODE in ( '1' , '2' , '3' )
        AND PAF.JOB_ID = JOB.JOB_ID
        AND PAF.ORGANIZATION_ID IN (
        SELECT
          ORGANIZATION_ID
        FROM
          HR_ALL_ORGANIZATION_UNITS
        WHERE BUSINESS_GROUP_ID = P_BUSINESS_GROUP_ID );
    CURSOR GET_LINE3_COUNTS IS
      SELECT
        '3' JCODE,
        COUNT(DECODE(PQH_NR_ALIEN_PKG.GET_COUNT_NR_ALIEN(PEO.PERSON_ID
                                                        ,P_REPORT_DATE)
                    ,'1'
                    ,DECODE(PEO.SEX
                          ,'M'
                          ,1
                          ,NULL)
                    ,NULL)) NRMEN,
        COUNT(DECODE(PQH_NR_ALIEN_PKG.GET_COUNT_NR_ALIEN(PEO.PERSON_ID
                                                        ,P_REPORT_DATE)
                    ,'1'
                    ,DECODE(PEO.SEX
                          ,'F'
                          ,1
                          ,NULL)
                    ,NULL)) NRWMEN,
        COUNT(DECODE(PQH_NR_ALIEN_PKG.GET_COUNT_NR_ALIEN(PEO.PERSON_ID
                                                        ,P_REPORT_DATE)
                    ,NULL
                    ,(DECODE(PEO.PER_INFORMATION1
                          ,'2'
                          ,DECODE(PEO.SEX
                                ,'M'
                                ,1
                                ,NULL)
                          ,NULL)))) BNHMEN,
        COUNT(DECODE(PQH_NR_ALIEN_PKG.GET_COUNT_NR_ALIEN(PEO.PERSON_ID
                                                        ,P_REPORT_DATE)
                    ,NULL
                    ,(DECODE(PEO.PER_INFORMATION1
                          ,'2'
                          ,DECODE(PEO.SEX
                                ,'F'
                                ,1
                                ,NULL)
                          ,NULL)))) BNHWMEN,
        COUNT(DECODE(PQH_NR_ALIEN_PKG.GET_COUNT_NR_ALIEN(PEO.PERSON_ID
                                                        ,P_REPORT_DATE)
                    ,NULL
                    ,(DECODE(PEO.PER_INFORMATION1
                          ,'6'
                          ,DECODE(PEO.SEX
                                ,'M'
                                ,1
                                ,NULL)
                          ,NULL)))) AM_ALMEN,
        COUNT(DECODE(PQH_NR_ALIEN_PKG.GET_COUNT_NR_ALIEN(PEO.PERSON_ID
                                                        ,P_REPORT_DATE)
                    ,NULL
                    ,(DECODE(PEO.PER_INFORMATION1
                          ,'6'
                          ,DECODE(PEO.SEX
                                ,'F'
                                ,1
                                ,NULL)
                          ,NULL)))) AM_ALWMEN,
        COUNT(DECODE(PQH_NR_ALIEN_PKG.GET_COUNT_NR_ALIEN(PEO.PERSON_ID
                                                        ,P_REPORT_DATE)
                    ,NULL
                    ,(DECODE(PEO.PER_INFORMATION1
                          ,'4'
                          ,DECODE(PEO.SEX
                                ,'M'
                                ,1
                                ,NULL)
                          ,'5'
                          ,DECODE(PEO.SEX
                                ,'M'
                                ,1
                                ,NULL)
                          ,NULL)))) APMEN,
        COUNT(DECODE(PQH_NR_ALIEN_PKG.GET_COUNT_NR_ALIEN(PEO.PERSON_ID
                                                        ,P_REPORT_DATE)
                    ,NULL
                    ,(DECODE(PEO.PER_INFORMATION1
                          ,'4'
                          ,DECODE(PEO.SEX
                                ,'F'
                                ,1
                                ,NULL)
                          ,'5'
                          ,DECODE(PEO.SEX
                                ,'F'
                                ,1
                                ,NULL)
                          ,NULL)))) APWMEN,
        COUNT(DECODE(PQH_NR_ALIEN_PKG.GET_COUNT_NR_ALIEN(PEO.PERSON_ID
                                                        ,P_REPORT_DATE)
                    ,NULL
                    ,(DECODE(PEO.PER_INFORMATION1
                          ,'3'
                          ,DECODE(PEO.SEX
                                ,'M'
                                ,1
                                ,NULL)
                          ,'9'
                          ,DECODE(PEO.SEX
                                ,'M'
                                ,1
                                ,NULL)
                          ,NULL)))) HMEN,
        COUNT(DECODE(PQH_NR_ALIEN_PKG.GET_COUNT_NR_ALIEN(PEO.PERSON_ID
                                                        ,P_REPORT_DATE)
                    ,NULL
                    ,(DECODE(PEO.PER_INFORMATION1
                          ,'3'
                          ,DECODE(PEO.SEX
                                ,'F'
                                ,1
                                ,NULL)
                          ,'9'
                          ,DECODE(PEO.SEX
                                ,'F'
                                ,1
                                ,NULL)
                          ,NULL)))) HWMEN,
        COUNT(DECODE(PQH_NR_ALIEN_PKG.GET_COUNT_NR_ALIEN(PEO.PERSON_ID
                                                        ,P_REPORT_DATE)
                    ,NULL
                    ,(DECODE(PEO.PER_INFORMATION1
                          ,'1'
                          ,DECODE(PEO.SEX
                                ,'M'
                                ,1
                                ,NULL)
                          ,NULL)))) WNHMEN,
        COUNT(DECODE(PQH_NR_ALIEN_PKG.GET_COUNT_NR_ALIEN(PEO.PERSON_ID
                                                        ,P_REPORT_DATE)
                    ,NULL
                    ,(DECODE(PEO.PER_INFORMATION1
                          ,'1'
                          ,DECODE(PEO.SEX
                                ,'F'
                                ,1
                                ,NULL)
                          ,NULL)))) WNHWMEN,
        COUNT(DECODE(PQH_NR_ALIEN_PKG.GET_COUNT_NR_ALIEN(PEO.PERSON_ID
                                                        ,P_REPORT_DATE)
                    ,NULL
                    ,(DECODE(PEO.PER_INFORMATION1
                          ,NULL
                          ,DECODE(PEO.SEX
                                ,'M'
                                ,1
                                ,NULL)
                          ,NULL)))) URMEN,
        COUNT(DECODE(PQH_NR_ALIEN_PKG.GET_COUNT_NR_ALIEN(PEO.PERSON_ID
                                                        ,P_REPORT_DATE)
                    ,NULL
                    ,(DECODE(PEO.PER_INFORMATION1
                          ,NULL
                          ,DECODE(PEO.SEX
                                ,'F'
                                ,1
                                ,NULL)
                          ,NULL)))) URWMEN
      FROM
        PER_ALL_PEOPLE_F PEO,
        PER_ALL_ASSIGNMENTS_F PAF,
        PER_ASSIGNMENT_STATUS_TYPES AST,
        PER_JOBS JOB,
        HR_LOOKUPS HL
      WHERE PAF.PERSON_ID = PEO.PERSON_ID
        AND PEO.CURRENT_EMPLOYEE_FLAG = 'Y'
        AND not exists (
        SELECT
          PET.PERSON_ID
        FROM
          PER_PEOPLE_EXTRA_INFO PET
        WHERE PET.PERSON_ID = PEO.PERSON_ID
          AND PET.PEI_INFORMATION_CATEGORY in ( 'PQH_TENURE_STATUS' )
          AND PET.PEI_INFORMATION1 in ( '01' , '02' , '04' )
          AND FND_DATE.CANONICAL_TO_DATE(PET.PEI_INFORMATION2) <= P_REPORT_DATE )
        AND PQH_EMPLOYMENT_CATEGORY.GET_SERVICE_START_DATE(PAF.PERIOD_OF_SERVICE_ID) BETWEEN CP_HIRE_DATE
        AND P_REPORT_DATE
        AND PAF.PRIMARY_FLAG = 'Y'
        AND PAF.ASSIGNMENT_TYPE = 'E'
        AND PAF.ASSIGNMENT_STATUS_TYPE_ID = AST.ASSIGNMENT_STATUS_TYPE_ID
        AND AST.PER_SYSTEM_STATUS <> 'TERM_ASSIGN'
        AND PQH_EMPLOYMENT_CATEGORY.IDENTIFY_EMPL_CATEGORY(PAF.EMPLOYMENT_CATEGORY
                                                    ,CP_FR
                                                    ,CP_FT
                                                    ,CP_PR
                                                    ,CP_PT) = 'FR'
        AND HL.LOOKUP_CODE = JOB.JOB_INFORMATION8
        AND HL.LOOKUP_TYPE = 'US_IPEDS_JOB_CATEGORIES'
        AND JOB.JOB_INFORMATION_CATEGORY = 'US'
        AND HL.LOOKUP_CODE in ( '1' , '2' , '3' )
        AND PAF.JOB_ID = JOB.JOB_ID
        AND PAF.ORGANIZATION_ID IN (
        SELECT
          ORGANIZATION_ID
        FROM
          HR_ALL_ORGANIZATION_UNITS
        WHERE BUSINESS_GROUP_ID = P_BUSINESS_GROUP_ID )
      GROUP BY
        '3';
    CURSOR GET_LINE3_TMR_COUNTS IS
      SELECT
        COUNT(DECODE(PEI.PEI_INFORMATION5
                    ,'2'
                    ,DECODE(PEO.SEX
                          ,'M'
                          ,1
                          ,NULL)
                    ,NULL)) BNHMEN,
        COUNT(DECODE(PEI.PEI_INFORMATION5
                    ,'2'
                    ,DECODE(PEO.SEX
                          ,'F'
                          ,1
                          ,NULL)
                    ,NULL)) BNHWMEN,
        COUNT(DECODE(PEI.PEI_INFORMATION5
                    ,'6'
                    ,DECODE(PEO.SEX
                          ,'M'
                          ,1
                          ,NULL)
                    ,NULL)) AM_ALMEN,
        COUNT(DECODE(PEI.PEI_INFORMATION5
                    ,'6'
                    ,DECODE(PEO.SEX
                          ,'F'
                          ,1
                          ,NULL)
                    ,NULL)) AM_ALWMEN,
        COUNT(DECODE(PEI.PEI_INFORMATION5
                    ,'4'
                    ,DECODE(PEO.SEX
                          ,'M'
                          ,1
                          ,NULL)
                    ,'5'
                    ,DECODE(PEO.SEX
                          ,'M'
                          ,1
                          ,NULL)
                    ,NULL)) A_PMEN,
        COUNT(DECODE(PEI.PEI_INFORMATION5
                    ,'4'
                    ,DECODE(PEO.SEX
                          ,'F'
                          ,1
                          ,NULL)
                    ,'5'
                    ,DECODE(PEO.SEX
                          ,'F'
                          ,1
                          ,NULL)
                    ,NULL)) A_PWMEN,
        COUNT(DECODE(PEI.PEI_INFORMATION5
                    ,'3'
                    ,DECODE(PEO.SEX
                          ,'M'
                          ,1
                          ,NULL)
                    ,'9'
                    ,DECODE(PEO.SEX
                          ,'M'
                          ,1
                          ,NULL)
                    ,NULL)) HMEN,
        COUNT(DECODE(PEI.PEI_INFORMATION5
                    ,'3'
                    ,DECODE(PEO.SEX
                          ,'F'
                          ,1
                          ,NULL)
                    ,'9'
                    ,DECODE(PEO.SEX
                          ,'F'
                          ,1
                          ,NULL)
                    ,NULL)) HWMEN,
        COUNT(DECODE(PEI.PEI_INFORMATION5
                    ,'1'
                    ,DECODE(PEO.SEX
                          ,'M'
                          ,1
                          ,NULL)
                    ,NULL)) WNHMEN,
        COUNT(DECODE(PEI.PEI_INFORMATION5
                    ,'1'
                    ,DECODE(PEO.SEX
                          ,'F'
                          ,1
                          ,NULL)
                    ,NULL)) WNHWMEN,
        COUNT(DECODE(PEI.PEI_INFORMATION5
                    ,NULL
                    ,DECODE(PEO.SEX
                          ,'M'
                          ,1
                          ,NULL)
                    ,NULL)) URMEN,
        COUNT(DECODE(PEI.PEI_INFORMATION5
                    ,NULL
                    ,DECODE(PEO.SEX
                          ,'F'
                          ,1
                          ,NULL)
                    ,NULL)) URWMEN
      FROM
        PER_ALL_PEOPLE_F PEO,
        PER_ALL_ASSIGNMENTS_F PAF,
        PER_ASSIGNMENT_STATUS_TYPES AST,
        PER_JOBS JOB,
        HR_LOOKUPS HL,
        PER_PEOPLE_EXTRA_INFO PEI
      WHERE PAF.PERSON_ID = PEO.PERSON_ID
        AND PEO.CURRENT_EMPLOYEE_FLAG = 'Y'
        AND PEO.PER_INFORMATION1 = '13'
        AND PEO.PERSON_ID = pei.person_id (+)
        AND ( PEI.INFORMATION_TYPE = 'PER_US_ADDL_ETHNIC_CAT'
      OR ( PEI.INFORMATION_TYPE <> 'PER_US_ADDL_ETHNIC_CAT'
        AND not exists (
        SELECT
          1
        FROM
          PER_PEOPLE_EXTRA_INFO PEI2
        WHERE PEI2.INFORMATION_TYPE = 'PER_US_ADDL_ETHNIC_CAT'
          AND PEI2.PERSON_ID = PEI.PERSON_ID )
        AND PEI.PERSON_EXTRA_INFO_ID = (
        SELECT
          MAX(PEI1.PERSON_EXTRA_INFO_ID)
        FROM
          PER_PEOPLE_EXTRA_INFO PEI1
        WHERE PEI1.PERSON_ID = PEI.PERSON_ID ) )
      OR ( not exists (
        SELECT
          PERSON_EXTRA_INFO_ID
        FROM
          PER_PEOPLE_EXTRA_INFO PEI3
        WHERE PEI3.PERSON_ID = PEI.PERSON_ID ) ) )
        AND not exists (
        SELECT
          PET.PERSON_ID
        FROM
          PER_PEOPLE_EXTRA_INFO PET
        WHERE PET.PERSON_ID = PEO.PERSON_ID
          AND PET.PEI_INFORMATION_CATEGORY in ( 'PQH_TENURE_STATUS' )
          AND PET.PEI_INFORMATION1 in ( '01' , '02' , '04' )
          AND FND_DATE.CANONICAL_TO_DATE(PET.PEI_INFORMATION2) <= P_REPORT_DATE )
        AND PQH_EMPLOYMENT_CATEGORY.GET_SERVICE_START_DATE(PAF.PERIOD_OF_SERVICE_ID) BETWEEN CP_HIRE_DATE
        AND P_REPORT_DATE
        AND PAF.PRIMARY_FLAG = 'Y'
        AND PAF.ASSIGNMENT_TYPE = 'E'
        AND PAF.ASSIGNMENT_STATUS_TYPE_ID = AST.ASSIGNMENT_STATUS_TYPE_ID
        AND AST.PER_SYSTEM_STATUS <> 'TERM_ASSIGN'
        AND PQH_EMPLOYMENT_CATEGORY.IDENTIFY_EMPL_CATEGORY(PAF.EMPLOYMENT_CATEGORY
                                                    ,CP_FR
                                                    ,CP_FT
                                                    ,CP_PR
                                                    ,CP_PT) = 'FR'
        AND HL.LOOKUP_CODE = JOB.JOB_INFORMATION8
        AND HL.LOOKUP_TYPE = 'US_IPEDS_JOB_CATEGORIES'
        AND JOB.JOB_INFORMATION_CATEGORY = 'US'
        AND HL.LOOKUP_CODE in ( '1' , '2' , '3' )
        AND PAF.JOB_ID = JOB.JOB_ID
        AND PAF.ORGANIZATION_ID IN (
        SELECT
          ORGANIZATION_ID
        FROM
          HR_ALL_ORGANIZATION_UNITS
        WHERE BUSINESS_GROUP_ID = P_BUSINESS_GROUP_ID );
    CURSOR GET_LINE4_COUNTS IS
      SELECT
        HL.LOOKUP_CODE JCODE,
        COUNT(DECODE(PQH_NR_ALIEN_PKG.GET_COUNT_NR_ALIEN(PEO.PERSON_ID
                                                        ,P_REPORT_DATE)
                    ,'1'
                    ,DECODE(PEO.SEX
                          ,'M'
                          ,1
                          ,NULL)
                    ,NULL)) NRMEN,
        COUNT(DECODE(PQH_NR_ALIEN_PKG.GET_COUNT_NR_ALIEN(PEO.PERSON_ID
                                                        ,P_REPORT_DATE)
                    ,'1'
                    ,DECODE(PEO.SEX
                          ,'F'
                          ,1
                          ,NULL)
                    ,NULL)) NRWMEN,
        COUNT(DECODE(PQH_NR_ALIEN_PKG.GET_COUNT_NR_ALIEN(PEO.PERSON_ID
                                                        ,P_REPORT_DATE)
                    ,NULL
                    ,(DECODE(PEO.PER_INFORMATION1
                          ,'2'
                          ,DECODE(PEO.SEX
                                ,'M'
                                ,1
                                ,NULL)
                          ,NULL)))) BNHMEN,
        COUNT(DECODE(PQH_NR_ALIEN_PKG.GET_COUNT_NR_ALIEN(PEO.PERSON_ID
                                                        ,P_REPORT_DATE)
                    ,NULL
                    ,(DECODE(PEO.PER_INFORMATION1
                          ,'2'
                          ,DECODE(PEO.SEX
                                ,'F'
                                ,1
                                ,NULL)
                          ,NULL)))) BNHWMEN,
        COUNT(DECODE(PQH_NR_ALIEN_PKG.GET_COUNT_NR_ALIEN(PEO.PERSON_ID
                                                        ,P_REPORT_DATE)
                    ,NULL
                    ,(DECODE(PEO.PER_INFORMATION1
                          ,'6'
                          ,DECODE(PEO.SEX
                                ,'M'
                                ,1
                                ,NULL)
                          ,NULL)))) AM_ALMEN,
        COUNT(DECODE(PQH_NR_ALIEN_PKG.GET_COUNT_NR_ALIEN(PEO.PERSON_ID
                                                        ,P_REPORT_DATE)
                    ,NULL
                    ,(DECODE(PEO.PER_INFORMATION1
                          ,'6'
                          ,DECODE(PEO.SEX
                                ,'F'
                                ,1
                                ,NULL)
                          ,NULL)))) AM_ALWMEN,
        COUNT(DECODE(PQH_NR_ALIEN_PKG.GET_COUNT_NR_ALIEN(PEO.PERSON_ID
                                                        ,P_REPORT_DATE)
                    ,NULL
                    ,(DECODE(PEO.PER_INFORMATION1
                          ,'4'
                          ,DECODE(PEO.SEX
                                ,'M'
                                ,1
                                ,NULL)
                          ,'5'
                          ,DECODE(PEO.SEX
                                ,'M'
                                ,1
                                ,NULL)
                          ,NULL)))) APMEN,
        COUNT(DECODE(PQH_NR_ALIEN_PKG.GET_COUNT_NR_ALIEN(PEO.PERSON_ID
                                                        ,P_REPORT_DATE)
                    ,NULL
                    ,(DECODE(PEO.PER_INFORMATION1
                          ,'4'
                          ,DECODE(PEO.SEX
                                ,'F'
                                ,1
                                ,NULL)
                          ,'5'
                          ,DECODE(PEO.SEX
                                ,'F'
                                ,1
                                ,NULL)
                          ,NULL)))) APWMEN,
        COUNT(DECODE(PQH_NR_ALIEN_PKG.GET_COUNT_NR_ALIEN(PEO.PERSON_ID
                                                        ,P_REPORT_DATE)
                    ,NULL
                    ,(DECODE(PEO.PER_INFORMATION1
                          ,'3'
                          ,DECODE(PEO.SEX
                                ,'M'
                                ,1
                                ,NULL)
                          ,'9'
                          ,DECODE(PEO.SEX
                                ,'M'
                                ,1
                                ,NULL)
                          ,NULL)))) HMEN,
        COUNT(DECODE(PQH_NR_ALIEN_PKG.GET_COUNT_NR_ALIEN(PEO.PERSON_ID
                                                        ,P_REPORT_DATE)
                    ,NULL
                    ,(DECODE(PEO.PER_INFORMATION1
                          ,'3'
                          ,DECODE(PEO.SEX
                                ,'F'
                                ,1
                                ,NULL)
                          ,'9'
                          ,DECODE(PEO.SEX
                                ,'F'
                                ,1
                                ,NULL)
                          ,NULL)))) HWMEN,
        COUNT(DECODE(PQH_NR_ALIEN_PKG.GET_COUNT_NR_ALIEN(PEO.PERSON_ID
                                                        ,P_REPORT_DATE)
                    ,NULL
                    ,(DECODE(PEO.PER_INFORMATION1
                          ,'1'
                          ,DECODE(PEO.SEX
                                ,'M'
                                ,1
                                ,NULL)
                          ,NULL)))) WNHMEN,
        COUNT(DECODE(PQH_NR_ALIEN_PKG.GET_COUNT_NR_ALIEN(PEO.PERSON_ID
                                                        ,P_REPORT_DATE)
                    ,NULL
                    ,(DECODE(PEO.PER_INFORMATION1
                          ,'1'
                          ,DECODE(PEO.SEX
                                ,'F'
                                ,1
                                ,NULL)
                          ,NULL)))) WNHWMEN,
        COUNT(DECODE(PQH_NR_ALIEN_PKG.GET_COUNT_NR_ALIEN(PEO.PERSON_ID
                                                        ,P_REPORT_DATE)
                    ,NULL
                    ,(DECODE(PEO.PER_INFORMATION1
                          ,NULL
                          ,DECODE(PEO.SEX
                                ,'M'
                                ,1
                                ,NULL)
                          ,NULL)))) URMEN,
        COUNT(DECODE(PQH_NR_ALIEN_PKG.GET_COUNT_NR_ALIEN(PEO.PERSON_ID
                                                        ,P_REPORT_DATE)
                    ,NULL
                    ,(DECODE(PEO.PER_INFORMATION1
                          ,NULL
                          ,DECODE(PEO.SEX
                                ,'F'
                                ,1
                                ,NULL)
                          ,NULL)))) URWMEN,
        COUNT(DECODE(PEO.SEX
                    ,'M'
                    ,PEO.PERSON_ID
                    ,NULL)) TOTMEN,
        COUNT(DECODE(PEO.SEX
                    ,'F'
                    ,PEO.PERSON_ID
                    ,NULL)) TOTWMEN
      FROM
        PER_ALL_PEOPLE_F PEO,
        PER_ALL_ASSIGNMENTS_F PAF,
        PER_ASSIGNMENT_STATUS_TYPES AST,
        PER_JOBS JOB,
        HR_LOOKUPS HL
      WHERE PEO.PERSON_ID = PAF.PERSON_ID
        AND PEO.CURRENT_EMPLOYEE_FLAG = 'Y'
        AND HL.LOOKUP_CODE = JOB.JOB_INFORMATION8
        AND HL.LOOKUP_TYPE = 'US_IPEDS_JOB_CATEGORIES'
        AND JOB.JOB_INFORMATION_CATEGORY = 'US'
        AND HL.LOOKUP_CODE not in ( '1' , '2' , '3' , '4' , '12' )
        AND PQH_EMPLOYMENT_CATEGORY.IDENTIFY_EMPL_CATEGORY(PAF.EMPLOYMENT_CATEGORY
                                                    ,CP_FR
                                                    ,CP_FT
                                                    ,CP_PR
                                                    ,CP_PT) = 'FR'
        AND PQH_EMPLOYMENT_CATEGORY.GET_SERVICE_START_DATE(PAF.PERIOD_OF_SERVICE_ID) BETWEEN CP_HIRE_DATE
        AND P_REPORT_DATE
        AND PAF.PRIMARY_FLAG = 'Y'
        AND PAF.ASSIGNMENT_STATUS_TYPE_ID = AST.ASSIGNMENT_STATUS_TYPE_ID
        AND AST.PER_SYSTEM_STATUS <> 'TERM_ASSIGN'
        AND PAF.JOB_ID = JOB.JOB_ID
        AND PAF.ASSIGNMENT_TYPE = 'E'
        AND PAF.ORGANIZATION_ID in (
        SELECT
          ORGANIZATION_ID
        FROM
          HR_ALL_ORGANIZATION_UNITS
        WHERE BUSINESS_GROUP_ID = P_BUSINESS_GROUP_ID )
      GROUP BY
        HL.LOOKUP_CODE;
    CURSOR GET_LINE4_TMR_COUNTS(C_LOOKUP_CODE IN VARCHAR2) IS
      SELECT
        COUNT(DECODE(PEI.PEI_INFORMATION5
                    ,'2'
                    ,DECODE(PEO.SEX
                          ,'M'
                          ,1
                          ,NULL)
                    ,NULL)) BNHMEN,
        COUNT(DECODE(PEI.PEI_INFORMATION5
                    ,'2'
                    ,DECODE(PEO.SEX
                          ,'F'
                          ,1
                          ,NULL)
                    ,NULL)) BNHWMEN,
        COUNT(DECODE(PEI.PEI_INFORMATION5
                    ,'6'
                    ,DECODE(PEO.SEX
                          ,'M'
                          ,1
                          ,NULL)
                    ,NULL)) AM_ALMEN,
        COUNT(DECODE(PEI.PEI_INFORMATION5
                    ,'6'
                    ,DECODE(PEO.SEX
                          ,'F'
                          ,1
                          ,NULL)
                    ,NULL)) AM_ALWMEN,
        COUNT(DECODE(PEI.PEI_INFORMATION5
                    ,'4'
                    ,DECODE(PEO.SEX
                          ,'M'
                          ,1
                          ,NULL)
                    ,'5'
                    ,DECODE(PEO.SEX
                          ,'M'
                          ,1
                          ,NULL)
                    ,NULL)) A_PMEN,
        COUNT(DECODE(PEI.PEI_INFORMATION5
                    ,'4'
                    ,DECODE(PEO.SEX
                          ,'F'
                          ,1
                          ,NULL)
                    ,'5'
                    ,DECODE(PEO.SEX
                          ,'F'
                          ,1
                          ,NULL)
                    ,NULL)) A_PWMEN,
        COUNT(DECODE(PEI.PEI_INFORMATION5
                    ,'3'
                    ,DECODE(PEO.SEX
                          ,'M'
                          ,1
                          ,NULL)
                    ,'9'
                    ,DECODE(PEO.SEX
                          ,'M'
                          ,1
                          ,NULL)
                    ,NULL)) HMEN,
        COUNT(DECODE(PEI.PEI_INFORMATION5
                    ,'3'
                    ,DECODE(PEO.SEX
                          ,'F'
                          ,1
                          ,NULL)
                    ,'9'
                    ,DECODE(PEO.SEX
                          ,'F'
                          ,1
                          ,NULL)
                    ,NULL)) HWMEN,
        COUNT(DECODE(PEI.PEI_INFORMATION5
                    ,'1'
                    ,DECODE(PEO.SEX
                          ,'M'
                          ,1
                          ,NULL)
                    ,NULL)) WNHMEN,
        COUNT(DECODE(PEI.PEI_INFORMATION5
                    ,'1'
                    ,DECODE(PEO.SEX
                          ,'F'
                          ,1
                          ,NULL)
                    ,NULL)) WNHWMEN,
        COUNT(DECODE(PEI.PEI_INFORMATION5
                    ,NULL
                    ,DECODE(PEO.SEX
                          ,'M'
                          ,1
                          ,NULL)
                    ,NULL)) URMEN,
        COUNT(DECODE(PEI.PEI_INFORMATION5
                    ,NULL
                    ,DECODE(PEO.SEX
                          ,'F'
                          ,1
                          ,NULL)
                    ,NULL)) URWMEN
      FROM
        PER_ALL_PEOPLE_F PEO,
        PER_ALL_ASSIGNMENTS_F PAF,
        PER_ASSIGNMENT_STATUS_TYPES AST,
        PER_JOBS JOB,
        HR_LOOKUPS HL,
        PER_PEOPLE_EXTRA_INFO PEI
      WHERE PEO.PERSON_ID = PAF.PERSON_ID
        AND PEO.CURRENT_EMPLOYEE_FLAG = 'Y'
        AND PEO.PER_INFORMATION1 = '13'
        AND PEO.PERSON_ID = pei.person_id (+)
        AND ( PEI.INFORMATION_TYPE = 'PER_US_ADDL_ETHNIC_CAT'
      OR ( PEI.INFORMATION_TYPE <> 'PER_US_ADDL_ETHNIC_CAT'
        AND not exists (
        SELECT
          1
        FROM
          PER_PEOPLE_EXTRA_INFO PEI2
        WHERE PEI2.INFORMATION_TYPE = 'PER_US_ADDL_ETHNIC_CAT'
          AND PEI2.PERSON_ID = PEI.PERSON_ID )
        AND PEI.PERSON_EXTRA_INFO_ID = (
        SELECT
          MAX(PEI1.PERSON_EXTRA_INFO_ID)
        FROM
          PER_PEOPLE_EXTRA_INFO PEI1
        WHERE PEI1.PERSON_ID = PEI.PERSON_ID ) )
      OR ( not exists (
        SELECT
          PERSON_EXTRA_INFO_ID
        FROM
          PER_PEOPLE_EXTRA_INFO PEI3
        WHERE PEI3.PERSON_ID = PEI.PERSON_ID ) ) )
        AND HL.LOOKUP_CODE = JOB.JOB_INFORMATION8
        AND HL.LOOKUP_TYPE = 'US_IPEDS_JOB_CATEGORIES'
        AND JOB.JOB_INFORMATION_CATEGORY = 'US'
        AND HL.LOOKUP_CODE not in ( '1' , '2' , '3' , '4' , '12' )
        AND PQH_EMPLOYMENT_CATEGORY.IDENTIFY_EMPL_CATEGORY(PAF.EMPLOYMENT_CATEGORY
                                                    ,CP_FR
                                                    ,CP_FT
                                                    ,CP_PR
                                                    ,CP_PT) = 'FR'
        AND PQH_EMPLOYMENT_CATEGORY.GET_SERVICE_START_DATE(PAF.PERIOD_OF_SERVICE_ID) BETWEEN CP_HIRE_DATE
        AND P_REPORT_DATE
        AND PAF.PRIMARY_FLAG = 'Y'
        AND PAF.ASSIGNMENT_STATUS_TYPE_ID = AST.ASSIGNMENT_STATUS_TYPE_ID
        AND AST.PER_SYSTEM_STATUS <> 'TERM_ASSIGN'
        AND PAF.JOB_ID = JOB.JOB_ID
        AND PAF.ASSIGNMENT_TYPE = 'E'
        AND PAF.ORGANIZATION_ID in (
        SELECT
          ORGANIZATION_ID
        FROM
          HR_ALL_ORGANIZATION_UNITS
        WHERE BUSINESS_GROUP_ID = P_BUSINESS_GROUP_ID )
        AND HL.LOOKUP_CODE = C_LOOKUP_CODE;
  BEGIN
    --HR_STANDARD.EVENT('BEFORE REPORT');
    PQH_EMPLOYMENT_CATEGORY.FETCH_EMPL_CATEGORIES(P_BUSINESS_GROUP_ID
                                                 ,L_FR
                                                 ,L_FT
                                                 ,L_PR
                                                 ,L_PT);
    CP_FR := L_FR;
    CP_FT := L_FT;
    CP_PR := L_PR;
    CP_PT := L_PT;
    L_YEAR := TO_CHAR(P_REPORT_DATE
                     ,'RRRR');
    L_MONTH := SUBSTR(P_REPORT_DATE
                     ,4
                     ,3);
    L_DAY := SUBSTR(P_REPORT_DATE
                   ,1
                   ,2);
    IF L_YEAR = 0 THEN
      L_YEAR := 2000;
    END IF;
    IF L_MONTH in ('JAN','FEB','MAR','APR','MAY','JUN') THEN
      L_YEAR_AGO := (TO_CHAR(P_REPORT_DATE
                           ,'RRRR')) - 1;
      CP_HIRE_DATE := TO_DATE('01-07-' || L_YEAR_AGO
                             ,'dd-mm-rrrr');
    ELSE
      CP_HIRE_DATE := TO_DATE('01-07-' || L_YEAR
                             ,'dd-mm-rrrr');
    END IF;

    LP_HIRE_DATE := to_char(CP_HIRE_DATE,'DD-MON-YYYY');

 P_REPORT_DATE_T := to_char(P_REPORT_DATE,'DD-MON-YYYY');

    --RETURN TRUE;
    OPEN GET_LINE1_COUNTS;
    FETCH GET_LINE1_COUNTS
     INTO SC,L_NR_MEN,L_NR_WMEN,L_BNH_MEN,L_BNH_WMEN,L_AMAI_MEN,L_AMAI_WMEN,L_AP_MEN,L_AP_WMEN,L_H_MEN,L_H_WMEN,L_WNH_MEN,L_WNH_WMEN,L_UR_MEN,L_UR_WMEN;
    CLOSE GET_LINE1_COUNTS;
    L_TOT_MEN := L_NR_MEN + L_BNH_MEN + L_AMAI_MEN + L_AP_MEN + L_H_MEN + L_WNH_MEN + L_UR_MEN;
    L_TOT_WMEN := L_NR_WMEN + L_BNH_WMEN + L_AMAI_WMEN + L_AP_WMEN + L_H_WMEN + L_WNH_WMEN + L_UR_WMEN;
    OPEN GET_LINE1_TMRACES_COUNTS;
    FETCH GET_LINE1_TMRACES_COUNTS
     INTO L_TMR_BNH_MEN,L_TMR_BNH_WMEN,L_TMR_AMAI_MEN,L_TMR_AMAI_WMEN,L_TMR_AP_MEN,L_TMR_AP_WMEN,L_TMR_H_MEN,L_TMR_H_WMEN,L_TMR_WNH_MEN,L_TMR_WNH_WMEN,L_TMR_UR_MEN,L_TMR_UR_WMEN;
    CLOSE GET_LINE1_TMRACES_COUNTS;
    L_BNH_MEN := L_BNH_MEN + L_TMR_BNH_MEN;
    L_BNH_WMEN := L_BNH_WMEN + L_TMR_BNH_WMEN;
    L_AMAI_MEN := L_AMAI_MEN + L_TMR_AMAI_MEN;
    L_AMAI_WMEN := L_AMAI_WMEN + L_TMR_AMAI_WMEN;
    L_AP_MEN := L_AP_MEN + L_TMR_AP_MEN;
    L_AP_WMEN := L_AP_WMEN + L_TMR_AP_WMEN;
    L_H_MEN := L_H_MEN + L_TMR_H_MEN;
    L_H_WMEN := L_H_WMEN + L_TMR_H_WMEN;
    L_WNH_MEN := L_WNH_MEN + L_TMR_WNH_MEN;
    L_WNH_WMEN := L_WNH_WMEN + L_TMR_WNH_WMEN;
    L_UR_MEN := L_UR_MEN + L_TMR_UR_MEN;
    L_UR_WMEN := L_UR_WMEN + L_TMR_UR_WMEN;
    L_TOT_MEN := L_TOT_MEN + L_TMR_BNH_MEN + L_TMR_AMAI_MEN + L_TMR_AP_MEN + L_TMR_H_MEN + L_TMR_WNH_MEN + L_TMR_UR_MEN;
    L_TOT_WMEN := L_TOT_WMEN + L_TMR_BNH_WMEN + L_TMR_AMAI_WMEN + L_TMR_AP_WMEN + L_TMR_H_WMEN + L_TMR_WNH_WMEN + L_TMR_UR_WMEN;
    INSERT INTO PAY_US_RPT_TOTALS
      (SESSION_ID
      ,ATTRIBUTE1
      ,VALUE1
      ,VALUE2
      ,VALUE3
      ,VALUE4
      ,VALUE5
      ,VALUE6
      ,VALUE7
      ,VALUE8
      ,VALUE9
      ,VALUE10
      ,VALUE11
      ,VALUE12
      ,VALUE13
      ,VALUE14
      ,VALUE15
      ,VALUE16
      ,VALUE17)
    VALUES   (USERENV('sessionid')
      ,'IPED9'
      ,SC
      ,L_NR_MEN
      ,L_NR_WMEN
      ,L_BNH_MEN
      ,L_BNH_WMEN
      ,L_AMAI_MEN
      ,L_AMAI_WMEN
      ,L_AP_MEN
      ,L_AP_WMEN
      ,L_H_MEN
      ,L_H_WMEN
      ,L_WNH_MEN
      ,L_WNH_WMEN
      ,L_UR_MEN
      ,L_UR_WMEN
      ,L_TOT_MEN
      ,L_TOT_WMEN);
    COMMIT;
    OPEN GET_LINE2_COUNTS;
    FETCH GET_LINE2_COUNTS
     INTO SC,L_NR_MEN,L_NR_WMEN,L_BNH_MEN,L_BNH_WMEN,L_AMAI_MEN,L_AMAI_WMEN,L_AP_MEN,L_AP_WMEN,L_H_MEN,L_H_WMEN,L_WNH_MEN,L_WNH_WMEN,L_UR_MEN,L_UR_WMEN;
    CLOSE GET_LINE2_COUNTS;
    L_TOT_MEN := L_NR_MEN + L_BNH_MEN + L_AMAI_MEN + L_AP_MEN + L_H_MEN + L_WNH_MEN + L_UR_MEN;
    L_TOT_WMEN := L_NR_WMEN + L_BNH_WMEN + L_AMAI_WMEN + L_AP_WMEN + L_H_WMEN + L_WNH_WMEN + L_UR_WMEN;
    OPEN GET_TMR_LINE2_COUNTS;
    FETCH GET_TMR_LINE2_COUNTS
     INTO L_TMR_BNH_MEN,L_TMR_BNH_WMEN,L_TMR_AMAI_MEN,L_TMR_AMAI_WMEN,L_TMR_AP_MEN,L_TMR_AP_WMEN,L_TMR_H_MEN,L_TMR_H_WMEN,L_TMR_WNH_MEN,L_TMR_WNH_WMEN,L_TMR_UR_MEN,L_TMR_UR_WMEN;
    CLOSE GET_TMR_LINE2_COUNTS;
    L_BNH_MEN := L_BNH_MEN + L_TMR_BNH_MEN;
    L_BNH_WMEN := L_BNH_WMEN + L_TMR_BNH_WMEN;
    L_AMAI_MEN := L_AMAI_MEN + L_TMR_AMAI_MEN;
    L_AMAI_WMEN := L_AMAI_WMEN + L_TMR_AMAI_WMEN;
    L_AP_MEN := L_AP_MEN + L_TMR_AP_MEN;
    L_AP_WMEN := L_AP_WMEN + L_TMR_AP_WMEN;
    L_H_MEN := L_H_MEN + L_TMR_H_MEN;
    L_H_WMEN := L_H_WMEN + L_TMR_H_WMEN;
    L_WNH_MEN := L_WNH_MEN + L_TMR_WNH_MEN;
    L_WNH_WMEN := L_WNH_WMEN + L_TMR_WNH_WMEN;
    L_UR_MEN := L_UR_MEN + L_TMR_UR_MEN;
    L_UR_WMEN := L_UR_WMEN + L_TMR_UR_WMEN;
    L_TOT_MEN := L_TOT_MEN + L_TMR_BNH_MEN + L_TMR_AMAI_MEN + L_TMR_AP_MEN + L_TMR_H_MEN + L_TMR_WNH_MEN + L_TMR_UR_MEN;
    L_TOT_WMEN := L_TOT_WMEN + L_TMR_BNH_WMEN + L_TMR_AMAI_WMEN + L_TMR_AP_WMEN + L_TMR_H_WMEN + L_TMR_WNH_WMEN + L_TMR_UR_WMEN;
    INSERT INTO PAY_US_RPT_TOTALS
      (SESSION_ID
      ,ATTRIBUTE1
      ,VALUE1
      ,VALUE2
      ,VALUE3
      ,VALUE4
      ,VALUE5
      ,VALUE6
      ,VALUE7
      ,VALUE8
      ,VALUE9
      ,VALUE10
      ,VALUE11
      ,VALUE12
      ,VALUE13
      ,VALUE14
      ,VALUE15
      ,VALUE16
      ,VALUE17)
    VALUES   (USERENV('sessionid')
      ,'IPED9'
      ,SC
      ,L_NR_MEN
      ,L_NR_WMEN
      ,L_BNH_MEN
      ,L_BNH_WMEN
      ,L_AMAI_MEN
      ,L_AMAI_WMEN
      ,L_AP_MEN
      ,L_AP_WMEN
      ,L_H_MEN
      ,L_H_WMEN
      ,L_WNH_MEN
      ,L_WNH_WMEN
      ,L_UR_MEN
      ,L_UR_WMEN
      ,L_TOT_MEN
      ,L_TOT_WMEN);
    COMMIT;
    OPEN GET_LINE3_COUNTS;
    FETCH GET_LINE3_COUNTS
     INTO SC,L_NR_MEN,L_NR_WMEN,L_BNH_MEN,L_BNH_WMEN,L_AMAI_MEN,L_AMAI_WMEN,L_AP_MEN,L_AP_WMEN,L_H_MEN,L_H_WMEN,L_WNH_MEN,L_WNH_WMEN,L_UR_MEN,L_UR_WMEN;
    CLOSE GET_LINE3_COUNTS;
    L_TOT_MEN := L_NR_MEN + L_BNH_MEN + L_AMAI_MEN + L_AP_MEN + L_H_MEN + L_WNH_MEN + L_UR_MEN;
    L_TOT_WMEN := L_NR_WMEN + L_BNH_WMEN + L_AMAI_WMEN + L_AP_WMEN + L_H_WMEN + L_WNH_WMEN + L_UR_WMEN;
    OPEN GET_LINE3_TMR_COUNTS;
    FETCH GET_LINE3_TMR_COUNTS
     INTO L_TMR_BNH_MEN,L_TMR_BNH_WMEN,L_TMR_AMAI_MEN,L_TMR_AMAI_WMEN,L_TMR_AP_MEN,L_TMR_AP_WMEN,L_TMR_H_MEN,L_TMR_H_WMEN,L_TMR_WNH_MEN,L_TMR_WNH_WMEN,L_TMR_UR_MEN,L_TMR_UR_WMEN;
    CLOSE GET_LINE3_TMR_COUNTS;
    L_BNH_MEN := L_BNH_MEN + L_TMR_BNH_MEN;
    L_BNH_WMEN := L_BNH_WMEN + L_TMR_BNH_WMEN;
    L_AMAI_MEN := L_AMAI_MEN + L_TMR_AMAI_MEN;
    L_AMAI_WMEN := L_AMAI_WMEN + L_TMR_AMAI_WMEN;
    L_AP_MEN := L_AP_MEN + L_TMR_AP_MEN;
    L_AP_WMEN := L_AP_WMEN + L_TMR_AP_WMEN;
    L_H_MEN := L_H_MEN + L_TMR_H_MEN;
    L_H_WMEN := L_H_WMEN + L_TMR_H_WMEN;
    L_WNH_MEN := L_WNH_MEN + L_TMR_WNH_MEN;
    L_WNH_WMEN := L_WNH_WMEN + L_TMR_WNH_WMEN;
    L_UR_MEN := L_UR_MEN + L_TMR_UR_MEN;
    L_UR_WMEN := L_UR_WMEN + L_TMR_UR_WMEN;
    L_TOT_MEN := L_TOT_MEN + L_TMR_BNH_MEN + L_TMR_AMAI_MEN + L_TMR_AP_MEN + L_TMR_H_MEN + L_TMR_WNH_MEN + L_TMR_UR_MEN;
    L_TOT_WMEN := L_TOT_WMEN + L_TMR_BNH_WMEN + L_TMR_AMAI_WMEN + L_TMR_AP_WMEN + L_TMR_H_WMEN + L_TMR_WNH_WMEN + L_TMR_UR_WMEN;
    INSERT INTO PAY_US_RPT_TOTALS
      (SESSION_ID
      ,ATTRIBUTE1
      ,VALUE1
      ,VALUE2
      ,VALUE3
      ,VALUE4
      ,VALUE5
      ,VALUE6
      ,VALUE7
      ,VALUE8
      ,VALUE9
      ,VALUE10
      ,VALUE11
      ,VALUE12
      ,VALUE13
      ,VALUE14
      ,VALUE15
      ,VALUE16
      ,VALUE17)
    VALUES   (USERENV('sessionid')
      ,'IPED9'
      ,SC
      ,L_NR_MEN
      ,L_NR_WMEN
      ,L_BNH_MEN
      ,L_BNH_WMEN
      ,L_AMAI_MEN
      ,L_AMAI_WMEN
      ,L_AP_MEN
      ,L_AP_WMEN
      ,L_H_MEN
      ,L_H_WMEN
      ,L_WNH_MEN
      ,L_WNH_WMEN
      ,L_UR_MEN
      ,L_UR_WMEN
      ,L_TOT_MEN
      ,L_TOT_WMEN);
    COMMIT;
    FOR i IN GET_LINE4_COUNTS LOOP
      SC := I.JCODE;
      L_NR_MEN := I.NRMEN;
      L_NR_WMEN := I.NRWMEN;
      L_BNH_MEN := I.BNHMEN;
      L_BNH_WMEN := I.BNHWMEN;
      L_AMAI_MEN := I.AM_ALMEN;
      L_AMAI_WMEN := I.AM_ALWMEN;
      L_AP_MEN := I.APMEN;
      L_AP_WMEN := I.APWMEN;
      L_H_MEN := I.HMEN;
      L_H_WMEN := I.HWMEN;
      L_WNH_MEN := I.WNHMEN;
      L_WNH_WMEN := I.WNHWMEN;
      L_UR_MEN := I.URMEN;
      L_UR_WMEN := I.URWMEN;
      L_TOT_MEN := L_NR_MEN + L_BNH_MEN + L_AMAI_MEN + L_AP_MEN + L_H_MEN + L_WNH_MEN + L_UR_MEN;
      L_TOT_WMEN := L_NR_WMEN + L_BNH_WMEN + L_AMAI_WMEN + L_AP_WMEN + L_H_WMEN + L_WNH_WMEN + L_UR_WMEN;
      FOR j IN GET_LINE4_TMR_COUNTS(sc) LOOP
        L_BNH_MEN := L_BNH_MEN + J.BNHMEN;
        L_BNH_WMEN := L_BNH_WMEN + J.BNHWMEN;
        L_AMAI_MEN := L_AMAI_MEN + J.AM_ALMEN;
        L_AMAI_WMEN := L_AMAI_WMEN + J.AM_ALWMEN;
        L_AP_MEN := L_AP_MEN + J.A_PMEN;
        L_AP_WMEN := L_AP_WMEN + J.A_PWMEN;
        L_H_MEN := L_H_MEN + J.HMEN;
        L_H_WMEN := L_H_WMEN + J.HWMEN;
        L_WNH_MEN := L_WNH_MEN + J.WNHMEN;
        L_WNH_WMEN := L_WNH_WMEN + J.WNHWMEN;
        L_UR_MEN := L_UR_MEN + J.URMEN;
        L_UR_WMEN := L_UR_WMEN + J.URWMEN;
        L_TOT_MEN := L_TOT_MEN + J.BNHMEN + J.AM_ALMEN + J.A_PMEN + J.HMEN + J.WNHMEN + J.URMEN;
        L_TOT_WMEN := L_TOT_WMEN + J.BNHWMEN + J.AM_ALWMEN + J.A_PWMEN + J.HWMEN + J.WNHWMEN + J.URWMEN;
      END LOOP;
      INSERT INTO PAY_US_RPT_TOTALS
        (SESSION_ID
        ,ATTRIBUTE1
        ,VALUE1
        ,VALUE2
        ,VALUE3
        ,VALUE4
        ,VALUE5
        ,VALUE6
        ,VALUE7
        ,VALUE8
        ,VALUE9
        ,VALUE10
        ,VALUE11
        ,VALUE12
        ,VALUE13
        ,VALUE14
        ,VALUE15
        ,VALUE16
        ,VALUE17)
      VALUES   (USERENV('sessionid')
        ,'IPED9'
        ,SC
        ,L_NR_MEN
        ,L_NR_WMEN
        ,L_BNH_MEN
        ,L_BNH_WMEN
        ,L_AMAI_MEN
        ,L_AMAI_WMEN
        ,L_AP_MEN
        ,L_AP_WMEN
        ,L_H_MEN
        ,L_H_WMEN
        ,L_WNH_MEN
        ,L_WNH_WMEN
        ,L_UR_MEN
        ,L_UR_WMEN
        ,L_TOT_MEN
        ,L_TOT_WMEN);
      COMMIT;
    END LOOP;
    RETURN TRUE;
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  temp number(15);
  BEGIN
    --HR_STANDARD.EVENT('AFTER REPORT');
    EXECUTE IMMEDIATE
      'DELETE FROM pay_us_rpt_totals
                    WHERE attribute1 = ''IPED9''';
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION LINE_NUM_P RETURN NUMBER IS
  BEGIN
    RETURN LINE_NUM;
  END LINE_NUM_P;

  FUNCTION LAST_LINENO_P RETURN NUMBER IS
  BEGIN
    RETURN LAST_LINENO;
  END LAST_LINENO_P;

  FUNCTION TOTREPORTTITLE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN TOTREPORTTITLE;
  END TOTREPORTTITLE_P;

  FUNCTION CP_FR_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_FR;
  END CP_FR_P;

  FUNCTION CP_FT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_FT;
  END CP_FT_P;

  FUNCTION CP_PR_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_PR;
  END CP_PR_P;

  FUNCTION CP_PT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_PT;
  END CP_PT_P;

  FUNCTION CP_HIRE_DATE_P RETURN DATE IS
  BEGIN
    RETURN CP_HIRE_DATE;
  END CP_HIRE_DATE_P;

END PQH_PQIPED9_XMLP_PKG;

/
