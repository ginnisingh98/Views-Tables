--------------------------------------------------------
--  DDL for Package Body PO_POXVDRVL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_POXVDRVL_XMLP_PKG" AS
/* $Header: POXVDRVLB.pls 120.1 2007/12/25 12:39:29 krreddy noship $ */

function orderby_clauseFormula return VARCHAR2 is
begin

if    upper(P_orderby) = 'VENDOR' then
      return('pov.vendor_name');
elsif upper(P_orderby) = 'VENDOR SITE' then
      return('pvs.vendor_site_code');
elsif upper(P_orderby) = 'ZIP CODE' then
      return('pvs.zip');
end if;
RETURN 'pov.vendor_name'; end;

function BeforeReport return boolean is
begin

declare
l_active_inactive    po_lookup_codes.displayed_field%type ;
l_sort     po_lookup_codes.displayed_field%type ;
l_vendor_type     po_lookup_codes.displayed_field%type ;

begin

begin

/*SRW.USER_EXIT('FND SRWINIT');*/null;


if P_active_inactive is not null then

    select displayed_field
    into l_active_inactive
    from po_lookup_codes
    where lookup_code = P_active_inactive
    and lookup_type = 'ACTIVE_INACTIVE';

    P_active_inactive_disp := l_active_inactive ;

else

    P_active_inactive_disp := '' ;

end if;

if P_vendor_type is not null then

    select displayed_field
    into l_vendor_type
    from po_lookup_codes
    where lookup_code = P_vendor_type
    and lookup_type = 'VENDOR TYPE';

    P_vendor_type_displayed := l_vendor_type ;

else

    P_vendor_type_displayed := '' ;

end if;


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

end;
  return (TRUE);
end;

function AfterReport return boolean is
begin
  /*SRW.USER_EXIT('FND SRWEXIT');*/null;

  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

END PO_POXVDRVL_XMLP_PKG ;


/
