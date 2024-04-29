--------------------------------------------------------
--  DDL for Package Body CE_CEJEEXER_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_CEJEEXER_XMLP_PKG" AS
/* $Header: CEJEEXERB.pls 120.0 2007/12/28 07:51:32 abraghun noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
    L_MESSAGE FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;
  BEGIN
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    CEP_STANDARD.INIT_SECURITY;
    BEGIN
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;

select SUBSTR(argument1,INSTR(argument1,'=',1)+1,LENGTH(argument1)),
SUBSTR(argument2,INSTR(argument2,'=',1)+1,LENGTH(argument2)),
SUBSTR(argument3,INSTR(argument3,'=',1)+1,LENGTH(argument3)),
SUBSTR(argument4,INSTR(argument4,'=',1)+1,LENGTH(argument4)),
SUBSTR(argument5,INSTR(argument5,'=',1)+1,LENGTH(argument5)),
SUBSTR(argument6,INSTR(argument6,'=',1)+1,LENGTH(argument6)),
SUBSTR(argument7,INSTR(argument7,'=',1)+1,LENGTH(argument7))
into
P_REQUEST_ID,
P_BANK_BRANCH_ID,
P_BANK_ACCOUNT_ID,
P_STAT_NUMBER_FROM,
P_STAT_NUMBER_TO,
P_STAT_DATE_FROM,
P_STAT_DATE_TO
from FND_CONCURRENT_REQUESTS
where request_id=P_CONC_REQUEST_ID;

ZP_STAT_DATE_FROM := to_char(P_STAT_DATE_FROM,'DD-MON-YYYY');
ZP_STAT_DATE_TO :=   to_char(P_STAT_DATE_TO,'DD-MON-YYYY');



			      /*
				'P_REQUEST_ID=' || g_request_id,
						'P_BANK_BRANCH_ID=' || g_p_bank_branch_id,
						'P_BANK_ACCOUNT_ID=' || g_p_bank_account_id,
						'P_STAT_NUMBER_FROM=' || g_p_statement_number_from,
						'P_STAT_NUMBER_TO='||g_p_statement_number_to,
						'P_STAT_DATE_FROM=' || g_p_statement_date_from,
						'P_STAT_DATE_TO=

			      */


      SELECT
        L.MEANING
      INTO C_ALL_TRANSLATION
      FROM
        CE_LOOKUPS L
      WHERE L.LOOKUP_TYPE = 'LITERAL'
        AND L.LOOKUP_CODE = 'ALL';
      C_COMPANY_NAME_HEADER := SUBSTR(CEP_STANDARD.GET_WINDOW_SESSION_TITLE
                                     ,1
                                     ,80);
    EXCEPTION
      WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('CE'
                ,'CE_PURGE_NO_SOB');
        L_MESSAGE := FND_MESSAGE.GET;
        RAISE_APPLICATION_ERROR(-20101
                               ,NULL);
    END;
    IF (P_BANK_BRANCH_ID IS NOT NULL) THEN
      BEGIN
        SELECT
          ABB.BANK_BRANCH_NAME
        INTO C_BANK_BRANCH_NAME_DSP
        FROM
          CE_BANK_BRANCHES_V ABB
        WHERE ABB.BRANCH_PARTY_ID = P_BANK_BRANCH_ID;
      EXCEPTION
        WHEN OTHERS THEN
          FND_MESSAGE.SET_NAME('CE'
                  ,'CE_INVALID_BANK_BRANCH');
          L_MESSAGE := FND_MESSAGE.GET;
          RAISE_APPLICATION_ERROR(-20101
                                 ,NULL);
      END;
      IF (P_BANK_ACCOUNT_ID IS NOT NULL) THEN
        BEGIN
          SELECT
            ABA.BANK_ACCOUNT_NUM,
            ABA.CURRENCY_CODE
          INTO C_BANK_ACCOUNT_NUM_DSP,C_BANK_CURRENCY_CODE_DSP
          FROM
            CE_BANK_ACCTS_GT_V ABA
          WHERE ABA.BANK_ACCOUNT_ID = P_BANK_ACCOUNT_ID
            AND ABA.ACCOUNT_CLASSIFICATION = 'INTERNAL';
        EXCEPTION
          WHEN OTHERS THEN
            FND_MESSAGE.SET_NAME('CE'
                    ,'CE_INVALID_BANK_ACC');
            L_MESSAGE := FND_MESSAGE.GET;
            RAISE_APPLICATION_ERROR(-20101
                                   ,NULL);
        END;
      ELSE
        C_BANK_ACCOUNT_NUM_DSP := ' -';
        C_BANK_CURRENCY_CODE_DSP := ' -';
      END IF;
    ELSE
      C_BANK_BRANCH_NAME_DSP := C_ALL_TRANSLATION;
      C_BANK_CURRENCY_CODE_DSP := C_ALL_TRANSLATION;
    END IF;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    DELETE FROM CE_JE_MESSAGES
     WHERE REQUEST_ID = P_REQUEST_ID;
    COMMIT;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION C_DATEFORMATFORMULA(C_DATEFORMAT IN VARCHAR2) RETURN CHAR IS
  BEGIN
    RETURN (C_DATEFORMAT);
  END C_DATEFORMATFORMULA;

  FUNCTION C_MESSAGE_DSPFORMULA(ERROR IN VARCHAR2) RETURN CHAR IS
    L_MESSAGE FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;
  BEGIN
    FND_MESSAGE.SET_ENCODED(ERROR);
    L_MESSAGE := FND_MESSAGE.GET;
    IF L_MESSAGE IS NULL THEN
      FND_MESSAGE.SET_NAME('CE'
              ,ERROR);
      L_MESSAGE := FND_MESSAGE.GET;
    END IF;
    RETURN (L_MESSAGE);
    RETURN NULL;
  END C_MESSAGE_DSPFORMULA;

  FUNCTION C_ALL_TRANSLATION_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_ALL_TRANSLATION;
  END C_ALL_TRANSLATION_P;

  FUNCTION C_BANK_BRANCH_NAME_DSP_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_BANK_BRANCH_NAME_DSP;
  END C_BANK_BRANCH_NAME_DSP_P;

  FUNCTION C_BANK_CURRENCY_CODE_DSP_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_BANK_CURRENCY_CODE_DSP;
  END C_BANK_CURRENCY_CODE_DSP_P;

  FUNCTION C_COMPANY_NAME_HEADER_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_COMPANY_NAME_HEADER;
  END C_COMPANY_NAME_HEADER_P;

  FUNCTION C_BASE_CURRENCY_CODE_DSP_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_BASE_CURRENCY_CODE_DSP;
  END C_BASE_CURRENCY_CODE_DSP_P;

  FUNCTION C_BANK_ACCOUNT_NUM_DSP_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_BANK_ACCOUNT_NUM_DSP;
  END C_BANK_ACCOUNT_NUM_DSP_P;

END CE_CEJEEXER_XMLP_PKG;


/