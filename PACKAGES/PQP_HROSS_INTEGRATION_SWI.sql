--------------------------------------------------------
--  DDL for Package PQP_HROSS_INTEGRATION_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_HROSS_INTEGRATION_SWI" AUTHID CURRENT_USER As
/* $Header: pqphrossintgswi.pkh 120.0 2005/05/29 02:24:01 appldev noship $ */
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
         ,p_middle_name                  IN Varchar2 DEFAULT NULL
         ,p_first_name                   IN Varchar2 DEFAULT NULL
         ,p_suffix                       IN Varchar2 DEFAULT NULL
         ,p_prefix                       IN Varchar2 DEFAULT NULL
         ,p_title                        IN Varchar2 DEFAULT NULL
         ,p_email_address                IN Varchar2 DEFAULT NULL
         ,p_preferred_name               IN Varchar2 DEFAULT NULL
         ,p_marital_status               IN Varchar2 DEFAULT NULL
         ,p_sex                          IN Varchar2
         ,p_nationality                  IN Varchar2 DEFAULT NULL
         ,p_national_identifier          IN Varchar2 DEFAULT NULL
         ,p_date_of_birth                IN Date     DEFAULT NULL
         ,p_date_of_hire                 IN Date
         ,p_employee_number              IN Varchar2 DEFAULT NULL
         ,p_person_type_id               IN Number
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
         ,p_coord_ben_no_cvg_flag        IN Varchar2 DEFAULT NULL
         ,p_coord_ben_med_ext_er         IN Varchar2 DEFAULT NULL
         ,p_coord_ben_med_pl_name        IN Varchar2 DEFAULT NULL
         ,p_coord_ben_med_insr_crr_name  IN Varchar2 DEFAULT NULL
         ,p_coord_ben_med_insr_crr_ident IN Varchar2 DEFAULT NULL
         ,p_coord_ben_med_cvg_strt_dt    IN Date     DEFAULT NULL
         ,p_coord_ben_med_cvg_end_dt     IN Date     DEFAULT NULL
         ,p_uses_tobacco_flag            IN Varchar2 DEFAULT NULL
         ,p_dpdnt_adoption_date          IN Date     DEFAULT NULL
         ,p_dpdnt_vlntry_svce_flag       IN Varchar2 DEFAULT NULL
         ,p_original_date_of_hire        IN Date     DEFAULT NULL
         ,p_adjusted_svc_date            IN Date     DEFAULT NULL
         ,p_town_of_birth                IN Varchar2 DEFAULT NULL
         ,p_region_of_birth              IN Varchar2 DEFAULT NULL
         ,p_country_of_birth             IN Varchar2 DEFAULT NULL
         ,p_global_person_id             IN Varchar2 DEFAULT NULL
         -- Person DF
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
         -- Person DDF
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
         -- Primary Address: Per_Addresses
         ,p_pradd_ovlapval_override      IN Varchar2 DEFAULT NULL
         ,p_address_type                 IN Varchar2 DEFAULT NULL
         ,p_adr_comments                 IN Varchar2 DEFAULT NULL
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
         ,p_add_information13            IN Varchar2 DEFAULT NULL
         ,p_add_information14            IN Varchar2 DEFAULT NULL
         ,p_add_information15            IN Varchar2 DEFAULT NULL
         ,p_add_information16            IN Varchar2 DEFAULT NULL
         ,p_add_information17            IN Varchar2 DEFAULT NULL
         ,p_add_information18            IN Varchar2 DEFAULT NULL
         ,p_add_information19            IN Varchar2 DEFAULT NULL
         ,p_add_information20            IN Varchar2 DEFAULT NULL
         -- Person Phones: Per_Phones
         ,p_phone_type                   IN Varchar2 DEFAULT NULL
         ,p_phone_number                 IN Varchar2 DEFAULT NULL
         ,p_phone_date_from              IN Date     DEFAULT NULL
         ,p_phone_date_to                IN Date     DEFAULT NULL
         -- Person Contact: Per_Contact_Relationships
         ,p_contact_type                 IN Varchar2 DEFAULT NULL
         ,p_contact_name                 IN Varchar2 DEFAULT NULL
         ,p_primary_contact              IN Varchar2 DEFAULT NULL
         ,p_primary_relationship         IN Varchar2 DEFAULT NULL
         ,p_contact_date_from            IN Date     DEFAULT NULL
         ,p_contact_date_to              IN Date     DEFAULT NULL
         ,p_return_status                OUT NOCOPY Varchar2
         --
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
         -- People Group Keyflex Field
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
         -- Soft Coding KeyflexId
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
-- ~ InsUpd_Assig_Extra_Info:
-- =============================================================================
PROCEDURE InsUpd_Assig_Extra_Info
         (p_validate                      IN   Number   DEFAULT NULL
         ,p_action                        IN   Varchar2
         ,p_business_group_id             IN   Number
         ,p_effective_date                IN   Date
         ,p_assignment_id                 IN   Number
         ,p_assignment_extra_info_id      IN OUT NOCOPY Number
         ,p_object_version_number         IN OUT NOCOPY NUMBER
         ,p_return_status                 OUT NOCOPY Varchar2
         ,p_information_type              IN   VARCHAR2
         -- DDF Segments
         ,p_aei_information_category      IN   Varchar2 DEFAULT NULL
         ,p_aei_information1              IN   Varchar2 DEFAULT NULL
         ,p_aei_information2              IN   Varchar2 DEFAULT NULL
         ,p_aei_information3              IN   Varchar2 DEFAULT NULL
         ,p_aei_information4              IN   Varchar2 DEFAULT NULL
         ,p_aei_information5              IN   Varchar2 DEFAULT NULL
         ,p_aei_information6              IN   Varchar2 DEFAULT NULL
         ,p_aei_information7              IN   Varchar2 DEFAULT NULL
         ,p_aei_information8              IN   Varchar2 DEFAULT NULL
         ,p_aei_information9              IN   Varchar2 DEFAULT NULL
         ,p_aei_information10             IN   Varchar2 DEFAULT NULL
         ,p_aei_information11             IN   Varchar2 DEFAULT NULL
         ,p_aei_information12             IN   Varchar2 DEFAULT NULL
         ,p_aei_information13             IN   Varchar2 DEFAULT NULL
         ,p_aei_information14             IN   Varchar2 DEFAULT NULL
         ,p_aei_information15             IN   Varchar2 DEFAULT NULL
         ,p_aei_information16             IN   Varchar2 DEFAULT NULL
         ,p_aei_information17             IN   Varchar2 DEFAULT NULL
         ,p_aei_information18             IN   Varchar2 DEFAULT NULL
         ,p_aei_information19             IN   Varchar2 DEFAULT NULL
         ,p_aei_information20             IN   Varchar2 DEFAULT NULL
         ,p_aei_information21             IN   Varchar2 DEFAULT NULL
         ,p_aei_information22             IN   Varchar2 DEFAULT NULL
         ,p_aei_information23             IN   Varchar2 DEFAULT NULL
         ,p_aei_information24             IN   Varchar2 DEFAULT NULL
         ,p_aei_information25             IN   Varchar2 DEFAULT NULL
         ,p_aei_information26             IN   Varchar2 DEFAULT NULL
         ,p_aei_information27             IN   Varchar2 DEFAULT NULL
         ,p_aei_information28             IN   Varchar2 DEFAULT NULL
         ,p_aei_information29             IN   Varchar2 DEFAULT NULL
         ,p_aei_information30             IN   Varchar2 DEFAULT NULL
         -- DF Segments
         ,p_aei_attribute_category        IN   Varchar2 DEFAULT NULL
         ,p_aei_attribute1                IN   Varchar2 DEFAULT NULL
         ,p_aei_attribute2                IN   Varchar2 DEFAULT NULL
         ,p_aei_attribute3                IN   Varchar2 DEFAULT NULL
         ,p_aei_attribute4                IN   Varchar2 DEFAULT NULL
         ,p_aei_attribute5                IN   Varchar2 DEFAULT NULL
         ,p_aei_attribute6                IN   Varchar2 DEFAULT NULL
         ,p_aei_attribute7                IN   Varchar2 DEFAULT NULL
         ,p_aei_attribute8                IN   Varchar2 DEFAULT NULL
         ,p_aei_attribute9                IN   Varchar2 DEFAULT NULL
         ,p_aei_attribute10               IN   Varchar2 DEFAULT NULL
         ,p_aei_attribute11               IN   Varchar2 DEFAULT NULL
         ,p_aei_attribute12               IN   Varchar2 DEFAULT NULL
         ,p_aei_attribute13               IN   Varchar2 DEFAULT NULL
         ,p_aei_attribute14               IN   Varchar2 DEFAULT NULL
         ,p_aei_attribute15               IN   Varchar2 DEFAULT NULL
         ,p_aei_attribute16               IN   Varchar2 DEFAULT NULL
         ,p_aei_attribute17               IN   Varchar2 DEFAULT NULL
         ,p_aei_attribute18               IN   Varchar2 DEFAULT NULL
         ,p_aei_attribute19               IN   Varchar2 DEFAULT NULL
         ,p_aei_attribute20               IN   Varchar2 DEFAULT NULL
         );
-- =============================================================================
-- ~ InsUpd_Person_Extra_Info:
-- =============================================================================
PROCEDURE InsUpd_Person_Extra_Info
         (p_validate                      IN   Number   DEFAULT NULL
         ,p_action                        IN   Varchar2
         ,p_business_group_id             IN   Number
         ,p_effective_date                IN   Date
         ,p_person_id                     IN   Number
         ,p_person_extra_info_id          IN OUT NOCOPY Number
         ,p_object_version_number         IN OUT NOCOPY NUMBER
         ,p_return_status                 OUT NOCOPY Varchar2
         ,p_information_type              IN   Varchar2
          -- DDF Segments
         ,p_pei_information_category      IN   Varchar2 DEFAULT NULL
         ,p_pei_information1              IN   Varchar2 DEFAULT NULL
         ,p_pei_information2              IN   Varchar2 DEFAULT NULL
         ,p_pei_information3              IN   Varchar2 DEFAULT NULL
         ,p_pei_information4              IN   Varchar2 DEFAULT NULL
         ,p_pei_information5              IN   Varchar2 DEFAULT NULL
         ,p_pei_information6              IN   Varchar2 DEFAULT NULL
         ,p_pei_information7              IN   Varchar2 DEFAULT NULL
         ,p_pei_information8              IN   Varchar2 DEFAULT NULL
         ,p_pei_information9              IN   Varchar2 DEFAULT NULL
         ,p_pei_information10             IN   Varchar2 DEFAULT NULL
         ,p_pei_information11             IN   Varchar2 DEFAULT NULL
         ,p_pei_information12             IN   Varchar2 DEFAULT NULL
         ,p_pei_information13             IN   Varchar2 DEFAULT NULL
         ,p_pei_information14             IN   Varchar2 DEFAULT NULL
         ,p_pei_information15             IN   Varchar2 DEFAULT NULL
         ,p_pei_information16             IN   Varchar2 DEFAULT NULL
         ,p_pei_information17             IN   Varchar2 DEFAULT NULL
         ,p_pei_information18             IN   Varchar2 DEFAULT NULL
         ,p_pei_information19             IN   Varchar2 DEFAULT NULL
         ,p_pei_information20             IN   Varchar2 DEFAULT NULL
         ,p_pei_information21             IN   Varchar2 DEFAULT NULL
         ,p_pei_information22             IN   Varchar2 DEFAULT NULL
         ,p_pei_information23             IN   Varchar2 DEFAULT NULL
         ,p_pei_information24             IN   Varchar2 DEFAULT NULL
         ,p_pei_information25             IN   Varchar2 DEFAULT NULL
         ,p_pei_information26             IN   Varchar2 DEFAULT NULL
         ,p_pei_information27             IN   Varchar2 DEFAULT NULL
         ,p_pei_information28             IN   Varchar2 DEFAULT NULL
         ,p_pei_information29             IN   Varchar2 DEFAULT NULL
         ,p_pei_information30             IN   Varchar2 DEFAULT NULL
          -- DF Segments
         ,p_pei_attribute_category        IN   Varchar2 DEFAULT NULL
         ,p_pei_attribute1                IN   Varchar2 DEFAULT NULL
         ,p_pei_attribute2                IN   Varchar2 DEFAULT NULL
         ,p_pei_attribute3                IN   Varchar2 DEFAULT NULL
         ,p_pei_attribute4                IN   Varchar2 DEFAULT NULL
         ,p_pei_attribute5                IN   Varchar2 DEFAULT NULL
         ,p_pei_attribute6                IN   Varchar2 DEFAULT NULL
         ,p_pei_attribute7                IN   Varchar2 DEFAULT NULL
         ,p_pei_attribute8                IN   Varchar2 DEFAULT NULL
         ,p_pei_attribute9                IN   Varchar2 DEFAULT NULL
         ,p_pei_attribute10               IN   Varchar2 DEFAULT NULL
         ,p_pei_attribute11               IN   Varchar2 DEFAULT NULL
         ,p_pei_attribute12               IN   Varchar2 DEFAULT NULL
         ,p_pei_attribute13               IN   Varchar2 DEFAULT NULL
         ,p_pei_attribute14               IN   Varchar2 DEFAULT NULL
         ,p_pei_attribute15               IN   Varchar2 DEFAULT NULL
         ,p_pei_attribute16               IN   Varchar2 DEFAULT NULL
         ,p_pei_attribute17               IN   Varchar2 DEFAULT NULL
         ,p_pei_attribute18               IN   Varchar2 DEFAULT NULL
         ,p_pei_attribute19               IN   Varchar2 DEFAULT NULL
         ,p_pei_attribute20               IN   Varchar2 DEFAULT NULL
         );
-- =============================================================================
-- ~ InsUpd_SIT_Info:
-- =============================================================================
PROCEDURE InsUpd_SIT_Info
         (p_valiDate                  IN     Number   DEFAULT NULL
         ,p_action                    IN     Varchar2
         ,p_person_id                 IN     Number
         ,p_business_group_id         IN     Number
         ,p_id_flex_num               IN     Number
         ,p_effective_date            IN     Date
         ,p_Date_from                 IN     Date     DEFAULT NULL
         ,p_Date_to                   IN     Date     DEFAULT NULL
         ,p_concat_segments           IN     varchar2 DEFAULT NULL
         ,p_analysis_criteria_id      IN OUT NOCOPY   Number
         ,p_person_analysis_id        IN OUT NOCOPY   Number
         ,p_pea_object_version_Number IN OUT NOCOPY   Number
         ,p_return_status                OUT NOCOPY Varchar2
         -- DF on per_person_analyses
         ,p_attribute_category        IN     Varchar2 DEFAULT NULL
         ,p_attribute1                IN     Varchar2 DEFAULT NULL
         ,p_attribute2                IN     Varchar2 DEFAULT NULL
         ,p_attribute3                IN     Varchar2 DEFAULT NULL
         ,p_attribute4                IN     Varchar2 DEFAULT NULL
         ,p_attribute5                IN     Varchar2 DEFAULT NULL
         ,p_attribute6                IN     Varchar2 DEFAULT NULL
         ,p_attribute7                IN     Varchar2 DEFAULT NULL
         ,p_attribute8                IN     Varchar2 DEFAULT NULL
         ,p_attribute9                IN     Varchar2 DEFAULT NULL
         ,p_attribute10               IN     Varchar2 DEFAULT NULL
         ,p_attribute11               IN     Varchar2 DEFAULT NULL
         ,p_attribute12               IN     Varchar2 DEFAULT NULL
         ,p_attribute13               IN     Varchar2 DEFAULT NULL
         ,p_attribute14               IN     Varchar2 DEFAULT NULL
         ,p_attribute15               IN     Varchar2 DEFAULT NULL
         ,p_attribute16               IN     Varchar2 DEFAULT NULL
         ,p_attribute17               IN     Varchar2 DEFAULT NULL
         ,p_attribute18               IN     Varchar2 DEFAULT NULL
         ,p_attribute19               IN     Varchar2 DEFAULT NULL
         ,p_attribute20               IN     Varchar2 DEFAULT NULL
         -- KFF segments on per_analysis_criteria
         ,p_segment1                  IN     Varchar2 DEFAULT NULL
         ,p_segment2                  IN     Varchar2 DEFAULT NULL
         ,p_segment3                  IN     Varchar2 DEFAULT NULL
         ,p_segment4                  IN     Varchar2 DEFAULT NULL
         ,p_segment5                  IN     Varchar2 DEFAULT NULL
         ,p_segment6                  IN     Varchar2 DEFAULT NULL
         ,p_segment7                  IN     Varchar2 DEFAULT NULL
         ,p_segment8                  IN     Varchar2 DEFAULT NULL
         ,p_segment9                  IN     Varchar2 DEFAULT NULL
         ,p_segment10                 IN     Varchar2 DEFAULT NULL
         ,p_segment11                 IN     Varchar2 DEFAULT NULL
         ,p_segment12                 IN     Varchar2 DEFAULT NULL
         ,p_segment13                 IN     Varchar2 DEFAULT NULL
         ,p_segment14                 IN     Varchar2 DEFAULT NULL
         ,p_segment15                 IN     Varchar2 DEFAULT NULL
         ,p_segment16                 IN     Varchar2 DEFAULT NULL
         ,p_segment17                 IN     Varchar2 DEFAULT NULL
         ,p_segment18                 IN     Varchar2 DEFAULT NULL
         ,p_segment19                 IN     Varchar2 DEFAULT NULL
         ,p_segment20                 IN     Varchar2 DEFAULT NULL
         ,p_segment21                 IN     Varchar2 DEFAULT NULL
         ,p_segment22                 IN     Varchar2 DEFAULT NULL
         ,p_segment23                 IN     Varchar2 DEFAULT NULL
         ,p_segment24                 IN     Varchar2 DEFAULT NULL
         ,p_segment25                 IN     Varchar2 DEFAULT NULL
         ,p_segment26                 IN     Varchar2 DEFAULT NULL
         ,p_segment27                 IN     Varchar2 DEFAULT NULL
         ,p_segment28                 IN     Varchar2 DEFAULT NULL
         ,p_segment29                 IN     Varchar2 DEFAULT NULL
         ,p_segment30                 IN     Varchar2 DEFAULT NULL
         --
         ,p_comments                  IN     varchar2 DEFAULT NULL
         ,p_request_id                IN     Number   DEFAULT NULL
         ,p_program_application_id    IN     Number   DEFAULT NULL
         ,p_program_id                IN     Number   DEFAULT NULL
         ,p_program_update_date       IN     Date     DEFAULT NULL
         );
END PQP_HROSS_Integration_SWI;

 

/
