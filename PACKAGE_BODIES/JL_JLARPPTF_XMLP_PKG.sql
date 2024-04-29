--------------------------------------------------------
--  DDL for Package Body JL_JLARPPTF_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_JLARPPTF_XMLP_PKG" AS
/* $Header: JLARPPTFB.pls 120.2 2008/01/11 07:52:18 abraghun noship $ */
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
    C_NLS_NO_DATA_EXISTS := FND_MESSAGE.GET;
    FND_MESSAGE.SET_NAME('SQLAP'
                        ,'AP_ALL_END_OF_REPORT');
    C_NLS_END_OF_REPORT := FND_MESSAGE.GET;
    C_NLS_NO_DATA_EXISTS := '*** ' || C_NLS_NO_DATA_EXISTS || ' ***';
    C_NLS_END_OF_REPORT := '*** ' || C_NLS_END_OF_REPORT || ' ***';
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
      C_REPORT_START_DATE := SYSDATE;
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
      IF (P_DEBUG_SWITCH in ('y','Y')) THEN
        /*SRW.MESSAGE('1'
                   ,'After SRWINIT')*/NULL;
      END IF;
      IF POPULATE_TRL <> TRUE THEN
        NULL;
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
      ZX_EXTRACT_PKG.PURGE(P_CONC_REQUEST_ID);
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  EXCEPTION
    WHEN OTHERS THEN
      /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
  END AFTERREPORT;

  FUNCTION GET_COMPANY_NAME RETURN BOOLEAN IS
    L_CHART_OF_ACCOUNTS_ID GL_SETS_OF_BOOKS.CHART_OF_ACCOUNTS_ID%TYPE;
    L_NAME GL_SETS_OF_BOOKS.NAME%TYPE;
    L_SOB_ID NUMBER;
  BEGIN
    IF P_SET_OF_BOOKS_ID IS NOT NULL THEN
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
    END IF;
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END GET_COMPANY_NAME;

  FUNCTION C_PERCEPTION_AMT_CHARFORMULA(PERCEPTION_AMOUNT IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN (LPAD(LTRIM(TO_CHAR(ROUND(PERCEPTION_AMOUNT
                                   ,2)
                             ,'9999999999999.99'))
               ,16
               ,' '));
  END C_PERCEPTION_AMT_CHARFORMULA;

  FUNCTION POPULATE_TRL RETURN BOOLEAN IS
  BEGIN
    /*SRW.MESSAGE('01'
               ,'Call to TRL API : zx_extract_pkg.populate_tax_data')*/NULL;
    ZX_EXTRACT_PKG.POPULATE_TAX_DATA(P_REPORTING_LEVEL => P_REPORTING_LEVEL
                                    ,P_REPORTING_CONTEXT => P_REPORTING_ENTITY_ID
                                    ,P_LEGAL_ENTITY_ID => P_LEGAL_ENTITY_ID
                                    ,P_SUMMARY_LEVEL => 'TRANSACTION_DISTRIBUTION'
                                    ,P_LEDGER_ID => P_SET_OF_BOOKS_ID
                                    ,P_REGISTER_TYPE => 'ALL'
                                    ,P_PRODUCT => 'AP'
                                    ,P_MATRIX_REPORT => 'N'
                                    ,P_CURRENCY_CODE_LOW => NULL
                                    ,P_CURRENCY_CODE_HIGH => NULL
                                    ,P_INCLUDE_AP_STD_TRX_CLASS => 'Y'
                                    ,P_INCLUDE_AP_DM_TRX_CLASS => 'Y'
                                    ,P_INCLUDE_AP_CM_TRX_CLASS => 'N'
                                    ,P_INCLUDE_AP_PREP_TRX_CLASS => 'Y'
                                    ,P_INCLUDE_AP_MIX_TRX_CLASS => 'N'
                                    ,P_INCLUDE_AP_EXP_TRX_CLASS => 'N'
                                    ,P_INCLUDE_AP_INT_TRX_CLASS => 'N'
                                    ,P_INCLUDE_AR_INV_TRX_CLASS => 'N'
                                    ,P_INCLUDE_AR_APPL_TRX_CLASS => 'N'
                                    ,P_INCLUDE_AR_ADJ_TRX_CLASS => 'N'
                                    ,P_INCLUDE_AR_MISC_TRX_CLASS => 'N'
                                    ,P_INCLUDE_AR_BR_TRX_CLASS => 'N'
                                    ,P_INCLUDE_GL_MANUAL_LINES => 'N'
                                    ,P_TRX_NUMBER_LOW => NULL
                                    ,P_TRX_NUMBER_HIGH => NULL
                                    ,P_EXTRACT_REPORT_LINE_NUMBER => NULL
                                    ,P_AR_TRX_PRINTING_STATUS => NULL
                                    ,P_AR_EXEMPTION_STATUS => NULL
                                    ,P_GL_DATE_LOW => P_GL_DATE_FROM
                                    ,P_GL_DATE_HIGH => P_GL_DATE_TO
                                    ,P_TRX_DATE_LOW => NULL
                                    ,P_TRX_DATE_HIGH => NULL
                                    ,P_ACCOUNTING_STATUS => 'ACCOUNTED'
                                    ,P_GL_PERIOD_NAME_LOW => NULL
                                    ,P_GL_PERIOD_NAME_HIGH => NULL
                                    ,P_TRX_DATE_PERIOD_NAME_LOW => NULL
                                    ,P_TRX_DATE_PERIOD_NAME_HIGH => NULL
                                    ,P_TAX_REGIME_CODE => NULL
                                    ,P_TAX => NULL
                                    ,P_TAX_STATUS_CODE => NULL
                                    ,P_TAX_RATE_CODE_LOW => NULL
                                    ,P_TAX_RATE_CODE_HIGH => NULL
                                    ,P_TAX_TYPE_CODE_LOW => NULL
                                    ,P_TAX_TYPE_CODE_HIGH => NULL
                                    ,P_DOCUMENT_SUB_TYPE => NULL
                                    ,P_TRX_BUSINESS_CATEGORY => NULL
                                    ,P_TAX_INVOICE_DATE_LOW => NULL
                                    ,P_TAX_INVOICE_DATE_HIGH => NULL
                                    ,P_POSTING_STATUS => 'ACCOUNTED'
                                    ,P_EXTRACT_ACCTED_TAX_LINES => NULL
                                    ,P_INCLUDE_ACCOUNTING_SEGMENTS => NULL
                                    ,P_BALANCING_SEGMENT_LOW => NULL
                                    ,P_BALANCING_SEGMENT_HIGH => NULL
                                    ,P_INCLUDE_DISCOUNTS => NULL
                                    ,P_EXTRACT_STARTING_LINE_NUM => NULL
                                    ,P_REQUEST_ID => P_CONC_REQUEST_ID
                                    ,P_REPORT_NAME => 'JLARPPTF'
                                    ,P_VAT_TRANSACTION_TYPE_CODE => NULL
                                    ,P_INCLUDE_FULLY_NR_TAX_FLAG => NULL
                                    ,P_MUNICIPAL_TAX_TYPE_CODE_LOW => NULL
                                    ,P_MUNICIPAL_TAX_TYPE_CODE_HIGH => NULL
                                    ,P_PROV_TAX_TYPE_CODE_LOW => NULL
                                    ,P_PROV_TAX_TYPE_CODE_HIGH => NULL
                                    ,P_EXCISE_TAX_TYPE_CODE_LOW => NULL
                                    ,P_EXCISE_TAX_TYPE_CODE_HIGH => NULL
                                    ,P_NON_TAXABLE_TAX_TYPE_CODE => NULL
                                    ,P_PER_TAX_TYPE_CODE_LOW => P_VAT_PERCEP_TAX_TYPE
                                    ,P_PER_TAX_TYPE_CODE_HIGH => P_VAT_PERCEP_TAX_TYPE
                                    ,P_VAT_TAX_TYPE_CODE => NULL
                                    ,P_EXCISE_TAX => NULL
                                    ,P_VAT_ADDITIONAL_TAX => NULL
                                    ,P_VAT_NON_TAXABLE_TAX => NULL
                                    ,P_VAT_NOT_TAX => NULL
                                    ,P_VAT_PERCEPTION_TAX => NULL
                                    ,P_VAT_TAX => NULL
                                    ,P_INC_SELF_WD_TAX => NULL
                                    ,P_EXCLUDING_TRX_LETTER => NULL
                                    ,P_TRX_LETTER_LOW => NULL
                                    ,P_TRX_LETTER_HIGH => NULL
                                    ,P_INCLUDE_REFERENCED_SOURCE => NULL
                                    ,P_PARTY_NAME => NULL
                                    ,P_BATCH_NAME => NULL
                                    ,P_BATCH_DATE_LOW => NULL
                                    ,P_BATCH_DATE_HIGH => NULL
                                    ,P_BATCH_SOURCE_ID => NULL
                                    ,P_ADJUSTED_DOC_FROM => NULL
                                    ,P_ADJUSTED_DOC_TO => NULL
                                    ,P_STANDARD_VAT_TAX_RATE => NULL
                                    ,P_MUNICIPAL_TAX => NULL
                                    ,P_PROVINCIAL_TAX => NULL
                                    ,P_TAX_ACCOUNT_LOW => NULL
                                    ,P_TAX_ACCOUNT_HIGH => NULL
                                    ,P_EXP_CERT_DATE_FROM => NULL
                                    ,P_EXP_CERT_DATE_TO => NULL
                                    ,P_EXP_METHOD => NULL
                                    ,P_PRINT_COMPANY_INFO => 'Y'
                                    ,P_REPRINT => 'N'
                                    ,P_ERRBUF => P_ERRBUF
                                    ,P_RETCODE => P_RETCODE);
    IF P_RETCODE <> 0 THEN
      /*SRW.MESSAGE('100'
                 ,'TRL: Return Code : ' || P_RETCODE)*/NULL;
      /*SRW.MESSAGE('101'
                 ,'TRL: Error Buffer : ' || P_ERRBUF)*/NULL;
      RETURN (FALSE);
    ELSE
      RETURN (TRUE);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      /*SRW.MESSAGE('102'
                 ,SQLERRM)*/NULL;
      RETURN (FALSE);
  END POPULATE_TRL;

  FUNCTION GET_FORMATTED_DOCNUM(P_DOC_NUM IN VARCHAR2) RETURN VARCHAR2 IS
    L_DOC_NUM VARCHAR2(50);
    L_DOCUMENT_NUM VARCHAR2(20);
    BRANCH_NUM VARCHAR2(4);
    DOC_NUM VARCHAR2(20);
    L_DASH NUMBER(2);
    L_SPACE NUMBER(2);
    BRANCH_DOC_NUM VARCHAR2(24);
  BEGIN
    L_DOC_NUM := TRANSLATE(P_DOC_NUM
                          ,'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
                          ,'0123456789');
    L_DASH := INSTR(L_DOC_NUM
                   ,'-'
                   ,1
                   ,1);
    L_SPACE := INSTR(L_DOC_NUM
                    ,' '
                    ,1
                    ,1);
    IF L_DASH < L_SPACE AND L_SPACE <> 0 THEN
      BRANCH_NUM := LPAD(NVL(SUBSTR(L_DOC_NUM
                                   ,1
                                   ,L_DASH - 1)
                            ,'0')
                        ,4
                        ,'0');
      L_DOCUMENT_NUM := TRANSLATE(SUBSTR(L_DOC_NUM
                                        ,L_DASH + 1
                                        ,20)
                                 ,'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz- '
                                 ,'0123456789');
    END IF;
    IF L_SPACE < L_DASH AND L_DASH <> 0 THEN
      BRANCH_NUM := LPAD(NVL(SUBSTR(L_DOC_NUM
                                   ,1
                                   ,L_SPACE - 1)
                            ,'0')
                        ,4
                        ,'0');
      L_DOCUMENT_NUM := TRANSLATE(SUBSTR(L_DOC_NUM
                                        ,L_SPACE + 1
                                        ,20)
                                 ,'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz- '
                                 ,'0123456789');
    END IF;
    IF L_DASH <= 4 AND L_DASH > 0 AND L_SPACE = 0 THEN
      BRANCH_NUM := LPAD(NVL(SUBSTR(L_DOC_NUM
                                   ,1
                                   ,L_DASH - 1)
                            ,'0')
                        ,4
                        ,'0');
      L_DOCUMENT_NUM := TRANSLATE(SUBSTR(L_DOC_NUM
                                        ,L_DASH + 1
                                        ,20)
                                 ,'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz- '
                                 ,'0123456789');
    ELSIF L_DASH <> 0 AND L_SPACE = 0 THEN
      BRANCH_NUM := LPAD(NVL(SUBSTR(L_DOC_NUM
                                   ,1
                                   ,4)
                            ,'0')
                        ,4
                        ,'0');
      L_DOCUMENT_NUM := TRANSLATE(SUBSTR(L_DOC_NUM
                                        ,L_DASH + 1
                                        ,20)
                                 ,'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz- '
                                 ,'0123456789');
    END IF;
    IF L_SPACE <= 4 AND L_SPACE > 0 AND L_DASH = 0 THEN
      BRANCH_NUM := LPAD(NVL(SUBSTR(L_DOC_NUM
                                   ,1
                                   ,L_SPACE - 1)
                            ,'0')
                        ,4
                        ,'0');
      L_DOCUMENT_NUM := TRANSLATE(SUBSTR(L_DOC_NUM
                                        ,L_SPACE + 1
                                        ,20)
                                 ,'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz- '
                                 ,'0123456789');
    ELSIF L_SPACE <> 0 AND L_DASH = 0 THEN
      BRANCH_NUM := LPAD(NVL(SUBSTR(L_DOC_NUM
                                   ,1
                                   ,4)
                            ,'0')
                        ,4
                        ,'0');
      L_DOCUMENT_NUM := TRANSLATE(SUBSTR(L_DOC_NUM
                                        ,L_SPACE + 1
                                        ,20)
                                 ,'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz- '
                                 ,'0123456789');
    END IF;
    IF L_SPACE = 0 AND L_DASH = 0 THEN
      BRANCH_NUM := LPAD(NVL(SUBSTR(L_DOC_NUM
                                   ,1
                                   ,4)
                            ,'0')
                        ,4
                        ,'0');
      L_DOCUMENT_NUM := TRANSLATE(SUBSTR(L_DOC_NUM
                                        ,5
                                        ,20)
                                 ,'0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz- '
                                 ,'0123456789');
    END IF;
    DOC_NUM := LPAD(L_DOCUMENT_NUM
                   ,20
                   ,'0');
    BRANCH_DOC_NUM := BRANCH_NUM || DOC_NUM;
    RETURN (BRANCH_DOC_NUM);
  END GET_FORMATTED_DOCNUM;

  FUNCTION DOC_NUMBERFORMULA(DOC_NUM IN VARCHAR2) RETURN VARCHAR2 IS
    L_BRANCH VARCHAR2(4);
    L_DOC_NUM VARCHAR2(8);
    L_BRANCH_DOC VARCHAR2(24);
  BEGIN
    L_BRANCH_DOC := GET_FORMATTED_DOCNUM(DOC_NUM);
    L_BRANCH := SUBSTR(L_BRANCH_DOC
                      ,1
                      ,4);
    L_DOC_NUM := SUBSTR(L_BRANCH_DOC
                       ,17
                       ,8);
    RETURN (L_BRANCH || L_DOC_NUM);
  END DOC_NUMBERFORMULA;

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

END JL_JLARPPTF_XMLP_PKG;



/
