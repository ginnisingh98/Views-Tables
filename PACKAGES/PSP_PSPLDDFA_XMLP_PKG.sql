--------------------------------------------------------
--  DDL for Package PSP_PSPLDDFA_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_PSPLDDFA_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PSPLDDFAS.pls 120.6 2007/10/29 07:23:53 amakrish noship $ */
  P_TIME_PERIOD_START DATE;

  P_TIME_PERIOD_END DATE;

  P_ORGANIZATION_ID VARCHAR2(2000);

  P_CONC_REQUEST_ID NUMBER;

  P_BUSINESS_GROUP_ID NUMBER;

  P_SET_OF_BOOKS_ID NUMBER;

  P_ORG_TEMPLATE_ID NUMBER;

  FUNCTION BEFOREPFORM(ORIENTATION IN VARCHAR2) RETURN BOOLEAN;

  FUNCTION P_TIME_PERIOD_STARTVALIDTRIGGE RETURN BOOLEAN;

  FUNCTION P_TIME_PERIOD_ENDVALIDTRIGGER RETURN BOOLEAN;

  FUNCTION CF_INSTITUTION_NAMEFORMULA RETURN VARCHAR2;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION AFTERPFORM RETURN BOOLEAN;

  FUNCTION CF_CURRENCY_FORMATFORMULA(CURRENCY_CODE IN VARCHAR2) RETURN CHAR;

  FUNCTION CF_DISTRIBUTION_AMOUNT_DSPFORM(DISTRIBUTION_AMOUNT IN NUMBER
                                         ,CF_CURRENCY_FORMAT IN VARCHAR2) RETURN CHAR;

  FUNCTION CF_SUM_CURRENCYFORMULA(CURRENCY_CODE IN VARCHAR2) RETURN CHAR;

  FUNCTION CF_SUM_DISTRIBUTION_AMOUNTFORM(CF_CURRENCY_FORMAT IN VARCHAR2
                                         ,CS_DISTRIBUTION_AMOUNT IN NUMBER) RETURN CHAR;

  FUNCTION CF_ORGANIZATION_NAMEFORMULA(ORGANIZATION_ID IN NUMBER) RETURN VARCHAR2;

  FUNCTION CF_CHARGING_INSTRUCTIONSFORMUL(GL_CODE_COMBINATION_ID IN NUMBER
                                         ,PROJECT_ID IN NUMBER
                                         ,TASK_ID IN NUMBER
                                         ,AWARD_ID IN NUMBER
                                         ,EXPENDITURE_ORGANIZATION_ID IN NUMBER
                                         ,EXPENDITURE_TYPE IN VARCHAR2) RETURN CHAR;

  FUNCTION CF_PERSON_NAMEFORMULA(PERSON_ID IN NUMBER) RETURN VARCHAR2;

  FUNCTION CF_ASSIGNMENT_NUMBERFORMULA(ASSIGNMENT_ID IN NUMBER) RETURN VARCHAR2;

  FUNCTION CF_ELEMENT_NAMEFORMULA(ELEMENT_TYPE_ID IN NUMBER) RETURN VARCHAR2;

  FUNCTION CF_PERIOD_NAMEFORMULA(TIME_PERIOD_ID IN NUMBER) RETURN VARCHAR2;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION CF_DATE_FORMATFORMULA RETURN CHAR;

  FUNCTION CF_START_DATE_DISPFORMULA(CF_DATE_FORMAT IN VARCHAR2) RETURN CHAR;

  FUNCTION CF_END_DATE_DISPFORMULA(CF_DATE_FORMAT IN VARCHAR2) RETURN CHAR;

  FUNCTION CF_RUN_DATE_DISPFORMULA(CF_DATE_FORMAT IN VARCHAR2) RETURN CHAR;

  PROCEDURE CRT(ERRBUF OUT NOCOPY VARCHAR2
               ,RETCODE OUT NOCOPY NUMBER
               ,A_TEMPLATE_ID IN NUMBER);

  PROCEDURE INIT_WORKFLOW(A_TEMPLATE_ID IN NUMBER);

  PROCEDURE UPD_INCLUDE_FLAG(A_TEMPLATE_ID IN NUMBER);

  FUNCTION GET_GL_DESCRIPTION(A_CODE_COMBINATION_ID IN NUMBER) RETURN VARCHAR2;

  PROCEDURE PUT(NAME IN VARCHAR2
               ,VAL IN VARCHAR2);

  FUNCTION DEFINED(NAME IN VARCHAR2) RETURN BOOLEAN;

  PROCEDURE GET(NAME IN VARCHAR2
               ,VAL OUT NOCOPY VARCHAR2);

  FUNCTION VALUE(NAME IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION SAVE_USER(X_NAME IN VARCHAR2
                    ,X_VALUE IN VARCHAR2) RETURN BOOLEAN;

  FUNCTION SAVE(X_NAME IN VARCHAR2
               ,X_VALUE IN VARCHAR2
               ,X_LEVEL_NAME IN VARCHAR2
               ,X_LEVEL_VALUE IN VARCHAR2
               ,X_LEVEL_VALUE_APP_ID IN VARCHAR2) RETURN BOOLEAN;

  PROCEDURE GET_SPECIFIC(NAME_Z IN VARCHAR2
                        ,USER_ID_Z IN NUMBER
                        ,RESPONSIBILITY_ID_Z IN NUMBER
                        ,APPLICATION_ID_Z IN NUMBER
                        ,VAL_Z OUT NOCOPY VARCHAR2
                        ,DEFINED_Z OUT NOCOPY BOOLEAN);

  FUNCTION VALUE_SPECIFIC(NAME IN VARCHAR2
                         ,USER_ID IN NUMBER
                         ,RESPONSIBILITY_ID IN NUMBER
                         ,APPLICATION_ID IN NUMBER) RETURN VARCHAR2;

  PROCEDURE INITIALIZE(USER_ID_Z IN NUMBER
                      ,RESPONSIBILITY_ID_Z IN NUMBER
                      ,APPLICATION_ID_Z IN NUMBER
                      ,SITE_ID_Z IN NUMBER);

  PROCEDURE PUTMULTIPLE(NAMES IN VARCHAR2
                       ,VALS IN VARCHAR2
                       ,NUM IN NUMBER);

END PSP_PSPLDDFA_XMLP_PKG;

/