--------------------------------------------------------
--  DDL for Package PSP_PSPENCSC_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_PSPENCSC_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PSPENCSCS.pls 120.3 2007/10/29 07:22:43 amakrish noship $ */
  P_PAYROLL_ID VARCHAR2(400) := 'and 1 =1 ';

  P_BUSINESS_GROUP NUMBER;

  P_CONC_REQUEST_ID NUMBER;

  P_ORGANIZATIONS VARCHAR2(400) := 'and  1   = 1 ';

  P_BEGIN_DATE DATE;

  CP_BEGIN_DATE VARCHAR2(25);

  CP_END_DATE VARCHAR2(25);

  P_END_DATE DATE;

  P_PAY_TEMPLATE_ID NUMBER;

  P_ORG_TEMPLATE_ID NUMBER;

  FUNCTION SUSP_ORGANIZATIONFORMULA(SUSPENSE_ORG_ACCOUNT_ID IN NUMBER) RETURN VARCHAR2;

  FUNCTION CF_TASK_NAMEFORMULA(TASK_ID1 IN NUMBER
                              ,PROJECT_ID1 IN NUMBER) RETURN VARCHAR2;

  FUNCTION CF_AWARD_NUMBERFORMULA(AWARD_ID1 IN NUMBER) RETURN VARCHAR2;

  FUNCTION CF_PROJECT_NUMBERFORMULA(PROJECT_ID1 IN NUMBER) RETURN VARCHAR2;

  FUNCTION CF_ORG_NAMEFORMULA(EXPENDITURE_ORGANIZATION_ID IN NUMBER) RETURN VARCHAR2;

  FUNCTION CF_GL_DESCFORMULA(GL_CODE_COMBINATION_ID IN NUMBER) RETURN VARCHAR2;

  FUNCTION CF_EMPLOYEE_NUMBERFORMULA(PERSON_ID1 IN NUMBER) RETURN VARCHAR2;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION P_ORGANIZATIONSVALIDTRIGGER RETURN BOOLEAN;

  FUNCTION CF_ORG_TOTAL_DSPFORMULA(CS_ORG_TOTAL IN NUMBER
                                  ,CF_CURRENCY_FORMAT IN VARCHAR2) RETURN CHAR;

  FUNCTION CF_EMP_TOTAL_DSPFORMULA(CS_EMP_TOTAL IN NUMBER
                                  ,CF_CURRENCY_FORMAT IN VARCHAR2) RETURN CHAR;

  FUNCTION CF_ENC_AMOUNT_DSPFORMULA(CS_ENC_AMOUNT IN NUMBER
                                   ,CF_CURRENCY_FORMAT IN VARCHAR2) RETURN CHAR;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION CF_SUSPENSE_ORG_ACCOUNTFORMULA(GL_CODE_COMBINATION_ID IN NUMBER
                                         ,CF_PROJECT_NUMBER IN VARCHAR2
                                         ,CF_AWARD_NUMBER IN VARCHAR2
                                         ,CF_TASK_NUMBER IN VARCHAR2
                                         ,CF_ORG_NAME IN VARCHAR2
                                         ,EXPENDITURE_TYPE IN VARCHAR2) RETURN CHAR;

  FUNCTION AFTERPFORM RETURN BOOLEAN;

  FUNCTION CF_CHARGING_INSTRUCTIONSFORMUL RETURN VARCHAR2;

  FUNCTION CF_PAY_TOTALFORMULA(CS_PAY_TOTAL IN NUMBER
                              ,CF_CURRENCY_FORMAT IN VARCHAR2) RETURN CHAR;

  FUNCTION CF_CURRENCY_FORMATFORMULA(CURRENCY_CODE IN VARCHAR2) RETURN CHAR;

  FUNCTION CF_CURRENCY_TOTAL_DSPFORMULA(CS_CURRENCY_TOTAL IN NUMBER
                                       ,CF_CURRENCY_FORMAT IN VARCHAR2) RETURN CHAR;

END PSP_PSPENCSC_XMLP_PKG;

/