--------------------------------------------------------
--  DDL for Package Body PO_POXSURUC_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_POXSURUC_XMLP_PKG" AS
/* $Header: POXSURUCB.pls 120.1 2007/12/25 12:34:17 krreddy noship $ */

function BeforeReport return boolean is
begin

declare
l_active_inactive    po_lookup_codes.displayed_field%type ;
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

end;
  return (TRUE);
end;

function AfterReport return boolean is
begin
  /*SRW.USER_EXIT('FND SRWEXIT');*/null;

  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

END PO_POXSURUC_XMLP_PKG ;


/
