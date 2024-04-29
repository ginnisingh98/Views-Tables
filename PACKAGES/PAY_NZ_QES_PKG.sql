--------------------------------------------------------
--  DDL for Package PAY_NZ_QES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NZ_QES_PKG" AUTHID CURRENT_USER as
/* $Header: pynzqes.pkh 115.4 2003/05/30 08:27:36 puchil ship $ */

function count_employees
  (p_organization_id  in hr_organization_units.organization_id%type,
   p_payroll_id       in pay_all_payrolls_f.payroll_id%type,
   p_time_period_id   in per_time_periods.time_period_id%type,
   p_location_id      in per_all_assignments_f.location_id%type,
   p_emp_cat_code     in per_all_people_f.per_information7%type,
   p_work_time_code   in per_all_people_f.per_information8%type,
   p_sex              in per_all_people_f.sex%type,
    p_survey_date     in date)
  return number;

function count_employees_using_balance
  (p_organization_id  in hr_organization_units.organization_id%type,
   p_payroll_id       in pay_all_payrolls_f.payroll_id%type,
   p_time_period_id   in per_time_periods.time_period_id%type,
   p_location_id      in per_all_assignments_f.location_id%type,
   p_emp_cat_code     in per_all_people_f.per_information7%type,
   p_work_time_code   in per_all_people_f.per_information8%type,
   p_sex              in per_all_people_f.sex%type,
   p_week_hours       in per_all_assignments_f.normal_hours%type,
   p_week_frequency   in per_all_assignments_f.frequency%type,
   p_survey_date      in date)
 return number;

function sum_balances
  (p_organization_id     in hr_organization_units.organization_id%type,
   p_payroll_id          in pay_all_payrolls_f.payroll_id%type,
   p_time_period_id      in per_time_periods.time_period_id%type,
   p_location_id         in per_all_assignments_f.location_id%type,
   p_defined_balance_id  in pay_defined_balances.defined_balance_id%type,
   p_sex                 in per_all_people_f.sex%type,
   p_survey_date         in date)
  return number;

  function id_for_defined_balance
    (p_balance_name       in pay_balance_types.balance_name%type,
     p_balance_dimension  in pay_balance_dimensions.database_item_suffix%type)
  return pay_balance_types.balance_type_id%type;

  function ordinary_time_payout
    (p_regular_payment_date  in per_time_periods.regular_payment_date%type,
     p_assignment_id         in per_all_assignments_f.assignment_id%type)
  return number;

  function hours_worked
    (p_assignment_id      in per_all_assignments_f.assignment_id%type,
     p_payroll_frequency  in pay_all_payrolls_f.period_type%type)
  return number;

  function convert_hours
    (p_assignment_hours     in per_all_assignments_f.normal_hours%type,
     p_payroll_frequency    in pay_all_payrolls_f.period_type%type,
     p_assignment_frequency in per_all_assignments_f.frequency%type)
  return number;

  function no_periods_per_year
    (p_period_type  in per_time_period_types.period_type%type)
  return number;
end pay_nz_qes_pkg;

 

/
