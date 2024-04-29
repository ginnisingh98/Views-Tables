--------------------------------------------------------
--  DDL for Package Body PO_POXCORSL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_POXCORSL_XMLP_PKG" AS
/* $Header: POXCORSLB.pls 120.1 2007/12/25 10:53:09 krreddy noship $ */

USER_EXIT_FAILURE EXCEPTION;

function BeforeReport return boolean is
begin
declare
cursor org_cursor IS
  select ood.organization_name
  from org_organization_definitions ood
  where ood.organization_id = p_ship_to;
l_org_displayed  org_organization_definitions.organization_name%type ;


begin
  OPEN org_cursor;
  FETCH org_cursor INTO l_org_displayed;
  P_SHIP_TO_ORG_NAME:=l_org_displayed;
  CLOSE org_cursor;




  if p_country_of_origin_code IS NOT NULL then
    p_query_where_country_code := ' paa.country_of_origin_code = '|| '''' || P_COUNTRY_OF_ORIGIN_CODE || '''';
  end if;
end;
BEGIN
  /*SRW.USER_EXIT('FND SRWINIT');*/null;

  EXCEPTION WHEN  USER_EXIT_FAILURE /*SRW.USER_EXIT_FAILURE */THEN
            /*SRW.MESSAGE(1,'srw_init');*/null;

END;
BEGIN

 null;
  EXCEPTION WHEN  USER_EXIT_FAILURE /*SRW.USER_EXIT_FAILURE */THEN
            /*SRW.MESSAGE(1,'Before Item Flex');*/null;

END;

  return (TRUE);
end;

function AfterReport return boolean is
begin
  /*SRW.USER_EXIT('FND SRWEXIT');*/null;

  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

END PO_POXCORSL_XMLP_PKG ;


/
