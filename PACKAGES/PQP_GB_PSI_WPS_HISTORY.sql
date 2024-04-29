--------------------------------------------------------
--  DDL for Package PQP_GB_PSI_WPS_HISTORY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_GB_PSI_WPS_HISTORY" AUTHID CURRENT_USER AS
--  /* $Header: pqpgbpsiwps.pkh 120.1 2007/05/24 06:35:02 jvaradra noship $ */

    --
    -- Debug Variables.
    --

    g_proc_name              VARCHAR2(61):= 'PQP_GB_PSI_WPS_HISTORY.';

    g_debug                  BOOLEAN    := hr_utility.debug_enabled;
    c_application_id         CONSTANT NUMBER := 8303;
    c_highest_date           CONSTANT DATE := hr_api.g_eot;
    g_person_id              NUMBER      := NULL;
    g_business_group_id      NUMBER      := NULL; -- IMPORTANT TO KEEP NULL
    g_assignment_id          NUMBER      := NULL; -- IMPORTANT TO KEEP NULL
    g_person_dtl             per_all_people_f%rowtype;
    g_assignment_dtl         per_all_assignments_f%rowtype;
    g_altkey                 VARCHAR2(12):= NULL;
    g_current_run            varchar2(20) := NULL;
    g_prev_event_dtl_rec     ben_ext_person.t_detailed_output_tab_rec;
    g_notional_pay           NUMBER; -- used while calculating actual pay
    g_effective_date         DATE;-- for cutover run this will be the cutover date
    g_extract_type           VARCHAR2(100);
    g_legislation_code       per_business_groups.legislation_code%TYPE   := 'GB';

    g_pension_element_type_id       NUMBER;

    -- for 6071527
    g_pension_scheme_name     VARCHAR2(50);


    -- for include_events
    g_pay_proc_evt_tab             ben_ext_person.t_detailed_output_table;

    -- globals set by set_shared_globals
    g_paypoint               VARCHAR2(5) := NULL;
    g_cutover_date           DATE;
    g_ext_dfn_id             NUMBER;
    g_is_terminated          VARCHAR2(1)  :='N';


    g_curr_person_dtls             per_all_people_f%ROWTYPE;
            -- this contains the person details on effective date

    g_curr_assg_dtls               per_all_assignments_f%ROWTYPE;

    -- uniformed grade override flag configuration values.
    g_unigrade_source     VARCHAR2(30);
    g_assignment_context  VARCHAR2(80);
    g_assignment_column   VARCHAR2(30);
    g_people_group_column VARCHAR2(30);
    ----------


    TYPE t_varchar30 IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
    g_dated_tables        t_varchar30;

    CURSOR get_wps_percent_cont_per
           (p_element_entry_id  IN NUMBER
            ,p_effective_date   IN DATE
            ,p_input_value_name IN VARCHAR2
           )
    IS
         SELECT peev.screen_entry_value
         FROM    pay_element_entry_values_f peev
                ,pay_input_values_f piv
         WHERE  peev.element_entry_id = p_element_entry_id
         AND    piv.input_value_id = peev.input_value_id
         AND    piv.NAME = p_input_value_name
         AND    p_effective_date BETWEEN peev.effective_start_date AND peev.effective_end_date;


    CURSOR get_wps_percent_cont_cut
           (p_assignment_id IN NUMBER
            ,p_effective_date  IN DATE
                ,p_element_type_id IN NUMBER
            ,p_input_value_name IN VARCHAR2
           )
    IS
        SELECT peev.screen_entry_value,peev.element_entry_id
        FROM pay_element_entries_f pee
            ,pay_element_entry_values_f peev
            ,pay_input_values_f piv
        WHERE pee.assignment_id=p_assignment_id
      AND pee.element_type_id = p_element_type_id
        AND peev.element_entry_id = pee.element_entry_id
        AND piv.input_value_id = peev.input_value_id
        AND piv.NAME = p_input_value_name
        AND p_effective_date BETWEEN peev.effective_start_date AND peev.effective_end_date
        AND rownum = 1;

    CURSOR csr_get_entry_type
            (p_element_entry_id IN NUMBER
             ,p_effective_date  IN DATE
            )
    IS
        SELECT entry_type
        FROM pay_element_entries_f
        where element_entry_id = p_element_entry_id
        AND p_effective_date BETWEEN effective_start_date AND effective_end_date;

    CURSOR csr_get_start_date_cut
            (p_element_entry_id IN NUMBER
            )
    IS
        SELECT effective_start_date FROM pay_element_entries_f
        WHERE element_entry_id = p_element_entry_id
        AND rownum = 1
        ORDER BY effective_start_date;

    CURSOR get_wps_element_name
            (p_element_type_id IN NUMBER
            )
    IS
        SELECT element_name FROM pay_element_types_f
        WHERE element_type_id = p_element_type_id
        AND rownum=1;

    TYPE t_number IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

    CURSOR csr_get_element_entry_id
            (
            p_element_entry_value_id    IN NUMBER
            )
     IS
            SELECT element_entry_id
            FROM PAY_ELEMENT_ENTRY_VALUES_F
            WHERE element_entry_value_id =p_element_entry_value_id
            AND ROWNUM=1;

    CURSOR csr_get_element_type_id
            (
            c_element_entry_id IN NUMBER
            )
     IS
            SELECT element_type_id
            FROM pay_element_entries_f
            WHERE element_entry_id = c_element_entry_id
            AND rownum=1;

     -- for 6071527
     /* to fetch the pension scheme name */
    CURSOR get_wps_ele_scheme_name
             (
             p_element_type_id IN NUMBER
             )
    IS
           SELECT eei_information1
             FROM pay_element_type_extra_info
            WHERE element_type_id = p_element_type_id
              AND information_type = 'PQP_GB_PENSION_SCHEME_INFO';

   /* to check if the buy back element is valid */
   CURSOR get_wps_byb_ele_scheme_name
             (
              p_element_type_id IN NUMBER
             ,p_pension_scheme_name IN VARCHAR2
             )
         IS
             SELECT eei_information1
               FROM pay_element_type_extra_info
              WHERE element_type_id = p_element_type_id
                AND information_type = 'PQP_GB_PENSION_SCHEME_INFO'
                AND eei_information1 = p_pension_scheme_name;

     /* to fetch the basic element contribution percent */
     CURSOR get_wps_percent_cont
           (p_assignment_id IN NUMBER
           ,p_effective_date  IN DATE
           ,p_element_type_id IN NUMBER
           ,p_input_value_name IN VARCHAR2
           )
    IS
        SELECT peev.screen_entry_value
          FROM pay_element_entries_f pee
               ,pay_element_entry_values_f peev
               ,pay_input_values_f piv
         WHERE pee.assignment_id=p_assignment_id
           AND pee.element_type_id = p_element_type_id
           AND peev.element_entry_id = pee.element_entry_id
           AND piv.input_value_id = peev.input_value_id
           AND piv.NAME = p_input_value_name
           AND p_effective_date BETWEEN peev.effective_start_date AND peev.effective_end_date
           AND rownum = 1;

     /* to fetch the buy back element contribution percent */
     CURSOR get_wps_byb_percent_cont
            (p_effective_date   IN DATE
            ,p_assignment_id IN NUMBER
            ,p_input_value_name IN VARCHAR2
            ,p_scheme_name IN VARCHAR2
           )
     IS
        SELECT peev.screen_entry_value
          FROM pay_element_types_f pet
              ,pay_element_entries_f pee
              ,pay_element_type_extra_info pete
              ,pay_element_entry_values_f peev
              ,pay_input_values_f piv
          WHERE pee.assignment_id = p_assignment_id -- 301168
            AND pee.element_type_id = pet.element_type_id -- 172156
            AND pet.element_name like '%Buy Back FWC'
            AND pet.element_type_id = pete.element_type_id
            AND pete.eei_information1 = p_scheme_name --'Classic'
            AND pee.element_entry_id = peev.element_entry_id
            AND peev.input_value_id = piv.input_value_id
            AND piv.NAME = p_input_value_name -- p_input_value_name
            AND p_effective_date BETWEEN peev.effective_start_date AND peev.effective_end_date
            AND p_effective_date BETWEEN pee.effective_start_date AND pee.effective_end_date;

        CURSOR get_wps_eff_end_date(p_element_type_id in number
                                   ,p_assignment_id in number
                                   ,p_effective_date in date
                                   )
         IS   SELECT effective_end_date
                FROM pay_element_entries_f
               WHERE assignment_id = p_assignment_id
                 AND p_effective_date BETWEEN effective_start_date AND effective_end_date
                 AND element_type_id = g_pension_element_type_id;

         CURSOR get_assgn_eff_end_date(p_assignment_id in number
                                      ,p_effective_date in date
                                      )
         IS   SELECT effective_end_date
                FROM per_all_assignments_f
               WHERE assignment_id = p_assignment_id
                 AND effective_end_date = p_effective_date
                 AND assignment_status_type_id = 1;

   -- for 6071527 end

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
       ---

-- ----------------------------------------------------------------------------
-- |------------------------< Function Definitions >---------------------------|
-- ----------------------------------------------------------------------------

  --
  -- WPS history main function
  --
  FUNCTION wps_history_main
            (p_business_group_id        IN         NUMBER   -- context
            ,p_effective_date           IN         DATE     -- context
            ,p_assignment_id            IN         NUMBER   -- context
            ,p_rule_parameter           IN         VARCHAR2 -- parameter
            ,p_output                   OUT NOCOPY VARCHAR2
            )
  RETURN number;

-- ----------------------------------------------------------------------------
-- |------------------------< chk_wps_cutover_crit >-------------------|
-- ----------------------------------------------------------------------------

FUNCTION chk_wps_cutover_crit
    (p_business_group_id        IN      NUMBER
    ,p_effective_date           IN      DATE
    ,p_assignment_id            IN      NUMBER
    )
  RETURN VARCHAR2;



-- ----------------------------------------------------------------------------
-- |------------------------< chk_wps_periodic_crit >-------------------|
-- ----------------------------------------------------------------------------

  FUNCTION chk_wps_periodic_crit
          (p_business_group_id        IN      NUMBER
          ,p_effective_date           IN      DATE
          ,p_assignment_id            IN      NUMBER
          )RETURN VARCHAR2;

-- ----------------------------------------------------------------------------
-- |----------------------< wps_post_processing >--------------------------|
--  Description:  This is the post-processing rule  for the Salary History.
-- ----------------------------------------------------------------------------
  FUNCTION wps_post_processing RETURN VARCHAR2;

END PQP_GB_PSI_WPS_HISTORY;

/
