--------------------------------------------------------
--  DDL for Package Body JA_JAINSTAC_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JA_JAINSTAC_XMLP_PKG" AS
/* $Header: JAINSTACB.pls 120.1 2007/12/25 16:29:38 dwkrishn noship $ */
  FUNCTION BALANCE(DT1 IN DATE
                  ,DT2 IN DATE
                  ,VEND_ID IN NUMBER) RETURN NUMBER IS
    V_AMOUNT NUMBER;
    LV_PREPAYMENT AP_INVOICES_ALL.INVOICE_TYPE_LOOKUP_CODE%TYPE;
  BEGIN
    LV_PREPAYMENT := 'PREPAYMENT';
    SELECT
      SUM((API.INVOICE_AMOUNT - NVL(AMOUNT_PAID
             ,0)) * NVL(EXCHANGE_RATE
             ,1)) AMOUNT
    INTO V_AMOUNT
    FROM
      AP_INVOICES_ALL API
    WHERE API.VENDOR_ID = VEND_ID
      AND TRUNC(API.INVOICE_DATE) BETWEEN TRUNC(DT1)
      AND TRUNC(DT2)
      AND API.PAYMENT_STATUS_FLAG IN ( 'N' , 'P' )
      AND API.INVOICE_TYPE_LOOKUP_CODE <> LV_PREPAYMENT
      AND ( API.ORG_ID = P_ORG_ID
    OR API.ORG_ID IS NULL );
    RETURN (NVL(V_AMOUNT
              ,0));
  END BALANCE;

  FUNCTION FINAL_BALANCE(DT IN DATE
                        ,VEND_ID IN NUMBER) RETURN NUMBER IS
    V_AMOUNT NUMBER;
  BEGIN
    SELECT
      SUM((API.INVOICE_AMOUNT - NVL(AMOUNT_PAID
             ,0)) * NVL(EXCHANGE_RATE
             ,1)) AMOUNT
    INTO V_AMOUNT
    FROM
      AP_INVOICES_ALL API
    WHERE API.VENDOR_ID = VEND_ID
      AND TRUNC(API.INVOICE_DATE) < TRUNC(DT)
      AND API.PAYMENT_STATUS_FLAG IN ( 'N' , 'P' )
      AND API.INVOICE_TYPE_LOOKUP_CODE <> 'PREPAYMENT'
      AND ( API.ORG_ID = P_ORG_ID
    OR API.ORG_ID IS NULL );
    RETURN (NVL(V_AMOUNT
              ,0));
  END FINAL_BALANCE;

  FUNCTION CF_AGE2FORMULA(VENDOR_ID IN NUMBER) RETURN NUMBER IS
  BEGIN
    P_AGE1 := SYSDATE - P_AGING_INTERVAL_DAYS;
    P_AGE1_AMOUNT := BALANCE(P_AGE1
                            ,SYSDATE
                            ,VENDOR_ID);
    IF P_NO_OF_INTERVALS = 2 THEN
      P_AGE13 := SYSDATE - P_AGING_INTERVAL_DAYS;
      P_AGE13_AMOUNT := FINAL_BALANCE(P_AGE13
                                     ,VENDOR_ID);
    ELSIF P_NO_OF_INTERVALS = 3 THEN
      P_AGE2 := SYSDATE - 2 * P_AGING_INTERVAL_DAYS;
      P_AGE2_AMOUNT := BALANCE(P_AGE2
                              ,P_AGE1 - 1
                              ,VENDOR_ID);
      P_AGE13 := SYSDATE - 2 * P_AGING_INTERVAL_DAYS;
      P_AGE13_AMOUNT := FINAL_BALANCE(P_AGE13
                                     ,VENDOR_ID);
    ELSIF P_NO_OF_INTERVALS = 4 THEN
      P_AGE2 := SYSDATE - 2 * P_AGING_INTERVAL_DAYS;
      P_AGE2_AMOUNT := BALANCE(P_AGE2
                              ,P_AGE1 - 1
                              ,VENDOR_ID);
      P_AGE3 := SYSDATE - 3 * P_AGING_INTERVAL_DAYS;
      P_AGE3_AMOUNT := BALANCE(P_AGE3
                              ,P_AGE2 - 1
                              ,VENDOR_ID);
      P_AGE13 := SYSDATE - 3 * P_AGING_INTERVAL_DAYS;
      P_AGE13_AMOUNT := FINAL_BALANCE(P_AGE13
                                     ,VENDOR_ID);
    ELSIF P_NO_OF_INTERVALS = 5 THEN
      P_AGE2 := SYSDATE - 2 * P_AGING_INTERVAL_DAYS;
      P_AGE2_AMOUNT := BALANCE(P_AGE2
                              ,P_AGE1 - 1
                              ,VENDOR_ID);
      P_AGE3 := SYSDATE - 3 * P_AGING_INTERVAL_DAYS;
      P_AGE3_AMOUNT := BALANCE(P_AGE3
                              ,P_AGE2 - 1
                              ,VENDOR_ID);
      P_AGE4 := SYSDATE - 4 * P_AGING_INTERVAL_DAYS;
      P_AGE4_AMOUNT := BALANCE(P_AGE4
                              ,P_AGE3 - 1
                              ,VENDOR_ID);
      P_AGE13 := SYSDATE - 4 * P_AGING_INTERVAL_DAYS;
      P_AGE13_AMOUNT := FINAL_BALANCE(P_AGE13 - 1
                                     ,VENDOR_ID);
    ELSIF P_NO_OF_INTERVALS = 6 THEN
      P_AGE2 := SYSDATE - 2 * P_AGING_INTERVAL_DAYS;
      P_AGE2_AMOUNT := BALANCE(P_AGE2
                              ,P_AGE1 - 1
                              ,VENDOR_ID);
      P_AGE3 := SYSDATE - 3 * P_AGING_INTERVAL_DAYS;
      P_AGE3_AMOUNT := BALANCE(P_AGE3
                              ,P_AGE2 - 1
                              ,VENDOR_ID);
      P_AGE4 := SYSDATE - 4 * P_AGING_INTERVAL_DAYS;
      P_AGE4_AMOUNT := BALANCE(P_AGE4
                              ,P_AGE3 - 1
                              ,VENDOR_ID);
      P_AGE5 := SYSDATE - 5 * P_AGING_INTERVAL_DAYS;
      P_AGE5_AMOUNT := BALANCE(P_AGE5
                              ,P_AGE4 - 1
                              ,VENDOR_ID);
      P_AGE13 := SYSDATE - 5 * P_AGING_INTERVAL_DAYS;
      P_AGE13_AMOUNT := FINAL_BALANCE(P_AGE13
                                     ,VENDOR_ID);
    ELSIF P_NO_OF_INTERVALS = 7 THEN
      P_AGE2 := SYSDATE - 2 * P_AGING_INTERVAL_DAYS;
      P_AGE2_AMOUNT := BALANCE(P_AGE2
                              ,P_AGE1 - 1
                              ,VENDOR_ID);
      P_AGE3 := SYSDATE - 3 * P_AGING_INTERVAL_DAYS;
      P_AGE3_AMOUNT := BALANCE(P_AGE3
                              ,P_AGE2 - 1
                              ,VENDOR_ID);
      P_AGE4 := SYSDATE - 4 * P_AGING_INTERVAL_DAYS;
      P_AGE4_AMOUNT := BALANCE(P_AGE4
                              ,P_AGE3 - 1
                              ,VENDOR_ID);
      P_AGE5 := SYSDATE - 5 * P_AGING_INTERVAL_DAYS;
      P_AGE5_AMOUNT := BALANCE(P_AGE5
                              ,P_AGE4 - 1
                              ,VENDOR_ID);
      P_AGE6 := SYSDATE - 6 * P_AGING_INTERVAL_DAYS;
      P_AGE6_AMOUNT := BALANCE(P_AGE6
                              ,P_AGE5 - 1
                              ,VENDOR_ID);
      P_AGE13 := SYSDATE - 6 * P_AGING_INTERVAL_DAYS;
      P_AGE13_AMOUNT := FINAL_BALANCE(P_AGE13
                                     ,VENDOR_ID);
    ELSIF P_NO_OF_INTERVALS = 8 THEN
      P_AGE2 := SYSDATE - 2 * P_AGING_INTERVAL_DAYS;
      P_AGE2_AMOUNT := BALANCE(P_AGE2
                              ,P_AGE1 - 1
                              ,VENDOR_ID);
      P_AGE3 := SYSDATE - 3 * P_AGING_INTERVAL_DAYS;
      P_AGE3_AMOUNT := BALANCE(P_AGE3
                              ,P_AGE2 - 1
                              ,VENDOR_ID);
      P_AGE4 := SYSDATE - 4 * P_AGING_INTERVAL_DAYS;
      P_AGE4_AMOUNT := BALANCE(P_AGE4
                              ,P_AGE3 - 1
                              ,VENDOR_ID);
      P_AGE5 := SYSDATE - 5 * P_AGING_INTERVAL_DAYS;
      P_AGE5_AMOUNT := BALANCE(P_AGE5
                              ,P_AGE4 - 1
                              ,VENDOR_ID);
      P_AGE6 := SYSDATE - 6 * P_AGING_INTERVAL_DAYS;
      P_AGE6_AMOUNT := BALANCE(P_AGE6
                              ,P_AGE5 - 1
                              ,VENDOR_ID);
      P_AGE7 := SYSDATE - 7 * P_AGING_INTERVAL_DAYS;
      P_AGE7_AMOUNT := BALANCE(P_AGE7
                              ,P_AGE6 - 1
                              ,VENDOR_ID);
      P_AGE13 := SYSDATE - 7 * P_AGING_INTERVAL_DAYS;
      P_AGE13_AMOUNT := FINAL_BALANCE(P_AGE13
                                     ,VENDOR_ID);
    ELSIF P_NO_OF_INTERVALS = 9 THEN
      P_AGE2 := SYSDATE - 2 * P_AGING_INTERVAL_DAYS;
      P_AGE2_AMOUNT := BALANCE(P_AGE2
                              ,P_AGE1 - 1
                              ,VENDOR_ID);
      P_AGE3 := SYSDATE - 3 * P_AGING_INTERVAL_DAYS;
      P_AGE3_AMOUNT := BALANCE(P_AGE3
                              ,P_AGE2 - 1
                              ,VENDOR_ID);
      P_AGE4 := SYSDATE - 4 * P_AGING_INTERVAL_DAYS;
      P_AGE4_AMOUNT := BALANCE(P_AGE4
                              ,P_AGE3 - 1
                              ,VENDOR_ID);
      P_AGE5 := SYSDATE - 5 * P_AGING_INTERVAL_DAYS;
      P_AGE5_AMOUNT := BALANCE(P_AGE5
                              ,P_AGE4 - 1
                              ,VENDOR_ID);
      P_AGE6 := SYSDATE - 6 * P_AGING_INTERVAL_DAYS;
      P_AGE6_AMOUNT := BALANCE(P_AGE6
                              ,P_AGE5 - 1
                              ,VENDOR_ID);
      P_AGE7 := SYSDATE - 7 * P_AGING_INTERVAL_DAYS;
      P_AGE7_AMOUNT := BALANCE(P_AGE7
                              ,P_AGE6 - 1
                              ,VENDOR_ID);
      P_AGE8 := SYSDATE - 8 * P_AGING_INTERVAL_DAYS;
      P_AGE8_AMOUNT := BALANCE(P_AGE8
                              ,P_AGE7 - 1
                              ,VENDOR_ID);
      P_AGE13 := SYSDATE - 8 * P_AGING_INTERVAL_DAYS;
      P_AGE13_AMOUNT := FINAL_BALANCE(P_AGE13
                                     ,VENDOR_ID);
    ELSIF P_NO_OF_INTERVALS = 10 THEN
      P_AGE2 := SYSDATE - 2 * P_AGING_INTERVAL_DAYS;
      P_AGE2_AMOUNT := BALANCE(P_AGE2
                              ,P_AGE1 - 1
                              ,VENDOR_ID);
      P_AGE3 := SYSDATE - 3 * P_AGING_INTERVAL_DAYS;
      P_AGE3_AMOUNT := BALANCE(P_AGE3
                              ,P_AGE2 - 1
                              ,VENDOR_ID);
      P_AGE4 := SYSDATE - 4 * P_AGING_INTERVAL_DAYS;
      P_AGE4_AMOUNT := BALANCE(P_AGE4
                              ,P_AGE3 - 1
                              ,VENDOR_ID);
      P_AGE5 := SYSDATE - 5 * P_AGING_INTERVAL_DAYS;
      P_AGE5_AMOUNT := BALANCE(P_AGE5
                              ,P_AGE4 - 1
                              ,VENDOR_ID);
      P_AGE6 := SYSDATE - 6 * P_AGING_INTERVAL_DAYS;
      P_AGE6_AMOUNT := BALANCE(P_AGE6
                              ,P_AGE5 - 1
                              ,VENDOR_ID);
      P_AGE7 := SYSDATE - 7 * P_AGING_INTERVAL_DAYS;
      P_AGE7_AMOUNT := BALANCE(P_AGE7
                              ,P_AGE6 - 1
                              ,VENDOR_ID);
      P_AGE8 := SYSDATE - 8 * P_AGING_INTERVAL_DAYS;
      P_AGE8_AMOUNT := BALANCE(P_AGE8
                              ,P_AGE7 - 1
                              ,VENDOR_ID);
      P_AGE9 := SYSDATE - 9 * P_AGING_INTERVAL_DAYS;
      P_AGE9_AMOUNT := BALANCE(P_AGE9
                              ,P_AGE8 - 1
                              ,VENDOR_ID);
      P_AGE13 := SYSDATE - 9 * P_AGING_INTERVAL_DAYS;
      P_AGE13_AMOUNT := FINAL_BALANCE(P_AGE13 - 1
                                     ,VENDOR_ID);
    ELSIF P_NO_OF_INTERVALS = 11 THEN
      P_AGE2 := SYSDATE - 2 * P_AGING_INTERVAL_DAYS;
      P_AGE2_AMOUNT := BALANCE(P_AGE2
                              ,P_AGE1 - 1
                              ,VENDOR_ID);
      P_AGE3 := SYSDATE - 3 * P_AGING_INTERVAL_DAYS;
      P_AGE3_AMOUNT := BALANCE(P_AGE3
                              ,P_AGE2 - 1
                              ,VENDOR_ID);
      P_AGE4 := SYSDATE - 4 * P_AGING_INTERVAL_DAYS;
      P_AGE4_AMOUNT := BALANCE(P_AGE4
                              ,P_AGE3 - 1
                              ,VENDOR_ID);
      P_AGE5 := SYSDATE - 5 * P_AGING_INTERVAL_DAYS;
      P_AGE5_AMOUNT := BALANCE(P_AGE5
                              ,P_AGE4 - 1
                              ,VENDOR_ID);
      P_AGE6 := SYSDATE - 6 * P_AGING_INTERVAL_DAYS;
      P_AGE6_AMOUNT := BALANCE(P_AGE6
                              ,P_AGE5 - 1
                              ,VENDOR_ID);
      P_AGE7 := SYSDATE - 7 * P_AGING_INTERVAL_DAYS;
      P_AGE7_AMOUNT := BALANCE(P_AGE7
                              ,P_AGE6 - 1
                              ,VENDOR_ID);
      P_AGE8 := SYSDATE - 8 * P_AGING_INTERVAL_DAYS;
      P_AGE8_AMOUNT := BALANCE(P_AGE8
                              ,P_AGE7 - 1
                              ,VENDOR_ID);
      P_AGE9 := SYSDATE - 9 * P_AGING_INTERVAL_DAYS;
      P_AGE9_AMOUNT := BALANCE(P_AGE9
                              ,P_AGE8 - 1
                              ,VENDOR_ID);
      P_AGE10 := SYSDATE - 10 * P_AGING_INTERVAL_DAYS;
      P_AGE10_AMOUNT := BALANCE(P_AGE10
                               ,P_AGE9 - 1
                               ,VENDOR_ID);
      P_AGE13 := SYSDATE - 10 * P_AGING_INTERVAL_DAYS;
      P_AGE13_AMOUNT := FINAL_BALANCE(P_AGE13
                                     ,VENDOR_ID);
    ELSIF P_NO_OF_INTERVALS = 12 THEN
      P_AGE2 := SYSDATE - 2 * P_AGING_INTERVAL_DAYS;
      P_AGE2_AMOUNT := BALANCE(P_AGE2
                              ,P_AGE1 - 1
                              ,VENDOR_ID);
      P_AGE3 := SYSDATE - 3 * P_AGING_INTERVAL_DAYS;
      P_AGE3_AMOUNT := BALANCE(P_AGE3
                              ,P_AGE2 - 1
                              ,VENDOR_ID);
      P_AGE4 := SYSDATE - 4 * P_AGING_INTERVAL_DAYS;
      P_AGE4_AMOUNT := BALANCE(P_AGE4
                              ,P_AGE3 - 1
                              ,VENDOR_ID);
      P_AGE5 := SYSDATE - 5 * P_AGING_INTERVAL_DAYS;
      P_AGE5_AMOUNT := BALANCE(P_AGE5
                              ,P_AGE4 - 1
                              ,VENDOR_ID);
      P_AGE6 := SYSDATE - 6 * P_AGING_INTERVAL_DAYS;
      P_AGE6_AMOUNT := BALANCE(P_AGE6
                              ,P_AGE5 - 1
                              ,VENDOR_ID);
      P_AGE7 := SYSDATE - 7 * P_AGING_INTERVAL_DAYS;
      P_AGE7_AMOUNT := BALANCE(P_AGE7
                              ,P_AGE6 - 1
                              ,VENDOR_ID);
      P_AGE8 := SYSDATE - 8 * P_AGING_INTERVAL_DAYS;
      P_AGE8_AMOUNT := BALANCE(P_AGE8
                              ,P_AGE7 - 1
                              ,VENDOR_ID);
      P_AGE9 := SYSDATE - 9 * P_AGING_INTERVAL_DAYS;
      P_AGE9_AMOUNT := BALANCE(P_AGE9
                              ,P_AGE8 - 1
                              ,VENDOR_ID);
      P_AGE10 := SYSDATE - 10 * P_AGING_INTERVAL_DAYS;
      P_AGE10_AMOUNT := BALANCE(P_AGE10
                               ,P_AGE9 - 1
                               ,VENDOR_ID);
      P_AGE11 := SYSDATE - 11 * P_AGING_INTERVAL_DAYS;
      P_AGE11_AMOUNT := BALANCE(P_AGE11
                               ,P_AGE10 - 1
                               ,VENDOR_ID);
      P_AGE13 := SYSDATE - 11 * P_AGING_INTERVAL_DAYS;
      P_AGE13_AMOUNT := FINAL_BALANCE(P_AGE13
                                     ,VENDOR_ID);
    ELSIF P_NO_OF_INTERVALS = 13 THEN
      P_AGE2 := SYSDATE - 2 * P_AGING_INTERVAL_DAYS;
      P_AGE2_AMOUNT := BALANCE(P_AGE2
                              ,P_AGE1 - 1
                              ,VENDOR_ID);
      P_AGE3 := SYSDATE - 3 * P_AGING_INTERVAL_DAYS;
      P_AGE3_AMOUNT := BALANCE(P_AGE3
                              ,P_AGE2 - 1
                              ,VENDOR_ID);
      P_AGE4 := SYSDATE - 4 * P_AGING_INTERVAL_DAYS;
      P_AGE4_AMOUNT := BALANCE(P_AGE4
                              ,P_AGE3 - 1
                              ,VENDOR_ID);
      P_AGE5 := SYSDATE - 5 * P_AGING_INTERVAL_DAYS;
      P_AGE5_AMOUNT := BALANCE(P_AGE5
                              ,P_AGE4 - 1
                              ,VENDOR_ID);
      P_AGE6 := SYSDATE - 6 * P_AGING_INTERVAL_DAYS;
      P_AGE6_AMOUNT := BALANCE(P_AGE6
                              ,P_AGE5 - 1
                              ,VENDOR_ID);
      P_AGE7 := SYSDATE - 7 * P_AGING_INTERVAL_DAYS;
      P_AGE7_AMOUNT := BALANCE(P_AGE7
                              ,P_AGE6 - 1
                              ,VENDOR_ID);
      P_AGE8 := SYSDATE - 8 * P_AGING_INTERVAL_DAYS;
      P_AGE8_AMOUNT := BALANCE(P_AGE8
                              ,P_AGE7 - 1
                              ,VENDOR_ID);
      P_AGE9 := SYSDATE - 9 * P_AGING_INTERVAL_DAYS;
      P_AGE9_AMOUNT := BALANCE(P_AGE9
                              ,P_AGE8 - 1
                              ,VENDOR_ID);
      P_AGE10 := SYSDATE - 10 * P_AGING_INTERVAL_DAYS;
      P_AGE10_AMOUNT := BALANCE(P_AGE10
                               ,P_AGE9 - 1
                               ,VENDOR_ID);
      P_AGE11 := SYSDATE - 11 * P_AGING_INTERVAL_DAYS;
      P_AGE11_AMOUNT := BALANCE(P_AGE11
                               ,P_AGE10 - 1
                               ,VENDOR_ID);
      P_AGE12 := SYSDATE - 12 * P_AGING_INTERVAL_DAYS;
      P_AGE12_AMOUNT := BALANCE(P_AGE12
                               ,P_AGE11 - 1
                               ,VENDOR_ID);
      P_AGE13 := SYSDATE - 12 * P_AGING_INTERVAL_DAYS;
      P_AGE13_AMOUNT := FINAL_BALANCE(P_AGE13
                                     ,VENDOR_ID);
    END IF;
    RETURN (1);
  END CF_AGE2FORMULA;

  FUNCTION CF_COMP_NAMEFORMULA(ORG_ID IN NUMBER) RETURN VARCHAR2 IS
    V_LEGAL_ENTITY NUMBER;
    V_NAME VARCHAR2(60);
  BEGIN
    SELECT
      NAME
    INTO V_NAME
    FROM
      HR_ORGANIZATION_UNITS
    WHERE NVL(ORGANIZATION_ID
       ,0) = NVL(ORG_ID
       ,0);
    RETURN (V_NAME);
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN (NULL);
  END CF_COMP_NAMEFORMULA;

  FUNCTION CF_COMP_ADDRFORMULA(ORG_ID IN NUMBER) RETURN VARCHAR2 IS
    V_LOCATION_ID NUMBER;
    V_ADDRESS VARCHAR2(1000);
    CURSOR FOR_LOCATION IS
      SELECT
        LOCATION_ID
      FROM
        HR_ORGANIZATION_UNITS
      WHERE ORGANIZATION_ID = ORG_ID;
    CURSOR FOR_ADDRESS IS
      SELECT
        ADDRESS_LINE_1 || ',' || ADDRESS_LINE_2 || ',' || ADDRESS_LINE_3 || ',' || TOWN_OR_CITY || ',' || COUNTRY || ',' || POSTAL_CODE || ',' || TELEPHONE_NUMBER_1 || ',' || TELEPHONE_NUMBER_2 || ',' || TELEPHONE_NUMBER_3
      FROM
        HR_LOCATIONS
      WHERE LOCATION_ID = V_LOCATION_ID;
  BEGIN
    OPEN FOR_LOCATION;
    FETCH FOR_LOCATION
     INTO V_LOCATION_ID;
    CLOSE FOR_LOCATION;
    OPEN FOR_ADDRESS;
    FETCH FOR_ADDRESS
     INTO V_ADDRESS;
    CLOSE FOR_ADDRESS;
    RETURN (V_ADDRESS);
  END CF_COMP_ADDRFORMULA;

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
  BEGIN
    /*SRW.MESSAGE(1275
               ,'Report Version is 120.2 Last modified date is 25/07/2005')*/NULL;
    P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    CP_AS_ON_DATE := TO_CHAR(P_AS_ON_DATE,'DD-MON-YY');
    CP_AS_ON_DATE1:= TO_CHAR(P_AS_ON_DATE,'DD-MON-YYYY');
    /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    BEGIN
      OPEN C_PROGRAM_ID(P_CONC_REQUEST_ID);
      FETCH C_PROGRAM_ID
       INTO V_PROGRAM_ID,V_ENABLE_TRACE;
      CLOSE C_PROGRAM_ID;
      /*SRW.MESSAGE(1275
                 ,'v_program_id -> ' || V_PROGRAM_ID || ', v_enable_trace -> ' || V_ENABLE_TRACE || ', request_id -> ' || P_CONC_REQUEST_ID)*/NULL;
      IF V_ENABLE_TRACE = 'Y' THEN
        EXECUTE IMMEDIATE
          'ALTER SESSION SET EVENTS ''10046 trace name context forever, level 4''';
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        /*SRW.MESSAGE(1275
                   ,'Error during enabling the trace. ErrCode -> ' || SQLCODE || ', ErrMesg -> ' || SQLERRM)*/NULL;
    END;
    IF P_AGING_INTERVAL_DAYS < 1 THEN
      CP_AGING_INTERVAL_DAYS := 1;
    END IF;
    IF P_NO_OF_INTERVALS < 2 THEN
      CP_NO_OF_INTERVALS := 2;
    END IF;
    IF P_NO_OF_INTERVALS > 13 THEN
      CP_NO_OF_INTERVALS := 13;
    END IF;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION CF_SOB_NAMEFORMULA RETURN VARCHAR2 IS
    CURSOR FOR_SOB_ID(V_ORG_ID IN NUMBER) IS
      SELECT
        SET_OF_BOOKS_ID
      FROM
        ORG_ORGANIZATION_DEFINITIONS
      WHERE NVL(OPERATING_UNIT
         ,0) = NVL(V_ORG_ID
         ,0);
    CURSOR FOR_SOB_NAME(SOB_ID IN NUMBER) IS
      SELECT
        NAME
      FROM
        GL_SETS_OF_BOOKS
      WHERE SET_OF_BOOKS_ID = SOB_ID;
    CURSOR FOR_INSTALL_INFO IS
      SELECT
        MULTI_ORG_FLAG
      FROM
        FND_PRODUCT_GROUPS;
    V_SET_OF_BOOKS_ID NUMBER;
    V_SOB_NAME VARCHAR2(100);
    V_MULTI_ORG VARCHAR2(1);
    V_ORG_ID NUMBER;
  BEGIN
    OPEN FOR_INSTALL_INFO;
    FETCH FOR_INSTALL_INFO
     INTO V_MULTI_ORG;
    CLOSE FOR_INSTALL_INFO;
    IF NVL(V_MULTI_ORG
       ,'N') = 'N' THEN
      V_ORG_ID := P_ORG_ID;
    ELSE
      V_ORG_ID := 0;
    END IF;
    OPEN FOR_SOB_ID(V_ORG_ID);
    FETCH FOR_SOB_ID
     INTO V_SET_OF_BOOKS_ID;
    CLOSE FOR_SOB_ID;
    OPEN FOR_SOB_NAME(V_SET_OF_BOOKS_ID);
    FETCH FOR_SOB_NAME
     INTO V_SOB_NAME;
    CLOSE FOR_SOB_NAME;
    RETURN (V_SOB_NAME);
  END CF_SOB_NAMEFORMULA;

  FUNCTION CF_P_VENDORFORMULA RETURN VARCHAR2 IS
    CURSOR FOR_VENDOR_NAME(V_ID IN NUMBER) IS
      SELECT
        VENDOR_NAME
      FROM
        PO_VENDORS
      WHERE VENDOR_ID = V_ID;
    V_VENDOR_NAME VARCHAR(100);
  BEGIN
    OPEN FOR_VENDOR_NAME(P_VENDOR_ID);
    FETCH FOR_VENDOR_NAME
     INTO V_VENDOR_NAME;
    CLOSE FOR_VENDOR_NAME;
    RETURN (V_VENDOR_NAME);
  END CF_P_VENDORFORMULA;

  FUNCTION CF_INR_AMOUNT1FORMULA(INVOICE_TYPE_LOOKUP_CODE1 IN VARCHAR2
                                ,EXCHANGE_RATE1 IN NUMBER
                                ,INVOICE_ID1 IN NUMBER
                                ,INVOICE_AMOUNT1 IN NUMBER
                                ,AMOUNT_PAID1 IN NUMBER) RETURN NUMBER IS
    AMOUNT NUMBER;
    PREPAY_APPLIED_AMT NUMBER;
  BEGIN
    IF INVOICE_TYPE_LOOKUP_CODE1 = 'PREPAYMENT' THEN
      SELECT
        SUM(PREPAY_AMOUNT_REMAINING) * NVL(EXCHANGE_RATE1
           ,1)
      INTO AMOUNT
      FROM
        AP_INVOICE_DISTRIBUTIONS_ALL APD
      GROUP BY
        APD.INVOICE_ID
      HAVING APD.INVOICE_ID = INVOICE_ID1;
    ELSE
      AMOUNT := (INVOICE_AMOUNT1 - NVL(AMOUNT_PAID1
                   ,0)) * NVL(EXCHANGE_RATE1
                   ,1);
    END IF;
    IF AMOUNT IS NULL THEN
      AMOUNT := INVOICE_AMOUNT1 * NVL(EXCHANGE_RATE1
                   ,1);
    END IF;
    RETURN AMOUNT;
  END CF_INR_AMOUNT1FORMULA;

  FUNCTION CF_AMOUNT1FORMULA(INVOICE_TYPE_LOOKUP_CODE1 IN VARCHAR2
                            ,INVOICE_ID1 IN NUMBER
                            ,INVOICE_AMOUNT1 IN NUMBER
                            ,AMOUNT_PAID1 IN NUMBER) RETURN NUMBER IS
    AMOUNT NUMBER;
    PREPAY_APPLIED_AMT NUMBER;
  BEGIN
    IF INVOICE_TYPE_LOOKUP_CODE1 = 'PREPAYMENT' THEN
      SELECT
        SUM(PREPAY_AMOUNT_REMAINING)
      INTO AMOUNT
      FROM
        AP_INVOICE_DISTRIBUTIONS_ALL APD
      GROUP BY
        APD.INVOICE_ID
      HAVING APD.INVOICE_ID = INVOICE_ID1;
    ELSE
      AMOUNT := (INVOICE_AMOUNT1 - NVL(AMOUNT_PAID1
                   ,0));
    END IF;
    IF AMOUNT IS NULL THEN
      AMOUNT := INVOICE_AMOUNT1;
    END IF;
    RETURN AMOUNT;
  END CF_AMOUNT1FORMULA;

  FUNCTION CF_REMARKSFORMULA(PAYMENT_STATUS_FLAG1 IN VARCHAR2) RETURN CHAR IS
    REMARK VARCHAR2(20);
  BEGIN
    IF PAYMENT_STATUS_FLAG1 = 'N' THEN
      REMARK := 'NOT PAID';
    ELSIF PAYMENT_STATUS_FLAG1 = 'P' THEN
      REMARK := 'PARTIALLY PAID';
    ELSIF PAYMENT_STATUS_FLAG1 = 'Y' THEN
      REMARK := 'FULLY PAID';
    END IF;
    RETURN REMARK;
  END CF_REMARKSFORMULA;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

END JA_JAINSTAC_XMLP_PKG;



/
