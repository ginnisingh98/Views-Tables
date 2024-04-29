--------------------------------------------------------
--  DDL for Package PQP_PENSION_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_PENSION_FUNCTIONS" AUTHID CURRENT_USER as
/* $Header: pqppenff.pkh 120.4.12010000.1 2008/07/28 11:21:09 appldev ship $ */

  type t_pension_info is table of pqp_pension_types_f%rowtype
  index by Binary_Integer;

  TYPE r_tax_si_rec IS RECORD
     ( tax_si_code     varchar2(20)
      ,reduction_order number);

  TYPE t_tax_si_tbl IS TABLE OF r_tax_si_rec
     INDEX BY BINARY_INTEGER;

  g_pension_rec              t_pension_info;
  g_proc_name                varchar2(80) := 'PQP_Pension_functions.';

-- ----------------------------------------------------------------------------
-- |---------------------< get_pension_type_details >--------------------------|
-- ----------------------------------------------------------------------------
--
function get_pension_type_details
  (p_business_group_id   in     pqp_pension_types_f.business_group_id%TYPE
  ,p_date_earned         in     date
  ,p_assignment_id       in     per_all_assignments_f.assignment_id%TYPE
  ,p_pension_type_id     in     pqp_pension_types_f.pension_type_id%TYPE
  ,p_legislation_code    in     pqp_pension_types_f.legislation_code%TYPE
  ,p_column_name         in     varchar2
  ,p_column_value        out nocopy varchar2
  ,p_error_message       out nocopy varchar2

  ) return NUMBER;

-- ----------------------------------------------------------------------------
-- |-------------------------< prorate_amount >-------------------------------|
-- ----------------------------------------------------------------------------
--
function prorate_amount
  (p_business_group_id      in     pqp_pension_types_f.business_group_id%TYPE
  ,p_date_earned            in     date
  ,p_assignment_id          in     per_all_assignments_f.assignment_id%TYPE
  ,p_amount                 in     number
  ,p_payroll_period         in     varchar2
  ,p_work_pattern           in     varchar2
  ,p_conversion_rule        in     varchar2
  ,p_prorated_amount        out nocopy number
  ,p_error_message          out nocopy varchar2
  ,p_payroll_period_prorate in varchar2
  ,p_override_pension_days  in NUMBER DEFAULT -9999
  ) return NUMBER;




-- ----------------------------------------------------------------------------
-- |--------------------------< get_run_year >--------------------------------|
-- ----------------------------------------------------------------------------
--
function get_run_year
  (p_date_earned          in     date
  ,p_error_message        out nocopy varchar2
  ) return NUMBER;

-- ----------------------------------------------------------------------------
-- |-----------------------< get_abp_pension_salary >-----------------------------|
-- ----------------------------------------------------------------------------
--

function get_abp_pension_salary
  (p_business_group_id        in     pqp_pension_types_f.business_group_id%TYPE
  ,p_date_earned              in     date
  ,p_assignment_id            in     per_all_assignments_f.assignment_id%TYPE
  ,p_payroll_id               in     pay_payroll_actions.payroll_id%TYPE
  ,p_period_start_date        in  date
  ,p_period_end_date          in  date
  ,p_scale_salary             in  number
  ,p_scale_salary_h           in  number
  ,p_ft_rec_bonus             in  number
  ,p_ft_rec_bonus_h           in  number
  ,p_pt_rec_bonus             in  number
  ,p_pt_rec_bonus_h           in  number
  ,p_ft_eoy_bonus             in  number
  ,p_ft_eoy_bonus_h           in  number
  ,p_pt_eoy_bonus             in  number
  ,p_pt_eoy_bonus_h           in  number
  ,p_salary_balance_value     out nocopy number
  ,p_error_message            out nocopy varchar2
  ,p_oht_correction           out nocopy varchar2
  ,p_scale_salary_eoy_bonus   in  number
  ,p_ft_rec_bonus_eoy_bonus   in  number
  ,p_pt_rec_bonus_eoy_bonus   in  number
  ,p_error_message1           out nocopy varchar2
  ,p_error_message2           out nocopy varchar2
  ,p_late_hire_indicator      in  number
  ) return number;

-- ----------------------------------------------------------------------------
-- |-----------------------< get_pension_salary >-----------------------------|
-- ----------------------------------------------------------------------------
--
function get_pension_salary
  (p_business_group_id    in  pqp_pension_types_f.business_group_id%TYPE
  ,p_date_earned          in  date
  ,p_assignment_id        in  per_all_assignments_f.assignment_id%TYPE
  ,p_payroll_action_id    in  pay_payroll_actions.payroll_action_id%TYPE
  ,p_salary_balance_name  in  varchar2
  ,p_payroll_period       in  varchar2
  ,p_salary_balance_value out nocopy number
  ,p_error_message        out nocopy varchar2
  ,p_pension_type_id      in  pqp_pension_types_f.pension_type_id%TYPE DEFAULT -99
  ) return NUMBER;


-- ----------------------------------------------------------------------------
-- |----------------------< get_pension_type_eligibility >--------------------|
-- ----------------------------------------------------------------------------
--
function get_pension_type_eligibility
  (p_business_group_id     in number
  ,p_date_earned           in date
  ,p_assignment_id         in number
  ,p_pension_type_id       in number
  ,p_eligibility_flag      out nocopy varchar2
  ,p_error_message         out nocopy varchar2
  ) return NUMBER;


-- ----------------------------------------------------------------------------
-- |----------------------< get_pension_threshold_ratio >--------------------|
-- ----------------------------------------------------------------------------
--
function get_pension_threshold_ratio
  (p_date_earned           in date
  ,p_assignment_id         in number
  ,p_business_group_id     in number
  ,p_assignment_action_id  in number
 ) return NUMBER;


-- ----------------------------------------------------------------------------
-- |----------------------< gen_dynamic_formula >-----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE gen_dynamic_formula ( p_pension_type_id  IN  NUMBER
                               ,p_effective_date   IN  DATE
                               ,p_formula_string   OUT NOCOPY varchar2
                             );

-- ----------------------------------------------------------------------------
-- |----------------------< gen_dynamic_sav_formula >-----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE gen_dynamic_sav_formula ( p_pension_type_id  IN  NUMBER
                                   ,p_effective_date   IN  DATE
                                   ,p_formula_string   OUT NOCOPY varchar2
                                  );

-- ------------------------------------------------------------------
-- |----------------------< get_bonus >-----------------------------|
-- ------------------------------------------------------------------

FUNCTION get_bonus
         ( p_date_earned       in   date
          ,p_assignment_id     in   per_all_assignments_f.assignment_id%TYPE
          ,p_business_group_id in   pqp_pension_types_f.business_group_id%TYPE
          ,p_pension_type_id   in   pqp_pension_types_f.pension_type_id%TYPE
          ,p_pay_period_salary in   number
          ,p_pay_period        in   varchar2
          ,p_work_pattern      in   varchar2
          ,p_conversion_rule   in   varchar2
          ,p_bonus_amount      out  NOCOPY number
          ,p_error_message     out  NOCOPY varchar2
         )
RETURN number;

-- ------------------------------------------------------------------
-- |----------------------< is_number >-----------------------------|
-- ------------------------------------------------------------------

FUNCTION is_number
         (
           p_data_value IN OUT NOCOPY varchar2
         )
RETURN NUMBER;

-- ------------------------------------------------------------------
-- |-----------------< get_addnl_savings_amt >-----------------------|
-- ------------------------------------------------------------------

FUNCTION get_addnl_savings_amt
         (
           p_assignment_id         in number
          ,p_date_earned           in date
          ,p_business_group_id     in number
          ,p_payroll_id            in number
          ,p_pension_type_id       in number
          ,p_payroll_period_number in number
          ,p_additional_amount     out NOCOPY number
          ,p_error_message         out NOCOPY varchar2
         )
RETURN NUMBER;

-- ----------------------------------------------------------------------------
-- |---------------------< get_abp_entry_value >--------------------------|
-- ----------------------------------------------------------------------------
--
function get_abp_entry_value
  (p_business_group_id   in     pqp_pension_types_f.business_group_id%TYPE
  ,p_date_earned         in     date
  ,p_assignment_id       in     per_all_assignments_f.assignment_id%TYPE
  ,p_element_type_id     in     number
  ,p_input_value_name    in     varchar2
  ) return NUMBER;

-- ----------------------------------------------------------------------------
-- |-----------------------< get_avg_part_time_perc >-------------------------|
-- ----------------------------------------------------------------------------
--
function get_avg_part_time_perc
  (p_business_group_id    in     pqp_pension_types_f.business_group_id%TYPE
  ,p_date_earned          in     date
  ,p_assignment_id        in     per_all_assignments_f.assignment_id%TYPE
  ,p_assignment_action_id IN     NUMBER
  ,p_period_start_date    in     DATE
  ,p_period_end_date      in     DATE
  ,p_avg_part_time_perc   OUT NOCOPY NUMBER
  ,p_error_message        OUT NOCOPY VARCHAR2)
return NUMBER;

-- ----------------------------------------------------------------------------
-- |-----------------------< get_avg_part_time_perc >-------------------------|
-- ----------------------------------------------------------------------------
FUNCTION get_hook_part_time_perc (p_assignment_id        IN NUMBER
                            ,p_date_earned          IN DATE
                            ,p_business_group_id    IN NUMBER
                            ,p_assignment_action_id IN NUMBER)
RETURN NUMBER;

-- ----------------------------------------------------------------------------
-- |--------------------< GET_REPORTING_PART_TIME_PERC>----------------------|
-- ----------------------------------------------------------------------------
FUNCTION GET_REPORTING_PART_TIME_PERC (p_assignment_id        IN NUMBER
                            ,p_date_earned          IN DATE
                            ,p_business_group_id    IN NUMBER
                            ,p_assignment_action_id IN NUMBER)
RETURN NUMBER;

-- ----------------------------------------------------------------------------
-- |---------------------------< GET_VERSION_ID>------------------------------|
-- ----------------------------------------------------------------------------
FUNCTION GET_VERSION_ID(p_business_group_id IN NUMBER
                       ,p_date_earned       IN DATE)
RETURN NUMBER;

--
-- ----------------------------------------------------------------------------
-- |---------------------< get_pay_period_age >-------------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION get_pay_period_age
  (p_business_group_id  IN  pqp_pension_types_f.business_group_id%TYPE
  ,p_date_earned        IN  DATE
  ,p_assignment_id      IN  per_all_assignments_f.assignment_id%TYPE
  ,p_period_start_date  IN  DATE
  ) RETURN NUMBER;

--
-- ----------------------------------------------------------------------------
-- |--------------------------< get_bal_val >---------------------------------|
-- ----------------------------------------------------------------------------
--
FUNCTION  get_bal_val
  (p_business_group_id    IN pqp_pension_types_f.business_group_id%TYPE
  ,p_assignment_id        IN per_all_assignments_f.assignment_id%TYPE
  ,p_effective_date       IN DATE
  ,p_balance_name         IN VARCHAR2
  ,p_dimension_name       IN VARCHAR2)
RETURN NUMBER;

END pqp_pension_functions;
--

/
