--------------------------------------------------------
--  DDL for Package PQP_GB_PSI_STH_HISTORY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_GB_PSI_STH_HISTORY" AUTHID CURRENT_USER AS
    --  /* $Header: pqpgbpsisth.pkh 120.1.12000000.2 2007/02/13 14:00:13 mseshadr noship $ */
    -- Debug Variables.
    --
    g_debug                        BOOLEAN    := hr_utility.debug_enabled;
    g_package                      VARCHAR2(30) := 'PQP_GB_PSI_STH_HISTORY';
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
    g_assg_start_date             DATE;

    g_start_date                  DATE  := NULL;
    g_end_date                    DATE  := NULL;
    g_effective_date              DATE;
    g_adjusted_hours              NUMBER;
    g_curr_element_entry_id       NUMBER;
    g_curr_element_type_id        NUMBER;
    g_curr_element_type_name      PAY_ELEMENT_TYPES_F.element_name%TYPE;

    ------------------------------------------
    g_adj_hrs_source              VARCHAR2(20); -- balance / element entries
    g_adj_hrs_bal_type            VARCHAR2(80);
    ------------------------------------------

    TYPE r_element_type_details IS RECORD
              (
              element_type_name     pay_element_types_f.element_name%TYPE
              );

    TYPE t_element_type_details IS TABLE OF r_element_type_details
                INDEX BY BINARY_INTEGER;

    g_valid_element_type_details  t_element_type_details;
                -- this contains the valid element type details.
    TYPE t_number IS TABLE OF NUMBER
                INDEX BY BINARY_INTEGER;

    TYPE t_varchar2 IS TABLE OF VARCHAR2(100)
                INDEX BY BINARY_INTEGER;

    g_proc_ele_entries      t_varchar2;
                -- this contains the processed element_entry_ids

    g_reported_claim_dates  t_varchar2;
                -- this contains the reported claim dates.
                -- this will be storing the element_entry_id indexed by
                -- date converted to the format 'ddmmyyyy' which will
                -- be a number

    g_reported_pay_periods  t_varchar2;
                -- this contains the  start dates of the reported pay periods
                -- this will be used only for Accumulated Records when the
                -- adj hours source s configured as balance type.

    -- ----------------------------------------------------------------------------
    -- |--------------------< short_time_hours_sin_criteria >----------------------|
    -- ----------------------------------------------------------------------------
    FUNCTION short_time_hours_sin_criteria
                (
                p_business_group_id      IN NUMBER
                ,p_assignment_id         IN NUMBER
                ,p_effective_date        IN DATE
                )RETURN VARCHAR2;
    -- ----------------------------------------------------------------------------
    -- |--------------------< short_time_hours_acc_criteria >----------------------|
    -- ----------------------------------------------------------------------------
    FUNCTION short_time_hours_acc_criteria
                (
                p_business_group_id      IN NUMBER
                ,p_assignment_id         IN NUMBER
                ,p_effective_date        IN DATE
                )RETURN VARCHAR2;
    -- ----------------------------------------------------------------------------
    -- |--------------------< short_time_hours_data_ele_val >----------------------|
    -- ----------------------------------------------------------------------------
    FUNCTION short_time_hours_data_ele_val
                 (
                 p_ext_user_value     IN VARCHAR2
                 ,p_output_value       OUT NOCOPY VARCHAR2
                 ) RETURN NUMBER;
    -- ----------------------------------------------------------------------------
    -- |----------------------< short_time_hours_claim_date >--------------------------|
    --  Description:  This is the post-processing rule  for the Short-Time Hours History.
    -- ----------------------------------------------------------------------------
    FUNCTION short_time_hours_claim_date
                 (
                 p_ext_user_value     IN VARCHAR2
                 ,p_output_value       OUT NOCOPY VARCHAR2
                 ) RETURN NUMBER;
    -- ----------------------------------------------------------------------------
    -- |----------------------< short_time_hours_post_proc >--------------------------|
    --  Description:  This is the post-processing rule  for the Short-Time Hours History.
    -- ----------------------------------------------------------------------------
    FUNCTION short_time_hours_post_proc RETURN VARCHAR2;

END PQP_GB_PSI_STH_HISTORY;

 

/
