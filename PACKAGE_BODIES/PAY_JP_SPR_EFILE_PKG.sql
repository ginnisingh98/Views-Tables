--------------------------------------------------------
--  DDL for Package Body PAY_JP_SPR_EFILE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_JP_SPR_EFILE_PKG" as
/* $Header: pyjpspre.pkb 120.0.12010000.6 2009/12/16 02:34:50 keyazawa noship $ */
--
c_package  constant varchar2(30) := 'pay_jp_spr_efile_pkg.';
g_debug    boolean := hr_utility.debug_enabled;
--
c_eol varchar2(30) := fnd_global.local_chr(10);
--
g_bg_itax_dpnt_ref_type  varchar2(150);
g_ass_set_formula_id     number;
g_ass_set_amendment_type hr_assignment_set_amendments.include_or_exclude%type;
g_file_dir fnd_concurrent_processes.plsql_dir%type;
--
g_warning_exist varchar2(1);
g_warning_header varchar2(1);
--
type t_per_rec is record(
  person_id number,
  assignment_id number,
  assignment_action_id number,
  ass_cnt number);
type t_per_tbl is table of t_per_rec index by binary_integer;
g_per_ind_tbl t_per_tbl;
--
type t_ass_rec is record(
  person_id            number,
  assignment_id        number,
  assignment_action_id number,
  effective_date       date,
  spr_term_valid       number,
  include_or_exclude hr_assignment_set_amendments.include_or_exclude%type);
type t_ass_tbl is table of t_ass_rec index by binary_integer;
g_ass_tbl t_ass_tbl;
g_ass_ind_tbl t_ass_tbl;
--
type t_number_tbl is table of number index by binary_integer;
g_assact_tbl t_number_tbl;
--
type t_data_rec is record(
  mag_assignment_action_id       number,
  assignment_action_id           number,
  assignment_id                  number,
  action_sequence                number,
  effective_date                 date,
  date_earned                    date,
  itax_organization_id           number,
  itax_category                  pay_jp_pre_tax.itax_category%type,
  itax_yea_category              pay_jp_pre_tax.itax_yea_category%type,
  dpnt_ref_type                  pay_all_payrolls_f.prl_information1%type,
  dpnt_effective_date            date,
  person_id                      number,
  sex                            per_all_people_f.sex%type,
  date_of_birth                  date,
  leaving_reason                 per_periods_of_service.leaving_reason%type,
  last_name                      per_all_people_f.per_information18%type,
  last_name_kana                 per_all_people_f.last_name%type,
  first_name                     per_all_people_f.per_information19%type,
  first_name_kana                per_all_people_f.first_name%type,
  employment_category            per_all_assignments_f.employment_category%type,
  district_code                  per_addresses.town_or_city%type,
  address                        varchar2(800),
  address_kana                   varchar2(800),
  address_jp                     varchar2(1),
  full_name                      varchar2(400),
  actual_termination_date        date,
  date_start                     date,
  full_name_kana                 varchar2(400),
  employee_number                per_all_people_f.employee_number%type,
  swot_number                    pay_jp_swot_numbers.swot_number%type,
  output_file_name               pay_jp_swot_numbers.output_file_name%type,
  itax_org_address               varchar2(500),
  itax_org_address_kana          varchar2(500),
  itax_org_name                  hr_organization_information.org_information1%type,
  itax_org_name_kana             hr_organization_information.org_information2%type,
  itax_org_phone                 hr_organization_information.org_information12%type,
  itax_org_serial1               hr_organization_information.org_information4%type,
  itax_org_serial2               hr_organization_information.org_information5%type,
  taxable_income                 number,
  net_taxable_income             number,
  total_income_exempt            number,
  withholding_itax               number,
  spouse_special_exempt          number,
  social_insurance_premium       number,
  mutual_aid_premium             number,
  life_insurance_premium_exempt  number,
  damage_insurance_premium_exem  number,
  housing_tax_reduction          number,
  private_pension_premium        number,
  spouse_net_taxable_income      number,
  long_damage_insurance_premium  number,
  disaster_tax_reduction         number,
  dependent_spouse_exists_kou    pay_action_information.action_information1%type,
  dependent_spouse_no_exist_kou  pay_action_information.action_information2%type,
  dependent_spouse_exists_otsu   pay_action_information.action_information3%type,
  dependent_spouse_no_exist_otsu pay_action_information.action_information4%type,
  aged_spouse_exists             pay_action_information.action_information5%type,
  num_specifieds_kou             number,
  num_specifieds_otsu            number,
  num_aged_parents_partial       number,
  num_ageds_kou                  number,
  num_ageds_otsu                 number,
  num_dependents_kou             number,
  num_dependents_otsu            number,
  num_special_disableds_partial  number,
  num_special_disableds          number,
  num_disableds                  number,
  husband_exists                 pay_action_information.action_information16%type,
  minor                          pay_action_information.action_information17%type,
  otsu                           pay_action_information.action_information18%type,
  special_disabled               pay_action_information.action_information19%type,
  disabled                       pay_action_information.action_information20%type,
  aged                           pay_action_information.action_information21%type,
  widow                          pay_action_information.action_information22%type,
  special_widow                  pay_action_information.action_information23%type,
  widower                        pay_action_information.action_information24%type,
  working_student                pay_action_information.action_information25%type,
  deceased_termination           pay_action_information.action_information26%type,
  disastered                     pay_action_information.action_information27%type,
  foreigner                      pay_action_information.action_information28%type,
  prev_job_employer_name         pay_action_information.action_information20%type,
  prev_job_employer_name_kana    pay_action_information.action_information19%type,
  prev_job_employer_add          varchar2(500),
  prev_job_employer_add_kana     varchar2(500),
  prev_job_foreign_address       pay_action_information.action_information21%type,
  prev_job_taxable_income        number,
  prev_job_itax                  number,
  prev_job_si_prem               number,
  prev_job_termination_date      date,
  prev_job_termination_year      number,
  prev_job_termination_month     number,
  prev_job_termination_day       number,
  hld_residence_date_1_date      date,
  hld_residence_date_1_year      number,
  hld_residence_date_1_month     number,
  hld_residence_date_1_day       number,
  hld_loan_count                 number,
  hld_payable_loan               number,
  hld_loan_type_1                pay_action_information.action_information4%type,
  hld_loan_balance_1             number,
  hld_residence_date_2_date      date,
  hld_residence_date_2_year      number,
  hld_residence_date_2_month     number,
  hld_residence_date_2_day       number,
  hld_loan_type_2                pay_action_information.action_information7%type,
  hld_loan_balance_2             number,
  original_description           varchar2(32767),
  original_description_kana      varchar2(32767),
  wtm_system_desc                varchar2(500),
  wtm_system_desc_kana           varchar2(500),
  wtm_user_desc                  varchar2(500),
  wtm_user_desc_kana             varchar2(500));
type t_data_tbl is table of t_data_rec index by binary_integer;
--
type t_body_rec is record(
  mag_assignment_action_id       number,
  assignment_action_id           number,
  assignment_id                  number,
  action_sequence                number,
  effective_date                 date,
  date_earned                    date,
  itax_organization_id           number,
  itax_category                  pay_jp_pre_tax.itax_category%type,
  itax_yea_category              pay_jp_pre_tax.itax_yea_category%type,
  dpnt_ref_type                  pay_all_payrolls_f.prl_information1%type,
  dpnt_effective_date            date,
  person_id                      number,
  sex                            per_all_people_f.sex%type,
  date_of_birth                  date,
  leaving_reason                 per_periods_of_service.leaving_reason%type,
  last_name                      per_all_people_f.per_information18%type,
  last_name_kana                 per_all_people_f.last_name%type,
  first_name                     per_all_people_f.per_information19%type,
  first_name_kana                per_all_people_f.first_name%type,
  employment_category            per_all_assignments_f.employment_category%type,
  address                        varchar2(800),
  address_kana                   varchar2(800),
  address_jp                     varchar2(1),
  full_name                      varchar2(400),
  full_name_kana                 varchar2(400),
  actual_termination_date        date,
  date_start                     date,
  itax_org_address               varchar2(500),
  itax_org_address_kana          varchar2(500),
  itax_org_name                  hr_organization_information.org_information1%type,
  itax_org_name_kana             hr_organization_information.org_information2%type,
  dependent_spouse_exists_kou    pay_action_information.action_information1%type,
  dependent_spouse_no_exist_kou  pay_action_information.action_information2%type,
  dependent_spouse_exists_otsu   pay_action_information.action_information3%type,
  dependent_spouse_no_exist_otsu pay_action_information.action_information4%type,
  aged_spouse_exists             pay_action_information.action_information5%type,
  husband_exists                 pay_action_information.action_information16%type,
  minor                          pay_action_information.action_information17%type,
  otsu                           pay_action_information.action_information18%type,
  special_disabled               pay_action_information.action_information19%type,
  disabled                       pay_action_information.action_information20%type,
  aged                           pay_action_information.action_information21%type,
  widow                          pay_action_information.action_information22%type,
  special_widow                  pay_action_information.action_information23%type,
  widower                        pay_action_information.action_information24%type,
  working_student                pay_action_information.action_information25%type,
  deceased_termination           pay_action_information.action_information26%type,
  disastered                     pay_action_information.action_information27%type,
  foreigner                      pay_action_information.action_information28%type,
  prev_job_employer_name         pay_action_information.action_information20%type,
  prev_job_employer_name_kana    pay_action_information.action_information19%type,
  prev_job_employer_add          varchar2(500),
  prev_job_employer_add_kana     varchar2(500),
  prev_job_employer_add_jp       pay_action_information.action_information21%type,
  pjob_termination_date          date,
  hld_payable_loan               pay_action_information.action_information1%type,
  hld_loan_count                 pay_action_information.action_information2%type,
  hld_residence_date_1           date,
  hld_loan_type_1                pay_action_information.action_information4%type,
  hld_loan_balance_1             pay_action_information.action_information5%type,
  hld_residence_date_2           date,
  hld_loan_type_2                pay_action_information.action_information7%type,
  hld_loan_balance_2             pay_action_information.action_information8%type,
  original_description           varchar2(32767),
  original_description_kana      varchar2(32767),
  long_description               varchar2(32767),
  wtm_system_desc                varchar2(500),
  wtm_system_desc_kana           varchar2(500),
  wtm_user_desc                  varchar2(500),
  wtm_user_desc_kana             varchar2(500),
  spr_term_valid                 number,
  --
  output_file_name               pay_jp_swot_numbers.output_file_name%type,
  file_ind                       number,
  --
  o_form_number                  varchar2(3),
  o_itax_org_serial1             hr_organization_information.org_information4%type,
  o_itax_org_cnt                 number,
  o_itax_org_address             varchar2(500),
  o_itax_org_name                hr_organization_information.org_information1%type,
  o_itax_org_phone               hr_organization_information.org_information12%type,
  o_itax_org_serial2             hr_organization_information.org_information5%type,
  o_itax_hq_address              varchar2(500),
  o_itax_hq_name                 hr_organization_information.org_information1%type,
  o_amend_flag                   varchar2(1),
  o_target_yy                    varchar2(2),
  o_address                      varchar2(800),
  o_address_jp                   varchar2(1),
  o_full_name                    varchar2(400),
  o_position                     varchar2(15),
  o_assortment                   fnd_new_messages.message_text%type,
  o_taxable_income               number,
  o_unpaid_income                number,
  o_net_taxable_income           number,
  o_total_income_exempt          number,
  o_withholding_itax             number,
  o_uncollected_itax             number,
  o_dep_spouse                   varchar2(1),
  o_aged_spouse                  varchar2(1),
  o_spouse_sp_exempt             varchar2(30),
  o_num_specifieds_kou           varchar2(30),
  o_num_specifieds_otsu          varchar2(30),
  o_num_ageds_kou                varchar2(30),
  o_num_aged_parents_lt          varchar2(30),
  o_num_ageds_otsu               varchar2(30),
  o_num_deps_kou                 varchar2(30),
  o_num_deps_otsu                varchar2(30),
  o_num_svr_disableds            varchar2(30),
  o_num_svr_disableds_lt         varchar2(30),
  o_num_disableds                varchar2(30),
  o_si_prem                      number,
  o_mutual_aid_prem              number,
  o_li_prem_exempt               number,
  o_ai_prem_exempt               number,
  o_housing_tax_reduction        number,
  o_pp_prem                      number,
  o_spouse_net_taxable_income    number,
  o_long_ai_prem                 number,
  o_birth_date_era               varchar2(1),
  o_birth_date_yy                varchar2(2),
  o_birth_date_mm                varchar2(2),
  o_birth_date_dd                varchar2(2),
  o_husband_exists               varchar2(1),
  o_minor                        varchar2(1),
  o_otsu                         varchar2(1),
  o_svr_disabled                 varchar2(1),
  o_disabled                     varchar2(1),
  o_aged                         varchar2(1),
  o_widow                        varchar2(1),
  o_widower                      varchar2(1),
  o_working_student              varchar2(1),
  o_deceased_termination         varchar2(1),
  o_disastered                   varchar2(1),
  o_foreigner                    varchar2(1),
  o_employed                     varchar2(1),
  o_employed_yy                  varchar2(2),
  o_employed_mm                  varchar2(2),
  o_employed_dd                  varchar2(2),
  o_pjob_itax_org_address        varchar2(500),
  o_pjob_itax_org_address_jp     varchar2(1),
  o_pjob_itax_org_full_name      pay_action_information.action_information20%type,
  o_pjob_taxable_income          number,
  o_pjob_itax                    number,
  o_pjob_si_prem                 number,
  o_disaster_tax_reduction       number,
  o_pjob_termination_date_yy     varchar2(2),
  o_pjob_termination_date_mm     varchar2(2),
  o_pjob_termination_date_dd     varchar2(2),
  o_hld_residence_date_1_yy      varchar2(2),
  o_hld_residence_date_1_mm      varchar2(2),
  o_hld_residence_date_1_dd      varchar2(2),
  o_hld_loan_count               number,
  o_hld_payable_loan             number,
  o_hld_loan_type_1              varchar2(2),
  o_hld_loan_balance_1           number,
  o_hld_residence_date_2_yy      varchar2(2),
  o_hld_residence_date_2_mm      varchar2(2),
  o_hld_residence_date_2_dd      varchar2(2),
  o_hld_loan_type_2              varchar2(2),
  o_hld_loan_balance_2           number,
  o_description                  varchar2(32767),
  o_gen_collecting               varchar2(1),
  o_blue_proprietor              varchar2(1),
  o_immune                       varchar2(1),
  o_full_name_kana               varchar2(400),
  o_employee_number              per_all_people_f.employee_number%type,
  o_district_code                per_addresses.town_or_city%type,
  o_swot_number                  pay_jp_swot_numbers.swot_number%type);
type t_body_tbl is table of t_body_rec index by binary_integer;
g_body_tbl t_body_tbl;
--
type t_file_rec is record(
  file_name varchar2(80),
  file_out utl_file.file_type);
type t_file_tbl is table of t_file_rec index by binary_integer;
g_file_tbl t_file_tbl;
--
type t_summary_rec is record(
  file_name     varchar2(80),
  district_code per_addresses.town_or_city%type,
  itax_org_cnt  number,
  emp_cnt       number,
  term_emp_cnt  number);
type t_summary_tbl is table of t_summary_rec index by binary_integer;
g_summary_tbl t_summary_tbl;
--
-- -------------------------------------------------------------------------
-- query for proc_ass in assignment_action_creation
-- -------------------------------------------------------------------------
c_proc_ass_select_clause varchar2(32767)
:= 'select /*+ ORDERED */
wic_v.person_id,
wic_v.assignment_id,
wic_v.assignment_action_id,
wic_v.effective_date,
wic_v.spr_term_valid';
--
c_proc_ass_from_clause varchar2(32767)
:= '(select /*+ ORDERED
                USE_NL(PADR, PADC)
                INDEX(PADR PER_ADDRESSES_N2)
                INDEX(PADC PER_ADDRESSES_N2) */
pjwa_v.pa_person_id person_id,
pjwa_v.assignment_id,
pjwa_v.assignment_action_id,
pjwa_v.effective_date,
pjwa_v.itax_organization_id,
decode(padr.address_id,null,padc.town_or_city,padr.town_or_city) town_or_city,
pjwa_v.spr_term_valid
from
(select /*+ ORDERED */
       pa.person_id pa_person_id,
       pjwa.assignment_id,
       pjwa.assignment_action_id,
       pjwa.effective_date,
       pjwa.person_id pjwa_person_id,
       pjwa.itax_organization_id,
       pjwa.actual_termination_date,
       to_number(decode(to_char(pjwa.actual_termination_date,''YYYY/MM/DD''),null,0,
         pay_jp_wic_pkg.spr_term_valid(
           pjwa.assignment_action_id,
           pjwa.assignment_id,
           pjwa.action_sequence,
           pjwa.effective_date,
           pjwa.itax_organization_id,
           pjwa.itax_category,
           pjwa.itax_yea_category,
           pjwa.employment_category,
           pjwa.actual_termination_date))) spr_term_valid
from   pay_payroll_actions ppa,
       pay_assignment_actions paa,
       per_all_assignments_f pa,
       pay_jp_wic_assacts_v pjwa
where  ppa.effective_date
       between fnd_date.canonical_to_date(''i_effective_soy'') and fnd_date.canonical_to_date(''i_effective_eoy'')
and    ppa.business_group_id + 0 = to_number(''i_business_group_id'')
and    ppa.action_type in (''R'',''Q'',''B'',''I'')
and    paa.payroll_action_id = ppa.payroll_action_id
and    paa.action_status = ''C''
and    pa.assignment_id = paa.assignment_id
and    ppa.effective_date
       between pa.effective_start_date and pa.effective_end_date
and    pjwa.assignment_action_id = paa.assignment_action_id
and    pjwa.payroll_action_id = ppa.payroll_action_id
and    pjwa.itax_organization_id = nvl(to_number(''i_organization_id''),pjwa.itax_organization_id)) pjwa_v,
       per_addresses padr,
       per_addresses padc
where  padr.person_id (+) = pjwa_v.pjwa_person_id
and    padr.address_type (+) = ''JP_R''
and    nvl(pjwa_v.actual_termination_date, add_months(trunc(pjwa_v.effective_date, ''YYYY''), 12))
       between padr.date_from (+) and nvl(padr.date_to(+), fnd_date.canonical_to_date(''i_eot''))
and    padc.person_id (+) = pjwa_v.pjwa_person_id
and    padc.address_type (+) = ''JP_C''
and    nvl(pjwa_v.actual_termination_date, add_months(trunc(pjwa_v.effective_date, ''YYYY''), 12))
       between padc.date_from (+) and nvl(padc.date_to(+), fnd_date.canonical_to_date(''i_eot''))) wic_v,
(select pjsn_act.organization_id,
        pjsn_act.district_code act_district_code,
        substrb(nvl(pjsn_act.report_district_code,pjsn_act.district_code),1,5) rep_district_code,
        pjsn_rep.swot_number rep_swot_number,
        pjsn_rep.output_file_name rep_output_file_name,
        pjsn_rep.efile_exclusive_flag rep_efile_exclusive_flag
 from   pay_jp_swot_numbers pjsn_rep,
        pay_jp_swot_numbers pjsn_act
 where  pjsn_rep.organization_id = pjsn_act.organization_id
 and    pjsn_rep.district_code = nvl(pjsn_act.report_district_code,pjsn_act.district_code)) pjsn_v';
--
c_proc_ass_where_clause varchar2(32767)
:= 'pjsn_v.organization_id (+) = wic_v.itax_organization_id
and    substrb(pjsn_v.act_district_code(+),1,5) = wic_v.town_or_city
and    nvl(pjsn_v.rep_district_code,nvl(wic_v.town_or_city,''X''))
       = nvl(''i_district_code'',nvl(pjsn_v.rep_district_code,nvl(wic_v.town_or_city,''X'')))
and    nvl(pjsn_v.rep_efile_exclusive_flag,''N'') = ''N''';
--
c_proc_ass_hasa_select_clause varchar2(32767)
:= ', hasa.include_or_exclude';
--
c_proc_ass_hasa_from_clause varchar2(32767)
:= 'hr_assignment_set_amendments hasa,';
--
c_proc_ass_hasa_where_clause varchar2(32767)
:= '(to_number(decode(nvl(''i_ass_set_formula_id'',''-1''),''-1'',
  decode(nvl(''i_ass_set_amendment_type'',''X''),''I'',hasa.assignment_id,wic_v.assignment_id),
  wic_v.assignment_id)) = wic_v.assignment_id
and hasa.assignment_set_id (+) = to_number(''i_assignment_set_id'')
and hasa.assignment_id (+) = wic_v.assignment_id
and nvl(hasa.include_or_exclude,''I'') <> ''E'')';
--
c_proc_ass_order_clause varchar2(32767)
:= 'wic_v.person_id';
--
-- -------------------------------------------------------------------------
-- query for proc_arch in archinit
-- -------------------------------------------------------------------------
c_proc_arch_select_clause varchar2(32767)
:= 'select
pjia.person_id,
pjia.assignment_id,
pjia.assignment_action_id,
pjia.effective_date,
to_number(decode(to_char(pjip.actual_termination_date,''YYYY/MM/DD''),null,0,
  decode(sign(fnd_number.canonical_to_number(pjit.taxable_income) - to_number(''i_valid_term_taxable_amt'')),1,0,1))) spr_term_valid';
--
c_proc_arch_from_clause varchar2(32767)
:= 'pay_payroll_actions ppa,
pay_assignment_actions paa,
pay_jp_itax_arch_v2 pjia,
pay_jp_itax_person_v2 pjip,
pay_jp_itax_tax_v pjit,
(select pjsn_act.organization_id,
        pjsn_act.district_code act_district_code,
        substrb(nvl(pjsn_act.report_district_code,pjsn_act.district_code),1,5) rep_district_code,
        pjsn_rep.swot_number rep_swot_number,
        pjsn_rep.output_file_name rep_output_file_name,
        pjsn_rep.efile_exclusive_flag rep_efile_exclusive_flag
 from   pay_jp_swot_numbers pjsn_rep,
        pay_jp_swot_numbers pjsn_act
 where  pjsn_rep.organization_id = pjsn_act.organization_id
 and    pjsn_rep.district_code = nvl(pjsn_act.report_district_code,pjsn_act.district_code)) pjsn_v';
--
c_proc_arch_where_clause varchar2(32767)
:= 'ppa.business_group_id + 0 = to_number(''i_business_group_id'')
and    ppa.effective_date
       between fnd_date.canonical_to_date(''i_effective_soy'') and fnd_date.canonical_to_date(''i_effective_eoy'')
and    ppa.action_type = ''X''
and    ppa.report_type = ''JPTW''
and    ppa.report_qualifier = ''JP''
and    ppa.report_category = ''ARCHIVE''
and    paa.payroll_action_id = ppa.payroll_action_id
and    pjia.action_context_id = paa.assignment_action_id
and    pjip.action_context_id = pjia.action_context_id
and    pjip.effective_date = pjia.effective_date
and    pjip.itax_organization_id = nvl(to_number(''i_organization_id''),pjip.itax_organization_id)
and    pjit.action_context_id = pjia.action_context_id
and    pjit.effective_date = pjia.effective_date
and    pjsn_v.organization_id (+) = pjip.itax_organization_id
and    substrb(pjsn_v.act_district_code(+),1,5) = pjip.district_code
and    nvl(pjsn_v.rep_district_code,nvl(pjip.district_code,''X''))
       = nvl(''i_district_code'',nvl(pjsn_v.rep_district_code,nvl(pjip.district_code,''X'')))
and    nvl(pjsn_v.rep_efile_exclusive_flag,''N'') = ''N''';
--
c_proc_arch_hasa_select_clause varchar2(32767)
:= ', hasa.include_or_exclude';
--
c_proc_arch_hasa_from_clause varchar2(32767)
:= 'hr_assignment_set_amendments hasa,';
--
c_proc_arch_hasa_where_clause varchar2(32767)
:= '(to_number(decode(nvl(''i_ass_set_formula_id'',''-1''),''-1'',
  decode(nvl(''i_ass_set_amendment_type'',''X''),''I'',hasa.assignment_id,paa.assignment_id),
  paa.assignment_id)) = paa.assignment_id
and hasa.assignment_set_id (+) = to_number(''i_assignment_set_id'')
and hasa.assignment_id (+) = paa.assignment_id
and nvl(hasa.include_or_exclude,''I'') <> ''E'')';
--
c_proc_arch_order_clause varchar2(32767)
:= 'pjia.person_id';
--
-- -------------------------------------------------------------------------
-- query for data_ass in archinit
-- -------------------------------------------------------------------------
c_data_ass_select_clause varchar2(32767)
:= 'select /*+ ORDERED */
wic_v.mag_assignment_action_id,
wic_v.assignment_action_id,
wic_v.assignment_id,
wic_v.action_sequence,
wic_v.effective_date,
wic_v.date_earned,
wic_v.itax_organization_id,
wic_v.itax_category,
wic_v.itax_yea_category,
wic_v.dpnt_ref_type,
wic_v.dpnt_effective_date,
wic_v.person_id,
wic_v.sex,
wic_v.date_of_birth,
wic_v.leaving_reason,
wic_v.last_name,
wic_v.last_name_kana,
wic_v.first_name,
wic_v.first_name_kana,
wic_v.employment_category,
nvl(pjsn_v.rep_district_code,wic_v.town_or_city)||per_jp_validations.district_code_check_digit(nvl(pjsn_v.rep_district_code,wic_v.town_or_city)) district_code,
wic_v.address,
wic_v.address_kana,
wic_v.address_jp,
wic_v.full_name,
wic_v.actual_termination_date,
wic_v.date_start,
wic_v.full_name_kana,
wic_v.employee_number,
pjsn_v.rep_swot_number swot_number,
nvl(pjsn_v.rep_output_file_name,
  pay_jp_spr_efile_pkg.default_file_name(nvl(pjsn_v.rep_district_code,wic_v.town_or_city)||
    per_jp_validations.district_code_check_digit(nvl(pjsn_v.rep_district_code,wic_v.town_or_city)))) output_file_name,
hoi.org_information6||hoi.org_information7||hoi.org_information8 itax_org_address,
hoi.org_information9||hoi.org_information10||hoi.org_information11 itax_org_address_kana,
hoi.org_information1 itax_org_name,
hoi.org_information2 itax_org_name_kana,
hoi.org_information12 itax_org_phone,
hoiw.org_information4 itax_org_serial1,
hoiw.org_information5 itax_org_serial2,
null taxable_income,
null net_taxable_income,
null total_income_exempt,
null withholding_itax,
null spouse_special_exempt,
null social_insurance_premium,
null mutual_aid_premium,
null life_insurance_premium_exempt,
null damage_insurance_premium_exem,
null housing_tax_reduction,
null private_pension_premium,
null spouse_net_taxable_income,
null long_damage_insurance_premium,
null disaster_tax_reduction,
null dependent_spouse_exists_kou,
null dependent_spouse_no_exist_kou,
null dependent_spouse_exists_otsu,
null dependent_spouse_no_exist_otsu,
null aged_spouse_exists,
null num_specifieds_kou,
null num_specifieds_otsu,
null num_aged_parents_partial,
null num_ageds_kou,
null num_ageds_otsu,
null num_dependents_kou,
null num_dependents_otsu,
null num_special_disableds_partial,
null num_special_disableds,
null num_disableds,
null husband_exists,
null minor,
null otsu,
null special_disabled,
null disabled,
null aged,
null widow,
null special_widow,
null widower,
null working_student,
null deceased_termination,
null disastered,
null foreigner,
null prev_job_employer_name,
null prev_job_employer_name_kana,
null prev_job_employer_add,
null prev_job_employer_add_kana,
null prev_job_foreign_address,
null prev_job_taxable_income,
null prev_job_itax,
null prev_job_si_prem,
null prev_job_termination_date,
null prev_job_termination_year,
null prev_job_termination_month,
null prev_job_termination_day,
null hld_residence_date_1_date,
null hld_residence_date_1_year,
null hld_residence_date_1_month,
null hld_residence_date_1_day,
null hld_loan_count,
null hld_payable_loan,
null hld_loan_type_1,
null hld_loan_balance_1,
null hld_residence_date_2_date,
null hld_residence_date_2_year,
null hld_residence_date_2_month,
null hld_residence_date_2_day,
null hld_loan_type_2,
null hld_loan_balance_2,
null original_description,
null original_description_kana,
null wtm_system_desc,
null wtm_system_desc_kana,
null wtm_user_desc,
null wtm_user_desc_kana';
--
c_data_ass_from_clause varchar2(32767)
:= '(select /*+ ORDERED */
paa.assignment_action_id mag_assignment_action_id,
pjwa.assignment_action_id,
pjwa.assignment_id,
pjwa.action_sequence,
pjwa.effective_date,
pjwa.date_earned,
pjwa.itax_organization_id,
pjwa.itax_category,
pjwa.itax_yea_category,
nvl(nvl(pap.prl_information1,''i_bg_itax_dpnt_ref_type''),''CTR_EE'') dpnt_ref_type,
nvl(fnd_date.canonical_to_date(pay_core_utils.get_parameter(''ITAX_DPNT_EFFECTIVE_DATE'',pjwa.legislative_parameters)),pjwa.effective_date) dpnt_effective_date,
pp.person_id,
pp.sex,
pp.date_of_birth,
pjwa.leaving_reason,
pp.per_information18 last_name,
pp.last_name last_name_kana,
pp.per_information19 first_name,
pp.first_name first_name_kana,
pjwa.employment_category,
decode(padr.address_id,null,padc.town_or_city,padr.town_or_city) town_or_city,
decode(padr.address_id, null,
  padc.address_line1||padc.address_line2||padc.address_line3,
  padr.address_line1||padr.address_line2||padr.address_line3) address,
decode(padr.address_id, null,
  padc.region_1||padc.region_2||padc.region_3,
  padr.region_1||padr.region_2||padr.region_3) address_kana,
decode(decode(padr.address_id,null,padc.country,padr.country),''JP'',''0'',''1'') address_jp,
pp.per_information18||'' ''||pp.per_information19 full_name,
pjwa.actual_termination_date,
pjwa.date_start,
pp.last_name||'' ''||pp.first_name full_name_kana,
pp.employee_number
from   pay_payroll_actions ppa,
       pay_assignment_actions paa,
       pay_jp_wic_assacts_v pjwa,
       pay_all_payrolls_f pap,
       per_all_people_f pp,
       per_addresses padr,
       per_addresses padc
where  ppa.payroll_action_id = :p_payroll_action_id
and    paa.payroll_action_id = ppa.payroll_action_id
and    pjwa.assignment_action_id = paa.source_action_id
and    pjwa.assignment_id = paa.assignment_id
and    pjwa.business_group_id + 0 = to_number(''i_business_group_id'')
and    pjwa.effective_date
       between fnd_date.canonical_to_date(''i_effective_soy'') and fnd_date.canonical_to_date(''i_effective_eoy'')
and    pjwa.itax_organization_id = nvl(to_number(''i_organization_id''),pjwa.itax_organization_id)
and    pap.payroll_id = pjwa.payroll_id
and    pjwa.effective_date
       between pap.effective_start_date and pap.effective_end_date
and    pp.person_id = pjwa.person_id
and    pjwa.effective_date
       between pp.effective_start_date and pp.effective_end_date
and    padr.person_id (+) = pjwa.person_id
and    padr.address_type (+) = ''JP_R''
and    nvl(pjwa.actual_termination_date, add_months(trunc(pjwa.effective_date, ''YYYY''), 12))
       between padr.date_from (+) and nvl(padr.date_to(+), fnd_date.canonical_to_date(''i_eot''))
and    padc.person_id (+) = pjwa.person_id
and    padc.address_type (+) = ''JP_C''
and    nvl(pjwa.actual_termination_date, add_months(trunc(pjwa.effective_date, ''YYYY''), 12))
       between padc.date_from (+) and nvl(padc.date_to(+), fnd_date.canonical_to_date(''i_eot''))) wic_v,
(select pjsn_act.organization_id,
        pjsn_act.district_code act_district_code,
        substrb(nvl(pjsn_act.report_district_code,pjsn_act.district_code),1,5) rep_district_code,
        pjsn_rep.swot_number rep_swot_number,
        pjsn_rep.output_file_name rep_output_file_name,
        pjsn_rep.efile_exclusive_flag rep_efile_exclusive_flag
 from   pay_jp_swot_numbers pjsn_rep,
        pay_jp_swot_numbers pjsn_act
 where  pjsn_rep.organization_id = pjsn_act.organization_id
 and    pjsn_rep.district_code = nvl(pjsn_act.report_district_code,pjsn_act.district_code)) pjsn_v,
hr_organization_information hoi,
hr_organization_information hoiw';
--
c_data_ass_where_clause varchar2(32767)
:= 'pjsn_v.organization_id (+) = wic_v.itax_organization_id
and    substrb(pjsn_v.act_district_code(+),1,5) = wic_v.town_or_city
and    nvl(pjsn_v.rep_district_code,nvl(wic_v.town_or_city,''X''))
       = nvl(''i_district_code'',nvl(pjsn_v.rep_district_code,nvl(wic_v.town_or_city,''X'')))
and    nvl(pjsn_v.rep_efile_exclusive_flag,''N'') = ''N''
and    hoi.organization_id (+) = wic_v.itax_organization_id
and    hoi.org_information_context(+) = ''JP_TAX_SWOT_INFO''
and    hoiw.organization_id (+) = wic_v.itax_organization_id
and    hoiw.org_information_context(+) = ''JP_ITAX_WITHHELD_INFO''';
--
c_data_ass_order_clause varchar2(32767)
:= 'nvl(pjsn_v.rep_district_code,wic_v.town_or_city),
hoi.org_information1,
wic_v.itax_organization_id,
lpad(wic_v.employee_number,30,'' '')';
--
-- -------------------------------------------------------------------------
-- query for data_arch in archinit
-- -------------------------------------------------------------------------
c_data_arch_select_clause varchar2(32767)
:= 'select
paa.assignment_action_id mag_assignment_action_id,
pjia.assignment_action_id,
pjia.assignment_id,
pjia.action_sequence,
pjia.effective_date,
pjia.date_earned,
pjip.itax_organization_id,
pjia.itax_category,
pjia.itax_yea_category,
null dpnt_ref_type,
null dpnt_effective_date,
pjia.person_id,
pjip.sex,
pjip.date_of_birth,
pjip.leaving_reason,
pjip.last_name_kanji last_name,
pjip.last_name_kana,
pjip.first_name_kanji first_name,
pjip.first_name_kana,
pjia.employment_category,
nvl(pjsn_v.rep_district_code,pjip.district_code)||per_jp_validations.district_code_check_digit(nvl(pjsn_v.rep_district_code,pjip.district_code)) district_code,
pjip.address_kanji address,
pjip.address_kana address_kana,
decode(pjip.country,''JP'',''0'',''1'') address_jp,
pjip.last_name_kanji||'' ''||pjip.first_name_kanji full_name,
pjip.actual_termination_date,
pjip.date_start,
pjip.last_name_kana||'' ''||pjip.first_name_kana full_name_kana,
pjip.employee_number,
pjsn_v.rep_swot_number swot_number,
nvl(pjsn_v.rep_output_file_name,
  pay_jp_spr_efile_pkg.default_file_name(nvl(pjsn_v.rep_district_code,pjip.district_code)||
    per_jp_validations.district_code_check_digit(nvl(pjsn_v.rep_district_code,pjip.district_code)))) output_file_name,
pjia.employer_address itax_org_address,
null itax_org_address_kana,
pjia.employer_name itax_org_name,
null itax_org_name_kana,
pjia.employer_telephone_number itax_org_phone,
pjia.reference_number1 itax_org_serial1,
pjia.reference_number2 itax_org_serial2,
fnd_number.canonical_to_number(pjit.taxable_income) taxable_income,
fnd_number.canonical_to_number(pjit.net_taxable_income) net_taxable_income,
fnd_number.canonical_to_number(pjit.total_income_exempt) total_income_exempt,
fnd_number.canonical_to_number(pjit.withholding_itax) withholding_itax,
fnd_number.canonical_to_number(pjit.spouse_special_exempt) spouse_special_exempt,
fnd_number.canonical_to_number(pjit.social_insurance_premium) social_insurance_premium,
fnd_number.canonical_to_number(pjit.mutual_aid_premium) mutual_aid_premium,
fnd_number.canonical_to_number(pjit.life_insurance_premium_exempt) life_insurance_premium_exempt,
fnd_number.canonical_to_number(pjit.damage_insurance_premium_exem) damage_insurance_premium_exem,
fnd_number.canonical_to_number(pjit.housing_tax_reduction) housing_tax_reduction,
fnd_number.canonical_to_number(pjit.private_pension_premium) private_pension_premium,
fnd_number.canonical_to_number(pjit.spouse_net_taxable_income) spouse_net_taxable_income,
fnd_number.canonical_to_number(pjit.long_damage_insurance_premium) long_damage_insurance_premium,
fnd_number.canonical_to_number(pjit.disaster_tax_reduction) disaster_tax_reduction,
pjio.dependent_spouse_exists_kou,
pjio.dependent_spouse_no_exist_kou,
pjio.dependent_spouse_exists_otsu,
pjio.dependent_spouse_no_exist_otsu,
pjio.aged_spouse_exists,
fnd_number.canonical_to_number(pjio.num_specifieds_kou) num_specifieds_kou,
fnd_number.canonical_to_number(pjio.num_specifieds_otsu) num_specifieds_otsu,
fnd_number.canonical_to_number(pjio.num_aged_parents_partial) num_aged_parents_partial,
fnd_number.canonical_to_number(pjio.num_ageds_kou) num_ageds_kou,
fnd_number.canonical_to_number(pjio.num_ageds_otsu) num_ageds_otsu,
fnd_number.canonical_to_number(pjio.num_dependents_kou) num_dependents_kou,
fnd_number.canonical_to_number(pjio.num_dependents_otsu) num_dependents_otsu,
fnd_number.canonical_to_number(pjio.num_special_disableds_partial) num_special_disableds_partial,
fnd_number.canonical_to_number(pjio.num_special_disableds) num_special_disableds,
fnd_number.canonical_to_number(pjio.num_disableds) num_disableds,
pjio.husband_exists,
pjio.minor,
pjio.otsu,
pjio.special_disabled,
pjio.disabled,
pjio.aged,
pjio.widow,
pjio.special_widow,
pjio.widower,
pjio.working_student,
pjio.deceased_termination,
pjio.disastered,
pjio.foreigner,
pjit.prev_job_employer_name_kanji prev_job_employer_name,
pjit.prev_job_employer_name_kana,
pjit.prev_job_employer_add_kanji prev_job_employer_add,
pjit.prev_job_employer_add_kana,
pjit.prev_job_foreign_address,
fnd_number.canonical_to_number(pjit.prev_job_taxable_income) prev_job_taxable_income,
fnd_number.canonical_to_number(pjit.prev_job_itax) prev_job_itax,
fnd_number.canonical_to_number(pjit.prev_job_si_prem) prev_job_si_prem,
null prev_job_termination_date,
fnd_number.canonical_to_number(pjit.prev_job_termination_year) prev_job_termination_year,
fnd_number.canonical_to_number(pjit.prev_job_termination_month) prev_job_termination_month,
fnd_number.canonical_to_number(pjit.prev_job_termination_day) prev_job_termination_day,
null hld_residence_date_1_date,
fnd_number.canonical_to_number(pjit.housing_residence_year) hld_residence_date_1_year,
fnd_number.canonical_to_number(pjit.housing_residence_month) hld_residence_date_1_month,
fnd_number.canonical_to_number(pjit.housing_residence_day) hld_residence_date_1_day,
null hld_loan_count,
null hld_payable_loan,
null hld_loan_type_1,
null hld_loan_balance_1,
null hld_residence_date_2_date,
null hld_residence_date_2_year,
null hld_residence_date_2_month,
null hld_residence_date_2_day,
null hld_loan_type_2,
null hld_loan_balance_2,
null original_description,
null original_description_kana,
pjio2.wtm_system_desc_kanji wtm_system_desc,
pjio2.wtm_system_desc_kana,
pjio2.wtm_user_desc_kanji wtm_user_desc,
pjio2.wtm_user_desc_kana';
--
c_data_arch_from_clause varchar2(32767)
:= 'pay_payroll_actions ppa,
pay_assignment_actions paa,
pay_assignment_actions ipaa,
pay_payroll_actions ippa,
pay_jp_itax_person_v2 pjip,
pay_jp_itax_arch_v2 pjia,
pay_jp_itax_tax_v pjit,
pay_jp_itax_other_v pjio,
pay_jp_itax_other2_v2 pjio2,
(select pjsn_act.organization_id,
        pjsn_act.district_code act_district_code,
        substrb(nvl(pjsn_act.report_district_code,pjsn_act.district_code),1,5) rep_district_code,
        pjsn_rep.swot_number rep_swot_number,
        pjsn_rep.output_file_name rep_output_file_name,
        pjsn_rep.efile_exclusive_flag rep_efile_exclusive_flag
 from   pay_jp_swot_numbers pjsn_rep,
        pay_jp_swot_numbers pjsn_act
 where  pjsn_rep.organization_id = pjsn_act.organization_id
 and    pjsn_rep.district_code = nvl(pjsn_act.report_district_code,pjsn_act.district_code)) pjsn_v';
--
c_data_arch_where_clause varchar2(32767)
:= 'ppa.payroll_action_id = :p_payroll_action_id
and    paa.payroll_action_id = ppa.payroll_action_id
and    ipaa.assignment_id = paa.assignment_id
and    ippa.payroll_action_id = ipaa.payroll_action_id
and    ippa.business_group_id + 0 = to_number(''i_business_group_id'')
and    ippa.effective_date
       between fnd_date.canonical_to_date(''i_effective_soy'') and fnd_date.canonical_to_date(''i_effective_eoy'')
and    ippa.action_type = ''X''
and    ippa.report_type = ''JPTW''
and    ippa.report_qualifier = ''JP''
and    ippa.report_category = ''ARCHIVE''
and    pjip.action_context_id = ipaa.assignment_action_id
and    pjip.itax_organization_id = nvl(to_number(''i_organization_id''),pjip.itax_organization_id)
and    pjia.action_context_id = pjip.action_context_id
and    pjia.effective_date = pjip.effective_date
and    pjia.assignment_action_id = paa.source_action_id
and    pjit.action_context_id = pjip.action_context_id
and    pjit.effective_date = pjip.effective_date
and    pjio.action_context_id = pjip.action_context_id
and    pjio.effective_date = pjip.effective_date
and    pjio2.action_context_id = pjip.action_context_id
and    pjio2.effective_date = pjip.effective_date
and    pjsn_v.organization_id (+) = pjip.itax_organization_id
and    substrb(pjsn_v.act_district_code(+),1,5) = pjip.district_code
and    nvl(pjsn_v.rep_district_code,nvl(pjip.district_code,''X''))
       = nvl(''i_district_code'',nvl(pjsn_v.rep_district_code,nvl(pjip.district_code,''X'')))
and    nvl(pjsn_v.rep_efile_exclusive_flag,''N'') = ''N''';
--
c_data_arch_order_clause varchar2(32767)
:= 'nvl(pjsn_v.rep_district_code,pjip.district_code),
pjia.employer_name,
pjip.itax_organization_id,
lpad(pjip.employee_number,30,'' '')';
--
c_data_arch_select_clause_2009 varchar2(32767)
:= 'select
paa.assignment_action_id mag_assignment_action_id,
pjia.assignment_action_id,
pjia.assignment_id,
pjia.action_sequence,
pjia.effective_date,
pjia.date_earned,
pjip.itax_organization_id,
pjia.itax_category,
pjia.itax_yea_category,
null dpnt_ref_type,
null dpnt_effective_date,
pjia.person_id,
pjip.sex,
pjip.date_of_birth,
pjip.leaving_reason,
pjip.last_name_kanji last_name,
pjip.last_name_kana,
pjip.first_name_kanji first_name,
pjip.first_name_kana,
pjia.employment_category,
nvl(pjsn_v.rep_district_code,pjip.district_code)||per_jp_validations.district_code_check_digit(nvl(pjsn_v.rep_district_code,pjip.district_code)) district_code,
pjip.address_kanji address,
pjip.address_kana address_kana,
decode(pjip.country,''JP'',''0'',''1'') address_jp,
pjip.last_name_kanji||'' ''||pjip.first_name_kanji full_name,
pjip.actual_termination_date,
pjip.date_start,
pjip.last_name_kana||'' ''||pjip.first_name_kana full_name_kana,
pjip.employee_number,
pjsn_v.rep_swot_number swot_number,
nvl(pjsn_v.rep_output_file_name,
  pay_jp_spr_efile_pkg.default_file_name(nvl(pjsn_v.rep_district_code,pjip.district_code)||
    per_jp_validations.district_code_check_digit(nvl(pjsn_v.rep_district_code,pjip.district_code)))) output_file_name,
pjia.employer_address itax_org_address,
null itax_org_address_kana,
pjia.employer_name itax_org_name,
null itax_org_name_kana,
pjia.employer_telephone_number itax_org_phone,
pjia.reference_number1 itax_org_serial1,
pjia.reference_number2 itax_org_serial2,
fnd_number.canonical_to_number(pjit.taxable_income) taxable_income,
fnd_number.canonical_to_number(pjit.net_taxable_income) net_taxable_income,
fnd_number.canonical_to_number(pjit.total_income_exempt) total_income_exempt,
fnd_number.canonical_to_number(pjit.withholding_itax) withholding_itax,
fnd_number.canonical_to_number(pjit.spouse_special_exempt) spouse_special_exempt,
fnd_number.canonical_to_number(pjit.social_insurance_premium) social_insurance_premium,
fnd_number.canonical_to_number(pjit.mutual_aid_premium) mutual_aid_premium,
fnd_number.canonical_to_number(pjit.life_insurance_premium_exempt) life_insurance_premium_exempt,
fnd_number.canonical_to_number(pjit.damage_insurance_premium_exem) damage_insurance_premium_exem,
fnd_number.canonical_to_number(pjit.housing_tax_reduction) housing_tax_reduction,
fnd_number.canonical_to_number(pjit.private_pension_premium) private_pension_premium,
fnd_number.canonical_to_number(pjit.spouse_net_taxable_income) spouse_net_taxable_income,
fnd_number.canonical_to_number(pjit.long_damage_insurance_premium) long_damage_insurance_premium,
fnd_number.canonical_to_number(pjit.disaster_tax_reduction) disaster_tax_reduction,
pjio.dependent_spouse_exists_kou,
pjio.dependent_spouse_no_exist_kou,
pjio.dependent_spouse_exists_otsu,
pjio.dependent_spouse_no_exist_otsu,
pjio.aged_spouse_exists,
fnd_number.canonical_to_number(pjio.num_specifieds_kou) num_specifieds_kou,
fnd_number.canonical_to_number(pjio.num_specifieds_otsu) num_specifieds_otsu,
fnd_number.canonical_to_number(pjio.num_aged_parents_partial) num_aged_parents_partial,
fnd_number.canonical_to_number(pjio.num_ageds_kou) num_ageds_kou,
fnd_number.canonical_to_number(pjio.num_ageds_otsu) num_ageds_otsu,
fnd_number.canonical_to_number(pjio.num_dependents_kou) num_dependents_kou,
fnd_number.canonical_to_number(pjio.num_dependents_otsu) num_dependents_otsu,
fnd_number.canonical_to_number(pjio.num_special_disableds_partial) num_special_disableds_partial,
fnd_number.canonical_to_number(pjio.num_special_disableds) num_special_disableds,
fnd_number.canonical_to_number(pjio.num_disableds) num_disableds,
pjio.husband_exists,
pjio.minor,
pjio.otsu,
pjio.special_disabled,
pjio.disabled,
pjio.aged,
pjio.widow,
pjio.special_widow,
pjio.widower,
pjio.working_student,
pjio.deceased_termination,
pjio.disastered,
pjio.foreigner,
pjit.prev_job_employer_name_kanji prev_job_employer_name,
pjit.prev_job_employer_name_kana,
pjit.prev_job_employer_add_kanji prev_job_employer_add,
pjit.prev_job_employer_add_kana,
pjit.prev_job_foreign_address,
fnd_number.canonical_to_number(pjit.prev_job_taxable_income) prev_job_taxable_income,
fnd_number.canonical_to_number(pjit.prev_job_itax) prev_job_itax,
fnd_number.canonical_to_number(pjit.prev_job_si_prem) prev_job_si_prem,
null prev_job_termination_date,
fnd_number.canonical_to_number(pjit.prev_job_termination_year) prev_job_termination_year,
fnd_number.canonical_to_number(pjit.prev_job_termination_month) prev_job_termination_month,
fnd_number.canonical_to_number(pjit.prev_job_termination_day) prev_job_termination_day,
pjih.residence_date_1 hld_residence_date_1_date,
null hld_residence_date_1_year,
null hld_residence_date_1_month,
null hld_residence_date_1_day,
pjih.loan_count hld_loan_count,
pjih.payable_loan hld_payable_loan,
pjih.loan_type_1 hld_loan_type_1,
pjih.loan_balance_1 hld_loan_balance_1,
pjih.residence_date_2 hld_residence_date_2_date,
null hld_residence_date_2_year,
null hld_residence_date_2_month,
null hld_residence_date_2_day,
pjih.loan_type_2 hld_loan_type_2,
pjih.loan_balance_2 hld_loan_balance_2,
null original_description,
null original_description_kana,
pjio2.wtm_system_desc_kanji wtm_system_desc,
pjio2.wtm_system_desc_kana,
pjio2.wtm_user_desc_kanji wtm_user_desc,
pjio2.wtm_user_desc_kana';
--
c_data_arch_from_clause_2009 varchar2(32767)
:= 'pay_payroll_actions ppa,
pay_assignment_actions paa,
pay_assignment_actions ipaa,
pay_payroll_actions ippa,
pay_jp_itax_person_v2 pjip,
pay_jp_itax_arch_v2 pjia,
pay_jp_itax_tax_v pjit,
pay_jp_itax_other_v pjio,
pay_jp_itax_other2_v2 pjio2,
pay_jp_itax_housing_v pjih,
(select pjsn_act.organization_id,
        pjsn_act.district_code act_district_code,
        substrb(nvl(pjsn_act.report_district_code,pjsn_act.district_code),1,5) rep_district_code,
        pjsn_rep.swot_number rep_swot_number,
        pjsn_rep.output_file_name rep_output_file_name,
        pjsn_rep.efile_exclusive_flag rep_efile_exclusive_flag
 from   pay_jp_swot_numbers pjsn_rep,
        pay_jp_swot_numbers pjsn_act
 where  pjsn_rep.organization_id = pjsn_act.organization_id
 and    pjsn_rep.district_code = nvl(pjsn_act.report_district_code,pjsn_act.district_code)) pjsn_v';
--
c_data_arch_where_clause_2009 varchar2(32767)
:= 'ppa.payroll_action_id = :p_payroll_action_id
and    paa.payroll_action_id = ppa.payroll_action_id
and    ipaa.assignment_id = paa.assignment_id
and    ippa.payroll_action_id = ipaa.payroll_action_id
and    ippa.business_group_id + 0 = to_number(''i_business_group_id'')
and    ippa.effective_date
       between fnd_date.canonical_to_date(''i_effective_soy'') and fnd_date.canonical_to_date(''i_effective_eoy'')
and    ippa.action_type = ''X''
and    ippa.report_type = ''JPTW''
and    ippa.report_qualifier = ''JP''
and    ippa.report_category = ''ARCHIVE''
and    pjip.action_context_id = ipaa.assignment_action_id
and    pjip.itax_organization_id = nvl(to_number(''i_organization_id''),pjip.itax_organization_id)
and    pjia.action_context_id = pjip.action_context_id
and    pjia.effective_date = pjip.effective_date
and    pjia.assignment_action_id = paa.source_action_id
and    pjit.action_context_id = pjip.action_context_id
and    pjit.effective_date = pjip.effective_date
and    pjio.action_context_id = pjip.action_context_id
and    pjio.effective_date = pjip.effective_date
and    pjio2.action_context_id = pjip.action_context_id
and    pjio2.effective_date = pjip.effective_date
and    pjih.action_context_id = pjip.action_context_id
and    pjih.effective_date = pjip.effective_date
and    pjsn_v.organization_id (+) = pjip.itax_organization_id
and    substrb(pjsn_v.act_district_code(+),1,5) = pjip.district_code
and    nvl(pjsn_v.rep_district_code,nvl(pjip.district_code,''X''))
       = nvl(''i_district_code'',nvl(pjsn_v.rep_district_code,nvl(pjip.district_code,''X'')))
and    nvl(pjsn_v.rep_efile_exclusive_flag,''N'') = ''N''';
--
-- -------------------------------------------------------------------------
-- set_file_prefix
-- -------------------------------------------------------------------------
procedure set_file_prefix(
  p_file_prefix in varchar2)
is
begin
--
  pay_jp_spr_efile_pkg.g_file_prefix := p_file_prefix;
--
end set_file_prefix;
--
-- -------------------------------------------------------------------------
-- set_file_extension
-- -------------------------------------------------------------------------
procedure set_file_extension(
  p_file_extension in varchar2)
is
begin
--
  pay_jp_spr_efile_pkg.g_file_extension := p_file_extension;
--
end set_file_extension;
--
-- -------------------------------------------------------------------------
-- default_file_name
-- -------------------------------------------------------------------------
function default_file_name(
  p_district_code in varchar2)
return varchar2
is
--
  l_file_name varchar2(80);
--
begin
--
  if p_district_code is null then
  --
    l_file_name := pay_jp_spr_efile_pkg.g_file_prefix||
      c_file_spliter||
      to_char(pay_jp_spr_efile_pkg.g_request_id)||c_file_extension;
  --
  else
  --
    l_file_name := pay_jp_spr_efile_pkg.g_file_prefix||
      c_file_spliter||
      p_district_code||
      c_file_spliter||
      to_char(pay_jp_spr_efile_pkg.g_request_id)||c_file_extension;
  --
  end if;
--
  if lengthb(l_file_name) > 80 then
  --
    fnd_message.set_name('PAY','PAY_JP_SPR_INV_FILE_NAME');
    fnd_message.raise_error;
  --
  end if;
--
return l_file_name;
end default_file_name;
--
-- -------------------------------------------------------------------------
-- file_era_code
-- -------------------------------------------------------------------------
function file_era_code(
  p_era_code in varchar2)
return varchar2
is
--
  l_file_era_code varchar2(1);
--
begin
--
  if p_era_code = 'M' then
    l_file_era_code := '3';
  elsif p_era_code = 'T' then
    l_file_era_code := '2';
  elsif p_era_code = 'S' then
    l_file_era_code := '1';
  elsif p_era_code = 'H' then
    l_file_era_code := '4';
  end if;
--
return l_file_era_code;
end file_era_code;
--
-- -------------------------------------------------------------------------
-- set_detail_debug
-- -------------------------------------------------------------------------
procedure set_detail_debug(
  p_yn in varchar2)
is
--
  -- hidden option for tracking
  cursor csr_hidden_debug
  is
  select parameter_value
  from   pay_action_parameters
  where  parameter_name = 'JP_DEBUG_PAYJPSPE';
--
  l_hidden_debug pay_action_parameters.parameter_value%type;
--
begin
--
  if p_yn is not null then
  --
    pay_jp_spr_efile_pkg.g_detail_debug := p_yn;
  --
  else
  --
    open csr_hidden_debug;
    fetch csr_hidden_debug into l_hidden_debug;
    close csr_hidden_debug;
  --
    if l_hidden_debug = 'Y' then
    --
      pay_jp_spr_efile_pkg.g_detail_debug := l_hidden_debug;
    --
    end if;
  --
  end if;
--
  if g_debug then
  --
    hr_utility.trace('l_hidden_debug : '||l_hidden_debug);
    hr_utility.trace('g_detail_debug : '||g_detail_debug);
  --
  end if;
--
end set_detail_debug;
--
-- -------------------------------------------------------------------------
-- sequence of process.
-- 1. range_cursor/initialization_code (inc. init_pact, archive_pact)
-- 2. assignment_action_creation    <= invoked by each ranges
-- 3. archinit     (inc. init_pact) <= invoked by each threads, start from here in mark-for-retry)
-- 4. archive_data (inc. init_assact, archive_assact)
-- 5. deinitialization_code
-- -------------------------------------------------------------------------
-- init_pact
-- -------------------------------------------------------------------------
procedure init_pact(
  p_payroll_action_id in number)
is
--
  l_proc varchar2(80) := c_package||'init_pact';
--
  l_detail_debug varchar2(1) := pay_jp_spr_efile_pkg.g_detail_debug;
--
  cursor csr_action
  is
  select ppa.business_group_id,
         ppa.effective_date,
         ppa.legislative_parameters,
         pbg.legislation_code,
         ppa.request_id
  from   pay_payroll_actions ppa,
         per_business_groups_perf pbg
  where  ppa.payroll_action_id = p_payroll_action_id
  and    pbg.business_group_id = ppa.business_group_id;
--
  cursor csr_arch_pact_exist
  is
  select 'Y'
  from   dual
  where  not exists(
    select null
    from   hr_organization_information hoi,
           hr_all_organization_units hou
    where  hoi.org_information_context = 'CLASS'
    and    hoi.org_information1 = 'JP_TAX_SWOT'
    and    hoi.organization_id = nvl(g_organization_id,hoi.organization_id)
    and    hou.organization_id = hoi.organization_id
    and    hou.business_group_id + 0 = g_business_group_id
    and    hou.date_from <= g_effective_eoy
    and    nvl(hou.date_to,hr_api.g_eot) >= g_effective_soy
    and    not exists(
      select null
      from   pay_payroll_actions ppa,
             pay_jp_itax_pact_v2 pjip
      where  ppa.business_group_id + 0 = g_business_group_id
      and    ppa.effective_date
             between g_effective_soy and g_effective_eoy
      and    ppa.action_type = 'X'
      and    ppa.report_type = 'JPTW'
      and    ppa.report_qualifier = 'JP'
      and    ppa.report_category = 'ARCHIVE'
      and    pjip.action_context_id = ppa.payroll_action_id
      and    nvl(pjip.itax_organization_id,hou.organization_id) = hou.organization_id
      and    pjip.effective_date
             between g_effective_soy and g_effective_eoy
      and    exists(
        select null
        from   pay_assignment_actions paa,
               pay_jp_itax_person_v2 pjips
        where  paa.payroll_action_id = ppa.payroll_action_id
        and    pjips.action_context_id = paa.assignment_action_id
        and    pjips.itax_organization_id = hoi.organization_id
        and    (to_number(to_char(pjip.effective_date,'YYYY')) < 2009
               or (to_number(to_char(pjip.effective_date,'YYYY')) >= 2009
                  and exists(
                    select null
                    from   pay_jp_itax_housing_v pjih
                    where  pjih.action_context_id = pjips.action_context_id
                    and    pjih.effective_date = pjips.effective_date))))));
--
  cursor csr_bg_itax_dpnt_ref_type
  is
  select nvl(hoi.org_information2,'CTR_EE')
  from   /* Business Group details */
         hr_organization_information hoi
  where  hoi.organization_id = g_business_group_id
  and    hoi.org_information_context = 'JP_BUSINESS_GROUP_INFO';
--
  cursor csr_file_dir
  is
  select fcp.plsql_dir
  from   fnd_concurrent_requests fcr,
         fnd_concurrent_processes fcp
  where  fcr.request_id = g_request_id
  and    fcp.concurrent_process_id = fcr.controlling_manager;
--
  l_csr_action csr_action%rowtype;
--
begin
--
  set_detail_debug(l_detail_debug);
--
  if g_debug
  and g_detail_debug = 'Y' then
    hr_utility.set_location(l_proc,0);
  end if;
--
  if g_payroll_action_id is null
  or g_payroll_action_id <> p_payroll_action_id then
  --
    if g_debug
    and g_detail_debug = 'Y' then
      hr_utility.set_location(l_proc,10);
      hr_utility.trace('no cache : g_pact_id('||g_payroll_action_id||'),p_pact_id('||p_payroll_action_id||')');
    end if;
    --
    open csr_action;
    fetch csr_action into l_csr_action;
    if csr_action%notfound then
      close csr_action;
      fnd_message.set_name('PAY','PAY_34985_INVALID_PAY_ACTION');
      fnd_message.raise_error;
    end if;
    close csr_action;
  --
    g_payroll_action_id := p_payroll_action_id;
    g_session_date      := l_csr_action.effective_date;
    g_effective_soy     := to_date(pay_core_utils.get_parameter('SUBJECT_YEAR',l_csr_action.legislative_parameters)||'/01/01','YYYY/MM/DD');
    g_effective_eoy     := add_months(g_effective_soy,12) - 1;
    g_effective_yyyy    := to_number(to_char(g_effective_soy,'YYYY'));
    g_business_group_id := l_csr_action.business_group_id;
    g_legislation_code  := l_csr_action.legislation_code;
    g_district_code     := pay_core_utils.get_parameter('DISTRICT_CODE',l_csr_action.legislative_parameters);
    g_organization_id   := fnd_number.canonical_to_number(pay_core_utils.get_parameter('ORGANIZATION_ID',l_csr_action.legislative_parameters));
    g_assignment_set_id := fnd_number.canonical_to_number(pay_core_utils.get_parameter('ASSIGNMENT_SET_ID',l_csr_action.legislative_parameters));
    --g_request_id        := fnd_global.conc_request_id;
    g_request_id        := l_csr_action.request_id;
    g_file_split        := pay_core_utils.get_parameter('FILE_SPLIT',l_csr_action.legislative_parameters);
    g_use_arch          := pay_core_utils.get_parameter('USE_ARCH',l_csr_action.legislative_parameters);
    --g_kana_flag         := pay_core_utils.get_parameter('KANA_FLAG',l_csr_action.legislative_parameters);
    --no support non-assignment creation to exclude assignment by assignment set (assignment_action_creation chache cannot be transfered to archinit)
    --g_process_assignments_flag := pay_core_utils.get_parameter('PROCESS_ASSIGNMENTS_FLAG',l_csr_action.legislative_parameters);
    g_remove_act        := pay_core_utils.get_parameter('REMOVE_ACT',l_csr_action.legislative_parameters);
  --
    -- not support partial archive unit (part of payroll)
    -- use archive when archive exist for itax_organization
    -- limitation is that excluding partial employee for whom archive has not been processed.
    --
    -- set null for g_use_arch = N and no csr_arch_pact_exist row
    g_arch_pact_exist := null;
    --
    if g_use_arch is null then
    --
      open csr_arch_pact_exist;
      fetch csr_arch_pact_exist into g_arch_pact_exist;
      close csr_arch_pact_exist;
    --
    elsif g_use_arch = 'Y' then
    --
      g_arch_pact_exist := 'Y';
    --
    end if;
  --
    g_bg_itax_dpnt_ref_type := null;
    open csr_bg_itax_dpnt_ref_type;
    fetch csr_bg_itax_dpnt_ref_type into g_bg_itax_dpnt_ref_type;
    close csr_bg_itax_dpnt_ref_type;
  --
    g_file_dir := null;
    open csr_file_dir;
    fetch csr_file_dir into g_file_dir;
    close csr_file_dir;
  --
    if g_file_dir is null then
    --
      fnd_message.set_name('FND','CONC-GET PLSQL FILE NAMES');
      fnd_message.raise_error;
    --
    end if;
  --
    g_ass_set_formula_id := null;
    g_ass_set_amendment_type := null;
    if g_assignment_set_id is not null then
    --
      hr_jp_ast_utility_pkg.get_assignment_set_info(g_assignment_set_id,g_ass_set_formula_id,g_ass_set_amendment_type);
    --
    end if;
  --
    if pay_jp_wic_pkg.g_valid_term_taxable_amt is null then
    --
      pay_jp_wic_pkg.set_valid_term_taxable_amt(c_valid_term_taxable_amt);
    --
    end if;
  --
    if pay_jp_report_pkg.g_char_set is null then
    --
      pay_jp_report_pkg.set_char_set(c_char_set);
    --
    end if;
  --
    if pay_jp_spr_efile_pkg.g_file_prefix is null then
    --
      set_file_prefix(c_file_prefix);
    --
    end if;
  --
    if pay_jp_spr_efile_pkg.g_file_extension is null then
    --
      set_file_extension(c_file_extension);
    --
    end if;
  --
  end if;
  --
  if g_debug then
    hr_utility.trace('g_payroll_action_id      : '||to_char(g_payroll_action_id));
    hr_utility.trace('g_session_date           : '||to_char(g_session_date,'YYYY/MM/DD'));
    hr_utility.trace('g_effective_soy          : '||to_char(g_effective_soy,'YYYY/MM/DD'));
    hr_utility.trace('g_effective_eoy          : '||to_char(g_effective_eoy,'YYYY/MM/DD'));
    hr_utility.trace('g_effective_yyyy         : '||to_char(g_effective_yyyy));
    hr_utility.trace('g_business_group_id      : '||to_char(g_business_group_id));
    hr_utility.trace('g_legislation_code       : '||g_legislation_code);
    hr_utility.trace('g_district_code          : '||g_district_code);
    hr_utility.trace('g_organization_id        : '||to_char(g_organization_id));
    hr_utility.trace('g_assignment_set_id      : '||to_char(g_assignment_set_id));
    hr_utility.trace('g_request_id             : '||to_char(g_request_id));
    hr_utility.trace('g_file_split             : '||g_file_split);
    hr_utility.trace('g_arch_pact_exist        : '||g_arch_pact_exist);
    hr_utility.trace('g_bg_itax_dpnt_ref_type  : '||g_bg_itax_dpnt_ref_type);
    hr_utility.trace('g_file_dir               : '||g_file_dir);
    hr_utility.trace('g_use_arch               : '||g_use_arch);
    --hr_utility.trace('kana_flag                : '||g_kana_flag);
    --hr_utility.trace('process_assignments_flag : '||g_process_assignments_flag);
    hr_utility.trace('g_remove_act             : '||g_remove_act);
    hr_utility.trace('g_ass_set_formula_id     : '||to_char(g_ass_set_formula_id));
    hr_utility.trace('g_ass_set_amendment_type : '||g_ass_set_amendment_type);
    hr_utility.trace('pay_jp_wic_pkg.g_valid_term_taxable_amt : '||to_char(pay_jp_wic_pkg.g_valid_term_taxable_amt));
    hr_utility.trace('pay_jp_report_pkg.g_char_set            : '||pay_jp_report_pkg.g_char_set);
    hr_utility.trace('pay_jp_spr_efile_pkg.g_file_prefix      : '||pay_jp_spr_efile_pkg.g_file_prefix);
    hr_utility.trace('pay_jp_spr_efile_pkg.g_file_extension   : '||pay_jp_spr_efile_pkg.g_file_extension);
  end if;
--
  if g_debug
  and g_detail_debug = 'Y' then
    hr_utility.set_location(l_proc,1000);
  end if;
--
end init_pact;
--
-- -------------------------------------------------------------------------
-- archive_pact
-- -------------------------------------------------------------------------
--procedure archive_pact(
--  p_payroll_action_id in number)
--is
----
--  l_proc varchar2(80) := c_package||'archive_pact';
----
--begin
----
--  if g_debug then
--    hr_utility.set_location(l_proc,0);
--  end if;
----
--  if g_debug then
--    hr_utility.set_location(l_proc,1000);
--  end if;
----
--end archive_pact;
--
-- -------------------------------------------------------------------------
-- range_cursor
-- -------------------------------------------------------------------------
procedure range_cursor(
  p_payroll_action_id in number,
  p_sqlstr            out nocopy varchar2)
is
--
  l_proc varchar2(80) := c_package||'range_cursor';
--
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  init_pact(p_payroll_action_id);
--
  if g_debug
  and g_detail_debug = 'Y' then
    hr_utility.set_location(l_proc,10);
  end if;
--
--  archive_pact(p_payroll_action_id);
----
--  if g_debug then
--    hr_utility.set_location(l_proc,20);
--  end if;
--
  ---- no create assact when process assignments flag is set.
  ----
  --if g_process_assignments_flag = 'N' then
  ----
  --  if g_debug then
  --    hr_utility.set_location(l_proc,25);
  --  end if;
  ----
  --  p_sqlstr :=
  --    'select 1
  --     from   dual
  --     where  :payroll_action_id < 0';
  ----
  --else
  --
    if g_debug
    and g_detail_debug = 'Y' then
      hr_utility.set_location(l_proc,30);
    end if;
  --
    p_sqlstr :=
      'select distinct ppos.person_id
       from   pay_payroll_actions ppa,
              per_all_people_f pp,
              per_periods_of_service ppos
       where  ppa.payroll_action_id = :payroll_action_id
       and    pp.business_group_id = ppa.business_group_id + 0
       and    ppos.person_id = pp.person_id
       and    ppos.business_group_id + 0 = pp.business_group_id
       and    ppos.date_start <= fnd_date.canonical_to_date(''i_effective_eoy'')
       and    nvl(ppos.final_process_date,fnd_date.canonical_to_date(''i_effective_soy'')) >= fnd_date.canonical_to_date(''i_effective_soy'')
       order by
         ppos.person_id';
  --
    p_sqlstr := replace(p_sqlstr,'i_effective_soy',fnd_date.date_to_canonical(g_effective_soy));
    p_sqlstr := replace(p_sqlstr,'i_effective_eoy',fnd_date.date_to_canonical(g_effective_eoy));
  --
  --end if;
--
  if g_debug then
    hr_utility.set_location(l_proc,1000);
  end if;
--
end range_cursor;
--
-- -------------------------------------------------------------------------
-- assignment_action_creation
-- -------------------------------------------------------------------------
procedure assignment_action_creation(
  p_payroll_action_id in number,
  p_start_person_id   in number,
  p_end_person_id     in number,
  p_chunk_number      in number)
is
--
  l_proc varchar2(80) := c_package||'assignment_action_creation';
--
  l_select_clause varchar2(32767);
  l_from_clause varchar2(32767);
  l_where_clause varchar2(32767);
  l_order_by_clause varchar2(255);
--
  l_hasa_select_clause varchar2(32767);
  l_hasa_from_clause varchar2(32767);
  l_hasa_where_clause varchar2(32767);
--
  l_spr_assignment_action_id number;
  l_ass_valid boolean;
--
  l_person_id number;
  l_assignment_id number;
  l_assignment_action_id number;
  l_ass_cnt number;
--
  l_ass_id_tbl t_number_tbl;
  l_ass_id_tbl_cnt number;
--
begin
--
  if g_debug
  and g_detail_debug = 'Y' then
    hr_utility.set_location(l_proc,0);
  end if;
--
  -- need set for multiple ranges.
  init_pact(p_payroll_action_id);
--
  if g_debug
  and g_detail_debug = 'Y' then
    hr_utility.set_location(l_proc,10);
  end if;
--
  if g_per_ind_tbl.count = 0
  or g_ass_ind_tbl.count = 0
  or g_ass_tbl.count = 0 then
  --
    if g_debug
    and g_detail_debug = 'Y' then
      hr_utility.set_location(l_proc,20);
    end if;
  --
    g_per_ind_tbl.delete;
    g_ass_ind_tbl.delete;
    g_ass_tbl.delete;
  --
    if g_arch_pact_exist is not null
    and g_arch_pact_exist = 'Y' then
    --
      if g_debug
      and g_detail_debug = 'Y' then
        hr_utility.set_location(l_proc,30);
      end if;
    --
      pay_jp_report_pkg.append_select_clause(c_proc_arch_select_clause,l_select_clause);
      pay_jp_report_pkg.append_from_clause(c_proc_arch_from_clause,l_from_clause);
      pay_jp_report_pkg.append_where_clause(c_proc_arch_where_clause,l_where_clause);
      pay_jp_report_pkg.append_order_clause(c_proc_arch_order_clause,l_order_by_clause);
    --
      l_hasa_select_clause := c_proc_arch_hasa_select_clause;
      l_hasa_from_clause := c_proc_arch_hasa_from_clause;
      l_hasa_where_clause := c_proc_arch_hasa_where_clause;
    --
    else
    --
      if g_debug
      and g_detail_debug = 'Y' then
        hr_utility.set_location(l_proc,40);
      end if;
    --
      pay_jp_report_pkg.append_select_clause(c_proc_ass_select_clause,l_select_clause);
      pay_jp_report_pkg.append_from_clause(c_proc_ass_from_clause,l_from_clause);
      pay_jp_report_pkg.append_where_clause(c_proc_ass_where_clause,l_where_clause);
      pay_jp_report_pkg.append_order_clause(c_proc_ass_order_clause,l_order_by_clause);
    --
      l_hasa_select_clause := c_proc_ass_hasa_select_clause;
      l_hasa_from_clause := c_proc_ass_hasa_from_clause;
      l_hasa_where_clause := c_proc_ass_hasa_where_clause;
    --
    end if;
  --
    if g_debug
    and g_detail_debug = 'Y' then
      hr_utility.set_location(l_proc,50);
    end if;
  --
    if g_assignment_set_id is not null
    and g_ass_set_amendment_type is not null
    and g_ass_set_amendment_type <> 'N' then
    --
      if g_debug
      and g_detail_debug = 'Y' then
        hr_utility.set_location(l_proc,60);
      end if;
    --
      pay_jp_report_pkg.append_select_clause(l_hasa_select_clause,l_select_clause);
      pay_jp_report_pkg.append_from_clause(l_hasa_from_clause,l_from_clause,'Y');
      pay_jp_report_pkg.append_where_clause(l_hasa_where_clause,l_where_clause);
    --
      --
      -- set variable parameter
      --
      l_where_clause := replace(l_where_clause,'i_ass_set_formula_id',to_char(g_ass_set_formula_id));
      l_where_clause := replace(l_where_clause,'i_ass_set_amendment_type',g_ass_set_amendment_type);
      l_where_clause := replace(l_where_clause,'i_assignment_set_id',to_char(g_assignment_set_id));
    --
    else
    --
      if g_debug
      and g_detail_debug = 'Y' then
        hr_utility.set_location(l_proc,70);
      end if;
    --
      pay_jp_report_pkg.append_select_clause(', null include_or_exclude',l_select_clause);
    --
    end if;
  --
    --
    -- set variable parameter
    --
    l_select_clause := replace(l_select_clause,'i_valid_term_taxable_amt',to_char(pay_jp_wic_pkg.g_valid_term_taxable_amt));
    --
    l_from_clause := replace(l_from_clause,'i_business_group_id',to_char(g_business_group_id));
    l_from_clause := replace(l_from_clause,'i_effective_soy',fnd_date.date_to_canonical(g_effective_soy));
    l_from_clause := replace(l_from_clause,'i_effective_eoy',fnd_date.date_to_canonical(g_effective_eoy));
    l_from_clause := replace(l_from_clause,'i_organization_id',to_char(g_organization_id));
    l_from_clause := replace(l_from_clause,'i_eot',fnd_date.date_to_canonical(hr_api.g_eot));
    --
    l_where_clause := replace(l_where_clause,'i_business_group_id',to_char(g_business_group_id));
    l_where_clause := replace(l_where_clause,'i_effective_soy',fnd_date.date_to_canonical(g_effective_soy));
    l_where_clause := replace(l_where_clause,'i_effective_eoy',fnd_date.date_to_canonical(g_effective_eoy));
    l_where_clause := replace(l_where_clause,'i_organization_id',to_char(g_organization_id));
    l_where_clause := replace(l_where_clause,'i_district_code',g_district_code);
  --
    if g_debug
    and g_detail_debug = 'Y' then
      hr_utility.set_location(l_proc,80);
      --
      if g_show_act_debug is null
      or g_show_act_debug <> 'Y' then
      --
        g_show_act_debug := 'Y';
      --
        pay_jp_report_pkg.show_debug(l_select_clause);
        pay_jp_report_pkg.show_debug(l_from_clause);
        pay_jp_report_pkg.show_debug(l_where_clause);
        pay_jp_report_pkg.show_debug(l_order_by_clause);
      --
      end if;
    end if;
  --
    execute immediate
      l_select_clause||
      l_from_clause||
      l_where_clause||
      l_order_by_clause
    bulk collect into g_ass_tbl;
    --using
    --  p_start_person_id,
    --  p_end_person_id;
  --
    if g_debug
    and g_detail_debug = 'Y' then
      hr_utility.set_location(l_proc,90);
      hr_utility.trace('g_ass_tbl.count : '||to_char(g_ass_tbl.count));
    end if;
  --
    if g_ass_tbl.count > 0 then
    --
      <<loop_ass_tbl>>
      for i in 1..g_ass_tbl.count loop
      --
        if ((l_person_id is not null
            and l_person_id = g_ass_tbl(i).person_id)
           or (l_assignment_id is not null
              and l_assignment_id = g_ass_tbl(i).assignment_id)) then
        --
          l_person_id := g_ass_tbl(i).person_id;
          l_assignment_id := g_ass_tbl(i).assignment_id;
          l_assignment_action_id := null;
          l_ass_cnt := l_ass_cnt + 1;
        --
        else
        --
          l_person_id := g_ass_tbl(i).person_id;
          l_assignment_id := g_ass_tbl(i).assignment_id;
          l_assignment_action_id := g_ass_tbl(i).assignment_action_id;
          l_ass_cnt := 1;
        --
        end if;
      --
        -- override if person_id or assignment_id is same
        g_per_ind_tbl(l_person_id).person_id            := l_person_id;
        g_per_ind_tbl(l_person_id).assignment_id        := l_assignment_id;
        g_per_ind_tbl(l_person_id).assignment_action_id := l_assignment_action_id;
        g_per_ind_tbl(l_person_id).ass_cnt              := l_ass_cnt;
        --
        g_ass_ind_tbl(g_ass_tbl(i).assignment_action_id).person_id            := g_ass_tbl(i).person_id;
        g_ass_ind_tbl(g_ass_tbl(i).assignment_action_id).assignment_id        := g_ass_tbl(i).assignment_id;
        g_ass_ind_tbl(g_ass_tbl(i).assignment_action_id).assignment_action_id := g_ass_tbl(i).assignment_action_id;
        g_ass_ind_tbl(g_ass_tbl(i).assignment_action_id).effective_date       := g_ass_tbl(i).effective_date;
        g_ass_ind_tbl(g_ass_tbl(i).assignment_action_id).spr_term_valid       := g_ass_tbl(i).spr_term_valid;
        g_ass_ind_tbl(g_ass_tbl(i).assignment_action_id).include_or_exclude   := g_ass_tbl(i).include_or_exclude;
      --
      end loop loop_ass_tbl;
    --
    else
    --
      hr_utility.trace('g_ass_tbl.count is 0 : '||to_char(g_ass_tbl.count));
    --
    end if;
  --
  end if;
--
  if g_debug
  and g_detail_debug = 'Y' then
  --
    hr_utility.set_location(l_proc,100);
    hr_utility.trace('p_start_person_id : '||to_char(p_start_person_id));
    hr_utility.trace('p_end_person_id   : '||to_char(p_end_person_id));
  --
    hr_utility.trace('g_per_ind_tbl.count : '||to_char(g_per_ind_tbl.count));
    hr_utility.trace('g_ass_ind_tbl.count : '||to_char(g_ass_ind_tbl.count));
    hr_utility.trace('g_ass_tbl.count     : '||to_char(g_ass_tbl.count));
  --
    if g_per_ind_tbl.count > 0 then
      hr_utility.trace('g_per_ind_tbl.first                          : '||to_char(g_per_ind_tbl.first));
      hr_utility.trace('g_per_ind_tbl.last                           : '||to_char(g_per_ind_tbl.last));
      hr_utility.trace('g_per_ind_tbl(g_per_ind_tbl.first).person_id : '||to_char(g_per_ind_tbl(g_per_ind_tbl.first).person_id));
      hr_utility.trace('g_per_ind_tbl(g_per_ind_tbl.last).person_id  : '||to_char(g_per_ind_tbl(g_per_ind_tbl.last).person_id));
    end if;
  --
    if g_ass_ind_tbl.count > 0 then
      hr_utility.trace('g_ass_ind_tbl.first                          : '||to_char(g_ass_ind_tbl.first));
      hr_utility.trace('g_ass_ind_tbl.last                           : '||to_char(g_ass_ind_tbl.last));
      hr_utility.trace('g_ass_ind_tbl(g_ass_ind_tbl.first).person_id : '||to_char(g_ass_ind_tbl(g_ass_ind_tbl.first).person_id));
      hr_utility.trace('g_ass_ind_tbl(g_ass_ind_tbl.last).person_id  : '||to_char(g_ass_ind_tbl(g_ass_ind_tbl.last).person_id));
    end if;
  --
    if g_ass_tbl.count > 0 then
      hr_utility.trace('g_ass_tbl.first                      : '||to_char(g_ass_tbl.first));
      hr_utility.trace('g_ass_tbl.last                       : '||to_char(g_ass_tbl.last));
      hr_utility.trace('g_ass_tbl(g_ass_tbl.first).person_id : '||to_char(g_ass_tbl(g_ass_tbl.first).person_id));
      hr_utility.trace('g_ass_tbl(g_ass_tbl.last).person_id  : '||to_char(g_ass_tbl(g_ass_tbl.last).person_id));
    end if;
  end if;
--
  if (g_per_ind_tbl.count > 0
     and g_ass_ind_tbl.count > 0
     and g_ass_tbl.count > 0) then
  --
    <<loop_per_tbl>>
    for j in p_start_person_id..p_end_person_id loop
    --
      l_person_id := null;
      l_ass_id_tbl_cnt := 0;
      l_ass_id_tbl.delete;
    --
      -- check if g_per_ind_tbl exist
      begin
      --
        l_person_id := g_per_ind_tbl(j).person_id;
      --
      exception
      when no_data_found then
      --
        null;
      --
      end;
    --
      -- skip out of range
      if l_person_id is not null then
      --
        -- case same person_id or assignment_id
        if g_per_ind_tbl(j).ass_cnt > 1 then
        --
          <<loop_imp_ass_tbl>>
          for s in 1..g_ass_tbl.count loop
          --
            if g_ass_tbl(s).person_id = g_per_ind_tbl(j).person_id then
            --
              l_ass_id_tbl_cnt := l_ass_id_tbl_cnt + 1;
              l_ass_id_tbl(l_ass_id_tbl_cnt) := g_ass_tbl(s).assignment_action_id;
            --
              if l_ass_id_tbl_cnt = g_per_ind_tbl(j).ass_cnt then
                exit loop_imp_ass_tbl;
              end if;
            --
            end if;
          --
          end loop loop_imp_ass_tbl;
        --
        else
        --
          l_ass_id_tbl_cnt := l_ass_id_tbl_cnt + 1;
          l_ass_id_tbl(l_ass_id_tbl_cnt) := g_per_ind_tbl(j).assignment_action_id;
        --
        end if;
      --
        if g_debug
        and g_detail_debug = 'Y' then
          hr_utility.trace('j person_id        : '||to_char(j));
          hr_utility.trace('l_ass_id_tbl_cnt   : '||to_char(l_ass_id_tbl_cnt));
          hr_utility.trace('l_ass_id_tbl.count : '||to_char(l_ass_id_tbl.count));
        end if;
      --
        if l_ass_id_tbl.count > 0 then
        --
          <<loop_exp_ass_tbl>>
          for t in 1..l_ass_id_tbl.count loop
          --
            l_ass_valid := true;
          --
            if g_ass_set_formula_id is not null
            and g_ass_ind_tbl(l_ass_id_tbl(t)).include_or_exclude is null then
            --
              l_ass_valid := hr_jp_ast_utility_pkg.formula_validate(
                p_formula_id     => g_ass_set_formula_id,
                p_assignment_id  => g_ass_ind_tbl(l_ass_id_tbl(t)).assignment_id,
                p_effective_date => g_ass_ind_tbl(l_ass_id_tbl(t)).effective_date,
                p_populate_fs    => true);
            --
            end if;
          --
            if l_ass_valid
            and g_valid_term_flag = 'Y'
            and g_ass_ind_tbl(l_ass_id_tbl(t)).spr_term_valid = 1 then
            --
              l_ass_valid := false;
            --
            end if;
          --
            if l_ass_valid then
            --
              select pay_assignment_actions_s.nextval
              into   l_spr_assignment_action_id
              from   dual;
            --
              hr_nonrun_asact.insact(
                lockingactid => l_spr_assignment_action_id,
                assignid     => g_ass_ind_tbl(l_ass_id_tbl(t)).assignment_id,
                pactid       => p_payroll_action_id,
                chunk        => p_chunk_number,
                greid        => null,
                source_act   => g_ass_ind_tbl(l_ass_id_tbl(t)).assignment_action_id);
            --
              if g_debug
              and g_detail_debug = 'Y' then
                hr_utility.trace('assignment_action_id     : '||to_char(l_ass_id_tbl(t))||','||to_char(l_ass_id_tbl(t))||','||to_char(g_ass_ind_tbl(l_ass_id_tbl(t)).assignment_action_id));
                hr_utility.trace('person_id                : '||to_char(g_ass_ind_tbl(l_ass_id_tbl(t)).person_id));
                hr_utility.trace('assignment_id            : '||to_char(g_ass_ind_tbl(l_ass_id_tbl(t)).assignment_id));
                hr_utility.trace('effective_date           : '||to_char(g_ass_ind_tbl(l_ass_id_tbl(t)).effective_date,'YYYY/MM/DD'));
                hr_utility.trace('spr_assignment_action_id : '||to_char(l_spr_assignment_action_id));
              end if;
            --
            end if;
          --
          end loop loop_exp_ass_tbl;
        --
        else
        --
          hr_utility.trace('l_ass_id_tbl.count is 0 : '||to_char(l_ass_id_tbl.count));
        --
        end if;
      --
      end if;
    --
    end loop loop_per_tbl;
  --
  else
  --
    hr_utility.trace('g_per_ind_tbl.count is 0 : '||to_char(g_per_ind_tbl.count));
    hr_utility.trace('g_ass_ind_tbl.count is 0 : '||to_char(g_ass_ind_tbl.count));
    hr_utility.trace('g_ass_tbl.count is 0     : '||to_char(g_ass_tbl.count));
  --
  end if;
--
  if g_debug
  and g_detail_debug = 'Y' then
    hr_utility.set_location(l_proc,1000);
  end if;
--
end assignment_action_creation;
--
-- -------------------------------------------------------------------------
-- archinit
-- -------------------------------------------------------------------------
procedure archinit(
  p_payroll_action_id in number)
is
--
  l_proc varchar2(80) := c_package||'archinit';
--
  l_select_clause varchar2(32767);
  l_from_clause varchar2(32767);
  l_where_clause varchar2(32767);
  l_order_by_clause varchar2(255);
--
  l_file_name varchar2(80);
  l_file_out utl_file.file_type;
  l_file_cnt number;
  l_file_over_start number;
--
  l_data_tbl t_data_tbl;
--
  l_certificate_info pay_jp_wic_pkg.t_certificate_info;
  l_prev_job_info pay_jp_wic_pkg.t_prev_job_info;
  l_housing_info pay_jp_wic_pkg.t_housing_info;
  l_submission_required_flag varchar2(1);
--
  l_district_code per_addresses.town_or_city%type;
  l_district_code_chg boolean;
  l_district_code_null boolean;
  l_itax_organization_id number;
  l_itax_org_name hr_organization_information.org_information1%type;
  l_itax_org_address varchar2(500);
  l_itax_org_cnt number;
  l_emp_cnt number;
  l_term_emp_cnt number;
  l_summary_tbl_cnt number;
--
  l_full_name_kana varchar2(400);
  l_address varchar2(500);
  l_assortment fnd_new_messages.message_text%type;
  l_yes varchar2(1);
  l_dep_spouse varchar2(1);
  l_aged_spouse varchar2(1);
  l_husband_exists varchar2(1);
  l_aged varchar2(1);
  l_widow varchar2(1);
  l_employed varchar2(1);
  l_employed_date date;
  l_pjob_itax_org_address varchar2(500);
  l_pjob_itax_org_address_jp varchar2(1);
  l_pjob_itax_org_full_name pay_action_information.action_information20%type;
  l_original_description varchar2(32767);
  l_desc_chr_len number;
--
  l_delimiter varchar2(1);
--
  type t_itax_org_kana_rec is record(
    itax_org_name    hr_organization_information.org_information1%type,
    itax_org_address varchar2(500));
  type t_itax_org_kana_tbl is table of t_itax_org_kana_rec index by binary_integer;
  l_itax_org_kana_tbl t_itax_org_kana_tbl;
--
  procedure get_itax_org_kana(
    p_itax_organization_id in number,
    p_itax_org_name out nocopy varchar2,
    p_itax_org_address out nocopy varchar2)
  is
  --
    l_found boolean := false;
  --
    cursor csr_itax_org_kana
    is
    select hoi.org_information2 itax_org_name_kana,
           hoi.org_information9||hoi.org_information10||hoi.org_information11 itax_org_address_kana
    from   hr_organization_information hoi
    where  hoi.organization_id = p_itax_organization_id
    and    hoi.org_information_context = 'JP_TAX_SWOT_INFO';
  --
  begin
  --
    if l_itax_org_kana_tbl.count > 0 then
    --
      begin
      --
        p_itax_org_name    := l_itax_org_kana_tbl(p_itax_organization_id).itax_org_name;
        p_itax_org_address := l_itax_org_kana_tbl(p_itax_organization_id).itax_org_address;
        l_found := true;
      --
      exception
      when others then
        null;
      end;
    --
    end if;
  --
    if not l_found then
    --
      open csr_itax_org_kana;
      fetch csr_itax_org_kana
      into p_itax_org_name,
           p_itax_org_address;
      close csr_itax_org_kana;
    --
      l_itax_org_kana_tbl(p_itax_organization_id).itax_org_name    := p_itax_org_name;
      l_itax_org_kana_tbl(p_itax_organization_id).itax_org_address := p_itax_org_address;
    --
    end if;
  --
  end get_itax_org_kana;
--
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  g_per_ind_tbl.delete;
  g_ass_ind_tbl.delete;
  g_ass_tbl.delete;
  g_assact_tbl.delete;
  g_body_tbl.delete;
  l_file_cnt := 0;
  l_file_over_start := 0;
  g_file_tbl.delete;
  g_warning_exist := null;
  g_warning_header := null;
  l_summary_tbl_cnt := 0;
  g_summary_tbl.delete;
  l_district_code_chg := false;
  l_district_code_null := false;
  l_itax_org_cnt := 0;
  l_emp_cnt := 0;
  l_term_emp_cnt := 0;
--
  -- need set for multiple threads.
  init_pact(p_payroll_action_id);
--
  if g_debug
  and g_detail_debug = 'Y' then
    hr_utility.set_location(l_proc,10);
  end if;
--
  if g_arch_pact_exist is not null
  and g_arch_pact_exist = 'Y' then
  --
    if g_debug
    and g_detail_debug = 'Y' then
      hr_utility.set_location(l_proc,20);
      hr_utility.trace('g_effective_yyyy : '||to_char(g_effective_yyyy));
    end if;
  --
    if g_effective_yyyy < 2009 then
    --
      pay_jp_report_pkg.append_select_clause(c_data_arch_select_clause,l_select_clause);
      pay_jp_report_pkg.append_from_clause(c_data_arch_from_clause,l_from_clause);
      pay_jp_report_pkg.append_where_clause(c_data_arch_where_clause,l_where_clause);
      pay_jp_report_pkg.append_order_clause(c_data_arch_order_clause,l_order_by_clause);
    --
    else
    --
      pay_jp_report_pkg.append_select_clause(c_data_arch_select_clause_2009,l_select_clause);
      pay_jp_report_pkg.append_from_clause(c_data_arch_from_clause_2009,l_from_clause);
      pay_jp_report_pkg.append_where_clause(c_data_arch_where_clause_2009,l_where_clause);
      pay_jp_report_pkg.append_order_clause(c_data_arch_order_clause,l_order_by_clause);
    --
    end if;
  --
    l_yes := c_arch_yes;
  --
  else
  --
    if g_debug
    and g_detail_debug = 'Y' then
      hr_utility.set_location(l_proc,30);
    end if;
  --
    pay_jp_report_pkg.append_select_clause(c_data_ass_select_clause,l_select_clause);
    pay_jp_report_pkg.append_from_clause(c_data_ass_from_clause,l_from_clause);
    pay_jp_report_pkg.append_where_clause(c_data_ass_where_clause,l_where_clause);
    pay_jp_report_pkg.append_order_clause(c_data_ass_order_clause,l_order_by_clause);
  --
    l_yes := c_ass_yes;
  --
  end if;
--
  --
  -- set variable parameter
  --
  l_from_clause := replace(l_from_clause,'i_bg_itax_dpnt_ref_type',g_bg_itax_dpnt_ref_type);
  l_from_clause := replace(l_from_clause,'i_business_group_id',to_char(g_business_group_id));
  l_from_clause := replace(l_from_clause,'i_effective_soy',fnd_date.date_to_canonical(g_effective_soy));
  l_from_clause := replace(l_from_clause,'i_effective_eoy',fnd_date.date_to_canonical(g_effective_eoy));
  l_from_clause := replace(l_from_clause,'i_organization_id',to_char(g_organization_id));
  l_from_clause := replace(l_from_clause,'i_district_code',g_district_code);
  l_from_clause := replace(l_from_clause,'i_eot',fnd_date.date_to_canonical(hr_api.g_eot));
  --
  l_where_clause := replace(l_where_clause,'i_business_group_id',to_char(g_business_group_id));
  l_where_clause := replace(l_where_clause,'i_effective_soy',fnd_date.date_to_canonical(g_effective_soy));
  l_where_clause := replace(l_where_clause,'i_effective_eoy',fnd_date.date_to_canonical(g_effective_eoy));
  l_where_clause := replace(l_where_clause,'i_organization_id',to_char(g_organization_id));
  l_where_clause := replace(l_where_clause,'i_district_code',g_district_code);
--
  if g_debug
  and g_detail_debug = 'Y' then
    hr_utility.set_location(l_proc,40);
    --
    if g_show_debug is null
    or g_show_debug <> 'Y' then
    --
      g_show_debug := 'Y';
    --
      pay_jp_report_pkg.show_debug(l_select_clause);
      pay_jp_report_pkg.show_debug(l_from_clause);
      pay_jp_report_pkg.show_debug(l_where_clause);
      pay_jp_report_pkg.show_debug(l_order_by_clause);
    --
    end if;
  end if;
--
  execute immediate
    l_select_clause||
    l_from_clause||
    l_where_clause||
    l_order_by_clause
  bulk collect into l_data_tbl
  using p_payroll_action_id;
--
  if g_debug
  and g_detail_debug = 'Y' then
    hr_utility.set_location(l_proc,50);
    hr_utility.trace('l_data_tbl.count : '||to_char(l_data_tbl.count));
  end if;
--
  for i in 1..l_data_tbl.count loop
  --
    -- -----------------------------------------------------
    -- g_assact_tbl setup
    -- -----------------------------------------------------
    g_assact_tbl(i) := l_data_tbl(i).mag_assignment_action_id;
  --
    -- -----------------------------------------------------
    -- l_data_tbl setup
    -- -----------------------------------------------------
    if g_arch_pact_exist is null
    or g_arch_pact_exist <> 'Y' then
    --
      l_certificate_info := null;
      l_prev_job_info := null;
      --l_certificate_info.delete;
      --l_prev_job_info.delete;
      l_submission_required_flag := null;
    --
      pay_jp_wic_pkg.get_certificate_info(
        p_assignment_action_id     => l_data_tbl(i).assignment_action_id,
        p_assignment_id            => l_data_tbl(i).assignment_id,
        p_action_sequence          => l_data_tbl(i).action_sequence,
        p_business_group_id        => g_business_group_id,
        p_effective_date           => l_data_tbl(i).effective_date,
        p_date_earned              => l_data_tbl(i).date_earned,
        p_itax_organization_id     => l_data_tbl(i).itax_organization_id,
        p_itax_category            => l_data_tbl(i).itax_category,
        p_itax_yea_category        => l_data_tbl(i).itax_yea_category,
        p_dpnt_ref_type            => l_data_tbl(i).dpnt_ref_type,
        p_dpnt_effective_date      => l_data_tbl(i).dpnt_effective_date,
        p_person_id                => l_data_tbl(i).person_id,
        p_sex                      => l_data_tbl(i).sex,
        p_date_of_birth            => l_data_tbl(i).date_of_birth,
        p_leaving_reason           => l_data_tbl(i).leaving_reason,
        p_last_name_kanji          => l_data_tbl(i).last_name,
        p_last_name_kana           => l_data_tbl(i).last_name_kana,
        p_employment_category      => l_data_tbl(i).employment_category,
        p_magnetic_media_flag      => 'Y',
        p_certificate_info         => l_certificate_info,
        p_submission_required_flag => l_submission_required_flag,
        p_prev_job_info            => l_prev_job_info,
        p_housing_info             => l_housing_info);
    --
      l_data_tbl(i).taxable_income                 := l_certificate_info.tax_info.taxable_income;
      l_data_tbl(i).net_taxable_income             := l_certificate_info.net_taxable_income;
      l_data_tbl(i).total_income_exempt            := l_certificate_info.total_income_exempt;
      l_data_tbl(i).withholding_itax               := l_certificate_info.tax_info.withholding_itax;
      l_data_tbl(i).spouse_special_exempt          := l_certificate_info.spouse_sp_exempt;
      l_data_tbl(i).social_insurance_premium       := l_certificate_info.tax_info.si_prem;
      l_data_tbl(i).mutual_aid_premium             := l_certificate_info.tax_info.mutual_aid_prem;
      l_data_tbl(i).life_insurance_premium_exempt  := l_certificate_info.li_prem_exempt;
      l_data_tbl(i).damage_insurance_premium_exem  := l_certificate_info.ai_prem_exempt;
      l_data_tbl(i).housing_tax_reduction          := l_certificate_info.housing_tax_reduction;
      l_data_tbl(i).private_pension_premium        := l_certificate_info.pp_prem;
      l_data_tbl(i).spouse_net_taxable_income      := l_certificate_info.spouse_net_taxable_income;
      l_data_tbl(i).long_damage_insurance_premium  := l_certificate_info.long_ai_prem;
      l_data_tbl(i).disaster_tax_reduction         := l_certificate_info.tax_info.disaster_tax_reduction;
      l_data_tbl(i).dependent_spouse_exists_kou    := l_certificate_info.dep_spouse_exists_kou;
      l_data_tbl(i).dependent_spouse_no_exist_kou  := l_certificate_info.dep_spouse_not_exist_kou;
      l_data_tbl(i).dependent_spouse_exists_otsu   := l_certificate_info.dep_spouse_exists_otsu;
      l_data_tbl(i).dependent_spouse_no_exist_otsu := l_certificate_info.dep_spouse_not_exist_otsu;
      l_data_tbl(i).aged_spouse_exists             := l_certificate_info.aged_spouse_exists;
      l_data_tbl(i).num_specifieds_kou             := l_certificate_info.num_specifieds_kou;
      l_data_tbl(i).num_specifieds_otsu            := l_certificate_info.num_specifieds_otsu;
      l_data_tbl(i).num_aged_parents_partial       := l_certificate_info.num_aged_parents_lt;
      l_data_tbl(i).num_ageds_kou                  := l_certificate_info.num_ageds_kou;
      l_data_tbl(i).num_ageds_otsu                 := l_certificate_info.num_ageds_otsu;
      l_data_tbl(i).num_dependents_kou             := l_certificate_info.num_deps_kou;
      l_data_tbl(i).num_dependents_otsu            := l_certificate_info.num_deps_otsu;
      l_data_tbl(i).num_special_disableds_partial  := l_certificate_info.num_svr_disableds_lt;
      l_data_tbl(i).num_special_disableds          := l_certificate_info.num_svr_disableds;
      l_data_tbl(i).num_disableds                  := l_certificate_info.num_disableds;
      l_data_tbl(i).husband_exists                 := l_certificate_info.husband_exists;
      l_data_tbl(i).minor                          := l_certificate_info.minor_flag;
      l_data_tbl(i).otsu                           := l_certificate_info.otsu_flag;
      l_data_tbl(i).special_disabled               := l_certificate_info.svr_disabled_flag;
      l_data_tbl(i).disabled                       := l_certificate_info.disabled_flag;
      l_data_tbl(i).aged                           := l_certificate_info.aged_flag;
      l_data_tbl(i).widow                          := l_certificate_info.widow_flag;
      l_data_tbl(i).special_widow                  := l_certificate_info.sp_widow_flag;
      l_data_tbl(i).widower                        := l_certificate_info.widower_flag;
      l_data_tbl(i).working_student                := l_certificate_info.working_student_flag;
      l_data_tbl(i).deceased_termination           := l_certificate_info.deceased_termination_flag;
      l_data_tbl(i).disastered                     := l_certificate_info.disastered_flag;
      l_data_tbl(i).foreigner                      := l_certificate_info.foreigner_flag;
    --
      if l_prev_job_info.taxable_income is null then
      --
        l_data_tbl(i).prev_job_employer_name         := null;
        l_data_tbl(i).prev_job_employer_name_kana    := null;
        l_data_tbl(i).prev_job_employer_add          := null;
        l_data_tbl(i).prev_job_employer_add_kana     := null;
        l_data_tbl(i).prev_job_foreign_address       := null;
        l_data_tbl(i).prev_job_taxable_income        := null;
        l_data_tbl(i).prev_job_itax                  := null;
        l_data_tbl(i).prev_job_si_prem               := null;
        l_data_tbl(i).prev_job_termination_date      := null;
        l_data_tbl(i).prev_job_termination_year      := null;
        l_data_tbl(i).prev_job_termination_month     := null;
        l_data_tbl(i).prev_job_termination_day       := null;
      --
      else
      --
        l_data_tbl(i).prev_job_employer_name         := l_prev_job_info.salary_payer_name_kanji;
        l_data_tbl(i).prev_job_employer_name_kana    := l_prev_job_info.salary_payer_name_kana;
        l_data_tbl(i).prev_job_employer_add          := l_prev_job_info.salary_payer_address_kanji;
        l_data_tbl(i).prev_job_employer_add_kana     := l_prev_job_info.salary_payer_address_kana;
        l_data_tbl(i).prev_job_foreign_address       := l_prev_job_info.foreign_address_flag;
        l_data_tbl(i).prev_job_taxable_income        := l_prev_job_info.taxable_income;
        l_data_tbl(i).prev_job_itax                  := l_prev_job_info.itax;
        l_data_tbl(i).prev_job_si_prem               := l_prev_job_info.si_prem;
        l_data_tbl(i).prev_job_termination_date      := l_prev_job_info.termination_date;
        l_data_tbl(i).prev_job_termination_year      := to_number(to_char(l_prev_job_info.termination_date,'YY','nls_calendar=''Japanese Imperial'''));
        l_data_tbl(i).prev_job_termination_month     := to_number(to_char(l_prev_job_info.termination_date,'MM','nls_calendar=''Japanese Imperial'''));
        l_data_tbl(i).prev_job_termination_day       := to_number(to_char(l_prev_job_info.termination_date,'DD','nls_calendar=''Japanese Imperial'''));
      --
      end if;
    --
      if g_effective_yyyy < 2009 then
      --
        l_data_tbl(i).hld_residence_date_1_date      := l_certificate_info.housing_residence_date;
        l_data_tbl(i).hld_residence_date_1_year      := to_number(to_char(l_certificate_info.housing_residence_date,'YY','nls_calendar=''Japanese Imperial'''));
        l_data_tbl(i).hld_residence_date_1_month     := to_number(to_char(l_certificate_info.housing_residence_date,'MM','nls_calendar=''Japanese Imperial'''));
        l_data_tbl(i).hld_residence_date_1_day       := to_number(to_char(l_certificate_info.housing_residence_date,'DD','nls_calendar=''Japanese Imperial'''));
        l_data_tbl(i).hld_loan_count                 := null;
        l_data_tbl(i).hld_payable_loan               := null;
        l_data_tbl(i).hld_loan_type_1                := null;
        l_data_tbl(i).hld_loan_balance_1             := null;
        l_data_tbl(i).hld_residence_date_2_date      := null;
        l_data_tbl(i).hld_residence_date_2_year      := null;
        l_data_tbl(i).hld_residence_date_2_month     := null;
        l_data_tbl(i).hld_residence_date_2_day       := null;
        l_data_tbl(i).hld_loan_type_2                := null;
        l_data_tbl(i).hld_loan_balance_2             := null;
      --
      else
      --
        l_data_tbl(i).hld_residence_date_1_date      := l_housing_info.residence_date_1;
        l_data_tbl(i).hld_residence_date_1_year      := to_number(to_char(l_housing_info.residence_date_1,'YY','nls_calendar=''Japanese Imperial'''));
        l_data_tbl(i).hld_residence_date_1_month     := to_number(to_char(l_housing_info.residence_date_1,'MM','nls_calendar=''Japanese Imperial'''));
        l_data_tbl(i).hld_residence_date_1_day       := to_number(to_char(l_housing_info.residence_date_1,'DD','nls_calendar=''Japanese Imperial'''));
        l_data_tbl(i).hld_loan_count                 := l_housing_info.loan_count;
        l_data_tbl(i).hld_payable_loan               := l_housing_info.payable_loan;
        l_data_tbl(i).hld_loan_type_1                := l_housing_info.loan_type_1;
        l_data_tbl(i).hld_loan_balance_1             := l_housing_info.loan_balance_1;
        l_data_tbl(i).hld_residence_date_2_date      := l_housing_info.residence_date_2;
        l_data_tbl(i).hld_residence_date_2_year      := to_number(to_char(l_housing_info.residence_date_2,'YY','nls_calendar=''Japanese Imperial'''));
        l_data_tbl(i).hld_residence_date_2_month     := to_number(to_char(l_housing_info.residence_date_2,'MM','nls_calendar=''Japanese Imperial'''));
        l_data_tbl(i).hld_residence_date_2_day       := to_number(to_char(l_housing_info.residence_date_2,'DD','nls_calendar=''Japanese Imperial'''));
        l_data_tbl(i).hld_loan_type_2                := l_housing_info.loan_type_2;
        l_data_tbl(i).hld_loan_balance_2             := l_housing_info.loan_balance_2;
      --
      end if;
    --
      l_data_tbl(i).original_description           := l_certificate_info.description_kanji;
      l_data_tbl(i).original_description_kana      := l_certificate_info.description_kana;
      l_data_tbl(i).wtm_system_desc                := null;
      l_data_tbl(i).wtm_system_desc_kana           := null;
      l_data_tbl(i).wtm_user_desc                  := null;
      l_data_tbl(i).wtm_user_desc_kana             := null;
    --
    else
    --
      if g_effective_yyyy >= 2009 then
      --
        l_data_tbl(i).hld_residence_date_1_year      := to_number(to_char(l_data_tbl(i).hld_residence_date_1_date,'YY','nls_calendar=''Japanese Imperial'''));
        l_data_tbl(i).hld_residence_date_1_month     := to_number(to_char(l_data_tbl(i).hld_residence_date_1_date,'MM','nls_calendar=''Japanese Imperial'''));
        l_data_tbl(i).hld_residence_date_1_day       := to_number(to_char(l_data_tbl(i).hld_residence_date_1_date,'DD','nls_calendar=''Japanese Imperial'''));
        l_data_tbl(i).hld_residence_date_2_year      := to_number(to_char(l_data_tbl(i).hld_residence_date_2_date,'YY','nls_calendar=''Japanese Imperial'''));
        l_data_tbl(i).hld_residence_date_2_month     := to_number(to_char(l_data_tbl(i).hld_residence_date_2_date,'MM','nls_calendar=''Japanese Imperial'''));
        l_data_tbl(i).hld_residence_date_2_day       := to_number(to_char(l_data_tbl(i).hld_residence_date_2_date,'DD','nls_calendar=''Japanese Imperial'''));
      --
      end if;
    --
      -- not set in case archive (desired to store into archive)
      if g_kana_flag is not null
      and g_kana_flag = 'Y' then
      --
        get_itax_org_kana(
          p_itax_organization_id => l_data_tbl(i).itax_organization_id,
          p_itax_org_name        => l_data_tbl(i).itax_org_name_kana,
          p_itax_org_address     => l_data_tbl(i).itax_org_address_kana);
      --
      else
      --
        get_itax_org_kana(
          p_itax_organization_id => l_data_tbl(i).itax_organization_id,
          p_itax_org_name        => l_data_tbl(i).itax_org_name_kana,
          p_itax_org_address     => l_data_tbl(i).itax_org_address_kana);
      --
      end if;
    --
      l_delimiter := null;
      if l_data_tbl(i).wtm_system_desc is not null
      and l_data_tbl(i).wtm_user_desc is not null then
      --
        l_delimiter := c_delimiter;
      --
      end if;
    --
      l_data_tbl(i).original_description           := l_data_tbl(i).wtm_system_desc||
         l_delimiter||
         l_data_tbl(i).wtm_user_desc;
    --
      l_delimiter := null;
      if l_data_tbl(i).wtm_system_desc_kana is not null
      and l_data_tbl(i).wtm_user_desc_kana is not null then
      --
        l_delimiter := c_delimiter;
      --
      end if;
    --
      l_data_tbl(i).original_description_kana      := l_data_tbl(i).wtm_system_desc_kana||
         l_delimiter||
         l_data_tbl(i).wtm_user_desc_kana;
    --
    end if;
  --
    -- -----------------------------------------------------
    -- g_body_tbl setup
    -- -----------------------------------------------------
    g_body_tbl(g_assact_tbl(i)).mag_assignment_action_id       := l_data_tbl(i).mag_assignment_action_id;
    g_body_tbl(g_assact_tbl(i)).assignment_action_id           := l_data_tbl(i).assignment_action_id;
    g_body_tbl(g_assact_tbl(i)).assignment_id                  := l_data_tbl(i).assignment_id;
    g_body_tbl(g_assact_tbl(i)).action_sequence                := l_data_tbl(i).action_sequence;
    g_body_tbl(g_assact_tbl(i)).effective_date                 := l_data_tbl(i).effective_date;
    g_body_tbl(g_assact_tbl(i)).date_earned                    := l_data_tbl(i).date_earned;
    g_body_tbl(g_assact_tbl(i)).itax_organization_id           := l_data_tbl(i).itax_organization_id;
    g_body_tbl(g_assact_tbl(i)).itax_category                  := l_data_tbl(i).itax_category;
    g_body_tbl(g_assact_tbl(i)).itax_yea_category              := l_data_tbl(i).itax_yea_category;
    g_body_tbl(g_assact_tbl(i)).dpnt_ref_type                  := l_data_tbl(i).dpnt_ref_type;
    g_body_tbl(g_assact_tbl(i)).dpnt_effective_date            := l_data_tbl(i).dpnt_effective_date;
    g_body_tbl(g_assact_tbl(i)).person_id                      := l_data_tbl(i).person_id;
    g_body_tbl(g_assact_tbl(i)).sex                            := l_data_tbl(i).sex;
    g_body_tbl(g_assact_tbl(i)).date_of_birth                  := l_data_tbl(i).date_of_birth;
    g_body_tbl(g_assact_tbl(i)).leaving_reason                 := l_data_tbl(i).leaving_reason;
    g_body_tbl(g_assact_tbl(i)).last_name                      := l_data_tbl(i).last_name;
    g_body_tbl(g_assact_tbl(i)).last_name_kana                 := l_data_tbl(i).last_name_kana;
    g_body_tbl(g_assact_tbl(i)).first_name                     := l_data_tbl(i).first_name;
    g_body_tbl(g_assact_tbl(i)).first_name_kana                := l_data_tbl(i).first_name_kana;
    g_body_tbl(g_assact_tbl(i)).employment_category            := l_data_tbl(i).employment_category;
    g_body_tbl(g_assact_tbl(i)).address                        := l_data_tbl(i).address;
    g_body_tbl(g_assact_tbl(i)).address_kana                   := l_data_tbl(i).address_kana;
    g_body_tbl(g_assact_tbl(i)).address_jp                     := l_data_tbl(i).address_jp;
    g_body_tbl(g_assact_tbl(i)).full_name                      := l_data_tbl(i).full_name;
    g_body_tbl(g_assact_tbl(i)).full_name_kana                 := l_data_tbl(i).full_name_kana;
    g_body_tbl(g_assact_tbl(i)).actual_termination_date        := l_data_tbl(i).actual_termination_date;
    g_body_tbl(g_assact_tbl(i)).date_start                     := l_data_tbl(i).date_start;
    g_body_tbl(g_assact_tbl(i)).itax_org_address               := l_data_tbl(i).itax_org_address;
    g_body_tbl(g_assact_tbl(i)).itax_org_address_kana          := l_data_tbl(i).itax_org_address_kana;
    g_body_tbl(g_assact_tbl(i)).itax_org_name                  := l_data_tbl(i).itax_org_name;
    g_body_tbl(g_assact_tbl(i)).itax_org_name_kana             := l_data_tbl(i).itax_org_name_kana;
    g_body_tbl(g_assact_tbl(i)).dependent_spouse_exists_kou    := l_data_tbl(i).dependent_spouse_exists_kou;
    g_body_tbl(g_assact_tbl(i)).dependent_spouse_no_exist_kou  := l_data_tbl(i).dependent_spouse_no_exist_kou;
    g_body_tbl(g_assact_tbl(i)).dependent_spouse_exists_otsu   := l_data_tbl(i).dependent_spouse_exists_otsu;
    g_body_tbl(g_assact_tbl(i)).dependent_spouse_no_exist_otsu := l_data_tbl(i).dependent_spouse_no_exist_otsu;
    g_body_tbl(g_assact_tbl(i)).aged_spouse_exists             := l_data_tbl(i).aged_spouse_exists;
    g_body_tbl(g_assact_tbl(i)).husband_exists                 := l_data_tbl(i).husband_exists;
    g_body_tbl(g_assact_tbl(i)).minor                          := l_data_tbl(i).minor;
    g_body_tbl(g_assact_tbl(i)).otsu                           := l_data_tbl(i).otsu;
    g_body_tbl(g_assact_tbl(i)).special_disabled               := l_data_tbl(i).special_disabled;
    g_body_tbl(g_assact_tbl(i)).disabled                       := l_data_tbl(i).disabled;
    g_body_tbl(g_assact_tbl(i)).aged                           := l_data_tbl(i).aged;
    g_body_tbl(g_assact_tbl(i)).widow                          := l_data_tbl(i).widow;
    g_body_tbl(g_assact_tbl(i)).special_widow                  := l_data_tbl(i).special_widow;
    g_body_tbl(g_assact_tbl(i)).widower                        := l_data_tbl(i).widower;
    g_body_tbl(g_assact_tbl(i)).working_student                := l_data_tbl(i).working_student;
    g_body_tbl(g_assact_tbl(i)).deceased_termination           := l_data_tbl(i).deceased_termination;
    g_body_tbl(g_assact_tbl(i)).disastered                     := l_data_tbl(i).disastered;
    g_body_tbl(g_assact_tbl(i)).foreigner                      := l_data_tbl(i).foreigner;
    g_body_tbl(g_assact_tbl(i)).prev_job_employer_name         := l_data_tbl(i).prev_job_employer_name;
    g_body_tbl(g_assact_tbl(i)).prev_job_employer_name_kana    := l_data_tbl(i).prev_job_employer_name_kana;
    g_body_tbl(g_assact_tbl(i)).prev_job_employer_add          := l_data_tbl(i).prev_job_employer_add;
    g_body_tbl(g_assact_tbl(i)).prev_job_employer_add_kana     := l_data_tbl(i).prev_job_employer_add_kana;
    g_body_tbl(g_assact_tbl(i)).prev_job_employer_add_jp       := l_data_tbl(i).prev_job_foreign_address;
    -- not set in case archive
    g_body_tbl(g_assact_tbl(i)).pjob_termination_date          := l_data_tbl(i).prev_job_termination_date;
    g_body_tbl(g_assact_tbl(i)).hld_payable_loan               := l_data_tbl(i).hld_payable_loan;
    g_body_tbl(g_assact_tbl(i)).hld_loan_count                 := l_data_tbl(i).hld_loan_count;
    -- not set in case archive before 2009
    g_body_tbl(g_assact_tbl(i)).hld_residence_date_1           := l_data_tbl(i).hld_residence_date_1_date;
    g_body_tbl(g_assact_tbl(i)).hld_loan_type_1                := l_data_tbl(i).hld_loan_type_1;
    g_body_tbl(g_assact_tbl(i)).hld_loan_balance_1             := l_data_tbl(i).hld_loan_balance_1;
    g_body_tbl(g_assact_tbl(i)).hld_residence_date_2           := l_data_tbl(i).hld_residence_date_2_date;
    g_body_tbl(g_assact_tbl(i)).hld_loan_type_2                := l_data_tbl(i).hld_loan_type_2;
    g_body_tbl(g_assact_tbl(i)).hld_loan_balance_2             := l_data_tbl(i).hld_loan_balance_2;
    --
    g_body_tbl(g_assact_tbl(i)).original_description           := l_data_tbl(i).original_description;
    g_body_tbl(g_assact_tbl(i)).original_description_kana      := l_data_tbl(i).original_description_kana;
    g_body_tbl(g_assact_tbl(i)).wtm_system_desc                := l_data_tbl(i).wtm_system_desc;
    g_body_tbl(g_assact_tbl(i)).wtm_system_desc_kana           := l_data_tbl(i).wtm_system_desc_kana;
    g_body_tbl(g_assact_tbl(i)).wtm_user_desc                  := l_data_tbl(i).wtm_user_desc;
    g_body_tbl(g_assact_tbl(i)).wtm_user_desc_kana             := l_data_tbl(i).wtm_user_desc_kana;
    --
    g_body_tbl(g_assact_tbl(i)).spr_term_valid                 := 0;
    if g_valid_term_flag is null
    or g_valid_term_flag <> 'Y' then
    --
      if l_data_tbl(i).actual_termination_date is not null
      and l_data_tbl(i).taxable_income <= pay_jp_wic_pkg.g_valid_term_taxable_amt then
      --
        g_body_tbl(g_assact_tbl(i)).spr_term_valid             := 1;
      --
      end if;
    --
    end if;
  --
    -- override output_file_name to unit file in case etax
    if g_file_split is not null
    and g_file_split = 'N' then
    --
      l_data_tbl(i).output_file_name :=
        pay_jp_spr_efile_pkg.g_file_prefix||
        c_file_spliter||
        to_char(pay_jp_spr_efile_pkg.g_request_id)||c_file_extension;
    --
    end if;
  --
    l_district_code_chg := false;
    if ((not l_district_code_null)
    and (l_district_code is null
        or l_data_tbl(i).district_code is null
        or l_district_code <> l_data_tbl(i).district_code)) then
    --
      l_district_code_chg := true;
    --
      l_district_code := l_data_tbl(i).district_code;
    --
      l_itax_org_cnt := 0;
      l_emp_cnt := 0;
      l_term_emp_cnt := 0;
      l_file_over_start := i;
    --
      l_itax_organization_id := null;
    --
      l_district_code_null := false;
      if l_data_tbl(i).district_code is null then
      --
        l_district_code_null := true;
      --
      end if;
    --
    end if;
  --
    l_emp_cnt := l_emp_cnt + 1;
  --
    if l_itax_organization_id is null
    or l_itax_organization_id <> l_data_tbl(i).itax_organization_id then
    --
      l_itax_organization_id := l_data_tbl(i).itax_organization_id;
      l_itax_org_cnt := l_itax_org_cnt + 1;
    --
      -- override output_file_name to unit file for multiple itax_org
      if l_itax_org_cnt > 1
      and (g_file_split is null
          or g_file_split = 'Y') then
      --
        -- reset all output_file_name for l_itax_org_cnt = 1 in same district_code group
        if l_itax_org_cnt = 2 then
        --
          if l_file_over_start > 0 then
          --
            -- override file
            l_file_name := default_file_name(l_district_code);
          --
            if l_file_cnt > 0 then
            --
              g_file_tbl(l_file_cnt).file_name       := l_file_name;
            --
            else
            --
              hr_utility.trace('l_file_cnt is 0 : '||to_char(l_file_cnt));
            --
            end if;
          --
            if l_summary_tbl_cnt > 0 then
            --
              g_summary_tbl(l_summary_tbl_cnt).file_name := l_file_name;
            --
            else
            --
              hr_utility.trace('l_summary_tbl_cnt is 0 : '||to_char(l_summary_tbl_cnt));
            --
            end if;
          --
            <<loop_file_over>>
            for j in l_file_over_start..(i - 1) loop
            --
              l_data_tbl(j).output_file_name := l_file_name;
            --
            end loop loop_file_over;
          --
          else
          --
            hr_utility.trace('l_file_over_start is 0 : '||to_char(l_file_over_start));
          --
          end if;
        --
        end if;
      --
      end if;
    --
    end if;
  --
    -- override output_file_name to unit file for multiple itax_org
    if l_itax_org_cnt > 1
    and (g_file_split is null
        or g_file_split = 'Y') then
    --
      l_data_tbl(i).output_file_name := default_file_name(l_district_code);
    --
    end if;
  --
    -- -----------------------------------------------------
    -- g_file_tbl setup
    -- -----------------------------------------------------
    --
    -- use same l_file_cnt if l_file_name is same
    --
    if l_file_name is null
    or l_file_name <> l_data_tbl(i).output_file_name then
    --
      l_file_cnt := l_file_cnt + 1;
      l_file_name := l_data_tbl(i).output_file_name;
    --
      g_file_tbl(l_file_cnt).file_name := l_file_name;
    --
    end if;
  --
    g_body_tbl(g_assact_tbl(i)).output_file_name               := l_data_tbl(i).output_file_name;
    g_body_tbl(g_assact_tbl(i)).file_ind                       := l_file_cnt;
  --
  -- output data format
  --
    l_itax_org_name := null;
    l_itax_org_address := null;
    l_address := null;
    --l_assortment := null;
    l_pjob_itax_org_address := null;
    l_pjob_itax_org_full_name := null;
    l_original_description := null;
  --
    if g_kana_flag is not null
    and g_kana_flag = 'Y' then
    --
      -- format same as payjpwtm
      l_itax_org_address        := hr_jp_standard_pkg.upper_kana(l_data_tbl(i).itax_org_address_kana);
      l_itax_org_name           := hr_jp_standard_pkg.upper_kana(l_data_tbl(i).itax_org_name_kana);
      l_address                 := hr_jp_standard_pkg.upper_kana(l_data_tbl(i).address_kana);
      --
      if l_assortment is null then
        l_assortment            := fnd_message.get_string('PAY','PAY_JP_WIC_EARNINGS_TYPE_KANA');
      end if;
      --
      l_pjob_itax_org_address   := l_data_tbl(i).prev_job_employer_add_kana;
      l_pjob_itax_org_full_name := l_data_tbl(i).prev_job_employer_name_kana;
      --
      l_original_description    := l_data_tbl(i).original_description_kana;
      if g_arch_pact_exist is null
      or g_arch_pact_exist <> 'Y' then
      --
        -- format same as payjpwtm
        l_original_description    := hr_jp_standard_pkg.upper_kana(hr_jp_standard_pkg.to_hankaku(l_original_description));
      --
      end if;
    --
    else
    --
      l_itax_org_address        := l_data_tbl(i).itax_org_address;
      l_itax_org_name           := l_data_tbl(i).itax_org_name;
      l_address                 := l_data_tbl(i).address;
    --
      if l_assortment is null then
        l_assortment            := fnd_message.get_string('PAY','PAY_JP_WIC_EARNINGS_TYPE_KANJI');
      end if;
      --
      l_pjob_itax_org_address   := l_data_tbl(i).prev_job_employer_add;
      l_pjob_itax_org_full_name := l_data_tbl(i).prev_job_employer_name;
      l_original_description    := l_data_tbl(i).original_description;
    --
    end if;
  --
    l_desc_chr_len := c_desc_chr_len;
    if g_effective_yyyy >= 2009 then
    --
      l_desc_chr_len := c_desc_chr_len_2009;
    --
    end if;
  --
    l_dep_spouse := null;
    if l_data_tbl(i).dependent_spouse_exists_kou = l_yes then
      l_dep_spouse := '1';
    elsif l_data_tbl(i).dependent_spouse_no_exist_kou = l_yes then
      l_dep_spouse := '2';
    elsif l_data_tbl(i).dependent_spouse_exists_otsu = l_yes then
      l_dep_spouse := '3';
    elsif l_data_tbl(i).dependent_spouse_no_exist_otsu = l_yes then
      l_dep_spouse := '4';
    end if;
    --
    l_aged_spouse := '0';
    if l_data_tbl(i).aged_spouse_exists = l_yes then
      l_aged_spouse := '1';
    end if;
    --
    l_husband_exists := null;
    l_aged := null;
    if g_effective_yyyy < 2005 then
    --
      l_husband_exists := pay_jp_report_pkg.decode_value(l_data_tbl(i).husband_exists = l_yes,'1','0');
      l_aged := pay_jp_report_pkg.decode_value(l_data_tbl(i).aged = l_yes,'1','0');
    --
    end if;
    --
    l_widow := '0';
    if l_data_tbl(i).widow = l_yes then
      l_widow := '1';
    elsif l_data_tbl(i).special_widow = l_yes then
      l_widow := '2';
    end if;
    --
    l_employed := '0';
    l_employed_date := null;
    -- set actual_termination_date in case when both term and start exists
    if l_data_tbl(i).actual_termination_date is not null then
    --
      l_employed := '2';
      l_employed_date := l_data_tbl(i).actual_termination_date;
      l_term_emp_cnt := l_term_emp_cnt + 1;
    --
    elsif l_data_tbl(i).date_start is not null then
    --
      l_employed := '1';
      l_employed_date := l_data_tbl(i).date_start;
    --
    end if;
    --
    l_pjob_itax_org_address_jp := '0';
    if l_data_tbl(i).prev_job_foreign_address = l_yes
    or l_data_tbl(i).prev_job_foreign_address = '1' then
      l_pjob_itax_org_address_jp := '1';
    end if;
    --
    -- format same as payjpwtm
    l_full_name_kana := hr_jp_standard_pkg.upper_kana(l_data_tbl(i).full_name_kana);
  --
  -- output data setup
  --
    g_body_tbl(g_assact_tbl(i)).o_form_number               := pay_jp_report_pkg.cnv_siz('h',3  ,c_form_number);
    g_body_tbl(g_assact_tbl(i)).o_itax_org_serial1          := pay_jp_report_pkg.cnv_siz('h',10 ,pay_jp_report_pkg.csvspchar(pay_jp_report_pkg.cnv_str(l_data_tbl(i).itax_org_serial1)));
    g_body_tbl(g_assact_tbl(i)).o_itax_org_cnt              := pay_jp_report_pkg.cnv_siz('h',50 ,l_itax_org_cnt);
    g_body_tbl(g_assact_tbl(i)).o_itax_org_address          := pay_jp_report_pkg.cnv_siz('z',60 ,pay_jp_report_pkg.cnv_str(l_itax_org_address));
    g_body_tbl(g_assact_tbl(i)).o_itax_org_name             := pay_jp_report_pkg.cnv_siz('z',30 ,pay_jp_report_pkg.cnv_str(l_itax_org_name));
    g_body_tbl(g_assact_tbl(i)).o_itax_org_phone            := pay_jp_report_pkg.cnv_siz('h',15 ,pay_jp_report_pkg.csvspchar(pay_jp_report_pkg.cnv_str(l_data_tbl(i).itax_org_phone)));
    g_body_tbl(g_assact_tbl(i)).o_itax_org_serial2          := pay_jp_report_pkg.cnv_siz('h',13 ,pay_jp_report_pkg.csvspchar(pay_jp_report_pkg.cnv_str(l_data_tbl(i).itax_org_serial2)));
    g_body_tbl(g_assact_tbl(i)).o_itax_hq_address           := pay_jp_report_pkg.cnv_siz('z',60 ,to_char(null));
    g_body_tbl(g_assact_tbl(i)).o_itax_hq_name              := pay_jp_report_pkg.cnv_siz('z',30 ,to_char(null));
    g_body_tbl(g_assact_tbl(i)).o_amend_flag                := pay_jp_report_pkg.cnv_siz('h',1  ,c_amend_flag);
    g_body_tbl(g_assact_tbl(i)).o_target_yy                 := pay_jp_report_pkg.cnv_siz('h',2  ,to_char(g_effective_soy,'YY','nls_calendar=''Japanese Imperial'''));
    g_body_tbl(g_assact_tbl(i)).o_address                   := pay_jp_report_pkg.cnv_siz('z',60 ,pay_jp_report_pkg.cnv_str(l_address));
    g_body_tbl(g_assact_tbl(i)).o_address_jp                := pay_jp_report_pkg.cnv_siz('h',1  ,l_data_tbl(i).address_jp);
    g_body_tbl(g_assact_tbl(i)).o_full_name                 := pay_jp_report_pkg.cnv_siz('z',30 ,pay_jp_report_pkg.cnv_str(l_data_tbl(i).full_name));
    g_body_tbl(g_assact_tbl(i)).o_position                  := pay_jp_report_pkg.cnv_siz('z',15 ,to_char(null));
    g_body_tbl(g_assact_tbl(i)).o_assortment                := pay_jp_report_pkg.cnv_siz('z',10 ,l_assortment);
    g_body_tbl(g_assact_tbl(i)).o_taxable_income            := pay_jp_report_pkg.cnv_siz('h',10 ,l_data_tbl(i).taxable_income);
    g_body_tbl(g_assact_tbl(i)).o_unpaid_income             := pay_jp_report_pkg.cnv_siz('h',10 ,c_unpaid_income);
    g_body_tbl(g_assact_tbl(i)).o_net_taxable_income        := pay_jp_report_pkg.cnv_siz('h',10 ,l_data_tbl(i).net_taxable_income);
    g_body_tbl(g_assact_tbl(i)).o_total_income_exempt       := pay_jp_report_pkg.cnv_siz('h',10 ,l_data_tbl(i).total_income_exempt);
    g_body_tbl(g_assact_tbl(i)).o_withholding_itax          := pay_jp_report_pkg.cnv_siz('h',10 ,l_data_tbl(i).withholding_itax);
    g_body_tbl(g_assact_tbl(i)).o_uncollected_itax          := pay_jp_report_pkg.cnv_siz('h',10 ,c_uncollected_itax);
    g_body_tbl(g_assact_tbl(i)).o_dep_spouse                := pay_jp_report_pkg.cnv_siz('h',1  ,l_dep_spouse);
    g_body_tbl(g_assact_tbl(i)).o_aged_spouse               := pay_jp_report_pkg.cnv_siz('h',1  ,l_aged_spouse);
    g_body_tbl(g_assact_tbl(i)).o_spouse_sp_exempt          := pay_jp_report_pkg.cnv_siz('h',10 ,l_data_tbl(i).spouse_special_exempt);
    g_body_tbl(g_assact_tbl(i)).o_num_specifieds_kou        := pay_jp_report_pkg.cnv_siz('h',2  ,l_data_tbl(i).num_specifieds_kou);
    g_body_tbl(g_assact_tbl(i)).o_num_specifieds_otsu       := pay_jp_report_pkg.cnv_siz('h',2  ,l_data_tbl(i).num_specifieds_otsu);
    g_body_tbl(g_assact_tbl(i)).o_num_ageds_kou             := pay_jp_report_pkg.cnv_siz('h',2  ,l_data_tbl(i).num_ageds_kou);
    g_body_tbl(g_assact_tbl(i)).o_num_aged_parents_lt       := pay_jp_report_pkg.cnv_siz('h',2  ,l_data_tbl(i).num_aged_parents_partial);
    g_body_tbl(g_assact_tbl(i)).o_num_ageds_otsu            := pay_jp_report_pkg.cnv_siz('h',2  ,l_data_tbl(i).num_ageds_otsu);
    g_body_tbl(g_assact_tbl(i)).o_num_deps_kou              := pay_jp_report_pkg.cnv_siz('h',2  ,l_data_tbl(i).num_dependents_kou);
    g_body_tbl(g_assact_tbl(i)).o_num_deps_otsu             := pay_jp_report_pkg.cnv_siz('h',2  ,l_data_tbl(i).num_dependents_otsu);
    g_body_tbl(g_assact_tbl(i)).o_num_svr_disableds         := pay_jp_report_pkg.cnv_siz('h',2  ,l_data_tbl(i).num_special_disableds);
    g_body_tbl(g_assact_tbl(i)).o_num_svr_disableds_lt      := pay_jp_report_pkg.cnv_siz('h',2  ,l_data_tbl(i).num_special_disableds_partial);
    g_body_tbl(g_assact_tbl(i)).o_num_disableds             := pay_jp_report_pkg.cnv_siz('h',2  ,l_data_tbl(i).num_disableds);
    g_body_tbl(g_assact_tbl(i)).o_si_prem                   := pay_jp_report_pkg.cnv_siz('h',10 ,l_data_tbl(i).social_insurance_premium);
    g_body_tbl(g_assact_tbl(i)).o_mutual_aid_prem           := pay_jp_report_pkg.cnv_siz('h',10 ,l_data_tbl(i).mutual_aid_premium);
    g_body_tbl(g_assact_tbl(i)).o_li_prem_exempt            := pay_jp_report_pkg.cnv_siz('h',10 ,l_data_tbl(i).life_insurance_premium_exempt);
    g_body_tbl(g_assact_tbl(i)).o_ai_prem_exempt            := pay_jp_report_pkg.cnv_siz('h',10 ,l_data_tbl(i).damage_insurance_premium_exem);
    g_body_tbl(g_assact_tbl(i)).o_housing_tax_reduction     := pay_jp_report_pkg.cnv_siz('h',10 ,l_data_tbl(i).housing_tax_reduction);
    g_body_tbl(g_assact_tbl(i)).o_pp_prem                   := pay_jp_report_pkg.cnv_siz('h',10 ,l_data_tbl(i).private_pension_premium);
    g_body_tbl(g_assact_tbl(i)).o_spouse_net_taxable_income := pay_jp_report_pkg.cnv_siz('h',10 ,l_data_tbl(i).spouse_net_taxable_income);
    g_body_tbl(g_assact_tbl(i)).o_long_ai_prem              := pay_jp_report_pkg.cnv_siz('h',10 ,l_data_tbl(i).long_damage_insurance_premium);
    g_body_tbl(g_assact_tbl(i)).o_birth_date_era            := pay_jp_report_pkg.cnv_siz('h',1  ,file_era_code(to_char(l_data_tbl(i).date_of_birth,'E','nls_calendar=''Japanese Imperial''')));
    g_body_tbl(g_assact_tbl(i)).o_birth_date_yy             := pay_jp_report_pkg.cnv_siz('h',2  ,to_char(l_data_tbl(i).date_of_birth,'YY','nls_calendar=''Japanese Imperial'''));
    g_body_tbl(g_assact_tbl(i)).o_birth_date_mm             := pay_jp_report_pkg.cnv_siz('h',2  ,to_char(l_data_tbl(i).date_of_birth,'MM','nls_calendar=''Japanese Imperial'''));
    g_body_tbl(g_assact_tbl(i)).o_birth_date_dd             := pay_jp_report_pkg.cnv_siz('h',2  ,to_char(l_data_tbl(i).date_of_birth,'DD','nls_calendar=''Japanese Imperial'''));
    g_body_tbl(g_assact_tbl(i)).o_husband_exists            := pay_jp_report_pkg.cnv_siz('h',1  ,l_husband_exists);
    g_body_tbl(g_assact_tbl(i)).o_minor                     := pay_jp_report_pkg.cnv_siz('h',1  ,pay_jp_report_pkg.decode_value(l_data_tbl(i).minor = l_yes,'1','0'));
    g_body_tbl(g_assact_tbl(i)).o_otsu                      := pay_jp_report_pkg.cnv_siz('h',1  ,pay_jp_report_pkg.decode_value(l_data_tbl(i).otsu = l_yes,'1','0'));
    g_body_tbl(g_assact_tbl(i)).o_svr_disabled              := pay_jp_report_pkg.cnv_siz('h',1  ,pay_jp_report_pkg.decode_value(l_data_tbl(i).special_disabled = l_yes,'1','0'));
    g_body_tbl(g_assact_tbl(i)).o_disabled                  := pay_jp_report_pkg.cnv_siz('h',1  ,pay_jp_report_pkg.decode_value(l_data_tbl(i).disabled = l_yes,'1','0'));
    g_body_tbl(g_assact_tbl(i)).o_aged                      := pay_jp_report_pkg.cnv_siz('h',1  ,l_aged);
    g_body_tbl(g_assact_tbl(i)).o_widow                     := pay_jp_report_pkg.cnv_siz('h',1  ,l_widow);
    g_body_tbl(g_assact_tbl(i)).o_widower                   := pay_jp_report_pkg.cnv_siz('h',1  ,pay_jp_report_pkg.decode_value(l_data_tbl(i).widower = l_yes,'1','0'));
    g_body_tbl(g_assact_tbl(i)).o_working_student           := pay_jp_report_pkg.cnv_siz('h',1  ,pay_jp_report_pkg.decode_value(l_data_tbl(i).working_student = l_yes,'1','0'));
    g_body_tbl(g_assact_tbl(i)).o_deceased_termination      := pay_jp_report_pkg.cnv_siz('h',1  ,pay_jp_report_pkg.decode_value(l_data_tbl(i).deceased_termination = l_yes,'1','0'));
    g_body_tbl(g_assact_tbl(i)).o_disastered                := pay_jp_report_pkg.cnv_siz('h',1  ,pay_jp_report_pkg.decode_value(l_data_tbl(i).disastered = l_yes,'1','0'));
    g_body_tbl(g_assact_tbl(i)).o_foreigner                 := pay_jp_report_pkg.cnv_siz('h',1  ,pay_jp_report_pkg.decode_value(l_data_tbl(i).foreigner = l_yes,'1','0'));
    g_body_tbl(g_assact_tbl(i)).o_employed                  := pay_jp_report_pkg.cnv_siz('h',1  ,l_employed);
    g_body_tbl(g_assact_tbl(i)).o_employed_yy               := pay_jp_report_pkg.cnv_siz('h',2  ,to_char(l_employed_date,'YY','nls_calendar=''Japanese Imperial'''));
    g_body_tbl(g_assact_tbl(i)).o_employed_mm               := pay_jp_report_pkg.cnv_siz('h',2  ,to_char(l_employed_date,'MM','nls_calendar=''Japanese Imperial'''));
    g_body_tbl(g_assact_tbl(i)).o_employed_dd               := pay_jp_report_pkg.cnv_siz('h',2  ,to_char(l_employed_date,'DD','nls_calendar=''Japanese Imperial'''));
    g_body_tbl(g_assact_tbl(i)).o_pjob_itax_org_address     := pay_jp_report_pkg.cnv_siz('z',60 ,pay_jp_report_pkg.cnv_str(l_pjob_itax_org_address));
    g_body_tbl(g_assact_tbl(i)).o_pjob_itax_org_address_jp  := pay_jp_report_pkg.cnv_siz('h',1  ,l_pjob_itax_org_address_jp);
    g_body_tbl(g_assact_tbl(i)).o_pjob_itax_org_full_name   := pay_jp_report_pkg.cnv_siz('z',30 ,pay_jp_report_pkg.cnv_str(l_pjob_itax_org_full_name));
    g_body_tbl(g_assact_tbl(i)).o_pjob_taxable_income       := pay_jp_report_pkg.cnv_siz('h',10 ,l_data_tbl(i).prev_job_taxable_income);
    g_body_tbl(g_assact_tbl(i)).o_pjob_itax                 := pay_jp_report_pkg.cnv_siz('h',10 ,l_data_tbl(i).prev_job_itax);
    g_body_tbl(g_assact_tbl(i)).o_pjob_si_prem              := pay_jp_report_pkg.cnv_siz('h',10 ,l_data_tbl(i).prev_job_si_prem);
    g_body_tbl(g_assact_tbl(i)).o_disaster_tax_reduction    := pay_jp_report_pkg.cnv_siz('h',10 ,l_data_tbl(i).disaster_tax_reduction);
    g_body_tbl(g_assact_tbl(i)).o_pjob_termination_date_yy  := pay_jp_report_pkg.cnv_siz('h',2  ,lpad(to_char(l_data_tbl(i).prev_job_termination_year),2,'0'));
    g_body_tbl(g_assact_tbl(i)).o_pjob_termination_date_mm  := pay_jp_report_pkg.cnv_siz('h',2  ,lpad(to_char(l_data_tbl(i).prev_job_termination_month),2,'0'));
    g_body_tbl(g_assact_tbl(i)).o_pjob_termination_date_dd  := pay_jp_report_pkg.cnv_siz('h',2  ,lpad(to_char(l_data_tbl(i).prev_job_termination_day),2,'0'));
    g_body_tbl(g_assact_tbl(i)).o_hld_residence_date_1_yy   := pay_jp_report_pkg.cnv_siz('h',2  ,lpad(to_char(l_data_tbl(i).hld_residence_date_1_year),2,'0'));
    g_body_tbl(g_assact_tbl(i)).o_hld_residence_date_1_mm   := pay_jp_report_pkg.cnv_siz('h',2  ,lpad(to_char(l_data_tbl(i).hld_residence_date_1_month),2,'0'));
    g_body_tbl(g_assact_tbl(i)).o_hld_residence_date_1_dd   := pay_jp_report_pkg.cnv_siz('h',2  ,lpad(to_char(l_data_tbl(i).hld_residence_date_1_day),2,'0'));
    g_body_tbl(g_assact_tbl(i)).o_hld_loan_count            := pay_jp_report_pkg.cnv_siz('h',1  ,l_data_tbl(i).hld_loan_count);
    g_body_tbl(g_assact_tbl(i)).o_hld_payable_loan          := pay_jp_report_pkg.cnv_siz('h',10 ,l_data_tbl(i).hld_payable_loan);
    g_body_tbl(g_assact_tbl(i)).o_hld_loan_type_1           := pay_jp_report_pkg.cnv_siz('h',2  ,l_data_tbl(i).hld_loan_type_1);
    g_body_tbl(g_assact_tbl(i)).o_hld_loan_balance_1        := pay_jp_report_pkg.cnv_siz('h',8  ,l_data_tbl(i).hld_loan_balance_1);
    g_body_tbl(g_assact_tbl(i)).o_hld_residence_date_2_yy   := pay_jp_report_pkg.cnv_siz('h',2  ,lpad(to_char(l_data_tbl(i).hld_residence_date_2_year),2,'0'));
    g_body_tbl(g_assact_tbl(i)).o_hld_residence_date_2_mm   := pay_jp_report_pkg.cnv_siz('h',2  ,lpad(to_char(l_data_tbl(i).hld_residence_date_2_month),2,'0'));
    g_body_tbl(g_assact_tbl(i)).o_hld_residence_date_2_dd   := pay_jp_report_pkg.cnv_siz('h',2  ,lpad(to_char(l_data_tbl(i).hld_residence_date_2_day),2,'0'));
    g_body_tbl(g_assact_tbl(i)).o_hld_loan_type_2           := pay_jp_report_pkg.cnv_siz('h',2  ,l_data_tbl(i).hld_loan_type_2);
    g_body_tbl(g_assact_tbl(i)).o_hld_loan_balance_2        := pay_jp_report_pkg.cnv_siz('h',8  ,l_data_tbl(i).hld_loan_balance_2);
    g_body_tbl(g_assact_tbl(i)).o_description               := pay_jp_report_pkg.cnv_siz('z',l_desc_chr_len,pay_jp_report_pkg.cnv_str(l_original_description));
    g_body_tbl(g_assact_tbl(i)).o_gen_collecting            := pay_jp_report_pkg.cnv_siz('h',1  ,c_gen_collecting);
    g_body_tbl(g_assact_tbl(i)).o_blue_proprietor           := pay_jp_report_pkg.cnv_siz('h',1  ,c_blue_proprietor);
    g_body_tbl(g_assact_tbl(i)).o_immune                    := pay_jp_report_pkg.cnv_siz('h',1  ,c_immune);
    g_body_tbl(g_assact_tbl(i)).o_full_name_kana            := pay_jp_report_pkg.cnv_siz('h',60 ,pay_jp_report_pkg.csvspchar(pay_jp_report_pkg.cnv_str(l_full_name_kana)));
    g_body_tbl(g_assact_tbl(i)).o_employee_number           := pay_jp_report_pkg.cnv_siz('h',25 ,pay_jp_report_pkg.csvspchar(pay_jp_report_pkg.cnv_str(l_data_tbl(i).employee_number)));
    g_body_tbl(g_assact_tbl(i)).o_district_code             := pay_jp_report_pkg.cnv_siz('h',6  ,l_district_code);
    g_body_tbl(g_assact_tbl(i)).o_swot_number               := pay_jp_report_pkg.cnv_siz('h',12 ,pay_jp_report_pkg.csvspchar(pay_jp_report_pkg.cnv_str(l_data_tbl(i).swot_number)));
  --
  -- warning data setup
  --
    g_body_tbl(g_assact_tbl(i)).long_description := null;
    if g_show_warning is null
    or g_show_warning = 'Y' then
    --
      if g_body_tbl(g_assact_tbl(i)).o_description <> hr_jp_standard_pkg.to_zenkaku(pay_jp_report_pkg.cnv_str(l_original_description)) then
      --
        g_warning_exist := 'Y';
        g_body_tbl(g_assact_tbl(i)).long_description := hr_jp_standard_pkg.to_zenkaku(pay_jp_report_pkg.cnv_str(l_original_description));
      --
      end if;
    --
    end if;
  --
  -- sumamry data setup
  --
    if g_show_summary is null
    or g_show_summary = 'Y' then
    --
      if l_district_code_chg then
      --
        l_summary_tbl_cnt := l_summary_tbl_cnt + 1;
      --
        g_summary_tbl(l_summary_tbl_cnt).file_name     := l_file_name;
        g_summary_tbl(l_summary_tbl_cnt).district_code := l_district_code;
      --
      end if;
    --
      --
      -- override to leave last record
      --
      g_summary_tbl(l_summary_tbl_cnt).itax_org_cnt := l_itax_org_cnt;
      g_summary_tbl(l_summary_tbl_cnt).emp_cnt      := l_emp_cnt;
      g_summary_tbl(l_summary_tbl_cnt).term_emp_cnt := l_term_emp_cnt;
    --
    end if;
  --
  end loop;
--
  if g_debug
  and g_detail_debug = 'Y' then
    hr_utility.set_location(l_proc,60);
    hr_utility.trace('g_file_tbl.count : '||to_char(g_file_tbl.count));
  end if;
--
  -- -----------------------------------------------------
  -- file open
  -- -----------------------------------------------------
  if g_file_tbl.count > 0 then
  --
    for i in 1..g_file_tbl.count loop
    --
      l_file_out := null;
      pay_jp_report_pkg.open_file(g_file_tbl(i).file_name,g_file_dir,l_file_out,'a');
    --
      g_file_tbl(i).file_out := l_file_out;
    --
    end loop;
  --
  end if;
--
  if g_debug
  and g_detail_debug = 'Y' then
  --
    if g_assact_tbl.count > 0 then
    --
      for i in 1..g_assact_tbl.count loop
      --
        hr_utility.trace('g_assact_tbl : '||to_char(i)||
          ' : '||to_char(g_assact_tbl(i))||' - g_body_tbl.mag_assignment_action_id : '||
          to_char(g_body_tbl(g_assact_tbl(i)).mag_assignment_action_id));
      --
      end loop;
    --
    else
      hr_utility.trace('g_assact_tbl.count is 0');
    end if;
  --
    hr_utility.set_location(l_proc,70);
  --
    if g_file_tbl.count > 0 then
    --
      for i in 1..g_file_tbl.count loop
      --
        hr_utility.trace('g_file_tbl : '||to_char(i)||' : '||g_file_tbl(i).file_name);
      --
      end loop;
    --
    else
      hr_utility.trace('g_file_tbl.count is 0');
    end if;
  --
    hr_utility.set_location(l_proc,80);
  --
  end if;
--
  if g_debug then
  --
    hr_utility.trace('g_assact_tbl.count  : '||to_char(g_assact_tbl.count));
    hr_utility.trace('g_file_tbl.count    : '||to_char(g_file_tbl.count));
    hr_utility.trace('g_body_tbl.count    : '||to_char(g_body_tbl.count));
    hr_utility.trace('g_warning_exist     : '||g_warning_exist);
    hr_utility.trace('g_summary_tbl.count : '||to_char(g_summary_tbl.count));
  --
    hr_utility.set_location(l_proc,1000);
  --
  end if;
--
end archinit;
--
-- -------------------------------------------------------------------------
-- init_assact
-- -------------------------------------------------------------------------
--procedure init_assact(
--  p_assignment_action_id in number,
--  p_assignment_id        in number)
--is
----
--  l_proc varchar2(80) := c_package||'init_assact';
----
--begin
----
--  if g_debug
--  and g_detail_debug = 'Y' then
--    hr_utility.set_location(l_proc,0);
--  end if;
----
--  if g_assignment_action_id is null
--  or g_assignment_action_id <> p_assignment_action_id then
--  --
--    if g_debug
--    and g_detail_debug = 'Y' then
--      hr_utility.set_location(l_proc,10);
--      hr_utility.trace('no cache : g_assact_id('||g_assignment_action_id||'),p_assact_id('||p_assignment_action_id||')');
--    end if;
--  --
--    g_assignment_action_id := p_assignment_action_id;
--    g_assignment_id := p_assignment_id;
--  --
--  end if;
--  --
--  if g_debug
--  and g_detail_debug = 'Y' then
--    hr_utility.trace('assignment_action_id : '||g_assignment_action_id);
--    hr_utility.trace('assignment_id        : '||g_assignment_id);
--    hr_utility.set_location(l_proc,1000);
--  end if;
----
--end init_assact;
--
-- -------------------------------------------------------------------------
-- archive_assact
-- -------------------------------------------------------------------------
--procedure archive_assact(
--  p_assignment_action_id in number,
--  p_assignment_id        in number)
--is
----
--  l_proc varchar2(80) := c_package||'archive_assact';
----
--begin
----
--  if g_debug
--  and g_detail_debug = 'Y' then
--    hr_utility.set_location(l_proc,0);
--  end if;
----
--  if g_debug
--  and g_detail_debug = 'Y' then
--    hr_utility.set_location(l_proc,1000);
--  end if;
----
--end archive_assact;
--
-- -------------------------------------------------------------------------
-- xml_assact
-- -------------------------------------------------------------------------
procedure xml_assact(
  p_assignment_action_id in number)
is
--
  l_proc varchar2(80) := c_package||'xml_assact';
--
  l_mag_assignment_action_id number;
  l_original_description varchar2(32767);
--
  l_xml_assact varchar2(32767);
--
begin
--
  if g_debug
  and g_detail_debug = 'Y' then
    hr_utility.set_location(l_proc,0);
    hr_utility.trace('p_assignment_action_id : '||to_char(p_assignment_action_id));
  end if;
--
  l_mag_assignment_action_id := g_body_tbl(p_assignment_action_id).mag_assignment_action_id;
--
  if l_mag_assignment_action_id is not null
  and l_mag_assignment_action_id = p_assignment_action_id then
  --
    if g_debug
    and g_detail_debug = 'Y' then
    --
      --
      if g_effective_yyyy < 2009 then
      --
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d1', g_body_tbl(p_assignment_action_id).o_form_number              ));
        hr_utility.trace(pay_jp_report_pkg.add_tag_v('d2', g_body_tbl(p_assignment_action_id).o_itax_org_serial1         ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d3', g_body_tbl(p_assignment_action_id).o_itax_org_cnt             ));
        hr_utility.trace(pay_jp_report_pkg.add_tag_v('d4', g_body_tbl(p_assignment_action_id).o_itax_org_address         ));
        hr_utility.trace(pay_jp_report_pkg.add_tag_v('d5', g_body_tbl(p_assignment_action_id).o_itax_org_name            ));
        hr_utility.trace(pay_jp_report_pkg.add_tag_v('d6', g_body_tbl(p_assignment_action_id).o_itax_org_phone           ));
        hr_utility.trace(pay_jp_report_pkg.add_tag_v('d7', g_body_tbl(p_assignment_action_id).o_itax_org_serial2         ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d8', g_body_tbl(p_assignment_action_id).o_itax_hq_address          ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d9', g_body_tbl(p_assignment_action_id).o_itax_hq_name             ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d10',g_body_tbl(p_assignment_action_id).o_amend_flag               ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d11',g_body_tbl(p_assignment_action_id).o_target_yy                ));
        hr_utility.trace(pay_jp_report_pkg.add_tag_v('d12',g_body_tbl(p_assignment_action_id).o_address                  ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d13',g_body_tbl(p_assignment_action_id).o_address_jp               ));
        hr_utility.trace(pay_jp_report_pkg.add_tag_v('d14',g_body_tbl(p_assignment_action_id).o_full_name                ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d15',g_body_tbl(p_assignment_action_id).o_position                 ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d16',g_body_tbl(p_assignment_action_id).o_assortment               ));
        hr_utility.trace(pay_jp_report_pkg.add_tag_m('d17',g_body_tbl(p_assignment_action_id).o_taxable_income           ));
        hr_utility.trace(pay_jp_report_pkg.add_tag_m('d18',g_body_tbl(p_assignment_action_id).o_unpaid_income            ));
        hr_utility.trace(pay_jp_report_pkg.add_tag_m('d19',g_body_tbl(p_assignment_action_id).o_net_taxable_income       ));
        hr_utility.trace(pay_jp_report_pkg.add_tag_m('d20',g_body_tbl(p_assignment_action_id).o_total_income_exempt      ));
        hr_utility.trace(pay_jp_report_pkg.add_tag_m('d21',g_body_tbl(p_assignment_action_id).o_withholding_itax         ));
        hr_utility.trace(pay_jp_report_pkg.add_tag_m('d22',g_body_tbl(p_assignment_action_id).o_uncollected_itax         ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d23',g_body_tbl(p_assignment_action_id).o_dep_spouse               ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d24',g_body_tbl(p_assignment_action_id).o_aged_spouse              ));
        hr_utility.trace(pay_jp_report_pkg.add_tag_m('d25',g_body_tbl(p_assignment_action_id).o_spouse_sp_exempt         ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d26',g_body_tbl(p_assignment_action_id).o_num_specifieds_kou       ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d27',g_body_tbl(p_assignment_action_id).o_num_specifieds_otsu      ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d28',g_body_tbl(p_assignment_action_id).o_num_ageds_kou            ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d29',g_body_tbl(p_assignment_action_id).o_num_aged_parents_lt      ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d30',g_body_tbl(p_assignment_action_id).o_num_ageds_otsu           ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d31',g_body_tbl(p_assignment_action_id).o_num_deps_kou             ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d32',g_body_tbl(p_assignment_action_id).o_num_deps_otsu            ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d33',g_body_tbl(p_assignment_action_id).o_num_svr_disableds        ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d34',g_body_tbl(p_assignment_action_id).o_num_svr_disableds_lt     ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d35',g_body_tbl(p_assignment_action_id).o_num_disableds            ));
        hr_utility.trace(pay_jp_report_pkg.add_tag_m('d36',g_body_tbl(p_assignment_action_id).o_si_prem                  ));
        hr_utility.trace(pay_jp_report_pkg.add_tag_m('d37',g_body_tbl(p_assignment_action_id).o_mutual_aid_prem          ));
        hr_utility.trace(pay_jp_report_pkg.add_tag_m('d38',g_body_tbl(p_assignment_action_id).o_li_prem_exempt           ));
        hr_utility.trace(pay_jp_report_pkg.add_tag_m('d39',g_body_tbl(p_assignment_action_id).o_ai_prem_exempt           ));
        hr_utility.trace(pay_jp_report_pkg.add_tag_m('d40',g_body_tbl(p_assignment_action_id).o_housing_tax_reduction    ));
        hr_utility.trace(pay_jp_report_pkg.add_tag_m('d41',g_body_tbl(p_assignment_action_id).o_pp_prem                  ));
        hr_utility.trace(pay_jp_report_pkg.add_tag_m('d42',g_body_tbl(p_assignment_action_id).o_spouse_net_taxable_income));
        hr_utility.trace(pay_jp_report_pkg.add_tag_m('d43',g_body_tbl(p_assignment_action_id).o_long_ai_prem             ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d44',g_body_tbl(p_assignment_action_id).o_birth_date_era           ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d45',g_body_tbl(p_assignment_action_id).o_birth_date_yy            ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d46',g_body_tbl(p_assignment_action_id).o_birth_date_mm            ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d47',g_body_tbl(p_assignment_action_id).o_birth_date_dd            ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d48',g_body_tbl(p_assignment_action_id).o_husband_exists           ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d49',g_body_tbl(p_assignment_action_id).o_minor                    ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d50',g_body_tbl(p_assignment_action_id).o_otsu                     ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d51',g_body_tbl(p_assignment_action_id).o_svr_disabled             ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d52',g_body_tbl(p_assignment_action_id).o_disabled                 ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d53',g_body_tbl(p_assignment_action_id).o_aged                     ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d54',g_body_tbl(p_assignment_action_id).o_widow                    ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d55',g_body_tbl(p_assignment_action_id).o_widower                  ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d56',g_body_tbl(p_assignment_action_id).o_working_student          ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d57',g_body_tbl(p_assignment_action_id).o_deceased_termination     ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d58',g_body_tbl(p_assignment_action_id).o_disastered               ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d59',g_body_tbl(p_assignment_action_id).o_foreigner                ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d60',g_body_tbl(p_assignment_action_id).o_employed                 ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d61',g_body_tbl(p_assignment_action_id).o_employed_yy              ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d62',g_body_tbl(p_assignment_action_id).o_employed_mm              ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d63',g_body_tbl(p_assignment_action_id).o_employed_dd              ));
        hr_utility.trace(pay_jp_report_pkg.add_tag_v('d64',g_body_tbl(p_assignment_action_id).o_pjob_itax_org_address    ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d65',g_body_tbl(p_assignment_action_id).o_pjob_itax_org_address_jp ));
        hr_utility.trace(pay_jp_report_pkg.add_tag_v('d66',g_body_tbl(p_assignment_action_id).o_pjob_itax_org_full_name  ));
        hr_utility.trace(pay_jp_report_pkg.add_tag_m('d67',g_body_tbl(p_assignment_action_id).o_pjob_taxable_income      ));
        hr_utility.trace(pay_jp_report_pkg.add_tag_m('d68',g_body_tbl(p_assignment_action_id).o_pjob_itax                ));
        hr_utility.trace(pay_jp_report_pkg.add_tag_m('d69',g_body_tbl(p_assignment_action_id).o_pjob_si_prem             ));
        hr_utility.trace(pay_jp_report_pkg.add_tag_m('d70',g_body_tbl(p_assignment_action_id).o_disaster_tax_reduction   ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d71',g_body_tbl(p_assignment_action_id).o_pjob_termination_date_yy ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d72',g_body_tbl(p_assignment_action_id).o_pjob_termination_date_mm ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d73',g_body_tbl(p_assignment_action_id).o_pjob_termination_date_dd ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d74',g_body_tbl(p_assignment_action_id).o_hld_residence_date_1_yy  ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d75',g_body_tbl(p_assignment_action_id).o_hld_residence_date_1_mm  ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d76',g_body_tbl(p_assignment_action_id).o_hld_residence_date_1_dd  ));
        hr_utility.trace(pay_jp_report_pkg.add_tag_v('d77',g_body_tbl(p_assignment_action_id).o_description              ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d78',g_body_tbl(p_assignment_action_id).o_gen_collecting           ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d79',g_body_tbl(p_assignment_action_id).o_blue_proprietor          ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d80',g_body_tbl(p_assignment_action_id).o_immune                   ));
        hr_utility.trace(pay_jp_report_pkg.add_tag_v('d81',g_body_tbl(p_assignment_action_id).o_full_name_kana           ));
        hr_utility.trace(pay_jp_report_pkg.add_tag_v('d82',g_body_tbl(p_assignment_action_id).o_employee_number          ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d83',g_body_tbl(p_assignment_action_id).o_district_code            ));
        hr_utility.trace(pay_jp_report_pkg.add_tag_v('d84',g_body_tbl(p_assignment_action_id).o_swot_number              ));
      --
      else
      --
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d1', g_body_tbl(p_assignment_action_id).o_form_number              ));
        hr_utility.trace(pay_jp_report_pkg.add_tag_v('d2', g_body_tbl(p_assignment_action_id).o_itax_org_serial1         ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d3', g_body_tbl(p_assignment_action_id).o_itax_org_cnt             ));
        hr_utility.trace(pay_jp_report_pkg.add_tag_v('d4', g_body_tbl(p_assignment_action_id).o_itax_org_address         ));
        hr_utility.trace(pay_jp_report_pkg.add_tag_v('d5', g_body_tbl(p_assignment_action_id).o_itax_org_name            ));
        hr_utility.trace(pay_jp_report_pkg.add_tag_v('d6', g_body_tbl(p_assignment_action_id).o_itax_org_phone           ));
        hr_utility.trace(pay_jp_report_pkg.add_tag_v('d7', g_body_tbl(p_assignment_action_id).o_itax_org_serial2         ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d8', g_body_tbl(p_assignment_action_id).o_itax_hq_address          ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d9', g_body_tbl(p_assignment_action_id).o_itax_hq_name             ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d10',g_body_tbl(p_assignment_action_id).o_amend_flag               ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d11',g_body_tbl(p_assignment_action_id).o_target_yy                ));
        hr_utility.trace(pay_jp_report_pkg.add_tag_v('d12',g_body_tbl(p_assignment_action_id).o_address                  ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d13',g_body_tbl(p_assignment_action_id).o_address_jp               ));
        hr_utility.trace(pay_jp_report_pkg.add_tag_v('d14',g_body_tbl(p_assignment_action_id).o_full_name                ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d15',g_body_tbl(p_assignment_action_id).o_position                 ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d16',g_body_tbl(p_assignment_action_id).o_assortment               ));
        hr_utility.trace(pay_jp_report_pkg.add_tag_m('d17',g_body_tbl(p_assignment_action_id).o_taxable_income           ));
        hr_utility.trace(pay_jp_report_pkg.add_tag_m('d18',g_body_tbl(p_assignment_action_id).o_unpaid_income            ));
        hr_utility.trace(pay_jp_report_pkg.add_tag_m('d19',g_body_tbl(p_assignment_action_id).o_net_taxable_income       ));
        hr_utility.trace(pay_jp_report_pkg.add_tag_m('d20',g_body_tbl(p_assignment_action_id).o_total_income_exempt      ));
        hr_utility.trace(pay_jp_report_pkg.add_tag_m('d21',g_body_tbl(p_assignment_action_id).o_withholding_itax         ));
        hr_utility.trace(pay_jp_report_pkg.add_tag_m('d22',g_body_tbl(p_assignment_action_id).o_uncollected_itax         ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d23',g_body_tbl(p_assignment_action_id).o_dep_spouse               ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d24',g_body_tbl(p_assignment_action_id).o_aged_spouse              ));
        hr_utility.trace(pay_jp_report_pkg.add_tag_m('d25',g_body_tbl(p_assignment_action_id).o_spouse_sp_exempt         ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d26',g_body_tbl(p_assignment_action_id).o_num_specifieds_kou       ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d27',g_body_tbl(p_assignment_action_id).o_num_specifieds_otsu      ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d28',g_body_tbl(p_assignment_action_id).o_num_ageds_kou            ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d29',g_body_tbl(p_assignment_action_id).o_num_aged_parents_lt      ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d30',g_body_tbl(p_assignment_action_id).o_num_ageds_otsu           ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d31',g_body_tbl(p_assignment_action_id).o_num_deps_kou             ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d32',g_body_tbl(p_assignment_action_id).o_num_deps_otsu            ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d33',g_body_tbl(p_assignment_action_id).o_num_svr_disableds        ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d34',g_body_tbl(p_assignment_action_id).o_num_svr_disableds_lt     ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d35',g_body_tbl(p_assignment_action_id).o_num_disableds            ));
        hr_utility.trace(pay_jp_report_pkg.add_tag_m('d36',g_body_tbl(p_assignment_action_id).o_si_prem                  ));
        hr_utility.trace(pay_jp_report_pkg.add_tag_m('d37',g_body_tbl(p_assignment_action_id).o_mutual_aid_prem          ));
        hr_utility.trace(pay_jp_report_pkg.add_tag_m('d38',g_body_tbl(p_assignment_action_id).o_li_prem_exempt           ));
        hr_utility.trace(pay_jp_report_pkg.add_tag_m('d39',g_body_tbl(p_assignment_action_id).o_ai_prem_exempt           ));
        hr_utility.trace(pay_jp_report_pkg.add_tag_m('d40',g_body_tbl(p_assignment_action_id).o_housing_tax_reduction    ));
        hr_utility.trace(pay_jp_report_pkg.add_tag_m('d41',g_body_tbl(p_assignment_action_id).o_pp_prem                  ));
        hr_utility.trace(pay_jp_report_pkg.add_tag_m('d42',g_body_tbl(p_assignment_action_id).o_spouse_net_taxable_income));
        hr_utility.trace(pay_jp_report_pkg.add_tag_m('d43',g_body_tbl(p_assignment_action_id).o_long_ai_prem             ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d44',g_body_tbl(p_assignment_action_id).o_birth_date_era           ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d45',g_body_tbl(p_assignment_action_id).o_birth_date_yy            ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d46',g_body_tbl(p_assignment_action_id).o_birth_date_mm            ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d47',g_body_tbl(p_assignment_action_id).o_birth_date_dd            ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d48',g_body_tbl(p_assignment_action_id).o_husband_exists           ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d49',g_body_tbl(p_assignment_action_id).o_minor                    ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d50',g_body_tbl(p_assignment_action_id).o_otsu                     ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d51',g_body_tbl(p_assignment_action_id).o_svr_disabled             ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d52',g_body_tbl(p_assignment_action_id).o_disabled                 ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d53',g_body_tbl(p_assignment_action_id).o_aged                     ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d54',g_body_tbl(p_assignment_action_id).o_widow                    ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d55',g_body_tbl(p_assignment_action_id).o_widower                  ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d56',g_body_tbl(p_assignment_action_id).o_working_student          ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d57',g_body_tbl(p_assignment_action_id).o_deceased_termination     ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d58',g_body_tbl(p_assignment_action_id).o_disastered               ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d59',g_body_tbl(p_assignment_action_id).o_foreigner                ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d60',g_body_tbl(p_assignment_action_id).o_employed                 ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d61',g_body_tbl(p_assignment_action_id).o_employed_yy              ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d62',g_body_tbl(p_assignment_action_id).o_employed_mm              ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d63',g_body_tbl(p_assignment_action_id).o_employed_dd              ));
        hr_utility.trace(pay_jp_report_pkg.add_tag_v('d64',g_body_tbl(p_assignment_action_id).o_pjob_itax_org_address    ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d65',g_body_tbl(p_assignment_action_id).o_pjob_itax_org_address_jp ));
        hr_utility.trace(pay_jp_report_pkg.add_tag_v('d66',g_body_tbl(p_assignment_action_id).o_pjob_itax_org_full_name  ));
        hr_utility.trace(pay_jp_report_pkg.add_tag_m('d67',g_body_tbl(p_assignment_action_id).o_pjob_taxable_income      ));
        hr_utility.trace(pay_jp_report_pkg.add_tag_m('d68',g_body_tbl(p_assignment_action_id).o_pjob_itax                ));
        hr_utility.trace(pay_jp_report_pkg.add_tag_m('d69',g_body_tbl(p_assignment_action_id).o_pjob_si_prem             ));
        hr_utility.trace(pay_jp_report_pkg.add_tag_m('d70',g_body_tbl(p_assignment_action_id).o_disaster_tax_reduction   ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d71',g_body_tbl(p_assignment_action_id).o_pjob_termination_date_yy ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d72',g_body_tbl(p_assignment_action_id).o_pjob_termination_date_mm ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d73',g_body_tbl(p_assignment_action_id).o_pjob_termination_date_dd ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d74',g_body_tbl(p_assignment_action_id).o_hld_residence_date_1_yy  ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d75',g_body_tbl(p_assignment_action_id).o_hld_residence_date_1_mm  ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d76',g_body_tbl(p_assignment_action_id).o_hld_residence_date_1_dd  ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d77',g_body_tbl(p_assignment_action_id).o_hld_loan_count           ));
        hr_utility.trace(pay_jp_report_pkg.add_tag_m('d78',g_body_tbl(p_assignment_action_id).o_hld_payable_loan         ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d79',g_body_tbl(p_assignment_action_id).o_hld_loan_type_1          ));
        hr_utility.trace(pay_jp_report_pkg.add_tag_m('d80',g_body_tbl(p_assignment_action_id).o_hld_loan_balance_1       ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d81',g_body_tbl(p_assignment_action_id).o_hld_residence_date_2_yy  ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d82',g_body_tbl(p_assignment_action_id).o_hld_residence_date_2_mm  ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d83',g_body_tbl(p_assignment_action_id).o_hld_residence_date_2_dd  ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d84',g_body_tbl(p_assignment_action_id).o_hld_loan_type_2          ));
        hr_utility.trace(pay_jp_report_pkg.add_tag_m('d85',g_body_tbl(p_assignment_action_id).o_hld_loan_balance_2       ));
        hr_utility.trace(pay_jp_report_pkg.add_tag_v('d86',g_body_tbl(p_assignment_action_id).o_description              ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d87',g_body_tbl(p_assignment_action_id).o_gen_collecting           ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d88',g_body_tbl(p_assignment_action_id).o_blue_proprietor          ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d89',g_body_tbl(p_assignment_action_id).o_immune                   ));
        hr_utility.trace(pay_jp_report_pkg.add_tag_v('d90',g_body_tbl(p_assignment_action_id).o_full_name_kana           ));
        hr_utility.trace(pay_jp_report_pkg.add_tag_v('d91',g_body_tbl(p_assignment_action_id).o_employee_number          ));
        hr_utility.trace(pay_jp_report_pkg.add_tag  ('d92',g_body_tbl(p_assignment_action_id).o_district_code            ));
        hr_utility.trace(pay_jp_report_pkg.add_tag_v('d93',g_body_tbl(p_assignment_action_id).o_swot_number              ));
      --
      end if;
    --
    end if;
  --
    if g_effective_yyyy < 2009 then
    --
      l_xml_assact :=
        '<g_emp>'||c_eol||
        pay_jp_report_pkg.add_tag  ('d1', g_body_tbl(p_assignment_action_id).o_form_number              )||c_eol||
        pay_jp_report_pkg.add_tag_v('d2', g_body_tbl(p_assignment_action_id).o_itax_org_serial1         )||c_eol||
        pay_jp_report_pkg.add_tag  ('d3', g_body_tbl(p_assignment_action_id).o_itax_org_cnt             )||c_eol||
        pay_jp_report_pkg.add_tag_v('d4', g_body_tbl(p_assignment_action_id).o_itax_org_address         )||c_eol||
        pay_jp_report_pkg.add_tag_v('d5', g_body_tbl(p_assignment_action_id).o_itax_org_name            )||c_eol||
        pay_jp_report_pkg.add_tag_v('d6', g_body_tbl(p_assignment_action_id).o_itax_org_phone           )||c_eol||
        pay_jp_report_pkg.add_tag_v('d7', g_body_tbl(p_assignment_action_id).o_itax_org_serial2         )||c_eol||
        pay_jp_report_pkg.add_tag  ('d8', g_body_tbl(p_assignment_action_id).o_itax_hq_address          )||c_eol||
        pay_jp_report_pkg.add_tag  ('d9', g_body_tbl(p_assignment_action_id).o_itax_hq_name             )||c_eol||
        pay_jp_report_pkg.add_tag  ('d10',g_body_tbl(p_assignment_action_id).o_amend_flag               )||c_eol||
        pay_jp_report_pkg.add_tag  ('d11',g_body_tbl(p_assignment_action_id).o_target_yy                )||c_eol||
        pay_jp_report_pkg.add_tag_v('d12',g_body_tbl(p_assignment_action_id).o_address                  )||c_eol||
        pay_jp_report_pkg.add_tag  ('d13',g_body_tbl(p_assignment_action_id).o_address_jp               )||c_eol||
        pay_jp_report_pkg.add_tag_v('d14',g_body_tbl(p_assignment_action_id).o_full_name                )||c_eol||
        pay_jp_report_pkg.add_tag  ('d15',g_body_tbl(p_assignment_action_id).o_position                 )||c_eol||
        pay_jp_report_pkg.add_tag  ('d16',g_body_tbl(p_assignment_action_id).o_assortment               )||c_eol||
        pay_jp_report_pkg.add_tag_m('d17',g_body_tbl(p_assignment_action_id).o_taxable_income           )||c_eol||
        pay_jp_report_pkg.add_tag_m('d18',g_body_tbl(p_assignment_action_id).o_unpaid_income            )||c_eol||
        pay_jp_report_pkg.add_tag_m('d19',g_body_tbl(p_assignment_action_id).o_net_taxable_income       )||c_eol||
        pay_jp_report_pkg.add_tag_m('d20',g_body_tbl(p_assignment_action_id).o_total_income_exempt      )||c_eol||
        pay_jp_report_pkg.add_tag_m('d21',g_body_tbl(p_assignment_action_id).o_withholding_itax         )||c_eol||
        pay_jp_report_pkg.add_tag_m('d22',g_body_tbl(p_assignment_action_id).o_uncollected_itax         )||c_eol||
        pay_jp_report_pkg.add_tag  ('d23',g_body_tbl(p_assignment_action_id).o_dep_spouse               )||c_eol||
        pay_jp_report_pkg.add_tag  ('d24',g_body_tbl(p_assignment_action_id).o_aged_spouse              )||c_eol||
        pay_jp_report_pkg.add_tag_m('d25',g_body_tbl(p_assignment_action_id).o_spouse_sp_exempt         )||c_eol||
        pay_jp_report_pkg.add_tag  ('d26',g_body_tbl(p_assignment_action_id).o_num_specifieds_kou       )||c_eol||
        pay_jp_report_pkg.add_tag  ('d27',g_body_tbl(p_assignment_action_id).o_num_specifieds_otsu      )||c_eol||
        pay_jp_report_pkg.add_tag  ('d28',g_body_tbl(p_assignment_action_id).o_num_ageds_kou            )||c_eol||
        pay_jp_report_pkg.add_tag  ('d29',g_body_tbl(p_assignment_action_id).o_num_aged_parents_lt      )||c_eol||
        pay_jp_report_pkg.add_tag  ('d30',g_body_tbl(p_assignment_action_id).o_num_ageds_otsu           )||c_eol||
        pay_jp_report_pkg.add_tag  ('d31',g_body_tbl(p_assignment_action_id).o_num_deps_kou             )||c_eol||
        pay_jp_report_pkg.add_tag  ('d32',g_body_tbl(p_assignment_action_id).o_num_deps_otsu            )||c_eol||
        pay_jp_report_pkg.add_tag  ('d33',g_body_tbl(p_assignment_action_id).o_num_svr_disableds        )||c_eol||
        pay_jp_report_pkg.add_tag  ('d34',g_body_tbl(p_assignment_action_id).o_num_svr_disableds_lt     )||c_eol||
        pay_jp_report_pkg.add_tag  ('d35',g_body_tbl(p_assignment_action_id).o_num_disableds            )||c_eol||
        pay_jp_report_pkg.add_tag_m('d36',g_body_tbl(p_assignment_action_id).o_si_prem                  )||c_eol||
        pay_jp_report_pkg.add_tag_m('d37',g_body_tbl(p_assignment_action_id).o_mutual_aid_prem          )||c_eol||
        pay_jp_report_pkg.add_tag_m('d38',g_body_tbl(p_assignment_action_id).o_li_prem_exempt           )||c_eol||
        pay_jp_report_pkg.add_tag_m('d39',g_body_tbl(p_assignment_action_id).o_ai_prem_exempt           )||c_eol||
        pay_jp_report_pkg.add_tag_m('d40',g_body_tbl(p_assignment_action_id).o_housing_tax_reduction    )||c_eol||
        pay_jp_report_pkg.add_tag_m('d41',g_body_tbl(p_assignment_action_id).o_pp_prem                  )||c_eol||
        pay_jp_report_pkg.add_tag_m('d42',g_body_tbl(p_assignment_action_id).o_spouse_net_taxable_income)||c_eol||
        pay_jp_report_pkg.add_tag_m('d43',g_body_tbl(p_assignment_action_id).o_long_ai_prem             )||c_eol||
        pay_jp_report_pkg.add_tag  ('d44',g_body_tbl(p_assignment_action_id).o_birth_date_era           )||c_eol||
        pay_jp_report_pkg.add_tag  ('d45',g_body_tbl(p_assignment_action_id).o_birth_date_yy            )||c_eol||
        pay_jp_report_pkg.add_tag  ('d46',g_body_tbl(p_assignment_action_id).o_birth_date_mm            )||c_eol||
        pay_jp_report_pkg.add_tag  ('d47',g_body_tbl(p_assignment_action_id).o_birth_date_dd            )||c_eol||
        pay_jp_report_pkg.add_tag  ('d48',g_body_tbl(p_assignment_action_id).o_husband_exists           )||c_eol||
        pay_jp_report_pkg.add_tag  ('d49',g_body_tbl(p_assignment_action_id).o_minor                    )||c_eol||
        pay_jp_report_pkg.add_tag  ('d50',g_body_tbl(p_assignment_action_id).o_otsu                     )||c_eol||
        pay_jp_report_pkg.add_tag  ('d51',g_body_tbl(p_assignment_action_id).o_svr_disabled             )||c_eol||
        pay_jp_report_pkg.add_tag  ('d52',g_body_tbl(p_assignment_action_id).o_disabled                 )||c_eol||
        pay_jp_report_pkg.add_tag  ('d53',g_body_tbl(p_assignment_action_id).o_aged                     )||c_eol||
        pay_jp_report_pkg.add_tag  ('d54',g_body_tbl(p_assignment_action_id).o_widow                    )||c_eol||
        pay_jp_report_pkg.add_tag  ('d55',g_body_tbl(p_assignment_action_id).o_widower                  )||c_eol||
        pay_jp_report_pkg.add_tag  ('d56',g_body_tbl(p_assignment_action_id).o_working_student          )||c_eol||
        pay_jp_report_pkg.add_tag  ('d57',g_body_tbl(p_assignment_action_id).o_deceased_termination     )||c_eol||
        pay_jp_report_pkg.add_tag  ('d58',g_body_tbl(p_assignment_action_id).o_disastered               )||c_eol||
        pay_jp_report_pkg.add_tag  ('d59',g_body_tbl(p_assignment_action_id).o_foreigner                )||c_eol||
        pay_jp_report_pkg.add_tag  ('d60',g_body_tbl(p_assignment_action_id).o_employed                 )||c_eol||
        pay_jp_report_pkg.add_tag  ('d61',g_body_tbl(p_assignment_action_id).o_employed_yy              )||c_eol||
        pay_jp_report_pkg.add_tag  ('d62',g_body_tbl(p_assignment_action_id).o_employed_mm              )||c_eol||
        pay_jp_report_pkg.add_tag  ('d63',g_body_tbl(p_assignment_action_id).o_employed_dd              )||c_eol||
        pay_jp_report_pkg.add_tag_v('d64',g_body_tbl(p_assignment_action_id).o_pjob_itax_org_address    )||c_eol||
        pay_jp_report_pkg.add_tag  ('d65',g_body_tbl(p_assignment_action_id).o_pjob_itax_org_address_jp )||c_eol||
        pay_jp_report_pkg.add_tag_v('d66',g_body_tbl(p_assignment_action_id).o_pjob_itax_org_full_name  )||c_eol||
        pay_jp_report_pkg.add_tag_m('d67',g_body_tbl(p_assignment_action_id).o_pjob_taxable_income      )||c_eol||
        pay_jp_report_pkg.add_tag_m('d68',g_body_tbl(p_assignment_action_id).o_pjob_itax                )||c_eol||
        pay_jp_report_pkg.add_tag_m('d69',g_body_tbl(p_assignment_action_id).o_pjob_si_prem             )||c_eol||
        pay_jp_report_pkg.add_tag_m('d70',g_body_tbl(p_assignment_action_id).o_disaster_tax_reduction   )||c_eol||
        pay_jp_report_pkg.add_tag  ('d71',g_body_tbl(p_assignment_action_id).o_pjob_termination_date_yy )||c_eol||
        pay_jp_report_pkg.add_tag  ('d72',g_body_tbl(p_assignment_action_id).o_pjob_termination_date_mm )||c_eol||
        pay_jp_report_pkg.add_tag  ('d73',g_body_tbl(p_assignment_action_id).o_pjob_termination_date_dd )||c_eol||
        pay_jp_report_pkg.add_tag  ('d74',g_body_tbl(p_assignment_action_id).o_hld_residence_date_1_yy  )||c_eol||
        pay_jp_report_pkg.add_tag  ('d75',g_body_tbl(p_assignment_action_id).o_hld_residence_date_1_mm  )||c_eol||
        pay_jp_report_pkg.add_tag  ('d76',g_body_tbl(p_assignment_action_id).o_hld_residence_date_1_dd  )||c_eol||
        pay_jp_report_pkg.add_tag_v('d77',g_body_tbl(p_assignment_action_id).o_description              )||c_eol||
        pay_jp_report_pkg.add_tag  ('d78',g_body_tbl(p_assignment_action_id).o_gen_collecting           )||c_eol||
        pay_jp_report_pkg.add_tag  ('d79',g_body_tbl(p_assignment_action_id).o_blue_proprietor          )||c_eol||
        pay_jp_report_pkg.add_tag  ('d80',g_body_tbl(p_assignment_action_id).o_immune                   )||c_eol||
        pay_jp_report_pkg.add_tag_v('d81',g_body_tbl(p_assignment_action_id).o_full_name_kana           )||c_eol||
        pay_jp_report_pkg.add_tag_v('d82',g_body_tbl(p_assignment_action_id).o_employee_number          )||c_eol||
        pay_jp_report_pkg.add_tag  ('d83',g_body_tbl(p_assignment_action_id).o_district_code            )||c_eol||
        pay_jp_report_pkg.add_tag_v('d84',g_body_tbl(p_assignment_action_id).o_swot_number              )||c_eol||
        '</g_emp>';
    --
    else
    --
      l_xml_assact :=
        '<g_emp>'||c_eol||
        pay_jp_report_pkg.add_tag  ('d1', g_body_tbl(p_assignment_action_id).o_form_number              )||c_eol||
        pay_jp_report_pkg.add_tag_v('d2', g_body_tbl(p_assignment_action_id).o_itax_org_serial1         )||c_eol||
        pay_jp_report_pkg.add_tag  ('d3', g_body_tbl(p_assignment_action_id).o_itax_org_cnt             )||c_eol||
        pay_jp_report_pkg.add_tag_v('d4', g_body_tbl(p_assignment_action_id).o_itax_org_address         )||c_eol||
        pay_jp_report_pkg.add_tag_v('d5', g_body_tbl(p_assignment_action_id).o_itax_org_name            )||c_eol||
        pay_jp_report_pkg.add_tag_v('d6', g_body_tbl(p_assignment_action_id).o_itax_org_phone           )||c_eol||
        pay_jp_report_pkg.add_tag_v('d7', g_body_tbl(p_assignment_action_id).o_itax_org_serial2         )||c_eol||
        pay_jp_report_pkg.add_tag  ('d8', g_body_tbl(p_assignment_action_id).o_itax_hq_address          )||c_eol||
        pay_jp_report_pkg.add_tag  ('d9', g_body_tbl(p_assignment_action_id).o_itax_hq_name             )||c_eol||
        pay_jp_report_pkg.add_tag  ('d10',g_body_tbl(p_assignment_action_id).o_amend_flag               )||c_eol||
        pay_jp_report_pkg.add_tag  ('d11',g_body_tbl(p_assignment_action_id).o_target_yy                )||c_eol||
        pay_jp_report_pkg.add_tag_v('d12',g_body_tbl(p_assignment_action_id).o_address                  )||c_eol||
        pay_jp_report_pkg.add_tag  ('d13',g_body_tbl(p_assignment_action_id).o_address_jp               )||c_eol||
        pay_jp_report_pkg.add_tag_v('d14',g_body_tbl(p_assignment_action_id).o_full_name                )||c_eol||
        pay_jp_report_pkg.add_tag  ('d15',g_body_tbl(p_assignment_action_id).o_position                 )||c_eol||
        pay_jp_report_pkg.add_tag  ('d16',g_body_tbl(p_assignment_action_id).o_assortment               )||c_eol||
        pay_jp_report_pkg.add_tag_m('d17',g_body_tbl(p_assignment_action_id).o_taxable_income           )||c_eol||
        pay_jp_report_pkg.add_tag_m('d18',g_body_tbl(p_assignment_action_id).o_unpaid_income            )||c_eol||
        pay_jp_report_pkg.add_tag_m('d19',g_body_tbl(p_assignment_action_id).o_net_taxable_income       )||c_eol||
        pay_jp_report_pkg.add_tag_m('d20',g_body_tbl(p_assignment_action_id).o_total_income_exempt      )||c_eol||
        pay_jp_report_pkg.add_tag_m('d21',g_body_tbl(p_assignment_action_id).o_withholding_itax         )||c_eol||
        pay_jp_report_pkg.add_tag_m('d22',g_body_tbl(p_assignment_action_id).o_uncollected_itax         )||c_eol||
        pay_jp_report_pkg.add_tag  ('d23',g_body_tbl(p_assignment_action_id).o_dep_spouse               )||c_eol||
        pay_jp_report_pkg.add_tag  ('d24',g_body_tbl(p_assignment_action_id).o_aged_spouse              )||c_eol||
        pay_jp_report_pkg.add_tag_m('d25',g_body_tbl(p_assignment_action_id).o_spouse_sp_exempt         )||c_eol||
        pay_jp_report_pkg.add_tag  ('d26',g_body_tbl(p_assignment_action_id).o_num_specifieds_kou       )||c_eol||
        pay_jp_report_pkg.add_tag  ('d27',g_body_tbl(p_assignment_action_id).o_num_specifieds_otsu      )||c_eol||
        pay_jp_report_pkg.add_tag  ('d28',g_body_tbl(p_assignment_action_id).o_num_ageds_kou            )||c_eol||
        pay_jp_report_pkg.add_tag  ('d29',g_body_tbl(p_assignment_action_id).o_num_aged_parents_lt      )||c_eol||
        pay_jp_report_pkg.add_tag  ('d30',g_body_tbl(p_assignment_action_id).o_num_ageds_otsu           )||c_eol||
        pay_jp_report_pkg.add_tag  ('d31',g_body_tbl(p_assignment_action_id).o_num_deps_kou             )||c_eol||
        pay_jp_report_pkg.add_tag  ('d32',g_body_tbl(p_assignment_action_id).o_num_deps_otsu            )||c_eol||
        pay_jp_report_pkg.add_tag  ('d33',g_body_tbl(p_assignment_action_id).o_num_svr_disableds        )||c_eol||
        pay_jp_report_pkg.add_tag  ('d34',g_body_tbl(p_assignment_action_id).o_num_svr_disableds_lt     )||c_eol||
        pay_jp_report_pkg.add_tag  ('d35',g_body_tbl(p_assignment_action_id).o_num_disableds            )||c_eol||
        pay_jp_report_pkg.add_tag_m('d36',g_body_tbl(p_assignment_action_id).o_si_prem                  )||c_eol||
        pay_jp_report_pkg.add_tag_m('d37',g_body_tbl(p_assignment_action_id).o_mutual_aid_prem          )||c_eol||
        pay_jp_report_pkg.add_tag_m('d38',g_body_tbl(p_assignment_action_id).o_li_prem_exempt           )||c_eol||
        pay_jp_report_pkg.add_tag_m('d39',g_body_tbl(p_assignment_action_id).o_ai_prem_exempt           )||c_eol||
        pay_jp_report_pkg.add_tag_m('d40',g_body_tbl(p_assignment_action_id).o_housing_tax_reduction    )||c_eol||
        pay_jp_report_pkg.add_tag_m('d41',g_body_tbl(p_assignment_action_id).o_pp_prem                  )||c_eol||
        pay_jp_report_pkg.add_tag_m('d42',g_body_tbl(p_assignment_action_id).o_spouse_net_taxable_income)||c_eol||
        pay_jp_report_pkg.add_tag_m('d43',g_body_tbl(p_assignment_action_id).o_long_ai_prem             )||c_eol||
        pay_jp_report_pkg.add_tag  ('d44',g_body_tbl(p_assignment_action_id).o_birth_date_era           )||c_eol||
        pay_jp_report_pkg.add_tag  ('d45',g_body_tbl(p_assignment_action_id).o_birth_date_yy            )||c_eol||
        pay_jp_report_pkg.add_tag  ('d46',g_body_tbl(p_assignment_action_id).o_birth_date_mm            )||c_eol||
        pay_jp_report_pkg.add_tag  ('d47',g_body_tbl(p_assignment_action_id).o_birth_date_dd            )||c_eol||
        pay_jp_report_pkg.add_tag  ('d48',g_body_tbl(p_assignment_action_id).o_husband_exists           )||c_eol||
        pay_jp_report_pkg.add_tag  ('d49',g_body_tbl(p_assignment_action_id).o_minor                    )||c_eol||
        pay_jp_report_pkg.add_tag  ('d50',g_body_tbl(p_assignment_action_id).o_otsu                     )||c_eol||
        pay_jp_report_pkg.add_tag  ('d51',g_body_tbl(p_assignment_action_id).o_svr_disabled             )||c_eol||
        pay_jp_report_pkg.add_tag  ('d52',g_body_tbl(p_assignment_action_id).o_disabled                 )||c_eol||
        pay_jp_report_pkg.add_tag  ('d53',g_body_tbl(p_assignment_action_id).o_aged                     )||c_eol||
        pay_jp_report_pkg.add_tag  ('d54',g_body_tbl(p_assignment_action_id).o_widow                    )||c_eol||
        pay_jp_report_pkg.add_tag  ('d55',g_body_tbl(p_assignment_action_id).o_widower                  )||c_eol||
        pay_jp_report_pkg.add_tag  ('d56',g_body_tbl(p_assignment_action_id).o_working_student          )||c_eol||
        pay_jp_report_pkg.add_tag  ('d57',g_body_tbl(p_assignment_action_id).o_deceased_termination     )||c_eol||
        pay_jp_report_pkg.add_tag  ('d58',g_body_tbl(p_assignment_action_id).o_disastered               )||c_eol||
        pay_jp_report_pkg.add_tag  ('d59',g_body_tbl(p_assignment_action_id).o_foreigner                )||c_eol||
        pay_jp_report_pkg.add_tag  ('d60',g_body_tbl(p_assignment_action_id).o_employed                 )||c_eol||
        pay_jp_report_pkg.add_tag  ('d61',g_body_tbl(p_assignment_action_id).o_employed_yy              )||c_eol||
        pay_jp_report_pkg.add_tag  ('d62',g_body_tbl(p_assignment_action_id).o_employed_mm              )||c_eol||
        pay_jp_report_pkg.add_tag  ('d63',g_body_tbl(p_assignment_action_id).o_employed_dd              )||c_eol||
        pay_jp_report_pkg.add_tag_v('d64',g_body_tbl(p_assignment_action_id).o_pjob_itax_org_address    )||c_eol||
        pay_jp_report_pkg.add_tag  ('d65',g_body_tbl(p_assignment_action_id).o_pjob_itax_org_address_jp )||c_eol||
        pay_jp_report_pkg.add_tag_v('d66',g_body_tbl(p_assignment_action_id).o_pjob_itax_org_full_name  )||c_eol||
        pay_jp_report_pkg.add_tag_m('d67',g_body_tbl(p_assignment_action_id).o_pjob_taxable_income      )||c_eol||
        pay_jp_report_pkg.add_tag_m('d68',g_body_tbl(p_assignment_action_id).o_pjob_itax                )||c_eol||
        pay_jp_report_pkg.add_tag_m('d69',g_body_tbl(p_assignment_action_id).o_pjob_si_prem             )||c_eol||
        pay_jp_report_pkg.add_tag_m('d70',g_body_tbl(p_assignment_action_id).o_disaster_tax_reduction   )||c_eol||
        pay_jp_report_pkg.add_tag  ('d71',g_body_tbl(p_assignment_action_id).o_pjob_termination_date_yy )||c_eol||
        pay_jp_report_pkg.add_tag  ('d72',g_body_tbl(p_assignment_action_id).o_pjob_termination_date_mm )||c_eol||
        pay_jp_report_pkg.add_tag  ('d73',g_body_tbl(p_assignment_action_id).o_pjob_termination_date_dd )||c_eol||
        pay_jp_report_pkg.add_tag  ('d74',g_body_tbl(p_assignment_action_id).o_hld_residence_date_1_yy  )||c_eol||
        pay_jp_report_pkg.add_tag  ('d75',g_body_tbl(p_assignment_action_id).o_hld_residence_date_1_mm  )||c_eol||
        pay_jp_report_pkg.add_tag  ('d76',g_body_tbl(p_assignment_action_id).o_hld_residence_date_1_dd  )||c_eol||
        pay_jp_report_pkg.add_tag  ('d77',g_body_tbl(p_assignment_action_id).o_hld_loan_count           )||c_eol||
        pay_jp_report_pkg.add_tag_m('d78',g_body_tbl(p_assignment_action_id).o_hld_payable_loan         )||c_eol||
        pay_jp_report_pkg.add_tag  ('d79',g_body_tbl(p_assignment_action_id).o_hld_loan_type_1          )||c_eol||
        pay_jp_report_pkg.add_tag_m('d80',g_body_tbl(p_assignment_action_id).o_hld_loan_balance_1       )||c_eol||
        pay_jp_report_pkg.add_tag  ('d81',g_body_tbl(p_assignment_action_id).o_hld_residence_date_2_yy  )||c_eol||
        pay_jp_report_pkg.add_tag  ('d82',g_body_tbl(p_assignment_action_id).o_hld_residence_date_2_mm  )||c_eol||
        pay_jp_report_pkg.add_tag  ('d83',g_body_tbl(p_assignment_action_id).o_hld_residence_date_2_dd  )||c_eol||
        pay_jp_report_pkg.add_tag  ('d84',g_body_tbl(p_assignment_action_id).o_hld_loan_type_2          )||c_eol||
        pay_jp_report_pkg.add_tag_m('d85',g_body_tbl(p_assignment_action_id).o_hld_loan_balance_2       )||c_eol||
        pay_jp_report_pkg.add_tag_v('d86',g_body_tbl(p_assignment_action_id).o_description              )||c_eol||
        pay_jp_report_pkg.add_tag  ('d87',g_body_tbl(p_assignment_action_id).o_gen_collecting           )||c_eol||
        pay_jp_report_pkg.add_tag  ('d88',g_body_tbl(p_assignment_action_id).o_blue_proprietor          )||c_eol||
        pay_jp_report_pkg.add_tag  ('d89',g_body_tbl(p_assignment_action_id).o_immune                   )||c_eol||
        pay_jp_report_pkg.add_tag_v('d90',g_body_tbl(p_assignment_action_id).o_full_name_kana           )||c_eol||
        pay_jp_report_pkg.add_tag_v('d91',g_body_tbl(p_assignment_action_id).o_employee_number          )||c_eol||
        pay_jp_report_pkg.add_tag  ('d92',g_body_tbl(p_assignment_action_id).o_district_code            )||c_eol||
        pay_jp_report_pkg.add_tag_v('d93',g_body_tbl(p_assignment_action_id).o_swot_number              )||c_eol||
        '</g_emp>';
    --
    end if;
  --
    pay_core_files.write_to_magtape_lob(l_xml_assact);
  --
  else
  --
    if g_debug
    and g_detail_debug = 'Y' then
      hr_utility.trace('mismatch assignment_action_id : g_body_tbl : '||to_char(l_mag_assignment_action_id)||' <> p_assignment_action_id : '||to_char(p_assignment_action_id));
    end if;
  --
  end if;
--
  if g_debug
  and g_detail_debug = 'Y' then
    hr_utility.set_location(l_proc,1000);
  end if;
--
exception
when no_data_found then
--
  if g_debug then
  --
    hr_utility.trace('no chache g_body_tbl : p_assignment_action_id : '||to_char(p_assignment_action_id));
    hr_utility.trace('g_body_tbl count : '||to_char(g_body_tbl.count));
  --
    if g_detail_debug = 'Y' then
    --
      for i in g_body_tbl.first..g_body_tbl.last loop
      --
        hr_utility.trace('g_body_tbl(i).mag_assignment_action_id : '||to_char(g_body_tbl(i).mag_assignment_action_id));
        hr_utility.trace('g_body_tbl(i).assignment_action_id     : '||to_char(g_body_tbl(i).assignment_action_id));
      --
      end loop;
    --
    end if;
  --
  end if;
--
when others then
  raise;
--
end xml_assact;
--
-- -------------------------------------------------------------------------
-- file_assact
-- -------------------------------------------------------------------------
procedure file_assact(
  p_assignment_action_id in number)
is
--
  l_proc varchar2(80) := c_package||'file_assact';
--
  l_mag_assignment_action_id number;
--
  l_file_ind number;
  l_file_name varchar2(80);
  l_file_out utl_file.file_type;
  l_file_assact varchar2(32767);
--
begin
--
  if g_debug
  and g_detail_debug = 'Y' then
    hr_utility.set_location(l_proc,0);
  end if;
--
  l_mag_assignment_action_id := g_body_tbl(p_assignment_action_id).mag_assignment_action_id;
--
  if l_mag_assignment_action_id is not null
  and l_mag_assignment_action_id = p_assignment_action_id then
  --
    --
    -- warning log
    --
    if g_warning_exist is not null
    and g_warning_exist = 'Y'
    and g_body_tbl(p_assignment_action_id).long_description is not null then
    --
      if g_warning_header is null
      or g_warning_header <> 'Y' then
      --
        g_warning_header := 'Y';
      --
        fnd_file.put_line(fnd_file.log,fnd_message.get_string('PAY','PAY_JP_WIC_DESC_TRUNCATED'));
      --
      end if;
    --
      fnd_file.put_line(fnd_file.log,g_body_tbl(p_assignment_action_id).o_employee_number||' : '||g_body_tbl(p_assignment_action_id).o_full_name);
      fnd_file.put_line(fnd_file.log,'----------------------------------------------------------------------------------------------------');
      pay_jp_report_pkg.show_warning(fnd_file.log,g_body_tbl(p_assignment_action_id).long_description);
      fnd_file.put_line(fnd_file.log,' ');
    --
    end if;
  --
    l_file_ind := g_body_tbl(p_assignment_action_id).file_ind;
  --
    l_file_name   := g_body_tbl(p_assignment_action_id).output_file_name;
    l_file_out    := g_file_tbl(l_file_ind).file_out;
  --
    if g_effective_yyyy < 2009 then
    --
      l_file_assact :=
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_form_number              ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_itax_org_serial1         ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_itax_org_cnt             ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_itax_org_address         ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_itax_org_name            ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_itax_org_phone           ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_itax_org_serial2         ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_itax_hq_address          ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_itax_hq_name             ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_amend_flag               ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_target_yy                ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_address                  ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_address_jp               ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_full_name                ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_position                 ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_assortment               ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_taxable_income           ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_unpaid_income            ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_net_taxable_income       ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_total_income_exempt      ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_withholding_itax         ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_uncollected_itax         ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_dep_spouse               ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_aged_spouse              ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_spouse_sp_exempt         ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_num_specifieds_kou       ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_num_specifieds_otsu      ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_num_ageds_kou            ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_num_aged_parents_lt      ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_num_ageds_otsu           ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_num_deps_kou             ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_num_deps_otsu            ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_num_svr_disableds        ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_num_svr_disableds_lt     ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_num_disableds            ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_si_prem                  ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_mutual_aid_prem          ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_li_prem_exempt           ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_ai_prem_exempt           ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_housing_tax_reduction    ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_pp_prem                  ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_spouse_net_taxable_income||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_long_ai_prem             ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_birth_date_era           ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_birth_date_yy            ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_birth_date_mm            ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_birth_date_dd            ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_husband_exists           ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_minor                    ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_otsu                     ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_svr_disabled             ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_disabled                 ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_aged                     ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_widow                    ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_widower                  ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_working_student          ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_deceased_termination     ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_disastered               ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_foreigner                ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_employed                 ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_employed_yy              ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_employed_mm              ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_employed_dd              ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_pjob_itax_org_address    ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_pjob_itax_org_address_jp ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_pjob_itax_org_full_name  ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_pjob_taxable_income      ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_pjob_itax                ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_pjob_si_prem             ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_disaster_tax_reduction   ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_pjob_termination_date_yy ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_pjob_termination_date_mm ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_pjob_termination_date_dd ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_hld_residence_date_1_yy  ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_hld_residence_date_1_mm  ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_hld_residence_date_1_dd  ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_description              ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_gen_collecting           ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_blue_proprietor          ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_immune                   ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_full_name_kana           ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_employee_number          ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_district_code            ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_swot_number              );
    --
    else
    --
      l_file_assact :=
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_form_number              ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_itax_org_serial1         ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_itax_org_cnt             ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_itax_org_address         ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_itax_org_name            ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_itax_org_phone           ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_itax_org_serial2         ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_itax_hq_address          ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_itax_hq_name             ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_amend_flag               ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_target_yy                ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_address                  ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_address_jp               ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_full_name                ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_position                 ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_assortment               ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_taxable_income           ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_unpaid_income            ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_net_taxable_income       ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_total_income_exempt      ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_withholding_itax         ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_uncollected_itax         ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_dep_spouse               ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_aged_spouse              ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_spouse_sp_exempt         ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_num_specifieds_kou       ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_num_specifieds_otsu      ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_num_ageds_kou            ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_num_aged_parents_lt      ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_num_ageds_otsu           ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_num_deps_kou             ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_num_deps_otsu            ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_num_svr_disableds        ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_num_svr_disableds_lt     ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_num_disableds            ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_si_prem                  ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_mutual_aid_prem          ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_li_prem_exempt           ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_ai_prem_exempt           ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_housing_tax_reduction    ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_pp_prem                  ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_spouse_net_taxable_income||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_long_ai_prem             ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_birth_date_era           ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_birth_date_yy            ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_birth_date_mm            ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_birth_date_dd            ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_husband_exists           ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_minor                    ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_otsu                     ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_svr_disabled             ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_disabled                 ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_aged                     ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_widow                    ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_widower                  ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_working_student          ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_deceased_termination     ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_disastered               ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_foreigner                ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_employed                 ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_employed_yy              ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_employed_mm              ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_employed_dd              ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_pjob_itax_org_address    ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_pjob_itax_org_address_jp ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_pjob_itax_org_full_name  ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_pjob_taxable_income      ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_pjob_itax                ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_pjob_si_prem             ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_disaster_tax_reduction   ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_pjob_termination_date_yy ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_pjob_termination_date_mm ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_pjob_termination_date_dd ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_hld_residence_date_1_yy  ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_hld_residence_date_1_mm  ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_hld_residence_date_1_dd  ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_hld_loan_count           ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_hld_payable_loan         ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_hld_loan_type_1          ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_hld_loan_balance_1       ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_hld_residence_date_2_yy  ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_hld_residence_date_2_mm  ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_hld_residence_date_2_dd  ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_hld_loan_type_2          ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_hld_loan_balance_2       ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_description              ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_gen_collecting           ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_blue_proprietor          ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_immune                   ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_full_name_kana           ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_employee_number          ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_district_code            ||c_delimiter)||
        pay_jp_report_pkg.cnv_txt(g_body_tbl(p_assignment_action_id).o_swot_number              );
    --
    end if;
  --
    pay_jp_report_pkg.write_file(l_file_name,l_file_out,l_file_assact);
  --
  else
  --
    if g_debug
    and g_detail_debug = 'Y' then
      hr_utility.trace('mismatch assignment_action_id : g_body_tbl : '||to_char(l_mag_assignment_action_id)||' <> p_assignment_action_id : '||to_char(p_assignment_action_id));
    end if;
  --
  end if;
--
  if g_debug
  and g_detail_debug = 'Y' then
    hr_utility.set_location(l_proc,1000);
  end if;
--
exception
when no_data_found then
--
  if g_debug then
  --
    hr_utility.trace('no chache g_body_tbl : p_assignment_action_id : '||to_char(p_assignment_action_id));
    hr_utility.trace('g_body_tbl count : '||to_char(g_body_tbl.count));
  --
    hr_utility.trace('no chache g_file_tbl : l_file_ind : '||to_char(l_file_ind));
    hr_utility.trace('g_file_tbl count : '||to_char(g_file_tbl.count));
  --
  end if;
--
when others then
  raise;
--
end file_assact;
--
-- -------------------------------------------------------------------------
-- gen_file
-- -------------------------------------------------------------------------
procedure gen_file
is
--
  l_proc varchar2(80) := c_package||'gen_file';
--
  l_ass_cnt number := 0;
--
begin
--
  if g_debug
  and g_detail_debug = 'Y' then
    hr_utility.set_location(l_proc,0);
    hr_utility.trace('g_assact_tbl.count : '||to_char(g_assact_tbl.count));
  end if;
--
  if g_assact_tbl.count > 0 then
  --
    for i in 1..g_assact_tbl.count loop
    --
      if g_assact_tbl(i) is not null then
      --
        file_assact(g_assact_tbl(i));
      --
        l_ass_cnt := l_ass_cnt + 1;
      --
      else
        if g_debug
        and g_detail_debug = 'Y' then
          hr_utility.trace('g_assact_tbl is null : '||to_char(i));
        end if;
      end if;
    --
    end loop;
  --
  end if;
--
  if g_debug
  and g_detail_debug = 'Y' then
    hr_utility.set_location(l_proc,1000);
  end if;
--
end gen_file;
--
-- -------------------------------------------------------------------------
-- del_file
-- -------------------------------------------------------------------------
procedure del_file(
  p_request_id in number,
  p_file_name in varchar2 default null)
is
--
  l_proc varchar2(80) := c_package||'del_file';
--
  l_payroll_action_id number;
--
  l_district_code per_addresses.town_or_city%type;
  l_itax_organization_id number;
  l_itax_org_cnt number;
--
  l_select_clause varchar2(32767);
  l_from_clause varchar2(32767);
  l_where_clause varchar2(32767);
  l_order_by_clause varchar2(255);
--
  l_file_dir fnd_concurrent_processes.plsql_dir%type;
  l_file_name varchar2(80);
  l_file_cnt number;
--
  l_data_tbl t_data_tbl;
  l_file_tbl t_file_tbl;
--
  cursor csr_action
  is
  select ppa.payroll_action_id
  from   pay_payroll_actions ppa
  where  ppa.request_id = p_request_id
  and    ppa.action_type = 'X'
  and    ppa.report_type = 'JP_SPR_EFILE'
  and    ppa.report_qualifier = 'JP'
  and    ppa.report_category = 'XML';
--
  cursor csr_file_dir
  is
  select fcp.plsql_dir
  from   fnd_concurrent_requests fcr,
         fnd_concurrent_processes fcp
  where  fcr.request_id = p_request_id
  and    fcp.concurrent_process_id = fcr.controlling_manager;
--
begin
--
  if g_debug
  and g_detail_debug = 'Y' then
    hr_utility.set_location(l_proc,0);
  end if;
--
  l_file_cnt := 0;
  l_itax_org_cnt := 0;
--
  open csr_file_dir;
  fetch csr_file_dir into l_file_dir;
  close csr_file_dir;
--
  if g_debug
  and g_detail_debug = 'Y' then
    hr_utility.set_location(l_proc,10);
    hr_utility.trace('l_file_dir : '||l_file_dir);
  end if;
--
  if l_file_dir is not null then
  --
    if p_file_name is not null then
    --
      if g_debug
      and g_detail_debug = 'Y' then
        hr_utility.set_location(l_proc,20);
        hr_utility.trace('p_file_name : '||p_file_name);
      end if;
    --
      if g_del_file <> 'N' then
        pay_jp_report_pkg.delete_file(l_file_dir,p_file_name);
      end if;
    --
      if g_debug
      and g_detail_debug = 'Y' then
         hr_utility.trace(p_file_name||' was deleted');
      end if;
    --
    else
    --
      if g_debug
      and g_detail_debug = 'Y' then
        hr_utility.set_location(l_proc,30);
        hr_utility.trace('p_request_id : '||to_char(p_request_id));
      end if;
    --
      open csr_action;
      fetch csr_action into l_payroll_action_id;
      close csr_action;
    --
      if g_debug
      and g_detail_debug = 'Y' then
        hr_utility.set_location(l_proc,40);
        hr_utility.trace('l_payroll_action_id : '||to_char(l_payroll_action_id));
      end if;
    --
      if l_payroll_action_id is not null then
      --
        -- need set to global variables.
        init_pact(l_payroll_action_id);
      --
        if g_debug
        and g_detail_debug = 'Y' then
          hr_utility.set_location(l_proc,50);
          hr_utility.trace('g_file_split : '||g_file_split);
        end if;
      --
        -- output_file_name to unit file in case etax
        if g_file_split is not null
        and g_file_split = 'N' then
        --
          l_file_name :=
            pay_jp_spr_efile_pkg.g_file_prefix||
            c_file_spliter||
            to_char(p_request_id)||c_file_extension;
        --
          if g_debug
          and g_detail_debug = 'Y' then
            hr_utility.set_location(l_proc,60);
            hr_utility.trace('l_file_name : '||l_file_name);
          end if;
        --
          if g_del_file <> 'N' then
            pay_jp_report_pkg.delete_file(l_file_dir,l_file_name);
          end if;
        --
          if g_debug
          and g_detail_debug = 'Y' then
             hr_utility.trace(l_file_name||' was deleted');
          end if;
        --
        else
        --
          if g_debug
          and g_detail_debug = 'Y' then
            hr_utility.set_location(l_proc,70);
            hr_utility.trace('g_arch_pact_exist : '||g_arch_pact_exist);
          end if;
        --
          if g_arch_pact_exist is not null
          and g_arch_pact_exist = 'Y' then
          --
            if g_debug
            and g_detail_debug = 'Y' then
              hr_utility.set_location(l_proc,80);
            end if;
          --
            pay_jp_report_pkg.append_select_clause(c_data_arch_select_clause,l_select_clause);
            pay_jp_report_pkg.append_from_clause(c_data_arch_from_clause,l_from_clause);
            pay_jp_report_pkg.append_where_clause(c_data_arch_where_clause,l_where_clause);
            pay_jp_report_pkg.append_order_clause(c_data_arch_order_clause,l_order_by_clause);
          --
          else
          --
            if g_debug
            and g_detail_debug = 'Y' then
              hr_utility.set_location(l_proc,90);
            end if;
          --
            pay_jp_report_pkg.append_select_clause(c_data_ass_select_clause,l_select_clause);
            pay_jp_report_pkg.append_from_clause(c_data_ass_from_clause,l_from_clause);
            pay_jp_report_pkg.append_where_clause(c_data_ass_where_clause,l_where_clause);
            pay_jp_report_pkg.append_order_clause(c_data_ass_order_clause,l_order_by_clause);
          --
          end if;
        --
          --
          -- set variable parameter
          --
          l_from_clause := replace(l_from_clause,'i_bg_itax_dpnt_ref_type',g_bg_itax_dpnt_ref_type);
          l_from_clause := replace(l_from_clause,'i_business_group_id',to_char(g_business_group_id));
          l_from_clause := replace(l_from_clause,'i_effective_soy',fnd_date.date_to_canonical(g_effective_soy));
          l_from_clause := replace(l_from_clause,'i_effective_eoy',fnd_date.date_to_canonical(g_effective_eoy));
          l_from_clause := replace(l_from_clause,'i_organization_id',to_char(g_organization_id));
          l_from_clause := replace(l_from_clause,'i_district_code',g_district_code);
          l_from_clause := replace(l_from_clause,'i_eot',fnd_date.date_to_canonical(hr_api.g_eot));
          --
          l_where_clause := replace(l_where_clause,'i_business_group_id',to_char(g_business_group_id));
          l_where_clause := replace(l_where_clause,'i_effective_soy',fnd_date.date_to_canonical(g_effective_soy));
          l_where_clause := replace(l_where_clause,'i_effective_eoy',fnd_date.date_to_canonical(g_effective_eoy));
          l_where_clause := replace(l_where_clause,'i_organization_id',to_char(g_organization_id));
          l_where_clause := replace(l_where_clause,'i_district_code',g_district_code);
        --
          if g_debug
          and g_detail_debug = 'Y' then
            hr_utility.set_location(l_proc,100);
            --
            if g_show_debug is null
            or g_show_debug <> 'Y' then
            --
              pay_jp_report_pkg.show_debug(l_select_clause);
              pay_jp_report_pkg.show_debug(l_from_clause);
              pay_jp_report_pkg.show_debug(l_where_clause);
              pay_jp_report_pkg.show_debug(l_order_by_clause);
            --
            end if;
          end if;
        --
          execute immediate
            l_select_clause||
            l_from_clause||
            l_where_clause||
            l_order_by_clause
          bulk collect into l_data_tbl
          using l_payroll_action_id;
        --
          if g_debug
          and g_detail_debug = 'Y' then
            hr_utility.set_location(l_proc,110);
            hr_utility.trace('l_data_tbl.count : '||to_char(l_data_tbl.count));
          end if;
        --
          -- -----------------------------------------------------
          -- l_file_tbl setup
          -- -----------------------------------------------------
          for i in 1..l_data_tbl.count loop
          --
            if l_district_code is null
            or l_district_code <> l_data_tbl(i).district_code then
            --
              l_district_code := l_data_tbl(i).district_code;
            --
              l_itax_org_cnt := 0;
              l_itax_organization_id := null;
            --
            end if;
          --
            if l_file_name is null
            or l_file_name <> l_data_tbl(i).output_file_name then
            --
              l_file_name := l_data_tbl(i).output_file_name;
            --
              if l_itax_org_cnt < 1 then
              --
                l_file_cnt := l_file_cnt + 1;
                l_file_tbl(l_file_cnt).file_name := l_file_name;
              --
              end if;
            --
            end if;
          --
            if l_itax_organization_id is null
            or l_itax_organization_id <> l_data_tbl(i).itax_organization_id then
            --
              l_itax_organization_id := l_data_tbl(i).itax_organization_id;
              l_itax_org_cnt := l_itax_org_cnt + 1;
            --
              -- override output_file_name to unit file for multiple itax_org
              if l_itax_org_cnt > 1
              and (g_file_split is null
                  or g_file_split = 'Y') then
              --
                -- reset file_name for l_itax_org_cnt = 1 in same district_code group
                if l_itax_org_cnt = 2 then
                --
                  -- override file name
                  --
                  l_file_tbl(l_file_cnt).file_name := default_file_name(l_district_code);
                --
                end if;
              --
              end if;
            --
            end if;
          --
          end loop;
        --
          if g_debug
          and g_detail_debug = 'Y' then
            hr_utility.set_location(l_proc,120);
            hr_utility.trace('l_file_tbl.count : '||to_char(l_file_tbl.count));
          end if;
        --
          -- -----------------------------------------------------
          -- file delete
          -- -----------------------------------------------------
          for i in 1..l_file_tbl.count loop
          --
            l_file_name := l_file_tbl(i).file_name;
          --
            if g_del_file <> 'N' then
              pay_jp_report_pkg.delete_file(l_file_dir,l_file_name);
            end if;
          --
            if g_debug
            and g_detail_debug = 'Y' then
              hr_utility.trace(to_char(i)||' : '||l_file_name||' was deleted');
            end if;
          --
          end loop;
        --
          if g_debug
          and g_detail_debug = 'Y' then
            hr_utility.set_location(l_proc,130);
          --
            if g_show_debug is null
            or g_show_debug <> 'Y' then
            --
              for i in l_file_tbl.first..l_file_tbl.last loop
                hr_utility.trace('target of delete : '||to_char(i)||' : '||l_file_tbl(i).file_name);
              end loop;
            --
            end if;
          --
          end if;
        --
        end if;
      --
      else
      --
        if g_debug
        and g_detail_debug = 'Y' then
          hr_utility.trace('l_payroll_action_id is null');
        end if;
      --
      end if;
    --
    end if;
  --
  else
  --
    if g_debug
    and g_detail_debug = 'Y' then
      hr_utility.trace('l_file_dir is null');
    end if;
  --
  end if;
--
  if g_debug
  and g_detail_debug = 'Y' then
    hr_utility.set_location(l_proc,1000);
  end if;
--
end del_file;
--
-- -------------------------------------------------------------------------
-- gen_xml_header
-- -------------------------------------------------------------------------
procedure gen_xml_header
is
--
  l_proc varchar2(80) := c_package||'gen_xml_header';
--
  l_xml_header varchar2(32767);
--
begin
--
  if g_debug
  and g_detail_debug = 'Y' then
    hr_utility.set_location(l_proc,0);
  end if;
--
  l_xml_header := c_eol||'<spr_efile>'||c_eol;
--
  pay_core_files.write_to_magtape_lob(l_xml_header);
--
  if g_debug
  and g_detail_debug = 'Y' then
    hr_utility.set_location(l_proc,1000);
  end if;
--
end gen_xml_header;
--
-- -------------------------------------------------------------------------
-- gen_xml_body
-- -------------------------------------------------------------------------
procedure gen_xml_body
is
--
  l_proc varchar2(80) := c_package||'gen_xml_body';
--
  l_mag_assignment_action_id number;
--
begin
--
  if g_debug
  and g_detail_debug = 'Y' then
    hr_utility.set_location(l_proc,0);
  end if;
--
  l_mag_assignment_action_id := pay_magtape_generic.get_parameter_value('TRANSFER_ACT_ID');
--
  xml_assact(l_mag_assignment_action_id);
--
  if g_debug
  and g_detail_debug = 'Y' then
    hr_utility.trace('l_mag_assignment_action_id : '||to_char(l_mag_assignment_action_id));
    hr_utility.set_location(l_proc,1000);
  end if;
--
end gen_xml_body;
--
-- -------------------------------------------------------------------------
-- gen_xml_footer
-- -------------------------------------------------------------------------
procedure gen_xml_footer
is
--
  l_proc varchar2(80) := c_package||'gen_xml_footer';
--
  l_xml_footer varchar2(32767);
--
begin
--
  if g_debug
  and g_detail_debug = 'Y' then
    hr_utility.set_location(l_proc,0);
  end if;
--
  l_xml_footer := '</spr_efile>';
--
  pay_core_files.write_to_magtape_lob(l_xml_footer);
--
  if g_debug
  and g_detail_debug = 'Y' then
    hr_utility.set_location(l_proc,10);
  end if;
--
  gen_file;
--
  if g_debug
  and g_detail_debug = 'Y' then
    hr_utility.set_location(l_proc,20);
    hr_utility.trace('g_file_tbl.count : '||to_char(g_file_tbl.count));
  end if;
--
  --
  -- for debug purpose
  --
  if g_file_tbl.count > 0 then
  --
    for i in 1..g_file_tbl.count loop
    --
      if g_debug
      and g_detail_debug = 'Y' then
        hr_utility.trace('g_file_tbl file_name : '||g_file_tbl(i).file_name);
      end if;
    --
    end loop;
  --
  end if;
--
  if g_debug
  and g_detail_debug = 'Y' then
    hr_utility.set_location(l_proc,1000);
  end if;
--
end gen_xml_footer;
--
-- -------------------------------------------------------------------------
-- archive_data
-- -------------------------------------------------------------------------
procedure archive_data(
  p_assignment_action_id in number,
  p_effective_date       in date)
is
--
  l_proc varchar2(80) := c_package||'archive_data';
--
  l_assignment_id number;
  l_tax_type pay_element_entry_values_f.screen_entry_value%type;
--
  l_action_information_id number;
  l_object_version_number number;
--
begin
--
  if g_debug
  and g_detail_debug = 'Y' then
    hr_utility.set_location(l_proc,0);
    hr_utility.trace('assignment_action_id  : '||p_assignment_action_id);
  end if;
--
--  init_assact(
--    p_assignment_action_id => p_assignment_action_id,
--    p_assignment_id        => l_assignment_id);
----
--  if g_debug
--  and g_detail_debug = 'Y' then
--    hr_utility.set_location(l_proc,10);
--  end if;
----
--  archive_assact(
--    p_assignment_action_id => p_assignment_action_id,
--    p_assignment_id        => l_assignment_id);
--
  if g_debug
  and g_detail_debug = 'Y' then
    hr_utility.set_location(l_proc,1000);
  end if;
--
end archive_data;
--
-- -------------------------------------------------------------------------
-- deinitialize_code
-- -------------------------------------------------------------------------
procedure deinitialize_code(
  p_payroll_action_id in number)
is
--
  l_proc varchar2(80) := c_package||'deinitialize_code';
--
  l_all_district_cnt number;
  l_all_emp_cnt      number;
  l_all_term_emp_cnt number;
--
begin
--
  if g_debug then
    hr_utility.set_location(l_proc,0);
  end if;
--
  --archive_pact(p_payroll_action_id);
--
  if g_debug
  and g_detail_debug = 'Y' then
    hr_utility.set_location(l_proc,10);
    hr_utility.trace('g_file_tbl.count : '||to_char(g_file_tbl.count));
  end if;
--
  if g_file_tbl.count > 0 then
  --
    for i in 1..g_file_tbl.count loop
    --
      pay_jp_report_pkg.close_file(g_file_tbl(i).file_name,g_file_tbl(i).file_out,'a');
    --
    end loop;
  --
  end if;
--
  if g_debug
  and g_detail_debug = 'Y' then
    hr_utility.set_location(l_proc,20);
    hr_utility.trace('g_summary_tbl.count : '||to_char(g_summary_tbl.count));
  end if;
--
  --
  -- cnt note log
  --
  if g_show_summary is null
  or g_show_summary <> 'N' then
  --
    if g_summary_tbl.count > 0 then
    --
      l_all_district_cnt := 0;
      l_all_emp_cnt      := 0;
      l_all_term_emp_cnt := 0;
    --
      fnd_file.put_line(fnd_file.log,'----------------------------------------------------------------------------------------------------');
      fnd_file.put_line(fnd_file.log,'File Name - Municipality Code : Special Withholding Agent / Employee / Retired Employee');
      fnd_file.put_line(fnd_file.log,'----------------------------------------------------------------------------------------------------');
    --
      for j in 1..g_summary_tbl.count loop
      --
        fnd_file.put_line(fnd_file.log,
          g_summary_tbl(j).file_name||' - '||
          g_summary_tbl(j).district_code||' : '||
          to_char(g_summary_tbl(j).itax_org_cnt)||' / '||
          to_char(g_summary_tbl(j).emp_cnt)||' / '||
          to_char(g_summary_tbl(j).term_emp_cnt));
      --
        if g_summary_tbl(j).district_code is not null then
        --
          l_all_district_cnt := l_all_district_cnt + 1;
        --
        end if;
      --
        l_all_emp_cnt      := l_all_emp_cnt + g_summary_tbl(j).emp_cnt;
        l_all_term_emp_cnt := l_all_term_emp_cnt + g_summary_tbl(j).term_emp_cnt;
      --
      end loop;
    --
      fnd_file.put_line(fnd_file.log,' ');
      fnd_file.put_line(fnd_file.log,'----------------------------------------------------------------------------------------------------');
      fnd_file.put_line(fnd_file.log,'Total : Municipality Code / Employee / Retired Employee');
      fnd_file.put_line(fnd_file.log,'----------------------------------------------------------------------------------------------------');
      fnd_file.put_line(fnd_file.log,
        'Total : '||
        to_char(l_all_district_cnt)||' / '||
        to_char(l_all_emp_cnt)||' / '||
        to_char(l_all_term_emp_cnt));
      fnd_file.put_line(fnd_file.log,' ');
    --
    end if;
  --
  end if;
--
  g_per_ind_tbl.delete;
  g_ass_ind_tbl.delete;
  g_ass_tbl.delete;
  g_assact_tbl.delete;
  g_body_tbl.delete;
  g_file_tbl.delete;
  g_warning_exist := null;
  g_warning_header := null;
  g_summary_tbl.delete;
--
  if g_debug
  and g_detail_debug = 'Y' then
    hr_utility.set_location(l_proc,30);
  end if;
--
  --pay_core_xdo_utils.archive_deinit(p_payroll_action_id);
  pay_core_xdo_utils.standard_deinit(p_payroll_action_id);
--
  if g_debug then
    hr_utility.set_location(l_proc,1000);
  end if;
--
end deinitialize_code;
--
-- -------------------------------------------------------------------------
-- sort_code
-- -------------------------------------------------------------------------
--procedure sort_code(
--  p_payroll_action_id in number,
--  p_sqlstr            in out nocopy varchar2,
--  p_length            out number)
--is
----
--  l_proc varchar2(80) := c_package||'sort_code';
----
--begin
----
--  if g_debug then
--    hr_utility.set_location(l_proc,0);
--  end if;
----
--  p_sqlstr :=
--    'select paa.rowid
--     from   pay_payroll_actions ppa,
--            pay_assignment_actions paa
--     where  ppa.payroll_action_id = :pactid
--     and    paa.payroll_action_id = ppa.payroll_action_id';
----
--  p_length := lengthb(p_sqlstr);
----
--  if g_debug then
--    hr_utility.set_location(l_proc,1000);
--  end if;
----
--end sort_code;
--
end pay_jp_spr_efile_pkg;

/
