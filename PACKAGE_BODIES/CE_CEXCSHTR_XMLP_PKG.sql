--------------------------------------------------------
--  DDL for Package Body CE_CEXCSHTR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_CEXCSHTR_XMLP_PKG" AS
/* $Header: CEXCSHTRB.pls 120.0 2007/12/28 07:54:25 abraghun noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    DECLARE
      L_MESSAGE FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;
    BEGIN
    P_AS_OF_DATE_T :=P_AS_OF_DATE;
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      INIT_SECURITY;
      BEGIN
        SELECT
          L.MEANING
        INTO
          C_ALL_TRANSLATION
        FROM
          GL_SETS_OF_BOOKS SOB,
          CE_SYSTEM_PARAMETERS SP,
          CE_LOOKUPS L
        WHERE SOB.SET_OF_BOOKS_ID = SP.SET_OF_BOOKS_ID
          AND L.LOOKUP_TYPE = 'LITERAL'
          AND L.LOOKUP_CODE = 'ALL'
          AND ROWNUM = 1;
      EXCEPTION
        WHEN OTHERS THEN
          SET_NAME('CE'
                  ,'CE_PURGE_NO_SOB');
          L_MESSAGE := GET;
          RAISE_APPLICATION_ERROR(-20101
                                 ,NULL);
      END;
      IF (P_SORT_BY IS NOT NULL) THEN
        BEGIN
          SELECT
            L.LOOKUP_CODE,
            L.MEANING
          INTO
            C_ORDER_BY
            ,C_ORDER_BY_MEANING
          FROM
            CE_LOOKUPS L
          WHERE L.LOOKUP_TYPE = 'ABR_REPORT_SORT_BY'
            AND L.LOOKUP_CODE = P_SORT_BY;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            SET_NAME('CE'
                    ,'CE_LOOKUP_ERR');
            L_MESSAGE := GET;
            RAISE_APPLICATION_ERROR(-20101
                                   ,NULL);
        END;
      ELSE
        C_ORDER_BY := C_ALL_TRANSLATION;
      END IF;
      IF (P_BANK_ACCOUNT_ID IS NOT NULL) THEN
        BEGIN
          SELECT
            BB.BANK_NAME,
            BB.BANK_BRANCH_NAME,
            B.BANK_ACCOUNT_NAME,
            B.BANK_ACCOUNT_NUM,
            B.CURRENCY_CODE
          INTO
            C_BANK_NAME_DSP
            ,C_BANK_BRANCH_NAME_DSP
            ,C_BANK_ACCOUNT_NAME_DSP
            ,C_BANK_ACCOUNT_NUM_DSP
            ,C_BANK_CURRENCY_CODE_DSP
          FROM
            CE_BANK_BRANCHES_V BB,
            CE_BANK_ACCTS_GT_V B
          WHERE B.BANK_ACCOUNT_ID = P_BANK_ACCOUNT_ID
            AND BB.BRANCH_PARTY_ID = B.BANK_BRANCH_ID;
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
       -- P_AS_OF_DATE := SYSDATE;
        P_AS_OF_DATE_T := SYSDATE;
      END IF;
      IF (P_SORT_BY = 'PAYMENT/RECEIPT NUMBER') THEN
        C_SORT_BY_LEX := '14, 8';
      ELSIF (P_SORT_BY = 'MATURITY DATE') THEN
        C_SORT_BY_LEX := '7';
      ELSIF (P_SORT_BY = 'PAYMENT METHOD') THEN
        C_SORT_BY_LEX := '9';
      END IF;
      IF (P_DEBUG_MODE = 'Y') THEN
        NULL;
      END IF;
    END;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      NULL;
    END;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION G_CHECK_RECEIPTGROUPFILTER(BANK_ACCOUNT_NUM IN VARCHAR2) RETURN BOOLEAN IS
  BEGIN
    IF BANK_ACCOUNT_NUM = '' THEN
      C_THE_END := 'N';
    ELSE
      C_THE_END := 'Y';
    END IF;
    RETURN (TRUE);
    RETURN (TRUE);
  END G_CHECK_RECEIPTGROUPFILTER;

  FUNCTION C_DATEFORMATFORMULA(C_DATEFORMAT IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN (fnd_global.nls_date_format);
  END C_DATEFORMATFORMULA;

  FUNCTION C_COMPANY_NAME_HEADER_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_COMPANY_NAME_HEADER;
  END C_COMPANY_NAME_HEADER_P;

  FUNCTION C_ALL_TRANSLATION_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_ALL_TRANSLATION;
  END C_ALL_TRANSLATION_P;

  FUNCTION C_DATE_CHECK_LEX_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_DATE_CHECK_LEX;
  END C_DATE_CHECK_LEX_P;

  FUNCTION C_RECON_CHECK_LEX_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_RECON_CHECK_LEX;
  END C_RECON_CHECK_LEX_P;

  FUNCTION C_DATE_RECEIPT_LEX_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_DATE_RECEIPT_LEX;
  END C_DATE_RECEIPT_LEX_P;

  FUNCTION C_THE_END_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_THE_END;
  END C_THE_END_P;

  FUNCTION C_CB_BEGIN_DATE_P RETURN DATE IS
  BEGIN
    RETURN C_CB_BEGIN_DATE;
  END C_CB_BEGIN_DATE_P;

  FUNCTION C_BANK_NAME_DSP_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_BANK_NAME_DSP;
  END C_BANK_NAME_DSP_P;

  FUNCTION C_ORDER_BY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_ORDER_BY;
  END C_ORDER_BY_P;

  FUNCTION C_BANK_BRANCH_NAME_DSP_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_BANK_BRANCH_NAME_DSP;
  END C_BANK_BRANCH_NAME_DSP_P;

  FUNCTION C_BANK_ACCOUNT_NAME_DSP_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_BANK_ACCOUNT_NAME_DSP;
  END C_BANK_ACCOUNT_NAME_DSP_P;

  FUNCTION C_BANK_ACCOUNT_NUM_DSP_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_BANK_ACCOUNT_NUM_DSP;
  END C_BANK_ACCOUNT_NUM_DSP_P;

  FUNCTION C_BANK_CURRENCY_CODE_DSP_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_BANK_CURRENCY_CODE_DSP;
  END C_BANK_CURRENCY_CODE_DSP_P;

  FUNCTION C_SORT_BY_LEX_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_SORT_BY_LEX;
  END C_SORT_BY_LEX_P;

  FUNCTION C_ORDER_BY_MEANING_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_ORDER_BY_MEANING;
  END C_ORDER_BY_MEANING_P;

  PROCEDURE SET_NAME(APPLICATION IN VARCHAR2
                    ,NAME IN VARCHAR2) IS
  BEGIN
    begin
    	FND_MESSAGE.SET_NAME(APPLICATION, NAME);
    end;
  END SET_NAME;

  /*PROCEDURE SET_TOKEN(TOKEN IN VARCHAR2
                     ,VALUE IN VARCHAR2
                     ,TRANSLATE IN BOOLEAN) IS
  BEGIN
    declare TRANSLATE BOOLEAN; begin TRANSLATE := sys.diutil.int_to_bool(TRANSLATE); FND_MESSAGE.SET_TOKEN(TOKEN, VALUE, TRANSLATE); end;

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
  END GET_STRING;

  FUNCTION GET_NUMBER(APPIN IN VARCHAR2
                     ,NAMEIN IN VARCHAR2) RETURN NUMBER IS
    X0 NUMBER;
  BEGIN
    STPROC.INIT('begin :X0 := FND_MESSAGE.GET_NUMBER(:APPIN, :NAMEIN); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(APPIN);
    STPROC.BIND_I(NAMEIN);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);
    RETURN X0;
  END GET_NUMBER;*/

  FUNCTION GET RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
    begin
    X0 := FND_MESSAGE.GET;
    RETURN X0;
    end;
  END GET;

 /* FUNCTION GET_ENCODED RETURN VARCHAR2 IS
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
     begin CEP_STANDARD.init_security; end;

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

END CE_CEXCSHTR_XMLP_PKG;


/