--------------------------------------------------------
--  DDL for Package Body XTR_XTRCCYGL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_XTRCCYGL_XMLP_PKG" AS
/* $Header: XTRCCYGLB.pls 120.1 2007/12/28 12:42:59 npannamp noship $ */
  FUNCTION AFTERPFORM RETURN BOOLEAN IS
    L_FACTOR NUMBER(15) := 1;
  BEGIN
    BEGIN
    P_DATE_FROM_T:=P_DATE_FROM;
    P_DATE_TO_T := P_DATE_TO;
    P_REALIZED_FLAG_T:=P_REALIZED_FLAG;
      IF P_FACTOR IS NOT NULL THEN
        SELECT
          DECODE(SUBSTR(P_FACTOR
                       ,1
                       ,1)
                ,'U'
                ,1
                ,'T'
                ,1000
                ,'M'
                ,1000000
                ,'B'
                ,100000000),
          MEANING
        INTO
          L_FACTOR
          ,P_USER_FACTOR
        FROM
          FND_LOOKUPS
        WHERE LOOKUP_TYPE = 'XTR_FACTOR'
          AND LOOKUP_CODE = SUBSTR(P_FACTOR
              ,1
              ,1);
      ELSE
        L_FACTOR := 1000;
      END IF;
      P_UNIT := L_FACTOR;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
    BEGIN
      --IF P_REALIZED_FLAG IS NOT NULL THEN
      IF P_REALIZED_FLAG_T IS NOT NULL THEN
        SELECT
          MEANING
        INTO
          Z2REALIZED_FLAG
        FROM
          FND_LOOKUPS
        WHERE LOOKUP_TYPE = 'XTR_MISC'
          --AND LOOKUP_CODE = P_REALIZED_FLAG;
          AND LOOKUP_CODE = P_REALIZED_FLAG_T;
        IF P_REALIZED_FLAG_T = 'REAL' THEN
          P_REALIZED_FLAG_T := 'Y';
        ELSE
          P_REALIZED_FLAG_T := 'N';
        END IF;
      ELSE
        P_REALIZED_FLAG_T := 'N';
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
    BEGIN
      IF P_DEAL_TYPE IS NOT NULL AND P_DEAL_TYPE < 'HEDGE' THEN
        SELECT
          USER_DEAL_TYPE
        INTO
          P_USER_DEAL_TYPE
        FROM
          XTR_DEAL_TYPES
        WHERE DEAL_TYPE = P_DEAL_TYPE;
      ELSIF P_DEAL_TYPE IS NOT NULL AND P_DEAL_TYPE = 'HEDGE' THEN
        SELECT
          MEANING
        INTO
          P_USER_DEAL_TYPE
        FROM
          FND_LOOKUPS
        WHERE LOOKUP_TYPE = 'XTR_HEDGE_MISC'
          AND LOOKUP_CODE = 'HEDGE';
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
    BEGIN
      IF P_GROUPBY IS NOT NULL THEN
        SELECT
          MEANING
        INTO
          P_USER_GROUPBY
        FROM
          FND_LOOKUPS
        WHERE LOOKUP_TYPE = 'XTR_MISC'
          AND LOOKUP_CODE = P_GROUPBY;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
    BEGIN
      IF P_COMPANY IS NOT NULL THEN
        SELECT
          SUBSTR(SHORT_NAME
                ,1
                ,30)
        INTO
          P_USER_COMPANY
        FROM
          XTR_PARTY_INFO
        WHERE PARTY_CODE = P_COMPANY
          AND PARTY_TYPE = 'C';
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
    BEGIN
      IF P_BATCH_ID_FROM IS NOT NULL THEN
        SELECT
          TO_CHAR(MIN(PERIOD_START)
                 ,'YYYY/MM/DD HH24:MI:SS')
        INTO
          P_DATE_FROM_T
        FROM
          XTR_BATCHES B,
          XTR_BATCH_EVENTS E
        WHERE B.BATCH_ID = E.BATCH_ID
          AND E.EVENT_CODE = 'REVAL'
          AND B.BATCH_ID >= P_BATCH_ID_FROM;
        P_USER_DATE_FROM := TO_DATE(P_DATE_FROM_T
                                   ,'YYYY/MM/DD HH24:MI:SS');
      END IF;
      IF P_BATCH_ID_TO IS NOT NULL THEN
        SELECT
          TO_CHAR(MAX(PERIOD_END)
                 ,'YYYY/MM/DD HH24:MI:SS')
        INTO
          P_DATE_TO_T
        FROM
          XTR_BATCHES B,
          XTR_BATCH_EVENTS E
        WHERE B.BATCH_ID = E.BATCH_ID
          AND E.EVENT_CODE = 'REVAL'
          AND B.BATCH_ID <= P_BATCH_ID_TO;
        P_USER_DATE_TO := TO_DATE(P_DATE_TO_T
                                 ,'YYYY/MM/DD HH24:MI:SS');
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
    L_DMMY_NUM NUMBER;
    L_MESSAGE FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;
    CURSOR GET_LANGUAGE_DESC IS
      SELECT
        ITEM_NAME,
        SUBSTR(TEXT
              ,1
              ,100) LANG_NAME
      FROM
        XTR_SYS_LANGUAGES_VL
      WHERE MODULE_NAME = 'XTRCCYGL';
  BEGIN
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    FOR c IN GET_LANGUAGE_DESC LOOP
      IF C.ITEM_NAME = 'Z2COMPANY' THEN
        Z2COMPANY := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z2REPORT_PRD' THEN
        Z2REPORT_PRD := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z2REVAL_CCY' THEN
        Z2REVAL_CCY := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z2SOB_CCY' THEN
        Z2SOB_CCY := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z2PORTFOLIO' THEN
        Z2PORTFOLIO := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z2DEAL_TYPE' THEN
        Z2DEAL_TYPE := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z2DEAL_SUBTYPE' THEN
        Z2DEAL_SUBTYPE := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z2PRODUCT_TYPE' THEN
        Z2PRODUCT_TYPE := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z2REFERENCE' THEN
        Z2REFERENCE := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z2START' THEN
        Z2START := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z2PRDEND' THEN
        Z2PRDEND := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z2PERIOD' THEN
        Z2PERIOD := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z2BUY' THEN
        Z2BUY := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z2SELL' THEN
        Z2SELL := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z2CCY' THEN
        Z2CCY := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z2CCY_SHT' THEN
        Z2CCY_SHT := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z2AMOUNT' THEN
        Z2AMOUNT := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z2TRANS' THEN
        Z2TRANS := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z2BEGIN' THEN
        Z2BEGIN := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z2FAIR_VALUE' THEN
        Z2FAIR_VALUE := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z2END' THEN
        Z2END := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z2GL_RATE' THEN
        Z2GL_RATE := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z2GAIN_LOSS' THEN
        Z2GAIN_LOSS := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z2TOTAL' THEN
        Z2TOTAL := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z2END_OF_REPORT' THEN
        Z2END_OF_REPORT := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z2NO_DATA_FOUND' THEN
        Z2NO_DATA_FOUND := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z1BATCH_ID_FROM' THEN
        Z1BATCH_ID_FROM := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z1BATCH_ID_TO' THEN
        Z1BATCH_ID_TO := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z1DATE_FROM' THEN
        Z1DATE_FROM := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z1DATE_TO' THEN
        Z1DATE_TO := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z1PARA_GROUPING' THEN
        Z1PARA_GROUPING := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z1REAL_UNREAL' THEN
        Z1REAL_UNREAL := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z1FACTOR' THEN
        Z1FACTOR := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z1REPHEAD_REAL' THEN
        Z1REPHEAD_REAL := C.LANG_NAME;
      ELSIF C.ITEM_NAME = 'Z1REPHEAD_UNREAL' THEN
        Z1REPHEAD_UNREAL := C.LANG_NAME;
      END IF;
    END LOOP;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION C_DATEFORMATFORMULA(C_DATEFORMAT IN VARCHAR2) RETURN CHAR IS
  BEGIN
    RETURN (fnd_global.nls_date_format);
  END C_DATEFORMATFORMULA;

  FUNCTION CO_SHT_NAMEFORMULA(COMPANY IN VARCHAR2) RETURN CHAR IS
    L_SHT_NAME VARCHAR2(30);
  BEGIN
    IF COMPANY IS NOT NULL THEN
      SELECT
        SHORT_NAME
      INTO
        L_SHT_NAME
      FROM
        XTR_PARTY_INFO
      WHERE PARTY_CODE = COMPANY
        AND PARTY_TYPE = 'C';
    END IF;
    RETURN (L_SHT_NAME);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (NULL);
  END CO_SHT_NAMEFORMULA;

  FUNCTION C_REPORT_NAMEFORMULA RETURN CHAR IS
    L_REPORT_NAME VARCHAR2(240);
  BEGIN
    IF P_REALIZED_FLAG_T in ('Y','REAL') THEN
      L_REPORT_NAME := Z1REPHEAD_REAL;
    ELSE
      L_REPORT_NAME := Z1REPHEAD_UNREAL;
    END IF;
    RETURN (L_REPORT_NAME);
  EXCEPTION
    WHEN OTHERS THEN
      SELECT
        SUBSTR(CP.USER_CONCURRENT_PROGRAM_NAME
              ,INSTR(CP.USER_CONCURRENT_PROGRAM_NAME
                   ,'-') + 2)
      INTO
        L_REPORT_NAME
      FROM
        FND_CONCURRENT_PROGRAMS_VL CP,
        FND_CONCURRENT_REQUESTS CR
      WHERE CR.REQUEST_ID = P_CONC_REQUEST_ID
        AND CP.APPLICATION_ID = CR.PROGRAM_APPLICATION_ID
        AND CP.CONCURRENT_PROGRAM_ID = CR.CONCURRENT_PROGRAM_ID;
      RETURN (L_REPORT_NAME);
  END C_REPORT_NAMEFORMULA;

  FUNCTION USER_DEAL_SUBTYPEFORMULA(DEAL_SUBTYPE_P IN VARCHAR2
                                   ,DEAL_TYPE_P IN VARCHAR2) RETURN CHAR IS
    L_USER_DEAL_SUBTYPE VARCHAR2(30);
  BEGIN
    IF DEAL_SUBTYPE_P IS NOT NULL AND DEAL_TYPE_P < 'HEDGE' THEN
      SELECT
        SUBSTR(USER_DEAL_SUBTYPE
              ,1
              ,30)
      INTO
        L_USER_DEAL_SUBTYPE
      FROM
        XTR_DEAL_SUBTYPES
      WHERE DEAL_SUBTYPE = DEAL_SUBTYPE_P
        AND DEAL_TYPE = DEAL_TYPE_P;
    ELSIF DEAL_SUBTYPE_P IS NOT NULL AND DEAL_TYPE_P = 'HEDGE' THEN
      SELECT
        SUBSTR(MEANING
              ,1
              ,30)
      INTO
        L_USER_DEAL_SUBTYPE
      FROM
        FND_LOOKUPS
      WHERE LOOKUP_TYPE = 'XTR_HEDGE_TYPES'
        AND LOOKUP_CODE = DEAL_SUBTYPE_p;
    END IF;
    RETURN (L_USER_DEAL_SUBTYPE);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (NULL);
  END USER_DEAL_SUBTYPEFORMULA;

  FUNCTION USER_DEAL_TYPEFORMULA(DEAL_TYPE_p IN VARCHAR2) RETURN CHAR IS
    L_USER_DEAL_TYPE VARCHAR2(30);
  BEGIN
    IF DEAL_TYPE_p IS NOT NULL AND DEAL_TYPE_p < 'HEDGE' THEN
      SELECT
        SUBSTR(USER_DEAL_TYPE
              ,1
              ,30)
      INTO
        L_USER_DEAL_TYPE
      FROM
        XTR_DEAL_TYPES
      WHERE DEAL_TYPE = DEAL_TYPE_p;
    ELSIF DEAL_TYPE_p IS NOT NULL AND DEAL_TYPE_p = 'HEDGE' THEN
      SELECT
        SUBSTR(MEANING
              ,1
              ,30)
      INTO
        L_USER_DEAL_TYPE
      FROM
        FND_LOOKUPS
      WHERE LOOKUP_TYPE = 'XTR_HEDGE_MISC'
        AND LOOKUP_CODE = 'HEDGE';
    END IF;
    RETURN (L_USER_DEAL_TYPE);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (NULL);
  END USER_DEAL_TYPEFORMULA;

  FUNCTION FAIR_VALUEFORMULA(COMPANY_P IN VARCHAR2
                            ,REF_NUMBER_P IN VARCHAR2
                            ,PERIOD_END_p IN DATE
                            ,BATCH_ID_P IN NUMBER
                            ,DEAL_TYPE IN VARCHAR2) RETURN NUMBER IS
    L_FAIR_VALUE NUMBER;
    CURSOR C_UNREAL IS
      SELECT
        A.FAIR_VALUE
      FROM
        XTR_REVALUATION_DETAILS_SUM_V A,
        XTR_BATCHES B
      WHERE A.COMPANY_CODE = COMPANY_p
        AND A.COMPANY_CODE = B.COMPANY_CODE
        AND A.BATCH_ID = B.BATCH_ID
        AND A.REF_NUMBER = REF_NUMBER_P
        AND B.PERIOD_END <= PERIOD_END_p
        AND A.REALIZED_FLAG = P_REALIZED_FLAG_T
      ORDER BY
        B.PERIOD_END DESC;
    CURSOR C_UNREAL_FIRST IS
      SELECT
        INITIAL_FAIR_VALUE
      FROM
        XTR_DEALS
      WHERE DEAL_NO = REF_NUMBER_p;
    CURSOR C_FIRST_TRANS IS
      SELECT
        SUM(INITIAL_FAIR_VALUE)
      FROM
        XTR_ROLLOVER_TRANSACTIONS
      WHERE DEAL_NUMBER = REF_NUMBER_p;
    CURSOR C_IRS IS
      SELECT
        SUM(INITIAL_FAIR_VALUE)
      FROM
        XTR_DEALS
      WHERE INT_SWAP_REF = REF_NUMBER_p;
    CURSOR C_CA_FV IS
      SELECT
        FAIR_VALUE
      FROM
        XTR_REVALUATION_DETAILS
      WHERE ACCOUNT_NO = REF_NUMBER_P
        AND DEAL_TYPE = 'CA'
        AND BATCH_ID = BATCH_ID_P
        AND EFFECTIVE_DATE = (
        SELECT
          MAX(EFFECTIVE_DATE)
        FROM
          XTR_REVALUATION_DETAILS
        WHERE ACCOUNT_NO = REF_NUMBER_p
          AND DEAL_TYPE = 'CA'
          AND BATCH_ID = BATCH_ID_p );
    CURSOR C_IG_FV IS
      SELECT
        FAIR_VALUE
      FROM
        XTR_REVALUATION_DETAILS
      WHERE DEAL_NO = TO_NUMBER(REF_NUMBER_p)
        AND DEAL_TYPE = 'IG'
        AND BATCH_ID = BATCH_ID_p
        AND EFFECTIVE_DATE = (
        SELECT
          MAX(EFFECTIVE_DATE)
        FROM
          XTR_REVALUATION_DETAILS
        WHERE DEAL_NO = REF_NUMBER_p
          AND DEAL_TYPE = 'IG'
          AND BATCH_ID = BATCH_ID_p );
    CURSOR C_ONC_FV IS
      SELECT
        SUM(FACE_VALUE)
      FROM
        XTR_REVALUATION_DETAILS
      WHERE DEAL_NO = TO_NUMBER(REF_NUMBER_p)
        AND DEAL_TYPE = 'ONC'
        AND BATCH_ID = BATCH_ID_p
        AND NVL(REALIZED_FLAG
         ,'N') = 'N'
        AND ( ( COMPLETE_FLAG = 'Y'
        AND TRANSACTION_NO in (
        SELECT
          TRANSACTION_NUMBER
        FROM
          XTR_ROLLOVER_TRANSACTIONS
        WHERE DEAL_NUMBER = TO_NUMBER(REF_NUMBER_p)
          AND START_DATE <= PERIOD_END_p
          AND ( CROSS_REF_TO_TRANS is null
        OR CROSS_REF_TO_TRANS not in (
          SELECT
            TRANSACTION_NO
          FROM
            XTR_REVALUATION_DETAILS
          WHERE DEAL_NO = TO_NUMBER(REF_NUMBER_p)
            AND BATCH_ID = BATCH_ID_p ) ) ) )
      OR ( COMPLETE_FLAG = 'N'
        AND TRANSACTION_NO = 1 ) );
  BEGIN
    IF DEAL_TYPE = 'CA' THEN
      OPEN C_CA_FV;
      FETCH C_CA_FV
       INTO
         L_FAIR_VALUE;
      CLOSE C_CA_FV;
    ELSIF DEAL_TYPE = 'IG' THEN
      OPEN C_IG_FV;
      FETCH C_IG_FV
       INTO
         L_FAIR_VALUE;
      CLOSE C_IG_FV;
    ELSIF DEAL_TYPE = 'ONC' THEN
      OPEN C_ONC_FV;
      FETCH C_ONC_FV
       INTO
         L_FAIR_VALUE;
      CLOSE C_ONC_FV;
    END IF;
    IF P_REALIZED_FLAG_T = 'Y' AND DEAL_TYPE not in ('FRA','IG','ONC','CA') THEN
      IF DEAL_TYPE in ('IRS') THEN
        OPEN C_IRS;
        FETCH C_IRS
         INTO
           L_FAIR_VALUE;
        CLOSE C_IRS;
      ELSE
        SELECT
          INITIAL_FAIR_VALUE
        INTO
          L_FAIR_VALUE
        FROM
          XTR_DEALS
        WHERE DEAL_NO = REF_NUMBER_p;
      END IF;
      IF L_FAIR_VALUE IS NULL AND DEAL_TYPE in ('NI') THEN
        OPEN C_FIRST_TRANS;
        FETCH C_FIRST_TRANS
         INTO
           L_FAIR_VALUE;
        CLOSE C_FIRST_TRANS;
      END IF;
    ELSIF P_REALIZED_FLAG_T = 'N' AND DEAL_TYPE not in ('IG','ONC','CA') THEN
      OPEN C_UNREAL;
      FETCH C_UNREAL
       INTO
         L_FAIR_VALUE;
      CLOSE C_UNREAL;
      IF L_FAIR_VALUE IS NULL AND DEAL_TYPE in ('NI') THEN
        OPEN C_FIRST_TRANS;
        FETCH C_FIRST_TRANS
         INTO
           L_FAIR_VALUE;
        CLOSE C_FIRST_TRANS;
      END IF;
    ELSIF P_REALIZED_FLAG_T = 'Y' AND DEAL_TYPE in ('FRA') THEN
      OPEN C_UNREAL;
      FETCH C_UNREAL
       INTO
         L_FAIR_VALUE;
      CLOSE C_UNREAL;
    END IF;
    RETURN (L_FAIR_VALUE / NVL(P_UNIT
              ,1000));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (NULL);
  END FAIR_VALUEFORMULA;

  FUNCTION BEGIN_RATEFORMULA(COMPANY IN VARCHAR2
                            ,REF_NUMBER_p IN VARCHAR2
                            ,PERIOD_START_p IN DATE
                            ,DEAL_TYPE IN VARCHAR2) RETURN NUMBER IS
    CURSOR C_BEGIN_RATE IS
      SELECT
        ROUND(A.EXCHANGE_RATE_ONE
             ,4)
      FROM
        XTR_REVALUATION_DETAILS_SUM_V A,
        XTR_BATCHES B
      WHERE A.COMPANY_CODE = COMPANY
        AND A.COMPANY_CODE = B.COMPANY_CODE
        AND A.BATCH_ID = B.BATCH_ID
        AND A.REF_NUMBER = REF_NUMBER_p
        AND B.PERIOD_END < PERIOD_START_p
        AND A.REALIZED_FLAG = P_REALIZED_FLAG_T
      ORDER BY
        PERIOD_START desc;
    CURSOR C_INIT_RATE IS
      SELECT
        EXCHANGE_RATE_ONE
      FROM
        XTR_DEALS
      WHERE DEAL_NO = REF_NUMBER_p;
    CURSOR C_IRS_RATE IS
      SELECT
        AVG(EXCHANGE_RATE_ONE)
      FROM
        XTR_DEALS
      WHERE INT_SWAP_REF = REF_NUMBER_p;
    CURSOR C_NI_INIT_RATE IS
      SELECT
        AVG(CURRENCY_EXCHANGE_RATE)
      FROM
        XTR_ROLLOVER_TRANSACTIONS
      WHERE DEAL_NUMBER = REF_NUMBER_p;
    L_BEGIN_RATE NUMBER;
  BEGIN
    IF P_REALIZED_FLAG_T = 'Y' AND DEAL_TYPE not in ('CA','IG','ONC','FX') THEN
      --IF DEAL_TYPE < 'IRS' THEN
      IF DEAL_TYPE <> 'IRS' THEN
        OPEN C_INIT_RATE;
        FETCH C_INIT_RATE
         INTO
           L_BEGIN_RATE;
        CLOSE C_INIT_RATE;
        IF L_BEGIN_RATE IS NULL AND DEAL_TYPE = 'NI' THEN
          OPEN C_NI_INIT_RATE;
          FETCH C_NI_INIT_RATE
           INTO
             L_BEGIN_RATE;
          CLOSE C_NI_INIT_RATE;
        END IF;
      ELSIF DEAL_TYPE = 'IRS' THEN
        OPEN C_IRS_RATE;
        FETCH C_IRS_RATE
         INTO
           L_BEGIN_RATE;
        CLOSE C_IRS_RATE;
      END IF;
    ELSIF P_REALIZED_FLAG_T = 'N' AND DEAL_TYPE not in ('CA','IG','ONC','FX') THEN
      OPEN C_BEGIN_RATE;
      FETCH C_BEGIN_RATE
       INTO
         L_BEGIN_RATE;
      CLOSE C_BEGIN_RATE;
      IF L_BEGIN_RATE IS NULL THEN
        IF DEAL_TYPE = 'IRS' THEN
          OPEN C_IRS_RATE;
          FETCH C_IRS_RATE
           INTO
             L_BEGIN_RATE;
          CLOSE C_IRS_RATE;
        --ELSIF DEAL_TYPE < 'IRS' THEN
        ELSIF DEAL_TYPE <> 'IRS' THEN
          OPEN C_INIT_RATE;
          FETCH C_INIT_RATE
           INTO
             L_BEGIN_RATE;
          CLOSE C_INIT_RATE;
        END IF;
        IF L_BEGIN_RATE IS NULL AND DEAL_TYPE = 'NI' THEN
          OPEN C_NI_INIT_RATE;
          FETCH C_NI_INIT_RATE
           INTO
             L_BEGIN_RATE;
          CLOSE C_NI_INIT_RATE;
        END IF;
      END IF;
    ELSIF DEAL_TYPE in ('CA','IG','ONC','FX') THEN
      RETURN (NULL);
    END IF;
    RETURN (ROUND(L_BEGIN_RATE
                ,5));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (NULL);
  END BEGIN_RATEFORMULA;

  FUNCTION END_RATEFORMULA(COMPANY_p IN VARCHAR2
                          ,REF_NUMBER_p IN VARCHAR2
                          ,PERIOD_END_p IN DATE
                          ,DEAL_TYPE IN VARCHAR2) RETURN NUMBER IS

   CURSOR C_END_RATE IS
      SELECT
        A.EXCHANGE_RATE_ONE
      FROM
        XTR_REVALUATION_DETAILS_SUM_V A,
        XTR_BATCHES B
      WHERE A.COMPANY_CODE = COMPANY_P
        AND A.COMPANY_CODE = B.COMPANY_CODE
        AND A.BATCH_ID = B.BATCH_ID
        AND A.REF_NUMBER = REF_NUMBER_p
        AND B.PERIOD_END <= PERIOD_END_p
        AND A.REALIZED_FLAG = P_REALIZED_FLAG_T
      ORDER BY
        PERIOD_START DESC;
    CURSOR C_INIT_RATE IS
      SELECT
        EXCHANGE_RATE_ONE
      FROM
        XTR_DEALS
      WHERE DEAL_NO = REF_NUMBER_p;
    L_END_RATE NUMBER;

  BEGIN
    IF DEAL_TYPE not in ('CA','IG','ONC','FX') THEN
      OPEN C_END_RATE;
      FETCH C_END_RATE
       INTO
         L_END_RATE;
      CLOSE C_END_RATE;
    ELSE
      RETURN (NULL);
    END IF;
    RETURN (ROUND(L_END_RATE
                ,5));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (NULL);
  END END_RATEFORMULA;

  FUNCTION REPORT_PRDFORMULA(C_DATEFORMAT IN VARCHAR2) RETURN CHAR IS
    L_TEMP VARCHAR2(100);
  BEGIN
    IF P_DATE_FROM_T IS NOT NULL AND P_DATE_TO_T IS NOT NULL THEN
      L_TEMP := TO_CHAR(TO_DATE(P_DATE_FROM_T
                               ,'YYYY/MM/DD HH24:MI:SS')
                       ,C_DATEFORMAT) || ' - ' || TO_CHAR(TO_DATE(P_DATE_TO_T
                               ,'YYYY/MM/DD HH24:MI:SS')
                       ,C_DATEFORMAT);
    END IF;
    RETURN (L_TEMP);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END REPORT_PRDFORMULA;

  FUNCTION SOB_CCYFORMULA(COMPANY IN VARCHAR2) RETURN CHAR IS
    L_SOB_CCY VARCHAR2(10);
  BEGIN
    SELECT
      CURRENCY_CODE
    INTO
      L_SOB_CCY
    FROM
      GL_SETS_OF_BOOKS B,
      XTR_PARTY_INFO P
    WHERE PARTY_CODE = COMPANY
      AND PARTY_TYPE = 'C'
      AND P.SET_OF_BOOKS_ID = B.SET_OF_BOOKS_ID;
    RETURN (L_SOB_CCY);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (NULL);
  END SOB_CCYFORMULA;

  FUNCTION FAIR_VALUE_RNDFORMULA(REVAL_CCY IN VARCHAR2
                                ,FAIR_VALUE IN NUMBER) RETURN NUMBER IS
    L_ROUND NUMBER;
    CURSOR C_ROUND IS
      SELECT
        ROUNDING_FACTOR
      FROM
        XTR_MASTER_CURRENCIES_V
      WHERE CURRENCY = REVAL_CCY;
  BEGIN
    OPEN C_ROUND;
    FETCH C_ROUND
     INTO
       L_ROUND;
    CLOSE C_ROUND;
    RETURN (ROUND(FAIR_VALUE
                ,L_ROUND));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FAIR_VALUE);

  END FAIR_VALUE_RNDFORMULA;

  FUNCTION GAIN_LOSS_RNDFORMULA(REVAL_CCY IN VARCHAR2
                               ,GAIN_LOSS IN NUMBER) RETURN NUMBER IS
    L_ROUND NUMBER;
    CURSOR C_ROUND IS
      SELECT
        ROUNDING_FACTOR
      FROM
        XTR_MASTER_CURRENCIES_V
      WHERE CURRENCY = REVAL_CCY;
  BEGIN
    OPEN C_ROUND;
    FETCH C_ROUND
     INTO
       L_ROUND;
    CLOSE C_ROUND;
    RETURN (ROUND(GAIN_LOSS
                ,L_ROUND));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (GAIN_LOSS);
  END GAIN_LOSS_RNDFORMULA;

  FUNCTION BASE_AMT_RNDFORMULA(REVAL_CCY IN VARCHAR2
                              ,BASE_AMOUNT IN NUMBER) RETURN NUMBER IS
    L_ROUND NUMBER;
    CURSOR C_ROUND IS
      SELECT
        ROUNDING_FACTOR
      FROM
        XTR_MASTER_CURRENCIES_V
      WHERE CURRENCY = REVAL_CCY;
  BEGIN
    OPEN C_ROUND;
    FETCH C_ROUND
     INTO
       L_ROUND;
    CLOSE C_ROUND;
    RETURN (ROUND(BASE_AMOUNT
                ,L_ROUND));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (BASE_AMOUNT);
  END BASE_AMT_RNDFORMULA;

END XTR_XTRCCYGL_XMLP_PKG;


/
