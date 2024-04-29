--------------------------------------------------------
--  DDL for Package Body AP_APXINAGE_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_APXINAGE_XMLP_PKG" AS
/* $Header: APXINAGEB.pls 120.0 2007/12/27 07:47:53 vjaganat noship $ */

FUNCTION  get_base_curr_data  RETURN BOOLEAN IS

  base_curr ap_system_parameters.base_currency_code%TYPE;   prec      fnd_currencies_vl.precision%TYPE;       min_au    fnd_currencies_vl.minimum_accountable_unit%TYPE;  descr     fnd_currencies_vl.description%TYPE;
BEGIN

  base_curr := '';
  prec      := 0;
  min_au    := 0;
  descr     := '';

  SELECT  p.base_currency_code,
          c.precision,
          nvl(c.minimum_accountable_unit,0),
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
  c_base_min_acct_unit  := nvl(min_au,0);
  c_base_description    := descr;

  RETURN (TRUE);

RETURN NULL; EXCEPTION

  WHEN   OTHERS  THEN
    RETURN (FALSE);

END;

FUNCTION  custom_init         RETURN BOOLEAN IS
MINDAY      NUMBER(10);
MAXDAY      NUMBER(10);
L_SORT_OPTION    AP_LOOKUP_CODES.DISPLAYED_FIELD%TYPE;
L_SUMMARY_OPTION AP_LOOKUP_CODES.DISPLAYED_FIELD%TYPE;
L_FORMAT_OPTION  AP_LOOKUP_CODES.DISPLAYED_FIELD%TYPE;
L_NLS_ALL        AP_LOOKUP_CODES.DISPLAYED_FIELD%TYPE;
L_INVOICE_TYPE   AP_LOOKUP_CODES.DISPLAYED_FIELD%TYPE;
L_PARTY_NAME     HZ_PARTIES.PARTY_NAME%TYPE;
BEGIN
  BEGIN
    SELECT displayed_field
    INTO   l_sort_option
    FROM   ap_lookup_codes
    WHERE  lookup_type = 'AGING_SORT_OPTION'
    AND    lookup_code = P_SORT_OPTION;
    C_HEAD_SORT_OPTION := L_SORT_OPTION;
  END;
    BEGIN
    IF (P_SUMMARY_OPTION is not NULL) then
    SELECT Meaning
    INTO   C_HEAD_SUMMARY_OPTION
    FROM   FND_LOOKUPS
    WHERE  lookup_code = P_SUMMARY_OPTION
    AND    lookup_type = 'YES_NO';
    END IF;

  END;
  BEGIN
    IF (P_FORMAT_OPTION is not NULL) then
    SELECT Meaning
    INTO   C_HEAD_FORMAT_OPTION
    FROM   FND_LOOKUPS
    WHERE  lookup_code = P_FORMAT_OPTION
    AND    lookup_type = 'YES_NO';
    END IF;
  END;

  BEGIN
    SELECT displayed_field
    INTO   l_nls_all
    FROM   ap_lookup_codes
    WHERE  lookup_type = 'NLS REPORT PARAMETER'
    AND    lookup_code = 'ALL';
  END;
  BEGIN
    if (P_INVOICE_TYPE is null) then
      C_INVOICE_TYPE_SELECT := '%';
      C_HEAD_INVOICE_TYPE   := L_NLS_ALL;
    else
      SELECT displayed_field
      INTO   l_invoice_type
      FROM   ap_lookup_codes
      WHERE  lookup_type = 'INVOICE TYPE'
      AND    lookup_code = P_INVOICE_TYPE;
      C_HEAD_INVOICE_TYPE   := L_INVOICE_TYPE;
      C_INVOICE_TYPE_SELECT := P_INVOICE_TYPE;
    end if;
  END;
  BEGIN
    if (P_PARTY_ID is not null) then
       SELECT hp.party_name
       INTO   l_party_name
       FROM   hz_parties hp
       WHERE  party_id = P_PARTY_ID;
       C_VENDOR_NAME_SELECT := L_PARTY_NAME;
       C_HEAD_VENDOR_NAME   := L_PARTY_NAME;
       P_PARTY_PREDICATE := 'AND HP.party_id = '||P_PARTY_ID;
    else
       C_VENDOR_NAME_SELECT := '%';
       C_HEAD_VENDOR_NAME   := L_NLS_ALL;
    end if;
  END;
  BEGIN
    SELECT min(days_start), max(days_to)
    INTO   MINDAY, MAXDAY
    FROM   ap_aging_period_lines aapl, ap_aging_periods aap
    WHERE  aapl.aging_period_id = aap.aging_period_id
      AND  upper(aap.period_name) = upper(P_PERIOD_TYPE);
    C_MINDAYS := MINDAY;
    C_MAXDAYS := MAXDAY;
  END;

      if P_AMOUNT_DUE_LOW is not null and P_AMOUNT_DUE_HIGH is not null then
     P_AMOUNT_PREDICATE := 'AND (nvl(ps.amount_remaining, 0) * nvl(i.exchange_rate,1)) between '''
         ||to_char(P_AMOUNT_DUE_LOW)||''' AND '''||to_char(P_AMOUNT_DUE_HIGH)||'''';
  elsif P_AMOUNT_DUE_LOW is not null and P_AMOUNT_DUE_HIGH is null then
     P_AMOUNT_PREDICATE := 'AND (nvl(ps.amount_remaining, 0) * nvl(i.exchange_rate,1)) >= '''
         ||to_char(P_AMOUNT_DUE_LOW)||'''';
  elsif P_AMOUNT_DUE_LOW is null and P_AMOUNT_DUE_HIGH is not null then
     P_AMOUNT_PREDICATE := 'AND (nvl(ps.amount_remaining, 0) * nvl(i.exchange_rate,1)) <= '''
	 ||to_char(P_AMOUNT_DUE_HIGH)||'''';
  end if;

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

P_SORT_OPTION_UPPER := P_SORT_OPTION;
P_FORMAT_OPTION_UPPER := P_FORMAT_OPTION;

DECLARE

  init_failure    EXCEPTION;

BEGIN





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


  IF (custom_init() <> TRUE) THEN
     RAISE init_failure;
  END IF;
  IF (p_debug_switch = 'Y') THEN
     /*SRW.MESSAGE('5','After custom_init');*/null;

  END IF;
























   BEGIN


	SELECT sort_by_alternate_field
	INTO SORT_BY_ALTERNATE
	FROM AP_SYSTEM_PARAMETERS;



   EXCEPTION
     WHEN OTHERS THEN
       SORT_BY_ALTERNATE := 'N';
   END;

   IF(set_order_by() <> TRUE) THEN
     RAISE init_failure;
   END IF;
   IF (p_debug_switch = 'Y') THEN
      /*SRW.MESSAGE('7','After set_order_by');*/null;

   END IF;

   IF(get_period_info() <> TRUE) THEN
     RAISE init_failure;
   END IF;
   IF (p_debug_switch = 'Y') THEN
      /*SRW.MESSAGE('8','After Get_period_info');*/null;

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

FUNCTION  set_order_by     RETURN BOOLEAN IS
BEGIN
   if (upper(P_SUMMARY_OPTION) = 'N' and
       upper(P_SORT_OPTION) = 'VENDOR NAME') then
       P_ORDER_BY := ' ORDER BY
             decode(:C_VENDOR_NAME_SELECT,
                        ''%'',decode(:SORT_BY_ALTERNATE, ''Y'',
                                     UPPER(v.vendor_name_alt), UPPER(v.vendor_name)),
                              decode(:SORT_BY_ALTERNATE, ''Y'', v.vendor_name_alt, v.vendor_name)),
             v.vendor_id,
             decode(:SORT_BY_ALTERNATE, ''Y'', vs.vendor_site_code_alt, vs.vendor_site_code),
	     i.invoice_type_lookup_code,
	     ps.due_date,
             i.invoice_num,
             ps.payment_num';
       RETURN (TRUE);
   end if;

   if (upper(P_SUMMARY_OPTION) = 'N' and
       upper(P_SORT_OPTION) = 'INVOICE TYPE') then
       P_ORDER_BY := ' ORDER BY
             i.invoice_type_lookup_code,
             decode(:C_VENDOR_NAME_SELECT,
                        ''%'',decode(:SORT_BY_ALTERNATE, ''Y'',
                                     UPPER(v.vendor_name_alt), UPPER(v.vendor_name)),
                              decode(:SORT_BY_ALTERNATE, ''Y'', v.vendor_name_alt, v.vendor_name)),
             v.vendor_id,
             decode(:SORT_BY_ALTERNATE, ''Y'', vs.vendor_site_code_alt, vs.vendor_site_code),
	     i.invoice_type_lookup_code,
	     ps.due_date,
             i.invoice_num,
             ps.payment_num';
       RETURN (TRUE);
   end if;

   if (upper(P_SUMMARY_OPTION) = 'Y' and
       upper(P_SORT_OPTION) = 'VENDOR NAME') then
       P_ORDER_BY := ' ORDER BY
             decode(:C_VENDOR_NAME_SELECT,
                        ''%'',decode(:SORT_BY_ALTERNATE, ''Y'',
                                     UPPER(v.vendor_name_alt), UPPER(v.vendor_name)),
                              decode(:SORT_BY_ALTERNATE, ''Y'', v.vendor_name_alt, v.vendor_name)),
             v.vendor_id,
             decode(:SORT_BY_ALTERNATE, ''Y'', vs.vendor_site_code_alt, vs.vendor_site_code),
	     i.invoice_type_lookup_code,
	     ps.due_date,
             i.invoice_num,
             ps.payment_num';
       RETURN (TRUE);
   end if;

   if (upper(P_SUMMARY_OPTION) = 'Y' and
       upper(P_SORT_OPTION) = 'INVOICE TYPE') then
       P_ORDER_BY := ' ORDER BY
             i.invoice_type_lookup_code,
             decode(:C_VENDOR_NAME_SELECT,
                        ''%'',decode(:SORT_BY_ALTERNATE, ''Y'',
                                     UPPER(v.vendor_name_alt), UPPER(v.vendor_name)),
                              decode(:SORT_BY_ALTERNATE, ''Y'', v.vendor_name_alt, v.vendor_name)),
             v.vendor_id,
             decode(:SORT_BY_ALTERNATE, ''Y'', vs.vendor_site_code_alt, vs.vendor_site_code),
	     i.invoice_type_lookup_code,
	     ps.due_date,
             i.invoice_num,
             ps.payment_num';
       RETURN (TRUE);
   end if;

RETURN NULL; EXCEPTION
   WHEN OTHERS THEN
      RETURN (FALSE);


END;

FUNCTION  get_period_info     RETURN BOOLEAN IS
l_period_days_start    ap_aging_period_lines.days_start%TYPE;
l_period_days_to       ap_aging_period_lines.days_to%TYPE;
l_period_seq_num       ap_aging_period_lines.period_sequence_num%TYPE;
l_period_title1        ap_aging_period_lines.report_heading1%TYPE;
l_period_title2        ap_aging_period_lines.report_heading2%TYPE;

cursor period_info is
  SELECT   lines.days_start,
           lines.days_to,
           lines.period_sequence_num,
           report_heading1,
           report_heading2
  FROM     ap_aging_period_lines lines,
           ap_aging_periods periods
  WHERE    lines.aging_period_id = periods.aging_period_id
  AND      upper(periods.period_name) = upper(p_period_type)
  ORDER BY lines.period_sequence_num;

BEGIN
   open period_info;
   loop
      fetch period_info into  l_period_days_start,l_period_days_to,
            l_period_seq_num,l_period_title1, l_period_title2;
      exit when (period_info%NOTFOUND);
      if (l_period_seq_num = 1) then
         C_INV_DUE_1_HEAD_1  := l_period_title1;
         C_INV_DUE_1_HEAD_2  := l_period_title2;
         C_INV_DUE_1_RANGE_FR := l_period_days_start;
         C_INV_DUE_1_RANGE_TO := l_period_days_to;
      end if;

      if (l_period_seq_num = 2) then
         C_INV_DUE_2_HEAD_1  := l_period_title1;
         C_INV_DUE_2_HEAD_2  := l_period_title2;
         C_INV_DUE_2_RANGE_FR := l_period_days_start;
         C_INV_DUE_2_RANGE_TO := l_period_days_to;
      end if;

      if (l_period_seq_num = 3) then
         C_INV_DUE_3_HEAD_1  := l_period_title1;
         C_INV_DUE_3_HEAD_2  := l_period_title2;
         C_INV_DUE_3_RANGE_FR := l_period_days_start;
         C_INV_DUE_3_RANGE_TO := l_period_days_to;
      end if;

      if (l_period_seq_num = 4) then
         C_INV_DUE_4_HEAD_1  := l_period_title1;
         C_INV_DUE_4_HEAD_2  := l_period_title2;
         C_INV_DUE_4_RANGE_FR := l_period_days_start;
         C_INV_DUE_4_RANGE_TO := l_period_days_to;
      end if;

   end loop;
   close period_info;
   return(TRUE);
   null;
RETURN NULL; EXCEPTION
   WHEN OTHERS THEN
      RETURN (FALSE);
END;

function c_contact_lineformula(C_CONTACT_SITE_ID in number) return varchar2 is
begin

DECLARE
l_contact_name     varchar2(160);
l_first_name       varchar2(4);
l_last_name        po_vendor_contacts.last_name%TYPE;
l_phone            po_vendor_contacts.phone%TYPE;
BEGIN
   SELECT  substr(first_name,1,1), last_name,phone
   INTO    l_first_name,l_last_name,l_phone
   FROM    po_vendor_contacts
   WHERE   vendor_site_id = C_CONTACT_SITE_ID
   AND     rownum = 1;
   if (l_first_name is not null or
       l_last_name is not null or
       l_phone is not null) then
       l_contact_name  :=  l_first_name ||'. '|| l_last_name||
                           ' '||l_phone ;
   end if;
   return(l_contact_name);
EXCEPTION
when NO_DATA_FOUND then null;
END;

RETURN NULL; end;

function c_percent_remainingformula(C_AMT_DUE_ORIGINAL in number, C_AMT_DUE_REMAINING in number) return number is
begin

DECLARE
l_calculated_value      number(10,1);
BEGIN
   if (nvl(C_AMT_DUE_ORIGINAL,0) > 0 or
       nvl(C_AMT_DUE_ORIGINAL,0) < 0) then
       l_calculated_value :=round((nvl(C_AMT_DUE_REMAINING,0)
                            /nvl(C_AMT_DUE_ORIGINAL,1))
                           *100,1);
       return(l_calculated_value);
   else
       return(0);
   end if;
END;

RETURN NULL; end;

function c_inv_due_amt_1formula(C_DAYS_PAST_DUE in number, C_AMT_DUE_REMAINING in number) return number is
begin

BEGIN
   if (nvl(C_DAYS_PAST_DUE,0) >= C_INV_DUE_1_RANGE_FR and
       nvl(C_DAYS_PAST_DUE,0) <= C_INV_DUE_1_RANGE_TO) then
       return(C_AMT_DUE_REMAINING);
   else
       return(0);
   end if;
END;
RETURN NULL; end;

function c_inv_due_amt_2formula(C_DAYS_PAST_DUE in number, C_AMT_DUE_REMAINING in number) return number is
begin

BEGIN
   if (nvl(C_DAYS_PAST_DUE,0) >= C_INV_DUE_2_RANGE_FR and
       nvl(C_DAYS_PAST_DUE,0) <= C_INV_DUE_2_RANGE_TO) then
       return(C_AMT_DUE_REMAINING);
   else
       return(0);
   end if;
END;
RETURN NULL; end;

function c_inv_due_amt_3formula(C_DAYS_PAST_DUE in number, C_AMT_DUE_REMAINING in number) return number is
begin

BEGIN
   if (nvl(C_DAYS_PAST_DUE,0) >= C_INV_DUE_3_RANGE_FR and
       nvl(C_DAYS_PAST_DUE,0) <= C_INV_DUE_3_RANGE_TO) then
       return(C_AMT_DUE_REMAINING);
   else
       return(0);
   end if;
END;
RETURN NULL; end;

function c_inv_due_amt_4formula(C_DAYS_PAST_DUE in number, C_AMT_DUE_REMAINING in number) return number is
begin

BEGIN
   if (nvl(C_DAYS_PAST_DUE,0) >= C_INV_DUE_4_RANGE_FR and
       nvl(C_DAYS_PAST_DUE,0) <= C_INV_DUE_4_RANGE_TO) then
       return(C_AMT_DUE_REMAINING);
   else
       return(0);
   end if;
END;
RETURN NULL; end;

function c_per_v_inv_amt_1formula(C_SUM_V_INV_AMT_1 in number, C_SUM_V_DUE_REMAINING in number) return number is
begin

DECLARE
l_percent     number(10):=0;
BEGIN
   l_percent := (round((nvl(C_SUM_V_INV_AMT_1,0) * 100)/
                 nvl(C_SUM_V_DUE_REMAINING,1),2));
   return(l_percent);
EXCEPTION
  WHEN ZERO_DIVIDE then
    return(0);
END;
RETURN NULL; end;

function c_per_v_inv_amt_2formula(C_SUM_V_INV_AMT_2 in number, C_SUM_V_DUE_REMAINING in number) return number is
begin

DECLARE
l_percent     number(10):=0;
BEGIN
   l_percent := (round((nvl(C_SUM_V_INV_AMT_2,0) * 100)/
                 nvl(C_SUM_V_DUE_REMAINING,1),2));
   return(l_percent);
EXCEPTION
  WHEN ZERO_DIVIDE then
     return(0);
END;
RETURN NULL; end;

function c_per_v_inv_amt_3formula(C_SUM_V_INV_AMT_3 in number, C_SUM_V_DUE_REMAINING in number) return number is
begin

DECLARE
l_percent     number(10):=0;
BEGIN
   l_percent := (round((nvl(C_SUM_V_INV_AMT_3,0) * 100)/
                 nvl(C_SUM_V_DUE_REMAINING,1),2));
   return(l_percent);
EXCEPTION
  WHEN ZERO_DIVIDE then
    return(0);
END;
RETURN NULL; end;

function c_per_v_inv_amt_4formula(C_SUM_V_INV_AMT_4 in number, C_SUM_V_DUE_REMAINING in number) return number is
begin

DECLARE
l_percent     number(10):=0;
BEGIN
   l_percent := (round((nvl(C_SUM_V_INV_AMT_4,0) * 100)/
                 nvl(C_SUM_V_DUE_REMAINING,1),2));
   return(l_percent);
EXCEPTION
  WHEN ZERO_DIVIDE then
     return(0);
END;
RETURN NULL; end;

function c_check_data_convertedformula(C_DATA_CONVERTED in varchar2) return number is
begin

BEGIN
   if (C_DATA_CONVERTED = '*') then
       C_REP_DATA_CONVERTED   := '*';
       return(1);

   else
       return(0);
   end if;
END;
RETURN NULL; end;

function c_per_inv_due_amt_1formula(C_SUM_INV_DUE_AMT_1 in number, C_SUM_AMT_REMAINING in number) return number is
begin

DECLARE
l_percent     number(10):=0;
BEGIN
   l_percent := ((nvl(C_SUM_INV_DUE_AMT_1,0) * 100)/
                 nvl(C_SUM_AMT_REMAINING,1));
   return(l_percent);
EXCEPTION
  WHEN ZERO_DIVIDE then
    return(0);

END;
RETURN NULL; end;

function c_per_inv_due_amt_2formula(C_SUM_INV_DUE_AMT_2 in number, C_SUM_AMT_REMAINING in number) return number is
begin

DECLARE
l_percent     number(10):=0;
BEGIN
   l_percent := ((nvl(C_SUM_INV_DUE_AMT_2,0) * 100)/
                 nvl(C_SUM_AMT_REMAINING,1));
   return(l_percent);
EXCEPTION
  WHEN ZERO_DIVIDE then
    return(0);


END;
RETURN NULL; end;

function c_per_inv_due_amt_3formula(C_SUM_INV_DUE_AMT_3 in number, C_SUM_AMT_REMAINING in number) return number is
begin

DECLARE
l_percent     number(10):=0;
BEGIN
   l_percent := ((nvl(C_SUM_INV_DUE_AMT_3,0) * 100)/
                 nvl(C_SUM_AMT_REMAINING,1));
   return(l_percent);
EXCEPTION
  WHEN ZERO_DIVIDE then
    return(0);

END;
RETURN NULL; end;

function c_per_inv_due_amt_4formula(C_SUM_INV_DUE_AMT_4 in number, C_SUM_AMT_REMAINING in number) return number is
begin

DECLARE
l_percent     number(10):=0;
BEGIN
   l_percent := ((nvl(C_SUM_INV_DUE_AMT_4,0) * 100)/
                 nvl(C_SUM_AMT_REMAINING,1));
   return(l_percent);
EXCEPTION
  WHEN ZERO_DIVIDE then
    return(0);


END;
RETURN NULL; end;

function c_pgbrk_data_convertedformula(C_SUM_DATA_CONVERTED in number) return varchar2 is
begin

BEGIN
   if (nvl(C_SUM_DATA_CONVERTED,0) > 0) then
       return('*');
   else
       return(' ');
   end if;
END;
RETURN NULL; end;

function c_v_data_convertedformula(C_SUM_V_DATA_CONVERTED in number) return varchar2 is
begin

BEGIN
   if (nvl(C_SUM_V_DATA_CONVERTED,0) > 0) then
       return('*');
   else
       return(' ');
   end if;
END;
RETURN NULL; end;

function c_tot_per_inv_due_1formula(C_TOT_INV_DUE_AMT_1 in number, C_TOT_AMT_REMAINING in number) return number is
begin

DECLARE
l_percent     number(10):=0;
BEGIN
   l_percent := ((nvl(C_TOT_INV_DUE_AMT_1,0) * 100)/
                 nvl(C_TOT_AMT_REMAINING,1));
   return(l_percent);
EXCEPTION
  WHEN ZERO_DIVIDE then
    return(0);


END;
RETURN NULL; end;

function c_tot_per_inv_due_2formula(C_TOT_INV_DUE_AMT_2 in number, C_TOT_AMT_REMAINING in number) return number is
begin

DECLARE
l_percent     number(10):=0;
BEGIN
   l_percent := ((nvl(C_TOT_INV_DUE_AMT_2,0) * 100)/
                 nvl(C_TOT_AMT_REMAINING,1));
   return(l_percent);
EXCEPTION
  WHEN ZERO_DIVIDE then
    return(0);


END;
RETURN NULL; end;

function c_tot_per_inv_due_3formula(C_TOT_INV_DUE_AMT_3 in number, C_TOT_AMT_REMAINING in number) return number is
begin

DECLARE
l_percent     number(10):=0;
BEGIN
   l_percent := ((nvl(C_TOT_INV_DUE_AMT_3,0) * 100)/
                 nvl(C_TOT_AMT_REMAINING,1));
   return(l_percent);
EXCEPTION
  WHEN ZERO_DIVIDE then
    return(0);


END;
RETURN NULL; end;

function c_tot_per_inv_due_4formula(C_TOT_INV_DUE_AMT_4 in number, C_TOT_AMT_REMAINING in number) return number is
begin

DECLARE
l_percent     number(10):=0;
BEGIN
   l_percent := ((nvl(C_TOT_INV_DUE_AMT_4,0) * 100)/
                 nvl(C_TOT_AMT_REMAINING,1));
   return(l_percent);
EXCEPTION
  WHEN ZERO_DIVIDE then
    return(0);


END;
RETURN NULL; end;

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
 Function C_VENDOR_NAME_SELECT_p return varchar2 is
	Begin
	 return C_VENDOR_NAME_SELECT;
	 END;
 Function C_INVOICE_TYPE_SELECT_p return varchar2 is
	Begin
	 return C_INVOICE_TYPE_SELECT;
	 END;
 Function C_MINDAYS_p return number is
	Begin
	 return C_MINDAYS;
	 END;
 Function C_MAXDAYS_p return number is
	Begin
	 return C_MAXDAYS;
	 END;
 Function C_INV_DUE_1_HEAD_1_p return varchar2 is
	Begin
	 return C_INV_DUE_1_HEAD_1;
	 END;
 Function C_INV_DUE_1_HEAD_2_p return varchar2 is
	Begin
	 return C_INV_DUE_1_HEAD_2;
	 END;
 Function C_INV_DUE_2_HEAD_1_p return varchar2 is
	Begin
	 return C_INV_DUE_2_HEAD_1;
	 END;
 Function C_INV_DUE_2_HEAD_2_p return varchar2 is
	Begin
	 return C_INV_DUE_2_HEAD_2;
	 END;
 Function C_INV_DUE_3_HEAD_1_p return varchar2 is
	Begin
	 return C_INV_DUE_3_HEAD_1;
	 END;
 Function C_INV_DUE_3_HEAD_2_p return varchar2 is
	Begin
	 return C_INV_DUE_3_HEAD_2;
	 END;
 Function C_INV_DUE_4_HEAD_1_p return varchar2 is
	Begin
	 return C_INV_DUE_4_HEAD_1;
	 END;
 Function C_INV_DUE_4_HEAD_2_p return varchar2 is
	Begin
	 return C_INV_DUE_4_HEAD_2;
	 END;
 Function C_INV_DUE_1_RANGE_FR_p return number is
	Begin
	 return C_INV_DUE_1_RANGE_FR;
	 END;
 Function C_INV_DUE_1_RANGE_TO_p return number is
	Begin
	 return C_INV_DUE_1_RANGE_TO;
	 END;
 Function C_INV_DUE_2_RANGE_FR_p return number is
	Begin
	 return C_INV_DUE_2_RANGE_FR;
	 END;
 Function C_INV_DUE_2_RANGE_TO_p return number is
	Begin
	 return C_INV_DUE_2_RANGE_TO;
	 END;
 Function C_INV_DUE_3_RANGE_FR_p return number is
	Begin
	 return C_INV_DUE_3_RANGE_FR;
	 END;
 Function C_INV_DUE_3_RANGE_TO_p return number is
	Begin
	 return C_INV_DUE_3_RANGE_TO;
	 END;
 Function C_INV_DUE_4_RANGE_FR_p return number is
	Begin
	 return C_INV_DUE_4_RANGE_FR;
	 END;
 Function C_INV_DUE_4_RANGE_TO_p return number is
	Begin
	 return C_INV_DUE_4_RANGE_TO;
	 END;
 Function C_HEAD_INVOICE_TYPE_p return varchar2 is
	Begin
	 return C_HEAD_INVOICE_TYPE;
	 END;
 Function C_HEAD_SORT_OPTION_p return varchar2 is
	Begin
	 return C_HEAD_SORT_OPTION;
	 END;
 Function C_HEAD_VENDOR_NAME_p return varchar2 is
	Begin
	 return C_HEAD_VENDOR_NAME;
	 END;
 Function C_REP_DATA_CONVERTED_p return varchar2 is
	Begin
	 return C_REP_DATA_CONVERTED;
	 END;
 Function C_NLS_END_OF_REPORT_p return varchar2 is
	Begin
	 return C_NLS_END_OF_REPORT;
	 END;
 Function C_HEAD_SUMMARY_OPTION_p return varchar2 is
	Begin
	 return C_HEAD_SUMMARY_OPTION;
	 END;
 Function C_HEAD_FORMAT_OPTION_p return varchar2 is
	Begin
	 return C_HEAD_FORMAT_OPTION;
	 END;
END AP_APXINAGE_XMLP_PKG ;


/
