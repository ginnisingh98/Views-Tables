--------------------------------------------------------
--  DDL for Package Body PO_POXPOSMH_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_POXPOSMH_XMLP_PKG" AS
/* $Header: POXPOSMHB.pls 120.1 2007/12/25 11:19:49 krreddy noship $ */

function BeforeReport return boolean is
begin

BEGIN
  /*SRW.USER_EXIT('FND SRWINIT');*/null;

  if (get_p_struct_num <> TRUE )
    then /*SRW.MESSAGE('1','Init failed');*/null;

  end if;
  FORMAT_MASK := PO_COMMON_XMLP_PKG.GET_PRECISION(P_QTY_PRECISION);
 null;


 null;


 null;


 null;

RETURN TRUE;
END;  return (TRUE);
end;

function AfterReport return boolean is
begin

/*SRW.USER_EXIT('FND SRWEXIT');*/null;
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

        P_STRUCT_NUM := l_p_struct_num ;

        return(TRUE) ;

        RETURN NULL; exception
        when others then return(FALSE) ;
end;

function c_report_avg_no_of_daysformula(C_report_tot_days_hold in number, C_report_number_total in number) return number is
begin
if(C_report_number_total=0) then
 return(0);
 else
 return (C_report_tot_days_hold / C_report_number_total);
 end if;
end;

function c_total_days_holdingformula(average in number, number_amount_tot in number) return number is
begin
  return(average * number_amount_tot);
end;

function c_unit_price_round(unit_price in varchar2, parent_currency_precision in number) return number is

begin

  /*srw.reference(unit_price);*/null;

  /*srw.reference(parent_currency_precision);*/null;


  return(round(unit_price,parent_currency_precision));
end;

function c_invoice_price_round(invoice_price in number, parent_currency_precision in number) return number is

begin

  /*srw.reference(invoice_price);*/null;

  /*srw.reference(Parent_currency_precision);*/null;

  return(round(invoice_price,parent_currency_precision));

end;

--Functions to refer Oracle report placeholders--

END PO_POXPOSMH_XMLP_PKG ;


/
