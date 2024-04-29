--------------------------------------------------------
--  DDL for Package Body PO_POXVDVOH_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_POXVDVOH_XMLP_PKG" AS
/* $Header: POXVDVOHB.pls 120.1 2007/12/25 12:41:39 krreddy noship $ */

function BeforeReport return boolean is
begin

declare
l_sort     po_lookup_codes.displayed_field%type ;
begin

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

RETURN TRUE;

end;  return (TRUE);
end;

function orderby_clauseFormula return VARCHAR2 is
begin

if    P_orderby = 'VENDOR' then
      return('pov.vendor_name');
elsif P_orderby = 'PO NUMBER' then
      return('decode(psp1.manual_po_num_type, ''NUMERIC'', null, poh.segment1)
,        decode(psp1.manual_po_num_type,''NUMERIC'',decode(rtrim(poh.segment1,''0123456789''),null,to_number(poh.segment1),-1),
                     null)');
end if;
RETURN NULL; end;

function AfterReport return boolean is
begin
  /*SRW.USER_EXIT('FND SRWEXIT');*/null;

  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

END PO_POXVDVOH_XMLP_PKG ;


/
