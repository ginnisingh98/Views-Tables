--------------------------------------------------------
--  DDL for Package Body FA_FASRCRVW_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_FASRCRVW_XMLP_PKG" AS
/* $Header: FASRCRVWB.pls 120.0.12010000.2 2009/07/22 12:20:13 gigupta ship $ */
  PROCEDURE GET_CURRENCY_CODE(BOOK IN VARCHAR2) IS
  BEGIN
    SELECT
      FCURR.CURRENCY_CODE
    INTO C_CURRENCY_CODE
    FROM
      FA_BOOK_CONTROLS BKCTRL,
      FND_CURRENCIES_VL FCURR,
      GL_SETS_OF_BOOKS GSBKS
    WHERE BKCTRL.BOOK_TYPE_CODE = BOOK
      AND BKCTRL.SET_OF_BOOKS_ID = GSBKS.SET_OF_BOOKS_ID
      AND GSBKS.CURRENCY_CODE = FCURR.CURRENCY_CODE;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
    WHEN OTHERS THEN
      RAISE_ORA_ERR('20050');
  END GET_CURRENCY_CODE;

  PROCEDURE RAISE_ORA_ERR(ERRNO IN VARCHAR2) IS
    ERRMSG VARCHAR2(1000);
  BEGIN
    ERRMSG := SQLERRM;
    RAISE_APPLICATION_ERROR(-20101
                           ,NULL);
  END RAISE_ORA_ERR;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    select SUBSTR(argument1,INSTR(argument1,'=',1)+1,LENGTH(argument1)),
    SUBSTR(argument2,INSTR(argument2,'=',1)+1,LENGTH(argument2))
    into P_MASS_RECLASS_ID_T,P_REQUEST_ID_T
    FROM FND_CONCURRENT_REQUESTS
    WHERE REQUEST_ID =P_CONC_REQUEST_ID;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION D_BASIC_RATEFORMULA(BASIC_RATE IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    IF (BASIC_RATE IS NOT NULL) THEN
      RETURN (SUBSTRB(TO_CHAR(BASIC_RATE
                            ,'990D00')
                    ,2
                    ,6));
    END IF;
    RETURN (' ');
  END D_BASIC_RATEFORMULA;

  FUNCTION D_ADJUSTED_RATEFORMULA(ADJUSTED_RATE IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    IF (ADJUSTED_RATE IS NOT NULL) THEN
      RETURN (SUBSTRB(TO_CHAR(ADJUSTED_RATE
                            ,'990D00')
                    ,2
                    ,6));
    END IF;
    RETURN (' ');
  END D_ADJUSTED_RATEFORMULA;

  FUNCTION D_SALVAGE_VAL_PCTFORMULA(SALVAGE_VAL_PERCENTAGE IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    IF (SALVAGE_VAL_PERCENTAGE IS NOT NULL) THEN
      RETURN (SUBSTRB(TO_CHAR(SALVAGE_VAL_PERCENTAGE
                            ,'990D00')
                    ,2
                    ,6));
    END IF;
    RETURN (' ');
  END D_SALVAGE_VAL_PCTFORMULA;

  FUNCTION C_SETUPFORMULA RETURN NUMBER IS
    L_COMPANY_NAME VARCHAR2(30);
    BOOK VARCHAR2(15);
    ASSET_TYPE VARCHAR2(80);
    FULLY_RSVD VARCHAR2(80);
    FROM_COST NUMBER;
    TO_COST NUMBER;
    FROM_ASSET VARCHAR2(15);
    TO_ASSET VARCHAR2(15);
    FROM_DPIS DATE;
    TO_DPIS DATE;
    LOCATION VARCHAR2(220);
    EMP_NAME VARCHAR2(240);
    EMP_NUM VARCHAR2(30);
    OLD_CAT VARCHAR2(220);
    NEW_CAT VARCHAR2(220);
    ASSET_KEY VARCHAR2(220);
    FROM_ACCT VARCHAR2(780);
    TO_ACCT VARCHAR2(780);
  BEGIN
    SELECT
      SC.COMPANY_NAME
    INTO L_COMPANY_NAME
    FROM
      FA_SYSTEM_CONTROLS SC;
    RP_COMPANY_NAME := L_COMPANY_NAME;
    FA_MASS_REC_UTILS_PKG.GET_SELECTION_CRITERIA(X_MASS_RECLASS_ID => P_MASS_RECLASS_ID_T
                                                ,X_BOOK_TYPE_CODE => BOOK
                                                ,X_ASSET_TYPE => ASSET_TYPE
                                                ,X_FULLY_RSVD => FULLY_RSVD
                                                ,X_FROM_COST => FROM_COST
                                                ,X_TO_COST => TO_COST
                                                ,X_FROM_ASSET => FROM_ASSET
                                                ,X_TO_ASSET => TO_ASSET
                                                ,X_FROM_DPIS => FROM_DPIS
                                                ,X_TO_DPIS => TO_DPIS
                                                ,X_LOCATION => LOCATION
                                                ,X_EMPLOYEE_NAME => EMP_NAME
                                                ,X_EMPLOYEE_NUMBER => EMP_NUM
                                                ,X_OLD_CATEGORY => OLD_CAT
                                                ,X_NEW_CATEGORY => NEW_CAT
                                                ,X_ASSET_KEY => ASSET_KEY
                                                ,X_FROM_EXP_ACCT => FROM_ACCT
                                                ,X_TO_EXP_ACCT => TO_ACCT
                                                ,P_LOG_LEVEL_REC => NULL);
    GET_CURRENCY_CODE(BOOK);
    C_BOOK := BOOK;
    C_ASSET_TYPE := ASSET_TYPE;
    C_FULLY_RSVD := FULLY_RSVD;
    C_FROM_COST := FROM_COST;
    C_TO_COST := TO_COST;
    C_FROM_ASSET := FROM_ASSET;
    C_TO_ASSET := TO_ASSET;
    C_FROM_DPIS := FROM_DPIS;
    C_TO_DPIS := TO_DPIS;
    C_LOCATION := LOCATION;
    C_EMP_NAME := EMP_NAME;
    C_EMP_NUM := EMP_NUM;
    C_OLD_CATEGORY := OLD_CAT;
    C_NEW_CATEGORY := NEW_CAT;
    C_ASSET_KEY := ASSET_KEY;
    C_FROM_ACCT := FROM_ACCT;
    C_TO_ACCT := TO_ACCT;
    RETURN (0);
    RETURN NULL;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RP_COMPANY_NAME := ' ';
      C_BOOK := ' ';
      C_ASSET_TYPE := ' ';
      C_FULLY_RSVD := ' ';
      C_FROM_COST := NULL;
      C_TO_COST := NULL;
      C_FROM_ASSET := ' ';
      C_TO_ASSET := ' ';
      C_FROM_DPIS := NULL;
      C_TO_DPIS := NULL;
      C_LOCATION := ' ';
      C_EMP_NAME := ' ';
      C_EMP_NUM := ' ';
      C_OLD_CATEGORY := ' ';
      C_NEW_CATEGORY := ' ';
      C_ASSET_KEY := ' ';
      C_FROM_ACCT := ' ';
      C_TO_ACCT := ' ';
      RETURN (1);
  END C_SETUPFORMULA;

  FUNCTION C_ASSET_TYPE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_ASSET_TYPE;
  END C_ASSET_TYPE_P;

  FUNCTION C_FULLY_RSVD_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_FULLY_RSVD;
  END C_FULLY_RSVD_P;

  FUNCTION C_FROM_COST_P RETURN NUMBER IS
  BEGIN
    RETURN C_FROM_COST;
  END C_FROM_COST_P;

  FUNCTION C_TO_COST_P RETURN NUMBER IS
  BEGIN
    RETURN C_TO_COST;
  END C_TO_COST_P;

  FUNCTION C_FROM_ASSET_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_FROM_ASSET;
  END C_FROM_ASSET_P;

  FUNCTION C_TO_ASSET_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_TO_ASSET;
  END C_TO_ASSET_P;

  FUNCTION C_FROM_DPIS_P RETURN DATE IS
  BEGIN
    RETURN C_FROM_DPIS;
  END C_FROM_DPIS_P;

  FUNCTION C_TO_DPIS_P RETURN DATE IS
  BEGIN
    RETURN C_TO_DPIS;
  END C_TO_DPIS_P;

  FUNCTION C_TO_ACCT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_TO_ACCT;
  END C_TO_ACCT_P;

  FUNCTION C_LOCATION_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_LOCATION;
  END C_LOCATION_P;

  FUNCTION C_EMP_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_EMP_NAME;
  END C_EMP_NAME_P;

  FUNCTION C_EMP_NUM_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_EMP_NUM;
  END C_EMP_NUM_P;

  FUNCTION C_OLD_CATEGORY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_OLD_CATEGORY;
  END C_OLD_CATEGORY_P;

  FUNCTION C_ASSET_KEY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_ASSET_KEY;
  END C_ASSET_KEY_P;

  FUNCTION C_FROM_ACCT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_FROM_ACCT;
  END C_FROM_ACCT_P;

  FUNCTION C_NEW_CATEGORY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_NEW_CATEGORY;
  END C_NEW_CATEGORY_P;

  FUNCTION C_CURRENCY_CODE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_CURRENCY_CODE;
  END C_CURRENCY_CODE_P;

  FUNCTION C_BOOK_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_BOOK;
  END C_BOOK_P;

  FUNCTION RP_COMPANY_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_COMPANY_NAME;
  END RP_COMPANY_NAME_P;

END FA_FASRCRVW_XMLP_PKG;


/
