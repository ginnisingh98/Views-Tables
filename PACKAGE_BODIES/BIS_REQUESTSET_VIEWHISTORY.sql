--------------------------------------------------------
--  DDL for Package Body BIS_REQUESTSET_VIEWHISTORY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_REQUESTSET_VIEWHISTORY" AS
/*$Header: BISRSVHB.pls 120.0 2005/06/01 18:20:19 appldev noship $*/

/* for bug#3807130.
 * no one should use this funciton any more.
 * get_sys_lookup_meaning and get_bis_lookup_meaning
 * should be used instead.
 */
function get_lookup_meaning(p_type in varchar2,
                            p_code in varchar2) return varchar2 is

 l_meaning varchar2(80);
 begin
  return null;
 end;


function get_sys_lookup_meaning(p_type in varchar2,
                            p_code in varchar2) return varchar2 is

 l_meaning varchar2(80);
 begin
   select distinct meaning into l_meaning
   from fnd_lookups
   where lookup_type=p_type
   and lookup_code=NVL(p_code, 'N');
   return l_meaning;
 exception
   when no_data_found then
     return null;
   when others then
     raise;
 end;


function get_bis_lookup_meaning(p_type in varchar2,
                            p_code in varchar2) return varchar2 is

 l_meaning varchar2(80);
 begin
   select distinct meaning into l_meaning
   from fnd_common_lookups
   where lookup_type=p_type
   and lookup_code=NVL(p_code, 'N');
   return l_meaning;
 exception
   when no_data_found then
     return null;
   when others then
     raise;
 end;


END BIS_REQUESTSET_VIEWHISTORY;

/
