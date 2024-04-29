--------------------------------------------------------
--  DDL for Package Body GME_GMEPRACT_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GME_GMEPRACT_XMLP_PKG" AS
/* $Header: GMEPRACTB.pls 120.1 2008/01/07 06:47:52 nchinnam noship $ */
  FUNCTION CF_WHEREFORMULA RETURN VARCHAR2 IS
    X_WHERE VARCHAR2(500);
    X_WHERE1 VARCHAR2(500);
    X_WHERE2 VARCHAR2(1000);
  BEGIN
    IF FROM_BATCH IS NOT NULL AND TO_BATCH IS NOT NULL THEN
      X_WHERE := 'Lpad(pm.batch_no,32,''0'') >=' || '''' || LPAD(FROM_BATCH
                     ,32
                     ,'0') || '''' || ' AND
                                    Lpad(pm.batch_no,32,''0'') <= ' || '''' || LPAD(TO_BATCH
                     ,32
                     ,'0') || '''';
    ELSIF FROM_BATCH IS NULL AND TO_BATCH IS NOT NULL THEN
      X_WHERE := 'Lpad(pm.batch_no,32,''0'') <=' || '''' || LPAD(TO_BATCH
                     ,32
                     ,'0') || '''';
    ELSIF FROM_BATCH IS NOT NULL AND TO_BATCH IS NULL THEN
      X_WHERE := 'Lpad(pm.batch_no,32,''0'') >=' || '''' || LPAD(FROM_BATCH
                     ,32
                     ,'0') || '''';
    ELSE
      X_WHERE := NULL;
    END IF;
    IF X_WHERE IS NOT NULL AND X_WHERE1 IS NOT NULL THEN
      X_WHERE2 := X_WHERE || ' AND ' || X_WHERE1;
    ELSE
      X_WHERE2 := X_WHERE || X_WHERE1;
    END IF;
    if X_WHERE2 Is NULL THEN
X_WHERE2:='pm.batch_no>''0''';
end if;
    RETURN (X_WHERE2);
  END CF_WHEREFORMULA;

  FUNCTION CF_ORD_BYFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF SORTRETFFORMULA = 'Start Date,Recipe,Version' THEN
      RETURN ('pm.plan_start_date,rcp.recipe_no,rcp.recipe_version');
    ELSE
      RETURN ('rcp.recipe_no,rcp.recipe_version,pm.plan_start_date');
    END IF;
    RETURN '  ';
  END CF_ORD_BYFORMULA;

  FUNCTION CF_BATCH_TYPEFORMULA(BATCH_TYPE IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    IF BATCH_TYPE = 0 THEN
      RETURN ('PROD');
    ELSIF BATCH_TYPE = 10 THEN
      RETURN ('FPO');
    END IF;
    RETURN NULL;
  END CF_BATCH_TYPEFORMULA;

  FUNCTION SORTRETFFORMULA RETURN VARCHAR2 IS
    X_SORT1 VARCHAR2(80);
    CURSOR CUR_SELECT IS
      SELECT
        MEANING
      FROM
        GEM_LOOKUP_VALUES
      WHERE LOOKUP_CODE = SORT_BY
        AND LOOKUP_TYPE = 'GME_GMEPRACT_SORT';
  BEGIN
    OPEN CUR_SELECT;
    FETCH CUR_SELECT
     INTO X_SORT1;
    CLOSE CUR_SELECT;
    RETURN (X_SORT1);
  END SORTRETFFORMULA;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
  FROM_DATE2:=to_char(FROM_DATE,'DD-MON-YY');
  TO_DATE2:=to_char(TO_DATE,'DD-MON-YY');
  FROM_DATE1:=to_char(FROM_DATE,'DD-MON-YYYY');
  TO_DATE1:=to_char(TO_DATE,'DD-MON-YYYY');
  FROM_DATE_1:=to_char(FROM_DATE,'DD-MON-YYYY HH24:MI:SS');
  TO_DATE_1:=to_char(TO_DATE,'DD-MON-YYYY HH24:MI:SS');
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    RETURN (TRUE);
  END BEFOREREPORT;

  PROCEDURE HEADER IS
  BEGIN
    NULL;
  END HEADER;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION CF_CONTEXT_ORGFORMULA RETURN CHAR IS
    CURSOR C_GET_ORG IS
      SELECT
        ORGANIZATION_CODE
      FROM
        MTL_PARAMETERS
      WHERE ORGANIZATION_ID = P_ORG_ID;
    L_ORG VARCHAR2(6);
  BEGIN
    OPEN C_GET_ORG;
    FETCH C_GET_ORG
     INTO L_ORG;
    CLOSE C_GET_ORG;
    L_ORG := '(' || L_ORG || ')';
    RETURN L_ORG;
  END CF_CONTEXT_ORGFORMULA;

END GME_GMEPRACT_XMLP_PKG;


/
