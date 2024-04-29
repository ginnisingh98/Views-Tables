--------------------------------------------------------
--  DDL for Package Body JL_JLMXFGLR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_JLMXFGLR_XMLP_PKG" AS
/* $Header: JLMXFGLRB.pls 120.1 2007/12/25 16:52:30 dwkrishn noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    IF UPPER(P_MRCSOBTYPE) = 'R' THEN
      FND_CLIENT_INFO.SET_CURRENCY_CONTEXT(P_CA_SET_OF_BOOKS_ID);
    END IF;
    GET_BASE_CURR_DATA;
    CUSTOM_INIT;
    RETURN (TRUE);
  END BEFOREREPORT;

  PROCEDURE GET_BASE_CURR_DATA IS
    BASE_CURR AP_SYSTEM_PARAMETERS.BASE_CURRENCY_CODE%TYPE;
    PREC FND_CURRENCIES_VL.PRECISION%TYPE;
    MIN_AU FND_CURRENCIES_VL.MINIMUM_ACCOUNTABLE_UNIT%TYPE;
    DESCR FND_CURRENCIES_VL.DESCRIPTION%TYPE;
    ORG_NAME GL_SETS_OF_BOOKS.NAME%TYPE;
  BEGIN
    BASE_CURR := '';
    PREC := 0;
    MIN_AU := 0;
    DESCR := '';
    ORG_NAME := '';
    IF UPPER(P_MRCSOBTYPE) = 'R' THEN
      BEGIN
        SELECT
          FCURR.CURRENCY_CODE,
          FCURR.PRECISION,
          FCURR.MINIMUM_ACCOUNTABLE_UNIT,
          FCURR.DESCRIPTION,
          GSBKS.NAME
        INTO BASE_CURR,PREC,MIN_AU,DESCR,ORG_NAME
        FROM
          FA_BOOK_CONTROLS_MRC_V BKCTRL,
          FND_CURRENCIES_VL FCURR,
          GL_SETS_OF_BOOKS GSBKS
        WHERE BKCTRL.BOOK_TYPE_CODE = P_BOOK_TYPE_CODE
          AND BKCTRL.SET_OF_BOOKS_ID = GSBKS.SET_OF_BOOKS_ID
          AND GSBKS.CURRENCY_CODE = FCURR.CURRENCY_CODE;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RAISE_ERR('JL_AR_FA_CUR_DET_NOT_DEFINED'
                   ,'N');
        WHEN OTHERS THEN
          RAISE_ORA_ERR;
      END;
    ELSE
      BEGIN
        SELECT
          FCURR.CURRENCY_CODE,
          FCURR.PRECISION,
          FCURR.MINIMUM_ACCOUNTABLE_UNIT,
          FCURR.DESCRIPTION,
          GSBKS.NAME
        INTO BASE_CURR,PREC,MIN_AU,DESCR,ORG_NAME
        FROM
          FA_BOOK_CONTROLS BKCTRL,
          FND_CURRENCIES_VL FCURR,
          GL_SETS_OF_BOOKS GSBKS
        WHERE BKCTRL.BOOK_TYPE_CODE = P_BOOK_TYPE_CODE
          AND BKCTRL.SET_OF_BOOKS_ID = GSBKS.SET_OF_BOOKS_ID
          AND GSBKS.CURRENCY_CODE = FCURR.CURRENCY_CODE;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RAISE_ERR('JL_AR_FA_CUR_DET_NOT_DEFINED'
                   ,'N');
        WHEN OTHERS THEN
          RAISE_ORA_ERR;
      END;
    END IF;
    C_BASE_CURRENCY_CODE := BASE_CURR;
    C_BASE_PRECISION := PREC;
    C_BASE_MIN_ACCT_UNIT := MIN_AU;
    C_BASE_DESCRIPTION := DESCR;
    C_ORGANIZATION_NAME := ORG_NAME;
  END GET_BASE_CURR_DATA;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    EXCEPTION
      WHEN OTHERS THEN
        /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
    END;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION C_PRICE_INDEXFORMULA(ASSET_CATEGORY IN NUMBER
                               ,ACQDATE IN DATE) RETURN NUMBER IS
    X NUMBER(15);
    CATEGORY_DESC VARCHAR2(40);
    ERRMSG VARCHAR2(1000);
  BEGIN
    SELECT
      FPI.PRICE_INDEX_ID
    INTO X
    FROM
      FA_PRICE_INDEXES FPI,
      FA_CATEGORY_BOOK_DEFAULTS FCBD
    WHERE FCBD.BOOK_TYPE_CODE = P_BOOK_TYPE_CODE
      AND FCBD.CATEGORY_ID = ASSET_CATEGORY
      AND ACQDATE >= FCBD.START_DPIS
      AND ACQDATE <= NVL(FCBD.END_DPIS
       ,ACQDATE)
      AND FCBD.PRICE_INDEX_NAME = FPI.PRICE_INDEX_NAME;
    IF X IS NULL THEN
      RAISE NO_DATA_FOUND;
    END IF;
    RETURN (X);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      SELECT
        DESCRIPTION
      INTO CATEGORY_DESC
      FROM
        FA_CATEGORIES
      WHERE CATEGORY_ID = ASSET_CATEGORY;
      SET_NAME('JL'
              ,'JL_ZZ_FA_INDX_NOT_DEF_FOR_CATG');
      SET_TOKEN('ASSET_CATEGORY'
               ,CATEGORY_DESC
               ,FALSE);
      ERRMSG := GET;
      /*SRW.MESSAGE(JL_ZZ_FA_UTILITIES_PKG.GET_APP_ERRNUM('JL'
                                                       ,'JL_ZZ_FA_INDX_NOT_DEF_FOR_CATG')
                 ,ERRMSG)*/NULL;
      /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
      RETURN NULL;
    WHEN OTHERS THEN
      RAISE_ORA_ERR;
      RETURN NULL;
  END C_PRICE_INDEXFORMULA;

  FUNCTION C_INDEX_VALUEFORMULA(C_PRICE_INDEX IN NUMBER
                               ,ACQDATE IN DATE) RETURN NUMBER IS
    X NUMBER;
    ERRMSG VARCHAR2(1000);
    INDEX_NAME VARCHAR2(40);
  BEGIN
    BEGIN
      SELECT
        PRICE_INDEX_VALUE
      INTO X
      FROM
        FA_PRICE_INDEX_VALUES
      WHERE PRICE_INDEX_ID = C_PRICE_INDEX
        AND ACQDATE BETWEEN FROM_DATE
        AND TO_DATE;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        SELECT
          PRICE_INDEX_NAME
        INTO INDEX_NAME
        FROM
          FA_PRICE_INDEXES
        WHERE PRICE_INDEX_ID = C_PRICE_INDEX;
        SET_NAME('JL'
                ,'JL_ZZ_FA_INDX_VAL_NOT_FOUND');
        SET_TOKEN('PRICE_INDEX'
                 ,INDEX_NAME
                 ,FALSE);
        SET_TOKEN('MISSING_DATE'
                 ,TO_CHAR(ACQDATE)
                 ,FALSE);
        ERRMSG := GET;
        /*SRW.MESSAGE(JL_ZZ_FA_UTILITIES_PKG.GET_APP_ERRNUM('JL'
                                                         ,'JL_ZZ_FA_INDX_VAL_NOT_FOUND')
                   ,ERRMSG)*/NULL;
        /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
        RETURN NULL;
      WHEN OTHERS THEN
        RAISE_ORA_ERR;
        RETURN NULL;
    END;
    RETURN (NVL(X
              ,0));
  END C_INDEX_VALUEFORMULA;

  FUNCTION C_CORR_FACTORFORMULA(C_INDEX_VALUE_HALF_PERIOD IN NUMBER
                               ,C_INDEX_VALUE IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (TRUNC(C_INDEX_VALUE_HALF_PERIOD / C_INDEX_VALUE
                ,C_RATIO_PRECISION));
  END C_CORR_FACTORFORMULA;

  FUNCTION C_ACCUM_DEPRN_PREV_YRFORMULA(ASSET_ID IN NUMBER
                                       ,PERIOD_COUNTER IN NUMBER
                                       ,RETIREMENT_ID IN NUMBER
                                       ,ORIGINAL_COST IN NUMBER) RETURN NUMBER IS
    T_ASSET_ID NUMBER := ASSET_ID;
    T_BOOK_TYPE_CODE VARCHAR(30) := P_BOOK_TYPE_CODE;
    T_PERIOD_START NUMBER := C_MIN_PERIOD_COUNTER;
    T_PERIOD_END NUMBER := C_MAX_PERIOD_COUNTER;
    T_PERIOD_COUNTER NUMBER := PERIOD_COUNTER;
    T_RETIREMENT_ID NUMBER := RETIREMENT_ID;
    T_ACC_DEPRN_PREV_FY NUMBER;
    L_NR_COST NUMBER;
    L_HAS_RESERVE_ADJUSTMENT NUMBER := 0;
    L_HAS_RETIREMENT NUMBER := 0;
    L_TOTAL_DEPRN_ADJUSTMENT NUMBER := 0;
    L_LAST_DEPRN_PERIOD_PREV_FY NUMBER;
    L_ACC_DEPRN_PREV_FY NUMBER := 0;
    L_ADJUSTED_COST_PREV_FY NUMBER := 0;
    L_PREV_ADJUSTED_COST NUMBER;
    L_COST_RETIRED NUMBER := ORIGINAL_COST;
    L_ADJ_COST_LESS_PART_RET NUMBER;
    L_COST_BEGIN_YEAR NUMBER;
    CURSOR C_RET_DEPRN_SUMMARY IS
      SELECT
        FDS.ADJUSTED_COST,
        FDS.PERIOD_COUNTER
      FROM
        FA_DEPRN_SUMMARY FDS
      WHERE FDS.BOOK_TYPE_CODE = T_BOOK_TYPE_CODE
        AND FDS.ASSET_ID = T_ASSET_ID
        AND FDS.PERIOD_COUNTER between T_PERIOD_START
        AND T_PERIOD_COUNTER;
    CURSOR C_RET_DEPRN_SUMMARY_MRC IS
      SELECT
        FDS.ADJUSTED_COST,
        FDS.PERIOD_COUNTER
      FROM
        FA_DEPRN_SUMMARY FDS
      WHERE FDS.BOOK_TYPE_CODE = T_BOOK_TYPE_CODE
        AND FDS.ASSET_ID = T_ASSET_ID
        AND FDS.PERIOD_COUNTER between T_PERIOD_START
        AND T_PERIOD_COUNTER;
  BEGIN
    T_ACC_DEPRN_PREV_FY := 0;
    IF UPPER(P_MRCSOBTYPE) = 'R' THEN
      BEGIN
        SELECT
          PERIOD_COUNTER,
          DEPRN_RESERVE,
          ADJUSTED_COST
        INTO L_LAST_DEPRN_PERIOD_PREV_FY,L_ACC_DEPRN_PREV_FY,L_ADJUSTED_COST_PREV_FY
        FROM
          FA_DEPRN_SUMMARY_MRC_V
        WHERE BOOK_TYPE_CODE = T_BOOK_TYPE_CODE
          AND ASSET_ID = T_ASSET_ID
          AND PERIOD_COUNTER = (
          SELECT
            MAX(FDS2.PERIOD_COUNTER)
          FROM
            FA_DEPRN_SUMMARY_MRC_V FDS2
          WHERE FDS2.BOOK_TYPE_CODE = T_BOOK_TYPE_CODE
            AND FDS2.ASSET_ID = T_ASSET_ID
            AND FDS2.PERIOD_COUNTER <= T_PERIOD_START - 1 );
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          L_ACC_DEPRN_PREV_FY := 0;
        WHEN OTHERS THEN
          L_ACC_DEPRN_PREV_FY := -1;
      END;
      IF L_ACC_DEPRN_PREV_FY = 0 THEN
        T_ACC_DEPRN_PREV_FY := 0;
        RETURN (NVL(T_ACC_DEPRN_PREV_FY
                  ,0));
      END IF;
      BEGIN
        SELECT
          COUNT(RET.RETIREMENT_ID)
        INTO L_HAS_RETIREMENT
        FROM
          FA_RETIREMENTS_MRC_V RET,
          FA_DEPRN_PERIODS_MRC_V FDP
        WHERE RET.BOOK_TYPE_CODE = T_BOOK_TYPE_CODE
          AND RET.STATUS <> 'DELETED'
          AND RET.BOOK_TYPE_CODE = FDP.BOOK_TYPE_CODE
          AND RET.ASSET_ID = T_ASSET_ID
          AND RET.DATE_RETIRED between FDP.CALENDAR_PERIOD_OPEN_DATE
          AND FDP.CALENDAR_PERIOD_CLOSE_DATE
          AND FDP.FISCAL_YEAR = P_CURR_FY;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_ORA_ERR;
      END;
      IF L_HAS_RETIREMENT = 0 THEN
        T_ACC_DEPRN_PREV_FY := L_ACC_DEPRN_PREV_FY;
        RETURN (NVL(T_ACC_DEPRN_PREV_FY
                  ,0));
      END IF;
      BEGIN
        SELECT
          BKS.COST
        INTO L_COST_BEGIN_YEAR
        FROM
          FA_BOOKS_MRC_V BKS,
          FA_DEPRN_PERIODS_MRC_V DPP
        WHERE DPP.PERIOD_COUNTER = T_PERIOD_START
          AND BKS.BOOK_TYPE_CODE = T_BOOK_TYPE_CODE
          AND DPP.BOOK_TYPE_CODE = BKS.BOOK_TYPE_CODE
          AND BKS.ASSET_ID = T_ASSET_ID
          AND DPP.PERIOD_OPEN_DATE between BKS.DATE_EFFECTIVE
          AND NVL(BKS.DATE_INEFFECTIVE
           ,DPP.PERIOD_OPEN_DATE);
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          L_COST_BEGIN_YEAR := 0;
        WHEN OTHERS THEN
          /*SRW.MESSAGE(1
                     ,'Error Calculation Cost at begining of the year')*/NULL;
      END;
      BEGIN
        SELECT
          COUNT(FDD.DEPRN_ADJUSTMENT_AMOUNT),
          SUM(FDD.DEPRN_ADJUSTMENT_AMOUNT)
        INTO L_HAS_RESERVE_ADJUSTMENT,L_TOTAL_DEPRN_ADJUSTMENT
        FROM
          FA_DEPRN_DETAIL_MRC_V FDD
        WHERE FDD.BOOK_TYPE_CODE = T_BOOK_TYPE_CODE
          AND FDD.ASSET_ID = T_ASSET_ID
          AND FDD.PERIOD_COUNTER between T_PERIOD_START
          AND T_PERIOD_END
          AND FDD.DEPRN_ADJUSTMENT_AMOUNT <> 0;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_ORA_ERR;
      END;
      IF L_HAS_RESERVE_ADJUSTMENT = 0 THEN
        BEGIN
          SELECT
            DEPRN_RESERVE / L_COST_BEGIN_YEAR * L_COST_RETIRED
          INTO T_ACC_DEPRN_PREV_FY
          FROM
            FA_DEPRN_SUMMARY_MRC_V
          WHERE BOOK_TYPE_CODE = T_BOOK_TYPE_CODE
            AND ASSET_ID = T_ASSET_ID
            AND PERIOD_COUNTER = L_LAST_DEPRN_PERIOD_PREV_FY;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            T_ACC_DEPRN_PREV_FY := 0;
          WHEN OTHERS THEN
            T_ACC_DEPRN_PREV_FY := -1;
        END;
      ELSE
        L_PREV_ADJUSTED_COST := L_ADJUSTED_COST_PREV_FY;
        L_ADJ_COST_LESS_PART_RET := L_ADJUSTED_COST_PREV_FY;
        FOR c_ret_rec IN C_RET_DEPRN_SUMMARY_MRC LOOP
          IF L_ADJ_COST_LESS_PART_RET = 0 THEN
            L_COST_RETIRED := 0;
            EXIT;
          END IF;
          IF C_RET_REC.ADJUSTED_COST <> L_PREV_ADJUSTED_COST THEN
            BEGIN
              SELECT
                RET.COST_RETIRED
              INTO L_COST_RETIRED
              FROM
                FA_RETIREMENTS_MRC_V RET,
                FA_DEPRN_PERIODS_MRC_V FDP
              WHERE RET.BOOK_TYPE_CODE = T_BOOK_TYPE_CODE
                AND RET.STATUS <> 'DELETED'
                AND RET.BOOK_TYPE_CODE = FDP.BOOK_TYPE_CODE
                AND RET.ASSET_ID = T_ASSET_ID
                AND RET.DATE_RETIRED between FDP.CALENDAR_PERIOD_OPEN_DATE
                AND FDP.CALENDAR_PERIOD_CLOSE_DATE
                AND FDP.PERIOD_COUNTER = C_RET_REC.PERIOD_COUNTER;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                L_COST_RETIRED := 0;
              WHEN OTHERS THEN
                L_COST_RETIRED := 0;
            END;
            IF L_COST_RETIRED <> 0 THEN
              IF L_COST_RETIRED <= L_ADJ_COST_LESS_PART_RET THEN
                L_ADJ_COST_LESS_PART_RET := L_ADJ_COST_LESS_PART_RET - L_COST_RETIRED;
              ELSE
                L_COST_RETIRED := L_ADJ_COST_LESS_PART_RET;
                L_ADJ_COST_LESS_PART_RET := 0;
              END IF;
            END IF;
            L_PREV_ADJUSTED_COST := C_RET_REC.ADJUSTED_COST;
          END IF;
        END LOOP;
        IF T_RETIREMENT_ID IS NULL THEN
          T_ACC_DEPRN_PREV_FY := (L_ACC_DEPRN_PREV_FY / L_ADJUSTED_COST_PREV_FY) * L_ADJ_COST_LESS_PART_RET;
        ELSE
          T_ACC_DEPRN_PREV_FY := (L_ACC_DEPRN_PREV_FY / L_ADJUSTED_COST_PREV_FY) * L_COST_RETIRED;
        END IF;
      END IF;
    ELSE
      BEGIN
        SELECT
          PERIOD_COUNTER,
          DEPRN_RESERVE,
          ADJUSTED_COST
        INTO L_LAST_DEPRN_PERIOD_PREV_FY,L_ACC_DEPRN_PREV_FY,L_ADJUSTED_COST_PREV_FY
        FROM
          FA_DEPRN_SUMMARY
        WHERE BOOK_TYPE_CODE = T_BOOK_TYPE_CODE
          AND ASSET_ID = T_ASSET_ID
          AND PERIOD_COUNTER = (
          SELECT
            MAX(FDS2.PERIOD_COUNTER)
          FROM
            FA_DEPRN_SUMMARY FDS2
          WHERE FDS2.BOOK_TYPE_CODE = T_BOOK_TYPE_CODE
            AND FDS2.ASSET_ID = T_ASSET_ID
            AND FDS2.PERIOD_COUNTER <= T_PERIOD_START - 1 );
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          L_ACC_DEPRN_PREV_FY := 0;
        WHEN OTHERS THEN
          L_ACC_DEPRN_PREV_FY := -1;
      END;
      IF L_ACC_DEPRN_PREV_FY = 0 THEN
        T_ACC_DEPRN_PREV_FY := 0;
        RETURN (NVL(T_ACC_DEPRN_PREV_FY
                  ,0));
      END IF;
      BEGIN
        SELECT
          COUNT(RET.RETIREMENT_ID)
        INTO L_HAS_RETIREMENT
        FROM
          FA_RETIREMENTS RET,
          FA_DEPRN_PERIODS FDP
        WHERE RET.BOOK_TYPE_CODE = T_BOOK_TYPE_CODE
          AND RET.STATUS <> 'DELETED'
          AND RET.BOOK_TYPE_CODE = FDP.BOOK_TYPE_CODE
          AND RET.ASSET_ID = T_ASSET_ID
          AND RET.DATE_RETIRED between FDP.CALENDAR_PERIOD_OPEN_DATE
          AND FDP.CALENDAR_PERIOD_CLOSE_DATE
          AND FDP.FISCAL_YEAR = P_CURR_FY;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_ORA_ERR;
      END;
      IF L_HAS_RETIREMENT = 0 THEN
        T_ACC_DEPRN_PREV_FY := L_ACC_DEPRN_PREV_FY;
        RETURN (NVL(T_ACC_DEPRN_PREV_FY
                  ,0));
      END IF;
      BEGIN
        SELECT
          BKS.COST
        INTO L_COST_BEGIN_YEAR
        FROM
          FA_BOOKS BKS,
          FA_DEPRN_PERIODS DPP
        WHERE DPP.PERIOD_COUNTER = T_PERIOD_START
          AND BKS.BOOK_TYPE_CODE = T_BOOK_TYPE_CODE
          AND DPP.BOOK_TYPE_CODE = BKS.BOOK_TYPE_CODE
          AND BKS.ASSET_ID = T_ASSET_ID
          AND DPP.PERIOD_OPEN_DATE between BKS.DATE_EFFECTIVE
          AND NVL(BKS.DATE_INEFFECTIVE
           ,DPP.PERIOD_OPEN_DATE);
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          L_COST_BEGIN_YEAR := 0;
        WHEN OTHERS THEN
          /*SRW.MESSAGE(1
                     ,'Error Calculation Cost at begining of the year')*/NULL;
      END;
      BEGIN
        SELECT
          COUNT(FDD.DEPRN_ADJUSTMENT_AMOUNT),
          SUM(FDD.DEPRN_ADJUSTMENT_AMOUNT)
        INTO L_HAS_RESERVE_ADJUSTMENT,L_TOTAL_DEPRN_ADJUSTMENT
        FROM
          FA_DEPRN_DETAIL FDD
        WHERE FDD.BOOK_TYPE_CODE = T_BOOK_TYPE_CODE
          AND FDD.ASSET_ID = T_ASSET_ID
          AND FDD.PERIOD_COUNTER between T_PERIOD_START
          AND T_PERIOD_END
          AND FDD.DEPRN_ADJUSTMENT_AMOUNT <> 0;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE_ORA_ERR;
      END;
      IF L_HAS_RESERVE_ADJUSTMENT = 0 THEN
        BEGIN
          SELECT
            DEPRN_RESERVE / L_COST_BEGIN_YEAR * L_COST_RETIRED
          INTO T_ACC_DEPRN_PREV_FY
          FROM
            FA_DEPRN_SUMMARY
          WHERE BOOK_TYPE_CODE = T_BOOK_TYPE_CODE
            AND ASSET_ID = T_ASSET_ID
            AND PERIOD_COUNTER = L_LAST_DEPRN_PERIOD_PREV_FY;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            T_ACC_DEPRN_PREV_FY := 0;
          WHEN OTHERS THEN
            T_ACC_DEPRN_PREV_FY := -1;
        END;
      ELSE
        L_PREV_ADJUSTED_COST := L_ADJUSTED_COST_PREV_FY;
        L_ADJ_COST_LESS_PART_RET := L_ADJUSTED_COST_PREV_FY;
        FOR c_ret_rec IN C_RET_DEPRN_SUMMARY LOOP
          IF L_ADJ_COST_LESS_PART_RET = 0 THEN
            L_COST_RETIRED := 0;
            EXIT;
          END IF;
          IF C_RET_REC.ADJUSTED_COST <> L_PREV_ADJUSTED_COST THEN
            BEGIN
              SELECT
                RET.COST_RETIRED
              INTO L_COST_RETIRED
              FROM
                FA_RETIREMENTS RET,
                FA_DEPRN_PERIODS FDP
              WHERE RET.BOOK_TYPE_CODE = T_BOOK_TYPE_CODE
                AND RET.STATUS <> 'DELETED'
                AND RET.BOOK_TYPE_CODE = FDP.BOOK_TYPE_CODE
                AND RET.ASSET_ID = T_ASSET_ID
                AND RET.DATE_RETIRED between FDP.CALENDAR_PERIOD_OPEN_DATE
                AND FDP.CALENDAR_PERIOD_CLOSE_DATE
                AND FDP.PERIOD_COUNTER = C_RET_REC.PERIOD_COUNTER;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                L_COST_RETIRED := 0;
              WHEN OTHERS THEN
                L_COST_RETIRED := 0;
            END;
            IF L_COST_RETIRED <> 0 THEN
              IF L_COST_RETIRED <= L_ADJ_COST_LESS_PART_RET THEN
                L_ADJ_COST_LESS_PART_RET := L_ADJ_COST_LESS_PART_RET - L_COST_RETIRED;
              ELSE
                L_COST_RETIRED := L_ADJ_COST_LESS_PART_RET;
                L_ADJ_COST_LESS_PART_RET := 0;
              END IF;
            END IF;
            L_PREV_ADJUSTED_COST := C_RET_REC.ADJUSTED_COST;
          END IF;
        END LOOP;
        IF T_RETIREMENT_ID IS NULL THEN
          T_ACC_DEPRN_PREV_FY := (L_ACC_DEPRN_PREV_FY / L_ADJUSTED_COST_PREV_FY) * L_ADJ_COST_LESS_PART_RET;
        ELSE
          T_ACC_DEPRN_PREV_FY := (L_ACC_DEPRN_PREV_FY / L_ADJUSTED_COST_PREV_FY) * L_COST_RETIRED;
        END IF;
      END IF;
    END IF;
    RETURN (NVL(T_ACC_DEPRN_PREV_FY
              ,0));
  END C_ACCUM_DEPRN_PREV_YRFORMULA;

  FUNCTION C_ADJ_NBVFORMULA(ORIGINAL_COST IN NUMBER
                           ,C_ACCUM_DEPRN_CURR_YR IN NUMBER
                           ,C_ACCUM_DEPRN_PREV_YR IN NUMBER
                           ,C_CORR_FACTOR IN NUMBER) RETURN NUMBER IS
    T_ADJ_NBV NUMBER;
  BEGIN
    T_ADJ_NBV := (ORIGINAL_COST - (C_ACCUM_DEPRN_CURR_YR + C_ACCUM_DEPRN_PREV_YR)) * C_CORR_FACTOR;
    RETURN (T_ADJ_NBV);
  END C_ADJ_NBVFORMULA;

  FUNCTION C_NBVFORMULA(ASSET_ID IN NUMBER
                       ,TRANSACTION_HEADER_ID IN NUMBER
                       ,PERIOD_COUNTER IN NUMBER
                       ,RETIREMENT_ID IN NUMBER
                       ,ORIGINAL_COST IN NUMBER) RETURN NUMBER IS
    T_ASSET_ID NUMBER := ASSET_ID;
    T_BOOK_TYPE_CODE VARCHAR(30) := P_BOOK_TYPE_CODE;
    T_TRANSACTION_HEADER_ID NUMBER := TRANSACTION_HEADER_ID;
    T_PERIOD_START NUMBER := C_MIN_PERIOD_COUNTER;
    T_PERIOD_END NUMBER := C_MAX_PERIOD_COUNTER;
    T_PERIOD_COUNTER NUMBER := PERIOD_COUNTER;
    T_RETIREMENT_ID NUMBER := RETIREMENT_ID;
    T_COST_RETIRED NUMBER := ORIGINAL_COST;
    T_ACC_DEPRN_LIFE_TD NUMBER;
  BEGIN
    T_ACC_DEPRN_LIFE_TD := 0;
    IF UPPER(P_MRCSOBTYPE) = 'R' THEN
      IF T_RETIREMENT_ID IS NOT NULL THEN
        BEGIN
          SELECT
            SUM(FAD.ADJUSTMENT_AMOUNT)
          INTO T_ACC_DEPRN_LIFE_TD
          FROM
            FA_ADJUSTMENTS_MRC_V FAD
          WHERE FAD.BOOK_TYPE_CODE = T_BOOK_TYPE_CODE
            AND FAD.ASSET_ID = T_ASSET_ID
            AND FAD.SOURCE_TYPE_CODE = 'RETIREMENT'
            AND FAD.ADJUSTMENT_TYPE = 'RESERVE'
            AND FAD.TRANSACTION_HEADER_ID = T_TRANSACTION_HEADER_ID;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            T_ACC_DEPRN_LIFE_TD := 0;
          WHEN OTHERS THEN
            T_ACC_DEPRN_LIFE_TD := -1;
        END;
      ELSE
        BEGIN
          SELECT
            DEPRN_RESERVE
          INTO T_ACC_DEPRN_LIFE_TD
          FROM
            FA_DEPRN_SUMMARY_MRC_V
          WHERE BOOK_TYPE_CODE = T_BOOK_TYPE_CODE
            AND ASSET_ID = T_ASSET_ID
            AND PERIOD_COUNTER = T_PERIOD_COUNTER;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            T_ACC_DEPRN_LIFE_TD := 0;
          WHEN OTHERS THEN
            T_ACC_DEPRN_LIFE_TD := -1;
        END;
      END IF;
    ELSE
      IF T_RETIREMENT_ID IS NOT NULL THEN
        BEGIN
          SELECT
            SUM(FAD.ADJUSTMENT_AMOUNT)
          INTO T_ACC_DEPRN_LIFE_TD
          FROM
            FA_ADJUSTMENTS FAD
          WHERE FAD.BOOK_TYPE_CODE = T_BOOK_TYPE_CODE
            AND FAD.ASSET_ID = T_ASSET_ID
            AND FAD.SOURCE_TYPE_CODE = 'RETIREMENT'
            AND FAD.ADJUSTMENT_TYPE = 'RESERVE'
            AND FAD.TRANSACTION_HEADER_ID = T_TRANSACTION_HEADER_ID;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            T_ACC_DEPRN_LIFE_TD := 0;
          WHEN OTHERS THEN
            T_ACC_DEPRN_LIFE_TD := -1;
        END;
      ELSE
        BEGIN
          SELECT
            DEPRN_RESERVE
          INTO T_ACC_DEPRN_LIFE_TD
          FROM
            FA_DEPRN_SUMMARY
          WHERE BOOK_TYPE_CODE = T_BOOK_TYPE_CODE
            AND ASSET_ID = T_ASSET_ID
            AND PERIOD_COUNTER = T_PERIOD_COUNTER;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            T_ACC_DEPRN_LIFE_TD := 0;
          WHEN OTHERS THEN
            T_ACC_DEPRN_LIFE_TD := -1;
        END;
      END IF;
    END IF;
    RETURN (NVL(T_ACC_DEPRN_LIFE_TD
              ,0));
  END C_NBVFORMULA;

  FUNCTION C_ACCUM_DEPRN_CURR_YRFORMULA(C_NBV IN NUMBER
                                       ,C_ACCUM_DEPRN_PREV_YR IN NUMBER) RETURN NUMBER IS
    V_YTD_DEPRN NUMBER;
  BEGIN
    V_YTD_DEPRN := C_NBV - C_ACCUM_DEPRN_PREV_YR;
    RETURN (V_YTD_DEPRN);
  END C_ACCUM_DEPRN_CURR_YRFORMULA;

  FUNCTION C_INDEX_VALUE_HALF_PERIODFORMU(ACQDATE IN DATE
                                         ,DATE_RETIRED IN DATE
                                         ,C_PRICE_INDEX IN NUMBER) RETURN NUMBER IS
    MON_NUM NUMBER(2);
    MON_ACQUIRED NUMBER(2);
    X NUMBER;
    HALF_PERIOD_DATE DATE;
    YEAR NUMBER;
    ERRMSG VARCHAR2(1000);
    INDEX_NAME VARCHAR2(40);
  BEGIN
    X := NULL;
    IF ACQDATE BETWEEN C_FISCAL_START_DATE AND C_FISCAL_END_DATE THEN
      MON_ACQUIRED := TO_NUMBER(TO_CHAR(ACQDATE
                                       ,'MM'));
    ELSE
      MON_ACQUIRED := 0;
    END IF;
    MON_NUM := JL_ZZ_FA_FUNCTIONS_PKG.MIDDLE_MONTH(MON_ACQUIRED
                                                  ,TO_NUMBER(TO_CHAR(DATE_RETIRED
                                                                   ,'MM'))
                                                  ,P_INCLUDE_DPIS
                                                  ,P_INCLUDE_RET);
    IF MON_NUM = '0' THEN
      YEAR := TO_CHAR(C_FISCAL_START_DATE - 365
                     ,'YYYY');
      MON_NUM := '12';
    ELSE
      YEAR := TO_CHAR(C_FISCAL_START_DATE
                     ,'YYYY');
    END IF;
    HALF_PERIOD_DATE := LAST_DAY(TO_DATE('01-' || LPAD(TO_CHAR(MON_NUM)
                                             ,2
                                             ,'0') || '-' || TO_CHAR(YEAR)
                                        ,'DD-MM-YYYY'));
    BEGIN
      SELECT
        PRICE_INDEX_VALUE
      INTO X
      FROM
        FA_PRICE_INDEX_VALUES
      WHERE PRICE_INDEX_ID = C_PRICE_INDEX
        AND HALF_PERIOD_DATE BETWEEN FROM_DATE
        AND TO_DATE;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        SELECT
          PRICE_INDEX_NAME
        INTO INDEX_NAME
        FROM
          FA_PRICE_INDEXES
        WHERE PRICE_INDEX_ID = C_PRICE_INDEX;
        FND_MESSAGE.SET_NAME('JL'
                            ,'JL_ZZ_FA_INDX_VAL_NOT_FOUND');
        FND_MESSAGE.SET_TOKEN('PRICE_INDEX'
                             ,INDEX_NAME
                             ,FALSE);
        FND_MESSAGE.SET_TOKEN('MISSING_DATE'
                             ,TO_CHAR(HALF_PERIOD_DATE)
                             ,FALSE);
        ERRMSG := FND_MESSAGE.GET;
        /*SRW.MESSAGE(JL_ZZ_FA_UTILITIES_PKG.GET_APP_ERRNUM('JL'
                                                         ,'JL_ZZ_FA_INDX_VAL_NOT_FOUND')
                   ,ERRMSG)*/NULL;
        /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
        RETURN NULL;
      WHEN OTHERS THEN
        RAISE_ORA_ERR;
        RETURN NULL;
    END;
    RETURN (NVL(X
              ,0));
  END C_INDEX_VALUE_HALF_PERIODFORMU;

  PROCEDURE CUSTOM_INIT IS
    FIS_YR NUMBER(4);
    CURR_PER_COUNTER NUMBER(15);
    MAX_PER_COUNTER NUMBER(15);
    MIN_PER_COUNTER NUMBER(15);
    LAST_PER_COUNTER NUMBER(15);
    V_RATIO_PRECISION VARCHAR2(10);
    FROM_DATE DATE;
    TO_DATE DATE;
  BEGIN
    FND_PROFILE.GET('JLZZ_INF_RATIO_PRECISION'
                   ,V_RATIO_PRECISION);
    IF V_RATIO_PRECISION IS NULL THEN
      C_RATIO_PRECISION := 38;
    ELSE
      C_RATIO_PRECISION := TO_NUMBER(V_RATIO_PRECISION);
    END IF;
    IF UPPER(P_MRCSOBTYPE) = 'R' THEN
      BEGIN
        SELECT
          MIN(PERIOD_COUNTER),
          MAX(PERIOD_COUNTER)
        INTO MIN_PER_COUNTER,MAX_PER_COUNTER
        FROM
          FA_DEPRN_PERIODS_MRC_V
        WHERE BOOK_TYPE_CODE = P_BOOK_TYPE_CODE
          AND FISCAL_YEAR = P_CURR_FY;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RAISE_ERR('JL_AR_FA_CUR_FY_DEP_PER_NOTDEF'
                   ,'N');
        WHEN OTHERS THEN
          RAISE_ORA_ERR;
      END;
      C_MIN_PERIOD_COUNTER := MIN_PER_COUNTER;
      C_MAX_PERIOD_COUNTER := MAX_PER_COUNTER;
      BEGIN
        SELECT
          MAX(PERIOD_COUNTER)
        INTO LAST_PER_COUNTER
        FROM
          FA_DEPRN_PERIODS_MRC_V
        WHERE BOOK_TYPE_CODE = P_BOOK_TYPE_CODE
          AND FISCAL_YEAR = P_CURR_FY - 1;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RAISE_ERR('JL_AR_FA_PRV_FY_DEP_PER_NOTDEF'
                   ,'N');
        WHEN OTHERS THEN
          RAISE_ORA_ERR;
      END;
      C_LAST_PERIOD_COUNTER := LAST_PER_COUNTER;
      BEGIN
        SELECT
          A.START_DATE,
          A.END_DATE
        INTO FROM_DATE,TO_DATE
        FROM
          FA_BOOK_CONTROLS_MRC_V B,
          FA_FISCAL_YEAR A
        WHERE A.FISCAL_YEAR = P_CURR_FY
          AND B.BOOK_TYPE_CODE = P_BOOK_TYPE_CODE
          AND B.FISCAL_YEAR_NAME = A.FISCAL_YEAR_NAME;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RAISE_ERR('JL_AR_FA_FY_DETAIL_NOT_DEFINED'
                   ,'N');
        WHEN OTHERS THEN
          RAISE_ORA_ERR;
      END;
    ELSE
      BEGIN
        SELECT
          MIN(PERIOD_COUNTER),
          MAX(PERIOD_COUNTER)
        INTO MIN_PER_COUNTER,MAX_PER_COUNTER
        FROM
          FA_DEPRN_PERIODS
        WHERE BOOK_TYPE_CODE = P_BOOK_TYPE_CODE
          AND FISCAL_YEAR = P_CURR_FY;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RAISE_ERR('JL_AR_FA_CUR_FY_DEP_PER_NOTDEF'
                   ,'N');
        WHEN OTHERS THEN
          RAISE_ORA_ERR;
      END;
      C_MIN_PERIOD_COUNTER := MIN_PER_COUNTER;
      C_MAX_PERIOD_COUNTER := MAX_PER_COUNTER;
      BEGIN
        SELECT
          MAX(PERIOD_COUNTER)
        INTO LAST_PER_COUNTER
        FROM
          FA_DEPRN_PERIODS
        WHERE BOOK_TYPE_CODE = P_BOOK_TYPE_CODE
          AND FISCAL_YEAR = P_CURR_FY - 1;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RAISE_ERR('JL_AR_FA_PRV_FY_DEP_PER_NOTDEF'
                   ,'N');
        WHEN OTHERS THEN
          RAISE_ORA_ERR;
      END;
      C_LAST_PERIOD_COUNTER := LAST_PER_COUNTER;
      BEGIN
        SELECT
          A.START_DATE,
          A.END_DATE
        INTO FROM_DATE,TO_DATE
        FROM
          FA_BOOK_CONTROLS B,
          FA_FISCAL_YEAR A
        WHERE A.FISCAL_YEAR = P_CURR_FY
          AND B.BOOK_TYPE_CODE = P_BOOK_TYPE_CODE
          AND B.FISCAL_YEAR_NAME = A.FISCAL_YEAR_NAME;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RAISE_ERR('JL_AR_FA_FY_DETAIL_NOT_DEFINED'
                   ,'N');
        WHEN OTHERS THEN
          RAISE_ORA_ERR;
      END;
    END IF;
    C_FISCAL_START_DATE := FROM_DATE;
    C_FISCAL_END_DATE := TO_DATE;
  END CUSTOM_INIT;

  FUNCTION C_GAIN_LOSSFORMULA(C_ADJ_NBV IN NUMBER
                             ,C_PROC_SALE IN NUMBER) RETURN NUMBER IS
    L_AMOUNT NUMBER;
  BEGIN
    L_AMOUNT := C_ADJ_NBV - C_PROC_SALE;
    RETURN (L_AMOUNT);
  END C_GAIN_LOSSFORMULA;

  FUNCTION C_RET_DATEFORMULA RETURN DATE IS
  BEGIN
    DECLARE
      MON_NUM NUMBER(2);
      L_RET_DATE DATE;
    BEGIN
      RETURN (SYSDATE);
    END;
    RETURN NULL;
  END C_RET_DATEFORMULA;

  FUNCTION C_PROC_SALEFORMULA(PROCEEDS_OF_SALE IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (PROCEEDS_OF_SALE);
  END C_PROC_SALEFORMULA;

  PROCEDURE RAISE_ORA_ERR IS
    ERRMSG VARCHAR2(1000);
    ERRNUM NUMBER;
  BEGIN
    ERRMSG := SQLERRM;
    ERRNUM := SQLCODE;
    /*SRW.MESSAGE(ERRNUM
               ,ERRMSG)*/NULL;
    /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
  END RAISE_ORA_ERR;

  PROCEDURE RAISE_ERR(MSGNAME IN VARCHAR2
                     ,ABORT_FLAG IN VARCHAR2) IS
    ERRMSG VARCHAR2(1000);
  BEGIN
    FND_MESSAGE.SET_NAME('JL'
                        ,MSGNAME);
    ERRMSG := FND_MESSAGE.GET;
    /*SRW.MESSAGE(JL_ZZ_FA_UTILITIES_PKG.GET_APP_ERRNUM('JL'
                                                     ,MSGNAME)
               ,ERRMSG)*/NULL;
    IF ABORT_FLAG = 'Y' THEN
      /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
    END IF;
  END RAISE_ERR;

  FUNCTION CF_1FORMULA RETURN CHAR IS
    T_MEANING VARCHAR2(30);
  BEGIN
    SELECT
      MEANING
    INTO T_MEANING
    FROM
      FND_LOOKUPS
    WHERE LOOKUP_TYPE = 'YES_NO'
      AND LOOKUP_CODE = P_INCLUDE_DPIS;
    RETURN (T_MEANING);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (P_INCLUDE_DPIS);
  END CF_1FORMULA;

  FUNCTION CF_INCLUDE_RETFORMULA RETURN CHAR IS
    T_MEANING VARCHAR2(30);
  BEGIN
    SELECT
      MEANING
    INTO T_MEANING
    FROM
      FND_LOOKUPS
    WHERE LOOKUP_TYPE = 'YES_NO'
      AND LOOKUP_CODE = P_INCLUDE_RET;
    RETURN (T_MEANING);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (P_INCLUDE_RET);
  END CF_INCLUDE_RETFORMULA;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    IF P_CA_SET_OF_BOOKS_ID <> -1999 THEN
      BEGIN
        SELECT
          MRC_SOB_TYPE_CODE,
          CURRENCY_CODE
        INTO P_MRCSOBTYPE,LP_CURRENCY_CODE
        FROM
          GL_SETS_OF_BOOKS
        WHERE SET_OF_BOOKS_ID = P_CA_SET_OF_BOOKS_ID;
      EXCEPTION
        WHEN OTHERS THEN
          P_MRCSOBTYPE := 'P';
      END;
    ELSE
      P_MRCSOBTYPE := 'P';
    END IF;
    IF UPPER(P_MRCSOBTYPE) = 'R' THEN
      LP_FA_BOOK_CONTROLS := 'FA_BOOK_CONTROLS_MRC_V';
      LP_FA_BOOKS := 'FA_BOOKS_MRC_V';
      LP_FA_ADJUSTMENTS := 'FA_ADJUSTMENTS_MRC_V';
      LP_FA_DEPRN_PERIODS := 'FA_DEPRN_PERIODS_MRC_V';
      LP_FA_DEPRN_SUMMARY := 'FA_DEPRN_SUMMARY_MRC_V';
      LP_FA_DEPRN_DETAIL := 'FA_DEPRN_DETAIL_MRC_V';
    ELSE
      LP_FA_BOOK_CONTROLS := 'FA_BOOK_CONTROLS';
      LP_FA_BOOKS := 'FA_BOOKS';
      LP_FA_ADJUSTMENTS := 'FA_ADJUSTMENTS';
      LP_FA_DEPRN_PERIODS := 'FA_DEPRN_PERIODS';
      LP_FA_DEPRN_SUMMARY := 'FA_DEPRN_SUMMARY';
      LP_FA_DEPRN_DETAIL := 'FA_DEPRN_DETAIL';
    END IF;
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION C_BASE_CURRENCY_CODE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_BASE_CURRENCY_CODE;
  END C_BASE_CURRENCY_CODE_P;

  FUNCTION C_BASE_PRECISION_P RETURN NUMBER IS
  BEGIN
    RETURN C_BASE_PRECISION;
  END C_BASE_PRECISION_P;

  FUNCTION C_BASE_MIN_ACCT_UNIT_P RETURN NUMBER IS
  BEGIN
    RETURN C_BASE_MIN_ACCT_UNIT;
  END C_BASE_MIN_ACCT_UNIT_P;

  FUNCTION C_BASE_DESCRIPTION_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_BASE_DESCRIPTION;
  END C_BASE_DESCRIPTION_P;

  FUNCTION C_ORGANIZATION_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_ORGANIZATION_NAME;
  END C_ORGANIZATION_NAME_P;

  FUNCTION C_CURR_FISCAL_YR_P RETURN NUMBER IS
  BEGIN
    RETURN C_CURR_FISCAL_YR;
  END C_CURR_FISCAL_YR_P;

  FUNCTION C_CURR_PERIOD_COUNTER_P RETURN NUMBER IS
  BEGIN
    RETURN C_CURR_PERIOD_COUNTER;
  END C_CURR_PERIOD_COUNTER_P;

  FUNCTION C_LAST_PERIOD_COUNTER_P RETURN NUMBER IS
  BEGIN
    RETURN C_LAST_PERIOD_COUNTER;
  END C_LAST_PERIOD_COUNTER_P;

  FUNCTION C_RATIO_PRECISION_P RETURN NUMBER IS
  BEGIN
    RETURN C_RATIO_PRECISION;
  END C_RATIO_PRECISION_P;

  FUNCTION C_MIN_PERIOD_COUNTER_P RETURN NUMBER IS
  BEGIN
    RETURN C_MIN_PERIOD_COUNTER;
  END C_MIN_PERIOD_COUNTER_P;

  FUNCTION C_MAX_PERIOD_COUNTER_P RETURN NUMBER IS
  BEGIN
    RETURN C_MAX_PERIOD_COUNTER;
  END C_MAX_PERIOD_COUNTER_P;

  FUNCTION C_FISCAL_START_DATE_P RETURN DATE IS
  BEGIN
    RETURN C_FISCAL_START_DATE;
  END C_FISCAL_START_DATE_P;

  FUNCTION C_FISCAL_END_DATE_P RETURN DATE IS
  BEGIN
    RETURN C_FISCAL_END_DATE;
  END C_FISCAL_END_DATE_P;

  PROCEDURE SET_NAME(APPLICATION IN VARCHAR2
                    ,NAME IN VARCHAR2) IS
  BEGIN
  /*  STPROC.INIT('begin FND_MESSAGE.SET_NAME(:APPLICATION, :NAME); end;');
    STPROC.BIND_I(APPLICATION);
    STPROC.BIND_I(NAME);
    STPROC.EXECUTE;*/

    FND_MESSAGE.SET_NAME(APPLICATION,NAME);
  END SET_NAME;

  PROCEDURE SET_TOKEN(TOKEN IN VARCHAR2
                     ,VALUE IN VARCHAR2
                     ,TRANSLATE IN BOOLEAN) IS
 TRANSLATE1 BOOLEAN;
  BEGIN
    /*STPROC.INIT('declare TRANSLATE BOOLEAN; begin TRANSLATE := sys.diutil.int_to_bool(:TRANSLATE); FND_MESSAGE.SET_TOKEN(:TOKEN, :VALUE, TRANSLATE); end;');
    STPROC.BIND_I(TRANSLATE);
    STPROC.BIND_I(TOKEN);
    STPROC.BIND_I(VALUE);
    STPROC.EXECUTE;*/

   -- TRANSLATE1 := sys.diutil.int_to_bool(TRANSLATE);
    FND_MESSAGE.SET_TOKEN(TOKEN, VALUE, TRANSLATE1);
  END SET_TOKEN;

  PROCEDURE RETRIEVE(MSGOUT OUT NOCOPY VARCHAR2) IS
  BEGIN
  /*  STPROC.INIT('begin FND_MESSAGE.RETRIEVE(:MSGOUT); end;');
    STPROC.BIND_O(MSGOUT);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,MSGOUT);*/null;
  END RETRIEVE;

  PROCEDURE CLEAR IS
  BEGIN
   /* STPROC.INIT('begin FND_MESSAGE.CLEAR; end;');
    STPROC.EXECUTE;*/null;
  END CLEAR;

  FUNCTION GET_STRING(APPIN IN VARCHAR2
                     ,NAMEIN IN VARCHAR2) RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
  /*  STPROC.INIT('begin :X0 := FND_MESSAGE.GET_STRING(:APPIN, :NAMEIN); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(APPIN);
    STPROC.BIND_I(NAMEIN);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/
    RETURN X0;
  END GET_STRING;

  FUNCTION GET_NUMBER(APPIN IN VARCHAR2
                     ,NAMEIN IN VARCHAR2) RETURN NUMBER IS
    X0 NUMBER;
  BEGIN
    /*STPROC.INIT('begin :X0 := FND_MESSAGE.GET_NUMBER(:APPIN, :NAMEIN); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(APPIN);
    STPROC.BIND_I(NAMEIN);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/null;
    RETURN X0;
  END GET_NUMBER;

  FUNCTION GET RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
  /*  STPROC.INIT('begin :X0 := FND_MESSAGE.GET; end;');
    STPROC.BIND_O(X0);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/

		   X0 := FND_MESSAGE.GET;
    RETURN X0;
  END GET;

  FUNCTION GET_ENCODED RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
  /*  STPROC.INIT('begin :X0 := FND_MESSAGE.GET_ENCODED; end;');
    STPROC.BIND_O(X0);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/
    RETURN X0;
  END GET_ENCODED;

  PROCEDURE PARSE_ENCODED(ENCODED_MESSAGE IN VARCHAR2
                         ,APP_SHORT_NAME OUT NOCOPY VARCHAR2
                         ,MESSAGE_NAME OUT NOCOPY VARCHAR2) IS
  BEGIN
  /*  STPROC.INIT('begin FND_MESSAGE.PARSE_ENCODED(:ENCODED_MESSAGE, :APP_SHORT_NAME, :MESSAGE_NAME); end;');
    STPROC.BIND_I(ENCODED_MESSAGE);
    STPROC.BIND_O(APP_SHORT_NAME);
    STPROC.BIND_O(MESSAGE_NAME);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(2
                   ,APP_SHORT_NAME);
    STPROC.RETRIEVE(3
                   ,MESSAGE_NAME);*/null;
  END PARSE_ENCODED;

  PROCEDURE SET_ENCODED(ENCODED_MESSAGE IN VARCHAR2) IS
  BEGIN
  /*  STPROC.INIT('begin FND_MESSAGE.SET_ENCODED(:ENCODED_MESSAGE); end;');
    STPROC.BIND_I(ENCODED_MESSAGE);
    STPROC.EXECUTE;*/null;
  END SET_ENCODED;

  PROCEDURE RAISE_ERROR IS
  BEGIN
   /* STPROC.INIT('begin FND_MESSAGE.RAISE_ERROR; end;');
    STPROC.EXECUTE;*/null;
  END RAISE_ERROR;

END JL_JLMXFGLR_XMLP_PKG;



/