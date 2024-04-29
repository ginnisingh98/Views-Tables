--------------------------------------------------------
--  DDL for Package PQP_GB_PSI_ALLOWANCE_HISTORY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_GB_PSI_ALLOWANCE_HISTORY" AUTHID CURRENT_USER AS
--  /* $Header: pqpgbpsiall.pkh 120.0.12010000.3 2008/08/05 14:06:26 ubhat ship $ */

    --
    -- Debug Variables.
    --

    g_proc_name              VARCHAR2(61):= 'PQP_GB_PSI_ALLOWANCE_HISTORY.';

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
    g_current_layout         varchar2(20) := NULL;
    g_notional_pay           NUMBER; -- used while calculating actual pay
    g_effective_date         DATE;-- for cutover run this will be the cutover date
    g_extract_type           VARCHAR2(100);
    g_legislation_code       per_business_groups.legislation_code%TYPE   := 'GB';

    g_notional_rate          NUMBER;
    g_allowance_actual_pay   NUMBER;
    g_allowance_code         VARCHAR2(10);

    -- for include_events
    g_pay_proc_evt_tab             ben_ext_person.t_detailed_output_table;

    -- globals set by set_shared_globals
    g_paypoint                  VARCHAR2(5) := NULL;
    g_cutover_date              DATE;
    g_ext_dfn_id                NUMBER;
    g_is_spread_bonus_yn        VARCHAR2(1) := NULL;
    g_allowance_end_dated_today VARCHAR2(1) := NULL;
    g_prev_event_dtl_rec        ben_ext_person.t_detailed_output_tab_rec;
    g_assg_start_date           DATE;
    g_user_rate_function        VARCHAR2(200) := NULL;
    g_claim_date                VARCHAR2(60);


    --g_penserver_contract_type      VARCHAR2(1);
    --g_contract_type_effective_date DATE;
    --g_contract_type                VARCHAR2(30);

    g_basic_sal_rate_name          VARCHAR2(30); -- the rate type used for Salary.

    g_salary_start_date            DATE; --

    g_salary_end_date              DATE;--

    g_salary_ele_end_date          DATE := c_highest_date;
            -- this is used to makr that current event date has a salary element end event
    g_non_salary_ele_end_date      DATE := c_highest_date;
            -- this is used to mark that there is no salary element end event on current event date

    g_sal_chg_event_exists         VARCHAR2(1);
            -- this is used to mark that there is a salary change event on current date.

    g_salary_ended                 VARCHAR2(1);
            -- this is mark that the salary has ended and no further event wud be processed

    g_salary_started               VARCHAR2(1);
            -- this is mark that the salary has started and further events will be processed

    g_curr_person_dtls             per_all_people_f%ROWTYPE;
            -- this contains the person details on effective date

    g_curr_assg_dtls               per_all_assignments_f%ROWTYPE;

  --For Bug 7149468
    g_leaver_event                  varchar2(2);

  --For Bug 7229852
    g_act_term_date                 DATE;


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

    TYPE t_number IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

    /*CURSOR csr_get_contract_type
                  (
                  p_effective_date  DATE
                  )
        IS
            select CONTRACT_TYPE
            from pqp_assignment_attributes_f
            where business_group_id = g_business_group_id
            and assignment_id = g_assignment_id
            and p_effective_date between effective_start_date
                                and effective_end_date;*/

    CURSOR csr_get_grade_extra_info
                (
                p_grade_id      NUMBER
                )
    IS
        select INFORMATION2 GRADE_CODE,INFORMATION5 UNIFORM_GRADE_FLAG
        from PER_GRADES
        where INFORMATION_CATEGORY = 'GB_PQP_PENSERV_GRADE_INFO'
        and grade_id  = p_grade_id
        and business_group_id = g_business_group_id
        and g_effective_date between date_from
                                  and nvl(date_to,c_highest_date);

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


    TYPE t_num_type    IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    TYPE t_date_type   IS TABLE OF DATE INDEX BY BINARY_INTEGER;

    TYPE r_asg_fte_values IS RECORD
          (
          t_assignment_budget_value_id  t_num_type
          ,t_effective_start_date       t_date_type
          ,t_effective_end_date         t_date_type
          ,t_value                      t_num_type
          );
    g_asg_fte_values r_asg_fte_values;

    -- cursor to fetch all the FTE values of an assignment
    CURSOR csr_get_asg_fte_values
    IS
        SELECT assignment_budget_value_id
               ,effective_start_date
               ,effective_end_date
               ,value
        FROM PER_ASSIGNMENT_BUDGET_VALUES_F
        WHERE UNIT = 'FTE'
        AND  assignment_id = g_assignment_id
        and business_group_id  = g_business_group_id;


    CURSOR csr_get_entry_value
         (c_effective_date    DATE
         ,c_element_entry_id  NUMBER
         ,c_input_value       IN VARCHAR2 DEFAULT 'PAY VALUE'
         )
    IS
    select peev.screen_entry_value
      from
      PAY_ELEMENT_ENTRY_VALUES_F peev
      ,pay_input_values_f piv
      where peev.element_entry_id = c_element_entry_id
        AND peev.input_value_id = piv.input_value_id
        and UPPER(piv.NAME) = UPPER(c_input_value)
        and c_effective_date
              between peev.effective_start_date
                  and peev.effective_end_date;

    CURSOR csr_get_start_date_cut
            (p_element_entry_id IN NUMBER
            )
    IS
        SELECT effective_start_date FROM pay_element_entries_f
        WHERE element_entry_id = p_element_entry_id
        AND rownum = 1
        ORDER BY effective_start_date;

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
  -- Allowance history main function
  --
  FUNCTION allowance_history_main
            (p_business_group_id        IN         NUMBER   -- context
            ,p_effective_date           IN         DATE     -- context
            ,p_assignment_id            IN         NUMBER   -- context
            ,p_rule_parameter           IN         VARCHAR2 -- parameter
            ,p_output                   OUT NOCOPY VARCHAR2
            )
  RETURN number;


    -- ----------------------------------------------------------------------------
    -- |---------------------< all_cutover_ext_criteria >---------------------|
    --  Description: Cutover extract criteria.
    -- ----------------------------------------------------------------------------
    FUNCTION all_cutover_ext_criteria
                (
                p_business_group_id      IN NUMBER
                ,p_assignment_id         IN NUMBER
                ,p_effective_date        IN DATE
                )RETURN VARCHAR2;
    -- ----------------------------------------------------------------------------
    -- |---------------------< salary_periodic_ext_criteria >---------------------|
    --  Description: Periodic Changes extract criteria.
    -- ----------------------------------------------------------------------------
    FUNCTION all_periodic_ext_criteria
                (
                p_business_group_id      IN NUMBER
                ,p_assignment_id         IN NUMBER
                ,p_effective_date        IN DATE
                )RETURN VARCHAR2;

  FUNCTION allowance_post_processing RETURN VARCHAR2;


END PQP_GB_PSI_ALLOWANCE_HISTORY;

/
