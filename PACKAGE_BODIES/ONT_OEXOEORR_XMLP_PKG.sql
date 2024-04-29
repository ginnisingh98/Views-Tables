--------------------------------------------------------
--  DDL for Package Body ONT_OEXOEORR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_OEXOEORR_XMLP_PKG" AS
/* $Header: OEXOEORRB.pls 120.3 2008/05/05 12:41:22 dwkrishn noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      BEGIN
        P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
	CP_ORDER_DATE_LOW :=to_char(P_ORDER_DATE_LOW,'DD-MON-YY');
	CP_ORDER_DATE_HIGH :=to_char(P_ORDER_DATE_HIGH,'DD-MON-YY');
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
        P_ORG_ID := MO_GLOBAL.GET_CURRENT_ORG_ID;
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
      EXCEPTION
        WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
          /*SRW.MESSAGE(1
                     ,'Failed in before report trigger:MSTK')*/NULL;
      END;
      IF P_ITEM IS NOT NULL THEN
        LP_ITEM_FLEX_ALL_SEG := ' and ' || RP_ITEM_FLEX_ALL_SEG_WHERE;
      END IF;
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
	  l_report_name := substr(l_report_name,1,instr(l_report_name,' (XML)'));
        RP_REPORT_NAME := L_REPORT_NAME;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RP_REPORT_NAME := 'Returns by Reason';
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

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    /*SRW.MESSAGE(99999
               ,'$Header: ONT_OEXOEORR_XMLP_PKG.rdf 120.6 2005/11/09 05:27 maysriva ship
	       $')*/NULL;
    BEGIN
      IF P_ORDER_DATE_LOW IS NOT NULL AND P_ORDER_DATE_HIGH IS NOT NULL THEN
        LP_ORDER_DATE := ' AND  trunc(h.ordered_date) between trunc(:p_order_date_low) and trunc(:p_order_date_high) ';
      ELSIF (P_ORDER_DATE_LOW IS NOT NULL) THEN
        LP_ORDER_DATE := ' and trunc(h.ordered_date) >= trunc(:p_order_date_low)';
      ELSIF (P_ORDER_DATE_HIGH IS NOT NULL) THEN
        LP_ORDER_DATE := ' and trunc(h.ordered_date) <= trunc(:p_order_date_high)';
      END IF;
      IF P_RETURN_REASON IS NOT NULL THEN
        LP_RETURN_REASON := ' and l.return_reason_code = :p_return_reason ';
      END IF;
      IF P_CREDIT_ORDER_TYPE IS NOT NULL THEN
        LP_CREDIT_ORDER_TYPE := ' and otype.transaction_type_id =' || P_CREDIT_ORDER_TYPE;
        SELECT
          OEOT.NAME
        INTO L_ORDER_TYPE
        FROM
          OE_TRANSACTION_TYPES_TL OEOT
        WHERE OEOT.TRANSACTION_TYPE_ID = P_CREDIT_ORDER_TYPE
          AND OEOT.LANGUAGE = USERENV('LANG');
      END IF;
      IF P_CREDIT_ORDER_LINE_TYPE IS NOT NULL THEN
        LP_CREDIT_ORDER_LINE_TYPE := ' and ltype.transaction_type_id =' || P_CREDIT_ORDER_LINE_TYPE;
        SELECT
          OEOT.NAME
        INTO L_LINE_TYPE
        FROM
          OE_TRANSACTION_TYPES_TL OEOT
        WHERE OEOT.TRANSACTION_TYPE_ID = P_CREDIT_ORDER_LINE_TYPE
          AND OEOT.LANGUAGE = USERENV('LANG');
      END IF;
    END;
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION C_SET_LBLFORMULA RETURN VARCHAR2 IS
  BEGIN
    BEGIN
      DECLARE
        L_ORDER_DATE_LOW VARCHAR2(50);
        L_ORDER_DATE_HIGH VARCHAR2(50);
      BEGIN
        IF (P_ORDER_DATE_LOW IS NULL) AND (P_ORDER_DATE_HIGH IS NULL) THEN
          NULL;
        ELSE
          IF P_ORDER_DATE_LOW IS NULL THEN
            L_ORDER_DATE_LOW := '   ';
          ELSE
            L_ORDER_DATE_LOW := TO_CHAR(P_ORDER_DATE_LOW
                                       ,'DD-MON-RRRR');
          END IF;
          IF P_ORDER_DATE_HIGH IS NULL THEN
            L_ORDER_DATE_HIGH := '   ';
          ELSE
            L_ORDER_DATE_HIGH := TO_CHAR(P_ORDER_DATE_HIGH
                                        ,'DD-MON-RRRR');
          END IF;
          RP_ORDER_DATE_RANGE := 'From ' || L_ORDER_DATE_LOW || ' To ' || L_ORDER_DATE_HIGH;
        END IF;
      END;
      IF P_RETURN_REASON IS NOT NULL THEN
        DECLARE
          MEANING VARCHAR2(80);
        BEGIN
          SELECT
            MEANING
          INTO MEANING
          FROM
            AR_LOOKUPS
          WHERE LOOKUP_TYPE = 'CREDIT_MEMO_REASON'
            AND LOOKUP_CODE = P_RETURN_REASON;
          RP_RETURN_REASON := MEANING;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            RP_RETURN_REASON := P_RETURN_REASON;
        END;
      END IF;
      IF P_CREDIT_ORDER_TYPE IS NOT NULL THEN
        RP_CREDIT_ORDER_TYPE := L_ORDER_TYPE;
      END IF;
      IF P_CREDIT_ORDER_LINE_TYPE IS NOT NULL THEN
        RP_CREDIT_LINE_TYPE := L_LINE_TYPE;
      END IF;
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

  FUNCTION C_VALUEFORMULA(UNIT_SELLING_PRICE IN NUMBER
                         ,FULFILLED_QTY IN NUMBER) RETURN NUMBER IS
  BEGIN
    /*SRW.REFERENCE(UNIT_SELLING_PRICE)*/NULL;
    /*SRW.REFERENCE(FULFILLED_QTY)*/NULL;
    RP_DATA_FOUND := 'X';
    RETURN (NVL(FULFILLED_QTY
              ,0) * NVL(UNIT_SELLING_PRICE
              ,0));
  END C_VALUEFORMULA;

  FUNCTION C_MASTER_ORGFORMULA RETURN CHAR IS
    V_MASTER_ORG VARCHAR2(20);
  BEGIN
    V_MASTER_ORG := NVL(OE_SYS_PARAMETERS.VALUE('MASTER_ORGANIZATION_ID'
                                               ,MO_GLOBAL.GET_CURRENT_ORG_ID)
                       ,0);
    RETURN V_MASTER_ORG;
  END C_MASTER_ORGFORMULA;

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

  FUNCTION RP_ITEM_FLEX_CODE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_ITEM_FLEX_CODE;
  END RP_ITEM_FLEX_CODE_P;

  FUNCTION RP_ITEM_FLEX_APROMPT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_ITEM_FLEX_APROMPT;
  END RP_ITEM_FLEX_APROMPT_P;

  FUNCTION RP_ORDER_DATE_RANGE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_ORDER_DATE_RANGE;
  END RP_ORDER_DATE_RANGE_P;

  FUNCTION RP_ORDER_BY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_ORDER_BY;
  END RP_ORDER_BY_P;

  FUNCTION RP_RETURN_REASON_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_RETURN_REASON;
  END RP_RETURN_REASON_P;

  FUNCTION RP_FLEX_OR_DESC_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_FLEX_OR_DESC;
  END RP_FLEX_OR_DESC_P;

  FUNCTION RP_ITEM_FLEX_ALL_SEG_WHERE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_ITEM_FLEX_ALL_SEG_WHERE;
  END RP_ITEM_FLEX_ALL_SEG_WHERE_P;

  FUNCTION RP_ITEM_ORDER_BY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_ITEM_ORDER_BY;
  END RP_ITEM_ORDER_BY_P;

  FUNCTION RP_ITEM_FLEX_ALL_SEG_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_ITEM_FLEX_ALL_SEG;
  END RP_ITEM_FLEX_ALL_SEG_P;

  FUNCTION RP_CREDIT_ORDER_TYPE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_CREDIT_ORDER_TYPE;
  END RP_CREDIT_ORDER_TYPE_P;

  FUNCTION RP_CREDIT_LINE_TYPE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_CREDIT_LINE_TYPE;
  END RP_CREDIT_LINE_TYPE_P;

  FUNCTION RP_DUMMY_ITEM_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_DUMMY_ITEM;
  END RP_DUMMY_ITEM_P;

FUNCTION ITEM_DSPFORMULA(ITEM_IDENTIFIER_TYPE IN VARCHAR2,INVENTORY_ITEM_ID1 IN NUMBER,ORDERED_ITEM_ID IN NUMBER,ORDERED_ITEM IN VARCHAR2,C_ORGANIZATION_ID IN VARCHAR2,C_INVENTORY_ITEM_ID IN VARCHAR2)  return Char is
v_item varchar2(2000);
v_description varchar2(500);
begin
  if (item_identifier_type is null or item_identifier_type = 'INT')
       or (p_print_description in ('I','D','F')) then
    select sitems.concatenated_segments item,
    	   sitems.description description
    into   v_item,v_description
    from   mtl_system_items_vl sitems
--    where  sitems.customer_order_enabled_flag = 'Y'
--    and    sitems.bom_item_type in (1,4)
    where    nvl(sitems.organization_id,0) = NVL(OE_SYS_PARAMETERS.VALUE('MASTER_ORGANIZATION_ID',MO_GLOBAL.GET_CURRENT_ORG_ID) ,0)
    and    sitems.inventory_item_id = inventory_item_id1;

    v_item := fnd_flex_xml_publisher_apis.process_kff_combination_1('Item_dsp', 'INV', p_item_flex_code,p_item_structure_num, C_ORGANIZATION_ID, C_INVENTORY_ITEM_ID, 'ALL', 'Y', 'VALUE') ;
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
    and    nvl(sitems.organization_id,0) = NVL(OE_SYS_PARAMETERS.VALUE('MASTER_ORGANIZATION_ID',MO_GLOBAL.GET_CURRENT_ORG_ID) ,0)
    and    sitems.inventory_item_id = inventory_item_id1;
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
    and    nvl(sitems.organization_id,0) = NVL(OE_SYS_PARAMETERS.VALUE('MASTER_ORGANIZATION_ID',MO_GLOBAL.GET_CURRENT_ORG_ID) ,0)
    and    sitems.inventory_item_id = inventory_item_id1
  --Bug 3433353 Begin
    and    items.org_independent_flag = 'N'
    and    items.organization_id = NVL(OE_SYS_PARAMETERS.VALUE('MASTER_ORGANIZATION_ID',MO_GLOBAL.GET_CURRENT_ORG_ID) ,0);
--    and    sitems.customer_order_enabled_flag = 'Y'
--    and    sitems.bom_item_type in (1,4)
   Exception When NO_DATA_FOUND Then
   Select items.cross_reference item, nvl(items.description,sitems.description) description
   into v_item,v_description
   from mtl_cross_reference_types xtypes,
   mtl_cross_references items,
   mtl_system_items_vl sitems
   where xtypes.cross_reference_type =
   items.cross_reference_type
   and items.inventory_item_id = sitems.inventory_item_id
   and items.cross_reference = ordered_item
   and items.cross_reference_type = item_identifier_type
   and nvl(sitems.organization_id,0) = NVL(OE_SYS_PARAMETERS.VALUE('MASTER_ORGANIZATION_ID',MO_GLOBAL.GET_CURRENT_ORG_ID) ,0)
   and sitems.inventory_item_id = inventory_item_id1
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


END ONT_OEXOEORR_XMLP_PKG;


/
