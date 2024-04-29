--------------------------------------------------------
--  DDL for Package Body AP_APXINROH_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_APXINROH_XMLP_PKG" AS
/* $Header: APXINROHB.pls 120.1 2008/01/06 11:52:23 vjaganat noship $ */

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

  if P_DATE_PAR = 'Discount Date' then
     P_START_DISCOUNT_DATE := P_START_DATE;
     P_END_DISCOUNT_DATE := P_END_DATE;
  else
     P_START_DUE_DATE := P_START_DATE;
     P_END_DUE_DATE := P_END_DATE;
  end if;

  return(TRUE);

END;

FUNCTION  get_cover_page_values   RETURN BOOLEAN IS

BEGIN

RETURN(TRUE);

RETURN NULL; EXCEPTION
WHEN OTHERS THEN
  RETURN(FALSE);

END;

FUNCTION  get_nls_strings     RETURN BOOLEAN IS
   nls_all       ap_lookup_codes.displayed_field%TYPE;    nls_na        ap_lookup_codes.displayed_field%TYPE;    nls_no_desc   ap_lookup_codes.displayed_field%TYPE;    nls_yes       fnd_lookups.meaning%TYPE;     nls_no        fnd_lookups.meaning%TYPE;
BEGIN

   nls_all     := '';
   nls_yes     := '';
   nls_no      := '';

   SELECT  ly.meaning,
           ln.meaning,
           l1.displayed_field,
           l2.displayed_field,
           l3.displayed_field
   INTO    nls_yes,  nls_no,  nls_all, nls_na, nls_no_desc
   FROM    fnd_lookups ly,  fnd_lookups ln,
	   ap_lookup_codes l1, ap_lookup_codes l2,
	   ap_lookup_codes l3
   WHERE   ly.lookup_type = 'YES_NO'
     AND   ly.lookup_code = 'Y'
     AND   ln.lookup_type = 'YES_NO'
     AND   ln.lookup_code = 'N'
     AND   l1.lookup_type = 'NLS REPORT PARAMETER'
     AND   l1.lookup_code = 'ALL'
     AND   l2.lookup_type = 'NLS REPORT PARAMETER'
     AND   l2.lookup_code = 'NA'
     AND   l3.lookup_type = 'NLS TRANSLATION'
     AND   l3.lookup_code = 'NO DESCRIPTION';

   c_nls_yes := nls_yes;
   c_nls_no  := nls_no;
   c_nls_all := nls_all;
   c_nls_na  := nls_na;
   c_nls_no_description  := nls_no_desc;

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
	LP_START_CREATION_DATE := to_char(P_START_CREATION_DATE, 'DD-MON-YY');
	LP_END_CREATION_DATE := to_char(P_END_CREATION_DATE, 'DD-MON-YY');
	LP_START_DATE := to_char(P_START_DATE, 'DD-MON-YY');
	LP_END_DATE := to_char(P_END_DATE, 'DD-MON-YY');


DECLARE

  init_failure    EXCEPTION;

BEGIN
/*srw.message(0, 'And so it begins ...');*/null;


  if P_ORDER_BY is null or P_ORDER_BY <> 'Vendor Name' then
     P_ORDER_BY := 'Hold Name';
  end if;



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


    IF (get_parameter_disp_value() = TRUE)then
    IF (p_debug_switch = 'Y') THEN
     /*SRW.MESSAGE('8', 'After Get_Parameter_Disp_Value');*/null;

    END IF;
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


  BEGIN

            SELECT sort_by_alternate_field
    INTO SORT_BY_ALTERNATE
    FROM AP_SYSTEM_PARAMETERS;



  EXCEPTION
    WHEN OTHERS THEN
      SORT_BY_ALTERNATE := 'N';
  END;



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

function C_ORDER_BYFormula return VARCHAR2 is
begin

if P_ORDER_BY = 'Hold Name' then
  return(
  'order by decode(:P_ORDER_BY,''Vendor Name'',''Do not sort by Hold Name'',upper(decode(h.hold_lookup_code,null,:C_NLS_NA,alc.displayed_field))),
  hp.party_name,
  inv1.invoice_date,
  inv1.invoice_id,
  B.batch_name,
  inv1.invoice_num,
  decode(h.hold_lookup_code,null,:C_NLS_NA,h.hold_lookup_code),
  decode(h.hold_lookup_code,null,:C_NLS_NA,alc.displayed_field),
  alc.displayed_field,
  decode(:SORT_BY_ALTERNATE, ''Y'', upper(hp.organization_name_phonetic), upper(hp.party_name)),
  inv1.invoice_date asc,
  upper(B.batch_name),
  inv1.vendor_id,
  inv1.invoice_num,
  DECODE(inv1.invoice_currency_code, :C_BASE_CURRENCY_CODE,inv1.invoice_amount,inv1.base_amount) desc'
  );

 else
  return(
  'order by decode(:P_ORDER_BY,''Vendor Name'',''Do not sort by Hold Name'',upper(decode(h.hold_lookup_code,null,:C_NLS_NA,alc.displayed_field))),
hp.party_name,
inv1.invoice_date,
inv1.invoice_id,
B.batch_name,
inv1.invoice_num,
decode(h.hold_lookup_code,null,:C_NLS_NA,h.hold_lookup_code),
decode(h.hold_lookup_code,null,:C_NLS_NA,alc.displayed_field),
decode(:SORT_BY_ALTERNATE, ''Y'', upper(hp.organization_name_phonetic), upper(hp.party_name)),
inv1.invoice_date asc,
upper(B.batch_name),
inv1.vendor_id,
inv1.invoice_num,
alc.displayed_field,
DECODE(inv1.invoice_currency_code, :C_BASE_CURRENCY_CODE,inv1.invoice_amount,inv1.base_amount) desc'
 );
end if;

RETURN ' '; end;

function C_ORDER_BY1Formula return VARCHAR2 is
begin

if P_ORDER_BY = 'Hold Name' then
  return(
'order by decode(:SORT_BY_ALTERNATE, ''Y'', upper(hp.organization_name_phonetic), upper(hp.party_name)),
hp.party_name,
inv1.vendor_id,
to_char(inv1.invoice_date,''YYYYMM''),
to_char(inv1.invoice_date,''fmMonth YYYY''),
inv1.invoice_date,
B.batch_name,
inv1.invoice_num,
inv1.invoice_id,
decode(h.hold_lookup_code,null,:C_NLS_NA,alc.displayed_field),
decode(h.hold_lookup_code,null,:C_NLS_NA,h.hold_lookup_code),
alc.displayed_field,
decode(:SORT_BY_ALTERNATE, ''Y'', upper(hp.organization_name_phonetic), upper(hp.party_name)),
inv1.invoice_date asc,
upper(B.batch_name),
inv1.vendor_id,
inv1.invoice_num,
DECODE(inv1.invoice_currency_code, :C_BASE_CURRENCY_CODE,inv1.invoice_amount,inv1.base_amount) desc'
  );

   else
  return(
' order by decode(:SORT_BY_ALTERNATE, ''Y'', upper(hp.organization_name_phonetic), upper(hp.party_name)),
hp.party_name,
inv1.vendor_id,
to_char(inv1.invoice_date,''YYYYMM''),
to_char(inv1.invoice_date,''fmMonth YYYY''),
inv1.invoice_date,
B.batch_name,
inv1.invoice_num,
inv1.invoice_id,
decode(h.hold_lookup_code,null,:C_NLS_NA,alc.displayed_field),
decode(h.hold_lookup_code,null,:C_NLS_NA,h.hold_lookup_code),
decode(:SORT_BY_ALTERNATE, ''Y'', upper(hp.organization_name_phonetic), upper(hp.party_name)),
inv1.invoice_date asc,
upper(B.batch_name),
inv1.vendor_id,
inv1.invoice_num,
alc.displayed_field,
DECODE(inv1.invoice_currency_code, :C_BASE_CURRENCY_CODE,inv1.invoice_amount,inv1.base_amount) desc'
 );
end if;

RETURN ' '; end;

FUNCTION GET_PARAMETER_DISP_VALUE RETURN BOOLEAN IS

  l_party_name         hz_parties.party_name%TYPE;
  l_order_by           VARCHAR2(80);
  l_hold_period_option VARCHAR2(80);
  l_due_or_discount    VARCHAR2(80);
  l_include_hold_desc  VARCHAR2(80);

BEGIN

    if p_party_id is not null then
       SELECT party_name
       INTO  l_party_name
       FROM  hz_parties
       WHERE party_id = p_party_id;

       cp_party_name  := l_party_name;
    end if;

    if p_order_by is not null then
       SELECT displayed_field
         INTO l_order_by
         FROM ap_lookup_codes
        WHERE lookup_type = 'RPT ORDER BY'
          AND lookup_code = p_order_by;
    end if;

    if p_subtotal_flag is not null then
       SELECT meaning
         INTO l_hold_period_option
         FROM fnd_lookups
        WHERE lookup_type = 'YES_NO'
          AND lookup_code = p_subtotal_flag;
    end if;

    if p_date_par is not null then
        SELECT displayed_field
         INTO l_due_or_discount
         FROM ap_lookup_codes
        WHERE lookup_type = 'DATE RANGE'
          AND lookup_code = p_date_par;
    end if;

    if p_hold_desc_flag is not null then
        SELECT meaning
         INTO l_include_hold_desc
         FROM fnd_lookups
        WHERE lookup_type = 'YES_NO'
          AND lookup_code = p_hold_desc_flag;
    end if;

    cp_order_by := l_order_by;
    cp_hold_period_option := l_hold_period_option;
    cp_due_or_discount := l_due_or_discount;
    cp_include_hold_desc := l_include_hold_desc;


RETURN(TRUE);
RETURN NULL; EXCEPTION

  WHEN   OTHERS  THEN
    RETURN (FALSE);


END;

function c_rep_total_countformula(c_total_count in number, c_pay_on_hold_count in number, c_sites_on_hold_count in number, c_total_count1 in number) return number is
begin

  if p_hold_code is null then
	if P_ORDER_BY = 'Hold Name' then
		return (nvl(c_total_count,0) + nvl(c_pay_on_hold_count,0)
        	         + nvl(c_sites_on_hold_count,0));
	else
		return (nvl(c_total_count1,0) + nvl(c_pay_on_hold_count,0)
        	         + nvl(c_sites_on_hold_count,0));
	end if;
  else
	if P_ORDER_BY = 'Hold Name' then
		return (nvl(c_total_count,0));
	else
		return (nvl(c_total_count1,0));
	end if;
  end if;
end;

function c_rep_total_remainingformula(c_total_remaining in number, c_ph_total_remaining in number, c_sh_total_remaining in number, c_total_remaining1 in number) return number is
begin

  if p_hold_code is null then
	if P_ORDER_BY = 'Hold Name' then
		return (nvl(c_total_remaining,0) + nvl(c_ph_total_remaining,0)
                	+ nvl(c_sh_total_remaining,0));
	else
		return (nvl(c_total_remaining1,0) + nvl(c_ph_total_remaining,0)
                	+ nvl(c_sh_total_remaining,0));
	end if;
  else
	if P_ORDER_BY = 'Hold Name' then
		return (nvl(c_total_remaining,0));
	else
		return (nvl(c_total_remaining1,0));
	end if;
  end if;
end;

function c_rep_total_originalformula(c_total_original in number, c_ph_total_original in number, c_sh_total_original in number, c_total_original1 in number) return number is
begin

   if p_hold_code is null then
	if P_ORDER_BY = 'Hold Name' then
		return (nvl(c_total_original,0) + nvl(c_ph_total_original,0)
                	+ nvl(c_sh_total_original,0));
	else
		return (nvl(c_total_original1,0) + nvl(c_ph_total_original,0)
                	+ nvl(c_sh_total_original,0));
	end if;
   else
	if P_ORDER_BY = 'Hold Name' then
		return (nvl(c_total_original,0));
	else
		return (nvl(c_total_original1,0));
	end if;
   end if;
end;

function C_vendor_clauseFormula return Char is
begin
  if P_PARTY_ID is not null then
    return('AND hp.party_id = '||to_char(P_PARTY_ID)||' ' );
  else
    return ' ';
  end if;
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
 Function C_NLS_NA_p return varchar2 is
	Begin
	 return C_NLS_NA;
	 END;
 Function C_NLS_NO_DESCRIPTION_p return varchar2 is
	Begin
	 return C_NLS_NO_DESCRIPTION;
	 END;
 Function C_NLS_END_OF_REPORT_p return varchar2 is
	Begin
	 return C_NLS_END_OF_REPORT;
	 END;
 Function CP_PARTY_NAME_p return varchar2 is
	Begin
	 return CP_PARTY_NAME;
	 END;
 Function CP_ORDER_BY_p return varchar2 is
	Begin
	 return CP_ORDER_BY;
	 END;
 Function CP_HOLD_PERIOD_OPTION_p return varchar2 is
	Begin
	 return CP_HOLD_PERIOD_OPTION;
	 END;
 Function CP_INCLUDE_HOLD_DESC_p return varchar2 is
	Begin
	 return CP_INCLUDE_HOLD_DESC;
	 END;
 Function CP_DUE_OR_DISCOUNT_p return varchar2 is
	Begin
	 return CP_DUE_OR_DISCOUNT;
	 END;
END AP_APXINROH_XMLP_PKG ;



/
