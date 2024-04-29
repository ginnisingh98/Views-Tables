--------------------------------------------------------
--  DDL for Package PQP_GB_PSI_HRS_HISTORY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_GB_PSI_HRS_HISTORY" 
--  /* $Header: pqpgbpsihrs.pkh 120.0.12000000.2 2007/02/13 13:52:25 mseshadr noship $ */
AUTHID CURRENT_USER AS
   --
   -- Debug Variables.
   --
   g_proc_name              VARCHAR2(61)       := 'pqp_gb_psi_hrs_history.';
   g_legislation_code       per_business_groups.legislation_code%TYPE   := 'GB';
   g_debug                  BOOLEAN                 := hr_utility.debug_enabled;
   g_business_group_id      NUMBER;
   g_effective_date         DATE;
   g_extract_type           VARCHAR2(100);
   g_cutover_date           DATE;
   g_ext_dfn_id             NUMBER;
   g_paypoint               VARCHAR2(10);
   g_active_asg_sts_id      NUMBER;
   g_terminate_asg_sts_id   NUMBER;
   g_event_counter          NUMBER;
   g_assignment_id          NUMBER;
   g_nested_level           NUMBER(5)           := pqp_utilities.g_nested_level;
   g_person_id              NUMBER;
   g_start_date             DATE;
   g_end_date               DATE;
   g_ft_hours               NUMBER;
   g_pt_hours               NUMBER;
   g_hours_type             VARCHAR2(10);

   TYPE r_element_details IS RECORD(
      element_type_id    NUMBER
     ,input_value_name   pay_input_values_f.NAME%TYPE
     ,input_value_id     NUMBER
   );

   TYPE r_ele_ent_details IS RECORD(
      element_entry_id       NUMBER
     ,effective_start_date   DATE
     ,effective_end_date     DATE
     ,element_type_id        NUMBER
   );

   TYPE r_asg_details IS RECORD(
      person_id                   NUMBER
     ,effective_start_date        DATE
     ,effective_end_date          DATE
     ,assignment_number           per_all_assignments_f.assignment_number%TYPE
     ,primary_flag                per_all_assignments_f.primary_flag%TYPE
     ,normal_hours                per_all_assignments_f.normal_hours%TYPE
     ,assignment_status_type_id   NUMBER
     ,employment_category         per_all_assignments_f.employment_category%TYPE
   );

   TYPE r_lookup_code IS RECORD(
      lookup_code   hr_lookups.lookup_code%TYPE
     ,meaning       hr_lookups.meaning%TYPE
   );

   -- cursor to fetch dated table info
   CURSOR csr_get_dated_table_info(c_table_name VARCHAR2)
   IS
      SELECT dated_table_id, table_name, surrogate_key_name
        FROM pay_dated_tables
       WHERE table_name = c_table_name;

   TYPE t_dated_table IS TABLE OF csr_get_dated_table_info%ROWTYPE
      INDEX BY BINARY_INTEGER;

   -- Cursor to get event group info
   CURSOR csr_get_event_group_info(c_event_group VARCHAR2)
   IS
      SELECT event_group_id, event_group_name, event_group_type
        FROM pay_event_groups
       WHERE event_group_name = c_event_group
         AND (
                 (business_group_id = g_business_group_id)
              OR (
                      business_group_id IS NULL
                  AND (
                          legislation_code IS NULL
                       OR legislation_code = g_legislation_code
                      )
                 )
             );

   TYPE t_event_group IS TABLE OF csr_get_event_group_info%ROWTYPE
      INDEX BY BINARY_INTEGER;

--   TYPE t_config_values IS TABLE OF r_config_values
--   INDEX BY BINARY_INTEGER;

   TYPE t_number IS TABLE OF NUMBER
      INDEX BY BINARY_INTEGER;

   TYPE t_element_details IS TABLE OF r_element_details
      INDEX BY BINARY_INTEGER;

   TYPE t_varchar2 IS TABLE OF VARCHAR2(150)
      INDEX BY BINARY_INTEGER;

   TYPE t_lookups IS TABLE OF r_lookup_code
      INDEX BY BINARY_INTEGER;

   g_tab_event_map_cv       pqp_utilities.t_config_values;
   g_tab_pen_sch_map_cv     pqp_utilities.t_config_values;
   g_tab_emp_typ_map_cv     pqp_utilities.t_config_values;
   g_tab_asg_status         t_number;
   g_tab_pen_ele_ids        t_element_details;
   g_tab_prs_dfn_cv         pqp_utilities.t_config_values;
   g_tab_event_desc_lov     t_lookups;
   g_person_dtl             per_all_people_f%ROWTYPE;
   g_assignment_dtl         per_all_assignments_f%ROWTYPE;
   g_tab_dated_table        t_dated_table;
   g_tab_pay_proc_evnts     ben_ext_person.t_detailed_output_table;
   g_tab_event_group        t_event_group;
   g_prev_pay_proc_evnts    ben_ext_person.t_detailed_output_tab_rec;

   -- cursor to fetch the asg status type id details
   CURSOR csr_get_asg_sts_dtls(c_per_system_status VARCHAR2)
   IS
      SELECT assignment_status_type_id, default_flag, active_flag, primary_flag
            ,user_status, pay_system_status, per_system_status
        FROM per_assignment_status_types
       WHERE per_system_status = c_per_system_status
         AND (
                 (business_group_id = g_business_group_id)
              OR (
                      business_group_id IS NULL
                  AND (
                          legislation_code IS NULL
                       OR legislation_code = g_legislation_code
                      )
                 )
             );

   -- Cursor to get abv details
   CURSOR csr_abv_dtls (c_assignment_id  NUMBER
                       ,c_effective_date DATE
                       )
   IS
      SELECT assignment_budget_value_id
            ,assignment_id
            ,effective_start_date
            ,effective_end_date
            ,unit
            ,value
        FROM per_assignment_budget_values_f
       WHERE assignment_id = c_assignment_id
         AND unit = 'FTE'
         AND c_effective_date BETWEEN effective_start_date
                                  AND effective_end_date;

   -- Debug
   PROCEDURE DEBUG(
      p_trace_message    IN   VARCHAR2
     ,p_trace_location   IN   NUMBER DEFAULT NULL
   );

   -- Debug_Enter
   PROCEDURE debug_enter(
      p_proc_name   IN   VARCHAR2
     ,p_trace_on    IN   VARCHAR2 DEFAULT NULL
   );

   -- Debug_Exit
   PROCEDURE debug_exit(
      p_proc_name   IN   VARCHAR2
     ,p_trace_off   IN   VARCHAR2 DEFAULT NULL
   );

   -- Debug Others
   PROCEDURE debug_others(
      p_proc_name   IN   VARCHAR2
     ,p_proc_step   IN   NUMBER DEFAULT NULL
   );

   -- Part Time Hours History Cutover Criteria
   FUNCTION chk_hrs_cutover_criteria(
      p_business_group_id   IN   NUMBER
     ,p_effective_date      IN   DATE
     ,p_assignment_id       IN   NUMBER
   )
      RETURN VARCHAR2;

   -- Part Time Hours History Periodic Criteria
   FUNCTION chk_hrs_periodic_criteria(
      p_business_group_id   IN   NUMBER
     ,p_effective_date      IN   DATE
     ,p_assignment_id       IN   NUMBER
   )
      RETURN VARCHAR2;

   -- Part Time Hours History Data
   FUNCTION get_hrs_history_data(
      p_business_group_id   IN   NUMBER
     ,p_effective_date      IN   DATE
     ,p_assignment_id       IN   NUMBER
     ,p_rule_parameter      IN   VARCHAR2
   )
      RETURN VARCHAR2;

   -- Part Time Hours History Post Process
   FUNCTION hrs_history_post_process(p_ext_rslt_id IN NUMBER)
      RETURN VARCHAR2;
END pqp_gb_psi_hrs_history;

 

/
