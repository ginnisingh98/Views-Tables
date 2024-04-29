--------------------------------------------------------
--  DDL for Package Body PO_POXRFRAR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_POXRFRAR_XMLP_PKG" AS
/* $Header: POXRFRARB.pls 120.2 2008/01/05 17:10:06 dwkrishn noship $ */

function AfterReport return boolean is
begin

/*SRW.USER_EXIT('FND SRWEXIT');*/null;
  return (TRUE);
end;

function BeforeReport return boolean is
begin

declare
l_sort     po_lookup_codes.displayed_field%type ;
begin

if P_ORDERBY is not null then

    select displayed_field
    into l_sort
    from po_lookup_codes
    where lookup_code = P_orderby
    and lookup_type = 'SRS ORDER BY';

    P_ORDERBY_DISP := l_sort ;

else

    P_ORDERBY_DISP := '' ;

end if;

  /*SRW.USER_EXIT('FND SRWINIT');*/null;

  if (get_p_struct_num <> TRUE )
    then /*SRW.MESSAGE('1','P Struct Num Init failed');*/null;

  end if;

 null;
RETURN TRUE;
END;  return (TRUE);
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

END PO_POXRFRAR_XMLP_PKG ;


/
