--------------------------------------------------------
--  DDL for Package PSP_PSPLSODL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_PSPLSODL_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PSPLSODLS.pls 120.3 2007/10/29 07:25:53 amakrish noship $ */
  P_BATCH_ID NUMBER;
  P_BATCH_ID1 NUMBER;

  P_CONC_REQUEST_ID NUMBER;

  P_BUSINESS_GROUP_ID NUMBER;

  P_SET_OF_BOOKS_ID NUMBER;

  P_ORG_TEMPLATE_ID NUMBER;

  P_BEGIN_DATE DATE;

  P_END_DATE DATE;

  FUNCTION CF_ORGANIZATION_NAMEFORMULA(ORGANIZATION_ID_V IN NUMBER) RETURN VARCHAR2;

  FUNCTION CF_GL_ACCOUNTFORMULA(GL_CODE_COMBINATION_ID IN NUMBER) RETURN VARCHAR2;

  FUNCTION CF_PROJECT_NAMEFORMULA(PROJECT_ID_V IN NUMBER) RETURN VARCHAR2;

  FUNCTION CF_EXP_ORG_NAMEFORMULA(EXPENDITURE_ORGANIZATION_ID IN NUMBER) RETURN VARCHAR2;

  FUNCTION CF_TASK_NAMEFORMULA(TASK_ID_V IN NUMBER
                              ,PROJECT_ID_V IN NUMBER) RETURN VARCHAR2;

  FUNCTION CF_AWARD_NAMEFORMULA(AWARD_ID_V IN NUMBER) RETURN VARCHAR2;

  FUNCTION CF_ASSIGNMENT_NUMBERFORMULA(ASSIGNMENT_ID_V IN NUMBER
                                      ,PERSON_ID_V IN NUMBER) RETURN VARCHAR2;

  FUNCTION CF_PERSON_NAMEFORMULA(PERSON_ID_V IN NUMBER) RETURN VARCHAR2;

  FUNCTION CF_EARNINGS_ELEMENTFORMULA(ELEMENT_TYPE_ID_V IN NUMBER) RETURN VARCHAR2;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION CF_EMPLOYEE_IDFORMULA(PERSON_ID_V IN NUMBER) RETURN VARCHAR2;

  FUNCTION CF_NUMBER_WORKING_DAYSFORMULA(SCHEDULE_BEGIN_DATE IN DATE
                                        ,SCHEDULE_END_DATE IN DATE) RETURN NUMBER;

  FUNCTION AFTERPFORM RETURN BOOLEAN;

  FUNCTION CF_TIME_PERIOD_STARTFORMULA(CF_DATE_FORMAT IN VARCHAR2) RETURN CHAR;

  FUNCTION CF_TIME_PERIOD_ENDFORMULA(CF_DATE_FORMAT IN VARCHAR2) RETURN CHAR;

  FUNCTION CF_INSTITUTION_NAMEFORMULA RETURN VARCHAR2;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION BEFOREPFORM RETURN BOOLEAN;

  FUNCTION CF_DATE_FORMATFORMULA RETURN CHAR;

  FUNCTION CF_DEFAULT_BEGIN_DATEFORMULA(DEFAULT_BEGIN_DATE IN DATE
                                       ,CF_DATE_FORMAT IN VARCHAR2) RETURN CHAR;

  FUNCTION CF_DEFAULT_END_DATEFORMULA(DEFAULT_END_DATE IN DATE
                                     ,CF_DATE_FORMAT IN VARCHAR2) RETURN CHAR;

  FUNCTION CF_DATE_RUNFORMULA(CF_DATE_FORMAT IN VARCHAR2) RETURN CHAR;

  FUNCTION CF_SCHEDULE_BEGIN_DATEFORMULA(SCHEDULE_BEGIN_DATE IN DATE
                                        ,CF_DATE_FORMAT IN VARCHAR2
                                        ,SCHEDULE_END_DATE IN DATE) RETURN CHAR;

  FUNCTION CF_SCHEDULE_END_DATEFORMULA(SCHEDULE_END_DATE IN DATE
                                      ,CF_DATE_FORMAT IN VARCHAR2) RETURN CHAR;

  PROCEDURE CRT(ERRBUF OUT NOCOPY VARCHAR2
               ,RETCODE OUT NOCOPY NUMBER
               ,A_TEMPLATE_ID IN NUMBER);

  PROCEDURE INIT_WORKFLOW(A_TEMPLATE_ID IN NUMBER);

  PROCEDURE UPD_INCLUDE_FLAG(A_TEMPLATE_ID IN NUMBER);


  PROCEDURE GET_ANNUAL_SALARY(P_ASSIGNMENT_ID IN NUMBER
                             ,P_SESSION_DATE IN DATE
                             ,P_ANNUAL_SALARY OUT NOCOPY NUMBER);

  PROCEDURE GET_GL_CCID(P_PAYROLL_ID IN NUMBER
                       ,P_SET_OF_BOOKS_ID IN NUMBER
                       ,P_COST_KEYFLEX_ID IN NUMBER
                       ,X_GL_CCID OUT NOCOPY NUMBER);

  FUNCTION BUSINESS_DAYS(LOW_DATE IN DATE
                        ,HIGH_DATE IN DATE) RETURN NUMBER;

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

END PSP_PSPLSODL_XMLP_PKG;

/