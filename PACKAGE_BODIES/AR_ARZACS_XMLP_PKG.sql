--------------------------------------------------------
--  DDL for Package Body AR_ARZACS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_ARZACS_XMLP_PKG" AS
/* $Header: ARZACSB.pls 120.0 2007/12/27 14:12:53 abraghun noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    CHECK_GL_DATE;
    GET_SET_OF_BOOKS;
    GET_PAYMENT_METHOD;
    GET_REMITTANCE_BANK_ACCOUNT;
    GET_BATCH_DETAILS;
    GET_MAX_CHR;
    POPULATE_YES_FIELD;
    POPULATE_NO_FIELD;
    POPULATE_VARIOUS_YES_NO_FIELDS;
    IF P_BR_REPORT <> 'Y' THEN
      CHECK_AUTOMATIC_CLEARING;
    ELSE
      BR_POPUL_VARIOUS_YES_NO_FIELDS;
      BR_HOUSEKEEPER_PROGRAM;
    END IF;
    LP_GL_DATE:=to_char(P_GL_DATE,'DD-MON-YYYY');
    LP_CLEAR_DATE:=to_char(P_CLEAR_DATE,'DD-MON-YYYY');

    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION BEFOREPFORM RETURN BOOLEAN IS
  BEGIN
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    RETURN (TRUE);
  END BEFOREPFORM;

  FUNCTION CF_TRANS_TYPEFORMULA RETURN CHAR IS
    OUT_TRANS_TYPE_NAME VARCHAR2(20);
  BEGIN
    IF P_BR_REPORT <> 'Y' THEN
      RETURN ' ';
    END IF;
    OUT_TRANS_TYPE_NAME := ' ';
    IF P_BR_TRANSACTION_TYPE IS NOT NULL THEN
      SELECT
        NAME
      INTO OUT_TRANS_TYPE_NAME
      FROM
        RA_CUST_TRX_TYPES
      WHERE CUST_TRX_TYPE_ID = P_BR_TRANSACTION_TYPE;
    END IF;
    RETURN OUT_TRANS_TYPE_NAME;
  END CF_TRANS_TYPEFORMULA;

  FUNCTION CF_BR_DATE_DISPFORMULA(BR_DATE IN DATE) RETURN CHAR IS
  BEGIN
    RETURN (FND_DATE.DATE_TO_CHARDATE(BR_DATE));
  END CF_BR_DATE_DISPFORMULA;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    P_AUTO_CLEAR_RECEIPTS := NULL;
    IF P_BR_REPORT = 'Y' THEN
      P_AUTO_CLEAR_RECEIPTS := ' (crh.cash_receipt_id in ' || ' (select rap.cash_receipt_id from ' ||
      ' ar_transaction_history trh,ar_receivable_applications rap ' || ' where trh.request_id = :p_conc_request_id and ' ||
      ' trh.current_record_flag = ''Y''  and ' || ' rap.applied_customer_trx_id = trh.customer_trx_id) and ' || ' crh.current_record_flag =  ''Y'')
      and ';
    ELSE
      P_AUTO_CLEAR_RECEIPTS := ' crh.request_id = :p_conc_request_id and ';
    END IF;
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION C_REC1_P RETURN NUMBER IS
  BEGIN
    RETURN C_REC1;
  END C_REC1_P;

  FUNCTION FUNC_CURRENCY_CODE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN FUNC_CURRENCY_CODE;
  END FUNC_CURRENCY_CODE_P;

  FUNCTION COMPANY_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN COMPANY_NAME;
  END COMPANY_NAME_P;

  FUNCTION C_NLS_YES_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_NLS_YES;
  END C_NLS_YES_P;

  FUNCTION C_NLS_NO_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_NLS_NO;
  END C_NLS_NO_P;

  FUNCTION C_PAYMENT_METHOD_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_PAYMENT_METHOD_NAME;
  END C_PAYMENT_METHOD_NAME_P;

  FUNCTION C_REMITTANCE_BANK_ACC_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_REMITTANCE_BANK_ACC_NAME;
  END C_REMITTANCE_BANK_ACC_NAME_P;

  FUNCTION C_REMITTANCE_BATCH_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_REMITTANCE_BATCH_NAME;
  END C_REMITTANCE_BATCH_NAME_P;

  FUNCTION MAX_CRH_ID_P RETURN NUMBER IS
  BEGIN
    RETURN MAX_CRH_ID;
  END MAX_CRH_ID_P;

  PROCEDURE GET_SET_OF_BOOKS IS
  BEGIN
    /*SRW.MESSAGE(1000
               ,'DEBUG:  Before_Report_Procs.Get_Set_Of_Books.')*/NULL;
    SELECT
      SOB.NAME,
      SOB.CURRENCY_CODE
    INTO COMPANY_NAME,FUNC_CURRENCY_CODE
    FROM
      GL_SETS_OF_BOOKS SOB,
      AR_SYSTEM_PARAMETERS AR
    WHERE SOB.SET_OF_BOOKS_ID = AR.SET_OF_BOOKS_ID;
  EXCEPTION
    WHEN OTHERS THEN
      /*SRW.MESSAGE(5000
                 ,'DEBUG:  Get_Batch_Details.Get_Set_Of_Books.')*/NULL;
      RAISE;
  END GET_SET_OF_BOOKS;

  PROCEDURE GET_PAYMENT_METHOD IS
  BEGIN
    /*SRW.MESSAGE(1000
               ,'DEBUG:  Before_Report_Procs.Get_Payment_Method.')*/NULL;
    IF (P_PAYMENT_METHOD_ID IS NOT NULL) THEN
      SELECT
        NAME
      INTO C_PAYMENT_METHOD_NAME
      FROM
        AR_RECEIPT_METHODS
      WHERE RECEIPT_METHOD_ID = P_PAYMENT_METHOD_ID;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      /*SRW.MESSAGE(5000
                 ,'DEBUG:  Get_Payment_Method.Unable to retrieve Payment Method.')*/NULL;
      RAISE;
  END GET_PAYMENT_METHOD;

  PROCEDURE GET_REMITTANCE_BANK_ACCOUNT IS
  BEGIN
    /*SRW.MESSAGE(1000
               ,'DEBUG:  Before_Report_Procs.Get_Remittance_Bank_Account.')*/NULL;
    IF (P_REMITTANCE_BANK_ACCOUNT_ID IS NOT NULL) THEN
      SELECT
        BANK_ACCOUNT_NAME
      INTO C_REMITTANCE_BANK_ACC_NAME
      FROM
        CE_BANK_ACCOUNTS CBA,
        CE_BANK_ACCT_USES BA
      WHERE BANK_ACCT_USE_ID = P_REMITTANCE_BANK_ACCOUNT_ID
        AND CBA.BANK_ACCOUNT_ID = BA.BANK_ACCOUNT_ID;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      /*SRW.MESSAGE(5000
                 ,'DEBUG:  Get_Remittance_Bank_Account.Unable to retrieve Remittance Bank Account.')*/NULL;
      RAISE;
  END GET_REMITTANCE_BANK_ACCOUNT;

  PROCEDURE GET_BATCH_DETAILS IS
  BEGIN
    /*SRW.MESSAGE(1000
               ,'DEBUG:  Before_Report_Procs.Get_Batch_Details.')*/NULL;
    IF (P_BATCH_NAME IS NOT NULL) THEN
      SELECT
        NAME,
        BATCH_ID
      INTO C_REMITTANCE_BATCH_NAME,P_BATCH_ID
      FROM
        AR_BATCHES
      WHERE NAME = P_BATCH_NAME;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      /*SRW.MESSAGE(5000
                 ,'DEBUG:  Get_Batch_Details.Unable to retrieve Batch Details.')*/NULL;
      RAISE;
  END GET_BATCH_DETAILS;

  PROCEDURE GET_MAX_CHR IS
  BEGIN
    /*SRW.MESSAGE(1000
               ,'DEBUG:  Before_Report_Procs.Get_Max_CHR.')*/NULL;
    SELECT
      MAX(CRH.CASH_RECEIPT_HISTORY_ID)
    INTO MAX_CRH_ID
    FROM
      AR_CASH_RECEIPT_HISTORY CRH;
  EXCEPTION
    WHEN OTHERS THEN
      /*SRW.MESSAGE(5000
                 ,'DEBUG:  Get_Batch_Details.Get_Mac_CHR.')*/NULL;
      RAISE;
  END GET_MAX_CHR;

  PROCEDURE POPULATE_YES_FIELD IS
    NLS_YES FND_LOOKUPS.MEANING%TYPE;
  BEGIN
    /*SRW.MESSAGE(1000
               ,'DEBUG:  Before_Report_Procs.Populate_Yes_Field.')*/NULL;
    SELECT
      MEANING
    INTO NLS_YES
    FROM
      AR_LOOKUPS
    WHERE LOOKUP_TYPE = 'YES/NO'
      AND LOOKUP_CODE = 'Y';
    C_NLS_YES := NLS_YES;
  EXCEPTION
    WHEN OTHERS THEN
      /*SRW.MESSAGE(5000
                 ,'DEBUG:  Get_Batch_Details.Populate_Yes_Field.')*/NULL;
      RAISE;
  END POPULATE_YES_FIELD;

  PROCEDURE POPULATE_NO_FIELD IS
    NLS_NO FND_LOOKUPS.MEANING%TYPE;
  BEGIN
    /*SRW.MESSAGE(1000
               ,'DEBUG:  Before_Report_Procs.Populate_No_Field.')*/NULL;
    SELECT
      MEANING
    INTO NLS_NO
    FROM
      AR_LOOKUPS LN
    WHERE LOOKUP_TYPE = 'YES/NO'
      AND LN.LOOKUP_CODE = 'N';
    C_NLS_NO := NLS_NO;
  EXCEPTION
    WHEN OTHERS THEN
      /*SRW.MESSAGE(5000
                 ,'DEBUG:  Get_Batch_Details.Populate_No_Field.')*/NULL;
      RAISE;
  END POPULATE_NO_FIELD;

  PROCEDURE POPULATE_VARIOUS_YES_NO_FIELDS IS
  BEGIN
    /*SRW.MESSAGE(1000
               ,'DEBUG:  Before_Report_Procs.Populate_Various_Yes_No_Fields.')*/NULL;
    IF (P_CLR_REMITTED_RECEIPTS = 'Y') THEN
      P_NLS_CLR_REM_REC := C_NLS_YES;
    ELSE
      P_NLS_CLR_REM_REC := C_NLS_NO;
    END IF;
    IF (P_CLR_DISC_RECEIPTS = 'Y') THEN
      P_NLS_CLR_DISC_REC := C_NLS_YES;
    ELSE
      P_NLS_CLR_DISC_REC := C_NLS_NO;
    END IF;
    IF (P_ELIMINATE_BANK_RISK = 'Y') THEN
      P_NLS_ELI_BANK_RISK := C_NLS_YES;
    ELSE
      P_NLS_ELI_BANK_RISK := C_NLS_NO;
    END IF;
  END POPULATE_VARIOUS_YES_NO_FIELDS;

  PROCEDURE CHECK_AUTOMATIC_CLEARING IS
    CHECK_CLEARING BOOLEAN;
  BEGIN
    /*SRW.MESSAGE(1000
               ,'DEBUG:  Before_Report_Procs.check_automatic_clearing.')*/NULL;
    CHECK_CLEARING := ARP_AUTOMATIC_CLEARING_PKG.AR_AUTOMATIC_CLEARING(P_CLR_REMITTED_RECEIPTS
                                                                      ,P_CLR_DISC_RECEIPTS
                                                                      ,P_ELIMINATE_BANK_RISK
                                                                      ,P_CLEAR_DATE
                                                                      ,P_GL_DATE
                                                                      ,P_CUSTOMER_NAME_LOW
                                                                      ,P_CUSTOMER_NAME_HIGH
                                                                      ,P_CUSTOMER_NUMBER_LOW
                                                                      ,P_CUSTOMER_NUMBER_HIGH
                                                                      ,P_RECEIPT_NUMBER_LOW
                                                                      ,P_RECEIPT_NUMBER_HIGH
                                                                      ,P_REMITTANCE_BANK_ACCOUNT_ID
                                                                      ,P_PAYMENT_METHOD_ID
                                                                      ,P_EXCHANGE_RATE_TYPE
                                                                      ,P_BATCH_ID
                                                                      ,P_UNDO_CLEARING);
    IF (NOT CHECK_CLEARING) THEN
      /*SRW.MESSAGE(5000
                 ,'DEBUG:  Get_Batch_Details.Error in arp_automatic_clearing_pkg')*/NULL;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      /*SRW.MESSAGE(5000
                 ,'DEBUG:  Get_Batch_Details.Check_Automatic_Clearing.')*/NULL;
      RAISE;
  END CHECK_AUTOMATIC_CLEARING;

  PROCEDURE BR_POPUL_VARIOUS_YES_NO_FIELDS IS
  BEGIN
    /*SRW.MESSAGE(1000
               ,'DEBUG:  Before_Report_Procs.Br_Populate_Various_Yes_No_Fields.')*/NULL;
    IF (P_BR_INCLUDE_ENDORSED = 'Y') THEN
      P_NLS_BR_INCLUDE_ENDORSED := C_NLS_YES;
    ELSE
      P_NLS_BR_INCLUDE_ENDORSED := C_NLS_NO;
    END IF;
    IF (P_BR_INCLUDE_FACTORED = 'Y') THEN
      P_NLS_BR_INCLUDE_FACTORED := C_NLS_YES;
    ELSE
      P_NLS_BR_INCLUDE_FACTORED := C_NLS_NO;
    END IF;
    IF (P_BR_INCLUDE_REMITTED = 'Y') THEN
      P_NLS_BR_INCLUDE_REMITTED := C_NLS_YES;
    ELSE
      P_NLS_BR_INCLUDE_REMITTED := C_NLS_NO;
    END IF;
    IF (P_BR_REPORT = 'Y') THEN
      P_NLS_BR_REPORT := C_NLS_YES;
    ELSE
      P_NLS_BR_REPORT := C_NLS_NO;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      /*SRW.MESSAGE(5001
                 ,'DEBUG:  Br_Popul_Various_Yes_No_Fields')*/NULL;
      RAISE;
  END BR_POPUL_VARIOUS_YES_NO_FIELDS;

  PROCEDURE BR_HOUSEKEEPER_PROGRAM IS
    CHECK_HOUSEKEEPER BOOLEAN;
  BEGIN
    /*SRW.MESSAGE(8000
               ,'DEBUG:  Before_Report_Procs.BR_Housekeeper.')*/NULL;
    CHECK_HOUSEKEEPER := ARP_BR_HOUSEKEEPER_PKG.AR_BR_HOUSEKEEPER(P_BR_EFFECTIVE_DATE
                                                                 ,P_GL_DATE
                                                                 ,P_BR_MATURITY_DATE_FROM
                                                                 ,P_BR_MATURITY_DATE_TO
                                                                 ,P_BR_GL_DATE_FROM
                                                                 ,P_BR_GL_DATE_TO
                                                                 ,P_BR_TRANSACTION_TYPE
                                                                 ,P_BR_INCLUDE_FACTORED
                                                                 ,P_BR_INCLUDE_REMITTED
                                                                 ,P_BR_INCLUDE_ENDORSED);
    IF (NOT CHECK_HOUSEKEEPER) THEN
      /*SRW.MESSAGE(8100
                 ,'DEBUG:  Check Housekeeper.')*/NULL;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      /*SRW.MESSAGE(8200
                 ,'DEBUG:  Check Housekeeper - others.')*/NULL;
      RAISE;
  END BR_HOUSEKEEPER_PROGRAM;

  PROCEDURE CHECK_GL_DATE IS
    OPEN_PERIODS NUMBER;
    NOT_OPEN EXCEPTION;
  BEGIN
    /*SRW.MESSAGE(1000
               ,'DEBUG:  Before_Report_Procs.Check_GL_Date.')*/NULL;
    SELECT
      count(*)
    INTO OPEN_PERIODS
    FROM
      GL_PERIOD_STATUSES GPS,
      AR_SYSTEM_PARAMETERS ASP
    WHERE GPS.SET_OF_BOOKS_ID = ASP.SET_OF_BOOKS_ID
      AND GPS.APPLICATION_ID = 222
      AND GPS.ADJUSTMENT_PERIOD_FLAG = 'N'
      AND P_GL_DATE BETWEEN GPS.START_DATE
      AND GPS.END_DATE
      AND GPS.CLOSING_STATUS in ( 'O' , 'F' );
    IF (OPEN_PERIODS = 0) THEN
      RAISE NOT_OPEN;
    END IF;
  EXCEPTION
    WHEN NOT_OPEN THEN
      /*SRW.MESSAGE(5000
                 ,'DEBUG:  GL_Date not within open period.')*/NULL;
      RAISE;
    WHEN OTHERS THEN
      /*SRW.MESSAGE(5000
                 ,'DEBUG:  Get_Batch_Details.Check_GL_Date.')*/NULL;
      RAISE;
  END CHECK_GL_DATE;

END AR_ARZACS_XMLP_PKG;


/
