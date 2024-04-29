--------------------------------------------------------
--  DDL for Package Body ZX_ZXAPJAJL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_ZXAPJAJL_XMLP_PKG" AS
/* $Header: ZXAPJAJLB.pls 120.1.12010000.1 2008/07/28 13:27:45 appldev ship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
    ERRBUF VARCHAR2(2000);
    RETCODE NUMBER;
    INIT_FAILURE EXCEPTION;
  BEGIN
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    LP_TAX_REGISTER_TYPE := P_TAX_REGISTER_TYPE;
    LP_PRODUCT := P_PRODUCT;
    IF INITIALIZE <> TRUE THEN
      RAISE INIT_FAILURE;
    END IF;
    IF GET_GL_DATE <> TRUE THEN
      RAISE INIT_FAILURE;
    END IF;
    IF CALL_TRL_ENGINE <> TRUE THEN
      RAISE INIT_FAILURE;
    END IF;
    SELECT
      COUNT(1)
    INTO CP_TRL_ROW_COUNT
    FROM
      ZX_REP_CONTEXT_T CON,
      ZX_REP_TRX_DETAIL_T DET
    WHERE CON.REQUEST_ID = P_CONC_REQUEST_ID
      AND DET.REQUEST_ID = CON.REQUEST_ID
      AND NVL(DET.REP_CONTEXT_ID
       ,CON.REP_CONTEXT_ID) = CON.REP_CONTEXT_ID;
    RETURN (TRUE);
  EXCEPTION
    WHEN INIT_FAILURE THEN
      RETURN (FALSE);

    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20101
                             ,NULL);

  END BEFOREREPORT;

  FUNCTION INITIALIZE RETURN BOOLEAN IS
    NLS_NO_DATA_FOUND VARCHAR2(50);
    NLS_END_OF_REPORT VARCHAR2(50);
    L_CANONICAL_DATE VARCHAR2(1000);
  BEGIN
    FND_MO_REPORTING_API.INITIALIZE(P_REP_CONTEXT_LVL_MNG
                                   ,P_REP_CONTEXT_ENTITY_NAME
                                   ,'AUTO');
    CP_REPORTING_LEVEL_NAME := FND_MO_REPORTING_API.GET_REPORTING_LEVEL_NAME;
    CP_REPORTING_ENTITY_NAME := FND_MO_REPORTING_API.GET_REPORTING_ENTITY_NAME;
    FND_MESSAGE.SET_NAME('JL'
                        ,'JL_ZZ_NO_DATA_FOUND');
    NLS_NO_DATA_FOUND := '**** ' || SUBSTR(FND_MESSAGE.GET
                               ,1
                               ,35) || ' ****';
    FND_MESSAGE.SET_NAME('JL'
                        ,'JL_ZZ_END_OF_REPORT');
    NLS_END_OF_REPORT := '**** ' || SUBSTR(FND_MESSAGE.GET
                               ,1
                               ,35) || ' ****';
    CP_NO_DATA_FOUND := NLS_NO_DATA_FOUND;
    CP_END_OF_REPORT := NLS_END_OF_REPORT;
    SELECT
      MEANING
    INTO CP_NLS_YES
    FROM
      FND_LOOKUPS
    WHERE LOOKUP_TYPE = 'YES_NO'
      AND LOOKUP_CODE = 'Y';
    SELECT
      MEANING
    INTO CP_NLS_NO
    FROM
      FND_LOOKUPS
    WHERE LOOKUP_TYPE = 'YES_NO'
      AND LOOKUP_CODE = 'N';
    SELECT
      L1.DISPLAYED_FIELD,
      L2.DISPLAYED_FIELD,
      L3.DISPLAYED_FIELD
    INTO CP_NLS_ALL,CP_NLS_VOID,CP_NLS_NA
    FROM
      AP_LOOKUP_CODES L1,
      AP_LOOKUP_CODES L2,
      AP_LOOKUP_CODES L3
    WHERE L1.LOOKUP_TYPE = 'NLS REPORT PARAMETER'
      AND L1.LOOKUP_CODE = 'ALL'
      AND L2.LOOKUP_TYPE = 'NLS TRANSLATION'
      AND L2.LOOKUP_CODE = 'VOID'
      AND L3.LOOKUP_TYPE = 'NLS REPORT PARAMETER'
      AND L3.LOOKUP_CODE = 'NA';
    BEGIN
      L_CANONICAL_DATE := FND_DATE.DATE_TO_CANONICAL(P_GL_DATE_LOW);
      P_TW_GL_DATE_LOW := TO_CHAR(TO_NUMBER(SUBSTRB(L_CANONICAL_DATE
                                                   ,1
                                                   ,4)) - 1911) || '/' || SUBSTRB(L_CANONICAL_DATE
                                 ,6
                                 ,5);
      L_CANONICAL_DATE := FND_DATE.DATE_TO_CANONICAL(P_GL_DATE_HIGH);
      P_TW_GL_DATE_HIGH := TO_CHAR(TO_NUMBER(SUBSTRB(L_CANONICAL_DATE
                                                    ,1
                                                    ,4)) - 1911) || '/' || SUBSTRB(L_CANONICAL_DATE
                                  ,6
                                  ,5);
      L_CANONICAL_DATE := FND_DATE.DATE_TO_CANONICAL(P_TRX_DATE_LOW);
      P_TW_TRX_DATE_LOW := TO_CHAR(TO_NUMBER(SUBSTRB(L_CANONICAL_DATE
                                                    ,1
                                                    ,4)) - 1911) || '/' || SUBSTRB(L_CANONICAL_DATE
                                  ,6
                                  ,5);
      L_CANONICAL_DATE := FND_DATE.DATE_TO_CANONICAL(P_TRX_DATE_HIGH);
      P_TW_TRX_DATE_HIGH := TO_CHAR(TO_NUMBER(SUBSTRB(L_CANONICAL_DATE
                                                     ,1
                                                     ,4)) - 1911) || '/' || SUBSTRB(L_CANONICAL_DATE
                                   ,6
                                   ,5);
      FND_PROFILE.GET('RESP_NAME'
                     ,P_RESPONSIBILITY_NAME);
      FND_PROFILE.GET('USER_NAME'
                     ,P_USER_NAME);
      IF P_REP_CONTEXT_LVL_MNG = '1000' THEN
        SELECT
          SOB.NAME
        INTO P_COMPANY_NAME_DESC
        FROM
          GL_SETS_OF_BOOKS SOB
        WHERE SET_OF_BOOKS_ID = P_REP_CONTEXT_ENTITY_NAME;
      ELSIF P_REP_CONTEXT_LVL_MNG = '2000' THEN
        SELECT
          LEDGER_NAME
        INTO P_COMPANY_NAME_DESC
        FROM
          GL_LEDGER_LE_V
        WHERE LEGAL_ENTITY_ID = P_REP_CONTEXT_ENTITY_NAME;
      ELSIF P_REP_CONTEXT_LVL_MNG = '3000' THEN
        SELECT
          SOB.NAME
        INTO P_COMPANY_NAME_DESC
        FROM
          HR_OPERATING_UNITS HR,
          GL_SETS_OF_BOOKS SOB
        WHERE HR.SET_OF_BOOKS_ID = SOB.SET_OF_BOOKS_ID
          AND HR.ORGANIZATION_ID = P_REP_CONTEXT_ENTITY_NAME;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;

    END;
    IF GET_DATE_FORMAT <> TRUE THEN
      RETURN FALSE;
    END IF;
    IF SET_REPORT_TITLE <> TRUE THEN
      RETURN FALSE;
    END IF;
    RETURN (TRUE);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);

  END INITIALIZE;

  FUNCTION GET_GL_DATE RETURN BOOLEAN IS
    L_START_DATE DATE;
    L_END_DATE DATE;
  BEGIN
    RETURN (TRUE);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);

  END GET_GL_DATE;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    IF P_REPORT_NAME = 'ZXTWPSPC' THEN
      COMMIT;
    END IF;
    BEGIN
      ZX_EXTRACT_PKG.PURGE(P_CONC_REQUEST_ID);
    EXCEPTION
      WHEN OTHERS THEN
        NULL;

    END;
    RETURN (TRUE);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20101
                             ,NULL);

  END AFTERREPORT;

  FUNCTION CALL_TRL_ENGINE RETURN BOOLEAN IS
    L_TAX_CLASS VARCHAR2(1);
    L_PRODUCT VARCHAR2(15);
    L_POSTING_STATUS VARCHAR2(15);
    L_TRX_DATE_LOW DATE;
    L_TRX_DATE_HIGH DATE;
    L_TRX_NUMBER_LOW VARCHAR2(30);
    L_TRX_NUMBER_HIGH VARCHAR2(30);
    L_APPLIED_TRX_NUMBER_LOW VARCHAR2(30);
    L_APPLIED_TRX_NUMBER_HIGH VARCHAR2(30);
    L_SUMMARY_LEVEL VARCHAR2(30);
    L_TRADING_PARTNER_ID VARCHAR2(200);
    L_RETCODE NUMBER;
    L_ERRBUF VARCHAR2(2000);
  BEGIN
    L_POSTING_STATUS := 'POSTED';
    IF P_REPORT_NAME in ('ZXTWPPRD') THEN
      L_POSTING_STATUS := NULL;
    ELSIF P_REPORT_NAME in ('ZXTWSEDI') THEN
      L_POSTING_STATUS := 'ALL';
    END IF;
    L_TRX_DATE_LOW := P_TRX_DATE_LOW;
    L_TRX_DATE_HIGH := P_TRX_DATE_HIGH;
    IF P_REPORT_NAME in ('ZXTWPSPC') THEN
      L_TRX_DATE_LOW := P_CD_DATE_FROM;
      L_TRX_DATE_HIGH := P_CD_DATE_TO;
      L_TRX_NUMBER_LOW := P_CD_NUMBER_FROM;
      L_TRX_NUMBER_HIGH := P_CD_NUMBER_TO;
      L_APPLIED_TRX_NUMBER_LOW := P_GUI_NUMBER_FROM;
      L_APPLIED_TRX_NUMBER_HIGH := P_GUI_NUMBER_TO;
    END IF;
    L_SUMMARY_LEVEL := 'TRANSACTION_LINE';
    IF P_REPORT_NAME in ('ZXTWPSPC','ZXARPCFF','ZXARPTFF') THEN
      L_SUMMARY_LEVEL := 'TRANSACTION_LINE';
    END IF;
    IF (P_REPORT_NAME in ('ZXTWPVAT','ZXTWPSPC','ZXCLPPLR')) THEN
      L_SUMMARY_LEVEL := 'TRANSACTION_DISTRIBUTION';
    END IF;
    IF P_TAX_REGISTER_TYPE IS NULL THEN
      LP_TAX_REGISTER_TYPE := 'ALL';
    END IF;
    IF (P_REPORT_NAME = 'ZXSGAGAL') THEN
      LP_PRODUCT := 'AP';
    END IF;
    ZX_EXTRACT_PKG.POPULATE_TAX_DATA(P_REPORTING_LEVEL => P_REP_CONTEXT_LVL_MNG
                                    ,P_REPORTING_CONTEXT => P_REP_CONTEXT_ENTITY_NAME
                                    ,P_LEGAL_ENTITY_ID => P_COMPANY_NAME
                                    ,P_REPORT_NAME => P_REPORT_NAME
                                    ,P_LEDGER_ID => P_LEDGER_ID
                                    ,P_REGISTER_TYPE => LP_TAX_REGISTER_TYPE
                                    ,P_SUMMARY_LEVEL => L_SUMMARY_LEVEL
                                    ,P_PRODUCT => LP_PRODUCT
                                    ,P_TRX_DATE_LOW => L_TRX_DATE_LOW
                                    ,P_TRX_DATE_HIGH => L_TRX_DATE_HIGH
                                    ,P_GL_DATE_LOW => P_GL_DATE_LOW
                                    ,P_GL_DATE_HIGH => P_GL_DATE_HIGH
                                    ,P_GL_PERIOD_NAME_LOW => P_ACCT_PERIOD_FROM
                                    ,P_GL_PERIOD_NAME_HIGH => P_ACCT_PERIOD_TO
                                    ,P_TRX_NUMBER_LOW => L_TRX_NUMBER_LOW
                                    ,P_TRX_NUMBER_HIGH => L_TRX_NUMBER_HIGH
                                    ,P_INCLUDE_AP_STD_TRX_CLASS => P_INCLUDE_AP_STD_TRX_CLASS
                                    ,P_INCLUDE_AP_CM_TRX_CLASS => P_INCLUDE_AP_CM_TRX_CLASS
                                    ,P_INCLUDE_AP_DM_TRX_CLASS => P_INCLUDE_AP_DM_TRX_CLASS
                                    ,P_INCLUDE_AP_EXP_TRX_CLASS => P_INCLUDE_AP_EXP_TRX_CLASS
                                    ,P_INCLUDE_AP_PREP_TRX_CLASS => P_INCLUDE_AP_PREP_TRX_CLASS
                                    ,P_INCLUDE_AP_MIX_TRX_CLASS => P_INCLUDE_AP_MIX_TRX_CLASS
                                    ,P_INCLUDE_AP_INT_TRX_CLASS => P_INCLUDE_AP_INT_TRX_CLASS
                                    ,P_INCLUDE_GL_MANUAL_LINES => P_INCLUDE_GL_MANUAL_LINES
                                    ,P_INCLUDE_AR_INV_TRX_CLASS => P_INCLUDE_AR_INV_TRX_CLASS
                                    ,P_INCLUDE_AR_APPL_TRX_CLASS => 'N'
                                    ,P_INCLUDE_AR_ADJ_TRX_CLASS => 'N'
                                    ,P_INCLUDE_AR_MISC_TRX_CLASS => 'N'
                                    ,P_INCLUDE_AR_BR_TRX_CLASS => 'N'
                                    ,P_POSTING_STATUS => L_POSTING_STATUS
                                    ,P_DOCUMENT_SUB_TYPE => P_GUI_TYPE
                                    ,P_REPRINT => P_REPRINT
                                    ,P_ADJUSTED_DOC_FROM => P_GUI_NUMBER_FROM
                                    ,P_ADJUSTED_DOC_TO => P_GUI_NUMBER_TO
                                    ,P_BATCH_DATE_LOW => P_BATCH_DATE_FROM
                                    ,P_BATCH_DATE_HIGH => P_BATCH_DATE_TO
                                    ,P_BATCH_NAME => P_BATCH_NAME
                                    ,P_MATRIX_REPORT => 'N'
                                    ,P_TAX_REGIME_CODE => P_TAX_REGIME
                                    ,P_TAX_RATE_CODE_LOW => P_TAX_CODE_LOW
                                    ,P_TAX_RATE_CODE_HIGH => P_TAX_CODE_HIGH
                                    ,P_TAX_TYPE_CODE_LOW => P_TAX_TYPE_LOW
                                    ,P_TAX_TYPE_CODE_HIGH => P_TAX_TYPE_HIGH
                                    ,P_INCLUDE_FULLY_NR_TAX_FLAG => 'N'
                                    ,P_VAT_TAX_TYPE_CODE => P_VAT_TAX_TYPE
                                    ,P_NON_TAXABLE_TAX_TYPE_CODE => P_NON_TAXABLE_TYPE
                                    ,P_VAT_PERCEPTION_TAX => P_VAT_PERC_TAX_TYPE
                                    ,P_EXCISE_TAX_TYPE_CODE_LOW => P_EXCISE_TAX_TYPE_FROM
                                    ,P_EXCISE_TAX_TYPE_CODE_HIGH => P_EXCISE_TAX_TYPE_TO
                                    ,P_MUNICIPAL_TAX_TYPE_CODE_LOW => P_MUNI_TAX_TYPE_FROM
                                    ,P_MUNICIPAL_TAX_TYPE_CODE_HIGH => P_MUNI_TAX_TYPE_TO
                                    ,P_PER_TAX_TYPE_CODE_LOW => P_PERC_TAX_TYPE_FROM
                                    ,P_PER_TAX_TYPE_CODE_HIGH => P_PERC_TAX_TYPE_TO
                                    ,P_PROV_TAX_TYPE_CODE_LOW => P_PROV_TAX_TYPE_FROM
                                    ,P_PROV_TAX_TYPE_CODE_HIGH => P_PROV_TAX_TYPE_TO
                                    ,P_EXCLUDING_TRX_LETTER => P_EXCLUDING_TRX_LETTER
                                    ,P_TRX_LETTER_LOW => P_TRX_LETTER_FROM
                                    ,P_TRX_LETTER_HIGH => P_TRX_LETTER_TO
                                    ,P_PARTY_NAME => P_SUPPLIER_NAME
                                    ,P_PRINT_COMPANY_INFO => P_PRINT_COMPANY_INFO
                                    ,P_REQUEST_ID => P_CONC_REQUEST_ID
                                    ,P_ACCOUNTING_STATUS => P_ACCOUNTING_STATUS
                                    ,P_ERRBUF => L_ERRBUF
                                    ,P_RETCODE => L_RETCODE);
    IF L_RETCODE <> 0 THEN
      RETURN (FALSE);
    END IF;
    RETURN (TRUE);
  END CALL_TRL_ENGINE;

  FUNCTION SET_REPORT_TITLE RETURN BOOLEAN IS
  BEGIN
    SELECT
      MEANING
    INTO CP_REPORT_TITLE
    FROM
      FND_LOOKUPS
    WHERE LOOKUP_TYPE = 'ZXAPJAJL'
      AND LOOKUP_CODE = P_REPORT_NAME;
    RETURN (TRUE);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      CP_REPORT_TITLE := 'Payables Tax Report';
      RETURN (TRUE);

    WHEN OTHERS THEN
      RETURN (FALSE);

  END SET_REPORT_TITLE;

  FUNCTION CF_RESPONSIBILITYFORMULA RETURN CHAR IS
  BEGIN
    RETURN (FND_GLOBAL.RESP_NAME);
  END CF_RESPONSIBILITYFORMULA;

  FUNCTION CF_USER_NAMEFORMULA RETURN CHAR IS
  BEGIN
    RETURN (FND_GLOBAL.USER_NAME);
  END CF_USER_NAMEFORMULA;

  FUNCTION GET_ROC_DATE(P_DATE IN DATE) RETURN VARCHAR2 IS
    L_DATE DATE := P_DATE;
    L_CANONICAL_DATE VARCHAR2(20);
    L_ROC_YEAR NUMBER(15);
    L_ROC_MMDD VARCHAR2(5);
    L_ROC_DATE VARCHAR2(20);
    L_LOC VARCHAR2(20) := 'Get_Roc_Date';
  BEGIN
    IF P_DATE IS NULL THEN
      RETURN (NULL);
    END IF;
    L_CANONICAL_DATE := FND_DATE.DATE_TO_CANONICAL(L_DATE);
    L_ROC_YEAR := TO_NUMBER(SUBSTRB(L_CANONICAL_DATE
                                   ,1
                                   ,4)) - 1911;
    L_ROC_MMDD := SUBSTRB(L_CANONICAL_DATE
                         ,6
                         ,5);
    L_ROC_DATE := TO_CHAR(L_ROC_YEAR) || '/' || L_ROC_MMDD;
    RETURN (L_ROC_DATE);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20101
                             ,NULL);

  END GET_ROC_DATE;

  FUNCTION CP_TW_BATCH_DATE_FROMFORMULA RETURN CHAR IS
  BEGIN
    RETURN GET_ROC_DATE(P_BATCH_DATE_FROM);
  END CP_TW_BATCH_DATE_FROMFORMULA;

  FUNCTION CP_TW_BATCH_DATE_TOFORMULA RETURN CHAR IS
  BEGIN
    RETURN GET_ROC_DATE(P_BATCH_DATE_TO);
  END CP_TW_BATCH_DATE_TOFORMULA;

  FUNCTION CP_TW_GL_DATE_HIGHFORMULA RETURN CHAR IS
  BEGIN
    RETURN GET_ROC_DATE(P_GL_DATE_HIGH);
  END CP_TW_GL_DATE_HIGHFORMULA;

  FUNCTION CP_TW_GL_DATE_LOWFORMULA RETURN CHAR IS
  BEGIN
    RETURN GET_ROC_DATE(P_GL_DATE_LOW);
  END CP_TW_GL_DATE_LOWFORMULA;

  FUNCTION CP_TW_TRX_DATE_HIGHFORMULA RETURN CHAR IS
  BEGIN
    RETURN GET_ROC_DATE(P_TRX_DATE_HIGH);
  END CP_TW_TRX_DATE_HIGHFORMULA;

  FUNCTION CP_TW_TRX_DATE_LOWFORMULA RETURN CHAR IS
  BEGIN
    RETURN GET_ROC_DATE(P_TRX_DATE_LOW);
  END CP_TW_TRX_DATE_LOWFORMULA;

  FUNCTION CF_TAXABLE_AMTFORMULA(C_INVOICE_ID IN NUMBER
                                ,C_TRANSACTION_LINE IN NUMBER) RETURN NUMBER IS
    L_INV_TAXABLE_AMT NUMBER := 0;
  BEGIN
    IF (CP_TRX_ID IS NULL) THEN
      CP_TRX_ID := 0;
    END IF;
    IF (CP_TRX_LINE_ID IS NULL) THEN
      CP_TRX_LINE_ID := 0;
    END IF;
    IF ((CP_TRX_ID <> C_INVOICE_ID) OR (CP_TRX_LINE_ID <> C_TRANSACTION_LINE)) THEN
      SELECT
        SUM(A.TAXABLE_AMT)
      INTO L_INV_TAXABLE_AMT
      FROM
        ZX_REP_TRX_DETAIL_T A
      WHERE A.TRX_ID = C_INVOICE_ID
        AND A.TRX_LINE_ID = C_TRANSACTION_LINE
        AND A.REQUEST_ID = P_CONC_REQUEST_ID
        AND A.ROWID = (
        SELECT
          MIN(B.ROWID)
        FROM
          ZX_REP_TRX_DETAIL_T B
        WHERE A.TRX_ID = B.TRX_ID
          AND A.TRX_LINE_ID = B.TRX_LINE_ID
          AND B.REQUEST_ID = P_CONC_REQUEST_ID );
    ELSE
      L_INV_TAXABLE_AMT := 0;
    END IF;
    CP_TRX_ID := C_INVOICE_ID;
    CP_TRX_LINE_ID := C_TRANSACTION_LINE;
    RETURN (L_INV_TAXABLE_AMT);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;

  END CF_TAXABLE_AMTFORMULA;

  FUNCTION CF_TAXABLE_ACC_AMTFORMULA(C_INVOICE_ID IN NUMBER
                                    ,C_TRANSACTION_LINE IN NUMBER) RETURN NUMBER IS
    L_INV_TAXABLE_AMT NUMBER := 0;
  BEGIN
    IF (CP_TRX_ID_ACC IS NULL) THEN
      CP_TRX_ID_ACC := 0;
    END IF;
    IF (CP_TRX_LINE_ID_ACC IS NULL) THEN
      CP_TRX_LINE_ID_ACC := 0;
    END IF;
    IF ((CP_TRX_ID_ACC <> C_INVOICE_ID) OR (CP_TRX_LINE_ID_ACC <> C_TRANSACTION_LINE)) THEN
      SELECT
        SUM(A.TAXABLE_AMT_FUNCL_CURR)
      INTO L_INV_TAXABLE_AMT
      FROM
        ZX_REP_TRX_DETAIL_T A
      WHERE A.TRX_ID = C_INVOICE_ID
        AND A.TRX_LINE_ID = C_TRANSACTION_LINE
        AND A.REQUEST_ID = P_CONC_REQUEST_ID
        AND A.ROWID = (
        SELECT
          MIN(B.ROWID)
        FROM
          ZX_REP_TRX_DETAIL_T B
        WHERE A.TRX_ID = B.TRX_ID
          AND A.TRX_LINE_ID = B.TRX_LINE_ID
          AND B.REQUEST_ID = P_CONC_REQUEST_ID );
      SELECT
        SUM(NVL(A.TAXABLE_AMT
               ,0) + NVL(A.TAX_AMT
               ,0)),
        SUM(NVL(A.TAXABLE_AMT_FUNCL_CURR
               ,0) + NVL(A.TAX_AMT_FUNCL_CURR
               ,0))
      INTO CF_TOT_AMOUNT,CF_TOT_FUNC_AMT
      FROM
        ZX_REP_TRX_DETAIL_T A
      WHERE A.TRX_ID = C_INVOICE_ID
        AND A.TRX_LINE_ID = C_TRANSACTION_LINE
        AND A.REQUEST_ID = P_CONC_REQUEST_ID
        AND A.ROWID = (
        SELECT
          MIN(B.ROWID)
        FROM
          ZX_REP_TRX_DETAIL_T B
        WHERE A.TRX_ID = B.TRX_ID
          AND A.TRX_LINE_ID = B.TRX_LINE_ID
          AND B.REQUEST_ID = P_CONC_REQUEST_ID );
    ELSE
      L_INV_TAXABLE_AMT := 0;
      CF_TOT_AMOUNT := 0;
      CF_TOT_FUNC_AMT := 0;
    END IF;
    CP_TRX_ID_ACC := C_INVOICE_ID;
    CP_TRX_LINE_ID_ACC := C_TRANSACTION_LINE;
    RETURN (L_INV_TAXABLE_AMT);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;

  END CF_TAXABLE_ACC_AMTFORMULA;

  FUNCTION CF_SUPPLIER_NAME_DESCFORMULA RETURN CHAR IS
    L_VENDOR_NAME VARCHAR2(2000);
  BEGIN
    SELECT
      VENDOR_NAME
    INTO L_VENDOR_NAME
    FROM
      PO_VENDORS
    WHERE VENDOR_ID = P_SUPPLIER_NAME;
    RETURN L_VENDOR_NAME;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;

  END CF_SUPPLIER_NAME_DESCFORMULA;

  FUNCTION CF_LEDGER_CURRENCYFORMULA RETURN CHAR IS
    L_LEDGER_CURRENCY VARCHAR2(200);
  BEGIN
    IF (P_REP_CONTEXT_LVL_MNG = '1000') THEN
      SELECT
        CURRENCY_CODE
      INTO L_LEDGER_CURRENCY
      FROM
        GL_LEDGERS
      WHERE LEDGER_ID = P_REP_CONTEXT_ENTITY_NAME;
    ELSIF (P_REP_CONTEXT_LVL_MNG = '2000') THEN
      SELECT
        CURRENCY_CODE
      INTO L_LEDGER_CURRENCY
      FROM
        GL_LEDGER_LE_V
      WHERE LEGAL_ENTITY_ID = P_REP_CONTEXT_ENTITY_NAME;
    ELSE
      SELECT
        B.CURRENCY_CODE
      INTO L_LEDGER_CURRENCY
      FROM
        HR_OPERATING_UNITS A,
        GL_LEDGERS B
      WHERE A.SET_OF_BOOKS_ID = B.LEDGER_ID
        AND A.ORGANIZATION_ID = P_REP_CONTEXT_ENTITY_NAME;
    END IF;
    RETURN L_LEDGER_CURRENCY;
  EXCEPTION
    WHEN OTHERS THEN
      L_LEDGER_CURRENCY := NULL;
      RETURN L_LEDGER_CURRENCY;

  END CF_LEDGER_CURRENCYFORMULA;

  FUNCTION CP_TRX_ID_P RETURN NUMBER IS
  BEGIN
    RETURN CP_TRX_ID;
  END CP_TRX_ID_P;

  FUNCTION CP_TRX_ID_ACC_P RETURN NUMBER IS
  BEGIN
    RETURN CP_TRX_ID_ACC;
  END CP_TRX_ID_ACC_P;

  FUNCTION CF_TOT_AMOUNT_P RETURN NUMBER IS
  BEGIN
    RETURN CF_TOT_AMOUNT;
  END CF_TOT_AMOUNT_P;

  FUNCTION CF_TOT_FUNC_AMT_P RETURN NUMBER IS
  BEGIN
    RETURN CF_TOT_FUNC_AMT;
  END CF_TOT_FUNC_AMT_P;

  FUNCTION CP_TRX_LINE_ID_ACC_P RETURN NUMBER IS
  BEGIN
    RETURN CP_TRX_LINE_ID_ACC;
  END CP_TRX_LINE_ID_ACC_P;

  FUNCTION CP_TRX_LINE_ID_P RETURN NUMBER IS
  BEGIN
    RETURN CP_TRX_LINE_ID;
  END CP_TRX_LINE_ID_P;

  FUNCTION CP_NLS_YES_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_NLS_YES;
  END CP_NLS_YES_P;

  FUNCTION CP_NLS_NO_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_NLS_NO;
  END CP_NLS_NO_P;

  FUNCTION CP_REPORTING_ENTITY_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_REPORTING_ENTITY_NAME;
  END CP_REPORTING_ENTITY_NAME_P;

  FUNCTION CP_REPORTING_LEVEL_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_REPORTING_LEVEL_NAME;
  END CP_REPORTING_LEVEL_NAME_P;

  FUNCTION CP_NLS_ALL_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_NLS_ALL;
  END CP_NLS_ALL_P;

  FUNCTION CP_NLS_VOID_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_NLS_VOID;
  END CP_NLS_VOID_P;

  FUNCTION CP_NLS_NA_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_NLS_NA;
  END CP_NLS_NA_P;

  FUNCTION CP_REPORT_TITLE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_REPORT_TITLE;
  END CP_REPORT_TITLE_P;

  FUNCTION CP_NO_DATA_FOUND_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_NO_DATA_FOUND;
  END CP_NO_DATA_FOUND_P;

  FUNCTION CP_END_OF_REPORT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_END_OF_REPORT;
  END CP_END_OF_REPORT_P;

  FUNCTION CP_TRL_ROW_COUNT_P RETURN NUMBER IS
  BEGIN
    RETURN CP_TRL_ROW_COUNT;
  END CP_TRL_ROW_COUNT_P;

  FUNCTION GET_DATE_FORMAT RETURN BOOLEAN IS
  BEGIN
    P_DATE4_FORMAT := 'DD-MON-YYYY';
    RETURN TRUE;
  END;

END ZX_ZXAPJAJL_XMLP_PKG;


/
