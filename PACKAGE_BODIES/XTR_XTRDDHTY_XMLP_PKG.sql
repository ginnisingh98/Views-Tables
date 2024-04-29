--------------------------------------------------------
--  DDL for Package Body XTR_XTRDDHTY_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_XTRDDHTY_XMLP_PKG" AS
/* $Header: XTRDDHTYB.pls 120.1 2007/12/28 12:46:58 npannamp noship $ */
  FUNCTION HITEM_AMTFORMULA(HEDGE_NO IN NUMBER
                           ,HEDGE_APPROACH IN VARCHAR2
                           ,HEDGE_AMOUNT IN NUMBER) RETURN NUMBER IS
    SOURCE_CURSOR INTEGER;
    DESTINATION_CURSOR INTEGER;
    IGNORE INTEGER;
    NATIVE CONSTANT INTEGER DEFAULT 1;
    V_AMOUNT NUMBER;
    V_QUERY VARCHAR2(1000);
    L_TOTAL NUMBER;
    CURSOR XTR_AMT IS
      SELECT
        SUM(REFERENCE_AMOUNT)
      FROM
        XTR_HEDGE_RELATIONSHIPS HR
      WHERE HR.INSTRUMENT_ITEM_FLAG = 'I'
        AND HR.HEDGE_ATTRIBUTE_ID = HEDGE_NO;
    CURSOR RECLASS IS
      SELECT
        SUM(RECLASS_HEDGE_AMT)
      FROM
        XTR_RECLASS_DETAILS
      WHERE HEDGE_ATTRIBUTE_ID = HEDGE_NO
        AND RECLASS_DATE <= P_DATE
        AND RECLASS_GAIN_LOSS_AMT is not null;
    L_RECLASS_AMT NUMBER;
    L_ORIG_HDG_AMT NUMBER;
  BEGIN
    OPEN RECLASS;
    FETCH RECLASS
     INTO L_RECLASS_AMT;
    CLOSE RECLASS;
    IF HEDGE_APPROACH = 'FORECAST' THEN
      L_ORIG_HDG_AMT := NVL(HEDGE_AMOUNT
                           ,0);
    ELSIF NVL(HEDGE_APPROACH , ' @#@ ') <> 'FORECAST' THEN
      OPEN XTR_AMT;
      FETCH XTR_AMT
       INTO L_ORIG_HDG_AMT;
      CLOSE XTR_AMT;
    END IF;
    IF NVL(L_ORIG_HDG_AMT
       ,0) <> 0 THEN
      L_TOTAL := (ABS(L_ORIG_HDG_AMT) - NVL(L_RECLASS_AMT
                    ,0)) * SIGN(L_ORIG_HDG_AMT);
    ELSE
      L_TOTAL := (-NVL(L_RECLASS_AMT
                    ,0));
    END IF;
    RETURN (L_TOTAL / NVL(P_UNIT
              ,1));
  EXCEPTION
    WHEN OTHERS THEN
      /*SRW.MESSAGE(100
                 ,SQLERRM)*/NULL;
      RETURN (NULL);
  END HITEM_AMTFORMULA;

  FUNCTION HINST_AMTFORMULA(CHINST_AMT IN NUMBER) RETURN NUMBER IS
    CURSOR ITEM(P_HEDGE_NO IN NUMBER) IS
      SELECT
        SUM(REFERENCE_AMOUNT)
      FROM
        XTR_HEDGE_RELATIONSHIPS
      WHERE HEDGE_ATTRIBUTE_ID = P_HEDGE_NO
        AND INSTRUMENT_ITEM_FLAG = 'U';
    L_AMOUNT NUMBER;
  BEGIN
    L_AMOUNT := CHINST_AMT;
    RETURN (L_AMOUNT / NVL(P_UNIT
              ,1));
  EXCEPTION
    WHEN OTHERS THEN
      /*SRW.MESSAGE(100
                 ,SQLERRM)*/NULL;
      RETURN (NULL);
  END HINST_AMTFORMULA;

  FUNCTION HITEM_RCCYFORMULA(COMPANY_CODE IN VARCHAR2
                            ,HEDGE_CURRENCY IN VARCHAR2
                            ,HITEM_AMT IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (ABS(GET_EQU_AMT(COMPANY_CODE
                          ,HEDGE_CURRENCY
                          ,HITEM_AMT)));
  END HITEM_RCCYFORMULA;

  FUNCTION HINST_RCCYFORMULA(COMPANY_CODE IN VARCHAR2
                            ,HEDGE_CURRENCY IN VARCHAR2
                            ,HINST_AMT IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (ABS(GET_EQU_AMT(COMPANY_CODE
                          ,HEDGE_CURRENCY
                          ,HINST_AMT)));
  END HINST_RCCYFORMULA;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
    CURSOR COMPANY(P_COMPANY IN VARCHAR2) IS
      SELECT
        SHORT_NAME
      FROM
        XTR_PARTIES_V
      WHERE PARTY_CODE = P_COMPANY;
    CURSOR STRATEGY(P_STRATEGY IN VARCHAR2) IS
      SELECT
        STRATEGY_NAME
      FROM
        XTR_HEDGE_STRATEGIES
      WHERE STRATEGY_CODE = P_STRATEGY;
    CURSOR CUR_MEAN(P_TYPE IN VARCHAR2,P_CODE IN VARCHAR2) IS
      SELECT
        MEANING
      FROM
        FND_LOOKUPS
      WHERE LOOKUP_TYPE = P_TYPE
        AND LOOKUP_CODE = P_CODE;
    L_LOOKUP_TYPE VARCHAR2(30);
  BEGIN
   P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
P_AS_OF_DATE_1 := P_AS_OF_DATE;
    P_DATE := FND_DATE.CANONICAL_TO_DATE(P_AS_OF_DATE_1);
    P_AS_OF_DATE_1 := P_DATE;
    IF P_FACTOR = '0' THEN
      P_UNIT := 1;
    ELSE
      P_UNIT := TO_NUMBER(P_FACTOR);
    END IF;
    IF REPORT_NAME IS NULL THEN
      SELECT
        CP.USER_CONCURRENT_PROGRAM_NAME
      INTO REPORT_NAME
      FROM
        FND_CONCURRENT_PROGRAMS_VL CP,
        FND_CONCURRENT_REQUESTS CR
      WHERE CR.REQUEST_ID = P_CONC_REQUEST_ID
        AND CP.APPLICATION_ID = CR.PROGRAM_APPLICATION_ID
        AND CP.CONCURRENT_PROGRAM_ID = CR.CONCURRENT_PROGRAM_ID;
 REPORT_NAME := substr(REPORT_NAME,1,instr(REPORT_NAME,' (XML)'));
    END IF;
    IF P_COMPANY IS NOT NULL THEN
      OPEN COMPANY(P_COMPANY);
      FETCH COMPANY
       INTO RP_COMPANY_NAME;
      CLOSE COMPANY;
    END IF;
    IF P_RISK_TYPE IS NOT NULL THEN
      OPEN CUR_MEAN('XTR_HEDGE_RISK_TYPES',P_RISK_TYPE);
      FETCH CUR_MEAN
       INTO RP_RISK_TYPE;
      CLOSE CUR_MEAN;
    END IF;
    IF P_HEDGE_TYPE IS NOT NULL THEN
      OPEN CUR_MEAN('XTR_HEDGE_TYPES',P_HEDGE_TYPE);
      FETCH CUR_MEAN
       INTO RP_HEDGE_TYPE;
      CLOSE CUR_MEAN;
    END IF;
    IF P_OBJECTIVE IS NOT NULL THEN
      OPEN CUR_MEAN('XTR_HEDGE_OBJECTIVE_TYPES',P_OBJECTIVE);
      FETCH CUR_MEAN
       INTO RP_OBJECTIVE;
      CLOSE CUR_MEAN;
    END IF;
    IF P_STRATEGY IS NOT NULL THEN
      OPEN STRATEGY(P_STRATEGY);
      FETCH STRATEGY
       INTO RP_STRATEGY_NAME;
      CLOSE STRATEGY;
    END IF;
    IF P_HEDGE_STATUS IS NOT NULL THEN
      IF P_HEDGE_STATUS = 'ALLXCANC' THEN
        L_LOOKUP_TYPE := 'XTR_HEDGE_MISC';
      ELSE
        L_LOOKUP_TYPE := 'XTR_HEDGE_STATUS';
      END IF;
      OPEN CUR_MEAN(L_LOOKUP_TYPE,P_HEDGE_STATUS);
      FETCH CUR_MEAN
       INTO RP_HEDGE_STATUS;
      CLOSE CUR_MEAN;
    END IF;
    IF P_FACTOR IS NOT NULL THEN
      OPEN CUR_MEAN('XTR_NUM_FACTOR',P_FACTOR);
      FETCH CUR_MEAN
       INTO RP_FACTOR;
      CLOSE CUR_MEAN;
    END IF;
    RETURN (TRUE);
  EXCEPTION
    WHEN OTHERS THEN
      /*SRW.MESSAGE(100
                 ,SQLERRM)*/NULL;
  END AFTERPFORM;

  FUNCTION GET_EQU_AMT(X_COMPANY_CODE IN VARCHAR2
                      ,X_BASE_CCY IN VARCHAR2
                      ,X_BASE_AMT IN NUMBER) RETURN NUMBER IS
    CURSOR COMPANY_INFO IS
      SELECT
        CP.PARAMETER_VALUE_CODE,
        DCT.USER_CONVERSION_TYPE,
        CURRENCY_CODE
      FROM
        XTR_PARTIES_V PTY,
        XTR_COMPANY_PARAMETERS CP,
        GL_SETS_OF_BOOKS SOB,
        GL_DAILY_CONVERSION_TYPES DCT
      WHERE PTY.PARTY_CODE = X_COMPANY_CODE
        AND CP.COMPANY_CODE = PTY.PARTY_CODE
        AND CP.PARAMETER_CODE = 'ACCNT_EXRTP'
        AND PTY.SET_OF_BOOKS_ID = SOB.SET_OF_BOOKS_ID
        AND CP.PARAMETER_VALUE_CODE = dct.conversion_type (+);
    CURSOR C_DATE(P_SOB_CCY IN VARCHAR2,L_CON_TYPE IN VARCHAR2) IS
      SELECT
        MAX(CONVERSION_DATE)
      FROM
        GL_DAILY_RATES
      WHERE FROM_CURRENCY = X_BASE_CCY
        AND TO_CURRENCY = P_SOB_CCY
        AND CONVERSION_TYPE = L_CON_TYPE
        AND CONVERSION_DATE <= P_AS_OF_DATE_1;
    SOB_CURRENCY VARCHAR2(15);
    L_PTY_CONVERT_TYPE VARCHAR2(30);
    L_PTY_USER_CONVERT_TYPE VARCHAR2(30);
    L_EQU_AMOUNT NUMBER;
    L_DATE DATE;
    L_CURRENCY VARCHAR2(15);
  BEGIN
    OPEN COMPANY_INFO;
    FETCH COMPANY_INFO
     INTO L_PTY_CONVERT_TYPE,L_PTY_USER_CONVERT_TYPE,SOB_CURRENCY;
    CLOSE COMPANY_INFO;
    L_CURRENCY := NVL(P_REPORT_CCY
                     ,SOB_CURRENCY);
    OPEN C_DATE(L_CURRENCY,L_PTY_CONVERT_TYPE);
    FETCH C_DATE
     INTO L_DATE;
    CLOSE C_DATE;
    L_EQU_AMOUNT := GL_CURRENCY_API.CONVERT_AMOUNT(X_BASE_CCY
                                                  ,L_CURRENCY
                                                  ,L_DATE
                                                  ,L_PTY_CONVERT_TYPE
                                                  ,X_BASE_AMT);
    RETURN (L_EQU_AMOUNT);
  EXCEPTION
    WHEN OTHERS THEN
      IF CP_NO_GL_RATE IS NULL THEN
        FND_MESSAGE.SET_NAME('XTR'
                            ,'XTR_HEDGE_NO_GL_RATE_SRW');
        IF CP_NO_GL_RATE IS NULL THEN
          CP_NO_GL_RATE := FND_MESSAGE.GET;
        END IF;
      END IF;
      /*SRW.MESSAGE(100
                 ,'Error Calculating the Report Currency Equivalent Amount')*/NULL;
      RETURN (NULL);
  END GET_EQU_AMT;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
    CURSOR GET_LANGUAGE_DESC IS
      SELECT
        ITEM_NAME,
        TEXT LANG_NAME
      FROM
        XTR_SYS_LANGUAGES_VL
      WHERE MODULE_NAME = 'XTRDDHTY';
  BEGIN

    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    FOR c IN GET_LANGUAGE_DESC LOOP
      IF C.ITEM_NAME = 'Z1AMOUNT' THEN
        Z1AMOUNT := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z1CUR_HEDGE' THEN
        Z1CUR_HEDGE := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z1ITEM_AMOUNT' THEN
        Z1ITEM_AMOUNT := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z1INST_AMOUNT' THEN
        Z1INST_AMOUNT := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z1AS_OF_DATE' THEN
        Z1AS_OF_DATE := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z1CCY' THEN
        Z1CCY := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z1COMPANY' THEN
        Z1COMPANY := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z1DER_DISCL' THEN
        Z1DER_DISCL := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z1END_DATE' THEN
        Z1END_DATE := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z1EQUI' THEN
        Z1EQUI := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z1FACTOR' THEN
        Z1FACTOR := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z1GT_SYSDATE' THEN
        IF P_AS_OF_DATE_1 > SYSDATE THEN
          Z1GT_SYSDATE := C.LANG_NAME;
        ELSE
          Z1GT_SYSDATE := NULL;
        END IF;
      ELSIF C.ITEM_NAME = 'Z1HEDGE' THEN
        Z1HEDGE := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z1HEDGE_INST' THEN
        Z1HEDGE_INST := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z1HEDGE_ITEM' THEN
        Z1HEDGE_ITEM := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z1HEDGE_TYPE' THEN
        Z1HEDGE_TYPE := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z1HSTGY_TOTAL' THEN
        Z1HSTGY_TOTAL := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z1HTYPE_TOTAL' THEN
        Z1HTYPE_TOTAL := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z1NUMBER' THEN
        Z1NUMBER := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z1OBJECTIVE' THEN
        Z1OBJECTIVE := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z1OBJECTIVE_DESC' THEN
        Z1OBJECTIVE_DESC := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z1PARAMETERS' THEN
        Z1PARAMETERS := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z1POLICY_REF' THEN
        Z1POLICY_REF := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z1REPORT_CCY' THEN
        Z1REPORT_CCY := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z1RISK_TYPE' THEN
        Z1RISK_TYPE := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z1START_DATE' THEN
        Z1START_DATE := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z1STRATEGY' THEN
        Z1STRATEGY := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z1STRATEGY_NAME' THEN
        Z1STRATEGY_NAME := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z2END_OF_REPORT' THEN
        Z2END_OF_REPORT := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z2HEDGE_STATUS' THEN
        Z2HEDGE_STATUS := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z2NO_DATA_FOUND' THEN
        Z2NO_DATA_FOUND := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z2PAGE' THEN
        Z2PAGE := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z2REPORT_DATE' THEN
        Z2REPORT_DATE := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z2STRATEGY' THEN
        Z2STRATEGY := C.LANG_NAME;
      END IF;
    END LOOP;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION COMPANY_NAMEFORMULA(COMPANY_CODE IN VARCHAR2) RETURN CHAR IS
    CURSOR COMPANY(P_COMPANY IN VARCHAR2) IS
      SELECT
        SHORT_NAME
      FROM
        XTR_PARTIES_V
      WHERE PARTY_CODE = P_COMPANY;
    L_COMPANY VARCHAR2(20);
  BEGIN
    IF COMPANY_CODE IS NOT NULL THEN
      OPEN COMPANY(COMPANY_CODE);
      FETCH COMPANY
       INTO L_COMPANY;
      CLOSE COMPANY;
    END IF;
    RETURN (L_COMPANY);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (NULL);
  END COMPANY_NAMEFORMULA;

  FUNCTION HEDGE_TYPE_DSPFORMULA(HEDGE_TYPE IN VARCHAR2) RETURN CHAR IS
    CURSOR HTYPE(P_HTYPE IN VARCHAR2) IS
      SELECT
        MEANING
      FROM
        FND_LOOKUPS
      WHERE LOOKUP_TYPE = 'XTR_HEDGE_TYPES'
        AND LOOKUP_CODE = P_HTYPE;
    L_HEDGE_TYPE VARCHAR2(80);
  BEGIN
    IF HEDGE_TYPE IS NOT NULL THEN
      OPEN HTYPE(HEDGE_TYPE);
      FETCH HTYPE
       INTO L_HEDGE_TYPE;
      CLOSE HTYPE;
    END IF;
    RETURN (L_HEDGE_TYPE);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (NULL);
  END HEDGE_TYPE_DSPFORMULA;

  FUNCTION OBJECTIVE_NAMEFORMULA(OBJECTIVE_CODE IN VARCHAR2) RETURN CHAR IS
    CURSOR OBJ(P_OBJ IN VARCHAR2) IS
      SELECT
        MEANING
      FROM
        FND_LOOKUPS
      WHERE LOOKUP_TYPE = 'XTR_HEDGE_OBJECTIVE_TYPES'
        AND LOOKUP_CODE = P_OBJ;
    L_OBJNAME VARCHAR2(80);
  BEGIN
    IF OBJECTIVE_CODE IS NOT NULL THEN
      OPEN OBJ(OBJECTIVE_CODE);
      FETCH OBJ
       INTO L_OBJNAME;
      CLOSE OBJ;
    END IF;
    RETURN (L_OBJNAME);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (NULL);
  END OBJECTIVE_NAMEFORMULA;

  FUNCTION OBJECTIVE_DESCFORMULA(OBJECTIVE_CODE IN VARCHAR2) RETURN CHAR IS
    CURSOR OBJ(P_OBJ IN VARCHAR2) IS
      SELECT
        DESCRIPTION
      FROM
        FND_LOOKUPS
      WHERE LOOKUP_TYPE = 'XTR_HEDGE_OBJECTIVE_TYPES'
        AND LOOKUP_CODE = P_OBJ;
    L_OBJDESC VARCHAR2(240);
  BEGIN
    IF OBJECTIVE_CODE IS NOT NULL THEN
      OPEN OBJ(OBJECTIVE_CODE);
      FETCH OBJ
       INTO L_OBJDESC;
      CLOSE OBJ;
    END IF;
    RETURN (L_OBJDESC);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (NULL);
  END OBJECTIVE_DESCFORMULA;

  FUNCTION RISK_TYPE_DSPFORMULA(RISK_TYPE IN VARCHAR2) RETURN CHAR IS
    CURSOR RISK(P_CODE IN VARCHAR2) IS
      SELECT
        MEANING
      FROM
        FND_LOOKUPS
      WHERE LOOKUP_TYPE = 'XTR_HEDGE_RISK_TYPES'
        AND LOOKUP_CODE = P_CODE;
    L_RISKNAME VARCHAR2(80);
  BEGIN
    IF RISK_TYPE IS NOT NULL THEN
      OPEN RISK(RISK_TYPE);
      FETCH RISK
       INTO L_RISKNAME;
      CLOSE RISK;
    END IF;
    RETURN (L_RISKNAME);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (NULL);
  END RISK_TYPE_DSPFORMULA;

  FUNCTION STARFORMULA(HEDGE_STATUS IN VARCHAR2) RETURN CHAR IS
  BEGIN
    IF HEDGE_STATUS <> 'CURRENT' THEN
      FND_MESSAGE.SET_NAME('XTR'
                          ,'XTR_HEDGE_NOT_CURRENT_SRW');
      FND_MESSAGE.SET_TOKEN('STATUS'
                           ,'Current');
      IF CP_NOT_CURRENT IS NULL THEN
        CP_NOT_CURRENT := FND_MESSAGE.GET;
      END IF;
      RETURN ('**');
    ELSE
      RETURN (NULL);
    END IF;
  END STARFORMULA;

  FUNCTION RPT_CCYFORMULA(COMPANY_CODE IN VARCHAR2) RETURN CHAR IS
    CURSOR COMPANY_INFO IS
      SELECT
        CP.PARAMETER_VALUE_CODE,
        DCT.USER_CONVERSION_TYPE,
        CURRENCY_CODE
      FROM
        XTR_PARTIES_V PTY,
        XTR_COMPANY_PARAMETERS CP,
        GL_SETS_OF_BOOKS SOB,
        GL_DAILY_CONVERSION_TYPES DCT
      WHERE PTY.PARTY_CODE = COMPANY_CODE
        AND CP.COMPANY_CODE = PTY.PARTY_CODE
        AND CP.PARAMETER_CODE = 'ACCNT_EXRTP'
        AND PTY.SET_OF_BOOKS_ID = SOB.SET_OF_BOOKS_ID
        AND CP.PARAMETER_VALUE_CODE = dct.conversion_type (+);
    SOB_CURRENCY VARCHAR2(15);
    L_PTY_CONVERT_TYPE VARCHAR2(30);
    L_PTY_USER_CONVERT_TYPE VARCHAR2(30);
    L_SOB_AMOUNT NUMBER;
    L_DATE DATE;
    L_CURRENCY VARCHAR2(15);
  BEGIN
    IF P_REPORT_CCY IS NOT NULL THEN
      RETURN (P_REPORT_CCY);
    ELSE
      OPEN COMPANY_INFO;
      FETCH COMPANY_INFO
       INTO L_PTY_CONVERT_TYPE,L_PTY_USER_CONVERT_TYPE,SOB_CURRENCY;
      CLOSE COMPANY_INFO;
      RETURN (SOB_CURRENCY);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (NULL);
  END RPT_CCYFORMULA;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION CHINST_AMTFORMULA(HEDGE_NO IN NUMBER) RETURN NUMBER IS
    L_APPROACH VARCHAR2(30);
    L_ROUND NUMBER;
    L_GAIN_LOSS_CCY VARCHAR2(15);
    L_AMOUNT_TYPE VARCHAR2(30);
    L_HEDGE_AMT NUMBER;
    L_REF_AMOUNT NUMBER;
    L_ORIG_HEDGE_AMT NUMBER;
    L_CUM_REC_HDG_AMT NUMBER;
    L_REM_HEDGE_AMT NUMBER;
    L_ORIG_REF_AMT NUMBER;
    L_CUR_REF_AMT NUMBER;
    CURSOR RECLASS IS
      SELECT
        SUM(RECLASS_HEDGE_AMT)
      FROM
        XTR_RECLASS_DETAILS
      WHERE HEDGE_ATTRIBUTE_ID = HEDGE_NO
        AND RECLASS_DATE <= P_DATE
        AND RECLASS_GAIN_LOSS_AMT is not null;
    CURSOR HDG IS
      SELECT
        S.HEDGE_APPROACH,
        H.HEDGE_AMOUNT
      FROM
        XTR_HEDGE_STRATEGIES S,
        XTR_HEDGE_ATTRIBUTES H
      WHERE S.STRATEGY_CODE = H.STRATEGY_CODE
        AND H.HEDGE_ATTRIBUTE_ID = HEDGE_NO;
    CURSOR REF_AMT(P_FLAG IN VARCHAR2) IS
      SELECT
        ABS(SUM(R.REFERENCE_AMOUNT)) REF_AMT
      FROM
        XTR_HEDGE_RELATIONSHIPS R
      WHERE R.HEDGE_ATTRIBUTE_ID = HEDGE_NO
        AND INSTRUMENT_ITEM_FLAG = P_FLAG;
  BEGIN
    OPEN HDG;
    FETCH HDG
     INTO L_APPROACH,L_HEDGE_AMT;
    CLOSE HDG;
    IF L_APPROACH = 'FORECAST' THEN
      L_ORIG_HEDGE_AMT := NVL(L_HEDGE_AMT
                             ,0);
    ELSE
      OPEN REF_AMT('I');
      FETCH REF_AMT
       INTO L_ORIG_HEDGE_AMT;
      CLOSE REF_AMT;
    END IF;
    OPEN REF_AMT('U');
    FETCH REF_AMT
     INTO L_ORIG_REF_AMT;
    CLOSE REF_AMT;
    OPEN RECLASS;
    FETCH RECLASS
     INTO L_CUM_REC_HDG_AMT;
    CLOSE RECLASS;
    L_REM_HEDGE_AMT := NVL(L_ORIG_HEDGE_AMT
                          ,0) - NVL(L_CUM_REC_HDG_AMT
                          ,0);
    L_CUR_REF_AMT := L_ORIG_REF_AMT * L_REM_HEDGE_AMT / L_ORIG_HEDGE_AMT;
    RETURN (L_CUR_REF_AMT);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END CHINST_AMTFORMULA;

  FUNCTION CP_NO_GL_RATE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_NO_GL_RATE;
  END CP_NO_GL_RATE_P;

  FUNCTION CP_NOT_CURRENT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_NOT_CURRENT;
  END CP_NOT_CURRENT_P;


END XTR_XTRDDHTY_XMLP_PKG;


/