--------------------------------------------------------
--  DDL for Package Body AP_APXVCHCR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_APXVCHCR_XMLP_PKG" AS
/* $Header: APXVCHCRB.pls 120.1 2008/06/18 11:01:44 npannamp noship $ */

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
   nls_all       ap_lookup_codes.displayed_field%TYPE;    nls_yes       fnd_lookups.meaning%TYPE;     nls_no        fnd_lookups.meaning%TYPE;     l_nls_display_supp_address   fnd_lookups.meaning%TYPE;
   l_nls_zero_amt_option    fnd_lookups.meaning%TYPE;
   nls_none_ep    ap_lookup_codes.displayed_field%TYPE;

BEGIN

   nls_all     := '';
   nls_yes     := '';
   nls_no      := '';
   nls_none_ep := '';

   SELECT  ly.meaning,
           ln.meaning,
           la.displayed_field,
           lanep.displayed_field
   INTO    nls_yes,  nls_no,  nls_all, nls_none_ep
   FROM    fnd_lookups ly,  fnd_lookups ln,  ap_lookup_codes la,
           ap_lookup_codes lanep
   WHERE   ly.lookup_type = 'YES_NO'
     AND   ly.lookup_code = 'Y'
     AND   ln.lookup_type = 'YES_NO'
     AND   ln.lookup_code = 'N'
     AND   la.lookup_type = 'NLS REPORT PARAMETER'
     AND   la.lookup_code = 'ALL'
     AND   lanep.lookup_type = 'NLS TRANSLATION'
     AND   lanep.lookup_code = 'NONE ELECTRONIC PAYMENT';


   c_nls_yes := nls_yes;
   c_nls_no  := nls_no;
   c_nls_all := nls_all;
   c_nls_none_ep := nls_none_ep;



   SELECT meaning
   INTO   l_nls_display_supp_address
   FROM   fnd_lookups
   WHERE  lookup_type = 'YES_NO'
   AND    lookup_code = P_ADDRS_OPTION;

   C_NLS_ADDR_OPTION := l_nls_display_supp_address;


   SELECT meaning
   INTO   l_nls_zero_amt_option
   FROM   fnd_lookups
   WHERE  lookup_type = 'YES_NO'
   AND    lookup_code = P_INCLUDE_ZEROS;

   C_NLS_ZERO_AMT_OPTION := l_nls_zero_amt_option;


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

LP_START_DATE := to_char(P_START_DATE, 'DD-MON-YY');
LP_END_DATE := to_char(P_END_DATE, 'DD-MON-YY');

DECLARE

  init_failure    EXCEPTION;

BEGIN




  C_FIRST_REC := 'Y';

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






























  IF (get_date_option() <> TRUE) THEN        RAISE init_failure;
  END IF;

  if P_DATE_OPTION = 'Payment Date' then
     P_WHERE1 := ('where cpd.payment_document_id(+) = chk.payment_document_id
                   AND   chk.ce_bank_acct_use_id = cbau.bank_acct_use_id
                   AND   cbau.bank_account_id  =  ba.bank_account_id
                   AND   ba.bank_branch_id = bb.branch_party_id
                   AND   chk.void_date is not null
                   AND   decode('''||P_INCLUDE_ZEROS||''', ''N'', chk.amount,  1) <> 0
                   AND   chk.check_date BETWEEN ''' ||TO_CHAR(P_START_DATE,'DD-MON-YYYY')||
                                        ''' AND '''|| TO_CHAR(P_END_DATE,'DD-MON-YYYY')||'''
                   AND   ft.territory_code(+) = chk.country
                 ');
  else
    P_WHERE1 := ('where  cpd.payment_document_id(+) = chk.payment_document_id
                  AND    chk.ce_bank_acct_use_id = cbau.bank_acct_use_id
                  AND    cbau.bank_account_id = ba.bank_account_id
                  AND    ba.bank_branch_id = bb.branch_party_id
                  AND    chk.void_date is not null
                  AND    decode('''||P_INCLUDE_ZEROS||''', ''N'', chk.amount,  1) <> 0
                  AND    chk.void_date BETWEEN ''' ||TO_CHAR(P_START_DATE,'DD-MON-YYYY')||
                                        ''' AND '''|| TO_CHAR(P_END_DATE,'DD-MON-YYYY')||'''
                  AND    ft.territory_code(+) = chk.country
                ');
  end if;




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

function c_pay_curr_nameformula(C_PAY_CURR_CODE in varchar2) return varchar2 is
begin

declare
l_pay_curr_name  FND_CURRENCIES_VL.name%TYPE;
begin
select c2.name
into   l_pay_curr_name
from   FND_CURRENCIES_VL c2
where  c2.currency_code = C_PAY_CURR_CODE;

return(l_pay_curr_name);
end;
RETURN NULL; end;

function c_bank_curr_nameformula(C_BANK_CURR_CODE in varchar2) return varchar2 is
begin

declare
  l_bank_curr_name  FND_CURRENCIES_VL.name%TYPE;
begin
  select c1.name
  into   l_bank_curr_name
  from   FND_CURRENCIES_VL c1
  where  c1.currency_code = C_BANK_CURR_CODE;

  if C_FIRST_REC = 'Y' then
     C_OLD_BANK_CURR_CODE := C_BANK_CURR_CODE;
     C_CURR_CODE_CHANGE_FLAG := 'N';
     C_FIRST_REC := 'N';
  else
     if C_OLD_BANK_CURR_CODE <> C_BANK_CURR_CODE then
        C_OLD_BANK_CURR_CODE := C_BANK_CURR_CODE;
        C_CURR_CODE_CHANGE_FLAG := 'Y';
     else
        C_CURR_CODE_CHANGE_FLAG := 'N';
     end if;
  end if;

  return(l_bank_curr_name);
end;

RETURN NULL; end;

FUNCTION GET_DATE_OPTION RETURN BOOLEAN IS
l_displayed_field  ap_lookup_codes.displayed_field%TYPE;

BEGIN

  SELECT  displayed_field
  INTO    l_displayed_field
  FROM    ap_lookup_codes
  WHERE   lookup_type  = 'CHECK OR VOID'
  AND     lookup_code = P_DATE_OPTION;

  c_date_option  := l_displayed_field;

 RETURN (TRUE);
 EXCEPTION
 WHEN   OTHERS  THEN
    /*srw.message('100','An Error Occured in Get_Date_Option');*/null;

    /*srw.message('101',SQLCODE||SQLERRM);*/null;

    RETURN (FALSE);

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
 Function C_FIRST_REC_p return varchar2 is
	Begin
	 return C_FIRST_REC;
	 END;
 Function C_OLD_BANK_CURR_CODE_p return varchar2 is
	Begin
	 return C_OLD_BANK_CURR_CODE;
	 END;
 Function C_CURR_CODE_CHANGE_FLAG_p return varchar2 is
	Begin
	 return C_CURR_CODE_CHANGE_FLAG;
	 END;
 Function C_NLS_END_OF_REPORT_p return varchar2 is
	Begin
	 return C_NLS_END_OF_REPORT;
	 END;
 Function C_NLS_ADDR_OPTION_p return varchar2 is
	Begin
	 return C_NLS_ADDR_OPTION;
	 END;
 Function C_NLS_ZERO_AMT_OPTION_p return varchar2 is
	Begin
	 return C_NLS_ZERO_AMT_OPTION;
	 END;
 Function C_DATE_OPTION_p return varchar2 is
	Begin
	 return C_DATE_OPTION;
	 END;
 Function C_nls_none_ep_p return varchar2 is
	Begin
	 return C_nls_none_ep;
	 END;
END AP_APXVCHCR_XMLP_PKG ;


/
