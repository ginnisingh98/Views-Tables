--------------------------------------------------------
--  DDL for Package Body PO_POXQTQAR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_POXQTQAR_XMLP_PKG" AS
/* $Header: POXQTQARB.pls 120.1 2007/12/25 11:34:31 krreddy noship $ */

USER_EXIT_FAILURE EXCEPTION;

function AfterReport return boolean is
begin

/*SRW.USER_EXIT('FND SRWEXIT');*/null;
  return (TRUE);
end;

function BeforeReport return boolean is
begin

BEGIN
  /*SRW.USER_EXIT('FND SRWINIT');*/null;

  if (get_p_struct_num <> TRUE )
    then /*SRW.MESSAGE('1','P Struct Num Init failed');*/null;

  end if;
  FORMAT_MASK := PO_common_xmlp_pkg.GET_PRECISION(P_QTY_PRECISION);
 null;


 null;


 null;
 EXCEPTION WHEN  USER_EXIT_FAILURE /*SRW.USER_EXIT_FAILURE */THEN
            /*SRW.MESSAGE(1,'Before Category Where');*/null;

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

--Functions to refer Oracle report placeholders--

END PO_POXQTQAR_XMLP_PKG ;


/
