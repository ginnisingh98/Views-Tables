--------------------------------------------------------
--  DDL for Package Body ONT_OEXOEOSR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_OEXOEOSR_XMLP_PKG" AS
/* $Header: OEXOEOSRB.pls 120.1 2007/12/25 07:23:40 npannamp noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      BEGIN
        P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
        P_ORDER_DATE_LOW_V:=to_char(P_ORDER_DATE_LOW,'DD-MON-YY');
        P_ORDER_DATE_HIGH_V:=to_char(P_ORDER_DATE_HIGH,'DD-MON-YY');
        --added as fix
        F1:=Oe_Sys_Parameters.Value('RECURRING_CHARGES',mo_global.get_current_org_id());
        /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
      EXCEPTION
        WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
          /*SRW.MESSAGE(1000
                     ,'Failed in BEFORE REPORT trigger')*/NULL;
          RETURN (FALSE);
      END;
      BEGIN
       -- P_ORG_ID := MO_GLOBAL.GET_CURRENT_ORG_ID;
        P_ORG_ID_V := MO_GLOBAL.GET_CURRENT_ORG_ID;
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
      DECLARE
        L_ORDER_SOURCE_NAME VARCHAR2(50);
      BEGIN
        SELECT
          NAME
        INTO L_ORDER_SOURCE_NAME
        FROM
          OE_ORDER_SOURCES
        WHERE ORDER_SOURCE_ID = NVL(P_ORDER_SOURCE
           ,-999);
        LP_ORDER_SOURCE_NAME := L_ORDER_SOURCE_NAME;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
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
          RP_REPORT_NAME := 'Orders Summary Report';
      END;
      DECLARE
        L_ORDER_TYPE_LOW_V VARCHAR2(50);
        L_ORDER_TYPE_HIGH_V VARCHAR2(50);
        L_CUSTOMER_NAME_LOW VARCHAR2(50);
        L_CUSTOMER_NAME_HIGH VARCHAR2(50);
        L_SALESREP_LOW VARCHAR2(50);
        L_SALESREP_HIGH VARCHAR2(50);
        L_ORDER_NUMBER_LOW VARCHAR2(50);
        L_ORDER_NUMBER_HIGH VARCHAR2(50);
        L_PO_NUMBER_LOW VARCHAR2(50);
        L_PO_NUMBER_HIGH VARCHAR2(50);
        L_ORDER_DATE_LOW VARCHAR2(50);
        L_ORDER_DATE_HIGH VARCHAR2(50);
        L_ORDER_STATUS_LOW VARCHAR2(50);
        L_ORDER_STATUS_HIGH VARCHAR2(50);
        L_COUNTRY_LOW VARCHAR2(50);
        L_COUNTRY_HIGH VARCHAR2(50);
        L_CREATED_BY_LOW VARCHAR2(50);
        L_CREATED_BY_HIGH VARCHAR2(50);
      BEGIN
        IF (P_ORDER_TYPE_LOW IS NULL) AND (P_ORDER_TYPE_HIGH IS NULL) THEN
          NULL;
        ELSE
          IF P_ORDER_TYPE_LOW IS NULL THEN
            L_ORDER_TYPE_LOW_V := '   ';
          ELSE
            L_ORDER_TYPE_LOW_V := SUBSTR(L_ORDER_TYPE_LOW
                                      ,1
                                      ,18);
          END IF;
          IF P_ORDER_TYPE_HIGH IS NULL THEN
            L_ORDER_TYPE_HIGH_V := '   ';
          ELSE
            L_ORDER_TYPE_HIGH_V := SUBSTR(L_ORDER_TYPE_HIGH
                                       ,1
                                       ,18);
          END IF;
          RP_ORDER_TYPE_RANGE := 'From ' || L_ORDER_TYPE_LOW_V || ' To ' || L_ORDER_TYPE_HIGH_V;
        END IF;
        IF (P_CUSTOMER_NAME_LOW IS NULL) AND (P_CUSTOMER_NAME_HIGH IS NULL) THEN
          NULL;
        ELSE
          IF P_CUSTOMER_NAME_LOW IS NULL THEN
            L_CUSTOMER_NAME_LOW := '   ';
          ELSE
            L_CUSTOMER_NAME_LOW := P_CUSTOMER_NAME_LOW;
          END IF;
          IF P_CUSTOMER_NAME_HIGH IS NULL THEN
            L_CUSTOMER_NAME_HIGH := '   ';
          ELSE
            L_CUSTOMER_NAME_HIGH := P_CUSTOMER_NAME_HIGH;
          END IF;
          RP_CUSTOMER_NAME_RANGE := 'From ' || L_CUSTOMER_NAME_LOW || ' To ' || L_CUSTOMER_NAME_HIGH;
        END IF;
        IF (P_SALESREP_LOW IS NULL) AND (P_SALESREP_HIGH IS NULL) THEN
          NULL;
        ELSE
          IF P_SALESREP_LOW IS NULL THEN
            L_SALESREP_LOW := '   ';
          ELSE
            L_SALESREP_LOW := SUBSTR(P_SALESREP_LOW
                                    ,1
                                    ,18);
          END IF;
          IF P_SALESREP_HIGH IS NULL THEN
            L_SALESREP_HIGH := '   ';
          ELSE
            L_SALESREP_HIGH := SUBSTR(P_SALESREP_HIGH
                                     ,1
                                     ,18);
          END IF;
          RP_SALESREP_RANGE := 'From ' || L_SALESREP_LOW || ' To ' || L_SALESREP_HIGH;
        END IF;
        IF (P_ORDER_NUM_LOW IS NULL) AND (P_ORDER_NUM_HIGH IS NULL) THEN
          NULL;
        ELSE
          IF P_ORDER_NUM_LOW IS NULL THEN
            L_ORDER_NUMBER_LOW := '   ';
          ELSE
            L_ORDER_NUMBER_LOW := SUBSTR(P_ORDER_NUM_LOW
                                        ,1
                                        ,18);
          END IF;
          IF P_ORDER_NUM_HIGH IS NULL THEN
            L_ORDER_NUMBER_HIGH := '   ';
          ELSE
            L_ORDER_NUMBER_HIGH := SUBSTR((P_ORDER_NUM_HIGH)
                                         ,1
                                         ,18);
          END IF;
          RP_ORDER_NUMBER_RANGE := 'From ' || L_ORDER_NUMBER_LOW || ' To ' || L_ORDER_NUMBER_HIGH;
        END IF;
        IF (P_PO_NUM_LOW IS NULL) AND (P_PO_NUM_HIGH IS NULL) THEN
          NULL;
        ELSE
          IF P_PO_NUM_LOW IS NULL THEN
            L_PO_NUMBER_LOW := '   ';
          ELSE
            L_PO_NUMBER_LOW := SUBSTR(P_PO_NUM_LOW
                                     ,1
                                     ,18);
          END IF;
          IF P_PO_NUM_HIGH IS NULL THEN
            L_PO_NUMBER_HIGH := '   ';
          ELSE
            L_PO_NUMBER_HIGH := SUBSTR((P_PO_NUM_HIGH)
                                      ,1
                                      ,18);
          END IF;
          RP_PO_NUMBER_RANGE := 'From ' || L_PO_NUMBER_LOW || ' To ' || L_PO_NUMBER_HIGH;
        END IF;
        IF (P_ORDER_DATE_LOW IS NULL) AND (P_ORDER_DATE_HIGH IS NULL) THEN
          NULL;
        ELSE
          IF P_ORDER_DATE_LOW IS NULL THEN
            L_ORDER_DATE_LOW := '   ';
          ELSE
            L_ORDER_DATE_LOW := P_ORDER_DATE_LOW;
          END IF;
          IF P_ORDER_DATE_HIGH IS NULL THEN
            L_ORDER_DATE_HIGH := '   ';
          ELSE
            L_ORDER_DATE_HIGH := P_ORDER_DATE_HIGH;
          END IF;
          --RP_ORDER_DATE_RANGE := 'From ' || L_ORDER_DATE_LOW || ' To ' || L_ORDER_DATE_HIGH;
          RP_ORDER_DATE_RANGE := 'From ' || substr(L_ORDER_DATE_LOW,1,7) ||substr(L_ORDER_DATE_LOW,10,11)|| ' To ' || substr(L_ORDER_DATE_HIGH,1,7)||substr(L_ORDER_DATE_HIGH,10,11);
        END IF;
        IF (P_ORDER_STATUS_LOW IS NULL) AND (P_ORDER_STATUS_HIGH IS NULL) THEN
          NULL;
        ELSE
          IF P_ORDER_STATUS_LOW IS NULL THEN
            L_ORDER_STATUS_LOW := '   ';
          ELSE
            L_ORDER_STATUS_LOW := SUBSTR(P_ORDER_STATUS_LOW
                                        ,1
                                        ,18);
          END IF;
          IF P_ORDER_STATUS_HIGH IS NULL THEN
            L_ORDER_STATUS_HIGH := '   ';
          ELSE
            L_ORDER_STATUS_HIGH := SUBSTR((P_ORDER_STATUS_HIGH)
                                         ,1
                                         ,18);
          END IF;
          RP_ORDER_STATUS_RANGE := 'From ' || L_ORDER_STATUS_LOW || ' To ' || L_ORDER_STATUS_HIGH;
        END IF;
        IF (P_COUNTRY_LOW IS NULL) AND (P_COUNTRY_HIGH IS NULL) THEN
          NULL;
        ELSE
          IF P_COUNTRY_LOW IS NULL THEN
            L_COUNTRY_LOW := '   ';
          ELSE
            L_COUNTRY_LOW := SUBSTR(P_COUNTRY_LOW
                                   ,1
                                   ,18);
          END IF;
          IF P_COUNTRY_HIGH IS NULL THEN
            L_COUNTRY_HIGH := '   ';
          ELSE
            L_COUNTRY_HIGH := SUBSTR((P_COUNTRY_HIGH)
                                    ,1
                                    ,18);
          END IF;
          RP_COUNTRY_RANGE := 'From ' || L_COUNTRY_LOW || ' To ' || L_COUNTRY_HIGH;
        END IF;
        IF (P_CREATED_BY_LOW IS NULL) AND (P_CREATED_BY_HIGH IS NULL) THEN
          NULL;
        ELSE
          IF P_CREATED_BY_LOW IS NULL THEN
            L_CREATED_BY_LOW := '   ';
          ELSE
            L_CREATED_BY_LOW := SUBSTR(P_CREATED_BY_LOW
                                      ,1
                                      ,18);
          END IF;
          IF P_CREATED_BY_HIGH IS NULL THEN
            L_CREATED_BY_HIGH := '   ';
          ELSE
            L_CREATED_BY_HIGH := SUBSTR((P_CREATED_BY_HIGH)
                                       ,1
                                       ,18);
          END IF;
          RP_CREATED_BY_RANGE := 'From ' || L_CREATED_BY_LOW || ' To ' || L_CREATED_BY_HIGH;
        END IF;
      END;
      DECLARE
        L_AGREEMENT_NAME VARCHAR2(50);
      BEGIN
        IF (P_AGREEMENT IS NOT NULL) THEN
          BEGIN
            SELECT
              NAME
            INTO L_AGREEMENT_NAME
            FROM
              OE_AGREEMENTS
            WHERE AGREEMENT_ID = P_AGREEMENT;
            RP_AGREEMENT := L_AGREEMENT_NAME;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              RP_AGREEMENT := NULL;
          END;
        END IF;
      END;
      DECLARE
        L_MEANING VARCHAR2(80);
        L_LOOKUP_TYPE VARCHAR2(80);
      BEGIN
        L_LOOKUP_TYPE := 'YES_NO';
        SELECT
          MEANING
        INTO L_MEANING
        FROM
          FND_LOOKUPS
        WHERE LOOKUP_TYPE = L_LOOKUP_TYPE
          AND LOOKUP_CODE = SUBSTR(UPPER(P_OPEN_ORDERS_ONLY)
              ,1
              ,1);
        RP_OPEN_ORDERS_ONLY := L_MEANING;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RP_OPEN_ORDERS_ONLY := 'Yes';
      END;
      IF P_ORDER_BY IS NOT NULL THEN
        DECLARE
          ORDER_BY VARCHAR2(80);
          L_LOOKUP_TYPE VARCHAR2(80);
          L_LOOKUP_CODE VARCHAR2(80);
        BEGIN
          L_LOOKUP_TYPE := 'ONT_OEXOEOSR_XMLP_PKG SORT BY';
          L_LOOKUP_CODE := P_ORDER_BY;
          SELECT
            MEANING
          INTO ORDER_BY
          FROM
            OE_LOOKUPS
          WHERE LOOKUP_TYPE = L_LOOKUP_TYPE
            AND LOOKUP_CODE = L_LOOKUP_CODE;
          RP_ORDER_BY := ORDER_BY;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            RP_ORDER_BY := P_ORDER_BY;
        END;
      END IF;
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
    /*SRW.MESSAGE(99999
               ,'$Header: ONT_OEXOEOSR_XMLP_PKG.rdf 120.7 2006/04/28 02:43 ddey ship
	       $')*/NULL;
    /*SRW.MESSAGE(99999
               ,'Oracle - Test Report')*/NULL;
    BEGIN
      IF (P_ORDER_TYPE_LOW IS NOT NULL) AND (P_ORDER_TYPE_HIGH IS NOT NULL) THEN
        IF (P_ORDER_TYPE_LOW = P_ORDER_TYPE_HIGH) THEN
          LP_ORDER_TYPE := ' and ot.transaction_type_id = :p_order_type_low ';
          SELECT
            OEOT.NAME
          INTO L_ORDER_TYPE_LOW
          FROM
            OE_TRANSACTION_TYPES_TL OEOT
          WHERE OEOT.TRANSACTION_TYPE_ID = P_ORDER_TYPE_LOW
            AND OEOT.LANGUAGE = USERENV('LANG');
        ELSE
          LP_ORDER_TYPE := 'and ( ot.transaction_type_id between :p_order_type_low and :p_order_type_high ) ';
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
        END IF;
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
        LP_ORDER_TYPE := 'and ot.transaction_type_id <= :p_order_type_high ';
        SELECT
          OEOT.NAME
        INTO L_ORDER_TYPE_HIGH
        FROM
          OE_TRANSACTION_TYPES_TL OEOT
        WHERE OEOT.TRANSACTION_TYPE_ID = P_ORDER_TYPE_HIGH
          AND OEOT.LANGUAGE = USERENV('LANG');
      END IF;
      IF (P_CUSTOMER_NAME_LOW IS NOT NULL) AND (P_CUSTOMER_NAME_HIGH IS NOT NULL) THEN
        IF (P_CUSTOMER_NAME_LOW = P_CUSTOMER_NAME_HIGH) THEN
          LP_CUSTOMER_NAME := ' and party.party_name = :p_customer_name_low ';
        ELSE
          LP_CUSTOMER_NAME := 'and ( party.party_name between :p_customer_name_low and :p_customer_name_high ) ';
        END IF;
      ELSIF (P_CUSTOMER_NAME_LOW IS NOT NULL) THEN
        LP_CUSTOMER_NAME := 'and party.party_name >= :p_customer_name_low ';
      ELSIF (P_CUSTOMER_NAME_HIGH IS NOT NULL) THEN
        LP_CUSTOMER_NAME := 'and party.party_name <= :p_customer_name_high ';
      END IF;
      IF (P_ORDER_NUM_LOW IS NOT NULL) AND (P_ORDER_NUM_HIGH IS NOT NULL) THEN
        IF (P_ORDER_NUM_LOW = P_ORDER_NUM_HIGH) THEN
          LP_ORDER_NUM := 'and h.order_number = :p_order_num_low ';
        ELSE
          LP_ORDER_NUM := 'and ( h.order_number between to_number(:p_order_num_low) and to_number(:p_order_num_high) ) ';
        END IF;
      ELSIF (P_ORDER_NUM_LOW IS NOT NULL) THEN
        LP_ORDER_NUM := 'and h.order_number >= to_number(:p_order_num_low) ';
      ELSIF (P_ORDER_NUM_HIGH IS NOT NULL) THEN
        LP_ORDER_NUM := 'and h.order_number <= to_number(:p_order_num_high) ';
      END IF;
      IF (P_SALESREP_LOW IS NOT NULL) AND (P_SALESREP_HIGH IS NOT NULL) THEN
        IF (P_SALESREP_LOW = P_SALESREP_HIGH) THEN
          LP_SALESREP := ' and sr.name = :p_salesrep_low ';
        ELSE
          LP_SALESREP := 'and  sr.name between :p_salesrep_low and :p_salesrep_high ';
        END IF;
      ELSIF (P_SALESREP_LOW IS NOT NULL) THEN
        LP_SALESREP := 'and sr.name >= :p_salesrep_low ';
      ELSIF (P_SALESREP_HIGH IS NOT NULL) THEN
        LP_SALESREP := 'and sr.name <= :p_salesrep_high ';
      END IF;
      IF (P_COUNTRY_LOW IS NOT NULL) AND (P_COUNTRY_HIGH IS NOT NULL) THEN
        LP_COUNTRY := 'and ( terr.territory_short_name between :p_country_low and :p_country_high ) ';
      ELSIF (P_COUNTRY_LOW IS NOT NULL) THEN
        LP_COUNTRY := 'and terr.territory_short_name >= :p_country_low ';
      ELSIF (P_COUNTRY_HIGH IS NOT NULL) THEN
        LP_COUNTRY := 'and terr.territory_short_name <= :p_country_high ';
      END IF;
      IF (P_PO_NUM_LOW IS NOT NULL) AND (P_PO_NUM_HIGH IS NOT NULL) THEN
        IF (P_PO_NUM_LOW = P_PO_NUM_HIGH) THEN
          LP_PO_NUM := ' and h.cust_po_number = :p_po_num_low ';
        ELSE
          LP_PO_NUM := 'and ( h.cust_po_number between :p_po_num_low and :p_po_num_high ) ';
        END IF;
      ELSIF (P_PO_NUM_LOW IS NOT NULL) THEN
        LP_PO_NUM := 'and h.cust_po_number >= :p_po_num_low ';
      ELSIF (P_PO_NUM_HIGH IS NOT NULL) THEN
        LP_PO_NUM := 'and h.cust_po_number <= :p_po_num_high ';
      END IF;
      IF P_ORDER_DATE_LOW IS NOT NULL AND P_ORDER_DATE_HIGH IS NOT NULL THEN
        LP_ORDER_DATE := ' AND  h.ordered_date  >=  :p_order_date_low and  h.ordered_date  < :p_order_date_high+1';
      ELSIF (P_ORDER_DATE_LOW IS NOT NULL) THEN
        LP_ORDER_DATE := 'and h.ordered_date >= :p_order_date_low';
      ELSIF (P_ORDER_DATE_HIGH IS NOT NULL) THEN
        LP_ORDER_DATE := 'and h.ordered_date <= :p_order_date_high+1';
      END IF;
      IF P_CREATED_BY_LOW IS NOT NULL AND P_CREATED_BY_HIGH IS NOT NULL THEN
        LP_CREATED_BY := ' AND  u.user_name  between :p_created_by_low and  :p_created_by_high';
      ELSIF (P_CREATED_BY_LOW IS NOT NULL) THEN
        LP_CREATED_BY := 'and u.user_name >= :p_created_by_low';
      ELSIF (P_CREATED_BY_HIGH IS NOT NULL) THEN
        LP_CREATED_BY := 'and u.user_name <= :p_created_by_high';
      END IF;
      IF (P_AGREEMENT IS NOT NULL) THEN
        LP_AGREEMENT := 'and  agree.agreement_id = :p_agreement';
      END IF;
      IF (P_ORDER_SOURCE IS NOT NULL) THEN
        LP_ORDER_SOURCE := 'and  h.order_source_id = :p_order_source ';
      END IF;
      IF P_OPEN_ORDERS_ONLY = 'Y' THEN
        LP_OPEN_ORDERS_ONLY := 'and nvl(h.open_flag,''N'') = ''Y'' ';
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
      RETURN ('  Currency');
    ELSIF SUBSTR(UPPER(P_ORDER_BY)
          ,1
          ,1) = 'S' THEN
      RETURN ('    Currency');
    ELSE
      RETURN ('Currency');
    END IF;
    RETURN NULL;
  END RP_CURR_LABELFORMULA;

  FUNCTION C_ORDER_COUNTFORMULA RETURN NUMBER IS
  BEGIN
    RETURN (1);
  END C_ORDER_COUNTFORMULA;

  FUNCTION C_LINE_COUNTFORMULA(HEADER_ID1 IN NUMBER) RETURN NUMBER IS
  BEGIN
    DECLARE
      L_COUNT NUMBER(20);
    BEGIN
      /*SRW.REFERENCE(HEADER_ID1)*/NULL;
      L_COUNT := 0;
      SELECT
        COUNT(1)
      INTO L_COUNT
      FROM
        OE_ORDER_LINES_ALL L
      WHERE L.HEADER_ID = HEADER_ID1;
      RETURN (L_COUNT);
    END;
    RETURN NULL;
  END C_LINE_COUNTFORMULA;

  FUNCTION RP_USE_FUNCTIONAL_CURRENCYFORM RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      L_TEMP VARCHAR2(100);
      L_LOOKUP_TYPE VARCHAR2(80);
      L_LOOKUP_CODE VARCHAR2(80);
    BEGIN
      L_LOOKUP_TYPE := 'YES_NO';
      L_LOOKUP_CODE := P_USE_FUNCTIONAL_CURRENCY;
      SELECT
        MEANING
      INTO L_TEMP
      FROM
        FND_LOOKUPS
      WHERE LOOKUP_CODE = L_LOOKUP_CODE
        AND LOOKUP_TYPE = L_LOOKUP_TYPE;
      RETURN (L_TEMP);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN ('No');
    END;
    RETURN NULL;
  END RP_USE_FUNCTIONAL_CURRENCYFORM;

  FUNCTION C_ORDER_AMOUNTFORMULA(CURRENCY1 IN VARCHAR2
                                ,ORDER_AMOUNT IN NUMBER
                                ,CONVERSION_TYPE_CODE IN VARCHAR2
                                ,ORDER_DATE IN DATE
                                ,CONVERSION_RATE IN NUMBER) RETURN NUMBER IS
  BEGIN
    DECLARE
      L_CONVERSION_RATE NUMBER;
    BEGIN
      /*SRW.REFERENCE(CURRENCY1)*/NULL;
      /*SRW.REFERENCE(RP_FUNCTIONAL_CURRENCY)*/NULL;
      /*SRW.REFERENCE(ORDER_AMOUNT)*/NULL;
      /*SRW.REFERENCE(CONVERSION_TYPE_CODE)*/NULL;
      /*SRW.REFERENCE(ORDER_DATE)*/NULL;
      L_CONVERSION_RATE := 0;
      IF P_USE_FUNCTIONAL_CURRENCY = 'N' THEN
        RETURN (ROUND(NVL(ORDER_AMOUNT
                        ,0)
                    ,2));
      ELSIF P_USE_FUNCTIONAL_CURRENCY = 'Y' THEN
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
        RETURN (NVL(L_CONVERSION_RATE
                  ,0) * ROUND(NVL(ORDER_AMOUNT
                        ,0)
                    ,2));
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN (0);
      WHEN OTHERS THEN
        RETURN (0);
    END;
    RETURN NULL;
  END C_ORDER_AMOUNTFORMULA;

  FUNCTION C_LIST_AMOUNTFORMULA(CURRENCY1 IN VARCHAR2
                               ,LIST_VALUE IN NUMBER
                               ,CONVERSION_TYPE_CODE IN VARCHAR2
                               ,ORDER_DATE IN DATE
                               ,CONVERSION_RATE IN NUMBER) RETURN NUMBER IS
  BEGIN
    DECLARE
      L_CONVERSION_RATE NUMBER;
    BEGIN
      /*SRW.REFERENCE(CURRENCY1)*/NULL;
      /*SRW.REFERENCE(RP_FUNCTIONAL_CURRENCY)*/NULL;
      /*SRW.REFERENCE(LIST_VALUE)*/NULL;
      /*SRW.REFERENCE(CONVERSION_TYPE_CODE)*/NULL;
      /*SRW.REFERENCE(ORDER_DATE)*/NULL;
      L_CONVERSION_RATE := 0;
      IF P_USE_FUNCTIONAL_CURRENCY = 'N' THEN
        RETURN (ROUND(NVL(LIST_VALUE
                        ,0)
                    ,2));
      ELSIF P_USE_FUNCTIONAL_CURRENCY = 'Y' THEN
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
        RETURN (NVL(L_CONVERSION_RATE
                  ,0) * ROUND(NVL(LIST_VALUE
                        ,0)
                    ,2));
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN (0);
      WHEN OTHERS THEN
        RETURN (0);
    END;
  END C_LIST_AMOUNTFORMULA;

  FUNCTION C_SHIPPED_AMOUNTFORMULA(CURRENCY1 IN VARCHAR2
                                  ,SHIP_VALUE IN NUMBER
                                  ,CONVERSION_TYPE_CODE IN VARCHAR2
                                  ,ORDER_DATE IN DATE
                                  ,CONVERSION_RATE IN NUMBER) RETURN NUMBER IS
  BEGIN
    DECLARE
      L_CONVERSION_RATE NUMBER;
    BEGIN
      /*SRW.REFERENCE(CURRENCY1)*/NULL;
      /*SRW.REFERENCE(RP_FUNCTIONAL_CURRENCY)*/NULL;
      /*SRW.REFERENCE(SHIP_VALUE)*/NULL;
      /*SRW.REFERENCE(CONVERSION_TYPE_CODE)*/NULL;
      /*SRW.REFERENCE(ORDER_DATE)*/NULL;
      L_CONVERSION_RATE := 0;
      IF P_USE_FUNCTIONAL_CURRENCY = 'N' THEN
        RETURN (ROUND(NVL(SHIP_VALUE
                        ,0)
                    ,2));
      ELSIF P_USE_FUNCTIONAL_CURRENCY = 'Y' THEN
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
        RETURN (NVL(L_CONVERSION_RATE
                  ,0) * ROUND(NVL(SHIP_VALUE
                        ,0)
                    ,2));
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN (0);
      WHEN OTHERS THEN
        RETURN (0);
    END;
  END C_SHIPPED_AMOUNTFORMULA;

  FUNCTION CF_1FORMULA(CHARGE_PERIODICITY_CODE IN VARCHAR2) RETURN CHAR IS
    L_UOM_CLASS VARCHAR2(50) := FND_PROFILE.VALUE('ONT_UOM_CLASS_CHARGE_PERIODICITY');
    L_CHARGE_PERIODICITY VARCHAR2(25);
  BEGIN
    IF CHARGE_PERIODICITY_CODE IS NOT NULL THEN
      SELECT
        UNIT_OF_MEASURE
      INTO L_CHARGE_PERIODICITY
      FROM
        MTL_UNITS_OF_MEASURE_VL
      WHERE UOM_CLASS = L_UOM_CLASS
        AND UOM_CODE = CHARGE_PERIODICITY_CODE;
      RETURN L_CHARGE_PERIODICITY;
    ELSE
      RETURN (P_ONE_TIME);
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
  END CF_1FORMULA;

  FUNCTION C_CURRENCYFORMULA(CURRENCY1 IN VARCHAR2) RETURN CHAR IS
  BEGIN
    IF P_USE_FUNCTIONAL_CURRENCY = 'N' THEN
      RETURN (CURRENCY1);
    ELSE
      RETURN (RP_FUNCTIONAL_CURRENCY);
    END IF;
  END C_CURRENCYFORMULA;

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

  FUNCTION RP_PO_NUMBER_RANGE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_PO_NUMBER_RANGE;
  END RP_PO_NUMBER_RANGE_P;

  FUNCTION RP_ORDER_DATE_RANGE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_ORDER_DATE_RANGE;
  END RP_ORDER_DATE_RANGE_P;

  FUNCTION RP_ORDER_STATUS_RANGE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_ORDER_STATUS_RANGE;
  END RP_ORDER_STATUS_RANGE_P;

  FUNCTION RP_COUNTRY_RANGE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_COUNTRY_RANGE;
  END RP_COUNTRY_RANGE_P;

  FUNCTION RP_CREATED_BY_RANGE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_CREATED_BY_RANGE;
  END RP_CREATED_BY_RANGE_P;

  FUNCTION RP_ORDER_BY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_ORDER_BY;
  END RP_ORDER_BY_P;

  FUNCTION RP_AGREEMENT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_AGREEMENT;
  END RP_AGREEMENT_P;

  FUNCTION IS_FIXED_RATE(X_FROM_CURRENCY IN VARCHAR2
                        ,X_TO_CURRENCY IN VARCHAR2
                        ,X_EFFECTIVE_DATE IN DATE) RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
  begin X0 := GL_CURRENCY_API.IS_FIXED_RATE(X_FROM_CURRENCY, X_TO_CURRENCY, X_EFFECTIVE_DATE);
  end;
    /*STPROC.INIT('begin :X0 := GL_CURRENCY_API.IS_FIXED_RATE(:X_FROM_CURRENCY, :X_TO_CURRENCY, :X_EFFECTIVE_DATE); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(X_FROM_CURRENCY);
    STPROC.BIND_I(X_TO_CURRENCY);
    STPROC.BIND_I(X_EFFECTIVE_DATE);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/
    RETURN X0;
  END IS_FIXED_RATE;

  PROCEDURE GET_RELATION(X_FROM_CURRENCY IN VARCHAR2
                        ,X_TO_CURRENCY IN VARCHAR2
                        ,X_EFFECTIVE_DATE IN DATE
                        ,X_FIXED_RATE IN OUT NOCOPY BOOLEAN
                        ,X_RELATIONSHIP IN OUT NOCOPY VARCHAR2) IS
  BEGIN

    /*

    STPROC.BIND_IO(X_FIXED_RATE);
    STPROC.BIND_I(X_FROM_CURRENCY);
    STPROC.BIND_I(X_TO_CURRENCY);
    STPROC.BIND_I(X_EFFECTIVE_DATE);
    STPROC.BIND_IO(X_RELATIONSHIP);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X_FIXED_RATE);
    STPROC.RETRIEVE(5
                   ,X_RELATIONSHIP);*/null;
  END GET_RELATION;

  FUNCTION GET_EURO_CODE RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
  begin
  X0 := GL_CURRENCY_API.GET_EURO_CODE;
  end;
    /*STPROC.INIT('begin :X0 := GL_CURRENCY_API.GET_EURO_CODE; end;');
    STPROC.BIND_O(X0);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/
    RETURN X0;
  END GET_EURO_CODE;

  FUNCTION GET_RATE(X_FROM_CURRENCY IN VARCHAR2
                   ,X_TO_CURRENCY IN VARCHAR2
                   ,X_CONVERSION_DATE IN DATE
                   ,X_CONVERSION_TYPE IN VARCHAR2) RETURN NUMBER IS
    X0 NUMBER;
  BEGIN
   /* STPROC.INIT('begin :X0 := GL_CURRENCY_API.GET_RATE(:X_FROM_CURRENCY, :X_TO_CURRENCY, :X_CONVERSION_DATE, :X_CONVERSION_TYPE); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(X_FROM_CURRENCY);
    STPROC.BIND_I(X_TO_CURRENCY);
    STPROC.BIND_I(X_CONVERSION_DATE);
    STPROC.BIND_I(X_CONVERSION_TYPE);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/null;
    RETURN X0;
  END GET_RATE;

  FUNCTION GET_RATE(X_SET_OF_BOOKS_ID IN NUMBER
                   ,X_FROM_CURRENCY IN VARCHAR2
                   ,X_CONVERSION_DATE IN DATE
                   ,X_CONVERSION_TYPE IN VARCHAR2) RETURN NUMBER IS
    X0 NUMBER;
  BEGIN
    /*STPROC.INIT('begin :X0 := GL_CURRENCY_API.GET_RATE(:X_SET_OF_BOOKS_ID, :X_FROM_CURRENCY, :X_CONVERSION_DATE, :X_CONVERSION_TYPE); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(X_SET_OF_BOOKS_ID);
    STPROC.BIND_I(X_FROM_CURRENCY);
    STPROC.BIND_I(X_CONVERSION_DATE);
    STPROC.BIND_I(X_CONVERSION_TYPE);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/null;
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
                   ,X0);*/ null;
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
                   ,X0);*/ null;
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
                   ,X0);*/null;
    RETURN X0;
  END GET_DERIVE_TYPE;

END ONT_OEXOEOSR_XMLP_PKG;



/
