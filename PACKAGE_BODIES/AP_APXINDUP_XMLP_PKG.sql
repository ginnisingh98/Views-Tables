--------------------------------------------------------
--  DDL for Package Body AP_APXINDUP_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_APXINDUP_XMLP_PKG" AS
/* $Header: APXINDUPB.pls 120.0 2007/12/27 07:53:06 vjaganat noship $ */
FUNCTION  get_base_curr_data  RETURN BOOLEAN IS
  base_curr ap_system_parameters.base_currency_code%TYPE;
  prec      fnd_currencies_vl.precision%TYPE;
  min_au    fnd_currencies_vl.minimum_accountable_unit%TYPE;
 descr     fnd_currencies_vl.description%TYPE;
 l_org_id  ap_system_parameters.org_id%TYPE;
BEGIN
  base_curr := '';
  prec      := 0;
  min_au    := 0;
  descr     := '';
  SELECT  p.base_currency_code,
          c.precision,
          c.minimum_accountable_unit,
	  NVL(p.org_id,-99),	          c.description
  INTO    base_curr,
          prec,
          min_au,
	  l_org_id,	          descr
  FROM    ap_system_parameters p,
          fnd_currencies_vl c
  WHERE   p.base_currency_code  = c.currency_code;
  c_base_currency_code  := base_curr;
  c_base_precision      := prec;
  c_base_min_acct_unit  := min_au;
  c_base_description    := descr;
  c_org_id		 := l_org_id;
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
   nls_all       ap_lookup_codes.displayed_field%TYPE;    nls_yes       fnd_lookups.meaning%TYPE;     nls_no        fnd_lookups.meaning%TYPE;
BEGIN
   nls_all     := '';
   nls_yes     := '';
   nls_no      := '';
   SELECT  ly.meaning,
           ln.meaning,
           la.displayed_field
   INTO    nls_yes,  nls_no,  nls_all
   FROM    fnd_lookups ly,  fnd_lookups ln,  ap_lookup_codes la
   WHERE   ly.lookup_type = 'YES_NO'
     AND   ly.lookup_code = 'Y'
     AND   ln.lookup_type = 'YES_NO'
     AND   ln.lookup_code = 'N'
     AND   la.lookup_type = 'NLS REPORT PARAMETER'
     AND   la.lookup_code = 'ALL';
   c_nls_yes := nls_yes;
   c_nls_no  := nls_no;
   c_nls_all := nls_all;
   /*SRW.USER_EXIT('FND MESSAGE_NAME APPL="SQLAP" NAME="AP_APPRVL_NO_DATA"');*/null;
   /*SRW.USER_EXIT('FND MESSAGE_GET OUTPUT_FIELD=":c_nls_no_data_exists"');*/null;
   /*c_nls_no_data_exists := '*** '||c_nls_no_data_exists||' ***';*/
   c_nls_no_data_exists := 'No Data Found';
   /*SRW.USER_EXIT('FND MESSAGE_NAME APPL="SQLAP" NAME="AP_ALL_END_OF_REPORT"');*/null;
   /*SRW.USER_EXIT('FND MESSAGE_GET OUTPUT_FIELD=":c_nls_end_of_report"');*/null;
   /*c_nls_end_of_report := '*** '||c_nls_end_of_report||' ***';*/
   c_nls_end_of_report := 'End of Report';
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
P_AUDIT_BEGIN_1 := to_char(P_AUDIT_BEGIN,'DD-MON-YY');
P_AUDIT_END_1	:= to_char(P_AUDIT_END,'DD-MON-YY');
P_COMPARE_BEGIN_1	:= to_char(P_COMPARE_BEGIN,'DD-MON-YY');
P_COMPARE_END_1	:= to_char(P_COMPARE_END,'DD-MON-YY');
  /*srw.reference(C_vendor_name_predicate);*/null;
  /*srw.reference(C_vendor_type_predicate);*/null;
If (p_vendor_name is not null) Then
    Select vendor_name into p_vendor_name_out
    From PO_VENDORS
    where vendor_id = p_vendor_name;
  End if;
  /*SRW.USER_EXIT('FND SRWINIT');*/null;
  IF (p_debug_switch = 'Y') THEN
     /*SRW.MESSAGE('1','After SRWINIT');*/null;
  END IF;
  IF (get_company_name() <> TRUE) THEN       RAISE init_failure;
  END IF;
  IF (p_debug_switch = 'Y') THEN
     /*SRW.MESSAGE('2','After Get_Company_Name');*/null;
  END IF;
  IF (get_nls_strings() <> TRUE) THEN      RAISE init_failure;
  END IF;
  IF (p_debug_switch = 'Y') THEN
     /*SRW.MESSAGE('3','After Get_NLS_Strings');*/null;
  END IF;
  IF (get_base_curr_data() <> TRUE) THEN        RAISE init_failure;
  ELSE	       if(c_org_id<>-99) then
    	P_ORG_COND:=' AND i1.org_id='||c_org_id||' and i2.org_id='||c_org_id;
     end if;
  END IF;
  IF (p_debug_switch = 'Y') THEN
     /*SRW.MESSAGE('4','After Get_Base_Curr_Data');*/null;
  END IF;
  IF (p_debug_switch = 'Y') THEN
     /*SRW.BREAK;*/null;
  END IF;
  RETURN (TRUE);
EXCEPTION
  WHEN   OTHERS  THEN
    RAISE_application_error(-20101,null);/*SRW.PROGRAM_ABORT;*/null;
END;  return (TRUE);
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
  l_sob_id                NUMBER;
  l_report_start_date     DATE;
BEGIN
  l_report_start_date := sysdate;   l_sob_id := p_set_of_books_id;
  SELECT  name,
          chart_of_accounts_id
  INTO    l_name,
          l_chart_of_accounts_id
  FROM    gl_sets_of_books
  WHERE   set_of_books_id = l_sob_id;
  c_company_name_header     := l_name;
  c_chart_of_accounts_id    := l_chart_of_accounts_id;
  c_report_start_date       := l_report_start_date;
  RETURN (TRUE);
RETURN NULL; EXCEPTION
  WHEN   OTHERS  THEN
    RETURN (FALSE);
END;
FUNCTION get_flexdata RETURN BOOLEAN IS
BEGIN
 null;
   RETURN (TRUE);
RETURN NULL; EXCEPTION
   WHEN OTHERS THEN
        RETURN(FALSE);
END;
function C_VENDOR_TYPE_PREDICATEFormula return VARCHAR2 is
begin
if P_VENDOR_TYPE is not null then
  return('AND V.vendor_type_lookup_code = '''||P_VENDOR_TYPE||'''');
end if;
--Commented By Raj
--RETURN NULL; end;
RETURN ' '; end;
function C_VENDOR_NAME_PREDICATEFormula return VARCHAR2 is
begin
if P_VENDOR_NAME is not null then
  return('AND V.vendor_id = '||to_char(P_VENDOR_NAME));
end if;
--Commented By Raj
--RETURN NULL; end;
RETURN ' '; end;
function CF_INV_DATE_COMPFormula return Char is
l_comp_inv_date		fnd_lookups.meaning%TYPE;
l_lookup_code		fnd_lookups.lookup_type%TYPE;
begin
  select meaning into l_comp_inv_date
  from fnd_lookups
    where lookup_type = 'YES_NO'
    and lookup_code = p_inv_date_comp;
  return(l_comp_inv_date);
end;
--Functions to refer Oracle report placeholders--
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
 Function C_COMPANY_NAME_HEADER_p return varchar2 is
	Begin
	 return C_COMPANY_NAME_HEADER;
	 END;
 Function C_REPORT_START_DATE_p return date is
	Begin
	 return C_REPORT_START_DATE;
	 END;
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
 Function C_CHART_OF_ACCOUNTS_ID_p return number is
	Begin
	 return C_CHART_OF_ACCOUNTS_ID;
	 END;
 Function C_NLS_END_OF_REPORT_p return varchar2 is
	Begin
	 return C_NLS_END_OF_REPORT;
	 END;
 Function C_ORG_ID_p return number is
	Begin
	 return C_ORG_ID;
	 END;
END AP_APXINDUP_XMLP_PKG ;



/
