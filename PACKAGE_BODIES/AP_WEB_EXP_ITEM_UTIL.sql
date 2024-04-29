--------------------------------------------------------
--  DDL for Package Body AP_WEB_EXP_ITEM_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_EXP_ITEM_UTIL" AS
/* $Header: apweiutb.pls 115.2 2002/11/03 22:18:25 osteinme noship $ */


function get_rep_id RETURN NUMBER is
begin
  return g_exp_report_id;
end;

function get_exp_param_id RETURN NUMBER is
begin
  return g_exp_report_parameter_id;
end;

procedure set_rep_id(id IN NUMBER) is
begin
  g_exp_report_id := id;
end;

procedure set_exp_param_id(id IN NUMBER) is
begin
  g_exp_report_parameter_id := id;
end;


/* **********************************************************************
   function itemization_allowed

   This function is used in the view ap_web_exp_type_item_v to determine
   if the 'itemization allowed' checkbox in the itemizations window should
   be checked or not.  It expects the g_exp_report_parameter_id package
   global to be set.

   ********************************************************************** */

function itemization_allowed(p_parameter_id IN NUMBER) RETURN VARCHAR2 is
  l_count NUMBER;
begin

  select count(1)
  into l_count
  from ap_pol_itemizations pi
  where pi.itemization_parameter_id = p_parameter_id
  and pi.parameter_id = g_exp_report_parameter_id;

  if l_count = 0 then
    return 'N';
  else
    return 'Y';
  end if;
end;

end ap_web_exp_item_util;

/
