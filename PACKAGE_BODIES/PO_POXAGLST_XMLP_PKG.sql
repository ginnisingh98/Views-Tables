--------------------------------------------------------
--  DDL for Package Body PO_POXAGLST_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_POXAGLST_XMLP_PKG" AS
/* $Header: POXAGLSTB.pls 120.2 2008/01/05 12:52:37 dwkrishn noship $ */

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


  if (get_p_struct_num <> TRUE )
    then /*SRW.MESSAGE('1','Init failed');*/null;

  end if;
LP_ORDERBY_DISPLAYED:=P_orderby_displayed;
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

function orderby_clauseFormula return VARCHAR2 is
begin

if      P_orderby = 'BUYER' then
        return('hre.full_name');
elsif   P_orderby = 'LOCATION' then
        return('hrl.location_code');
elsif   P_orderby = 'CATEGORY' then
        return(P_ORDERBY_CAT);
end if;

--RETURN NULL; end;
RETURN('hre.full_name'); end;

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

END PO_POXAGLST_XMLP_PKG ;


/
