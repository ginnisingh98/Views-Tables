--------------------------------------------------------
--  DDL for Package Body PA_PAXFRADR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PAXFRADR_XMLP_PKG" AS
/* $Header: PAXFRADRB.pls 120.0 2008/01/02 11:33:00 krreddy noship $ */
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
      L_NO_DATA_FOUND VARCHAR2(80);
      L_NO_REPORT_DATA VARCHAR2(100);
      L_MSG_COUNT NUMBER;
      L_MSG_DATA VARCHAR2(200);
      L_RETURN_STATUS VARCHAR2(10);
      L_EXIST_FLAG VARCHAR2(2);
    BEGIN
      /*SRW.MESSAGE(1
                 ,'Started Before Report Function')*/NULL;
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
      IF P_FROM_PROJECT_NUMBER IS NOT NULL THEN
        BEGIN
          SELECT
            SEGMENT1
          INTO P_FROM_PROJECT_NUMBER
          FROM
            PA_PROJECTS_ALL
          WHERE PROJECT_ID = P_FROM_PROJECT_NUMBER;
        END;
      END IF;
      IF P_TO_PROJECT_NUMBER IS NOT NULL THEN
        BEGIN
          SELECT
            SEGMENT1
          INTO P_TO_PROJECT_NUMBER
          FROM
            PA_PROJECTS_ALL
          WHERE PROJECT_ID = P_TO_PROJECT_NUMBER;
        END;
      END IF;
      IF P_PROJ_TYPE IS NOT NULL THEN
        BEGIN
          SELECT
            PROJECT_TYPE
          INTO P_PROJ_TYPE
          FROM
            PA_PROJECT_TYPES_ALL
          WHERE PROJECT_TYPE_ID = P_PROJ_TYPE;
        END;
      END IF;
      /*SRW.MESSAGE(1
                 ,'From Project Number : ' || P_FROM_PROJECT_NUMBER)*/NULL;
      /*SRW.MESSAGE(1
                 ,'To Project Number   : ' || P_TO_PROJECT_NUMBER)*/NULL;
      BEGIN
        L_EXIST_FLAG := 'Y';
        BEGIN
          SELECT
            DISTINCT
            'N'
          INTO L_EXIST_FLAG
          FROM
            PA_PROJECTS P
          WHERE P.SEGMENT1 BETWEEN NVL(P_FROM_PROJECT_NUMBER
             ,'0')
            AND NVL(P_TO_PROJECT_NUMBER
             ,'z')
            AND P.PROJECT_TYPE = NVL(P_PROJ_TYPE
             ,P.PROJECT_TYPE)
            AND ( NVL(REVALUATE_FUNDING_FLAG
             ,'N') = 'N'
            AND NOT EXISTS (
            SELECT
              F.PROJECT_ID
            FROM
              PA_PROJECT_FUNDINGS F
            WHERE P.PROJECT_ID = F.PROJECT_ID
              AND REVALUATION_THROUGH_DATE between NVL(TRUNC(P_REVAL_FROM_DATE)
               ,SYSDATE - 10000)
              AND NVL(TRUNC(P_REVAL_TO_DATE)
               ,SYSDATE + 10000) ) );
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            L_EXIST_FLAG := 'Y';
        END;
        BEGIN
          SELECT
            DISTINCT
            'Y'
          INTO L_EXIST_FLAG
          FROM
            PA_PROJECTS P
          WHERE P.SEGMENT1 BETWEEN NVL(P_FROM_PROJECT_NUMBER
             ,'0')
            AND NVL(P_TO_PROJECT_NUMBER
             ,'z')
            AND P.PROJECT_TYPE = NVL(P_PROJ_TYPE
             ,P.PROJECT_TYPE)
            AND ( NVL(REVALUATE_FUNDING_FLAG
             ,'N') = 'Y'
          OR EXISTS (
            SELECT
              F.PROJECT_ID
            FROM
              PA_PROJECT_FUNDINGS F
            WHERE P.PROJECT_ID = F.PROJECT_ID
              AND REVALUATION_THROUGH_DATE between NVL(TRUNC(P_REVAL_FROM_DATE)
               ,SYSDATE - 10000)
              AND NVL(TRUNC(P_REVAL_TO_DATE)
               ,SYSDATE + 10000) ) );
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            NULL;
        END;
        IF L_EXIST_FLAG = 'N' THEN
          SELECT
            MESSAGE_TEXT
          INTO L_NO_REPORT_DATA
          FROM
            FND_NEW_MESSAGES
          WHERE MESSAGE_NAME = 'R_REP_NO_DATA';
          C_NO_REPORT_DATA := L_NO_REPORT_DATA;
        END IF;
      END;
      SELECT
        MEANING
      INTO L_NO_DATA_FOUND
      FROM
        PA_LOOKUPS
      WHERE LOOKUP_CODE = 'NO_DATA_FOUND'
        AND LOOKUP_TYPE = 'MESSAGE';
      C_NO_DATA_FOUND := L_NO_DATA_FOUND;
      IF P_MODE IS NULL THEN
        P_MODE := 'D';
      END IF;
      /*SRW.MESSAGE(1
                 ,'Checking and Setting for Debug mode. Value : ' || P_DEBUG_MODE)*/NULL;
      IF P_DEBUG_MODE = 'Y' THEN
        PA_DEBUG.SET_PROCESS('PLSQL'
                            ,'LOG'
                            ,'Y');
        PA_DEBUG.ENABLE_DEBUG;
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        C_DUMMY_DATA := 1;
      WHEN OTHERS THEN
        /*SRW.MESSAGE(1
                   ,'Error: From When-Others in Before Report')*/NULL;
        /*SRW.MESSAGE(1
                   ,SQLERRM)*/NULL;
        /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
    END;
    LP_FROM_PROJECT_NUMBER:=P_FROM_PROJECT_NUMBER;
    LP_TO_PROJECT_NUMBER:=P_TO_PROJECT_NUMBER;
    LP_REVAL_FROM_DATE:=to_char(P_REVAL_FROM_DATE,'DD-MON-YY');
    LP_REVAL_TO_DATE:=to_char(P_REVAL_TO_DATE,'DD-MON-YY');
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION P_MODEVALIDTRIGGER RETURN BOOLEAN IS
  BEGIN
    BEGIN
      SELECT
        MEANING
      INTO P_REPORT_MODE
      FROM
        FND_LOOKUP_VALUES
      WHERE LOOKUP_TYPE = 'REPORT_TYPE_SD'
        AND LOOKUP_CODE = NVL(P_MODE
         ,'D');
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        /*SRW.MESSAGE(1
                   ,'No Data found for Report Type Mode')*/NULL;
      WHEN OTHERS THEN
        /*SRW.MESSAGE(1
                   ,'Others for Report Type Mode')*/NULL;
    END;
    RETURN (TRUE);
  END P_MODEVALIDTRIGGER;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

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

  FUNCTION C_RETCODE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_RETCODE;
  END C_RETCODE_P;

  FUNCTION CURR_CODE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CURR_CODE;
  END CURR_CODE_P;

  FUNCTION C_ERROR_BUF_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_ERROR_BUF;
  END C_ERROR_BUF_P;

  FUNCTION C_NO_REPORT_DATA_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_NO_REPORT_DATA;
  END C_NO_REPORT_DATA_P;

END PA_PAXFRADR_XMLP_PKG;


/
