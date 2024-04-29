--------------------------------------------------------
--  DDL for Package Body PAY_US_HR_HELPDESK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_HR_HELPDESK" AS
/* $Header: payushrhd.pkb 120.0.12010000.4 2009/04/20 05:33:52 sudedas noship $ */

procedure GET_USPAY_DETAILS (p_per_id number,
                             p_bg_id number,
                             p_eff_date date,
                             p_leg_code varchar2,
                             p_pyrl_dtls  out nocopy HR_PERSON_RECORD.PAYROLL_RECORD,
                             p_error out nocopy varchar2)
is

-- Cursor declaration for US Payroll details starts here

-- Cursor to fetch basic details for Payroll Archive process

cursor csr_uspay_req (l_person_id number,l_eff_date date) is
select distinct
 ppa.payroll_action_id
,paa.assignment_id
,paa.assignment_action_id
,paf.location_id
from pay_payroll_actions ppa
,pay_assignment_actions paa
,per_assignments_f paf
,per_people_f ppf
,hr_lookups hl
where ppa.action_type = 'X'
and  ppa.action_status = 'C'
and  ppa.report_type = hl.meaning
and  hl.lookup_type = 'PAYSLIP_REPORT_TYPES'
and  hl.lookup_code = 'US'
and  ppa.payroll_action_id = paa.payroll_action_id
and  paa.assignment_id = paf.assignment_id
and  paf.person_id = ppf.person_id
and  ppf.person_id = l_person_id
and  ppa.effective_date = (select max(ppa1.effective_date)
from pay_payroll_actions ppa1
,pay_assignment_actions paa1
,hr_lookups hl1
where ppa1.effective_date <= l_eff_date
and ppa1.action_type = 'X'
and ppa1.action_status = 'C'
and ppa1.report_type = hl1.meaning
and hl1.lookup_type = 'PAYSLIP_REPORT_TYPES'
and hl1.lookup_code = 'US'
and ppa1.payroll_action_id = paa1.payroll_action_id
and paa1.assignment_id = paa.assignment_id
and ppa1.business_group_id = ppa.business_group_id)
and ppa.effective_date between paf.effective_start_date and paf.effective_end_date;

-- Cursor to fetch Work Location State details

cursor csr_state_det(p_location_id number) is
select region_2,location_code,
(select state_name from pay_us_states where state_abbrev = region_2)
from hr_locations_all
where location_id = p_location_id;

-- Cursor to fetch legislation_code

cursor csr_leg_code(p_bus_grp_id number) is
select to_char(org_information9) from
hr_organization_information where organization_id = p_bus_grp_id
and org_information_context = 'Business Group Information';

-- Cursor to fetch run_type

cursor csr_run_type(p_assignment_action_id NUMBER) is
select prt.run_type_name
  from pay_assignment_actions paa_xfr
      ,pay_assignment_actions paa_prepay
      ,pay_payroll_actions ppa_prepay
      ,pay_run_types_f prt
 where paa_xfr.assignment_action_id = p_assignment_action_id
   and (INSTR(paa_xfr.serial_number, 'PY') <> 0
       or INSTR(paa_xfr.serial_number, 'UY') <> 0)
   and paa_xfr.source_action_id is not null
   and fnd_number.canonical_to_number(SUBSTR(paa_xfr.serial_number, 3)) = paa_prepay.assignment_action_id
   and paa_prepay.payroll_action_id = ppa_prepay.payroll_action_id
   and ppa_prepay.action_type in ('R', 'Q')
   and paa_prepay.run_type_id = prt.run_type_id
   and prt.legislation_code = 'US';

-- Cursor to fetch all required details on US Payroll by HR Helpdesk

cursor csr_uspay_det(p_asg_action_id number,p_asg_id number,l_eff_date date,p_state_code varchar2,p_state_desc varchar2,p_loc_name varchar2)
 is
SELECT
organization_name
,job
,to_char(payment_date,'YYYY-MM-DD')
,Period_type
,location_name
,employee_address1 || employee_address2 || employee_address3 || ' ' || employee_city || ' ' || employee_state || ' ' || employee_zip_code
,payroll_name
,'USD'
,to_char(ending_date,'YYYY-MM-DD')
,'Federal'
,(select status from pay_us_emp_w4dtl_action_info_v
where action_context_id = p_asg_action_id
and   tax_jurisdiction = 'Federal'
 and   trunc(effective_date) <= l_eff_date) STATUS

,(select exemptions from pay_us_emp_w4dtl_action_info_v
 where action_context_id = p_asg_action_id
 and   assignment_id = p_asg_id
 and   trunc(effective_date) <= l_eff_date
and   tax_jurisdiction = 'Federal')  EXEMPTIONS

,(select additional_tax_amount from pay_us_emp_w4dtl_action_info_v
 where action_context_id = p_asg_action_id
 and   assignment_id = p_asg_id
 and  trunc(effective_date) <= l_eff_date
 and   tax_jurisdiction = 'Federal')  ADDNL_TAX_AMOUNT

,(select override_tax_amount from pay_us_emp_w4dtl_action_info_v
 where action_context_id = p_asg_action_id
 and   assignment_id = p_asg_id
 and   trunc(effective_date) <= l_eff_date
 and   tax_jurisdiction = 'Federal')  OVERRIDE_TAX_AMOUNT

 ,(select override_tax_percentage from pay_us_emp_w4dtl_action_info_v
 where action_context_id = p_asg_action_id
 and   assignment_id = p_asg_id
 and   trunc(effective_date) <= l_eff_date
 and   tax_jurisdiction = 'Federal')  OVERRIDE_TAX_PERCENTAGE
 ,p_state_code

 ,(select exemptions from pay_us_emp_w4dtl_action_info_v
 where action_context_id = p_asg_action_id
 and   assignment_id = p_asg_id
 and   trunc(effective_date) <= l_eff_date
 and   tax_jurisdiction = p_state_desc)  STEXEMPTIONS

,(select additional_tax_amount from pay_us_emp_w4dtl_action_info_v
 where action_context_id = p_asg_action_id
 and   assignment_id = p_asg_id
 and   trunc(effective_date) <= l_eff_date
 and   tax_jurisdiction = p_state_desc)  STADDNL_TAX_AMOUNT

,(select override_tax_amount from pay_us_emp_w4dtl_action_info_v
 where action_context_id = p_asg_action_id
 and   assignment_id = p_asg_id
 and   trunc(effective_date) <= l_eff_date
 and   tax_jurisdiction = p_state_desc)  STOVERRIDE_TAX_AMOUNT

 ,(select override_tax_percentage from pay_us_emp_w4dtl_action_info_v
 where action_context_id = p_asg_action_id
 and   assignment_id = p_asg_id
 and   trunc(effective_date) <= l_eff_date
 and   tax_jurisdiction = p_state_desc)  STOVERRIDE_TAX_PERCENTAGE

,(select gross_earnings
 from pay_ac_emp_sum_action_info_v
 where action_context_id = p_asg_action_id
 and   action_information_category = 'AC SUMMARY CURRENT')  TOTAL_EARNINGS_CV

 ,(select (nvl(gross_earnings, 0) - nvl(pretax_deductions, 0))
 from pay_ac_emp_sum_action_info_v
 where action_context_id = p_asg_action_id
 and   action_information_category = 'AC SUMMARY CURRENT')  TAXABLE_GROSS_CV

 ,(select taxes
 from pay_ac_emp_sum_action_info_v
 where action_context_id = p_asg_action_id
 and   action_information_category = 'AC SUMMARY CURRENT')  TOTAL_TAXES_CV

 ,(select (nvl(pretax_deductions, 0) + nvl(after_tax_deductions, 0))
 from pay_ac_emp_sum_action_info_v
 where action_context_id = p_asg_action_id
 and   action_information_category = 'AC SUMMARY CURRENT')  TOTAL_DEDUCTIONS_CV

 ,(select net_pay
 from pay_ac_emp_sum_action_info_v
 where action_context_id = p_asg_action_id
 and   action_information_category = 'AC SUMMARY CURRENT')  NET_PAY_CV

 ,(select gross_earnings
 from pay_ac_emp_sum_action_info_v
 where action_context_id = p_asg_action_id
 and   action_information_category = 'AC SUMMARY YTD')  TOTAL_EARNINGS_YTD

 ,(select (nvl(gross_earnings, 0) - nvl(pretax_deductions, 0))
 from pay_ac_emp_sum_action_info_v
 where action_context_id = p_asg_action_id
 and   action_information_category = 'AC SUMMARY YTD')  TAXABLE_GROSS_YTD

 ,(select taxes
 from pay_ac_emp_sum_action_info_v
 where action_context_id = p_asg_action_id
 and   action_information_category = 'AC SUMMARY YTD')  TOTAL_TAXES_YTD

 ,(select (nvl(pretax_deductions, 0) + nvl(after_tax_deductions, 0))
 from pay_ac_emp_sum_action_info_v
 where action_context_id = p_asg_action_id
 and   action_information_category = 'AC SUMMARY YTD')  TOTAL_DEDUCTIONS_YTD

 ,(select net_pay
 from pay_ac_emp_sum_action_info_v
 where action_context_id = p_asg_action_id
 and   action_information_category = 'AC SUMMARY YTD')  NET_PAY_YTD

from pay_employee_action_info_v peai
where action_context_id = p_asg_action_id
and   assignment_id = p_asg_id
and   trunc(effective_date) <= l_eff_date
and   location_name = p_loc_name;

-- Cursor declaration for US Payroll details ends here

-- Variable declarations for US Payroll details starts here

p_location_name       varchar2(100);

p_assignment_id       per_all_assignments_f.assignment_id%type;
p_assg_action_id      pay_assignment_actions.assignment_action_id%type;
p_pyrl_action_id      pay_payroll_actions.payroll_action_id%type;

p_cnt                 number;

p_location_id         number;
p_state_code          varchar2(100);
p_state_desc          varchar2(100);
lv_run_typ_nm         pay_run_types_f.run_type_name%TYPE;

-- Variable declarations for US Payroll details ends here

begin
                   p_cnt := 1;

                    open  csr_uspay_req(p_per_id,p_eff_date);
                        loop
                        fetch csr_uspay_req into p_pyrl_action_id,p_assignment_id,p_assg_action_id,p_location_id;
                        exit when csr_uspay_req%notfound;

                        open csr_state_det(p_location_id);
                        fetch csr_state_det into p_state_code,p_location_name,p_state_desc;
                        close csr_state_det;

                        lv_run_typ_nm := NULL;

                        open csr_run_type(p_assg_action_id);
                        fetch csr_run_type into lv_run_typ_nm;
                        close csr_run_type;

                        if lv_run_typ_nm is NULL then
                           lv_run_typ_nm := 'Regular Standard Run';
                        end if;

                        p_pyrl_dtls(p_cnt).RUN_TYPE := lv_run_typ_nm;

                        open csr_uspay_det(p_assg_action_id,p_assignment_id,p_eff_date, p_state_code,p_state_desc,p_location_name);
                        fetch csr_uspay_det  into p_pyrl_dtls(p_cnt).COMPANY,
                            p_pyrl_dtls(p_cnt).JOB_TITLE,
                            p_pyrl_dtls(p_cnt).PAYMENT_DATE,
                            p_pyrl_dtls(p_cnt).PAY_FREQUENCY,
                            p_pyrl_dtls(p_cnt).TAX_LOCATION,
                            p_pyrl_dtls(p_cnt).ADDRESS,
                            p_pyrl_dtls(p_cnt).PAY_GROUP,
                            p_pyrl_dtls(p_cnt).CURRENCY_CODE,
                            p_pyrl_dtls(p_cnt).PERIOD_END,
                            p_pyrl_dtls(p_cnt).TAX_JURISDICTION,
                            p_pyrl_dtls(p_cnt).MARITAL_STATUS,
                            p_pyrl_dtls(p_cnt).FED_EXEMPTIONS,
                            p_pyrl_dtls(p_cnt).FED_ADDNL_TAX_AMOUNT,
                            p_pyrl_dtls(p_cnt).FED_OVERRIDE_TAX_AMOUNT,
                            p_pyrl_dtls(p_cnt).FED_OVERRIDE_TAX_PERCENTAGE,
                            p_pyrl_dtls(p_cnt).STATE_CODE,
                            p_pyrl_dtls(p_cnt).ST_EXEMPTIONS,
                            p_pyrl_dtls(p_cnt).ST_ADDNL_TAX_AMOUNT,
                            p_pyrl_dtls(p_cnt).ST_OVERRIDE_TAX_AMOUNT,
                            p_pyrl_dtls(p_cnt).ST_OVERRIDE_TAX_PERCENTAGE,
                            p_pyrl_dtls(p_cnt).TOTAL_EARNINGS_CV,
                            p_pyrl_dtls(p_cnt).TAX_GROSS_CV,
                            p_pyrl_dtls(p_cnt).TOTAL_TAXES_CV,
                            p_pyrl_dtls(p_cnt).TOTAL_DED_CV,
                            p_pyrl_dtls(p_cnt).TOTAL_NETPAY_CV,
                            p_pyrl_dtls(p_cnt).TOTAL_EARNINGS_YTD,
                            p_pyrl_dtls(p_cnt).TAX_GROSS_YTD,
                            p_pyrl_dtls(p_cnt).TOTAL_TAXES_YTD,
                            p_pyrl_dtls(p_cnt).TOTAL_DED_YTD,
                            p_pyrl_dtls(p_cnt).TOTAL_NETPAY_YTD;
                 exit when csr_uspay_det%notfound;
                        close csr_uspay_det;
                 p_pyrl_dtls(p_cnt).LEGISLATION_CODE := p_leg_code;
                        p_cnt := p_cnt+1;

                        end loop;
                        close csr_uspay_req;



exception when others
then
p_error := 'FROM US PAYROLL'||substr(SQLERRM,1,1500);
end GET_USPAY_DETAILS;

end PAY_US_HR_HELPDESK;

/
