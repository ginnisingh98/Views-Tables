--------------------------------------------------------
--  DDL for Package Body ONT_OEXOEORS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_OEXOEORS_XMLP_PKG" AS
/* $Header: OEXOEORSB.pls 120.3 2008/05/05 12:41:59 dwkrishn noship $ */

function BeforeReport return boolean is
begin

DECLARE
BEGIN
--added as fix
P_RETURN_DATE_LOW_V :=to_char(P_RETURN_DATE_LOW,'DD-MON-YY');
P_RETURN_DATE_HIGH_V :=to_char(P_RETURN_DATE_HIGH,'DD-MON-YY');
P_EXP_REC_DATE_LOW_V :=to_char(P_EXP_REC_DATE_LOW,'DD-MON-YY');
P_EXP_REC_DATE_HIGH_V :=to_char(P_EXP_REC_DATE_HIGH,'DD-MON-YY');

  BEGIN
  null;
  EXCEPTION
     --WHEN SRW.USER_EXIT_FAILURE THEN
     when others then
       null;
	--SRW.MESSAGE (1000,'Failed in BEFORE REPORT trigger');
     return (FALSE);
  END;

BEGIN

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

      RP_Report_Name := substr(RP_Report_Name,1,instr(RP_Report_Name,' (XML)'));
  EXCEPTION
      WHEN NO_DATA_FOUND
      THEN RP_REPORT_NAME := 'Credit Order Summary Report';
  END;

/*------------------------------------------------------------------------------
Following PL/SQL block builds up the lexical parameters, to be used in the
WHERE clause of the query. This also populates the report level variables, used
to store the flexfield structure.
------------------------------------------------------------------------------*/
  BEGIN
   -- SRW.REFERENCE(:P_item_flex_code);
   -- SRW.REFERENCE(:P_ITEM_STRUCTURE_NUM);

null;

   /* SRW.USER_EXIT('FND FLEXSQL CODE=":p_item_flex_code"
			   NUM=":p_item_structure_num"
			   APPL_SHORT_NAME="INV"
			   OUTPUT=":rp_item_flex_all_seg"
			   MODE="SELECT"
			   DISPLAY="ALL"
			   TABLEALIAS="SI"
			    ');*/

  EXCEPTION
    --WHEN SRW.USER_EXIT_FAILURE THEN
    --srw.message(2000,'Failed in BEFORE REPORT trigger. FND FLEXSQL USER_EXIT');
    when others then
     null;
  END;



  DECLARE
      l_return_date_low             VARCHAR2 (50);
      l_return_date_high            VARCHAR2 (50);
      l_exp_rec_date_low            VARCHAR2 (50);
      l_exp_rec_date_high           VARCHAR2 (50);
      l_return_number_low           VARCHAR2 (50);
      l_return_number_high          VARCHAR2 (50);
      l_customer_name_low           VARCHAR2 (50);
      l_customer_name_high          VARCHAR2 (50);
      l_customer_number_low         VARCHAR2 (50);
      l_customer_number_high        VARCHAR2 (50);

  BEGIN

  if ( p_return_date_low is NULL) AND ( p_return_date_high is NULL ) then
    NULL ;
  else
    if p_return_date_low is NULL then
      l_return_date_low := '   ';
    else
      l_return_date_low := to_char(p_return_date_low, 'DD-MON-RRRR');
    end if ;
    if p_return_date_high is NULL then
      l_return_date_high := '   ';
    else
      l_return_date_high := to_char(p_return_date_high, 'DD-MON-RRRR');
    end if ;
    rp_return_date_range  := 'From '||l_return_date_low||' To '||l_return_date_high ;

  end if ;


  if ( p_exp_rec_date_low is NULL) AND ( p_exp_rec_date_high is NULL ) then
    NULL ;
  else
    if p_exp_rec_date_low is NULL then
      l_exp_rec_date_low := '   ';
    else
      l_exp_rec_date_low := to_char(p_exp_rec_date_low, 'DD-MON-RRRR');
    end if ;
    if p_exp_rec_date_high is NULL then
      l_exp_rec_date_high := '   ';
    else
      l_exp_rec_date_high := to_char(p_exp_rec_date_high, 'DD-MON-RRRR');
    end if ;
    rp_exp_rec_date_range  := 'From '||l_exp_rec_date_low||' To '||l_exp_rec_date_high ;
  end if ;


  if ( p_return_num_low is NULL) AND ( p_return_num_high is NULL ) then
    NULL ;
  else
    if p_return_num_low is NULL then
      l_return_number_low := '   ';
    else
      l_return_number_low := substr(p_return_num_low,1,18) ;
    end if ;
    if p_return_num_high is NULL then
      l_return_number_high := '   ';
    else
      l_return_number_high := substr((p_return_num_high),1,18);
    end if ;
    rp_return_number_range  := 'From '||l_return_number_low||' To '||l_return_number_high ;
  end if ;


  if ( p_customer_number_low is NULL) AND ( p_customer_number_high is NULL ) then
    NULL ;
  else
    if p_customer_number_low is NULL then
      l_customer_number_low := '   ';
    else
      l_customer_number_low := substr(p_customer_number_low,1,18) ;
    end if ;
    if p_customer_number_high is NULL then
      l_customer_number_high := '   ';
    else
      l_customer_number_high := substr((p_customer_number_high),1,18);
    end if ;
    rp_cust_no_range  := 'From '||l_customer_number_low||' To '||l_customer_number_high ;
  end if ;


  if ( p_customer_name_low is NULL) AND ( p_customer_name_high is NULL ) then
    NULL ;
  else
    if p_customer_name_low is NULL then
      l_customer_name_low := '   ';
    else
      l_customer_name_low := substr(p_customer_name_low,1,18) ;
    end if ;
    if p_customer_name_high is NULL then
      l_customer_name_high := '   ';
    else
      l_customer_name_high := substr((p_customer_name_high),1,18);
    end if ;
    rp_cust_name_range  := 'From '||l_customer_name_low||' To '||l_customer_name_high ;
  end if ;


  END ;


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
    rp_print_description := 'Description';
  END ;

DECLARE
    l_meaning       VARCHAR2 (80);
  BEGIN
    SELECT MEANING
    INTO   l_meaning
    FROM OE_LOOKUPS
    WHERE LOOKUP_TYPE = 'YES_NO'
    AND LOOKUP_CODE  = substr(upper(p_open_returns_only),1,1)
    ;

    rp_open_returns_only := l_meaning ;
  EXCEPTION WHEN NO_DATA_FOUND THEN
    rp_open_returns_only := 'Yes';
  END ;

  DECLARE
     l_fc_display VARCHAR2(80);
  BEGIN
     select meaning
       into l_fc_display
       from oe_lookups
      where lookup_type='YES_NO'
	and lookup_code = p_use_functional_currency
	;

  rp_use_functional_currency := l_fc_display ;

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    NULL;
  END;

EXCEPTION WHEN OTHERS THEN
--  SRW.MESSAGE (4000, ' Error in Before Report Trigger');
null;

END ;
  return (TRUE);
end;
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

  FUNCTION P_ORGANIZATION_IDVALIDTRIGGER RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END P_ORGANIZATION_IDVALIDTRIGGER;

  FUNCTION P_ITEM_FLEX_CODEVALIDTRIGGER RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END P_ITEM_FLEX_CODEVALIDTRIGGER;

  FUNCTION P_SOB_IDVALIDTRIGGER RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END P_SOB_IDVALIDTRIGGER;

  FUNCTION P_USE_FUNCTIONAL_CURRENCYVALID RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END P_USE_FUNCTIONAL_CURRENCYVALID;

  FUNCTION C_ACTUAL_RECEIPT_DAYS(QTY_AUTHORIZED IN NUMBER
                                ,RECEIPT_DAYS IN NUMBER) RETURN NUMBER IS
    ACTUAL_DAYS NUMBER;
  BEGIN
    IF QTY_AUTHORIZED = 0 THEN
      ACTUAL_DAYS := 0;
    ELSE
      ACTUAL_DAYS := RECEIPT_DAYS;
    END IF;
    RETURN (ACTUAL_DAYS);
  END C_ACTUAL_RECEIPT_DAYS;

  FUNCTION C_ACTUAL_RETURN_DAYS(QTY_AUTHORIZED IN NUMBER
                               ,RETURN_DAYS IN NUMBER) RETURN NUMBER IS
    ACTUAL_DAYS NUMBER;
  BEGIN
    IF QTY_AUTHORIZED = 0 THEN
      ACTUAL_DAYS := 0;
    ELSE
      ACTUAL_DAYS := RETURN_DAYS;
    END IF;
    RETURN (ACTUAL_DAYS);
  END C_ACTUAL_RETURN_DAYS;

  FUNCTION AFTERPFORM RETURN BOOLEAN IS
  BEGIN
    /*SRW.MESSAGE(99999
               ,'$Header: OEXOEORSB.pls 120.3 2008/05/05 12:41:59 dwkrishn noship $')*/NULL;
    BEGIN
      IF (P_CUSTOMER_NAME_LOW IS NOT NULL) AND (P_CUSTOMER_NAME_HIGH IS NOT NULL) THEN
        LP_CUSTOMER_NAME := 'and ( PARTY.PARTY_NAME between :p_customer_name_low and :p_customer_name_high ) ';
      ELSIF (P_CUSTOMER_NAME_LOW IS NOT NULL) THEN
        LP_CUSTOMER_NAME := 'and PARTY.PARTY_NAME >= :p_customer_name_low ';
      ELSIF (P_CUSTOMER_NAME_HIGH IS NOT NULL) THEN
        LP_CUSTOMER_NAME := 'and PARTY.PARTY_NAME <= :p_customer_name_high ';
      END IF;
      IF (P_CUSTOMER_NUMBER_LOW IS NOT NULL) AND (P_CUSTOMER_NUMBER_HIGH IS NOT NULL) THEN
        LP_CUSTOMER_NUMBER := 'and ( CUST_ACCT.ACCOUNT_NUMBER between :p_customer_number_low and :p_customer_number_high ) ';
      ELSIF (P_CUSTOMER_NUMBER_LOW IS NOT NULL) THEN
        LP_CUSTOMER_NUMBER := 'and rac.customer_number >= :p_customer_number_low ';
        LP_CUSTOMER_NUMBER := 'and  CUST_ACCT.ACCOUNT_NUMBER >= :p_customer_number_low ';
      ELSIF (P_CUSTOMER_NUMBER_HIGH IS NOT NULL) THEN
        LP_CUSTOMER_NUMBER := 'and rac.customer_number <= :p_customer_number_high ';
        LP_CUSTOMER_NUMBER := 'and CUST_ACCT.ACCOUNT_NUMBER <= :p_customer_number_high ';
      END IF;
      IF (P_WAREHOUSE IS NOT NULL) THEN
        LP_WAREHOUSE := 'and wh.name = :p_warehouse ';
      END IF;
      IF (P_RETURN_TYPE IS NOT NULL) THEN
        LP_RETURN_TYPE := 'and otYPE.transaction_type_id = :p_return_type ';
        SELECT
          OEOT.NAME
        INTO L_ORDER_TYPE
        FROM
          OE_TRANSACTION_TYPES_TL OEOT
        WHERE OEOT.TRANSACTION_TYPE_ID = P_RETURN_TYPE
          AND OEOT.LANGUAGE = USERENV('LANG');
      END IF;
      IF (P_RETURN_LINE_TYPE IS NOT NULL) THEN
        LP_RETURN_LINE_TYPE := 'and ltYPE.transaction_type_id = :p_return_line_type ';
        SELECT
          OEOT.NAME
        INTO L_LINE_TYPE
        FROM
          OE_TRANSACTION_TYPES_TL OEOT
        WHERE OEOT.TRANSACTION_TYPE_ID = P_RETURN_LINE_TYPE
          AND OEOT.LANGUAGE = USERENV('LANG');
      END IF;
      IF (P_LINE_CATEGORY = 'CREDIT') OR (P_LINE_CATEGORY IS NULL) THEN
        LP_LINE_CATEGORY := 'and l.line_category_code = ''RETURN'' ';
      END IF;
      IF (P_RETURN_NUM_LOW IS NOT NULL) AND (P_RETURN_NUM_HIGH IS NOT NULL) THEN
        LP_RETURN_NUM := 'and ( h.order_number between to_number(:p_return_num_low) and to_number(:p_return_num_high)) ';
      ELSIF (P_RETURN_NUM_LOW IS NOT NULL) THEN
        LP_RETURN_NUM := 'and h.order_number >= to_number(:p_return_num_low) ';
      ELSIF (P_RETURN_NUM_HIGH IS NOT NULL) THEN
        LP_RETURN_NUM := 'and h.order_number <= to_number(:p_return_num_high) ';
      END IF;
      IF (P_EXP_REC_DATE_LOW IS NOT NULL) AND (P_EXP_REC_DATE_HIGH IS NOT NULL) THEN
        LP_EXP_REC_DATE := 'and  (l.request_date between :p_exp_rec_date_low and :p_exp_rec_date_high) ';
      ELSIF (P_EXP_REC_DATE_LOW IS NOT NULL) THEN
        LP_EXP_REC_DATE := 'and l.request_date  >= :p_exp_rec_date_low ';
      ELSIF (P_EXP_REC_DATE_HIGH IS NOT NULL) THEN
        LP_EXP_REC_DATE := 'and l.request_date  <= :p_exp_rec_date_high ';
      END IF;
      IF (P_RETURN_DATE_LOW IS NOT NULL) AND (P_RETURN_DATE_HIGH IS NOT NULL) THEN
        LP_RETURN_DATE := 'and  (h.ordered_date between :p_return_date_low and :p_return_date_high) ';
      ELSIF (P_RETURN_DATE_LOW IS NOT NULL) THEN
        LP_RETURN_DATE := 'and h.ordered_date  >= :p_return_date_low ';
      ELSIF (P_RETURN_DATE_HIGH IS NOT NULL) THEN
        LP_RETURN_DATE := 'and h.ordered_date  <= :p_return_date_high ';
      END IF;
      IF (P_RETURN_DAYS_LOW IS NOT NULL) AND (P_RETURN_DAYS_HIGH IS NOT NULL) THEN
        LP_RETURN_DAYS := 'and decode(l.line_category_code, ''ORDER'', 0, trunc(om_reports_common_pkg.oexoeors_get_workflow_date(l.line_id)) - trunc(h.ordered_date))  between :p_return_days_low and :p_return_days_high ';
      ELSIF (P_RETURN_DAYS_LOW IS NOT NULL) THEN
        LP_RETURN_DAYS := 'and decode(l.line_category_code, ''ORDER'', 0, trunc(om_reports_common_pkg.oexoeors_get_workflow_date(l.line_id)) - trunc(h.ordered_date)) >= :p_return_days_low ';
      ELSIF (P_RETURN_DAYS_HIGH IS NOT NULL) THEN
        LP_RETURN_DAYS := 'and decode(l.line_category_code, ''ORDER'', 0, trunc(om_reports_common_pkg.oexoeors_get_workflow_date(l.line_id)) - trunc(h.ordered_date)) <= :p_return_days_high ';
      END IF;
      IF (P_REC_DAYS_LOW IS NOT NULL) AND (P_REC_DAYS_HIGH IS NOT NULL) THEN
        LP_REC_DAYS := 'and decode(l.line_category_code, ''ORDER'', 0, trunc(om_reports_common_pkg.oexoeors_get_workflow_date(l.line_id)) - trunc(l.request_date))  between :p_rec_days_low and :p_rec_days_high ';
      ELSIF (P_REC_DAYS_LOW IS NOT NULL) THEN
        LP_REC_DAYS := 'and decode(l.line_category_code, ''ORDER'', 0, trunc(om_reports_common_pkg.oexoeors_get_workflow_date(l.line_id)) - trunc(l.request_date)) >= :p_rec_days_low ';
      ELSIF (P_REC_DAYS_HIGH IS NOT NULL) THEN
        LP_REC_DAYS := 'and decode(l.line_category_code, ''ORDER'', 0, trunc(om_reports_common_pkg.oexoeors_get_workflow_date(l.line_id)) - trunc(l.request_date)) <= :p_rec_days_high ';
      END IF;
      IF P_OPEN_RETURNS_ONLY = 'Y' THEN
        LP_OPEN_RETURNS_ONLY := 'and nvl(h.open_flag,''N'') = ''Y'' ';
      END IF;
    END;
    RETURN (TRUE);
  END AFTERPFORM;

  FUNCTION C_DATA_NOT_FOUNDFORMULA(CURRENCY2 IN VARCHAR2) RETURN NUMBER IS
  BEGIN
    RP_DATA_FOUND := CURRENCY2;
    RETURN (0);
  END C_DATA_NOT_FOUNDFORMULA;

  FUNCTION C_ORDER_COUNTFORMULA RETURN NUMBER IS
  BEGIN
    RETURN (1);
  END C_ORDER_COUNTFORMULA;

  FUNCTION RP_ORDER_BYFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      L_SORT_BY VARCHAR2(100);
    BEGIN
      SELECT
        MEANING
      INTO L_SORT_BY
      FROM
        OE_LOOKUPS
      WHERE LOOKUP_CODE = P_ORDER_BY
        AND LOOKUP_TYPE = 'OEXOEORS SORT BY';
      RETURN (L_SORT_BY);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN ('Customer');
    END;
    RETURN NULL;
  END RP_ORDER_BYFORMULA;

  FUNCTION C_MASTER_ORGFORMULA RETURN NUMBER IS
    V_MASTER_ORG VARCHAR2(20);
  BEGIN
    V_MASTER_ORG := NVL(OE_SYS_PARAMETERS.VALUE('MASTER_ORGANIZATION_ID'
                                               ,MO_GLOBAL.GET_CURRENT_ORG_ID)
                       ,0);
    RETURN V_MASTER_ORG;
  END C_MASTER_ORGFORMULA;

  FUNCTION RP_DUMMY_ITEM_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_DUMMY_ITEM;
  END RP_DUMMY_ITEM_P;

  FUNCTION C_AUTHORIZED_AMOUNT_P(currency2 varchar2,authorized_amount number,conversion_type_code varchar2,return_date date,conversion_rate number) RETURN NUMBER IS
  BEGIN
Declare
     l_conversion_rate number (15,3);
 BEGIN
  l_conversion_rate := 0 ;

 if P_USE_FUNCTIONAL_CURRENCY = 'N' then
   c_authorized_amount  := nvl (authorized_amount,0);
  /* srw.user_exit (
		   'FND FORMAT_CURRENCY
		    CODE=":CURRENCY2"
		    DISPLAY_WIDTH="11"
		    AMOUNT=":c_authorized_amount"
		    DISPLAY=":c_authorized_amount_dsp"
		    ');*/
   return (c_authorized_amount);
 end if ;


 IF p_use_functional_currency = 'Y' THEN
	 IF currency2 = rp_functional_currency then
	   l_conversion_rate := 1 ;
	 else
	   IF conversion_rate is null then
	      l_conversion_rate := gl_currency_api.get_rate (
                                        p_sob_id,
                                        currency2,
                                        return_date,
                                        conversion_type_code );
	   ELSE
	     l_conversion_rate :=conversion_rate ;
	   END IF;
	 END IF;

   c_authorized_amount := nvl (l_conversion_rate,0) * nvl ( authorized_amount,0);
 /*  srw.user_exit (
		   'FND FORMAT_CURRENCY
		    CODE=":RP_FUNCTIONAL_CURRENCY"
		    DISPLAY_WIDTH="11"
		    AMOUNT=":c_authorized_amount"
		    DISPLAY=":c_authorized_amount_dsp"
		    ');*/
   return (c_authorized_amount);

 END IF ;

/* EXCEPTION
 WHEN NO_DATA_FOUND THEN
   :c_authorized_amount := 0 ;

   return ('NO RATE');*/
 end;



  END C_AUTHORIZED_AMOUNT_P;

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

  FUNCTION RP_RETURN_NUMBER_RANGE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_RETURN_NUMBER_RANGE;
  END RP_RETURN_NUMBER_RANGE_P;

  FUNCTION RP_EXP_REC_DATE_RANGE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_EXP_REC_DATE_RANGE;
  END RP_EXP_REC_DATE_RANGE_P;

  FUNCTION RP_RETURN_DATE_RANGE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_RETURN_DATE_RANGE;
  END RP_RETURN_DATE_RANGE_P;

  FUNCTION RP_OPEN_RETURNS_ONLY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_OPEN_RETURNS_ONLY;
  END RP_OPEN_RETURNS_ONLY_P;

  FUNCTION RP_USE_FUNCTIONAL_CURRENCY_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_USE_FUNCTIONAL_CURRENCY;
  END RP_USE_FUNCTIONAL_CURRENCY_P;

  FUNCTION RP_CUST_NAME_RANGE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_CUST_NAME_RANGE;
  END RP_CUST_NAME_RANGE_P;

  FUNCTION RP_CUST_NO_RANGE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_CUST_NO_RANGE;
  END RP_CUST_NO_RANGE_P;

  FUNCTION IS_FIXED_RATE(X_FROM_CURRENCY IN VARCHAR2
                        ,X_TO_CURRENCY IN VARCHAR2
                        ,X_EFFECTIVE_DATE IN DATE) RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
    /*STPROC.INIT('begin :X0 := GL_CURRENCY_API.IS_FIXED_RATE(:X_FROM_CURRENCY, :X_TO_CURRENCY, :X_EFFECTIVE_DATE); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(X_FROM_CURRENCY);
    STPROC.BIND_I(X_TO_CURRENCY);
    STPROC.BIND_I(X_EFFECTIVE_DATE);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/null;
    RETURN X0;
  END IS_FIXED_RATE;

  PROCEDURE GET_RELATION(X_FROM_CURRENCY IN VARCHAR2
                        ,X_TO_CURRENCY IN VARCHAR2
                        ,X_EFFECTIVE_DATE IN DATE
                        ,X_FIXED_RATE IN OUT NOCOPY BOOLEAN
                        ,X_RELATIONSHIP IN OUT NOCOPY VARCHAR2) IS
  BEGIN
   /* STPROC.INIT('declare X_FIXED_RATE BOOLEAN; begin X_FIXED_RATE := sys.diutil.int_to_bool(:X_FIXED_RATE); GL_CURRENCY_API.GET_RELATION(:X_FROM_CURRENCY, :X_TO_CURRENCY,
   :X_EFFECTIVE_DATE, X_FIXED_RATE, :X_RELATIONSHIP); :X_FIXED_RATE := sys.diutil.bool_to_int(X_FIXED_RATE); end;');
    STPROC.BIND_IO(X_FIXED_RATE);
    STPROC.BIND_I(X_FROM_CURRENCY);
    STPROC.BIND_I(X_TO_CURRENCY);
    STPROC.BIND_I(X_EFFECTIVE_DATE);
    STPROC.BIND_IO(X_RELATIONSHIP);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X_FIXED_RATE);
    STPROC.RETRIEVE(5
                   ,X_RELATIONSHIP);*/null;
  END GET_RELATION;

  FUNCTION GET_EURO_CODE RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
    /*STPROC.INIT('begin :X0 := GL_CURRENCY_API.GET_EURO_CODE; end;');
    STPROC.BIND_O(X0);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/
    RETURN X0;
  END GET_EURO_CODE;

  FUNCTION GET_RATE(X_FROM_CURRENCY IN VARCHAR2
                   ,X_TO_CURRENCY IN VARCHAR2
                   ,X_CONVERSION_DATE IN DATE
                   ,X_CONVERSION_TYPE IN VARCHAR2) RETURN NUMBER IS
    X0 NUMBER;
  BEGIN
  /*  STPROC.INIT('begin :X0 := GL_CURRENCY_API.GET_RATE(:X_FROM_CURRENCY, :X_TO_CURRENCY, :X_CONVERSION_DATE, :X_CONVERSION_TYPE); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(X_FROM_CURRENCY);
    STPROC.BIND_I(X_TO_CURRENCY);
    STPROC.BIND_I(X_CONVERSION_DATE);
    STPROC.BIND_I(X_CONVERSION_TYPE);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/
    RETURN X0;
  END GET_RATE;

  FUNCTION GET_RATE(X_SET_OF_BOOKS_ID IN NUMBER
                   ,X_FROM_CURRENCY IN VARCHAR2
                   ,X_CONVERSION_DATE IN DATE
                   ,X_CONVERSION_TYPE IN VARCHAR2) RETURN NUMBER IS
    X0 NUMBER;
  BEGIN
   /* STPROC.INIT('begin :X0 := GL_CURRENCY_API.GET_RATE(:X_SET_OF_BOOKS_ID, :X_FROM_CURRENCY, :X_CONVERSION_DATE, :X_CONVERSION_TYPE); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(X_SET_OF_BOOKS_ID);
    STPROC.BIND_I(X_FROM_CURRENCY);
    STPROC.BIND_I(X_CONVERSION_DATE);
    STPROC.BIND_I(X_CONVERSION_TYPE);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/
    RETURN X0;
  END GET_RATE;

  FUNCTION CONVERT_AMOUNT(X_FROM_CURRENCY IN VARCHAR2
                         ,X_TO_CURRENCY IN VARCHAR2
                         ,X_CONVERSION_DATE IN DATE
                         ,X_CONVERSION_TYPE IN VARCHAR2
                         ,X_AMOUNT IN NUMBER) RETURN NUMBER IS
    X0 NUMBER;
  BEGIN
   /* STPROC.INIT('begin :X0 := GL_CURRENCY_API.CONVERT_AMOUNT(:X_FROM_CURRENCY, :X_TO_CURRENCY, :X_CONVERSION_DATE, :X_CONVERSION_TYPE, :X_AMOUNT); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(X_FROM_CURRENCY);
    STPROC.BIND_I(X_TO_CURRENCY);
    STPROC.BIND_I(X_CONVERSION_DATE);
    STPROC.BIND_I(X_CONVERSION_TYPE);
    STPROC.BIND_I(X_AMOUNT);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/
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
                   ,X0);*/
    RETURN X0;
  END CONVERT_AMOUNT;

  FUNCTION GET_DERIVE_TYPE(SOB_ID IN NUMBER
                          ,PERIOD IN VARCHAR2
                          ,CURR_CODE IN VARCHAR2) RETURN VARCHAR2 IS
    X0 VARCHAR2(2000);
  BEGIN
  /*  STPROC.INIT('begin :X0 := GL_CURRENCY_API.GET_DERIVE_TYPE(:SOB_ID, :PERIOD, :CURR_CODE); end;');
    STPROC.BIND_O(X0);
    STPROC.BIND_I(SOB_ID);
    STPROC.BIND_I(PERIOD);
    STPROC.BIND_I(CURR_CODE);
    STPROC.EXECUTE;
    STPROC.RETRIEVE(1
                   ,X0);*/
    RETURN X0;
  END GET_DERIVE_TYPE;

FUNCTION ITEM_DSPFORMULA(ITEM_IDENTIFIER_TYPE IN VARCHAR2,INVENTORY_ITEM_ID1 IN NUMBER,ORDERED_ITEM_ID IN NUMBER,ORDERED_ITEM IN VARCHAR2,C_ORGANIZATION_ID IN VARCHAR2,C_INVENTORY_ITEM_ID IN VARCHAR2)  return Char is
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
    and    nvl(sitems.organization_id,0) = NVL(OE_SYS_PARAMETERS.VALUE('MASTER_ORGANIZATION_ID',MO_GLOBAL.GET_CURRENT_ORG_ID),0)
    and    sitems.inventory_item_id = inventory_item_id1;
    v_item :=fnd_flex_xml_publisher_apis.process_kff_combination_1('Item_dsp', 'INV', p_item_flex_code, p_item_structure_num, C_ORGANIZATION_ID, C_INVENTORY_ITEM_ID, 'ALL', 'Y', 'VALUE');
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
    -- Bug 3433353 Begin
    and   items.org_independent_flag ='N'
    and   items.organization_id = NVL(OE_SYS_PARAMETERS.VALUE('MASTER_ORGANIZATION_ID',MO_GLOBAL.GET_CURRENT_ORG_ID),0);
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
    and items.inventory_item_id = sitems.inventory_item_id
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

END ONT_OEXOEORS_XMLP_PKG;

/
