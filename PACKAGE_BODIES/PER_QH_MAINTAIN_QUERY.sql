--------------------------------------------------------
--  DDL for Package Body PER_QH_MAINTAIN_QUERY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_QH_MAINTAIN_QUERY" as
/* $Header: peqhmntq.pkb 120.5.12010000.3 2009/08/14 06:47:53 varanjan ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  per_qh_maintain_query.';
--
procedure onerow
(out_rec                      IN OUT NOCOPY mainrec
,p_person_id                  IN     number
,p_assignment_id              IN     number default null
,p_effective_date             IN     date
,p_template_name              IN     varchar2
,p_block_name                 IN     varchar2
,p_legislation_code           IN     varchar2
) is
--
--Added for PMxbg
cursor csr_bg_name
      (p_person_id number,
      p_effective_date date) is
select x.name
from per_business_groups x , per_all_people_f papf
where x.business_group_id = papf.business_group_id
and papf.person_id=p_person_id;
--
--Added for PMxbg
 cursor csr_get_leg
 (p_business_group_id number) is
 select x.legislation_code
 from per_business_groups x
 where x.business_group_id=p_business_group_id;
 --
  cursor csr_template(p_legislation_code varchar2) is
  select
  hft.form_template_id
  from hr_form_templates_b hft
  ,    fnd_form ff
  where
  ff.form_name='PERWSQHM'
  and ff.application_id=800
  and ff.form_id=hft.form_id
  and hft.template_name=p_template_name
  and (hft.legislation_code = p_legislation_code
      or hft.legislation_code is null);
  --
  l_form_template_id hr_form_templates_b.form_template_id%type;
  --
  l_default_value                VARCHAR2(2000);
  --
  CURSOR csr_template_items
    (p_form_template_id             IN    NUMBER
    ,p_full_item_name               IN    VARCHAR2
    )
  IS
    SELECT tim.template_item_id
          ,itptl.default_value
      FROM hr_template_items_b tim
      ,    hr_form_items_b fim
      ,    hr_item_properties_b itpb
      ,    hr_item_properties_tl itptl
     WHERE fim.full_item_name = p_full_item_name
       AND tim.form_item_id = fim.form_item_id
       AND tim.form_template_id = p_form_template_id
       AND itpb.template_item_id (+) = tim.template_item_id
       AND itptl.item_property_id (+) = itpb.item_property_id
       AND itptl.language (+) = USERENV('LANG');

  l_template_item                csr_template_items%ROWTYPE;
  --
  CURSOR csr_template_item_contexts
    (p_template_item_id             IN    NUMBER
    ,p_emp_apl_flag                 IN    VARCHAR2
    )
  IS
    SELECT itptl.default_value
      FROM hr_item_contexts icx
          ,hr_item_properties_b itpb
          ,hr_item_properties_tl itptl
          ,hr_template_item_contexts_b tic
     WHERE icx.segment1 = p_emp_apl_flag
       AND icx.item_context_id = tic.item_context_id
       AND tic.context_type = 'QH_PER_TYPE'
       AND tic.template_item_id = p_template_item_id
       AND itpb.template_item_context_id (+) = tic.template_item_context_id
       AND itptl.item_property_id (+) = itpb.item_property_id
       AND itptl.language (+) = USERENV('LANG');

  l_template_item_context        csr_template_item_contexts%ROWTYPE;
  --
  l_template_item_found          BOOLEAN;

--
cursor csr_person_details
      (p_person_id number
      ,p_effective_date date) is

select *
from per_all_people_f
where person_id=p_person_id
and p_effective_date between effective_start_date and effective_end_date;
--
cursor csr_person_type
      (p_person_type_id number) is
SELECT
  ppttl.user_person_type,
  ppt.system_person_type
FROM
  per_person_types_tl ppttl,
  per_person_types ppt
WHERE
  ppt.person_type_id=p_person_type_id
  and ppt.active_flag = 'Y'
  and ppttl.person_type_id = ppt.person_type_id
  and ppttl.language = userenv('LANG');
--
cursor csr_lang
      (p_lang_code VARCHAR2) is
select description
from fnd_languages_vl
where language_code=p_lang_code;
--
cursor csr_benfts_grp
      (p_benfts_grp_id NUMBER) is
select name
from  ben_benfts_grp
where benfts_grp_id=p_benfts_grp_id;
--
cursor leg_lookup(p_type varchar2) is
select rule_type
from pay_legislative_field_info plfi
where plfi.field_name = p_type
and plfi.legislation_code = p_legislation_code;
--
l_rule_type pay_legislative_field_info.rule_type%type;
--
cursor csr_application
       (p_person_id number
       ,p_effective_date date) is
select * from per_applications
where person_id=p_person_id
and p_effective_date between date_received and nvl(date_end,p_effective_date);
--
-- Bug 3540524 Starts here
-- Description : Modified the query of the cursor csr_period_of_svc.
/*cursor csr_period_of_svc
       (p_person_id number
       ,p_effective_date date) is
select * from per_periods_of_service
where person_id=p_person_id
and p_effective_date between date_start and nvl(final_process_date,p_effective_date);
*/
--
cursor csr_period_of_svc
       (p_person_id number
       ,p_effective_date date) is
select * from per_periods_of_service
where person_id=p_person_id
and date_start <= p_effective_date
order by date_start desc;
--
-- Bug 3540524 Ends here
--
--
-- Bug 3983662 Starts here
--
cursor csr_period_of_placement
       (p_person_id number
       ,p_effective_date date) is
select * from per_periods_of_placement
where person_id=p_person_id
and date_start <= p_effective_date
order by date_start desc;
/*and p_effective_date between date_start and nvl(actual_termination_date,p_effective_date);*/

-- Bug 3983662 Ends here
--
cursor csr_addresses
      (p_person_id number
      ,p_effective_date date) is
select *
from per_addresses
where person_id=p_person_id
and primary_flag='Y'
and p_effective_date between date_from and nvl(date_to,p_effective_date);
--
cursor csr_phone
      (p_person_id number
      ,p_type VARCHAR2
      ,p_effective_date date) is
select 0,phone_id,date_from,date_to,phone_number,object_version_number
from per_phones
where parent_id=p_person_id
and parent_table='PER_ALL_PEOPLE_F'
and phone_type=p_type
and p_effective_date between date_from and nvl(date_to,p_effective_date)
UNION
select months_between(p_effective_date,date_to),phone_id,date_from,date_to,phone_number,object_version_number
from per_phones
where parent_id=p_person_id
and parent_table='PER_ALL_PEOPLE_F'
and phone_type=p_type
and p_effective_date>date_to
UNION
select months_between(date_from,p_effective_date),phone_id,date_from,date_to,phone_number,object_version_number
from per_phones
where parent_id=p_person_id
and parent_table='PER_ALL_PEOPLE_F'
and phone_type=p_type
and p_effective_date<date_from
order by 1;
--
type phn_typ is record (dummy number
                       ,phone_id per_phones.phone_id%type
                       ,date_from per_phones.date_from%type
                       ,date_to per_phones.date_to%type
                       ,phone_number per_phones.phone_number%type
                       ,object_version_number per_phones.object_version_number%type);
phn_rec phn_typ;
--
cursor csr_assignment_details
       (p_assignment_id number
       ,p_effective_date date) is
select *
from per_all_assignments_f
where assignment_id=p_assignment_id
and p_effective_date between effective_start_date and effective_end_date;
--
cursor csr_asg_status
       (p_assignment_status_type_id number
       ,p_business_group_id         number) is
SELECT
  nvl(atl.user_status     ,stl.user_status),
  nvl(a.per_system_status ,s.per_system_status)
FROM
  per_ass_status_type_amends_tl atl,
  per_ass_status_type_amends a,
  per_assignment_status_types_tl stl,
  per_assignment_status_types s
WHERE
  s.assignment_status_type_id= p_assignment_status_type_id and
  a.assignment_status_type_id (+) = s.assignment_status_type_id and
  a.business_group_id (+) +0= p_business_group_id and
  nvl(a.active_flag, s.active_flag) = 'Y' and
  a.ass_status_type_amend_id = atl.ass_status_type_amend_id (+) and
  decode(atl.language,null,'1',atl.language) = decode(atl.language,null,'1',userenv('LANG')) and
  s.assignment_status_type_id = stl.assignment_status_type_id and
  stl.language = userenv('LANG');
--
cursor csr_rec_activity
      (p_recruitment_activity_id number) is
select name
from per_recruitment_activities
where recruitment_activity_id=p_recruitment_activity_id;
--
cursor csr_pgp_rec
      (p_people_group_id number) is
select * from pay_people_groups
where people_group_id=p_people_group_id;
--
cursor csr_scl_rec
      (p_soft_coding_keyflex_id number) is
select * from hr_soft_coding_keyflex
where soft_coding_keyflex_id=p_soft_coding_keyflex_id;
--
cursor csr_vacancy
      (p_vacancy_id number) is
select vac.name
,      rec.name
from   per_requisitions rec
,      per_vacancies vac
where vacancy_id=p_vacancy_id
and   vac.requisition_id=rec.requisition_id;
--
cursor csr_ceiling_step
      (p_special_ceiling_step_id number
      ,p_effective_date date) is
  select psp.spinal_point spinal_point
  , count(*) step
  from per_spinal_points psp
  , per_spinal_points psp2
  , per_spinal_point_steps_f psps
  , per_spinal_point_steps_f psps2
  where psp.spinal_point_id = psps.spinal_point_id
  and psps.grade_spine_id = psps2.grade_spine_id
  and psp2.spinal_point_id = psps2.spinal_point_id
  and psps.step_id=p_special_ceiling_step_id
  and psp.sequence >= psp2.sequence
  and p_effective_date between psps.effective_start_date
      and psps.effective_end_date
  and p_effective_date between psps2.effective_start_date
      and psps2.effective_end_date
  group by psp.spinal_point
  , psps.step_id
  , psps.sequence
  , psps.effective_start_date
  , psps.effective_end_date
  order by 2;
--
cursor csr_reference
      (p_contract_id number
      ,p_effective_date date) is
select reference
from per_contracts_f
where contract_id=p_contract_id
and p_effective_date between effective_start_date and effective_end_date;
--
cursor csr_collective_agr
      (p_collective_agreement_id number) is
select name
from per_collective_agreements
where collective_agreement_id=p_collective_agreement_id;
--
cursor csr_cagr_flex_num
      (p_id_flex_num number) is
select id_flex_structure_name
from fnd_id_flex_structures_vl
where id_flex_code= 'CAGR'
and   application_id = 800
and   id_flex_num=p_id_flex_num;
--
cursor csr_address_style
      (p_style VARCHAR2) is
select descriptive_flex_context_name
from   fnd_descr_flex_contexts_vl
where  descriptive_flexfield_name='Address Structure'
and    application_id=800
and    descriptive_flex_context_code=p_style;
--
cursor csr_pay_proposal
      (p_assignment_id number
      ,p_effective_date date) is
select *
from per_pay_proposals p1
where p1.assignment_id=p_assignment_id
and   p1.change_date=
     (select max(p2.change_date)
      from per_pay_proposals p2
      where p2.assignment_id=p_assignment_id
      and change_date<=p_effective_date)
and p1.date_to >= p_effective_date;    -- Fix For Bug # 8494017
--
cursor csr_deployment
      (p_person_id number) is
select *
from per_deployment_factors
where person_id=p_person_id;
--
cursor reverse_lookup(p_meaning varchar2
                     ,p_lookup_type varchar2) is
select lookup_code
from hr_lookups
where lookup_type=p_lookup_type
and meaning=p_meaning
and enabled_flag='Y'
and p_effective_date between
nvl(start_date_active,p_effective_date) and nvl(end_date_active,p_effective_date);
--
cursor csr_checklist
      (p_person_id number
      ,p_item_code varchar2) is
select *
from per_checklist_items
where person_id=p_person_id
and item_code=p_item_code;
--
cursor csr_country
      (p_territory_code varchar2) is
select territory_short_name
from fnd_territories_vl
where territory_code=p_territory_code;
--
cursor salary_basis(p_effective_date date
                 ,p_pay_basis_id number) is
SELECT ppb.name
,      ppb.pay_basis
,PET.INPUT_CURRENCY_CODE
, PIV.UOM
FROM PAY_ELEMENT_TYPES_F PET
, PAY_INPUT_VALUES_F       PIV
, PER_PAY_BASES            PPB
WHERE PPB.PAY_BASIS_ID=p_pay_basis_id
AND PPB.INPUT_VALUE_ID=PIV.INPUT_VALUE_ID
AND p_effective_date  BETWEEN
PIV.EFFECTIVE_START_DATE AND
PIV.EFFECTIVE_END_DATE
AND PIV.ELEMENT_TYPE_ID=PET.ELEMENT_TYPE_ID
AND p_effective_date  BETWEEN
PET.EFFECTIVE_START_DATE AND
PET.EFFECTIVE_END_DATE;
--
cursor csr_vendor(p_vendor_id in number) is
select vendor_name
from po_vendors pov
where pov.vendor_id = p_vendor_id;
--
cursor csr_vendor_site(p_vendor_site_id in number) is
select vendor_site_code
from po_vendor_sites_all
where vendor_site_id=p_vendor_site_id;
--
cursor csr_po_header(p_po_header_id in number) is
select segment1
from po_headers_all
where po_header_id = p_po_header_id;
--
cursor csr_po_line(p_po_line_id in number) is
select line_num
from po_lines_all
where po_line_id = p_po_line_id;
--
cursor csr_sob(p_set_of_books_id number) is
select sob.name, sob.chart_of_accounts_id
from gl_sets_of_books sob
where sob.set_of_books_id = p_set_of_books_id;
--
cursor csr_asg_rates(p_assignment_id number
                    ,p_effective_date date) is
select gr.grade_rule_id
      ,pr.name rate_name
      ,gr.rate_id
      ,SUBSTR(hr_general.decode_lookup('RATE_BASIS',pr.rate_basis),1,80) rate_basis
      ,fnd_asr.meaning asg_rate_type_name
      ,gr.currency_code
      ,f.name rate_currency
      ,gr.value
      ,gr.effective_start_date
      ,gr.effective_end_date
      ,gr.object_version_number
from  pay_grade_rules_f gr
     ,pay_rates pr
     ,fnd_currencies_vl f
     ,fnd_lookups fnd_asr
where gr.rate_type = 'A'
and   gr.grade_or_spinal_point_id = p_assignment_id
and   p_effective_date between gr.effective_start_date and gr.effective_end_date
and   gr.rate_id = pr.rate_id
and   gr.currency_code = f.currency_code
and  fnd_asr.lookup_code(+)=pr.asg_rate_type
and  fnd_asr.lookup_type(+)='PRICE DIFFERENTIALS';
--
l_rate_rec csr_asg_rates%rowtype;
--
l_uom pay_input_values_f.uom%type;
--
per_rec per_all_people_f%rowtype;
app_rec per_applications%rowtype;
pds_rec per_periods_of_service%rowtype;
pdp_rec per_periods_of_placement%rowtype;
addr_rec per_addresses%rowtype;
asg_rec per_all_assignments_f%rowtype;
pgp_rec pay_people_groups%rowtype;
scl_rec hr_soft_coding_keyflex%rowtype;
pyp_rec per_pay_proposals%rowtype;
dpf_rec per_deployment_factors%rowtype;
chk_rec per_checklist_items%rowtype;
--
l_end_of_time date;
l_legislation_code varchar2(150);
l_proc varchar2(72) := g_package||'onerow';
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
--
  l_end_of_time:=hr_api.g_eot;
--
-- get the person record
--
  open csr_person_details(p_person_id      => p_person_id
                         ,p_effective_date => p_effective_date);
  fetch csr_person_details into per_rec;
  if csr_person_details%notfound then
    close csr_person_details;
    out_rec.person_update_allowed:='FALSE';
    out_rec.asg_update_allowed:='FALSE';
    out_rec.tax_update_allowed:='FALSE';
  else
  close csr_person_details;
--
  hr_utility.set_location(l_proc, 20);
--
-- set the output fields
--
  out_rec.person_id                     :=per_rec.person_id;
  out_rec.business_group_id             :=per_rec.business_group_id;
  out_rec.per_effective_start_date      :=per_rec.effective_start_date;
  out_rec.per_effective_end_date        :=per_rec.effective_end_date;
--
  if per_rec.effective_end_date=l_end_of_time then
    out_rec.person_update_allowed:='TRUE';
  else
    out_rec.person_update_allowed:='FALSE';
  end if;
--
--Added for PMxbg
  open csr_get_leg(per_rec.business_group_id);
  fetch csr_get_leg into l_legislation_code;
  close csr_get_leg;
 --
  out_rec.legislation              :=l_legislation_code;
--
  hr_utility.set_location(l_proc, 30);
--
  open csr_person_type(per_rec.person_type_id);
  fetch csr_person_type into out_rec.person_type,out_rec.system_person_type;
  close csr_person_type;
--
  hr_utility.set_location(l_proc, 40);
--
  out_rec.person_type_id                :=per_rec.person_type_id;
  out_rec.last_name                     :=per_rec.last_name;
  out_rec.start_date                    :=per_rec.start_date;
  out_rec.applicant_number              :=per_rec.applicant_number;
  out_rec.background_check_status       :=per_rec.background_check_status;
  out_rec.background_date_check         :=per_rec.background_date_check;
  out_rec.blood_type_meaning            :=hr_reports.get_lookup_meaning('BLOOD_TYPE',per_rec.blood_type);
  out_rec.blood_type                    :=per_rec.blood_type;
--
  hr_utility.set_location(l_proc, 50);
--
if per_rec.person_id is not null then
            open csr_bg_name(per_rec.person_id,p_effective_date);
            fetch csr_bg_name into out_rec.business_group_name;
            close csr_bg_name;
          else
            out_rec.business_group_name:=null;
 end if;
--


  if per_rec.correspondence_language is not null then
    open csr_lang(per_rec.correspondence_language);
    fetch csr_lang into out_rec.corr_lang_meaning;
    close csr_lang;
  end if;
--
  hr_utility.set_location(l_proc, 60);
--
  out_rec.correspondence_language       :=per_rec.correspondence_language;
  out_rec.current_applicant_flag        :=per_rec.current_applicant_flag;
  out_rec.current_emp_or_apl_flag       :=per_rec.current_emp_or_apl_flag;
  out_rec.current_employee_flag         :=per_rec.current_employee_flag;
--CWK
  out_rec.current_npw_flag              :=per_rec.current_npw_flag;
  out_rec.npw_number                    :=per_rec.npw_number;
  out_rec.date_employee_data_verified   :=per_rec.date_employee_data_verified;
  out_rec.date_of_birth                 :=per_rec.date_of_birth;
  out_rec.age:=floor(months_between(p_effective_date,per_rec.date_of_birth)/12);
  out_rec.email_address                 :=per_rec.email_address;
  out_rec.employee_number               :=per_rec.employee_number;
  out_rec.expnse_chk_send_addr_meaning  :=hr_reports.get_lookup_meaning('HOME_OFFICE',per_rec.expense_check_send_to_address);
  out_rec.expnse_check_send_to_address  :=per_rec.expense_check_send_to_address;
  out_rec.first_name                    :=per_rec.first_name;
  out_rec.per_fte_capacity              :=per_rec.fte_capacity;
--
  hr_utility.set_location(l_proc, 70);
--
  out_rec.full_name                     :=per_rec.full_name;
  out_rec.hold_applicant_date_until     :=per_rec.hold_applicant_date_until;
  out_rec.honors                        :=per_rec.honors;
  out_rec.internal_location             :=per_rec.internal_location;
  out_rec.known_as                      :=per_rec.known_as;
  out_rec.last_medical_test_by          :=per_rec.last_medical_test_by;
  out_rec.last_medical_test_date        :=per_rec.last_medical_test_date;
  out_rec.mailstop                      :=per_rec.mailstop;
  out_rec.marital_status_meaning        :=hr_reports.get_lookup_meaning('MAR_STATUS',per_rec.marital_status);
  out_rec.marital_status                :=per_rec.marital_status;
  out_rec.middle_names                  :=per_rec.middle_names;
  out_rec.nationality_meaning           :=hr_reports.get_lookup_meaning('NATIONALITY',per_rec.nationality);
  out_rec.nationality                   :=per_rec.nationality;
  out_rec.national_identifier           :=per_rec.national_identifier;
  out_rec.office_number                 :=per_rec.office_number;
  out_rec.on_military_service           :=per_rec.on_military_service;
--
  hr_utility.set_location(l_proc, 80);
--
  out_rec.pre_name_adjunct              :=per_rec.pre_name_adjunct;
  out_rec.previous_last_name            :=per_rec.previous_last_name;
  out_rec.rehire_recommendation         :=per_rec.rehire_recommendation;
  out_rec.rehire_reason                 :=per_rec.rehire_reason;
  out_rec.resume_exists                 :=per_rec.resume_exists;
  out_rec.resume_last_updated           :=per_rec.resume_last_updated;
-- Bug 3037019
  out_rec.registered_disabled_flag      :=hr_reports.get_lookup_meaning('REGISTERED_DISABLED',per_rec.registered_disabled_flag);
  out_rec.registered_disabled           :=per_rec.registered_disabled_flag;
  out_rec.second_passport_exists        :=per_rec.second_passport_exists;
  out_rec.sex_meaning                   :=hr_reports.get_lookup_meaning('SEX',per_rec.sex);
  out_rec.sex                           :=per_rec.sex;
--
  hr_utility.set_location(l_proc, 90);
--
  out_rec.student_status_meaning        :=hr_reports.get_lookup_meaning('STUDENT_STATUS',per_rec.student_status);
  out_rec.student_status                :=per_rec.student_status;
  out_rec.suffix                        :=per_rec.suffix;
  out_rec.title_meaning                 :=hr_reports.get_lookup_meaning('TITLE',per_rec.title);
  out_rec.title                         :=per_rec.title;
  out_rec.work_schedule_meaning         :=hr_reports.get_lookup_meaning('WORK_SCHEDULE',per_rec.work_schedule);
  out_rec.work_schedule                 :=per_rec.work_schedule;
  out_rec.coord_ben_med_pln_no          :=per_rec.coord_ben_med_pln_no;
  out_rec.coord_ben_no_cvg_flag         :=per_rec.coord_ben_no_cvg_flag;
  out_rec.dpdnt_adoption_date           :=per_rec.dpdnt_adoption_date;
  out_rec.dpdnt_vlntry_svce_flag        :=per_rec.dpdnt_vlntry_svce_flag;
  out_rec.receipt_of_death_cert_date    :=per_rec.receipt_of_death_cert_date;
  out_rec.uses_tobacco_flag             :=per_rec.uses_tobacco_flag;
--
  hr_utility.set_location(l_proc, 100);
--
  if per_rec.benefit_group_id is not null then
    open csr_benfts_grp(per_rec.benefit_group_id);
    fetch csr_benfts_grp into out_rec.benefit_group;
    close csr_benfts_grp;
  end if;
--
  hr_utility.set_location(l_proc, 110);
--
  out_rec.benefit_group_id              :=per_rec.benefit_group_id;
  out_rec.attribute_category            :=per_rec.attribute_category;
  out_rec.attribute1                    :=per_rec.attribute1;
  out_rec.attribute2                    :=per_rec.attribute2;
  out_rec.attribute3                    :=per_rec.attribute3;
  out_rec.attribute4                    :=per_rec.attribute4;
  out_rec.attribute5                    :=per_rec.attribute5;
  out_rec.attribute6                    :=per_rec.attribute6;
  out_rec.attribute7                    :=per_rec.attribute7;
  out_rec.attribute8                    :=per_rec.attribute8;
  out_rec.attribute9                    :=per_rec.attribute9;
  out_rec.attribute10                   :=per_rec.attribute10;
  out_rec.attribute11                   :=per_rec.attribute11;
  out_rec.attribute12                   :=per_rec.attribute12;
  out_rec.attribute13                   :=per_rec.attribute13;
  out_rec.attribute14                   :=per_rec.attribute14;
  out_rec.attribute15                   :=per_rec.attribute15;
  out_rec.attribute16                   :=per_rec.attribute16;
  out_rec.attribute17                   :=per_rec.attribute17;
  out_rec.attribute18                   :=per_rec.attribute18;
  out_rec.attribute19                   :=per_rec.attribute19;
  out_rec.attribute20                   :=per_rec.attribute20;
  out_rec.attribute21                   :=per_rec.attribute21;
  out_rec.attribute22                   :=per_rec.attribute22;
  out_rec.attribute23                   :=per_rec.attribute23;
  out_rec.attribute24                   :=per_rec.attribute24;
  out_rec.attribute25                   :=per_rec.attribute25;
  out_rec.attribute26                   :=per_rec.attribute26;
  out_rec.attribute27                   :=per_rec.attribute27;
  out_rec.attribute28                   :=per_rec.attribute28;
  out_rec.attribute29                   :=per_rec.attribute29;
  out_rec.attribute30                   :=per_rec.attribute30;
  out_rec.per_information_category      :=per_rec.per_information_category;
  out_rec.per_information1              :=per_rec.per_information1;
  out_rec.per_information2              :=per_rec.per_information2;
  out_rec.per_information3              :=per_rec.per_information3;
  out_rec.per_information4              :=per_rec.per_information4;
  out_rec.per_information5              :=per_rec.per_information5;
  out_rec.per_information6              :=per_rec.per_information6;
  out_rec.per_information7              :=per_rec.per_information7;
  out_rec.per_information8              :=per_rec.per_information8;
  out_rec.per_information9              :=per_rec.per_information9;
  out_rec.per_information10             :=per_rec.per_information10;
  out_rec.per_information11             :=per_rec.per_information11;
  out_rec.per_information12             :=per_rec.per_information12;
  out_rec.per_information13             :=per_rec.per_information13;
  out_rec.per_information14             :=per_rec.per_information14;
  out_rec.per_information15             :=per_rec.per_information15;
  out_rec.per_information16             :=per_rec.per_information16;
  out_rec.per_information17             :=per_rec.per_information17;
  out_rec.per_information18             :=per_rec.per_information18;
  out_rec.per_information19             :=per_rec.per_information19;
  out_rec.per_information20             :=per_rec.per_information20;
  out_rec.per_information21             :=per_rec.per_information21;
  out_rec.per_information22             :=per_rec.per_information22;
  out_rec.per_information23             :=per_rec.per_information23;
  out_rec.per_information24             :=per_rec.per_information24;
  out_rec.per_information25             :=per_rec.per_information25;
  out_rec.per_information26             :=per_rec.per_information26;
  out_rec.per_information27             :=per_rec.per_information27;
  out_rec.per_information28             :=per_rec.per_information28;
  out_rec.per_information29             :=per_rec.per_information29;
  out_rec.per_information30             :=per_rec.per_information30;
  out_rec.date_of_death                 :=per_rec.date_of_death;
  out_rec.original_date_of_hire         :=per_rec.original_date_of_hire;
  --
  out_rec.town_of_birth                 :=per_rec.town_of_birth;
  open leg_lookup('TOWN_OF_BIRTH');
  fetch leg_lookup into l_rule_type;
  if leg_lookup%notfound then
    close leg_lookup;
    out_rec.town_of_birth_meaning:=per_rec.town_of_birth;
  else
    close leg_lookup;
    out_rec.town_of_birth_meaning:=
    hr_reports.get_lookup_meaning(l_rule_type,per_rec.town_of_birth);
  end if;
  --
  out_rec.region_of_birth               :=per_rec.region_of_birth;
  open leg_lookup('REGION_OF_BIRTH');
  fetch leg_lookup into l_rule_type;
  if leg_lookup%notfound then
    close leg_lookup;
    out_rec.region_of_birth_meaning:=per_rec.region_of_birth;
  else
    close leg_lookup;
    out_rec.region_of_birth_meaning:=
    hr_reports.get_lookup_meaning(l_rule_type,per_rec.region_of_birth);
  end if;
  --
  out_rec.country_of_birth              :=per_rec.country_of_birth;
--
  if per_rec.country_of_birth is not null then
    open csr_country(per_rec.country_of_birth);
    fetch csr_country into out_rec.country_of_birth_meaning;
    close csr_country;
  end if;
--
  out_rec.per_object_version_number     :=per_rec.object_version_number;
--
  hr_utility.set_location(l_proc, 120);
--
  if per_rec.current_applicant_flag='Y' then
--
  hr_utility.set_location(l_proc, 130);
--
    open csr_application(p_person_id,p_effective_date);
    fetch csr_application into app_rec;
    close csr_application;
--
  hr_utility.set_location(l_proc, 140);
--
    out_rec.application_id              :=app_rec.application_id;
    out_rec.projected_hire_date         :=app_rec.projected_hire_date;
    out_rec.appl_attribute_category     :=app_rec.appl_attribute_category;
    out_rec.appl_attribute1             :=app_rec.appl_attribute1;
    out_rec.appl_attribute2             :=app_rec.appl_attribute2;
    out_rec.appl_attribute3             :=app_rec.appl_attribute3;
    out_rec.appl_attribute4             :=app_rec.appl_attribute4;
    out_rec.appl_attribute5             :=app_rec.appl_attribute5;
    out_rec.appl_attribute6             :=app_rec.appl_attribute6;
    out_rec.appl_attribute7             :=app_rec.appl_attribute7;
    out_rec.appl_attribute8             :=app_rec.appl_attribute8;
    out_rec.appl_attribute9             :=app_rec.appl_attribute9;
    out_rec.appl_attribute10            :=app_rec.appl_attribute10;
    out_rec.appl_attribute11            :=app_rec.appl_attribute11;
    out_rec.appl_attribute12            :=app_rec.appl_attribute12;
    out_rec.appl_attribute13            :=app_rec.appl_attribute13;
    out_rec.appl_attribute14            :=app_rec.appl_attribute14;
    out_rec.appl_attribute15            :=app_rec.appl_attribute15;
    out_rec.appl_attribute16            :=app_rec.appl_attribute16;
    out_rec.appl_attribute17            :=app_rec.appl_attribute17;
    out_rec.appl_attribute18            :=app_rec.appl_attribute18;
    out_rec.appl_attribute19            :=app_rec.appl_attribute19;
    out_rec.appl_attribute20            :=app_rec.appl_attribute20;
    out_rec.current_employer            :=app_rec.current_employer;
    out_rec.successful_flag             :=app_rec.successful_flag;
    out_rec.termination_reason          :=app_rec.termination_reason;
    out_rec.termination_reason_meaning  :=hr_reports.get_lookup_meaning('TERM_APL_REASON',app_rec.termination_reason);
    out_rec.app_date_received           :=app_rec.date_received;
    out_rec.app_date_end                :=app_rec.date_end;
    out_rec.app_object_version_number   :=app_rec.object_version_number;
  end if;
--
  hr_utility.set_location(l_proc, 150);
--
-- Bug 3540524 Starts Here
-- Description : Bring the data back to form even if the person is not an employee.
--               Here this restriction is blocking the Adjusted service date to propagate
--               to the form, if the person is not an Emplyee.Made necessary code changes
--               in the form to prevent an update of the Adjusted Service date, if the person
--               is not an employee.
--  if per_rec.current_employee_flag='Y' then
--
    hr_utility.set_location(l_proc, 160);
--
    open csr_period_of_svc(p_person_id,p_effective_date);
    fetch csr_period_of_svc into pds_rec;
    close csr_period_of_svc;
    out_rec.period_of_service_id:=pds_rec.period_of_service_id;
    out_rec.adjusted_svc_date:=pds_rec.adjusted_svc_date;
    out_rec.employment_end_date:=pds_rec.final_process_date;
    out_rec.actual_termination_date:=pds_rec.actual_termination_date;
    out_rec.hire_date:=pds_rec.date_start;
    out_rec.pds_object_version_number   :=pds_rec.object_version_number;
--  end if;   -- Bug 3540524
--
-- Bug 3540524 Ends  Here
--
--CWK added
--  if per_rec.current_npw_flag='Y' then
--
-- The above checks were commented as part of 3540524 fix
-- This is not correct as this would not allow EX-CWK workers
-- to populate the employment_end_date.
--New check to verify the system_person_type is required as part of 5507008

if out_rec.SYSTEM_PERSON_TYPE in ('OTHER','APL') then
    --
    hr_utility.set_location(l_proc, 165);
    --
    open csr_period_of_placement(p_person_id,p_effective_date);
    fetch csr_period_of_placement into pdp_rec;
    close csr_period_of_placement;
    out_rec.period_of_placement_date_start:=pdp_rec.date_start;
    out_rec.pdp_object_version_number := pdp_rec.object_version_number;
    --this will populate the employment_end_date
    out_rec.employment_end_date:=pdp_rec.final_process_date;

end if;
-- end of fix 5507008
  hr_utility.set_location(l_proc, 170);
--
  hr_utility.set_location(l_proc, 180);
--
  open csr_addresses(p_person_id,p_effective_date);
  fetch csr_addresses into addr_rec;
  if csr_addresses%found then
--
  hr_utility.set_location(l_proc, 190);
--
    close csr_addresses;
    out_rec.address_id                   :=addr_rec.address_id;
    out_rec.adr_date_from                :=addr_rec.date_from;
    out_rec.addr_primary_flag            :=addr_rec.primary_flag;
--
    open csr_address_style(addr_rec.style);
    fetch csr_address_style into out_rec.style_meaning;
    close csr_address_style;
--
  hr_utility.set_location(l_proc, 200);
--
    out_rec.style                        :=addr_rec.style;
    out_rec.address_line1                :=addr_rec.address_line1;
    out_rec.address_line2                :=addr_rec.address_line2;
    out_rec.address_line3                :=addr_rec.address_line3;
    out_rec.address_type_meaning         :=hr_reports.get_lookup_meaning('ADDRESS_TYPE',addr_rec.address_type);
    out_rec.address_type                 :=addr_rec.address_type;
    out_rec.country                      :=addr_rec.country;
    out_rec.adr_date_to                  :=addr_rec.date_to;
    out_rec.postal_code                  :=addr_rec.postal_code;
    out_rec.region_1                     :=addr_rec.region_1;
    out_rec.region_2                     :=addr_rec.region_2;
    out_rec.region_3                     :=addr_rec.region_3;
    out_rec.town_or_city                 :=addr_rec.town_or_city;
    out_rec.telephone_number_1           :=addr_rec.telephone_number_1;
    out_rec.telephone_number_2           :=addr_rec.telephone_number_2;
    out_rec.telephone_number_3           :=addr_rec.telephone_number_3;
    out_rec.add_information13            :=addr_rec.add_information13;
    out_rec.add_information14            :=addr_rec.add_information14;
    out_rec.add_information15            :=addr_rec.add_information15;
    out_rec.add_information16            :=addr_rec.add_information16;
    out_rec.add_information17            :=addr_rec.add_information17;
    out_rec.add_information18            :=addr_rec.add_information18;
    out_rec.add_information19            :=addr_rec.add_information19;
    out_rec.add_information20            :=addr_rec.add_information20;
    out_rec.addr_attribute_category      :=addr_rec.addr_attribute_category;
    out_rec.addr_attribute1              :=addr_rec.addr_attribute1;
    out_rec.addr_attribute2              :=addr_rec.addr_attribute2;
    out_rec.addr_attribute3              :=addr_rec.addr_attribute3;
    out_rec.addr_attribute4              :=addr_rec.addr_attribute4;
    out_rec.addr_attribute5              :=addr_rec.addr_attribute5;
    out_rec.addr_attribute6              :=addr_rec.addr_attribute6;
    out_rec.addr_attribute7              :=addr_rec.addr_attribute7;
    out_rec.addr_attribute8              :=addr_rec.addr_attribute8;
    out_rec.addr_attribute9              :=addr_rec.addr_attribute9;
    out_rec.addr_attribute10             :=addr_rec.addr_attribute10;
    out_rec.addr_attribute11             :=addr_rec.addr_attribute11;
    out_rec.addr_attribute12             :=addr_rec.addr_attribute12;
    out_rec.addr_attribute13             :=addr_rec.addr_attribute13;
    out_rec.addr_attribute14             :=addr_rec.addr_attribute14;
    out_rec.addr_attribute15             :=addr_rec.addr_attribute15;
    out_rec.addr_attribute16             :=addr_rec.addr_attribute16;
    out_rec.addr_attribute17             :=addr_rec.addr_attribute17;
    out_rec.addr_attribute18             :=addr_rec.addr_attribute18;
    out_rec.addr_attribute19             :=addr_rec.addr_attribute19;
    out_rec.addr_attribute20             :=addr_rec.addr_attribute20;
    out_rec.addr_object_version_number   :=addr_rec.object_version_number;
--
  hr_utility.set_location(l_proc, 240);
  else
    close csr_addresses;
  end if;
--
  hr_utility.set_location(l_proc, 250);
--
  open csr_phone(p_person_id,'H1',p_effective_date);
  fetch csr_phone into phn_rec;
  if csr_phone%found then
--
  hr_utility.set_location(l_proc, 260);
--
    close csr_phone;
    out_rec.phn_h_phone_id               :=phn_rec.phone_id;
    out_rec.phn_h_date_from              :=phn_rec.date_from;
    out_rec.phn_h_date_to                :=phn_rec.date_to;
    out_rec.phn_h_phone_number           :=phn_rec.phone_number;
    out_rec.phn_h_object_version_number  :=phn_rec.object_version_number;
  else
    close csr_phone;
  end if;
--
  hr_utility.set_location(l_proc, 270);
--
  open csr_phone(p_person_id,'W1',p_effective_date);
  fetch csr_phone into phn_rec;
  if csr_phone%found then
--
  hr_utility.set_location(l_proc, 280);
--
    close csr_phone;
    out_rec.phn_w_phone_id               :=phn_rec.phone_id;
    out_rec.phn_w_date_from              :=phn_rec.date_from;
    out_rec.phn_w_date_to                :=phn_rec.date_to;
    out_rec.phn_w_phone_number           :=phn_rec.phone_number;
    out_rec.phn_w_object_version_number  :=phn_rec.object_version_number;
  else
    close csr_phone;
  end if;
--
  hr_utility.set_location(l_proc, 290);
--
  open csr_phone(p_person_id,'M',p_effective_date);
  fetch csr_phone into phn_rec;
  if csr_phone%found then
--
  hr_utility.set_location(l_proc, 300);
--
    close csr_phone;
    out_rec.phn_m_phone_id               :=phn_rec.phone_id;
    out_rec.phn_m_date_from              :=phn_rec.date_from;
    out_rec.phn_m_date_to                :=phn_rec.date_to;
    out_rec.phn_m_phone_number           :=phn_rec.phone_number;
    out_rec.phn_m_object_version_number  :=phn_rec.object_version_number;
  else
    close csr_phone;
  end if;
--
  hr_utility.set_location(l_proc, 310);
--
  open csr_phone(p_person_id,'HF',p_effective_date);
  fetch csr_phone into phn_rec;
  if csr_phone%found then
--
  hr_utility.set_location(l_proc, 320);
--
    close csr_phone;
    out_rec.phn_hf_phone_id              :=phn_rec.phone_id;
    out_rec.phn_hf_date_from             :=phn_rec.date_from;
    out_rec.phn_hf_date_to               :=phn_rec.date_to;
    out_rec.phn_hf_phone_number          :=phn_rec.phone_number;
    out_rec.phn_hf_object_version_number :=phn_rec.object_version_number;
  else
    close csr_phone;
  end if;
--
  hr_utility.set_location(l_proc, 330);
--
  open csr_phone(p_person_id,'WF',p_effective_date);
  fetch csr_phone into phn_rec;
  if csr_phone%found then
--
  hr_utility.set_location(l_proc, 340);
--
    close csr_phone;
    out_rec.phn_wf_phone_id              :=phn_rec.phone_id;
    out_rec.phn_wf_date_from             :=phn_rec.date_from;
    out_rec.phn_wf_date_to               :=phn_rec.date_to;
    out_rec.phn_wf_phone_number          :=phn_rec.phone_number;
    out_rec.phn_wf_object_version_number :=phn_rec.object_version_number;
  else
    close csr_phone;
  end if;
--
  hr_utility.set_location(l_proc, 350);
--
  open csr_deployment(p_person_id);
  fetch csr_deployment into dpf_rec;
  if csr_deployment%found then
--
  hr_utility.set_location(l_proc, 360);
--
    out_rec.deployment_factor_id         :=dpf_rec.deployment_factor_id;
    out_rec.work_any_country             :=dpf_rec.work_any_country;
    out_rec.work_any_location            :=dpf_rec.work_any_location;
    out_rec.relocate_domestically        :=dpf_rec.relocate_domestically;
    out_rec.relocate_internationally     :=dpf_rec.relocate_internationally;
    out_rec.travel_required              :=dpf_rec.travel_required;
--
  hr_utility.set_location(l_proc, 370);
--
    if dpf_rec.country1 is not null then
--
  hr_utility.set_location(l_proc, 380);
--
      open csr_country(dpf_rec.country1);
      fetch csr_country into out_rec.country1_meaning;
      close csr_country;
    end if;
    out_rec.country1                     :=dpf_rec.country1;
--
    if dpf_rec.country2 is not null then
--
  hr_utility.set_location(l_proc, 390);
--
      open csr_country(dpf_rec.country2);
      fetch csr_country into out_rec.country2_meaning;
      close csr_country;
    end if;
    out_rec.country2                     :=dpf_rec.country2;
--
    if dpf_rec.country3 is not null then
--
  hr_utility.set_location(l_proc, 400);
--
      open csr_country(dpf_rec.country3);
      fetch csr_country into out_rec.country3_meaning;
      close csr_country;
    end if;
    out_rec.country3                     :=dpf_rec.country3;
--
  hr_utility.set_location(l_proc, 410);
--
    out_rec.dpf_work_duration_meaning    :=hr_reports.get_lookup_meaning('PER_TIME_SCALES',dpf_rec.work_duration);
    out_rec.dpf_work_duration            :=dpf_rec.work_duration;
    out_rec.dpf_work_schedule_meaning    :=hr_reports.get_lookup_meaning('PER_WORK_SCHEDULE',dpf_rec.work_schedule);
    out_rec.dpf_work_schedule            :=dpf_rec.work_schedule;
    out_rec.dpf_work_hours_meaning       :=hr_reports.get_lookup_meaning('PER_WORK_HOURS',dpf_rec.work_hours);
    out_rec.dpf_work_hours               :=dpf_rec.work_hours;
    out_rec.dpf_fte_capacity_meaning     :=hr_reports.get_lookup_meaning('PER_FTE_CAPACITY',dpf_rec.fte_capacity);
    out_rec.dpf_fte_capacity             :=dpf_rec.fte_capacity;
    out_rec.visit_internationally        :=dpf_rec.visit_internationally;
    out_rec.only_current_location        :=dpf_rec.only_current_location;
--
  hr_utility.set_location(l_proc, 420);
--
    if dpf_rec.no_country1 is not null then
--
  hr_utility.set_location(l_proc, 430);
--
      open csr_country(dpf_rec.no_country1);
      fetch csr_country into out_rec.no_country1_meaning;
      close csr_country;
    end if;
    out_rec.no_country1                  :=dpf_rec.no_country1;
--
    if dpf_rec.no_country2 is not null then
--
  hr_utility.set_location(l_proc, 440);
--
      open csr_country(dpf_rec.no_country2);
      fetch csr_country into out_rec.no_country2_meaning;
      close csr_country;
    end if;
    out_rec.no_country2                  :=dpf_rec.no_country2;
--
    if dpf_rec.no_country3 is not null then
--
  hr_utility.set_location(l_proc, 450);
--
      open csr_country(dpf_rec.no_country3);
      fetch csr_country into out_rec.no_country3_meaning;
      close csr_country;
    end if;
    out_rec.no_country3                  :=dpf_rec.no_country3;
--
--
  hr_utility.set_location(l_proc, 460);
--
    out_rec.earliest_available_date      :=dpf_rec.earliest_available_date;
    out_rec.available_for_transfer       :=dpf_rec.available_for_transfer;
    out_rec.relocation_pref_meaning      :=hr_reports.get_lookup_meaning('PER_RELOCATION_PREFERENCES',dpf_rec.relocation_preference);
    out_rec.relocation_preference        :=dpf_rec.relocation_preference;
    out_rec.dpf_object_version_number    :=dpf_rec.object_version_number;
    out_rec.dpf_attribute_category       :=dpf_rec.attribute_category;
    out_rec.dpf_attribute1               :=dpf_rec.attribute1;
    out_rec.dpf_attribute2               :=dpf_rec.attribute2;
    out_rec.dpf_attribute3               :=dpf_rec.attribute3;
    out_rec.dpf_attribute4               :=dpf_rec.attribute4;
    out_rec.dpf_attribute5               :=dpf_rec.attribute5;
    out_rec.dpf_attribute6               :=dpf_rec.attribute6;
    out_rec.dpf_attribute7               :=dpf_rec.attribute7;
    out_rec.dpf_attribute8               :=dpf_rec.attribute8;
    out_rec.dpf_attribute9               :=dpf_rec.attribute9;
    out_rec.dpf_attribute10              :=dpf_rec.attribute10;
    out_rec.dpf_attribute11              :=dpf_rec.attribute11;
    out_rec.dpf_attribute12              :=dpf_rec.attribute12;
    out_rec.dpf_attribute13              :=dpf_rec.attribute13;
    out_rec.dpf_attribute14              :=dpf_rec.attribute14;
    out_rec.dpf_attribute15              :=dpf_rec.attribute15;
    out_rec.dpf_attribute16              :=dpf_rec.attribute16;
    out_rec.dpf_attribute17              :=dpf_rec.attribute17;
    out_rec.dpf_attribute18              :=dpf_rec.attribute18;
    out_rec.dpf_attribute19              :=dpf_rec.attribute19;
    out_rec.dpf_attribute20              :=dpf_rec.attribute20;
--
  hr_utility.set_location(l_proc, 470);
--
  else
    close csr_deployment;
  end if;
--
  open csr_template(per_per_bus.return_legislation_code(p_person_id));
  fetch csr_template into l_form_template_id;
  close csr_template;
--
  hr_utility.set_location(l_proc, 475);
  --
  open csr_template_items
    (p_form_template_id             => l_form_template_id
    ,p_full_item_name               => p_block_name||'.CHK1_ITEM_CODE_MEANING'
    );
  fetch csr_template_items into l_template_item;
  --
  IF (csr_template_items%found) THEN
    hr_utility.set_location(l_proc, 480);
    close csr_template_items;
    open csr_template_item_contexts
      (p_template_item_id             => l_template_item.template_item_id
      ,p_emp_apl_flag                 => out_rec.person_type
      );
    fetch csr_template_item_contexts INTO l_template_item_context;
    IF (csr_template_item_contexts%FOUND)
    THEN
      l_default_value := l_template_item_context.default_value;
    ELSE
      l_default_value := l_template_item.default_value;
    END IF;
    CLOSE csr_template_item_contexts;
    --
    open reverse_lookup(l_default_value,'CHECKLIST_ITEM');
    fetch reverse_lookup into chk_rec.item_code;
    if reverse_lookup%found then
    hr_utility.set_location(l_proc, 485);
      close reverse_lookup;
      out_rec.chk1_item_code_meaning:=l_default_value;
      out_rec.chk1_item_code        :=chk_rec.item_code;
    --
      open csr_checklist(p_person_id, chk_rec.item_code);
      fetch csr_checklist into chk_rec;
      if csr_checklist%found then
      --
        hr_utility.set_location(l_proc, 490);
      --
        close csr_checklist;
        out_rec.chk1_checklist_item_id       :=chk_rec.checklist_item_id;
        out_rec.chk1_date_due                :=chk_rec.date_due;
        out_rec.chk1_date_done               :=chk_rec.date_done;
        out_rec.chk1_status_meaning          :=hr_reports.get_lookup_meaning('CHECKLIST_STATUS',chk_rec.status);
        out_rec.chk1_status                  :=chk_rec.status;
        out_rec.chk1_notes                   :=chk_rec.notes;
        out_rec.chk1_object_version_number   :=chk_rec.object_version_number;
      --
        hr_utility.set_location(l_proc,495);
      --
      else
        close csr_checklist;
      end if;
    else
      hr_utility.set_location(l_proc,500);
      close reverse_lookup;
      out_rec.chk1_item_code_meaning:=null;
      out_rec.chk1_item_code        :=null;
    end if;

  else
    close csr_template_items;
  END IF;
--
    hr_utility.set_location(l_proc, 505);
  open csr_template_items
    (p_form_template_id             => l_form_template_id
    ,p_full_item_name               => p_block_name||'.CHK2_ITEM_CODE_MEANING'
    );
  fetch csr_template_items into l_template_item;
  --
  IF (csr_template_items%found) THEN
    hr_utility.set_location(l_proc, 510);
    close csr_template_items;
    open csr_template_item_contexts
      (p_template_item_id             => l_template_item.template_item_id
      ,p_emp_apl_flag                 => out_rec.person_type
      );
    fetch csr_template_item_contexts INTO l_template_item_context;
    IF (csr_template_item_contexts%FOUND)
    THEN
      l_default_value := l_template_item_context.default_value;
    ELSE
      l_default_value := l_template_item.default_value;
    END IF;
    CLOSE csr_template_item_contexts;
    --
    open reverse_lookup(l_default_value,'CHECKLIST_ITEM');
    fetch reverse_lookup into chk_rec.item_code;
    if reverse_lookup%found then
    hr_utility.set_location(l_proc, 515);
      close reverse_lookup;
      out_rec.chk2_item_code_meaning:=l_default_value;
      out_rec.chk2_item_code        :=chk_rec.item_code;
    --
      open csr_checklist(p_person_id, chk_rec.item_code);
      fetch csr_checklist into chk_rec;
      if csr_checklist%found then
      --
        hr_utility.set_location(l_proc, 520);
      --
        close csr_checklist;
        out_rec.chk2_checklist_item_id       :=chk_rec.checklist_item_id;
        out_rec.chk2_date_due                :=chk_rec.date_due;
        out_rec.chk2_date_done               :=chk_rec.date_done;
        out_rec.chk2_status_meaning          :=hr_reports.get_lookup_meaning('CHECKLIST_STATUS',chk_rec.status);
        out_rec.chk2_status                  :=chk_rec.status;
        out_rec.chk2_notes                   :=chk_rec.notes;
        out_rec.chk2_object_version_number   :=chk_rec.object_version_number;
      --
        hr_utility.set_location(l_proc,525);
      --
      else
        close csr_checklist;
      end if;
    else
      hr_utility.set_location(l_proc,530);
      close reverse_lookup;
      out_rec.chk2_item_code_meaning:=null;
      out_rec.chk2_item_code        :=null;
    end if;

  else
    close csr_template_items;
  END IF;
--
  hr_utility.set_location(l_proc,535);
--
  open csr_template_items
    (p_form_template_id             => l_form_template_id
    ,p_full_item_name               => p_block_name||'.CHK3_ITEM_CODE_MEANING'
    );
  fetch csr_template_items into l_template_item;
  --
  IF (csr_template_items%found) THEN
    hr_utility.set_location(l_proc, 540);
    close csr_template_items;
    open csr_template_item_contexts
      (p_template_item_id             => l_template_item.template_item_id
      ,p_emp_apl_flag                 => out_rec.person_type
      );
    fetch csr_template_item_contexts INTO l_template_item_context;
    IF (csr_template_item_contexts%FOUND)
    THEN
      l_default_value := l_template_item_context.default_value;
    ELSE
      l_default_value := l_template_item.default_value;
    END IF;
    CLOSE csr_template_item_contexts;
    --
    open reverse_lookup(l_default_value,'CHECKLIST_ITEM');
    fetch reverse_lookup into chk_rec.item_code;
    if reverse_lookup%found then
    hr_utility.set_location(l_proc, 545);
      close reverse_lookup;
      out_rec.chk3_item_code_meaning:=l_default_value;
      out_rec.chk3_item_code        :=chk_rec.item_code;
    --
      open csr_checklist(p_person_id, chk_rec.item_code);
      fetch csr_checklist into chk_rec;
      if csr_checklist%found then
      --
        hr_utility.set_location(l_proc, 550);
      --
        close csr_checklist;
        out_rec.chk3_checklist_item_id       :=chk_rec.checklist_item_id;
        out_rec.chk3_date_due                :=chk_rec.date_due;
        out_rec.chk3_date_done               :=chk_rec.date_done;
        out_rec.chk3_status_meaning          :=hr_reports.get_lookup_meaning('CHECKLIST_STATUS',chk_rec.status);
        out_rec.chk3_status                  :=chk_rec.status;
        out_rec.chk3_notes                   :=chk_rec.notes;
        out_rec.chk3_object_version_number   :=chk_rec.object_version_number;
      --
        hr_utility.set_location(l_proc,555);
      --
      else
        close csr_checklist;
      end if;
    else
      hr_utility.set_location(l_proc,560);
      close reverse_lookup;
      out_rec.chk3_item_code_meaning:=null;
      out_rec.chk3_item_code        :=null;
    end if;

  else
    close csr_template_items;
  END IF;
--
  hr_utility.set_location(l_proc,565);
--
  open csr_template_items
    (p_form_template_id             => l_form_template_id
    ,p_full_item_name               => p_block_name||'.CHK4_ITEM_CODE_MEANING'
    );
  fetch csr_template_items into l_template_item;
  --
  IF (csr_template_items%found) THEN
    hr_utility.set_location(l_proc, 570);
    close csr_template_items;
    open csr_template_item_contexts
      (p_template_item_id             => l_template_item.template_item_id
      ,p_emp_apl_flag                 => out_rec.person_type
      );
    fetch csr_template_item_contexts INTO l_template_item_context;
    IF (csr_template_item_contexts%FOUND)
    THEN
      l_default_value := l_template_item_context.default_value;
    ELSE
      l_default_value := l_template_item.default_value;
    END IF;
    CLOSE csr_template_item_contexts;
    --
    open reverse_lookup(l_default_value,'CHECKLIST_ITEM');
    fetch reverse_lookup into chk_rec.item_code;
    if reverse_lookup%found then
    hr_utility.set_location(l_proc, 575);
      close reverse_lookup;
      out_rec.chk4_item_code_meaning:=l_default_value;
      out_rec.chk4_item_code        :=chk_rec.item_code;
    --
      open csr_checklist(p_person_id, chk_rec.item_code);
      fetch csr_checklist into chk_rec;
      if csr_checklist%found then
      --
        hr_utility.set_location(l_proc, 580);
      --
        close csr_checklist;
        out_rec.chk4_checklist_item_id       :=chk_rec.checklist_item_id;
        out_rec.chk4_date_due                :=chk_rec.date_due;
        out_rec.chk4_date_done               :=chk_rec.date_done;
        out_rec.chk4_status_meaning          :=hr_reports.get_lookup_meaning('CHECKLIST_STATUS',chk_rec.status);
        out_rec.chk4_status                  :=chk_rec.status;
        out_rec.chk4_notes                   :=chk_rec.notes;
        out_rec.chk4_object_version_number   :=chk_rec.object_version_number;
      --
        hr_utility.set_location(l_proc,585);
      --
      else
        close csr_checklist;
      end if;
    else
      hr_utility.set_location(l_proc,590);
      close reverse_lookup;
      out_rec.chk4_item_code_meaning:=null;
      out_rec.chk4_item_code        :=null;
    end if;

  else
    close csr_template_items;
  END IF;
--
  hr_utility.set_location(l_proc,595);
--
  open csr_template_items
    (p_form_template_id             => l_form_template_id
    ,p_full_item_name               => p_block_name||'.CHK5_ITEM_CODE_MEANING'
    );
  fetch csr_template_items into l_template_item;
  --
  IF (csr_template_items%found) THEN
    hr_utility.set_location(l_proc, 600);
    close csr_template_items;
    open csr_template_item_contexts
      (p_template_item_id             => l_template_item.template_item_id
      ,p_emp_apl_flag                 => out_rec.person_type
      );
    fetch csr_template_item_contexts INTO l_template_item_context;
    IF (csr_template_item_contexts%FOUND)
    THEN
      l_default_value := l_template_item_context.default_value;
    ELSE
      l_default_value := l_template_item.default_value;
    END IF;
    CLOSE csr_template_item_contexts;
    --
    open reverse_lookup(l_default_value,'CHECKLIST_ITEM');
    fetch reverse_lookup into chk_rec.item_code;
    if reverse_lookup%found then
    hr_utility.set_location(l_proc, 605);
      close reverse_lookup;
      out_rec.chk5_item_code_meaning:=l_default_value;
      out_rec.chk5_item_code        :=chk_rec.item_code;
    --
      open csr_checklist(p_person_id, chk_rec.item_code);
      fetch csr_checklist into chk_rec;
      if csr_checklist%found then
      --
        hr_utility.set_location(l_proc, 610);
      --
        close csr_checklist;
        out_rec.chk5_checklist_item_id       :=chk_rec.checklist_item_id;
        out_rec.chk5_date_due                :=chk_rec.date_due;
        out_rec.chk5_date_done               :=chk_rec.date_done;
        out_rec.chk5_status_meaning          :=hr_reports.get_lookup_meaning('CHECKLIST_STATUS',chk_rec.status);
        out_rec.chk5_status                  :=chk_rec.status;
        out_rec.chk5_notes                   :=chk_rec.notes;
        out_rec.chk5_object_version_number   :=chk_rec.object_version_number;
      --
        hr_utility.set_location(l_proc,615);
      --
      else
        close csr_checklist;
      end if;
    else
      hr_utility.set_location(l_proc,620);
      close reverse_lookup;
      out_rec.chk5_item_code_meaning:=null;
      out_rec.chk5_item_code        :=null;
    end if;

  else
    close csr_template_items;
  END IF;
--
  hr_utility.set_location(l_proc,625);
--
  open csr_template_items
    (p_form_template_id             => l_form_template_id
    ,p_full_item_name               => p_block_name||'.CHK6_ITEM_CODE_MEANING'
    );
  fetch csr_template_items into l_template_item;
  --
  IF (csr_template_items%found) THEN
    hr_utility.set_location(l_proc, 630);
    close csr_template_items;
    open csr_template_item_contexts
      (p_template_item_id             => l_template_item.template_item_id
      ,p_emp_apl_flag                 => out_rec.person_type
      );
    fetch csr_template_item_contexts INTO l_template_item_context;
    IF (csr_template_item_contexts%FOUND)
    THEN
      l_default_value := l_template_item_context.default_value;
    ELSE
      l_default_value := l_template_item.default_value;
    END IF;
    CLOSE csr_template_item_contexts;
    --
    open reverse_lookup(l_default_value,'CHECKLIST_ITEM');
    fetch reverse_lookup into chk_rec.item_code;
    if reverse_lookup%found then
    hr_utility.set_location(l_proc, 635);
      close reverse_lookup;
      out_rec.chk6_item_code_meaning:=l_default_value;
      out_rec.chk6_item_code        :=chk_rec.item_code;
    --
      open csr_checklist(p_person_id, chk_rec.item_code);
      fetch csr_checklist into chk_rec;
      if csr_checklist%found then
      --
        hr_utility.set_location(l_proc, 640);
      --
        close csr_checklist;
        out_rec.chk6_checklist_item_id       :=chk_rec.checklist_item_id;
        out_rec.chk6_date_due                :=chk_rec.date_due;
        out_rec.chk6_date_done               :=chk_rec.date_done;
        out_rec.chk6_status_meaning          :=hr_reports.get_lookup_meaning('CHECKLIST_STATUS',chk_rec.status);
        out_rec.chk6_status                  :=chk_rec.status;
        out_rec.chk6_notes                   :=chk_rec.notes;
        out_rec.chk6_object_version_number   :=chk_rec.object_version_number;
      --
        hr_utility.set_location(l_proc,645);
      --
      else
        close csr_checklist;
      end if;
    else
      hr_utility.set_location(l_proc,650);
      close reverse_lookup;
      out_rec.chk6_item_code_meaning:=null;
      out_rec.chk6_item_code        :=null;
    end if;

  else
    close csr_template_items;
  END IF;
--
   hr_utility.set_location(l_proc,655);
--
  open csr_template_items
    (p_form_template_id             => l_form_template_id
    ,p_full_item_name               => p_block_name||'.CHK7_ITEM_CODE_MEANING'
    );
  fetch csr_template_items into l_template_item;
  --
  IF (csr_template_items%found) THEN
    hr_utility.set_location(l_proc, 660);
    close csr_template_items;
    open csr_template_item_contexts
      (p_template_item_id             => l_template_item.template_item_id
      ,p_emp_apl_flag                 => out_rec.person_type
      );
    fetch csr_template_item_contexts INTO l_template_item_context;
    IF (csr_template_item_contexts%FOUND)
    THEN
      l_default_value := l_template_item_context.default_value;
    ELSE
      l_default_value := l_template_item.default_value;
    END IF;
    CLOSE csr_template_item_contexts;
    --
    open reverse_lookup(l_default_value,'CHECKLIST_ITEM');
    fetch reverse_lookup into chk_rec.item_code;
    if reverse_lookup%found then
    hr_utility.set_location(l_proc, 665);
      close reverse_lookup;
      out_rec.chk7_item_code_meaning:=l_default_value;
      out_rec.chk7_item_code        :=chk_rec.item_code;
    --
      open csr_checklist(p_person_id, chk_rec.item_code);
      fetch csr_checklist into chk_rec;
      if csr_checklist%found then
      --
        hr_utility.set_location(l_proc, 670);
      --
        close csr_checklist;
        out_rec.chk7_checklist_item_id       :=chk_rec.checklist_item_id;
        out_rec.chk7_date_due                :=chk_rec.date_due;
        out_rec.chk7_date_done               :=chk_rec.date_done;
        out_rec.chk7_status_meaning          :=hr_reports.get_lookup_meaning('CHECKLIST_STATUS',chk_rec.status);
        out_rec.chk7_status                  :=chk_rec.status;
        out_rec.chk7_notes                   :=chk_rec.notes;
        out_rec.chk7_object_version_number   :=chk_rec.object_version_number;
      --
        hr_utility.set_location(l_proc,675);
      --
      else
        close csr_checklist;
      end if;
    else
      hr_utility.set_location(l_proc,680);
      close reverse_lookup;
      out_rec.chk7_item_code_meaning:=null;
      out_rec.chk7_item_code        :=null;
    end if;

  else
    close csr_template_items;
  END IF;
--
  hr_utility.set_location(l_proc,685);
--
  open csr_template_items
    (p_form_template_id             => l_form_template_id
    ,p_full_item_name               => p_block_name||'.CHK8_ITEM_CODE_MEANING'
    );
  fetch csr_template_items into l_template_item;
  --
  IF (csr_template_items%found) THEN
    hr_utility.set_location(l_proc, 690);
    close csr_template_items;
    open csr_template_item_contexts
      (p_template_item_id             => l_template_item.template_item_id
      ,p_emp_apl_flag                 => out_rec.person_type
      );
    fetch csr_template_item_contexts INTO l_template_item_context;
    IF (csr_template_item_contexts%FOUND)
    THEN
      l_default_value := l_template_item_context.default_value;
    ELSE
      l_default_value := l_template_item.default_value;
    END IF;
    CLOSE csr_template_item_contexts;
    --
    open reverse_lookup(l_default_value,'CHECKLIST_ITEM');
    fetch reverse_lookup into chk_rec.item_code;
    if reverse_lookup%found then
    hr_utility.set_location(l_proc, 695);
      close reverse_lookup;
      out_rec.chk8_item_code_meaning:=l_default_value;
      out_rec.chk8_item_code        :=chk_rec.item_code;
    --
      open csr_checklist(p_person_id, chk_rec.item_code);
      fetch csr_checklist into chk_rec;
      if csr_checklist%found then
      --
        hr_utility.set_location(l_proc, 700);
      --
        close csr_checklist;
        out_rec.chk8_checklist_item_id       :=chk_rec.checklist_item_id;
        out_rec.chk8_date_due                :=chk_rec.date_due;
        out_rec.chk8_date_done               :=chk_rec.date_done;
        out_rec.chk8_status_meaning          :=hr_reports.get_lookup_meaning('CHECKLIST_STATUS',chk_rec.status);
        out_rec.chk8_status                  :=chk_rec.status;
        out_rec.chk8_notes                   :=chk_rec.notes;
        out_rec.chk8_object_version_number   :=chk_rec.object_version_number;
      --
        hr_utility.set_location(l_proc,705);
      --
      else
        close csr_checklist;
      end if;
    else
      hr_utility.set_location(l_proc,710);
      close reverse_lookup;
      out_rec.chk8_item_code_meaning:=null;
      out_rec.chk8_item_code        :=null;
    end if;

  else
    close csr_template_items;
  END IF;
--
  hr_utility.set_location(l_proc,715);
--
  open csr_template_items
    (p_form_template_id             => l_form_template_id
    ,p_full_item_name               => p_block_name||'.CHK9_ITEM_CODE_MEANING'
    );
  fetch csr_template_items into l_template_item;
  --
  IF (csr_template_items%found) THEN
    hr_utility.set_location(l_proc, 720);
    close csr_template_items;
    open csr_template_item_contexts
      (p_template_item_id             => l_template_item.template_item_id
      ,p_emp_apl_flag                 => out_rec.person_type
      );
    fetch csr_template_item_contexts INTO l_template_item_context;
    IF (csr_template_item_contexts%FOUND)
    THEN
      l_default_value := l_template_item_context.default_value;
    ELSE
      l_default_value := l_template_item.default_value;
    END IF;
    CLOSE csr_template_item_contexts;
    --
    open reverse_lookup(l_default_value,'CHECKLIST_ITEM');
    fetch reverse_lookup into chk_rec.item_code;
    if reverse_lookup%found then
    hr_utility.set_location(l_proc, 725);
      close reverse_lookup;
      out_rec.chk9_item_code_meaning:=l_default_value;
      out_rec.chk9_item_code        :=chk_rec.item_code;
    --
      open csr_checklist(p_person_id, chk_rec.item_code);
      fetch csr_checklist into chk_rec;
      if csr_checklist%found then
      --
        hr_utility.set_location(l_proc, 730);
      --
        close csr_checklist;
        out_rec.chk9_checklist_item_id       :=chk_rec.checklist_item_id;
        out_rec.chk9_date_due                :=chk_rec.date_due;
        out_rec.chk9_date_done               :=chk_rec.date_done;
        out_rec.chk9_status_meaning          :=hr_reports.get_lookup_meaning('CHECKLIST_STATUS',chk_rec.status);
        out_rec.chk9_status                  :=chk_rec.status;
        out_rec.chk9_notes                   :=chk_rec.notes;
        out_rec.chk9_object_version_number   :=chk_rec.object_version_number;
      --
        hr_utility.set_location(l_proc,735);
      --
      else
        close csr_checklist;
      end if;
    else
      hr_utility.set_location(l_proc,740);
      close reverse_lookup;
      out_rec.chk9_item_code_meaning:=null;
      out_rec.chk9_item_code        :=null;
    end if;

  else
    close csr_template_items;
  END IF;
--
  hr_utility.set_location(l_proc,745);
--
  open csr_template_items
    (p_form_template_id             => l_form_template_id
    ,p_full_item_name               => p_block_name||'.CHK10_ITEM_CODE_MEANING'
    );
  fetch csr_template_items into l_template_item;
  --
  IF (csr_template_items%found) THEN
    hr_utility.set_location(l_proc, 750);
    close csr_template_items;
    open csr_template_item_contexts
      (p_template_item_id             => l_template_item.template_item_id
      ,p_emp_apl_flag                 => out_rec.person_type
      );
    fetch csr_template_item_contexts INTO l_template_item_context;
    IF (csr_template_item_contexts%FOUND)
    THEN
      l_default_value := l_template_item_context.default_value;
    ELSE
      l_default_value := l_template_item.default_value;
    END IF;
    CLOSE csr_template_item_contexts;
    --
    open reverse_lookup(l_default_value,'CHECKLIST_ITEM');
    fetch reverse_lookup into chk_rec.item_code;
    if reverse_lookup%found then
    hr_utility.set_location(l_proc, 755);
      close reverse_lookup;
      out_rec.chk10_item_code_meaning:=l_default_value;
      out_rec.chk10_item_code        :=chk_rec.item_code;
    --
      open csr_checklist(p_person_id, chk_rec.item_code);
      fetch csr_checklist into chk_rec;
      if csr_checklist%found then
      --
        hr_utility.set_location(l_proc, 760);
      --
        close csr_checklist;
        out_rec.chk10_checklist_item_id       :=chk_rec.checklist_item_id;
        out_rec.chk10_date_due                :=chk_rec.date_due;
        out_rec.chk10_date_done               :=chk_rec.date_done;
        out_rec.chk10_status_meaning          :=hr_reports.get_lookup_meaning('CHECKLIST_STATUS',chk_rec.status);
        out_rec.chk10_status                  :=chk_rec.status;
        out_rec.chk10_notes                   :=chk_rec.notes;
        out_rec.chk10_object_version_number   :=chk_rec.object_version_number;
      --
        hr_utility.set_location(l_proc,765);
      --
      else
        close csr_checklist;
      end if;
    else
      hr_utility.set_location(l_proc,770);
      close reverse_lookup;
      out_rec.chk10_item_code_meaning:=null;
      out_rec.chk10_item_code        :=null;
    end if;

  else
    close csr_template_items;
  END IF;
--
  hr_utility.set_location(l_proc,771);
  hr_utility.trace('p_assignment_id   : ' || p_assignment_id);
  hr_utility.trace('p_effective_date  : ' || p_effective_date);
--
  if p_assignment_id is not null then
--
  hr_utility.set_location(l_proc,772);
--
    open csr_assignment_details(p_assignment_id,p_effective_date);
    fetch csr_assignment_details into asg_rec;
    if csr_assignment_details%notfound then
      close csr_assignment_details;
      out_rec.assignment_id:=-1;
      --no assignment found mean person is OTHER or EX-something
      --flag up that the fields should be disabled, fixes bug 3929761
      out_rec.asg_update_allowed:='FALSE';
      hr_utility.set_location(l_proc,773);
    else
--
      hr_utility.set_location(l_proc,774);
--
      out_rec.assignment_id                 :=asg_rec.assignment_id;
      out_rec.asg_effective_start_date      :=asg_rec.effective_start_date;
      out_rec.asg_effective_end_date        :=asg_rec.effective_end_date;
--
      if asg_rec.effective_end_date=l_end_of_time then
        out_rec.asg_update_allowed:='TRUE';
      else
        out_rec.asg_update_allowed:='FALSE';
      end if;
--
      hr_utility.set_location(l_proc,775);
--
      if asg_rec.recruiter_id is not null then
        out_rec.recruiter
          :=per_qh_populate.get_full_name(asg_rec.recruiter_id,p_effective_date);
      end if;
      out_rec.recruiter_id                  :=asg_rec.recruiter_id;
--
  hr_utility.set_location(l_proc,776);
--
      if asg_rec.grade_id is not null then
        out_rec.grade:=per_qh_populate.get_grade(asg_rec.grade_id);
      end if;
      out_rec.grade_id                      :=asg_rec.grade_id;
--
  hr_utility.set_location(l_proc,777);
--
      if asg_rec.grade_ladder_pgm_id is not null then
        out_rec.grade_ladder
          := per_qh_populate.get_grade_ladder(asg_rec.grade_ladder_pgm_id
                                             ,p_effective_date);
      end if;
      out_rec.grade_ladder_pgm_id           := asg_rec.grade_ladder_pgm_id;
--
  hr_utility.set_location(l_proc,778);
--
      if asg_rec.position_id is not null then
        out_rec.position
        :=per_qh_populate.get_position(asg_rec.position_id,p_effective_date);
      end if;
      out_rec.position_id                   :=asg_rec.position_id;
--
  hr_utility.set_location(l_proc,779);
--
      if asg_rec.job_id is not null then
        out_rec.job:=per_qh_populate.get_job(asg_rec.job_id);
      end if;
      out_rec.job_id                        :=asg_rec.job_id;
  --
    hr_utility.set_location(l_proc,780);
  --
      open csr_asg_status(asg_rec.assignment_status_type_id,asg_rec.business_group_id);
      fetch csr_asg_status into out_rec.assignment_status_type,out_rec.system_status;
      close csr_asg_status;
      out_rec.assignment_status_type_id     :=asg_rec.assignment_status_type_id;
  --
    hr_utility.set_location(l_proc,782);
  --
      if asg_rec.payroll_id is not null then
        out_rec.payroll:=
        per_qh_populate.get_payroll(asg_rec.payroll_id,p_effective_date);
      end if;
      out_rec.payroll_id                    :=asg_rec.payroll_id;
  --
    hr_utility.set_location(l_proc,785);
  --
      if asg_rec.location_id is not null then
        out_rec.location:=per_qh_populate.get_location(asg_rec.location_id);
        out_rec.location_address:=hr_general.hr_lookup_locations(asg_rec.location_id);
      end if;
      out_rec.location_id                   :=asg_rec.location_id;
  --
    hr_utility.set_location(l_proc,790);
  --
      if asg_rec.person_referred_by_id is not null then
      out_rec.person_referred_by:=
    per_qh_populate.get_full_name(asg_rec.person_referred_by_id,p_effective_date);
      end if;
      out_rec.person_referred_by_id         :=asg_rec.person_referred_by_id;
  --
    hr_utility.set_location(l_proc,800);
  --
      if asg_rec.supervisor_id is not null then
        out_rec.supervisor:=
        per_qh_populate.get_full_name(asg_rec.supervisor_id,p_effective_date);
      end if;
      out_rec.supervisor_id                 :=asg_rec.supervisor_id;
  --
    hr_utility.set_location(l_proc,805);
  --
      if asg_rec.supervisor_assignment_id is not null then
        out_rec.supervisor_assignment_number :=
        per_qh_populate.get_supervisor_assgn_number(
               asg_rec.supervisor_assignment_id,asg_rec.business_group_id);
      end if;
      out_rec.supervisor_assignment_id := asg_rec.supervisor_assignment_id;
  --
    hr_utility.set_location(l_proc,810);
  --
      if asg_rec.recruitment_activity_id is not null then
        open csr_rec_activity(asg_rec.recruitment_activity_id);
        fetch csr_rec_activity into out_rec.recruitment_activity;
        close csr_rec_activity;
      end if;
      out_rec.recruitment_activity_id       :=asg_rec.recruitment_activity_id;
  --
    hr_utility.set_location(l_proc,820);
  --
      if asg_rec.source_organization_id is not null then
        out_rec.source_organization
        :=per_qh_populate.get_organization(asg_rec.source_organization_id);
      end if;
      out_rec.source_organization_id        :=asg_rec.source_organization_id;
  --
    hr_utility.set_location(l_proc,830);
  --
      out_rec.organization
        :=per_qh_populate.get_organization(asg_rec.organization_id);
      out_rec.organization_id               :=asg_rec.organization_id;
  --
    hr_utility.set_location(l_proc,840);
  --
      if asg_rec.people_group_id is not null then
        open csr_pgp_rec(asg_rec.people_group_id);
        fetch csr_pgp_rec into pgp_rec;
        close csr_pgp_rec;
  --
    hr_utility.set_location(l_proc,850);
  --
        out_rec.pgp_segment1                :=pgp_rec.segment1;
        out_rec.pgp_segment2                :=pgp_rec.segment2;
        out_rec.pgp_segment3                :=pgp_rec.segment3;
        out_rec.pgp_segment4                :=pgp_rec.segment4;
        out_rec.pgp_segment5                :=pgp_rec.segment5;
        out_rec.pgp_segment6                :=pgp_rec.segment6;
        out_rec.pgp_segment7                :=pgp_rec.segment7;
        out_rec.pgp_segment8                :=pgp_rec.segment8;
        out_rec.pgp_segment9                :=pgp_rec.segment9;
        out_rec.pgp_segment10               :=pgp_rec.segment10;
        out_rec.pgp_segment11               :=pgp_rec.segment11;
        out_rec.pgp_segment12               :=pgp_rec.segment12;
        out_rec.pgp_segment13               :=pgp_rec.segment13;
        out_rec.pgp_segment14               :=pgp_rec.segment14;
        out_rec.pgp_segment15               :=pgp_rec.segment15;
        out_rec.pgp_segment16               :=pgp_rec.segment16;
        out_rec.pgp_segment17               :=pgp_rec.segment17;
        out_rec.pgp_segment18               :=pgp_rec.segment18;
        out_rec.pgp_segment19               :=pgp_rec.segment19;
        out_rec.pgp_segment20               :=pgp_rec.segment20;
        out_rec.pgp_segment21               :=pgp_rec.segment21;
        out_rec.pgp_segment22               :=pgp_rec.segment22;
        out_rec.pgp_segment23               :=pgp_rec.segment23;
        out_rec.pgp_segment24               :=pgp_rec.segment24;
        out_rec.pgp_segment25               :=pgp_rec.segment25;
        out_rec.pgp_segment26               :=pgp_rec.segment26;
        out_rec.pgp_segment27               :=pgp_rec.segment27;
        out_rec.pgp_segment28               :=pgp_rec.segment28;
        out_rec.pgp_segment29               :=pgp_rec.segment29;
        out_rec.pgp_segment30               :=pgp_rec.segment30;
      end if;
      out_rec.people_group_id               :=asg_rec.people_group_id;
  --
    hr_utility.set_location(l_proc,860);
  --
      if asg_rec.soft_coding_keyflex_id is not null then
        open csr_scl_rec(asg_rec.soft_coding_keyflex_id);
        fetch csr_scl_rec into scl_rec;
        close csr_scl_rec;
  --
    hr_utility.set_location(l_proc,870);
  --
        out_rec.scl_segment1                :=scl_rec.segment1;
        out_rec.scl_segment2                :=scl_rec.segment2;
        out_rec.scl_segment3                :=scl_rec.segment3;
        out_rec.scl_segment4                :=scl_rec.segment4;
        out_rec.scl_segment5                :=scl_rec.segment5;
        out_rec.scl_segment6                :=scl_rec.segment6;
        out_rec.scl_segment7                :=scl_rec.segment7;
        out_rec.scl_segment8                :=scl_rec.segment8;
        out_rec.scl_segment9                :=scl_rec.segment9;
        out_rec.scl_segment10               :=scl_rec.segment10;
        out_rec.scl_segment11               :=scl_rec.segment11;
        out_rec.scl_segment12               :=scl_rec.segment12;
        out_rec.scl_segment13               :=scl_rec.segment13;
        out_rec.scl_segment14               :=scl_rec.segment14;
        out_rec.scl_segment15               :=scl_rec.segment15;
        out_rec.scl_segment16               :=scl_rec.segment16;
        out_rec.scl_segment17               :=scl_rec.segment17;
        out_rec.scl_segment18               :=scl_rec.segment18;
        out_rec.scl_segment19               :=scl_rec.segment19;
        out_rec.scl_segment20               :=scl_rec.segment20;
        out_rec.scl_segment21               :=scl_rec.segment21;
        out_rec.scl_segment22               :=scl_rec.segment22;
        out_rec.scl_segment23               :=scl_rec.segment23;
        out_rec.scl_segment24               :=scl_rec.segment24;
        out_rec.scl_segment25               :=scl_rec.segment25;
        out_rec.scl_segment26               :=scl_rec.segment26;
        out_rec.scl_segment27               :=scl_rec.segment27;
        out_rec.scl_segment28               :=scl_rec.segment28;
        out_rec.scl_segment29               :=scl_rec.segment29;
        out_rec.scl_segment30               :=scl_rec.segment30;
      end if;
      out_rec.soft_coding_keyflex_id        :=asg_rec.soft_coding_keyflex_id;
  --
    hr_utility.set_location(l_proc,880);
  --
      if asg_rec.vacancy_id is not null then
        open csr_vacancy(asg_rec.vacancy_id);
        fetch csr_vacancy into out_rec.vacancy,out_rec.requisition;
        close csr_vacancy;
      end if;
      out_rec.vacancy_id                    :=asg_rec.vacancy_id;
  --
    hr_utility.set_location(l_proc,890);
  --
      if asg_rec.pay_basis_id is not null then
        open salary_basis(p_effective_date,asg_rec.pay_basis_id);
        fetch salary_basis into
         out_rec.salary_basis
        ,out_rec.pay_basis
        ,out_rec.currency_code
        ,l_uom;
        close salary_basis;
        if l_uom='M' then
          per_pay_proposals_populate.get_currency_format(out_rec.currency_code,out_rec.salary_format);
        else
          per_pay_proposals_populate.get_number_format(out_rec.salary_format);
        end if;
      end if;
      out_rec.pay_basis_id                  :=asg_rec.pay_basis_id;
      out_rec.pay_basis_meaning             :=hr_reports.get_lookup_meaning('PAY_BASIS',out_rec.pay_basis);
  --
    hr_utility.set_location(l_proc,900);
  --
      out_rec.assignment_sequence           :=asg_rec.assignment_sequence;
      out_rec.assignment_type               :=asg_rec.assignment_type;
      out_rec.asg_primary_flag              :=asg_rec.primary_flag;
      out_rec.assignment_number             :=asg_rec.assignment_number;
      out_rec.date_probation_end            :=asg_rec.date_probation_end;
      out_rec.default_code_comb_id          :=asg_rec.default_code_comb_id;
      --
      if asg_rec.assignment_type in ('E','A') then    -- fix for the bug 8727447
          out_rec.employment_category_meaning
             :=hr_reports.get_lookup_meaning('EMP_CAT',asg_rec.employment_category);
      elsif asg_rec.assignment_type = 'C' then
          out_rec.employment_category_meaning
             := hr_reports.get_lookup_meaning('CWK_ASG_CATEGORY',asg_rec.employment_category);
      end if;
      --
      out_rec.employment_category           :=asg_rec.employment_category;
      out_rec.employee_category_meaning     :=hr_reports.get_lookup_meaning('EMPLOYEE_CATG',asg_rec.employee_category);
      out_rec.employee_category             :=asg_rec.employee_category;
      out_rec.frequency_meaning             :=hr_reports.get_lookup_meaning('FREQUENCY',asg_rec.frequency);
      out_rec.frequency                     :=asg_rec.frequency;
      out_rec.normal_hours                  :=asg_rec.normal_hours;
      out_rec.probation_period              :=asg_rec.probation_period;
      out_rec.probation_unit_meaning        :=hr_reports.get_lookup_meaning('QUALIFYING_UNITS',asg_rec.probation_unit);
      out_rec.probation_unit                :=asg_rec.probation_unit;
      out_rec.notice_period                 :=asg_rec.notice_period;
      out_rec.notice_unit_meaning           :=hr_reports.get_lookup_meaning('QUALIFYING_UNITS',asg_rec.notice_period_uom);
      out_rec.notice_unit                   :=asg_rec.notice_period_uom;
      out_rec.set_of_books_id               :=asg_rec.set_of_books_id;
      if asg_rec.set_of_books_id is not null then
        open csr_sob(asg_rec.set_of_books_id);
        fetch csr_sob into out_rec.set_of_books_name, out_rec.gl_keyflex_struct;
        close csr_sob;
      end if;
      out_rec.billing_title                 :=asg_rec.title;
      out_rec.time_normal_finish            :=asg_rec.time_normal_finish;
      out_rec.time_normal_start             :=asg_rec.time_normal_start;
  --
    hr_utility.set_location(l_proc,910);
  --
  --CWK asg fields
      out_rec.projected_assignment_end      :=asg_rec.projected_assignment_end;
      out_rec.vendor_employee_number        :=asg_rec.vendor_employee_number;
      out_rec.vendor_assignment_number      :=asg_rec.vendor_assignment_number;
      if asg_rec.vendor_id is not null then
        open csr_vendor(asg_rec.vendor_id);
         fetch csr_vendor into out_rec.vendor_name;
        close csr_vendor;
      end if;
      out_rec.vendor_id                     :=asg_rec.vendor_id;
      out_rec.project_title                 :=asg_rec.project_title;
  --
      if asg_rec.vendor_site_id is not null then
        open csr_vendor_site(asg_rec.vendor_site_id);
          fetch csr_vendor_site into out_rec.vendor_site_code;
        close csr_vendor_site;
      end if;
      out_rec.vendor_site_id                :=asg_rec.vendor_site_id;
  --
      if asg_rec.po_header_id is not null then
        open csr_po_header(asg_rec.po_header_id);
          fetch csr_po_header into out_rec.po_header_num;
        close csr_po_header;
      end if;
      out_rec.po_header_id                  :=asg_rec.po_header_id;
  --
      if asg_rec.po_line_id is not null then
        open csr_po_line(asg_rec.po_line_id);
          fetch csr_po_line into out_rec.po_line_num;
        close csr_po_line;
      end if;
      out_rec.po_line_id                    :=asg_rec.po_line_id;
  --
    hr_utility.set_location(l_proc,915);
  --CWK asg rates
      if nvl(fnd_profile.value('PO_SERVICES_ENABLED'),'N') = 'Y' then
        fnd_message.set_name('PER','HR_PO_RATE_MESG');
  	out_rec.grade_rule_id              := l_rate_rec.grade_rule_id;
  	out_rec.rate_id                    := null;
  	out_rec.rate_name                  := null;
  	out_rec.rate_basis                 := substrb(fnd_message.get,1,30);
        out_rec.asg_rate_type_name         := null;
  	out_rec.rate_currency              := null;
  	out_rec.rate_currency_code         := null;
  	out_rec.rate_value                 := null;
  	out_rec.rate_effective_start_date  := null;
  	out_rec.rate_effective_end_date    := null;
  	out_rec.rate_object_version_number := null;
      else                                 --try to find the HR assignment rates
	open csr_asg_rates(p_assignment_id, p_effective_date);
	fetch csr_asg_rates into l_rate_rec;
	if csr_asg_rates%notfound then
	     hr_utility.set_location(l_proc,916);
	  out_rec.grade_rule_id              := null;
	  out_rec.rate_id                    := null;
	  out_rec.rate_name                  := null;
	  out_rec.rate_basis                 := null;
	  out_rec.asg_rate_type_name         := null;
	  out_rec.rate_currency              := null;
	  out_rec.rate_currency_code         := null;
	  out_rec.rate_value                 := null;
	  out_rec.rate_effective_start_date  := null;
	  out_rec.rate_effective_end_date    := null;
	  out_rec.rate_object_version_number := null;
	elsif csr_asg_rates%found then
	     hr_utility.set_location(l_proc,917);
	  out_rec.grade_rule_id              := l_rate_rec.grade_rule_id;
	  out_rec.rate_id                    := l_rate_rec.rate_id;
	  out_rec.rate_name                  := l_rate_rec.rate_name;
	  out_rec.rate_basis                 := l_rate_rec.rate_basis;
	  out_rec.asg_rate_type_name         := l_rate_rec.asg_rate_type_name;
	  out_rec.rate_currency              := l_rate_rec.rate_currency;
	  out_rec.rate_currency_code         := l_rate_rec.currency_code;
	  out_rec.rate_value                 := l_rate_rec.value;
	  out_rec.rate_effective_start_date  := l_rate_rec.effective_start_date;
	  out_rec.rate_effective_end_date    := l_rate_rec.effective_end_date;
	  out_rec.rate_object_version_number := l_rate_rec.object_version_number;
	  fetch csr_asg_rates into l_rate_rec;    --try a second fetch
	  if csr_asg_rates%notfound then
	    null;
	  elsif csr_asg_rates%found then
    --this means multiple rates exits. Further update processing will rely on setting
    --grade_rule_id but nothing else
	       hr_utility.set_location(l_proc,918);
	    fnd_message.set_name('PER','HR_MULTI_RATE_MESG');
	  out_rec.grade_rule_id              := l_rate_rec.grade_rule_id;
	  out_rec.rate_id                    := null;
	  out_rec.rate_name                  := null;
	  out_rec.rate_basis                 := substrb(fnd_message.get,1,30);
	  out_rec.asg_rate_type_name         := null;
	  out_rec.rate_currency              := null;
	  out_rec.rate_currency_code         := null;
	  out_rec.rate_value                 := null;
	  out_rec.rate_effective_start_date  := null;
	  out_rec.rate_effective_end_date    := null;
	  out_rec.rate_object_version_number := null;
	  end if;
	end if;
	close csr_asg_rates;
      end if;  --end check for PO_SERVICES_ENABLED
  --
    hr_utility.set_location(l_proc,919);
  --
      out_rec.ass_attribute_category        :=asg_rec.ass_attribute_category;
      out_rec.ass_attribute1                :=asg_rec.ass_attribute1;
      out_rec.ass_attribute2                :=asg_rec.ass_attribute2;
      out_rec.ass_attribute3                :=asg_rec.ass_attribute3;
      out_rec.ass_attribute4                :=asg_rec.ass_attribute4;
      out_rec.ass_attribute5                :=asg_rec.ass_attribute5;
      out_rec.ass_attribute6                :=asg_rec.ass_attribute6;
      out_rec.ass_attribute7                :=asg_rec.ass_attribute7;
      out_rec.ass_attribute8                :=asg_rec.ass_attribute8;
      out_rec.ass_attribute9                :=asg_rec.ass_attribute9;
      out_rec.ass_attribute10               :=asg_rec.ass_attribute10;
      out_rec.ass_attribute11               :=asg_rec.ass_attribute11;
      out_rec.ass_attribute12               :=asg_rec.ass_attribute12;
      out_rec.ass_attribute13               :=asg_rec.ass_attribute13;
      out_rec.ass_attribute14               :=asg_rec.ass_attribute14;
      out_rec.ass_attribute15               :=asg_rec.ass_attribute15;
      out_rec.ass_attribute16               :=asg_rec.ass_attribute16;
      out_rec.ass_attribute17               :=asg_rec.ass_attribute17;
      out_rec.ass_attribute18               :=asg_rec.ass_attribute18;
      out_rec.ass_attribute19               :=asg_rec.ass_attribute19;
      out_rec.ass_attribute20               :=asg_rec.ass_attribute20;
      out_rec.ass_attribute21               :=asg_rec.ass_attribute21;
      out_rec.ass_attribute22               :=asg_rec.ass_attribute22;
      out_rec.ass_attribute23               :=asg_rec.ass_attribute23;
      out_rec.ass_attribute24               :=asg_rec.ass_attribute24;
      out_rec.ass_attribute25               :=asg_rec.ass_attribute25;
      out_rec.ass_attribute26               :=asg_rec.ass_attribute26;
      out_rec.ass_attribute27               :=asg_rec.ass_attribute27;
      out_rec.ass_attribute28               :=asg_rec.ass_attribute28;
      out_rec.ass_attribute29               :=asg_rec.ass_attribute29;
      out_rec.ass_attribute30               :=asg_rec.ass_attribute30;
      out_rec.asg_object_version_number     :=asg_rec.object_version_number;
      out_rec.bargaining_unit_code_meaning  :=hr_reports.get_lookup_meaning('BARGAINING_UNIT_CODE',asg_rec.bargaining_unit_code);
      out_rec.bargaining_unit_code          :=asg_rec.bargaining_unit_code;
      out_rec.labour_union_member_flag      :=asg_rec.labour_union_member_flag;
      out_rec.hourly_salaried_meaning       :=hr_reports.get_lookup_meaning('HOURLY_SALARIED_CODE',asg_rec.hourly_salaried_code);
      out_rec.hourly_salaried_code          :=asg_rec.hourly_salaried_code;
  --
    hr_utility.set_location(l_proc,920);
  --
      if asg_rec.special_ceiling_step_id is not null then
        open csr_ceiling_step(asg_rec.special_ceiling_step_id,p_effective_date);
        fetch csr_ceiling_step into out_rec.special_ceiling_point, out_rec.special_ceiling_step;
        close csr_ceiling_step;
      end if;
      out_rec.special_ceiling_step_id       :=asg_rec.special_ceiling_step_id;
  --
    hr_utility.set_location(l_proc,930);
  --
  -- Bug# 4153433 Start Here
  --
      if asg_rec.assignment_type = 'E' then
         out_rec.change_reason_meaning         :=hr_reports.get_lookup_meaning('EMP_ASSIGN_REASON',asg_rec.change_reason);
      elsif asg_rec.assignment_type = 'A' then
         out_rec.change_reason_meaning         :=hr_reports.get_lookup_meaning('APL_ASSIGN_REASON',asg_rec.change_reason);
      elsif asg_rec.assignment_type = 'C' then
         out_rec.change_reason_meaning         :=hr_reports.get_lookup_meaning('CWK_ASSIGN_REASON',asg_rec.change_reason);
      end if;
  --
  --Bug# 4153433 End here
  --
      out_rec.change_reason                 :=asg_rec.change_reason;
      out_rec.internal_address_line         :=asg_rec.internal_address_line;
      out_rec.manager_flag                  :=asg_rec.manager_flag;
      out_rec.perf_review_period            :=asg_rec.perf_review_period;
      out_rec.perf_rev_period_freq_meaning  :=hr_reports.get_lookup_meaning('FREQUENCY',asg_rec.perf_review_period_frequency);
      out_rec.perf_review_period_frequency  :=asg_rec.perf_review_period_frequency;
      out_rec.sal_review_period             :=asg_rec.sal_review_period;
      out_rec.sal_rev_period_freq_meaning   :=hr_reports.get_lookup_meaning('FREQUENCY',asg_rec.sal_review_period_frequency);
      out_rec.sal_review_period_frequency   :=asg_rec.sal_review_period_frequency;
      out_rec.source_type_meaning           :=hr_reports.get_lookup_meaning('REC_TYPE',asg_rec.source_type);
      out_rec.source_type                   :=asg_rec.source_type;
  --
    hr_utility.set_location(l_proc,940);
  --
      if asg_rec.contract_id is not null then
        open csr_reference(asg_rec.contract_id,p_effective_date);
        fetch csr_reference into out_rec.contract;
        close csr_reference;
      end if;
      out_rec.contract_id                   :=asg_rec.contract_id;
  --
    hr_utility.set_location(l_proc,950);
  --
      if asg_rec.collective_agreement_id is not null then
        open csr_collective_agr(asg_rec.collective_agreement_id);
        fetch csr_collective_agr into out_rec.collective_agreement;
        close csr_collective_agr;
      end if;
      out_rec.collective_agreement_id 	 :=asg_rec.collective_agreement_id;
  --
    hr_utility.set_location(l_proc,960);
  --
      if asg_rec.cagr_id_flex_num is not null then
        open csr_cagr_flex_num(asg_rec.cagr_id_flex_num);
        fetch csr_cagr_flex_num into out_rec.cagr_id_flex_name;
        close csr_cagr_flex_num;
      end if;
      out_rec.cagr_id_flex_num	         :=asg_rec.cagr_id_flex_num;
  --
      out_rec.cagr_grade_def_id             :=asg_rec.cagr_grade_def_id;
  --
    hr_utility.set_location(l_proc,970);
  --
      if asg_rec.establishment_id is not null then
        out_rec.establishment
        :=per_qh_populate.get_organization(asg_rec.establishment_id);
      end if;
      out_rec.establishment_id	         :=asg_rec.establishment_id;
  --
    hr_utility.set_location(l_proc,980);
  --
--Bug 3063591 Start Here
      out_rec.work_at_home                 :=asg_rec.work_at_home;
--Bug 3063591 End Here
  --
    hr_utility.set_location(l_proc,985);
  --
      open csr_pay_proposal(p_assignment_id,p_effective_date);
      fetch csr_pay_proposal into pyp_rec;
      if csr_pay_proposal%found then
  --
    hr_utility.set_location(l_proc,990);
  --
        close csr_pay_proposal;
        out_rec.pay_proposal_id            :=pyp_rec.pay_proposal_id;
        out_rec.change_date                :=pyp_rec.change_date;
        out_rec.proposed_salary_n          :=pyp_rec.proposed_salary_n;
        out_rec.proposal_reason            :=pyp_rec.proposal_reason;
        out_rec.proposal_reason_meaning    :=
                hr_reports.get_lookup_meaning('PROPOSAL_REASON',pyp_rec.proposal_reason);
        out_rec.pyp_attribute_category     :=pyp_rec.attribute_category;
        out_rec.pyp_attribute1             :=pyp_rec.attribute1;
        out_rec.pyp_attribute2             :=pyp_rec.attribute2;
        out_rec.pyp_attribute3             :=pyp_rec.attribute3;
        out_rec.pyp_attribute4             :=pyp_rec.attribute4;
        out_rec.pyp_attribute5             :=pyp_rec.attribute5;
        out_rec.pyp_attribute6             :=pyp_rec.attribute6;
        out_rec.pyp_attribute7             :=pyp_rec.attribute7;
        out_rec.pyp_attribute8             :=pyp_rec.attribute8;
        out_rec.pyp_attribute9             :=pyp_rec.attribute9;
        out_rec.pyp_attribute10            :=pyp_rec.attribute10;
        out_rec.pyp_attribute11            :=pyp_rec.attribute11;
        out_rec.pyp_attribute12            :=pyp_rec.attribute12;
        out_rec.pyp_attribute13            :=pyp_rec.attribute13;
        out_rec.pyp_attribute14            :=pyp_rec.attribute14;
        out_rec.pyp_attribute15            :=pyp_rec.attribute15;
        out_rec.pyp_attribute16            :=pyp_rec.attribute16;
        out_rec.pyp_attribute17            :=pyp_rec.attribute17;
        out_rec.pyp_attribute18            :=pyp_rec.attribute18;
        out_rec.pyp_attribute19            :=pyp_rec.attribute19;
        out_rec.pyp_attribute20            :=pyp_rec.attribute20;
        out_rec.pyp_object_version_number  :=pyp_rec.object_version_number;
        out_rec.multiple_components        :=pyp_rec.multiple_components;
        out_rec.approved                   :=pyp_rec.approved;
      else
        close csr_pay_proposal;
      end if;
    end if; -- assignment found
  end if;  -- assignment_id is not null
--
      out_rec.person_type                :=hr_person_type_usage_info.get_user_person_type
                                           (p_effective_date => p_effective_date
                                           ,p_person_id      => p_person_id
                                           );
--
  per_qh_tax_query.tax_query
  (tax_effective_start_date => out_rec.tax_effective_start_date
  ,tax_effective_end_date   => out_rec.tax_effective_end_date
  ,tax_field1          => out_rec.tax_field1
  ,tax_field2          => out_rec.tax_field2
  ,tax_field3          => out_rec.tax_field3
  ,tax_field4          => out_rec.tax_field4
  ,tax_field5          => out_rec.tax_field5
  ,tax_field6          => out_rec.tax_field6
  ,tax_field7          => out_rec.tax_field7
  ,tax_field8          => out_rec.tax_field8
  ,tax_field9          => out_rec.tax_field9
  ,tax_field10         => out_rec.tax_field10
  ,tax_field11         => out_rec.tax_field11
  ,tax_field12         => out_rec.tax_field12
  ,tax_field13         => out_rec.tax_field13
  ,tax_field14         => out_rec.tax_field14
  ,tax_field15         => out_rec.tax_field15
  ,tax_field16         => out_rec.tax_field16
  ,tax_field17         => out_rec.tax_field17
  ,tax_field18         => out_rec.tax_field18
  ,tax_field19         => out_rec.tax_field19
  ,tax_field20         => out_rec.tax_field20
  ,tax_field21         => out_rec.tax_field21
  ,tax_field22         => out_rec.tax_field22
  ,tax_field23         => out_rec.tax_field23
  ,tax_field24         => out_rec.tax_field24
  ,tax_field25         => out_rec.tax_field25
  ,tax_field26         => out_rec.tax_field26
  ,tax_field27         => out_rec.tax_field27
  ,tax_field28         => out_rec.tax_field28
  ,tax_field29         => out_rec.tax_field29
  ,tax_field30         => out_rec.tax_field30
  ,tax_field31         => out_rec.tax_field31
  ,tax_field32         => out_rec.tax_field32
  ,tax_field33         => out_rec.tax_field33
  ,tax_field34         => out_rec.tax_field34
  ,tax_field35         => out_rec.tax_field35
  ,tax_field36         => out_rec.tax_field36
  ,tax_field37         => out_rec.tax_field37
  ,tax_field38         => out_rec.tax_field38
  ,tax_field39         => out_rec.tax_field39
  ,tax_field40         => out_rec.tax_field40
  ,tax_field41         => out_rec.tax_field41
  ,tax_field42         => out_rec.tax_field42
  ,tax_field43         => out_rec.tax_field43
  ,tax_field44         => out_rec.tax_field44
  ,tax_field45         => out_rec.tax_field45
  ,tax_field46         => out_rec.tax_field46
  ,tax_field47         => out_rec.tax_field47
  ,tax_field48         => out_rec.tax_field48
  ,tax_field49         => out_rec.tax_field49
  ,tax_field50         => out_rec.tax_field50
  ,tax_field51         => out_rec.tax_field51
  ,tax_field52         => out_rec.tax_field52
  ,tax_field53         => out_rec.tax_field53
  ,tax_field54         => out_rec.tax_field54
  ,tax_field55         => out_rec.tax_field55
  ,tax_field56         => out_rec.tax_field56
  ,tax_field57         => out_rec.tax_field57
  ,tax_field58         => out_rec.tax_field58
  ,tax_field59         => out_rec.tax_field59
  ,tax_field60         => out_rec.tax_field60
  ,tax_field61         => out_rec.tax_field61
  ,tax_field62         => out_rec.tax_field62
  ,tax_field63         => out_rec.tax_field63
  ,tax_field64         => out_rec.tax_field64
  ,tax_field65         => out_rec.tax_field65
  ,tax_field66         => out_rec.tax_field66
  ,tax_field67         => out_rec.tax_field67
  ,tax_field68         => out_rec.tax_field68
  ,tax_field69         => out_rec.tax_field69
  ,tax_field70         => out_rec.tax_field70
  ,tax_field71         => out_rec.tax_field71
  ,tax_field72         => out_rec.tax_field72
  ,tax_field73         => out_rec.tax_field73
  ,tax_field74         => out_rec.tax_field74
  ,tax_field75         => out_rec.tax_field75
  ,tax_field76         => out_rec.tax_field76
  ,tax_field77         => out_rec.tax_field77
  ,tax_field78         => out_rec.tax_field78
  ,tax_field79         => out_rec.tax_field79
  ,tax_field80         => out_rec.tax_field80
  ,tax_field81         => out_rec.tax_field81
  ,tax_field82         => out_rec.tax_field82
  ,tax_field83         => out_rec.tax_field83
  ,tax_field84         => out_rec.tax_field84
  ,tax_field85         => out_rec.tax_field85
  ,tax_field86         => out_rec.tax_field86
  ,tax_field87         => out_rec.tax_field87
  ,tax_field88         => out_rec.tax_field88
  ,tax_field89         => out_rec.tax_field89
  ,tax_field90         => out_rec.tax_field90
  ,tax_field91         => out_rec.tax_field91
  ,tax_field92         => out_rec.tax_field92
  ,tax_field93         => out_rec.tax_field93
  ,tax_field94         => out_rec.tax_field94
  ,tax_field95         => out_rec.tax_field95
  ,tax_field96         => out_rec.tax_field96
  ,tax_field97         => out_rec.tax_field97
  ,tax_field98         => out_rec.tax_field98
  ,tax_field99         => out_rec.tax_field99
  ,tax_field100        => out_rec.tax_field100
  ,tax_field101        => out_rec.tax_field101
  ,tax_field102        => out_rec.tax_field102
  ,tax_field103        => out_rec.tax_field103
  ,tax_field104        => out_rec.tax_field104
  ,tax_field105        => out_rec.tax_field105
  ,tax_field106        => out_rec.tax_field106
  ,tax_field107        => out_rec.tax_field107
  ,tax_field108        => out_rec.tax_field108
  ,tax_field109        => out_rec.tax_field109
  ,tax_field110        => out_rec.tax_field110
  ,tax_field111        => out_rec.tax_field111
  ,tax_field112        => out_rec.tax_field112
  ,tax_field113        => out_rec.tax_field113
  ,tax_field114        => out_rec.tax_field114
  ,tax_field115        => out_rec.tax_field115
  ,tax_field116        => out_rec.tax_field116
  ,tax_field117        => out_rec.tax_field117
  ,tax_field118        => out_rec.tax_field118
  ,tax_field119        => out_rec.tax_field119
  ,tax_field120        => out_rec.tax_field120
  ,tax_field121        => out_rec.tax_field121
  ,tax_field122        => out_rec.tax_field122
  ,tax_field123        => out_rec.tax_field123
  ,tax_field124        => out_rec.tax_field124
  ,tax_field125        => out_rec.tax_field125
  ,tax_field126        => out_rec.tax_field126
  ,tax_field127        => out_rec.tax_field127
  ,tax_field128        => out_rec.tax_field128
  ,tax_field129        => out_rec.tax_field129
  ,tax_field130        => out_rec.tax_field130
  ,tax_field131        => out_rec.tax_field131
  ,tax_field132        => out_rec.tax_field132
  ,tax_field133        => out_rec.tax_field133
  ,tax_field134        => out_rec.tax_field134
  ,tax_field135        => out_rec.tax_field135
  ,tax_field136        => out_rec.tax_field136
  ,tax_field137        => out_rec.tax_field137
  ,tax_field138        => out_rec.tax_field138
  ,tax_field139        => out_rec.tax_field139
  ,tax_field140        => out_rec.tax_field140
  ,tax_field141        => out_rec.tax_field141
  ,tax_field142        => out_rec.tax_field142
  ,tax_field143        => out_rec.tax_field143
  ,tax_field144        => out_rec.tax_field144
  ,tax_field145        => out_rec.tax_field145
  ,tax_field146        => out_rec.tax_field146
  ,tax_field147        => out_rec.tax_field147
  ,tax_field148        => out_rec.tax_field148
  ,tax_field149        => out_rec.tax_field149
  ,tax_field150        => out_rec.tax_field150
  ,tax_update_allowed  => out_rec.tax_update_allowed
  ,p_person_id         => p_person_id
  ,p_assignment_id     => p_assignment_id
  ,p_legislation_code  => l_legislation_code
  ,p_effective_date    => p_effective_date
  );
  --
  end if;
  hr_utility.set_location('Leaving: '||l_proc,1000);
--

end onerow;
--
procedure mntquery
(resultset                    IN OUT NOCOPY maintab
,p_person_id                  IN     number
,p_assignment_id              IN     number default null
,p_effective_date             IN     date
,p_template_name              IN     varchar2
,p_block_name                 IN     varchar2
,p_legislation_code           IN     varchar2
) is
  l_out_rec mainrec;
begin
               onerow(l_out_rec
                     ,p_person_id
                     ,p_assignment_id
                     ,p_effective_date
                     ,p_template_name
                     ,p_block_name
                     ,p_legislation_code
                     );
  resultset(1):=l_out_rec;
end mntquery;
--
end per_qh_maintain_query;

/
