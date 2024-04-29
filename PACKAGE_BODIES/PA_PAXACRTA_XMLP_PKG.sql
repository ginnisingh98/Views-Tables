--------------------------------------------------------
--  DDL for Package Body PA_PAXACRTA_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PAXACRTA_XMLP_PKG" AS
/* $Header: PAXACRTAB.pls 120.0 2008/01/02 11:12:35 krreddy noship $ */
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
      NDF VARCHAR2(80);
      ERRBUF VARCHAR2(525);
      MESSAGE_BUF VARCHAR2(256);
      NUMBER_OF_MESSAGES NUMBER;
    BEGIN
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
      /*SRW.USER_EXIT('FND GETPROFILE
                    NAME="PA_DEBUG_MODE"
                    FIELD=":p_debug_mode"
                    PRINT_ERROR="N"')*/NULL;
      P_RULE_OPTIMIZER := FND_PROFILE.VALUE('PA_RULE_BASED_OPTIMIZER');
      IF (GET_COMPANY_NAME <> TRUE) THEN
        RAISE INIT_FAILURE;
      END IF;
      SELECT
        MEANING
      INTO NDF
      FROM
        PA_LOOKUPS
      WHERE LOOKUP_CODE = 'NO_DATA_FOUND'
        AND LOOKUP_TYPE = 'MESSAGE';
      C_NO_DATA_FOUND := NDF;
      /*SRW.MESSAGE(1
                 ,'Concurrent request id is ' || TO_CHAR(P_CONC_REQUEST_ID))*/NULL;
      /*SRW.MESSAGE(1
                 ,'Calling Refresh Transaction Accumulation')*/NULL;
      PA_PROJ_ACCUM_MAIN.BUILD_TXN_ACCUM(ERRBUF
                                        ,C_RETCODE
                                        ,P_PROJECT_NUM_FROM
                                        ,P_PROJECT_NUM_TO
                                        ,P_START_PA_PERIOD
                                        ,P_END_PA_PERIOD
                                        ,P_SYSTEM_LINKAGE_FUNCTION);
      IF (C_RETCODE <> 0) THEN
        /*SRW.MESSAGE(1
                   ,ERRBUF)*/NULL;
        NUMBER_OF_MESSAGES := PA_DEBUG.NO_OF_DEBUG_MESSAGES;
        IF (P_DEBUG_MODE = 'Y' AND NUMBER_OF_MESSAGES > 0) THEN
          /*SRW.MESSAGE(1
                     ,'Debug Messages:')*/NULL;
          FOR i IN 1 .. NUMBER_OF_MESSAGES LOOP
            PA_DEBUG.GET_MESSAGE(I
                                ,MESSAGE_BUF);
            /*SRW.MESSAGE(1
                       ,MESSAGE_BUF)*/NULL;
          END LOOP;
        END IF;
        /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        SELECT
          MEANING
        INTO NDF
        FROM
          PA_LOOKUPS
        WHERE LOOKUP_CODE = 'NO_DATA_FOUND'
          AND LOOKUP_TYPE = 'MESSAGE';
        C_NO_DATA_FOUND := NDF;
        C_DUMMY_DATA := 1;
      WHEN OTHERS THEN
        /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
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
  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    DECLARE
      MESSAGE_BUF VARCHAR2(256);
      NUMBER_OF_MESSAGES NUMBER;
      ACCUM_ERROR EXCEPTION;
      X_PROJECT_ID NUMBER;
      X_RAW_COST_B NUMBER;
      X_BILLABLE_RAW_COST_B NUMBER;
      X_BURDENED_COST_B NUMBER;
      X_BILLABLE_BURDENED_COST_B NUMBER;
      X_QUANTITY_B NUMBER;
      X_LABOR_HOURS_B NUMBER;
      X_BILLABLE_QUANTITY_B NUMBER;
      X_BILLABLE_LABOR_HOURS_B NUMBER;
      X_REVENUE_B NUMBER;
      X_RAW_COST_A NUMBER;
      X_BILLABLE_RAW_COST_A NUMBER;
      X_BURDENED_COST_A NUMBER;
      X_BILLABLE_BURDENED_COST_A NUMBER;
      X_QUANTITY_A NUMBER;
      X_LABOR_HOURS_A NUMBER;
      X_BILLABLE_QUANTITY_A NUMBER;
      X_BILLABLE_LABOR_HOURS_A NUMBER;
      X_REVENUE_A NUMBER;
    BEGIN
      /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
      NUMBER_OF_MESSAGES := PA_ACCUM_SRW.GET_NUMBER_OF_PROJECTS;
      /*SRW.MESSAGE(1
                 ,'No. of Projects Accumulated = ' || TO_CHAR(NUMBER_OF_MESSAGES))*/NULL;
      BEGIN
        FOR i IN 1 .. NUMBER_OF_MESSAGES LOOP
          PA_ACCUM_SRW.REPORT_PROJECT_TXN_NUMBERS(I
                                                 ,X_PROJECT_ID
                                                 ,X_RAW_COST_B
                                                 ,X_BILLABLE_RAW_COST_B
                                                 ,X_BURDENED_COST_B
                                                 ,X_BILLABLE_BURDENED_COST_B
                                                 ,X_QUANTITY_B
                                                 ,X_LABOR_HOURS_B
                                                 ,X_BILLABLE_QUANTITY_B
                                                 ,X_BILLABLE_LABOR_HOURS_B
                                                 ,X_REVENUE_B
                                                 ,X_RAW_COST_A
                                                 ,X_BILLABLE_RAW_COST_A
                                                 ,X_BURDENED_COST_A
                                                 ,X_BILLABLE_BURDENED_COST_A
                                                 ,X_QUANTITY_A
                                                 ,X_LABOR_HOURS_A
                                                 ,X_BILLABLE_QUANTITY_A
                                                 ,X_BILLABLE_LABOR_HOURS_A
                                                 ,X_REVENUE_A);
          /*SRW.MESSAGE(1
                     ,'Project Id = ')*/NULL;
          /*SRW.MESSAGE(1
                     ,'|---------------------|---------------------------|')*/NULL;
          /*SRW.MESSAGE(1
                     ,'| ACCUMULATION COLUMN |   Before    |    After    |')*/NULL;
          /*SRW.MESSAGE(1
                     ,'|---------------------|---------------------------|')*/NULL;
          /*SRW.MESSAGE(1
                     ,'|RAW COST             ' || FMT(X_RAW_COST_B) || FMT(X_RAW_COST_A))*/NULL;
          /*SRW.MESSAGE(1
                     ,'|BILLABLE RAW COST    ' || FMT(X_BILLABLE_RAW_COST_B) || FMT(X_BILLABLE_RAW_COST_A))*/NULL;
          /*SRW.MESSAGE(1
                     ,'|BURDENED COST        ' || FMT(X_BURDENED_COST_B) || FMT(X_BURDENED_COST_A))*/NULL;
          /*SRW.MESSAGE(1
                     ,'|BILLABLE BURDENED CST' || FMT(X_BILLABLE_BURDENED_COST_B) || FMT(X_BILLABLE_BURDENED_COST_A))*/NULL;
          /*SRW.MESSAGE(1
                     ,'|QUANTITY             ' || FMT(X_QUANTITY_B) || FMT(X_QUANTITY_A))*/NULL;
          /*SRW.MESSAGE(1
                     ,'|LABOR HOURS          ' || FMT(X_LABOR_HOURS_B) || FMT(X_LABOR_HOURS_A))*/NULL;
          /*SRW.MESSAGE(1
                     ,'|BILLABLE QUANTITY    ' || FMT(X_BILLABLE_QUANTITY_B) || FMT(X_BILLABLE_QUANTITY_A))*/NULL;
          /*SRW.MESSAGE(1
                     ,'|BILLABLE LABOR HOURS ' || FMT(X_BILLABLE_LABOR_HOURS_B) || FMT(X_BILLABLE_LABOR_HOURS_A))*/NULL;
          /*SRW.MESSAGE(1
                     ,'|REVENUE              ' || FMT(X_REVENUE_B) || FMT(X_REVENUE_A))*/NULL;
          /*SRW.MESSAGE(1
                     ,'|---------------------|---------------------------|')*/NULL;
        END LOOP;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
      NUMBER_OF_MESSAGES := PA_DEBUG.NO_OF_DEBUG_MESSAGES;
      IF (P_DEBUG_MODE = 'Y' AND NUMBER_OF_MESSAGES > 0) THEN
        /*SRW.MESSAGE(1
                   ,'Debug Messages:')*/NULL;
        FOR i IN 1 .. NUMBER_OF_MESSAGES LOOP
          PA_DEBUG.GET_MESSAGE(I
                              ,MESSAGE_BUF);
          /*SRW.MESSAGE(1
                     ,MESSAGE_BUF)*/NULL;
        END LOOP;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
    END;
    RETURN (TRUE);
  END AFTERREPORT;
  FUNCTION FMT(NUMBER_IN IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN TO_CHAR(NVL(NUMBER_IN
                      ,0)
                  ,'9999999990D99');
  END FMT;
  FUNCTION CF_CORBFORMULA(PROJECT_TYPE_CLASS_CODE IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF PROJECT_TYPE_CLASS_CODE = 'CAPITAL' THEN
      RETURN P_CAPITAL;
    ELSE
      RETURN P_BILLABLE;
    END IF;
  END CF_CORBFORMULA;
  FUNCTION CF_NOTCORBFORMULA(PROJECT_TYPE_CLASS_CODE IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF PROJECT_TYPE_CLASS_CODE = 'CAPITAL' THEN
      RETURN P_NONCAPITAL;
    ELSE
      RETURN P_NONBILLABLE;
    END IF;
  END CF_NOTCORBFORMULA;
  FUNCTION C_FMT_MASKFORMULA RETURN VARCHAR2 IS
    TMP_FMT_MASK VARCHAR2(15);
  BEGIN
    TMP_FMT_MASK := PA_CURRENCY.CURRENCY_FMT_MASK(15);
    RETURN TMP_FMT_MASK;
  END C_FMT_MASKFORMULA;
  FUNCTION CF_CMT_EXCEPTIONSFORMULA(SUM_EXCEPTION_CODE IN VARCHAR2) RETURN CHAR IS
    TMP_MESSAGE VARCHAR2(255);
  BEGIN
    FND_MESSAGE.SET_NAME('PA'
                        ,SUM_EXCEPTION_CODE);
    SELECT
      SUBSTRB(FND_MESSAGE.GET
             ,1
             ,255)
    INTO TMP_MESSAGE
    FROM
      DUAL;
    RETURN TMP_MESSAGE;
  END CF_CMT_EXCEPTIONSFORMULA;
  FUNCTION CF_CMT_LINE_EXCEPTFORMULA(CMT_REJECTION_CODE IN VARCHAR2) RETURN VARCHAR2 IS
    TMP_LINE_EXCEPT VARCHAR2(255);
  BEGIN
    FND_MESSAGE.SET_NAME('PA'
                        ,CMT_REJECTION_CODE);
    SELECT
      SUBSTRB(FND_MESSAGE.GET
             ,1
             ,255)
    INTO TMP_LINE_EXCEPT
    FROM
      DUAL;
    RETURN TMP_LINE_EXCEPT;
  END CF_CMT_LINE_EXCEPTFORMULA;
  FUNCTION C_COMPANY_NAME_HEADER_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_COMPANY_NAME_HEADER;
  END C_COMPANY_NAME_HEADER_P;
  FUNCTION C_NO_DATA_FOUND_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_NO_DATA_FOUND;
  END C_NO_DATA_FOUND_P;
  FUNCTION C_DUMMY_DATA_P RETURN NUMBER IS
  BEGIN
    RETURN C_DUMMY_DATA;
  END C_DUMMY_DATA_P;
  FUNCTION C_RETCODE_P RETURN NUMBER IS
  BEGIN
    RETURN C_RETCODE;
  END C_RETCODE_P;
END PA_PAXACRTA_XMLP_PKG;


/
