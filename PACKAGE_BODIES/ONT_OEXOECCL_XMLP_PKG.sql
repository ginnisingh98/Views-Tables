--------------------------------------------------------
--  DDL for Package Body ONT_OEXOECCL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_OEXOECCL_XMLP_PKG" AS
/* $Header: OEXOECCLB.pls 120.2 2008/05/05 10:14:20 dwkrishn noship $ */
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
  BEGIN
    BEGIN
      IF P_CUSTOMER_NAME IS NOT NULL THEN
        LP_CUSTOMER_NAME := ' and c.name = :p_customer_name';
      END IF;
      IF (lp_customer_name IS NULL) THEN
	lp_customer_name := ' ';
      END IF;
      IF P_CUSTOMER_NUMBER IS NOT NULL THEN
        LP_CUSTOMER_NUMBER := ' and c.customer_number = :p_customer_number';
      END IF;
       IF (lp_customer_number IS NULL) THEN
	lp_customer_number := ' ';
      END IF;
      IF P_ORDER_NUMBER IS NOT NULL THEN
        LP_ORDER_NUMBER := ' and h.order_number = :p_order_number';
      END IF;
       IF (lp_order_number IS NULL) THEN
	lp_order_number := ' ';
      END IF;
      IF P_CURRENCY_CODE IS NOT NULL THEN
        LP_CURRENCY_CODE := ' and h.transactional_curr_code = :p_currency_code';
      END IF;
      IF (lp_currency_code IS NULL) THEN
	lp_currency_code := ' ';
      END IF;
      IF (P_DATE_HOLD_APPLIED_LOW IS NOT NULL) AND (P_DATE_HOLD_APPLIED_HIGH IS NOT NULL) THEN
        LP_DATE_HOLD_APPLIED := 'and  (trunc(oh.creation_date)  between :p_date_hold_applied_low
                                			and :p_date_hold_applied_high) ';
      ELSIF (P_DATE_HOLD_APPLIED_LOW IS NOT NULL) THEN
        LP_DATE_HOLD_APPLIED := 'and trunc(oh.creation_date)  >= :p_date_hold_applied_low ';
      ELSIF (P_DATE_HOLD_APPLIED_HIGH IS NOT NULL) THEN
        LP_DATE_HOLD_APPLIED := 'and trunc(oh.creation_date)  <= :p_date_hold_applied_high ';
      END IF;
      IF (lp_date_hold_applied IS NULL) THEN
	lp_date_hold_applied := ' ';
      END IF;
      IF P_ORDER_TYPE IS NOT NULL THEN
        LP_ORDER_TYPE := ' and ot.transaction_type_id = :p_order_type';
        SELECT
          OEOT.NAME
        INTO L_ORDER_TYPE
        FROM
          OE_TRANSACTION_TYPES_TL OEOT
        WHERE OEOT.TRANSACTION_TYPE_ID = P_ORDER_TYPE
          AND OEOT.LANGUAGE = USERENV('LANG');
      END IF;
      IF (lp_order_type IS NULL) THEN
	lp_order_type := ' ';
      END IF;
      IF P_LINE_TYPE IS NOT NULL THEN
        LP_LINE_TYPE := ' and lt.line_type_id = :p_line_type';
        SELECT
          OEOT.NAME
        INTO L_LINE_TYPE
        FROM
          OE_TRANSACTION_TYPES_TL OEOT
        WHERE OEOT.TRANSACTION_TYPE_ID = P_LINE_TYPE
          AND OEOT.LANGUAGE = USERENV('LANG');
      END IF;
      IF (lp_line_type IS NULL) THEN
	lp_line_type := ' ';
      END IF;
    END;
    RETURN (TRUE);
  END AFTERPFORM;
  FUNCTION C_DATA_NOT_FOUNDFORMULA(CUSTOMER_NAME IN VARCHAR2) RETURN NUMBER IS
  BEGIN
    RP_DATA_FOUND := CUSTOMER_NAME;
    RETURN (0);
  END C_DATA_NOT_FOUNDFORMULA;
  FUNCTION C_ADDRESSFORMULA(ADDRESS1 IN VARCHAR2
                           ,CITY IN VARCHAR2
                           ,STATE IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    /*SRW.REFERENCE(ADDRESS1)*/NULL;
    /*SRW.REFERENCE(CITY)*/NULL;
    /*SRW.REFERENCE(STATE)*/NULL;
    IF ADDRESS1 IS NOT NULL THEN
      RETURN (ADDRESS1 || ' , ' || CITY || ' , ' || STATE);
    ELSE
      RETURN (NULL);
    END IF;
    RETURN NULL;
  END C_ADDRESSFORMULA;
  FUNCTION P_ITEM_FLEX_CODEVALIDTRIGGER RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END P_ITEM_FLEX_CODEVALIDTRIGGER;
  FUNCTION INVENTORY_ITEM_ID_P RETURN NUMBER IS
  BEGIN
    RETURN INVENTORY_ITEM_ID;
  END INVENTORY_ITEM_ID_P;
  FUNCTION ORDERED_ITEM_P RETURN VARCHAR2 IS
  BEGIN
    RETURN ORDERED_ITEM;
  END ORDERED_ITEM_P;
  FUNCTION ORDERED_ITEM_ID_P RETURN NUMBER IS
  BEGIN
    RETURN ORDERED_ITEM_ID;
  END ORDERED_ITEM_ID_P;
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
  FUNCTION RP_DATE_HOLD_APPLIED_RANGE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_DATE_HOLD_APPLIED_RANGE;
  END RP_DATE_HOLD_APPLIED_RANGE_P;
  FUNCTION RP_SHIP_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_SHIP;
  END RP_SHIP_P;
  FUNCTION RP_ORDER_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_ORDER;
  END RP_ORDER_P;
  FUNCTION RP_VAT_PROFILE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_VAT_PROFILE;
  END RP_VAT_PROFILE_P;
  FUNCTION RP_PRINT_DESCRIPTION_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_PRINT_DESCRIPTION;
  END RP_PRINT_DESCRIPTION_P;
  FUNCTION RP_ITEM_FLEX_ALL_SEG_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_ITEM_FLEX_ALL_SEG;
  END RP_ITEM_FLEX_ALL_SEG_P;
  FUNCTION RP_DUMMY_ITEM_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_DUMMY_ITEM;
  END RP_DUMMY_ITEM_P;
  function BeforeReport return boolean is
begin
DECLARE
BEGIN
  /*BEGIN
  SRW.USER_EXIT('FND SRWINIT');
  EXCEPTION
     WHEN SRW.USER_EXIT_FAILURE THEN
	SRW.MESSAGE (1000,'Failed in BEFORE REPORT trigger');
     return (FALSE);
     NULL;
  END;*/
  BEGIN /*MOAC*/
  P_ORG_ID:= MO_GLOBAL.GET_CURRENT_ORG_ID();
  LP_ORG_ID:=P_ORG_ID;
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
The following block retrieves the profile option value for VAT
-------------------------------------------------------------------------------*/
BEGIN
    /*SRW.REFERENCE(:P_VAT_PROFILE);
    SRW.USER_EXIT('FND GETPROFILE NAME=":P_VAT_PROFILE"
                   FIELD=":RP_VAT_PROFILE"
                   PRINT_ERROR="N"');
EXCEPTION
    WHEN SRW.USER_EXIT_FAILURE THEN
    srw.message(2000,'Failed in BEFORE REPORT trigger. FND GETPROFILE - VAT USER_EXIT'); */
    NULL;
END;
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
      THEN RP_REPORT_NAME := 'Lines on Credit Check Hold Report';
  END;
/*------------------------------------------------------------------------------
Following PL/SQL block builds up the lexical parameters, to be used in the
WHERE clause of the query. This also populates the report level variables, used
to store the flexfield structure.
------------------------------------------------------------------------------*/
  BEGIN
    /*SRW.REFERENCE(:P_item_flex_code);
    SRW.REFERENCE(:P_ITEM_STRUCTURE_NUM);
    SRW.USER_EXIT('FND FLEXSQL CODE=":p_item_flex_code"
			   NUM=":p_item_structure_num"
			   APPL_SHORT_NAME="INV"
			   OUTPUT=":rp_item_flex_all_seg"
			   MODE="SELECT"
			   DISPLAY="ALL"
			   TABLEALIAS="SI"
			    ');
  EXCEPTION
    WHEN SRW.USER_EXIT_FAILURE THEN
    srw.message(2000,'Failed in BEFORE REPORT trigger. FND FLEXSQL USER_EXIT'); */
    NULL;
  END;
/*------------------------------------------------------------------------------
Following PL/SQL fetches the Master Organization Id for the session.
Used in the WHERE clause of the query.
------------------------------------------------------------------------------*/
  BEGIN
    RP_DUMMY_ITEM := NVL( OE_SYS_PARAMETERS.VALUE('MASTER_ORGANIZATION_ID',mo_global.get_current_org_id()),0 );
  EXCEPTION
    WHEN OTHERS THEN
	 /*SRW.MESSAGE(1000,'Error in fetching Master Organization Id for the session');*/
	 RP_DUMMY_ITEM := 0;
  END;
  DECLARE
      l_date_hold_applied_low             VARCHAR2 (50);
      l_date_hold_applied_high            VARCHAR2 (50);
  BEGIN
  if ( p_date_hold_applied_low is NULL) AND ( p_date_hold_applied_high is NULL ) then
    NULL ;
  else
    if p_date_hold_applied_low is NULL then
      l_date_hold_applied_low := '   ';
    else
      l_date_hold_applied_low := substr(to_char(p_date_hold_applied_low,'DD-MON-YYYY'),1,18);
    end if ;
    if p_date_hold_applied_high is NULL then
      l_date_hold_applied_high := '   ';
    else
      l_date_hold_applied_high := substr(to_char(p_date_hold_applied_high,'DD-MON-YYYY'),1,18);
    end if ;
    rp_date_hold_applied_range  := 'From '||l_date_hold_applied_low||' To '||l_date_hold_applied_high ;
  end if ;
DECLARE
    l_meaning       VARCHAR2 (80);
  BEGIN
    SELECT MEANING
    INTO   l_meaning
    FROM OE_LOOKUPS
    WHERE LOOKUP_TYPE = 'ITEM_DISPLAY_CODE'
    AND LOOKUP_CODE  = substr(upper(p_item_description),1,1)
    ;
    rp_print_description := l_meaning ;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    rp_print_description := 'Description';
  END ;
  END ;
END ;
  return (TRUE);
end beforereport;

FUNCTION ITEM_DSPFORMULA(ITEM_IDENTIFIER_TYPE IN VARCHAR2,ORDERED_ITEM_ID IN NUMBER,ORDERED_ITEM IN VARCHAR2,ORGANIZATION_ID IN NUMBER,INVENTORY_ITEM_ID1 IN NUMBER) RETURN VARCHAR2 IS

v_item varchar2(2000);
v_description varchar2(500);
begin
  if (item_identifier_type is null or item_identifier_type = 'INT')
       or (p_item_description in ('I','D','F')) then

	  v_item := fnd_flex_xml_publisher_apis.process_kff_combination_1('Item_dsp', 'INV', p_item_flex_code, p_item_structure_num, Item_DspFormula.ORGANIZATION_ID, Item_DspFormula.INVENTORY_ITEM_ID1, 'ALL', 'Y', 'VALUE');

    select sitems.description description
    into   v_description
    from   mtl_system_items_vl sitems
    where  sitems.customer_order_enabled_flag = 'Y'
    and    sitems.bom_item_type in (1,4)
    and    nvl(sitems.organization_id,0) = RP_DUMMY_ITEM
    and    sitems.inventory_item_id = Item_DspFormula.inventory_item_id1;  --Bug2764262

      /*   srw.reference (:item_flex);
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
    v_item :=  fnd_flex_xml_publisher_apis.process_kff_combination_1('Item_dsp', 'INV', p_item_flex_code, p_item_structure_num, Item_DspFormula.ORGANIZATION_ID, Item_DspFormula.INVENTORY_ITEM_ID1, 'ALL', 'Y', 'VALUE');
  elsif (item_identifier_type = 'CUST' and p_item_description in ('C','P','O')) then
    select citems.customer_item_number item,
    	   nvl(citems.customer_item_desc,sitems.description) description
    into   v_item,v_description
    from   mtl_customer_items citems,
           mtl_customer_item_xrefs cxref,
           mtl_system_items_vl sitems
    where  citems.customer_item_id = cxref.customer_item_id
    and    cxref.inventory_item_id = sitems.inventory_item_id
    and    citems.customer_item_id = Item_DspFormula.ordered_item_id
    and    nvl(sitems.organization_id,0) = RP_DUMMY_ITEM
    and    sitems.inventory_item_id = Item_DspFormula.inventory_item_id1;
--    and    sitems.customer_order_enabled_flag = 'Y'
--    and    sitems.bom_item_type in (1,4)
  elsif (p_item_description in ('C','P','O')) then
    select items.cross_reference item,
    	   nvl(items.description,sitems.description) description
    into   v_item,v_description
    from   mtl_cross_reference_types xtypes,
           mtl_cross_references items,
           mtl_system_items_vl sitems
    where  xtypes.cross_reference_type = items.cross_reference_type
    and    items.inventory_item_id = sitems.inventory_item_id
    and    items.cross_reference = Item_DspFormula.ordered_item
    and    items.cross_reference_type = Item_DspFormula.item_identifier_type
    and    nvl(sitems.organization_id,0) = RP_DUMMY_ITEM
    and    sitems.inventory_item_id = Item_DspFormula.inventory_item_id1;
--    and    sitems.customer_order_enabled_flag = 'Y'
--    and    sitems.bom_item_type in (1,4)
  end if;

  if (p_item_description in ('I','C')) then
    return(v_item||' - '||v_description);
  elsif (p_item_description in ('D','P')) then
    return(v_description);
  else
    return(v_item);
  end if;

RETURN NULL;
Exception
   When Others Then
        return('Item Not Found');
end;

END ONT_OEXOECCL_XMLP_PKG;


/
