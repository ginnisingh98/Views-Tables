--------------------------------------------------------
--  DDL for Package Body PO_POXKISUM_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_POXKISUM_XMLP_PKG" AS
/* $Header: POXKISUMB.pls 120.2 2007/12/25 11:02:02 krreddy noship $ */

USER_EXIT_FAILURE EXCEPTION;

function BeforeReport return boolean is
begin

DECLARE
   l_sort           po_lookup_codes.displayed_field%type;
   C_DATE_FORMAT varchar2(20);
BEGIN
/*SRW.USER_EXIT('FND SRWINIT');*/null;
C_DATE_FORMAT := 'DD-MON-YY';
CP_CREATION_DATE_FROM :=to_char(P_CREATION_DATE_FROM,C_DATE_FORMAT);
CP_CREATION_DATE_TO :=to_char(P_CREATION_DATE_TO,C_DATE_FORMAT);

P_ORDERBY := P_SORT ;

IF P_ORDERBY is NOT NULL THEN

   SELECT displayed_field
   INTO l_sort
   FROM po_lookup_codes
   WHERE lookup_code = P_ORDERBY
   AND lookup_type = 'SRS ORDER BY';

   P_ORDERBY_DISPLAYED := l_sort;

ELSE

   P_ORDERBY_DISPLAYED := '';

END IF;

RETURN TRUE;
END;  return (TRUE);
end;

function AfterReport return boolean is
begin

/*SRW.USER_EXIT('FND SRWEXIT');*/null;

  return (TRUE);
end;

function return_amt_saved(C_AMOUNT_LIST1 in number, C_AMOUNT_ACTUAL1 in number) return number is
begin

  /*srw.reference (C_AMOUNT_LIST1);*/null;

  /*srw.reference (C_AMOUNT_ACTUAL1);*/null;


  return C_AMOUNT_LIST1 - C_AMOUNT_ACTUAL1;

end;

function orderby_clauseFormula return VARCHAR2 is
begin

if upper(P_ORDERBY) = 'BUYER' then
   return('ppf.full_name');
elsif upper(P_ORDERBY) = 'PO TYPE' then
   return('plc.displayed_field');
elsif upper(P_ORDERBY) = 'PO NUMBER' then
   return('decode(psp1.manual_po_num_type,''NUMERIC'',
                  null,poh.segment1),
           decode(psp1.manual_po_num_type,''NUMERIC'',
                  to_number(poh.segment1),null)');
end if;
RETURN NULL; end;

function return_amt_act(C_quantity in number, Line_price in number, Rate in number) return number is
begin

/*srw.reference(C_quantity);*/null;

/*srw.reference(Line_price);*/null;

/*srw.reference(Rate);*/null;


return(nvl(C_quantity,0)
       * nvl(Line_price,0)
       * nvl(Rate,1));
end;

function return_amt_list(C_min_quote in number, Market_price in number, List in number, C_quantity in number, Rate in number) return number is
  amount number := 0;
begin
  /*srw.reference(C_quantity);*/null;

  /*srw.reference(C_min_quote);*/null;

  /*srw.reference(List);*/null;

  /*srw.reference(Market_price);*/null;

  /*srw.reference(Rate);*/null;


  if C_min_quote is not null and C_min_quote <> 0 then
    amount := C_min_quote;
  elsif Market_price is not null then
    amount := Market_price;
  elsif List is not null then
    amount := List;
  end if;

  return (amount)*nvl(C_quantity,0) * nvl(Rate,1);

end;

function return_type(C_min_quote in number, Quote_code in varchar2, Market_price in number, Market_code in varchar2, List in number, List_code in varchar2) return varchar2 is

  type_code VARCHAR2(25) := ' ';

begin

  /*srw.reference (C_min_quote);*/null;

  /*srw.reference (Market_price);*/null;

  /*srw.reference (List);*/null;


  if C_min_quote is not NULL and C_min_quote <> 0 then
     type_code := Quote_code;
  elsif Market_price is not NULL then
     type_code := Market_code;
  elsif List is not NULL then
     type_code := List_code;
  end if;

  return type_code;

end;

function return_list(C_min_quote in number, Market_price in number, List in number, Rate in number) return number is

  list_price number := 0;

begin
  /*srw.reference(Order_type);*/null;

  /*srw.reference(C_min_quote);*/null;

  /*srw.reference(Market_price);*/null;

  /*srw.reference(List);*/null;

  /*srw.reference(Rate);*/null;


  if C_min_quote is not null and C_min_quote <> 0 then
    list_price := C_min_quote;
  elsif Market_price is not null then
    list_price := Market_price;
  elsif List is not null then
    list_price := List;
  end if;

  return (list_price * nvl(Rate,1));

end;

function return_discount(C_AMOUNT_LIST1 in number, C_AMOUNT_ACTUAL1 in number) return number is
begin

  /*srw.reference (C_AMOUNT_LIST1);*/null;

  /*srw.reference (C_AMOUNT_ACTUAL1);*/null;


  if (C_AMOUNT_LIST1 - C_AMOUNT_ACTUAL1) <= 0 then
    return 0;
  else
    return ((C_AMOUNT_LIST1 - C_AMOUNT_ACTUAL1) /C_AMOUNT_LIST1) * 100;
  end if;
RETURN NULL; end;

function get_quantity(Shipment_quantity in number, Shipment_quantity_cancelled in number, Line_quantity in number) return number is

begin
  /*srw.reference (Shipment_quantity);*/null;

  /*srw.reference (Shipment_quantity_cancelled);*/null;

  /*srw.reference (Line_quantity);*/null;

  /*srw.reference (P_qty_precision);*/null;


  if (Shipment_quantity) is not null then
     return round((nvl(Shipment_quantity,0) - nvl(Shipment_quantity_cancelled,0)),P_qty_precision);
  else
     return round(nvl(Line_quantity,0),P_qty_precision);
  end if;

RETURN NULL; end;

function round_amount_actual_rep(c_amount_actual_rep in number, c_curr_precision in number) return number is
begin

  /*srw.reference(c_amount_actual_rep);*/null;

  /*srw.reference(c_curr_precision);*/null;


  return(round(c_amount_actual_rep, c_curr_precision));
end;

function round_amount_saved_rep(c_amount_saved_rep in number, c_curr_precision in number) return number is
begin

  /*srw.reference(c_amount_saved_rep);*/null;

  /*srw.reference(c_curr_precision);*/null;


  return(round(c_amount_saved_rep, c_curr_precision));
end;

function round_amount_list_rep(c_amount_list_rep in number, c_curr_precision in number) return number is
begin

  /*srw.reference(c_amount_list_rep);*/null;

  /*srw.reference(c_curr_precision);*/null;


  return(round(c_amount_list_rep, c_curr_precision));
end;

function round_amount_list_subtotal_rep(c_amount_list_subtotal in number, c_curr_precision in number) return number is
begin

  /*srw.reference(c_amount_list_subtotal);*/null;

  /*srw.reference(c_curr_precision);*/null;


  return(round(c_amount_list_subtotal, c_curr_precision));
end;

function round_amount_actual_subtotal(c_amount_actual_subtotal in number, c_curr_precision in number) return number is
begin

  /*srw.reference(c_amount_actual_subtotal);*/null;

  /*srw.reference(c_curr_precision);*/null;


  return(round(c_amount_actual_subtotal, c_curr_precision));
end;

function round_amount_saved_subtotal(c_amount_saved_subtotal in number, c_curr_precision in number) return number is
begin

  /*srw.reference(c_amount_saved_subtotal);*/null;

  /*srw.reference(c_curr_precision);*/null;


  return(round(c_amount_saved_subtotal, c_curr_precision));
end;

function round_amount_list1(c_amount_list1 in number, c_curr_precision in number) return number is
begin

  /*srw.reference(c_amount_list1);*/null;

  /*srw.reference(c_curr_precision);*/null;


  return(round(c_amount_list1, c_curr_precision));
end;

function round_amount_actual1(c_amount_actual1 in number, c_curr_precision in number) return number is
begin

  /*srw.reference(c_amount_actual1);*/null;

  /*srw.reference(c_curr_precision);*/null;


  return(round(c_amount_actual1, c_curr_precision));
end;

function round_amount_saved(c_amount_saved in number, c_curr_precision in number) return number is
begin

  /*srw.reference(c_amount_saved);*/null;

  /*srw.reference(c_curr_precision);*/null;


  return(round(c_amount_saved, c_curr_precision));
end;

--Functions to refer Oracle report placeholders--

END PO_POXKISUM_XMLP_PKG ;


/
