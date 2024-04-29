--------------------------------------------------------
--  DDL for Package Body AR_ARXDIR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_ARXDIR_XMLP_PKG" AS
/* $Header: ARXDIRB.pls 120.0 2007/12/27 13:47:17 abraghun noship $ */

function BeforeReport return boolean is
begin

/*SRW.USER_EXIT('FND SRWINIT');*/null;

P_ORDER_BY_T:=UPPER(P_ORDER_BY);

rp_sum_for := ARP_STANDARD.FND_MESSAGE(
                  'AR_REPORTS_SUM_FOR');



begin

 P_CONS_PROFILE_VALUE := AR_SETUP.value('AR_SHOW_BILLING_NUMBER',null);

     /*srw.message ('101', 'Consolidated Billing Profile:  ' || P_CONS_PROFILE_VALUE);*/null;


exception
     when others then
          /*srw.message ('101', 'Consolidated Billing Profile:  Failed.');*/null;

end;


If    ( P_CONS_PROFILE_VALUE = 'N' ) then
      lp_query_show_bill        := 'to_char(NULL)';
      --lp_table_show_bill        := null;
      --lp_where_show_bill        := null;
      lp_table_show_bill        := ' ';
      lp_where_show_bill        := ' ';

Else  lp_query_show_bill        := 'ci.cons_billing_number';
      lp_table_show_bill        := 'ar_cons_inv ci,';
      lp_where_show_bill        := 'and ar_payment_schedules.cons_inv_id = ci.cons_inv_id(+)';

End if;

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
BEGIN
    RP_Company_Name := Company_Name;

    SELECT substr(cp.user_concurrent_program_name,1,80)
    INTO   l_report_name
    FROM   FND_CONCURRENT_PROGRAMS_VL cp,
           FND_CONCURRENT_REQUESTS cr
    WHERE  cr.request_id = P_CONC_REQUEST_ID
    AND    cp.application_id = cr.program_application_id
    AND    cp.concurrent_program_id = cr.concurrent_program_id;

    RP_Report_Name := l_report_name;
    RETURN(l_report_name);
EXCEPTION
    WHEN NO_DATA_FOUND
    THEN RP_REPORT_NAME := null;
         RETURN(NULL);
END;
RETURN NULL; end;

function AfterPForm return boolean is
begin


BEGIN

if p_due_date_low is NOT NULL   then
  lp_due_date_low := 'and ar_payment_schedules.due_date >= :p_due_date_low';
end if ;
if p_due_date_high is NOT NULL   then
  lp_due_date_high := 'and ar_payment_schedules.due_date <= :p_due_date_high';
end if ;

if p_item_number_low is NOT NULL   then
  lp_item_number_low  := ' and ar_payment_schedules.trx_number  >= :p_item_number_low' ;
end if ;

if p_item_number_high is  NOT NULL  then
  lp_item_number_high  := ' and ar_payment_schedules.trx_number  <= :p_item_number_high' ;
end if ;

if p_customer_name_low is NOT NULL   then
  lp_customer_name_low := 'and PARTY.PARTY_NAME  >= :p_customer_name_low ' ;
end if ;

if p_customer_name_high is NOT NULL   then
  lp_customer_name_high := 'and PARTY.PARTY_NAME  <= :p_customer_name_high ' ;
end if ;

if p_customer_number_low is NOT NULL   then
  lp_customer_number_low := 'and CUST.ACCOUNT_NUMBER  >= :p_customer_number_low ' ;
end if ;

if p_customer_number_high is NOT NULL   then
  lp_customer_number_high := 'and CUST.ACCOUNT_NUMBER  <= :p_customer_number_high ' ;
end if ;

if p_collector_low is NOT NULL   then
  lp_collector_low  := 'and ar_collectors.name >= :p_collector_low ';
end if ;

if p_collector_high is NOT NULL   then
  lp_collector_high  := 'and ar_collectors.name <= :p_collector_high ';
end if ;

if p_invoice_status is NOT NULL then
   IF p_invoice_status = 'O' THEN
      --p_invoice_status := 'OP';
      p_invoice_status_param := 'OP';
   ELSE
      --p_invoice_status := 'CL' ;
      p_invoice_status_param := 'CL' ;
   END IF;
   --lp_status := ' and ar_payment_schedules.status = :p_invoice_status ';
   lp_status := ' and ar_payment_schedules.status = AR_ARXDIR_XMLP_PKG.p_invoice_status_param ';
end if;
if ( UPPER (p_order_by) = 'CUSTOMER') then
  lp_order_by := 'order by  '||
  	        'ar_payment_schedules.invoice_currency_code,'||
    	        'PARTY.PARTY_NAME,'||
		'CUST.CUST_ACCOUNT_ID,'||
		'CUST.ACCOUNT_NUMBER,'||
  	        'ar_payment_schedules.due_date,'||
  	        'ar_payment_schedules.trx_number'
		;
elsif ( UPPER (p_order_by) = 'INVOICE NUMBER') then
  lp_order_by := 'order by  '||
  	        'ar_payment_schedules.invoice_currency_code,'||
  	        'ar_payment_schedules.trx_number,'||
    	        'PARTY.PARTY_NAME,'||
		'CUST.CUST_ACCOUNT_ID,'||
		'CUST.ACCOUNT_NUMBER,'||
  	        'ar_payment_schedules.due_date'
		;
elsif ( UPPER (p_order_by) = 'DUE DATE') then
  lp_order_by := 'order by  '||
  	        'ar_payment_schedules.invoice_currency_code,'||
  	        'ar_payment_schedules.due_date,'||
    	        'PARTY.PARTY_NAME,'||
  		'CUST.CUST_ACCOUNT_ID,'||
		'CUST.ACCOUNT_NUMBER,'||
	        'ar_payment_schedules.trx_number'
		;
end if ;

END ;
  return (TRUE);
end;

function c_data_not_foundformula(Currency_Main in varchar2) return number is
begin

rp_data_found := Currency_Main ;
return (0);
end;

function c_cust_summary_labelformula(Dummy_Customer_Name in varchar2) return varchar2 is
begin

DECLARE

l_temp    VARCHAR2 (70);

BEGIN

l_temp := rp_sum_for || ' ' || Dummy_Customer_Name;
return (l_temp);

END ;

RETURN NULL; end;

function c_currency_summary_labelformul(Currency_Main in varchar2) return varchar2 is
begin

DECLARE

l_temp       VARCHAR2 (100);

BEGIN

l_temp := rp_sum_for || ' ' || Currency_Main;
return (l_temp);

END ;
RETURN NULL; end;

function cons_numberformula(Number in varchar2, cons_bill_number in varchar2) return varchar2 is
begin

/*srw.reference(Number);*/null;

/*srw.reference(cons_bill_number);*/null;


If    ( P_CONS_PROFILE_VALUE = 'N' ) then
      return(substr(Number,1,38));
 ELSIF ( P_CONS_PROFILE_VALUE = 'Y' ) AND
       (cons_bill_number is NULL) then
       return(substr(Number,1,38));
 ELSE
       return(substr(substr(Number,1,NVL(length(Number), 0))||'/'||cons_bill_number,1,38));

END IF;
RETURN NULL; end;

--Functions to refer Oracle report placeholders--

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
 Function RPD_REPORT_TOTAL_INV_p return varchar2 is
	Begin
	 return RPD_REPORT_TOTAL_INV;
	 END;
 Function RPD_REPORT_TOTAL_BAL_p return varchar2 is
	Begin
	 return RPD_REPORT_TOTAL_BAL;
	 END;
 Function RPD_REPORT_TOTAL_DISP_p return varchar2 is
	Begin
	 return RPD_REPORT_TOTAL_DISP;
	 END;
 Function rp_sum_for_p return varchar2 is
	Begin
	 return rp_sum_for;
	 END;
END AR_ARXDIR_XMLP_PKG ;


/
