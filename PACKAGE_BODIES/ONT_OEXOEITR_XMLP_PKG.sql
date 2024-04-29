--------------------------------------------------------
--  DDL for Package Body ONT_OEXOEITR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_OEXOEITR_XMLP_PKG" AS
/* $Header: OEXOEITRB.pls 120.2 2008/05/05 09:04:13 dwkrishn noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      BEGIN
        P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
        P_ORDER_DATE_LOW_T := to_char(P_ORDER_DATE_LOW,'DD-MON-YY');
        P_ORDER_DATE_HIGH_T := TO_CHAR(P_ORDER_DATE_HIGH,'DD-MON-YY');

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
        IF P_ITEM_LOW IS NOT NULL OR P_ITEM_HI IS NOT NULL THEN
          LP_ITEM := ' and ' || LP_ITEM;
        ELSE
          LP_ITEM := ' ';
        END IF;
      EXCEPTION
        WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
          /*SRW.MESSAGE(1
                     ,'Failed in before report trigger:MSTK')*/NULL;
      END;
      DECLARE
        L_MEANING VARCHAR2(80);
        L_LOOKUP_TYPE VARCHAR2(80);
      BEGIN
        L_LOOKUP_TYPE := 'ITEM_DISPLAY_CODE';
        SELECT
          MEANING
        INTO L_MEANING
        FROM
          OE_LOOKUPS
        WHERE LOOKUP_TYPE = L_LOOKUP_TYPE
          AND LOOKUP_CODE = SUBSTR(UPPER(P_PRINT_DESCRIPTION)
              ,1
              ,1);
        RP_PRINT_DESCRIPTION := L_MEANING;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RP_PRINT_DESCRIPTION := 'Internal Item Description';
        WHEN OTHERS THEN
          /*SRW.MESSAGE(2000
                     ,'Failed in BEFORE REPORT trigger. Get Print Description')*/NULL;
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
          RP_REPORT_NAME := 'Orders by Item';
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
    IF P_ORDER_NUM_LOW IS NOT NULL AND P_ORDER_NUM_HIGH IS NOT NULL THEN
      LP_ORDER_NUM := ' AND  h.order_number  between to_number(:p_order_num_low) and to_number(:p_order_num_high)  ';
    ELSIF (P_ORDER_NUM_LOW IS NOT NULL) THEN
      LP_ORDER_NUM := ' and h.order_number >= to_number(:p_order_num_low) ';
    ELSIF (P_ORDER_NUM_HIGH IS NOT NULL) THEN
      LP_ORDER_NUM := ' and h.order_number <= to_number(:p_order_num_high) ';
    ELSE
      LP_ORDER_NUM := ' ';
    END IF;
    IF P_ORDER_TYPE_LOW IS NOT NULL AND P_ORDER_TYPE_HIGH IS NOT NULL THEN
      LP_ORDER_TYPE := 'and ot.transaction_type_id between :P_order_type_low and :P_order_type_high ';
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
    ELSE
      IF P_ORDER_TYPE_LOW IS NULL AND P_ORDER_TYPE_HIGH IS NOT NULL THEN
        LP_ORDER_TYPE := 'and ot.transaction_type_id <= :P_order_type_high ';
        SELECT
          OEOT.NAME
        INTO L_ORDER_TYPE_HIGH
        FROM
          OE_TRANSACTION_TYPES_TL OEOT
        WHERE OEOT.TRANSACTION_TYPE_ID = P_ORDER_TYPE_HIGH
          AND OEOT.LANGUAGE = USERENV('LANG');
      ELSE
        IF P_ORDER_TYPE_LOW IS NOT NULL AND P_ORDER_TYPE_HIGH IS NULL THEN
          LP_ORDER_TYPE := 'and ot.transaction_type_id >= :P_order_type_low ';
          SELECT
            OEOT.NAME
          INTO L_ORDER_TYPE_LOW
          FROM
            OE_TRANSACTION_TYPES_TL OEOT
          WHERE OEOT.TRANSACTION_TYPE_ID = P_ORDER_TYPE_LOW
            AND OEOT.LANGUAGE = USERENV('LANG');
        ELSE
          LP_ORDER_TYPE := '   ';
        END IF;
      END IF;
    END IF;
    IF P_ORDER_DATE_LOW IS NOT NULL AND P_ORDER_DATE_HIGH IS NOT NULL THEN
      LP_ORDER_DATE := ' AND h.ordered_date >= :p_order_date_low and h.ordered_date < :p_order_date_high+1 ';
    ELSIF (P_ORDER_DATE_LOW IS NOT NULL) THEN
      LP_ORDER_DATE := ' and h.ordered_date >= :p_order_date_low';
    ELSIF (P_ORDER_DATE_HIGH IS NOT NULL) THEN
      LP_ORDER_DATE := 'and h.ordered_date < :p_order_date_high+1 ';
    ELSE
      LP_ORDER_DATE := ' ';
    END IF;
    IF P_CUSTOMER_NAME_LOW IS NOT NULL AND P_CUSTOMER_NAME_HIGH IS NOT NULL THEN
      IF P_CUSTOMER_NAME_LOW = P_CUSTOMER_NAME_HIGH THEN
        LP_CUSTOMER_NAME := ' AND party.party_name = :p_customer_name_low ';
      ELSE
        LP_CUSTOMER_NAME := ' AND party.party_name between :p_customer_name_low and :p_customer_name_high ';
      END IF;
    ELSIF (P_CUSTOMER_NAME_LOW IS NOT NULL) THEN
      LP_CUSTOMER_NAME := ' and party.party_name >= :p_customer_name_low ';
    ELSIF (P_CUSTOMER_NAME_HIGH IS NOT NULL) THEN
      LP_CUSTOMER_NAME := ' and party.party_name <= :p_customer_name_high ';
    ELSE
      LP_CUSTOMER_NAME := ' ';
    END IF;
    IF (P_OPENONLY IS NOT NULL) THEN
      IF ((SUBSTR(UPPER(P_OPENONLY)
            ,1
            ,1)) = 'Y') THEN
        LP_OPENONLY := ' AND NVL(H.OPEN_FLAG, ''N'') = ''Y''';
      ELSE
        LP_OPENONLY := ' ';
      END IF;
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
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION C_SET_LBLFORMULA RETURN VARCHAR2 IS
  BEGIN
    BEGIN
      IF P_CUSTOMER_NAME_LOW IS NOT NULL OR P_CUSTOMER_NAME_HIGH IS NOT NULL THEN
        RP_CUSTOMER_RANGE := 'From ' || NVL(SUBSTR(P_CUSTOMER_NAME_LOW
                                       ,1
                                       ,16)
                                ,'     ') || ' To ' || NVL(SUBSTR(P_CUSTOMER_NAME_HIGH
                                       ,1
                                       ,16)
                                ,'     ');
      END IF;
      IF P_ORDER_DATE_LOW IS NOT NULL OR P_ORDER_DATE_HIGH IS NOT NULL THEN
        RP_ORDER_DATE_RANGE := 'From ' || NVL(TO_CHAR(P_ORDER_DATE_LOW
                                          ,'DD-MON-RRRR')
                                  ,'     ') || ' To ' || NVL(TO_CHAR(P_ORDER_DATE_HIGH
                                          ,'DD-MON-RRRR')
                                  ,'     ');
      END IF;
      IF P_ORDER_NUM_LOW IS NOT NULL OR P_ORDER_NUM_HIGH IS NOT NULL THEN
        RP_ORDER_RANGE := 'From ' || NVL(P_ORDER_NUM_LOW
                             ,'     ') || ' To ' || NVL(P_ORDER_NUM_HIGH
                             ,'     ');
      END IF;
      IF P_ITEM_LOW IS NOT NULL OR P_ITEM_HI IS NOT NULL THEN
        RP_ITEM_RANGE := 'From ' || NVL(P_ITEM_LOW
                            ,'       ') || ' To ' || NVL(P_ITEM_HI
                            ,'        ');
      END IF;
      BEGIN
        DECLARE
          MEANING VARCHAR2(80);
        BEGIN
          SELECT
            MEANING
          INTO MEANING
          FROM
            FND_LOOKUPS
          WHERE LOOKUP_TYPE = 'YES_NO'
            AND LOOKUP_CODE = P_OPENONLY;
          RP_OPENONLY := MEANING;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            RP_OPENONLY := P_OPENONLY;
        END;
      END;
      RETURN (1);
    END;
    RETURN NULL;
  END C_SET_LBLFORMULA;

  FUNCTION RP_ORDER_CATEGORYFORMULA RETURN VARCHAR2 IS
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
    RETURN NULL;
  END RP_ORDER_CATEGORYFORMULA;

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
    RETURN NULL;
  END RP_LINE_CATEGORYFORMULA;

  FUNCTION CF_UNIT1FORMULA(UNIT IN VARCHAR2) RETURN CHAR IS
  BEGIN
    CP_UNIT1 := UNIT;
    RETURN 1;
  END CF_UNIT1FORMULA;

  FUNCTION CF_UNIT2FORMULA(UNIT2 IN VARCHAR2) RETURN CHAR IS
  BEGIN
    CP_UNIT2 := UNIT2;
    RETURN 1;
  END CF_UNIT2FORMULA;

  FUNCTION C_MASTER_ORGFORMULA RETURN NUMBER IS
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

  FUNCTION CF_CHARGE_PERIODICITYFORMULA(CHARGE_PERIODICITY_CODE IN VARCHAR2) RETURN VARCHAR2 IS
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

  FUNCTION RP_CUSTOMER_RANGE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_CUSTOMER_RANGE;
  END RP_CUSTOMER_RANGE_P;

  FUNCTION RP_TYPE_RANGE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_TYPE_RANGE;
  END RP_TYPE_RANGE_P;

  FUNCTION RP_ORDER_RANGE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_ORDER_RANGE;
  END RP_ORDER_RANGE_P;

  FUNCTION RP_ORDER_DATE_RANGE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_ORDER_DATE_RANGE;
  END RP_ORDER_DATE_RANGE_P;

  FUNCTION RP_ORDER_BY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_ORDER_BY;
  END RP_ORDER_BY_P;

  FUNCTION RP_OPENONLY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_OPENONLY;
  END RP_OPENONLY_P;

  FUNCTION RP_ITEM_RANGE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_ITEM_RANGE;
  END RP_ITEM_RANGE_P;

  FUNCTION RP_ITEM_FLEX_ALL_SEG_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_ITEM_FLEX_ALL_SEG;
  END RP_ITEM_FLEX_ALL_SEG_P;

  FUNCTION RP_PRINT_DESCRIPTION_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_PRINT_DESCRIPTION;
  END RP_PRINT_DESCRIPTION_P;

  FUNCTION CP_UNIT1_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_UNIT1;
  END CP_UNIT1_P;

  FUNCTION CP_UNIT2_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_UNIT2;
  END CP_UNIT2_P;
  FUNCTION F_1FORMATTRIGGER RETURN VARCHAR2 IS
  BEGIN
  IF OE_SYS_PARAMETERS.VALUE('RECURRING_CHARGES',MO_GLOBAL.GET_CURRENT_ORG_ID()) ='Y' THEN
  RETURN ('TRUE');
  ELSE
   RETURN ('FALSE');
  END IF;
  END F_1FORMATTRIGGER;

function Item_dspFormula(
ITEM_IDENTIFIER_TYPE IN VARCHAR2,
C_MASTER_ORG IN NUMBER,
INVENTORY_ITEM_ID_T IN NUMBER,
ORDERED_ITEM_ID IN NUMBER,
ORDERED_ITEM IN VARCHAR2,
ORGANIZATION_ID_T in number,
INVENTORY_ITEM_ID_T1 in number
)

return Char is
v_item varchar2(2000);
v_description varchar2(500);
begin

  if (item_identifier_type is null or item_identifier_type = 'INT')
       or (P_PRINT_DESCRIPTION in ('I','D','F')) then
    select sitems.description description
    into   v_description
    from   mtl_system_items_vl sitems
--    where  sitems.customer_order_enabled_flag = 'Y'
--    and    sitems.bom_item_type in (1,4)
    where    nvl(sitems.organization_id,0) = c_master_org
    and    sitems.inventory_item_id = inventory_item_id_T;
        /* srw.reference (:item_flex);
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
    v_item := fnd_flex_xml_publisher_apis.process_kff_combination_1('Item_dsp', 'INV', P_item_flex_code, P_ITEM_STRUCTURE_NUM, ORGANIZATION_ID_T, INVENTORY_ITEM_ID_T1, 'ALL', 'Y', 'VALUE');
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
    and    sitems.inventory_item_id = inventory_item_id_T;
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
    and    sitems.inventory_item_id = inventory_item_id_T
    -- Bug 3433353 Start
    and    items.org_independent_flag = 'N'
    and    items.organization_id = c_master_org;
--    and    sitems.customer_order_enabled_flag = 'Y'
--    and    sitems.bom_item_type in (1,4)
     Exception When NO_DATA_FOUND Then
     Select items.cross_reference item,
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
     and sitems.inventory_item_id = inventory_item_id_T
     and items.org_independent_flag = 'Y';
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
Exception
   When Others Then
        return('Item Not Found');
end;


END ONT_OEXOEITR_XMLP_PKG;


/
