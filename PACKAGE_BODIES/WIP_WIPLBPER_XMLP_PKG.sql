--------------------------------------------------------
--  DDL for Package Body WIP_WIPLBPER_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_WIPLBPER_XMLP_PKG" AS
/* $Header: WIPLBPERB.pls 120.1 2008/01/31 12:24:59 npannamp noship $ */
  FUNCTION LIMIT_EFFICIENCY(C_EFF_TOTAL_MAIN IN NUMBER) RETURN BOOLEAN IS
  BEGIN
    IF (P_MINIMUM_EFFICIENCY IS NOT NULL) THEN
      IF (P_MAXIMUM_EFFICIENCY IS NOT NULL) THEN
        IF ((C_EFF_TOTAL_MAIN >= P_MINIMUM_EFFICIENCY) AND (C_EFF_TOTAL_MAIN <= P_MAXIMUM_EFFICIENCY)) THEN
          RETURN (TRUE);
        ELSE
          RETURN (FALSE);
        END IF;
      ELSE
        RETURN (C_EFF_TOTAL_MAIN >= P_MINIMUM_EFFICIENCY);
      END IF;
    ELSE
      IF (P_MAXIMUM_EFFICIENCY IS NOT NULL) THEN
        RETURN (C_EFF_TOTAL_MAIN <= P_MAXIMUM_EFFICIENCY);
      ELSE
        RETURN (TRUE);
      END IF;
    END IF;
    RETURN NULL;
  END LIMIT_EFFICIENCY;

  FUNCTION LIMIT_DEPT RETURN CHARACTER IS
    LIMIT_DEPT VARCHAR2(80);
  BEGIN
    IF (P_FROM_DEPARTMENT IS NOT NULL) THEN
      IF (P_TO_DEPARTMENT IS NOT NULL) THEN
        LIMIT_DEPT := 'AND BD.department_code BETWEEN ''' || P_FROM_DEPARTMENT || ''' AND ''' || P_TO_DEPARTMENT || '''';
      ELSE
        LIMIT_DEPT := 'AND BD.department_code >= ''' || P_FROM_DEPARTMENT || '''';
      END IF;
    ELSE
      IF (P_TO_DEPARTMENT IS NOT NULL) THEN
        LIMIT_DEPT := 'AND BD.department_code <= ''' || P_TO_DEPARTMENT || '''';
      ELSE
        LIMIT_DEPT := '   ';
      END IF;
    END IF;
    RETURN (LIMIT_DEPT);
  END LIMIT_DEPT;

  FUNCTION LIMIT_RESOURCE RETURN CHARACTER IS
    LIMIT_RES VARCHAR2(80);
  BEGIN
    IF (P_FROM_RESOURCE IS NOT NULL) THEN
      IF (P_TO_RESOURCE IS NOT NULL) THEN
        LIMIT_RES := 'AND BR.resource_code between ''' || P_FROM_RESOURCE || ''' AND ''' || P_TO_RESOURCE || '''';
      ELSE
        LIMIT_RES := 'AND BR.resource_code >= ''' || P_FROM_RESOURCE || '''';
      END IF;
    ELSE
      IF (P_TO_RESOURCE IS NOT NULL) THEN
        LIMIT_RES := 'AND BR.resource_code <= ''' || P_TO_RESOURCE || '''';
      ELSE
        LIMIT_RES := '   ';
      END IF;
    END IF;
    RETURN (LIMIT_RES);
  END LIMIT_RESOURCE;

  FUNCTION LIMIT_JOB_DATES RETURN CHARACTER IS
    LIMIT_DATES VARCHAR2(2000);
  BEGIN
    IF (P_FROM_DATE IS NOT NULL) THEN
      IF (P_TO_DATE IS NOT NULL) THEN
        LIMIT_DATES := 'AND ((WE.ENTITY_TYPE IN (1,3)
                                          AND EXISTS
                                          (SELECT 1 FROM WIP_DISCRETE_JOBS WDJ
                                          WHERE WDJ.WIP_ENTITY_ID = WE.WIP_ENTITY_ID
                                          AND WDJ.ORGANIZATION_ID = WE.ORGANIZATION_ID
                                          AND TRUNC(WDJ.DATE_RELEASED) <= TO_DATE(''' || TO_CHAR(P_TO_DATE
                              ,'YYYYMMDD') || ''',''YYYYMMDD'') AND NVL(TRUNC(WDJ.DATE_CLOSED),TO_DATE(''' || TO_CHAR(P_FROM_DATE
                              ,'YYYYMMDD') || ''',''YYYYMMDD'')) >= TO_DATE(''' || TO_CHAR(P_FROM_DATE
                              ,'YYYYMMDD') || ''',''YYYYMMDD'')))
                                          OR (WE.ENTITY_TYPE = 2
                                          AND EXISTS
                                          (SELECT 1 FROM WIP_REPETITIVE_SCHEDULES WRS1
                                          WHERE WRS1.ORGANIZATION_ID = WE.ORGANIZATION_ID
                                          AND WRS1.REPETITIVE_SCHEDULE_ID =
                                          WOP.REPETITIVE_SCHEDULE_ID
                                        AND TRUNC(WRS1.DATE_RELEASED) <= TO_DATE(''' || TO_CHAR(P_TO_DATE
                              ,'YYYYMMDD') || ''',''YYYYMMDD'') AND NVL(TRUNC(WRS1.DATE_CLOSED),TO_DATE(''' || TO_CHAR(P_FROM_DATE
                              ,'YYYYMMDD') || ''',''YYYYMMDD'')) >= TO_DATE(''' || TO_CHAR(P_FROM_DATE
                              ,'YYYYMMDD') || ''',''YYYYMMDD''))))';
      ELSE
        LIMIT_DATES := 'AND ((WE.ENTITY_TYPE IN (1,3)
                                           AND EXISTS
                                           (SELECT 1 FROM WIP_DISCRETE_JOBS WDJ
                                           WHERE WDJ.WIP_ENTITY_ID = WE.WIP_ENTITY_ID
                                           AND WDJ.ORGANIZATION_ID = WE.ORGANIZATION_ID
                                           AND WDJ.DATE_RELEASED IS NOT NULL
                                           AND NVL(TRUNC(WDJ.DATE_CLOSED),TO_DATE(''' || TO_CHAR(P_FROM_DATE
                              ,'YYYYMMDD') || ''',''YYYYMMDD'')) >= TO_DATE(''' || TO_CHAR(P_FROM_DATE
                              ,'YYYYMMDD') || ''',''YYYYMMDD'')))
                                           OR (WE.ENTITY_TYPE = 2
                                           AND EXISTS
                                           (SELECT 1 FROM WIP_REPETITIVE_SCHEDULES WRS1
                                           WHERE WRS1.ORGANIZATION_ID = WE.ORGANIZATION_ID
                                           AND WRS1.REPETITIVE_SCHEDULE_ID =
                                                WOP.REPETITIVE_SCHEDULE_ID
                                           AND WRS1.DATE_RELEASED IS NOT NULL
                                           AND NVL(TRUNC(WRS1.DATE_CLOSED),TO_DATE(''' || TO_CHAR(P_FROM_DATE
                              ,'YYYYMMDD') || ''',''YYYYMMDD'')) >= TO_DATE(''' || TO_CHAR(P_FROM_DATE
                              ,'YYYYMMDD') || ''',''YYYYMMDD''))))';
      END IF;
    ELSE
      IF (P_TO_DATE IS NOT NULL) THEN
        LIMIT_DATES := 'AND ((WE.ENTITY_TYPE IN (1,3)
                                           AND EXISTS
                                           (SELECT 1 FROM WIP_DISCRETE_JOBS WDJ
                                           WHERE WDJ.WIP_ENTITY_ID = WE.WIP_ENTITY_ID
                                           AND WDJ.ORGANIZATION_ID = WE.ORGANIZATION_ID
                                          AND TRUNC(WDJ.DATE_RELEASED) <= TO_DATE(''' || TO_CHAR(P_TO_DATE
                              ,'YYYYMMDD') || ''',''YYYYMMDD'')))
                                           OR (WE.ENTITY_TYPE = 2
                                           AND EXISTS
                                           (SELECT 1 FROM WIP_REPETITIVE_SCHEDULES WRS1
                                           WHERE WRS1.ORGANIZATION_ID = WE.ORGANIZATION_ID
                                           AND WRS1.REPETITIVE_SCHEDULE_ID =
                                                 WOP.REPETITIVE_SCHEDULE_ID
                                       AND TRUNC(WRS1.DATE_RELEASED) <= TO_DATE(''' || TO_CHAR(P_TO_DATE
                              ,'YYYYMMDD') || ''',''YYYYMMDD''))))';
      ELSE
        LIMIT_DATES := '   ';
      END IF;
    END IF;
    RETURN (LIMIT_DATES);
  END LIMIT_JOB_DATES;

  FUNCTION C_STD_UNITSFORMULA(BASIS_TYPE IN NUMBER
                             ,USAGE_RATE1 IN NUMBER
                             ,ASSY_UNITS1 IN NUMBER
                             ,USAGE_RATE IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF (BASIS_TYPE = 1) THEN
      RETURN (ROUND((USAGE_RATE1 * ASSY_UNITS1)
                  ,P_QTY_PRECISION));
    ELSE
      IF (ASSY_UNITS1 > 0) THEN
        RETURN (USAGE_RATE);
      ELSE
        RETURN (0);
      END IF;
    END IF;
    RETURN NULL;
  END C_STD_UNITSFORMULA;

  FUNCTION C_EFFICIENCYFORMULA(APPLIED IN NUMBER
                              ,C_STD_UNITS IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF (APPLIED = 0) THEN
      RETURN (-1);
    ELSE
      RETURN (100 * C_STD_UNITS / APPLIED);
    END IF;
    RETURN NULL;
  END C_EFFICIENCYFORMULA;

  FUNCTION C_EFF_TOTAL_MAINFORMULA(C_APPLIED_TOTAL IN NUMBER
                                  ,C_STD_TOTAL IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF (C_APPLIED_TOTAL = 0) THEN
      RETURN (-1);
    ELSE
      RETURN (100 * C_STD_TOTAL / C_APPLIED_TOTAL);
    END IF;
    RETURN NULL;
  END C_EFF_TOTAL_MAINFORMULA;

  FUNCTION C_EFF_FLAGFORMULA(C_EFF_TOTAL_MAIN IN NUMBER) RETURN NUMBER IS
  BEGIN
    /*SRW.REFERENCE(C_EFF_TOTAL_MAIN)*/NULL;
    IF (LIMIT_EFFICIENCY(C_EFF_TOTAL_MAIN)) THEN
      RETURN (1);
    ELSE
      RETURN (0);
    END IF;
    RETURN NULL;
  END C_EFF_FLAGFORMULA;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
  P_FROM_DATE1:=to_char(P_FROM_DATE,'DD-MON-YY');
  P_TO_DATE1:=to_char(P_TO_DATE,'DD-MON-YY');
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    CP_CURRENCY_CODE := WIP_common_xmlp_pkg.get_precision(2);
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION C_LIMIT_DATE_FLOWFORMULA RETURN CHAR IS
    LIMIT_DATES VARCHAR2(2000);
  BEGIN
    IF (P_FROM_DATE IS NOT NULL) THEN
      IF (P_TO_DATE IS NOT NULL) THEN
        LIMIT_DATES := 'AND EXISTS
                                                 (SELECT 1 FROM WIP_FLOW_SCHEDULES WFS2
                                                  WHERE WFS2.WIP_ENTITY_ID = WF.WIP_ENTITY_ID
                                                  AND WFS2.ORGANIZATION_ID = WF.ORGANIZATION_ID
                                                  AND TRUNC(WFS2.SCHEDULED_START_DATE) <= TO_DATE(''' || TO_CHAR(P_TO_DATE
                              ,'YYYYMMDD') || ''',''YYYYMMDD'') AND NVL(TRUNC(WFS2.SCHEDULED_COMPLETION_DATE),TO_DATE(''' || TO_CHAR(P_FROM_DATE
                              ,'YYYYMMDD') || ''',''YYYYMMDD'')) >= TO_DATE(''' || TO_CHAR(P_FROM_DATE
                              ,'YYYYMMDD') || ''',''YYYYMMDD'')))';
      ELSE
        LIMIT_DATES := 'AND EXISTS
                                           (SELECT 1 FROM WIP_FLOW_SCHEDULES WFS2
                                           WHERE WFS2.ORGANIZATION_ID = WF.ORGANIZATION_ID
                                           AND WFS2.WIP_ENTITY_ID =  WF.WIP_ENTITY_ID
                                           AND WFS2.SCHEDULED_START_DATE IS NOT NULL
                                           AND NVL(TRUNC(WFS2.SCHEDULED_COMPLETION_DATE),TO_DATE(''' || TO_CHAR(P_FROM_DATE
                              ,'YYYYMMDD') || ''',''YYYYMMDD'')) >= TO_DATE(''' || TO_CHAR(P_FROM_DATE
                              ,'YYYYMMDD') || ''',''YYYYMMDD'')))';
      END IF;
    ELSE
      IF (P_TO_DATE IS NOT NULL) THEN
        LIMIT_DATES := 'AND EXISTS
                                           (SELECT 1 FROM WIP_FLOW_SCHEDULES WFS2
                                           WHERE WFS2.ORGANIZATION_ID = WF.ORGANIZATION_ID
                                           AND WFS2.WIP_ENTITY_ID = WF.WIP_ENTITY_ID
                                           AND TRUNC(WFS2.SCHEDULED_START_DATE) <= TO_DATE(''' || TO_CHAR(P_TO_DATE
                              ,'YYYYMMDD') || ''',''YYYYMMDD'')))';
      ELSE
        LIMIT_DATES := ' ';
      END IF;
    END IF;
    RETURN (LIMIT_DATES);
  END C_LIMIT_DATE_FLOWFORMULA;

END WIP_WIPLBPER_XMLP_PKG;


/
