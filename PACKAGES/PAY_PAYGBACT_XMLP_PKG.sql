--------------------------------------------------------
--  DDL for Package PAY_PAYGBACT_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PAYGBACT_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAYGBACTS.pls 120.0 2008/01/07 15:33:06 srikrish noship $ */
  P_BUSINESS_GROUP_ID NUMBER;

  P_SESSION_DATE DATE;
  P_SESSION_DATE_T VARCHAR2(40);

  P_CONC_REQUEST_ID NUMBER;

  P_ELEMENT_NAME VARCHAR2(12);

  P_START_DATE DATE;
  P_START_DATE_T VARCHAR2(40);

  P_PERSON_ID NUMBER;

  PERSON_ID VARCHAR2(40);

  SESSION_DATE DATE;

  C_BUSINESS_GROUP_NAME VARCHAR2(240);

  C_REPORT_SUBTITLE VARCHAR2(60);

  C_PERSON_NAME VARCHAR2(500) := 'All Employees';

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION GET_STAT_PERIOD_START(ASSIGNMENT_ACTION_ID IN NUMBER) RETURN DATE;

  FUNCTION GET_NI_PTD(ASSIGNMENT_ACTION_ID IN NUMBER
                     ,ELEMENT_NAME IN VARCHAR2
                     ,INPUT_NAME IN VARCHAR2) RETURN NUMBER;

  FUNCTION GET_NI_YTD(ASSIGNMENT_ACTION_ID IN NUMBER
                     ,ELEMENT_NAME IN VARCHAR2
                     ,INPUT_NAME IN VARCHAR2) RETURN NUMBER;

  FUNCTION BEFOREPFORM RETURN BOOLEAN;

  FUNCTION AFTERPFORM RETURN BOOLEAN;

  FUNCTION BETWEENPAGE RETURN BOOLEAN;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION C_BUSINESS_GROUP_NAME_P RETURN VARCHAR2;

  FUNCTION C_REPORT_SUBTITLE_P RETURN VARCHAR2;

  FUNCTION C_PERSON_NAME_P RETURN VARCHAR2;

  FUNCTION GET_BUDGET(P_BUDGET_ID IN NUMBER) RETURN VARCHAR2;

  FUNCTION GET_BUDGET_VERSION(P_BUDGET_ID IN NUMBER
                             ,P_BUDGET_VERSION_ID IN NUMBER) RETURN VARCHAR2;

  PROCEDURE GET_ORGANIZATION(P_ORGANIZATION_ID IN NUMBER
                            ,P_ORG_NAME OUT NOCOPY VARCHAR2
                            ,P_ORG_TYPE OUT NOCOPY VARCHAR2);

  FUNCTION GET_JOB(P_JOB_ID IN NUMBER) RETURN VARCHAR2;

  FUNCTION GET_POSITION(P_POSITION_ID IN NUMBER) RETURN VARCHAR2;

  FUNCTION GET_GRADE(P_GRADE_ID IN NUMBER) RETURN VARCHAR2;

  FUNCTION GET_STATUS(P_BUSINESS_GROUP_ID IN NUMBER
                     ,P_ASSIGNMENT_STATUS_TYPE_ID IN NUMBER
                     ,P_LEGISLATION_CODE IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION GET_ABS_TYPE(P_ABS_ATT_TYPE_ID IN NUMBER) RETURN VARCHAR2;

  PROCEDURE GET_TIME_PERIOD(P_TIME_PERIOD_ID IN NUMBER
                           ,P_PERIOD_NAME OUT NOCOPY VARCHAR2
                           ,P_START_DATE OUT NOCOPY DATE
                           ,P_END_DATE OUT NOCOPY DATE);

  FUNCTION GET_BUSINESS_GROUP(P_BUSINESS_GROUP_ID IN NUMBER) RETURN VARCHAR2;

  FUNCTION COUNT_ORG_SUBORDINATES(P_ORG_STRUCTURE_VERSION_ID IN NUMBER
                                 ,P_PARENT_ORGANIZATION_ID IN NUMBER) RETURN NUMBER;

  FUNCTION COUNT_POS_SUBORDINATES(P_POS_STRUCTURE_VERSION_ID IN NUMBER
                                 ,P_PARENT_POSITION_ID IN NUMBER) RETURN NUMBER;

  PROCEDURE GET_ORGANIZATION_HIERARCHY(P_ORGANIZATION_STRUCTURE_ID IN NUMBER
                                      ,P_ORG_STRUCTURE_VERSION_ID IN NUMBER
                                      ,P_ORG_STRUCTURE_NAME OUT NOCOPY VARCHAR2
                                      ,P_ORG_VERSION OUT NOCOPY NUMBER
                                      ,P_VERSION_START_DATE OUT NOCOPY DATE
                                      ,P_VERSION_END_DATE OUT NOCOPY DATE);

  PROCEDURE GET_POSITION_HIERARCHY(P_POSITION_STRUCTURE_ID IN NUMBER
                                  ,P_POS_STRUCTURE_VERSION_ID IN NUMBER
                                  ,P_POS_STRUCTURE_NAME OUT NOCOPY VARCHAR2
                                  ,P_POS_VERSION OUT NOCOPY NUMBER
                                  ,P_VERSION_START_DATE OUT NOCOPY DATE
                                  ,P_VERSION_END_DATE OUT NOCOPY DATE);

  FUNCTION GET_LOOKUP_MEANING(P_LOOKUP_TYPE IN VARCHAR2
                             ,P_LOOKUP_CODE IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION PERSON_MATCHING_SKILLS(P_PERSON_ID IN NUMBER
                                 ,P_JOB_POSITION_ID IN NUMBER
                                 ,P_JOB_POSITION_TYPE IN VARCHAR2
                                 ,P_MATCHING_LEVEL IN VARCHAR2
                                 ,P_NO_OF_ESSENTIAL IN NUMBER
                                 ,P_NO_OF_DESIRABLE IN NUMBER) RETURN BOOLEAN;

  FUNCTION GET_PAYROLL_NAME(P_SESSION_DATE IN DATE
                           ,P_PAYROLL_ID IN NUMBER) RETURN VARCHAR2;

  FUNCTION GET_ELEMENT_NAME(P_SESSION_DATE IN DATE
                           ,P_ELEMENT_TYPE_ID IN NUMBER) RETURN VARCHAR2;

  PROCEDURE GEN_PARTIAL_MATCHING_LEXICAL(P_CONCATENATED_SEGMENTS IN VARCHAR2
                                        ,P_ID_FLEX_NUM IN NUMBER
                                        ,P_MATCHING_LEXICAL IN OUT NOCOPY VARCHAR2);

  PROCEDURE GET_ATTRIBUTES(P_CONCATENATED_SEGMENTS IN VARCHAR2
                          ,P_NAME IN VARCHAR2
                          ,P_SEGMENTS_USED OUT NOCOPY NUMBER
                          ,P_VALUE1 OUT NOCOPY VARCHAR2
                          ,P_VALUE2 OUT NOCOPY VARCHAR2
                          ,P_VALUE3 OUT NOCOPY VARCHAR2
                          ,P_VALUE4 OUT NOCOPY VARCHAR2
                          ,P_VALUE5 OUT NOCOPY VARCHAR2
                          ,P_VALUE6 OUT NOCOPY VARCHAR2
                          ,P_VALUE7 OUT NOCOPY VARCHAR2
                          ,P_VALUE8 OUT NOCOPY VARCHAR2
                          ,P_VALUE9 OUT NOCOPY VARCHAR2
                          ,P_VALUE10 OUT NOCOPY VARCHAR2
                          ,P_VALUE11 OUT NOCOPY VARCHAR2
                          ,P_VALUE12 OUT NOCOPY VARCHAR2
                          ,P_VALUE13 OUT NOCOPY VARCHAR2
                          ,P_VALUE14 OUT NOCOPY VARCHAR2
                          ,P_VALUE15 OUT NOCOPY VARCHAR2
                          ,P_VALUE16 OUT NOCOPY VARCHAR2
                          ,P_VALUE17 OUT NOCOPY VARCHAR2
                          ,P_VALUE18 OUT NOCOPY VARCHAR2
                          ,P_VALUE19 OUT NOCOPY VARCHAR2
                          ,P_VALUE20 OUT NOCOPY VARCHAR2
                          ,P_VALUE21 OUT NOCOPY VARCHAR2
                          ,P_VALUE22 OUT NOCOPY VARCHAR2
                          ,P_VALUE23 OUT NOCOPY VARCHAR2
                          ,P_VALUE24 OUT NOCOPY VARCHAR2
                          ,P_VALUE25 OUT NOCOPY VARCHAR2
                          ,P_VALUE26 OUT NOCOPY VARCHAR2
                          ,P_VALUE27 OUT NOCOPY VARCHAR2
                          ,P_VALUE28 OUT NOCOPY VARCHAR2
                          ,P_VALUE29 OUT NOCOPY VARCHAR2
                          ,P_VALUE30 OUT NOCOPY VARCHAR2);

  PROCEDURE GET_SEGMENTS(P_CONCATENATED_SEGMENTS IN VARCHAR2
                        ,P_ID_FLEX_NUM IN NUMBER
                        ,P_SEGMENTS_USED OUT NOCOPY NUMBER
                        ,P_VALUE1 OUT NOCOPY VARCHAR2
                        ,P_VALUE2 OUT NOCOPY VARCHAR2
                        ,P_VALUE3 OUT NOCOPY VARCHAR2
                        ,P_VALUE4 OUT NOCOPY VARCHAR2
                        ,P_VALUE5 OUT NOCOPY VARCHAR2
                        ,P_VALUE6 OUT NOCOPY VARCHAR2
                        ,P_VALUE7 OUT NOCOPY VARCHAR2
                        ,P_VALUE8 OUT NOCOPY VARCHAR2
                        ,P_VALUE9 OUT NOCOPY VARCHAR2
                        ,P_VALUE10 OUT NOCOPY VARCHAR2
                        ,P_VALUE11 OUT NOCOPY VARCHAR2
                        ,P_VALUE12 OUT NOCOPY VARCHAR2
                        ,P_VALUE13 OUT NOCOPY VARCHAR2
                        ,P_VALUE14 OUT NOCOPY VARCHAR2
                        ,P_VALUE15 OUT NOCOPY VARCHAR2
                        ,P_VALUE16 OUT NOCOPY VARCHAR2
                        ,P_VALUE17 OUT NOCOPY VARCHAR2
                        ,P_VALUE18 OUT NOCOPY VARCHAR2
                        ,P_VALUE19 OUT NOCOPY VARCHAR2
                        ,P_VALUE20 OUT NOCOPY VARCHAR2
                        ,P_VALUE21 OUT NOCOPY VARCHAR2
                        ,P_VALUE22 OUT NOCOPY VARCHAR2
                        ,P_VALUE23 OUT NOCOPY VARCHAR2
                        ,P_VALUE24 OUT NOCOPY VARCHAR2
                        ,P_VALUE25 OUT NOCOPY VARCHAR2
                        ,P_VALUE26 OUT NOCOPY VARCHAR2
                        ,P_VALUE27 OUT NOCOPY VARCHAR2
                        ,P_VALUE28 OUT NOCOPY VARCHAR2
                        ,P_VALUE29 OUT NOCOPY VARCHAR2
                        ,P_VALUE30 OUT NOCOPY VARCHAR2);

  PROCEDURE GET_DESC_FLEX(P_APPL_SHORT_NAME IN VARCHAR2
                         ,P_DESC_FLEX_NAME IN VARCHAR2
                         ,P_TABLE_ALIAS IN VARCHAR2
                         ,P_TITLE OUT NOCOPY VARCHAR2
                         ,P_LABEL_EXPR OUT NOCOPY VARCHAR2
                         ,P_COLUMN_EXPR OUT NOCOPY VARCHAR2);

  PROCEDURE GET_DESC_FLEX_CONTEXT(P_APPL_SHORT_NAME IN VARCHAR2
                                 ,P_DESC_FLEX_NAME IN VARCHAR2
                                 ,P_TABLE_ALIAS IN VARCHAR2
                                 ,P_TITLE OUT NOCOPY VARCHAR2
                                 ,P_LABEL_EXPR OUT NOCOPY VARCHAR2
                                 ,P_COLUMN_EXPR OUT NOCOPY VARCHAR2);

  PROCEDURE GET_DVLPR_DESC_FLEX(P_APPL_SHORT_NAME IN VARCHAR2
                               ,P_DESC_FLEX_NAME IN VARCHAR2
                               ,P_DESC_FLEX_CONTEXT IN VARCHAR2
                               ,P_TABLE_ALIAS IN VARCHAR2
                               ,P_TITLE OUT NOCOPY VARCHAR2
                               ,P_LABEL_EXPR OUT NOCOPY VARCHAR2
                               ,P_COLUMN_EXPR OUT NOCOPY VARCHAR2);

  FUNCTION GET_PERSON_NAME(P_SESSION_DATE IN DATE
                          ,P_PERSON_ID IN NUMBER) RETURN VARCHAR2;

  PROCEDURE SET_CONTEXT(P_CONTEXT_NAME IN VARCHAR2
                       ,P_CONTEXT_VALUE IN VARCHAR2);

  FUNCTION RUN_DB_ITEM(P_DATABASE_NAME IN VARCHAR2
                      ,P_BUS_GROUP_ID IN NUMBER
                      ,P_LEGISLATION_CODE IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION CHECK_BAL_EXPIRY(P_BAL_OWNER_ASG_ACTION IN NUMBER
                           ,P_ASSIGNMENT_ACTION_ID IN NUMBER
                           ,P_DIMENSION_NAME IN VARCHAR2
                           ,P_EXPIRY_CHECKING_LEVEL IN VARCHAR2
                           ,P_EXPIRY_CHECKING_CODE IN VARCHAR2
                           ,P_BAL_CONTEXT_STR IN VARCHAR2) RETURN BOOLEAN;

  FUNCTION GET_VALUE(P_DEFINED_BALANCE_ID IN NUMBER
                    ,P_ASSIGNMENT_ACTION_ID IN NUMBER) RETURN NUMBER;

  FUNCTION GET_VALUE(P_DEFINED_BALANCE_ID IN NUMBER
                    ,P_ASSIGNMENT_ACTION_ID IN NUMBER
                    ,P_ALWAYS_GET_DB_ITEM IN BOOLEAN) RETURN NUMBER;

  FUNCTION GET_VALUE(P_DEFINED_BALANCE_ID IN NUMBER
                    ,P_ASSIGNMENT_ID IN NUMBER
                    ,P_VIRTUAL_DATE IN DATE) RETURN NUMBER;

  FUNCTION GET_VALUE(P_DEFINED_BALANCE_ID IN NUMBER
                    ,P_ASSIGNMENT_ID IN NUMBER
                    ,P_VIRTUAL_DATE IN DATE
                    ,P_ALWAYS_GET_DB_ITEM IN BOOLEAN) RETURN NUMBER;

  FUNCTION GET_VALUE_LOCK(P_DEFINED_BALANCE_ID IN NUMBER
                         ,P_ASSIGNMENT_ID IN NUMBER
                         ,P_VIRTUAL_DATE IN DATE
                         ,P_ASG_LOCK IN VARCHAR2) RETURN NUMBER;

  FUNCTION GET_VALUE_LOCK(P_DEFINED_BALANCE_ID IN NUMBER
                         ,P_ASSIGNMENT_ID IN NUMBER
                         ,P_VIRTUAL_DATE IN DATE
                         ,P_ALWAYS_GET_DB_ITEM IN BOOLEAN
                         ,P_ASG_LOCK IN VARCHAR2) RETURN NUMBER;

END PAY_PAYGBACT_XMLP_PKG;

/