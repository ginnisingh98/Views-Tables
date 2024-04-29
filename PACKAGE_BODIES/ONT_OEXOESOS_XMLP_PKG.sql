--------------------------------------------------------
--  DDL for Package Body ONT_OEXOESOS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_OEXOESOS_XMLP_PKG" AS
/* $Header: OEXOESOSB.pls 120.3 2008/05/05 06:38:53 dwkrishn noship $ */

function Item_dspFormula(item_identifier_type_L varchar2,
			  inventory_item_id_L number,
			  ordered_item_id_L number,
			  ordered_item_L varchar2,
			  ORGANIZATION_ID_L number) return Char is
v_item varchar2(2000);
v_description varchar2(500);
begin
  if (item_identifier_type_L is null or item_identifier_type_L = 'INT')
       or (p_print_description in ('I','D','F')) then
    select sitems.concatenated_segments item,
    	   sitems.description description
    into   v_item,v_description
    from   mtl_system_items_vl sitems
--    where  sitems.customer_order_enabled_flag = 'Y'
--    and    sitems.bom_item_type in (1,4)
    where    nvl(sitems.organization_id,0) = nvl(oe_sys_parameters.value('MASTER_ORGANIZATION_ID',mo_global.get_current_org_id()),0)
    and    sitems.inventory_item_id = inventory_item_id_L;
     /*    srw.reference (:p_item_flex_code);
         srw.reference (:Item_dsp);
         srw.reference (:p_item_structure_num);
         srw.user_exit (' FND FLEXIDVAL
		    CODE=":p_item_flex_code"
		    NUM=":p_item_structure_num"
		    APPL_SHORT_NAME="INV"
		    DATA= ":item_flex"
		    VALUE=":Item_dsp"
		    DISPLAY="ALL"'
		);    */
    v_item :=fnd_flex_xml_publisher_apis.process_kff_combination_1('Item_dsp', 'INV', p_item_flex_code,p_item_structure_num,ORGANIZATION_ID_L,INVENTORY_ITEM_ID_L, 'ALL', 'Y', 'VALUE');
  elsif (item_identifier_type_L = 'CUST' and p_print_description in ('C','P','O')) then
    select citems.customer_item_number item,
    	   nvl(citems.customer_item_desc,sitems.description) description
    into   v_item,v_description
    from   mtl_customer_items citems,
           mtl_customer_item_xrefs cxref,
           mtl_system_items_vl sitems
    where  citems.customer_item_id = cxref.customer_item_id
    and    cxref.inventory_item_id = sitems.inventory_item_id
    and    citems.customer_item_id = ordered_item_id_L
    and    nvl(sitems.organization_id,0) = nvl(oe_sys_parameters.value('MASTER_ORGANIZATION_ID',mo_global.get_current_org_id()),0)
    and    sitems.inventory_item_id = inventory_item_id_L;
--    and    sitems.customer_order_enabled_flag = 'Y'
--    and    sitems.bom_item_type in (1,4)
  elsif (p_print_description in ('C','P','O')) then
    select items.cross_reference item,
    	   nvl(items.description,sitems.description) description
    into   v_item,v_description
    from   mtl_cross_reference_types xtypes,
           mtl_cross_references items,
           mtl_system_items_vl sitems
    where  xtypes.cross_reference_type = items.cross_reference_type
    and    items.inventory_item_id = sitems.inventory_item_id
    and    items.cross_reference = ordered_item_L
    and    items.cross_reference_type = item_identifier_type_L
    and    nvl(sitems.organization_id,0) = nvl(oe_sys_parameters.value('MASTER_ORGANIZATION_ID',mo_global.get_current_org_id()),0)
    and    sitems.inventory_item_id = inventory_item_id_L;
--    and    sitems.customer_order_enabled_flag = 'Y'
--    and    sitems.bom_item_type in (1,4)
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
end;


  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
BEGIN

DECLARE

BEGIN

   BEGIN
   -- SRW.USER_EXIT('FND SRWINIT');

  /* EXCEPTION
       WHEN SRW.USER_EXIT_FAILURE THEN
       SRW.MESSAGE(1000,'FAILED IN BEFORE REPORT TRIGGER');
       RAISE SRW.PROGRAM_ABORT;
       WHEN OTHERS THEN NULL;*/
       NULL;
   END;

BEGIN  /*MOAC*/

 P_ORGANIZATION_ID:= MO_GLOBAL.GET_CURRENT_ORG_ID();

END;

/*------------------------------------------------------------------------------
FOLLOWING PL/SQL BLOCK GETS THE COMPANY NAME, FUNCTIONAL CURRENCY AND PRECISION.
------------------------------------------------------------------------------*/
  DECLARE
  L_COMPANY_NAME            VARCHAR2 (100);
  L_FUNCTIONAL_CURRENCY     VARCHAR2  (15);

  BEGIN

    SELECT SOB.NAME                   ,
	   SOB.CURRENCY_CODE
    INTO
	   L_COMPANY_NAME ,
	   L_FUNCTIONAL_CURRENCY
    FROM    GL_SETS_OF_BOOKS SOB,
	    FND_CURRENCIES CUR
    WHERE  SOB.SET_OF_BOOKS_ID = P_SOB_ID
    AND    SOB.CURRENCY_CODE = CUR.CURRENCY_CODE
    ;

    RP_COMPANY_NAME            := L_COMPANY_NAME;
    RP_FUNCTIONAL_CURRENCY     := L_FUNCTIONAL_CURRENCY ;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN NULL ;
    WHEN OTHERS THEN NULL;
  END ;

/*------------------------------------------------------------------------------
FOLLOWING PL/SQL BLOCK GETS THE ITEM FLEXFIELD
------------------------------------------------------------------------------*/
BEGIN
    /*SRW.REFERENCE(:P_ITEM_FLEX_CODE);
    SRW.REFERENCE(:P_ITEM_STRUCTURE_NUM);
    SRW.USER_EXIT('FND FLEXSQL CODE=":P_ITEM_FLEX_CODE"
			   NUM=":P_ITEM_STRUCTURE_NUM"
			   APPL_SHORT_NAME="INV"
			   OUTPUT=":RP_ITEM_FLEX_ALL_SEG"
			   MODE="SELECT"
			   DISPLAY="ALL"
			   TABLEALIAS="SI"');*/
/*EXCEPTION
  WHEN SRW.USER_EXIT_FAILURE THEN
 SRW.MESSAGE(1,'FAILED IN BEFORE REPORT TRIGGER:MSTK');
  WHEN OTHERS THEN NULL;*/
  NULL;
END;


/*------------------------------------------------------------------------------
FOLLOWING PL/SQL BLOCK GETS THE REPORT NAME FOR THE PASSED CONCURRENT REQUEST ID.
------------------------------------------------------------------------------*/
  DECLARE
      L_REPORT_NAME  VARCHAR2(240);
  BEGIN
      SELECT CP.USER_CONCURRENT_PROGRAM_NAME
      INTO   L_REPORT_NAME
      FROM   FND_CONCURRENT_PROGRAMS_VL CP,
	     FND_CONCURRENT_REQUESTS CR
      WHERE  CR.REQUEST_ID     = P_CONC_REQUEST_ID
      AND    CP.APPLICATION_ID = CR.PROGRAM_APPLICATION_ID
      AND    CP.CONCURRENT_PROGRAM_ID = CR.CONCURRENT_PROGRAM_ID
      ;

      RP_REPORT_NAME := SUBSTR(L_REPORT_NAME,1,INSTR(L_REPORT_NAME,' (XML)'));
  EXCEPTION
      WHEN NO_DATA_FOUND
      THEN RP_REPORT_NAME := 'Salesperson Order Summary Report';
      WHEN OTHERS THEN NULL;
  END;

END;

/*-----------------------------------------------------------------------------------------
FOLLOWING PL/SQL BLOCK GETS THE AGREEMENT NAME FOR THE PASSED AGREEMENT ID.
------------------------------------------------------------------------------------------*/
  DECLARE
    L_AGREEMENT_NAME          VARCHAR2 (50);

  BEGIN

  IF ( P_AGREEMENT IS NOT NULL) THEN
    BEGIN
      SELECT NAME
      INTO L_AGREEMENT_NAME
      FROM OE_AGREEMENTS
      WHERE AGREEMENT_ID = P_AGREEMENT;
      RP_AGREEMENT_NAME := L_AGREEMENT_NAME ;
    EXCEPTION
      WHEN NO_DATA_FOUND
      THEN RP_AGREEMENT_NAME := NULL;
    END;
  END IF;

  END;
  LP_ORDER_DATE_LOW := to_char(P_ORDER_DATE_LOW,'DD-MON-YY');
  LP_ORDER_DATE_HIGH := to_char(P_ORDER_DATE_HIGH,'DD-MON-YY');
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

  FUNCTION P_ORGANIZATION_IDVALIDTRIGGER RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END P_ORGANIZATION_IDVALIDTRIGGER;

  FUNCTION P_ITEM_FLEX_CODEVALIDTRIGGER RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END P_ITEM_FLEX_CODEVALIDTRIGGER;

  FUNCTION P_SOB_IDVALIDTRIGGER RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END P_SOB_IDVALIDTRIGGER;

  FUNCTION P_USE_FUNCTIONAL_CURRENCYVALID RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END P_USE_FUNCTIONAL_CURRENCYVALID;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    BEGIN
      IF P_ORDER_NUM_LOW IS NOT NULL AND P_ORDER_NUM_HIGH IS NOT NULL THEN
        IF (P_ORDER_NUM_LOW = P_ORDER_NUM_HIGH) THEN
          LP_ORDER_NUM := ' and h.order_number = to_number(:p_order_num_low) ';
        ELSE
          LP_ORDER_NUM := ' AND  h.order_number  between to_number(:p_order_num_low) and to_number(:p_order_num_high)  ';
        END IF;
      ELSIF (P_ORDER_NUM_LOW IS NOT NULL) THEN
        LP_ORDER_NUM := 'and h.order_number >= to_number(:p_order_num_low) ';
      ELSIF (P_ORDER_NUM_HIGH IS NOT NULL) THEN
        LP_ORDER_NUM := 'and h.order_number <= to_number(:p_order_num_high) ';
      ELSE
        LP_ORDER_NUM := ' ';
      END IF;
      P_ORGANIZATION_ID := NVL(P_ORGANIZATION_ID
                              ,0);
      SELECT
        USERENV('LANG')
      INTO P_LANG
      FROM
        DUAL;
      IF P_SALESREP_LOW IS NOT NULL AND P_SALESREP_HIGH IS NOT NULL THEN
        IF (P_SALESREP_LOW = P_SALESREP_HIGH) THEN
          LP_SALESREP := ' and sr.name = :p_salesrep_low ';
        ELSE
          LP_SALESREP := ' AND nvl(sr.name,''zzzzzz'') between :p_salesrep_low and :p_salesrep_high ';
        END IF;
      ELSIF (P_SALESREP_LOW IS NOT NULL) THEN
        LP_SALESREP := 'and sr.name >= :p_salesrep_low ';
      ELSIF (P_SALESREP_HIGH IS NOT NULL) THEN
        LP_SALESREP := 'and sr.name <= :p_salesrep_high ';
      ELSE
        LP_SALESREP := ' ';
      END IF;
      IF P_ORDER_DATE_LOW IS NOT NULL AND P_ORDER_DATE_HIGH IS NOT NULL THEN
        LP_ORDER_DATE := ' AND  h.ordered_date  >= :p_order_date_low and  h.ordered_date < :p_order_date_high + 1';
      ELSIF (P_ORDER_DATE_LOW IS NOT NULL) THEN
        LP_ORDER_DATE := ' and h.ordered_date >= :p_order_date_low';
      ELSIF (P_ORDER_DATE_HIGH IS NOT NULL) THEN
        LP_ORDER_DATE := ' and h.ordered_date < :p_order_date_high + 1';
      ELSE
        LP_ORDER_DATE := ' ';
      END IF;
      IF P_CUSTOMER_NAME_LOW IS NOT NULL AND P_CUSTOMER_NAME_HIGH IS NOT NULL THEN
        IF (P_CUSTOMER_NAME_LOW = P_CUSTOMER_NAME_HIGH) THEN
          LP_CUSTOMER_NAME := 'and party.party_name = :p_customer_name_low ';
        ELSE
          LP_CUSTOMER_NAME := ' AND  party.party_name between :p_customer_name_low and :p_customer_name_high ';
        END IF;
      ELSIF (P_CUSTOMER_NAME_LOW IS NOT NULL) THEN
        LP_CUSTOMER_NAME := 'and party.party_name >= :p_customer_name_low ';
      ELSIF (P_CUSTOMER_NAME_HIGH IS NOT NULL) THEN
        LP_CUSTOMER_NAME := 'and party.party_name <= :p_customer_name_high ';
      ELSE
        LP_CUSTOMER_NAME := ' ';
      END IF;
      IF P_CUSTOMER_NUM_LOW IS NOT NULL AND P_CUSTOMER_NUM_HIGH IS NOT NULL THEN
        IF (P_CUSTOMER_NUM_LOW = P_CUSTOMER_NUM_HIGH) THEN
          LP_CUSTOMER_NUM := 'and cust_acct.account_number = :p_customer_num_low ';
        ELSE
          LP_CUSTOMER_NUM := 'and cust_acct.account_number between :p_customer_num_low and :p_customer_num_high ';
        END IF;
      ELSIF (P_CUSTOMER_NUM_LOW IS NOT NULL) THEN
        LP_CUSTOMER_NUM := ' and cust_acct.account_number >= :p_customer_num_low';
      ELSIF (P_CUSTOMER_NUM_HIGH IS NOT NULL) THEN
        LP_CUSTOMER_NUM := ' and cust_acct.account_number <= :p-customer_num_high';
      ELSE
        LP_CUSTOMER_NUM := ' ';
      END IF;
      IF P_ORDER_TYPE IS NOT NULL THEN
        LP_ORDER_TYPE := ' and ot.transaction_type_id = :p_order_type ';
        SELECT
          OEOT.NAME
        INTO L_ORDER_TYPE
        FROM
          OE_TRANSACTION_TYPES_TL OEOT
        WHERE OEOT.TRANSACTION_TYPE_ID = P_ORDER_TYPE
          AND OEOT.LANGUAGE = USERENV('LANG');
      ELSE
       LP_ORDER_TYPE := ' ';
      END IF;
      IF P_AGREEMENT IS NOT NULL THEN
        LP_AGREEMENT := ' and t.agreement_id = :p_agreement ';
      ELSE
        LP_AGREEMENT := ' ';
      END IF;
      IF P_OPEN_ORDERS_ONLY = 'Y' THEN
        LP_OPEN_ORDERS_ONLY := ' and h.open_flag = ''Y'' ';
      ELSE
        LP_OPEN_ORDERS_ONLY := ' ';
      END IF;
      IF P_LINE_TYPE IS NOT NULL THEN
        LP_LINE_TYPE := ' and lt.line_type_id = :p_line_type ';
        SELECT
          OEOT.NAME
        INTO L_LINE_TYPE
        FROM
          OE_TRANSACTION_TYPES_TL OEOT
        WHERE OEOT.TRANSACTION_TYPE_ID = P_LINE_TYPE
          AND OEOT.LANGUAGE = USERENV('LANG');
      ELSE
        LP_LINE_TYPE := ' ';
      END IF;
      IF P_ORDER_NUM_LOW = P_ORDER_NUM_HIGH THEN
        LP_ORDER_CATEGORY := ' ';
      ELSE
        IF P_ORDER_CATEGORY IS NOT NULL THEN
          IF P_ORDER_CATEGORY = 'f' THEN
            LP_ORDER_CATEGORY := 'and h.order_category_code in (''ORDER'', ''MIXED'') ';
          ELSIF P_ORDER_CATEGORY = 'CREDIT' THEN
            LP_ORDER_CATEGORY := 'and h.order_category_code in (''RETURN'', ''MIXED'') ';
          ELSIF P_ORDER_CATEGORY = 'ALL' THEN
            LP_ORDER_CATEGORY := ' ';
          ELSE
	    LP_ORDER_CATEGORY := ' ';
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
          LP_LINE_CATEGORY := ' ';
        END IF;
      ELSE
        LP_LINE_CATEGORY := 'and l.line_category_code = ''ORDER'' ';
      END IF;
    END;
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION C_SET_LBLFORMULA RETURN VARCHAR2 IS
  BEGIN
    BEGIN
      /*SRW.REFERENCE(P_ORDER_BY)*/NULL;
      IF P_CUSTOMER_NAME_LOW IS NOT NULL OR P_CUSTOMER_NAME_HIGH IS NOT NULL THEN
        RP_CUSTOMER_RANGE := 'From ' || NVL(SUBSTR(P_CUSTOMER_NAME_LOW
                                       ,1
                                       ,16)
                                ,'     ') || ' To ' || NVL(SUBSTR(P_CUSTOMER_NAME_HIGH
                                       ,1
                                       ,16)
                                ,'     ');
      END IF;
      IF P_CUSTOMER_NUM_LOW IS NOT NULL OR P_CUSTOMER_NUM_HIGH IS NOT NULL THEN
        RP_CUSTOMER_NUM_RANGE := 'From ' || NVL(P_CUSTOMER_NUM_LOW
                                    ,'      ') || 'To ' || NVL(P_CUSTOMER_NUM_HIGH
                                    ,'        ');
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
      IF P_ORDER_DATE_LOW IS NOT NULL AND P_ORDER_DATE_HIGH IS NOT NULL THEN
        RP_ORDER_DATE_RANGE := 'From ' || P_ORDER_DATE_LOW || ' To ' || P_ORDER_DATE_HIGH;
      ELSIF P_ORDER_DATE_LOW IS NOT NULL THEN
        RP_ORDER_DATE_RANGE := 'From ' || P_ORDER_DATE_LOW || ' To ' || '    ';
      ELSIF P_ORDER_DATE_HIGH IS NOT NULL THEN
        RP_ORDER_DATE_RANGE := 'From ' || '    ' || ' To ' || P_ORDER_DATE_HIGH;
      END IF;
      IF P_ORDER_NUM_LOW IS NOT NULL OR P_ORDER_NUM_HIGH IS NOT NULL THEN
        RP_ORDER_RANGE := 'From ' || NVL(P_ORDER_NUM_LOW
                             ,'     ') || ' To ' || NVL(P_ORDER_NUM_HIGH
                             ,'     ');
      END IF;
      IF P_ORDER_BY IS NOT NULL THEN
        DECLARE
          ORDER_BY VARCHAR2(80);
          L_LOOKUP_TYPE VARCHAR2(30) := 'OEXOESOS ORDER BY';
          L_LOOKUP_CODE VARCHAR2(30) := P_ORDER_BY;
        BEGIN
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
      IF P_OPEN_ORDERS_ONLY IS NOT NULL THEN
        DECLARE
          MEANING VARCHAR2(80);
          L_LOOKUP_TYPE VARCHAR2(30) := 'YES_NO';
          L_LOOKUP_CODE VARCHAR2(30) := NVL(P_OPEN_ORDERS_ONLY
             ,'N');
        BEGIN
          SELECT
            MEANING
          INTO MEANING
          FROM
            FND_LOOKUPS
          WHERE LOOKUP_TYPE = L_LOOKUP_TYPE
            AND LOOKUP_CODE = L_LOOKUP_CODE;
          RP_OPEN_ORDERS_ONLY := MEANING;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            RP_OPEN_ORDERS_ONLY := P_OPEN_ORDERS_ONLY;
        END;
      END IF;
      DECLARE
        MEANING VARCHAR2(80);
        L_LOOKUP_TYPE VARCHAR2(30) := 'YES_NO';
        L_LOOKUP_CODE VARCHAR2(30) := P_USE_FUNCTIONAL_CURRENCY;
      BEGIN
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
        L_LOOKUP_TYPE VARCHAR2(30) := 'ITEM_DISPLAY_CODE';
        L_LOOKUP_CODE VARCHAR2(30) := P_PRINT_DESCRIPTION;
      BEGIN
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
                                ,ORDERED_DATE IN DATE
                                ,CONVERSION_TYPE_CODE IN VARCHAR2
                                ,CONVERSION_RATE IN NUMBER) RETURN NUMBER IS
  BEGIN
    DECLARE
      GL_RATE NUMBER;
    BEGIN
      /*SRW.REFERENCE(CURRENCY_CODE)*/NULL;
      /*SRW.REFERENCE(ORDERED_DATE)*/NULL;
      /*SRW.REFERENCE(CONVERSION_TYPE_CODE)*/NULL;
      IF P_USE_FUNCTIONAL_CURRENCY = 'Y' THEN
        IF CURRENCY_CODE = RP_FUNCTIONAL_CURRENCY THEN
          RETURN (1);
        ELSE
          IF CONVERSION_RATE IS NULL THEN
            GL_RATE := GET_RATE(P_SOB_ID
                               ,CURRENCY_CODE
                               ,TRUNC(ORDERED_DATE)
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

  FUNCTION C_PRICEFORMULA(EXTENDED_PRICE IN NUMBER
                         ,C_GL_CONV_RATE IN NUMBER) RETURN NUMBER IS
  BEGIN
    DECLARE
      AMOUNT NUMBER(14,2);
    BEGIN
      /*SRW.REFERENCE(EXTENDED_PRICE)*/NULL;
      /*SRW.REFERENCE(C_GL_CONV_RATE)*/NULL;
      IF P_USE_FUNCTIONAL_CURRENCY = 'Y' THEN
        IF C_GL_CONV_RATE <> -1 THEN
          SELECT
            C_GL_CONV_RATE * EXTENDED_PRICE
          INTO AMOUNT
          FROM
            DUAL;
          RETURN (AMOUNT);
        ELSE
          RETURN (0);
        END IF;
      ELSE
        RETURN (EXTENDED_PRICE);
      END IF;
    END;
    RETURN NULL;
  END C_PRICEFORMULA;

  FUNCTION C_CURRENCY_CODEFORMULA(CURRENCY_CODE IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    /*SRW.REFERENCE(CURRENCY_CODE)*/NULL;
    RP_DATA_FOUND := 'X';
    IF P_USE_FUNCTIONAL_CURRENCY = 'Y' THEN
      RETURN (RP_FUNCTIONAL_CURRENCY);
    ELSE
      RETURN (CURRENCY_CODE);
    END IF;
    RETURN NULL;
  END C_CURRENCY_CODEFORMULA;

  FUNCTION C_DISCOUNT_CURRFORMULA(S_SELLP_CURR IN NUMBER
                                 ,S_LISTP_CURR IN NUMBER
                                 ,S_SELLP_CURR_RMA IN NUMBER
                                 ,S_LISTP_CURR_RMA IN NUMBER) RETURN NUMBER IS
  BEGIN
    DECLARE
      DISCOUNT NUMBER;
    BEGIN
      /*SRW.REFERENCE(S_SELLP_CURR)*/NULL;
      /*SRW.REFERENCE(S_LISTP_CURR)*/NULL;
      /*SRW.REFERENCE(S_SELLP_CURR_RMA)*/NULL;
      /*SRW.REFERENCE(S_LISTP_CURR_RMA)*/NULL;
      IF S_LISTP_CURR - 2 * S_LISTP_CURR_RMA <> 0 THEN
        SELECT
          ( ( S_LISTP_CURR - 2 * S_LISTP_CURR_RMA ) - ( S_SELLP_CURR - 2 * S_SELLP_CURR_RMA ) ) / ( S_LISTP_CURR - 2 * S_LISTP_CURR_RMA ) * 100
        INTO DISCOUNT
        FROM
          DUAL;
        RETURN (DISCOUNT);
      ELSE
        RETURN (0);
      END IF;
    END;
    RETURN NULL;
  END C_DISCOUNT_CURRFORMULA;

  FUNCTION C_DISCOUNT_SRFORMULA(S_SELLP_SR IN NUMBER
                               ,S_LISTP_SR IN NUMBER
                               ,S_SELLP_SR_RMA IN NUMBER
                               ,S_LISTP_SR_RMA IN NUMBER) RETURN NUMBER IS
  BEGIN
    DECLARE
      DISCOUNT NUMBER;
    BEGIN
      /*SRW.REFERENCE(S_SELLP_SR)*/NULL;
      /*SRW.REFERENCE(S_LISTP_SR)*/NULL;
      /*SRW.REFERENCE(S_SELLP_SR_RMA)*/NULL;
      /*SRW.REFERENCE(S_LISTP_SR_RMA)*/NULL;
      IF S_LISTP_SR - 2 * S_LISTP_SR_RMA <> 0 THEN
        SELECT
          ( ( S_LISTP_SR - 2 * S_LISTP_SR_RMA ) - ( S_SELLP_SR - 2 * S_SELLP_SR_RMA ) ) / ( S_LISTP_SR - 2 * S_LISTP_SR_RMA ) * 100
        INTO DISCOUNT
        FROM
          DUAL;
        RETURN (DISCOUNT);
      ELSE
        RETURN (0);
      END IF;
    END;
    RETURN NULL;
  END C_DISCOUNT_SRFORMULA;

  FUNCTION C_DISCOUNT_CUSTFORMULA(S_SELLP_CUST IN NUMBER
                                 ,S_LISTP_CUST IN NUMBER) RETURN NUMBER IS
  BEGIN
    DECLARE
      DISCOUNT NUMBER;
    BEGIN
      /*SRW.REFERENCE(S_SELLP_CUST)*/NULL;
      /*SRW.REFERENCE(S_LISTP_CUST)*/NULL;
      IF S_LISTP_CUST <> 0 THEN
        SELECT
          ( S_LISTP_CUST - S_SELLP_CUST ) / S_LISTP_CUST * 100
        INTO DISCOUNT
        FROM
          DUAL;
        RETURN (DISCOUNT);
      ELSE
        RETURN (0);
      END IF;
    END;
    RETURN NULL;
  END C_DISCOUNT_CUSTFORMULA;

  FUNCTION C_SALE_PRICEFORMULA(SALE_PRICE IN NUMBER
                              ,C_GL_CONV_RATE IN NUMBER) RETURN NUMBER IS
  BEGIN
    DECLARE
      AMOUNT NUMBER(14,2);
    BEGIN
      /*SRW.REFERENCE(SALE_PRICE)*/NULL;
      /*SRW.REFERENCE(C_GL_CONV_RATE)*/NULL;
      IF P_USE_FUNCTIONAL_CURRENCY = 'Y' THEN
        IF C_GL_CONV_RATE <> -1 THEN
          SELECT
            C_GL_CONV_RATE * SALE_PRICE
          INTO AMOUNT
          FROM
            DUAL;
          RETURN (AMOUNT);
        ELSE
          RETURN (0);
        END IF;
      ELSE
        RETURN (SALE_PRICE);
      END IF;
    END;
    RETURN NULL;
  END C_SALE_PRICEFORMULA;

  FUNCTION C_DISCOUNT_ORDERFORMULA(S_SELLP_ORDER IN NUMBER
                                  ,S_LISTP_ORDER IN NUMBER) RETURN NUMBER IS
  BEGIN
    DECLARE
      DISCOUNT NUMBER;
    BEGIN
      /*SRW.REFERENCE(S_SELLP_ORDER)*/NULL;
      /*SRW.REFERENCE(S_LISTP_ORDER)*/NULL;
      IF S_LISTP_ORDER <> 0 THEN
        SELECT
          ( S_LISTP_ORDER - S_SELLP_ORDER ) / S_LISTP_ORDER * 100
        INTO DISCOUNT
        FROM
          DUAL;
        RETURN (DISCOUNT);
      ELSE
        RETURN (0);
      END IF;
    END;
    RETURN NULL;
  END C_DISCOUNT_ORDERFORMULA;

  FUNCTION C_SALESREP_TOTAL_NETFORMULA RETURN NUMBER IS
  BEGIN
    RETURN NULL;
  END C_SALESREP_TOTAL_NETFORMULA;

  FUNCTION S_PRICE_CURR_NETFORMULA(S_PRICE_CURR IN NUMBER
                                  ,S_PRICE_CURR_RMA IN NUMBER) RETURN NUMBER IS
  BEGIN
    DECLARE
      TOTAL_NET NUMBER;
    BEGIN
      /*SRW.REFERENCE(S_PRICE_CURR)*/NULL;
      /*SRW.REFERENCE(S_PRICE_CURR_RMA)*/NULL;
      SELECT
        ( S_PRICE_CURR - 2 * S_PRICE_CURR_RMA )
      INTO TOTAL_NET
      FROM
        DUAL;
      RETURN (TOTAL_NET);
    END;
    RETURN NULL;
  END S_PRICE_CURR_NETFORMULA;

  FUNCTION RP_ORDER_CATEGORYFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      L_MEANING VARCHAR2(80);
      L_LOOKUP_TYPE VARCHAR2(30) := 'REPORT_ORDER_CATEGORY';
      L_LOOKUP_CODE VARCHAR2(30) := P_ORDER_CATEGORY;
    BEGIN
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
    RETURN (NULL);
  END RP_ORDER_CATEGORYFORMULA;

  FUNCTION RP_LINE_CATEGORYFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      L_MEANING VARCHAR2(80);
      L_LOOKUP_TYPE VARCHAR2(30) := 'REPORT_LINE_DISPLAY';
      L_LOOKUP_CODE VARCHAR2(30) := P_LINE_CATEGORY;
    BEGIN
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
    RETURN NULL;
  END RP_LINE_CATEGORYFORMULA;

  FUNCTION C_COUNT_LINEFORMULA(HEADER_ID IN NUMBER) RETURN NUMBER IS
  BEGIN
    DECLARE
      LINE_NUM NUMBER;
    BEGIN
      SELECT
        count(SC.LINE_ID)
      INTO LINE_NUM
      FROM
        OE_SALES_CREDITS SC
      WHERE SC.HEADER_ID = C_COUNT_LINEFORMULA.HEADER_ID;
      RETURN (LINE_NUM);
    END;
    RETURN NULL;
  END C_COUNT_LINEFORMULA;

  FUNCTION C_COUNT_SALESREPFORMULA(HEADER_ID IN NUMBER) RETURN NUMBER IS
  BEGIN
    DECLARE
      SALESREP_NUM NUMBER;
    BEGIN
      IF (G_HEADER_SC_TBL.EXISTS(MOD(HEADER_ID
                                ,G_BINARY_LIMIT))) THEN
        /*SRW.MESSAGE(1
                   ,'In c_count_salesrep: header_id ' || HEADER_ID || ' exists')*/NULL;
        SALESREP_NUM := G_HEADER_SC_TBL(MOD(HEADER_ID
                                           ,G_BINARY_LIMIT)).COUNT_SALESREP;
        /*SRW.MESSAGE(1
                   ,'In c_count_salesrep: salesrep_num ' || SALESREP_NUM)*/NULL;
      ELSE
        SELECT
          count(SC.SALESREP_ID)
        INTO SALESREP_NUM
        FROM
          OE_SALES_CREDITS SC
        WHERE SC.HEADER_ID = C_COUNT_SALESREPFORMULA.HEADER_ID;
        G_HEADER_SC_TBL(MOD(HEADER_ID
                           ,G_BINARY_LIMIT)).HEADER_ID := HEADER_ID;
        G_HEADER_SC_TBL(MOD(HEADER_ID
                           ,G_BINARY_LIMIT)).COUNT_SALESREP := SALESREP_NUM;
      END IF;
      RETURN (SALESREP_NUM);
    END;
    RETURN NULL;
  END C_COUNT_SALESREPFORMULA;

  FUNCTION S_SALESREP_TOTAL_NETFORMULA(C_SALESREP_TOTAL IN NUMBER
                                      ,C_SALESREP_TOTAL_RMA IN NUMBER) RETURN NUMBER IS
  BEGIN
    DECLARE
      TOTAL_NET NUMBER;
    BEGIN
      /*SRW.REFERENCE(C_SALESREP_TOTAL)*/NULL;
      /*SRW.REFERENCE(C_SALESREP_TOTAL_RMA)*/NULL;
      SELECT
        ( C_SALESREP_TOTAL - 2 * C_SALESREP_TOTAL_RMA )
      INTO TOTAL_NET
      FROM
        DUAL;
      RETURN (TOTAL_NET);
    END;
    RETURN NULL;
  END S_SALESREP_TOTAL_NETFORMULA;

  FUNCTION C_CHARGE_PERIODICITYFORMULA(CHARGE_PERIODICITY_CODE IN VARCHAR2) RETURN CHAR IS
    L_CHARGE_PERIODICITY VARCHAR2(25);
  BEGIN
    IF CHARGE_PERIODICITY_CODE IS NOT NULL THEN
      SELECT
        UNIT_OF_MEASURE
      INTO L_CHARGE_PERIODICITY
      FROM
        MTL_UNITS_OF_MEASURE_VL
      WHERE UOM_CODE = CHARGE_PERIODICITY_CODE
        AND UOM_CLASS = FND_PROFILE.VALUE('ONT_UOM_CLASS_CHARGE_PERIODICITY');
      RETURN L_CHARGE_PERIODICITY;
    ELSE
      RETURN (P_CHARGE_PERIODICITY);
    END IF;
    RETURN NULL;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
  END C_CHARGE_PERIODICITYFORMULA;

  FUNCTION C_DISCOUNT_PERIODICITYFORMULA(S_SELLP_PERIODICITY IN NUMBER
                                        ,S_LISTP_PERIODICITY IN NUMBER) RETURN NUMBER IS
  BEGIN
    DECLARE
      DISCOUNT NUMBER;
    BEGIN
      /*SRW.REFERENCE(S_SELLP_PERIODICITY)*/NULL;
      /*SRW.REFERENCE(S_LISTP_PERIODICITY)*/NULL;
      IF S_LISTP_PERIODICITY <> 0 THEN
        SELECT
          ( S_LISTP_PERIODICITY - S_SELLP_PERIODICITY ) / S_LISTP_PERIODICITY * 100
        INTO DISCOUNT
        FROM
          DUAL;
        RETURN (DISCOUNT);
      ELSE
        RETURN (0);
      END IF;
    END;
    RETURN NULL;
  END C_DISCOUNT_PERIODICITYFORMULA;

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

  FUNCTION RP_ORDER_DATE_RANGE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_ORDER_DATE_RANGE;
  END RP_ORDER_DATE_RANGE_P;

  FUNCTION RP_SALES_REASON_LBL_2_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_SALES_REASON_LBL_2;
  END RP_SALES_REASON_LBL_2_P;

  FUNCTION RP_ORDER_BY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_ORDER_BY;
  END RP_ORDER_BY_P;

  FUNCTION RP_OPEN_ORDERS_ONLY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_OPEN_ORDERS_ONLY;
  END RP_OPEN_ORDERS_ONLY_P;

  FUNCTION RP_USE_FUNCTIONAL_CURRENCY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_USE_FUNCTIONAL_CURRENCY;
  END RP_USE_FUNCTIONAL_CURRENCY_P;

  FUNCTION RP_FLEX_OR_DESC_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_FLEX_OR_DESC;
  END RP_FLEX_OR_DESC_P;

  FUNCTION RP_AGREEMENT_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_AGREEMENT_NAME;
  END RP_AGREEMENT_NAME_P;

  FUNCTION RP_CUSTOMER_NUM_RANGE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_CUSTOMER_NUM_RANGE;
  END RP_CUSTOMER_NUM_RANGE_P;

  FUNCTION IS_FIXED_RATE(X_FROM_CURRENCY IN VARCHAR2
                        ,X_TO_CURRENCY IN VARCHAR2
                        ,X_EFFECTIVE_DATE IN DATE) RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
    /*STPROC.INIT('begin :X0 := GL_CURRENCY_API.IS_FIXED_RATE(:X_FROM_CURRENCY, :X_TO_CURRENCY, :X_EFFECTIVE_DATE); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(X_FROM_CURRENCY);
    STPROC.BIND_I(X_TO_CURRENCY);
    STPROC.BIND_I(X_EFFECTIVE_DATE);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);
    RETURN X0;*/
    RETURN(NULL);
  END IS_FIXED_RATE;

  PROCEDURE GET_RELATION(X_FROM_CURRENCY IN VARCHAR2
                        ,X_TO_CURRENCY IN VARCHAR2
                        ,X_EFFECTIVE_DATE IN DATE
                        ,X_FIXED_RATE IN OUT NOCOPY BOOLEAN
                        ,X_RELATIONSHIP IN OUT NOCOPY VARCHAR2) IS
  BEGIN
    /*STPROC.INIT('declare X_FIXED_RATE BOOLEAN;
    begin X_FIXED_RATE := sys.diutil.int_to_bool(:X_FIXED_RATE);
    GL_CURRENCY_API.GET_RELATION(:X_FROM_CURRENCY, :X_TO_CURRENCY, :X_EFFECTIVE_DATE, X_FIXED_RATE,
    :X_RELATIONSHIP); :X_FIXED_RATE := sys.diutil.bool_to_int(X_FIXED_RATE); end;');
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
    /*(STPROC.INIT('begin :X0 := GL_CURRENCY_API.GET_EURO_CODE; end;');
    STPROC.BIND_O(X0);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);
    RETURN X0;*/
    RETURN (NULL);
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
                   ,X0);
    RETURN X0;*/
    RETURN (NULL);
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
                   ,X0);
    RETURN X0; */
     RETURN (NULL);
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
                   ,X0);
    RETURN X0;*/
     RETURN (NULL);

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
                   ,X0);
    RETURN X0;*/
     RETURN (NULL);
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
                   ,X0);
    RETURN X0;*/
     RETURN (NULL);
  END GET_DERIVE_TYPE;

FUNCTION F_PERIODICITYFORMATTRIGGER RETURN VARCHAR2 IS
BEGIN
  IF OE_SYS_PARAMETERS.VALUE ('RECURRING_CHARGES',MO_GLOBAL.GET_CURRENT_ORG_ID()) = 'Y' THEN
   RETURN ('TRUE');
  ELSE
   RETURN ('FALSE');
  END IF;
  RETURN ('FALSE');
END;

END ONT_OEXOESOS_XMLP_PKG;



/
