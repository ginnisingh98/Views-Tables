--------------------------------------------------------
--  DDL for Package Body ONT_OEXIODIS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_OEXIODIS_XMLP_PKG" AS
/* $Header: OEXIODISB.pls 120.3 2008/05/05 10:13:23 dwkrishn noship $ */
  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    BEGIN
      IF P_OPEN_ORDER_ONLY	 IS NOT NULL THEN
        LP_OPEN_ORDER_ONLY := 'and oeh.open_flag = ''Y'' ';
      ELSE
        LP_OPEN_ORDER_ONLY := ' ';
      END IF;
      IF P_ORDER_NUM_LOW IS NOT NULL THEN
        LP_ORDER_NUM_LOW := 'and oeh.order_number >= :p_order_num_low ';
      ELSE
        LP_ORDER_NUM_LOW := ' ';
      END IF;
      IF P_ORDER_NUM_HIGH IS NOT NULL THEN
        LP_ORDER_NUM_HIGH := 'and oeh.order_number <= :p_order_num_high ';
      ELSE
        LP_ORDER_NUM_HIGH := ' ';
      END IF;
      BEGIN
      IF P_ORDER_DATE_LOW IS NOT NULL THEN
        LP_ORDER_DATE_LOW := 'and oeh.ordered_date >= :p_order_date_low ';
        SELECT
          OEOT.NAME
        INTO L_ORDER_TYPE_LOW
        FROM
          OE_TRANSACTION_TYPES_TL OEOT
        WHERE OEOT.TRANSACTION_TYPE_ID = P_ORDER_TYPE_LOW
          AND OEOT.LANGUAGE = USERENV('LANG');
      ELSE
        LP_ORDER_DATE_LOW := ' ';
      END IF;
      EXCEPTION WHEN others then
	 NULL;
      END;
      BEGIN
      IF P_ORDER_DATE_HIGH IS NOT NULL THEN
        LP_ORDER_DATE_HIGH := 'and oeh.ordered_date < :p_order_date_high+1 ';
        SELECT
          OEOT.NAME
        INTO L_ORDER_TYPE_HIGH
        FROM
          OE_TRANSACTION_TYPES_TL OEOT
        WHERE OEOT.TRANSACTION_TYPE_ID = P_ORDER_TYPE_HIGH
          AND OEOT.LANGUAGE = USERENV('LANG');
      ELSE
        LP_ORDER_DATE_HIGH := ' ';
      END IF;
      EXCEPTION WHEN others then
	 NULL;
      END;
      BEGIN
      IF P_ORDER_TYPE_LOW IS NOT NULL THEN
        LP_ORDER_TYPE_LOW := 'and oet.transaction_type_id >= ''' || P_ORDER_TYPE_LOW || '''';
        SELECT
          OEOT.NAME
        INTO L_ORDER_TYPE_LOW
        FROM
          OE_TRANSACTION_TYPES_TL OEOT
        WHERE OEOT.TRANSACTION_TYPE_ID = P_ORDER_TYPE_LOW
          AND OEOT.LANGUAGE = USERENV('LANG');
      ELSE
        LP_ORDER_TYPE_LOW := ' ';
      END IF;
      EXCEPTION WHEN others then
	 NULL;
      END;
      BEGIN
      IF P_ORDER_TYPE_HIGH IS NOT NULL THEN
        LP_ORDER_TYPE_HIGH := 'and oet.transaction_type_id >= ''' || P_ORDER_TYPE_HIGH || '''';
        SELECT
          OEOT.NAME
        INTO L_ORDER_TYPE_HIGH
        FROM
          OE_TRANSACTION_TYPES_TL OEOT
        WHERE OEOT.TRANSACTION_TYPE_ID = P_ORDER_TYPE_HIGH
          AND OEOT.LANGUAGE = USERENV('LANG');
      ELSE
        LP_ORDER_TYPE_HIGH := ' ';
      END IF;
      EXCEPTION WHEN others then
	 NULL;
      END;
      IF P_REQUISITION_NUM_LOW IS NOT NULL THEN
        LP_REQUISITION_NUM_LOW := 'and porh.segment1 >= to_char(:p_requisition_num_low) ';
      ELSE
        LP_REQUISITION_NUM_LOW := ' ';
      END IF;
      IF P_REQUISITION_NUM_HIGH IS NOT NULL THEN
        LP_REQUISITION_NUM_HIGH := 'and porh.segment1 <= to_char(:p_requisition_num_high) ';
      ELSE
        LP_REQUISITION_NUM_HIGH := ' ';
      END IF;
    END;

    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      BEGIN
        P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
	CP_ORDER_DATE_LOW := TO_CHAR(P_ORDER_DATE_LOW,'YYYY/MM/DD HH24:MI:SS');
	CP_ORDER_DATE_HIGH :=TO_CHAR(P_ORDER_DATE_HIGH,'YYYY/MM/DD HH24:MI:SS');
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
        L_COMPANY_NAME VARCHAR2(30);
      BEGIN
        SELECT
          NAME
        INTO L_COMPANY_NAME
        FROM
          GL_SETS_OF_BOOKS
        WHERE SET_OF_BOOKS_ID = P_SOB_ID;
        RP_COMPANY_NAME := L_COMPANY_NAME;
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
          RP_REPORT_NAME := 'Internal Order and Purchasing Requisition Discrepancy Report';
      END;
      BEGIN
        /*SRW.REFERENCE(P_ITEM_FLEX_CODE)*/NULL;
        /*SRW.REFERENCE(P_ITEM_STRUCTURE_NUM)*/NULL;
        /*SRW.REFERENCE(P_ITEM_LOW)*/NULL;
        /*SRW.REFERENCE(P_ITEM_HIGH)*/NULL;
        IF P_ITEM_LOW IS NOT NULL OR P_ITEM_HIGH IS NOT NULL THEN
          LP_ITEM := ' and ' || LP_ITEM;
        END IF;
      EXCEPTION
        WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
          /*SRW.MESSAGE(2000
                     ,'Failed in BEFORE REPORT trigger. FND FLEXSQL USER_EXIT')*/NULL;
      END;
      BEGIN
        RP_DUMMY_ITEM := NVL(OE_SYS_PARAMETERS.VALUE('MASTER_ORGANIZATION_ID'
                                                    ,MO_GLOBAL.GET_CURRENT_ORG_ID)
                            ,0);
      EXCEPTION
        WHEN OTHERS THEN
          /*SRW.MESSAGE(1000
                     ,'Error in fetching Master Organization Id for the session')*/NULL;
          RP_DUMMY_ITEM := 0;
      END;
    END;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION C_BUILD_LBLFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      L_DATE VARCHAR2(11);
      H_DATE VARCHAR2(11);
    BEGIN
      IF P_ORDER_NUM_LOW IS NOT NULL OR P_ORDER_NUM_HIGH IS NOT NULL THEN
        RP_ORDER_RANGE := 'From ' || NVL(P_ORDER_NUM_LOW
                             ,'     ') || ' To ' || NVL(P_ORDER_NUM_HIGH
                             ,'     ');
      END IF;
      L_DATE := '           ';
      H_DATE := '           ';
      IF P_ORDER_DATE_LOW IS NOT NULL THEN
        L_DATE := TO_CHAR(P_ORDER_DATE_LOW);
      END IF;
      IF P_ORDER_DATE_HIGH IS NOT NULL THEN
        H_DATE := TO_CHAR(P_ORDER_DATE_HIGH);
      END IF;
      IF P_ORDER_DATE_LOW IS NOT NULL OR P_ORDER_DATE_HIGH IS NOT NULL THEN
        RP_ORDER_DATE_RANGE := 'From ' || L_DATE || ' To ' || H_DATE;
      END IF;
      IF P_REQUISITION_NUM_LOW IS NOT NULL OR P_REQUISITION_NUM_HIGH IS NOT NULL THEN
        RP_REQUISITION_RANGE := 'From ' || P_REQUISITION_NUM_LOW || ' To ' || P_REQUISITION_NUM_HIGH;
      END IF;
      IF P_ORDER_TYPE_LOW IS NOT NULL OR P_ORDER_TYPE_HIGH IS NOT NULL THEN
        RP_ORDER_TYPE_RANGE := 'From ' || L_ORDER_TYPE_LOW || ' To ' || L_ORDER_TYPE_HIGH;
      END IF;
      IF P_ITEM_LOW IS NOT NULL OR P_ITEM_HIGH IS NOT NULL THEN
        RP_ITEM_RANGE := 'From ' || P_ITEM_LOW || ' To ' || P_ITEM_HIGH;
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
        RP_ITEM_DISPLAY_METHOD := ITEM_DISPLAY_MEANING;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RP_ITEM_DISPLAY_METHOD := NULL;
      END;
      DECLARE
        OPEN_ORDER_ONLY VARCHAR2(80);
      BEGIN
        SELECT
          MEANING
        INTO OPEN_ORDER_ONLY
        FROM
          OE_LOOKUPS
        WHERE LOOKUP_TYPE = 'YES_NO'
          AND LOOKUP_CODE = P_OPEN_ORDER_ONLY;
        RP_OPEN_ORDER_ONLY := OPEN_ORDER_ONLY;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RP_OPEN_ORDER_ONLY := NULL;
      END;
      DECLARE
        ORDER_BY VARCHAR2(80);
      BEGIN
        SELECT
          MEANING
        INTO ORDER_BY
        FROM
          OE_LOOKUPS
        WHERE LOOKUP_TYPE = 'OEXIODIS ORDER BY'
          AND LOOKUP_CODE = P_ORDER_BY;
        RP_ORDER_BY := ORDER_BY;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RP_ORDER_BY := P_ORDER_BY;
      END;
      RETURN (1);
    END;
    RETURN NULL;
  END C_BUILD_LBLFORMULA;

  FUNCTION CF_SO_HOLDFORMULA(OM_LINE_ID IN NUMBER
                            ,OM_HEADER_ID IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    /*SRW.REFERENCE(OM_LINE_ID)*/NULL;
    /*SRW.REFERENCE(OM_HEADER_ID)*/NULL;
    DECLARE
      L_NUM_HOLD NUMBER;
      L_MEANING VARCHAR2(80);
    BEGIN
      SELECT
        COUNT(ORDER_HOLD_ID)
      INTO L_NUM_HOLD
      FROM
        OE_ORDER_HOLDS_ALL
      WHERE HEADER_ID = OM_HEADER_ID
        AND HOLD_RELEASE_ID is null
        AND ( LINE_ID = OM_LINE_ID
      OR LINE_ID is null );
      IF (L_NUM_HOLD = 0) THEN
        SELECT
          MEANING
        INTO L_MEANING
        FROM
          OE_LOOKUPS
        WHERE LOOKUP_TYPE = 'YES_NO'
          AND LOOKUP_CODE = 'N';
      ELSE
        SELECT
          MEANING
        INTO L_MEANING
        FROM
          OE_LOOKUPS
        WHERE LOOKUP_TYPE = 'YES_NO'
          AND LOOKUP_CODE = 'Y';
      END IF;
      RETURN (L_MEANING);
    END;
    RETURN NULL;
  END CF_SO_HOLDFORMULA;

  FUNCTION CF_PO_ITEM_DISPLAYFORMULA(CF_ITEM_FLEX IN VARCHAR2
                                    ,RQ_ITEM_DESCRIPTION IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    /*SRW.REFERENCE(P_PRINT_DESCRIPTION)*/NULL;
    /*SRW.REFERENCE(CF_ITEM_FLEX)*/NULL;
    RP_DATA_FOUND := 'X';
    IF UPPER(P_PRINT_DESCRIPTION) in ('F','O') THEN
      RETURN (CF_ITEM_FLEX);
    ELSIF UPPER(P_PRINT_DESCRIPTION) in ('D','P') THEN
      RETURN (RQ_ITEM_DESCRIPTION);
    ELSIF UPPER(P_PRINT_DESCRIPTION) in ('C','I') THEN
      RETURN (CF_ITEM_FLEX || RQ_ITEM_DESCRIPTION);
    END IF;
    RETURN NULL;
  END CF_PO_ITEM_DISPLAYFORMULA;

  FUNCTION CF_ORDER_BYFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      ORDER_BY VARCHAR2(80);
    BEGIN
      IF P_ORDER_BY = 'ORDER_NUM' THEN
        ORDER_BY := ' om_order_number, om_order_date ';
      ELSIF P_ORDER_BY = 'ORDER_TYPE' THEN
        ORDER_BY := ' om_order_type,om_order_number ';
      ELSIF P_ORDER_BY = 'ORDER_DATE' THEN
        ORDER_BY := ' om_order_date, om_order_number ';
      ELSE
        ORDER_BY := ' om_order_date ';
      END IF;
      RETURN (ORDER_BY);
    END;
    RETURN NULL;
  END CF_ORDER_BYFORMULA;

  FUNCTION P_CUSTOMER_NUMBER_LOWVALIDTRIG RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END P_CUSTOMER_NUMBER_LOWVALIDTRIG;

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

  FUNCTION RP_REPORT_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_REPORT_NAME;
  END RP_REPORT_NAME_P;

  FUNCTION RP_COMPANY_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_COMPANY_NAME;
  END RP_COMPANY_NAME_P;

  FUNCTION RP_SUB_TITLE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_SUB_TITLE;
  END RP_SUB_TITLE_P;

  FUNCTION RP_ORDER_RANGE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_ORDER_RANGE;
  END RP_ORDER_RANGE_P;

  FUNCTION RP_REQUISITION_RANGE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_REQUISITION_RANGE;
  END RP_REQUISITION_RANGE_P;

  FUNCTION RP_ORDER_DATE_RANGE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_ORDER_DATE_RANGE;
  END RP_ORDER_DATE_RANGE_P;

  FUNCTION RP_ITEM_DISPLAY_METHOD_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_ITEM_DISPLAY_METHOD;
  END RP_ITEM_DISPLAY_METHOD_P;

  FUNCTION RP_OPEN_ORDER_ONLY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_OPEN_ORDER_ONLY;
  END RP_OPEN_ORDER_ONLY_P;

  FUNCTION RP_ORDER_BY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_ORDER_BY;
  END RP_ORDER_BY_P;

  FUNCTION RP_ITEM_FLEX2_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_ITEM_FLEX2;
  END RP_ITEM_FLEX2_P;

  FUNCTION RP_ITEM_FLEX_ALL_SEG_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_ITEM_FLEX_ALL_SEG;
  END RP_ITEM_FLEX_ALL_SEG_P;

  FUNCTION RP_ITEM_RANGE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_ITEM_RANGE;
  END RP_ITEM_RANGE_P;

  FUNCTION RP_DATA_FOUND_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_DATA_FOUND;
  END RP_DATA_FOUND_P;

  FUNCTION RP_ORDER_TYPE_RANGE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_ORDER_TYPE_RANGE;
  END RP_ORDER_TYPE_RANGE_P;

  FUNCTION RP_DUMMY_ITEM_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_DUMMY_ITEM;
  END RP_DUMMY_ITEM_P;

  function item_dspFormula(item_identifier_type in VARCHAR2,ordered_item_id in number,ordered_item in varchar2,ORGANIZATION_ID in number, INVENTORY_ITEM_ID in number) return Char is
v_item varchar2(2000);
v_description varchar2(500);
begin
  if (item_identifier_type is null or item_identifier_type = 'INT')
       or (p_print_description in ('I','D','F')) then

    v_item := fnd_flex_xml_publisher_apis.process_kff_combination_1('Item_dsp', 'INV', p_item_flex_code,p_item_structure_num ,item_dspFormula.ORGANIZATION_ID,item_dspFormula.INVENTORY_ITEM_ID, 'ALL', 'Y',
'VALUE');

    select sitems.description description
    into   v_description
    from   mtl_system_items_vl sitems
    --where  sitems.customer_order_enabled_flag = 'Y'
    where    sitems.bom_item_type in (1,4)
    and    nvl(sitems.organization_id,0) = RP_DUMMY_ITEM
    and    sitems.inventory_item_id = item_dspFormula.inventory_item_id;

     /*    srw.reference (:item_flex);
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
    v_item := fnd_flex_xml_publisher_apis.process_kff_combination_1('Item_dsp', 'INV', p_item_flex_code,p_item_structure_num ,item_dspFormula.ORGANIZATION_ID,item_dspFormula.INVENTORY_ITEM_ID, 'ALL', 'Y',
'VALUE');
  elsif (item_identifier_type = 'CUST' and p_print_description in ('C','P','O')) then
    select citems.customer_item_number item,
    	   nvl(citems.customer_item_desc,sitems.description) description
    into   v_item,v_description
    from   mtl_customer_items citems,
           mtl_customer_item_xrefs cxref,
           mtl_system_items_vl sitems
    where  citems.customer_item_id = cxref.customer_item_id
    and    cxref.inventory_item_id = sitems.inventory_item_id
    and    citems.customer_item_id = item_dspFormula.ordered_item_id
    and    nvl(sitems.organization_id,0) = RP_DUMMY_ITEM
    and    sitems.inventory_item_id = item_dspFormula.inventory_item_id;
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
    and    items.cross_reference = item_dspFormula.ordered_item
    and    items.cross_reference_type = item_dspFormula.item_identifier_type
    and    nvl(sitems.organization_id,0) = RP_DUMMY_ITEM
    and    sitems.inventory_item_id = item_dspFormula.inventory_item_id;
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
EXCEPTION
WHEN NO_DATA_FOUND THEN
RETURN ('Item not found');
end;



END ONT_OEXIODIS_XMLP_PKG;


/
