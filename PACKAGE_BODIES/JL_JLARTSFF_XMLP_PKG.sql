--------------------------------------------------------
--  DDL for Package Body JL_JLARTSFF_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_JLARTSFF_XMLP_PKG" AS
/* $Header: JLARTSFFB.pls 120.2 2008/01/11 07:52:36 abraghun noship $ */
  PROCEDURE GET_BASE_CURR_DATA IS
    BASE_CURR AP_SYSTEM_PARAMETERS.BASE_CURRENCY_CODE%TYPE;
    PREC FND_CURRENCIES.PRECISION%TYPE;
    MIN_AU FND_CURRENCIES.MINIMUM_ACCOUNTABLE_UNIT%TYPE;
    DESCR FND_CURRENCIES.DESCRIPTION%TYPE;
    ORG_NAME GL_SETS_OF_BOOKS.NAME%TYPE;
  BEGIN
    BASE_CURR := '';
    PREC := 0;
    MIN_AU := 0;
    DESCR := '';
    ORG_NAME := '';
    SELECT
      FCURR.CURRENCY_CODE,
      FCURR.PRECISION,
      FCURR.MINIMUM_ACCOUNTABLE_UNIT,
      FCURR.DESCRIPTION,
      GSBKS.NAME
    INTO BASE_CURR,PREC,MIN_AU,DESCR,ORG_NAME
    FROM
      AR_SYSTEM_PARAMETERS ASP,
      FND_CURRENCIES_VL FCURR,
      GL_SETS_OF_BOOKS GSBKS
    WHERE ASP.SET_OF_BOOKS_ID = GSBKS.SET_OF_BOOKS_ID
      AND GSBKS.CURRENCY_CODE = FCURR.CURRENCY_CODE;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
    WHEN OTHERS THEN
      C_BASE_CURRENCY_CODE := BASE_CURR;
      C_BASE_PRECISION := PREC;
      C_BASE_MIN_ACCT_UNIT := MIN_AU;
      C_BASE_DESCRIPTION := DESCR;
  END GET_BASE_CURR_DATA;

  FUNCTION CUSTOM_INIT RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (FALSE);
  END CUSTOM_INIT;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
    L_NAME VARCHAR2(30);
    L_TAX_ID VARCHAR2(30);
    L_ORG_ID NUMBER(15);
    L_VAT_ID NUMBER(15);
    L_VATPERC_ID NUMBER(15);
    L_VATADDL_ID NUMBER(15);
    L_EXC_ID NUMBER(15);
    L_VATNOT_ID NUMBER(15);
    L_NON_TAX_ID NUMBER(15);
    err number(10):=0;
  BEGIN
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    L_VAT_ID := NULL;
    BEGIN
      SELECT
        TAX_CATEGORY_ID
      INTO L_VAT_ID
      FROM
        JL_ZZ_AR_TX_CATEGRY
      WHERE TAX_CATEGORY = P_VAT
        AND ROWNUM = 1;
    EXCEPTION
      WHEN OTHERS THEN
        L_VAT_ID := NULL;
    END;
    err:=1;
    L_VATPERC_ID := NULL;
    BEGIN
      SELECT
        TAX_CATEGORY_ID
      INTO L_VATPERC_ID
      FROM
        JL_ZZ_AR_TX_CATEGRY
      WHERE TAX_CATEGORY = P_VATPERC
        AND ROWNUM = 1;
    EXCEPTION
      WHEN OTHERS THEN
        L_VATPERC_ID := NULL;
    END;
        err:=2;
    L_VATADDL_ID := NULL;
    BEGIN
      SELECT
        TAX_CATEGORY_ID
      INTO L_VATADDL_ID
      FROM
        JL_ZZ_AR_TX_CATEGRY
      WHERE TAX_CATEGORY = P_VATADDL
        AND ROWNUM = 1;
    EXCEPTION
      WHEN OTHERS THEN
        L_VATADDL_ID := NULL;
    END;
        err:=3;
    L_EXC_ID := NULL;
    BEGIN
      SELECT
        TAX_CATEGORY_ID
      INTO L_EXC_ID
      FROM
        JL_ZZ_AR_TX_CATEGRY
      WHERE TAX_CATEGORY = P_EXCISE
        AND ROWNUM = 1;
    EXCEPTION
      WHEN OTHERS THEN
        L_EXC_ID := NULL;
    END;
        err:=4;
    L_VATNOT_ID := NULL;
    BEGIN
      SELECT
        TAX_CATEGORY_ID
      INTO L_VATNOT_ID
      FROM
        JL_ZZ_AR_TX_CATEGRY
      WHERE TAX_CATEGORY = P_VATNOT
        AND ROWNUM = 1;
    EXCEPTION
      WHEN OTHERS THEN
        L_VATNOT_ID := NULL;
    END;
        err:=5;
    L_NON_TAX_ID := NULL;
    BEGIN
      SELECT
        TAX_CATEGORY_ID
      INTO L_NON_TAX_ID
      FROM
        JL_ZZ_AR_TX_CATEGRY
      WHERE TAX_CATEGORY = P_VAT_NON_TAXABLE
        AND ROWNUM = 1;
    EXCEPTION
      WHEN OTHERS THEN
        L_NON_TAX_ID := NULL;
    END;
        err:=6;
    L_ORG_ID := OE_PROFILE.VALUE_WNPS('SO_ORGANIZATION_ID');
    BEGIN
      SELECT
        RPAD(DECODE(HR.GLOBAL_ATTRIBUTE11
                   ,NULL
                   ,'           '
                   ,SUBSTR(HR.GLOBAL_ATTRIBUTE11
                         ,1
                         ,10) || SUBSTR(HR.GLOBAL_ATTRIBUTE12
                         ,1
                         ,1))
            ,11
            ,' ')
      INTO L_TAX_ID
      FROM
        HR_ORGANIZATION_UNITS HRU,
        HR_LOCATIONS_ALL HR
      WHERE HRU.ORGANIZATION_ID = L_ORG_ID
        AND HRU.LOCATION_ID = HR.LOCATION_ID;
    EXCEPTION
      WHEN OTHERS THEN
        L_TAX_ID := ' Test1     ';
    END;
        err:=7;
    SELECT
      TAXPAYER_ID
    INTO L_TAX_ID
    FROM
      ZX_REP_CONTEXT_T
    WHERE REQUEST_ID = P_CONC_REQUEST_ID;
        err:=8;
  EXCEPTION
    WHEN OTHERS THEN
     -- RAISE_APPLICATION_ERROR(-20101, err || SQLERRM || '  ' ||P_CONC_REQUEST_ID);
      L_TAX_ID := '  Test 2         ';
      CP_COMP_TAX_ID := L_TAX_ID;
      P_VAT_ID := L_VAT_ID;
      P_VATADDL_ID := L_VATADDL_ID;
      P_VATPERC_ID := L_VATPERC_ID;
      P_EXC_ID := L_EXC_ID;
      P_VATNOT_ID := L_VATNOT_ID;
      P_NON_TAX_ID := L_NON_TAX_ID;
      IF POPULATE_TRL <> TRUE THEN
        NULL;
      END IF;
      BEGIN
        SELECT
          TAXPAYER_ID
        INTO L_TAX_ID
        FROM
          ZX_REP_CONTEXT_T
        WHERE REQUEST_ID = P_CONC_REQUEST_ID;
      EXCEPTION
        WHEN OTHERS THEN
          L_TAX_ID := '           ';
      END;
      CP_COMP_TAX_ID := L_TAX_ID;
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

  FUNCTION FORMAT_CURRENCY(P_AMOUNT IN NUMBER) RETURN VARCHAR2 IS
    FORMAT_STRING VARCHAR2(16);
    FORMATED_AMOUNT VARCHAR2(15);
  BEGIN
    FORMAT_STRING := RPAD('0.'
                         ,4
                         ,'0');
    FORMAT_STRING := LPAD(FORMAT_STRING
                         ,16
                         ,'0');
    FORMATED_AMOUNT := LPAD(REPLACE(LTRIM(RTRIM(TO_CHAR(ABS(P_AMOUNT)
                                                       ,FORMAT_STRING)))
                                   ,'.'
                                   ,'')
                           ,15
                           ,'0');
    RETURN (FORMATED_AMOUNT);
  EXCEPTION
    WHEN OTHERS THEN
      FORMATED_AMOUNT := LPAD(REPLACE(TO_CHAR(ABS(ROUND(P_AMOUNT
                                                       ,2)))
                                     ,'.'
                                     ,'')
                             ,15
                             ,'0');
      RETURN FORMATED_AMOUNT;
  END FORMAT_CURRENCY;

  FUNCTION CF_TOT_DOC_FFORMULA(CS_TOT_DOC_AMT IN NUMBER) RETURN VARCHAR2 IS
    L_CHAR_OPERATION_AMT VARCHAR2(15);
  BEGIN
    L_CHAR_OPERATION_AMT := FORMAT_CURRENCY(CS_TOT_DOC_AMT);
    RETURN (L_CHAR_OPERATION_AMT);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN ('000000000000000');
  END CF_TOT_DOC_FFORMULA;

  FUNCTION CF_TOT_NON_TAXABLE_AMTFORMULA(CS_NON_TAXABLE_AMT IN NUMBER) RETURN VARCHAR2 IS
    L_CHAR_NON_TAXABLE_AMT VARCHAR2(15);
  BEGIN
    L_CHAR_NON_TAXABLE_AMT := FORMAT_CURRENCY(CS_NON_TAXABLE_AMT);
    RETURN (L_CHAR_NON_TAXABLE_AMT);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN ('000000000000000');
  END CF_TOT_NON_TAXABLE_AMTFORMULA;

  FUNCTION CF_TOT_TAXABLE_AMTFORMULA(CS_TAXABLE_AMT IN NUMBER) RETURN CHAR IS
    L_CHAR_TAXABLE_AMT VARCHAR2(15);
  BEGIN
    L_CHAR_TAXABLE_AMT := FORMAT_CURRENCY(CS_TAXABLE_AMT);
    RETURN (L_CHAR_TAXABLE_AMT);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN ('000000000000000');
  END CF_TOT_TAXABLE_AMTFORMULA;

  FUNCTION CF_TOT_VAT_TAX_AMTFORMULA(CS_VAT_TAX_AMT IN NUMBER) RETURN VARCHAR2 IS
    L_VAT_TAX_AMT VARCHAR2(15);
  BEGIN
    L_VAT_TAX_AMT := FORMAT_CURRENCY(CS_VAT_TAX_AMT);
    RETURN (L_VAT_TAX_AMT);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN ('000000000000000');
  END CF_TOT_VAT_TAX_AMTFORMULA;

  FUNCTION CF_TOT_NOT_REG_TAX_AMTFORMULA(CS_NOT_REG_TAX_AMT IN NUMBER) RETURN CHAR IS
    L_CHAR_NOT_REG_TAX_AMT VARCHAR2(15);
  BEGIN
    L_CHAR_NOT_REG_TAX_AMT := FORMAT_CURRENCY(CS_NOT_REG_TAX_AMT);
    RETURN (L_CHAR_NOT_REG_TAX_AMT);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN ('000000000000000');
  END CF_TOT_NOT_REG_TAX_AMTFORMULA;

  FUNCTION CF_TOT_FED_PER_AMTFORMULA(CS_FED_PER_AMT IN NUMBER) RETURN VARCHAR2 IS
    L_CHAR_FED_PER_AMT VARCHAR2(15);
  BEGIN
    L_CHAR_FED_PER_AMT := FORMAT_CURRENCY(CS_FED_PER_AMT);
    RETURN (L_CHAR_FED_PER_AMT);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN ('000000000000000');
  END CF_TOT_FED_PER_AMTFORMULA;

  FUNCTION CF_TOT_PRO_PER_AMTFORMULA(CS_PRO_PER_AMT IN NUMBER) RETURN CHAR IS
    L_CHAR_PRO_PER_AMT VARCHAR2(15);
  BEGIN
    L_CHAR_PRO_PER_AMT := FORMAT_CURRENCY(CS_PRO_PER_AMT);
    RETURN (L_CHAR_PRO_PER_AMT);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN ('000000000000000');
  END CF_TOT_PRO_PER_AMTFORMULA;

  FUNCTION CF_TOT_EXMPT_AMTFORMULA(CS_EXMPT_AMT IN NUMBER) RETURN VARCHAR2 IS
    L_CHAR_EXMPT_AMT VARCHAR2(15);
  BEGIN
    L_CHAR_EXMPT_AMT := FORMAT_CURRENCY(CS_EXMPT_AMT);
    RETURN (L_CHAR_EXMPT_AMT);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN ('000000000000000');
  END CF_TOT_EXMPT_AMTFORMULA;

  FUNCTION CF_TOT_MUN_PER_AMTFORMULA(CS_MUN_PER_AMT IN NUMBER) RETURN VARCHAR2 IS
    L_CHAR_MUN_PER_AMT VARCHAR2(15);
  BEGIN
    L_CHAR_MUN_PER_AMT := FORMAT_CURRENCY(CS_MUN_PER_AMT);
    RETURN (L_CHAR_MUN_PER_AMT);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN ('000000000000000');
  END CF_TOT_MUN_PER_AMTFORMULA;

  FUNCTION CF_TOT_EXC_AMTFORMULA(CS_EXC_AMT IN NUMBER) RETURN VARCHAR2 IS
    L_CHAR_EXC_AMT VARCHAR2(15);
  BEGIN
    L_CHAR_EXC_AMT := FORMAT_CURRENCY(CS_EXC_AMT);
    RETURN (L_CHAR_EXC_AMT);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN ('000000000000000');
  END CF_TOT_EXC_AMTFORMULA;

  FUNCTION CF_REC_TYPE_2FORMULA(CF_TOT_CNT IN NUMBER
                               ,CF_TOT_DOC_F IN VARCHAR2
                               ,CF_TOT_NON_TAXABLE_AMT IN VARCHAR2
                               ,CF_TOT_TAXABLE_AMT IN VARCHAR2
                               ,CF_TOT_VAT_TAX_AMT IN VARCHAR2
                               ,CF_TOT_NOT_REG_TAX_AMT IN VARCHAR2
                               ,CF_TOT_EXMPT_AMT IN VARCHAR2
                               ,CF_TOT_FED_PER_AMT IN VARCHAR2
                               ,CF_TOT_PRO_PER_AMT IN VARCHAR2
                               ,CF_TOT_MUN_PER_AMT IN VARCHAR2
                               ,CF_TOT_EXC_AMT IN VARCHAR2) RETURN VARCHAR2 IS
    L_REC_TYPE_2 VARCHAR2(375);
    L_TOT_DOC_F VARCHAR2(15);
    L_TOT_NON_TAXABLE_AMT VARCHAR2(15);
    L_TOT_VAT_TAX_AMT VARCHAR2(15);
  BEGIN
    L_REC_TYPE_2 := '2' || TO_CHAR(P_FROM_DATE
                           ,'YYYYMM') || RPAD(' '
                        ,29
                        ,' ') || LPAD(CF_TOT_CNT
                        ,12
                        ,'0') || RPAD(' '
                        ,10
                        ,' ') || CP_COMP_TAX_ID || RPAD(' '
                        ,30
                        ,' ') || CF_TOT_DOC_F || CF_TOT_NON_TAXABLE_AMT || CF_TOT_TAXABLE_AMT || RPAD(' '
                        ,4
                        ,' ') || CF_TOT_VAT_TAX_AMT || CF_TOT_NOT_REG_TAX_AMT || CF_TOT_EXMPT_AMT || CF_TOT_FED_PER_AMT || CF_TOT_PRO_PER_AMT || CF_TOT_MUN_PER_AMT || CF_TOT_EXC_AMT || RPAD(' '
                        ,75
                        ,' ');
    RETURN (L_REC_TYPE_2);
  END CF_REC_TYPE_2FORMULA;

  FUNCTION CF_BLANK_SUMFORMULA RETURN CHAR IS
  BEGIN
    RETURN (' ');
  END CF_BLANK_SUMFORMULA;

  FUNCTION CF_TOT_CNTFORMULA RETURN NUMBER IS
    L_TOT NUMBER;
  BEGIN
    L_TOT := CP_TOT + CP_NON_TOT;
    RETURN (L_TOT);
  END CF_TOT_CNTFORMULA;

  FUNCTION POPULATE_TRL RETURN BOOLEAN IS
  BEGIN
    /*SRW.MESSAGE('01'
               ,'TRL API Call : zx_extract_pkg.populate_tax_data ')*/NULL;
    ZX_EXTRACT_PKG.POPULATE_TAX_DATA(P_REPORTING_LEVEL => P_REPORTING_LEVEL
                                    ,P_REPORTING_CONTEXT => P_REPORTING_ENTITY_ID
                                    ,P_LEGAL_ENTITY_ID => P_LEGAL_ENTITY_ID
                                    ,P_SUMMARY_LEVEL => 'TRANSACTION_LINE'
                                    ,P_LEDGER_ID => P_SET_OF_BOOKS_ID
                                    ,P_REGISTER_TYPE => 'ALL'
                                    ,P_PRODUCT => 'AR'
                                    ,P_MATRIX_REPORT => 'N'
                                    ,P_CURRENCY_CODE_LOW => NULL
                                    ,P_CURRENCY_CODE_HIGH => NULL
                                    ,P_INCLUDE_AP_STD_TRX_CLASS => 'N'
                                    ,P_INCLUDE_AP_DM_TRX_CLASS => 'N'
                                    ,P_INCLUDE_AP_CM_TRX_CLASS => 'N'
                                    ,P_INCLUDE_AP_PREP_TRX_CLASS => 'N'
                                    ,P_INCLUDE_AP_MIX_TRX_CLASS => 'N'
                                    ,P_INCLUDE_AP_EXP_TRX_CLASS => 'N'
                                    ,P_INCLUDE_AP_INT_TRX_CLASS => 'N'
                                    ,P_INCLUDE_AR_INV_TRX_CLASS => 'Y'
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
                                    ,P_TRX_DATE_LOW => P_FROM_DATE
                                    ,P_TRX_DATE_HIGH => P_TO_DATE
                                    ,P_GL_PERIOD_NAME_LOW => NULL
                                    ,P_GL_PERIOD_NAME_HIGH => NULL
                                    ,P_TRX_DATE_PERIOD_NAME_LOW => NULL
                                    ,P_TRX_DATE_PERIOD_NAME_HIGH => NULL
                                    ,P_TAX_REGIME_CODE => P_TAX_REGIME
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
                                    ,P_POSTING_STATUS => NULL
                                    ,P_EXTRACT_ACCTED_TAX_LINES => NULL
                                    ,P_INCLUDE_ACCOUNTING_SEGMENTS => NULL
                                    ,P_BALANCING_SEGMENT_LOW => NULL
                                    ,P_BALANCING_SEGMENT_HIGH => NULL
                                    ,P_INCLUDE_DISCOUNTS => NULL
                                    ,P_EXTRACT_STARTING_LINE_NUM => NULL
                                    ,P_REQUEST_ID => P_CONC_REQUEST_ID
                                    ,P_REPORT_NAME => 'JLARTSFF'
                                    ,P_VAT_TRANSACTION_TYPE_CODE => NULL
                                    ,P_INCLUDE_FULLY_NR_TAX_FLAG => NULL
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
                                    ,P_EXCISE_TAX => P_EXCISE
                                    ,P_VAT_ADDITIONAL_TAX => P_VATADDL
                                    ,P_VAT_NON_TAXABLE_TAX => P_VAT_NON_TAXABLE
                                    ,P_VAT_NOT_TAX => P_VATNOT
                                    ,P_VAT_PERCEPTION_TAX => P_VATPERC
                                    ,P_VAT_TAX => P_VAT
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
                                    ,P_MUNICIPAL_TAX => P_MUN_TAX_REGIME
                                    ,P_PROVINCIAL_TAX => P_PRO_TAX_REGIME
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

  FUNCTION CF_DOC_AMT_NUMFORMULA(VOID_TRX IN VARCHAR2
                                ,DOC_AMT IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF VOID_TRX IS NULL THEN
      RETURN (DOC_AMT);
    ELSE
      RETURN (0);
    END IF;
  END CF_DOC_AMT_NUMFORMULA;

  FUNCTION CF_NON_AMT_NUMFORMULA(VOID_TRX IN VARCHAR2
                                ,NON_TXBL_AMT IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF VOID_TRX IS NULL THEN
      RETURN (NON_TXBL_AMT);
    ELSE
      RETURN (0);
    END IF;
  END CF_NON_AMT_NUMFORMULA;

  FUNCTION CF_TAXABLE_AMT_NUMFORMULA(VOID_TRX IN VARCHAR2
                                    ,TXBL_AMT IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF VOID_TRX IS NULL THEN
      RETURN (TXBL_AMT);
    ELSE
      RETURN (0);
    END IF;
  END CF_TAXABLE_AMT_NUMFORMULA;

  FUNCTION CF_VAT_TAX_AMT_NUMFORMULA(VOID_TRX IN VARCHAR2
                                    ,VAT_AMOUNT IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF VOID_TRX IS NULL THEN
      RETURN (VAT_AMOUNT);
    ELSE
      RETURN (0);
    END IF;
  END CF_VAT_TAX_AMT_NUMFORMULA;

  FUNCTION CF_NON_REG_TAX_AMT_NUMFORMULA(VOID_TRX IN VARCHAR2
                                        ,NON_REG_AMT IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF VOID_TRX IS NULL THEN
      RETURN (NON_REG_AMT);
    ELSE
      RETURN (0);
    END IF;
  END CF_NON_REG_TAX_AMT_NUMFORMULA;

  FUNCTION CF_EXMPT_AMT_NUMFORMULA(VOID_TRX IN VARCHAR2
                                  ,EXMPT_AMT IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF VOID_TRX IS NULL THEN
      RETURN (EXMPT_AMT);
    ELSE
      RETURN (0);
    END IF;
  END CF_EXMPT_AMT_NUMFORMULA;

  FUNCTION CF_FED_PER_AMT_NUMFORMULA(VOID_TRX IN VARCHAR2
                                    ,FED_PERCEP_AMT IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF VOID_TRX IS NULL THEN
      RETURN (FED_PERCEP_AMT);
    ELSE
      RETURN (0);
    END IF;
  END CF_FED_PER_AMT_NUMFORMULA;

  FUNCTION CF_PRO_PER_AMT_NUMFORMULA(VOID_TRX IN VARCHAR2
                                    ,PROV_PRECEP_AMT IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF VOID_TRX IS NULL THEN
      RETURN (PROV_PRECEP_AMT);
    ELSE
      RETURN (0);
    END IF;
  END CF_PRO_PER_AMT_NUMFORMULA;

  FUNCTION CF_MUN_PER_AMT_NUMFORMULA(VOID_TRX IN VARCHAR2
                                    ,MUNIC_PERCEP_AMT IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF VOID_TRX IS NULL THEN
      RETURN (MUNIC_PERCEP_AMT);
    ELSE
      RETURN (0);
    END IF;
  END CF_MUN_PER_AMT_NUMFORMULA;

  FUNCTION CF_EXC_AMT_NUMFORMULA(VOID_TRX IN VARCHAR2
                                ,EXCISE_AMT IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF VOID_TRX IS NULL THEN
      RETURN (EXCISE_AMT);
    ELSE
      RETURN (0);
    END IF;
  END CF_EXC_AMT_NUMFORMULA;

  FUNCTION CF_DOC_AMT_CHRFORMULA(DOC_AMT IN NUMBER) RETURN CHAR IS
  BEGIN
    RETURN (FORMAT_CURRENCY(DOC_AMT));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN ('000000000000000');
  END CF_DOC_AMT_CHRFORMULA;

  FUNCTION CF_NON_AMT_CHRFORMULA(NON_TXBL_AMT IN NUMBER) RETURN CHAR IS
  BEGIN
    RETURN (FORMAT_CURRENCY(NON_TXBL_AMT));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN ('000000000000000');
  END CF_NON_AMT_CHRFORMULA;

  FUNCTION CF_TAXABLE_AMT_CHRFORMULA(TXBL_AMT IN NUMBER) RETURN CHAR IS
  BEGIN
    RETURN (FORMAT_CURRENCY(TXBL_AMT));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN ('000000000000000');
  END CF_TAXABLE_AMT_CHRFORMULA;

  FUNCTION CF_VAT_TAX_AMT_CHRFORMULA(VAT_AMOUNT IN NUMBER) RETURN CHAR IS
  BEGIN
    RETURN (FORMAT_CURRENCY(VAT_AMOUNT));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN ('000000000000000');
  END CF_VAT_TAX_AMT_CHRFORMULA;

  FUNCTION CF_NON_REG_TAX_AMT_CHRFORMULA(NON_REG_AMT IN NUMBER) RETURN CHAR IS
  BEGIN
    RETURN (FORMAT_CURRENCY(NON_REG_AMT));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN ('000000000000000');
  END CF_NON_REG_TAX_AMT_CHRFORMULA;

  FUNCTION CF_EXMPT_AMT_CHRFORMULA(EXMPT_AMT IN NUMBER) RETURN CHAR IS
  BEGIN
    RETURN (FORMAT_CURRENCY(EXMPT_AMT));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN ('000000000000000');
  END CF_EXMPT_AMT_CHRFORMULA;

  FUNCTION CF_FED_PER_AMT_CHRFORMULA(FED_PERCEP_AMT IN NUMBER) RETURN CHAR IS
  BEGIN
    RETURN (FORMAT_CURRENCY(FED_PERCEP_AMT));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN ('000000000000000');
  END CF_FED_PER_AMT_CHRFORMULA;

  FUNCTION CF_PRO_PER_AMT_CHRFORMULA(PROV_PRECEP_AMT IN NUMBER) RETURN CHAR IS
  BEGIN
    RETURN (FORMAT_CURRENCY(PROV_PRECEP_AMT));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN ('000000000000000');
  END CF_PRO_PER_AMT_CHRFORMULA;

  FUNCTION CF_MUN_PER_AMT_CHRFORMULA(MUNIC_PERCEP_AMT IN NUMBER) RETURN CHAR IS
  BEGIN
    RETURN (FORMAT_CURRENCY(MUNIC_PERCEP_AMT));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN ('000000000000000');
  END CF_MUN_PER_AMT_CHRFORMULA;

  FUNCTION CF_EXC_AMT_CHRFORMULA(EXCISE_AMT IN NUMBER) RETURN CHAR IS
  BEGIN
    RETURN (FORMAT_CURRENCY(EXCISE_AMT));
  EXCEPTION
    WHEN OTHERS THEN
      RETURN ('000000000000000');
  END CF_EXC_AMT_CHRFORMULA;

  FUNCTION CF_EXCHANGE_RATEFORMULA(EXCHANGE_RATE IN NUMBER) RETURN CHAR IS
    L_FORMATED_EXCHG_RATE VARCHAR2(10);
    FORMAT_STRING VARCHAR2(11);
  BEGIN
    FORMAT_STRING := RPAD('0.'
                         ,8
                         ,'0');
    FORMAT_STRING := LPAD(FORMAT_STRING
                         ,11
                         ,'9');
    L_FORMATED_EXCHG_RATE := LPAD(REPLACE(LTRIM(RTRIM(TO_CHAR(ABS(EXCHANGE_RATE)
                                                             ,FORMAT_STRING)))
                                         ,'.'
                                         ,'')
                                 ,10
                                 ,'0');
    RETURN L_FORMATED_EXCHG_RATE;
  END CF_EXCHANGE_RATEFORMULA;

  FUNCTION CF_REC_COUNTFORMULA(CUSTOMER_TRX_ID IN NUMBER) RETURN NUMBER IS
    L_VAT_COUNT NUMBER;
  BEGIN
    SELECT
      count(TAX_RATE)
    INTO L_VAT_COUNT
    FROM
      ZX_REP_TRX_DETAIL_T
    WHERE REQUEST_ID = P_CONC_REQUEST_ID
      AND TRX_ID = CUSTOMER_TRX_ID
      AND TAX = P_VAT;
    RETURN (L_VAT_COUNT);
  END CF_REC_COUNTFORMULA;

  FUNCTION CF_VAT_NON_RECFORMULA(NON_TXBL_AMT IN NUMBER
                                ,VOID_TRX IN VARCHAR2
                                ,DOC_DATE IN VARCHAR2
                                ,DGI_CODES IN VARCHAR2
                                ,FISCAL_PRINTER IN VARCHAR2
                                ,STRING1 IN VARCHAR2
                                ,CAI_INFO IN VARCHAR2
                                ,DOC_VOID_DATE IN VARCHAR2
                                ,CF_REC_COUNT IN NUMBER
                                ,CF_DOC_AMT_CHR IN VARCHAR2
                                ,CF_NON_AMT_CHR IN VARCHAR2
                                ,CUST_VAT_REG_CODE IN VARCHAR2
                                ,CUR_CODE IN VARCHAR2
                                ,CF_EXCHANGE_RATE IN VARCHAR2
                                ,VAT_RATE_QTY IN NUMBER
                                ,DGI_TRX_CODE IN VARCHAR2
                                ,VAT_RATE IN NUMBER
                                ,CF_EXMPT_AMT_CHR IN VARCHAR2
                                ,CF_TAXABLE_AMT_CHR IN VARCHAR2
                                ,CF_VAT_RATE IN VARCHAR2
                                ,CF_VAT_TAX_AMT_CHR IN VARCHAR2
                                ,CF_NON_REG_TAX_AMT_CHR IN VARCHAR2
                                ,CF_FED_PER_AMT_CHR IN VARCHAR2
                                ,CF_PRO_PER_AMT_CHR IN VARCHAR2
                                ,CF_MUN_PER_AMT_CHR IN VARCHAR2
                                ,CF_EXC_AMT_CHR IN VARCHAR2) RETURN CHAR IS
    L_REC_TYPE_1 VARCHAR2(375);
  BEGIN
    IF NON_TXBL_AMT <> 0 THEN
      BEGIN
        IF VOID_TRX IS NOT NULL THEN
          L_REC_TYPE_1 := RPAD('1' || DOC_DATE || DGI_CODES || FISCAL_PRINTER || STRING1 || '000000000000000' || '000000000000000' || '000000000000000' || '0000' || '000000000000000' || '000000000000000' || '000000000000000' ||
	  '000000000000000' || '000000000000000' || '000000000000000' || '000000000000000' || '00' || '   ' || '0000000000' || '0' || ' ' || CAI_INFO || DOC_VOID_DATE
                              ,375
                              ,' ');
        ELSIF CF_REC_COUNT = 0 THEN
          L_REC_TYPE_1 := RPAD('1' || DOC_DATE || DGI_CODES || FISCAL_PRINTER || STRING1 || CF_DOC_AMT_CHR || CF_NON_AMT_CHR || '000000000000000' || '0000' || '000000000000000' || '000000000000000' || '000000000000000' ||
	  '000000000000000' || '000000000000000' || '000000000000000' || '000000000000000' || CUST_VAT_REG_CODE || CUR_CODE || CF_EXCHANGE_RATE || VAT_RATE_QTY || DGI_TRX_CODE || CAI_INFO || DOC_VOID_DATE
                              ,375
                              ,' ');
        ELSE
          L_REC_TYPE_1 := RPAD('1' || DOC_DATE || DGI_CODES || FISCAL_PRINTER || STRING1 || '000000000000000' || CF_NON_AMT_CHR || '000000000000000' || '0000' || '000000000000000' || '000000000000000' || '000000000000000' ||
	  '000000000000000' || '000000000000000' || '000000000000000' || '000000000000000' || CUST_VAT_REG_CODE || CUR_CODE || CF_EXCHANGE_RATE || VAT_RATE_QTY || DGI_TRX_CODE || CAI_INFO || DOC_VOID_DATE
                              ,375
                              ,' ');
        END IF;
        CP_NON_TOT := NVL(CP_NON_TOT
                         ,0) + 1;
        RETURN (L_REC_TYPE_1);
      END;
    ELSE
      IF CF_REC_COUNT = CP_REC_COUNT THEN
        IF VOID_TRX IS NOT NULL THEN
          L_REC_TYPE_1 := RPAD('1' || DOC_DATE || DGI_CODES || FISCAL_PRINTER || STRING1 || '000000000000000' || '000000000000000' ||
	  '000000000000000' || '0000' || '000000000000000' || '000000000000000' || '000000000000000' || '000000000000000' || '000000000000000' || '000000000000000' ||
	  '000000000000000' || '00' || '   ' || '0000000000' || '0' || ' ' || CAI_INFO || DOC_VOID_DATE
                              ,375
                              ,' ');
        ELSIF VAT_RATE = 0 THEN
          L_REC_TYPE_1 := RPAD('1' || DOC_DATE || DGI_CODES || FISCAL_PRINTER || STRING1 || CF_DOC_AMT_CHR || '000000000000000' || '000000000000000' ||
	  VAT_RATE || '000000000000000' || '000000000000000' || CF_EXMPT_AMT_CHR || '000000000000000' || '000000000000000' || '000000000000000' ||
	  '000000000000000' || CUST_VAT_REG_CODE || CUR_CODE || CF_EXCHANGE_RATE || VAT_RATE_QTY || DGI_TRX_CODE || CAI_INFO || DOC_VOID_DATE
                              ,375
                              ,' ');
        ELSE
          L_REC_TYPE_1 := RPAD('1' || DOC_DATE || DGI_CODES || FISCAL_PRINTER || STRING1 || CF_DOC_AMT_CHR || '000000000000000' || CF_TAXABLE_AMT_CHR || CF_VAT_RATE || CF_VAT_TAX_AMT_CHR || CF_NON_REG_TAX_AMT_CHR ||
	  '000000000000000' || CF_FED_PER_AMT_CHR || CF_PRO_PER_AMT_CHR || CF_MUN_PER_AMT_CHR || CF_EXC_AMT_CHR || CUST_VAT_REG_CODE || CUR_CODE || CF_EXCHANGE_RATE || VAT_RATE_QTY || DGI_TRX_CODE || CAI_INFO || DOC_VOID_DATE
                              ,375
                              ,' ');
        END IF;
        CP_TOT := NVL(CP_TOT
                     ,0) + 1;
        CP_REC_COUNT := 1;
      ELSE
        IF VOID_TRX IS NOT NULL THEN
          L_REC_TYPE_1 := RPAD('1' || DOC_DATE || DGI_CODES || FISCAL_PRINTER || STRING1 || '000000000000000' || '000000000000000' || '000000000000000' || '0000' || '000000000000000' || '000000000000000' || '000000000000000' ||
	  '000000000000000' || '000000000000000' || '000000000000000' || '000000000000000' || '00' || '   ' || '0000000000' || '0' || ' ' || CAI_INFO || DOC_VOID_DATE
                              ,375
                              ,' ');
        ELSIF VAT_RATE = 0 THEN
          L_REC_TYPE_1 := RPAD('1' || DOC_DATE || DGI_CODES || FISCAL_PRINTER || STRING1 || '000000000000000' || '000000000000000' || '000000000000000' || VAT_RATE || '000000000000000' || '000000000000000'
	  || CF_EXMPT_AMT_CHR || '000000000000000' || '000000000000000' || '000000000000000' || '000000000000000' || CUST_VAT_REG_CODE || CUR_CODE || CF_EXCHANGE_RATE || VAT_RATE_QTY || DGI_TRX_CODE || CAI_INFO || DOC_VOID_DATE
                              ,375
                              ,' ');
        ELSE
          L_REC_TYPE_1 := RPAD('1' || DOC_DATE || DGI_CODES || FISCAL_PRINTER || STRING1 || '000000000000000' || '000000000000000' || CF_TAXABLE_AMT_CHR || CF_VAT_RATE || CF_VAT_TAX_AMT_CHR || '000000000000000' ||
	  '000000000000000' || '000000000000000' || '000000000000000' || '000000000000000' || '000000000000000' || CUST_VAT_REG_CODE || CUR_CODE || CF_EXCHANGE_RATE || VAT_RATE_QTY || DGI_TRX_CODE || CAI_INFO || DOC_VOID_DATE
                              ,375
                              ,' ');
        END IF;
        CP_REC_COUNT := NVL(CP_REC_COUNT
                           ,0) + 1;
        CP_TOT := NVL(CP_TOT
                     ,0) + 1;
      END IF;
      RETURN (L_REC_TYPE_1);
    END IF;
  END CF_VAT_NON_RECFORMULA;

  FUNCTION CF_BLANK_CHRFORMULA RETURN CHAR IS
  BEGIN
    RETURN (' ');
  END CF_BLANK_CHRFORMULA;

  FUNCTION CP_REC_COUNTFORMULA RETURN NUMBER IS
  BEGIN
    NULL;
  END CP_REC_COUNTFORMULA;

  FUNCTION CF_VAT_RATEFORMULA(VAT_RATE IN NUMBER) RETURN CHAR IS
    L_RATE_CHAR VARCHAR2(4);
    FORMAT_STRING VARCHAR2(5);
    FORMATED_RATE VARCHAR2(4);
  BEGIN
    FORMAT_STRING := RPAD('0.'
                         ,4
                         ,'0');
    FORMAT_STRING := LPAD(FORMAT_STRING
                         ,5
                         ,'0');
    FORMATED_RATE := LPAD(REPLACE(LTRIM(RTRIM(TO_CHAR(ABS(VAT_RATE)
                                                     ,FORMAT_STRING)))
                                 ,'.'
                                 ,'')
                         ,4
                         ,'0');
    RETURN (FORMATED_RATE);
  EXCEPTION
    WHEN OTHERS THEN
      FORMATED_RATE := LPAD(REPLACE(TO_CHAR(ABS(ROUND(VAT_RATE
                                                     ,2)))
                                   ,'.'
                                   ,'')
                           ,4
                           ,'0');
      RETURN (FORMATED_RATE);
  END CF_VAT_RATEFORMULA;

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

  FUNCTION CP_COMP_TAX_ID_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_COMP_TAX_ID;
  END CP_COMP_TAX_ID_P;

  FUNCTION CP_REC_COUNT_P RETURN NUMBER IS
  BEGIN
    RETURN CP_REC_COUNT;
  END CP_REC_COUNT_P;

  FUNCTION P_VAT_ID_P RETURN NUMBER IS
  BEGIN
    RETURN P_VAT_ID;
  END P_VAT_ID_P;

  FUNCTION P_VATADDL_ID_P RETURN NUMBER IS
  BEGIN
    RETURN P_VATADDL_ID;
  END P_VATADDL_ID_P;

  FUNCTION P_VATPERC_ID_P RETURN NUMBER IS
  BEGIN
    RETURN P_VATPERC_ID;
  END P_VATPERC_ID_P;

  FUNCTION P_EXC_ID_P RETURN NUMBER IS
  BEGIN
    RETURN P_EXC_ID;
  END P_EXC_ID_P;

  FUNCTION P_VATNOT_ID_P RETURN NUMBER IS
  BEGIN
    RETURN P_VATNOT_ID;
  END P_VATNOT_ID_P;

  FUNCTION P_NON_TAX_ID_P RETURN NUMBER IS
  BEGIN
    RETURN P_NON_TAX_ID;
  END P_NON_TAX_ID_P;

  FUNCTION CP_TOT_P RETURN NUMBER IS
  BEGIN
    RETURN CP_TOT;
  END CP_TOT_P;

  FUNCTION CP_NON_TOT_P RETURN NUMBER IS
  BEGIN
    RETURN CP_NON_TOT;
  END CP_NON_TOT_P;

END JL_JLARTSFF_XMLP_PKG;




/
