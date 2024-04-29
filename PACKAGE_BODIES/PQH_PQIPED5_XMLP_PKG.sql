--------------------------------------------------------
--  DDL for Package Body PQH_PQIPED5_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_PQIPED5_XMLP_PKG" AS
/* $Header: PQIPED5B.pls 120.2 2008/03/18 10:57:35 amakrish noship $ */

FUNCTION CF_1FORMULA RETURN NUMBER IS
    TEMP_NUM NUMBER;
  BEGIN
    TEMP_NUM := LINE_NUM;
    LINE_NUM := LINE_NUM + 1;
    IF LINE_NUM = 9 THEN
      LINE_NUM := 10;
    END IF;
    RETURN TEMP_NUM;
  END CF_1FORMULA;

  FUNCTION SUMNRMENPERREPORTFORMULA(SUM_GT9_NRMEN IN NUMBER
                                   ,SUM_LT9_NRMEN IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (SUM_GT9_NRMEN + SUM_LT9_NRMEN);
  END SUMNRMENPERREPORTFORMULA;

  FUNCTION SUMNRWMENPERREPORTFORMULA(SUM_GT9_NRWMEN IN NUMBER
                                    ,SUM_LT9_NRWMEN IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (SUM_GT9_NRWMEN + SUM_LT9_NRWMEN);
  END SUMNRWMENPERREPORTFORMULA;

  FUNCTION SUMBNHMENPERREPORTFORMULA(SUM_GT9_BNHMEN IN NUMBER
                                    ,SUM_LT9_BNHMEN IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (SUM_GT9_BNHMEN + SUM_LT9_BNHMEN);
  END SUMBNHMENPERREPORTFORMULA;

  FUNCTION SUMBNHWMENPERREPORTFORMULA(SUM_GT9_BNHWMEN IN NUMBER
                                     ,SUM_LT9_BNHWMEN IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (SUM_GT9_BNHWMEN + SUM_LT9_BNHWMEN);
  END SUMBNHWMENPERREPORTFORMULA;

  FUNCTION SUMAM_ALMENPERREPORTFORMULA(SUM_GT9_AM_ALMEN IN NUMBER
                                      ,SUM_LT9_AM_ALMEN IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (SUM_GT9_AM_ALMEN + SUM_LT9_AM_ALMEN);
  END SUMAM_ALMENPERREPORTFORMULA;

  FUNCTION SUMAM_ALWMENPERREPORTFORMULA(SUM_GT9_AM_ALWMEN IN NUMBER
                                       ,SUM_LT9_AM_ALWMEN IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (SUM_GT9_AM_ALWMEN + SUM_LT9_AM_ALWMEN);
  END SUMAM_ALWMENPERREPORTFORMULA;

  FUNCTION SUMAPMENPERREPORTFORMULA(SUM_GT9_A_PMEN IN NUMBER
                                   ,SUM_LT9_APMEN IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (SUM_GT9_A_PMEN + SUM_LT9_APMEN);
  END SUMAPMENPERREPORTFORMULA;

  FUNCTION SUMAPWMENPERREPORTFORMULA(SUM_GT9_A_PWMEN IN NUMBER
                                    ,SUM_LT9_APWMEN IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (SUM_GT9_A_PWMEN + SUM_LT9_APWMEN);
  END SUMAPWMENPERREPORTFORMULA;

  FUNCTION SUMHMENPERREPORTFORMULA(SUM_GT9_HMEN IN NUMBER
                                  ,SUM_LT9_HMEN IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (SUM_GT9_HMEN + SUM_LT9_HMEN);
  END SUMHMENPERREPORTFORMULA;

  FUNCTION SUMHWMENPERREPORTFORMULA(SUM_GT9_HWMEN IN NUMBER
                                   ,SUM_LT9_HWMEN IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (SUM_GT9_HWMEN + SUM_LT9_HWMEN);
  END SUMHWMENPERREPORTFORMULA;

  FUNCTION SUMWNHMENPERREPORTFORMULA(SUM_GT9_WNHMEN IN NUMBER
                                    ,SUM_LT9_WNHMEN IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (SUM_GT9_WNHMEN + SUM_LT9_WNHMEN);
  END SUMWNHMENPERREPORTFORMULA;

  FUNCTION SUMWNHWMENPERREPORTFORMULA(SUM_GT9_WNHWMEN IN NUMBER
                                     ,SUM_LT9_WNHWMEN IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (SUM_GT9_WNHWMEN + SUM_LT9_WNHWMEN);
  END SUMWNHWMENPERREPORTFORMULA;

  FUNCTION SUMURMENPERREPORTFORMULA(SUM_GT9_URMEN IN NUMBER
                                   ,SUM_LT9_URMEN IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (SUM_GT9_URMEN + SUM_LT9_URMEN);
  END SUMURMENPERREPORTFORMULA;

  FUNCTION SUMURWMENPERREPORTFORMULA(SUM_GT9_URWMEN IN NUMBER
                                    ,SUM_LT9_URWMEN IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (SUM_GT9_URWMEN + SUM_LT9_URWMEN);
  END SUMURWMENPERREPORTFORMULA;

  FUNCTION SUMTOTMENPERREPORTFORMULA(SUM_GT9_TOTMEN IN NUMBER
                                    ,SUM_LT9_TOTMEN IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (SUM_GT9_TOTMEN + SUM_LT9_TOTMEN);
  END SUMTOTMENPERREPORTFORMULA;

  FUNCTION SUMTOTWMENPERREPORTFORMULA(SUM_GT9_TOTWMEN IN NUMBER
                                     ,SUM_LT9_TOTWMEN IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (SUM_GT9_TOTWMEN + SUM_LT9_TOTWMEN);
  END SUMTOTWMENPERREPORTFORMULA;

  FUNCTION CF_GROUPTOTTITLEFORMULA(SC IN VARCHAR2) RETURN CHAR IS
    L_TOTAL_TITLE VARCHAR2(200) := '';
    L_CONTR_CODE VARCHAR2(9) := SC;
  BEGIN
    IF L_CONTR_CODE = '02' THEN
      L_TOTAL_TITLE := 'Total 9/10 month salary contract (sum of Lines 2-8)';
    ELSIF L_CONTR_CODE = '03' THEN
      L_TOTAL_TITLE := 'Total 11/12 month salary contract (sum of Lines 10-16)';
    END IF;
    RETURN L_TOTAL_TITLE;
  END CF_GROUPTOTTITLEFORMULA;

  FUNCTION CF_LINENOGROUPFORMULA(SC IN VARCHAR2) RETURN NUMBER IS
    TEMP_NUM NUMBER;
    P_CONTR_CODE VARCHAR2(10) := SC;
  BEGIN
    IF P_CONTR_CODE = '02' THEN
      TEMP_NUM := 9;
    ELSIF P_CONTR_CODE = '03' THEN
      TEMP_NUM := 17;
    END IF;
    RETURN TEMP_NUM;
  END CF_LINENOGROUPFORMULA;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
    L_QUERY_TEXT VARCHAR2(2000);
    L_FR VARCHAR2(2000);
    L_FT VARCHAR2(2000);
    L_PR VARCHAR2(2000);
    L_PT VARCHAR2(2000);
    LINE VARCHAR2(1);
    SC VARCHAR2(2000);
    SALARY_RANGE VARCHAR2(2000);
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
    L_DURATION1 NUMBER(5) := 9;
    L_DURATION2 NUMBER(5) := 10;
    CURSOR GET_LINE1_COUNTS(C_DURATION1 IN NUMBER,C_DURATION2 IN NUMBER) IS
      SELECT
        1 LINE,
        DECODE(C_DURATION1
              ,9
              ,'02'
              ,11
              ,'03') SC,
        PQH_SALARY_CLASS_INTERVALS_PKG.GET_SALARY_INTERVAL(PQH_EMPLOYMENT_CATEGORY.IDENTIFY_EMPL_CATEGORY(ASS.EMPLOYMENT_CATEGORY
                                                                                                         ,CP_FR
                                                                                                         ,CP_FT
                                                                                                         ,CP_PR
                                                                                                         ,CP_PT)
                                                          ,NVL(PPP.PROPOSED_SALARY_N
                                                             ,0) * PPB.PAY_ANNUALIZATION_FACTOR) SALARY_RANGE,
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
                          ,NULL)))) A_PMEN,
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
                          ,NULL)))) A_PWMEN,
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
                          ,NULL))
                    ,NULL)) URMEN,
        COUNT(DECODE(PQH_NR_ALIEN_PKG.GET_COUNT_NR_ALIEN(PEO.PERSON_ID
                                                        ,P_REPORT_DATE)
                    ,NULL
                    ,(DECODE(PEO.PER_INFORMATION1
                          ,NULL
                          ,DECODE(PEO.SEX
                                ,'F'
                                ,1
                                ,NULL)
                          ,NULL))
                    ,NULL)) URWMEN
      FROM
        PER_ALL_PEOPLE_F PEO,
        PER_ALL_ASSIGNMENTS_F ASS,
        PER_ASSIGNMENT_STATUS_TYPES AST,
        PER_CONTRACTS_F PCO,
        PER_PAY_PROPOSALS PPP,
        PER_PAY_BASES PPB,
        HR_LOOKUPS HL,
        PER_JOBS JOB,
        PER_SHARED_TYPES PST,
        PER_SHARED_TYPES PST1
      WHERE PEO.PERSON_ID = ASS.PERSON_ID
        AND PEO.CURRENT_EMPLOYEE_FLAG = 'Y'
        AND PCO.PERSON_ID = PEO.PERSON_ID
        AND PQH_EMPLOYMENT_CATEGORY.IDENTIFY_EMPL_CATEGORY(ASS.EMPLOYMENT_CATEGORY
                                                    ,CP_FR
                                                    ,CP_FT
                                                    ,CP_PR
                                                    ,CP_PT) IN ( 'FR' )
        AND ASS.PAY_BASIS_ID = PPB.PAY_BASIS_ID
        AND ASS.ASSIGNMENT_ID = PPP.ASSIGNMENT_ID
        AND PPP.CHANGE_DATE = (
        SELECT
          MAX(CHANGE_DATE)
        FROM
          PER_PAY_PROPOSALS PRO
        WHERE PPP.ASSIGNMENT_ID = PRO.ASSIGNMENT_ID
          AND PRO.CHANGE_DATE <= P_REPORT_DATE
          AND PRO.APPROVED = 'Y' )
        AND NVL(PPP.PROPOSED_SALARY_N
         ,0) * PPB.PAY_ANNUALIZATION_FACTOR > 0
        AND P_REPORT_DATE BETWEEN PEO.EFFECTIVE_START_DATE
        AND PEO.EFFECTIVE_END_DATE
        AND P_REPORT_DATE BETWEEN ASS.EFFECTIVE_START_DATE
        AND ASS.EFFECTIVE_END_DATE
        AND P_REPORT_DATE BETWEEN PCO.EFFECTIVE_START_DATE
        AND PCO.EFFECTIVE_END_DATE
        AND ASS.PRIMARY_FLAG = 'Y'
        AND ASS.ASSIGNMENT_STATUS_TYPE_ID = AST.ASSIGNMENT_STATUS_TYPE_ID
        AND AST.PER_SYSTEM_STATUS <> 'TERM_ASSIGN'
        AND ASS.ASSIGNMENT_TYPE = 'E'
        AND PCO.TYPE = 'FULL_TIME'
        AND PCO.STATUS = PST.SYSTEM_TYPE_CD
        AND PST.LOOKUP_TYPE = 'CONTRACT_STATUS'
        AND pst1.system_type_cd (+) = PST.SYSTEM_TYPE_CD
        AND pst1.lookup_type (+) = PST.LOOKUP_TYPE
        AND PST.BUSINESS_GROUP_ID is null
        AND pst1.business_group_id (+) = P_BUSINESS_GROUP_ID
        AND NVL(PST1.INFORMATION1
         ,PST.INFORMATION1) = 'Y'
        AND PQH_EMPLOYMENT_CATEGORY.GET_DURATION_IN_MONTHS(PCO.DURATION
                                                    ,PCO.DURATION_UNITS
                                                    ,PCO.BUSINESS_GROUP_ID
                                                    ,P_REPORT_DATE) BETWEEN C_DURATION1
        AND C_DURATION2
        AND HL.LOOKUP_TYPE = 'US_IPEDS_JOB_CATEGORIES'
        AND JOB.JOB_INFORMATION8 in ( '1' , '2' , '3' )
        AND HL.LOOKUP_CODE = JOB.JOB_INFORMATION8
        AND JOB.JOB_INFORMATION_CATEGORY = 'US'
        AND ASS.JOB_ID = JOB.JOB_ID
        AND ASS.ORGANIZATION_ID in (
        SELECT
          ORG.ORGANIZATION_ID
        FROM
          HR_ALL_ORGANIZATION_UNITS ORG
        WHERE BUSINESS_GROUP_ID = P_BUSINESS_GROUP_ID
          AND PQH_INST_TYPE_PKG.GET_INST_TYPE(ORG.ORGANIZATION_ID) = 'NON-MED' )
      GROUP BY
        PQH_SALARY_CLASS_INTERVALS_PKG.GET_SALARY_INTERVAL(PQH_EMPLOYMENT_CATEGORY.IDENTIFY_EMPL_CATEGORY(ASS.EMPLOYMENT_CATEGORY
                                                                                                         ,CP_FR
                                                                                                         ,CP_FT
                                                                                                         ,CP_PR
                                                                                                         ,CP_PT)
                                                          ,NVL(PPP.PROPOSED_SALARY_N
                                                             ,0) * PPB.PAY_ANNUALIZATION_FACTOR);
    CURSOR GET_LINE1_TMRACES_COUNTS(C_SALARY_RANGE IN VARCHAR2,C_DURATION1 IN NUMBER,C_DURATION2 IN NUMBER) IS
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
        PER_ALL_ASSIGNMENTS_F ASS,
        PER_ASSIGNMENT_STATUS_TYPES AST,
        PER_CONTRACTS_F PCO,
        PER_PAY_PROPOSALS PPP,
        PER_PAY_BASES PPB,
        HR_LOOKUPS HL,
        PER_JOBS JOB,
        PER_SHARED_TYPES PST,
        PER_SHARED_TYPES PST1,
        PER_PEOPLE_EXTRA_INFO PEI
      WHERE PEO.PERSON_ID = ASS.PERSON_ID
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
        AND PCO.PERSON_ID = PEO.PERSON_ID
        AND PQH_EMPLOYMENT_CATEGORY.IDENTIFY_EMPL_CATEGORY(ASS.EMPLOYMENT_CATEGORY
                                                    ,CP_FR
                                                    ,CP_FT
                                                    ,CP_PR
                                                    ,CP_PT) IN ( 'FR' )
        AND ASS.PAY_BASIS_ID = PPB.PAY_BASIS_ID
        AND ASS.ASSIGNMENT_ID = PPP.ASSIGNMENT_ID
        AND PPP.CHANGE_DATE = (
        SELECT
          MAX(CHANGE_DATE)
        FROM
          PER_PAY_PROPOSALS PRO
        WHERE PPP.ASSIGNMENT_ID = PRO.ASSIGNMENT_ID
          AND PRO.CHANGE_DATE <= P_REPORT_DATE
          AND PRO.APPROVED = 'Y' )
        AND NVL(PPP.PROPOSED_SALARY_N
         ,0) * PPB.PAY_ANNUALIZATION_FACTOR > 0
        AND P_REPORT_DATE BETWEEN PEO.EFFECTIVE_START_DATE
        AND PEO.EFFECTIVE_END_DATE
        AND P_REPORT_DATE BETWEEN ASS.EFFECTIVE_START_DATE
        AND ASS.EFFECTIVE_END_DATE
        AND P_REPORT_DATE BETWEEN PCO.EFFECTIVE_START_DATE
        AND PCO.EFFECTIVE_END_DATE
        AND ASS.PRIMARY_FLAG = 'Y'
        AND ASS.ASSIGNMENT_STATUS_TYPE_ID = AST.ASSIGNMENT_STATUS_TYPE_ID
        AND AST.PER_SYSTEM_STATUS <> 'TERM_ASSIGN'
        AND ASS.ASSIGNMENT_TYPE = 'E'
        AND PCO.TYPE = 'FULL_TIME'
        AND PCO.STATUS = PST.SYSTEM_TYPE_CD
        AND PST.LOOKUP_TYPE = 'CONTRACT_STATUS'
        AND pst1.system_type_cd (+) = PST.SYSTEM_TYPE_CD
        AND pst1.lookup_type (+) = PST.LOOKUP_TYPE
        AND PST.BUSINESS_GROUP_ID is null
        AND pst1.business_group_id (+) = P_BUSINESS_GROUP_ID
        AND NVL(PST1.INFORMATION1
         ,PST.INFORMATION1) = 'Y'
        AND PQH_EMPLOYMENT_CATEGORY.GET_DURATION_IN_MONTHS(PCO.DURATION
                                                    ,PCO.DURATION_UNITS
                                                    ,PCO.BUSINESS_GROUP_ID
                                                    ,P_REPORT_DATE) BETWEEN C_DURATION1
        AND C_DURATION2
        AND HL.LOOKUP_TYPE = 'US_IPEDS_JOB_CATEGORIES'
        AND JOB.JOB_INFORMATION8 in ( '1' , '2' , '3' )
        AND HL.LOOKUP_CODE = JOB.JOB_INFORMATION8
        AND JOB.JOB_INFORMATION_CATEGORY = 'US'
        AND ASS.JOB_ID = JOB.JOB_ID
        AND ASS.ORGANIZATION_ID in (
        SELECT
          ORG.ORGANIZATION_ID
        FROM
          HR_ALL_ORGANIZATION_UNITS ORG
        WHERE BUSINESS_GROUP_ID = P_BUSINESS_GROUP_ID
          AND PQH_INST_TYPE_PKG.GET_INST_TYPE(ORG.ORGANIZATION_ID) = 'NON-MED' )
        AND PQH_SALARY_CLASS_INTERVALS_PKG.GET_SALARY_INTERVAL(PQH_EMPLOYMENT_CATEGORY.IDENTIFY_EMPL_CATEGORY(ASS.EMPLOYMENT_CATEGORY
                                                                                                       ,CP_FR
                                                                                                       ,CP_FT
                                                                                                       ,CP_PR
                                                                                                       ,CP_PT)
                                                        ,NVL(PPP.PROPOSED_SALARY_N
                                                           ,0) * PPB.PAY_ANNUALIZATION_FACTOR) = C_SALARY_RANGE;
    CURSOR GET_LINE2_COUNTS IS
      SELECT
        1 LINE,
        'Less than 9 months' DISP_NAME,
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
                          ,NULL)))) A_PMEN,
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
                          ,NULL)))) A_PWMEN,
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
        PER_ALL_ASSIGNMENTS_F ASS,
        PER_ASSIGNMENT_STATUS_TYPES AST,
        PER_CONTRACTS_F PCO,
        PER_PAY_PROPOSALS PPP,
        PER_PAY_BASES PPB,
        HR_LOOKUPS HL,
        PER_JOBS JOB,
        PER_SHARED_TYPES PST,
        PER_SHARED_TYPES PST1
      WHERE PEO.PERSON_ID = ASS.PERSON_ID
        AND PEO.CURRENT_EMPLOYEE_FLAG = 'Y'
        AND PCO.PERSON_ID = PEO.PERSON_ID
        AND PQH_EMPLOYMENT_CATEGORY.IDENTIFY_EMPL_CATEGORY(ASS.EMPLOYMENT_CATEGORY
                                                    ,CP_FR
                                                    ,CP_FT
                                                    ,CP_PR
                                                    ,CP_PT) IN ( 'FR' )
        AND ASS.PAY_BASIS_ID = PPB.PAY_BASIS_ID
        AND ASS.ASSIGNMENT_ID = PPP.ASSIGNMENT_ID
        AND PPP.CHANGE_DATE = (
        SELECT
          MAX(CHANGE_DATE)
        FROM
          PER_PAY_PROPOSALS PRO
        WHERE PPP.ASSIGNMENT_ID = PRO.ASSIGNMENT_ID
          AND PRO.CHANGE_DATE <= P_REPORT_DATE
          AND PRO.APPROVED = 'Y' )
        AND NVL(PPP.PROPOSED_SALARY_N
         ,0) * PPB.PAY_ANNUALIZATION_FACTOR > 0
        AND P_REPORT_DATE BETWEEN PEO.EFFECTIVE_START_DATE
        AND PEO.EFFECTIVE_END_DATE
        AND P_REPORT_DATE BETWEEN ASS.EFFECTIVE_START_DATE
        AND ASS.EFFECTIVE_END_DATE
        AND P_REPORT_DATE BETWEEN PCO.EFFECTIVE_START_DATE
        AND PCO.EFFECTIVE_END_DATE
        AND ASS.PRIMARY_FLAG = 'Y'
        AND ASS.ASSIGNMENT_STATUS_TYPE_ID = AST.ASSIGNMENT_STATUS_TYPE_ID
        AND AST.PER_SYSTEM_STATUS <> 'TERM_ASSIGN'
        AND ASS.ASSIGNMENT_TYPE = 'E'
        AND PCO.TYPE = 'FULL_TIME'
        AND PCO.STATUS = PST.SYSTEM_TYPE_CD
        AND PST.LOOKUP_TYPE = 'CONTRACT_STATUS'
        AND pst1.system_type_cd (+) = PST.SYSTEM_TYPE_CD
        AND pst1.lookup_type (+) = PST.LOOKUP_TYPE
        AND PST.BUSINESS_GROUP_ID is null
        AND pst1.business_group_id (+) = P_BUSINESS_GROUP_ID
        AND NVL(PST1.INFORMATION1
         ,PST.INFORMATION1) = 'Y'
        AND PQH_EMPLOYMENT_CATEGORY.GET_DURATION_IN_MONTHS(PCO.DURATION
                                                    ,PCO.DURATION_UNITS
                                                    ,PCO.BUSINESS_GROUP_ID
                                                    ,P_REPORT_DATE) < 9
        AND HL.LOOKUP_TYPE = 'US_IPEDS_JOB_CATEGORIES'
        AND JOB.JOB_INFORMATION8 in ( '1' , '2' , '3' )
        AND HL.LOOKUP_CODE = JOB.JOB_INFORMATION8
        AND JOB.JOB_INFORMATION_CATEGORY = 'US'
        AND ASS.JOB_ID = JOB.JOB_ID
        AND ASS.ORGANIZATION_ID in (
        SELECT
          ORG.ORGANIZATION_ID
        FROM
          HR_ALL_ORGANIZATION_UNITS ORG
        WHERE BUSINESS_GROUP_ID = P_BUSINESS_GROUP_ID
          AND PQH_INST_TYPE_PKG.GET_INST_TYPE(ORG.ORGANIZATION_ID) = 'NON-MED' );
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
        PER_ALL_ASSIGNMENTS_F ASS,
        PER_ASSIGNMENT_STATUS_TYPES AST,
        PER_CONTRACTS_F PCO,
        PER_PAY_PROPOSALS PPP,
        PER_PAY_BASES PPB,
        HR_LOOKUPS HL,
        PER_JOBS JOB,
        PER_SHARED_TYPES PST,
        PER_SHARED_TYPES PST1,
        PER_PEOPLE_EXTRA_INFO PEI
      WHERE PEO.PERSON_ID = ASS.PERSON_ID
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
        AND PCO.PERSON_ID = PEO.PERSON_ID
        AND PQH_EMPLOYMENT_CATEGORY.IDENTIFY_EMPL_CATEGORY(ASS.EMPLOYMENT_CATEGORY
                                                    ,CP_FR
                                                    ,CP_FT
                                                    ,CP_PR
                                                    ,CP_PT) IN ( 'FR' )
        AND ASS.PAY_BASIS_ID = PPB.PAY_BASIS_ID
        AND ASS.ASSIGNMENT_ID = PPP.ASSIGNMENT_ID
        AND PPP.CHANGE_DATE = (
        SELECT
          MAX(CHANGE_DATE)
        FROM
          PER_PAY_PROPOSALS PRO
        WHERE PPP.ASSIGNMENT_ID = PRO.ASSIGNMENT_ID
          AND PRO.CHANGE_DATE <= P_REPORT_DATE
          AND PRO.APPROVED = 'Y' )
        AND NVL(PPP.PROPOSED_SALARY_N
         ,0) * PPB.PAY_ANNUALIZATION_FACTOR > 0
        AND P_REPORT_DATE BETWEEN PEO.EFFECTIVE_START_DATE
        AND PEO.EFFECTIVE_END_DATE
        AND P_REPORT_DATE BETWEEN ASS.EFFECTIVE_START_DATE
        AND ASS.EFFECTIVE_END_DATE
        AND P_REPORT_DATE BETWEEN PCO.EFFECTIVE_START_DATE
        AND PCO.EFFECTIVE_END_DATE
        AND ASS.PRIMARY_FLAG = 'Y'
        AND ASS.ASSIGNMENT_STATUS_TYPE_ID = AST.ASSIGNMENT_STATUS_TYPE_ID
        AND AST.PER_SYSTEM_STATUS <> 'TERM_ASSIGN'
        AND ASS.ASSIGNMENT_TYPE = 'E'
        AND PCO.TYPE = 'FULL_TIME'
        AND PCO.STATUS = PST.SYSTEM_TYPE_CD
        AND PST.LOOKUP_TYPE = 'CONTRACT_STATUS'
        AND pst1.system_type_cd (+) = PST.SYSTEM_TYPE_CD
        AND pst1.lookup_type (+) = PST.LOOKUP_TYPE
        AND PST.BUSINESS_GROUP_ID is null
        AND pst1.business_group_id (+) = P_BUSINESS_GROUP_ID
        AND NVL(PST1.INFORMATION1
         ,PST.INFORMATION1) = 'Y'
        AND PQH_EMPLOYMENT_CATEGORY.GET_DURATION_IN_MONTHS(PCO.DURATION
                                                    ,PCO.DURATION_UNITS
                                                    ,PCO.BUSINESS_GROUP_ID
                                                    ,P_REPORT_DATE) < 9
        AND HL.LOOKUP_TYPE = 'US_IPEDS_JOB_CATEGORIES'
        AND JOB.JOB_INFORMATION8 in ( '1' , '2' , '3' )
        AND HL.LOOKUP_CODE = JOB.JOB_INFORMATION8
        AND JOB.JOB_INFORMATION_CATEGORY = 'US'
        AND ASS.JOB_ID = JOB.JOB_ID
        AND ASS.ORGANIZATION_ID in (
        SELECT
          ORG.ORGANIZATION_ID
        FROM
          HR_ALL_ORGANIZATION_UNITS ORG
        WHERE BUSINESS_GROUP_ID = P_BUSINESS_GROUP_ID
          AND PQH_INST_TYPE_PKG.GET_INST_TYPE(ORG.ORGANIZATION_ID) = 'NON-MED' );
  BEGIN
   -- HR_STANDARD.EVENT('BEFORE REPORT');
    PQH_EMPLOYMENT_CATEGORY.FETCH_EMPL_CATEGORIES(P_BUSINESS_GROUP_ID
                                                 ,L_FR
                                                 ,L_FT
                                                 ,L_PR
                                                 ,L_PT);
    CP_FR := L_FR;
    CP_FT := L_FT;
    CP_PR := L_PR;
    CP_PT := L_PT;
    FOR i IN 1 .. 2 LOOP
      IF I = 1 THEN
        L_DURATION1 := 9;
        L_DURATION2 := 10;
      ELSIF I = 2 THEN
        L_DURATION1 := 11;
        L_DURATION2 := 12;
      END IF;
      FOR i IN GET_LINE1_COUNTS(l_duration1,l_duration2) LOOP
        LINE := I.LINE;
        SC := I.SC;
        SALARY_RANGE := I.SALARY_RANGE;
        L_NR_MEN := I.NRMEN;
        L_NR_WMEN := I.NRWMEN;
        L_BNH_MEN := I.BNHMEN;
        L_BNH_WMEN := I.BNHWMEN;
        L_AMAI_MEN := I.AM_ALMEN;
        L_AMAI_WMEN := I.AM_ALWMEN;
        L_AP_MEN := I.A_PMEN;
        L_AP_WMEN := I.A_PWMEN;
        L_H_MEN := I.HMEN;
        L_H_WMEN := I.HWMEN;
        L_WNH_MEN := I.WNHMEN;
        L_WNH_WMEN := I.WNHWMEN;
        L_UR_MEN := I.URMEN;
        L_UR_WMEN := I.URWMEN;
        L_TOT_MEN := L_NR_MEN + L_BNH_MEN + L_AMAI_MEN + L_AP_MEN + L_H_MEN + L_WNH_MEN + L_UR_MEN;
        L_TOT_WMEN := L_NR_WMEN + L_BNH_WMEN + L_AMAI_WMEN + L_AP_WMEN + L_H_WMEN + L_WNH_WMEN + L_UR_WMEN;
        FOR j IN GET_LINE1_TMRACES_COUNTS(salary_range,l_duration1,l_duration2) LOOP
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
          ,ATTRIBUTE2
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
          ,VALUE17
          ,VALUE18)
        VALUES   (USERENV('sessionid')
          ,'IPED5'
          ,SALARY_RANGE
          ,LINE
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
    END LOOP;
    OPEN GET_LINE2_COUNTS;
    FETCH GET_LINE2_COUNTS
     INTO LINE,SC,L_NR_MEN,L_NR_WMEN,L_BNH_MEN,L_BNH_WMEN,L_AMAI_MEN,L_AMAI_WMEN,L_AP_MEN,L_AP_WMEN,L_H_MEN,L_H_WMEN,L_WNH_MEN,L_WNH_WMEN,L_UR_MEN,L_UR_WMEN;
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
      ,ATTRIBUTE2
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
      ,'IPED5'
      ,SC
      ,LINE
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
     RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
   -- HR_STANDARD.EVENT('AFTER REPORT');
    EXECUTE IMMEDIATE
      'DELETE FROM pay_us_rpt_totals
                    WHERE attribute1 = ''IPED5''';
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION LINE_NUM_P RETURN NUMBER IS
  BEGIN
    RETURN LINE_NUM;
  END LINE_NUM_P;

  FUNCTION CP_REPORTTOTTITLE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_REPORTTOTTITLE;
  END CP_REPORTTOTTITLE_P;

  FUNCTION CP_LASTLINENUM_P RETURN NUMBER IS
  BEGIN
    RETURN CP_LASTLINENUM;
  END CP_LASTLINENUM_P;

  FUNCTION CP_FT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_FT;
  END CP_FT_P;

  FUNCTION CP_FR_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_FR;
  END CP_FR_P;

  FUNCTION CP_PT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_PT;
  END CP_PT_P;

  FUNCTION CP_PR_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_PR;
  END CP_PR_P;
END PQH_PQIPED5_XMLP_PKG ;

/
