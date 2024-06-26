--------------------------------------------------------
--  DDL for Package Body PSP_PSPENCDU_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_PSPENCDU_XMLP_PKG" AS
/* $Header: PSPENCDUB.pls 120.6 2008/01/30 07:43:38 amakrish noship $ */
  FUNCTION CF_TASK_NAMEFORMULA(TASK_ID IN NUMBER
                              ,PROJECT_ID IN NUMBER) RETURN VARCHAR2 IS
    V_TASK_NUMBER VARCHAR2(30);
  BEGIN
    IF TASK_ID IS NOT NULL THEN
      SELECT
        TASK_NUMBER
      INTO V_TASK_NUMBER
      FROM
        PA_TASKS_EXPEND_V
      WHERE PROJECT_ID = CF_TASK_NAMEFORMULA.PROJECT_ID
        AND TASK_ID = CF_TASK_NAMEFORMULA.TASK_ID;
      RETURN (V_TASK_NUMBER);
    END IF;
    RETURN NULL;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN ('no_data_found');
    WHEN TOO_MANY_ROWS THEN
      RETURN ('too many rows');
    WHEN OTHERS THEN
      RETURN ('error');
  END CF_TASK_NAMEFORMULA;

  FUNCTION CF_AWARD_NUMBERFORMULA(AWARD_ID IN NUMBER) RETURN VARCHAR2 IS
    V_AWARD_NUMBER VARCHAR2(30);
  BEGIN
    IF AWARD_ID IS NOT NULL THEN
      SELECT
        DISTINCT
        AWARD_NUMBER
      INTO V_AWARD_NUMBER
      FROM
        GMS_AWARDS_BASIC_V
      WHERE AWARD_ID = CF_AWARD_NUMBERFORMULA.AWARD_ID;
      RETURN (V_AWARD_NUMBER);
    END IF;
    RETURN NULL;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN ('no_data_found');
    WHEN TOO_MANY_ROWS THEN
      RETURN ('too many rows');
    WHEN OTHERS THEN
      RETURN ('error');
  END CF_AWARD_NUMBERFORMULA;

  FUNCTION CF_PROJECT_NUMBERFORMULA(PROJECT_ID IN NUMBER) RETURN VARCHAR2 IS
    V_PROJECT_NUMBER VARCHAR2(30);
  BEGIN
    IF PROJECT_ID IS NOT NULL THEN
      SELECT
        PROJECT_NUMBER
      INTO V_PROJECT_NUMBER
      FROM
        GMS_PROJECTS_EXPEND_V
      WHERE PROJECT_ID = CF_PROJECT_NUMBERFORMULA.PROJECT_ID;
      RETURN (V_PROJECT_NUMBER);
    END IF;
    RETURN NULL;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN ('no_data_found');
    WHEN TOO_MANY_ROWS THEN
      RETURN ('too many rows');
    WHEN OTHERS THEN
      RETURN ('error');
  END CF_PROJECT_NUMBERFORMULA;

  FUNCTION CF_ORG_NAMEFORMULA(EXPENDITURE_ORGANIZATION_ID IN NUMBER) RETURN VARCHAR2 IS
    V_ORG_NAME HR_ALL_ORGANIZATION_UNITS_TL.NAME%TYPE;
  BEGIN
    IF EXPENDITURE_ORGANIZATION_ID IS NOT NULL THEN
      SELECT
        NAME
      INTO V_ORG_NAME
      FROM
        PA_ORGANIZATIONS_EXPEND_V
      WHERE ORGANIZATION_ID = EXPENDITURE_ORGANIZATION_ID
        AND ACTIVE_FLAG = 'Y';
      RETURN (V_ORG_NAME);
    END IF;
    RETURN NULL;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN ('no_data_found');
    WHEN TOO_MANY_ROWS THEN
      RETURN ('too many rows');
    WHEN OTHERS THEN
      RETURN ('error');
  END CF_ORG_NAMEFORMULA;

  FUNCTION CF_GL_DESCFORMULA(GL_CODE_COMBINATION_ID IN NUMBER) RETURN VARCHAR2 IS
    V_GL_CODE VARCHAR2(255);
    V_SOB NUMBER := PSP_GENERAL.GET_SPECIFIC_PROFILE('GL_SET_OF_BKS_ID');
  BEGIN
    IF GL_CODE_COMBINATION_ID IS NOT NULL THEN
      V_GL_CODE := PSP_GENERAL.GET_GL_DESCRIPTION(V_SOB
                                                 ,GL_CODE_COMBINATION_ID);
      RETURN (V_GL_CODE);
    END IF;
    RETURN NULL;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN ('no_data_found');
    WHEN TOO_MANY_ROWS THEN
      RETURN ('too many rows');
    WHEN OTHERS THEN
      RETURN ('error');
  END CF_GL_DESCFORMULA;

  FUNCTION CF_EMPLOYEE_NUMBERFORMULA(PERSON_ID IN NUMBER) RETURN VARCHAR2 IS
    V_EMPLOYEE_NUMBER VARCHAR2(30);
  BEGIN
    SELECT
      PAF1.EMPLOYEE_NUMBER
    INTO V_EMPLOYEE_NUMBER
    FROM
      PER_ALL_PEOPLE_F PAF1
    WHERE PERSON_ID = CF_EMPLOYEE_NUMBERFORMULA.PERSON_ID
      AND EFFECTIVE_START_DATE = (
      SELECT
        MIN(EFFECTIVE_START_DATE)
      FROM
        PER_ALL_PEOPLE_F PAF2
      WHERE PAF1.PERSON_ID = PAF2.PERSON_ID
        AND PAF2.CURRENT_EMPLOYEE_FLAG = 'Y' );
    RETURN (V_EMPLOYEE_NUMBER);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN ('no_data_found');
    WHEN TOO_MANY_ROWS THEN
      RETURN ('too many rows');
    WHEN OTHERS THEN
      RETURN ('error');
  END CF_EMPLOYEE_NUMBERFORMULA;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    --HR_STANDARD.EVENT('BEFORE REPORT');
    LP_BEGIN_DATE:=to_char(P_BEGIN_DATE,'DD-MON-YYYY');
    LP_END_DATE:=to_char(P_END_DATE,'DD-MON-YYYY');
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION P_ORGANIZATIONSVALIDTRIGGER RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END P_ORGANIZATIONSVALIDTRIGGER;

  FUNCTION CF_ORG_TOTAL_DSPFORMULA(CS_ORG_TOTAL IN NUMBER
                                  ,CF_CURRENCY_FORMAT IN VARCHAR2) RETURN CHAR IS
  BEGIN
    /*SRW.REFERENCE(CS_ORG_TOTAL)*/NULL;
    /*SRW.REFERENCE(CF_CURRENCY_FORMAT)*/NULL;
    RETURN (TO_CHAR(CS_ORG_TOTAL
                  ,CF_CURRENCY_FORMAT));
  END CF_ORG_TOTAL_DSPFORMULA;

  FUNCTION CF_EMP_TOTAL_DSPFORMULA(CS_EMP_TOTAL IN NUMBER
                                  ,CF_CURRENCY_FORMAT IN VARCHAR2) RETURN CHAR IS
  BEGIN
    /*SRW.REFERENCE(CS_EMP_TOTAL)*/NULL;
    /*SRW.REFERENCE(CF_CURRENCY_FORMAT)*/NULL;
    RETURN (TO_CHAR(CS_EMP_TOTAL
                  ,CF_CURRENCY_FORMAT));
  END CF_EMP_TOTAL_DSPFORMULA;

  FUNCTION CF_ENC_AMOUNT_DSPFORMULA(CS_ENC_AMOUNT IN NUMBER
                                   ,CF_CURRENCY_FORMAT IN VARCHAR2) RETURN CHAR IS
  BEGIN
    /*SRW.REFERENCE(CS_ENC_AMOUNT)*/NULL;
    /*SRW.REFERENCE(CF_CURRENCY_FORMAT)*/NULL;
    RETURN (TO_CHAR(CS_ENC_AMOUNT
                  ,CF_CURRENCY_FORMAT));
  END CF_ENC_AMOUNT_DSPFORMULA;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    --HR_STANDARD.EVENT('AFTER REPORT');
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION CF_SUSPENSE_ORG_ACCOUNTFORMULA(GL_CODE_COMBINATION_ID IN NUMBER
                                         ,CF_PROJECT_NUMBER IN VARCHAR2
                                         ,CF_AWARD_NUMBER IN VARCHAR2
                                         ,CF_TASK_NUMBER IN VARCHAR2
                                         ,CF_ORG_NAME IN VARCHAR2
                                         ,EXPENDITURE_TYPE IN VARCHAR2) RETURN CHAR IS
    L_SUSPENSE_ORG_ACCOUNT VARCHAR2(2000);
    V_SOB NUMBER := PSP_GENERAL.GET_SPECIFIC_PROFILE('GL_SET_OF_BKS_ID');
    V_RETCODE NUMBER;
    L_CHART_OF_ACCTS VARCHAR2(20);
  BEGIN
    IF GL_CODE_COMBINATION_ID IS NOT NULL THEN
      V_RETCODE := PSP_GENERAL.FIND_CHART_OF_ACCTS(V_SOB
                                                  ,L_CHART_OF_ACCTS);
      L_SUSPENSE_ORG_ACCOUNT := FND_FLEX_EXT.GET_SEGS(APPLICATION_SHORT_NAME => 'SQLGL'
                                                     ,KEY_FLEX_CODE => 'GL#'
                                                     ,STRUCTURE_NUMBER => TO_NUMBER(L_CHART_OF_ACCTS)
                                                     ,COMBINATION_ID => GL_CODE_COMBINATION_ID);
    ELSE
      L_SUSPENSE_ORG_ACCOUNT := CF_PROJECT_NUMBER || ' ' || CF_AWARD_NUMBER || ' ' || CF_TASK_NUMBER || ' ' || CF_ORG_NAME || ' ' || EXPENDITURE_TYPE;
    END IF;
    RETURN (L_SUSPENSE_ORG_ACCOUNT);
  END CF_SUSPENSE_ORG_ACCOUNTFORMULA;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
    CURSOR C1(P_LOOKUP_CODE IN VARCHAR2,L_TEMPLATE_ID IN NUMBER) IS
      SELECT
        COUNT(1)
      FROM
        PSP_REPORT_TEMPLATE_DETAILS
      WHERE TEMPLATE_ID = L_TEMPLATE_ID
        AND CRITERIA_LOOKUP_TYPE = 'PSP_SELECTION_CRITERIA'
        AND CRITERIA_LOOKUP_CODE = P_LOOKUP_CODE;
    L_NUM NUMBER;
    L_NUM1 NUMBER;
    L_NUM2 NUMBER;
  BEGIN
    IF P_ORG_TEMPLATE_ID IS NULL THEN
      P_ORGANIZATIONS := ' and 1 = 1 ';
    ELSE
      OPEN C1('ORG',P_ORG_TEMPLATE_ID);
      FETCH C1
       INTO L_NUM;
      CLOSE C1;
      IF L_NUM <> 0 THEN
        P_ORGANIZATIONS := ' and b.organization_id  IN (select criteria_value1 from psp_report_template_details
                                  where template_id = ' || P_ORG_TEMPLATE_ID || '
                                  and   criteria_lookup_type = ''PSP_SELECTION_CRITERIA''
                                  and   criteria_lookup_code = ''ORG'' ' || ' ) ';
      ELSE
        P_ORGANIZATIONS := ' and 1 = 1 ';
      END IF;
    END IF;
    IF P_PAY_TEMPLATE_ID IS NULL THEN
      P_PAYROLL_ID := ' and 1 = 1 ';
    ELSE
      OPEN C1('PAY',P_PAY_TEMPLATE_ID);
      FETCH C1
       INTO L_NUM2;
      CLOSE C1;
      IF L_NUM2 <> 0 THEN
        P_PAYROLL_ID := ' and a.payroll_id IN (select criteria_value1 from psp_report_template_details
                                where template_id = ' || P_PAY_TEMPLATE_ID || '
                                and   criteria_lookup_type = ''PSP_SELECTION_CRITERIA''
                                and   criteria_lookup_code = ''PAY'' ' || ' ) ';
      ELSE
        P_PAYROLL_ID := ' and 1 = 1 ';
      END IF;
    END IF;
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION CF_CHARGING_INSTRUCTIONSFORMUL RETURN VARCHAR2 IS
    L_SUSPENSE_ORG_ACCOUNT VARCHAR2(2000);
  BEGIN
    RETURN (NULL);
  END CF_CHARGING_INSTRUCTIONSFORMUL;

  FUNCTION CF_PAY_TOTALFORMULA(CS_PAY_TOTAL IN NUMBER
                              ,CF_CURRENCY_FORMAT IN VARCHAR2) RETURN CHAR IS
  BEGIN
    /*SRW.REFERENCE(CS_PAY_TOTAL)*/NULL;
    /*SRW.REFERENCE(CF_CURRENCY_FORMAT)*/NULL;
    RETURN (TO_CHAR(CS_PAY_TOTAL
                  ,CF_CURRENCY_FORMAT));
  END CF_PAY_TOTALFORMULA;

  FUNCTION CF_1FORMULA(CURRENCY_CODE IN VARCHAR2) RETURN CHAR IS
  BEGIN
    /*SRW.REFERENCE(CURRENCY_CODE)*/NULL;
    RETURN (FND_CURRENCY.GET_FORMAT_MASK(CURRENCY_CODE
                                       ,30));
  END CF_1FORMULA;

  FUNCTION CF_CURRENCY_TOTAL_DSPFORMULA(CURRENCY_CODE IN VARCHAR2
                                       ,CF_CURRENCY_FORMAT IN VARCHAR2
                                       ,CS_CURRENCY_TOTAL IN NUMBER) RETURN CHAR IS
  BEGIN
    /*SRW.REFERENCE(CURRENCY_CODE)*/NULL;
    /*SRW.REFERENCE(CF_CURRENCY_FORMAT)*/NULL;
    RETURN (TO_CHAR(CS_CURRENCY_TOTAL
                  ,CF_CURRENCY_FORMAT));
  END CF_CURRENCY_TOTAL_DSPFORMULA;

END PSP_PSPENCDU_XMLP_PKG;

/
