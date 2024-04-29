--------------------------------------------------------
--  DDL for Package Body AP_APXMTDTR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_APXMTDTR_XMLP_PKG" AS
/* $Header: APXMTDTRB.pls 120.0 2007/12/27 08:14:08 vjaganat noship $ */

FUNCTION  get_base_curr_data  RETURN BOOLEAN IS

  base_curr ap_system_parameters.base_currency_code%TYPE;   prec      fnd_currencies.precision%TYPE;       min_au    fnd_currencies.minimum_accountable_unit%TYPE;  descr     fnd_currencies.description%TYPE;
BEGIN

  base_curr := '';
  prec      := 0;
  min_au    := 0;
  descr     := '';

  SELECT  p.base_currency_code,
          c.precision,
          c.minimum_accountable_unit,
          c.description
  INTO    base_curr,
          prec,
          min_au,
          descr
  FROM    ap_system_parameters p,
          fnd_currencies c
  WHERE   p.base_currency_code  = c.currency_code;

  C_BASE_CURRENCY_CODE  := base_curr;
  C_BASE_PRECISION      := prec;
  C_BASE_MIN_ACCT_UNIT  := min_au;
  C_BASE_DESCRIPTION    := descr;

  RETURN (TRUE);

RETURN NULL; EXCEPTION

  WHEN   OTHERS  THEN
    RETURN (FALSE);

END;

FUNCTION  custom_init         RETURN BOOLEAN IS

BEGIN


RETURN (TRUE);

RETURN NULL; EXCEPTION

  WHEN   OTHERS  THEN
    RETURN (FALSE);

END;

FUNCTION  get_cover_page_values   RETURN BOOLEAN IS

BEGIN

RETURN(TRUE);

RETURN NULL; EXCEPTION
WHEN OTHERS THEN
  RETURN(FALSE);

END;

FUNCTION  get_nls_strings     RETURN BOOLEAN IS
   nls_void      ap_lookup_codes.displayed_field%TYPE;    nls_na        ap_lookup_codes.displayed_field%TYPE;    nls_all       ap_lookup_codes.displayed_field%TYPE;    nls_yes       fnd_lookups.meaning%TYPE;     nls_no        fnd_lookups.meaning%TYPE;
BEGIN

   SELECT  ly.meaning,
           ln.meaning,
           l1.displayed_field,
           l2.displayed_field,
           l3.displayed_field
   INTO    nls_yes,
	   nls_no,
	   nls_all,
	   nls_void,
	   nls_na
   FROM    fnd_lookups ly,
	   fnd_lookups ln,
	   ap_lookup_codes l1,
	   ap_lookup_codes l2,
	   ap_lookup_codes l3
   WHERE   ly.lookup_type = 'YES_NO'
     AND   ly.lookup_code = 'Y'
     AND   ln.lookup_type = 'YES_NO'
     AND   ln.lookup_code = 'N'
     AND   l1.lookup_type = 'NLS REPORT PARAMETER'
     AND   l1.lookup_code = 'ALL'
     AND   l2.lookup_type = 'NLS TRANSLATION'
     AND   l2.lookup_code = 'VOID'
     AND   l3.lookup_type = 'NLS REPORT PARAMETER'
     AND   l3.lookup_code = 'NA';

   C_NLS_YES 	:= nls_yes;
   C_NLS_NO  	:= nls_no;
   C_NLS_ALL 	:= nls_all;
   C_NLS_VOID  := nls_void;
   C_NLS_NA	:= nls_na;



/*srw.user_exit('FND MESSAGE_NAME APPL="SQLAP" NAME="AP_APPRVL_NO_DATA"');*/null;

/*srw.user_exit('FND MESSAGE_GET OUTPUT_FIELD=":C_NLS_NO_DATA_EXISTS"');*/null;

/*srw.user_exit('FND MESSAGE_NAME APPL="SQLAP" NAME="AP_ALL_END_OF_REPORT"');*/null;

/*srw.user_exit('FND MESSAGE_GET OUTPUT_FIELD=":C_NLS_END_OF_REPORT"');*/null;


C_NLS_NO_DATA_EXISTS := 'No Data Found';
C_NLS_END_OF_REPORT  := 'End of Report';

RETURN (TRUE);

RETURN NULL; EXCEPTION
   WHEN OTHERS THEN
      RETURN (FALSE);
END;

function BeforeReport return boolean is
begin



DECLARE

  init_failure    EXCEPTION;

BEGIN


  C_REPORT_START_DATE := sysdate;




  /*SRW.USER_EXIT('FND SRWINIT');*/null;

  IF (p_debug_switch in ('y','Y')) THEN
     /*SRW.MESSAGE('1','After SRWINIT');*/null;

  END IF;




  IF (get_company_name() <> TRUE) THEN       RAISE init_failure;
  END IF;
  IF (p_debug_switch in ('y','Y')) THEN
     /*SRW.MESSAGE('2','After Get_Company_Name');*/null;

  END IF;



  IF (get_nls_strings() <> TRUE) THEN      RAISE init_failure;
  END IF;
  IF (p_debug_switch in ('y','Y')) THEN
     /*SRW.MESSAGE('3','After Get_NLS_Strings');*/null;

  END IF;



  IF (get_base_curr_data() <> TRUE) THEN        RAISE init_failure;
  END IF;
  IF (p_debug_switch in ('y','Y')) THEN
     /*SRW.MESSAGE('4','After Get_Base_Curr_Data');*/null;

  END IF;


  LP_PO_RELEASE_ID := 'AND 1=1 ';
  IF(p_po_release_id IS NOT NULL) THEN
    LP_PO_RELEASE_ID := 'AND PR.po_release_id = '||to_char(p_po_release_id) ;
  END IF;













   IF (get_flexdata() <> TRUE) THEN
      RAISE init_failure;
   END IF;
   IF (p_debug_switch in ('y','Y')) THEN
      /*SRW.MESSAGE ('6', 'After Get_Flexdata');*/null;

   END IF;

   IF (get_flexdata3() <> TRUE) THEN
      RAISE init_failure;
   END IF;
   IF (p_debug_switch in ('y','Y')) THEN
      /*SRW.MESSAGE ('6', 'After Get_Flexdata3');*/null;

   END IF;

   IF (get_flexdata4() <> TRUE) THEN
      RAISE init_failure;
   END IF;
   IF (p_debug_switch in ('y','Y')) THEN
      /*SRW.MESSAGE ('6', 'After Get_Flexdata4');*/null;

   END IF;














  IF (p_debug_switch in ('y','Y')) THEN
     /*SRW.BREAK;*/null;

  END IF;



  RETURN (TRUE);



EXCEPTION

  WHEN   OTHERS  THEN

  /*  RAISE_application_error(-20101,null);SRW.PROGRAM_ABORT;*/null;


END;
  return (TRUE);
end;

function AfterReport return boolean is
begin

BEGIN
   /*SRW.USER_EXIT('FND SRWEXIT');*/null;

   IF (P_DEBUG_SWITCH = 'Y') THEN
      /*SRW.MESSAGE('20','After SRWEXIT');*/null;

   END IF;
EXCEPTION
WHEN OTHERS THEN
   RAISE_application_error(-20101,null);/*SRW.PROGRAM_ABORT;*/null;

END;  return (TRUE);
end;

FUNCTION  get_company_name    RETURN BOOLEAN IS
  l_chart_of_accounts_id  gl_sets_of_books.chart_of_accounts_id%TYPE;
  l_name                  gl_sets_of_books.name%TYPE;
  l_sob_id		  number;
BEGIN

  if P_SET_OF_BOOKS_ID is not null then
     l_sob_id := p_set_of_books_id;
     SELECT  name,
             chart_of_accounts_id
     INTO    l_name,
             l_chart_of_accounts_id
     FROM    gl_sets_of_books
     WHERE   set_of_books_id = l_sob_id;

     c_company_name_header     := l_name;
     c_chart_of_accounts_id    := l_chart_of_accounts_id;

  end if;

  RETURN (TRUE);

RETURN NULL; EXCEPTION

  WHEN   OTHERS  THEN
    RETURN (FALSE);

END;

FUNCTION get_flexdata RETURN BOOLEAN IS

BEGIN

   if C_CHART_OF_ACCOUNTS_ID is not null then

 null;
      return (TRUE);
   else
      /*SRW.MESSAGE('999','Cannot use flex API without a chart of accounts ID.');*/null;

      return(FALSE);
   end if;

RETURN NULL; EXCEPTION
   WHEN OTHERS THEN
        RETURN(FALSE);
END;

FUNCTION get_flexdata3 RETURN BOOLEAN IS

BEGIN

   if C_CHART_OF_ACCOUNTS_ID is not null then

 null;
      return (TRUE);
   else
      /*SRW.MESSAGE('999','Cannot use flex API without a chart of accounts ID.');*/null;

      return(FALSE);
   end if;

RETURN NULL; EXCEPTION
   WHEN OTHERS THEN
        RETURN(FALSE);
END;

FUNCTION get_flexdata4 RETURN BOOLEAN IS

BEGIN

   if C_CHART_OF_ACCOUNTS_ID is not null then

 null;
      return (TRUE);
   else
      /*SRW.MESSAGE('999','Cannot use flex API without a chart of accounts ID.');*/null;

      return(FALSE);
   end if;

RETURN NULL; EXCEPTION
   WHEN OTHERS THEN
        RETURN(FALSE);
END;

function c_po_price_roundformula(C_PO_PRICE in number, C_CURRENCY_CODE in varchar2) return number is
begin
  /*SRW.REFERENCE(C_PO_PRICE);*/null;

return(ap_utilities_pkg.ap_round_currency(C_PO_PRICE,C_CURRENCY_CODE));
end;

function c_po_price1_roundformula(C_PO_PRICE1 in number, C_PO_CURRENCY_CODE in varchar2) return number is
begin
  /*SRW.REFERENCE(C_PO_PRICE1);*/null;

return(ap_utilities_pkg.ap_round_currency(C_PO_PRICE1,C_PO_CURRENCY_CODE));
end;

function cf_exchange_rate_type_desc_inv(c_exchange_rate_type in varchar2) return char is

l_exchange_rate_type_desc varchar2(30);

begin

  if c_exchange_rate_type is not null then
    select substr(user_conversion_type,1,16) user_conversion_type
    into l_exchange_rate_type_desc
    from gl_daily_conversion_types
    where conversion_type = c_exchange_rate_type;
  end if;

  return (l_exchange_rate_type_desc);
end;

function cf_rate_type_desc_poformula(c_rate_type in varchar2) return char is

l_rate_type_desc_po varchar2(30);

begin

  if c_rate_type is not null then
    select substr(user_conversion_type,1,16) user_conversion_type
    into l_rate_type_desc_po
    from gl_daily_conversion_types
    where conversion_type = c_rate_type;
  end if;

  return (l_rate_type_desc_po);
end;

function cf_exchange_rate_type_desc_rec(c_exchange_rate_type1 in varchar2) return char is

l_exchange_rate_type_desc_rec varchar2(30);

begin

  if c_exchange_rate_type1 is not null then
    select substr(user_conversion_type,1,30) user_conversion_type
    into l_exchange_rate_type_desc_rec
    from gl_daily_conversion_types
    where conversion_type = c_exchange_rate_type1;
  end if;

  return (l_exchange_rate_type_desc_rec);
end;

--Functions to refer Oracle report placeholders--

 Function C_NLS_YES_p return varchar2 is
	Begin
	 return C_NLS_YES;
	 END;
 Function C_NLS_NO_p return varchar2 is
	Begin
	 return C_NLS_NO;
	 END;
 Function C_NLS_ALL_p return varchar2 is
	Begin
	 return C_NLS_ALL;
	 END;
 Function C_NLS_NO_DATA_EXISTS_p return varchar2 is
	Begin
	 return C_NLS_NO_DATA_EXISTS;
	 END;
 Function C_NLS_VOID_p return varchar2 is
	Begin
	 return C_NLS_VOID;
	 END;
 Function C_NLS_NA_p return varchar2 is
	Begin
	 return C_NLS_NA;
	 END;
 Function C_NLS_END_OF_REPORT_p return varchar2 is
	Begin
	 return C_NLS_END_OF_REPORT;
	 END;
 Function C_REPORT_START_DATE_p return date is
	Begin
	 return C_REPORT_START_DATE;
	 END;
 Function C_COMPANY_NAME_HEADER_p return varchar2 is
	Begin
	 return C_COMPANY_NAME_HEADER;
	 END;
 Function C_BASE_CURRENCY_CODE_p return varchar2 is
	Begin
	 return C_BASE_CURRENCY_CODE;
	 END;
 Function C_BASE_PRECISION_p return number is
	Begin
	 return C_BASE_PRECISION;
	 END;
 Function C_BASE_MIN_ACCT_UNIT_p return number is
	Begin
	 return C_BASE_MIN_ACCT_UNIT;
	 END;
 Function C_BASE_DESCRIPTION_p return varchar2 is
	Begin
	 return C_BASE_DESCRIPTION;
	 END;
 Function C_CHART_OF_ACCOUNTS_ID_p return number is
	Begin
	 return C_CHART_OF_ACCOUNTS_ID;
	 END;
 --Function Applications Template Report_p return varchar2 is
   Function Applications_Template_Report_p return varchar2 is
	Begin
	 --return Applications Template Report;
	   return Applications_Template_Report;
	 END;
END AP_APXMTDTR_XMLP_PKG ;


/
