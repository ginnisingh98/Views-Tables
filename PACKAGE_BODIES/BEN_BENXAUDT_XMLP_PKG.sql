--------------------------------------------------------
--  DDL for Package Body BEN_BENXAUDT_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BENXAUDT_XMLP_PKG" AS
/* $Header: BENXAUDTB.pls 120.1 2007/12/10 08:39:53 vjaganat noship $ */

  procedure get_seq_num is
  begin
    g_counter := g_counter + 1;
  end;

function valueformula(ext_rcd_id in number, ext_rslt_dtl_id in number, seq_num in number) return varchar2 is
begin
  return(ben_ext_util.get_value(ext_rcd_id, ext_rslt_dtl_id, seq_num));
end;

--function business_nameformula(business_group_id in number) return varchar2 is
function business_nameformula(p_business_group_id in number) return varchar2 is
  cursor get_bg is
  SELECT name
  FROM   hr_all_organization_units_vl
  --WHERE  organization_id = business_group_id;
  WHERE  organization_id = p_business_group_id;
  l_bg_name    hr_all_organization_units.name%type;
begin

  open get_bg;
  fetch get_bg into l_bg_name;
  close get_bg;
  return (l_bg_name);
end;

function BetweenPage return boolean is
begin
  g_counter := g_counter - 1;
  return (TRUE);
end;

function BeforeReport return boolean is
begin
    --hr_standard.event('BEFORE REPORT');
  return (TRUE);
end;

function AfterReport return boolean is
begin
    --hr_standard.event('AFTER REPORT');
  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

END BEN_BENXAUDT_XMLP_PKG ;

/
