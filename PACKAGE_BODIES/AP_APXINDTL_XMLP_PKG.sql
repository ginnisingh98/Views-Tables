--------------------------------------------------------
--  DDL for Package Body AP_APXINDTL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_APXINDTL_XMLP_PKG" AS
/* $Header: APXINDTLB.pls 120.0 2007/12/27 07:51:32 vjaganat noship $ */
FUNCTION  get_base_curr_data  RETURN BOOLEAN IS
  base_curr ap_system_parameters.base_currency_code%TYPE;   prec      fnd_currencies_vl.precision%TYPE;       min_au    fnd_currencies_vl.minimum_accountable_unit%TYPE;  descr     fnd_currencies_vl.description%TYPE;
BEGIN
  prec      := 0;
  min_au    := 0;
  descr     := '';
  SELECT  c.precision,
          c.minimum_accountable_unit,
          c.description
  INTO    prec,
          min_au,
          descr
  FROM    ap_system_parameters p,
          fnd_currencies_vl c
  WHERE   p.base_currency_code  = c.currency_code;
  c_base_precision      := prec;
  c_base_min_acct_unit  := min_au;
  c_base_description    := descr;
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
   c_nls_no_data_exists := '*** '||c_nls_no_data_exists||' ***';
   /*SRW.USER_EXIT('FND MESSAGE_NAME APPL="SQLAP" NAME="AP_ALL_END_OF_REPORT"');*/null;
   /*SRW.USER_EXIT('FND MESSAGE_GET OUTPUT_FIELD=":c_nls_end_of_report"');*/null;
   c_nls_end_of_report := '*** '||c_nls_end_of_report||' ***';
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
  P_START_DATE1 := to_char(P_START_DATE,'DD-MON-YY');
    P_END_DATE1 := to_char(P_END_DATE,'DD-MON-YY');
   P_VENDOR_TYPE_LOOKUP_CODE_1 := P_VENDOR_TYPE_LOOKUP_CODE;
  /*SRW.USER_EXIT('FND SRWINIT');*/null;
  IF (p_debug_switch = 'Y') THEN
     /*SRW.MESSAGE('1','After SRWINIT');*/null;
  END IF;
  IF p_vendor_type_lookup_code is null then
     p_vendor_type_lookup_code_1 := 'All';
  END IF;
  IF (set_dynamic_where() <> TRUE) THEN       RAISE init_failure;
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
  l_base_curr_code        ap_system_parameters.base_currency_code%TYPE;
BEGIN
  l_report_start_date := sysdate;   l_sob_id := p_set_of_books_id;
  SELECT  gl.name,
          gl.chart_of_accounts_id,
          p.base_currency_code
  INTO    l_name,
          l_chart_of_accounts_id,
          l_base_curr_code
  FROM    gl_sets_of_books gl, ap_system_parameters p
  WHERE   gl.set_of_books_id = l_sob_id;
  c_company_name_header     := l_name;
  c_chart_of_accounts_id    := l_chart_of_accounts_id;
  c_report_start_date       := l_report_start_date;
  c_base_currency_code      := l_base_curr_code;
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
FUNCTION  get_nls_vendor_type  RETURN BOOLEAN IS
  l_nls_vndr_type_lkup_code po_lookup_codes.displayed_field%TYPE;
BEGIN
  SELECT  plc.displayed_field
  INTO    l_nls_vndr_type_lkup_code
  FROM    po_lookup_codes plc
  WHERE   plc.lookup_type = 'VENDOR TYPE'
  AND     plc.lookup_code = p_vendor_type_lookup_code;
  c_nls_vndr_type_lkup_code     := l_nls_vndr_type_lkup_code;
  RETURN (TRUE);
RETURN NULL; EXCEPTION
  WHEN   OTHERS  THEN
    RETURN (FALSE);
END;
function c_allcurr_dscnt_amt_tknformula(C_SMRY_CURRENCY in varchar2, C_SMRY_DSCNT_AMT_TAKEN in number, C_SMRY_BASE_CURR_DTKN in number) return number is
begin
if C_BASE_CURRENCY_CODE = C_SMRY_CURRENCY then
   return(C_SMRY_DSCNT_AMT_TAKEN);
else
   return(C_SMRY_BASE_CURR_DTKN);
end if;
RETURN NULL; end;
function c_allcurr_inv_amtformula(C_SMRY_CURRENCY in varchar2, C_SMRY_INVOICE_AMOUNT in number, C_SMRY_BASE_CURR_AMT in number) return number is
begin
if C_BASE_CURRENCY_CODE = C_SMRY_CURRENCY then
return(C_SMRY_INVOICE_AMOUNT);
else
return(C_SMRY_BASE_CURR_AMT);
end if;
RETURN NULL; end;
function c_allcurr_dscnt_amt_lostformul(C_SMRY_CURRENCY in varchar2, C_SMRY_DSCNT_AMT_LOST in number, C_SMRY_BASE_CURR_DLST in number) return number is
begin
if C_BASE_CURRENCY_CODE = C_SMRY_CURRENCY then
return(C_SMRY_DSCNT_AMT_LOST);
else
return(C_SMRY_BASE_CURR_DLST);
end if;
RETURN NULL; end;
function c_allcurr_no_rate_cntformula(C_SMRY_CURRENCY in varchar2, C_SMRY_NO_RATE_COUNT in number) return number is
begin
if C_BASE_CURRENCY_CODE = C_SMRY_CURRENCY then
   return(0);
else
   return(C_SMRY_NO_RATE_COUNT);
end if;
RETURN NULL; end;
function c_m_allcurr_inv_amtformula(C_CURRENCY in varchar2, C_INVOICE_AMOUNT in number, C_BASE_CURRENCY_AMOUNT in number) return number is
begin
if C_BASE_CURRENCY_CODE = C_CURRENCY then
   return(C_INVOICE_AMOUNT);
else
   return(C_BASE_CURRENCY_AMOUNT);
end if;
RETURN NULL; end;
function c_m_allcurr_dtkn_amtformula(C_CURRENCY in varchar2, C_DISCOUNT_AMOUNT_TAKEN in number, C_BASE_CURR_DISCNT_TAKEN in number) return number is
begin
if C_BASE_CURRENCY_CODE = C_CURRENCY then
   return(C_DISCOUNT_AMOUNT_TAKEN);
else
   return(C_BASE_CURR_DISCNT_TAKEN);
end if;
RETURN NULL; end;
function c_m_allcurr_dlst_amtformula(C_CURRENCY in varchar2, C_DISCOUNT_AMOUNT_LOST in number, C_BASE_CURR_DISCNT_LOST in number) return number is
begin
if C_BASE_CURRENCY_CODE = C_CURRENCY then
   return(C_DISCOUNT_AMOUNT_LOST);
else
   return(C_BASE_CURR_DISCNT_LOST);
end if;
RETURN NULL; end;
function c_m_allcurr_no_rate_cntformula(C_CURRENCY in varchar2, C_NO_RATE_COUNT in number) return number is
begin
if C_BASE_CURRENCY_CODE = C_CURRENCY then
   return(0);
else
   return(C_NO_RATE_COUNT);
end if;
RETURN NULL; end;
FUNCTION SET_DYNAMIC_WHERE RETURN BOOLEAN IS
l_vendor_id_pred  VARCHAR2(1000);
BEGIN
IF P_VENDOR_ID IS NOT NULL  THEN
   l_vendor_id_pred := 'AND v1.vendor_id = '||P_VENDOR_ID;
   ELSE
l_vendor_id_pred := 'and 1=1';
 END IF;
c_vendor_id_pred := l_vendor_id_pred;
RETURN(TRUE);
EXCEPTION
  WHEN OTHERS THEN
    RETURN(FALSE);
END;
FUNCTION SET_QUERY RETURN BOOLEAN IS
BEGIN
  if P_summary_option = 'Y' THEN
     /*srw.set_maxrow('Q_1',0);*/null;
  else
     /*srw.set_maxrow('Q_2',0);*/null;
  end if;
  return(TRUE);
END;
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
 Function C_REPORT_RUN_TIME_p return varchar2 is
	Begin
	 return C_REPORT_RUN_TIME;
	 END;
 Function C_CHART_OF_ACCOUNTS_ID_p return number is
	Begin
	 return C_CHART_OF_ACCOUNTS_ID;
	 END;
 Function C_NLS_VNDR_TYPE_LKUP_CODE_p return varchar2 is
	Begin
	 return C_NLS_VNDR_TYPE_LKUP_CODE;
	 END;
 Function C_NO_RATE_COUNT_SAME_CURR_p return number is
	Begin
	 return C_NO_RATE_COUNT_SAME_CURR;
	 END;
 Function C_NLS_END_OF_REPORT_p return varchar2 is
	Begin
	 return C_NLS_END_OF_REPORT;
	 END;
END AP_APXINDTL_XMLP_PKG ;


/
