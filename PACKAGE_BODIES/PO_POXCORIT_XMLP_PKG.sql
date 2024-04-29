--------------------------------------------------------
--  DDL for Package Body PO_POXCORIT_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_POXCORIT_XMLP_PKG" AS
/* $Header: POXCORITB.pls 120.1 2007/12/25 10:51:36 krreddy noship $ */

USER_EXIT_FAILURE EXCEPTION;

function BeforeReport return boolean is
begin
declare
  l_org_displayed  org_organization_definitions.organization_name%type ;
begin
  if P_org_id is not null then
    select organization_name
    into l_org_displayed
    from org_organization_definitions
    where organization_id = P_org_id ;

    p_organization_name:=l_org_displayed;
 else
  P_organization_name := '' ;
  end if;

  if p_country_of_origin_code IS NOT NULL then
    p_query_where_country_code := ' poll.country_of_origin_code = '|| '''' || P_COUNTRY_OF_ORIGIN_CODE || '''';
  end if;
  if P_QUERY_WHERE_COUNTRY_CODE is null then P_QUERY_WHERE_COUNTRY_CODE:= '1=1'; end if;
end;
BEGIN
  /*SRW.USER_EXIT('FND SRWINIT');*/null;

  EXCEPTION WHEN  USER_EXIT_FAILURE /*SRW.USER_EXIT_FAILURE */THEN
            /*SRW.MESSAGE(1,'srw_init');*/null;

END;
  if (get_p_struct_num <> TRUE )
    then /*SRW.MESSAGE('1','P Struct Num Init failed');*/null;

  end if;


 null;


 null;


 null;


 null;
  return (TRUE);
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

        P_CAT_STRUCT_NUM := l_p_struct_num ;

        return(TRUE) ;

        RETURN NULL; exception
        when others then return(FALSE) ;
end;

function f_get_vendor_item_number (p_org_id number
             , p_vendor_id number
             , p_vendor_site_id number
             , p_item_id number)return varchar2 is
l_item_number VARCHAR2(25);
BEGIN
  SELECT primary_vendor_item
  INTO l_item_number
  FROM po_approved_supplier_list
  WHERE using_organization_id = p_org_id
  AND   vendor_id = p_vendor_id
  AND   vendor_site_id = p_vendor_site_id
  AND   item_id = p_item_id;

  RETURN l_item_number;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END;

function cf_vendor_item_numberformula(C_USING_ORG_ID in number, C_VENDOR_ID in number, C_VENDOR_SITE_ID in number, C_ITEM_ID in number) return varchar2 is
begin
  return(F_GET_VENDOR_ITEM_NUMBER(C_USING_ORG_ID,C_VENDOR_ID
                        , C_VENDOR_SITE_ID, C_ITEM_ID));
end;

--Functions to refer Oracle report placeholders--

END PO_POXCORIT_XMLP_PKG ;


/
