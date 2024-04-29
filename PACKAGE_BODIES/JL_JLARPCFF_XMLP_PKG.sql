--------------------------------------------------------
--  DDL for Package Body JL_JLARPCFF_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_JLARPCFF_XMLP_PKG" AS
/* $Header: JLARPCFFB.pls 120.2 2008/01/11 07:51:42 abraghun noship $ */
  PROCEDURE GET_BASE_CURR_DATA IS
    BASE_CURR FND_CURRENCIES_VL.CURRENCY_CODE%TYPE;
    PREC FND_CURRENCIES_VL.PRECISION%TYPE;
    MIN_AU FND_CURRENCIES_VL.MINIMUM_ACCOUNTABLE_UNIT%TYPE;
    DESCR FND_CURRENCIES_VL.DESCRIPTION%TYPE;
    ORG_NAME GL_SETS_OF_BOOKS.NAME%TYPE;
  BEGIN
    BASE_CURR := '';
    PREC := 0;
    MIN_AU := 0;
    DESCR := '';
    ORG_NAME := '';
    BEGIN
      SELECT
        FCURR.CURRENCY_CODE,
        FCURR.PRECISION,
        FCURR.MINIMUM_ACCOUNTABLE_UNIT,
        FCURR.DESCRIPTION
      INTO BASE_CURR,PREC,MIN_AU,DESCR
      FROM
        AP_SYSTEM_PARAMETERS ASP,
        FND_CURRENCIES_VL FCURR
      WHERE ASP.BASE_CURRENCY_CODE = FCURR.CURRENCY_CODE;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RAISE_ERR('200XX'
                 ,'JL_AR_FA_CURR_DET_NOT_DEFINED');
      WHEN OTHERS THEN
        RAISE_ORA_ERR('200XX');
    END;
    C_BASE_CURRENCY_CODE := BASE_CURR;
    C_BASE_PRECISION := PREC;
    C_BASE_MIN_ACCT_UNIT := MIN_AU;
    C_BASE_DESCRIPTION := DESCR;
    C_ORGANISATION_NAME := ORG_NAME;
  END GET_BASE_CURR_DATA;

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

  PROCEDURE RAISE_ORA_ERR(ERRNO IN VARCHAR2) IS
    ERRMSG VARCHAR2(1000);
  BEGIN
    ERRMSG := SQLERRM;
    /*SRW.MESSAGE(ERRNO
               ,ERRMSG)*/NULL;
    /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
  END RAISE_ORA_ERR;

  PROCEDURE RAISE_ERR(ERRNO IN VARCHAR2
                     ,MSGNAME IN VARCHAR2) IS
    ERRMSG VARCHAR2(1000);
  BEGIN
    FND_MESSAGE.SET_NAME('JL'
                        ,MSGNAME);
    ERRMSG := FND_MESSAGE.GET;
    /*SRW.MESSAGE(ERRNO
               ,ERRMSG)*/NULL;
    /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
  END RAISE_ERR;

  FUNCTION CF_ACC_DATEFORMULA(INVOICE_ID IN NUMBER
                             ,TAX_RATE_ID IN NUMBER) RETURN DATE IS
    L_ACCOUNTING_DATE DATE;
    L_REVERSAL_FLAG VARCHAR2(1);
    CURSOR ACC_DATE IS
      SELECT
        AID.ACCOUNTING_DATE,
        AID.REVERSAL_FLAG
      FROM
        AP_INVOICE_DISTRIBUTIONS_ALL AID
      WHERE AID.INVOICE_ID = CF_ACC_DATEFORMULA.INVOICE_ID
        AND AID.TAX_CODE_ID = TAX_RATE_ID
        AND AID.LINE_TYPE_LOOKUP_CODE in ( 'NONREC_TAX' , 'REC_TAX' )
      ORDER BY
        AID.ACCOUNTING_DATE;
  BEGIN
    FOR date_rec IN ACC_DATE LOOP
      IF NVL(DATE_REC.REVERSAL_FLAG
         ,'N') = 'N' THEN
        L_ACCOUNTING_DATE := DATE_REC.ACCOUNTING_DATE;
        EXIT;
      END IF;
    END LOOP;
    /*SRW.MESSAGE('1'
               ,'Accounting Date is :' || TO_CHAR(L_ACCOUNTING_DATE
                      ,'dd-mon-yyyy'))*/NULL;
    RETURN (L_ACCOUNTING_DATE);
  END CF_ACC_DATEFORMULA;

  FUNCTION CF_CITI_RECFORMULA(CF_ACC_DATE IN DATE
                             ,CF_TAX_AMOUNT IN NUMBER
                             ,DOCUMENT_TYPE IN VARCHAR2
                             ,DOCUMENT_NUM IN VARCHAR2
                             ,DOCUMENT_DATE IN DATE
                             ,CUIT_NUMBER IN VARCHAR2
                             ,SUP_NAME IN VARCHAR2) RETURN CHAR IS
    L_CITI_REC VARCHAR2(130);
    L_DEC VARCHAR2(10);
    AMT_WITH_DEC VARCHAR2(12);
    L_CHAR_TAX_AMOUNT VARCHAR2(12);
    L_DEC_PART VARCHAR2(10);
    L_INT_PART VARCHAR2(12);
    L NUMBER;
    L_THIRD_CUIT VARCHAR2(11);
    L_THIRD_NAME VARCHAR2(25);
    L_VAT_FEES VARCHAR2(12);
  BEGIN
    IF CF_ACC_DATE IS NULL THEN
      RETURN 'no_rec';
    END IF;
    L_CHAR_TAX_AMOUNT := LPAD(REPLACE(LTRIM(RTRIM(TO_CHAR(CF_TAX_AMOUNT
                                                         ,'9999999990.00')))
                                     ,'.'
                                     ,'')
                             ,12
                             ,'0');
    L_THIRD_CUIT := LPAD('0'
                        ,11
                        ,'0');
    L_THIRD_NAME := LPAD(' '
                        ,25
                        ,' ');
    L_VAT_FEES := LPAD('0'
                      ,12
                      ,'0');
    /*SRW.MESSAGE('90'
               ,'Tax amonunt' || TO_CHAR(CF_TAX_AMOUNT))*/NULL;
    IF CF_ACC_DATE >= P_START_DATE AND CF_ACC_DATE <= P_END_DATE AND CF_TAX_AMOUNT > 0 THEN
      L_CITI_REC := DOCUMENT_TYPE || DOCUMENT_NUM || TO_CHAR(DOCUMENT_DATE
                           ,'DDMMYYYY') || CUIT_NUMBER || SUP_NAME || L_CHAR_TAX_AMOUNT || L_THIRD_CUIT || L_THIRD_NAME || L_VAT_FEES;
    ELSE
      L_CITI_REC := 'no_rec';
    END IF;
    RETURN (L_CITI_REC);
  END CF_CITI_RECFORMULA;

  FUNCTION CF_TAX_AMOUNTFORMULA(TAX_AMOUNT IN NUMBER) RETURN NUMBER IS
    L_TAX_AMOUNT NUMBER;
  BEGIN
    L_TAX_AMOUNT := TAX_AMOUNT;
    RETURN (L_TAX_AMOUNT);
  EXCEPTION
    WHEN VALUE_ERROR THEN
      NULL;
  END CF_TAX_AMOUNTFORMULA;

  FUNCTION CF_SPACEFORMULA RETURN VARCHAR2 IS
  BEGIN
    RETURN (' ');
  END CF_SPACEFORMULA;

  FUNCTION POPULATE_TRL RETURN BOOLEAN IS
  BEGIN
    /*SRW.MESSAGE('01'
               ,'Call to TRL API : zx_extract_pkg.populate_tax_data')*/NULL;
    ZX_EXTRACT_PKG.POPULATE_TAX_DATA(P_REPORTING_LEVEL => P_REPORTING_LEVEL
                                    ,P_REPORTING_CONTEXT => P_REPORTING_ENTITY_ID
                                    ,P_LEGAL_ENTITY_ID => P_LEGAL_ENTITY_ID
                                    ,P_SUMMARY_LEVEL => 'TRANSACTION'
                                    ,P_LEDGER_ID => P_SET_OF_BOOKS_ID
                                    ,P_REGISTER_TYPE => 'TAX'
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
                                    ,P_GL_DATE_LOW => NULL
                                    ,P_GL_DATE_HIGH => NULL
                                    ,P_TRX_DATE_LOW => P_START_DATE
                                    ,P_TRX_DATE_HIGH => P_END_DATE
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
                                    ,P_TAX_TYPE_CODE_LOW => P_TAX_TYPE
                                    ,P_TAX_TYPE_CODE_HIGH => P_TAX_TYPE
                                    ,P_DOCUMENT_SUB_TYPE => NULL
                                    ,P_TRX_BUSINESS_CATEGORY => NULL
                                    ,P_TAX_INVOICE_DATE_LOW => NULL
                                    ,P_TAX_INVOICE_DATE_HIGH => NULL
                                    ,P_POSTING_STATUS => NULL
                                    ,P_EXTRACT_ACCTED_TAX_LINES => NULL
                                    ,P_INCLUDE_ACCOUNTING_SEGMENTS => NULL
                                    ,P_BALANCING_SEGMENT_LOW => NULL
                                    ,P_BALANCING_SEGMENT_HIGH => NULL
                                    ,P_INCLUDE_DISCOUNTS => NULL
                                    ,P_EXTRACT_STARTING_LINE_NUM => NULL
                                    ,P_REQUEST_ID => P_CONC_REQUEST_ID
                                    ,P_REPORT_NAME => 'JLARPCFF'
                                    ,P_VAT_TRANSACTION_TYPE_CODE => NULL
                                    ,P_INCLUDE_FULLY_NR_TAX_FLAG => 'Y'
                                    ,P_MUNICIPAL_TAX_TYPE_CODE_LOW => NULL
                                    ,P_MUNICIPAL_TAX_TYPE_CODE_HIGH => NULL
                                    ,P_PROV_TAX_TYPE_CODE_LOW => NULL
                                    ,P_PROV_TAX_TYPE_CODE_HIGH => NULL
                                    ,P_EXCISE_TAX_TYPE_CODE_LOW => NULL
                                    ,P_EXCISE_TAX_TYPE_CODE_HIGH => NULL
                                    ,P_NON_TAXABLE_TAX_TYPE_CODE => NULL
                                    ,P_PER_TAX_TYPE_CODE_LOW => NULL
                                    ,P_PER_TAX_TYPE_CODE_HIGH => NULL
                                    ,P_VAT_TAX_TYPE_CODE => NULL
                                    ,P_EXCISE_TAX => NULL
                                    ,P_VAT_ADDITIONAL_TAX => NULL
                                    ,P_VAT_NON_TAXABLE_TAX => NULL
                                    ,P_VAT_NOT_TAX => NULL
                                    ,P_VAT_PERCEPTION_TAX => NULL
                                    ,P_VAT_TAX => P_TAX_TYPE
                                    ,P_INC_SELF_WD_TAX => NULL
                                    ,P_EXCLUDING_TRX_LETTER => NULL
                                    ,P_TRX_LETTER_LOW => P_TRANSACTION_LETTER_FROM
                                    ,P_TRX_LETTER_HIGH => P_TRANSACTION_LETTER_TO
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

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    IF POPULATE_TRL <> TRUE THEN
      NULL;
    END IF;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION C_ORGANISATION_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_ORGANISATION_NAME;
  END C_ORGANISATION_NAME_P;

  FUNCTION C_BASE_MIN_ACCT_UNIT_P RETURN NUMBER IS
  BEGIN
    RETURN C_BASE_MIN_ACCT_UNIT;
  END C_BASE_MIN_ACCT_UNIT_P;

  FUNCTION C_BASE_CURRENCY_CODE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_BASE_CURRENCY_CODE;
  END C_BASE_CURRENCY_CODE_P;

  FUNCTION C_BASE_PRECISION_P RETURN NUMBER IS
  BEGIN
    RETURN C_BASE_PRECISION;
  END C_BASE_PRECISION_P;

  FUNCTION C_BASE_DESCRIPTION_P RETURN VARCHAR2 IS
  BEGIN
    RETURN C_BASE_DESCRIPTION;
  END C_BASE_DESCRIPTION_P;

END JL_JLARPCFF_XMLP_PKG;



/
