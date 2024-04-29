--------------------------------------------------------
--  DDL for Package PQP_GB_PSI_BON_HISTORY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_GB_PSI_BON_HISTORY" AUTHID CURRENT_USER AS
    --  /* $Header: pqpgbpsibon.pkh 120.4.12010000.2 2008/08/05 14:06:51 ubhat ship $ */
    -- Debug Variables.
    --
    g_debug                        BOOLEAN    := hr_utility.debug_enabled;
    g_package                      VARCHAR2(30) := 'PQP_GB_PSI_BON_HISTORY';
    c_highest_date                 CONSTANT DATE := hr_api.g_eot;

    g_assignment_id                NUMBER;
    g_person_id                    NUMBER;
    g_business_group_id            per_all_people_f.business_group_id%TYPE;
    g_legislation_code             VARCHAR2(4);
    g_current_layout               VARCHAR2(20);

    g_paypoint                     VARCHAR2(30);
    g_ext_dfn_id                   NUMBER;
    g_pay_proc_evt_tab             ben_ext_person.t_detailed_output_table;


    g_curr_person_dtls             per_all_people_f%ROWTYPE;
            -- this contains the person details on effective date

    g_curr_assg_dtls               per_all_assignments_f%ROWTYPE;
            -- this contains the person details on effective date

    g_effective_date              DATE;
    g_curr_element_type_id        NUMBER;
    g_curr_element_entry_id       NUMBER;
    g_curr_element_type_name      PAY_ELEMENT_TYPES_F.element_name%TYPE;
    g_curr_ee_start_date          DATE;
    g_curr_ee_end_date            DATE;

    g_include_current_row         BOOLEAN;

    TYPE t_varchar2 IS TABLE OF VARCHAR2(1000)
                INDEX BY BINARY_INTEGER;
    g_proc_bon_codes      t_varchar2;

    g_assg_start_date     DATE;

    g_bon_bal_type_id     pay_balance_types.balance_type_id%TYPE;

--For BUG 5998129
    g_first_retro_event             DATE;
    g_first_retro_event_start       DATE;
    g_first_approved_event          DATE;
    g_first_eff_date		    BOOLEAN; /* For Bug: 6791275 */


    -- ----------------------------------------------------------------------------
    -- |--------------------< bonus_cutover_ext_criteria >----------------------|
    -- ----------------------------------------------------------------------------
    FUNCTION bonus_cutover_ext_criteria
                (
                p_business_group_id      IN NUMBER
                ,p_assignment_id         IN NUMBER
                ,p_effective_date        IN DATE
                )RETURN VARCHAR2;
    -- ----------------------------------------------------------------------------
    -- |--------------------< bonus_periodic_ext_criteria >----------------------|
    -- ----------------------------------------------------------------------------
    FUNCTION bonus_periodic_ext_criteria
                (
                p_business_group_id      IN NUMBER
                ,p_assignment_id         IN NUMBER
                ,p_effective_date        IN DATE
                )RETURN VARCHAR2;
    -- ----------------------------------------------------------------------------
    -- |--------------------< bonus_history_data_ele_val >----------------------|
    -- ----------------------------------------------------------------------------
    FUNCTION bonus_history_data_ele_val
                 (
                 p_ext_user_value     IN VARCHAR2
                 ,p_output_value       OUT NOCOPY VARCHAR2
                 ) RETURN NUMBER;

    -- ----------------------------------------------------------------------------
    -- |----------------------< bonus_history_post_proc >--------------------------|
    --  Description:  This is the post-processing rule  for the Short-Time Hours History.
    -- ----------------------------------------------------------------------------
    FUNCTION bonus_history_post_proc RETURN VARCHAR2;

END PQP_GB_PSI_BON_HISTORY;

/
