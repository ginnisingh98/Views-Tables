--------------------------------------------------------
--  DDL for Package AP_APXCCOUT_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_APXCCOUT_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: APXCCOUT_SUMMARYS.pls 120.0 2007/12/28 11:11:51 vjaganat noship $ */
  P_TRACE_SWITCH VARCHAR2(1);

  P_CONC_REQUEST_ID NUMBER := 0;

  P_MIN_PRECISION NUMBER;

  P_SEND_NOTIFICATIONS VARCHAR2(2);

  P_MIN_AMOUNT NUMBER;

  P_BILLED_START_DATE DATE;

  P_BILLED_END_DATE DATE;

  P_CARD_PROGRAM_ID NUMBER;

  P_OPERATION_TYPE VARCHAR2(32767);

  LP_EMPLOYEE_WHERE VARCHAR2(2000);

  P_STATUS VARCHAR2(1);

  LP_EMPLOYEE_FROM VARCHAR2(200);

  LP_SELECT_EMP VARCHAR2(30) := '1';

  LP_GROUP_BY VARCHAR2(60);

  LP_SELECT_SUP VARCHAR2(30) := '1';

  LP_EMPLOYEE_STATUS VARCHAR2(32767) := '''Active''';

  P_BUCKET1 NUMBER;

  P_BUCKET2 NUMBER;

  P_BUCKET3 NUMBER;

  P_BUCKET4 NUMBER;

  P_MANAGER NUMBER;

  P_EMPLOYEE NUMBER;

  LP_EMP_MGR VARCHAR2(2000);

  LP_EMP_MGR1 VARCHAR2(2000);

  LP_SELECT_EMP_NAME VARCHAR2(60) := '''abcdsfkjshdfksdfhksdhfksadfhksdhfksadfsadfksadfksdafh''';

  P_INCLUDE_DIRECTS VARCHAR2(1);

  LP_MIN_AMT_WHERE VARCHAR2(200);

  P_ESC_LEVEL NUMBER;

  P_GRACE_DAYS NUMBER;

  LP_INACTIVE_WHERE VARCHAR2(300);

  CP_UNSUBMITTED NUMBER := 0;

  CP_REJECTED NUMBER := 0;

  CP_WITHDRAWN NUMBER := 0;

  CP_SAVED NUMBER := 0;

  CP_RETURNED NUMBER := 0;

  CP_RESOLUTN NUMBER := 0;

  CP_INVOICED NUMBER := 0;

  CP_ERROR NUMBER := 0;

  CP_EMP_APPR NUMBER := 0;

  CP_MGR_UNAPPROVED NUMBER := 0;

  CP_AP_UNAPPROVED NUMBER := 0;

  CP_DISPUTED NUMBER := 0;

  CP_MASKED_CARD_NUMBER VARCHAR2(20);

  CP_SUPERVISOR_NAME VARCHAR2(240);

  CP_EMP_NAME_SUMM VARCHAR2(240);

  CP_AGE_SUP_NAME VARCHAR2(240);

  CP_SUP_PEND_BUCKET1 NUMBER;

  CP_SUP_PEND_BUCKET2 NUMBER;

  CP_SUP_PEND_BUCKET3 NUMBER;

  CP_SUP_PEND_BUCKET4 NUMBER;

  CP_AGE_EMP_NAME VARCHAR2(240);

  CP_APPR_PEND_BUCKET1 NUMBER := 0;

  CP_APPR_PEND_BUCKET3 NUMBER := 0;

  CP_APPR_PEND_BUCKET4 NUMBER := 0;

  CP_APPR_PEND_BUCKET2 NUMBER := 0;

  CP_EMP_PEND_BUCKET1 NUMBER := 0;

  CP_EMP_PEND_BUCKET2 NUMBER := 0;

  CP_EMP_PEND_BUCKET3 NUMBER := 0;

  CP_EMP_PEND_BUCKET4 NUMBER := 0;

  CP_SYS_PEND_BUCKET2 NUMBER := 0;

  CP_SYS_PEND_BUCKET3 NUMBER := 0;

  CP_SYS_PEND_BUCKET4 NUMBER := 0;

  CP_SYS_PEND_BUCKET1 NUMBER := 0;

  CP_MGR_PEND_BUCKET1 NUMBER := 0;

  CP_MGR_PEND_BUCKET2 NUMBER := 0;

  CP_MGR_PEND_BUCKET3 NUMBER := 0;

  CP_MGR_PEND_BUCKET4 NUMBER := 0;

  CP_BUCKET1 NUMBER;

  CP_BUCKET2 NUMBER;

  CP_BUCKET3 NUMBER;

  CP_BUCKET4 NUMBER;

  CP_EMP_PENDING NUMBER;

  CP_SYS_PENDING NUMBER;

  CP_MGR_PENDING NUMBER;

  CP_APPR_PENDING NUMBER;

  CP_NLS_YES VARCHAR2(80);

  CP_NLS_NO VARCHAR2(80);

  CP_NLS_ALL VARCHAR2(80);

  CP_NLS_NO_DATA_FOUND VARCHAR2(80);

  CP_NLS_END_OF_REPORT VARCHAR2(80);

  CP_COMPANY_NAME_HEADER VARCHAR2(80);

  CP_CHART_OF_ACCOUNTS_ID NUMBER;

  C_BASE_CURRENCY_CODE VARCHAR2(15);

  C_BASE_DESCRIPTION VARCHAR2(240);

  C_BASE_MIN_ACCT_UNIT NUMBER;

  C_BASE_PRECISION NUMBER;

  CP_NLS_UNSUBMITTED VARCHAR2(80);

  CP_NLS_MGR_UNAPPROVED VARCHAR2(80);

  CP_NLS_AP_UNAPPROVED VARCHAR2(80);

  CP_NLS_DISPUTED VARCHAR2(80);

  CP_CARD_PROGRAM_NAME VARCHAR2(80);

  CP_1 NUMBER;

  CP_REPORT_TITLE VARCHAR2(200);

  CP_BUCKET1_NAME VARCHAR2(20);

  CP_BUCKET2_NAME VARCHAR2(20);

  CP_BUCKET3_NAME VARCHAR2(20);

  CP_BUCKET4_NAME VARCHAR2(20);

  CP_NLS_REJECTED VARCHAR2(80);

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  FUNCTION GETNLSSTRINGS RETURN BOOLEAN;

  FUNCTION CF_REPORT_NUMFORMULA(C_REPORT_HEADER_ID IN NUMBER) RETURN VARCHAR2;

  FUNCTION GETCOMPANYNAME RETURN BOOLEAN;

  FUNCTION CF_STATUSFORMULA(C_STATUS IN VARCHAR2
                           ,C_BILLED_AMOUNT IN NUMBER) RETURN VARCHAR2;

  FUNCTION CF_CP_CURRENCY_CODEFORMULA(C_CP_CURRENCY_CODE IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION CF_EMP_CURRENCY_CODEFORMULA(C_EMP_CURRENCY_CODE IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION GETBASECURRDATA RETURN BOOLEAN;

  PROCEDURE SENDUNSUBMITTED;

  PROCEDURE SENDMGRUNAPPROVED;

  PROCEDURE SENDDISPUTED;

  FUNCTION GETCARDPROGRAMNAME RETURN BOOLEAN;

  FUNCTION CF_SUPERVISOR_NAMEFORMULA(SUPERVISOR_ID1 IN NUMBER) RETURN CHAR;

  FUNCTION CF_AGING_BUCKETSFORMULA(AGE_POSTED_DATE IN DATE
                                  ,AGING_AMOUNT IN NUMBER) RETURN CHAR;

  FUNCTION CF_AGING_SUP_NAMEFORMULA(AGE_SUPERVISOR_ID IN NUMBER) RETURN CHAR;

  FUNCTION CF_AGE_AMP_NAMEFORMULA(AGE_EMPLOYEE_ID IN NUMBER
                                 ,AGE_EMP_STATUS IN VARCHAR2) RETURN CHAR;

  FUNCTION CF_EMP_NAME_SUMMFORMULA(EMPLOYEE_ID1 IN NUMBER) RETURN CHAR;

  FUNCTION CF_PENDING_AMOUNTSFORMULA(AGING_REPORT_STATUS_CODE IN VARCHAR2
                                    ,AGE_POSTED_DATE IN DATE
                                    ,AGING_AMOUNT IN NUMBER) RETURN CHAR;

  FUNCTION CF_AGE_SUP_PEND_BUCKLET1FORMUL(CS_SUP_BUCKET1 IN NUMBER
                                         ,CS_SUP_BUCKET2 IN NUMBER
                                         ,CS_SUP_BUCKET3 IN NUMBER
                                         ,CS_SUP_BUCKET4 IN NUMBER) RETURN CHAR;

  PROCEDURE SEND1DUNNINGNOTIFICATIONS(P_IN_MIN_BUCKET IN NUMBER
                                     ,P_IN_MAX_BUCKET IN NUMBER
                                     ,P_IN_DUNNING_NUMBER IN NUMBER
                                     ,P_IN_SEND_NOTIFICATIONS IN VARCHAR2
                                     ,P_IN_ESC_LEVEL IN NUMBER
                                     ,P_IN_GRACE_DAYS IN NUMBER);

  FUNCTION AFTERPFORM RETURN BOOLEAN;

  FUNCTION CF_MASKED_CARD_NUMBERFORMULA(C_CARD_NUMBER IN VARCHAR2) RETURN CHAR;

  PROCEDURE AP_WEB_START_INACT_PRO(P_CARD_PROGRAM_ID IN NUMBER
                                  ,P_CC_BILLED_START_DATE IN DATE
                                  ,P_CC_BILLED_END_DATE IN DATE
                                  ,P_ERRNUM OUT NOCOPY NUMBER
                                  ,P_ERRMSG OUT NOCOPY VARCHAR2);

  FUNCTION CP_UNSUBMITTED_P RETURN NUMBER;

  FUNCTION CP_REJECTED_P RETURN NUMBER;

  FUNCTION CP_WITHDRAWN_P RETURN NUMBER;

  FUNCTION CP_SAVED_P RETURN NUMBER;

  FUNCTION CP_RETURNED_P RETURN NUMBER;

  FUNCTION CP_RESOLUTN_P RETURN NUMBER;

  FUNCTION CP_INVOICED_P RETURN NUMBER;

  FUNCTION CP_ERROR_P RETURN NUMBER;

  FUNCTION CP_EMP_APPR_P RETURN NUMBER;

  FUNCTION CP_MGR_UNAPPROVED_P RETURN NUMBER;

  FUNCTION CP_AP_UNAPPROVED_P RETURN NUMBER;

  FUNCTION CP_DISPUTED_P RETURN NUMBER;

  FUNCTION CP_MASKED_CARD_NUMBER_P RETURN VARCHAR2;

  FUNCTION CP_SUPERVISOR_NAME_P RETURN VARCHAR2;

  FUNCTION CP_EMP_NAME_SUMM_P RETURN VARCHAR2;

  FUNCTION CP_AGE_SUP_NAME_P RETURN VARCHAR2;

  FUNCTION CP_SUP_PEND_BUCKET1_P RETURN NUMBER;

  FUNCTION CP_SUP_PEND_BUCKET2_P RETURN NUMBER;

  FUNCTION CP_SUP_PEND_BUCKET3_P RETURN NUMBER;

  FUNCTION CP_SUP_PEND_BUCKET4_P RETURN NUMBER;

  FUNCTION CP_AGE_EMP_NAME_P RETURN VARCHAR2;

  FUNCTION CP_APPR_PEND_BUCKET1_P RETURN NUMBER;

  FUNCTION CP_APPR_PEND_BUCKET3_P RETURN NUMBER;

  FUNCTION CP_APPR_PEND_BUCKET4_P RETURN NUMBER;

  FUNCTION CP_APPR_PEND_BUCKET2_P RETURN NUMBER;

  FUNCTION CP_EMP_PEND_BUCKET1_P RETURN NUMBER;

  FUNCTION CP_EMP_PEND_BUCKET2_P RETURN NUMBER;

  FUNCTION CP_EMP_PEND_BUCKET3_P RETURN NUMBER;

  FUNCTION CP_EMP_PEND_BUCKET4_P RETURN NUMBER;

  FUNCTION CP_SYS_PEND_BUCKET2_P RETURN NUMBER;

  FUNCTION CP_SYS_PEND_BUCKET3_P RETURN NUMBER;

  FUNCTION CP_SYS_PEND_BUCKET4_P RETURN NUMBER;

  FUNCTION CP_SYS_PEND_BUCKET1_P RETURN NUMBER;

  FUNCTION CP_MGR_PEND_BUCKET1_P RETURN NUMBER;

  FUNCTION CP_MGR_PEND_BUCKET2_P RETURN NUMBER;

  FUNCTION CP_MGR_PEND_BUCKET3_P RETURN NUMBER;

  FUNCTION CP_MGR_PEND_BUCKET4_P RETURN NUMBER;

  FUNCTION CP_BUCKET1_P RETURN NUMBER;

  FUNCTION CP_BUCKET2_P RETURN NUMBER;

  FUNCTION CP_BUCKET3_P RETURN NUMBER;

  FUNCTION CP_BUCKET4_P RETURN NUMBER;

  FUNCTION CP_EMP_PENDING_P RETURN NUMBER;

  FUNCTION CP_SYS_PENDING_P RETURN NUMBER;

  FUNCTION CP_MGR_PENDING_P RETURN NUMBER;

  FUNCTION CP_APPR_PENDING_P RETURN NUMBER;

  FUNCTION CP_NLS_YES_P RETURN VARCHAR2;

  FUNCTION CP_NLS_NO_P RETURN VARCHAR2;

  FUNCTION CP_NLS_ALL_P RETURN VARCHAR2;

  FUNCTION CP_NLS_NO_DATA_FOUND_P RETURN VARCHAR2;

  FUNCTION CP_NLS_END_OF_REPORT_P RETURN VARCHAR2;

  FUNCTION CP_COMPANY_NAME_HEADER_P RETURN VARCHAR2;

  FUNCTION CP_CHART_OF_ACCOUNTS_ID_P RETURN NUMBER;

  FUNCTION C_BASE_CURRENCY_CODE_P RETURN VARCHAR2;

  FUNCTION C_BASE_DESCRIPTION_P RETURN VARCHAR2;

  FUNCTION C_BASE_MIN_ACCT_UNIT_P RETURN NUMBER;

  FUNCTION C_BASE_PRECISION_P RETURN NUMBER;

  FUNCTION CP_NLS_UNSUBMITTED_P RETURN VARCHAR2;

  FUNCTION CP_NLS_MGR_UNAPPROVED_P RETURN VARCHAR2;

  FUNCTION CP_NLS_AP_UNAPPROVED_P RETURN VARCHAR2;

  FUNCTION CP_NLS_DISPUTED_P RETURN VARCHAR2;

  FUNCTION CP_CARD_PROGRAM_NAME_P RETURN VARCHAR2;

  FUNCTION CP_1_P RETURN NUMBER;

  FUNCTION CP_REPORT_TITLE_P RETURN VARCHAR2;

  FUNCTION CP_BUCKET1_NAME_P RETURN VARCHAR2;

  FUNCTION CP_BUCKET2_NAME_P RETURN VARCHAR2;

  FUNCTION CP_BUCKET3_NAME_P RETURN VARCHAR2;

  FUNCTION CP_BUCKET4_NAME_P RETURN VARCHAR2;

  FUNCTION CP_NLS_REJECTED_P RETURN VARCHAR2;

  FUNCTION Q_agingFilter RETURN BOOLEAN  ;

  FUNCTION Q_TRANS_SUMMFilter RETURN BOOLEAN ;

  FUNCTION Q_TRXNFilter RETURN BOOLEAN ;

END AP_APXCCOUT_XMLP_PKG;


/