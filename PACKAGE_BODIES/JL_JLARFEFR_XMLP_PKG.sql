--------------------------------------------------------
--  DDL for Package Body JL_JLARFEFR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_JLARFEFR_XMLP_PKG" AS
/* $Header: JLARFEFRB.pls 120.1 2007/12/25 16:32:35 dwkrishn noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
    L_FLAG VARCHAR2(1);
    L_SCALING_FACTOR NUMBER := 0;
    ERRMSG VARCHAR2(1000);
    ERRNUM NUMBER;
  BEGIN
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    C_SCALING_FACTOR := L_SCALING_FACTOR;
    IF UPPER(P_MRCSOBTYPE) = 'R' THEN
      FND_CLIENT_INFO.SET_CURRENCY_CONTEXT(P_CA_SET_OF_BOOKS_ID);
    END IF;
    IF UPPER(P_MRCSOBTYPE) = 'R' THEN
      SELECT
        DISTRIBUTION_SOURCE_BOOK
      INTO P_CORP_BOOK
      FROM
        FA_BOOK_CONTROLS_MRC_V
      WHERE BOOK_TYPE_CODE = P_BOOK_TYPE_CODE;
      SELECT
        PERIOD_NAME
      INTO C_PERIOD_FROM
      FROM
        FA_DEPRN_PERIODS_MRC_V
      WHERE PERIOD_COUNTER = P_PERIOD_COUNTER_FROM
        AND BOOK_TYPE_CODE = P_BOOK_TYPE_CODE;
      SELECT
        PERIOD_NAME
      INTO C_PERIOD_TO
      FROM
        FA_DEPRN_PERIODS_MRC_V
      WHERE PERIOD_COUNTER = P_PERIOD_COUNTER_TO
        AND BOOK_TYPE_CODE = P_BOOK_TYPE_CODE;
      /*SRW.MESSAGE('10000'
                 ,'Check ==' || P_PERIOD_COUNTER_TO)*/NULL;
      /*SRW.MESSAGE('10000'
                 ,'Check ==' || P_BOOK_TYPE_CODE)*/NULL;
      BEGIN
        SELECT
          'Y'
        INTO L_FLAG
        FROM
          FA_DEPRN_PERIODS_MRC_V
        WHERE BOOK_TYPE_CODE = P_BOOK_TYPE_CODE
          AND PERIOD_COUNTER = P_PERIOD_COUNTER_TO
          AND PERIOD_CLOSE_DATE is not null;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          SET_NAME('JL'
                  ,'JL_CO_FA_SAME_AS_PERIOD_CLOSED');
          SET_TOKEN('PERIOD'
                   ,C_PERIOD_TO
                   ,TRUE);
          SET_TOKEN('BOOK'
                   ,P_BOOK_TYPE_CODE
                   ,TRUE);
          ERRMSG := GET;
          /*SRW.MESSAGE(62331
                     ,ERRMSG)*/NULL;
          /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
        WHEN OTHERS THEN
          ERRMSG := SQLERRM;
          ERRNUM := SQLCODE;
          /*SRW.MESSAGE(ERRNUM
                     ,ERRMSG)*/NULL;
          /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
      END;
    ELSE
      SELECT
        DISTRIBUTION_SOURCE_BOOK
      INTO P_CORP_BOOK
      FROM
        FA_BOOK_CONTROLS
      WHERE BOOK_TYPE_CODE = P_BOOK_TYPE_CODE;
      SELECT
        PERIOD_NAME
      INTO C_PERIOD_FROM
      FROM
        FA_DEPRN_PERIODS
      WHERE PERIOD_COUNTER = P_PERIOD_COUNTER_FROM
        AND BOOK_TYPE_CODE = P_BOOK_TYPE_CODE;
      SELECT
        PERIOD_NAME
      INTO C_PERIOD_TO
      FROM
        FA_DEPRN_PERIODS
      WHERE PERIOD_COUNTER = P_PERIOD_COUNTER_TO
        AND BOOK_TYPE_CODE = P_BOOK_TYPE_CODE;
      /*SRW.MESSAGE('10000'
                 ,'Check ==' || P_PERIOD_COUNTER_TO)*/NULL;
      /*SRW.MESSAGE('10000'
                 ,'Check ==' || P_BOOK_TYPE_CODE)*/NULL;
      BEGIN
        SELECT
          'Y'
        INTO L_FLAG
        FROM
          FA_DEPRN_PERIODS
        WHERE BOOK_TYPE_CODE = P_BOOK_TYPE_CODE
          AND PERIOD_COUNTER = P_PERIOD_COUNTER_TO
          AND PERIOD_CLOSE_DATE is not null;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          SET_NAME('JL'
                  ,'JL_CO_FA_SAME_AS_PERIOD_CLOSED');
          SET_TOKEN('PERIOD'
                   ,C_PERIOD_TO
                   ,TRUE);
          SET_TOKEN('BOOK'
                   ,P_BOOK_TYPE_CODE
                   ,TRUE);
          ERRMSG := GET;
          /*SRW.MESSAGE(62331
                     ,ERRMSG)*/NULL;
          /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
        WHEN OTHERS THEN
          ERRMSG := SQLERRM;
          ERRNUM := SQLCODE;
          /*SRW.MESSAGE(ERRNUM
                     ,ERRMSG)*/NULL;
          /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
      END;
    END IF;
    JL_ZZ_FA_FUNCTIONS_PKG.POPULATE_FA_EXHIBIT_DATA(P_BOOK_TYPE_CODE
                                                   ,P_CORP_BOOK
                                                   ,P_CONC_REQUEST_ID
                                                   ,P_PERIOD_COUNTER_FROM
                                                   ,P_PERIOD_COUNTER_TO
                                                   ,P_MRCSOBTYPE);
    GET_BASE_CURR_DATA;
    RETURN (TRUE);
  END BEFOREREPORT;

  PROCEDURE GET_BASE_CURR_DATA IS
    BASE_CURR FND_CURRENCIES_VL.CURRENCY_CODE%TYPE;
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
          RAISE_ERR('JL_AR_FA_CURR_DET_NOT_DEFINED'
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
          RAISE_ERR('JL_AR_FA_CURR_DET_NOT_DEFINED'
                   ,'N');
        WHEN OTHERS THEN
          RAISE_ORA_ERR;
      END;
    END IF;
    C_BASE_CURRENCY_CODE := BASE_CURR;
    C_BASE_PRECISION := PREC;
    C_BASE_MIN_ACCT_UNIT := 0;
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
    SET_NAME('JL'
            ,MSGNAME);
    ERRMSG := GET;
    /*SRW.MESSAGE(JL_ZZ_FA_UTILITIES_PKG.GET_APP_ERRNUM('JL'
                                                     ,MSGNAME)
               ,ERRMSG)*/NULL;
    IF ABORT_FLAG = 'Y' THEN
      /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
    END IF;
  END RAISE_ERR;

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

  FUNCTION C_ORGANIZATION_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_ORGANIZATION_NAME;
  END C_ORGANIZATION_NAME_P;

  FUNCTION C_BASE_MIN_ACCT_UNIT_P RETURN NUMBER IS
  BEGIN
    RETURN C_BASE_MIN_ACCT_UNIT;
  END C_BASE_MIN_ACCT_UNIT_P;

  FUNCTION C_BASE_DESCRIPTION_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_BASE_DESCRIPTION;
  END C_BASE_DESCRIPTION_P;

  FUNCTION C_PERIOD_FROM_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_PERIOD_FROM;
  END C_PERIOD_FROM_P;

  FUNCTION C_PERIOD_TO_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_PERIOD_TO;
  END C_PERIOD_TO_P;

  FUNCTION C_SCALING_FACTOR_P RETURN NUMBER IS
  BEGIN
    RETURN C_SCALING_FACTOR;
  END C_SCALING_FACTOR_P;

  PROCEDURE SET_NAME(APPLICATION IN VARCHAR2
                    ,NAME IN VARCHAR2) IS
  BEGIN
   /* STPROC.INIT('begin FND_MESSAGE.SET_NAME(:APPLICATION, :NAME); end;');
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
   /* STPROC.INIT('declare TRANSLATE BOOLEAN; begin TRANSLATE := sys.diutil.int_to_bool(:TRANSLATE); FND_MESSAGE.SET_TOKEN(:TOKEN, :VALUE, TRANSLATE); end;');
    STPROC.BIND_I(TRANSLATE);
    STPROC.BIND_I(TOKEN);
    STPROC.BIND_I(VALUE);
    STPROC.EXECUTE;*/

    --TRANSLATE1 := sys.diutil.int_to_bool(TRANSLATE);
    FND_MESSAGE.SET_TOKEN(TOKEN, VALUE, TRANSLATE1);
  END SET_TOKEN;

  PROCEDURE RETRIEVE(MSGOUT OUT NOCOPY VARCHAR2) IS
  BEGIN
   /* STPROC.INIT('begin FND_MESSAGE.RETRIEVE(:MSGOUT); end;');
    STPROC.BIND_O(MSGOUT);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,MSGOUT);*/

		   FND_MESSAGE.RETRIEVE(MSGOUT);
  END RETRIEVE;

  PROCEDURE CLEAR IS
  BEGIN
  /*  STPROC.INIT('begin FND_MESSAGE.CLEAR; end;');
    STPROC.EXECUTE;*/null;
  END CLEAR;

  FUNCTION GET_STRING(APPIN IN VARCHAR2
                     ,NAMEIN IN VARCHAR2) RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
  /* STPROC.INIT('begin :X0 := FND_MESSAGE.GET_STRING(:APPIN, :NAMEIN); end;');
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
  /*  STPROC.INIT('begin :X0 := FND_MESSAGE.GET_NUMBER(:APPIN, :NAMEIN); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(APPIN);
    STPROC.BIND_I(NAMEIN);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/
    RETURN X0;
  END GET_NUMBER;

  FUNCTION GET RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
   /* STPROC.INIT('begin :X0 := FND_MESSAGE.GET; end;');
    STPROC.BIND_O(X0);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/X0 := FND_MESSAGE.GET;
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
 /*   STPROC.INIT('begin FND_MESSAGE.PARSE_ENCODED(:ENCODED_MESSAGE, :APP_SHORT_NAME, :MESSAGE_NAME); end;');
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
   /* STPROC.INIT('begin FND_MESSAGE.SET_ENCODED(:ENCODED_MESSAGE); end;');
    STPROC.BIND_I(ENCODED_MESSAGE);
    STPROC.EXECUTE;*/null;
  END SET_ENCODED;

  PROCEDURE RAISE_ERROR IS
  BEGIN
   /* STPROC.INIT('begin FND_MESSAGE.RAISE_ERROR; end;');
    STPROC.EXECUTE;*/null;
  END RAISE_ERROR;

END JL_JLARFEFR_XMLP_PKG;



/