--------------------------------------------------------
--  DDL for Package Body ONT_OEXPRPRS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_OEXPRPRS_XMLP_PKG" AS
/* $Header: OEXPRPRSB.pls 120.2 2008/01/04 07:26:26 nchinnam noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      BEGIN
 F1:=Oe_Sys_Parameters.Value('RECURRING_CHARGES',mo_global.get_current_org_id());
        P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
        /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
        /*SRW.MESSAGE(5000
                   ,'Changed Report is running')*/NULL;
      EXCEPTION
        WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
          /*SRW.MESSAGE(1000
                     ,'Failed in BEFORE REPORT trigger')*/NULL;
          RETURN (FALSE);
      END;
      BEGIN
        P_ORGANIZATION_ID := MO_GLOBAL.GET_CURRENT_ORG_ID;
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
	  L_REPORT_NAME := substr(L_REPORT_NAME,1,instr(L_REPORT_NAME,' (XML)'));
        RP_REPORT_NAME := L_REPORT_NAME;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RP_REPORT_NAME := 'Pricing Report - Summary ';
      END;
      DECLARE
        L_ORDER_DATE_LOW VARCHAR2(50);
        L_ORDER_DATE_HIGH VARCHAR2(50);
        L_ORDER_AMOUNT_LOW VARCHAR2(50);
        L_ORDER_AMOUNT_HIGH VARCHAR2(50);
        L_ORDER_LIST_LOW VARCHAR2(50);
        L_ORDER_LIST_HIGH VARCHAR2(50);
        L_ORDER_NUMBER_LOW VARCHAR2(50);
        L_ORDER_NUMBER_HIGH VARCHAR2(50);
        L_ORDER_TYPE_LOW VARCHAR2(50);
        L_ORDER_TYPE_HIGH VARCHAR2(50);
        L_SALESREP_LOW VARCHAR2(50);
        L_SALESREP_HIGH VARCHAR2(50);
        L_CUSTOMER_NUMBER_LOW VARCHAR2(50);
        L_CUSTOMER_NUMBER_HIGH VARCHAR2(50);
        L_CUSTOMER_NAME_LOW VARCHAR2(50);
        L_CUSTOMER_NAME_HIGH VARCHAR2(50);
      BEGIN
        IF (P_ORDER_DATE_LOW IS NULL) AND (P_ORDER_DATE_HIGH IS NULL) THEN
          NULL;
        ELSE
          IF P_ORDER_DATE_LOW IS NULL THEN
            L_ORDER_DATE_LOW := '   ';
          ELSE
            L_ORDER_DATE_LOW := TO_CHAR(P_ORDER_DATE_LOW
                                       ,'DD-MON-YYYY');
          END IF;
          IF P_ORDER_DATE_HIGH IS NULL THEN
            L_ORDER_DATE_HIGH := '   ';
          ELSE
            L_ORDER_DATE_HIGH := TO_CHAR(P_ORDER_DATE_HIGH
                                        ,'DD-MON-YYYY');
          END IF;
          RP_ORDER_DATE_RANGE := 'From ' || L_ORDER_DATE_LOW || ' To ' || L_ORDER_DATE_HIGH;
        END IF;
        IF (P_ORDER_AMOUNT_LOW IS NULL) AND (P_ORDER_AMOUNT_HIGH IS NULL) THEN
          NULL;
        ELSE
          IF P_ORDER_AMOUNT_LOW IS NULL THEN
            L_ORDER_AMOUNT_LOW := '   ';
          ELSE
            L_ORDER_AMOUNT_LOW := SUBSTR(TO_CHAR(P_ORDER_AMOUNT_LOW)
                                        ,1
                                        ,18);
          END IF;
          IF P_ORDER_AMOUNT_HIGH IS NULL THEN
            L_ORDER_AMOUNT_HIGH := '   ';
          ELSE
            L_ORDER_AMOUNT_HIGH := SUBSTR(TO_CHAR(P_ORDER_AMOUNT_HIGH)
                                         ,1
                                         ,18);
          END IF;
          RP_ORDER_AMOUNT_RANGE := 'From ' || L_ORDER_AMOUNT_LOW || ' To ' || L_ORDER_AMOUNT_HIGH;
        END IF;
        IF (P_ORDER_LIST_LOW IS NULL) AND (P_ORDER_LIST_HIGH IS NULL) THEN
          NULL;
        ELSE
          IF P_ORDER_LIST_LOW IS NULL THEN
            L_ORDER_LIST_LOW := '   ';
          ELSE
            L_ORDER_LIST_LOW := SUBSTR(TO_CHAR(P_ORDER_LIST_LOW)
                                      ,1
                                      ,18);
          END IF;
          IF P_ORDER_LIST_HIGH IS NULL THEN
            L_ORDER_LIST_HIGH := '   ';
          ELSE
            L_ORDER_LIST_HIGH := SUBSTR(TO_CHAR(P_ORDER_LIST_HIGH)
                                       ,1
                                       ,18);
          END IF;
          RP_ORDER_LIST_RANGE := 'From ' || L_ORDER_LIST_LOW || ' To ' || L_ORDER_LIST_HIGH;
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
        IF (P_CUSTOMER_NUMBER_LO IS NULL) AND (P_CUSTOMER_NUMBER_HI IS NULL) THEN
          NULL;
        ELSE
          IF P_CUSTOMER_NUMBER_LO IS NULL THEN
            L_CUSTOMER_NUMBER_LOW := '   ';
          ELSE
            L_CUSTOMER_NUMBER_LOW := SUBSTR(P_CUSTOMER_NUMBER_LO
                                           ,1
                                           ,18);
          END IF;
          IF P_CUSTOMER_NUMBER_HI IS NULL THEN
            L_CUSTOMER_NUMBER_HIGH := '   ';
          ELSE
            L_CUSTOMER_NUMBER_HIGH := SUBSTR((P_CUSTOMER_NUMBER_HI)
                                            ,1
                                            ,18);
          END IF;
          RP_CUSTOMER_NUMBER_RANGE := 'From ' || L_CUSTOMER_NUMBER_LOW || ' To ' || L_CUSTOMER_NUMBER_HIGH;
        END IF;
        IF (P_CUSTOMER_NAME_LO IS NULL) AND (P_CUSTOMER_NAME_HI IS NULL) THEN
          NULL;
        ELSE
          IF P_CUSTOMER_NAME_LO IS NULL THEN
            L_CUSTOMER_NAME_LOW := '   ';
          ELSE
            L_CUSTOMER_NAME_LOW := SUBSTR(P_CUSTOMER_NAME_LO
                                         ,1
                                         ,18);
          END IF;
          IF P_CUSTOMER_NAME_HI IS NULL THEN
            L_CUSTOMER_NAME_HIGH := '   ';
          ELSE
            L_CUSTOMER_NAME_HIGH := SUBSTR((P_CUSTOMER_NAME_HI)
                                          ,1
                                          ,18);
          END IF;
          RP_CUSTOMER_NAME_RANGE := 'From ' || L_CUSTOMER_NAME_LOW || ' To ' || L_CUSTOMER_NAME_HIGH;
        END IF;
        IF (P_ORDER_TYPE_LO IS NULL) AND (P_ORDER_TYPE_HI IS NULL) THEN
          NULL;
        ELSE
          IF P_ORDER_TYPE_LO IS NULL THEN
            L_ORDER_TYPE_LOW := '   ';
          ELSE
            L_ORDER_TYPE_LOW := SUBSTR(L_ORDER_TYPE_LOW
                                      ,1
                                      ,18);
          END IF;
          IF P_ORDER_TYPE_HI IS NULL THEN
            L_ORDER_TYPE_HIGH := '   ';
          ELSE
            L_ORDER_TYPE_HIGH := SUBSTR((L_ORDER_TYPE_HIGH)
                                       ,1
                                       ,18);
          END IF;
          RP_ORDER_TYPE_RANGE := 'From ' || L_ORDER_TYPE_LOW || ' To ' || L_ORDER_TYPE_HIGH;
        END IF;
        IF (P_SALESREP_LO IS NULL) AND (P_SALESREP_HI IS NULL) THEN
          NULL;
        ELSE
          IF P_SALESREP_LO IS NULL THEN
            L_SALESREP_LOW := '   ';
          ELSE
            L_SALESREP_LOW := SUBSTR(P_SALESREP_LO
                                    ,1
                                    ,18);
          END IF;
          IF P_SALESREP_HI IS NULL THEN
            L_SALESREP_HIGH := '   ';
          ELSE
            L_SALESREP_HIGH := SUBSTR((P_SALESREP_HI)
                                     ,1
                                     ,18);
          END IF;
          RP_SALESREP_RANGE := 'From ' || L_SALESREP_LOW || ' To ' || L_SALESREP_HIGH;
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
      DECLARE
        L_MEANING VARCHAR2(80);
        L_LOOKUP_TYPE VARCHAR2(80);
        L_LOOKUP_CODE VARCHAR2(80);
      BEGIN
        L_LOOKUP_TYPE := 'REPORT_ORDER_CATEGORY';
        L_LOOKUP_CODE := P_ORDER_CATEGORY;
        SELECT
          MEANING
        INTO L_MEANING
        FROM
          OE_LOOKUPS
        WHERE LOOKUP_TYPE = L_LOOKUP_TYPE
          AND LOOKUP_CODE = L_LOOKUP_CODE;
        RP_ORDER_CATEGORY := L_MEANING;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RP_ORDER_CATEGORY := 'All Orders';
      END;
      DECLARE
        L_MEANING VARCHAR2(80);
        L_LOOKUP_TYPE VARCHAR2(80);
        L_LOOKUP_CODE VARCHAR2(80);
      BEGIN
        L_LOOKUP_TYPE := 'REPORT_LINE_DISPLAY';
        L_LOOKUP_CODE := P_LINE_CATEGORY;
        SELECT
          MEANING
        INTO L_MEANING
        FROM
          OE_LOOKUPS
        WHERE LOOKUP_TYPE = L_LOOKUP_TYPE
          AND LOOKUP_CODE = L_LOOKUP_CODE;
        RP_LINE_CATEGORY := L_MEANING;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RP_LINE_CATEGORY := 'All Lines';
      END;
    EXCEPTION
      WHEN OTHERS THEN
        /*SRW.MESSAGE(4000
                   ,' Error in Before Report Trigger')*/NULL;
    END;
    DECLARE
      L_AGREEMENT_NAME VARCHAR2(240);
    BEGIN
      IF (P_AGREEMENT IS NOT NULL) THEN
        BEGIN
          SELECT
            NAME
          INTO L_AGREEMENT_NAME
          FROM
            OE_AGREEMENTS
          WHERE AGREEMENT_ID = P_AGREEMENT;
          RP_AGREEMENT_NAME := L_AGREEMENT_NAME;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            RP_AGREEMENT_NAME := NULL;
        END;
      END IF;
    END;
    RETURN (TRUE);
  END BEFOREREPORT;
  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      EXECUTE IMMEDIATE
        'alter session set sql_trace=false';
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
      IF (P_CUSTOMER_NAME_LO IS NOT NULL) AND (P_CUSTOMER_NAME_HI IS NOT NULL) THEN
        LP_CUSTOMER_NAME := 'and ( PARTY.PARTY_NAME between :p_customer_name_lo and :p_customer_name_hi ) ';
      ELSIF (P_CUSTOMER_NAME_LO IS NOT NULL) THEN
        LP_CUSTOMER_NAME := 'and PARTY.PARTY_NAME >= :p_customer_name_lo ';
      ELSIF (P_CUSTOMER_NAME_HI IS NOT NULL) THEN
        LP_CUSTOMER_NAME := 'and PARTY.PARTY_NAME <= :p_customer_name_hi ';
      END IF;
      IF (P_CUSTOMER_NUMBER_LO IS NOT NULL) AND (P_CUSTOMER_NUMBER_HI IS NOT NULL) THEN
        LP_CUSTOMER_NUMBER := 'and ( CUST_ACCT.ACCOUNT_NUMBER between :p_customer_number_lo and :p_customer_number_hi ) ';
      ELSIF (P_CUSTOMER_NUMBER_LO IS NOT NULL) THEN
        LP_CUSTOMER_NUMBER := 'and CUST_ACCT.ACCOUNT_NUMBER >= :p_customer_number_lo ';
      ELSIF (P_CUSTOMER_NUMBER_HI IS NOT NULL) THEN
        LP_CUSTOMER_NUMBER := 'and CUST_ACCT.ACCOUNT_NUMBER <= :p_customer_number_hi ';
      END IF;
      IF (P_AGREEMENT IS NOT NULL) THEN
        LP_AGREEMENT := 'and ag.agreement_id = :p_agreement ';
      END IF;
      IF (P_SALESREP_LO IS NOT NULL) AND (P_SALESREP_HI IS NOT NULL) THEN
        LP_SALESREP := 'and ( sr.name between :p_salesrep_lo and :p_salesrep_hi ) ';
      ELSIF (P_SALESREP_LO IS NOT NULL) THEN
        LP_SALESREP := 'and sr.name >= :p_salesrep_lo ';
      ELSIF (P_SALESREP_HI IS NOT NULL) THEN
        LP_SALESREP := 'and sr.name <= :p_salesrep_hi ';
      END IF;
      IF (P_ORDER_TYPE_LO IS NOT NULL) AND (P_ORDER_TYPE_HI IS NOT NULL) THEN
        LP_ORDER_TYPE := 'and ( ot.transaction_type_id between :p_order_type_lo and :p_order_type_hi ) ';
        SELECT
          OEOT.NAME
        INTO L_ORDER_TYPE_LOW
        FROM
          OE_TRANSACTION_TYPES_TL OEOT
        WHERE OEOT.TRANSACTION_TYPE_ID = P_ORDER_TYPE_LO
          AND OEOT.LANGUAGE = USERENV('LANG');
        SELECT
          OEOT.NAME
        INTO L_ORDER_TYPE_HIGH
        FROM
          OE_TRANSACTION_TYPES_TL OEOT
        WHERE OEOT.TRANSACTION_TYPE_ID = P_ORDER_TYPE_HI
          AND OEOT.LANGUAGE = USERENV('LANG');
      ELSIF (P_ORDER_TYPE_LO IS NOT NULL) THEN
        LP_ORDER_TYPE := 'and ot.transaction_type_id >= :p_order_type_lo ';
        SELECT
          OEOT.NAME
        INTO L_ORDER_TYPE_LOW
        FROM
          OE_TRANSACTION_TYPES_TL OEOT
        WHERE OEOT.TRANSACTION_TYPE_ID = P_ORDER_TYPE_LO
          AND OEOT.LANGUAGE = USERENV('LANG');
      ELSIF (P_ORDER_TYPE_HI IS NOT NULL) THEN
        LP_ORDER_TYPE := 'and ot.transaction_type_id <= :p_order_type_hi ';
        SELECT
          OEOT.NAME
        INTO L_ORDER_TYPE_HIGH
        FROM
          OE_TRANSACTION_TYPES_TL OEOT
        WHERE OEOT.TRANSACTION_TYPE_ID = P_ORDER_TYPE_HI
          AND OEOT.LANGUAGE = USERENV('LANG');
      END IF;
      IF (P_ORDER_NUM_LOW IS NOT NULL) AND (P_ORDER_NUM_HIGH IS NOT NULL) THEN
        LP_ORDER_NUM := 'and ( h.order_number between to_number(:p_order_num_low) and to_number(:p_order_num_high) ) ';
      ELSIF (P_ORDER_NUM_LOW IS NOT NULL) THEN
        LP_ORDER_NUM := 'and h.order_number >= to_number(:p_order_num_low) ';
      ELSIF (P_ORDER_NUM_HIGH IS NOT NULL) THEN
        LP_ORDER_NUM := 'and h.order_number <= to_number(:p_order_num_high) ';
      END IF;
      IF (P_ORDER_DATE_LOW IS NOT NULL) AND (P_ORDER_DATE_HIGH IS NOT NULL) THEN
        LP_ORDER_DATE := 'and  (h.ordered_date between :p_order_date_low
                         			      and :p_order_date_high) ';
      ELSIF (P_ORDER_DATE_LOW IS NOT NULL) THEN
        LP_ORDER_DATE := 'and h.ordered_date  >= :p_order_date_low ';
      ELSIF (P_ORDER_DATE_HIGH IS NOT NULL) THEN
        LP_ORDER_DATE := 'and h.ordered_date  <= :p_order_date_high ';
      END IF;
      IF ((P_ORDER_AMOUNT_LOW IS NULL) AND (P_ORDER_AMOUNT_HIGH IS NULL) AND (P_ORDER_LIST_LOW IS NULL) AND (P_ORDER_LIST_HIGH IS NULL)) THEN
        NULL;
      ELSE
        IF (P_ORDER_AMOUNT_LOW IS NOT NULL) AND (P_ORDER_AMOUNT_HIGH IS NOT NULL) THEN
          LP_ORDER_AMOUNT := ' sum(nvl(l.ordered_quantity,0)*
                             			     nvl(l.unit_selling_price,0)) between :p_order_amount_low and :p_order_amount_high';
        ELSIF (P_ORDER_AMOUNT_LOW IS NOT NULL) THEN
          LP_ORDER_AMOUNT := ' sum(nvl(l.ordered_quantity,0)*
                             			     nvl(l.unit_selling_price,0)) >= :p_order_amount_low ';
        ELSIF (P_ORDER_AMOUNT_HIGH IS NOT NULL) THEN
          LP_ORDER_AMOUNT := ' sum(nvl(l.ordered_quantity,0)*
                             			     nvl(l.unit_selling_price,0)) <= :p_order_amount_high ';
        END IF;
        IF (P_ORDER_LIST_LOW IS NOT NULL) AND (P_ORDER_LIST_HIGH IS NOT NULL) THEN
          LP_ORDER_LIST := ' sum(nvl(l.ordered_quantity,0)*
                           			     nvl(l.unit_list_price,0)) between :p_order_list_low and :p_order_list_high';
        ELSIF (P_ORDER_LIST_LOW IS NOT NULL) THEN
          LP_ORDER_LIST := ' sum(nvl(l.ordered_quantity,0)*
                           			     nvl(l.unit_list_price,0)) >= :p_order_list_low ';
        ELSIF (P_ORDER_LIST_HIGH IS NOT NULL) THEN
          LP_ORDER_LIST := ' sum(nvl(l.ordered_quantity,0)*
                           			     nvl(l.unit_list_price,0)) <= :p_order_list_high ';
        END IF;
        IF (LP_ORDER_AMOUNT IS NOT NULL) AND (LP_ORDER_LIST IS NOT NULL) THEN
          LP_HAVING := ' having ' || LP_ORDER_AMOUNT || '  and  ' || LP_ORDER_LIST;
        ELSIF (LP_ORDER_AMOUNT IS NOT NULL) AND (LP_ORDER_LIST IS NULL) THEN
          LP_HAVING := ' having ' || LP_ORDER_AMOUNT;
        ELSIF (LP_ORDER_AMOUNT IS NULL) AND (LP_ORDER_LIST IS NOT NULL) THEN
          LP_HAVING := ' having ' || LP_ORDER_LIST;
        END IF;
      END IF;
      IF P_OPEN_ORDERS_ONLY = 'Y' THEN
        LP_OPEN_ORDERS_ONLY := 'and nvl(h.open_flag,''N'') = ''Y'' ';
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
            LP_ORDER_CATEGORY := ' ';
          END IF;
        END IF;
      END IF;
      IF P_LINE_CATEGORY IS NOT NULL THEN
        IF P_LINE_CATEGORY = 'SALES' THEN
          LP_LINE_CATEGORY := 'and l.line_category_code = ''ORDER'' ';
        ELSIF P_LINE_CATEGORY = 'CREDIT' THEN
          LP_LINE_CATEGORY := 'and l.line_category_code = ''RETURN'' ';
        ELSIF P_LINE_CATEGORY = 'ALL' THEN
          LP_LINE_CATEGORY := ' ';
        END IF;
      ELSE
        LP_LINE_CATEGORY := ' ';
      END IF;
      IF (P_ORDER_BY IS NOT NULL) THEN
        IF (P_ORDER_BY = 'CUSTOMER') THEN
          LP_SORT_BY := ', PARTY.PARTY_NAME ';
        ELSIF (P_ORDER_BY = 'ORDER_NUMBER') THEN
          LP_SORT_BY := ', h.order_number ';
        END IF;
      ELSE
        LP_SORT_BY := ', h.order_number ';
      END IF;
    END;
    RETURN (TRUE);
  END AFTERPFORM;
  FUNCTION RP_ORDER_BYFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      L_SORT_BY VARCHAR2(100);
      L_LOOKUP_TYPE VARCHAR2(80);
      L_LOOKUP_CODE VARCHAR2(80);
    BEGIN
      L_LOOKUP_TYPE := 'OEXPRPRS ORDER BY';
      L_LOOKUP_CODE := P_ORDER_BY;
      SELECT
        MEANING
      INTO L_SORT_BY
      FROM
        OE_LOOKUPS
      WHERE LOOKUP_CODE = L_LOOKUP_CODE
        AND LOOKUP_TYPE = L_LOOKUP_TYPE;
      RETURN (L_SORT_BY);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN ('Order Number');
    END;
    RETURN NULL;
  END RP_ORDER_BYFORMULA;
  FUNCTION C_DISCOUNT_PRICEFORMULA(ORDER_AMOUNT IN NUMBER
                                  ,ORDER_LIST IN NUMBER) RETURN NUMBER IS
  BEGIN
    /*SRW.REFERENCE(ORDER_AMOUNT)*/NULL;
    /*SRW.REFERENCE(ORDER_LIST)*/NULL;
    RETURN (NVL(ORDER_LIST
              ,0) - NVL(ORDER_AMOUNT
              ,0));
  END C_DISCOUNT_PRICEFORMULA;
  FUNCTION C_DATA_NOT_FOUNDFORMULA(CURRENCY2 IN VARCHAR2) RETURN NUMBER IS
  BEGIN
    RP_DATA_FOUND := CURRENCY2;
    RETURN (0);
  END C_DATA_NOT_FOUNDFORMULA;
  FUNCTION C_ORDER_AMOUNTFORMULA(ORDER_AMOUNT IN NUMBER
                                ,C_PRE IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (ROUND(ORDER_AMOUNT
                ,C_PRE));
  END C_ORDER_AMOUNTFORMULA;
  FUNCTION C_ORDER_LISTFORMULA(ORDER_LIST IN NUMBER
                              ,C_PRE IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (ROUND(ORDER_LIST
                ,C_PRE));
  END C_ORDER_LISTFORMULA;
  FUNCTION C_DISCOUNT_PRICE_CUFORMULA(S_DISCOUNT_PRICE_CU IN NUMBER
                                     ,C_PRE IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (ROUND(S_DISCOUNT_PRICE_CU
                ,C_PRE));
  END C_DISCOUNT_PRICE_CUFORMULA;
  FUNCTION C_ORDER_LIST_CUFORMULA(S_ORDER_LIST_CU IN NUMBER
                                 ,C_PRE IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (ROUND(S_ORDER_LIST_CU
                ,C_PRE));
  END C_ORDER_LIST_CUFORMULA;
  FUNCTION C_ORDER_AMOUNT_CUFORMULA(S_ORDER_AMOUNT_CU IN NUMBER
                                   ,C_PRE IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (ROUND(S_ORDER_AMOUNT_CU
                ,C_PRE));
  END C_ORDER_AMOUNT_CUFORMULA;
  FUNCTION C_DISCOUNT_PRICE_OTFORMULA(S_DISCOUNT_PRICE_OT IN NUMBER
                                     ,C_PRE IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (ROUND(S_DISCOUNT_PRICE_OT
                ,C_PRE));
  END C_DISCOUNT_PRICE_OTFORMULA;
  FUNCTION C_ORDER_LIST_OTFORMULA(S_ORDER_LIST_OT IN NUMBER
                                 ,C_PRE IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (ROUND(S_ORDER_LIST_OT
                ,C_PRE));
  END C_ORDER_LIST_OTFORMULA;
  FUNCTION C_ORDER_AMOUNT_OTFORMULA(S_ORDER_AMOUNT_OT IN NUMBER
                                   ,C_PRE IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (ROUND(S_ORDER_AMOUNT_OT
                ,C_PRE));
  END C_ORDER_AMOUNT_OTFORMULA;
  FUNCTION C_DISCOUNT_PRCE_CFORMULA(S_DISCOUNT_PRICE_C IN NUMBER
                                   ,C_PRE IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (ROUND(S_DISCOUNT_PRICE_C
                ,C_PRE));
  END C_DISCOUNT_PRCE_CFORMULA;
  FUNCTION C_ORDER_LIST_CFORMULA(S_ORDER_LIST_C IN NUMBER
                                ,C_PRE IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (ROUND(S_ORDER_LIST_C
                ,C_PRE));
  END C_ORDER_LIST_CFORMULA;
  FUNCTION C_ORDER_AMOUNT_CFORMULA(S_ORDER_AMOUNT_C IN NUMBER
                                  ,C_PRE IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (ROUND(S_ORDER_AMOUNT_C
                ,C_PRE));
  END C_ORDER_AMOUNT_CFORMULA;
  FUNCTION CF_1FORMULA(CHARGE_PERIODICITY_CODE IN VARCHAR2) RETURN VARCHAR2 IS
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
  FUNCTION CF_2FORMULA(S_ORDER_AMOUNT_P IN NUMBER
                      ,C_PRE IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (ROUND(S_ORDER_AMOUNT_P
                ,C_PRE));
  END CF_2FORMULA;
  FUNCTION C_DISCOUNT_PRICE_PFORMULA(S_DISCOUNT_PRICE_P IN NUMBER
                                    ,C_PRE IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (ROUND(S_DISCOUNT_PRICE_P
                ,C_PRE));
  END C_DISCOUNT_PRICE_PFORMULA;
  FUNCTION C_ORDER_LIST_PFORMULA(S_ORDER_LIST_P IN NUMBER
                                ,C_PRE IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (ROUND(S_ORDER_LIST_P
                ,C_PRE));
  END C_ORDER_LIST_PFORMULA;
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
  FUNCTION RP_ORDER_LIST_RANGE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_ORDER_LIST_RANGE;
  END RP_ORDER_LIST_RANGE_P;
  FUNCTION RP_ORDER_DATE_RANGE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_ORDER_DATE_RANGE;
  END RP_ORDER_DATE_RANGE_P;
  FUNCTION RP_OPEN_ORDERS_ONLY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_OPEN_ORDERS_ONLY;
  END RP_OPEN_ORDERS_ONLY_P;
  FUNCTION RP_ORDER_AMOUNT_RANGE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_ORDER_AMOUNT_RANGE;
  END RP_ORDER_AMOUNT_RANGE_P;
  FUNCTION RP_AGREEMENT_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_AGREEMENT_NAME;
  END RP_AGREEMENT_NAME_P;
  FUNCTION RP_ORDER_TYPE_RANGE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_ORDER_TYPE_RANGE;
  END RP_ORDER_TYPE_RANGE_P;
  FUNCTION RP_CUSTOMER_NUMBER_RANGE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_CUSTOMER_NUMBER_RANGE;
  END RP_CUSTOMER_NUMBER_RANGE_P;
  FUNCTION RP_CUSTOMER_NAME_RANGE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_CUSTOMER_NAME_RANGE;
  END RP_CUSTOMER_NAME_RANGE_P;
  FUNCTION RP_SALESREP_RANGE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_SALESREP_RANGE;
  END RP_SALESREP_RANGE_P;
  FUNCTION RP_ORDER_CATEGORY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_ORDER_CATEGORY;
  END RP_ORDER_CATEGORY_P;
  FUNCTION RP_LINE_CATEGORY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_LINE_CATEGORY;
  END RP_LINE_CATEGORY_P;
END ONT_OEXPRPRS_XMLP_PKG;


/
