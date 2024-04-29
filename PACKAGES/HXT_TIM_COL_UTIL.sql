--------------------------------------------------------
--  DDL for Package HXT_TIM_COL_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXT_TIM_COL_UTIL" AUTHID CURRENT_USER AS
/* $Header: hxtclut.pkh 120.0.12010000.2 2009/02/24 14:06:46 asrajago ship $ */

/*------------------------------
|| Base Anchored Declarations
------------------------------*/
  project_id hxt_projects_v.project_id%TYPE;
  earn_pol_id hxt_earning_policies.id%TYPE;

/*------------------------------
||         Constants
------------------------------*/
  g_orcl_tm_app_id_cons CONSTANT hr_lookups.application_id%TYPE := 808;
  g_orcl_hr_app_id_cons CONSTANT hr_lookups.application_id%TYPE := 800;


  -- Bug 7359347
  -- The below associative array holds the session date
  -- indexed by sessionid.

  TYPE DATETAB IS TABLE OF DATE INDEX BY BINARY_INTEGER;

  g_session_date  DATETAB;


/*------------------------------------
|| Public Module Declarations
------------------------------------*/
   FUNCTION get_person_id(i_employee_number IN VARCHAR2,
                          i_business_group_id IN NUMBER,
                          i_date_worked IN DATE,
                          o_person_id OUT NOCOPY NUMBER,
                          o_last_name OUT NOCOPY VARCHAR2,
                          o_first_name OUT NOCOPY VARCHAR2)RETURN NUMBER;

   FUNCTION determine_pay_date( i_start_time IN DATE,
                                i_end_time IN DATE,
                                i_person_id IN NUMBER,
                                o_date_worked OUT NOCOPY DATE) RETURN NUMBER;

   FUNCTION get_element_type_id(i_element_name IN VARCHAR2,
       	                        i_date_worked IN DATE,
                                i_bg_id        IN NUMBER,
                                o_element_type_id OUT NOCOPY NUMBER)RETURN NUMBER;

   FUNCTION chk_element_link(p_asg_id           IN NUMBER,
                             p_date_worked      IN DATE,
                             p_element_type_id  IN NUMBER) RETURN NUMBER;

   FUNCTION get_earn_pol_id(i_assignment_id IN NUMBER DEFAULT NULL,
                            i_date_worked IN DATE,
                            i_earn_pol_name IN VARCHAR2 DEFAULT NULL,
                            o_earn_pol_id OUT NOCOPY earn_pol_id%TYPE) RETURN NUMBER;

   FUNCTION get_task_id(i_task_number IN VARCHAR2,
                        i_date_worked IN DATE,
                        i_project_id IN NUMBER, /* PWM 05-APR-00 */
                        o_task_id OUT NOCOPY NUMBER)RETURN NUMBER;

   FUNCTION get_grade_id(i_grade_name IN VARCHAR2,
                         i_business_group_id IN NUMBER,
                         i_date_worked IN DATE,
                         o_grade_id OUT NOCOPY NUMBER)RETURN NUMBER;

   FUNCTION get_location_id(i_location_code IN VARCHAR2,
                            i_date_worked IN DATE,
                            o_location_id OUT NOCOPY NUMBER)RETURN NUMBER;

   FUNCTION get_project_id(i_project_number IN VARCHAR2,
                           i_date_worked IN DATE,
                           o_project_id OUT NOCOPY project_id%TYPE)RETURN NUMBER;

   FUNCTION validate_separate_chk_flg(io_separate_check_flag IN OUT NOCOPY VARCHAR2) RETURN NUMBER;

   FUNCTION validate_earn_reason_code(i_earn_reason_code IN VARCHAR2,
                                      i_date_worked      IN DATE) RETURN NUMBER;
                       --           i_element_type_id IN NUMBER) RETURN NUMBER;

   FUNCTION validate_time_summary_id( i_time_summary_id IN NUMBER)RETURN NUMBER;

   FUNCTION validate_cost_center_id(i_cost_center_id IN NUMBER,
                                    i_date_worked IN DATE )RETURN NUMBER;

   FUNCTION validate_timecard_source( i_timecard_source IN VARCHAR2,
                                      i_date_worked IN DATE,
                                      o_timecard_source_code OUT NOCOPY VARCHAR2  ) RETURN NUMBER;

   FUNCTION validate_wage_code(i_wage_code IN VARCHAR2,
                               i_date_worked IN DATE )RETURN NUMBER;

   FUNCTION get_session_date(o_sess_date OUT NOCOPY DATE )RETURN NUMBER;


   -- Bug 7359347
   -- Added new global function which returns session date for this session id.

   FUNCTION return_session_date RETURN DATE;


END HXT_TIM_COL_UTIL;

/
