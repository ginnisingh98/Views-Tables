--------------------------------------------------------
--  DDL for Package Body AP_APXCHECC_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_APXCHECC_XMLP_PKG" AS
/* $Header: APXCHECCB.pls 120.0 2007/12/27 07:34:20 vjaganat noship $ */
  FUNCTION GET_BASE_CURR_DATA RETURN BOOLEAN IS
    BASE_CURR AP_SYSTEM_PARAMETERS.BASE_CURRENCY_CODE%TYPE;
    PREC FND_CURRENCIES_VL.PRECISION%TYPE;
    MIN_AU FND_CURRENCIES_VL.MINIMUM_ACCOUNTABLE_UNIT%TYPE;
    DESCR FND_CURRENCIES_VL.DESCRIPTION%TYPE;
  BEGIN
    BASE_CURR := '';
    PREC := 0;
    MIN_AU := 0;
    DESCR := '';
    SELECT
      P.BASE_CURRENCY_CODE,
      C.PRECISION,
      C.MINIMUM_ACCOUNTABLE_UNIT,
      C.DESCRIPTION
    INTO BASE_CURR,PREC,MIN_AU,DESCR
    FROM
      AP_SYSTEM_PARAMETERS P,
      FND_CURRENCIES_VL C
    WHERE P.BASE_CURRENCY_CODE = C.CURRENCY_CODE;
    C_BASE_CURRENCY_CODE := BASE_CURR;
    C_BASE_PRECISION := PREC;
    C_BASE_MIN_ACCT_UNIT := MIN_AU;
    C_BASE_DESCRIPTION := DESCR;
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END GET_BASE_CURR_DATA;

  FUNCTION CUSTOM_INIT RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
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
    NLS_YES FND_LOOKUPS.MEANING%TYPE;
    NLS_NO FND_LOOKUPS.MEANING%TYPE;
    NLS_AMOUNT_DIFFERENCE AP_LOOKUP_CODES.DISPLAYED_FIELD%TYPE;
    NLS_CLEARED_BEFORE_ISSUED AP_LOOKUP_CODES.DISPLAYED_FIELD%TYPE;
    NLS_VOIDED_AND_CLEARED AP_LOOKUP_CODES.DISPLAYED_FIELD%TYPE;
    NLS_PAYMENT_NOT_CLEARED AP_LOOKUP_CODES.DISPLAYED_FIELD%TYPE;
    NLS_CLEAR_DATE_NULL AP_LOOKUP_CODES.DISPLAYED_FIELD%TYPE;
    NLS_CLEAR_AMOUNT_NULL AP_LOOKUP_CODES.DISPLAYED_FIELD%TYPE;
    NLS_NONE_EP AP_LOOKUP_CODES.DISPLAYED_FIELD%TYPE;
  BEGIN
    NLS_ALL := '';
    NLS_YES := '';
    NLS_NO := '';
    NLS_NONE_EP := '';
    SELECT
      LY.MEANING,
      LN.MEANING,
      LA.DISPLAYED_FIELD,
      LNEP.DISPLAYED_FIELD
    INTO NLS_YES,NLS_NO,NLS_ALL,NLS_NONE_EP
    FROM
      FND_LOOKUPS LY,
      FND_LOOKUPS LN,
      AP_LOOKUP_CODES LA,
      AP_LOOKUP_CODES LNEP
    WHERE LY.LOOKUP_TYPE = 'YES_NO'
      AND LY.LOOKUP_CODE = 'Y'
      AND LN.LOOKUP_TYPE = 'YES_NO'
      AND LN.LOOKUP_CODE = 'N'
      AND LA.LOOKUP_TYPE = 'NLS REPORT PARAMETER'
      AND LA.LOOKUP_CODE = 'ALL'
      AND LNEP.LOOKUP_TYPE = 'NLS TRANSLATION'
      AND LNEP.LOOKUP_CODE = 'NONE ELECTRONIC PAYMENT';
    C_NLS_NONE_EP := NLS_NONE_EP;
    C_NLS_YES := NLS_YES;
    C_NLS_NO := NLS_NO;
    C_NLS_ALL := NLS_ALL;
    FND_MESSAGE.SET_NAME('SQLAP'
                        ,'AP_APPRVL_NO_DATA');
    C_NLS_NO_DATA_EXISTS := FND_MESSAGE.GET;
    FND_MESSAGE.SET_NAME('SQLAP'
                        ,'AP_ALL_END_OF_REPORT');
    C_NLS_END_OF_REPORT := FND_MESSAGE.GET;
    BEGIN
      SELECT
        ALC1.DISPLAYED_FIELD,
        ALC2.DISPLAYED_FIELD,
        ALC3.DISPLAYED_FIELD,
        ALC4.DISPLAYED_FIELD,
        ALC5.DISPLAYED_FIELD,
        ALC6.DISPLAYED_FIELD
      INTO NLS_AMOUNT_DIFFERENCE,NLS_CLEARED_BEFORE_ISSUED,NLS_VOIDED_AND_CLEARED,NLS_PAYMENT_NOT_CLEARED,NLS_CLEAR_DATE_NULL,NLS_CLEAR_AMOUNT_NULL
      FROM
        AP_LOOKUP_CODES ALC1,
        AP_LOOKUP_CODES ALC2,
        AP_LOOKUP_CODES ALC3,
        AP_LOOKUP_CODES ALC4,
        AP_LOOKUP_CODES ALC5,
        AP_LOOKUP_CODES ALC6
      WHERE ALC1.LOOKUP_TYPE = 'PAYMENT EXCEPTIONS'
        AND ALC2.LOOKUP_TYPE = 'PAYMENT EXCEPTIONS'
        AND ALC3.LOOKUP_TYPE = 'PAYMENT EXCEPTIONS'
        AND ALC4.LOOKUP_TYPE = 'PAYMENT EXCEPTIONS'
        AND ALC5.LOOKUP_TYPE = 'PAYMENT EXCEPTIONS'
        AND ALC6.LOOKUP_TYPE = 'PAYMENT EXCEPTIONS'
        AND ALC1.LOOKUP_CODE = 'AMOUNT DIFFERENCE'
        AND ALC2.LOOKUP_CODE = 'CLEARED BEFORE ISSUED'
        AND ALC3.LOOKUP_CODE = 'VOIDED AND CLEARED'
        AND ALC4.LOOKUP_CODE = 'PAYMENT NOT CLEARED'
        AND ALC5.LOOKUP_CODE = 'CLEAR DATE NULL'
        AND ALC6.LOOKUP_CODE = 'CLEAR AMOUNT NULL';
      C_NLS_AMOUNT_DIFFERENCE := NLS_AMOUNT_DIFFERENCE;
      C_NLS_CLEARED_BEFORE_ISSUED := NLS_CLEARED_BEFORE_ISSUED;
      C_NLS_VOIDED_AND_CLEARED := NLS_VOIDED_AND_CLEARED;
      C_NLS_PAYMENT_NOT_CLEARED := NLS_PAYMENT_NOT_CLEARED;
      C_NLS_CLEAR_DATE_NULL := NLS_CLEAR_DATE_NULL;
      C_NLS_CLEAR_AMOUNT_NULL := NLS_CLEAR_AMOUNT_NULL;
    END;
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
    LP_BEGIN_DATE:=to_char(P_BEGIN_DATE,'DD-MON-YY');
     LP_END_DATE:=to_char(P_END_DATE,'DD-MON-YY');

    LP_BRANCH_ID:=nvl(P_BRANCH_ID,'All');
    LP_BANK_ACCOUNT_NAME:=nvl(P_BANK_ACCOUNT_NAME,'All');
    LP_CHECK_STOCK:=nvl(P_CHECK_STOCK,'All');
    LP_CHECK_EXC:=nvl(P_CHECK_EXC,'All');
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
      IF (P_DEBUG_SWITCH = 'Y') THEN
        /*SRW.MESSAGE('1'
                   ,'After SRWINIT')*/NULL;
      END IF;
      IF (GET_COMPANY_NAME <> TRUE) THEN
        RAISE INIT_FAILURE;
      END IF;
      IF (P_DEBUG_SWITCH = 'Y') THEN
        /*SRW.MESSAGE('2'
                   ,'After Get_Company_Name')*/NULL;
      END IF;
      IF (GET_NLS_STRINGS <> TRUE) THEN
        RAISE INIT_FAILURE;
      END IF;
      IF (P_DEBUG_SWITCH = 'Y') THEN
        /*SRW.MESSAGE('3'
                   ,'After Get_NLS_Strings')*/NULL;
      END IF;
      IF (GET_BASE_CURR_DATA <> TRUE) THEN
        RAISE INIT_FAILURE;
      END IF;
      IF (P_DEBUG_SWITCH = 'Y') THEN
        /*SRW.MESSAGE('4'
                   ,'After Get_Base_Curr_Data')*/NULL;
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

  FUNCTION C_EXCEPTION_STRINGFORMULA(C_AMOUNT_EXCP IN VARCHAR2
                                    ,C_DATE_EXCP IN VARCHAR2
                                    ,C_VOID_EXCP IN VARCHAR2
                                    ,C_OUST_EXCP IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      L_EXCEPTION_STR VARCHAR2(100);
      L_EXCP_STR_NULL VARCHAR2(1) := 'Y';
    BEGIN
      IF (C_AMOUNT_EXCP IS NOT NULL) THEN
        L_EXCEPTION_STR := C_AMOUNT_EXCP;
        L_EXCP_STR_NULL := 'N';
      END IF;
      IF (C_DATE_EXCP IS NOT NULL) THEN
        IF (L_EXCP_STR_NULL = 'N') THEN
          L_EXCEPTION_STR := L_EXCEPTION_STR || ', ' || C_DATE_EXCP;
        ELSE
          L_EXCEPTION_STR := C_DATE_EXCP;
          L_EXCP_STR_NULL := 'N';
        END IF;
      END IF;
      IF (C_VOID_EXCP IS NOT NULL) THEN
        IF (L_EXCP_STR_NULL = 'N') THEN
          L_EXCEPTION_STR := L_EXCEPTION_STR || ', ' || C_VOID_EXCP;
        ELSE
          L_EXCEPTION_STR := C_VOID_EXCP;
          L_EXCP_STR_NULL := 'N';
        END IF;
      END IF;
      IF (C_OUST_EXCP IS NOT NULL) THEN
        IF (L_EXCP_STR_NULL = 'N') THEN
          L_EXCEPTION_STR := L_EXCEPTION_STR || ', ' || C_OUST_EXCP;
        ELSE
          L_EXCEPTION_STR := C_OUST_EXCP;
        END IF;
      END IF;
      RETURN (L_EXCEPTION_STR);
    END;
    RETURN NULL;
  END C_EXCEPTION_STRINGFORMULA;

  FUNCTION C_CURRENCY_DESCRIPTIONFORMULA(C_CURRENCY_CODE IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      L_CURRENCY_DESC FND_CURRENCIES_VL.NAME%TYPE;
    BEGIN
      SELECT
        SUBSTR(NAME
              ,1
              ,25)
      INTO L_CURRENCY_DESC
      FROM
        FND_CURRENCIES_VL
      WHERE CURRENCY_CODE = C_CURRENCY_CODE;
      RETURN (L_CURRENCY_DESC);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;
    RETURN NULL;
  END C_CURRENCY_DESCRIPTIONFORMULA;

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

  FUNCTION C_NLS_AMOUNT_DIFFERENCE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_NLS_AMOUNT_DIFFERENCE;
  END C_NLS_AMOUNT_DIFFERENCE_P;

  FUNCTION C_NLS_CLEARED_BEFORE_ISSUED_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_NLS_CLEARED_BEFORE_ISSUED;
  END C_NLS_CLEARED_BEFORE_ISSUED_P;

  FUNCTION C_NLS_VOIDED_AND_CLEARED_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_NLS_VOIDED_AND_CLEARED;
  END C_NLS_VOIDED_AND_CLEARED_P;

  FUNCTION C_NLS_PAYMENT_NOT_CLEARED_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_NLS_PAYMENT_NOT_CLEARED;
  END C_NLS_PAYMENT_NOT_CLEARED_P;

  FUNCTION C_NLS_CLEAR_DATE_NULL_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_NLS_CLEAR_DATE_NULL;
  END C_NLS_CLEAR_DATE_NULL_P;

  FUNCTION C_NLS_CLEAR_AMOUNT_NULL_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_NLS_CLEAR_AMOUNT_NULL;
  END C_NLS_CLEAR_AMOUNT_NULL_P;

  FUNCTION C_NLS_END_OF_REPORT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_NLS_END_OF_REPORT;
  END C_NLS_END_OF_REPORT_P;

  FUNCTION C_NLS_NONE_EP_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_NLS_NONE_EP;
  END C_NLS_NONE_EP_P;

END AP_APXCHECC_XMLP_PKG;


/