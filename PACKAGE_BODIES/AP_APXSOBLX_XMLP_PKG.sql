--------------------------------------------------------
--  DDL for Package Body AP_APXSOBLX_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_APXSOBLX_XMLP_PKG" AS
/* $Header: APXSOBLXB.pls 120.0 2007/12/27 08:30:19 vjaganat noship $ */
function cf_cur_totalformula(c_inv_total in number, c_prepay_total in number) return number is
begin
  /*srw.reference(c_inv_total);*/null;
  /*srw.reference(c_prepay_total);*/null;
return(c_inv_total-nvl(c_prepay_total,0));
end;
function CF_as_of_date_displayFormula return char is
day varchar2(2);
month varchar2(30);
year varchar2(4);
begin
month:=rtrim(to_char(p_as_of_date,'Month'),' ');
day:=to_char(p_as_of_date,'DD');
year:=to_char(p_as_of_DATE,'YYYY');
return(month||' '||day||','||year);
end;
function BeforeReport return boolean is
l_date date;
begin
  begin
/*srw.user_exit('FND SRWINIT');*/null;
P_CONC_REQUEST_ID:=FND_GLOBAL.conc_request_id;
l_date:=fnd_date.chardate_to_date(p_as_of_date);
p_as_of_date_1 := to_char(p_as_of_date,'DD-MON-YY');
AP_GET_SUPPLIER_BALANCE_PKG.ap_get_supplier_balance(
                                p_conc_request_id
                               ,p_set_of_books_id
                               ,l_date
                               ,p_supplier_name_from
                               ,p_supplier_name_to
                               ,p_currency
                               ,p_min_invoice_balance
                               ,p_min_open_balance
                               ,p_include_prepayments
                               ,p_reference_number
                               ,p_debug_flag
                               ,p_trace_flag
                                      );
   end;
  return (TRUE);
end;
function AfterReport return boolean is
begin
  /*srw.user_exit('FND SRWEXIT');*/null;
  return (TRUE);
end;
function cf_displayformula(CF_cur_total in number) return number is
begin
        IF CF_cur_total >= p_min_open_balance THEN
  	return (1);
  ELSE
	return(0);
  END IF;
end;
--Functions to refer Oracle report placeholders--
END AP_APXSOBLX_XMLP_PKG ;


/
