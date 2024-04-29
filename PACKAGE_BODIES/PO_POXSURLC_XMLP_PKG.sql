--------------------------------------------------------
--  DDL for Package Body PO_POXSURLC_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_POXSURLC_XMLP_PKG" AS
/* $Header: POXSURLCB.pls 120.1 2007/12/25 12:30:13 krreddy noship $ */
function orderby_clauseFormula return VARCHAR2 is
begin
if    P_SORT = 'COUNTRY' then
       return('country');
elsif P_SORT = 'STATE' then
       return('province');
elsif P_SORT = 'LOCATION' then
       return('location_code');
end if;
RETURN 'location_code'; end;
function BeforeReport return boolean is
begin
declare
l_active_inactive    po_lookup_codes.displayed_field%type ;
l_sort     po_lookup_codes.displayed_field%type ;
l_site     po_lookup_codes.displayed_field%type ;
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
if P_site is not null then
    select displayed_field
    into l_site
    from po_lookup_codes
    where lookup_code = P_site
    and lookup_type = 'SITE_TYPE';
    P_site_disp := l_site ;
else
    P_site_disp := '' ;
end if;
end;
  return (TRUE);
end;
function AfterReport return boolean is
begin
  /*SRW.USER_EXIT('FND SRWEXIT');*/null;
  return (TRUE);
end;
--Functions to refer Oracle report placeholders--
END PO_POXSURLC_XMLP_PKG ;


/
