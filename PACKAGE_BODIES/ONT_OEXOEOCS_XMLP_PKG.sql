--------------------------------------------------------
--  DDL for Package Body ONT_OEXOEOCS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_OEXOEOCS_XMLP_PKG" AS
/* $Header: OEXOEOCSB.pls 120.3 2008/05/05 12:37:45 dwkrishn noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN

	P_ORGANIZATION_ID1 := P_ORGANIZATION_ID;

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
       -- P_ORGANIZATION_ID := MO_GLOBAL.GET_CURRENT_ORG_ID;
        P_ORGANIZATION_ID1 := MO_GLOBAL.GET_CURRENT_ORG_ID;
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
        END IF;
	IF (lp_item_flex_all_seg IS NULL) THEN
	lp_item_flex_all_seg := ' ';
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
        RP_REPORT_NAME := L_REPORT_NAME;

      IF (UPPER(RP_REPORT_NAME) = 'CANCELLED ORDERS REPORT (XML)') THEN
	RP_REPORT_NAME := 'Cancelled Orders Report' ;
      END IF;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RP_REPORT_NAME := 'Cancelled Orders Report';
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
    P_ORDER_DATE_LOW1 := TO_CHAR(P_ORDER_DATE_LOW,'DD-MON-YY');
	P_ORDER_DATE_HIGH1 := TO_CHAR(P_ORDER_DATE_HIGH,'DD-MON-YY');
      IF P_ORDER_NUM_LOW IS NOT NULL AND P_ORDER_NUM_HIGH IS NOT NULL THEN
        LP_ORDER_NUM := ' AND  h.order_number  between to_number(:p_order_num_low) and to_number(:p_order_num_high)  ';
      ELSIF (P_ORDER_NUM_LOW IS NOT NULL) THEN
        LP_ORDER_NUM := 'and h.order_number >= to_number(:p_order_num_low) ';
      ELSIF (P_ORDER_NUM_HIGH IS NOT NULL) THEN
        LP_ORDER_NUM := 'and h.order_number <= to_number(:p_order_num_high) ';
      END IF;

IF (lp_order_num IS NULL) THEN
	lp_order_num := ' ';
END IF;

      IF P_SALESREP_LOW IS NOT NULL AND P_SALESREP_HIGH IS NOT NULL THEN
        LP_SALESREP := ' AND nvl(sr.name,''zzzzzz'') between :p_salesrep_low and :p_salesrep_high ';
      ELSIF (P_SALESREP_LOW IS NOT NULL) THEN
        LP_SALESREP := 'and sr.name >= :p_salesrep_low ';
      ELSIF (P_SALESREP_HIGH IS NOT NULL) THEN
        LP_SALESREP := 'and sr.name <= :p_salesrep_high ';
      END IF;

      IF (lp_salesrep IS NULL) THEN
	lp_salesrep := ' ';
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
      END IF;

IF (lp_order_date IS NULL) THEN
	lp_order_date := ' ';
END IF;

      IF P_CUSTOMER_NAME_LOW IS NOT NULL AND P_CUSTOMER_NAME_HIGH IS NOT NULL THEN
        LP_CUSTOMER_NAME := ' AND org.name between :p_customer_name_low and :p_customer_name_high ';
      ELSIF (P_CUSTOMER_NAME_LOW IS NOT NULL) THEN
        LP_CUSTOMER_NAME := 'and org.name >= :p_customer_name_low ';
      ELSIF (P_CUSTOMER_NAME_HIGH IS NOT NULL) THEN
        LP_CUSTOMER_NAME := 'and org.name <= :p_customer_name_high ';
      END IF;

IF (lp_customer_name IS NULL) THEN
	lp_customer_name := ' ';
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

      IF (lp_order_category IS NULL) THEN
	lp_order_category := ' ';
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

IF (lp_line_category IS NULL) THEN
	lp_line_category := ' ';
END IF;
    RETURN (TRUE);
  END AFTERPFORM;

function Item_dspFormula(item_identifier_type in varchar2, IID number, ORDERED_ITEM_ID number, ORDERED_ITEM varchar2,C_ORGANIZATION_ID in varchar2,C_INVENTORY_ITEM_ID in varchar2) return Char is
v_item varchar2(2000);
v_description varchar2(500);
begin
  if (item_identifier_type is null or item_identifier_type = 'INT')
       or (p_print_description in ('I','D','F')) then
    select sitems.concatenated_segments item,
    	   sitems.description description
    into   v_item,v_description
    from   mtl_system_items_vl sitems
    where
--    sitems.customer_order_enabled_flag = 'Y'    --> Commented for the bug 2864636
--    and    sitems.bom_item_type in (1,4)
    nvl(sitems.organization_id,0) = nvl(oe_sys_parameters.value('MASTER_ORGANIZATION_ID',mo_global.get_current_org_id()),0)
    and    sitems.inventory_item_id = iid;
    rp_dummy_item := v_item;
       rp_dummy_item := '';
   v_item := fnd_flex_xml_publisher_apis.process_kff_combination_1('Item_dsp', 'INV', p_item_flex_code, p_item_structure_num, C_ORGANIZATION_ID,C_INVENTORY_ITEM_ID, 'ALL', 'Y', 'VALUE');

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
    and    nvl(sitems.organization_id,0) = nvl(oe_sys_parameters.value('MASTER_ORGANIZATION_ID',mo_global.get_current_org_id()),0)
    and    sitems.inventory_item_id = iid;
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
    and    nvl(sitems.organization_id,0) = nvl(oe_sys_parameters.value('MASTER_ORGANIZATION_ID',mo_global.get_current_org_id()),0)
    and    sitems.inventory_item_id = iid
    --Bug 3433353 Begin
    and    items.org_independent_flag = 'N'
    and    items.organization_id = nvl(oe_sys_parameters.value('MASTER_ORGANIZATION_ID',mo_global.get_current_org_id()),0);
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
    and nvl(sitems.organization_id,0) = nvl(oe_sys_parameters.value('MASTER_ORGANIZATION_ID',mo_global.get_current_org_id()),0)
    and sitems.inventory_item_id = iid
    and items.org_independent_flag = 'Y';
    End;

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
        --RP_ORDER_DATE_RANGE := 'From ' || P_ORDER_DATE_LOW || ' To ' || P_ORDER_DATE_HIGH;
	RP_ORDER_DATE_RANGE := 'From ' || P_ORDER_DATE_LOW1 || ' To ' || P_ORDER_DATE_HIGH1;
      ELSIF P_ORDER_DATE_LOW IS NOT NULL THEN
        --RP_ORDER_DATE_RANGE := 'From ' || P_ORDER_DATE_LOW || ' To ' || '       ';
	RP_ORDER_DATE_RANGE := 'From ' || P_ORDER_DATE_LOW1 || ' To ' || '       ';
      ELSIF P_ORDER_DATE_HIGH IS NOT NULL THEN
        --RP_ORDER_DATE_RANGE := 'From ' || '       ' || ' To ' || P_ORDER_DATE_HIGH;
	RP_ORDER_DATE_RANGE := 'From ' || '       ' || ' To ' || P_ORDER_DATE_HIGH1;
      END IF;
      IF P_ORDER_NUM_LOW IS NOT NULL OR P_ORDER_NUM_HIGH IS NOT NULL THEN
        RP_ORDER_RANGE := 'From ' || NVL(P_ORDER_NUM_LOW
                             ,'     ') || ' To ' || NVL(P_ORDER_NUM_HIGH
                             ,'     ');
      END IF;
      IF P_ORDER_BY IS NOT NULL THEN
        DECLARE
          ORDER_BY VARCHAR2(80);
        BEGIN
          SELECT
            MEANING
          INTO ORDER_BY
          FROM
            OE_LOOKUPS
          WHERE LOOKUP_TYPE = 'OEXOEOCS SORT BY'
            AND LOOKUP_CODE = P_ORDER_BY;
          RP_ORDER_BY := ORDER_BY;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            RP_ORDER_BY := P_ORDER_BY;
        END;
      END IF;
      DECLARE
        MEANING VARCHAR2(80);
      BEGIN
        SELECT
          MEANING
        INTO MEANING
        FROM
          FND_LOOKUPS
        WHERE LOOKUP_TYPE = 'YES_NO'
          AND LOOKUP_CODE = P_USE_FUNCTIONAL_CURRENCY;
        RP_USE_FUNCTIONAL_CURRENCY := MEANING;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RP_USE_FUNCTIONAL_CURRENCY := P_USE_FUNCTIONAL_CURRENCY;
      END;
      DECLARE
        ITEM_DISPLAY_MEANING VARCHAR2(80);
      BEGIN
        SELECT
          MEANING
        INTO ITEM_DISPLAY_MEANING
        FROM
          OE_LOOKUPS
        WHERE LOOKUP_TYPE = 'ITEM_DISPLAY_CODE'
          AND LOOKUP_CODE = P_PRINT_DESCRIPTION;
        RP_FLEX_OR_DESC := ITEM_DISPLAY_MEANING;
      END;
      RETURN (1);
    END;
    RETURN NULL;
  END C_SET_LBLFORMULA;

  FUNCTION C_GL_CONV_RATEFORMULA(CURRENCY2 IN VARCHAR2
                                ,ORD_DATE IN DATE
                                ,CONVERSION_TYPE_CODE IN VARCHAR2
                                ,CONVERSION_RATE IN NUMBER) RETURN NUMBER IS
  BEGIN
    DECLARE
      GL_RATE NUMBER;
    BEGIN
      /*SRW.REFERENCE(CURRENCY2)*/NULL;
      /*SRW.REFERENCE(ORD_DATE)*/NULL;
      /*SRW.REFERENCE(CONVERSION_TYPE_CODE)*/NULL;
      IF P_USE_FUNCTIONAL_CURRENCY = 'Y' THEN
        IF CURRENCY2 = RP_FUNCTIONAL_CURRENCY THEN
          RETURN (1);
        ELSE
          IF CONVERSION_RATE IS NULL THEN
            GL_RATE := GET_RATE(P_SOB_ID
                               ,CURRENCY2
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

  FUNCTION C_AMOUNTFORMULA(AMOUNT IN NUMBER
                          ,C_GL_CONV_RATE IN NUMBER
                          ,C_PRECISION IN NUMBER) RETURN NUMBER IS
  BEGIN
    DECLARE
      ORDER_AMOUNT NUMBER(14,2);
    BEGIN
      /*SRW.REFERENCE(AMOUNT)*/NULL;
      /*SRW.REFERENCE(C_GL_CONV_RATE)*/NULL;
      /*SRW.REFERENCE(C_PRECISION)*/NULL;
      IF P_USE_FUNCTIONAL_CURRENCY = 'Y' THEN
        IF C_GL_CONV_RATE <> -1 THEN
          SELECT
            C_GL_CONV_RATE * AMOUNT
          INTO ORDER_AMOUNT
          FROM
            DUAL;
          RETURN (ROUND(ORDER_AMOUNT
                      ,C_PRECISION));
        ELSE
          RETURN (0);
        END IF;
      ELSE
        RETURN (ROUND(AMOUNT
                    ,C_PRECISION));
      END IF;
    END;
    RETURN NULL;
  END C_AMOUNTFORMULA;

  FUNCTION C_CURRENCY_CODEFORMULA(CURRENCY2 IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    /*SRW.REFERENCE(CURRENCY2)*/NULL;
    IF P_USE_FUNCTIONAL_CURRENCY = 'Y' THEN
      RETURN (RP_FUNCTIONAL_CURRENCY);
    ELSE
      RETURN (CURRENCY2);
    END IF;
    RETURN NULL;
  END C_CURRENCY_CODEFORMULA;

  FUNCTION RP_ORDER_CATEGORYFORMULA RETURN VARCHAR2 IS
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

  FUNCTION RP_LINE_CATEGORYFORMULA RETURN VARCHAR2 IS
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

  FUNCTION CF_UNIT4FORMULA(UNIT2 IN VARCHAR2) RETURN CHAR IS
  BEGIN
    CP_UNIT4 := UNIT2;
    RETURN 1;
  END CF_UNIT4FORMULA;

  FUNCTION CF_UNIT3FORMULA(UNIT1 IN VARCHAR2) RETURN CHAR IS
  BEGIN
    CP_UNIT3 := UNIT1;
    RETURN 1;
  END CF_UNIT3FORMULA;

  FUNCTION C_PRECISIONFORMULA(P_CURRENCY_CODE IN VARCHAR2) RETURN NUMBER IS
  BEGIN
    DECLARE
      W_PRECISION NUMBER;
    BEGIN
      SELECT
        PRECISION
      INTO W_PRECISION
      FROM
        FND_CURRENCIES
     -- WHERE CURRENCY_CODE = CURRENCY_CODE
      WHERE CURRENCY_CODE = P_CURRENCY_CODE;
      RETURN (W_PRECISION);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        W_PRECISION := 2;
        RETURN (W_PRECISION);
    END;
    RETURN NULL;
  END C_PRECISIONFORMULA;

  FUNCTION RP_DUMMY_ITEM_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_DUMMY_ITEM;
  END RP_DUMMY_ITEM_P;

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

  FUNCTION RP_ORDER_BY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_ORDER_BY;
  END RP_ORDER_BY_P;

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

  FUNCTION CP_UNIT3_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_UNIT3;
  END CP_UNIT3_P;

  FUNCTION CP_UNIT4_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_UNIT4;
  END CP_UNIT4_P;

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
		   null;
    RETURN X0;
  END IS_FIXED_RATE;

  PROCEDURE GET_RELATION(X_FROM_CURRENCY IN VARCHAR2
                        ,X_TO_CURRENCY IN VARCHAR2
                        ,X_EFFECTIVE_DATE IN DATE
                        ,X_FIXED_RATE IN OUT NOCOPY BOOLEAN
                        ,X_RELATIONSHIP IN OUT NOCOPY VARCHAR2) IS
  BEGIN
   /* STPROC.INIT('declare X_FIXED_RATE BOOLEAN;
   begin
   X_FIXED_RATE := sys.diutil.int_to_bool(:X_FIXED_RATE);
   GL_CURRENCY_API.GET_RELATION(:X_FROM_CURRENCY, :X_TO_CURRENCY, :X_EFFECTIVE_DATE, X_FIXED_RATE, :X_RELATIONSHIP); :X_FIXED_RATE := sys.diutil.bool_to_int(X_FIXED_RATE); end;');
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
		   null;
  END GET_RELATION;

  FUNCTION GET_EURO_CODE RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
 /*   STPROC.INIT('begin :X0 := GL_CURRENCY_API.GET_EURO_CODE; end;');
    STPROC.BIND_O(X0);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/
		   null;
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
                   ,X0);
		   */ null;
    RETURN X0;
  END GET_RATE;

  FUNCTION GET_RATE(X_SET_OF_BOOKS_ID IN NUMBER
                   ,X_FROM_CURRENCY IN VARCHAR2
                   ,X_CONVERSION_DATE IN DATE
                   ,X_CONVERSION_TYPE IN VARCHAR2) RETURN NUMBER IS
    X0 NUMBER;
  BEGIN
  /*  STPROC.INIT('begin :X0 := GL_CURRENCY_API.GET_RATE(:X_SET_OF_BOOKS_ID, :X_FROM_CURRENCY, :X_CONVERSION_DATE, :X_CONVERSION_TYPE); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(X_SET_OF_BOOKS_ID);
    STPROC.BIND_I(X_FROM_CURRENCY);
    STPROC.BIND_I(X_CONVERSION_DATE);
    STPROC.BIND_I(X_CONVERSION_TYPE);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);
		   */ null;
    RETURN X0;
  END GET_RATE;

  FUNCTION CONVERT_AMOUNT(X_FROM_CURRENCY IN VARCHAR2
                         ,X_TO_CURRENCY IN VARCHAR2
                         ,X_CONVERSION_DATE IN DATE
                         ,X_CONVERSION_TYPE IN VARCHAR2
                         ,X_AMOUNT IN NUMBER) RETURN NUMBER IS
    X0 NUMBER;
  BEGIN
  /*  STPROC.INIT('begin :X0 := GL_CURRENCY_API.CONVERT_AMOUNT(:X_FROM_CURRENCY, :X_TO_CURRENCY, :X_CONVERSION_DATE, :X_CONVERSION_TYPE, :X_AMOUNT); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(X_FROM_CURRENCY);
    STPROC.BIND_I(X_TO_CURRENCY);
    STPROC.BIND_I(X_CONVERSION_DATE);
    STPROC.BIND_I(X_CONVERSION_TYPE);
    STPROC.BIND_I(X_AMOUNT);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);
		   */ null;
    RETURN X0;
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
		   */ null;
    RETURN X0;
  END CONVERT_AMOUNT;

  FUNCTION GET_DERIVE_TYPE(SOB_ID IN NUMBER
                          ,PERIOD IN VARCHAR2
                          ,CURR_CODE IN VARCHAR2) RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
    /* STPROC.INIT('begin :X0 := GL_CURRENCY_API.GET_DERIVE_TYPE(:SOB_ID, :PERIOD, :CURR_CODE); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(SOB_ID);
    STPROC.BIND_I(PERIOD);
    STPROC.BIND_I(CURR_CODE);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);
		   */ null;
    RETURN X0;
  END GET_DERIVE_TYPE;

END ONT_OEXOEOCS_XMLP_PKG;



/
