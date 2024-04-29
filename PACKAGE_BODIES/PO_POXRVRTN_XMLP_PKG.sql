--------------------------------------------------------
--  DDL for Package Body PO_POXRVRTN_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_POXRVRTN_XMLP_PKG" AS
/* $Header: POXRVRTNB.pls 120.1 2007/12/25 12:19:35 krreddy noship $ */

USER_EXIT_FAILURE EXCEPTION;

function BeforeReport return boolean is
begin

declare
l_sort     po_lookup_codes.displayed_field%type ;
l_org_displayed    org_organization_definitions.organization_name%type ;
begin

QTY_PRECISION:=po_common_xmlp_pkg.GET_PRECISION(P_QTY_PRECISION);
LP_TRANS_DATE_FROM := to_char(P_TRANS_DATE_FROM,'DD-MON-YY') ;
LP_TRANS_DATE_TO   := to_char(P_TRANS_DATE_TO,'DD-MON-YY') ;
P_TRANS_DATE_FROM_date:= P_TRANS_DATE_FROM;
P_TRANS_DATE_TO_date:= P_TRANS_DATE_TO;

if P_sort is not null then

    select displayed_field
    into l_sort
    from po_lookup_codes
    where lookup_code = P_sort
    and lookup_type = 'SRS ORDER BY';

    P_sort_disp := l_sort ;

else

    P_sort_disp := '' ;

end if;

if P_org_id is not null then

    select organization_name
    into l_org_displayed
    from org_organization_definitions
    where organization_id = P_org_id ;

    P_org_displayed := l_org_displayed ;

else

    P_org_displayed := '' ;

end if;


end;
BEGIN
  /*SRW.USER_EXIT('FND SRWINIT');*/null;

  EXCEPTION WHEN  USER_EXIT_FAILURE /*SRW.USER_EXIT_FAILURE */THEN
            /*SRW.MESSAGE(1,'srw_init');*/null;

END;
BEGIN
  if (get_p_struct_num <> TRUE )
  then /*SRW.MESSAGE('1','P Struct Num Init failed');*/null;

  end if;                                                                    END;
BEGIN

 null;
  EXCEPTION WHEN  USER_EXIT_FAILURE /*SRW.USER_EXIT_FAILURE */THEN
            /*SRW.MESSAGE(1,'Before Cat Flex');*/null;

END;
BEGIN

 null;
  EXCEPTION WHEN  USER_EXIT_FAILURE /*SRW.USER_EXIT_FAILURE */THEN
            /*SRW.MESSAGE(1,'Before Item Flex');*/null;

END;
RETURN TRUE;  return (TRUE);
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

if P_SORT = 'VENDOR' then
   return('5,8,9');
else
   return('8,9');
end if;
RETURN NULL; end;

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

function document_numberformula(release_number in number, PO_Number in varchar2) return varchar2 is
begin

if (release_number is null ) then return PO_Number ;
else return ( PO_Number || '-' || to_char(release_number) ) ;
end if;
RETURN NULL; end;

function c_qty_net_rcvdformula(C_qty_received in varchar2, C_qty_corrected in varchar2, C_qty_rtv in varchar2, C_qty_corrected_rtv in varchar2) return number is
begin

/*srw.reference(C_qty_received) ;*/null;

/*srw.reference(C_qty_corrected) ;*/null;

/*srw.reference(C_qty_rtv) ;*/null;

/*srw.reference(C_qty_corrected_rtv) ;*/null;

return ( C_qty_received + C_qty_corrected - C_qty_rtv - C_qty_corrected_rtv ) ;
end;

function c_qty_rtv_and_correctedformula(C_qty_rtv in varchar2, C_qty_corrected_rtv in varchar2) return number is
begin

/*srw.reference(C_qty_rtv) ;*/null;

/*srw.reference(C_qty_corrected_rtv ) ;*/null;

return ( C_qty_rtv + C_qty_corrected_rtv ) ;
end;

function AfterPForm return boolean is
begin

  return (TRUE);
end;

function BeforePForm return boolean is
begin

  return (TRUE);
end;

function BetweenPage return boolean is
begin

  return (TRUE);
end;

function AfterReport return boolean is
begin


  /*SRW.USER_EXIT('FND SRWEXIT');*/null;


  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

END PO_POXRVRTN_XMLP_PKG ;


/
