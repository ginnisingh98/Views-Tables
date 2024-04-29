--------------------------------------------------------
--  DDL for Package PAY_AU_SOE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_AU_SOE_PKG" AUTHID CURRENT_USER as
/* $Header: pyausoe.pkh 120.10.12010000.2 2009/12/21 17:27:12 pmatamsr ship $ */

  procedure get_home_address
    (p_person_id      in  per_addresses.person_id%type,
     p_address_line1  out NOCOPY per_addresses.address_line1%type,
     p_address_line2  out NOCOPY per_addresses.address_line2%type,
     p_address_line3  out NOCOPY per_addresses.address_line3%type,
     p_town_city      out NOCOPY per_addresses.town_or_city%type,
     p_postal_code    out NOCOPY per_addresses.postal_code%type,
     p_country_name   out NOCOPY fnd_territories_tl.territory_short_name%type);

  procedure get_work_address
    (p_location_id    in  hr_locations.location_id%type,
     p_address_line1  out NOCOPY hr_locations.address_line_1%type,
     p_address_line2  out NOCOPY hr_locations.address_line_2%type,
     p_address_line3  out NOCOPY hr_locations.address_line_3%type,
     p_town_city      out NOCOPY hr_locations.town_or_city%type,
     p_postal_code    out NOCOPY hr_locations.postal_code%type,
     p_country_name   out NOCOPY fnd_territories_tl.territory_short_name%type);

  function get_salary
    (p_pay_basis_id    in per_pay_bases.pay_basis_id%type,
     p_assignment_id   in pay_element_entries_f.assignment_id%type,
     p_effective_date  in date)
  return varchar2;

  function business_currency_code
    (p_business_group_id  in hr_organization_units.business_group_id%type)
  return fnd_currencies.currency_code%type;

/* Bug 4169557 - Introduced procedure for populating LE dimension Defined Balance ID's
*/
    procedure populate_defined_balances;

    procedure balance_totals
    (p_assignment_id               in per_all_assignments_f.assignment_id%type,
     p_assignment_action_id        in pay_assignment_actions.assignment_action_id%type,
     p_effective_date              in date,
     p_gross_this_pay             out NOCOPY number,
     p_other_deductions_this_pay  out NOCOPY number,
     p_tax_deductions_this_pay    out NOCOPY number,
     p_gross_ytd                  out NOCOPY number,
     p_other_deductions_ytd       out NOCOPY number,
     p_tax_deductions_ytd         out NOCOPY number,
     p_non_tax_allowances_run     out NOCOPY number,
     p_non_tax_allowances_ytd     out NOCOPY number,
     p_pre_tax_deductions_run     out NOCOPY number,
     p_pre_tax_deductions_ytd     out NOCOPY number,
     p_super_run                  out NOCOPY number,
     p_super_ytd                  out NOCOPY number,
     p_taxable_income_this_pay    out NOCOPY number,
     p_taxable_income_ytd         out NOCOPY number,
     p_direct_payments_run        out NOCOPY number,
     p_direct_payments_ytd        out NOCOPY number,
      p_get_le_level_bal          in varchar2  ,
      p_fetch_only_ytd_value      in varchar2);

    /* bug 3935483 2 new parameters added to balance_totals and final_balance_totals  p_get_le_level_bal  when  Y the le level balances,run and ytd, would be fetched
    p_fetch_only_ytd_value when  Y  ytd balances would be fetched and run balances would not be fetched*/

procedure get_asg_latest_pay(p_session_date in     date,
                 p_payroll_exists           in out NOCOPY varchar2,
                 p_assignment_action_id     in out NOCOPY number,
                 p_run_assignment_action_id in out NOCOPY number,
                 p_assignment_id            in     number,
                 p_payroll_id              out NOCOPY number,
                 p_payroll_action_id        in out NOCOPY number,
                 p_date_earned              in out NOCOPY varchar2,
                 p_time_period_id          out NOCOPY number,
                 p_period_name             out NOCOPY varchar2,
                 p_pay_advice_date         out NOCOPY date,
                 p_pay_advice_message      out NOCOPY varchar2);

procedure get_details (p_assignment_action_id in out NOCOPY number,
                      p_run_assignment_action_id in out NOCOPY number,
                      p_assignment_id        in out NOCOPY number,
                      p_payroll_id              out NOCOPY number,
                      p_payroll_action_id    in out NOCOPY number,
                      p_date_earned          in out NOCOPY date,
                      p_time_period_id          out NOCOPY number,
                      p_period_name             out NOCOPY varchar2,
                      p_pay_advice_date         out NOCOPY date,
                      p_pay_advice_message      out NOCOPY varchar2);
procedure final_balance_totals
    (p_assignment_id           in per_all_assignments_f.assignment_id%type,
     p_assignment_action_id    in pay_assignment_actions.assignment_action_id%type,
     p_effective_date              in date,
     p_gross_this_pay             out NOCOPY number,
     p_other_deductions_this_pay  out NOCOPY number,
     p_tax_deductions_this_pay    out NOCOPY number,
     p_gross_ytd                  out NOCOPY number,
     p_other_deductions_ytd       out NOCOPY number,
     p_tax_deductions_ytd         out NOCOPY number,
     p_non_tax_allow_this_pay     out NOCOPY number,
     p_non_tax_allow_ytd          out NOCOPY number,
     p_pre_tax_deductions_this_pay out NOCOPY number,
     p_pre_tax_deductions_ytd      out NOCOPY number,
     p_super_this_pay              out NOCOPY number,
     p_super_ytd                   out NOCOPY number,
     p_taxable_income_this_pay     out NOCOPY number,
     p_taxable_income_ytd          out NOCOPY number,
     p_direct_payments_this_pay    out NOCOPY number,
     p_direct_payments_ytd        out NOCOPY number,
     p_get_le_level_bal		   in varchar2 ,
     p_fetch_only_ytd_value       in varchar2);


function super_fund_name
    (p_source_id in  number,
     p_element_reporting_name in pay_element_types_f.reporting_name%type,
     p_date_earned in pay_payroll_actions.date_earned%type,
     p_assignment_action_id in pay_assignment_actions.assignment_action_id%type,
     p_assignment_id in per_all_assignments_f.assignment_id%type,
     p_element_entry_id in pay_element_entries_f.PERSONAL_PAYMENT_METHOD_ID%TYPE,
     p_business_group_id per_all_assignments_f.business_group_id%TYPE)

  return varchar2;

/* Bug 5591333 - Function is used to compute Hours for Elements.
*/

FUNCTION get_element_payment_hours
(
   p_assignment_action_id IN pay_assignment_actions.assignment_action_id%TYPE,
   p_element_type_id IN pay_element_entries_f.element_entry_id%TYPE,
   p_pay_bases_id    IN per_all_assignments_f.pay_basis_id%TYPE,
   p_run_result_id   IN pay_run_results.run_result_ID%TYPE,
   p_effective_date  IN pay_payroll_actions.effective_date%TYPE
)
RETURN NUMBER;

/* 5599310 */

FUNCTION get_element_payment_rate
(
   p_assignment_action_id IN pay_assignment_actions.assignment_action_id%TYPE,
   p_element_type_id IN pay_element_entries_f.element_entry_id%TYPE,
   p_run_result_id   IN pay_run_results.run_result_ID%TYPE,
   p_effective_date  IN pay_payroll_actions.effective_date%TYPE
)
RETURN NUMBER;

/* Bug 5597052 - Function added to compute Hours for pay_au_asg_leave_taken_v */

FUNCTION get_leave_taken_hours
(
   p_element_type_id IN pay_element_entries_f.element_entry_id%TYPE,
   p_run_result_id   IN pay_run_results.run_result_ID%TYPE,
   p_effective_date  IN pay_payroll_actions.effective_date%TYPE
)
RETURN NUMBER;

/*Bug 5689508 Function to get Currency Code */
FUNCTION get_currency_code
    (p_business_group_id  in hr_organization_units.business_group_id%type,
     p_payroll_id      in pay_payrolls_f.payroll_id%type,
     p_effective_date    in date)
  RETURN fnd_currencies.currency_code%type;

/*Bug 9221420 - Function to get payment effective date */
FUNCTION get_effective_date
    (p_assignment_action_id in pay_assignment_actions.assignment_action_id%TYPE)
RETURN pay_payroll_actions.effective_date%TYPE;

end pay_au_soe_pkg;

/
