--------------------------------------------------------
--  DDL for Package PQP_GB_PSI_SALARY_HISTORY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_GB_PSI_SALARY_HISTORY" AUTHID CURRENT_USER AS
    --  /* $Header: pqpgbpssal.pkh 120.0.12000000.3 2007/03/07 13:15:02 kkarri noship $ */
    --
    -- Debug Variables.
    --
    g_debug                        BOOLEAN    := hr_utility.debug_enabled;
    g_package                      VARCHAR2(30) := 'PQP_GB_PSI_SALARY_HISTORY';
    c_application_id               CONSTANT NUMBER := 8303;
    c_highest_date                 CONSTANT DATE := hr_api.g_eot;
    g_person_id                    per_all_people_f.person_id%type;
    g_assignment_id                NUMBER;
    g_business_group_id            per_all_people_f.business_group_id%TYPE;
    g_legislation_code             VARCHAR2(4);
    g_current_run                  varchar2(20);
    g_pay_proc_evt_tab             ben_ext_person.t_detailed_output_table;
    g_prev_event_dtl_rec           ben_ext_person.t_detailed_output_tab_rec;
    g_notional_pay                 NUMBER; -- used while calculating actual pay
    g_effective_date               DATE;-- for cutover run this will be the cutover date
                                        --  for periodic changes this will be set to event eff date.

    --g_penserver_contract_type      VARCHAR2(1);
    --g_contract_type_effective_date DATE;
    --g_contract_type                VARCHAR2(30);

    g_basic_sal_rate_name          VARCHAR2(30); -- the rate type used for Salary.

    g_user_rate_function           VARCHAR2(200);

    g_sal_ele_fte_attr             VARCHAR2(10); -- added in 115.12.

    g_salary_start_date            DATE; --

    g_salary_end_date              DATE;--

    g_curr_person_dtls             per_all_people_f%ROWTYPE;
            -- this contains the person details on effective date

    g_curr_assg_dtls               per_all_assignments_f%ROWTYPE;
            -- this contains the person details on effective date
    g_paypoint                     VARCHAR2(30);
    g_cutover_date                 DATE;
    g_ext_dfn_id                   NUMBER;

    -- uniformed grade override flag configuration values.
    g_unigrade_source     VARCHAR2(30);
    g_assignment_context  VARCHAR2(80);
    g_assignment_column   VARCHAR2(30);
    g_people_group_column VARCHAR2(30);
    ----------

    g_grade_chg_date      DATE  :=  hr_api.g_eot;
    g_todays_grade_code   VARCHAR2(80);

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

    TYPE t_varchar2 IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;

    g_grade_codes t_varchar2;

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
    -- |----------------------< set_salary_history_globals >---------------------|
    --  Description: This procedure is to obtain set the extract level globals.
    -- ----------------------------------------------------------------------------
    PROCEDURE set_salary_history_globals
                (
                p_business_group_id     IN NUMBER
                ,p_assignment_id        IN NUMBER
                ,p_effective_date       IN DATE
                );

    -- ----------------------------------------------------------------------------
    -- |----------------------< set_assignment_globals >--------------------------|
    --  Description:  This procedure is to set the assignment level globals.
    -- ----------------------------------------------------------------------------
    PROCEDURE set_assignment_globals
                (
                p_assignment_id         IN NUMBER
                ,p_effective_date        IN DATE
                );

    PROCEDURE reset_salary_history_globals;

    -- ----------------------------------------------------------------------------
    -- |---------------------< salary_cutover_ext_criteria >---------------------|
    --  Description: Cutover extract criteria.
    -- ----------------------------------------------------------------------------
    FUNCTION salary_cutover_ext_criteria
                (
                p_business_group_id      IN NUMBER
                ,p_assignment_id         IN NUMBER
                ,p_effective_date        IN DATE
                )RETURN VARCHAR2;
    -- ----------------------------------------------------------------------------
    -- |---------------------< salary_periodic_ext_criteria >---------------------|
    --  Description: Periodic Changes extract criteria.
    -- ----------------------------------------------------------------------------
    FUNCTION salary_periodic_ext_criteria
                (
                p_business_group_id      IN NUMBER
                ,p_assignment_id         IN NUMBER
                ,p_effective_date        IN DATE
                )RETURN VARCHAR2;

    -- ----------------------------------------------------------------------------
    -- |---------------------< salary_data_element_value >-----------------------|
    --  Description:  This is a common function used by all the data elements to fetch
    --                  thier respective values. Depending the parameter p_ext_user_value
    --                  this procedure decides which value to be returned.
    -- ----------------------------------------------------------------------------
    FUNCTION salary_data_element_value
         (
         p_ext_user_value     IN VARCHAR2
         ,p_output_value      OUT NOCOPY VARCHAR2
         )
    RETURN NUMBER;

    -- ----------------------------------------------------------------------------
    -- |----------------------< salary_post_processing >--------------------------|
    --  Description:  This is the post-processing rule  for the Salary History.
    -- ----------------------------------------------------------------------------
    FUNCTION salary_post_processing RETURN VARCHAR2;

END PQP_GB_PSI_SALARY_HISTORY;

 

/
