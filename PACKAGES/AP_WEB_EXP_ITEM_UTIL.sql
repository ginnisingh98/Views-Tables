--------------------------------------------------------
--  DDL for Package AP_WEB_EXP_ITEM_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_EXP_ITEM_UTIL" AUTHID CURRENT_USER AS
/* $Header: apweiuts.pls 115.1 2002/08/25 19:49:53 osteinme noship $ */

   g_exp_report_id NUMBER;
   g_exp_report_parameter_id NUMBER;

   function get_rep_id return NUMBER;
   function get_exp_param_id return NUMBER;
   procedure set_rep_id(id IN NUMBER);
   procedure set_exp_param_id(id IN NUMBER);
   function itemization_allowed(p_parameter_id IN NUMBER) RETURN VARCHAR2;
end ap_web_exp_item_util;

 

/
