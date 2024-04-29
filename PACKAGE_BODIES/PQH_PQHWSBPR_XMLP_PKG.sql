--------------------------------------------------------
--  DDL for Package Body PQH_PQHWSBPR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_PQHWSBPR_XMLP_PKG" AS
/* $Header: PQHWSBPRB.pls 120.2 2007/12/21 19:31:13 vjaganat noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  l_dummy boolean;
  BEGIN
    DECLARE
      CURSOR CSR_BDGT_NO IS
        SELECT
          BUDGET_NAME,
          VERSION_NUMBER
        FROM
          PQH_BUDGETS BGT,
          PQH_BUDGET_VERSIONS BVR
        WHERE BGT.BUDGET_ID = BVR.BUDGET_ID
          AND BGT.BUSINESS_GROUP_ID = P_BUSINESS_GROUP_ID
          AND BUDGET_VERSION_ID = P_BUDGET_VERSION_ID;
      CURSOR CSR_CURR_CODE IS
        SELECT
          BG.CURRENCY_CODE
        FROM
          PER_BUSINESS_GROUPS BG,
          PQH_BUDGETS BGT,
          PQH_BUDGET_VERSIONS BVR
        WHERE BGT.BUDGET_ID = BVR.BUDGET_ID
          AND BVR.BUDGET_VERSION_ID = P_BUDGET_VERSION_ID
          AND BGT.BUSINESS_GROUP_ID = BG.BUSINESS_GROUP_ID;
      CURSOR CSR_BGT_CURR IS
        SELECT
          BGT.CURRENCY_CODE
        FROM
          PQH_BUDGETS BGT,
          PQH_BUDGET_VERSIONS BVR
        WHERE BGT.BUDGET_ID = BVR.BUDGET_ID
          AND BVR.BUDGET_VERSION_ID = P_BUDGET_VERSION_ID;
      CURSOR CSR_SESSION_DATE IS
        SELECT
          sysdate
        FROM
          DUAL;
      CURSOR CSR_RECORD_VALUE IS
        SELECT
          MEANING
        FROM
          HR_LOOKUPS
        WHERE LOOKUP_TYPE = 'PQH_BUDGET_DETAIL_RECORD_TYPE'
          AND LOOKUP_CODE = P_RECORD_TYPE;
      L_BG_CURR_CODE VARCHAR2(150) := '';
      L_BUDGET_CURR VARCHAR2(150) := '';
    BEGIN
      l_dummy := BEFOREPFORM;
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      OPEN CSR_BDGT_NO;
      FETCH CSR_BDGT_NO
       INTO
         CP_BUDGET_NAME
         ,CP_BUDGET_VERSION;
      CLOSE CSR_BDGT_NO;
      OPEN CSR_RECORD_VALUE;
      FETCH CSR_RECORD_VALUE
       INTO
         CP_RECORD_VALUE;
      CLOSE CSR_RECORD_VALUE;
      P_REPORT_TITLE := HR_GENERAL.DECODE_LOOKUP('PQH_REPORT_TITLES'
                                                ,'PQHWSBPR');
      C_BUSINESS_GROUP_NAME := GET_BUSINESS_GROUP(P_BUSINESS_GROUP_ID);
      OPEN CSR_BGT_CURR;
      FETCH CSR_BGT_CURR
       INTO
         L_BUDGET_CURR;
      CLOSE CSR_BGT_CURR;
      IF L_BUDGET_CURR IS NOT NULL THEN
        CP_CURRENCY_CODE := L_BUDGET_CURR;
      ELSE
        OPEN CSR_CURR_CODE;
        FETCH CSR_CURR_CODE
         INTO
           L_BG_CURR_CODE;
        CLOSE CSR_CURR_CODE;
        CP_CURRENCY_CODE := L_BG_CURR_CODE;
      END IF;
      OPEN CSR_SESSION_DATE;
      FETCH CSR_SESSION_DATE
       INTO
         CP_SESSION_DT;
      CLOSE CSR_SESSION_DATE;
    END;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION CF_1FORMULA(BUDGET_UNIT_ID IN NUMBER
                      ,BUDGET_PERIOD_ACTUAL_VALUE IN NUMBER
                      ,BUDGET_PERIOD_CMMTMNT_VALUE IN NUMBER) RETURN NUMBER IS
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
    IF NVL(L_SHARED_TYPE_CD
       ,'XX') = 'MONEY' THEN
      RETURN (NVL(BUDGET_PERIOD_ACTUAL_VALUE
                ,0) + NVL(BUDGET_PERIOD_CMMTMNT_VALUE
                ,0));
    ELSE
      RETURN (NVL(BUDGET_PERIOD_ACTUAL_VALUE
                ,0));
    END IF;
  END CF_1FORMULA;

  FUNCTION CF_DEF_EX_AMTFORMULA(BUDGET_PERIOD_BUDGETED_VALUE IN NUMBER
                               ,CF_PROJECTED_EXP IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (NVL(BUDGET_PERIOD_BUDGETED_VALUE
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

  FUNCTION CF_ACT_PERFORMULA(BUDGET_PERIOD_BUDGETED_VALUE IN NUMBER
                            ,BUDGET_PERIOD_ACTUAL_VALUE IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF BUDGET_PERIOD_BUDGETED_VALUE = 0 THEN
      RETURN 0;
    ELSE
      RETURN (NVL(BUDGET_PERIOD_ACTUAL_VALUE
                ,0) / BUDGET_PERIOD_BUDGETED_VALUE) * 100;
    END IF;
  END CF_ACT_PERFORMULA;

  FUNCTION CF_COM_PERFORMULA(BUDGET_PERIOD_BUDGETED_VALUE IN NUMBER
                            ,BUDGET_PERIOD_CMMTMNT_VALUE IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF BUDGET_PERIOD_BUDGETED_VALUE = 0 THEN
      RETURN 0;
    ELSE
      RETURN (NVL(BUDGET_PERIOD_CMMTMNT_VALUE
                ,0) / BUDGET_PERIOD_BUDGETED_VALUE) * 100;
    END IF;
  END CF_COM_PERFORMULA;

  FUNCTION CF_PROJ_PERFORMULA(BUDGET_PERIOD_BUDGETED_VALUE IN NUMBER
                             ,CF_PROJECTED_EXP IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF BUDGET_PERIOD_BUDGETED_VALUE = 0 THEN
      RETURN 0;
    ELSE
      RETURN (NVL(CF_PROJECTED_EXP
                ,0) / BUDGET_PERIOD_BUDGETED_VALUE) * 100;
    END IF;
  END CF_PROJ_PERFORMULA;

  FUNCTION CF_DEF_EX_PERFORMULA(BUDGET_PERIOD_BUDGETED_VALUE IN NUMBER
                               ,CF_DEF_EX_AMT IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF BUDGET_PERIOD_BUDGETED_VALUE = 0 THEN
      RETURN 0;
    ELSE
      RETURN (NVL(CF_DEF_EX_AMT
                ,0) / BUDGET_PERIOD_BUDGETED_VALUE) * 100;
    END IF;
  END CF_DEF_EX_PERFORMULA;

  FUNCTION CF_FORMAT_MASKFORMULA(BUDGET_UNIT_ID IN NUMBER) RETURN CHAR IS
    BUDGET_UNIT_CD VARCHAR2(30);
    L_FORMAT_MASK VARCHAR2(40);
  BEGIN
    SELECT
      SYSTEM_TYPE_CD
    INTO
      BUDGET_UNIT_CD
    FROM
      PER_SHARED_TYPES
    WHERE SHARED_TYPE_ID = BUDGET_UNIT_ID;
    IF BUDGET_UNIT_CD = 'MONEY' THEN
      L_FORMAT_MASK := FND_CURRENCY.GET_FORMAT_MASK(CP_CURRENCY_CODE
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
  END CF_FORMAT_MASKFORMULA;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION C_REPORT_SUBTITLE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_REPORT_SUBTITLE;
  END C_REPORT_SUBTITLE_P;

  FUNCTION CP_BUDGET_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_BUDGET_NAME;
  END CP_BUDGET_NAME_P;

  FUNCTION CP_BUDGET_VERSION_P RETURN NUMBER IS
  BEGIN
    RETURN CP_BUDGET_VERSION;
  END CP_BUDGET_VERSION_P;

  FUNCTION CP_CURRENCY_CODE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_CURRENCY_CODE;
  END CP_CURRENCY_CODE_P;

  FUNCTION C_BUSINESS_GROUP_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_BUSINESS_GROUP_NAME;
  END C_BUSINESS_GROUP_NAME_P;

  FUNCTION CP_SESSION_DT_P RETURN DATE IS
  BEGIN
    RETURN CP_SESSION_DT;
  END CP_SESSION_DT_P;

  FUNCTION CP_RECORD_VALUE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_RECORD_VALUE;
  END CP_RECORD_VALUE_P;

  FUNCTION GET_BUSINESS_GROUP(P_BUSINESS_GROUP_ID IN NUMBER) RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
    X0 := HR_REPORTS.GET_BUSINESS_GROUP(P_BUSINESS_GROUP_ID);
    RETURN X0;
  END GET_BUSINESS_GROUP;

END PQH_PQHWSBPR_XMLP_PKG;

/
