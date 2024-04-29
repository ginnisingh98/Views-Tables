--------------------------------------------------------
--  DDL for Package Body AR_ARXASR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_ARXASR_XMLP_PKG" AS
/* $Header: ARXASRB.pls 120.0 2007/12/27 13:33:19 abraghun noship $ */

function BeforeReport return boolean is
begin
	P_CONC_REQUEST_ID:=FND_GLOBAL.conc_request_id;
/*SRW.USER_EXIT('FND SRWINIT');*/null;





begin

 P_CONS_PROFILE_VALUE := AR_SETUP.value('AR_SHOW_BILLING_NUMBER',null);
     /*srw.message ('101', 'Consolidated Billing Profile:  ' || P_CONS_PROFILE_VALUE);*/null;


exception
     when others then
     /*srw.message ('101', 'Consolidated Billing Profile:  Failed.');*/null;

end;


     If    ( P_CONS_PROFILE_VALUE = 'N' ) then
           lp_query_show_bill        := 'to_char(NULL)';
          -- lp_table_show_bill        := null;
           lp_table_show_bill        := ' ';
          -- lp_where_show_bill        := null;
			lp_where_show_bill        := ' ';

     Else  lp_query_show_bill        := 'ci.cons_billing_number';
           lp_table_show_bill        := 'ar_cons_inv ci,';
           lp_where_show_bill        := 'and ps.cons_inv_id = ci.cons_inv_id(+)';

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
    l_report_name  VARCHAR2(240);
BEGIN
    RP_Company_Name := Company_Name;
    SELECT cp.user_concurrent_program_name
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
    THEN RP_REPORT_NAME := NULL;
         RETURN(NULL);
END;
RETURN NULL; end;

function AfterPForm return boolean is
begin


 /*SRW.USER_EXIT('FND SRWINIT');*/null;


  p_mrcsobtype := 'P';


  lp_ar_system_parameters := 'AR_SYSTEM_PARAMETERS';
  lp_ar_system_parameters_all := 'AR_SYSTEM_PARAMETERS_ALL';
  lp_ar_payment_schedules := 'AR_PAYMENT_SCHEDULES';
  lp_ar_payment_schedules_all := 'AR_PAYMENT_SCHEDULES_ALL';
  lp_ar_adjustments := 'AR_ADJUSTMENTS';
  lp_ar_adjustments_all := 'AR_ADJUSTMENTS_ALL';
  lp_ar_cash_receipt_history := 'AR_CASH_RECEIPT_HISTORY';
  lp_ar_cash_receipt_history_all := 'AR_CASH_RECEIPT_HISTORY_ALL';
  lp_ar_batches := 'AR_BATCHES';
  lp_ar_batches_all := 'AR_BATCHES_ALL';
  lp_ar_cash_receipts := 'AR_CASH_RECEIPTS';
  lp_ar_cash_receipts_all := 'AR_CASH_RECEIPTS_ALL';
  lp_ar_distributions := 'AR_DISTRIBUTIONS';
  lp_ar_distributions_all := 'AR_DISTRIBUTIONS_ALL';
  lp_ra_customer_trx := 'RA_CUSTOMER_TRX';
  lp_ra_customer_trx_all := 'RA_CUSTOMER_TRX_ALL';
  lp_ra_batches := 'RA_BATCHES';
  lp_ra_batches_all := 'RA_BATCHES_ALL';
  lp_ra_cust_trx_gl_dist := 'RA_CUST_TRX_LINE_GL_DIST';
  lp_ra_cust_trx_gl_dist_all := 'RA_CUST_TRX_LINE_GL_DIST_ALL';
  lp_ar_misc_cash_dists := 'AR_MISC_CASH_DISTRIBUTIONS';
  lp_ar_misc_cash_dists_all := 'AR_MISC_CASH_DISTRIBUTIONS_ALL';
  lp_ar_rate_adjustments := 'AR_RATE_ADJUSTMENTS';
  lp_ar_rate_adjustments_all := 'AR_RATE_ADJUSTMENTS_ALL';
  lp_ar_receivable_apps := 'AR_RECEIVABLE_APPLICATIONS';
  lp_ar_receivable_apps_all := 'AR_RECEIVABLE_APPLICATIONS_ALL';



BEGIN



if p_start_account_status is NOT NULL then
  lp_start_account_status1 := 'and   decode(cp_site.collector_id, null, cp_cust.account_status,
			cp_site.account_status ) >= :p_start_account_status' ;
  lp_start_account_status2 := 'and  cp_cust.account_status >= :p_start_account_status' ;

end if ;
if p_end_account_status is NOT NULL then
  lp_end_account_status1 := 'and   decode(cp_site.collector_id, null, cp_cust.account_status,
			cp_site.account_status ) <= :p_end_account_status' ;
  lp_end_account_status2 := 'and  cp_cust.account_status <= :p_end_account_status' ;

end if ;


if p_customer_name_low is NOT NULL then
  lp_customer_name_low := 'and party.party_name  >= :p_customer_name_low';
end if ;
if p_customer_name_high is NOT NULL then
  lp_customer_name_high := 'and party.party_name  <= :p_customer_name_high';
end if ;
if p_customer_number_low is NOT NULL then
  lp_customer_number_low := 'and cust_acct.account_number  >= :p_customer_number_low';
end if ;
if p_customer_number_high is NOT NULL then
  lp_customer_number_high := 'and cust_acct.account_number  <= :p_customer_number_high';
end if ;
if p_collector_name_low is NOT NULL then
  lp_collector_name_low := 'and col.name  >= :p_collector_name_low';
end if ;
if p_collector_name_high is NOT NULL then
  lp_collector_name_high := 'and col.name  <= :p_collector_name_high';
end if ;

if upper (p_order_by) = 'COLLECTOR' then
  lp_order_by := 'order by 1, 6 , 5 , 2 , 3 , 8 , 7 ' ;
elsif  upper (p_order_by) = 'CUSTOMER NUMBER' then
  lp_order_by := ' order by  1 , 3 , 8 , 7 '  ;
else
  lp_order_by := ' order by  1 , 2 , 3 , 8 , 7 ' ;
end if ;

END ;
  return (TRUE);
end;

function c_status_summary_labelformula(status in varchar2) return varchar2 is
begin

return ( status );

end;

function c_data_not_foundformula(status in varchar2) return number is
begin


rp_data_found := nvl(status , 'null') ;

return (0);

end;

--Functions to refer Oracle report placeholders--

 Function RP_COMPANY_NAME_p return varchar2 is
	Begin
	 return RP_COMPANY_NAME;
	 END;
 Function RP_REPORT_NAME_p return varchar2 is
	Begin
	 return substr(RP_REPORT_NAME,1,instr(RP_REPORT_NAME,' (XML)'));
	 END;
 Function RP_DATA_FOUND_p return varchar2 is
	Begin
	 return RP_DATA_FOUND;
	 END;
 Function RPD_REPORT_SUMMARY_p return varchar2 is
	Begin
	 return RPD_REPORT_SUMMARY;
	 END;
END AR_ARXASR_XMLP_PKG ;


/
