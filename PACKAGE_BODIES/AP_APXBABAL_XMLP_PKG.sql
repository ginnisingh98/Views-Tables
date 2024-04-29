--------------------------------------------------------
--  DDL for Package Body AP_APXBABAL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_APXBABAL_XMLP_PKG" AS
/* $Header: APXBABALB.pls 120.0 2007/12/27 07:27:12 vjaganat noship $ */

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

  c_base_currency_code  := base_curr;
  c_base_precision      := prec;
  c_base_min_acct_unit  := min_au;
  c_base_description    := descr;

  RETURN (TRUE);

RETURN NULL;

EXCEPTION

  WHEN   OTHERS  THEN
    RETURN (FALSE);

END;

FUNCTION  custom_init         RETURN BOOLEAN IS

BEGIN
select 	recon_accounting_flag
into 	C_RECON_ACCOUNTING
from 	ap_system_parameters;

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
   nls_all       ap_lookup_codes.displayed_field%TYPE;    nls_ba_par    ap_lookup_codes.displayed_field%TYPE;
   nls_yes       fnd_lookups.meaning%TYPE;     nls_no        fnd_lookups.meaning%TYPE;
BEGIN

   nls_all     := '';
   nls_ba_par  := '';
   nls_yes     := '';
   nls_no      := '';

   SELECT  ly.meaning,
           ln.meaning,
           l1.displayed_field,
           l2.displayed_field
   INTO    nls_yes,  nls_no,  nls_all, nls_ba_par
   FROM    fnd_lookups ly,  fnd_lookups ln,
	   ap_lookup_codes l1, ap_lookup_codes l2
   WHERE   ly.lookup_type = 'YES_NO'
     AND   ly.lookup_code = 'Y'
     AND   ln.lookup_type = 'YES_NO'
     AND   ln.lookup_code = 'N'
     AND   l1.lookup_type = 'NLS REPORT PARAMETER'
     AND   l1.lookup_code = 'ALL'
     AND   l2.lookup_type = 'ACTIVE_OPTIONS'
     AND   upper(l2.lookup_code) = upper(P_BANK_ACCOUNT_PAR);

   c_nls_yes 		:= nls_yes;
   c_nls_no  		:= nls_no;
   c_nls_all 		:= nls_all;
   c_nls_ba_par 	:= nls_ba_par;

   /*SRW.USER_EXIT('FND MESSAGE_NAME APPL ="SQLAP" NAME="AP_APPRVL_NO_DATA"');*/null;

   /*SRW.USER_EXIT('FND MESSAGE_GET OUTPUT_FIELD=":c_nls_no_data_exists"');*/null;

   /*SRW.MESSAGE('999', c_nls_no_data_exists);*/null;

   c_nls_no_data_exists := '*** '||c_nls_no_data_exists||' ***';

   /*SRW.USER_EXIT('FND MESSAGE_NAME APPL="SQLAP" NAME="AP_ALL_END_OF_REPORT"');*/null;

   /*SRW.USER_EXIT('FND MESSAGE_GET OUTPUT_FIELD=":c_nls_end_of_report"');*/null;

   /*SRW.MESSAGE('999', c_nls_end_of_report);*/null;

   c_nls_end_of_report := '*** '||c_nls_end_of_report||' ***';

RETURN (TRUE);

RETURN NULL; EXCEPTION
   WHEN OTHERS THEN
   /*srw.message(999,sqlerrm);*/null;

      RETURN (FALSE);
END;

function BeforeReport return boolean is
begin



DECLARE

  init_failure    EXCEPTION;

BEGIN

  LP_EFFECTIVE_DATE:=to_char(P_EFFECTIVE_DATE,'DD-MON-YY');


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
  END IF;
  IF (p_debug_switch = 'Y') THEN
     /*SRW.MESSAGE('4','After Get_Base_Curr_Data');*/null;

  END IF;













   IF (get_flexdata() <> TRUE) THEN
      RAISE init_failure;
   END IF;
   IF (p_debug_switch = 'Y') THEN
      /*SRW.MESSAGE ('6', 'After Get_Flexdata');*/null;

   END IF;
  IF (get_flexdata2() <> TRUE) THEN
      RAISE init_failure;
   END IF;
   IF (p_debug_switch = 'Y') THEN
      /*SRW.MESSAGE ('6', 'After Get_Flexdata2');*/null;

   END IF;




    IF(custom_init() <> TRUE) THEN
      RAISE init_failure;
    END IF;
    IF (p_debug_switch = 'Y') THEN
       /*SRW.MESSAGE('7','After Custom_Init');*/null;

    END IF;




  IF (p_debug_switch = 'Y') THEN
     /*SRW.BREAK;*/null;

  END IF;



  RETURN (TRUE);



EXCEPTION

  WHEN   OTHERS  THEN

   /* RAISE_application_error(-20101,null);SRW.PROGRAM_ABORT;*/
   null;


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

FUNCTION calculate_run_time RETURN BOOLEAN IS
end_date   DATE;
start_date DATE;
BEGIN
end_date   := sysdate;
start_date := C_REPORT_START_DATE;
C_REPORT_RUN_TIME := to_char(to_date('01/01/0001','DD/MM/YYYY') + ((end_date - start_date)),'HH24:MI:SS');
RETURN(TRUE);
RETURN NULL; EXCEPTION
WHEN OTHERS THEN
RAISE_application_error(-20101,null);/*SRW.PROGRAM_ABORT;*/null;

END;

FUNCTION get_flexdata2 RETURN BOOLEAN IS
BEGIN



 null;
   RETURN (TRUE);

RETURN NULL; EXCEPTION
   WHEN OTHERS THEN
        RETURN(FALSE);
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
 Function C_NLS_BA_PAR_p return varchar2 is
	Begin
	 return C_NLS_BA_PAR;
	 END;
 Function C_NLS_END_OF_REPORT_p return varchar2 is
	Begin
	 return C_NLS_END_OF_REPORT;
	 END;
 Function C_RECON_ACCOUNTING_p return varchar2 is
	Begin
	 return C_RECON_ACCOUNTING;
	 END;
END AP_APXBABAL_XMLP_PKG ;


/
