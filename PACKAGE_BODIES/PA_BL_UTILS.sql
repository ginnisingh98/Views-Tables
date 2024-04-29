--------------------------------------------------------
--  DDL for Package Body PA_BL_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_BL_UTILS" AS
/* $Header: PAXCCBLB.pls 115.0 99/09/29 14:25:53 porting shi $*/


--===========================================================================
-- Function Name : get_supplier_or_emp_name
-- Description   : Gets the supplier name if the expenditure system linkage
--                 function is of type 'VI'. Otherwise, gets the employee
--                 full name.
-- Parameters    : v_expenditure_item_id - Expenditure Item ID
--                 v_sys_linkage_func    - system linkage function
--                 v_creation_date       - Expenditure Item Date
--                 v_person_id           - Incurred by Person ID
-- Return        : either the supplier name or the employee full name.
--===========================================================================
FUNCTION get_supplier_or_emp_name
  (v_expenditure_item_id IN pa_expenditure_items_all.expenditure_item_id%TYPE,
   v_sys_linkage_func IN pa_expenditure_items_all.system_linkage_function%TYPE,
   v_creation_date IN pa_expenditure_items_all.expenditure_item_date%TYPE,
   v_person_id IN pa_expenditures_all.incurred_by_person_id%TYPE)
  RETURN VARCHAR2
IS
  v_emp_name            per_people_f.full_name%TYPE := NULL;
  v_vendor_id           po_vendors.vendor_id%TYPE;
  v_vendor_name         po_vendors.vendor_name%TYPE := NULL;
  v_sup_err_msg         VARCHAR2(20) := 'NO SUPPLIER FOUND';
  v_emp_err_msg         VARCHAR2(20) := 'NO EMPLOYEE FOUND';
BEGIN
  IF v_sys_linkage_func = 'VI' THEN
     BEGIN
       SELECT TO_NUMBER(system_reference1)
       INTO v_vendor_id
       FROM pa_cost_distribution_lines_all
       WHERE expenditure_item_id = v_expenditure_item_id
       AND   line_num = 1;

       IF v_vendor_id IS NOT NULL THEN
          SELECT vendor_name
          INTO v_vendor_name
          FROM po_vendors
          WHERE vendor_id = v_vendor_id;
       END IF;

       RETURN v_vendor_name;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
            RETURN v_sup_err_msg;
     END;
  ELSE
     BEGIN
       SELECT full_name
       INTO v_emp_name
       FROM per_people_f
       WHERE v_person_id = person_id
       AND   v_creation_date BETWEEN effective_start_date
             AND NVL(effective_end_date, v_creation_date)
       AND   ROWNUM < 2;

       RETURN v_emp_name;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
            RETURN v_emp_err_msg;
     END;
  END IF;

END get_supplier_or_emp_name;


--===========================================================================
-- Function Name : get_organization_name
-- Description   : Get the non-labor organization name if the system linkage
--                 function is of type 'USG'. Otherwise, gets either the
--                 incurred by organization name or the override to
--                 organization name (depending on whether override to
--                 organization has been specified).
-- Parameters    : v_sys_linkage_fn    - system linkage function
--                 v_non_labor_orgid   - Non Labor Organization ID
--                 v_override_orgid    - Override To Organization ID
--                 v_incurred_by_orgid - Incurred by Organization ID
-- Return        : organization name
--===========================================================================
FUNCTION get_organization_name
  (v_sys_linkage_fn IN pa_expenditure_items_all.system_linkage_function%TYPE,
   v_non_labor_orgid IN pa_expenditure_items_all.organization_id%TYPE,
   v_override_orgid IN pa_expenditure_items_all.override_to_organization_id%TYPE,
   v_incurred_by_orgid IN pa_expenditures_all.incurred_by_organization_id%TYPE)
  RETURN VARCHAR2
IS
  v_org_id   hr_all_organization_units_tl.organization_id%TYPE;
  v_org_name hr_all_organization_units_tl.name%TYPE;
  v_error_msg    VARCHAR2(25) := 'NO ORGANIZATION FOUND';
BEGIN

  -- get the appropriate organization id
  IF v_sys_linkage_fn = 'USG' THEN
     v_org_id := v_non_labor_orgid;
  ELSE
     v_org_id := NVL(v_override_orgid, v_incurred_by_orgid);
  END IF;

  -- get organization name
  SELECT name
  INTO v_org_name
  FROM hr_all_organization_units_tl
  WHERE organization_id = v_org_id
  AND   decode(organization_id, null, '1', language)
         = decode(organization_id, null, '1', userenv('lang'));

  RETURN v_org_name;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
       RETURN v_error_msg;

END get_organization_name;


END PA_BL_UTILS;

/
