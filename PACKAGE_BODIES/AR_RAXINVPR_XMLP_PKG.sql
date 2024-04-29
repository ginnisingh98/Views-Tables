--------------------------------------------------------
--  DDL for Package Body AR_RAXINVPR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_RAXINVPR_XMLP_PKG" AS
/* $Header: RAXINVPRB.pls 120.0 2007/12/27 14:27:03 abraghun noship $ */

function AfterPForm return boolean is
begin

declare msg AR_LOOKUPS.MEANING%TYPE;
        out1 varchar2(4096);
        out2 varchar2(4096);
        trn  ar_system_parameters.tax_registration_number%TYPE;

BEGIN

out1 := 'X';
end;
  return (TRUE);
end;

function BeforeReport return boolean is
begin

declare where1 varchar2(8096);
        where2 varchar2(8096);
        table1 varchar2(8096);
        table2 varchar2(8096);
	--print_option	VARCHAR2(80);
	print_option_t	VARCHAR2(80);
	--type_id		VARCHAR2(50);
	type_id_t		VARCHAR2(50);
	--customer_id	VARCHAR2(50);
	customer_id_t	VARCHAR2(50);
	--batch_id	VARCHAR2(50);
	batch_id_t	VARCHAR2(50);
	--open_invoices	VARCHAR2(80);
	open_invoices_t	VARCHAR2(80);
	--invoice_dates	VARCHAR2(50);
	invoice_dates_t	VARCHAR2(50);
	--invoice_numbers	VARCHAR2(50);
	invoice_numbers_t	VARCHAR2(50);
	company_name	VARCHAR2(50);
	--functional_currency VARCHAR2(15);
	functional_currency_t VARCHAR2(15);
    	l_report_name  VARCHAR2(240);

BEGIN

BEGIN
   /*SRW.USER_EXIT('FND SRWINIT');*/null;

end;

BEGIN

if (p_choice = 'BATCH' and p_batch_id is null)
then
   arp_standard.fnd_message('740');
   /*srw.message('100', arp_standard.fnd_message(arp_standard.md_msg_text +         arp_standard.md_msg_number));*/null;

   raise_application_error(-20101,null);/*srw.program_abort;*/null;

end if;



arp_trx_select_control.build_where_clause(
 p_choice, p_open_invoice, p_cust_trx_type_id,
 p_cust_trx_class,
 p_installment_number, p_dates_low, p_dates_high,
 p_customer_id, p_customer_class_code, p_trx_number_low,
 p_trx_number_high, p_batch_id, p_customer_trx_id,
 p_adj_number_low, p_adj_number_high,
 p_adj_dates_low, p_adj_dates_high,
 where1, where2, table1, table2 );

p_where1 := where1;
p_where2 := where2;
p_table1 := table1;
p_table2 := table2;

exception
when others
then
   if sqlcode = -20000
   then
   begin
      /*srw.message( '100', arp_standard.fnd_message(arp_standard.md_msg_text + arp_standard.md_msg_number) );*/null;

      raise_application_error(-20101,null);/*srw.program_abort;*/null;

   end;
   else
   begin
      /*srw.message( '100', 'Oracle Error in call to ' ||
                          'Before Report Trigger' ||
                           to_char(sqlcode, '999999' ) );*/null;

      raise_application_error(-20101,null);/*srw.program_abort;*/null;

   end;
   end if;
end;

begin



select  option_lu.meaning
--into    print_option
into    print_option_t
from    ar_lookups              option_lu
where   option_lu.lookup_type(+) = 'INVOICE_PRINTING'
and     option_lu.lookup_code(+) = upper(p_choice);

--print_option := print_option;
print_option := print_option_t;



if p_customer_trx_id is not null then
	select  name
	--into    type_id
	into    type_id_t
	from    ra_cust_trx_types
	where   cust_trx_type_id = p_customer_trx_id;
--type_id := type_id;
type_id := type_id_t;
end if;



if p_customer_id is not null then
	select  substrb(party.party_name,1,50)
	--into    customer_id
	into    customer_id_t
	from    hz_cust_accounts           cust,
		hz_parties		party
	where   cust.cust_account_id  = p_customer_id
          and   cust.party_id = party.party_id;

--customer_id := customer_id;
customer_id := customer_id_t;

end if;



if p_batch_id is not null then
	select  bat.name
	--into    batch_id
	into    batch_id_t
	from    ra_batches              bat
	where   bat.batch_id = p_batch_id;

--batch_id := batch_id;
batch_id := batch_id_t;
end if;


if p_open_invoice is not null then
	select  open_lu.meaning
	--into    open_invoices
	into    open_invoices_t
	from    ar_lookups              open_lu
	where   open_lu.lookup_type = 'YES/NO'
	and     open_lu.lookup_code = p_open_invoice;
--open_invoices := open_invoices;
open_invoices := open_invoices_t;
end if;

if p_dates_low is not null or p_dates_high is not null then
	invoice_dates := nvl(to_char(p_dates_low,'DD-MON-YYYY'),'     ') || ' to ' || nvl(to_char(p_dates_high,'DD-MON-YYYY'),'     ');
end if;

if p_trx_number_low is not null or p_trx_number_high is not null then
	invoice_numbers := nvl(p_trx_number_low,'     ') || ' to ' || nvl(p_trx_number_high,'     ');
end if;

exception
when others then
	begin
      	/*srw.message( '100', 'Oracle Error in call to ' ||
                          'Before Report Trigger' ||
                           to_char(sqlcode, '999999' ) );*/null;

      	raise_application_error(-20101,null);/*srw.program_abort;*/null;

   	end;

end;

begin
        SELECT sob.name   Company_Name,
               sob.currency_code Functional_Currency
	--INTO   company_name, functional_currency
	INTO   company_name, functional_currency_t
	FROM    gl_sets_of_books sob, ar_system_parameters ar
	WHERE   sob.set_of_books_id  = ar.set_of_books_id;

	RP_COMPANY_NAME := company_name;
	--Functional_Currency := functional_currency;
	Functional_Currency := functional_currency_t;

    SELECT cp.user_concurrent_program_name
    INTO   l_report_name
    FROM   FND_CONCURRENT_PROGRAMS_VL cp,
           FND_CONCURRENT_REQUESTS cr
    WHERE  cr.request_id = P_CONC_REQUEST_ID
    AND    cp.application_id = cr.program_application_id
    AND    cp.concurrent_program_id = cr.concurrent_program_id;

    RP_Report_Name := l_report_name;

EXCEPTION
    WHEN NO_DATA_FOUND
    THEN RP_REPORT_NAME := 'Invoice Print Preview Report';
END;
end;  return (TRUE);
end;

function AfterReport return boolean is
begin

/*srw.user_exit( 'FND SRWEXIT' );*/null;

  return (TRUE);
end;

function installment_last_print_datefor(sequence_num in number, last_printed_sequence_num in number, printing_pending in varchar2, last_print_date in date) return date is
begin

if (nvl(sequence_num, 1) > nvl(last_printed_sequence_num, 0))
then installment_printing_pending := printing_pending;
     return('');
else installment_printing_pending := '';
     return(last_print_date);
end if;

RETURN NULL; end;

--Functions to refer Oracle report placeholders--

 Function INSTALLMENT_PRINTING_PENDING_p return varchar2 is
	Begin
	 return INSTALLMENT_PRINTING_PENDING;
	 END;
 Function RP_DATA_FOUND_p return varchar2 is
	Begin
	 return RP_DATA_FOUND;
	 END;
 Function RP_COMPANY_NAME_p return varchar2 is
	Begin
	 return RP_COMPANY_NAME;
	 END;
 Function RP_REPORT_NAME_p return varchar2 is
	Begin
	 return RP_REPORT_NAME;
	 END;
 Function Print_option_p return varchar2 is
	Begin
	 return Print_option;
	 END;
 Function Type_id_p return varchar2 is
	Begin
	 return Type_id;
	 END;
 Function Customer_id_p return varchar2 is
	Begin
	 return Customer_id;
	 END;
 Function Batch_id_p return varchar2 is
	Begin
	 return Batch_id;
	 END;
 Function Open_Invoices_p return varchar2 is
	Begin
	 return Open_Invoices;
	 END;
 Function Invoice_Dates_p return varchar2 is
	Begin
	 return Invoice_Dates;
	 END;
 Function Invoice_Numbers_p return varchar2 is
	Begin
	 return Invoice_Numbers;
	 END;
 Function Functional_Currency_p return varchar2 is
	Begin
	 return Functional_Currency;
	 END;
/*added as  a fix*/
function D_AmountFormula return VARCHAR2 is
begin

--srw.reference(:Amount);
--srw.reference(:Functional_Currency);
RP_DATA_FOUND := '12345';
/*srw.user_exit('FND FORMAT_CURRENCY
		CODE=":Functional_Currency"
		DISPLAY_WIDTH="17"
		AMOUNT=":Amount"
		DISPLAY=":D_Amount"
 		MINIMUM_PRECISION=":P_MIN_PRECISION"');
	RETURN(:D_Amount);
*/
RETURN NULL;
end;

/*fix ends*/
END AR_RAXINVPR_XMLP_PKG ;



/
