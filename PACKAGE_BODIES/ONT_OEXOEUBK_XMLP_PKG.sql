--------------------------------------------------------
--  DDL for Package Body ONT_OEXOEUBK_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_OEXOEUBK_XMLP_PKG" AS
/* $Header: OEXOEUBKB.pls 120.3 2008/05/05 06:39:13 dwkrishn noship $ */
function Item_dspFormula(inventory_item_id_L IN number,
                        item_identifier_type_L IN VARCHAR2,
			 ordered_item_id_L IN NUMBER,
                         ORGANIZATION_ID_L IN NUMBER,
			 ordered_item_L IN VARCHAR2) return Char is
v_item varchar2(2000);
v_description varchar2(500);
begin
  if (inventory_item_id_L is null) then
    return null;
  end if;
  if (item_identifier_type_L is null or item_identifier_type_L = 'INT')
       or (p_print_description in ('I','D','F')) then
    select sitems.concatenated_segments item,
    	   sitems.description description
    into   v_item,v_description
    from   mtl_system_items_vl sitems
    where  sitems.customer_order_enabled_flag = 'Y'

    and    nvl(sitems.organization_id,0) = nvl(oe_sys_parameters.value('MASTER_ORGANIZATION_ID',mo_global.get_current_org_id()),0)
    and    sitems.inventory_item_id = inventory_item_id_L;
/*
         srw.reference (:p_item_flex_code);
         srw.reference (:Item_dsp);
         srw.reference (:p_item_structure_num);
--modified the use_exit to use item_flex to derive the value for
-- the item for FP bug 3693140
         srw.user_exit (' FND FLEXIDVAL
		    CODE=":p_item_flex_code"
		    NUM=":p_item_structure_num"
		    APPL_SHORT_NAME="INV"
		    DATA= ":item_flex"
		    VALUE=":Item_dsp"
		    DISPLAY="ALL"'
		);  */
    v_item := fnd_flex_xml_publisher_apis.process_kff_combination_1('Item_dsp', 'INV',p_item_flex_code,p_item_structure_num,ORGANIZATION_ID_L,INVENTORY_ITEM_ID_L, 'ALL', 'Y', 'VALUE');
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
  Begin
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
    and    sitems.inventory_item_id = inventory_item_id_L
    --Bug 3433353 Being
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
    and items.cross_reference = ordered_item_L
    and items.cross_reference_type = item_identifier_type_L
    and nvl(sitems.organization_id,0) = nvl(oe_sys_parameters.value('MASTER_ORGANIZATION_ID',mo_global.get_current_org_id()),0)
    and sitems.inventory_item_id = inventory_item_id_L
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

function BeforeReport return boolean is
	begin
		BEGIN
P_ORGANIZATION_ID1 := P_ORGANIZATION_ID;

		  BEGIN
			 -- SRW.USER_EXIT('FND SRWINIT');
			 null;
			/*  EXCEPTION
			     WHEN SRW.USER_EXIT_FAILURE THEN
			SRW.MESSAGE (1000,'Failed in BEFORE REPORT trigger');
			     return (FALSE);*/
		  END;

		BEGIN  /*MOAC*/

			--P_ORGANIZATION_ID:= MO_GLOBAL.GET_CURRENT_ORG_ID();
			P_ORGANIZATION_ID1:= MO_GLOBAL.GET_CURRENT_ORG_ID();

		END;

/*------------------------------------------------------------------------------
Following PL/SQL block gets the company name, functional currency and precision.
------------------------------------------------------------------------------*/

  DECLARE
  l_company_name            VARCHAR2 (100);
  l_functional_currency     VARCHAR2  (15);

  BEGIN

    SELECT sob.name                   ,
	   sob.currency_code
    INTO
	   l_company_name ,
	   l_functional_currency
    FROM    gl_sets_of_books sob,
	    fnd_currencies cur
    WHERE  sob.set_of_books_id = p_sob_id
    AND    sob.currency_code = cur.currency_code
    ;

    rp_company_name            := l_company_name;
    rp_functional_currency     := l_functional_currency ;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL ;
  END ;

/*------------------------------------------------------------------------------
Following PL/SQL block gets the report name for the passed concurrent request Id.
------------------------------------------------------------------------------*/
  DECLARE
      l_report_name  VARCHAR2(240);
  BEGIN
      SELECT cp.user_concurrent_program_name
      INTO   l_report_name
      FROM   FND_CONCURRENT_PROGRAMS_VL cp,
	     FND_CONCURRENT_REQUESTS cr
      WHERE  cr.request_id     = P_CONC_REQUEST_ID
      AND    cp.application_id = cr.program_application_id
      AND    cp.concurrent_program_id = cr.concurrent_program_id
      ;

      RP_Report_Name := l_report_name;
  EXCEPTION
      WHEN NO_DATA_FOUND
      THEN RP_REPORT_NAME := 'Unbooked Orders Report';
  END;

/*------------------------------------------------------------------------------
Following PL/SQL block builds up the lexical parameters, to be used in the
WHERE clause of the query. This also populates the report level variables, used
to store the flexfield structure.
------------------------------------------------------------------------------*/
 /* BEGIN
   -- SRW.REFERENCE(:P_item_flex_code);
   -- SRW.REFERENCE(:P_item_structure_num);


    SRW.USER_EXIT('FND FLEXSQL CODE=":P_item_flex_code"
			   NUM=":P_ITEM_STRUCTURE_NUM"
			   APPL_SHORT_NAME="INV"
			   OUTPUT=":rp_item_flex_all_seg"
			   MODE="SELECT"
			   DISPLAY="ALL"
			   TABLEALIAS="MSI"
			    ');


  EXCEPTION
    WHEN SRW.USER_EXIT_FAILURE THEN
    srw.message(2000,'Failed in BEFORE REPORT trigger. FND FLEXSQL USER_EXIT');
  END;
*/


DECLARE
    l_meaning       VARCHAR2 (80);
  BEGIN
    SELECT MEANING
    INTO   l_meaning
    FROM OE_LOOKUPS
    WHERE LOOKUP_TYPE = 'ITEM_DISPLAY_CODE'
    AND LOOKUP_CODE  = substr(upper(p_print_description),1,1)
    ;

    rp_print_description := l_meaning ;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    rp_print_description := 'Internal Item Description';
  when OTHERS then
  null;
 -- srw.message(2000,'Failed in BEFORE REPORT trigger. Get Print Description');

  END ;

/*------------------------------------------------------------------------------
THE Following PL/SQL block populates the order_date_range and created_by range
parameters used in the report margins
------------------------------------------------------------------------------*/
  BEGIN
	if (P_created_by_low is NOT NULL OR P_created_by_high is NOT NULL) then
	  if (P_Created_by_low is NULL) then
	    P_Created_by_low := '     ';
	  end if;
	  lp_created_by_range := ' From '||P_Created_by_low||' To '||P_Created_by_high;
	end if;

	if (P_order_date_low is NOT NULL OR P_order_date_high is NOT NULL) then
	  lp_order_date_range := ' From '||nvl(to_char(P_Order_date_low, 'DD-MON-RRRR'), '     ')
           || ' To ' ||nvl(to_char(P_Order_date_high, 'DD-MON-RRRR'), '     ');
 	end if;
  END;
END ;
IF Oe_Sys_Parameters.Value('RECURRING_CHARGES',mo_global.get_current_org_id())='Y' Then
	C_PERIODICITY_DSP_FLAG := 'Y';
ELSE
	C_PERIODICITY_DSP_FLAG := 'N';
END IF;
  return (TRUE);
end BeforeReport;

  -------------------------
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
    BEGIN
      IF (UPPER(P_ORDER_BY) = 'CREATED_BY') THEN
        LP_ORDER_BY := 'order by 4,1,2';
        SELECT
          MEANING
        INTO LP_ORDER_BY_MEAN
        FROM
          OE_LOOKUPS
        WHERE LOOKUP_CODE = UPPER(P_ORDER_BY)
          AND LOOKUP_TYPE = 'OEXOEUBK ORDER BY';
      ELSE
        LP_ORDER_BY := 'order by 1,2,4';
        LP_ORDER_BY_MEAN := 'Order Number';
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        LP_ORDER_BY_MEAN := P_ORDER_BY;
    END;
    IF (lp_order_by IS NULL) THEN
	lp_order_by := ' ';
    END IF;

    BEGIN
      IF (P_ORDER_DATE_LOW IS NOT NULL) AND (P_ORDER_DATE_HIGH IS NOT NULL) THEN
        LP_ORDER_DATE := 'and h.ordered_date between :p_order_date_low and (:p_order_date_high+1) ';
      ELSIF (P_ORDER_DATE_LOW IS NOT NULL) THEN
        LP_ORDER_DATE := 'and h.ordered_date >= :p_order_date_low';
      ELSIF (P_ORDER_DATE_HIGH IS NOT NULL) THEN
        LP_ORDER_DATE := 'and h.ordered_date  <= (:p_order_date_high+1) ';
      END IF;

      IF (lp_order_date IS NULL) THEN
	lp_order_date := ' ';
    END IF;

    END;
    BEGIN
      IF (P_CREATED_BY_LOW IS NOT NULL) AND (P_CREATED_BY_HIGH IS NOT NULL) THEN
        LP_CREATED_BY := 'and fu.user_name between :p_created_by_low and :p_created_by_high ';
      ELSIF (P_CREATED_BY_LOW IS NOT NULL) THEN
        LP_CREATED_BY := 'and fu.user_name >= :p_created_by_low ';
      ELSIF (P_CREATED_BY_HIGH IS NOT NULL) THEN
        LP_CREATED_BY := 'and fu.user_name <= :p_created_by_high ';
      END IF;
IF (lp_created_by IS NULL) THEN
	lp_created_by := ' ';
    END IF;

    END;
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
    IF (lp_line_category IS NULL) THEN
	lp_line_category := ' ';
    END IF;
    RETURN (TRUE);
  END AFTERPFORM;

-----------------------
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

  FUNCTION C_PERIODICITY_DSPFORMULA(CHARGE_PERIODICITY_CODE IN VARCHAR2) RETURN CHAR IS
    L_UOM_CLASS VARCHAR2(20) := FND_PROFILE.VALUE('ONT_UOM_CLASS_CHARGE_PERIODICITY');
    L_CHARGE_PERIODICITY VARCHAR2(25);
  BEGIN
    IF CHARGE_PERIODICITY_CODE IS NULL THEN
      RETURN (P_ONE_TIME);
    ELSE
      SELECT
        UNIT_OF_MEASURE
      INTO L_CHARGE_PERIODICITY
      FROM
        MTL_UNITS_OF_MEASURE_VL
      WHERE UOM_CLASS = L_UOM_CLASS
        AND UOM_CODE = CHARGE_PERIODICITY_CODE;
      RETURN L_CHARGE_PERIODICITY;
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
  END C_PERIODICITY_DSPFORMULA;

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

  FUNCTION RP_PRINT_DESCRIPTION_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_PRINT_DESCRIPTION;
  END RP_PRINT_DESCRIPTION_P;

  FUNCTION RP_DUMMY_ITEM_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_DUMMY_ITEM;
  END RP_DUMMY_ITEM_P;

END ONT_OEXOEUBK_XMLP_PKG;


/
