--------------------------------------------------------
--  DDL for Package Body PO_POXPOPAA_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_POXPOPAA_XMLP_PKG" AS
/* $Header: POXPOPAAB.pls 120.1 2007/12/25 11:16:51 krreddy noship $ */

function BeforeReport return boolean is
begin

BEGIN
  /*SRW.USER_EXIT('FND SRWINIT');*/null;

QTY_PRECISION:=po_common_XMLP_PKG.GET_PRECISION(P_QTY_PRECISION);
  if (get_p_struct_num <> TRUE )
    then /*SRW.MESSAGE('1','P Struct Num Init failed');*/null;

  end if;

 null;


 null;
END;  return (TRUE);
end;

function AfterReport return boolean is
begin

/*SRW.USER_EXIT('FND SRWEXIT');*/null;
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

function cf_buyer_formulaformula(buyer in varchar2) return char is
begin
  cp_buyer:=buyer;
  return null;
end;

function CF_BUYERFormula return Char is
buyer varchar(240):=null;
begin

  if p_buyer is not null then
  buyer:=cp_buyer;
  else
  buyer:=null;
  end if;

 return buyer;

end;

function CP_BUYERFormula return Char is
begin
  null;end;

--Functions to refer Oracle report placeholders--

 Function CP_BUYER_p return varchar2 is
	Begin
	 return CP_BUYER;
	 END;
END PO_POXPOPAA_XMLP_PKG ;


/
