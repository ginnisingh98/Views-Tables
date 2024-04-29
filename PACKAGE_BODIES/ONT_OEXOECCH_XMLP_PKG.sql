--------------------------------------------------------
--  DDL for Package Body ONT_OEXOECCH_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_OEXOECCH_XMLP_PKG" AS
/* $Header: OEXOECCHB.pls 120.1 2007/12/25 07:13:51 npannamp noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      BEGIN
        P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
        /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
      EXCEPTION
        WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
          /*SRW.MESSAGE(1000
                     ,'Failed in BEFORE REPORT trigger')*/NULL;
          RETURN (FALSE);
      END;
      DECLARE
        L_COMPANY_NAME VARCHAR2(100);
        L_FUNCTIONAL_CURRENCY VARCHAR2(15);
      BEGIN
        SELECT
          SOB.NAME,
          SOB.CURRENCY_CODE
        INTO L_COMPANY_NAME,L_FUNCTIONAL_CURRENCY
        FROM
          GL_SETS_OF_BOOKS SOB,
          FND_CURRENCIES CUR
        WHERE SOB.SET_OF_BOOKS_ID = P_SOB_ID
          AND SOB.CURRENCY_CODE = CUR.CURRENCY_CODE;
        RP_COMPANY_NAME := L_COMPANY_NAME;
        RP_FUNCTIONAL_CURRENCY := L_FUNCTIONAL_CURRENCY;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
      END;
      BEGIN
        /*SRW.REFERENCE(P_VAT_PROFILE)*/NULL;
        RP_VAT_PROFILE := FND_PROFILE.VALUE(':P_VAT_PROFILE');
      EXCEPTION
        WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
          /*SRW.MESSAGE(2000
                     ,'Failed in BEFORE REPORT trigger. FND GETPROFILE - VAT USER_EXIT')*/NULL;
      END;
      DECLARE
        L_REPORT_NAME VARCHAR2(240);
      BEGIN
        SELECT
          CP.USER_CONCURRENT_PROGRAM_NAME
        INTO L_REPORT_NAME
        FROM
          FND_CONCURRENT_PROGRAMS_VL CP,
          FND_CONCURRENT_REQUESTS CR
        WHERE CR.REQUEST_ID = P_CONC_REQUEST_ID
          AND CP.APPLICATION_ID = CR.PROGRAM_APPLICATION_ID
          AND CP.CONCURRENT_PROGRAM_ID = CR.CONCURRENT_PROGRAM_ID;
        RP_REPORT_NAME := L_REPORT_NAME;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RP_REPORT_NAME := 'Orders on Credit Hold';
      END;
      DECLARE
        L_DATE_HOLD_APPLIED_LOW VARCHAR2(50);
        L_DATE_HOLD_APPLIED_HIGH VARCHAR2(50);
      BEGIN
        IF (P_DATE_HOLD_APPLIED_LOW IS NULL) AND (P_DATE_HOLD_APPLIED_HIGH IS NULL) THEN
          NULL;
        ELSE
          IF P_DATE_HOLD_APPLIED_LOW IS NULL THEN
            L_DATE_HOLD_APPLIED_LOW := '   ';
          ELSE
            L_DATE_HOLD_APPLIED_LOW := SUBSTR(TO_CHAR(P_DATE_HOLD_APPLIED_LOW
                                                     ,'DD-MON-YYYY')
                                             ,1
                                             ,18);
          END IF;
          IF P_DATE_HOLD_APPLIED_HIGH IS NULL THEN
            L_DATE_HOLD_APPLIED_HIGH := '   ';
          ELSE
            L_DATE_HOLD_APPLIED_HIGH := SUBSTR(TO_CHAR(P_DATE_HOLD_APPLIED_HIGH
                                                      ,'DD-MON-YYYY')
                                              ,1
                                              ,18);
          END IF;
          RP_DATE_HOLD_APPLIED_RANGE := 'From ' || L_DATE_HOLD_APPLIED_LOW || ' To ' || L_DATE_HOLD_APPLIED_HIGH;
        END IF;
      END;
      DECLARE
        L_SHIP VARCHAR2(80);
        L_LOOKUP_TYPE VARCHAR2(80);
        L_LOOKUP_CODE VARCHAR2(80);
      BEGIN
        L_LOOKUP_TYPE := 'CREDIT_RULE_TYPES';
        L_LOOKUP_CODE := 'SHIPPING';
        SELECT
          MEANING
        INTO L_SHIP
        FROM
          OE_LOOKUPS
        WHERE LOOKUP_TYPE = L_LOOKUP_TYPE
          AND LOOKUP_CODE = L_LOOKUP_CODE;
        RP_SHIP := L_SHIP;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RP_SHIP := 'Shipping';
      END;
      DECLARE
        L_ORD VARCHAR2(80);
        L_LOOKUP_TYPE VARCHAR2(80);
        L_LOOKUP_CODE VARCHAR2(80);
      BEGIN
        L_LOOKUP_TYPE := 'CREDIT_RULE_TYPES';
        L_LOOKUP_CODE := 'ORDERING';
        SELECT
          MEANING
        INTO L_ORD
        FROM
          OE_LOOKUPS
        WHERE LOOKUP_TYPE = L_LOOKUP_TYPE
          AND LOOKUP_CODE = L_LOOKUP_CODE;
        RP_ORDER := L_ORD;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RP_ORDER := 'Ordering';
      END;
      BEGIN
        RP_CURR_PROFILE := FND_PROFILE.VALUE('ONT_UNIT_PRICE_PRECISION_TYPE');
      EXCEPTION
        WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
          /*SRW.MESSAGE(3000
                     ,'Failed in BEFORE REPORT Trigger FND GETPROFILE USER_EXIT')*/NULL;
      END;
      DECLARE
        L_PICK VARCHAR2(80);
        L_LOOKUP_TYPE VARCHAR2(80);
        L_LOOKUP_CODE VARCHAR2(80);
      BEGIN
        L_LOOKUP_TYPE := 'CREDIT_RULE_TYPES';
        L_LOOKUP_CODE := 'PICKING';
        SELECT
          MEANING
        INTO L_PICK
        FROM
          OE_LOOKUPS
        WHERE LOOKUP_TYPE = L_LOOKUP_TYPE
          AND LOOKUP_CODE = L_LOOKUP_CODE;
        RP_PICK := L_PICK;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RP_PICK := 'Picking';
      END;
      DECLARE
        L_PACK VARCHAR2(80);
        L_LOOKUP_TYPE VARCHAR2(80);
        L_LOOKUP_CODE VARCHAR2(80);
      BEGIN
        L_LOOKUP_TYPE := 'CREDIT_RULE_TYPES';
        L_LOOKUP_CODE := 'PACKING';
        SELECT
          MEANING
        INTO L_PACK
        FROM
          OE_LOOKUPS
        WHERE LOOKUP_TYPE = L_LOOKUP_TYPE
          AND LOOKUP_CODE = L_LOOKUP_CODE;
        RP_PACK := L_PACK;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RP_PACK := 'Packing';
      END;
    END;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(1
                   ,'Failed in AFTER REPORT TRIGGER')*/NULL;
        RETURN (FALSE);
    END;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    BEGIN
      IF P_CUSTOMER_NAME IS NOT NULL THEN
        LP_CUSTOMER_NAME := ' and party.party_name = :p_customer_name';
      END IF;
      IF P_CUSTOMER_NUMBER IS NOT NULL THEN
        LP_CUSTOMER_NUMBER := ' and cust_acct.account_number = :p_customer_number';
      END IF;
      IF P_ORDER_NUMBER IS NOT NULL THEN
        LP_ORDER_NUMBER := ' and h.order_number = :p_order_number';
      END IF;
      IF P_CURRENCY_CODE IS NOT NULL THEN
        LP_CURRENCY_CODE := ' and h.transactional_curr_code = :p_currency_code';
      END IF;
      IF (P_DATE_HOLD_APPLIED_LOW IS NOT NULL) AND (P_DATE_HOLD_APPLIED_HIGH IS NOT NULL) THEN
        LP_DATE_HOLD_APPLIED := 'and  (trunc(oh.creation_date)  between :p_date_hold_applied_low
                                			and :p_date_hold_applied_high) ';
      ELSIF (P_DATE_HOLD_APPLIED_LOW IS NOT NULL) THEN
        LP_DATE_HOLD_APPLIED := 'and trunc(oh.creation_date)  >= :p_date_hold_applied_low ';
      ELSIF (P_DATE_HOLD_APPLIED_HIGH IS NOT NULL) THEN
        LP_DATE_HOLD_APPLIED := 'and trunc(oh.creation_date)  <= :p_date_hold_applied_high ';
      END IF;
      IF P_ORDER_TYPE IS NOT NULL THEN
        LP_ORDER_TYPE := ' and ot.transaction_type_id = :p_order_type';
        SELECT
          OEOT.NAME
        INTO L_ORDER_TYPE
        FROM
          OE_TRANSACTION_TYPES_TL OEOT
        WHERE OEOT.TRANSACTION_TYPE_ID = P_ORDER_TYPE
          AND OEOT.LANGUAGE = USERENV('LANG');
      END IF;
    END;
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION C_COMPUTE_AMOUNTSFORMULA(SITE_USE_ID IN NUMBER
                                   ,CURRENCY1 IN VARCHAR2
                                   ,CUSTOMER_ID IN NUMBER
                                   ,ENTRY_OPEN_AR_DAYS IN NUMBER
                                   ,ENTRY_OPEN_AR_FLAG IN VARCHAR2
                                   ,SHIP_OPEN_AR_DAYS IN NUMBER
                                   ,SHIP_OPEN_AR_FLAG IN VARCHAR2
                                   ,ENTRY_UNINVOICED_FLAG IN VARCHAR2
                                   ,ENTRY_ON_HOLD_FLAG IN VARCHAR2
                                   ,SHIP_UNINVOICED_FLAG IN VARCHAR2
                                   ,SHIP_ON_HOLD_FLAG IN VARCHAR2
                                   ,ENTRY_SHIPPING_INTERVAL IN NUMBER
                                   ,SHIP_SHIPPING_INTERVAL IN NUMBER
                                   ,ENTRY_RULE_ID IN NUMBER
                                   ,SHIP_RULE_ID IN NUMBER
                                   ,PICK_OPEN_AR_DAYS IN NUMBER
                                   ,PICK_OPEN_AR_FLAG IN VARCHAR2
                                   ,PICK_UNINVOICED_FLAG IN VARCHAR2
                                   ,PICK_ON_HOLD_FLAG IN VARCHAR2
                                   ,PICK_SHIPPING_INTERVAL IN NUMBER
                                   ,PICK_RULE_ID IN NUMBER
                                   ,PACK_OPEN_AR_DAYS IN NUMBER
                                   ,PACK_OPEN_AR_FLAG IN VARCHAR2
                                   ,PACK_UNINVOICED_FLAG IN VARCHAR2
                                   ,PACK_ON_HOLD_FLAG IN VARCHAR2
                                   ,PACK_SHIPPING_INTERVAL IN NUMBER
                                   ,PACK_RULE_ID IN NUMBER) RETURN NUMBER IS
  BEGIN
    DECLARE
      L_ORDER_LIMIT NUMBER(17,2);
      L_TOTAL_LIMIT NUMBER(17,2);
      L_REC_BAL_CREDIT NUMBER(17,2);
      L_REC_BAL_SHIP NUMBER(17,2);
      L_UNINV_ORD_CREDIT NUMBER(17,2);
      L_UNINV_ORD_SHIP NUMBER(17,2);
      L_TOTAL1_CREDIT NUMBER(17,2);
      L_TOTAL3_CREDIT NUMBER(17,2);
      L_TOTAL1_SHIP NUMBER(17,2);
      L_TOTAL3_SHIP NUMBER(17,2);
      L_INCLUDE_RISK_FLAG1 VARCHAR2(1);
      L_INCLUDE_RISK_FLAG2 VARCHAR2(1);
      DEBUG NUMBER;
      L_INCLUDE_RISK_FLAG3 VARCHAR2(1);
      L_INCLUDE_RISK_FLAG4 VARCHAR2(1);
      L_REC_BAL_PICK NUMBER(17,2);
      L_REC_BAL_PACK NUMBER(17,2);
      L_UNINV_ORD_PICK NUMBER(17,2);
      L_UNINV_ORD_PACK NUMBER(17,2);
      L_TOTAL1_PICK NUMBER(17,2);
      L_TOTAL3_PICK NUMBER(17,2);
      L_TOTAL1_PACK NUMBER(17,2);
      L_TOTAL3_PACK NUMBER(17,2);
    BEGIN
      /*SRW.REFERENCE(SITE_USE_ID)*/NULL;
      /*SRW.REFERENCE(CURRENCY1)*/NULL;
      /*SRW.REFERENCE(CUSTOMER_ID)*/NULL;
      /*SRW.REFERENCE(ENTRY_OPEN_AR_DAYS)*/NULL;
      /*SRW.REFERENCE(ENTRY_OPEN_AR_FLAG)*/NULL;
      /*SRW.REFERENCE(SHIP_OPEN_AR_DAYS)*/NULL;
      /*SRW.REFERENCE(SHIP_OPEN_AR_FLAG)*/NULL;
      /*SRW.REFERENCE(ENTRY_UNINVOICED_FLAG)*/NULL;
      /*SRW.REFERENCE(ENTRY_ON_HOLD_FLAG)*/NULL;
      /*SRW.REFERENCE(SHIP_UNINVOICED_FLAG)*/NULL;
      /*SRW.REFERENCE(SHIP_ON_HOLD_FLAG)*/NULL;
      /*SRW.REFERENCE(ENTRY_SHIPPING_INTERVAL)*/NULL;
      /*SRW.REFERENCE(SHIP_SHIPPING_INTERVAL)*/NULL;
      /*SRW.REFERENCE(ENTRY_RULE_ID)*/NULL;
      /*SRW.REFERENCE(SHIP_RULE_ID)*/NULL;
      /*SRW.REFERENCE(RP_VAT_PROFILE)*/NULL;
      /*SRW.REFERENCE(PICK_OPEN_AR_DAYS)*/NULL;
      /*SRW.REFERENCE(PICK_OPEN_AR_FLAG)*/NULL;
      /*SRW.REFERENCE(PICK_UNINVOICED_FLAG)*/NULL;
      /*SRW.REFERENCE(PICK_ON_HOLD_FLAG)*/NULL;
      /*SRW.REFERENCE(PICK_SHIPPING_INTERVAL)*/NULL;
      /*SRW.REFERENCE(PICK_RULE_ID)*/NULL;
      /*SRW.REFERENCE(PACK_OPEN_AR_DAYS)*/NULL;
      /*SRW.REFERENCE(PACK_OPEN_AR_FLAG)*/NULL;
      /*SRW.REFERENCE(PACK_UNINVOICED_FLAG)*/NULL;
      /*SRW.REFERENCE(PACK_ON_HOLD_FLAG)*/NULL;
      /*SRW.REFERENCE(PACK_SHIPPING_INTERVAL)*/NULL;
      /*SRW.REFERENCE(PACK_RULE_ID)*/NULL;
      L_ORDER_LIMIT := 0;
      L_TOTAL_LIMIT := 0;
      L_REC_BAL_CREDIT := 0;
      L_REC_BAL_SHIP := 0;
      L_UNINV_ORD_CREDIT := 0;
      L_UNINV_ORD_SHIP := 0;
      L_TOTAL1_CREDIT := 0;
      L_TOTAL3_CREDIT := 0;
      L_TOTAL1_SHIP := 0;
      L_TOTAL3_SHIP := 0;
      L_INCLUDE_RISK_FLAG1 := 'N';
      L_INCLUDE_RISK_FLAG2 := 'N';
      C_ORDER_LIMIT := 0;
      C_TOT_ORDER_LIMIT := 0;
      C_REC_BAL_CREDIT := 0;
      C_REC_BAL_SHIP := 0;
      C_UNINV_ORD_CREDIT := 0;
      C_UNINV_ORD_SHIP := 0;
      L_INCLUDE_RISK_FLAG3 := 'N';
      L_INCLUDE_RISK_FLAG4 := 'N';
      L_REC_BAL_PICK := 0;
      L_REC_BAL_PACK := 0;
      L_UNINV_ORD_PICK := 0;
      L_UNINV_ORD_PACK := 0;
      L_TOTAL1_PICK := 0;
      L_TOTAL3_PICK := 0;
      L_TOTAL1_PACK := 0;
      L_TOTAL3_PACK := 0;
      C_REC_BAL_PICK := 0;
      C_REC_BAL_PACK := 0;
      C_UNINV_ORD_PICK := 0;
      C_UNINV_ORD_PACK := 0;
      IF SITE_USE_ID <> 0 THEN
        DEBUG := 1;
        SELECT
          NVL(SUM(NVL(CPA.OVERALL_CREDIT_LIMIT
                     ,-1) * (100 + CP.TOLERANCE) / 100)
             ,-1),
          NVL(SUM(NVL(CPA.TRX_CREDIT_LIMIT
                     ,-1) * (100 + CP.TOLERANCE) / 100)
             ,-1)
        INTO L_TOTAL_LIMIT,L_ORDER_LIMIT
        FROM
          HZ_CUSTOMER_PROFILES CP,
          HZ_CUST_PROFILE_AMTS CPA
        WHERE CP.SITE_USE_ID = C_COMPUTE_AMOUNTSFORMULA.SITE_USE_ID
          AND CP.CUST_ACCOUNT_PROFILE_ID = CPA.CUST_ACCOUNT_PROFILE_ID
          AND CPA.CURRENCY_CODE = CURRENCY1;
      ELSE
        DEBUG := 2;
        SELECT
          NVL(SUM(NVL(CPA.OVERALL_CREDIT_LIMIT
                     ,-1) * (100 + CP.TOLERANCE) / 100)
             ,-1),
          NVL(SUM(NVL(CPA.TRX_CREDIT_LIMIT
                     ,-1) * (100 + CP.TOLERANCE) / 100)
             ,-1)
        INTO L_TOTAL_LIMIT,L_ORDER_LIMIT
        FROM
          HZ_CUSTOMER_PROFILES CP,
          HZ_CUST_PROFILE_AMTS CPA
        WHERE CP.CUST_ACCOUNT_ID = CUSTOMER_ID
          AND CP.CUST_ACCOUNT_PROFILE_ID = CPA.CUST_ACCOUNT_PROFILE_ID
          AND CPA.CURRENCY_CODE = CURRENCY1
          AND CP.SITE_USE_ID IS NULL;
      END IF;
      C_ORDER_LIMIT := L_ORDER_LIMIT;
      C_TOT_ORDER_LIMIT := L_TOTAL_LIMIT;
      IF RP_VAT_PROFILE IS NOT NULL THEN
        IF ENTRY_RULE_ID <> -1 THEN
          DEBUG := 3;
          SELECT
            INCLUDE_PAYMENTS_AT_RISK_FLAG
          INTO L_INCLUDE_RISK_FLAG1
          FROM
            OE_CREDIT_CHECK_RULES
          WHERE CREDIT_CHECK_RULE_ID = ENTRY_RULE_ID;
        END IF;
        IF SHIP_RULE_ID <> -1 THEN
          DEBUG := 4;
          SELECT
            INCLUDE_PAYMENTS_AT_RISK_FLAG
          INTO L_INCLUDE_RISK_FLAG2
          FROM
            OE_CREDIT_CHECK_RULES
          WHERE CREDIT_CHECK_RULE_ID = SHIP_RULE_ID;
        END IF;
        IF PICK_RULE_ID <> -1 AND PICK_RULE_ID IS NOT NULL THEN
          DEBUG := 45;
          SELECT
            INCLUDE_PAYMENTS_AT_RISK_FLAG
          INTO L_INCLUDE_RISK_FLAG3
          FROM
            OE_CREDIT_CHECK_RULES
          WHERE CREDIT_CHECK_RULE_ID = PICK_RULE_ID;
        END IF;
        IF PACK_RULE_ID <> -1 AND PACK_RULE_ID IS NOT NULL THEN
          DEBUG := 46;
          SELECT
            INCLUDE_PAYMENTS_AT_RISK_FLAG
          INTO L_INCLUDE_RISK_FLAG4
          FROM
            OE_CREDIT_CHECK_RULES
          WHERE CREDIT_CHECK_RULE_ID = PACK_RULE_ID;
        END IF;
      END IF;
      IF SITE_USE_ID = 0 THEN
        IF ENTRY_OPEN_AR_FLAG = 'Y' THEN
          IF ENTRY_OPEN_AR_DAYS IS NULL THEN
            DEBUG := 5;
            SELECT
              NVL(SUM(AMOUNT_DUE_REMAINING)
                 ,0)
            INTO L_REC_BAL_CREDIT
            FROM
              AR_PAYMENT_SCHEDULES
            WHERE CUSTOMER_ID = CUSTOMER_ID
              AND INVOICE_CURRENCY_CODE = CURRENCY1
              AND NVL(RECEIPT_CONFIRMED_FLAG
               ,'Y') = 'Y';
            IF L_INCLUDE_RISK_FLAG1 = 'Y' THEN
              DEBUG := 6;
              SELECT
                NVL(SUM(CRH.AMOUNT)
                   ,0) + L_REC_BAL_CREDIT
              INTO L_REC_BAL_CREDIT
              FROM
                AR_CASH_RECEIPT_HISTORY CRH,
                AR_CASH_RECEIPTS CR
              WHERE CRH.CASH_RECEIPT_ID = CR.CASH_RECEIPT_ID
                AND NVL(CR.CONFIRMED_FLAG
                 ,'Y') = 'Y'
                AND CRH.CURRENT_RECORD_FLAG = 'Y'
                AND CRH.STATUS <> DECODE(CRH.FACTOR_FLAG
                    ,'Y'
                    ,'RISK_ELIMINATED'
                    ,'CLEARED')
                AND CRH.STATUS <> 'REVERSED'
                AND CR.CURRENCY_CODE = CURRENCY1
                AND CR.PAY_FROM_CUSTOMER = CUSTOMER_ID;
            END IF;
          ELSE
            DEBUG := 7;
            SELECT
              NVL(SUM(AMOUNT_DUE_REMAINING)
                 ,0)
            INTO L_REC_BAL_CREDIT
            FROM
              AR_PAYMENT_SCHEDULES
            WHERE CUSTOMER_ID = CUSTOMER_ID
              AND INVOICE_CURRENCY_CODE = CURRENCY1
              AND NVL(RECEIPT_CONFIRMED_FLAG
               ,'Y') = 'Y'
              AND SYSDATE - TRX_DATE > ENTRY_OPEN_AR_DAYS;
            IF L_INCLUDE_RISK_FLAG1 = 'Y' THEN
              DEBUG := 8;
              SELECT
                NVL(SUM(CRH.AMOUNT)
                   ,0) + L_REC_BAL_CREDIT
              INTO L_REC_BAL_CREDIT
              FROM
                AR_CASH_RECEIPT_HISTORY CRH,
                AR_CASH_RECEIPTS CR
              WHERE CRH.CASH_RECEIPT_ID = CR.CASH_RECEIPT_ID
                AND NVL(CR.CONFIRMED_FLAG
                 ,'Y') = 'Y'
                AND CRH.CURRENT_RECORD_FLAG = 'Y'
                AND CRH.STATUS <> DECODE(CRH.FACTOR_FLAG
                    ,'Y'
                    ,'RISK_ELIMINATED'
                    ,'CLEARED')
                AND CRH.STATUS <> 'REVERSED'
                AND CR.CURRENCY_CODE = CURRENCY1
                AND CR.PAY_FROM_CUSTOMER = CUSTOMER_ID
                AND SYSDATE - CR.RECEIPT_DATE > ENTRY_OPEN_AR_DAYS;
            END IF;
          END IF;
        ELSE
          DEBUG := 9;
          L_REC_BAL_CREDIT := 0;
        END IF;
      ELSE
        IF ENTRY_OPEN_AR_FLAG = 'Y' THEN
          IF ENTRY_OPEN_AR_DAYS IS NULL THEN
            DEBUG := 10;
            SELECT
              NVL(SUM(AMOUNT_DUE_REMAINING)
                 ,0)
            INTO L_REC_BAL_CREDIT
            FROM
              AR_PAYMENT_SCHEDULES
            WHERE CUSTOMER_SITE_USE_ID = C_COMPUTE_AMOUNTSFORMULA.SITE_USE_ID
              AND NVL(RECEIPT_CONFIRMED_FLAG
               ,'Y') = 'Y'
              AND INVOICE_CURRENCY_CODE = CURRENCY1;
            IF L_INCLUDE_RISK_FLAG1 = 'Y' THEN
              DEBUG := 11;
              SELECT
                NVL(SUM(CRH.AMOUNT)
                   ,0) + L_REC_BAL_CREDIT
              INTO L_REC_BAL_CREDIT
              FROM
                AR_CASH_RECEIPT_HISTORY CRH,
                AR_CASH_RECEIPTS CR
              WHERE CRH.CASH_RECEIPT_ID = CR.CASH_RECEIPT_ID
                AND NVL(CR.CONFIRMED_FLAG
                 ,'Y') = 'Y'
                AND CRH.CURRENT_RECORD_FLAG = 'Y'
                AND CRH.STATUS <> DECODE(CRH.FACTOR_FLAG
                    ,'Y'
                    ,'RISK_ELIMINATED'
                    ,'CLEARED')
                AND CRH.STATUS <> 'REVERSED'
                AND CR.CURRENCY_CODE = CURRENCY1
                AND CR.PAY_FROM_CUSTOMER = CUSTOMER_ID
                AND CR.CUSTOMER_SITE_USE_ID = C_COMPUTE_AMOUNTSFORMULA.SITE_USE_ID;
            END IF;
          ELSE
            DEBUG := 12;
            SELECT
              NVL(SUM(AMOUNT_DUE_REMAINING)
                 ,0)
            INTO L_REC_BAL_CREDIT
            FROM
              AR_PAYMENT_SCHEDULES
            WHERE CUSTOMER_SITE_USE_ID = C_COMPUTE_AMOUNTSFORMULA.SITE_USE_ID
              AND NVL(RECEIPT_CONFIRMED_FLAG
               ,'Y') = 'Y'
              AND INVOICE_CURRENCY_CODE = CURRENCY1
              AND SYSDATE - TRX_DATE > ENTRY_OPEN_AR_DAYS;
            IF L_INCLUDE_RISK_FLAG1 = 'Y' THEN
              DEBUG := 13;
              SELECT
                NVL(SUM(CRH.AMOUNT)
                   ,0) + L_REC_BAL_CREDIT
              INTO L_REC_BAL_CREDIT
              FROM
                AR_CASH_RECEIPT_HISTORY CRH,
                AR_CASH_RECEIPTS CR
              WHERE CRH.CASH_RECEIPT_ID = CR.CASH_RECEIPT_ID
                AND NVL(CR.CONFIRMED_FLAG
                 ,'Y') = 'Y'
                AND CRH.CURRENT_RECORD_FLAG = 'Y'
                AND CRH.STATUS <> DECODE(CRH.FACTOR_FLAG
                    ,'Y'
                    ,'RISK_ELIMINATED'
                    ,'CLEARED')
                AND CRH.STATUS <> 'REVERSED'
                AND CR.CURRENCY_CODE = CURRENCY1
                AND CR.CUSTOMER_SITE_USE_ID = C_COMPUTE_AMOUNTSFORMULA.SITE_USE_ID
                AND CR.PAY_FROM_CUSTOMER = CUSTOMER_ID
                AND SYSDATE - CR.RECEIPT_DATE > ENTRY_OPEN_AR_DAYS;
            END IF;
          END IF;
        ELSE
          DEBUG := 14;
          L_REC_BAL_CREDIT := 0;
        END IF;
      END IF;
      C_REC_BAL_CREDIT := L_REC_BAL_CREDIT;
      IF SITE_USE_ID = 0 THEN
        IF SHIP_OPEN_AR_FLAG = 'Y' THEN
          IF SHIP_OPEN_AR_DAYS IS NULL THEN
            DEBUG := 15;
            SELECT
              NVL(SUM(AMOUNT_DUE_REMAINING)
                 ,0)
            INTO L_REC_BAL_SHIP
            FROM
              AR_PAYMENT_SCHEDULES
            WHERE CUSTOMER_ID = CUSTOMER_ID
              AND INVOICE_CURRENCY_CODE = CURRENCY1
              AND NVL(RECEIPT_CONFIRMED_FLAG
               ,'Y') = 'Y';
            IF L_INCLUDE_RISK_FLAG2 = 'Y' THEN
              DEBUG := 16;
              SELECT
                NVL(SUM(CRH.AMOUNT)
                   ,0) + L_REC_BAL_SHIP
              INTO L_REC_BAL_SHIP
              FROM
                AR_CASH_RECEIPT_HISTORY CRH,
                AR_CASH_RECEIPTS CR
              WHERE CRH.CASH_RECEIPT_ID = CR.CASH_RECEIPT_ID
                AND NVL(CR.CONFIRMED_FLAG
                 ,'Y') = 'Y'
                AND CRH.CURRENT_RECORD_FLAG = 'Y'
                AND CRH.STATUS <> DECODE(CRH.FACTOR_FLAG
                    ,'Y'
                    ,'RISK_ELIMINATED'
                    ,'CLEARED')
                AND CRH.STATUS <> 'REVERSED'
                AND CR.CURRENCY_CODE = CURRENCY1
                AND CR.PAY_FROM_CUSTOMER = CUSTOMER_ID;
            END IF;
          ELSE
            DEBUG := 17;
            SELECT
              NVL(SUM(AMOUNT_DUE_REMAINING)
                 ,0)
            INTO L_REC_BAL_SHIP
            FROM
              AR_PAYMENT_SCHEDULES
            WHERE CUSTOMER_ID = CUSTOMER_ID
              AND INVOICE_CURRENCY_CODE = CURRENCY1
              AND NVL(RECEIPT_CONFIRMED_FLAG
               ,'Y') = 'Y'
              AND SYSDATE - TRX_DATE > SHIP_OPEN_AR_DAYS;
            IF L_INCLUDE_RISK_FLAG2 = 'Y' THEN
              DEBUG := 18;
              SELECT
                NVL(SUM(CRH.AMOUNT)
                   ,0) + L_REC_BAL_SHIP
              INTO L_REC_BAL_SHIP
              FROM
                AR_CASH_RECEIPT_HISTORY CRH,
                AR_CASH_RECEIPTS CR
              WHERE CRH.CASH_RECEIPT_ID = CR.CASH_RECEIPT_ID
                AND NVL(CR.CONFIRMED_FLAG
                 ,'Y') = 'Y'
                AND CRH.CURRENT_RECORD_FLAG = 'Y'
                AND CRH.STATUS <> DECODE(CRH.FACTOR_FLAG
                    ,'Y'
                    ,'RISK_ELIMINATED'
                    ,'CLEARED')
                AND CRH.STATUS <> 'REVERSED'
                AND CR.CURRENCY_CODE = CURRENCY1
                AND CR.PAY_FROM_CUSTOMER = CUSTOMER_ID
                AND SYSDATE - CR.RECEIPT_DATE > SHIP_OPEN_AR_DAYS;
            END IF;
          END IF;
        ELSE
          DEBUG := 19;
          L_REC_BAL_SHIP := 0;
        END IF;
      ELSE
        IF SHIP_OPEN_AR_FLAG = 'Y' THEN
          IF SHIP_OPEN_AR_DAYS IS NULL THEN
            DEBUG := 20;
            SELECT
              NVL(SUM(AMOUNT_DUE_REMAINING)
                 ,0)
            INTO L_REC_BAL_SHIP
            FROM
              AR_PAYMENT_SCHEDULES
            WHERE CUSTOMER_SITE_USE_ID = C_COMPUTE_AMOUNTSFORMULA.SITE_USE_ID
              AND NVL(RECEIPT_CONFIRMED_FLAG
               ,'Y') = 'Y'
              AND INVOICE_CURRENCY_CODE = CURRENCY1;
            IF L_INCLUDE_RISK_FLAG2 = 'Y' THEN
              DEBUG := 21;
              SELECT
                NVL(SUM(CRH.AMOUNT)
                   ,0) + L_REC_BAL_SHIP
              INTO L_REC_BAL_SHIP
              FROM
                AR_CASH_RECEIPT_HISTORY CRH,
                AR_CASH_RECEIPTS CR
              WHERE CRH.CASH_RECEIPT_ID = CR.CASH_RECEIPT_ID
                AND NVL(CR.CONFIRMED_FLAG
                 ,'Y') = 'Y'
                AND CRH.CURRENT_RECORD_FLAG = 'Y'
                AND CRH.STATUS <> DECODE(CRH.FACTOR_FLAG
                    ,'Y'
                    ,'RISK_ELIMINATED'
                    ,'CLEARED')
                AND CRH.STATUS <> 'REVERSED'
                AND CR.CURRENCY_CODE = CURRENCY1
                AND CR.PAY_FROM_CUSTOMER = CUSTOMER_ID
                AND CR.CUSTOMER_SITE_USE_ID = C_COMPUTE_AMOUNTSFORMULA.SITE_USE_ID;
            END IF;
          ELSE
            DEBUG := 22;
            SELECT
              NVL(SUM(AMOUNT_DUE_REMAINING)
                 ,0)
            INTO L_REC_BAL_SHIP
            FROM
              AR_PAYMENT_SCHEDULES
            WHERE CUSTOMER_SITE_USE_ID = C_COMPUTE_AMOUNTSFORMULA.SITE_USE_ID
              AND NVL(RECEIPT_CONFIRMED_FLAG
               ,'Y') = 'Y'
              AND INVOICE_CURRENCY_CODE = CURRENCY1
              AND SYSDATE - TRX_DATE > SHIP_OPEN_AR_DAYS;
            IF L_INCLUDE_RISK_FLAG2 = 'Y' THEN
              DEBUG := 23;
              SELECT
                NVL(SUM(CRH.AMOUNT)
                   ,0) + L_REC_BAL_SHIP
              INTO L_REC_BAL_SHIP
              FROM
                AR_CASH_RECEIPT_HISTORY CRH,
                AR_CASH_RECEIPTS CR
              WHERE CRH.CASH_RECEIPT_ID = CR.CASH_RECEIPT_ID
                AND NVL(CR.CONFIRMED_FLAG
                 ,'Y') = 'Y'
                AND CRH.CURRENT_RECORD_FLAG = 'Y'
                AND CRH.STATUS <> DECODE(CRH.FACTOR_FLAG
                    ,'Y'
                    ,'RISK_ELIMINATED'
                    ,'CLEARED')
                AND CRH.STATUS <> 'REVERSED'
                AND CR.CURRENCY_CODE = CURRENCY1
                AND CR.PAY_FROM_CUSTOMER = CUSTOMER_ID
                AND CR.CUSTOMER_SITE_USE_ID = C_COMPUTE_AMOUNTSFORMULA.SITE_USE_ID
                AND SYSDATE - CR.RECEIPT_DATE > SHIP_OPEN_AR_DAYS;
            END IF;
          END IF;
        ELSE
          DEBUG := 24;
          L_REC_BAL_SHIP := 0;
        END IF;
      END IF;
      C_REC_BAL_SHIP := L_REC_BAL_SHIP;
      IF SITE_USE_ID = 0 THEN
        IF ENTRY_UNINVOICED_FLAG = 'Y' THEN
          IF ENTRY_ON_HOLD_FLAG = 'Y' THEN
            DEBUG := 25;
            SELECT
              NVL(SUM(NVL(L.UNIT_SELLING_PRICE
                         ,0) * NVL(L.ORDERED_QUANTITY
                         ,0))
                 ,0)
            INTO L_TOTAL1_CREDIT
            FROM
              OE_ORDER_LINES_ALL L,
              OE_ORDER_HEADERS H,
              HZ_CUST_SITE_USES_ALL SU,
              HZ_PARTY_SITES PARTY_SITE,
              HZ_LOC_ASSIGNMENTS LOC_ASSIGN,
              HZ_LOCATIONS LOC,
              HZ_CUST_ACCT_SITES_ALL ACCT_SITE
            WHERE H.INVOICE_TO_ORG_ID = SU.SITE_USE_ID
              AND ACCT_SITE.CUST_ACCOUNT_ID = CUSTOMER_ID
              AND ACCT_SITE.CUST_ACCT_SITE_ID = SU.CUST_ACCT_SITE_ID
              AND ACCT_SITE.PARTY_SITE_ID = PARTY_SITE.PARTY_SITE_ID
              AND LOC.LOCATION_ID = PARTY_SITE.LOCATION_ID
              AND LOC.LOCATION_ID = LOC_ASSIGN.LOCATION_ID
              AND NVL(ACCT_SITE.ORG_ID
               ,-99) = NVL(LOC_ASSIGN.ORG_ID
               ,-99)
              AND H.TRANSACTIONAL_CURR_CODE = CURRENCY1
              AND L.HEADER_ID = H.HEADER_ID
              AND L.LINE_CATEGORY_CODE = 'ORDER'
              AND L.BOOKED_FLAG = 'Y'
              AND NVL(L.INVOICE_INTERFACE_STATUS_CODE
               ,'X') not in ( 'PARTIAL' , 'YES' )
              AND DECODE(ENTRY_SHIPPING_INTERVAL
                  ,-1
                  ,TRUNC(SYSDATE)
                  ,NVL(L.REQUEST_DATE
                     ,H.REQUEST_DATE) + ENTRY_SHIPPING_INTERVAL) >= TRUNC(SYSDATE);
            DEBUG := 26;
            SELECT
              NVL(SUM(NVL(L.UNIT_SELLING_PRICE
                         ,0) * (NVL(L.ORDERED_QUANTITY
                         ,0) - NVL(L.SHIPPED_QUANTITY
                         ,0)))
                 ,0)
            INTO L_TOTAL3_CREDIT
            FROM
              OE_ORDER_LINES_ALL L,
              OE_ORDER_HEADERS H,
              HZ_CUST_SITE_USES_ALL SU,
              HZ_PARTY_SITES PARTY_SITE,
              HZ_LOC_ASSIGNMENTS LOC_ASSIGN,
              HZ_LOCATIONS LOC,
              HZ_CUST_ACCT_SITES_ALL ACCT_SITE
            WHERE ACCT_SITE.CUST_ACCOUNT_ID = CUSTOMER_ID
              AND ACCT_SITE.CUST_ACCT_SITE_ID = SU.CUST_ACCT_SITE_ID
              AND ACCT_SITE.PARTY_SITE_ID = PARTY_SITE.PARTY_SITE_ID
              AND LOC.LOCATION_ID = PARTY_SITE.LOCATION_ID
              AND LOC.LOCATION_ID = LOC_ASSIGN.LOCATION_ID
              AND NVL(ACCT_SITE.ORG_ID
               ,-99) = NVL(LOC_ASSIGN.ORG_ID
               ,-99)
              AND SU.SITE_USE_ID = H.INVOICE_TO_ORG_ID
              AND H.TRANSACTIONAL_CURR_CODE = CURRENCY1
              AND L.HEADER_ID = H.HEADER_ID
              AND L.LINE_CATEGORY_CODE = 'ORDER'
              AND L.INVOICE_INTERFACE_STATUS_CODE = 'PARTIAL'
              AND L.BOOKED_FLAG = 'Y'
              AND DECODE(ENTRY_SHIPPING_INTERVAL
                  ,-1
                  ,TRUNC(SYSDATE)
                  ,NVL(L.REQUEST_DATE
                     ,H.REQUEST_DATE) + ENTRY_SHIPPING_INTERVAL) >= TRUNC(SYSDATE);
            L_UNINV_ORD_CREDIT := L_TOTAL1_CREDIT + L_TOTAL3_CREDIT;
          ELSE
            DEBUG := 27;
            SELECT
              NVL(SUM(NVL(L.UNIT_SELLING_PRICE
                         ,0) * NVL(L.ORDERED_QUANTITY
                         ,0))
                 ,0)
            INTO L_TOTAL1_CREDIT
            FROM
              OE_ORDER_LINES_ALL L,
              OE_ORDER_HEADERS H,
              HZ_CUST_SITE_USES_ALL SU,
              HZ_PARTY_SITES PARTY_SITE,
              HZ_LOC_ASSIGNMENTS LOC_ASSIGN,
              HZ_LOCATIONS LOC,
              HZ_CUST_ACCT_SITES_ALL ACCT_SITE
            WHERE ACCT_SITE.CUST_ACCOUNT_ID = CUSTOMER_ID
              AND ACCT_SITE.CUST_ACCT_SITE_ID = SU.CUST_ACCT_SITE_ID
              AND ACCT_SITE.PARTY_SITE_ID = PARTY_SITE.PARTY_SITE_ID
              AND LOC.LOCATION_ID = PARTY_SITE.LOCATION_ID
              AND LOC.LOCATION_ID = LOC_ASSIGN.LOCATION_ID
              AND NVL(ACCT_SITE.ORG_ID
               ,-99) = NVL(LOC_ASSIGN.ORG_ID
               ,-99)
              AND SU.SITE_USE_ID = H.INVOICE_TO_ORG_ID
              AND H.TRANSACTIONAL_CURR_CODE = CURRENCY1
              AND L.HEADER_ID = H.HEADER_ID
              AND L.LINE_CATEGORY_CODE = 'ORDER'
              AND L.BOOKED_FLAG = 'Y'
              AND NVL(L.INVOICE_INTERFACE_STATUS_CODE
               ,'X') not in ( 'PARTIAL' , 'YES' )
              AND DECODE(ENTRY_SHIPPING_INTERVAL
                  ,-1
                  ,TRUNC(SYSDATE)
                  ,NVL(L.REQUEST_DATE
                     ,H.REQUEST_DATE) + ENTRY_SHIPPING_INTERVAL) >= TRUNC(SYSDATE)
              AND not exists (
              SELECT
                'x'
              FROM
                OE_ORDER_HOLDS OH
              WHERE OH.HEADER_ID = H.HEADER_ID
                AND OH.HOLD_RELEASE_ID is null );
            DEBUG := 28;
            SELECT
              NVL(SUM(NVL(L.UNIT_SELLING_PRICE
                         ,0) * (NVL(L.ORDERED_QUANTITY
                         ,0) - -NVL(L.SHIPPED_QUANTITY
                         ,0)))
                 ,0)
            INTO L_TOTAL3_CREDIT
            FROM
              OE_ORDER_LINES_ALL L,
              OE_ORDER_HEADERS H,
              HZ_CUST_SITE_USES_ALL SU,
              HZ_PARTY_SITES PARTY_SITE,
              HZ_LOC_ASSIGNMENTS LOC_ASSIGN,
              HZ_LOCATIONS LOC,
              HZ_CUST_ACCT_SITES_ALL ACCT_SITE
            WHERE ACCT_SITE.CUST_ACCOUNT_ID = CUSTOMER_ID
              AND ACCT_SITE.CUST_ACCT_SITE_ID = SU.CUST_ACCT_SITE_ID
              AND ACCT_SITE.PARTY_SITE_ID = PARTY_SITE.PARTY_SITE_ID
              AND LOC.LOCATION_ID = PARTY_SITE.LOCATION_ID
              AND LOC.LOCATION_ID = LOC_ASSIGN.LOCATION_ID
              AND NVL(ACCT_SITE.ORG_ID
               ,-99) = NVL(LOC_ASSIGN.ORG_ID
               ,-99)
              AND SU.SITE_USE_ID = H.INVOICE_TO_ORG_ID
              AND H.TRANSACTIONAL_CURR_CODE = CURRENCY1
              AND L.HEADER_ID = H.HEADER_ID
              AND L.LINE_CATEGORY_CODE = 'ORDER'
              AND L.INVOICE_INTERFACE_STATUS_CODE = 'PARTIAL'
              AND L.BOOKED_FLAG = 'Y'
              AND DECODE(ENTRY_SHIPPING_INTERVAL
                  ,-1
                  ,TRUNC(SYSDATE)
                  ,NVL(L.REQUEST_DATE
                     ,H.REQUEST_DATE) + ENTRY_SHIPPING_INTERVAL) >= TRUNC(SYSDATE)
              AND not exists (
              SELECT
                'x'
              FROM
                OE_ORDER_HOLDS OH
              WHERE OH.HEADER_ID = H.HEADER_ID
                AND OH.HOLD_RELEASE_ID is null );
            L_UNINV_ORD_CREDIT := L_TOTAL1_CREDIT + L_TOTAL3_CREDIT;
          END IF;
        ELSE
          DEBUG := 29;
          L_UNINV_ORD_CREDIT := 0;
        END IF;
      ELSE
        IF ENTRY_UNINVOICED_FLAG = 'Y' THEN
          IF ENTRY_ON_HOLD_FLAG = 'Y' THEN
            DEBUG := 30;
            SELECT
              NVL(SUM(NVL(L.UNIT_SELLING_PRICE
                         ,0) * NVL(L.ORDERED_QUANTITY
                         ,0))
                 ,0)
            INTO L_TOTAL1_CREDIT
            FROM
              OE_ORDER_LINES_ALL L,
              OE_ORDER_HEADERS H,
              HZ_CUST_SITE_USES_ALL SU,
              HZ_PARTY_SITES PARTY_SITE,
              HZ_LOC_ASSIGNMENTS LOC_ASSIGN,
              HZ_LOCATIONS LOC,
              HZ_CUST_ACCT_SITES_ALL ACCT_SITE
            WHERE H.INVOICE_TO_ORG_ID = SU.SITE_USE_ID
              AND SU.SITE_USE_ID = C_COMPUTE_AMOUNTSFORMULA.SITE_USE_ID
              AND ACCT_SITE.CUST_ACCT_SITE_ID = SU.CUST_ACCT_SITE_ID
              AND ACCT_SITE.PARTY_SITE_ID = PARTY_SITE.PARTY_SITE_ID
              AND LOC.LOCATION_ID = PARTY_SITE.LOCATION_ID
              AND LOC.LOCATION_ID = LOC_ASSIGN.LOCATION_ID
              AND NVL(ACCT_SITE.ORG_ID
               ,-99) = NVL(LOC_ASSIGN.ORG_ID
               ,-99)
              AND H.TRANSACTIONAL_CURR_CODE = CURRENCY1
              AND L.HEADER_ID = H.HEADER_ID
              AND L.LINE_CATEGORY_CODE = 'ORDER'
              AND NVL(L.INVOICE_INTERFACE_STATUS_CODE
               ,'X') not in ( 'PARTIAL' , 'YES' )
              AND L.BOOKED_FLAG = 'Y'
              AND DECODE(ENTRY_SHIPPING_INTERVAL
                  ,-1
                  ,TRUNC(SYSDATE)
                  ,NVL(L.REQUEST_DATE
                     ,H.REQUEST_DATE) + ENTRY_SHIPPING_INTERVAL) >= TRUNC(SYSDATE);
            DEBUG := 31;
            SELECT
              NVL(SUM(NVL(L.UNIT_SELLING_PRICE
                         ,0) * (NVL(L.ORDERED_QUANTITY
                         ,0) - -NVL(L.SHIPPED_QUANTITY
                         ,0)))
                 ,0)
            INTO L_TOTAL3_CREDIT
            FROM
              OE_ORDER_LINES_ALL L,
              OE_ORDER_HEADERS H,
              HZ_CUST_SITE_USES_ALL SU,
              HZ_PARTY_SITES PARTY_SITE,
              HZ_LOC_ASSIGNMENTS LOC_ASSIGN,
              HZ_LOCATIONS LOC,
              HZ_CUST_ACCT_SITES_ALL ACCT_SITE
            WHERE SU.SITE_USE_ID = C_COMPUTE_AMOUNTSFORMULA.SITE_USE_ID
              AND ACCT_SITE.CUST_ACCT_SITE_ID = SU.CUST_ACCT_SITE_ID
              AND ACCT_SITE.PARTY_SITE_ID = PARTY_SITE.PARTY_SITE_ID
              AND LOC.LOCATION_ID = PARTY_SITE.LOCATION_ID
              AND LOC.LOCATION_ID = LOC_ASSIGN.LOCATION_ID
              AND NVL(ACCT_SITE.ORG_ID
               ,-99) = NVL(LOC_ASSIGN.ORG_ID
               ,-99)
              AND SU.SITE_USE_ID = H.INVOICE_TO_ORG_ID
              AND H.TRANSACTIONAL_CURR_CODE = CURRENCY1
              AND L.HEADER_ID = H.HEADER_ID
              AND L.LINE_CATEGORY_CODE = 'ORDER'
              AND L.INVOICE_INTERFACE_STATUS_CODE = 'PARTIAL'
              AND L.BOOKED_FLAG = 'Y'
              AND DECODE(ENTRY_SHIPPING_INTERVAL
                  ,-1
                  ,TRUNC(SYSDATE)
                  ,NVL(L.REQUEST_DATE
                     ,H.REQUEST_DATE) + ENTRY_SHIPPING_INTERVAL) >= TRUNC(SYSDATE);
            L_UNINV_ORD_CREDIT := L_TOTAL1_CREDIT + L_TOTAL3_CREDIT;
          ELSE
            DEBUG := 32;
            SELECT
              NVL(SUM(NVL(L.UNIT_SELLING_PRICE
                         ,0) * NVL(L.ORDERED_QUANTITY
                         ,0))
                 ,0)
            INTO L_TOTAL1_CREDIT
            FROM
              OE_ORDER_LINES_ALL L,
              OE_ORDER_HEADERS H,
              HZ_CUST_SITE_USES_ALL SU,
              HZ_PARTY_SITES PARTY_SITE,
              HZ_LOC_ASSIGNMENTS LOC_ASSIGN,
              HZ_LOCATIONS LOC,
              HZ_CUST_ACCT_SITES_ALL ACCT_SITE
            WHERE SU.SITE_USE_ID = C_COMPUTE_AMOUNTSFORMULA.SITE_USE_ID
              AND ACCT_SITE.CUST_ACCT_SITE_ID = SU.CUST_ACCT_SITE_ID
              AND ACCT_SITE.PARTY_SITE_ID = PARTY_SITE.PARTY_SITE_ID
              AND LOC.LOCATION_ID = PARTY_SITE.LOCATION_ID
              AND LOC.LOCATION_ID = LOC_ASSIGN.LOCATION_ID
              AND NVL(ACCT_SITE.ORG_ID
               ,-99) = NVL(LOC_ASSIGN.ORG_ID
               ,-99)
              AND SU.SITE_USE_ID = H.INVOICE_TO_ORG_ID
              AND H.TRANSACTIONAL_CURR_CODE = CURRENCY1
              AND L.HEADER_ID = H.HEADER_ID
              AND L.LINE_CATEGORY_CODE = 'ORDER'
              AND NVL(L.INVOICE_INTERFACE_STATUS_CODE
               ,'X') not in ( 'PARTIAL' , 'YES' )
              AND L.BOOKED_FLAG = 'Y'
              AND DECODE(ENTRY_SHIPPING_INTERVAL
                  ,-1
                  ,TRUNC(SYSDATE)
                  ,NVL(L.REQUEST_DATE
                     ,H.REQUEST_DATE) + ENTRY_SHIPPING_INTERVAL) >= TRUNC(SYSDATE)
              AND not exists (
              SELECT
                'x'
              FROM
                OE_ORDER_HOLDS OH
              WHERE OH.HEADER_ID = H.HEADER_ID
                AND OH.HOLD_RELEASE_ID is null );
            DEBUG := 33;
            SELECT
              NVL(SUM(NVL(L.UNIT_SELLING_PRICE
                         ,0) * (NVL(L.ORDERED_QUANTITY
                         ,0) - -NVL(L.SHIPPED_QUANTITY
                         ,0)))
                 ,0)
            INTO L_TOTAL3_CREDIT
            FROM
              OE_ORDER_LINES_ALL L,
              OE_ORDER_HEADERS H,
              HZ_CUST_SITE_USES_ALL SU,
              HZ_PARTY_SITES PARTY_SITE,
              HZ_LOC_ASSIGNMENTS LOC_ASSIGN,
              HZ_LOCATIONS LOC,
              HZ_CUST_ACCT_SITES_ALL ACCT_SITE
            WHERE SU.SITE_USE_ID = C_COMPUTE_AMOUNTSFORMULA.SITE_USE_ID
              AND ACCT_SITE.CUST_ACCT_SITE_ID = SU.CUST_ACCT_SITE_ID
              AND ACCT_SITE.PARTY_SITE_ID = PARTY_SITE.PARTY_SITE_ID
              AND LOC.LOCATION_ID = PARTY_SITE.LOCATION_ID
              AND LOC.LOCATION_ID = LOC_ASSIGN.LOCATION_ID
              AND NVL(ACCT_SITE.ORG_ID
               ,-99) = NVL(LOC_ASSIGN.ORG_ID
               ,-99)
              AND SU.SITE_USE_ID = H.INVOICE_TO_ORG_ID
              AND H.TRANSACTIONAL_CURR_CODE = CURRENCY1
              AND L.HEADER_ID = H.HEADER_ID
              AND L.LINE_CATEGORY_CODE = 'ORDER'
              AND L.INVOICE_INTERFACE_STATUS_CODE = 'PARTIAL'
              AND L.BOOKED_FLAG = 'Y'
              AND DECODE(ENTRY_SHIPPING_INTERVAL
                  ,-1
                  ,TRUNC(SYSDATE)
                  ,NVL(L.REQUEST_DATE
                     ,H.REQUEST_DATE) + ENTRY_SHIPPING_INTERVAL) >= TRUNC(SYSDATE)
              AND not exists (
              SELECT
                'x'
              FROM
                OE_ORDER_HOLDS OH
              WHERE OH.HEADER_ID = H.HEADER_ID
                AND OH.HOLD_RELEASE_ID is null );
            L_UNINV_ORD_CREDIT := L_TOTAL1_CREDIT + L_TOTAL3_CREDIT;
          END IF;
        ELSE
          DEBUG := 34;
          L_UNINV_ORD_CREDIT := 0;
        END IF;
      END IF;
      C_UNINV_ORD_CREDIT := L_UNINV_ORD_CREDIT;
      IF SITE_USE_ID = 0 THEN
        IF SHIP_UNINVOICED_FLAG = 'Y' THEN
          IF SHIP_ON_HOLD_FLAG = 'Y' THEN
            DEBUG := 35;
            SELECT
              NVL(SUM(NVL(L.UNIT_SELLING_PRICE
                         ,0) * NVL(L.ORDERED_QUANTITY
                         ,0))
                 ,0)
            INTO L_TOTAL1_SHIP
            FROM
              OE_ORDER_LINES_ALL L,
              OE_ORDER_HEADERS H,
              HZ_CUST_SITE_USES_ALL SU,
              HZ_PARTY_SITES PARTY_SITE,
              HZ_LOC_ASSIGNMENTS LOC_ASSIGN,
              HZ_LOCATIONS LOC,
              HZ_CUST_ACCT_SITES_ALL ACCT_SITE
            WHERE ACCT_SITE.CUST_ACCOUNT_ID = CUSTOMER_ID
              AND ACCT_SITE.CUST_ACCT_SITE_ID = SU.CUST_ACCT_SITE_ID
              AND ACCT_SITE.PARTY_SITE_ID = PARTY_SITE.PARTY_SITE_ID
              AND LOC.LOCATION_ID = PARTY_SITE.LOCATION_ID
              AND LOC.LOCATION_ID = LOC_ASSIGN.LOCATION_ID
              AND NVL(ACCT_SITE.ORG_ID
               ,-99) = NVL(LOC_ASSIGN.ORG_ID
               ,-99)
              AND SU.SITE_USE_ID = H.INVOICE_TO_ORG_ID
              AND H.TRANSACTIONAL_CURR_CODE = CURRENCY1
              AND L.HEADER_ID = H.HEADER_ID
              AND L.LINE_CATEGORY_CODE = 'ORDER'
              AND L.BOOKED_FLAG = 'Y'
              AND NVL(L.INVOICE_INTERFACE_STATUS_CODE
               ,'X') not in ( 'PARTIAL' , 'YES' )
              AND DECODE(SHIP_SHIPPING_INTERVAL
                  ,-1
                  ,TRUNC(SYSDATE)
                  ,NVL(L.REQUEST_DATE
                     ,H.REQUEST_DATE) + SHIP_SHIPPING_INTERVAL) >= TRUNC(SYSDATE);
            DEBUG := 36;
            SELECT
              NVL(SUM(NVL(L.UNIT_SELLING_PRICE
                         ,0) * (NVL(L.ORDERED_QUANTITY
                         ,0) - NVL(L.SHIPPED_QUANTITY
                         ,0)))
                 ,0)
            INTO L_TOTAL3_SHIP
            FROM
              OE_ORDER_LINES_ALL L,
              OE_ORDER_HEADERS H,
              HZ_CUST_SITE_USES_ALL SU,
              HZ_PARTY_SITES PARTY_SITE,
              HZ_LOC_ASSIGNMENTS LOC_ASSIGN,
              HZ_LOCATIONS LOC,
              HZ_CUST_ACCT_SITES_ALL ACCT_SITE
            WHERE ACCT_SITE.CUST_ACCOUNT_ID = CUSTOMER_ID
              AND ACCT_SITE.CUST_ACCT_SITE_ID = SU.CUST_ACCT_SITE_ID
              AND ACCT_SITE.PARTY_SITE_ID = PARTY_SITE.PARTY_SITE_ID
              AND LOC.LOCATION_ID = PARTY_SITE.LOCATION_ID
              AND LOC.LOCATION_ID = LOC_ASSIGN.LOCATION_ID
              AND NVL(ACCT_SITE.ORG_ID
               ,-99) = NVL(LOC_ASSIGN.ORG_ID
               ,-99)
              AND SU.SITE_USE_ID = H.INVOICE_TO_ORG_ID
              AND H.TRANSACTIONAL_CURR_CODE = CURRENCY1
              AND L.HEADER_ID = H.HEADER_ID
              AND L.LINE_CATEGORY_CODE = 'ORDER'
              AND L.INVOICE_INTERFACE_STATUS_CODE = 'PARTIAL'
              AND L.BOOKED_FLAG = 'Y'
              AND DECODE(SHIP_SHIPPING_INTERVAL
                  ,-1
                  ,TRUNC(SYSDATE)
                  ,NVL(L.REQUEST_DATE
                     ,H.REQUEST_DATE) + SHIP_SHIPPING_INTERVAL) >= TRUNC(SYSDATE);
            L_UNINV_ORD_SHIP := L_TOTAL1_SHIP + L_TOTAL3_SHIP;
          ELSE
            DEBUG := 37;
            SELECT
              NVL(SUM(NVL(L.UNIT_SELLING_PRICE
                         ,0) * NVL(L.ORDERED_QUANTITY
                         ,0))
                 ,0)
            INTO L_TOTAL1_SHIP
            FROM
              OE_ORDER_LINES_ALL L,
              OE_ORDER_HEADERS H,
              HZ_CUST_SITE_USES_ALL SU,
              HZ_PARTY_SITES PARTY_SITE,
              HZ_LOC_ASSIGNMENTS LOC_ASSIGN,
              HZ_LOCATIONS LOC,
              HZ_CUST_ACCT_SITES_ALL ACCT_SITE
            WHERE ACCT_SITE.CUST_ACCOUNT_ID = CUSTOMER_ID
              AND ACCT_SITE.CUST_ACCT_SITE_ID = SU.CUST_ACCT_SITE_ID
              AND ACCT_SITE.PARTY_SITE_ID = PARTY_SITE.PARTY_SITE_ID
              AND LOC.LOCATION_ID = PARTY_SITE.LOCATION_ID
              AND LOC.LOCATION_ID = LOC_ASSIGN.LOCATION_ID
              AND NVL(ACCT_SITE.ORG_ID
               ,-99) = NVL(LOC_ASSIGN.ORG_ID
               ,-99)
              AND SU.SITE_USE_ID = H.INVOICE_TO_ORG_ID
              AND H.TRANSACTIONAL_CURR_CODE = CURRENCY1
              AND L.HEADER_ID = H.HEADER_ID
              AND L.LINE_CATEGORY_CODE = 'ORDER'
              AND L.BOOKED_FLAG = 'Y'
              AND NVL(L.INVOICE_INTERFACE_STATUS_CODE
               ,'X') not in ( 'PARTIAL' , 'YES' )
              AND DECODE(SHIP_SHIPPING_INTERVAL
                  ,-1
                  ,TRUNC(SYSDATE)
                  ,NVL(L.REQUEST_DATE
                     ,H.REQUEST_DATE) + SHIP_SHIPPING_INTERVAL) >= TRUNC(SYSDATE)
              AND not exists (
              SELECT
                'x'
              FROM
                OE_ORDER_HOLDS OH
              WHERE OH.HEADER_ID = H.HEADER_ID
                AND OH.HOLD_RELEASE_ID is null );
            DEBUG := 38;
            SELECT
              NVL(SUM(NVL(L.UNIT_SELLING_PRICE
                         ,0) * (NVL(L.ORDERED_QUANTITY
                         ,0) - NVL(L.SHIPPED_QUANTITY
                         ,0)))
                 ,0)
            INTO L_TOTAL3_SHIP
            FROM
              OE_ORDER_LINES_ALL L,
              OE_ORDER_HEADERS H,
              HZ_CUST_SITE_USES_ALL SU,
              HZ_PARTY_SITES PARTY_SITE,
              HZ_LOC_ASSIGNMENTS LOC_ASSIGN,
              HZ_LOCATIONS LOC,
              HZ_CUST_ACCT_SITES_ALL ACCT_SITE
            WHERE ACCT_SITE.CUST_ACCOUNT_ID = CUSTOMER_ID
              AND ACCT_SITE.CUST_ACCT_SITE_ID = SU.CUST_ACCT_SITE_ID
              AND ACCT_SITE.PARTY_SITE_ID = PARTY_SITE.PARTY_SITE_ID
              AND LOC.LOCATION_ID = PARTY_SITE.LOCATION_ID
              AND LOC.LOCATION_ID = LOC_ASSIGN.LOCATION_ID
              AND NVL(ACCT_SITE.ORG_ID
               ,-99) = NVL(LOC_ASSIGN.ORG_ID
               ,-99)
              AND SU.SITE_USE_ID = H.INVOICE_TO_ORG_ID
              AND H.TRANSACTIONAL_CURR_CODE = CURRENCY1
              AND L.HEADER_ID = H.HEADER_ID
              AND L.LINE_CATEGORY_CODE = 'ORDER'
              AND L.INVOICE_INTERFACE_STATUS_CODE = 'PARTIAL'
              AND L.BOOKED_FLAG = 'Y'
              AND DECODE(SHIP_SHIPPING_INTERVAL
                  ,-1
                  ,TRUNC(SYSDATE)
                  ,NVL(L.REQUEST_DATE
                     ,H.REQUEST_DATE) + SHIP_SHIPPING_INTERVAL) >= TRUNC(SYSDATE)
              AND not exists (
              SELECT
                'x'
              FROM
                OE_ORDER_HOLDS OH
              WHERE OH.HEADER_ID = H.HEADER_ID
                AND OH.HOLD_RELEASE_ID is null );
            L_UNINV_ORD_SHIP := L_TOTAL1_SHIP + L_TOTAL3_SHIP;
          END IF;
        ELSE
          DEBUG := 39;
          L_UNINV_ORD_SHIP := 0;
        END IF;
      ELSE
        IF SHIP_UNINVOICED_FLAG = 'Y' THEN
          IF SHIP_ON_HOLD_FLAG = 'Y' THEN
            DEBUG := 40;
            SELECT
              NVL(SUM(NVL(L.UNIT_SELLING_PRICE
                         ,0) * NVL(L.ORDERED_QUANTITY
                         ,0))
                 ,0)
            INTO L_TOTAL1_SHIP
            FROM
              OE_ORDER_LINES_ALL L,
              OE_ORDER_HEADERS H,
              HZ_CUST_SITE_USES_ALL SU,
              HZ_PARTY_SITES PARTY_SITE,
              HZ_LOC_ASSIGNMENTS LOC_ASSIGN,
              HZ_LOCATIONS LOC,
              HZ_CUST_ACCT_SITES_ALL ACCT_SITE
            WHERE H.INVOICE_TO_ORG_ID = SU.SITE_USE_ID
              AND SU.SITE_USE_ID = C_COMPUTE_AMOUNTSFORMULA.SITE_USE_ID
              AND ACCT_SITE.CUST_ACCT_SITE_ID = SU.CUST_ACCT_SITE_ID
              AND ACCT_SITE.PARTY_SITE_ID = PARTY_SITE.PARTY_SITE_ID
              AND LOC.LOCATION_ID = PARTY_SITE.LOCATION_ID
              AND LOC.LOCATION_ID = LOC_ASSIGN.LOCATION_ID
              AND NVL(ACCT_SITE.ORG_ID
               ,-99) = NVL(LOC_ASSIGN.ORG_ID
               ,-99)
              AND H.TRANSACTIONAL_CURR_CODE = CURRENCY1
              AND L.HEADER_ID = H.HEADER_ID
              AND L.LINE_CATEGORY_CODE = 'ORDER'
              AND NVL(L.INVOICE_INTERFACE_STATUS_CODE
               ,'X') not in ( 'PARTIAL' , 'YES' )
              AND L.BOOKED_FLAG = 'Y'
              AND DECODE(SHIP_SHIPPING_INTERVAL
                  ,-1
                  ,TRUNC(SYSDATE)
                  ,NVL(L.REQUEST_DATE
                     ,H.REQUEST_DATE) + SHIP_SHIPPING_INTERVAL) >= TRUNC(SYSDATE);
            DEBUG := 41;
            SELECT
              NVL(SUM(NVL(L.UNIT_SELLING_PRICE
                         ,0) * (NVL(L.ORDERED_QUANTITY
                         ,0) - NVL(L.SHIPPED_QUANTITY
                         ,0)))
                 ,0)
            INTO L_TOTAL3_SHIP
            FROM
              OE_ORDER_LINES_ALL L,
              OE_ORDER_HEADERS H,
              HZ_CUST_SITE_USES_ALL SU,
              HZ_PARTY_SITES PARTY_SITE,
              HZ_LOC_ASSIGNMENTS LOC_ASSIGN,
              HZ_LOCATIONS LOC,
              HZ_CUST_ACCT_SITES_ALL ACCT_SITE
            WHERE SU.SITE_USE_ID = C_COMPUTE_AMOUNTSFORMULA.SITE_USE_ID
              AND ACCT_SITE.CUST_ACCT_SITE_ID = SU.CUST_ACCT_SITE_ID
              AND ACCT_SITE.PARTY_SITE_ID = PARTY_SITE.PARTY_SITE_ID
              AND LOC.LOCATION_ID = PARTY_SITE.LOCATION_ID
              AND LOC.LOCATION_ID = LOC_ASSIGN.LOCATION_ID
              AND NVL(ACCT_SITE.ORG_ID
               ,-99) = NVL(LOC_ASSIGN.ORG_ID
               ,-99)
              AND SU.SITE_USE_ID = H.INVOICE_TO_ORG_ID
              AND H.TRANSACTIONAL_CURR_CODE = CURRENCY1
              AND L.HEADER_ID = H.HEADER_ID
              AND L.LINE_CATEGORY_CODE = 'ORDER'
              AND L.INVOICE_INTERFACE_STATUS_CODE = 'PARTIAL'
              AND L.BOOKED_FLAG = 'Y'
              AND DECODE(SHIP_SHIPPING_INTERVAL
                  ,-1
                  ,TRUNC(SYSDATE)
                  ,NVL(L.REQUEST_DATE
                     ,H.REQUEST_DATE) + SHIP_SHIPPING_INTERVAL) >= TRUNC(SYSDATE);
            L_UNINV_ORD_SHIP := L_TOTAL1_SHIP + L_TOTAL3_SHIP;
          ELSE
            DEBUG := 42;
            SELECT
              NVL(SUM(NVL(L.UNIT_SELLING_PRICE
                         ,0) * NVL(L.ORDERED_QUANTITY
                         ,0))
                 ,0)
            INTO L_TOTAL1_SHIP
            FROM
              OE_ORDER_LINES_ALL L,
              OE_ORDER_HEADERS H,
              HZ_CUST_SITE_USES_ALL SU,
              HZ_PARTY_SITES PARTY_SITE,
              HZ_LOC_ASSIGNMENTS LOC_ASSIGN,
              HZ_LOCATIONS LOC,
              HZ_CUST_ACCT_SITES_ALL ACCT_SITE
            WHERE SU.SITE_USE_ID = C_COMPUTE_AMOUNTSFORMULA.SITE_USE_ID
              AND ACCT_SITE.CUST_ACCT_SITE_ID = SU.CUST_ACCT_SITE_ID
              AND ACCT_SITE.PARTY_SITE_ID = PARTY_SITE.PARTY_SITE_ID
              AND LOC.LOCATION_ID = PARTY_SITE.LOCATION_ID
              AND LOC.LOCATION_ID = LOC_ASSIGN.LOCATION_ID
              AND NVL(ACCT_SITE.ORG_ID
               ,-99) = NVL(LOC_ASSIGN.ORG_ID
               ,-99)
              AND SU.SITE_USE_ID = H.INVOICE_TO_ORG_ID
              AND H.TRANSACTIONAL_CURR_CODE = CURRENCY1
              AND L.HEADER_ID = H.HEADER_ID
              AND L.LINE_CATEGORY_CODE = 'ORDER'
              AND NVL(L.INVOICE_INTERFACE_STATUS_CODE
               ,'X') not in ( 'PARTIAL' , 'YES' )
              AND L.BOOKED_FLAG = 'Y'
              AND DECODE(SHIP_SHIPPING_INTERVAL
                  ,-1
                  ,TRUNC(SYSDATE)
                  ,NVL(L.REQUEST_DATE
                     ,H.REQUEST_DATE) + SHIP_SHIPPING_INTERVAL) >= TRUNC(SYSDATE)
              AND not exists (
              SELECT
                'x'
              FROM
                OE_ORDER_HOLDS OH
              WHERE OH.HEADER_ID = H.HEADER_ID
                AND OH.HOLD_RELEASE_ID is null );
            DEBUG := 43;
            SELECT
              NVL(SUM(NVL(L.UNIT_SELLING_PRICE
                         ,0) * (NVL(L.ORDERED_QUANTITY
                         ,0) - NVL(L.SHIPPED_QUANTITY
                         ,0)))
                 ,0)
            INTO L_TOTAL3_SHIP
            FROM
              OE_ORDER_LINES_ALL L,
              OE_ORDER_HEADERS H,
              HZ_CUST_SITE_USES_ALL SU,
              HZ_PARTY_SITES PARTY_SITE,
              HZ_LOC_ASSIGNMENTS LOC_ASSIGN,
              HZ_LOCATIONS LOC,
              HZ_CUST_ACCT_SITES_ALL ACCT_SITE
            WHERE SU.SITE_USE_ID = C_COMPUTE_AMOUNTSFORMULA.SITE_USE_ID
              AND ACCT_SITE.CUST_ACCT_SITE_ID = SU.CUST_ACCT_SITE_ID
              AND ACCT_SITE.PARTY_SITE_ID = PARTY_SITE.PARTY_SITE_ID
              AND LOC.LOCATION_ID = PARTY_SITE.LOCATION_ID
              AND LOC.LOCATION_ID = LOC_ASSIGN.LOCATION_ID
              AND NVL(ACCT_SITE.ORG_ID
               ,-99) = NVL(LOC_ASSIGN.ORG_ID
               ,-99)
              AND SU.SITE_USE_ID = H.INVOICE_TO_ORG_ID
              AND H.TRANSACTIONAL_CURR_CODE = CURRENCY1
              AND L.HEADER_ID = H.HEADER_ID
              AND L.LINE_CATEGORY_CODE = 'ORDER'
              AND L.INVOICE_INTERFACE_STATUS_CODE = 'PARTIAL'
              AND L.BOOKED_FLAG = 'Y'
              AND DECODE(SHIP_SHIPPING_INTERVAL
                  ,-1
                  ,TRUNC(SYSDATE)
                  ,NVL(L.REQUEST_DATE
                     ,H.REQUEST_DATE) + SHIP_SHIPPING_INTERVAL) >= TRUNC(SYSDATE)
              AND not exists (
              SELECT
                'x'
              FROM
                OE_ORDER_HOLDS OH
              WHERE OH.HEADER_ID = H.HEADER_ID
                AND OH.HOLD_RELEASE_ID is null );
            L_UNINV_ORD_SHIP := L_TOTAL1_SHIP + L_TOTAL3_SHIP;
          END IF;
        ELSE
          DEBUG := 44;
          L_UNINV_ORD_SHIP := 0;
        END IF;
      END IF;
      C_UNINV_ORD_PACK := L_UNINV_ORD_PACK;
      IF SITE_USE_ID = 0 THEN
        IF PICK_OPEN_AR_FLAG = 'Y' THEN
          IF PICK_OPEN_AR_DAYS IS NULL THEN
            DEBUG := 47;
            SELECT
              NVL(SUM(AMOUNT_DUE_REMAINING)
                 ,0)
            INTO L_REC_BAL_PICK
            FROM
              AR_PAYMENT_SCHEDULES
            WHERE CUSTOMER_ID = CUSTOMER_ID
              AND INVOICE_CURRENCY_CODE = CURRENCY1
              AND NVL(RECEIPT_CONFIRMED_FLAG
               ,'Y') = 'Y';
            IF L_INCLUDE_RISK_FLAG2 = 'Y' THEN
              DEBUG := 48;
              SELECT
                NVL(SUM(CRH.AMOUNT)
                   ,0) + L_REC_BAL_PICK
              INTO L_REC_BAL_PICK
              FROM
                AR_CASH_RECEIPT_HISTORY CRH,
                AR_CASH_RECEIPTS CR
              WHERE CRH.CASH_RECEIPT_ID = CR.CASH_RECEIPT_ID
                AND NVL(CR.CONFIRMED_FLAG
                 ,'Y') = 'Y'
                AND CRH.CURRENT_RECORD_FLAG = 'Y'
                AND CRH.STATUS <> DECODE(CRH.FACTOR_FLAG
                    ,'Y'
                    ,'RISK_ELIMINATED'
                    ,'CLEARED')
                AND CRH.STATUS <> 'REVERSED'
                AND CR.CURRENCY_CODE = CURRENCY1
                AND CR.PAY_FROM_CUSTOMER = CUSTOMER_ID;
            END IF;
          ELSE
            DEBUG := 49;
            SELECT
              NVL(SUM(AMOUNT_DUE_REMAINING)
                 ,0)
            INTO L_REC_BAL_PICK
            FROM
              AR_PAYMENT_SCHEDULES
            WHERE CUSTOMER_ID = CUSTOMER_ID
              AND INVOICE_CURRENCY_CODE = CURRENCY1
              AND NVL(RECEIPT_CONFIRMED_FLAG
               ,'Y') = 'Y'
              AND SYSDATE - TRX_DATE > PICK_OPEN_AR_DAYS;
            IF L_INCLUDE_RISK_FLAG2 = 'Y' THEN
              DEBUG := 50;
              SELECT
                NVL(SUM(CRH.AMOUNT)
                   ,0) + L_REC_BAL_PICK
              INTO L_REC_BAL_PICK
              FROM
                AR_CASH_RECEIPT_HISTORY CRH,
                AR_CASH_RECEIPTS CR
              WHERE CRH.CASH_RECEIPT_ID = CR.CASH_RECEIPT_ID
                AND NVL(CR.CONFIRMED_FLAG
                 ,'Y') = 'Y'
                AND CRH.CURRENT_RECORD_FLAG = 'Y'
                AND CRH.STATUS <> DECODE(CRH.FACTOR_FLAG
                    ,'Y'
                    ,'RISK_ELIMINATED'
                    ,'CLEARED')
                AND CRH.STATUS <> 'REVERSED'
                AND CR.CURRENCY_CODE = CURRENCY1
                AND CR.PAY_FROM_CUSTOMER = CUSTOMER_ID
                AND SYSDATE - CR.RECEIPT_DATE > PICK_OPEN_AR_DAYS;
            END IF;
          END IF;
        ELSE
          DEBUG := 51;
          L_REC_BAL_PICK := 0;
        END IF;
      ELSE
        IF PICK_OPEN_AR_FLAG = 'Y' THEN
          IF PICK_OPEN_AR_DAYS IS NULL THEN
            DEBUG := 52;
            SELECT
              NVL(SUM(AMOUNT_DUE_REMAINING)
                 ,0)
            INTO L_REC_BAL_PICK
            FROM
              AR_PAYMENT_SCHEDULES
            WHERE CUSTOMER_SITE_USE_ID = C_COMPUTE_AMOUNTSFORMULA.SITE_USE_ID
              AND NVL(RECEIPT_CONFIRMED_FLAG
               ,'Y') = 'Y'
              AND INVOICE_CURRENCY_CODE = CURRENCY1;
            IF L_INCLUDE_RISK_FLAG2 = 'Y' THEN
              DEBUG := 53;
              SELECT
                NVL(SUM(CRH.AMOUNT)
                   ,0) + L_REC_BAL_PICK
              INTO L_REC_BAL_PICK
              FROM
                AR_CASH_RECEIPT_HISTORY CRH,
                AR_CASH_RECEIPTS CR
              WHERE CRH.CASH_RECEIPT_ID = CR.CASH_RECEIPT_ID
                AND NVL(CR.CONFIRMED_FLAG
                 ,'Y') = 'Y'
                AND CRH.CURRENT_RECORD_FLAG = 'Y'
                AND CRH.STATUS <> DECODE(CRH.FACTOR_FLAG
                    ,'Y'
                    ,'RISK_ELIMINATED'
                    ,'CLEARED')
                AND CRH.STATUS <> 'REVERSED'
                AND CR.CURRENCY_CODE = CURRENCY1
                AND CR.PAY_FROM_CUSTOMER = CUSTOMER_ID
                AND CR.CUSTOMER_SITE_USE_ID = C_COMPUTE_AMOUNTSFORMULA.SITE_USE_ID;
            END IF;
          ELSE
            DEBUG := 54;
            SELECT
              NVL(SUM(AMOUNT_DUE_REMAINING)
                 ,0)
            INTO L_REC_BAL_PICK
            FROM
              AR_PAYMENT_SCHEDULES
            WHERE CUSTOMER_SITE_USE_ID = C_COMPUTE_AMOUNTSFORMULA.SITE_USE_ID
              AND NVL(RECEIPT_CONFIRMED_FLAG
               ,'Y') = 'Y'
              AND INVOICE_CURRENCY_CODE = CURRENCY1
              AND SYSDATE - TRX_DATE > PICK_OPEN_AR_DAYS;
            IF L_INCLUDE_RISK_FLAG2 = 'Y' THEN
              DEBUG := 55;
              SELECT
                NVL(SUM(CRH.AMOUNT)
                   ,0) + L_REC_BAL_PICK
              INTO L_REC_BAL_PICK
              FROM
                AR_CASH_RECEIPT_HISTORY CRH,
                AR_CASH_RECEIPTS CR
              WHERE CRH.CASH_RECEIPT_ID = CR.CASH_RECEIPT_ID
                AND NVL(CR.CONFIRMED_FLAG
                 ,'Y') = 'Y'
                AND CRH.CURRENT_RECORD_FLAG = 'Y'
                AND CRH.STATUS <> DECODE(CRH.FACTOR_FLAG
                    ,'Y'
                    ,'RISK_ELIMINATED'
                    ,'CLEARED')
                AND CRH.STATUS <> 'REVERSED'
                AND CR.CURRENCY_CODE = CURRENCY1
                AND CR.PAY_FROM_CUSTOMER = CUSTOMER_ID
                AND CR.CUSTOMER_SITE_USE_ID = C_COMPUTE_AMOUNTSFORMULA.SITE_USE_ID
                AND SYSDATE - CR.RECEIPT_DATE > PICK_OPEN_AR_DAYS;
            END IF;
          END IF;
        ELSE
          DEBUG := 56;
          L_REC_BAL_PICK := 0;
        END IF;
      END IF;
      C_REC_BAL_PICK := L_REC_BAL_PICK;
      IF SITE_USE_ID = 0 THEN
        IF PACK_OPEN_AR_FLAG = 'Y' THEN
          IF PACK_OPEN_AR_DAYS IS NULL THEN
            DEBUG := 57;
            SELECT
              NVL(SUM(AMOUNT_DUE_REMAINING)
                 ,0)
            INTO L_REC_BAL_PACK
            FROM
              AR_PAYMENT_SCHEDULES
            WHERE CUSTOMER_ID = CUSTOMER_ID
              AND INVOICE_CURRENCY_CODE = CURRENCY1
              AND NVL(RECEIPT_CONFIRMED_FLAG
               ,'Y') = 'Y';
            IF L_INCLUDE_RISK_FLAG2 = 'Y' THEN
              DEBUG := 58;
              SELECT
                NVL(SUM(CRH.AMOUNT)
                   ,0) + L_REC_BAL_PACK
              INTO L_REC_BAL_PACK
              FROM
                AR_CASH_RECEIPT_HISTORY CRH,
                AR_CASH_RECEIPTS CR
              WHERE CRH.CASH_RECEIPT_ID = CR.CASH_RECEIPT_ID
                AND NVL(CR.CONFIRMED_FLAG
                 ,'Y') = 'Y'
                AND CRH.CURRENT_RECORD_FLAG = 'Y'
                AND CRH.STATUS <> DECODE(CRH.FACTOR_FLAG
                    ,'Y'
                    ,'RISK_ELIMINATED'
                    ,'CLEARED')
                AND CRH.STATUS <> 'REVERSED'
                AND CR.CURRENCY_CODE = CURRENCY1
                AND CR.PAY_FROM_CUSTOMER = CUSTOMER_ID;
            END IF;
          ELSE
            DEBUG := 59;
            SELECT
              NVL(SUM(AMOUNT_DUE_REMAINING)
                 ,0)
            INTO L_REC_BAL_PACK
            FROM
              AR_PAYMENT_SCHEDULES
            WHERE CUSTOMER_ID = CUSTOMER_ID
              AND INVOICE_CURRENCY_CODE = CURRENCY1
              AND NVL(RECEIPT_CONFIRMED_FLAG
               ,'Y') = 'Y'
              AND SYSDATE - TRX_DATE > PACK_OPEN_AR_DAYS;
            IF L_INCLUDE_RISK_FLAG2 = 'Y' THEN
              DEBUG := 60;
              SELECT
                NVL(SUM(CRH.AMOUNT)
                   ,0) + L_REC_BAL_PACK
              INTO L_REC_BAL_PACK
              FROM
                AR_CASH_RECEIPT_HISTORY CRH,
                AR_CASH_RECEIPTS CR
              WHERE CRH.CASH_RECEIPT_ID = CR.CASH_RECEIPT_ID
                AND NVL(CR.CONFIRMED_FLAG
                 ,'Y') = 'Y'
                AND CRH.CURRENT_RECORD_FLAG = 'Y'
                AND CRH.STATUS <> DECODE(CRH.FACTOR_FLAG
                    ,'Y'
                    ,'RISK_ELIMINATED'
                    ,'CLEARED')
                AND CRH.STATUS <> 'REVERSED'
                AND CR.CURRENCY_CODE = CURRENCY1
                AND CR.PAY_FROM_CUSTOMER = CUSTOMER_ID
                AND SYSDATE - CR.RECEIPT_DATE > PACK_OPEN_AR_DAYS;
            END IF;
          END IF;
        ELSE
          DEBUG := 61;
          L_REC_BAL_PACK := 0;
        END IF;
      ELSE
        IF PACK_OPEN_AR_FLAG = 'Y' THEN
          IF PACK_OPEN_AR_DAYS IS NULL THEN
            DEBUG := 62;
            SELECT
              NVL(SUM(AMOUNT_DUE_REMAINING)
                 ,0)
            INTO L_REC_BAL_PACK
            FROM
              AR_PAYMENT_SCHEDULES
            WHERE CUSTOMER_SITE_USE_ID = C_COMPUTE_AMOUNTSFORMULA.SITE_USE_ID
              AND NVL(RECEIPT_CONFIRMED_FLAG
               ,'Y') = 'Y'
              AND INVOICE_CURRENCY_CODE = CURRENCY1;
            IF L_INCLUDE_RISK_FLAG2 = 'Y' THEN
              DEBUG := 63;
              SELECT
                NVL(SUM(CRH.AMOUNT)
                   ,0) + L_REC_BAL_PACK
              INTO L_REC_BAL_PACK
              FROM
                AR_CASH_RECEIPT_HISTORY CRH,
                AR_CASH_RECEIPTS CR
              WHERE CRH.CASH_RECEIPT_ID = CR.CASH_RECEIPT_ID
                AND NVL(CR.CONFIRMED_FLAG
                 ,'Y') = 'Y'
                AND CRH.CURRENT_RECORD_FLAG = 'Y'
                AND CRH.STATUS <> DECODE(CRH.FACTOR_FLAG
                    ,'Y'
                    ,'RISK_ELIMINATED'
                    ,'CLEARED')
                AND CRH.STATUS <> 'REVERSED'
                AND CR.CURRENCY_CODE = CURRENCY1
                AND CR.PAY_FROM_CUSTOMER = CUSTOMER_ID
                AND CR.CUSTOMER_SITE_USE_ID = C_COMPUTE_AMOUNTSFORMULA.SITE_USE_ID;
            END IF;
          ELSE
            DEBUG := 64;
            SELECT
              NVL(SUM(AMOUNT_DUE_REMAINING)
                 ,0)
            INTO L_REC_BAL_PACK
            FROM
              AR_PAYMENT_SCHEDULES
            WHERE CUSTOMER_SITE_USE_ID = C_COMPUTE_AMOUNTSFORMULA.SITE_USE_ID
              AND NVL(RECEIPT_CONFIRMED_FLAG
               ,'Y') = 'Y'
              AND INVOICE_CURRENCY_CODE = CURRENCY1
              AND SYSDATE - TRX_DATE > PACK_OPEN_AR_DAYS;
            IF L_INCLUDE_RISK_FLAG2 = 'Y' THEN
              DEBUG := 65;
              SELECT
                NVL(SUM(CRH.AMOUNT)
                   ,0) + L_REC_BAL_PACK
              INTO L_REC_BAL_PACK
              FROM
                AR_CASH_RECEIPT_HISTORY CRH,
                AR_CASH_RECEIPTS CR
              WHERE CRH.CASH_RECEIPT_ID = CR.CASH_RECEIPT_ID
                AND NVL(CR.CONFIRMED_FLAG
                 ,'Y') = 'Y'
                AND CRH.CURRENT_RECORD_FLAG = 'Y'
                AND CRH.STATUS <> DECODE(CRH.FACTOR_FLAG
                    ,'Y'
                    ,'RISK_ELIMINATED'
                    ,'CLEARED')
                AND CRH.STATUS <> 'REVERSED'
                AND CR.CURRENCY_CODE = CURRENCY1
                AND CR.PAY_FROM_CUSTOMER = CUSTOMER_ID
                AND CR.CUSTOMER_SITE_USE_ID = C_COMPUTE_AMOUNTSFORMULA.SITE_USE_ID
                AND SYSDATE - CR.RECEIPT_DATE > PACK_OPEN_AR_DAYS;
            END IF;
          END IF;
        ELSE
          DEBUG := 66;
          L_REC_BAL_PACK := 0;
        END IF;
      END IF;
      C_REC_BAL_PACK := L_REC_BAL_PACK;
      IF SITE_USE_ID = 0 THEN
        IF PICK_UNINVOICED_FLAG = 'Y' THEN
          IF PICK_ON_HOLD_FLAG = 'Y' THEN
            DEBUG := 67;
            SELECT
              NVL(SUM(NVL(L.UNIT_SELLING_PRICE
                         ,0) * NVL(L.ORDERED_QUANTITY
                         ,0))
                 ,0)
            INTO L_TOTAL1_PICK
            FROM
              OE_ORDER_LINES_ALL L,
              OE_ORDER_HEADERS H,
              HZ_CUST_SITE_USES_ALL SU,
              HZ_PARTY_SITES PARTY_SITE,
              HZ_LOC_ASSIGNMENTS LOC_ASSIGN,
              HZ_LOCATIONS LOC,
              HZ_CUST_ACCT_SITES_ALL ACCT_SITE
            WHERE ACCT_SITE.CUST_ACCOUNT_ID = CUSTOMER_ID
              AND ACCT_SITE.CUST_ACCT_SITE_ID = SU.CUST_ACCT_SITE_ID
              AND ACCT_SITE.PARTY_SITE_ID = PARTY_SITE.PARTY_SITE_ID
              AND LOC.LOCATION_ID = PARTY_SITE.LOCATION_ID
              AND LOC.LOCATION_ID = LOC_ASSIGN.LOCATION_ID
              AND NVL(ACCT_SITE.ORG_ID
               ,-99) = NVL(LOC_ASSIGN.ORG_ID
               ,-99)
              AND SU.SITE_USE_ID = H.INVOICE_TO_ORG_ID
              AND H.TRANSACTIONAL_CURR_CODE = CURRENCY1
              AND L.HEADER_ID = H.HEADER_ID
              AND L.LINE_CATEGORY_CODE = 'ORDER'
              AND L.BOOKED_FLAG = 'Y'
              AND NVL(L.INVOICE_INTERFACE_STATUS_CODE
               ,'X') not in ( 'PARTIAL' , 'YES' )
              AND DECODE(PICK_SHIPPING_INTERVAL
                  ,-1
                  ,TRUNC(SYSDATE)
                  ,NVL(L.REQUEST_DATE
                     ,H.REQUEST_DATE) + PICK_SHIPPING_INTERVAL) >= TRUNC(SYSDATE);
            DEBUG := 68;
            SELECT
              NVL(SUM(NVL(L.UNIT_SELLING_PRICE
                         ,0) * (NVL(L.ORDERED_QUANTITY
                         ,0) - NVL(L.SHIPPED_QUANTITY
                         ,0)))
                 ,0)
            INTO L_TOTAL3_PICK
            FROM
              OE_ORDER_LINES_ALL L,
              OE_ORDER_HEADERS H,
              HZ_CUST_SITE_USES_ALL SU,
              HZ_PARTY_SITES PARTY_SITE,
              HZ_LOC_ASSIGNMENTS LOC_ASSIGN,
              HZ_LOCATIONS LOC,
              HZ_CUST_ACCT_SITES_ALL ACCT_SITE
            WHERE ACCT_SITE.CUST_ACCOUNT_ID = CUSTOMER_ID
              AND ACCT_SITE.CUST_ACCT_SITE_ID = SU.CUST_ACCT_SITE_ID
              AND ACCT_SITE.PARTY_SITE_ID = PARTY_SITE.PARTY_SITE_ID
              AND LOC.LOCATION_ID = PARTY_SITE.LOCATION_ID
              AND LOC.LOCATION_ID = LOC_ASSIGN.LOCATION_ID
              AND NVL(ACCT_SITE.ORG_ID
               ,-99) = NVL(LOC_ASSIGN.ORG_ID
               ,-99)
              AND SU.SITE_USE_ID = H.INVOICE_TO_ORG_ID
              AND H.TRANSACTIONAL_CURR_CODE = CURRENCY1
              AND L.HEADER_ID = H.HEADER_ID
              AND L.LINE_CATEGORY_CODE = 'ORDER'
              AND L.INVOICE_INTERFACE_STATUS_CODE = 'PARTIAL'
              AND L.BOOKED_FLAG = 'Y'
              AND DECODE(PICK_SHIPPING_INTERVAL
                  ,-1
                  ,TRUNC(SYSDATE)
                  ,NVL(L.REQUEST_DATE
                     ,H.REQUEST_DATE) + PICK_SHIPPING_INTERVAL) >= TRUNC(SYSDATE);
            L_UNINV_ORD_PICK := L_TOTAL1_PICK + L_TOTAL3_PICK;
          ELSE
            DEBUG := 69;
            SELECT
              NVL(SUM(NVL(L.UNIT_SELLING_PRICE
                         ,0) * NVL(L.ORDERED_QUANTITY
                         ,0))
                 ,0)
            INTO L_TOTAL1_PICK
            FROM
              OE_ORDER_LINES_ALL L,
              OE_ORDER_HEADERS H,
              HZ_CUST_SITE_USES_ALL SU,
              HZ_PARTY_SITES PARTY_SITE,
              HZ_LOC_ASSIGNMENTS LOC_ASSIGN,
              HZ_LOCATIONS LOC,
              HZ_CUST_ACCT_SITES_ALL ACCT_SITE
            WHERE ACCT_SITE.CUST_ACCOUNT_ID = CUSTOMER_ID
              AND ACCT_SITE.CUST_ACCT_SITE_ID = SU.CUST_ACCT_SITE_ID
              AND ACCT_SITE.PARTY_SITE_ID = PARTY_SITE.PARTY_SITE_ID
              AND LOC.LOCATION_ID = PARTY_SITE.LOCATION_ID
              AND LOC.LOCATION_ID = LOC_ASSIGN.LOCATION_ID
              AND NVL(ACCT_SITE.ORG_ID
               ,-99) = NVL(LOC_ASSIGN.ORG_ID
               ,-99)
              AND SU.SITE_USE_ID = H.INVOICE_TO_ORG_ID
              AND H.TRANSACTIONAL_CURR_CODE = CURRENCY1
              AND L.HEADER_ID = H.HEADER_ID
              AND L.LINE_CATEGORY_CODE = 'ORDER'
              AND L.BOOKED_FLAG = 'Y'
              AND NVL(L.INVOICE_INTERFACE_STATUS_CODE
               ,'X') not in ( 'PARTIAL' , 'YES' )
              AND DECODE(PICK_SHIPPING_INTERVAL
                  ,-1
                  ,TRUNC(SYSDATE)
                  ,NVL(L.REQUEST_DATE
                     ,H.REQUEST_DATE) + PICK_SHIPPING_INTERVAL) >= TRUNC(SYSDATE)
              AND not exists (
              SELECT
                'x'
              FROM
                OE_ORDER_HOLDS OH
              WHERE OH.HEADER_ID = H.HEADER_ID
                AND OH.HOLD_RELEASE_ID is null );
            DEBUG := 70;
            SELECT
              NVL(SUM(NVL(L.UNIT_SELLING_PRICE
                         ,0) * (NVL(L.ORDERED_QUANTITY
                         ,0) - NVL(L.SHIPPED_QUANTITY
                         ,0)))
                 ,0)
            INTO L_TOTAL3_PICK
            FROM
              OE_ORDER_LINES_ALL L,
              OE_ORDER_HEADERS H,
              HZ_CUST_SITE_USES_ALL SU,
              HZ_PARTY_SITES PARTY_SITE,
              HZ_LOC_ASSIGNMENTS LOC_ASSIGN,
              HZ_LOCATIONS LOC,
              HZ_CUST_ACCT_SITES_ALL ACCT_SITE
            WHERE ACCT_SITE.CUST_ACCOUNT_ID = CUSTOMER_ID
              AND ACCT_SITE.CUST_ACCT_SITE_ID = SU.CUST_ACCT_SITE_ID
              AND ACCT_SITE.PARTY_SITE_ID = PARTY_SITE.PARTY_SITE_ID
              AND LOC.LOCATION_ID = PARTY_SITE.LOCATION_ID
              AND LOC.LOCATION_ID = LOC_ASSIGN.LOCATION_ID
              AND NVL(ACCT_SITE.ORG_ID
               ,-99) = NVL(LOC_ASSIGN.ORG_ID
               ,-99)
              AND SU.SITE_USE_ID = H.INVOICE_TO_ORG_ID
              AND H.TRANSACTIONAL_CURR_CODE = CURRENCY1
              AND L.HEADER_ID = H.HEADER_ID
              AND L.LINE_CATEGORY_CODE = 'ORDER'
              AND L.INVOICE_INTERFACE_STATUS_CODE = 'PARTIAL'
              AND L.BOOKED_FLAG = 'Y'
              AND DECODE(PICK_SHIPPING_INTERVAL
                  ,-1
                  ,TRUNC(SYSDATE)
                  ,NVL(L.REQUEST_DATE
                     ,H.REQUEST_DATE) + PICK_SHIPPING_INTERVAL) >= TRUNC(SYSDATE)
              AND not exists (
              SELECT
                'x'
              FROM
                OE_ORDER_HOLDS OH
              WHERE OH.HEADER_ID = H.HEADER_ID
                AND OH.HOLD_RELEASE_ID is null );
            L_UNINV_ORD_PICK := L_TOTAL1_PICK + L_TOTAL3_PICK;
          END IF;
        ELSE
          DEBUG := 71;
          L_UNINV_ORD_PICK := 0;
        END IF;
      ELSE
        IF PICK_UNINVOICED_FLAG = 'Y' THEN
          IF PICK_ON_HOLD_FLAG = 'Y' THEN
            DEBUG := 72;
            SELECT
              NVL(SUM(NVL(L.UNIT_SELLING_PRICE
                         ,0) * NVL(L.ORDERED_QUANTITY
                         ,0))
                 ,0)
            INTO L_TOTAL1_PICK
            FROM
              OE_ORDER_LINES_ALL L,
              OE_ORDER_HEADERS H,
              HZ_CUST_SITE_USES_ALL SU,
              HZ_PARTY_SITES PARTY_SITE,
              HZ_LOC_ASSIGNMENTS LOC_ASSIGN,
              HZ_LOCATIONS LOC,
              HZ_CUST_ACCT_SITES_ALL ACCT_SITE
            WHERE H.INVOICE_TO_ORG_ID = SU.SITE_USE_ID
              AND SU.SITE_USE_ID = C_COMPUTE_AMOUNTSFORMULA.SITE_USE_ID
              AND ACCT_SITE.CUST_ACCT_SITE_ID = SU.CUST_ACCT_SITE_ID
              AND ACCT_SITE.PARTY_SITE_ID = PARTY_SITE.PARTY_SITE_ID
              AND LOC.LOCATION_ID = PARTY_SITE.LOCATION_ID
              AND LOC.LOCATION_ID = LOC_ASSIGN.LOCATION_ID
              AND NVL(ACCT_SITE.ORG_ID
               ,-99) = NVL(LOC_ASSIGN.ORG_ID
               ,-99)
              AND H.TRANSACTIONAL_CURR_CODE = CURRENCY1
              AND L.HEADER_ID = H.HEADER_ID
              AND L.LINE_CATEGORY_CODE = 'ORDER'
              AND NVL(L.INVOICE_INTERFACE_STATUS_CODE
               ,'X') not in ( 'PARTIAL' , 'YES' )
              AND L.BOOKED_FLAG = 'Y'
              AND DECODE(PICK_SHIPPING_INTERVAL
                  ,-1
                  ,TRUNC(SYSDATE)
                  ,NVL(L.REQUEST_DATE
                     ,H.REQUEST_DATE) + PICK_SHIPPING_INTERVAL) >= TRUNC(SYSDATE);
            DEBUG := 74;
            SELECT
              NVL(SUM(NVL(L.UNIT_SELLING_PRICE
                         ,0) * (NVL(L.ORDERED_QUANTITY
                         ,0) - NVL(L.SHIPPED_QUANTITY
                         ,0)))
                 ,0)
            INTO L_TOTAL3_PICK
            FROM
              OE_ORDER_LINES_ALL L,
              OE_ORDER_HEADERS H,
              HZ_CUST_SITE_USES_ALL SU,
              HZ_PARTY_SITES PARTY_SITE,
              HZ_LOC_ASSIGNMENTS LOC_ASSIGN,
              HZ_LOCATIONS LOC,
              HZ_CUST_ACCT_SITES_ALL ACCT_SITE
            WHERE SU.SITE_USE_ID = C_COMPUTE_AMOUNTSFORMULA.SITE_USE_ID
              AND ACCT_SITE.CUST_ACCT_SITE_ID = SU.CUST_ACCT_SITE_ID
              AND ACCT_SITE.PARTY_SITE_ID = PARTY_SITE.PARTY_SITE_ID
              AND LOC.LOCATION_ID = PARTY_SITE.LOCATION_ID
              AND LOC.LOCATION_ID = LOC_ASSIGN.LOCATION_ID
              AND NVL(ACCT_SITE.ORG_ID
               ,-99) = NVL(LOC_ASSIGN.ORG_ID
               ,-99)
              AND SU.SITE_USE_ID = H.INVOICE_TO_ORG_ID
              AND H.TRANSACTIONAL_CURR_CODE = CURRENCY1
              AND L.HEADER_ID = H.HEADER_ID
              AND L.LINE_CATEGORY_CODE = 'ORDER'
              AND L.INVOICE_INTERFACE_STATUS_CODE = 'PARTIAL'
              AND L.BOOKED_FLAG = 'Y'
              AND DECODE(PICK_SHIPPING_INTERVAL
                  ,-1
                  ,TRUNC(SYSDATE)
                  ,NVL(L.REQUEST_DATE
                     ,H.REQUEST_DATE) + PICK_SHIPPING_INTERVAL) >= TRUNC(SYSDATE);
            L_UNINV_ORD_PICK := L_TOTAL1_PICK + L_TOTAL3_PICK;
          ELSE
            DEBUG := 75;
            SELECT
              NVL(SUM(NVL(L.UNIT_SELLING_PRICE
                         ,0) * NVL(L.ORDERED_QUANTITY
                         ,0))
                 ,0)
            INTO L_TOTAL1_PICK
            FROM
              OE_ORDER_LINES_ALL L,
              OE_ORDER_HEADERS H,
              HZ_CUST_SITE_USES_ALL SU,
              HZ_PARTY_SITES PARTY_SITE,
              HZ_LOC_ASSIGNMENTS LOC_ASSIGN,
              HZ_LOCATIONS LOC,
              HZ_CUST_ACCT_SITES_ALL ACCT_SITE
            WHERE SU.SITE_USE_ID = C_COMPUTE_AMOUNTSFORMULA.SITE_USE_ID
              AND ACCT_SITE.CUST_ACCT_SITE_ID = SU.CUST_ACCT_SITE_ID
              AND ACCT_SITE.PARTY_SITE_ID = PARTY_SITE.PARTY_SITE_ID
              AND LOC.LOCATION_ID = PARTY_SITE.LOCATION_ID
              AND LOC.LOCATION_ID = LOC_ASSIGN.LOCATION_ID
              AND NVL(ACCT_SITE.ORG_ID
               ,-99) = NVL(LOC_ASSIGN.ORG_ID
               ,-99)
              AND SU.SITE_USE_ID = H.INVOICE_TO_ORG_ID
              AND H.TRANSACTIONAL_CURR_CODE = CURRENCY1
              AND L.HEADER_ID = H.HEADER_ID
              AND L.LINE_CATEGORY_CODE = 'ORDER'
              AND NVL(L.INVOICE_INTERFACE_STATUS_CODE
               ,'X') not in ( 'PARTIAL' , 'YES' )
              AND L.BOOKED_FLAG = 'Y'
              AND DECODE(PICK_SHIPPING_INTERVAL
                  ,-1
                  ,TRUNC(SYSDATE)
                  ,NVL(L.REQUEST_DATE
                     ,H.REQUEST_DATE) + PICK_SHIPPING_INTERVAL) >= TRUNC(SYSDATE)
              AND not exists (
              SELECT
                'x'
              FROM
                OE_ORDER_HOLDS OH
              WHERE OH.HEADER_ID = H.HEADER_ID
                AND OH.HOLD_RELEASE_ID is null );
            DEBUG := 76;
            SELECT
              NVL(SUM(NVL(L.UNIT_SELLING_PRICE
                         ,0) * (NVL(L.ORDERED_QUANTITY
                         ,0) - NVL(L.SHIPPED_QUANTITY
                         ,0)))
                 ,0)
            INTO L_TOTAL3_PICK
            FROM
              OE_ORDER_LINES_ALL L,
              OE_ORDER_HEADERS H,
              HZ_CUST_SITE_USES_ALL SU,
              HZ_PARTY_SITES PARTY_SITE,
              HZ_LOC_ASSIGNMENTS LOC_ASSIGN,
              HZ_LOCATIONS LOC,
              HZ_CUST_ACCT_SITES_ALL ACCT_SITE
            WHERE SU.SITE_USE_ID = C_COMPUTE_AMOUNTSFORMULA.SITE_USE_ID
              AND ACCT_SITE.CUST_ACCT_SITE_ID = SU.CUST_ACCT_SITE_ID
              AND ACCT_SITE.PARTY_SITE_ID = PARTY_SITE.PARTY_SITE_ID
              AND LOC.LOCATION_ID = PARTY_SITE.LOCATION_ID
              AND LOC.LOCATION_ID = LOC_ASSIGN.LOCATION_ID
              AND NVL(ACCT_SITE.ORG_ID
               ,-99) = NVL(LOC_ASSIGN.ORG_ID
               ,-99)
              AND SU.SITE_USE_ID = H.INVOICE_TO_ORG_ID
              AND H.TRANSACTIONAL_CURR_CODE = CURRENCY1
              AND L.HEADER_ID = H.HEADER_ID
              AND L.LINE_CATEGORY_CODE = 'ORDER'
              AND L.INVOICE_INTERFACE_STATUS_CODE = 'PARTIAL'
              AND L.BOOKED_FLAG = 'Y'
              AND DECODE(PICK_SHIPPING_INTERVAL
                  ,-1
                  ,TRUNC(SYSDATE)
                  ,NVL(L.REQUEST_DATE
                     ,H.REQUEST_DATE) + PICK_SHIPPING_INTERVAL) >= TRUNC(SYSDATE)
              AND not exists (
              SELECT
                'x'
              FROM
                OE_ORDER_HOLDS OH
              WHERE OH.HEADER_ID = H.HEADER_ID
                AND OH.HOLD_RELEASE_ID is null );
            L_UNINV_ORD_PICK := L_TOTAL1_PICK + L_TOTAL3_PICK;
          END IF;
        ELSE
          DEBUG := 77;
          L_UNINV_ORD_PICK := 0;
        END IF;
      END IF;
      C_UNINV_ORD_PICK := L_UNINV_ORD_PICK;
      IF SITE_USE_ID = 0 THEN
        IF PACK_UNINVOICED_FLAG = 'Y' THEN
          IF PACK_ON_HOLD_FLAG = 'Y' THEN
            DEBUG := 78;
            SELECT
              NVL(SUM(NVL(L.UNIT_SELLING_PRICE
                         ,0) * NVL(L.ORDERED_QUANTITY
                         ,0))
                 ,0)
            INTO L_TOTAL1_PACK
            FROM
              OE_ORDER_LINES_ALL L,
              OE_ORDER_HEADERS H,
              HZ_CUST_SITE_USES_ALL SU,
              HZ_PARTY_SITES PARTY_SITE,
              HZ_LOC_ASSIGNMENTS LOC_ASSIGN,
              HZ_LOCATIONS LOC,
              HZ_CUST_ACCT_SITES_ALL ACCT_SITE
            WHERE ACCT_SITE.CUST_ACCOUNT_ID = CUSTOMER_ID
              AND ACCT_SITE.CUST_ACCT_SITE_ID = SU.CUST_ACCT_SITE_ID
              AND ACCT_SITE.PARTY_SITE_ID = PARTY_SITE.PARTY_SITE_ID
              AND LOC.LOCATION_ID = PARTY_SITE.LOCATION_ID
              AND LOC.LOCATION_ID = LOC_ASSIGN.LOCATION_ID
              AND NVL(ACCT_SITE.ORG_ID
               ,-99) = NVL(LOC_ASSIGN.ORG_ID
               ,-99)
              AND SU.SITE_USE_ID = H.INVOICE_TO_ORG_ID
              AND H.TRANSACTIONAL_CURR_CODE = CURRENCY1
              AND L.HEADER_ID = H.HEADER_ID
              AND L.LINE_CATEGORY_CODE = 'ORDER'
              AND L.BOOKED_FLAG = 'Y'
              AND NVL(L.INVOICE_INTERFACE_STATUS_CODE
               ,'X') not in ( 'PARTIAL' , 'YES' )
              AND DECODE(PACK_SHIPPING_INTERVAL
                  ,-1
                  ,TRUNC(SYSDATE)
                  ,NVL(L.REQUEST_DATE
                     ,H.REQUEST_DATE) + PACK_SHIPPING_INTERVAL) >= TRUNC(SYSDATE);
            DEBUG := 79;
            SELECT
              NVL(SUM(NVL(L.UNIT_SELLING_PRICE
                         ,0) * (NVL(L.ORDERED_QUANTITY
                         ,0) - NVL(L.SHIPPED_QUANTITY
                         ,0)))
                 ,0)
            INTO L_TOTAL3_PACK
            FROM
              OE_ORDER_LINES_ALL L,
              OE_ORDER_HEADERS H,
              HZ_CUST_SITE_USES_ALL SU,
              HZ_PARTY_SITES PARTY_SITE,
              HZ_LOC_ASSIGNMENTS LOC_ASSIGN,
              HZ_LOCATIONS LOC,
              HZ_CUST_ACCT_SITES_ALL ACCT_SITE
            WHERE ACCT_SITE.CUST_ACCOUNT_ID = CUSTOMER_ID
              AND ACCT_SITE.CUST_ACCT_SITE_ID = SU.CUST_ACCT_SITE_ID
              AND ACCT_SITE.PARTY_SITE_ID = PARTY_SITE.PARTY_SITE_ID
              AND LOC.LOCATION_ID = PARTY_SITE.LOCATION_ID
              AND LOC.LOCATION_ID = LOC_ASSIGN.LOCATION_ID
              AND NVL(ACCT_SITE.ORG_ID
               ,-99) = NVL(LOC_ASSIGN.ORG_ID
               ,-99)
              AND SU.SITE_USE_ID = H.INVOICE_TO_ORG_ID
              AND H.TRANSACTIONAL_CURR_CODE = CURRENCY1
              AND L.HEADER_ID = H.HEADER_ID
              AND L.LINE_CATEGORY_CODE = 'ORDER'
              AND L.INVOICE_INTERFACE_STATUS_CODE = 'PARTIAL'
              AND L.BOOKED_FLAG = 'Y'
              AND DECODE(PACK_SHIPPING_INTERVAL
                  ,-1
                  ,TRUNC(SYSDATE)
                  ,NVL(L.REQUEST_DATE
                     ,H.REQUEST_DATE) + PACK_SHIPPING_INTERVAL) >= TRUNC(SYSDATE);
            L_UNINV_ORD_PACK := L_TOTAL1_PACK + L_TOTAL3_PACK;
          ELSE
            DEBUG := 80;
            SELECT
              NVL(SUM(NVL(L.UNIT_SELLING_PRICE
                         ,0) * NVL(L.ORDERED_QUANTITY
                         ,0))
                 ,0)
            INTO L_TOTAL1_PACK
            FROM
              OE_ORDER_LINES_ALL L,
              OE_ORDER_HEADERS H,
              HZ_CUST_SITE_USES_ALL SU,
              HZ_PARTY_SITES PARTY_SITE,
              HZ_LOC_ASSIGNMENTS LOC_ASSIGN,
              HZ_LOCATIONS LOC,
              HZ_CUST_ACCT_SITES_ALL ACCT_SITE
            WHERE ACCT_SITE.CUST_ACCOUNT_ID = CUSTOMER_ID
              AND ACCT_SITE.CUST_ACCT_SITE_ID = SU.CUST_ACCT_SITE_ID
              AND ACCT_SITE.PARTY_SITE_ID = PARTY_SITE.PARTY_SITE_ID
              AND LOC.LOCATION_ID = PARTY_SITE.LOCATION_ID
              AND LOC.LOCATION_ID = LOC_ASSIGN.LOCATION_ID
              AND NVL(ACCT_SITE.ORG_ID
               ,-99) = NVL(LOC_ASSIGN.ORG_ID
               ,-99)
              AND SU.SITE_USE_ID = H.INVOICE_TO_ORG_ID
              AND H.TRANSACTIONAL_CURR_CODE = CURRENCY1
              AND L.HEADER_ID = H.HEADER_ID
              AND L.LINE_CATEGORY_CODE = 'ORDER'
              AND L.BOOKED_FLAG = 'Y'
              AND NVL(L.INVOICE_INTERFACE_STATUS_CODE
               ,'X') not in ( 'PARTIAL' , 'YES' )
              AND DECODE(PACK_SHIPPING_INTERVAL
                  ,-1
                  ,TRUNC(SYSDATE)
                  ,NVL(L.REQUEST_DATE
                     ,H.REQUEST_DATE) + PACK_SHIPPING_INTERVAL) >= TRUNC(SYSDATE)
              AND not exists (
              SELECT
                'x'
              FROM
                OE_ORDER_HOLDS OH
              WHERE OH.HEADER_ID = H.HEADER_ID
                AND OH.HOLD_RELEASE_ID is null );
            DEBUG := 81;
            SELECT
              NVL(SUM(NVL(L.UNIT_SELLING_PRICE
                         ,0) * (NVL(L.ORDERED_QUANTITY
                         ,0) - NVL(L.SHIPPED_QUANTITY
                         ,0)))
                 ,0)
            INTO L_TOTAL3_PACK
            FROM
              OE_ORDER_LINES_ALL L,
              OE_ORDER_HEADERS H,
              HZ_CUST_SITE_USES_ALL SU,
              HZ_PARTY_SITES PARTY_SITE,
              HZ_LOC_ASSIGNMENTS LOC_ASSIGN,
              HZ_LOCATIONS LOC,
              HZ_CUST_ACCT_SITES_ALL ACCT_SITE
            WHERE ACCT_SITE.CUST_ACCOUNT_ID = CUSTOMER_ID
              AND ACCT_SITE.CUST_ACCT_SITE_ID = SU.CUST_ACCT_SITE_ID
              AND ACCT_SITE.PARTY_SITE_ID = PARTY_SITE.PARTY_SITE_ID
              AND LOC.LOCATION_ID = PARTY_SITE.LOCATION_ID
              AND LOC.LOCATION_ID = LOC_ASSIGN.LOCATION_ID
              AND NVL(ACCT_SITE.ORG_ID
               ,-99) = NVL(LOC_ASSIGN.ORG_ID
               ,-99)
              AND SU.SITE_USE_ID = H.INVOICE_TO_ORG_ID
              AND H.TRANSACTIONAL_CURR_CODE = CURRENCY1
              AND L.HEADER_ID = H.HEADER_ID
              AND L.LINE_CATEGORY_CODE = 'ORDER'
              AND L.INVOICE_INTERFACE_STATUS_CODE = 'PARTIAL'
              AND L.BOOKED_FLAG = 'Y'
              AND DECODE(PACK_SHIPPING_INTERVAL
                  ,-1
                  ,TRUNC(SYSDATE)
                  ,NVL(L.REQUEST_DATE
                     ,H.REQUEST_DATE) + PACK_SHIPPING_INTERVAL) >= TRUNC(SYSDATE)
              AND not exists (
              SELECT
                'x'
              FROM
                OE_ORDER_HOLDS OH
              WHERE OH.HEADER_ID = H.HEADER_ID
                AND OH.HOLD_RELEASE_ID is null );
            L_UNINV_ORD_PACK := L_TOTAL1_PACK + L_TOTAL3_PACK;
          END IF;
        ELSE
          DEBUG := 82;
          L_UNINV_ORD_PACK := 0;
        END IF;
      ELSE
        IF PACK_UNINVOICED_FLAG = 'Y' THEN
          IF PACK_ON_HOLD_FLAG = 'Y' THEN
            DEBUG := 83;
            SELECT
              NVL(SUM(NVL(L.UNIT_SELLING_PRICE
                         ,0) * NVL(L.ORDERED_QUANTITY
                         ,0))
                 ,0)
            INTO L_TOTAL1_PACK
            FROM
              OE_ORDER_LINES_ALL L,
              OE_ORDER_HEADERS H,
              HZ_CUST_SITE_USES_ALL SU,
              HZ_PARTY_SITES PARTY_SITE,
              HZ_LOC_ASSIGNMENTS LOC_ASSIGN,
              HZ_LOCATIONS LOC,
              HZ_CUST_ACCT_SITES_ALL ACCT_SITE
            WHERE H.INVOICE_TO_ORG_ID = SU.SITE_USE_ID
              AND SU.SITE_USE_ID = C_COMPUTE_AMOUNTSFORMULA.SITE_USE_ID
              AND ACCT_SITE.CUST_ACCT_SITE_ID = SU.CUST_ACCT_SITE_ID
              AND ACCT_SITE.PARTY_SITE_ID = PARTY_SITE.PARTY_SITE_ID
              AND LOC.LOCATION_ID = PARTY_SITE.LOCATION_ID
              AND LOC.LOCATION_ID = LOC_ASSIGN.LOCATION_ID
              AND NVL(ACCT_SITE.ORG_ID
               ,-99) = NVL(LOC_ASSIGN.ORG_ID
               ,-99)
              AND H.TRANSACTIONAL_CURR_CODE = CURRENCY1
              AND L.HEADER_ID = H.HEADER_ID
              AND L.LINE_CATEGORY_CODE = 'ORDER'
              AND NVL(L.INVOICE_INTERFACE_STATUS_CODE
               ,'X') not in ( 'PARTIAL' , 'YES' )
              AND L.BOOKED_FLAG = 'Y'
              AND DECODE(PACK_SHIPPING_INTERVAL
                  ,-1
                  ,TRUNC(SYSDATE)
                  ,NVL(L.REQUEST_DATE
                     ,H.REQUEST_DATE) + PACK_SHIPPING_INTERVAL) >= TRUNC(SYSDATE);
            DEBUG := 84;
            SELECT
              NVL(SUM(NVL(L.UNIT_SELLING_PRICE
                         ,0) * (NVL(L.ORDERED_QUANTITY
                         ,0) - NVL(L.SHIPPED_QUANTITY
                         ,0)))
                 ,0)
            INTO L_TOTAL3_PACK
            FROM
              OE_ORDER_LINES_ALL L,
              OE_ORDER_HEADERS H,
              HZ_CUST_SITE_USES_ALL SU,
              HZ_PARTY_SITES PARTY_SITE,
              HZ_LOC_ASSIGNMENTS LOC_ASSIGN,
              HZ_LOCATIONS LOC,
              HZ_CUST_ACCT_SITES_ALL ACCT_SITE
            WHERE SU.SITE_USE_ID = C_COMPUTE_AMOUNTSFORMULA.SITE_USE_ID
              AND ACCT_SITE.CUST_ACCT_SITE_ID = SU.CUST_ACCT_SITE_ID
              AND ACCT_SITE.PARTY_SITE_ID = PARTY_SITE.PARTY_SITE_ID
              AND LOC.LOCATION_ID = PARTY_SITE.LOCATION_ID
              AND LOC.LOCATION_ID = LOC_ASSIGN.LOCATION_ID
              AND NVL(ACCT_SITE.ORG_ID
               ,-99) = NVL(LOC_ASSIGN.ORG_ID
               ,-99)
              AND SU.SITE_USE_ID = H.INVOICE_TO_ORG_ID
              AND H.TRANSACTIONAL_CURR_CODE = CURRENCY1
              AND L.HEADER_ID = H.HEADER_ID
              AND L.LINE_CATEGORY_CODE = 'ORDER'
              AND L.INVOICE_INTERFACE_STATUS_CODE = 'PARTIAL'
              AND L.BOOKED_FLAG = 'Y'
              AND DECODE(PACK_SHIPPING_INTERVAL
                  ,-1
                  ,TRUNC(SYSDATE)
                  ,NVL(L.REQUEST_DATE
                     ,H.REQUEST_DATE) + PACK_SHIPPING_INTERVAL) >= TRUNC(SYSDATE);
            L_UNINV_ORD_PACK := L_TOTAL1_PACK + L_TOTAL3_PACK;
          ELSE
            DEBUG := 85;
            SELECT
              NVL(SUM(NVL(L.UNIT_SELLING_PRICE
                         ,0) * NVL(L.ORDERED_QUANTITY
                         ,0))
                 ,0)
            INTO L_TOTAL1_PACK
            FROM
              OE_ORDER_LINES_ALL L,
              OE_ORDER_HEADERS H,
              HZ_CUST_SITE_USES_ALL SU,
              HZ_PARTY_SITES PARTY_SITE,
              HZ_LOC_ASSIGNMENTS LOC_ASSIGN,
              HZ_LOCATIONS LOC,
              HZ_CUST_ACCT_SITES_ALL ACCT_SITE
            WHERE SU.SITE_USE_ID = C_COMPUTE_AMOUNTSFORMULA.SITE_USE_ID
              AND ACCT_SITE.CUST_ACCT_SITE_ID = SU.CUST_ACCT_SITE_ID
              AND ACCT_SITE.PARTY_SITE_ID = PARTY_SITE.PARTY_SITE_ID
              AND LOC.LOCATION_ID = PARTY_SITE.LOCATION_ID
              AND LOC.LOCATION_ID = LOC_ASSIGN.LOCATION_ID
              AND NVL(ACCT_SITE.ORG_ID
               ,-99) = NVL(LOC_ASSIGN.ORG_ID
               ,-99)
              AND SU.SITE_USE_ID = H.INVOICE_TO_ORG_ID
              AND H.TRANSACTIONAL_CURR_CODE = CURRENCY1
              AND L.HEADER_ID = H.HEADER_ID
              AND L.LINE_CATEGORY_CODE = 'ORDER'
              AND NVL(L.INVOICE_INTERFACE_STATUS_CODE
               ,'X') not in ( 'PARTIAL' , 'YES' )
              AND L.BOOKED_FLAG = 'Y'
              AND DECODE(PACK_SHIPPING_INTERVAL
                  ,-1
                  ,TRUNC(SYSDATE)
                  ,NVL(L.REQUEST_DATE
                     ,H.REQUEST_DATE) + PACK_SHIPPING_INTERVAL) >= TRUNC(SYSDATE)
              AND not exists (
              SELECT
                'x'
              FROM
                OE_ORDER_HOLDS OH
              WHERE OH.HEADER_ID = H.HEADER_ID
                AND OH.HOLD_RELEASE_ID is null );
            DEBUG := 86;
            SELECT
              NVL(SUM(NVL(L.UNIT_SELLING_PRICE
                         ,0) * (NVL(L.ORDERED_QUANTITY
                         ,0) - NVL(L.SHIPPED_QUANTITY
                         ,0)))
                 ,0)
            INTO L_TOTAL3_PACK
            FROM
              OE_ORDER_LINES_ALL L,
              OE_ORDER_HEADERS H,
              HZ_CUST_SITE_USES_ALL SU,
              HZ_PARTY_SITES PARTY_SITE,
              HZ_LOC_ASSIGNMENTS LOC_ASSIGN,
              HZ_LOCATIONS LOC,
              HZ_CUST_ACCT_SITES_ALL ACCT_SITE
            WHERE SU.SITE_USE_ID = C_COMPUTE_AMOUNTSFORMULA.SITE_USE_ID
              AND ACCT_SITE.CUST_ACCT_SITE_ID = SU.CUST_ACCT_SITE_ID
              AND ACCT_SITE.PARTY_SITE_ID = PARTY_SITE.PARTY_SITE_ID
              AND LOC.LOCATION_ID = PARTY_SITE.LOCATION_ID
              AND LOC.LOCATION_ID = LOC_ASSIGN.LOCATION_ID
              AND NVL(ACCT_SITE.ORG_ID
               ,-99) = NVL(LOC_ASSIGN.ORG_ID
               ,-99)
              AND SU.SITE_USE_ID = H.INVOICE_TO_ORG_ID
              AND H.TRANSACTIONAL_CURR_CODE = CURRENCY1
              AND L.HEADER_ID = H.HEADER_ID
              AND L.LINE_CATEGORY_CODE = 'ORDER'
              AND L.INVOICE_INTERFACE_STATUS_CODE = 'PARTIAL'
              AND L.BOOKED_FLAG = 'Y'
              AND DECODE(PACK_SHIPPING_INTERVAL
                  ,-1
                  ,TRUNC(SYSDATE)
                  ,NVL(L.REQUEST_DATE
                     ,H.REQUEST_DATE) + PACK_SHIPPING_INTERVAL) >= TRUNC(SYSDATE)
              AND not exists (
              SELECT
                'x'
              FROM
                OE_ORDER_HOLDS OH
              WHERE OH.HEADER_ID = H.HEADER_ID
                AND OH.HOLD_RELEASE_ID is null );
            L_UNINV_ORD_PACK := L_TOTAL1_PACK + L_TOTAL3_PACK;
          END IF;
        ELSE
          DEBUG := 87;
          L_UNINV_ORD_PACK := 0;
        END IF;
      END IF;
      C_UNINV_ORD_PACK := L_UNINV_ORD_PACK;
      RETURN (0);
    EXCEPTION
      WHEN OTHERS THEN
        /*SRW.MESSAGE(1000
                   ,'debug: ' || TO_CHAR(DEBUG))*/NULL;
        /*SRW.MESSAGE(1000
                   ,SQLCODE || '    ' || SQLERRM)*/NULL;
        RETURN (0);
    END;
    RETURN NULL;
  END C_COMPUTE_AMOUNTSFORMULA;

  FUNCTION C_DATA_NOT_FOUNDFORMULA(CUSTOMER_NAME IN VARCHAR2) RETURN NUMBER IS
  BEGIN
    RP_DATA_FOUND := CUSTOMER_NAME;
    RETURN (0);
  END C_DATA_NOT_FOUNDFORMULA;

  FUNCTION C_ADDRESSFORMULA(ADDRESS1 IN VARCHAR2
                           ,CITY IN VARCHAR2
                           ,STATE IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    /*SRW.REFERENCE(ADDRESS1)*/NULL;
    /*SRW.REFERENCE(CITY)*/NULL;
    /*SRW.REFERENCE(STATE)*/NULL;
    IF ADDRESS1 IS NOT NULL THEN
      RETURN (ADDRESS1 || ' , ' || CITY || ' , ' || STATE);
    ELSE
      RETURN (NULL);
    END IF;
    RETURN NULL;
  END C_ADDRESSFORMULA;

  FUNCTION C_DAYS_ON_HOLD_CRFORMULA(S_DAYS_ON_HOLD_CR IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (ROUND(S_DAYS_ON_HOLD_CR
                ,0));
  END C_DAYS_ON_HOLD_CRFORMULA;

  FUNCTION C_DAYS_ON_HOLD_CUFORMULA(S_DAYS_ON_HOLD_CU IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (ROUND(S_DAYS_ON_HOLD_CU
                ,0));
  END C_DAYS_ON_HOLD_CUFORMULA;

  FUNCTION C_UNINV_ORD_SHIP_P RETURN NUMBER IS
  BEGIN
    RETURN C_UNINV_ORD_SHIP;
  END C_UNINV_ORD_SHIP_P;

  FUNCTION C_UNINV_ORD_CREDIT_P RETURN NUMBER IS
  BEGIN
    RETURN C_UNINV_ORD_CREDIT;
  END C_UNINV_ORD_CREDIT_P;

  FUNCTION C_REC_BAL_SHIP_P RETURN NUMBER IS
  BEGIN
    RETURN C_REC_BAL_SHIP;
  END C_REC_BAL_SHIP_P;

  FUNCTION C_REC_BAL_CREDIT_P RETURN NUMBER IS
  BEGIN
    RETURN C_REC_BAL_CREDIT;
  END C_REC_BAL_CREDIT_P;

  FUNCTION C_TOT_ORDER_LIMIT_P RETURN NUMBER IS
  BEGIN
    RETURN C_TOT_ORDER_LIMIT;
  END C_TOT_ORDER_LIMIT_P;

  FUNCTION C_ORDER_LIMIT_P RETURN NUMBER IS
  BEGIN
    RETURN C_ORDER_LIMIT;
  END C_ORDER_LIMIT_P;

  FUNCTION C_REC_BAL_PICK_P RETURN NUMBER IS
  BEGIN
    RETURN C_REC_BAL_PICK;
  END C_REC_BAL_PICK_P;

  FUNCTION C_REC_BAL_PACK_P RETURN NUMBER IS
  BEGIN
    RETURN C_REC_BAL_PACK;
  END C_REC_BAL_PACK_P;

  FUNCTION C_UNINV_ORD_PICK_P RETURN NUMBER IS
  BEGIN
    RETURN C_UNINV_ORD_PICK;
  END C_UNINV_ORD_PICK_P;

  FUNCTION C_UNINV_ORD_PACK_P RETURN NUMBER IS
  BEGIN
    RETURN C_UNINV_ORD_PACK;
  END C_UNINV_ORD_PACK_P;

  FUNCTION RP_REPORT_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_REPORT_NAME;
  END RP_REPORT_NAME_P;

  FUNCTION RP_SUB_TITLE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_SUB_TITLE;
  END RP_SUB_TITLE_P;

  FUNCTION RP_COMPANY_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_COMPANY_NAME;
  END RP_COMPANY_NAME_P;

  FUNCTION RP_FUNCTIONAL_CURRENCY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_FUNCTIONAL_CURRENCY;
  END RP_FUNCTIONAL_CURRENCY_P;

  FUNCTION RP_DATA_FOUND_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_DATA_FOUND;
  END RP_DATA_FOUND_P;

  FUNCTION RP_DATE_HOLD_APPLIED_RANGE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_DATE_HOLD_APPLIED_RANGE;
  END RP_DATE_HOLD_APPLIED_RANGE_P;

  FUNCTION RP_SHIP_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_SHIP;
  END RP_SHIP_P;

  FUNCTION RP_ORDER_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_ORDER;
  END RP_ORDER_P;

  FUNCTION RP_VAT_PROFILE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_VAT_PROFILE;
  END RP_VAT_PROFILE_P;

  FUNCTION RP_CURR_PROFILE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_CURR_PROFILE;
  END RP_CURR_PROFILE_P;

  FUNCTION RP_ORDER_AMOUNT_P RETURN NUMBER IS
  BEGIN
    RETURN RP_ORDER_AMOUNT;
  END RP_ORDER_AMOUNT_P;

  FUNCTION RP_TOTAL_AMOUNT_P RETURN NUMBER IS
  BEGIN
    RETURN RP_TOTAL_AMOUNT;
  END RP_TOTAL_AMOUNT_P;

  FUNCTION RP_PICK_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_PICK;
  END RP_PICK_P;

  FUNCTION RP_PACK_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_PACK;
  END RP_PACK_P;

  FUNCTION ORDER_AMOUNT_DSPFORMULA( currency1 in varchar2,order_amount in number) RETURN VARCHAR2 IS
  BEGIN

	--Bug 3466261 Starts
	declare
	L_STD_PRECISION NUMBER;
	L_EXT_PRECISION NUMBER;
	L_MIN_ACCT_UNIT NUMBER;
	L_ORDER_AMT NUMBER;
	begin
	/*SRW.REFERENCE(:RP_CURR_PROFILE);
	SRW.REFERENCE(:RP_ORDER_AMOUNT);
	srw.reference (:currency1);
	srw.reference (:order_amount);*/

	L_ORDER_AMT := order_amount;

	FND_CURRENCY_CACHE.GET_INFO(currency1,L_STD_PRECISION,L_EXT_PRECISION,L_MIN_ACCT_UNIT);


	IF( RP_CURR_PROFILE = 'EXTENDED' ) THEN
		L_ORDER_AMT := ROUND(L_ORDER_AMT,L_EXT_PRECISION);
	ELSE
		L_ORDER_AMT := ROUND(L_ORDER_AMT,L_STD_PRECISION);
	END IF;
	RP_ORDER_AMOUNT := L_ORDER_AMT;

	EXCEPTION
	WHEN OTHERS THEN
	 RP_ORDER_AMOUNT := order_amount;
	END;
	--Bug 3466261 End

	/* srw.user_exit (
			 'FND FORMAT_CURRENCY
			  CODE=":currency1"
			  DISPLAY_WIDTH="17"
			  AMOUNT=":RP_ORDER_AMOUNT"
			  DISPLAY=":order_amount_dsp"
			  ');*/
	RETURN (RP_ORDER_AMOUNT);

END;

FUNCTION S_ORDER_AMOUNT_CR_DSPFORMULA(currency1 in varchar2, s_order_amount_cr in number ) RETURN VARCHAR2 IS
BEGIN

	--Bug 3466261 Starts
	declare
	L_STD_PRECISION NUMBER;
	L_EXT_PRECISION NUMBER;
	L_MIN_ACCT_UNIT NUMBER;
	L_TOTAL_AMT NUMBER;
	begin
	/*SRW.REFERENCE(:RP_CURR_PROFILE);
	SRW.REFERENCE(:RP_TOTAL_AMOUNT);
	srw.reference (:currency1);
	srw.reference (:s_order_amount_cr);*/

	L_TOTAL_AMT := s_order_amount_cr;

	FND_CURRENCY_CACHE.GET_INFO(currency1,L_STD_PRECISION,L_EXT_PRECISION,L_MIN_ACCT_UNIT);

	IF( RP_CURR_PROFILE = 'EXTENDED' ) THEN
		L_TOTAL_AMT := ROUND(L_TOTAL_AMT,L_EXT_PRECISION);
	ELSE
		L_TOTAL_AMT := ROUND(L_TOTAL_AMT,L_STD_PRECISION);
	END IF;
	RP_TOTAL_AMOUNT := L_TOTAL_AMT;

	EXCEPTION
	WHEN OTHERS THEN
	 RP_TOTAL_AMOUNT := s_order_amount_cr;
	END;
	--Bug 3466261 End

	 /*srw.user_exit (
			 'FND FORMAT_CURRENCY
			  CODE=":currency1"
			  DISPLAY_WIDTH="17"
			  AMOUNT=":RP_TOTAL_AMOUNT"
			  DISPLAY=":s_order_amount_cr_dsp"
			  ');*/
	RETURN (RP_TOTAL_AMOUNT);

END;



END ONT_OEXOECCH_XMLP_PKG;


/
