--------------------------------------------------------
--  DDL for Package PQP_HROSS_INTEGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_HROSS_INTEGRATION" AUTHID CURRENT_USER As
/* $Header: pqphrossintg.pkh 120.0 2005/05/29 02:21:25 appldev noship $ */

-- =============================================================================
-- ~ Get_Person_Type:
-- =============================================================================
FUNCTION Get_Person_Type
        (p_person_id         IN Number
        ,p_business_group_id IN Number
        ,p_effective_date    IN Date) Return Varchar2;
-- =============================================================================
-- ~ Create_Student_Employee:
-- =============================================================================
PROCEDURE Create_Student_Employee
         (p_last_name                    IN Varchar2
         ,p_middle_name                  IN Varchar2 DEFAULT NULL
         ,p_first_name                   IN Varchar2 DEFAULT NULL
         ,p_suffix                       IN Varchar2 DEFAULT NULL
         ,p_prefix                       IN Varchar2 DEFAULT NULL
         ,p_title                        IN Varchar2 DEFAULT NULL
         ,p_email_address                IN Varchar2 DEFAULT NULL
         ,p_preferred_name               IN Varchar2 DEFAULT NULL
         ,p_dup_person_id                IN Number   DEFAULT NULL
         ,p_dup_party_id                 IN Number   DEFAULT NULL
         ,p_marital_status               IN Varchar2 DEFAULT NULL
         ,p_sex                          IN Varchar2
         ,p_nationality                  IN Varchar2 DEFAULT NULL
         ,p_national_identifier          IN Varchar2 DEFAULT NULL
         ,p_date_of_birth                IN Date     DEFAULT NULL
         ,p_date_of_hire                 IN Date
         ,p_employee_number              IN Varchar2 DEFAULT NULL
         ,p_primary_flag                 IN Varchar2 DEFAULT NULL
         ,p_address_style                IN Varchar2 DEFAULT NULL
         ,p_address_line1                IN Varchar2 DEFAULT NULL
         ,p_address_line2                IN Varchar2 DEFAULT NULL
         ,p_address_line3                IN Varchar2 DEFAULT NULL
         ,p_region1                      IN Varchar2 DEFAULT NULL
         ,p_region2                      IN Varchar2 DEFAULT NULL
         ,p_region3                      IN Varchar2 DEFAULT NULL
         ,p_town_or_city                 IN Varchar2 DEFAULT NULL
         ,p_country                      IN Varchar2 DEFAULT NULL
         ,p_postal_code                  IN Varchar2 DEFAULT NULL
         ,p_telephone_no1                IN Varchar2 DEFAULT NULL
         ,p_telephone_no2                IN Varchar2 DEFAULT NULL
         ,p_telephone_no3                IN Varchar2 DEFAULT NULL
         ,p_address_date_from            IN Date     DEFAULT NULL
         ,p_address_date_to              IN Date     DEFAULT NULL
         ,p_phone_type                   IN Varchar2 DEFAULT NULL
         ,p_phone_number                 IN Varchar2 DEFAULT NULL
         ,p_phone_date_from              IN Date     DEFAULT NULL
         ,p_phone_date_to                IN Date     DEFAULT NULL
         ,p_contact_type                 IN Varchar2 DEFAULT NULL
         ,p_contact_name                 IN Varchar2 DEFAULT NULL
         ,p_primary_contact              IN Varchar2 DEFAULT NULL
         ,p_personal_flag                IN Varchar2 DEFAULT NULL
         ,p_contact_date_from            IN Date     DEFAULT NULL
         ,p_contact_date_to              IN Date     DEFAULT NULL
         ,p_assign_organization          IN Varchar2 DEFAULT NULL
         ,p_job                          IN Number   DEFAULT NULL
         ,p_grade                        IN Number   DEFAULT NULL
         ,p_internal_location            IN Varchar2 DEFAULT NULL
         ,p_assign_group                 IN Varchar2 DEFAULT NULL
         ,p_position                     IN Number   DEFAULT NULL
         ,p_payroll                      IN Number   DEFAULT NULL
         ,p_status                       IN Varchar2 DEFAULT NULL
         ,p_assignment_no                IN Varchar2 DEFAULT NULL
         ,p_assignment_category          IN Varchar2 DEFAULT NULL
         ,p_collective_agreement         IN Varchar2 DEFAULT NULL
         ,p_employee_category            IN Varchar2 DEFAULT NULL
         ,p_user_person_type             IN Number   DEFAULT NULL
         ,p_salary_basis                 IN Number   DEFAULT NULL
         ,p_gre                          IN Varchar2 DEFAULT NULL
         ,p_web_adi_identifier           IN Varchar2 DEFAULT NULL
         ,p_assign_eff_dt_from           IN Date     DEFAULT NULL
         ,p_assign_eff_dt_to             IN Date     DEFAULT NULL
         ,p_per_attribute_category       IN Varchar2 DEFAULT NULL
         ,p_per_attribute1               IN Varchar2 DEFAULT NULL
         ,p_per_attribute2               IN Varchar2 DEFAULT NULL
         ,p_per_attribute3               IN Varchar2 DEFAULT NULL
         ,p_per_attribute4               IN Varchar2 DEFAULT NULL
         ,p_per_attribute5               IN Varchar2 DEFAULT NULL
         ,p_per_attribute6               IN Varchar2 DEFAULT NULL
         ,p_per_attribute7               IN Varchar2 DEFAULT NULL
         ,p_per_attribute8               IN Varchar2 DEFAULT NULL
         ,p_per_attribute9               IN Varchar2 DEFAULT NULL
         ,p_per_attribute10              IN Varchar2 DEFAULT NULL
         ,p_per_attribute11              IN Varchar2 DEFAULT NULL
         ,p_per_attribute12              IN Varchar2 DEFAULT NULL
         ,p_per_attribute13              IN Varchar2 DEFAULT NULL
         ,p_per_attribute14              IN Varchar2 DEFAULT NULL
         ,p_per_attribute15              IN Varchar2 DEFAULT NULL
         ,p_per_attribute16              IN Varchar2 DEFAULT NULL
         ,p_per_attribute17              IN Varchar2 DEFAULT NULL
         ,p_per_attribute18              IN Varchar2 DEFAULT NULL
         ,p_per_attribute19              IN Varchar2 DEFAULT NULL
         ,p_per_attribute20              IN Varchar2 DEFAULT NULL
         ,p_per_attribute21              IN Varchar2 DEFAULT NULL
         ,p_per_attribute22              IN Varchar2 DEFAULT NULL
         ,p_per_attribute23              IN Varchar2 DEFAULT NULL
         ,p_per_attribute24              IN Varchar2 DEFAULT NULL
         ,p_per_attribute25              IN Varchar2 DEFAULT NULL
         ,p_per_attribute26              IN Varchar2 DEFAULT NULL
         ,p_per_attribute27              IN Varchar2 DEFAULT NULL
         ,p_per_attribute28              IN Varchar2 DEFAULT NULL
         ,p_per_attribute29              IN Varchar2 DEFAULT NULL
         ,p_per_attribute30              IN Varchar2 DEFAULT NULL
         ,p_per_information_category     IN Varchar2 DEFAULT NULL
         ,p_per_information1             IN Varchar2 DEFAULT NULL
         ,p_per_information2             IN Varchar2 DEFAULT NULL
         ,p_per_information3             IN Varchar2 DEFAULT NULL
         ,p_per_information4             IN Varchar2 DEFAULT NULL
         ,p_per_information5             IN Varchar2 DEFAULT NULL
         ,p_per_information6             IN Varchar2 DEFAULT NULL
         ,p_per_information7             IN Varchar2 DEFAULT NULL
         ,p_per_information8             IN Varchar2 DEFAULT NULL
         ,p_per_information9             IN Varchar2 DEFAULT NULL
         ,p_per_information10            IN Varchar2 DEFAULT NULL
         ,p_per_information11            IN Varchar2 DEFAULT NULL
         ,p_per_information12            IN Varchar2 DEFAULT NULL
         ,p_per_information13            IN Varchar2 DEFAULT NULL
         ,p_per_information14            IN Varchar2 DEFAULT NULL
         ,p_per_information15            IN Varchar2 DEFAULT NULL
         ,p_per_information16            IN Varchar2 DEFAULT NULL
         ,p_per_information17            IN Varchar2 DEFAULT NULL
         ,p_per_information18            IN Varchar2 DEFAULT NULL
         ,p_per_information19            IN Varchar2 DEFAULT NULL
         ,p_per_information20            IN Varchar2 DEFAULT NULL
         ,p_per_information21            IN Varchar2 DEFAULT NULL
         ,p_per_information22            IN Varchar2 DEFAULT NULL
         ,p_per_information23            IN Varchar2 DEFAULT NULL
         ,p_per_information24            IN Varchar2 DEFAULT NULL
         ,p_per_information25            IN Varchar2 DEFAULT NULL
         ,p_per_information26            IN Varchar2 DEFAULT NULL
         ,p_per_information27            IN Varchar2 DEFAULT NULL
         ,p_per_information28            IN Varchar2 DEFAULT NULL
         ,p_per_information29            IN Varchar2 DEFAULT NULL
         ,p_per_information30            IN Varchar2 DEFAULT NULL
         ,p_ass_attribute_category       IN Varchar2 DEFAULT NULL
         ,p_ass_attribute1               IN Varchar2 DEFAULT NULL
         ,p_ass_attribute2               IN Varchar2 DEFAULT NULL
         ,p_ass_attribute3               IN Varchar2 DEFAULT NULL
         ,p_ass_attribute4               IN Varchar2 DEFAULT NULL
         ,p_ass_attribute5               IN Varchar2 DEFAULT NULL
         ,p_ass_attribute6               IN Varchar2 DEFAULT NULL
         ,p_ass_attribute7               IN Varchar2 DEFAULT NULL
         ,p_ass_attribute8               IN Varchar2 DEFAULT NULL
         ,p_ass_attribute9               IN Varchar2 DEFAULT NULL
         ,p_ass_attribute10              IN Varchar2 DEFAULT NULL
         ,p_ass_attribute11              IN Varchar2 DEFAULT NULL
         ,p_ass_attribute12              IN Varchar2 DEFAULT NULL
         ,p_ass_attribute13              IN Varchar2 DEFAULT NULL
         ,p_ass_attribute14              IN Varchar2 DEFAULT NULL
         ,p_ass_attribute15              IN Varchar2 DEFAULT NULL
         ,p_ass_attribute16              IN Varchar2 DEFAULT NULL
         ,p_ass_attribute17              IN Varchar2 DEFAULT NULL
         ,p_ass_attribute18              IN Varchar2 DEFAULT NULL
         ,p_ass_attribute19              IN Varchar2 DEFAULT NULL
         ,p_ass_attribute20              IN Varchar2 DEFAULT NULL
         ,p_ass_attribute21              IN Varchar2 DEFAULT NULL
         ,p_ass_attribute22              IN Varchar2 DEFAULT NULL
         ,p_ass_attribute23              IN Varchar2 DEFAULT NULL
         ,p_ass_attribute24              IN Varchar2 DEFAULT NULL
         ,p_ass_attribute25              IN Varchar2 DEFAULT NULL
         ,p_ass_attribute26              IN Varchar2 DEFAULT NULL
         ,p_ass_attribute27              IN Varchar2 DEFAULT NULL
         ,p_ass_attribute28              IN Varchar2 DEFAULT NULL
         ,p_ass_attribute29              IN Varchar2 DEFAULT NULL
         ,p_ass_attribute30              IN Varchar2 DEFAULT NULL
         ,p_adr_attribute_category       IN Varchar2 DEFAULT NULL
         ,p_adr_attribute1               IN Varchar2 DEFAULT NULL
         ,p_adr_attribute2               IN Varchar2 DEFAULT NULL
         ,p_adr_attribute3               IN Varchar2 DEFAULT NULL
         ,p_adr_attribute4               IN Varchar2 DEFAULT NULL
         ,p_adr_attribute5               IN Varchar2 DEFAULT NULL
         ,p_adr_attribute6               IN Varchar2 DEFAULT NULL
         ,p_adr_attribute7               IN Varchar2 DEFAULT NULL
         ,p_adr_attribute8               IN Varchar2 DEFAULT NULL
         ,p_adr_attribute9               IN Varchar2 DEFAULT NULL
         ,p_adr_attribute10              IN Varchar2 DEFAULT NULL
         ,p_adr_attribute11              IN Varchar2 DEFAULT NULL
         ,p_adr_attribute12              IN Varchar2 DEFAULT NULL
         ,p_adr_attribute13              IN Varchar2 DEFAULT NULL
         ,p_adr_attribute14              IN Varchar2 DEFAULT NULL
         ,p_adr_attribute15              IN Varchar2 DEFAULT NULL
         ,p_adr_attribute16              IN Varchar2 DEFAULT NULL
         ,p_adr_attribute17              IN Varchar2 DEFAULT NULL
         ,p_adr_attribute18              IN Varchar2 DEFAULT NULL
         ,p_adr_attribute19              IN Varchar2 DEFAULT NULL
         ,p_adr_attribute20              IN Varchar2 DEFAULT NULL
         ,p_business_group_id            IN Number   DEFAULT NULL
         ,p_data_pump_flag               IN Varchar2 DEFAULT NULL
         ,p_add_information13            IN Varchar2 DEFAULT NULL
         ,p_add_information14            IN Varchar2 DEFAULT NULL
         ,p_add_information15            IN Varchar2 DEFAULT NULL
         ,p_add_information16            IN Varchar2 DEFAULT NULL
         ,p_add_information17            IN Varchar2 DEFAULT NULL
         ,p_add_information18            IN Varchar2 DEFAULT NULL
         ,p_add_information19            IN Varchar2 DEFAULT NULL
         ,p_add_information20            IN Varchar2 DEFAULT NULL
         ,p_concat_segments              IN Varchar2 DEFAULT NULL
         ,p_people_segment1              IN Varchar2 DEFAULT NULL
         ,p_people_segment2              IN Varchar2 DEFAULT NULL
         ,p_people_segment3              IN Varchar2 DEFAULT NULL
         ,p_people_segment4              IN Varchar2 DEFAULT NULL
         ,p_people_segment5              IN Varchar2 DEFAULT NULL
         ,p_people_segment6              IN Varchar2 DEFAULT NULL
         ,p_people_segment7              IN Varchar2 DEFAULT NULL
         ,p_people_segment8              IN Varchar2 DEFAULT NULL
         ,p_people_segment9              IN Varchar2 DEFAULT NULL
         ,p_people_segment10             IN Varchar2 DEFAULT NULL
         ,p_people_segment11             IN Varchar2 DEFAULT NULL
         ,p_people_segment12             IN Varchar2 DEFAULT NULL
         ,p_people_segment13             IN Varchar2 DEFAULT NULL
         ,p_people_segment14             IN Varchar2 DEFAULT NULL
         ,p_people_segment15             IN Varchar2 DEFAULT NULL
         ,p_people_segment16             IN Varchar2 DEFAULT NULL
         ,p_people_segment17             IN Varchar2 DEFAULT NULL
         ,p_people_segment18             IN Varchar2 DEFAULT NULL
         ,p_people_segment19             IN Varchar2 DEFAULT NULL
         ,p_people_segment20             IN Varchar2 DEFAULT NULL
         ,p_people_segment21             IN Varchar2 DEFAULT NULL
         ,p_people_segment22             IN Varchar2 DEFAULT NULL
         ,p_people_segment23             IN Varchar2 DEFAULT NULL
         ,p_people_segment24             IN Varchar2 DEFAULT NULL
         ,p_people_segment25             IN Varchar2 DEFAULT NULL
         ,p_people_segment26             IN Varchar2 DEFAULT NULL
         ,p_people_segment27             IN Varchar2 DEFAULT NULL
         ,p_people_segment28             IN Varchar2 DEFAULT NULL
         ,p_people_segment29             IN Varchar2 DEFAULT NULL
         ,p_people_segment30             IN Varchar2 DEFAULT NULL
         ,p_soft_segments                IN Varchar2 DEFAULT NULL
         ,p_soft_segment1                IN Varchar2 DEFAULT NULL
         ,p_soft_segment2                IN Varchar2 DEFAULT NULL
         ,p_soft_segment3                IN Varchar2 DEFAULT NULL
         ,p_soft_segment4                IN Varchar2 DEFAULT NULL
         ,p_soft_segment5                IN Varchar2 DEFAULT NULL
         ,p_soft_segment6                IN Varchar2 DEFAULT NULL
         ,p_soft_segment7                IN Varchar2 DEFAULT NULL
         ,p_soft_segment8                IN Varchar2 DEFAULT NULL
         ,p_soft_segment9                IN Varchar2 DEFAULT NULL
         ,p_soft_segment10               IN Varchar2 DEFAULT NULL
         ,p_soft_segment11               IN Varchar2 DEFAULT NULL
         ,p_soft_segment12               IN Varchar2 DEFAULT NULL
         ,p_soft_segment13               IN Varchar2 DEFAULT NULL
         ,p_soft_segment14               IN Varchar2 DEFAULT NULL
         ,p_soft_segment15               IN Varchar2 DEFAULT NULL
         ,p_soft_segment16               IN Varchar2 DEFAULT NULL
         ,p_soft_segment17               IN Varchar2 DEFAULT NULL
         ,p_soft_segment18               IN Varchar2 DEFAULT NULL
         ,p_soft_segment19               IN Varchar2 DEFAULT NULL
         ,p_soft_segment20               IN Varchar2 DEFAULT NULL
         ,p_soft_segment21               IN Varchar2 DEFAULT NULL
         ,p_soft_segment22               IN Varchar2 DEFAULT NULL
         ,p_soft_segment23               IN Varchar2 DEFAULT NULL
         ,p_soft_segment24               IN Varchar2 DEFAULT NULL
         ,p_soft_segment25               IN Varchar2 DEFAULT NULL
         ,p_soft_segment26               IN Varchar2 DEFAULT NULL
         ,p_soft_segment27               IN Varchar2 DEFAULT NULL
         ,p_soft_segment28               IN Varchar2 DEFAULT NULL
         ,p_soft_segment29               IN Varchar2 DEFAULT NULL
         ,p_soft_segment30               IN Varchar2 DEFAULT NULL
         ,p_business_group_name          IN Varchar2 DEFAULT NULL
         ,p_batch_id                     IN Number   DEFAULT NULL
         ,p_data_pump_batch_line_id      IN Varchar2 DEFAULT NULL
         ,p_per_comments                 IN Varchar2 DEFAULT NULL
         ,p_date_employee_data_verified  IN Date     DEFAULT NULL
         ,p_expense_check_send_to_addres IN Varchar2 DEFAULT NULL
         ,p_previous_last_name           IN Varchar2 DEFAULT NULL
         ,p_registered_disabled_flag     IN Varchar2 DEFAULT NULL
         ,p_vendor_id                    IN Number   DEFAULT NULL
         ,p_date_of_death                IN Date     DEFAULT NULL
         ,p_background_check_status      IN Varchar2 DEFAULT NULL
         ,p_background_date_check        IN Date     DEFAULT NULL
         ,p_blood_type                   IN Varchar2 DEFAULT NULL
         ,p_correspondence_language      IN Varchar2 DEFAULT NULL
         ,p_fast_path_employee           IN Varchar2 DEFAULT NULL
         ,p_fte_capacity                 IN Number   DEFAULT NULL
         ,p_honors                       IN Varchar2 DEFAULT NULL
         ,p_last_medical_test_by         IN Varchar2 DEFAULT NULL
         ,p_last_medical_test_date       IN Date     DEFAULT NULL
         ,p_mailstop                     IN Varchar2 DEFAULT NULL
         ,p_office_number                IN Varchar2 DEFAULT NULL
         ,p_on_military_service          IN Varchar2 DEFAULT NULL
         ,p_pre_name_adjunct             IN Varchar2 DEFAULT NULL
         ,p_projected_start_date         IN Date     DEFAULT NULL
         ,p_resume_exists                IN Varchar2 DEFAULT NULL
         ,p_resume_last_updated          IN Date     DEFAULT NULL
         ,p_second_passport_exists       IN Varchar2 DEFAULT NULL
         ,p_student_status               IN Varchar2 DEFAULT NULL
         ,p_work_schedule                IN Varchar2 DEFAULT NULL
         ,p_benefit_group_id             IN Number   DEFAULT NULL
         ,p_receipt_of_death_cert_date   IN Date     DEFAULT NULL
         ,p_coord_ben_med_pln_no         IN Varchar2 DEFAULT NULL
         ,p_coord_ben_no_cvg_flag        IN Varchar2 DEFAULT  'N'
         ,p_coord_ben_med_ext_er         IN Varchar2 DEFAULT NULL
         ,p_coord_ben_med_pl_name        IN Varchar2 DEFAULT NULL
         ,p_coord_ben_med_insr_crr_name  IN Varchar2 DEFAULT NULL
         ,p_coord_ben_med_insr_crr_ident IN Varchar2 DEFAULT NULL
         ,p_coord_ben_med_cvg_strt_dt    IN Date     DEFAULT NULL
         ,p_coord_ben_med_cvg_end_dt     IN Date     DEFAULT NULL
         ,p_uses_tobacco_flag            IN Varchar2 DEFAULT NULL
         ,p_dpdnt_adoption_date          IN Date     DEFAULT NULL
         ,p_dpdnt_vlntry_svce_flag       IN Varchar2 DEFAULT  'N'
         ,p_original_date_of_hire        IN Date     DEFAULT NULL
         ,p_adjusted_svc_date            IN Date     DEFAULT NULL
         ,p_town_of_birth                IN Varchar2 DEFAULT NULL
         ,p_region_of_birth              IN Varchar2 DEFAULT NULL
         ,p_country_of_birth             IN Varchar2 DEFAULT NULL
         ,p_global_person_id             IN Varchar2 DEFAULT NULL
         ,p_party_id                     IN Number   DEFAULT NULL
         ,p_supervisor_id                IN Number   DEFAULT NULL
         ,p_assignment_number            IN Varchar2 DEFAULT NULL
         ,p_change_reason                IN Varchar2 DEFAULT NULL
         ,p_asg_comments                 IN Varchar2 DEFAULT NULL
         ,p_date_probation_end           IN Date     DEFAULT NULL
         ,p_default_code_comb_id         IN Number   DEFAULT NULL
         ,p_frequency                    IN Varchar2 DEFAULT NULL
         ,p_internal_address_line        IN Varchar2 DEFAULT NULL
         ,p_manager_flag                 IN Varchar2 DEFAULT NULL
         ,p_normal_hours                 IN Number   DEFAULT NULL
         ,p_perf_review_period           IN Number   DEFAULT NULL
         ,p_perf_review_period_frequency IN Varchar2 DEFAULT NULL
         ,p_probation_period             IN Number   DEFAULT NULL
         ,p_probation_unit               IN Varchar2 DEFAULT NULL
         ,p_sal_review_period            IN Number   DEFAULT NULL
         ,p_sal_review_period_frequency  IN Varchar2 DEFAULT NULL
         ,p_set_of_books_id              IN Number   DEFAULT NULL
         ,p_source_type                  IN Varchar2 DEFAULT NULL
         ,p_time_normal_finish           IN Varchar2 DEFAULT NULL
         ,p_time_normal_start            IN Varchar2 DEFAULT NULL
         ,p_bargaining_unit_code         IN Varchar2 DEFAULT NULL
         ,p_labour_union_member_flag     IN Varchar2 DEFAULT NULL
         ,p_hourly_salaried_code         IN Varchar2 DEFAULT NULL
         ,p_pradd_ovlapval_override      IN Varchar2 DEFAULT NULL
         ,p_address_type                 IN Varchar2 DEFAULT NULL
         ,p_adr_comments                 IN Varchar2 DEFAULT NULL
         ,p_batch_name                   IN Varchar2 DEFAULT NULL
         ,p_location_id                  IN Number   DEFAULT NULL
         ,p_student_number               IN Varchar2 DEFAULT NULL
          );

-- =============================================================================
-- ~ Create_BatchHdr_For_DataPump:
-- =============================================================================
PROCEDURE Create_BatchHdr_For_DataPump
         (p_batch_process_name           OUT NOCOPY Varchar2
         ,p_batch_process_id             OUT NOCOPY Number);

-- =============================================================================
-- ~ Create_OSS_Person:
-- =============================================================================
PROCEDURE Create_OSS_Person
         (p_business_group_id            IN Number
         ,p_dup_person_id                IN Number
         ,p_effective_date               IN Date
         -- Person Details: Per_All_People_F
         ,p_party_id                     IN Number   DEFAULT NULL
         ,p_last_name                    IN Varchar2
         ,p_middle_name                  IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_first_name                   IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_suffix                       IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_prefix                       IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_title                        IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_email_address                IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_preferred_name               IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_marital_status               IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_sex                          IN Varchar2
         ,p_nationality                  IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_national_identifier          IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_date_of_birth                IN Date     DEFAULT Hr_Api.g_date
         ,p_date_of_hire                 IN Date
         ,p_employee_number              IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_person_type_id               IN Number
         ,p_date_employee_data_verified  IN Date     DEFAULT Hr_Api.g_date
         ,p_expense_check_send_to_addres IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_previous_last_name           IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_registered_disabled_flag     IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_vendor_id                    IN Number   DEFAULT NULL
         ,p_date_of_death                IN Date     DEFAULT Hr_Api.g_date
         ,p_background_check_status      IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_background_date_check        IN Date     DEFAULT Hr_Api.g_date
         ,p_blood_type                   IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_correspondence_language      IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_fast_path_employee           IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_fte_capacity                 IN Number   DEFAULT NULL
         ,p_honors                       IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_last_medical_test_by         IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_last_medical_test_date       IN Date     DEFAULT Hr_Api.g_date
         ,p_mailstop                     IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_office_number                IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_on_military_service          IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_pre_name_adjunct             IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_projected_start_date         IN Date     DEFAULT Hr_Api.g_date
         ,p_resume_exists                IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_resume_last_updated          IN Date     DEFAULT Hr_Api.g_date
         ,p_second_passport_exists       IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_student_status               IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_work_schedule                IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_benefit_group_id             IN Number   DEFAULT NULL
         ,p_receipt_of_death_cert_date   IN Date     DEFAULT Hr_Api.g_date
         ,p_coord_ben_med_pln_no         IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_coord_ben_no_cvg_flag        IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_coord_ben_med_ext_er         IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_coord_ben_med_pl_name        IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_coord_ben_med_insr_crr_name  IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_coord_ben_med_insr_crr_ident IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_coord_ben_med_cvg_strt_dt    IN Date     DEFAULT Hr_Api.g_date
         ,p_coord_ben_med_cvg_end_dt     IN Date     DEFAULT Hr_Api.g_date
         ,p_uses_tobacco_flag            IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_dpdnt_adoption_date          IN Date     DEFAULT Hr_Api.g_date
         ,p_dpdnt_vlntry_svce_flag       IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_original_date_of_hire        IN Date     DEFAULT Hr_Api.g_date
         ,p_adjusted_svc_date            IN Date     DEFAULT Hr_Api.g_date
         ,p_town_of_birth                IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_region_of_birth              IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_country_of_birth             IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_global_person_id             IN Varchar2 DEFAULT Hr_Api.g_varchar2
         -- Person DF
         ,p_per_attribute_category       IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_per_attribute1               IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_per_attribute2               IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_per_attribute3               IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_per_attribute4               IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_per_attribute5               IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_per_attribute6               IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_per_attribute7               IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_per_attribute8               IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_per_attribute9               IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_per_attribute10              IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_per_attribute11              IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_per_attribute12              IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_per_attribute13              IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_per_attribute14              IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_per_attribute15              IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_per_attribute16              IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_per_attribute17              IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_per_attribute18              IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_per_attribute19              IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_per_attribute20              IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_per_attribute21              IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_per_attribute22              IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_per_attribute23              IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_per_attribute24              IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_per_attribute25              IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_per_attribute26              IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_per_attribute27              IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_per_attribute28              IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_per_attribute29              IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_per_attribute30              IN Varchar2 DEFAULT Hr_Api.g_varchar2
         -- Person DDF
         ,p_per_information_category     IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_per_information1             IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_per_information2             IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_per_information3             IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_per_information4             IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_per_information5             IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_per_information6             IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_per_information7             IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_per_information8             IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_per_information9             IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_per_information10            IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_per_information11            IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_per_information12            IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_per_information13            IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_per_information14            IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_per_information15            IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_per_information16            IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_per_information17            IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_per_information18            IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_per_information19            IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_per_information20            IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_per_information21            IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_per_information22            IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_per_information23            IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_per_information24            IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_per_information25            IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_per_information26            IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_per_information27            IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_per_information28            IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_per_information29            IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_per_information30            IN Varchar2 DEFAULT Hr_Api.g_varchar2
         -- Primary Address: Per_Addresses
         ,p_pradd_ovlapval_override      IN Varchar2 DEFAULT NULL
         ,p_address_type                 IN Varchar2 DEFAULT NULL
         ,p_adr_comments                 IN Varchar2 DEFAULT NULL
         ,p_primary_flag                 IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_address_style                IN Varchar2 DEFAULT NULL
         ,p_address_line1                IN Varchar2 DEFAULT NULL
         ,p_address_line2                IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_address_line3                IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_region1                      IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_region2                      IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_region3                      IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_town_or_city                 IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_country                      IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_postal_code                  IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_telephone_no1                IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_telephone_no2                IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_telephone_no3                IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_address_date_from            IN Date     DEFAULT Hr_Api.g_date
         ,p_address_date_to              IN Date     DEFAULT Hr_Api.g_date
         ,p_adr_attribute_category       IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_adr_attribute1               IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_adr_attribute2               IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_adr_attribute3               IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_adr_attribute4               IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_adr_attribute5               IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_adr_attribute6               IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_adr_attribute7               IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_adr_attribute8               IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_adr_attribute9               IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_adr_attribute10              IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_adr_attribute11              IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_adr_attribute12              IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_adr_attribute13              IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_adr_attribute14              IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_adr_attribute15              IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_adr_attribute16              IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_adr_attribute17              IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_adr_attribute18              IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_adr_attribute19              IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_adr_attribute20              IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_add_information13            IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_add_information14            IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_add_information15            IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_add_information16            IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_add_information17            IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_add_information18            IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_add_information19            IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_add_information20            IN Varchar2 DEFAULT Hr_Api.g_varchar2
         -- Person Phones: Per_Phones
         ,p_phone_type                   IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_phone_number                 IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_phone_date_from              IN Date     DEFAULT Hr_Api.g_date
         ,p_phone_date_to                IN Date     DEFAULT Hr_Api.g_date
         -- Person Contact: Per_Contact_Relationships
         ,p_contact_type                 IN Varchar2 DEFAULT NULL
         ,p_contact_name                 IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_primary_contact              IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_primary_relationship         IN Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_contact_date_from            IN Date     DEFAULT Hr_Api.g_date
         ,p_contact_date_to              IN Date     DEFAULT Hr_Api.g_date
         ,p_return_status                OUT NOCOPY Varchar2
         ,p_dup_asg_id                   IN Number   DEFAULT NULL
         ,p_mode_type                    IN Varchar2 DEFAULT NULL
         );
-- =============================================================================
-- ~ Upd_OSS_Person_Asg:
-- =============================================================================
PROCEDURE Upd_OSS_Person_Asg
         (p_effective_date               IN     Date
         ,p_datetrack_update_mode        IN     Varchar2 DEFAULT NULL
         ,p_assignment_id                IN     Number
         ,p_party_id                     IN     Number
         ,p_business_group_id            IN     Number
         ,p_validate                     IN     Boolean  DEFAULT FALSE
         ,p_called_from_mass_update      IN     Boolean  DEFAULT FALSE
         --
         ,p_grade_id                     IN     Number   DEFAULT Hr_Api.g_number
         ,p_position_id                  IN     Number   DEFAULT Hr_Api.g_number
         ,p_job_id                       IN     Number   DEFAULT Hr_Api.g_number
         ,p_payroll_id                   IN     Number   DEFAULT Hr_Api.g_number
         ,p_location_id                  IN     Number   DEFAULT Hr_Api.g_number
         ,p_organization_id              IN     Number   DEFAULT Hr_Api.g_number
         ,p_pay_basis_id                 IN     Number   DEFAULT Hr_Api.g_number
         ,p_employment_category          IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_assignment_category          IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         --
         ,p_supervisor_id                IN     Number   DEFAULT Hr_Api.g_number
         ,p_assignment_number            IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_change_reason                IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_assignment_status_type_id    IN     Number   DEFAULT Hr_Api.g_number
         ,p_comments                     IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_date_probation_end           IN     Date     DEFAULT Hr_Api.g_date
         ,p_default_code_comb_id         IN     Number   DEFAULT Hr_Api.g_number
         ,p_frequency                    IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_internal_address_line        IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_manager_flag                 IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_normal_hours                 IN     Number   DEFAULT Hr_Api.g_number
         ,p_perf_review_period           IN     Number   DEFAULT Hr_Api.g_number
         ,p_perf_review_period_frequency IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_probation_period             IN     Number   DEFAULT Hr_Api.g_number
         ,p_probation_unit               IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_sal_review_period            IN     Number   DEFAULT Hr_Api.g_number
         ,p_sal_review_period_frequency  IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_set_of_books_id              IN     Number   DEFAULT Hr_Api.g_number
         ,p_source_type                  IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_time_normal_finish           IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_time_normal_start            IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_bargaining_unit_code         IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_labour_union_member_flag     IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_hourly_salaried_code         IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_title                        IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_notice_period                IN     Number   DEFAULT Hr_Api.g_number
         ,p_notice_period_uom            IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_employee_category            IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_work_at_home                 IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_job_post_source_name         IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_supervisor_assignment_id     IN     Number   DEFAULT Hr_Api.g_number
         --People Group Keyflex Field
         ,p_people_group_id              IN     Number   DEFAULT Hr_Api.g_number
         ,p_pgrp_segment1                IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_pgrp_segment2                IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_pgrp_segment3                IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_pgrp_segment4                IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_pgrp_segment5                IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_pgrp_segment6                IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_pgrp_segment7                IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_pgrp_segment8                IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_pgrp_segment9                IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_pgrp_segment10               IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_pgrp_segment11               IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_pgrp_segment12               IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_pgrp_segment13               IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_pgrp_segment14               IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_pgrp_segment15               IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_pgrp_segment16               IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_pgrp_segment17               IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_pgrp_segment18               IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_pgrp_segment19               IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_pgrp_segment20               IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_pgrp_segment21               IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_pgrp_segment22               IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_pgrp_segment23               IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_pgrp_segment24               IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_pgrp_segment25               IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_pgrp_segment26               IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_pgrp_segment27               IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_pgrp_segment28               IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_pgrp_segment29               IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_pgrp_segment30               IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_pgrp_concat_segments         IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         --Soft Coding KeyflexId
         ,p_soft_coding_keyflex_id       IN     Number   DEFAULT Hr_Api.g_number
         ,p_soft_concat_segments         IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_scl_segment1                 IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_scl_segment2                 IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_scl_segment3                 IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_scl_segment4                 IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_scl_segment5                 IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_scl_segment6                 IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_scl_segment7                 IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_scl_segment8                 IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_scl_segment9                 IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_scl_segment10                IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_scl_segment11                IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_scl_segment12                IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_scl_segment13                IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_scl_segment14                IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_scl_segment15                IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_scl_segment16                IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_scl_segment17                IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_scl_segment18                IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_scl_segment19                IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_scl_segment20                IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_scl_segment21                IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_scl_segment22                IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_scl_segment23                IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_scl_segment24                IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_scl_segment25                IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_scl_segment26                IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_scl_segment27                IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_scl_segment28                IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_scl_segment29                IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_scl_segment30                IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         -- Assignment DF Information
         ,p_ass_attribute_category       IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_ass_attribute1               IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_ass_attribute2               IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_ass_attribute3               IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_ass_attribute4               IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_ass_attribute5               IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_ass_attribute6               IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_ass_attribute7               IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_ass_attribute8               IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_ass_attribute9               IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_ass_attribute10              IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_ass_attribute11              IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_ass_attribute12              IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_ass_attribute13              IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_ass_attribute14              IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_ass_attribute15              IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_ass_attribute16              IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_ass_attribute17              IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_ass_attribute18              IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_ass_attribute19              IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_ass_attribute20              IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_ass_attribute21              IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_ass_attribute22              IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_ass_attribute23              IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_ass_attribute24              IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_ass_attribute25              IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_ass_attribute26              IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_ass_attribute27              IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_ass_attribute28              IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_ass_attribute29              IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_ass_attribute30              IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         --
         ,p_grade_ladder_pgm_id          IN     Number   DEFAULT Hr_Api.g_number
         ,p_special_ceiling_step_id      IN     Number   DEFAULT Hr_Api.g_number
         ,p_cagr_grade_def_id            IN     Number   DEFAULT Hr_Api.g_number
         ,p_contract_id                  IN     Number   DEFAULT Hr_Api.g_number
         ,p_establishment_id             IN     Number   DEFAULT Hr_Api.g_number
         ,p_collective_agreement_id      IN     Number   DEFAULT Hr_Api.g_number
         ,p_cagr_id_flex_num             IN     Number   DEFAULT Hr_Api.g_number
         ,p_cag_segment1                 IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_cag_segment2                 IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_cag_segment3                 IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_cag_segment4                 IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_cag_segment5                 IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_cag_segment6                 IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_cag_segment7                 IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_cag_segment8                 IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_cag_segment9                 IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_cag_segment10                IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_cag_segment11                IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_cag_segment12                IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_cag_segment13                IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_cag_segment14                IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_cag_segment15                IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_cag_segment16                IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_cag_segment17                IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_cag_segment18                IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_cag_segment19                IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_cag_segment20                IN     Varchar2 DEFAULT Hr_Api.g_varchar2
         ,p_return_status                OUT NOCOPY Varchar2
         ,p_FICA_exempt                  IN     Varchar2 DEFAULT Null
         );
-- =============================================================================
-- ~ FICA_Status: Function to return the FICA status of an employee assignment.
-- ~ This only appicable for US legislation
-- =============================================================================
FUNCTION FICA_Status
         (p_assignment_id     IN Number
         ,p_effective_date    IN Date
          ) RETURN Varchar2;
END Pqp_Hross_Integration;

 

/
