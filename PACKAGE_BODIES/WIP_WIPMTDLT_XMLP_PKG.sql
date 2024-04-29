--------------------------------------------------------
--  DDL for Package Body WIP_WIPMTDLT_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_WIPMTDLT_XMLP_PKG" AS
/* $Header: WIPMTDLTB.pls 120.0 2007/12/24 10:02:04 npannamp noship $ */
function BeforeReport return boolean is
begin
P_FROM_DATE1:=to_char(P_FROM_DATE,'DD-MON-YY');
P_TO_DATE1:=to_char(P_TO_DATE,'DD-MON-YY');
 return (TRUE);
end;
  FUNCTION LIMIT_JOBS RETURN CHARACTER IS
    LIMIT_JOBS VARCHAR2(500);
  BEGIN
    IF (P_FROM_JOB IS NOT NULL) THEN
      IF (P_TO_JOB IS NOT NULL) THEN
        LIMIT_JOBS := ' AND WE.wip_entity_name BETWEEN ''' || P_FROM_JOB || ''' AND ''' || P_TO_JOB || '''';
      ELSE
        LIMIT_JOBS := ' AND WE.wip_entity_name >= ''' || P_FROM_JOB || '''';
      END IF;
    ELSE
      IF (P_TO_JOB IS NOT NULL) THEN
        LIMIT_JOBS := ' AND WE.wip_entity_name <= ''' || P_TO_JOB || '''';
      ELSE
        LIMIT_JOBS := '   ';
      END IF;
    END IF;
    RETURN (LIMIT_JOBS);
  END LIMIT_JOBS;

  FUNCTION LIMIT_ASSEMBLYFORMULA RETURN VARCHAR2 IS
  BEGIN
    BEGIN
      IF (P_FLEXWHERE IS NOT NULL) THEN
        RETURN ('AND ');
      ELSE
        RETURN ('  ');
      END IF;
    END;
    RETURN NULL;
  END LIMIT_ASSEMBLYFORMULA;

  FUNCTION LIMIT_LOTS RETURN CHARACTER IS
    LIMIT_LOTS VARCHAR2(500);
  BEGIN
    IF (P_FROM_LOT IS NOT NULL) THEN
      IF (P_TO_LOT IS NOT NULL) THEN
        LIMIT_LOTS := ' AND DJ.lot_number BETWEEN ''' || P_FROM_LOT || ''' AND ''' || P_TO_LOT || '''';
      ELSE
        LIMIT_LOTS := ' AND DJ.lot_number >= ''' || P_FROM_LOT || '''';
      END IF;
    ELSE
      IF (P_TO_LOT IS NOT NULL) THEN
        LIMIT_LOTS := ' AND DJ.lot_number <= ''' || P_TO_LOT || '''';
      ELSE
        LIMIT_LOTS := '  ';
      END IF;
    END IF;
    RETURN (LIMIT_LOTS);
  END LIMIT_LOTS;

  FUNCTION SORT_OPTION RETURN CHARACTER IS
    SORT_OPTION VARCHAR2(80);
  BEGIN
    IF (P_SORT = 1) THEN
      SORT_OPTION := 'ORDER BY WE.wip_entity_name, DJ.lot_number';
    ELSE
      IF (P_SORT = 2) THEN
        SORT_OPTION := 'ORDER BY DJ.lot_number, WE.wip_entity_name';
      END IF;
    END IF;
    RETURN (SORT_OPTION);
  END SORT_OPTION;

  FUNCTION LIMIT_DATES RETURN CHARACTER IS
    LIMIT_DATES VARCHAR2(120);
  BEGIN
    IF (P_FROM_DATE IS NOT NULL) THEN
      IF (P_TO_DATE IS NOT NULL) THEN
        LIMIT_DATES := ' AND TRUNC(DJ.date_released) BETWEEN TO_DATE(''' || TO_CHAR(P_FROM_DATE
                              ,'YYYYMMDD') || ''',''YYYYMMDD'') AND TO_DATE(''' || TO_CHAR(P_TO_DATE
                              ,'YYYYMMDD') || ''',''YYYYMMDD'')';
      ELSE
        LIMIT_DATES := ' AND TRUNC(DJ.date_released) >= TO_DATE(''' || TO_CHAR(P_FROM_DATE
                              ,'YYYYMMDD') || ''',''YYYYMMDD'')';
      END IF;
    ELSE
      IF (P_TO_DATE IS NOT NULL) THEN
        LIMIT_DATES := ' AND TRUNC(DJ.date_released) <= TO_DATE(''' || TO_CHAR(P_TO_DATE
                              ,'YYYYMMDD') || ''',''YYYYMMDD'')';
      ELSE
        LIMIT_DATES := '  ';
      END IF;
    END IF;
    RETURN (LIMIT_DATES);
  END LIMIT_DATES;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION C_SORT_SUM RETURN CHARACTER IS
    C_SORT_SUM VARCHAR2(80);
  BEGIN
    IF (P_SORT = 1) THEN
      C_SORT_SUM := 'Job';
    ELSE
      IF (P_SORT = 2) THEN
        C_SORT_SUM := 'Lot';
      ELSE
        C_SORT_SUM := 'Illegal sort';
      END IF;
    END IF;
    RETURN (C_SORT_SUM);
  END C_SORT_SUM;

  FUNCTION C_COMP_ORDERFORMULA(C_ASSY_FLEX IN VARCHAR2
                              ,COMPONENT IN VARCHAR2
                              ,C_COMP_ORDER IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    BEGIN
      /*SRW.REFERENCE(C_ASSY_FLEX)*/NULL;
      /*SRW.REFERENCE(COMPONENT)*/NULL;
      RETURN (C_COMP_ORDER);
    END;
    RETURN NULL;
  END C_COMP_ORDERFORMULA;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    IF P_ASSEMBLY IS NOT NULL THEN
      P_OUTER := ' ';
    END IF;
    RETURN (TRUE);
  END AFTERPFORM;

END WIP_WIPMTDLT_XMLP_PKG;



/
