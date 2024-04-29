--------------------------------------------------------
--  DDL for Package Body WIP_WIPDJPCK_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_WIPDJPCK_XMLP_PKG" AS
/* $Header: WIPDJPCKB.pls 120.3 2008/01/31 12:21:29 npannamp noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN

  select id_flex_num_cl

into item_id_flex_num

from(

SELECT fifst.id_flex_num id_flex_num_cl

FROM fnd_id_flex_structures fifst

WHERE fifst.application_id = 401

AND fifst.id_flex_code = 'MSTK'

AND fifst.enabled_flag = 'Y'

AND fifst.freeze_flex_definition_flag = 'Y'

ORDER BY fifst.id_flex_num )

where rownum<2 ;


    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    DECLARE
      P_ORG_ID_CHAR VARCHAR2(100) := (P_ORGANIZATION_ID);
    BEGIN
      P_QTY_PRECISION := nvl(P_QTY_PRECISION,2);
      QTY_PRECISION :=wip_common_xmlp_pkg.get_precision(P_QTY_PRECISION);
      FND_PROFILE.PUT('MFG_ORGANIZATION_ID'
                     ,P_ORG_ID_CHAR);
      /*SRW.USER_EXIT('FND PUTPROFILE NAME="' || 'MFG_ORGANIZATION_ID' || '" FIELD="' || P_ORG_ID_CHAR || '"')*/NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(020
                   ,'Failed in before report trigger, setting org profile ')*/NULL;
        RAISE;
    END;
    RETURN (TRUE);
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION C_LIMIT_SUPPLY_TYPEFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF (P_SUPPLY_TYPE IS NOT NULL) THEN
      RETURN ('AND DECODE(WRO.WIP_SUPPLY_TYPE,3,2,WRO.WIP_SUPPLY_TYPE) = ' || TO_CHAR(P_SUPPLY_TYPE));
    ELSE
      RETURN (' ');
    END IF;
    RETURN NULL;
  END C_LIMIT_SUPPLY_TYPEFORMULA;

  FUNCTION LIMIT_JOBS RETURN CHARACTER IS
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
        LIMIT_JOBS := ' AND WE.WIP_ENTITY_NAME  >= ''' || REPLACE(P_FROM_JOB
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
  END LIMIT_JOBS;

  FUNCTION DATE_LIMITER RETURN CHARACTER IS
    LIMIT_DATES VARCHAR2(120);
  BEGIN
    IF (P_FROM_DATE IS NOT NULL) THEN
      IF (P_TO_DATE IS NOT NULL) THEN
        LIMIT_DATES := ' AND TRUNC(WDJ.SCHEDULED_START_DATE) BETWEEN TO_DATE(''' || TO_CHAR(P_FROM_DATE
                              ,'YYYYMMDD') || ''',''YYYYMMDD'') AND TO_DATE(''' || TO_CHAR(P_TO_DATE
                              ,'YYYYMMDD') || ''',''YYYYMMDD'')';
      ELSE
        LIMIT_DATES := ' AND TRUNC(WDJ.SCHEDULED_START_DATE) >= TO_DATE(''' || TO_CHAR(P_FROM_DATE
                              ,'YYYYMMDD') || ''',''YYYYMMDD'')';
      END IF;
    ELSE
      IF (P_TO_DATE IS NOT NULL) THEN
        LIMIT_DATES := ' AND TRUNC(WDJ.SCHEDULED_START_DATE) <= TO_DATE(''' || TO_CHAR(P_TO_DATE
                              ,'YYYYMMDD') || ''',''YYYYMMDD'')';
      ELSE
        LIMIT_DATES := ' ';
      END IF;
    END IF;
    RETURN (LIMIT_DATES);
  END DATE_LIMITER;

  FUNCTION C_LIMIT_SUBINVFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF (P_SUPPLY_SUBINV IS NOT NULL) THEN
      RETURN ('AND WRO.SUPPLY_SUBINVENTORY = ''' || P_SUPPLY_SUBINV || '''');
    ELSE
      RETURN (' ');
    END IF;
    RETURN NULL;
  END C_LIMIT_SUBINVFORMULA;

  FUNCTION C_P_SUPPLY_TYPEFORMULA RETURN NUMBER IS
  BEGIN
    IF (P_SUPPLY_TYPE IS NOT NULL) THEN
      RETURN (P_SUPPLY_TYPE);
    ELSE
      RETURN (0);
    END IF;
    RETURN NULL;
  END C_P_SUPPLY_TYPEFORMULA;

  FUNCTION ORDER_FUNC(COMPONENT IN VARCHAR2
                     ,SUPPLY_LOCATOR IN VARCHAR2
                     ,C_COMPONENT_DISP IN VARCHAR2
                     ,C_LOCATOR_DISP IN VARCHAR2
                     ,C_COMP_SORT IN VARCHAR2
                     ,C_LOC_SORT IN VARCHAR2
                     ,SUPPLY_SUBINV IN VARCHAR2
                     ,OP_SEQ IN NUMBER
                     ,DATE_REQUIRED IN DATE
                     ,ITEM_SEQ IN NUMBER) RETURN CHARACTER IS
    TEMP VARCHAR2(2000);
  BEGIN
    /*SRW.REFERENCE(COMPONENT)*/NULL;
    /*SRW.REFERENCE(SUPPLY_LOCATOR)*/NULL;
    /*SRW.REFERENCE(C_COMPONENT_DISP)*/NULL;
    /*SRW.REFERENCE(C_LOCATOR_DISP)*/NULL;
    /*SRW.REFERENCE(C_COMP_SORT)*/NULL;
    /*SRW.REFERENCE(C_LOC_SORT)*/NULL;
    /*SRW.REFERENCE(SUPPLY_SUBINV)*/NULL;
    /*SRW.REFERENCE(OP_SEQ)*/NULL;
    /*SRW.REFERENCE(DATE_REQUIRED)*/NULL;
    /*SRW.REFERENCE(ITEM_SEQ)*/NULL;
    IF (P_SORT_BY = 4) THEN
      TEMP := RPAD(SUPPLY_SUBINV
                  ,10) || C_LOC_SORT || C_COMP_SORT || LPAD(TO_CHAR(OP_SEQ)
                  ,4
                  ,TO_CHAR(0)) || LPAD(TO_CHAR(DATE_REQUIRED
                          ,'J')
                  ,10);
    ELSIF (P_SORT_BY = 5) THEN
      TEMP := LPAD(TO_CHAR(DATE_REQUIRED
                          ,'J')
                  ,10) || C_COMP_SORT || LPAD(TO_CHAR(OP_SEQ)
                  ,4
                  ,TO_CHAR(0)) || RPAD(SUPPLY_SUBINV
                  ,10) || C_LOC_SORT;
    ELSIF (P_SORT_BY = 9) THEN
      TEMP := C_COMP_SORT || RPAD(SUPPLY_SUBINV
                  ,10) || C_LOC_SORT;
    ELSIF (P_SORT_BY = 15) THEN
      TEMP := LPAD(TO_CHAR(ITEM_SEQ)
                  ,4
                  ,TO_CHAR(0)) || LPAD(TO_CHAR(OP_SEQ)
                  ,4
                  ,TO_CHAR(0)) || C_COMP_SORT;
    ELSE
      TEMP := C_COMP_SORT || LPAD(TO_CHAR(OP_SEQ)
                  ,4
                  ,TO_CHAR(0)) || LPAD(TO_CHAR(DATE_REQUIRED
                          ,'J')
                  ,10
                  ,TO_CHAR(0)) || RPAD(SUPPLY_SUBINV
                  ,10) || C_LOC_SORT;
    END IF;
    RETURN (TEMP);
  END ORDER_FUNC;

  FUNCTION C_LIMIT_STATUSFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF (P_TXN_ONLY = 2) THEN
      RETURN ('(1,3,4,6)');
    ELSE
      RETURN ('(3,4)');
    END IF;
    RETURN NULL;
  END C_LIMIT_STATUSFORMULA;

  FUNCTION ZEROFORMULA RETURN NUMBER IS
  BEGIN
    RETURN (0);
  END ZEROFORMULA;

  FUNCTION C_COMP_SORTFORMULA(C_COMPONENT_DISP IN VARCHAR2
                             ,C_COMP_SORT IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    /*SRW.REFERENCE(C_COMPONENT_DISP)*/NULL;
    RETURN (C_COMP_SORT);
  END C_COMP_SORTFORMULA;

  FUNCTION C_LOC_SORTFORMULA(C_LOCATOR_DISP IN VARCHAR2
                            ,LOCATOR_ID IN NUMBER
                            ,C_LOC_SORT IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    /*SRW.REFERENCE(C_LOCATOR_DISP)*/NULL;
    IF (LOCATOR_ID > -1) THEN
      RETURN (C_LOC_SORT);
    ELSE
      RETURN ('          ');
    END IF;
    RETURN NULL;
  END C_LOC_SORTFORMULA;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
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

END WIP_WIPDJPCK_XMLP_PKG;


/
