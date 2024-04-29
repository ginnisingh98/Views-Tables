--------------------------------------------------------
--  DDL for Package Body AR_ARXCOBLX_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_ARXCOBLX_XMLP_PKG" AS
/* $Header: ARXCOBLXB.pls 120.0 2007/12/27 13:41:45 abraghun noship $ */

function cf_totalformula(c_inv_open_balance in number, cf_credits_and_receipts in number) return number is
begin
/*srw.reference(cf_credits_and_receipts);*/null;

  return(c_inv_open_balance+(cf_credits_and_receipts));
end;

function cf_credits_and_receiptsformula(c_unapplied_receipts in number, c_on_account_receipts in number, c_on_account_credits in number) return number is
begin
    return((c_unapplied_receipts+c_on_account_receipts)+c_on_account_credits);
end;

function BeforeReport return boolean is
l_date date;
begin
 	P_CONC_REQUEST_ID:=FND_GLOBAL.conc_request_id;
  begin
/*srw.user_exit('FND SRWINIT');*/null;




l_date:=fnd_date.chardate_to_date(p_as_of_date);


select set_of_books_id into p_set_of_books_id
from ar_system_parameters;


AR_GET_CUSTOMER_BALANCE_PKG.ar_get_customer_balance(
                                p_conc_request_id
                               ,p_set_of_books_id
                               ,l_date
                               ,p_customer_name_from
                               ,p_customer_name_to
                               ,p_customer_number_low
                               ,p_customer_number_high
                               ,p_currency
                               ,p_min_invoice_balance
                               ,p_min_customer_balance
                               ,p_include_on_account_credits
                               ,p_include_on_account_receipts
                               ,p_include_unapplied_receipts
                               ,p_include_uncleared_receipts
                               ,p_reference_number
                               ,p_debug_flag
                               ,p_trace_flag
                                      );
 end;
  return (TRUE);
end;

function C_as_of_date_displayFormula return char is
day   varchar2(2);
month varchar2(50);
year  varchar2(4);
begin


  month := substrb(rtrim(to_char(p_as_of_date,'Month'),' '),1,50);
  day   := to_char(p_as_of_date,'DD');
  year  := to_char(p_as_of_DATE,'YYYY');

  return(day||' '||month||' '||year);
end;

function AfterReport return boolean is
begin
  /*srw.user_exit('FND SRWEXIT');*/null;

  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

END AR_ARXCOBLX_XMLP_PKG ;


/
