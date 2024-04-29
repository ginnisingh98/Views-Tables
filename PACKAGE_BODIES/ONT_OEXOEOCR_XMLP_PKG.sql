--------------------------------------------------------
--  DDL for Package Body ONT_OEXOEOCR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_OEXOEOCR_XMLP_PKG" AS
/* $Header: OEXOEOCRB.pls 120.3 2008/05/05 09:06:18 dwkrishn noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      BEGIN
        P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
        /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
      EXCEPTION
        WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
          BEGIN
            /*SRW.MESSAGE(1000
                       ,'Failed in BEFORE REPORT trigger')*/NULL;
            /*RAISE SRW.PROGRAM_ABORT*/RAISE_APPLICATION_ERROR(-20101,null);
          END;
      END;
      BEGIN
        P_ORGANIZATION_ID := MO_GLOBAL.GET_CURRENT_ORG_ID;
      END;
      BEGIN
        IF P_ITEM IS NOT NULL THEN
          SELECT
            CONCATENATED_SEGMENTS
          INTO P_ITEM_NAME
          FROM
            MTL_SYSTEM_ITEMS_KFV
          WHERE INVENTORY_ITEM_ID = P_ITEM
            AND CUSTOMER_ORDER_ENABLED_FLAG = 'Y'
            AND BOM_ITEM_TYPE in ( 1 , 4 )
            AND ORGANIZATION_ID = OE_SYS_PARAMETERS.VALUE('MASTER_ORGANIZATION_ID');
        END IF;
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
        /*SRW.REFERENCE(P_ITEM_FLEX_CODE)*/NULL;
        /*SRW.REFERENCE(P_ITEM_STRUCTURE_NUM)*/NULL;
        IF P_ITEM IS NOT NULL THEN
          LP_ITEM_FLEX_ALL_SEG := ' and ' || RP_ITEM_FLEX_ALL_SEG_WHERE;
        ELSE
	  LP_ITEM_FLEX_ALL_SEG := ' ';
        END IF;
      EXCEPTION
        WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
          /*SRW.MESSAGE(1
                     ,'Failed in before report trigger:MSTK')*/NULL;
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
        RP_REPORT_NAME := SUBSTR(L_REPORT_NAME,1,INSTR(L_REPORT_NAME,' (XML)'));
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RP_REPORT_NAME := 'Cancelled Orders Reason Detail Report';
      END;
    END;
    LP_ORDER_BY := UPPER(P_ORDER_BY);
    LP_ORDER_DATE_LOW := TO_CHAR(P_ORDER_DATE_LOW,'DD-MON-YY');
    LP_ORDER_DATE_HIGH := TO_CHAR(P_ORDER_DATE_HIGH,'DD-MON-YY');
    LP_CANCEL_DATE_LOW := TO_CHAR(P_CANCEL_DATE_LOW,'DD-MON-YY');
    LP_CANCEL_DATE_HIGH := TO_CHAR(P_CANCEL_DATE_HIGH,'DD-MON-YY');
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

  FUNCTION P_ITEM_FLEX_CODEVALIDTRIGGER RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END P_ITEM_FLEX_CODEVALIDTRIGGER;

  FUNCTION P_USE_FUNCTIONAL_CURRENCYVALID RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END P_USE_FUNCTIONAL_CURRENCYVALID;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    BEGIN
      IF P_ORDER_NUM_LOW IS NOT NULL AND P_ORDER_NUM_HIGH IS NOT NULL THEN
        LP_ORDER_NUM := ' AND  h.order_number  between to_number(:p_order_num_low) and to_number(:p_order_num_high)  ';
      ELSIF (P_ORDER_NUM_LOW IS NOT NULL) THEN
        LP_ORDER_NUM := 'and h.order_number >= to_number(:p_order_num_low) ';
      ELSIF (P_ORDER_NUM_HIGH IS NOT NULL) THEN
        LP_ORDER_NUM := 'and h.order_number <= to_number(:p_order_num_high) ';
      ELSE
        LP_ORDER_NUM := ' ';
      END IF;
      IF P_SALESREP_LOW IS NOT NULL AND P_SALESREP_HIGH IS NOT NULL THEN
        LP_SALESREP := ' AND nvl(sr.name,''zzzzzz'') between :p_salesrep_low and :p_salesrep_high ';
      ELSIF (P_SALESREP_LOW IS NOT NULL) THEN
        LP_SALESREP := 'and sr.name >= :p_salesrep_low ';
      ELSIF (P_SALESREP_HIGH IS NOT NULL) THEN
        LP_SALESREP := 'and sr.name <= :p_salesrep_high ';
      ELSE
        LP_SALESREP := ' ';  --praveen
      END IF;
      IF P_CANCEL_DATE_LOW IS NOT NULL AND P_CANCEL_DATE_HIGH IS NOT NULL THEN
        LP_CANCEL_DATE := ' AND  trunc(lh.hist_creation_date, ''DD'')
                                                   between  trunc(:p_cancel_date_low, ''DD'')
                                                       and  trunc(:p_cancel_date_high, ''DD'') ';
      ELSIF (P_CANCEL_DATE_LOW IS NOT NULL) THEN
        LP_CANCEL_DATE := ' AND  trunc(lh.hist_creation_date, ''DD'')
                                                        >=  trunc(:p_cancel_date_low, ''DD'') ';
      ELSIF (P_CANCEL_DATE_HIGH IS NOT NULL) THEN
        LP_CANCEL_DATE := ' AND  trunc(lh.hist_creation_date, ''DD'')
                                                        <=  trunc(:p_cancel_date_high, ''DD'') ';
      ELSE
	LP_CANCEL_DATE := ' ';
      END IF;
      IF P_ORDER_DATE_LOW IS NOT NULL AND P_ORDER_DATE_HIGH IS NOT NULL THEN
        LP_ORDER_DATE := ' AND  trunc(h.ordered_date, ''DD'')
                                                  between  trunc(:p_order_date_low, ''DD'')
                                                      and  trunc(:p_order_date_high, ''DD'') ';
      ELSIF (P_ORDER_DATE_LOW IS NOT NULL) THEN
        LP_ORDER_DATE := ' AND  trunc(h.ordered_date, ''DD'')
                                                       >=  trunc(:p_order_date_low, ''DD'') ';
      ELSIF (P_ORDER_DATE_HIGH IS NOT NULL) THEN
        LP_ORDER_DATE := ' AND  trunc(h.ordered_date, ''DD'')
                                                       <=  trunc(:p_order_date_high, ''DD'') ';
      ELSE
        LP_ORDER_DATE := ' ';
      END IF;
      IF P_CUSTOMER_NAME_LOW IS NOT NULL AND P_CUSTOMER_NAME_HIGH IS NOT NULL THEN
        LP_CUSTOMER_NAME := ' AND  org.name between :p_customer_name_low and :p_customer_name_high ';
      ELSIF (P_CUSTOMER_NAME_LOW IS NOT NULL) THEN
        LP_CUSTOMER_NAME := 'and org.name >= :p_customer_name_low ';
      ELSIF (P_CUSTOMER_NAME_HIGH IS NOT NULL) THEN
        LP_CUSTOMER_NAME := 'and org.name <= :p_customer_name_high ';
      ELSE
	LP_CUSTOMER_NAME := ' '; --praveen
      END IF;
      IF P_CANCELLED_BY_LOW IS NOT NULL AND P_CANCELLED_BY_HIGH IS NOT NULL THEN
        LP_CANCELLED_BY := ' and fnd_user.user_name between :p_cancelled_by_low and
                                                      :p_cancelled_by_high ';
      ELSIF (P_CANCELLED_BY_LOW IS NOT NULL) THEN
        LP_CANCELLED_BY := 'and fnd_user.user_name >= :p_cancelled_by_low ';
      ELSIF (P_CANCELLED_BY_HIGH IS NOT NULL) THEN
        LP_CANCELLED_BY := ' and fnd_user.user_name <= :p_cancelled_by_high ';
      ELSE
        LP_CANCELLED_BY := ' ';
      END IF;
      IF P_CANCEL_REASON IS NOT NULL THEN
        LP_CANCEL_REASON := ' and r.reason_code = :p_cancel_reason ';
      ELSE
        LP_CANCEL_REASON := ' ';
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
            LP_ORDER_CATEGORY := ' '; --praveen
          END IF;
        ELSE
          LP_ORDER_CATEGORY := 'and h.order_category_code in (''ORDER'', ''MIXED'') ';
        END IF;
      END IF;
      IF P_LINE_CATEGORY IS NOT NULL THEN
        IF P_LINE_CATEGORY = 'SALES' THEN
          LP_LINE_CATEGORY := 'and lh.line_category_code = ''ORDER'' ';
        ELSIF P_LINE_CATEGORY = 'CREDIT' THEN
          LP_LINE_CATEGORY := 'and lh.line_category_code = ''RETURN'' ';
        ELSIF P_LINE_CATEGORY = 'ALL' THEN
          LP_LINE_CATEGORY := ' '; --praveen
        END IF;
      ELSE
        LP_LINE_CATEGORY := 'and lh.line_category_code = ''ORDER'' ';
      END IF;
    END;
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION C_SET_LBLFORMULA RETURN VARCHAR2 IS
  BEGIN
    BEGIN
      /*SRW.REFERENCE(P_ORDER_BY)*/NULL;
      IF UPPER(P_ORDER_BY) = 'SALESREP' THEN
        RP_SALES_REASON_LBL := 'Salesperson';
        RP_SALES_REASON_LBL_2 := 'Salesperson: ';
      ELSIF UPPER(P_ORDER_BY) = 'CANCEL_REASON' THEN
        RP_SALES_REASON_LBL := 'Cancel Reason';
        RP_SALES_REASON_LBL_2 := 'Cancel Reason: ';
      ELSIF UPPER(P_ORDER_BY) = 'ORDER_DATE' THEN
        RP_DATE_LBL := 'Order Date';
      ELSIF UPPER(P_ORDER_BY) = 'CANCEL_DATE' THEN
        RP_DATE_LBL := 'Cancel Date';
      END IF;
      IF P_CUSTOMER_NAME_LOW IS NOT NULL OR P_CUSTOMER_NAME_HIGH IS NOT NULL THEN
        RP_CUSTOMER_RANGE := 'From ' || NVL(SUBSTR(P_CUSTOMER_NAME_LOW
                                       ,1
                                       ,16)
                                ,'     ') || ' To ' || NVL(SUBSTR(P_CUSTOMER_NAME_HIGH
                                       ,1
                                       ,16)
                                ,'     ');
      END IF;
      IF P_SALESREP_LOW IS NOT NULL OR P_SALESREP_HIGH IS NOT NULL THEN
        RP_SALESPERSON_RANGE := 'From ' || NVL(SUBSTR(P_SALESREP_LOW
                                          ,1
                                          ,16)
                                   ,'     ') || ' To ' || NVL(SUBSTR(P_SALESREP_HIGH
                                          ,1
                                          ,16)
                                   ,'     ');
      END IF;
      IF P_CANCEL_DATE_LOW IS NOT NULL AND P_CANCEL_DATE_HIGH IS NOT NULL THEN
        RP_CANCEL_DATE_RANGE := 'From ' || LP_CANCEL_DATE_LOW || ' To ' || LP_CANCEL_DATE_HIGH;
      ELSIF P_CANCEL_DATE_LOW IS NOT NULL THEN
        RP_CANCEL_DATE_RANGE := 'From ' || LP_CANCEL_DATE_LOW || ' To ' || '       ';
      ELSIF P_CANCEL_DATE_HIGH IS NOT NULL THEN
        RP_CANCEL_DATE_RANGE := 'From ' || '       ' || ' To ' || LP_CANCEL_DATE_HIGH;
      END IF;
      IF P_ORDER_DATE_LOW IS NOT NULL AND P_ORDER_DATE_HIGH IS NOT NULL THEN
        RP_ORDER_DATE_RANGE := 'From ' || LP_ORDER_DATE_LOW || ' To ' || LP_ORDER_DATE_HIGH;
      ELSIF P_ORDER_DATE_LOW IS NOT NULL THEN
        RP_ORDER_DATE_RANGE := 'From ' || LP_ORDER_DATE_LOW || ' To ' || '       ';
      ELSIF P_ORDER_DATE_HIGH IS NOT NULL THEN
        RP_ORDER_DATE_RANGE := 'From ' || '       ' || ' To ' || LP_ORDER_DATE_HIGH;
      END IF;
      IF P_ORDER_NUM_LOW IS NOT NULL OR P_ORDER_NUM_HIGH IS NOT NULL THEN
        RP_ORDER_RANGE := 'From ' || NVL(P_ORDER_NUM_LOW
                             ,'     ') || ' To ' || NVL(P_ORDER_NUM_HIGH
                             ,'     ');
      END IF;
      IF P_CANCELLED_BY_LOW IS NOT NULL OR P_CANCELLED_BY_HIGH IS NOT NULL THEN
        RP_CANCELLED_BY_RANGE := 'From ' || NVL(SUBSTR(P_CANCELLED_BY_LOW
                                           ,1
                                           ,16)
                                    ,'     ') || ' To ' || NVL(SUBSTR(P_CANCELLED_BY_HIGH
                                           ,1
                                           ,16)
                                    ,'     ');
      END IF;
      IF P_ORDER_BY IS NOT NULL THEN
        DECLARE
          ORDER_BY VARCHAR2(80);
          L_LOOKUP_TYPE VARCHAR2(80);
          L_LOOKUP_CODE VARCHAR2(80);
        BEGIN
          L_LOOKUP_TYPE := 'OEXOEOCR SORT BY';
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
      IF P_CANCEL_REASON IS NOT NULL THEN
        DECLARE
          MEANING VARCHAR2(80);
          L_LOOKUP_TYPE VARCHAR2(80);
          L_LOOKUP_CODE VARCHAR2(80);
        BEGIN
          L_LOOKUP_TYPE := 'CANCEL_CODE';
          L_LOOKUP_CODE := P_CANCEL_REASON;
          SELECT
            MEANING
          INTO MEANING
          FROM
            OE_LOOKUPS
          WHERE LOOKUP_TYPE = L_LOOKUP_TYPE
            AND LOOKUP_CODE = L_LOOKUP_CODE;
          RP_CANCEL_REASON := MEANING;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            RP_CANCEL_REASON := P_CANCEL_REASON;
        END;
      END IF;
      DECLARE
        MEANING VARCHAR2(80);
        L_LOOKUP_TYPE VARCHAR2(80);
        L_LOOKUP_CODE VARCHAR2(80);
      BEGIN
        L_LOOKUP_TYPE := 'YES_NO';
        L_LOOKUP_CODE := P_USE_FUNCTIONAL_CURRENCY;
        SELECT
          MEANING
        INTO MEANING
        FROM
          FND_LOOKUPS
        WHERE LOOKUP_TYPE = L_LOOKUP_TYPE
          AND LOOKUP_CODE = L_LOOKUP_CODE;
        RP_USE_FUNCTIONAL_CURRENCY := MEANING;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RP_USE_FUNCTIONAL_CURRENCY := P_USE_FUNCTIONAL_CURRENCY;
      END;
      DECLARE
        ITEM_DISPLAY_MEANING VARCHAR2(80);
        L_LOOKUP_TYPE VARCHAR2(80);
        L_LOOKUP_CODE VARCHAR2(80);
      BEGIN
        L_LOOKUP_TYPE := 'ITEM_DISPLAY_CODE';
        L_LOOKUP_CODE := P_PRINT_DESCRIPTION;
        SELECT
          MEANING
        INTO ITEM_DISPLAY_MEANING
        FROM
          OE_LOOKUPS
        WHERE LOOKUP_TYPE = L_LOOKUP_TYPE
          AND LOOKUP_CODE = L_LOOKUP_CODE;
        RP_FLEX_OR_DESC := ITEM_DISPLAY_MEANING;
      END;
      RETURN (1);
    END;
    RETURN NULL;
  END C_SET_LBLFORMULA;

  FUNCTION C_GL_CONV_RATEFORMULA(CURRENCY_CODE IN VARCHAR2
                                ,ORD_DATE IN DATE
                                ,CONVERSION_TYPE_CODE IN VARCHAR2
                                ,CONVERSION_RATE IN NUMBER) RETURN NUMBER IS
  BEGIN
    DECLARE
      GL_RATE NUMBER;
    BEGIN
      /*SRW.REFERENCE(CURRENCY_CODE)*/NULL;
      /*SRW.REFERENCE(ORD_DATE)*/NULL;
      /*SRW.REFERENCE(CONVERSION_TYPE_CODE)*/NULL;
      IF P_USE_FUNCTIONAL_CURRENCY = 'Y' THEN
        IF CURRENCY_CODE = RP_FUNCTIONAL_CURRENCY THEN
          RETURN (1);
        ELSE
          IF CONVERSION_RATE IS NULL THEN
            GL_RATE := GET_RATE(P_SOB_ID
                               ,CURRENCY_CODE
                               ,ORD_DATE
                               ,CONVERSION_TYPE_CODE);
            RETURN (GL_RATE);
          ELSE
            RETURN (CONVERSION_RATE);
          END IF;
        END IF;
      ELSE
        RETURN (1);
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN (-1);
      WHEN OTHERS THEN
        RETURN (-1);
    END;
    RETURN NULL;
  END C_GL_CONV_RATEFORMULA;

  FUNCTION C_AMOUNTFORMULA(CALC_AMOUNT IN NUMBER
                          ,C_GL_CONV_RATE IN NUMBER
                          ,C_PRECISION IN NUMBER) RETURN NUMBER IS
  BEGIN
    DECLARE
      ORDER_AMOUNT NUMBER(14,2);

    BEGIN
      /*SRW.REFERENCE(CALC_AMOUNT)*/NULL;
      /*SRW.REFERENCE(C_GL_CONV_RATE)*/NULL;
      /*SRW.REFERENCE(C_PRECISION)*/NULL;
      IF P_USE_FUNCTIONAL_CURRENCY = 'Y' THEN
        IF C_GL_CONV_RATE <> -1 THEN
          SELECT
            C_GL_CONV_RATE * CALC_AMOUNT
          INTO ORDER_AMOUNT
          FROM
            DUAL;
          RETURN (ROUND(ORDER_AMOUNT
                      ,C_PRECISION));
        ELSE
          RETURN (0);
        END IF;
      ELSE
        RETURN (ROUND(CALC_AMOUNT
                    ,C_PRECISION));
      END IF;
    END;
    RETURN NULL;
  END C_AMOUNTFORMULA;

  FUNCTION C_CURRENCY_CODEFORMULA(CURRENCY_CODE IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    /*SRW.REFERENCE(CURRENCY_CODE)*/NULL;
    IF P_USE_FUNCTIONAL_CURRENCY = 'Y' THEN
      RETURN (RP_FUNCTIONAL_CURRENCY);
    ELSE
      RETURN (CURRENCY_CODE);
    END IF;
    RETURN NULL;
  END C_CURRENCY_CODEFORMULA;

  FUNCTION PR_ORDER_CATEGORYFORMULA RETURN CHAR IS
  BEGIN
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
      RETURN (L_MEANING);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN (NULL);
    END;
  END PR_ORDER_CATEGORYFORMULA;

  FUNCTION RP_LINE_CATEGORYFORMULA RETURN VARCHAR2 IS
  BEGIN
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
      RETURN (L_MEANING);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN (NULL);
    END;
  END RP_LINE_CATEGORYFORMULA;

  FUNCTION CF_UNIT1FORMULA(UNIT1 IN VARCHAR2) RETURN CHAR IS
  BEGIN
    CP_UNIT1 := UNIT1;
    RETURN 1;
  END CF_UNIT1FORMULA;

  FUNCTION CF_UNIT2FORMULA(UNIT2 IN VARCHAR2) RETURN CHAR IS
  BEGIN
    CP_UNIT2 := UNIT2;
    RETURN 1;
  END CF_UNIT2FORMULA;

  FUNCTION C_CANCELLED_QTYFORMULA(LINEID IN NUMBER
                                 ,CANCELLED_QTY IN NUMBER) RETURN NUMBER IS
  BEGIN
    DECLARE
      HIST_LINES NUMBER;
      CAN_QTY_1 NUMBER;
      ORD_QTY_MAX NUMBER;
      CAN_QTY_MAX NUMBER;
      CAN_QTY_FINAL1 NUMBER;
      CAN_QTY_FINAL2 NUMBER;
    BEGIN
      SELECT
        COUNT(1)
      INTO HIST_LINES
      FROM
        OE_ORDER_LINES_HISTORY
      WHERE LINE_ID = LINEID
        AND HIST_TYPE_CODE = 'CANCELLATION';
      IF HIST_LINES = 1 THEN
        SELECT
          CANCELLED_QUANTITY
        INTO CAN_QTY_1
        FROM
          OE_ORDER_LINES_ALL
        WHERE LINE_ID = LINEID;
        RETURN (CAN_QTY_1);
      ELSE
        SELECT
          MAX(ORDERED_QUANTITY),
          MAX(CANCELLED_QUANTITY)
        INTO ORD_QTY_MAX,CAN_QTY_MAX
        FROM
          OE_ORDER_LINES_HISTORY
        WHERE LINE_ID = LINEID
          AND HIST_TYPE_CODE = 'CANCELLATION';
        IF CANCELLED_QTY = CAN_QTY_MAX THEN
          SELECT
            ( CANCELLED_QUANTITY - CAN_QTY_MAX )
          INTO CAN_QTY_FINAL1
          FROM
            OE_ORDER_LINES_ALL
          WHERE LINE_ID = LINEID;
          RETURN (CAN_QTY_FINAL1);
        ELSE
          SELECT
            MIN(CANCELLED_QUANTITY)
          INTO CAN_QTY_FINAL2
          FROM
            OE_ORDER_LINES_HISTORY
          WHERE LINE_ID = LINEID
            AND CANCELLED_QUANTITY > CANCELLED_QTY
            AND HIST_TYPE_CODE = 'CANCELLATION';
          RETURN (CAN_QTY_FINAL2 - CANCELLED_QTY);
        END IF;
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN (NULL);
    END;
  END C_CANCELLED_QTYFORMULA;

  FUNCTION CALC_AMOUNTFORMULA(LINEID IN NUMBER
                             ,CANCELLED_QTY IN NUMBER) RETURN NUMBER IS
  BEGIN
    DECLARE
      HIST_LINES NUMBER;
      CAN_QTY_1 NUMBER;
      ORD_QTY_MAX NUMBER;
      CAN_QTY_MAX NUMBER;
      CAN_QTY_FINAL1 NUMBER;
      CAN_QTY_FINAL2 NUMBER;
      UNIT_SELLING_PRICE_VAR NUMBER;
    BEGIN
      SELECT
        COUNT(1)
      INTO HIST_LINES
      FROM
        OE_ORDER_LINES_HISTORY
      WHERE LINE_ID = LINEID
        AND HIST_TYPE_CODE = 'CANCELLATION';
      IF HIST_LINES = 1 THEN
        SELECT
          CANCELLED_QUANTITY,
          UNIT_SELLING_PRICE
        INTO CAN_QTY_1,UNIT_SELLING_PRICE_VAR
        FROM
          OE_ORDER_LINES_ALL
        WHERE LINE_ID = LINEID;
        RETURN (CAN_QTY_1 * UNIT_SELLING_PRICE_VAR);
      ELSE
        SELECT
          MAX(ORDERED_QUANTITY),
          MAX(CANCELLED_QUANTITY)
        INTO ORD_QTY_MAX,CAN_QTY_MAX
        FROM
          OE_ORDER_LINES_HISTORY
        WHERE LINE_ID = LINEID
          AND HIST_TYPE_CODE = 'CANCELLATION';
        IF CANCELLED_QTY = CAN_QTY_MAX THEN
          SELECT
            ( CANCELLED_QUANTITY - CAN_QTY_MAX ),
            UNIT_SELLING_PRICE
          INTO CAN_QTY_FINAL1,UNIT_SELLING_PRICE_VAR
          FROM
            OE_ORDER_LINES_ALL
          WHERE LINE_ID = LINEID;
          RETURN (CAN_QTY_FINAL1 * UNIT_SELLING_PRICE_VAR);
        ELSE
          SELECT
            MIN(CANCELLED_QUANTITY)
          INTO CAN_QTY_FINAL2
          FROM
            OE_ORDER_LINES_HISTORY
          WHERE LINE_ID = LINEID
            AND CANCELLED_QUANTITY > CANCELLED_QTY
            AND HIST_TYPE_CODE = 'CANCELLATION';
          SELECT
            DISTINCT
            UNIT_SELLING_PRICE
          INTO UNIT_SELLING_PRICE_VAR
          FROM
            OE_ORDER_LINES_HISTORY
          WHERE LINE_ID = LINEID
            AND CANCELLED_QUANTITY = CAN_QTY_FINAL2
            AND HIST_TYPE_CODE = 'CANCELLATION';
          RETURN ((CAN_QTY_FINAL2 - CANCELLED_QTY) * UNIT_SELLING_PRICE_VAR);
        END IF;
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN (NULL);
    END;
  END CALC_AMOUNTFORMULA;

  FUNCTION C_PRECISIONFORMULA(CURRENCY_CODE IN VARCHAR2) RETURN NUMBER IS
  BEGIN
    DECLARE
      W_PRECISION NUMBER;
    BEGIN
      SELECT
        PRECISION
      INTO W_PRECISION
      FROM
        FND_CURRENCIES CUR
      WHERE CUR.CURRENCY_CODE = C_PRECISIONFORMULA.CURRENCY_CODE;
      RETURN (W_PRECISION);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        W_PRECISION := 2;
        RETURN (W_PRECISION);
    END;
    RETURN NULL;
  END C_PRECISIONFORMULA;

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

  FUNCTION RP_ITEM_FLEX_LPROMPT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_ITEM_FLEX_LPROMPT;
  END RP_ITEM_FLEX_LPROMPT_P;

  FUNCTION RP_ITEM_FLEX_ALL_SEG_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_ITEM_FLEX_ALL_SEG;
  END RP_ITEM_FLEX_ALL_SEG_P;

  FUNCTION RP_ITEM_FLEX_APROMPT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_ITEM_FLEX_APROMPT;
  END RP_ITEM_FLEX_APROMPT_P;

  FUNCTION RP_SALES_REASON_LBL_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_SALES_REASON_LBL;
  END RP_SALES_REASON_LBL_P;

  FUNCTION RP_CUSTOMER_RANGE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_CUSTOMER_RANGE;
  END RP_CUSTOMER_RANGE_P;

  FUNCTION RP_SALESPERSON_RANGE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_SALESPERSON_RANGE;
  END RP_SALESPERSON_RANGE_P;

  FUNCTION RP_ORDER_RANGE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_ORDER_RANGE;
  END RP_ORDER_RANGE_P;

  FUNCTION RP_CANCEL_DATE_RANGE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_CANCEL_DATE_RANGE;
  END RP_CANCEL_DATE_RANGE_P;

  FUNCTION RP_SALES_REASON_LBL_2_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_SALES_REASON_LBL_2;
  END RP_SALES_REASON_LBL_2_P;

  FUNCTION RP_ORDER_BY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_ORDER_BY;
  END RP_ORDER_BY_P;

  FUNCTION RP_CANCEL_REASON_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_CANCEL_REASON;
  END RP_CANCEL_REASON_P;

  FUNCTION RP_USE_FUNCTIONAL_CURRENCY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_USE_FUNCTIONAL_CURRENCY;
  END RP_USE_FUNCTIONAL_CURRENCY_P;

  FUNCTION RP_FLEX_OR_DESC_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_FLEX_OR_DESC;
  END RP_FLEX_OR_DESC_P;

  FUNCTION RP_ITEM_FLEX_ALL_SEG_WHERE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_ITEM_FLEX_ALL_SEG_WHERE;
  END RP_ITEM_FLEX_ALL_SEG_WHERE_P;

  FUNCTION RP_ORDER_DATE_RANGE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_ORDER_DATE_RANGE;
  END RP_ORDER_DATE_RANGE_P;

  FUNCTION RP_CANCELLED_BY_RANGE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_CANCELLED_BY_RANGE;
  END RP_CANCELLED_BY_RANGE_P;

  FUNCTION RP_DATE_LBL_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_DATE_LBL;
  END RP_DATE_LBL_P;

  FUNCTION CP_UNIT1_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_UNIT1;
  END CP_UNIT1_P;

  FUNCTION CP_UNIT2_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_UNIT2;
  END CP_UNIT2_P;

  FUNCTION RP_DUMMY_ITEM_P RETURN NUMBER IS
  BEGIN
    RETURN RP_DUMMY_ITEM;
  END RP_DUMMY_ITEM_P;

  FUNCTION IS_FIXED_RATE(X_FROM_CURRENCY IN VARCHAR2
                        ,X_TO_CURRENCY IN VARCHAR2
                        ,X_EFFECTIVE_DATE IN DATE) RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
 /*   STPROC.INIT('begin :X0 := GL_CURRENCY_API.IS_FIXED_RATE(:X_FROM_CURRENCY, :X_TO_CURRENCY, :X_EFFECTIVE_DATE); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(X_FROM_CURRENCY);
    STPROC.BIND_I(X_TO_CURRENCY);
    STPROC.BIND_I(X_EFFECTIVE_DATE);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);
    RETURN X0;*/
    NULL;
    RETURN(NULL);

  END IS_FIXED_RATE;

  PROCEDURE GET_RELATION(X_FROM_CURRENCY IN VARCHAR2
                        ,X_TO_CURRENCY IN VARCHAR2
                        ,X_EFFECTIVE_DATE IN DATE
                        ,X_FIXED_RATE IN OUT NOCOPY BOOLEAN
                        ,X_RELATIONSHIP IN OUT NOCOPY VARCHAR2) IS
  BEGIN
   /* STPROC.INIT('declare X_FIXED_RATE BOOLEAN; begin X_FIXED_RATE := sys.diutil.int_to_bool(:X_FIXED_RATE); GL_CURRENCY_API.GET_RELATION(:X_FROM_CURRENCY, :X_TO_CURRENCY, :X_EFFECTIVE_DATE, X_FIXED_RATE, :X_RELATIONSHIP);
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
  NULL;
  END GET_RELATION;

  FUNCTION GET_EURO_CODE RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
 /*   STPROC.INIT('begin :X0 := GL_CURRENCY_API.GET_EURO_CODE; end;');
    STPROC.BIND_O(X0);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);
    RETURN X0;*/
    NULL;
      RETURN(NULL);
  END GET_EURO_CODE;

  FUNCTION GET_RATE(X_FROM_CURRENCY IN VARCHAR2
                   ,X_TO_CURRENCY IN VARCHAR2
                   ,X_CONVERSION_DATE IN DATE
                   ,X_CONVERSION_TYPE IN VARCHAR2) RETURN NUMBER IS
    X0 NUMBER;
  BEGIN
 /*   STPROC.INIT('begin :X0 := GL_CURRENCY_API.GET_RATE(:X_FROM_CURRENCY, :X_TO_CURRENCY, :X_CONVERSION_DATE, :X_CONVERSION_TYPE); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(X_FROM_CURRENCY);
    STPROC.BIND_I(X_TO_CURRENCY);
    STPROC.BIND_I(X_CONVERSION_DATE);
    STPROC.BIND_I(X_CONVERSION_TYPE);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);
    RETURN X0;*/
NULL;
      RETURN(NULL);
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
                   ,X0);
    RETURN X0;*/
    NULL;
      RETURN(NULL);
  END GET_RATE;

  FUNCTION CONVERT_AMOUNT(X_FROM_CURRENCY IN VARCHAR2
                         ,X_TO_CURRENCY IN VARCHAR2
                         ,X_CONVERSION_DATE IN DATE
                         ,X_CONVERSION_TYPE IN VARCHAR2
                         ,X_AMOUNT IN NUMBER) RETURN NUMBER IS
    X0 NUMBER;
  BEGIN
   /* STPROC.INIT('begin :X0 := GL_CURRENCY_API.CONVERT_AMOUNT(:X_FROM_CURRENCY, :X_TO_CURRENCY, :X_CONVERSION_DATE, :X_CONVERSION_TYPE, :X_AMOUNT); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(X_FROM_CURRENCY);
    STPROC.BIND_I(X_TO_CURRENCY);
    STPROC.BIND_I(X_CONVERSION_DATE);
    STPROC.BIND_I(X_CONVERSION_TYPE);
    STPROC.BIND_I(X_AMOUNT);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);
    RETURN X0;*/
    NULL;
      RETURN(NULL);
  END CONVERT_AMOUNT;

  FUNCTION CONVERT_AMOUNT(X_SET_OF_BOOKS_ID IN NUMBER
                         ,X_FROM_CURRENCY IN VARCHAR2
                         ,X_CONVERSION_DATE IN DATE
                         ,X_CONVERSION_TYPE IN VARCHAR2
                         ,X_AMOUNT IN NUMBER) RETURN NUMBER IS
    X0 NUMBER;
  BEGIN
 /*   STPROC.INIT('begin :X0 := GL_CURRENCY_API.CONVERT_AMOUNT(:X_SET_OF_BOOKS_ID, :X_FROM_CURRENCY, :X_CONVERSION_DATE, :X_CONVERSION_TYPE, :X_AMOUNT); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(X_SET_OF_BOOKS_ID);
    STPROC.BIND_I(X_FROM_CURRENCY);
    STPROC.BIND_I(X_CONVERSION_DATE);
    STPROC.BIND_I(X_CONVERSION_TYPE);
    STPROC.BIND_I(X_AMOUNT);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);
    RETURN X0;*/
    NULL;
      RETURN(NULL);
  END CONVERT_AMOUNT;

  FUNCTION GET_DERIVE_TYPE(SOB_ID IN NUMBER
                          ,PERIOD IN VARCHAR2
                          ,CURR_CODE IN VARCHAR2) RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
 /*   STPROC.INIT('begin :X0 := GL_CURRENCY_API.GET_DERIVE_TYPE(:SOB_ID, :PERIOD, :CURR_CODE); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(SOB_ID);
    STPROC.BIND_I(PERIOD);
    STPROC.BIND_I(CURR_CODE);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);
    RETURN X0;*/
    NULL;
      RETURN(NULL);
  END GET_DERIVE_TYPE;

FUNCTION C_AMOUNT_DSPFORMULA RETURN VARCHAR2 IS
      C_GL_CONV_RATE NUMBER;
      C_AMOUNT_DSP VARCHAR2(10);
BEGIN

--SRW.REFERENCE(:C_AMOUNT);
--SRW.REFERENCE(:CURRENCY_CODE);
--SRW.REFERENCE(:C_GL_CONV_RATE);
--SRW.REFERENCE(:RP_FUNCTIONAL_CURRENCY);

RP_DATA_FOUND := 'X';
IF C_GL_CONV_RATE <> -1 THEN
	IF P_USE_FUNCTIONAL_CURRENCY = 'Y' THEN
	/*	SRW.USER_EXIT('FND FORMAT_CURRENCY
		CODE=":RP_FUNCTIONAL_CURRENCY"
		DISPLAY_WIDTH="14"
		AMOUNT=":C_AMOUNT"
		DISPLAY=":C_AMOUNT_DSP"
                MINIMUM_PRECISION=":P_MIXED_PRECISION"');*/
		RETURN(C_AMOUNT_DSP);
	ELSE
	/*	SRW.USER_EXIT('FND FORMAT_CURRENCY
		CODE=":CURRENCY_CODE"
		DISPLAY_WIDTH="14"
		AMOUNT=":C_AMOUNT"
		DISPLAY=":C_AMOUNT_DSP"
                MINIMUM_PRECISION=":P_MIXED_PRECISION"');*/
		RETURN(C_AMOUNT_DSP);
	END IF;
ELSE
	RETURN('NO RATE');
END IF;

RETURN NULL;

END;


function item_dspFormula
(
ITEM_IDENTIFIER_TYPE_T in varchar2,
iid IN NUMBER,
SI_ORGANIZATION_ID IN NUMBER,
SI_INVENTORY_ITEM_ID IN NUMBER,
ordered_item_id IN NUMBER,
ORDERED_ITEM IN VARCHAR
)
return Char is
v_item varchar2(2000);
v_description varchar2(500);
begin
  if (ITEM_IDENTIFIER_TYPE_T is null or ITEM_IDENTIFIER_TYPE_T = 'INT')
       or (p_print_description in ('I','D','F')) then

    --v_item := :item_flex;

    select sitems.description description
    into   v_description
    from   mtl_system_items_vl sitems
    where
    nvl(sitems.organization_id,0) = nvl(oe_sys_parameters.value('MASTER_ORGANIZATION_ID',mo_global.get_current_org_id()),0)
    and    sitems.inventory_item_id = IID;

       /*  srw.reference (:item_flex);
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
    v_item := fnd_flex_xml_publisher_apis.process_kff_combination_1('Item_dsp', 'INV', p_item_flex_code, p_item_structure_num, SI_ORGANIZATION_ID, SI_INVENTORY_ITEM_ID, 'ALL', 'Y', 'VALUE');
  elsif (ITEM_IDENTIFIER_TYPE_T = 'CUST' and p_print_description in ('C','P','O')) then
    select citems.customer_item_number item,
    	   nvl(citems.customer_item_desc,sitems.description) description
    into   v_item,v_description
    from   mtl_customer_items citems,
           mtl_customer_item_xrefs cxref,
           mtl_system_items_vl sitems
    where  citems.customer_item_id = cxref.customer_item_id
    and    cxref.inventory_item_id = sitems.inventory_item_id
    and    citems.customer_item_id = ordered_item_id
    and    nvl(sitems.organization_id,0) = nvl(oe_sys_parameters.value('MASTER_ORGANIZATION_ID',mo_global.get_current_org_id()),0)
    and    sitems.inventory_item_id = IID;
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
    and    items.cross_reference = ORDERED_ITEM
    and    items.cross_reference_type = ITEM_IDENTIFIER_TYPE_T
    and    nvl(sitems.organization_id,0) = nvl(oe_sys_parameters.value('MASTER_ORGANIZATION_ID',mo_global.get_current_org_id()),0)
    and    sitems.inventory_item_id = IID
    and   items.org_independent_flag = 'N'
    and   items.organization_id = nvl(oe_sys_parameters.value('MASTER_ORGANIZATION_ID',mo_global.get_current_org_id()),0);
    Exception When NO_DATA_FOUND Then
    Select items.cross_reference item,
    nvl(items.description,sitems.description) description
    into v_item,v_description
    from mtl_cross_reference_types xtypes,
    mtl_cross_references items,
    mtl_system_items_vl sitems
    where xtypes.cross_reference_type = items.cross_reference_type
    and items.inventory_item_id = sitems.inventory_item_id
    and items.cross_reference = ORDERED_ITEM
    and items.cross_reference_type = ITEM_IDENTIFIER_TYPE_T
    and nvl(sitems.organization_id,0 ) = nvl(oe_sys_parameters.value('MASTER_ORGANIZATION_ID',mo_global.get_current_org_id()),0)
    and sitems.inventory_item_id = IID
    and items.org_independent_flag ='Y';
    End;
    --Bug 3433353 End

  end if;

  if (p_print_description in ('I','C')) then
    return(v_item||' - '||v_description);
  elsif (p_print_description in ('D','P')) then
    return(v_description);
  else
    return(v_item);
  end if;




RETURN NULL;
exception
when no_data_found then
return ('Item not found');
end;


END ONT_OEXOEOCR_XMLP_PKG;



/
