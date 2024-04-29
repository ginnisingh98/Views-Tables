--------------------------------------------------------
--  DDL for Package Body WIP_WIPMTLCT_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_WIPMTLCT_XMLP_PKG" AS
/* $Header: WIPMTLCTB.pls 120.1 2008/01/31 12:29:25 npannamp noship $ */
  FUNCTION LIMIT_JOBS RETURN CHARACTER IS
    LIMIT_JOBS VARCHAR2(500);
  BEGIN
    IF (P_FROM_JOB_ID IS NOT NULL) THEN
      IF (P_TO_JOB_ID IS NOT NULL) THEN
        LIMIT_JOBS := ' AND WE.wip_entity_name BETWEEN ''' || P_FROM_JOB_ID || ''' AND ''' || P_TO_JOB_ID || '''';
      ELSE
        LIMIT_JOBS := ' AND WE.wip_entity_name >= ''' || P_FROM_JOB_ID || '''';
      END IF;
    ELSE
      IF (P_TO_JOB_ID IS NOT NULL) THEN
        LIMIT_JOBS := ' AND WE.wip_entity_name <= ''' || P_TO_JOB_ID || '''';
      ELSE
        LIMIT_JOBS := ' ';
      END IF;
    END IF;
    RETURN (LIMIT_JOBS);
  END LIMIT_JOBS;

  FUNCTION LIMIT_LINES RETURN CHARACTER IS
    LIMIT_LINES VARCHAR2(500);
  BEGIN
    IF (P_FROM_LINE IS NOT NULL) THEN
      IF (P_TO_LINE IS NOT NULL) THEN
        LIMIT_LINES := ' AND WL.line_code BETWEEN ''' || P_FROM_LINE || ''' AND ''' || P_TO_LINE || '''';
      ELSE
        LIMIT_LINES := ' AND WL.line_code >= ''' || P_FROM_LINE || '''';
      END IF;
    ELSE
      IF (P_TO_LINE IS NOT NULL) THEN
        LIMIT_LINES := ' AND WL.line_code <= ''' || P_TO_LINE || '''';
      ELSE
        LIMIT_LINES := ' ';
      END IF;
    END IF;
    RETURN (LIMIT_LINES);
  END LIMIT_LINES;

  FUNCTION LIMIT_ASSEMBLYFORMULA RETURN VARCHAR2 IS
  BEGIN
    BEGIN
      IF (P_FLEXWHERE IS NOT NULL) THEN
        RETURN ('AND ');
      ELSE
        RETURN ('  ');
      END IF;
    END;
    RETURN ' ';
  END LIMIT_ASSEMBLYFORMULA;

  FUNCTION LIMIT_DEPARTMENTS RETURN CHARACTER IS
    LIMIT_DEPARTMENTS VARCHAR2(500);
  BEGIN
    IF (P_FROM_DEPARTMENT_ID IS NOT NULL) THEN
      IF (P_TO_DEPARTMENT_ID IS NOT NULL) THEN
        LIMIT_DEPARTMENTS := ' AND DE.department_code BETWEEN ''' || P_FROM_DEPARTMENT_ID || ''' AND ''' || P_TO_DEPARTMENT_ID || '''';
      ELSE
        LIMIT_DEPARTMENTS := ' AND DE.department_code >= ''' || P_FROM_DEPARTMENT_ID || '''';
      END IF;
    ELSE
      IF (P_TO_DEPARTMENT_ID IS NOT NULL) THEN
        LIMIT_DEPARTMENTS := ' AND DE.department_code <= ''' || P_TO_DEPARTMENT_ID || '''';
      ELSE
        LIMIT_DEPARTMENTS := ' ';
      END IF;
    END IF;
    RETURN (LIMIT_DEPARTMENTS);
  END LIMIT_DEPARTMENTS;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    /*SRW.USER_EXIT('FND FLEXSQL CODE="MSTK"
                                             APPL_SHORT_NAME="INV",
                                             OUTPUT=":P_ASSY_FLEX"
                                             MODE="SELECT"
                                             DISPLAY="ALL"
                                             TABLEALIAS="MSI"')*/NULL;
    IF (P_FROM_ASSEMBLY_ID IS NOT NULL) THEN
      IF (P_TO_ASSEMBLY_ID IS NOT NULL) THEN
        NULL;
      ELSE
        NULL;
      END IF;
    ELSE
      IF (P_TO_ASSEMBLY_ID IS NOT NULL) THEN
        NULL;
      END IF;
    END IF;
    RETURN (TRUE);
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION C_ORDER1 RETURN CHARACTER IS
    C_ORDER1 VARCHAR2(80);
  BEGIN
    IF (P_SORT = 1) THEN
      C_ORDER1 := 'ORDER BY WE.wip_entity_name, ';
    ELSE
      IF (P_SORT = 2) THEN
        C_ORDER1 := 'ORDER BY ';
      ELSE
        IF (P_SORT = 3) THEN
          C_ORDER1 := 'ORDER BY DE.department_code, ';
        ELSE
          IF (P_SORT = 4) THEN
            C_ORDER1 := 'ORDER BY WL.line_code, ';
          END IF;
        END IF;
      END IF;
    END IF;
    RETURN (C_ORDER1);
  END C_ORDER1;

  FUNCTION C_ORDER2 RETURN CHARACTER IS
    C_ORDER2 VARCHAR2(80);
  BEGIN
    IF (P_SORT = 1) THEN
      C_ORDER2 := ', WL.line_code, WO.operation_seq_num';
    ELSE
      IF (P_SORT = 2) THEN
        C_ORDER2 := ', WE.wip_entity_name, WL.line_code, WO.operation_seq_num';
      ELSE
        IF (P_SORT = 3) THEN
          C_ORDER2 := ', WE.wip_entity_name, WO.operation_seq_num';
        ELSE
          IF (P_SORT = 4) THEN
            C_ORDER2 := ', WE.wip_entity_name, WO.operation_seq_num';
          END IF;
        END IF;
      END IF;
    END IF;
    RETURN (C_ORDER2);
  END C_ORDER2;

  FUNCTION C_ASSY_ORDER RETURN CHARACTER IS
    C_ASSY_ORDER VARCHAR2(850);
  BEGIN
    C_ASSY_ORDER := 'Assembly';
    RETURN (C_ASSY_ORDER);
  END C_ASSY_ORDER;

  FUNCTION C_SORT_LIST RETURN CHARACTER IS
    C_SORT_LIST VARCHAR2(80);
  BEGIN
    IF (P_SORT = 1) THEN
      C_SORT_LIST := 'Job/Schedule, Assembly, Line, OpSeq';
    ELSE
      IF (P_SORT = 2) THEN
        C_SORT_LIST := 'Assembly, Job/Schedule, Line, OpSeq';
      ELSE
        IF (P_SORT = 3) THEN
          C_SORT_LIST := 'Department, Assembly, Job/Schedule, OpSeq';
        ELSE
          IF (P_SORT = 4) THEN
            C_SORT_LIST := 'Line, Assembly, Job/Schedule, OpSeq';
          END IF;
        END IF;
      END IF;
    END IF;
    RETURN (C_SORT_LIST);
  END C_SORT_LIST;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END AFTERPFORM;

END WIP_WIPMTLCT_XMLP_PKG;


/
