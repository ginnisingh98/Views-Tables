--------------------------------------------------------
--  DDL for Package Body ONT_OEXOEUBD_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_OEXOEUBD_XMLP_PKG" AS
/* $Header: OEXOEUBDB.pls 120.1 2007/12/25 07:26:50 npannamp noship $ */
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
      SELECT
        MEANING
      INTO LP_ORDER_BY_MEAN
      FROM
        OE_LOOKUPS
      WHERE LOOKUP_CODE = UPPER(P_ORDER_BY)
        AND LOOKUP_TYPE = 'ONT_OEXOEUBD_XMLP_PKG SORT BY';
      IF (UPPER(P_ORDER_BY) = 'CREATED_BY') THEN
        LP_ORDER_BY := 'order by 5,2,1';
      ELSIF (UPPER(P_ORDER_BY) = 'MANAGER') THEN
        LP_ORDER_BY := 'order by 4,2,1';
      ELSIF (SUBSTR(UPPER(P_ORDER_BY)
            ,1
            ,1) = 'O') THEN
        LP_ORDER_BY := 'ORDER BY 10 ASC,order_number';
        --LP_ORDER_BY := 'ORDER BY 10 ASC,16 ASC, 1,2,3,4,5,6,7,8,15,9';
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        LP_ORDER_BY_MEAN := P_ORDER_BY;
    END;
    BEGIN
      IF (P_ORDER_DATE_LOW IS NOT NULL) AND (P_ORDER_DATE_HIGH IS NOT NULL) THEN
        LP_ORDER_DATE := 'and h.ordered_date between :P_order_date_low and (:P_order_date_high) + 1';
      ELSIF (P_ORDER_DATE_LOW IS NOT NULL) THEN
        LP_ORDER_DATE := 'and h.ordered_date >= :P_order_date_low';
      ELSIF (P_ORDER_DATE_HIGH IS NOT NULL) THEN
        LP_ORDER_DATE := 'and h.ordered_date  <= (:P_order_date_high) + 1';
      END IF;
    END;
    BEGIN
      IF (P_CREATED_BY_LOW IS NOT NULL) AND (P_CREATED_BY_HIGH IS NOT NULL) THEN
        LP_CREATED_BY := 'and fu.user_name between :P_created_by_low and :P_created_by_high ';
      ELSIF (P_CREATED_BY_LOW IS NOT NULL) THEN
        LP_CREATED_BY := 'and fu.user_name >= :P_created_by_low ';
      ELSIF (P_CREATED_BY_HIGH IS NOT NULL) THEN
        LP_CREATED_BY := 'and fu.user_name <= :P_created_by_high ';
      END IF;
    END;
    BEGIN
      IF (P_MANAGER_LOW IS NOT NULL) AND (P_MANAGER_HIGH IS NOT NULL) THEN
        LP_MANAGER := 'and ppf_mgr.email_address between :p_manager_low and :p_manager_high ';
      ELSIF (P_MANAGER_LOW IS NOT NULL) THEN
        LP_MANAGER := 'and ppf_mgr.email_address >= :p_manager_low ';
      ELSIF (P_MANAGER_HIGH IS NOT NULL) THEN
        LP_MANAGER := 'and ppf_mgr.email_address <= :p_manager_high ';
      END IF;
    END;
    BEGIN
      IF (P_ORDER_TYPE_LOW IS NOT NULL) AND (P_ORDER_TYPE_HIGH IS NOT NULL) THEN
        LP_ORDER_TYPE := 'and ( ot.transaction_type_id between :p_order_type_low and :p_order_type_high ) ';
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
      ELSIF (P_ORDER_TYPE_LOW IS NOT NULL) THEN
        LP_ORDER_TYPE := 'and ot.transaction_type_id >= :p_order_type_low ';
        SELECT
          OEOT.NAME
        INTO L_ORDER_TYPE_LOW
        FROM
          OE_TRANSACTION_TYPES_TL OEOT
        WHERE OEOT.TRANSACTION_TYPE_ID = P_ORDER_TYPE_LOW
          AND OEOT.LANGUAGE = USERENV('LANG');
      ELSIF (P_ORDER_TYPE_HIGH IS NOT NULL) THEN
        LP_ORDER_TYPE := 'and ot.transaction_type_id <= :p_order_type_high ';
        SELECT
          OEOT.NAME
        INTO L_ORDER_TYPE_HIGH
        FROM
          OE_TRANSACTION_TYPES_TL OEOT
        WHERE OEOT.TRANSACTION_TYPE_ID = P_ORDER_TYPE_HIGH
          AND OEOT.LANGUAGE = USERENV('LANG');
      END IF;
    END;
    BEGIN
      IF (P_USE_FUNCTIONAL_CURRENCY = 'Y') THEN
        L_USE_FUNCTIONAL_CURRENCY := 'Yes';
      ELSIF (P_USE_FUNCTIONAL_CURRENCY = 'N') THEN
        L_USE_FUNCTIONAL_CURRENCY := 'No';
      END IF;
    END;
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION RP_ORDER_CATEGORYFORMULA RETURN VARCHAR2 IS
  BEGIN
    RETURN NULL;
  END RP_ORDER_CATEGORYFORMULA;

  FUNCTION RP_LINE_CATEGORYFORMULA RETURN VARCHAR2 IS
  BEGIN
    RETURN NULL;
  END RP_LINE_CATEGORYFORMULA;

  FUNCTION C_LINE_AMTFORMULA(TRANSACTIONAL_CURR_CODE IN VARCHAR2
                            ,LINE_AMT IN NUMBER
                            ,CONVERSION_TYPE_CODE IN VARCHAR2
                            ,ORDERED_DATE IN DATE
                            ,CONVERSION_RATE IN NUMBER) RETURN NUMBER IS
  BEGIN
    DECLARE
      L_CONVERSION_RATE NUMBER(15,3);
    BEGIN
      /*SRW.REFERENCE(TRANSACTIONAL_CURR_CODE)*/NULL;
      /*SRW.REFERENCE(RP_FUNCTIONAL_CURRENCY)*/NULL;
      /*SRW.REFERENCE(LINE_AMT)*/NULL;
      /*SRW.REFERENCE(CONVERSION_TYPE_CODE)*/NULL;
      /*SRW.REFERENCE(ORDERED_DATE)*/NULL;
      L_CONVERSION_RATE := 0;
      IF P_USE_FUNCTIONAL_CURRENCY = 'N' THEN
        RETURN (NVL(LINE_AMT
                  ,0));
      ELSIF P_USE_FUNCTIONAL_CURRENCY = 'Y' THEN
        IF TRANSACTIONAL_CURR_CODE = RP_FUNCTIONAL_CURRENCY THEN
          L_CONVERSION_RATE := 1;
        ELSE
          IF CONVERSION_RATE IS NULL THEN
            L_CONVERSION_RATE := GL_CURRENCY_API.GET_RATE(P_SOB_ID
                                                         ,TRANSACTIONAL_CURR_CODE
                                                         ,ORDERED_DATE
                                                         ,CONVERSION_TYPE_CODE);
          ELSE
            L_CONVERSION_RATE := CONVERSION_RATE;
          END IF;
        END IF;
        RETURN (NVL(L_CONVERSION_RATE
                  ,0) * NVL(LINE_AMT
                  ,0));
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN (0);
      WHEN OTHERS THEN
        RETURN (0);
    END;
  END C_LINE_AMTFORMULA;

  FUNCTION C_PRECISIONFORMULA(TRANSACTIONAL_CURR_CODE IN VARCHAR2) RETURN NUMBER IS
  BEGIN
    DECLARE
      W_PRECISION NUMBER;
    BEGIN
      SELECT
        PRECISION
      INTO W_PRECISION
      FROM
        FND_CURRENCIES
      WHERE CURRENCY_CODE = TRANSACTIONAL_CURR_CODE;
      RETURN (W_PRECISION);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        W_PRECISION := 2;
        RETURN (W_PRECISION);
    END;
    RETURN NULL;
  END C_PRECISIONFORMULA;

  FUNCTION C_RECUR_CHARGESFORMULA(CHARGE_PERIODICITY_CODE IN VARCHAR2) RETURN CHAR IS
    L_UOM_CLASS VARCHAR2(50) := FND_PROFILE.VALUE('ONT_UOM_CLASS_CHARGE_PERIODICITY');
    L_CHARGE_PERIODICITY VARCHAR2(25);
  BEGIN
    IF CHARGE_PERIODICITY_CODE IS NOT NULL THEN
      SELECT
        UNIT_OF_MEASURE
      INTO L_CHARGE_PERIODICITY
      FROM
        MTL_UNITS_OF_MEASURE_VL
      WHERE UOM_CODE = CHARGE_PERIODICITY_CODE
        AND UOM_CLASS = L_UOM_CLASS;
      RETURN L_CHARGE_PERIODICITY;
    ELSE
      RETURN (P_ONE_TIME);
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
  END C_RECUR_CHARGESFORMULA;

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

  FUNCTION RP_C_EXT_TOTAL_ROUNDED_P RETURN NUMBER IS
  BEGIN
    RETURN RP_C_EXT_TOTAL_ROUNDED;
  END RP_C_EXT_TOTAL_ROUNDED_P;

  FUNCTION RP_C_RECUR_CHARGE_ROUNDED_P RETURN NUMBER IS
  BEGIN
    RETURN RP_C_RECUR_CHARGE_ROUNDED;
  END RP_C_RECUR_CHARGE_ROUNDED_P;

  function BeforeReport return boolean is
  begin

  --ADDED AS FIX TO IMPLEMENT UNCONVERTED FORMAT TRIGGER
  F_Periodicity := OE_Sys_Parameters.Value('RECURRING_CHARGES',mo_global.get_current_org_id());
  --added for proper date formats
  P_ORDER_DATE_LOW_V:=to_char(P_ORDER_DATE_LOW,'DD-MON-YY');
  P_ORDER_DATE_HIGH_V:=to_char(P_ORDER_DATE_HIGH,'DD-MON-YY');


  DECLARE
  BEGIN

    /*BEGIN
    --SRW.USER_EXIT('FND SRWINIT');
    EXCEPTION
       WHEN SRW.USER_EXIT_FAILURE THEN
  	SRW.MESSAGE (1000,'Failed in BEFORE REPORT trigger');
       return (FALSE);
    END;*/


  BEGIN  /*MOAC*/

  --P_ORGANIZATION_ID:= MO_GLOBAL.GET_CURRENT_ORG_ID();
  P_ORGANIZATION_ID_V:= MO_GLOBAL.GET_CURRENT_ORG_ID();

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
        THEN RP_REPORT_NAME := 'Unbooked Orders Detail Report';
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
    END;*/


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
    --srw.message(2000,'Failed in BEFORE REPORT trigger. Get Print Description');
    null;

    END ;




  /*------------------------------------------------------------------------------
  THE Following PL/SQL block populates the order_date_range and created_by range
  parameters used in the report margins
  ------------------------------------------------------------------------------*/
  DECLARE
     l_created_by_low    VARCHAR2(50);
     l_manager_low        VARCHAR2(50);

  BEGIN
  	if (P_created_by_low is NOT NULL OR P_created_by_high is NOT NULL) then
  	  if (P_created_by_low is NULL) then
  	    l_created_by_low := '     ';
             else l_created_by_low := P_created_by_low;
  	  end if;
  	  lp_created_by_range := 'From '||l_Created_by_low||' To '||P_created_by_high;
  	end if;

         if (p_manager_low is NOT NULL OR P_manager_high is NOT NULL) then
  	  if (p_manager_low is NULL) then
  	    l_manager_low := '     ';
            else l_manager_low := p_manager_low;
  	  end if;
  	  lp_manager_range := 'Manager From '||l_manager_low||' To '||P_manager_high;
  	end if;

  	if (P_order_date_low is NOT NULL OR P_order_date_high is NOT NULL) then
  	  lp_order_date_range := 'From '||nvl(to_char(P_order_date_low, 'DD-MON-RRRR'), '     ')
             || ' To ' ||nvl(to_char(P_order_date_high, 'DD-MON-RRRR'), '     ');
   	end if;
    END;

    DECLARE
        l_order_type_low             VARCHAR2 (50);
        l_order_type_high            VARCHAR2 (50);
    BEGIN

    if ( p_order_type_low is NULL) AND ( p_order_type_high is NULL ) then
      NULL ;
    else
      if p_order_type_low is NULL then
        l_order_type_low := '   ';
      else
        l_order_type_low := substr(l_order_type_low ,1,18);
      end if ;
      if p_order_type_high is NULL then
        l_order_type_high := '   ';
      else
        l_order_type_high := substr(l_order_type_high,1,18);
      end if ;
      lp_order_type_range  := 'Order Type From '||l_order_type_low||' To '||l_order_type_high ;

    end if ;
   END;


  END ;
    return (TRUE);
end;

END ONT_OEXOEUBD_XMLP_PKG;



/
