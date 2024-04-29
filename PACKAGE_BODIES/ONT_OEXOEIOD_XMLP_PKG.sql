--------------------------------------------------------
--  DDL for Package Body ONT_OEXOEIOD_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_OEXOEIOD_XMLP_PKG" AS
/* $Header: OEXOEIODB.pls 120.3 2008/05/05 09:03:31 dwkrishn noship $ */
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

  FUNCTION P_ITEM_FLEX_CODEVALIDTRIGGER RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END P_ITEM_FLEX_CODEVALIDTRIGGER;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    BEGIN
      /*SRW.REFERENCE(P_SALESREP_LOW)*/NULL;
      /*SRW.REFERENCE(P_SALESREP_HIGH)*/NULL;
      IF (P_ORDER_TYPE_LOW IS NOT NULL) AND (P_ORDER_TYPE_HIGH IS NOT NULL) THEN
        LP_ORDER_TYPE := 'and ( ot.transaction_type_id between p_order_type_low and p_order_type_high ) ';
        SELECT
          OEOT.NAME
        INTO L_ORDER_TYPE_LOW
        FROM
          OE_TRANSACTION_TYPES_TL OEOT
        WHERE OEOT.TRANSACTION_TYPE_ID = P_ORDER_TYPE_LOW
          AND OEOT.LANGUAGE = USERENV('LANG');
        SELECT
          OEOT.NAME
        INTO L_ORDER_TYPE_HIGH
        FROM
          OE_TRANSACTION_TYPES_TL OEOT
        WHERE OEOT.TRANSACTION_TYPE_ID = P_ORDER_TYPE_HIGH
          AND OEOT.LANGUAGE = USERENV('LANG');
      ELSIF (P_ORDER_TYPE_LOW IS NOT NULL) THEN
        LP_ORDER_TYPE := 'and ot.transaction_type_id >= :p_order_type_low ';
        SELECT
          OEOT.NAME
        INTO L_ORDER_TYPE_LOW
        FROM
          OE_TRANSACTION_TYPES_TL OEOT
        WHERE OEOT.TRANSACTION_TYPE_ID = P_ORDER_TYPE_LOW
          AND OEOT.LANGUAGE = USERENV('LANG');
      ELSIF (P_ORDER_TYPE_HIGH IS NOT NULL) THEN
        LP_ORDER_TYPE := 'and ot.transaction_type_id <= p_order_type_high ';
        SELECT
          OEOT.NAME
        INTO L_ORDER_TYPE_HIGH
        FROM
          OE_TRANSACTION_TYPES_TL OEOT
        WHERE OEOT.TRANSACTION_TYPE_ID = P_ORDER_TYPE_HIGH
          AND OEOT.LANGUAGE = USERENV('LANG');
      END IF;
      IF (P_CUSTOMER_NAME_LOW IS NOT NULL) AND (P_CUSTOMER_NAME_HIGH IS NOT NULL) THEN
        LP_CUSTOMER_NAME := 'and ( party.party_name between :p_customer_name_low and :p_customer_name_high ) ';
      ELSIF (P_CUSTOMER_NAME_LOW IS NOT NULL) THEN
        LP_CUSTOMER_NAME := 'and party.party_name >= :p_customer_name_low ';
      ELSIF (P_CUSTOMER_NAME_HIGH IS NOT NULL) THEN
        LP_CUSTOMER_NAME := 'and party.party_name <= :p_customer_name_high ';
      END IF;
      IF (P_ORDER_NUM_LOW IS NOT NULL) AND (P_ORDER_NUM_HIGH IS NOT NULL) THEN
        IF (P_ORDER_NUM_LOW = P_ORDER_NUM_HIGH) THEN
          LP_ORDER_NUM := 'and h.order_number = :p_order_num_low ';
        ELSE
          LP_ORDER_NUM := 'and ( h.order_number between :p_order_num_low and :p_order_num_high ) ';
        END IF;
      ELSIF (P_ORDER_NUM_LOW IS NOT NULL) THEN
        LP_ORDER_NUM := 'and h.order_number >= :p_order_num_low ';
      ELSIF (P_ORDER_NUM_HIGH IS NOT NULL) THEN
        LP_ORDER_NUM := 'and h.order_number <= :p_order_num_high ';
      END IF;
      IF (P_SALESREP_LOW IS NOT NULL) AND (P_SALESREP_HIGH IS NOT NULL) THEN
        LP_SALESREP := 'and  (nvl(sr.name,''zzzzzz'') between :p_salesrep_low and :p_salesrep_high ) ';
      ELSIF (P_SALESREP_LOW IS NOT NULL) THEN
        LP_SALESREP := 'and nvl(sr.name,''zzzzzz'') >= :p_salesrep_low ';
      ELSIF (P_SALESREP_HIGH IS NOT NULL) THEN
        LP_SALESREP := 'and nvl(sr.name,''zzzzzz'') <= :p_salesrep_high ';
      END IF;
      IF (P_COUNTRY_LOW IS NOT NULL) THEN
        LP_COUNTRY := 'and terr.territory_short_name  =  :p_country_low ';
      END IF;
      IF P_OPEN_ORDERS_ONLY = 'Y' THEN
        LP_OPEN_ORDERS_ONLY := 'and h.open_flag = ''Y'' ';
      END IF;
      IF P_ORDER_NUM_LOW = P_ORDER_NUM_HIGH THEN
        NULL;
      ELSE
        IF P_ORDER_CATEGORY IS NOT NULL THEN
          IF P_ORDER_CATEGORY = 'SALES' THEN
            LP_ORDER_CATEGORY := 'and h.order_category_code in (''ORDER'', ''MIXED'') ';
          ELSIF P_ORDER_CATEGORY = 'CREDIT' THEN
            LP_ORDER_CATEGORY := 'and h.order_category_code in (''RETURN'', ''MIXED'') ';
          ELSIF P_ORDER_CATEGORY = 'ALL' THEN
            LP_ORDER_CATEGORY := NULL;
          END IF;
        ELSE
          LP_ORDER_CATEGORY := 'and h.order_category_code in (''ORDER'', ''MIXED'') ';
        END IF;
      END IF;
      IF P_LINE_CATEGORY IS NOT NULL THEN
        IF P_LINE_CATEGORY = 'SALES' THEN
          LP_LINE_CATEGORY := 'and l.line_category_code = ''ORDER'' ';
        ELSIF P_LINE_CATEGORY = 'CREDIT' THEN
          LP_LINE_CATEGORY := 'and l.line_category_code = ''RETURN'' ';
        ELSIF P_LINE_CATEGORY = 'ALL' THEN
          LP_LINE_CATEGORY := NULL;
        END IF;
      ELSE
        LP_LINE_CATEGORY := 'and l.line_category_code = ''ORDER'' ';
      END IF;
    END;
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION C_DATA_NOT_FOUNDFORMULA(CURRENCY1 IN VARCHAR2) RETURN NUMBER IS
  BEGIN
    RP_DATA_FOUND := CURRENCY1;
    RETURN (0);
  END C_DATA_NOT_FOUNDFORMULA;

  FUNCTION RP_CURR_LABELFORMULA RETURN VARCHAR2 IS
  BEGIN
    IF SUBSTR(UPPER(P_ORDER_BY)
          ,1
          ,1) = 'O' THEN
      RETURN ('  Currency:');
    ELSIF SUBSTR(UPPER(P_ORDER_BY)
          ,1
          ,1) = 'S' THEN
      RETURN ('    Currency:');
    ELSE
      RETURN ('Currency:');
    END IF;
    RETURN NULL;
  END RP_CURR_LABELFORMULA;

  FUNCTION C_ORDER_COUNTFORMULA RETURN NUMBER IS
  BEGIN
    RETURN (1);
  END C_ORDER_COUNTFORMULA;

  FUNCTION RP_ORDER_BYFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      L_TEMP VARCHAR2(100);
    BEGIN
      SELECT
        MEANING
      INTO L_TEMP
      FROM
        OE_LOOKUPS
      WHERE LOOKUP_TYPE = 'OEXOEIOD ORDER BY'
        AND SUBSTR(LOOKUP_CODE
            ,1
            ,1) = SUBSTR(UPPER(P_ORDER_BY)
            ,1
            ,1);
      RETURN (L_TEMP);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN ('Customer');
    END;
    RETURN NULL;
  END RP_ORDER_BYFORMULA;

  FUNCTION C_LINE_COUNTFORMULA(HEADER_ID1 IN NUMBER) RETURN NUMBER IS
  BEGIN
    DECLARE
      L_COUNT NUMBER(20);
    BEGIN
      /*SRW.REFERENCE(HEADER_ID1)*/NULL;
      L_COUNT := 0;
      SELECT
        1
      INTO L_COUNT
      FROM
        OE_ORDER_LINES_ALL L,
        RA_CUSTOMER_TRX_LINES_ALL TRXL,
        OE_ORDER_HEADERS H
      WHERE L.HEADER_ID = C_LINE_COUNTFORMULA.HEADER_ID1
        AND H.HEADER_ID = L.HEADER_ID
        AND TRXL.INTERFACE_LINE_CONTEXT = P_INVOICE_LINE_CONTEXT
        AND TRXL.INTERFACE_LINE_ATTRIBUTE1 = H.ORDER_NUMBER
        AND TO_CHAR(L.LINE_ID) = TRXL.INTERFACE_LINE_ATTRIBUTE6
        AND NVL(L.ORG_ID
         ,0) = NVL(LP_ORG_ID
         ,0)
        AND NVL(TRXL.ORG_ID
         ,0) = NVL(LP_ORG_ID
         ,0)
        AND ROWNUM = 1;
      RETURN (L_COUNT);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        L_COUNT := 0;
        RETURN (L_COUNT);
    END;
    RETURN NULL;
  END C_LINE_COUNTFORMULA;

  FUNCTION C_CONVERT_AMOUNTFORMULA(CURRENCY1 IN VARCHAR2
                                  ,AMOUNT IN NUMBER
                                  ,CONVERSION_TYPE_CODE IN VARCHAR2
                                  ,ORDER_DATE IN DATE
                                  ,CONVERSION_RATE IN NUMBER) RETURN NUMBER IS
  BEGIN
    DECLARE
      L_CONVERSION_RATE NUMBER(15);
      L_CURRENCY VARCHAR2(15);
      L_PRECISION NUMBER;
    BEGIN
      /*SRW.REFERENCE(CURRENCY1)*/NULL;
      /*SRW.REFERENCE(RP_FUNCTIONAL_CURRENCY)*/NULL;
      /*SRW.REFERENCE(C_AMOUNT)*/NULL;
      /*SRW.REFERENCE(AMOUNT)*/NULL;
      /*SRW.REFERENCE(CONVERSION_TYPE_CODE)*/NULL;
      /*SRW.REFERENCE(ORDER_DATE)*/NULL;
      L_CONVERSION_RATE := 0;
      BEGIN
        IF P_USE_FUNCTIONAL_CURRENCY = 'N' THEN
          L_CURRENCY := CURRENCY1;
        ELSE
          L_CURRENCY := RP_FUNCTIONAL_CURRENCY;
        END IF;
        SELECT
          PRECISION
        INTO L_PRECISION
        FROM
          FND_CURRENCIES
        WHERE CURRENCY_CODE = L_CURRENCY;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          L_PRECISION := 2;
      END;
      IF P_USE_FUNCTIONAL_CURRENCY = 'N' THEN
        C_AMOUNT := ROUND(NVL(AMOUNT
                             ,0)
                         ,L_PRECISION);
        RETURN (0);
      END IF;
      IF P_USE_FUNCTIONAL_CURRENCY = 'Y' THEN
        IF CURRENCY1 = RP_FUNCTIONAL_CURRENCY THEN
          L_CONVERSION_RATE := 1;
        ELSE
          IF CONVERSION_RATE IS NULL THEN
            L_CONVERSION_RATE := GET_RATE(P_SOB_ID
                                         ,CURRENCY1
                                         ,ORDER_DATE
                                         ,CONVERSION_TYPE_CODE);
          ELSE
            L_CONVERSION_RATE := CONVERSION_RATE;
          END IF;
        END IF;
        C_AMOUNT := ROUND((NVL(L_CONVERSION_RATE
                             ,0) * NVL(AMOUNT
                             ,0))
                         ,L_PRECISION);
        RETURN (0);
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        C_AMOUNT := 0;
        RETURN (0);
      WHEN OTHERS THEN
        C_AMOUNT := 0;
        RETURN (0);
    END;
    RETURN NULL;
  END C_CONVERT_AMOUNTFORMULA;

  FUNCTION RP_USE_FUNCTIONAL_CURRENCYFORM RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      L_TEMP VARCHAR2(100);
    BEGIN
      SELECT
        MEANING
      INTO L_TEMP
      FROM
        FND_LOOKUPS
      WHERE LOOKUP_CODE = P_USE_FUNCTIONAL_CURRENCY
        AND LOOKUP_TYPE = 'YES_NO';
      RETURN (L_TEMP);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN ('No');
    END;
    RETURN NULL;
  END RP_USE_FUNCTIONAL_CURRENCYFORM;

  FUNCTION C_CONVERT_SVC_AMOUNTFORMULA(CURRENCY1 IN VARCHAR2
                                      ,SVC_AMOUNT IN NUMBER
                                      ,CONVERSION_TYPE_CODE IN VARCHAR2
                                      ,ORDER_DATE IN DATE
                                      ,CONVERSION_RATE IN NUMBER) RETURN NUMBER IS
  BEGIN
    DECLARE
      L_CONVERSION_RATE NUMBER(15);
      L_CURRENCY VARCHAR2(15);
      L_PRECISION NUMBER;
    BEGIN
      /*SRW.REFERENCE(CURRENCY1)*/NULL;
      /*SRW.REFERENCE(RP_FUNCTIONAL_CURRENCY)*/NULL;
      /*SRW.REFERENCE(C_SVC_AMOUNT)*/NULL;
      /*SRW.REFERENCE(SVC_AMOUNT)*/NULL;
      /*SRW.REFERENCE(CONVERSION_TYPE_CODE)*/NULL;
      /*SRW.REFERENCE(ORDER_DATE)*/NULL;
      L_CONVERSION_RATE := 0;
      BEGIN
        IF P_USE_FUNCTIONAL_CURRENCY = 'N' THEN
          L_CURRENCY := CURRENCY1;
        ELSE
          L_CURRENCY := RP_FUNCTIONAL_CURRENCY;
        END IF;
        SELECT
          PRECISION
        INTO L_PRECISION
        FROM
          FND_CURRENCIES
        WHERE CURRENCY_CODE = L_CURRENCY;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          L_PRECISION := 2;
      END;
      IF P_USE_FUNCTIONAL_CURRENCY = 'N' THEN
        C_SVC_AMOUNT := ROUND(NVL(SVC_AMOUNT
                                 ,0)
                             ,L_PRECISION);
        RETURN (0);
      END IF;
      IF P_USE_FUNCTIONAL_CURRENCY = 'Y' THEN
        IF CURRENCY1 = RP_FUNCTIONAL_CURRENCY THEN
          L_CONVERSION_RATE := 1;
        ELSE
          IF CONVERSION_RATE IS NULL THEN
            L_CONVERSION_RATE := GET_RATE(P_SOB_ID
                                         ,CURRENCY1
                                         ,ORDER_DATE
                                         ,CONVERSION_TYPE_CODE);
          ELSE
            L_CONVERSION_RATE := CONVERSION_RATE;
          END IF;
        END IF;
        C_SVC_AMOUNT := ROUND((NVL(L_CONVERSION_RATE
                                 ,0) * NVL(SVC_AMOUNT
                                 ,0))
                             ,L_PRECISION);
        RETURN (0);
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        C_SVC_AMOUNT := 0;
        RETURN (0);
      WHEN OTHERS THEN
        C_SVC_AMOUNT := 0;
        RETURN (0);
    END;
    RETURN NULL;
  END C_CONVERT_SVC_AMOUNTFORMULA;

  FUNCTION S_AMOUNT_ONFORMULA(C_AMT_INV1 IN NUMBER
                             ,C_SVC_AMT1 IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (NVL(C_AMT_INV1
              ,0) + NVL(C_SVC_AMT1
              ,0));
  END S_AMOUNT_ONFORMULA;

  FUNCTION S_AMOUNT_CUFORMULA(C_AMT_INV_CU IN NUMBER
                             ,C_SVC_AMT_INV_CU IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (NVL(C_AMT_INV_CU
              ,0) + NVL(C_SVC_AMT_INV_CU
              ,0));
  END S_AMOUNT_CUFORMULA;

  FUNCTION S_AMOUNT_CURFORMULA(C_AMT_INV_CUR IN NUMBER
                              ,C_SVC_AMT_INV_CUR IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (NVL(C_AMT_INV_CUR
              ,0) + NVL(C_SVC_AMT_INV_CUR
              ,0));
  END S_AMOUNT_CURFORMULA;

  FUNCTION S_AMOUNT_CPBFORMULA(C_AMT_INV_CPB IN NUMBER
                              ,C_SVC_AMT_INV_CPB IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (NVL(C_AMT_INV_CPB
              ,0) + NVL(C_SVC_AMT_INV_CPB
              ,0));
  END S_AMOUNT_CPBFORMULA;

  FUNCTION S_AMOUNT_OTFORMULA(C_AMT_INV_OT IN NUMBER
                             ,C_SVC_AMT_OT IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (NVL(C_AMT_INV_OT
              ,0) + NVL(C_SVC_AMT_OT
              ,0));
  END S_AMOUNT_OTFORMULA;

  FUNCTION S_AMOUNT_SPFORMULA(C_AMT_INV_SP IN NUMBER
                             ,C_SVC_AMT_INV_SP IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (NVL(C_AMT_INV_SP
              ,0) + NVL(C_SVC_AMT_INV_SP
              ,0));
  END S_AMOUNT_SPFORMULA;

  FUNCTION BEFOREPFORM RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END BEFOREPFORM;

  FUNCTION RP_ORDER_CATEGORYFORMULA RETURN CHAR IS
  BEGIN
    DECLARE
      L_MEANING VARCHAR2(80);
    BEGIN
      SELECT
        MEANING
      INTO L_MEANING
      FROM
        OE_LOOKUPS
      WHERE LOOKUP_TYPE = 'REPORT_ORDER_CATEGORY'
        AND LOOKUP_CODE = P_ORDER_CATEGORY;
      RETURN (L_MEANING);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN (NULL);
    END;
    RETURN NULL;
  END RP_ORDER_CATEGORYFORMULA;

  FUNCTION RP_LINE_CATEGORYFORMULA RETURN CHAR IS
  BEGIN
    DECLARE
      L_MEANING VARCHAR2(80);
    BEGIN
      SELECT
        MEANING
      INTO L_MEANING
      FROM
        OE_LOOKUPS
      WHERE LOOKUP_TYPE = 'REPORT_LINE_DISPLAY'
        AND LOOKUP_CODE = P_LINE_CATEGORY;
      RETURN (L_MEANING);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN (NULL);
    END;
    RETURN NULL;
  END RP_LINE_CATEGORYFORMULA;

  FUNCTION C_MASTER_ORGFORMULA RETURN CHAR IS
    V_MASTER_ORG VARCHAR2(20);
  BEGIN
    SELECT
      NVL(OE_SYS_PARAMETERS.VALUE('MASTER_ORGANIZATION_ID'
                                 ,MO_GLOBAL.GET_CURRENT_ORG_ID)
         ,0)
    INTO V_MASTER_ORG
    FROM
      DUAL;
    RETURN V_MASTER_ORG;
  END C_MASTER_ORGFORMULA;

  FUNCTION C_QUANTITY_CURFORMULA(S_QUANTITY_CUR IN NUMBER
                                ,S_SVC_QUANTITY_CUR IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (S_QUANTITY_CUR + S_SVC_QUANTITY_CUR);
  END C_QUANTITY_CURFORMULA;

  FUNCTION C_QUANTITY_SPFORMULA(S_QUANTITY_SP IN NUMBER
                               ,S_SVC_QUANTITY_SP IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (S_QUANTITY_SP + S_SVC_QUANTITY_SP);
  END C_QUANTITY_SPFORMULA;

  FUNCTION CF_1FORMULA(S_QUANTITY_OT IN NUMBER
                      ,S_SVC_QUANTITY_OT IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (S_QUANTITY_OT + S_SVC_QUANTITY_OT);
  END CF_1FORMULA;

  FUNCTION CF_1FORMULA0009(S_QUANTITY_CPB IN NUMBER
                          ,S_SVC_QUANTITY_CPB IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (S_QUANTITY_CPB + S_SVC_QUANTITY_CPB);
  END CF_1FORMULA0009;

  FUNCTION CF_1FORMULA0011(S_QUANTITY_CU IN NUMBER
                          ,S_SVC_QUANTITY_CU IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (S_QUANTITY_CU + S_SVC_QUANTITY_CU);
  END CF_1FORMULA0011;

  FUNCTION C_QUANTITY_ONFORMULA(S_QUANTITY_ON IN NUMBER
                               ,S_SVC_QUANTITY_ON IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (S_QUANTITY_ON + S_SVC_QUANTITY_ON);
  END C_QUANTITY_ONFORMULA;

  FUNCTION C_PRECISIONFORMULA(CURRENCY1 IN VARCHAR2) RETURN NUMBER IS
  BEGIN
    DECLARE
      W_PRECISION NUMBER;
    BEGIN
      SELECT
        PRECISION
      INTO W_PRECISION
      FROM
        FND_CURRENCIES
      WHERE CURRENCY_CODE = CURRENCY1;
      RETURN (W_PRECISION);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        W_PRECISION := 2;
        RETURN (W_PRECISION);
    END;
    RETURN NULL;
  END C_PRECISIONFORMULA;

  FUNCTION C_CURRENCYFORMULA(CURRENCY1 IN VARCHAR2) RETURN CHAR IS
  BEGIN
    IF P_USE_FUNCTIONAL_CURRENCY = 'N' THEN
      RETURN (CURRENCY1);
    ELSE
      RETURN (RP_FUNCTIONAL_CURRENCY);
    END IF;
  END C_CURRENCYFORMULA;

  FUNCTION C_AMOUNT_P RETURN NUMBER IS
  BEGIN
    RETURN C_AMOUNT;
  END C_AMOUNT_P;

  FUNCTION C_SVC_AMOUNT_P RETURN NUMBER IS
  BEGIN
    RETURN C_SVC_AMOUNT;
  END C_SVC_AMOUNT_P;

  FUNCTION RP_SVC_DUMMY_ITEM_P RETURN DATE IS
  BEGIN
    RETURN RP_SVC_DUMMY_ITEM;
  END RP_SVC_DUMMY_ITEM_P;

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

  FUNCTION RP_ITEM_FLEX_ALL_SEG_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_ITEM_FLEX_ALL_SEG;
  END RP_ITEM_FLEX_ALL_SEG_P;

  FUNCTION RP_ORDER_NUMBER_RANGE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_ORDER_NUMBER_RANGE;
  END RP_ORDER_NUMBER_RANGE_P;

  FUNCTION RP_SALESREP_RANGE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_SALESREP_RANGE;
  END RP_SALESREP_RANGE_P;

  FUNCTION RP_CUSTOMER_NAME_RANGE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_CUSTOMER_NAME_RANGE;
  END RP_CUSTOMER_NAME_RANGE_P;

  FUNCTION RP_ORDER_TYPE_RANGE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_ORDER_TYPE_RANGE;
  END RP_ORDER_TYPE_RANGE_P;

  FUNCTION RP_OPEN_ORDERS_ONLY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_OPEN_ORDERS_ONLY;
  END RP_OPEN_ORDERS_ONLY_P;

  FUNCTION RP_PRINT_DESCRIPTION_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_PRINT_DESCRIPTION;
  END RP_PRINT_DESCRIPTION_P;

  FUNCTION RP_DUMMY_ITEM_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_DUMMY_ITEM;
  END RP_DUMMY_ITEM_P;

  FUNCTION IS_FIXED_RATE(X_FROM_CURRENCY IN VARCHAR2
                        ,X_TO_CURRENCY IN VARCHAR2
                        ,X_EFFECTIVE_DATE IN DATE) RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
   /* STPROC.INIT('begin :X0 := GL_CURRENCY_API.IS_FIXED_RATE(:X_FROM_CURRENCY, :X_TO_CURRENCY, :X_EFFECTIVE_DATE); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(X_FROM_CURRENCY);
    STPROC.BIND_I(X_TO_CURRENCY);
    STPROC.BIND_I(X_EFFECTIVE_DATE);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/

    X0 := GL_CURRENCY_API.IS_FIXED_RATE(X_FROM_CURRENCY, X_TO_CURRENCY, X_EFFECTIVE_DATE);

    RETURN X0;
  END IS_FIXED_RATE;

  PROCEDURE GET_RELATION(X_FROM_CURRENCY IN VARCHAR2
                        ,X_TO_CURRENCY IN VARCHAR2
                        ,X_EFFECTIVE_DATE IN DATE
                        ,X_FIXED_RATE IN OUT NOCOPY BOOLEAN
                        ,X_RELATIONSHIP IN OUT NOCOPY VARCHAR2) IS
  BEGIN
    /*STPROC.INIT('declare X_FIXED_RATE BOOLEAN; begin X_FIXED_RATE := sys.diutil.int_to_bool(:X_FIXED_RATE); GL_CURRENCY_API.GET_RELATION(:X_FROM_CURRENCY, :X_TO_CURRENCY, :X_EFFECTIVE_DATE, X_FIXED_RATE, :X_RELATIONSHIP);
    :X_FIXED_RATE := sys.diutil.bool_to_int(X_FIXED_RATE); end;');
    STPROC.BIND_IO(X_FIXED_RATE);
    STPROC.BIND_I(X_FROM_CURRENCY);
    STPROC.BIND_I(X_TO_CURRENCY);
    STPROC.BIND_I(X_EFFECTIVE_DATE);
    STPROC.BIND_IO(X_RELATIONSHIP);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X_FIXED_RATE);
    STPROC.RETRIEVE(5
                   ,X_RELATIONSHIP);*/

    GL_CURRENCY_API.GET_RELATION(X_FROM_CURRENCY, X_TO_CURRENCY, X_EFFECTIVE_DATE, X_FIXED_RATE, X_RELATIONSHIP);

  END GET_RELATION;

  FUNCTION GET_EURO_CODE RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
   /* STPROC.INIT('begin :X0 := GL_CURRENCY_API.GET_EURO_CODE; end;');
    STPROC.BIND_O(X0);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/

    X0 := GL_CURRENCY_API.GET_EURO_CODE;
    RETURN X0;
  END GET_EURO_CODE;

  FUNCTION GET_RATE(X_FROM_CURRENCY IN VARCHAR2
                   ,X_TO_CURRENCY IN VARCHAR2
                   ,X_CONVERSION_DATE IN DATE
                   ,X_CONVERSION_TYPE IN VARCHAR2) RETURN NUMBER IS
    X0 NUMBER;
  BEGIN
    /*STPROC.INIT('begin :X0 := GL_CURRENCY_API.GET_RATE(:X_FROM_CURRENCY, :X_TO_CURRENCY, :X_CONVERSION_DATE, :X_CONVERSION_TYPE); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(X_FROM_CURRENCY);
    STPROC.BIND_I(X_TO_CURRENCY);
    STPROC.BIND_I(X_CONVERSION_DATE);
    STPROC.BIND_I(X_CONVERSION_TYPE);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/
    X0 := GL_CURRENCY_API.GET_RATE(X_FROM_CURRENCY, X_TO_CURRENCY, X_CONVERSION_DATE, X_CONVERSION_TYPE);
    RETURN X0;
  END GET_RATE;

  FUNCTION GET_RATE(X_SET_OF_BOOKS_ID IN NUMBER
                   ,X_FROM_CURRENCY IN VARCHAR2
                   ,X_CONVERSION_DATE IN DATE
                   ,X_CONVERSION_TYPE IN VARCHAR2) RETURN NUMBER IS
    X0 NUMBER;
  BEGIN
   /* STPROC.INIT('begin :X0 := GL_CURRENCY_API.GET_RATE(:X_SET_OF_BOOKS_ID, :X_FROM_CURRENCY, :X_CONVERSION_DATE, :X_CONVERSION_TYPE); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(X_SET_OF_BOOKS_ID);
    STPROC.BIND_I(X_FROM_CURRENCY);
    STPROC.BIND_I(X_CONVERSION_DATE);
    STPROC.BIND_I(X_CONVERSION_TYPE);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/

		   X0 := GL_CURRENCY_API.GET_RATE(X_SET_OF_BOOKS_ID, X_FROM_CURRENCY, X_CONVERSION_DATE, X_CONVERSION_TYPE);
    RETURN X0;
  END GET_RATE;

  FUNCTION CONVERT_AMOUNT(X_FROM_CURRENCY IN VARCHAR2
                         ,X_TO_CURRENCY IN VARCHAR2
                         ,X_CONVERSION_DATE IN DATE
                         ,X_CONVERSION_TYPE IN VARCHAR2
                         ,X_AMOUNT IN NUMBER) RETURN NUMBER IS
    X0 NUMBER;
  BEGIN
    /*STPROC.INIT('begin :X0 := GL_CURRENCY_API.CONVERT_AMOUNT(:X_FROM_CURRENCY, :X_TO_CURRENCY, :X_CONVERSION_DATE, :X_CONVERSION_TYPE, :X_AMOUNT); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(X_FROM_CURRENCY);
    STPROC.BIND_I(X_TO_CURRENCY);
    STPROC.BIND_I(X_CONVERSION_DATE);
    STPROC.BIND_I(X_CONVERSION_TYPE);
    STPROC.BIND_I(X_AMOUNT);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/
    X0 := GL_CURRENCY_API.CONVERT_AMOUNT(X_FROM_CURRENCY, X_TO_CURRENCY, X_CONVERSION_DATE, X_CONVERSION_TYPE, X_AMOUNT);

    RETURN X0;
  END CONVERT_AMOUNT;

  FUNCTION CONVERT_AMOUNT(X_SET_OF_BOOKS_ID IN NUMBER
                         ,X_FROM_CURRENCY IN VARCHAR2
                         ,X_CONVERSION_DATE IN DATE
                         ,X_CONVERSION_TYPE IN VARCHAR2
                         ,X_AMOUNT IN NUMBER) RETURN NUMBER IS
    X0 NUMBER;
  BEGIN
    /*STPROC.INIT('begin :X0 := GL_CURRENCY_API.CONVERT_AMOUNT(:X_SET_OF_BOOKS_ID, :X_FROM_CURRENCY, :X_CONVERSION_DATE, :X_CONVERSION_TYPE, :X_AMOUNT); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(X_SET_OF_BOOKS_ID);
    STPROC.BIND_I(X_FROM_CURRENCY);
    STPROC.BIND_I(X_CONVERSION_DATE);
    STPROC.BIND_I(X_CONVERSION_TYPE);
    STPROC.BIND_I(X_AMOUNT);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/
    X0 := GL_CURRENCY_API.CONVERT_AMOUNT(X_SET_OF_BOOKS_ID, X_FROM_CURRENCY, X_CONVERSION_DATE, X_CONVERSION_TYPE, X_AMOUNT);
    RETURN X0;
  END CONVERT_AMOUNT;

  FUNCTION GET_DERIVE_TYPE(SOB_ID IN NUMBER
                          ,PERIOD IN VARCHAR2
                          ,CURR_CODE IN VARCHAR2) RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
    /*STPROC.INIT('begin :X0 := GL_CURRENCY_API.GET_DERIVE_TYPE(:SOB_ID, :PERIOD, :CURR_CODE); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(SOB_ID);
    STPROC.BIND_I(PERIOD);
    STPROC.BIND_I(CURR_CODE);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/
    X0 := GL_CURRENCY_API.GET_DERIVE_TYPE(SOB_ID, PERIOD, CURR_CODE);
    RETURN X0;
  END GET_DERIVE_TYPE;

  FUNCTION RATE_EXISTS(X_FROM_CURRENCY IN VARCHAR2
                      ,X_TO_CURRENCY IN VARCHAR2
                      ,X_CONVERSION_DATE IN DATE
                      ,X_CONVERSION_TYPE IN VARCHAR2) RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
    /*STPROC.INIT('begin :X0 := GL_CURRENCY_API.RATE_EXISTS(:X_FROM_CURRENCY, :X_TO_CURRENCY, :X_CONVERSION_DATE, :X_CONVERSION_TYPE); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(X_FROM_CURRENCY);
    STPROC.BIND_I(X_TO_CURRENCY);
    STPROC.BIND_I(X_CONVERSION_DATE);
    STPROC.BIND_I(X_CONVERSION_TYPE);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/

    X0 := GL_CURRENCY_API.RATE_EXISTS(X_FROM_CURRENCY, X_TO_CURRENCY, X_CONVERSION_DATE,  X_CONVERSION_TYPE);
    RETURN X0;
  END RATE_EXISTS;


 FUNCTION BEFOREREPORT RETURN BOOLEAN IS
 BEGIN

	DECLARE
	BEGIN

		/*BEGIN
		SRW.USER_EXIT('FND SRWINIT');
		EXCEPTION
			WHEN SRW.USER_EXIT_FAILURE THEN
			SRW.MESSAGE (1000,'Failed in BEFORE REPORT trigger');
		return (FALSE);
		END;*/null;


	BEGIN /*MOAC*/

		LP_ORG_ID:= MO_GLOBAL.GET_CURRENT_ORG_ID();

	END;

/*
DECLARE
COUNT_OE_ORDER_HEADERS NUMBER(10);
COUNT_oe_order_lines_all NUMBER(10);
COUNT_oe_transaction_types_tl NUMBER(10);
COUNT_hz_cust_site_uses_all NUMBER(10);
COUNT_hz_cust_acct_sites_all NUMBER(10);
COUNT_hz_party_sites NUMBER(10);
COUNT_hz_locations NUMBER(10);
COUNT_ra_salesreps_all NUMBER(10);
COUNT_fnd_territories_vl NUMBER(10);
COUNT_hz_parties NUMBER(10);
COUNT_hz_cust_accounts NUMBER(10);

BEGIN

SELECT COUNT(*) INTO COUNT_OE_ORDER_HEADERS FROM OE_ORDER_HEADERS;

SELECT COUNT(*) INTO COUNT_oe_order_lines_all FROM oe_order_lines_all;

SELECT COUNT(*) INTO COUNT_oe_transaction_types_tl FROM oe_transaction_types_tl;

SELECT COUNT(*) INTO COUNT_hz_cust_site_uses_all FROM hz_cust_site_uses_all;

SELECT COUNT(*) INTO COUNT_hz_cust_acct_sites_all FROM hz_cust_acct_sites_all;

SELECT COUNT(*) INTO COUNT_hz_party_sites FROM hz_party_sites;

SELECT COUNT(*) INTO COUNT_hz_locations FROM hz_locations;

SELECT COUNT(*) INTO COUNT_ra_salesreps_all FROM ra_salesreps_all;

SELECT COUNT(*) INTO COUNT_fnd_territories_vl FROM fnd_territories_vl;

SELECT COUNT(*) INTO COUNT_hz_parties FROM hz_parties;

SELECT COUNT(*) INTO COUNT_hz_cust_accounts FROM hz_cust_accounts;

DSP_COUNT:= DSP_COUNT ||' COUNT_OE_ORDER_HEADERS-->' || COUNT_OE_ORDER_HEADERS || ' COUNT_oe_order_lines_all--->' || COUNT_oe_order_lines_all ||'COUNT_oe_transaction_types_tl--->' || COUNT_oe_transaction_types_tl || 'COUNT_hz_cust_site_uses_all--->' ||
COUNT_hz_cust_site_uses_all || 'COUNT_hz_cust_acct_sites_all--->' || COUNT_hz_cust_acct_sites_all || 'COUNT_hz_party_sites--->'||COUNT_hz_party_sites|| 'COUNT_hz_locations-->' ||COUNT_hz_locations||'COUNT_ra_salesreps_all-->' ||
COUNT_ra_salesreps_all||' COUNT_fnd_territories_vl-->'|| COUNT_fnd_territories_vl || 'COUNT_hz_parties--->' || COUNT_hz_parties||' COUNT_hz_cust_accounts-->'|| COUNT_hz_cust_accounts;

END;*/
/*------------------------------------------------------------------------------
Following PL/SQL block gets the company name, functional currency and precision.
------------------------------------------------------------------------------*/


  DECLARE
  l_company_name            VARCHAR2 (100);
  l_functional_currency     VARCHAR2  (15);

  BEGIN

    SELECT sob.name                   ,
	   sob.currency_code
    INTO
	   l_company_name ,
	   l_functional_currency
    FROM    gl_sets_of_books sob,
	    fnd_currencies cur
    WHERE  sob.set_of_books_id = p_sob_id
    AND    sob.currency_code = cur.currency_code
    ;

    rp_company_name            := l_company_name;
    rp_functional_currency     := l_functional_currency ;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL ;
  END ;

/*------------------------------------------------------------------------------
Following PL/SQL block gets the report name for the passed concurrent request Id.
------------------------------------------------------------------------------*/
  DECLARE
      l_report_name  VARCHAR2(240);
  BEGIN
      SELECT cp.user_concurrent_program_name
      INTO   l_report_name
      FROM   FND_CONCURRENT_PROGRAMS_VL cp,
	     FND_CONCURRENT_REQUESTS cr
      WHERE  cr.request_id     = P_CONC_REQUEST_ID
      AND    cp.application_id = cr.program_application_id
      AND    cp.concurrent_program_id = cr.concurrent_program_id
      ;

      RP_Report_Name := l_report_name;
  EXCEPTION
      WHEN NO_DATA_FOUND
      THEN RP_REPORT_NAME := 'Order/Invoice Detail Report';
  END;

/*------------------------------------------------------------------------------
Following PL/SQL block builds up the lexical parameters, to be used in the
WHERE clause of the query. This also populates the report level variables, used
to store the flexfield structure.
------------------------------------------------------------------------------*/
  /*BEGIN
    SRW.REFERENCE(P_item_flex_code);
    SRW.REFERENCE(P_item_structure_num);

    SRW.USER_EXIT('FND FLEXSQL CODE=":p_item_flex_code"
			   NUM=":p_item_structure_num"
			   APPL_SHORT_NAME="INV"
			   OUTPUT=":rp_item_flex_all_seg"
			   MODE="SELECT"
			   DISPLAY="ALL"
			   TABLEALIAS="SI"
			    ');
  EXCEPTION
    WHEN SRW.USER_EXIT_FAILURE THEN
    srw.message(2000,'Failed in BEFORE REPORT trigger. FND FLEXSQL USER_EXIT');
  END;*/


  DECLARE
      l_order_type_low             VARCHAR2 (50);
      l_order_type_high            VARCHAR2 (50);
      l_customer_name_low          VARCHAR2 (50);
      l_customer_name_high         VARCHAR2 (50);
      l_salesrep_low               VARCHAR2 (50);
      l_salesrep_high              VARCHAR2 (50);
      l_order_number_low           VARCHAR2 (50);
      l_order_number_high          VARCHAR2 (50);

  BEGIN

  if ( p_order_type_low is NULL) AND ( p_order_type_high is NULL ) then
    NULL ;
  else
    if p_order_type_low is NULL then
      l_order_type_low := '   ';
    else
      l_order_type_low := substr(l_order_type_low ,1,18);
    end if ;
    if p_order_type_high is NULL then
      l_order_type_high := '   ';
    else
      l_order_type_high := substr(l_order_type_high,1,18);
    end if ;
    rp_order_type_range  := 'From '||l_order_type_low||' To '||l_order_type_high ;

  end if ;


  if ( p_customer_name_low is NULL) AND ( p_customer_name_high is NULL ) then
    NULL ;
  else
    if p_customer_name_low is NULL then
      l_customer_name_low := '   ';
    else
      l_customer_name_low := substr(p_customer_name_low,1,18) ;
    end if ;
    if p_customer_name_high is NULL then
      l_customer_name_high := '   ';
    else
      l_customer_name_high := substr(p_customer_name_high,1,18);
    end if ;
    rp_customer_name_range  := 'From '||l_customer_name_low||' To '||l_customer_name_high ;
  end if ;

  if ( p_salesrep_low is NULL) AND ( p_salesrep_high is NULL ) then
    NULL ;
  else
    if p_salesrep_low is NULL then
      l_salesrep_low := '   ';
    else
      l_salesrep_low := substr(p_salesrep_low,1,18) ;
    end if ;
    if p_salesrep_high is NULL then
      l_salesrep_high := '   ';
    else
      l_salesrep_high := substr(p_salesrep_high,1,18);
    end if ;
    rp_salesrep_range  := 'From '||l_salesrep_low||' To '||l_salesrep_high ;
  end if ;

  if ( p_order_num_low is NULL) AND ( p_order_num_high is NULL ) then
    NULL ;
  else
    if p_order_num_low is NULL then
      l_order_number_low := '   ';
    else
      l_order_number_low := substr(p_order_num_low,1,18) ;
    end if ;
    if p_order_num_high is NULL then
      l_order_number_high := '   ';
    else
      l_order_number_high := substr((p_order_num_high),1,18);
    end if ;
    rp_order_number_range  := 'From '||l_order_number_low||' To '||l_order_number_high ;
  end if ;

  END ;

DECLARE
    l_meaning       VARCHAR2 (80);
  BEGIN
    SELECT MEANING
    INTO   l_meaning
    FROM OE_LOOKUPS
    WHERE LOOKUP_TYPE = 'ITEM_DISPLAY_CODE'
    AND LOOKUP_CODE  = substr(upper(p_print_description),1,1)
    ;

    rp_print_description := l_meaning ;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    rp_print_description := 'Internal Item Description';
  when OTHERS then
  /*srw.message(2000,'Failed in BEFORE REPORT trigger. Get Print Description'); */null;

  END ;

/*DECLARE
    l_meaning       VARCHAR2 (80);
  BEGIN
    SELECT MEANING
    INTO   l_meaning
    FROM  OE_LOOKUPS
    WHERE LOOKUP_TYPE = 'ITEM_DISPLAY_CODE'
    AND LOOKUP_CODE  = substr(upper(p_print_description),1,1)
    ;

    rp_print_description := l_meaning ;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    rp_print_description := 'Description';
  END ;
*/

DECLARE
    l_meaning       VARCHAR2 (80);
  BEGIN
    SELECT MEANING
    INTO   l_meaning
    FROM FND_LOOKUPS
    WHERE LOOKUP_TYPE = 'YES_NO'
    AND LOOKUP_CODE  = substr(upper(p_open_orders_only),1,1)
    ;

    rp_open_orders_only := l_meaning ;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    rp_open_orders_only := 'Yes';
  END ;

END ;
  RETURN (TRUE);
 END BEFOREREPORT;

FUNCTION ITEM_DSPFORMULA(ITEM_IDENTIFIER_TYPE IN VARCHAR2,INVENTORY_ITEM_ID IN NUMBER, C_MASTER_ORG IN VARCHAR2,ORDERED_ITEM_ID IN NUMBER,ORDERED_ITEM IN VARCHAR2,SI_ORGANIZATION_ID IN NUMBER, SI_INVENTORY_ITEM_ID IN NUMBER) RETURN VARCHAR2 IS
v_item varchar2(2000);
v_description varchar2(500);
begin
  if (item_identifier_type is null or item_identifier_type = 'INT')
       or (p_print_description in ('I','D','F')) then
    select sitems.description description
    into   v_description
    from   mtl_system_items_vl sitems
--    where  sitems.customer_order_enabled_flag = 'Y'
--    and    sitems.bom_item_type in (1,4)
    where    nvl(sitems.organization_id,0) = c_master_org
    and    sitems.inventory_item_id = ITEM_DSPFORMULA.inventory_item_id;
    rp_dummy_item := v_item;
      /*   srw.reference (:item_flex);
         srw.reference (:p_item_flex_code);
         srw.reference (:Item_dsp);
         srw.reference (:p_item_structure_num);
         srw.user_exit (' FND FLEXIDVAL
		    CODE=":p_item_flex_code"
		    NUM=":p_item_structure_num"
		    APPL_SHORT_NAME="INV"
		    DATA= ":item_flex"
		    VALUE=":Item_dsp"
		    DISPLAY="ALL"'
		);*/
   -- rp_dummy_item := '';
    v_item := fnd_flex_xml_publisher_apis.process_kff_combination_1('Item_dsp', 'INV', p_item_flex_code, p_item_structure_num, SI_ORGANIZATION_ID, SI_INVENTORY_ITEM_ID, 'ALL', 'Y', 'VALUE');
  elsif (item_identifier_type = 'CUST' and p_print_description in ('C','P','O')) then
    select citems.customer_item_number item,
    	   nvl(citems.customer_item_desc,sitems.description) description
    into   v_item,v_description
    from   mtl_customer_items citems,
           mtl_customer_item_xrefs cxref,
           mtl_system_items_vl sitems
    where  citems.customer_item_id = cxref.customer_item_id
    and    cxref.inventory_item_id = sitems.inventory_item_id
    and    citems.customer_item_id = ordered_item_id
    and    nvl(sitems.organization_id,0) = c_master_org
    and    sitems.inventory_item_id = ITEM_DSPFORMULA.inventory_item_id;
--    and    sitems.customer_order_enabled_flag = 'Y'
--    and    sitems.bom_item_type in (1,4)
  elsif (p_print_description in ('C','P','O')) then
    Begin
    select items.cross_reference item,
    	   nvl(items.description,sitems.description) description
    into   v_item,v_description
    from   mtl_cross_reference_types xtypes,
           mtl_cross_references items,
           mtl_system_items_vl sitems
    where  xtypes.cross_reference_type = items.cross_reference_type
    and    items.inventory_item_id = sitems.inventory_item_id
    and    items.cross_reference = ordered_item
    and    items.cross_reference_type = item_identifier_type
    and    nvl(sitems.organization_id,0) = c_master_org
    and    sitems.inventory_item_id = ITEM_DSPFORMULA.inventory_item_id
  --Bug 3433353 begin
    and    items.org_independent_flag = 'N'
    and    items.organization_id = c_master_org;
--    and    sitems.customer_order_enabled_flag = 'Y'
--    and    sitems.bom_item_type in (1,4)
    Exception When NO_DATA_FOUND Then
    select items.cross_reference item,
    nvl(items.description,sitems.description) description
    into v_item,v_description
    from mtl_cross_reference_types xtypes,
    mtl_cross_references items,
    mtl_system_items_vl sitems
    where xtypes.cross_reference_type =
    items.cross_reference_type
    and items.inventory_item_id =
    sitems.inventory_item_id
    and items.cross_reference = ordered_item
    and items.cross_reference_type = item_identifier_type
    and nvl(sitems.organization_id,0) = c_master_org
    and sitems.inventory_item_id = ITEM_DSPFORMULA.inventory_item_id
    and items.org_independent_flag = 'Y';
    End;
--Bug 343353 End
  end if;

  if (p_print_description in ('I','C')) then
    return(v_item||' - '||v_description);
  elsif (p_print_description in ('D','P')) then
    return(v_description);
  else
    return(v_item);
  end if;



RETURN NULL;
Exception
   When Others Then
        return('Item Not Found');
end ITEM_DSPFORMULA;
END ONT_OEXOEIOD_XMLP_PKG;



/
