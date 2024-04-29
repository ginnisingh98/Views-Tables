--------------------------------------------------------
--  DDL for Package Body ZX_ZXJGTAX_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_ZXJGTAX_XMLP_PKG" AS
/* $Header: ZXJGTAXB.pls 120.1.12010000.1 2008/07/28 13:27:51 appldev ship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
    ERRBUF VARCHAR2(2000);
    RETCODE NUMBER;
    INIT_FAILURE EXCEPTION;
    DUMMY VARCHAR2(1000);
  BEGIN
    EXECUTE IMMEDIATE
      'ALTER SESSION SET SQL_TRACE=TRUE';
    SELECT
      'ZXARRECV'
    INTO DUMMY
    FROM
      DUAL;
    /*SRW.MESSAGE('1'
               ,'Before Init')*/NULL;
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    /*SRW.MESSAGE('1'
               ,'After Init')*/NULL;
    /*SRW.MESSAGE('13'
               ,'Before populating tax extract')*/NULL;
    IF CALL_TRL_ENGINE <> TRUE THEN
      RAISE INIT_FAILURE;
    END IF;
    /*SRW.MESSAGE('14'
               ,'After populating tax extract')*/NULL;
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
    /*SRW.MESSAGE('19'
               ,'End of Before Report Trigger')*/NULL;
    RETURN (TRUE);
  EXCEPTION
    WHEN INIT_FAILURE THEN
      RETURN (FALSE);
    WHEN OTHERS THEN
      /*SRW.MESSAGE('999'
                 ,SQLERRM)*/NULL;
      /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
  END BEFOREREPORT;

  FUNCTION INITIALIZE RETURN BOOLEAN IS
    INIT_EXCEPTION EXCEPTION;
  BEGIN
    /*SRW.MESSAGE('01'
               ,'BEFORE call XLA_MO_REPORTING_API')*/NULL;
    XLA_MO_REPORTING_API.INITIALIZE(P_REPORTING_LEVEL
                                   ,P_REPORTING_ENTITY_ID
                                   ,'AUTO');
    CP_REPORTING_LEVEL_NAME := XLA_MO_REPORTING_API.GET_REPORTING_LEVEL_NAME;
    CP_REPORTING_ENTITY_NAME := XLA_MO_REPORTING_API.GET_REPORTING_ENTITY_NAME;
    /*SRW.MESSAGE('02'
               ,'AFTER call XLA_MO_REPORTING_API')*/NULL;
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    RETURN (TRUE);
  EXCEPTION
    WHEN OTHERS THEN
      /*SRW.MESSAGE('999'
                 ,SQLERRM)*/NULL;
      RETURN (FALSE);
  END INITIALIZE;

  FUNCTION CALL_TRL_ENGINE RETURN BOOLEAN IS
    L_TAX_CLASS VARCHAR2(1);
    L_PRODUCT VARCHAR2(15);
    L_SUMMARY_LEVEL VARCHAR2(30);
    L_RETCODE NUMBER;
    L_ERRBUF VARCHAR2(2000);
  BEGIN
    L_SUMMARY_LEVEL := 'TRANSACTION_DISTRIBUTION';
    L_PRODUCT := 'ALL';
    ZX_EXTRACT_PKG.POPULATE_TAX_DATA(P_REPORTING_LEVEL => P_REPORTING_LEVEL
                                    ,P_REPORTING_CONTEXT => P_REPORTING_ENTITY_ID
                                    ,P_REPORT_NAME => 'ZXJGTAX'
                                    ,P_REGISTER_TYPE => 'TAX'
                                    ,P_SUMMARY_LEVEL => L_SUMMARY_LEVEL
                                    ,P_PRODUCT => L_PRODUCT
                                    ,P_GL_DATE_LOW => P_GL_DATE_FROM
                                    ,P_GL_DATE_HIGH => P_GL_DATE_TO
                                    ,P_CURRENCY_CODE_LOW => P_CURRENCY_CODE
                                    ,P_CURRENCY_CODE_HIGH => P_CURRENCY_CODE
                                    ,P_ACCOUNTING_STATUS => 'ACCOUNTED'
                                    ,P_INCLUDE_ACCOUNTING_SEGMENTS => 'Y'
                                    ,P_MATRIX_REPORT => 'N'
                                    ,P_BALANCING_SEGMENT_LOW => P_BALANCING_SEG
                                    ,P_BALANCING_SEGMENT_HIGH => P_BALANCING_SEG
                                    ,P_TAXABLE_ACCOUNT_LOW => P_TAXABLE_ACCOUNT_FROM
                                    ,P_TAXABLE_ACCOUNT_HIGH => P_TAXABLE_ACCOUNT_TO
                                    ,P_INCLUDE_AP_STD_TRX_CLASS => 'Y'
                                    ,P_INCLUDE_AP_CM_TRX_CLASS => 'Y'
                                    ,P_INCLUDE_AP_DM_TRX_CLASS => 'Y'
                                    ,P_INCLUDE_AP_EXP_TRX_CLASS => 'Y'
                                    ,P_INCLUDE_AP_PREP_TRX_CLASS => 'Y'
                                    ,P_INCLUDE_AP_MIX_TRX_CLASS => 'Y'
                                    ,P_INCLUDE_AP_INT_TRX_CLASS => 'Y'
                                    ,P_INCLUDE_GL_MANUAL_LINES => 'Y'
                                    ,P_INCLUDE_AR_INV_TRX_CLASS => 'Y'
                                    ,P_INCLUDE_AR_APPL_TRX_CLASS => 'Y'
                                    ,P_INCLUDE_AR_ADJ_TRX_CLASS => 'Y'
                                    ,P_INCLUDE_AR_MISC_TRX_CLASS => 'Y'
                                    ,P_INCLUDE_AR_BR_TRX_CLASS => 'Y'
                                    ,P_INCLUDE_FULLY_NR_TAX_FLAG => 'Y'
                                    ,P_TAX_REGIME_CODE => P_TAX_REGIME_CODE
                                    ,P_TAX => P_TAX
                                    ,P_TAX_STATUS_CODE => P_TAX_STATUS_CODE
                                    ,P_TAX_RATE_CODE_LOW => P_TAX_RATE_CODE
                                    ,P_TAX_RATE_CODE_HIGH => P_TAX_RATE_CODE
                                    ,P_TAX_TYPE_CODE_LOW => P_TAX_TYPE
                                    ,P_TAX_TYPE_CODE_HIGH => P_TAX_TYPE
                                    ,P_REQUEST_ID => P_CONC_REQUEST_ID
                                    ,P_LEDGER_ID => P_LEDGER_ID
                                    ,P_CHART_OF_ACCOUNTS_ID => P_COA_ID
                                    ,P_ERRBUF => L_ERRBUF
                                    ,P_RETCODE => L_RETCODE);
    IF L_RETCODE <> 0 THEN
      /*SRW.MESSAGE('401'
                 ,'Return Code: ' || L_RETCODE)*/NULL;
      /*SRW.MESSAGE('402'
                 ,'Error Buffer: ' || L_ERRBUF)*/NULL;
      RETURN (FALSE);
    END IF;
    RETURN (TRUE);
  END CALL_TRL_ENGINE;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    ZX_EXTRACT_PKG.PURGE(P_CONC_REQUEST_ID);
    RETURN (TRUE);
  EXCEPTION
    WHEN OTHERS THEN
      /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
      RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION CF_RESPONSIBILITYFORMULA RETURN CHAR IS
  BEGIN
    RETURN (FND_GLOBAL.RESP_NAME);
  END CF_RESPONSIBILITYFORMULA;

  FUNCTION CF_USER_NAMEFORMULA RETURN CHAR IS
  BEGIN
    RETURN (FND_GLOBAL.USER_NAME);
  END CF_USER_NAMEFORMULA;

  FUNCTION CF_TAXABLE_AMTFORMULA(C_TRX_ID IN NUMBER
                                ,C_TRX_LINE_ID IN NUMBER) RETURN NUMBER IS
    L_INV_TAXABLE_AMT NUMBER := 0;
  BEGIN
    /*SRW.MESSAGE(100
               ,':: Inside formula ::')*/NULL;
    IF (CP_TRX_ID IS NULL) THEN
      CP_TRX_ID := 0;
    END IF;
    IF (CP_TRX_LINE_ID IS NULL) THEN
      CP_TRX_LINE_ID := 0;
    END IF;
    IF ((CP_TRX_ID <> C_TRX_ID) OR (CP_TRX_LINE_ID <> C_TRX_LINE_ID)) THEN
      SELECT
        SUM(A.TAXABLE_AMT)
      INTO L_INV_TAXABLE_AMT
      FROM
        ZX_REP_TRX_DETAIL_T A
      WHERE A.TRX_ID = C_TRX_ID
        AND A.TRX_LINE_ID = C_TRX_LINE_ID
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
    CP_TRX_ID := C_TRX_ID;
    CP_TRX_LINE_ID := C_TRX_LINE_ID;
    /*SRW.MESSAGE(101
               ,'trx_id : ' || C_TRX_ID || ' trx_line_id : ' || C_TRX_LINE_ID || ' taxable amt : ' || L_INV_TAXABLE_AMT)*/NULL;
    RETURN (L_INV_TAXABLE_AMT);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END CF_TAXABLE_AMTFORMULA;

  FUNCTION CF_TAXABLE_ACC_AMTFORMULA(C_TRX_ID IN NUMBER
                                    ,C_TRX_LINE_ID IN NUMBER) RETURN NUMBER IS
    L_INV_TAXABLE_AMT NUMBER := 0;
  BEGIN
    /*SRW.MESSAGE(100
               ,':: Inside formula ::')*/NULL;
    IF (CP_TRX_ID_ACC IS NULL) THEN
      CP_TRX_ID_ACC := 0;
    END IF;
    IF (CP_TRX_LINE_ID_ACC IS NULL) THEN
      CP_TRX_LINE_ID_ACC := 0;
    END IF;
    IF ((CP_TRX_ID_ACC <> C_TRX_ID) OR (CP_TRX_LINE_ID_ACC <> C_TRX_LINE_ID)) THEN
      SELECT
        SUM(A.TAXABLE_AMT_FUNCL_CURR)
      INTO L_INV_TAXABLE_AMT
      FROM
        ZX_REP_TRX_DETAIL_T A
      WHERE A.TRX_ID = C_TRX_ID
        AND A.TRX_LINE_ID = C_TRX_LINE_ID
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
    CP_TRX_ID_ACC := C_TRX_ID;
    CP_TRX_LINE_ID_ACC := C_TRX_LINE_ID;
    /*SRW.MESSAGE(101
               ,'trx_id : ' || C_TRX_ID || ' trx_line_id : ' || C_TRX_LINE_ID || ' taxable amt : ' || L_INV_TAXABLE_AMT)*/NULL;
    RETURN (L_INV_TAXABLE_AMT);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END CF_TAXABLE_ACC_AMTFORMULA;

  FUNCTION CP_TRX_ID_P RETURN NUMBER IS
  BEGIN
    RETURN CP_TRX_ID;
  END CP_TRX_ID_P;

  FUNCTION CP_TRX_LINE_ID_P RETURN NUMBER IS
  BEGIN
    RETURN CP_TRX_LINE_ID;
  END CP_TRX_LINE_ID_P;

  FUNCTION CP_TRX_ID_ACC_P RETURN NUMBER IS
  BEGIN
    RETURN CP_TRX_ID_ACC;
  END CP_TRX_ID_ACC_P;

  FUNCTION CP_TRX_LINE_ID_ACC_P RETURN NUMBER IS
  BEGIN
    RETURN CP_TRX_LINE_ID_ACC;
  END CP_TRX_LINE_ID_ACC_P;

  FUNCTION CP_REPORTING_LEVEL_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_REPORTING_LEVEL_NAME;
  END CP_REPORTING_LEVEL_NAME_P;

  FUNCTION CP_REPORTING_ENTITY_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_REPORTING_ENTITY_NAME;
  END CP_REPORTING_ENTITY_NAME_P;

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

END ZX_ZXJGTAX_XMLP_PKG;


/
