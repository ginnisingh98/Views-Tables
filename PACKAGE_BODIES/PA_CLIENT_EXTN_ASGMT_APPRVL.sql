--------------------------------------------------------
--  DDL for Package Body PA_CLIENT_EXTN_ASGMT_APPRVL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CLIENT_EXTN_ASGMT_APPRVL" AS
/*$Header: PARAAPCB.pls 120.1 2005/10/28 11:34:55 ssong noship $*/

--
-- Determine if the specified assignment's approval required items have been changed or not.
--
-- Currently the required items :
--   work type's resource utilization, org utilization, billable flag, assignment start date,
--   assignment end date, bill rates, transfer price rate override, transfer proce currency override,
--   transfer price basis override, transfer price applied % override
--
FUNCTION Is_Asgmt_Appr_Items_Changed
( p_assignment_id             IN   pa_project_assignments.assignment_id%TYPE)
RETURN VARCHAR2
IS

--Row(s) returned if No changes made
CURSOR items_not_changed IS
 SELECT 'N'
 FROM pa_project_assignments ppa,
      pa_assignments_history pah,
      pa_work_types_b       wtv1,
      pa_work_types_b       wtv2
 WHERE ppa.assignment_id      = p_assignment_id
 AND   pah.assignment_id      = p_assignment_id
 AND   pah.last_approved_flag = 'Y'
 AND   ppa.start_date         = pah.start_date
 AND   ppa.end_date           = pah.end_date
 AND  (ppa.work_type_id = pah.work_type_id
       OR  (ppa.work_type_id                     <> pah.work_type_id
            AND wtv1.work_type_id                = ppa.work_type_id
            AND wtv2.work_type_id                = pah.work_type_id
            AND wtv1.BILLABLE_CAPITALIZABLE_FLAG = wtv2.BILLABLE_CAPITALIZABLE_FLAG
            AND wtv1.RES_UTILIZATION_PERCENTAGE  = wtv2.RES_UTILIZATION_PERCENTAGE
            AND wtv1.ORG_UTILIZATION_PERCENTAGE  = wtv2.ORG_UTILIZATION_PERCENTAGE
	   )
   	)
-- Included NVL condition for the below four conditions for Bug#3960313
 AND   nvl(ppa.tp_rate_override, -99)              = nvl(pah.tp_rate_override, -99)
 AND   nvl(ppa.tp_currency_override, '-99')        = nvl(pah.tp_currency_override, '-99')
 AND   nvl(ppa.tp_calc_base_code_override, '-99')  = nvl(pah.tp_calc_base_code_override, '-99')
 AND   nvl(ppa.tp_percent_applied_override, -99)   = nvl(pah.tp_percent_applied_override, -99)
 AND   rownum = 1;

l_is_changed VARCHAR2(1);

BEGIN
  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_CLIENT_EXTN_ASGMT_APPRVL.Is_Asgmt_Appr_Items_Changed');

  OPEN items_not_changed;
  FETCH items_not_changed INTO l_is_changed;

  IF items_not_changed%NOTFOUND THEN
    l_is_changed := 'Y';
  END IF;

  CLOSE items_not_changed;

  RETURN l_is_changed;

  EXCEPTION
     WHEN OTHERS THEN
         -- Set the excetption Message and the stack
         FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_CLIENT_EXTN_ASGMT_APPRVL.Is_Asgmt_Appr_Items_Changed'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
         --
         RAISE;  -- This is optional depending on the needs

END Is_Asgmt_Appr_Items_Changed;


END PA_CLIENT_EXTN_ASGMT_APPRVL;

/
