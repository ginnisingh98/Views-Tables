--------------------------------------------------------
--  DDL for Package Body HXT_TIM_COL_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXT_TIM_COL_UTIL" AS
/* $Header: hxtclut.pkb 120.4.12010000.2 2009/02/24 14:58:25 asrajago ship $ */

/*-------------------------------------------------------------------------
||
||                     Private Module Definitions
||
-------------------------------------------------------------------------*/

/****************************************************
get_element_cat()
Gets earning category of the given element type.
****************************************************/
PROCEDURE get_element_cat(i_element_type_id IN NUMBER,
                          o_earning_cat OUT NOCOPY VARCHAR2 )
IS
BEGIN
   SELECT eltv.hxt_earning_category
     INTO o_earning_cat
     FROM hxt_pay_element_types_f_ddf_v eltv
    WHERE eltv.element_type_id = i_element_type_id;
EXCEPTION
   WHEN no_data_found THEN
      o_earning_cat := NULL;
   WHEN OTHERS THEN
      o_earning_cat := 'ERR';
END get_element_cat;


/*-------------------------------------------------------------------------
||
||                     Public Module Definitions
||
-------------------------------------------------------------------------*/

/********************************************************
 Because customers will have different definitions
 of what an Employee Number is, get_person_id exists
 as a user exit.
 For base system, this call will return
 a valid person_id, last_name, and first_name from
 the per_people_f using the input value employee_number
 passed in as a parameter.
*********************************************************/
FUNCTION get_person_id(i_employee_number IN VARCHAR2,
                       i_business_group_id IN NUMBER,
                       i_date_worked IN DATE,
                       o_person_id OUT NOCOPY NUMBER,
                       o_last_name OUT NOCOPY VARCHAR2,
		       o_first_name OUT NOCOPY VARCHAR2)RETURN NUMBER IS
BEGIN
  SELECT person_id,
	 last_name,
         first_name
    INTO o_person_id,
	 o_last_name,
	 o_first_name
    FROM per_people_f
   WHERE employee_number = i_employee_number
     AND i_date_worked BETWEEN effective_start_date
                           AND effective_end_date
     AND business_group_id = i_business_group_id;

   RETURN 0;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       RETURN 1;
    WHEN OTHERS THEN
       RETURN 2;

END get_person_id;
/***********************************************
  determine_pay_date()
  Rules to define what day an employee is paid
  based upon the time punch will vary. We will
  pass in start_time, end_time, and the person_id
  as arguments to this function.
  Phase I merely sets the date worked = to the
  start time. Future releases will need to determine
  the date worked based upon the employee's
  work schedule.
************************************************/
FUNCTION determine_pay_date( i_start_time IN DATE,
			     i_end_time IN DATE,
                             i_person_id IN NUMBER,
                             o_date_worked OUT NOCOPY DATE) RETURN NUMBER IS
BEGIN
  o_date_worked := trunc(i_start_time);
  RETURN 0;
END determine_pay_date;

/****************************************************
get_earn_pol_id()
Get the earning policy for an assignment number or
an earning policy name.
****************************************************/
FUNCTION get_earn_pol_id(i_assignment_id IN NUMBER DEFAULT NULL,
                         i_date_worked IN DATE,
                         i_earn_pol_name IN VARCHAR2 DEFAULT NULL,
                         o_earn_pol_id OUT NOCOPY earn_pol_id%TYPE) RETURN NUMBER
IS

BEGIN
   IF i_earn_pol_name IS NOT NULL THEN
         /* Earning Policy override from API parameters. */
         SELECT id
           INTO o_earn_pol_id
           FROM hxt_earning_policies
          WHERE name = i_earn_pol_name
            AND i_date_worked BETWEEN effective_start_date
                                  AND effective_end_date;
  ELSIF i_assignment_id IS NOT NULL THEN
         /* No Earning Policy override, get EP for current assignment. */
         SELECT ep.id
           INTO o_earn_pol_id
           FROM hxt_earning_policies ep,
                hxt_per_aei_ddf_v pafv
          WHERE pafv.assignment_id = i_assignment_id
            AND i_date_worked BETWEEN pafv.effective_start_date
                                  AND pafv.effective_end_date
            AND pafv.hxt_earning_policy = ep.id
            AND i_date_worked BETWEEN ep.effective_start_date
                                  AND ep.effective_end_date;
   ELSE
      RETURN 2;
   END IF;
   RETURN 0;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
       RETURN 1;
    WHEN OTHERS THEN
       RETURN 2;

END get_earn_pol_id;

/****************************************************
chk_element_link()
Check that the assignment is eligible for the element.
****************************************************/
--
FUNCTION chk_element_link(p_asg_id           IN NUMBER,
                          p_date_worked      IN DATE,
                          p_element_type_id  IN NUMBER) RETURN NUMBER
IS
--
l_exists VARCHAR2(1);
--
BEGIN

   SELECT MAX('Y') --5574629
     INTO l_exists
     FROM pay_element_links_f ell,
          per_all_assignments_f asm,
          hxt_pay_element_types_f_ddf_v eltv
    WHERE asm.assignment_id = p_asg_id
      AND p_date_worked BETWEEN asm.effective_start_date
                            AND asm.effective_end_date
      AND ell.element_type_id = p_element_type_id
      AND p_date_worked BETWEEN ell.effective_start_date
                            AND ell.effective_end_date
-- Condition modified for Bug 2669059
--      AND eltv.element_type_id = p_element_type_id
	 AND eltv.element_type_id = ell.element_type_id
      AND p_date_worked BETWEEN eltv.effective_start_date
                            AND eltv.effective_end_date
      AND eltv.hxt_earning_category is not null
      AND nvl(ell.organization_id,nvl(asm.organization_id,-1)) =
          nvl(asm.organization_id,-1)
      AND (ell.people_group_id is null
           or exists (SELECT 'x'
                        FROM pay_assignment_link_usages_f usage
                       WHERE usage.assignment_id = asm.assignment_id
                         AND usage.element_link_id = ell.element_link_id
                         AND p_date_worked BETWEEN usage.effective_start_date
                                               AND usage.effective_end_date))
      AND nvl(ell.job_id, nvl(asm.job_id,-1)) = nvl(asm.job_id,-1)
      AND nvl(ell.position_id, nvl(asm.position_id,-1)) = nvl(asm.position_id,-1)
      AND nvl(ell.grade_id,nvl(asm.grade_id,-1)) = nvl(asm.grade_id,-1)
      AND nvl(ell.location_id,nvl(asm.location_id,-1)) = nvl(asm.location_id,-1)
      AND nvl(ell.payroll_id,nvl(asm.payroll_id,-1)) = nvl(asm.payroll_id,-1)
      AND nvl(ell.employment_category, nvl(asm.employment_category,-1)) =
          nvl(asm.employment_category,-1)
      AND nvl(ell.pay_basis_id,nvl(asm.pay_basis_id,-1)) =
          nvl(asm.pay_basis_id,-1)
      AND nvl(ell.business_group_id, nvl(asm.business_group_id,-1)) =
          nvl(asm.business_group_id,-1);
    RETURN 0;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
       RETURN 1;
    WHEN OTHERS THEN
       RETURN 2;

END chk_element_link;

/****************************************************
get_element_type_id()
Get the element type id for an element name.
****************************************************/
FUNCTION get_element_type_id(i_element_name IN VARCHAR2,
 			     i_date_worked IN DATE,
                             i_bg_id IN NUMBER,
                             o_element_type_id OUT NOCOPY NUMBER)RETURN NUMBER
IS
BEGIN
/* SQL query modified for Bug 2597231 */
   SELECT elt.element_type_id
     INTO o_element_type_id
     FROM pay_element_types_f elt,
          pay_element_types_f_tl eltt
    WHERE eltt.element_name = i_element_name
      AND eltt.language = userenv('LANG')
      AND elt.element_type_id = eltt.element_type_id
      AND (elt.business_group_id = i_bg_id or elt.business_group_id is null)
      AND ( legislation_code = ( SELECT legislation_code
                               FROM per_business_groups
                               WHERE business_group_id = i_bg_id) or
           legislation_code is NULL )
      AND i_date_worked BETWEEN elt.effective_start_date
          AND elt.effective_end_date ;
    RETURN 0;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
       RETURN 1;
    WHEN OTHERS THEN
       RETURN 2;

END get_element_type_id;


/****************************************************
get_grade_id()
Get the grade id for a grade code.
****************************************************/
FUNCTION get_grade_id(i_grade_name IN VARCHAR2,
                      i_business_group_id IN NUMBER,
                      i_date_worked IN DATE,
                      o_grade_id OUT NOCOPY NUMBER)RETURN NUMBER
IS
BEGIN
  SELECT grade_id
    INTO o_grade_id
    FROM per_grades
   WHERE name =  i_grade_name
     AND business_group_id + 0 = i_business_group_id
     AND i_date_worked BETWEEN date_from
                           AND nvl(date_to,hr_general.end_of_time);
   RETURN 0;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
       RETURN 1;
    WHEN OTHERS THEN
       RETURN 2;
END get_grade_id;

/****************************************************
get_location_id()
Get the location id for a location code.
****************************************************/
FUNCTION get_location_id(i_location_code IN VARCHAR2,
                         i_date_worked IN DATE,
                         o_location_id OUT NOCOPY NUMBER)RETURN NUMBER
IS
BEGIN

   SELECT location_id
     INTO o_location_id
     FROM hr_locations
    WHERE location_code = i_location_code
      AND COUNTRY = 'US'
      AND i_date_worked <= NVL(INACTIVE_DATE, i_date_worked);

    RETURN 0;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
       RETURN 1;
    WHEN OTHERS THEN
       RETURN 2;

END get_location_id;


/****************************************************
get_project_id()
Get the project id for a project number.
****************************************************/
FUNCTION get_project_id(i_project_number IN VARCHAR2,
                        i_date_worked IN DATE,
                        o_project_id OUT NOCOPY project_id%TYPE) RETURN NUMBER
IS
BEGIN
/* PWM 05-APR-00 Added organization id to select clause */
   SELECT PRJ.PROJECT_ID
     INTO o_project_id
     FROM HXT_ALL_PROJECTS_V PRJ
    WHERE PRJ.PROJECT_NUMBER = i_project_number;

/* PWM 05-APR-00 Added organization id to select clause
*/
    RETURN 0;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
       RETURN 1;
    WHEN OTHERS THEN
       RETURN 2;

END get_project_id;

/****************************************************
get_task_id()
Get the task id for a task number.
****************************************************/
FUNCTION get_task_id(i_task_number IN VARCHAR2,
                     i_date_worked IN DATE,
                     i_project_id IN NUMBER, /* PWM 05-APR-00 */
                     o_task_id OUT NOCOPY NUMBER)RETURN NUMBER
IS
BEGIN
   SELECT TAS.TASK_ID
     INTO o_task_id
     FROM HXT_ALL_TASKS_V TAS
    WHERE TAS.task_number = i_task_number
      AND TAS.project_id = i_project_id ;

    RETURN 0;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
       RETURN 1;
    WHEN OTHERS THEN
       RETURN 2;

END get_task_id;


/*****************************************************
validate_separate_chk_flg()
Up-case and validate the separate check flag parameter.
*****************************************************/
FUNCTION validate_separate_chk_flg
		(io_separate_check_flag IN OUT NOCOPY VARCHAR2) RETURN NUMBER IS
BEGIN
   io_separate_check_flag := UPPER(io_separate_check_flag);

   IF io_separate_check_flag IN ('Y','N') THEN
      RETURN 0;
   ELSE
      RETURN 1;
   END IF;

END validate_separate_chk_flg;


/***********************************************************
validate_earn_reason_code()
Validate the earning reason code parameter of record_time
based on the date_worked and the earning_category for the
element_type_id for the hours_type parameter of record_time.
************************************************************/
FUNCTION validate_earn_reason_code(i_earn_reason_code IN VARCHAR2,
                                   i_date_worked      IN DATE) RETURN NUMBER
                                   -- i_element_type_id IN NUMBER)RETURN NUMBER
IS

   -- hxt_earning_category VARCHAR2(30);
   hold_reason_code VARCHAR2(80);

BEGIN
   -- get_element_cat(i_element_type_id, hxt_earning_category);
   -- IF hxt_earning_category IS NULL OR
      -- hxt_earning_category = 'ERR'
   -- THEN
      -- RETURN 1;
   -- ELSE
      SELECT fcl.meaning
        INTO hold_reason_code
        FROM hr_lookups fcl
       WHERE fcl.lookup_code = i_earn_reason_code
         AND i_date_worked BETWEEN NVL(fcl.start_date_active, i_date_worked)
                               AND NVL(fcl.end_date_active, i_date_worked)
         AND fcl.application_id = g_orcl_hr_app_id_cons
         AND fcl.enabled_flag = 'Y'
         AND fcl.lookup_type = 'ELE_ENTRY_REASON';

      RETURN 0;
   -- END IF;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN 2;
   WHEN OTHERS THEN
      RETURN 3;
END validate_earn_reason_code;


/***********************************************************
validate_time_summary_id()
Validate the time summary id parameter of record_time.
************************************************************/
FUNCTION validate_time_summary_id( i_time_summary_id IN NUMBER)RETURN NUMBER
IS

   l_dummy CHAR(1);

BEGIN
      SELECT '1'
        INTO l_dummy
        FROM hxt_sum_hours_worked
       WHERE id = i_time_summary_id;

      RETURN 0;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN 1;
   WHEN OTHERS THEN
      RETURN 2;
END validate_time_summary_id;


/*******************************************************************
validate_cost_center_id()
This validates the foreign key via the non-table lookup item(s), an
selects the foreign key column(s) into the hidden base table item(s)
********************************************************************/
FUNCTION validate_cost_center_id(i_cost_center_id IN NUMBER,
                                 i_date_worked IN DATE )RETURN NUMBER
IS
   hold_cost_center_id NUMBER(15);
BEGIN
 --
 -- Replace ADT code with TA36 cost allocation code.
 --
   SELECT PCAK.COST_ALLOCATION_KEYFLEX_ID
     INTO hold_cost_center_id
     FROM PAY_COST_ALLOCATION_KEYFLEX PCAK
    WHERE PCAK.COST_ALLOCATION_KEYFLEX_ID = i_cost_center_id;
   RETURN 0;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
       RETURN 1;
    WHEN OTHERS THEN
       RETURN 2;
END validate_cost_center_id;


/*******************************************************************
validate_timecard_source()
Validates the timecard source parameter.

Bug 2398037.
the comparison of meaning with i_timecard_source will fail in
non-english instances. Instead, we can use lookup code as the function
only checks for the existence of lookup.

********************************************************************/
FUNCTION validate_timecard_source(i_timecard_source IN VARCHAR2,
                    i_date_worked IN DATE,
                    o_timecard_source_code OUT NOCOPY VARCHAR2 )RETURN NUMBER IS
BEGIN
   SELECT fcl.lookup_code
     INTO o_timecard_source_code
     FROM hr_lookups fcl
/*    WHERE fcl.meaning = i_timecard_source    bug 2398037 */
      WHERE fcl.lookup_code = 'S'
 AND i_date_worked BETWEEN NVL(fcl.start_date_active, i_date_worked)
                            AND NVL(fcl.end_date_active, i_date_worked)
      AND fcl.application_id = g_orcl_tm_app_id_cons
      AND fcl.enabled_flag = 'Y'
      AND fcl.lookup_type = 'HXT_TIMECARD_SOURCE';
   RETURN 0;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
       RETURN 1;
    WHEN OTHERS THEN
       RETURN 2;
END validate_timecard_source;


/*******************************************************************
validate_wage_code()
Validate the prevailing wage code.
********************************************************************/
FUNCTION validate_wage_code(i_wage_code IN VARCHAR2,
                                 i_date_worked IN DATE )RETURN NUMBER
IS
   hold_wage_code VARCHAR2(10);
BEGIN
   SELECT prev_wage_code
     INTO hold_wage_code
     FROM hxt_prev_wage_base pwb
    WHERE pwb.prev_wage_code = i_wage_code
      AND i_date_worked BETWEEN pwb.effective_start_date
                            AND pwb.effective_end_date;
   RETURN 0;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
       RETURN 1;
    WHEN OTHERS THEN
       RETURN 2;
END validate_wage_code;


/*******************************************************************
get_session_date()
Get the current session date from fnd_sessions.
********************************************************************/
FUNCTION get_session_date(o_sess_date OUT NOCOPY DATE )RETURN NUMBER
IS
   hold_sess_date DATE;
BEGIN

   -- Bug 7359347
   -- Check if there exists a cached value before querying on FND_SESSIONS.

   IF g_session_date.EXISTS(USERENV('SESSIONID'))
   THEN
      o_sess_date := g_session_date(USERENV('SESSIONID'));
   ELSE
      SELECT effective_date
        INTO hold_sess_date
        FROM fnd_sessions
       WHERE session_id = USERENV('SESSIONID');

      o_sess_date := hold_sess_date;
      -- Bug 7359347
      -- cache the new value for next call.
      g_session_date(USERENV('SESSIONID')) := hold_sess_date;

   END IF;

   RETURN 0;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
       RETURN 1;
END get_session_date;


-- Bug 7359347
-- Following function picks up the session date from
-- the global g_session_date table instead of FND_SESSIONS if it exists.
-- It would call get_session_date above if the value doesnt exist.
-- Subsequently, the returned value is cached.

FUNCTION return_session_date
RETURN DATE
IS

l_retcode   NUMBER;
l_sessdate  DATE;

BEGIN

   -- Check if this session already has one.
   IF g_session_date.EXISTS(USERENV('SESSIONID'))
   THEN
      -- It has one, return it.
      RETURN g_session_date(USERENV('SESSIONID'));
   ELSE
      -- Need to pick up one from FND_SESIONS.  Call the above function.
      l_retcode := get_session_date(l_sessdate);
   END IF;

   RETURN l_sessdate;
END return_session_date;




END HXT_TIM_COL_UTIL;

/
