--------------------------------------------------------
--  DDL for Package PER_QH_FIND_QUERY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_QH_FIND_QUERY" AUTHID CURRENT_USER as
/* $Header: peqhfndq.pkh 120.1 2005/12/29 05:34:28 rvarshne noship $ */

type findrec is RECORD
(person_id                     per_all_people_f.person_id%type
,business_group_name           per_business_groups.name%type
,per_effective_start_date      per_all_people_f.effective_start_date%type
,per_effective_end_date        per_all_people_f.effective_end_date%type
,person_type                   varchar2(240)
,system_person_type            per_person_types.system_person_type%type
,last_name                     per_all_people_f.last_name%type
,start_date                    per_all_people_f.start_date%type
,applicant_number              per_all_people_f.applicant_number%type
,background_chk_stat_meaning   hr_lookups.meaning%type
,background_date_check         per_all_people_f.background_date_check%type
,blood_type_meaning            hr_lookups.meaning%type
,corr_lang_meaning             hr_lookups.meaning%type
,date_employee_data_verified   per_all_people_f.date_employee_data_verified%type
,date_of_birth                 per_all_people_f.date_of_birth%type
,email_address                 per_all_people_f.email_address%type
,employee_number               per_all_people_f.employee_number%type
,expnse_chk_send_addr_meaning  hr_lookups.meaning%type
,first_name                    per_all_people_f.first_name%type
,per_fte_capacity              per_all_people_f.fte_capacity%type
,full_name                     per_all_people_f.full_name%type
--CWK
,npw_number                    per_all_people_f.npw_number%type
,project_title                 per_all_assignments_f.project_title%type
,vendor_employee_number        per_all_assignments_f.vendor_employee_number%type
,vendor_assignment_number      per_all_assignments_f.vendor_assignment_number%type
,vendor_name                   po_vendors.vendor_name%type
,vendor_site_code              po_vendor_sites_all.vendor_site_code%TYPE
,po_header_num                 po_headers_all.segment1%TYPE
,po_line_num                   po_lines_all.line_num%TYPE
--
,hold_applicant_date_until     per_all_people_f.hold_applicant_date_until%type
,honors                        per_all_people_f.honors%type
,internal_location             per_all_people_f.internal_location%type
,known_as                      per_all_people_f.known_as%type
,last_medical_test_by          per_all_people_f.last_medical_test_by%type
,last_medical_test_date        per_all_people_f.last_medical_test_date%type
,mailstop                      per_all_people_f.mailstop%type
,marital_status_meaning        hr_lookups.meaning%type
,middle_names                  per_all_people_f.middle_names%type
,nationality_meaning           hr_lookups.meaning%type
,national_identifier           per_all_people_f.national_identifier%type
,office_number                 per_all_people_f.office_number%type
,on_military_service_meaning   hr_lookups.meaning%type
,pre_name_adjunct              per_all_people_f.pre_name_adjunct%type
,previous_last_name            per_all_people_f.previous_last_name%type
,rehire_recommendation         per_all_people_f.rehire_recommendation%type
,resume_exists_meaning         hr_lookups.meaning%type
,resume_last_updated           per_all_people_f.resume_last_updated%type
-- Bug 3037019
,registered_disabled_flag      hr_lookups.meaning%type
,secnd_passport_exsts_meaning  hr_lookups.meaning%type
,sex_meaning                   hr_lookups.meaning%type
,student_status_meaning        hr_lookups.meaning%type
,suffix                        per_all_people_f.suffix%type
,title_meaning                 hr_lookups.meaning%type
,work_schedule_meaning         hr_lookups.meaning%type
,coord_ben_med_pln_no          per_all_people_f.coord_ben_med_pln_no%type
,cord_ben_no_cvg_flag_meaning  hr_lookups.meaning%type
,dpdnt_adoption_date           per_all_people_f.dpdnt_adoption_date%type
,dpdnt_vlntry_svc_flg_meaning  hr_lookups.meaning%type
,receipt_of_death_cert_date    per_all_people_f.receipt_of_death_cert_date%type
,uses_tobacco_meaning          hr_lookups.meaning%type
,benefit_group                 ben_benfts_grp.name%type
/*    These fields are no longer used because they may change
      context on a row by row basis, making them meaningless in a table

,attribute_category            per_all_people_f.attribute_category%type
,attribute1                    per_all_people_f.attribute1%type
,attribute1_v                  varchar2(150)
,attribute1_m                  varchar2(150)
,attribute2                    per_all_people_f.attribute2%type
,attribute2_v                  varchar2(150)
,attribute2_m                  varchar2(150)
,attribute3                    per_all_people_f.attribute3%type
,attribute3_v                  varchar2(150)
,attribute3_m                  varchar2(150)
,attribute4                    per_all_people_f.attribute4%type
,attribute4_v                  varchar2(150)
,attribute4_m                  varchar2(150)
,attribute5                    per_all_people_f.attribute5%type
,attribute5_v                  varchar2(150)
,attribute5_m                  varchar2(150)
,attribute6                    per_all_people_f.attribute6%type
,attribute6_v                  varchar2(150)
,attribute6_m                  varchar2(150)
,attribute7                    per_all_people_f.attribute7%type
,attribute7_v                  varchar2(150)
,attribute7_m                  varchar2(150)
,attribute8                    per_all_people_f.attribute8%type
,attribute8_v                  varchar2(150)
,attribute8_m                  varchar2(150)
,attribute9                    per_all_people_f.attribute9%type
,attribute9_v                  varchar2(150)
,attribute9_m                  varchar2(150)
,attribute10                   per_all_people_f.attribute10%type
,attribute10_v                 varchar2(150)
,attribute10_m                 varchar2(150)
,attribute11                   per_all_people_f.attribute11%type
,attribute11_v                 varchar2(150)
,attribute11_m                 varchar2(150)
,attribute12                   per_all_people_f.attribute12%type
,attribute12_v                 varchar2(150)
,attribute12_m                 varchar2(150)
,attribute13                   per_all_people_f.attribute13%type
,attribute13_v                 varchar2(150)
,attribute13_m                 varchar2(150)
,attribute14                   per_all_people_f.attribute14%type
,attribute14_v                 varchar2(150)
,attribute14_m                 varchar2(150)
,attribute15                   per_all_people_f.attribute15%type
,attribute15_v                 varchar2(150)
,attribute15_m                 varchar2(150)
,attribute16                   per_all_people_f.attribute16%type
,attribute16_v                 varchar2(150)
,attribute16_m                 varchar2(150)
,attribute17                   per_all_people_f.attribute17%type
,attribute17_v                 varchar2(150)
,attribute17_m                 varchar2(150)
,attribute18                   per_all_people_f.attribute18%type
,attribute18_v                 varchar2(150)
,attribute18_m                 varchar2(150)
,attribute19                   per_all_people_f.attribute19%type
,attribute19_v                 varchar2(150)
,attribute19_m                 varchar2(150)
,attribute20                   per_all_people_f.attribute20%type
,attribute20_v                 varchar2(150)
,attribute20_m                 varchar2(150)
,attribute21                   per_all_people_f.attribute21%type
,attribute21_v                 varchar2(150)
,attribute21_m                 varchar2(150)
,attribute22                   per_all_people_f.attribute22%type
,attribute22_v                 varchar2(150)
,attribute22_m                 varchar2(150)
,attribute23                   per_all_people_f.attribute23%type
,attribute23_v                 varchar2(150)
,attribute23_m                 varchar2(150)
,attribute24                   per_all_people_f.attribute24%type
,attribute24_v                 varchar2(150)
,attribute24_m                 varchar2(150)
,attribute25                   per_all_people_f.attribute25%type
,attribute25_v                 varchar2(150)
,attribute25_m                 varchar2(150)
,attribute26                   per_all_people_f.attribute26%type
,attribute26_v                 varchar2(150)
,attribute26_m                 varchar2(150)
,attribute27                   per_all_people_f.attribute27%type
,attribute27_v                 varchar2(150)
,attribute27_m                 varchar2(150)
,attribute28                   per_all_people_f.attribute28%type
,attribute28_v                 varchar2(150)
,attribute28_m                 varchar2(150)
,attribute29                   per_all_people_f.attribute29%type
,attribute29_v                 varchar2(150)
,attribute29_m                 varchar2(150)
,attribute30                   per_all_people_f.attribute30%type
,attribute30_v                 varchar2(150)
,attribute30_m                 varchar2(150)
*/
,per_information_category      per_all_people_f.per_information_category%type
,per_information1              per_all_people_f.attribute1%type
,per_information1_v            varchar2(150)
,per_information1_m            varchar2(150)
,per_information2              per_all_people_f.attribute2%type
,per_information2_v            varchar2(150)
,per_information2_m            varchar2(150)
,per_information3              per_all_people_f.attribute3%type
,per_information3_v            varchar2(150)
,per_information3_m            varchar2(150)
,per_information4              per_all_people_f.attribute4%type
,per_information4_v            varchar2(150)
,per_information4_m            varchar2(150)
,per_information5              per_all_people_f.attribute5%type
,per_information5_v            varchar2(150)
,per_information5_m            varchar2(150)
,per_information6              per_all_people_f.attribute6%type
,per_information6_v            varchar2(150)
,per_information6_m            varchar2(150)
,per_information7              per_all_people_f.attribute7%type
,per_information7_v            varchar2(150)
,per_information7_m            varchar2(150)
,per_information8              per_all_people_f.attribute8%type
,per_information8_v            varchar2(150)
,per_information8_m            varchar2(150)
,per_information9              per_all_people_f.attribute9%type
,per_information9_v            varchar2(150)
,per_information9_m            varchar2(150)
,per_information10             per_all_people_f.attribute10%type
,per_information10_v           varchar2(150)
,per_information10_m           varchar2(150)
,per_information11             per_all_people_f.attribute11%type
,per_information11_v           varchar2(150)
,per_information11_m           varchar2(150)
,per_information12             per_all_people_f.attribute12%type
,per_information12_v           varchar2(150)
,per_information12_m           varchar2(150)
,per_information13             per_all_people_f.attribute13%type
,per_information13_v           varchar2(150)
,per_information13_m           varchar2(150)
,per_information14             per_all_people_f.attribute14%type
,per_information14_v           varchar2(150)
,per_information14_m           varchar2(150)
,per_information15             per_all_people_f.attribute15%type
,per_information15_v           varchar2(150)
,per_information15_m           varchar2(150)
,per_information16             per_all_people_f.attribute16%type
,per_information16_v           varchar2(150)
,per_information16_m           varchar2(150)
,per_information17             per_all_people_f.attribute17%type
,per_information17_v           varchar2(150)
,per_information17_m           varchar2(150)
,per_information18             per_all_people_f.attribute18%type
,per_information18_v           varchar2(150)
,per_information18_m           varchar2(150)
,per_information19             per_all_people_f.attribute19%type
,per_information19_v           varchar2(150)
,per_information19_m           varchar2(150)
,per_information20             per_all_people_f.attribute20%type
,per_information20_v           varchar2(150)
,per_information20_m           varchar2(150)
,per_information21             per_all_people_f.attribute21%type
,per_information21_v           varchar2(150)
,per_information21_m           varchar2(150)
,per_information22             per_all_people_f.attribute22%type
,per_information22_v           varchar2(150)
,per_information22_m           varchar2(150)
,per_information23             per_all_people_f.attribute23%type
,per_information23_v           varchar2(150)
,per_information23_m           varchar2(150)
,per_information24             per_all_people_f.attribute24%type
,per_information24_v           varchar2(150)
,per_information24_m           varchar2(150)
,per_information25             per_all_people_f.attribute25%type
,per_information25_v           varchar2(150)
,per_information25_m           varchar2(150)
,per_information26             per_all_people_f.attribute26%type
,per_information26_v           varchar2(150)
,per_information26_m           varchar2(150)
,per_information27             per_all_people_f.attribute27%type
,per_information27_v           varchar2(150)
,per_information27_m           varchar2(150)
,per_information28             per_all_people_f.attribute28%type
,per_information28_v           varchar2(150)
,per_information28_m           varchar2(150)
,per_information29             per_all_people_f.attribute29%type
,per_information29_v           varchar2(150)
,per_information29_m           varchar2(150)
,per_information30             per_all_people_f.attribute30%type
,per_information30_v           varchar2(150)
,per_information30_m           varchar2(150)
,date_of_death                 per_all_people_f.date_of_death%type
,hire_date                     per_periods_of_service.date_start%type
,projected_hire_date           per_applications.projected_hire_date%type
,assignment_id                 per_all_assignments_f.assignment_id%type
,asg_effective_start_date      per_all_assignments_f.effective_start_date%type
,asg_effective_end_date        per_all_assignments_f.effective_end_date%type
,recruiter                     per_all_people_f.full_name%type
,grade                         per_grades.name%type
,grade_ladder                  ben_pgm_f.name%type
,position                      hr_all_positions_f.name%type
,job                           per_jobs.name%type
,assignment_status_type        per_assignment_status_types.user_status%type
,system_status                 per_assignment_status_types.per_system_status%type
,payroll                       pay_all_payrolls_f.payroll_name%type
,location                      hr_locations.location_code%type
,person_referred_by            per_all_people_f.full_name%type
,supervisor                    per_all_people_f.full_name%type
,supervisor_assignment_number  per_assignments_v.supervisor_assignment_number%type
,recruitment_activity          per_recruitment_activities.name%type
,source_organization           hr_all_organization_units.name%type
,organization                  hr_all_organization_units.name%type
,pgp_segment1                  pay_people_groups.segment1%type
,pgp_segment1_v                varchar2(150)
,pgp_segment1_m                varchar2(150)
,pgp_segment2                  pay_people_groups.segment2%type
,pgp_segment2_v                varchar2(150)
,pgp_segment2_m                varchar2(150)
,pgp_segment3                  pay_people_groups.segment3%type
,pgp_segment3_v                varchar2(150)
,pgp_segment3_m                varchar2(150)
,pgp_segment4                  pay_people_groups.segment4%type
,pgp_segment4_v                varchar2(150)
,pgp_segment4_m                varchar2(150)
,pgp_segment5                  pay_people_groups.segment5%type
,pgp_segment5_v                varchar2(150)
,pgp_segment5_m                varchar2(150)
,pgp_segment6                  pay_people_groups.segment6%type
,pgp_segment6_v                varchar2(150)
,pgp_segment6_m                varchar2(150)
,pgp_segment7                  pay_people_groups.segment7%type
,pgp_segment7_v                varchar2(150)
,pgp_segment7_m                varchar2(150)
,pgp_segment8                  pay_people_groups.segment8%type
,pgp_segment8_v                varchar2(150)
,pgp_segment8_m                varchar2(150)
,pgp_segment9                  pay_people_groups.segment9%type
,pgp_segment9_v                varchar2(150)
,pgp_segment9_m                varchar2(150)
,pgp_segment10                 pay_people_groups.segment10%type
,pgp_segment10_v               varchar2(150)
,pgp_segment10_m               varchar2(150)
,pgp_segment11                 pay_people_groups.segment11%type
,pgp_segment11_v               varchar2(150)
,pgp_segment11_m               varchar2(150)
,pgp_segment12                 pay_people_groups.segment12%type
,pgp_segment12_v               varchar2(150)
,pgp_segment12_m               varchar2(150)
,pgp_segment13                 pay_people_groups.segment13%type
,pgp_segment13_v               varchar2(150)
,pgp_segment13_m               varchar2(150)
,pgp_segment14                 pay_people_groups.segment14%type
,pgp_segment14_v               varchar2(150)
,pgp_segment14_m               varchar2(150)
,pgp_segment15                 pay_people_groups.segment15%type
,pgp_segment15_v               varchar2(150)
,pgp_segment15_m               varchar2(150)
,pgp_segment16                 pay_people_groups.segment16%type
,pgp_segment16_v               varchar2(150)
,pgp_segment16_m               varchar2(150)
,pgp_segment17                 pay_people_groups.segment17%type
,pgp_segment17_v               varchar2(150)
,pgp_segment17_m               varchar2(150)
,pgp_segment18                 pay_people_groups.segment18%type
,pgp_segment18_v               varchar2(150)
,pgp_segment18_m               varchar2(150)
,pgp_segment19                 pay_people_groups.segment19%type
,pgp_segment19_v               varchar2(150)
,pgp_segment19_m               varchar2(150)
,pgp_segment20                 pay_people_groups.segment20%type
,pgp_segment20_v               varchar2(150)
,pgp_segment20_m               varchar2(150)
,pgp_segment21                 pay_people_groups.segment21%type
,pgp_segment21_v               varchar2(150)
,pgp_segment21_m               varchar2(150)
,pgp_segment22                 pay_people_groups.segment22%type
,pgp_segment22_v               varchar2(150)
,pgp_segment22_m               varchar2(150)
,pgp_segment23                 pay_people_groups.segment23%type
,pgp_segment23_v               varchar2(150)
,pgp_segment23_m               varchar2(150)
,pgp_segment24                 pay_people_groups.segment24%type
,pgp_segment24_v               varchar2(150)
,pgp_segment24_m               varchar2(150)
,pgp_segment25                 pay_people_groups.segment25%type
,pgp_segment25_v               varchar2(150)
,pgp_segment25_m               varchar2(150)
,pgp_segment26                 pay_people_groups.segment26%type
,pgp_segment26_v               varchar2(150)
,pgp_segment26_m               varchar2(150)
,pgp_segment27                 pay_people_groups.segment27%type
,pgp_segment27_v               varchar2(150)
,pgp_segment27_m               varchar2(150)
,pgp_segment28                 pay_people_groups.segment28%type
,pgp_segment28_v               varchar2(150)
,pgp_segment28_m               varchar2(150)
,pgp_segment29                 pay_people_groups.segment29%type
,pgp_segment29_v               varchar2(150)
,pgp_segment29_m               varchar2(150)
,pgp_segment30                 pay_people_groups.segment30%type
,pgp_segment30_v               varchar2(150)
,pgp_segment30_m               varchar2(150)
,people_group_id               per_all_assignments_f.people_group_id%type
,scl_segment1                  hr_soft_coding_keyflex.segment1%type
,scl_segment1_v                varchar2(150)
,scl_segment1_m                varchar2(150)
,scl_segment2                  hr_soft_coding_keyflex.segment2%type
,scl_segment2_v                varchar2(150)
,scl_segment2_m                varchar2(150)
,scl_segment3                  hr_soft_coding_keyflex.segment3%type
,scl_segment3_v                varchar2(150)
,scl_segment3_m                varchar2(150)
,scl_segment4                  hr_soft_coding_keyflex.segment4%type
,scl_segment4_v                varchar2(150)
,scl_segment4_m                varchar2(150)
,scl_segment5                  hr_soft_coding_keyflex.segment5%type
,scl_segment5_v                varchar2(150)
,scl_segment5_m                varchar2(150)
,scl_segment6                  hr_soft_coding_keyflex.segment6%type
,scl_segment6_v                varchar2(150)
,scl_segment6_m                varchar2(150)
,scl_segment7                  hr_soft_coding_keyflex.segment7%type
,scl_segment7_v                varchar2(150)
,scl_segment7_m                varchar2(150)
,scl_segment8                  hr_soft_coding_keyflex.segment8%type
,scl_segment8_v                varchar2(150)
,scl_segment8_m                varchar2(150)
,scl_segment9                  hr_soft_coding_keyflex.segment9%type
,scl_segment9_v                varchar2(150)
,scl_segment9_m                varchar2(150)
,scl_segment10                 hr_soft_coding_keyflex.segment10%type
,scl_segment10_v               varchar2(150)
,scl_segment10_m               varchar2(150)
,scl_segment11                 hr_soft_coding_keyflex.segment11%type
,scl_segment11_v               varchar2(150)
,scl_segment11_m               varchar2(150)
,scl_segment12                 hr_soft_coding_keyflex.segment12%type
,scl_segment12_v               varchar2(150)
,scl_segment12_m               varchar2(150)
,scl_segment13                 hr_soft_coding_keyflex.segment13%type
,scl_segment13_v               varchar2(150)
,scl_segment13_m               varchar2(150)
,scl_segment14                 hr_soft_coding_keyflex.segment14%type
,scl_segment14_v               varchar2(150)
,scl_segment14_m               varchar2(150)
,scl_segment15                 hr_soft_coding_keyflex.segment15%type
,scl_segment15_v               varchar2(150)
,scl_segment15_m               varchar2(150)
,scl_segment16                 hr_soft_coding_keyflex.segment16%type
,scl_segment16_v               varchar2(150)
,scl_segment16_m               varchar2(150)
,scl_segment17                 hr_soft_coding_keyflex.segment17%type
,scl_segment17_v               varchar2(150)
,scl_segment17_m               varchar2(150)
,scl_segment18                 hr_soft_coding_keyflex.segment18%type
,scl_segment18_v               varchar2(150)
,scl_segment18_m               varchar2(150)
,scl_segment19                 hr_soft_coding_keyflex.segment19%type
,scl_segment19_v               varchar2(150)
,scl_segment19_m               varchar2(150)
,scl_segment20                 hr_soft_coding_keyflex.segment20%type
,scl_segment20_v               varchar2(150)
,scl_segment20_m               varchar2(150)
,scl_segment21                 hr_soft_coding_keyflex.segment21%type
,scl_segment21_v               varchar2(150)
,scl_segment21_m               varchar2(150)
,scl_segment22                 hr_soft_coding_keyflex.segment22%type
,scl_segment22_v               varchar2(150)
,scl_segment22_m               varchar2(150)
,scl_segment23                 hr_soft_coding_keyflex.segment23%type
,scl_segment23_v               varchar2(150)
,scl_segment23_m               varchar2(150)
,scl_segment24                 hr_soft_coding_keyflex.segment24%type
,scl_segment24_v               varchar2(150)
,scl_segment24_m               varchar2(150)
,scl_segment25                 hr_soft_coding_keyflex.segment25%type
,scl_segment25_v               varchar2(150)
,scl_segment25_m               varchar2(150)
,scl_segment26                 hr_soft_coding_keyflex.segment26%type
,scl_segment26_v               varchar2(150)
,scl_segment26_m               varchar2(150)
,scl_segment27                 hr_soft_coding_keyflex.segment27%type
,scl_segment27_v               varchar2(150)
,scl_segment27_m               varchar2(150)
,scl_segment28                 hr_soft_coding_keyflex.segment28%type
,scl_segment28_v               varchar2(150)
,scl_segment28_m               varchar2(150)
,scl_segment29                 hr_soft_coding_keyflex.segment29%type
,scl_segment29_v               varchar2(150)
,scl_segment29_m               varchar2(150)
,scl_segment30                 hr_soft_coding_keyflex.segment30%type
,scl_segment30_v               varchar2(150)
,scl_segment30_m               varchar2(150)
,soft_coding_keyflex_id        per_all_assignments_f.soft_coding_keyflex_id%type
,vacancy                       per_vacancies.name%type
,requisition                   per_requisitions.name%type default null
,salary_basis                  per_pay_bases.name%type
,pay_basis                     per_pay_bases.pay_basis%type
,assignment_sequence           per_all_assignments_f.assignment_sequence%type
,assignment_type               per_all_assignments_f.assignment_type%type
,asg_primary_flag              per_all_assignments_f.primary_flag%type
,assignment_number             per_all_assignments_f.assignment_number%type
,date_probation_end            per_all_assignments_f.date_probation_end%type
,default_code_comb_id          per_all_assignments_f.default_code_comb_id%type
,employment_category_meaning   hr_lookups.meaning%type
,frequency_meaning             hr_lookups.meaning%type
,normal_hours                  per_all_assignments_f.normal_hours%type
,probation_period              per_all_assignments_f.probation_period%type
,probation_unit_meaning        hr_lookups.meaning%type
,time_normal_finish            per_all_assignments_f.time_normal_finish%type
,time_normal_start             per_all_assignments_f.time_normal_start%type
/*    These fields are no longer used because they may change
      context on a row by row basis, making them meaningless in a table

,ass_attribute_category        per_all_assignments_f.ass_attribute_category%type
,ass_attribute1                per_all_assignments_f.ass_attribute1%type
,ass_attribute1_v              varchar2(150)
,ass_attribute1_m              varchar2(150)
,ass_attribute2                per_all_assignments_f.ass_attribute2%type
,ass_attribute2_v              varchar2(150)
,ass_attribute2_m              varchar2(150)
,ass_attribute3                per_all_assignments_f.ass_attribute3%type
,ass_attribute3_v              varchar2(150)
,ass_attribute3_m              varchar2(150)
,ass_attribute4                per_all_assignments_f.ass_attribute4%type
,ass_attribute4_v              varchar2(150)
,ass_attribute4_m              varchar2(150)
,ass_attribute5                per_all_assignments_f.ass_attribute5%type
,ass_attribute5_v              varchar2(150)
,ass_attribute5_m              varchar2(150)
,ass_attribute6                per_all_assignments_f.ass_attribute6%type
,ass_attribute6_v              varchar2(150)
,ass_attribute6_m              varchar2(150)
,ass_attribute7                per_all_assignments_f.ass_attribute7%type
,ass_attribute7_v              varchar2(150)
,ass_attribute7_m              varchar2(150)
,ass_attribute8                per_all_assignments_f.ass_attribute8%type
,ass_attribute8_v              varchar2(150)
,ass_attribute8_m              varchar2(150)
,ass_attribute9                per_all_assignments_f.ass_attribute9%type
,ass_attribute9_v              varchar2(150)
,ass_attribute9_m              varchar2(150)
,ass_attribute10               per_all_assignments_f.ass_attribute10%type
,ass_attribute10_v             varchar2(150)
,ass_attribute10_m             varchar2(150)
,ass_attribute11               per_all_assignments_f.ass_attribute11%type
,ass_attribute11_v             varchar2(150)
,ass_attribute11_m             varchar2(150)
,ass_attribute12               per_all_assignments_f.ass_attribute12%type
,ass_attribute12_v             varchar2(150)
,ass_attribute12_m             varchar2(150)
,ass_attribute13               per_all_assignments_f.ass_attribute13%type
,ass_attribute13_v             varchar2(150)
,ass_attribute13_m             varchar2(150)
,ass_attribute14               per_all_assignments_f.ass_attribute14%type
,ass_attribute14_v             varchar2(150)
,ass_attribute14_m             varchar2(150)
,ass_attribute15               per_all_assignments_f.ass_attribute15%type
,ass_attribute15_v             varchar2(150)
,ass_attribute15_m             varchar2(150)
,ass_attribute16               per_all_assignments_f.ass_attribute16%type
,ass_attribute16_v             varchar2(150)
,ass_attribute16_m             varchar2(150)
,ass_attribute17               per_all_assignments_f.ass_attribute17%type
,ass_attribute17_v             varchar2(150)
,ass_attribute17_m             varchar2(150)
,ass_attribute18               per_all_assignments_f.ass_attribute18%type
,ass_attribute18_v             varchar2(150)
,ass_attribute18_m             varchar2(150)
,ass_attribute19               per_all_assignments_f.ass_attribute19%type
,ass_attribute19_v             varchar2(150)
,ass_attribute19_m             varchar2(150)
,ass_attribute20               per_all_assignments_f.ass_attribute20%type
,ass_attribute20_v             varchar2(150)
,ass_attribute20_m             varchar2(150)
,ass_attribute21               per_all_assignments_f.ass_attribute21%type
,ass_attribute21_v             varchar2(150)
,ass_attribute21_m             varchar2(150)
,ass_attribute22               per_all_assignments_f.ass_attribute22%type
,ass_attribute22_v             varchar2(150)
,ass_attribute22_m             varchar2(150)
,ass_attribute23               per_all_assignments_f.ass_attribute23%type
,ass_attribute23_v             varchar2(150)
,ass_attribute23_m             varchar2(150)
,ass_attribute24               per_all_assignments_f.ass_attribute24%type
,ass_attribute24_v             varchar2(150)
,ass_attribute24_m             varchar2(150)
,ass_attribute25               per_all_assignments_f.ass_attribute25%type
,ass_attribute25_v             varchar2(150)
,ass_attribute25_m             varchar2(150)
,ass_attribute26               per_all_assignments_f.ass_attribute26%type
,ass_attribute26_v             varchar2(150)
,ass_attribute26_m             varchar2(150)
,ass_attribute27               per_all_assignments_f.ass_attribute27%type
,ass_attribute27_v             varchar2(150)
,ass_attribute27_m             varchar2(150)
,ass_attribute28               per_all_assignments_f.ass_attribute28%type
,ass_attribute28_v             varchar2(150)
,ass_attribute28_m             varchar2(150)
,ass_attribute29               per_all_assignments_f.ass_attribute29%type
,ass_attribute29_v             varchar2(150)
,ass_attribute29_m             varchar2(150)
,ass_attribute30               per_all_assignments_f.ass_attribute30%type
,ass_attribute30_v             varchar2(150)
,ass_attribute30_m             varchar2(150)
*/
,bargaining_unit_code_meaning  hr_lookups.meaning%type
,labour_union_member_flag      per_all_assignments_f.labour_union_member_flag%type
,hourly_salaried_meaning       hr_lookups.meaning%type
,special_ceiling_step          number
,special_ceiling_point         per_spinal_points.spinal_point%type
,change_reason_meaning         hr_lookups.meaning%type
,internal_address_line         per_all_assignments_f.internal_address_line%type
,manager_flag                  per_all_assignments_f.manager_flag%type
,perf_review_period            per_all_assignments_f.perf_review_period%type
,perf_rev_period_freq_meaning  hr_lookups.meaning%type
,sal_review_period             per_all_assignments_f.sal_review_period%type
,sal_rev_period_freq_meaning   hr_lookups.meaning%type
,source_type_meaning           hr_lookups.meaning%type
,contract                      per_contracts_f.reference%type
,collective_agreement          per_collective_agreements.name%type
,cagr_id_flex_name             fnd_id_flex_structures_v.id_flex_structure_name%type
,cagr_grade                    varchar2(1)
,establishment                 hr_leg_establishments_v.name%type);

type findtab is table of findrec
index by binary_integer;

procedure findquery(resultset IN OUT NOCOPY findtab
,p_effective_date              date
,business_group_id             per_all_people_f.business_group_id%type
,business_group_name           per_business_groups.name%type default null
,person_id                     per_all_people_f.person_id%type default null
,person_type                   per_person_types.user_person_type%type default null
,system_person_type            per_person_types.system_person_type%type  default null
,person_type_id                per_all_people_f.person_type_id%type default null
,last_name                     per_all_people_f.last_name%type default null
,start_date                    per_all_people_f.start_date%type default null
,hire_date                     per_periods_of_service.date_start%type default null
,applicant_number              per_all_people_f.applicant_number%type default null
,date_of_birth                 per_all_people_f.date_of_birth%type default null
,email_address                 per_all_people_f.email_address%type default null
,employee_number               per_all_people_f.employee_number%type default null
--CWK
,npw_number                    per_all_people_f.npw_number%type default null
,project_title                 per_all_assignments_f.project_title%type default null
,vendor_id                     per_all_assignments_f.vendor_id%type default null
,vendor_name                   po_vendors.vendor_name%type default null
,vendor_employee_number        per_all_assignments_f.vendor_employee_number%type default null
,vendor_assignment_number      per_all_assignments_f.vendor_assignment_number%type default null
,vendor_site_code              po_vendor_sites_all.vendor_site_code%TYPE default null
,vendor_site_id                po_vendor_sites_all.vendor_site_id%TYPE default null
,po_header_num                 po_headers_all.segment1%TYPE default null
,po_header_id                  po_headers_all.po_header_id%TYPE default null
,po_line_num                   po_lines_all.line_num%TYPE default null
,po_line_id                    po_lines_all.po_line_id%TYPE default null
--
,first_name                    per_all_people_f.first_name%type default null
,full_name                     per_all_people_f.full_name%type default null
,title                         per_all_people_f.title%type
,middle_names                  per_all_people_f.middle_names%type
,nationality_meaning           hr_lookups.meaning%type default null
,nationality                   per_all_people_f.nationality%type default null
,national_identifier           per_all_people_f.national_identifier%type default null
-- Bug 3037019
,registered_disabled_flag      hr_lookups.meaning%type default null
,registered_disabled           per_all_people_f.registered_disabled_flag%type default null
,sex_meaning                   hr_lookups.meaning%type default null
,sex                           per_all_people_f.sex%type default null
,benefit_group                 ben_benfts_grp.name%type default null
,benefit_group_id              per_all_people_f.benefit_group_id%type default null
,grade                         per_grades.name%type default null
,grade_id                      per_all_assignments_f.grade_id%type default null
,grade_ladder                  ben_pgm_f.name%type default null
,grade_ladder_pgm_id           per_all_assignments_f.grade_ladder_pgm_id%type default null
,position                      hr_all_positions_f.name%type default null
,position_id                   per_all_assignments_f.position_id%type default null
,job                           per_jobs.name%type default null
,job_id                        per_all_assignments_f.job_id%type default null
,assignment_status_type        per_assignment_status_types.user_status%type default null
,assignment_status_type_id     per_all_assignments_f.assignment_status_type_id%type default null
,payroll                       pay_all_payrolls_f.payroll_name%type default null
,payroll_id                    per_all_assignments_f.payroll_id%type default null
,location                      hr_locations.location_code%type default null
,location_id                   per_all_assignments_f.location_id%type default null
,supervisor                    per_all_people_f.full_name%type default null
,supervisor_id                 per_all_assignments_f.supervisor_id%type default null
,supervisor_assignment_number  per_assignments_v.supervisor_assignment_number%type default null
,supervisor_assignment_id      per_all_assignments_f.supervisor_assignment_id%type default null
,recruitment_activity          per_recruitment_activities.name%type default null
,recruitment_activity_id       per_all_assignments_f.recruitment_activity_id%type default null
,organization                  hr_all_organization_units.name%type default null
,organization_id               per_all_assignments_f.organization_id%type default null
,people_group                  pay_people_groups.group_name%type default null
,people_group_id               per_all_assignments_f.people_group_id%type default null
,vacancy                       per_vacancies.name%type default null
,vacancy_id                    per_all_assignments_f.vacancy_id%type default null
,requisition                   per_requisitions.name%type default null
,requisition_id                per_requisitions.requisition_id%type default null
,salary_basis                  per_pay_bases.name%type default null
,pay_basis_id                  per_all_assignments_f.pay_basis_id%type default null
,bargaining_unit_code_meaning  hr_lookups.meaning%type default null
,bargaining_unit_code          per_all_assignments_f.bargaining_unit_code%type default null
,employment_category_meaning   hr_lookups.meaning%type default null
,employment_category           per_all_assignments_f.employment_category%type default null
,establishment                 hr_leg_establishments_v.name%type default null
,establishment_id              hr_leg_establishments_v.organization_id%type default null
,projected_hire_date           per_applications.projected_hire_date%type default null
,secure                        varchar2 default null
,field1_name                   varchar2 default null
,field1_condition_code         varchar2 default null
,field1_value                  varchar2 default null
,field2_name                   varchar2 default null
,field2_condition_code         varchar2 default null
,field2_value                  varchar2 default null
,field3_name                   varchar2 default null
,field3_condition_code         varchar2 default null
,field3_value                  varchar2 default null
,field4_name                   varchar2 default null
,field4_condition_code         varchar2 default null
,field4_value                  varchar2 default null
,field5_name                   varchar2 default null
,field5_condition_code         varchar2 default null
,field5_value                  varchar2 default null
,p_fetch_details               boolean  default true
,p_customized_restriction_id   number   default null
,p_employees_allowed           boolean  default false
,p_applicants_allowed          boolean  default false
,p_cwk_allowed                 boolean  default false
,select_stmt               out nocopy varchar2);


procedure findsave(
 query_id                      in     number
,business_group_id             in     per_all_people_f.business_group_id%type
,business_group_name           in     per_business_groups.name%type
,person_id                     in     per_all_people_f.person_id%type default null
,person_type                   in     per_person_types.user_person_type%type default null
,system_person_type            in     per_person_types.system_person_type%type  default null
,person_type_id                in     per_all_people_f.person_type_id%type default null
,last_name                     in     per_all_people_f.last_name%type default null
,start_date                    in     per_all_people_f.start_date%type default null
,hire_date                     in     per_periods_of_service.date_start%type default null
,applicant_number              in     per_all_people_f.applicant_number%type default null
,date_of_birth                 in     per_all_people_f.date_of_birth%type default null
,email_address                 in     per_all_people_f.email_address%type default null
,employee_number               in     per_all_people_f.employee_number%type default null
--CWK
,npw_number                    in     per_all_people_f.npw_number%type default null
,project_title                 in     per_all_assignments_f.project_title%type default null
,vendor_id                     in     per_all_assignments_f.vendor_id%type default null
,vendor_name                   in     po_vendors.vendor_name%type default null
,vendor_employee_number        in  per_all_assignments_f.vendor_employee_number%type default null
,vendor_assignment_number      in  per_all_assignments_f.vendor_assignment_number%type default null
,vendor_site_code              in  po_vendor_sites_all.vendor_site_code%TYPE default null
,vendor_site_id                in  po_vendor_sites_all.vendor_site_id%TYPE default null
,po_header_num                 in  po_headers_all.segment1%TYPE default null
,po_header_id                  in  po_headers_all.po_header_id%TYPE default null
,po_line_num                   in  po_lines_all.line_num%TYPE default null
,po_line_id                    in  po_lines_all.po_line_id%TYPE default null
--
,first_name                    in     per_all_people_f.first_name%type default null
,full_name                     in     per_all_people_f.full_name%type default null
,title                         per_all_people_f.title%type
,middle_names                  per_all_people_f.middle_names%type
,nationality_meaning           in     hr_lookups.meaning%type default null
,nationality                   in     per_all_people_f.nationality%type default null
,national_identifier           in     per_all_people_f.national_identifier%type default null
-- Bug 3037019
,registered_disabled_flag      in     hr_lookups.meaning%type default null
,registered_disabled           in     per_all_people_f.registered_disabled_flag%type default null
,sex_meaning                   in     hr_lookups.meaning%type default null
,sex                           in     per_all_people_f.sex%type default null
,benefit_group                 in     ben_benfts_grp.name%type default null
,benefit_group_id              in     per_all_people_f.benefit_group_id%type default null
,grade                         in     per_grades.name%type default null
,grade_id                      in     per_all_assignments_f.grade_id%type default null
,grade_ladder                  in     ben_pgm_f.name%type default null
,grade_ladder_pgm_id           in     per_all_assignments_f.grade_ladder_pgm_id%type default null
,position                      in     hr_all_positions_f.name%type default null
,position_id                   in     per_all_assignments_f.position_id%type default null
,job                           in     per_jobs.name%type default null
,job_id                        in     per_all_assignments_f.job_id%type default null
,assignment_status_type        in     per_assignment_status_types.user_status%type default null
,assignment_status_type_id     in     per_all_assignments_f.assignment_status_type_id%type default null
,payroll                       in     pay_all_payrolls_f.payroll_name%type default null
,payroll_id                    in     per_all_assignments_f.payroll_id%type default null
,location                      in     hr_locations.location_code%type default null
,location_id                   in     per_all_assignments_f.location_id%type default null
,supervisor                    in     per_all_people_f.full_name%type default null
,supervisor_id                 in     per_all_assignments_f.supervisor_id%type default null
,supervisor_assignment_number  in     per_assignments_v.supervisor_assignment_number%type default null
,supervisor_assignment_id      in     per_all_assignments_f.supervisor_assignment_id%type default null
,recruitment_activity          in     per_recruitment_activities.name%type default null
,recruitment_activity_id       in     per_all_assignments_f.recruitment_activity_id%type default null
,organization                  in     hr_all_organization_units.name%type default null
,organization_id               in     per_all_assignments_f.organization_id%type default null
,people_group                  in     pay_people_groups.group_name%type default null
,people_group_id               in     per_all_assignments_f.people_group_id%type default null
,vacancy                       in     per_vacancies.name%type default null
,vacancy_id                    in     per_all_assignments_f.vacancy_id%type default null
,requisition                   in     per_requisitions.name%type default null
,requisition_id                in     per_requisitions.requisition_id%type default null
,salary_basis                  in     per_pay_bases.name%type default null
,pay_basis_id                  in     per_all_assignments_f.pay_basis_id%type default null
,bargaining_unit_code_meaning  in     hr_lookups.meaning%type default null
,bargaining_unit_code          in     per_all_assignments_f.bargaining_unit_code%type default null
,employment_category_meaning   in     hr_lookups.meaning%type default null
,employment_category           in     per_all_assignments_f.employment_category%type default null
,establishment                 in     hr_leg_establishments_v.name%type default null
,establishment_id              in     hr_leg_establishments_v.organization_id%type default null
,projected_hire_date           in     per_applications.projected_hire_date%type default null
,secure                        in     varchar2 default null
,field1_name                   in     varchar2 default null
,field1_condition_code         in     varchar2 default null
,field1_value                  in     varchar2 default null
,field2_name                   in     varchar2 default null
,field2_condition_code         in     varchar2 default null
,field2_value                  in     varchar2 default null
,field3_name                   in     varchar2 default null
,field3_condition_code         in     varchar2 default null
,field3_value                  in     varchar2 default null
,field4_name                   in     varchar2 default null
,field4_condition_code         in     varchar2 default null
,field4_value                  in     varchar2 default null
,field5_name                   in     varchar2 default null
,field5_condition_code         in     varchar2 default null
,field5_value                  in     varchar2 default null
);

procedure findretrieve
(p_query_id                  in     number
,p_effective_date            in     date
,p_customized_restriction_id in     number   default null
,p_employees_allowed         in     boolean  default false
,p_applicants_allowed        in     boolean  default false
,p_cwk_allowed               in     boolean  default false
,p_people_tab                   out nocopy findtab
);

end per_qh_find_query;

 

/
