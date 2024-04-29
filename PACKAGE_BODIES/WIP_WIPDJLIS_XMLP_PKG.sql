--------------------------------------------------------
--  DDL for Package Body WIP_WIPDJLIS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_WIPDJLIS_XMLP_PKG" AS
/* $Header: WIPDJLISB.pls 120.1 2008/01/31 12:17:26 npannamp noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      SELECT fifst.id_flex_num
into p_item_flex_num
FROM fnd_id_flex_structures fifst
WHERE fifst.application_id = 401
AND fifst.id_flex_code = 'MSTK'
AND fifst.enabled_flag = 'Y'
AND fifst.freeze_flex_definition_flag = 'Y'
and rownum<2;
      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
      /*SRW.USER_EXIT('FND FLEXSQL CODE="MSTK"
                                  APPL_SHORT_NAME="INV" OUTPUT=":P_ITEM_DATA"
                                  MODE="SELECT" DISPLAY="ALL" TABLEALIAS="SI"')*/NULL;
      IF (P_FROM_ASSEMBLY IS NOT NULL) THEN
        IF (P_TO_ASSEMBLY IS NOT NULL) THEN
          NULL;
        ELSE
          NULL;
        END IF;
      ELSE
        IF (P_TO_ASSEMBLY IS NOT NULL) THEN
          NULL;
        END IF;
      END IF;
      RETURN TRUE;
    END;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION DATE_LIMITER RETURN CHARACTER IS
    LIMIT_DATES VARCHAR2(120);
  BEGIN
    IF (P_FROM_START_DATE IS NOT NULL) THEN
      IF (P_TO_START_DATE IS NOT NULL) THEN
        LIMIT_DATES := ' AND TRUNC(DJ.SCHEDULED_START_DATE) BETWEEN TO_DATE(''' || TO_CHAR(P_FROM_START_DATE
                              ,'YYYYMMDD') || ''',''YYYYMMDD'') AND TO_DATE(''' || TO_CHAR(P_TO_START_DATE
                              ,'YYYYMMDD') || ''',''YYYYMMDD'')';
      ELSE
        LIMIT_DATES := ' AND TRUNC(DJ.SCHEDULED_START_DATE) >= TO_DATE(''' || TO_CHAR(P_FROM_START_DATE
                              ,'YYYYMMDD') || ''',''YYYYMMDD'')';
      END IF;
    ELSE
      IF (P_TO_START_DATE IS NOT NULL) THEN
        LIMIT_DATES := ' AND TRUNC(DJ.SCHEDULED_START_DATE) <= TO_DATE(''' || TO_CHAR(P_TO_START_DATE
                              ,'YYYYMMDD') || ''',''YYYYMMDD'')';
      ELSE
        LIMIT_DATES := ' ';
      END IF;
    END IF;
    RETURN (LIMIT_DATES);
  END DATE_LIMITER;

  FUNCTION JOB_LIMITER RETURN CHARACTER IS
    LIMIT_JOBS VARCHAR2(768);
  BEGIN
    IF (P_FROM_JOB IS NOT NULL) THEN
      IF (P_TO_JOB IS NOT NULL) THEN
        LIMIT_JOBS := ' AND WE.WIP_ENTITY_NAME BETWEEN ''' || REPLACE(P_FROM_JOB
                             ,''''
                             ,'''''') || ''' AND ''' || REPLACE(P_TO_JOB
                             ,''''
                             ,'''''') || '''';
      ELSE
        LIMIT_JOBS := ' AND WE.WIP_ENTITY_NAME >= ''' || REPLACE(P_FROM_JOB
                             ,''''
                             ,'''''') || '''';
      END IF;
    ELSE
      IF (P_TO_JOB IS NOT NULL) THEN
        LIMIT_JOBS := ' AND WE.WIP_ENTITY_NAME <= ''' || REPLACE(P_TO_JOB
                             ,''''
                             ,'''''') || '''';
      ELSE
        LIMIT_JOBS := ' ';
      END IF;
    END IF;
    RETURN (LIMIT_JOBS);
  END JOB_LIMITER;

  FUNCTION DYNAMIC_ORDER_BY RETURN CHARACTER IS
    ORDER_BY_CLAUSE VARCHAR2(100);
  BEGIN
    IF (P_SORT_CODE = 10) THEN
      ORDER_BY_CLAUSE := 'TRUNC(DJ.SCHEDULED_START_DATE)';
    ELSIF (P_SORT_CODE = 11) THEN
      ORDER_BY_CLAUSE := 'WE.WIP_ENTITY_NAME';
    ELSIF (P_SORT_CODE = 1) THEN
      ORDER_BY_CLAUSE := P_ITEM_ORDER;
    ELSIF (P_SORT_CODE = 14) THEN
      ORDER_BY_CLAUSE := 'SG.SCHEDULE_GROUP_NAME, DJ.BUILD_SEQUENCE';
    END IF;
    RETURN (ORDER_BY_CLAUSE);
  END DYNAMIC_ORDER_BY;

  FUNCTION C_STATUS_LIMITERFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF (P_STATUS IS NOT NULL) THEN
      RETURN ('AND DJ.STATUS_TYPE = ''' || P_STATUS || '''');
    ELSE
      RETURN (' ');
    END IF;
    RETURN NULL;
  END C_STATUS_LIMITERFORMULA;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    IF P_FROM_ASSEMBLY IS NOT NULL OR P_TO_ASSEMBLY IS NOT NULL THEN
      P_OUTER := ' ';
      P_ITEM_ORG := ' AND SI.ORGANIZATION_ID = :ORG_ID';
    END IF;
    IF P_SCHEDULE_GROUP_FROM IS NOT NULL OR P_SCHEDULE_GROUP_TO IS NOT NULL THEN
      P_SG_OUTER := ' ';
    END IF;
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION C_LIMITER RETURN VARCHAR2 IS
    C_OUT VARCHAR2(200);
  BEGIN
    IF P_SCHEDULE_GROUP_FROM IS NOT NULL THEN
      IF P_SCHEDULE_GROUP_TO IS NOT NULL THEN
        C_OUT := ' AND SG.SCHEDULE_GROUP_NAME BETWEEN ''' || P_SCHEDULE_GROUP_FROM || ''' AND ''' || P_SCHEDULE_GROUP_TO || '''';
      ELSE
        C_OUT := ' AND SG.SCHEDULE_GROUP_NAME >= ''' || P_SCHEDULE_GROUP_FROM || '''';
      END IF;
    ELSE
      IF P_SCHEDULE_GROUP_TO IS NOT NULL THEN
        C_OUT := ' AND SG.SCHEDULE_GROUP_NAME <= ''' || P_SCHEDULE_GROUP_TO || '''';
      ELSE
        C_OUT := ' ';
      END IF;
    END IF;
    RETURN (C_OUT);
  END C_LIMITER;

END WIP_WIPDJLIS_XMLP_PKG;



/
