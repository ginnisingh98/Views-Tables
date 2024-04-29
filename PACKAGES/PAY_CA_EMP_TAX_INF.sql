--------------------------------------------------------
--  DDL for Package PAY_CA_EMP_TAX_INF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CA_EMP_TAX_INF" AUTHID CURRENT_USER as
/* $Header: pycantax.pkh 120.2.12010000.5 2009/03/30 11:54:21 aneghosh ship $ */

procedure  get_province_code (p_assignment_id         in number,
                          p_session_date          in date,
                          p_res_province_code  out nocopy varchar2,
                          p_res_province_name  out nocopy varchar2,
                          p_work_province_code out nocopy varchar2,
                          p_work_province_name out nocopy varchar2,
                          p_res_inf_flag              in varchar2,
                          p_work_inf_flag              in varchar2);

procedure  create_default_tax_record (p_assignment_id     in number,
                                   p_effective_start_date out nocopy date,
                                   p_effective_end_date   out nocopy date,
                                   p_effective_date       in date,
                                   p_business_group_id    in number,
                                   p_legislation_code     in varchar2,
                                   p_work_province        in varchar2,
                                   p_ret_code             out nocopy number,
                                   p_ret_text             out nocopy varchar2);

/*****************************************************************************
Delete_fed_tax_rule procedure calls
    "pay_ca_emp_fedtax_inf_api.delete_ca_emp_fedtax_inf" procedure for updating
    "Effective_End_Date" of tax records in PAY_CA_EMP_FED_TAX_INFO_F table.

    "pay_ca_emp_prvtax_inf_api.delete_ca_emp_prvtax_inf" procedure for updating
    "Effective_End_Date" of tax records in PAY_CA_EMP_PROV_TAX_INFO_F table.

*****************************************************************************/

procedure   delete_fed_tax_rule (p_effective_date         in     date,
                                 p_datetrack_delete_mode  in     varchar2,
                                 p_assignment_id          in     number,
                                 p_delete_routine         in     varchar2,
                                 p_effective_start_date   out nocopy date,
                                 p_effective_end_date     out nocopy date,
                                 p_object_version_number  out nocopy number);

/*****************************************************************************
    Maintain_ca_employee_taxes procedure fetches "Assignment_id"
    values for the given "period_of_service_id"
    and calls Delete_fed_tax_rule procedure.
*****************************************************************************/

procedure maintain_ca_employee_taxes(
                            p_period_of_service_id     in  number,
                            p_effective_date           in  date,
                            p_datetrack_mode           in  varchar2  default null,
                            p_delete_routine           in  varchar2  default null);

procedure delete_tax_record(
                            p_period_of_service_id     in  number,
                            p_final_process_date           in  date);

function get_basic_exemption(p_effective_date date,
                             p_province   varchar2 DEFAULT NULL) return number;

procedure get_min_asg_start_date(p_assignment_id in number,
                                 p_min_start_date out nocopy date) ;

function get_tax_detail_num(p_assignment_id in Number,
               p_effective_start_date in date,
               p_effective_end_date in date,
               p_effective_date in date,
               p_info_type  in VARCHAR2) return number;

PRAGMA RESTRICT_REFERENCES(get_tax_detail_num,WNDS,WNPS);

function get_tax_detail_char(p_assignment_id in Number,
               p_effective_start_date in date,
               p_effective_end_date in date,
               p_effective_date in date,
               p_info_type  in VARCHAR2) return varchar2;

PRAGMA RESTRICT_REFERENCES(get_tax_detail_char,WNDS,WNPS);

function get_tax_detail_dfs(p_assignment_id in Number,
               p_effective_start_date in date,
               p_effective_end_date in date,
               p_effective_date in date,
               p_info_type  in VARCHAR2) return varchar2;


PRAGMA RESTRICT_REFERENCES(get_tax_detail_dfs,WNDS,WNPS);

function get_prov_tax_detail_num(p_assignment_id in Number,
               p_effective_start_date in date,
               p_effective_end_date in date,
               p_effective_date in date,
               p_province_abbrev in VARCHAR2,
               p_info_type  in VARCHAR2) return number;

PRAGMA RESTRICT_REFERENCES(get_prov_tax_detail_num,WNDS,WNPS);

function get_prov_tax_detail_char(p_assignment_id in Number,
               p_effective_start_date in date,
               p_effective_end_date in date,
               p_effective_date in date,
               p_province_abbrev in varchar2,
               p_info_type  in VARCHAR2) return VARCHAR2;

PRAGMA RESTRICT_REFERENCES(get_prov_tax_detail_char,WNDS,WNPS);

function get_prov_tax_detail_dfs(p_assignment_id in Number,
               p_effective_start_date in date,
               p_effective_end_date in date,
               p_effective_date in date,
               p_province_abbrev in varchar2,
               p_info_type  in VARCHAR2) return VARCHAR2;


PRAGMA RESTRICT_REFERENCES(get_prov_tax_detail_dfs,WNDS,WNPS);

function get_address(p_person_id       in Number,
                     p_effective_date  in date,
                     address_line_no   in number
                     ) return VARCHAR2;
PRAGMA RESTRICT_REFERENCES(get_address,WNDS,WNPS);

function get_salary_basis(p_salary_basis_id in Number) return VARCHAR2;
PRAGMA RESTRICT_REFERENCES(get_salary_basis,WNDS,WNPS);

function get_base_salary(p_assignment_id in Number,
                         p_effective_date in date,
                         p_salary_basis_id in number) return VARCHAR2;
PRAGMA RESTRICT_REFERENCES(get_base_salary,WNDS,WNPS);

function get_summary_info(p_assignment_action_id in Number,
                         p_information_type in varchar2,
                         p_dimension in varchar2) return NUMBER;
PRAGMA RESTRICT_REFERENCES(get_summary_info,WNDS);

function check_age_under18_or_over70(p_payroll_action_id in Number,
                         p_date_of_birth in Date) return VARCHAR2;
PRAGMA RESTRICT_REFERENCES(check_age_under18_or_over70,WNDS);

function check_age_under18(p_payroll_action_id in Number,
                         p_date_of_birth in Date) return VARCHAR2;
PRAGMA RESTRICT_REFERENCES(check_age_under18,WNDS);

function retro_across_calendar_years(p_element_entry_id  in number,
                                     p_payroll_action_id in number)
return varchar2;
PRAGMA RESTRICT_REFERENCES(retro_across_calendar_years,WNDS);

function check_ei_exempt(p_roe_assignment_id in Number,
                         p_roe_date in Date) return VARCHAR2;

end pay_ca_emp_tax_inf;

/
