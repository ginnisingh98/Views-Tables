--------------------------------------------------------
--  DDL for Package Body ONT_OEXOEORD_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_OEXOEORD_XMLP_PKG" AS
/* $Header: OEXOEORDB.pls 120.3 2008/05/05 12:39:26 dwkrishn noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  APF BOOLEAN;
  APF1 BOOLEAN;
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
        RP_CURR_PROFILE := FND_PROFILE.VALUE('ONT_UNIT_PRICE_PRECISION_TYPE');
      EXCEPTION
        WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
          /*SRW.MESSAGE(3000
                     ,'Failed in BEFORE REPORT Trigger FND GETPROFILE USER_EXIT')*/NULL;
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
          RP_REPORT_NAME := 'Credit Order Detail Report';
      END;
      BEGIN
        /*SRW.REFERENCE(P_ITEM_FLEX_CODE)*/NULL;
        /*SRW.REFERENCE(P_ITEM_STRUCTURE_NUM)*/NULL;
        IF (P_ITEM IS NOT NULL) THEN
          LP_ITEM := ' AND ' || LP_ITEM;
        ELSE
	  LP_ITEM := ' ';
        END IF;
      EXCEPTION
        WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
          /*SRW.MESSAGE(2000
                     ,'Failed in BEFORE REPORT trigger. FND FLEXSQL USER_EXIT')*/NULL;
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
          AND LOOKUP_CODE = SUBSTR(UPPER(P_PRINT_DESCRIPTION)
              ,1
              ,1);
        RP_PRINT_DESCRIPTION := L_MEANING;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RP_PRINT_DESCRIPTION := 'Description';
      END;
      DECLARE
        L_MEANING VARCHAR2(80);
      BEGIN
        SELECT
          MEANING
        INTO L_MEANING
        FROM
          OE_LOOKUPS
        WHERE LOOKUP_TYPE = 'YES_NO'
          AND LOOKUP_CODE = SUBSTR(UPPER(P_OPEN_RETURNS_ONLY)
              ,1
              ,1);
        RP_OPEN_RETURNS_ONLY := L_MEANING;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RP_OPEN_RETURNS_ONLY := 'Yes';
      END;
    END;
    APF := P_ORDER_BYVALIDTRIGGER;
    APF1 := P_CREDIT_ONLYVALIDTRIGGER;
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
               ,'$Header: OEXOEORDB.pls 120.3 2008/05/05 12:39:26 dwkrishn noship $')*/NULL;
    DECLARE
      BLANKS CONSTANT VARCHAR2(5) DEFAULT '     ';
      ALL_RANGE CONSTANT VARCHAR2(16) DEFAULT 'From' || BLANKS || 'To' || BLANKS;
    BEGIN
      IF (P_RETURN_TYPE IS NOT NULL) THEN
        LP_RETURN_TYPE := ' AND otype.transaction_type_id = :P_RETURN_TYPE ';
        SELECT
          OEOT.NAME
        INTO L_ORDER_TYPE
        FROM
          OE_TRANSACTION_TYPES_TL OEOT
        WHERE OEOT.TRANSACTION_TYPE_ID = P_RETURN_TYPE
          AND OEOT.LANGUAGE = USERENV('LANG');
      ELSE
        LP_RETURN_TYPE := ' ';
      END IF;
      IF (P_SALESREP IS NOT NULL) THEN
        LP_SALESREP := ' AND SR.NAME = :P_SALESREP ';
      ELSE
        LP_SALESREP := ' ';
      END IF;
      SELECT
        USERENV('LANG')
      INTO P_LANG
      FROM
        DUAL;
      P_ORGANIZATION_ID := NVL(P_ORGANIZATION_ID
                              ,0);
      IF (P_RETURN_LINE_TYPE IS NOT NULL) THEN
        LP_RETURN_LINE_TYPE := 'and ltype.transaction_type_id = :p_return_line_type ';
        SELECT
          OEOT.NAME
        INTO L_LINE_TYPE
        FROM
          OE_TRANSACTION_TYPES_TL OEOT
        WHERE OEOT.TRANSACTION_TYPE_ID = P_RETURN_LINE_TYPE
          AND OEOT.LANGUAGE = USERENV('LANG');
      ELSE
        LP_RETURN_LINE_TYPE := ' ';
      END IF;
      IF (P_LINE_CATEGORY = 'CREDIT') OR (P_LINE_CATEGORY IS NULL) THEN
        LP_LINE_CATEGORY := 'and l.line_category_code = ''RETURN'' ';
      ELSE
        LP_LINE_CATEGORY := ' ';
      END IF;
      IF (P_CUSTOMER_NAME_LOW IS NOT NULL) AND (P_CUSTOMER_NAME_HIGH IS NOT NULL) THEN
        IF (P_CUSTOMER_NAME_LOW = P_CUSTOMER_NAME_HIGH) THEN
          LP_CUSTOMER_NAME := ' and party.party_name = :p_customer_name_low';
        ELSE
          LP_CUSTOMER_NAME := ' AND (party.party_name BETWEEN' || ' :P_CUSTOMER_NAME_LOW AND' || ' :P_CUSTOMER_NAME_HIGH) ';
        END IF;
        CUSTOMER_PARMS := 'From ' || SUBSTR(P_CUSTOMER_NAME_LOW
                                ,1
                                ,20) || ' To ' || SUBSTR(P_CUSTOMER_NAME_HIGH
                                ,1
                                ,20);
      ELSIF (P_CUSTOMER_NAME_LOW IS NOT NULL) THEN
        LP_CUSTOMER_NAME := ' AND party.party_name >=' || ' :P_CUSTOMER_NAME_LOW ';
        CUSTOMER_PARMS := 'From ' || SUBSTR(P_CUSTOMER_NAME_LOW
                                ,1
                                ,20) || ' To ' || BLANKS;
      ELSIF (P_CUSTOMER_NAME_HIGH IS NOT NULL) THEN
        LP_CUSTOMER_NAME := ' AND party.party_name <=' || ' :P_CUSTOMER_NAME_HIGH ';
        CUSTOMER_PARMS := 'From ' || BLANKS || 'To ' || SUBSTR(P_CUSTOMER_NAME_HIGH
                                ,1
                                ,20);
      ELSE
        LP_CUSTOMER_NAME := ' ';
        CUSTOMER_PARMS := ALL_RANGE;
      END IF;
      IF (P_OPEN_RETURNS_ONLY = 'Y') THEN
        LP_OPEN_RETURNS_ONLY := 'AND H.OPEN_FLAG =  ''Y''';
      ELSE
        LP_OPEN_RETURNS_ONLY := ' ';
      END IF;
      IF (P_CUSTOMER_NUM_LOW IS NOT NULL) AND (P_CUSTOMER_NUM_HIGH IS NOT NULL) THEN
        IF (P_CUSTOMER_NUM_LOW = P_CUSTOMER_NUM_HIGH) THEN
          LP_CUSTOMER_NUM := ' and cust.account_number = :p_customer_num_low';
        ELSE
          LP_CUSTOMER_NUM := ' AND (cust.account_number BETWEEN' || ' :P_CUSTOMER_NUM_LOW AND' || ' :P_CUSTOMER_NUM_HIGH) ';
        END IF;
        CUSTOMER_NUM_PARMS := 'From ' || SUBSTR(P_CUSTOMER_NUM_LOW
                                    ,1
                                    ,20) || ' To ' || SUBSTR(P_CUSTOMER_NUM_HIGH
                                    ,1
                                    ,20);
      ELSIF (P_CUSTOMER_NUM_LOW IS NOT NULL) THEN
        LP_CUSTOMER_NUM := ' AND cust.account_number >=' || ' :P_CUSTOMER_NUM_LOW ';
        CUSTOMER_NUM_PARMS := 'From ' || SUBSTR(P_CUSTOMER_NUM_LOW
                                    ,1
                                    ,20) || ' To ' || BLANKS;
      ELSIF (P_CUSTOMER_NUM_HIGH IS NOT NULL) THEN
        LP_CUSTOMER_NUM := ' AND cust.account_number <=' || ' :P_CUSTOMER_NUM_HIGH ';
        CUSTOMER_NUM_PARMS := 'From ' || BLANKS || 'To ' || SUBSTR(P_CUSTOMER_NUM_HIGH
                                    ,1
                                    ,20);
      ELSE
        CUSTOMER_NUM_PARMS := ALL_RANGE;
	LP_CUSTOMER_NUM := ' ';
      END IF;
      IF (P_RETURN_NUM_LOW IS NOT NULL) AND (P_RETURN_NUM_HIGH IS NOT NULL) THEN
        IF (P_RETURN_NUM_LOW = P_RETURN_NUM_HIGH) THEN
          LP_RETURN_NUM := ' and h.order_number= :p_return_num_low';
        ELSE
          LP_RETURN_NUM := ' AND (H.ORDER_NUMBER BETWEEN' || ' TO_NUMBER(:P_RETURN_NUM_LOW) AND' || ' TO_NUMBER(:P_RETURN_NUM_HIGH)) ';
        END IF;
        RETURN_NUM_PARMS := 'From ' || P_RETURN_NUM_LOW || ' To ' || P_RETURN_NUM_HIGH;
      ELSIF (P_RETURN_NUM_LOW IS NOT NULL) THEN
        LP_RETURN_NUM := ' AND H.ORDER_NUMBER >= ' || ' TO_NUMBER(:P_RETURN_NUM_LOW) ';
        RETURN_NUM_PARMS := 'From ' || P_RETURN_NUM_LOW || ' To ' || BLANKS;
      ELSIF (P_RETURN_NUM_HIGH IS NOT NULL) THEN
        LP_RETURN_NUM := ' AND H.ORDER_NUMBER <=' || ' TO_NUMBER(:P_RETURN_NUM_HIGH) ';
        RETURN_NUM_PARMS := 'From ' || BLANKS || 'To ' || P_RETURN_NUM_HIGH;
      ELSE
        LP_RETURN_NUM :=' ';
        RETURN_NUM_PARMS := ' ';
      END IF;
      IF (P_RETURN_DATE_LOW IS NOT NULL) AND (P_RETURN_DATE_HIGH IS NOT NULL) THEN
        IF (P_RETURN_DATE_LOW = P_RETURN_DATE_HIGH) THEN
          LP_RETURN_DATE := ' and h.ordered_date = :p_return_date_low';
        ELSE
          LP_RETURN_DATE := ' AND (H.ORDERED_DATE BETWEEN' || ' :P_RETURN_DATE_LOW' || ' AND' || ' :P_RETURN_DATE_HIGH) ';
        END IF;
        RETURN_DATE_PARMS := 'From ' || TO_CHAR(P_RETURN_DATE_LOW
                                    ,'YYYY/MM/DD') || ' To ' || TO_CHAR(P_RETURN_DATE_HIGH
                                    ,'YYYY/MM/DD');
      ELSIF (P_RETURN_DATE_LOW IS NOT NULL) THEN
        LP_RETURN_DATE := ' AND H.ORDERED_DATE >=' || ' :P_RETURN_DATE_LOW ';
        RETURN_DATE_PARMS := 'From ' || TO_CHAR(P_RETURN_DATE_LOW
                                    ,'YYYY/MM/DD') || ' To ' || BLANKS;
      ELSIF (P_RETURN_DATE_HIGH IS NOT NULL) THEN
        LP_RETURN_DATE := ' AND H.ORDERED_DATE <=' || ' :P_RETURN_DATE_HIGH ';
        RETURN_DATE_PARMS := 'From ' || BLANKS || 'To ' || TO_CHAR(P_RETURN_DATE_HIGH
                                    ,'YYYY/MM/DD');
      ELSE
        LP_RETURN_DATE := ' ';
        RETURN_DATE_PARMS := ' ';
      END IF;
    END;
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION P_ORDER_BYVALIDTRIGGER RETURN BOOLEAN IS
  BEGIN
    BEGIN
      IF (P_ORDER_BY IS NOT NULL) THEN
        SELECT
          SUBSTR(MEANING
                ,1
                ,50)
        INTO SORT_BY_MEANING
        FROM
          OE_LOOKUPS
        WHERE LOOKUP_TYPE = 'OEXOEORD ORDER BY'
          AND LOOKUP_CODE = P_ORDER_BY;
      ELSE
        SELECT
          SUBSTR(MEANING
                ,1
                ,50)
        INTO SORT_BY_MEANING
        FROM
          OE_LOOKUPS
        WHERE LOOKUP_TYPE = 'OEXOEORD ORDER BY'
          AND LOOKUP_CODE = 'RETURN_NUMBER';
      END IF;
      RETURN (TRUE);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN (FALSE);
    END;
    RETURN (TRUE);
  END P_ORDER_BYVALIDTRIGGER;

  FUNCTION P_ITEM_DISPLAYVALIDTRIGGER RETURN BOOLEAN IS
  BEGIN
    RETURN NULL;
  END P_ITEM_DISPLAYVALIDTRIGGER;

  FUNCTION AMT_EXPECTEDFORMULA(QTY_AUTHORIZED IN NUMBER
                              ,SELLING_PRICE IN NUMBER
                              ,CURRENCY_CODE IN VARCHAR2) RETURN NUMBER IS
  BEGIN
    DECLARE
      L_STD_PRECISION NUMBER;
      L_EXT_PRECISION NUMBER;
      L_MIN_ACCT_UNIT NUMBER;
      L_AMT_EXPECTED NUMBER;
    BEGIN
      /*SRW.REFERENCE(QTY_AUTHORIZED)*/NULL;
      /*SRW.REFERENCE(SELLING_PRICE)*/NULL;
      /*SRW.REFERENCE(P_MIN_PRECISION)*/NULL;
      /*SRW.REFERENCE(CURRENCY_CODE)*/NULL;
      /*SRW.REFERENCE(RP_CURR_PROFILE)*/NULL;
      FND_CURRENCY.GET_INFO(CURRENCY_CODE
                           ,L_STD_PRECISION
                           ,L_EXT_PRECISION
                           ,L_MIN_ACCT_UNIT);
      L_AMT_EXPECTED := NVL(QTY_AUTHORIZED
                           ,0) * NVL(SELLING_PRICE
                           ,0);
      IF (RP_CURR_PROFILE = 'EXTENDED') THEN
        L_AMT_EXPECTED := ROUND(L_AMT_EXPECTED
                               ,L_EXT_PRECISION);
      ELSE
        L_AMT_EXPECTED := ROUND(L_AMT_EXPECTED
                               ,L_STD_PRECISION);
      END IF;
      RETURN (L_AMT_EXPECTED);
    EXCEPTION
      WHEN OTHERS THEN
        RETURN NULL;
    END;
  END AMT_EXPECTEDFORMULA;

  FUNCTION AMT_RECEIVEDFORMULA(QTY_RECEIVED IN NUMBER
                              ,SELLING_PRICE IN NUMBER
                              ,CURRENCY_CODE IN VARCHAR2) RETURN NUMBER IS
  BEGIN
    DECLARE
      L_STD_PRECISION NUMBER;
      L_EXT_PRECISION NUMBER;
      L_MIN_ACCT_UNIT NUMBER;
      L_AMT_RECEIVED NUMBER;
    BEGIN
      /*SRW.REFERENCE(QTY_RECEIVED)*/NULL;
      /*SRW.REFERENCE(P_MIN_PRECISION)*/NULL;
      /*SRW.REFERENCE(SELLING_PRICE)*/NULL;
      /*SRW.REFERENCE(CURRENCY_CODE)*/NULL;
      /*SRW.REFERENCE(RP_CURR_PROFILE)*/NULL;
      FND_CURRENCY.GET_INFO(CURRENCY_CODE
                           ,L_STD_PRECISION
                           ,L_EXT_PRECISION
                           ,L_MIN_ACCT_UNIT);
      L_AMT_RECEIVED := NVL(QTY_RECEIVED
                           ,0) * NVL(SELLING_PRICE
                           ,0);
      IF (RP_CURR_PROFILE = 'EXTENDED') THEN
        L_AMT_RECEIVED := ROUND(L_AMT_RECEIVED
                               ,L_EXT_PRECISION);
      ELSE
        L_AMT_RECEIVED := ROUND(L_AMT_RECEIVED
                               ,L_STD_PRECISION);
      END IF;
      RETURN (L_AMT_RECEIVED);
    EXCEPTION
      WHEN OTHERS THEN
        RETURN NULL;
    END;
  END AMT_RECEIVEDFORMULA;

  FUNCTION AMT_ACCEPTEDFORMULA(QTY_ACCEPTED IN NUMBER
                              ,SELLING_PRICE IN NUMBER
                              ,CURRENCY_CODE IN VARCHAR2) RETURN NUMBER IS
  BEGIN
    DECLARE
      L_STD_PRECISION NUMBER;
      L_EXT_PRECISION NUMBER;
      L_MIN_ACCT_UNIT NUMBER;
      L_AMT_ACCEPTED NUMBER;
    BEGIN
      /*SRW.REFERENCE(QTY_ACCEPTED)*/NULL;
      /*SRW.REFERENCE(P_MIN_PRECISION)*/NULL;
      /*SRW.REFERENCE(SELLING_PRICE)*/NULL;
      /*SRW.REFERENCE(CURRENCY_CODE)*/NULL;
      /*SRW.REFERENCE(RP_CURR_PROFILE)*/NULL;
      FND_CURRENCY.GET_INFO(CURRENCY_CODE
                           ,L_STD_PRECISION
                           ,L_EXT_PRECISION
                           ,L_MIN_ACCT_UNIT);
      L_AMT_ACCEPTED := NVL(QTY_ACCEPTED
                           ,0) * NVL(SELLING_PRICE
                           ,0);
      IF (RP_CURR_PROFILE = 'EXTENDED') THEN
        L_AMT_ACCEPTED := ROUND(L_AMT_ACCEPTED
                               ,L_EXT_PRECISION);
      ELSE
        L_AMT_ACCEPTED := ROUND(L_AMT_ACCEPTED
                               ,L_STD_PRECISION);
      END IF;
      RETURN (L_AMT_ACCEPTED);
    EXCEPTION
      WHEN OTHERS THEN
        RETURN NULL;
    END;
  END AMT_ACCEPTEDFORMULA;

  FUNCTION P_CREDIT_ONLYVALIDTRIGGER RETURN BOOLEAN IS
  BEGIN
    BEGIN
      IF (P_CREDIT_ONLY IS NOT NULL) THEN
        SELECT
          SUBSTR(MEANING
                ,1
                ,5)
        INTO CREDIT_ONLY_MEANING
        FROM
          FND_LOOKUPS
        WHERE LOOKUP_TYPE = 'YES_NO'
          AND LOOKUP_CODE = SUBSTR(UPPER(P_CREDIT_ONLY)
              ,1
              ,1);
      END IF;
      RETURN (TRUE);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN (FALSE);
    END;
    RETURN (TRUE);
  END P_CREDIT_ONLYVALIDTRIGGER;

  FUNCTION REF_NUMFORMULA(REF_ID IN VARCHAR2
                         ,REF_TYPE_CODE IN VARCHAR2
                         ,LINE_ID IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      REF_NUMBER VARCHAR2(240);
    BEGIN
      IF (REF_ID IS NOT NULL) THEN
        IF (REF_TYPE_CODE = 'INVOICE') THEN
          SELECT
            TRX.TRX_NUMBER
          INTO REF_NUMBER
          FROM
            RA_CUSTOMER_TRX TRX,
            RA_CUSTOMER_TRX_LINES_ALL TRXL
          WHERE TRXL.CUSTOMER_TRX_LINE_ID = REF_ID
            AND TRXL.CUSTOMER_TRX_ID = TRX.CUSTOMER_TRX_ID;
        ELSIF (REF_TYPE_CODE = 'SERIAL') THEN
          SELECT
            L2.RETURN_ATTRIBUTE2
          INTO REF_NUMBER
          FROM
            OE_ORDER_LINES_ALL L2
          WHERE L2.LINE_ID = LINE_ID;
        ELSIF (REF_TYPE_CODE = 'ORDER') THEN
          SELECT
            OH2.ORDER_NUMBER
          INTO REF_NUMBER
          FROM
            OE_ORDER_HEADERS OH2
          WHERE OH2.HEADER_ID = REF_ID;
        ELSIF (REF_TYPE_CODE = 'PO') THEN
          SELECT
            OH2.CUST_PO_NUMBER
          INTO REF_NUMBER
          FROM
            OE_ORDER_HEADERS OH2
          WHERE OH2.HEADER_ID = REF_ID;
        END IF;
      END IF;
      RETURN (REF_NUMBER);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN (NULL);
    END;
    RETURN NULL;
  END REF_NUMFORMULA;

  FUNCTION C_TOTAL_RMAFORMULA(TOTAL_RMA IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (TOTAL_RMA);
  END C_TOTAL_RMAFORMULA;

  FUNCTION C_TOTAL_LINESFORMULA(TOTAL_LINES IN NUMBER) RETURN NUMBER IS
  BEGIN
    RETURN (TOTAL_LINES);
  END C_TOTAL_LINESFORMULA;

  FUNCTION C_MASTER_ORGFORMULA RETURN NUMBER IS
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

  FUNCTION RP_ITEM_FLEX_ALL_SEG_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_ITEM_FLEX_ALL_SEG;
  END RP_ITEM_FLEX_ALL_SEG_P;

  FUNCTION RP_PRINT_DESCRIPTION_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_PRINT_DESCRIPTION;
  END RP_PRINT_DESCRIPTION_P;

  FUNCTION RP_OPEN_RETURNS_ONLY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_OPEN_RETURNS_ONLY;
  END RP_OPEN_RETURNS_ONLY_P;

  FUNCTION RP_CURR_PROFILE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_CURR_PROFILE;
  END RP_CURR_PROFILE_P;

  FUNCTION ITEM_DSPFORMULA(ITEM_IDENTIFIER_TYPE IN VARCHAR2,INVENTORY_ITEM_ID1 IN NUMBER,ORDERED_ITEM_ID IN NUMBER,ORDERED_ITEM IN VARCHAR2,C_ORGANIZATION_ID IN VARCHAR2,C_INVENTORY_ITEM_ID IN VARCHAR2) RETURN CHAR IS
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
    where    nvl(sitems.organization_id,0) = NVL(OE_SYS_PARAMETERS.VALUE('MASTER_ORGANIZATION_ID',MO_GLOBAL.GET_CURRENT_ORG_ID),0)
    and    sitems.inventory_item_id = inventory_item_id1;
    v_item := fnd_flex_xml_publisher_apis.process_kff_combination_1('Item_dsp', 'INV', p_item_flex_code, p_item_structure_num, C_ORGANIZATION_ID, C_INVENTORY_ITEM_ID, 'ALL', 'Y', 'VALUE');

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
    and    nvl(sitems.organization_id,0) = NVL(OE_SYS_PARAMETERS.VALUE('MASTER_ORGANIZATION_ID',MO_GLOBAL.GET_CURRENT_ORG_ID),0)
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
    and    nvl(sitems.organization_id,0) = NVL(OE_SYS_PARAMETERS.VALUE('MASTER_ORGANIZATION_ID',MO_GLOBAL.GET_CURRENT_ORG_ID),0)
    and    sitems.inventory_item_id = inventory_item_id1
--Bug 3433353 Start
    and items.org_independent_flag = 'N'
    and items.organization_id = NVL(OE_SYS_PARAMETERS.VALUE('MASTER_ORGANIZATION_ID',MO_GLOBAL.GET_CURRENT_ORG_ID),0);
--    and    sitems.customer_order_enabled_flag = 'Y'
--    and    sitems.bom_item_type in (1,4)
   Exception When NO_DATA_FOUND Then
   Select items.cross_reference item,
   nvl(items.description,sitems.description) description into
   v_item,v_description
   from mtl_cross_reference_types xtypes,
   mtl_cross_references items,
   mtl_system_items_vl sitems
   where xtypes.cross_reference_type =
   items.cross_reference_type
   and items.inventory_item_id =
   sitems.inventory_item_id
   and items.cross_reference = ordered_item
   and items.cross_reference_type = item_identifier_type
   and nvl(sitems.organization_id,0) = NVL(OE_SYS_PARAMETERS.VALUE('MASTER_ORGANIZATION_ID',MO_GLOBAL.GET_CURRENT_ORG_ID),0)
   and sitems.inventory_item_id = inventory_item_id1
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


END ONT_OEXOEORD_XMLP_PKG;


/
