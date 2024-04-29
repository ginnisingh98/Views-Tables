--------------------------------------------------------
--  DDL for Package Body PO_POXRQCRQ_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_POXRQCRQ_XMLP_PKG" AS
/* $Header: POXRQCRQB.pls 120.1 2007/12/25 11:46:37 krreddy noship $ */

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

  /*SRW.USER_EXIT('FND SRWINIT');*/null;


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

function orderby_clauseFormula return VARCHAR2 is
begin

if upper(P_ORDERBY) = 'PREPARER' then
   return('papf.full_name');
elsif upper(P_ORDERBY) = 'REQ NUMBER' then
   return('decode(psp1.manual_req_num_type,''NUMERIC'',
            null,prh.segment1)
          ,decode(psp1.manual_req_num_type,''NUMERIC'',
            to_number(prh.segment1),null)');
end if;
--RETURN NULL; end;
RETURN('papf.full_name'); end;

--Functions to refer Oracle report placeholders--

END PO_POXRQCRQ_XMLP_PKG ;


/
