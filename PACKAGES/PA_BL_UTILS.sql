--------------------------------------------------------
--  DDL for Package PA_BL_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_BL_UTILS" AUTHID CURRENT_USER AS
/* $Header: PAXCCBLS.pls 115.0 99/09/29 14:26:08 porting shi $*/

FUNCTION get_supplier_or_emp_name
  (v_expenditure_item_id IN pa_expenditure_items_all.expenditure_item_id%TYPE,
   v_sys_linkage_func IN pa_expenditure_items_all.system_linkage_function%TYPE,
   v_creation_date IN pa_expenditure_items_all.expenditure_item_date%TYPE,
   v_person_id IN pa_expenditures_all.incurred_by_person_id%TYPE)
  RETURN VARCHAR2;

FUNCTION get_organization_name
  (v_sys_linkage_fn IN pa_expenditure_items_all.system_linkage_function%TYPE,
   v_non_labor_orgid IN pa_expenditure_items_all.organization_id%TYPE,
   v_override_orgid IN pa_expenditure_items_all.override_to_organization_id%TYPE,
   v_incurred_by_orgid IN pa_expenditures_all.incurred_by_organization_id%TYPE)
  RETURN VARCHAR2;

END PA_BL_UTILS;

 

/
