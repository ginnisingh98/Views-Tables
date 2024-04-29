--------------------------------------------------------
--  DDL for Package Body PER_QH_MAINTAIN_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_QH_MAINTAIN_UPDATE" AS
/* $Header: peqhmnti.pkb 120.10.12010000.3 2009/07/10 11:57:08 varanjan ship $ */
--
-- Package Variables
--
g_package  VARCHAR2(33) := '  per_qh_maintain_update.';
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
,p_hire_date                    IN OUT NOCOPY per_periods_of_service.date_start%TYPE  -- Bug 3975241
--CWK
,p_current_npw_flag             IN     per_all_people_f.current_npw_flag%TYPE
,p_npw_number                   IN OUT NOCOPY per_all_people_f.npw_number%TYPE
,p_placement_date_start         IN OUT NOCOPY per_all_assignments_f.period_of_placement_date_start%TYPE  -- Bug 4287925
,p_projected_assignment_end     IN     per_all_assignments_f.projected_assignment_end%TYPE
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
,p_party_id                     IN     per_all_people_f.party_id%TYPE DEFAULT NULL
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
) IS
--
  l_person_id NUMBER;
  l_per_object_version_number       per_all_people_f.object_version_number%TYPE;
  l_pdp_object_version_number       per_periods_of_placement.object_version_number%TYPE;
  l_employee_number                 per_all_people_f.employee_number%TYPE;
  l_applicant_number                per_all_people_f.applicant_number%TYPE;
  l_npw_number                      per_all_people_f.npw_number%TYPE;
  l_per_effective_start_date        DATE;
  l_per_effective_end_date          DATE;
  l_per_validation_start_date       DATE;
  l_per_validation_end_date         DATE;
  l_full_name                       per_all_people_f.full_name%TYPE;
  l_comment_id                      NUMBER;
  l_name_combination_warning        BOOLEAN;
  l_assign_payroll_warning          BOOLEAN;
  l_orig_hire_warning               BOOLEAN;
--
  l_assignment_id NUMBER;
  l_asg_object_version_number per_all_assignments_f.object_version_number%TYPE;
  l_special_ceiling_step_id per_all_assignments_f.special_ceiling_step_id%TYPE;
  l_assignment_sequence per_all_assignments_f.assignment_sequence%TYPE;
  l_assignment_number per_all_assignments_f.assignment_number%TYPE;
  l_group_name                      VARCHAR2(240);
  l_asg_effective_start_date        DATE;
  l_asg_effective_end_date          DATE;
  l_asg_validation_start_date       DATE;
  l_asg_validation_end_date         DATE;
  l_people_group_id                 NUMBER;
  l_hourly_salaried_warning         BOOLEAN;
  l_org_now_no_manager_warning      BOOLEAN;
  l_other_manager_warning           BOOLEAN;
  l_spp_delete_warning              BOOLEAN;
  l_entries_changed_warning         VARCHAR2(30);
  l_tax_district_changed_warning    BOOLEAN;
  l_cagr_grade_def_id               NUMBER;
  l_cagr_concatenated_segments      VARCHAR2(240);
--
  l_concatenated_segments           hr_soft_coding_keyflex.concatenated_segments%TYPE;
  l_soft_coding_keyflex_id          NUMBER;
  l_no_managers_warning             BOOLEAN;
  l_other_manager_warning2          BOOLEAN;
--
  l_pgp_rec pay_people_groups%ROWTYPE;
  l_scl_rec hr_soft_coding_keyflex%ROWTYPE;
--
  l_app_object_version_number per_applications.object_version_number%TYPE;
  l_application_id per_applications.application_id%TYPE;
--
  l_address_id per_addresses.address_id%TYPE;
  l_addr_object_version_number per_addresses.object_version_number%TYPE;
--
  l_phone_id per_phones.phone_id%TYPE;
  l_phn_object_version_number per_phones.object_version_number%TYPE;
--
  l_deployment_factor_id per_deployment_factors.deployment_factor_id%TYPE;
  l_dpf_object_version_number per_deployment_factors.object_version_number%TYPE;
  l_pay_proposal_id per_pay_proposals.pay_proposal_id%TYPE;
  l_pyp_object_version_number per_pay_proposals.object_version_number%TYPE;
  l_element_entry_id             pay_element_entries_f.element_entry_id%TYPE;
  l_inv_next_sal_date_warning	 BOOLEAN;
  l_proposed_salary_warning      BOOLEAN;
  l_approved_warning             BOOLEAN;
  l_payroll_warning		 BOOLEAN;
--
  l_checklist_item_id per_checklist_items.checklist_item_id%TYPE;
  l_chk_object_version_number per_checklist_items.object_version_number%TYPE;
--
  l_grade_rule_id               pay_grade_rules_f.grade_rule_id%TYPE;
  l_rate_effective_start_date   pay_grade_rules_f.effective_start_date%TYPE;
  l_rate_effective_end_date     pay_grade_rules_f.effective_end_date%TYPE;
  l_rate_object_version_number  pay_grade_rules_f.object_version_number%TYPE;
--
  l_dummy_n NUMBER;
  l_dummy_v VARCHAR2(240);
  l_dummy_d DATE;
  l_datetrack_update_mode VARCHAR2(30):='CORRECTION';
  l_creation_date DATE;
  l_pos_id  NUMBER;
  l_pos_ovn NUMBER;
--
  l_gsp_post_process_warning   varchar2(30);
  l_gsp_post_process_warning2  varchar2(30);
--
l_proc VARCHAR2(72) := g_package||'insert_maintain_data';
BEGIN
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  hr_utility.set_location('Insert Enter:' || fnd_profile.value('PER_ORGANIZATION_ID'), 13163);
  per_qh_maintain_update.p_qh_organization_id := NULL;   --- Added For Bug # 6706502

  SAVEPOINT insert_maintain_data;
  --  support "future hires", especially necessary for HR Foundation.
  l_cagr_grade_def_id:=p_cagr_grade_def_id;  -- Bug 3484602
  IF p_system_person_type = 'EMP' then
     l_creation_date := nvl(p_hire_date,p_effective_date);
  ELSIF p_system_person_type = 'APL' then
-- Bug 3900299 Starts Here
     l_creation_date := nvl(p_app_date_received,p_effective_date);
-- Bug 3900299 Ends Here
  ELSIF p_system_person_type = 'CWK' then
     l_creation_date := nvl(p_placement_date_start,p_effective_date);
  END IF;
  --
  IF p_system_person_type='EMP' THEN
    hr_utility.set_location(l_proc, 30);
    hr_utility.set_location('Insert EMP Before:' || fnd_profile.value('PER_ORGANIZATION_ID'), 13163);
    l_employee_number:=p_employee_number;
    hr_employee_api.create_employee
      (p_hire_date                    => l_creation_date  --p_effective_date
      ,p_business_group_id            => p_business_group_id
      ,p_last_name                    => p_last_name
      ,p_sex                          => p_sex
      ,p_person_type_id               => p_person_type_id
      ,p_date_employee_data_verified  => p_date_employee_data_verified
      ,p_date_of_birth                => p_date_of_birth
      ,p_email_address                => p_email_address
      ,p_employee_number              => l_employee_number
      ,p_expense_check_send_to_addres => p_expense_check_send_to_addres
      ,p_first_name                   => p_first_name
      ,p_known_as                     => p_known_as
      ,p_marital_status               => p_marital_status
      ,p_middle_names                 => p_middle_names
      ,p_nationality                  => p_nationality
      ,p_national_identifier          => p_national_identifier
      ,p_previous_last_name           => p_previous_last_name
      ,p_registered_disabled_flag     => p_registered_disabled_flag
      ,p_title                        => p_title
      ,p_attribute_category           => p_attribute_category
      ,p_attribute1                   => p_attribute1
      ,p_attribute2                   => p_attribute2
      ,p_attribute3                   => p_attribute3
      ,p_attribute4                   => p_attribute4
      ,p_attribute5                   => p_attribute5
      ,p_attribute6                   => p_attribute6
      ,p_attribute7                   => p_attribute7
      ,p_attribute8                   => p_attribute8
      ,p_attribute9                   => p_attribute9
      ,p_attribute10                  => p_attribute10
      ,p_attribute11                  => p_attribute11
      ,p_attribute12                  => p_attribute12
      ,p_attribute13                  => p_attribute13
      ,p_attribute14                  => p_attribute14
      ,p_attribute15                  => p_attribute15
      ,p_attribute16                  => p_attribute16
      ,p_attribute17                  => p_attribute17
      ,p_attribute18                  => p_attribute18
      ,p_attribute19                  => p_attribute19
      ,p_attribute20                  => p_attribute20
      ,p_attribute21                  => p_attribute21
      ,p_attribute22                  => p_attribute22
      ,p_attribute23                  => p_attribute23
      ,p_attribute24                  => p_attribute24
      ,p_attribute25                  => p_attribute25
      ,p_attribute26                  => p_attribute26
      ,p_attribute27                  => p_attribute27
      ,p_attribute28                  => p_attribute28
      ,p_attribute29                  => p_attribute29
      ,p_attribute30                  => p_attribute30
      ,p_per_information_category     => p_per_information_category
      ,p_per_information1             => p_per_information1
      ,p_per_information2             => p_per_information2
      ,p_per_information3             => p_per_information3
      ,p_per_information4             => p_per_information4
      ,p_per_information5             => p_per_information5
      ,p_per_information6             => p_per_information6
      ,p_per_information7             => p_per_information7
      ,p_per_information8             => p_per_information8
      ,p_per_information9             => p_per_information9
      ,p_per_information10            => p_per_information10
      ,p_per_information11            => p_per_information11
      ,p_per_information12            => p_per_information12
      ,p_per_information13            => p_per_information13
      ,p_per_information14            => p_per_information14
      ,p_per_information15            => p_per_information15
      ,p_per_information16            => p_per_information16
      ,p_per_information17            => p_per_information17
      ,p_per_information18            => p_per_information18
      ,p_per_information19            => p_per_information19
      ,p_per_information20            => p_per_information20
      ,p_per_information21            => p_per_information21
      ,p_per_information22            => p_per_information22
      ,p_per_information23            => p_per_information23
      ,p_per_information24            => p_per_information24
      ,p_per_information25            => p_per_information25
      ,p_per_information26            => p_per_information26
      ,p_per_information27            => p_per_information27
      ,p_per_information28            => p_per_information28
      ,p_per_information29            => p_per_information29
      ,p_per_information30            => p_per_information30
      ,p_date_of_death                => p_date_of_death
      ,p_background_check_status      => p_background_check_status
      ,p_background_date_check        => p_background_date_check
      ,p_blood_type                   => p_blood_type
      ,p_correspondence_language      => p_correspondence_language
      ,p_fte_capacity                 => p_per_fte_capacity
      ,p_honors                       => p_honors
      ,p_internal_location            => p_internal_location
      ,p_last_medical_test_by         => p_last_medical_test_by
      ,p_last_medical_test_date       => p_last_medical_test_date
      ,p_mailstop                     => p_mailstop
      ,p_office_number                => p_office_number
      ,p_on_military_service          => p_on_military_service
      ,p_pre_name_adjunct             => p_pre_name_adjunct
      ,p_rehire_recommendation	      => p_rehire_recommendation  -- Bug 3210500
      ,p_resume_exists                => p_resume_exists
      ,p_resume_last_updated          => p_resume_last_updated
      ,p_second_passport_exists       => p_second_passport_exists
      ,p_student_status               => p_student_status
      ,p_work_schedule                => p_work_schedule
      ,p_suffix                       => p_suffix
      ,p_benefit_group_id             => p_benefit_group_id
      ,p_receipt_of_death_cert_date   => p_receipt_of_death_cert_date
      ,p_coord_ben_med_pln_no         => p_coord_ben_med_pln_no
      ,p_coord_ben_no_cvg_flag        => p_coord_ben_no_cvg_flag
      ,p_uses_tobacco_flag            => p_uses_tobacco_flag
      ,p_dpdnt_adoption_date          => p_dpdnt_adoption_date
      ,p_dpdnt_vlntry_svce_flag       => p_dpdnt_vlntry_svce_flag
      ,p_original_date_of_hire        => p_original_date_of_hire
      ,p_adjusted_svc_date            => p_adjusted_svc_date
      ,p_town_of_birth                => p_town_of_birth
      ,p_region_of_birth              => p_region_of_birth
      ,p_country_of_birth             => p_country_of_birth
      ,p_party_id                     => p_party_id
      ,p_fast_path_employee           => p_fast_path_employee
      ,p_person_id                    => l_person_id
      ,p_assignment_id                => l_assignment_id
      ,p_per_object_version_number    => l_per_object_version_number
      ,p_asg_object_version_number    => l_asg_object_version_number
      ,p_per_effective_start_date     => l_per_effective_start_date
      ,p_per_effective_end_date       => l_per_effective_end_date
      ,p_full_name                    => l_full_name
      ,p_per_comment_id               => l_comment_id
      ,p_assignment_sequence          => l_assignment_sequence
      ,p_assignment_number            => l_assignment_number
      ,p_name_combination_warning     => l_name_combination_warning
      ,p_assign_payroll_warning       => l_assign_payroll_warning
      ,p_orig_hire_warning            => l_orig_hire_warning
      );
    p_hire_date := l_creation_date;     -- Bug 3975241
    hr_utility.set_location('Insert EMP After:' || fnd_profile.value('PER_ORGANIZATION_ID'), 13163);
    begin

      -- get the pds id id and ovn
      SELECT asg.period_of_service_id,
             pds.object_version_number
      INTO l_pos_id, l_pos_ovn
      FROM per_all_assignments_f asg, per_periods_of_service pds
      WHERE asg.assignment_id = l_assignment_id
      and asg.period_of_service_id = pds.period_of_service_id;

      p_period_of_service_id := l_pos_id;
      p_pds_object_version_number := l_pos_ovn;
    exception when others then
       null;
    end;

  ELSIF p_system_person_type='APL' THEN
    l_applicant_number:=p_applicant_number;
    hr_applicant_api.create_applicant
      (
       p_date_received                 => l_creation_date  --p_effective_date
      ,p_business_group_id             => p_business_group_id
      ,p_last_name                     => p_last_name
      ,p_person_type_id                => p_person_type_id
      ,p_applicant_number              => l_applicant_number
      ,p_date_employee_data_verified   => p_date_employee_data_verified
      ,p_date_of_birth                 => p_date_of_birth
      ,p_email_address                 => p_email_address
      ,p_expense_check_send_to_addres  => p_expense_check_send_to_addres
      ,p_first_name                    => p_first_name
      ,p_known_as                      => p_known_as
      ,p_marital_status                => p_marital_status
      ,p_middle_names                  => p_middle_names
      ,p_nationality                   => p_nationality
      ,p_national_identifier           => p_national_identifier
      ,p_previous_last_name            => p_previous_last_name
      ,p_registered_disabled_flag      => p_registered_disabled_flag
      ,p_sex                           => p_sex
      ,p_title                         => p_title
      ,p_attribute_category            => p_attribute_category
      ,p_attribute1                    => p_attribute1
      ,p_attribute2                    => p_attribute2
      ,p_attribute3                    => p_attribute3
      ,p_attribute4                    => p_attribute4
      ,p_attribute5                    => p_attribute5
      ,p_attribute6                    => p_attribute6
      ,p_attribute7                    => p_attribute7
      ,p_attribute8                    => p_attribute8
      ,p_attribute9                    => p_attribute9
      ,p_attribute10                   => p_attribute10
      ,p_attribute11                   => p_attribute11
      ,p_attribute12                   => p_attribute12
      ,p_attribute13                   => p_attribute13
      ,p_attribute14                   => p_attribute14
      ,p_attribute15                   => p_attribute15
      ,p_attribute16                   => p_attribute16
      ,p_attribute17                   => p_attribute17
      ,p_attribute18                   => p_attribute18
      ,p_attribute19                   => p_attribute19
      ,p_attribute20                   => p_attribute20
      ,p_attribute21                   => p_attribute21
      ,p_attribute22                   => p_attribute22
      ,p_attribute23                   => p_attribute23
      ,p_attribute24                   => p_attribute24
      ,p_attribute25                   => p_attribute25
      ,p_attribute26                   => p_attribute26
      ,p_attribute27                   => p_attribute27
      ,p_attribute28                   => p_attribute28
      ,p_attribute29                   => p_attribute29
      ,p_attribute30                   => p_attribute30
      ,p_per_information_category      => p_per_information_category
      ,p_per_information1              => p_per_information1
      ,p_per_information2              => p_per_information2
      ,p_per_information3              => p_per_information3
      ,p_per_information4              => p_per_information4
      ,p_per_information5              => p_per_information5
      ,p_per_information6              => p_per_information6
      ,p_per_information7              => p_per_information7
      ,p_per_information8              => p_per_information8
      ,p_per_information9              => p_per_information9
      ,p_per_information10             => p_per_information10
      ,p_per_information11             => p_per_information11
      ,p_per_information12             => p_per_information12
      ,p_per_information13             => p_per_information13
      ,p_per_information14             => p_per_information14
      ,p_per_information15             => p_per_information15
      ,p_per_information16             => p_per_information16
      ,p_per_information17             => p_per_information17
      ,p_per_information18             => p_per_information18
      ,p_per_information19             => p_per_information19
      ,p_per_information20             => p_per_information20
      ,p_per_information21             => p_per_information21
      ,p_per_information22             => p_per_information22
      ,p_per_information23             => p_per_information23
      ,p_per_information24             => p_per_information24
      ,p_per_information25             => p_per_information25
      ,p_per_information26             => p_per_information26
      ,p_per_information27             => p_per_information27
      ,p_per_information28             => p_per_information28
      ,p_per_information29             => p_per_information29
      ,p_per_information30             => p_per_information30
      ,p_background_check_status       => p_background_check_status
      ,p_background_date_check         => p_background_date_check
      ,p_correspondence_language       => p_correspondence_language
      ,p_fte_capacity                  => p_per_fte_capacity
      ,p_hold_applicant_date_until     => p_hold_applicant_date_until
      ,p_honors                        => p_honors
      ,p_mailstop                      => p_mailstop
      ,p_office_number                 => p_office_number
      ,p_on_military_service           => p_on_military_service
      ,p_pre_name_adjunct              => p_pre_name_adjunct
      ,p_resume_exists                 => p_resume_exists
      ,p_resume_last_updated           => p_resume_last_updated
      ,p_student_status                => p_student_status
      ,p_work_schedule                 => p_work_schedule
      ,p_suffix                        => p_suffix
      ,p_date_of_death                 => p_date_of_death
      ,p_benefit_group_id              => p_benefit_group_id
      ,p_receipt_of_death_cert_date    => p_receipt_of_death_cert_date
      ,p_coord_ben_med_pln_no          => p_coord_ben_med_pln_no
      ,p_coord_ben_no_cvg_flag         => p_coord_ben_no_cvg_flag
      ,p_uses_tobacco_flag             => p_uses_tobacco_flag
      ,p_dpdnt_adoption_date           => p_dpdnt_adoption_date
      ,p_dpdnt_vlntry_svce_flag        => p_dpdnt_vlntry_svce_flag
      ,p_original_date_of_hire         => p_original_date_of_hire
      ,p_town_of_birth                 => p_town_of_birth
      ,p_region_of_birth               => p_region_of_birth
      ,p_country_of_birth              => p_country_of_birth
      ,p_party_id                      => p_party_id
      ,p_vacancy_id                    => p_vacancy_id
      ,p_person_id                     => l_person_id
      ,p_assignment_id                 => l_assignment_id
      ,p_application_id                => l_application_id
      ,p_per_object_version_number     => l_per_object_version_number
      ,p_asg_object_version_number     => l_asg_object_version_number
      ,p_apl_object_version_number     => l_app_object_version_number
      ,p_per_effective_start_date      => l_per_effective_start_date
      ,p_per_effective_end_date        => l_per_effective_end_date
      ,p_full_name                     => l_full_name
      ,p_per_comment_id                => l_comment_id
      ,p_assignment_sequence           => l_assignment_sequence
      ,p_name_combination_warning      => l_name_combination_warning
      ,p_orig_hire_warning             => l_orig_hire_warning
      );
-- Bug 3900299 Starts Here
     p_app_date_received :=l_creation_date;
-- Bug 3900299 Ends Here
  ELSIF p_system_person_type='CWK' then
    l_npw_number := p_npw_number;
    hr_contingent_worker_api.create_cwk
      (p_start_date                   => l_creation_date  --p_effective_date
      ,p_business_group_id            => p_business_group_id
      ,p_last_name                    => p_last_name
      ,p_person_type_id               => p_person_type_id
      ,p_npw_number                   => l_npw_number
      ,p_background_check_status      => p_background_check_status
      ,p_background_date_check        => p_background_date_check
      ,p_blood_type                   => p_blood_type
      ,p_correspondence_language      => p_correspondence_language
      ,p_country_of_birth             => p_country_of_birth
      ,p_date_of_birth                => p_date_of_birth
      ,p_date_of_death                => p_date_of_death
      ,p_dpdnt_adoption_date          => p_dpdnt_adoption_date
      ,p_dpdnt_vlntry_svce_flag       => p_dpdnt_vlntry_svce_flag
      ,p_email_address                => p_email_address
      ,p_first_name                   => p_first_name
      ,p_fte_capacity                 => p_per_fte_capacity
      ,p_honors                       => p_honors
      ,p_internal_location            => p_internal_location
      ,p_known_as                     => p_known_as
      ,p_last_medical_test_by         => p_last_medical_test_by
      ,p_last_medical_test_date       => p_last_medical_test_date
      ,p_mailstop                     => p_mailstop
      ,p_marital_status               => p_marital_status
      ,p_middle_names                 => p_middle_names
      ,p_national_identifier          => p_national_identifier
      ,p_nationality                  => p_nationality
      ,p_office_number                => p_office_number
      ,p_on_military_service          => p_on_military_service
      ,p_pre_name_adjunct             => p_pre_name_adjunct
      ,p_previous_last_name           => p_previous_last_name
      ,p_projected_placement_end      => null
      ,p_receipt_of_death_cert_date   => p_receipt_of_death_cert_date
      ,p_region_of_birth              => p_region_of_birth
      ,p_registered_disabled_flag     => p_registered_disabled_flag
      ,p_resume_exists                => p_resume_exists
      ,p_resume_last_updated          => p_resume_last_updated
      ,p_second_passport_exists       => p_second_passport_exists
      ,p_sex                          => p_sex
      ,p_student_status               => p_student_status
      ,p_suffix                       => p_suffix
      ,p_title                        => p_title
      ,p_town_of_birth                => p_town_of_birth
      ,p_uses_tobacco_flag            => p_uses_tobacco_flag
      ,p_work_schedule                => p_work_schedule
      ,p_party_id                     => p_party_id
      ,p_attribute_category           => p_attribute_category
      ,p_attribute1                   => p_attribute1
      ,p_attribute2                   => p_attribute2
      ,p_attribute3                   => p_attribute3
      ,p_attribute4                   => p_attribute4
      ,p_attribute5                   => p_attribute5
      ,p_attribute6                   => p_attribute6
      ,p_attribute7                   => p_attribute7
      ,p_attribute8                   => p_attribute8
      ,p_attribute9                   => p_attribute9
      ,p_attribute10                  => p_attribute10
      ,p_attribute11                  => p_attribute11
      ,p_attribute12                  => p_attribute12
      ,p_attribute13                  => p_attribute13
      ,p_attribute14                  => p_attribute14
      ,p_attribute15                  => p_attribute15
      ,p_attribute16                  => p_attribute16
      ,p_attribute17                  => p_attribute17
      ,p_attribute18                  => p_attribute18
      ,p_attribute19                  => p_attribute19
      ,p_attribute20                  => p_attribute20
      ,p_attribute21                  => p_attribute21
      ,p_attribute22                  => p_attribute22
      ,p_attribute23                  => p_attribute23
      ,p_attribute24                  => p_attribute24
      ,p_attribute25                  => p_attribute25
      ,p_attribute26                  => p_attribute26
      ,p_attribute27                  => p_attribute27
      ,p_attribute28                  => p_attribute28
      ,p_attribute29                  => p_attribute29
      ,p_attribute30                  => p_attribute30
      ,p_per_information_category     => p_per_information_category
      ,p_per_information1             => p_per_information1
      ,p_per_information2             => p_per_information2
      ,p_per_information3             => p_per_information3
      ,p_per_information4             => p_per_information4
      ,p_per_information5             => p_per_information5
      ,p_per_information6             => p_per_information6
      ,p_per_information7             => p_per_information7
      ,p_per_information8             => p_per_information8
      ,p_per_information9             => p_per_information9
      ,p_per_information10            => p_per_information10
      ,p_per_information11            => p_per_information11
      ,p_per_information12            => p_per_information12
      ,p_per_information13            => p_per_information13
      ,p_per_information14            => p_per_information14
      ,p_per_information15            => p_per_information15
      ,p_per_information16            => p_per_information16
      ,p_per_information17            => p_per_information17
      ,p_per_information18            => p_per_information18
      ,p_per_information19            => p_per_information19
      ,p_per_information20            => p_per_information20
      ,p_per_information21            => p_per_information21
      ,p_per_information22            => p_per_information22
      ,p_per_information23            => p_per_information23
      ,p_per_information24            => p_per_information24
      ,p_per_information25            => p_per_information25
      ,p_per_information26            => p_per_information26
      ,p_per_information27            => p_per_information27
      ,p_per_information28            => p_per_information28
      ,p_per_information29            => p_per_information29
      ,p_per_information30            => p_per_information30
      ,p_person_id                    => l_person_id
      ,p_per_object_version_number    => l_per_object_version_number
      ,p_per_effective_start_date     => l_per_effective_start_date
      ,p_per_effective_end_date       => l_per_effective_end_date
      ,p_pdp_object_version_number    => l_pdp_object_version_number
      ,p_full_name                    => l_full_name
      ,p_comment_id                   => l_comment_id
      ,p_assignment_id                => l_assignment_id
      ,p_asg_object_version_number    => l_asg_object_version_number
      ,p_assignment_sequence          => l_assignment_sequence
      ,p_assignment_number            => l_assignment_number
      ,p_name_combination_warning     => l_name_combination_warning
      ,p_original_date_of_hire        => p_original_date_of_hire -- for the bug 5744328
      );
-- Bug 4287925 Starts Here
     p_placement_date_start :=l_creation_date;
-- Bug 4287925 Ends Here
  END IF;
  --
  p_person_id:=l_person_id;
  p_employee_number:=l_employee_number;
  p_applicant_number:=l_applicant_number;
  p_npw_number:=l_npw_number;
  p_assignment_id:=l_assignment_id;
  p_application_id:=l_application_id;
  p_app_object_version_number:=l_app_object_version_number;
  p_per_object_version_number:=l_per_object_version_number;
  p_per_effective_start_date:=l_per_effective_start_date;
  p_per_effective_end_date:=l_per_effective_end_date;
  p_per_validation_start_date:=l_per_effective_start_date;
  p_per_validation_end_date:=l_per_effective_end_date;
  p_pdp_object_version_number:=l_pdp_object_version_number;
  p_full_name:=l_full_name;
  p_assignment_sequence:=l_assignment_sequence;
  p_assignment_number:=l_assignment_number;
--  p_name_combination_warning:=l_name_combination_warning; - checked already
  p_assign_payroll_warning:=l_assign_payroll_warning;
--  p_orig_hire_warning:=l_orig_hire_warning; - insert of person, so not applicable
  --
  hr_utility.set_location(l_proc, 50);
  --
  --
-- Bug 3891200 Starts Here
-- Desc: Modified the if condition.to replace address_line1 with style and date_from
--  IF p_address_line1 IS NOT NULL THEN
  IF p_style is not null and p_adr_date_from is not null then
-- Bug 3891200 Ends Here
    --
    --
    hr_utility.set_location(l_proc, 190);
    hr_utility.set_location('Insert Add Before:' || fnd_profile.value('PER_ORGANIZATION_ID'), 13163);
    --
    hr_person_address_api.cre_or_upd_person_address
      (p_effective_date               => l_creation_date --p_effective_date
      ,p_person_id                    => l_person_id
      ,p_update_mode                  => 'CORRECTION'
      ,p_primary_flag                 => 'Y'
      ,p_style                        => p_style
      ,p_date_from                    => p_adr_date_from
      ,p_date_to                      => p_adr_date_to
      ,p_address_type                 => p_address_type
      ,p_address_line1                => p_address_line1
      ,p_address_line2                => p_address_line2
      ,p_address_line3                => p_address_line3
      ,p_town_or_city                 => p_town_or_city
      ,p_region_1                     => p_region_1
      ,p_region_2                     => p_region_2
      ,p_region_3                     => p_region_3
      ,p_postal_code                  => p_postal_code
      ,p_country                      => p_country
      ,p_telephone_number_1           => p_telephone_number_1
      ,p_telephone_number_2           => p_telephone_number_2
      ,p_telephone_number_3           => p_telephone_number_3
      ,p_addr_attribute_category      => p_addr_attribute_category
      ,p_addr_attribute1              => p_addr_attribute1
      ,p_addr_attribute2              => p_addr_attribute2
      ,p_addr_attribute3              => p_addr_attribute3
      ,p_addr_attribute4              => p_addr_attribute4
      ,p_addr_attribute5              => p_addr_attribute5
      ,p_addr_attribute6              => p_addr_attribute6
      ,p_addr_attribute7              => p_addr_attribute7
      ,p_addr_attribute8              => p_addr_attribute8
      ,p_addr_attribute9              => p_addr_attribute9
      ,p_addr_attribute10             => p_addr_attribute10
      ,p_addr_attribute11             => p_addr_attribute11
      ,p_addr_attribute12             => p_addr_attribute12
      ,p_addr_attribute13             => p_addr_attribute13
      ,p_addr_attribute14             => p_addr_attribute14
      ,p_addr_attribute15             => p_addr_attribute15
      ,p_addr_attribute16             => p_addr_attribute16
      ,p_addr_attribute17             => p_addr_attribute17
      ,p_addr_attribute18             => p_addr_attribute18
      ,p_addr_attribute19             => p_addr_attribute19
      ,p_addr_attribute20             => p_addr_attribute20
--
--Bug 3216519 Start here
--
      ,p_add_information13            => p_add_information13
      ,p_add_information14            => p_add_information14
      ,p_add_information15            => p_add_information15
      ,p_add_information16            => p_add_information16
--
--Bug 3216519 End here
--
      ,p_add_information17            => p_add_information17
      ,p_add_information18            => p_add_information18
      ,p_add_information19            => p_add_information19
      ,p_add_information20            => p_add_information20
      ,p_address_id                   => l_address_id
      ,p_object_version_number        => l_addr_object_version_number
    );
    --
    p_address_id:=l_address_id;
    p_addr_object_version_number:=l_addr_object_version_number;
    --
    hr_utility.set_location(l_proc, 200);
    --
    hr_utility.set_location('Insert Add After:' || fnd_profile.value('PER_ORGANIZATION_ID'), 13163);

  END IF;

---- Fix For Bug # 6827296 Starts ----

l_special_ceiling_step_id:=p_special_ceiling_step_id;

---- Fix For Bug # 6827296 Ends ----

  --
  --
  -- employee assignments
  --
  IF p_assignment_type='E' THEN
    --
       hr_utility.set_location(l_proc, 110);
hr_utility.set_location('Insert Asg Before:' || fnd_profile.value('PER_ORGANIZATION_ID'), 13163);
hr_utility.set_location('Insert Asg p_organization_id:' || p_organization_id, 13163);
    --
-- Fix For Bug 6706502 Starts--

per_qh_maintain_update.p_qh_organization_id := p_organization_id;

-- Fix For Bug 6706502 Ends--

    hr_utility.set_location(l_proc, 110);
    --
    hr_assignment_api.update_emp_asg
    (p_effective_date               => l_creation_date  --p_effective_date
    ,p_datetrack_update_mode        => 'CORRECTION'
    ,p_assignment_id                => l_assignment_id
    ,p_object_version_number        => l_asg_object_version_number
    ,p_supervisor_id                => p_supervisor_id
    ,p_supervisor_assignment_id     => p_supervisor_assignment_id
    ,p_assignment_number            => p_assignment_number
    ,p_change_reason                => p_change_reason
    ,p_assignment_status_type_id    => p_assignment_status_type_id
    ,p_date_probation_end           => p_date_probation_end
    ,p_default_code_comb_id         => p_default_code_comb_id
    ,p_frequency                    => p_frequency
    ,p_internal_address_line        => p_internal_address_line
    ,p_manager_flag                 => p_manager_flag
    ,p_normal_hours                 => p_normal_hours
    ,p_perf_review_period           => p_perf_review_period
    ,p_perf_review_period_frequency => p_perf_review_period_frequency
    ,p_probation_period             => p_probation_period
    ,p_probation_unit               => p_probation_unit
    ,p_notice_period                => p_notice_period
    ,p_notice_period_uom            => p_notice_unit
    ,p_employee_category            => p_employee_category
    ,p_sal_review_period            => p_sal_review_period
    ,p_sal_review_period_frequency  => p_sal_review_period_frequency
    ,p_set_of_books_id              => p_set_of_books_id
    ,p_title                        => p_billing_title
    ,p_source_type                  => p_source_type
    ,p_time_normal_finish           => p_time_normal_finish
    ,p_time_normal_start            => p_time_normal_start
    ,p_bargaining_unit_code         => p_bargaining_unit_code
    ,p_labour_union_member_flag     => p_labour_union_member_flag
    ,p_hourly_salaried_code         => p_hourly_salaried_code
    ,p_ass_attribute_category       => p_ass_attribute_category
    ,p_ass_attribute1               => p_ass_attribute1
    ,p_ass_attribute2               => p_ass_attribute2
    ,p_ass_attribute3               => p_ass_attribute3
    ,p_ass_attribute4               => p_ass_attribute4
    ,p_ass_attribute5               => p_ass_attribute5
    ,p_ass_attribute6               => p_ass_attribute6
    ,p_ass_attribute7               => p_ass_attribute7
    ,p_ass_attribute8               => p_ass_attribute8
    ,p_ass_attribute9               => p_ass_attribute9
    ,p_ass_attribute10              => p_ass_attribute10
    ,p_ass_attribute11              => p_ass_attribute11
    ,p_ass_attribute12              => p_ass_attribute12
    ,p_ass_attribute13              => p_ass_attribute13
    ,p_ass_attribute14              => p_ass_attribute14
    ,p_ass_attribute15              => p_ass_attribute15
    ,p_ass_attribute16              => p_ass_attribute16
    ,p_ass_attribute17              => p_ass_attribute17
    ,p_ass_attribute18              => p_ass_attribute18
    ,p_ass_attribute19              => p_ass_attribute19
    ,p_ass_attribute20              => p_ass_attribute20
    ,p_ass_attribute21              => p_ass_attribute21
    ,p_ass_attribute22              => p_ass_attribute22
    ,p_ass_attribute23              => p_ass_attribute23
    ,p_ass_attribute24              => p_ass_attribute24
    ,p_ass_attribute25              => p_ass_attribute25
    ,p_ass_attribute26              => p_ass_attribute26
    ,p_ass_attribute27              => p_ass_attribute27
    ,p_ass_attribute28              => p_ass_attribute28
    ,p_ass_attribute29              => p_ass_attribute29
    ,p_ass_attribute30              => p_ass_attribute30
    ,p_segment1                     => p_scl_segment1
    ,p_segment2                     => p_scl_segment2
    ,p_segment3                     => p_scl_segment3
    ,p_segment4                     => p_scl_segment4
    ,p_segment5                     => p_scl_segment5
    ,p_segment6                     => p_scl_segment6
    ,p_segment7                     => p_scl_segment7
    ,p_segment8                     => p_scl_segment8
    ,p_segment9                     => p_scl_segment9
    ,p_segment10                    => p_scl_segment10
    ,p_segment11                    => p_scl_segment11
    ,p_segment12                    => p_scl_segment12
    ,p_segment13                    => p_scl_segment13
    ,p_segment14                    => p_scl_segment14
    ,p_segment15                    => p_scl_segment15
    ,p_segment16                    => p_scl_segment16
    ,p_segment17                    => p_scl_segment17
    ,p_segment18                    => p_scl_segment18
    ,p_segment19                    => p_scl_segment19
    ,p_segment20                    => p_scl_segment20
    ,p_segment21                    => p_scl_segment21
    ,p_segment22                    => p_scl_segment22
    ,p_segment23                    => p_scl_segment23
    ,p_segment24                    => p_scl_segment24
    ,p_segment25                    => p_scl_segment25
    ,p_segment26                    => p_scl_segment26
    ,p_segment27                    => p_scl_segment27
    ,p_segment28                    => p_scl_segment28
    ,p_segment29                    => p_scl_segment29
    ,p_segment30                    => p_scl_segment30
    ,p_concatenated_segments        => l_concatenated_segments
    ,p_contract_id                  =>     p_contract_id
    ,p_establishment_id             =>     p_establishment_id
    ,p_collective_agreement_id      =>     p_collective_agreement_id
    ,p_cagr_id_flex_num             =>     p_cagr_id_flex_num
    ,p_cagr_grade_def_id            =>     l_cagr_grade_def_id
--Bug 3063591 Start Here
    ,p_work_at_home                 =>     p_work_at_home
--Bug 3063591 End Here
    ,p_cagr_concatenated_segments   =>     l_cagr_concatenated_segments
    ,p_soft_coding_keyflex_id       => l_soft_coding_keyflex_id
    ,p_comment_id                   => l_comment_id
    ,p_effective_start_date         => l_asg_effective_start_date
    ,p_effective_end_date           => l_asg_effective_end_date
    ,p_no_managers_warning          => l_no_managers_warning
    ,p_other_manager_warning        => l_other_manager_warning2
    ,p_hourly_salaried_warning      => l_hourly_salaried_warning
    ,p_gsp_post_process_warning     => l_gsp_post_process_warning
    );
    --
    hr_utility.set_location(l_proc,120);
    --
    per_qh_maintain_update.p_qh_organization_id := NULL;   --- Added For Bug # 6706502
    hr_utility.set_location('Insert Asg After:' || fnd_profile.value('PER_ORGANIZATION_ID'), 13163);

  hr_assignment_api.update_emp_asg_criteria
    (p_effective_date               => l_creation_date  --p_effective_date
    ,p_datetrack_update_mode        => 'CORRECTION'
    ,p_assignment_id                => l_assignment_id
    ,p_object_version_number        => l_asg_object_version_number
    ,p_grade_id                     => p_grade_id
    ,p_grade_ladder_pgm_id          => p_grade_ladder_pgm_id
    ,p_position_id                  => p_position_id
    ,p_job_id                       => p_job_id
    ,p_payroll_id                   => p_payroll_id
    ,p_location_id                  => p_location_id
    ,p_special_ceiling_step_id      => l_special_ceiling_step_id
    ,p_organization_id              => p_organization_id
    ,p_pay_basis_id                 => p_pay_basis_id
    ,p_segment1                     => p_pgp_segment1
    ,p_segment2                     => p_pgp_segment2
    ,p_segment3                     => p_pgp_segment3
    ,p_segment4                     => p_pgp_segment4
    ,p_segment5                     => p_pgp_segment5
    ,p_segment6                     => p_pgp_segment6
    ,p_segment7                     => p_pgp_segment7
    ,p_segment8                     => p_pgp_segment8
    ,p_segment9                     => p_pgp_segment9
    ,p_segment10                    => p_pgp_segment10
    ,p_segment11                    => p_pgp_segment11
    ,p_segment12                    => p_pgp_segment12
    ,p_segment13                    => p_pgp_segment13
    ,p_segment14                    => p_pgp_segment14
    ,p_segment15                    => p_pgp_segment15
    ,p_segment16                    => p_pgp_segment16
    ,p_segment17                    => p_pgp_segment17
    ,p_segment18                    => p_pgp_segment18
    ,p_segment19                    => p_pgp_segment19
    ,p_segment20                    => p_pgp_segment20
    ,p_segment21                    => p_pgp_segment21
    ,p_segment22                    => p_pgp_segment22
    ,p_segment23                    => p_pgp_segment23
    ,p_segment24                    => p_pgp_segment24
    ,p_segment25                    => p_pgp_segment25
    ,p_segment26                    => p_pgp_segment26
    ,p_segment27                    => p_pgp_segment27
    ,p_segment28                    => p_pgp_segment28
    ,p_segment29                    => p_pgp_segment29
    ,p_segment30                    => p_pgp_segment30
    ,p_employment_category          => p_employment_category
    ,p_group_name                   => l_group_name
    ,p_effective_start_date         => l_asg_effective_start_date
    ,p_effective_end_date           => l_asg_effective_end_date
    ,p_people_group_id              => l_people_group_id
    ,p_org_now_no_manager_warning   => l_org_now_no_manager_warning
    ,p_other_manager_warning        => l_other_manager_warning
    ,p_spp_delete_warning           => l_spp_delete_warning
    ,p_entries_changed_warning      => l_entries_changed_warning
    ,p_tax_district_changed_warning => l_tax_district_changed_warning
    ,p_soft_coding_keyflex_id       => l_soft_coding_keyflex_id
    ,p_concatenated_segments        => l_concatenated_segments
    ,p_gsp_post_process_warning     => l_gsp_post_process_warning2
    );
    --
    hr_utility.set_location(l_proc, 130);
    --
    hr_utility.set_location('Insert Asg Cr After:' || fnd_profile.value('PER_ORGANIZATION_ID'), 13163);

    IF l_no_managers_warning THEN
      l_org_now_no_manager_warning:=TRUE;
    END IF;
    --
    IF l_other_manager_warning2 THEN
      l_other_manager_warning:=TRUE;
    END IF;
    --
    IF l_spp_delete_warning THEN
      --
      fnd_message.set_name('PER', 'HR_289828_INV_SPP_CHANGE');
      hr_utility.raise_error;
      --
    END IF;
    --
    hr_utility.set_location(l_proc, 140);
    --
  ELSIF p_assignment_type='A' then
    --
    hr_utility.set_location(l_proc, 150);
    --
    hr_assignment_api.update_apl_asg
    (p_effective_date               =>     l_creation_date  --p_effective_date
    ,p_datetrack_update_mode        =>     'CORRECTION'
    ,p_assignment_id                =>     l_assignment_id
    ,p_object_version_number        =>     l_asg_object_version_number
    ,p_grade_id                     =>     p_grade_id
    ,p_grade_ladder_pgm_id          =>     p_grade_ladder_pgm_id
    ,p_job_id                       =>     p_job_id
    ,p_payroll_id                   =>     p_payroll_id
    ,p_location_id                  =>     p_location_id
    ,p_organization_id              =>     p_organization_id
    ,p_position_id                  =>     p_position_id
    ,p_application_id               =>     p_application_id
    ,p_special_ceiling_step_id      =>     l_special_ceiling_step_id
    ,p_recruiter_id                 =>     p_recruiter_id
    ,p_recruitment_activity_id      =>     p_recruitment_activity_id
    ,p_vacancy_id                   =>     p_vacancy_id
    ,p_pay_basis_id                 =>     p_pay_basis_id
    ,p_person_referred_by_id        =>     p_person_referred_by_id
    ,p_supervisor_id                =>     p_supervisor_id
    ,p_supervisor_assignment_id     =>     p_supervisor_assignment_id
    ,p_source_organization_id       =>     p_source_organization_id
    ,p_change_reason                =>     p_change_reason
    ,p_assignment_status_type_id    =>     p_assignment_status_type_id
    ,p_internal_address_line        =>     p_internal_address_line
    ,p_default_code_comb_id         =>     p_default_code_comb_id
    ,p_employment_category          =>     p_employment_category
    ,p_frequency                    =>     p_frequency
    ,p_manager_flag                 =>     p_manager_flag
    ,p_normal_hours                 =>     p_normal_hours
    ,p_perf_review_period           =>     p_perf_review_period
    ,p_perf_review_period_frequency =>     p_perf_review_period_frequency
    ,p_probation_period             =>     p_probation_period
    ,p_probation_unit               =>     p_probation_unit
    ,p_sal_review_period            =>     p_sal_review_period
    ,p_sal_review_period_frequency  =>     p_sal_review_period_frequency
    ,p_set_of_books_id              =>     p_set_of_books_id
    ,p_title                        =>     p_billing_title
    ,p_source_type                  =>     p_source_type
    ,p_time_normal_finish           =>     p_time_normal_finish
    ,p_time_normal_start            =>     p_time_normal_start
    ,p_bargaining_unit_code         =>     p_bargaining_unit_code
    ,p_date_probation_end           =>     p_date_probation_end
    ,p_ass_attribute_category       =>     p_ass_attribute_category
    ,p_ass_attribute1               =>     p_ass_attribute1
    ,p_ass_attribute2               =>     p_ass_attribute2
    ,p_ass_attribute3               =>     p_ass_attribute3
    ,p_ass_attribute4               =>     p_ass_attribute4
    ,p_ass_attribute5               =>     p_ass_attribute5
    ,p_ass_attribute6               =>     p_ass_attribute6
    ,p_ass_attribute7               =>     p_ass_attribute7
    ,p_ass_attribute8               =>     p_ass_attribute8
    ,p_ass_attribute9               =>     p_ass_attribute9
    ,p_ass_attribute10              =>     p_ass_attribute10
    ,p_ass_attribute11              =>     p_ass_attribute11
    ,p_ass_attribute12              =>     p_ass_attribute12
    ,p_ass_attribute13              =>     p_ass_attribute13
    ,p_ass_attribute14              =>     p_ass_attribute14
    ,p_ass_attribute15              =>     p_ass_attribute15
    ,p_ass_attribute16              =>     p_ass_attribute16
    ,p_ass_attribute17              =>     p_ass_attribute17
    ,p_ass_attribute18              =>     p_ass_attribute18
    ,p_ass_attribute19              =>     p_ass_attribute19
    ,p_ass_attribute20              =>     p_ass_attribute20
    ,p_ass_attribute21              =>     p_ass_attribute21
    ,p_ass_attribute22              =>     p_ass_attribute22
    ,p_ass_attribute23              =>     p_ass_attribute23
    ,p_ass_attribute24              =>     p_ass_attribute24
    ,p_ass_attribute25              =>     p_ass_attribute25
    ,p_ass_attribute26              =>     p_ass_attribute26
    ,p_ass_attribute27              =>     p_ass_attribute27
    ,p_ass_attribute28              =>     p_ass_attribute28
    ,p_ass_attribute29              =>     p_ass_attribute29
    ,p_ass_attribute30              =>     p_ass_attribute30
    ,p_scl_segment1                 =>     p_scl_segment1
    ,p_scl_segment2                 =>     p_scl_segment2
    ,p_scl_segment3                 =>     p_scl_segment3
    ,p_scl_segment4                 =>     p_scl_segment4
    ,p_scl_segment5                 =>     p_scl_segment5
    ,p_scl_segment6                 =>     p_scl_segment6
    ,p_scl_segment7                 =>     p_scl_segment7
    ,p_scl_segment8                 =>     p_scl_segment8
    ,p_scl_segment9                 =>     p_scl_segment9
    ,p_scl_segment10                =>     p_scl_segment10
    ,p_scl_segment11                =>     p_scl_segment11
    ,p_scl_segment12                =>     p_scl_segment12
    ,p_scl_segment13                =>     p_scl_segment13
    ,p_scl_segment14                =>     p_scl_segment14
    ,p_scl_segment15                =>     p_scl_segment15
    ,p_scl_segment16                =>     p_scl_segment16
    ,p_scl_segment17                =>     p_scl_segment17
    ,p_scl_segment18                =>     p_scl_segment18
    ,p_scl_segment19                =>     p_scl_segment19
    ,p_scl_segment20                =>     p_scl_segment20
    ,p_scl_segment21                =>     p_scl_segment21
    ,p_scl_segment22                =>     p_scl_segment22
    ,p_scl_segment23                =>     p_scl_segment23
    ,p_scl_segment24                =>     p_scl_segment24
    ,p_scl_segment25                =>     p_scl_segment25
    ,p_scl_segment26                =>     p_scl_segment26
    ,p_scl_segment27                =>     p_scl_segment27
    ,p_scl_segment28                =>     p_scl_segment28
    ,p_scl_segment29                =>     p_scl_segment29
    ,p_scl_segment30                =>     p_scl_segment30
    ,p_pgp_segment1                 =>     p_pgp_segment1
    ,p_pgp_segment2                 =>     p_pgp_segment2
    ,p_pgp_segment3                 =>     p_pgp_segment3
    ,p_pgp_segment4                 =>     p_pgp_segment4
    ,p_pgp_segment5                 =>     p_pgp_segment5
    ,p_pgp_segment6                 =>     p_pgp_segment6
    ,p_pgp_segment7                 =>     p_pgp_segment7
    ,p_pgp_segment8                 =>     p_pgp_segment8
    ,p_pgp_segment9                 =>     p_pgp_segment9
    ,p_pgp_segment10                =>     p_pgp_segment10
    ,p_pgp_segment11                =>     p_pgp_segment11
    ,p_pgp_segment12                =>     p_pgp_segment12
    ,p_pgp_segment13                =>     p_pgp_segment13
    ,p_pgp_segment14                =>     p_pgp_segment14
    ,p_pgp_segment15                =>     p_pgp_segment15
    ,p_pgp_segment16                =>     p_pgp_segment16
    ,p_pgp_segment17                =>     p_pgp_segment17
    ,p_pgp_segment18                =>     p_pgp_segment18
    ,p_pgp_segment19                =>     p_pgp_segment19
    ,p_pgp_segment20                =>     p_pgp_segment20
    ,p_pgp_segment21                =>     p_pgp_segment21
    ,p_pgp_segment22                =>     p_pgp_segment22
    ,p_pgp_segment23                =>     p_pgp_segment23
    ,p_pgp_segment24                =>     p_pgp_segment24
    ,p_pgp_segment25                =>     p_pgp_segment25
    ,p_pgp_segment26                =>     p_pgp_segment26
    ,p_pgp_segment27                =>     p_pgp_segment27
    ,p_pgp_segment28                =>     p_pgp_segment28
    ,p_pgp_segment29                =>     p_pgp_segment29
    ,p_pgp_segment30                =>     p_pgp_segment30
    ,p_contract_id                  =>     p_contract_id
    ,p_establishment_id             =>     p_establishment_id
    ,p_collective_agreement_id      =>     p_collective_agreement_id
    ,p_cagr_id_flex_num             =>     p_cagr_id_flex_num
    ,p_cagr_grade_def_id            =>     l_cagr_grade_def_id
--Bug 3063591 Start Here
    ,p_work_at_home                 =>     p_work_at_home
    ,p_notice_period                =>     p_notice_period
    ,p_notice_period_uom            =>     p_notice_unit
--Bug 3063591 End Here
    ,p_cagr_concatenated_segments   =>     l_cagr_concatenated_segments
    ,p_group_name                   =>     l_group_name
    ,p_concatenated_segments        =>     l_concatenated_segments
    ,p_comment_id                   =>     l_comment_id
    ,p_people_group_id              =>     l_people_group_id
    ,p_soft_coding_keyflex_id       =>     l_soft_coding_keyflex_id
    ,p_effective_start_date         =>     l_asg_effective_start_date
    ,p_effective_end_date           =>     l_asg_effective_end_date
    );
    --
    hr_utility.set_location(l_proc, 160);
    --
  ELSIF p_assignment_type='C' then    --CWK assignment
    --
    hr_utility.set_location(l_proc, 162);
    hr_utility.set_location(to_char(p_projected_assignment_end,'DD-MON-YYYY'), 162);

    hr_assignment_api.update_cwk_asg
    (p_effective_date               => l_creation_date  --p_effective_date
    ,p_datetrack_update_mode        => 'CORRECTION'
    ,p_assignment_id                => l_assignment_id
    ,p_object_version_number        => l_asg_object_version_number
    ,p_assignment_category          => p_employment_category
    ,p_assignment_number            => p_assignment_number
    ,p_change_reason                => p_change_reason
    ,p_default_code_comb_id         => p_default_code_comb_id
    ,p_frequency                    => p_frequency
    ,p_internal_address_line        => p_internal_address_line
    ,p_labour_union_member_flag     => p_labour_union_member_flag
    ,p_manager_flag                 => p_manager_flag
    ,p_normal_hours                 => p_normal_hours
    ,p_project_title                => p_project_title
    ,p_set_of_books_id              => p_set_of_books_id
    ,p_title                        => p_billing_title
    ,p_source_type                  => p_source_type
    ,p_supervisor_id                => p_supervisor_id
    ,p_supervisor_assignment_id     => p_supervisor_assignment_id
    ,p_time_normal_finish           => p_time_normal_finish
    ,p_time_normal_start            => p_time_normal_start
    ,p_vendor_assignment_number     => p_vendor_assignment_number
    ,p_vendor_employee_number       => p_vendor_employee_number
    ,p_vendor_id                    => p_vendor_id
    ,p_vendor_site_id               => p_vendor_site_id
    ,p_po_header_id                 => p_po_header_id
    ,p_po_line_id                   => p_po_line_id
    ,p_projected_assignment_end     => p_projected_assignment_end
    ,p_assignment_status_type_id    => p_assignment_status_type_id
    ,p_attribute_category       => p_ass_attribute_category
    ,p_attribute1               => p_ass_attribute1
    ,p_attribute2               => p_ass_attribute2
    ,p_attribute3               => p_ass_attribute3
    ,p_attribute4               => p_ass_attribute4
    ,p_attribute5               => p_ass_attribute5
    ,p_attribute6               => p_ass_attribute6
    ,p_attribute7               => p_ass_attribute7
    ,p_attribute8               => p_ass_attribute8
    ,p_attribute9               => p_ass_attribute9
    ,p_attribute10              => p_ass_attribute10
    ,p_attribute11              => p_ass_attribute11
    ,p_attribute12              => p_ass_attribute12
    ,p_attribute13              => p_ass_attribute13
    ,p_attribute14              => p_ass_attribute14
    ,p_attribute15              => p_ass_attribute15
    ,p_attribute16              => p_ass_attribute16
    ,p_attribute17              => p_ass_attribute17
    ,p_attribute18              => p_ass_attribute18
    ,p_attribute19              => p_ass_attribute19
    ,p_attribute20              => p_ass_attribute20
    ,p_attribute21              => p_ass_attribute21
    ,p_attribute22              => p_ass_attribute22
    ,p_attribute23              => p_ass_attribute23
    ,p_attribute24              => p_ass_attribute24
    ,p_attribute25              => p_ass_attribute25
    ,p_attribute26              => p_ass_attribute26
    ,p_attribute27              => p_ass_attribute27
    ,p_attribute28              => p_ass_attribute28
    ,p_attribute29              => p_ass_attribute29
    ,p_attribute30              => p_ass_attribute30
    ,p_scl_segment1                     => p_scl_segment1
    ,p_scl_segment2                     => p_scl_segment2
    ,p_scl_segment3                     => p_scl_segment3
    ,p_scl_segment4                     => p_scl_segment4
    ,p_scl_segment5                     => p_scl_segment5
    ,p_scl_segment6                     => p_scl_segment6
    ,p_scl_segment7                     => p_scl_segment7
    ,p_scl_segment8                     => p_scl_segment8
    ,p_scl_segment9                     => p_scl_segment9
    ,p_scl_segment10                    => p_scl_segment10
    ,p_scl_segment11                    => p_scl_segment11
    ,p_scl_segment12                    => p_scl_segment12
    ,p_scl_segment13                    => p_scl_segment13
    ,p_scl_segment14                    => p_scl_segment14
    ,p_scl_segment15                    => p_scl_segment15
    ,p_scl_segment16                    => p_scl_segment16
    ,p_scl_segment17                    => p_scl_segment17
    ,p_scl_segment18                    => p_scl_segment18
    ,p_scl_segment19                    => p_scl_segment19
    ,p_scl_segment20                    => p_scl_segment20
    ,p_scl_segment21                    => p_scl_segment21
    ,p_scl_segment22                    => p_scl_segment22
    ,p_scl_segment23                    => p_scl_segment23
    ,p_scl_segment24                    => p_scl_segment24
    ,p_scl_segment25                    => p_scl_segment25
    ,p_scl_segment26                    => p_scl_segment26
    ,p_scl_segment27                    => p_scl_segment27
    ,p_scl_segment28                    => p_scl_segment28
    ,p_scl_segment29                    => p_scl_segment29
    ,p_scl_segment30                    => p_scl_segment30
    ,p_org_now_no_manager_warning   => l_org_now_no_manager_warning
    ,p_effective_start_date         => l_asg_effective_start_date
    ,p_effective_end_date           => l_asg_effective_end_date
    ,p_comment_id                   => l_comment_id
    ,p_no_managers_warning          => l_no_managers_warning
    ,p_other_manager_warning        => l_other_manager_warning2
    ,p_soft_coding_keyflex_id       => l_soft_coding_keyflex_id
    ,p_concatenated_segments        => l_concatenated_segments
    ,p_hourly_salaried_warning      => l_hourly_salaried_warning
    );
    --
    hr_utility.set_location(l_proc, 163);
    --
    hr_assignment_api.update_cwk_asg_criteria
      (p_effective_date               => l_creation_date  --p_effective_date
      ,p_datetrack_update_mode        => 'CORRECTION'
      ,p_assignment_id                => l_assignment_id
      ,p_object_version_number        => l_asg_object_version_number
      ,p_grade_id                     => p_grade_id
      ,p_position_id                  => p_position_id
      ,p_job_id                       => p_job_id
--      ,p_payroll_id                   => p_payroll_id
      ,p_location_id                  => p_location_id
      ,p_organization_id              => p_organization_id
--      ,p_pay_basis_id                 => p_pay_basis_id
      ,p_segment1                     => p_pgp_segment1
      ,p_segment2                     => p_pgp_segment2
      ,p_segment3                     => p_pgp_segment3
      ,p_segment4                     => p_pgp_segment4
      ,p_segment5                     => p_pgp_segment5
      ,p_segment6                     => p_pgp_segment6
      ,p_segment7                     => p_pgp_segment7
      ,p_segment8                     => p_pgp_segment8
      ,p_segment9                     => p_pgp_segment9
      ,p_segment10                    => p_pgp_segment10
      ,p_segment11                    => p_pgp_segment11
      ,p_segment12                    => p_pgp_segment12
      ,p_segment13                    => p_pgp_segment13
      ,p_segment14                    => p_pgp_segment14
      ,p_segment15                    => p_pgp_segment15
      ,p_segment16                    => p_pgp_segment16
      ,p_segment17                    => p_pgp_segment17
      ,p_segment18                    => p_pgp_segment18
      ,p_segment19                    => p_pgp_segment19
      ,p_segment20                    => p_pgp_segment20
      ,p_segment21                    => p_pgp_segment21
      ,p_segment22                    => p_pgp_segment22
      ,p_segment23                    => p_pgp_segment23
      ,p_segment24                    => p_pgp_segment24
      ,p_segment25                    => p_pgp_segment25
      ,p_segment26                    => p_pgp_segment26
      ,p_segment27                    => p_pgp_segment27
      ,p_segment28                    => p_pgp_segment28
      ,p_segment29                    => p_pgp_segment29
      ,p_segment30                    => p_pgp_segment30
      ,p_people_group_name            => l_group_name
      ,p_effective_start_date         => l_asg_effective_start_date
      ,p_effective_end_date           => l_asg_effective_end_date
      ,p_people_group_id              => l_people_group_id
      ,p_org_now_no_manager_warning   => l_org_now_no_manager_warning
      ,p_other_manager_warning        => l_other_manager_warning
      ,p_spp_delete_warning           => l_spp_delete_warning
      ,p_entries_changed_warning      => l_entries_changed_warning
      ,p_tax_district_changed_warning => l_tax_district_changed_warning
      );
    --
    hr_utility.set_location(l_proc, 164);
    --
    IF p_rate_id is not null then   --an assignment rate has been entered for the CWK
       hr_rate_values_api.create_assignment_rate_value
	    (p_effective_date           => l_creation_date  --p_effective_date
	    ,p_business_group_id        => p_business_group_id
	    ,p_rate_id                  => p_rate_id
	    ,p_assignment_id            => l_assignment_id
	    ,p_rate_type                => 'A'
	    ,p_currency_code            => p_rate_currency_code
	    ,p_value                    => p_rate_value
	    ,p_grade_rule_id            => l_grade_rule_id
	    ,p_object_version_number    => l_rate_object_version_number
	    ,p_effective_start_date     => l_rate_effective_start_date
	    ,p_effective_end_date       => l_rate_effective_end_date
            );
    END IF;
    p_grade_rule_id               := l_grade_rule_id;
    p_rate_object_version_number  := l_rate_object_version_number;
    p_rate_effective_start_date   := l_rate_effective_start_date;
    p_rate_effective_end_date     := l_rate_effective_end_date;
  END IF;
  --
  p_assignment_id:=l_assignment_id;
  p_asg_object_version_number:=l_asg_object_version_number;
  p_special_ceiling_step_id:=l_special_ceiling_step_id;
  p_asg_effective_start_date:=l_asg_effective_start_date;
  p_asg_effective_end_date:=l_asg_effective_end_date;
  p_asg_validation_start_date:=l_asg_effective_start_date;
  p_asg_validation_end_date:=l_asg_effective_end_date;
  p_people_group_id:=l_people_group_id;
  p_org_now_no_manager_warning:=l_org_now_no_manager_warning;
  p_other_manager_warning:=l_other_manager_warning;
  p_spp_delete_warning:=l_spp_delete_warning;
  p_entries_changed_warning:=l_entries_changed_warning;
  p_tax_district_changed_warning:=l_tax_district_changed_warning;
  p_cagr_grade_def_id:=l_cagr_grade_def_id;
--  p_cagr_concatenated_segments:=l_cagr_concatenated_segments;
  p_soft_coding_keyflex_id:=l_soft_coding_keyflex_id;
--
  --
  -- bug2999562 support gsp post process
  --
  if l_gsp_post_process_warning is not null then
    hr_utility.set_location(l_proc, 165);
    p_gsp_post_process_warning := l_gsp_post_process_warning;
  elsif l_gsp_post_process_warning2 is not null then
    hr_utility.set_location(l_proc, 166);
    p_gsp_post_process_warning := l_gsp_post_process_warning2;
  else
    p_gsp_post_process_warning := null;
  end if;

  hr_utility.set_location(l_proc, 167);
  --
  IF l_application_id IS NOT NULL AND
    (p_projected_hire_date IS NOT NULL
     OR p_appl_attribute_category IS NOT NULL
     OR p_appl_attribute1 IS NOT NULL
     OR p_appl_attribute2 IS NOT NULL
     OR p_appl_attribute3 IS NOT NULL
     OR p_appl_attribute4 IS NOT NULL
     OR p_appl_attribute5 IS NOT NULL
     OR p_appl_attribute6 IS NOT NULL
     OR p_appl_attribute7 IS NOT NULL
     OR p_appl_attribute8 IS NOT NULL
     OR p_appl_attribute9 IS NOT NULL
     OR p_appl_attribute10 IS NOT NULL
     OR p_appl_attribute11 IS NOT NULL
     OR p_appl_attribute12 IS NOT NULL
     OR p_appl_attribute13 IS NOT NULL
     OR p_appl_attribute14 IS NOT NULL
     OR p_appl_attribute15 IS NOT NULL
     OR p_appl_attribute16 IS NOT NULL
     OR p_appl_attribute17 IS NOT NULL
     OR p_appl_attribute18 IS NOT NULL
     OR p_appl_attribute19 IS NOT NULL
     OR p_appl_attribute20 IS NOT NULL
     OR p_current_employer IS NOT NULL
     OR p_termination_reason IS NOT NULL) THEN
    --
    --
    hr_utility.set_location(l_proc, 170);
    --
    hr_application_api.update_apl_details
      (p_application_id               => l_application_id
      ,p_object_version_number        => l_app_object_version_number
      ,p_effective_date               => l_creation_date  --p_effective_date
      ,p_current_employer             => p_current_employer
      ,p_projected_hire_date          => p_projected_hire_date
      ,p_termination_reason           => p_termination_reason
      ,p_appl_attribute_category      => p_appl_attribute_category
      ,p_appl_attribute1              => p_appl_attribute1
      ,p_appl_attribute2              => p_appl_attribute2
      ,p_appl_attribute3              => p_appl_attribute3
      ,p_appl_attribute4              => p_appl_attribute4
      ,p_appl_attribute5              => p_appl_attribute5
      ,p_appl_attribute6              => p_appl_attribute6
      ,p_appl_attribute7              => p_appl_attribute7
      ,p_appl_attribute8              => p_appl_attribute8
      ,p_appl_attribute9              => p_appl_attribute9
      ,p_appl_attribute10             => p_appl_attribute10
      ,p_appl_attribute11             => p_appl_attribute11
      ,p_appl_attribute12             => p_appl_attribute12
      ,p_appl_attribute13             => p_appl_attribute13
      ,p_appl_attribute14             => p_appl_attribute14
      ,p_appl_attribute15             => p_appl_attribute15
      ,p_appl_attribute16             => p_appl_attribute16
      ,p_appl_attribute17             => p_appl_attribute17
      ,p_appl_attribute18             => p_appl_attribute18
      ,p_appl_attribute19             => p_appl_attribute19
      ,p_appl_attribute20             => p_appl_attribute20
    );
    --
    hr_utility.set_location(l_proc, 180);
    --
    p_app_object_version_number:=l_app_object_version_number;
    p_application_id:=l_application_id;
  END IF;
  --
  hr_utility.set_location(l_proc, 185);
  --
  -- home phone
  --
  IF p_phn_h_phone_number IS NOT NULL THEN
    --
    l_phone_id:=NULL;
    l_phn_object_version_number:=NULL;
    hr_phone_api.create_or_update_phone
      (p_effective_date               => l_creation_date  --p_effective_date
      ,p_parent_id                    => p_person_id
      ,p_update_mode                  => l_datetrack_update_mode
      ,p_parent_table                 => 'PER_ALL_PEOPLE_F'
      ,p_phone_type                   => 'H1'
      ,p_phone_number                 => p_phn_h_phone_number
      ,p_date_from                    => p_phn_h_date_from
      ,p_date_to                      => p_phn_h_date_to
      ,p_object_version_number        => l_phn_object_version_number
      ,p_phone_id                     => l_phone_id
    );
    p_phn_h_phone_id:=l_phone_id;
    p_phn_h_object_version_number := l_phn_object_version_number;
  END IF;
  --
  -- work phone
  --
  IF p_phn_w_phone_number IS NOT NULL THEN
    --
    l_phone_id:=NULL;
    l_phn_object_version_number:=NULL;
    hr_phone_api.create_or_update_phone
      (p_effective_date               => l_creation_date  --p_effective_date
      ,p_parent_id                    => p_person_id
      ,p_update_mode                  => l_datetrack_update_mode
      ,p_parent_table                 => 'PER_ALL_PEOPLE_F'
      ,p_phone_type                   => 'W1'
      ,p_phone_number                 => p_phn_w_phone_number
      ,p_date_from                    => p_phn_w_date_from
      ,p_date_to                      => p_phn_w_date_to
      ,p_object_version_number        => l_phn_object_version_number
      ,p_phone_id                     => l_phone_id
    );
    p_phn_w_phone_id:=l_phone_id;
    p_phn_w_object_version_number := l_phn_object_version_number;
  END IF;
  --
  -- mobile phone
  --
  IF p_phn_m_phone_number IS NOT NULL THEN
    --
    l_phone_id:=NULL;
    l_phn_object_version_number:=NULL;
    hr_phone_api.create_or_update_phone
      (p_effective_date               => l_creation_date  --p_effective_date
      ,p_parent_id                    => p_person_id
      ,p_update_mode                  => l_datetrack_update_mode
      ,p_parent_table                 => 'PER_ALL_PEOPLE_F'
      ,p_phone_type                   => 'M'
      ,p_phone_number                 => p_phn_m_phone_number
      ,p_date_from                    => p_phn_m_date_from
      ,p_date_to                      => p_phn_m_date_to
      ,p_object_version_number        => l_phn_object_version_number
      ,p_phone_id                     => l_phone_id
    );
    p_phn_m_phone_id:=l_phone_id;
    p_phn_m_object_version_number := l_phn_object_version_number;
  END IF;
  --
  -- home fax
  --
  IF p_phn_hf_phone_number IS NOT NULL THEN
    --
    l_phone_id:=NULL;
    l_phn_object_version_number:=NULL;
    hr_phone_api.create_or_update_phone
      (p_effective_date               => l_creation_date  --p_effective_date
      ,p_parent_id                    => p_person_id
      ,p_update_mode                  => l_datetrack_update_mode
      ,p_parent_table                 => 'PER_ALL_PEOPLE_F'
      ,p_phone_type                   => 'HF'
      ,p_phone_number                 => p_phn_hf_phone_number
      ,p_date_from                    => p_phn_hf_date_from
      ,p_date_to                      => p_phn_hf_date_to
      ,p_object_version_number        => l_phn_object_version_number
      ,p_phone_id                     => l_phone_id
    );
    p_phn_hf_phone_id:=l_phone_id;
    p_phn_hf_object_version_number := l_phn_object_version_number;
  END IF;
  --
  -- work fax
  --
  IF p_phn_wf_phone_number IS NOT NULL THEN
    --
    l_phone_id:=NULL;
    l_phn_object_version_number:=NULL;
    hr_phone_api.create_or_update_phone
      (p_effective_date               => l_creation_date  --p_effective_date
      ,p_parent_id                    => p_person_id
      ,p_update_mode                  => l_datetrack_update_mode
      ,p_parent_table                 => 'PER_ALL_PEOPLE_F'
      ,p_phone_type                   => 'WF'
      ,p_phone_number                 => p_phn_wf_phone_number
      ,p_date_from                    => p_phn_wf_date_from
      ,p_date_to                      => p_phn_wf_date_to
      ,p_object_version_number        => l_phn_object_version_number
      ,p_phone_id                     => l_phone_id
    );
    p_phn_wf_phone_id:=l_phone_id;
    p_phn_wf_object_version_number := l_phn_object_version_number;
  END IF;
  --
  IF p_proposed_salary_n IS NOT NULL THEN
    --
    hr_maintain_proposal_api.insert_salary_proposal
      (p_pay_proposal_id              => l_pay_proposal_id
      ,p_assignment_id                => l_assignment_id
      ,p_business_group_id            => p_business_group_id
      ,p_change_date                  => p_change_date
      ,p_proposal_reason              => p_proposal_reason
      ,p_proposed_salary_n            => p_proposed_salary_n
      ,p_attribute_category           => p_pyp_attribute_category
      ,p_attribute1                   => p_pyp_attribute1
      ,p_attribute2                   => p_pyp_attribute2
      ,p_attribute3                   => p_pyp_attribute3
      ,p_attribute4                   => p_pyp_attribute4
      ,p_attribute5                   => p_pyp_attribute5
      ,p_attribute6                   => p_pyp_attribute6
      ,p_attribute7                   => p_pyp_attribute7
      ,p_attribute8                   => p_pyp_attribute8
      ,p_attribute9                   => p_pyp_attribute9
      ,p_attribute10                  => p_pyp_attribute10
      ,p_attribute11                  => p_pyp_attribute11
      ,p_attribute12                  => p_pyp_attribute12
      ,p_attribute13                  => p_pyp_attribute13
      ,p_attribute14                  => p_pyp_attribute14
      ,p_attribute15                  => p_pyp_attribute15
      ,p_attribute16                  => p_pyp_attribute16
      ,p_attribute17                  => p_pyp_attribute17
      ,p_attribute18                  => p_pyp_attribute18
      ,p_attribute19                  => p_pyp_attribute19
      ,p_attribute20                  => p_pyp_attribute20
      ,p_object_version_number        => l_pyp_object_version_number
      ,p_multiple_components          => 'N'
      ,p_approved                     => p_approved
      ,p_element_entry_id             => l_dummy_n
      ,p_inv_next_sal_date_warning    => l_inv_next_sal_date_warning
      ,p_proposed_salary_warning      => l_proposed_salary_warning
      ,p_approved_warning             => l_approved_warning
      ,p_payroll_warning              => l_payroll_warning
    );
  p_pay_proposal_id:=l_pay_proposal_id;
  p_pyp_object_version_number:=l_pyp_object_version_number;
  p_proposed_salary_warning:=l_proposed_salary_warning;
  p_approved_warning:=l_approved_warning;
  p_payroll_warning:=l_payroll_warning;
  END IF;
  --
  IF NVL(p_work_any_country,'N')<>'N'
  OR NVL(p_work_any_location,'N')<>'N'
  OR NVL(p_relocate_domestically,'N')<>'N'
  OR NVL(p_relocate_internationally,'N')<>'N'
  OR NVL(p_travel_required,'N')<>'N'
  OR p_country1 IS NOT NULL
  OR p_country2 IS NOT NULL
  OR p_country3 IS NOT NULL
  OR p_dpf_work_duration IS NOT NULL
  OR p_dpf_work_schedule IS NOT NULL
  OR p_dpf_work_hours IS NOT NULL
  OR p_dpf_fte_capacity IS NOT NULL
  OR NVL( p_visit_internationally,'N')<>'N'
  OR NVL(p_only_current_location,'N')<>'N'
  OR p_no_country1 IS NOT NULL
  OR p_no_country2 IS NOT NULL
  OR p_no_country3 IS NOT NULL
  OR p_earliest_available_date IS NOT NULL
  OR NVL(p_available_for_transfer,'N')<>'N'
  OR p_relocation_preference IS NOT NULL
  OR p_dpf_attribute_category IS NOT NULL
  OR p_dpf_attribute1  IS NOT NULL
  OR p_dpf_attribute2  IS NOT NULL
  OR p_dpf_attribute3  IS NOT NULL
  OR p_dpf_attribute4  IS NOT NULL
  OR p_dpf_attribute5  IS NOT NULL
  OR p_dpf_attribute6  IS NOT NULL
  OR p_dpf_attribute7  IS NOT NULL
  OR p_dpf_attribute8  IS NOT NULL
  OR p_dpf_attribute9  IS NOT NULL
  OR p_dpf_attribute10 IS NOT NULL
  OR p_dpf_attribute11 IS NOT NULL
  OR p_dpf_attribute12 IS NOT NULL
  OR p_dpf_attribute13 IS NOT NULL
  OR p_dpf_attribute14 IS NOT NULL
  OR p_dpf_attribute15 IS NOT NULL
  OR p_dpf_attribute16 IS NOT NULL
  OR p_dpf_attribute17 IS NOT NULL
  OR p_dpf_attribute18 IS NOT NULL
  OR p_dpf_attribute19 IS NOT NULL
  OR p_dpf_attribute20 IS NOT NULL THEN
    --
    hr_deployment_factor_api.create_person_dpmt_factor
    (p_effective_date                => l_creation_date  --p_effective_date
    ,p_person_id                     => l_person_id
    ,p_work_any_country              => p_work_any_country
    ,p_work_any_location             => p_work_any_location
    ,p_relocate_domestically         => p_relocate_domestically
    ,p_relocate_internationally      => p_relocate_internationally
    ,p_travel_required               => p_travel_required
    ,p_country1                      => p_country1
    ,p_country2                      => p_country2
    ,p_country3                      => p_country3
    ,p_work_duration                 => p_dpf_work_duration
    ,p_work_schedule                 => p_dpf_work_schedule
    ,p_work_hours                    => p_dpf_work_hours
    ,p_fte_capacity                  => p_dpf_fte_capacity
    ,p_visit_internationally         => p_visit_internationally
    ,p_only_current_location         => p_only_current_location
    ,p_no_country1                   => p_no_country1
    ,p_no_country2                   => p_no_country2
    ,p_no_country3                   => p_no_country3
    ,p_earliest_available_date       => p_earliest_available_date
    ,p_available_for_transfer        => p_available_for_transfer
    ,p_relocation_preference         => p_relocation_preference
    ,p_attribute_category            => p_dpf_attribute_category
    ,p_attribute1                    => p_dpf_attribute1
    ,p_attribute2                    => p_dpf_attribute2
    ,p_attribute3                    => p_dpf_attribute3
    ,p_attribute4                    => p_dpf_attribute4
    ,p_attribute5                    => p_dpf_attribute5
    ,p_attribute6                    => p_dpf_attribute6
    ,p_attribute7                    => p_dpf_attribute7
    ,p_attribute8                    => p_dpf_attribute8
    ,p_attribute9                    => p_dpf_attribute9
    ,p_attribute10                   => p_dpf_attribute10
    ,p_attribute11                   => p_dpf_attribute11
    ,p_attribute12                   => p_dpf_attribute12
    ,p_attribute13                   => p_dpf_attribute13
    ,p_attribute14                   => p_dpf_attribute14
    ,p_attribute15                   => p_dpf_attribute15
    ,p_attribute16                   => p_dpf_attribute16
    ,p_attribute17                   => p_dpf_attribute17
    ,p_attribute18                   => p_dpf_attribute18
    ,p_attribute19                   => p_dpf_attribute19
    ,p_attribute20                   => p_dpf_attribute20
    ,p_deployment_factor_id          => l_deployment_factor_id
    ,p_object_version_number         => l_dpf_object_version_number
    );
    p_dpf_object_version_number:=l_dpf_object_version_number;
    p_deployment_factor_id:=l_deployment_factor_id;
  END IF;
  --
  l_checklist_item_id:=p_chk1_checklist_item_id;
  l_chk_object_version_number:= p_chk1_object_version_number;
  --
  IF p_chk1_item_code IS NOT NULL AND
      (  p_chk1_status     IS NOT NULL
      OR p_chk1_date_due   IS NOT NULL
      OR p_chk1_date_done  IS NOT NULL
      OR p_chk1_notes      IS NOT NULL) THEN
    --
    l_checklist_item_id:=NULL;
    l_chk_object_version_number:= NULL;
    --
    per_checklist_items_api.cre_or_upd_checklist_items
    (p_checklist_item_id => l_checklist_item_id
    ,p_effective_date => l_creation_date  --p_effective_date
    ,p_object_version_number => l_chk_object_version_number
    ,p_person_id => l_person_id
    ,p_item_code => p_chk1_item_code
    ,p_date_due => p_chk1_date_due
    ,p_date_done => p_chk1_date_done
    ,p_status => p_chk1_status
    ,p_notes => p_chk1_notes
    );
    p_chk1_checklist_item_id:=l_checklist_item_id;
    p_chk1_object_version_number:=l_chk_object_version_number;
  END IF;
  --
  IF p_chk2_item_code IS NOT NULL AND
      (  p_chk2_status     IS NOT NULL
      OR p_chk2_date_due   IS NOT NULL
      OR p_chk2_date_done  IS NOT NULL
      OR p_chk2_notes      IS NOT NULL) THEN
    --
    l_checklist_item_id:=NULL;
    l_chk_object_version_number:= NULL;
    --
    per_checklist_items_api.cre_or_upd_checklist_items
    (p_checklist_item_id => l_checklist_item_id
    ,p_effective_date => l_creation_date  --p_effective_date
    ,p_object_version_number => l_chk_object_version_number
    ,p_person_id => l_person_id
    ,p_item_code => p_chk2_item_code
    ,p_date_due => p_chk2_date_due
    ,p_date_done => p_chk2_date_done
    ,p_status => p_chk2_status
    ,p_notes => p_chk2_notes
    );
    p_chk2_checklist_item_id:=l_checklist_item_id;
    p_chk2_object_version_number:=l_chk_object_version_number;
  END IF;
  --
  IF p_chk3_item_code IS NOT NULL AND
      (  p_chk3_status     IS NOT NULL
      OR p_chk3_date_due   IS NOT NULL
      OR p_chk3_date_done  IS NOT NULL
      OR p_chk3_notes      IS NOT NULL) THEN
    --
    l_checklist_item_id:=NULL;
    l_chk_object_version_number:= NULL;
    --
    per_checklist_items_api.cre_or_upd_checklist_items
    (p_checklist_item_id => l_checklist_item_id
    ,p_effective_date => l_creation_date  --p_effective_date
    ,p_object_version_number => l_chk_object_version_number
    ,p_person_id => l_person_id
    ,p_item_code => p_chk3_item_code
    ,p_date_due => p_chk3_date_due
    ,p_date_done => p_chk3_date_done
    ,p_status => p_chk3_status
    ,p_notes => p_chk3_notes
    );
    p_chk3_checklist_item_id:=l_checklist_item_id;
    p_chk3_object_version_number:=l_chk_object_version_number;
  END IF;
  --
  IF p_chk4_item_code IS NOT NULL AND
      (  p_chk4_status     IS NOT NULL
      OR p_chk4_date_due   IS NOT NULL
      OR p_chk4_date_done  IS NOT NULL
      OR p_chk4_notes      IS NOT NULL) THEN
    --
    l_checklist_item_id:=NULL;
    l_chk_object_version_number:= NULL;
    --
    per_checklist_items_api.cre_or_upd_checklist_items
    (p_checklist_item_id => l_checklist_item_id
    ,p_effective_date => l_creation_date  --p_effective_date
    ,p_object_version_number => l_chk_object_version_number
    ,p_person_id => l_person_id
    ,p_item_code => p_chk4_item_code
    ,p_date_due => p_chk4_date_due
    ,p_date_done => p_chk4_date_done
    ,p_status => p_chk4_status
    ,p_notes => p_chk4_notes
    );
    p_chk4_checklist_item_id:=l_checklist_item_id;
    p_chk4_object_version_number:=l_chk_object_version_number;
  END IF;
  --
  IF p_chk5_item_code IS NOT NULL AND
      (  p_chk5_status     IS NOT NULL
      OR p_chk5_date_due   IS NOT NULL
      OR p_chk5_date_done  IS NOT NULL
      OR p_chk5_notes      IS NOT NULL) THEN
    --
    l_checklist_item_id:=NULL;
    l_chk_object_version_number:= NULL;
    --
    per_checklist_items_api.cre_or_upd_checklist_items
    (p_checklist_item_id => l_checklist_item_id
    ,p_effective_date => l_creation_date  --p_effective_date
    ,p_object_version_number => l_chk_object_version_number
    ,p_person_id => l_person_id
    ,p_item_code => p_chk5_item_code
    ,p_date_due => p_chk5_date_due
    ,p_date_done => p_chk5_date_done
    ,p_status => p_chk5_status
    ,p_notes => p_chk5_notes
    );
    p_chk5_checklist_item_id:=l_checklist_item_id;
    p_chk5_object_version_number:=l_chk_object_version_number;
  END IF;
  --
  IF p_chk6_item_code IS NOT NULL AND
      (  p_chk6_status     IS NOT NULL
      OR p_chk6_date_due   IS NOT NULL
      OR p_chk6_date_done  IS NOT NULL
      OR p_chk6_notes      IS NOT NULL) THEN
    --
    l_checklist_item_id:=NULL;
    l_chk_object_version_number:= NULL;
    --
    per_checklist_items_api.cre_or_upd_checklist_items
    (p_checklist_item_id => l_checklist_item_id
    ,p_effective_date => l_creation_date  --p_effective_date
    ,p_object_version_number => l_chk_object_version_number
    ,p_person_id => l_person_id
    ,p_item_code => p_chk6_item_code
    ,p_date_due => p_chk6_date_due
    ,p_date_done => p_chk6_date_done
    ,p_status => p_chk6_status
    ,p_notes => p_chk6_notes
    );
    p_chk6_checklist_item_id:=l_checklist_item_id;
    p_chk6_object_version_number:=l_chk_object_version_number;
  END IF;
  --
  IF p_chk7_item_code IS NOT NULL AND
      (  p_chk7_status     IS NOT NULL
      OR p_chk7_date_due   IS NOT NULL
      OR p_chk7_date_done  IS NOT NULL
      OR p_chk7_notes      IS NOT NULL) THEN
    --
    l_checklist_item_id:=NULL;
    l_chk_object_version_number:= NULL;
    --
    per_checklist_items_api.cre_or_upd_checklist_items
    (p_checklist_item_id => l_checklist_item_id
    ,p_effective_date => l_creation_date  --p_effective_date
    ,p_object_version_number => l_chk_object_version_number
    ,p_person_id => l_person_id
    ,p_item_code => p_chk7_item_code
    ,p_date_due => p_chk7_date_due
    ,p_date_done => p_chk7_date_done
    ,p_status => p_chk7_status
    ,p_notes => p_chk7_notes
    );
    p_chk7_checklist_item_id:=l_checklist_item_id;
    p_chk7_object_version_number:=l_chk_object_version_number;
  END IF;
  --
  IF p_chk8_item_code IS NOT NULL AND
      (  p_chk8_status     IS NOT NULL
      OR p_chk8_date_due   IS NOT NULL
      OR p_chk8_date_done  IS NOT NULL
      OR p_chk8_notes      IS NOT NULL) THEN
    --
    l_checklist_item_id:=NULL;
    l_chk_object_version_number:= NULL;
    --
    per_checklist_items_api.cre_or_upd_checklist_items
    (p_checklist_item_id => l_checklist_item_id
    ,p_effective_date => l_creation_date  --p_effective_date
    ,p_object_version_number => l_chk_object_version_number
    ,p_person_id => l_person_id
    ,p_item_code => p_chk8_item_code
    ,p_date_due => p_chk8_date_due
    ,p_date_done => p_chk8_date_done
    ,p_status => p_chk8_status
    ,p_notes => p_chk8_notes
    );
    p_chk8_checklist_item_id:=l_checklist_item_id;
    p_chk8_object_version_number:=l_chk_object_version_number;
  END IF;
  --
  IF p_chk9_item_code IS NOT NULL AND
      (  p_chk9_status     IS NOT NULL
      OR p_chk9_date_due   IS NOT NULL
      OR p_chk9_date_done  IS NOT NULL
      OR p_chk9_notes      IS NOT NULL) THEN
    --
    l_checklist_item_id:=NULL;
    l_chk_object_version_number:= NULL;
    --
    per_checklist_items_api.cre_or_upd_checklist_items
    (p_checklist_item_id => l_checklist_item_id
    ,p_effective_date => l_creation_date  --p_effective_date
    ,p_object_version_number => l_chk_object_version_number
    ,p_person_id => l_person_id
    ,p_item_code => p_chk9_item_code
    ,p_date_due => p_chk9_date_due
    ,p_date_done => p_chk9_date_done
    ,p_status => p_chk9_status
    ,p_notes => p_chk9_notes
    );
    p_chk9_checklist_item_id:=l_checklist_item_id;
    p_chk9_object_version_number:=l_chk_object_version_number;
  END IF;
  --
  IF p_chk10_item_code IS NOT NULL AND
      (  p_chk10_status     IS NOT NULL
      OR p_chk10_date_due   IS NOT NULL
      OR p_chk10_date_done  IS NOT NULL
      OR p_chk10_notes      IS NOT NULL) THEN
    --
    l_checklist_item_id:=NULL;
    l_chk_object_version_number:= NULL;
    --
    per_checklist_items_api.cre_or_upd_checklist_items
    (p_checklist_item_id => l_checklist_item_id
    ,p_effective_date => l_creation_date  --p_effective_date
    ,p_object_version_number => l_chk_object_version_number
    ,p_person_id => l_person_id
    ,p_item_code => p_chk10_item_code
    ,p_date_due => p_chk10_date_due
    ,p_date_done => p_chk10_date_done
    ,p_status => p_chk10_status
    ,p_notes => p_chk10_notes
    );
    p_chk10_checklist_item_id:=l_checklist_item_id;
    p_chk10_object_version_number:=l_chk_object_version_number;
  END IF;
  --
  per_qh_tax_update.insert_tax_data
  (tax_effective_start_date => p_tax_effective_start_date
  ,tax_effective_end_date   => p_tax_effective_end_date
  ,tax_field1          => p_tax_field1
  ,tax_field2          => p_tax_field2
  ,tax_field3          => p_tax_field3
  ,tax_field4          => p_tax_field4
  ,tax_field5          => p_tax_field5
  ,tax_field6          => p_tax_field6
  ,tax_field7          => p_tax_field7
  ,tax_field8          => p_tax_field8
  ,tax_field9          => p_tax_field9
  ,tax_field10         => p_tax_field10
  ,tax_field11         => p_tax_field11
  ,tax_field12         => p_tax_field12
  ,tax_field13         => p_tax_field13
  ,tax_field14         => p_tax_field14
  ,tax_field15         => p_tax_field15
  ,tax_field16         => p_tax_field16
  ,tax_field17         => p_tax_field17
  ,tax_field18         => p_tax_field18
  ,tax_field19         => p_tax_field19
  ,tax_field20         => p_tax_field20
  ,tax_field21         => p_tax_field21
  ,tax_field22         => p_tax_field22
  ,tax_field23         => p_tax_field23
  ,tax_field24         => p_tax_field24
  ,tax_field25         => p_tax_field25
  ,tax_field26         => p_tax_field26
  ,tax_field27         => p_tax_field27
  ,tax_field28         => p_tax_field28
  ,tax_field29         => p_tax_field29
  ,tax_field30         => p_tax_field30
  ,tax_field31         => p_tax_field31
  ,tax_field32         => p_tax_field32
  ,tax_field33         => p_tax_field33
  ,tax_field34         => p_tax_field34
  ,tax_field35         => p_tax_field35
  ,tax_field36         => p_tax_field36
  ,tax_field37         => p_tax_field37
  ,tax_field38         => p_tax_field38
  ,tax_field39         => p_tax_field39
  ,tax_field40         => p_tax_field40
  ,tax_field41         => p_tax_field41
  ,tax_field42         => p_tax_field42
  ,tax_field43         => p_tax_field43
  ,tax_field44         => p_tax_field44
  ,tax_field45         => p_tax_field45
  ,tax_field46         => p_tax_field46
  ,tax_field47         => p_tax_field47
  ,tax_field48         => p_tax_field48
  ,tax_field49         => p_tax_field49
  ,tax_field50         => p_tax_field50
  ,tax_field51         => p_tax_field51
  ,tax_field52         => p_tax_field52
  ,tax_field53         => p_tax_field53
  ,tax_field54         => p_tax_field54
  ,tax_field55         => p_tax_field55
  ,tax_field56         => p_tax_field56
  ,tax_field57         => p_tax_field57
  ,tax_field58         => p_tax_field58
  ,tax_field59         => p_tax_field59
  ,tax_field60         => p_tax_field60
  ,tax_field61         => p_tax_field61
  ,tax_field62         => p_tax_field62
  ,tax_field63         => p_tax_field63
  ,tax_field64         => p_tax_field64
  ,tax_field65         => p_tax_field65
  ,tax_field66         => p_tax_field66
  ,tax_field67         => p_tax_field67
  ,tax_field68         => p_tax_field68
  ,tax_field69         => p_tax_field69
  ,tax_field70         => p_tax_field70
  ,tax_field71         => p_tax_field71
  ,tax_field72         => p_tax_field72
  ,tax_field73         => p_tax_field73
  ,tax_field74         => p_tax_field74
  ,tax_field75         => p_tax_field75
  ,tax_field76         => p_tax_field76
  ,tax_field77         => p_tax_field77
  ,tax_field78         => p_tax_field78
  ,tax_field79         => p_tax_field79
  ,tax_field80         => p_tax_field80
  ,tax_field81         => p_tax_field81
  ,tax_field82         => p_tax_field82
  ,tax_field83         => p_tax_field83
  ,tax_field84         => p_tax_field84
  ,tax_field85         => p_tax_field85
  ,tax_field86         => p_tax_field86
  ,tax_field87         => p_tax_field87
  ,tax_field88         => p_tax_field88
  ,tax_field89         => p_tax_field89
  ,tax_field90         => p_tax_field90
  ,tax_field91         => p_tax_field91
  ,tax_field92         => p_tax_field92
  ,tax_field93         => p_tax_field93
  ,tax_field94         => p_tax_field94
  ,tax_field95         => p_tax_field95
  ,tax_field96         => p_tax_field96
  ,tax_field97         => p_tax_field97
  ,tax_field98         => p_tax_field98
  ,tax_field99         => p_tax_field99
  ,tax_field100        => p_tax_field100
  ,tax_field101        => p_tax_field101
  ,tax_field102        => p_tax_field102
  ,tax_field103        => p_tax_field103
  ,tax_field104        => p_tax_field104
  ,tax_field105        => p_tax_field105
  ,tax_field106        => p_tax_field106
  ,tax_field107        => p_tax_field107
  ,tax_field108        => p_tax_field108
  ,tax_field109        => p_tax_field109
  ,tax_field110        => p_tax_field110
  ,tax_field111        => p_tax_field111
  ,tax_field112        => p_tax_field112
  ,tax_field113        => p_tax_field113
  ,tax_field114        => p_tax_field114
  ,tax_field115        => p_tax_field115
  ,tax_field116        => p_tax_field116
  ,tax_field117        => p_tax_field117
  ,tax_field118        => p_tax_field118
  ,tax_field119        => p_tax_field119
  ,tax_field120        => p_tax_field120
  ,tax_field121        => p_tax_field121
  ,tax_field122        => p_tax_field122
  ,tax_field123        => p_tax_field123
  ,tax_field124        => p_tax_field124
  ,tax_field125        => p_tax_field125
  ,tax_field126        => p_tax_field126
  ,tax_field127        => p_tax_field127
  ,tax_field128        => p_tax_field128
  ,tax_field129        => p_tax_field129
  ,tax_field130        => p_tax_field130
  ,tax_field131        => p_tax_field131
  ,tax_field132        => p_tax_field132
  ,tax_field133        => p_tax_field133
  ,tax_field134        => p_tax_field134
  ,tax_field135        => p_tax_field135
  ,tax_field136        => p_tax_field136
  ,tax_field137        => p_tax_field137
  ,tax_field138        => p_tax_field138
  ,tax_field139        => p_tax_field139
  ,tax_field140        => p_tax_field140
  ,tax_field141        => p_tax_field141
  ,tax_field142        => p_tax_field142
  ,tax_field143        => p_tax_field143
  ,tax_field144        => p_tax_field144
  ,tax_field145        => p_tax_field145
  ,tax_field146        => p_tax_field146
  ,tax_field147        => p_tax_field147
  ,tax_field148        => p_tax_field148
  ,tax_field149        => p_tax_field149
  ,tax_field150        => p_tax_field150
  ,p_person_id         => p_person_id
  ,p_assignment_id     => p_assignment_id
  ,p_legislation_code  => p_legislation_code
  ,p_effective_date    => l_creation_date  --p_effective_date
  );

  --start changes for bug 6598795

  hr_assignment.update_assgn_context_value (p_business_group_id,
				   p_person_id,
				   p_assignment_id,
				   p_effective_date);

  --end changes for bug 6598795
--
--If tax routines are used by localizations, they could have changed OVNs on some tables
--We need to provide code here to pass back the correct OVNs to the form
--
if p_person_id is not null then
  select per.object_version_number into l_per_object_version_number
  from per_all_people_f per
  where per.person_id=p_person_id
--  and p_effective_date between per.effective_start_date and per.effective_end_date;
  and l_creation_date between per.effective_start_date and per.effective_end_date;
  --
  p_per_object_version_number := l_per_object_version_number;
  --
end if;
if p_assignment_id is not null
and p_assignment_id > 0 then
  select asg.object_version_number into l_asg_object_version_number
  from per_all_assignments_f asg
  where asg.assignment_id=p_assignment_id
--  and p_effective_date between asg.effective_start_date and asg.effective_end_date;
  and l_creation_date between asg.effective_start_date and asg.effective_end_date;
  --
  p_asg_object_version_number := l_asg_object_version_number;
end if;
  --
  hr_utility.set_location('Insert After:' || fnd_profile.value('PER_ORGANIZATION_ID'), 13163);
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO insert_maintain_data;
    RAISE;
END insert_maintain_data;
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
) IS
--
  l_per_object_version_number per_all_people_f.object_version_number%TYPE;
  l_pdp_object_version_number       per_periods_of_placement.object_version_number%TYPE;
  l_employee_number                 per_all_people_f.employee_number%TYPE;
  l_npw_number                      per_all_people_f.npw_number%TYPE := p_npw_number;
  l_per_effective_start_date        DATE;
  l_per_effective_end_date          DATE;
  l_per_validation_start_date       DATE;
  l_per_validation_end_date         DATE;
  l_per_datetrack_update_mode              VARCHAR2(30);
  l_full_name                       per_all_people_f.full_name%TYPE;
  l_duplicate_flag                  VARCHAR2(1);
  l_comment_id                      NUMBER;
  l_name_combination_warning        BOOLEAN;
  l_assign_payroll_warning          BOOLEAN;
  l_orig_hire_warning               BOOLEAN;
--
  l_assignment_id NUMBER;
  l_assignment_sequence per_all_assignments_f.assignment_sequence%TYPE;
  l_assignment_number per_all_assignments_f.assignment_number%TYPE;
  l_asg_object_version_number per_all_assignments_f.object_version_number%TYPE;
  l_special_ceiling_step_id per_all_assignments_f.special_ceiling_step_id%TYPE;
  l_group_name                      VARCHAR2(240);
  l_asg_effective_start_date        DATE;
  l_asg_effective_end_date          DATE;
  l_asg_validation_start_date       DATE;
  l_asg_validation_end_date         DATE;
  l_asg_datetrack_update_mode              VARCHAR2(30);
  l_rate_datetrack_update_mode      VARCHAR2(30);
  l_people_group_id                 NUMBER;
  l_org_now_no_manager_warning      BOOLEAN;
  l_hourly_salaried_warning         BOOLEAN;
  l_other_manager_warning           BOOLEAN;
  l_spp_delete_warning              BOOLEAN;
  l_entries_changed_warning         VARCHAR2(30);
  l_tax_district_changed_warning    BOOLEAN;
  l_cagr_id_flex_num                NUMBER;
  l_cagr_grade_def_id               NUMBER;
  l_cagr_concatenated_segments      VARCHAR2(240);
--
  l_concatenated_segments           hr_soft_coding_keyflex.concatenated_segments%TYPE;
  l_soft_coding_keyflex_id          NUMBER;
  l_no_managers_warning             BOOLEAN;
  l_other_manager_warning2          BOOLEAN;
--
  l_pgp_rec pay_people_groups%ROWTYPE;
  l_scl_rec hr_soft_coding_keyflex%ROWTYPE;
--
  l_app_object_version_number per_applications.object_version_number%TYPE;
--
  l_address_id per_addresses.address_id%TYPE;
  l_addr_object_version_number per_addresses.object_version_number%TYPE;
--
  l_phone_id per_phones.phone_id%TYPE;
  l_phn_object_version_number per_phones.object_version_number%TYPE;
--
  l_deployment_factor_id per_deployment_factors.deployment_factor_id%TYPE;
  l_dpf_object_version_number per_deployment_factors.object_version_number%TYPE;
  l_pay_proposal_id per_pay_proposals.pay_proposal_id%TYPE;
  l_pyp_object_version_number per_pay_proposals.object_version_number%TYPE;
  l_element_entry_id             pay_element_entries_f.element_entry_id%TYPE;
  l_inv_next_sal_date_warning	 BOOLEAN;
  l_proposed_salary_warning      BOOLEAN;
  l_approved_warning             BOOLEAN;
  l_payroll_warning		 BOOLEAN;
--
  l_checklist_item_id per_checklist_items.checklist_item_id%TYPE;
  l_chk_object_version_number per_checklist_items.object_version_number%TYPE;
--
  l_grade_rule_id               pay_grade_rules_f.grade_rule_id%TYPE;
  l_rate_effective_start_date   pay_grade_rules_f.effective_start_date%TYPE;
  l_rate_effective_end_date     pay_grade_rules_f.effective_end_date%TYPE;
  l_rate_object_version_number  pay_grade_rules_f.object_version_number%TYPE;
--
  l_party_id per_all_people_f.party_id%TYPE;
--
  l_gsp_post_process_warning   varchar2(30); -- bug2999562
  l_gsp_post_process_warning2  varchar2(30);
  l_gsp_post_process_warning3  varchar2(30);
--
CURSOR csr_pgp_rec
      (p_people_group_id NUMBER) IS
SELECT * FROM pay_people_groups
WHERE people_group_id=p_people_group_id;
--
CURSOR csr_scl_rec
      (p_soft_coding_keyflex_id NUMBER) IS
SELECT * FROM hr_soft_coding_keyflex
WHERE soft_coding_keyflex_id=p_soft_coding_keyflex_id;
--


-- for disabling the descriptive flex field
l_add_struct_d hr_dflex_utility.l_ignore_dfcode_varray :=
                           hr_dflex_utility.l_ignore_dfcode_varray();
-- for disabling the key flex field
l_add_struct_k hr_kflex_utility.l_ignore_kfcode_varray :=
                           hr_kflex_utility.l_ignore_kfcode_varray();
--
--
-- start of bug 4553630
-- the following cursor have been defined so that it can validate the creation of primary
-- address as with this new code it is not possible to create two primary address
-- and also template definitions does not support creation of more than one primary address for any legislation.
l_check_primary varchar2(1);
cursor chk_primary is
select 'x'
from per_addresses
where person_id=p_person_id
and primary_flag='Y'
and p_effective_date between date_from and nvl(date_to,hr_api.g_eot);

-- end of bug 4553630

l_proc VARCHAR2(72) := g_package||'update_maintain_data';
BEGIN
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  per_qh_maintain_update.p_qh_organization_id := NULL;   --- Added For Bug # 6706502

  SAVEPOINT update_maintain_data;
  --
  -- start of bug 4553630
  if p_address_id is null   then
      open chk_primary ;
      fetch chk_primary into l_check_primary;
   if chk_primary%found then
       close chk_primary;
        hr_utility.set_message(800, 'HR_449032_PRIMARY_ADDR_EXISTS');
        hr_utility.raise_error;
   else
       close chk_primary;
    end if;
  end if;

 -- end of bug 4553630
   --
  l_per_object_version_number:=p_per_object_version_number;
  l_per_effective_start_date:=p_per_effective_start_date;
  l_per_effective_end_date:=p_per_effective_end_date;
  l_pdp_object_version_number:=p_pdp_object_version_number;
  l_employee_number:=p_employee_number;
  IF p_per_effective_start_date=p_effective_date THEN
    l_per_datetrack_update_mode:='CORRECTION';
  ELSE
    l_per_datetrack_update_mode:=p_datetrack_update_mode;
  END IF;
  --
  l_assignment_id:=p_assignment_id;
  l_assignment_sequence:=p_assignment_sequence;
  l_assignment_number:=p_assignment_number;
  l_asg_object_version_number:=p_asg_object_version_number;
  l_asg_effective_start_date:=p_asg_effective_start_date;
  l_asg_effective_end_date:=p_asg_effective_end_date;
  l_special_ceiling_step_id:=p_special_ceiling_step_id;
  l_people_group_id:=p_people_group_id;
  l_soft_coding_keyflex_id := p_soft_coding_keyflex_id;
  l_cagr_id_flex_num:=p_cagr_id_flex_num;
  l_cagr_grade_def_id:=p_cagr_grade_def_id;
  IF p_asg_effective_start_date=p_effective_date THEN
    l_asg_datetrack_update_mode:='CORRECTION';
  ELSE
    l_asg_datetrack_update_mode:=p_datetrack_update_mode;
  END IF;
  IF p_rate_effective_start_date is not null
  AND p_rate_effective_start_date=p_effective_date THEN
    l_rate_datetrack_update_mode:='CORRECTION';
  ELSE
    l_rate_datetrack_update_mode:=p_datetrack_update_mode;
  END IF;
 --
  l_app_object_version_number:=p_app_object_version_number;
  --
  l_addr_object_version_number:=p_addr_object_version_number;
  l_address_id:=p_address_id;
  --
  l_pyp_object_version_number:=p_pyp_object_version_number;
  l_pay_proposal_id:=p_pay_proposal_id;
  --
  l_dpf_object_version_number:=p_dpf_object_version_number;
  l_deployment_factor_id:=p_deployment_factor_id;
  --
  if p_rate_object_version_number is not null then
    l_grade_rule_id             := p_grade_rule_id;
    l_rate_object_version_number:= p_rate_object_version_number;
  end if;
  --
  hr_utility.set_location(l_proc, 20);
  --
  lock_maintain_data
  (p_effective_date                 => p_effective_date
  ,p_datetrack_update_mode          => p_datetrack_update_mode
  ,p_person_update_allowed          => p_person_update_allowed
  ,p_person_id                      => p_person_id
  ,p_per_effective_start_date       => l_per_effective_start_date
  ,p_per_effective_end_date         => l_per_effective_end_date
  ,p_per_validation_start_date      => l_per_validation_start_date
  ,p_per_validation_end_date        => l_per_validation_end_date
  ,p_per_object_version_number      => p_per_object_version_number
  ,p_placement_date_start           => p_placement_date_start
  ,p_pdp_object_version_number      => p_pdp_object_version_number
  ,p_grade_rule_id                  => p_grade_rule_id
  ,p_rate_effective_start_date      => p_rate_effective_start_date
  ,p_rate_effective_end_date        => p_rate_effective_end_date
  ,p_rate_object_version_number     => p_rate_object_version_number
  ,p_assignment_update_allowed      => p_assignment_update_allowed
  ,p_assignment_id                  => p_assignment_id
  ,p_asg_effective_start_date       => l_asg_effective_start_date
  ,p_asg_effective_end_date         => l_asg_effective_end_date
  ,p_asg_validation_start_date      => l_asg_validation_start_date
  ,p_asg_validation_end_date        => l_asg_validation_end_date
  ,p_asg_object_version_number      => p_asg_object_version_number
  ,p_application_id                 => p_application_id
  ,p_app_object_version_number      => p_app_object_version_number
  ,p_pds_object_version_number      => p_pds_object_version_number
  ,p_pds_hire_date                  => p_pds_hire_date
  ,p_address_id                     => p_address_id
  ,p_addr_object_version_number     => p_addr_object_version_number
  ,p_phn_h_phone_id                 => p_phn_h_phone_id
  ,p_phn_h_object_version_number    => p_phn_h_object_version_number
  ,p_phn_w_phone_id                 => p_phn_w_phone_id
  ,p_phn_w_object_version_number    => p_phn_w_object_version_number
  ,p_phn_m_phone_id                 => p_phn_m_phone_id
  ,p_phn_m_object_version_number    => p_phn_m_object_version_number
  ,p_phn_hf_phone_id                => p_phn_hf_phone_id
  ,p_phn_hf_object_version_number   => p_phn_hf_object_version_number
  ,p_phn_wf_phone_id                => p_phn_wf_phone_id
  ,p_phn_wf_object_version_number   => p_phn_wf_object_version_number
  ,p_pay_proposal_id                => p_pay_proposal_id
  ,p_pyp_object_version_number      => p_pyp_object_version_number
  ,p_deployment_factor_id           => p_deployment_factor_id
  ,p_dpf_object_version_number      => p_dpf_object_version_number
  ,p_chk1_checklist_item_id         => p_chk1_checklist_item_id
  ,p_chk1_object_version_number     => p_chk1_object_version_number
  ,p_chk2_checklist_item_id         => p_chk2_checklist_item_id
  ,p_chk2_object_version_number     => p_chk2_object_version_number
  ,p_chk3_checklist_item_id         => p_chk3_checklist_item_id
  ,p_chk3_object_version_number     => p_chk3_object_version_number
  ,p_chk4_checklist_item_id         => p_chk4_checklist_item_id
  ,p_chk4_object_version_number     => p_chk4_object_version_number
  ,p_chk5_checklist_item_id         => p_chk5_checklist_item_id
  ,p_chk5_object_version_number     => p_chk5_object_version_number
  ,p_chk6_checklist_item_id         => p_chk6_checklist_item_id
  ,p_chk6_object_version_number     => p_chk6_object_version_number
  ,p_chk7_checklist_item_id         => p_chk7_checklist_item_id
  ,p_chk7_object_version_number     => p_chk7_object_version_number
  ,p_chk8_checklist_item_id         => p_chk8_checklist_item_id
  ,p_chk8_object_version_number     => p_chk8_object_version_number
  ,p_chk9_checklist_item_id         => p_chk9_checklist_item_id
  ,p_chk9_object_version_number     => p_chk9_object_version_number
  ,p_chk10_checklist_item_id        => p_chk10_checklist_item_id
  ,p_chk10_object_version_number    => p_chk10_object_version_number
  );
  --
  hr_utility.set_location(l_proc, 30);
  --
  -- check to see if the person fields have been changed
  --
  IF p_person_update_allowed='TRUE' AND
    (NVL(per_per_shd.g_old_rec.effective_start_date,hr_api.g_date)
     <>NVL(l_per_effective_start_date,hr_api.g_date)
     OR NVL(per_per_shd.g_old_rec.effective_end_date,hr_api.g_date)
     <>NVL(l_per_effective_end_date,hr_api.g_date)
     AND NVL(per_per_shd.g_old_rec.person_type_id,hr_api.g_number)
     <>NVL(p_person_type_id,hr_api.g_number)
      OR NVL(per_per_shd.g_old_rec.last_name,hr_api.g_varchar2)
     <>NVL(p_last_name,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.start_date,hr_api.g_date)
     <>NVL(p_start_date,hr_api.g_date)
     OR NVL(per_per_shd.g_old_rec.applicant_number,hr_api.g_varchar2)
     <>NVL(p_applicant_number,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.background_check_status,hr_api.g_varchar2)
     <>NVL(p_background_check_status,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.background_date_check,hr_api.g_date)
     <>NVL(p_background_date_check,hr_api.g_date)
     OR NVL(per_per_shd.g_old_rec.blood_type,hr_api.g_varchar2)
     <>NVL(p_blood_type,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.correspondence_language,hr_api.g_varchar2)
     <>NVL(p_correspondence_language,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.current_applicant_flag,hr_api.g_varchar2)
     <>NVL(p_current_applicant_flag,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.current_emp_or_apl_flag,hr_api.g_varchar2)
     <>NVL(p_current_emp_or_apl_flag,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.current_employee_flag,hr_api.g_varchar2)
     <>NVL(p_current_employee_flag,hr_api.g_varchar2)
--CWK
     OR NVL(per_per_shd.g_old_rec.current_npw_flag,hr_api.g_varchar2)
     <>NVL(p_current_npw_flag,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.npw_number,hr_api.g_varchar2)
     <>NVL(p_npw_number,hr_api.g_varchar2)
--
     OR NVL(per_per_shd.g_old_rec.date_employee_data_verified,hr_api.g_date)
     <>NVL(p_date_employee_data_verified,hr_api.g_date)
     OR NVL(per_per_shd.g_old_rec.date_of_birth,hr_api.g_date)
     <>NVL(p_date_of_birth,hr_api.g_date)
     OR NVL(per_per_shd.g_old_rec.email_address,hr_api.g_varchar2)
     <>NVL(p_email_address,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.employee_number,hr_api.g_varchar2)
     <>NVL(p_employee_number,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.expense_check_send_to_address,hr_api.g_varchar2)
     <>NVL(p_expense_check_send_to_addres,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.first_name,hr_api.g_varchar2)
     <>NVL(p_first_name,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.fte_capacity,hr_api.g_number)
     <>NVL(p_per_fte_capacity,hr_api.g_number)
--removed for bugfix 2903984
--     OR NVL(per_per_shd.g_old_rec.full_name,hr_api.g_varchar2)
--    <>NVL(p_full_name,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.hold_applicant_date_until,hr_api.g_date)
     <>NVL(p_hold_applicant_date_until,hr_api.g_date)
     OR NVL(per_per_shd.g_old_rec.honors,hr_api.g_varchar2)
     <>NVL(p_honors,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.internal_location,hr_api.g_varchar2)
     <>NVL(p_internal_location,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.known_as,hr_api.g_varchar2)
     <>NVL(p_known_as,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.last_medical_test_by,hr_api.g_varchar2)
     <>NVL(p_last_medical_test_by,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.last_medical_test_date,hr_api.g_date)
     <>NVL(p_last_medical_test_date,hr_api.g_date)
     OR NVL(per_per_shd.g_old_rec.mailstop,hr_api.g_varchar2)
     <>NVL(p_mailstop,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.marital_status,hr_api.g_varchar2)
     <>NVL(p_marital_status,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.middle_names,hr_api.g_varchar2)
     <>NVL(p_middle_names,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.nationality,hr_api.g_varchar2)
     <>NVL(p_nationality,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.national_identifier,hr_api.g_varchar2)
     <>NVL(p_national_identifier,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.office_number,hr_api.g_varchar2)
     <>NVL(p_office_number,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.on_military_service,hr_api.g_varchar2)
     <>NVL(p_on_military_service,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.pre_name_adjunct,hr_api.g_varchar2)
     <>NVL(p_pre_name_adjunct,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.previous_last_name,hr_api.g_varchar2)
     <>NVL(p_previous_last_name,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.rehire_recommendation,hr_api.g_varchar2)
     <>NVL(p_rehire_recommendation,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.rehire_reason,hr_api.g_varchar2)
     <>NVL(p_rehire_reason,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.resume_exists,hr_api.g_varchar2)
     <>NVL(p_resume_exists,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.resume_last_updated,hr_api.g_date)
     <>NVL(p_resume_last_updated,hr_api.g_date)
     OR NVL(per_per_shd.g_old_rec.registered_disabled_flag,hr_api.g_varchar2)
     <>NVL(p_registered_disabled_flag,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.second_passport_exists,hr_api.g_varchar2)
     <>NVL(p_second_passport_exists,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.sex,hr_api.g_varchar2)
     <>NVL(p_sex,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.student_status,hr_api.g_varchar2)
     <>NVL(p_student_status,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.suffix,hr_api.g_varchar2)
     <>NVL(p_suffix,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.title,hr_api.g_varchar2)
     <>NVL(p_title,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.work_schedule,hr_api.g_varchar2)
     <>NVL(p_work_schedule,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.coord_ben_med_pln_no,hr_api.g_varchar2)
     <>NVL(p_coord_ben_med_pln_no,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.coord_ben_no_cvg_flag,hr_api.g_varchar2)
     <>NVL(p_coord_ben_no_cvg_flag,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.dpdnt_adoption_date,hr_api.g_date)
     <>NVL(p_dpdnt_adoption_date,hr_api.g_date)
     OR NVL(per_per_shd.g_old_rec.dpdnt_vlntry_svce_flag,hr_api.g_varchar2)
     <>NVL(p_dpdnt_vlntry_svce_flag,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.receipt_of_death_cert_date,hr_api.g_date)
     <>NVL(p_receipt_of_death_cert_date,hr_api.g_date)
     OR NVL(per_per_shd.g_old_rec.uses_tobacco_flag,hr_api.g_varchar2)
     <>NVL(p_uses_tobacco_flag,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.benefit_group_id,hr_api.g_number)
     <>NVL(p_benefit_group_id,hr_api.g_number)
     OR NVL(per_per_shd.g_old_rec.attribute_category,hr_api.g_varchar2)
     <>NVL(p_attribute_category,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.attribute1,hr_api.g_varchar2)
     <>NVL(p_attribute1,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.attribute2,hr_api.g_varchar2)
     <>NVL(p_attribute2,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.attribute3,hr_api.g_varchar2)
     <>NVL(p_attribute3,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.attribute4,hr_api.g_varchar2)
     <>NVL(p_attribute4,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.attribute5,hr_api.g_varchar2)
     <>NVL(p_attribute5,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.attribute6,hr_api.g_varchar2)
     <>NVL(p_attribute6,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.attribute7,hr_api.g_varchar2)
     <>NVL(p_attribute7,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.attribute8,hr_api.g_varchar2)
     <>NVL(p_attribute8,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.attribute9,hr_api.g_varchar2)
     <>NVL(p_attribute9,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.attribute10,hr_api.g_varchar2)
     <>NVL(p_attribute10,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.attribute11,hr_api.g_varchar2)
     <>NVL(p_attribute11,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.attribute12,hr_api.g_varchar2)
     <>NVL(p_attribute12,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.attribute13,hr_api.g_varchar2)
     <>NVL(p_attribute13,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.attribute14,hr_api.g_varchar2)
     <>NVL(p_attribute14,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.attribute15,hr_api.g_varchar2)
     <>NVL(p_attribute15,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.attribute16,hr_api.g_varchar2)
     <>NVL(p_attribute16,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.attribute17,hr_api.g_varchar2)
     <>NVL(p_attribute17,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.attribute18,hr_api.g_varchar2)
     <>NVL(p_attribute18,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.attribute19,hr_api.g_varchar2)
     <>NVL(p_attribute19,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.attribute20,hr_api.g_varchar2)
     <>NVL(p_attribute20,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.attribute21,hr_api.g_varchar2)
     <>NVL(p_attribute21,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.attribute22,hr_api.g_varchar2)
     <>NVL(p_attribute22,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.attribute23,hr_api.g_varchar2)
     <>NVL(p_attribute23,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.attribute24,hr_api.g_varchar2)
     <>NVL(p_attribute24,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.attribute25,hr_api.g_varchar2)
     <>NVL(p_attribute25,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.attribute26,hr_api.g_varchar2)
     <>NVL(p_attribute26,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.attribute27,hr_api.g_varchar2)
     <>NVL(p_attribute27,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.attribute28,hr_api.g_varchar2)
     <>NVL(p_attribute28,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.attribute29,hr_api.g_varchar2)
     <>NVL(p_attribute29,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.attribute30,hr_api.g_varchar2)
     <>NVL(p_attribute30,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.per_information_category,hr_api.g_varchar2)
     <>NVL(p_per_information_category,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.per_information1,hr_api.g_varchar2)
     <>NVL(p_per_information1,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.per_information2,hr_api.g_varchar2)
     <>NVL(p_per_information2,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.per_information3,hr_api.g_varchar2)
     <>NVL(p_per_information3,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.per_information4,hr_api.g_varchar2)
     <>NVL(p_per_information4,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.per_information5,hr_api.g_varchar2)
     <>NVL(p_per_information5,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.per_information6,hr_api.g_varchar2)
     <>NVL(p_per_information6,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.per_information7,hr_api.g_varchar2)
     <>NVL(p_per_information7,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.per_information8,hr_api.g_varchar2)
     <>NVL(p_per_information8,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.per_information9,hr_api.g_varchar2)
     <>NVL(p_per_information9,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.per_information10,hr_api.g_varchar2)
     <>NVL(p_per_information10,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.per_information11,hr_api.g_varchar2)
     <>NVL(p_per_information11,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.per_information12,hr_api.g_varchar2)
     <>NVL(p_per_information12,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.per_information13,hr_api.g_varchar2)
     <>NVL(p_per_information13,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.per_information14,hr_api.g_varchar2)
     <>NVL(p_per_information14,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.per_information15,hr_api.g_varchar2)
     <>NVL(p_per_information15,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.per_information16,hr_api.g_varchar2)
     <>NVL(p_per_information16,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.per_information17,hr_api.g_varchar2)
     <>NVL(p_per_information17,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.per_information18,hr_api.g_varchar2)
     <>NVL(p_per_information18,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.per_information19,hr_api.g_varchar2)
     <>NVL(p_per_information19,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.per_information20,hr_api.g_varchar2)
     <>NVL(p_per_information20,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.per_information21,hr_api.g_varchar2)
     <>NVL(p_per_information21,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.per_information22,hr_api.g_varchar2)
     <>NVL(p_per_information22,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.per_information23,hr_api.g_varchar2)
     <>NVL(p_per_information23,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.per_information24,hr_api.g_varchar2)
     <>NVL(p_per_information24,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.per_information25,hr_api.g_varchar2)
     <>NVL(p_per_information25,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.per_information26,hr_api.g_varchar2)
     <>NVL(p_per_information26,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.per_information27,hr_api.g_varchar2)
     <>NVL(p_per_information27,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.per_information28,hr_api.g_varchar2)
     <>NVL(p_per_information28,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.per_information29,hr_api.g_varchar2)
     <>NVL(p_per_information29,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.per_information30,hr_api.g_varchar2)
     <>NVL(p_per_information30,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.date_of_death,hr_api.g_date)
     <>NVL(p_date_of_death,hr_api.g_date)
     OR NVL(per_per_shd.g_old_rec.original_date_of_hire,hr_api.g_date)
     <>NVL(p_original_date_of_hire,hr_api.g_date)
     OR NVL(per_pds_shd.g_old_rec.adjusted_svc_date,hr_api.g_date)
     <>NVL(p_adjusted_svc_date,hr_api.g_date)
     OR NVL(per_per_shd.g_old_rec.town_of_birth,hr_api.g_varchar2)
     <>NVL(p_town_of_birth,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.region_of_birth,hr_api.g_varchar2)
     <>NVL(p_region_of_birth,hr_api.g_varchar2)
     OR NVL(per_per_shd.g_old_rec.country_of_birth,hr_api.g_varchar2)
     <>NVL(p_country_of_birth,hr_api.g_varchar2)
    ) THEN
    --
    hr_utility.set_location(l_proc, 40);
    --
    select party_id
      into l_party_id
      from per_all_people_f
     where person_id=p_person_id
       and p_effective_date between effective_start_date
                                and effective_end_date;
    hr_person_api.update_person
    (p_effective_date               => p_effective_date
    ,p_datetrack_update_mode        => l_per_datetrack_update_mode
    ,p_person_id                    => p_person_id
    ,p_party_id                     => l_party_id
    ,p_object_version_number        => l_per_object_version_number
    ,p_person_type_id               => p_person_type_id
    ,p_last_name                    => p_last_name
    ,p_applicant_number             => p_applicant_number
    ,p_date_employee_data_verified  => p_date_employee_data_verified
    ,p_date_of_birth                => p_date_of_birth
    ,p_email_address                => p_email_address
    ,p_employee_number              => l_employee_number
    ,p_npw_number                   => l_npw_number
    ,p_expense_check_send_to_addres => p_expense_check_send_to_addres
    ,p_first_name                   => p_first_name
    ,p_known_as                     => p_known_as
    ,p_marital_status               => p_marital_status
    ,p_middle_names                 => p_middle_names
    ,p_nationality                  => p_nationality
    ,p_national_identifier          => p_national_identifier
    ,p_previous_last_name           => p_previous_last_name
    ,p_registered_disabled_flag     => p_registered_disabled_flag
    ,p_sex                          => p_sex
    ,p_title                        => p_title
    ,p_attribute_category           => p_attribute_category
    ,p_attribute1                   => p_attribute1
    ,p_attribute2                   => p_attribute2
    ,p_attribute3                   => p_attribute3
    ,p_attribute4                   => p_attribute4
    ,p_attribute5                   => p_attribute5
    ,p_attribute6                   => p_attribute6
    ,p_attribute7                   => p_attribute7
    ,p_attribute8                   => p_attribute8
    ,p_attribute9                   => p_attribute9
    ,p_attribute10                  => p_attribute10
    ,p_attribute11                  => p_attribute11
    ,p_attribute12                  => p_attribute12
    ,p_attribute13                  => p_attribute13
    ,p_attribute14                  => p_attribute14
    ,p_attribute15                  => p_attribute15
    ,p_attribute16                  => p_attribute16
    ,p_attribute17                  => p_attribute17
    ,p_attribute18                  => p_attribute18
    ,p_attribute19                  => p_attribute19
    ,p_attribute20                  => p_attribute20
    ,p_attribute21                  => p_attribute21
    ,p_attribute22                  => p_attribute22
    ,p_attribute23                  => p_attribute23
    ,p_attribute24                  => p_attribute24
    ,p_attribute25                  => p_attribute25
    ,p_attribute26                  => p_attribute26
    ,p_attribute27                  => p_attribute27
    ,p_attribute28                  => p_attribute28
    ,p_attribute29                  => p_attribute29
    ,p_attribute30                  => p_attribute30
    ,p_per_information_category     => p_per_information_category
    ,p_per_information1             => p_per_information1
    ,p_per_information2             => p_per_information2
    ,p_per_information3             => p_per_information3
    ,p_per_information4             => p_per_information4
    ,p_per_information5             => p_per_information5
    ,p_per_information6             => p_per_information6
    ,p_per_information7             => p_per_information7
    ,p_per_information8             => p_per_information8
    ,p_per_information9             => p_per_information9
    ,p_per_information10            => p_per_information10
    ,p_per_information11            => p_per_information11
    ,p_per_information12            => p_per_information12
    ,p_per_information13            => p_per_information13
    ,p_per_information14            => p_per_information14
    ,p_per_information15            => p_per_information15
    ,p_per_information16            => p_per_information16
    ,p_per_information17            => p_per_information17
    ,p_per_information18            => p_per_information18
    ,p_per_information19            => p_per_information19
    ,p_per_information20            => p_per_information20
    ,p_per_information21            => p_per_information21
    ,p_per_information22            => p_per_information22
    ,p_per_information23            => p_per_information23
    ,p_per_information24            => p_per_information24
    ,p_per_information25            => p_per_information25
    ,p_per_information26            => p_per_information26
    ,p_per_information27            => p_per_information27
    ,p_per_information28            => p_per_information28
    ,p_per_information29            => p_per_information29
    ,p_per_information30            => p_per_information30
    ,p_date_of_death                => p_date_of_death
    ,p_background_check_status      => p_background_check_status
    ,p_background_date_check        => p_background_date_check
    ,p_blood_type                   => p_blood_type
    ,p_correspondence_language      => p_correspondence_language
    ,p_fte_capacity                 => p_per_fte_capacity
    ,p_hold_applicant_date_until    => p_hold_applicant_date_until
    ,p_honors                       => p_honors
    ,p_internal_location            => p_internal_location
    ,p_last_medical_test_by         => p_last_medical_test_by
    ,p_last_medical_test_date       => p_last_medical_test_date
    ,p_mailstop                     => p_mailstop
    ,p_office_number                => p_office_number
    ,p_on_military_service          => p_on_military_service
    ,p_pre_name_adjunct             => p_pre_name_adjunct
    ,p_rehire_recommendation        => p_rehire_recommendation
    ,p_rehire_reason                => p_rehire_reason
    ,p_resume_exists                => p_resume_exists
    ,p_resume_last_updated          => p_resume_last_updated
    ,p_second_passport_exists       => p_second_passport_exists
    ,p_student_status               => p_student_status
    ,p_work_schedule                => p_work_schedule
    ,p_suffix                       => p_suffix
    ,p_benefit_group_id             => p_benefit_group_id
    ,p_receipt_of_death_cert_date   => p_receipt_of_death_cert_date
    ,p_coord_ben_med_pln_no         => p_coord_ben_med_pln_no
    ,p_coord_ben_no_cvg_flag        => p_coord_ben_no_cvg_flag
    ,p_uses_tobacco_flag            => p_uses_tobacco_flag
    ,p_dpdnt_adoption_date          => p_dpdnt_adoption_date
    ,p_dpdnt_vlntry_svce_flag       => p_dpdnt_vlntry_svce_flag
    ,p_original_date_of_hire        => p_original_date_of_hire
    ,p_adjusted_svc_date            => p_adjusted_svc_date
    ,p_town_of_birth                => p_town_of_birth
    ,p_region_of_birth              => p_region_of_birth
    ,p_country_of_birth             => p_country_of_birth
    ,p_effective_start_date         => l_per_effective_start_date
    ,p_effective_end_date           => l_per_effective_end_date
    ,p_full_name                    => l_full_name
    ,p_comment_id                   => l_comment_id
    ,p_name_combination_warning     => l_name_combination_warning
    ,p_assign_payroll_warning       => l_assign_payroll_warning
    ,p_orig_hire_warning            => l_orig_hire_warning
    );
  END IF;
  --
  p_per_effective_start_date:=l_per_effective_start_date;
  p_per_effective_end_date:=l_per_effective_end_date;
  p_per_validation_start_date:=l_per_validation_start_date;
  p_per_validation_end_date:=l_per_validation_end_date;
  p_employee_number:=l_employee_number;
  p_per_object_version_number:=l_per_object_version_number;
  p_assign_payroll_warning:=l_assign_payroll_warning;
  p_orig_hire_warning:=l_orig_hire_warning;
  --changed as part of fix 2903984
  if l_full_name is not null then
    p_full_name:=l_full_name;
  else
      hr_person.derive_full_name(p_first_name
                                ,p_middle_names
                                ,p_last_name
                                ,p_known_as
                                ,p_title
                                ,p_suffix
                                ,p_date_of_birth
                                ,p_person_id
                                ,p_business_group_id
                                ,l_full_name
                                ,l_duplicate_flag
                                );
      p_full_name:=l_full_name;
  end if;
  --
  hr_utility.set_location(l_proc, 50);
  --
  --
  --removed clause which updated projected_placement_end on placement table
  --now that column is superceded by projected_assignment)_end on assignment
  --
-- Bug 3891200 Starts Here
-- Desc: Modified the if condition.to replace address_line1 with style and date_from
--  IF (p_address_id IS NULL AND p_address_line1 IS NOT NULL)
  IF (p_address_id IS NULL AND p_style IS NOT NULL and p_adr_date_from IS NOT NULL)
     OR (p_address_id IS NOT NULL AND (
        NVL(per_add_shd.g_old_rec.date_from,hr_api.g_date)
     <> NVL(p_adr_date_from,hr_api.g_date)
     OR NVL(per_add_shd.g_old_rec.style,hr_api.g_varchar2)
     <> NVL(p_style,hr_api.g_varchar2)
     OR NVL(per_add_shd.g_old_rec.address_line1,hr_api.g_varchar2)
     <> NVL(p_address_line1,hr_api.g_varchar2)
     OR NVL(per_add_shd.g_old_rec.address_line2,hr_api.g_varchar2)
     <> NVL(p_address_line2,hr_api.g_varchar2)
     OR NVL(per_add_shd.g_old_rec.address_line3,hr_api.g_varchar2)
     <> NVL(p_address_line3,hr_api.g_varchar2)
     OR NVL(per_add_shd.g_old_rec.address_type,hr_api.g_varchar2)
     <> NVL(p_address_type,hr_api.g_varchar2)
     OR NVL(per_add_shd.g_old_rec.country,hr_api.g_varchar2)
     <> NVL(p_country,hr_api.g_varchar2)
     OR NVL(per_add_shd.g_old_rec.date_to,hr_api.g_date)
     <> NVL(p_adr_date_to,hr_api.g_date)
     OR NVL(per_add_shd.g_old_rec.postal_code,hr_api.g_varchar2)
     <> NVL(p_postal_code,hr_api.g_varchar2)
     OR NVL(per_add_shd.g_old_rec.region_1,hr_api.g_varchar2)
     <> NVL(p_region_1,hr_api.g_varchar2)
     OR NVL(per_add_shd.g_old_rec.region_2,hr_api.g_varchar2)
     <> NVL(p_region_2,hr_api.g_varchar2)
     OR NVL(per_add_shd.g_old_rec.region_3,hr_api.g_varchar2)
     <> NVL(p_region_3,hr_api.g_varchar2)
     OR NVL(per_add_shd.g_old_rec.town_or_city,hr_api.g_varchar2)
     <> NVL(p_town_or_city,hr_api.g_varchar2)
     OR NVL(per_add_shd.g_old_rec.telephone_number_1,hr_api.g_varchar2)
     <> NVL(p_telephone_number_1,hr_api.g_varchar2)
     OR NVL(per_add_shd.g_old_rec.telephone_number_2,hr_api.g_varchar2)
     <> NVL(p_telephone_number_2,hr_api.g_varchar2)
     OR NVL(per_add_shd.g_old_rec.telephone_number_3,hr_api.g_varchar2)
     <> NVL(p_telephone_number_3,hr_api.g_varchar2)
     OR NVL(per_add_shd.g_old_rec.addr_attribute_category,hr_api.g_varchar2)
     <> NVL(p_addr_attribute_category,hr_api.g_varchar2)
     OR NVL(per_add_shd.g_old_rec.addr_attribute1,hr_api.g_varchar2)
     <> NVL(p_addr_attribute1,hr_api.g_varchar2)
     OR NVL(per_add_shd.g_old_rec.addr_attribute2,hr_api.g_varchar2)
     <> NVL(p_addr_attribute2,hr_api.g_varchar2)
     OR NVL(per_add_shd.g_old_rec.addr_attribute3,hr_api.g_varchar2)
     <> NVL(p_addr_attribute3,hr_api.g_varchar2)
     OR NVL(per_add_shd.g_old_rec.addr_attribute4,hr_api.g_varchar2)
     <> NVL(p_addr_attribute4,hr_api.g_varchar2)
     OR NVL(per_add_shd.g_old_rec.addr_attribute5,hr_api.g_varchar2)
     <> NVL(p_addr_attribute5,hr_api.g_varchar2)
     OR NVL(per_add_shd.g_old_rec.addr_attribute6,hr_api.g_varchar2)
     <> NVL(p_addr_attribute6,hr_api.g_varchar2)
     OR NVL(per_add_shd.g_old_rec.addr_attribute7,hr_api.g_varchar2)
     <> NVL(p_addr_attribute7,hr_api.g_varchar2)
     OR NVL(per_add_shd.g_old_rec.addr_attribute8,hr_api.g_varchar2)
     <> NVL(p_addr_attribute8,hr_api.g_varchar2)
     OR NVL(per_add_shd.g_old_rec.addr_attribute9,hr_api.g_varchar2)
     <> NVL(p_addr_attribute9,hr_api.g_varchar2)
     OR NVL(per_add_shd.g_old_rec.addr_attribute10,hr_api.g_varchar2)
     <> NVL(p_addr_attribute10,hr_api.g_varchar2)
     OR NVL(per_add_shd.g_old_rec.addr_attribute11,hr_api.g_varchar2)
     <> NVL(p_addr_attribute11,hr_api.g_varchar2)
     OR NVL(per_add_shd.g_old_rec.addr_attribute12,hr_api.g_varchar2)
     <> NVL(p_addr_attribute12,hr_api.g_varchar2)
     OR NVL(per_add_shd.g_old_rec.addr_attribute13,hr_api.g_varchar2)
     <> NVL(p_addr_attribute13,hr_api.g_varchar2)
     OR NVL(per_add_shd.g_old_rec.addr_attribute14,hr_api.g_varchar2)
     <> NVL(p_addr_attribute14,hr_api.g_varchar2)
     OR NVL(per_add_shd.g_old_rec.addr_attribute15,hr_api.g_varchar2)
     <> NVL(p_addr_attribute15,hr_api.g_varchar2)
     OR NVL(per_add_shd.g_old_rec.addr_attribute16,hr_api.g_varchar2)
     <> NVL(p_addr_attribute16,hr_api.g_varchar2)
     OR NVL(per_add_shd.g_old_rec.addr_attribute17,hr_api.g_varchar2)
     <> NVL(p_addr_attribute17,hr_api.g_varchar2)
     OR NVL(per_add_shd.g_old_rec.addr_attribute18,hr_api.g_varchar2)
     <> NVL(p_addr_attribute18,hr_api.g_varchar2)
     OR NVL(per_add_shd.g_old_rec.addr_attribute19,hr_api.g_varchar2)
     <> NVL(p_addr_attribute19,hr_api.g_varchar2)
     OR NVL(per_add_shd.g_old_rec.addr_attribute20,hr_api.g_varchar2)
     <> NVL(p_addr_attribute20,hr_api.g_varchar2)
-- Bug 3216519 Start Here
     OR NVL(per_add_shd.g_old_rec.add_information13,hr_api.g_varchar2)
     <> NVL(p_add_information13,hr_api.g_varchar2)
     OR NVL(per_add_shd.g_old_rec.add_information14,hr_api.g_varchar2)
     <> NVL(p_add_information14,hr_api.g_varchar2)
     OR NVL(per_add_shd.g_old_rec.add_information15,hr_api.g_varchar2)
     <> NVL(p_add_information15,hr_api.g_varchar2)
     OR NVL(per_add_shd.g_old_rec.add_information16,hr_api.g_varchar2)
     <> NVL(p_add_information16,hr_api.g_varchar2)
-- Bug 3216519 End Here
     OR NVL(per_add_shd.g_old_rec.add_information17,hr_api.g_varchar2)
     <> NVL(p_add_information17,hr_api.g_varchar2)
     OR NVL(per_add_shd.g_old_rec.add_information18,hr_api.g_varchar2)
     <> NVL(p_add_information18,hr_api.g_varchar2)
     OR NVL(per_add_shd.g_old_rec.add_information19,hr_api.g_varchar2)
     <> NVL(p_add_information19,hr_api.g_varchar2)
     OR NVL(per_add_shd.g_old_rec.add_information20,hr_api.g_varchar2)
     <> NVL(p_add_information20,hr_api.g_varchar2)
   ) ) THEN
    --
    --
    hr_utility.set_location(l_proc, 190);
    --
    hr_person_address_api.cre_or_upd_person_address
      (p_effective_date               => p_effective_date
      ,p_person_id                    => p_person_id
      ,p_update_mode                  => p_datetrack_update_mode
      ,p_primary_flag                 => 'Y'
      ,p_style                        => p_style
      ,p_date_from                    => p_adr_date_from
      ,p_date_to                      => p_adr_date_to
      ,p_address_type                 => p_address_type
      ,p_address_line1                => p_address_line1
      ,p_address_line2                => p_address_line2
      ,p_address_line3                => p_address_line3
      ,p_town_or_city                 => p_town_or_city
      ,p_region_1                     => p_region_1
      ,p_region_2                     => p_region_2
      ,p_region_3                     => p_region_3
      ,p_postal_code                  => p_postal_code
      ,p_country                      => p_country
      ,p_telephone_number_1           => p_telephone_number_1
      ,p_telephone_number_2           => p_telephone_number_2
      ,p_telephone_number_3           => p_telephone_number_3
      ,p_addr_attribute_category      => p_addr_attribute_category
      ,p_addr_attribute1              => p_addr_attribute1
      ,p_addr_attribute2              => p_addr_attribute2
      ,p_addr_attribute3              => p_addr_attribute3
      ,p_addr_attribute4              => p_addr_attribute4
      ,p_addr_attribute5              => p_addr_attribute5
      ,p_addr_attribute6              => p_addr_attribute6
      ,p_addr_attribute7              => p_addr_attribute7
      ,p_addr_attribute8              => p_addr_attribute8
      ,p_addr_attribute9              => p_addr_attribute9
      ,p_addr_attribute10             => p_addr_attribute10
      ,p_addr_attribute11             => p_addr_attribute11
      ,p_addr_attribute12             => p_addr_attribute12
      ,p_addr_attribute13             => p_addr_attribute13
      ,p_addr_attribute14             => p_addr_attribute14
      ,p_addr_attribute15             => p_addr_attribute15
      ,p_addr_attribute16             => p_addr_attribute16
      ,p_addr_attribute17             => p_addr_attribute17
      ,p_addr_attribute18             => p_addr_attribute18
      ,p_addr_attribute19             => p_addr_attribute19
      ,p_addr_attribute20             => p_addr_attribute20
--
--Bug 3216519 Start here
--
      ,p_add_information13            => p_add_information13
      ,p_add_information14            => p_add_information14
      ,p_add_information15            => p_add_information15
      ,p_add_information16            => p_add_information16
--
--Bug 3216519 End here
--
      ,p_add_information17            => p_add_information17
      ,p_add_information18            => p_add_information18
      ,p_add_information19            => p_add_information19
      ,p_add_information20            => p_add_information20
      ,p_address_id                   => l_address_id
      ,p_object_version_number        => l_addr_object_version_number
    );
    --
    --
    hr_utility.set_location(l_proc, 200);
    --
  END IF;
  --
  p_addr_object_version_number:=l_addr_object_version_number;
  p_address_id:=l_address_id;
  --
  --
  IF p_assignment_id IS NOT NULL THEN
  IF p_assignment_update_allowed='TRUE' THEN
    --
    -- check to see if the assignment data has changed
    --
    IF per_asg_shd.g_old_rec.people_group_id IS NOT NULL THEN
      --
      hr_utility.set_location(l_proc, 60);
      --
      OPEN csr_pgp_rec(per_asg_shd.g_old_rec.people_group_id);
      FETCH csr_pgp_rec INTO l_pgp_rec;
      CLOSE csr_pgp_rec;
    END IF;
    --
    IF per_asg_shd.g_old_rec.soft_coding_keyflex_id IS NOT NULL THEN
      --
      hr_utility.set_location(l_proc, 70);
      --
      OPEN csr_scl_rec(per_asg_shd.g_old_rec.soft_coding_keyflex_id);
      FETCH csr_scl_rec INTO l_scl_rec;
      CLOSE csr_scl_rec;
    END IF;
    --
    hr_utility.set_location(l_proc, 80);
    --
    IF NVL(per_asg_shd.g_old_rec.recruiter_id,hr_api.g_number)
       <>NVL(p_recruiter_id,hr_api.g_number)
       OR NVL(per_asg_shd.g_old_rec.grade_id,hr_api.g_number)
       <>NVL(p_grade_id,hr_api.g_number)
       OR NVL(per_asg_shd.g_old_rec.grade_ladder_pgm_id,hr_api.g_number)
       <>NVL(p_grade_ladder_pgm_id,hr_api.g_number)
       OR NVL(per_asg_shd.g_old_rec.position_id,hr_api.g_number)
       <>NVL(p_position_id,hr_api.g_number)
       OR NVL(per_asg_shd.g_old_rec.job_id,hr_api.g_number)
       <>NVL(p_job_id,hr_api.g_number)
       OR NVL(per_asg_shd.g_old_rec.assignment_status_type_id,hr_api.g_number)
       <>NVL(p_assignment_status_type_id,hr_api.g_number)
       OR NVL(per_asg_shd.g_old_rec.payroll_id,hr_api.g_number)
       <>NVL(p_payroll_id,hr_api.g_number)
       OR NVL(per_asg_shd.g_old_rec.location_id,hr_api.g_number)
       <>NVL(p_location_id,hr_api.g_number)
       OR NVL(per_asg_shd.g_old_rec.person_referred_by_id,hr_api.g_number)
       <>NVL(p_person_referred_by_id,hr_api.g_number)
       OR NVL(per_asg_shd.g_old_rec.supervisor_id,hr_api.g_number)
       <>NVL(p_supervisor_id,hr_api.g_number)
       OR NVL(per_asg_shd.g_old_rec.supervisor_assignment_id,hr_api.g_number)
       <>NVL(p_supervisor_assignment_id,hr_api.g_number)
       OR NVL(per_asg_shd.g_old_rec.recruitment_activity_id,hr_api.g_number)
       <>NVL(p_recruitment_activity_id,hr_api.g_number)
       OR NVL(per_asg_shd.g_old_rec.source_organization_id,hr_api.g_number)
       <>NVL(p_source_organization_id,hr_api.g_number)
       OR NVL(per_asg_shd.g_old_rec.organization_id,hr_api.g_number)
       <>NVL(p_organization_id,hr_api.g_number)
       OR NVL(l_pgp_rec.segment1,hr_api.g_varchar2)
       <>NVL(p_pgp_segment1,hr_api.g_varchar2)
       OR NVL(l_pgp_rec.segment2,hr_api.g_varchar2)
       <>NVL(p_pgp_segment2,hr_api.g_varchar2)
       OR NVL(l_pgp_rec.segment3,hr_api.g_varchar2)
       <>NVL(p_pgp_segment3,hr_api.g_varchar2)
       OR NVL(l_pgp_rec.segment4,hr_api.g_varchar2)
       <>NVL(p_pgp_segment4,hr_api.g_varchar2)
       OR NVL(l_pgp_rec.segment5,hr_api.g_varchar2)
       <>NVL(p_pgp_segment5,hr_api.g_varchar2)
       OR NVL(l_pgp_rec.segment6,hr_api.g_varchar2)
       <>NVL(p_pgp_segment6,hr_api.g_varchar2)
       OR NVL(l_pgp_rec.segment7,hr_api.g_varchar2)
       <>NVL(p_pgp_segment7,hr_api.g_varchar2)
       OR NVL(l_pgp_rec.segment8,hr_api.g_varchar2)
       <>NVL(p_pgp_segment8,hr_api.g_varchar2)
       OR NVL(l_pgp_rec.segment9,hr_api.g_varchar2)
       <>NVL(p_pgp_segment9,hr_api.g_varchar2)
       OR NVL(l_pgp_rec.segment10,hr_api.g_varchar2)
       <>NVL(p_pgp_segment10,hr_api.g_varchar2)
       OR NVL(l_pgp_rec.segment11,hr_api.g_varchar2)
       <>NVL(p_pgp_segment11,hr_api.g_varchar2)
       OR NVL(l_pgp_rec.segment12,hr_api.g_varchar2)
       <>NVL(p_pgp_segment12,hr_api.g_varchar2)
       OR NVL(l_pgp_rec.segment13,hr_api.g_varchar2)
       <>NVL(p_pgp_segment13,hr_api.g_varchar2)
       OR NVL(l_pgp_rec.segment14,hr_api.g_varchar2)
       <>NVL(p_pgp_segment14,hr_api.g_varchar2)
       OR NVL(l_pgp_rec.segment15,hr_api.g_varchar2)
       <>NVL(p_pgp_segment15,hr_api.g_varchar2)
       OR NVL(l_pgp_rec.segment16,hr_api.g_varchar2)
       <>NVL(p_pgp_segment16,hr_api.g_varchar2)
       OR NVL(l_pgp_rec.segment17,hr_api.g_varchar2)
       <>NVL(p_pgp_segment17,hr_api.g_varchar2)
       OR NVL(l_pgp_rec.segment18,hr_api.g_varchar2)
       <>NVL(p_pgp_segment18,hr_api.g_varchar2)
       OR NVL(l_pgp_rec.segment19,hr_api.g_varchar2)
       <>NVL(p_pgp_segment19,hr_api.g_varchar2)
       OR NVL(l_pgp_rec.segment20,hr_api.g_varchar2)
       <>NVL(p_pgp_segment20,hr_api.g_varchar2)
       OR NVL(l_pgp_rec.segment21,hr_api.g_varchar2)
       <>NVL(p_pgp_segment21,hr_api.g_varchar2)
       OR NVL(l_pgp_rec.segment22,hr_api.g_varchar2)
       <>NVL(p_pgp_segment22,hr_api.g_varchar2)
       OR NVL(l_pgp_rec.segment23,hr_api.g_varchar2)
       <>NVL(p_pgp_segment23,hr_api.g_varchar2)
       OR NVL(l_pgp_rec.segment24,hr_api.g_varchar2)
       <>NVL(p_pgp_segment24,hr_api.g_varchar2)
       OR NVL(l_pgp_rec.segment25,hr_api.g_varchar2)
       <>NVL(p_pgp_segment25,hr_api.g_varchar2)
       OR NVL(l_pgp_rec.segment26,hr_api.g_varchar2)
       <>NVL(p_pgp_segment26,hr_api.g_varchar2)
       OR NVL(l_pgp_rec.segment27,hr_api.g_varchar2)
       <>NVL(p_pgp_segment27,hr_api.g_varchar2)
       OR NVL(l_pgp_rec.segment28,hr_api.g_varchar2)
       <>NVL(p_pgp_segment28,hr_api.g_varchar2)
       OR NVL(l_pgp_rec.segment29,hr_api.g_varchar2)
       <>NVL(p_pgp_segment29,hr_api.g_varchar2)
       OR NVL(l_pgp_rec.segment30,hr_api.g_varchar2)
       <>NVL(p_pgp_segment30,hr_api.g_varchar2)
       OR NVL(l_scl_rec.segment1,hr_api.g_varchar2)
       <>NVL(p_scl_segment1,hr_api.g_varchar2)
       OR NVL(l_scl_rec.segment2,hr_api.g_varchar2)
       <>NVL(p_scl_segment2,hr_api.g_varchar2)
       OR NVL(l_scl_rec.segment3,hr_api.g_varchar2)
       <>NVL(p_scl_segment3,hr_api.g_varchar2)
       OR NVL(l_scl_rec.segment4,hr_api.g_varchar2)
       <>NVL(p_scl_segment4,hr_api.g_varchar2)
       OR NVL(l_scl_rec.segment5,hr_api.g_varchar2)
       <>NVL(p_scl_segment5,hr_api.g_varchar2)
       OR NVL(l_scl_rec.segment6,hr_api.g_varchar2)
       <>NVL(p_scl_segment6,hr_api.g_varchar2)
       OR NVL(l_scl_rec.segment7,hr_api.g_varchar2)
       <>NVL(p_scl_segment7,hr_api.g_varchar2)
       OR NVL(l_scl_rec.segment8,hr_api.g_varchar2)
       <>NVL(p_scl_segment8,hr_api.g_varchar2)
       OR NVL(l_scl_rec.segment9,hr_api.g_varchar2)
       <>NVL(p_scl_segment9,hr_api.g_varchar2)
       OR NVL(l_scl_rec.segment10,hr_api.g_varchar2)
       <>NVL(p_scl_segment10,hr_api.g_varchar2)
       OR NVL(l_scl_rec.segment11,hr_api.g_varchar2)
       <>NVL(p_scl_segment11,hr_api.g_varchar2)
       OR NVL(l_scl_rec.segment12,hr_api.g_varchar2)
       <>NVL(p_scl_segment12,hr_api.g_varchar2)
       OR NVL(l_scl_rec.segment13,hr_api.g_varchar2)
       <>NVL(p_scl_segment13,hr_api.g_varchar2)
       OR NVL(l_scl_rec.segment14,hr_api.g_varchar2)
       <>NVL(p_scl_segment14,hr_api.g_varchar2)
       OR NVL(l_scl_rec.segment15,hr_api.g_varchar2)
       <>NVL(p_scl_segment15,hr_api.g_varchar2)
       OR NVL(l_scl_rec.segment16,hr_api.g_varchar2)
       <>NVL(p_scl_segment16,hr_api.g_varchar2)
       OR NVL(l_scl_rec.segment17,hr_api.g_varchar2)
       <>NVL(p_scl_segment17,hr_api.g_varchar2)
       OR NVL(l_scl_rec.segment18,hr_api.g_varchar2)
       <>NVL(p_scl_segment18,hr_api.g_varchar2)
       OR NVL(l_scl_rec.segment19,hr_api.g_varchar2)
       <>NVL(p_scl_segment19,hr_api.g_varchar2)
       OR NVL(l_scl_rec.segment20,hr_api.g_varchar2)
       <>NVL(p_scl_segment20,hr_api.g_varchar2)
       OR NVL(l_scl_rec.segment21,hr_api.g_varchar2)
       <>NVL(p_scl_segment21,hr_api.g_varchar2)
       OR NVL(l_scl_rec.segment22,hr_api.g_varchar2)
       <>NVL(p_scl_segment22,hr_api.g_varchar2)
       OR NVL(l_scl_rec.segment23,hr_api.g_varchar2)
       <>NVL(p_scl_segment23,hr_api.g_varchar2)
       OR NVL(l_scl_rec.segment24,hr_api.g_varchar2)
       <>NVL(p_scl_segment24,hr_api.g_varchar2)
       OR NVL(l_scl_rec.segment25,hr_api.g_varchar2)
       <>NVL(p_scl_segment25,hr_api.g_varchar2)
       OR NVL(l_scl_rec.segment26,hr_api.g_varchar2)
       <>NVL(p_scl_segment26,hr_api.g_varchar2)
       OR NVL(l_scl_rec.segment27,hr_api.g_varchar2)
       <>NVL(p_scl_segment27,hr_api.g_varchar2)
       OR NVL(l_scl_rec.segment28,hr_api.g_varchar2)
       <>NVL(p_scl_segment28,hr_api.g_varchar2)
       OR NVL(l_scl_rec.segment29,hr_api.g_varchar2)
       <>NVL(p_scl_segment29,hr_api.g_varchar2)
       OR NVL(l_scl_rec.segment30,hr_api.g_varchar2)
       <>NVL(p_scl_segment30,hr_api.g_varchar2)
       OR NVL(per_asg_shd.g_old_rec.vacancy_id,hr_api.g_number)
       <>NVL(p_vacancy_id,hr_api.g_number)
       OR NVL(per_asg_shd.g_old_rec.pay_basis_id,hr_api.g_number)
       <>NVL(p_pay_basis_id,hr_api.g_number)
       OR NVL(per_asg_shd.g_old_rec.assignment_type,hr_api.g_varchar2)
       <>NVL(p_assignment_type,hr_api.g_varchar2)
       OR NVL(per_asg_shd.g_old_rec.primary_flag,hr_api.g_varchar2)
       <>NVL(p_asg_primary_flag,hr_api.g_varchar2)
       OR NVL(per_asg_shd.g_old_rec.assignment_number,hr_api.g_varchar2)
       <>NVL(l_assignment_number,hr_api.g_varchar2)
       OR NVL(per_asg_shd.g_old_rec.date_probation_end,hr_api.g_date)
       <>NVL(p_date_probation_end,hr_api.g_date)
       OR NVL(per_asg_shd.g_old_rec.default_code_comb_id,hr_api.g_number)
       <>NVL(p_default_code_comb_id,hr_api.g_number)
       OR NVL(per_asg_shd.g_old_rec.employment_category,hr_api.g_varchar2)
       <>NVL(p_employment_category,hr_api.g_varchar2)
       OR NVL(per_asg_shd.g_old_rec.employee_category,hr_api.g_varchar2)
       <>NVL(p_employee_category,hr_api.g_varchar2)
       OR NVL(per_asg_shd.g_old_rec.frequency,hr_api.g_varchar2)
       <>NVL(p_frequency,hr_api.g_varchar2)
       OR NVL(per_asg_shd.g_old_rec.normal_hours,hr_api.g_number)
       <>NVL(p_normal_hours,hr_api.g_number)
       OR NVL(per_asg_shd.g_old_rec.probation_period,hr_api.g_number)
       <>NVL(p_probation_period,hr_api.g_number)
       OR NVL(per_asg_shd.g_old_rec.probation_unit,hr_api.g_varchar2)
       <>NVL(p_probation_unit,hr_api.g_varchar2)
       OR NVL(per_asg_shd.g_old_rec.notice_period,hr_api.g_number)
       <>NVL(p_notice_period,hr_api.g_number)
       OR NVL(per_asg_shd.g_old_rec.notice_period_uom,hr_api.g_varchar2)
       <>NVL(p_notice_unit,hr_api.g_varchar2)
       OR NVL(per_asg_shd.g_old_rec.set_of_books_id,hr_api.g_number)
       <>NVL(p_set_of_books_id,hr_api.g_number)
       OR NVL(per_asg_shd.g_old_rec.title,hr_api.g_varchar2)
       <>NVL(p_billing_title,hr_api.g_varchar2)
       OR NVL(per_asg_shd.g_old_rec.time_normal_finish,hr_api.g_varchar2)
       <>NVL(p_time_normal_finish,hr_api.g_varchar2)
       OR NVL(per_asg_shd.g_old_rec.time_normal_start,hr_api.g_varchar2)
       <>NVL(p_time_normal_start,hr_api.g_varchar2)
       OR NVL(per_asg_shd.g_old_rec.ass_attribute_category,hr_api.g_varchar2)
       <>NVL(p_ass_attribute_category,hr_api.g_varchar2)
       OR NVL(per_asg_shd.g_old_rec.ass_attribute1,hr_api.g_varchar2)
       <>NVL(p_ass_attribute1,hr_api.g_varchar2)
       OR NVL(per_asg_shd.g_old_rec.ass_attribute2,hr_api.g_varchar2)
       <>NVL(p_ass_attribute2,hr_api.g_varchar2)
       OR NVL(per_asg_shd.g_old_rec.ass_attribute3,hr_api.g_varchar2)
       <>NVL(p_ass_attribute3,hr_api.g_varchar2)
       OR NVL(per_asg_shd.g_old_rec.ass_attribute4,hr_api.g_varchar2)
       <>NVL(p_ass_attribute4,hr_api.g_varchar2)
       OR NVL(per_asg_shd.g_old_rec.ass_attribute5,hr_api.g_varchar2)
       <>NVL(p_ass_attribute5,hr_api.g_varchar2)
       OR NVL(per_asg_shd.g_old_rec.ass_attribute6,hr_api.g_varchar2)
       <>NVL(p_ass_attribute6,hr_api.g_varchar2)
       OR NVL(per_asg_shd.g_old_rec.ass_attribute7,hr_api.g_varchar2)
       <>NVL(p_ass_attribute7,hr_api.g_varchar2)
       OR NVL(per_asg_shd.g_old_rec.ass_attribute8,hr_api.g_varchar2)
       <>NVL(p_ass_attribute8,hr_api.g_varchar2)
       OR NVL(per_asg_shd.g_old_rec.ass_attribute9,hr_api.g_varchar2)
       <>NVL(p_ass_attribute9,hr_api.g_varchar2)
       OR NVL(per_asg_shd.g_old_rec.ass_attribute10,hr_api.g_varchar2)
       <>NVL(p_ass_attribute10,hr_api.g_varchar2)
       OR NVL(per_asg_shd.g_old_rec.ass_attribute11,hr_api.g_varchar2)
       <>NVL(p_ass_attribute11,hr_api.g_varchar2)
       OR NVL(per_asg_shd.g_old_rec.ass_attribute12,hr_api.g_varchar2)
       <>NVL(p_ass_attribute12,hr_api.g_varchar2)
       OR NVL(per_asg_shd.g_old_rec.ass_attribute13,hr_api.g_varchar2)
       <>NVL(p_ass_attribute13,hr_api.g_varchar2)
       OR NVL(per_asg_shd.g_old_rec.ass_attribute14,hr_api.g_varchar2)
       <>NVL(p_ass_attribute14,hr_api.g_varchar2)
       OR NVL(per_asg_shd.g_old_rec.ass_attribute15,hr_api.g_varchar2)
       <>NVL(p_ass_attribute15,hr_api.g_varchar2)
       OR NVL(per_asg_shd.g_old_rec.ass_attribute16,hr_api.g_varchar2)
       <>NVL(p_ass_attribute16,hr_api.g_varchar2)
       OR NVL(per_asg_shd.g_old_rec.ass_attribute17,hr_api.g_varchar2)
       <>NVL(p_ass_attribute17,hr_api.g_varchar2)
       OR NVL(per_asg_shd.g_old_rec.ass_attribute18,hr_api.g_varchar2)
       <>NVL(p_ass_attribute18,hr_api.g_varchar2)
       OR NVL(per_asg_shd.g_old_rec.ass_attribute19,hr_api.g_varchar2)
       <>NVL(p_ass_attribute19,hr_api.g_varchar2)
       OR NVL(per_asg_shd.g_old_rec.ass_attribute20,hr_api.g_varchar2)
       <>NVL(p_ass_attribute20,hr_api.g_varchar2)
       OR NVL(per_asg_shd.g_old_rec.ass_attribute21,hr_api.g_varchar2)
       <>NVL(p_ass_attribute21,hr_api.g_varchar2)
       OR NVL(per_asg_shd.g_old_rec.ass_attribute22,hr_api.g_varchar2)
       <>NVL(p_ass_attribute22,hr_api.g_varchar2)
       OR NVL(per_asg_shd.g_old_rec.ass_attribute23,hr_api.g_varchar2)
       <>NVL(p_ass_attribute23,hr_api.g_varchar2)
       OR NVL(per_asg_shd.g_old_rec.ass_attribute24,hr_api.g_varchar2)
       <>NVL(p_ass_attribute24,hr_api.g_varchar2)
       OR NVL(per_asg_shd.g_old_rec.ass_attribute25,hr_api.g_varchar2)
       <>NVL(p_ass_attribute25,hr_api.g_varchar2)
       OR NVL(per_asg_shd.g_old_rec.ass_attribute26,hr_api.g_varchar2)
       <>NVL(p_ass_attribute26,hr_api.g_varchar2)
       OR NVL(per_asg_shd.g_old_rec.ass_attribute27,hr_api.g_varchar2)
       <>NVL(p_ass_attribute27,hr_api.g_varchar2)
       OR NVL(per_asg_shd.g_old_rec.ass_attribute28,hr_api.g_varchar2)
       <>NVL(p_ass_attribute28,hr_api.g_varchar2)
       OR NVL(per_asg_shd.g_old_rec.ass_attribute29,hr_api.g_varchar2)
       <>NVL(p_ass_attribute29,hr_api.g_varchar2)
       OR NVL(per_asg_shd.g_old_rec.ass_attribute30,hr_api.g_varchar2)
       <>NVL(p_ass_attribute30,hr_api.g_varchar2)
       OR NVL(per_asg_shd.g_old_rec.bargaining_unit_code,hr_api.g_varchar2)
       <>NVL(p_bargaining_unit_code,hr_api.g_varchar2)
       OR NVL(per_asg_shd.g_old_rec.labour_union_member_flag,hr_api.g_varchar2)
       <>NVL(p_labour_union_member_flag,hr_api.g_varchar2)
    --Bug 3063591 Start Here
       OR NVL(per_asg_shd.g_old_rec.work_at_home,hr_api.g_varchar2)
       <>NVL(p_work_at_home,hr_api.g_varchar2)
    --Bug 3063591 End Here
       OR NVL(per_asg_shd.g_old_rec.hourly_salaried_code,hr_api.g_varchar2)
       <>NVL(p_hourly_salaried_code,hr_api.g_varchar2)
       OR NVL(per_asg_shd.g_old_rec.special_ceiling_step_id,hr_api.g_number)
       <>NVL(p_special_ceiling_step_id,hr_api.g_number)
       OR NVL(per_asg_shd.g_old_rec.change_reason,hr_api.g_varchar2)
       <>NVL(p_change_reason,hr_api.g_varchar2)
       OR NVL(per_asg_shd.g_old_rec.internal_address_line,hr_api.g_varchar2)
       <>NVL(p_internal_address_line,hr_api.g_varchar2)
       OR NVL(per_asg_shd.g_old_rec.manager_flag,hr_api.g_varchar2)
       <>NVL(p_manager_flag,hr_api.g_varchar2)
       OR NVL(per_asg_shd.g_old_rec.perf_review_period,hr_api.g_number)
       <>NVL(p_perf_review_period,hr_api.g_number)
       OR NVL(per_asg_shd.g_old_rec.perf_review_period_frequency,hr_api.g_varchar2)
       <>NVL(p_perf_review_period_frequency,hr_api.g_varchar2)
       OR NVL(per_asg_shd.g_old_rec.sal_review_period,hr_api.g_number)
       <>NVL(p_sal_review_period,hr_api.g_number)
       OR NVL(per_asg_shd.g_old_rec.sal_review_period_frequency,hr_api.g_varchar2)
       <>NVL(p_sal_review_period_frequency,hr_api.g_varchar2)
       OR NVL(per_asg_shd.g_old_rec.source_type,hr_api.g_varchar2)
       <>NVL(p_source_type,hr_api.g_varchar2)
       OR NVL(per_asg_shd.g_old_rec.contract_id,hr_api.g_number)
       <>NVL(p_contract_id,hr_api.g_number)
       OR NVL(per_asg_shd.g_old_rec.collective_agreement_id,hr_api.g_number)
       <>NVL(p_collective_agreement_id,hr_api.g_number)
       OR NVL(per_asg_shd.g_old_rec.cagr_id_flex_num,hr_api.g_number)
       <>NVL(p_cagr_id_flex_num,hr_api.g_number)
       OR NVL(per_asg_shd.g_old_rec.cagr_grade_def_id,hr_api.g_number)
       <>NVL(p_cagr_grade_def_id,hr_api.g_number)
       OR NVL(per_asg_shd.g_old_rec.establishment_id,hr_api.g_number)
       <>NVL(p_establishment_id,hr_api.g_number)
--CWK
       OR NVL(per_asg_shd.g_old_rec.period_of_placement_date_start,hr_api.g_date)
       <>NVL(p_placement_date_start,hr_api.g_date)
       OR NVL(per_asg_shd.g_old_rec.vendor_id,hr_api.g_number)
       <>NVL(p_vendor_id,hr_api.g_number)
       OR NVL(per_asg_shd.g_old_rec.vendor_employee_number,hr_api.g_varchar2)
       <>NVL(p_vendor_employee_number,hr_api.g_varchar2)
       OR NVL(per_asg_shd.g_old_rec.vendor_assignment_number,hr_api.g_varchar2)
       <>NVL(p_vendor_assignment_number,hr_api.g_varchar2)
       OR NVL(per_asg_shd.g_old_rec.project_title,hr_api.g_varchar2)
       <>NVL(p_project_title,hr_api.g_varchar2)
       OR NVL(per_asg_shd.g_old_rec.vendor_site_id,hr_api.g_number)
       <>NVL(p_vendor_site_id,hr_api.g_number)
       OR NVL(per_asg_shd.g_old_rec.po_header_id,hr_api.g_number)
       <>NVL(p_po_header_id,hr_api.g_number)
       OR NVL(per_asg_shd.g_old_rec.po_line_id,hr_api.g_number)
       <>NVL(p_po_line_id,hr_api.g_number)
       OR NVL(per_asg_shd.g_old_rec.projected_assignment_end,hr_api.g_date)
       <>NVL(p_projected_assignment_end,hr_api.g_date)

      THEN
      --
      hr_utility.set_location(l_proc, 100);
      --
        --
        -- employee assignments
        --
        IF p_assignment_type='E' THEN
          --
          hr_utility.set_location(l_proc, 110);
          --
--
-- Bug 3174130 Start here
-- Description : Swapped the two assignment update procedures ' hr_assignment_api.update_emp_asg'
--               and ' hr_assignment_api.update_emp_asg_criteria' so that consistency can be implemented
--               with insert procedure. This will in turn resolve the updation problem on the assignment table.
--




-- perform field level validation first to obtain as much error information
-- as possible
--
-- call the assignment criteria api
-- this enters all of the data which have element link dependencies
--
  -- Added for turn off key flex field validation
  -- BUG 4539313 fix  turned off the key flex field validation only when legislation code is not US
  -- Bug  5150732 - included 'CA' in the if condition .
 if p_legislation_code not in ('US','CA') then
  l_add_struct_k.extend(1);
  l_add_struct_k(l_add_struct_k.count) := 'SCL';
  end if;
  -- BUG 4539313 ends here.
  l_add_struct_k.extend(1);
  l_add_struct_k(l_add_struct_k.count) := 'CAGR';

  hr_kflex_utility.create_ignore_kf_validation(p_rec => l_add_struct_k);
  --
  -- code for disabling the descriptive flex field
  l_add_struct_d.extend(1);
  l_add_struct_d(l_add_struct_d.count) := 'PER_ASSIGNMENTS';

 hr_dflex_utility.create_ignore_df_validation(p_rec => l_add_struct_d);
  --
          hr_assignment_api.update_emp_asg_criteria
          (p_effective_date               => p_effective_date
          ,p_datetrack_update_mode        => l_asg_datetrack_update_mode
          ,p_assignment_id                => l_assignment_id
          ,p_object_version_number        => l_asg_object_version_number
          ,p_grade_id                     => p_grade_id
          ,p_grade_ladder_pgm_id          => p_grade_ladder_pgm_id
          ,p_position_id                  => p_position_id
          ,p_job_id                       => p_job_id
          ,p_payroll_id                   => p_payroll_id
          ,p_location_id                  => p_location_id
          ,p_special_ceiling_step_id      => l_special_ceiling_step_id
          ,p_organization_id              => p_organization_id
          ,p_pay_basis_id                 => p_pay_basis_id
          ,p_segment1                     => p_pgp_segment1
          ,p_segment2                     => p_pgp_segment2
          ,p_segment3                     => p_pgp_segment3
          ,p_segment4                     => p_pgp_segment4
          ,p_segment5                     => p_pgp_segment5
          ,p_segment6                     => p_pgp_segment6
          ,p_segment7                     => p_pgp_segment7
          ,p_segment8                     => p_pgp_segment8
          ,p_segment9                     => p_pgp_segment9
          ,p_segment10                    => p_pgp_segment10
          ,p_segment11                    => p_pgp_segment11
          ,p_segment12                    => p_pgp_segment12
          ,p_segment13                    => p_pgp_segment13
          ,p_segment14                    => p_pgp_segment14
          ,p_segment15                    => p_pgp_segment15
          ,p_segment16                    => p_pgp_segment16
          ,p_segment17                    => p_pgp_segment17
          ,p_segment18                    => p_pgp_segment18
          ,p_segment19                    => p_pgp_segment19
          ,p_segment20                    => p_pgp_segment20
          ,p_segment21                    => p_pgp_segment21
          ,p_segment22                    => p_pgp_segment22
          ,p_segment23                    => p_pgp_segment23
          ,p_segment24                    => p_pgp_segment24
          ,p_segment25                    => p_pgp_segment25
          ,p_segment26                    => p_pgp_segment26
          ,p_segment27                    => p_pgp_segment27
          ,p_segment28                    => p_pgp_segment28
          ,p_segment29                    => p_pgp_segment29
          ,p_segment30                    => p_pgp_segment30
          ,p_employment_category          => p_employment_category
	  ,p_scl_segment1                 => p_scl_segment1  -- added for the bug 4539313
          ,p_group_name                   => l_group_name
          ,p_effective_start_date         => l_asg_effective_start_date
          ,p_effective_end_date           => l_asg_effective_end_date
          ,p_people_group_id              => l_people_group_id
          ,p_org_now_no_manager_warning   => l_org_now_no_manager_warning
          ,p_other_manager_warning        => l_other_manager_warning
          ,p_spp_delete_warning           => l_spp_delete_warning
          ,p_entries_changed_warning      => l_entries_changed_warning
          ,p_tax_district_changed_warning => l_tax_district_changed_warning
          ,p_soft_coding_keyflex_id       => l_soft_coding_keyflex_id
          ,p_concatenated_segments        => l_concatenated_segments
          ,p_gsp_post_process_warning     => l_gsp_post_process_warning -- bug2999562
          );

          --
          hr_utility.set_location(l_proc, 120);
          --
	   hr_dflex_utility.remove_ignore_df_validation;
           hr_kflex_utility.remove_ignore_kf_validation;


        hr_assignment_api.update_emp_asg
          (p_effective_date               => p_effective_date
          ,p_datetrack_update_mode        => 'CORRECTION'
          ,p_assignment_id                => l_assignment_id
          ,p_object_version_number        => l_asg_object_version_number
          ,p_supervisor_id                => p_supervisor_id
          ,p_supervisor_assignment_id     => p_supervisor_assignment_id
          ,p_assignment_number            => p_assignment_number
          ,p_change_reason                => p_change_reason
          ,p_assignment_status_type_id    => p_assignment_status_type_id
          ,p_date_probation_end           => p_date_probation_end
          ,p_default_code_comb_id         => p_default_code_comb_id
          ,p_frequency                    => p_frequency
          ,p_internal_address_line        => p_internal_address_line
          ,p_manager_flag                 => p_manager_flag
          ,p_normal_hours                 => p_normal_hours
          ,p_perf_review_period           => p_perf_review_period
          ,p_perf_review_period_frequency => p_perf_review_period_frequency
          ,p_probation_period             => p_probation_period
          ,p_probation_unit               => p_probation_unit
          ,p_notice_period                => p_notice_period
          ,p_notice_period_uom            => p_notice_unit
          ,p_employee_category            => p_employee_category
          ,p_sal_review_period            => p_sal_review_period
          ,p_sal_review_period_frequency  => p_sal_review_period_frequency
          ,p_set_of_books_id              => p_set_of_books_id
          ,p_title                        => p_billing_title
          ,p_source_type                  => p_source_type
          ,p_time_normal_finish           => p_time_normal_finish
          ,p_time_normal_start            => p_time_normal_start
          ,p_bargaining_unit_code         => p_bargaining_unit_code
          ,p_labour_union_member_flag     => p_labour_union_member_flag
          ,p_hourly_salaried_code         => p_hourly_salaried_code
          ,p_ass_attribute_category       => p_ass_attribute_category
          ,p_ass_attribute1               => p_ass_attribute1
          ,p_ass_attribute2               => p_ass_attribute2
          ,p_ass_attribute3               => p_ass_attribute3
          ,p_ass_attribute4               => p_ass_attribute4
          ,p_ass_attribute5               => p_ass_attribute5
          ,p_ass_attribute6               => p_ass_attribute6
          ,p_ass_attribute7               => p_ass_attribute7
          ,p_ass_attribute8               => p_ass_attribute8
          ,p_ass_attribute9               => p_ass_attribute9
          ,p_ass_attribute10              => p_ass_attribute10
          ,p_ass_attribute11              => p_ass_attribute11
          ,p_ass_attribute12              => p_ass_attribute12
          ,p_ass_attribute13              => p_ass_attribute13
          ,p_ass_attribute14              => p_ass_attribute14
          ,p_ass_attribute15              => p_ass_attribute15
          ,p_ass_attribute16              => p_ass_attribute16
          ,p_ass_attribute17              => p_ass_attribute17
          ,p_ass_attribute18              => p_ass_attribute18
          ,p_ass_attribute19              => p_ass_attribute19
          ,p_ass_attribute20              => p_ass_attribute20
          ,p_ass_attribute21              => p_ass_attribute21
          ,p_ass_attribute22              => p_ass_attribute22
          ,p_ass_attribute23              => p_ass_attribute23
          ,p_ass_attribute24              => p_ass_attribute24
          ,p_ass_attribute25              => p_ass_attribute25
          ,p_ass_attribute26              => p_ass_attribute26
          ,p_ass_attribute27              => p_ass_attribute27
          ,p_ass_attribute28              => p_ass_attribute28
          ,p_ass_attribute29              => p_ass_attribute29
          ,p_ass_attribute30              => p_ass_attribute30
          ,p_segment1                     => p_scl_segment1
          ,p_segment2                     => p_scl_segment2
          ,p_segment3                     => p_scl_segment3
          ,p_segment4                     => p_scl_segment4
          ,p_segment5                     => p_scl_segment5
          ,p_segment6                     => p_scl_segment6
          ,p_segment7                     => p_scl_segment7
          ,p_segment8                     => p_scl_segment8
          ,p_segment9                     => p_scl_segment9
          ,p_segment10                    => p_scl_segment10
          ,p_segment11                    => p_scl_segment11
          ,p_segment12                    => p_scl_segment12
          ,p_segment13                    => p_scl_segment13
          ,p_segment14                    => p_scl_segment14
          ,p_segment15                    => p_scl_segment15
          ,p_segment16                    => p_scl_segment16
          ,p_segment17                    => p_scl_segment17
          ,p_segment18                    => p_scl_segment18
          ,p_segment19                    => p_scl_segment19
          ,p_segment20                    => p_scl_segment20
          ,p_segment21                    => p_scl_segment21
          ,p_segment22                    => p_scl_segment22
          ,p_segment23                    => p_scl_segment23
          ,p_segment24                    => p_scl_segment24
          ,p_segment25                    => p_scl_segment25
          ,p_segment26                    => p_scl_segment26
          ,p_segment27                    => p_scl_segment27
          ,p_segment28                    => p_scl_segment28
          ,p_segment29                    => p_scl_segment29
          ,p_segment30                    => p_scl_segment30
          ,p_concatenated_segments        => l_concatenated_segments
          ,p_contract_id                  =>     p_contract_id
          ,p_establishment_id             =>     p_establishment_id
          ,p_collective_agreement_id      =>     p_collective_agreement_id
          ,p_cagr_id_flex_num             =>     l_cagr_id_flex_num
          ,p_cagr_grade_def_id            =>     l_cagr_grade_def_id
    --Bug 3063591 Start Here
          ,p_work_at_home                 =>     p_work_at_home
    --Bug 3063591 End Here
          ,p_cagr_concatenated_segments   =>     l_cagr_concatenated_segments
          ,p_soft_coding_keyflex_id       => l_soft_coding_keyflex_id
          ,p_comment_id                   => l_comment_id
          ,p_effective_start_date         => l_asg_effective_start_date
          ,p_effective_end_date           => l_asg_effective_end_date
          ,p_no_managers_warning          => l_no_managers_warning
          ,p_other_manager_warning        => l_other_manager_warning2
          ,p_hourly_salaried_warning      => l_hourly_salaried_warning
          ,p_gsp_post_process_warning     => l_gsp_post_process_warning2 -- bug2999562
          );

          --
          hr_utility.set_location(l_proc, 130);
          --
--
-- Bug 3174130 End here
--

        IF l_no_managers_warning THEN
          l_org_now_no_manager_warning:=TRUE;
        END IF;
        --
        IF l_other_manager_warning2 THEN
          l_other_manager_warning:=TRUE;
        END IF;
        --
        IF l_spp_delete_warning THEN
          --
          fnd_message.set_name('PER', 'HR_289828_INV_SPP_CHANGE');
          hr_utility.raise_error;
          --
        END IF;
        --
        hr_utility.set_location(l_proc, 140);
        --
      ELSIF p_assignment_type = 'A' then
          --
          hr_utility.set_location(l_proc, 150);
          --
        hr_assignment_api.update_apl_asg
          (p_effective_date               =>     p_effective_date
          ,p_datetrack_update_mode        =>     l_asg_datetrack_update_mode
          ,p_assignment_id                =>     l_assignment_id
          ,p_object_version_number        =>     l_asg_object_version_number
          ,p_grade_id                     =>     p_grade_id
          ,p_grade_ladder_pgm_id          =>     p_grade_ladder_pgm_id
          ,p_job_id                       =>     p_job_id
          ,p_payroll_id                   =>     p_payroll_id
          ,p_location_id                  =>     p_location_id
          ,p_organization_id              =>     p_organization_id
          ,p_position_id                  =>     p_position_id
          ,p_application_id               =>     p_application_id
          ,p_special_ceiling_step_id      =>     p_special_ceiling_step_id
          ,p_recruiter_id                 =>     p_recruiter_id
          ,p_recruitment_activity_id      =>     p_recruitment_activity_id
          ,p_vacancy_id                   =>     p_vacancy_id
          ,p_pay_basis_id                 =>     p_pay_basis_id
          ,p_person_referred_by_id        =>     p_person_referred_by_id
          ,p_supervisor_id                =>     p_supervisor_id
          ,p_supervisor_assignment_id     =>     p_supervisor_assignment_id
          ,p_source_organization_id       =>     p_source_organization_id
          ,p_change_reason                =>     p_change_reason
          ,p_assignment_status_type_id    =>     p_assignment_status_type_id
          ,p_internal_address_line        =>     p_internal_address_line
          ,p_default_code_comb_id         =>     p_default_code_comb_id
          ,p_employment_category          =>     p_employment_category
          ,p_frequency                    =>     p_frequency
          ,p_manager_flag                 =>     p_manager_flag
          ,p_normal_hours                 =>     p_normal_hours
          ,p_perf_review_period           =>     p_perf_review_period
          ,p_perf_review_period_frequency =>     p_perf_review_period_frequency
          ,p_probation_period             =>     p_probation_period
          ,p_probation_unit               =>     p_probation_unit
          ,p_sal_review_period            =>     p_sal_review_period
          ,p_sal_review_period_frequency  =>     p_sal_review_period_frequency
          ,p_set_of_books_id              =>     p_set_of_books_id
          ,p_title                        =>     p_billing_title
          ,p_source_type                  =>     p_source_type
          ,p_time_normal_finish           =>     p_time_normal_finish
          ,p_time_normal_start            =>     p_time_normal_start
          ,p_bargaining_unit_code         =>     p_bargaining_unit_code
          ,p_date_probation_end           =>     p_date_probation_end
          ,p_ass_attribute_category       =>     p_ass_attribute_category
          ,p_ass_attribute1               =>     p_ass_attribute1
          ,p_ass_attribute2               =>     p_ass_attribute2
          ,p_ass_attribute3               =>     p_ass_attribute3
          ,p_ass_attribute4               =>     p_ass_attribute4
          ,p_ass_attribute5               =>     p_ass_attribute5
          ,p_ass_attribute6               =>     p_ass_attribute6
          ,p_ass_attribute7               =>     p_ass_attribute7
          ,p_ass_attribute8               =>     p_ass_attribute8
          ,p_ass_attribute9               =>     p_ass_attribute9
          ,p_ass_attribute10              =>     p_ass_attribute10
          ,p_ass_attribute11              =>     p_ass_attribute11
          ,p_ass_attribute12              =>     p_ass_attribute12
          ,p_ass_attribute13              =>     p_ass_attribute13
          ,p_ass_attribute14              =>     p_ass_attribute14
          ,p_ass_attribute15              =>     p_ass_attribute15
          ,p_ass_attribute16              =>     p_ass_attribute16
          ,p_ass_attribute17              =>     p_ass_attribute17
          ,p_ass_attribute18              =>     p_ass_attribute18
          ,p_ass_attribute19              =>     p_ass_attribute19
          ,p_ass_attribute20              =>     p_ass_attribute20
          ,p_ass_attribute21              =>     p_ass_attribute21
          ,p_ass_attribute22              =>     p_ass_attribute22
          ,p_ass_attribute23              =>     p_ass_attribute23
          ,p_ass_attribute24              =>     p_ass_attribute24
          ,p_ass_attribute25              =>     p_ass_attribute25
          ,p_ass_attribute26              =>     p_ass_attribute26
          ,p_ass_attribute27              =>     p_ass_attribute27
          ,p_ass_attribute28              =>     p_ass_attribute28
          ,p_ass_attribute29              =>     p_ass_attribute29
          ,p_ass_attribute30              =>     p_ass_attribute30
          ,p_scl_segment1                 =>     p_scl_segment1
          ,p_scl_segment2                 =>     p_scl_segment2
          ,p_scl_segment3                 =>     p_scl_segment3
          ,p_scl_segment4                 =>     p_scl_segment4
          ,p_scl_segment5                 =>     p_scl_segment5
          ,p_scl_segment6                 =>     p_scl_segment6
          ,p_scl_segment7                 =>     p_scl_segment7
          ,p_scl_segment8                 =>     p_scl_segment8
          ,p_scl_segment9                 =>     p_scl_segment9
          ,p_scl_segment10                =>     p_scl_segment10
          ,p_scl_segment11                =>     p_scl_segment11
          ,p_scl_segment12                =>     p_scl_segment12
          ,p_scl_segment13                =>     p_scl_segment13
          ,p_scl_segment14                =>     p_scl_segment14
          ,p_scl_segment15                =>     p_scl_segment15
          ,p_scl_segment16                =>     p_scl_segment16
          ,p_scl_segment17                =>     p_scl_segment17
          ,p_scl_segment18                =>     p_scl_segment18
          ,p_scl_segment19                =>     p_scl_segment19
          ,p_scl_segment20                =>     p_scl_segment20
          ,p_scl_segment21                =>     p_scl_segment21
          ,p_scl_segment22                =>     p_scl_segment22
          ,p_scl_segment23                =>     p_scl_segment23
          ,p_scl_segment24                =>     p_scl_segment24
          ,p_scl_segment25                =>     p_scl_segment25
          ,p_scl_segment26                =>     p_scl_segment26
          ,p_scl_segment27                =>     p_scl_segment27
          ,p_scl_segment28                =>     p_scl_segment28
          ,p_scl_segment29                =>     p_scl_segment29
          ,p_scl_segment30                =>     p_scl_segment30
          ,p_pgp_segment1                 =>     p_pgp_segment1
          ,p_pgp_segment2                 =>     p_pgp_segment2
          ,p_pgp_segment3                 =>     p_pgp_segment3
          ,p_pgp_segment4                 =>     p_pgp_segment4
          ,p_pgp_segment5                 =>     p_pgp_segment5
          ,p_pgp_segment6                 =>     p_pgp_segment6
          ,p_pgp_segment7                 =>     p_pgp_segment7
          ,p_pgp_segment8                 =>     p_pgp_segment8
          ,p_pgp_segment9                 =>     p_pgp_segment9
          ,p_pgp_segment10                =>     p_pgp_segment10
          ,p_pgp_segment11                =>     p_pgp_segment11
          ,p_pgp_segment12                =>     p_pgp_segment12
          ,p_pgp_segment13                =>     p_pgp_segment13
          ,p_pgp_segment14                =>     p_pgp_segment14
          ,p_pgp_segment15                =>     p_pgp_segment15
          ,p_pgp_segment16                =>     p_pgp_segment16
          ,p_pgp_segment17                =>     p_pgp_segment17
          ,p_pgp_segment18                =>     p_pgp_segment18
          ,p_pgp_segment19                =>     p_pgp_segment19
          ,p_pgp_segment20                =>     p_pgp_segment20
          ,p_pgp_segment21                =>     p_pgp_segment21
          ,p_pgp_segment22                =>     p_pgp_segment22
          ,p_pgp_segment23                =>     p_pgp_segment23
          ,p_pgp_segment24                =>     p_pgp_segment24
          ,p_pgp_segment25                =>     p_pgp_segment25
          ,p_pgp_segment26                =>     p_pgp_segment26
          ,p_pgp_segment27                =>     p_pgp_segment27
          ,p_pgp_segment28                =>     p_pgp_segment28
          ,p_pgp_segment29                =>     p_pgp_segment29
          ,p_pgp_segment30                =>     p_pgp_segment30
          ,p_contract_id                  =>     p_contract_id
          ,p_establishment_id             =>     p_establishment_id
          ,p_collective_agreement_id      =>     p_collective_agreement_id
          ,p_cagr_id_flex_num             =>     l_cagr_id_flex_num
          ,p_cagr_grade_def_id            =>     l_cagr_grade_def_id
    --Bug 3063591 Start Here
          ,p_work_at_home                 =>     p_work_at_home
          ,p_notice_period                =>     p_notice_period
          ,p_notice_period_uom            =>     p_notice_unit
    --Bug 3063591 End Here
          ,p_cagr_concatenated_segments   =>     l_cagr_concatenated_segments
          ,p_group_name                   =>     l_group_name
          ,p_concatenated_segments        =>     l_concatenated_segments
          ,p_comment_id                   =>     l_comment_id
          ,p_people_group_id              =>     l_people_group_id
          ,p_soft_coding_keyflex_id       =>     l_soft_coding_keyflex_id
          ,p_effective_start_date         =>     l_asg_effective_start_date
          ,p_effective_end_date           =>     l_asg_effective_end_date
        );
        --
        hr_utility.set_location(l_proc, 160);
        --
      ELSIF p_assignment_type = 'C' then
	hr_assignment_api.update_cwk_asg_criteria
	  (p_effective_date               => p_effective_date
	  ,p_datetrack_update_mode        => l_asg_datetrack_update_mode
	  ,p_assignment_id                => l_assignment_id
	  ,p_object_version_number        => l_asg_object_version_number
	  ,p_grade_id                     => p_grade_id
	  ,p_position_id                  => p_position_id
	  ,p_job_id                       => p_job_id
--          ,p_payroll_id                   => p_payroll_id
	  ,p_location_id                  => p_location_id
	  ,p_organization_id              => p_organization_id
--          ,p_pay_basis_id                 => p_pay_basis_id
	  ,p_segment1                     => p_pgp_segment1
	  ,p_segment2                     => p_pgp_segment2
	  ,p_segment3                     => p_pgp_segment3
	  ,p_segment4                     => p_pgp_segment4
	  ,p_segment5                     => p_pgp_segment5
	  ,p_segment6                     => p_pgp_segment6
	  ,p_segment7                     => p_pgp_segment7
	  ,p_segment8                     => p_pgp_segment8
	  ,p_segment9                     => p_pgp_segment9
	  ,p_segment10                    => p_pgp_segment10
	  ,p_segment11                    => p_pgp_segment11
	  ,p_segment12                    => p_pgp_segment12
	  ,p_segment13                    => p_pgp_segment13
	  ,p_segment14                    => p_pgp_segment14
	  ,p_segment15                    => p_pgp_segment15
	  ,p_segment16                    => p_pgp_segment16
	  ,p_segment17                    => p_pgp_segment17
	  ,p_segment18                    => p_pgp_segment18
	  ,p_segment19                    => p_pgp_segment19
	  ,p_segment20                    => p_pgp_segment20
	  ,p_segment21                    => p_pgp_segment21
	  ,p_segment22                    => p_pgp_segment22
	  ,p_segment23                    => p_pgp_segment23
	  ,p_segment24                    => p_pgp_segment24
	  ,p_segment25                    => p_pgp_segment25
	  ,p_segment26                    => p_pgp_segment26
	  ,p_segment27                    => p_pgp_segment27
	  ,p_segment28                    => p_pgp_segment28
	  ,p_segment29                    => p_pgp_segment29
	  ,p_segment30                    => p_pgp_segment30
	  ,p_people_group_name            => l_group_name
	  ,p_effective_start_date         => l_asg_effective_start_date
	  ,p_effective_end_date           => l_asg_effective_end_date
	  ,p_people_group_id              => l_people_group_id
	  ,p_org_now_no_manager_warning   => l_org_now_no_manager_warning
	  ,p_other_manager_warning        => l_other_manager_warning
	  ,p_spp_delete_warning           => l_spp_delete_warning
          ,p_entries_changed_warning      => l_entries_changed_warning
	  ,p_tax_district_changed_warning => l_tax_district_changed_warning
	  );
          --
          hr_utility.set_location(l_proc, 163);
          --
	  hr_assignment_api.update_cwk_asg
	  (p_effective_date               => p_effective_date
	  ,p_datetrack_update_mode        => 'CORRECTION'
	  ,p_assignment_id                => l_assignment_id
	  ,p_object_version_number        => l_asg_object_version_number
	  ,p_assignment_category          => p_employment_category
	  ,p_assignment_number            => p_assignment_number
	  ,p_change_reason                => p_change_reason
	  ,p_default_code_comb_id         => p_default_code_comb_id
	  ,p_frequency                    => p_frequency
	  ,p_internal_address_line        => p_internal_address_line
	  ,p_labour_union_member_flag     => p_labour_union_member_flag
	  ,p_manager_flag                 => p_manager_flag
	  ,p_normal_hours                 => p_normal_hours
	  ,p_project_title                => p_project_title
	  ,p_set_of_books_id              => p_set_of_books_id
          ,p_title                        => p_billing_title
	  ,p_source_type                  => p_source_type
	  ,p_supervisor_id                => p_supervisor_id
	  ,p_supervisor_assignment_id     => p_supervisor_assignment_id
	  ,p_time_normal_finish           => p_time_normal_finish
	  ,p_time_normal_start            => p_time_normal_start
	  ,p_vendor_assignment_number     => p_vendor_assignment_number
	  ,p_vendor_employee_number       => p_vendor_employee_number
	  ,p_vendor_id                    => p_vendor_id
	  ,p_vendor_site_id               => p_vendor_site_id
	  ,p_po_header_id                 => p_po_header_id
	  ,p_po_line_id                   => p_po_line_id
          ,p_projected_assignment_end     => p_projected_assignment_end
	  ,p_assignment_status_type_id    => p_assignment_status_type_id
	  ,p_attribute_category       => p_ass_attribute_category
	  ,p_attribute1               => p_ass_attribute1
	  ,p_attribute2               => p_ass_attribute2
	  ,p_attribute3               => p_ass_attribute3
	  ,p_attribute4               => p_ass_attribute4
	  ,p_attribute5               => p_ass_attribute5
	  ,p_attribute6               => p_ass_attribute6
	  ,p_attribute7               => p_ass_attribute7
	  ,p_attribute8               => p_ass_attribute8
	  ,p_attribute9               => p_ass_attribute9
	  ,p_attribute10              => p_ass_attribute10
	  ,p_attribute11              => p_ass_attribute11
	  ,p_attribute12              => p_ass_attribute12
	  ,p_attribute13              => p_ass_attribute13
	  ,p_attribute14              => p_ass_attribute14
	  ,p_attribute15              => p_ass_attribute15
	  ,p_attribute16              => p_ass_attribute16
	  ,p_attribute17              => p_ass_attribute17
	  ,p_attribute18              => p_ass_attribute18
	  ,p_attribute19              => p_ass_attribute19
	  ,p_attribute20              => p_ass_attribute20
	  ,p_attribute21              => p_ass_attribute21
	  ,p_attribute22              => p_ass_attribute22
	  ,p_attribute23              => p_ass_attribute23
	  ,p_attribute24              => p_ass_attribute24
	  ,p_attribute25              => p_ass_attribute25
	  ,p_attribute26              => p_ass_attribute26
	  ,p_attribute27              => p_ass_attribute27
	  ,p_attribute28              => p_ass_attribute28
	  ,p_attribute29              => p_ass_attribute29
	  ,p_attribute30              => p_ass_attribute30
	  ,p_scl_segment1                     => p_scl_segment1
	  ,p_scl_segment2                     => p_scl_segment2
	  ,p_scl_segment3                     => p_scl_segment3
	  ,p_scl_segment4                     => p_scl_segment4
	  ,p_scl_segment5                     => p_scl_segment5
	  ,p_scl_segment6                     => p_scl_segment6
	  ,p_scl_segment7                     => p_scl_segment7
	  ,p_scl_segment8                     => p_scl_segment8
	  ,p_scl_segment9                     => p_scl_segment9
	  ,p_scl_segment10                    => p_scl_segment10
	  ,p_scl_segment11                    => p_scl_segment11
	  ,p_scl_segment12                    => p_scl_segment12
	  ,p_scl_segment13                    => p_scl_segment13
	  ,p_scl_segment14                    => p_scl_segment14
	  ,p_scl_segment15                    => p_scl_segment15
	  ,p_scl_segment16                    => p_scl_segment16
	  ,p_scl_segment17                    => p_scl_segment17
	  ,p_scl_segment18                    => p_scl_segment18
	  ,p_scl_segment19                    => p_scl_segment19
	  ,p_scl_segment20                    => p_scl_segment20
	  ,p_scl_segment21                    => p_scl_segment21
	  ,p_scl_segment22                    => p_scl_segment22
	  ,p_scl_segment23                    => p_scl_segment23
	  ,p_scl_segment24                    => p_scl_segment24
	  ,p_scl_segment25                    => p_scl_segment25
	  ,p_scl_segment26                    => p_scl_segment26
	  ,p_scl_segment27                    => p_scl_segment27
	  ,p_scl_segment28                    => p_scl_segment28
	  ,p_scl_segment29                    => p_scl_segment29
	  ,p_scl_segment30                    => p_scl_segment30
	  ,p_org_now_no_manager_warning   => l_org_now_no_manager_warning
	  ,p_effective_start_date         => l_asg_effective_start_date
	  ,p_effective_end_date           => l_asg_effective_end_date
	  ,p_comment_id                   => l_comment_id
	  ,p_no_managers_warning          => l_no_managers_warning
	  ,p_other_manager_warning        => l_other_manager_warning2
	  ,p_soft_coding_keyflex_id       => l_soft_coding_keyflex_id
	  ,p_concatenated_segments        => l_concatenated_segments
	  ,p_hourly_salaried_warning      => l_hourly_salaried_warning
	  );
      END IF;  --assignment types
    END IF;   --has assignment changed
  END IF;   --is assignment_update_allowed
  IF p_assignment_type='C' THEN
     IF p_grade_rule_id is null
     AND p_rate_id is not null then   --an assignment rate has been entered for the CWK
          hr_utility.set_location(l_proc, 1010);
	  hr_rate_values_api.create_assignment_rate_value
	       (p_effective_date           => p_effective_date
	       ,p_business_group_id        => p_business_group_id
	       ,p_rate_id                  => p_rate_id
	       ,p_assignment_id            => l_assignment_id
	       ,p_rate_type                => 'A'
	       ,p_currency_code            => p_rate_currency_code
	       ,p_value                    => p_rate_value
	       ,p_grade_rule_id            => l_grade_rule_id
	       ,p_object_version_number    => l_rate_object_version_number
	       ,p_effective_start_date     => l_rate_effective_start_date
	       ,p_effective_end_date       => l_rate_effective_end_date
	       );
	   p_grade_rule_id               := l_grade_rule_id;
	   p_rate_object_version_number  := l_rate_object_version_number;
	   p_rate_effective_start_date   := l_rate_effective_start_date;
	   p_rate_effective_end_date     := l_rate_effective_end_date;
     ELSIF p_grade_rule_id is not null
     AND p_rate_id is not null
     AND ( nvl(pay_pgr_shd.g_old_rec.currency_code,hr_api.g_varchar2)
           <>nvl(p_rate_currency_code,hr_api.g_varchar2)
        OR nvl(pay_pgr_shd.g_old_rec.value,hr_api.g_varchar2)
           <>nvl(p_rate_value,hr_api.g_varchar2) )
     THEN
          hr_utility.set_location(l_proc, 1020);
	  hr_rate_values_api.update_assignment_rate_value
	       (p_effective_date           => p_effective_date
	       ,p_grade_rule_id            => l_grade_rule_id
	       ,p_datetrack_mode           => l_rate_datetrack_update_mode
	       ,p_currency_code            => p_rate_currency_code
	       ,p_value                    => p_rate_value
	       ,p_object_version_number    => l_rate_object_version_number
	       ,p_effective_start_date     => l_rate_effective_start_date
	       ,p_effective_end_date       => l_rate_effective_end_date
	       );
	   p_rate_object_version_number  := l_rate_object_version_number;
	   p_rate_effective_start_date   := l_rate_effective_start_date;
	   p_rate_effective_end_date     := l_rate_effective_end_date;
      ELSE
        --special case: multiple rates, the query code has explicitly set grade_rule_id
        --but set rate_id null and the fields are not updateable anyway
        hr_utility.set_location(l_proc, 1030);
     END IF;
  END IF;
  ELSE -- we are entering a secondary assignment.
    IF p_assignment_type='E' THEN
      hr_assignment_api.create_secondary_emp_asg
      (p_effective_date               => p_effective_date
      ,p_person_id                    => p_person_id
      ,p_organization_id              => p_organization_id
      ,p_grade_id                     => p_grade_id
      ,p_grade_ladder_pgm_id          => p_grade_ladder_pgm_id
      ,p_position_id                  => p_position_id
      ,p_job_id                       => p_job_id
      ,p_assignment_status_type_id    => p_assignment_status_type_id
      ,p_payroll_id                   => p_payroll_id
      ,p_location_id                  => p_location_id
      ,p_supervisor_id                => p_supervisor_id
      ,p_supervisor_assignment_id     => p_supervisor_assignment_id
      ,p_special_ceiling_step_id      => p_special_ceiling_step_id
      ,p_pay_basis_id                 => p_pay_basis_id
      ,p_assignment_number            => l_assignment_number
      ,p_change_reason                => p_change_reason
      ,p_date_probation_end           => p_date_probation_end
      ,p_default_code_comb_id         => p_default_code_comb_id
      ,p_employment_category          => p_employment_category
      ,p_frequency                    => p_frequency
      ,p_internal_address_line        => p_internal_address_line
      ,p_manager_flag                 => p_manager_flag
      ,p_normal_hours                 => p_normal_hours
      ,p_perf_review_period           => p_perf_review_period
      ,p_perf_review_period_frequency => p_perf_review_period_frequency
      ,p_probation_period             => p_probation_period
      ,p_probation_unit               => p_probation_unit
      ,p_notice_period                => p_notice_period
      ,p_notice_period_uom            => p_notice_unit
      ,p_employee_category            => p_employee_category
      ,p_sal_review_period            => p_sal_review_period
      ,p_sal_review_period_frequency  => p_sal_review_period_frequency
      ,p_set_of_books_id              => p_set_of_books_id
      ,p_title                        => p_billing_title
      ,p_source_type                  => p_source_type
      ,p_time_normal_finish           => p_time_normal_finish
      ,p_time_normal_start            => p_time_normal_start
      ,p_bargaining_unit_code         => p_bargaining_unit_code
      ,p_labour_union_member_flag     => p_labour_union_member_flag
      ,p_hourly_salaried_code         => p_hourly_salaried_code
      ,p_ass_attribute_category       => p_ass_attribute_category
      ,p_ass_attribute1               => p_ass_attribute1
      ,p_ass_attribute2               => p_ass_attribute2
      ,p_ass_attribute3               => p_ass_attribute3
      ,p_ass_attribute4               => p_ass_attribute4
      ,p_ass_attribute5               => p_ass_attribute5
      ,p_ass_attribute6               => p_ass_attribute6
      ,p_ass_attribute7               => p_ass_attribute7
      ,p_ass_attribute8               => p_ass_attribute8
      ,p_ass_attribute9               => p_ass_attribute9
      ,p_ass_attribute10              => p_ass_attribute10
      ,p_ass_attribute11              => p_ass_attribute11
      ,p_ass_attribute12              => p_ass_attribute12
      ,p_ass_attribute13              => p_ass_attribute13
      ,p_ass_attribute14              => p_ass_attribute14
      ,p_ass_attribute15              => p_ass_attribute15
      ,p_ass_attribute16              => p_ass_attribute16
      ,p_ass_attribute17              => p_ass_attribute17
      ,p_ass_attribute18              => p_ass_attribute18
      ,p_ass_attribute19              => p_ass_attribute19
      ,p_ass_attribute20              => p_ass_attribute20
      ,p_ass_attribute21              => p_ass_attribute21
      ,p_ass_attribute22              => p_ass_attribute22
      ,p_ass_attribute23              => p_ass_attribute23
      ,p_ass_attribute24              => p_ass_attribute24
      ,p_ass_attribute25              => p_ass_attribute25
      ,p_ass_attribute26              => p_ass_attribute26
      ,p_ass_attribute27              => p_ass_attribute27
      ,p_ass_attribute28              => p_ass_attribute28
      ,p_ass_attribute29              => p_ass_attribute29
      ,p_ass_attribute30              => p_ass_attribute30
      ,p_scl_segment1                 => p_scl_segment1
      ,p_scl_segment2                 => p_scl_segment2
      ,p_scl_segment3                 => p_scl_segment3
      ,p_scl_segment4                 => p_scl_segment4
      ,p_scl_segment5                 => p_scl_segment5
      ,p_scl_segment6                 => p_scl_segment6
      ,p_scl_segment7                 => p_scl_segment7
      ,p_scl_segment8                 => p_scl_segment8
      ,p_scl_segment9                 => p_scl_segment9
      ,p_scl_segment10                => p_scl_segment10
      ,p_scl_segment11                => p_scl_segment11
      ,p_scl_segment12                => p_scl_segment12
      ,p_scl_segment13                => p_scl_segment13
      ,p_scl_segment14                => p_scl_segment14
      ,p_scl_segment15                => p_scl_segment15
      ,p_scl_segment16                => p_scl_segment16
      ,p_scl_segment17                => p_scl_segment17
      ,p_scl_segment18                => p_scl_segment18
      ,p_scl_segment19                => p_scl_segment19
      ,p_scl_segment20                => p_scl_segment20
      ,p_scl_segment21                => p_scl_segment21
      ,p_scl_segment22                => p_scl_segment22
      ,p_scl_segment23                => p_scl_segment23
      ,p_scl_segment24                => p_scl_segment24
      ,p_scl_segment25                => p_scl_segment25
      ,p_scl_segment26                => p_scl_segment26
      ,p_scl_segment27                => p_scl_segment27
      ,p_scl_segment28                => p_scl_segment28
      ,p_scl_segment29                => p_scl_segment29
      ,p_scl_segment30                => p_scl_segment30
      ,p_pgp_segment1                 => p_pgp_segment1
      ,p_pgp_segment2                 => p_pgp_segment2
      ,p_pgp_segment3                 => p_pgp_segment3
      ,p_pgp_segment4                 => p_pgp_segment4
      ,p_pgp_segment5                 => p_pgp_segment5
      ,p_pgp_segment6                 => p_pgp_segment6
      ,p_pgp_segment7                 => p_pgp_segment7
      ,p_pgp_segment8                 => p_pgp_segment8
      ,p_pgp_segment9                 => p_pgp_segment9
      ,p_pgp_segment10                => p_pgp_segment10
      ,p_pgp_segment11                => p_pgp_segment11
      ,p_pgp_segment12                => p_pgp_segment12
      ,p_pgp_segment13                => p_pgp_segment13
      ,p_pgp_segment14                => p_pgp_segment14
      ,p_pgp_segment15                => p_pgp_segment15
      ,p_pgp_segment16                => p_pgp_segment16
      ,p_pgp_segment17                => p_pgp_segment17
      ,p_pgp_segment18                => p_pgp_segment18
      ,p_pgp_segment19                => p_pgp_segment19
      ,p_pgp_segment20                => p_pgp_segment20
      ,p_pgp_segment21                => p_pgp_segment21
      ,p_pgp_segment22                => p_pgp_segment22
      ,p_pgp_segment23                => p_pgp_segment23
      ,p_pgp_segment24                => p_pgp_segment24
      ,p_pgp_segment25                => p_pgp_segment25
      ,p_pgp_segment26                => p_pgp_segment26
      ,p_pgp_segment27                => p_pgp_segment27
      ,p_pgp_segment28                => p_pgp_segment28
      ,p_pgp_segment29                => p_pgp_segment29
      ,p_pgp_segment30                => p_pgp_segment30
      ,p_contract_id                  => p_contract_id
      ,p_establishment_id             => p_establishment_id
      ,p_collective_agreement_id      => p_collective_agreement_id
      ,p_cagr_id_flex_num             => p_cagr_id_flex_num
      ,p_group_name                   => l_group_name
      ,p_concatenated_segments        => l_concatenated_segments
      ,p_cagr_grade_def_id            => l_cagr_grade_def_id
--Bug 3063591 Start Here
      ,p_work_at_home                 =>     p_work_at_home
--Bug 3063591 End Here
      ,p_cagr_concatenated_segments   => l_cagr_concatenated_segments
      ,p_assignment_id                => l_assignment_id
      ,p_soft_coding_keyflex_id       => l_soft_coding_keyflex_id
      ,p_people_group_id              => l_people_group_id
      ,p_object_version_number        => l_asg_object_version_number
      ,p_effective_start_date         => l_asg_effective_start_date
      ,p_effective_end_date           => l_asg_effective_end_date
      ,p_assignment_sequence          => l_assignment_sequence
      ,p_comment_id                   => l_comment_id
      ,p_other_manager_warning        => l_other_manager_warning
      ,p_hourly_salaried_warning      => l_hourly_salaried_warning
      ,p_gsp_post_process_warning     => l_gsp_post_process_warning3 -- bug2999562
      );
    ELSIF p_assignment_type='A'  THEN -- a secondary applicant assignment
     hr_assignment_api.create_secondary_apl_asg
       (p_effective_date               =>     p_effective_date
       ,p_person_id                    =>     p_person_id
       ,p_organization_id              =>     p_organization_id
       ,p_recruiter_id                 =>     p_recruiter_id
       ,p_grade_id                     =>     p_grade_id
       ,p_grade_ladder_pgm_id          =>     p_grade_ladder_pgm_id
       ,p_position_id                  =>     p_position_id
       ,p_job_id                       =>     p_job_id
       ,p_payroll_id                   =>     p_payroll_id
       ,p_assignment_status_type_id    =>     p_assignment_status_type_id
       ,p_location_id                  =>     p_location_id
       ,p_person_referred_by_id        =>     p_person_referred_by_id
       ,p_supervisor_id                =>     p_supervisor_id
       ,p_supervisor_assignment_id     =>     p_supervisor_assignment_id
       ,p_special_ceiling_step_id      =>     p_special_ceiling_step_id
       ,p_recruitment_activity_id      =>     p_recruitment_activity_id
       ,p_source_organization_id       =>     p_source_organization_id
       ,p_vacancy_id                   =>     p_vacancy_id
       ,p_pay_basis_id                 =>     p_pay_basis_id
       ,p_change_reason                =>     p_change_reason
       ,p_internal_address_line        =>     p_internal_address_line
       ,p_date_probation_end           =>     p_date_probation_end
       ,p_default_code_comb_id         =>     p_default_code_comb_id
       ,p_employment_category          =>     p_employment_category
       ,p_frequency                    =>     p_frequency
       ,p_manager_flag                 =>     p_manager_flag
       ,p_normal_hours                 =>     p_normal_hours
       ,p_perf_review_period           =>     p_perf_review_period
       ,p_perf_review_period_frequency =>     p_perf_review_period_frequency
       ,p_probation_period             =>     p_probation_period
       ,p_probation_unit               =>     p_probation_unit
       ,p_sal_review_period            =>     p_sal_review_period
       ,p_sal_review_period_frequency  =>     p_sal_review_period_frequency
       ,p_set_of_books_id              =>     p_set_of_books_id
       ,p_title                        =>     p_billing_title
       ,p_source_type                  =>     p_source_type
       ,p_time_normal_finish           =>     p_time_normal_finish
       ,p_time_normal_start            =>     p_time_normal_start
       ,p_bargaining_unit_code         =>     p_bargaining_unit_code
       ,p_ass_attribute_category       =>     p_ass_attribute_category
       ,p_ass_attribute1               =>     p_ass_attribute1
       ,p_ass_attribute2               =>     p_ass_attribute2
       ,p_ass_attribute3               =>     p_ass_attribute3
       ,p_ass_attribute4               =>     p_ass_attribute4
       ,p_ass_attribute5               =>     p_ass_attribute5
       ,p_ass_attribute6               =>     p_ass_attribute6
       ,p_ass_attribute7               =>     p_ass_attribute7
       ,p_ass_attribute8               =>     p_ass_attribute8
       ,p_ass_attribute9               =>     p_ass_attribute9
       ,p_ass_attribute10              =>     p_ass_attribute10
       ,p_ass_attribute11              =>     p_ass_attribute11
       ,p_ass_attribute12              =>     p_ass_attribute12
       ,p_ass_attribute13              =>     p_ass_attribute13
       ,p_ass_attribute14              =>     p_ass_attribute14
       ,p_ass_attribute15              =>     p_ass_attribute15
       ,p_ass_attribute16              =>     p_ass_attribute16
       ,p_ass_attribute17              =>     p_ass_attribute17
       ,p_ass_attribute18              =>     p_ass_attribute18
       ,p_ass_attribute19              =>     p_ass_attribute19
       ,p_ass_attribute20              =>     p_ass_attribute20
       ,p_ass_attribute21              =>     p_ass_attribute21
       ,p_ass_attribute22              =>     p_ass_attribute22
       ,p_ass_attribute23              =>     p_ass_attribute23
       ,p_ass_attribute24              =>     p_ass_attribute24
       ,p_ass_attribute25              =>     p_ass_attribute25
       ,p_ass_attribute26              =>     p_ass_attribute26
       ,p_ass_attribute27              =>     p_ass_attribute27
       ,p_ass_attribute28              =>     p_ass_attribute28
       ,p_ass_attribute29              =>     p_ass_attribute29
       ,p_ass_attribute30              =>     p_ass_attribute30
       ,p_scl_segment1                 =>     p_scl_segment1
       ,p_scl_segment2                 =>     p_scl_segment2
       ,p_scl_segment3                 =>     p_scl_segment3
       ,p_scl_segment4                 =>     p_scl_segment4
       ,p_scl_segment5                 =>     p_scl_segment5
       ,p_scl_segment6                 =>     p_scl_segment6
       ,p_scl_segment7                 =>     p_scl_segment7
       ,p_scl_segment8                 =>     p_scl_segment8
       ,p_scl_segment9                 =>     p_scl_segment9
       ,p_scl_segment10                =>     p_scl_segment10
       ,p_scl_segment11                =>     p_scl_segment11
       ,p_scl_segment12                =>     p_scl_segment12
       ,p_scl_segment13                =>     p_scl_segment13
       ,p_scl_segment14                =>     p_scl_segment14
       ,p_scl_segment15                =>     p_scl_segment15
       ,p_scl_segment16                =>     p_scl_segment16
       ,p_scl_segment17                =>     p_scl_segment17
       ,p_scl_segment18                =>     p_scl_segment18
       ,p_scl_segment19                =>     p_scl_segment19
       ,p_scl_segment20                =>     p_scl_segment20
       ,p_scl_segment21                =>     p_scl_segment21
       ,p_scl_segment22                =>     p_scl_segment22
       ,p_scl_segment23                =>     p_scl_segment23
       ,p_scl_segment24                =>     p_scl_segment24
       ,p_scl_segment25                =>     p_scl_segment25
       ,p_scl_segment26                =>     p_scl_segment26
       ,p_scl_segment27                =>     p_scl_segment27
       ,p_scl_segment28                =>     p_scl_segment28
       ,p_scl_segment29                =>     p_scl_segment29
       ,p_scl_segment30                =>     p_scl_segment30
       ,p_concatenated_segments        =>     l_concatenated_segments
       ,p_pgp_segment1                 =>     p_pgp_segment1
       ,p_pgp_segment2                 =>     p_pgp_segment2
       ,p_pgp_segment3                 =>     p_pgp_segment3
       ,p_pgp_segment4                 =>     p_pgp_segment4
       ,p_pgp_segment5                 =>     p_pgp_segment5
       ,p_pgp_segment6                 =>     p_pgp_segment6
       ,p_pgp_segment7                 =>     p_pgp_segment7
       ,p_pgp_segment8                 =>     p_pgp_segment8
       ,p_pgp_segment9                 =>     p_pgp_segment9
       ,p_pgp_segment10                =>     p_pgp_segment10
       ,p_pgp_segment11                =>     p_pgp_segment11
       ,p_pgp_segment12                =>     p_pgp_segment12
       ,p_pgp_segment13                =>     p_pgp_segment13
       ,p_pgp_segment14                =>     p_pgp_segment14
       ,p_pgp_segment15                =>     p_pgp_segment15
       ,p_pgp_segment16                =>     p_pgp_segment16
       ,p_pgp_segment17                =>     p_pgp_segment17
       ,p_pgp_segment18                =>     p_pgp_segment18
       ,p_pgp_segment19                =>     p_pgp_segment19
       ,p_pgp_segment20                =>     p_pgp_segment20
       ,p_pgp_segment21                =>     p_pgp_segment21
       ,p_pgp_segment22                =>     p_pgp_segment22
       ,p_pgp_segment23                =>     p_pgp_segment23
       ,p_pgp_segment24                =>     p_pgp_segment24
       ,p_pgp_segment25                =>     p_pgp_segment25
       ,p_pgp_segment26                =>     p_pgp_segment26
       ,p_pgp_segment27                =>     p_pgp_segment27
       ,p_pgp_segment28                =>     p_pgp_segment28
       ,p_pgp_segment29                =>     p_pgp_segment29
       ,p_pgp_segment30                =>     p_pgp_segment30
       ,p_contract_id                  =>     p_contract_id
       ,p_establishment_id             =>     p_establishment_id
       ,p_collective_agreement_id      =>     p_collective_agreement_id
       ,p_cagr_id_flex_num             =>     p_cagr_id_flex_num
       ,p_cagr_grade_def_id            =>     l_cagr_grade_def_id
--Bug 3063591 Start Here
      ,p_work_at_home                 =>     p_work_at_home
      ,p_notice_period                =>     p_notice_period
      ,p_notice_period_uom            =>     p_notice_unit

--Bug 3063591 End Here
       ,p_cagr_concatenated_segments   =>     l_cagr_concatenated_segments
       ,p_group_name                   =>     l_group_name
       ,p_assignment_id                =>     l_assignment_id
       ,p_people_group_id              =>     l_people_group_id
       ,p_soft_coding_keyflex_id       =>     l_soft_coding_keyflex_id
       ,p_comment_id                   =>     l_comment_id
       ,p_object_version_number        =>     l_asg_object_version_number
       ,p_effective_start_date         =>     l_asg_effective_start_date
       ,p_effective_end_date           =>     l_asg_effective_end_date
       ,p_assignment_sequence          =>     l_assignment_sequence
       );
    ELSIF p_assignment_type = 'C' then
     hr_assignment_api.create_secondary_cwk_asg
      (p_effective_date               => p_effective_date
      ,p_business_group_id            => p_business_group_id
      ,p_person_id                    => p_person_id
      ,p_organization_id              => p_organization_id
      ,p_assignment_number            => l_assignment_number
      ,p_assignment_category          => p_employment_category
      ,p_assignment_status_type_id    => p_assignment_status_type_id
      ,p_change_reason                => p_change_reason
      ,p_default_code_comb_id         => p_default_code_comb_id
      ,p_establishment_id             => p_establishment_id
      ,p_frequency                    => p_frequency
      ,p_internal_address_line        => p_internal_address_line
      ,p_job_id                       => p_job_id
      ,p_labour_union_member_flag     => p_labour_union_member_flag
      ,p_location_id                  => p_location_id
      ,p_manager_flag                 => p_manager_flag
      ,p_normal_hours                 => p_normal_hours
      ,p_position_id                  => p_position_id
      ,p_grade_id                     => p_grade_id
      ,p_project_title                => p_project_title
      ,p_set_of_books_id              => p_set_of_books_id
      ,p_title                        => p_billing_title
      ,p_source_type                  => p_source_type
      ,p_supervisor_id                => p_supervisor_id
      ,p_time_normal_finish           => p_time_normal_finish
      ,p_time_normal_start            => p_time_normal_start
      ,p_vendor_assignment_number     => p_vendor_assignment_number
      ,p_vendor_employee_number       => p_vendor_employee_number
      ,p_vendor_id                    => p_vendor_id
      ,p_vendor_site_id               => p_vendor_site_id
      ,p_po_header_id                 => p_po_header_id
      ,p_po_line_id                   => p_po_line_id
      ,p_projected_assignment_end     => p_projected_assignment_end
      ,p_attribute_category       => p_ass_attribute_category
      ,p_attribute1               => p_ass_attribute1
      ,p_attribute2               => p_ass_attribute2
      ,p_attribute3               => p_ass_attribute3
      ,p_attribute4               => p_ass_attribute4
      ,p_attribute5               => p_ass_attribute5
      ,p_attribute6               => p_ass_attribute6
      ,p_attribute7               => p_ass_attribute7
      ,p_attribute8               => p_ass_attribute8
      ,p_attribute9               => p_ass_attribute9
      ,p_attribute10              => p_ass_attribute10
      ,p_attribute11              => p_ass_attribute11
      ,p_attribute12              => p_ass_attribute12
      ,p_attribute13              => p_ass_attribute13
      ,p_attribute14              => p_ass_attribute14
      ,p_attribute15              => p_ass_attribute15
      ,p_attribute16              => p_ass_attribute16
      ,p_attribute17              => p_ass_attribute17
      ,p_attribute18              => p_ass_attribute18
      ,p_attribute19              => p_ass_attribute19
      ,p_attribute20              => p_ass_attribute20
      ,p_attribute21              => p_ass_attribute21
      ,p_attribute22              => p_ass_attribute22
      ,p_attribute23              => p_ass_attribute23
      ,p_attribute24              => p_ass_attribute24
      ,p_attribute25              => p_ass_attribute25
      ,p_attribute26              => p_ass_attribute26
      ,p_attribute27              => p_ass_attribute27
      ,p_attribute28              => p_ass_attribute28
      ,p_attribute29              => p_ass_attribute29
      ,p_attribute30              => p_ass_attribute30
      ,p_scl_segment1                 => p_scl_segment1
      ,p_scl_segment2                 => p_scl_segment2
      ,p_scl_segment3                 => p_scl_segment3
      ,p_scl_segment4                 => p_scl_segment4
      ,p_scl_segment5                 => p_scl_segment5
      ,p_scl_segment6                 => p_scl_segment6
      ,p_scl_segment7                 => p_scl_segment7
      ,p_scl_segment8                 => p_scl_segment8
      ,p_scl_segment9                 => p_scl_segment9
      ,p_scl_segment10                => p_scl_segment10
      ,p_scl_segment11                => p_scl_segment11
      ,p_scl_segment12                => p_scl_segment12
      ,p_scl_segment13                => p_scl_segment13
      ,p_scl_segment14                => p_scl_segment14
      ,p_scl_segment15                => p_scl_segment15
      ,p_scl_segment16                => p_scl_segment16
      ,p_scl_segment17                => p_scl_segment17
      ,p_scl_segment18                => p_scl_segment18
      ,p_scl_segment19                => p_scl_segment19
      ,p_scl_segment20                => p_scl_segment20
      ,p_scl_segment21                => p_scl_segment21
      ,p_scl_segment22                => p_scl_segment22
      ,p_scl_segment23                => p_scl_segment23
      ,p_scl_segment24                => p_scl_segment24
      ,p_scl_segment25                => p_scl_segment25
      ,p_scl_segment26                => p_scl_segment26
      ,p_scl_segment27                => p_scl_segment27
      ,p_scl_segment28                => p_scl_segment28
      ,p_scl_segment29                => p_scl_segment29
      ,p_scl_segment30                => p_scl_segment30
      ,p_pgp_segment1                 => p_pgp_segment1
      ,p_pgp_segment2                 => p_pgp_segment2
      ,p_pgp_segment3                 => p_pgp_segment3
      ,p_pgp_segment4                 => p_pgp_segment4
      ,p_pgp_segment5                 => p_pgp_segment5
      ,p_pgp_segment6                 => p_pgp_segment6
      ,p_pgp_segment7                 => p_pgp_segment7
      ,p_pgp_segment8                 => p_pgp_segment8
      ,p_pgp_segment9                 => p_pgp_segment9
      ,p_pgp_segment10                => p_pgp_segment10
      ,p_pgp_segment11                => p_pgp_segment11
      ,p_pgp_segment12                => p_pgp_segment12
      ,p_pgp_segment13                => p_pgp_segment13
      ,p_pgp_segment14                => p_pgp_segment14
      ,p_pgp_segment15                => p_pgp_segment15
      ,p_pgp_segment16                => p_pgp_segment16
      ,p_pgp_segment17                => p_pgp_segment17
      ,p_pgp_segment18                => p_pgp_segment18
      ,p_pgp_segment19                => p_pgp_segment19
      ,p_pgp_segment20                => p_pgp_segment20
      ,p_pgp_segment21                => p_pgp_segment21
      ,p_pgp_segment22                => p_pgp_segment22
      ,p_pgp_segment23                => p_pgp_segment23
      ,p_pgp_segment24                => p_pgp_segment24
      ,p_pgp_segment25                => p_pgp_segment25
      ,p_pgp_segment26                => p_pgp_segment26
      ,p_pgp_segment27                => p_pgp_segment27
      ,p_pgp_segment28                => p_pgp_segment28
      ,p_pgp_segment29                => p_pgp_segment29
      ,p_pgp_segment30                => p_pgp_segment30
      ,p_assignment_id                => l_assignment_id
      ,p_object_version_number        => l_asg_object_version_number
      ,p_effective_start_date         => l_asg_effective_start_date
      ,p_effective_end_date           => l_asg_effective_end_date
      ,p_assignment_sequence          => l_assignment_sequence
      ,p_comment_id                   => l_comment_id
      ,p_people_group_id              => l_people_group_id
      ,p_people_group_name            => l_group_name
      ,p_other_manager_warning        => l_other_manager_warning
      ,p_hourly_salaried_warning      => l_hourly_salaried_warning
      ,p_soft_coding_keyflex_id       => l_soft_coding_keyflex_id
      );
    --
      IF p_rate_id is not null then   --an assignment rate has been entered for the CWK asg
	 hr_rate_values_api.create_assignment_rate_value
	      (p_effective_date           => p_effective_date
	      ,p_business_group_id        => p_business_group_id
	      ,p_rate_id                  => p_rate_id
	      ,p_assignment_id            => l_assignment_id
	      ,p_rate_type                => 'A'
	      ,p_currency_code            => p_rate_currency_code
	      ,p_value                    => p_rate_value
	      ,p_grade_rule_id            => l_grade_rule_id
	      ,p_object_version_number    => l_rate_object_version_number
	      ,p_effective_start_date     => l_rate_effective_start_date
	      ,p_effective_end_date       => l_rate_effective_end_date
	      );
      END IF;
      p_grade_rule_id               := l_grade_rule_id;
      p_rate_object_version_number  := l_rate_object_version_number;
      p_rate_effective_start_date   := l_rate_effective_start_date;
      p_rate_effective_end_date     := l_rate_effective_end_date;
    END IF;
  END IF;
  --
  p_assignment_id:=l_assignment_id;
  p_assignment_sequence:=l_assignment_sequence;
  p_assignment_number:=l_assignment_number;
  p_asg_object_version_number:=l_asg_object_version_number;
  p_asg_effective_start_date:=l_asg_effective_start_date;
  p_asg_effective_end_date:=l_asg_effective_end_date;
  p_asg_validation_start_date:=l_asg_validation_start_date;
  p_asg_validation_end_date:=l_asg_validation_end_date;
  p_people_group_id:=l_people_group_id;
  p_soft_coding_keyflex_id:=l_soft_coding_keyflex_id;
  p_special_ceiling_step_id:=l_special_ceiling_step_id;
  p_cagr_id_flex_num:=l_cagr_id_flex_num;
  p_cagr_grade_def_id:=l_cagr_grade_def_id;
  p_org_now_no_manager_warning:=l_org_now_no_manager_warning;
  p_other_manager_warning:=l_other_manager_warning;
  --
  --
  -- bug2999562 support gsp post process
  --
  if l_gsp_post_process_warning is not null then
    hr_utility.set_location(l_proc, 162);
    p_gsp_post_process_warning := l_gsp_post_process_warning;
  elsif l_gsp_post_process_warning2 is not null then
    hr_utility.set_location(l_proc, 163);
    p_gsp_post_process_warning := l_gsp_post_process_warning2;
  elsif l_gsp_post_process_warning3 is not null then
    hr_utility.set_location(l_proc, 164);
    p_gsp_post_process_warning := l_gsp_post_process_warning3;
  else
    p_gsp_post_process_warning := null;
  end if;
  --
  hr_utility.set_location(l_proc, 165);
  --
  IF p_application_id IS NOT NULL AND (
        NVL(per_apl_shd.g_old_rec.projected_hire_date,hr_api.g_date)
     <> NVL(p_projected_hire_date,hr_api.g_date)
     OR NVL(per_apl_shd.g_old_rec.appl_attribute_category,hr_api.g_varchar2)
     <> NVL(p_appl_attribute_category,hr_api.g_varchar2)
     OR NVL(per_apl_shd.g_old_rec.appl_attribute1,hr_api.g_varchar2)
     <> NVL(p_appl_attribute1,hr_api.g_varchar2)
     OR NVL(per_apl_shd.g_old_rec.appl_attribute2,hr_api.g_varchar2)
     <> NVL(p_appl_attribute2,hr_api.g_varchar2)
     OR NVL(per_apl_shd.g_old_rec.appl_attribute3,hr_api.g_varchar2)
     <> NVL(p_appl_attribute3,hr_api.g_varchar2)
     OR NVL(per_apl_shd.g_old_rec.appl_attribute4,hr_api.g_varchar2)
     <> NVL(p_appl_attribute4,hr_api.g_varchar2)
     OR NVL(per_apl_shd.g_old_rec.appl_attribute5,hr_api.g_varchar2)
     <> NVL(p_appl_attribute5,hr_api.g_varchar2)
     OR NVL(per_apl_shd.g_old_rec.appl_attribute6,hr_api.g_varchar2)
     <> NVL(p_appl_attribute6,hr_api.g_varchar2)
     OR NVL(per_apl_shd.g_old_rec.appl_attribute7,hr_api.g_varchar2)
     <> NVL(p_appl_attribute7,hr_api.g_varchar2)
     OR NVL(per_apl_shd.g_old_rec.appl_attribute8,hr_api.g_varchar2)
     <> NVL(p_appl_attribute8,hr_api.g_varchar2)
     OR NVL(per_apl_shd.g_old_rec.appl_attribute9,hr_api.g_varchar2)
     <> NVL(p_appl_attribute9,hr_api.g_varchar2)
     OR NVL(per_apl_shd.g_old_rec.appl_attribute10,hr_api.g_varchar2)
     <> NVL(p_appl_attribute10,hr_api.g_varchar2)
     OR NVL(per_apl_shd.g_old_rec.appl_attribute11,hr_api.g_varchar2)
     <> NVL(p_appl_attribute11,hr_api.g_varchar2)
     OR NVL(per_apl_shd.g_old_rec.appl_attribute12,hr_api.g_varchar2)
     <> NVL(p_appl_attribute12,hr_api.g_varchar2)
     OR NVL(per_apl_shd.g_old_rec.appl_attribute13,hr_api.g_varchar2)
     <> NVL(p_appl_attribute13,hr_api.g_varchar2)
     OR NVL(per_apl_shd.g_old_rec.appl_attribute14,hr_api.g_varchar2)
     <> NVL(p_appl_attribute14,hr_api.g_varchar2)
     OR NVL(per_apl_shd.g_old_rec.appl_attribute15,hr_api.g_varchar2)
     <> NVL(p_appl_attribute15,hr_api.g_varchar2)
     OR NVL(per_apl_shd.g_old_rec.appl_attribute16,hr_api.g_varchar2)
     <> NVL(p_appl_attribute16,hr_api.g_varchar2)
     OR NVL(per_apl_shd.g_old_rec.appl_attribute17,hr_api.g_varchar2)
     <> NVL(p_appl_attribute17,hr_api.g_varchar2)
     OR NVL(per_apl_shd.g_old_rec.appl_attribute18,hr_api.g_varchar2)
     <> NVL(p_appl_attribute18,hr_api.g_varchar2)
     OR NVL(per_apl_shd.g_old_rec.appl_attribute19,hr_api.g_varchar2)
     <> NVL(p_appl_attribute19,hr_api.g_varchar2)
     OR NVL(per_apl_shd.g_old_rec.appl_attribute20,hr_api.g_varchar2)
     <> NVL(p_appl_attribute20,hr_api.g_varchar2)
     OR NVL(per_apl_shd.g_old_rec.current_employer,hr_api.g_varchar2)
     <> NVL(p_current_employer,hr_api.g_varchar2)
     OR NVL(per_apl_shd.g_old_rec.termination_reason,hr_api.g_varchar2)
     <> NVL(p_termination_reason,hr_api.g_varchar2)) THEN
    --
    --
    hr_utility.set_location(l_proc, 170);
    --
    hr_application_api.update_apl_details
      (p_application_id               => p_application_id
      ,p_object_version_number        => l_app_object_version_number
      ,p_effective_date               => p_effective_date
      ,p_current_employer             => p_current_employer
      ,p_projected_hire_date          => p_projected_hire_date
      ,p_termination_reason           => p_termination_reason
      ,p_appl_attribute_category      => p_appl_attribute_category
      ,p_appl_attribute1              => p_appl_attribute1
      ,p_appl_attribute2              => p_appl_attribute2
      ,p_appl_attribute3              => p_appl_attribute3
      ,p_appl_attribute4              => p_appl_attribute4
      ,p_appl_attribute5              => p_appl_attribute5
      ,p_appl_attribute6              => p_appl_attribute6
      ,p_appl_attribute7              => p_appl_attribute7
      ,p_appl_attribute8              => p_appl_attribute8
      ,p_appl_attribute9              => p_appl_attribute9
      ,p_appl_attribute10             => p_appl_attribute10
      ,p_appl_attribute11             => p_appl_attribute11
      ,p_appl_attribute12             => p_appl_attribute12
      ,p_appl_attribute13             => p_appl_attribute13
      ,p_appl_attribute14             => p_appl_attribute14
      ,p_appl_attribute15             => p_appl_attribute15
      ,p_appl_attribute16             => p_appl_attribute16
      ,p_appl_attribute17             => p_appl_attribute17
      ,p_appl_attribute18             => p_appl_attribute18
      ,p_appl_attribute19             => p_appl_attribute19
      ,p_appl_attribute20             => p_appl_attribute20
    );
    --
    hr_utility.set_location(l_proc, 180);
    --
  END IF;
  --
  p_app_object_version_number:=l_app_object_version_number;
  --
  hr_utility.set_location(l_proc, 185);
  -- home phone
  --
  IF p_phn_h_phone_id IS NOT NULL THEN
    per_phn_shd.lck
    (p_phone_id              => p_phn_h_phone_id
    ,p_object_version_number => p_phn_h_object_version_number);
  END IF;
  --
  IF (p_phn_h_phone_id IS NULL AND p_phn_h_phone_number IS NOT NULL) OR
     (p_phn_h_phone_id IS NOT NULL AND (
        NVL(per_phn_shd.g_old_rec.date_from,hr_api.g_date)
     <> NVL(p_phn_h_date_from,hr_api.g_date)
     OR NVL(per_phn_shd.g_old_rec.date_to,hr_api.g_date)
     <> NVL(p_phn_h_date_to,hr_api.g_date)
     OR NVL(per_phn_shd.g_old_rec.phone_number,hr_api.g_varchar2)
     <> NVL(p_phn_h_phone_number,hr_api.g_varchar2) )) THEN
    --

 -- added for the bug 4584695
 -- added the if condition that checks whether to call the delete api or the create_update api
 -- and assigns the value null to the return parameters as they record is getting deleted

 if (NVL(per_phn_shd.g_old_rec.phone_number,hr_api.g_varchar2)
           <> NVL(p_phn_h_phone_number,hr_api.g_varchar2) and
          p_phn_h_phone_number is null ) then

    l_phone_id := p_phn_h_phone_id;
    l_phn_object_version_number := p_phn_h_object_version_number;

     hr_phone_api.delete_phone(p_phone_id  => l_phone_id
                               ,p_object_version_number => l_phn_object_version_number);

    p_phn_h_phone_id := null;
    p_phn_h_object_version_number := null;

    else
    -- end of bug 4584695
    l_phone_id := p_phn_h_phone_id;
    l_phn_object_version_number := p_phn_h_object_version_number;
    hr_phone_api.create_or_update_phone
      (p_effective_date               => p_effective_date
      ,p_parent_id                    => p_person_id
      ,p_update_mode                  => p_datetrack_update_mode
      ,p_parent_table                 => 'PER_ALL_PEOPLE_F'
      ,p_phone_type                   => 'H1'
      ,p_phone_number                 => p_phn_h_phone_number
      ,p_date_from                    => p_phn_h_date_from
      ,p_date_to                      => p_phn_h_date_to
      ,p_object_version_number        => l_phn_object_version_number
      ,p_phone_id                     => l_phone_id
    );
    --
    p_phn_h_phone_id := l_phone_id;
    p_phn_h_object_version_number := l_phn_object_version_number;
    --
  end if;

  END IF;
  --
  -- work phone
  --
  IF p_phn_w_phone_id IS NOT NULL THEN
    per_phn_shd.lck
    (p_phone_id              => p_phn_w_phone_id
    ,p_object_version_number => p_phn_w_object_version_number);
  END IF;
  --
  IF (p_phn_w_phone_id IS NULL AND p_phn_w_phone_number IS NOT NULL) OR
     (p_phn_w_phone_id IS NOT NULL AND (
        NVL(per_phn_shd.g_old_rec.date_from,hr_api.g_date)
     <> NVL(p_phn_w_date_from,hr_api.g_date)
     OR NVL(per_phn_shd.g_old_rec.date_to,hr_api.g_date)
     <> NVL(p_phn_w_date_to,hr_api.g_date)
     OR NVL(per_phn_shd.g_old_rec.phone_number,hr_api.g_varchar2)
     <> NVL(p_phn_w_phone_number,hr_api.g_varchar2) )) THEN
    --

 -- added for the bug 4584695
 -- added the if condition that checks whether to call the delete api or the create_update api
 -- and assigns the value null to the return parameters as they record is getting deleted

 if (NVL(per_phn_shd.g_old_rec.phone_number,hr_api.g_varchar2)
           <> NVL(p_phn_w_phone_number ,hr_api.g_varchar2) and
          p_phn_w_phone_number  is null ) then

    l_phone_id := p_phn_w_phone_id ;
     l_phn_object_version_number := p_phn_w_object_version_number;

     hr_phone_api.delete_phone(p_phone_id  => l_phone_id
                               ,p_object_version_number => l_phn_object_version_number);

    p_phn_w_phone_id  := null;
    p_phn_w_object_version_number := null;

    else
    -- end of bug 4584695

    l_phone_id := p_phn_w_phone_id;
    l_phn_object_version_number := p_phn_w_object_version_number;
    hr_phone_api.create_or_update_phone
      (p_effective_date               => p_effective_date
      ,p_parent_id                    => p_person_id
      ,p_update_mode                  => p_datetrack_update_mode
      ,p_parent_table                 => 'PER_ALL_PEOPLE_F'
      ,p_phone_type                   => 'W1'
      ,p_phone_number                 => p_phn_w_phone_number
      ,p_date_from                    => p_phn_w_date_from
      ,p_date_to                      => p_phn_w_date_to
      ,p_object_version_number        => l_phn_object_version_number
      ,p_phone_id                     => l_phone_id
    );
    --
    p_phn_w_phone_id := l_phone_id;
    p_phn_w_object_version_number := l_phn_object_version_number;
    --

    end if;
    END IF;
  --
  -- mobile phone
  --
  IF p_phn_m_phone_id IS NOT NULL THEN
    per_phn_shd.lck
    (p_phone_id              => p_phn_m_phone_id
    ,p_object_version_number => p_phn_m_object_version_number);
  END IF;
  --
  IF (p_phn_m_phone_id IS NULL AND p_phn_m_phone_number IS NOT NULL) OR
     (p_phn_m_phone_id IS NOT NULL AND (
        NVL(per_phn_shd.g_old_rec.date_from,hr_api.g_date)
     <> NVL(p_phn_m_date_from,hr_api.g_date)
     OR NVL(per_phn_shd.g_old_rec.date_to,hr_api.g_date)
     <> NVL(p_phn_m_date_to,hr_api.g_date)
     OR NVL(per_phn_shd.g_old_rec.phone_number,hr_api.g_varchar2)
     <> NVL(p_phn_m_phone_number,hr_api.g_varchar2) )) THEN
    --

 -- added for the bug 4584695
 -- added the if condition that checks whether to call the delete api or the create_update api
 -- and assigns the value null to the return parameters as they record is getting deleted

 if (NVL(per_phn_shd.g_old_rec.phone_number,hr_api.g_varchar2)
           <> NVL(p_phn_m_phone_number,hr_api.g_varchar2) and
          p_phn_m_phone_number is null ) then

    l_phone_id := p_phn_m_phone_id;
    l_phn_object_version_number := p_phn_m_object_version_number;

     hr_phone_api.delete_phone(p_phone_id  => l_phone_id
                               ,p_object_version_number => l_phn_object_version_number);

    p_phn_m_phone_id := null;
    p_phn_m_object_version_number := null;

    else
    -- end of bug 4584695

    l_phone_id := p_phn_m_phone_id;
    l_phn_object_version_number := p_phn_m_object_version_number;
    hr_phone_api.create_or_update_phone
      (p_effective_date               => p_effective_date
      ,p_parent_id                    => p_person_id
      ,p_update_mode                  => p_datetrack_update_mode
      ,p_parent_table                 => 'PER_ALL_PEOPLE_F'
      ,p_phone_type                   => 'M'
      ,p_phone_number                 => p_phn_m_phone_number
      ,p_date_from                    => p_phn_m_date_from
      ,p_date_to                      => p_phn_m_date_to
      ,p_object_version_number        => l_phn_object_version_number
      ,p_phone_id                     => l_phone_id
    );
    --
    p_phn_m_phone_id := l_phone_id;
    p_phn_m_object_version_number := l_phn_object_version_number;
    --
  END IF;
  END IF;
  --
  -- home fax
  --
  IF p_phn_hf_phone_id IS NOT NULL THEN
    per_phn_shd.lck
    (p_phone_id              => p_phn_hf_phone_id
    ,p_object_version_number => p_phn_hf_object_version_number);
  END IF;
  --
  IF (p_phn_hf_phone_id IS NULL AND p_phn_hf_phone_number IS NOT NULL) OR
     (p_phn_hf_phone_id IS NOT NULL AND (
        NVL(per_phn_shd.g_old_rec.date_from,hr_api.g_date)
     <> NVL(p_phn_hf_date_from,hr_api.g_date)
     OR NVL(per_phn_shd.g_old_rec.date_to,hr_api.g_date)
     <> NVL(p_phn_hf_date_to,hr_api.g_date)
     OR NVL(per_phn_shd.g_old_rec.phone_number,hr_api.g_varchar2)
     <> NVL(p_phn_hf_phone_number,hr_api.g_varchar2) )) THEN
    --
    l_phone_id := p_phn_hf_phone_id;
    l_phn_object_version_number := p_phn_hf_object_version_number;
    hr_phone_api.create_or_update_phone
      (p_effective_date               => p_effective_date
      ,p_parent_id                    => p_person_id
      ,p_update_mode                  => p_datetrack_update_mode
      ,p_parent_table                 => 'PER_ALL_PEOPLE_F'
      ,p_phone_type                   => 'HF'
      ,p_phone_number                 => p_phn_hf_phone_number
      ,p_date_from                    => p_phn_hf_date_from
      ,p_date_to                      => p_phn_hf_date_to
      ,p_object_version_number        => l_phn_object_version_number
      ,p_phone_id                     => l_phone_id
    );
    --
    p_phn_hf_phone_id := l_phone_id;
    p_phn_hf_object_version_number := l_phn_object_version_number;
    --
  END IF;
  --
  -- work fax
  --
  IF p_phn_wf_phone_id IS NOT NULL THEN
    per_phn_shd.lck
    (p_phone_id              => p_phn_wf_phone_id
    ,p_object_version_number => p_phn_wf_object_version_number);
  END IF;
  --
  IF (p_phn_wf_phone_id IS NULL AND p_phn_wf_phone_number IS NOT NULL) OR
     (p_phn_wf_phone_id IS NOT NULL AND (
        NVL(per_phn_shd.g_old_rec.date_from,hr_api.g_date)
     <> NVL(p_phn_wf_date_from,hr_api.g_date)
     OR NVL(per_phn_shd.g_old_rec.date_to,hr_api.g_date)
     <> NVL(p_phn_wf_date_to,hr_api.g_date)
     OR NVL(per_phn_shd.g_old_rec.phone_number,hr_api.g_varchar2)
     <> NVL(p_phn_wf_phone_number,hr_api.g_varchar2) )) THEN
    --
    -- added for the bug 5301807
 -- added the if condition that checks whether to call the delete api or the create_update api
 -- and assigns the value null to the return parameters as the record is getting deleted
    if (NVL(per_phn_shd.g_old_rec.phone_number,hr_api.g_varchar2)
           <> NVL(p_phn_wf_phone_number,hr_api.g_varchar2) and
          p_phn_wf_phone_number is null ) then
      l_phone_id := p_phn_wf_phone_id ;
      l_phn_object_version_number := p_phn_wf_object_version_number;

      hr_phone_api.delete_phone(p_phone_id  => l_phone_id
                               ,p_object_version_number => l_phn_object_version_number);

      p_phn_w_phone_id  := null;
      p_phn_w_object_version_number := null;
    else
-- end of bug 5301807
    l_phone_id := p_phn_wf_phone_id;
    l_phn_object_version_number := p_phn_wf_object_version_number;
    hr_phone_api.create_or_update_phone
      (p_effective_date               => p_effective_date
      ,p_parent_id                    => p_person_id
      ,p_update_mode                  => p_datetrack_update_mode
      ,p_parent_table                 => 'PER_ALL_PEOPLE_F'
      ,p_phone_type                   => 'WF'
      ,p_phone_number                 => p_phn_wf_phone_number
      ,p_date_from                    => p_phn_wf_date_from
      ,p_date_to                      => p_phn_wf_date_to
      ,p_object_version_number        => l_phn_object_version_number
      ,p_phone_id                     => l_phone_id
    );
    --
    p_phn_wf_phone_id := l_phone_id;
    p_phn_wf_object_version_number := l_phn_object_version_number;
    --
 -- added for the bug 5301807
    end if;
-- end of bug 5301807
  END IF;
  --
  IF (p_pay_proposal_id IS NULL AND p_proposed_salary_n IS NOT NULL) OR
     (p_pay_proposal_id IS NOT NULL AND (
       NVL(per_pyp_shd.g_old_rec.change_date,hr_api.g_date)
     <>NVL(p_change_date,hr_api.g_date)
     OR NVL(per_pyp_shd.g_old_rec.proposed_salary_n,hr_api.g_number)
     <>NVL(p_proposed_salary_n,hr_api.g_number)
     OR NVL(per_pyp_shd.g_old_rec.proposal_reason,hr_api.g_varchar2)
     <>NVL(p_proposal_reason,hr_api.g_varchar2)
     OR NVL(per_pyp_shd.g_old_rec.attribute_category,hr_api.g_varchar2)
     <>NVL(p_pyp_attribute_category,hr_api.g_varchar2)
     OR NVL(per_pyp_shd.g_old_rec.attribute1,hr_api.g_varchar2)
     <>NVL(p_pyp_attribute1,hr_api.g_varchar2)
     OR NVL(per_pyp_shd.g_old_rec.attribute2,hr_api.g_varchar2)
     <>NVL(p_pyp_attribute2,hr_api.g_varchar2)
     OR NVL(per_pyp_shd.g_old_rec.attribute3,hr_api.g_varchar2)
     <>NVL(p_pyp_attribute3,hr_api.g_varchar2)
     OR NVL(per_pyp_shd.g_old_rec.attribute4,hr_api.g_varchar2)
     <>NVL(p_pyp_attribute4,hr_api.g_varchar2)
     OR NVL(per_pyp_shd.g_old_rec.attribute5,hr_api.g_varchar2)
     <>NVL(p_pyp_attribute5,hr_api.g_varchar2)
     OR NVL(per_pyp_shd.g_old_rec.attribute6,hr_api.g_varchar2)
     <>NVL(p_pyp_attribute6,hr_api.g_varchar2)
     OR NVL(per_pyp_shd.g_old_rec.attribute7,hr_api.g_varchar2)
     <>NVL(p_pyp_attribute7,hr_api.g_varchar2)
     OR NVL(per_pyp_shd.g_old_rec.attribute8,hr_api.g_varchar2)
     <>NVL(p_pyp_attribute8,hr_api.g_varchar2)
     OR NVL(per_pyp_shd.g_old_rec.attribute9,hr_api.g_varchar2)
     <>NVL(p_pyp_attribute9,hr_api.g_varchar2)
     OR NVL(per_pyp_shd.g_old_rec.attribute10,hr_api.g_varchar2)
     <>NVL(p_pyp_attribute10,hr_api.g_varchar2)
     OR NVL(per_pyp_shd.g_old_rec.attribute11,hr_api.g_varchar2)
     <>NVL(p_pyp_attribute11,hr_api.g_varchar2)
     OR NVL(per_pyp_shd.g_old_rec.attribute12,hr_api.g_varchar2)
     <>NVL(p_pyp_attribute12,hr_api.g_varchar2)
     OR NVL(per_pyp_shd.g_old_rec.attribute13,hr_api.g_varchar2)
     <>NVL(p_pyp_attribute13,hr_api.g_varchar2)
     OR NVL(per_pyp_shd.g_old_rec.attribute14,hr_api.g_varchar2)
     <>NVL(p_pyp_attribute14,hr_api.g_varchar2)
     OR NVL(per_pyp_shd.g_old_rec.attribute15,hr_api.g_varchar2)
     <>NVL(p_pyp_attribute15,hr_api.g_varchar2)
     OR NVL(per_pyp_shd.g_old_rec.attribute16,hr_api.g_varchar2)
     <>NVL(p_pyp_attribute16,hr_api.g_varchar2)
     OR NVL(per_pyp_shd.g_old_rec.attribute17,hr_api.g_varchar2)
     <>NVL(p_pyp_attribute17,hr_api.g_varchar2)
     OR NVL(per_pyp_shd.g_old_rec.attribute18,hr_api.g_varchar2)
     <>NVL(p_pyp_attribute18,hr_api.g_varchar2)
     OR NVL(per_pyp_shd.g_old_rec.attribute19,hr_api.g_varchar2)
     <>NVL(p_pyp_attribute19,hr_api.g_varchar2)
     OR NVL(per_pyp_shd.g_old_rec.attribute20,hr_api.g_varchar2)
     <>NVL(p_pyp_attribute20,hr_api.g_varchar2)
     OR NVL(per_pyp_shd.g_old_rec.approved,hr_api.g_varchar2)
     <>NVL(p_approved,hr_api.g_varchar2) )) THEN
    --
    --
    hr_maintain_proposal_api.cre_or_upd_salary_proposal
      (p_pay_proposal_id              => l_pay_proposal_id
      ,p_object_version_number        => l_pyp_object_version_number
      ,p_business_group_id            => p_business_group_id
      ,p_assignment_id                => p_assignment_id
      ,p_change_date                  => p_change_date
      ,p_proposal_reason              => p_proposal_reason
      ,p_proposed_salary_n            => p_proposed_salary_n
      ,p_attribute_category           => p_pyp_attribute_category
      ,p_attribute1                   => p_pyp_attribute1
      ,p_attribute2                   => p_pyp_attribute2
      ,p_attribute3                   => p_pyp_attribute3
      ,p_attribute4                   => p_pyp_attribute4
      ,p_attribute5                   => p_pyp_attribute5
      ,p_attribute6                   => p_pyp_attribute6
      ,p_attribute7                   => p_pyp_attribute7
      ,p_attribute8                   => p_pyp_attribute8
      ,p_attribute9                   => p_pyp_attribute9
      ,p_attribute10                  => p_pyp_attribute10
      ,p_attribute11                  => p_pyp_attribute11
      ,p_attribute12                  => p_pyp_attribute12
      ,p_attribute13                  => p_pyp_attribute13
      ,p_attribute14                  => p_pyp_attribute14
      ,p_attribute15                  => p_pyp_attribute15
      ,p_attribute16                  => p_pyp_attribute16
      ,p_attribute17                  => p_pyp_attribute17
      ,p_attribute18                  => p_pyp_attribute18
      ,p_attribute19                  => p_pyp_attribute19
      ,p_attribute20                  => p_pyp_attribute20
      ,p_approved                     => p_approved
      ,p_inv_next_sal_date_warning    => l_inv_next_sal_date_warning
      ,p_proposed_salary_warning      => l_proposed_salary_warning
      ,p_approved_warning             => l_approved_warning
      ,p_payroll_warning              => l_payroll_warning
    );
  END IF;
  p_pay_proposal_id:=l_pay_proposal_id;
  p_pyp_object_version_number:=l_pyp_object_version_number;
  p_proposed_salary_warning:=l_proposed_salary_warning;
  p_approved_warning:=l_approved_warning;
  p_payroll_warning:=l_payroll_warning;
  --
  IF p_deployment_factor_id IS NULL THEN
    IF NVL(p_work_any_country,'N')<>'N'
    OR NVL(p_work_any_location,'N')<>'N'
    OR NVL(p_relocate_domestically,'N')<>'N'
    OR NVL(p_relocate_internationally,'N')<>'N'
    OR NVL(p_travel_required,'N')<>'N'
    OR p_country1 IS NOT NULL
    OR p_country2 IS NOT NULL
    OR p_country3 IS NOT NULL
    OR p_dpf_work_duration IS NOT NULL
    OR p_dpf_work_schedule IS NOT NULL
    OR p_dpf_work_hours IS NOT NULL
    OR p_dpf_fte_capacity IS NOT NULL
    OR NVL( p_visit_internationally,'N')<>'N'
    OR NVL(p_only_current_location,'N')<>'N'
    OR p_no_country1 IS NOT NULL
    OR p_no_country2 IS NOT NULL
    OR p_no_country3 IS NOT NULL
    OR p_earliest_available_date IS NOT NULL
    OR NVL(p_available_for_transfer,'N')<>'N'
    OR p_relocation_preference IS NOT NULL
    OR p_dpf_attribute_category IS NOT NULL
    OR p_dpf_attribute1  IS NOT NULL
    OR p_dpf_attribute2  IS NOT NULL
    OR p_dpf_attribute3  IS NOT NULL
    OR p_dpf_attribute4  IS NOT NULL
    OR p_dpf_attribute5  IS NOT NULL
    OR p_dpf_attribute6  IS NOT NULL
    OR p_dpf_attribute7  IS NOT NULL
    OR p_dpf_attribute8  IS NOT NULL
    OR p_dpf_attribute9  IS NOT NULL
    OR p_dpf_attribute10 IS NOT NULL
    OR p_dpf_attribute11 IS NOT NULL
    OR p_dpf_attribute12 IS NOT NULL
    OR p_dpf_attribute13 IS NOT NULL
    OR p_dpf_attribute14 IS NOT NULL
    OR p_dpf_attribute15 IS NOT NULL
    OR p_dpf_attribute16 IS NOT NULL
    OR p_dpf_attribute17 IS NOT NULL
    OR p_dpf_attribute18 IS NOT NULL
    OR p_dpf_attribute19 IS NOT NULL
    OR p_dpf_attribute20 IS NOT NULL THEN
    --
      hr_deployment_factor_api.create_person_dpmt_factor
      (p_effective_date                => p_effective_date
      ,p_person_id                     => p_person_id
      ,p_work_any_country              => p_work_any_country
      ,p_work_any_location             => p_work_any_location
      ,p_relocate_domestically         => p_relocate_domestically
      ,p_relocate_internationally      => p_relocate_internationally
      ,p_travel_required               => p_travel_required
      ,p_country1                      => p_country1
      ,p_country2                      => p_country2
      ,p_country3                      => p_country3
      ,p_work_duration                 => p_dpf_work_duration
      ,p_work_schedule                 => p_dpf_work_schedule
      ,p_work_hours                    => p_dpf_work_hours
      ,p_fte_capacity                  => p_dpf_fte_capacity
      ,p_visit_internationally         => p_visit_internationally
      ,p_only_current_location         => p_only_current_location
      ,p_no_country1                   => p_no_country1
      ,p_no_country2                   => p_no_country2
      ,p_no_country3                   => p_no_country3
      ,p_earliest_available_date       => p_earliest_available_date
      ,p_available_for_transfer        => p_available_for_transfer
      ,p_relocation_preference         => p_relocation_preference
      ,p_attribute_category            => p_dpf_attribute_category
      ,p_attribute1                    => p_dpf_attribute1
      ,p_attribute2                    => p_dpf_attribute2
      ,p_attribute3                    => p_dpf_attribute3
      ,p_attribute4                    => p_dpf_attribute4
      ,p_attribute5                    => p_dpf_attribute5
      ,p_attribute6                    => p_dpf_attribute6
      ,p_attribute7                    => p_dpf_attribute7
      ,p_attribute8                    => p_dpf_attribute8
      ,p_attribute9                    => p_dpf_attribute9
      ,p_attribute10                   => p_dpf_attribute10
      ,p_attribute11                   => p_dpf_attribute11
      ,p_attribute12                   => p_dpf_attribute12
      ,p_attribute13                   => p_dpf_attribute13
      ,p_attribute14                   => p_dpf_attribute14
      ,p_attribute15                   => p_dpf_attribute15
      ,p_attribute16                   => p_dpf_attribute16
      ,p_attribute17                   => p_dpf_attribute17
      ,p_attribute18                   => p_dpf_attribute18
      ,p_attribute19                   => p_dpf_attribute19
      ,p_attribute20                   => p_dpf_attribute20
      ,p_deployment_factor_id          => l_deployment_factor_id
      ,p_object_version_number         => l_dpf_object_version_number
      );
    END IF;
  ELSE
    --
    IF NVL(per_dpf_shd.g_old_rec.work_any_country,hr_api.g_varchar2)
       <> NVL(p_work_any_country,hr_api.g_varchar2)
       OR NVL(per_dpf_shd.g_old_rec.work_any_location,hr_api.g_varchar2)
       <> NVL(p_work_any_location,hr_api.g_varchar2)
       OR NVL(per_dpf_shd.g_old_rec.relocate_domestically,hr_api.g_varchar2)
       <> NVL(p_relocate_domestically,hr_api.g_varchar2)
       OR NVL(per_dpf_shd.g_old_rec.relocate_internationally,hr_api.g_varchar2)
       <> NVL(p_relocate_internationally,hr_api.g_varchar2)
       OR NVL(per_dpf_shd.g_old_rec.travel_required,hr_api.g_varchar2)
       <> NVL(p_travel_required,hr_api.g_varchar2)
       OR NVL(per_dpf_shd.g_old_rec.country1,hr_api.g_varchar2)
       <> NVL(p_country1,hr_api.g_varchar2)
       OR NVL(per_dpf_shd.g_old_rec.country2,hr_api.g_varchar2)
       <> NVL(p_country2,hr_api.g_varchar2)
       OR NVL(per_dpf_shd.g_old_rec.country3,hr_api.g_varchar2)
       <> NVL(p_country3,hr_api.g_varchar2)
       OR NVL(per_dpf_shd.g_old_rec.work_duration,hr_api.g_varchar2)
       <> NVL(p_dpf_work_duration,hr_api.g_varchar2)
       OR NVL(per_dpf_shd.g_old_rec.work_schedule,hr_api.g_varchar2)
       <> NVL(p_dpf_work_schedule,hr_api.g_varchar2)
       OR NVL(per_dpf_shd.g_old_rec.work_hours,hr_api.g_varchar2)
       <> NVL(p_dpf_work_hours,hr_api.g_varchar2)
       OR NVL(per_dpf_shd.g_old_rec.fte_capacity,hr_api.g_varchar2)
       <> NVL(p_dpf_fte_capacity,hr_api.g_varchar2)
       OR NVL(per_dpf_shd.g_old_rec.visit_internationally,hr_api.g_varchar2)
       <> NVL(p_visit_internationally,hr_api.g_varchar2)
       OR NVL(per_dpf_shd.g_old_rec.only_current_location,hr_api.g_varchar2)
       <> NVL(p_only_current_location,hr_api.g_varchar2)
       OR NVL(per_dpf_shd.g_old_rec.no_country1,hr_api.g_varchar2)
       <> NVL(p_no_country1,hr_api.g_varchar2)
       OR NVL(per_dpf_shd.g_old_rec.no_country2,hr_api.g_varchar2)
       <> NVL(p_no_country2,hr_api.g_varchar2)
       OR NVL(per_dpf_shd.g_old_rec.no_country3,hr_api.g_varchar2)
       <> NVL(p_no_country3,hr_api.g_varchar2)
       OR NVL(per_dpf_shd.g_old_rec.earliest_available_date,hr_api.g_date)
       <> NVL(p_earliest_available_date,hr_api.g_date)
       OR NVL(per_dpf_shd.g_old_rec.available_for_transfer,hr_api.g_varchar2)
       <> NVL(p_available_for_transfer,hr_api.g_varchar2)
       OR NVL(per_dpf_shd.g_old_rec.relocation_preference,hr_api.g_varchar2)
       <> NVL(p_relocation_preference,hr_api.g_varchar2)
       OR NVL(per_dpf_shd.g_old_rec.attribute_category,hr_api.g_varchar2)
       <> NVL(p_dpf_attribute_category,hr_api.g_varchar2)
       OR NVL(per_dpf_shd.g_old_rec.attribute1,hr_api.g_varchar2)
       <> NVL(p_dpf_attribute1,hr_api.g_varchar2)
       OR NVL(per_dpf_shd.g_old_rec.attribute2,hr_api.g_varchar2)
       <> NVL(p_dpf_attribute2,hr_api.g_varchar2)
       OR NVL(per_dpf_shd.g_old_rec.attribute3,hr_api.g_varchar2)
       <> NVL(p_dpf_attribute3,hr_api.g_varchar2)
       OR NVL(per_dpf_shd.g_old_rec.attribute4,hr_api.g_varchar2)
       <> NVL(p_dpf_attribute4,hr_api.g_varchar2)
       OR NVL(per_dpf_shd.g_old_rec.attribute5,hr_api.g_varchar2)
       <> NVL(p_dpf_attribute5,hr_api.g_varchar2)
       OR NVL(per_dpf_shd.g_old_rec.attribute6,hr_api.g_varchar2)
       <> NVL(p_dpf_attribute6,hr_api.g_varchar2)
       OR NVL(per_dpf_shd.g_old_rec.attribute7,hr_api.g_varchar2)
       <> NVL(p_dpf_attribute7,hr_api.g_varchar2)
       OR NVL(per_dpf_shd.g_old_rec.attribute8,hr_api.g_varchar2)
       <> NVL(p_dpf_attribute8,hr_api.g_varchar2)
       OR NVL(per_dpf_shd.g_old_rec.attribute9,hr_api.g_varchar2)
       <> NVL(p_dpf_attribute9,hr_api.g_varchar2)
       OR NVL(per_dpf_shd.g_old_rec.attribute10,hr_api.g_varchar2)
       <> NVL(p_dpf_attribute10,hr_api.g_varchar2)
       OR NVL(per_dpf_shd.g_old_rec.attribute11,hr_api.g_varchar2)
       <> NVL(p_dpf_attribute11,hr_api.g_varchar2)
       OR NVL(per_dpf_shd.g_old_rec.attribute12,hr_api.g_varchar2)
       <> NVL(p_dpf_attribute12,hr_api.g_varchar2)
       OR NVL(per_dpf_shd.g_old_rec.attribute13,hr_api.g_varchar2)
       <> NVL(p_dpf_attribute13,hr_api.g_varchar2)
       OR NVL(per_dpf_shd.g_old_rec.attribute14,hr_api.g_varchar2)
       <> NVL(p_dpf_attribute14,hr_api.g_varchar2)
       OR NVL(per_dpf_shd.g_old_rec.attribute15,hr_api.g_varchar2)
       <> NVL(p_dpf_attribute15,hr_api.g_varchar2)
       OR NVL(per_dpf_shd.g_old_rec.attribute16,hr_api.g_varchar2)
       <> NVL(p_dpf_attribute16,hr_api.g_varchar2)
       OR NVL(per_dpf_shd.g_old_rec.attribute17,hr_api.g_varchar2)
       <> NVL(p_dpf_attribute17,hr_api.g_varchar2)
       OR NVL(per_dpf_shd.g_old_rec.attribute18,hr_api.g_varchar2)
       <> NVL(p_dpf_attribute18,hr_api.g_varchar2)
       OR NVL(per_dpf_shd.g_old_rec.attribute19,hr_api.g_varchar2)
       <> NVL(p_dpf_attribute19,hr_api.g_varchar2)
       OR NVL(per_dpf_shd.g_old_rec.attribute20,hr_api.g_varchar2)
       <> NVL(p_dpf_attribute20,hr_api.g_varchar2) THEN
      --
      hr_deployment_factor_api.update_person_dpmt_factor
      (p_effective_date                => p_effective_date
      ,p_deployment_factor_id          => l_deployment_factor_id
      ,p_object_version_number         => l_dpf_object_version_number
      ,p_work_any_country              => p_work_any_country
      ,p_work_any_location             => p_work_any_location
      ,p_relocate_domestically         => p_relocate_domestically
      ,p_relocate_internationally      => p_relocate_internationally
      ,p_travel_required               => p_travel_required
      ,p_country1                      => p_country1
      ,p_country2                      => p_country2
      ,p_country3                      => p_country3
      ,p_work_duration                 => p_dpf_work_duration
      ,p_work_schedule                 => p_dpf_work_schedule
      ,p_work_hours                    => p_dpf_work_hours
      ,p_fte_capacity                  => p_dpf_fte_capacity
      ,p_visit_internationally         => p_visit_internationally
      ,p_only_current_location         => p_only_current_location
      ,p_no_country1                   => p_no_country1
      ,p_no_country2                   => p_no_country2
      ,p_no_country3                   => p_no_country3
      ,p_earliest_available_date       => p_earliest_available_date
      ,p_available_for_transfer        => p_available_for_transfer
      ,p_relocation_preference         => p_relocation_preference
      ,p_attribute_category            => p_dpf_attribute_category
      ,p_attribute1                    => p_dpf_attribute1
      ,p_attribute2                    => p_dpf_attribute2
      ,p_attribute3                    => p_dpf_attribute3
      ,p_attribute4                    => p_dpf_attribute4
      ,p_attribute5                    => p_dpf_attribute5
      ,p_attribute6                    => p_dpf_attribute6
      ,p_attribute7                    => p_dpf_attribute7
      ,p_attribute8                    => p_dpf_attribute8
      ,p_attribute9                    => p_dpf_attribute9
      ,p_attribute10                   => p_dpf_attribute10
      ,p_attribute11                   => p_dpf_attribute11
      ,p_attribute12                   => p_dpf_attribute12
      ,p_attribute13                   => p_dpf_attribute13
      ,p_attribute14                   => p_dpf_attribute14
      ,p_attribute15                   => p_dpf_attribute15
      ,p_attribute16                   => p_dpf_attribute16
      ,p_attribute17                   => p_dpf_attribute17
      ,p_attribute18                   => p_dpf_attribute18
      ,p_attribute19                   => p_dpf_attribute19
      ,p_attribute20                   => p_dpf_attribute20
      );
    END IF;
  END IF;
  --
  p_deployment_factor_id:=l_deployment_factor_id;
  p_dpf_object_version_number:=l_dpf_object_version_number;
  --
  l_checklist_item_id:=p_chk1_checklist_item_id;
  l_chk_object_version_number:= p_chk1_object_version_number;
  --
  IF l_checklist_item_id IS NOT NULL THEN
    per_chk_shd.lck
    (p_checklist_item_id     => l_checklist_item_id
    ,p_object_version_number => l_chk_object_version_number);
  END IF;
  --
  IF (l_checklist_item_id IS NULL  AND
      p_chk1_item_code IS NOT NULL AND
      (  p_chk1_status     IS NOT NULL
      OR p_chk1_date_due   IS NOT NULL
      OR p_chk1_date_done  IS NOT NULL
      OR p_chk1_notes      IS NOT NULL)) OR
     (l_checklist_item_id IS NOT NULL AND
      (  NVL(per_chk_shd.g_old_rec.status,hr_api.g_varchar2)
      <> NVL(p_chk1_status,hr_api.g_varchar2)
      OR NVL(per_chk_shd.g_old_rec.date_due,hr_api.g_date)
      <> NVL(p_chk1_date_due,hr_api.g_date)
      OR NVL(per_chk_shd.g_old_rec.date_done,hr_api.g_date)
      <> NVL(p_chk1_date_done,hr_api.g_date)
      OR NVL(per_chk_shd.g_old_rec.notes,hr_api.g_varchar2)
      <> NVL(p_chk1_notes,hr_api.g_varchar2))) THEN
    --
    per_checklist_items_api.cre_or_upd_checklist_items
    (p_effective_date => p_effective_date
    ,p_checklist_item_id => l_checklist_item_id
    ,p_object_version_number => l_chk_object_version_number
    ,p_person_id => p_person_id
    ,p_item_code => p_chk1_item_code
    ,p_date_due => p_chk1_date_due
    ,p_date_done => p_chk1_date_done
    ,p_status => p_chk1_status
    ,p_notes => p_chk1_notes
    );
    --
    p_chk1_checklist_item_id:=l_checklist_item_id;
    p_chk1_object_version_number:=l_chk_object_version_number;
    --
  END IF;
  --
  l_checklist_item_id:=p_chk2_checklist_item_id;
  l_chk_object_version_number:= p_chk2_object_version_number;
  --
  IF l_checklist_item_id IS NOT NULL THEN
    per_chk_shd.lck
    (p_checklist_item_id     => l_checklist_item_id
    ,p_object_version_number => l_chk_object_version_number);
  END IF;
  --
  IF (l_checklist_item_id IS NULL  AND
      p_chk2_item_code IS NOT NULL AND
      (  p_chk2_status     IS NOT NULL
      OR p_chk2_date_due   IS NOT NULL
      OR p_chk2_date_done  IS NOT NULL
      OR p_chk2_notes      IS NOT NULL)) OR
     (l_checklist_item_id IS NOT NULL AND
      (  NVL(per_chk_shd.g_old_rec.status,hr_api.g_varchar2)
      <> NVL(p_chk2_status,hr_api.g_varchar2)
      OR NVL(per_chk_shd.g_old_rec.date_due,hr_api.g_date)
      <> NVL(p_chk2_date_due,hr_api.g_date)
      OR NVL(per_chk_shd.g_old_rec.date_done,hr_api.g_date)
      <> NVL(p_chk2_date_done,hr_api.g_date)
      OR NVL(per_chk_shd.g_old_rec.notes,hr_api.g_varchar2)
      <> NVL(p_chk2_notes,hr_api.g_varchar2))) THEN
    --
    per_checklist_items_api.cre_or_upd_checklist_items
    (p_effective_date => p_effective_date
    ,p_checklist_item_id => l_checklist_item_id
    ,p_object_version_number => l_chk_object_version_number
    ,p_person_id => p_person_id
    ,p_item_code => p_chk2_item_code
    ,p_date_due => p_chk2_date_due
    ,p_date_done => p_chk2_date_done
    ,p_status => p_chk2_status
    ,p_notes => p_chk2_notes
    );
    --
    p_chk2_checklist_item_id:=l_checklist_item_id;
    p_chk2_object_version_number:=l_chk_object_version_number;
    --
  END IF;
  --
  l_checklist_item_id:=p_chk3_checklist_item_id;
  l_chk_object_version_number:= p_chk3_object_version_number;
  --
  IF l_checklist_item_id IS NOT NULL THEN
    per_chk_shd.lck
    (p_checklist_item_id     => l_checklist_item_id
    ,p_object_version_number => l_chk_object_version_number);
  END IF;
  --
  IF (l_checklist_item_id IS NULL  AND
      p_chk3_item_code IS NOT NULL AND
      (  p_chk3_status     IS NOT NULL
      OR p_chk3_date_due   IS NOT NULL
      OR p_chk3_date_done  IS NOT NULL
      OR p_chk3_notes      IS NOT NULL)) OR
     (l_checklist_item_id IS NOT NULL AND
      (  NVL(per_chk_shd.g_old_rec.status,hr_api.g_varchar2)
      <> NVL(p_chk3_status,hr_api.g_varchar2)
      OR NVL(per_chk_shd.g_old_rec.date_due,hr_api.g_date)
      <> NVL(p_chk3_date_due,hr_api.g_date)
      OR NVL(per_chk_shd.g_old_rec.date_done,hr_api.g_date)
      <> NVL(p_chk3_date_done,hr_api.g_date)
      OR NVL(per_chk_shd.g_old_rec.notes,hr_api.g_varchar2)
      <> NVL(p_chk3_notes,hr_api.g_varchar2))) THEN
    --
    per_checklist_items_api.cre_or_upd_checklist_items
    (p_effective_date => p_effective_date
    ,p_checklist_item_id => l_checklist_item_id
    ,p_object_version_number => l_chk_object_version_number
    ,p_person_id => p_person_id
    ,p_item_code => p_chk3_item_code
    ,p_date_due => p_chk3_date_due
    ,p_date_done => p_chk3_date_done
    ,p_status => p_chk3_status
    ,p_notes => p_chk3_notes
    );
    --
    p_chk3_checklist_item_id:=l_checklist_item_id;
    p_chk3_object_version_number:=l_chk_object_version_number;
    --
  END IF;
  --
  l_checklist_item_id:=p_chk4_checklist_item_id;
  l_chk_object_version_number:= p_chk4_object_version_number;
  --
  IF l_checklist_item_id IS NOT NULL THEN
    per_chk_shd.lck
    (p_checklist_item_id     => l_checklist_item_id
    ,p_object_version_number => l_chk_object_version_number);
  END IF;
  --
  IF (l_checklist_item_id IS NULL  AND
      p_chk4_item_code IS NOT NULL AND
      (  p_chk4_status     IS NOT NULL
      OR p_chk4_date_due   IS NOT NULL
      OR p_chk4_date_done  IS NOT NULL
      OR p_chk4_notes      IS NOT NULL)) OR
     (l_checklist_item_id IS NOT NULL AND
      (  NVL(per_chk_shd.g_old_rec.status,hr_api.g_varchar2)
      <> NVL(p_chk4_status,hr_api.g_varchar2)
      OR NVL(per_chk_shd.g_old_rec.date_due,hr_api.g_date)
      <> NVL(p_chk4_date_due,hr_api.g_date)
      OR NVL(per_chk_shd.g_old_rec.date_done,hr_api.g_date)
      <> NVL(p_chk4_date_done,hr_api.g_date)
      OR NVL(per_chk_shd.g_old_rec.notes,hr_api.g_varchar2)
      <> NVL(p_chk4_notes,hr_api.g_varchar2))) THEN
    --
    per_checklist_items_api.cre_or_upd_checklist_items
    (p_effective_date => p_effective_date
    ,p_checklist_item_id => l_checklist_item_id
    ,p_object_version_number => l_chk_object_version_number
    ,p_person_id => p_person_id
    ,p_item_code => p_chk4_item_code
    ,p_date_due => p_chk4_date_due
    ,p_date_done => p_chk4_date_done
    ,p_status => p_chk4_status
    ,p_notes => p_chk4_notes
    );
    --
    p_chk4_checklist_item_id:=l_checklist_item_id;
    p_chk4_object_version_number:=l_chk_object_version_number;
    --
  END IF;
  --
  l_checklist_item_id:=p_chk5_checklist_item_id;
  l_chk_object_version_number:= p_chk5_object_version_number;
  --
  IF l_checklist_item_id IS NOT NULL THEN
    per_chk_shd.lck
    (p_checklist_item_id     => l_checklist_item_id
    ,p_object_version_number => l_chk_object_version_number);
  END IF;
  --
  IF (l_checklist_item_id IS NULL  AND
      p_chk5_item_code IS NOT NULL AND
      (  p_chk5_status     IS NOT NULL
      OR p_chk5_date_due   IS NOT NULL
      OR p_chk5_date_done  IS NOT NULL
      OR p_chk5_notes      IS NOT NULL)) OR
     (l_checklist_item_id IS NOT NULL AND
      (  NVL(per_chk_shd.g_old_rec.status,hr_api.g_varchar2)
      <> NVL(p_chk5_status,hr_api.g_varchar2)
      OR NVL(per_chk_shd.g_old_rec.date_due,hr_api.g_date)
      <> NVL(p_chk5_date_due,hr_api.g_date)
      OR NVL(per_chk_shd.g_old_rec.date_done,hr_api.g_date)
      <> NVL(p_chk5_date_done,hr_api.g_date)
      OR NVL(per_chk_shd.g_old_rec.notes,hr_api.g_varchar2)
      <> NVL(p_chk5_notes,hr_api.g_varchar2))) THEN
    --
    per_checklist_items_api.cre_or_upd_checklist_items
    (p_effective_date => p_effective_date
    ,p_checklist_item_id => l_checklist_item_id
    ,p_object_version_number => l_chk_object_version_number
    ,p_person_id => p_person_id
    ,p_item_code => p_chk5_item_code
    ,p_date_due => p_chk5_date_due
    ,p_date_done => p_chk5_date_done
    ,p_status => p_chk5_status
    ,p_notes => p_chk5_notes
    );
    --
    p_chk5_checklist_item_id:=l_checklist_item_id;
    p_chk5_object_version_number:=l_chk_object_version_number;
    --
  END IF;
  --
  l_checklist_item_id:=p_chk6_checklist_item_id;
  l_chk_object_version_number:= p_chk6_object_version_number;
  --
  IF l_checklist_item_id IS NOT NULL THEN
    per_chk_shd.lck
    (p_checklist_item_id     => l_checklist_item_id
    ,p_object_version_number => l_chk_object_version_number);
  END IF;
  --
  IF (l_checklist_item_id IS NULL  AND
      p_chk6_item_code IS NOT NULL AND
      (  p_chk6_status     IS NOT NULL
      OR p_chk6_date_due   IS NOT NULL
      OR p_chk6_date_done  IS NOT NULL
      OR p_chk6_notes      IS NOT NULL)) OR
     (l_checklist_item_id IS NOT NULL AND
      (  NVL(per_chk_shd.g_old_rec.status,hr_api.g_varchar2)
      <> NVL(p_chk6_status,hr_api.g_varchar2)
      OR NVL(per_chk_shd.g_old_rec.date_due,hr_api.g_date)
      <> NVL(p_chk6_date_due,hr_api.g_date)
      OR NVL(per_chk_shd.g_old_rec.date_done,hr_api.g_date)
      <> NVL(p_chk6_date_done,hr_api.g_date)
      OR NVL(per_chk_shd.g_old_rec.notes,hr_api.g_varchar2)
      <> NVL(p_chk6_notes,hr_api.g_varchar2))) THEN
    --
    per_checklist_items_api.cre_or_upd_checklist_items
    (p_effective_date => p_effective_date
    ,p_checklist_item_id => l_checklist_item_id
    ,p_object_version_number => l_chk_object_version_number
    ,p_person_id => p_person_id
    ,p_item_code => p_chk6_item_code
    ,p_date_due => p_chk6_date_due
    ,p_date_done => p_chk6_date_done
    ,p_status => p_chk6_status
    ,p_notes => p_chk6_notes
    );
    --
    p_chk6_checklist_item_id:=l_checklist_item_id;
    p_chk6_object_version_number:=l_chk_object_version_number;
    --
  END IF;
  --
  l_checklist_item_id:=p_chk7_checklist_item_id;
  l_chk_object_version_number:= p_chk7_object_version_number;
  --
  IF l_checklist_item_id IS NOT NULL THEN
    per_chk_shd.lck
    (p_checklist_item_id     => l_checklist_item_id
    ,p_object_version_number => l_chk_object_version_number);
  END IF;
  --
  IF (l_checklist_item_id IS NULL  AND
      p_chk7_item_code IS NOT NULL AND
      (  p_chk7_status     IS NOT NULL
      OR p_chk7_date_due   IS NOT NULL
      OR p_chk7_date_done  IS NOT NULL
      OR p_chk7_notes      IS NOT NULL)) OR
     (l_checklist_item_id IS NOT NULL AND
      (  NVL(per_chk_shd.g_old_rec.status,hr_api.g_varchar2)
      <> NVL(p_chk7_status,hr_api.g_varchar2)
      OR NVL(per_chk_shd.g_old_rec.date_due,hr_api.g_date)
      <> NVL(p_chk7_date_due,hr_api.g_date)
      OR NVL(per_chk_shd.g_old_rec.date_done,hr_api.g_date)
      <> NVL(p_chk7_date_done,hr_api.g_date)
      OR NVL(per_chk_shd.g_old_rec.notes,hr_api.g_varchar2)
      <> NVL(p_chk7_notes,hr_api.g_varchar2))) THEN
    --
    per_checklist_items_api.cre_or_upd_checklist_items
    (p_effective_date => p_effective_date
    ,p_checklist_item_id => l_checklist_item_id
    ,p_object_version_number => l_chk_object_version_number
    ,p_person_id => p_person_id
    ,p_item_code => p_chk7_item_code
    ,p_date_due => p_chk7_date_due
    ,p_date_done => p_chk7_date_done
    ,p_status => p_chk7_status
    ,p_notes => p_chk7_notes
    );
    --
    p_chk7_checklist_item_id:=l_checklist_item_id;
    p_chk7_object_version_number:=l_chk_object_version_number;
    --
  END IF;
  --
  l_checklist_item_id:=p_chk8_checklist_item_id;
  l_chk_object_version_number:= p_chk8_object_version_number;
  --
  IF l_checklist_item_id IS NOT NULL THEN
    per_chk_shd.lck
    (p_checklist_item_id     => l_checklist_item_id
    ,p_object_version_number => l_chk_object_version_number);
  END IF;
  --
  IF (l_checklist_item_id IS NULL  AND
      p_chk8_item_code IS NOT NULL AND
      (  p_chk8_status     IS NOT NULL
      OR p_chk8_date_due   IS NOT NULL
      OR p_chk8_date_done  IS NOT NULL
      OR p_chk8_notes      IS NOT NULL)) OR
     (l_checklist_item_id IS NOT NULL AND
      (  NVL(per_chk_shd.g_old_rec.status,hr_api.g_varchar2)
      <> NVL(p_chk8_status,hr_api.g_varchar2)
      OR NVL(per_chk_shd.g_old_rec.date_due,hr_api.g_date)
      <> NVL(p_chk8_date_due,hr_api.g_date)
      OR NVL(per_chk_shd.g_old_rec.date_done,hr_api.g_date)
      <> NVL(p_chk8_date_done,hr_api.g_date)
      OR NVL(per_chk_shd.g_old_rec.notes,hr_api.g_varchar2)
      <> NVL(p_chk8_notes,hr_api.g_varchar2))) THEN
    --
    per_checklist_items_api.cre_or_upd_checklist_items
    (p_effective_date => p_effective_date
    ,p_checklist_item_id => l_checklist_item_id
    ,p_object_version_number => l_chk_object_version_number
    ,p_person_id => p_person_id
    ,p_item_code => p_chk8_item_code
    ,p_date_due => p_chk8_date_due
    ,p_date_done => p_chk8_date_done
    ,p_status => p_chk8_status
    ,p_notes => p_chk8_notes
    );
    --
    p_chk8_checklist_item_id:=l_checklist_item_id;
    p_chk8_object_version_number:=l_chk_object_version_number;
    --
  END IF;
  --
  l_checklist_item_id:=p_chk9_checklist_item_id;
  l_chk_object_version_number:= p_chk9_object_version_number;
  --
  IF l_checklist_item_id IS NOT NULL THEN
    per_chk_shd.lck
    (p_checklist_item_id     => l_checklist_item_id
    ,p_object_version_number => l_chk_object_version_number);
  END IF;
  --
  IF (l_checklist_item_id IS NULL  AND
      p_chk9_item_code IS NOT NULL AND
      (  p_chk9_status     IS NOT NULL
      OR p_chk9_date_due   IS NOT NULL
      OR p_chk9_date_done  IS NOT NULL
      OR p_chk9_notes      IS NOT NULL)) OR
     (l_checklist_item_id IS NOT NULL AND
      (  NVL(per_chk_shd.g_old_rec.status,hr_api.g_varchar2)
      <> NVL(p_chk9_status,hr_api.g_varchar2)
      OR NVL(per_chk_shd.g_old_rec.date_due,hr_api.g_date)
      <> NVL(p_chk9_date_due,hr_api.g_date)
      OR NVL(per_chk_shd.g_old_rec.date_done,hr_api.g_date)
      <> NVL(p_chk9_date_done,hr_api.g_date)
      OR NVL(per_chk_shd.g_old_rec.notes,hr_api.g_varchar2)
      <> NVL(p_chk9_notes,hr_api.g_varchar2))) THEN
    --
    per_checklist_items_api.cre_or_upd_checklist_items
    (p_effective_date => p_effective_date
    ,p_checklist_item_id => l_checklist_item_id
    ,p_object_version_number => l_chk_object_version_number
    ,p_person_id => p_person_id
    ,p_item_code => p_chk9_item_code
    ,p_date_due => p_chk9_date_due
    ,p_date_done => p_chk9_date_done
    ,p_status => p_chk9_status
    ,p_notes => p_chk9_notes
    );
    --
    p_chk9_checklist_item_id:=l_checklist_item_id;
    p_chk9_object_version_number:=l_chk_object_version_number;
    --
  END IF;
  --
  l_checklist_item_id:=p_chk10_checklist_item_id;
  l_chk_object_version_number:= p_chk10_object_version_number;
  --
  IF l_checklist_item_id IS NOT NULL THEN
    per_chk_shd.lck
    (p_checklist_item_id     => l_checklist_item_id
    ,p_object_version_number => l_chk_object_version_number);
  END IF;
  --
  IF (l_checklist_item_id IS NULL AND
      p_chk10_item_code IS NOT NULL AND
      (  p_chk10_status     IS NOT NULL
      OR p_chk10_date_due   IS NOT NULL
      OR p_chk10_date_done  IS NOT NULL
      OR p_chk10_notes      IS NOT NULL)) OR
     (l_checklist_item_id IS NOT NULL AND
      (  NVL(per_chk_shd.g_old_rec.status,hr_api.g_varchar2)
      <> NVL(p_chk10_status,hr_api.g_varchar2)
      OR NVL(per_chk_shd.g_old_rec.date_due,hr_api.g_date)
      <> NVL(p_chk10_date_due,hr_api.g_date)
      OR NVL(per_chk_shd.g_old_rec.date_done,hr_api.g_date)
      <> NVL(p_chk10_date_done,hr_api.g_date)
      OR NVL(per_chk_shd.g_old_rec.notes,hr_api.g_varchar2)
      <> NVL(p_chk10_notes,hr_api.g_varchar2))) THEN
    --
    per_checklist_items_api.cre_or_upd_checklist_items
    (p_effective_date => p_effective_date
    ,p_checklist_item_id => l_checklist_item_id
    ,p_object_version_number => l_chk_object_version_number
    ,p_person_id => p_person_id
    ,p_item_code => p_chk10_item_code
    ,p_date_due => p_chk10_date_due
    ,p_date_done => p_chk10_date_done
    ,p_status => p_chk10_status
    ,p_notes => p_chk10_notes
    );
  END IF;
    --
    p_chk10_checklist_item_id:=l_checklist_item_id;
    p_chk10_object_version_number:=l_chk_object_version_number;
    --
  per_qh_tax_update.update_tax_data
  (tax_effective_start_date => p_tax_effective_start_date
  ,tax_effective_end_date   => p_tax_effective_end_date
  ,tax_field1          => p_tax_field1
  ,tax_field2          => p_tax_field2
  ,tax_field3          => p_tax_field3
  ,tax_field4          => p_tax_field4
  ,tax_field5          => p_tax_field5
  ,tax_field6          => p_tax_field6
  ,tax_field7          => p_tax_field7
  ,tax_field8          => p_tax_field8
  ,tax_field9          => p_tax_field9
  ,tax_field10         => p_tax_field10
  ,tax_field11         => p_tax_field11
  ,tax_field12         => p_tax_field12
  ,tax_field13         => p_tax_field13
  ,tax_field14         => p_tax_field14
  ,tax_field15         => p_tax_field15
  ,tax_field16         => p_tax_field16
  ,tax_field17         => p_tax_field17
  ,tax_field18         => p_tax_field18
  ,tax_field19         => p_tax_field19
  ,tax_field20         => p_tax_field20
  ,tax_field21         => p_tax_field21
  ,tax_field22         => p_tax_field22
  ,tax_field23         => p_tax_field23
  ,tax_field24         => p_tax_field24
  ,tax_field25         => p_tax_field25
  ,tax_field26         => p_tax_field26
  ,tax_field27         => p_tax_field27
  ,tax_field28         => p_tax_field28
  ,tax_field29         => p_tax_field29
  ,tax_field30         => p_tax_field30
  ,tax_field31         => p_tax_field31
  ,tax_field32         => p_tax_field32
  ,tax_field33         => p_tax_field33
  ,tax_field34         => p_tax_field34
  ,tax_field35         => p_tax_field35
  ,tax_field36         => p_tax_field36
  ,tax_field37         => p_tax_field37
  ,tax_field38         => p_tax_field38
  ,tax_field39         => p_tax_field39
  ,tax_field40         => p_tax_field40
  ,tax_field41         => p_tax_field41
  ,tax_field42         => p_tax_field42
  ,tax_field43         => p_tax_field43
  ,tax_field44         => p_tax_field44
  ,tax_field45         => p_tax_field45
  ,tax_field46         => p_tax_field46
  ,tax_field47         => p_tax_field47
  ,tax_field48         => p_tax_field48
  ,tax_field49         => p_tax_field49
  ,tax_field50         => p_tax_field50
  ,tax_field51         => p_tax_field51
  ,tax_field52         => p_tax_field52
  ,tax_field53         => p_tax_field53
  ,tax_field54         => p_tax_field54
  ,tax_field55         => p_tax_field55
  ,tax_field56         => p_tax_field56
  ,tax_field57         => p_tax_field57
  ,tax_field58         => p_tax_field58
  ,tax_field59         => p_tax_field59
  ,tax_field60         => p_tax_field60
  ,tax_field61         => p_tax_field61
  ,tax_field62         => p_tax_field62
  ,tax_field63         => p_tax_field63
  ,tax_field64         => p_tax_field64
  ,tax_field65         => p_tax_field65
  ,tax_field66         => p_tax_field66
  ,tax_field67         => p_tax_field67
  ,tax_field68         => p_tax_field68
  ,tax_field69         => p_tax_field69
  ,tax_field70         => p_tax_field70
  ,tax_field71         => p_tax_field71
  ,tax_field72         => p_tax_field72
  ,tax_field73         => p_tax_field73
  ,tax_field74         => p_tax_field74
  ,tax_field75         => p_tax_field75
  ,tax_field76         => p_tax_field76
  ,tax_field77         => p_tax_field77
  ,tax_field78         => p_tax_field78
  ,tax_field79         => p_tax_field79
  ,tax_field80         => p_tax_field80
  ,tax_field81         => p_tax_field81
  ,tax_field82         => p_tax_field82
  ,tax_field83         => p_tax_field83
  ,tax_field84         => p_tax_field84
  ,tax_field85         => p_tax_field85
  ,tax_field86         => p_tax_field86
  ,tax_field87         => p_tax_field87
  ,tax_field88         => p_tax_field88
  ,tax_field89         => p_tax_field89
  ,tax_field90         => p_tax_field90
  ,tax_field91         => p_tax_field91
  ,tax_field92         => p_tax_field92
  ,tax_field93         => p_tax_field93
  ,tax_field94         => p_tax_field94
  ,tax_field95         => p_tax_field95
  ,tax_field96         => p_tax_field96
  ,tax_field97         => p_tax_field97
  ,tax_field98         => p_tax_field98
  ,tax_field99         => p_tax_field99
  ,tax_field100        => p_tax_field100
  ,tax_field101        => p_tax_field101
  ,tax_field102        => p_tax_field102
  ,tax_field103        => p_tax_field103
  ,tax_field104        => p_tax_field104
  ,tax_field105        => p_tax_field105
  ,tax_field106        => p_tax_field106
  ,tax_field107        => p_tax_field107
  ,tax_field108        => p_tax_field108
  ,tax_field109        => p_tax_field109
  ,tax_field110        => p_tax_field110
  ,tax_field111        => p_tax_field111
  ,tax_field112        => p_tax_field112
  ,tax_field113        => p_tax_field113
  ,tax_field114        => p_tax_field114
  ,tax_field115        => p_tax_field115
  ,tax_field116        => p_tax_field116
  ,tax_field117        => p_tax_field117
  ,tax_field118        => p_tax_field118
  ,tax_field119        => p_tax_field119
  ,tax_field120        => p_tax_field120
  ,tax_field121        => p_tax_field121
  ,tax_field122        => p_tax_field122
  ,tax_field123        => p_tax_field123
  ,tax_field124        => p_tax_field124
  ,tax_field125        => p_tax_field125
  ,tax_field126        => p_tax_field126
  ,tax_field127        => p_tax_field127
  ,tax_field128        => p_tax_field128
  ,tax_field129        => p_tax_field129
  ,tax_field130        => p_tax_field130
  ,tax_field131        => p_tax_field131
  ,tax_field132        => p_tax_field132
  ,tax_field133        => p_tax_field133
  ,tax_field134        => p_tax_field134
  ,tax_field135        => p_tax_field135
  ,tax_field136        => p_tax_field136
  ,tax_field137        => p_tax_field137
  ,tax_field138        => p_tax_field138
  ,tax_field139        => p_tax_field139
  ,tax_field140        => p_tax_field140
  ,tax_field141        => p_tax_field141
  ,tax_field142        => p_tax_field142
  ,tax_field143        => p_tax_field143
  ,tax_field144        => p_tax_field144
  ,tax_field145        => p_tax_field145
  ,tax_field146        => p_tax_field146
  ,tax_field147        => p_tax_field147
  ,tax_field148        => p_tax_field148
  ,tax_field149        => p_tax_field149
  ,tax_field150        => p_tax_field150
  ,tax_update_allowed  => p_tax_update_allowed
  ,p_person_id         => p_person_id
  ,p_assignment_id     => p_assignment_id
  ,p_legislation_code  => p_legislation_code
  ,p_effective_date    => p_effective_date
  );
--
--If tax routines are used by localizations, they could have changed OVNs on some tables
--We need to provide code here to pass back the correct OVNs to the form
--
if p_person_id is not null then
  select per.object_version_number into l_per_object_version_number
  from per_all_people_f per
  where per.person_id=p_person_id
  and p_effective_date between per.effective_start_date and per.effective_end_date;
  --
  p_per_object_version_number := l_per_object_version_number;
  --
end if;
if p_assignment_id is not null
and p_assignment_id > 0 then
  select asg.object_version_number into l_asg_object_version_number
  from per_all_assignments_f asg
  where asg.assignment_id=p_assignment_id
  and p_effective_date between asg.effective_start_date and asg.effective_end_date;
  --
  p_asg_object_version_number := l_asg_object_version_number;
end if;
  --
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO update_maintain_data;
    RAISE;
END update_maintain_data;

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
,p_pds_hire_date                IN     per_periods_of_service.date_start%TYPE
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
) IS
l_proc VARCHAR2(72) := g_package||'lock_maintain_data';
l_per_datetrack_update_mode VARCHAR2(30);
l_asg_datetrack_update_mode VARCHAR2(30);
l_rate_datetrack_update_mode VARCHAR2(30);
l_period_of_placement_id per_periods_of_placement.period_of_placement_id%TYPE;
l_rate_validation_start_date DATE;
l_rate_validation_end_date   DATE;
l_period_of_service_id   per_periods_of_service.period_of_service_id%TYPE;
--
CURSOR csr_pdp_rec
       (p_person_id NUMBER
       ,p_placement_date_start DATE) IS
SELECT period_of_placement_id
FROM  per_periods_of_placement
WHERE person_id = p_person_id
AND   date_start = p_placement_date_start;

CURSOR csr_pds_rec
       (p_person_id NUMBER
       ,p_pds_hire_date DATE) IS
SELECT period_of_service_id
FROM  per_periods_of_service
WHERE person_id = p_person_id
AND   date_start = p_pds_hire_date;
--
BEGIN
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  IF p_person_update_allowed='TRUE' THEN
    IF p_per_effective_start_date=p_effective_date THEN
      l_per_datetrack_update_mode:='CORRECTION';
    ELSE
      l_per_datetrack_update_mode:=p_datetrack_update_mode;
    END IF;

    per_per_shd.lck
    (p_effective_date        => p_effective_date
    ,p_datetrack_mode        => l_per_datetrack_update_mode
    ,p_person_id             => p_person_id
    ,p_object_version_number => p_per_object_version_number
    ,p_validation_start_date => p_per_validation_start_date
    ,p_validation_end_date   => p_per_validation_end_date
    );
    hr_utility.set_location(l_proc, 15);
    IF p_pdp_object_version_number IS NOT NULL then
      open csr_pdp_rec(p_person_id,p_placement_date_start);
      fetch csr_pdp_rec into l_period_of_placement_id;
      close csr_pdp_rec;
      per_pdp_shd.lck
      (p_period_of_placement_id     => l_period_of_placement_id
      ,p_object_version_number      => p_pdp_object_version_number
      );
    END IF;
  END IF;
  IF p_pds_object_version_number IS NOT NULL then
      open csr_pds_rec(p_person_id,p_pds_hire_date);
      fetch csr_pds_rec into l_period_of_service_id;
      close csr_pds_rec;
      per_pds_shd.lck
      (p_period_of_service_id     => l_period_of_service_id
      ,p_object_version_number      => p_pds_object_version_number
      );
    END IF;
  --
  IF p_assignment_id IS NOT NULL AND p_assignment_update_allowed='TRUE' THEN
      hr_utility.set_location(l_proc, 20);
      --
      IF p_asg_effective_start_date=p_effective_date THEN
        l_asg_datetrack_update_mode:='CORRECTION';
      ELSE
        l_asg_datetrack_update_mode:=p_datetrack_update_mode;
      END IF;
      --
      per_asg_shd.lck
      (p_effective_date        => p_effective_date
      ,p_datetrack_mode        => l_asg_datetrack_update_mode
      ,p_assignment_id         => p_assignment_id
      ,p_object_version_number => p_asg_object_version_number
      ,p_validation_start_date => p_asg_validation_start_date
      ,p_validation_end_date   => p_asg_validation_end_date
      );
  ELSE
    p_asg_validation_start_date:=p_effective_date;
    p_asg_validation_end_date:=hr_api.g_eot;
  END IF;
  --
  IF p_grade_rule_id is not null
  AND p_rate_object_version_number is not null THEN
    hr_utility.set_location(l_proc, 25);
      IF p_rate_effective_start_date=p_effective_date THEN
        l_rate_datetrack_update_mode:='CORRECTION';
      ELSE
        l_rate_datetrack_update_mode:=p_datetrack_update_mode;
      END IF;
    --
    pay_pgr_shd.lck
    (p_effective_date            => p_effective_date
    ,p_datetrack_mode            => l_rate_datetrack_update_mode
    ,p_grade_rule_id             => p_grade_rule_id
    ,p_object_version_number     => p_rate_object_version_number
    ,p_validation_start_date     => l_rate_validation_start_date
    ,p_validation_end_date       => l_rate_validation_end_date
    );
  END IF;
  --
  IF p_application_id IS NOT NULL THEN
    hr_utility.set_location(l_proc, 30);
    --
    per_apl_shd.lck
    (p_application_id => p_application_id
    ,p_object_version_number => p_app_object_version_number);
  END IF;
  --
  IF p_address_id IS NOT NULL THEN
    hr_utility.set_location(l_proc, 40);
    --
     per_add_shd.lck
    (p_address_id            => p_address_id
    ,p_object_version_number => p_addr_object_version_number);
  END IF;
  --
  IF p_phn_h_phone_id IS NOT NULL THEN
    hr_utility.set_location(l_proc, 50);
    --
    per_phn_shd.lck
    (p_phone_id              => p_phn_h_phone_id
    ,p_object_version_number => p_phn_h_object_version_number);
  END IF;
  --
  IF p_phn_w_phone_id IS NOT NULL THEN
    hr_utility.set_location(l_proc, 60);
    --
    per_phn_shd.lck
    (p_phone_id              => p_phn_w_phone_id
    ,p_object_version_number => p_phn_w_object_version_number);
  END IF;
  --
  IF p_phn_m_phone_id IS NOT NULL THEN
    hr_utility.set_location(l_proc, 70);
    --
    per_phn_shd.lck
    (p_phone_id              => p_phn_m_phone_id
    ,p_object_version_number => p_phn_m_object_version_number);
  END IF;
  --
  IF p_phn_hf_phone_id IS NOT NULL THEN
    hr_utility.set_location(l_proc, 80);
    --
    per_phn_shd.lck
    (p_phone_id              => p_phn_hf_phone_id
    ,p_object_version_number => p_phn_hf_object_version_number);
  END IF;
  --
  IF p_phn_wf_phone_id IS NOT NULL THEN
    hr_utility.set_location(l_proc, 90);
    --
    per_phn_shd.lck
    (p_phone_id              => p_phn_wf_phone_id
    ,p_object_version_number => p_phn_wf_object_version_number);
  END IF;
  --
  IF p_pay_proposal_id IS NOT NULL THEN
    hr_utility.set_location(l_proc, 100);
    --
    per_pyp_shd.lck
    (p_pay_proposal_id       => p_pay_proposal_id
    ,p_object_version_number => p_pyp_object_version_number);
  END IF;
  --
  IF p_deployment_factor_id IS NOT NULL THEN
    hr_utility.set_location(l_proc, 110);
    --
    per_dpf_shd.lck
    (p_deployment_factor_id  => p_deployment_factor_id
    ,p_object_version_number => p_dpf_object_version_number);
  END IF;
  --
  IF p_chk1_checklist_item_id IS NOT NULL THEN
    hr_utility.set_location(l_proc, 120);
    --
    per_chk_shd.lck
    (p_checklist_item_id     => p_chk1_checklist_item_id
    ,p_object_version_number => p_chk1_object_version_number);
  END IF;
  --
  IF p_chk2_checklist_item_id IS NOT NULL THEN
    hr_utility.set_location(l_proc, 130);
    --
    per_chk_shd.lck
    (p_checklist_item_id     => p_chk2_checklist_item_id
    ,p_object_version_number => p_chk2_object_version_number);
  END IF;
  --
  IF p_chk3_checklist_item_id IS NOT NULL THEN
    hr_utility.set_location(l_proc, 140);
    --
    per_chk_shd.lck
    (p_checklist_item_id     => p_chk3_checklist_item_id
    ,p_object_version_number => p_chk3_object_version_number);
  END IF;
  --
  IF p_chk4_checklist_item_id IS NOT NULL THEN
    hr_utility.set_location(l_proc, 150);
    --
    per_chk_shd.lck
    (p_checklist_item_id     => p_chk4_checklist_item_id
    ,p_object_version_number => p_chk4_object_version_number);
  END IF;
  --
  IF p_chk5_checklist_item_id IS NOT NULL THEN
    hr_utility.set_location(l_proc, 160);
    --
    per_chk_shd.lck
    (p_checklist_item_id     => p_chk5_checklist_item_id
    ,p_object_version_number => p_chk5_object_version_number);
  END IF;
  --
  IF p_chk6_checklist_item_id IS NOT NULL THEN
    hr_utility.set_location(l_proc, 170);
    --
    per_chk_shd.lck
    (p_checklist_item_id     => p_chk6_checklist_item_id
    ,p_object_version_number => p_chk6_object_version_number);
  END IF;
  --
  IF p_chk7_checklist_item_id IS NOT NULL THEN
    hr_utility.set_location(l_proc, 180);
    --
    per_chk_shd.lck
    (p_checklist_item_id     => p_chk7_checklist_item_id
    ,p_object_version_number => p_chk7_object_version_number);
  END IF;
  --
  IF p_chk8_checklist_item_id IS NOT NULL THEN
    hr_utility.set_location(l_proc, 190);
    --
    per_chk_shd.lck
    (p_checklist_item_id     => p_chk8_checklist_item_id
    ,p_object_version_number => p_chk8_object_version_number);
  END IF;
  --
  IF p_chk9_checklist_item_id IS NOT NULL THEN
    hr_utility.set_location(l_proc, 200);
    --
    per_chk_shd.lck
    (p_checklist_item_id     => p_chk9_checklist_item_id
    ,p_object_version_number => p_chk9_object_version_number);
  END IF;
  --
  IF p_chk10_checklist_item_id IS NOT NULL THEN
    hr_utility.set_location(l_proc, 210);
    --
    per_chk_shd.lck
    (p_checklist_item_id     => p_chk10_checklist_item_id
    ,p_object_version_number => p_chk10_object_version_number);
  END IF;
  --
  hr_utility.set_location('Leaving: '||l_proc, 220);
  --
--Bugfix # 3888928 starts here
EXCEPTION
  when app_exception.application_exception then
    hr_message.provide_error;
    if hr_message.last_message_app in ('PER','PAY') then
      if hr_message.last_message_name='HR_7155_OBJECT_INVALID' then
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        fnd_message.raise_error;
      end if;
    end if;

    -- Re-raise the current exception as we do not
    -- want to handle any other Application error.
    raise;
  when others then
    raise;
--Bugfix# 3888928 Ends here
END lock_maintain_data;
--
END;

/
