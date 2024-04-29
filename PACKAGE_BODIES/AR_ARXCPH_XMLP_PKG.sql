--------------------------------------------------------
--  DDL for Package Body AR_ARXCPH_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_ARXCPH_XMLP_PKG" AS
/* $Header: ARXCPHB.pls 120.0 2007/12/27 13:43:08 abraghun noship $ */

function BeforeReport return boolean is
begin
	P_CONC_REQUEST_ID:=FND_GLOBAL.conc_request_id;
	CP_IN_TRX_DATE_LOW := to_char(P_IN_TRX_DATE_LOW,'DD-MON-YY');
	CP_IN_TRX_DATE_HIGH :=to_char(P_IN_TRX_DATE_HIGH,'DD-MON-YY');
/*SRW.USER_EXIT('FND SRWINIT');*/null;


begin
/*srw.reference(SORT_BY_PHONETICS);*/null;

/*srw.user_exit('FND GETPROFILE
                   NAME="RA_CUSTOMERS_SORT_BY_PHONETICS"
	           FIELD="SORT_BY_PHONETICS"
                   PRINT_ERROR ="N"');*/null;


if SORT_BY_PHONETICS = 'Y' then

	P_SORT := 'PARTY.ORGANIZATION_NAME_PHONETIC';

else

	P_SORT := 'PARTY.PARTY_NAME';

end if;

exception when others then

	P_SORT := 'PARTY.PARTY_NAME';

end;

  return (TRUE);
end;

function AfterReport return boolean is
begin

/*SRW.USER_EXIT('FND SRWEXIT');*/null;
  return (TRUE);
end;

function AfterPForm return boolean is
    sdate     DATE;
begin


     /*srw.message (1000, 'DEBUG:  Doing some sysdate thing.');*/null;


     select sysdate
     into   sdate
     from   dual;

     p_sysdate := sdate;
     if p_in_inv_num_low IS NOT NULL then
	lp_invoice_num_low := ' and  ar_payment_schedules.trx_number >= :p_in_inv_num_low ' ;
     end if;

     if p_in_inv_num_high IS NOT NULL then
	lp_invoice_num_high := ' and  ar_payment_schedules.trx_number <= :p_in_inv_num_high ' ;
     end if;


     /*srw.message (1000, 'DEBUG:  Setting the Customer Name Range.');*/null;


     if p_in_customer_low is not null then
	lp_customer_name_low := ' and PARTY.PARTY_NAME >= :p_in_customer_low ';
     end if;

     if p_in_customer_high is not null then
	lp_customer_name_high := ' and PARTY.PARTY_NAME <= :p_in_customer_high ';
     end if;


     /*srw.message (1000, 'DEBUG:  Setting the Customer Number Range.');*/null;


     if p_in_customer_num_low is not null then
	lp_cust_num_low := ' and CUST.ACCOUNT_NUMBER >= :p_in_customer_num_low ';
     end if;

     if p_in_customer_num_high is not null then
	lp_cust_num_high := ' and CUST.ACCOUNT_NUMBER <=:p_in_customer_num_high ';
     end if;


     /*srw.message (1000, 'DEBUG:  Setting the Trx Date Range.');*/null;


     if p_in_trx_date_low is not null then
	lp_trx_date_low := ' and ar_receivable_applications.apply_date >= :p_in_trx_date_low ';
     end if;

     if p_in_trx_date_high is not null then
	lp_trx_date_high := ' and ar_receivable_applications.apply_date <= :p_in_trx_date_high ';
     else
	lp_trx_date_high := ' and ar_receivable_applications.apply_date <= :p_sysdate ';
     end if;


     /*srw.message (1000, 'DEBUG:  Setting the Collector Range.');*/null;



     if p_in_collector_low is not null then
	lp_collector_low := ' and ar_collectors.name  >= :p_in_collector_low ';
     end if;

     if p_in_collector_high is not null then
	lp_collector_high := ' and ar_collectors.name  <= :p_in_collector_high ';
     end if;


     /*srw.message (1000, 'DEBUG:  Setting the Terms Range.');*/null;


     if p_in_terms_low is not null then
	lp_terms_low  := ' and  nvl(ra_terms.name,''XX'') >= :p_in_terms_low ';
     end if;

     if p_in_terms_high is not null then
	lp_terms_high  := ' and  nvl(ra_terms.name,''XX'') <= :p_in_terms_high ';
     end if;

     return (TRUE);

end;

function report_nameformula(Company_Name in varchar2) return varchar2 is
    l_report_name  VARCHAR2(80);
BEGIN
    RP_Company_Name := Company_Name;
    RP_Report_Name  := '';

    SELECT substr(cp.user_concurrent_program_name,1,80)
    INTO   l_report_name
    FROM   FND_CONCURRENT_PROGRAMS_VL cp,
           FND_CONCURRENT_REQUESTS cr
    WHERE  cr.request_id = P_CONC_REQUEST_ID
    AND    cp.application_id = cr.program_application_id
    AND    cp.concurrent_program_id = cr.concurrent_program_id;

    RP_Report_Name := substr(l_report_name,1,instr(l_report_name,' (XML)'));

    /*srw.message (1000, 'DEBUG:  Concurrent Request Id:  ' || to_char (P_Conc_Request_Id) );*/null;

    /*srw.message (1000, 'DEBUG:  Report Name:  ' || RP_Report_Name);*/null;


    RETURN(l_report_name);
RETURN NULL; EXCEPTION
    WHEN NO_DATA_FOUND THEN
         /*srw.message (1000, 'DEBUG:  Report Name not found.');*/null;

         RETURN('Receipt Analysis - Days Late');
END;

function Report_SubtitleFormula return Char is
begin

begin


RP_SUB_TITLE:= SUBSTRB(ARP_STANDARD.FND_MESSAGE(
				'AR_REPORTS_TRX_DATE_FROM_TO',
				'FROM_DATE',p_in_trx_date_low,
				'TO_DATE',p_in_trx_date_high),1,80);

return(1);
end;
end;

function Sort_OrderFormula return VARCHAR2 is
begin

declare
	sorting_order VARCHAR2(80);
begin
	        select meaning
        into    sorting_order
        from   ar_lookups
        where  lookup_type='SORT_BY_ARXCPH'
        and    lookup_code = p_in_sorting_order;

RP_Sort_Order := sorting_order;

return(sorting_order);

end;

RETURN NULL; end;

function average_days_lateformula(rec_counter in number, sum_days_late in number) return number is
begin

declare
	av_days_late	number(10);
begin
/*srw.reference(sum_days_late);*/null;

/*srw.reference(rec_counter);*/null;


if rec_counter <> 0 then
	av_days_late :=  sum_days_late / rec_counter;
end if;

	return(av_days_late);
end;
RETURN NULL; end;

function wt_avg_days_lateformula(sum_payment in number, sum_w_days_late in number) return number is
begin

declare
	wt_avg_days_late	number(20);
begin
	/*srw.reference(sum_w_days_late);*/null;

	/*srw.reference(sum_payment);*/null;


if (sum_payment <> 0 ) then
	wt_avg_days_late := sum_w_days_late / sum_payment;
end if;

	return(wt_avg_days_late);
end;
RETURN NULL; end;

function skip_inv_sumformula(invoice_amount in number, customer_id in number, currency_code in varchar2, customer_trx_id in number, terms_sequence_number in number) return number is
begin

declare

begin

/*srw.reference(currency_code);*/null;

/*srw.reference(invoice_amount);*/null;

/*srw.reference(prev_currency_code);*/null;

/*srw.reference(skip_sum);*/null;

/*srw.reference(customer_trx_id);*/null;

/*srw.reference(prev_customer_trx_id);*/null;

/*srw.reference(prev_customer_id);*/null;

/*srw.reference(prev_terms);*/null;


if (prev_customer_id is null) then
		skip_sum := invoice_amount;
else
	if (prev_customer_id <> customer_id) OR (prev_currency_code <> currency_code) then
		skip_sum := 0;
	end if;
end if;

if (prev_customer_trx_id <> customer_trx_id ) OR (prev_terms <> terms_sequence_number) then
	skip_sum := nvl(skip_sum,0) + invoice_amount;
end if;

prev_customer_id := customer_id;
prev_currency_code := currency_code;
prev_customer_trx_id := customer_trx_id;
prev_terms := terms_sequence_number;

return (skip_sum);

end;


RETURN NULL; end;

function set_addr_flagformula(address_id in number) return number is
begin

begin
/*srw.reference(address_id);*/null;

/*srw.reference(prev_addr_id);*/null;


if prev_addr_id <> address_id then
	addr_prn_flag := 'Y' ;
else
	addr_prn_flag := 'N' ;
end if;
prev_addr_id := address_id;
return(1);
end;




RETURN NULL; end;

--Functions to refer Oracle report placeholders--

 Function Skip_Sum_p return number is
	Begin
	 return Skip_Sum;
	 END;
 Function Addr_Prn_Flag_p return varchar2 is
	Begin
	 return Addr_Prn_Flag;
	 END;
 Function Prev_Addr_Id_p return number is
	Begin
	 return Prev_Addr_Id;
	 END;
 Function prev_customer_trx_id_p return varchar2 is
	Begin
	 return prev_customer_trx_id;
	 END;
 Function prev_currency_code_p return varchar2 is
	Begin
	 return prev_currency_code;
	 END;
 Function prev_customer_id_p return varchar2 is
	Begin
	 return prev_customer_id;
	 END;
 Function prev_terms_p return varchar2 is
	Begin
	 return prev_terms;
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
 Function RP_SUB_TITLE_p return varchar2 is
	Begin
	 return RP_SUB_TITLE;
	 END;
 Function RP_SORT_ORDER_p return varchar2 is
	Begin
	 return RP_SORT_ORDER;
	 END;
 Function Actual_Invoice_Sum_p return number is
	Begin
	 return Actual_Invoice_Sum;
	 END;
 function D_invoice_amountFormula(customer varchar2) return VARCHAR2 is
	begin
	RP_DATA_FOUND := customer;
	return null;
	end;
END AR_ARXCPH_XMLP_PKG ;


/
