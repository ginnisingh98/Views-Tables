--------------------------------------------------------
--  DDL for Package Body PQP_HROSS_INTEGRATION_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_HROSS_INTEGRATION_SWI" As
/* $Header: pqphrossintgswi.pkb 120.0 2005/05/29 02:23:47 appldev noship $ */

-- =============================================================================
-- ~ Package variables
-- =============================================================================
   g_package  CONSTANT Varchar2(150) := 'PQP_HROSS_Integration_SWI.';
-- =============================================================================
-- ~ Get_PK_For_Validation: Check to see if the visa history is already exist or not.
-- =============================================================================
FUNCTION Get_PK_For_Validation
         (p_port_of_entry        IN Varchar2
         ,p_cntry_entry_form_num IN VARCHAR2) Return BOOLEAN AS

  TYPE csr_lv_rowid IS REF CURSOR;
  cur_rowid              csr_lv_rowid;
  SQLstmt                varchar2(2000);
  lv_rowid               varchar2(1000);
  l_proc_name  CONSTANT  varchar2(150):= g_package ||'Get_PK_For_Validation';

BEGIN

  Hr_Utility.set_location('Entering: '||l_proc_name, 5);

  SQLstmt:=' SELECT rowid
               FROM igs_pe_visit_histry
              WHERE port_of_entry        = :1
                AND cntry_entry_form_num = :2';
  OPEN cur_rowid FOR SQLstmt
               Using p_port_of_entry
                    ,p_cntry_entry_form_num;
  FETCH cur_rowid INTO lv_rowid;
  IF (cur_rowid%FOUND) THEN
    CLOSE cur_rowid;
    RETURN(TRUE);
  ELSE
    CLOSE cur_rowid;
    RETURN(FALSE);
  END IF;

  Hr_Utility.set_location('Leaving: '||l_proc_name, 50);

END Get_PK_For_Validation;

-- =============================================================================
-- ~ Create_OSS_Person:
-- =============================================================================
PROCEDURE Create_OSS_Person
         (p_business_group_id            IN Number
         ,p_dup_person_id                IN Number
         ,p_effective_date               IN Date
         -- Person Details: Per_All_People_F
         ,p_party_id                     IN Number
         ,p_last_name                    IN Varchar2
         ,p_middle_name                  IN Varchar2
         ,p_first_name                   IN Varchar2
         ,p_suffix                       IN Varchar2
         ,p_prefix                       IN Varchar2
         ,p_title                        IN Varchar2
         ,p_email_address                IN Varchar2
         ,p_preferred_name               IN Varchar2
         ,p_marital_status               IN Varchar2
         ,p_sex                          IN Varchar2
         ,p_nationality                  IN Varchar2
         ,p_national_identifier          IN Varchar2
         ,p_date_of_birth                IN Date
         ,p_date_of_hire                 IN Date
         ,p_employee_number              IN Varchar2
         ,p_person_type_id               IN Number
         ,p_date_employee_data_verified  IN Date
         ,p_expense_check_send_to_addres IN Varchar2
         ,p_previous_last_name           IN Varchar2
         ,p_registered_disabled_flag     IN Varchar2
         ,p_vendor_id                    IN Number
         ,p_date_of_death                IN Date
         ,p_background_check_status      IN Varchar2
         ,p_background_date_check        IN Date
         ,p_blood_type                   IN Varchar2
         ,p_correspondence_language      IN Varchar2
         ,p_fast_path_employee           IN Varchar2
         ,p_fte_capacity                 IN Number
         ,p_honors                       IN Varchar2
         ,p_last_medical_test_by         IN Varchar2
         ,p_last_medical_test_date       IN Date
         ,p_mailstop                     IN Varchar2
         ,p_office_number                IN Varchar2
         ,p_on_military_service          IN Varchar2
         ,p_pre_name_adjunct             IN Varchar2
         ,p_projected_start_date         IN Date
         ,p_resume_exists                IN Varchar2
         ,p_resume_last_updated          IN Date
         ,p_second_passport_exists       IN Varchar2
         ,p_student_status               IN Varchar2
         ,p_work_schedule                IN Varchar2
         ,p_benefit_group_id             IN Number
         ,p_receipt_of_death_cert_date   IN Date
         ,p_coord_ben_med_pln_no         IN Varchar2
         ,p_coord_ben_no_cvg_flag        IN Varchar2
         ,p_coord_ben_med_ext_er         IN Varchar2
         ,p_coord_ben_med_pl_name        IN Varchar2
         ,p_coord_ben_med_insr_crr_name  IN Varchar2
         ,p_coord_ben_med_insr_crr_ident IN Varchar2
         ,p_coord_ben_med_cvg_strt_dt    IN Date
         ,p_coord_ben_med_cvg_end_dt     IN Date
         ,p_uses_tobacco_flag            IN Varchar2
         ,p_dpdnt_adoption_date          IN Date
         ,p_dpdnt_vlntry_svce_flag       IN Varchar2
         ,p_original_date_of_hire        IN Date
         ,p_adjusted_svc_date            IN Date
         ,p_town_of_birth                IN Varchar2
         ,p_region_of_birth              IN Varchar2
         ,p_country_of_birth             IN Varchar2
         ,p_global_person_id             IN Varchar2
         -- Person DF
         ,p_per_attribute_category       IN Varchar2
         ,p_per_attribute1               IN Varchar2
         ,p_per_attribute2               IN Varchar2
         ,p_per_attribute3               IN Varchar2
         ,p_per_attribute4               IN Varchar2
         ,p_per_attribute5               IN Varchar2
         ,p_per_attribute6               IN Varchar2
         ,p_per_attribute7               IN Varchar2
         ,p_per_attribute8               IN Varchar2
         ,p_per_attribute9               IN Varchar2
         ,p_per_attribute10              IN Varchar2
         ,p_per_attribute11              IN Varchar2
         ,p_per_attribute12              IN Varchar2
         ,p_per_attribute13              IN Varchar2
         ,p_per_attribute14              IN Varchar2
         ,p_per_attribute15              IN Varchar2
         ,p_per_attribute16              IN Varchar2
         ,p_per_attribute17              IN Varchar2
         ,p_per_attribute18              IN Varchar2
         ,p_per_attribute19              IN Varchar2
         ,p_per_attribute20              IN Varchar2
         ,p_per_attribute21              IN Varchar2
         ,p_per_attribute22              IN Varchar2
         ,p_per_attribute23              IN Varchar2
         ,p_per_attribute24              IN Varchar2
         ,p_per_attribute25              IN Varchar2
         ,p_per_attribute26              IN Varchar2
         ,p_per_attribute27              IN Varchar2
         ,p_per_attribute28              IN Varchar2
         ,p_per_attribute29              IN Varchar2
         ,p_per_attribute30              IN Varchar2
         -- Person DDF
         ,p_per_information_category     IN Varchar2
         ,p_per_information1             IN Varchar2
         ,p_per_information2             IN Varchar2
         ,p_per_information3             IN Varchar2
         ,p_per_information4             IN Varchar2
         ,p_per_information5             IN Varchar2
         ,p_per_information6             IN Varchar2
         ,p_per_information7             IN Varchar2
         ,p_per_information8             IN Varchar2
         ,p_per_information9             IN Varchar2
         ,p_per_information10            IN Varchar2
         ,p_per_information11            IN Varchar2
         ,p_per_information12            IN Varchar2
         ,p_per_information13            IN Varchar2
         ,p_per_information14            IN Varchar2
         ,p_per_information15            IN Varchar2
         ,p_per_information16            IN Varchar2
         ,p_per_information17            IN Varchar2
         ,p_per_information18            IN Varchar2
         ,p_per_information19            IN Varchar2
         ,p_per_information20            IN Varchar2
         ,p_per_information21            IN Varchar2
         ,p_per_information22            IN Varchar2
         ,p_per_information23            IN Varchar2
         ,p_per_information24            IN Varchar2
         ,p_per_information25            IN Varchar2
         ,p_per_information26            IN Varchar2
         ,p_per_information27            IN Varchar2
         ,p_per_information28            IN Varchar2
         ,p_per_information29            IN Varchar2
         ,p_per_information30            IN Varchar2
         -- Primary Address: Per_Addresses
         ,p_pradd_ovlapval_override      IN Varchar2
         ,p_address_type                 IN Varchar2
         ,p_adr_comments                 IN Varchar2
         ,p_primary_flag                 IN Varchar2
         ,p_address_style                IN Varchar2
         ,p_address_line1                IN Varchar2
         ,p_address_line2                IN Varchar2
         ,p_address_line3                IN Varchar2
         ,p_region1                      IN Varchar2
         ,p_region2                      IN Varchar2
         ,p_region3                      IN Varchar2
         ,p_town_or_city                 IN Varchar2
         ,p_country                      IN Varchar2
         ,p_postal_code                  IN Varchar2
         ,p_telephone_no1                IN Varchar2
         ,p_telephone_no2                IN Varchar2
         ,p_telephone_no3                IN Varchar2
         ,p_address_date_from            IN Date
         ,p_address_date_to              IN Date
         ,p_adr_attribute_category       IN Varchar2
         ,p_adr_attribute1               IN Varchar2
         ,p_adr_attribute2               IN Varchar2
         ,p_adr_attribute3               IN Varchar2
         ,p_adr_attribute4               IN Varchar2
         ,p_adr_attribute5               IN Varchar2
         ,p_adr_attribute6               IN Varchar2
         ,p_adr_attribute7               IN Varchar2
         ,p_adr_attribute8               IN Varchar2
         ,p_adr_attribute9               IN Varchar2
         ,p_adr_attribute10              IN Varchar2
         ,p_adr_attribute11              IN Varchar2
         ,p_adr_attribute12              IN Varchar2
         ,p_adr_attribute13              IN Varchar2
         ,p_adr_attribute14              IN Varchar2
         ,p_adr_attribute15              IN Varchar2
         ,p_adr_attribute16              IN Varchar2
         ,p_adr_attribute17              IN Varchar2
         ,p_adr_attribute18              IN Varchar2
         ,p_adr_attribute19              IN Varchar2
         ,p_adr_attribute20              IN Varchar2
         ,p_add_information13            IN Varchar2
         ,p_add_information14            IN Varchar2
         ,p_add_information15            IN Varchar2
         ,p_add_information16            IN Varchar2
         ,p_add_information17            IN Varchar2
         ,p_add_information18            IN Varchar2
         ,p_add_information19            IN Varchar2
         ,p_add_information20            IN Varchar2
         -- Person Phones: Per_Phones
         ,p_phone_type                   IN Varchar2
         ,p_phone_number                 IN Varchar2
         ,p_phone_date_from              IN Date
         ,p_phone_date_to                IN Date
         -- Person Contact: Per_Contact_Relationships
         ,p_contact_type                 IN Varchar2
         ,p_contact_name                 IN Varchar2
         ,p_primary_contact              IN Varchar2
         ,p_primary_relationship         IN Varchar2
         ,p_contact_date_from            IN Date
         ,p_contact_date_to              IN Date
         ,p_return_status                OUT NOCOPY Varchar2
         ,p_dup_asg_id                   IN Number
         ,p_mode_type                    IN Varchar2
        ) AS
  --
  -- Variables for IN/OUT parameters
  --
  l_proc  CONSTANT   Varchar2(150) := g_package ||'Create_OSS_Person';
BEGIN
  Hr_Utility.set_location(' Entering:' || l_proc,5);
  --
  -- Issue a savepoint
  --
  SAVEPOINT Create_OSS_Person_swi;
  --
  -- Initialise Multiple Message Detection
  --
  Hr_Multi_Message.enable_message_list;
  --
  -- Call API
  --
  Pqp_Hross_Integration.Create_OSS_Person
  (p_business_group_id            => p_business_group_id
  ,p_dup_person_id                => p_dup_person_id
  ,p_effective_date               => p_effective_date
  -- Person Details: Per_All_People_F
  ,p_party_id                     => p_party_id
  ,p_last_name                    => p_last_name
  ,p_middle_name                  => p_middle_name
  ,p_first_name                   => p_first_name
  ,p_suffix                       => p_suffix
  ,p_prefix                       => p_prefix
  ,p_title                        => p_title
  ,p_email_address                => p_email_address
  ,p_preferred_name               => p_preferred_name
  ,p_marital_status               => p_marital_status
  ,p_sex                          => p_sex
  ,p_nationality                  => p_nationality
  ,p_national_identifier          => p_national_identifier
  ,p_date_of_birth                => p_date_of_birth
  ,p_date_of_hire                 => p_date_of_hire
  ,p_employee_number              => p_employee_number
  ,p_person_type_id               => p_person_type_id
  ,p_date_employee_data_verified  => p_date_employee_data_verified
  ,p_expense_check_send_to_addres => p_expense_check_send_to_addres
  ,p_previous_last_name           => p_previous_last_name
  ,p_registered_disabled_flag     => p_registered_disabled_flag
  ,p_vendor_id                    => p_vendor_id
  ,p_date_of_death                => p_date_of_death
  ,p_background_check_status      => p_background_check_status
  ,p_background_date_check        => p_background_date_check
  ,p_blood_type                   => p_blood_type
  ,p_correspondence_language      => p_correspondence_language
  ,p_fast_path_employee           => p_fast_path_employee
  ,p_fte_capacity                 => p_fte_capacity
  ,p_honors                       => p_honors
  ,p_last_medical_test_by         => p_last_medical_test_by
  ,p_last_medical_test_date       => p_last_medical_test_date
  ,p_mailstop                     => p_mailstop
  ,p_office_number                => p_office_number
  ,p_on_military_service          => p_on_military_service
  ,p_pre_name_adjunct             => p_pre_name_adjunct
  ,p_projected_start_date         => p_projected_start_date
  ,p_resume_exists                => p_resume_exists
  ,p_resume_last_updated          => p_resume_last_updated
  ,p_second_passport_exists       => p_second_passport_exists
  ,p_student_status               => p_student_status
  ,p_work_schedule                => p_work_schedule
  ,p_benefit_group_id             => p_benefit_group_id
  ,p_receipt_of_death_cert_date   => p_receipt_of_death_cert_date
  ,p_coord_ben_med_pln_no         => p_coord_ben_med_pln_no
  ,p_coord_ben_no_cvg_flag        => p_coord_ben_no_cvg_flag
  ,p_coord_ben_med_ext_er         => p_coord_ben_med_ext_er
  ,p_coord_ben_med_pl_name        => p_coord_ben_med_pl_name
  ,p_coord_ben_med_insr_crr_name  => p_coord_ben_med_insr_crr_name
  ,p_coord_ben_med_insr_crr_ident => p_coord_ben_med_insr_crr_ident
  ,p_coord_ben_med_cvg_strt_dt    => p_coord_ben_med_cvg_strt_dt
  ,p_coord_ben_med_cvg_end_dt     => p_coord_ben_med_cvg_end_dt
  ,p_uses_tobacco_flag            => p_uses_tobacco_flag
  ,p_dpdnt_adoption_date          => p_dpdnt_adoption_date
  ,p_dpdnt_vlntry_svce_flag       => p_dpdnt_vlntry_svce_flag
  ,p_original_date_of_hire        => p_original_date_of_hire
  ,p_adjusted_svc_date            => p_adjusted_svc_date
  ,p_town_of_birth                => p_town_of_birth
  ,p_region_of_birth              => p_region_of_birth
  ,p_country_of_birth             => p_country_of_birth
  ,p_global_person_id             => p_global_person_id
   -- Person DF
  ,p_per_attribute_category       => p_per_attribute_category
  ,p_per_attribute1               => p_per_attribute1
  ,p_per_attribute2               => p_per_attribute2
  ,p_per_attribute3               => p_per_attribute3
  ,p_per_attribute4               => p_per_attribute4
  ,p_per_attribute5               => p_per_attribute5
  ,p_per_attribute6               => p_per_attribute6
  ,p_per_attribute7               => p_per_attribute7
  ,p_per_attribute8               => p_per_attribute8
  ,p_per_attribute9               => p_per_attribute9
  ,p_per_attribute10              => p_per_attribute10
  ,p_per_attribute11              => p_per_attribute11
  ,p_per_attribute12              => p_per_attribute12
  ,p_per_attribute13              => p_per_attribute13
  ,p_per_attribute14              => p_per_attribute14
  ,p_per_attribute15              => p_per_attribute15
  ,p_per_attribute16              => p_per_attribute16
  ,p_per_attribute17              => p_per_attribute17
  ,p_per_attribute18              => p_per_attribute18
  ,p_per_attribute19              => p_per_attribute19
  ,p_per_attribute20              => p_per_attribute20
  ,p_per_attribute21              => p_per_attribute21
  ,p_per_attribute22              => p_per_attribute22
  ,p_per_attribute23              => p_per_attribute23
  ,p_per_attribute24              => p_per_attribute24
  ,p_per_attribute25              => p_per_attribute25
  ,p_per_attribute26              => p_per_attribute26
  ,p_per_attribute27              => p_per_attribute27
  ,p_per_attribute28              => p_per_attribute28
  ,p_per_attribute29              => p_per_attribute29
  ,p_per_attribute30              => p_per_attribute30
  -- Person DDF
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
  -- Primary Address: Per_Addresses
  ,p_pradd_ovlapval_override      => p_pradd_ovlapval_override
  ,p_address_type                 => p_address_type
  ,p_adr_comments                 => p_adr_comments
  ,p_primary_flag                 => p_primary_flag
  ,p_address_style                => p_address_style
  ,p_address_line1                => p_address_line1
  ,p_address_line2                => p_address_line2
  ,p_address_line3                => p_address_line3
  ,p_region1                      => p_region1
  ,p_region2                      => p_region2
  ,p_region3                      => p_region3
  ,p_town_or_city                 => p_town_or_city
  ,p_country                      => p_country
  ,p_postal_code                  => p_postal_code
  ,p_telephone_no1                => p_telephone_no1
  ,p_telephone_no2                => p_telephone_no2
  ,p_telephone_no3                => p_telephone_no3
  ,p_address_date_from            => p_address_date_from
  ,p_address_date_to              => p_address_date_to
  ,p_adr_attribute_category       => p_adr_attribute_category
  ,p_adr_attribute1               => p_adr_attribute1
  ,p_adr_attribute2               => p_adr_attribute2
  ,p_adr_attribute3               => p_adr_attribute3
  ,p_adr_attribute4               => p_adr_attribute4
  ,p_adr_attribute5               => p_adr_attribute5
  ,p_adr_attribute6               => p_adr_attribute6
  ,p_adr_attribute7               => p_adr_attribute7
  ,p_adr_attribute8               => p_adr_attribute8
  ,p_adr_attribute9               => p_adr_attribute9
  ,p_adr_attribute10              => p_adr_attribute10
  ,p_adr_attribute11              => p_adr_attribute11
  ,p_adr_attribute12              => p_adr_attribute12
  ,p_adr_attribute13              => p_adr_attribute13
  ,p_adr_attribute14              => p_adr_attribute14
  ,p_adr_attribute15              => p_adr_attribute15
  ,p_adr_attribute16              => p_adr_attribute16
  ,p_adr_attribute17              => p_adr_attribute17
  ,p_adr_attribute18              => p_adr_attribute18
  ,p_adr_attribute19              => p_adr_attribute19
  ,p_adr_attribute20              => p_adr_attribute20
  ,p_add_information13            => p_add_information13
  ,p_add_information14            => p_add_information14
  ,p_add_information15            => p_add_information15
  ,p_add_information16            => p_add_information16
  ,p_add_information17            => p_add_information17
  ,p_add_information18            => p_add_information18
  ,p_add_information19            => p_add_information19
  ,p_add_information20            => p_add_information20
  -- Person Phones: Per_Phones
  ,p_phone_type                   => p_phone_type
  ,p_phone_number                 => p_phone_number
  ,p_phone_date_from              => p_phone_date_from
  ,p_phone_date_to                => p_phone_date_to
  -- Person Contact: Per_Contact_Relationships
  ,p_contact_type                 => p_contact_type
  ,p_contact_name                 => p_contact_name
  ,p_primary_contact              => p_primary_contact
  ,p_primary_relationship         => p_primary_relationship
  ,p_contact_date_from            => p_contact_date_from
  ,p_contact_date_to              => p_contact_date_to
  ,p_return_status                => p_return_status
  ,p_dup_asg_id                   => p_dup_asg_id
  ,p_mode_type                    => p_mode_type
   );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  --
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  p_return_status := Hr_Multi_Message.get_return_status_disable;
  Hr_Utility.set_location(' Leaving:' || l_proc,50);
  --
EXCEPTION
  WHEN Hr_Multi_Message.error_message_exist THEN
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    ROLLBACK TO Create_OSS_Person_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_return_status := Hr_Multi_Message.get_return_status_disable;
    Hr_Utility.set_location(' Leaving:' || l_proc, 70);
  WHEN Others THEN
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    ROLLBACK TO Create_OSS_Person_swi;
    IF Hr_Multi_Message.unexpected_error_add(l_proc) THEN
       Hr_Utility.set_location(' Leaving:' || l_proc,80);

    END IF;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := Hr_Multi_Message.get_return_status_disable;
    Hr_Utility.set_location(' Leaving:' || l_proc,90);

END Create_OSS_Person;
-- =============================================================================
-- ~ Upd_OSS_Person_Asg:
-- =============================================================================
PROCEDURE Upd_OSS_Person_Asg
          (p_effective_date               IN     Date
          ,p_datetrack_update_mode        IN     Varchar2
          ,p_assignment_id                IN     Number
          ,p_party_id                     IN     Number
          ,p_business_group_id            IN     Number
          ,p_valiDate                     IN     Boolean
          ,p_called_from_mass_upDate      IN     Boolean
          --
          ,p_grade_id                     IN     Number
          ,p_position_id                  IN     Number
          ,p_job_id                       IN     Number
          ,p_payroll_id                   IN     Number
          ,p_location_id                  IN     Number
          ,p_organization_id              IN     Number
          ,p_pay_basis_id                 IN     Number
          ,p_employment_category          IN     Varchar2
          ,p_assignment_category          IN     Varchar2
          --
          ,p_supervisor_id                IN     Number
          ,p_assignment_number            IN     Varchar2
          ,p_change_reason                IN     Varchar2
          ,p_assignment_status_type_id    IN     Number
          ,p_comments                     IN     Varchar2
          ,p_Date_probation_end           IN     Date
          ,p_default_code_comb_id         IN     Number
          ,p_frequency                    IN     Varchar2
          ,p_internal_address_line        IN     Varchar2
          ,p_manager_flag                 IN     Varchar2
          ,p_normal_hours                 IN     Number
          ,p_perf_review_period           IN     Number
          ,p_perf_review_period_frequency IN     Varchar2
          ,p_probation_period             IN     Number
          ,p_probation_unit               IN     Varchar2
          ,p_sal_review_period            IN     Number
          ,p_sal_review_period_frequency  IN     Varchar2
          ,p_set_of_books_id              IN     Number
          ,p_source_type                  IN     Varchar2
          ,p_time_normal_finish           IN     Varchar2
          ,p_time_normal_start            IN     Varchar2
          ,p_bargaining_unit_code         IN     Varchar2
          ,p_labour_union_member_flag     IN     Varchar2
          ,p_hourly_salaried_code         IN     Varchar2
          ,p_title                        IN     Varchar2
          ,p_notice_period                IN     Number
          ,p_notice_period_uom            IN     Varchar2
          ,p_employee_category            IN     Varchar2
          ,p_work_at_home                 IN     Varchar2
          ,p_job_post_source_name         IN     Varchar2
          ,p_supervisor_assignment_id     IN     Number
          --People Group Keyflex Field
          ,p_people_group_id              IN     Number
          ,p_pgrp_segment1                IN     Varchar2
          ,p_pgrp_segment2                IN     Varchar2
          ,p_pgrp_segment3                IN     Varchar2
          ,p_pgrp_segment4                IN     Varchar2
          ,p_pgrp_segment5                IN     Varchar2
          ,p_pgrp_segment6                IN     Varchar2
          ,p_pgrp_segment7                IN     Varchar2
          ,p_pgrp_segment8                IN     Varchar2
          ,p_pgrp_segment9                IN     Varchar2
          ,p_pgrp_segment10               IN     Varchar2
          ,p_pgrp_segment11               IN     Varchar2
          ,p_pgrp_segment12               IN     Varchar2
          ,p_pgrp_segment13               IN     Varchar2
          ,p_pgrp_segment14               IN     Varchar2
          ,p_pgrp_segment15               IN     Varchar2
          ,p_pgrp_segment16               IN     Varchar2
          ,p_pgrp_segment17               IN     Varchar2
          ,p_pgrp_segment18               IN     Varchar2
          ,p_pgrp_segment19               IN     Varchar2
          ,p_pgrp_segment20               IN     Varchar2
          ,p_pgrp_segment21               IN     Varchar2
          ,p_pgrp_segment22               IN     Varchar2
          ,p_pgrp_segment23               IN     Varchar2
          ,p_pgrp_segment24               IN     Varchar2
          ,p_pgrp_segment25               IN     Varchar2
          ,p_pgrp_segment26               IN     Varchar2
          ,p_pgrp_segment27               IN     Varchar2
          ,p_pgrp_segment28               IN     Varchar2
          ,p_pgrp_segment29               IN     Varchar2
          ,p_pgrp_segment30               IN     Varchar2
          ,p_pgrp_concat_segments         IN     Varchar2
          --Soft Coding KeyflexId
          ,p_soft_coding_keyflex_id       IN     Number
          ,p_soft_concat_segments         IN     Varchar2
          ,p_scl_segment1                 IN     Varchar2
          ,p_scl_segment2                 IN     Varchar2
          ,p_scl_segment3                 IN     Varchar2
          ,p_scl_segment4                 IN     Varchar2
          ,p_scl_segment5                 IN     Varchar2
          ,p_scl_segment6                 IN     Varchar2
          ,p_scl_segment7                 IN     Varchar2
          ,p_scl_segment8                 IN     Varchar2
          ,p_scl_segment9                 IN     Varchar2
          ,p_scl_segment10                IN     Varchar2
          ,p_scl_segment11                IN     Varchar2
          ,p_scl_segment12                IN     Varchar2
          ,p_scl_segment13                IN     Varchar2
          ,p_scl_segment14                IN     Varchar2
          ,p_scl_segment15                IN     Varchar2
          ,p_scl_segment16                IN     Varchar2
          ,p_scl_segment17                IN     Varchar2
          ,p_scl_segment18                IN     Varchar2
          ,p_scl_segment19                IN     Varchar2
          ,p_scl_segment20                IN     Varchar2
          ,p_scl_segment21                IN     Varchar2
          ,p_scl_segment22                IN     Varchar2
          ,p_scl_segment23                IN     Varchar2
          ,p_scl_segment24                IN     Varchar2
          ,p_scl_segment25                IN     Varchar2
          ,p_scl_segment26                IN     Varchar2
          ,p_scl_segment27                IN     Varchar2
          ,p_scl_segment28                IN     Varchar2
          ,p_scl_segment29                IN     Varchar2
          ,p_scl_segment30                IN     Varchar2
          -- Assignment DF Information
          ,p_ass_attribute_category       IN     Varchar2
          ,p_ass_attribute1               IN     Varchar2
          ,p_ass_attribute2               IN     Varchar2
          ,p_ass_attribute3               IN     Varchar2
          ,p_ass_attribute4               IN     Varchar2
          ,p_ass_attribute5               IN     Varchar2
          ,p_ass_attribute6               IN     Varchar2
          ,p_ass_attribute7               IN     Varchar2
          ,p_ass_attribute8               IN     Varchar2
          ,p_ass_attribute9               IN     Varchar2
          ,p_ass_attribute10              IN     Varchar2
          ,p_ass_attribute11              IN     Varchar2
          ,p_ass_attribute12              IN     Varchar2
          ,p_ass_attribute13              IN     Varchar2
          ,p_ass_attribute14              IN     Varchar2
          ,p_ass_attribute15              IN     Varchar2
          ,p_ass_attribute16              IN     Varchar2
          ,p_ass_attribute17              IN     Varchar2
          ,p_ass_attribute18              IN     Varchar2
          ,p_ass_attribute19              IN     Varchar2
          ,p_ass_attribute20              IN     Varchar2
          ,p_ass_attribute21              IN     Varchar2
          ,p_ass_attribute22              IN     Varchar2
          ,p_ass_attribute23              IN     Varchar2
          ,p_ass_attribute24              IN     Varchar2
          ,p_ass_attribute25              IN     Varchar2
          ,p_ass_attribute26              IN     Varchar2
          ,p_ass_attribute27              IN     Varchar2
          ,p_ass_attribute28              IN     Varchar2
          ,p_ass_attribute29              IN     Varchar2
          ,p_ass_attribute30              IN     Varchar2
          --
          ,p_grade_ladder_pgm_id          IN     Number
          ,p_special_ceiling_step_id      IN     Number
          ,p_cagr_grade_def_id            IN     Number
          ,p_contract_id                  IN     Number
          ,p_establishment_id             IN     Number
          ,p_collective_agreement_id      IN     Number
          ,p_cagr_id_flex_num             IN     Number
          ,p_cag_segment1                 IN     Varchar2
          ,p_cag_segment2                 IN     Varchar2
          ,p_cag_segment3                 IN     Varchar2
          ,p_cag_segment4                 IN     Varchar2
          ,p_cag_segment5                 IN     Varchar2
          ,p_cag_segment6                 IN     Varchar2
          ,p_cag_segment7                 IN     Varchar2
          ,p_cag_segment8                 IN     Varchar2
          ,p_cag_segment9                 IN     Varchar2
          ,p_cag_segment10                IN     Varchar2
          ,p_cag_segment11                IN     Varchar2
          ,p_cag_segment12                IN     Varchar2
          ,p_cag_segment13                IN     Varchar2
          ,p_cag_segment14                IN     Varchar2
          ,p_cag_segment15                IN     Varchar2
          ,p_cag_segment16                IN     Varchar2
          ,p_cag_segment17                IN     Varchar2
          ,p_cag_segment18                IN     Varchar2
          ,p_cag_segment19                IN     Varchar2
          ,p_cag_segment20                IN     Varchar2
          ,p_return_status                OUT NOCOPY Varchar2
          ,p_FICA_exempt                  IN     Varchar2
          ) AS
  --
  -- Variables for IN/OUT parameters
  --
  l_proc  CONSTANT   Varchar2(150) := g_package ||'Upd_OSS_Person_Asg';
  l_FICA_exempt      Varchar2(15);
BEGIN
  Hr_Utility.set_location(' Entering:' || l_proc,5);
  --
  -- Issue a savepoint
  --
  SAVEPOINT Upd_OSS_Person_Asg_SWI;
  IF p_FICA_exempt Is NULL THEN
     l_FICA_exempt := 'N';
  ELSE
     l_FICA_exempt := p_FICA_exempt;
  END IF;
  --
  -- Initialise Multiple Message Detection
  --
  Hr_Multi_Message.enable_message_list;
  --
  -- Call API
  --
  Pqp_Hross_Integration.Upd_OSS_Person_Asg
  (p_effective_date               => p_effective_date
  ,p_datetrack_update_mode        => p_datetrack_update_mode
  ,p_assignment_id                => p_assignment_id
  ,p_party_id                     => p_party_id
  ,p_business_group_id            => p_business_group_id
  ,p_valiDate                     => FALSE
  ,p_called_from_mass_upDate      => FALSE
  --
  ,p_grade_id                     => p_grade_id
  ,p_position_id                  => p_position_id
  ,p_job_id                       => p_job_id
  ,p_payroll_id                   => p_payroll_id
  ,p_location_id                  => p_location_id
  ,p_organization_id              => p_organization_id
  ,p_pay_basis_id                 => p_pay_basis_id
  ,p_employment_category          => p_employment_category
  ,p_assignment_category          => p_assignment_category
  --
  ,p_supervisor_id                => p_supervisor_id
  ,p_assignment_number            => p_assignment_number
  ,p_change_reason                => p_change_reason
  ,p_assignment_status_type_id    => p_assignment_status_type_id
  ,p_comments                     => p_comments
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
  ,p_sal_review_period            => p_sal_review_period
  ,p_sal_review_period_frequency  => p_sal_review_period_frequency
  ,p_set_of_books_id              => p_set_of_books_id
  ,p_source_type                  => p_source_type
  ,p_time_normal_finish           => p_time_normal_finish
  ,p_time_normal_start            => p_time_normal_start
  ,p_bargaining_unit_code         => p_bargaining_unit_code
  ,p_labour_union_member_flag     => p_labour_union_member_flag
  ,p_hourly_salaried_code         => p_hourly_salaried_code
  ,p_title                        => p_title
  ,p_notice_period                => p_notice_period
  ,p_notice_period_uom            => p_notice_period_uom
  ,p_employee_category            => p_employee_category
  ,p_work_at_home                 => p_work_at_home
  ,p_job_post_source_name         => p_job_post_source_name
  ,p_supervisor_assignment_id     => p_supervisor_assignment_id
  --People Group Keyflex Field
  ,p_people_group_id              => p_people_group_id
  ,p_pgrp_segment1                => p_pgrp_segment1
  ,p_pgrp_segment2                => p_pgrp_segment2
  ,p_pgrp_segment3                => p_pgrp_segment3
  ,p_pgrp_segment4                => p_pgrp_segment4
  ,p_pgrp_segment5                => p_pgrp_segment5
  ,p_pgrp_segment6                => p_pgrp_segment6
  ,p_pgrp_segment7                => p_pgrp_segment7
  ,p_pgrp_segment8                => p_pgrp_segment8
  ,p_pgrp_segment9                => p_pgrp_segment9
  ,p_pgrp_segment10               => p_pgrp_segment10
  ,p_pgrp_segment11               => p_pgrp_segment11
  ,p_pgrp_segment12               => p_pgrp_segment12
  ,p_pgrp_segment13               => p_pgrp_segment13
  ,p_pgrp_segment14               => p_pgrp_segment14
  ,p_pgrp_segment15               => p_pgrp_segment15
  ,p_pgrp_segment16               => p_pgrp_segment16
  ,p_pgrp_segment17               => p_pgrp_segment17
  ,p_pgrp_segment18               => p_pgrp_segment18
  ,p_pgrp_segment19               => p_pgrp_segment19
  ,p_pgrp_segment20               => p_pgrp_segment20
  ,p_pgrp_segment21               => p_pgrp_segment21
  ,p_pgrp_segment22               => p_pgrp_segment22
  ,p_pgrp_segment23               => p_pgrp_segment23
  ,p_pgrp_segment24               => p_pgrp_segment24
  ,p_pgrp_segment25               => p_pgrp_segment25
  ,p_pgrp_segment26               => p_pgrp_segment26
  ,p_pgrp_segment27               => p_pgrp_segment27
  ,p_pgrp_segment28               => p_pgrp_segment28
  ,p_pgrp_segment29               => p_pgrp_segment29
  ,p_pgrp_segment30               => p_pgrp_segment30
  ,p_pgrp_concat_segments         => p_pgrp_concat_segments
  -- Soft Coding KeyflexId
  ,p_soft_coding_keyflex_id       => p_soft_coding_keyflex_id
  ,p_soft_concat_segments         => p_soft_concat_segments
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
  -- Assignment DF Information
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
  --
  ,p_grade_ladder_pgm_id          => p_grade_ladder_pgm_id
  ,p_special_ceiling_step_id      => p_special_ceiling_step_id
  ,p_cagr_grade_def_id            => p_cagr_grade_def_id
  ,p_contract_id                  => p_contract_id
  ,p_establishment_id             => p_establishment_id
  ,p_collective_agreement_id      => p_collective_agreement_id
  ,p_cagr_id_flex_num             => p_cagr_id_flex_num
  ,p_cag_segment1                 => p_cag_segment1
  ,p_cag_segment2                 => p_cag_segment2
  ,p_cag_segment3                 => p_cag_segment3
  ,p_cag_segment4                 => p_cag_segment4
  ,p_cag_segment5                 => p_cag_segment5
  ,p_cag_segment6                 => p_cag_segment6
  ,p_cag_segment7                 => p_cag_segment7
  ,p_cag_segment8                 => p_cag_segment8
  ,p_cag_segment9                 => p_cag_segment9
  ,p_cag_segment10                => p_cag_segment10
  ,p_cag_segment11                => p_cag_segment11
  ,p_cag_segment12                => p_cag_segment12
  ,p_cag_segment13                => p_cag_segment13
  ,p_cag_segment14                => p_cag_segment14
  ,p_cag_segment15                => p_cag_segment15
  ,p_cag_segment16                => p_cag_segment16
  ,p_cag_segment17                => p_cag_segment17
  ,p_cag_segment18                => p_cag_segment18
  ,p_cag_segment19                => p_cag_segment19
  ,p_cag_segment20                => p_cag_segment20
  ,p_return_status                => p_return_status
  ,p_FICA_exempt                  => l_FICA_exempt
   );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  --
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  p_return_status := Hr_Multi_Message.get_return_status_disable;
  Hr_Utility.set_location(' Leaving:' || l_proc,50);
  --
EXCEPTION
  WHEN Hr_Multi_Message.error_message_exist THEN
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    ROLLBACK TO Upd_OSS_Person_Asg_SWI;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_return_status := Hr_Multi_Message.get_return_status_disable;
    Hr_Utility.set_location(' Leaving:' || l_proc, 70);
  WHEN Others THEN
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    ROLLBACK TO Upd_OSS_Person_Asg_SWI;
    IF Hr_Multi_Message.unexpected_error_add(l_proc) THEN
       Hr_Utility.set_location(' Leaving:' || l_proc,80);
    END IF;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := Hr_Multi_Message.get_return_status_disable;
    Hr_Utility.set_location(' Leaving:' || l_proc,90);

END Upd_OSS_Person_Asg;

-- =============================================================================
-- ~ InsUpd_Assig_Extra_Info:
-- =============================================================================
PROCEDURE InsUpd_Assig_Extra_Info
         (p_validate                      IN   Number
         ,p_action                        IN   Varchar2
         ,p_business_group_id             IN   Number
         ,p_effective_date                IN   Date
         ,p_assignment_id                 IN   Number
         ,p_assignment_extra_info_id      IN OUT NOCOPY Number
         ,p_object_version_number         IN OUT NOCOPY NUMBER
         ,p_return_status                 OUT NOCOPY Varchar2
         ,p_information_type              IN   VARCHAR2
          -- DDF Segments
         ,p_aei_information_category      IN   Varchar2
         ,p_aei_information1              IN   Varchar2
         ,p_aei_information2              IN   Varchar2
         ,p_aei_information3              IN   Varchar2
         ,p_aei_information4              IN   Varchar2
         ,p_aei_information5              IN   Varchar2
         ,p_aei_information6              IN   Varchar2
         ,p_aei_information7              IN   Varchar2
         ,p_aei_information8              IN   Varchar2
         ,p_aei_information9              IN   Varchar2
         ,p_aei_information10             IN   Varchar2
         ,p_aei_information11             IN   Varchar2
         ,p_aei_information12             IN   Varchar2
         ,p_aei_information13             IN   Varchar2
         ,p_aei_information14             IN   Varchar2
         ,p_aei_information15             IN   Varchar2
         ,p_aei_information16             IN   Varchar2
         ,p_aei_information17             IN   Varchar2
         ,p_aei_information18             IN   Varchar2
         ,p_aei_information19             IN   Varchar2
         ,p_aei_information20             IN   Varchar2
         ,p_aei_information21             IN   Varchar2
         ,p_aei_information22             IN   Varchar2
         ,p_aei_information23             IN   Varchar2
         ,p_aei_information24             IN   Varchar2
         ,p_aei_information25             IN   Varchar2
         ,p_aei_information26             IN   Varchar2
         ,p_aei_information27             IN   Varchar2
         ,p_aei_information28             IN   Varchar2
         ,p_aei_information29             IN   Varchar2
         ,p_aei_information30             IN   Varchar2
          -- DF Segments
         ,p_aei_attribute_category        IN   Varchar2
         ,p_aei_attribute1                IN   Varchar2
         ,p_aei_attribute2                IN   Varchar2
         ,p_aei_attribute3                IN   Varchar2
         ,p_aei_attribute4                IN   Varchar2
         ,p_aei_attribute5                IN   Varchar2
         ,p_aei_attribute6                IN   Varchar2
         ,p_aei_attribute7                IN   Varchar2
         ,p_aei_attribute8                IN   Varchar2
         ,p_aei_attribute9                IN   Varchar2
         ,p_aei_attribute10               IN   Varchar2
         ,p_aei_attribute11               IN   Varchar2
         ,p_aei_attribute12               IN   Varchar2
         ,p_aei_attribute13               IN   Varchar2
         ,p_aei_attribute14               IN   Varchar2
         ,p_aei_attribute15               IN   Varchar2
         ,p_aei_attribute16               IN   Varchar2
         ,p_aei_attribute17               IN   Varchar2
         ,p_aei_attribute18               IN   Varchar2
         ,p_aei_attribute19               IN   Varchar2
         ,p_aei_attribute20               IN   Varchar2
         ) IS
  l_proc  CONSTANT   Varchar2(150) := g_package ||'InsUpd_Assig_Extra_Info';
  l_extra_info_rec   per_assignment_extra_info%ROWTYPE;
  l_validate         Boolean;
BEGIN
  Hr_Utility.set_location(' Entering:' || l_proc,5);
  --
  -- Issue a savepoint
  --
  SAVEPOINT Extra_Info;
  l_validate := FALSE;
  IF NVL(p_validate,0) <> 0  THEN
     l_validate := TRUE;
  END IF;
  --
  -- Initialise Multiple Message Detection
  --
  Hr_Multi_Message.enable_message_list;
  --
  -- Call API
  --
  l_extra_info_rec.information_type := p_information_type;
  l_extra_info_rec.aei_information_category := p_aei_information_category;
  l_extra_info_rec.aei_attribute_category := p_aei_attribute_category;

  l_extra_info_rec.aei_information1 := p_aei_information1;
  l_extra_info_rec.aei_information2 := p_aei_information2;
  l_extra_info_rec.aei_information3 := p_aei_information3;
  l_extra_info_rec.aei_information4 := p_aei_information4;
  l_extra_info_rec.aei_information5 := p_aei_information5;
  l_extra_info_rec.aei_information6 := p_aei_information6;
  l_extra_info_rec.aei_information7 := p_aei_information7;
  l_extra_info_rec.aei_information8 := p_aei_information8;
  l_extra_info_rec.aei_information9 := p_aei_information9;
  l_extra_info_rec.aei_information10 := p_aei_information10;
  l_extra_info_rec.aei_information11 := p_aei_information11;
  l_extra_info_rec.aei_information12 := p_aei_information12;
  l_extra_info_rec.aei_information13 := p_aei_information13;
  l_extra_info_rec.aei_information14 := p_aei_information14;
  l_extra_info_rec.aei_information15 := p_aei_information15;
  l_extra_info_rec.aei_information16 := p_aei_information16;
  l_extra_info_rec.aei_information17 := p_aei_information17;
  l_extra_info_rec.aei_information18 := p_aei_information18;
  l_extra_info_rec.aei_information19 := p_aei_information19;
  l_extra_info_rec.aei_information20 := p_aei_information20;
  l_extra_info_rec.aei_information21 := p_aei_information21;
  l_extra_info_rec.aei_information22 := p_aei_information22;
  l_extra_info_rec.aei_information23 := p_aei_information23;
  l_extra_info_rec.aei_information24 := p_aei_information24;
  l_extra_info_rec.aei_information25 := p_aei_information25;
  l_extra_info_rec.aei_information26 := p_aei_information26;
  l_extra_info_rec.aei_information27 := p_aei_information27;
  l_extra_info_rec.aei_information28 := p_aei_information28;
  l_extra_info_rec.aei_information29 := p_aei_information29;
  l_extra_info_rec.aei_information30 := p_aei_information30;

  l_extra_info_rec.aei_attribute1 := p_aei_attribute1;
  l_extra_info_rec.aei_attribute2 := p_aei_attribute2;
  l_extra_info_rec.aei_attribute3 := p_aei_attribute3;
  l_extra_info_rec.aei_attribute4 := p_aei_attribute4;
  l_extra_info_rec.aei_attribute5 := p_aei_attribute5;
  l_extra_info_rec.aei_attribute6 := p_aei_attribute6;
  l_extra_info_rec.aei_attribute7 := p_aei_attribute7;
  l_extra_info_rec.aei_attribute8 := p_aei_attribute8;
  l_extra_info_rec.aei_attribute9 := p_aei_attribute9;
  l_extra_info_rec.aei_attribute10 := p_aei_attribute10;
  l_extra_info_rec.aei_attribute11 := p_aei_attribute11;
  l_extra_info_rec.aei_attribute12 := p_aei_attribute12;
  l_extra_info_rec.aei_attribute13 := p_aei_attribute13;
  l_extra_info_rec.aei_attribute14 := p_aei_attribute14;
  l_extra_info_rec.aei_attribute15 := p_aei_attribute15;
  l_extra_info_rec.aei_attribute16 := p_aei_attribute16;
  l_extra_info_rec.aei_attribute17 := p_aei_attribute17;
  l_extra_info_rec.aei_attribute18 := p_aei_attribute18;
  l_extra_info_rec.aei_attribute19 := p_aei_attribute19;
  l_extra_info_rec.aei_attribute20 := p_aei_attribute20;

  IF p_action = 'CREATE' THEN
   l_extra_info_rec.assignment_id            := Null;
   l_extra_info_rec.assignment_extra_info_id := Null;
  ELSIF p_action IN('UPDATE','DELETE') THEN
   l_extra_info_rec.assignment_id            := p_assignment_id;
   l_extra_info_rec.assignment_extra_info_id := p_assignment_extra_info_id;
   l_extra_info_rec.object_version_number    := p_object_version_number;
  END IF;
  PQP_HRTCA_Integration.InsUpd_Asg_Extra_info
  (p_assignment_id     => p_assignment_id
  ,p_business_group_id => p_business_group_id
  ,p_validate          => l_validate
  ,p_action            => p_action
  ,p_extra_info_rec    => l_extra_info_rec
   );
  p_assignment_extra_info_id := l_extra_info_rec.assignment_extra_info_id;
  p_object_version_number    := l_extra_info_rec.object_version_number;

  p_return_status := Hr_Multi_Message.get_return_status_disable;
  Hr_Utility.set_location(' Leaving:' || l_proc,50);
  --
EXCEPTION
  WHEN Hr_Multi_Message.error_message_exist THEN
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    ROLLBACK TO Extra_Info;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_return_status            := Hr_Multi_Message.get_return_status_disable;
    p_assignment_extra_info_id := Null;
    p_object_version_number    := Null;

    Hr_Utility.set_location(' Leaving:' || l_proc, 70);
  WHEN Others THEN
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    ROLLBACK TO Extra_Info;
    IF Hr_Multi_Message.unexpected_error_add(l_proc) THEN
       Hr_Utility.set_location(' Leaving:' || l_proc,80);
    END IF;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status            := Hr_Multi_Message.get_return_status_disable;
    p_assignment_extra_info_id := Null;
    p_object_version_number    := Null;

    Hr_Utility.set_location(' Leaving:' || l_proc,90);

END InsUpd_Assig_Extra_Info;
-- =============================================================================
-- ~ InsUpd_Person_Extra_Info:
-- =============================================================================
PROCEDURE InsUpd_Person_Extra_Info
         (p_validate                      IN   Number
         ,p_action                        IN   Varchar2
         ,p_business_group_id             IN   Number
         ,p_effective_date                IN   Date
         ,p_person_id                     IN   Number
         ,p_person_extra_info_id          IN OUT NOCOPY Number
         ,p_object_version_number         IN OUT NOCOPY NUMBER
         ,p_return_status                 OUT NOCOPY Varchar2
         ,p_information_type              IN   VARCHAR2
          -- DDF Segments
         ,p_pei_information_category      IN   Varchar2
         ,p_pei_information1              IN   Varchar2
         ,p_pei_information2              IN   Varchar2
         ,p_pei_information3              IN   Varchar2
         ,p_pei_information4              IN   Varchar2
         ,p_pei_information5              IN   Varchar2
         ,p_pei_information6              IN   Varchar2
         ,p_pei_information7              IN   Varchar2
         ,p_pei_information8              IN   Varchar2
         ,p_pei_information9              IN   Varchar2
         ,p_pei_information10             IN   Varchar2
         ,p_pei_information11             IN   Varchar2
         ,p_pei_information12             IN   Varchar2
         ,p_pei_information13             IN   Varchar2
         ,p_pei_information14             IN   Varchar2
         ,p_pei_information15             IN   Varchar2
         ,p_pei_information16             IN   Varchar2
         ,p_pei_information17             IN   Varchar2
         ,p_pei_information18             IN   Varchar2
         ,p_pei_information19             IN   Varchar2
         ,p_pei_information20             IN   Varchar2
         ,p_pei_information21             IN   Varchar2
         ,p_pei_information22             IN   Varchar2
         ,p_pei_information23             IN   Varchar2
         ,p_pei_information24             IN   Varchar2
         ,p_pei_information25             IN   Varchar2
         ,p_pei_information26             IN   Varchar2
         ,p_pei_information27             IN   Varchar2
         ,p_pei_information28             IN   Varchar2
         ,p_pei_information29             IN   Varchar2
         ,p_pei_information30             IN   Varchar2
          -- DF Segments
         ,p_pei_attribute_category        IN   Varchar2
         ,p_pei_attribute1                IN   Varchar2
         ,p_pei_attribute2                IN   Varchar2
         ,p_pei_attribute3                IN   Varchar2
         ,p_pei_attribute4                IN   Varchar2
         ,p_pei_attribute5                IN   Varchar2
         ,p_pei_attribute6                IN   Varchar2
         ,p_pei_attribute7                IN   Varchar2
         ,p_pei_attribute8                IN   Varchar2
         ,p_pei_attribute9                IN   Varchar2
         ,p_pei_attribute10               IN   Varchar2
         ,p_pei_attribute11               IN   Varchar2
         ,p_pei_attribute12               IN   Varchar2
         ,p_pei_attribute13               IN   Varchar2
         ,p_pei_attribute14               IN   Varchar2
         ,p_pei_attribute15               IN   Varchar2
         ,p_pei_attribute16               IN   Varchar2
         ,p_pei_attribute17               IN   Varchar2
         ,p_pei_attribute18               IN   Varchar2
         ,p_pei_attribute19               IN   Varchar2
         ,p_pei_attribute20               IN   Varchar2
         ) IS
  Cursor csr_pei (p_person_id            IN Number
                 ,p_person_extra_info_id IN Number
                 ,p_information_type     IN Varchar2) Is
  SELECT *
    FROM per_people_extra_info pei
   WHERE pei.person_id = p_person_id
     AND pei.person_extra_info_id = p_person_extra_info_id
     AND pei.information_type = p_information_type;

  l_proc  CONSTANT   Varchar2(150) := g_package ||'InsUpd_Person_Extra_Info';
  l_extra_info_rec   per_people_extra_info%ROWTYPE;
  l_old_info_rec     per_people_extra_info%ROWTYPE;
  l_error_msg        varchar2(2000);
  l_msg_data         varchar2(4000);
  l_validate         Boolean;
BEGIN
  Hr_Utility.set_location(' Entering:' || l_proc,5);
  --
  -- Issue a savepoint
  --
  SAVEPOINT Extra_Info;
  l_validate := FALSE;
  IF NVL(p_validate,0) <> 0  THEN
     l_validate := TRUE;
  END IF;
  Hr_Utility.set_location(' set the person id profile:' || p_person_id,7);
  Fnd_Profile.put('PER_PERSON_ID',p_person_id);
  --
  -- Initialise Multiple Message Detection
  --
  Hr_Multi_Message.enable_message_list;
  --
  -- Call API
  --
  l_extra_info_rec.information_type         := p_information_type;
  l_extra_info_rec.pei_information_category := p_pei_information_category;
  l_extra_info_rec.pei_attribute_category   := p_pei_attribute_category;

  l_extra_info_rec.pei_information1 := p_pei_information1;
  l_extra_info_rec.pei_information2 := p_pei_information2;
  l_extra_info_rec.pei_information3 := p_pei_information3;
  l_extra_info_rec.pei_information4 := p_pei_information4;
  l_extra_info_rec.pei_information5 := p_pei_information5;

  l_extra_info_rec.pei_information6 := p_pei_information6;
  l_extra_info_rec.pei_information7 := p_pei_information7;
  l_extra_info_rec.pei_information8 := p_pei_information8;
  l_extra_info_rec.pei_information9 := p_pei_information9;
  l_extra_info_rec.pei_information10 := p_pei_information10;

  l_extra_info_rec.pei_information11 := p_pei_information11;
  l_extra_info_rec.pei_information12 := p_pei_information12;
  l_extra_info_rec.pei_information13 := p_pei_information13;
  l_extra_info_rec.pei_information14 := p_pei_information14;
  l_extra_info_rec.pei_information15 := p_pei_information15;

  l_extra_info_rec.pei_information16 := p_pei_information16;
  l_extra_info_rec.pei_information17 := p_pei_information17;
  l_extra_info_rec.pei_information18 := p_pei_information18;
  l_extra_info_rec.pei_information19 := p_pei_information19;
  l_extra_info_rec.pei_information20 := p_pei_information20;

  l_extra_info_rec.pei_information21 := p_pei_information21;
  l_extra_info_rec.pei_information22 := p_pei_information22;
  l_extra_info_rec.pei_information23 := p_pei_information23;
  l_extra_info_rec.pei_information24 := p_pei_information24;
  l_extra_info_rec.pei_information25 := p_pei_information25;

  l_extra_info_rec.pei_information26 := p_pei_information26;
  l_extra_info_rec.pei_information27 := p_pei_information27;
  l_extra_info_rec.pei_information28 := p_pei_information28;
  l_extra_info_rec.pei_information29 := p_pei_information29;
  l_extra_info_rec.pei_information30 := p_pei_information30;

  l_extra_info_rec.pei_attribute1  := p_pei_attribute1;
  l_extra_info_rec.pei_attribute2  := p_pei_attribute2;
  l_extra_info_rec.pei_attribute3  := p_pei_attribute3;
  l_extra_info_rec.pei_attribute4  := p_pei_attribute4;
  l_extra_info_rec.pei_attribute5  := p_pei_attribute5;

  l_extra_info_rec.pei_attribute6  := p_pei_attribute6;
  l_extra_info_rec.pei_attribute7  := p_pei_attribute7;
  l_extra_info_rec.pei_attribute8  := p_pei_attribute8;
  l_extra_info_rec.pei_attribute9  := p_pei_attribute9;
  l_extra_info_rec.pei_attribute10 := p_pei_attribute10;

  l_extra_info_rec.pei_attribute11 := p_pei_attribute11;
  l_extra_info_rec.pei_attribute12 := p_pei_attribute12;
  l_extra_info_rec.pei_attribute13 := p_pei_attribute13;
  l_extra_info_rec.pei_attribute14 := p_pei_attribute14;
  l_extra_info_rec.pei_attribute15 := p_pei_attribute15;

  l_extra_info_rec.pei_attribute16 := p_pei_attribute16;
  l_extra_info_rec.pei_attribute17 := p_pei_attribute17;
  l_extra_info_rec.pei_attribute18 := p_pei_attribute18;
  l_extra_info_rec.pei_attribute19 := p_pei_attribute19;
  l_extra_info_rec.pei_attribute20 := p_pei_attribute20;

  IF p_action = 'CREATE' THEN
   l_extra_info_rec.person_id            := Null;
   l_extra_info_rec.person_extra_info_id := Null;
   IF (l_extra_info_rec.information_type
       ='PER_US_VISIT_HISTORY') THEN
      IF(Get_PK_For_Validation
         (l_extra_info_rec.pei_information13
         ,l_extra_info_rec.pei_information12)
          ) THEN
          l_msg_data
           := fnd_message.get_string('PQP','PQP_230198_VISA_HISTORY_EXISTS');
      END IF;
   END IF;

  ELSIF p_action = 'UPDATE' THEN
   -- If the action is update
   l_extra_info_rec.person_id             := p_person_id;
   l_extra_info_rec.person_extra_info_id  := p_person_extra_info_id;
   l_extra_info_rec.object_version_number := p_object_version_number;
   OPEN csr_pei (p_person_id            => p_person_id
                ,p_person_extra_info_id => p_person_extra_info_id
                ,p_information_type     => l_extra_info_rec.information_type);
   FETCH csr_pei INTO l_old_info_rec;
   CLOSE csr_pei;
   -- Need to do some additional check for the following information type.
   IF l_extra_info_rec.information_type = 'PER_US_VISIT_HISTORY' THEN
    -- =================================================================================
    -- Purpose (VS)-R       = pei_information5  = This is Specific to HRMS
    -- Visa Number          = pei_information11 = igs_pe_visit_histry_v.visa_number
    -- Start Date-R         = pei_information7  = igs_pe_visit_histry.visit_start_date
    -- End Date             = pei_information8  = igs_pe_visit_histry.visit_end_date
    -- Spouse Accompanied-R = pei_information9  = This is Specific to HRMS
    -- Child Accompanied -R = pei_information10 = This is Specific to HRMS
    -- Entry Number         = pei_information12 = igs_pe_visit_histry.cntry_entry_form_num
    -- Port Of Entry (VS)   = pei_information13 = igs_pe_visit_histry.port_of_entry
    -- ================================================================================
     IF l_extra_info_rec.pei_information11 Is null THEN
       l_msg_data := 'VISA Number is required for student.';
     ELSIF (l_extra_info_rec.pei_information12 Is Null or
            l_extra_info_rec.pei_information13 Is Null ) THEN
       l_msg_data := 'Port Of Entry and Entry Number are required for Student Employee.';
     ELSIF (l_extra_info_rec.pei_information12 <>
            l_old_info_rec.pei_information12) or
           (l_extra_info_rec.pei_information13 <>
            l_old_info_rec.pei_information13) THEN
       l_msg_data := 'Cannot Update the Port of Entry or Number for a Student Employee.';
     END IF;
   END IF;

  ELSIF p_action = 'DELETE' THEN
   -- If the action is delete.
   l_extra_info_rec.person_id             := p_person_id;
   l_extra_info_rec.person_extra_info_id  := p_person_extra_info_id;
   l_extra_info_rec.object_version_number := p_object_version_number;

  END IF;
  -- Check if any errors are raised.
  IF l_msg_data Is Not Null Then
     l_error_msg := Substrb(l_msg_data,1,2000);
     Hr_Utility.set_message(8303, 'PQP_230500_HROSS_GENERIC_ERR');
     Hr_Utility.set_message_token('GENERIC_TOKEN',l_error_msg );
     Hr_Utility.raise_error;
  END IF;

  PQP_HRTCA_Integration.InsUpd_Per_Extra_info
  (p_person_id         => p_person_id
  ,p_business_group_id => p_business_group_id
  ,p_validate          => l_validate
  ,p_action            => p_action
  ,p_extra_info_rec    => l_extra_info_rec
   );
  p_person_extra_info_id  := l_extra_info_rec.person_extra_info_id;
  p_object_version_number := l_extra_info_rec.object_version_number;

  p_return_status := Hr_Multi_Message.get_return_status_disable;
  Hr_Utility.set_location(' Leaving:' || l_proc,50);
  --
EXCEPTION
  WHEN Hr_Multi_Message.error_message_exist THEN
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    ROLLBACK TO Extra_Info;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_return_status         := Hr_Multi_Message.get_return_status_disable;
    p_person_extra_info_id  := Null;
    p_object_version_number := Null;

    Hr_Utility.set_location(' Leaving:' || l_proc, 70);
  WHEN Others THEN
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    ROLLBACK TO Extra_Info;
    IF Hr_Multi_Message.unexpected_error_add(l_proc) THEN
       Hr_Utility.set_location(' Leaving:' || l_proc,80);
    END IF;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status            := Hr_Multi_Message.get_return_status_disable;
    p_person_extra_info_id  := Null;
    p_object_version_number := Null;

    Hr_Utility.set_location(' Leaving:' || l_proc,90);

END InsUpd_Person_Extra_Info;
-- =============================================================================
-- ~ InsUpd_SIT_Info:
-- =============================================================================
PROCEDURE InsUpd_SIT_Info
         (p_valiDate                  IN     Number
         ,p_action                    IN     Varchar2
         ,p_person_id                 IN     Number
         ,p_business_group_id         IN     Number
         ,p_id_flex_num               IN     Number
         ,p_effective_date            IN     Date
         ,p_Date_from                 IN     Date
         ,p_Date_to                   IN     Date
         ,p_concat_segments           IN     varchar2
         ,p_analysis_criteria_id      IN OUT NOCOPY Number
         ,p_person_analysis_id        IN OUT NOCOPY Number
         ,p_pea_object_version_Number IN OUT NOCOPY Number
         ,p_return_status                OUT NOCOPY Varchar2
         -- DF on per_person_analyses
         ,p_attribute_category        IN     Varchar2
         ,p_attribute1                IN     Varchar2
         ,p_attribute2                IN     Varchar2
         ,p_attribute3                IN     Varchar2
         ,p_attribute4                IN     Varchar2
         ,p_attribute5                IN     Varchar2
         ,p_attribute6                IN     Varchar2
         ,p_attribute7                IN     Varchar2
         ,p_attribute8                IN     Varchar2
         ,p_attribute9                IN     Varchar2
         ,p_attribute10               IN     Varchar2
         ,p_attribute11               IN     Varchar2
         ,p_attribute12               IN     Varchar2
         ,p_attribute13               IN     Varchar2
         ,p_attribute14               IN     Varchar2
         ,p_attribute15               IN     Varchar2
         ,p_attribute16               IN     Varchar2
         ,p_attribute17               IN     Varchar2
         ,p_attribute18               IN     Varchar2
         ,p_attribute19               IN     Varchar2
         ,p_attribute20               IN     Varchar2
         -- KFF segments on per_analysis_criteria
         ,p_segment1                  IN     Varchar2
         ,p_segment2                  IN     Varchar2
         ,p_segment3                  IN     Varchar2
         ,p_segment4                  IN     Varchar2
         ,p_segment5                  IN     Varchar2
         ,p_segment6                  IN     Varchar2
         ,p_segment7                  IN     Varchar2
         ,p_segment8                  IN     Varchar2
         ,p_segment9                  IN     Varchar2
         ,p_segment10                 IN     Varchar2
         ,p_segment11                 IN     Varchar2
         ,p_segment12                 IN     Varchar2
         ,p_segment13                 IN     Varchar2
         ,p_segment14                 IN     Varchar2
         ,p_segment15                 IN     Varchar2
         ,p_segment16                 IN     Varchar2
         ,p_segment17                 IN     Varchar2
         ,p_segment18                 IN     Varchar2
         ,p_segment19                 IN     Varchar2
         ,p_segment20                 IN     Varchar2
         ,p_segment21                 IN     Varchar2
         ,p_segment22                 IN     Varchar2
         ,p_segment23                 IN     Varchar2
         ,p_segment24                 IN     Varchar2
         ,p_segment25                 IN     Varchar2
         ,p_segment26                 IN     Varchar2
         ,p_segment27                 IN     Varchar2
         ,p_segment28                 IN     Varchar2
         ,p_segment29                 IN     Varchar2
         ,p_segment30                 IN     Varchar2
         --
         ,p_comments                  IN     varchar2
         ,p_request_id                IN     Number
         ,p_program_application_id    IN     Number
         ,p_program_id                IN     Number
         ,p_program_update_date       IN     Date
         ) IS

  l_proc  CONSTANT        Varchar2(150) := g_package ||'InsUpd_SIT_Info';
  l_analysis_criteria_rec per_analysis_criteria%ROWTYPE;
  l_analyses_rec          per_person_analyses%ROWTYPE;
  l_validate              Boolean;
BEGIN
  Hr_Utility.set_location(' Entering:' || l_proc,5);
  --
  -- Issue a savepoint
  --
  SAVEPOINT Extra_Info;
  l_validate := FALSE;
  IF NVL(p_validate,0) <> 0  THEN
     l_validate := TRUE;
  END IF;

  --
  -- Initialise Multiple Message Detection
  --
  Hr_Multi_Message.enable_message_list;
  --
  -- Call API
  --
  l_analyses_rec.business_group_id     := p_business_group_id;
  l_analyses_rec.person_id             := p_person_id;
  l_analyses_rec.id_flex_num           := p_id_flex_num;
  l_analyses_rec.Date_from             := p_Date_from;
  l_analyses_rec.Date_to               := p_Date_to;
  l_analyses_rec.object_version_Number := p_pea_object_version_Number;
  l_analyses_rec.person_analysis_id    := p_person_analysis_id;

  l_analyses_rec.attribute_category := p_attribute_category;
  l_analyses_rec.attribute1 := p_attribute1;
  l_analyses_rec.attribute2 := p_attribute2;
  l_analyses_rec.attribute3 := p_attribute3;
  l_analyses_rec.attribute4 := p_attribute4;
  l_analyses_rec.attribute5 := p_attribute5;
  l_analyses_rec.attribute6 := p_attribute6;
  l_analyses_rec.attribute7 := p_attribute7;
  l_analyses_rec.attribute8 := p_attribute8;
  l_analyses_rec.attribute9 := p_attribute9;
  l_analyses_rec.attribute10 := p_attribute10;
  l_analyses_rec.attribute11 := p_attribute11;
  l_analyses_rec.attribute12 := p_attribute12;
  l_analyses_rec.attribute13 := p_attribute13;
  l_analyses_rec.attribute14 := p_attribute14;
  l_analyses_rec.attribute15 := p_attribute15;
  l_analyses_rec.attribute16 := p_attribute16;
  l_analyses_rec.attribute17 := p_attribute17;
  l_analyses_rec.attribute18 := p_attribute18;
  l_analyses_rec.attribute19 := p_attribute19;
  l_analyses_rec.attribute20 := p_attribute20;

  l_analysis_criteria_rec.analysis_criteria_id := p_analysis_criteria_id;
  l_analysis_criteria_rec.segment1 := p_segment1;
  l_analysis_criteria_rec.segment2 := p_segment2;
  l_analysis_criteria_rec.segment3 := p_segment3;
  l_analysis_criteria_rec.segment4 := p_segment4;
  l_analysis_criteria_rec.segment5 := p_segment5;
  l_analysis_criteria_rec.segment6 := p_segment6;
  l_analysis_criteria_rec.segment7 := p_segment7;
  l_analysis_criteria_rec.segment8 := p_segment8;
  l_analysis_criteria_rec.segment9 := p_segment9;
  l_analysis_criteria_rec.segment10 := p_segment10;
  l_analysis_criteria_rec.segment11 := p_segment11;
  l_analysis_criteria_rec.segment12 := p_segment12;
  l_analysis_criteria_rec.segment13 := p_segment13;
  l_analysis_criteria_rec.segment14 := p_segment14;
  l_analysis_criteria_rec.segment15 := p_segment15;
  l_analysis_criteria_rec.segment16 := p_segment16;
  l_analysis_criteria_rec.segment17 := p_segment17;
  l_analysis_criteria_rec.segment18 := p_segment18;
  l_analysis_criteria_rec.segment19 := p_segment19;
  l_analysis_criteria_rec.segment20 := p_segment20;
  l_analysis_criteria_rec.segment21 := p_segment21;
  l_analysis_criteria_rec.segment22 := p_segment22;
  l_analysis_criteria_rec.segment23 := p_segment23;
  l_analysis_criteria_rec.segment24 := p_segment24;
  l_analysis_criteria_rec.segment25 := p_segment25;
  l_analysis_criteria_rec.segment26 := p_segment26;
  l_analysis_criteria_rec.segment27 := p_segment27;
  l_analysis_criteria_rec.segment28 := p_segment28;
  l_analysis_criteria_rec.segment29 := p_segment29;
  l_analysis_criteria_rec.segment30 := p_segment30;

  IF p_action = 'CREATE' THEN
     l_analyses_rec.person_analysis_id    := NULL;
     l_analyses_rec.object_version_Number := NULL;
  END IF;

  PQP_HRTCA_Integration.InsUpd_SIT_info
  (p_person_id             => p_person_id
  ,p_business_group_id     => p_business_group_id
  ,p_validate              => l_validate
  ,p_effective_date        => p_effective_date
  ,p_action                => p_action
  ,p_analysis_criteria_rec => l_analysis_criteria_rec
  ,p_analyses_rec          => l_analyses_rec
   );
  p_analysis_criteria_id      := l_analysis_criteria_rec.analysis_criteria_id;
  p_person_analysis_id        := l_analyses_rec.person_analysis_id;
  p_pea_object_version_Number := l_analyses_rec.object_version_Number;


  p_return_status := Hr_Multi_Message.get_return_status_disable;
  Hr_Utility.set_location(' Leaving:' || l_proc,50);
  --
EXCEPTION
  WHEN Hr_Multi_Message.error_message_exist THEN
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    ROLLBACK TO Extra_Info;

    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_return_status             := Hr_Multi_Message.get_return_status_disable;
    p_analysis_criteria_id      := Null;
    p_person_analysis_id        := Null;
    p_pea_object_version_Number := Null;

    Hr_Utility.set_location(' Leaving:' || l_proc, 70);
  WHEN Others THEN
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    ROLLBACK TO Extra_Info;
    IF Hr_Multi_Message.unexpected_error_add(l_proc) THEN
       Hr_Utility.set_location(' Leaving:' || l_proc,80);
    END IF;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status            := Hr_Multi_Message.get_return_status_disable;
    p_analysis_criteria_id      := Null;
    p_person_analysis_id        := Null;
    p_pea_object_version_Number := Null;
    Hr_Utility.set_location(' Leaving:' || l_proc,90);

END InsUpd_SIT_Info;

END PQP_HROSS_Integration_SWI;

/
