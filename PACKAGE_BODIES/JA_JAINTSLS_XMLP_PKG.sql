--------------------------------------------------------
--  DDL for Package Body JA_JAINTSLS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JA_JAINTSLS_XMLP_PKG" AS
/* $Header: JAINTSLSB.pls 120.1 2007/12/25 16:32:25 dwkrishn noship $ */
  FUNCTION CF_1FORMULA(LINE_AMOUNT IN NUMBER) RETURN NUMBER IS
    LINE_AMT NUMBER(17) := 0;
  BEGIN
    LINE_AMT := LINE_AMT + LINE_AMOUNT;
    RETURN (LINE_AMT);
  END CF_1FORMULA;

  FUNCTION C_LINE_TOTAL_W_TAXFORMULA(CS_TAX_TOTAL_1 IN NUMBER
                                    ,CS_LINE_TOTAL_WO_TAX_1 IN NUMBER) RETURN NUMBER IS
    LINE_TOTAL NUMBER(17) := 0;
  BEGIN
    LINE_TOTAL := LINE_TOTAL + CS_TAX_TOTAL_1 + CS_LINE_TOTAL_WO_TAX_1;
    RETURN (LINE_TOTAL);
  END C_LINE_TOTAL_W_TAXFORMULA;

  FUNCTION P_END_DATEVALIDTRIGGER RETURN BOOLEAN IS
  BEGIN
    IF P_END_DATE IS NULL THEN
      P_END_DATE := TRUNC(SYSDATE);
    END IF;
    RETURN (TRUE);
  END P_END_DATEVALIDTRIGGER;

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
    V_ORG_ID NUMBER;
    LV_SALES JAI_CMN_TAXES_ALL.TAX_TYPE%TYPE;
    LV_CST JAI_CMN_TAXES_ALL.TAX_TYPE%TYPE;
    a boolean;
  BEGIN
  a:=P_END_DATEVALIDTRIGGER;
  LP_END_DATE:=P_END_DATE;
    V_ORG_ID := FND_PROFILE.VALUE('ORG_ID');
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;

    BEGIN
      OPEN C_PROGRAM_ID(P_CONC_REQUEST_ID);
      FETCH C_PROGRAM_ID
       INTO V_PROGRAM_ID,V_ENABLE_TRACE;
      CLOSE C_PROGRAM_ID;
            IF V_ENABLE_TRACE = 'Y' THEN
        EXECUTE IMMEDIATE
          'ALTER SESSION SET EVENTS ''10046 trace name context forever, level 4''';
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
       NULL;
    END;
    IF P_START_DATE IS NULL THEN
      LV_SALES := '%SALES%';
      LV_CST := '%CST%';
      SELECT
        MIN(CUTX.TRX_DATE)
      INTO P_START_DATE
      FROM
        RA_CUSTOMER_TRX_ALL CUTX,
        JAI_AR_TRXS JCUTX,
        RA_CUSTOMER_TRX_LINES_ALL CUTXL,
        JAI_CMN_CUS_ADDRESSES JCUAD,
        JAI_AR_TRX_TAX_LINES JRCTAXL,
        JAI_CMN_TAXES_ALL JITC,
        AR_PAYMENT_SCHEDULES_ALL ARPS
      WHERE JCUTX.ORGANIZATION_ID = P_ORGANIZATION_ID
        AND CUTX.CUSTOMER_TRX_ID = JCUTX.CUSTOMER_TRX_ID
        AND CUTXL.CUSTOMER_TRX_ID = CUTX.CUSTOMER_TRX_ID
        AND JRCTAXL.LINK_TO_CUST_TRX_LINE_ID = CUTXL.CUSTOMER_TRX_LINE_ID
        AND JITC.TAX_ID = JRCTAXL.TAX_ID
        AND ( UPPER(JITC.TAX_TYPE) like LV_SALES
      OR UPPER(JITC.TAX_TYPE) like LV_CST )
        AND UPPER(CUTX.COMPLETE_FLAG) = 'Y'
        AND ARPS.CUSTOMER_TRX_ID = CUTX.CUSTOMER_TRX_ID
        AND jcuad.customer_id (+) = CUTX.SOLD_TO_CUSTOMER_ID;
    END IF;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION CF_1FORMULA0004(CUSTOMER_TRX_LINE_ID IN NUMBER) RETURN NUMBER IS
  BEGIN
    DECLARE
      EXCISE_TAX NUMBER;
      LV_EXCISE JAI_CMN_TAXES_ALL.TAX_TYPE%TYPE;
      LV_ADDL_EXCISE JAI_CMN_TAXES_ALL.TAX_TYPE%TYPE;
      LV_OTHER_EXCISE JAI_CMN_TAXES_ALL.TAX_TYPE%TYPE;
      LV_EXC_EDU_CESS JAI_CMN_TAXES_ALL.TAX_TYPE%TYPE;
      LV_SH_EXC_EDU_CESS JAI_CMN_TAXES_ALL.TAX_TYPE%TYPE;
    BEGIN
      LV_EXCISE := 'EXCISE';
      LV_ADDL_EXCISE := 'ADDL. EXCISE';
      LV_OTHER_EXCISE := 'OTHER EXCISE';
      LV_EXC_EDU_CESS := 'EXCISE_EDUCATION_CESS';
      LV_SH_EXC_EDU_CESS := 'EXCISE_SH_EDU_CESS';
      SELECT
        SUM(A.TAX_AMOUNT)
      INTO EXCISE_TAX
      FROM
        JAI_AR_TRX_TAX_LINES A,
        JAI_CMN_TAXES_ALL B
      WHERE A.LINK_TO_CUST_TRX_LINE_ID = CF_1FORMULA0004.CUSTOMER_TRX_LINE_ID
        AND A.TAX_ID = B.TAX_ID
        AND UPPER(B.TAX_TYPE) IN ( LV_EXCISE , LV_ADDL_EXCISE , LV_OTHER_EXCISE , LV_EXC_EDU_CESS , LV_SH_EXC_EDU_CESS );
      CP_EXCISE_1 := EXCISE_TAX;
      RETURN (NVL(EXCISE_TAX
                ,0));
    END;
  END CF_1FORMULA0004;

  FUNCTION CF_2FORMULA(CUSTOMER_TRX_LINE_ID IN NUMBER) RETURN NUMBER IS
  BEGIN
    DECLARE
      OTHER_TAX NUMBER;
      LV_EXCISE JAI_CMN_TAXES_ALL.TAX_TYPE%TYPE;
      LV_ADDL_EXCISE JAI_CMN_TAXES_ALL.TAX_TYPE%TYPE;
      LV_OTHER_EXCISE JAI_CMN_TAXES_ALL.TAX_TYPE%TYPE;
      LV_EXC_EDU_CESS JAI_CMN_TAXES_ALL.TAX_TYPE%TYPE;
      LV_SALES_TAX JAI_CMN_TAXES_ALL.TAX_TYPE%TYPE;
      LV_CST JAI_CMN_TAXES_ALL.TAX_TYPE%TYPE;
      LV_SH_EXC_EDU_CESS JAI_CMN_TAXES_ALL.TAX_TYPE%TYPE;
    BEGIN
      LV_EXCISE := 'EXCISE';
      LV_ADDL_EXCISE := 'ADDL. EXCISE';
      LV_OTHER_EXCISE := 'OTHER EXCISE';
      LV_EXC_EDU_CESS := 'EXCISE_EDUCATION_CESS';
      LV_SALES_TAX := 'SALES TAX';
      LV_CST := 'CST';
      LV_SH_EXC_EDU_CESS := 'EXCISE_SH_EDU_CESS';
      SELECT
        SUM(A.TAX_AMOUNT)
      INTO OTHER_TAX
      FROM
        JAI_AR_TRX_TAX_LINES A,
        JAI_CMN_TAXES_ALL B
      WHERE A.LINK_TO_CUST_TRX_LINE_ID = CF_2FORMULA.CUSTOMER_TRX_LINE_ID
        AND A.TAX_ID = B.TAX_ID
        AND UPPER(B.TAX_TYPE) NOT IN ( LV_EXCISE , LV_ADDL_EXCISE , LV_OTHER_EXCISE , LV_EXC_EDU_CESS , LV_SALES_TAX , LV_CST , LV_SH_EXC_EDU_CESS );
      CP_ADDL_OTHER_TAXES_1 := NVL(OTHER_TAX
                                  ,0);
      RETURN (NVL(OTHER_TAX
                ,0));
    END;
  END CF_2FORMULA;

  FUNCTION CF_1FORMULA0013(CUSTOMER_TRX_ID IN NUMBER) RETURN NUMBER IS
    V_TOTAL_AMOUNT NUMBER;
  BEGIN
    SELECT
      SUM(NVL(LINE_AMOUNT
             ,0)) + SUM(NVL(TAX_AMOUNT
             ,0))
    INTO V_TOTAL_AMOUNT
    FROM
      JAI_AR_TRX_LINES
    WHERE CUSTOMER_TRX_ID = CF_1FORMULA0013.CUSTOMER_TRX_ID;
    RETURN (V_TOTAL_AMOUNT);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (0);
  END CF_1FORMULA0013;

  FUNCTION CF_2FORMULA0008(TAX_ACCOUNT_ID IN NUMBER) RETURN CHAR IS
    CURSOR C_ACCOUNT(P_CODE_COMBINATION_ID IN NUMBER) IS
      SELECT
        CONCATENATED_SEGMENTS
      FROM
        GL_CODE_COMBINATIONS_KFV
      WHERE CODE_COMBINATION_ID = P_CODE_COMBINATION_ID;
    V_ACCOUNT_CODE VARCHAR2(285);
  BEGIN
    OPEN C_ACCOUNT(TAX_ACCOUNT_ID);
    FETCH C_ACCOUNT
     INTO V_ACCOUNT_CODE;
    CLOSE C_ACCOUNT;
    RETURN V_ACCOUNT_CODE;
  END CF_2FORMULA0008;

  FUNCTION CF_SALES_TAXABLE_AMT_2FORMULA(TAX_TYPE IN VARCHAR2
                                        ,STAX_RATE IN NUMBER
                                        ,STAX_AMT IN NUMBER) RETURN NUMBER IS
    V_SALES_TAX_BASE_AMT NUMBER := 0;
  BEGIN
    IF TAX_TYPE in ('Sales Tax','CST') AND NVL(STAX_RATE
       ,0) <> 0 THEN
      V_SALES_TAX_BASE_AMT := (STAX_AMT * 100) / STAX_RATE;
    END IF;
    RETURN V_SALES_TAX_BASE_AMT;
  END CF_SALES_TAXABLE_AMT_2FORMULA;

  FUNCTION CF_TRX_NUMBER_DATE_1FORMULA(TRX_NUMBER IN VARCHAR2
                                      ,TRX_DATE IN DATE) RETURN CHAR IS
  BEGIN
    RETURN TRX_NUMBER || ', ' || TO_CHAR(TRX_DATE
                  ,'DD-MON-YYYY');
  END CF_TRX_NUMBER_DATE_1FORMULA;

  FUNCTION CF_1FORMULA0005(CUSTOMER_TRX_ID IN NUMBER
                          ,ORDER_LINE_ID IN VARCHAR2
                          ,LINE_AMOUNT IN NUMBER) RETURN NUMBER IS
    V_LINE_AMOUNT RA_CUSTOMER_TRX_LINES_ALL.EXTENDED_AMOUNT%TYPE;
    CURSOR C_LINE_AMOUNT(CP_LINE_TYPE IN RA_CUSTOMER_TRX_LINES_ALL.LINE_TYPE%TYPE) IS
      SELECT
        SUM(NVL(EXTENDED_AMOUNT
               ,0))
      FROM
        RA_CUSTOMER_TRX_LINES_ALL
      WHERE CUSTOMER_TRX_ID = CF_1FORMULA0005.CUSTOMER_TRX_ID
        AND LINE_TYPE = CP_LINE_TYPE
        AND SALES_ORDER_LINE = ORDER_LINE_ID
      GROUP BY
        SALES_ORDER_LINE;
    CURSOR C_CREATED_FROM IS
      SELECT
        CREATED_FROM
      FROM
        RA_CUSTOMER_TRX_ALL
      WHERE CUSTOMER_TRX_ID = CF_1FORMULA0005.CUSTOMER_TRX_ID;
    V_CREATED_FROM RA_CUSTOMER_TRX_ALL.CREATED_FROM%TYPE;
    MY_EXCEPTION EXCEPTION;
  BEGIN
    OPEN C_CREATED_FROM;
    FETCH C_CREATED_FROM
     INTO V_CREATED_FROM;
    CLOSE C_CREATED_FROM;
    IF V_CREATED_FROM = 'RAXTRX' THEN
      OPEN C_LINE_AMOUNT('LINE');
      FETCH C_LINE_AMOUNT
       INTO V_LINE_AMOUNT;
      CLOSE C_LINE_AMOUNT;
      IF V_LINE_AMOUNT IS NULL THEN
        /*SRW.MESSAGE(100
                   ,'created from ' || V_CREATED_FROM)*/NULL;
        /*SRW.MESSAGE(101
                   ,' Customer trx id  ' || CUSTOMER_TRX_ID)*/NULL;
        /*SRW.MESSAGE(102
                   ,' Sales order no  ' || ORDER_LINE_ID)*/NULL;
        RAISE MY_EXCEPTION;
      END IF;
      RETURN V_LINE_AMOUNT;
    ELSIF V_CREATED_FROM = 'ARXTWMAI' THEN
      IF LINE_AMOUNT IS NULL THEN
        /*SRW.MESSAGE(100
                   ,'created from ' || V_CREATED_FROM)*/NULL;
        /*SRW.MESSAGE(101
                   ,' Customer trx id  ' || CUSTOMER_TRX_ID)*/NULL;
        /*SRW.MESSAGE(102
                   ,' Sales order no  ' || ORDER_LINE_ID)*/NULL;
        RAISE MY_EXCEPTION;
      END IF;
      RETURN LINE_AMOUNT;
    END IF;
    RETURN NULL;
  EXCEPTION
    WHEN MY_EXCEPTION THEN
      /*SRW.MESSAGE(100
                 ,'created from ' || V_CREATED_FROM)*/NULL;
      /*SRW.MESSAGE(101
                 ,' Customer trx id  ' || CUSTOMER_TRX_ID)*/NULL;
      /*SRW.MESSAGE(102
                 ,' Sales order no  ' || ORDER_LINE_ID)*/NULL;
      RETURN NULL;
  END CF_1FORMULA0005;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    NULL;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION CF_VAT_TAXES_1(CUSTOMER_TRX_LINE_ID IN NUMBER) RETURN NUMBER IS
    VAT_TAX NUMBER;
  BEGIN
    SELECT
      SUM(A.FUNC_TAX_AMOUNT)
    INTO VAT_TAX
    FROM
      JAI_AR_TRX_TAX_LINES A,
      JAI_CMN_TAXES_ALL B
    WHERE A.LINK_TO_CUST_TRX_LINE_ID = CF_VAT_TAXES_1.CUSTOMER_TRX_LINE_ID
      AND A.TAX_ID = B.TAX_ID
      AND UPPER(B.TAX_TYPE) IN (
      SELECT
        TAX_TYPE
      FROM
        JAI_REGIME_TAX_TYPES_V
      WHERE REGIME_CODE = 'VAT' );
    CP_VAT_TAXES_1 := NVL(VAT_TAX
                         ,0);
    RETURN (NVL(VAT_TAX
              ,0));
  END CF_VAT_TAXES_1;

  FUNCTION CP_EXCISE_1_P RETURN NUMBER IS
  BEGIN
    RETURN CP_EXCISE_1;
  END CP_EXCISE_1_P;

  FUNCTION CP_ADDL_OTHER_TAXES_1_P RETURN NUMBER IS
  BEGIN
    RETURN CP_ADDL_OTHER_TAXES_1;
  END CP_ADDL_OTHER_TAXES_1_P;

  FUNCTION CP_VAT_TAXES_1_P RETURN NUMBER IS
  BEGIN
    RETURN CP_VAT_TAXES_1;
  END CP_VAT_TAXES_1_P;

END JA_JAINTSLS_XMLP_PKG;



/