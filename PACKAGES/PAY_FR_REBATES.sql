--------------------------------------------------------
--  DDL for Package PAY_FR_REBATES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_FR_REBATES" AUTHID CURRENT_USER as
/* $Header: pyfrebat.pkh 115.7 2003/11/11 07:58:06 autiwari noship $ */
--
Procedure init_formula (p_formula_name in varchar2);
--
g_inputs   ff_exec.inputs_t;
g_outputs  ff_exec.outputs_t;
--
Function get_aubry_II_rebate (p_date_earned        in date
                             ,p_assignment_id      in number
                             ,p_process_type       in varchar2
                             ,p_tax_unit_id        in number
                             ,p_asg_action_id      in number
                             ,p_business_group_id  in number
                             ,p_aubry_I_used       in varchar2
                             ,p_robien_used        in varchar2
                             ,p_subject_to_ss_cont in number
                             ,p_hours_worked       in number
                             ,p_sick_pay           in number
                             ,p_absence_days       in number
                             ,p_aubry_II_rebate              out nocopy number
                             ,p_aubry_II_rebate_code         out nocopy varchar2
                             ,p_aubry_II_contribution_id     out nocopy number
                             ,p_aubry_II_zrr_rebate          out nocopy number
                             ,p_aubry_II_zrr_rebate_code     out nocopy varchar2
                             ,p_aubry_II_zrr_contribution_id out nocopy number
                             ,p_message                      out nocopy varchar2) return number;
--
Function get_aubry_I_rebate (p_date_earned        in date
                            ,p_assignment_id      in number
                            ,p_process_type       in varchar2
                            ,p_tax_unit_id        in number
                            ,p_mesg                    out nocopy varchar2
                            ,p_aubry_I_rebate          out nocopy number
                            ,p_aubry_I_rebate_code     out nocopy varchar2
                            ,p_aubry_I_contribution_id out nocopy number) return number;
--
Function get_robien_rebate (p_date_earned         in date
                           ,p_assignment_id       in number
                           ,p_process_type        in varchar2
                           ,p_tax_unit_id         in number
                           ,p_contributions_base  in number
                           ,p_mesg                    out nocopy varchar2
                           ,p_robien_rebate           out nocopy number
                           ,p_robien_rebate_code      out nocopy varchar2
                           ,p_robien_rebate_rate      out nocopy number
                           ,p_robien_contribution_id  out nocopy number) return number;
--
Function get_part_time_rebate (p_date_earned        in date
                              ,p_assignment_id      in number
                              ,p_process_type       in varchar2
                              ,p_tax_unit_id        in number
                              ,p_contributions_base in number
                              ,p_mesg                       out nocopy varchar2
                              ,p_part_time_rebate           out nocopy number
                              ,p_part_time_rebate_code      out nocopy varchar2
                              ,p_part_time_contribution_id  out nocopy number) return number;
--
Function get_ss_lower_rebate (p_date_earned        in date
                             ,p_assignment_id      in number
                             ,p_process_type       in varchar2
                             ,p_tax_unit_id        in number
                             ,p_business_group_id  in number
                             ,p_salary             in number
                             ,p_salary_excluding_absence in number
                             ,p_hours_worked       in number
                             ,p_absence_days       in number
                             ,p_mesg                     out nocopy varchar2
                             ,p_ss_lower_rebate          out nocopy number
                             ,p_ss_lower_rebate_code     out nocopy varchar2
                             ,p_ss_lower_contribution_id out nocopy number) return number;
--
Function valid_aubry_robien_dates (p_org_id             in number,
                                   p_information_type   in varchar2,
                                   p_date_from          in date,
                                   p_date_to            in date default null) return varchar2;
--
Function contribution_info (p_date_earned    in date
                           ,p_process_type   in varchar2
                           ,p_element_name   in varchar2
                           ,p_usage_type     in varchar2
                           ,p_contribution_id   out nocopy number
                           ,p_contribution_code out nocopy varchar2
                           ,mesg                out nocopy varchar2) return number;
--
Function get_eligibility (p_date_earned    in date
                         ,p_assignment_id  in number
                         ,p_process_type   in varchar2
                         ,p_tax_unit_id    in number
                         ,p_asg_action_id  in number
                         ,p_pay_action_id  in number
                         ,p_aubry_II_used  out nocopy varchar2
                         ,p_aubry_I_used   out nocopy varchar2
                         ,p_robien_used    out nocopy varchar2
                         ,p_part_time_used out nocopy varchar2
                         ,p_ss_lower_used  out nocopy varchar2
                         ,p_mesg           out nocopy varchar2
                         ,p_fillon_used    out nocopy varchar2
                         ,p_fillon_mesg    out nocopy varchar2
                         ,p_director_mesg  out nocopy varchar2
                         ,p_fillon_part_time_mesg
                                     out nocopy varchar2) return number;
--
Function get_prev_asg_hours (p_assignment_id        in number
                            ,p_payroll_action_id    in number
                            ,p_process_type        in varchar2
                            ,p_tax_unit_id         in number) return number;
--
end pay_fr_rebates;

 

/
