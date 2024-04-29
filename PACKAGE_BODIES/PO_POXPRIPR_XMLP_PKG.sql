--------------------------------------------------------
--  DDL for Package Body PO_POXPRIPR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_POXPRIPR_XMLP_PKG" AS
/* $Header: POXPRIPRB.pls 120.3 2008/01/22 07:43:20 dwkrishn noship $ */
USER_EXIT_FAILURE EXCEPTION;
function BeforeReport return boolean is
begin
declare
l_sort     po_lookup_codes.displayed_field%type ;
begin
/*SRW.USER_EXIT('FND SRWINIT');*/null;
if P_orderby is not null then
    select displayed_field
    into l_sort
    from po_lookup_codes
    where lookup_code = P_orderby
    and lookup_type = 'SRS ORDER BY';
    P_orderby_displayed := l_sort ;
    if P_orderby = 'ITEM' then
       P_orderby_clause := 'MSI.SEGMENT1';
    else
       P_orderby_clause := 'MCA.SEGMENT1';
    end if;
else
    P_orderby_displayed := '' ;
    P_orderby_clause := 'MCA.SEGMENT1';
end if;
QTY_PRECISION:= po_common_xmlp_pkg.get_precision(P_qty_precision);
if P_BASE_CURRENCY is null then P_BASE_CURRENCY:='USD'; end if;
  if (get_p_struct_num <> TRUE )
    then /*SRW.MESSAGE('1','Init failed');*/null;
  end if;
LP_orderby_clause:=P_orderby_clause;
 null;
 null;
 null;
 null;
 null;
 null;
  RETURN TRUE;
END;
  return (TRUE);
end;
function AfterReport return boolean is
begin
/*srw.do_sql('alter session set sql_trace=false');*/null;
/*SRW.USER_EXIT('FND SRWEXIT');*/null;
  return (TRUE);
end;
function ipvformula(Average_Purchase in number, Average_Invoice in number) return number is
begin
/*srw.reference(Average_Invoice) ;*/null;
/*srw.reference(Average_Purchase) ;*/null;
if Average_Purchase = 0 then return 0 ;
else return (round(((Average_Invoice-Average_Purchase)/Average_Purchase)*100,8)) ;
end if;
RETURN NULL; end;
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
function orderby_clauseFormula return VARCHAR2 is
begin
if    P_orderby = 'ITEM' then
      return(P_ORDERBY_ITEM);
elsif P_orderby = 'CATEGORY' then
      return(P_ORDERBY_CAT);
end if;
RETURN NULL; end;
function get_p_struct_num return boolean is
l_p_struct_num number;
begin
        select structure_id
        into l_p_struct_num
        from mtl_default_sets_view
        where functional_area_id = 2 ;
        P_STRUCT_NUM1 := l_p_struct_num ;
        return(TRUE) ;
        RETURN NULL; exception
        when others then return(FALSE) ;
end;
function item_average_purchase_roundfor(item_average_purchase in number, c_fnd_precision in number) return number is
begin
    /*srw.reference(item_average_purchase);*/null;
    /*SRW.REFERENCE(c_fnd_precision);*/null;
    return(round(item_average_purchase, c_fnd_precision));
end;
function item_average_invoice_roundform(item_average_invoice in number, c_fnd_precision in number) return number is
begin
  /*srw.reference(item_average_invoice);*/null;
    /*SRW.REFERENCE(c_fnd_precision);*/null;
  return(round(item_average_invoice, c_fnd_precision ));
end;
function AfterPForm return boolean is
begin
/*SRW.USER_EXIT('FND SRWINIT');*/null;
if (p_period_from is NOT NULL) then
   select  start_date
   into    P_period_start_date
   from    gl_period_statuses gps,
           financials_system_parameters fps
   where   period_name = P_period_from and
   gps.set_of_books_id=fps.set_of_books_id and
   application_id=201;
end if;
if (p_period_to is NOT NULL) then
   select end_date
   into   P_period_end_date from gl_period_statuses gps,
          financials_system_parameters fps
   where  period_name = P_period_to and
   gps.set_of_books_id=fps.set_of_books_id and
   application_id=201;
end if;
if (p_period_from is NOT NULL and p_period_to is NOT NULL ) then
    period_where:=' trunc(aid.accounting_date) BETWEEN (:P_period_start_date ) AND (:P_period_end_date) ';
elsif (p_period_from is NULL and p_period_to is NOT NULL ) then
    period_where:=' trunc(aid.accounting_date) <= (:P_period_end_date) ';
elsif (p_period_from is NOT NULL and p_period_to is NULL ) then
    period_where:= ' trunc(aid.accounting_date) >= (:P_period_start_date) ';
else
    period_where:=' 1=1 ';
end if;
    return (TRUE);
end;
function average_purchase_roundformula(AVERAGE_PURCHASE in number, c_fnd_precision in number) return number is
begin
  /*SRW.REFERENCE(AVERAGE_PURCHASE);*/null;
  /*SRW.REFERENCE(c_fnd_precision);*/null;
  RETURN(round(AVERAGE_PURCHASE,c_fnd_precision));
end;
function c_amount_roundformula(C_AMOUNT in number, c_fnd_precision in number) return number is
begin
  /*SRW.REFERENCE(C_AMOUNT);*/null;
  /*SRW.REFERENCE(c_fnd_precision);*/null;
  RETURN(round(C_AMOUNT,c_fnd_precision));
end;
function average_invoice_roundformula(AVERAGE_INVOICE in number, c_fnd_precision in number) return number is
begin
  /*SRW.REFERENCE(AVERAGE_INVOICE);*/null;
  /*SRW.REFERENCE(c_fnd_precision);*/null;
  RETURN(round(AVERAGE_INVOICE,c_fnd_precision));
end;
function c_amount_tot_roundformula(C_AMOUNT_TOT in number, c_fnd_precision in number) return number is
begin
  /*SRW.REFERENCE(C_AMOUNT_TOT);*/null;
  /*SRW.REFERENCE(c_fnd_precision);*/null;
  RETURN(round(C_AMOUNT_TOT,c_fnd_precision));
end;
function rateformula(Unit_Of_measure in varchar2, Unit in varchar2, Item_id in number) return number is
begin
	  if ( Unit_Of_measure <> Unit ) then
  		return(PO_UOM_S.po_uom_convert(Unit_of_Measure, Unit, Item_id ));
	  else
	  	return (1);
	  end if;
end;
function po_primary_qtyformula(PO_Quantity in number, conv_Rate in number) return number is
begin
	  return(round((PO_Quantity * conv_Rate),P_qty_precision));
end;
function ap_primary_qtyformula(AP_Quantity in number, conv_Rate in number) return number is
begin
      return(round((AP_Quantity * conv_Rate),P_qty_precision));
end;
function average_invoiceformula(Q_Invoiced in number, Total_amount_Invoiced in number) return number is
begin
  if Q_Invoiced = 0 then
    return (0);
  else
    return (Total_amount_Invoiced/Q_Invoiced);
  end if;
end;
function average_purchaseformula(C_amount in number, Q_Purchased in number) return number is
begin
  if Q_Purchased = 0 then
     return (0);
  else
     return (C_amount/Q_Purchased);
  end if;
end;
--Functions to refer Oracle report placeholders--
END PO_POXPRIPR_XMLP_PKG ;


/
