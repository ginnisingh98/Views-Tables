--------------------------------------------------------
--  DDL for Package Body AR_ARBRATBR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_ARBRATBR_XMLP_PKG" AS
/* $Header: ARBRATBRB.pls 120.1 2008/01/07 14:48:41 abraghun noship $ */
  FUNCTION CF_MATURITY_DATEFORMULA(MATURITY_DATE IN DATE) RETURN CHAR IS
  BEGIN
    RETURN (FND_DATE.DATE_TO_CHARDATE(MATURITY_DATE));
  END CF_MATURITY_DATEFORMULA;

  FUNCTION CF_SYSDATEFORMULA RETURN CHAR IS
  BEGIN
    RETURN (FND_DATE.DATE_TO_CHARDT(SYSDATE));
  END CF_SYSDATEFORMULA;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    DECLARE
      ERRBUF VARCHAR2(132);
    BEGIN
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
      SELECT
        C.PRECISION,
        C.CURRENCY_CODE,
        SOB.NAME
      INTO CP_PRECISION,CP_FUNC_CURR,CP_SOB
      FROM
        AP_SYSTEM_PARAMETERS ASP,
        GL_SETS_OF_BOOKS SOB,
        FND_CURRENCIES_VL C
      WHERE ASP.SET_OF_BOOKS_ID = SOB.SET_OF_BOOKS_ID
        AND ASP.BASE_CURRENCY_CODE = C.CURRENCY_CODE;
      IF P_VERSION = 'S' THEN
        CP_VERSION := 'Summary';
      ELSE
        CP_VERSION := 'Detail';
      END IF;
      IF P_REQUEST_ID IS NULL THEN
        SELECT
          MAX(REQUEST_ID)
        INTO CP_REQUEST_ID
        FROM
          AR_BR_TRX_BATCH_RPT
        WHERE BATCH_ID = P_BATCH;
      ELSE
        CP_REQUEST_ID := P_REQUEST_ID;
      END IF;
      BEGIN
        SELECT
          RAB.NAME SC_BATCH_NAME,
          ARL_STATUS.MEANING SC_BATCH_STATUS,
          SLC.DUE_DATE_LOW SC_DUE_DATE_LOW,
          SLC.DUE_DATE_HIGH SC_DUE_DATE_HIGH,
          SLC.TRX_DATE_LOW SC_TRX_DATE_LOW,
          SLC.TRX_DATE_HIGH SC_TRX_DATE_HIGH,
          SLC.TRX_NUMBER_LOW SC_TRX_NUMBER_LOW,
          SLC.TRX_NUMBER_HIGH SC_TRX_NUMBER_HIGH,
          ARM.NAME SC_PAYMENT_METHOD,
          RAB.ISSUE_DATE SC_ISSUE_DATE,
          ARL_CLASS.MEANING SC_CUSTOMER_CLASS,
          ARL_CATEGORY.MEANING SC_CUSTOMER_CATEGORY,
          SUBSTRB(PARTY.PARTY_NAME
                 ,1
                 ,50) SC_CUSTOMER_NAME,
          RAC.ACCOUNT_NUMBER SC_CUSTOMER_NUMBER,
          RAS.LOCATION SC_LOCATION,
          APB.BANK_NAME SC_BANK_NAME,
          TYP.NAME SC_TRX_TYPE,
          RAB.CURRENCY_CODE SC_CURRENCY_CODE,
          BSR.NAME SOURCE
        INTO CP_BATCH_NAME,CP_BATCH_STATUS,CP_DUE_DATE_LOW,CP_DUE_DATE_HIGH,
	CP_TRX_DATE_LOW,CP_TRX_DATE_HIGH,CP_TRX_NUMBER_LOW,CP_TRX_NUMBER_HIGH,
	CP_PAYMENT_METHOD,CP_ISSUE_DATE,CP_CUSTOMER_CLASS,CP_CUSTOMER_CATEGORY,
	CP_CUSTOMER_NAME,CP_CUSTOMER_NUMBER,CP_LOCATION,CP_BANK_NAME,CP_TRX_TYPE,CP_CURRENCY_CODE,CP_SOURCE
        FROM
          AR_SELECTION_CRITERIA SLC,
          RA_BATCHES RAB,
          AR_RECEIPT_METHODS ARM,
          AR_LOOKUPS ARL_STATUS,
          AR_LOOKUPS ARL_CLASS,
          AR_LOOKUPS ARL_CATEGORY,
          HZ_CUST_ACCOUNTS RAC,
          HZ_PARTIES PARTY,
          HZ_CUST_SITE_USES RAS,
          CE_BANK_BRANCHES_V APB,
          RA_CUST_TRX_TYPES TYP,
          RA_BATCH_SOURCES BSR
        WHERE SLC.SELECTION_CRITERIA_ID = rab.selection_criteria_id (+)
          AND SLC.RECEIPT_METHOD_ID = arm.receipt_method_id (+)
          AND RAB.BATCH_PROCESS_STATUS = arl_status.lookup_code (+)
          AND arl_status.lookup_type (+) = 'RA_BATCH_PROCESS_STATUS'
          AND SLC.CUSTOMER_CLASS_CODE = arl_class.lookup_code (+)
          AND arl_class.lookup_type (+) = 'CUSTOMER CLASS'
          AND SLC.CUSTOMER_CATEGORY_CODE = arl_category.lookup_code (+)
          AND arl_category.lookup_type (+) = 'CUSTOMER_CATEGORY'
          AND SLC.CUSTOMER_ID = rac.cust_account_id (+)
          AND RAC.PARTY_ID = party.party_id (+)
          AND SLC.SITE_USE_ID = ras.site_use_id (+)
          AND SLC.BANK_BRANCH_ID = apb.branch_party_id (+)
          AND SLC.CUST_TRX_TYPE_ID = typ.cust_trx_type_id (+)
          AND RAB.BATCH_SOURCE_ID = bsr.batch_source_id (+)
          AND RAB.BATCH_ID = (
          SELECT
            MAX(RPT.BATCH_ID)
          FROM
            AR_BR_TRX_BATCH_RPT RPT
          WHERE RPT.REQUEST_ID = CP_REQUEST_ID );
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
      END;
    END;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION CF_TRX_DATEFORMULA(TRX_DATE IN DATE) RETURN CHAR IS
  BEGIN
    RETURN (FND_DATE.DATE_TO_CHARDATE(TRX_DATE));
  END CF_TRX_DATEFORMULA;

  FUNCTION CF_FUNC_AMT_ASSIGNEDFORMULA(EXCHANGE_RATE IN NUMBER
                                      ,AMOUNT_ASSIGNED IN NUMBER) RETURN NUMBER IS
  BEGIN
    DECLARE
      L_FUNC_AMT_ASSIGNED NUMBER;
      L_NEW_ADR NUMBER;
      L_NEW_AADR NUMBER;
      L_ADR NUMBER := 0;
      L_AADR NUMBER := 0;
    BEGIN
      ARP_UTIL.CALC_ACCTD_AMOUNT(NULL
                                ,NULL
                                ,NULL
                                ,EXCHANGE_RATE
                                ,'+'
                                ,L_ADR
                                ,L_AADR
                                ,AMOUNT_ASSIGNED
                                ,L_NEW_ADR
                                ,L_NEW_AADR
                                ,L_FUNC_AMT_ASSIGNED);
      RETURN (L_FUNC_AMT_ASSIGNED);
    END;
  END CF_FUNC_AMT_ASSIGNEDFORMULA;

  FUNCTION CF_REPORT_TITLEFORMULA RETURN CHAR IS
  BEGIN
    DECLARE
      L_REPORT_NAME VARCHAR2(80);
    BEGIN
      SELECT
        SUBSTR(CP.USER_CONCURRENT_PROGRAM_NAME
              ,1
              ,80)
      INTO L_REPORT_NAME
      FROM
        FND_CONCURRENT_PROGRAMS_VL CP,
        FND_APPLICATION_VL AP
      WHERE CP.CONCURRENT_PROGRAM_NAME = 'ARBRATBR'
        AND AP.APPLICATION_SHORT_NAME = 'AR'
        AND CP.APPLICATION_ID = AP.APPLICATION_ID;
      RETURN (L_REPORT_NAME);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN ('Automatic Transactions Batch Report');
      WHEN TOO_MANY_ROWS THEN
        RETURN ('Automatic Transactions Batch Report');
    END;
    RETURN NULL;
  END CF_REPORT_TITLEFORMULA;

  FUNCTION CF_DUE_DATE_LOWFORMULA RETURN CHAR IS
  BEGIN
    RETURN (FND_DATE.DATE_TO_CHARDATE(CP_DUE_DATE_LOW));
  END CF_DUE_DATE_LOWFORMULA;

  FUNCTION CF_DUE_DATE_HIGHFORMULA RETURN CHAR IS
  BEGIN
    RETURN (FND_DATE.DATE_TO_CHARDATE(CP_DUE_DATE_HIGH));
  END CF_DUE_DATE_HIGHFORMULA;

  FUNCTION CF_TRX_DATE_LOWFORMULA RETURN CHAR IS
  BEGIN
    RETURN (FND_DATE.DATE_TO_CHARDATE(CP_TRX_DATE_LOW));
  END CF_TRX_DATE_LOWFORMULA;

  FUNCTION CF_TRX_DATE_HIGHFORMULA RETURN CHAR IS
  BEGIN
    RETURN (FND_DATE.DATE_TO_CHARDATE(CP_TRX_DATE_HIGH));
  END CF_TRX_DATE_HIGHFORMULA;

  FUNCTION CF_ISSUE_DATEFORMULA RETURN CHAR IS
  BEGIN
    RETURN (FND_DATE.DATE_TO_CHARDATE(CP_ISSUE_DATE));
  END CF_ISSUE_DATEFORMULA;

  FUNCTION CP_SOB_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_SOB;
  END CP_SOB_P;

  FUNCTION CP_PRECISION_P RETURN NUMBER IS
  BEGIN
    RETURN CP_PRECISION;
  END CP_PRECISION_P;

  FUNCTION CP_FUNC_CURR_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_FUNC_CURR;
  END CP_FUNC_CURR_P;

  FUNCTION CP_VERSION_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_VERSION;
  END CP_VERSION_P;

  FUNCTION CP_REQUEST_ID_P RETURN NUMBER IS
  BEGIN
    RETURN CP_REQUEST_ID;
  END CP_REQUEST_ID_P;

  FUNCTION CP_BATCH_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_BATCH_NAME;
  END CP_BATCH_NAME_P;

  FUNCTION CP_BATCH_STATUS_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_BATCH_STATUS;
  END CP_BATCH_STATUS_P;

  FUNCTION CP_DUE_DATE_LOW_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_DUE_DATE_LOW;
  END CP_DUE_DATE_LOW_P;

  FUNCTION CP_DUE_DATE_HIGH_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_DUE_DATE_HIGH;
  END CP_DUE_DATE_HIGH_P;

  FUNCTION CP_TRX_DATE_LOW_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_TRX_DATE_LOW;
  END CP_TRX_DATE_LOW_P;

  FUNCTION CP_TRX_DATE_HIGH_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_TRX_DATE_HIGH;
  END CP_TRX_DATE_HIGH_P;

  FUNCTION CP_TRX_NUMBER_LOW_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_TRX_NUMBER_LOW;
  END CP_TRX_NUMBER_LOW_P;

  FUNCTION CP_TRX_NUMBER_HIGH_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_TRX_NUMBER_HIGH;
  END CP_TRX_NUMBER_HIGH_P;

  FUNCTION CP_PAYMENT_METHOD_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_PAYMENT_METHOD;
  END CP_PAYMENT_METHOD_P;

  FUNCTION CP_ISSUE_DATE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_ISSUE_DATE;
  END CP_ISSUE_DATE_P;

  FUNCTION CP_CUSTOMER_CLASS_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_CUSTOMER_CLASS;
  END CP_CUSTOMER_CLASS_P;

  FUNCTION CP_CUSTOMER_CATEGORY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_CUSTOMER_CATEGORY;
  END CP_CUSTOMER_CATEGORY_P;

  FUNCTION CP_CUSTOMER_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_CUSTOMER_NAME;
  END CP_CUSTOMER_NAME_P;

  FUNCTION CP_CUSTOMER_NUMBER_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_CUSTOMER_NUMBER;
  END CP_CUSTOMER_NUMBER_P;

  FUNCTION CP_LOCATION_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_LOCATION;
  END CP_LOCATION_P;

  FUNCTION CP_BANK_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_BANK_NAME;
  END CP_BANK_NAME_P;

  FUNCTION CP_TRX_TYPE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_TRX_TYPE;
  END CP_TRX_TYPE_P;

  FUNCTION CP_CURRENCY_CODE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_CURRENCY_CODE;
  END CP_CURRENCY_CODE_P;

  FUNCTION CP_SOURCE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_SOURCE;
  END CP_SOURCE_P;

END AR_ARBRATBR_XMLP_PKG;



/
