--------------------------------------------------------
--  DDL for Package PQP_GB_PSI_EARNINGS_HISTORY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_GB_PSI_EARNINGS_HISTORY" 
--  /* $Header: pqpgbpsiern.pkh 120.7.12010000.5 2009/04/24 12:02:20 jvaradra ship $ */
AUTHID CURRENT_USER AS
   --
   -- Debug Variables.
   --
   g_proc_name              VARCHAR2(61)      := 'pqp_gb_psi_earnings_history.';
   g_legislation_code       per_business_groups.legislation_code%TYPE   := 'GB';
   g_debug                  BOOLEAN                 := hr_utility.debug_enabled;
   g_business_group_id      NUMBER;
   g_effective_date         DATE;
   g_extract_type           VARCHAR2(100);
   g_cutover_date           DATE;
   g_ext_dfn_id             NUMBER;
   g_paypoint               VARCHAR2(10);
   g_nested_level           NUMBER(5)           := pqp_utilities.g_nested_level;
   g_assignment_id          NUMBER;
   g_ni_ele_type_id         NUMBER;
   g_ni_category_iv_id      NUMBER;
   g_ni_pension_iv_id       NUMBER;
   g_ni_euel_bal_type_id    NUMBER;
   g_ni_euel_ptd_bal_id     NUMBER;
   g_ni_eet_bal_type_id     NUMBER;
   g_ni_eet_ptd_bal_id      NUMBER;
 --Bug 7312374: Added globals for NI UAP
   g_ni_euap_bal_type_id    NUMBER;
   g_ni_euap_ptd_bal_id     NUMBER;

   -- For bug 7297812
   g_asst_action_id    NUMBER;
   g_prev_asst_action_id NUMBER;
   g_prev_assg_id  NUMBER := -1;

   -- For Bug 8425023

   g_check_balance VARCHAR2(10) := 'Y';


 -- Commenting the below variables as they are now replaced by g_tot_ayr_fb_cont_bal_id and g_tot_ayr_fb_ptd_bal_id
/* g_tot_byb_cont_bal_id    NUMBER;
   g_tot_byb_ptd_bal_id     NUMBER; */

   g_tot_ayr_cont_bal_id    NUMBER;
   g_tot_ayr_ptd_bal_id     NUMBER;
   -- For 115.9
   g_tot_ayr_ytd_bal_id     NUMBER;

   g_tot_ayr_fb_cont_bal_id    NUMBER;
   g_tot_ayr_fb_ptd_bal_id     NUMBER;
   -- For 115.9
   g_tot_ayr_fb_ytd_bal_id     NUMBER;

   /* Begin for Nuvos */

   g_tot_apavc_cont_bal_id    NUMBER;
   g_tot_apavc_ptd_bal_id     NUMBER;
   -- For 115.9
   g_tot_apavc_ytd_bal_id     NUMBER;

   g_tot_apavcm_cont_bal_id    NUMBER;
   g_tot_apavcm_ptd_bal_id     NUMBER;
   -- For 115.9
   g_tot_apavcm_ytd_bal_id     NUMBER;

   /* END for Nuvos */

   g_effective_start_date   DATE;
   g_effective_end_date     DATE;
   g_procptd_dimension_id   NUMBER;
   -- For 115.9
   g_penytd_dimension_id   NUMBER;
   g_tdptd_dimension_id     NUMBER;
   g_ayfwd_bal_conts        NUMBER;
   g_ni_e_cat_exists        VARCHAR2(10);
   g_member                 VARCHAR2(10);

   g_ayfb_bal_conts         NUMBER;

--For Bug 5941475
   g_ern_term_exclude_flag  VARCHAR2(10) := 'Y';

--    TYPE r_config_values IS RECORD (
--       pcv_information1               pqp_configuration_values.pcv_information1%TYPE,
--       pcv_information2               pqp_configuration_values.pcv_information2%TYPE,
--       pcv_information3               pqp_configuration_values.pcv_information3%TYPE,
--       pcv_information4               pqp_configuration_values.pcv_information4%TYPE,
--       pcv_information5               pqp_configuration_values.pcv_information5%TYPE,
--       pcv_information6               pqp_configuration_values.pcv_information6%TYPE,
--       pcv_information7               pqp_configuration_values.pcv_information7%TYPE,
--       pcv_information8               pqp_configuration_values.pcv_information8%TYPE,
--       pcv_information9               pqp_configuration_values.pcv_information9%TYPE,
--       pcv_information10              pqp_configuration_values.pcv_information10%TYPE,
--       pcv_information11              pqp_configuration_values.pcv_information11%TYPE,
--       pcv_information12              pqp_configuration_values.pcv_information12%TYPE,
--       pcv_information13              pqp_configuration_values.pcv_information13%TYPE,
--       pcv_information14              pqp_configuration_values.pcv_information14%TYPE,
--       pcv_information15              pqp_configuration_values.pcv_information15%TYPE,
--       pcv_information16              pqp_configuration_values.pcv_information16%TYPE,
--       pcv_information17              pqp_configuration_values.pcv_information17%TYPE,
--       pcv_information18              pqp_configuration_values.pcv_information18%TYPE,
--       pcv_information19              pqp_configuration_values.pcv_information19%TYPE,
--       pcv_information20              pqp_configuration_values.pcv_information20%TYPE
--        );

   TYPE r_element_details IS RECORD(
      element_type_id    NUMBER
     ,element_name       pay_element_types_f.element_name%TYPE
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

   TYPE r_pen_bal_dtls IS RECORD(
      element_type_id      NUMBER
     ,ees_balance_name     pay_balance_types.balance_name%TYPE
     ,ees_bal_type_id      NUMBER
     ,ees_ptd_bal_id       NUMBER
     -- For 115.9
     ,ees_ytd_bal_id       NUMBER
     ,ers_balance_name     pay_balance_types.balance_name%TYPE
     ,ers_bal_type_id      NUMBER
     ,ers_ptd_bal_id       NUMBER
     -- For 115.9
     ,ers_ytd_bal_id       NUMBER
     -- Commenting the below variables as they are not used
    /* ,add_balance_name     pay_balance_types.balance_name%TYPE
     ,add_bal_type_id      NUMBER
     ,add_ptd_bal_id       NUMBER
     ,ayr_balance_name     pay_balance_types.balance_name%TYPE
     ,ayr_bal_type_id      NUMBER
     ,ayr_ptd_bal_id       NUMBER
     ,fwd_balance_name     pay_balance_types.balance_name%TYPE
     ,fwd_bal_type_id      NUMBER
     ,fwd_ptd_bal_id       NUMBER */
     ,ayfwd_balance_name   pay_balance_types.balance_name%TYPE
     ,ayfwd_bal_type_id    NUMBER
     ,ayfwd_ptd_bal_id     NUMBER
     -- For 115.9
     ,ayfwd_ytd_bal_id       NUMBER
     --For  Bug 6082532 (Added Years Family Benefit)
 /*    ,ayfb_balance_name    pay_balance_types.balance_name%TYPE
     ,ayfb_bal_type_id     NUMBER
     ,ayfb_ptd_bal_id      NUMBER */
     --For  Nuvos
     ,nuvos_sa_balance_name    pay_balance_types.balance_name%TYPE
     ,nuvos_sa_bal_type_id     NUMBER
     ,nuvos_sa_ptd_bal_id      NUMBER
     -- For 115.9
     ,nuvos_sa_ytd_bal_id      NUMBER

   );

   TYPE r_ele_bal_dtls IS RECORD(
      balance_name         pay_balance_types.balance_name%TYPE
     ,balance_type_id      NUMBER
     ,defined_balance_id   NUMBER
     ,pen_defined_balance_id   NUMBER
   );

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

   TYPE t_eei_info IS TABLE OF pay_element_type_extra_info%ROWTYPE
      INDEX BY BINARY_INTEGER;

   TYPE t_ele_bal_dtls IS TABLE OF r_ele_bal_dtls
      INDEX BY BINARY_INTEGER;

   TYPE t_pen_bal_dtls IS TABLE OF r_pen_bal_dtls
   INDEX BY BINARY_INTEGER;

   g_tab_pen_sch_map_cv     pqp_utilities.t_config_values;
   g_tab_pen_ele_ids        t_element_details;
   g_tab_prs_dfn_cv         pqp_utilities.t_config_values;
   g_person_dtl             per_all_people_f%ROWTYPE;
   g_assignment_dtl         per_all_assignments_f%ROWTYPE;
   g_tab_eei_info           t_eei_info;
   g_tab_clas_pen_bal_dtls  t_pen_bal_dtls;
   g_tab_clap_pen_bal_dtls  t_pen_bal_dtls;
   g_tab_prem_pen_bal_dtls  t_pen_bal_dtls;
   g_tab_part_pen_bal_dtls  t_pen_bal_dtls;
   g_tab_avc_pen_bal_dtls   t_ele_bal_dtls;
   g_ni_ele_ent_details     r_ele_ent_details;
   g_tab_ni_cont_out_bals   t_varchar2;

   -- For Nuvos
   g_tab_nuvos_pen_bal_dtls  t_pen_bal_dtls;

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

   -- Earnings History Criteria
   FUNCTION chk_earnings_history_criteria(
      p_business_group_id   IN   NUMBER
     ,p_effective_date      IN   DATE
     ,p_assignment_id       IN   NUMBER
   )
      RETURN VARCHAR2;

   -- Earnings History Data
   FUNCTION get_earnings_history_data(
      p_business_group_id   IN   NUMBER
     ,p_effective_date      IN   DATE
     ,p_assignment_id       IN   NUMBER
     ,p_rule_parameter      IN   VARCHAR2
   )
      RETURN VARCHAR2;

   -- Earnings History Post Process
   FUNCTION earnings_history_post_process(p_ext_rslt_id IN NUMBER)
      RETURN VARCHAR2;
END pqp_gb_psi_earnings_history;

/
