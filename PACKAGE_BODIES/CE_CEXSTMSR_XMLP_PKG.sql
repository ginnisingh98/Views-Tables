--------------------------------------------------------
--  DDL for Package Body CE_CEXSTMSR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_CEXSTMSR_XMLP_PKG" AS
/* $Header: CEXSTMSRB.pls 120.0 2007/12/28 07:57:30 abraghun noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    DECLARE
      L_MESSAGE FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;
    BEGIN
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      P_STAT_DATE_FROM_T := TO_CHAR(P_STAT_DATE_FROM,fnd_global.nls_date_format);
      P_STAT_DATE_TO_T := TO_CHAR(P_STAT_DATE_TO,fnd_global.nls_date_format);
      INIT_SECURITY;
      IF (P_TEST_LAYOUT = 'Y') THEN
        RAISE NO_DATA_FOUND;
      END IF;
      BEGIN
        SELECT
          L.MEANING
        INTO
          C_ALL_TRANSLATION
        FROM
          CE_LOOKUPS L
        WHERE L.LOOKUP_TYPE = 'LITERAL'
          AND L.LOOKUP_CODE = 'ALL';
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          SET_NAME('CE'
                  ,'CE_PURGE_NO_SOB');
          L_MESSAGE := GET;
          RAISE_APPLICATION_ERROR(-20101
                                 ,NULL);
      END;
      IF (P_BANK_ACCOUNT_ID IS NOT NULL) THEN
        BEGIN
          SELECT
            ABB.BANK_NAME,
            ABB.BANK_BRANCH_NAME,
            ABA.BANK_ACCOUNT_NAME,
            ABA.BANK_ACCOUNT_NUM,
            ABA.CURRENCY_CODE
          INTO
            C_BANK_NAME_DSP
            ,C_BANK_BRANCH_NAME_DSP
            ,C_BANK_ACCOUNT_NAME_DSP
            ,C_BANK_ACCOUNT_NUM_DSP
            ,C_BANK_CURRENCY_CODE_DSP
          FROM
            CE_BANK_BRANCHES_V ABB,
            CE_BANK_ACCTS_GT_V ABA
          WHERE ABA.BANK_ACCOUNT_ID = P_BANK_ACCOUNT_ID
            AND ABB.BRANCH_PARTY_ID = ABA.BANK_BRANCH_ID;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            SET_NAME('CE'
                    ,'CE_INVALID_BANK');
            L_MESSAGE := GET;
            RAISE_APPLICATION_ERROR(-20101
                                   ,NULL);
        END;
      ELSE
        C_BANK_NAME_DSP := C_ALL_TRANSLATION;
        C_BANK_BRANCH_NAME_DSP := C_ALL_TRANSLATION;
        C_BANK_ACCOUNT_NAME_DSP := C_ALL_TRANSLATION;
        C_BANK_ACCOUNT_NUM_DSP := C_ALL_TRANSLATION;
        C_BANK_CURRENCY_CODE_DSP := C_ALL_TRANSLATION;
      END IF;
      IF (P_AS_OF_DATE IS NULL) THEN
        C_AS_OF_DATE_DSP := ' - ';
      ELSE
        C_AS_OF_DATE_DSP := P_AS_OF_DATE;
      END IF;
      SELECT
        MEANING
      INTO
        C_BALANCES_BY
      FROM
        CE_LOOKUPS
      WHERE LOOKUP_TYPE = 'BALANCES_BY'
        AND LOOKUP_CODE = P_BALANCES_BY;
      IF (P_STAT_DATE_FROM IS NOT NULL AND P_STAT_DATE_TO IS NOT NULL) THEN
        C_STAT_DATE_LEX := 'sh.statement_date BETWEEN to_date(''' || TO_CHAR(P_STAT_DATE_FROM
                                  ,'DD-MON-YYYY') || ''',''DD-MON-YYYY'') AND to_date(''' || TO_CHAR(P_STAT_DATE_TO
                                  ,'DD-MON-YYYY') || ''',''DD-MON-YYYY'')';
      ELSIF (P_STAT_DATE_FROM IS NULL AND P_STAT_DATE_TO IS NOT NULL) THEN
        C_STAT_DATE_LEX := 'sh.statement_date <= to_date(''' || TO_CHAR(P_STAT_DATE_TO
                                  ,'DD-MON-YYYY') || ''',''DD-MON-YYYY'')';
      ELSIF (P_STAT_DATE_FROM IS NOT NULL AND P_STAT_DATE_TO IS NULL) THEN
        C_STAT_DATE_LEX := 'sh.statement_date >= to_date(''' || TO_CHAR(P_STAT_DATE_FROM
                                  ,'DD-MON-YYYY') || ''',''DD-MON-YYYY'')';
      END IF;
      IF (P_STAT_NUMBER_FROM IS NOT NULL AND P_STAT_NUMBER_TO IS NOT NULL) THEN
        C_STAT_NUMBER_LEX := 'sh.statement_number BETWEEN ''' || P_STAT_NUMBER_FROM || ''' AND ''' || P_STAT_NUMBER_TO || '''';
      ELSIF (P_STAT_NUMBER_FROM IS NULL AND P_STAT_NUMBER_TO IS NOT NULL) THEN
        C_STAT_NUMBER_LEX := 'sh.statement_number <= ''' || P_STAT_NUMBER_TO || '''';
      ELSIF (P_STAT_NUMBER_FROM IS NOT NULL AND P_STAT_NUMBER_TO IS NULL) THEN
        C_STAT_NUMBER_LEX := 'sh.statement_number >= ''' || P_STAT_NUMBER_FROM || '''';
      END IF;
      IF (P_DEBUG_MODE = 'Y') THEN
        NULL;
      END IF;
    END;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION C_NET_MOVEMENTFORMULA(C_STAT_END_BAL IN NUMBER
                                ,C_STAT_BEGIN_BAL IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (C_STAT_END_BAL - C_STAT_BEGIN_BAL);
  END C_NET_MOVEMENTFORMULA;

  FUNCTION C_ITEMSFORMULA(C_STAT_HEADER_ID IN NUMBER) RETURN NUMBER IS
  BEGIN
    DECLARE
      ITEMS CE_STATEMENT_LINES.STATEMENT_LINE_ID%TYPE;
    BEGIN
      SELECT
        count(*)
      INTO
        ITEMS
      FROM
        CE_STATEMENT_LINES
      WHERE STATEMENT_HEADER_ID = C_STAT_HEADER_ID;
      RETURN (NVL(ITEMS
                ,0));
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN (0);
    END;
    RETURN NULL;
  END C_ITEMSFORMULA;

  FUNCTION C_UNREC_ITEMSFORMULA(C_STAT_HEADER_ID IN NUMBER) RETURN NUMBER IS
  BEGIN
    DECLARE
      ITEMS CE_STATEMENT_LINES.STATEMENT_LINE_ID%TYPE;
    BEGIN
      SELECT
        count(*)
      INTO
        ITEMS
      FROM
        CE_STATEMENT_LINES
      WHERE STATEMENT_HEADER_ID = C_STAT_HEADER_ID
        AND STATUS = 'UNRECONCILED';
      RETURN (NVL(ITEMS
                ,0));
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN (0);
    END;
    RETURN NULL;
  END C_UNREC_ITEMSFORMULA;

  FUNCTION C_STAT_UNREC_AMOUNTFORMULA(C_STAT_HEADER_ID IN NUMBER) RETURN NUMBER IS
  BEGIN
    DECLARE
      AMOUNT CE_STATEMENT_LINES.AMOUNT%TYPE;
      AMOUNT_CLEARED CE_RECONCILED_TRANSACTIONS_V.AMOUNT_CLEARED%TYPE;
    BEGIN
      SELECT
        SUM(AMOUNT)
      INTO
        AMOUNT
      FROM
        CE_STATEMENT_LINES
      WHERE STATEMENT_HEADER_ID = C_STAT_HEADER_ID;
      SELECT
        SUM(AMOUNT_CLEARED)
      INTO
        AMOUNT_CLEARED
      FROM
        CE_RECONCILED_TRANSACTIONS_V
      WHERE STATEMENT_HEADER_ID = C_STAT_HEADER_ID;
      RETURN (NVL(AMOUNT
                ,0) - NVL(AMOUNT_CLEARED
                ,0));
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN (0);
    END;
    RETURN NULL;
  END C_STAT_UNREC_AMOUNTFORMULA;

  FUNCTION G_BANKGROUPFILTER(C_BANK_ID IN NUMBER) RETURN BOOLEAN IS
  BEGIN
    IF (C_BANK_ID IS NOT NULL) THEN
      C_THE_END := 'Y';
    END IF;
    RETURN (TRUE);
  END G_BANKGROUPFILTER;

  FUNCTION C_LINES_UNREC_AMOUNTFORMULA(C_STAT_LINE_STATUS IN VARCHAR2
                                      ,C_STAT_LINE_TYPE IN VARCHAR2
                                      ,C_STAT_LINE_AMOUNT IN NUMBER
                                      ,C_LINES_SUM_CLEARED IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF (C_STAT_LINE_STATUS = 'EXTERNAL') THEN
      RETURN (0);
    ELSE
      IF (C_STAT_LINE_STATUS not in ('UNRECONCILED','ERROR')) THEN
        RETURN (0);
      ELSIF (C_STAT_LINE_TYPE = 'RECEIPT') THEN
        RETURN (C_STAT_LINE_AMOUNT - NVL(C_LINES_SUM_CLEARED
                  ,0));
      ELSE
        RETURN -1 * (C_STAT_LINE_AMOUNT - NVL(C_LINES_SUM_CLEARED
                  ,0));
      END IF;
    END IF;
    RETURN NULL;
  END C_LINES_UNREC_AMOUNTFORMULA;

  FUNCTION C_STAT_END_BALFORMULA(C_STAT_BEGIN_BAL IN NUMBER
                                ,C_STAT_DEBIT_AMOUNT IN NUMBER
                                ,C_STAT_CREDIT_AMOUNT IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (NVL(C_STAT_BEGIN_BAL
              ,0) - C_STAT_DEBIT_AMOUNT + C_STAT_CREDIT_AMOUNT);
  END C_STAT_END_BALFORMULA;

  FUNCTION C_DATEFORMATFORMULA(C_DATEFORMAT IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
   -- RETURN (C_DATEFORMAT);
    RETURN (fnd_global.nls_date_format);
  END C_DATEFORMATFORMULA;

  FUNCTION C_ALL_TRANSLATION_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_ALL_TRANSLATION;
  END C_ALL_TRANSLATION_P;

  FUNCTION C_BANK_NAME_DSP_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_BANK_NAME_DSP;
  END C_BANK_NAME_DSP_P;

  FUNCTION C_STAT_DATE_LEX_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_STAT_DATE_LEX;
  END C_STAT_DATE_LEX_P;

  FUNCTION C_SOB_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_SOB_NAME;
  END C_SOB_NAME_P;

  FUNCTION C_SET_OF_BOOKS_ID_P RETURN NUMBER IS
  BEGIN
    RETURN C_SET_OF_BOOKS_ID;
  END C_SET_OF_BOOKS_ID_P;

  FUNCTION C_THE_END_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_THE_END;
  END C_THE_END_P;

  FUNCTION C_FUNC_CURR_CODE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_FUNC_CURR_CODE;
  END C_FUNC_CURR_CODE_P;

  FUNCTION C_BANK_BRANCH_NAME_DSP_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_BANK_BRANCH_NAME_DSP;
  END C_BANK_BRANCH_NAME_DSP_P;

  FUNCTION C_BANK_ACCOUNT_NUM_DSP_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_BANK_ACCOUNT_NUM_DSP;
  END C_BANK_ACCOUNT_NUM_DSP_P;

  FUNCTION C_BANK_ACCOUNT_NAME_DSP_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_BANK_ACCOUNT_NAME_DSP;
  END C_BANK_ACCOUNT_NAME_DSP_P;

  FUNCTION C_BANK_CURRENCY_CODE_DSP_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_BANK_CURRENCY_CODE_DSP;
  END C_BANK_CURRENCY_CODE_DSP_P;

  FUNCTION C_STAT_NUMBER_LEX_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_STAT_NUMBER_LEX;
  END C_STAT_NUMBER_LEX_P;

  FUNCTION C_AS_OF_DATE_DSP_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_AS_OF_DATE_DSP;
  END C_AS_OF_DATE_DSP_P;

  FUNCTION C_BALANCES_BY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_BALANCES_BY;
  END C_BALANCES_BY_P;

  PROCEDURE SET_NAME(APPLICATION IN VARCHAR2
                    ,NAME IN VARCHAR2) IS
  BEGIN

begin FND_MESSAGE.SET_NAME(APPLICATION, NAME); end;
    --STPROC.BIND_I(APPLICATION);
    --STPROC.BIND_I(NAME);
    --STPROC.EXECUTE;
  END SET_NAME;

 /* PROCEDURE SET_TOKEN(TOKEN IN VARCHAR2
                     ,VALUE IN VARCHAR2
                     ,TRANSLATE IN BOOLEAN) IS
  BEGIN
    STPROC.INIT('declare TRANSLATE BOOLEAN; begin TRANSLATE := sys.diutil.int_to_bool(:TRANSLATE); FND_MESSAGE.SET_TOKEN(:TOKEN, :VALUE, TRANSLATE); end;');
    STPROC.BIND_I(TRANSLATE);
    STPROC.BIND_I(TOKEN);
    STPROC.BIND_I(VALUE);
    STPROC.EXECUTE;
  END SET_TOKEN;

  PROCEDURE RETRIEVE(MSGOUT OUT NOCOPY VARCHAR2) IS
  BEGIN
    STPROC.INIT('begin FND_MESSAGE.RETRIEVE(:MSGOUT); end;');
    STPROC.BIND_O(MSGOUT);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,MSGOUT);
  END RETRIEVE;

  PROCEDURE CLEAR IS
  BEGIN
    STPROC.INIT('begin FND_MESSAGE.CLEAR; end;');
    STPROC.EXECUTE;
  END CLEAR;

  FUNCTION GET_STRING(APPIN IN VARCHAR2
                     ,NAMEIN IN VARCHAR2) RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
    STPROC.INIT('begin :X0 := FND_MESSAGE.GET_STRING(:APPIN, :NAMEIN); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(APPIN);
    STPROC.BIND_I(NAMEIN);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);
    RETURN X0;
  END GET_STRING;*/

  FUNCTION GET RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
    begin X0 := FND_MESSAGE.GET; end;
    --STPROC.BIND_O(X0);
    --STPROC.EXECUTE;
    --STPROC.RETRIEVE(1                 ,X0);
    RETURN X0;
  END GET;

  /*FUNCTION GET_ENCODED RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
    STPROC.INIT('begin :X0 := FND_MESSAGE.GET_ENCODED; end;');
    STPROC.BIND_O(X0);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);
    RETURN X0;
  END GET_ENCODED;

  PROCEDURE PARSE_ENCODED(ENCODED_MESSAGE IN VARCHAR2
                         ,APP_SHORT_NAME OUT NOCOPY VARCHAR2
                         ,MESSAGE_NAME OUT NOCOPY VARCHAR2) IS
  BEGIN
    STPROC.INIT('begin FND_MESSAGE.PARSE_ENCODED(:ENCODED_MESSAGE, :APP_SHORT_NAME, :MESSAGE_NAME); end;');
    STPROC.BIND_I(ENCODED_MESSAGE);
    STPROC.BIND_O(APP_SHORT_NAME);
    STPROC.BIND_O(MESSAGE_NAME);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(2
                   ,APP_SHORT_NAME);
    STPROC.RETRIEVE(3
                   ,MESSAGE_NAME);
  END PARSE_ENCODED;

  PROCEDURE SET_ENCODED(ENCODED_MESSAGE IN VARCHAR2) IS
  BEGIN
    STPROC.INIT('begin FND_MESSAGE.SET_ENCODED(:ENCODED_MESSAGE); end;');
    STPROC.BIND_I(ENCODED_MESSAGE);
    STPROC.EXECUTE;
  END SET_ENCODED;

  PROCEDURE RAISE_ERROR IS
  BEGIN
    STPROC.INIT('begin FND_MESSAGE.RAISE_ERROR; end;');
    STPROC.EXECUTE;
  END RAISE_ERROR;

  PROCEDURE DEBUG(LINE IN VARCHAR2) IS
  BEGIN
    STPROC.INIT('begin CEP_STANDARD.DEBUG(:LINE); end;');
    STPROC.BIND_I(LINE);
    STPROC.EXECUTE;
  END DEBUG;

  PROCEDURE ENABLE_DEBUG IS
  BEGIN
    STPROC.INIT('begin CEP_STANDARD.ENABLE_DEBUG; end;');
    STPROC.EXECUTE;
  END ENABLE_DEBUG;

  PROCEDURE DISABLE_DEBUG IS
  BEGIN
    STPROC.INIT('begin CEP_STANDARD.DISABLE_DEBUG; end;');
    STPROC.EXECUTE;
  END DISABLE_DEBUG;*/

  PROCEDURE INIT_SECURITY IS
  BEGIN
    begin cep_standard.init_security; end;
    --STPROC.EXECUTE;
  END INIT_SECURITY;

 /* FUNCTION GET_WINDOW_SESSION_TITLE RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
    STPROC.INIT('begin :X0 := CEP_STANDARD.GET_WINDOW_SESSION_TITLE; end;');
    STPROC.BIND_O(X0);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);
    RETURN X0;
  END GET_WINDOW_SESSION_TITLE;

  FUNCTION GET_EFFECTIVE_DATE(P_BANK_ACCOUNT_ID IN NUMBER
                             ,P_TRX_CODE IN VARCHAR2
                             ,P_RECEIPT_DATE IN DATE) RETURN DATE IS
    X0 DATE;
  BEGIN
    STPROC.INIT('begin :X0 := CEP_STANDARD.GET_EFFECTIVE_DATE(:P_BANK_ACCOUNT_ID, :P_TRX_CODE, :P_RECEIPT_DATE); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(P_BANK_ACCOUNT_ID);
    STPROC.BIND_I(P_TRX_CODE);
    STPROC.BIND_I(P_RECEIPT_DATE);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);
    RETURN X0;
  END GET_EFFECTIVE_DATE;*/

END CE_CEXSTMSR_XMLP_PKG;


/