--------------------------------------------------------
--  DDL for Package Body PQH_PQIPED11_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_PQIPED11_XMLP_PKG" AS
/* $Header: PQIPED11B.pls 120.2 2008/04/16 11:17:22 amakrish noship $ */

function cf_1formula(SUMNRMenNonInstr in number, Sum_Instr_NRMen in number) return number is
begin
  return (SUMNRMenNonInstr + Sum_Instr_NRMen);
end;

function cf_2formula(SUMNRWmenNonInstr in number, Sum_Instr_NRWMen in number) return number is
begin
    return (SUMNRWmenNonInstr + Sum_Instr_NRWMen);
end;

function cf_3formula(SUMBnHMenNonInstr in number, Sum_Instr_BnHMen in number) return number is
begin
  return(SUMBnHMenNonInstr + Sum_Instr_BnHMen);
end;

function cf_4formula(SUMBnHWMenNonInstr in number, Sum_Instr_BnHWMen in number) return number is
begin
  return(SUMBnHWMenNonInstr + Sum_Instr_BnHWMen);
end;

function cf_4formula0004(SUMAm_AlMenNonInstr in number, Sum_Instr_Am_AlMen in number) return number is
begin
   return(SUMAm_AlMenNonInstr + Sum_Instr_Am_AlMen);
end;

function cf_sumam_alwmenformula(SUMAm_AlWMenNonInstr in number, Sum_Instr_Am_AlWMen in number) return number is
begin
    return(SUMAm_AlWMenNonInstr + Sum_Instr_Am_AlWMen);
end;

function cf_sumapmenformula(SUMAPMenNonInstr in number, Sum_Instr_APMen in number) return number is
begin
   return(SUMAPMenNonInstr + Sum_Instr_APMen);
end;

function cf_sumapwmenformula(SUMAPWmenNonInstr in number, Sum_Instr_APWmen in number) return number is
begin
  return(SUMAPWmenNonInstr + Sum_Instr_APWmen);
end;

function cf_sumhmenformula(SUMHMenNonInstr in number, Sum_Instr_HMen in number) return number is
begin
   return(SUMHMenNonInstr + Sum_Instr_HMen);
end;

function cf_sumhwmenformula(SUMHWMenNonInstr in number, Sum_Instr_HWMen in number) return number is
begin
    return(SUMHWMenNonInstr + Sum_Instr_HWMen);
end;

function cf_sumwnhmenformula(SUMWnHMenNonInstr in number, Sum_Instr_WnHMen in number) return number is
begin
    return(SUMWnHMenNonInstr + Sum_Instr_WnHMen);
end;

function cf_sumwnhwmenformula(SUMWnHWmenNonInstr in number, Sum_Instr_WnHWMen in number) return number is
begin
    return(SUMWnHWmenNonInstr + Sum_Instr_WnHWMen);
end;

function cf_sumurmenformula(SUMURMenNonInstr in number, Sum_Instr_URMen in number) return number is
begin
    return(SUMURMenNonInstr + Sum_Instr_URMen);
end;

function cf_sumurwmenformula(SUMURWMenNonInstr in number, Sum_Instr_URWMen in number) return number is
begin
    return(SUMURWMenNonInstr + Sum_Instr_URWMen);
end;

function cf_totmenformula(SUMTotMenNonInstr in number, Sum_Instr_TotMen in number) return number is
begin
    return(SUMTotMenNonInstr + Sum_Instr_TotMen);
end;

function cf_11formula(SUMTotWMenNonInstr in number, Sum_Instr_TotWMen in number) return number is
begin
    return(SUMTotWMenNonInstr + Sum_Instr_TotWMen);
end;

function BeforeReport return boolean is
l_query_text	varchar2(2000);

l_fr	varchar2(2000);
l_ft	varchar2(2000);
l_pr	varchar2(2000);
l_pt	varchar2(2000);
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
    L_TOT_MEN NUMBER(38) := 0;
    L_TOT_WMEN NUMBER(38) := 0;
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
        2 LINE,
        HL.LOOKUP_CODE JOBCODE,
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
        PER_ALL_ASSIGNMENTS_F ASS,
        PER_ASSIGNMENT_STATUS_TYPES AST,
        PER_JOBS JOB,
        PER_PAY_PROPOSALS PPP,
        PER_PAY_BASES PPB,
        HR_LOOKUPS HL
      WHERE PEO.PERSON_ID = ASS.PERSON_ID
        AND PEO.CURRENT_EMPLOYEE_FLAG = 'Y'
        AND HL.LOOKUP_CODE = JOB.JOB_INFORMATION8
        AND PQH_EMPLOYMENT_CATEGORY.IDENTIFY_EMPL_CATEGORY(ASS.EMPLOYMENT_CATEGORY
                                                    ,CP_FR
                                                    ,CP_FT
                                                    ,CP_PR
                                                    ,CP_PT) IN ( 'PR' )
        AND HL.LOOKUP_TYPE = 'US_IPEDS_JOB_CATEGORIES'
        AND JOB.JOB_INFORMATION_CATEGORY = 'US'
        AND HL.LOOKUP_CODE not in ( '1' , '2' , '3' )
        AND P_REPORT_DATE BETWEEN PEO.EFFECTIVE_START_DATE
        AND PEO.EFFECTIVE_END_DATE
        AND P_REPORT_DATE BETWEEN ASS.EFFECTIVE_START_DATE
        AND ASS.EFFECTIVE_END_DATE
        AND ASS.PRIMARY_FLAG = 'Y'
        AND ASS.ASSIGNMENT_STATUS_TYPE_ID = AST.ASSIGNMENT_STATUS_TYPE_ID
        AND AST.PER_SYSTEM_STATUS <> 'TERM_ASSIGN'
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
        AND ASS.JOB_ID = JOB.JOB_ID
        AND ASS.ASSIGNMENT_TYPE = 'E'
        AND ASS.ORGANIZATION_ID in (
        SELECT
          ORGANIZATION_ID
        FROM
          HR_ALL_ORGANIZATION_UNITS
        WHERE BUSINESS_GROUP_ID = P_BUSINESS_GROUP_ID )
      GROUP BY
        HL.LOOKUP_CODE;
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
        PER_ALL_PEOPLE_F PEO,
        PER_ALL_ASSIGNMENTS_F ASS,
        PER_ASSIGNMENT_STATUS_TYPES AST,
        PER_JOBS JOB,
        PER_PAY_PROPOSALS PPP,
        PER_PAY_BASES PPB,
        HR_LOOKUPS HL,
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
        AND HL.LOOKUP_CODE = JOB.JOB_INFORMATION8
        AND PQH_EMPLOYMENT_CATEGORY.IDENTIFY_EMPL_CATEGORY(ASS.EMPLOYMENT_CATEGORY
                                                    ,CP_FR
                                                    ,CP_FT
                                                    ,CP_PR
                                                    ,CP_PT) IN ( 'PR' )
        AND HL.LOOKUP_TYPE = 'US_IPEDS_JOB_CATEGORIES'
        AND JOB.JOB_INFORMATION_CATEGORY = 'US'
        AND HL.LOOKUP_CODE not in ( '1' , '2' , '3' )
        AND P_REPORT_DATE BETWEEN PEO.EFFECTIVE_START_DATE
        AND PEO.EFFECTIVE_END_DATE
        AND P_REPORT_DATE BETWEEN ASS.EFFECTIVE_START_DATE
        AND ASS.EFFECTIVE_END_DATE
        AND ASS.PRIMARY_FLAG = 'Y'
        AND ASS.ASSIGNMENT_STATUS_TYPE_ID = AST.ASSIGNMENT_STATUS_TYPE_ID
        AND AST.PER_SYSTEM_STATUS <> 'TERM_ASSIGN'
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
        AND ASS.JOB_ID = JOB.JOB_ID
        AND ASS.ASSIGNMENT_TYPE = 'E'
        AND ASS.ORGANIZATION_ID in (
        SELECT
          ORGANIZATION_ID
        FROM
          HR_ALL_ORGANIZATION_UNITS
        WHERE BUSINESS_GROUP_ID = P_BUSINESS_GROUP_ID )
        AND HL.LOOKUP_CODE = C_LOOKUP_CODE;
    CURSOR GET_LINE2_COUNTS IS
      SELECT
        1 LINE,
        'Faculty(Instruction/Research/Public Service)' DISP_NAME,
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
        PER_JOBS JOB,
        PER_PAY_PROPOSALS PPP,
        PER_PAY_BASES PPB,
        HR_LOOKUPS HL
      WHERE PEO.PERSON_ID = ASS.PERSON_ID
        AND PEO.CURRENT_EMPLOYEE_FLAG = 'Y'
        AND HL.LOOKUP_CODE = JOB.JOB_INFORMATION8
        AND PQH_EMPLOYMENT_CATEGORY.IDENTIFY_EMPL_CATEGORY(ASS.EMPLOYMENT_CATEGORY
                                                    ,CP_FR
                                                    ,CP_FT
                                                    ,CP_PR
                                                    ,CP_PT) IN ( 'PR' )
        AND HL.LOOKUP_TYPE = 'US_IPEDS_JOB_CATEGORIES'
        AND JOB.JOB_INFORMATION_CATEGORY = 'US'
        AND HL.LOOKUP_CODE IN ( '1' , '2' , '3' )
        AND P_REPORT_DATE BETWEEN PEO.EFFECTIVE_START_DATE
        AND PEO.EFFECTIVE_END_DATE
        AND P_REPORT_DATE BETWEEN ASS.EFFECTIVE_START_DATE
        AND ASS.EFFECTIVE_END_DATE
        AND ASS.PRIMARY_FLAG = 'Y'
        AND ASS.ASSIGNMENT_STATUS_TYPE_ID = AST.ASSIGNMENT_STATUS_TYPE_ID
        AND AST.PER_SYSTEM_STATUS <> 'TERM_ASSIGN'
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
        AND ASS.JOB_ID = JOB.JOB_ID
        AND ASS.ASSIGNMENT_TYPE = 'E'
        AND ASS.ORGANIZATION_ID in (
        SELECT
          ORGANIZATION_ID
        FROM
          HR_ALL_ORGANIZATION_UNITS
        WHERE BUSINESS_GROUP_ID = P_BUSINESS_GROUP_ID );
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
        PER_JOBS JOB,
        PER_PAY_PROPOSALS PPP,
        PER_PAY_BASES PPB,
        HR_LOOKUPS HL,
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
        AND HL.LOOKUP_CODE = JOB.JOB_INFORMATION8
        AND PQH_EMPLOYMENT_CATEGORY.IDENTIFY_EMPL_CATEGORY(ASS.EMPLOYMENT_CATEGORY
                                                    ,CP_FR
                                                    ,CP_FT
                                                    ,CP_PR
                                                    ,CP_PT) IN ( 'PR' )
        AND HL.LOOKUP_TYPE = 'US_IPEDS_JOB_CATEGORIES'
        AND JOB.JOB_INFORMATION_CATEGORY = 'US'
        AND HL.LOOKUP_CODE IN ( '1' , '2' , '3' )
        AND P_REPORT_DATE BETWEEN PEO.EFFECTIVE_START_DATE
        AND PEO.EFFECTIVE_END_DATE
        AND P_REPORT_DATE BETWEEN ASS.EFFECTIVE_START_DATE
        AND ASS.EFFECTIVE_END_DATE
        AND ASS.PRIMARY_FLAG = 'Y'
        AND ASS.ASSIGNMENT_STATUS_TYPE_ID = AST.ASSIGNMENT_STATUS_TYPE_ID
        AND AST.PER_SYSTEM_STATUS <> 'TERM_ASSIGN'
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
        AND ASS.JOB_ID = JOB.JOB_ID
        AND ASS.ASSIGNMENT_TYPE = 'E'
        AND ASS.ORGANIZATION_ID in (
        SELECT
          ORGANIZATION_ID
        FROM
          HR_ALL_ORGANIZATION_UNITS
        WHERE BUSINESS_GROUP_ID = P_BUSINESS_GROUP_ID );

begin
   --hr_standard.event('BEFORE REPORT');

   pqh_employment_category.fetch_empl_categories(p_business_group_id,l_fr,l_ft,l_pr,l_pt);

   	cp_fr  := l_fr;
	cp_ft	:= l_ft;
	cp_pr	:= l_pr;
	cp_pt	:= l_pt;
    FOR i IN GET_LINE1_COUNTS LOOP
      LINE := I.LINE;
      SC := I.JOBCODE;
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
        ,'IPED11'
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
      ,'IPED11'
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

      commit;
   return TRUE;
end;

function line_noFormula return Number is
temp_num number;
begin
  temp_num := line_num;
  line_num:= line_num + 1;

  return temp_num;
end;

function AfterReport return boolean is
begin
  --hr_standard.event('AFTER REPORT');
      EXECUTE IMMEDIATE
      'DELETE FROM pay_us_rpt_totals
                    WHERE attribute1 = ''IPED11''';

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
 Function LastLineNo_p return number is
	Begin
	 return LastLineNo;
	 END;
 Function totTitle_p return varchar2 is
	Begin
	 return totTitle;
	 END;
END PQH_PQIPED11_XMLP_PKG ;

/
