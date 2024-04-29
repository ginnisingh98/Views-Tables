--------------------------------------------------------
--  DDL for Package Body PQH_PQIPED8_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_PQIPED8_XMLP_PKG" AS
/* $Header: PQIPED8B.pls 120.3 2008/04/16 11:16:58 amakrish noship $ */

function BeforeReport return boolean is

l_fr	varchar2(2000);
l_ft	varchar2(2000);
l_pr	varchar2(2000);
l_pt	varchar2(2000);
LINE VARCHAR2(2000);
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
        '01' TENINFO,
        HLA.LOOKUP_CODE ARANK,
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
        HR_LOOKUPS HLA,
        PER_ALL_PEOPLE_F PEO,
        PER_ALL_ASSIGNMENTS_F PAF,
        PER_ASSIGNMENT_STATUS_TYPES AST,
        PER_PEOPLE_EXTRA_INFO PPEA,
        PER_PEOPLE_EXTRA_INFO PPET,
        HR_LOOKUPS HL,
        PER_PAY_PROPOSALS PPP,
        PER_PAY_BASES PPB,
        PER_JOBS JOB
      WHERE PAF.PERSON_ID = PPEA.PERSON_ID
        AND PEO.CURRENT_EMPLOYEE_FLAG = 'Y'
        AND PAF.PERSON_ID = PPET.PERSON_ID
        AND PAF.PERSON_ID = PEO.PERSON_ID
        AND PPEA.INFORMATION_TYPE = 'PQH_ACADEMIC_RANK'
        AND PPET.INFORMATION_TYPE = 'PQH_TENURE_STATUS'
        AND P_REPORT_DATE BETWEEN PAF.EFFECTIVE_START_DATE
        AND PAF.EFFECTIVE_END_DATE
        AND P_REPORT_DATE BETWEEN PEO.EFFECTIVE_START_DATE
        AND PEO.EFFECTIVE_END_DATE
        AND FND_DATE.CANONICAL_TO_DATE(PPET.PEI_INFORMATION2) <= P_REPORT_DATE
        AND P_REPORT_DATE BETWEEN FND_DATE.CANONICAL_TO_DATE(PPEA.PEI_INFORMATION2)
        AND FND_DATE.CANONICAL_TO_DATE(NVL(PPEA.PEI_INFORMATION3
                                    ,'4712/12/31 00:00:00'))
        AND PPET.PEI_INFORMATION1 in ( '01' )
        AND HLA.LOOKUP_TYPE = PPEA.INFORMATION_TYPE
        AND PPEA.PEI_INFORMATION1 = HLA.LOOKUP_CODE
        AND PPEA.PEI_INFORMATION1 IS NOT NULL
        AND PPEA.PEI_INFORMATION1 not in ( '01' )
        AND PPET.PEI_INFORMATION1 IS NOT NULL
        AND PAF.PRIMARY_FLAG = 'Y'
        AND PAF.ASSIGNMENT_TYPE = 'E'
        AND PAF.ASSIGNMENT_STATUS_TYPE_ID = AST.ASSIGNMENT_STATUS_TYPE_ID
        AND AST.PER_SYSTEM_STATUS <> 'TERM_ASSIGN'
        AND PQH_EMPLOYMENT_CATEGORY.IDENTIFY_EMPL_CATEGORY(PAF.EMPLOYMENT_CATEGORY
                                                    ,CP_FR
                                                    ,CP_FT
                                                    ,CP_PR
                                                    ,CP_PT) IN ( 'FR' )
        AND HL.LOOKUP_TYPE = 'US_IPEDS_JOB_CATEGORIES'
        AND JOB.JOB_INFORMATION8 in ( '1' , '2' , '3' )
        AND HL.LOOKUP_CODE = JOB.JOB_INFORMATION8
        AND JOB.JOB_INFORMATION_CATEGORY = 'US'
        AND PAF.JOB_ID = JOB.JOB_ID
        AND PAF.PAY_BASIS_ID = PPB.PAY_BASIS_ID
        AND PAF.ASSIGNMENT_ID = PPP.ASSIGNMENT_ID
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
        AND PAF.ORGANIZATION_ID IN (
        SELECT
          ORGANIZATION_ID
        FROM
          HR_ALL_ORGANIZATION_UNITS
        WHERE BUSINESS_GROUP_ID = P_BUSINESS_GROUP_ID )
      GROUP BY
        '01',
        HLA.LOOKUP_CODE;
    CURSOR GET_LINE1_TMRACES_COUNTS(C_LOOKUP_CODE IN VARCHAR2) IS
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
        HR_LOOKUPS HLA,
        PER_ALL_PEOPLE_F PEO,
        PER_ALL_ASSIGNMENTS_F PAF,
        PER_ASSIGNMENT_STATUS_TYPES AST,
        PER_PEOPLE_EXTRA_INFO PPEA,
        PER_PEOPLE_EXTRA_INFO PPET,
        HR_LOOKUPS HL,
        PER_PAY_PROPOSALS PPP,
        PER_PAY_BASES PPB,
        PER_JOBS JOB,
        PER_PEOPLE_EXTRA_INFO PEI
      WHERE PAF.PERSON_ID = PPEA.PERSON_ID
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
        AND PAF.PERSON_ID = PPET.PERSON_ID
        AND PAF.PERSON_ID = PEO.PERSON_ID
        AND PPEA.INFORMATION_TYPE = 'PQH_ACADEMIC_RANK'
        AND PPET.INFORMATION_TYPE = 'PQH_TENURE_STATUS'
        AND P_REPORT_DATE BETWEEN PAF.EFFECTIVE_START_DATE
        AND PAF.EFFECTIVE_END_DATE
        AND P_REPORT_DATE BETWEEN PEO.EFFECTIVE_START_DATE
        AND PEO.EFFECTIVE_END_DATE
        AND FND_DATE.CANONICAL_TO_DATE(PPET.PEI_INFORMATION2) <= P_REPORT_DATE
        AND P_REPORT_DATE BETWEEN FND_DATE.CANONICAL_TO_DATE(PPEA.PEI_INFORMATION2)
        AND FND_DATE.CANONICAL_TO_DATE(NVL(PPEA.PEI_INFORMATION3
                                    ,'4712/12/31 00:00:00'))
        AND PPET.PEI_INFORMATION1 in ( '01' )
        AND HLA.LOOKUP_TYPE = PPEA.INFORMATION_TYPE
        AND PPEA.PEI_INFORMATION1 = HLA.LOOKUP_CODE
        AND PPEA.PEI_INFORMATION1 IS NOT NULL
        AND PPEA.PEI_INFORMATION1 not in ( '01' )
        AND PPET.PEI_INFORMATION1 IS NOT NULL
        AND PAF.PRIMARY_FLAG = 'Y'
        AND PAF.ASSIGNMENT_TYPE = 'E'
        AND PAF.ASSIGNMENT_STATUS_TYPE_ID = AST.ASSIGNMENT_STATUS_TYPE_ID
        AND AST.PER_SYSTEM_STATUS <> 'TERM_ASSIGN'
        AND PQH_EMPLOYMENT_CATEGORY.IDENTIFY_EMPL_CATEGORY(PAF.EMPLOYMENT_CATEGORY
                                                    ,CP_FR
                                                    ,CP_FT
                                                    ,CP_PR
                                                    ,CP_PT) IN ( 'FR' )
        AND HL.LOOKUP_TYPE = 'US_IPEDS_JOB_CATEGORIES'
        AND JOB.JOB_INFORMATION8 in ( '1' , '2' , '3' )
        AND HL.LOOKUP_CODE = JOB.JOB_INFORMATION8
        AND JOB.JOB_INFORMATION_CATEGORY = 'US'
        AND PAF.JOB_ID = JOB.JOB_ID
        AND PAF.PAY_BASIS_ID = PPB.PAY_BASIS_ID
        AND PAF.ASSIGNMENT_ID = PPP.ASSIGNMENT_ID
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
        AND PAF.ORGANIZATION_ID IN (
        SELECT
          ORGANIZATION_ID
        FROM
          HR_ALL_ORGANIZATION_UNITS
        WHERE BUSINESS_GROUP_ID = P_BUSINESS_GROUP_ID )
        AND HLA.LOOKUP_CODE = C_LOOKUP_CODE;
    CURSOR GET_LINE2_COUNTS IS
      SELECT
        '01' TENINFO,
        '01' ARANK,
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
        HR_LOOKUPS HL,
        PER_PAY_PROPOSALS PPP,
        PER_PAY_BASES PPB,
        PER_JOBS JOB
      WHERE PAF.PERSON_ID = PPET.PERSON_ID
        AND PAF.PERSON_ID = PEO.PERSON_ID
        AND PEO.CURRENT_EMPLOYEE_FLAG = 'Y'
        AND PPET.INFORMATION_TYPE = 'PQH_TENURE_STATUS'
        AND P_REPORT_DATE BETWEEN PAF.EFFECTIVE_START_DATE
        AND PAF.EFFECTIVE_END_DATE
        AND P_REPORT_DATE BETWEEN PEO.EFFECTIVE_START_DATE
        AND PEO.EFFECTIVE_END_DATE
        AND FND_DATE.CANONICAL_TO_DATE(PPET.PEI_INFORMATION2) <= P_REPORT_DATE
        AND PPET.PEI_INFORMATION1 in ( '01' )
        AND PPET.PEI_INFORMATION1 IS NOT NULL
        AND not exists (
        SELECT
          PEA.PERSON_ID
        FROM
          PER_PEOPLE_EXTRA_INFO PEA
        WHERE PEA.PERSON_ID = PEO.PERSON_ID
          AND PEA.INFORMATION_TYPE in ( 'PQH_ACADEMIC_RANK' )
          AND PEA.PEI_INFORMATION1 in ( '02' , '03' , '04' , '05' , '06' )
          AND P_REPORT_DATE between FND_DATE.CANONICAL_TO_DATE(PEA.PEI_INFORMATION2)
          AND FND_DATE.CANONICAL_TO_DATE(NVL(PEA.PEI_INFORMATION3
                                      ,'4712/12/31 00:00:00')) )
        AND PAF.PRIMARY_FLAG = 'Y'
        AND PAF.ASSIGNMENT_TYPE = 'E'
        AND PAF.ASSIGNMENT_STATUS_TYPE_ID = AST.ASSIGNMENT_STATUS_TYPE_ID
        AND AST.PER_SYSTEM_STATUS <> 'TERM_ASSIGN'
        AND PQH_EMPLOYMENT_CATEGORY.IDENTIFY_EMPL_CATEGORY(PAF.EMPLOYMENT_CATEGORY
                                                    ,CP_FR
                                                    ,CP_FT
                                                    ,CP_PR
                                                    ,CP_PT) IN ( 'FR' )
        AND HL.LOOKUP_TYPE = 'US_IPEDS_JOB_CATEGORIES'
        AND JOB.JOB_INFORMATION8 in ( '1' , '2' , '3' )
        AND HL.LOOKUP_CODE = JOB.JOB_INFORMATION8
        AND JOB.JOB_INFORMATION_CATEGORY = 'US'
        AND PAF.JOB_ID = JOB.JOB_ID
        AND PAF.PAY_BASIS_ID = PPB.PAY_BASIS_ID
        AND PAF.ASSIGNMENT_ID = PPP.ASSIGNMENT_ID
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
        AND PAF.ORGANIZATION_ID IN (
        SELECT
          ORGANIZATION_ID
        FROM
          HR_ALL_ORGANIZATION_UNITS
        WHERE BUSINESS_GROUP_ID = P_BUSINESS_GROUP_ID )
      GROUP BY
        '01',
        '01';
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
        HR_LOOKUPS HL,
        PER_PAY_PROPOSALS PPP,
        PER_PAY_BASES PPB,
        PER_JOBS JOB,
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
        AND PPET.INFORMATION_TYPE = 'PQH_TENURE_STATUS'
        AND P_REPORT_DATE BETWEEN PAF.EFFECTIVE_START_DATE
        AND PAF.EFFECTIVE_END_DATE
        AND P_REPORT_DATE BETWEEN PEO.EFFECTIVE_START_DATE
        AND PEO.EFFECTIVE_END_DATE
        AND FND_DATE.CANONICAL_TO_DATE(PPET.PEI_INFORMATION2) <= P_REPORT_DATE
        AND PPET.PEI_INFORMATION1 in ( '01' )
        AND PPET.PEI_INFORMATION1 IS NOT NULL
        AND not exists (
        SELECT
          PEA.PERSON_ID
        FROM
          PER_PEOPLE_EXTRA_INFO PEA
        WHERE PEA.PERSON_ID = PEO.PERSON_ID
          AND PEA.INFORMATION_TYPE in ( 'PQH_ACADEMIC_RANK' )
          AND PEA.PEI_INFORMATION1 in ( '02' , '03' , '04' , '05' , '06' )
          AND P_REPORT_DATE between FND_DATE.CANONICAL_TO_DATE(PEA.PEI_INFORMATION2)
          AND FND_DATE.CANONICAL_TO_DATE(NVL(PEA.PEI_INFORMATION3
                                      ,'4712/12/31 00:00:00')) )
        AND PAF.PRIMARY_FLAG = 'Y'
        AND PAF.ASSIGNMENT_TYPE = 'E'
        AND PAF.ASSIGNMENT_STATUS_TYPE_ID = AST.ASSIGNMENT_STATUS_TYPE_ID
        AND AST.PER_SYSTEM_STATUS <> 'TERM_ASSIGN'
        AND PQH_EMPLOYMENT_CATEGORY.IDENTIFY_EMPL_CATEGORY(PAF.EMPLOYMENT_CATEGORY
                                                    ,CP_FR
                                                    ,CP_FT
                                                    ,CP_PR
                                                    ,CP_PT) IN ( 'FR' )
        AND HL.LOOKUP_TYPE = 'US_IPEDS_JOB_CATEGORIES'
        AND JOB.JOB_INFORMATION8 in ( '1' , '2' , '3' )
        AND HL.LOOKUP_CODE = JOB.JOB_INFORMATION8
        AND JOB.JOB_INFORMATION_CATEGORY = 'US'
        AND PAF.JOB_ID = JOB.JOB_ID
        AND PAF.PAY_BASIS_ID = PPB.PAY_BASIS_ID
        AND PAF.ASSIGNMENT_ID = PPP.ASSIGNMENT_ID
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
        AND PAF.ORGANIZATION_ID IN (
        SELECT
          ORGANIZATION_ID
        FROM
          HR_ALL_ORGANIZATION_UNITS
        WHERE BUSINESS_GROUP_ID = P_BUSINESS_GROUP_ID );
    CURSOR GET_LINE3_COUNTS IS
      SELECT
        '02' TENINFO,
        HLA.LOOKUP_CODE ARANK,
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
        HR_LOOKUPS HLA,
        PER_ALL_PEOPLE_F PEO,
        PER_ALL_ASSIGNMENTS_F PAF,
        PER_ASSIGNMENT_STATUS_TYPES AST,
        PER_PEOPLE_EXTRA_INFO PPEA,
        PER_PEOPLE_EXTRA_INFO PPET,
        HR_LOOKUPS HL,
        PER_PAY_PROPOSALS PPP,
        PER_PAY_BASES PPB,
        PER_JOBS JOB
      WHERE PAF.PERSON_ID = PPEA.PERSON_ID
        AND PAF.PERSON_ID = PPET.PERSON_ID
        AND PAF.PERSON_ID = PEO.PERSON_ID
        AND PEO.CURRENT_EMPLOYEE_FLAG = 'Y'
        AND PPEA.INFORMATION_TYPE = 'PQH_ACADEMIC_RANK'
        AND PPET.INFORMATION_TYPE = 'PQH_TENURE_STATUS'
        AND P_REPORT_DATE BETWEEN PAF.EFFECTIVE_START_DATE
        AND PAF.EFFECTIVE_END_DATE
        AND P_REPORT_DATE BETWEEN PEO.EFFECTIVE_START_DATE
        AND PEO.EFFECTIVE_END_DATE
        AND FND_DATE.CANONICAL_TO_DATE(PPET.PEI_INFORMATION2) <= P_REPORT_DATE
        AND P_REPORT_DATE BETWEEN FND_DATE.CANONICAL_TO_DATE(PPEA.PEI_INFORMATION2)
        AND FND_DATE.CANONICAL_TO_DATE(NVL(PPEA.PEI_INFORMATION3
                                    ,'4712/12/31 00:00:00'))
        AND PPET.PEI_INFORMATION1 in ( '02' , '04' )
        AND HLA.LOOKUP_TYPE = PPEA.INFORMATION_TYPE
        AND PPEA.PEI_INFORMATION1 = HLA.LOOKUP_CODE
        AND PPEA.PEI_INFORMATION1 IS NOT NULL
        AND PPET.PEI_INFORMATION1 IS NOT NULL
        AND PPEA.PEI_INFORMATION1 not in ( '01' )
        AND PAF.PRIMARY_FLAG = 'Y'
        AND PAF.ASSIGNMENT_TYPE = 'E'
        AND PAF.ASSIGNMENT_STATUS_TYPE_ID = AST.ASSIGNMENT_STATUS_TYPE_ID
        AND AST.PER_SYSTEM_STATUS <> 'TERM_ASSIGN'
        AND PQH_EMPLOYMENT_CATEGORY.IDENTIFY_EMPL_CATEGORY(PAF.EMPLOYMENT_CATEGORY
                                                    ,CP_FR
                                                    ,CP_FT
                                                    ,CP_PR
                                                    ,CP_PT) IN ( 'FR' )
        AND HL.LOOKUP_TYPE = 'US_IPEDS_JOB_CATEGORIES'
        AND JOB.JOB_INFORMATION8 in ( '1' , '2' , '3' )
        AND HL.LOOKUP_CODE = JOB.JOB_INFORMATION8
        AND JOB.JOB_INFORMATION_CATEGORY = 'US'
        AND PAF.JOB_ID = JOB.JOB_ID
        AND PAF.PAY_BASIS_ID = PPB.PAY_BASIS_ID
        AND PAF.ASSIGNMENT_ID = PPP.ASSIGNMENT_ID
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
        AND PAF.ORGANIZATION_ID IN (
        SELECT
          ORGANIZATION_ID
        FROM
          HR_ALL_ORGANIZATION_UNITS
        WHERE BUSINESS_GROUP_ID = P_BUSINESS_GROUP_ID )
      GROUP BY
        '02',
        HLA.LOOKUP_CODE;
    CURSOR GET_LINE3_TMR_COUNTS(C_LOOKUP_CODE IN VARCHAR2) IS
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
        HR_LOOKUPS HLA,
        PER_ALL_PEOPLE_F PEO,
        PER_ALL_ASSIGNMENTS_F PAF,
        PER_ASSIGNMENT_STATUS_TYPES AST,
        PER_PEOPLE_EXTRA_INFO PPEA,
        PER_PEOPLE_EXTRA_INFO PPET,
        HR_LOOKUPS HL,
        PER_PAY_PROPOSALS PPP,
        PER_PAY_BASES PPB,
        PER_JOBS JOB,
        PER_PEOPLE_EXTRA_INFO PEI
      WHERE PAF.PERSON_ID = PPEA.PERSON_ID
        AND PAF.PERSON_ID = PPET.PERSON_ID
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
        AND PPEA.INFORMATION_TYPE = 'PQH_ACADEMIC_RANK'
        AND PPET.INFORMATION_TYPE = 'PQH_TENURE_STATUS'
        AND P_REPORT_DATE BETWEEN PAF.EFFECTIVE_START_DATE
        AND PAF.EFFECTIVE_END_DATE
        AND P_REPORT_DATE BETWEEN PEO.EFFECTIVE_START_DATE
        AND PEO.EFFECTIVE_END_DATE
        AND FND_DATE.CANONICAL_TO_DATE(PPET.PEI_INFORMATION2) <= P_REPORT_DATE
        AND P_REPORT_DATE BETWEEN FND_DATE.CANONICAL_TO_DATE(PPEA.PEI_INFORMATION2)
        AND FND_DATE.CANONICAL_TO_DATE(NVL(PPEA.PEI_INFORMATION3
                                    ,'4712/12/31 00:00:00'))
        AND PPET.PEI_INFORMATION1 in ( '02' , '04' )
        AND HLA.LOOKUP_TYPE = PPEA.INFORMATION_TYPE
        AND PPEA.PEI_INFORMATION1 = HLA.LOOKUP_CODE
        AND PPEA.PEI_INFORMATION1 IS NOT NULL
        AND PPET.PEI_INFORMATION1 IS NOT NULL
        AND PPEA.PEI_INFORMATION1 not in ( '01' )
        AND PAF.PRIMARY_FLAG = 'Y'
        AND PAF.ASSIGNMENT_TYPE = 'E'
        AND PAF.ASSIGNMENT_STATUS_TYPE_ID = AST.ASSIGNMENT_STATUS_TYPE_ID
        AND AST.PER_SYSTEM_STATUS <> 'TERM_ASSIGN'
        AND PQH_EMPLOYMENT_CATEGORY.IDENTIFY_EMPL_CATEGORY(PAF.EMPLOYMENT_CATEGORY
                                                    ,CP_FR
                                                    ,CP_FT
                                                    ,CP_PR
                                                    ,CP_PT) IN ( 'FR' )
        AND HL.LOOKUP_TYPE = 'US_IPEDS_JOB_CATEGORIES'
        AND JOB.JOB_INFORMATION8 in ( '1' , '2' , '3' )
        AND HL.LOOKUP_CODE = JOB.JOB_INFORMATION8
        AND JOB.JOB_INFORMATION_CATEGORY = 'US'
        AND PAF.JOB_ID = JOB.JOB_ID
        AND PAF.PAY_BASIS_ID = PPB.PAY_BASIS_ID
        AND PAF.ASSIGNMENT_ID = PPP.ASSIGNMENT_ID
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
        AND PAF.ORGANIZATION_ID IN (
        SELECT
          ORGANIZATION_ID
        FROM
          HR_ALL_ORGANIZATION_UNITS
        WHERE BUSINESS_GROUP_ID = P_BUSINESS_GROUP_ID )
        AND HLA.LOOKUP_CODE = C_LOOKUP_CODE;
    CURSOR GET_LINE4_COUNTS IS
      SELECT
        '02' TENINFO,
        '01' ARANK,
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
        HR_LOOKUPS HL,
        PER_PAY_PROPOSALS PPP,
        PER_PAY_BASES PPB,
        PER_JOBS JOB
      WHERE PAF.PERSON_ID = PPET.PERSON_ID
        AND PAF.PERSON_ID = PEO.PERSON_ID
        AND PEO.CURRENT_EMPLOYEE_FLAG = 'Y'
        AND PPET.INFORMATION_TYPE = 'PQH_TENURE_STATUS'
        AND P_REPORT_DATE BETWEEN PAF.EFFECTIVE_START_DATE
        AND PAF.EFFECTIVE_END_DATE
        AND P_REPORT_DATE BETWEEN PEO.EFFECTIVE_START_DATE
        AND PEO.EFFECTIVE_END_DATE
        AND FND_DATE.CANONICAL_TO_DATE(PPET.PEI_INFORMATION2) <= P_REPORT_DATE
        AND PPET.PEI_INFORMATION1 in ( '02' , '04' )
        AND PPET.PEI_INFORMATION1 IS NOT NULL
        AND not exists (
        SELECT
          PEA.PERSON_ID
        FROM
          PER_PEOPLE_EXTRA_INFO PEA
        WHERE PEA.PERSON_ID = PEO.PERSON_ID
          AND PEA.INFORMATION_TYPE in ( 'PQH_ACADEMIC_RANK' )
          AND PEA.PEI_INFORMATION1 in ( '02' , '03' , '04' , '05' , '06' )
          AND P_REPORT_DATE between FND_DATE.CANONICAL_TO_DATE(PEA.PEI_INFORMATION2)
          AND FND_DATE.CANONICAL_TO_DATE(NVL(PEA.PEI_INFORMATION3
                                      ,'4712/12/31 00:00:00')) )
        AND PAF.PRIMARY_FLAG = 'Y'
        AND PAF.ASSIGNMENT_TYPE = 'E'
        AND PAF.ASSIGNMENT_STATUS_TYPE_ID = AST.ASSIGNMENT_STATUS_TYPE_ID
        AND AST.PER_SYSTEM_STATUS <> 'TERM_ASSIGN'
        AND PQH_EMPLOYMENT_CATEGORY.IDENTIFY_EMPL_CATEGORY(PAF.EMPLOYMENT_CATEGORY
                                                    ,CP_FR
                                                    ,CP_FT
                                                    ,CP_PR
                                                    ,CP_PT) IN ( 'FR' )
        AND HL.LOOKUP_TYPE = 'US_IPEDS_JOB_CATEGORIES'
        AND JOB.JOB_INFORMATION8 in ( '1' , '2' , '3' )
        AND HL.LOOKUP_CODE = JOB.JOB_INFORMATION8
        AND JOB.JOB_INFORMATION_CATEGORY = 'US'
        AND PAF.JOB_ID = JOB.JOB_ID
        AND PAF.PAY_BASIS_ID = PPB.PAY_BASIS_ID
        AND PAF.ASSIGNMENT_ID = PPP.ASSIGNMENT_ID
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
        AND PAF.ORGANIZATION_ID IN (
        SELECT
          ORGANIZATION_ID
        FROM
          HR_ALL_ORGANIZATION_UNITS
        WHERE BUSINESS_GROUP_ID = P_BUSINESS_GROUP_ID )
      GROUP BY
        '02',
        '01';
    CURSOR GET_LINE4_TMR_COUNTS IS
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
        HR_LOOKUPS HL,
        PER_PAY_PROPOSALS PPP,
        PER_PAY_BASES PPB,
        PER_JOBS JOB,
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
        AND PPET.INFORMATION_TYPE = 'PQH_TENURE_STATUS'
        AND P_REPORT_DATE BETWEEN PAF.EFFECTIVE_START_DATE
        AND PAF.EFFECTIVE_END_DATE
        AND P_REPORT_DATE BETWEEN PEO.EFFECTIVE_START_DATE
        AND PEO.EFFECTIVE_END_DATE
        AND FND_DATE.CANONICAL_TO_DATE(PPET.PEI_INFORMATION2) <= P_REPORT_DATE
        AND PPET.PEI_INFORMATION1 in ( '02' , '04' )
        AND PPET.PEI_INFORMATION1 IS NOT NULL
        AND not exists (
        SELECT
          PEA.PERSON_ID
        FROM
          PER_PEOPLE_EXTRA_INFO PEA
        WHERE PEA.PERSON_ID = PEO.PERSON_ID
          AND PEA.INFORMATION_TYPE in ( 'PQH_ACADEMIC_RANK' )
          AND PEA.PEI_INFORMATION1 in ( '02' , '03' , '04' , '05' , '06' )
          AND P_REPORT_DATE between FND_DATE.CANONICAL_TO_DATE(PEA.PEI_INFORMATION2)
          AND FND_DATE.CANONICAL_TO_DATE(NVL(PEA.PEI_INFORMATION3
                                      ,'4712/12/31 00:00:00')) )
        AND PAF.PRIMARY_FLAG = 'Y'
        AND PAF.ASSIGNMENT_TYPE = 'E'
        AND PAF.ASSIGNMENT_STATUS_TYPE_ID = AST.ASSIGNMENT_STATUS_TYPE_ID
        AND AST.PER_SYSTEM_STATUS <> 'TERM_ASSIGN'
        AND PQH_EMPLOYMENT_CATEGORY.IDENTIFY_EMPL_CATEGORY(PAF.EMPLOYMENT_CATEGORY
                                                    ,CP_FR
                                                    ,CP_FT
                                                    ,CP_PR
                                                    ,CP_PT) IN ( 'FR' )
        AND HL.LOOKUP_TYPE = 'US_IPEDS_JOB_CATEGORIES'
        AND JOB.JOB_INFORMATION8 in ( '1' , '2' , '3' )
        AND HL.LOOKUP_CODE = JOB.JOB_INFORMATION8
        AND JOB.JOB_INFORMATION_CATEGORY = 'US'
        AND PAF.JOB_ID = JOB.JOB_ID
        AND PAF.PAY_BASIS_ID = PPB.PAY_BASIS_ID
        AND PAF.ASSIGNMENT_ID = PPP.ASSIGNMENT_ID
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
        AND PAF.ORGANIZATION_ID IN (
        SELECT
          ORGANIZATION_ID
        FROM
          HR_ALL_ORGANIZATION_UNITS
        WHERE BUSINESS_GROUP_ID = P_BUSINESS_GROUP_ID );
    CURSOR GET_LINE5_COUNTS IS
      SELECT
        '03' TENINFO,
        HLA.LOOKUP_CODE ARANK,
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
        HR_LOOKUPS HLA,
        PER_ALL_PEOPLE_F PEO,
        PER_ALL_ASSIGNMENTS_F PAF,
        PER_ASSIGNMENT_STATUS_TYPES AST,
        PER_PEOPLE_EXTRA_INFO PPEA,
        HR_LOOKUPS HL,
        PER_PAY_PROPOSALS PPP,
        PER_PAY_BASES PPB,
        PER_JOBS JOB
      WHERE PAF.PERSON_ID = PEO.PERSON_ID
        AND PEO.CURRENT_EMPLOYEE_FLAG = 'Y'
        AND PAF.PERSON_ID = PPEA.PERSON_ID
        AND PPEA.INFORMATION_TYPE = 'PQH_ACADEMIC_RANK'
        AND P_REPORT_DATE BETWEEN PAF.EFFECTIVE_START_DATE
        AND PAF.EFFECTIVE_END_DATE
        AND P_REPORT_DATE BETWEEN PEO.EFFECTIVE_START_DATE
        AND PEO.EFFECTIVE_END_DATE
        AND HLA.LOOKUP_TYPE = PPEA.INFORMATION_TYPE
        AND PPEA.PEI_INFORMATION1 = HLA.LOOKUP_CODE
        AND PPEA.PEI_INFORMATION1 not in ( '01' )
        AND P_REPORT_DATE BETWEEN FND_DATE.CANONICAL_TO_DATE(PPEA.PEI_INFORMATION2)
        AND FND_DATE.CANONICAL_TO_DATE(NVL(PPEA.PEI_INFORMATION3
                                    ,'4712/12/31 00:00:00'))
        AND PPEA.PEI_INFORMATION1 IS NOT NULL
        AND not exists (
        SELECT
          PET.PERSON_ID
        FROM
          PER_PEOPLE_EXTRA_INFO PET
        WHERE PET.PERSON_ID = PEO.PERSON_ID
          AND PET.INFORMATION_TYPE in ( 'PQH_TENURE_STATUS' )
          AND PET.PEI_INFORMATION1 in ( '01' , '02' , '04' )
          AND FND_DATE.CANONICAL_TO_DATE(PET.PEI_INFORMATION2) <= P_REPORT_DATE )
        AND PAF.PRIMARY_FLAG = 'Y'
        AND PAF.ASSIGNMENT_TYPE = 'E'
        AND PAF.ASSIGNMENT_STATUS_TYPE_ID = AST.ASSIGNMENT_STATUS_TYPE_ID
        AND AST.PER_SYSTEM_STATUS <> 'TERM_ASSIGN'
        AND PQH_EMPLOYMENT_CATEGORY.IDENTIFY_EMPL_CATEGORY(PAF.EMPLOYMENT_CATEGORY
                                                    ,CP_FR
                                                    ,CP_FT
                                                    ,CP_PR
                                                    ,CP_PT) IN ( 'FR' )
        AND HL.LOOKUP_TYPE = 'US_IPEDS_JOB_CATEGORIES'
        AND JOB.JOB_INFORMATION8 in ( '1' , '2' , '3' )
        AND HL.LOOKUP_CODE = JOB.JOB_INFORMATION8
        AND JOB.JOB_INFORMATION_CATEGORY = 'US'
        AND PAF.JOB_ID = JOB.JOB_ID
        AND PAF.PAY_BASIS_ID = PPB.PAY_BASIS_ID
        AND PAF.ASSIGNMENT_ID = PPP.ASSIGNMENT_ID
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
        AND PAF.ORGANIZATION_ID IN (
        SELECT
          ORGANIZATION_ID
        FROM
          HR_ALL_ORGANIZATION_UNITS
        WHERE BUSINESS_GROUP_ID = P_BUSINESS_GROUP_ID )
      GROUP BY
        '03',
        HLA.LOOKUP_CODE;
    CURSOR GET_LINE5_TMR_COUNTS(C_LOOKUP_CODE IN VARCHAR2) IS
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
        HR_LOOKUPS HLA,
        PER_ALL_PEOPLE_F PEO,
        PER_ALL_ASSIGNMENTS_F PAF,
        PER_ASSIGNMENT_STATUS_TYPES AST,
        PER_PEOPLE_EXTRA_INFO PPEA,
        HR_LOOKUPS HL,
        PER_PAY_PROPOSALS PPP,
        PER_PAY_BASES PPB,
        PER_JOBS JOB,
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
        AND PAF.PERSON_ID = PPEA.PERSON_ID
        AND PPEA.INFORMATION_TYPE = 'PQH_ACADEMIC_RANK'
        AND P_REPORT_DATE BETWEEN PAF.EFFECTIVE_START_DATE
        AND PAF.EFFECTIVE_END_DATE
        AND P_REPORT_DATE BETWEEN PEO.EFFECTIVE_START_DATE
        AND PEO.EFFECTIVE_END_DATE
        AND HLA.LOOKUP_TYPE = PPEA.INFORMATION_TYPE
        AND PPEA.PEI_INFORMATION1 = HLA.LOOKUP_CODE
        AND PPEA.PEI_INFORMATION1 not in ( '01' )
        AND P_REPORT_DATE BETWEEN FND_DATE.CANONICAL_TO_DATE(PPEA.PEI_INFORMATION2)
        AND FND_DATE.CANONICAL_TO_DATE(NVL(PPEA.PEI_INFORMATION3
                                    ,'4712/12/31 00:00:00'))
        AND PPEA.PEI_INFORMATION1 IS NOT NULL
        AND not exists (
        SELECT
          PET.PERSON_ID
        FROM
          PER_PEOPLE_EXTRA_INFO PET
        WHERE PET.PERSON_ID = PEO.PERSON_ID
          AND PET.INFORMATION_TYPE in ( 'PQH_TENURE_STATUS' )
          AND PET.PEI_INFORMATION1 in ( '01' , '02' , '04' )
          AND FND_DATE.CANONICAL_TO_DATE(PET.PEI_INFORMATION2) <= P_REPORT_DATE )
        AND PAF.PRIMARY_FLAG = 'Y'
        AND PAF.ASSIGNMENT_TYPE = 'E'
        AND PAF.ASSIGNMENT_STATUS_TYPE_ID = AST.ASSIGNMENT_STATUS_TYPE_ID
        AND AST.PER_SYSTEM_STATUS <> 'TERM_ASSIGN'
        AND PQH_EMPLOYMENT_CATEGORY.IDENTIFY_EMPL_CATEGORY(PAF.EMPLOYMENT_CATEGORY
                                                    ,CP_FR
                                                    ,CP_FT
                                                    ,CP_PR
                                                    ,CP_PT) IN ( 'FR' )
        AND HL.LOOKUP_TYPE = 'US_IPEDS_JOB_CATEGORIES'
        AND JOB.JOB_INFORMATION8 in ( '1' , '2' , '3' )
        AND HL.LOOKUP_CODE = JOB.JOB_INFORMATION8
        AND JOB.JOB_INFORMATION_CATEGORY = 'US'
        AND PAF.JOB_ID = JOB.JOB_ID
        AND PAF.PAY_BASIS_ID = PPB.PAY_BASIS_ID
        AND PAF.ASSIGNMENT_ID = PPP.ASSIGNMENT_ID
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
        AND PAF.ORGANIZATION_ID IN (
        SELECT
          ORGANIZATION_ID
        FROM
          HR_ALL_ORGANIZATION_UNITS
        WHERE BUSINESS_GROUP_ID = P_BUSINESS_GROUP_ID )
        AND HLA.LOOKUP_CODE = C_LOOKUP_CODE;
    CURSOR GET_LINE6_COUNTS IS
      SELECT
        '03' TENINFO,
        '01' ARANK,
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
        HR_LOOKUPS HL,
        PER_PAY_PROPOSALS PPP,
        PER_PAY_BASES PPB,
        PER_JOBS JOB
      WHERE PAF.PERSON_ID = PEO.PERSON_ID
        AND PEO.CURRENT_EMPLOYEE_FLAG = 'Y'
        AND P_REPORT_DATE BETWEEN PAF.EFFECTIVE_START_DATE
        AND PAF.EFFECTIVE_END_DATE
        AND P_REPORT_DATE BETWEEN PEO.EFFECTIVE_START_DATE
        AND PEO.EFFECTIVE_END_DATE
        AND not exists (
        SELECT
          PET.PERSON_ID
        FROM
          PER_PEOPLE_EXTRA_INFO PET
        WHERE PET.PERSON_ID = PEO.PERSON_ID
          AND PET.INFORMATION_TYPE in ( 'PQH_TENURE_STATUS' )
          AND PET.PEI_INFORMATION1 in ( '01' , '02' , '04' )
          AND FND_DATE.CANONICAL_TO_DATE(PET.PEI_INFORMATION2) <= P_REPORT_DATE )
        AND not exists (
        SELECT
          PEA.PERSON_ID
        FROM
          PER_PEOPLE_EXTRA_INFO PEA
        WHERE PEA.PERSON_ID = PEO.PERSON_ID
          AND PEA.INFORMATION_TYPE in ( 'PQH_ACADEMIC_RANK' )
          AND PEA.PEI_INFORMATION1 in ( '02' , '03' , '04' , '05' , '06' )
          AND P_REPORT_DATE between FND_DATE.CANONICAL_TO_DATE(PEA.PEI_INFORMATION2)
          AND FND_DATE.CANONICAL_TO_DATE(NVL(PEA.PEI_INFORMATION3
                                      ,'4712/12/31 00:00:00')) )
        AND PAF.PRIMARY_FLAG = 'Y'
        AND PAF.ASSIGNMENT_TYPE = 'E'
        AND PAF.ASSIGNMENT_STATUS_TYPE_ID = AST.ASSIGNMENT_STATUS_TYPE_ID
        AND AST.PER_SYSTEM_STATUS <> 'TERM_ASSIGN'
        AND PQH_EMPLOYMENT_CATEGORY.IDENTIFY_EMPL_CATEGORY(PAF.EMPLOYMENT_CATEGORY
                                                    ,CP_FR
                                                    ,CP_FT
                                                    ,CP_PR
                                                    ,CP_PT) IN ( 'FR' )
        AND HL.LOOKUP_TYPE = 'US_IPEDS_JOB_CATEGORIES'
        AND JOB.JOB_INFORMATION8 in ( '1' , '2' , '3' )
        AND HL.LOOKUP_CODE = JOB.JOB_INFORMATION8
        AND JOB.JOB_INFORMATION_CATEGORY = 'US'
        AND PAF.JOB_ID = JOB.JOB_ID
        AND PAF.PAY_BASIS_ID = PPB.PAY_BASIS_ID
        AND PAF.ASSIGNMENT_ID = PPP.ASSIGNMENT_ID
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
        AND PAF.ORGANIZATION_ID IN (
        SELECT
          ORGANIZATION_ID
        FROM
          HR_ALL_ORGANIZATION_UNITS
        WHERE BUSINESS_GROUP_ID = P_BUSINESS_GROUP_ID )
      GROUP BY
        '03',
        '01';
    CURSOR GET_LINE6_TMR_COUNTS IS
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
        HR_LOOKUPS HL,
        PER_PAY_PROPOSALS PPP,
        PER_PAY_BASES PPB,
        PER_JOBS JOB,
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
        AND P_REPORT_DATE BETWEEN PAF.EFFECTIVE_START_DATE
        AND PAF.EFFECTIVE_END_DATE
        AND P_REPORT_DATE BETWEEN PEO.EFFECTIVE_START_DATE
        AND PEO.EFFECTIVE_END_DATE
        AND not exists (
        SELECT
          PET.PERSON_ID
        FROM
          PER_PEOPLE_EXTRA_INFO PET
        WHERE PET.PERSON_ID = PEO.PERSON_ID
          AND PET.INFORMATION_TYPE in ( 'PQH_TENURE_STATUS' )
          AND PET.PEI_INFORMATION1 in ( '01' , '02' , '04' )
          AND FND_DATE.CANONICAL_TO_DATE(PET.PEI_INFORMATION2) <= P_REPORT_DATE )
        AND not exists (
        SELECT
          PEA.PERSON_ID
        FROM
          PER_PEOPLE_EXTRA_INFO PEA
        WHERE PEA.PERSON_ID = PEO.PERSON_ID
          AND PEA.INFORMATION_TYPE in ( 'PQH_ACADEMIC_RANK' )
          AND PEA.PEI_INFORMATION1 in ( '02' , '03' , '04' , '05' , '06' )
          AND P_REPORT_DATE between FND_DATE.CANONICAL_TO_DATE(PEA.PEI_INFORMATION2)
          AND FND_DATE.CANONICAL_TO_DATE(NVL(PEA.PEI_INFORMATION3
                                      ,'4712/12/31 00:00:00')) )
        AND PAF.PRIMARY_FLAG = 'Y'
        AND PAF.ASSIGNMENT_TYPE = 'E'
        AND PAF.ASSIGNMENT_STATUS_TYPE_ID = AST.ASSIGNMENT_STATUS_TYPE_ID
        AND AST.PER_SYSTEM_STATUS <> 'TERM_ASSIGN'
        AND PQH_EMPLOYMENT_CATEGORY.IDENTIFY_EMPL_CATEGORY(PAF.EMPLOYMENT_CATEGORY
                                                    ,CP_FR
                                                    ,CP_FT
                                                    ,CP_PR
                                                    ,CP_PT) IN ( 'FR' )
        AND HL.LOOKUP_TYPE = 'US_IPEDS_JOB_CATEGORIES'
        AND JOB.JOB_INFORMATION8 in ( '1' , '2' , '3' )
        AND HL.LOOKUP_CODE = JOB.JOB_INFORMATION8
        AND JOB.JOB_INFORMATION_CATEGORY = 'US'
        AND PAF.JOB_ID = JOB.JOB_ID
        AND PAF.PAY_BASIS_ID = PPB.PAY_BASIS_ID
        AND PAF.ASSIGNMENT_ID = PPP.ASSIGNMENT_ID
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
        AND PAF.ORGANIZATION_ID IN (
        SELECT
          ORGANIZATION_ID
        FROM
          HR_ALL_ORGANIZATION_UNITS
        WHERE BUSINESS_GROUP_ID = P_BUSINESS_GROUP_ID );
  BEGIN
   -- HR_STANDARD.EVENT('BEFORE REPORT');
   CP_REPORT_DATE := to_char(P_REPORT_DATE,'DD-MON-YYYY');
    PQH_EMPLOYMENT_CATEGORY.FETCH_EMPL_CATEGORIES(P_BUSINESS_GROUP_ID
                                                 ,L_FR
                                                 ,L_FT
                                                 ,L_PR
                                                 ,L_PT);
    CP_FR := L_FR;
    CP_FT := L_FT;
    CP_PR := L_PR;
    CP_PT := L_PT;
    FOR i IN GET_LINE1_COUNTS LOOP
      LINE := I.TENINFO;
      SC := I.ARANK;
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
      FOR j IN GET_LINE1_TMRACES_COUNTS(sc) LOOP
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
        ,VALUE17
        ,VALUE18)
      VALUES   (USERENV('sessionid')
        ,'IPED8'
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
      ,'IPED8'
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
    FOR i IN GET_LINE3_COUNTS LOOP
      LINE := I.TENINFO;
      SC := I.ARANK;
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
      FOR j IN GET_LINE3_TMR_COUNTS(sc) LOOP
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
        ,VALUE17
        ,VALUE18)
      VALUES   (USERENV('sessionid')
        ,'IPED8'
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
    OPEN GET_LINE4_COUNTS;
    FETCH GET_LINE4_COUNTS
     INTO LINE,SC,L_NR_MEN,L_NR_WMEN,L_BNH_MEN,L_BNH_WMEN,L_AMAI_MEN,L_AMAI_WMEN,L_AP_MEN,L_AP_WMEN,L_H_MEN,L_H_WMEN,L_WNH_MEN,L_WNH_WMEN,L_UR_MEN,L_UR_WMEN;
    CLOSE GET_LINE4_COUNTS;
    L_TOT_MEN := L_NR_MEN + L_BNH_MEN + L_AMAI_MEN + L_AP_MEN + L_H_MEN + L_WNH_MEN + L_UR_MEN;
    L_TOT_WMEN := L_NR_WMEN + L_BNH_WMEN + L_AMAI_WMEN + L_AP_WMEN + L_H_WMEN + L_WNH_WMEN + L_UR_WMEN;
    OPEN GET_LINE4_TMR_COUNTS;
    FETCH GET_LINE4_TMR_COUNTS
     INTO L_TMR_BNH_MEN,L_TMR_BNH_WMEN,L_TMR_AMAI_MEN,L_TMR_AMAI_WMEN,L_TMR_AP_MEN,L_TMR_AP_WMEN,L_TMR_H_MEN,L_TMR_H_WMEN,L_TMR_WNH_MEN,L_TMR_WNH_WMEN,L_TMR_UR_MEN,L_TMR_UR_WMEN;
    CLOSE GET_LINE4_TMR_COUNTS;
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
      ,VALUE17
      ,VALUE18)
    VALUES   (USERENV('sessionid')
      ,'IPED8'
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
    FOR i IN GET_LINE5_COUNTS LOOP
      LINE := I.TENINFO;
      SC := I.ARANK;
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
      FOR j IN GET_LINE5_TMR_COUNTS(sc) LOOP
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
        ,VALUE17
        ,VALUE18)
      VALUES   (USERENV('sessionid')
        ,'IPED8'
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
    OPEN GET_LINE6_COUNTS;
    FETCH GET_LINE6_COUNTS
     INTO LINE,SC,L_NR_MEN,L_NR_WMEN,L_BNH_MEN,L_BNH_WMEN,L_AMAI_MEN,L_AMAI_WMEN,L_AP_MEN,L_AP_WMEN,L_H_MEN,L_H_WMEN,L_WNH_MEN,L_WNH_WMEN,L_UR_MEN,L_UR_WMEN;
    CLOSE GET_LINE6_COUNTS;
    L_TOT_MEN := L_NR_MEN + L_BNH_MEN + L_AMAI_MEN + L_AP_MEN + L_H_MEN + L_WNH_MEN + L_UR_MEN;
    L_TOT_WMEN := L_NR_WMEN + L_BNH_WMEN + L_AMAI_WMEN + L_AP_WMEN + L_H_WMEN + L_WNH_WMEN + L_UR_WMEN;
    OPEN GET_LINE6_TMR_COUNTS;
    FETCH GET_LINE6_TMR_COUNTS
     INTO L_TMR_BNH_MEN,L_TMR_BNH_WMEN,L_TMR_AMAI_MEN,L_TMR_AMAI_WMEN,L_TMR_AP_MEN,L_TMR_AP_WMEN,L_TMR_H_MEN,L_TMR_H_WMEN,L_TMR_WNH_MEN,L_TMR_WNH_WMEN,L_TMR_UR_MEN,L_TMR_UR_WMEN;
    CLOSE GET_LINE6_TMR_COUNTS;
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
      ,VALUE17
      ,VALUE18)
    VALUES   (USERENV('sessionid')
      ,'IPED8'
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

 return true;
end;

function CF_1Formula return Number is
temp_num number;
begin
    temp_num := line_num;
     line_num := line_num + 1;
     if line_num = 84 then
        line_num := 85;
     elsif line_num = 91 then
        line_num := 92;
     end if;
     return temp_num;
end;

function cf_grouplinenumformula(TenStat in varchar2) return number is
temp_num number;
p_contr_code varchar2(10) := TenStat;
begin
  if p_contr_code = '01' then
    temp_num := 84;
  elsif p_contr_code = '02' then
    temp_num := 91;
   elsif p_contr_code = '03' then
     temp_num := 98;
   end if;
  return temp_num;
end;

function CF_GroupTotTitleFormula(TenStat in varchar2) return Char is
 l_total_title	VARCHAR2(200)	:= '';
 l_contr_code	VARCHAR2(9)	:= TenStat;
begin
  IF 	l_contr_code =  '01' THEN
	l_total_title	:= 'Total Faculty with Tenure (sum of lines 78-83)';
  ELSIF l_contr_code 	= '02' THEN
	l_total_title	:= 'Total Non-Tenured Faculty (Those on tenure track) sum  of lines 85-90';
  ELSIF l_contr_code 	= '03' THEN
	l_total_title	:= 'Total Non-Tenured Faculty (Those not on tenure track) sum of lines 92-97';
  END IF;
return l_total_title;
end;

function AfterReport return boolean is
begin
  --hr_standard.event('AFTER REPORT');
   EXECUTE IMMEDIATE
      'DELETE FROM pay_us_rpt_totals
                    WHERE attribute1 = ''IPED8''';

  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function CP_FR_p return varchar2 is
	Begin
	 return CP_FR;
	 END;
 Function CP_FT_p return varchar2 is
	Begin
	 return CP_FT;
	 END;
 Function CP_PR_p return varchar2 is
	Begin
	 return CP_PR;
	 END;
 Function CP_PT_p return varchar2 is
	Begin
	 return CP_PT;
	 END;
 Function line_num_p return number is
	Begin
	 return line_num;
	 END;
 Function CP_LineNumRepTot_p return number is
	Begin
	 return CP_LineNumRepTot;
	 END;
 Function CP_RepTotTitle_p return varchar2 is
	Begin
	 return CP_RepTotTitle;
	 END;
END PQH_PQIPED8_XMLP_PKG ;

/
