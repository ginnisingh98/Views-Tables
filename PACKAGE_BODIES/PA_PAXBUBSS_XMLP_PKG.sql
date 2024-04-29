--------------------------------------------------------
--  DDL for Package Body PA_PAXBUBSS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PAXBUBSS_XMLP_PKG" AS
/* $Header: PAXBUBSSB.pls 120.0 2008/01/02 11:21:53 krreddy noship $ */
  FUNCTION GET_COVER_PAGE_VALUES RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END GET_COVER_PAGE_VALUES;
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    DECLARE
      INIT_FAILURE EXCEPTION;
      P_ORG HR_ORGANIZATION_UNITS.NAME%TYPE;
      P_MGR VARCHAR2(30);
      P_NUMBER VARCHAR2(30);
      P_NAME VARCHAR2(30);
      TSK_NUM VARCHAR2(30);
      TSK_NAME VARCHAR2(30);
      EXPLODE VARCHAR2(30);
      P_COST_BGT_CODE VARCHAR2(30);
      P_COST_BGT_TYPE VARCHAR2(30);
      P_REV_BGT_CODE VARCHAR2(30);
      P_REV_BGT_TYPE VARCHAR2(30);
    BEGIN
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
      /*SRW.USER_EXIT('FND GETPROFILE
                    NAME="PA_RULE_BASED_OPTIMIZER"
                    FIELD=":p_rule_optimizer"
                    PRINT_ERROR="N"')*/NULL;
      P_DEBUG_MODE := FND_PROFILE.VALUE('PA_DEBUG_MODE');
      IF ORG IS NOT NULL THEN
        SELECT
          SUBSTR(NAME
                ,1
                ,60)
        INTO P_ORG
        FROM
          HR_ORGANIZATION_UNITS
        WHERE ORG = ORGANIZATION_ID;
      END IF;
      C_ORG := P_ORG;
      IF MGR IS NOT NULL THEN
        SELECT
          SUBSTR(FULL_NAME
                ,1
                ,30)
        INTO P_MGR
        FROM
          PER_PEOPLE_F
        WHERE MGR = PERSON_ID
          AND sysdate between EFFECTIVE_START_DATE
          AND NVL(EFFECTIVE_END_DATE
           ,SYSDATE + 1)
          AND ( CURRENT_NPW_FLAG = 'Y'
        OR CURRENT_EMPLOYEE_FLAG = 'Y' )
          AND DECODE(CURRENT_NPW_FLAG
              ,'Y'
              ,NPW_NUMBER
              ,EMPLOYEE_NUMBER) IS NOT NULL;
      END IF;
      C_MGR := P_MGR;
      IF PROJ IS NOT NULL THEN
        SELECT
          SEGMENT1,
          NAME
        INTO P_NUMBER,P_NAME
        FROM
          PA_PROJECTS
        WHERE PROJ = PROJECT_ID;
      END IF;
      C_PROJ_NUM := P_NUMBER;
      C_PROJ_NAME := P_NAME;
      IF TOPTASK IS NOT NULL THEN
        SELECT
          TASK_NUMBER,
          TASK_NAME
        INTO TSK_NUM,TSK_NAME
        FROM
          PA_TASKS
        WHERE TOPTASK = TASK_ID;
      END IF;
      C_TASK_NUM := TSK_NUM;
      C_TASK_NAME := TSK_NAME;
      IF EXPLODE_SUB_TASKS IS NOT NULL THEN
        SELECT
          MEANING
        INTO EXPLODE
        FROM
          FND_LOOKUPS
        WHERE LOOKUP_TYPE = 'YES_NO'
          AND LOOKUP_CODE = EXPLODE_SUB_TASKS;
      END IF;
      C_EXPLODE := EXPLODE;
      IF (COST_BGT_CODE IS NULL) THEN
        SELECT
          BUDGET_TYPE_CODE,
          BUDGET_TYPE
        INTO P_COST_BGT_CODE,P_COST_BGT_TYPE
        FROM
          PA_BUDGET_TYPES
        WHERE BUDGET_AMOUNT_CODE = 'C'
          AND PREDEFINED_FLAG = 'Y'
          AND BUDGET_TYPE_CODE = 'AC';
        C_COST_BGT_CODE := P_COST_BGT_CODE;
        C_COST_BGT_NAME := P_COST_BGT_TYPE;
      ELSE
        SELECT
          BUDGET_TYPE
        INTO P_COST_BGT_TYPE
        FROM
          PA_BUDGET_TYPES
        WHERE BUDGET_TYPE_CODE = COST_BGT_CODE;
        C_COST_BGT_CODE := COST_BGT_CODE;
        C_COST_BGT_NAME := P_COST_BGT_TYPE;
      END IF;
      IF (REV_BGT_CODE IS NULL) THEN
        SELECT
          BUDGET_TYPE_CODE,
          BUDGET_TYPE
        INTO P_REV_BGT_CODE,P_REV_BGT_TYPE
        FROM
          PA_BUDGET_TYPES
        WHERE BUDGET_AMOUNT_CODE = 'R'
          AND PREDEFINED_FLAG = 'Y'
          AND BUDGET_TYPE_CODE = 'AR';
        C_REV_BGT_CODE := P_REV_BGT_CODE;
        C_REV_BGT_NAME := P_REV_BGT_TYPE;
      ELSE
        SELECT
          BUDGET_TYPE
        INTO P_REV_BGT_TYPE
        FROM
          PA_BUDGET_TYPES
        WHERE BUDGET_TYPE_CODE = REV_BGT_CODE;
        C_REV_BGT_CODE := REV_BGT_CODE;
        C_REV_BGT_NAME := P_REV_BGT_TYPE;
      END IF;
      IF (GET_COMPANY_NAME <> TRUE) THEN
        RAISE INIT_FAILURE;
      END IF;
      IF (NO_DATA_FOUND_FUNC <> TRUE) THEN
        RAISE INIT_FAILURE;
      END IF;
    END;
    RETURN (TRUE);
  END BEFOREREPORT;
  FUNCTION GET_COMPANY_NAME RETURN BOOLEAN IS
    L_NAME GL_SETS_OF_BOOKS.NAME%TYPE;
  BEGIN
    SELECT
      GL.NAME
    INTO L_NAME
    FROM
      GL_SETS_OF_BOOKS GL,
      PA_IMPLEMENTATIONS PI
    WHERE GL.SET_OF_BOOKS_ID = PI.SET_OF_BOOKS_ID;
    C_COMPANY_NAME_HEADER := L_NAME;
    RETURN (TRUE);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END GET_COMPANY_NAME;
  FUNCTION NO_DATA_FOUND_FUNC RETURN BOOLEAN IS
    MESSAGE_NAME VARCHAR2(80);
  BEGIN
    SELECT
      MEANING
    INTO MESSAGE_NAME
    FROM
      PA_LOOKUPS
    WHERE LOOKUP_TYPE = 'MESSAGE'
      AND LOOKUP_CODE = 'NO_DATA_FOUND';
    C_NO_DATA_FOUND := MESSAGE_NAME;
    RETURN (TRUE);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END NO_DATA_FOUND_FUNC;
  FUNCTION GET_AR(PROJECT_ID_1 IN NUMBER) RETURN NUMBER IS
    ACCREC NUMBER(15,2);
  BEGIN
    SELECT
      SUM(AR.ACCTD_AMOUNT_DUE_REMAINING)
    INTO ACCREC
    FROM
      AR_PAYMENT_SCHEDULES AR,
      RA_CUSTOMER_TRX TRX,
      PA_DRAFT_INVOICES PDI
    WHERE PDI.SYSTEM_REFERENCE = TRX.CUSTOMER_TRX_ID
      AND TRX.TRX_NUMBER = AR.TRX_NUMBER
      AND PDI.PROJECT_ID = PROJECT_ID_1;
    RETURN (ACCREC);
  END GET_AR;
  FUNCTION ACCOUNTS_RECEIVABLEFORMULA(PROJECT_ID IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (GET_AR(PROJECT_ID));
  END ACCOUNTS_RECEIVABLEFORMULA;
  FUNCTION UNBILLED_RECFORMULA(RETN_ACCOUNTING_FLAG IN VARCHAR2
                              ,TOTAL_REVENUE_AMOUNT IN NUMBER
                              ,PFC_TOTAL_INVOICE_AMOUNT IN NUMBER
                              ,UNBILLED_RETENTION IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF (RETN_ACCOUNTING_FLAG = 'N') THEN
      RETURN (GREATEST((TOTAL_REVENUE_AMOUNT - PFC_TOTAL_INVOICE_AMOUNT - UNBILLED_RETENTION)
                     ,0));
    ELSE
      RETURN (GREATEST((TOTAL_REVENUE_AMOUNT - PFC_TOTAL_INVOICE_AMOUNT)
                     ,0));
    END IF;
  END UNBILLED_RECFORMULA;
  FUNCTION UNEARNED_REVFORMULA(RETN_ACCOUNTING_FLAG IN VARCHAR2
                              ,PFC_TOTAL_INVOICE_AMOUNT IN NUMBER
                              ,UNBILLED_RETENTION IN NUMBER
                              ,TOTAL_REVENUE_AMOUNT IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF (RETN_ACCOUNTING_FLAG = 'N') THEN
      RETURN (GREATEST((PFC_TOTAL_INVOICE_AMOUNT + UNBILLED_RETENTION - TOTAL_REVENUE_AMOUNT)
                     ,0));
    ELSE
      RETURN (GREATEST((PFC_TOTAL_INVOICE_AMOUNT - TOTAL_REVENUE_AMOUNT)
                     ,0));
    END IF;
  END UNEARNED_REVFORMULA;
  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    END;
    RETURN (TRUE);
  END AFTERREPORT;
  FUNCTION C_INDENTED_TASK_NUMBERFORMULA(WBS_LEVEL IN NUMBER
                                        ,TASK_NUMBER IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN (LPAD(' '
               ,2 * (NVL(WBS_LEVEL
                  ,1) - 1)) || TASK_NUMBER);
  END C_INDENTED_TASK_NUMBERFORMULA;
  FUNCTION C_INDENTED_TASK_NAMEFORMULA(WBS_LEVEL IN NUMBER
                                      ,TASK_NAME IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN (LPAD(' '
               ,2 * (NVL(WBS_LEVEL
                  ,1) - 1)) || TASK_NAME);
  END C_INDENTED_TASK_NAMEFORMULA;
  FUNCTION UNBILLED_RETNFORMULA(RETN_ACCOUNTING_FLAG IN VARCHAR2
                               ,UNBILLED_RETENTION IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF (RETN_ACCOUNTING_FLAG = 'N') THEN
      RETURN (0);
    ELSE
      RETURN (-UNBILLED_RETENTION);
    END IF;
  END UNBILLED_RETNFORMULA;
  FUNCTION C_COMPANY_NAME_HEADER_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_COMPANY_NAME_HEADER;
  END C_COMPANY_NAME_HEADER_P;
  FUNCTION C_NO_DATA_FOUND_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_NO_DATA_FOUND;
  END C_NO_DATA_FOUND_P;
  FUNCTION C_ORG_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_ORG;
  END C_ORG_P;
  FUNCTION C_PROJ_NUM_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_PROJ_NUM;
  END C_PROJ_NUM_P;
  FUNCTION C_PROJ_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_PROJ_NAME;
  END C_PROJ_NAME_P;
  FUNCTION C_MGR_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_MGR;
  END C_MGR_P;
  FUNCTION C_TASK_NUM_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_TASK_NUM;
  END C_TASK_NUM_P;
  FUNCTION C_TASK_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_TASK_NAME;
  END C_TASK_NAME_P;
  FUNCTION C_EXPLODE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_EXPLODE;
  END C_EXPLODE_P;
  FUNCTION C_PROJ_TYPE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_PROJ_TYPE;
  END C_PROJ_TYPE_P;
  FUNCTION C_COST_BGT_CODE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_COST_BGT_CODE;
  END C_COST_BGT_CODE_P;
  FUNCTION C_REV_BGT_CODE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_REV_BGT_CODE;
  END C_REV_BGT_CODE_P;
  FUNCTION C_COST_BGT_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_COST_BGT_NAME;
  END C_COST_BGT_NAME_P;
  FUNCTION C_REV_BGT_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_REV_BGT_NAME;
  END C_REV_BGT_NAME_P;
END PA_PAXBUBSS_XMLP_PKG;

/