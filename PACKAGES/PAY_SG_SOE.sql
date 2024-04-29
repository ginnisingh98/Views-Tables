--------------------------------------------------------
--  DDL for Package PAY_SG_SOE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_SG_SOE" AUTHID CURRENT_USER as
/* $Header: pysgsoe.pkh 120.1.12010000.1 2008/07/27 23:42:02 appldev ship $ */

  function current_salary
    (p_pay_basis_id    in per_pay_bases.pay_basis_id%type,
     p_assignment_id   in pay_element_entries_f.assignment_id%type,
     p_effective_date  in date)
  return varchar2;

  function net_accrual
    (p_assignment_id      in pay_assignment_actions.assignment_id%type,
     p_plan_id            in pay_accrual_plans.accrual_plan_id%type,
     p_payroll_id         in pay_payroll_actions.payroll_id%type,
     p_business_group_id  in pay_accrual_plans.business_group_id%type,
     p_effective_date     in per_time_periods.end_date%type)
  return number;

  procedure current_and_ytd_balances
    (p_prepaid_tag	     in varchar,
     p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type,
     p_balance_name          in pay_balance_types.balance_name%type,
     p_person_id             in per_all_people_f.person_id%type,
     p_current_balance       out nocopy number,
     p_ytd_balance           out nocopy number);

  procedure current_and_ytd_balances
    (p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type,
     p_balance_name          in pay_balance_types.balance_name%type,
     p_person_id             in per_all_people_f.person_id%type,
     p_current_balance       out nocopy number,
     p_ytd_balance           out nocopy number);

  procedure balance_totals
    (p_prepaid_tag		     varchar,
     p_assignment_action_id          in pay_assignment_actions.assignment_action_id%type,
     p_person_id                     in per_all_people_f.person_id%type,
     p_gross_pay_current             out nocopy number,
     p_statutory_deductions_current  out nocopy number,
     p_other_deductions_current      out nocopy number,
     p_net_pay_current               out nocopy number,
     p_non_payroll_current           out nocopy number,
     p_gross_pay_ytd                 out nocopy number,
     p_statutory_deductions_ytd      out nocopy number,
     p_other_deductions_ytd          out nocopy number,
     p_net_pay_ytd                   out nocopy number,
     p_non_payroll_ytd               out nocopy number,
     p_employee_cpf_current          out nocopy number,
     p_employer_cpf_current          out nocopy number,
     p_cpf_total_current             out nocopy number,
     p_employee_cpf_ytd              out nocopy number,
     p_employer_cpf_ytd              out nocopy number,
     p_cpf_total_ytd                 out nocopy number);

  procedure balance_totals
    (p_assignment_action_id          in pay_assignment_actions.assignment_action_id%type,
     p_person_id                     in per_all_people_f.person_id%type,
     p_gross_pay_current             out nocopy number,
     p_statutory_deductions_current  out nocopy number,
     p_other_deductions_current      out nocopy number,
     p_net_pay_current               out nocopy number,
     p_non_payroll_current           out nocopy number,
     p_gross_pay_ytd                 out nocopy number,
     p_statutory_deductions_ytd      out nocopy number,
     p_other_deductions_ytd          out nocopy number,
     p_net_pay_ytd                   out nocopy number,
     p_non_payroll_ytd               out nocopy number,
     p_employee_cpf_current          out nocopy number,
     p_employer_cpf_current          out nocopy number,
     p_cpf_total_current             out nocopy number,
     p_employee_cpf_ytd              out nocopy number,
     p_employer_cpf_ytd              out nocopy number,
     p_cpf_total_ytd                 out nocopy number);

  function get_exchange_rate
    (p_from_currency 		in gl_daily_rates.from_currency%type,
     p_to_currency 		in gl_daily_rates.to_currency%type,
     eff_date 			in gl_daily_rates.conversion_date%type,
     p_business_group_id 	in pay_user_columns.business_group_id%type )
  return number;
  function get_tax_id
    ( p_assignment_action_id 	number)
  return number;

  procedure get_home_address
    (p_person_id      in  per_addresses.person_id%type,
     p_address_line1  out nocopy per_addresses.address_line1%type,
     p_address_line2  out nocopy per_addresses.address_line2%type,
     p_address_line3  out nocopy per_addresses.address_line3%type,
     p_town_city      out nocopy per_addresses.town_or_city%type,
     p_postal_code    out nocopy per_addresses.postal_code%type,
     p_country_name   out nocopy fnd_territories_tl.territory_short_name%type);

  procedure get_work_address
    (p_location_id    in  hr_locations.location_id%type,
     p_address_line1  out nocopy hr_locations.address_line_1%type,
     p_address_line2  out nocopy hr_locations.address_line_2%type,
     p_address_line3  out nocopy hr_locations.address_line_3%type,
     p_town_city      out nocopy hr_locations.town_or_city%type,
     p_postal_code    out nocopy hr_locations.postal_code%type,
     p_country_name   out nocopy fnd_territories_tl.territory_short_name%type);
  function business_currency_code
    (p_business_group_id  in hr_organization_units.business_group_id%type)
    return fnd_currencies.currency_code%type;

  function get_assignment_currency_code
    (p_assignment_id  in per_all_assignments_f.assignment_id%type,
    p_effective_date in pay_payroll_actions.effective_date%type)
    return fnd_currencies.currency_code%type;

   function get_payroll_currency_code
    (p_payroll_id     in pay_payrolls_f.payroll_id%type,
    p_effective_date in pay_payroll_actions.effective_date%type)
    return fnd_currencies.currency_code%type;

end pay_sg_soe;

/
