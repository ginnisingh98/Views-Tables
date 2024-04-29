--------------------------------------------------------
--  DDL for Package Body XTR_XTROHINS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_XTROHINS_XMLP_PKG" AS
/* $Header: XTROHINSB.pls 120.1 2007/12/28 12:58:16 npannamp noship $ */
  FUNCTION AFTERPFORM RETURN BOOLEAN IS
    CURSOR COMPANY(P_COMPANY IN VARCHAR2) IS
      SELECT
        SHORT_NAME
      FROM
        XTR_PARTIES_V
      WHERE PARTY_CODE = P_COMPANY;
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
    IF P_HEDGE_TYPE IS NOT NULL THEN
      OPEN CUR_MEAN('XTR_HEDGE_TYPES',P_HEDGE_TYPE);
      FETCH CUR_MEAN
       INTO RP_HEDGE_TYPE;
      CLOSE CUR_MEAN;
    END IF;
    IF P_OBJECTIVE IS NOT NULL THEN
      OPEN CUR_MEAN('XTR_HEDGE_OBJECTIVE_TYPES',P_OBJECTIVE);
      FETCH CUR_MEAN
       INTO RP_HEDGE_OBJ;
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
      /*SRW.MESSAGE(200
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
      WHERE MODULE_NAME = 'XTROHINS';
  BEGIN
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    FOR c IN GET_LANGUAGE_DESC LOOP
      BEGIN
        IF C.ITEM_NAME = 'Z1AS_OF_DATE' THEN
          Z1AS_OF_DATE := C.LANG_NAME;
        ELSIF C.ITEM_NAME = 'Z1CCY' THEN
          Z1CCY := C.LANG_NAME;
        ELSIF C.ITEM_NAME = 'Z1CURRENT' THEN
          Z1CURRENT := C.LANG_NAME;
        ELSIF C.ITEM_NAME = 'Z1COMPANY' THEN
          Z1COMPANY := C.LANG_NAME;
        ELSIF C.ITEM_NAME = 'Z1CONTRA' THEN
          Z1CONTRA := C.LANG_NAME;
        ELSIF C.ITEM_NAME = 'Z1DEAL' THEN
          Z1DEAL := C.LANG_NAME;
        ELSIF C.ITEM_NAME = 'Z1DEAL_AMOUNT' THEN
          Z1DEAL_AMOUNT := C.LANG_NAME;
        ELSIF C.ITEM_NAME = 'Z1END_OF_REPORT' THEN
          Z1END_OF_REPORT := C.LANG_NAME;
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
        ELSIF C.ITEM_NAME = 'Z1HEDGE_AMOUNT' THEN
          Z1HEDGE_AMOUNT := C.LANG_NAME;
        ELSIF C.ITEM_NAME = 'Z1HEDGE_OBJ' THEN
          Z1HEDGE_OBJ := C.LANG_NAME;
        ELSIF C.ITEM_NAME = 'Z1HEDGE_STRATEGY' THEN
          Z1HEDGE_STRATEGY := C.LANG_NAME;
        ELSIF C.ITEM_NAME = 'Z1HEDGE_TYPE' THEN
          Z1HEDGE_TYPE := C.LANG_NAME;
        ELSIF C.ITEM_NAME = 'Z1HTYPE_TOTAL' THEN
          Z1HTYPE_TOTAL := C.LANG_NAME;
        ELSIF C.ITEM_NAME = 'Z1NO_DATA_FOUND' THEN
          Z1NO_DATA_FOUND := C.LANG_NAME;
        ELSIF C.ITEM_NAME = 'Z1NO_HISNT_FOUND' THEN
          Z1NO_HINST_FOUND := C.LANG_NAME;
        ELSIF C.ITEM_NAME = 'Z1NUMBER' THEN
          Z1NUMBER := C.LANG_NAME;
        ELSIF C.ITEM_NAME = 'Z1OBJECTIVE' THEN
          Z1OBJECTIVE := C.LANG_NAME;
        ELSIF C.ITEM_NAME = 'Z1PAGE' THEN
          Z1PAGE := C.LANG_NAME;
        ELSIF C.ITEM_NAME = 'Z1PARAMETERS' THEN
          Z1PARAMETERS := C.LANG_NAME;
        ELSIF C.ITEM_NAME = 'Z1REPORT_CCY' THEN
          Z1REPORT_CCY := C.LANG_NAME;
        ELSIF C.ITEM_NAME = 'Z1REPORT_DATE' THEN
          Z1REPORT_DATE := C.LANG_NAME;
        ELSIF C.ITEM_NAME = 'Z1STRATEGY' THEN
          Z1STRATEGY := C.LANG_NAME;
        ELSIF C.ITEM_NAME = 'Z1SUBTYPE' THEN
          Z1SUBTYPE := C.LANG_NAME;
        ELSIF C.ITEM_NAME = 'Z1TYPE' THEN
          Z1TYPE := C.LANG_NAME;
        ELSIF C.ITEM_NAME = 'Z1UNASSIGNED' THEN
          Z1UNASSIGNED := C.LANG_NAME;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END LOOP;
    RETURN (TRUE);
  END BEFOREREPORT;
  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;
  FUNCTION GET_DSP_VALUE(TYPE IN VARCHAR2
                        ,CODE IN VARCHAR2) RETURN VARCHAR2 IS
    CURSOR CUR_MEAN(P_TYPE IN VARCHAR2,P_CODE IN VARCHAR2) IS
      SELECT
        MEANING
      FROM
        FND_LOOKUPS
      WHERE LOOKUP_TYPE = P_TYPE
        AND LOOKUP_CODE = P_CODE;
    L_MEANING VARCHAR2(80);
  BEGIN
    IF CODE IS NOT NULL THEN
      OPEN CUR_MEAN(TYPE,CODE);
      FETCH CUR_MEAN
       INTO L_MEANING;
      CLOSE CUR_MEAN;
    END IF;
    RETURN (L_MEANING);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (NULL);
  END GET_DSP_VALUE;
  FUNCTION RCCY_AMTFORMULA(HEDGE_TYPE IN VARCHAR2
                          ,HEDGE_CURRENCY IN VARCHAR2
                          ,CURRENCY_DSP IN VARCHAR2
                          ,COMPANY_CODE IN VARCHAR2
                          ,HDG_CONTRA_AMT IN NUMBER) RETURN NUMBER IS
    L_CCY VARCHAR2(15);
  BEGIN
    IF HEDGE_TYPE <> 'UNASSIGNED' THEN
      L_CCY := HEDGE_CURRENCY;
    ELSE
      L_CCY := CURRENCY_DSP;
    END IF;
    RETURN (ABS(GET_EQU_AMT(COMPANY_CODE
                          ,L_CCY
                          ,HDG_CONTRA_AMT)));
  END RCCY_AMTFORMULA;
  FUNCTION DEAL_AMTFORMULA(DEAL_NO_1 IN NUMBER
                          ,CURRENCY_DSP IN VARCHAR2
                          ,HEDGE_TYPE IN VARCHAR2
                          ,DEAL_TYPE IN VARCHAR2
                          ,HEDGE_CURRENCY IN VARCHAR2) RETURN NUMBER IS
    L_CURR VARCHAR2(15);
    L_BUY_CURR VARCHAR2(15);
    L_SELL_CURR VARCHAR2(15);
    L_BUY_AMOUNT NUMBER;
    L_SELL_AMOUNT NUMBER;
    L_FACE_VALUE NUMBER;
    L_DEAL_AMT NUMBER;
    L_ALLOC_AMT NUMBER;
    L_UNASGD_AMT NUMBER;
    L_AMOUNT NUMBER;
    ROUNDFAC NUMBER(3,2);
    CURSOR RND(P_CURR IN VARCHAR2) IS
      SELECT
        NVL(M.ROUNDING_FACTOR
           ,2)
      FROM
        XTR_MASTER_CURRENCIES_V M
      WHERE M.CURRENCY = P_CURR;
    CURSOR CCY IS
      SELECT
        CURRENCY,
        CURRENCY_BUY,
        CURRENCY_SELL,
        BUY_AMOUNT / NVL(P_UNIT
           ,1) BUY_AMOUNT,
        SELL_AMOUNT / NVL(P_UNIT
           ,1) SELL_AMOUNT,
        FACE_VALUE_AMOUNT / NVL(P_UNIT
           ,1) FACE_VALUE_AMOUNT
      FROM
        XTR_DEALS
      WHERE DEAL_NO = DEAL_NO_1;
  BEGIN
    OPEN CCY;
    FETCH CCY
     INTO L_CURR,L_BUY_CURR,L_SELL_CURR,L_BUY_AMOUNT,L_SELL_AMOUNT,L_FACE_VALUE;
    CLOSE CCY;
    OPEN RND(CURRENCY_DSP);
    FETCH RND
     INTO ROUNDFAC;
    CLOSE RND;
    IF HEDGE_TYPE <> 'UNASSIGNED' THEN
      IF DEAL_TYPE in ('FX','FXO') THEN
        IF HEDGE_CURRENCY = L_BUY_CURR THEN
          L_AMOUNT := L_BUY_AMOUNT;
        ELSE
          L_AMOUNT := L_SELL_AMOUNT;
        END IF;
      ELSE
        L_AMOUNT := L_FACE_VALUE;
      END IF;
    ELSE
      IF DEAL_TYPE in ('FX','FXO') THEN
        IF CURRENCY_DSP = L_BUY_CURR THEN
          L_AMOUNT := L_BUY_AMOUNT;
        ELSE
          L_AMOUNT := L_SELL_AMOUNT;
        END IF;
      ELSE
        L_AMOUNT := L_FACE_VALUE;
      END IF;
    END IF;
    RETURN (ROUND(L_AMOUNT
                ,ROUNDFAC));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (NULL);
  END DEAL_AMTFORMULA;
  FUNCTION CURRFORMULA(DEAL_NO_1 IN NUMBER
                      ,DEAL_TYPE IN VARCHAR2
                      ,HEDGE_TYPE IN VARCHAR2
                      ,HEDGE_CURRENCY IN VARCHAR2) RETURN CHAR IS
    L_CURR VARCHAR2(15);
    L_BUY_CURR VARCHAR2(15);
    L_SELL_CURR VARCHAR2(15);
    CURSOR CCY IS
      SELECT
        CURRENCY,
        CURRENCY_BUY,
        CURRENCY_SELL
      FROM
        XTR_DEALS
      WHERE DEAL_NO = DEAL_NO_1;
    CURSOR CUR_IRS IS
      SELECT
        TEXT
      FROM
        XTR_SYS_LANGUAGES_VL
      WHERE MODULE_NAME = 'XTROHINS'
        AND ITEM_NAME = 'Z1IRS_NOTE';
  BEGIN
    IF DEAL_TYPE = 'IRS' THEN
      IF CP_IRS_NOTE IS NULL THEN
        OPEN CUR_IRS;
        FETCH CUR_IRS
         INTO CP_IRS_NOTE;
        CLOSE CUR_IRS;
      END IF;
    END IF;
    IF HEDGE_TYPE <> 'UNASSIGNED' THEN
      RETURN (HEDGE_CURRENCY);
    ELSE
      OPEN CCY;
      FETCH CCY
       INTO L_CURR,L_BUY_CURR,L_SELL_CURR;
      CLOSE CCY;
      IF DEAL_TYPE in ('FX','FXO') THEN
        RETURN (L_BUY_CURR);
      ELSE
        RETURN (L_CURR);
      END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (NULL);
  END CURRFORMULA;
  FUNCTION CONTRA_CCY_DSPFORMULA(DEAL_NO_1 IN NUMBER
                                ,HEDGE_TYPE IN VARCHAR2
                                ,HEDGE_CURRENCY IN VARCHAR2
                                ,DEAL_TYPE IN VARCHAR2) RETURN CHAR IS
    L_CURR VARCHAR2(15);
    L_BUY_CURR VARCHAR2(15);
    L_SELL_CURR VARCHAR2(15);
    CURSOR CCY IS
      SELECT
        CURRENCY,
        CURRENCY_BUY,
        CURRENCY_SELL
      FROM
        XTR_DEALS
      WHERE DEAL_NO = DEAL_NO_1;
    CURSOR IRS_CCY IS
      SELECT
        CURRENCY
      FROM
        XTR_DEALS
      WHERE INT_SWAP_REF = (
        SELECT
          INT_SWAP_REF
        FROM
          XTR_DEALS
        WHERE DEAL_NO = DEAL_NO_1 )
        AND DEAL_SUBTYPE = 'INVEST'
        AND DEAL_TYPE = 'IRS';
  BEGIN
    IF HEDGE_TYPE <> 'UNASSIGNED' THEN
      RETURN (HEDGE_CURRENCY);
    ELSE
      OPEN CCY;
      FETCH CCY
       INTO L_CURR,L_BUY_CURR,L_SELL_CURR;
      CLOSE CCY;
      IF DEAL_TYPE in ('FX','FXO') THEN
        RETURN (L_SELL_CURR);
      ELSE
        RETURN (NULL);
      END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (NULL);
  END CONTRA_CCY_DSPFORMULA;
  FUNCTION OBJECTIVE_DSPFORMULA(OBJECTIVE_CODE IN VARCHAR2) RETURN CHAR IS
  BEGIN
    RETURN (GET_DSP_VALUE('XTR_HEDGE_OBJECTIVE_TYPES'
                        ,OBJECTIVE_CODE));
  END OBJECTIVE_DSPFORMULA;
  FUNCTION HDG_CONTRA_AMTFORMULA(DEAL_NO_1 IN NUMBER
                                ,CURRENCY_DSP IN VARCHAR2
                                ,HEDGE_TYPE IN VARCHAR2
                                ,CHEDGE_AMOUNT IN NUMBER
                                ,DEAL_TYPE IN VARCHAR2) RETURN NUMBER IS
    L_CURR VARCHAR2(15);
    L_BUY_CURR VARCHAR2(15);
    L_SELL_CURR VARCHAR2(15);
    L_BUY_AMOUNT NUMBER;
    L_SELL_AMOUNT NUMBER;
    L_FACE_VALUE NUMBER;
    L_DEAL_AMT NUMBER;
    L_ALLOC_AMT NUMBER;
    L_UNASGD_AMT NUMBER;
    L_AMOUNT NUMBER;
    ROUNDFAC NUMBER(3,2);
    CURSOR RND(P_CURR IN VARCHAR2) IS
      SELECT
        NVL(M.ROUNDING_FACTOR
           ,0)
      FROM
        XTR_MASTER_CURRENCIES_V M
      WHERE M.CURRENCY = P_CURR;
    CURSOR CCY IS
      SELECT
        CURRENCY,
        CURRENCY_BUY,
        CURRENCY_SELL,
        BUY_AMOUNT / NVL(P_UNIT
           ,1) BUY_AMOUNT,
        SELL_AMOUNT / NVL(P_UNIT
           ,1) SELL_AMOUNT,
        FACE_VALUE_AMOUNT / NVL(P_UNIT
           ,1) FACE_VALUE_AMOUNT
      FROM
        XTR_DEALS
      WHERE DEAL_NO = DEAL_NO_1;
    CURSOR ALLOC IS
      SELECT
        SUM(CUR_PCT_ALLOCATION)
      FROM
        XTR_HEDGE_RELATIONSHIPS HR,
        XTR_HEDGE_ATTRIBUTES HA
      WHERE HR.HEDGE_ATTRIBUTE_ID = HA.HEDGE_ATTRIBUTE_ID
        AND PRIMARY_CODE = DEAL_NO_1
        AND INSTRUMENT_ITEM_FLAG = 'U'
        AND START_DATE <= P_AS_OF_DATE_1
        AND ( HEDGE_STATUS IN ( 'CURRENT' , 'DESIGNATE' , 'FULFILLED' )
      OR ( HEDGE_STATUS in ( 'FAILED' , 'DEDESIGNATED' )
        AND P_AS_OF_DATE_1 <= HA.DISCONTINUE_DATE ) );
  BEGIN
    OPEN CCY;
    FETCH CCY
     INTO L_CURR,L_BUY_CURR,L_SELL_CURR,L_BUY_AMOUNT,L_SELL_AMOUNT,L_FACE_VALUE;
    CLOSE CCY;
    OPEN RND(CURRENCY_DSP);
    FETCH RND
     INTO ROUNDFAC;
    CLOSE RND;
    IF HEDGE_TYPE <> 'UNASSIGNED' THEN
      L_AMOUNT := (ABS(CHEDGE_AMOUNT));
    ELSE
      OPEN ALLOC;
      FETCH ALLOC
       INTO L_ALLOC_AMT;
      CLOSE ALLOC;
      IF DEAL_TYPE in ('FX','FXO') THEN
        L_AMOUNT := (ABS(L_BUY_AMOUNT) * (100 - NVL(L_ALLOC_AMT
                       ,0)) / 100);
      ELSE
        L_AMOUNT := (ABS(L_FACE_VALUE) * (100 - NVL(L_ALLOC_AMT
                       ,0)) / 100);
      END IF;
    END IF;
    RETURN ROUND(L_AMOUNT
                ,ROUNDFAC);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (NULL);
  END HDG_CONTRA_AMTFORMULA;
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
  FUNCTION HEDGE_TYPE_DSPFORMULA(HEDGE_TYPE IN VARCHAR2) RETURN CHAR IS
  BEGIN
    IF HEDGE_TYPE = 'UNASSIGNED' THEN
      RETURN (GET_DSP_VALUE('XTR_HEDGE_MISC'
                          ,HEDGE_TYPE));
    ELSE
      RETURN (GET_DSP_VALUE('XTR_HEDGE_TYPES'
                          ,HEDGE_TYPE));
    END IF;
  END HEDGE_TYPE_DSPFORMULA;
  FUNCTION COMPANY_NAMEFORMULA(COMPANY_CODE IN VARCHAR2) RETURN CHAR IS
    CURSOR COMPANY(P_COMPANY IN VARCHAR2) IS
      SELECT
        SHORT_NAME
      FROM
        XTR_PARTIES_V
      WHERE PARTY_CODE = P_COMPANY;
    L_COMPANY_NAME VARCHAR2(20);
  BEGIN
    IF COMPANY_CODE IS NOT NULL THEN
      OPEN COMPANY(COMPANY_CODE);
      FETCH COMPANY
       INTO L_COMPANY_NAME;
      CLOSE COMPANY;
    END IF;
    RETURN (L_COMPANY_NAME);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (NULL);
  END COMPANY_NAMEFORMULA;
  FUNCTION CHEDGE_AMOUNTFORMULA(HEDGE_NO IN NUMBER) RETURN NUMBER IS
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
    RETURN (L_CUR_REF_AMT / NVL(P_UNIT
              ,1));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END CHEDGE_AMOUNTFORMULA;
  FUNCTION CP_NO_GL_RATE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_NO_GL_RATE;
  END CP_NO_GL_RATE_P;
  FUNCTION CP_IRS_NOTE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_IRS_NOTE;
  END CP_IRS_NOTE_P;
END XTR_XTROHINS_XMLP_PKG;


/