--------------------------------------------------------
--  DDL for Package Body BEN_BENXSMRY_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BENXSMRY_XMLP_PKG" AS
/* $Header: BENXSMRYB.pls 120.1 2007/12/10 08:41:35 vjaganat noship $ */

function valueformula(ext_rcd_id in number, ext_rslt_dtl_id in number, seq_num in number) return varchar2 is
begin
  return(ben_ext_util.get_value(ext_rcd_id, ext_rslt_dtl_id, seq_num));
end;

function business_groupformula(p_business_group_id in number) return varchar2 is

  cursor get_bg_name is
  SELECT name
  FROM   per_business_groups
  WHERE  business_group_id = p_business_group_id;

  l_name   per_business_groups.name%type ;
begin
  open get_bg_name;
  fetch get_bg_name into l_name;
  close get_bg_name;

  return (l_name);
end;

function total_peopleformula(people_count_dummy in number, error_count_dummy in number) return number is
begin
  return(nvl(people_count_dummy, 0) + nvl(error_count_dummy, 0));
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

END BEN_BENXSMRY_XMLP_PKG ;

/
