--------------------------------------------------------
--  DDL for Package Body AR_ARXPDI_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_ARXPDI_XMLP_PKG" AS
/* $Header: ARXPDIB.pls 120.1 2008/01/11 10:47:41 abraghun noship $ */
function BeforeReport return boolean is
begin
	P_CONC_REQUEST_ID:=FND_GLOBAL.conc_request_id;
/*SRW.USER_EXIT('FND SRWINIT');*/null;
get_boiler_plates ;
begin
 P_CONS_PROFILE_VALUE := AR_SETUP.value('AR_SHOW_BILLING_NUMBER',null);
exception when others then null;
end;
If    ( P_CONS_PROFILE_VALUE = 'N' ) then
      lp_query_show_bill        := 'to_char(NULL)';
      --lp_table_show_bill        := null;
      --lp_where_show_bill        := null;
	  lp_table_show_bill        := ' ';
      lp_where_show_bill        := ' ';
Else  lp_query_show_bill        := 'ci.cons_billing_number';
      lp_table_show_bill        := 'ar_cons_inv ci,';
      lp_where_show_bill        := 'and ps.cons_inv_id = ci.cons_inv_id(+)';
End if;
p_as_of := rtrim(ARP_STANDARD.FND_MESSAGE('AR_REPORTS_AS_OF'));
p_as_of := p_as_of || ' ';
p_balance_due := ARPT_SQL_FUNC_UTIL.get_lookup_meaning('SORT_BY_ARXPDI','Balance Due');
p_customer := ARPT_SQL_FUNC_UTIL.get_lookup_meaning('SORTY_BY_ARXPDI','Customer');
p_salesperson := ARPT_SQL_FUNC_UTIL.get_lookup_meaning('SORT_BY_ARXPDI','Salesperson');
  return (TRUE);
end;
function AfterReport return boolean is
begin
/*SRW.USER_EXIT('FND SRWEXIT');*/null;
  return (TRUE);
end;
function report_nameformula(Company_Name in varchar2) return varchar2 is
begin
DECLARE
    l_report_name  VARCHAR2(80);
    l_amount_low   VARCHAR2 (15);
    l_amount_high  VARCHAR2 (15);
    l_past_days_due_low VARCHAR2 (20);
    l_past_days_due_high VARCHAR2 (20);
BEGIN
 if p_past_days_due_low is NULL then
     l_past_days_due_low := '   ';
   else
     l_past_days_due_low := p_past_days_due_low ;
   end if ;
 if p_past_days_due_high is NULL then
     l_past_days_due_high := '   ';
   else
     l_past_days_due_high := p_past_days_due_high ;
   end if ;
    rp_past_days_from := l_past_days_due_low;
    rp_past_days_to   := l_past_days_due_high;
   p_days_past_due_from := ARP_STANDARD.FND_MESSAGE('AR_REPORTS_DAYS_PD_FROM_TO',
                            'FROM_DATE',rtrim(l_past_days_due_low),
                            'TO_DATE',rtrim(l_past_days_due_high));
   RP_Company_Name := Company_Name ;
   rp_as_of_date := TO_CHAR(p_as_of_date, 'DD-MON-YY');
   if p_amount_low is NULL then
     l_amount_low := '   ';
   else
     l_amount_low := p_amount_low ;
   end if ;
   if p_amount_high is NULL then
     l_amount_high := '   ';
   else
     l_amount_high := p_amount_high ;
   end if ;
   rp_balance_from := l_amount_low;
   rp_balance_to   := l_amount_high;
   p_balance_due_from := ARP_STANDARD.FND_MESSAGE('AR_REPORTS_BAL_FROM_TO',
                          'LOW_AMT',rtrim(l_amount_low),
                          'HIGH_AMT',rtrim(l_amount_high));
    SELECT substr(cp.user_concurrent_program_name, 1, 80)
    INTO   l_report_name
    FROM   FND_CONCURRENT_PROGRAMS_VL cp,
           FND_CONCURRENT_REQUESTS cr
    WHERE  cr.request_id = P_CONC_REQUEST_ID
    AND    cp.application_id = cr.program_application_id
    AND    cp.concurrent_program_id = cr.concurrent_program_id;
l_report_name:= substr(l_report_name,1,instr(l_report_name,' (XML)'));
    RP_Report_Name := l_report_name;
    RETURN(l_report_name);
EXCEPTION
    WHEN NO_DATA_FOUND
    THEN RP_REPORT_NAME := NULL;
         RETURN(NULL);
END;
RETURN NULL; end;
function AfterPForm return boolean is
begin
BEGIN
  if ( p_order_by = 'Balance Due') then
      lp_order_by  :=
                    ' ORDER BY 1 ASC,2 ASC,4 DESC,6 ASC,7 ASC,8 ASC ,  ps.invoice_currency_code , PARTY.PARTY_NAME ,
                    CUST.CUST_ACCOUNT_ID , ps.trx_number , ps.customer_trx_id , ps.due_date , ps.amount_due_original desc , ps.tax_original desc , ps.amount_due_remaining desc'
                   ;
  elsif ( p_order_by = 'Customer') then
      lp_order_by  :=
                    'ORDER BY 1 ASC,2 ASC,4 DESC,6 ASC,7 ASC,8 ASC ,  ps.invoice_currency_code , PARTY.PARTY_NAME ,
                    CUST.CUST_ACCOUNT_ID , ps.trx_number , ps.customer_trx_id , ps.due_date , ps.amount_due_original desc , ps.tax_original desc , ps.amount_due_remaining desc';
  elsif ( p_order_by = 'Salesperson') then
      lp_order_by  :=
                    'ORDER BY 1 ASC,2 ASC,4 DESC,6 ASC,7 ASC,8 ASC ,  ps.invoice_currency_code , srep.name , PARTY.PARTY_NAME ,
                    CUST.CUST_ACCOUNT_ID , ps.trx_number , ps.customer_trx_id , ps.due_date , ps.amount_due_original desc , ps.tax_original desc , ps.amount_due_remaining desc'
                    ;
  end if ;
  if p_past_days_due_low is NOT NULL  then
    lp_past_days_due_low := 'and ( :p_as_of_date  - :p_past_days_due_low) >=  ps.due_date + 0 ';
  end if ;
  if p_past_days_due_high is NOT NULL then
    lp_past_days_due_high := 'and ( :p_as_of_date - :p_past_days_due_high ) <=  ps.due_date + 0  ';
  end if ;
  if p_amount_low is NOT NULL  then
    lp_amount_low := 'and ps.due_amount  >= :p_amount_low ';
  end if ;
  if p_amount_high is NOT NULL then
    lp_amount_high := 'and ps.due_amount <= :p_amount_high ';
  end if ;
  if p_collector_low  is NOT NULL and p_collector_high  is NOT NULL  then
      if p_collector_low = p_collector_high  then
      lp_collector_low := ' and col.name  = :p_collector_low ';
      else
       lp_collector_low := ' and col.name   >= :p_collector_low ';
       lp_collector_high := ' and col.name  <= :p_collector_high ';
      end if;
  end if ;
  if p_collector_low  is NOT NULL and p_collector_high  is NULL then
    lp_collector_low := ' and col.name  >= :p_collector_low ';
  end if ;
  if p_collector_high  is NOT NULL and p_collector_low  is NULL  then
    lp_collector_high := ' and col.name  <= :p_collector_high ';
  end if ;
if p_customer_name_low is NOT NULL and p_customer_name_high is NOT NULL then
   if p_customer_name_low = p_customer_name_high then
       lp_customer_name_low  := ' and PARTY.PARTY_NAME  =  :p_customer_name_low ';
   else
   lp_customer_name_low := ' and PARTY.PARTY_NAME  >=  :p_customer_name_low ';
   lp_customer_name_high := ' and PARTY.PARTY_NAME <=  :p_customer_name_high ';
   end if;
end if;
 if p_customer_name_low is NOT NULL and p_customer_name_high is NULL then
    lp_customer_name_low := ' and PARTY.PARTY_NAME  >=  :p_customer_name_low ';
  end if ;
  if p_customer_name_high is NOT NULL  and p_customer_name_low is NULL then
    lp_customer_name_high := ' and PARTY.PARTY_NAME <=  :p_customer_name_high ';
  end if ;
  ph_customer_number_low := p_customer_number_low ;
  ph_customer_number_high := p_customer_number_high ;
   if p_customer_number_low is NOT NULL and  p_customer_number_high is NOT NULL  then
     if  p_customer_number_low  = p_customer_number_high then
     lp_customer_number_low := ' and CUST.ACCOUNT_NUMBER = :p_customer_number_low ' ;
     else
     lp_customer_number_low := ' and CUST.ACCOUNT_NUMBER >= :p_customer_number_low ' ;
     lp_customer_number_high := 'and CUST.ACCOUNT_NUMBER <= :p_customer_number_high ' ;
     end if;
  end if;
  if p_customer_number_low is NOT NULL and p_customer_number_high is NULL then
    lp_customer_number_low := ' and CUST.ACCOUNT_NUMBER >= :p_customer_number_low ' ;
  end if  ;
  if p_customer_number_high is NOT NULL and p_customer_number_low is NULL  then
    lp_customer_number_high := ' and CUST.ACCOUNT_NUMBER <= :p_customer_number_high ' ;
  end if  ;
 if p_invoice_type_low is NOT NULL and p_invoice_type_high is NOT NULL then
     if p_invoice_type_low = p_invoice_type_high then
     lp_invoice_type_low  := ' and arpt_sql_func_util.get_trx_type_details(ctx.cust_trx_type_id ,''NAME'')  = :p_invoice_type_low ' ;
     else
    lp_invoice_type_low  := ' and arpt_sql_func_util.get_trx_type_details(ctx.cust_trx_type_id ,''NAME'')  >= :p_invoice_type_low ' ;
    lp_invoice_type_high  := ' and arpt_sql_func_util.get_trx_type_details(ctx.cust_trx_type_id ,''NAME'') <= :p_invoice_type_high ' ;
     end if ;
  end if ;
  if p_invoice_type_low is NOT NULL and p_invoice_type_high is  NULL then
    lp_invoice_type_low  := ' and arpt_sql_func_util.get_trx_type_details(ctx.cust_trx_type_id ,''NAME'') >= :p_invoice_type_low ' ;
  end if ;
  if p_invoice_type_high is NOT NULL and p_invoice_type_low is NULL then
    lp_invoice_type_high  := ' and arpt_sql_func_util.get_trx_type_details(ctx.cust_trx_type_id ,''NAME'') <= :p_invoice_type_high ' ;
  end if ;
 if p_salesrep_low is NOT NULL then
   lp_salesrep_low := ' and  ( (srep.name  >= :p_salesrep_low) ) ' ;
  end if ;
 if p_salesrep_high is NOT NULL then
   lp_salesrep_high := ' and  ( (srep.name  <= :p_salesrep_high) ) ' ;
  end if ;
/*SRW.MESSAGE(100, 'p_as_of_date: '||p_as_of_date);*/null;
END ;
  return (TRUE);
end;
function c_temp_salformula(Currency_Code in varchar2,Salesrep in varchar2) return varchar2 is
begin
DECLARE
l_temp_curr  VARCHAR2 (270);
BEGIN
  /*srw.reference (Currency_Code);*/null;
  /*srw.reference (Salesrep);*/null;
  if (p_order_by  = 'Salesperson') then
    rp_sale_curr  := 'Salesrep:  '||''||Salesrep ;
    rp_curr       := 'Currency:  '||''||Currency_Code;
  else
    rp_sale_curr  := 'Currency:  '||''||Currency_Code;
  end if ;
return (l_temp_curr);
end ;
RETURN NULL; end;
function c_data_foundformula(Currency_Code in varchar2) return varchar2 is
begin
RP_DATA_FOUND  := Currency_Code ;
/*srw.message('100','rp_data_found = ' || RP_DATA_FOUND);*/null;
return (0);
end;
function c_custom_checkformula(Currency_Code in varchar2, Cust_ID in number) return varchar2 is
begin
begin
rp_cust_check := 0 ;
rp_curr_check :=  0 ;
if (rp_old_curr <> Currency_Code) OR (rp_old_curr  is NULL) then
  rp_old_customer := '              ';
  rp_curr_check   := 1 ;
end if ;
rp_old_curr := Currency_Code ;
if (rp_old_customer = to_char(Cust_ID)) then
  rp_cust_check := 0 ;
else
  rp_cust_check := 1 ;
end if ;
rp_old_customer := Cust_ID;
end ;
RETURN NULL; end;
procedure get_boiler_plates is
w_industry_code varchar2(20);
w_industry_stat varchar2(20);
begin
if fnd_installation.get(0, 0,
                        w_industry_stat,
                        w_industry_code) then
   if w_industry_code = 'C' then
      c_salesrep_title := null ;
   else
      get_lookup_meaning('IND_SALES_REP',
                         w_industry_code,
                         c_salesrep_title);
   end if;
end if;
c_industry_code :=   w_Industry_code ;
end ;
procedure get_lookup_meaning(p_lookup_type      in varchar2,
                             p_lookup_code      in varchar2,
                             p_lookup_meaning  in out NOCOPY varchar2)
                            is
w_meaning varchar2(80);
begin
select meaning
  into w_meaning
  from fnd_lookups
 where lookup_type = p_lookup_type
   and lookup_code = p_lookup_code ;
p_lookup_meaning := w_meaning ;
exception
   when no_data_found then
                        p_lookup_meaning := null ;
end ;
function set_display_for_core return boolean is
begin
if c_industry_code = 'C' then
   return(TRUE);
else
   if c_salesrep_title is not null then
      return(FALSE);
   else
      return(TRUE);
   end if;
end if;
RETURN NULL; end;
function set_display_for_gov return boolean is
begin
if c_industry_code = 'C' then
   return(FALSE);
else
   if c_salesrep_title is not null then
      return(TRUE);
   else
      return(FALSE);
   end if;
end if;
RETURN NULL; end ;
function invoice_number_consformula(invoice_number in varchar2, cons_bill_number in varchar2) return varchar2 is
begin
/*srw.reference(invoice_number);*/null;
/*srw.reference(cons_bill_number);*/null;
If    ( P_CONS_PROFILE_VALUE = 'N' ) then
      return(substr(invoice_number,1,40));
 ELSIF ( P_CONS_PROFILE_VALUE = 'Y' ) AND
       (cons_bill_number is NULL) then
       return(substr(invoice_number,1,40));
 ELSE
       return(substr(substr(invoice_number,1,NVL(length(invoice_number), 0))||'/'||cons_bill_number,1,40));
END IF;
RETURN NULL; end;
function CF_ORDER_BYFormula return Char is
   order_meaning AR_LOOKUPS.MEANING%TYPE;
begin
    Order_meaning := ARPT_SQL_FUNC_UTIL.get_lookup_meaning('SORT_BY_ARXPDI',p_order_by);
  RETURN (ORDER_MEANING);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN(P_ORDER_BY);
end;
function CF_salespersonFormula return Char is
     order_meaning AR_LOOKUPS.MEANING%TYPE;
begin
    Order_meaning := ARPT_SQL_FUNC_UTIL.get_lookup_meaning('SORT_BY_ARXPDI','Salesperson');
  RETURN (ORDER_MEANING);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN('Salesperson');
end;
--Functions to refer Oracle report placeholders--
 Function ACCT_BAL_APROMPT_p return varchar2 is
	Begin
	 return ACCT_BAL_APROMPT;
	 END;
 Function RP_OLD_CURR_p return varchar2 is
	Begin
	 return RP_OLD_CURR;
	 END;
 Function RP_CURR_CHECK_p return number is
	Begin
	 return RP_CURR_CHECK;
	 END;
 Function RP_OLD_CUSTOMER_p return varchar2 is
	Begin
	 return RP_OLD_CUSTOMER;
	 END;
 Function RP_CUST_CHECK_p return number is
	Begin
	 return RP_CUST_CHECK;
	 END;
 Function RP_COMPANY_NAME_p return varchar2 is
	Begin
	 return RP_COMPANY_NAME;
	 END;
 Function RP_REPORT_NAME_p return varchar2 is
	Begin
	 return RP_REPORT_NAME;
	 END;
 Function RP_DATA_FOUND_p return varchar2 is
	Begin
	 return RP_DATA_FOUND;
	 END;
 Function RP_AS_OF_DATE_p return varchar2 is
	Begin
	 return RP_AS_OF_DATE;
	 END;
 Function RP_PAST_DAYS_p return varchar2 is
	Begin
	 return RP_PAST_DAYS;
	 END;
 Function RP_BALANCE_p return varchar2 is
	Begin
	 return RP_BALANCE;
	 END;
 Function RP_SALE_CURR_p return varchar2 is
	Begin
	 return RP_SALE_CURR;
	 END;
 Function RP_CURR_p return varchar2 is
	Begin
	 return RP_CURR;
	 END;
 Function c_industry_code_p return varchar2 is
	Begin
	 return c_industry_code;
	 END;
 Function c_salesrep_title_p return varchar2 is
	Begin
	 return c_salesrep_title;
	 END;
 Function rp_balance_from_p return varchar2 is
	Begin
	 return rp_balance_from;
	 END;
 Function rp_balance_to_p return varchar2 is
	Begin
	 return rp_balance_to;
	 END;
 Function rp_past_days_from_p return varchar2 is
	Begin
	 return rp_past_days_from;
	 END;
 Function rp_past_days_to_p return varchar2 is
	Begin
	 return rp_past_days_to;
	 END;
END AR_ARXPDI_XMLP_PKG ;



/
