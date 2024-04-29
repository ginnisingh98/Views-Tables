--------------------------------------------------------
--  DDL for Package Body PO_POXSUMIT_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_POXSUMIT_XMLP_PKG" AS
/* $Header: POXSUMITB.pls 120.1 2007/12/25 12:28:38 krreddy noship $ */

USER_EXIT_FAILURE EXCEPTION;

function BeforeReport return boolean is
begin

declare
l_active_inactive    po_lookup_codes.displayed_field%type ;
l_sort     po_lookup_codes.displayed_field%type ;
begin

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

    P_sort_displayed := l_sort ;

else

    P_sort_displayed := '' ;

end if;


end;

BEGIN
  /*SRW.USER_EXIT('FND SRWINIT');*/null;

  EXCEPTION WHEN  USER_EXIT_FAILURE /*SRW.USER_EXIT_FAILURE */THEN
            /*SRW.MESSAGE(1,'srw_init');*/null;

END;
BEGIN
  if (get_p_struct_num <> TRUE )
    then /*SRW.MESSAGE('1','Init failed');*/null;

  end if;
END;
BEGIN

 null;
  EXCEPTION WHEN  USER_EXIT_FAILURE /*SRW.USER_EXIT_FAILURE */THEN
            /*SRW.MESSAGE(1,'Before Item Flex');*/null;

END;
BEGIN

 null;
  EXCEPTION WHEN  USER_EXIT_FAILURE /*SRW.USER_EXIT_FAILURE */THEN
            /*SRW.MESSAGE(1,'Before Acc Flex');*/null;

END;
BEGIN

 null;
  EXCEPTION WHEN  USER_EXIT_FAILURE /*SRW.USER_EXIT_FAILURE */THEN
            /*SRW.MESSAGE(1,'Before Cat Flex');*/null;

END;
BEGIN

 null;
  EXCEPTION WHEN  USER_EXIT_FAILURE /*SRW.USER_EXIT_FAILURE */THEN
            /*SRW.MESSAGE(1,'Before Item Orderby');*/null;

END;
BEGIN

 null;
  EXCEPTION WHEN  USER_EXIT_FAILURE /*SRW.USER_EXIT_FAILURE */THEN
            /*SRW.MESSAGE(1,'Before Categroy Orderby');*/null;

END;
RETURN TRUE;  return (TRUE);
end;

function AfterReport return boolean is
begin
/*SRW.USER_EXIT('FND SRWEXIT');*/null;

RETURN TRUE;  return (TRUE);
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

--Functions to refer Oracle report placeholders--

END PO_POXSUMIT_XMLP_PKG ;


/
