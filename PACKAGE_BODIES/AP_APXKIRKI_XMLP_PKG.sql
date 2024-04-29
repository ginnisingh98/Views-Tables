--------------------------------------------------------
--  DDL for Package Body AP_APXKIRKI_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_APXKIRKI_XMLP_PKG" AS
/* $Header: APXKIRKIB.pls 120.0 2007/12/27 08:09:12 vjaganat noship $ */
  FUNCTION GET_BASE_CURR_DATA RETURN BOOLEAN IS
    BASE_CURR AP_SYSTEM_PARAMETERS.BASE_CURRENCY_CODE%TYPE;
    PREC FND_CURRENCIES_VL.PRECISION%TYPE;
    MIN_AU FND_CURRENCIES_VL.MINIMUM_ACCOUNTABLE_UNIT%TYPE;
    DESCR FND_CURRENCIES_VL.DESCRIPTION%TYPE;
    ORG_ID AP_SYSTEM_PARAMETERS.ORG_ID%TYPE;
  BEGIN
    BASE_CURR := '';
    PREC := 0;
    MIN_AU := 0;
    DESCR := '';
    SELECT
      P.BASE_CURRENCY_CODE,
      C.PRECISION,
      C.MINIMUM_ACCOUNTABLE_UNIT,
      C.DESCRIPTION,
      P.ORG_ID
    INTO BASE_CURR,PREC,MIN_AU,DESCR,ORG_ID
    FROM
      AP_SYSTEM_PARAMETERS P,
      FND_CURRENCIES_VL C
    WHERE P.BASE_CURRENCY_CODE = C.CURRENCY_CODE;
    C_BASE_CURRENCY_CODE := BASE_CURR;
    C_BASE_PRECISION := PREC;
    C_BASE_MIN_ACCT_UNIT := MIN_AU;
    C_BASE_DESCRIPTION := DESCR;
    C_ORG_ID := ORG_ID;
    IF P_MIN_PRECISION = 0 THEN
      P_MIN_PRECISION := PREC;
    END IF;
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END GET_BASE_CURR_DATA;

  FUNCTION CUSTOM_INIT RETURN BOOLEAN IS
  BEGIN
    /*SRW.MESSAGE('1001'
               ,'period_data: Getting period information...')*/NULL;
    IF (PERIOD_DATA <> TRUE) THEN
      RETURN (FALSE);
    END IF;
    /*SRW.REFERENCE(C_PERIOD_TYPE)*/NULL;
    IF C_PERIOD_TYPE IS NULL THEN
      RETURN (TRUE);
    END IF;
    /*SRW.MESSAGE('1002'
               ,'all_period: Getting data prior to requested period...')*/NULL;
    IF (ALL_PERIOD <> TRUE) THEN
      RETURN (FALSE);
    END IF;
    /*SRW.MESSAGE('1003'
               ,'matching_holds: Getting matching hold data...')*/NULL;
    IF (MATCHING_HOLDS <> TRUE) THEN
      RETURN (FALSE);
    END IF;
    /*SRW.MESSAGE('1004'
               ,'invoice_data: Getting invoice data...')*/NULL;
    IF (INVOICE_DATA <> TRUE) THEN
      RETURN (FALSE);
    END IF;
    /*SRW.MESSAGE('1005'
               ,'variance_data: Getting invoice variance data...')*/NULL;
    IF (VARIANCE_DATA <> TRUE) THEN
      RETURN (FALSE);
    END IF;
    IF C_STATUS = 'N' THEN
      UPDATE
        AP_OTHER_PERIODS
      SET
        STATUS = 'S'
      WHERE PERIOD_NAME = P_PERIOD_NAME
        AND MODULE = C_MODULE;
      COMMIT;
    END IF;
    /*SRW.MESSAGE('1006'
               ,'current_period: Getting data for requested period...')*/NULL;
    IF (CURRENT_PERIOD <> TRUE) THEN
      RETURN (FALSE);
    END IF;
    IF C_STATUS = 'N' THEN
      /*SRW.MESSAGE('1007'
                 ,'insert_key_ind: Inserting into key_ind tables...')*/NULL;
      IF (INSERT_KEY_IND <> TRUE) THEN
        RETURN (FALSE);
      END IF;
    ELSE
      /*SRW.MESSAGE('1008'
                 ,'update_key_ind: Updating key_ind tables...')*/NULL;
      IF (UPDATE_KEY_IND <> TRUE) THEN
        RETURN (FALSE);
      END IF;
    END IF;
    UPDATE
      AP_OTHER_PERIODS
    SET
      STATUS = 'C'
    WHERE PERIOD_NAME = P_PERIOD_NAME
      AND MODULE = C_MODULE;
    /*SRW.MESSAGE('1009'
               ,'prior_period: Getting prior period data...')*/NULL;
    IF (PRIOR_PERIOD <> TRUE) THEN
      RETURN (FALSE);
    END IF;
    /*SRW.MESSAGE('1010'
               ,'calculate_statistics: Calculating statistics...')*/NULL;
    IF (CALCULATE_STATISTICS <> TRUE) THEN
      RETURN (FALSE);
    END IF;
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END CUSTOM_INIT;

  FUNCTION GET_COVER_PAGE_VALUES RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END GET_COVER_PAGE_VALUES;

  FUNCTION GET_NLS_STRINGS RETURN BOOLEAN IS
    NLS_ALL AP_LOOKUP_CODES.DISPLAYED_FIELD%TYPE;
    NLS_NA AP_LOOKUP_CODES.DISPLAYED_FIELD%TYPE;
    NLS_YES FND_LOOKUPS.MEANING%TYPE;
    NLS_NO FND_LOOKUPS.MEANING%TYPE;
  BEGIN
    NLS_ALL := '';
    NLS_YES := '';
    NLS_NO := '';
    NLS_NA := '';
    SELECT
      LY.MEANING,
      LN.MEANING,
      LA.DISPLAYED_FIELD,
      LNA.DISPLAYED_FIELD
    INTO NLS_YES,NLS_NO,NLS_ALL,NLS_NA
    FROM
      FND_LOOKUPS LY,
      FND_LOOKUPS LN,
      AP_LOOKUP_CODES LA,
      AP_LOOKUP_CODES LNA
    WHERE LY.LOOKUP_TYPE = 'YES_NO'
      AND LY.LOOKUP_CODE = 'Y'
      AND LN.LOOKUP_TYPE = 'YES_NO'
      AND LN.LOOKUP_CODE = 'N'
      AND LA.LOOKUP_TYPE = 'NLS REPORT PARAMETER'
      AND LA.LOOKUP_CODE = 'ALL'
      AND LNA.LOOKUP_TYPE = 'NLS REPORT PARAMETER'
      AND LNA.LOOKUP_CODE = 'NA';
    C_NLS_YES := NLS_YES;
    C_NLS_NO := NLS_NO;
    C_NLS_ALL := NLS_ALL;
    C_NLS_NA := NLS_NA;
    FND_MESSAGE.SET_NAME('SQLAP'
                        ,'AP_APPRVL_NO_DATA');
    C_NLS_NO_DATA_EXISTS := FND_MESSAGE.GET;
    C_NLS_NO_DATA_EXISTS := C_NLS_NO_DATA_EXISTS;
    FND_MESSAGE.SET_NAME('SQLAP'
                        ,'AP_ALL_END_OF_REPORT');
    C_NLS_END_OF_REPORT := FND_MESSAGE.GET;
    C_NLS_END_OF_REPORT := C_NLS_END_OF_REPORT ;
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END GET_NLS_STRINGS;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    DECLARE
      INIT_FAILURE EXCEPTION;
    BEGIN
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
      IF (P_DEBUG_SWITCH = 'Y') THEN
        /*SRW.MESSAGE('1'
                   ,'After SRWINIT')*/NULL;
      END IF;
      IF (GET_PERIOD_NAME_FROM_ROWID <> TRUE) THEN
        RAISE INIT_FAILURE;
      END IF;
      IF (P_DEBUG_SWITCH = 'Y') THEN
        /*SRW.MESSAGE('2'
                   ,'After Get_Period_Name')*/NULL;
      END IF;
      IF (GET_COMPANY_NAME <> TRUE) THEN
        RAISE INIT_FAILURE;
      END IF;
      IF (P_DEBUG_SWITCH = 'Y') THEN
        /*SRW.MESSAGE('3'
                   ,'After Get_Company_Name')*/NULL;
      END IF;
      IF (GET_NLS_STRINGS <> TRUE) THEN
        RAISE INIT_FAILURE;
      END IF;
      IF (P_DEBUG_SWITCH = 'Y') THEN
        /*SRW.MESSAGE('4'
                   ,'After Get_NLS_Strings')*/NULL;
      END IF;
      IF (GET_BASE_CURR_DATA <> TRUE) THEN
        RAISE INIT_FAILURE;
      END IF;
      IF (P_DEBUG_SWITCH = 'Y') THEN
        /*SRW.MESSAGE('5'
                   ,'After Get_Base_Curr_Data')*/NULL;
      END IF;
      IF (GET_WHERE_CONDITIONS <> TRUE) THEN
        RAISE INIT_FAILURE;
      END IF;
      IF (P_DEBUG_SWITCH = 'Y') THEN
        /*SRW.MESSAGE('8'
                   ,'After Get_Where_Conditions')*/NULL;
      END IF;
      IF (GET_SYSTEM_USER_NAME <> TRUE) THEN
        RAISE INIT_FAILURE;
      END IF;
      IF (P_DEBUG_SWITCH = 'Y') THEN
        /*SRW.MESSAGE('9'
                   ,'After Get_System_User_Name')*/NULL;
      END IF;
      IF (CUSTOM_INIT <> TRUE) THEN
        RAISE INIT_FAILURE;
      END IF;
      IF (P_DEBUG_SWITCH = 'Y') THEN
        /*SRW.MESSAGE('10'
                   ,'After Custom_Init')*/NULL;
      END IF;
      IF (P_DEBUG_SWITCH = 'Y') THEN
        /*SRW.BREAK*/NULL;
      END IF;
      RETURN (TRUE);
    EXCEPTION
      WHEN OTHERS THEN
        /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
    END;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
      IF (P_DEBUG_SWITCH = 'Y') THEN
        /*SRW.MESSAGE('20'
                   ,'After SRWEXIT')*/NULL;
        UPDATE
          AP_OTHER_PERIODS
        SET
          STATUS = 'Y'
        WHERE PERIOD_NAME = P_PERIOD_NAME
          AND PERIOD_TYPE = C_PERIOD_TYPE
          AND MODULE = 'KEY INDICATORS'
          AND APPLICATION_ID = 200;
        COMMIT;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
    END;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION GET_COMPANY_NAME RETURN BOOLEAN IS
    L_CHART_OF_ACCOUNTS_ID GL_SETS_OF_BOOKS.CHART_OF_ACCOUNTS_ID%TYPE;
    L_NAME GL_SETS_OF_BOOKS.NAME%TYPE;
    L_SOB_ID NUMBER;
    L_REPORT_START_DATE DATE;
  BEGIN
    L_REPORT_START_DATE := SYSDATE;
    L_SOB_ID := P_SET_OF_BOOKS_ID;
    SELECT
      NAME,
      CHART_OF_ACCOUNTS_ID
    INTO L_NAME,L_CHART_OF_ACCOUNTS_ID
    FROM
      GL_SETS_OF_BOOKS
    WHERE SET_OF_BOOKS_ID = L_SOB_ID;
    C_COMPANY_NAME_HEADER := L_NAME;
    C_CHART_OF_ACCOUNTS_ID := L_CHART_OF_ACCOUNTS_ID;
    C_REPORT_START_DATE := L_REPORT_START_DATE;
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END GET_COMPANY_NAME;

  FUNCTION CALCULATE_RUN_TIME RETURN BOOLEAN IS
    END_DATE DATE;
    START_DATE DATE;
  BEGIN
    END_DATE := SYSDATE;
    START_DATE := C_REPORT_START_DATE;
    C_REPORT_RUN_TIME := TO_CHAR(TO_DATE('01/01/0001'
                                        ,'DD/MM/YYYY') + ((END_DATE - START_DATE))
                                ,'HH24:MI:SS');
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
  END CALCULATE_RUN_TIME;

  FUNCTION PERIOD_DATA RETURN BOOLEAN IS
    L_PERIOD_YEAR AP_OTHER_PERIODS.PERIOD_YEAR%TYPE;
    L_PRIOR_PERIOD_YEAR AP_OTHER_PERIODS.PERIOD_YEAR%TYPE;
    L_PERIOD_NUM AP_OTHER_PERIODS.PERIOD_NUM%TYPE;
    L_PRIOR_PERIOD_NUM AP_OTHER_PERIODS.PERIOD_NUM%TYPE;
    L_PRIOR_PERIOD_NAME AP_OTHER_PERIODS.PERIOD_NAME%TYPE;
    L_PERIOD_TYPE AP_OTHER_PERIODS.PERIOD_TYPE%TYPE;
    L_START_DATE AP_OTHER_PERIODS.START_DATE%TYPE;
    L_PRIOR_START_DATE AP_OTHER_PERIODS.START_DATE%TYPE;
    L_END_DATE AP_OTHER_PERIODS.END_DATE%TYPE;
    L_PRIOR_END_DATE AP_OTHER_PERIODS.END_DATE%TYPE;
    L_STATUS AP_OTHER_PERIODS.STATUS%TYPE;
    PERIOD_NOT_DEFINED EXCEPTION;
  BEGIN
    BEGIN
      SELECT
        PERIOD_YEAR,
        PERIOD_NUM,
        PERIOD_TYPE,
        START_DATE,
        END_DATE,
        STATUS
      INTO L_PERIOD_YEAR,L_PERIOD_NUM,L_PERIOD_TYPE,L_START_DATE,L_END_DATE,L_STATUS
      FROM
        AP_OTHER_PERIODS
      WHERE ROWID = P_PERIOD_ROWID
        AND MODULE = C_MODULE;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE PERIOD_NOT_DEFINED;
    END;
    IF L_PERIOD_NUM = 1 THEN
      L_PRIOR_PERIOD_YEAR := L_PERIOD_YEAR - 1;
      SELECT
        MAX(PERIOD_NUM)
      INTO L_PRIOR_PERIOD_NUM
      FROM
        AP_OTHER_PERIODS
      WHERE PERIOD_TYPE = L_PERIOD_TYPE
        AND PERIOD_YEAR = L_PRIOR_PERIOD_YEAR
        AND MODULE = C_MODULE;
    ELSE
      L_PRIOR_PERIOD_NUM := L_PERIOD_NUM - 1;
      L_PRIOR_PERIOD_YEAR := L_PERIOD_YEAR;
    END IF;
    BEGIN
      SELECT
        PERIOD_NAME,
        START_DATE,
        END_DATE
      INTO L_PRIOR_PERIOD_NAME,L_PRIOR_START_DATE,L_PRIOR_END_DATE
      FROM
        AP_OTHER_PERIODS
      WHERE PERIOD_TYPE = L_PERIOD_TYPE
        AND PERIOD_YEAR = L_PRIOR_PERIOD_YEAR
        AND PERIOD_NUM = L_PRIOR_PERIOD_NUM
        AND MODULE = C_MODULE;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        L_PRIOR_PERIOD_NAME := '';
        L_PRIOR_START_DATE := '';
        L_PRIOR_START_DATE := '';
    END;
    C_PERIOD_YEAR := L_PERIOD_YEAR;
    C_PRIOR_PERIOD_YEAR := L_PRIOR_PERIOD_YEAR;
    C_PERIOD_NUM := L_PERIOD_NUM;
    C_PRIOR_PERIOD_NUM := L_PRIOR_PERIOD_NUM;
    C_PRIOR_PERIOD_NAME := L_PRIOR_PERIOD_NAME;
    C_PERIOD_TYPE := L_PERIOD_TYPE;
    C_START_DATE := L_START_DATE;
    C_PRIOR_START_DATE := L_PRIOR_START_DATE;
    C_END_DATE := L_END_DATE;
    C_PRIOR_END_DATE := L_PRIOR_END_DATE;
    C_STATUS := L_STATUS;
    RETURN (TRUE);
    /*SRW.MESSAGE('1'
               ,C_PRIOR_PERIOD_NAME)*/NULL;
    RETURN NULL;
  EXCEPTION
    WHEN PERIOD_NOT_DEFINED THEN
      /*SRW.MESSAGE('101'
                 ,'Current period is not defined.')*/NULL;
      RETURN (TRUE);
    WHEN OTHERS THEN
      RETURN (FALSE);
  END PERIOD_DATA;

  FUNCTION ALL_PERIOD RETURN BOOLEAN IS
    L_TOTAL_VENDORS NUMBER := 0;
    L_TOTAL_INACTIVE NUMBER := 0;
    L_TOTAL_ONE_TIME NUMBER := 0;
    L_TOTAL_1099 NUMBER := 0;
    L_TOTAL_VOIDED NUMBER := 0;
    L_TOTAL_DISTS NUMBER := 0;
    L_TOTAL_BATCHES NUMBER := 0;
    L_TOTAL_INVOICES NUMBER := 0;
    L_TOTAL_INVOICES_DLR NUMBER := 0;
    L_TOTAL_INVOICE_HOLDS NUMBER := 0;
    L_TOTAL_INVOICE_HOLDS_DLR NUMBER := 0;
    L_TOTAL_CLEARED NUMBER := 0;
    L_TOTAL_CLEARED_DLR NUMBER := 0;
    L_TOTAL_STOPPED NUMBER := 0;
    L_TOTAL_MAN_CHECKS NUMBER := 0;
    L_TOTAL_MAN_CHECKS_DLR NUMBER := 0;
    L_TOTAL_AUTO_CHECKS NUMBER := 0;
    L_TOTAL_AUTO_CHECKS_DLR NUMBER := 0;
    L_TOTAL_SPOILED NUMBER := 0;
    L_TOTAL_OUTSTANDING NUMBER := 0;
    L_TOTAL_PAID_INV NUMBER := 0;
    L_TOTAL_DISCS_DLR NUMBER := 0;
    L_TOTAL_DISCS NUMBER := 0;
    L_TOTAL_SCHEDULED NUMBER := 0;
    L_TOTAL_SITES NUMBER := 0;
    L_TOTAL_REFUND_CHECKS NUMBER := 0;
    L_TOTAL_REFUND_CHECKS_DLR NUMBER := 0;
    L_TOTAL_OUTSTANDING_DLR NUMBER := 0;
    L_TOTAL_LINES NUMBER := 0;
  BEGIN
    SELECT
      count(*),
      NVL(SUM(DECODE(SIGN(NVL(END_DATE_ACTIVE
                             ,SYSDATE + 1) - SYSDATE)
                    ,1
                    ,0
                    ,1))
         ,0),
      NVL(SUM(DECODE(ONE_TIME_FLAG
                    ,'Y'
                    ,1
                    ,0))
         ,0),
      NVL(SUM(DECODE(TYPE_1099
                    ,NULL
                    ,0
                    ,1))
         ,0)
    INTO L_TOTAL_VENDORS,L_TOTAL_INACTIVE,L_TOTAL_ONE_TIME,L_TOTAL_1099
    FROM
      PO_VENDORS
    WHERE TRUNC(CREATION_DATE) <= TO_DATE(C_END_DATE
           ,'DD/MM/YYYY');
    SELECT
      count(*)
    INTO L_TOTAL_VOIDED
    FROM
      AP_CHECKS
    WHERE VOID_DATE <= TO_DATE(C_END_DATE
           ,'DD/MM/YYYY');
    SELECT
      count(*)
    INTO L_TOTAL_DISTS
    FROM
      AP_INVOICE_DISTRIBUTIONS DIS
    WHERE TRUNC(DIS.CREATION_DATE) <= TO_DATE(C_END_DATE
           ,'DD/MM/YYYY');
    SELECT
      count(*)
    INTO L_TOTAL_LINES
    FROM
      AP_INVOICE_LINES LINES
    WHERE TRUNC(LINES.CREATION_DATE) <= TO_DATE(C_END_DATE
           ,'DD/MM/YYYY');
    SELECT
      count(( BATCH_ID )),
      nvl(count(*),
          0),
      SUM(NVL(BASE_AMOUNT
             ,NVL(INVOICE_AMOUNT
                ,0)))
    INTO L_TOTAL_BATCHES,L_TOTAL_INVOICES,L_TOTAL_INVOICES_DLR
    FROM
      AP_INVOICES
    WHERE TRUNC(CREATION_DATE) <= TO_DATE(C_END_DATE
           ,'DD/MM/YYYY');
    SELECT
      NVL(SUM(DECODE(AP_HOLDS.HOLD_LOOKUP_CODE
                    ,NULL
                    ,0
                    ,1))
         ,0),
      NVL(SUM(DECODE(AP_HOLDS.HOLD_LOOKUP_CODE
                    ,NULL
                    ,0
                    ,NVL(AP_INVOICES.BASE_AMOUNT
                       ,AP_INVOICES.INVOICE_AMOUNT)))
         ,0)
    INTO L_TOTAL_INVOICE_HOLDS,L_TOTAL_INVOICE_HOLDS_DLR
    FROM
      AP_INVOICES,
      AP_HOLDS,
      AP_HOLD_CODES
    WHERE AP_INVOICES.INVOICE_ID = AP_HOLDS.INVOICE_ID
      AND AP_HOLDS.HOLD_LOOKUP_CODE = AP_HOLD_CODES.HOLD_LOOKUP_CODE
      AND AP_HOLD_CODES.HOLD_TYPE = 'INVOICE HOLD REASON'
      AND AP_HOLDS.RELEASE_LOOKUP_CODE IS NULL
      AND TRUNC(AP_INVOICES.CREATION_DATE) <= TO_DATE(C_END_DATE
           ,'DD/MM/YYYY');
    SELECT
      count(*),
      NVL(SUM(NVL(CLEARED_BASE_AMOUNT
                 ,NVL(CLEARED_AMOUNT
                    ,AMOUNT)))
         ,0)
    INTO L_TOTAL_CLEARED,L_TOTAL_CLEARED_DLR
    FROM
      AP_CHECKS
    WHERE CLEARED_DATE <= TO_DATE(C_END_DATE
           ,'DD/MM/YYYY');
    SELECT
      count(*)
    INTO L_TOTAL_STOPPED
    FROM
      AP_CHECKS
    WHERE STOPPED_BY is not null
      AND VOID_DATE is null
      AND RELEASED_DATE is null;
    SELECT
      NVL(SUM(DECODE(PAYMENT_TYPE_FLAG
                    ,'R'
                    ,0
                    ,(DECODE(CHECKRUN_NAME
                          ,NULL
                          ,1
                          ,0))))
         ,0),
      NVL(SUM(DECODE(PAYMENT_TYPE_FLAG
                    ,'R'
                    ,0
                    ,(DECODE(CHECKRUN_NAME
                          ,NULL
                          ,NVL(BASE_AMOUNT
                             ,AMOUNT)
                          ,0))))
         ,0),
      NVL(SUM(DECODE(CHECKRUN_NAME
                    ,NULL
                    ,0
                    ,1))
         ,0),
      NVL(SUM(DECODE(CHECKRUN_NAME
                    ,NULL
                    ,0
                    ,NVL(BASE_AMOUNT
                       ,AMOUNT)))
         ,0),
      NVL(SUM(DECODE(STATUS_LOOKUP_CODE
                    ,'SPOILED'
                    ,1
                    ,0))
         ,0),
      SUM(DECODE(CLEARED_DATE
                ,NULL
                ,DECODE(STATUS_LOOKUP_CODE
                      ,'NEGOTIABLE'
                      ,1
                      ,'ISSUED'
                      ,1
                      ,'VOIDED'
                      ,1
                      ,'STOP INITIATED'
                      ,1
                      ,0)
                ,0)),
      SUM(DECODE(CLEARED_DATE
                ,NULL
                ,DECODE(STATUS_LOOKUP_CODE
                      ,'NEGOTIABLE'
                      ,NVL(BASE_AMOUNT
                         ,AMOUNT)
                      ,'ISSUED'
                      ,NVL(BASE_AMOUNT
                         ,AMOUNT)
                      ,'VOIDED'
                      ,NVL(BASE_AMOUNT
                         ,AMOUNT)
                      ,'STOP INITIATED'
                      ,NVL(BASE_AMOUNT
                         ,AMOUNT)
                      ,0)
                ,0))
    INTO L_TOTAL_MAN_CHECKS,L_TOTAL_MAN_CHECKS_DLR,L_TOTAL_AUTO_CHECKS,L_TOTAL_AUTO_CHECKS_DLR,L_TOTAL_SPOILED,L_TOTAL_OUTSTANDING,L_TOTAL_OUTSTANDING_DLR
    FROM
      AP_CHECKS
    WHERE CHECK_DATE <= TO_DATE(C_END_DATE
           ,'DD/MM/YYYY')
      AND NVL(VOID_DATE
       ,SYSDATE + 1) >= sysdate;
    SELECT
      NVL(SUM(DECODE(CHECKRUN_NAME
                    ,NULL
                    ,1
                    ,0))
         ,0),
      NVL(SUM(DECODE(CHECKRUN_NAME
                    ,NULL
                    ,NVL(BASE_AMOUNT
                       ,AMOUNT)
                    ,0))
         ,0)
    INTO L_TOTAL_REFUND_CHECKS,L_TOTAL_REFUND_CHECKS_DLR
    FROM
      AP_CHECKS
    WHERE CHECK_DATE <= TO_DATE(C_END_DATE
           ,'DD/MM/YYYY')
      AND NVL(VOID_DATE
       ,SYSDATE + 1) >= sysdate
      AND PAYMENT_TYPE_FLAG = 'R';
    SELECT
      count(( INVOICE_ID )),
      NVL(SUM(NVL(AP_UTILITIES_PKG.AP_ROUND_CURRENCY((DISCOUNT_TAKEN * NVL(PAY.EXCHANGE_RATE
                                                        ,1))
                                                    ,C_BASE_CURRENCY_CODE)
                 ,0))
         ,0),
      NVL(SUM(DECODE(DISCOUNT_TAKEN
                    ,NULL
                    ,0
                    ,0
                    ,0
                    ,1))
         ,0)
    INTO L_TOTAL_PAID_INV,L_TOTAL_DISCS_DLR,L_TOTAL_DISCS
    FROM
      AP_CHECKS CHK,
      AP_INVOICE_PAYMENTS PAY
    WHERE CHECK_DATE <= TO_DATE(C_END_DATE
           ,'DD/MM/YYYY')
      AND PAY.CHECK_ID = CHK.CHECK_ID
      AND NVL(VOID_DATE
       ,SYSDATE + 1) >= sysdate;
    SELECT
      count(*)
    INTO L_TOTAL_SCHEDULED
    FROM
      AP_PAYMENT_SCHEDULES PAY,
      AP_INVOICES INV
    WHERE PAY.INVOICE_ID = INV.INVOICE_ID
      AND TRUNC(INV.CREATION_DATE) <= TO_DATE(C_END_DATE
           ,'DD/MM/YYYY');
    SELECT
      count(*)
    INTO L_TOTAL_SITES
    FROM
      PO_VENDORS PV,
      PO_VENDOR_SITES PVS
    WHERE TRUNC(PVS.CREATION_DATE) <= TO_DATE(C_END_DATE
           ,'DD/MM/YYYY')
      AND PV.VENDOR_ID = PVS.VENDOR_ID
      AND TRUNC(PV.CREATION_DATE) <= TO_DATE(C_END_DATE
           ,'DD/MM/YYYY');
    C_TOTAL_VENDORS := L_TOTAL_VENDORS;
    C_TOTAL_INACTIVE := L_TOTAL_INACTIVE;
    C_TOTAL_ONE_TIME := L_TOTAL_ONE_TIME;
    C_TOTAL_1099 := L_TOTAL_1099;
    C_TOTAL_VOIDED := L_TOTAL_VOIDED;
    C_TOTAL_DISTS := L_TOTAL_DISTS;
    C_TOTAL_BATCHES := L_TOTAL_BATCHES;
    C_TOTAL_INVOICES := L_TOTAL_INVOICES;
    C_TOTAL_INVOICES_DLR := L_TOTAL_INVOICES_DLR;
    C_TOTAL_INVOICE_HOLDS := L_TOTAL_INVOICE_HOLDS;
    C_TOTAL_INVOICE_HOLDS_DLR := L_TOTAL_INVOICE_HOLDS_DLR;
    C_TOTAL_CLEARED := L_TOTAL_CLEARED;
    C_TOTAL_CLEARED_DLR := L_TOTAL_CLEARED_DLR;
    C_TOTAL_STOPPED := L_TOTAL_STOPPED;
    C_TOTAL_MAN_CHECKS := L_TOTAL_MAN_CHECKS;
    C_TOTAL_MAN_CHECKS_DLR := L_TOTAL_MAN_CHECKS_DLR;
    C_TOTAL_AUTO_CHECKS := L_TOTAL_AUTO_CHECKS;
    C_TOTAL_AUTO_CHECKS_DLR := L_TOTAL_AUTO_CHECKS_DLR;
    C_TOTAL_SPOILED := L_TOTAL_SPOILED;
    C_TOTAL_OUTSTANDING := L_TOTAL_OUTSTANDING;
    C_TOTAL_PAID_INV := L_TOTAL_PAID_INV;
    C_TOTAL_DISCS_DLR := L_TOTAL_DISCS_DLR;
    C_TOTAL_DISCS := L_TOTAL_DISCS;
    C_TOTAL_SCHEDULED := L_TOTAL_SCHEDULED;
    C_TOTAL_SITES := L_TOTAL_SITES;
    C_TOTAL_REFUND_CHECKS := L_TOTAL_REFUND_CHECKS;
    C_TOTAL_REFUND_CHECKS_DLR := L_TOTAL_REFUND_CHECKS_DLR;
    C_TOTAL_OUTSTANDING_DLR := L_TOTAL_OUTSTANDING_DLR;
    C_TOTAL_LINES := L_TOTAL_LINES;
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END ALL_PERIOD;

  FUNCTION MATCHING_HOLDS RETURN BOOLEAN IS
    L_INVOICE_AMOUNT NUMBER;
    L_CREATION_DATE DATE;
    L_TOTAL_MH NUMBER := 0;
    L_TOTAL_MH_DLR NUMBER := 0;
    L_MH_COUNT NUMBER := 0;
    L_MH_AMOUNT NUMBER := 0;
  BEGIN
    FOR c1 IN (SELECT
                 H.INVOICE_ID
               FROM
                 AP_HOLDS H,
                 AP_HOLD_CODES HC
               WHERE RELEASE_LOOKUP_CODE is null
                 AND H.HOLD_LOOKUP_CODE = HC.HOLD_LOOKUP_CODE
                 AND HC.HOLD_TYPE = 'MATCHING HOLD REASON') LOOP
      BEGIN
        SELECT
          NVL(BASE_AMOUNT
             ,NVL(INVOICE_AMOUNT
                ,0)),
          TRUNC(CREATION_DATE)
        INTO L_INVOICE_AMOUNT,L_CREATION_DATE
        FROM
          AP_INVOICES
        WHERE INVOICE_ID = C1.INVOICE_ID;
        IF L_CREATION_DATE <= TO_DATE(C_END_DATE
               ,'DD/MM/YYYY') THEN
          L_TOTAL_MH := L_TOTAL_MH + 1;
          L_TOTAL_MH_DLR := L_TOTAL_MH_DLR + L_INVOICE_AMOUNT;
          IF L_CREATION_DATE >= TO_DATE(C_START_DATE
                 ,'DD/MM/YYYY') THEN
            L_MH_COUNT := L_MH_COUNT + 1;
            L_MH_AMOUNT := L_MH_AMOUNT + L_INVOICE_AMOUNT;
          END IF;
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
      END;
    END LOOP;
    C_TOTAL_MH := L_TOTAL_MH;
    C_TOTAL_MH_DLR := L_TOTAL_MH_DLR;
    C_MH_COUNT := L_MH_COUNT;
    C_MH_AMOUNT := L_MH_AMOUNT;
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END MATCHING_HOLDS;

  FUNCTION INVOICE_DATA RETURN BOOLEAN IS
    L_INVOICE_AMOUNT NUMBER;
    L_CREATION_DATE DATE;
    L_TOTAL_MATCHED NUMBER := 0;
    L_TOTAL_MATCHED_DLR NUMBER := 0;
    L_NEW_COUNT NUMBER := 0;
    L_NEW_AMOUNT NUMBER := 0;
  BEGIN
    FOR c1 IN (SELECT
                 DISTINCT
                 ( INVOICE_ID ) MATCHED_INVOICE_ID
               FROM
                 AP_INVOICE_DISTRIBUTIONS
               WHERE PO_DISTRIBUTION_ID is not null) LOOP
      BEGIN
        SELECT
          NVL(BASE_AMOUNT
             ,NVL(INVOICE_AMOUNT
                ,0)),
          TRUNC(CREATION_DATE)
        INTO L_INVOICE_AMOUNT,L_CREATION_DATE
        FROM
          AP_INVOICES
        WHERE INVOICE_ID = C1.MATCHED_INVOICE_ID;
        IF L_CREATION_DATE <= TO_DATE(C_END_DATE
               ,'DD/MM/YYYY') THEN
          L_TOTAL_MATCHED := L_TOTAL_MATCHED + 1;
          L_TOTAL_MATCHED_DLR := L_TOTAL_MATCHED_DLR + L_INVOICE_AMOUNT;
          IF L_CREATION_DATE >= TO_DATE(C_START_DATE
                 ,'DD/MM/YYYY') THEN
            L_NEW_COUNT := L_NEW_COUNT + 1;
            L_NEW_AMOUNT := L_NEW_AMOUNT + L_INVOICE_AMOUNT;
          END IF;
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
      END;
    END LOOP;
    C_TOTAL_MATCHED := L_TOTAL_MATCHED;
    C_TOTAL_MATCHED_DLR := L_TOTAL_MATCHED_DLR;
    C_NEW_COUNT := L_NEW_COUNT;
    C_NEW_AMOUNT := L_NEW_AMOUNT;
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END INVOICE_DATA;

  FUNCTION VARIANCE_DATA RETURN BOOLEAN IS
    L_DIST_TOTAL_VARS NUMBER := 0;
    L_DIST_TOTAL_VARS_DLR NUMBER := 0;
    L_DIST_VAR_COUNT NUMBER := 0;
    L_DIST_VAR_AMOUNT NUMBER := 0;
    L_LINE_TOTAL_VARS NUMBER := 0;
    L_LINE_TOTAL_VARS_DLR NUMBER := 0;
    L_LINE_VAR_COUNT NUMBER := 0;
    L_LINE_VAR_AMOUNT NUMBER := 0;
  BEGIN
    FOR c1 IN (SELECT
                 SUM(NVL(DIS.BASE_AMOUNT
                        ,DIS.AMOUNT)) DIS_SUM,
                 TRUNC(INV.CREATION_DATE) INV_CREATION_DATE,
                 NVL(INV.BASE_AMOUNT
                    ,NVL(INVOICE_AMOUNT
                       ,0)) INV_AMOUNT
               FROM
                 AP_INVOICE_DISTRIBUTIONS DIS,
                 AP_INVOICES INV
               WHERE PAYMENT_STATUS_FLAG in ( 'P' , 'N' )
                 AND DIS.INVOICE_ID = INV.INVOICE_ID
               GROUP BY
                 DIS.INVOICE_ID,
                 INV.CREATION_DATE,
                 INVOICE_AMOUNT,
                 INV.BASE_AMOUNT	-- Added
               HAVING INVOICE_AMOUNT <> SUM(DIS.AMOUNT)) LOOP
      IF C1.INV_CREATION_DATE <= TO_DATE(C_END_DATE
             ,'DD/MM/YYYY') THEN
        L_DIST_TOTAL_VARS := L_DIST_TOTAL_VARS + 1;
        L_DIST_TOTAL_VARS_DLR := L_DIST_TOTAL_VARS_DLR + C1.INV_AMOUNT;
        IF C1.INV_CREATION_DATE >= TO_DATE(C_START_DATE
               ,'DD/MM/YYYY') THEN
          L_DIST_VAR_COUNT := L_DIST_VAR_COUNT + 1;
          L_DIST_VAR_AMOUNT := L_DIST_VAR_AMOUNT + C1.INV_AMOUNT;
        END IF;
      END IF;
    END LOOP;
    FOR c2 IN (SELECT
                 SUM(LINES.AMOUNT) LINES_SUM,
                 TRUNC(INV.CREATION_DATE) INV_CREATION_DATE,
                 NVL(INVOICE_AMOUNT
                    ,0) INV_AMOUNT
               FROM
                 AP_INVOICE_LINES LINES,
                 AP_INVOICES INV,
                 AP_INVOICE_DISTRIBUTIONS DIST
               WHERE INV.INVOICE_ID = LINES.INVOICE_ID
                 AND LINES.INVOICE_ID = DIST.INVOICE_ID
                 AND LINES.LINE_NUMBER = DIST.INVOICE_LINE_NUMBER
                 AND PAYMENT_STATUS_FLAG in ( 'P' , 'N' )
               GROUP BY
                 LINES.INVOICE_ID,
                 INV.CREATION_DATE,
                 INVOICE_AMOUNT
               HAVING INVOICE_AMOUNT <> SUM(LINES.AMOUNT)) LOOP
      IF C2.INV_CREATION_DATE <= TO_DATE(C_END_DATE
             ,'DD/MM/YYYY') THEN
        L_LINE_TOTAL_VARS := L_LINE_TOTAL_VARS + 1;
        L_LINE_TOTAL_VARS_DLR := L_LINE_TOTAL_VARS_DLR + C2.INV_AMOUNT;
        IF C2.INV_CREATION_DATE >= TO_DATE(C_START_DATE
               ,'DD/MM/YYYY') THEN
          L_LINE_VAR_COUNT := L_LINE_VAR_COUNT + 1;
          L_LINE_VAR_AMOUNT := L_LINE_VAR_AMOUNT + C2.INV_AMOUNT;
        END IF;
      END IF;
    END LOOP;
    C_DIST_TOTAL_VARS := L_DIST_TOTAL_VARS;
    C_DIST_TOTAL_VARS_DLR := L_DIST_TOTAL_VARS_DLR;
    C_DIST_VAR_COUNT := L_DIST_VAR_COUNT;
    C_DIST_VAR_AMOUNT := L_DIST_VAR_AMOUNT;
    C_LINE_TOTAL_VARS := L_LINE_TOTAL_VARS;
    C_LINE_TOTAL_VARS_DLR := L_LINE_TOTAL_VARS_DLR;
    C_LINE_VAR_COUNT := L_LINE_VAR_COUNT;
    C_LINE_VAR_AMOUNT := L_LINE_VAR_AMOUNT;
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END VARIANCE_DATA;

  FUNCTION CURRENT_PERIOD RETURN BOOLEAN IS
    L_VOID NUMBER := 0;
    L_CLEARED NUMBER := 0;
    L_CLEARED_DLR NUMBER := 0;
    L_STOPPED NUMBER := 0;
    L_MANUAL_CHECKS NUMBER := 0;
    L_MANUAL_CHECKS_DLR NUMBER := 0;
    L_AUTO_CHECKS NUMBER := 0;
    L_AUTO_CHECKS_DLR NUMBER := 0;
    L_NEW_SPOILED NUMBER := 0;
    L_NEW_OUTSTANDING NUMBER := 0;
    L_MANUAL_PAYMENTS NUMBER := 0;
    L_MANUAL_PAYMENTS_DLR NUMBER := 0;
    L_AUTO_PAYMENTS NUMBER := 0;
    L_AUTO_PAYMENTS_DLR NUMBER := 0;
    L_INVOICES NUMBER := 0;
    L_DISCOUNT_DLR NUMBER := 0;
    L_DISCOUNTS NUMBER := 0;
    L_NEW_INVOICES NUMBER := 0;
    L_TOTAL_DLR NUMBER := 0;
    L_BATCHES NUMBER := 0;
    L_NEW_ON_HOLD NUMBER := 0;
    L_NEW_HOLD_DLR NUMBER := 0;
    L_PAYMENT_SCHEDULES NUMBER := 0;
    L_NEW_DISTS NUMBER := 0;
    L_NEW_VENDORS NUMBER := 0;
    L_NEW_INACTIVE NUMBER := 0;
    L_NEW_ONE_TIME NUMBER := 0;
    L_NEW_TYPE_1099_VENDORS NUMBER := 0;
    L_OLD_VENDOR_SITES NUMBER := 0;
    L_TOTAL_VENDORS_HELD NUMBER := 0;
    L_NEW_VENDOR_SITES NUMBER := 0;
    L_NEW_VENDORS_HELD NUMBER := 0;
    L_UPDATED_VENDORS NUMBER := 0;
    L_UPDATED_SITES NUMBER := 0;
    L_NEW_OUTSTANDING_DLR NUMBER := 0;
    L_NEW_REFUND_PAYMENTS NUMBER := 0;
    L_NEW_REFUND_PAYMENTS_DLR NUMBER := 0;
    L_NEW_LINES NUMBER := 0;
  BEGIN
    SELECT
      count(*)
    INTO L_VOID
    FROM
      AP_CHECKS
    WHERE VOID_DATE >= TO_DATE(C_START_DATE
           ,'DD/MM/YYYY')
      AND VOID_DATE <= TO_DATE(C_END_DATE
           ,'DD/MM/YYYY');
    SELECT
      count(*),
      NVL(SUM(NVL(CLEARED_BASE_AMOUNT
                 ,NVL(CLEARED_AMOUNT
                    ,AMOUNT)))
         ,0)
    INTO L_CLEARED,L_CLEARED_DLR
    FROM
      AP_CHECKS
    WHERE CLEARED_DATE >= TO_DATE(C_START_DATE
           ,'DD/MM/YYYY')
      AND CLEARED_DATE <= TO_DATE(C_END_DATE
           ,'DD/MM/YYYY');
    SELECT
      count(*)
    INTO L_STOPPED
    FROM
      AP_CHECKS
    WHERE TRUNC(STOPPED_DATE) >= TO_DATE(C_START_DATE
           ,'DD/MM/YYYY')
      AND TRUNC(STOPPED_DATE) <= TO_DATE(C_END_DATE
           ,'DD/MM/YYYY')
      AND VOID_DATE is null
      AND RELEASED_DATE is null;
    SELECT
      NVL(SUM(DECODE(PAYMENT_TYPE_FLAG
                    ,'R'
                    ,0
                    ,(DECODE(CHECKRUN_NAME
                          ,NULL
                          ,1
                          ,0))))
         ,0),
      NVL(SUM(DECODE(PAYMENT_TYPE_FLAG
                    ,'R'
                    ,0
                    ,(DECODE(CHECKRUN_NAME
                          ,NULL
                          ,NVL(BASE_AMOUNT
                             ,AMOUNT)
                          ,0))))
         ,0),
      NVL(SUM(DECODE(CHECKRUN_NAME
                    ,NULL
                    ,0
                    ,1))
         ,0),
      NVL(SUM(DECODE(CHECKRUN_NAME
                    ,NULL
                    ,0
                    ,NVL(BASE_AMOUNT
                       ,AMOUNT)))
         ,0),
      NVL(SUM(DECODE(STATUS_LOOKUP_CODE
                    ,'SPOILED'
                    ,1
                    ,0))
         ,0),
      SUM(DECODE(CLEARED_DATE
                ,NULL
                ,DECODE(STATUS_LOOKUP_CODE
                      ,'NEGOTIABLE'
                      ,1
                      ,'ISSUED'
                      ,1
                      ,'VOIDED'
                      ,1
                      ,'STOP INITIATED'
                      ,1
                      ,0)
                ,0)),
      SUM(DECODE(CLEARED_DATE
                ,NULL
                ,DECODE(STATUS_LOOKUP_CODE
                      ,'NEGOTIABLE'
                      ,NVL(BASE_AMOUNT
                         ,AMOUNT)
                      ,'ISSUED'
                      ,NVL(BASE_AMOUNT
                         ,AMOUNT)
                      ,'VOIDED'
                      ,NVL(BASE_AMOUNT
                         ,AMOUNT)
                      ,'STOP INITIATED'
                      ,NVL(BASE_AMOUNT
                         ,AMOUNT)
                      ,0)
                ,0))
    INTO L_MANUAL_CHECKS,L_MANUAL_CHECKS_DLR,L_AUTO_CHECKS,L_AUTO_CHECKS_DLR,L_NEW_SPOILED,L_NEW_OUTSTANDING,L_NEW_OUTSTANDING_DLR
    FROM
      AP_CHECKS
    WHERE CHECK_DATE >= TO_DATE(C_START_DATE
           ,'DD/MM/YYYY')
      AND CHECK_DATE <= TO_DATE(C_END_DATE
           ,'DD/MM/YYYY')
      AND NVL(VOID_DATE
       ,SYSDATE + 1) >= sysdate;
    SELECT
      NVL(SUM(DECODE(CHECKRUN_NAME
                    ,NULL
                    ,1
                    ,0))
         ,0),
      NVL(SUM(DECODE(CHECKRUN_NAME
                    ,NULL
                    ,NVL(BASE_AMOUNT
                       ,AMOUNT)
                    ,0))
         ,0)
    INTO L_NEW_REFUND_PAYMENTS,L_NEW_REFUND_PAYMENTS_DLR
    FROM
      AP_CHECKS
    WHERE CHECK_DATE >= TO_DATE(C_START_DATE
           ,'DD/MM/YYYY')
      AND CHECK_DATE <= TO_DATE(C_END_DATE
           ,'DD/MM/YYYY')
      AND NVL(VOID_DATE
       ,SYSDATE + 1) >= sysdate
      AND PAYMENT_TYPE_FLAG = 'R';
    SELECT
      NVL(SUM(DECODE(CHECKRUN_NAME
                    ,NULL
                    ,1
                    ,0))
         ,0),
      NVL(SUM(DECODE(CHECKRUN_NAME
                    ,NULL
                    ,NVL(PAY.PAYMENT_BASE_AMOUNT
                       ,PAY.AMOUNT)
                    ,0))
         ,0),
      NVL(SUM(DECODE(CHECKRUN_NAME
                    ,NULL
                    ,0
                    ,1))
         ,0),
      NVL(SUM(DECODE(CHECKRUN_NAME
                    ,NULL
                    ,0
                    ,NVL(PAY.PAYMENT_BASE_AMOUNT
                       ,PAY.AMOUNT)))
         ,0),
      nvl(count(( INVOICE_ID )),
          0),
      NVL(SUM(AP_UTILITIES_PKG.AP_ROUND_CURRENCY((DISCOUNT_TAKEN * NVL(PAY.EXCHANGE_RATE
                                                    ,1))
                                                ,C_BASE_CURRENCY_CODE))
         ,0),
      NVL(SUM(DECODE(DISCOUNT_TAKEN
                    ,NULL
                    ,0
                    ,0
                    ,0
                    ,1))
         ,0)
    INTO L_MANUAL_PAYMENTS,L_MANUAL_PAYMENTS_DLR,L_AUTO_PAYMENTS,L_AUTO_PAYMENTS_DLR,L_INVOICES,L_DISCOUNT_DLR,L_DISCOUNTS
    FROM
      AP_CHECKS CHK,
      AP_INVOICE_PAYMENTS PAY
    WHERE CHECK_DATE >= TO_DATE(C_START_DATE
           ,'DD/MM/YYYY')
      AND CHECK_DATE <= TO_DATE(C_END_DATE
           ,'DD/MM/YYYY')
      AND PAY.CHECK_ID = CHK.CHECK_ID
      AND NVL(VOID_DATE
       ,SYSDATE + 1) >= sysdate;
    SELECT
      count(*),
      SUM(NVL(BASE_AMOUNT
             ,NVL(INVOICE_AMOUNT
                ,0))),
      nvl(count(( BATCH_ID )),
          0)
    INTO L_NEW_INVOICES,L_TOTAL_DLR,L_BATCHES
    FROM
      AP_INVOICES
    WHERE TRUNC(CREATION_DATE) >= TRUNC(TO_DATE(C_START_DATE
                 ,'DD/MM/YYYY'))
      AND TRUNC(CREATION_DATE) <= TRUNC(TO_DATE(C_END_DATE
                 ,'DD/MM/YYYY'));
    SELECT
      NVL(SUM(DECODE(H.HOLD_LOOKUP_CODE
                    ,NULL
                    ,0
                    ,1))
         ,0),
      NVL(SUM(DECODE(H.HOLD_LOOKUP_CODE
                    ,NULL
                    ,0
                    ,NVL(I.BASE_AMOUNT
                       ,I.INVOICE_AMOUNT)))
         ,0)
    INTO L_NEW_ON_HOLD,L_NEW_HOLD_DLR
    FROM
      AP_INVOICES I,
      AP_HOLDS H,
      AP_HOLD_CODES HC
    WHERE I.INVOICE_ID = H.INVOICE_ID
      AND H.HOLD_LOOKUP_CODE = HC.HOLD_LOOKUP_CODE
      AND TRUNC(I.CREATION_DATE) >= TO_DATE(C_START_DATE
           ,'DD/MM/YYYY')
      AND TRUNC(I.CREATION_DATE) <= TO_DATE(C_END_DATE
           ,'DD/MM/YYYY')
      AND HC.HOLD_TYPE = 'INVOICE HOLD REASON'
      AND H.RELEASE_LOOKUP_CODE IS NULL;
    SELECT
      count(*)
    INTO L_PAYMENT_SCHEDULES
    FROM
      AP_PAYMENT_SCHEDULES PAY,
      AP_INVOICES INV
    WHERE PAY.INVOICE_ID = INV.INVOICE_ID
      AND TRUNC(INV.CREATION_DATE) >= TO_DATE(C_START_DATE
           ,'DD/MM/YYYY')
      AND TRUNC(INV.CREATION_DATE) <= TO_DATE(C_END_DATE
           ,'DD/MM/YYYY');
    SELECT
      count(*)
    INTO L_NEW_LINES
    FROM
      AP_INVOICE_LINES LINES
    WHERE TRUNC(LINES.CREATION_DATE) >= TO_DATE(C_START_DATE
           ,'DD/MM/YYYY')
      AND TRUNC(LINES.CREATION_DATE) <= TO_DATE(C_END_DATE
           ,'DD/MM/YYYY');
    SELECT
      count(*)
    INTO L_NEW_DISTS
    FROM
      AP_INVOICE_DISTRIBUTIONS DIS
    WHERE TRUNC(DIS.CREATION_DATE) >= TO_DATE(C_START_DATE
           ,'DD/MM/YYYY')
      AND TRUNC(DIS.CREATION_DATE) <= TO_DATE(C_END_DATE
           ,'DD/MM/YYYY');
    SELECT
      count(*),
	    NVL(SUM(DECODE(SIGN(NVL(END_DATE_ACTIVE
	                     ,SYSDATE + 1) - SYSDATE)
	            ,1
	            ,0
	            ,1))
	 ,0),
      NVL(SUM(DECODE(ONE_TIME_FLAG
                    ,'Y'
                    ,1
                    ,0))
         ,0),
      NVL(SUM(DECODE(TYPE_1099
                    ,NULL
                    ,0
                    ,1))
         ,0)
    INTO L_NEW_VENDORS,L_NEW_INACTIVE,L_NEW_ONE_TIME,L_NEW_TYPE_1099_VENDORS
    FROM
      PO_VENDORS
    WHERE TRUNC(CREATION_DATE) >= TO_DATE(C_START_DATE
           ,'DD/MM/YYYY')
      AND TRUNC(CREATION_DATE) <= TO_DATE(C_END_DATE
           ,'DD/MM/YYYY');
    SELECT
      count(*),
      NVL(SUM(DECODE(PVS.HOLD_ALL_PAYMENTS_FLAG
                    ,'Y'
                    ,1
                    ,DECODE(PVS.HOLD_FUTURE_PAYMENTS_FLAG
                          ,'Y'
                          ,1
                          ,0)))
         ,0)
    INTO L_OLD_VENDOR_SITES,L_TOTAL_VENDORS_HELD
    FROM
      PO_VENDORS PV,
      PO_VENDOR_SITES PVS
    WHERE TRUNC(PVS.CREATION_DATE) >= TO_DATE(C_START_DATE
           ,'DD/MM/YYYY')
      AND TRUNC(PVS.CREATION_DATE) <= TO_DATE(C_END_DATE
           ,'DD/MM/YYYY')
      AND PV.VENDOR_ID = PVS.VENDOR_ID
      AND TRUNC(PV.CREATION_DATE) < TO_DATE(C_START_DATE
           ,'DD/MM/YYYY');
    SELECT
      count(*),
      NVL(SUM(DECODE(PVS.HOLD_ALL_PAYMENTS_FLAG
                    ,'Y'
                    ,1
                    ,DECODE(PVS.HOLD_FUTURE_PAYMENTS_FLAG
                          ,'Y'
                          ,1
                          ,0)))
         ,0)
    INTO L_NEW_VENDOR_SITES,L_NEW_VENDORS_HELD
    FROM
      PO_VENDORS PV,
      PO_VENDOR_SITES PVS
    WHERE TRUNC(PVS.CREATION_DATE) >= TO_DATE(C_START_DATE
           ,'DD/MM/YYYY')
      AND TRUNC(PVS.CREATION_DATE) <= TO_DATE(C_END_DATE
           ,'DD/MM/YYYY')
      AND PV.VENDOR_ID = PVS.VENDOR_ID
      AND TRUNC(PV.CREATION_DATE) >= TO_DATE(C_START_DATE
           ,'DD/MM/YYYY')
      AND TRUNC(PV.CREATION_DATE) <= TO_DATE(C_END_DATE
           ,'DD/MM/YYYY');
    SELECT
      count(*)
    INTO L_UPDATED_VENDORS
    FROM
      PO_VENDORS
    WHERE TRUNC(LAST_UPDATE_DATE) >= TO_DATE(C_START_DATE
           ,'DD/MM/YYYY')
      AND TRUNC(LAST_UPDATE_DATE) <= TO_DATE(C_END_DATE
           ,'DD/MM/YYYY');
    SELECT
      count(*)
    INTO L_UPDATED_SITES
    FROM
      PO_VENDOR_SITES
    WHERE TRUNC(LAST_UPDATE_DATE) >= TO_DATE(C_START_DATE
           ,'DD/MM/YYYY')
      AND TRUNC(LAST_UPDATE_DATE) <= TO_DATE(C_END_DATE
           ,'DD/MM/YYYY');
    C_VOID := L_VOID;
    C_CLEARED := L_CLEARED;
    C_CLEARED_DLR := L_CLEARED_DLR;
    C_STOPPED := L_STOPPED;
    C_MANUAL_CHECKS := L_MANUAL_CHECKS;
    C_MANUAL_CHECKS_DLR := L_MANUAL_CHECKS_DLR;
    C_AUTO_CHECKS := L_AUTO_CHECKS;
    C_AUTO_CHECKS_DLR := L_AUTO_CHECKS_DLR;
    C_NEW_SPOILED := L_NEW_SPOILED;
    C_NEW_OUTSTANDING := L_NEW_OUTSTANDING;
    C_MANUAL_PAYMENTS := L_MANUAL_PAYMENTS;
    C_MANUAL_PAYMENTS_DLR := L_MANUAL_PAYMENTS_DLR;
    C_AUTO_PAYMENTS := L_AUTO_PAYMENTS;
    C_AUTO_PAYMENTS_DLR := L_AUTO_PAYMENTS_DLR;
    C_INVOICES := L_INVOICES;
    C_DISCOUNT_DLR := L_DISCOUNT_DLR;
    C_DISCOUNTS := L_DISCOUNTS;
    C_NEW_INVOICES := L_NEW_INVOICES;
    C_TOTAL_DLR := L_TOTAL_DLR;
    C_BATCHES := L_BATCHES;
    C_NEW_ON_HOLD := L_NEW_ON_HOLD;
    C_NEW_HOLD_DLR := L_NEW_HOLD_DLR;
    C_PAYMENT_SCHEDULES := L_PAYMENT_SCHEDULES;
    C_NEW_DISTS := L_NEW_DISTS;
    C_NEW_VENDORS := L_NEW_VENDORS;
    C_NEW_INACTIVE := L_NEW_INACTIVE;
    C_NEW_ONE_TIME := L_NEW_ONE_TIME;
    C_NEW_TYPE_1099_VENDORS := L_NEW_TYPE_1099_VENDORS;
    C_OLD_VENDOR_SITES := L_OLD_VENDOR_SITES;
    C_TOTAL_VENDORS_HELD := L_TOTAL_VENDORS_HELD;
    C_NEW_VENDOR_SITES := L_NEW_VENDOR_SITES;
    C_NEW_VENDORS_HELD := L_NEW_VENDORS_HELD;
    C_UPDATED_VENDORS := L_UPDATED_VENDORS;
    C_UPDATED_SITES := L_UPDATED_SITES;
    C_NEW_OUTSTANDING_DLR := L_NEW_OUTSTANDING_DLR;
    C_NEW_REFUND_PAYMENTS := L_NEW_REFUND_PAYMENTS;
    C_NEW_REFUND_PAYMENTS_DLR := L_NEW_REFUND_PAYMENTS_DLR;
    C_NEW_LINES := L_NEW_LINES;
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END CURRENT_PERIOD;

  FUNCTION INSERT_KEY_IND RETURN BOOLEAN IS
  BEGIN
    INSERT INTO AP_INVOICE_KEY_IND
      (PERIOD_NAME
      ,LAST_UPDATE_DATE
      ,LAST_UPDATED_BY
      ,NUM_INVOICES
      ,AMOUNT_INVOICES
      ,NUM_INVOICE_LINES
      ,NUM_DISTRIBUTIONS
      ,NUM_BATCHES
      ,NUM_INVOICE_LINE_VARIANCES
      ,NUM_INVOICE_DIST_VARIANCES
      ,AMOUNT_INVOICE_LINE_VARIANCES
      ,AMOUNT_INVOICE_DIST_VARIANCES
      ,NUM_PAYMENT_SCHEDULES
      ,NUM_INVOICES_HELD
      ,AMOUNT_INVOICES_HELD
      ,NUM_INVOICES_MATCHED
      ,AMOUNT_INVOICES_MATCHED
      ,NUM_INVOICES_MATCH_HOLD
      ,AMOUNT_INVOICES_MATCH_HOLD
      ,ORG_ID)
    VALUES   (P_PERIOD_NAME
      ,SYSDATE
      ,0
      ,C_NEW_INVOICES
      ,C_TOTAL_DLR
      ,C_NEW_LINES
      ,C_NEW_DISTS
      ,C_BATCHES
      ,C_LINE_VAR_COUNT
      ,C_DIST_VAR_COUNT
      ,C_LINE_VAR_AMOUNT
      ,C_DIST_VAR_AMOUNT
      ,C_PAYMENT_SCHEDULES
      ,C_NEW_ON_HOLD
      ,C_NEW_HOLD_DLR
      ,C_NEW_COUNT
      ,C_NEW_AMOUNT
      ,C_MH_COUNT
      ,C_MH_AMOUNT
      ,C_ORG_ID);
    INSERT INTO AP_VENDOR_KEY_IND
      (PERIOD_NAME
      ,LAST_UPDATE_DATE
      ,LAST_UPDATED_BY
      ,NUM_VENDORS
      ,NUM_VENDOR_SITES
      ,NUM_SITES
      ,NUM_INACTIVE_VENDORS
      ,NUM_ONE_TIME_VENDORS
      ,NUM_1099_VENDORS
      ,NUM_VENDORS_HELD
      ,NUM_VENDORS_UPDATED
      ,NUM_SITES_UPDATED
      ,ORG_ID)
    VALUES   (P_PERIOD_NAME
      ,SYSDATE
      ,0
      ,C_NEW_VENDORS
      ,C_NEW_VENDOR_SITES
      ,C_OLD_VENDOR_SITES
      ,C_NEW_INACTIVE
      ,C_NEW_ONE_TIME
      ,C_NEW_TYPE_1099_VENDORS
      ,C_NEW_VENDORS_HELD
      ,C_UPDATED_VENDORS
      ,C_UPDATED_SITES
      ,C_ORG_ID);
    INSERT INTO AP_PAYMENT_KEY_IND
      (PERIOD_NAME
      ,LAST_UPDATE_DATE
      ,LAST_UPDATED_BY
      ,NUM_AUTO_PAYMENTS
      ,NUM_MANUAL_PAYMENTS
      ,AMOUNT_AUTO_PAYMENTS
      ,AMOUNT_MANUAL_PAYMENTS
      ,NUM_INVOICES_PAID
      ,NUM_AUTO_CHECKS
      ,NUM_MANUAL_CHECKS
      ,AMOUNT_AUTO_CHECKS
      ,AMOUNT_MANUAL_CHECKS
      ,NUM_DISCOUNTS_TAKEN
      ,AMOUNT_DISCOUNTS_TAKEN
      ,NUM_CHECKS_VOIDED
      ,NUM_STOP_PAYMENTS
      ,NUM_SPOILED
      ,NUM_OUTSTANDING
      ,NUM_CLEARED_CHECKS
      ,AMOUNT_CLEARED_CHECKS
      ,AMOUNT_OUTSTANDING
      ,NUM_REFUND_PAYMENTS
      ,AMOUNT_REFUND_PAYMENTS
      ,ORG_ID)
    VALUES   (P_PERIOD_NAME
      ,SYSDATE
      ,0
      ,C_AUTO_PAYMENTS
      ,C_MANUAL_PAYMENTS
      ,C_AUTO_PAYMENTS_DLR
      ,C_MANUAL_PAYMENTS_DLR
      ,C_INVOICES
      ,C_AUTO_CHECKS
      ,C_MANUAL_CHECKS
      ,C_AUTO_CHECKS_DLR
      ,C_MANUAL_CHECKS_DLR
      ,C_DISCOUNTS
      ,C_DISCOUNT_DLR
      ,C_VOID
      ,C_STOPPED
      ,C_NEW_SPOILED
      ,C_NEW_OUTSTANDING
      ,C_CLEARED
      ,C_CLEARED_DLR
      ,C_NEW_OUTSTANDING_DLR
      ,C_NEW_REFUND_PAYMENTS
      ,C_NEW_REFUND_PAYMENTS_DLR
      ,C_ORG_ID);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END INSERT_KEY_IND;

  FUNCTION UPDATE_KEY_IND RETURN BOOLEAN IS
  BEGIN
    UPDATE
      AP_INVOICE_KEY_IND
    SET
      LAST_UPDATE_DATE = SYSDATE
      ,LAST_UPDATED_BY = 0
      ,NUM_INVOICES = C_NEW_INVOICES
      ,AMOUNT_INVOICES = C_TOTAL_DLR
      ,NUM_DISTRIBUTIONS = C_NEW_DISTS
      ,NUM_INVOICE_LINES = C_NEW_LINES
      ,NUM_BATCHES = C_BATCHES
      ,NUM_INVOICE_LINE_VARIANCES = C_LINE_VAR_COUNT
      ,NUM_INVOICE_DIST_VARIANCES = C_DIST_VAR_COUNT
      ,AMOUNT_INVOICE_LINE_VARIANCES = C_LINE_VAR_AMOUNT
      ,AMOUNT_INVOICE_DIST_VARIANCES = C_DIST_VAR_AMOUNT
      ,NUM_PAYMENT_SCHEDULES = C_PAYMENT_SCHEDULES
      ,NUM_INVOICES_HELD = C_NEW_ON_HOLD
      ,AMOUNT_INVOICES_HELD = C_NEW_HOLD_DLR
      ,NUM_INVOICES_MATCHED = C_NEW_COUNT
      ,AMOUNT_INVOICES_MATCHED = C_NEW_AMOUNT
      ,NUM_INVOICES_MATCH_HOLD = C_MH_COUNT
      ,AMOUNT_INVOICES_MATCH_HOLD = C_MH_AMOUNT
    WHERE PERIOD_NAME = P_PERIOD_NAME;
    UPDATE
      AP_VENDOR_KEY_IND
    SET
      LAST_UPDATE_DATE = SYSDATE
      ,LAST_UPDATED_BY = 0
      ,NUM_VENDORS = C_NEW_VENDORS
      ,NUM_VENDOR_SITES = C_NEW_VENDOR_SITES
      ,NUM_SITES = C_OLD_VENDOR_SITES
      ,NUM_INACTIVE_VENDORS = C_NEW_INACTIVE
      ,NUM_ONE_TIME_VENDORS = C_NEW_ONE_TIME
      ,NUM_1099_VENDORS = C_NEW_TYPE_1099_VENDORS
      ,NUM_VENDORS_HELD = C_NEW_VENDORS_HELD
      ,NUM_VENDORS_UPDATED = C_UPDATED_VENDORS
      ,NUM_SITES_UPDATED = C_UPDATED_SITES
    WHERE PERIOD_NAME = P_PERIOD_NAME;
    UPDATE
      AP_PAYMENT_KEY_IND
    SET
      LAST_UPDATE_DATE = SYSDATE
      ,LAST_UPDATED_BY = 0
      ,NUM_AUTO_PAYMENTS = C_AUTO_PAYMENTS
      ,NUM_MANUAL_PAYMENTS = C_MANUAL_PAYMENTS
      ,AMOUNT_AUTO_PAYMENTS = C_AUTO_PAYMENTS_DLR
      ,AMOUNT_MANUAL_PAYMENTS = C_MANUAL_PAYMENTS_DLR
      ,NUM_INVOICES_PAID = C_INVOICES
      ,NUM_AUTO_CHECKS = C_AUTO_CHECKS
      ,NUM_MANUAL_CHECKS = C_MANUAL_CHECKS
      ,AMOUNT_AUTO_CHECKS = C_AUTO_CHECKS_DLR
      ,AMOUNT_MANUAL_CHECKS = C_MANUAL_CHECKS_DLR
      ,NUM_DISCOUNTS_TAKEN = C_DISCOUNTS
      ,AMOUNT_DISCOUNTS_TAKEN = C_DISCOUNT_DLR
      ,NUM_CHECKS_VOIDED = C_VOID
      ,NUM_STOP_PAYMENTS = C_STOPPED
      ,NUM_SPOILED = C_NEW_SPOILED
      ,NUM_OUTSTANDING = C_NEW_OUTSTANDING
      ,NUM_CLEARED_CHECKS = C_CLEARED
      ,AMOUNT_CLEARED_CHECKS = C_CLEARED_DLR
      ,AMOUNT_OUTSTANDING = C_NEW_OUTSTANDING_DLR
      ,NUM_REFUND_PAYMENTS = C_NEW_REFUND_PAYMENTS
      ,AMOUNT_REFUND_PAYMENTS = C_NEW_REFUND_PAYMENTS_DLR
    WHERE PERIOD_NAME = P_PERIOD_NAME;
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END UPDATE_KEY_IND;

  FUNCTION PRIOR_PERIOD RETURN BOOLEAN IS
    L_PRIOR_PERIOD_EXISTS VARCHAR2(1) := 'Y';
    L_OLD_INVOICES NUMBER := 0;
    L_OLD_TOTAL_DLR NUMBER := 0;
    L_OLD_DISTS NUMBER := 0;
    L_OLD_BATCHES NUMBER := 0;
    L_OLD_PAYMENT_SCHEDULES NUMBER := 0;
    L_OLD_ON_HOLD NUMBER := 0;
    L_OLD_HOLD_DLR NUMBER := 0;
    L_OLD_COUNT NUMBER := 0;
    L_OLD_AMOUNT NUMBER := 0;
    L_OLD_MH_COUNT NUMBER := 0;
    L_OLD_MH_AMOUNT NUMBER := 0;
    L_OLD_VENDORS NUMBER := 0;
    L_OLD_SITES NUMBER := 0;
    L_INACTIVE NUMBER := 0;
    L_ONE_TIME NUMBER := 0;
    L_TYPE_1099_VENDORS NUMBER := 0;
    L_VENDORS_HELD NUMBER := 0;
    L_OLD_INVOICES_PAID NUMBER := 0;
    L_OLD_AUTO_CHECKS NUMBER := 0;
    L_OLD_MANUAL_CHECKS NUMBER := 0;
    L_OLD_AUTO_CHECKS_DLR NUMBER := 0;
    L_OLD_MANUAL_CHECKS_DLR NUMBER := 0;
    L_OLD_DISCOUNTS NUMBER := 0;
    L_OLD_DISCOUNT_DLR NUMBER := 0;
    L_OLD_VOID NUMBER := 0;
    L_OLD_STOPPED NUMBER := 0;
    L_OLD_SPOILED NUMBER := 0;
    L_OLD_OUTSTANDING NUMBER := 0;
    L_OLD_CLEARED NUMBER := 0;
    L_OLD_CLEARED_DLR NUMBER := 0;
    L_PRIOR_OLD_VENDOR_SITES NUMBER := 0;
    L_PRIOR_VENDORS_UPDATED NUMBER := 0;
    L_PRIOR_SITES_UPDATED NUMBER := 0;
    L_OLD_OUTSTANDING_DLR NUMBER := 0;
    L_OLD_REFUND_PAYMENTS NUMBER := 0;
    L_OLD_REFUND_PAYMENTS_DLR NUMBER := 0;
    L_OLD_LINES NUMBER := 0;
    L_OLD_VAR_LINES_COUNT NUMBER := 0;
    L_OLD_VAR_LINES_AMOUNT NUMBER := 0;
    L_OLD_VAR_DISTS_COUNT NUMBER := 0;
    L_OLD_VAR_DISTS_AMOUNT NUMBER := 0;
  BEGIN
    BEGIN
      SELECT
        NUM_INVOICES,
        AMOUNT_INVOICES,
        NUM_INVOICE_LINES,
        NUM_DISTRIBUTIONS,
        NUM_BATCHES,
        NUM_INVOICE_LINE_VARIANCES,
        NUM_INVOICE_DIST_VARIANCES,
        AMOUNT_INVOICE_LINE_VARIANCES,
        AMOUNT_INVOICE_DIST_VARIANCES,
        NUM_PAYMENT_SCHEDULES,
        NUM_INVOICES_HELD,
        AMOUNT_INVOICES_HELD,
        NUM_INVOICES_MATCHED,
        AMOUNT_INVOICES_MATCHED,
        NUM_INVOICES_MATCH_HOLD,
        AMOUNT_INVOICES_MATCH_HOLD,
        NUM_VENDORS,
        NUM_VENDOR_SITES,
        NUM_SITES,
        NUM_INACTIVE_VENDORS,
        NUM_ONE_TIME_VENDORS,
        NUM_1099_VENDORS,
        NUM_VENDORS_HELD,
        NUM_VENDORS_UPDATED,
        NUM_SITES_UPDATED,
        NUM_INVOICES_PAID,
        NUM_AUTO_CHECKS,
        NUM_MANUAL_CHECKS,
        AMOUNT_AUTO_CHECKS,
        AMOUNT_MANUAL_CHECKS,
        NUM_DISCOUNTS_TAKEN,
        AMOUNT_DISCOUNTS_TAKEN,
        NUM_CHECKS_VOIDED,
        NUM_STOP_PAYMENTS,
        NUM_SPOILED,
        NUM_OUTSTANDING,
        NUM_CLEARED_CHECKS,
        AMOUNT_CLEARED_CHECKS,
        AMOUNT_OUTSTANDING,
        NUM_REFUND_PAYMENTS,
        AMOUNT_REFUND_PAYMENTS
      INTO L_OLD_INVOICES,L_OLD_TOTAL_DLR,L_OLD_LINES,L_OLD_DISTS,L_OLD_BATCHES,L_OLD_VAR_LINES_COUNT,
      L_OLD_VAR_DISTS_COUNT,L_OLD_VAR_LINES_AMOUNT,L_OLD_VAR_DISTS_AMOUNT,L_OLD_PAYMENT_SCHEDULES,
      L_OLD_ON_HOLD,L_OLD_HOLD_DLR,L_OLD_COUNT,L_OLD_AMOUNT,L_OLD_MH_COUNT,L_OLD_MH_AMOUNT,L_OLD_VENDORS,
      L_OLD_SITES,L_PRIOR_OLD_VENDOR_SITES,L_INACTIVE,L_ONE_TIME,L_TYPE_1099_VENDORS,L_VENDORS_HELD,
      L_PRIOR_VENDORS_UPDATED,L_PRIOR_SITES_UPDATED,L_OLD_INVOICES_PAID,L_OLD_AUTO_CHECKS,L_OLD_MANUAL_CHECKS,
      L_OLD_AUTO_CHECKS_DLR,L_OLD_MANUAL_CHECKS_DLR,L_OLD_DISCOUNTS,L_OLD_DISCOUNT_DLR,L_OLD_VOID,L_OLD_STOPPED,
      L_OLD_SPOILED,L_OLD_OUTSTANDING,L_OLD_CLEARED,L_OLD_CLEARED_DLR,L_OLD_OUTSTANDING_DLR,L_OLD_REFUND_PAYMENTS,L_OLD_REFUND_PAYMENTS_DLR
      FROM
        AP_INVOICE_KEY_IND INV,
        AP_VENDOR_KEY_IND VEN,
        AP_PAYMENT_KEY_IND PAY
      WHERE INV.PERIOD_NAME = VEN.PERIOD_NAME
        AND INV.PERIOD_NAME = PAY.PERIOD_NAME
        AND INV.PERIOD_NAME = C_PRIOR_PERIOD_NAME;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        /*SRW.MESSAGE('103'
                   ,'No data found for prior period.')*/NULL;
        L_PRIOR_PERIOD_EXISTS := 'N';
    END;
    C_OLD_INVOICES := L_OLD_INVOICES;
    C_OLD_TOTAL_DLR := L_OLD_TOTAL_DLR;
    C_OLD_DISTS := L_OLD_DISTS;
    C_OLD_BATCHES := L_OLD_BATCHES;
    C_OLD_PAYMENT_SCHEDULES := L_OLD_PAYMENT_SCHEDULES;
    C_OLD_ON_HOLD := L_OLD_ON_HOLD;
    C_OLD_HOLD_DLR := L_OLD_HOLD_DLR;
    C_OLD_COUNT := L_OLD_COUNT;
    C_OLD_AMOUNT := L_OLD_AMOUNT;
    C_OLD_MH_COUNT := L_OLD_MH_COUNT;
    C_OLD_MH_AMOUNT := L_OLD_MH_AMOUNT;
    C_OLD_VENDORS := L_OLD_VENDORS;
    C_OLD_SITES := L_OLD_SITES;
    C_INACTIVE := L_INACTIVE;
    C_ONE_TIME := L_ONE_TIME;
    C_TYPE_1099_VENDORS := L_TYPE_1099_VENDORS;
    C_VENDORS_HELD := L_VENDORS_HELD;
    C_OLD_INVOICES_PAID := L_OLD_INVOICES_PAID;
    C_OLD_AUTO_CHECKS := L_OLD_AUTO_CHECKS;
    C_OLD_MANUAL_CHECKS := L_OLD_MANUAL_CHECKS;
    C_OLD_AUTO_CHECKS_DLR := L_OLD_AUTO_CHECKS_DLR;
    C_OLD_MANUAL_CHECKS_DLR := L_OLD_MANUAL_CHECKS_DLR;
    C_OLD_DISCOUNTS := L_OLD_DISCOUNTS;
    C_OLD_DISCOUNT_DLR := L_OLD_DISCOUNT_DLR;
    C_OLD_VOID := L_OLD_VOID;
    C_OLD_STOPPED := L_OLD_STOPPED;
    C_OLD_SPOILED := L_OLD_SPOILED;
    C_OLD_OUTSTANDING := L_OLD_OUTSTANDING;
    C_OLD_CLEARED := L_OLD_CLEARED;
    C_OLD_CLEARED_DLR := L_OLD_CLEARED_DLR;
    C_PRIOR_OLD_VENDOR_SITES := L_PRIOR_OLD_VENDOR_SITES;
    C_PRIOR_VENDORS_UPDATED := L_PRIOR_VENDORS_UPDATED;
    C_PRIOR_SITES_UPDATED := L_PRIOR_SITES_UPDATED;
    C_OLD_OUTSTANDING_DLR := L_OLD_OUTSTANDING_DLR;
    C_OLD_REFUND_PAYMENTS := L_OLD_REFUND_PAYMENTS;
    C_OLD_REFUND_PAYMENTS_DLR := L_OLD_REFUND_PAYMENTS_DLR;
    C_OLD_LINES := L_OLD_LINES;
    C_OLD_LINES_VAR_COUNT := L_OLD_VAR_LINES_COUNT;
    C_OLD_LINES_VAR_AMOUNT := L_OLD_VAR_LINES_AMOUNT;
    C_OLD_DISTS_VAR_COUNT := L_OLD_VAR_DISTS_COUNT;
    C_OLD_DISTS_VAR_AMOUNT := L_OLD_VAR_DISTS_AMOUNT;
    C_PRIOR_PERIOD_EXISTS := L_PRIOR_PERIOD_EXISTS;
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END PRIOR_PERIOD;

  FUNCTION CALCULATE_STATISTICS RETURN BOOLEAN IS
    L_INVOICE_COUNT NUMBER := 0;
    L_AVERAGE_SITES NUMBER;
    L_AVERAGE_LINES NUMBER;
    L_AVERAGE_PAY_INV NUMBER;
    L_AVERAGE_PAY_CHK NUMBER;
    L_AVERAGE_MH NUMBER;
    L_TOTAL_SITE NUMBER := 0;
    L_AVERAGE_DISTS NUMBER;
    L_TOTAL_NEW_EXCEPTIONS NUMBER := 0;
    L_TOTAL_OLD_EXCEPTIONS NUMBER := 0;
    L_TOTAL_TOTAL_EXCEPTIONS NUMBER := 0;
    L_TOTAL_NEW_EXCEPTIONS_DLR NUMBER := 0;
    L_TOTAL_OLD_EXCEPTIONS_DLR NUMBER := 0;
    L_TOTAL_TOTAL_EXCEPTIONS_DLR NUMBER := 0;
    L_TOTAL_NEW_CHECKS NUMBER := 0;
    L_TOTAL_OLD_CHECKS NUMBER := 0;
    L_TOTAL_TOTAL_CHECKS NUMBER := 0;
    L_TOTAL_NEW_CHECKS_DLR NUMBER := 0;
    L_TOTAL_OLD_CHECKS_DLR NUMBER := 0;
    L_TOTAL_TOTAL_CHECKS_DLR NUMBER := 0;
    L_TOTAL_ADDITIONAL_SITES NUMBER := 0;
    L_TOTAL_VENDORS_UPDATED NUMBER := 0;
    L_TOTAL_SITES_UPDATED NUMBER := 0;
    L_PERCENT_VENDORS NUMBER(38,2);
    L_PERCENT_SITES NUMBER(38,2);
    L_PERCENT_ONE_TIME NUMBER(38,2);
    L_PERCENT_1099 NUMBER(38,2);
    L_PERCENT_VENDORS_HELD NUMBER(38,2);
    L_PERCENT_INACTIVE NUMBER(38,2);
    L_PERCENT_INVOICES NUMBER(38,2);
    L_PERCENT_INVOICES_DLR NUMBER(38,2);
    L_PERCENT_MATCHED NUMBER(38,2);
    L_PERCENT_MATCHED_DLR NUMBER(38,2);
    L_PERCENT_DISTS NUMBER(38,2);
    L_PERCENT_LINES NUMBER(38,2);
    L_PERCENT_SCHEDULED NUMBER(38,2);
    L_PERCENT_BATCHES NUMBER(38,2);
    L_PERCENT_DIST_VARS NUMBER(38,2);
    L_PERCENT_LINE_VARS NUMBER(38,2);
    L_PERCENT_DIST_VARS_DLR NUMBER(38,2);
    L_PERCENT_LINE_VARS_DLR NUMBER(38,2);
    L_PERCENT_INVOICE_HOLDS NUMBER(38,2);
    L_PERCENT_INVOICE_HOLDS_DLR NUMBER(38,2);
    L_PERCENT_MH NUMBER(38,2);
    L_PERCENT_MH_DLR NUMBER(38,2);
    L_PERCENT_MAN_CHECKS NUMBER(38,2);
    L_PERCENT_MAN_CHECKS_DLR NUMBER(38,2);
    L_PERCENT_AUTO_CHECKS NUMBER(38,2);
    L_PERCENT_AUTO_CHECKS_DLR NUMBER(38,2);
    L_PERCENT_REFUND_CHECKS NUMBER(38,2);
    L_PERCENT_REFUND_CHECKS_DLR NUMBER(38,2);
    L_PERCENT_PAID_INV NUMBER(38,2);
    L_PERCENT_DISCS NUMBER(38,2);
    L_PERCENT_DISCS_DLR NUMBER(38,2);
    L_PERCENT_VOIDED NUMBER(38,2);
    L_PERCENT_STOPPED NUMBER(38,2);
    L_PERCENT_SPOILED NUMBER(38,2);
    L_PERCENT_OUTSTANDING NUMBER(38,2);
    L_PERCENT_OUTSTANDING_DLR NUMBER(38,2);
    L_PERCENT_CLEARED NUMBER(38,2);
    L_PERCENT_CLEARED_DLR NUMBER(38,2);
    L_PERCENT_ADDITIONAL_SITES NUMBER(38,2);
    L_PERCENT_VENDORS_UPDATED NUMBER(38,2);
    L_PERCENT_SITES_UPDATED NUMBER(38,2);
    L_PERCENT_TOTAL_EXCEPTIONS NUMBER(38,2);
    L_PERCENT_TOTAL_EXCEPTIONS_DLR NUMBER(38,2);
    L_PERCENT_TOTAL_CHECKS NUMBER(38,2);
    L_PERCENT_TOTAL_CHECKS_DLR NUMBER(38,2);
  BEGIN
    /*SRW.REFERENCE(C_TOTAL_VENDORS)*/NULL;
    /*SRW.REFERENCE(C_TOTAL_INACTIVE)*/NULL;
    /*SRW.REFERENCE(C_TOTAL_ONE_TIME)*/NULL;
    /*SRW.REFERENCE(C_TOTAL_1099)*/NULL;
    /*SRW.REFERENCE(C_TOTAL_VOIDED)*/NULL;
    /*SRW.REFERENCE(C_TOTAL_DISTS)*/NULL;
    /*SRW.REFERENCE(C_TOTAL_BATCHES)*/NULL;
    /*SRW.REFERENCE(C_TOTAL_INVOICES)*/NULL;
    /*SRW.REFERENCE(C_TOTAL_INVOICES_DLR)*/NULL;
    /*SRW.REFERENCE(C_TOTAL_INVOICE_HOLDS)*/NULL;
    /*SRW.REFERENCE(C_TOTAL_INVOICE_HOLDS_DLR)*/NULL;
    /*SRW.REFERENCE(C_TOTAL_CLEARED)*/NULL;
    /*SRW.REFERENCE(C_TOTAL_CLEARED_DLR)*/NULL;
    /*SRW.REFERENCE(C_STOPPED)*/NULL;
    /*SRW.REFERENCE(C_TOTAL_MAN_CHECKS)*/NULL;
    /*SRW.REFERENCE(C_TOTAL_MAN_CHECKS_DLR)*/NULL;
    /*SRW.REFERENCE(C_TOTAL_AUTO_CHECKS)*/NULL;
    /*SRW.REFERENCE(C_TOTAL_AUTO_CHECKS_DLR)*/NULL;
    /*SRW.REFERENCE(C_TOTAL_SPOILED)*/NULL;
    /*SRW.REFERENCE(C_TOTAL_OUTSTANDING)*/NULL;
    /*SRW.REFERENCE(C_TOTAL_PAID_INV)*/NULL;
    /*SRW.REFERENCE(C_TOTAL_DISCS_DLR)*/NULL;
    /*SRW.REFERENCE(C_TOTAL_DISCS)*/NULL;
    /*SRW.REFERENCE(C_TOTAL_SCHEDULED)*/NULL;
    /*SRW.REFERENCE(C_TOTAL_SITES)*/NULL;
    /*SRW.REFERENCE(C_TOTAL_OUTSTANDING_DLR)*/NULL;
    /*SRW.REFERENCE(C_TOTAL_REFUND_CHECKS)*/NULL;
    /*SRW.REFERENCE(C_TOTAL_REFUND_CHECKS_DLR)*/NULL;
    /*SRW.REFERENCE(C_TOTAL_LINES)*/NULL;
    /*SRW.REFERENCE(C_TOTAL_MH)*/NULL;
    /*SRW.REFERENCE(C_TOTAL_MH_DLR)*/NULL;
    /*SRW.REFERENCE(C_MH_COUNT)*/NULL;
    /*SRW.REFERENCE(C_MH_AMOUNT)*/NULL;
    /*SRW.REFERENCE(C_TOTAL_MATCHED)*/NULL;
    /*SRW.REFERENCE(C_TOTAL_MATCHED_DLR)*/NULL;
    /*SRW.REFERENCE(C_NEW_COUNT)*/NULL;
    /*SRW.REFERENCE(C_NEW_AMOUNT)*/NULL;
    /*SRW.REFERENCE(C_DIST_TOTAL_VARS)*/NULL;
    /*SRW.REFERENCE(C_DIST_TOTAL_VARS_DLR)*/NULL;
    /*SRW.REFERENCE(C_DIST_VAR_COUNT)*/NULL;
    /*SRW.REFERENCE(C_DIST_VAR_AMOUNT)*/NULL;
    /*SRW.REFERENCE(C_LINE_TOTAL_VARS)*/NULL;
    /*SRW.REFERENCE(C_LINE_TOTAL_VARS_DLR)*/NULL;
    /*SRW.REFERENCE(C_LINE_VAR_COUNT)*/NULL;
    /*SRW.REFERENCE(C_LINE_VAR_AMOUNT)*/NULL;
    /*SRW.REFERENCE(C_VOID)*/NULL;
    /*SRW.REFERENCE(C_CLEARED)*/NULL;
    /*SRW.REFERENCE(C_CLEARED_DLR)*/NULL;
    /*SRW.REFERENCE(C_STOPPED)*/NULL;
    /*SRW.REFERENCE(C_MANUAL_CHECKS)*/NULL;
    /*SRW.REFERENCE(C_MANUAL_CHECKS_DLR)*/NULL;
    /*SRW.REFERENCE(C_AUTO_CHECKS)*/NULL;
    /*SRW.REFERENCE(C_AUTO_CHECKS_DLR)*/NULL;
    /*SRW.REFERENCE(C_NEW_SPOILED)*/NULL;
    /*SRW.REFERENCE(C_NEW_OUTSTANDING)*/NULL;
    /*SRW.REFERENCE(C_MANUAL_PAYMENTS)*/NULL;
    /*SRW.REFERENCE(C_MANUAL_PAYMENTS_DLR)*/NULL;
    /*SRW.REFERENCE(C_AUTO_PAYMENTS)*/NULL;
    /*SRW.REFERENCE(C_AUTO_PAYMENTS_DLR)*/NULL;
    /*SRW.REFERENCE(C_INVOICES)*/NULL;
    /*SRW.REFERENCE(C_DISCOUNT_DLR)*/NULL;
    /*SRW.REFERENCE(C_DISCOUNTS)*/NULL;
    /*SRW.REFERENCE(C_NEW_INVOICES)*/NULL;
    /*SRW.REFERENCE(C_TOTAL_DLR)*/NULL;
    /*SRW.REFERENCE(C_BATCHES)*/NULL;
    /*SRW.REFERENCE(C_NEW_ON_HOLD)*/NULL;
    /*SRW.REFERENCE(C_NEW_HOLD_DLR)*/NULL;
    /*SRW.REFERENCE(C_PAYMENT_SCHEDULES)*/NULL;
    /*SRW.REFERENCE(C_NEW_DISTS)*/NULL;
    /*SRW.REFERENCE(C_NEW_VENDORS)*/NULL;
    /*SRW.REFERENCE(C_NEW_INACTIVE)*/NULL;
    /*SRW.REFERENCE(C_NEW_ONE_TIME)*/NULL;
    /*SRW.REFERENCE(C_NEW_TYPE_1099_VENDORS)*/NULL;
    /*SRW.REFERENCE(C_OLD_VENDOR_SITES)*/NULL;
    /*SRW.REFERENCE(C_TOTAL_VENDORS_HELD)*/NULL;
    /*SRW.REFERENCE(C_NEW_VENDOR_SITES)*/NULL;
    /*SRW.REFERENCE(C_NEW_VENDORS_HELD)*/NULL;
    /*SRW.REFERENCE(C_UPDATED_VENDORS)*/NULL;
    /*SRW.REFERENCE(C_UPDATED_SITES)*/NULL;
    /*SRW.REFERENCE(C_NEW_OUTSTANDING_DLR)*/NULL;
    /*SRW.REFERENCE(C_NEW_REFUND_PAYMENTS)*/NULL;
    /*SRW.REFERENCE(C_NEW_REFUND_PAYMENTS_DLR)*/NULL;
    /*SRW.REFERENCE(C_NEW_LINES)*/NULL;
    /*SRW.REFERENCE(C_OLD_INVOICES)*/NULL;
    /*SRW.REFERENCE(C_OLD_TOTAL_DLR)*/NULL;
    /*SRW.REFERENCE(C_OLD_DISTS)*/NULL;
    /*SRW.REFERENCE(C_OLD_BATCHES)*/NULL;
    /*SRW.REFERENCE(C_OLD_DISTS_VAR_COUNT)*/NULL;
    /*SRW.REFERENCE(C_OLD_DISTS_VAR_AMOUNT)*/NULL;
    /*SRW.REFERENCE(C_OLD_PAYMENT_SCHEDULES)*/NULL;
    /*SRW.REFERENCE(C_OLD_ON_HOLD)*/NULL;
    /*SRW.REFERENCE(C_OLD_HOLD_DLR)*/NULL;
    /*SRW.REFERENCE(C_OLD_COUNT)*/NULL;
    /*SRW.REFERENCE(C_OLD_AMOUNT)*/NULL;
    /*SRW.REFERENCE(C_OLD_MH_COUNT)*/NULL;
    /*SRW.REFERENCE(C_OLD_MH_AMOUNT)*/NULL;
    /*SRW.REFERENCE(C_OLD_VENDORS)*/NULL;
    /*SRW.REFERENCE(C_OLD_SITES)*/NULL;
    /*SRW.REFERENCE(C_INACTIVE)*/NULL;
    /*SRW.REFERENCE(C_ONE_TIME)*/NULL;
    /*SRW.REFERENCE(C_TYPE_1099_VENDORS)*/NULL;
    /*SRW.REFERENCE(C_VENDORS_HELD)*/NULL;
    /*SRW.REFERENCE(C_OLD_INVOICES_PAID)*/NULL;
    /*SRW.REFERENCE(C_OLD_AUTO_CHECKS)*/NULL;
    /*SRW.REFERENCE(C_OLD_MANUAL_CHECKS)*/NULL;
    /*SRW.REFERENCE(C_OLD_AUTO_CHECKS_DLR)*/NULL;
    /*SRW.REFERENCE(C_OLD_MANUAL_CHECKS_DLR)*/NULL;
    /*SRW.REFERENCE(C_OLD_DISCOUNTS)*/NULL;
    /*SRW.REFERENCE(C_OLD_DISCOUNT_DLR)*/NULL;
    /*SRW.REFERENCE(C_OLD_VOID)*/NULL;
    /*SRW.REFERENCE(C_OLD_STOPPED)*/NULL;
    /*SRW.REFERENCE(C_OLD_SPOILED)*/NULL;
    /*SRW.REFERENCE(C_OLD_OUTSTANDING)*/NULL;
    /*SRW.REFERENCE(C_OLD_CLEARED)*/NULL;
    /*SRW.REFERENCE(C_OLD_CLEARED_DLR)*/NULL;
    /*SRW.REFERENCE(C_PRIOR_OLD_VENDOR_SITES)*/NULL;
    /*SRW.REFERENCE(C_PRIOR_VENDORS_UPDATED)*/NULL;
    /*SRW.REFERENCE(C_PRIOR_SITES_UPDATED)*/NULL;
    /*SRW.REFERENCE(C_OLD_OUTSTANDING_DLR)*/NULL;
    /*SRW.REFERENCE(C_OLD_REFUND_PAYMENTS)*/NULL;
    /*SRW.REFERENCE(C_OLD_REFUND_PAYMENTS_DLR)*/NULL;
    /*SRW.REFERENCE(C_OLD_LINES)*/NULL;
    /*SRW.REFERENCE(C_OLD_LINES_VAR_COUNT)*/NULL;
    /*SRW.REFERENCE(C_OLD_LINES_VAR_AMOUNT)*/NULL;
    L_TOTAL_NEW_EXCEPTIONS := C_DIST_VAR_COUNT + C_LINE_VAR_COUNT + C_NEW_ON_HOLD + C_MH_COUNT;
    L_TOTAL_OLD_EXCEPTIONS := C_OLD_DISTS_VAR_COUNT + C_OLD_LINES_VAR_COUNT + C_OLD_ON_HOLD + C_OLD_MH_COUNT;
    L_TOTAL_TOTAL_EXCEPTIONS := C_DIST_TOTAL_VARS + C_LINE_TOTAL_VARS + C_TOTAL_INVOICE_HOLDS + C_TOTAL_MH;
    L_TOTAL_NEW_EXCEPTIONS_DLR := C_DIST_VAR_AMOUNT + C_LINE_VAR_AMOUNT + C_NEW_HOLD_DLR + C_MH_AMOUNT;
    L_TOTAL_OLD_EXCEPTIONS_DLR := C_OLD_DISTS_VAR_AMOUNT + C_OLD_LINES_VAR_AMOUNT + C_OLD_HOLD_DLR + C_OLD_MH_AMOUNT;
    L_TOTAL_TOTAL_EXCEPTIONS_DLR := C_DIST_TOTAL_VARS_DLR + C_LINE_TOTAL_VARS_DLR + C_TOTAL_INVOICE_HOLDS_DLR + C_TOTAL_MH_DLR;
    L_TOTAL_NEW_CHECKS := C_MANUAL_CHECKS + C_AUTO_CHECKS + C_NEW_REFUND_PAYMENTS;
    L_TOTAL_OLD_CHECKS := C_OLD_MANUAL_CHECKS + C_OLD_AUTO_CHECKS + C_OLD_REFUND_PAYMENTS;
    L_TOTAL_TOTAL_CHECKS := C_TOTAL_MAN_CHECKS + C_TOTAL_AUTO_CHECKS + C_TOTAL_REFUND_CHECKS;
    L_TOTAL_NEW_CHECKS_DLR := C_MANUAL_CHECKS_DLR + C_AUTO_CHECKS_DLR + C_NEW_REFUND_PAYMENTS_DLR;
    L_TOTAL_OLD_CHECKS_DLR := C_OLD_MANUAL_CHECKS_DLR + C_OLD_AUTO_CHECKS_DLR + C_OLD_REFUND_PAYMENTS_DLR;
    L_TOTAL_TOTAL_CHECKS_DLR := C_TOTAL_MAN_CHECKS_DLR + C_TOTAL_AUTO_CHECKS_DLR + C_TOTAL_REFUND_CHECKS_DLR;
    L_TOTAL_ADDITIONAL_SITES := C_OLD_VENDOR_SITES + C_PRIOR_OLD_VENDOR_SITES;
    L_TOTAL_VENDORS_UPDATED := C_UPDATED_VENDORS + C_PRIOR_VENDORS_UPDATED;
    L_TOTAL_SITES_UPDATED := C_UPDATED_SITES + C_PRIOR_SITES_UPDATED;
    IF C_OLD_VENDORS <> 0 THEN
      L_PERCENT_VENDORS := ((C_NEW_VENDORS - C_OLD_VENDORS) / C_OLD_VENDORS) * 100;
    END IF;
    IF C_OLD_SITES <> 0 THEN
      L_PERCENT_SITES := ((C_NEW_VENDOR_SITES - C_OLD_SITES) / C_OLD_SITES) * 100;
    END IF;
    IF C_PRIOR_OLD_VENDOR_SITES <> 0 THEN
      L_PERCENT_ADDITIONAL_SITES := ((C_OLD_VENDOR_SITES - C_PRIOR_OLD_VENDOR_SITES) / C_PRIOR_OLD_VENDOR_SITES) * 100;
    END IF;
    IF C_PRIOR_VENDORS_UPDATED <> 0 THEN
      L_PERCENT_VENDORS_UPDATED := ((C_UPDATED_VENDORS - C_PRIOR_VENDORS_UPDATED) / C_PRIOR_VENDORS_UPDATED) * 100;
    END IF;
    IF C_PRIOR_SITES_UPDATED <> 0 THEN
      L_PERCENT_SITES_UPDATED := ((C_UPDATED_SITES - C_PRIOR_SITES_UPDATED) / C_PRIOR_SITES_UPDATED) * 100;
    END IF;
    IF C_OLD_REFUND_PAYMENTS <> 0 THEN
      L_PERCENT_REFUND_CHECKS := ((C_NEW_REFUND_PAYMENTS - C_OLD_REFUND_PAYMENTS) / C_OLD_REFUND_PAYMENTS) * 100;
    END IF;
    IF C_OLD_REFUND_PAYMENTS_DLR <> 0 THEN
      L_PERCENT_REFUND_CHECKS_DLR := ((C_NEW_REFUND_PAYMENTS_DLR - C_OLD_REFUND_PAYMENTS_DLR) / C_OLD_REFUND_PAYMENTS_DLR) * 100;
    END IF;
    IF C_OLD_OUTSTANDING_DLR <> 0 THEN
      L_PERCENT_OUTSTANDING_DLR := ((C_NEW_OUTSTANDING_DLR - C_OLD_OUTSTANDING_DLR) / C_OLD_OUTSTANDING_DLR) * 100;
    END IF;
    IF C_ONE_TIME <> 0 THEN
      L_PERCENT_ONE_TIME := ((C_NEW_ONE_TIME - C_ONE_TIME) / C_ONE_TIME) * 100;
    END IF;
    IF C_TYPE_1099_VENDORS <> 0 THEN
      L_PERCENT_1099 := ((C_NEW_TYPE_1099_VENDORS - C_TYPE_1099_VENDORS) / C_TYPE_1099_VENDORS) * 100;
    END IF;
    IF C_VENDORS_HELD <> 0 THEN
      L_PERCENT_VENDORS_HELD := ((C_NEW_VENDORS_HELD - C_VENDORS_HELD) / C_VENDORS_HELD) * 100;
    END IF;
    IF C_INACTIVE <> 0 THEN
      L_PERCENT_INACTIVE := ((C_NEW_INACTIVE - C_INACTIVE) / C_INACTIVE) * 100;
    END IF;
    IF C_OLD_INVOICES <> 0 THEN
      L_PERCENT_INVOICES := ((C_NEW_INVOICES - C_OLD_INVOICES) / C_OLD_INVOICES) * 100;
    END IF;
    IF C_OLD_TOTAL_DLR <> 0 THEN
      L_PERCENT_INVOICES_DLR := ((C_TOTAL_DLR - C_OLD_TOTAL_DLR) / C_OLD_TOTAL_DLR) * 100;
    END IF;
    IF C_OLD_COUNT <> 0 THEN
      L_PERCENT_MATCHED := ((C_NEW_COUNT - C_OLD_COUNT) / C_OLD_COUNT) * 100;
    END IF;
    IF C_OLD_AMOUNT <> 0 THEN
      L_PERCENT_MATCHED_DLR := ((C_NEW_AMOUNT - C_OLD_AMOUNT) / C_OLD_AMOUNT) * 100;
    END IF;
    IF C_OLD_DISTS <> 0 THEN
      L_PERCENT_DISTS := ((C_NEW_DISTS - C_OLD_DISTS) / C_OLD_DISTS) * 100;
    END IF;
    IF C_OLD_LINES <> 0 THEN
      L_PERCENT_LINES := ((C_NEW_LINES - C_OLD_LINES) / C_OLD_LINES) * 100;
    END IF;
    IF C_OLD_PAYMENT_SCHEDULES <> 0 THEN
      L_PERCENT_SCHEDULED := ((C_PAYMENT_SCHEDULES - C_OLD_PAYMENT_SCHEDULES) / C_OLD_PAYMENT_SCHEDULES) * 100;
    END IF;
    IF C_OLD_BATCHES <> 0 THEN
      L_PERCENT_BATCHES := ((C_BATCHES - C_OLD_BATCHES) / C_OLD_BATCHES) * 100;
    END IF;
    IF C_OLD_LINES_VAR_COUNT <> 0 THEN
      L_PERCENT_LINE_VARS := ((C_LINE_VAR_COUNT - C_OLD_LINES_VAR_COUNT) / C_OLD_LINES_VAR_COUNT) * 100;
    END IF;
    IF C_OLD_LINES_VAR_AMOUNT <> 0 THEN
      L_PERCENT_LINE_VARS_DLR := ((C_LINE_VAR_AMOUNT - C_OLD_LINES_VAR_AMOUNT) / C_OLD_LINES_VAR_AMOUNT) * 100;
    END IF;
    IF C_OLD_DISTS_VAR_COUNT <> 0 THEN
      L_PERCENT_DIST_VARS := ((C_DIST_VAR_COUNT - C_OLD_DISTS_VAR_COUNT) / C_OLD_DISTS_VAR_COUNT) * 100;
    END IF;
    IF C_OLD_DISTS_VAR_AMOUNT <> 0 THEN
      L_PERCENT_DIST_VARS_DLR := ((C_DIST_VAR_AMOUNT - C_OLD_DISTS_VAR_AMOUNT) / C_OLD_DISTS_VAR_AMOUNT) * 100;
    END IF;
    IF C_OLD_ON_HOLD <> 0 THEN
      L_PERCENT_INVOICE_HOLDS := ((C_NEW_ON_HOLD - C_OLD_ON_HOLD) / C_OLD_ON_HOLD) * 100;
    END IF;
    IF C_OLD_HOLD_DLR <> 0 THEN
      L_PERCENT_INVOICE_HOLDS_DLR := ((C_NEW_HOLD_DLR - C_OLD_HOLD_DLR) / C_OLD_HOLD_DLR) * 100;
    END IF;
    IF C_OLD_MH_COUNT <> 0 THEN
      L_PERCENT_MH := ((C_MH_COUNT - C_OLD_MH_COUNT) / C_OLD_MH_COUNT) * 100;
    END IF;
    IF C_OLD_MH_AMOUNT <> 0 THEN
      L_PERCENT_MH_DLR := ((C_MH_AMOUNT - C_OLD_MH_AMOUNT) / C_OLD_MH_AMOUNT) * 100;
    END IF;
    IF C_OLD_MANUAL_CHECKS <> 0 THEN
      L_PERCENT_MAN_CHECKS := ((C_MANUAL_CHECKS - C_OLD_MANUAL_CHECKS) / C_OLD_MANUAL_CHECKS) * 100;
    END IF;
    IF C_OLD_MANUAL_CHECKS_DLR <> 0 THEN
      L_PERCENT_MAN_CHECKS_DLR := ((C_MANUAL_CHECKS_DLR - C_OLD_MANUAL_CHECKS_DLR) / C_OLD_MANUAL_CHECKS_DLR) * 100;
    END IF;
    IF C_OLD_AUTO_CHECKS <> 0 THEN
      L_PERCENT_AUTO_CHECKS := ((C_AUTO_CHECKS - C_OLD_AUTO_CHECKS) / C_OLD_AUTO_CHECKS) * 100;
    END IF;
    IF C_OLD_AUTO_CHECKS_DLR <> 0 THEN
      L_PERCENT_AUTO_CHECKS_DLR := ((C_AUTO_CHECKS_DLR - C_OLD_AUTO_CHECKS_DLR) / C_OLD_AUTO_CHECKS_DLR) * 100;
    END IF;
    IF C_OLD_INVOICES_PAID <> 0 THEN
      L_PERCENT_PAID_INV := ((C_INVOICES - C_OLD_INVOICES_PAID) / C_OLD_INVOICES_PAID) * 100;
    END IF;
    IF C_OLD_DISCOUNTS <> 0 THEN
      L_PERCENT_DISCS := ((C_DISCOUNTS - C_OLD_DISCOUNTS) / C_OLD_DISCOUNTS) * 100;
    END IF;
    IF C_OLD_DISCOUNT_DLR <> 0 THEN
      L_PERCENT_DISCS_DLR := ((C_DISCOUNT_DLR - C_OLD_DISCOUNT_DLR) / C_OLD_DISCOUNT_DLR) * 100;
    END IF;
    IF C_OLD_VOID <> 0 THEN
      L_PERCENT_VOIDED := ((C_VOID - C_OLD_VOID) / C_OLD_VOID) * 100;
    END IF;
    IF C_OLD_STOPPED <> 0 THEN
      L_PERCENT_STOPPED := ((C_STOPPED - C_OLD_STOPPED) / C_OLD_STOPPED) * 100;
    END IF;
    IF C_OLD_SPOILED <> 0 THEN
      L_PERCENT_SPOILED := ((C_NEW_SPOILED - C_OLD_SPOILED) / C_OLD_SPOILED) * 100;
    END IF;
    IF C_OLD_OUTSTANDING <> 0 THEN
      L_PERCENT_OUTSTANDING := ((C_NEW_OUTSTANDING - C_OLD_OUTSTANDING) / C_OLD_OUTSTANDING) * 100;
    END IF;
    IF C_OLD_CLEARED <> 0 THEN
      L_PERCENT_CLEARED := ((C_CLEARED - C_OLD_CLEARED) / C_OLD_CLEARED) * 100;
    END IF;
    IF C_OLD_CLEARED_DLR <> 0 THEN
      L_PERCENT_CLEARED_DLR := ((C_CLEARED_DLR - C_OLD_CLEARED_DLR) / C_OLD_CLEARED_DLR) * 100;
    END IF;
    IF L_TOTAL_OLD_EXCEPTIONS <> 0 THEN
      L_PERCENT_TOTAL_EXCEPTIONS := ((L_TOTAL_NEW_EXCEPTIONS - L_TOTAL_OLD_EXCEPTIONS) / L_TOTAL_OLD_EXCEPTIONS) * 100;
    END IF;
    IF L_TOTAL_OLD_EXCEPTIONS_DLR <> 0 THEN
      L_PERCENT_TOTAL_EXCEPTIONS_DLR := ((L_TOTAL_NEW_EXCEPTIONS_DLR - L_TOTAL_OLD_EXCEPTIONS_DLR) / L_TOTAL_OLD_EXCEPTIONS_DLR) * 100;
    END IF;
    IF L_TOTAL_OLD_CHECKS <> 0 THEN
      L_PERCENT_TOTAL_CHECKS := ((L_TOTAL_NEW_CHECKS - L_TOTAL_OLD_CHECKS) / L_TOTAL_OLD_CHECKS) * 100;
    END IF;
    IF L_TOTAL_OLD_CHECKS_DLR <> 0 THEN
      L_PERCENT_TOTAL_CHECKS_DLR := ((L_TOTAL_NEW_CHECKS_DLR - L_TOTAL_OLD_CHECKS_DLR) / L_TOTAL_OLD_CHECKS_DLR) * 100;
    END IF;
    L_TOTAL_SITE := C_TOTAL_SITES + C_OLD_VENDOR_SITES;
    IF C_TOTAL_VENDORS <> 0 THEN
      L_AVERAGE_SITES := C_TOTAL_SITES / C_TOTAL_VENDORS;
    END IF;
    IF C_TOTAL_INVOICES <> 0 THEN
      L_AVERAGE_DISTS := C_TOTAL_DISTS / C_TOTAL_INVOICES;
    END IF;
    IF C_TOTAL_INVOICES <> 0 THEN
      L_AVERAGE_LINES := C_TOTAL_LINES / C_TOTAL_INVOICES;
    END IF;
    IF C_TOTAL_INVOICES <> 0 THEN
      L_AVERAGE_PAY_INV := C_TOTAL_SCHEDULED / C_TOTAL_INVOICES;
    END IF;
    IF L_TOTAL_TOTAL_CHECKS <> 0 THEN
      L_AVERAGE_PAY_CHK := C_TOTAL_PAID_INV / L_TOTAL_TOTAL_CHECKS;
    END IF;
    SELECT
      count(( INVOICE_ID ))
    INTO L_INVOICE_COUNT
    FROM
      AP_HOLDS H,
      AP_HOLD_CODES HC
    WHERE H.RELEASE_LOOKUP_CODE is null
      AND H.HOLD_LOOKUP_CODE = HC.HOLD_LOOKUP_CODE
      AND HC.HOLD_TYPE = 'MATCHING HOLD REASON';
    IF L_INVOICE_COUNT <> 0 THEN
      L_AVERAGE_MH := C_TOTAL_MH / L_INVOICE_COUNT;
    END IF;
    C_AVERAGE_SITES := L_AVERAGE_SITES;
    C_AVERAGE_LINES := L_AVERAGE_LINES;
    C_AVERAGE_DISTS := L_AVERAGE_DISTS;
    C_AVERAGE_PAY_INV := L_AVERAGE_PAY_INV;
    C_AVERAGE_PAY_CHK := L_AVERAGE_PAY_CHK;
    C_AVERAGE_MH := L_AVERAGE_MH;
    C_TOTAL_SITE := L_TOTAL_SITE;
    C_TOTAL_NEW_EXCEPTIONS := L_TOTAL_NEW_EXCEPTIONS;
    C_TOTAL_OLD_EXCEPTIONS := L_TOTAL_OLD_EXCEPTIONS;
    C_TOTAL_TOTAL_EXCEPTIONS := L_TOTAL_TOTAL_EXCEPTIONS;
    C_TOTAL_NEW_EXCEPTIONS_DLR := L_TOTAL_NEW_EXCEPTIONS_DLR;
    C_TOTAL_OLD_EXCEPTIONS_DLR := L_TOTAL_OLD_EXCEPTIONS_DLR;
    C_TOTAL_TOTAL_EXCEPTIONS_DLR := L_TOTAL_TOTAL_EXCEPTIONS_DLR;
    C_TOTAL_NEW_CHECKS := L_TOTAL_NEW_CHECKS;
    C_TOTAL_OLD_CHECKS := L_TOTAL_OLD_CHECKS;
    C_TOTAL_TOTAL_CHECKS := L_TOTAL_TOTAL_CHECKS;
    C_TOTAL_NEW_CHECKS_DLR := L_TOTAL_NEW_CHECKS_DLR;
    C_TOTAL_OLD_CHECKS_DLR := L_TOTAL_OLD_CHECKS_DLR;
    C_TOTAL_TOTAL_CHECKS_DLR := L_TOTAL_TOTAL_CHECKS_DLR;
    C_TOTAL_ADDITIONAL_SITES := L_TOTAL_ADDITIONAL_SITES;
    C_TOTAL_VENDORS_UPDATED := L_TOTAL_VENDORS_UPDATED;
    C_TOTAL_SITES_UPDATED := L_TOTAL_SITES_UPDATED;
    C_PERCENT_VENDORS := L_PERCENT_VENDORS;
    C_PERCENT_SITES := L_PERCENT_SITES;
    C_PERCENT_ONE_TIME := L_PERCENT_ONE_TIME;
    C_PERCENT_1099 := L_PERCENT_1099;
    C_PERCENT_VENDORS_HELD := L_PERCENT_VENDORS_HELD;
    C_PERCENT_INACTIVE := L_PERCENT_INACTIVE;
    C_PERCENT_INVOICES := L_PERCENT_INVOICES;
    C_PERCENT_INVOICES_DLR := L_PERCENT_INVOICES_DLR;
    C_PERCENT_MATCHED := L_PERCENT_MATCHED;
    C_PERCENT_MATCHED_DLR := L_PERCENT_MATCHED_DLR;
    C_PERCENT_LINES := L_PERCENT_LINES;
    C_PERCENT_DISTS := L_PERCENT_DISTS;
    C_PERCENT_SCHEDULED := L_PERCENT_SCHEDULED;
    C_PERCENT_BATCHES := L_PERCENT_BATCHES;
    C_PERCENT_LINE_VARS := L_PERCENT_LINE_VARS;
    C_PERCENT_LINE_VARS_DLR := L_PERCENT_LINE_VARS_DLR;
    C_PERCENT_DIST_VARS := L_PERCENT_DIST_VARS;
    C_PERCENT_DIST_VARS_DLR := L_PERCENT_DIST_VARS_DLR;
    C_PERCENT_INVOICE_HOLDS := L_PERCENT_INVOICE_HOLDS;
    C_PERCENT_INVOICE_HOLDS_DLR := L_PERCENT_INVOICE_HOLDS_DLR;
    C_PERCENT_MH := L_PERCENT_MH;
    C_PERCENT_MH_DLR := L_PERCENT_MH_DLR;
    C_PERCENT_MAN_CHECKS := L_PERCENT_MAN_CHECKS;
    C_PERCENT_MAN_CHECKS_DLR := L_PERCENT_MAN_CHECKS_DLR;
    C_PERCENT_AUTO_CHECKS := L_PERCENT_AUTO_CHECKS;
    C_PERCENT_AUTO_CHECKS_DLR := L_PERCENT_AUTO_CHECKS_DLR;
    C_PERCENT_PAID_INV := L_PERCENT_PAID_INV;
    C_PERCENT_DISCS := L_PERCENT_DISCS;
    C_PERCENT_DISCS_DLR := L_PERCENT_DISCS_DLR;
    C_PERCENT_VOIDED := L_PERCENT_VOIDED;
    C_PERCENT_STOPPED := L_PERCENT_STOPPED;
    C_PERCENT_SPOILED := L_PERCENT_SPOILED;
    C_PERCENT_OUTSTANDING := L_PERCENT_OUTSTANDING;
    C_PERCENT_CLEARED := L_PERCENT_CLEARED;
    C_PERCENT_CLEARED_DLR := L_PERCENT_CLEARED_DLR;
    C_PERCENT_ADDITIONAL_SITES := L_PERCENT_ADDITIONAL_SITES;
    C_PERCENT_VENDORS_UPDATED := L_PERCENT_VENDORS_UPDATED;
    C_PERCENT_SITES_UPDATED := L_PERCENT_SITES_UPDATED;
    C_PERCENT_TOTAL_EXCEPTIONS := L_PERCENT_TOTAL_EXCEPTIONS;
    C_PERCENT_TOTAL_EXCEPTIONS_DLR := L_PERCENT_TOTAL_EXCEPTIONS_DLR;
    C_PERCENT_TOTAL_CHECKS := L_PERCENT_TOTAL_CHECKS;
    C_PERCENT_TOTAL_CHECKS_DLR := L_PERCENT_TOTAL_CHECKS_DLR;
    C_PERCENT_REFUND_CHECKS := L_PERCENT_REFUND_CHECKS;
    C_PERCENT_REFUND_CHECKS_DLR := L_PERCENT_REFUND_CHECKS_DLR;
    C_PERCENT_OUTSTANDING_DLR := L_PERCENT_OUTSTANDING_DLR;
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END CALCULATE_STATISTICS;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION CF_PER_CHANGE_AT_CURFORMULA(CS_CURR_INV_NUM IN NUMBER
                                      ,CS_PRIOR_INV_NUM IN NUMBER) RETURN NUMBER IS
    L_PERCENT NUMBER(38,2) := 0.00;
  BEGIN
    /*SRW.REFERENCE(CS_CURR_INV_NUM)*/NULL;
    /*SRW.REFERENCE(CS_PRIOR_INV_NUM)*/NULL;
    IF CS_PRIOR_INV_NUM <> 0 THEN
      L_PERCENT := ((CS_CURR_INV_NUM - CS_PRIOR_INV_NUM) / CS_PRIOR_INV_NUM) * 100;
    END IF;
    RETURN L_PERCENT;
  END CF_PER_CHANGE_AT_CURFORMULA;

  FUNCTION CF_PER_CHANGE_AT_CUR_AMTFORMUL(CS_CURR_INV_AMT IN NUMBER
                                         ,CS_PRIOR_INV_AMT IN NUMBER) RETURN NUMBER IS
    L_PERCENT NUMBER(38,2) := 0.00;
  BEGIN
    /*SRW.REFERENCE(CS_CURR_INV_AMT)*/NULL;
    /*SRW.REFERENCE(CS_PRIOR_INV_AMT)*/NULL;
    IF CS_PRIOR_INV_AMT <> 0 THEN
      L_PERCENT := ((CS_CURR_INV_AMT - CS_PRIOR_INV_AMT) / CS_PRIOR_INV_AMT) * 100;
    END IF;
    RETURN L_PERCENT;
  END CF_PER_CHANGE_AT_CUR_AMTFORMUL;

  FUNCTION CF_PERCENT_CHANGE_NUMFORMULA(C_PRIOR_NUM_OF_INVOICES IN NUMBER
                                       ,C_CURRENT_NUM_OF_INVOICES IN NUMBER) RETURN NUMBER IS
    L_PERCENT NUMBER(38,2) := 0.00;
  BEGIN
    IF C_PRIOR_NUM_OF_INVOICES <> 0 THEN
      L_PERCENT := ((C_CURRENT_NUM_OF_INVOICES - C_PRIOR_NUM_OF_INVOICES) / C_PRIOR_NUM_OF_INVOICES) * 100;
    END IF;
    RETURN L_PERCENT;
  END CF_PERCENT_CHANGE_NUMFORMULA;

  FUNCTION CF_PERCENT_CHANGE_AMOUNTFORMUL(C_PRIOR_INVOICE_AMOUNT IN NUMBER
                                         ,C_CURRENT_INVOICE_AMOUNT IN NUMBER) RETURN NUMBER IS
    L_PERCENT NUMBER(38,2) := 0.00;
  BEGIN
    IF C_PRIOR_INVOICE_AMOUNT <> 0 THEN
      L_PERCENT := ((C_CURRENT_INVOICE_AMOUNT - C_PRIOR_INVOICE_AMOUNT) / C_PRIOR_INVOICE_AMOUNT) * 100;
    END IF;
    RETURN L_PERCENT;
  END CF_PERCENT_CHANGE_AMOUNTFORMUL;

  FUNCTION CF_PERCENT_INV_USERFORMULA(CS_SUM_PRIOR_INV_NUM IN NUMBER
                                     ,CS_SUM_CURR_INV_NUM IN NUMBER) RETURN NUMBER IS
    L_PERCENT NUMBER(38,2) := 0.00;
  BEGIN
    IF CS_SUM_PRIOR_INV_NUM <> 0 THEN
      L_PERCENT := ((CS_SUM_CURR_INV_NUM - CS_SUM_PRIOR_INV_NUM) / CS_SUM_PRIOR_INV_NUM) * 100;
    END IF;
    RETURN L_PERCENT;
  END CF_PERCENT_INV_USERFORMULA;

  FUNCTION CF_PERCENT_FUNC_AMT_USERFORMUL(CS_SUM_PRIOR_FUNC_AMT IN NUMBER
                                         ,CS_SUM_CURR_FUNC_AMT IN NUMBER) RETURN NUMBER IS
    L_PERCENT NUMBER(38,2) := 0.00;
  BEGIN
    IF CS_SUM_PRIOR_FUNC_AMT <> 0 THEN
      L_PERCENT := ((CS_SUM_CURR_FUNC_AMT - CS_SUM_PRIOR_FUNC_AMT) / CS_SUM_PRIOR_FUNC_AMT) * 100;
    END IF;
    RETURN L_PERCENT;
  END CF_PERCENT_FUNC_AMT_USERFORMUL;

  FUNCTION CF_PERCENT_DISTFORMULA0006(CS_PRIOR_DIST IN NUMBER
                                     ,CS_CURR_DIST IN NUMBER) RETURN CHAR IS
    L_PERCENT NUMBER(38,2) := 0.00;
  BEGIN
    IF CS_PRIOR_DIST <> 0 THEN
      L_PERCENT := ((CS_CURR_DIST - CS_PRIOR_DIST) / CS_PRIOR_DIST) * 100;
      /*SRW.MESSAGE('10'
                 ,'L Percent Value = ' || TO_CHAR(L_PERCENT))*/NULL;
      RETURN TO_CHAR(L_PERCENT);
    ELSE
      RETURN (C_NLS_NA);
    END IF;
    /*SRW.MESSAGE('10'
               ,'L Percent Value = ' || TO_CHAR(L_PERCENT))*/NULL;
  END CF_PERCENT_DISTFORMULA0006;

  FUNCTION GET_SYSTEM_USER_NAME RETURN BOOLEAN IS
  BEGIN
    FND_MESSAGE.SET_NAME('SQLAP'
                        ,'AP_KEY_IND_SYSTEM_USER');
    C_SYSTEM_USER_NAME := FND_MESSAGE.GET;
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (TRUE);
  END GET_SYSTEM_USER_NAME;

  FUNCTION CF_DISPLAY_SOURCEFORMULA(C_INVOICE_SOURCE IN VARCHAR2) RETURN CHAR IS
    L_DISPLAY_FIELD VARCHAR2(80);
  BEGIN
    /*SRW.REFERENCE(C_INVOICE_SOURCE)*/NULL;
    SELECT
      DISPLAYED_FIELD
    INTO L_DISPLAY_FIELD
    FROM
      AP_LOOKUP_CODES
    WHERE LOOKUP_TYPE = 'SOURCE'
      AND LOOKUP_CODE = C_INVOICE_SOURCE;
    RETURN L_DISPLAY_FIELD;
  EXCEPTION
    WHEN OTHERS THEN
      /*SRW.MESSAGE('99'
                 ,'Error in Getting Display Field for the Invoice Source')*/NULL;
      RETURN C_INVOICE_SOURCE;
  END CF_DISPLAY_SOURCEFORMULA;

  FUNCTION GET_PERIOD_NAME_FROM_ROWID RETURN BOOLEAN IS
  BEGIN
    SELECT
      PERIOD_NAME
    INTO P_PERIOD_NAME
    FROM
      AP_OTHER_PERIODS
    WHERE ROWID = P_PERIOD_ROWID;
    RETURN (TRUE);
  END GET_PERIOD_NAME_FROM_ROWID;

  FUNCTION GET_WHERE_CONDITIONS RETURN BOOLEAN IS
  BEGIN
    IF P_ENTERED_BY IS NOT NULL THEN
      P_WHERE_CREATED_BY := 'AND DECODE (ai.source, ''SelfService'', fnd_user_ap_pkg.get_user_name(ai.last_updated_by),
                            						    fnd_user_ap_pkg.get_user_name(ai.created_by))
                            	= fnd_user_ap_pkg.get_user_name(' || P_ENTERED_BY || ')';
      P_WHERE_CREATED_BY_AERH := 'AND fnd_user_ap_pkg.get_user_name(aerh.last_updated_by)
                                                         	= fnd_user_ap_pkg.get_user_name(' || P_ENTERED_BY || ')';
    ELSE
      P_WHERE_CREATED_BY := ' ';
      P_WHERE_CREATED_BY_AERH := ' ';
    END IF;
    RETURN (TRUE);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END GET_WHERE_CONDITIONS;

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

  FUNCTION C_COMPANY_NAME_HEADER_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_COMPANY_NAME_HEADER;
  END C_COMPANY_NAME_HEADER_P;

  FUNCTION C_REPORT_START_DATE_P RETURN DATE IS
  BEGIN
    RETURN C_REPORT_START_DATE;
  END C_REPORT_START_DATE_P;

  FUNCTION C_NLS_YES_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_NLS_YES;
  END C_NLS_YES_P;

  FUNCTION C_NLS_NO_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_NLS_NO;
  END C_NLS_NO_P;

  FUNCTION C_NLS_ALL_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_NLS_ALL;
  END C_NLS_ALL_P;

  FUNCTION C_NLS_NO_DATA_EXISTS_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_NLS_NO_DATA_EXISTS;
  END C_NLS_NO_DATA_EXISTS_P;

  FUNCTION C_REPORT_RUN_TIME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_REPORT_RUN_TIME;
  END C_REPORT_RUN_TIME_P;

  FUNCTION C_CHART_OF_ACCOUNTS_ID_P RETURN NUMBER IS
  BEGIN
    RETURN C_CHART_OF_ACCOUNTS_ID;
  END C_CHART_OF_ACCOUNTS_ID_P;

  FUNCTION C_MODULE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_MODULE;
  END C_MODULE_P;

  FUNCTION C_PERIOD_YEAR_P RETURN NUMBER IS
  BEGIN
    RETURN C_PERIOD_YEAR;
  END C_PERIOD_YEAR_P;

  FUNCTION C_PRIOR_PERIOD_YEAR_P RETURN NUMBER IS
  BEGIN
    RETURN C_PRIOR_PERIOD_YEAR;
  END C_PRIOR_PERIOD_YEAR_P;

  FUNCTION C_PERIOD_NUM_P RETURN NUMBER IS
  BEGIN
    RETURN C_PERIOD_NUM;
  END C_PERIOD_NUM_P;

  FUNCTION C_PRIOR_PERIOD_NUM_P RETURN NUMBER IS
  BEGIN
    RETURN C_PRIOR_PERIOD_NUM;
  END C_PRIOR_PERIOD_NUM_P;

  FUNCTION C_PRIOR_PERIOD_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_PRIOR_PERIOD_NAME;
  END C_PRIOR_PERIOD_NAME_P;

  FUNCTION C_PERIOD_TYPE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_PERIOD_TYPE;
  END C_PERIOD_TYPE_P;

  FUNCTION C_START_DATE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_START_DATE;
  END C_START_DATE_P;

  FUNCTION C_PRIOR_START_DATE_P RETURN DATE IS
  BEGIN
    RETURN C_PRIOR_START_DATE;
  END C_PRIOR_START_DATE_P;

  FUNCTION C_END_DATE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_END_DATE;
  END C_END_DATE_P;

  FUNCTION C_PRIOR_END_DATE_P RETURN DATE IS
  BEGIN
    RETURN C_PRIOR_END_DATE;
  END C_PRIOR_END_DATE_P;

  FUNCTION C_STATUS_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_STATUS;
  END C_STATUS_P;

  FUNCTION C_TOTAL_VENDORS_P RETURN NUMBER IS
  BEGIN
    RETURN C_TOTAL_VENDORS;
  END C_TOTAL_VENDORS_P;

  FUNCTION C_TOTAL_INACTIVE_P RETURN NUMBER IS
  BEGIN
    RETURN C_TOTAL_INACTIVE;
  END C_TOTAL_INACTIVE_P;

  FUNCTION C_TOTAL_ONE_TIME_P RETURN NUMBER IS
  BEGIN
    RETURN C_TOTAL_ONE_TIME;
  END C_TOTAL_ONE_TIME_P;

  FUNCTION C_TOTAL_1099_P RETURN NUMBER IS
  BEGIN
    RETURN C_TOTAL_1099;
  END C_TOTAL_1099_P;

  FUNCTION C_TOTAL_VOIDED_P RETURN NUMBER IS
  BEGIN
    RETURN C_TOTAL_VOIDED;
  END C_TOTAL_VOIDED_P;

  FUNCTION C_TOTAL_DISTS_P RETURN NUMBER IS
  BEGIN
    RETURN C_TOTAL_DISTS;
  END C_TOTAL_DISTS_P;

  FUNCTION C_TOTAL_BATCHES_P RETURN NUMBER IS
  BEGIN
    RETURN C_TOTAL_BATCHES;
  END C_TOTAL_BATCHES_P;

  FUNCTION C_TOTAL_INVOICES_P RETURN NUMBER IS
  BEGIN
    RETURN C_TOTAL_INVOICES;
  END C_TOTAL_INVOICES_P;

  FUNCTION C_TOTAL_INVOICES_DLR_P RETURN NUMBER IS
  BEGIN
    RETURN C_TOTAL_INVOICES_DLR;
  END C_TOTAL_INVOICES_DLR_P;

  FUNCTION C_TOTAL_INVOICE_HOLDS_P RETURN NUMBER IS
  BEGIN
    RETURN C_TOTAL_INVOICE_HOLDS;
  END C_TOTAL_INVOICE_HOLDS_P;

  FUNCTION C_TOTAL_INVOICE_HOLDS_DLR_P RETURN NUMBER IS
  BEGIN
    RETURN C_TOTAL_INVOICE_HOLDS_DLR;
  END C_TOTAL_INVOICE_HOLDS_DLR_P;

  FUNCTION C_TOTAL_CLEARED_P RETURN NUMBER IS
  BEGIN
    RETURN C_TOTAL_CLEARED;
  END C_TOTAL_CLEARED_P;

  FUNCTION C_TOTAL_CLEARED_DLR_P RETURN NUMBER IS
  BEGIN
    RETURN C_TOTAL_CLEARED_DLR;
  END C_TOTAL_CLEARED_DLR_P;

  FUNCTION C_STOPPED_P RETURN NUMBER IS
  BEGIN
    RETURN C_STOPPED;
  END C_STOPPED_P;

  FUNCTION C_TOTAL_MAN_CHECKS_P RETURN NUMBER IS
  BEGIN
    RETURN C_TOTAL_MAN_CHECKS;
  END C_TOTAL_MAN_CHECKS_P;

  FUNCTION C_TOTAL_MAN_CHECKS_DLR_P RETURN NUMBER IS
  BEGIN
    RETURN C_TOTAL_MAN_CHECKS_DLR;
  END C_TOTAL_MAN_CHECKS_DLR_P;

  FUNCTION C_TOTAL_AUTO_CHECKS_P RETURN NUMBER IS
  BEGIN
    RETURN C_TOTAL_AUTO_CHECKS;
  END C_TOTAL_AUTO_CHECKS_P;

  FUNCTION C_TOTAL_AUTO_CHECKS_DLR_P RETURN NUMBER IS
  BEGIN
    RETURN C_TOTAL_AUTO_CHECKS_DLR;
  END C_TOTAL_AUTO_CHECKS_DLR_P;

  FUNCTION C_TOTAL_SPOILED_P RETURN NUMBER IS
  BEGIN
    RETURN C_TOTAL_SPOILED;
  END C_TOTAL_SPOILED_P;

  FUNCTION C_TOTAL_OUTSTANDING_P RETURN NUMBER IS
  BEGIN
    RETURN C_TOTAL_OUTSTANDING;
  END C_TOTAL_OUTSTANDING_P;

  FUNCTION C_TOTAL_PAID_INV_P RETURN NUMBER IS
  BEGIN
    RETURN C_TOTAL_PAID_INV;
  END C_TOTAL_PAID_INV_P;

  FUNCTION C_TOTAL_DISCS_DLR_P RETURN NUMBER IS
  BEGIN
    RETURN C_TOTAL_DISCS_DLR;
  END C_TOTAL_DISCS_DLR_P;

  FUNCTION C_TOTAL_DISCS_P RETURN NUMBER IS
  BEGIN
    RETURN C_TOTAL_DISCS;
  END C_TOTAL_DISCS_P;

  FUNCTION C_TOTAL_SCHEDULED_P RETURN NUMBER IS
  BEGIN
    RETURN C_TOTAL_SCHEDULED;
  END C_TOTAL_SCHEDULED_P;

  FUNCTION C_TOTAL_SITES_P RETURN NUMBER IS
  BEGIN
    RETURN C_TOTAL_SITES;
  END C_TOTAL_SITES_P;

  FUNCTION C_TOTAL_MH_P RETURN NUMBER IS
  BEGIN
    RETURN C_TOTAL_MH;
  END C_TOTAL_MH_P;

  FUNCTION C_TOTAL_MH_DLR_P RETURN NUMBER IS
  BEGIN
    RETURN C_TOTAL_MH_DLR;
  END C_TOTAL_MH_DLR_P;

  FUNCTION C_MH_COUNT_P RETURN NUMBER IS
  BEGIN
    RETURN C_MH_COUNT;
  END C_MH_COUNT_P;

  FUNCTION C_MH_AMOUNT_P RETURN NUMBER IS
  BEGIN
    RETURN C_MH_AMOUNT;
  END C_MH_AMOUNT_P;

  FUNCTION C_TOTAL_MATCHED_P RETURN NUMBER IS
  BEGIN
    RETURN C_TOTAL_MATCHED;
  END C_TOTAL_MATCHED_P;

  FUNCTION C_TOTAL_MATCHED_DLR_P RETURN NUMBER IS
  BEGIN
    RETURN C_TOTAL_MATCHED_DLR;
  END C_TOTAL_MATCHED_DLR_P;

  FUNCTION C_NEW_COUNT_P RETURN NUMBER IS
  BEGIN
    RETURN C_NEW_COUNT;
  END C_NEW_COUNT_P;

  FUNCTION C_NEW_AMOUNT_P RETURN NUMBER IS
  BEGIN
    RETURN C_NEW_AMOUNT;
  END C_NEW_AMOUNT_P;

  FUNCTION C_VOID_P RETURN NUMBER IS
  BEGIN
    RETURN C_VOID;
  END C_VOID_P;

  FUNCTION C_CLEARED_P RETURN NUMBER IS
  BEGIN
    RETURN C_CLEARED;
  END C_CLEARED_P;

  FUNCTION C_CLEARED_DLR_P RETURN NUMBER IS
  BEGIN
    RETURN C_CLEARED_DLR;
  END C_CLEARED_DLR_P;

  FUNCTION C_MANUAL_CHECKS_P RETURN NUMBER IS
  BEGIN
    RETURN C_MANUAL_CHECKS;
  END C_MANUAL_CHECKS_P;

  FUNCTION C_TOTAL_STOPPED_P RETURN NUMBER IS
  BEGIN
    RETURN C_TOTAL_STOPPED;
  END C_TOTAL_STOPPED_P;

  FUNCTION C_MANUAL_CHECKS_DLR_P RETURN NUMBER IS
  BEGIN
    RETURN C_MANUAL_CHECKS_DLR;
  END C_MANUAL_CHECKS_DLR_P;

  FUNCTION C_AUTO_CHECKS_P RETURN NUMBER IS
  BEGIN
    RETURN C_AUTO_CHECKS;
  END C_AUTO_CHECKS_P;

  FUNCTION C_AUTO_CHECKS_DLR_P RETURN NUMBER IS
  BEGIN
    RETURN C_AUTO_CHECKS_DLR;
  END C_AUTO_CHECKS_DLR_P;

  FUNCTION C_NEW_SPOILED_P RETURN NUMBER IS
  BEGIN
    RETURN C_NEW_SPOILED;
  END C_NEW_SPOILED_P;

  FUNCTION C_NEW_OUTSTANDING_P RETURN NUMBER IS
  BEGIN
    RETURN C_NEW_OUTSTANDING;
  END C_NEW_OUTSTANDING_P;

  FUNCTION C_MANUAL_PAYMENTS_P RETURN NUMBER IS
  BEGIN
    RETURN C_MANUAL_PAYMENTS;
  END C_MANUAL_PAYMENTS_P;

  FUNCTION C_MANUAL_PAYMENTS_DLR_P RETURN NUMBER IS
  BEGIN
    RETURN C_MANUAL_PAYMENTS_DLR;
  END C_MANUAL_PAYMENTS_DLR_P;

  FUNCTION C_AUTO_PAYMENTS_P RETURN NUMBER IS
  BEGIN
    RETURN C_AUTO_PAYMENTS;
  END C_AUTO_PAYMENTS_P;

  FUNCTION C_AUTO_PAYMENTS_DLR_P RETURN NUMBER IS
  BEGIN
    RETURN C_AUTO_PAYMENTS_DLR;
  END C_AUTO_PAYMENTS_DLR_P;

  FUNCTION C_INVOICES_P RETURN NUMBER IS
  BEGIN
    RETURN C_INVOICES;
  END C_INVOICES_P;

  FUNCTION C_DISCOUNT_DLR_P RETURN NUMBER IS
  BEGIN
    RETURN C_DISCOUNT_DLR;
  END C_DISCOUNT_DLR_P;

  FUNCTION C_DISCOUNTS_P RETURN NUMBER IS
  BEGIN
    RETURN C_DISCOUNTS;
  END C_DISCOUNTS_P;

  FUNCTION C_NEW_INVOICES_P RETURN NUMBER IS
  BEGIN
    RETURN C_NEW_INVOICES;
  END C_NEW_INVOICES_P;

  FUNCTION C_TOTAL_DLR_P RETURN NUMBER IS
  BEGIN
    RETURN C_TOTAL_DLR;
  END C_TOTAL_DLR_P;

  FUNCTION C_BATCHES_P RETURN NUMBER IS
  BEGIN
    RETURN C_BATCHES;
  END C_BATCHES_P;

  FUNCTION C_NEW_ON_HOLD_P RETURN NUMBER IS
  BEGIN
    RETURN C_NEW_ON_HOLD;
  END C_NEW_ON_HOLD_P;

  FUNCTION C_NEW_HOLD_DLR_P RETURN NUMBER IS
  BEGIN
    RETURN C_NEW_HOLD_DLR;
  END C_NEW_HOLD_DLR_P;

  FUNCTION C_PAYMENT_SCHEDULES_P RETURN NUMBER IS
  BEGIN
    RETURN C_PAYMENT_SCHEDULES;
  END C_PAYMENT_SCHEDULES_P;

  FUNCTION C_NEW_DISTS_P RETURN NUMBER IS
  BEGIN
    RETURN C_NEW_DISTS;
  END C_NEW_DISTS_P;

  FUNCTION C_NEW_VENDORS_P RETURN NUMBER IS
  BEGIN
    RETURN C_NEW_VENDORS;
  END C_NEW_VENDORS_P;

  FUNCTION C_NEW_INACTIVE_P RETURN NUMBER IS
  BEGIN
    RETURN C_NEW_INACTIVE;
  END C_NEW_INACTIVE_P;

  FUNCTION C_NEW_ONE_TIME_P RETURN NUMBER IS
  BEGIN
    RETURN C_NEW_ONE_TIME;
  END C_NEW_ONE_TIME_P;

  FUNCTION C_NEW_TYPE_1099_VENDORS_P RETURN NUMBER IS
  BEGIN
    RETURN C_NEW_TYPE_1099_VENDORS;
  END C_NEW_TYPE_1099_VENDORS_P;

  FUNCTION C_OLD_VENDOR_SITES_P RETURN NUMBER IS
  BEGIN
    RETURN C_OLD_VENDOR_SITES;
  END C_OLD_VENDOR_SITES_P;

  FUNCTION C_TOTAL_VENDORS_HELD_P RETURN NUMBER IS
  BEGIN
    RETURN C_TOTAL_VENDORS_HELD;
  END C_TOTAL_VENDORS_HELD_P;

  FUNCTION C_NEW_VENDOR_SITES_P RETURN NUMBER IS
  BEGIN
    RETURN C_NEW_VENDOR_SITES;
  END C_NEW_VENDOR_SITES_P;

  FUNCTION C_UPDATED_VENDORS_P RETURN NUMBER IS
  BEGIN
    RETURN C_UPDATED_VENDORS;
  END C_UPDATED_VENDORS_P;

  FUNCTION C_UPDATED_SITES_P RETURN NUMBER IS
  BEGIN
    RETURN C_UPDATED_SITES;
  END C_UPDATED_SITES_P;

  FUNCTION C_NEW_VENDORS_HELD_P RETURN NUMBER IS
  BEGIN
    RETURN C_NEW_VENDORS_HELD;
  END C_NEW_VENDORS_HELD_P;

  FUNCTION C_OLD_INVOICES_P RETURN NUMBER IS
  BEGIN
    RETURN C_OLD_INVOICES;
  END C_OLD_INVOICES_P;

  FUNCTION C_OLD_TOTAL_DLR_P RETURN NUMBER IS
  BEGIN
    RETURN C_OLD_TOTAL_DLR;
  END C_OLD_TOTAL_DLR_P;

  FUNCTION C_OLD_DISTS_P RETURN NUMBER IS
  BEGIN
    RETURN C_OLD_DISTS;
  END C_OLD_DISTS_P;

  FUNCTION C_OLD_BATCHES_P RETURN NUMBER IS
  BEGIN
    RETURN C_OLD_BATCHES;
  END C_OLD_BATCHES_P;

  FUNCTION C_OLD_PAYMENT_SCHEDULES_P RETURN NUMBER IS
  BEGIN
    RETURN C_OLD_PAYMENT_SCHEDULES;
  END C_OLD_PAYMENT_SCHEDULES_P;

  FUNCTION C_OLD_ON_HOLD_P RETURN NUMBER IS
  BEGIN
    RETURN C_OLD_ON_HOLD;
  END C_OLD_ON_HOLD_P;

  FUNCTION C_OLD_HOLD_DLR_P RETURN NUMBER IS
  BEGIN
    RETURN C_OLD_HOLD_DLR;
  END C_OLD_HOLD_DLR_P;

  FUNCTION C_OLD_COUNT_P RETURN NUMBER IS
  BEGIN
    RETURN C_OLD_COUNT;
  END C_OLD_COUNT_P;

  FUNCTION C_OLD_AMOUNT_P RETURN NUMBER IS
  BEGIN
    RETURN C_OLD_AMOUNT;
  END C_OLD_AMOUNT_P;

  FUNCTION C_OLD_MH_COUNT_P RETURN NUMBER IS
  BEGIN
    RETURN C_OLD_MH_COUNT;
  END C_OLD_MH_COUNT_P;

  FUNCTION C_OLD_MH_AMOUNT_P RETURN NUMBER IS
  BEGIN
    RETURN C_OLD_MH_AMOUNT;
  END C_OLD_MH_AMOUNT_P;

  FUNCTION C_OLD_VENDORS_P RETURN NUMBER IS
  BEGIN
    RETURN C_OLD_VENDORS;
  END C_OLD_VENDORS_P;

  FUNCTION C_OLD_SITES_P RETURN NUMBER IS
  BEGIN
    RETURN C_OLD_SITES;
  END C_OLD_SITES_P;

  FUNCTION C_INACTIVE_P RETURN NUMBER IS
  BEGIN
    RETURN C_INACTIVE;
  END C_INACTIVE_P;

  FUNCTION C_ONE_TIME_P RETURN NUMBER IS
  BEGIN
    RETURN C_ONE_TIME;
  END C_ONE_TIME_P;

  FUNCTION C_TYPE_1099_VENDORS_P RETURN NUMBER IS
  BEGIN
    RETURN C_TYPE_1099_VENDORS;
  END C_TYPE_1099_VENDORS_P;

  FUNCTION C_VENDORS_HELD_P RETURN NUMBER IS
  BEGIN
    RETURN C_VENDORS_HELD;
  END C_VENDORS_HELD_P;

  FUNCTION C_OLD_INVOICES_PAID_P RETURN NUMBER IS
  BEGIN
    RETURN C_OLD_INVOICES_PAID;
  END C_OLD_INVOICES_PAID_P;

  FUNCTION C_OLD_AUTO_CHECKS_P RETURN NUMBER IS
  BEGIN
    RETURN C_OLD_AUTO_CHECKS;
  END C_OLD_AUTO_CHECKS_P;

  FUNCTION C_OLD_MANUAL_CHECKS_P RETURN NUMBER IS
  BEGIN
    RETURN C_OLD_MANUAL_CHECKS;
  END C_OLD_MANUAL_CHECKS_P;

  FUNCTION C_OLD_DISCOUNTS_P RETURN NUMBER IS
  BEGIN
    RETURN C_OLD_DISCOUNTS;
  END C_OLD_DISCOUNTS_P;

  FUNCTION C_OLD_DISCOUNT_DLR_P RETURN NUMBER IS
  BEGIN
    RETURN C_OLD_DISCOUNT_DLR;
  END C_OLD_DISCOUNT_DLR_P;

  FUNCTION C_OLD_VOID_P RETURN NUMBER IS
  BEGIN
    RETURN C_OLD_VOID;
  END C_OLD_VOID_P;

  FUNCTION C_OLD_STOPPED_P RETURN NUMBER IS
  BEGIN
    RETURN C_OLD_STOPPED;
  END C_OLD_STOPPED_P;

  FUNCTION C_OLD_SPOILED_P RETURN NUMBER IS
  BEGIN
    RETURN C_OLD_SPOILED;
  END C_OLD_SPOILED_P;

  FUNCTION C_OLD_OUTSTANDING_P RETURN NUMBER IS
  BEGIN
    RETURN C_OLD_OUTSTANDING;
  END C_OLD_OUTSTANDING_P;

  FUNCTION C_OLD_CLEARED_P RETURN NUMBER IS
  BEGIN
    RETURN C_OLD_CLEARED;
  END C_OLD_CLEARED_P;

  FUNCTION C_OLD_CLEARED_DLR_P RETURN NUMBER IS
  BEGIN
    RETURN C_OLD_CLEARED_DLR;
  END C_OLD_CLEARED_DLR_P;

  FUNCTION C_OLD_AUTO_CHECKS_DLR_P RETURN NUMBER IS
  BEGIN
    RETURN C_OLD_AUTO_CHECKS_DLR;
  END C_OLD_AUTO_CHECKS_DLR_P;

  FUNCTION C_OLD_MANUAL_CHECKS_DLR_P RETURN NUMBER IS
  BEGIN
    RETURN C_OLD_MANUAL_CHECKS_DLR;
  END C_OLD_MANUAL_CHECKS_DLR_P;

  FUNCTION C_AVERAGE_SITES_P RETURN NUMBER IS
  BEGIN
    RETURN C_AVERAGE_SITES;
  END C_AVERAGE_SITES_P;

  FUNCTION C_AVERAGE_LINES_P RETURN NUMBER IS
  BEGIN
    RETURN C_AVERAGE_LINES;
  END C_AVERAGE_LINES_P;

  FUNCTION C_AVERAGE_PAY_INV_P RETURN NUMBER IS
  BEGIN
    RETURN C_AVERAGE_PAY_INV;
  END C_AVERAGE_PAY_INV_P;

  FUNCTION C_AVERAGE_PAY_CHK_P RETURN NUMBER IS
  BEGIN
    RETURN C_AVERAGE_PAY_CHK;
  END C_AVERAGE_PAY_CHK_P;

  FUNCTION C_AVERAGE_MH_P RETURN NUMBER IS
  BEGIN
    RETURN C_AVERAGE_MH;
  END C_AVERAGE_MH_P;

  FUNCTION C_TOTAL_SITE_P RETURN NUMBER IS
  BEGIN
    RETURN C_TOTAL_SITE;
  END C_TOTAL_SITE_P;

  FUNCTION C_TOTAL_NEW_EXCEPTIONS_P RETURN NUMBER IS
  BEGIN
    RETURN C_TOTAL_NEW_EXCEPTIONS;
  END C_TOTAL_NEW_EXCEPTIONS_P;

  FUNCTION C_TOTAL_OLD_EXCEPTIONS_P RETURN NUMBER IS
  BEGIN
    RETURN C_TOTAL_OLD_EXCEPTIONS;
  END C_TOTAL_OLD_EXCEPTIONS_P;

  FUNCTION C_TOTAL_TOTAL_EXCEPTIONS_P RETURN NUMBER IS
  BEGIN
    RETURN C_TOTAL_TOTAL_EXCEPTIONS;
  END C_TOTAL_TOTAL_EXCEPTIONS_P;

  FUNCTION C_TOTAL_NEW_EXCEPTIONS_DLR_P RETURN NUMBER IS
  BEGIN
    RETURN C_TOTAL_NEW_EXCEPTIONS_DLR;
  END C_TOTAL_NEW_EXCEPTIONS_DLR_P;

  FUNCTION C_TOTAL_OLD_EXCEPTIONS_DLR_P RETURN NUMBER IS
  BEGIN
    RETURN C_TOTAL_OLD_EXCEPTIONS_DLR;
  END C_TOTAL_OLD_EXCEPTIONS_DLR_P;

  FUNCTION C_TOTAL_TOTAL_EXCEPTIONS_DLR_P RETURN NUMBER IS
  BEGIN
    RETURN C_TOTAL_TOTAL_EXCEPTIONS_DLR;
  END C_TOTAL_TOTAL_EXCEPTIONS_DLR_P;

  FUNCTION C_TOTAL_NEW_CHECKS_P RETURN NUMBER IS
  BEGIN
    RETURN C_TOTAL_NEW_CHECKS;
  END C_TOTAL_NEW_CHECKS_P;

  FUNCTION C_TOTAL_OLD_CHECKS_P RETURN NUMBER IS
  BEGIN
    RETURN C_TOTAL_OLD_CHECKS;
  END C_TOTAL_OLD_CHECKS_P;

  FUNCTION C_TOTAL_TOTAL_CHECKS_P RETURN NUMBER IS
  BEGIN
    RETURN C_TOTAL_TOTAL_CHECKS;
  END C_TOTAL_TOTAL_CHECKS_P;

  FUNCTION C_TOTAL_NEW_CHECKS_DLR_P RETURN NUMBER IS
  BEGIN
    RETURN C_TOTAL_NEW_CHECKS_DLR;
  END C_TOTAL_NEW_CHECKS_DLR_P;

  FUNCTION C_TOTAL_OLD_CHECKS_DLR_P RETURN NUMBER IS
  BEGIN
    RETURN C_TOTAL_OLD_CHECKS_DLR;
  END C_TOTAL_OLD_CHECKS_DLR_P;

  FUNCTION C_TOTAL_TOTAL_CHECKS_DLR_P RETURN NUMBER IS
  BEGIN
    RETURN C_TOTAL_TOTAL_CHECKS_DLR;
  END C_TOTAL_TOTAL_CHECKS_DLR_P;

  FUNCTION C_PERCENT_VENDORS_P RETURN NUMBER IS
  BEGIN
    RETURN C_PERCENT_VENDORS;
  END C_PERCENT_VENDORS_P;

  FUNCTION C_PERCENT_SITES_P RETURN NUMBER IS
  BEGIN
    RETURN C_PERCENT_SITES;
  END C_PERCENT_SITES_P;

  FUNCTION C_PERCENT_ONE_TIME_P RETURN NUMBER IS
  BEGIN
    RETURN C_PERCENT_ONE_TIME;
  END C_PERCENT_ONE_TIME_P;

  FUNCTION C_PERCENT_1099_P RETURN NUMBER IS
  BEGIN
    RETURN C_PERCENT_1099;
  END C_PERCENT_1099_P;

  FUNCTION C_PERCENT_VENDORS_HELD_P RETURN NUMBER IS
  BEGIN
    RETURN C_PERCENT_VENDORS_HELD;
  END C_PERCENT_VENDORS_HELD_P;

  FUNCTION C_PERCENT_INACTIVE_P RETURN NUMBER IS
  BEGIN
    RETURN C_PERCENT_INACTIVE;
  END C_PERCENT_INACTIVE_P;

  FUNCTION C_PERCENT_INVOICES_P RETURN NUMBER IS
  BEGIN
    RETURN C_PERCENT_INVOICES;
  END C_PERCENT_INVOICES_P;

  FUNCTION C_PERCENT_INVOICES_DLR_P RETURN NUMBER IS
  BEGIN
    RETURN C_PERCENT_INVOICES_DLR;
  END C_PERCENT_INVOICES_DLR_P;

  FUNCTION C_PERCENT_MATCHED_P RETURN NUMBER IS
  BEGIN
    RETURN C_PERCENT_MATCHED;
  END C_PERCENT_MATCHED_P;

  FUNCTION C_PERCENT_MATCHED_DLR_P RETURN NUMBER IS
  BEGIN
    RETURN C_PERCENT_MATCHED_DLR;
  END C_PERCENT_MATCHED_DLR_P;

  FUNCTION C_PERCENT_DISTS_P RETURN NUMBER IS
  BEGIN
    RETURN C_PERCENT_DISTS;
  END C_PERCENT_DISTS_P;

  FUNCTION C_PERCENT_SCHEDULED_P RETURN NUMBER IS
  BEGIN
    RETURN C_PERCENT_SCHEDULED;
  END C_PERCENT_SCHEDULED_P;

  FUNCTION C_PERCENT_BATCHES_P RETURN NUMBER IS
  BEGIN
    RETURN C_PERCENT_BATCHES;
  END C_PERCENT_BATCHES_P;

  FUNCTION C_PERCENT_INVOICE_HOLDS_P RETURN NUMBER IS
  BEGIN
    RETURN C_PERCENT_INVOICE_HOLDS;
  END C_PERCENT_INVOICE_HOLDS_P;

  FUNCTION C_PERCENT_INVOICE_HOLDS_DLR_P RETURN NUMBER IS
  BEGIN
    RETURN C_PERCENT_INVOICE_HOLDS_DLR;
  END C_PERCENT_INVOICE_HOLDS_DLR_P;

  FUNCTION C_PERCENT_MH_P RETURN NUMBER IS
  BEGIN
    RETURN C_PERCENT_MH;
  END C_PERCENT_MH_P;

  FUNCTION C_PERCENT_MH_DLR_P RETURN NUMBER IS
  BEGIN
    RETURN C_PERCENT_MH_DLR;
  END C_PERCENT_MH_DLR_P;

  FUNCTION C_PERCENT_MAN_CHECKS_P RETURN NUMBER IS
  BEGIN
    RETURN C_PERCENT_MAN_CHECKS;
  END C_PERCENT_MAN_CHECKS_P;

  FUNCTION C_PERCENT_MAN_CHECKS_DLR_P RETURN NUMBER IS
  BEGIN
    RETURN C_PERCENT_MAN_CHECKS_DLR;
  END C_PERCENT_MAN_CHECKS_DLR_P;

  FUNCTION C_PERCENT_AUTO_CHECKS_P RETURN NUMBER IS
  BEGIN
    RETURN C_PERCENT_AUTO_CHECKS;
  END C_PERCENT_AUTO_CHECKS_P;

  FUNCTION C_PERCENT_AUTO_CHECKS_DLR_P RETURN NUMBER IS
  BEGIN
    RETURN C_PERCENT_AUTO_CHECKS_DLR;
  END C_PERCENT_AUTO_CHECKS_DLR_P;

  FUNCTION C_PERCENT_PAID_INV_P RETURN NUMBER IS
  BEGIN
    RETURN C_PERCENT_PAID_INV;
  END C_PERCENT_PAID_INV_P;

  FUNCTION C_PERCENT_DISCS_P RETURN NUMBER IS
  BEGIN
    RETURN C_PERCENT_DISCS;
  END C_PERCENT_DISCS_P;

  FUNCTION C_PERCENT_DISCS_DLR_P RETURN NUMBER IS
  BEGIN
    RETURN C_PERCENT_DISCS_DLR;
  END C_PERCENT_DISCS_DLR_P;

  FUNCTION C_PERCENT_VOIDED_P RETURN NUMBER IS
  BEGIN
    RETURN C_PERCENT_VOIDED;
  END C_PERCENT_VOIDED_P;

  FUNCTION C_PERCENT_STOPPED_P RETURN NUMBER IS
  BEGIN
    RETURN C_PERCENT_STOPPED;
  END C_PERCENT_STOPPED_P;

  FUNCTION C_PERCENT_SPOILED_P RETURN NUMBER IS
  BEGIN
    RETURN C_PERCENT_SPOILED;
  END C_PERCENT_SPOILED_P;

  FUNCTION C_PERCENT_OUTSTANDING_P RETURN NUMBER IS
  BEGIN
    RETURN C_PERCENT_OUTSTANDING;
  END C_PERCENT_OUTSTANDING_P;

  FUNCTION C_PERCENT_CLEARED_P RETURN NUMBER IS
  BEGIN
    RETURN C_PERCENT_CLEARED;
  END C_PERCENT_CLEARED_P;

  FUNCTION C_PERCENT_CLEARED_DLR_P RETURN NUMBER IS
  BEGIN
    RETURN C_PERCENT_CLEARED_DLR;
  END C_PERCENT_CLEARED_DLR_P;

  FUNCTION C_PERCENT_TOTAL_EXCEPTIONS_P RETURN NUMBER IS
  BEGIN
    RETURN C_PERCENT_TOTAL_EXCEPTIONS;
  END C_PERCENT_TOTAL_EXCEPTIONS_P;

  FUNCTION C_PERCENT_TOTAL_EXCEPTIONS_DL RETURN NUMBER IS
  BEGIN
    RETURN C_PERCENT_TOTAL_EXCEPTIONS_DLR;
  END C_PERCENT_TOTAL_EXCEPTIONS_DL;

  FUNCTION C_PERCENT_TOTAL_CHECKS_P RETURN NUMBER IS
  BEGIN
    RETURN C_PERCENT_TOTAL_CHECKS;
  END C_PERCENT_TOTAL_CHECKS_P;

  FUNCTION C_PERCENT_TOTAL_CHECKS_DLR_P RETURN NUMBER IS
  BEGIN
    RETURN C_PERCENT_TOTAL_CHECKS_DLR;
  END C_PERCENT_TOTAL_CHECKS_DLR_P;

  FUNCTION C_NLS_NA_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_NLS_NA;
  END C_NLS_NA_P;

  FUNCTION C_PRIOR_PERIOD_EXISTS_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_PRIOR_PERIOD_EXISTS;
  END C_PRIOR_PERIOD_EXISTS_P;

  FUNCTION C_NLS_END_OF_REPORT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_NLS_END_OF_REPORT;
  END C_NLS_END_OF_REPORT_P;

  FUNCTION C_PRIOR_OLD_VENDOR_SITES_P RETURN NUMBER IS
  BEGIN
    RETURN C_PRIOR_OLD_VENDOR_SITES;
  END C_PRIOR_OLD_VENDOR_SITES_P;

  FUNCTION C_PERCENT_ADDITIONAL_SITES_P RETURN NUMBER IS
  BEGIN
    RETURN C_PERCENT_ADDITIONAL_SITES;
  END C_PERCENT_ADDITIONAL_SITES_P;

  FUNCTION C_TOTAL_ADDITIONAL_SITES_P RETURN NUMBER IS
  BEGIN
    RETURN C_TOTAL_ADDITIONAL_SITES;
  END C_TOTAL_ADDITIONAL_SITES_P;

  FUNCTION C_PRIOR_VENDORS_UPDATED_P RETURN NUMBER IS
  BEGIN
    RETURN C_PRIOR_VENDORS_UPDATED;
  END C_PRIOR_VENDORS_UPDATED_P;

  FUNCTION C_PRIOR_SITES_UPDATED_P RETURN NUMBER IS
  BEGIN
    RETURN C_PRIOR_SITES_UPDATED;
  END C_PRIOR_SITES_UPDATED_P;

  FUNCTION C_PERCENT_VENDORS_UPDATED_P RETURN NUMBER IS
  BEGIN
    RETURN C_PERCENT_VENDORS_UPDATED;
  END C_PERCENT_VENDORS_UPDATED_P;

  FUNCTION C_PERCENT_SITES_UPDATED_P RETURN NUMBER IS
  BEGIN
    RETURN C_PERCENT_SITES_UPDATED;
  END C_PERCENT_SITES_UPDATED_P;

  FUNCTION C_TOTAL_VENDORS_UPDATED_P RETURN NUMBER IS
  BEGIN
    RETURN C_TOTAL_VENDORS_UPDATED;
  END C_TOTAL_VENDORS_UPDATED_P;

  FUNCTION C_TOTAL_SITES_UPDATED_P RETURN NUMBER IS
  BEGIN
    RETURN C_TOTAL_SITES_UPDATED;
  END C_TOTAL_SITES_UPDATED_P;

  FUNCTION C_SYSTEM_USER_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_SYSTEM_USER_NAME;
  END C_SYSTEM_USER_NAME_P;

  FUNCTION C_TOTAL_REFUND_CHECKS_P RETURN NUMBER IS
  BEGIN
    RETURN C_TOTAL_REFUND_CHECKS;
  END C_TOTAL_REFUND_CHECKS_P;

  FUNCTION C_TOTAL_REFUND_CHECKS_DLR_P RETURN NUMBER IS
  BEGIN
    RETURN C_TOTAL_REFUND_CHECKS_DLR;
  END C_TOTAL_REFUND_CHECKS_DLR_P;

  FUNCTION C_TOTAL_OUTSTANDING_DLR_P RETURN NUMBER IS
  BEGIN
    RETURN C_TOTAL_OUTSTANDING_DLR;
  END C_TOTAL_OUTSTANDING_DLR_P;

  FUNCTION C_NEW_OUTSTANDING_DLR_P RETURN NUMBER IS
  BEGIN
    RETURN C_NEW_OUTSTANDING_DLR;
  END C_NEW_OUTSTANDING_DLR_P;

  FUNCTION C_NEW_REFUND_PAYMENTS_P RETURN NUMBER IS
  BEGIN
    RETURN C_NEW_REFUND_PAYMENTS;
  END C_NEW_REFUND_PAYMENTS_P;

  FUNCTION C_NEW_REFUND_PAYMENTS_DLR_P RETURN NUMBER IS
  BEGIN
    RETURN C_NEW_REFUND_PAYMENTS_DLR;
  END C_NEW_REFUND_PAYMENTS_DLR_P;

  FUNCTION C_OLD_OUTSTANDING_DLR_P RETURN NUMBER IS
  BEGIN
    RETURN C_OLD_OUTSTANDING_DLR;
  END C_OLD_OUTSTANDING_DLR_P;

  FUNCTION C_OLD_REFUND_PAYMENTS_P RETURN NUMBER IS
  BEGIN
    RETURN C_OLD_REFUND_PAYMENTS;
  END C_OLD_REFUND_PAYMENTS_P;

  FUNCTION C_OLD_REFUND_PAYMENTS_DLR_P RETURN NUMBER IS
  BEGIN
    RETURN C_OLD_REFUND_PAYMENTS_DLR;
  END C_OLD_REFUND_PAYMENTS_DLR_P;

  FUNCTION C_PERCENT_OUTSTANDING_DLR_P RETURN NUMBER IS
  BEGIN
    RETURN C_PERCENT_OUTSTANDING_DLR;
  END C_PERCENT_OUTSTANDING_DLR_P;

  FUNCTION C_PERCENT_REFUND_CHECKS_P RETURN NUMBER IS
  BEGIN
    RETURN C_PERCENT_REFUND_CHECKS;
  END C_PERCENT_REFUND_CHECKS_P;

  FUNCTION C_PERCENT_REFUND_CHECKS_DLR_P RETURN NUMBER IS
  BEGIN
    RETURN C_PERCENT_REFUND_CHECKS_DLR;
  END C_PERCENT_REFUND_CHECKS_DLR_P;

  FUNCTION C_NEW_LINES_P RETURN NUMBER IS
  BEGIN
    RETURN C_NEW_LINES;
  END C_NEW_LINES_P;

  FUNCTION C_OLD_LINES_P RETURN NUMBER IS
  BEGIN
    RETURN C_OLD_LINES;
  END C_OLD_LINES_P;

  FUNCTION C_PERCENT_LINES_P RETURN NUMBER IS
  BEGIN
    RETURN C_PERCENT_LINES;
  END C_PERCENT_LINES_P;

  FUNCTION C_TOTAL_LINES_P RETURN NUMBER IS
  BEGIN
    RETURN C_TOTAL_LINES;
  END C_TOTAL_LINES_P;

  FUNCTION C_OLD_LINES_VAR_COUNT_P RETURN NUMBER IS
  BEGIN
    RETURN C_OLD_LINES_VAR_COUNT;
  END C_OLD_LINES_VAR_COUNT_P;

  FUNCTION C_OLD_LINES_VAR_AMOUNT_P RETURN NUMBER IS
  BEGIN
    RETURN C_OLD_LINES_VAR_AMOUNT;
  END C_OLD_LINES_VAR_AMOUNT_P;

  FUNCTION C_LINE_TOTAL_VARS_P RETURN NUMBER IS
  BEGIN
    RETURN C_LINE_TOTAL_VARS;
  END C_LINE_TOTAL_VARS_P;

  FUNCTION C_LINE_TOTAL_VARS_DLR_P RETURN NUMBER IS
  BEGIN
    RETURN C_LINE_TOTAL_VARS_DLR;
  END C_LINE_TOTAL_VARS_DLR_P;

  FUNCTION C_LINE_VAR_COUNT_P RETURN NUMBER IS
  BEGIN
    RETURN C_LINE_VAR_COUNT;
  END C_LINE_VAR_COUNT_P;

  FUNCTION C_LINE_VAR_AMOUNT_P RETURN NUMBER IS
  BEGIN
    RETURN C_LINE_VAR_AMOUNT;
  END C_LINE_VAR_AMOUNT_P;

  FUNCTION C_OLD_DISTS_VAR_COUNT_P RETURN NUMBER IS
  BEGIN
    RETURN C_OLD_DISTS_VAR_COUNT;
  END C_OLD_DISTS_VAR_COUNT_P;

  FUNCTION C_OLD_DISTS_VAR_AMOUNT_P RETURN NUMBER IS
  BEGIN
    RETURN C_OLD_DISTS_VAR_AMOUNT;
  END C_OLD_DISTS_VAR_AMOUNT_P;

  FUNCTION C_DIST_TOTAL_VARS_P RETURN NUMBER IS
  BEGIN
    RETURN C_DIST_TOTAL_VARS;
  END C_DIST_TOTAL_VARS_P;

  FUNCTION C_DIST_TOTAL_VARS_DLR_P RETURN NUMBER IS
  BEGIN
    RETURN C_DIST_TOTAL_VARS_DLR;
  END C_DIST_TOTAL_VARS_DLR_P;

  FUNCTION C_DIST_VAR_COUNT_P RETURN NUMBER IS
  BEGIN
    RETURN C_DIST_VAR_COUNT;
  END C_DIST_VAR_COUNT_P;

  FUNCTION C_DIST_VAR_AMOUNT_P RETURN NUMBER IS
  BEGIN
    RETURN C_DIST_VAR_AMOUNT;
  END C_DIST_VAR_AMOUNT_P;

  FUNCTION C_PERCENT_LINE_VARS_P RETURN NUMBER IS
  BEGIN
    RETURN C_PERCENT_LINE_VARS;
  END C_PERCENT_LINE_VARS_P;

  FUNCTION C_PERCENT_DIST_VARS_P RETURN NUMBER IS
  BEGIN
    RETURN C_PERCENT_DIST_VARS;
  END C_PERCENT_DIST_VARS_P;

  FUNCTION C_PERCENT_LINE_VARS_DLR_P RETURN NUMBER IS
  BEGIN
    RETURN C_PERCENT_LINE_VARS_DLR;
  END C_PERCENT_LINE_VARS_DLR_P;

  FUNCTION C_PERCENT_DIST_VARS_DLR_P RETURN NUMBER IS
  BEGIN
    RETURN C_PERCENT_DIST_VARS_DLR;
  END C_PERCENT_DIST_VARS_DLR_P;

  FUNCTION C_AVERAGE_DISTS_P RETURN NUMBER IS
  BEGIN
    RETURN C_AVERAGE_DISTS;
  END C_AVERAGE_DISTS_P;

  FUNCTION C_ORG_ID_P RETURN NUMBER IS
  BEGIN
    RETURN C_ORG_ID;
  END C_ORG_ID_P;

END AP_APXKIRKI_XMLP_PKG;



/
