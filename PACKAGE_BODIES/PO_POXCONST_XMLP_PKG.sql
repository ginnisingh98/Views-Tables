--------------------------------------------------------
--  DDL for Package Body PO_POXCONST_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_POXCONST_XMLP_PKG" AS
/* $Header: POXCONSTB.pls 120.1 2007/12/25 10:49:19 krreddy noship $ */

USER_EXIT_FAILURE EXCEPTION;

function BeforeReport return boolean is
begin

declare
l_sort     po_lookup_codes.displayed_field%type ;
begin

QTY_PRECISION:=PO_common_xmlp_pkg.GET_PRECISION(P_QTY_PRECISION);
if P_orderby is not null then

    select displayed_field
    into l_sort
    from po_lookup_codes
    where lookup_code = P_orderby
    and lookup_type = 'SRS ORDER BY';

    P_orderby_displayed := l_sort ;

else

    P_orderby_displayed := '' ;

end if;


end;
BEGIN
  /*SRW.USER_EXIT('FND SRWINIT');*/null;

  EXCEPTION WHEN  USER_EXIT_FAILURE /*SRW.USER_EXIT_FAILURE */THEN
            /*SRW.MESSAGE(1, 'srw_init');*/null;

END;
BEGIN
  if (get_p_struct_num <> TRUE )
  then /*SRW.MESSAGE('1','Init failed');*/null;

  end if;
END;
BEGIN

 null;
  EXCEPTION WHEN  USER_EXIT_FAILURE /*SRW.USER_EXIT_FAILURE */THEN
            /*SRW.MESSAGE(1, 'Before Item Flex');*/null;

END;
BEGIN

 null;
  EXCEPTION WHEN  USER_EXIT_FAILURE /*SRW.USER_EXIT_FAILURE */THEN
            /*SRW.MESSAGE(1, 'Before Cat Flex');*/null;

END;
BEGIN

 null;
  EXCEPTION WHEN  USER_EXIT_FAILURE /*SRW.USER_EXIT_FAILURE */THEN
            /*SRW.MESSAGE(1, 'Before Item Orderby');*/null;

END;
BEGIN

 null;
  EXCEPTION WHEN  USER_EXIT_FAILURE /*SRW.USER_EXIT_FAILURE */THEN
            /*SRW.MESSAGE(1, 'Before Cat Orderby');*/null;

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

function orderby_clauseFormula return VARCHAR2 is
begin

if P_ORDERBY = 'PO Number' then
     return ('21, 22');
elsif P_ORDERBY = 'ITEM' then
     return(P_ORDERBY_ITEM) ;
elsif P_ORDERBY = 'CATEGORY' then
     return (P_ORDERBY_CAT) ;
end if;
--RETURN NULL; end;
return ('21, 22');  end;

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

function c_sum_contract_round(C_SUM_CONTRACT in number, C_PRECISION in number) return number is
BEGIN

	/*SRW.REFERENCE(C_SUM_CONTRACT);*/null;

	/*SRW.REFERENCE(C_PRECISION);*/null;

	RETURN(ROUND(C_SUM_CONTRACT, C_PRECISION));

END;

function c_amount_round(C_AMOUNT in number, C_PRECISION in number) return number is
BEGIN

	/*SRW.REFERENCE(C_AMOUNT);*/null;

	/*SRW.REFERENCE(C_PRECISION);*/null;

	RETURN(ROUND(C_AMOUNT, C_PRECISION));

END;

function c_total_po_amount_round(C_TOTAL_PO_AMOUNT in number, C_PRECISION in number) return number is
BEGIN

	/*SRW.REFERENCE(C_TOTAL_PO_AMOUNT);*/null;

	/*SRW.REFERENCE(C_PRECISION);*/null;

	RETURN(ROUND(C_TOTAL_PO_AMOUNT, C_PRECISION));

END;

function c_amount_1_round(c_amount_1 in number, c_precision in number) return number is
begin

	/*srw.reference(c_amount_1);*/null;

	/*srw.reference(c_precision);*/null;

	return(round(c_amount_1, c_precision));

end;

function c_unit_price_roundformula(UNIT_PRICE in varchar2, C_EXTENDED_PRECISION in number) return number is
begin
    /*SRW.REFERENCE(UNIT_PRICE);*/null;

  /*SRW.REFERENCE(C_EXTENDED_PRECISION);*/null;

  RETURN(ROUND(UNIT_PRICE,C_EXTENDED_PRECISION));
end;

--Functions to refer Oracle report placeholders--

END PO_POXCONST_XMLP_PKG ;


/
