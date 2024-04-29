--------------------------------------------------------
--  DDL for Package Body WIP_WIPSUEMP_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_WIPSUEMP_XMLP_PKG" AS
/* $Header: WIPSUEMPB.pls 120.1 2008/01/31 12:43:56 npannamp noship $ */
  FUNCTION EMPLOYEE_TABLE RETURN CHARACTER IS
  BEGIN
    IF (P_CURRENT_ONLY = 1) THEN
      RETURN ('MTL_EMPLOYEES_CURRENT_VIEW');
    ELSE
      RETURN ('MTL_EMPLOYEES_VIEW');
    END IF;
    RETURN ' ';
  END EMPLOYEE_TABLE;

  FUNCTION LIMIT_EMPLOYEE RETURN CHARACTER IS
    LIMIT_EMP VARCHAR2(500);
  BEGIN
    IF (P_FROM_EMPLOYEE IS NOT NULL) THEN
      IF (P_TO_EMPLOYEE IS NOT NULL) THEN
        LIMIT_EMP := 'AND hre.full_name between ''' || REPLACE(P_FROM_EMPLOYEE
                            ,''''
                            ,'''''') || ''' AND ''' || REPLACE(P_TO_EMPLOYEE
                            ,''''
                            ,'''''') || '''';
      ELSE
        LIMIT_EMP := 'AND hre.full_name >= ''' || REPLACE(P_FROM_EMPLOYEE
                            ,''''
                            ,'''''') || '''';
      END IF;
    ELSE
      IF (P_TO_EMPLOYEE IS NOT NULL) THEN
        LIMIT_EMP := 'AND hre.full_name <= ''' || REPLACE(P_TO_EMPLOYEE
                            ,''''
                            ,'''''') || '''';
      ELSE
        LIMIT_EMP := ' ';
      END IF;
    END IF;
    RETURN (LIMIT_EMP);
  END LIMIT_EMPLOYEE;

  FUNCTION LIMIT_DATES RETURN CHARACTER IS
    LIMIT_DATES VARCHAR2(120);
  BEGIN
    IF (P_FROM_DATE IS NOT NULL) THEN
      IF (P_TO_DATE IS NOT NULL) THEN
        LIMIT_DATES := ' AND TRUNC(w1.effective_date) BETWEEN  TO_DATE(''' || TO_CHAR(P_FROM_DATE
                              ,'YYYYMMDD') || ''',''YYYYMMDD'') AND  TO_DATE(''' || TO_CHAR(P_TO_DATE
                              ,'YYYYMMDD') || ''',''YYYYMMDD'')';
      ELSE
        LIMIT_DATES := ' AND TRUNC(w1.effective_date) >=  TO_DATE(''' || TO_CHAR(P_FROM_DATE
                              ,'YYYYMMDD') || ''',''YYYYMMDD'')';
      END IF;
    ELSE
      IF (P_TO_DATE IS NOT NULL) THEN
        LIMIT_DATES := ' AND TRUNC(w1.effective_date) <=  TO_DATE(''' || TO_CHAR(P_TO_DATE
                              ,'YYYYMMDD') || ''',''YYYYMMDD'')';
      ELSE
        LIMIT_DATES := ' ';
      END IF;
    END IF;
    RETURN (LIMIT_DATES);
  END LIMIT_DATES;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    SELECT
      CURRENCY_CODE
    INTO P_CURR_CODE
    FROM
      GL_SETS_OF_BOOKS G,
      ORG_ORGANIZATION_DEFINITIONS O
    WHERE G.SET_OF_BOOKS_ID = O.SET_OF_BOOKS_ID
      AND O.ORGANIZATION_ID = P_ORGANIZATION_ID;
    SELECT
      NVL(C.EXTENDED_PRECISION
         ,C.PRECISION)
    INTO P_PRECISION
    FROM
      ORG_ORGANIZATION_DEFINITIONS O,
      FND_CURRENCIES C
    WHERE O.ORGANIZATION_ID = P_ORGANIZATION_ID
      AND C.CURRENCY_CODE = P_CURR_CODE;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION C_SUBTITLEFORMULA(P_CURRENCY_CODE IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN ('(' || P_CURRENCY_CODE || ')');
  END C_SUBTITLEFORMULA;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END AFTERPFORM;

END WIP_WIPSUEMP_XMLP_PKG;



/
