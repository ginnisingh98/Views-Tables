--------------------------------------------------------
--  DDL for Package Body JG_JGZZARIN_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JG_JGZZARIN_XMLP_PKG" AS
/* $Header: JGZZARINB.pls 120.2 2007/12/25 16:09:34 npannamp noship $ */
  FUNCTION S_SFORMULA(INVOICE_TOTAL IN NUMBER
                     ,CURRENCY IN VARCHAR2) RETURN VARCHAR2 IS
    VALUE NUMBER;
    VALUE1 NUMBER;
    VALUE2 NUMBER;
    DECIMAL NUMBER;
    WHOLE_DECIMAL NUMBER;
    WHOLE_VALUE NUMBER;
    I NUMBER;
    C_PL_CENT FND_LOOKUP_VALUES.MEANING%TYPE;
    C_PL_CENT_E FND_LOOKUP_VALUES.MEANING%TYPE;
    C_PL_CENT_Y FND_LOOKUP_VALUES.MEANING%TYPE;
  BEGIN
    S_SAY := '';
    I := 10;
    DECIMAL := ABS(INVOICE_TOTAL - TRUNC(INVOICE_TOTAL));
    VALUE := ABS(INVOICE_TOTAL);
    SELECT
      ' ' || LC1.MEANING || ' ',
      ' ' || LC2.MEANING || ' ',
      ' ' || LC3.MEANING || ' '
    INTO C_PL_CENT_E,C_PL_CENT_Y,C_PL_CENT
    FROM
      FND_LOOKUPS LC1,
      FND_LOOKUPS LC2,
      FND_LOOKUPS LC3
    WHERE LC1.LOOKUP_TYPE = 'JE_NLS_TRANSLATION'
      AND LC1.LOOKUP_CODE = 'PL_CENT_E'
      AND LC2.LOOKUP_TYPE = 'JE_NLS_TRANSLATION'
      AND LC2.LOOKUP_CODE = 'PL_CENT_Y'
      AND LC3.LOOKUP_TYPE = 'JE_NLS_TRANSLATION'
      AND LC3.LOOKUP_CODE = 'PL_CENT';
    IF P_SESSION_LANGUAGE = 'POLISH' THEN
      WHOLE_VALUE := TRUNC(VALUE);
      S_SAY := JE_AMOUNT_UTILITIES(NVL(WHOLE_VALUE
                                      ,0)) || ' ';
      WHOLE_DECIMAL := TRUNC(DECIMAL * 100);
      IF P_DEBUG_SWITCH = 'Y' THEN
        /*SRW.MESSAGE('999'
                   ,'VALUE : ' || VALUE)*/NULL;
        /*SRW.MESSAGE('999'
                   ,S_SAY)*/NULL;
      END IF;
      IF WHOLE_DECIMAL = 0 THEN
        S_SAY := S_SAY || '0/100 ' || C_PL_CENT_Y;
      ELSIF WHOLE_DECIMAL = 1 THEN
        S_SAY := S_SAY || TO_CHAR(ROUND(DECIMAL
                              ,2) * 100) || '/100 ' || C_PL_CENT;
      ELSIF SUBSTR(WHOLE_DECIMAL
            ,LENGTH(WHOLE_DECIMAL) - 1
            ,2) in ('12','13','14') THEN
        S_SAY := S_SAY || TO_CHAR(ROUND(DECIMAL
                              ,2) * 100) || '/100 ' || C_PL_CENT_Y;
      ELSIF SUBSTR(WHOLE_DECIMAL
            ,LENGTH(WHOLE_DECIMAL)
            ,1) in ('2','3','4') THEN
        S_SAY := S_SAY || TO_CHAR(ROUND(DECIMAL
                              ,2) * 100) || '/100 ' || C_PL_CENT_E;
      ELSE
        S_SAY := S_SAY || TO_CHAR(ROUND(DECIMAL
                              ,2) * 100) || '/100 ' || C_PL_CENT_Y;
      END IF;
    ELSE
      LOOP
        VALUE1 := TRUNC(VALUE / I
                       ,1);
        VALUE2 := (VALUE1 - TRUNC(VALUE1)) * 10;
        IF VALUE1 = 0 AND VALUE2 * 10 = 0 THEN
          S_SAY := S_SAY || TO_CHAR(ROUND(DECIMAL
                                ,2) * 100) || '/100* ' || CURRENCY;
          EXIT;
        END IF;
        IF VALUE2 = 1 THEN
          S_SAY := 'one*' || S_SAY;
        END IF;
        IF VALUE2 = 2 THEN
          S_SAY := 'two*' || S_SAY;
        END IF;
        IF VALUE2 = 3 THEN
          S_SAY := 'three*' || S_SAY;
        END IF;
        IF VALUE2 = 4 THEN
          S_SAY := 'four*' || S_SAY;
        END IF;
        IF VALUE2 = 5 THEN
          S_SAY := 'five*' || S_SAY;
        END IF;
        IF VALUE2 = 6 THEN
          S_SAY := 'six*' || S_SAY;
        END IF;
        IF VALUE2 = 7 THEN
          S_SAY := 'seven*' || S_SAY;
        END IF;
        IF VALUE2 = 8 THEN
          S_SAY := 'eight*' || S_SAY;
        END IF;
        IF VALUE2 = 9 THEN
          S_SAY := 'nine*' || S_SAY;
        END IF;
        IF VALUE2 = 0 THEN
          S_SAY := 'zero*' || S_SAY;
        END IF;
        I := I * 10;
      END LOOP;
    END IF;
    RETURN NULL;
  END S_SFORMULA;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.BREAK*/NULL;
    PRINT_STATUS_UPDATE;
    EXECUTE IMMEDIATE
      'commit';
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

  PROCEDURE PRINT_STATUS_UPDATE IS
    PC RA_CUSTOMER_TRX.PRINTING_COUNT%TYPE;
    PLP RA_CUSTOMER_TRX.PRINTING_LAST_PRINTED%TYPE;
    POD RA_CUSTOMER_TRX.PRINTING_ORIGINAL_DATE%TYPE;
    CTI RA_CUSTOMER_TRX.CUSTOMER_TRX_ID%TYPE;
    CURSOR C1 IS
      SELECT
        PRINTING_COUNT,
        PRINTING_LAST_PRINTED,
        PRINTING_ORIGINAL_DATE,
        CUSTOMER_TRX_ID
      FROM
        RA_CUSTOMER_TRX
      WHERE SET_OF_BOOKS_ID = P_SET_OF_BOOKS_ID
        AND COMPLETE_FLAG = 'Y'
        AND CUST_TRX_TYPE_ID = DECODE(P_DOCUMENT_TYPE
            ,NULL
            ,CUST_TRX_TYPE_ID
            ,P_DOCUMENT_TYPE)
        AND TRX_NUMBER between DECODE(P_INVOICE_NUMBER_LOW
            ,NULL
            ,TRX_NUMBER_LOW
            ,P_INVOICE_NUMBER_LOW)
        AND DECODE(P_INVOICE_NUMBER_HIGH
            ,NULL
            ,TRX_NUMBER_HIGH
            ,P_INVOICE_NUMBER_HIGH)
        AND TRX_DATE between NVL(P_INVOICE_DATE_LOW
         ,TRX_DATE)
        AND NVL(P_INVOICE_DATE_HIGH
         ,TRX_DATE)
        AND DECODE(P_BATCH_ID
            ,NULL
            ,1
            ,P_BATCH_ID) = DECODE(P_BATCH_ID
            ,NULL
            ,1
            ,BATCH_ID)
        AND BILL_TO_CUSTOMER_ID = DECODE(P_CUST_ID
            ,NULL
            ,BILL_TO_CUSTOMER_ID
            ,P_CUST_ID);
  BEGIN
    OPEN C1;
    LOOP
      FETCH C1
       INTO PC,PLP,POD,CTI;
      EXIT WHEN C1%NOTFOUND;
      IF P_PRINT_CODE = 'N' THEN
        UPDATE
          RA_CUSTOMER_TRX
        SET
          PRINTING_COUNT = DECODE(PC
                ,NULL
                ,0
                ,PC) + 1
          ,PRINTING_LAST_PRINTED = SYSDATE
          ,PRINTING_ORIGINAL_DATE = DECODE(PC
                ,NULL
                ,SYSDATE)
        WHERE CUSTOMER_TRX_ID = CTI
          AND NVL(PRINTING_COUNT
           ,0) = 0;
      ELSE
        UPDATE
          RA_CUSTOMER_TRX
        SET
          PRINTING_COUNT = DECODE(PC
                ,NULL
                ,0
                ,PC) + 1
          ,PRINTING_LAST_PRINTED = SYSDATE
          ,PRINTING_ORIGINAL_DATE = DECODE(PC
                ,NULL
                ,SYSDATE)
        WHERE CUSTOMER_TRX_ID = CTI
          AND NVL(PRINTING_COUNT
           ,0) <> 0;
      END IF;
    END LOOP;
    CLOSE C1;
  END PRINT_STATUS_UPDATE;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
      P_ORG_ID := MO_GLOBAL.GET_CURRENT_ORG_ID;
      P_COUNTRY_CODE := JG_ZZ_SHARED_PKG.GET_COUNTRY(P_ORG_ID);
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        BEGIN
          /*SRW.MESSAGE(100
                     ,'Foundation is not initialised')*/NULL;
          /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
        END;
    END;
    DECLARE
      COAID NUMBER;
      SOBNAME VARCHAR2(30);
      FUNCTCURR VARCHAR2(15);
      ERRBUF VARCHAR2(132);
      TRX_LOW VARCHAR2(20);
      TRX_HIGH VARCHAR2(20);
      COMP_NO VARCHAR2(20);
      VAT_REG VARCHAR2(20);
    BEGIN
      SELECT
        SUBSTR(USERENV('LANGUAGE')
              ,1
              ,INSTR(USERENV('LANGUAGE')
                   ,'_') - 1)
      INTO P_SESSION_LANGUAGE
      FROM
        DUAL;
      IF P_DEBUG_SWITCH = 'Y' THEN
        /*SRW.MESSAGE(999
                   ,'Session Language : ' || P_SESSION_LANGUAGE)*/NULL;
      END IF;
      JG_GET_SET_OF_BOOKS_INFO(P_SET_OF_BOOKS_ID
                              ,COAID
                              ,SOBNAME
                              ,FUNCTCURR
                              ,ERRBUF);
      IF (ERRBUF IS NOT NULL) THEN
        /*SRW.MESSAGE('00'
                   ,ERRBUF)*/NULL;
        /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
      END IF;
      SELECT
        PRECISION
      INTO PRECISION
      FROM
        FND_CURRENCIES
      WHERE CURRENCY_CODE = FUNCTCURR;
      SELECT
        REP_REGISTRATION_NUMBER
      INTO VAT_REG
      FROM
        ZX_PARTY_TAX_PROFILE PTP
      WHERE PARTY_TYPE_CODE = 'LEGAL_ESTABLISHMENT'
        AND PARTY_ID = (
        SELECT
          PARTY_ID
        FROM
          XLE_ETB_PROFILES XEP
        WHERE XEP.LEGAL_ENTITY_ID = P_ORG_ID
          AND MAIN_ESTABLISHMENT_FLAG = 'Y' );
      STRUCT_NUM := COAID;
      SET_OF_BOOKS_NAME := SOBNAME;
      FUNC_CURRENCY := FUNCTCURR;
      VAT_REGISTRATION_NUM := VAT_REG;
      IF P_PRINT_CODE = 'Y' THEN
        PRINT_TYPE := 'and (t.printing_count is not null or t.printing_count>0)';
      END IF;
      IF P_PRINT_CODE = 'N' THEN
        PRINT_TYPE := 'and (t.printing_count is null or t.printing_count=0)';
      END IF;
      SELECT
        MIN(TRX_NUMBER)
      INTO TRX_LOW
      FROM
        RA_CUSTOMER_TRX;
      SELECT
        MAX(TRX_NUMBER)
      INTO TRX_HIGH
      FROM
        RA_CUSTOMER_TRX;
      SELECT
        MAX(REGISTRATION_NUMBER)
      INTO COMP_NO
      FROM
        XLE_FIRSTPARTY_INFORMATION_V
      WHERE LEGAL_ENTITY_ID = P_ORG_ID;
      TRX_NUMBER_LOW := TRX_LOW;
      TRX_NUMBER_HIGH := TRX_HIGH;
      COMP_NUMBER := COMP_NO;
    END;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION CF_SHIP_ADDRESSFORMULA(CUST_NAME IN VARCHAR2
                                 ,SHIP_ADD_1 IN VARCHAR2
                                 ,SHIP_ADD_2 IN VARCHAR2
                                 ,SHIP_ADD_3 IN VARCHAR2
                                 ,SHIP_ADD_4 IN VARCHAR2
                                 ,SHIP_CITY IN VARCHAR2
                                 ,SHIP_POSTAL_CODE IN VARCHAR2
                                 ,SHIP_COUNTRY IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    CP_SHIP_CUST_NAME := CUST_NAME;
    CP_SHIP_ADD_1 := SHIP_ADD_1;
    CP_SHIP_ADD_2 := SHIP_ADD_2;
    CP_SHIP_ADD_3 := SHIP_ADD_3;
    CP_SHIP_ADD_4 := SHIP_ADD_4;
    CP_SHIP_CITY := SHIP_CITY;
    CP_SHIP_POSTAL_CODE := SHIP_POSTAL_CODE;
    CP_SHIP_COUNTRY := SHIP_COUNTRY;
    RETURN NULL;
  END CF_SHIP_ADDRESSFORMULA;

  FUNCTION CF_BILL_ADDRESSFORMULA(BILL_CUST_NAME IN VARCHAR2
                                 ,BILL_ADD_1 IN VARCHAR2
                                 ,BILL_ADD_2 IN VARCHAR2
                                 ,BILL_ADD_3 IN VARCHAR2
                                 ,BILL_ADD_4 IN VARCHAR2
                                 ,BILL_CITY IN VARCHAR2
                                 ,BILL_POSTAL_CODE IN VARCHAR2
                                 ,BILL_TAX_REFERENCE IN VARCHAR2
                                 ,BILL_COUNTRY IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    CP_BILL_CUST_NAME := BILL_CUST_NAME;
    CP_BILL_ADD_1 := BILL_ADD_1;
    CP_BILL_ADD_2 := BILL_ADD_2;
    CP_BILL_ADD_3 := BILL_ADD_3;
    CP_BILL_ADD_4 := BILL_ADD_4;
    CP_BILL_CITY := BILL_CITY;
    CP_BILL_POSTAL_CODE := BILL_POSTAL_CODE;
    CP_BILL_TAX_REFERENCE := BILL_TAX_REFERENCE;
    CP_BILL_COUNTRY := BILL_COUNTRY;
    RETURN NULL;
  END CF_BILL_ADDRESSFORMULA;

  FUNCTION CF_REMIT_ADDRESSFORMULA(REMIT_ADD_1 IN VARCHAR2
                                  ,REMIT_ADD_2 IN VARCHAR2
                                  ,REMIT_ADD_3 IN VARCHAR2
                                  ,REMIT_ADD_4 IN VARCHAR2
                                  ,REMIT_CITY IN VARCHAR2
                                  ,REMIT_POSTAL_CODE IN VARCHAR2
                                  ,REMIT_COUNTRY IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    CP_REMIT_ADD_1 := REMIT_ADD_1;
    CP_REMIT_ADD_2 := REMIT_ADD_2;
    CP_REMIT_ADD_3 := REMIT_ADD_3;
    CP_REMIT_ADD_4 := REMIT_ADD_4;
    CP_REMIT_CITY := REMIT_CITY;
    CP_REMIT_POSTAL_CODE := REMIT_POSTAL_CODE;
    CP_REMIT_COUNTRY := REMIT_COUNTRY;
    RETURN NULL;
  END CF_REMIT_ADDRESSFORMULA;

  FUNCTION CF_1FORMULA RETURN VARCHAR2 IS
  BEGIN
    RETURN ('X');
  END CF_1FORMULA;

  FUNCTION CP_SHIP_COUNTRYFORMULA RETURN VARCHAR2 IS
  BEGIN
    RETURN NULL;
  END CP_SHIP_COUNTRYFORMULA;

  FUNCTION CF_DUE_DATEFORMULA(DUE_DATE IN DATE) RETURN CHAR IS
  BEGIN
    RETURN FND_DATE.DATE_TO_CHARDATE(DUE_DATE);
  END CF_DUE_DATEFORMULA;

  FUNCTION CF_TRX_DATEFORMULA(TRX_DATE IN DATE) RETURN CHAR IS
  BEGIN
    RETURN FND_DATE.DATE_TO_CHARDATE(TRX_DATE);
  END CF_TRX_DATEFORMULA;

  FUNCTION CF_TAX_DATEFORMULA(TAX_DATE IN DATE) RETURN CHAR IS
  BEGIN
    RETURN FND_DATE.DATE_TO_CHARDATE(TAX_DATE);
  END CF_TAX_DATEFORMULA;

  FUNCTION JE_AMOUNT_UTILITIES(IN_NUMERAL IN NUMBER) RETURN VARCHAR2 IS
    C_ZERO AP_LOOKUP_CODES.DISPLAYED_FIELD%TYPE;
    C_THOUSAND AP_LOOKUP_CODES.DISPLAYED_FIELD%TYPE;
    C_MILLION AP_LOOKUP_CODES.DISPLAYED_FIELD%TYPE;
    C_BILLION AP_LOOKUP_CODES.DISPLAYED_FIELD%TYPE;
    C_PL_THOUSAND FND_LOOKUPS.MEANING%TYPE;
    C_PL_THOUSAND_Y FND_LOOKUPS.MEANING%TYPE;
    C_PL_THOUSAND_E FND_LOOKUPS.MEANING%TYPE;
    C_PL_MILLION FND_LOOKUPS.MEANING%TYPE;
    C_PL_MILLION_Y FND_LOOKUPS.MEANING%TYPE;
    C_PL_MILLION_OW FND_LOOKUPS.MEANING%TYPE;
    C_PL_BILLION FND_LOOKUPS.MEANING%TYPE;
    C_PL_BILLION_Y FND_LOOKUPS.MEANING%TYPE;
    C_PL_BILLION_OW FND_LOOKUPS.MEANING%TYPE;
    C_PL_CURRENCY FND_LOOKUPS.MEANING%TYPE;
    C_PL_CURRENCY_E FND_LOOKUPS.MEANING%TYPE;
    C_PL_CURRENCY_YCH FND_LOOKUPS.MEANING%TYPE;
    NUMBER_TOO_LARGE EXCEPTION;
    NUMERAL INTEGER := ABS(IN_NUMERAL);
    MAX_DIGIT INTEGER := 12;
    NUMBER_TEXT VARCHAR2(240) := '';
    BILLION_SEG VARCHAR2(25);
    MILLION_SEG VARCHAR2(25);
    THOUSAND_SEG VARCHAR2(25);
    UNITS_SEG VARCHAR2(25);
    BILLION_LOOKUP VARCHAR2(80);
    MILLION_LOOKUP VARCHAR2(80);
    THOUSAND_LOOKUP VARCHAR2(80);
    UNITS_LOOKUP VARCHAR2(80);
    THOUSAND NUMBER := POWER(10
         ,3);
    MILLION NUMBER := POWER(10
         ,6);
    BILLION NUMBER := POWER(10
         ,9);
  BEGIN
    IF NUMERAL >= POWER(10
         ,MAX_DIGIT) THEN
      RAISE NUMBER_TOO_LARGE;
    END IF;
    IF NUMERAL = 0 AND P_SESSION_LANGUAGE <> 'POLISH' THEN
      SELECT
        ' ' || DISPLAYED_FIELD || ' '
      INTO C_ZERO
      FROM
        AP_LOOKUP_CODES
      WHERE LOOKUP_CODE = 'ZERO';
      RETURN (C_ZERO);
    END IF;
    BILLION_SEG := TO_CHAR(TRUNC(NUMERAL / BILLION));
    NUMERAL := NUMERAL - (TRUNC(NUMERAL / BILLION) * BILLION);
    MILLION_SEG := TO_CHAR(TRUNC(NUMERAL / MILLION));
    NUMERAL := NUMERAL - (TRUNC(NUMERAL / MILLION) * MILLION);
    THOUSAND_SEG := TO_CHAR(TRUNC(NUMERAL / THOUSAND));
    UNITS_SEG := TO_CHAR(MOD(NUMERAL
                            ,THOUSAND));
    SELECT
      ' ' || LC1.DISPLAYED_FIELD || ' ',
      ' ' || LC2.DISPLAYED_FIELD || ' ',
      ' ' || LC3.DISPLAYED_FIELD || ' ',
      ' ' || LC4.DISPLAYED_FIELD,
      LC5.DESCRIPTION,
      LC6.DESCRIPTION,
      LC7.DESCRIPTION,
      LC8.DESCRIPTION
    INTO C_BILLION,C_MILLION,C_THOUSAND,C_ZERO,BILLION_LOOKUP,MILLION_LOOKUP,THOUSAND_LOOKUP,UNITS_LOOKUP
    FROM
      AP_LOOKUP_CODES LC1,
      AP_LOOKUP_CODES LC2,
      AP_LOOKUP_CODES LC3,
      AP_LOOKUP_CODES LC4,
      AP_LOOKUP_CODES LC5,
      AP_LOOKUP_CODES LC6,
      AP_LOOKUP_CODES LC7,
      AP_LOOKUP_CODES LC8
    WHERE LC1.LOOKUP_CODE = 'BILLION'
      AND LC1.LOOKUP_TYPE = 'NLS TRANSLATION'
      AND LC2.LOOKUP_CODE = 'MILLION'
      AND LC2.LOOKUP_TYPE = 'NLS TRANSLATION'
      AND LC3.LOOKUP_CODE = 'THOUSAND'
      AND LC3.LOOKUP_TYPE = 'NLS TRANSLATION'
      AND LC4.LOOKUP_CODE = 'ZERO'
      AND LC4.LOOKUP_TYPE = 'NLS TRANSLATION'
      AND LC5.LOOKUP_CODE = BILLION_SEG
      AND LC5.LOOKUP_TYPE = 'NUMBERS'
      AND LC6.LOOKUP_CODE = MILLION_SEG
      AND LC6.LOOKUP_TYPE = 'NUMBERS'
      AND LC7.LOOKUP_CODE = THOUSAND_SEG
      AND LC7.LOOKUP_TYPE = 'NUMBERS'
      AND LC8.LOOKUP_CODE = UNITS_SEG
      AND LC8.LOOKUP_TYPE = 'NUMBERS';
    SELECT
      ' ' || LC10.MEANING || ' ',
      ' ' || LC11.MEANING || ' ',
      ' ' || LC12.MEANING || ' ',
      ' ' || LC20.MEANING || ' ',
      ' ' || LC21.MEANING || ' ',
      ' ' || LC22.MEANING || ' ',
      ' ' || LC30.MEANING || ' ',
      ' ' || LC31.MEANING || ' ',
      ' ' || LC32.MEANING || ' ',
      ' ' || LC40.MEANING || ' ',
      ' ' || LC41.MEANING || ' ',
      ' ' || LC42.MEANING || ' '
    INTO C_PL_BILLION,C_PL_BILLION_Y,C_PL_BILLION_OW,C_PL_MILLION,C_PL_MILLION_Y,C_PL_MILLION_OW,C_PL_THOUSAND,C_PL_THOUSAND_Y,C_PL_THOUSAND_E,C_PL_CURRENCY,C_PL_CURRENCY_E,C_PL_CURRENCY_YCH
    FROM
      FND_LOOKUPS LC10,
      FND_LOOKUPS LC11,
      FND_LOOKUPS LC12,
      FND_LOOKUPS LC20,
      FND_LOOKUPS LC21,
      FND_LOOKUPS LC22,
      FND_LOOKUPS LC30,
      FND_LOOKUPS LC31,
      FND_LOOKUPS LC32,
      FND_LOOKUPS LC40,
      FND_LOOKUPS LC41,
      FND_LOOKUPS LC42
    WHERE LC10.LOOKUP_CODE = 'PL_BILLION'
      AND LC10.LOOKUP_TYPE = 'JE_NLS_TRANSLATION'
      AND LC11.LOOKUP_CODE = 'PL_BILLION_Y'
      AND LC11.LOOKUP_TYPE = 'JE_NLS_TRANSLATION'
      AND LC12.LOOKUP_CODE = 'PL_BILLION_OW'
      AND LC12.LOOKUP_TYPE = 'JE_NLS_TRANSLATION'
      AND LC20.LOOKUP_CODE = 'PL_MILLION'
      AND LC20.LOOKUP_TYPE = 'JE_NLS_TRANSLATION'
      AND LC21.LOOKUP_CODE = 'PL_MILLION_Y'
      AND LC21.LOOKUP_TYPE = 'JE_NLS_TRANSLATION'
      AND LC22.LOOKUP_CODE = 'PL_MILLION_OW'
      AND LC22.LOOKUP_TYPE = 'JE_NLS_TRANSLATION'
      AND LC30.LOOKUP_CODE = 'PL_THOUSAND'
      AND LC30.LOOKUP_TYPE = 'JE_NLS_TRANSLATION'
      AND LC31.LOOKUP_CODE = 'PL_THOUSAND_Y'
      AND LC31.LOOKUP_TYPE = 'JE_NLS_TRANSLATION'
      AND LC32.LOOKUP_CODE = 'PL_THOUSAND_E'
      AND LC32.LOOKUP_TYPE = 'JE_NLS_TRANSLATION'
      AND LC40.LOOKUP_CODE = 'PL_CURRENCY'
      AND LC40.LOOKUP_TYPE = 'JE_NLS_TRANSLATION'
      AND LC41.LOOKUP_CODE = 'PL_CURRENCY_E'
      AND LC41.LOOKUP_TYPE = 'JE_NLS_TRANSLATION'
      AND LC42.LOOKUP_CODE = 'PL_CURRENCY_YCH'
      AND LC42.LOOKUP_TYPE = 'JE_NLS_TRANSLATION';
    IF (P_SESSION_LANGUAGE = 'FRENCH' OR P_SESSION_LANGUAGE = 'CANADIAN FRENCH') AND THOUSAND_SEG = '1' THEN
      THOUSAND_LOOKUP := NULL;
    END IF;
    IF BILLION_SEG <> '0' AND (P_SESSION_LANGUAGE = 'POLISH') THEN
      IF SUBSTR(BILLION_SEG
            ,LENGTH(BILLION_SEG) - 1
            ,2) in ('12','13','14') THEN
        NUMBER_TEXT := NUMBER_TEXT || BILLION_LOOKUP || C_PL_BILLION_OW;
      ELSIF SUBSTR(BILLION_SEG
            ,LENGTH(BILLION_SEG)
            ,1) in ('2','3','4') THEN
        NUMBER_TEXT := NUMBER_TEXT || BILLION_LOOKUP || C_PL_BILLION_Y;
      ELSIF BILLION_SEG = 1 THEN
        NUMBER_TEXT := NUMBER_TEXT || BILLION_LOOKUP || C_PL_BILLION;
      ELSIF SUBSTR(BILLION_SEG
            ,LENGTH(BILLION_SEG)
            ,1) in ('0','1','5','6','7','8','9') THEN
        NUMBER_TEXT := NUMBER_TEXT || BILLION_LOOKUP || C_PL_BILLION_OW;
      ELSE
        /*SRW.MESSAGE('999'
                   ,' JE_AMOUNT_UNTILITIES : Billion Exception Raised')*/NULL;
        RAISE PROGRAM_ERROR;
      END IF;
    END IF;
    IF MILLION_SEG <> '0' AND (P_SESSION_LANGUAGE = 'POLISH') THEN
      IF SUBSTR(MILLION_SEG
            ,LENGTH(MILLION_SEG) - 1
            ,2) in ('12','13','14') THEN
        NUMBER_TEXT := NUMBER_TEXT || MILLION_LOOKUP || C_PL_MILLION_OW;
      ELSIF SUBSTR(MILLION_SEG
            ,LENGTH(MILLION_SEG)
            ,1) in ('2','3','4') THEN
        NUMBER_TEXT := NUMBER_TEXT || MILLION_LOOKUP || C_PL_MILLION_Y;
      ELSIF MILLION_SEG = 1 THEN
        NUMBER_TEXT := NUMBER_TEXT || MILLION_LOOKUP || C_PL_MILLION;
      ELSIF SUBSTR(MILLION_SEG
            ,LENGTH(MILLION_SEG)
            ,1) in ('0','1','5','6','7','8','9') THEN
        NUMBER_TEXT := NUMBER_TEXT || MILLION_LOOKUP || C_PL_MILLION_OW;
      ELSE
        /*SRW.MESSAGE('999'
                   ,' JE_AMOUNT_UNTILITIES : Million Exception Raised')*/NULL;
        RAISE PROGRAM_ERROR;
      END IF;
    END IF;
    IF THOUSAND_SEG <> '0' AND (P_SESSION_LANGUAGE = 'POLISH') THEN
      IF SUBSTR(THOUSAND_SEG
            ,LENGTH(THOUSAND_SEG) - 1
            ,2) in ('12','13','14') THEN
        NUMBER_TEXT := NUMBER_TEXT || THOUSAND_LOOKUP || C_PL_THOUSAND_Y;
      ELSIF SUBSTR(THOUSAND_SEG
            ,LENGTH(THOUSAND_SEG)
            ,1) in ('2','3','4') THEN
        NUMBER_TEXT := NUMBER_TEXT || THOUSAND_LOOKUP || C_PL_THOUSAND_E;
      ELSIF THOUSAND_SEG = 1 THEN
        NUMBER_TEXT := NUMBER_TEXT || THOUSAND_LOOKUP || C_PL_THOUSAND;
      ELSIF SUBSTR(THOUSAND_SEG
            ,LENGTH(THOUSAND_SEG)
            ,1) in ('0','1','5','6','7','8','9') THEN
        NUMBER_TEXT := NUMBER_TEXT || THOUSAND_LOOKUP || C_PL_THOUSAND_Y;
      ELSE
        /*SRW.MESSAGE('999'
                   ,' JE_AMOUNT_UNTILITIES : Thousand Exception Raised')*/NULL;
        RAISE PROGRAM_ERROR;
      END IF;
    END IF;
    IF (UNITS_SEG <> '0' AND P_SESSION_LANGUAGE = 'POLISH') THEN
      IF SUBSTR(UNITS_SEG
            ,LENGTH(UNITS_SEG) - 1
            ,2) in ('12','13','14') THEN
        NUMBER_TEXT := NUMBER_TEXT || UNITS_LOOKUP || C_PL_CURRENCY_YCH;
      ELSIF SUBSTR(UNITS_SEG
            ,LENGTH(UNITS_SEG)
            ,1) in ('2','3','4') THEN
        NUMBER_TEXT := NUMBER_TEXT || UNITS_LOOKUP || C_PL_CURRENCY_E;
      ELSIF UNITS_SEG = 1 THEN
        NUMBER_TEXT := NUMBER_TEXT || UNITS_LOOKUP || C_PL_CURRENCY;
      ELSIF SUBSTR(UNITS_SEG
            ,LENGTH(UNITS_SEG)
            ,1) in ('0','1','5','6','7','8','9') THEN
        NUMBER_TEXT := NUMBER_TEXT || UNITS_LOOKUP || C_PL_CURRENCY_YCH;
      ELSE
        /*SRW.MESSAGE('999'
                   ,' JE_AMOUNT_UNTILITIES : Units Exception Raised')*/NULL;
        RAISE PROGRAM_ERROR;
      END IF;
    ELSIF (UNITS_SEG = '0' AND P_SESSION_LANGUAGE = 'POLISH' AND IN_NUMERAL > 0) THEN
      NUMBER_TEXT := NUMBER_TEXT || C_PL_CURRENCY_YCH;
    ELSIF (UNITS_SEG = '0' AND P_SESSION_LANGUAGE = 'POLISH') THEN
      NUMBER_TEXT := NUMBER_TEXT || ' ' || UNITS_LOOKUP || C_PL_CURRENCY_YCH;
    END IF;
    NUMBER_TEXT := LTRIM(NUMBER_TEXT);
    NUMBER_TEXT := UPPER(SUBSTR(NUMBER_TEXT
                               ,1
                               ,1)) || RTRIM(LOWER(SUBSTR(NUMBER_TEXT
                                     ,2
                                     ,LENGTH(NUMBER_TEXT))));
    IF P_DEBUG_SWITCH = 'Y' THEN
      /*SRW.MESSAGE('999'
                 ,NUMBER_TEXT)*/NULL;
    END IF;
    RETURN (NUMBER_TEXT);
  EXCEPTION
    WHEN NUMBER_TOO_LARGE THEN
      RETURN (NULL);
    WHEN OTHERS THEN
      RETURN (NULL);
  END JE_AMOUNT_UTILITIES;

  FUNCTION CF_APPLY_DATEFORMULA(APPLY_DATE1 IN DATE) RETURN CHAR IS
  BEGIN
    RETURN FND_DATE.DATE_TO_CHARDATE(APPLY_DATE1);
  END CF_APPLY_DATEFORMULA;

  FUNCTION G_INVOICE_HEADERGROUPFILTER RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END G_INVOICE_HEADERGROUPFILTER;

  FUNCTION G_CUSTOMER_TRX_ID2GROUPFILTER RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END G_CUSTOMER_TRX_ID2GROUPFILTER;

  FUNCTION S_SAY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN S_SAY;
  END S_SAY_P;

  FUNCTION CP_SHIP_CUST_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_SHIP_CUST_NAME;
  END CP_SHIP_CUST_NAME_P;

  FUNCTION CP_SHIP_ADD_1_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_SHIP_ADD_1;
  END CP_SHIP_ADD_1_P;

  FUNCTION CP_SHIP_ADD_2_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_SHIP_ADD_2;
  END CP_SHIP_ADD_2_P;

  FUNCTION CP_SHIP_ADD_3_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_SHIP_ADD_3;
  END CP_SHIP_ADD_3_P;

  FUNCTION CP_SHIP_ADD_4_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_SHIP_ADD_4;
  END CP_SHIP_ADD_4_P;

  FUNCTION CP_SHIP_CITY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_SHIP_CITY;
  END CP_SHIP_CITY_P;

  FUNCTION CP_SHIP_POSTAL_CODE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_SHIP_POSTAL_CODE;
  END CP_SHIP_POSTAL_CODE_P;

  FUNCTION CP_SHIP_COUNTRY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_SHIP_COUNTRY;
  END CP_SHIP_COUNTRY_P;

  FUNCTION CP_BILL_CUST_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_BILL_CUST_NAME;
  END CP_BILL_CUST_NAME_P;

  FUNCTION CP_BILL_ADD_1_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_BILL_ADD_1;
  END CP_BILL_ADD_1_P;

  FUNCTION CP_BILL_ADD_2_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_BILL_ADD_2;
  END CP_BILL_ADD_2_P;

  FUNCTION CP_BILL_ADD_3_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_BILL_ADD_3;
  END CP_BILL_ADD_3_P;

  FUNCTION CP_BILL_ADD_4_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_BILL_ADD_4;
  END CP_BILL_ADD_4_P;

  FUNCTION CP_BILL_CITY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_BILL_CITY;
  END CP_BILL_CITY_P;

  FUNCTION CP_BILL_POSTAL_CODE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_BILL_POSTAL_CODE;
  END CP_BILL_POSTAL_CODE_P;

  FUNCTION CP_BILL_COUNTRY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_BILL_COUNTRY;
  END CP_BILL_COUNTRY_P;

  FUNCTION CP_BILL_TAX_REFERENCE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_BILL_TAX_REFERENCE;
  END CP_BILL_TAX_REFERENCE_P;

  FUNCTION CP_REMIT_CUST_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_REMIT_CUST;
  END CP_REMIT_CUST_P;

  FUNCTION CP_REMIT_ADD_1_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_REMIT_ADD_1;
  END CP_REMIT_ADD_1_P;

  FUNCTION CP_REMIT_ADD_2_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_REMIT_ADD_2;
  END CP_REMIT_ADD_2_P;

  FUNCTION CP_REMIT_ADD_3_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_REMIT_ADD_3;
  END CP_REMIT_ADD_3_P;

  FUNCTION CP_REMIT_ADD_4_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_REMIT_ADD_4;
  END CP_REMIT_ADD_4_P;

  FUNCTION CP_REMIT_CITY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_REMIT_CITY;
  END CP_REMIT_CITY_P;

  FUNCTION CP_REMIT_COUNTRY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_REMIT_COUNTRY;
  END CP_REMIT_COUNTRY_P;

  FUNCTION CP_1_P RETURN NUMBER IS
  BEGIN
    RETURN CP_1;
  END CP_1_P;

  FUNCTION CP_REMIT_POSTAL_CODE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_REMIT_POSTAL_CODE;
  END CP_REMIT_POSTAL_CODE_P;

  FUNCTION FUNC_CURRENCY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN FUNC_CURRENCY;
  END FUNC_CURRENCY_P;

  FUNCTION ORDERBY_ACCT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN ORDERBY_ACCT;
  END ORDERBY_ACCT_P;

  FUNCTION PRECISION_P RETURN NUMBER IS
  BEGIN
    RETURN PRECISION;
  END PRECISION_P;

  FUNCTION SELECT_ALL_P RETURN VARCHAR2 IS
  BEGIN
    RETURN SELECT_ALL;
  END SELECT_ALL_P;

  FUNCTION SET_OF_BOOKS_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN SET_OF_BOOKS_NAME;
  END SET_OF_BOOKS_NAME_P;

  FUNCTION STRUCT_NUM_P RETURN VARCHAR2 IS
  BEGIN
    RETURN STRUCT_NUM;
  END STRUCT_NUM_P;

  FUNCTION WHERE_FLEX_P RETURN VARCHAR2 IS
  BEGIN
    RETURN WHERE_FLEX;
  END WHERE_FLEX_P;

  FUNCTION PRINT_TYPE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN PRINT_TYPE;
  END PRINT_TYPE_P;

  FUNCTION TRX_NUMBER_LOW_P RETURN VARCHAR2 IS
  BEGIN
    RETURN TRX_NUMBER_LOW;
  END TRX_NUMBER_LOW_P;

  FUNCTION TRX_NUMBER_HIGH_P RETURN VARCHAR2 IS
  BEGIN
    RETURN TRX_NUMBER_HIGH;
  END TRX_NUMBER_HIGH_P;

  FUNCTION COMP_NUMBER_P RETURN VARCHAR2 IS
  BEGIN
    RETURN COMP_NUMBER;
  END COMP_NUMBER_P;

  FUNCTION VAT_REGISTRATION_NUM_P RETURN VARCHAR2 IS
  BEGIN
    RETURN VAT_REGISTRATION_NUM;
  END VAT_REGISTRATION_NUM_P;

  PROCEDURE JG_GET_PERIOD_DATES(APP_ID IN NUMBER
                               ,TSET_OF_BOOKS_ID IN NUMBER
                               ,TPERIOD_NAME IN VARCHAR2
                               ,TSTART_DATE OUT NOCOPY DATE
                               ,TEND_DATE OUT NOCOPY DATE
                               ,ERRBUF OUT NOCOPY VARCHAR2) IS
  BEGIN
    /*STPROC.INIT('begin JG_INFO.JG_GET_PERIOD_DATES(:APP_ID, :TSET_OF_BOOKS_ID, :TPERIOD_NAME, :TSTART_DATE, :TEND_DATE, :ERRBUF); end;');
    STPROC.BIND_I(APP_ID);
    STPROC.BIND_I(TSET_OF_BOOKS_ID);
    STPROC.BIND_I(TPERIOD_NAME);
    STPROC.BIND_O(TSTART_DATE);
    STPROC.BIND_O(TEND_DATE);
    STPROC.BIND_O(ERRBUF);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(4
                   ,TSTART_DATE);
    STPROC.RETRIEVE(5
                   ,TEND_DATE);
    STPROC.RETRIEVE(6
                   ,ERRBUF);*/null;

  END JG_GET_PERIOD_DATES;

  PROCEDURE JG_GET_SET_OF_BOOKS_INFO(SOBID IN NUMBER
                                    ,COAID OUT NOCOPY NUMBER
                                    ,SOBNAME OUT NOCOPY VARCHAR2
                                    ,FUNC_CURR OUT NOCOPY VARCHAR2
                                    ,ERRBUF OUT NOCOPY VARCHAR2) IS
  BEGIN
    /*STPROC.INIT('begin JG_INFO.JG_GET_SET_OF_BOOKS_INFO(:SOBID, :COAID, :SOBNAME, :FUNC_CURR, :ERRBUF); end;');
    STPROC.BIND_I(SOBID);
    STPROC.BIND_O(COAID);
    STPROC.BIND_O(SOBNAME);
    STPROC.BIND_O(FUNC_CURR);
    STPROC.BIND_O(ERRBUF);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(2
                   ,COAID);
    STPROC.RETRIEVE(3
                   ,SOBNAME);
    STPROC.RETRIEVE(4
                   ,FUNC_CURR);
    STPROC.RETRIEVE(5
                   ,ERRBUF);*/
    JG_INFO.JG_GET_SET_OF_BOOKS_INFO(SOBID, COAID, SOBNAME, FUNC_CURR, ERRBUF);
  END JG_GET_SET_OF_BOOKS_INFO;

  PROCEDURE JG_GET_BUD_OR_ENC_NAME(ACTUAL_TYPE IN VARCHAR2
                                  ,TYPE_ID IN NUMBER
                                  ,NAME OUT NOCOPY VARCHAR2
                                  ,ERRBUF OUT NOCOPY VARCHAR2) IS
  BEGIN
    /*STPROC.INIT('begin JG_INFO.JG_GET_BUD_OR_ENC_NAME(:ACTUAL_TYPE, :TYPE_ID, :NAME, :ERRBUF); end;');
    STPROC.BIND_I(ACTUAL_TYPE);
    STPROC.BIND_I(TYPE_ID);
    STPROC.BIND_O(NAME);
    STPROC.BIND_O(ERRBUF);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(3
                   ,NAME);
    STPROC.RETRIEVE(4
                   ,ERRBUF);*/
    JG_INFO.JG_GET_BUD_OR_ENC_NAME(ACTUAL_TYPE, TYPE_ID, NAME, ERRBUF);
  END JG_GET_BUD_OR_ENC_NAME;

  PROCEDURE JG_GET_LOOKUP_VALUE(LMODE IN VARCHAR2
                               ,CODE IN VARCHAR2
                               ,TYPE IN VARCHAR2
                               ,VALUE OUT NOCOPY VARCHAR2
                               ,ERRBUF OUT NOCOPY VARCHAR2) IS
  BEGIN
    /*STPROC.INIT('begin JG_INFO.JG_GET_LOOKUP_VALUE(:LMODE, :CODE, :TYPE, :VALUE, :ERRBUF); end;');
    STPROC.BIND_I(LMODE);
    STPROC.BIND_I(CODE);
    STPROC.BIND_I(TYPE);
    STPROC.BIND_O(VALUE);
    STPROC.BIND_O(ERRBUF);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(4
                   ,VALUE);
    STPROC.RETRIEVE(5
                   ,ERRBUF);*/
    JG_INFO.JG_GET_LOOKUP_VALUE(LMODE, CODE, TYPE, VALUE, ERRBUF);
  END JG_GET_LOOKUP_VALUE;

  PROCEDURE JG_GET_FIRST_PERIOD(APP_ID IN NUMBER
                               ,TSET_OF_BOOKS_ID IN NUMBER
                               ,TPERIOD_NAME IN VARCHAR2
                               ,TFIRST_PERIOD OUT NOCOPY VARCHAR2
                               ,ERRBUF OUT NOCOPY VARCHAR2) IS
  BEGIN
    /*STPROC.INIT('begin JG_INFO.JG_GET_FIRST_PERIOD(:APP_ID, :TSET_OF_BOOKS_ID, :TPERIOD_NAME, :TFIRST_PERIOD, :ERRBUF); end;');
    STPROC.BIND_I(APP_ID);
    STPROC.BIND_I(TSET_OF_BOOKS_ID);
    STPROC.BIND_I(TPERIOD_NAME);
    STPROC.BIND_O(TFIRST_PERIOD);
    STPROC.BIND_O(ERRBUF);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(4
                   ,TFIRST_PERIOD);
    STPROC.RETRIEVE(5
                   ,ERRBUF);*/
    JG_INFO.JG_GET_FIRST_PERIOD(APP_ID, TSET_OF_BOOKS_ID, TPERIOD_NAME, TFIRST_PERIOD, ERRBUF);
  END JG_GET_FIRST_PERIOD;

  PROCEDURE JG_GET_FIRST_PERIOD_OF_QUARTER(APP_ID IN NUMBER
                                          ,TSET_OF_BOOKS_ID IN NUMBER
                                          ,TPERIOD_NAME IN VARCHAR2
                                          ,TFIRST_PERIOD OUT NOCOPY VARCHAR2
                                          ,ERRBUF OUT NOCOPY VARCHAR2) IS
  BEGIN
    /*STPROC.INIT('begin JG_INFO.JG_GET_FIRST_PERIOD_OF_QUARTER(:APP_ID, :TSET_OF_BOOKS_ID, :TPERIOD_NAME, :TFIRST_PERIOD, :ERRBUF); end;');
    STPROC.BIND_I(APP_ID);
    STPROC.BIND_I(TSET_OF_BOOKS_ID);
    STPROC.BIND_I(TPERIOD_NAME);
    STPROC.BIND_O(TFIRST_PERIOD);
    STPROC.BIND_O(ERRBUF);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(4
                   ,TFIRST_PERIOD);
    STPROC.RETRIEVE(5
                   ,ERRBUF);*/
    JG_INFO.JG_GET_FIRST_PERIOD_OF_QUARTER(APP_ID, TSET_OF_BOOKS_ID, TPERIOD_NAME, TFIRST_PERIOD, ERRBUF);
  END JG_GET_FIRST_PERIOD_OF_QUARTER;

  PROCEDURE JG_GET_CONSOLIDATION_INFO(CONS_ID IN NUMBER
                                     ,CONS_NAME OUT NOCOPY VARCHAR2
                                     ,METHOD OUT NOCOPY VARCHAR2
                                     ,CURR_CODE OUT NOCOPY VARCHAR2
                                     ,FROM_SOBID OUT NOCOPY NUMBER
                                     ,TO_SOBID OUT NOCOPY NUMBER
                                     ,DESCRIPTION OUT NOCOPY VARCHAR2
                                     ,START_DATE OUT NOCOPY DATE
                                     ,END_DATE OUT NOCOPY DATE
                                     ,ERRBUF OUT NOCOPY VARCHAR2) IS
  BEGIN
   /* STPROC.INIT('begin JG_INFO.JG_GET_CONSOLIDATION_INFO(:CONS_ID, :CONS_NAME, :METHOD, :CURR_CODE, :FROM_SOBID, :TO_SOBID, :DESCRIPTION, :START_DATE, :END_DATE, :ERRBUF); end;');
    STPROC.BIND_I(CONS_ID);
    STPROC.BIND_O(CONS_NAME);
    STPROC.BIND_O(METHOD);
    STPROC.BIND_O(CURR_CODE);
    STPROC.BIND_O(FROM_SOBID);
    STPROC.BIND_O(TO_SOBID);
    STPROC.BIND_O(DESCRIPTION);
    STPROC.BIND_O(START_DATE);
    STPROC.BIND_O(END_DATE);
    STPROC.BIND_O(ERRBUF);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(2
                   ,CONS_NAME);
    STPROC.RETRIEVE(3
                   ,METHOD);
    STPROC.RETRIEVE(4
                   ,CURR_CODE);
    STPROC.RETRIEVE(5
                   ,FROM_SOBID);
    STPROC.RETRIEVE(6
                   ,TO_SOBID);
    STPROC.RETRIEVE(7
                   ,DESCRIPTION);
    STPROC.RETRIEVE(8
                   ,START_DATE);
    STPROC.RETRIEVE(9
                   ,END_DATE);
    STPROC.RETRIEVE(10
                   ,ERRBUF);*/null;

  END JG_GET_CONSOLIDATION_INFO;

END JG_JGZZARIN_XMLP_PKG;



/