--------------------------------------------------------
--  DDL for Package Body EDW_POA_CURR_CONV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_POA_CURR_CONV" as
/*$Header: poacurrb.pls 115.2 2003/01/09 23:38:11 rvickrey ship $ */

l_conversion_rate number := 1;

function convert_currency(
                         p_from_currency varchar2,
                         p_to_currency varchar2,
                         p_rate_date date,
                         p_rate_type varchar2
                         ) return number is

 begin

   begin
     l_conversion_rate := gl_currency_api.get_rate(p_from_currency,p_to_currency,p_rate_date,p_rate_type);

   exception
    when others then
      l_conversion_rate := 1;
   end;

 return l_conversion_rate;

 end convert_currency;

END EDW_POA_CURR_CONV;


/
