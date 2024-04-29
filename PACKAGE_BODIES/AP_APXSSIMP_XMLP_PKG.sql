--------------------------------------------------------
--  DDL for Package Body AP_APXSSIMP_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_APXSSIMP_XMLP_PKG" AS
/* $Header: APXSSIMPB.pls 120.0 2007/12/27 08:32:01 vjaganat noship $ */
  FUNCTION GET_NLS_STRINGS RETURN BOOLEAN IS
    NLS_VOID AP_LOOKUP_CODES.DISPLAYED_FIELD%TYPE;
    NLS_NA AP_LOOKUP_CODES.DISPLAYED_FIELD%TYPE;
    NLS_ALL AP_LOOKUP_CODES.DISPLAYED_FIELD%TYPE;
    NLS_YES FND_LOOKUPS.MEANING%TYPE;
    NLS_NO FND_LOOKUPS.MEANING%TYPE;
  BEGIN
    SELECT
      LY.MEANING,
      LN.MEANING,
      L1.DISPLAYED_FIELD,
      L2.DISPLAYED_FIELD,
      L3.DISPLAYED_FIELD
    INTO NLS_YES,NLS_NO,NLS_ALL,NLS_VOID,NLS_NA
    FROM
      FND_LOOKUPS LY,
      FND_LOOKUPS LN,
      AP_LOOKUP_CODES L1,
      AP_LOOKUP_CODES L2,
      AP_LOOKUP_CODES L3
    WHERE LY.LOOKUP_TYPE = 'YES_NO'
      AND LY.LOOKUP_CODE = 'Y'
      AND LN.LOOKUP_TYPE = 'YES_NO'
      AND LN.LOOKUP_CODE = 'N'
      AND L1.LOOKUP_TYPE = 'NLS REPORT PARAMETER'
      AND L1.LOOKUP_CODE = 'ALL'
      AND L2.LOOKUP_TYPE = 'NLS TRANSLATION'
      AND L2.LOOKUP_CODE = 'VOID'
      AND L3.LOOKUP_TYPE = 'NLS REPORT PARAMETER'
      AND L3.LOOKUP_CODE = 'NA';
    C_NLS_YES := NLS_YES;
    C_NLS_NO := NLS_NO;
    C_NLS_ALL := NLS_ALL;
    C_NLS_VOID := NLS_VOID;
    C_NLS_NA := NLS_NA;
    FND_MESSAGE.SET_NAME('SQLAP'
                        ,'AP_APPRVL_NO_DATA');
    FND_MESSAGE.SET_NAME('SQLAP'
                        ,'AP_ALL_END_OF_REPORT');
  /*  C_NLS_NO_DATA_EXISTS := '*** ' || C_NLS_NO_DATA_EXISTS || ' ***';
    C_NLS_END_OF_REPORT := '*** ' || C_NLS_END_OF_REPORT || ' ***'; */
     FND_MESSAGE.GET_TEXT_NUMBER('SQLAP'
                                ,'AP_APPRVL_NO_DATA',
				C_NLS_NO_DATA_EXISTS,
				l_dummy);
    FND_MESSAGE.GET_TEXT_NUMBER('SQLAP'
                               ,'AP_ALL_END_OF_REPORT',
			       C_NLS_END_OF_REPORT,
			       l_dummy);
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
      L_VENDOR_SITE_ID NUMBER;
      L_RETURN_STATUS VARCHAR2(50);
      L_MSG_COUNT NUMBER;
      L_MSG_DATA VARCHAR2(2000);
    BEGIN
      P_DEBUG_SWITCH := 'Y';
      C_REPORT_START_DATE := SYSDATE;
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      IF (P_DEBUG_SWITCH in ('y','Y')) THEN
        NULL;
      END IF;
      IF (GET_COMPANY_NAME <> TRUE) THEN
        RAISE INIT_FAILURE;
      END IF;
      IF (P_DEBUG_SWITCH in ('y','Y')) THEN
        NULL;
      END IF;
      IF (GET_NLS_STRINGS <> TRUE) THEN
        RAISE INIT_FAILURE;
      END IF;
      IF (P_DEBUG_SWITCH in ('y','Y')) THEN
        NULL;
      END IF;
      AP_VENDOR_PUB_PKG.IMPORT_VENDOR_SITES(P_API_VERSION => 1.0
                                           ,P_SOURCE => 'IMPORT'
                                           ,P_WHAT_TO_IMPORT => P_WHAT_TO_IMPORT
                                           ,P_COMMIT_SIZE => P_COMMIT_SIZE
                                           ,X_RETURN_STATUS => L_RETURN_STATUS
                                           ,X_MSG_COUNT => L_MSG_COUNT
                                           ,X_MSG_DATA => L_MSG_DATA);
      IF (P_DEBUG_SWITCH in ('y','Y')) THEN
        NULL;
      END IF;
      IF (GET_HEADER_INFORMATION <> TRUE) THEN
        RAISE INIT_FAILURE;
      END IF;
      IF (P_DEBUG_SWITCH in ('y','Y')) THEN
        NULL;
      END IF;
      IF (P_DEBUG_SWITCH in ('y','Y')) THEN
        NULL;
      END IF;
      RETURN (TRUE);
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20101
                               ,NULL);
    END;
    RETURN (TRUE);
  END BEFOREREPORT;
  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    UPDATE
      AP_SUPPLIER_SITES_INT
    SET
      IMPORT_REQUEST_ID = NULL
    WHERE STATUS <> 'PROCESSED'
      AND IMPORT_REQUEST_ID = P_CONC_REQUEST_ID;
    BEGIN
      IF (P_DEBUG_SWITCH = 'Y') THEN
        NULL;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20101
                               ,NULL);
    END;
    RETURN (TRUE);
  END AFTERREPORT;
  FUNCTION GET_COMPANY_NAME RETURN BOOLEAN IS
    L_CHART_OF_ACCOUNTS_ID GL_SETS_OF_BOOKS.CHART_OF_ACCOUNTS_ID%TYPE;
    L_NAME GL_SETS_OF_BOOKS.NAME%TYPE;
    L_SOB_ID NUMBER;
  BEGIN
    IF P_SET_OF_BOOKS_ID IS NULL THEN
      FND_PROFILE.GET('GL_SET_OF_BKS_ID'
                     ,L_SOB_ID);
    ELSE
      L_SOB_ID := P_SET_OF_BOOKS_ID;
    END IF;
    IF L_SOB_ID IS NOT NULL THEN
      SELECT
        NAME,
        CHART_OF_ACCOUNTS_ID
      INTO L_NAME,L_CHART_OF_ACCOUNTS_ID
      FROM
        GL_SETS_OF_BOOKS
      WHERE SET_OF_BOOKS_ID = L_SOB_ID;
      C_COMPANY_NAME_HEADER := L_NAME;
      C_CHART_OF_ACCOUNTS_ID := L_CHART_OF_ACCOUNTS_ID;
    END IF;
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END GET_COMPANY_NAME;
  FUNCTION GET_HEADER_INFORMATION RETURN BOOLEAN IS
  BEGIN
    SELECT
      DISPLAYED_FIELD
    INTO C_IMPORT_OPTIONS
    FROM
      AP_LOOKUP_CODES
    WHERE LOOKUP_TYPE = 'AP_IMPORT_OPTIONS'
      AND LOOKUP_CODE = P_WHAT_TO_IMPORT;
    IF P_PRINT_EXCEPTIONS = 'Y' THEN
      C_PRINT_EXCEPTIONS := C_NLS_YES;
    ELSE
      C_PRINT_EXCEPTIONS := C_NLS_NO;
    END IF;
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END GET_HEADER_INFORMATION;
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
  FUNCTION C_NLS_VOID_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_NLS_VOID;
  END C_NLS_VOID_P;
  FUNCTION C_NLS_NA_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_NLS_NA;
  END C_NLS_NA_P;
  FUNCTION C_NLS_END_OF_REPORT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_NLS_END_OF_REPORT;
  END C_NLS_END_OF_REPORT_P;
  FUNCTION C_REPORT_START_DATE_P RETURN DATE IS
  BEGIN
    RETURN C_REPORT_START_DATE;
  END C_REPORT_START_DATE_P;
  FUNCTION C_COMPANY_NAME_HEADER_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_COMPANY_NAME_HEADER;
  END C_COMPANY_NAME_HEADER_P;
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
  FUNCTION C_CHART_OF_ACCOUNTS_ID_P RETURN NUMBER IS
  BEGIN
    RETURN C_CHART_OF_ACCOUNTS_ID;
  END C_CHART_OF_ACCOUNTS_ID_P;
  FUNCTION APPLICATIONS_TEMPLATE_REPORT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN APPLICATIONS_TEMPLATE_REPORT;
  END APPLICATIONS_TEMPLATE_REPORT_P;
  FUNCTION C_IMPORT_OPTIONS_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_IMPORT_OPTIONS;
  END C_IMPORT_OPTIONS_P;
  FUNCTION C_PRINT_EXCEPTIONS_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_PRINT_EXCEPTIONS;
  END C_PRINT_EXCEPTIONS_P;
END AP_APXSSIMP_XMLP_PKG;


/
