--------------------------------------------------------
--  DDL for Package PQP_GB_PSI_BASIC_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_GB_PSI_BASIC_DATA" AUTHID CURRENT_USER AS
--  /* $Header: pqpgbpsibas.pkh 120.0.12010000.4 2009/09/09 05:12:48 jvaradra ship $ */

--
-- Debug Variables.
--
   g_legislation_code   per_business_groups.legislation_code%TYPE   := 'GB';
   g_debug              BOOLEAN                      := hr_utility.debug_enabled;
   g_effective_date     DATE;
   g_extract_type       VARCHAR2(100);

   g_proc_name              VARCHAR2(61):= 'PQP_GB_PSI_BASIC_DATA.';

--
-- Global Varibales
--
  g_business_group_id      NUMBER      := NULL; -- IMPORTANT TO KEEP NULL
  g_assignment_id          NUMBER      := NULL; -- IMPORTANT TO KEEP NULL

  g_person_id              NUMBER      := NULL;
  g_person_dtl             per_all_people_f%rowtype;
  g_assignment_dtl         per_all_assignments_f%rowtype;

  g_bank_detail_report_y_n VARCHAR2(2) := NULL;
  g_bank_details_found     VARCHAR2(1) := NULL;
  g_current_run            VARCHAR2(10):= NULL;
  g_altkey                 VARCHAR2(12):= NULL;

  -- for include_events
  g_pay_proc_evt_tab             ben_ext_person.t_detailed_output_table;

-- globals set by set_shared_globals
  g_paypoint               VARCHAR2(5) := NULL;
  g_cutover_date           DATE;
  g_ext_dfn_id             NUMBER;
--
  g_marital_status_mapping     pqp_utilities.t_config_values;

-- For Bug 8790100
  g_title_change_exists    VARCHAR2(1) := 'N';
  g_honors_change_exists   VARCHAR2(1) := 'N';
  g_location_change_exists VARCHAR2(1) := 'N';
  g_prevsur_change_exists  VARCHAR2(1) := 'N';
  g_midname_change_exists  VARCHAR2(1) := 'N';

  --
  -- For location code to be fetched from location EIT
  --
  CURSOR csr_location_code (p_location_id  NUMBER)
  IS
    select hlei.lei_information2
    from hr_location_extra_info hlei
    where hlei.location_id = p_location_id
      and hlei.information_type = 'PQP_GB_PENSERV_LOCATION_INFO';

  --
  -- For hire date to be fetched from person form
  --
  CURSOR csr_person_hire_date
          (p_business_group_id      NUMBER
          ,p_effective_date         DATE
          ,p_person_id              NUMBER
          ) IS
  select papf.original_date_of_hire
  from per_all_people_f papf
  where papf.person_id = p_person_id
    and papf.business_group_id = p_business_group_id
    and p_effective_date
      between papf.effective_start_date and papf.effective_end_date;


  --
  -- For fetching bank details of an assignment
  --
  CURSOR csr_bank_details
          (p_business_group_id      NUMBER
          ,p_effective_date         DATE
          ,p_assignment_id          NUMBER
          ) IS
  select pea.segment3, pea.segment4, pea.segment6, pea.segment7  --personal.external_account_id
  from PAY_PERSONAL_PAYMENT_METHODS_F pppm,pay_external_accounts pea
  where pppm.external_account_id = pea.external_account_id
    and pppm.business_group_id = p_business_group_id
    and pppm.assignment_id =  p_assignment_id
    and p_effective_date
      between pppm.effective_start_date and pppm.effective_end_date
  Order by pppm.priority; --Added for Bug 8270421

  -- global to hold bank account details
  g_asg_bank_details       csr_bank_details%ROWTYPE;

  --
  -- determine multiple_assignments
  --
  CURSOR csr_mult_assignment_y_n
          (p_business_group_id      NUMBER
          ,p_effective_date         DATE
          ,p_person_id              NUMBER
          )
  IS
  select count(distinct assignment_id)
  from per_all_assignments_f paaf
  where p_effective_date
      between paaf.effective_start_date and paaf.effective_end_date
    and assignment_type <> 'A' --Added for bug 7693193
    and person_id in
        (select person_id
         from per_all_people_f
         where national_identifier = (
              select national_identifier
              from per_people_f
              where person_id = p_person_id and rownum = 1));


  --
  -- determine spouse_dob
  --
  CURSOR csr_spouse_dob
          (p_business_group_id      NUMBER
          ,p_effective_date         DATE
          ,p_person_id              NUMBER
          )
  IS
  select papf.date_of_birth
  from PER_CONTACT_RELATIONSHIPS pcr, per_all_people_f papf
  where pcr.person_id = p_person_id
    and pcr.contact_person_id = papf.person_id
    and papf.business_group_id = p_business_group_id
    and pcr.business_group_id = p_business_group_id
    and pcr.contact_type = 'S'
    and p_effective_date
            between pcr.date_start and NVL(pcr.date_end,to_date('31/12/4712','DD/MM/YYYY'));


-- ----------------------------------------------------------------------------
-- |------------------------< Function Definitions >---------------------------|
-- ----------------------------------------------------------------------------

  --
  -- basic extract main function
  --
  FUNCTION basic_extract_main
            (p_business_group_id        IN         NUMBER   -- context
            ,p_effective_date           IN         DATE     -- context
            ,p_assignment_id            IN         NUMBER   -- context
            ,p_rule_parameter           IN         VARCHAR2 -- parameter
            ,p_output                   OUT NOCOPY VARCHAR2
            )
  RETURN number;


  FUNCTION chk_basic_data_cutover_crit
          (p_business_group_id        IN      NUMBER
          ,p_effective_date           IN      DATE
          ,p_assignment_id            IN      NUMBER
          )RETURN VARCHAR2;

  FUNCTION chk_basic_data_periodic_crit
          (p_business_group_id        IN      NUMBER
          ,p_effective_date           IN      DATE
          ,p_assignment_id            IN      NUMBER
          )RETURN VARCHAR2;

   -- Debug
   PROCEDURE DEBUG (
      p_trace_message    IN   VARCHAR2
     ,p_trace_location   IN   NUMBER DEFAULT NULL
   );

   -- Debug_Enter
   PROCEDURE debug_enter (
      p_proc_name   IN   VARCHAR2
     ,p_trace_on    IN   VARCHAR2 DEFAULT NULL
   );

   -- Debug_Exit
   PROCEDURE debug_exit (
      p_proc_name   IN   VARCHAR2
     ,p_trace_off   IN   VARCHAR2 DEFAULT NULL
   );

   -- Debug Others
   PROCEDURE debug_others (
      p_proc_name   IN   VARCHAR2
     ,p_proc_step   IN   NUMBER DEFAULT NULL
   );

  FUNCTION basic_data_post_processing RETURN VARCHAR2;


END PQP_GB_PSI_BASIC_DATA;

/
