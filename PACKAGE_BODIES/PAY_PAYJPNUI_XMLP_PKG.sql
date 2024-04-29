--------------------------------------------------------
--  DDL for Package Body PAY_PAYJPNUI_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PAYJPNUI_XMLP_PKG" AS
/* $Header: PAYJPNUIB.pls 120.0 2007/12/13 12:19:00 amakrish noship $ */
  FUNCTION CF_DETAILS_DUMMYFORMULA(ASSIGNMENT_ID IN NUMBER
                                  ,EFFECTIVE_DATE IN DATE
                                  ,TARGET_DATE IN DATE
                                  ,DATE_OF_BIRTH IN DATE) RETURN NUMBER IS
    L_DATE_ERA_CODE NUMBER;
    L_DATE_YEAR NUMBER;
    L_DATE_MONTH NUMBER;
    L_DATE_DAY NUMBER;
    L_DUMMY NUMBER;
    L_UI_NUMBER VARCHAR2(11);
  BEGIN
    L_UI_NUMBER := PAY_JP_REPORT_PKG.SUBSTRB2(PAY_JP_BALANCE_PKG.GET_ENTRY_VALUE_CHAR(G_UI_NUMBER_IV_ID
                                                                                     ,ASSIGNMENT_ID
                                                                                     ,EFFECTIVE_DATE)
                                             ,1
                                             ,11);
    IF L_UI_NUMBER IS NOT NULL THEN
      CP_UI_NUMBER := PAY_JP_REPORT_PKG.SUBSTRB2(L_UI_NUMBER
                                                ,1
                                                ,4) || '-' || PAY_JP_REPORT_PKG.SUBSTRB2(L_UI_NUMBER
                                                ,5
                                                ,6) || '-' || PAY_JP_REPORT_PKG.SUBSTRB2(L_UI_NUMBER
                                                ,11
                                                ,1);
    ELSE
      CP_UI_NUMBER := L_UI_NUMBER;
    END IF;
    PAY_JP_REPORT_PKG.TO_ERA(TARGET_DATE
                            ,L_DATE_ERA_CODE
                            ,L_DATE_YEAR
                            ,L_DATE_MONTH
                            ,L_DATE_DAY);
    L_DATE_YEAR := L_DATE_YEAR - TRUNC(L_DATE_YEAR
                        ,-2);
    CP_TARGET_DATE := LPAD(TO_CHAR(L_DATE_YEAR)
                          ,2
                          ,'0') || LPAD(TO_CHAR(L_DATE_MONTH)
                          ,2
                          ,'0') || LPAD(TO_CHAR(L_DATE_DAY)
                          ,2
                          ,'0');
    PAY_JP_REPORT_PKG.TO_ERA(DATE_OF_BIRTH
                            ,L_DATE_ERA_CODE
                            ,L_DATE_YEAR
                            ,L_DATE_MONTH
                            ,L_DATE_DAY);
    L_DATE_YEAR := L_DATE_YEAR - TRUNC(L_DATE_YEAR
                        ,-2);
    CP_DATE_OF_BIRTH := TO_CHAR(CEIL(L_DATE_ERA_CODE / 2)) || '-' || LPAD(TO_CHAR(L_DATE_YEAR)
                            ,2
                            ,'0') || LPAD(TO_CHAR(L_DATE_MONTH)
                            ,2
                            ,'0') || LPAD(TO_CHAR(L_DATE_DAY)
                            ,2
                            ,'0');
    IF P_REPORT_TYPE = '3' THEN
      PAY_JP_REPORT_PKG.TO_ERA(PAY_JP_BALANCE_PKG.GET_ENTRY_VALUE_DATE(G_QUALIFIED_DATE_IV_ID
                                                                      ,ASSIGNMENT_ID
                                                                      ,TARGET_DATE)
                              ,L_DATE_ERA_CODE
                              ,L_DATE_YEAR
                              ,L_DATE_MONTH
                              ,L_DATE_DAY);
      L_DATE_YEAR := L_DATE_YEAR - TRUNC(L_DATE_YEAR
                          ,-2);
      CP_QUALIFIED_DATE := LPAD(TO_CHAR(L_DATE_YEAR)
                               ,2
                               ,'0') || LPAD(TO_CHAR(L_DATE_MONTH)
                               ,2
                               ,'0') || LPAD(TO_CHAR(L_DATE_DAY)
                               ,2
                               ,'0');
    ELSE
      CP_QUALIFIED_DATE := NULL;
    END IF;
    RETURN ('');
  END CF_DETAILS_DUMMYFORMULA;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
    L_WHERE_CLAUSE_FOR_ASSID VARCHAR2(150);
  BEGIN
    L_WHERE_CLAUSE_FOR_ASSID := PAY_JP_REPORT_PKG.GET_CONCATENATED_NUMBERS(TO_NUMBER(P_ASSIGNMENT_ID1)
                                                                          ,TO_NUMBER(P_ASSIGNMENT_ID2)
                                                                          ,TO_NUMBER(P_ASSIGNMENT_ID3)
                                                                          ,TO_NUMBER(P_ASSIGNMENT_ID4)
                                                                          ,TO_NUMBER(P_ASSIGNMENT_ID5)
                                                                          ,TO_NUMBER(P_ASSIGNMENT_ID6)
                                                                          ,TO_NUMBER(P_ASSIGNMENT_ID7)
                                                                          ,TO_NUMBER(P_ASSIGNMENT_ID8)
                                                                          ,TO_NUMBER(P_ASSIGNMENT_ID9)
                                                                          ,TO_NUMBER(P_ASSIGNMENT_ID10));
    IF L_WHERE_CLAUSE_FOR_ASSID IS NOT NULL THEN
      P_WHERE_CLAUSE_FOR_ASSID := 'and uiv.assignment_id in (' || L_WHERE_CLAUSE_FOR_ASSID || ')';
      else
P_WHERE_CLAUSE_FOR_ASSID := ' ';
    END IF;
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
    L_DATE_ERA_CODE NUMBER;
    L_DATE_YEAR NUMBER;
    L_DATE_MONTH NUMBER;
    L_DATE_DAY NUMBER;
    L_LEGISLATION_CODE PER_BUSINESS_GROUPS.LEGISLATION_CODE%TYPE;
  BEGIN
   -- HR_STANDARD.EVENT('BEFORE REPORT');
    PAY_JP_REPORT_PKG.TO_ERA(SYSDATE
                            ,L_DATE_ERA_CODE
                            ,L_DATE_YEAR
                            ,L_DATE_MONTH
                            ,L_DATE_DAY);
    L_DATE_YEAR := L_DATE_YEAR - TRUNC(L_DATE_YEAR
                        ,-2);
    CP_OUTPUT_DATE_GLOBAL := PAY_JP_REPORT_PKG.SUBSTRB2(NVL(HR_GENERAL.DECODE_LOOKUP('JP_ERA'
                                                                                    ,TO_CHAR(L_DATE_ERA_CODE))
                                                           ,'    ') || LPAD(NVL(TO_CHAR(L_DATE_YEAR)
                                                                ,' ')
                                                            ,2
                                                            ,' ') || FND_MESSAGE.GET_STRING('PAY'
                                                                              ,'PAY_JP_TRANS_YY') || LPAD(NVL(TO_CHAR(L_DATE_MONTH)
                                                                ,' ')
                                                            ,2
                                                            ,' ') || FND_MESSAGE.GET_STRING('PAY'
                                                                              ,'PAY_JP_TRANS_MM') || LPAD(NVL(TO_CHAR(L_DATE_DAY)
                                                                ,' ')
                                                            ,2
                                                            ,' ') || FND_MESSAGE.GET_STRING('PAY'
                                                                              ,'PAY_JP_TRANS_DD')
                                                       ,1
                                                       ,21);
    IF P_REPORT_TYPE = '1' THEN
      CP_REPORT_TITLE := 'Employment Insurance Insured Notification of Qualification Checklist';
      CP_TARGET_DATE_TITLE := 'Qualified Date';
      CP_NOTE_TITLE := 'Remark';
    ELSIF P_REPORT_TYPE = '2' THEN
      CP_REPORT_TITLE := 'Employment Insurance Insured Notification of Disqualification Checklist';
      CP_TARGET_DATE_TITLE := 'Disqualified Date';
      CP_NOTE_TITLE := 'Insured Address or Residence';
    ELSIF P_REPORT_TYPE = '3' THEN
      CP_REPORT_TITLE := 'Employment Insurance Insured Notification of Relocation Checklist';
      CP_TARGET_DATE_TITLE := 'Relocation Date';
      CP_NOTE_TITLE := 'Location Number Before Relocate';
    ELSIF P_REPORT_TYPE = '5' THEN
      CP_REPORT_TITLE := 'Employment Insurance Insured Notification of Full Name Change Checklist';
      CP_TARGET_DATE_TITLE := 'Full Name Change Date';
      CP_NOTE_TITLE := 'Insured Old Full Name';
    ELSIF P_REPORT_TYPE = '6' THEN
      CP_REPORT_TITLE := 'Employment Insurance Insured Notification of Class Change Checklist';
      CP_TARGET_DATE_TITLE := 'Class Change Date';
      CP_NOTE_TITLE := 'Remark';
    END IF;
    L_LEGISLATION_CODE := PAY_JP_BALANCE_PKG.GET_LEGISLATION_CODE(P_BUSINESS_GROUP_ID);
    G_UI_NUMBER_IV_ID := PAY_JP_BALANCE_PKG.GET_INPUT_VALUE_ID('COM_LI_INFO'
                                                              ,'EI_NUM'
                                                              ,P_BUSINESS_GROUP_ID
                                                              ,L_LEGISLATION_CODE);
    G_QUALIFIED_DATE_IV_ID := PAY_JP_BALANCE_PKG.GET_INPUT_VALUE_ID('COM_EI_QUALIFY_INFO'
                                                                   ,'QUALIFY_DATE'
                                                                   ,P_BUSINESS_GROUP_ID
                                                                   ,L_LEGISLATION_CODE);
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
   -- HR_STANDARD.EVENT('AFTER REPORT');
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION CP_UI_NUMBER_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_UI_NUMBER;
  END CP_UI_NUMBER_P;

  FUNCTION CP_TARGET_DATE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_TARGET_DATE;
  END CP_TARGET_DATE_P;

  FUNCTION CP_DATE_OF_BIRTH_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_DATE_OF_BIRTH;
  END CP_DATE_OF_BIRTH_P;

  FUNCTION CP_QUALIFIED_DATE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_QUALIFIED_DATE;
  END CP_QUALIFIED_DATE_P;

  FUNCTION CP_OUTPUT_DATE_GLOBAL_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_OUTPUT_DATE_GLOBAL;
  END CP_OUTPUT_DATE_GLOBAL_P;

  FUNCTION CP_REPORT_TITLE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_REPORT_TITLE;
  END CP_REPORT_TITLE_P;

  FUNCTION CP_TARGET_DATE_TITLE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_TARGET_DATE_TITLE;
  END CP_TARGET_DATE_TITLE_P;

  FUNCTION CP_NOTE_TITLE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_NOTE_TITLE;
  END CP_NOTE_TITLE_P;

END PAY_PAYJPNUI_XMLP_PKG;

/
