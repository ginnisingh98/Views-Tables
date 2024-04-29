--------------------------------------------------------
--  DDL for Package PAY_FR_ARC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_FR_ARC_PKG" AUTHID CURRENT_USER as
/* $Header: pyfrarch.pkh 115.10 2004/01/16 08:57:17 hwinsor noship $ */
--
function get_parameter (
         p_parameter_string          in varchar2
        ,p_token                     in varchar2
        ,p_segment_number            in number default null)  return varchar2;
--
function get_balance_id (
         p_balance_name              in varchar2
        ,p_dimension                 in varchar2)             return number ;
--
procedure range_cursor(
      pactid                         in number
     ,sqlstr                         out nocopy varchar);
--
procedure action_creation(
      pactid                         in number
     ,stperson                       in number
     ,endperson                      in number
     ,chunk                          in number);
--
procedure archinit(
      p_payroll_action_id            in number);
--
procedure archive_code(
      p_assactid                     in number
     ,p_effective_date               in date);
--
procedure archive_code_sub(
      p_assactid                     in number
     ,p_effective_date               in date);
--
procedure deinitialize(
      p_payroll_action_id            in number);
--
procedure load_balances(
      p_assignment_action_id         in number
     ,p_archive_action_id            in number
     ,p_context_id                   in number
     ,p_totals_taxable_income        out nocopy number);
--
procedure load_holidays(
      p_assignment_id                in number
     ,p_person_id                    in number
     ,p_effective_date               in date
     ,p_assignment_action_id         in number
     ,p_establishment_id             in number
     ,p_business_group_id            in number);
--
procedure load_employee_dates(
      p_assignment_id                in number
     ,p_effective_date               in date
     ,p_assignment_action_id         in number
     ,p_latest_date_earned           in date
     ,p_asat_date                    out nocopy date
     ,p_payroll_id                   in number
     ,p_establishment_id             in number
     ,p_term_reason                  OUT nocopy varchar2
     ,p_term_atd                     OUT nocopy date
     ,p_term_lwd                     OUT nocopy date
     ,p_term_pay_schedule            OUT nocopy varchar2);
--
procedure load_employee(
      p_assignment_id                in number
     ,p_person_id                    in number
     ,p_asat_date                    in date
     ,p_assignment_action_id         in number
     ,p_latest_date_earned           in date
     ,p_establishment_id             in number
     ,p_ee_info_id                   out nocopy number);
--
procedure load_bank(
      p_assignment_action_id         in number
     ,p_assignment_id                in number
     ,p_totals_previous_advice       out nocopy number
     ,p_totals_this_advice           out nocopy number
     ,p_totals_net_advice            out nocopy number
     ,p_establishment_id             in number
     ,p_asat_date                    in date);
--
procedure load_messages(
      p_archive_assignment_action_id in number
     ,p_establishment_id             in number
     ,p_term_atd                     in date
     ,p_term_reason                  in varchar2);
--
procedure load_ee_rate_grouped_runs(
      p_archive_assignment_action_id in number
     ,p_assignment_id                in number
     ,p_latest_process_type          in varchar2
     ,p_total_gross_pay              out nocopy number
     ,p_reductions                   out nocopy number
     ,p_net_payments                 out nocopy number
     ,p_court_orders                 out nocopy number
     ,p_establishment_id             in number
     ,p_effective_date               in date
     ,p_termination_reason           in varchar2
     ,p_term_st_ele_id               in number
     ,p_term_ex_ele_id               in number
);
--
procedure load_deductions1(
      p_archive_assignment_action_id in number
     ,p_assignment_id                in number
     ,p_latest_process_type          in varchar2
     ,p_total_deduct_ee              out nocopy number
     ,p_total_deduct_er              out nocopy number
     ,p_total_charge_ee              out nocopy number
     ,p_total_charge_er              out nocopy number
     ,p_establishment_id             in number
     ,p_effective_date               in date);
procedure load_deductions(
      p_archive_assignment_action_id in number
     ,p_assignment_id                in number
     ,p_latest_process_type          in varchar2
     ,p_total_deduct_ee              out nocopy number
     ,p_total_deduct_er              out nocopy number
     ,p_total_charge_ee              out nocopy number
     ,p_total_charge_er              out nocopy number
     ,p_establishment_id             in number
     ,p_effective_date               in date);
--
procedure load_rate_grouped_runs(
      p_archive_assignment_action_id in number
     ,p_assignment_id                in number
     ,p_latest_process_type          in varchar2
     ,p_total_ee_net_deductions      out nocopy number
     ,p_establishment_id             in number
     ,p_total_gross_pay              in out nocopy number
     ,p_effective_date               in date);
--
procedure load_payslip_text (
      p_action_id                    in number);
--
procedure get_all_parameters (
      p_payroll_action_id            in number
     ,p_payroll_id                   out nocopy number
     ,p_assignment_id                out nocopy number
     ,p_assignment_set_id            out nocopy number
     ,p_business_group_id            out nocopy number
     ,p_start_date                   out nocopy date
     ,p_effective_date               out nocopy date);
--
-- Support objects
--
procedure get_latest_run_data(
      p_archive_action_id            in number
     ,p_assignment_id                in number
     ,p_establishment_id             in number
     ,p_date_earned                  out nocopy date
     ,p_latest_process_type          out nocopy varchar2
     ,p_latest_assignment_action_id  out nocopy number);
--
procedure load_organization_details(
      p_payroll_action_id            in number
     ,p_business_Group_id            in number
     ,p_payroll_id                   in number
     ,p_assignment_id                in number
     ,p_assignment_set_id            in number
     ,p_effective_date               in date
     ,p_start_date                   in date);
--
procedure get_instance_variables (
      p_assignment_action_id         in  number
     ,p_person_id                    out nocopy number
     ,p_establishment_id             out nocopy number
     ,p_assignment_id                out nocopy number
     ,p_payroll_id                   out nocopy number);
--
procedure write_archive(
          p_action_context_id             in number
         ,p_action_context_type           in varchar2
         ,p_rubric                        in varchar2
         ,p_rubric_sort                   in number
         ,p_tax_unit_id                   in number
         ,p_context_prefix                in varchar2
         ,p_action_information_category   in varchar2
         ,p_action_information4           in varchar2 default null
         ,p_action_information5           in varchar2 default null
         ,p_action_information6           in varchar2 default null
         ,p_action_information7           in varchar2 default null
         ,p_action_information8           in varchar2 default null
         ,p_action_information9           in varchar2 default null
         ,p_action_information10          in varchar2 default null
         ,p_action_information11          in varchar2 default null
         ,p_action_information12          in varchar2 default null
         ,p_action_information13          in varchar2 default null );
--
end PAY_FR_ARC_PKG;

 

/
