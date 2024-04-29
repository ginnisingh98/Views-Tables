--------------------------------------------------------
--  DDL for Package Body QA_QLTPLCHR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_QLTPLCHR_XMLP_PKG" AS
/* $Header: QLTPLCHRB.pls 120.0 2007/12/24 10:36:54 krreddy noship $ */
  FUNCTION C_DEFAULT_VALUE_NUMFORMULA(DATATYPE_NUM IN NUMBER
                                     ,DEFAULT_VALUE IN VARCHAR2) RETURN NUMBER IS
  BEGIN
    IF (DATATYPE_NUM = 2) THEN
      RETURN (TO_NUMBER(DEFAULT_VALUE
                      ,'9999999999999999.999999'));
    ELSE
      RETURN (2);
    END IF;
    RETURN NULL;
  END C_DEFAULT_VALUE_NUMFORMULA;

  FUNCTION P_PLANVALIDTRIGGER RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END P_PLANVALIDTRIGGER;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    IF (P_ORGANIZATION_ID IS NOT NULL) THEN
      P_ORG_LIMITER := 'and qpv.organization_id = ''' || TO_CHAR(P_ORGANIZATION_ID) || '''';
    END IF;
    IF (P_PLAN_TYPE_DESC IS NOT NULL) THEN
      P_PLAN_TYPE_DESC_LIMITER := 'and qpv.plan_type_code = ''' || P_PLAN_TYPE_DESC || '''';
      SELECT
        MEANING
      INTO P_PLAN_TYPE_MEANING
      FROM
        FND_COMMON_LOOKUPS
      WHERE LOOKUP_TYPE = 'COLLECTION_PLAN_TYPE'
        AND LOOKUP_CODE = P_PLAN_TYPE_DESC;
    END IF;
    IF (P_PLAN IS NOT NULL) THEN
      SELECT
        NAME
      INTO P_PLAN
      FROM
        QA_PLANS
      WHERE PLAN_ID = P_PLAN;
      P_PLAN_LIMITER := 'and qpv.name = ''' || P_PLAN || '''';
    END IF;
    P_PLAN_ENABLED_FLAG := NVL(TO_NUMBER(P_PLAN_ENABLED)
                              ,1);
    SELECT
      MEANING
    INTO P_PLAN_ENABLED_MEANING
    FROM
      MFG_LOOKUPS
    WHERE LOOKUP_TYPE = 'SYS_YES_NO'
      AND LOOKUP_CODE = P_PLAN_ENABLED_FLAG;
    IF (P_PLAN_ENABLED_FLAG = 1) THEN
      P_PLAN_ENABLED_LIMITER := 'and ((to_date(''' || TO_CHAR(SYSDATE) || ''',''DD-MON-RRRR'')
                                	between qpv.effective_from and qpv.effective_to) or
                                	(qpv.effective_from is null and to_date(''' || TO_CHAR(SYSDATE) || ''',''DD-MON-RRRR'') <=
                                	qpv.effective_to) or
                                	(qpv.effective_to is null and to_date(''' || TO_CHAR(SYSDATE) || ''',''DD-MON-RRRR'') >=
                                	qpv.effective_from) or (qpv.effective_from is null and qpv.effective_to is null))';
    ELSIF (P_PLAN_ENABLED_FLAG = 2) THEN
      P_PLAN_ENABLED_LIMITER := 'and ((''' || TO_CHAR(SYSDATE) || '''
                                	not between qpv.effective_from and qpv.effective_to) or
                                	(qpv.effective_from is null and ''' || TO_CHAR(SYSDATE) || ''' >
                                	qpv.effective_to) or
                                	(qpv.effective_to is null and ''' || TO_CHAR(SYSDATE) || ''' <
                                	qpv.effective_from))';
    END IF;
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION TRANSLLATE(ENABLED_MEANING IN VARCHAR2) RETURN NUMBER IS
    CURSOR C1(ENABLED_MEANNING IN VARCHAR2) IS
      SELECT
        LOOKUP_CODE
      FROM
        MFG_LOOKUPS
      WHERE LOOKUP_TYPE = 'SYS_YES_NO'
        AND MEANING = ENABLED_MEANNING;
    TRANSLATED NUMBER;
  BEGIN
    OPEN C1(ENABLED_MEANING);
    FETCH C1
     INTO TRANSLATED;
    CLOSE C1;
    RETURN TRANSLATED;
  END TRANSLLATE;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
   apf boolean;
  BEGIN
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    apf := AFTERPFORM;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

END QA_QLTPLCHR_XMLP_PKG;


/
