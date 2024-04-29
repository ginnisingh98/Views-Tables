--------------------------------------------------------
--  DDL for Package Body AP_APXINRIR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_APXINRIR_XMLP_PKG" AS
/* $Header: APXINRIRB.pls 120.0 2007/12/27 07:59:45 vjaganat noship $ */

function BeforeReport return boolean is
begin

DECLARE

  init_failure    EXCEPTION;

BEGIN


  p_unapprove_flag_1 := p_unapprove_flag;
  CP_START_DATE := to_char(P_START_DATE,'DD-MON-YY');
  CP_END_DATE := to_char(P_END_DATE,'DD-MON-YY');
  /*SRW.USER_EXIT('FND SRWINIT');*/null;

  IF (p_debug_switch = 'Y') THEN
     /*SRW.MESSAGE('1','After SRWINIT');*/null;

  END IF;


/*SRW.MESSAGE('1','i am here 21');*/null;


  IF (get_company_name() <> TRUE) THEN          RAISE init_failure;
  END IF;
  IF (p_debug_switch = 'Y') THEN
     /*SRW.MESSAGE('2','After Get_Company_Name');*/null;

  END IF;


  IF (get_nls_strings() <> TRUE) THEN           RAISE init_failure;
  END IF;
  IF (p_debug_switch = 'Y') THEN
     /*SRW.MESSAGE('3','After Get_NLS_Strings');*/null;

  END IF;


  IF (get_supplier_invoice_info() <> TRUE) THEN           RAISE init_failure;
  END IF;
  IF (p_debug_switch = 'Y') THEN
     /*SRW.MESSAGE('4','After Get_Supplier_Invoice_Info');*/null;

  END IF;


  IF (get_base_curr_data() <> TRUE) THEN        RAISE init_failure;
  END IF;
  IF (p_debug_switch = 'Y') THEN
     /*SRW.MESSAGE('5','After Get_Base_Curr_Data');*/null;

  END IF;


  IF (custom_init() <> TRUE) THEN          RAISE_application_error(-20101,null);/*SRW.PROGRAM_ABORT;*/null;

  END IF;
  IF (p_debug_switch = 'Y') THEN
     /*SRW.MESSAGE('6','After Custom_Init');*/null;

  END IF;

  IF (get_flexdata() <> TRUE) THEN          RAISE_application_error(-20101,null);/*SRW.PROGRAM_ABORT;*/null;

  END IF;
  IF (p_debug_switch = 'Y') THEN
     /*SRW.MESSAGE('7','After get_flexdata');*/null;

  END IF;


  IF (set_p_where() <> TRUE) THEN          RAISE_application_error(-20101,null);/*SRW.PROGRAM_ABORT;*/null;

  END IF;
  IF (p_debug_switch = 'Y') THEN
     /*SRW.MESSAGE('8','After set_p_where');*/null;

  END IF;

  IF (p_debug_switch = 'Y') THEN
	/*SRW.MESSAGE('9','P_DYNAMIC_BATCH_ORDERBY = ' || P_dynamic_batch_orderby);*/null;

	/*SRW.MESSAGE('10','P_invoice_amount = ' || P_invoice_amount);*/null;

	/*SRW.MESSAGE('11','P_flexdata = ' || P_flexdata);*/null;

	/*SRW.MESSAGE('12','P_flexdata1 = ' || P_flexdata1);*/null;

	/*SRW.MESSAGE('13','P_gl_code_combinations2 = ' || P_gl_code_combinations2);*/null;

	/*SRW.MESSAGE('14','c_invoice_id_predicate = ' || c_invoice_id_predicate);*/null;

	/*SRW.MESSAGE('15','c_batch_predicate = ' || c_batch_predicate);*/null;

	/*SRW.MESSAGE('16','c_match_status_predicate = ' || c_match_status_predicate);*/null;

	/*SRW.MESSAGE('17','c_inv_type_pred = ' || c_inv_type_pred);*/null;

	/*SRW.MESSAGE('18','c_accounting_date_predicate = ' || c_accounting_date_predicate);*/null;

	/*SRW.MESSAGE('19','c_invoice_cancelled_predicate = ' || c_invoice_cancelled_predicate);*/null;

	/*SRW.MESSAGE('20','c_created_by_predicate = ' || c_created_by_predicate);*/null;

	/*SRW.MESSAGE('21','c_start_date_predicate = ' || c_start_date_predicate);*/null;

	/*SRW.MESSAGE('22','c_end_date_predicate = ' || c_end_date_predicate);*/null;

	/*SRW.MESSAGE('23','c_gl_ccid2_predicate = ' || c_gl_ccid2_predicate);*/null;

	/*SRW.MESSAGE('24','c_orderby_batch_id = ' || c_orderby_batch_id);*/null;

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

    /*SRW.USER_EXIT('FND SRWEXIT');*/null;

    RETURN (FALSE);

END;  return (TRUE);
end;

function AfterReport return boolean is
begin

BEGIN
/*SRW.USER_EXIT('FND SRWEXIT');*/null;

END;  return (TRUE);
end;

FUNCTION  custom_init         RETURN BOOLEAN IS
l_batch_flag      VARCHAR2(1);
l_show_lib_acct   VARCHAR2(1);
l_batchid         number(15);
l_userid          number(14);
l_cash_basis_flag VARCHAR2(1);
BEGIN
   BEGIN
      SELECT ap_system_parameters.batch_control_flag
      INTO   l_batch_flag
      FROM   ap_system_parameters;
      C_BATCH_FLAG := l_batch_flag;
   EXCEPTION
   WHEN NO_DATA_FOUND THEN NULL;
   END;

   BEGIN
     SELECT nvl(sla_ledger_cash_basis_flag, 'N')
     INTO   l_cash_basis_flag
     FROM   gl_sets_of_books sob,
            ap_system_parameters asp
     WHERE  asp.set_of_books_id = sob.set_of_books_id;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       l_cash_basis_flag :='N';
   END;
   BEGIN
      if (l_cash_basis_flag = 'Y' ) then
         C_SHOW_LIB_ACCT := 'N';
      else
         C_SHOW_LIB_ACCT := 'Y';
      end if;
   END;
   BEGIN
      if (upper(p_batch) <> 'ALL' and p_batch is not null) then
         SELECT ap_batches.batch_id
         INTO   l_batchid
         FROM   ap_batches
         where  batch_name = p_batch;
         C_BATCH_ID := to_char(l_batchid);
      end if;
   EXCEPTION
   WHEN NO_DATA_FOUND THEN NULL;
   END;
   BEGIN
      SELECT decode(p_entry_person,null,'',fnd_user.user_id)
      INTO   l_userid
      FROM   fnd_user
      WHERE  user_name = decode(p_entry_person,null,user_name,p_entry_person);
      C_USER_ID := l_userid;
   EXCEPTION
   WHEN NO_DATA_FOUND THEN NULL;
   END;

RETURN (TRUE);

RETURN NULL; EXCEPTION

  WHEN   OTHERS  THEN NULL;

RETURN NULL; END;

FUNCTION  get_base_curr_data  RETURN BOOLEAN IS

  l_base_curr   VARCHAR2(15);        l_prec        NUMBER;          l_min_au      NUMBER;          l_sob_id      NUMBER;

BEGIN

  SELECT  p.base_currency_code,
          c.precision,
          c.minimum_accountable_unit
  INTO    l_base_curr,
          l_prec,
          l_min_au
  FROM    ap_system_parameters p,
          fnd_currencies_vl c
  WHERE   p.base_currency_code  = c.currency_code;

  c_base_currency_code  := l_base_curr;
  c_base_precision      := l_prec;
  c_base_min_acct_unit  := l_min_au;
  RETURN (TRUE);

RETURN NULL; EXCEPTION

  WHEN   OTHERS  THEN Null;

RETURN NULL; END;

FUNCTION  get_company_name    RETURN BOOLEAN IS

  l_chart_of_accounts_id  NUMBER;
  l_name                  VARCHAR2(30);     l_sob_id                  NUMBER;

BEGIN


  select set_of_books_id
  into l_sob_id
  from ap_system_parameters;

  p_sob_id := l_sob_id;
  SELECT  substr(name,1,30),
          chart_of_accounts_id
  INTO    l_name,
          l_chart_of_accounts_id
  FROM    gl_sets_of_books
  WHERE   set_of_books_id   = l_sob_id;

  c_company_name_header     := l_name;
  c_chart_of_accounts_id    := l_chart_of_accounts_id;

  RETURN (TRUE);

RETURN NULL; EXCEPTION

  WHEN   OTHERS  THEN
    RETURN (FALSE);

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

   c_nls_no_data_exists := 'No Data Found';

   /*SRW.USER_EXIT('FND MESSAGE_NAME APPL="SQLAP" NAME="AP_ALL_END_OF_REPORT"');*/null;

   /*SRW.USER_EXIT('FND MESSAGE_GET OUTPUT_FIELD=":c_nls_end_of_report"');*/null;

   c_nls_end_of_report := 'End of Report';

   if p_unapprove_flag_1 = 'Y' THEN
     c_unapproved_invoices_only := nls_yes;
   else
     c_unapproved_invoices_only := nls_no;
   end if;

   if p_cancelled_flag = 'Y' THEN
     c_cancelled_invoices_only := nls_yes;
   else
     c_cancelled_invoices_only := nls_no;
   end if;


RETURN (TRUE);

RETURN NULL; EXCEPTION
   WHEN OTHERS THEN
      RETURN (FALSE);
END;

FUNCTION  get_flexdata     RETURN BOOLEAN IS
BEGIN


 null;


 null;
  return(TRUE);
END;

FUNCTION  set_p_where     RETURN BOOLEAN IS

l_nls_yes       varchar2(4);
l_type_of_report   varchar2(40);
l_start_date    gl_period_statuses.start_date%TYPE;
l_end_date      gl_period_statuses.end_date%TYPE;


BEGIN


   if (p_cancelled_flag = 'Y') then
       p_unapprove_flag_1 := 'N';
   end if;


   if (c_show_lib_acct <> 'Y') then
      if (p_batch is null or
          (p_batch = c_nls_na and c_batch_flag <> 'Y')) then
         if (p_unapprove_flag_1 <> 'Y') then
            l_type_of_report := 'SEL_INVOICES';
         else
            l_type_of_report := 'SEL_UNAPPROVED_INVOICES';
         end if;
      else
            if (p_unapprove_flag_1 <> 'Y') then
               l_type_of_report := 'SEL_BATCH_INVOICES';
            else
               l_type_of_report := 'SEL_UNAPPROVED_BATCH';
            end if;
      end if;
   else
        if (p_batch is null or
            (p_batch = c_nls_na and c_batch_flag <> 'Y')) then
              if (p_unapprove_flag_1 <> 'Y') then
                 l_type_of_report := 'SEL_INVOICES_WITH_LA';
              else
                 l_type_of_report :=
                           'SEL_UNAPPROVED_INVOICES_WITH_LA';
              end if;
        else
           if (p_unapprove_flag_1 <> 'Y') then
              l_type_of_report := 'SEL_BATCH_INVOICES_WITH_LA';
           else
              l_type_of_report := 'SEL_UNAPPROVED_BATCH_WITH_LA';
           end if;
        end if;
   end if;




    if (l_type_of_report = 'SEL_BATCH_INVOICES') then

          P_invoice_amount := 'decode(inv1.cancelled_date, null, inv1.invoice_amount, inv1.cancelled_amount)';
          C_batch_predicate := 'and inv1.batch_id = '||C_batch_id;
                   P_flexdata1 := 'null';
          P_gl_code_combinations2 := ' ';
	  C_match_status_predicate := ' ';

    elsif (l_type_of_report = 'SEL_BATCH_INVOICES_WITH_LA') then

          P_invoice_amount := 'decode(inv1.cancelled_date, null, inv1.invoice_amount, inv1.cancelled_amount)';
          C_batch_predicate := 'and inv1.batch_id = '||C_batch_id;
	  C_match_status_predicate := ' ';
                   C_gl_ccid2_predicate := 'and GC2.code_combination_id(+) = dist.accts_pay_code_combination_id';


    elsif (l_type_of_report = 'SEL_UNAPPROVED_BATCH') then

          P_invoice_amount := 'inv1.invoice_amount';
         	  C_batch_predicate := 'and inv1.batch_id = '||C_batch_id;
          P_flexdata1 := 'null';
          P_gl_code_combinations2 := ' ';
	  C_match_status_predicate := ' ';

    elsif (l_type_of_report = 'SEL_UNAPPROVED_BATCH_WITH_LA') then

          P_invoice_amount := 'inv1.invoice_amount';
                   C_batch_predicate := 'and inv1.batch_id = '||C_batch_id;
          C_match_status_predicate := 'and (dist.match_status_flag = ''N'' or dist.match_status_flag is null)';
          C_gl_ccid2_predicate := 'and GC2.code_combination_id(+) = dist.accts_pay_code_combination_id';

    elsif (l_type_of_report = 'SEL_INVOICES') then

          P_invoice_amount := 'decode(inv1.cancelled_date, null, inv1.invoice_amount, inv1.cancelled_amount)';
                   P_dynamic_batch_orderby := 'bat.batch_id';
          C_orderby_batch_id := 'bat.batch_id,';
          P_flexdata1 := 'null';
          P_gl_code_combinations2 := ' ';
	  C_batch_predicate := ' ';
	  C_match_status_predicate := ' ';

    elsif (l_type_of_report = 'SEL_INVOICES_WITH_LA') then

          P_invoice_amount := 'decode(inv1.cancelled_date, null, inv1.invoice_amount, inv1.cancelled_amount)';
                   P_dynamic_batch_orderby := 'bat.batch_id';
          C_orderby_batch_id := 'bat.batch_id,';
	  C_batch_predicate := ' ';
	  C_match_status_predicate := ' ';
          C_gl_ccid2_predicate := 'and GC2.code_combination_id(+) = dist.accts_pay_code_combination_id';

    elsif (l_type_of_report = 'SEL_UNAPPROVED_INVOICES') then

          P_invoice_amount := 'inv1.invoice_amount';
          C_match_status_predicate := 'and (dist.match_status_flag = ''N'' or dist.match_status_flag is null)';
         	  P_dynamic_batch_orderby := 'bat.batch_id';
          C_orderby_batch_id := 'bat.batch_id,';
          P_flexdata1 := 'null';
          P_gl_code_combinations2 := ' ';
	  C_batch_predicate := ' ';

    elsif (l_type_of_report = 'SEL_UNAPPROVED_INVOICES_WITH_LA') then

          P_invoice_amount := 'inv1.invoice_amount';
          C_match_status_predicate := 'and (dist.match_status_flag = ''N'' or dist.match_status_flag is null)';
         	  P_dynamic_batch_orderby := 'bat.batch_id';
          C_orderby_batch_id := 'bat.batch_id,';
	  C_batch_predicate := ' ';
          C_gl_ccid2_predicate := 'and GC2.code_combination_id(+) = dist.accts_pay_code_combination_id';

      else
               C_batch_predicate := ' ';
	       C_match_status_predicate := ' ' ;
    end if;




    C_invoice_cancelled_predicate := 'AND 1 = DECODE('''||P_CANCELLED_FLAG||''', ''N'', 1, ''Y'', DECODE(inv1.cancelled_date, NULL, 0, 1))';


    if (C_user_id is not null) then
        C_created_by_predicate := 'and inv1.created_by = '||C_user_id;
    ELSE
        C_created_by_predicate := ' ';
    end if;



    if (P_start_date is not null) then
        C_start_date_predicate := 'and inv1.creation_date >= TO_DATE('''||to_char(P_start_date
              ,'DD-MON-YYYY')||' 00:00:00'', ''DD-MON-YYYY HH24:MI:SS'')';
    ELSE
        C_start_date_predicate := ' ';
    end if;

    if (P_end_date is not null) then
        C_end_date_predicate :=  'and inv1.creation_date <= TO_DATE('''||to_char(P_end_date
              ,'DD-MON-YYYY')||' 23:59:59'', ''DD-MON-YYYY HH24:MI:SS'')';
    ELSE
        C_end_date_predicate := ' ';
    end if;

    if (P_INVOICE_TYPE is not null) then
	C_INV_TYPE_PRED := 'and inv1.invoice_type_lookup_code = '''||P_INVOICE_TYPE||'''';
    ELSE
        C_INV_TYPE_PRED := ' ';

    end if;


    C_INVOICE_ID_PREDICATE := 'AND inv1.invoice_id = lines.invoice_id(+) '||
                               'AND lines.invoice_id = dist.invoice_id(+) '||
                               'AND lines.line_number = dist.invoice_line_number(+) ';

    if P_ACCOUNTING_PERIOD is not null then
      BEGIN
         SELECT  start_date, end_date
         INTO    l_start_date, l_end_date
         FROM    gl_period_statuses
         WHERE   period_name = P_ACCOUNTING_PERIOD
           AND   set_of_books_id = P_SOB_ID
           AND     application_id = 200
           AND NVL(adjustment_period_flag, 'N') = 'N';

         C_ACCOUNTING_DATE_PREDICATE := 'AND dist.accounting_date between '''||
            to_char(l_start_date)||''' AND '''||to_char(l_end_date)||'''';

                                             C_INVOICE_ID_PREDICATE := 'AND inv1.invoice_id = dist.invoice_id';

      EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;

      END;
     ELSE
         C_ACCOUNTING_DATE_PREDICATE := ' ';
    end if;

return(TRUE);
END;

FUNCTION GET_SUPPLIER_INVOICE_INFO RETURN BOOLEAN IS

l_supplier_name   po_vendors.vendor_name%TYPE;
l_invoice_type    varchar2(80);

BEGIN

  IF p_vendor_id IS NOT NULL THEN

     Select vendor_name
       into l_supplier_name
       from po_vendors
       where vendor_id = p_vendor_id;

      c_supplier_name := l_supplier_name;

  END IF;



  IF p_invoice_type IS NOT NULL THEN

     Select displayed_field
       into l_invoice_type
       from ap_lookup_codes
       where lookup_code = p_invoice_type
       and   lookup_type = 'INVOICE TYPE'
       and   nvl(inactive_date, sysdate+1) > sysdate;

     c_invoice_type1 :=  l_invoice_type;

  END IF;


RETURN (TRUE);

RETURN NULL; EXCEPTION

  WHEN   OTHERS  THEN
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
 Function C_COMPANY_NAME_HEADER_p return varchar2 is
	Begin
	 return C_COMPANY_NAME_HEADER;
	 END;
 Function C_CHART_OF_ACCOUNTS_ID_p return number is
	Begin
	 return C_CHART_OF_ACCOUNTS_ID;
	 END;
 Function C_NLS_NA_p return varchar2 is
	Begin
	 return C_NLS_NA;
	 END;
 Function C_NLS_NO_DATA_EXISTS_p return varchar2 is
	Begin
	 return C_NLS_NO_DATA_EXISTS;
	 END;
 Function C_SHOW_LIB_ACCT_p return varchar2 is
	Begin
	 return C_SHOW_LIB_ACCT;
	 END;
 Function C_BATCH_FLAG_p return varchar2 is
	Begin
	 return C_BATCH_FLAG;
	 END;
 Function C_BATCH_ID_p return varchar2 is
	Begin
	 return C_BATCH_ID;
	 END;
 Function C_USER_ID_p return varchar2 is
	Begin
	 return C_USER_ID;
	 END;
 Function C_liability_acct_flex_p return varchar2 is
	Begin
	 return C_liability_acct_flex;
	 END;
 Function C_batch_predicate_p return varchar2 is
	Begin
	 return C_batch_predicate;
	 END;
 Function C_match_status_predicate_p return varchar2 is
	Begin
	 return C_match_status_predicate;
	 END;
 Function C_invoice_cancelled_pred_1 return varchar2 is
	Begin
	 return C_invoice_cancelled_predicate;
	 END;
 Function C_created_by_predicate_p return varchar2 is
	Begin
	 return C_created_by_predicate;
	 END;
 Function C_start_date_predicate_p return varchar2 is
	Begin
	 return C_start_date_predicate;
	 END;
 Function C_end_date_predicate_p return varchar2 is
	Begin
	 return C_end_date_predicate;
	 END;
 Function C_gl_ccid2_predicate_p return varchar2 is
	Begin
	 return C_gl_ccid2_predicate;
	 END;
 Function C_orderby_batch_id_p return varchar2 is
	Begin
	 return C_orderby_batch_id;
	 END;
 Function C_INV_TYPE_PRED_p return varchar2 is
	Begin
	 return C_INV_TYPE_PRED;
	 END;
 Function C_NLS_END_OF_REPORT_p return varchar2 is
	Begin
	 return C_NLS_END_OF_REPORT;
	 END;
 Function C_INVOICE_ID_PREDICATE_p return varchar2 is
	Begin
	 return C_INVOICE_ID_PREDICATE;
	 END;
 Function C_ACCOUNTING_DATE_PREDICATE_p return varchar2 is
	Begin
	 return C_ACCOUNTING_DATE_PREDICATE;
	 END;
 Function C_CANCELLED_INVOICES_ONLY_p return varchar2 is
	Begin
	 return C_CANCELLED_INVOICES_ONLY;
	 END;
 Function C_UNAPPROVED_INVOICES_ONLY_p return varchar2 is
	Begin
	 return C_UNAPPROVED_INVOICES_ONLY;
	 END;
 Function C_Supplier_Name_p return varchar2 is
	Begin
	 return C_Supplier_Name;
	 END;
 Function C_INVOICE_TYPE1_p return varchar2 is
	Begin
	 return C_INVOICE_TYPE1;
	 END;
END AP_APXINRIR_XMLP_PKG ;



/
