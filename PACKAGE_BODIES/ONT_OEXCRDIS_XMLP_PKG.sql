--------------------------------------------------------
--  DDL for Package Body ONT_OEXCRDIS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_OEXCRDIS_XMLP_PKG" AS
/* $Header: OEXCRDISB.pls 120.4 2008/06/05 11:54:15 dwkrishn noship $ */
  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    BEGIN
      IF P_ORDER_BY = 'CUSTOMER' THEN
        LP_ORDER_BY := 'order by oe_customer_name, oe_number, line_shipment_option_number ';
      ELSIF P_ORDER_BY = 'ORDER_TYPE' THEN
        LP_ORDER_BY := 'order by oe_order_type, oe_line_type, oe_customer_name, oe_number, line_shipment_option_number ';
      ELSIF P_ORDER_BY = 'ORDER_NUM' THEN
        LP_ORDER_BY := 'order by oe_number, line_shipment_option_number ';
      ELSE
        LP_ORDER_BY := 'order by oe_number ';
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
      IF P_ORDER_DATE_LOW IS NOT NULL THEN
        LP_ORDER_DATE_LOW := 'and oeh.ordered_date >= :p_order_date_low ';
      ELSE
        LP_ORDER_DATE_LOW := ' ';
      END IF;
      IF P_ORDER_DATE_HIGH IS NOT NULL THEN
        LP_ORDER_DATE_HIGH := 'and oeh.ordered_date <= :p_order_date_high ';
      ELSE
        LP_ORDER_DATE_HIGH := ' ';
      END IF;
      IF P_RECEIPT_DATE_LOW IS NOT NULL THEN
        LP_RECEIPT_DATE_LOW := 'and om_reports_common_pkg.oexoeors_get_workflow_date(oel.line_id) >= :p_receipt_date_low ';
      ELSE
        LP_RECEIPT_DATE_LOW := ' ';
      END IF;
      IF P_RECEIPT_DATE_HIGH IS NOT NULL THEN
        LP_RECEIPT_DATE_HIGH := 'and om_reports_common_pkg.oexoeors_get_workflow_date(oel.line_id) <= :p_receipt_date_high ';
      ELSE
        LP_RECEIPT_DATE_HIGH := ' ';
      END IF;
      IF P_CUSTOMER_NAME_LOW IS NOT NULL THEN
        LP_CUSTOMER_NAME_LOW := 'and c.name >= :p_customer_name_low ';
      ELSE
        LP_CUSTOMER_NAME_LOW := ' ';
      END IF;
      IF P_CUSTOMER_NAME_HIGH IS NOT NULL THEN
        LP_CUSTOMER_NAME_HIGH := 'and c.name <= :p_customer_name_high ';
      ELSE
        LP_CUSTOMER_NAME_HIGH := ' ';
      END IF;
      IF P_CUSTOMER_NUMBER_LOW IS NOT NULL THEN
        LP_CUSTOMER_NUMBER_LOW := 'and c.customer_number >= ''' || P_CUSTOMER_NUMBER_LOW || '''';
      ELSE
        LP_CUSTOMER_NUMBER_LOW := ' ';
      END IF;
      IF P_CUSTOMER_NUMBER_HIGH IS NOT NULL THEN
        LP_CUSTOMER_NUMBER_HIGH := ' and c.customer_number <= ''' || P_CUSTOMER_NUMBER_HIGH || '''';
      ELSE
        LP_CUSTOMER_NUMBER_HIGH := ' ';
      END IF;
      /*SRW.MESSAGE(1
                 ,'Error -1 ')*/NULL;
      IF P_ORDER_TYPE_LOW IS NOT NULL THEN
        LP_ORDER_TYPE_LOW := 'and oeot.transaction_type_id >= ' || P_ORDER_TYPE_LOW;
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
      IF P_ORDER_TYPE_HIGH IS NOT NULL THEN
        LP_ORDER_TYPE_HIGH := 'and oeot.transaction_type_id <=' || P_ORDER_TYPE_HIGH;
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
      /*SRW.MESSAGE(1
                 ,'l_order_type_low-->' || L_ORDER_TYPE_LOW)*/NULL;
    END;
    RETURN (TRUE);
  END AFTERPFORM;

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
        P_ORG_ID := MO_GLOBAL.GET_CURRENT_ORG_ID;
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
        RP_REPORT_NAME := L_REPORT_NAME;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RP_REPORT_NAME := 'Credit Order Discrepancy Report';
      END;
      BEGIN
        /*SRW.REFERENCE(P_ITEM_FLEX_CODE)*/NULL;
        /*SRW.REFERENCE(P_ITEM_STRUCTURE_NUM)*/NULL;
        /*SRW.REFERENCE(P_ITEM_LOW)*/NULL;
        /*SRW.REFERENCE(P_ITEM_HIGH)*/NULL;
        IF P_ITEM_LOW IS NOT NULL OR P_ITEM_HIGH IS NOT NULL THEN
          LP_ITEM1 := ' and ' ;
        END IF;
      EXCEPTION
        WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
          /*SRW.MESSAGE(2000
                     ,'Failed in BEFORE REPORT trigger. FND FLEXSQL USER_EXIT')*/NULL;
      END;
    END;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION C_BUILD_LBLFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      L_DATE VARCHAR2(11);
      H_DATE VARCHAR2(11);
      LR_DATE VARCHAR2(11);
      HR_DATE VARCHAR2(11);
    BEGIN
      IF P_ORDER_NUM_LOW IS NOT NULL OR P_ORDER_NUM_HIGH IS NOT NULL THEN
        RP_ORDER_RANGE := 'From ' || NVL(P_ORDER_NUM_LOW
                             ,'     ') || ' To ' || NVL(P_ORDER_NUM_HIGH
                             ,'     ');
      END IF;
      IF P_CUSTOMER_NAME_LOW IS NOT NULL OR P_CUSTOMER_NAME_HIGH IS NOT NULL THEN
        RP_CUSTOMER_RANGE := 'From ' || NVL(P_CUSTOMER_NAME_LOW
                                ,'      ') || ' To ' || NVL(P_CUSTOMER_NAME_HIGH
                                ,'     ');
      END IF;
      IF P_CUSTOMER_NUMBER_LOW IS NOT NULL OR P_CUSTOMER_NUMBER_HIGH IS NOT NULL THEN
        RP_CUSTOMER_NUMBER_RANGE := 'From ' || P_CUSTOMER_NUMBER_LOW || ' To ' || P_CUSTOMER_NUMBER_HIGH;
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
      IF P_ORDER_TYPE_LOW IS NOT NULL OR P_ORDER_TYPE_HIGH IS NOT NULL THEN
        RP_ORDER_TYPE_RANGE := 'From ' || NVL(L_ORDER_TYPE_LOW
                                  ,'      ') || ' To ' || NVL(L_ORDER_TYPE_HIGH
                                  ,'     ');
      END IF;
      IF P_ITEM_LOW IS NOT NULL OR P_ITEM_HIGH IS NOT NULL THEN
        RP_ITEM_RANGE := 'From ' || NVL(P_ITEM_LOW
                            ,'      ') || ' To ' || NVL(P_ITEM_HIGH
                            ,'     ');
      END IF;
      LR_DATE := '           ';
      HR_DATE := '           ';
      IF P_RECEIPT_DATE_LOW IS NOT NULL THEN
        LR_DATE := TO_CHAR(P_RECEIPT_DATE_LOW);
      END IF;
      IF P_RECEIPT_DATE_HIGH IS NOT NULL THEN
        HR_DATE := TO_CHAR(P_RECEIPT_DATE_HIGH);
      END IF;
      IF P_RECEIPT_DATE_LOW IS NOT NULL OR P_RECEIPT_DATE_HIGH IS NOT NULL THEN
        RP_RECEIPT_DATE_RANGE := 'From ' || LR_DATE || ' To ' || HR_DATE;
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
        ORDER_BY VARCHAR2(80);
      BEGIN
        SELECT
          MEANING
        INTO ORDER_BY
        FROM
          OE_LOOKUPS
        WHERE LOOKUP_TYPE = 'OEXCRDIS ORDER BY'
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

  FUNCTION RP_DUMMY_ITEM_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_DUMMY_ITEM;
  END RP_DUMMY_ITEM_P;

  FUNCTION RP_REPORT_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_REPORT_NAME;
  END RP_REPORT_NAME_P;

  FUNCTION RP_COMPANY_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_COMPANY_NAME;
  END RP_COMPANY_NAME_P;

  FUNCTION RP_ITEM_FLEX_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_ITEM_FLEX;
  END RP_ITEM_FLEX_P;

  FUNCTION RP_SUB_TITLE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_SUB_TITLE;
  END RP_SUB_TITLE_P;

  FUNCTION RP_ORDER_RANGE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_ORDER_RANGE;
  END RP_ORDER_RANGE_P;

  FUNCTION RP_CUSTOMER_RANGE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_CUSTOMER_RANGE;
  END RP_CUSTOMER_RANGE_P;

  FUNCTION RP_ORDER_DATE_RANGE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_ORDER_DATE_RANGE;
  END RP_ORDER_DATE_RANGE_P;

  FUNCTION RP_ITEM_DISPLAY_METHOD_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_ITEM_DISPLAY_METHOD;
  END RP_ITEM_DISPLAY_METHOD_P;

  FUNCTION RP_ORDER_TYPE_RANGE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_ORDER_TYPE_RANGE;
  END RP_ORDER_TYPE_RANGE_P;

  FUNCTION RP_ORDER_BY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_ORDER_BY;
  END RP_ORDER_BY_P;

  FUNCTION RP_ITEM_FLEX_ALL_SEG_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_ITEM_FLEX_ALL_SEG;
  END RP_ITEM_FLEX_ALL_SEG_P;

  FUNCTION RP_CUSTOMER_NUMBER_RANGE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_CUSTOMER_NUMBER_RANGE;
  END RP_CUSTOMER_NUMBER_RANGE_P;

  FUNCTION RP_ITEM_RANGE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_ITEM_RANGE;
  END RP_ITEM_RANGE_P;

  FUNCTION RP_DATA_FOUND_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_DATA_FOUND;
  END RP_DATA_FOUND_P;

  FUNCTION RP_RECEIPT_DATE_RANGE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_RECEIPT_DATE_RANGE;
  END RP_RECEIPT_DATE_RANGE_P;

FUNCTION ITEM_DSPFORMULA(item_identifier_type in varchar2,oe_inventory_item_id1 in number ,rp_dummy_item in varchar2,
item_dsp in varchar2, ORDERED_ITEM_ID in number, ordered_item in varchar2, ORGANIZATION_ID in number, INVENTORY_ITEM_ID in number)
RETURN VARCHAR2 IS
v_item varchar2(2000);
v_description varchar2(500);
begin

if (item_identifier_type is null or item_identifier_type = 'INT')
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
    and    sitems.inventory_item_id = oe_inventory_item_id1;
--    rp_dummy_item := v_item;

        /* srw.reference (:ITEM_FLEX);
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
		);*/
--    rp_dummy_item := '';
    v_item := fnd_flex_xml_publisher_apis.process_kff_combination_1('Item_dsp', 'INV', p_item_flex_code, p_item_structure_num, ITEM_DSPFORMULA.ORGANIZATION_ID, ITEM_DSPFORMULA.INVENTORY_ITEM_ID, 'ALL', 'Y', 'VALUE');
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
    and    sitems.inventory_item_id = oe_inventory_item_id1;
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
    and    items.cross_reference = ordered_item
    and    items.cross_reference_type = item_identifier_type
    and    nvl(sitems.organization_id,0) = nvl(oe_sys_parameters.value('MASTER_ORGANIZATION_ID',mo_global.get_current_org_id()),0)
    and    sitems.inventory_item_id = oe_inventory_item_id1;
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
END ITEM_DSPFORMULA;



END ONT_OEXCRDIS_XMLP_PKG;


/
