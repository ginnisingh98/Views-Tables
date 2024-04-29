--------------------------------------------------------
--  DDL for Package Body HR_IN_EMPLOYEE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_IN_EMPLOYEE_API" AS
/* $Header: peempini.pkb 120.1 2007/10/05 11:27:44 sivanara ship $ */
g_package  VARCHAR2(33) ;
g_trace boolean ;

-- ----------------------------------------------------------------------------
-- |--------------------------< create_in_employee >-----------------------------|
-- ----------------------------------------------------------------------------

procedure create_in_employee
  (p_validate                      IN     boolean  default false
  ,p_hire_date                     IN     date
  ,p_business_group_id             IN     number
  ,p_last_name                     IN     varchar2
  ,p_sex                           IN     varchar2
  ,p_person_type_id                IN     number   default null
  ,p_per_comments                  IN     varchar2 default null
  ,p_date_employee_data_verified   IN     date     default null
  ,p_date_of_birth                 IN     date     default null
  ,p_email_address                 IN     varchar2 default null
  ,p_employee_number               IN out nocopy varchar2
  ,p_expense_check_send_to_addres  IN     varchar2 default null
  ,p_first_name                    IN     varchar2 default null
  ,p_alias_name                    IN     varchar2 default null --Bugfix 3762728
  ,p_marital_status                IN     varchar2 default null
  ,p_middle_names                  IN     varchar2 default null
  ,p_nationality                   IN     varchar2 default null
  ,p_national_identifier           IN     varchar2 default null
  ,p_previous_last_name            IN     varchar2 default null
  ,p_registered_disabled_flag      IN     varchar2 default null
  ,p_title                         IN     varchar2 default null
  ,p_vendor_id                     IN     number   default null
  ,p_work_telephone                IN     varchar2 default null
  ,p_attribute_category            IN     varchar2 default null
  ,p_attribute1                    IN     varchar2 default null
  ,p_attribute2                    IN     varchar2 default null
  ,p_attribute3                    IN     varchar2 default null
  ,p_attribute4                    IN     varchar2 default null
  ,p_attribute5                    IN     varchar2 default null
  ,p_attribute6                    IN     varchar2 default null
  ,p_attribute7                    IN     varchar2 default null
  ,p_attribute8                    IN     varchar2 default null
  ,p_attribute9                    IN     varchar2 default null
  ,p_attribute10                   IN     varchar2 default null
  ,p_attribute11                   IN     varchar2 default null
  ,p_attribute12                   IN     varchar2 default null
  ,p_attribute13                   IN     varchar2 default null
  ,p_attribute14                   IN     varchar2 default null
  ,p_attribute15                   IN     varchar2 default null
  ,p_attribute16                   IN     varchar2 default null
  ,p_attribute17                   IN     varchar2 default null
  ,p_attribute18                   IN     varchar2 default null
  ,p_attribute19                   IN     varchar2 default null
  ,p_attribute20                   IN     varchar2 default null
  ,p_attribute21                   IN     varchar2 default null
  ,p_attribute22                   IN     varchar2 default null
  ,p_attribute23                   IN     varchar2 default null
  ,p_attribute24                   IN     varchar2 default null
  ,p_attribute25                   IN     varchar2 default null
  ,p_attribute26                   IN     varchar2 default null
  ,p_attribute27                   IN     varchar2 default null
  ,p_attribute28                   IN     varchar2 default null
  ,p_attribute29                   IN     varchar2 default null
  ,p_attribute30                   IN     varchar2 default null
  ,p_pan                           IN     varchar2 default null
  ,p_pan_af                        IN     varchar2 default null
  ,p_ex_serviceman                 IN     varchar2 default null --Bugfix 3762728
  ,p_resident_status               IN     varchar2 default null
  ,p_pf_number                     IN     varchar2 default null
  ,p_esi_number                    IN     varchar2 default null
  ,p_superannuation_number         IN     varchar2 default null
  ,p_group_ins_number              IN     varchar2 default null
  ,p_gratuity_number               IN     varchar2 default null
  ,p_pension_number                IN     varchar2 default NULL
  ,p_NSSN                          IN     varchar2 default NULL
  ,p_date_of_death                 IN     date     default null
  ,p_background_check_status       IN     varchar2 default null
  ,p_background_date_check         IN     date     default null
  ,p_blood_type                    IN     varchar2 default null
  ,p_correspondence_language       IN     varchar2 default null
  ,p_fast_path_employee            IN     varchar2 default null
  ,p_fte_capacity                  IN     number   default null
  ,p_honors                        IN     varchar2 default null
  ,p_internal_location             IN     varchar2 default null
  ,p_last_medical_test_by          IN     varchar2 default null
  ,p_last_medical_test_date        IN     date     default null
  ,p_mailstop                      IN     varchar2 default null
  ,p_office_number                 IN     varchar2 default null
  ,p_on_military_service           IN     varchar2 default null
  ,p_pre_name_adjunct              IN     varchar2 default null
  ,p_rehire_recommendation 	   IN     varchar2 default null
  ,p_projected_start_date          IN     date     default null
  ,p_resume_exists                 IN     varchar2 default null
  ,p_resume_last_updated           IN     date     default null
  ,p_second_passport_exists        IN     varchar2 default null
  ,p_student_status                IN     varchar2 default null
  ,p_work_schedule                 IN     varchar2 default null
  ,p_suffix                        IN     varchar2 default null
  ,p_benefit_group_id              IN     number   default null
  ,p_receipt_of_death_cert_date    IN     date     default null
  ,p_coord_ben_med_pln_no          IN     varchar2 default null
  ,p_coord_ben_no_cvg_flag         IN     varchar2 default 'N'
  ,p_coord_ben_med_ext_er          IN     varchar2 default null
  ,p_coord_ben_med_pl_name         IN     varchar2 default null
  ,p_coord_ben_med_insr_crr_name   IN     varchar2 default null
  ,p_coord_ben_med_insr_crr_ident  IN     varchar2 default null
  ,p_coord_ben_med_cvg_strt_dt     IN     date default null
  ,p_coord_ben_med_cvg_end_dt      IN     date default null
  ,p_uses_tobacco_flag             IN     varchar2 default null
  ,p_dpdnt_adoption_date           IN     date     default null
  ,p_dpdnt_vlntry_svce_flag        IN     varchar2 default 'N'
  ,p_original_date_of_hire         IN     date     default null
  ,p_adjusted_svc_date             IN     date     default null
  ,p_place_of_birth                IN     varchar2 default null --Bugfix 3762728
  ,p_region_of_birth               IN     varchar2 default null
  ,p_country_of_birth              IN     varchar2 default null
  ,p_global_person_id              IN     varchar2 default null
  ,p_party_id                      IN     number default null
  ,p_person_id                     OUT NOCOPY number
  ,p_assignment_id                 OUT NOCOPY number
  ,p_per_object_version_number     OUT NOCOPY number
  ,p_asg_object_version_number     OUT NOCOPY number
  ,p_per_effective_start_date      OUT NOCOPY date
  ,p_per_effective_end_date        OUT NOCOPY date
  ,p_full_name                     OUT NOCOPY varchar2
  ,p_per_comment_id                OUT NOCOPY number
  ,p_assignment_sequence           OUT NOCOPY number
  ,p_assignment_number             OUT NOCOPY varchar2
  ,p_name_combination_warning      OUT NOCOPY boolean
  ,p_assign_payroll_warning        OUT NOCOPY boolean
  ,p_orig_hire_warning             OUT NOCOPY boolean
  ) IS
    -- Declare cursors and local variables
    --
    l_proc  VARCHAR2(72);
    l_pension_number VARCHAR2(30);

    --
BEGIN
  g_package := 'hr_in_employee_api.';
  l_proc  := g_package||'create_in_employee';
  g_trace := hr_utility.debug_enabled ;

  if g_trace then
    hr_utility.set_location('Entering: '||l_proc, 10);
  end if ;

  if  hr_general2.IS_BG(p_business_group_id, 'IN') = false then
    hr_utility.set_message(800, 'HR_7208_API_BUS_GRP_INVALID');
    hr_utility.raise_error;
  end if;

  if g_trace then
     hr_utility.set_location(l_proc, 20);
  end if ;

  l_pension_number :=p_pension_number;

  IF p_pension_number IS NULL THEN
    l_pension_number :=p_pf_number;
  END IF;



  hr_employee_api.create_employee
    ( p_validate                      => p_validate
      ,p_hire_date                    => p_hire_date
      ,p_business_group_id            => p_business_group_id
      ,p_last_name                    => p_last_name
      ,p_sex                          => p_sex
      ,p_person_type_id               => p_person_type_id
      ,p_per_comments                 => p_per_comments
      ,p_date_employee_data_verified  => p_date_employee_data_verified
      ,p_date_of_birth                => p_date_of_birth
      ,p_email_address                => p_email_address
      ,p_employee_number              => p_employee_number
      ,p_expense_check_send_to_addres => p_expense_check_send_to_addres
      ,p_first_name                   => p_first_name
      ,p_known_as                     => p_alias_name --Bugfix 3762728
      ,p_marital_status               => p_marital_status
      ,p_middle_names                 => p_middle_names
      ,p_nationality                  => p_nationality
      ,p_national_identifier          => p_national_identifier
      ,p_previous_last_name           => p_previous_last_name
      ,p_registered_disabled_flag     => p_registered_disabled_flag
      ,p_title                        => p_title
      ,p_vendor_id                    => p_vendor_id
      ,p_work_telephone               => p_work_telephone
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
      ,p_per_information_category     => 'IN'
      ,p_per_information4             => p_pan
      ,p_per_information5             => p_pan_af
      ,p_per_information6             => p_ex_serviceman --Bugfix 3762728
      ,p_per_information7             => p_resident_status
      ,p_per_information8             => p_pf_number
      ,p_per_information9             => p_esi_number
      ,p_per_information10            => p_superannuation_number
      ,p_per_information11            => p_group_ins_number
      ,p_per_information12            => p_gratuity_number
      ,p_per_information13            => l_pension_number
      ,p_per_information15            => p_NSSN
      ,p_date_of_death                => p_date_of_death
      ,p_background_check_status      => p_background_check_status
      ,p_background_date_check        => p_background_date_check
      ,p_blood_type                   => p_blood_type
      ,p_correspondence_language      => p_correspondence_language
      ,p_fast_path_employee           => p_fast_path_employee
      ,p_fte_capacity                 => p_fte_capacity
      ,p_honors                       => p_honors
      ,p_internal_location            => p_internal_location
      ,p_last_medical_test_by         => p_last_medical_test_by
      ,p_last_medical_test_date       => p_last_medical_test_date
      ,p_mailstop                     => p_mailstop
      ,p_office_number                => p_office_number
      ,p_on_military_service          => p_on_military_service
      ,p_pre_name_adjunct             => p_pre_name_adjunct
      ,p_rehire_recommendation 	      => p_rehire_recommendation
      ,p_projected_start_date         => p_projected_start_date
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
      ,p_town_of_birth                => p_place_of_birth --Bugfix 3762728
      ,p_region_of_birth              => p_region_of_birth
      ,p_country_of_birth             => p_country_of_birth
      ,p_global_person_id             => p_global_person_id
      ,p_party_id                     => p_party_id
      ,p_person_id                    => p_person_id
      ,p_assignment_id                => p_assignment_id
      ,p_per_object_version_number    => p_per_object_version_number
      ,p_asg_object_version_number    => p_asg_object_version_number
      ,p_per_effective_start_date     => p_per_effective_start_date
      ,p_per_effective_end_date       => p_per_effective_end_date
      ,p_full_name                    => p_full_name
      ,p_per_comment_id               => p_per_comment_id
      ,p_assignment_sequence          => p_assignment_sequence
      ,p_assignment_number            => p_assignment_number
      ,p_name_combination_warning     => p_name_combination_warning
      ,p_assign_payroll_warning       => p_assign_payroll_warning
      ,p_orig_hire_warning            => p_orig_hire_warning
  );

  IF g_trace THEN
    hr_utility.set_location('Leaving: '||l_proc, 30);
  END IF ;

END create_in_employee ;
END hr_in_employee_api ;

/
