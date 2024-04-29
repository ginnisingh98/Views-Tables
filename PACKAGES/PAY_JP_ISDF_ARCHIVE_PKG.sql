--------------------------------------------------------
--  DDL for Package PAY_JP_ISDF_ARCHIVE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_JP_ISDF_ARCHIVE_PKG" AUTHID CURRENT_USER as
/* $Header: pyjpisfc.pkh 120.2.12010000.1 2008/07/27 22:59:29 appldev ship $ */
--
g_archive_default_flag varchar2(1);
g_copy_archive_pact_id number;
--
type t_li_info_rec is record(
  assignment_extra_info_id  per_assignment_extra_info.assignment_extra_info_id%type,
  aei_object_version_number per_assignment_extra_info.object_version_number%type,
  info_type                 hr_organization_information.org_information_context%type,
  ins_class                 per_assignment_extra_info.aei_information1%type,
  ins_comp_code             per_assignment_extra_info.aei_information2%type,
  ins_comp_name             hr_organization_information.org_information2%type,
  calc_prem_ff              hr_organization_information.org_information3%type,
  lig_prem_bal              hr_organization_information.org_information4%type,
  lig_prem_mth_ele          hr_organization_information.org_information5%type,
  lig_prem_bon_ele          hr_organization_information.org_information6%type,
  lip_prem_bal              hr_organization_information.org_information7%type,
  lip_prem_mth_ele          hr_organization_information.org_information8%type,
  lip_prem_bon_ele          hr_organization_information.org_information9%type,
  start_date                date,
  end_date                  date,
  ins_type                  per_assignment_extra_info.aei_information5%type,
  ins_period_start_date     date,
  ins_period                per_assignment_extra_info.aei_information6%type,
  contractor_name           per_assignment_extra_info.aei_information7%type,
  beneficiary_name          per_assignment_extra_info.aei_information8%type,
  beneficiary_relship       per_assignment_extra_info.aei_information9%type,
  linc_prem                 number);
--
type t_ai_info_rec is record(
  assignment_extra_info_id  per_assignment_extra_info.assignment_extra_info_id%type,
  aei_object_version_number per_assignment_extra_info.object_version_number%type,
  info_type                 hr_organization_information.org_information_context%type,
  ins_class                 per_assignment_extra_info.aei_information13%type,
  ins_term_type             per_assignment_extra_info.aei_information1%type,
  ins_comp_code             per_assignment_extra_info.aei_information2%type,
  ins_comp_name             hr_organization_information.org_information2%type,
  calc_prem_ff              hr_organization_information.org_information3%type,
  eqi_prem_bal              hr_organization_information.org_information4%type,
  eqi_prem_mth_ele          hr_organization_information.org_information5%type,
  eqi_prem_bon_ele          hr_organization_information.org_information6%type,
  ai_prem_bal               hr_organization_information.org_information7%type,
  ai_prem_mth_ele           hr_organization_information.org_information8%type,
  ai_prem_bon_ele           hr_organization_information.org_information9%type,
  start_date                date,
  end_date                  date,
  ins_type                  per_assignment_extra_info.aei_information5%type,
  ins_period                per_assignment_extra_info.aei_information6%type,
  contractor_name           per_assignment_extra_info.aei_information7%type,
  beneficiary_name          per_assignment_extra_info.aei_information8%type,
  beneficiary_relship       per_assignment_extra_info.aei_information9%type,
  maturity_repayment        per_assignment_extra_info.aei_information10%type,
  annual_prem               number);
--
type t_spouse_rec is record(
  spouse_type         varchar2(60),
  widow_type          varchar2(60),
  spouse_dct_exclude  varchar2(60),
  spouse_income_entry number);
--
type t_entry_rec is record(
  ins_entry_cnt                number,
  ins_datetrack_update_mode    varchar2(60),
  ins_element_entry_id         number,
  ins_ee_object_version_number number,
  life_gen_ins_prem            number,
  life_pens_ins_prem           number,
  nonlife_long_ins_prem        number,
  nonlife_short_ins_prem       number,
  earthquake_ins_prem          number,
  is_entry_cnt                 number,
  is_datetrack_update_mode     varchar2(60),
  is_element_entry_id          number,
  is_ee_object_version_number  number,
  social_ins_prem              number,
  mutual_aid_prem              number,
  spouse_income                number,
  sp_dct_exclude               varchar2(60),
  national_pens_ins_prem       number);
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
procedure archive_data(
  p_assignment_action_id in number,
  p_effective_date       in date);
--
procedure deinitialize_code(
  p_payroll_action_id in number);
--
-- init_pact,init_assact,ee_datetrack_update_mode,fetch_entry,archive_assact are called from pay_jp_isdf_ss_pkg
procedure init_pact(
  p_payroll_action_id in number);
--
procedure init_assact(
  p_assignment_action_id in number,
  p_assignment_id        in number);
--
function ee_datetrack_update_mode(
  p_element_entry_id     in number,
  p_effective_start_date in date,
  p_effective_end_date   in date,
  p_effective_date       in date)
return varchar2;
--
procedure fetch_entry(
  p_assignment_id     in number,
  p_business_group_id in number,
  p_effective_date    in date,
  p_entry_rec         out nocopy t_entry_rec);
--
procedure archive_assact(
  p_assignment_action_id in number,
  p_assignment_id        in number);
--
end pay_jp_isdf_archive_pkg;

/
