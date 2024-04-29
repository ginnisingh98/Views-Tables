--------------------------------------------------------
--  DDL for Package Body ONT_OEXPRPRD_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_OEXPRPRD_XMLP_PKG" AS
/* $Header: OEXPRPRDB.pls 120.3 2008/05/05 06:40:04 dwkrishn noship $ */
function Item_dspFormula(item_identifier_type_L varchar2,
                         iid_L number ,
			  oid_L number,
			  oi_L varchar2,
			  INVENTORY_ITEM_ID_L number,
			  ORGANIZATION_ID_L number) return Char is
v_item varchar2(2000);
v_description varchar2(500);
begin
  if (item_identifier_type_L is null or item_identifier_type_L = 'INT')
       or (p_print_description in ('I','D','F')) then
    select
--	   sitems.concatenated_segments item,
    	   sitems.description description
    into
--	   v_item,
	   v_description
    from   mtl_system_items_vl sitems
    where
 	 sitems.customer_order_enabled_flag = 'Y'    and
	 sitems.bom_item_type in (1,4)
    and    nvl(sitems.organization_id,0) = nvl(oe_sys_parameters.value('MASTER_ORGANIZATION_ID',mo_global.get_current_org_id()),0)
    and    sitems.inventory_item_id = iid_L;
--    :rp_dummy_item := v_item;

  /*       srw.reference (:ITEM_FLEX);
         srw.reference (:p_item_flex_code);
         srw.reference (:Item_dsp);
         srw.reference (:p_item_structure_num);
         srw.user_exit (' FND FLEXIDVAL
		    CODE=":p_item_flex_code"
		    NUM=":p_item_structure_num"
		    APPL_SHORT_NAME="INV"
		    DATA= ":ITEM_FLEX"
		    VALUE=":Item_dsp"
		    DISPLAY="ALL"'
		);
--    :rp_dummy_item := ''; */
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
    and    citems.customer_item_id = oid_L
    and    nvl(sitems.organization_id,0) = nvl(oe_sys_parameters.value('MASTER_ORGANIZATION_ID',mo_global.get_current_org_id()),0)
    and    sitems.inventory_item_id = iid_L;
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
    and    items.cross_reference = oi_L
    and    items.cross_reference_type = item_identifier_type_L
    and    nvl(sitems.organization_id,0) = nvl(oe_sys_parameters.value('MASTER_ORGANIZATION_ID',mo_global.get_current_org_id()),0)
    and    sitems.inventory_item_id = iid_L;
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
        RP_REPORT_NAME := SUBSTR(L_REPORT_NAME,1,INSTR(L_REPORT_NAME,' (XML)'));
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RP_REPORT_NAME := 'Order Discount Detail Report';
      END;
      DECLARE
        L_ITEM_STRING VARCHAR2(5000);
      BEGIN
        /*SRW.REFERENCE(P_ITEM_FLEX_CODE)*/NULL;
        /*SRW.REFERENCE(P_ITEM_STRUCTURE_NUM)*/NULL;
        IF P_ITEM_LOW IS NOT NULL OR P_ITEM_HI IS NOT NULL THEN
          LP_ITEM := ' and ' || L_ITEM_STRING;
        ELSE
	  LP_ITEM := '  ';
        END IF;
      EXCEPTION
        WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
          /*SRW.MESSAGE(2000
                     ,'Failed in BEFORE REPORT trigger:MSTK')*/NULL;
      END;
      DECLARE
        L_MEANING VARCHAR2(80);
      BEGIN
        SELECT
          MEANING
        INTO L_MEANING
        FROM
          OE_LOOKUPS
        WHERE LOOKUP_TYPE = 'ITEM_DISPLAY_CODE'
          AND LOOKUP_CODE = SUBSTR(UPPER(NVL(P_PRINT_DESCRIPTION,'D'))
              ,1
              ,1);
        ITEM_FLEX_DESC_MEANING := L_MEANING;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          ITEM_FLEX_DESC_MEANING := 'Internal Item Description';
        WHEN OTHERS THEN
          /*SRW.MESSAGE(2000
                     ,'Failed in BEFORE REPORT trigger. Get Print Description')*/NULL;
      END;
      BEGIN
        RP_CURR_PROFILE := FND_PROFILE.VALUE('ONT_UNIT_PRICE_PRECISION_TYPE');
      EXCEPTION
        WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
          /*SRW.MESSAGE(3000
                     ,'Failed in BEFORE REPORT Trigger FND GETPROFILE USER_EXIT')*/NULL;
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
  openflag boolean;
  BEGIN
    DECLARE
      BLANKS CONSTANT VARCHAR2(5) DEFAULT '     ';
      ALL_RANGE CONSTANT VARCHAR2(16) DEFAULT 'From' || BLANKS || 'To' || BLANKS;
    BEGIN
      IF (P_ORDER_NUM_LOW IS NOT NULL) AND (P_ORDER_NUM_HIGH IS NOT NULL) THEN
        LP_ORDER_NUM := ' AND (H.ORDER_NUMBER BETWEEN' || ' TO_NUMBER(:P_ORDER_NUM_LOW) AND' || ' TO_NUMBER(:P_ORDER_NUM_HIGH)) ';
        ORDER_NUMBER_PARMS := 'From ' || SUBSTR(P_ORDER_NUM_LOW
                                    ,1
                                    ,6) || ' To ' || SUBSTR(P_ORDER_NUM_HIGH
                                    ,1
                                    ,6);
        ORDER_NUMBER_PARMS_LOW := SUBSTR(P_ORDER_NUM_LOW
                                        ,1
                                        ,6);
        ORDER_NUMBER_PARMS_HIGH := SUBSTR(P_ORDER_NUM_HIGH
                                         ,1
                                         ,6);
      ELSIF (P_ORDER_NUM_LOW IS NOT NULL) THEN
        LP_ORDER_NUM := ' AND H.ORDER_NUMBER >=' || ' TO_NUMBER(:P_ORDER_NUM_LOW) ';
        ORDER_NUMBER_PARMS := 'From ' || SUBSTR(P_ORDER_NUM_LOW
                                    ,1
                                    ,6) || ' To ' || BLANKS;
        ORDER_NUMBER_PARMS_LOW := SUBSTR(P_ORDER_NUM_LOW
                                        ,1
                                        ,6);
        ORDER_NUMBER_PARMS_HIGH := BLANKS;
      ELSIF (P_ORDER_NUM_HIGH IS NOT NULL) THEN
        LP_ORDER_NUM := ' AND H.ORDER_NUMBER <=' || ' TO_NUMBER(:P_ORDER_NUM_HIGH) ';
        ORDER_NUMBER_PARMS := 'From ' || BLANKS || 'To ' || SUBSTR(P_ORDER_NUM_HIGH
                                    ,1
                                    ,6);
        ORDER_NUMBER_PARMS_LOW := BLANKS;
        ORDER_NUMBER_PARMS_HIGH := SUBSTR(P_ORDER_NUM_HIGH
                                         ,1
                                         ,6);
      ELSE
        LP_ORDER_NUM := '  ';
        ORDER_NUMBER_PARMS := ALL_RANGE;
        ORDER_NUMBER_PARMS_LOW := BLANKS;
        ORDER_NUMBER_PARMS_HIGH := BLANKS;
      END IF;
      IF (P_CUSTOMER_NAME_LOW IS NOT NULL) AND (P_CUSTOMER_NAME_HIGH IS NOT NULL) THEN
        LP_CUSTOMER_NAME := ' AND (ORG.NAME BETWEEN' || ' :P_CUSTOMER_NAME_LOW AND' || ' :P_CUSTOMER_NAME_HIGH) ';
        CUSTOMER_PARMS := 'From ' || SUBSTR(P_CUSTOMER_NAME_LOW
                                ,1
                                ,20) || ' To ' || SUBSTR(P_CUSTOMER_NAME_HIGH
                                ,1
                                ,20);
        CUSTOMER_PARMS_LOW := SUBSTR(P_CUSTOMER_NAME_LOW
                                    ,1
                                    ,20);
        CUSTOMER_PARMS_HIGH := SUBSTR(P_CUSTOMER_NAME_HIGH
                                     ,1
                                     ,20);
      ELSIF (P_CUSTOMER_NAME_LOW IS NOT NULL) THEN
        LP_CUSTOMER_NAME := ' AND ORG.NAME >=' || ' :P_CUSTOMER_NAME_LOW ';
        CUSTOMER_PARMS := 'From ' || SUBSTR(P_CUSTOMER_NAME_LOW
                                ,1
                                ,20) || ' To ' || BLANKS;
        CUSTOMER_PARMS_LOW := SUBSTR(P_CUSTOMER_NAME_LOW
                                    ,1
                                    ,20);
        CUSTOMER_PARMS_HIGH := BLANKS;
      ELSIF (P_CUSTOMER_NAME_HIGH IS NOT NULL) THEN
        LP_CUSTOMER_NAME := ' AND ORG.NAME <=' || ' :P_CUSTOMER_NAME_HIGH ';
        CUSTOMER_PARMS := 'From ' || BLANKS || 'To ' || SUBSTR(P_CUSTOMER_NAME_HIGH
                                ,1
                                ,20);
        CUSTOMER_PARMS_LOW := BLANKS;
        CUSTOMER_PARMS_HIGH := SUBSTR(P_CUSTOMER_NAME_HIGH
                                     ,1
                                     ,20);
      ELSE
        LP_CUSTOMER_NAME := '  ';
        CUSTOMER_PARMS := ALL_RANGE;
        CUSTOMER_PARMS_LOW := BLANKS;
        CUSTOMER_PARMS_HIGH := BLANKS;
      END IF;
      IF (P_CUSTOMER_NUM_LOW IS NOT NULL) AND (P_CUSTOMER_NUM_HIGH IS NOT NULL) THEN
        LP_CUSTOMER_NUM := ' AND (ORG.CUSTOMER_NUMBER BETWEEN' || ' :P_CUSTOMER_NUM_LOW AND' || ' :P_CUSTOMER_NUM_HIGH) ';
        CUSTOMER_NUM_PARMS := 'From ' || SUBSTR(P_CUSTOMER_NUM_LOW
                                    ,1
                                    ,20) || ' To ' || SUBSTR(P_CUSTOMER_NUM_HIGH
                                    ,1
                                    ,20);
        CUSTOMER_NUM_PARMS_LOW := SUBSTR(P_CUSTOMER_NUM_LOW
                                        ,1
                                        ,20);
        CUSTOMER_NUM_PARMS_HIGH := SUBSTR(P_CUSTOMER_NUM_HIGH
                                         ,1
                                         ,20);
      ELSIF (P_CUSTOMER_NUM_LOW IS NOT NULL) THEN
        LP_CUSTOMER_NUM := ' AND ORG.CUSTOMER_NUMBER >=' || ' :P_CUSTOMER_NUM_LOW ';
        CUSTOMER_NUM_PARMS := 'From ' || SUBSTR(P_CUSTOMER_NUM_LOW
                                    ,1
                                    ,20) || ' To ' || BLANKS;
        CUSTOMER_NUM_PARMS_LOW := SUBSTR(P_CUSTOMER_NUM_LOW
                                        ,1
                                        ,20);
        CUSTOMER_NUM_PARMS_HIGH := BLANKS;
      ELSIF (P_CUSTOMER_NUM_HIGH IS NOT NULL) THEN
        LP_CUSTOMER_NUM := ' AND ORG.CUSTOMER_NUMBER <=' || ' :P_CUSTOMER_NUM_HIGH ';
        CUSTOMER_NUM_PARMS := 'From ' || BLANKS || 'To ' || SUBSTR(P_CUSTOMER_NUM_HIGH
                                    ,1
                                    ,20);
        CUSTOMER_NUM_PARMS_LOW := BLANKS;
        CUSTOMER_NUM_PARMS_HIGH := SUBSTR(P_CUSTOMER_NUM_HIGH
                                         ,1
                                         ,20);
      ELSE
        LP_CUSTOMER_NUM := '  ';
        CUSTOMER_NUM_PARMS := ALL_RANGE;
        CUSTOMER_NUM_PARMS_LOW := BLANKS;
        CUSTOMER_NUM_PARMS_HIGH := BLANKS;
      END IF;
      IF (P_ORDER_DATE_LOW IS NOT NULL) AND (P_ORDER_DATE_HIGH IS NOT NULL) THEN
        LP_ORDER_DATE := ' AND (trunc(H.ORDERED_DATE) BETWEEN' || ' :P_ORDER_DATE_LOW AND' || ' :P_ORDER_DATE_HIGH) ';
        ORDER_DATE_PARMS := 'From ' || TO_CHAR(P_ORDER_DATE_LOW
                                   ,'YYYY/MM/DD') || ' To ' || TO_CHAR(P_ORDER_DATE_HIGH
                                   ,'YYYY/MM/DD');
        ORDER_DATE_PARMS_LOW := TO_CHAR(P_ORDER_DATE_LOW
                                       ,'YYYY/MM/DD');
        ORDER_DATE_PARMS_HIGH := TO_CHAR(P_ORDER_DATE_HIGH
                                        ,'YYYY/MM/DD');
      ELSIF (P_ORDER_DATE_LOW IS NOT NULL) THEN
        LP_ORDER_DATE := ' AND trunc(H.ORDERED_DATE) >= :P_ORDER_DATE_LOW';
        ORDER_DATE_PARMS := 'From ' || TO_CHAR(P_ORDER_DATE_LOW
                                   ,'YYYY/MM/DD') || ' To ' || BLANKS;
        ORDER_DATE_PARMS_LOW := TO_CHAR(P_ORDER_DATE_LOW
                                       ,'YYYY/MM/DD');
        ORDER_DATE_PARMS_HIGH := BLANKS;
      ELSIF (P_ORDER_DATE_HIGH IS NOT NULL) THEN
        LP_ORDER_DATE := ' AND trunc(H.ORDERED_DATE) <= :P_ORDER_DATE_HIGH';
        ORDER_DATE_PARMS := 'From ' || BLANKS || 'To ' || TO_CHAR(P_ORDER_DATE_HIGH
                                   ,'YYYY/MM/DD');
        ORDER_DATE_PARMS_LOW := BLANKS;
        ORDER_DATE_PARMS_HIGH := TO_CHAR(P_ORDER_DATE_HIGH
                                        ,'YYYY/MM/DD');
      ELSE
        LP_ORDER_DATE := '  ';
        ORDER_DATE_PARMS := ALL_RANGE;
        ORDER_DATE_PARMS_LOW := BLANKS;
        ORDER_DATE_PARMS_HIGH := BLANKS;
      END IF;
      IF (P_ORDER_TYPE_LOW IS NOT NULL) AND (P_ORDER_TYPE_HIGH IS NOT NULL) THEN
        LP_ORDER_TYPE := ' AND (OT.transaction_type_id BETWEEN' || ' :P_ORDER_TYPE_LOW AND' || ' :P_ORDER_TYPE_HIGH) ';
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
        ORDER_TYPE_PARMS := 'From ' || SUBSTR(L_ORDER_TYPE_LOW
                                  ,1
                                  ,16) || ' To ' || SUBSTR(L_ORDER_TYPE_HIGH
                                  ,1
                                  ,16);
        ORDER_TYPE_PARMS_LOW := SUBSTR(L_ORDER_TYPE_LOW
                                      ,1
                                      ,16);
        ORDER_TYPE_PARMS_HIGH := SUBSTR(L_ORDER_TYPE_HIGH
                                       ,1
                                       ,16);
      ELSIF (P_ORDER_TYPE_LOW IS NOT NULL) THEN
        LP_ORDER_TYPE := ' AND OT.transaction_type_id >=' || ' :P_ORDER_TYPE_LOW ';
        SELECT
          OEOT.NAME
        INTO L_ORDER_TYPE_LOW
        FROM
          OE_TRANSACTION_TYPES_TL OEOT
        WHERE OEOT.TRANSACTION_TYPE_ID = P_ORDER_TYPE_LOW
          AND OEOT.LANGUAGE = USERENV('LANG');
        ORDER_TYPE_PARMS := 'From ' || SUBSTR(L_ORDER_TYPE_LOW
                                  ,1
                                  ,16) || ' To ' || BLANKS;
        ORDER_TYPE_PARMS_LOW := SUBSTR(L_ORDER_TYPE_LOW
                                      ,1
                                      ,16);
        ORDER_TYPE_PARMS_HIGH := BLANKS;
      ELSIF (P_ORDER_TYPE_HIGH IS NOT NULL) THEN
        LP_ORDER_TYPE := ' AND OT.transaction_type_id <=' || ' :P_ORDER_TYPE_HIGH ';
        SELECT
          OEOT.NAME
        INTO L_ORDER_TYPE_HIGH
        FROM
          OE_TRANSACTION_TYPES_TL OEOT
        WHERE OEOT.TRANSACTION_TYPE_ID = P_ORDER_TYPE_HIGH
          AND OEOT.LANGUAGE = USERENV('LANG');
        ORDER_TYPE_PARMS := 'From ' || BLANKS || 'To ' || SUBSTR(L_ORDER_TYPE_HIGH
                                  ,1
                                  ,16);
        ORDER_TYPE_PARMS_LOW := BLANKS;
        ORDER_TYPE_PARMS_HIGH := SUBSTR(L_ORDER_TYPE_HIGH
                                       ,1
                                       ,16);
      ELSE
        LP_ORDER_TYPE := '  ';
        ORDER_TYPE_PARMS := ALL_RANGE;
        ORDER_TYPE_PARMS_LOW := BLANKS;
        ORDER_TYPE_PARMS_HIGH := BLANKS;
      END IF;
      IF (P_LINE_TYPE_LOW IS NOT NULL) THEN
        SELECT
          OEOT.NAME
        INTO L_LINE_TYPE_LOW
        FROM
          OE_TRANSACTION_TYPES_TL OEOT
        WHERE OEOT.TRANSACTION_TYPE_ID = P_LINE_TYPE_LOW
          AND OEOT.LANGUAGE = USERENV('LANG');
      END IF;
      IF (P_LINE_TYPE_HIGH IS NOT NULL) THEN
        SELECT
          OEOT.NAME
        INTO L_LINE_TYPE_HIGH
        FROM
          OE_TRANSACTION_TYPES_TL OEOT
        WHERE OEOT.TRANSACTION_TYPE_ID = P_LINE_TYPE_HIGH
          AND OEOT.LANGUAGE = USERENV('LANG');
      END IF;
      IF (P_ITEM_LOW IS NOT NULL) AND (P_ITEM_HI IS NOT NULL) THEN
        /*SRW.MESSAGE(1
                   ,':P_ITEM_LOW' || P_ITEM_LOW)*/NULL;
        LINE_TYPE_PARMS := 'From ' || SUBSTR(L_LINE_TYPE_LOW
                                 ,1
                                 ,16) || ' To ' || SUBSTR(L_LINE_TYPE_HIGH
                                 ,1
                                 ,16);
        LINE_TYPE_PARMS_LOW := SUBSTR(L_LINE_TYPE_LOW
                                     ,1
                                     ,16);
        LINE_TYPE_PARMS_HIGH := SUBSTR(L_LINE_TYPE_HIGH
                                      ,1
                                      ,16);
      ELSIF (P_ITEM_LOW IS NOT NULL) THEN
        LINE_TYPE_PARMS := 'From ' || SUBSTR(P_ITEM_LOW
                                 ,1
                                 ,16) || ' To ' || BLANKS;
        LINE_TYPE_PARMS_LOW := SUBSTR(P_ITEM_LOW
                                     ,1
                                     ,16);
        LINE_TYPE_PARMS_HIGH := BLANKS;
      ELSIF (P_ITEM_HI IS NOT NULL) THEN
        LINE_TYPE_PARMS := 'From ' || BLANKS || 'To ' || SUBSTR(P_ITEM_HI
                                 ,1
                                 ,16);
        LINE_TYPE_PARMS_LOW := BLANKS;
        LINE_TYPE_PARMS_HIGH := SUBSTR(P_ITEM_HI
                                      ,1
                                      ,16);
      ELSE
        LINE_TYPE_PARMS := ALL_RANGE;
        LINE_TYPE_PARMS_LOW := BLANKS;
        LINE_TYPE_PARMS_HIGH := BLANKS;
      END IF;
      IF (P_SALESREP_LOW IS NOT NULL) AND (P_SALESREP_HIGH IS NOT NULL) THEN
        LP_SALESREP := ' AND (H.SALESREP_ID BETWEEN' || ' :P_SALESREP_LOW AND' || ' :P_SALESREP_HIGH) ';
        SALESREP_PARMS := 'From ' || SUBSTR(P_SALESREP_LOW
                                ,1
                                ,20) || ' To ' || SUBSTR(P_SALESREP_HIGH
                                ,1
                                ,20);
        SALESREP_PARMS_LOW := SUBSTR(P_SALESREP_LOW
                                    ,1
                                    ,20);
        SALESREP_PARMS_HIGH := SUBSTR(P_SALESREP_HIGH
                                     ,1
                                     ,20);
      ELSIF (P_SALESREP_LOW IS NOT NULL) THEN
        LP_SALESREP := ' AND H.SALESREP_ID >=' || ' :P_SALESREP_LOW ';
        SALESREP_PARMS := 'From ' || SUBSTR(P_SALESREP_LOW
                                ,1
                                ,20) || ' To ' || BLANKS;
        SALESREP_PARMS_LOW := SUBSTR(P_SALESREP_LOW
                                    ,1
                                    ,20);
        SALESREP_PARMS_HIGH := BLANKS;
      ELSIF (P_SALESREP_HIGH IS NOT NULL) THEN
        LP_SALESREP := ' AND H.SALESREP_ID <=' || ' :P_SALESREP_HIGH ';
        SALESREP_PARMS := 'From ' || BLANKS || 'To ' || SUBSTR(P_SALESREP_HIGH
                                ,1
                                ,20);
        SALESREP_PARMS_LOW := BLANKS;
        SALESREP_PARMS_HIGH := SUBSTR(P_SALESREP_HIGH
                                     ,1
                                     ,20);
      ELSE
	LP_SALESREP := '  ';
        SALESREP_PARMS := ALL_RANGE;
        SALESREP_PARMS_LOW := BLANKS;
        SALESREP_PARMS_HIGH := BLANKS;
      END IF;
      IF (P_SORT_BY IS NOT NULL) THEN
        IF (P_SORT_BY = 'CUSTOMER') THEN
          LP_SORT_BY := ' ORG.NAME, ';
        ELSIF (P_SORT_BY = 'ORDER_NUMBER') THEN
          LP_SORT_BY := ' H.ORDER_NUMBER, ';
        ELSIF (P_SORT_BY = 'ITEM') THEN
          LP_SORT_BY := ' SI.SEGMENT1, ';
        END IF;
      ELSE
        LP_SORT_BY := ' H.ORDER_NUMBER, ';
      END IF;
      IF (P_OPEN_FLAG IS NOT NULL) THEN
        IF ((SUBSTR(UPPER(P_OPEN_FLAG)
              ,1
              ,1)) = 'Y') THEN
          LP_OPEN_FLAG := ' AND H.OPEN_FLAG = ''Y''';
        ELSE
          LP_OPEN_FLAG := ' AND H.OPEN_FLAG IS NOT NULL';
        END IF;
      ELSE
        LP_OPEN_FLAG := '  ';
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
            LP_ORDER_CATEGORY := '     ';
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
          LP_LINE_CATEGORY := '  ';
        END IF;
      ELSE
        LP_LINE_CATEGORY := 'and l.line_category_code = ''ORDER'' ';
      END IF;
    END;
    openflag:=P_OPEN_FLAGVALIDTRIGGER();
    RETURN (TRUE);
  END AFTERPFORM;
  FUNCTION TOTAL_SELL_PRICEFORMULA(SELL_PRICE IN NUMBER
                                  ,QUANTITY IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (NVL(SELL_PRICE
              ,0) * NVL(QUANTITY
              ,0));
  END TOTAL_SELL_PRICEFORMULA;
  FUNCTION ORDER_DISCOUNTFORMULA(ORDER_LIST_AMT IN NUMBER
                                ,ORDER_SELL_AMT IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF (ORDER_LIST_AMT = 0) THEN
      RETURN (0);
    ELSE
      RETURN (100 - (ORDER_SELL_AMT / ORDER_LIST_AMT) * 100);
    END IF;
    RETURN NULL;
  END ORDER_DISCOUNTFORMULA;
  FUNCTION TOTAL_LIST_PRICEFORMULA(LIST_PRICE IN NUMBER
                                  ,QUANTITY IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (NVL(LIST_PRICE
              ,0) * NVL(QUANTITY
              ,0));
  END TOTAL_LIST_PRICEFORMULA;
  FUNCTION SORT_BY_MEANINGVALIDTRIGGER RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END SORT_BY_MEANINGVALIDTRIGGER;
  FUNCTION ORDER_TYPE_PARMSVALIDTRIGGER RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END ORDER_TYPE_PARMSVALIDTRIGGER;
  FUNCTION ORDER_NUMBER_PARMSVALIDTRIGGER RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END ORDER_NUMBER_PARMSVALIDTRIGGER;
  FUNCTION SALESREP_PARMSVALIDTRIGGER RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END SALESREP_PARMSVALIDTRIGGER;
  FUNCTION CUSTOMER_PARMSVALIDTRIGGER RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END CUSTOMER_PARMSVALIDTRIGGER;
  FUNCTION ORDER_DATE_PARMSVALIDTRIGGER RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END ORDER_DATE_PARMSVALIDTRIGGER;
  FUNCTION P_SORT_BYVALIDTRIGGER RETURN BOOLEAN IS
  BEGIN
    BEGIN
      RETURN (TRUE);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN (FALSE);
    END;
    RETURN (TRUE);
  END P_SORT_BYVALIDTRIGGER;
  FUNCTION P_OPEN_FLAGVALIDTRIGGER RETURN BOOLEAN IS
  BEGIN
    BEGIN
      IF (P_OPEN_FLAG IS NOT NULL) THEN
        SELECT
          SUBSTR(MEANING
                ,1
                ,5)
        INTO OPEN_FLAG_MEANING
        FROM
          FND_LOOKUPS
        WHERE LOOKUP_TYPE = 'YES_NO'
          AND LOOKUP_CODE = SUBSTR(UPPER(P_OPEN_FLAG)
              ,1
              ,1);
      END IF;
      RETURN (TRUE);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN (FALSE);
    END;
    RETURN (TRUE);
  END P_OPEN_FLAGVALIDTRIGGER;
  FUNCTION P_PRINT_DESCVALIDTRIGGER RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END P_PRINT_DESCVALIDTRIGGER;
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
  FUNCTION TOTAL_ORDER_LIST_PRICEFORMULA(LINE_LIST_PRICE IN NUMBER
                                        ,QUANTITY IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (NVL(LINE_LIST_PRICE
              ,0) * NVL(QUANTITY
              ,0));
  END TOTAL_ORDER_LIST_PRICEFORMULA;
  FUNCTION TOTAL_LINE_SELL_PRICEFORMULA(LINE_SELL_PRICE IN NUMBER
                                       ,QUANTITY IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (NVL(LINE_SELL_PRICE
              ,0) * NVL(QUANTITY
              ,0));
  END TOTAL_LINE_SELL_PRICEFORMULA;
  FUNCTION BEFOREPFORM RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END BEFOREPFORM;
  FUNCTION BETWEENPAGE RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END BETWEENPAGE;
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
  FUNCTION DISCOUNT_AMOUNTFORMULA(DISCOUNT_AMT IN NUMBER) RETURN NUMBER IS
  BEGIN
    /*SRW.REFERENCE(P_MIN_PRECISION)*/NULL;
    RETURN (ROUND(NVL(DISCOUNT_AMT
                    ,0)
                ,TO_NUMBER(NVL(P_MIN_PRECISION,2))));
  END DISCOUNT_AMOUNTFORMULA;
  FUNCTION CF_CHARGE_PERIODICITYFORMULA(CHARGE_PERIODICITY_CODE IN VARCHAR2) RETURN CHAR IS
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
  END CF_CHARGE_PERIODICITYFORMULA;
FUNCTION LIST_PRICE_DISPLAYFORMULA(LIST_PRICE IN NUMBER)
				    RETURN VARCHAR2 IS
BEGIN
/*SRW.REFERENCE(:RP_FUNCTIONAL_CURRENCY);
SRW.REFERENCE(:LIST_PRICE);
SRW.REFERENCE(:LIST_PRICE_DISPLAY);
SRW.REFERENCE(:P_MIN_PRECISION);*/
--BUG 3485175 STARTS
DECLARE
L_STD_PRECISION NUMBER;
L_EXT_PRECISION NUMBER;
L_MIN_ACCT_UNIT NUMBER;
L_LIST_PRICE NUMBER;
BEGIN
/*SRW.REFERENCE(:RP_CURR_PROFILE);
SRW.REFERENCE(:RP_LIST_PRICE);*/
L_LIST_PRICE := LIST_PRICE;
FND_CURRENCY.GET_INFO(RP_FUNCTIONAL_CURRENCY,L_STD_PRECISION,L_EXT_PRECISION,L_MIN_ACCT_UNIT);
IF( FND_PROFILE.VALUE('ONT_UNIT_PRICE_PRECISION_TYPE') = 'EXTENDED' ) THEN
	L_LIST_PRICE := ROUND(L_LIST_PRICE,L_EXT_PRECISION);
ELSE
	L_LIST_PRICE := ROUND(L_LIST_PRICE,L_STD_PRECISION);
END IF;
RP_LIST_PRICE := L_LIST_PRICE;
EXCEPTION
WHEN OTHERS THEN
RP_LIST_PRICE := LIST_PRICE;
END;
--BUG 3485175 END
/*SRW.USER_EXIT('FND FORMAT_CURRENCY
               CODE=":RP_FUNCTIONAL_CURRENCY"
               DISPLAY_WIDTH="13"
               AMOUNT=":RP_LIST_PRICE"
               DISPLAY=":LIST_PRICE_DISPLAY"
               MINIMUM_PRECISION=":P_MIN_PRECISION"');*/
RETURN(LIST_PRICE);
EXCEPTION
WHEN NO_DATA_FOUND THEN
RETURN ('NO RATE');
WHEN OTHERS THEN
RETURN('NO RATE');
END LIST_PRICE_DISPLAYFORMULA;
FUNCTION SELL_PRICE_DISPLAYFORMULA (SELL_PRICE IN NUMBER) RETURN VARCHAR2 IS
BEGIN
/*SRW.REFERENCE(:RP_FUNCTIONAL_CURRENCY);
SRW.REFERENCE(:SELL_PRICE);
SRW.REFERENCE(:SELL_PRICE_DISPLAY);
SRW.REFERENCE(:P_MIN_PRECISION);*/
--BUG 3485175 STARTS
DECLARE
L_STD_PRECISION NUMBER;
L_EXT_PRECISION NUMBER;
L_MIN_ACCT_UNIT NUMBER;
L_SELL_PRICE NUMBER;
BEGIN
--SRW.REFERENCE(:RP_CURR_PROFILE);
--SRW.REFERENCE(:RP_SELL_PRICE);
L_SELL_PRICE := SELL_PRICE;
FND_CURRENCY.GET_INFO(RP_FUNCTIONAL_CURRENCY,L_STD_PRECISION,L_EXT_PRECISION,L_MIN_ACCT_UNIT);
IF( FND_PROFILE.VALUE('ONT_UNIT_PRICE_PRECISION_TYPE') = 'EXTENDED' ) THEN
	L_SELL_PRICE := ROUND(L_SELL_PRICE,L_EXT_PRECISION);
ELSE
	L_SELL_PRICE := ROUND(L_SELL_PRICE,L_STD_PRECISION);
END IF;
RP_SELL_PRICE := L_SELL_PRICE;
EXCEPTION
WHEN OTHERS THEN
 RP_SELL_PRICE := SELL_PRICE;
END;
--BUG 3485175 END
/*SRW.USER_EXIT('FND FORMAT_CURRENCY
               CODE=":RP_FUNCTIONAL_CURRENCY"
               DISPLAY_WIDTH="37"
               AMOUNT=":RP_SELL_PRICE"
               DISPLAY=":SELL_PRICE_DISPLAY"
               MINIMUM_PRECISION=":P_MIN_PRECISION"');*/
RETURN(SELL_PRICE);
EXCEPTION
WHEN NO_DATA_FOUND THEN
RETURN ('NO RATE');
WHEN OTHERS THEN
RETURN('NO RATE');
END;
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
  FUNCTION RP_ITEM_FLEX_ALL_SEG_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_ITEM_FLEX_ALL_SEG;
  END RP_ITEM_FLEX_ALL_SEG_P;
  FUNCTION RP_CURR_PROFILE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_CURR_PROFILE;
  END RP_CURR_PROFILE_P;
  FUNCTION RP_LIST_PRICE_P RETURN NUMBER IS
  BEGIN
    RETURN RP_LIST_PRICE;
  END RP_LIST_PRICE_P;
  FUNCTION RP_SELL_PRICE_P RETURN NUMBER IS
  BEGIN
    RETURN RP_SELL_PRICE;
  END RP_SELL_PRICE_P;
  FUNCTION F_1FORMATTRIGGER RETURN VARCHAR2 IS
  BEGIN
	  IF Oe_Sys_Parameters.Value('RECURRING_CHARGES',mo_global.get_current_org_id())='Y' Then
	  return ('TRUE');
	  ELSE
	  return ('FALSE');
	  END IF;
  END F_1FORMATTRIGGER;



END ONT_OEXPRPRD_XMLP_PKG;


/
