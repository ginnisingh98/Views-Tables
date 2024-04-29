--------------------------------------------------------
--  DDL for Package Body PO_POXRQEXP_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_POXRQEXP_XMLP_PKG" AS
/* $Header: POXRQEXPB.pls 120.1 2008/01/06 07:11:27 dwkrishn noship $ */

USER_EXIT_FAILURE EXCEPTION;

function BeforeReport return boolean is
begin

BEGIN
  /*SRW.USER_EXIT('FND SRWINIT');*/null;

  if (get_p_struct_num <> TRUE )
    then /*SRW.MESSAGE('1','P Struct Num Init failed');*/null;

  end if;

 null;


 null;
  RETURN TRUE;
END;
  return (TRUE);
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

function AfterReport return boolean is
begin
  /*SRW.USER_EXIT('FND SRWEXIT');*/null;

  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

END PO_POXRQEXP_XMLP_PKG ;


/
