--------------------------------------------------------
--  DDL for Package Body AP_APXT7INE_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_APXT7INE_XMLP_PKG" AS
/* $Header: APXT7INEB.pls 120.0 2007/12/27 08:36:59 vjaganat noship $ */

FUNCTION  get_base_curr_data  RETURN BOOLEAN IS

  base_curr ap_system_parameters.base_currency_code%TYPE;   prec      fnd_currencies_vl.precision%TYPE;       min_au    fnd_currencies_vl.minimum_accountable_unit%TYPE;  descr     fnd_currencies_vl.description%TYPE;
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
          fnd_currencies_vl c
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


/*C_NLS_NO_DATA_EXISTS := '*** '||C_NLS_NO_DATA_EXISTS||' ***';
C_NLS_END_OF_REPORT  := '*** '||C_NLS_END_OF_REPORT||' ***';*/

C_NLS_NO_DATA_EXISTS := 'No Data Found';
C_NLS_END_OF_REPORT  := 'End of Report';

RETURN (TRUE);

RETURN NULL; EXCEPTION
   WHEN OTHERS THEN
      RETURN (FALSE);
END;

function BeforeReport return boolean is
begin

LP_START_DATE := to_char(P_START_DATE, 'DD-MON-YYYY');
LP_END_DATE := to_char(P_END_DATE, 'DD-MON-YYYY');

DECLARE

  init_failure    EXCEPTION;
  l_combined_flag varchar2(1);
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


  SELECT nvl(combined_filing_flag,'N')
  INTO l_combined_flag
  FROM ap_system_parameters;

  C_COMBINED_FILING := l_combined_flag;

  IF (p_debug_switch in ('y','Y')) THEN
     /*SRW.BREAK;*/null;

  END IF;

  IF (get_balancing_segment_column() <> TRUE) then
	raise init_failure;
  END IF;

  IF (get_entity_name() <> TRUE) then
	raise init_failure;
  END IF;

  RETURN (TRUE);

EXCEPTION

  WHEN   OTHERS  THEN
    RAISE_application_error(-20101,null);/*SRW.PROGRAM_ABORT;*/null;

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

Function Get_Balancing_segment_column Return BOOLEAN IS

Begin

	SELECT  fnd.application_column_name
        INTO    p_balancing_segment_column
        FROM    fnd_segment_attribute_values fnd,
                gl_sets_of_books gl
        WHERE   fnd.attribute_value='Y'
        AND     fnd.segment_attribute_type = 'GL_BALANCING'
        AND     fnd.id_flex_num = gl.chart_of_accounts_id
        AND     fnd.id_flex_code = 'GL#'
        AND     gl.set_of_books_id = p_set_of_books_id;

        return(TRUE);

RETURN NULL; EXCEPTION
	WHEN OTHERS THEN
		RETURN(FALSE);

END;

Function Get_Entity_name Return BOOLEAN IS

Begin

	SELECT  entity_name
        INTO    p_entity_name
        FROM    ap_reporting_entities
        WHERE   tax_entity_id = p_rep_entity_id;

        return(TRUE);

RETURN NULL; EXCEPTION
	WHEN OTHERS THEN
		RETURN(FALSE);

END;

function c_count_invoice_exceptionformu(c_count_no_type in number, c_count_non_1099 in number, c_count_null_region in number) return number is
begin

 return (c_count_no_type + c_count_non_1099 + c_count_null_region);
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
 /*Function Applications Template Report_p return varchar2 is
	Begin
	 return Applications Template Report;
	 END;*/

 Function Applications_Template_Report_p return varchar2 is
 	Begin
 	 return Applications_Template_Report;
	 END;
 Function C_COMBINED_FILING_p return varchar2 is
	Begin
	 return C_COMBINED_FILING;
	 END;
END AP_APXT7INE_XMLP_PKG ;


/
