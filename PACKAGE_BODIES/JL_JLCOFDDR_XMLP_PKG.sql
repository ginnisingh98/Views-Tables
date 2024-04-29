--------------------------------------------------------
--  DDL for Package Body JL_JLCOFDDR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_JLCOFDDR_XMLP_PKG" AS
/* $Header: JLCOFDDRB.pls 120.1 2007/12/25 16:46:30 dwkrishn noship $ */
  FUNCTION BOOKFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      L_BOOK VARCHAR2(15);
      L_BOOK_CLASS VARCHAR2(15);
      L_ACCOUNTING_FLEX_STRUCTURE NUMBER(15);
      L_CURRENCY_CODE VARCHAR2(15);
      L_DISTRIBUTION_SOURCE_BOOK VARCHAR2(15);
      L_PRECISION NUMBER(15);
    BEGIN
      SELECT
        BC.BOOK_TYPE_CODE,
        BC.BOOK_CLASS,
        BC.ACCOUNTING_FLEX_STRUCTURE,
        BC.DISTRIBUTION_SOURCE_BOOK,
        SOB.CURRENCY_CODE,
        CUR.PRECISION
      INTO L_BOOK,L_BOOK_CLASS,L_ACCOUNTING_FLEX_STRUCTURE,L_DISTRIBUTION_SOURCE_BOOK,L_CURRENCY_CODE,L_PRECISION
      FROM
        FA_BOOK_CONTROLS BC,
        GL_SETS_OF_BOOKS SOB,
        FND_CURRENCIES CUR
      WHERE BC.BOOK_TYPE_CODE = P_BOOK
        AND SOB.SET_OF_BOOKS_ID = BC.SET_OF_BOOKS_ID
        AND SOB.CURRENCY_CODE = CUR.CURRENCY_CODE;
      BOOK_CLASS := L_BOOK_CLASS;
      ACCOUNTING_FLEX_STRUCTURE := L_ACCOUNTING_FLEX_STRUCTURE;
      DISTRIBUTION_SOURCE_BOOK := L_DISTRIBUTION_SOURCE_BOOK;
      CURRENCY_CODE := L_CURRENCY_CODE;
      P_MIN_PRECISION := L_PRECISION;
      RETURN (L_BOOK);
    END;
    RETURN NULL;
  END BOOKFORMULA;

  FUNCTION PERIOD1FORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      L_PERIOD_NAME VARCHAR2(15);
      L_PERIOD_POD DATE;
      L_PERIOD_PCD DATE;
      L_PERIOD_PC NUMBER(15);
      L_PERIOD_FY NUMBER(15);
    BEGIN
      SELECT
        PERIOD_NAME,
        PERIOD_COUNTER,
        PERIOD_OPEN_DATE,
        NVL(PERIOD_CLOSE_DATE
           ,SYSDATE),
        FISCAL_YEAR
      INTO L_PERIOD_NAME,L_PERIOD_PC,L_PERIOD_POD,L_PERIOD_PCD,L_PERIOD_FY
      FROM
        FA_DEPRN_PERIODS
      WHERE BOOK_TYPE_CODE = P_BOOK
        AND PERIOD_NAME = P_PERIOD1;
      PERIOD1_PC := L_PERIOD_PC;
      PERIOD1_POD := L_PERIOD_POD;
      PERIOD1_PCD := L_PERIOD_PCD;
      PERIOD1_FY := L_PERIOD_FY;
      RETURN (L_PERIOD_NAME);
    END;
    RETURN NULL;
  END PERIOD1FORMULA;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    /*SRW.REFERENCE(P_BATCH_ID)*/NULL;
    IF P_BATCH_ID IS NOT NULL THEN
      C_DYNAMIC_WHERE_CLAUSE := ' and jh.je_batch_id = :P_BATCH_ID';
    ELSE
      C_DYNAMIC_WHERE_CLAUSE := ' and 1 = 1';
    END IF;
    /*SRW.REFERENCE(P_LINE_NUM)*/NULL;
    IF P_LINE_NUM IS NOT NULL THEN
      C_DYNAMIC_WHERE_CLAUSE := C_DYNAMIC_WHERE_CLAUSE || ' and jl1.je_line_num = :P_LINE_NUM';
    END IF;
    /*SRW.REFERENCE(P_ACCT_CCID)*/NULL;
    IF P_ACCT_CCID IS NOT NULL THEN
      C_DYNAMIC_WHERE_CLAUSE := C_DYNAMIC_WHERE_CLAUSE || ' and aj.code_combination_id = :P_ACCT_CCID';
    END IF;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION F_COMP_NAMEFORMULA(COMPANY_NAME IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RP_COMPANY_NAME := COMPANY_NAME;
    RETURN NULL;
  END F_COMP_NAMEFORMULA;

  FUNCTION ACCOUNTING_FLEX_STRUCTURE_P RETURN NUMBER IS
  BEGIN
    RETURN ACCOUNTING_FLEX_STRUCTURE;
  END ACCOUNTING_FLEX_STRUCTURE_P;

  FUNCTION CURRENCY_CODE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CURRENCY_CODE;
  END CURRENCY_CODE_P;

  FUNCTION BOOK_CLASS_P RETURN VARCHAR2 IS
  BEGIN
    RETURN BOOK_CLASS;
  END BOOK_CLASS_P;

  FUNCTION DISTRIBUTION_SOURCE_BOOK_P RETURN VARCHAR2 IS
  BEGIN
    RETURN DISTRIBUTION_SOURCE_BOOK;
  END DISTRIBUTION_SOURCE_BOOK_P;

  FUNCTION PERIOD1_PC_P RETURN NUMBER IS
  BEGIN
    RETURN PERIOD1_PC;
  END PERIOD1_PC_P;

  FUNCTION PERIOD1_PCD_P RETURN DATE IS
  BEGIN
    RETURN PERIOD1_PCD;
  END PERIOD1_PCD_P;

  FUNCTION PERIOD1_POD_P RETURN DATE IS
  BEGIN
    RETURN PERIOD1_POD;
  END PERIOD1_POD_P;

  FUNCTION PERIOD1_FY_P RETURN NUMBER IS
  BEGIN
    RETURN PERIOD1_FY;
  END PERIOD1_FY_P;

  FUNCTION RP_COMPANY_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_COMPANY_NAME;
  END RP_COMPANY_NAME_P;

  FUNCTION C_DYNAMIC_WHERE_CLAUSE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_DYNAMIC_WHERE_CLAUSE;
  END C_DYNAMIC_WHERE_CLAUSE_P;

END JL_JLCOFDDR_XMLP_PKG;




/
