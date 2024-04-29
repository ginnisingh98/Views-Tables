--------------------------------------------------------
--  DDL for Package Body AR_RAXICI_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_RAXICI_XMLP_PKG" AS
/* $Header: RAXICIB.pls 120.0 2007/12/27 14:21:51 abraghun noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION REPORT_NAMEFORMULA(COMPANY_NAME IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      L_REPORT_NAME VARCHAR2(80);
    BEGIN
      RP_COMPANY_NAME := COMPANY_NAME;
      SELECT
        SUBSTR(CP.USER_CONCURRENT_PROGRAM_NAME
              ,1
              ,80)
      INTO L_REPORT_NAME
      FROM
        FND_CONCURRENT_PROGRAMS_VL CP,
        FND_CONCURRENT_REQUESTS CR
      WHERE CR.REQUEST_ID = P_CONC_REQUEST_ID
        AND CP.APPLICATION_ID = CR.PROGRAM_APPLICATION_ID
        AND CP.CONCURRENT_PROGRAM_ID = CR.CONCURRENT_PROGRAM_ID;
      RP_REPORT_NAME := L_REPORT_NAME;
      RETURN (L_REPORT_NAME);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RP_REPORT_NAME := NULL;
        RETURN (NULL);
    END;
    RETURN NULL;
  END REPORT_NAMEFORMULA;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    DECLARE
      L_START_GL_DATE VARCHAR2(11);
      L_END_GL_DATE VARCHAR2(11);
    BEGIN
      PH_START_GL_DATE := TO_CHAR(P_START_GL_DATE
                                 ,'DD-MON-YYYY');
      PH_END_GL_DATE := TO_CHAR(P_END_GL_DATE
                               ,'DD-MON-YYYY');
      IF P_START_GL_DATE IS NOT NULL AND P_END_GL_DATE IS NOT NULL THEN
        LP_WHERE := ' and head_dist.gl_date BETWEEN :p_start_gl_date AND :p_end_gl_date
                                      and dist.gl_date BETWEEN :p_start_gl_date AND :p_end_gl_date ';
      END IF;
      IF P_START_GL_DATE IS NOT NULL AND P_END_GL_DATE IS NULL THEN
        LP_WHERE := ' and head_dist.gl_date >= :p_start_gl_date
                                      and dist.gl_date >= :p_start_gl_date ';
      END IF;
      IF P_START_GL_DATE IS NULL AND P_END_GL_DATE IS NOT NULL THEN
        LP_WHERE := ' and head_dist.gl_date <= :p_end_gl_date
                                      and dist.gl_date <= :p_end_gl_date ';
      END IF;
    END;
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION RP_GL_DATE_RANGEFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      L_TEMP VARCHAR2(200);
      L_START_GL_DATE VARCHAR2(50);
      L_END_GL_DATE VARCHAR2(50);
    BEGIN
      IF P_START_GL_DATE IS NULL THEN
        L_START_GL_DATE := '   ';
      ELSE
        L_START_GL_DATE := PH_START_GL_DATE;
      END IF;
      IF P_END_GL_DATE IS NULL THEN
        L_END_GL_DATE := '   ';
      ELSE
        L_END_GL_DATE := PH_END_GL_DATE;
      END IF;
      L_TEMP := ARP_STANDARD.FND_MESSAGE('AR_REPORTS_GL_DATE_FROM_TO'
                                        ,'FROM_DATE'
                                        ,L_START_GL_DATE
                                        ,'TO_DATE'
                                        ,L_END_GL_DATE);
      RETURN (L_TEMP);
    END;
    RETURN NULL;
  END RP_GL_DATE_RANGEFORMULA;

  FUNCTION C_DATA_NOT_FOUNDFORMULA(CLASS IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RP_DATA_FOUND := CLASS;
    RETURN (0);
  END C_DATA_NOT_FOUNDFORMULA;

  FUNCTION CF_ACC_MESSAGEFORMULA(ORG_ID IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF ARP_UTIL.OPEN_PERIOD_EXISTS('3000'
                               ,ORG_ID
                               ,P_START_GL_DATE
                               ,P_END_GL_DATE) THEN
      FND_MESSAGE.SET_NAME('AR'
                          ,'AR_REPORT_ACC_NOT_GEN');
      CP_ACC_MESSAGE := FND_MESSAGE.GET;
    ELSE
      CP_ACC_MESSAGE := NULL;
    END IF;
    RETURN 0;
  END CF_ACC_MESSAGEFORMULA;

  FUNCTION ACCT_BAL_APROMPT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN ACCT_BAL_APROMPT;
  END ACCT_BAL_APROMPT_P;

  FUNCTION RP_COMPANY_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_COMPANY_NAME;
  END RP_COMPANY_NAME_P;

  FUNCTION RP_REPORT_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_REPORT_NAME;
  END RP_REPORT_NAME_P;

  FUNCTION RP_DATA_FOUND_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_DATA_FOUND;
  END RP_DATA_FOUND_P;

  FUNCTION CP_ACC_MESSAGE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_ACC_MESSAGE;
  END CP_ACC_MESSAGE_P;

END AR_RAXICI_XMLP_PKG;


/