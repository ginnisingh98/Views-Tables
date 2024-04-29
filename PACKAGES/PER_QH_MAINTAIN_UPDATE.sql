--------------------------------------------------------
--  DDL for Package PER_QH_MAINTAIN_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_QH_MAINTAIN_UPDATE" AUTHID CURRENT_USER AS
/* $Header: peqhmnti.pkh 120.4.12010000.2 2009/07/10 11:38:51 varanjan ship $ */

-- Fix For Bug 8246722 Starts--

p_qh_organization_id per_all_assignments_f.organization_id%TYPE default NULL;

-- Fix For Bug 8246722 Ends--

PROCEDURE insert_maintain_data
(p_effective_date               IN     DATE
,p_person_id                       OUT NOCOPY per_all_people_f.person_id%TYPE
,p_business_group_id            IN     per_all_people_f.business_group_id%TYPE
,p_legislation_code             IN     VARCHAR2
,p_per_effective_start_date     IN OUT NOCOPY per_all_people_f.effective_start_date%TYPE
,p_per_effective_end_date       IN OUT NOCOPY per_all_people_f.effective_end_date%TYPE
,p_per_validation_start_date       OUT NOCOPY DATE
,p_per_validation_end_date         OUT NOCOPY DATE
,p_person_type                  IN     per_person_types.user_person_type%TYPE
,p_system_person_type           IN     per_person_types.system_person_type%TYPE
,p_person_type_id               IN     per_all_people_f.person_type_id%TYPE
,p_last_name                    IN     per_all_people_f.last_name%TYPE
,p_start_date                   IN     per_all_people_f.start_date%TYPE
,p_applicant_number             IN OUT NOCOPY per_all_people_f.applicant_number%TYPE
,p_background_check_status      IN     per_all_people_f.background_check_status%TYPE
,p_background_date_check        IN     per_all_people_f.background_date_check%TYPE
,p_blood_type                   IN     per_all_people_f.blood_type%TYPE
,p_correspondence_language      IN     per_all_people_f.correspondence_language%TYPE
,p_current_applicant_flag       IN     per_all_people_f.current_applicant_flag%TYPE
,p_current_emp_or_apl_flag      IN     per_all_people_f.current_emp_or_apl_flag%TYPE
,p_current_employee_flag        IN     per_all_people_f.current_employee_flag%TYPE
,p_hire_date                    IN OUT NOCOPY per_periods_of_service.date_start%TYPE    -- Bug 3975241
--CWK
,p_current_npw_flag             IN     per_all_people_f.current_npw_flag%TYPE
,p_npw_number                   IN OUT NOCOPY per_all_people_f.npw_number%TYPE
,p_placement_date_start         IN OUT NOCOPY per_all_assignments_f.period_of_placement_date_start%TYPE -- Bug 4287925
,p_projected_assignment_end      IN    per_all_assignments_f.projected_assignment_end%TYPE
,p_pdp_object_version_number       OUT NOCOPY per_periods_of_placement.object_version_number%TYPE
,p_vendor_employee_number       IN     per_all_assignments_f.vendor_employee_number%TYPE
,p_vendor_assignment_number     IN     per_all_assignments_f.vendor_assignment_number%TYPE
,p_vendor_id                    IN     per_all_assignments_f.vendor_id%TYPE
,p_vendor_site_id               IN     per_all_assignments_f.vendor_site_id%TYPE
,p_po_header_id                 IN     per_all_assignments_f.po_header_id%TYPE
,p_po_line_id                   IN     per_all_assignments_f.po_line_id%TYPE
,p_project_title                IN     per_all_assignments_f.project_title%TYPE
,p_grade_rule_id                   OUT NOCOPY pay_grade_rules_f.grade_rule_id%TYPE
,p_rate_id                      IN     pay_grade_rules_f.rate_id%TYPE
,p_rate_currency_code           IN     pay_grade_rules_f.currency_code%TYPE
,p_rate_value                   IN     pay_grade_rules_f.value%TYPE
,p_rate_effective_start_date       OUT NOCOPY pay_grade_rules_f.effective_start_date%TYPE
,p_rate_effective_end_date         OUT NOCOPY pay_grade_rules_f.effective_end_date%TYPE
,p_rate_object_version_number      OUT NOCOPY pay_grade_rules_f.object_version_number%TYPE
--
,p_date_employee_data_verified  IN     per_all_people_f.date_employee_data_verified%TYPE
,p_date_of_birth                IN     per_all_people_f.date_of_birth%TYPE
,p_email_address                IN     per_all_people_f.email_address%TYPE
,p_employee_number              IN OUT NOCOPY per_all_people_f.employee_number%TYPE
,p_expense_check_send_to_addres IN     per_all_people_f.expense_check_send_to_address%TYPE
,p_first_name                   IN     per_all_people_f.first_name%TYPE
,p_per_fte_capacity             IN     per_all_people_f.fte_capacity%TYPE
,p_full_name                       OUT NOCOPY per_all_people_f.full_name%TYPE
,p_hold_applicant_date_until    IN     per_all_people_f.hold_applicant_date_until%TYPE
,p_honors                       IN     per_all_people_f.honors%TYPE
,p_internal_location            IN     per_all_people_f.internal_location%TYPE
,p_known_as                     IN     per_all_people_f.known_as%TYPE
,p_last_medical_test_by         IN     per_all_people_f.last_medical_test_by%TYPE
,p_last_medical_test_date       IN     per_all_people_f.last_medical_test_date%TYPE
,p_mailstop                     IN     per_all_people_f.mailstop%TYPE
,p_marital_status               IN     per_all_people_f.marital_status%TYPE
,p_middle_names                 IN     per_all_people_f.middle_names%TYPE
,p_nationality                  IN     per_all_people_f.nationality%TYPE
,p_national_identifier          IN     per_all_people_f.national_identifier%TYPE
,p_office_number                IN     per_all_people_f.office_number%TYPE
,p_on_military_service          IN     per_all_people_f.on_military_service%TYPE
,p_pre_name_adjunct             IN     per_all_people_f.pre_name_adjunct%TYPE
,p_previous_last_name           IN     per_all_people_f.previous_last_name%TYPE
,p_rehire_recommendation        IN     per_all_people_f.rehire_recommendation%TYPE
,p_rehire_reason                IN     per_all_people_f.rehire_reason%TYPE
,p_resume_exists                IN     per_all_people_f.resume_exists%TYPE
,p_resume_last_updated          IN     per_all_people_f.resume_last_updated%TYPE
,p_registered_disabled_flag     IN     per_all_people_f.registered_disabled_flag%TYPE
,p_second_passport_exists       IN     per_all_people_f.second_passport_exists%TYPE
,p_sex                          IN     per_all_people_f.sex%TYPE
,p_student_status               IN     per_all_people_f.student_status%TYPE
,p_suffix                       IN     per_all_people_f.suffix%TYPE
,p_title                        IN     per_all_people_f.title%TYPE
,p_work_schedule                IN     per_all_people_f.work_schedule%TYPE
,p_coord_ben_med_pln_no         IN     per_all_people_f.coord_ben_med_pln_no%TYPE
,p_coord_ben_no_cvg_flag        IN     per_all_people_f.coord_ben_no_cvg_flag%TYPE
,p_dpdnt_adoption_date          IN     per_all_people_f.dpdnt_adoption_date%TYPE
,p_dpdnt_vlntry_svce_flag       IN     per_all_people_f.dpdnt_vlntry_svce_flag%TYPE
,p_receipt_of_death_cert_date   IN     per_all_people_f.receipt_of_death_cert_date%TYPE
,p_uses_tobacco_flag            IN     per_all_people_f.uses_tobacco_flag%TYPE
,p_benefit_group_id             IN     per_all_people_f.benefit_group_id%TYPE
,p_attribute_category           IN     per_all_people_f.attribute_category%TYPE
,p_attribute1                   IN     per_all_people_f.attribute1%TYPE
,p_attribute2                   IN     per_all_people_f.attribute2%TYPE
,p_attribute3                   IN     per_all_people_f.attribute3%TYPE
,p_attribute4                   IN     per_all_people_f.attribute4%TYPE
,p_attribute5                   IN     per_all_people_f.attribute5%TYPE
,p_attribute6                   IN     per_all_people_f.attribute6%TYPE
,p_attribute7                   IN     per_all_people_f.attribute7%TYPE
,p_attribute8                   IN     per_all_people_f.attribute8%TYPE
,p_attribute9                   IN     per_all_people_f.attribute9%TYPE
,p_attribute10                  IN     per_all_people_f.attribute10%TYPE
,p_attribute11                  IN     per_all_people_f.attribute11%TYPE
,p_attribute12                  IN     per_all_people_f.attribute12%TYPE
,p_attribute13                  IN     per_all_people_f.attribute13%TYPE
,p_attribute14                  IN     per_all_people_f.attribute14%TYPE
,p_attribute15                  IN     per_all_people_f.attribute15%TYPE
,p_attribute16                  IN     per_all_people_f.attribute16%TYPE
,p_attribute17                  IN     per_all_people_f.attribute17%TYPE
,p_attribute18                  IN     per_all_people_f.attribute18%TYPE
,p_attribute19                  IN     per_all_people_f.attribute19%TYPE
,p_attribute20                  IN     per_all_people_f.attribute20%TYPE
,p_attribute21                  IN     per_all_people_f.attribute21%TYPE
,p_attribute22                  IN     per_all_people_f.attribute22%TYPE
,p_attribute23                  IN     per_all_people_f.attribute23%TYPE
,p_attribute24                  IN     per_all_people_f.attribute24%TYPE
,p_attribute25                  IN     per_all_people_f.attribute25%TYPE
,p_attribute26                  IN     per_all_people_f.attribute26%TYPE
,p_attribute27                  IN     per_all_people_f.attribute27%TYPE
,p_attribute28                  IN     per_all_people_f.attribute28%TYPE
,p_attribute29                  IN     per_all_people_f.attribute29%TYPE
,p_attribute30                  IN     per_all_people_f.attribute30%TYPE
,p_per_information_category     IN     per_all_people_f.per_information_category%TYPE
,p_per_information1             IN     per_all_people_f.attribute1%TYPE
,p_per_information2             IN     per_all_people_f.attribute2%TYPE
,p_per_information3             IN     per_all_people_f.attribute3%TYPE
,p_per_information4             IN     per_all_people_f.attribute4%TYPE
,p_per_information5             IN     per_all_people_f.attribute5%TYPE
,p_per_information6             IN     per_all_people_f.attribute6%TYPE
,p_per_information7             IN     per_all_people_f.attribute7%TYPE
,p_per_information8             IN     per_all_people_f.attribute8%TYPE
,p_per_information9             IN     per_all_people_f.attribute9%TYPE
,p_per_information10            IN     per_all_people_f.attribute10%TYPE
,p_per_information11            IN     per_all_people_f.attribute11%TYPE
,p_per_information12            IN     per_all_people_f.attribute12%TYPE
,p_per_information13            IN     per_all_people_f.attribute13%TYPE
,p_per_information14            IN     per_all_people_f.attribute14%TYPE
,p_per_information15            IN     per_all_people_f.attribute15%TYPE
,p_per_information16            IN     per_all_people_f.attribute16%TYPE
,p_per_information17            IN     per_all_people_f.attribute17%TYPE
,p_per_information18            IN     per_all_people_f.attribute18%TYPE
,p_per_information19            IN     per_all_people_f.attribute19%TYPE
,p_per_information20            IN     per_all_people_f.attribute20%TYPE
,p_per_information21            IN     per_all_people_f.attribute21%TYPE
,p_per_information22            IN     per_all_people_f.attribute22%TYPE
,p_per_information23            IN     per_all_people_f.attribute23%TYPE
,p_per_information24            IN     per_all_people_f.attribute24%TYPE
,p_per_information25            IN     per_all_people_f.attribute25%TYPE
,p_per_information26            IN     per_all_people_f.attribute26%TYPE
,p_per_information27            IN     per_all_people_f.attribute27%TYPE
,p_per_information28            IN     per_all_people_f.attribute28%TYPE
,p_per_information29            IN     per_all_people_f.attribute29%TYPE
,p_per_information30            IN     per_all_people_f.attribute30%TYPE
,p_date_of_death                IN     per_all_people_f.date_of_death%TYPE
,p_original_date_of_hire        IN     per_all_people_f.original_date_of_hire%TYPE
,p_town_of_birth                IN     per_all_people_f.town_of_birth%TYPE
,p_region_of_birth              IN     per_all_people_f.region_of_birth%TYPE
,p_country_of_birth             IN     per_all_people_f.country_of_birth%TYPE
,p_party_id                     IN     per_all_people_f.party_id%TYPE default null
,p_fast_path_employee           IN     per_all_people_f.fast_path_employee%TYPE default null
,p_rehire_authorizor            IN     per_all_people_f.rehire_authorizor%TYPE default null
,p_per_object_version_number       OUT NOCOPY per_all_people_f.object_version_number%TYPE
,p_assignment_id                   OUT NOCOPY per_all_assignments_f.assignment_id%TYPE
,p_asg_effective_start_date     IN OUT NOCOPY per_all_assignments_f.effective_start_date%TYPE
,p_asg_effective_end_date       IN OUT NOCOPY per_all_assignments_f.effective_end_date%TYPE
,p_asg_validation_start_date       OUT NOCOPY DATE
,p_asg_validation_end_date         OUT NOCOPY DATE
,p_recruiter_id                 IN     per_all_assignments_f.recruiter_id%TYPE
,p_grade_id                     IN     per_all_assignments_f.grade_id%TYPE
,p_grade_ladder_pgm_id          IN     per_all_assignments_f.grade_ladder_pgm_id%TYPE
,p_position_id                  IN     per_all_assignments_f.position_id%TYPE
,p_job_id                       IN     per_all_assignments_f.job_id%TYPE
,p_assignment_status_type_id    IN     per_all_assignments_f.assignment_status_type_id%TYPE
,p_system_status                IN     per_assignment_status_types.per_system_status%TYPE
,p_payroll_id                   IN     per_all_assignments_f.payroll_id%TYPE
,p_location_id                  IN     per_all_assignments_f.location_id%TYPE
,p_person_referred_by_id        IN     per_all_assignments_f.person_referred_by_id%TYPE
,p_supervisor_id                IN     per_all_assignments_f.supervisor_id%TYPE
,p_supervisor_assignment_id     IN     per_all_assignments_f.supervisor_assignment_id%TYPE
,p_recruitment_activity_id      IN     per_all_assignments_f.recruitment_activity_id%TYPE
,p_source_organization_id       IN     per_all_assignments_f.source_organization_id%TYPE
,p_organization_id              IN     per_all_assignments_f.organization_id%TYPE
,p_pgp_segment1                 IN     pay_people_groups.segment1%TYPE
,p_pgp_segment2                 IN     pay_people_groups.segment2%TYPE
,p_pgp_segment3                 IN     pay_people_groups.segment3%TYPE
,p_pgp_segment4                 IN     pay_people_groups.segment4%TYPE
,p_pgp_segment5                 IN     pay_people_groups.segment5%TYPE
,p_pgp_segment6                 IN     pay_people_groups.segment6%TYPE
,p_pgp_segment7                 IN     pay_people_groups.segment7%TYPE
,p_pgp_segment8                 IN     pay_people_groups.segment8%TYPE
,p_pgp_segment9                 IN     pay_people_groups.segment9%TYPE
,p_pgp_segment10                IN     pay_people_groups.segment10%TYPE
,p_pgp_segment11                IN     pay_people_groups.segment11%TYPE
,p_pgp_segment12                IN     pay_people_groups.segment12%TYPE
,p_pgp_segment13                IN     pay_people_groups.segment13%TYPE
,p_pgp_segment14                IN     pay_people_groups.segment14%TYPE
,p_pgp_segment15                IN     pay_people_groups.segment15%TYPE
,p_pgp_segment16                IN     pay_people_groups.segment16%TYPE
,p_pgp_segment17                IN     pay_people_groups.segment17%TYPE
,p_pgp_segment18                IN     pay_people_groups.segment18%TYPE
,p_pgp_segment19                IN     pay_people_groups.segment19%TYPE
,p_pgp_segment20                IN     pay_people_groups.segment20%TYPE
,p_pgp_segment21                IN     pay_people_groups.segment21%TYPE
,p_pgp_segment22                IN     pay_people_groups.segment22%TYPE
,p_pgp_segment23                IN     pay_people_groups.segment23%TYPE
,p_pgp_segment24                IN     pay_people_groups.segment24%TYPE
,p_pgp_segment25                IN     pay_people_groups.segment25%TYPE
,p_pgp_segment26                IN     pay_people_groups.segment26%TYPE
,p_pgp_segment27                IN     pay_people_groups.segment27%TYPE
,p_pgp_segment28                IN     pay_people_groups.segment28%TYPE
,p_pgp_segment29                IN     pay_people_groups.segment29%TYPE
,p_pgp_segment30                IN     pay_people_groups.segment30%TYPE
,p_people_group_id                 OUT NOCOPY per_all_assignments_f.people_group_id%TYPE
,p_scl_segment1                 IN     hr_soft_coding_keyflex.segment1%TYPE
,p_scl_segment2                 IN     hr_soft_coding_keyflex.segment2%TYPE
,p_scl_segment3                 IN     hr_soft_coding_keyflex.segment3%TYPE
,p_scl_segment4                 IN     hr_soft_coding_keyflex.segment4%TYPE
,p_scl_segment5                 IN     hr_soft_coding_keyflex.segment5%TYPE
,p_scl_segment6                 IN     hr_soft_coding_keyflex.segment6%TYPE
,p_scl_segment7                 IN     hr_soft_coding_keyflex.segment7%TYPE
,p_scl_segment8                 IN     hr_soft_coding_keyflex.segment8%TYPE
,p_scl_segment9                 IN     hr_soft_coding_keyflex.segment9%TYPE
,p_scl_segment10                IN     hr_soft_coding_keyflex.segment10%TYPE
,p_scl_segment11                IN     hr_soft_coding_keyflex.segment11%TYPE
,p_scl_segment12                IN     hr_soft_coding_keyflex.segment12%TYPE
,p_scl_segment13                IN     hr_soft_coding_keyflex.segment13%TYPE
,p_scl_segment14                IN     hr_soft_coding_keyflex.segment14%TYPE
,p_scl_segment15                IN     hr_soft_coding_keyflex.segment15%TYPE
,p_scl_segment16                IN     hr_soft_coding_keyflex.segment16%TYPE
,p_scl_segment17                IN     hr_soft_coding_keyflex.segment17%TYPE
,p_scl_segment18                IN     hr_soft_coding_keyflex.segment18%TYPE
,p_scl_segment19                IN     hr_soft_coding_keyflex.segment19%TYPE
,p_scl_segment20                IN     hr_soft_coding_keyflex.segment20%TYPE
,p_scl_segment21                IN     hr_soft_coding_keyflex.segment21%TYPE
,p_scl_segment22                IN     hr_soft_coding_keyflex.segment22%TYPE
,p_scl_segment23                IN     hr_soft_coding_keyflex.segment23%TYPE
,p_scl_segment24                IN     hr_soft_coding_keyflex.segment24%TYPE
,p_scl_segment25                IN     hr_soft_coding_keyflex.segment25%TYPE
,p_scl_segment26                IN     hr_soft_coding_keyflex.segment26%TYPE
,p_scl_segment27                IN     hr_soft_coding_keyflex.segment27%TYPE
,p_scl_segment28                IN     hr_soft_coding_keyflex.segment28%TYPE
,p_scl_segment29                IN     hr_soft_coding_keyflex.segment29%TYPE
,p_scl_segment30                IN     hr_soft_coding_keyflex.segment30%TYPE
,p_soft_coding_keyflex_id          OUT NOCOPY per_all_assignments_f.soft_coding_keyflex_id%TYPE
,p_vacancy_id                   IN     per_all_assignments_f.vacancy_id%TYPE
,p_pay_basis_id                 IN     per_all_assignments_f.pay_basis_id%TYPE
,p_assignment_sequence             OUT NOCOPY per_all_assignments_f.assignment_sequence%TYPE
,p_assignment_type              IN     per_all_assignments_f.assignment_type%TYPE
,p_asg_primary_flag             IN     per_all_assignments_f.primary_flag%TYPE
,p_assignment_number               OUT NOCOPY per_all_assignments_f.assignment_number%TYPE
,p_date_probation_end           IN     per_all_assignments_f.date_probation_end%TYPE
,p_default_code_comb_id         IN     per_all_assignments_f.default_code_comb_id%TYPE
,p_employment_category          IN     per_all_assignments_f.employment_category%TYPE
,p_employee_category            IN     per_all_assignments_f.employee_category%TYPE
,p_frequency                    IN     per_all_assignments_f.frequency%TYPE
,p_normal_hours                 IN     per_all_assignments_f.normal_hours%TYPE
,p_period_of_service_id         IN OUT NOCOPY per_all_assignments_f.period_of_service_id%TYPE
,p_probation_period             IN     per_all_assignments_f.probation_period%TYPE
,p_probation_unit               IN     per_all_assignments_f.probation_unit%TYPE
,p_notice_period                IN     per_all_assignments_f.notice_period%TYPE
,p_notice_unit                  IN     per_all_assignments_f.notice_period_uom%TYPE
--
,p_set_of_books_id              IN     per_all_assignments_f.set_of_books_id%TYPE
,p_billing_title                IN     per_all_assignments_f.title%type
--
,p_time_normal_finish           IN     per_all_assignments_f.time_normal_finish%TYPE
,p_time_normal_start            IN     per_all_assignments_f.time_normal_start%TYPE
,p_ass_attribute_category       IN     per_all_assignments_f.ass_attribute_category%TYPE
,p_ass_attribute1               IN     per_all_assignments_f.ass_attribute1%TYPE
,p_ass_attribute2               IN     per_all_assignments_f.ass_attribute2%TYPE
,p_ass_attribute3               IN     per_all_assignments_f.ass_attribute3%TYPE
,p_ass_attribute4               IN     per_all_assignments_f.ass_attribute4%TYPE
,p_ass_attribute5               IN     per_all_assignments_f.ass_attribute5%TYPE
,p_ass_attribute6               IN     per_all_assignments_f.ass_attribute6%TYPE
,p_ass_attribute7               IN     per_all_assignments_f.ass_attribute7%TYPE
,p_ass_attribute8               IN     per_all_assignments_f.ass_attribute8%TYPE
,p_ass_attribute9               IN     per_all_assignments_f.ass_attribute9%TYPE
,p_ass_attribute10              IN     per_all_assignments_f.ass_attribute10%TYPE
,p_ass_attribute11              IN     per_all_assignments_f.ass_attribute11%TYPE
,p_ass_attribute12              IN     per_all_assignments_f.ass_attribute12%TYPE
,p_ass_attribute13              IN     per_all_assignments_f.ass_attribute13%TYPE
,p_ass_attribute14              IN     per_all_assignments_f.ass_attribute14%TYPE
,p_ass_attribute15              IN     per_all_assignments_f.ass_attribute15%TYPE
,p_ass_attribute16              IN     per_all_assignments_f.ass_attribute16%TYPE
,p_ass_attribute17              IN     per_all_assignments_f.ass_attribute17%TYPE
,p_ass_attribute18              IN     per_all_assignments_f.ass_attribute18%TYPE
,p_ass_attribute19              IN     per_all_assignments_f.ass_attribute19%TYPE
,p_ass_attribute20              IN     per_all_assignments_f.ass_attribute20%TYPE
,p_ass_attribute21              IN     per_all_assignments_f.ass_attribute21%TYPE
,p_ass_attribute22              IN     per_all_assignments_f.ass_attribute22%TYPE
,p_ass_attribute23              IN     per_all_assignments_f.ass_attribute23%TYPE
,p_ass_attribute24              IN     per_all_assignments_f.ass_attribute24%TYPE
,p_ass_attribute25              IN     per_all_assignments_f.ass_attribute25%TYPE
,p_ass_attribute26              IN     per_all_assignments_f.ass_attribute26%TYPE
,p_ass_attribute27              IN     per_all_assignments_f.ass_attribute27%TYPE
,p_ass_attribute28              IN     per_all_assignments_f.ass_attribute28%TYPE
,p_ass_attribute29              IN     per_all_assignments_f.ass_attribute29%TYPE
,p_ass_attribute30              IN     per_all_assignments_f.ass_attribute30%TYPE
,p_asg_object_version_number       OUT NOCOPY per_all_assignments_f.object_version_number%TYPE
,p_bargaining_unit_code         IN     per_all_assignments_f.bargaining_unit_code%TYPE
,p_labour_union_member_flag     IN     per_all_assignments_f.labour_union_member_flag%TYPE
,p_hourly_salaried_code         IN     per_all_assignments_f.hourly_salaried_code%TYPE
,p_special_ceiling_step_id      IN OUT NOCOPY per_all_assignments_f.special_ceiling_step_id%TYPE
,p_change_reason                IN     per_all_assignments_f.change_reason%TYPE
,p_internal_address_line        IN     per_all_assignments_f.internal_address_line%TYPE
,p_manager_flag                 IN     per_all_assignments_f.manager_flag%TYPE
,p_perf_review_period           IN     per_all_assignments_f.perf_review_period%TYPE
,p_perf_review_period_frequency IN     per_all_assignments_f.perf_review_period_frequency%TYPE
,p_sal_review_period            IN     per_all_assignments_f.sal_review_period%TYPE
,p_sal_review_period_frequency  IN     per_all_assignments_f.sal_review_period_frequency%TYPE
,p_source_type                  IN     per_all_assignments_f.source_type%TYPE
,p_contract_id                  IN     per_all_assignments_f.contract_id%TYPE
,p_collective_agreement_id      IN     per_all_assignments_f.collective_agreement_id%TYPE
,p_cagr_id_flex_num             IN OUT NOCOPY per_all_assignments_f.cagr_id_flex_num%TYPE
,p_cagr_grade_def_id            IN OUT NOCOPY per_all_assignments_f.cagr_grade_def_id%TYPE
,p_establishment_id             IN     per_all_assignments_f.establishment_id%TYPE
--Bug 3063591 Start Here
,p_work_at_home                 IN     per_all_assignments_f.work_at_home%TYPE default null
--Bug 3063591 End Here
,p_application_id                  OUT NOCOPY per_applications.application_id%TYPE
-- Bug 3900299 Starts Here
,p_app_date_received            IN OUT NOCOPY per_applications.date_received%TYPE
-- Bug 3900299 Ends Here
,p_projected_hire_date          IN     per_applications.projected_hire_date%TYPE
,p_appl_attribute_category      IN     per_applications.appl_attribute_category%TYPE
,p_appl_attribute1              IN     per_applications.appl_attribute1%TYPE
,p_appl_attribute2              IN     per_applications.appl_attribute2%TYPE
,p_appl_attribute3              IN     per_applications.appl_attribute3%TYPE
,p_appl_attribute4              IN     per_applications.appl_attribute4%TYPE
,p_appl_attribute5              IN     per_applications.appl_attribute5%TYPE
,p_appl_attribute6              IN     per_applications.appl_attribute6%TYPE
,p_appl_attribute7              IN     per_applications.appl_attribute7%TYPE
,p_appl_attribute8              IN     per_applications.appl_attribute8%TYPE
,p_appl_attribute9              IN     per_applications.appl_attribute9%TYPE
,p_appl_attribute10             IN     per_applications.appl_attribute10%TYPE
,p_appl_attribute11             IN     per_applications.appl_attribute11%TYPE
,p_appl_attribute12             IN     per_applications.appl_attribute12%TYPE
,p_appl_attribute13             IN     per_applications.appl_attribute13%TYPE
,p_appl_attribute14             IN     per_applications.appl_attribute14%TYPE
,p_appl_attribute15             IN     per_applications.appl_attribute15%TYPE
,p_appl_attribute16             IN     per_applications.appl_attribute16%TYPE
,p_appl_attribute17             IN     per_applications.appl_attribute17%TYPE
,p_appl_attribute18             IN     per_applications.appl_attribute18%TYPE
,p_appl_attribute19             IN     per_applications.appl_attribute19%TYPE
,p_appl_attribute20             IN     per_applications.appl_attribute20%TYPE
,p_current_employer             IN     per_applications.current_employer%TYPE
,p_termination_reason           IN     per_applications.termination_reason%TYPE
,p_app_object_version_number       OUT NOCOPY per_applications.object_version_number%TYPE
,p_adjusted_svc_date            IN     per_periods_of_service.adjusted_svc_date%TYPE
,p_pds_object_version_number    IN OUT NOCOPY per_periods_of_service.object_version_number%TYPE
,p_address_id                      OUT NOCOPY per_addresses.address_id%TYPE
,p_adr_date_from                IN     per_addresses.date_from%TYPE
,p_style                        IN     per_addresses.style%TYPE
,p_address_line1                IN     per_addresses.address_line1%TYPE
,p_address_line2                IN     per_addresses.address_line2%TYPE
,p_address_line3                IN     per_addresses.address_line3%TYPE
,p_address_type                 IN     per_addresses.address_type%TYPE
,p_country                      IN     per_addresses.country%TYPE
,p_adr_date_to                  IN     per_addresses.date_to%TYPE
,p_postal_code                  IN     per_addresses.postal_code%TYPE
,p_region_1                     IN     per_addresses.region_1%TYPE
,p_region_2                     IN     per_addresses.region_2%TYPE
,p_region_3                     IN     per_addresses.region_3%TYPE
,p_town_or_city                 IN     per_addresses.town_or_city%TYPE
,p_telephone_number_1           IN     per_addresses.telephone_number_1%TYPE
,p_telephone_number_2           IN     per_addresses.telephone_number_2%TYPE
,p_telephone_number_3           IN     per_addresses.telephone_number_3%TYPE
,p_add_information13            IN     per_addresses.add_information13%TYPE
,p_add_information14            IN     per_addresses.add_information14%TYPE
,p_add_information15            IN     per_addresses.add_information15%TYPE
,p_add_information16            IN     per_addresses.add_information16%TYPE
,p_add_information17            IN     per_addresses.add_information17%TYPE
,p_add_information18            IN     per_addresses.add_information18%TYPE
,p_add_information19            IN     per_addresses.add_information19%TYPE
,p_add_information20            IN     per_addresses.add_information20%TYPE
,p_addr_attribute_category      IN     per_addresses.addr_attribute_category%TYPE
,p_addr_attribute1              IN     per_addresses.addr_attribute1%TYPE
,p_addr_attribute2              IN     per_addresses.addr_attribute2%TYPE
,p_addr_attribute3              IN     per_addresses.addr_attribute3%TYPE
,p_addr_attribute4              IN     per_addresses.addr_attribute4%TYPE
,p_addr_attribute5              IN     per_addresses.addr_attribute5%TYPE
,p_addr_attribute6              IN     per_addresses.addr_attribute6%TYPE
,p_addr_attribute7              IN     per_addresses.addr_attribute7%TYPE
,p_addr_attribute8              IN     per_addresses.addr_attribute8%TYPE
,p_addr_attribute9              IN     per_addresses.addr_attribute9%TYPE
,p_addr_attribute10             IN     per_addresses.addr_attribute10%TYPE
,p_addr_attribute11             IN     per_addresses.addr_attribute11%TYPE
,p_addr_attribute12             IN     per_addresses.addr_attribute12%TYPE
,p_addr_attribute13             IN     per_addresses.addr_attribute13%TYPE
,p_addr_attribute14             IN     per_addresses.addr_attribute14%TYPE
,p_addr_attribute15             IN     per_addresses.addr_attribute15%TYPE
,p_addr_attribute16             IN     per_addresses.addr_attribute16%TYPE
,p_addr_attribute17             IN     per_addresses.addr_attribute17%TYPE
,p_addr_attribute18             IN     per_addresses.addr_attribute18%TYPE
,p_addr_attribute19             IN     per_addresses.addr_attribute19%TYPE
,p_addr_attribute20             IN     per_addresses.addr_attribute20%TYPE
,p_addr_object_version_number      OUT NOCOPY per_addresses.object_version_number%TYPE
,p_phn_h_phone_id                  OUT NOCOPY per_phones.phone_id%TYPE
,p_phn_h_date_from              IN     per_phones.date_from%TYPE
,p_phn_h_date_to                IN     per_phones.date_to%TYPE
,p_phn_h_phone_number           IN     per_phones.phone_number%TYPE
,p_phn_h_object_version_number     OUT NOCOPY per_phones.object_version_number%TYPE
,p_phn_w_phone_id                  OUT NOCOPY per_phones.phone_id%TYPE
,p_phn_w_date_from              IN     per_phones.date_from%TYPE
,p_phn_w_date_to                IN     per_phones.date_to%TYPE
,p_phn_w_phone_number           IN     per_phones.phone_number%TYPE
,p_phn_w_object_version_number     OUT NOCOPY per_phones.object_version_number%TYPE
,p_phn_m_phone_id                  OUT NOCOPY per_phones.phone_id%TYPE
,p_phn_m_date_from              IN     per_phones.date_from%TYPE
,p_phn_m_date_to                IN     per_phones.date_to%TYPE
,p_phn_m_phone_number           IN     per_phones.phone_number%TYPE
,p_phn_m_object_version_number     OUT NOCOPY per_phones.object_version_number%TYPE
,p_phn_hf_phone_id                 OUT NOCOPY per_phones.phone_id%TYPE
,p_phn_hf_date_from             IN     per_phones.date_from%TYPE
,p_phn_hf_date_to               IN     per_phones.date_to%TYPE
,p_phn_hf_phone_number          IN     per_phones.phone_number%TYPE
,p_phn_hf_object_version_number    OUT NOCOPY per_phones.object_version_number%TYPE
,p_phn_wf_phone_id                 OUT NOCOPY per_phones.phone_id%TYPE
,p_phn_wf_date_from             IN     per_phones.date_from%TYPE
,p_phn_wf_date_to               IN     per_phones.date_to%TYPE
,p_phn_wf_phone_number          IN     per_phones.phone_number%TYPE
,p_phn_wf_object_version_number    OUT NOCOPY per_phones.object_version_number%TYPE
,p_pay_proposal_id                 OUT NOCOPY per_pay_proposals.pay_proposal_id%TYPE
,p_change_date                  IN     per_pay_proposals.change_date%TYPE
,p_proposed_salary_n            IN     per_pay_proposals.proposed_salary_n%TYPE
,p_proposal_reason              IN     per_pay_proposals.proposal_reason%TYPE
,p_pyp_attribute_category       IN     per_pay_proposals.attribute_category%TYPE
,p_pyp_attribute1               IN     per_pay_proposals.attribute1%TYPE
,p_pyp_attribute2               IN     per_pay_proposals.attribute2%TYPE
,p_pyp_attribute3               IN     per_pay_proposals.attribute3%TYPE
,p_pyp_attribute4               IN     per_pay_proposals.attribute4%TYPE
,p_pyp_attribute5               IN     per_pay_proposals.attribute5%TYPE
,p_pyp_attribute6               IN     per_pay_proposals.attribute6%TYPE
,p_pyp_attribute7               IN     per_pay_proposals.attribute7%TYPE
,p_pyp_attribute8               IN     per_pay_proposals.attribute8%TYPE
,p_pyp_attribute9               IN     per_pay_proposals.attribute9%TYPE
,p_pyp_attribute10              IN     per_pay_proposals.attribute10%TYPE
,p_pyp_attribute11              IN     per_pay_proposals.attribute11%TYPE
,p_pyp_attribute12              IN     per_pay_proposals.attribute12%TYPE
,p_pyp_attribute13              IN     per_pay_proposals.attribute13%TYPE
,p_pyp_attribute14              IN     per_pay_proposals.attribute14%TYPE
,p_pyp_attribute15              IN     per_pay_proposals.attribute15%TYPE
,p_pyp_attribute16              IN     per_pay_proposals.attribute16%TYPE
,p_pyp_attribute17              IN     per_pay_proposals.attribute17%TYPE
,p_pyp_attribute18              IN     per_pay_proposals.attribute18%TYPE
,p_pyp_attribute19              IN     per_pay_proposals.attribute19%TYPE
,p_pyp_attribute20              IN     per_pay_proposals.attribute20%TYPE
,p_pyp_object_version_number       OUT NOCOPY per_pay_proposals.object_version_number%TYPE
,p_approved                     IN     per_pay_proposals.approved%TYPE
,p_deployment_factor_id            OUT NOCOPY per_deployment_factors.deployment_factor_id%TYPE
,p_work_any_country             IN     per_deployment_factors.work_any_country%TYPE
,p_work_any_location            IN     per_deployment_factors.work_any_location%TYPE
,p_relocate_domestically        IN     per_deployment_factors.relocate_domestically%TYPE
,p_relocate_internationally     IN     per_deployment_factors.relocate_internationally%TYPE
,p_travel_required              IN     per_deployment_factors.travel_required%TYPE
,p_country1                     IN     per_deployment_factors.country1%TYPE
,p_country2                     IN     per_deployment_factors.country2%TYPE
,p_country3                     IN     per_deployment_factors.country3%TYPE
,p_dpf_work_duration            IN     per_deployment_factors.work_duration%TYPE
,p_dpf_work_schedule            IN     per_deployment_factors.work_schedule%TYPE
,p_dpf_work_hours               IN     per_deployment_factors.work_hours%TYPE
,p_dpf_fte_capacity             IN     per_deployment_factors.fte_capacity%TYPE
,p_visit_internationally        IN     per_deployment_factors.visit_internationally%TYPE
,p_only_current_location        IN     per_deployment_factors.only_current_location%TYPE
,p_no_country1                  IN     per_deployment_factors.no_country1%TYPE
,p_no_country2                  IN     per_deployment_factors.no_country2%TYPE
,p_no_country3                  IN     per_deployment_factors.no_country3%TYPE
,p_earliest_available_date      IN     per_deployment_factors.earliest_available_date%TYPE
,p_available_for_transfer       IN     per_deployment_factors.available_for_transfer%TYPE
,p_relocation_preference        IN     per_deployment_factors.relocation_preference%TYPE
,p_dpf_object_version_number       OUT NOCOPY per_deployment_factors.object_version_number%TYPE
,p_dpf_attribute_category       IN     per_deployment_factors.attribute_category%TYPE
,p_dpf_attribute1               IN     per_deployment_factors.attribute1%TYPE
,p_dpf_attribute2               IN     per_deployment_factors.attribute2%TYPE
,p_dpf_attribute3               IN     per_deployment_factors.attribute3%TYPE
,p_dpf_attribute4               IN     per_deployment_factors.attribute4%TYPE
,p_dpf_attribute5               IN     per_deployment_factors.attribute5%TYPE
,p_dpf_attribute6               IN     per_deployment_factors.attribute6%TYPE
,p_dpf_attribute7               IN     per_deployment_factors.attribute7%TYPE
,p_dpf_attribute8               IN     per_deployment_factors.attribute8%TYPE
,p_dpf_attribute9               IN     per_deployment_factors.attribute9%TYPE
,p_dpf_attribute10              IN     per_deployment_factors.attribute10%TYPE
,p_dpf_attribute11              IN     per_deployment_factors.attribute11%TYPE
,p_dpf_attribute12              IN     per_deployment_factors.attribute12%TYPE
,p_dpf_attribute13              IN     per_deployment_factors.attribute13%TYPE
,p_dpf_attribute14              IN     per_deployment_factors.attribute14%TYPE
,p_dpf_attribute15              IN     per_deployment_factors.attribute15%TYPE
,p_dpf_attribute16              IN     per_deployment_factors.attribute16%TYPE
,p_dpf_attribute17              IN     per_deployment_factors.attribute17%TYPE
,p_dpf_attribute18              IN     per_deployment_factors.attribute18%TYPE
,p_dpf_attribute19              IN     per_deployment_factors.attribute19%TYPE
,p_dpf_attribute20              IN     per_deployment_factors.attribute20%TYPE
,p_chk1_checklist_item_id          OUT NOCOPY per_checklist_items.checklist_item_id%TYPE
,p_chk1_item_code               IN     per_checklist_items.item_code%TYPE
,p_chk1_date_due                IN     per_checklist_items.date_due%TYPE
,p_chk1_date_done               IN     per_checklist_items.date_done%TYPE
,p_chk1_status                  IN     per_checklist_items.status%TYPE
,p_chk1_notes                   IN     per_checklist_items.notes%TYPE
,p_chk1_object_version_number      OUT NOCOPY per_checklist_items.object_version_number%TYPE
,p_chk2_checklist_item_id          OUT NOCOPY per_checklist_items.checklist_item_id%TYPE
,p_chk2_item_code               IN     per_checklist_items.item_code%TYPE
,p_chk2_date_due                IN     per_checklist_items.date_due%TYPE
,p_chk2_date_done               IN     per_checklist_items.date_done%TYPE
,p_chk2_status                  IN     per_checklist_items.status%TYPE
,p_chk2_notes                   IN     per_checklist_items.notes%TYPE
,p_chk2_object_version_number      OUT NOCOPY per_checklist_items.object_version_number%TYPE
,p_chk3_checklist_item_id          OUT NOCOPY per_checklist_items.checklist_item_id%TYPE
,p_chk3_item_code               IN     per_checklist_items.item_code%TYPE
,p_chk3_date_due                IN     per_checklist_items.date_due%TYPE
,p_chk3_date_done               IN     per_checklist_items.date_done%TYPE
,p_chk3_status                  IN     per_checklist_items.status%TYPE
,p_chk3_notes                   IN     per_checklist_items.notes%TYPE
,p_chk3_object_version_number      OUT NOCOPY per_checklist_items.object_version_number%TYPE
,p_chk4_checklist_item_id          OUT NOCOPY per_checklist_items.checklist_item_id%TYPE
,p_chk4_item_code               IN     per_checklist_items.item_code%TYPE
,p_chk4_date_due                IN     per_checklist_items.date_due%TYPE
,p_chk4_date_done               IN     per_checklist_items.date_done%TYPE
,p_chk4_status                  IN     per_checklist_items.status%TYPE
,p_chk4_notes                   IN     per_checklist_items.notes%TYPE
,p_chk4_object_version_number      OUT NOCOPY per_checklist_items.object_version_number%TYPE
,p_chk5_checklist_item_id          OUT NOCOPY per_checklist_items.checklist_item_id%TYPE
,p_chk5_item_code               IN     per_checklist_items.item_code%TYPE
,p_chk5_date_due                IN     per_checklist_items.date_due%TYPE
,p_chk5_date_done               IN     per_checklist_items.date_done%TYPE
,p_chk5_status                  IN     per_checklist_items.status%TYPE
,p_chk5_notes                   IN     per_checklist_items.notes%TYPE
,p_chk5_object_version_number      OUT NOCOPY per_checklist_items.object_version_number%TYPE
,p_chk6_checklist_item_id          OUT NOCOPY per_checklist_items.checklist_item_id%TYPE
,p_chk6_item_code               IN     per_checklist_items.item_code%TYPE
,p_chk6_date_due                IN     per_checklist_items.date_due%TYPE
,p_chk6_date_done               IN     per_checklist_items.date_done%TYPE
,p_chk6_status                  IN     per_checklist_items.status%TYPE
,p_chk6_notes                   IN     per_checklist_items.notes%TYPE
,p_chk6_object_version_number      OUT NOCOPY per_checklist_items.object_version_number%TYPE
,p_chk7_checklist_item_id          OUT NOCOPY per_checklist_items.checklist_item_id%TYPE
,p_chk7_item_code               IN     per_checklist_items.item_code%TYPE
,p_chk7_date_due                IN     per_checklist_items.date_due%TYPE
,p_chk7_date_done               IN     per_checklist_items.date_done%TYPE
,p_chk7_status                  IN     per_checklist_items.status%TYPE
,p_chk7_notes                   IN     per_checklist_items.notes%TYPE
,p_chk7_object_version_number      OUT NOCOPY per_checklist_items.object_version_number%TYPE
,p_chk8_checklist_item_id          OUT NOCOPY per_checklist_items.checklist_item_id%TYPE
,p_chk8_item_code               IN     per_checklist_items.item_code%TYPE
,p_chk8_date_due                IN     per_checklist_items.date_due%TYPE
,p_chk8_date_done               IN     per_checklist_items.date_done%TYPE
,p_chk8_status                  IN     per_checklist_items.status%TYPE
,p_chk8_notes                   IN     per_checklist_items.notes%TYPE
,p_chk8_object_version_number      OUT NOCOPY per_checklist_items.object_version_number%TYPE
,p_chk9_checklist_item_id          OUT NOCOPY per_checklist_items.checklist_item_id%TYPE
,p_chk9_item_code               IN     per_checklist_items.item_code%TYPE
,p_chk9_date_due                IN     per_checklist_items.date_due%TYPE
,p_chk9_date_done               IN     per_checklist_items.date_done%TYPE
,p_chk9_status                  IN     per_checklist_items.status%TYPE
,p_chk9_notes                   IN     per_checklist_items.notes%TYPE
,p_chk9_object_version_number      OUT NOCOPY per_checklist_items.object_version_number%TYPE
,p_chk10_checklist_item_id         OUT NOCOPY per_checklist_items.checklist_item_id%TYPE
,p_chk10_item_code              IN     per_checklist_items.item_code%TYPE
,p_chk10_date_due               IN     per_checklist_items.date_due%TYPE
,p_chk10_date_done              IN     per_checklist_items.date_done%TYPE
,p_chk10_status                 IN     per_checklist_items.status%TYPE
,p_chk10_notes                  IN     per_checklist_items.notes%TYPE
,p_chk10_object_version_number     OUT NOCOPY per_checklist_items.object_version_number%TYPE
,p_tax_effective_start_date     IN OUT NOCOPY DATE
,p_tax_effective_end_date       IN OUT NOCOPY DATE
,p_tax_field1                   IN OUT NOCOPY VARCHAR2
,p_tax_field2                   IN OUT NOCOPY VARCHAR2
,p_tax_field3                   IN OUT NOCOPY VARCHAR2
,p_tax_field4                   IN OUT NOCOPY VARCHAR2
,p_tax_field5                   IN OUT NOCOPY VARCHAR2
,p_tax_field6                   IN OUT NOCOPY VARCHAR2
,p_tax_field7                   IN OUT NOCOPY VARCHAR2
,p_tax_field8                   IN OUT NOCOPY VARCHAR2
,p_tax_field9                   IN OUT NOCOPY VARCHAR2
,p_tax_field10                  IN OUT NOCOPY VARCHAR2
,p_tax_field11                  IN OUT NOCOPY VARCHAR2
,p_tax_field12                  IN OUT NOCOPY VARCHAR2
,p_tax_field13                  IN OUT NOCOPY VARCHAR2
,p_tax_field14                  IN OUT NOCOPY VARCHAR2
,p_tax_field15                  IN OUT NOCOPY VARCHAR2
,p_tax_field16                  IN OUT NOCOPY VARCHAR2
,p_tax_field17                  IN OUT NOCOPY VARCHAR2
,p_tax_field18                  IN OUT NOCOPY VARCHAR2
,p_tax_field19                  IN OUT NOCOPY VARCHAR2
,p_tax_field20                  IN OUT NOCOPY VARCHAR2
,p_tax_field21                  IN OUT NOCOPY VARCHAR2
,p_tax_field22                  IN OUT NOCOPY VARCHAR2
,p_tax_field23                  IN OUT NOCOPY VARCHAR2
,p_tax_field24                  IN OUT NOCOPY VARCHAR2
,p_tax_field25                  IN OUT NOCOPY VARCHAR2
,p_tax_field26                  IN OUT NOCOPY VARCHAR2
,p_tax_field27                  IN OUT NOCOPY VARCHAR2
,p_tax_field28                  IN OUT NOCOPY VARCHAR2
,p_tax_field29                  IN OUT NOCOPY VARCHAR2
,p_tax_field30                  IN OUT NOCOPY VARCHAR2
,p_tax_field31                  IN OUT NOCOPY VARCHAR2
,p_tax_field32                  IN OUT NOCOPY VARCHAR2
,p_tax_field33                  IN OUT NOCOPY VARCHAR2
,p_tax_field34                  IN OUT NOCOPY VARCHAR2
,p_tax_field35                  IN OUT NOCOPY VARCHAR2
,p_tax_field36                  IN OUT NOCOPY VARCHAR2
,p_tax_field37                  IN OUT NOCOPY VARCHAR2
,p_tax_field38                  IN OUT NOCOPY VARCHAR2
,p_tax_field39                  IN OUT NOCOPY VARCHAR2
,p_tax_field40                  IN OUT NOCOPY VARCHAR2
,p_tax_field41                  IN OUT NOCOPY VARCHAR2
,p_tax_field42                  IN OUT NOCOPY VARCHAR2
,p_tax_field43                  IN OUT NOCOPY VARCHAR2
,p_tax_field44                  IN OUT NOCOPY VARCHAR2
,p_tax_field45                  IN OUT NOCOPY VARCHAR2
,p_tax_field46                  IN OUT NOCOPY VARCHAR2
,p_tax_field47                  IN OUT NOCOPY VARCHAR2
,p_tax_field48                  IN OUT NOCOPY VARCHAR2
,p_tax_field49                  IN OUT NOCOPY VARCHAR2
,p_tax_field50                  IN OUT NOCOPY VARCHAR2
,p_tax_field51                  IN OUT NOCOPY VARCHAR2
,p_tax_field52                  IN OUT NOCOPY VARCHAR2
,p_tax_field53                  IN OUT NOCOPY VARCHAR2
,p_tax_field54                  IN OUT NOCOPY VARCHAR2
,p_tax_field55                  IN OUT NOCOPY VARCHAR2
,p_tax_field56                  IN OUT NOCOPY VARCHAR2
,p_tax_field57                  IN OUT NOCOPY VARCHAR2
,p_tax_field58                  IN OUT NOCOPY VARCHAR2
,p_tax_field59                  IN OUT NOCOPY VARCHAR2
,p_tax_field60                  IN OUT NOCOPY VARCHAR2
,p_tax_field61                  IN OUT NOCOPY VARCHAR2
,p_tax_field62                  IN OUT NOCOPY VARCHAR2
,p_tax_field63                  IN OUT NOCOPY VARCHAR2
,p_tax_field64                  IN OUT NOCOPY VARCHAR2
,p_tax_field65                  IN OUT NOCOPY VARCHAR2
,p_tax_field66                  IN OUT NOCOPY VARCHAR2
,p_tax_field67                  IN OUT NOCOPY VARCHAR2
,p_tax_field68                  IN OUT NOCOPY VARCHAR2
,p_tax_field69                  IN OUT NOCOPY VARCHAR2
,p_tax_field70                  IN OUT NOCOPY VARCHAR2
,p_tax_field71                  IN OUT NOCOPY VARCHAR2
,p_tax_field72                  IN OUT NOCOPY VARCHAR2
,p_tax_field73                  IN OUT NOCOPY VARCHAR2
,p_tax_field74                  IN OUT NOCOPY VARCHAR2
,p_tax_field75                  IN OUT NOCOPY VARCHAR2
,p_tax_field76                  IN OUT NOCOPY VARCHAR2
,p_tax_field77                  IN OUT NOCOPY VARCHAR2
,p_tax_field78                  IN OUT NOCOPY VARCHAR2
,p_tax_field79                  IN OUT NOCOPY VARCHAR2
,p_tax_field80                  IN OUT NOCOPY VARCHAR2
,p_tax_field81                  IN OUT NOCOPY VARCHAR2
,p_tax_field82                  IN OUT NOCOPY VARCHAR2
,p_tax_field83                  IN OUT NOCOPY VARCHAR2
,p_tax_field84                  IN OUT NOCOPY VARCHAR2
,p_tax_field85                  IN OUT NOCOPY VARCHAR2
,p_tax_field86                  IN OUT NOCOPY VARCHAR2
,p_tax_field87                  IN OUT NOCOPY VARCHAR2
,p_tax_field88                  IN OUT NOCOPY VARCHAR2
,p_tax_field89                  IN OUT NOCOPY VARCHAR2
,p_tax_field90                  IN OUT NOCOPY VARCHAR2
,p_tax_field91                  IN OUT NOCOPY VARCHAR2
,p_tax_field92                  IN OUT NOCOPY VARCHAR2
,p_tax_field93                  IN OUT NOCOPY VARCHAR2
,p_tax_field94                  IN OUT NOCOPY VARCHAR2
,p_tax_field95                  IN OUT NOCOPY VARCHAR2
,p_tax_field96                  IN OUT NOCOPY VARCHAR2
,p_tax_field97                  IN OUT NOCOPY VARCHAR2
,p_tax_field98                  IN OUT NOCOPY VARCHAR2
,p_tax_field99                  IN OUT NOCOPY VARCHAR2
,p_tax_field100                 IN OUT NOCOPY VARCHAR2
,p_tax_field101                 IN OUT NOCOPY VARCHAR2
,p_tax_field102                 IN OUT NOCOPY VARCHAR2
,p_tax_field103                 IN OUT NOCOPY VARCHAR2
,p_tax_field104                 IN OUT NOCOPY VARCHAR2
,p_tax_field105                 IN OUT NOCOPY VARCHAR2
,p_tax_field106                 IN OUT NOCOPY VARCHAR2
,p_tax_field107                 IN OUT NOCOPY VARCHAR2
,p_tax_field108                 IN OUT NOCOPY VARCHAR2
,p_tax_field109                 IN OUT NOCOPY VARCHAR2
,p_tax_field110                 IN OUT NOCOPY VARCHAR2
,p_tax_field111                 IN OUT NOCOPY VARCHAR2
,p_tax_field112                 IN OUT NOCOPY VARCHAR2
,p_tax_field113                 IN OUT NOCOPY VARCHAR2
,p_tax_field114                 IN OUT NOCOPY VARCHAR2
,p_tax_field115                 IN OUT NOCOPY VARCHAR2
,p_tax_field116                 IN OUT NOCOPY VARCHAR2
,p_tax_field117                 IN OUT NOCOPY VARCHAR2
,p_tax_field118                 IN OUT NOCOPY VARCHAR2
,p_tax_field119                 IN OUT NOCOPY VARCHAR2
,p_tax_field120                 IN OUT NOCOPY VARCHAR2
,p_tax_field121                 IN OUT NOCOPY VARCHAR2
,p_tax_field122                 IN OUT NOCOPY VARCHAR2
,p_tax_field123                 IN OUT NOCOPY VARCHAR2
,p_tax_field124                 IN OUT NOCOPY VARCHAR2
,p_tax_field125                 IN OUT NOCOPY VARCHAR2
,p_tax_field126                 IN OUT NOCOPY VARCHAR2
,p_tax_field127                 IN OUT NOCOPY VARCHAR2
,p_tax_field128                 IN OUT NOCOPY VARCHAR2
,p_tax_field129                 IN OUT NOCOPY VARCHAR2
,p_tax_field130                 IN OUT NOCOPY VARCHAR2
,p_tax_field131                 IN OUT NOCOPY VARCHAR2
,p_tax_field132                 IN OUT NOCOPY VARCHAR2
,p_tax_field133                 IN OUT NOCOPY VARCHAR2
,p_tax_field134                 IN OUT NOCOPY VARCHAR2
,p_tax_field135                 IN OUT NOCOPY VARCHAR2
,p_tax_field136                 IN OUT NOCOPY VARCHAR2
,p_tax_field137                 IN OUT NOCOPY VARCHAR2
,p_tax_field138                 IN OUT NOCOPY VARCHAR2
,p_tax_field139                 IN OUT NOCOPY VARCHAR2
,p_tax_field140                 IN OUT NOCOPY VARCHAR2
-- Bug 3357807 Start Here
,p_tax_field141                 IN OUT NOCOPY DATE
,p_tax_field142                 IN OUT NOCOPY DATE
,p_tax_field143                 IN OUT NOCOPY DATE
,p_tax_field144                 IN OUT NOCOPY DATE
,p_tax_field145                 IN OUT NOCOPY DATE
,p_tax_field146                 IN OUT NOCOPY DATE
,p_tax_field147                 IN OUT NOCOPY DATE
,p_tax_field148                 IN OUT NOCOPY DATE
,p_tax_field149                 IN OUT NOCOPY DATE
,p_tax_field150                 IN OUT NOCOPY DATE
-- Bug 3357807 End Here
,p_assign_payroll_warning          OUT NOCOPY BOOLEAN
,p_org_now_no_manager_warning      OUT NOCOPY BOOLEAN
,p_other_manager_warning           OUT NOCOPY BOOLEAN
,p_spp_delete_warning              OUT NOCOPY BOOLEAN
,p_entries_changed_warning         OUT NOCOPY VARCHAR2
,p_tax_district_changed_warning    OUT NOCOPY BOOLEAN
,p_proposed_salary_warning         OUT NOCOPY BOOLEAN
,p_approved_warning                OUT NOCOPY BOOLEAN
,p_payroll_warning                 OUT NOCOPY BOOLEAN
,p_gsp_post_process_warning        OUT NOCOPY VARCHAR2
);
--
PROCEDURE update_maintain_data
(p_effective_date               IN     DATE
,p_datetrack_update_mode        IN     VARCHAR2
,p_person_update_allowed        IN     VARCHAR2 DEFAULT 'TRUE'
,p_person_id                    IN     per_all_people_f.person_id%TYPE
,p_business_group_id            IN     per_all_people_f.business_group_id%TYPE
,p_legislation_code             IN     VARCHAR2
,p_per_effective_start_date     IN OUT NOCOPY per_all_people_f.effective_start_date%TYPE
,p_per_effective_end_date       IN OUT NOCOPY per_all_people_f.effective_end_date%TYPE
,p_per_validation_start_date       OUT NOCOPY DATE
,p_per_validation_end_date         OUT NOCOPY DATE
,p_person_type                  IN     per_person_types.user_person_type%TYPE
,p_system_person_type           IN     per_person_types.system_person_type%TYPE
,p_person_type_id               IN     per_all_people_f.person_type_id%TYPE
,p_last_name                    IN     per_all_people_f.last_name%TYPE
,p_start_date                   IN     per_all_people_f.start_date%TYPE
,p_applicant_number             IN     per_all_people_f.applicant_number%TYPE
,p_background_check_status      IN     per_all_people_f.background_check_status%TYPE
,p_background_date_check        IN     per_all_people_f.background_date_check%TYPE
,p_blood_type                   IN     per_all_people_f.blood_type%TYPE
,p_correspondence_language      IN     per_all_people_f.correspondence_language%TYPE
,p_current_applicant_flag       IN     per_all_people_f.current_applicant_flag%TYPE
,p_current_emp_or_apl_flag      IN     per_all_people_f.current_emp_or_apl_flag%TYPE
,p_current_employee_flag        IN     per_all_people_f.current_employee_flag%TYPE
--CWK
,p_current_npw_flag             IN     per_all_people_f.current_npw_flag%TYPE
,p_npw_number                   IN     per_all_people_f.npw_number%TYPE
,p_placement_date_start         IN     per_all_assignments_f.period_of_placement_date_start%TYPE
,p_projected_assignment_end     IN     per_all_assignments_f.projected_assignment_end%TYPE
,p_pdp_object_version_number    IN OUT NOCOPY per_periods_of_placement.object_version_number%TYPE
,p_vendor_employee_number       IN     per_all_assignments_f.vendor_employee_number%TYPE
,p_vendor_assignment_number     IN     per_all_assignments_f.vendor_assignment_number%TYPE
,p_vendor_id                    IN     per_all_assignments_f.vendor_id%TYPE
,p_vendor_site_id               IN     per_all_assignments_f.vendor_site_id%TYPE
,p_po_header_id                 IN     per_all_assignments_f.po_header_id%TYPE
,p_po_line_id                   IN     per_all_assignments_f.po_line_id%TYPE
,p_project_title                IN     per_all_assignments_f.project_title%TYPE
,p_grade_rule_id                IN OUT NOCOPY pay_grade_rules_f.grade_rule_id%TYPE
,p_rate_id                      IN     pay_grade_rules_f.rate_id%TYPE
,p_rate_currency_code           IN     pay_grade_rules_f.currency_code%TYPE
,p_rate_value                   IN     pay_grade_rules_f.value%TYPE
,p_rate_effective_start_date    IN OUT NOCOPY pay_grade_rules_f.effective_start_date%TYPE
,p_rate_effective_end_date      IN OUT NOCOPY pay_grade_rules_f.effective_end_date%TYPE
,p_rate_object_version_number   IN OUT NOCOPY pay_grade_rules_f.object_version_number%TYPE
--
,p_date_employee_data_verified  IN     per_all_people_f.date_employee_data_verified%TYPE
,p_date_of_birth                IN     per_all_people_f.date_of_birth%TYPE
,p_email_address                IN     per_all_people_f.email_address%TYPE
,p_employee_number              IN OUT NOCOPY per_all_people_f.employee_number%TYPE
,p_expense_check_send_to_addres IN     per_all_people_f.expense_check_send_to_address%TYPE
,p_first_name                   IN     per_all_people_f.first_name%TYPE
,p_per_fte_capacity             IN     per_all_people_f.fte_capacity%TYPE
,p_full_name                       OUT NOCOPY per_all_people_f.full_name%TYPE
,p_hold_applicant_date_until    IN     per_all_people_f.hold_applicant_date_until%TYPE
,p_honors                       IN     per_all_people_f.honors%TYPE
,p_internal_location            IN     per_all_people_f.internal_location%TYPE
,p_known_as                     IN     per_all_people_f.known_as%TYPE
,p_last_medical_test_by         IN     per_all_people_f.last_medical_test_by%TYPE
,p_last_medical_test_date       IN     per_all_people_f.last_medical_test_date%TYPE
,p_mailstop                     IN     per_all_people_f.mailstop%TYPE
,p_marital_status               IN     per_all_people_f.marital_status%TYPE
,p_middle_names                 IN     per_all_people_f.middle_names%TYPE
,p_nationality                  IN     per_all_people_f.nationality%TYPE
,p_national_identifier          IN     per_all_people_f.national_identifier%TYPE
,p_office_number                IN     per_all_people_f.office_number%TYPE
,p_on_military_service          IN     per_all_people_f.on_military_service%TYPE
,p_pre_name_adjunct             IN     per_all_people_f.pre_name_adjunct%TYPE
,p_previous_last_name           IN     per_all_people_f.previous_last_name%TYPE
,p_rehire_recommendation        IN     per_all_people_f.rehire_recommendation%TYPE
,p_rehire_reason                IN     per_all_people_f.rehire_reason%TYPE
,p_resume_exists                IN     per_all_people_f.resume_exists%TYPE
,p_resume_last_updated          IN     per_all_people_f.resume_last_updated%TYPE
,p_registered_disabled_flag     IN     per_all_people_f.registered_disabled_flag%TYPE
,p_second_passport_exists       IN     per_all_people_f.second_passport_exists%TYPE
,p_sex                          IN     per_all_people_f.sex%TYPE
,p_student_status               IN     per_all_people_f.student_status%TYPE
,p_suffix                       IN     per_all_people_f.suffix%TYPE
,p_title                        IN     per_all_people_f.title%TYPE
,p_work_schedule                IN     per_all_people_f.work_schedule%TYPE
,p_coord_ben_med_pln_no         IN     per_all_people_f.coord_ben_med_pln_no%TYPE
,p_coord_ben_no_cvg_flag        IN     per_all_people_f.coord_ben_no_cvg_flag%TYPE
,p_dpdnt_adoption_date          IN     per_all_people_f.dpdnt_adoption_date%TYPE
,p_dpdnt_vlntry_svce_flag       IN     per_all_people_f.dpdnt_vlntry_svce_flag%TYPE
,p_receipt_of_death_cert_date   IN     per_all_people_f.receipt_of_death_cert_date%TYPE
,p_uses_tobacco_flag            IN     per_all_people_f.uses_tobacco_flag%TYPE
,p_benefit_group_id             IN     per_all_people_f.benefit_group_id%TYPE
,p_attribute_category           IN     per_all_people_f.attribute_category%TYPE
,p_attribute1                   IN     per_all_people_f.attribute1%TYPE
,p_attribute2                   IN     per_all_people_f.attribute2%TYPE
,p_attribute3                   IN     per_all_people_f.attribute3%TYPE
,p_attribute4                   IN     per_all_people_f.attribute4%TYPE
,p_attribute5                   IN     per_all_people_f.attribute5%TYPE
,p_attribute6                   IN     per_all_people_f.attribute6%TYPE
,p_attribute7                   IN     per_all_people_f.attribute7%TYPE
,p_attribute8                   IN     per_all_people_f.attribute8%TYPE
,p_attribute9                   IN     per_all_people_f.attribute9%TYPE
,p_attribute10                  IN     per_all_people_f.attribute10%TYPE
,p_attribute11                  IN     per_all_people_f.attribute11%TYPE
,p_attribute12                  IN     per_all_people_f.attribute12%TYPE
,p_attribute13                  IN     per_all_people_f.attribute13%TYPE
,p_attribute14                  IN     per_all_people_f.attribute14%TYPE
,p_attribute15                  IN     per_all_people_f.attribute15%TYPE
,p_attribute16                  IN     per_all_people_f.attribute16%TYPE
,p_attribute17                  IN     per_all_people_f.attribute17%TYPE
,p_attribute18                  IN     per_all_people_f.attribute18%TYPE
,p_attribute19                  IN     per_all_people_f.attribute19%TYPE
,p_attribute20                  IN     per_all_people_f.attribute20%TYPE
,p_attribute21                  IN     per_all_people_f.attribute21%TYPE
,p_attribute22                  IN     per_all_people_f.attribute22%TYPE
,p_attribute23                  IN     per_all_people_f.attribute23%TYPE
,p_attribute24                  IN     per_all_people_f.attribute24%TYPE
,p_attribute25                  IN     per_all_people_f.attribute25%TYPE
,p_attribute26                  IN     per_all_people_f.attribute26%TYPE
,p_attribute27                  IN     per_all_people_f.attribute27%TYPE
,p_attribute28                  IN     per_all_people_f.attribute28%TYPE
,p_attribute29                  IN     per_all_people_f.attribute29%TYPE
,p_attribute30                  IN     per_all_people_f.attribute30%TYPE
,p_per_information_category     IN     per_all_people_f.per_information_category%TYPE
,p_per_information1             IN     per_all_people_f.attribute1%TYPE
,p_per_information2             IN     per_all_people_f.attribute2%TYPE
,p_per_information3             IN     per_all_people_f.attribute3%TYPE
,p_per_information4             IN     per_all_people_f.attribute4%TYPE
,p_per_information5             IN     per_all_people_f.attribute5%TYPE
,p_per_information6             IN     per_all_people_f.attribute6%TYPE
,p_per_information7             IN     per_all_people_f.attribute7%TYPE
,p_per_information8             IN     per_all_people_f.attribute8%TYPE
,p_per_information9             IN     per_all_people_f.attribute9%TYPE
,p_per_information10            IN     per_all_people_f.attribute10%TYPE
,p_per_information11            IN     per_all_people_f.attribute11%TYPE
,p_per_information12            IN     per_all_people_f.attribute12%TYPE
,p_per_information13            IN     per_all_people_f.attribute13%TYPE
,p_per_information14            IN     per_all_people_f.attribute14%TYPE
,p_per_information15            IN     per_all_people_f.attribute15%TYPE
,p_per_information16            IN     per_all_people_f.attribute16%TYPE
,p_per_information17            IN     per_all_people_f.attribute17%TYPE
,p_per_information18            IN     per_all_people_f.attribute18%TYPE
,p_per_information19            IN     per_all_people_f.attribute19%TYPE
,p_per_information20            IN     per_all_people_f.attribute20%TYPE
,p_per_information21            IN     per_all_people_f.attribute21%TYPE
,p_per_information22            IN     per_all_people_f.attribute22%TYPE
,p_per_information23            IN     per_all_people_f.attribute23%TYPE
,p_per_information24            IN     per_all_people_f.attribute24%TYPE
,p_per_information25            IN     per_all_people_f.attribute25%TYPE
,p_per_information26            IN     per_all_people_f.attribute26%TYPE
,p_per_information27            IN     per_all_people_f.attribute27%TYPE
,p_per_information28            IN     per_all_people_f.attribute28%TYPE
,p_per_information29            IN     per_all_people_f.attribute29%TYPE
,p_per_information30            IN     per_all_people_f.attribute30%TYPE
,p_date_of_death                IN     per_all_people_f.date_of_death%TYPE
,p_original_date_of_hire        IN     per_all_people_f.original_date_of_hire%TYPE
,p_town_of_birth                  IN     per_all_people_f.town_of_birth%TYPE
,p_region_of_birth                IN     per_all_people_f.region_of_birth%TYPE
,p_country_of_birth               IN     per_all_people_f.country_of_birth%TYPE
,p_per_object_version_number    IN OUT NOCOPY per_all_people_f.object_version_number%TYPE
,p_assignment_update_allowed    IN     VARCHAR2 DEFAULT 'TRUE'
,p_assignment_id                IN OUT NOCOPY per_all_assignments_f.assignment_id%TYPE
,p_asg_effective_start_date     IN OUT NOCOPY per_all_assignments_f.effective_start_date%TYPE
,p_asg_effective_end_date       IN OUT NOCOPY per_all_assignments_f.effective_end_date%TYPE
,p_asg_validation_start_date       OUT NOCOPY DATE
,p_asg_validation_end_date         OUT NOCOPY DATE
,p_recruiter_id                 IN     per_all_assignments_f.recruiter_id%TYPE
,p_grade_id                     IN     per_all_assignments_f.grade_id%TYPE
,p_grade_ladder_pgm_id          IN     per_all_assignments_f.grade_ladder_pgm_id%TYPE
,p_position_id                  IN     per_all_assignments_f.position_id%TYPE
,p_job_id                       IN     per_all_assignments_f.job_id%TYPE
,p_assignment_status_type_id    IN     per_all_assignments_f.assignment_status_type_id%TYPE
,p_system_status                IN     per_assignment_status_types.per_system_status%TYPE
,p_payroll_id                   IN     per_all_assignments_f.payroll_id%TYPE
,p_location_id                  IN     per_all_assignments_f.location_id%TYPE
,p_person_referred_by_id        IN     per_all_assignments_f.person_referred_by_id%TYPE
,p_supervisor_id                IN     per_all_assignments_f.supervisor_id%TYPE
,p_supervisor_assignment_id     IN     per_all_assignments_f.supervisor_assignment_id%TYPE
,p_recruitment_activity_id      IN     per_all_assignments_f.recruitment_activity_id%TYPE
,p_source_organization_id       IN     per_all_assignments_f.source_organization_id%TYPE
,p_organization_id              IN     per_all_assignments_f.organization_id%TYPE
,p_pgp_segment1                 IN     pay_people_groups.segment1%TYPE
,p_pgp_segment2                 IN     pay_people_groups.segment2%TYPE
,p_pgp_segment3                 IN     pay_people_groups.segment3%TYPE
,p_pgp_segment4                 IN     pay_people_groups.segment4%TYPE
,p_pgp_segment5                 IN     pay_people_groups.segment5%TYPE
,p_pgp_segment6                 IN     pay_people_groups.segment6%TYPE
,p_pgp_segment7                 IN     pay_people_groups.segment7%TYPE
,p_pgp_segment8                 IN     pay_people_groups.segment8%TYPE
,p_pgp_segment9                 IN     pay_people_groups.segment9%TYPE
,p_pgp_segment10                IN     pay_people_groups.segment10%TYPE
,p_pgp_segment11                IN     pay_people_groups.segment11%TYPE
,p_pgp_segment12                IN     pay_people_groups.segment12%TYPE
,p_pgp_segment13                IN     pay_people_groups.segment13%TYPE
,p_pgp_segment14                IN     pay_people_groups.segment14%TYPE
,p_pgp_segment15                IN     pay_people_groups.segment15%TYPE
,p_pgp_segment16                IN     pay_people_groups.segment16%TYPE
,p_pgp_segment17                IN     pay_people_groups.segment17%TYPE
,p_pgp_segment18                IN     pay_people_groups.segment18%TYPE
,p_pgp_segment19                IN     pay_people_groups.segment19%TYPE
,p_pgp_segment20                IN     pay_people_groups.segment20%TYPE
,p_pgp_segment21                IN     pay_people_groups.segment21%TYPE
,p_pgp_segment22                IN     pay_people_groups.segment22%TYPE
,p_pgp_segment23                IN     pay_people_groups.segment23%TYPE
,p_pgp_segment24                IN     pay_people_groups.segment24%TYPE
,p_pgp_segment25                IN     pay_people_groups.segment25%TYPE
,p_pgp_segment26                IN     pay_people_groups.segment26%TYPE
,p_pgp_segment27                IN     pay_people_groups.segment27%TYPE
,p_pgp_segment28                IN     pay_people_groups.segment28%TYPE
,p_pgp_segment29                IN     pay_people_groups.segment29%TYPE
,p_pgp_segment30                IN     pay_people_groups.segment30%TYPE
,p_people_group_id              IN OUT NOCOPY per_all_assignments_f.people_group_id%TYPE
,p_scl_segment1                 IN     hr_soft_coding_keyflex.segment1%TYPE
,p_scl_segment2                 IN     hr_soft_coding_keyflex.segment2%TYPE
,p_scl_segment3                 IN     hr_soft_coding_keyflex.segment3%TYPE
,p_scl_segment4                 IN     hr_soft_coding_keyflex.segment4%TYPE
,p_scl_segment5                 IN     hr_soft_coding_keyflex.segment5%TYPE
,p_scl_segment6                 IN     hr_soft_coding_keyflex.segment6%TYPE
,p_scl_segment7                 IN     hr_soft_coding_keyflex.segment7%TYPE
,p_scl_segment8                 IN     hr_soft_coding_keyflex.segment8%TYPE
,p_scl_segment9                 IN     hr_soft_coding_keyflex.segment9%TYPE
,p_scl_segment10                IN     hr_soft_coding_keyflex.segment10%TYPE
,p_scl_segment11                IN     hr_soft_coding_keyflex.segment11%TYPE
,p_scl_segment12                IN     hr_soft_coding_keyflex.segment12%TYPE
,p_scl_segment13                IN     hr_soft_coding_keyflex.segment13%TYPE
,p_scl_segment14                IN     hr_soft_coding_keyflex.segment14%TYPE
,p_scl_segment15                IN     hr_soft_coding_keyflex.segment15%TYPE
,p_scl_segment16                IN     hr_soft_coding_keyflex.segment16%TYPE
,p_scl_segment17                IN     hr_soft_coding_keyflex.segment17%TYPE
,p_scl_segment18                IN     hr_soft_coding_keyflex.segment18%TYPE
,p_scl_segment19                IN     hr_soft_coding_keyflex.segment19%TYPE
,p_scl_segment20                IN     hr_soft_coding_keyflex.segment20%TYPE
,p_scl_segment21                IN     hr_soft_coding_keyflex.segment21%TYPE
,p_scl_segment22                IN     hr_soft_coding_keyflex.segment22%TYPE
,p_scl_segment23                IN     hr_soft_coding_keyflex.segment23%TYPE
,p_scl_segment24                IN     hr_soft_coding_keyflex.segment24%TYPE
,p_scl_segment25                IN     hr_soft_coding_keyflex.segment25%TYPE
,p_scl_segment26                IN     hr_soft_coding_keyflex.segment26%TYPE
,p_scl_segment27                IN     hr_soft_coding_keyflex.segment27%TYPE
,p_scl_segment28                IN     hr_soft_coding_keyflex.segment28%TYPE
,p_scl_segment29                IN     hr_soft_coding_keyflex.segment29%TYPE
,p_scl_segment30                IN     hr_soft_coding_keyflex.segment30%TYPE
,p_soft_coding_keyflex_id       IN OUT NOCOPY per_all_assignments_f.soft_coding_keyflex_id%TYPE
,p_vacancy_id                   IN     per_all_assignments_f.vacancy_id%TYPE
,p_pay_basis_id                 IN     per_all_assignments_f.pay_basis_id%TYPE
,p_assignment_sequence          IN OUT NOCOPY per_all_assignments_f.assignment_sequence%TYPE
,p_assignment_type              IN     per_all_assignments_f.assignment_type%TYPE
,p_asg_primary_flag             IN     per_all_assignments_f.primary_flag%TYPE
,p_assignment_number            IN OUT NOCOPY per_all_assignments_f.assignment_number%TYPE
,p_date_probation_end           IN     per_all_assignments_f.date_probation_end%TYPE
,p_default_code_comb_id         IN     per_all_assignments_f.default_code_comb_id%TYPE
,p_employment_category          IN     per_all_assignments_f.employment_category%TYPE
,p_employee_category            IN     per_all_assignments_f.employee_category%TYPE
,p_frequency                    IN     per_all_assignments_f.frequency%TYPE
,p_normal_hours                 IN     per_all_assignments_f.normal_hours%TYPE
,p_period_of_service_id         IN     per_all_assignments_f.period_of_service_id%TYPE
,p_probation_period             IN     per_all_assignments_f.probation_period%TYPE
,p_probation_unit               IN     per_all_assignments_f.probation_unit%TYPE
,p_notice_period                IN     per_all_assignments_f.notice_period%TYPE
,p_notice_unit                  IN     per_all_assignments_f.notice_period_uom%TYPE
--
,p_set_of_books_id              IN     per_all_assignments_f.set_of_books_id%TYPE
,p_billing_title                IN     per_all_assignments_f.title%type
--
,p_time_normal_finish           IN     per_all_assignments_f.time_normal_finish%TYPE
,p_time_normal_start            IN     per_all_assignments_f.time_normal_start%TYPE
,p_ass_attribute_category       IN     per_all_assignments_f.ass_attribute_category%TYPE
,p_ass_attribute1               IN     per_all_assignments_f.ass_attribute1%TYPE
,p_ass_attribute2               IN     per_all_assignments_f.ass_attribute2%TYPE
,p_ass_attribute3               IN     per_all_assignments_f.ass_attribute3%TYPE
,p_ass_attribute4               IN     per_all_assignments_f.ass_attribute4%TYPE
,p_ass_attribute5               IN     per_all_assignments_f.ass_attribute5%TYPE
,p_ass_attribute6               IN     per_all_assignments_f.ass_attribute6%TYPE
,p_ass_attribute7               IN     per_all_assignments_f.ass_attribute7%TYPE
,p_ass_attribute8               IN     per_all_assignments_f.ass_attribute8%TYPE
,p_ass_attribute9               IN     per_all_assignments_f.ass_attribute9%TYPE
,p_ass_attribute10              IN     per_all_assignments_f.ass_attribute10%TYPE
,p_ass_attribute11              IN     per_all_assignments_f.ass_attribute11%TYPE
,p_ass_attribute12              IN     per_all_assignments_f.ass_attribute12%TYPE
,p_ass_attribute13              IN     per_all_assignments_f.ass_attribute13%TYPE
,p_ass_attribute14              IN     per_all_assignments_f.ass_attribute14%TYPE
,p_ass_attribute15              IN     per_all_assignments_f.ass_attribute15%TYPE
,p_ass_attribute16              IN     per_all_assignments_f.ass_attribute16%TYPE
,p_ass_attribute17              IN     per_all_assignments_f.ass_attribute17%TYPE
,p_ass_attribute18              IN     per_all_assignments_f.ass_attribute18%TYPE
,p_ass_attribute19              IN     per_all_assignments_f.ass_attribute19%TYPE
,p_ass_attribute20              IN     per_all_assignments_f.ass_attribute20%TYPE
,p_ass_attribute21              IN     per_all_assignments_f.ass_attribute21%TYPE
,p_ass_attribute22              IN     per_all_assignments_f.ass_attribute22%TYPE
,p_ass_attribute23              IN     per_all_assignments_f.ass_attribute23%TYPE
,p_ass_attribute24              IN     per_all_assignments_f.ass_attribute24%TYPE
,p_ass_attribute25              IN     per_all_assignments_f.ass_attribute25%TYPE
,p_ass_attribute26              IN     per_all_assignments_f.ass_attribute26%TYPE
,p_ass_attribute27              IN     per_all_assignments_f.ass_attribute27%TYPE
,p_ass_attribute28              IN     per_all_assignments_f.ass_attribute28%TYPE
,p_ass_attribute29              IN     per_all_assignments_f.ass_attribute29%TYPE
,p_ass_attribute30              IN     per_all_assignments_f.ass_attribute30%TYPE
,p_asg_object_version_number    IN OUT NOCOPY per_all_assignments_f.object_version_number%TYPE
,p_bargaining_unit_code         IN     per_all_assignments_f.bargaining_unit_code%TYPE
,p_labour_union_member_flag     IN     per_all_assignments_f.labour_union_member_flag%TYPE
,p_hourly_salaried_code         IN     per_all_assignments_f.hourly_salaried_code%TYPE
,p_special_ceiling_step_id      IN OUT NOCOPY per_all_assignments_f.special_ceiling_step_id%TYPE
,p_change_reason                IN     per_all_assignments_f.change_reason%TYPE
,p_internal_address_line        IN     per_all_assignments_f.internal_address_line%TYPE
,p_manager_flag                 IN     per_all_assignments_f.manager_flag%TYPE
,p_perf_review_period           IN     per_all_assignments_f.perf_review_period%TYPE
,p_perf_review_period_frequency IN     per_all_assignments_f.perf_review_period_frequency%TYPE
,p_sal_review_period            IN     per_all_assignments_f.sal_review_period%TYPE
,p_sal_review_period_frequency  IN     per_all_assignments_f.sal_review_period_frequency%TYPE
,p_source_type                  IN     per_all_assignments_f.source_type%TYPE
,p_contract_id                  IN     per_all_assignments_f.contract_id%TYPE
,p_collective_agreement_id      IN     per_all_assignments_f.collective_agreement_id%TYPE
,p_cagr_id_flex_num             IN OUT NOCOPY per_all_assignments_f.cagr_id_flex_num%TYPE
,p_cagr_grade_def_id            IN OUT NOCOPY per_all_assignments_f.cagr_grade_def_id%TYPE
,p_establishment_id             IN     per_all_assignments_f.establishment_id%TYPE
--Bug 3063591 Start Here
,p_work_at_home                 IN     per_all_assignments_f.work_at_home%TYPE default null
--Bug 3063591 End Here
,p_application_id               IN     per_applications.application_id%TYPE
,p_projected_hire_date          IN     per_applications.projected_hire_date%TYPE
,p_appl_attribute_category      IN     per_applications.appl_attribute_category%TYPE
,p_appl_attribute1              IN     per_applications.appl_attribute1%TYPE
,p_appl_attribute2              IN     per_applications.appl_attribute2%TYPE
,p_appl_attribute3              IN     per_applications.appl_attribute3%TYPE
,p_appl_attribute4              IN     per_applications.appl_attribute4%TYPE
,p_appl_attribute5              IN     per_applications.appl_attribute5%TYPE
,p_appl_attribute6              IN     per_applications.appl_attribute6%TYPE
,p_appl_attribute7              IN     per_applications.appl_attribute7%TYPE
,p_appl_attribute8              IN     per_applications.appl_attribute8%TYPE
,p_appl_attribute9              IN     per_applications.appl_attribute9%TYPE
,p_appl_attribute10             IN     per_applications.appl_attribute10%TYPE
,p_appl_attribute11             IN     per_applications.appl_attribute11%TYPE
,p_appl_attribute12             IN     per_applications.appl_attribute12%TYPE
,p_appl_attribute13             IN     per_applications.appl_attribute13%TYPE
,p_appl_attribute14             IN     per_applications.appl_attribute14%TYPE
,p_appl_attribute15             IN     per_applications.appl_attribute15%TYPE
,p_appl_attribute16             IN     per_applications.appl_attribute16%TYPE
,p_appl_attribute17             IN     per_applications.appl_attribute17%TYPE
,p_appl_attribute18             IN     per_applications.appl_attribute18%TYPE
,p_appl_attribute19             IN     per_applications.appl_attribute19%TYPE
,p_appl_attribute20             IN     per_applications.appl_attribute20%TYPE
,p_current_employer             IN     per_applications.current_employer%TYPE
,p_termination_reason           IN     per_applications.termination_reason%TYPE
,p_app_object_version_number    IN OUT NOCOPY per_applications.object_version_number%TYPE
,p_adjusted_svc_date            IN     per_periods_of_service.adjusted_svc_date%TYPE
,p_pds_object_version_number    IN     per_periods_of_service.object_version_number%TYPE
,p_pds_hire_date                IN     per_periods_of_service.date_start%TYPE
,p_address_id                   IN OUT NOCOPY per_addresses.address_id%TYPE
,p_adr_date_from                IN     per_addresses.date_from%TYPE
,p_style                        IN     per_addresses.style%TYPE
,p_address_line1                IN     per_addresses.address_line1%TYPE
,p_address_line2                IN     per_addresses.address_line2%TYPE
,p_address_line3                IN     per_addresses.address_line3%TYPE
,p_address_type                 IN     per_addresses.address_type%TYPE
,p_country                      IN     per_addresses.country%TYPE
,p_adr_date_to                  IN     per_addresses.date_to%TYPE
,p_postal_code                  IN     per_addresses.postal_code%TYPE
,p_region_1                     IN     per_addresses.region_1%TYPE
,p_region_2                     IN     per_addresses.region_2%TYPE
,p_region_3                     IN     per_addresses.region_3%TYPE
,p_town_or_city                 IN     per_addresses.town_or_city%TYPE
,p_telephone_number_1           IN     per_addresses.telephone_number_1%TYPE
,p_telephone_number_2           IN     per_addresses.telephone_number_2%TYPE
,p_telephone_number_3           IN     per_addresses.telephone_number_3%TYPE
,p_add_information13            IN     per_addresses.add_information13%TYPE
,p_add_information14            IN     per_addresses.add_information14%TYPE
,p_add_information15            IN     per_addresses.add_information15%TYPE
,p_add_information16            IN     per_addresses.add_information16%TYPE
,p_add_information17            IN     per_addresses.add_information17%TYPE
,p_add_information18            IN     per_addresses.add_information18%TYPE
,p_add_information19            IN     per_addresses.add_information19%TYPE
,p_add_information20            IN     per_addresses.add_information20%TYPE
,p_addr_attribute_category      IN     per_addresses.addr_attribute_category%TYPE
,p_addr_attribute1              IN     per_addresses.addr_attribute1%TYPE
,p_addr_attribute2              IN     per_addresses.addr_attribute2%TYPE
,p_addr_attribute3              IN     per_addresses.addr_attribute3%TYPE
,p_addr_attribute4              IN     per_addresses.addr_attribute4%TYPE
,p_addr_attribute5              IN     per_addresses.addr_attribute5%TYPE
,p_addr_attribute6              IN     per_addresses.addr_attribute6%TYPE
,p_addr_attribute7              IN     per_addresses.addr_attribute7%TYPE
,p_addr_attribute8              IN     per_addresses.addr_attribute8%TYPE
,p_addr_attribute9              IN     per_addresses.addr_attribute9%TYPE
,p_addr_attribute10             IN     per_addresses.addr_attribute10%TYPE
,p_addr_attribute11             IN     per_addresses.addr_attribute11%TYPE
,p_addr_attribute12             IN     per_addresses.addr_attribute12%TYPE
,p_addr_attribute13             IN     per_addresses.addr_attribute13%TYPE
,p_addr_attribute14             IN     per_addresses.addr_attribute14%TYPE
,p_addr_attribute15             IN     per_addresses.addr_attribute15%TYPE
,p_addr_attribute16             IN     per_addresses.addr_attribute16%TYPE
,p_addr_attribute17             IN     per_addresses.addr_attribute17%TYPE
,p_addr_attribute18             IN     per_addresses.addr_attribute18%TYPE
,p_addr_attribute19             IN     per_addresses.addr_attribute19%TYPE
,p_addr_attribute20             IN     per_addresses.addr_attribute20%TYPE
,p_addr_object_version_number   IN OUT NOCOPY per_addresses.object_version_number%TYPE
,p_phn_h_phone_id               IN OUT NOCOPY per_phones.phone_id%TYPE
,p_phn_h_date_from              IN     per_phones.date_from%TYPE
,p_phn_h_date_to                IN     per_phones.date_to%TYPE
,p_phn_h_phone_number           IN     per_phones.phone_number%TYPE
,p_phn_h_object_version_number  IN OUT NOCOPY per_phones.object_version_number%TYPE
,p_phn_w_phone_id               IN OUT NOCOPY per_phones.phone_id%TYPE
,p_phn_w_date_from              IN     per_phones.date_from%TYPE
,p_phn_w_date_to                IN     per_phones.date_to%TYPE
,p_phn_w_phone_number           IN     per_phones.phone_number%TYPE
,p_phn_w_object_version_number  IN OUT NOCOPY per_phones.object_version_number%TYPE
,p_phn_m_phone_id               IN OUT NOCOPY per_phones.phone_id%TYPE
,p_phn_m_date_from              IN     per_phones.date_from%TYPE
,p_phn_m_date_to                IN     per_phones.date_to%TYPE
,p_phn_m_phone_number           IN     per_phones.phone_number%TYPE
,p_phn_m_object_version_number  IN OUT NOCOPY per_phones.object_version_number%TYPE
,p_phn_hf_phone_id              IN OUT NOCOPY per_phones.phone_id%TYPE
,p_phn_hf_date_from             IN     per_phones.date_from%TYPE
,p_phn_hf_date_to               IN     per_phones.date_to%TYPE
,p_phn_hf_phone_number          IN     per_phones.phone_number%TYPE
,p_phn_hf_object_version_number IN OUT NOCOPY per_phones.object_version_number%TYPE
,p_phn_wf_phone_id              IN OUT NOCOPY per_phones.phone_id%TYPE
,p_phn_wf_date_from             IN     per_phones.date_from%TYPE
,p_phn_wf_date_to               IN     per_phones.date_to%TYPE
,p_phn_wf_phone_number          IN     per_phones.phone_number%TYPE
,p_phn_wf_object_version_number IN OUT NOCOPY per_phones.object_version_number%TYPE
,p_pay_proposal_id              IN OUT NOCOPY per_pay_proposals.pay_proposal_id%TYPE
,p_change_date                  IN     per_pay_proposals.change_date%TYPE
,p_proposed_salary_n            IN     per_pay_proposals.proposed_salary_n%TYPE
,p_proposal_reason              IN     per_pay_proposals.proposal_reason%TYPE
,p_pyp_attribute_category       IN     per_pay_proposals.attribute_category%TYPE
,p_pyp_attribute1               IN     per_pay_proposals.attribute1%TYPE
,p_pyp_attribute2               IN     per_pay_proposals.attribute2%TYPE
,p_pyp_attribute3               IN     per_pay_proposals.attribute3%TYPE
,p_pyp_attribute4               IN     per_pay_proposals.attribute4%TYPE
,p_pyp_attribute5               IN     per_pay_proposals.attribute5%TYPE
,p_pyp_attribute6               IN     per_pay_proposals.attribute6%TYPE
,p_pyp_attribute7               IN     per_pay_proposals.attribute7%TYPE
,p_pyp_attribute8               IN     per_pay_proposals.attribute8%TYPE
,p_pyp_attribute9               IN     per_pay_proposals.attribute9%TYPE
,p_pyp_attribute10              IN     per_pay_proposals.attribute10%TYPE
,p_pyp_attribute11              IN     per_pay_proposals.attribute11%TYPE
,p_pyp_attribute12              IN     per_pay_proposals.attribute12%TYPE
,p_pyp_attribute13              IN     per_pay_proposals.attribute13%TYPE
,p_pyp_attribute14              IN     per_pay_proposals.attribute14%TYPE
,p_pyp_attribute15              IN     per_pay_proposals.attribute15%TYPE
,p_pyp_attribute16              IN     per_pay_proposals.attribute16%TYPE
,p_pyp_attribute17              IN     per_pay_proposals.attribute17%TYPE
,p_pyp_attribute18              IN     per_pay_proposals.attribute18%TYPE
,p_pyp_attribute19              IN     per_pay_proposals.attribute19%TYPE
,p_pyp_attribute20              IN     per_pay_proposals.attribute20%TYPE
,p_pyp_object_version_number    IN OUT NOCOPY per_pay_proposals.object_version_number%TYPE
,p_approved                     IN     per_pay_proposals.approved%TYPE
,p_deployment_factor_id         IN OUT NOCOPY per_deployment_factors.deployment_factor_id%TYPE
,p_work_any_country             IN     per_deployment_factors.work_any_country%TYPE
,p_work_any_location            IN     per_deployment_factors.work_any_location%TYPE
,p_relocate_domestically        IN     per_deployment_factors.relocate_domestically%TYPE
,p_relocate_internationally     IN     per_deployment_factors.relocate_internationally%TYPE
,p_travel_required              IN     per_deployment_factors.travel_required%TYPE
,p_country1                     IN     per_deployment_factors.country1%TYPE
,p_country2                     IN     per_deployment_factors.country2%TYPE
,p_country3                     IN     per_deployment_factors.country3%TYPE
,p_dpf_work_duration            IN     per_deployment_factors.work_duration%TYPE
,p_dpf_work_schedule            IN     per_deployment_factors.work_schedule%TYPE
,p_dpf_work_hours               IN     per_deployment_factors.work_hours%TYPE
,p_dpf_fte_capacity             IN     per_deployment_factors.fte_capacity%TYPE
,p_visit_internationally        IN     per_deployment_factors.visit_internationally%TYPE
,p_only_current_location        IN     per_deployment_factors.only_current_location%TYPE
,p_no_country1                  IN     per_deployment_factors.no_country1%TYPE
,p_no_country2                  IN     per_deployment_factors.no_country2%TYPE
,p_no_country3                  IN     per_deployment_factors.no_country3%TYPE
,p_earliest_available_date      IN     per_deployment_factors.earliest_available_date%TYPE
,p_available_for_transfer       IN     per_deployment_factors.available_for_transfer%TYPE
,p_relocation_preference        IN     per_deployment_factors.relocation_preference%TYPE
,p_dpf_object_version_number    IN OUT NOCOPY per_deployment_factors.object_version_number%TYPE
,p_dpf_attribute_category       IN     per_deployment_factors.attribute_category%TYPE
,p_dpf_attribute1               IN     per_deployment_factors.attribute1%TYPE
,p_dpf_attribute2               IN     per_deployment_factors.attribute2%TYPE
,p_dpf_attribute3               IN     per_deployment_factors.attribute3%TYPE
,p_dpf_attribute4               IN     per_deployment_factors.attribute4%TYPE
,p_dpf_attribute5               IN     per_deployment_factors.attribute5%TYPE
,p_dpf_attribute6               IN     per_deployment_factors.attribute6%TYPE
,p_dpf_attribute7               IN     per_deployment_factors.attribute7%TYPE
,p_dpf_attribute8               IN     per_deployment_factors.attribute8%TYPE
,p_dpf_attribute9               IN     per_deployment_factors.attribute9%TYPE
,p_dpf_attribute10              IN     per_deployment_factors.attribute10%TYPE
,p_dpf_attribute11              IN     per_deployment_factors.attribute11%TYPE
,p_dpf_attribute12              IN     per_deployment_factors.attribute12%TYPE
,p_dpf_attribute13              IN     per_deployment_factors.attribute13%TYPE
,p_dpf_attribute14              IN     per_deployment_factors.attribute14%TYPE
,p_dpf_attribute15              IN     per_deployment_factors.attribute15%TYPE
,p_dpf_attribute16              IN     per_deployment_factors.attribute16%TYPE
,p_dpf_attribute17              IN     per_deployment_factors.attribute17%TYPE
,p_dpf_attribute18              IN     per_deployment_factors.attribute18%TYPE
,p_dpf_attribute19              IN     per_deployment_factors.attribute19%TYPE
,p_dpf_attribute20              IN     per_deployment_factors.attribute20%TYPE
,p_chk1_checklist_item_id       IN OUT NOCOPY per_checklist_items.checklist_item_id%TYPE
,p_chk1_item_code               IN     per_checklist_items.item_code%TYPE
,p_chk1_date_due                IN     per_checklist_items.date_due%TYPE
,p_chk1_date_done               IN     per_checklist_items.date_done%TYPE
,p_chk1_status                  IN     per_checklist_items.status%TYPE
,p_chk1_notes                   IN     per_checklist_items.notes%TYPE
,p_chk1_object_version_number   IN OUT NOCOPY per_checklist_items.object_version_number%TYPE
,p_chk2_checklist_item_id       IN OUT NOCOPY per_checklist_items.checklist_item_id%TYPE
,p_chk2_item_code               IN     per_checklist_items.item_code%TYPE
,p_chk2_date_due                IN     per_checklist_items.date_due%TYPE
,p_chk2_date_done               IN     per_checklist_items.date_done%TYPE
,p_chk2_status                  IN     per_checklist_items.status%TYPE
,p_chk2_notes                   IN     per_checklist_items.notes%TYPE
,p_chk2_object_version_number   IN OUT NOCOPY per_checklist_items.object_version_number%TYPE
,p_chk3_checklist_item_id       IN OUT NOCOPY per_checklist_items.checklist_item_id%TYPE
,p_chk3_item_code               IN     per_checklist_items.item_code%TYPE
,p_chk3_date_due                IN     per_checklist_items.date_due%TYPE
,p_chk3_date_done               IN     per_checklist_items.date_done%TYPE
,p_chk3_status                  IN     per_checklist_items.status%TYPE
,p_chk3_notes                   IN     per_checklist_items.notes%TYPE
,p_chk3_object_version_number   IN OUT NOCOPY per_checklist_items.object_version_number%TYPE
,p_chk4_checklist_item_id       IN OUT NOCOPY per_checklist_items.checklist_item_id%TYPE
,p_chk4_item_code               IN     per_checklist_items.item_code%TYPE
,p_chk4_date_due                IN     per_checklist_items.date_due%TYPE
,p_chk4_date_done               IN     per_checklist_items.date_done%TYPE
,p_chk4_status                  IN     per_checklist_items.status%TYPE
,p_chk4_notes                   IN     per_checklist_items.notes%TYPE
,p_chk4_object_version_number   IN OUT NOCOPY per_checklist_items.object_version_number%TYPE
,p_chk5_checklist_item_id       IN OUT NOCOPY per_checklist_items.checklist_item_id%TYPE
,p_chk5_item_code               IN     per_checklist_items.item_code%TYPE
,p_chk5_date_due                IN     per_checklist_items.date_due%TYPE
,p_chk5_date_done               IN     per_checklist_items.date_done%TYPE
,p_chk5_status                  IN     per_checklist_items.status%TYPE
,p_chk5_notes                   IN     per_checklist_items.notes%TYPE
,p_chk5_object_version_number   IN OUT NOCOPY per_checklist_items.object_version_number%TYPE
,p_chk6_checklist_item_id       IN OUT NOCOPY per_checklist_items.checklist_item_id%TYPE
,p_chk6_item_code               IN     per_checklist_items.item_code%TYPE
,p_chk6_date_due                IN     per_checklist_items.date_due%TYPE
,p_chk6_date_done               IN     per_checklist_items.date_done%TYPE
,p_chk6_status                  IN     per_checklist_items.status%TYPE
,p_chk6_notes                   IN     per_checklist_items.notes%TYPE
,p_chk6_object_version_number   IN OUT NOCOPY per_checklist_items.object_version_number%TYPE
,p_chk7_checklist_item_id       IN OUT NOCOPY per_checklist_items.checklist_item_id%TYPE
,p_chk7_item_code               IN     per_checklist_items.item_code%TYPE
,p_chk7_date_due                IN     per_checklist_items.date_due%TYPE
,p_chk7_date_done               IN     per_checklist_items.date_done%TYPE
,p_chk7_status                  IN     per_checklist_items.status%TYPE
,p_chk7_notes                   IN     per_checklist_items.notes%TYPE
,p_chk7_object_version_number   IN OUT NOCOPY per_checklist_items.object_version_number%TYPE
,p_chk8_checklist_item_id       IN OUT NOCOPY per_checklist_items.checklist_item_id%TYPE
,p_chk8_item_code               IN     per_checklist_items.item_code%TYPE
,p_chk8_date_due                IN     per_checklist_items.date_due%TYPE
,p_chk8_date_done               IN     per_checklist_items.date_done%TYPE
,p_chk8_status                  IN     per_checklist_items.status%TYPE
,p_chk8_notes                   IN     per_checklist_items.notes%TYPE
,p_chk8_object_version_number   IN OUT NOCOPY per_checklist_items.object_version_number%TYPE
,p_chk9_checklist_item_id       IN OUT NOCOPY per_checklist_items.checklist_item_id%TYPE
,p_chk9_item_code               IN     per_checklist_items.item_code%TYPE
,p_chk9_date_due                IN     per_checklist_items.date_due%TYPE
,p_chk9_date_done               IN     per_checklist_items.date_done%TYPE
,p_chk9_status                  IN     per_checklist_items.status%TYPE
,p_chk9_notes                   IN     per_checklist_items.notes%TYPE
,p_chk9_object_version_number   IN OUT NOCOPY per_checklist_items.object_version_number%TYPE
,p_chk10_checklist_item_id      IN OUT NOCOPY per_checklist_items.checklist_item_id%TYPE
,p_chk10_item_code              IN     per_checklist_items.item_code%TYPE
,p_chk10_date_due               IN     per_checklist_items.date_due%TYPE
,p_chk10_date_done              IN     per_checklist_items.date_done%TYPE
,p_chk10_status                 IN     per_checklist_items.status%TYPE
,p_chk10_notes                  IN     per_checklist_items.notes%TYPE
,p_chk10_object_version_number  IN OUT NOCOPY per_checklist_items.object_version_number%TYPE
,p_tax_effective_start_date     IN OUT NOCOPY DATE
,p_tax_effective_end_date       IN OUT NOCOPY DATE
,p_tax_field1                   IN OUT NOCOPY VARCHAR2
,p_tax_field2                   IN OUT NOCOPY VARCHAR2
,p_tax_field3                   IN OUT NOCOPY VARCHAR2
,p_tax_field4                   IN OUT NOCOPY VARCHAR2
,p_tax_field5                   IN OUT NOCOPY VARCHAR2
,p_tax_field6                   IN OUT NOCOPY VARCHAR2
,p_tax_field7                   IN OUT NOCOPY VARCHAR2
,p_tax_field8                   IN OUT NOCOPY VARCHAR2
,p_tax_field9                   IN OUT NOCOPY VARCHAR2
,p_tax_field10                  IN OUT NOCOPY VARCHAR2
,p_tax_field11                  IN OUT NOCOPY VARCHAR2
,p_tax_field12                  IN OUT NOCOPY VARCHAR2
,p_tax_field13                  IN OUT NOCOPY VARCHAR2
,p_tax_field14                  IN OUT NOCOPY VARCHAR2
,p_tax_field15                  IN OUT NOCOPY VARCHAR2
,p_tax_field16                  IN OUT NOCOPY VARCHAR2
,p_tax_field17                  IN OUT NOCOPY VARCHAR2
,p_tax_field18                  IN OUT NOCOPY VARCHAR2
,p_tax_field19                  IN OUT NOCOPY VARCHAR2
,p_tax_field20                  IN OUT NOCOPY VARCHAR2
,p_tax_field21                  IN OUT NOCOPY VARCHAR2
,p_tax_field22                  IN OUT NOCOPY VARCHAR2
,p_tax_field23                  IN OUT NOCOPY VARCHAR2
,p_tax_field24                  IN OUT NOCOPY VARCHAR2
,p_tax_field25                  IN OUT NOCOPY VARCHAR2
,p_tax_field26                  IN OUT NOCOPY VARCHAR2
,p_tax_field27                  IN OUT NOCOPY VARCHAR2
,p_tax_field28                  IN OUT NOCOPY VARCHAR2
,p_tax_field29                  IN OUT NOCOPY VARCHAR2
,p_tax_field30                  IN OUT NOCOPY VARCHAR2
,p_tax_field31                  IN OUT NOCOPY VARCHAR2
,p_tax_field32                  IN OUT NOCOPY VARCHAR2
,p_tax_field33                  IN OUT NOCOPY VARCHAR2
,p_tax_field34                  IN OUT NOCOPY VARCHAR2
,p_tax_field35                  IN OUT NOCOPY VARCHAR2
,p_tax_field36                  IN OUT NOCOPY VARCHAR2
,p_tax_field37                  IN OUT NOCOPY VARCHAR2
,p_tax_field38                  IN OUT NOCOPY VARCHAR2
,p_tax_field39                  IN OUT NOCOPY VARCHAR2
,p_tax_field40                  IN OUT NOCOPY VARCHAR2
,p_tax_field41                  IN OUT NOCOPY VARCHAR2
,p_tax_field42                  IN OUT NOCOPY VARCHAR2
,p_tax_field43                  IN OUT NOCOPY VARCHAR2
,p_tax_field44                  IN OUT NOCOPY VARCHAR2
,p_tax_field45                  IN OUT NOCOPY VARCHAR2
,p_tax_field46                  IN OUT NOCOPY VARCHAR2
,p_tax_field47                  IN OUT NOCOPY VARCHAR2
,p_tax_field48                  IN OUT NOCOPY VARCHAR2
,p_tax_field49                  IN OUT NOCOPY VARCHAR2
,p_tax_field50                  IN OUT NOCOPY VARCHAR2
,p_tax_field51                  IN OUT NOCOPY VARCHAR2
,p_tax_field52                  IN OUT NOCOPY VARCHAR2
,p_tax_field53                  IN OUT NOCOPY VARCHAR2
,p_tax_field54                  IN OUT NOCOPY VARCHAR2
,p_tax_field55                  IN OUT NOCOPY VARCHAR2
,p_tax_field56                  IN OUT NOCOPY VARCHAR2
,p_tax_field57                  IN OUT NOCOPY VARCHAR2
,p_tax_field58                  IN OUT NOCOPY VARCHAR2
,p_tax_field59                  IN OUT NOCOPY VARCHAR2
,p_tax_field60                  IN OUT NOCOPY VARCHAR2
,p_tax_field61                  IN OUT NOCOPY VARCHAR2
,p_tax_field62                  IN OUT NOCOPY VARCHAR2
,p_tax_field63                  IN OUT NOCOPY VARCHAR2
,p_tax_field64                  IN OUT NOCOPY VARCHAR2
,p_tax_field65                  IN OUT NOCOPY VARCHAR2
,p_tax_field66                  IN OUT NOCOPY VARCHAR2
,p_tax_field67                  IN OUT NOCOPY VARCHAR2
,p_tax_field68                  IN OUT NOCOPY VARCHAR2
,p_tax_field69                  IN OUT NOCOPY VARCHAR2
,p_tax_field70                  IN OUT NOCOPY VARCHAR2
,p_tax_field71                  IN OUT NOCOPY VARCHAR2
,p_tax_field72                  IN OUT NOCOPY VARCHAR2
,p_tax_field73                  IN OUT NOCOPY VARCHAR2
,p_tax_field74                  IN OUT NOCOPY VARCHAR2
,p_tax_field75                  IN OUT NOCOPY VARCHAR2
,p_tax_field76                  IN OUT NOCOPY VARCHAR2
,p_tax_field77                  IN OUT NOCOPY VARCHAR2
,p_tax_field78                  IN OUT NOCOPY VARCHAR2
,p_tax_field79                  IN OUT NOCOPY VARCHAR2
,p_tax_field80                  IN OUT NOCOPY VARCHAR2
,p_tax_field81                  IN OUT NOCOPY VARCHAR2
,p_tax_field82                  IN OUT NOCOPY VARCHAR2
,p_tax_field83                  IN OUT NOCOPY VARCHAR2
,p_tax_field84                  IN OUT NOCOPY VARCHAR2
,p_tax_field85                  IN OUT NOCOPY VARCHAR2
,p_tax_field86                  IN OUT NOCOPY VARCHAR2
,p_tax_field87                  IN OUT NOCOPY VARCHAR2
,p_tax_field88                  IN OUT NOCOPY VARCHAR2
,p_tax_field89                  IN OUT NOCOPY VARCHAR2
,p_tax_field90                  IN OUT NOCOPY VARCHAR2
,p_tax_field91                  IN OUT NOCOPY VARCHAR2
,p_tax_field92                  IN OUT NOCOPY VARCHAR2
,p_tax_field93                  IN OUT NOCOPY VARCHAR2
,p_tax_field94                  IN OUT NOCOPY VARCHAR2
,p_tax_field95                  IN OUT NOCOPY VARCHAR2
,p_tax_field96                  IN OUT NOCOPY VARCHAR2
,p_tax_field97                  IN OUT NOCOPY VARCHAR2
,p_tax_field98                  IN OUT NOCOPY VARCHAR2
,p_tax_field99                  IN OUT NOCOPY VARCHAR2
,p_tax_field100                 IN OUT NOCOPY VARCHAR2
,p_tax_field101                 IN OUT NOCOPY VARCHAR2
,p_tax_field102                 IN OUT NOCOPY VARCHAR2
,p_tax_field103                 IN OUT NOCOPY VARCHAR2
,p_tax_field104                 IN OUT NOCOPY VARCHAR2
,p_tax_field105                 IN OUT NOCOPY VARCHAR2
,p_tax_field106                 IN OUT NOCOPY VARCHAR2
,p_tax_field107                 IN OUT NOCOPY VARCHAR2
,p_tax_field108                 IN OUT NOCOPY VARCHAR2
,p_tax_field109                 IN OUT NOCOPY VARCHAR2
,p_tax_field110                 IN OUT NOCOPY VARCHAR2
,p_tax_field111                 IN OUT NOCOPY VARCHAR2
,p_tax_field112                 IN OUT NOCOPY VARCHAR2
,p_tax_field113                 IN OUT NOCOPY VARCHAR2
,p_tax_field114                 IN OUT NOCOPY VARCHAR2
,p_tax_field115                 IN OUT NOCOPY VARCHAR2
,p_tax_field116                 IN OUT NOCOPY VARCHAR2
,p_tax_field117                 IN OUT NOCOPY VARCHAR2
,p_tax_field118                 IN OUT NOCOPY VARCHAR2
,p_tax_field119                 IN OUT NOCOPY VARCHAR2
,p_tax_field120                 IN OUT NOCOPY VARCHAR2
,p_tax_field121                 IN OUT NOCOPY VARCHAR2
,p_tax_field122                 IN OUT NOCOPY VARCHAR2
,p_tax_field123                 IN OUT NOCOPY VARCHAR2
,p_tax_field124                 IN OUT NOCOPY VARCHAR2
,p_tax_field125                 IN OUT NOCOPY VARCHAR2
,p_tax_field126                 IN OUT NOCOPY VARCHAR2
,p_tax_field127                 IN OUT NOCOPY VARCHAR2
,p_tax_field128                 IN OUT NOCOPY VARCHAR2
,p_tax_field129                 IN OUT NOCOPY VARCHAR2
,p_tax_field130                 IN OUT NOCOPY VARCHAR2
,p_tax_field131                 IN OUT NOCOPY VARCHAR2
,p_tax_field132                 IN OUT NOCOPY VARCHAR2
,p_tax_field133                 IN OUT NOCOPY VARCHAR2
,p_tax_field134                 IN OUT NOCOPY VARCHAR2
,p_tax_field135                 IN OUT NOCOPY VARCHAR2
,p_tax_field136                 IN OUT NOCOPY VARCHAR2
,p_tax_field137                 IN OUT NOCOPY VARCHAR2
,p_tax_field138                 IN OUT NOCOPY VARCHAR2
,p_tax_field139                 IN OUT NOCOPY VARCHAR2
,p_tax_field140                 IN OUT NOCOPY VARCHAR2
-- Bug 3357807 Start Here
,p_tax_field141                 IN OUT NOCOPY DATE
,p_tax_field142                 IN OUT NOCOPY DATE
,p_tax_field143                 IN OUT NOCOPY DATE
,p_tax_field144                 IN OUT NOCOPY DATE
,p_tax_field145                 IN OUT NOCOPY DATE
,p_tax_field146                 IN OUT NOCOPY DATE
,p_tax_field147                 IN OUT NOCOPY DATE
,p_tax_field148                 IN OUT NOCOPY DATE
,p_tax_field149                 IN OUT NOCOPY DATE
,p_tax_field150                 IN OUT NOCOPY DATE
-- Bug 3357807 End Here
,p_tax_update_allowed           IN OUT NOCOPY VARCHAR2
,p_orig_hire_warning               OUT NOCOPY BOOLEAN
,p_assign_payroll_warning          OUT NOCOPY BOOLEAN
,p_org_now_no_manager_warning      OUT NOCOPY BOOLEAN
,p_other_manager_warning           OUT NOCOPY BOOLEAN
,p_spp_delete_warning              OUT NOCOPY BOOLEAN
,p_entries_changed_warning         OUT NOCOPY VARCHAR2
,p_tax_district_changed_warning    OUT NOCOPY BOOLEAN
,p_proposed_salary_warning         OUT NOCOPY BOOLEAN
,p_approved_warning                OUT NOCOPY BOOLEAN
,p_payroll_warning                 OUT NOCOPY BOOLEAN
,p_gsp_post_process_warning        OUT NOCOPY VARCHAR2
);
--
PROCEDURE lock_maintain_data
(p_effective_date                DATE
,p_datetrack_update_mode         VARCHAR2
,p_person_update_allowed         VARCHAR2 DEFAULT 'TRUE'
,p_person_id                     per_all_people_f.person_id%TYPE
,p_per_effective_start_date      per_all_people_f.effective_start_date%TYPE
,p_per_effective_end_date        per_all_people_f.effective_end_date%TYPE
,p_per_validation_start_date     OUT NOCOPY DATE
,p_per_validation_end_date       OUT NOCOPY DATE
,p_per_object_version_number     per_all_people_f.object_version_number%TYPE
--CWK
,p_placement_date_start          per_periods_of_placement.date_start%TYPE
,p_pdp_object_version_number     per_periods_of_placement.object_version_number%TYPE
,p_grade_rule_id                 pay_grade_rules_f.grade_rule_id%TYPE
,p_rate_effective_start_date     pay_grade_rules_f.effective_start_date%TYPE
,p_rate_effective_end_date       pay_grade_rules_f.effective_end_date%TYPE
,p_rate_object_version_number    pay_grade_rules_f.object_version_number%TYPE
--
,p_assignment_update_allowed     VARCHAR2 DEFAULT 'TRUE'
,p_assignment_id                 per_all_assignments_f.assignment_id%TYPE
,p_asg_effective_start_date      per_all_assignments_f.effective_start_date%TYPE
,p_asg_effective_end_date        per_all_assignments_f.effective_end_date%TYPE
,p_asg_validation_start_date     OUT NOCOPY DATE
,p_asg_validation_end_date       OUT NOCOPY DATE
,p_asg_object_version_number     per_all_assignments_f.object_version_number%TYPE
,p_application_id                per_applications.application_id%TYPE
,p_app_object_version_number     per_applications.object_version_number%TYPE
,p_pds_object_version_number     per_periods_of_service.object_version_number%TYPE
,p_pds_hire_date                 per_periods_of_service.date_start%TYPE
,p_address_id                    per_addresses.address_id%TYPE
,p_addr_object_version_number    per_addresses.object_version_number%TYPE
,p_phn_h_phone_id                per_phones.phone_id%TYPE
,p_phn_h_object_version_number   per_phones.object_version_number%TYPE
,p_phn_w_phone_id                per_phones.phone_id%TYPE
,p_phn_w_object_version_number   per_phones.object_version_number%TYPE
,p_phn_m_phone_id                per_phones.phone_id%TYPE
,p_phn_m_object_version_number   per_phones.object_version_number%TYPE
,p_phn_hf_phone_id               per_phones.phone_id%TYPE
,p_phn_hf_object_version_number  per_phones.object_version_number%TYPE
,p_phn_wf_phone_id               per_phones.phone_id%TYPE
,p_phn_wf_object_version_number  per_phones.object_version_number%TYPE
,p_pay_proposal_id               per_pay_proposals.pay_proposal_id%TYPE
,p_pyp_object_version_number     per_pay_proposals.object_version_number%TYPE
,p_deployment_factor_id          per_deployment_factors.deployment_factor_id%TYPE
,p_dpf_object_version_number     per_deployment_factors.object_version_number%TYPE
,p_chk1_checklist_item_id        per_checklist_items.checklist_item_id%TYPE
,p_chk1_object_version_number    per_checklist_items.object_version_number%TYPE
,p_chk2_checklist_item_id        per_checklist_items.checklist_item_id%TYPE
,p_chk2_object_version_number    per_checklist_items.object_version_number%TYPE
,p_chk3_checklist_item_id        per_checklist_items.checklist_item_id%TYPE
,p_chk3_object_version_number    per_checklist_items.object_version_number%TYPE
,p_chk4_checklist_item_id        per_checklist_items.checklist_item_id%TYPE
,p_chk4_object_version_number    per_checklist_items.object_version_number%TYPE
,p_chk5_checklist_item_id        per_checklist_items.checklist_item_id%TYPE
,p_chk5_object_version_number    per_checklist_items.object_version_number%TYPE
,p_chk6_checklist_item_id        per_checklist_items.checklist_item_id%TYPE
,p_chk6_object_version_number    per_checklist_items.object_version_number%TYPE
,p_chk7_checklist_item_id        per_checklist_items.checklist_item_id%TYPE
,p_chk7_object_version_number    per_checklist_items.object_version_number%TYPE
,p_chk8_checklist_item_id        per_checklist_items.checklist_item_id%TYPE
,p_chk8_object_version_number    per_checklist_items.object_version_number%TYPE
,p_chk9_checklist_item_id        per_checklist_items.checklist_item_id%TYPE
,p_chk9_object_version_number    per_checklist_items.object_version_number%TYPE
,p_chk10_checklist_item_id       per_checklist_items.checklist_item_id%TYPE
,p_chk10_object_version_number   per_checklist_items.object_version_number%TYPE
);
END;

/
