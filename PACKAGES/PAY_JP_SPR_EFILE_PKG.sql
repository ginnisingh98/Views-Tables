--------------------------------------------------------
--  DDL for Package PAY_JP_SPR_EFILE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_JP_SPR_EFILE_PKG" AUTHID CURRENT_USER as
/* $Header: pyjpspre.pkh 120.0.12010000.5 2009/12/16 02:33:33 keyazawa noship $ */
--
g_valid_term_flag varchar2(1) := 'Y';
--
c_valid_term_taxable_amt number := 300000;
c_char_set varchar2(30) := 'JA16SJIS';
c_file_prefix varchar2(6) := '315dat';
c_file_spliter varchar2(1) := '_';
c_file_extension varchar2(4) := '.txt';
c_arch_yes varchar2(1) := '*';
c_ass_yes varchar2(1) := 'Y';
c_delimiter varchar2(1) := ',';
--
c_form_number varchar2(3) := '315';
c_amend_flag varchar2(1) := '0';
c_unpaid_income varchar2(10) := '0';
c_uncollected_itax varchar2(10) := '0';
c_gen_collecting varchar2(1) := '0';
c_blue_proprietor varchar2(1) := '0';
c_immune varchar2(1) := '0';
c_desc_chr_len number := 100;
c_desc_chr_len_2009 number := 65;
--
g_payroll_action_id number;
g_session_date      date;
g_effective_soy     date;
g_effective_eoy     date;
g_effective_yyyy    number;
g_business_group_id number;
g_legislation_code  per_business_groups.legislation_code%type;
g_district_code     per_addresses.town_or_city%type;
g_organization_id   number;
g_assignment_set_id number;
g_request_id        number;
g_file_split        varchar2(1);
g_use_arch          varchar2(1);
g_kana_flag         varchar2(1);
--g_kana_flag                varchar2(1);
--g_process_assignments_flag varchar2(1);
g_remove_act        varchar2(1);
g_arch_pact_exist   varchar2(1);
--
g_file_prefix    varchar2(30);
g_file_extension varchar2(30);
--
g_del_file       varchar2(1);
g_show_act_debug varchar2(1);
g_show_debug     varchar2(1);
g_detail_debug   varchar2(1);
g_show_warning   varchar2(1);
g_show_summary   varchar2(1);
--
-- -------------------------------------------------------------------------
-- use in pay_magtape_generic cursor
-- -------------------------------------------------------------------------
level_cnt number;
--
-- -------------------------------------------------------------------------
-- csr_bg : unit of gen_xml_header
-- -------------------------------------------------------------------------
cursor csr_bg
is
select 1
from   dual;
--
-- -------------------------------------------------------------------------
-- csr_emp : unit of gen_xml_body
-- -------------------------------------------------------------------------
cursor csr_emp
is
select 'TRANSFER_ACT_ID=P',
       unit_v.assignment_action_id
from
(select /*+ ORDERED */
        proc_wic_v.assignment_action_id assignment_action_id,
        nvl(proc_pjsn_v.rep_district_code,proc_wic_v.town_or_city) district_code,
        proc_hoi.org_information1 itax_org_name,
        proc_wic_v.itax_organization_id itax_organization_id,
        lpad(proc_wic_v.employee_number,30,' ') employee_number
from
(select /*+ ORDERED */
proc_paa.assignment_action_id,
proc_pjwa.itax_organization_id,
decode(proc_padr.address_id,null,proc_padc.town_or_city,proc_padr.town_or_city) town_or_city,
proc_pp.employee_number
from   pay_payroll_actions proc_ppa,
       pay_assignment_actions proc_paa,
       pay_jp_wic_assacts_v proc_pjwa,
       pay_all_payrolls_f proc_pap,
       per_all_people_f proc_pp,
       per_addresses proc_padr,
       per_addresses proc_padc
where  nvl(pay_jp_spr_efile_pkg.g_arch_pact_exist,'N') = 'N'
and    proc_ppa.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
and    proc_paa.payroll_action_id = proc_ppa.payroll_action_id
and    proc_pjwa.assignment_action_id = proc_paa.source_action_id
and    proc_pjwa.assignment_id = proc_paa.assignment_id
and    proc_pjwa.business_group_id + 0 = pay_jp_spr_efile_pkg.g_business_group_id
and    proc_pjwa.effective_date
       between pay_jp_spr_efile_pkg.g_effective_soy and pay_jp_spr_efile_pkg.g_effective_eoy
and    proc_pjwa.itax_organization_id = nvl(pay_jp_spr_efile_pkg.g_organization_id,proc_pjwa.itax_organization_id)
and    proc_pap.payroll_id = proc_pjwa.payroll_id
and    proc_pjwa.effective_date
       between proc_pap.effective_start_date and proc_pap.effective_end_date
and    proc_pp.person_id = proc_pjwa.person_id
and    proc_pjwa.effective_date
       between proc_pp.effective_start_date and proc_pp.effective_end_date
and    proc_padr.person_id (+) = proc_pjwa.person_id
and    proc_padr.address_type (+) = 'JP_R'
and    nvl(proc_pjwa.actual_termination_date, add_months(trunc(proc_pjwa.effective_date, 'YYYY'), 12))
       between proc_padr.date_from (+) and nvl(proc_padr.date_to(+), hr_api.g_eot)
and    proc_padc.person_id (+) = proc_pjwa.person_id
and    proc_padc.address_type (+) = 'JP_C'
and    nvl(proc_pjwa.actual_termination_date, add_months(trunc(proc_pjwa.effective_date, 'YYYY'), 12))
       between proc_padc.date_from (+) and nvl(proc_padc.date_to(+), hr_api.g_eot)) proc_wic_v,
(select proc_pjsn_act.organization_id,
        proc_pjsn_act.district_code act_district_code,
        substrb(nvl(proc_pjsn_act.report_district_code,proc_pjsn_act.district_code),1,5) rep_district_code,
        proc_pjsn_rep.efile_exclusive_flag rep_efile_exclusive_flag
 from   pay_jp_swot_numbers proc_pjsn_rep,
        pay_jp_swot_numbers proc_pjsn_act
 where  proc_pjsn_rep.organization_id = proc_pjsn_act.organization_id
 and    proc_pjsn_rep.district_code = nvl(proc_pjsn_act.report_district_code,proc_pjsn_act.district_code)) proc_pjsn_v,
hr_organization_information proc_hoi
where  proc_pjsn_v.organization_id (+) = proc_wic_v.itax_organization_id
and    substrb(proc_pjsn_v.act_district_code(+),1,5) = proc_wic_v.town_or_city
and    nvl(proc_pjsn_v.rep_district_code,nvl(proc_wic_v.town_or_city,'X'))
       = nvl(pay_jp_spr_efile_pkg.g_district_code,nvl(proc_pjsn_v.rep_district_code,nvl(proc_wic_v.town_or_city,'X')))
and    nvl(proc_pjsn_v.rep_efile_exclusive_flag,'N') = 'N'
and    proc_hoi.organization_id (+) = proc_wic_v.itax_organization_id
and    proc_hoi.org_information_context(+) = 'JP_TAX_SWOT_INFO'
union
select arch_paa.assignment_action_id assignment_action_id,
       nvl(arch_pjsn_v.rep_district_code,arch_pjip.district_code) district_code,
       arch_pjia.employer_name itax_org_name,
       arch_pjip.itax_organization_id itax_organization_id,
       lpad(arch_pjip.employee_number,30,' ') employee_number
from
pay_payroll_actions arch_ppa,
pay_assignment_actions arch_paa,
pay_assignment_actions arch_ipaa,
pay_payroll_actions arch_ippa,
pay_jp_itax_person_v2 arch_pjip,
pay_jp_itax_arch_v2 arch_pjia,
(select arch_pjsn_act.organization_id,
        arch_pjsn_act.district_code act_district_code,
        substrb(nvl(arch_pjsn_act.report_district_code,arch_pjsn_act.district_code),1,5) rep_district_code,
        arch_pjsn_rep.efile_exclusive_flag rep_efile_exclusive_flag
 from   pay_jp_swot_numbers arch_pjsn_rep,
        pay_jp_swot_numbers arch_pjsn_act
 where  arch_pjsn_rep.organization_id = arch_pjsn_act.organization_id
 and    arch_pjsn_rep.district_code = nvl(arch_pjsn_act.report_district_code,arch_pjsn_act.district_code)) arch_pjsn_v
where  nvl(pay_jp_spr_efile_pkg.g_arch_pact_exist,'N') = 'Y'
and    arch_ppa.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
and    arch_paa.payroll_action_id = arch_ppa.payroll_action_id
and    arch_ipaa.assignment_id = arch_paa.assignment_id
and    arch_ippa.payroll_action_id = arch_ipaa.payroll_action_id
and    arch_ippa.business_group_id + 0 = pay_jp_spr_efile_pkg.g_business_group_id
and    arch_ippa.effective_date
       between pay_jp_spr_efile_pkg.g_effective_soy and pay_jp_spr_efile_pkg.g_effective_eoy
and    arch_ippa.action_type = 'X'
and    arch_ippa.report_type = 'JPTW'
and    arch_ippa.report_qualifier = 'JP'
and    arch_ippa.report_category = 'ARCHIVE'
and    arch_pjip.action_context_id = arch_ipaa.assignment_action_id
and    arch_pjip.itax_organization_id = nvl(pay_jp_spr_efile_pkg.g_organization_id,arch_pjip.itax_organization_id)
and    arch_pjia.action_context_id = arch_pjip.action_context_id
and    arch_pjia.effective_date = arch_pjip.effective_date
and    arch_pjia.assignment_action_id = arch_paa.source_action_id
and    arch_pjsn_v.organization_id (+) = arch_pjip.itax_organization_id
and    substrb(arch_pjsn_v.act_district_code(+),1,5) = arch_pjip.district_code
and    nvl(arch_pjsn_v.rep_district_code,nvl(arch_pjip.district_code,'X'))
       = nvl(pay_jp_spr_efile_pkg.g_district_code,nvl(arch_pjsn_v.rep_district_code,nvl(arch_pjip.district_code,'X')))
and    nvl(arch_pjsn_v.rep_efile_exclusive_flag,'N') = 'N') unit_v
order by
  unit_v.district_code,
  unit_v.itax_org_name,
  unit_v.itax_organization_id,
  unit_v.employee_number;
--
-- -------------------------------------------------------------------------
-- csr_asg_act : unit of gen_xml_footer
-- -------------------------------------------------------------------------
cursor csr_asg_act
is
select 1
from dual;
--
procedure set_file_prefix(
  p_file_prefix in varchar2);
--
procedure set_file_extension(
  p_file_extension in varchar2);
--
function default_file_name(
  p_district_code in varchar2)
return varchar2;
--
procedure set_detail_debug(
  p_yn in varchar2);
--
procedure del_file(
  p_request_id in number,
  p_file_name in varchar2 default null);
--
procedure range_cursor(
  p_payroll_action_id in number,
  p_sqlstr            out nocopy varchar2);
--
procedure assignment_action_creation(
  p_payroll_action_id in number,
  p_start_person_id   in number,
  p_end_person_id     in number,
  p_chunk_number      in number);
--
procedure archinit(
  p_payroll_action_id in number);
--
procedure gen_xml_header;
--
procedure gen_xml_body;
--
procedure gen_xml_footer;
--
procedure archive_data(
  p_assignment_action_id in number,
  p_effective_date       in date);
--
procedure deinitialize_code(
  p_payroll_action_id in number);
--
end pay_jp_spr_efile_pkg;

/
