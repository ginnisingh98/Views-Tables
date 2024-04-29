--------------------------------------------------------
--  DDL for Package Body PQH_PQHWSPCH_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_PQHWSPCH_XMLP_PKG" AS
/* $Header: PQHWSPCHB.pls 120.2 2007/12/21 19:32:33 vjaganat noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  l_dummy boolean;
  BEGIN
    DECLARE
      CURSOR CSR_HIERARCHY IS
        SELECT
          NAME
        FROM
          PER_ORGANIZATION_STRUCTURES
        WHERE BUSINESS_GROUP_ID = P_BUSINESS_GROUP_ID
          AND NVL(POSITION_CONTROL_STRUCTURE_FLG
           ,'N') = 'Y';
      CURSOR CSR_POSN_TYPE IS
        SELECT
          MEANING
        FROM
          HR_LOOKUPS
        WHERE LOOKUP_TYPE = 'PQH_POSITION_TYPE'
          AND LOOKUP_CODE = P_POSITION_TYPE;
      CURSOR CSR_CURRENCY_NAME IS
        SELECT
          NAME
        FROM
          FND_CURRENCIES_ACTIVE_V
        WHERE CURRENCY_CODE <> 'STAT'
          AND CURRENCY_CODE = P_CURRENCY_CODE;
      CURSOR CSR_SESSION_DATE IS
        SELECT
          sysdate
        FROM
          DUAL;
    BEGIN
      l_dummy := BEFOREPFORM;
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      OPEN CSR_CURRENCY_NAME;
      FETCH CSR_CURRENCY_NAME
       INTO
         CP_CURRENCY;
      CLOSE CSR_CURRENCY_NAME;
      OPEN CSR_HIERARCHY;
      FETCH CSR_HIERARCHY
       INTO
         CP_HIERARCHY_NAME;
      CLOSE CSR_HIERARCHY;
      OPEN CSR_POSN_TYPE;
      FETCH CSR_POSN_TYPE
       INTO
         CP_POSITION_TYPE;
      CLOSE CSR_POSN_TYPE;
      P_REPORT_TITLE := HR_GENERAL.DECODE_LOOKUP('PQH_REPORT_TITLES'
                                                ,'PQHWSPCH');
      C_BUSINESS_GROUP_NAME := GET_BUSINESS_GROUP(P_BUSINESS_GROUP_ID);
      OPEN CSR_SESSION_DATE;
      FETCH CSR_SESSION_DATE
       INTO
         CP_SESSION_DT;
      CLOSE CSR_SESSION_DATE;
    END;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION CF_1FORMULA(BUDGET_UNIT_ID1 IN NUMBER
                      ,ACTUAL_AMT IN NUMBER
                      ,COMMITTED_AMT IN NUMBER) RETURN NUMBER IS
    CURSOR SHARED_TYPES IS
      SELECT
        SYSTEM_TYPE_CD
      FROM
        PER_SHARED_TYPES
      WHERE SHARED_TYPE_ID = BUDGET_UNIT_ID1;
    L_SHARED_TYPE_CD PER_SHARED_TYPES.SYSTEM_TYPE_CD%TYPE;
  BEGIN
    OPEN SHARED_TYPES;
    FETCH SHARED_TYPES
     INTO
       L_SHARED_TYPE_CD;
    CLOSE SHARED_TYPES;
    IF L_SHARED_TYPE_CD = 'MONEY' THEN
      RETURN (NVL(ACTUAL_AMT
                ,0) + NVL(COMMITTED_AMT
                ,0));
    ELSE
      RETURN (NVL(ACTUAL_AMT
                ,0));
    END IF;
  END CF_1FORMULA;

  FUNCTION CF_DEF_EX_AMTFORMULA(BUDGETED_AMT IN NUMBER
                               ,CF_PROJECTED_EXP IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (NVL(BUDGETED_AMT
              ,0) - NVL(CF_PROJECTED_EXP
              ,0));
  END CF_DEF_EX_AMTFORMULA;

  FUNCTION BEFOREPFORM RETURN BOOLEAN IS
  BEGIN
    INSERT INTO FND_SESSIONS
      (SESSION_ID
      ,EFFECTIVE_DATE)
    VALUES   (USERENV('sessionid')
      ,P_EFFECTIVE_DATE);
    RETURN (TRUE);
  END BEFOREPFORM;

  FUNCTION CF_ACT_PERFORMULA(BUDGETED_AMT IN NUMBER
                            ,ACTUAL_AMT IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF BUDGETED_AMT = 0 THEN
      RETURN 0;
    ELSE
      RETURN (NVL(ACTUAL_AMT
                ,0) / BUDGETED_AMT) * 100;
    END IF;
  END CF_ACT_PERFORMULA;

  FUNCTION CF_COM_PERFORMULA(BUDGETED_AMT IN NUMBER
                            ,COMMITTED_AMT IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF BUDGETED_AMT = 0 THEN
      RETURN 0;
    ELSE
      RETURN (NVL(COMMITTED_AMT
                ,0) / BUDGETED_AMT) * 100;
    END IF;
  END CF_COM_PERFORMULA;

  FUNCTION CF_PROJ_PERFORMULA(BUDGETED_AMT IN NUMBER
                             ,CF_PROJECTED_EXP IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF BUDGETED_AMT = 0 THEN
      RETURN 0;
    ELSE
      RETURN (NVL(CF_PROJECTED_EXP
                ,0) / BUDGETED_AMT) * 100;
    END IF;
  END CF_PROJ_PERFORMULA;

  FUNCTION CF_DEF_EX_PERFORMULA(BUDGETED_AMT IN NUMBER
                               ,CF_DEF_EX_AMT IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF BUDGETED_AMT = 0 THEN
      RETURN 0;
    ELSE
      RETURN (NVL(CF_DEF_EX_AMT
                ,0) / BUDGETED_AMT) * 100;
    END IF;
  END CF_DEF_EX_PERFORMULA;

  FUNCTION CF_ORG_PROJECTED_EXPFORMULA(BUDGET_UNIT_ID IN NUMBER
                                      ,CF_ORG_ACTUAL_AMT IN NUMBER
                                      ,CF_ORG_COMMITTED_AMT IN NUMBER) RETURN NUMBER IS
    CURSOR SHARED_TYPES IS
      SELECT
        SYSTEM_TYPE_CD
      FROM
        PER_SHARED_TYPES
      WHERE SHARED_TYPE_ID = BUDGET_UNIT_ID;
    L_SHARED_TYPE_CD PER_SHARED_TYPES.SYSTEM_TYPE_CD%TYPE;
  BEGIN
    OPEN SHARED_TYPES;
    FETCH SHARED_TYPES
     INTO
       L_SHARED_TYPE_CD;
    CLOSE SHARED_TYPES;
    IF L_SHARED_TYPE_CD = 'MONEY' THEN
      RETURN (NVL(CF_ORG_ACTUAL_AMT
                ,0) + NVL(CF_ORG_COMMITTED_AMT
                ,0));
    ELSE
      RETURN (NVL(CF_ORG_ACTUAL_AMT
                ,0));
    END IF;
  END CF_ORG_PROJECTED_EXPFORMULA;

  FUNCTION CF_ORG_DEF_EX_AMTFORMULA(CF_ORG_BUDGETED_AMT IN NUMBER
                                   ,CF_ORG_PROJECTED_EXP IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (NVL(CF_ORG_BUDGETED_AMT
              ,0) - NVL(CF_ORG_PROJECTED_EXP
              ,0));
  END CF_ORG_DEF_EX_AMTFORMULA;

  FUNCTION CF_ORG_ACT_PERFORMULA(CF_ORG_BUDGETED_AMT IN NUMBER
                                ,CF_ORG_ACTUAL_AMT IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF CF_ORG_BUDGETED_AMT = 0 THEN
      RETURN 0;
    ELSE
      RETURN (NVL(CF_ORG_ACTUAL_AMT
                ,0) / CF_ORG_BUDGETED_AMT) * 100;
    END IF;
  END CF_ORG_ACT_PERFORMULA;

  FUNCTION CF_ORG_COM_PERFORMULA(CF_ORG_BUDGETED_AMT IN NUMBER
                                ,CF_ORG_COMMITTED_AMT IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF CF_ORG_BUDGETED_AMT = 0 THEN
      RETURN 0;
    ELSE
      RETURN (NVL(CF_ORG_COMMITTED_AMT
                ,0) / CF_ORG_BUDGETED_AMT) * 100;
    END IF;
  END CF_ORG_COM_PERFORMULA;

  FUNCTION CF_ORG_PROJ_PERFORMULA(CF_ORG_BUDGETED_AMT IN NUMBER
                                 ,CF_ORG_PROJECTED_EXP IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF CF_ORG_BUDGETED_AMT = 0 THEN
      RETURN 0;
    ELSE
      RETURN (NVL(CF_ORG_PROJECTED_EXP
                ,0) / CF_ORG_BUDGETED_AMT) * 100;
    END IF;
  END CF_ORG_PROJ_PERFORMULA;

  FUNCTION CF_ORG_DEF_EX_PERFORMULA(CF_ORG_BUDGETED_AMT IN NUMBER
                                   ,CF_ORG_DEF_EX_AMT IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF CF_ORG_BUDGETED_AMT = 0 THEN
      RETURN 0;
    ELSE
      RETURN (NVL(CF_ORG_DEF_EX_AMT
                ,0) / CF_ORG_BUDGETED_AMT) * 100;
    END IF;
  END CF_ORG_DEF_EX_PERFORMULA;

  FUNCTION CF_ORG_BUDGETED_AMTFORMULA(ORGANIZATION_ID1 IN NUMBER
                                     ,BUDGET_UNIT_ID IN NUMBER) RETURN NUMBER IS
    L_AMT NUMBER(15,2);
  BEGIN
    L_AMT := PQH_MGMT_RPT_PKG.GET_ORG_POSN_BUDGET_AMT(ORGANIZATION_ID1
                                                     ,P_START_DATE
                                                     ,P_END_DATE
                                                     ,BUDGET_UNIT_ID
                                                     ,P_CURRENCY_CODE);
    RETURN NVL(L_AMT
              ,0);
  END CF_ORG_BUDGETED_AMTFORMULA;

  FUNCTION CF_ORG_ACTUAL_AMTFORMULA(ORGANIZATION_ID1 IN NUMBER
                                   ,BUDGET_UNIT_ID IN NUMBER) RETURN NUMBER IS
    L_AMT NUMBER(15,2);
  BEGIN
    L_AMT := PQH_MGMT_RPT_PKG.GET_ORG_POSN_ACTUAL_CMMTMNTS(ORGANIZATION_ID1
                                                          ,P_START_DATE
                                                          ,P_END_DATE
                                                          ,BUDGET_UNIT_ID
                                                          ,'A'
                                                          ,P_CURRENCY_CODE);
    RETURN NVL(L_AMT
              ,0);
  END CF_ORG_ACTUAL_AMTFORMULA;

  FUNCTION CF_ORG_COMMITTED_AMTFORMULA(ORGANIZATION_ID1 IN NUMBER
                                      ,BUDGET_UNIT_ID IN NUMBER) RETURN NUMBER IS
    L_AMT NUMBER(15,2);
  BEGIN
    L_AMT := PQH_MGMT_RPT_PKG.GET_ORG_POSN_ACTUAL_CMMTMNTS(ORGANIZATION_ID1
                                                          ,P_START_DATE
                                                          ,P_END_DATE
                                                          ,BUDGET_UNIT_ID
                                                          ,'C'
                                                          ,P_CURRENCY_CODE);
    RETURN NVL(L_AMT
              ,0);
  END CF_ORG_COMMITTED_AMTFORMULA;

  FUNCTION CF_BGRP_BUDGETED_AMTFORMULA(BGRP_BUDGET_UNIT_ID IN NUMBER
                                      ,BGRP_ACTUAL_AMT IN NUMBER
                                      ,BGRP_COMMITTED_AMT IN NUMBER) RETURN NUMBER IS
    CURSOR SHARED_TYPES IS
      SELECT
        SYSTEM_TYPE_CD
      FROM
        PER_SHARED_TYPES
      WHERE SHARED_TYPE_ID = BGRP_BUDGET_UNIT_ID;
    L_SHARED_TYPE_CD PER_SHARED_TYPES.SYSTEM_TYPE_CD%TYPE;
  BEGIN
    OPEN SHARED_TYPES;
    FETCH SHARED_TYPES
     INTO
       L_SHARED_TYPE_CD;
    CLOSE SHARED_TYPES;
    IF L_SHARED_TYPE_CD = 'MONEY' THEN
      RETURN (NVL(BGRP_ACTUAL_AMT
                ,0) + NVL(BGRP_COMMITTED_AMT
                ,0));
    ELSE
      RETURN (NVL(BGRP_ACTUAL_AMT
                ,0));
    END IF;
  END CF_BGRP_BUDGETED_AMTFORMULA;

  FUNCTION CF_BGRP_DEF_EX_AMTFORMULA(BGRP_BUDGETED_AMT IN NUMBER
                                    ,CF_BGRP_PROJECTED_AMT IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (NVL(BGRP_BUDGETED_AMT
              ,0) - NVL(CF_BGRP_PROJECTED_AMT
              ,0));
  END CF_BGRP_DEF_EX_AMTFORMULA;

  FUNCTION CF_BGRP_COM_PERFORMULA(BGRP_BUDGETED_AMT IN NUMBER
                                 ,BGRP_COMMITTED_AMT IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF BGRP_BUDGETED_AMT = 0 THEN
      RETURN 0;
    ELSE
      RETURN ((NVL(BGRP_COMMITTED_AMT
                ,0) / BGRP_BUDGETED_AMT) * 100);
    END IF;
  END CF_BGRP_COM_PERFORMULA;

  FUNCTION CF_BGRP_PROJ_PERFORMULA(BGRP_BUDGETED_AMT IN NUMBER
                                  ,CF_BGRP_PROJECTED_AMT IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF BGRP_BUDGETED_AMT = 0 THEN
      RETURN 0;
    ELSE
      RETURN ((NVL(CF_BGRP_PROJECTED_AMT
                ,0) / BGRP_BUDGETED_AMT) * 100);
    END IF;
  END CF_BGRP_PROJ_PERFORMULA;

  FUNCTION CF_BGRP_DEF_EX_PERFORMULA(BGRP_BUDGETED_AMT IN NUMBER
                                    ,CF_BGRP_DEF_EX_AMT IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF BGRP_BUDGETED_AMT = 0 THEN
      RETURN 0;
    ELSE
      RETURN ((NVL(CF_BGRP_DEF_EX_AMT
                ,0) / BGRP_BUDGETED_AMT) * 100);
    END IF;
  END CF_BGRP_DEF_EX_PERFORMULA;

  FUNCTION CF_BGRP_ACTUAL_PERFORMULA(BGRP_BUDGETED_AMT IN NUMBER
                                    ,BGRP_ACTUAL_AMT IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF BGRP_BUDGETED_AMT = 0 THEN
      RETURN 0;
    ELSE
      RETURN ((NVL(BGRP_ACTUAL_AMT
                ,0) / BGRP_BUDGETED_AMT) * 100);
    END IF;
  END CF_BGRP_ACTUAL_PERFORMULA;

  FUNCTION CF_FORMAT_MASK2(BUDGET_UNIT_ID IN NUMBER) RETURN CHAR IS
    CURSOR CSR_UOM IS
      SELECT
        SYSTEM_TYPE_CD
      FROM
        PER_SHARED_TYPES
      WHERE SHARED_TYPE_ID = BUDGET_UNIT_ID
        AND LOOKUP_TYPE = 'BUDGET_MEASUREMENT_TYPE';
    L_BUDGET_MEASUREMENT_TYPE PER_SHARED_TYPES.SHARED_TYPE_NAME%TYPE;
    L_FORMAT_MASK VARCHAR2(50);
  BEGIN
    OPEN CSR_UOM;
    FETCH CSR_UOM
     INTO
       L_BUDGET_MEASUREMENT_TYPE;
    CLOSE CSR_UOM;
    IF L_BUDGET_MEASUREMENT_TYPE = 'MONEY' THEN
      L_FORMAT_MASK := FND_CURRENCY.GET_FORMAT_MASK(P_CURRENCY_CODE
                                                   ,22);
    ELSE
      FND_CURRENCY.BUILD_FORMAT_MASK(L_FORMAT_MASK
                                    ,22
                                    ,2
                                    ,NULL
                                    ,NULL
                                    ,NULL
                                    ,NULL);
    END IF;
    RETURN L_FORMAT_MASK;
  END CF_FORMAT_MASK2;

  FUNCTION CF_FORMAT_MASK1(BUDGET_UNIT_ID1 IN NUMBER) RETURN CHAR IS
    CURSOR CSR_UOM IS
      SELECT
        SYSTEM_TYPE_CD
      FROM
        PER_SHARED_TYPES
      WHERE SHARED_TYPE_ID = BUDGET_UNIT_ID1
        AND LOOKUP_TYPE = 'BUDGET_MEASUREMENT_TYPE';
    L_BUDGET_MEASUREMENT_TYPE PER_SHARED_TYPES.SHARED_TYPE_NAME%TYPE;
    L_FORMAT_MASK VARCHAR2(50);
  BEGIN
    OPEN CSR_UOM;
    FETCH CSR_UOM
     INTO
       L_BUDGET_MEASUREMENT_TYPE;
    CLOSE CSR_UOM;
    IF L_BUDGET_MEASUREMENT_TYPE = 'MONEY' THEN
      L_FORMAT_MASK := FND_CURRENCY.GET_FORMAT_MASK(P_CURRENCY_CODE
                                                   ,22);
    ELSE
      FND_CURRENCY.BUILD_FORMAT_MASK(L_FORMAT_MASK
                                    ,22
                                    ,2
                                    ,NULL
                                    ,NULL
                                    ,NULL
                                    ,NULL);
    END IF;
    RETURN L_FORMAT_MASK;
  END CF_FORMAT_MASK1;

  FUNCTION CF_FORMAT_MASK3(BGRP_BUDGET_UNIT_ID IN NUMBER) RETURN CHAR IS
    CURSOR CSR_UOM IS
      SELECT
        SYSTEM_TYPE_CD
      FROM
        PER_SHARED_TYPES
      WHERE SHARED_TYPE_ID = BGRP_BUDGET_UNIT_ID
        AND LOOKUP_TYPE = 'BUDGET_MEASUREMENT_TYPE';
    L_BUDGET_MEASUREMENT_TYPE PER_SHARED_TYPES.SHARED_TYPE_NAME%TYPE;
    L_FORMAT_MASK VARCHAR2(50);
  BEGIN
    OPEN CSR_UOM;
    FETCH CSR_UOM
     INTO
       L_BUDGET_MEASUREMENT_TYPE;
    CLOSE CSR_UOM;
    IF L_BUDGET_MEASUREMENT_TYPE = 'MONEY' THEN
      L_FORMAT_MASK := FND_CURRENCY.GET_FORMAT_MASK(P_CURRENCY_CODE
                                                   ,22);
    ELSE
      FND_CURRENCY.BUILD_FORMAT_MASK(L_FORMAT_MASK
                                    ,22
                                    ,2
                                    ,NULL
                                    ,NULL
                                    ,NULL
                                    ,NULL);
    END IF;
    RETURN L_FORMAT_MASK;
  END CF_FORMAT_MASK3;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION C_REPORT_SUBTITLE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_REPORT_SUBTITLE;
  END C_REPORT_SUBTITLE_P;

  FUNCTION CP_BUSINESS_GROUP_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_BUSINESS_GROUP_NAME;
  END CP_BUSINESS_GROUP_NAME_P;

  FUNCTION CP_HIERARCHY_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_HIERARCHY_NAME;
  END CP_HIERARCHY_NAME_P;

  FUNCTION CP_POSITION_TYPE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_POSITION_TYPE;
  END CP_POSITION_TYPE_P;

  FUNCTION CP_CURRENCY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_CURRENCY;
  END CP_CURRENCY_P;

  FUNCTION C_BUSINESS_GROUP_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_BUSINESS_GROUP_NAME;
  END C_BUSINESS_GROUP_NAME_P;

  FUNCTION CP_SESSION_DT_P RETURN DATE IS
  BEGIN
    RETURN CP_SESSION_DT;
  END CP_SESSION_DT_P;

  FUNCTION GET_BUSINESS_GROUP(P_BUSINESS_GROUP_ID IN NUMBER) RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
    X0 := HR_REPORTS.GET_BUSINESS_GROUP(P_BUSINESS_GROUP_ID);
    RETURN X0;
  END GET_BUSINESS_GROUP;

END PQH_PQHWSPCH_XMLP_PKG;

/