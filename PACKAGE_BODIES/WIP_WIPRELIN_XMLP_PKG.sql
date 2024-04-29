--------------------------------------------------------
--  DDL for Package Body WIP_WIPRELIN_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_WIPRELIN_XMLP_PKG" AS
/* $Header: WIPRELINB.pls 120.2 2008/01/31 12:37:30 npannamp noship $ */
  FUNCTION LIMIT_LINES RETURN CHARACTER IS
    LIMIT_LINES VARCHAR2(80);
  BEGIN
    IF (P_FROM_LINE IS NOT NULL) THEN
      IF (P_TO_LINE IS NOT NULL) THEN
        LIMIT_LINES := ' AND WL.LINE_CODE BETWEEN ''' || P_FROM_LINE || ''' AND ''' || P_TO_LINE || ''' ';
      ELSE
        LIMIT_LINES := ' AND WL.LINE_CODE  >= ''' || P_FROM_LINE || ''' ';
      END IF;
    ELSE
      IF (P_TO_LINE IS NOT NULL) THEN
        LIMIT_LINES := ' AND WL.LINE_CODE  <= ''' || P_TO_LINE || ''' ';
      ELSE
        LIMIT_LINES := ' ';
      END IF;
    END IF;
    RETURN (LIMIT_LINES);
  END LIMIT_LINES;

  FUNCTION LIMIT_JOBS RETURN CHARACTER IS
    LIMIT_JOBS VARCHAR2(500);
  BEGIN
    IF (P_FROM_JOB IS NOT NULL) THEN
      IF (P_TO_JOB IS NOT NULL) THEN
        LIMIT_JOBS := ' AND WE.WIP_ENTITY_NAME BETWEEN ''' || P_FROM_JOB || ''' AND ''' || P_TO_JOB || '''';
      ELSE
        LIMIT_JOBS := ' AND WE.WIP_ENTITY_NAME  >= ''' || P_FROM_JOB || '''';
      END IF;
    ELSE
      IF (P_TO_JOB IS NOT NULL) THEN
        LIMIT_JOBS := ' AND WE.WIP_ENTITY_NAME <= ''' || P_TO_JOB || '''';
      ELSE
        LIMIT_JOBS := '  ';
      END IF;
    END IF;
    RETURN (LIMIT_JOBS);
  END LIMIT_JOBS;

  FUNCTION LIMIT_DATES RETURN CHARACTER IS
    LIMIT_DATES VARCHAR2(1000);
  BEGIN
    IF (P_FROM_DATE IS NOT NULL) THEN
      IF (P_TO_DATE IS NOT NULL) THEN
        LIMIT_DATES := ' AND (((TRUNC(RS.FIRST_UNIT_START_DATE) < TO_DATE(''' || TO_CHAR(P_FROM_DATE
                              ,'YYYYMMDD') || ''',''YYYYMMDD'')) AND (TRUNC(RS.LAST_UNIT_COMPLETION_DATE) >= TO_DATE(''' || TO_CHAR(P_TO_DATE
                              ,'YYYYMMDD') || ''',''YYYYMMDD'')))' || ' OR ((TRUNC(RS.FIRST_UNIT_START_DATE) >= TO_DATE(''' || TO_CHAR(P_FROM_DATE
                              ,'YYYYMMDD') || ''',''YYYYMMDD'')) AND (TRUNC(RS.LAST_UNIT_COMPLETION_DATE) <= TO_DATE(''' || TO_CHAR(P_TO_DATE
                              ,'YYYYMMDD') || ''',''YYYYMMDD'')))' || ' OR ((TRUNC(RS.FIRST_UNIT_START_DATE) <= TO_DATE(''' || TO_CHAR(P_FROM_DATE
                              ,'YYYYMMDD') || ''',''YYYYMMDD'')) AND (TRUNC(RS.LAST_UNIT_COMPLETION_DATE) > TO_DATE(''' || TO_CHAR(P_TO_DATE
                              ,'YYYYMMDD') || ''',''YYYYMMDD'')))' || ' OR ((TRUNC(RS.FIRST_UNIT_START_DATE) <= TO_DATE(''' || TO_CHAR(P_FROM_DATE
                              ,'YYYYMMDD') || ''',''YYYYMMDD'')) AND (TRUNC(RS.LAST_UNIT_COMPLETION_DATE) >= TO_DATE(''' || TO_CHAR(P_TO_DATE
                              ,'YYYYMMDD') || ''',''YYYYMMDD''))))';
      ELSE
        LIMIT_DATES := ' AND TRUNC(RS.LAST_UNIT_COMPLETION_DATE) >= TO_DATE(''' || TO_CHAR(P_FROM_DATE
                              ,'YYYYMMDD') || ''',''YYYYMMDD'') ';
      END IF;
    ELSE
      IF (P_TO_DATE IS NOT NULL) THEN
        LIMIT_DATES := ' AND TRUNC(RS.FIRST_UNIT_START_DATE) <= TO_DATE(''' || TO_CHAR(P_TO_DATE
                              ,'YYYYMMDD') || ''',''YYYYMMDD'') ';
      ELSE
        LIMIT_DATES := ' ';
      END IF;
    END IF;
    RETURN (LIMIT_DATES);
  END LIMIT_DATES;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
  qty_precision:=wip_common_xmlp_pkg.get_precision(P_qty_precision);
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    RETURN (TRUE);
  END BEFOREREPORT;

END WIP_WIPRELIN_XMLP_PKG;


/
