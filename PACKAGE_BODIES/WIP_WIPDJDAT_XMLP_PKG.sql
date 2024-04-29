--------------------------------------------------------
--  DDL for Package Body WIP_WIPDJDAT_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_WIPDJDAT_XMLP_PKG" AS
/* $Header: WIPDJDATB.pls 120.1 2008/01/31 12:12:39 npannamp noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
  SELECT fifst.id_flex_num
into p_item_flex_num
FROM fnd_id_flex_structures fifst
WHERE fifst.application_id = 401
AND fifst.id_flex_code = 'MSTK'
AND fifst.enabled_flag = 'Y'
AND fifst.freeze_flex_definition_flag = 'Y'
and rownum<2;
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    DECLARE
      P_ORG_ID_CHAR VARCHAR2(100) := (P_ORG_ID);
    BEGIN
      FND_PROFILE.PUT('MFG_ORGANIZATION_ID'
                     ,P_ORG_ID_CHAR);
      /*SRW.USER_EXIT('FND PUTPROFILE NAME="' || 'MFG_ORGANIZATION_ID' || '" FIELD="' || P_ORG_ID_CHAR || '"')*/NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(020
                   ,'Failed in before report trigger, setting org profile ')*/NULL;
        RAISE;
    END;
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
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    END;
    RETURN (TRUE);
  END AFTERREPORT;

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

  FUNCTION C_ASSEMBLY_LIMITERFORMULA RETURN VARCHAR2 IS
  BEGIN
    BEGIN
      IF (P_ITEM_WHERE IS NOT NULL) THEN
        RETURN ('AND ');
      ELSE
        RETURN ('  ');
      END IF;
    END;
    RETURN NULL;
  END C_ASSEMBLY_LIMITERFORMULA;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    BEGIN
      IF P_FROM_ASSEMBLY IS NOT NULL OR P_TO_ASSEMBLY IS NOT NULL THEN
        P_OUTER := ' ';
      END IF;
      IF P_SCHEDULE_GROUP_FROM IS NOT NULL OR P_SCHEDULE_GROUP_TO IS NOT NULL THEN
        P_SG_OUTER := ' ';
      END IF;
      P_OE_ONT_INSTALLED := OE_INSTALL.GET_ACTIVE_PRODUCT;
      P_FND_ATTACHMENTS := 'UNION SELECT TO_NUMBER(AD.PK1_VALUE),
                                         VL.DESCRIPTION  Instruction,
                                         ST.SHORT_TEXT   Instruction_Description
                                   FROM  FND_DOCUMENTS_SHORT_TEXT ST,
                                         FND_DOCUMENTS D,
                                         FND_DOCUMENTS_VL VL,
                                         FND_ATTACHED_DOCUMENTS AD
                                   WHERE ST.MEDIA_ID = VL.MEDIA_ID
                                   AND   VL.DOCUMENT_ID = AD.DOCUMENT_ID
                                   AND   VL.DOCUMENT_ID = D.DOCUMENT_ID
                                   AND   D.USAGE_TYPE IN (''O'',''T'')
                                   AND   SYSDATE BETWEEN TRUNC(NVL(D.START_DATE_ACTIVE, SYSDATE))
                                         AND TRUNC(NVL(D.END_DATE_ACTIVE, SYSDATE))+1
                                   AND   AD.ENTITY_NAME = ''WIP_DISCRETE_JOBS''
                                   AND   AD.PK2_VALUE = :P_ORG_ID';
    END;
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION C_ORDER_BYFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF P_SORT_BY = 14 THEN
      RETURN ('SG.SCHEDULE_GROUP_NAME, DJ.BUILD_SEQUENCE');
    ELSE
      RETURN ('WE.WIP_ENTITY_NAME');
    END IF;
    RETURN NULL;
  END C_ORDER_BYFORMULA;

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
END WIP_WIPDJDAT_XMLP_PKG;


/
