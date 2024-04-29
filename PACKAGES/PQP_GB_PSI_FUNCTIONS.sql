--------------------------------------------------------
--  DDL for Package PQP_GB_PSI_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_GB_PSI_FUNCTIONS" AUTHID CURRENT_USER AS
--  /* $Header: pqpgbpsifunc.pkh 120.12.12010000.10 2009/12/07 12:07:59 jvaradra ship $ */

--
-- Debug Variables.
--
   g_legislation_code   per_business_groups.legislation_code%TYPE   := 'GB';
   g_debug              BOOLEAN                      := hr_utility.debug_enabled;
   g_effective_date     DATE;

   g_proc_name          VARCHAR2(61):= 'PQP_GB_PSI_FUNCTIONS.';
   g_nested_level       NUMBER:= pqp_utilities.g_nested_level;
   g_count              NUMBER := 0;

--
-- Global Varibales
--

  hr_application_error          EXCEPTION;
  PRAGMA EXCEPTION_INIT(hr_application_error, -20001);


  g_debug_timestamps            BOOLEAN := FALSE;
  g_debug_entry_exits_only      BOOLEAN := FALSE;


  g_business_group_id      NUMBER      := NULL; -- IMPORTANT TO KEEP NULL
  g_business_group_id_backup NUMBER      := NULL; -- IMPORTANT TO KEEP NULL
  g_person_id              NUMBER      := NULL;
  g_paypoint               VARCHAR2(5) := NULL;
  g_current_run            VARCHAR2(10):= NULL;
  g_cutover_date           DATE;
  g_altkey                 VARCHAR2(12):= NULL;
  g_assignment_id          NUMBER      := NULL;
  g_assignment_number      VARCHAR2(30):= NULL;
  g_debug_flag             VARCHAR2(1);
  g_debug_enable_mode      VARCHAR2(10) := NULL;
  g_extract_type           VARCHAR2(10) := NULL;
  g_dfn_name               VARCHAR2(10) := NULL;
  g_output_name            VARCHAR2(110) := NULL;
  g_sequence_number        VARCHAR2(4);
  g_prev_event_dtl_rec           ben_ext_person.t_detailed_output_tab_rec;


  g_prev_assignment_id     NUMBER      := NULL;
  g_prev_effective_date    DATE;
  g_prev_inclusion_flag    VARCHAR2(1) := 'Y';
  g_person_dtl             per_all_people_f%ROWTYPE;
  g_assignment_dtl         per_all_assignments_f%ROWTYPE;

  -- 115.44.11511.1
  -- For Penserver Performance
  -- SE code benxthrd.pkb will use this variables to build the dynamic sql

  g_caller               VARCHAR2(10);
  g_last_app_date        DATE;

  --115.48: Bug 7291713
  /*
  --115.47
  g_bas_eff_date       VARCHAR2(30);
  */

  -- added by kkarri
  -- this contains the value of the pension scheme entered in the
  -- assignment flexfield. this value is set in basic criteria
  -- after calling check_employee_eligibility
  g_pension_scheme        VARCHAR2(80);

  g_asg_membership_col     VARCHAR2(20);
  g_asg_membership_context VARCHAR2(80);
  ------------------------------------------
  -- Added for reprocess logic
  TYPE t_date IS TABLE OF DATE
  INDEX BY BINARY_INTEGER;
  g_min_effective_date   t_date;
  g_min_eff_date_exists  VARCHAR2(10);
  g_effective_start_date DATE;
  g_effective_end_date   DATE;

  g_salary_ended_today      VARCHAR2(1) := 'N';
  g_allowance_has_end_dated VARCHAR2(1);
  g_is_terminated           VARCHAR2(1) := 'N';
  g_curr_element_type_id    NUMBER;
  g_curr_element_entry_id   NUMBER;

  -- Concurrent program
  g_wait_interval         NUMBER := 60; -- seconds
  g_max_wait              NUMBER := 0; -- Meaning no time out
  g_reference_extract     VARCHAR2(30);


-- =============================================================================
-- Used to maintain the penser extract defination names
-- =============================================================================
TYPE r_ext_dfn_names IS RECORD
                (extract_name      VARCHAR2(160)
                ,extract_code      VARCHAR2(10)
                );

TYPE t_ext_dfn_names is Table OF r_ext_dfn_names
                   INDEX BY BINARY_INTEGER;

g_code_ext_names      t_ext_dfn_names;
g_cutover_ext_names   t_ext_dfn_names;
g_periodic_ext_names  t_ext_dfn_names;


-- =============================================================================
-- Used to maintain the penser extract process details
-- =============================================================================

TYPE r_ext_dtls IS RECORD
                (extract_name      VARCHAR2(160)
                ,extract_code      VARCHAR2(10)
                ,short_name        VARCHAR2(80)
                ,request_id        VARCHAR2(10)
                ,extract_rslt_id   NUMBER
                );

TYPE t_ext_dtls is Table OF r_ext_dtls
                   INDEX BY BINARY_INTEGER;

g_ext_dtls      t_ext_dtls;



    TYPE r_error_dtl IS RECORD
          (
          extract_type        VARCHAR2(30)
         ,error_number        NUMBER
         ,error_text          VARCHAR2(32000)
         ,token1              VARCHAR2(32000)
         ,token2              VARCHAR2(32000)
         ,token3              VARCHAR2(32000)
         ,token4              VARCHAR2(32000)
         ,assignment_id       NUMBER
         ,ext_rslt_id         NUMBER
         );

      TYPE t_error_collection IS TABLE OF r_error_dtl
      INDEX BY BINARY_INTEGER;

    g_errors   t_error_collection;
    g_warnings t_error_collection;

    TYPE t_varchar2 IS TABLE OF VARCHAR2(100)
    INDEX BY BINARY_INTEGER;

    g_employer_code t_varchar2;

---------------

-- moved to pqp_utilities
/*
    TYPE r_config_values IS RECORD (
          configuration_value_id        NUMBER,
          pcv_information1              pqp_configuration_values.pcv_information1%TYPE,
          pcv_information2              pqp_configuration_values.pcv_information2%TYPE,
          pcv_information3              pqp_configuration_values.pcv_information3%TYPE,
          pcv_information4              pqp_configuration_values.pcv_information4%TYPE,
          pcv_information5              pqp_configuration_values.pcv_information5%TYPE,
          pcv_information6              pqp_configuration_values.pcv_information6%TYPE,
          pcv_information7              pqp_configuration_values.pcv_information7%TYPE,
          pcv_information8              pqp_configuration_values.pcv_information8%TYPE,
          pcv_information9              pqp_configuration_values.pcv_information9%TYPE,
          pcv_information10             pqp_configuration_values.pcv_information10%TYPE,
          pcv_information11             pqp_configuration_values.pcv_information11%TYPE,
          pcv_information12             pqp_configuration_values.pcv_information12%TYPE,
          pcv_information13             pqp_configuration_values.pcv_information13%TYPE,
          pcv_information14             pqp_configuration_values.pcv_information14%TYPE,
          pcv_information15             pqp_configuration_values.pcv_information15%TYPE,
          pcv_information16             pqp_configuration_values.pcv_information16%TYPE,
          pcv_information17             pqp_configuration_values.pcv_information17%TYPE,
          pcv_information18             pqp_configuration_values.pcv_information18%TYPE,
          pcv_information19             pqp_configuration_values.pcv_information19%TYPE,
          pcv_information20             pqp_configuration_values.pcv_information20%TYPE
          );

      TYPE t_config_values IS TABLE OF r_config_values
      INDEX BY BINARY_INTEGER;


    g_assign_category_mapping          t_config_values;
*/

  g_assign_category_mapping         pqp_utilities.t_config_values;
  g_pension_scheme_mapping          pqp_utilities.t_config_values;


  ---------------added by kkarri----------------
    c_highest_date                 CONSTANT DATE := hr_api.g_eot;

    --g_penserver_contract_type      VARCHAR2(1);
    --g_contract_type_effective_date DATE;
    --g_contract_type                VARCHAR2(30);

    g_pay_proc_evt_tab             ben_ext_person.t_detailed_output_table;

    g_salary_ele_end_date          DATE := hr_api.g_eot;
            -- this is used to makr that current event date has a salary element end event
    g_non_salary_ele_end_date      DATE := hr_api.g_eot;
            -- this is used to mark that there is no salary element end event on current event date

    g_sal_chg_event_exists         VARCHAR2(1);
            -- this is used to mark that there is a salary change event on current date.

    g_salary_started               VARCHAR2(1);
            -- this is mark that the salary has started and further events will be processed
    g_salary_ended                 VARCHAR2(1);
            -- this is mark that the salary has ended and no further event wud be processed
    g_salary_start_date            DATE; --

    g_salary_end_date              DATE;--

    TYPE t_varchar30 IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
    g_dated_tables        t_varchar30;

    CURSOR csr_assignment_status
              (
              p_assignment_status_type_id NUMBER
              )
    IS
         SELECT DECODE(pay_system_status,'D','DO NOT PROCESS','P','PROCESS')
                ,per_system_status
         FROM per_assignment_status_types
         WHERE ASSIGNMENT_STATUS_TYPE_ID = p_assignment_status_type_id
         AND  primary_flag = 'P';

    -- cursor to check if the change is on FTE
    CURSOR csr_is_fte_abv
            (
            p_assignment_budget_value_id  NUMBER
            )
    IS
        SELECT 'Y'
        FROM PER_ASSIGNMENT_BUDGET_VALUES_F
        WHERE assignment_budget_value_id = p_assignment_budget_value_id
        AND UNIT = 'FTE'
        AND ROWNUM = 1 ;

  --Bug 7611963: Cusor to fetch element end date.
    Cursor csr_get_ele_end_date(p_element_entry_id IN NUMBER)
    Is
       Select max(effective_end_date)
       From pay_element_entries_f
       Where element_entry_id = p_element_entry_id;

    g_retro_event_date_reported BOOLEAN :=  TRUE;

    -- ----------------------------------------------------------------------------
    -- |------------------------< init_st_end_date_glob --------------------------|
    -- ----------------------------------------------------------------------------
    PROCEDURE init_st_end_date_glob;

    -- ----------------------------------------------------------------------------
    -- |---------------------< get_start_end_date >------------------------|
    -- ----------------------------------------------------------------------------
    FUNCTION get_start_end_date
                (
                p_assignment_id         NUMBER
                ,p_business_group_id    NUMBER
                ,p_effective_date       DATE
                ,p_start_date           OUT NOCOPY DATE
                ,p_end_date             OUT NOCOPY DATE
                )RETURN NUMBER;

    -- ----------------------------------------------------------------------------
    -- |-------------------------< get_contract_type >-----------------------------|
    -- ----------------------------------------------------------------------------
    FUNCTION get_contract_type
                (
                p_assignment_id          NUMBER
                ,p_business_group_id     NUMBER
                ,p_effective_date        IN DATE
                ,p_contract_type         OUT NOCOPY VARCHAR2
                ) RETURN NUMBER;

    ------------------------------------------------------------------------------
    --|-------------------------< get_notional_pay >-----------------------|
    -- ----------------------------------------------------------------------------
    FUNCTION get_notional_pay
                (
                p_assignment_id       IN NUMBER
                ,p_business_group_id  IN NUMBER
                ,p_effective_date   IN DATE
                ,p_name             IN VARCHAR2
                ,p_rt_element       IN VARCHAR2
                ,p_rate             IN OUT NOCOPY NUMBER
                ,p_custom_function  IN VARCHAR2  DEFAULT NULL
                ,p_allowance_code   IN VARCHAR2  DEFAULT NULL
                ,p_allowance_pet_id IN NUMBER  DEFAULT NULL
                ) RETURN NUMBER;

    -- ----------------------------------------------------------------------------
    -- |------------------------< get_actual_pay >--------------------------|
    -- ----------------------------------------------------------------------------
    FUNCTION get_actual_pay
                (
                p_assignment_id   IN NUMBER
                ,p_notional_pay   IN NUMBER
                ,p_effective_date IN DATE
                ,p_output         OUT NOCOPY VARCHAR2
                )RETURN NUMBER;

  ------------------------------------------------
  --
  -- For fetching person details for person_id
  --
      CURSOR csr_get_person_dtl
         ( p_business_group_id      NUMBER
          ,p_effective_date         DATE
          ,p_person_id              NUMBER
          ) IS
      select *
  from per_all_people_f papf
  where papf.business_group_id = p_business_group_id
    and papf.person_id = p_person_id
    and p_effective_date
        between papf.effective_start_date
            and papf.effective_end_date;


  --
  -- For fetching assignment details
  --

-- old
/*
CURSOR csr_get_assignment_dtl
         ( p_business_group_id      NUMBER
          ,p_effective_date         DATE
          ,p_assignment_id          NUMBER
          ) IS
      select *
  from per_all_assignments_f paaf
  where paaf.business_group_id = p_business_group_id
    and paaf.assignment_id = p_assignment_id
    and paaf.assignment_type = 'E'
    and paaf.employment_category IS NOT NULL
    and p_effective_date
        between paaf.effective_start_date
            and paaf.effective_end_date;
*/

-- new
-- 1) for periodic : till final_process_date
  CURSOR csr_get_assignment_dtl_per
         ( p_business_group_id      NUMBER
          ,p_effective_date         DATE
          ,p_assignment_id          NUMBER
          ) IS
      select paaf.*
  from per_all_assignments_f paaf --, per_periods_of_service PPS
  where paaf.business_group_id = p_business_group_id
    and paaf.assignment_id = p_assignment_id
    and paaf.assignment_type = 'E'
--    and pps.person_id = paaf.person_id
--    and pps.business_group_id = p_business_group_id
    and paaf.employment_category IS NOT NULL
    and p_effective_date
        between paaf.effective_start_date
            and paaf.effective_end_date;
  --  and p_effective_date
    --    between pps.date_start
      --      and NVL(pps.final_process_date,to_date('31/12/4712','DD/MM/YYYY'));


-- 2) for cutover : till actual_termination_date
  CURSOR csr_get_assignment_dtl_cut
         ( p_business_group_id      NUMBER
          ,p_effective_date         DATE
          ,p_assignment_id          NUMBER
          ) IS
      select paaf.*
  from per_all_assignments_f paaf, per_periods_of_service PPS
  where paaf.business_group_id = p_business_group_id
    and paaf.assignment_id = p_assignment_id
    and paaf.assignment_type = 'E'
    and pps.person_id = paaf.person_id
    and pps.business_group_id = p_business_group_id
    and paaf.employment_category IS NOT NULL
    and p_effective_date
        between paaf.effective_start_date
            and paaf.effective_end_date
    and p_effective_date
        between pps.date_start
            and NVL(pps.actual_termination_date,to_date('31/12/4712','DD/MM/YYYY'));



  --
  -- Indicator whether element_type_id of a pension scheme
  -- is present for this assignment or not.
  -- Being used for checking if person is in a particular scheme
  --
  CURSOR csr_partnership_scheme_flag
         (p_business_group_id       NUMBER
         ,p_effective_date          DATE
         ,p_assignment_id           NUMBER
         ,p_element_type_id         NUMBER
         )
  IS
  select 'Y' from dual
  where
  (select pee.element_type_id
   from pay_element_entries_f pee ,pay_element_links_f pel
   where pee.element_link_id = pel.element_link_id
     and pel.business_group_id = p_business_group_id
     and pee.assignment_id = p_assignment_id
     and pee.element_type_id = p_element_type_id
     and p_effective_date between
         pee.effective_start_date and pee.effective_end_date
     and rownum = 1
     ) IS NOT NULL;

/*
  --
  -- fetch penserver assignment category code
  --
  CURSOR csr_assignment_category
          (p_business_group_id      NUMBER
          ,p_effective_date         DATE
          ,p_assignment_id              NUMBER
          )
  IS
  select pcv.pcv_information2
  from per_all_assignments_f paaf, PQP_CONFIGURATION_VALUES pcv
  where     paaf.assignment_id = p_assignment_id
    and pcv.pcv_information1 = paaf.employment_category
    and paaf.business_group_id = p_business_group_id
    and pcv_information_category = 'PQP_GB_PENSERVER_EMPLYMT_TYPE'
    and p_effective_date
        between paaf.effective_start_date
                                and paaf.effective_end_date;
*/


  --
  -- penserver last_hire_date indicator
  -- returns a 'Y' if the person has been employed
  -- more than 3 months ago from the current date
  CURSOR csr_last_hire_date_indicator
          (p_business_group_id      NUMBER
          ,p_effective_date         DATE
          ,p_person_id              NUMBER
          )
  IS

  select 'Y'
  from dual
  where
    (select PPS.DATE_START -- DECODE(PER.CURRENT_EMPLOYEE_FLAG,'Y',PPS.DATE_START,NULL)
     from per_all_people_f PER, per_periods_of_service PPS
     where per.person_id = p_person_id
       and pps.person_id = p_person_id
       and p_effective_date
         between per.effective_start_date
                 and NVL(per.effective_end_date,to_date('31/12/4712','DD/MM/YYYY'))
       and p_effective_date
         between pps.date_start
                 and NVL(pps.final_process_date,to_date('31/12/4712','DD/MM/YYYY'))
     )
       <=
     (
     select add_months(p_effective_date,-3) from dual
     );

FUNCTION check_debug
       (p_business_group_id IN     VARCHAR2 -- context
    )
   RETURN boolean;

-------------debug
  PROCEDURE DEBUG(
    p_trace_message             IN       VARCHAR2
   ,p_trace_location            IN       NUMBER DEFAULT NULL
  );

-------------debug_enter
  PROCEDURE debug_enter(
    p_proc_name                 IN       VARCHAR2 DEFAULT NULL
   ,p_trace_on                  IN       VARCHAR2 DEFAULT NULL
  );

-------------debug_exit
  PROCEDURE debug_exit(
    p_proc_name                 IN       VARCHAR2 DEFAULT NULL
   ,p_trace_off                 IN       VARCHAR2 DEFAULT NULL
  );

  PROCEDURE debug_others(
    p_proc_name                 IN       VARCHAR2
   ,p_proc_step                 IN       NUMBER DEFAULT NULL
  );


-- ----------------------------------------------------------------------------
-- |------------------------< check_employee_eligibility >-------------------|
-- ----------------------------------------------------------------------------
FUNCTION check_employee_eligibility
              (p_business_group_id       IN NUMBER
              ,p_assignment_id           IN NUMBER
              ,p_effective_date          IN DATE
              ,p_chg_value               OUT NOCOPY VARCHAR2 -- the scheme name entered.
              )  RETURN VARCHAR2; -- Y or N

  FUNCTION chk_penserver_basic_criteria
    (p_business_group_id        IN      NUMBER
    ,p_effective_date           IN      DATE
    ,p_assignment_id            IN      NUMBER
    ,p_person_dtl               OUT NOCOPY per_all_people_f%rowtype
    ,p_assignment_dtl           OUT NOCOPY per_all_assignments_f%rowtype
    ) RETURN VARCHAR2;

/*
  PROCEDURE get_config_type_values
    (
     p_configuration_type   IN              VARCHAR2
    ,p_business_group_id    IN              NUMBER
    ,p_legislation_code     IN              VARCHAR2
    ,p_tab_config_values    OUT NOCOPY      t_config_values
    );
*/

  PROCEDURE set_shared_globals
    (p_business_group_id        IN      NUMBER
    ,p_paypoint                 OUT NOCOPY VARCHAR2
    ,p_cutover_date             OUT NOCOPY VARCHAR2
    ,p_ext_dfn_id               OUT NOCOPY NUMBER
    );


--
-- function to store error/warnings into collection
--
  PROCEDURE store_extract_exceptions
           (p_extract_type        IN VARCHAR2 -- global/interface name
           ,p_error_number        IN NUMBER
           ,p_error_text          IN VARCHAR2
           ,p_token1              IN VARCHAR2 DEFAULT NULL
           ,p_token2              IN VARCHAR2 DEFAULT NULL
           ,p_token3              IN VARCHAR2 DEFAULT NULL
           ,p_token4              IN VARCHAR2 DEFAULT NULL
           ,p_error_warning_flag  IN VARCHAR2 -- E (error) / W(warning)
           );

--
-- function to raise error/warnings that are stored in collection
--

  PROCEDURE raise_extract_exceptions
           (p_extract_type        IN VARCHAR2 DEFAULT 'DE'
           );

--
-- function to return altkey of a person assignment
--

  FUNCTION altkey
    --(p_assignment_number IN     VARCHAR2 -- context
    --,p_paypoint          IN     VARCHAR2 -- context
    --)
    RETURN VARCHAR2;

--
-- function to return paypoint of a person assignment
--
  FUNCTION paypoint
    (p_business_group_id IN     VARCHAR2 -- context
    )
    RETURN VARCHAR2;

--
-- function to return employer_code of a person assignment
--
  FUNCTION employer_code
      (p_business_group_id       NUMBER
      ,p_effective_date          DATE
      ,p_assignment_id           NUMBER
      ) RETURN VARCHAR2;

-- =============================================================================
-- ~ PQP_Penserver_Extract: This is called by the conc. program
-- ~ to run Penserver extracts and is basically a
-- ~ wrapper around the benefits conc. program Extract Process.
-- This function will launch new concurrent requests for each extract submission
-- =============================================================================

PROCEDURE PQP_Penserver_Extract
           (errbuf                        OUT NOCOPY  VARCHAR2
           ,retcode                       OUT NOCOPY  VARCHAR2
           ,p_benefit_action_id           IN     NUMBER
           ,p_business_group_id           IN     NUMBER
               ,p_execution_mode              IN     VARCHAR2 -- GEN/DBG/SET
           ,p_execution_mode_type         IN     VARCHAR2
           ,p_extract_type                IN     VARCHAR2 -- CUT/PED/CODE
           ,p_dfn_name                    IN     VARCHAR2 -- ALL/BDI/ADI/SDI/EDI/ACI/BCI/GCI/LCI
           ,p_start_date                  IN     VARCHAR2
           ,p_eff_date                    IN     VARCHAR2
           ,p_submit_request_y_n          IN     VARCHAR2 default 'N'
           ,p_concurrent_request_id       IN     NUMBER DEFAULT NULL
           ,p_year_end_close              IN     VARCHAR2 default 'N'  -- /* Nuvos Changes */
           ,p_short_time_hours_single     IN     VARCHAR2 default 'INCLUDE'  -- For Bug 7010282
           );



-- =============================================================================
-- This procedure gets control totals information
-- =============================================================================
PROCEDURE Get_Penserver_CntrlTtl_Process
           (errbuf                OUT NOCOPY  VARCHAR2
           ,retcode               OUT NOCOPY  VARCHAR2
           ,p_extract_type        IN     VARCHAR2 DEFAULT NULL
           ,p_parent_request_id       IN     NUMBER DEFAULT NULL
           ,p_parent_selected     IN     VARCHAR2 DEFAULT NULL
               ,p_ext_bdi_rslt_id     IN     NUMBER DEFAULT NULL
           ,p_ext_adi_rslt_id     IN     NUMBER DEFAULT NULL
               ,p_ext_sehi_rslt_id    IN     NUMBER DEFAULT NULL
           ,p_ext_sahi_rslt_id    IN     NUMBER DEFAULT NULL
           ,p_ext_ehi_rslt_id     IN     NUMBER DEFAULT NULL
           ,p_ext_ahi_rslt_id     IN     NUMBER DEFAULT NULL
               ,p_ext_bhi_rslt_id     IN     NUMBER DEFAULT NULL
           ,p_ext_wps_rslt_id     IN     NUMBER DEFAULT NULL
           ,p_ext_pthi_rslt_id    IN     NUMBER DEFAULT NULL
           ,p_ext_sthi_rslt_id    IN     NUMBER DEFAULT NULL
           ,p_ext_sthai_rslt_id   IN     NUMBER DEFAULT NULL
           ,p_business_group_id   IN     NUMBER
           ,p_year_end_close      IN     VARCHAR2 default 'N'  -- /* Nuvos Changes */
           );

-- =============================================================================
-- Record : rec_cntrl_tot
-- to get total controls information
-- =============================================================================
TYPE rec_cntrl_tot IS RECORD
  ( pay_point                        VARCHAR2(6)
   ,file_extract_date                VARCHAR2(16)
   ,seq_num                          VARCHAR2(3)
   ,basic_cnt                        VARCHAR2(10)
   ,serv_hist_cnt                    VARCHAR2(10)
   ,earn_hist_cnt                    VARCHAR2(10)
   ,earn_hist_tot_WPS                VARCHAR2(16)
   ,sal_hist_cnt                     VARCHAR2(10)
   ,sal_hist_tot_national_pay        VARCHAR2(16)
   ,allw_hist_rec_cnt                VARCHAR2(10)
   ,allw_hist_tot_allw_rate          VARCHAR2(16)
   ,bonus_hist_rec_cnt               VARCHAR2(10)
   ,bonus_hist_tot_bonus_amt         VARCHAR2(16)
   ,WPS_contrbt_hist_rec_cnt         VARCHAR2(10)
   ,WPS_contrbt_hist_tot_perc        VARCHAR2(16)
   ,AVC_hist_rec_cnt                 VARCHAR2(10)
   ,EECONT_tot                       VARCHAR2(16)
   ,other_benef_rec_cnt              VARCHAR2(10)
   ,PUP_tot                          VARCHAR2(16)
   ,prt_tm_hr_hist_rec_cnt           VARCHAR2(10)
   ,prt_tm_hr_hist_tot_pthrs     VARCHAR2(16)
   ,srt_tm_hr_hist_sing_rec_cnt      VARCHAR2(10)
   ,srt_tm_hr_hist_sing_tot_hr_var   VARCHAR2(16)
   ,srt_tm_hr_hist_accu_rec_cnt      VARCHAR2(10)
   ,srt_tm_hr_hist_accu_tot_hr_var   VARCHAR2(16)
   ,event_det_tot_rec                VARCHAR2(10)
   ,event_det_tot_amt                VARCHAR2(16)
   ,remarks_interface_tot_rec        VARCHAR2(10)
   ,addr_data_tot_rec                VARCHAR2(10)
   ,benef_det_tot_rec                VARCHAR2(10)
   ,pay_hist_cnt                     VARCHAR2(10)    -- For Nuvos changes
   ,pay_hist_tot_EARN                VARCHAR2(16)
   ,pay_hist_tot_DEDS                VARCHAR2(16)
   ,year_end_close                   VARCHAR2(4)
   ,pay_per_end_date                 VARCHAR2(10)
   );
TYPE t_cntrl_tot IS TABLE OF rec_cntrl_tot
      INDEX BY BINARY_INTEGER;

-- =============================================================================
-- Record : rec_allowance_codes
-- to get allowance code information
-- =============================================================================
TYPE rec_allowance_codes IS RECORD
  ( pay_point              VARCHAR2(6)
   ,allowance_code         VARCHAR2(20)
   ,allowance_descr        VARCHAR2(60)
   ,pension_flag           VARCHAR2(1)
   ,industrial_flag        VARCHAR2(1)
   ,spread_bonus_flag      VARCHAR2(1)
   ,filler1                VARCHAR2(16)
   ,basic_pay_reckonable   VARCHAR2(1)
   ,pre_75_reckonable      VARCHAR2(1)
   ,filler2                VARCHAR2(79)
   );
TYPE t_allowance_codes IS TABLE OF rec_allowance_codes
      INDEX BY BINARY_INTEGER;

-- =============================================================================
-- Record : rec_bonus_codes
-- to get bonus code information
-- =============================================================================
TYPE rec_bonus_codes IS RECORD
  ( pay_point              VARCHAR2(6)
   ,bonus_code             VARCHAR2(20)
   ,bonus_descr            VARCHAR2(60)
   ,pension_flag           VARCHAR2(1)
   ,industrial_flag        VARCHAR2(1)
   ,filler1                VARCHAR2(16)
   ,basic_pay_reckonable   VARCHAR2(1)
   ,pre_75_reckonable      VARCHAR2(1)
   ,filler2                VARCHAR2(86)
   );
TYPE t_bonus_codes IS TABLE OF rec_bonus_codes
      INDEX BY BINARY_INTEGER;

-- =============================================================================
-- Cursor - csr_get_extra_allow_information
-- Information type is passed as parameter
-- =============================================================================
   CURSOR csr_get_extra_allow_info
          (p_from_date         IN DATE
          ,p_to_date           IN DATE) IS
   SELECT element_name,
          eei_information2 code,
          eei_information3 description,
          eei_information4 pension_flag,
          eei_information5 industrial_flag,
          eei_information6 spread_bonus_flag,
          eei_information7 basic_pay_reckonable,
          eei_information8 pre_75_reckonable
     FROM pay_element_type_extra_info petei,
          pay_element_types_f petf
    WHERE information_type = 'PQP_GB_PENSERV_ALLOWANCE_INFO'
    AND   petei.element_type_id = petf.element_type_id
    AND   petei.eei_information2 IS NOT NULL
    AND   ((p_from_date BETWEEN petf.effective_start_date AND petf.effective_end_date)
           OR
          (p_to_date BETWEEN petf.effective_start_date AND petf.effective_end_date));


-- =============================================================================
-- Cursor - csr_get_extra_bonus_information
-- Information type is passed as parameter
-- =============================================================================
   CURSOR csr_get_extra_bonus_info
          ( p_from_date         IN DATE
               ,p_to_date           IN DATE) IS
   SELECT element_name,
          eei_information2 code,
          eei_information3 description,
          eei_information4 pension_flag,
          eei_information5 industrial_flag,
          eei_information6 basic_pay_reckonable,
          eei_information7 pre_75_reckonable
     FROM pay_element_type_extra_info petei,
          pay_element_types_f petf
    WHERE information_type = 'PQP_GB_PENSERV_BONUS_INFO'
    AND   petei.element_type_id = petf.element_type_id
    AND   petei.eei_information2 IS NOT NULL
    AND   ((p_from_date BETWEEN petf.effective_start_date AND petf.effective_end_date)
           OR
          (p_to_date BETWEEN petf.effective_start_date AND petf.effective_end_date));


-- =============================================================================
-- Cursor - csr_debug_enable_mode
-- =============================================================================
   CURSOR csr_debug_enable_mode IS
   SELECT * -- argument3
   FROM fnd_concurrent_requests
   WHERE request_id =
     (SELECT req.parent_request_id
      FROM fnd_concurrent_requests req, fnd_concurrent_programs con
      WHERE request_id = fnd_global.conc_request_id
      AND con.concurrent_program_id = req.concurrent_program_id);


-- =============================================================================
-- Cursor - csr_debug_enable_mode_parent
-- =============================================================================
   CURSOR csr_debug_enable_mode_parent IS
   SELECT * -- req.parent_request_id
   FROM fnd_concurrent_requests req
   WHERE request_id = fnd_global.conc_request_id;


-- =============================================================================
-- Cursor - csr_get_elements_of_info_type
-- Information type is passed as parameter
-- Input Value is mandatory
-- =============================================================================
      CURSOR csr_get_elements_of_info_type
          (c_information_type IN VARCHAR2
          ,c_input_value      IN VARCHAR2 DEFAULT 'PAY VALUE'
           ) IS
      SELECT distinct(petei.element_type_id)
         ,pet.element_name
         ,pet.processing_type
         ,piv.input_value_id
         ,petei.eei_information1
         ,petei.eei_information2
         ,petei.eei_information3
         ,petei.eei_information4
         ,petei.eei_information5
         ,petei.eei_information6
         ,petei.eei_information7
         ,petei.eei_information8
         ,petei.eei_information9
         ,petei.eei_information10
         ,pet.retro_summ_ele_id -- retro element type ID -- 115.33 (1)
      FROM pay_element_type_extra_info petei
      ,pay_element_types_f pet
      ,pay_input_values_f piv
      ,pay_input_values_f piv2
      WHERE petei.information_type = c_information_type
      AND pet.element_type_id = petei.element_type_id
      AND piv.element_type_id = pet.element_type_id
      AND piv2.element_type_id = pet.element_type_id
      AND UPPER(piv2.NAME) = UPPER(c_input_value)
      AND UPPER(piv.NAME) = 'PAY VALUE' ;


-- =============================================================================
-- Cursor - csr_get_elements_of_info_type
-- Information type is passed as parameter
-- no restriction on Input value
-- =============================================================================
     CURSOR csr_ele_info_type_no_inp_val
          (c_information_type IN VARCHAR2
           ) IS
     SELECT distinct(petei.element_type_id)
         ,pet.element_name
         ,pet.processing_type
         ,pet.element_type_id ele_type_id
         ,petei.eei_information1
         ,petei.eei_information2
         ,petei.eei_information3
         ,petei.eei_information4
         ,petei.eei_information5
         ,petei.eei_information6
         ,petei.eei_information7
         ,petei.eei_information8
         ,petei.eei_information9
         ,petei.eei_information10
         ,pet.retro_summ_ele_id -- retro element type ID -- 115.33 (1)
      FROM pay_element_type_extra_info petei
      ,pay_element_types_f pet
      WHERE petei.information_type = c_information_type
      AND pet.element_type_id = petei.element_type_id;


-- =============================================================================
-- Cursor - csr_get_elements_of_info_type
-- Information type is passed as parameter
-- =============================================================================
   CURSOR csr_get_element_type_id(c_element_entry_id IN NUMBER) IS
   SELECT element_type_id
     FROM pay_element_entries_f
     WHERE element_entry_id = c_element_entry_id
     AND rownum=1;


-- =============================================================================
-- Used to maintain element information
-- =============================================================================

   TYPE t_elements_of_info_type is Table OF csr_get_elements_of_info_type%rowtype
                                INDEX BY BINARY_INTEGER;

   g_elements_of_info_type      t_elements_of_info_type;


-- =============================================================================
-- Used to maintain element_entry_id and element_type_id collection
-- =============================================================================

   TYPE r_elements_processed IS RECORD
                (element_type_id   NUMBER
                ,inclusion_flag    VARCHAR2(1) -- Y/N
                );
   TYPE t_elements_processed is Table OF r_elements_processed
                                INDEX BY BINARY_INTEGER;

   g_elements_processed      t_elements_processed;



  CURSOR csr_get_asg_act_id
       ( p_assignment_id NUMBER
        ,p_date_earned   DATE
       )
  IS
  SELECT /*+ ordered use_nl(PAA PPA)
          index (PAA PAY_ASSIGNMENT_ACTIONS_N1)
          index (PAA PAY_ASSIGNMENT_ACTIONS_N51)
          index (PPA PAY_PAYROLL_ACTIONS_PK)*/
          paa.assignment_action_id -- max(paa.assignment_action_id)
         -- no longer using max, now pick all assignment runs
    FROM pay_assignment_actions paa
        ,pay_payroll_actions    ppa
    WHERE paa.assignment_id        = p_assignment_id
      AND ppa.action_status        = 'C'
      AND paa.action_status        = 'C'
      AND paa.payroll_action_id    = ppa.payroll_action_id
      AND ppa.date_earned          = p_date_earned
      AND ppa.action_type in ('R', 'Q', 'I', 'V', 'B')
      AND paa.source_action_id IS NOT NULL -- pick the assignment_action_id which has run_results
      order by assignment_action_id desc ; -- pick from highest, descending

-- Added as part of 115.33 (2)
  CURSOR csr_get_asg_act_id_retro
  ( p_assignment_id        NUMBER
   ,p_date_earned          DATE
  )IS

  SELECT paa.assignment_action_id -- min(paa.assignment_action_id)
        -- ppa.date_earned
    FROM pay_assignment_actions paa
        ,pay_payroll_actions    ppa
   WHERE paa.assignment_id        = p_assignment_id
     AND ppa.action_status        = 'C'
     AND paa.action_status        = 'C'
     AND paa.payroll_action_id    = ppa.payroll_action_id
     AND ppa.action_type IN ('R', 'Q', 'I', 'V', 'B')
     AND ppa.date_earned          = p_date_earned
     AND paa.source_action_id IS NULL
     ORDER BY assignment_action_id desc ; -- pick from highest, descending
--  ORDER BY assignment_action_id ;


  -- get all assignment_action_id, source_action_id
  CURSOR csr_get_all_asg_act_id
       ( p_assignment_id NUMBER
        ,p_date_earned   DATE
        ,p_element_entry_id NUMBER
       )
  IS
  SELECT paa.assignment_action_id, paa.source_action_id
    FROM pay_assignment_actions paa
        ,pay_payroll_actions    ppa
        ,pay_run_results        prr
    WHERE paa.assignment_id        = p_assignment_id
      AND ppa.action_status        = 'C'
      AND paa.action_status        = 'C'
      AND paa.payroll_action_id    = ppa.payroll_action_id
      AND paa.assignment_action_id = prr.assignment_action_id
      AND prr.element_entry_id     = p_element_entry_id
      AND ppa.date_earned          = p_date_earned
      AND ppa.action_type in ('R', 'Q', 'I', 'V', 'B')
      AND paa.source_action_id IS NOT NULL -- pick the assignment_action_id which has run_results
      order by assignment_action_id desc ; -- pick from highest, descending



  -- get run retult details of element and its indirect elements
  CURSOR csr_run_rslt_indirect_ele
       (p_source_id  NUMBER
       ,p_asg_act_id NUMBER
       )
  IS
  SELECT prr.*
  FROM pay_run_results       prr
  WHERE prr.assignment_action_id = p_asg_act_id
    AND prr.source_id = p_source_id;


  -- fetch elements which are of this source assignment action and element id
  -- basically fetch future retro payments
  -- For Bug 8652303
  -- The retro entries are not picked up if the retro entry has the source id as
  -- the element entry id of the original bonus element.

  CURSOR csr_retro_ele
       (p_assignment_id        NUMBER
       ,p_source_id            NUMBER
       ,p_source_asg_action_id NUMBER
       ,p_effective_date       DATE
       ,p_ele_entry_id         NUMBER
       )
  IS
  SELECT *
--         element_entry_id, effective_start_date, effective_end_date, creator_type,
--        ,entry_type, creator_id, source_id, source_asg_action_id, source_start_date,
--        ,source_end_date, element_type_id
  FROM pay_element_entries_f
  WHERE source_asg_action_id = p_source_asg_action_id
  AND (source_id = p_source_id OR source_id = p_ele_entry_id)
  AND assignment_id = p_assignment_id
  AND effective_end_date <= p_effective_date;


  -- For Bug 9150874
  -- The retro entries are not picked up if the retro entry has the source id as
  -- the element entry id of the original bonus element and the original bonus element
  -- didnot get processed in the Payroll run.

  CURSOR csr_retro_ele_check
         (p_assignment_id        NUMBER
         ,p_effective_end_date   DATE
         ,p_effective_start_date DATE
         ,p_ele_entry_id         NUMBER
         )
      IS
   SELECT * FROM pay_element_entries_f
    WHERE source_id = p_ele_entry_id
      AND assignment_id = p_assignment_id
      AND effective_end_date <= p_effective_end_date
      AND effective_start_date >= p_effective_start_date;


  CURSOR csr_get_next_payroll_date
         (p_assignment_id NUMBER
         ,p_effective_date  DATE
         )
  IS
  SELECT min(ptp.end_date) next_payroll_date
    FROM per_time_periods       ptp
        ,per_all_assignments_f  paaf
    WHERE ptp.payroll_id     = paaf.payroll_id
      AND paaf.assignment_id = p_assignment_id
      AND ptp.end_date      >= p_effective_date ;


  CURSOR csr_get_run_result_value
       (--p_element_type_id NUMBER
        p_element_entry_id NUMBER
       ,p_input_value_id   NUMBER
       ,p_asg_act_id       NUMBER
       )
  IS
  SELECT to_number(prrv.result_value) result,
         prrv.run_result_id -- to be used as ee.source_id for retro elements
    FROM pay_run_result_values prrv
        ,pay_run_results       prr
    WHERE prrv.run_result_id       = prr.run_result_id
      AND prr.assignment_action_id = p_asg_act_id
      -- AND prr.element_type_id      = p_element_type_id
      AND prr.source_id            = p_element_entry_id
      AND prrv.input_value_id      = p_input_value_id ;



  -- Added as part of 115.33 (3)
  -- this cursor will look into future payrolls and fetch the retro payments
  -- which were earned in this month (of whose assignment_action_id is being passed as param)
  CURSOR csr_get_retro_run_value
       (p_assignment_action_id NUMBER
       ,p_effective_date          DATE
       )
  IS
  select  /*+ ORDERED USE_NL(BAL_ASSACT BACT ASSACT PACT EE RR RRV)
INDEX (BAL_ASSACT  PAY_ASSIGNMENT_ACTIONS_PK )
INDEX (BACT PAY_PAYROLL_ACTIONS_PK)
INDEX (ASSACT  PAY_ASSIGNMENT_ACTIONS_N51 )
INDEX (ASSACT  PAY_ASSIGNMENT_ACTIONS_N1 )
INDEX (PACT PAY_PAYROLL_ACTIONS_PK)
INDEX (EE PAY_ELEMENT_ENTRIES_F_N50)
INDEX (RR PAY_RUN_RESULTS_N51)
INDEX (RRV PAY_RUN_RESULT_VALUES_N50)
*/
          RRV.input_value_id,
          RRV.result_value,
          BACT.effective_date,
          EE.element_entry_id,
          EE.element_type_id,
          EE.effective_start_date,
          EE.effective_end_date,
          EE.source_id ee_source_id, -- this is run_result_id of parent element, of which this ele is a retro
          RR.source_id rr_source_id,
          RR.status,
          RR.source_type
          from    pay_assignment_actions          BAL_ASSACT,
          pay_payroll_actions             BACT,
          pay_assignment_actions          ASSACT,
          pay_payroll_actions             PACT,
          pay_element_entries_f           EE,
          pay_run_results                 RR,
          pay_run_result_values           RRV
  where   BAL_ASSACT.assignment_action_id = p_assignment_action_id
  and     BACT.payroll_action_id = BAL_ASSACT.payroll_action_id
  and     BACT.action_type <> 'V'
  and     ASSACT.assignment_id = BAL_ASSACT.assignment_id
  and     ASSACT.action_sequence > BAL_ASSACT.action_sequence
  and     PACT.payroll_action_id = ASSACT.payroll_action_id
  and     PACT.action_type = 'L'
  and     BACT.effective_date
          between nvl(PACT.start_date,
             BACT.effective_date) and PACT.effective_date
  and     EE.assignment_id = ASSACT.assignment_id
  and     PACT.effective_date
          between EE.effective_start_date and EE.effective_end_date
  and     EE.creator_id = ASSACT.assignment_action_id
  and     EE.creator_type in ('RR', 'EE', 'NR', 'PR')
  and         EE.effective_end_date <= p_effective_date -- pick retro payment before run date
  and     EE.source_asg_action_id = BAL_ASSACT.assignment_action_id
  and     RR.source_id = EE.element_entry_id
  and     RR.status in ('P', 'PA')

  and     RR.source_type in ('E', 'I')
  and     RRV.run_result_id = RR.run_result_id
  and     nvl(RRV.result_value, '0') <> '0'
  and     not exists(
                  select  null
                  from    pay_run_results VRR
                  where   VRR.source_id = RR.run_result_id
                  and     VRR.source_type in ('R', 'V'));


  -- added by kkarri
  --    this is added to fetch the UK Rate Types element attribution.
  TYPE r_ele_attribution IS RECORD
          (
          from_time_dimension         fnd_lookups.lookup_code%TYPE
          ,pay_source_value           fnd_lookups.lookup_code%TYPE
          ,qualifier                  pay_element_types_f.element_name%TYPE
          ,fte                        fnd_lookups.lookup_code%TYPE
          ,termtime                   fnd_lookups.lookup_code%TYPE
          ,calc_type                  fnd_lookups.lookup_code%TYPE
          ,calc_value                 fnd_lookups.lookup_code%TYPE
          ,input_value                fnd_lookups.lookup_code%TYPE
          ,link_to_assign             fnd_lookups.lookup_code%TYPE
          ,term_time_yes_no           fnd_lookups.lookup_code%TYPE
          ,sum_multiple_entries_yn    fnd_lookups.lookup_code%TYPE
          ,lookup_input_values_yn     fnd_lookups.lookup_code%TYPE
          ,column_name_source_type    pay_element_type_extra_info.eei_information16%TYPE
          ,column_name_source_name    pay_element_type_extra_info.eei_information17%TYPE
          ,row_name_source_type       pay_element_type_extra_info.eei_information18%TYPE
          ,row_name_source_name       pay_element_type_extra_info.eei_information19%TYPE
          );

  TYPE t_ele_attribution IS TABLE OF r_ele_attribution
                         INDEX BY BINARY_INTEGER;

  g_ele_attribution     t_ele_attribution;

--
-- function to check for special characters in a string
-- if not a-z,A-Z,0-9, return false
--
function is_alphanumeric
  (p_string                in varchar2
  ) Return Boolean;

--
-- function to check for special characters in a string
-- if not a-z,A-Z,0-9, or a space, return false
--
function is_alphanumeric_space_allowed
  (p_string                in varchar2
  ) Return Boolean;

--
-- function to check for special characters in a string
-- if not 0-9, return false
--
function is_numeric
  (p_string                in varchar2
  ) Return Boolean;

/*
--
--  GET_CURRENT_EXTRACT_RESULT
--
--    Returns the ext_rslt_id for the current extract process
--    if one is running, else returns -1
--
  FUNCTION get_current_extract_result RETURN NUMBER;

*/


--
--  GET_CURRENT_EXTRACT_PERSON
--
--    Returns the person id associated with the given assignment.
--    If none is found,it returns NULL. This may arise if the
--    user calls this from a header/trailer record, where
--    a dummy context of assignment_id = -1 is passed.
--
--
  FUNCTION get_current_extract_person
    (p_assignment_id NUMBER  -- context
    ) RETURN NUMBER;

-- =============================================================================
-- Cursor to get the extract dfn id
-- =============================================================================

   CURSOR csr_ext_dfn_id(c_extract_name   IN VARCHAR2) IS
    SELECT dfn.ext_dfn_id
     FROM  ben_ext_dfn dfn
     WHERE dfn.name = c_extract_name;


-- =============================================================================
-- Get the benefit action details
-- =============================================================================
   Cursor csr_ben (c_ext_dfn_id in number
                  ,c_ext_rslt_id in number
                  ,c_business_group_id in number) is
   select ben.pgm_id
         ,ben.pl_id
         ,ben.benefit_action_id
         ,ben.business_group_id
         ,ben.process_date
         ,ben.request_id
     from ben_benefit_actions ben
    where ben.pl_id  = c_ext_rslt_id
      and ben.pgm_id = c_ext_dfn_id
      and ben.business_group_id = c_business_group_id;

-- =============================================================================
-- Cursor to fetch the last successful approved run date
-- =============================================================================
   CURSOR csr_get_run_date(c_ext_dfn_id IN NUMBER
                          ,c_business_group_id IN NUMBER)
   IS
   SELECT least(trunc(run_strt_dt),eff_dt),output_name -- MAX(eff_dt)
     FROM ben_ext_rslt
    WHERE ext_dfn_id = c_ext_dfn_id
      AND business_group_id = c_business_group_id
      AND ext_stat_cd = 'A'
            order by eff_dt desc;


--
-- Error and warning raising functions to be called from raise_data_errors
--

  FUNCTION raise_extract_warning
    (p_assignment_id     IN     NUMBER    DEFAULT g_assignment_id     -- context
    ,p_error_text        IN     VARCHAR2
    ,p_error_number      IN     NUMBER    DEFAULT NULL
    ,p_token1            IN     VARCHAR2  DEFAULT NULL  --added to pass tokens to messages.
    ,p_token2            IN     VARCHAR2  DEFAULT NULL  --added to pass tokens to messages.
    ,p_token3            IN     VARCHAR2  DEFAULT NULL  --added to pass tokens to messages.
    ,p_token4            IN     VARCHAR2  DEFAULT NULL  --added to pass tokens to messages.
    ) RETURN NUMBER;

  FUNCTION raise_extract_error
    (p_business_group_id IN     NUMBER    DEFAULT g_business_group_id -- context
    ,p_assignment_id     IN     NUMBER    DEFAULT g_assignment_id     -- context
    ,p_error_text        IN     VARCHAR2
    ,p_error_number      IN     NUMBER    DEFAULT NULL
    ,p_token1            IN     VARCHAR2  DEFAULT NULL  --added to pass tokens to messages.
    ,p_token2            IN     VARCHAR2  DEFAULT NULL  --added to pass tokens to messages.
    ,p_token3            IN     VARCHAR2  DEFAULT NULL  --added to pass tokens to messages.
    ,p_token4            IN     VARCHAR2  DEFAULT NULL  --added to pass tokens to messages.
    ) RETURN NUMBER;


  FUNCTION include_event
    (p_actual_date IN DATE
    ,p_effective_date IN DATE
    ,p_run_from_cutover_date IN VARCHAR2 DEFAULT 'N'
    )
  RETURN VARCHAR2;

  PROCEDURE process_retro_event
              (
              p_include   VARCHAR2  DEFAULT 'Y'
              );

  FUNCTION chk_is_employee_a_leaver
                (
                p_assignment_id     NUMBER
                ,p_effective_date   DATE
                ,p_leaver_date      OUT NOCOPY DATE
                ) RETURN VARCHAR2;


  FUNCTION get_ext_rslt_frm_req
                (p_request_id        IN NUMBER
                ,p_business_group_id IN NUMBER
                ) RETURN NUMBER;

  PROCEDURE get_elements_of_info_type
      (p_information_type         IN VARCHAR2
      ,p_input_value              IN VARCHAR2 DEFAULT 'PAY VALUE'
      ,p_input_value_mandatory_yn IN VARCHAR2 DEFAULT 'Y'
      );


  PROCEDURE check_if_element_qualifies
      (p_element_entry_id           IN  NUMBER
      ,p_element_type_id            OUT NOCOPY NUMBER
      ,p_include                    OUT NOCOPY VARCHAR2 -- Y/N
      ,p_extract_type               IN  VARCHAR2 DEFAULT 'PERIODIC'
      ,p_element_type_id_from_crit  IN  NUMBER DEFAULT NULL
      );


  FUNCTION calc_payment_by_run_rslt
    (p_assignment_id      IN NUMBER
    ,p_element_entry_id IN NUMBER
    ,p_element_type_id  IN NUMBER
    ,p_date_earned      IN DATE
    )  RETURN NUMBER;


  FUNCTION get_element_payment
    (p_assignment_id        IN NUMBER
    ,p_element_entry_id   IN NUMBER
    ,p_element_type_id    IN NUMBER
    ,p_effective_date     IN DATE
    )  RETURN NUMBER;



  FUNCTION get_element_payment_balance
    (p_assignment_id        IN NUMBER
    ,p_element_entry_id   IN NUMBER
    ,p_element_type_id    IN NUMBER
    ,p_balance_type_id    IN NUMBER
    ,p_effective_date     IN DATE
    )  RETURN NUMBER;



  FUNCTION ele_entry_inp_val_cut_crit
     (
       p_ext_pay_input_value   IN VARCHAR2
      ,p_ext_pay_element_type  IN VARCHAR2
      ,p_ext_pay_element_entry IN VARCHAR2
      ,p_output                OUT NOCOPY VARCHAR2
     )RETURN VARCHAR2;

  FUNCTION ele_entry_inp_val_per_crit
     (
       p_ext_pay_input_value   IN VARCHAR2
      ,p_ext_pay_element_type  IN VARCHAR2
      ,p_ext_pay_element_entry IN VARCHAR2
      ,p_output                OUT NOCOPY VARCHAR2
     )RETURN VARCHAR2;


  FUNCTION check_employee_pension_scheme
      (p_business_group_id       IN NUMBER
      ,p_effective_date          IN DATE
      ,p_assignment_id           IN NUMBER
      ,p_psi_pension_scheme      IN VARCHAR2
      ,p_pension_element_type_id OUT NOCOPY NUMBER
      ) RETURN VARCHAR2;

  FUNCTION is_today_sal_start RETURN VARCHAR2;
  FUNCTION is_today_sal_end RETURN VARCHAR2;

  FUNCTION get_dated_table_name
                (
                p_dated_table_id    NUMBER
                )RETURN VARCHAR2;

  Procedure exclude_errored_people
          (p_business_group_id in number
          );

  Procedure common_post_process
          (p_business_group_id in number
          );

   FUNCTION get_first_retro_event_date
                (
                p_assignment_id    IN  NUMBER
                ,p_retro_event_date OUT NOCOPY DATE
                )RETURN NUMBER;
/* For bug 8359083
 -- ----------------------------------------------------------------------------
 -- |-----------------------< get_penserver_date >--------------------------|
 -- Description: This function will fetch the least effective_date for each assignment
 --              from where the events needs to be processed for reporting
 -- ----------------------------------------------------------------------------

   FUNCTION get_penserver_date
                (p_assignment_id     IN    NUMBER
                ,p_business_group_id IN   NUMBER
                ,p_lapp_date      IN date
                ,p_end_date       IN DATE
                ) RETURN date;  */

    -- ----------------------------------------------------------------------------
    -- |-----------------------< is_proper_claim_date >--------------------------|
    -- Description:
    -- ----------------------------------------------------------------------------
    FUNCTION is_proper_claim_date
                (
                p_claim_date        IN DATE
                ,p_element_name     IN VARCHAR2
                ,p_element_entry_id IN NUMBER
                ,p_assg_start_date  IN DATE
                )RETURN BOOLEAN;


    -- ----------------------------------------------------------------------------
    -- |------------------------< get_rate_usr_func_name >--------------------------|
    -- ----------------------------------------------------------------------------
    PROCEDURE get_rate_usr_func_name
                (
                p_business_group_id   NUMBER
                ,p_legislation_code   VARCHAR2
                ,p_interface_name     VARCHAR2    -- expected to be SALARY / ALLOWANCE
                ,p_rate_name          OUT NOCOPY VARCHAR2
                ,p_rate_code          OUT NOCOPY VARCHAR2
                ,p_usr_rate_function  OUT NOCOPY VARCHAR2
                ,p_sal_ele_fte_attr   OUT NOCOPY VARCHAR2
                );

    ----------------------------------------------------------------------------
    -- |------------------------< get_fte_value >--------------------------|
    -- ----------------------------------------------------------------------------
    FUNCTION get_fte_value
              (
              p_assignment_id   NUMBER
              ,p_effective_date  DATE
              )RETURN NUMBER;

    ----------------------------------------------------------------------------
    -- |------------------------< get_element_attribution >--------------------------|
    -- ----------------------------------------------------------------------------
    PROCEDURE get_element_attribution
              (
              p_element_name      VARCHAR2
              ,p_ele_attribution  OUT NOCOPY  r_ele_attribution
              );

END PQP_GB_PSI_FUNCTIONS;

/
