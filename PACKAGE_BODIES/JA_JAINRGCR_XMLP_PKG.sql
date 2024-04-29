--------------------------------------------------------
--  DDL for Package Body JA_JAINRGCR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JA_JAINRGCR_XMLP_PKG" AS
/* $Header: JAINRGCRB.pls 120.1 2007/12/25 16:28:07 dwkrishn noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
    CURSOR CUR_PROGRAM_ID(P_REQUEST_ID IN NUMBER) IS
      SELECT
        CONCURRENT_PROGRAM_ID,
        NVL(ENABLE_TRACE
           ,'N')
      FROM
        FND_CONCURRENT_REQUESTS
      WHERE REQUEST_ID = P_REQUEST_ID;
    CURSOR CUR_GET_AUDSID IS
      SELECT
        A.SID,
        A.SERIAL#,
        B.SPID
      FROM
        V$SESSION A,
        V$PROCESS B
      WHERE AUDSID = USERENV('SESSIONID')
        AND A.PADDR = B.ADDR;
    CURSOR CUR_GET_DBNAME IS
      SELECT
        NAME
      FROM
        V$DATABASE;
    AUDSID NUMBER := USERENV('SESSIONID');
    SID NUMBER;
    SERIAL NUMBER;
    SPID VARCHAR2(9);
    NAME1 VARCHAR2(25);
    V_ENABLE_TRACE FND_CONCURRENT_PROGRAMS.ENABLE_TRACE%TYPE;
    V_PROGRAM_ID FND_CONCURRENT_PROGRAMS.CONCURRENT_PROGRAM_ID%TYPE;
  BEGIN

    /*CP_FROM_DATE := TO_CHAR(TO_DATE(P_FROM_DATE,'YYYY/MM/DD HH24:MI:SS'),'DD-MON-YY');
    CP_TO_DATE := TO_CHAR(TO_DATE(P_TO_DATE,'YYYY/MM/DD HH24:MI:SS'),'DD-MON-YY');*/
    CP_FROM_DATE := to_char(P_FROM_DATE,'DD-MON-YY');
    CP_TO_DATE := to_char(P_TO_DATE,'DD-MON-YY');

    /*SRW.MESSAGE(1275
               ,'Report Version is 120.3 Last modified date is 20/06/007')*/NULL;
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    BEGIN
      OPEN CUR_PROGRAM_ID(P_CONC_REQUEST_ID);
      FETCH CUR_PROGRAM_ID
       INTO V_PROGRAM_ID,V_ENABLE_TRACE;
      CLOSE CUR_PROGRAM_ID;
      /*SRW.MESSAGE(1275
                 ,'v_program_id -> ' || V_PROGRAM_ID || ', v_enable_trace -> ' || V_ENABLE_TRACE || ', request_id -> ' || P_CONC_REQUEST_ID)*/NULL;
      IF V_ENABLE_TRACE = 'Y' THEN
        OPEN CUR_GET_AUDSID;
        FETCH CUR_GET_AUDSID
         INTO SID,SERIAL,SPID;
        CLOSE CUR_GET_AUDSID;
        OPEN CUR_GET_DBNAME;
        FETCH CUR_GET_DBNAME
         INTO NAME1;
        CLOSE CUR_GET_DBNAME;
        /*SRW.MESSAGE(1275
                   ,'TraceFile Name = ' || LOWER(NAME1) || '_ora_' || SPID || '.trc')*/NULL;
        EXECUTE IMMEDIATE
          'ALTER SESSION SET EVENTS ''10046 trace name context forever, level 4''';
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        /*SRW.MESSAGE(1275
                   ,'Error during enabling the trace. ErrCode -> ' || SQLCODE || ', ErrMesg ->' || SQLERRM)*/NULL;
    END;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION CF_CREDIT_TAKENFORMULA(CS_SERVICE_CREDIT IN NUMBER
                                 ,CS_EDU_CREDIT IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (NVL(CS_SERVICE_CREDIT
              ,0) + NVL(CS_EDU_CREDIT
              ,0));
  END CF_CREDIT_TAKENFORMULA;

  FUNCTION CF_CREDIT_UTILIZEDFORMULA RETURN NUMBER IS
    CURSOR CUR_AR_UTIL_CREDIT(CP_SOURCE IN JAI_RGM_TRX_REFS.SOURCE%TYPE) IS
      SELECT
        SUM(RECOVERED_AMOUNT)
      FROM
        JAI_RGM_TRX_REFS
      WHERE SOURCE = CP_SOURCE
        AND TAX_TYPE in ( LV_TAX_TYPE_SERVICE , LV_TAX_TYPE_SERVICE_EDU_CESS , LV_TAX_TYPE_SH_SER_EDU_CESS )
        AND ORGANIZATION_ID IN (
        SELECT
          DISTINCT
          ORGANIZATION_ID
        FROM
          JAI_RGM_ORG_REGNS_V
        WHERE REGIME_CODE = LV_SERVICE_REGIME
          AND REGISTRATION_TYPE = LV_OTH_REG_TYPE
          AND ATTRIBUTE_TYPE_CODE = LV_PRIM_ATT_TYPE_CODE
          AND ATTRIBUTE_CODE = LV_SERVICE_ATT_CODE
          AND ATTRIBUTE_VALUE = P_REGM_PRMY_REGN )
        AND ( NVL(TRUNC(CREATION_DATE)
         ,SYSDATE) ) BETWEEN ( NVL(P_FROM_DATE
         ,SYSDATE) )
        AND ( NVL(P_TO_DATE
         ,SYSDATE) );
    CURSOR CUR_AR_SER_DIST_OUT_DEBIT IS
      SELECT
        NVL(SUM(DEBIT_AMOUNT)
           ,0)
      FROM
        JAI_RGM_TRX_RECORDS
      WHERE SOURCE = LV_SERVICE_SRC_DISTRIBUTE_OUT
        AND REGIME_CODE = LV_SERVICE_REGIME
        AND TAX_TYPE IN ( LV_TAX_TYPE_SERVICE , LV_TAX_TYPE_SERVICE_EDU_CESS , LV_TAX_TYPE_SH_SER_EDU_CESS )
        AND REGIME_PRIMARY_REGNO = P_REGM_PRMY_REGN
        AND ( NVL(TRUNC(CREATION_DATE)
         ,SYSDATE) ) BETWEEN ( NVL(P_FROM_DATE
         ,SYSDATE) )
        AND ( NVL(P_TO_DATE
         ,SYSDATE) );
    CURSOR CUR_MANUAL_DEBIT(CP_SOURCE IN JAI_RGM_TRX_REFS.SOURCE%TYPE) IS
      SELECT
        NVL(SUM(DEBIT_AMOUNT)
           ,0)
      FROM
        JAI_RGM_TRX_RECORDS
      WHERE SOURCE = CP_SOURCE
        AND REGIME_CODE = LV_SERVICE_REGIME
        AND TAX_TYPE IN ( LV_TAX_TYPE_SERVICE , LV_TAX_TYPE_SERVICE_EDU_CESS , LV_TAX_TYPE_SH_SER_EDU_CESS )
        AND SOURCE_TRX_TYPE IN ( LV_ADJUST_LIABILITY , LV_LIABILITY )
        AND REGIME_PRIMARY_REGNO = P_REGM_PRMY_REGN
        AND ( NVL(TRUNC(CREATION_DATE)
         ,SYSDATE) ) BETWEEN ( NVL(P_FROM_DATE
         ,SYSDATE) )
        AND ( NVL(P_TO_DATE
         ,SYSDATE) );
    CURSOR CUR_PAYMENT(CP_SOURCE IN JAI_RGM_TRX_RECORDS.SOURCE%TYPE,CP_TRX_TYPE IN JAI_RGM_TRX_RECORDS.SOURCE_TRX_TYPE%TYPE) IS
      SELECT
        NVL(SUM(DEBIT_AMOUNT)
           ,0)
      FROM
        JAI_RGM_TRX_RECORDS
      WHERE SOURCE = CP_SOURCE
        AND REGIME_CODE = LV_SERVICE_REGIME
        AND TAX_TYPE IN ( LV_TAX_TYPE_SERVICE , LV_TAX_TYPE_SERVICE_EDU_CESS , LV_TAX_TYPE_SH_SER_EDU_CESS )
        AND SOURCE_TRX_TYPE = CP_TRX_TYPE
        AND REGIME_PRIMARY_REGNO = P_REGM_PRMY_REGN
        AND ( NVL(TRUNC(CREATION_DATE)
         ,SYSDATE) ) BETWEEN ( NVL(P_FROM_DATE
         ,SYSDATE) )
        AND ( NVL(P_TO_DATE
         ,SYSDATE) );
    LN_AR_UTIL_CREDIT NUMBER := 0;
    LN_AR_SER_DIST_OUT_DEBIT NUMBER := 0;
    LV_MANUAL_DEBIT NUMBER := 0;
    LV_PAYMENT NUMBER := 0;
  BEGIN
    OPEN CUR_AR_UTIL_CREDIT('AR');
    FETCH CUR_AR_UTIL_CREDIT
     INTO LN_AR_UTIL_CREDIT;
    CLOSE CUR_AR_UTIL_CREDIT;
    OPEN CUR_AR_SER_DIST_OUT_DEBIT;
    FETCH CUR_AR_SER_DIST_OUT_DEBIT
     INTO LN_AR_SER_DIST_OUT_DEBIT;
    CLOSE CUR_AR_SER_DIST_OUT_DEBIT;
    OPEN CUR_MANUAL_DEBIT('MANUAL');
    FETCH CUR_MANUAL_DEBIT
     INTO LV_MANUAL_DEBIT;
    CLOSE CUR_MANUAL_DEBIT;
    OPEN CUR_PAYMENT('MANUAL','PAYMENT');
    FETCH CUR_PAYMENT
     INTO LV_PAYMENT;
    CLOSE CUR_PAYMENT;
    RETURN (NVL(LN_AR_UTIL_CREDIT
              ,0) + NVL(LN_AR_SER_DIST_OUT_DEBIT
              ,0) + NVL(LV_MANUAL_DEBIT
              ,0) - NVL(LV_PAYMENT
              ,0));
  END CF_CREDIT_UTILIZEDFORMULA;

  FUNCTION CF_CLOSING_BALFORMULA(CF_OPENING_BAL IN NUMBER
                                ,CF_CREDIT_TAKEN IN NUMBER
                                ,CF_CREDIT_UTILIZED IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (NVL(CF_OPENING_BAL
              ,0) + NVL(CF_CREDIT_TAKEN
              ,0) - NVL(CF_CREDIT_UTILIZED
              ,0));
  END CF_CLOSING_BALFORMULA;

  FUNCTION CF_OPENING_BALFORMULA RETURN NUMBER IS
    CURSOR CUR_INVOICE_OPEN_BAL(CP_SOURCE IN JAI_RGM_TRX_REFS.SOURCE%TYPE) IS
      SELECT
        SUM(RECOVERED_AMOUNT)
      FROM
        JAI_RGM_TRX_REFS
      WHERE SOURCE = CP_SOURCE
        AND TAX_TYPE in ( LV_TAX_TYPE_SERVICE , LV_TAX_TYPE_SERVICE_EDU_CESS , LV_TAX_TYPE_SH_SER_EDU_CESS )
        AND TRUNC(CREATION_DATE) < P_FROM_DATE
        AND ORGANIZATION_ID in (
        SELECT
          DISTINCT
          ORGANIZATION_ID
        FROM
          JAI_RGM_ORG_REGNS_V
        WHERE REGIME_CODE = LV_SERVICE_REGIME
          AND REGISTRATION_TYPE = LV_OTH_REG_TYPE
          AND ATTRIBUTE_TYPE_CODE = LV_PRIM_ATT_TYPE_CODE
          AND ATTRIBUTE_CODE = LV_SERVICE_ATT_CODE
          AND ATTRIBUTE_VALUE = P_REGM_PRMY_REGN );
    CURSOR CUR_DIST_IN IS
      SELECT
        SUM(CREDIT_AMOUNT)
      FROM
        JAI_RGM_TRX_RECORDS
      WHERE SOURCE = LV_SERVICE_SRC_DISTRIBUTE_IN
        AND REGIME_CODE = LV_SERVICE_REGIME
        AND TAX_TYPE IN ( LV_TAX_TYPE_SERVICE , LV_TAX_TYPE_SERVICE_EDU_CESS , LV_TAX_TYPE_SH_SER_EDU_CESS )
        AND REGIME_PRIMARY_REGNO = P_REGM_PRMY_REGN
        AND ( NVL(TRUNC(CREATION_DATE)
         ,TRUNC(SYSDATE)) ) < ( NVL(P_FROM_DATE
         ,TRUNC(SYSDATE)) );
    CURSOR CUR_MANUAL_IN(CP_SOURCE IN JAI_RGM_TRX_RECORDS.SOURCE%TYPE) IS
      SELECT
        SUM(CREDIT_AMOUNT)
      FROM
        JAI_RGM_TRX_RECORDS
      WHERE SOURCE = CP_SOURCE
        AND REGIME_CODE = LV_SERVICE_REGIME
        AND TAX_TYPE IN ( LV_TAX_TYPE_SERVICE , LV_TAX_TYPE_SERVICE_EDU_CESS , LV_TAX_TYPE_SH_SER_EDU_CESS )
        AND SOURCE_TRX_TYPE IN ( LV_ADJUST_RECOVERY , LV_RECOVERY )
        AND REGIME_PRIMARY_REGNO = P_REGM_PRMY_REGN
        AND ( NVL(TRUNC(CREATION_DATE)
         ,TRUNC(SYSDATE)) ) < ( NVL(P_FROM_DATE
         ,TRUNC(SYSDATE)) );
    CURSOR CUR_AR_UTIL_CREDIT(CP_SOURCE IN JAI_RGM_TRX_REFS.SOURCE%TYPE) IS
      SELECT
        SUM(RECOVERED_AMOUNT)
      FROM
        JAI_RGM_TRX_REFS
      WHERE SOURCE = CP_SOURCE
        AND TAX_TYPE in ( LV_TAX_TYPE_SERVICE , LV_TAX_TYPE_SERVICE_EDU_CESS , LV_TAX_TYPE_SH_SER_EDU_CESS )
        AND TRUNC(CREATION_DATE) < P_FROM_DATE
        AND ORGANIZATION_ID IN (
        SELECT
          DISTINCT
          ORGANIZATION_ID
        FROM
          JAI_RGM_ORG_REGNS_V
        WHERE REGIME_CODE = LV_SERVICE_REGIME
          AND REGISTRATION_TYPE = LV_OTH_REG_TYPE
          AND ATTRIBUTE_TYPE_CODE = LV_PRIM_ATT_TYPE_CODE
          AND ATTRIBUTE_CODE = LV_SERVICE_ATT_CODE
          AND ATTRIBUTE_VALUE = P_REGM_PRMY_REGN );
    CURSOR CUR_AR_SER_DIST_OUT_DEBIT IS
      SELECT
        NVL(SUM(DEBIT_AMOUNT)
           ,0)
      FROM
        JAI_RGM_TRX_RECORDS
      WHERE SOURCE = LV_SERVICE_SRC_DISTRIBUTE_OUT
        AND REGIME_CODE = LV_SERVICE_REGIME
        AND TAX_TYPE IN ( LV_TAX_TYPE_SERVICE , LV_TAX_TYPE_SERVICE_EDU_CESS , LV_TAX_TYPE_SH_SER_EDU_CESS )
        AND REGIME_PRIMARY_REGNO = P_REGM_PRMY_REGN
        AND ( NVL(TRUNC(CREATION_DATE)
         ,TRUNC(SYSDATE)) ) < ( NVL(P_FROM_DATE
         ,TRUNC(SYSDATE)) );
    CURSOR CUR_MANUAL_DEBIT(CP_SOURCE IN JAI_RGM_TRX_RECORDS.SOURCE%TYPE) IS
      SELECT
        NVL(SUM(DEBIT_AMOUNT)
           ,0)
      FROM
        JAI_RGM_TRX_RECORDS
      WHERE SOURCE = CP_SOURCE
        AND REGIME_CODE = LV_SERVICE_REGIME
        AND TAX_TYPE IN ( LV_TAX_TYPE_SERVICE , LV_TAX_TYPE_SH_SER_EDU_CESS , LV_TAX_TYPE_SERVICE_EDU_CESS )
        AND SOURCE_TRX_TYPE IN ( LV_LIABILITY , LV_ADJUST_LIABILITY )
        AND REGIME_PRIMARY_REGNO = P_REGM_PRMY_REGN
        AND ( NVL(TRUNC(CREATION_DATE)
         ,TRUNC(SYSDATE)) ) < ( NVL(P_FROM_DATE
         ,TRUNC(SYSDATE)) );
    CURSOR CUR_PAYMENT(CP_SOURCE IN JAI_RGM_TRX_RECORDS.SOURCE%TYPE,CP_SOURCE_TRX_TYPE IN JAI_RGM_TRX_RECORDS.SOURCE_TRX_TYPE%TYPE) IS
      SELECT
        NVL(SUM(DEBIT_AMOUNT)
           ,0)
      FROM
        JAI_RGM_TRX_RECORDS
      WHERE SOURCE = CP_SOURCE
        AND REGIME_CODE = LV_SERVICE_REGIME
        AND TAX_TYPE IN ( LV_TAX_TYPE_SERVICE , LV_TAX_TYPE_SERVICE_EDU_CESS , LV_TAX_TYPE_SH_SER_EDU_CESS )
        AND SOURCE_TRX_TYPE = CP_SOURCE_TRX_TYPE
        AND REGIME_PRIMARY_REGNO = P_REGM_PRMY_REGN
        AND ( NVL(TRUNC(CREATION_DATE)
         ,TRUNC(SYSDATE)) ) < ( NVL(P_FROM_DATE
         ,TRUNC(SYSDATE)) );
    LV_INV_OPEN_BAL NUMBER := 0;
    LV_OPEN_DIST_BAL NUMBER := 0;
    LV_AR_UTIL_CREDIT NUMBER := 0;
    LV_AR_SER_DIST_OUT_DEBIT NUMBER := 0;
    LV_MANUAL_BAL NUMBER := 0;
    LV_MANUAL_DEBIT_BAL NUMBER := 0;
    LV_MANUAL_PAYMENT NUMBER := 0;
  BEGIN
    OPEN CUR_INVOICE_OPEN_BAL('AP');
    FETCH CUR_INVOICE_OPEN_BAL
     INTO LV_INV_OPEN_BAL;
    CLOSE CUR_INVOICE_OPEN_BAL;
    OPEN CUR_DIST_IN;
    FETCH CUR_DIST_IN
     INTO LV_OPEN_DIST_BAL;
    CLOSE CUR_DIST_IN;
    OPEN CUR_MANUAL_IN('MANUAL');
    FETCH CUR_MANUAL_IN
     INTO LV_MANUAL_BAL;
    CLOSE CUR_MANUAL_IN;
    OPEN CUR_MANUAL_DEBIT('MANUAL');
    FETCH CUR_MANUAL_DEBIT
     INTO LV_MANUAL_DEBIT_BAL;
    CLOSE CUR_MANUAL_DEBIT;
    OPEN CUR_AR_UTIL_CREDIT('AR');
    FETCH CUR_AR_UTIL_CREDIT
     INTO LV_AR_UTIL_CREDIT;
    CLOSE CUR_AR_UTIL_CREDIT;
    OPEN CUR_AR_SER_DIST_OUT_DEBIT;
    FETCH CUR_AR_SER_DIST_OUT_DEBIT
     INTO LV_AR_SER_DIST_OUT_DEBIT;
    CLOSE CUR_AR_SER_DIST_OUT_DEBIT;
    OPEN CUR_PAYMENT('MANUAL','PAYMENT');
    FETCH CUR_PAYMENT
     INTO LV_MANUAL_PAYMENT;
    CLOSE CUR_PAYMENT;
    RETURN (NVL(LV_OPEN_DIST_BAL
              ,0) + NVL(LV_INV_OPEN_BAL
              ,0) + NVL(LV_MANUAL_BAL
              ,0) - NVL(LV_AR_UTIL_CREDIT
              ,0) - NVL(LV_AR_SER_DIST_OUT_DEBIT
              ,0) - NVL(LV_MANUAL_DEBIT_BAL
              ,0) + NVL(LV_MANUAL_PAYMENT
              ,0));
  END CF_OPENING_BALFORMULA;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
    LV_REPORTING_LEVEL VARCHAR2(2000);
    LN_REPORTING_ENTITY_ID NUMBER;
    LV_PREDICATE_TYPE VARCHAR2(2000);
  BEGIN
    LV_REPORTING_LEVEL := P_REPORTING_LEVEL;
    LN_REPORTING_ENTITY_ID := P_REPORTING_ENTITY_ID;
    FND_MO_REPORTING_API.INITIALIZE(LV_REPORTING_LEVEL
                                   ,LN_REPORTING_ENTITY_ID
                                   ,LV_PREDICATE_TYPE);
    P_ORG_WHERE := P_ORG_WHERE || FND_MO_REPORTING_API.GET_PREDICATE('JPVS'
                                                     ,NULL
                                                     ,NULL);
    P_ORG_WHERE := P_ORG_WHERE || FND_MO_REPORTING_API.GET_PREDICATE('APA'
                                                     ,NULL
                                                     ,NULL);
    P_ORG_WHERE := P_ORG_WHERE || FND_MO_REPORTING_API.GET_PREDICATE('PVSA'
                                                     ,NULL
                                                     ,NULL);
    P_ORG_WHERE := P_ORG_WHERE || FND_MO_REPORTING_API.GET_PREDICATE('APSA'
                                                     ,NULL
                                                     ,NULL);
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION CF_SERVICE_TYPEFORMULA(SERVICE_TYPE_CODE IN VARCHAR2) RETURN CHAR IS
    CURSOR GET_SERVICE_TYPE_CUR IS
      SELECT
        DESCRIPTION DISPLAYED_FIELD
      FROM
        JA_LOOKUPS
      WHERE LOOKUP_TYPE = 'JAI_SERVICE_TYPE'
        AND LOOKUP_CODE = SERVICE_TYPE_CODE;
    LV_SERVICE_TYPE VARCHAR2(80);
  BEGIN
    OPEN GET_SERVICE_TYPE_CUR;
    FETCH GET_SERVICE_TYPE_CUR
     INTO LV_SERVICE_TYPE;
    CLOSE GET_SERVICE_TYPE_CUR;
    RETURN LV_SERVICE_TYPE;
  END CF_SERVICE_TYPEFORMULA;

  FUNCTION CF_VALUEFORMULA(INVOICE_ID IN NUMBER
                          ,SOURCE_TYPE IN VARCHAR2
                          ,ST_RATE IN NUMBER
                          ,ST IN NUMBER
                          ,VALUE IN NUMBER) RETURN NUMBER IS
    LV_TAX_AMT NUMBER := 0;
    LV_RET_VAL NUMBER := 0;
    LV_VALUE NUMBER := 0;
    LN_AMOUNT_REMAINING NUMBER;
    CURSOR C_GET_AMT_REMAIN IS
      SELECT
        SUM(AMOUNT_REMAINING) AMOUNT_REMAINING
      FROM
        AP_PAYMENT_SCHEDULES_ALL
      WHERE INVOICE_ID = CF_VALUEFORMULA.INVOICE_ID;
  BEGIN
    OPEN C_GET_AMT_REMAIN;
    FETCH C_GET_AMT_REMAIN
     INTO LN_AMOUNT_REMAINING;
    CLOSE C_GET_AMT_REMAIN;
    IF SOURCE_TYPE = 'AP' THEN
      IF NVL(ST_RATE
         ,0) <> 0 THEN
        LV_TAX_AMT := (ST * 100) / ST_RATE;
      END IF;
      LV_VALUE := NVL(VALUE
                     ,0) - NVL(LN_AMOUNT_REMAINING
                     ,0);
      IF NVL(VALUE
         ,0) <> 0 THEN
        LV_RET_VAL := (NVL(LV_VALUE
                         ,0) * NVL(LV_TAX_AMT
                         ,0)) / VALUE;
      END IF;
    ELSE
      LV_RET_VAL := VALUE;
    END IF;
    RETURN (ROUND(NVL(LV_RET_VAL
                    ,0)
                ,2));
  END CF_VALUEFORMULA;

  FUNCTION CF_DESCRIPTIONFORMULA(SRC_DOC_ID IN NUMBER
                                ,ITEM_ID IN NUMBER
                                ,SOURCE_TYPE IN VARCHAR2) RETURN CHAR IS
    CURSOR CUR_DESCRIPTION IS
      SELECT
        DISTINCT
        HAOU1.NAME FROM_ORG,
        HAOU2.NAME TO_ORG
      FROM
        JAI_RGM_DIS_SRC_HDRS SRC_HDRS,
        JAI_RGM_DIS_SRC_TAXES SRC_TAXS,
        JAI_RGM_DIS_DES_HDRS DES_HDRS,
        JAI_RGM_DIS_DES_TAXES DES_TAXS,
        HR_ALL_ORGANIZATION_UNITS HAOU1,
        HR_ALL_ORGANIZATION_UNITS HAOU2
      WHERE SRC_HDRS.TRANSFER_ID = DES_HDRS.TRANSFER_ID
        AND SRC_HDRS.TRANSFER_ID = SRC_TAXS.TRANSFER_ID
        AND DES_HDRS.TRANSFER_DESTINATION_ID = DES_TAXS.TRANSFER_DESTINATION_ID
        AND DES_TAXS.TRANSFER_SOURCE_ID = SRC_TAXS.TRANSFER_SOURCE_ID
        AND SRC_HDRS.TRANSFER_ID = SRC_DOC_ID
        AND SRC_HDRS.PARTY_ID = HAOU1.ORGANIZATION_ID
        AND DES_HDRS.DESTINATION_PARTY_ID = HAOU2.ORGANIZATION_ID;
    CURSOR CUR_ITEM_DESC IS
      SELECT
        DISTINCT
        DESCRIPTION
      FROM
        MTL_SYSTEM_ITEMS
      WHERE INVENTORY_ITEM_ID = ITEM_ID;
    LV_DESC VARCHAR2(300);
    LV_TO_ORG VARCHAR2(100);
    LV_FROM_ORG VARCHAR2(100);
  BEGIN
    IF SOURCE_TYPE = 'DISTRIBUTION' THEN
      OPEN CUR_DESCRIPTION;
      FETCH CUR_DESCRIPTION
       INTO LV_FROM_ORG,LV_TO_ORG;
      CLOSE CUR_DESCRIPTION;
      LV_DESC := 'Service Distribute In' ||  'FROM' ||  LV_FROM_ORG ||  'TO' ||  LV_TO_ORG;
    ELSIF SOURCE_TYPE = 'MANUAL' THEN
      LV_DESC := 'MANUAL';
    ELSIF SOURCE_TYPE = 'AP' THEN
      OPEN CUR_ITEM_DESC;
      FETCH CUR_ITEM_DESC
       INTO LV_DESC;
      CLOSE CUR_ITEM_DESC;
    END IF;
    RETURN LV_DESC;
  END CF_DESCRIPTIONFORMULA;

END JA_JAINRGCR_XMLP_PKG;



/