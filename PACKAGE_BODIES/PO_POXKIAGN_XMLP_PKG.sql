--------------------------------------------------------
--  DDL for Package Body PO_POXKIAGN_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_POXKIAGN_XMLP_PKG" AS
/* $Header: POXKIAGNB.pls 120.1 2007/12/25 10:59:35 krreddy noship $ */

USER_EXIT_FAILURE EXCEPTION;

function BeforeReport return boolean is
begin

DECLARE
   l_sort       po_lookup_codes.displayed_field%type;
BEGIN
  /*SRW.USER_EXIT('FND SRWINIT');*/null;


  LP_STRUCT_NUM := P_STRUCT_NUM ;


  if (get_p_struct_num <> TRUE )
    then /*SRW.MESSAGE('1','P Struct Num Init failed');*/null;

  end if;

  IF P_ORDERBY IS NOT NULL THEN

    SELECT displayed_field
    INTO l_sort
    FROM po_lookup_codes
    WHERE lookup_code = P_ORDERBY
    AND lookup_type = 'SRS ORDER BY';

    P_ORDERBY_DISP := l_sort;

  ELSE

    P_ORDERBY_DISP := '';

  END IF;


 null;


 null;


 null;
  RETURN TRUE;
END;
  return (TRUE);
end;

procedure get_precision is
begin
/*srw.attr.mask        :=  SRW.FORMATMASK_ATTR;*/null;

if P_qty_precision = 0 then /*srw.attr.formatmask  := '-NNN,NNN,NNN,NN0';*/null;

else
if P_qty_precision = 1 then /*srw.attr.formatmask  := '-NNN,NNN,NNN,NN0.0';*/null;

else
if P_qty_precision = 3 then /*srw.attr.formatmask  :=  '-NN,NNN,NNN,NN0.000';*/null;

else
if P_qty_precision = 4 then /*srw.attr.formatmask  :=   '-N,NNN,NNN,NN0.0000';*/null;

else
if P_qty_precision = 5 then /*srw.attr.formatmask  :=     '-NNN,NNN,NN0.00000';*/null;

else
if P_qty_precision = 6 then /*srw.attr.formatmask  :=      '-NN,NNN,NN0.000000';*/null;

else /*srw.attr.formatmask  :=  '-NNN,NNN,NNN,NN0.00';*/null;

end if; end if; end if; end if; end if; end if;
/*srw.set_attr(0,srw.attr);*/null;

end;

function get_p_struct_num return boolean is

l_p_struct_num number;

begin
        select structure_id
        into l_p_struct_num
        from mtl_default_sets_view
        where functional_area_id = 2 ;

        LP_STRUCT_NUM := l_p_struct_num ;

        return(TRUE) ;

        RETURN NULL; exception
        when others then return(FALSE) ;
end;

function orderby_clauseFormula return VARCHAR2 is
begin

BEGIN
  IF P_ORDERBY = 'CATEGORY' THEN
     RETURN(P_ORDERBY_CAT);
  ELSIF P_ORDERBY = 'PO NUMBER' THEN
     RETURN('decode(psp1.manual_po_num_type, ''NUMERIC'',
               null, poh.segment1),
             decode(psp1.manual_po_num_type, ''NUMERIC'',
               to_number(poh.segment1), null)');
  END IF;
END;
RETURN NULL; end;

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

return (amount)*nvl(C_quantity,0)* nvl(Rate,1);

end;

function return_amt_saved(C_AMOUNT_LIST in number, C_AMOUNT_ACTUAL in number) return number is
begin
  /*srw.reference (C_AMOUNT_LIST);*/null;

  /*srw.reference (C_AMOUNT_ACTUAL);*/null;


  return C_AMOUNT_LIST - C_AMOUNT_ACTUAL;

end;

function return_discount(C_AMOUNT_LIST in number, C_AMOUNT_ACTUAL in number) return number is
begin
  /*srw.reference (C_AMOUNT_LIST);*/null;

  /*srw.reference (C_AMOUNT_ACTUAL);*/null;


  if (C_AMOUNT_LIST - C_AMOUNT_ACTUAL) <= 0 then
    return 0;
  else
    return ((C_AMOUNT_LIST - C_AMOUNT_ACTUAL) /C_AMOUNT_LIST) * 100;
  end if;

RETURN NULL; end;

function return_list(Order_type in varchar2, C_min_quote in number, Market_price in number, List in number, Rate in number) return number is

  list_price number := 0;

begin
  /*srw.reference(Order_type);*/null;

  /*srw.reference(C_min_quote);*/null;

  /*srw.reference(Market_price);*/null;

  /*srw.reference(List);*/null;

  /*srw.reference(Rate);*/null;


  if Order_type = 'AMOUNT' then
    return 0;
  elsif C_min_quote is not null and C_min_quote <> 0 then
    list_price := C_min_quote;
  elsif Market_price is not null then
    list_price := Market_price;
  elsif List is not null then
    list_price := List;
  end if;

  return (list_price * nvl(Rate,1));

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

function return_amt_act(C_quantity in number, Line_price in number, Rate in number) return number is
begin

/*srw.reference(C_quantity);*/null;

/*srw.reference(Line_price);*/null;

/*srw.reference(Rate);*/null;


return(nvl(C_quantity,0)
       * nvl(Line_price,0)
       * nvl(Rate,1));
end;

function get_quantity(Shipment_quantity in number, Line_quantity in number) return number is

begin
  /*srw.reference (Shipment_quantity);*/null;

  /*srw.reference (Line_quantity);*/null;

  /*srw.reference (P_qty_precision);*/null;


  if (Shipment_quantity) is not null then
     return round(Shipment_quantity,P_qty_precision);
  else
     return round(nvl(Line_quantity,0),P_qty_precision);
  end if;

RETURN NULL; end;

function AfterReport return boolean is
begin
  /*SRW.USER_EXIT('FND SRWEXIT');*/null;

  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

END PO_POXKIAGN_XMLP_PKG ;


/
