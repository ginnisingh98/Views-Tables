--------------------------------------------------------
--  DDL for Package Body JA_JAINBBR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JA_JAINBBR_XMLP_PKG" AS
/* $Header: JAINBBRB.pls 120.1 2007/12/25 16:13:44 dwkrishn noship $ */
  FUNCTION CF_CLOSING_BALANCEFORMULA(CF_CLOSING_BALANCE IN NUMBER
                                    ,CF_OPEN_BALANCE IN NUMBER
                                    ,RECEIPTS IN VARCHAR2
                                    ,PAYMENTS IN VARCHAR2) RETURN NUMBER IS
  BEGIN
    RETURN (NVL(CF_CLOSING_BALANCE
              ,CF_OPEN_BALANCE) + RECEIPTS - PAYMENTS);
  END CF_CLOSING_BALANCEFORMULA;

  FUNCTION CF_BALANCEFORMULA(RECEIPTS IN VARCHAR2
                            ,PAYMENTS IN VARCHAR2) RETURN NUMBER IS
  BEGIN
    RETURN (NVL(RECEIPTS
              ,0) - NVL(PAYMENTS
              ,0));
  END CF_BALANCEFORMULA;

  FUNCTION CF_ACCOUNT_CODEFORMULA(ACCOUNT_CODE IN NUMBER) RETURN VARCHAR2 IS
    V_ACCOUNT VARCHAR2(1000);
  BEGIN
    JAI_CMN_GL_PKG.GET_ACCOUNT_NUMBER(P_CHART_OF_ACCTS_ID
                                     ,ACCOUNT_CODE
                                     ,V_ACCOUNT);
    RETURN (V_ACCOUNT);
  END CF_ACCOUNT_CODEFORMULA;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
    CURSOR C_PROGRAM_ID(P_REQUEST_ID IN NUMBER) IS
      SELECT
        CONCURRENT_PROGRAM_ID,
        NVL(ENABLE_TRACE
           ,'N')
      FROM
        FND_CONCURRENT_REQUESTS
      WHERE REQUEST_ID = P_REQUEST_ID;
    V_ENABLE_TRACE FND_CONCURRENT_PROGRAMS.ENABLE_TRACE%TYPE;
    V_PROGRAM_ID FND_CONCURRENT_PROGRAMS.CONCURRENT_PROGRAM_ID%TYPE;
  BEGIN
    /*SRW.MESSAGE(1275
               ,'Report Version -> 115.2, Last Updated Date -> 17/11/2004')*/NULL;
    BEGIN
      OPEN C_PROGRAM_ID(P_CONC_REQUEST_ID);
      FETCH C_PROGRAM_ID
       INTO V_PROGRAM_ID,V_ENABLE_TRACE;
      CLOSE C_PROGRAM_ID;
      /*SRW.MESSAGE(1275
                 ,'v_program_id -> ' || V_PROGRAM_ID || ', v_enable_trace -> ' || V_ENABLE_TRACE || ', request_id -> ' || P_CONC_REQUEST_ID)*/NULL;
      IF V_ENABLE_TRACE = 'Y' THEN
        EXECUTE IMMEDIATE
          'ALTER SESSION SET EVENTS ''10046 trace name context forever, level 4''';
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        /*SRW.MESSAGE(1275
                   ,'Error during enabling the trace. ErrCode -> ' || SQLCODE || ', ErrMesg -> ' || SQLERRM)*/NULL;
    END;
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    LP_SET_OF_BOOKS_ID := FND_PROFILE.VALUE('GL_SET_OF_BKS_ID');
    IF P_BOOK_TYPE = 'C' THEN
      P_DUMMY := 'Cash';
    ELSE
      P_DUMMY := 'Bank';
    END IF;
    LP_START_DATE:=to_char(P_START_DATE,'DD-MON-YYYY');
    LP_END_DATE:=to_char(P_END_DATE,'DD-MON-YYYY');
    LP1_START_DATE:=to_char(P_START_DATE,'DD-MON-YYYY HH24:MI:SS');
    LP1_END_DATE:=to_char(P_END_DATE,'DD-MON-YYYY HH24:MI:SS');

    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION CF_1FORMULA RETURN VARCHAR2 IS
    CURSOR FOR_SOB_ID(COA_ID IN NUMBER) IS
      SELECT
        SET_OF_BOOKS_ID
      FROM
        ORG_ORGANIZATION_DEFINITIONS
      WHERE CHART_OF_ACCOUNTS_ID = COA_ID;
    CURSOR FOR_SOB_NAME(SOB_ID IN NUMBER) IS
      SELECT
        NAME
      FROM
        GL_SETS_OF_BOOKS
      WHERE SET_OF_BOOKS_ID = SOB_ID;
    V_SET_OF_BOOKS_ID NUMBER;
    V_SOB_NAME VARCHAR2(100);
  BEGIN
    OPEN FOR_SOB_ID(P_CHART_OF_ACCTS_ID);
    FETCH FOR_SOB_ID
     INTO V_SET_OF_BOOKS_ID;
    CLOSE FOR_SOB_ID;
    OPEN FOR_SOB_NAME(V_SET_OF_BOOKS_ID);
    FETCH FOR_SOB_NAME
     INTO V_SOB_NAME;
    CLOSE FOR_SOB_NAME;
    RETURN (V_SOB_NAME);
  END CF_1FORMULA;

  FUNCTION CF_ACCT_DESCFORMULA (account_code IN NUMBER) RETURN VARCHAR2 IS
    CURSOR GET_APP_COLUMN_NAME(CP_ID_FLEX_CODE IN FND_SEGMENT_ATTRIBUTE_VALUES.ID_FLEX_CODE%TYPE,CP_SEG_ATT_TYPE IN FND_SEGMENT_ATTRIBUTE_VALUES.SEGMENT_ATTRIBUTE_TYPE%TYPE) IS
      SELECT
        DISTINCT
        APPLICATION_COLUMN_NAME
      FROM
        FND_SEGMENT_ATTRIBUTE_VALUES
      WHERE APPLICATION_ID = 101
        AND ID_FLEX_CODE = CP_ID_FLEX_CODE
        AND ID_FLEX_NUM = P_CHART_OF_ACCTS_ID
        AND SEGMENT_ATTRIBUTE_TYPE = CP_SEG_ATT_TYPE
        AND ATTRIBUTE_VALUE = 'Y';
    CURSOR FLEX_VAL_SET_ID(V_COLUMN_NAME IN VARCHAR2,CP_ID_FLEX_CODE IN FND_SEGMENT_ATTRIBUTE_VALUES.ID_FLEX_CODE%TYPE) IS
      SELECT
        A.FLEX_VALUE_SET_ID
      FROM
        FND_ID_FLEX_SEGMENTS A
      WHERE A.APPLICATION_COLUMN_NAME = V_COLUMN_NAME
        AND A.APPLICATION_ID = 101
        AND A.ID_FLEX_CODE = CP_ID_FLEX_CODE
        AND A.ID_FLEX_NUM = P_CHART_OF_ACCTS_ID;
    V_COLUMN_NAME VARCHAR2(30);
    V_COLUMN_VALUE VARCHAR2(30);
    V_FLEX_ID NUMBER;
    V_DESCRIPTION VARCHAR2(100);
    CURSOR GET_DESCRIPTION IS
      SELECT
        SUBSTR(DESCRIPTION
              ,1
              ,50)
      FROM
        FND_FLEX_VALUES_VL
      WHERE FLEX_VALUE_SET_ID = V_FLEX_ID
        AND FLEX_VALUE = V_COLUMN_VALUE;
  BEGIN
    OPEN GET_APP_COLUMN_NAME('GL#','GL_ACCOUNT');
    FETCH GET_APP_COLUMN_NAME
     INTO V_COLUMN_NAME;
    CLOSE GET_APP_COLUMN_NAME;
    IF V_COLUMN_NAME IS NULL THEN
      V_COLUMN_NAME := 'SEGMENT3';
    END IF;
    OPEN FLEX_VAL_SET_ID(V_COLUMN_NAME,'GL#');
    FETCH FLEX_VAL_SET_ID
     INTO V_FLEX_ID;
    CLOSE FLEX_VAL_SET_ID;
    /*EXECUTE IMMEDIATE
      'select ' || V_COLUMN_NAME || ' into :p_column_value from gl_code_combinations
      		where chart_of_accounts_id = :P_CHART_OF_ACCTS_ID AND code_combination_id = :account_code';*/
    EXECUTE IMMEDIATE
      'select ' || V_COLUMN_NAME || ' from gl_code_combinations
      		where chart_of_accounts_id = :P_CHART_OF_ACCTS_ID AND code_combination_id = :account_code'
	        INTO p_column_value
		USING P_CHART_OF_ACCTS_ID,account_code  ;
    V_COLUMN_VALUE := P_COLUMN_VALUE;
    OPEN GET_DESCRIPTION;
    FETCH GET_DESCRIPTION
     INTO V_DESCRIPTION;
    CLOSE GET_DESCRIPTION;
    RETURN (V_DESCRIPTION);
  END CF_ACCT_DESCFORMULA;

  FUNCTION CF_P_BOOKFORMULA RETURN VARCHAR2 IS
    V_BOOK_TYPE VARCHAR2(20);
  BEGIN
    IF P_BOOK_TYPE = 'B' THEN
      V_BOOK_TYPE := 'Bank Book';
    ELSE
      V_BOOK_TYPE := 'Cash Book';
    END IF;
    RETURN (V_BOOK_TYPE);
  END CF_P_BOOKFORMULA;

  FUNCTION JA_IN_CAL_BAL(P_BASE_DATE IN DATE
                        ,P_BALANCE_TYPE IN VARCHAR2
                        ,P_OPEN_CLOSE IN VARCHAR2) RETURN NUMBER IS
    V_BASE_DATE DATE;
    V_AMOUNT1 NUMBER;
    V_AMOUNT2 NUMBER;
    V_AMOUNT3 NUMBER;
    V_BALANCE NUMBER;
    V_SET_OF_BOOKS_ID NUMBER;
    LV_PAY_SOURCE GL_JE_HEADERS.JE_SOURCE%TYPE;
    LV_RCV_SOURCE GL_JE_HEADERS.JE_SOURCE%TYPE;
    LV_PAY_SOURCE1 GL_JE_HEADERS.JE_SOURCE%TYPE;
    LV_RCV_SOURCE1 GL_JE_HEADERS.JE_SOURCE%TYPE;
    LV_CLEAR_STATUS AR_CASH_RECEIPT_HISTORY_ALL.STATUS%TYPE;
    LV_REMIT_STATUS AR_CASH_RECEIPT_HISTORY_ALL.STATUS%TYPE;
    LV_CONFIRM_STATUS AR_CASH_RECEIPT_HISTORY_ALL.STATUS%TYPE;
    LV_REV_STATUS AR_CASH_RECEIPT_HISTORY_ALL.STATUS%TYPE;
    LV_NEGOT_LOOKUP AP_CHECKS_ALL.STATUS_LOOKUP_CODE%TYPE;
    LV_CLEAR_LOOKUP AP_CHECKS_ALL.STATUS_LOOKUP_CODE%TYPE;
    LV_VOIDED_LOOKUP AP_CHECKS_ALL.STATUS_LOOKUP_CODE%TYPE;
    LV_REC_UNACC_LOOKUP AP_CHECKS_ALL.STATUS_LOOKUP_CODE%TYPE;
    LV_REC_LOOKUP AP_CHECKS_ALL.STATUS_LOOKUP_CODE%TYPE;
    LV_CLEAR_UNACC_LOOKUP AP_CHECKS_ALL.STATUS_LOOKUP_CODE%TYPE;
  BEGIN
    LV_PAY_SOURCE := 'Payables India';
    LV_RCV_SOURCE := 'Receivables India';
    LV_PAY_SOURCE1 := 'Payables';
    LV_RCV_SOURCE1 := 'Receivables';
    LV_CLEAR_STATUS := 'CLEARED';
    LV_REMIT_STATUS := 'REMITTED';
    LV_CONFIRM_STATUS := 'CONFIRMED';
    LV_REV_STATUS := 'REVERSED';
    LV_NEGOT_LOOKUP := 'NEGOTIABLE';
    LV_CLEAR_LOOKUP := 'CLEARED';
    LV_VOIDED_LOOKUP := 'VOIDED';
    LV_REC_UNACC_LOOKUP := 'RECONCILED UNACCOUNTED';
    LV_REC_LOOKUP := 'RECONCILED';
    LV_CLEAR_UNACC_LOOKUP := 'CLEARED BUT UNACCOUNTED';
    IF P_OPEN_CLOSE = 'OP' THEN
      V_BASE_DATE := P_BASE_DATE;
    END IF;
    SELECT
      DECODE(P_BALANCE_TYPE
            ,'CR'
            ,SUM(ACCOUNTED_DR)
            ,'DR'
            ,SUM(ACCOUNTED_CR)
            ,0)
    INTO V_AMOUNT2
    FROM
      GL_JE_HEADERS GLH,
      GL_JE_LINES GLL,
      CE_BANK_ACCOUNTS CBA
    WHERE GLH.JE_HEADER_ID = GLL.JE_HEADER_ID
      AND GLH.LEDGER_ID = GLL.LEDGER_ID
      AND GLL.LEDGER_ID = LP_SET_OF_BOOKS_ID
      AND CBA.ASSET_CODE_COMBINATION_ID = GLL.CODE_COMBINATION_ID
      AND CBA.BANK_ACCOUNT_ID = P_BANK_ACCOUNT_ID
      AND GLH.JE_SOURCE NOT IN ( LV_PAY_SOURCE , LV_RCV_SOURCE , LV_PAY_SOURCE1 , LV_RCV_SOURCE1 )
      AND GLH.DEFAULT_EFFECTIVE_DATE < V_BASE_DATE
      AND ( CBA.ACCOUNT_OWNER_ORG_ID IS NULL
    OR CBA.ACCOUNT_OWNER_ORG_ID = P_ORG_ID );
    IF P_BALANCE_TYPE = 'CR' THEN
      SELECT
        SUM(DECODE(ACRH.STATUS
                  ,'REVERSED'
                  ,(ACRH.AMOUNT * NVL(ACRH.EXCHANGE_RATE
                     ,1)) * -1
                  ,NVL(ACRH.AMOUNT
                     ,0) * NVL(ACRH.EXCHANGE_RATE
                     ,1)))
      INTO V_AMOUNT1
      FROM
        AR_CASH_RECEIPT_HISTORY_ALL ACRH,
        AR_CASH_RECEIPTS_ALL ACR,
        HZ_PARTIES HP,
        HZ_CUST_ACCOUNTS HCA,
        CE_BANK_ACCOUNTS CBA
      WHERE ACRH.CASH_RECEIPT_ID = ACR.CASH_RECEIPT_ID
        AND ACR.REMITTANCE_BANK_ACCOUNT_ID = CBA.BANK_ACCOUNT_ID
        AND HCA.PARTY_ID = hp.party_id (+)
        AND ACR.PAY_FROM_CUSTOMER = hca.cust_account_id (+)
        AND ACRH.STATUS IN ( LV_CLEAR_STATUS , LV_REMIT_STATUS , LV_CONFIRM_STATUS , LV_REV_STATUS )
        AND ( ( ACRH.STATUS = LV_REV_STATUS
        AND ACR.REVERSAL_DATE is not null )
      OR ( ACRH.CASH_RECEIPT_HISTORY_ID IN (
        SELECT
          MIN(INCRH.CASH_RECEIPT_HISTORY_ID)
        FROM
          AR_CASH_RECEIPT_HISTORY_ALL INCRH
        WHERE INCRH.CASH_RECEIPT_ID = ACR.CASH_RECEIPT_ID
          AND INCRH.STATUS <> LV_REV_STATUS ) ) )
        AND CBA.BANK_ACCOUNT_ID = P_BANK_ACCOUNT_ID
        AND ACRH.GL_DATE < V_BASE_DATE
        AND ( ACR.ORG_ID IS NULL
      OR ACR.ORG_ID = P_ORG_ID );
      SELECT
        SUM(API.INVOICE_AMOUNT * NVL(API.EXCHANGE_RATE
               ,1))
      INTO V_AMOUNT3
      FROM
        AP_INVOICE_DISTRIBUTIONS_ALL APID,
        AP_INVOICE_LINES_ALL APLA,
        AP_INVOICES_ALL API,
        PO_VENDORS POV,
        CE_BANK_ACCOUNTS CBA
      WHERE API.INVOICE_ID = APID.INVOICE_ID
        AND APLA.INVOICE_ID = APID.INVOICE_ID
        AND APLA.LINE_NUMBER = APID.INVOICE_LINE_NUMBER
        AND API.VENDOR_ID = POV.VENDOR_ID
        AND CBA.BANK_ACCOUNT_ID = P_BANK_ACCOUNT_ID
        AND CBA.ASSET_CODE_COMBINATION_ID = APID.DIST_CODE_COMBINATION_ID
        AND APID.MATCH_STATUS_FLAG = 'A'
        AND APID.ACCOUNTING_DATE < V_BASE_DATE
        AND ( CBA.ACCOUNT_OWNER_ORG_ID IS NULL
      OR CBA.ACCOUNT_OWNER_ORG_ID = P_ORG_ID );
      V_BALANCE := NVL(V_AMOUNT1
                      ,0) + NVL(V_AMOUNT2
                      ,0) + NVL(V_AMOUNT3
                      ,0);
    ELSIF P_BALANCE_TYPE = 'DR' THEN
      SELECT
        SUM(NVL(AIP.AMOUNT
               ,0) * NVL(AIP.EXCHANGE_RATE
               ,1))
      INTO V_AMOUNT1
      FROM
        AP_INVOICE_PAYMENTS_ALL AIP,
        AP_CHECKS_ALL APC,
        CE_BANK_ACCOUNTS CBA
      WHERE AIP.CHECK_ID = APC.CHECK_ID
        AND APC.BANK_ACCOUNT_ID = CBA.BANK_ACCOUNT_ID
        AND APC.STATUS_LOOKUP_CODE IN ( LV_NEGOT_LOOKUP , LV_CLEAR_LOOKUP , LV_VOIDED_LOOKUP , LV_REC_UNACC_LOOKUP , LV_REC_LOOKUP , LV_CLEAR_UNACC_LOOKUP )
        AND CBA.BANK_ACCOUNT_ID = P_BANK_ACCOUNT_ID
        AND AIP.ACCOUNTING_DATE < V_BASE_DATE
        AND ( CBA.ACCOUNT_OWNER_ORG_ID IS NULL
      OR CBA.ACCOUNT_OWNER_ORG_ID = P_ORG_ID );
      V_BALANCE := NVL(V_AMOUNT1
                      ,0) + NVL(V_AMOUNT2
                      ,0);
    END IF;
    RETURN V_BALANCE;
  END JA_IN_CAL_BAL;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION CF_OPEN_BAL_DRFORMULA RETURN NUMBER IS
    AMT NUMBER;
    AMT1 NUMBER;
  BEGIN
    RETURN (JA_IN_CAL_BAL(P_START_DATE
                        ,'DR'
                        ,'OP'));
  END CF_OPEN_BAL_DRFORMULA;

  FUNCTION CF_OPEN_BAL_CRFORMULA RETURN NUMBER IS
    AMT NUMBER;
    AMT1 NUMBER;
  BEGIN
    RETURN (JA_IN_CAL_BAL(P_START_DATE
                        ,'CR'
                        ,'OP'));
  END CF_OPEN_BAL_CRFORMULA;

  FUNCTION CF_OPEN_BALANCEFORMULA(CF_OPEN_BAL_CR IN NUMBER
                                 ,CF_OPEN_BAL_DR IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (NVL(CF_OPEN_BAL_CR
              ,0) - NVL(CF_OPEN_BAL_DR
              ,0));
  END CF_OPEN_BALANCEFORMULA;

END JA_JAINBBR_XMLP_PKG;


/
