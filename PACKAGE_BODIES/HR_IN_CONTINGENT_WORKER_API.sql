--------------------------------------------------------
--  DDL for Package Body HR_IN_CONTINGENT_WORKER_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_IN_CONTINGENT_WORKER_API" as
/* $Header: pecwkini.pkb 120.0 2005/05/31 07:25 appldev noship $ */
--
	-- Package Variables
	g_package  varchar2(33) ;

--
-- ----------------------------------------------------------------------------
-- |------------------------------< create_cwk >------------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_in_cwk
  (p_validate                      IN     BOOLEAN  DEFAULT FALSE
  ,p_start_date                    IN     DATE
  ,p_business_group_id             IN     NUMBER
  ,p_last_name                     IN     VARCHAR2
  ,p_person_type_id                IN     NUMBER   DEFAULT NULL
  ,p_npw_number                    IN OUT NOCOPY VARCHAR2
  ,p_background_check_status       IN     VARCHAR2 DEFAULT NULL
  ,p_background_date_check         IN     DATE     DEFAULT NULL
  ,p_blood_type                    IN     VARCHAR2 DEFAULT NULL
  ,p_comments                      IN     VARCHAR2 DEFAULT NULL
  ,p_correspondence_language       IN     VARCHAR2 DEFAULT NULL
  ,p_country_of_birth              IN     VARCHAR2 DEFAULT NULL
  ,p_date_of_birth                 IN     DATE     DEFAULT NULL
  ,p_date_of_death                 IN     DATE     DEFAULT NULL
  ,p_dpdnt_adoption_date           IN     DATE     DEFAULT NULL
  ,p_dpdnt_vlntry_svce_flag        IN     VARCHAR2 DEFAULT NULL
  ,p_email_address                 IN     VARCHAR2 DEFAULT NULL
  ,p_first_name                    IN     VARCHAR2 DEFAULT NULL
  ,p_fte_capacity                  IN     NUMBER   DEFAULT NULL
  ,p_honors                        IN     VARCHAR2 DEFAULT NULL
  ,p_internal_location             IN     VARCHAR2 DEFAULT NULL
  ,p_alias_name                    IN     VARCHAR2 DEFAULT NULL
  ,p_last_medical_test_by          IN     VARCHAR2 DEFAULT NULL
  ,p_last_medical_test_date        IN     DATE     DEFAULT NULL
  ,p_mailstop                      IN     VARCHAR2 DEFAULT NULL
  ,p_marital_status                IN     VARCHAR2 DEFAULT NULL
  ,p_middle_name                   IN     VARCHAR2 DEFAULT NULL
  ,p_national_identifier           IN     VARCHAR2 DEFAULT NULL
  ,p_nationality                   IN     VARCHAR2 DEFAULT NULL
  ,p_office_number                 IN     VARCHAR2 DEFAULT NULL
  ,p_on_military_service           IN     VARCHAR2 DEFAULT NULL
  ,p_party_id                      IN     NUMBER   DEFAULT NULL
  ,p_pre_name_adjunct              IN     VARCHAR2 DEFAULT NULL
  ,p_previous_last_name            IN     VARCHAR2 DEFAULT NULL
  ,p_projected_placement_end       IN     DATE     DEFAULT NULL
  ,p_receipt_of_death_cert_date    IN     DATE     DEFAULT NULL
  ,p_region_of_birth               IN     VARCHAR2 DEFAULT NULL
  ,p_registered_disabled_flag      IN     VARCHAR2 DEFAULT NULL
  ,p_resume_exists                 IN     VARCHAR2 DEFAULT NULL
  ,p_resume_last_updated           IN     DATE     DEFAULT NULL
  ,p_second_passport_exists        IN     VARCHAR2 DEFAULT NULL
  ,p_sex                           IN     VARCHAR2 DEFAULT NULL
  ,p_student_status                IN     VARCHAR2 DEFAULT NULL
  ,p_suffix                        IN     VARCHAR2 DEFAULT NULL
  ,p_title                         IN     VARCHAR2 DEFAULT NULL
  ,p_place_of_birth                IN     VARCHAR2 DEFAULT NULL
  ,p_uses_tobacco_flag             IN     VARCHAR2 DEFAULT NULL
  ,p_vendor_id                     IN     NUMBER   DEFAULT NULL
  ,p_work_schedule                 IN     VARCHAR2 DEFAULT NULL
  ,p_work_telephone                IN     VARCHAR2 DEFAULT NULL
  ,p_exp_check_send_to_address     IN     VARCHAR2 DEFAULT NULL
  ,p_hold_applicant_date_until     IN     DATE     DEFAULT NULL
  ,p_date_employee_data_verified   IN     DATE     DEFAULT NULL
  ,p_benefit_group_id              IN     NUMBER   DEFAULT NULL
  ,p_coord_ben_med_pln_no          IN     VARCHAR2 DEFAULT NULL
  ,p_coord_ben_no_cvg_flag         IN     VARCHAR2 DEFAULT NULL
  ,p_original_date_of_hire         IN     DATE     DEFAULT NULL
  ,p_attribute_category            IN     VARCHAR2 DEFAULT NULL
  ,p_attribute1                    IN     VARCHAR2 DEFAULT NULL
  ,p_attribute2                    IN     VARCHAR2 DEFAULT NULL
  ,p_attribute3                    IN     VARCHAR2 DEFAULT NULL
  ,p_attribute4                    IN     VARCHAR2 DEFAULT NULL
  ,p_attribute5                    IN     VARCHAR2 DEFAULT NULL
  ,p_attribute6                    IN     VARCHAR2 DEFAULT NULL
  ,p_attribute7                    IN     VARCHAR2 DEFAULT NULL
  ,p_attribute8                    IN     VARCHAR2 DEFAULT NULL
  ,p_attribute9                    IN     VARCHAR2 DEFAULT NULL
  ,p_attribute10                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute11                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute12                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute13                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute14                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute15                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute16                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute17                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute18                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute19                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute20                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute21                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute22                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute23                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute24                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute25                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute26                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute27                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute28                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute29                   IN     VARCHAR2 DEFAULT NULL
  ,p_attribute30                   IN     VARCHAR2 DEFAULT NULL
  ,p_pan                           IN     VARCHAR2 DEFAULT NULL
  ,p_pan_af                        IN     VARCHAR2 DEFAULT NULL
  ,p_ex_serviceman                 IN     VARCHAR2 DEFAULT NULL
  ,p_resident_status               IN     VARCHAR2 DEFAULT NULL
  ,p_pf_number                     IN     VARCHAR2 DEFAULT NULL
  ,p_esi_number                    IN     VARCHAR2 DEFAULT NULL
  ,p_superannuation_number         IN     VARCHAR2 DEFAULT NULL
  ,p_gi_number                     IN     VARCHAR2 DEFAULT NULL
  ,p_gratuity_number               IN     VARCHAR2 DEFAULT NULL
  ,p_pension_number                IN     VARCHAR2 DEFAULT NULL
  ,p_person_id                        OUT NOCOPY   NUMBER
  ,p_per_object_version_number        OUT NOCOPY   NUMBER
  ,p_per_effective_start_date         OUT NOCOPY   DATE
  ,p_per_effective_end_date           OUT NOCOPY   DATE
  ,p_pdp_object_version_number        OUT NOCOPY   NUMBER
  ,p_full_name                        OUT NOCOPY   VARCHAR2
  ,p_comment_id                       OUT NOCOPY   NUMBER
  ,p_assignment_id                    OUT NOCOPY   NUMBER
  ,p_asg_object_version_number        OUT NOCOPY   NUMBER
  ,p_assignment_sequence              OUT NOCOPY   NUMBER
  ,p_assignment_number                OUT NOCOPY   VARCHAR2
  ,p_name_combination_warning         OUT NOCOPY   BOOLEAN
  )  is

  l_proc                 VARCHAR2(72) ;
  g_trace                BOOLEAN;
  l_pension_number       per_all_people_f.per_information13%TYPE;
  --

BEGIN
 g_package := '  hr_in_contingent_worker_api.';
 l_proc  := g_package||'create_in_cwk';
 g_trace := hr_utility.debug_enabled ;

  IF g_trace THEN
    hr_utility.set_location('Entering: '||l_proc, 10);
  END IF ;

  IF  hr_general2.IS_BG(p_business_group_id, 'IN') = FALSE THEN
    hr_utility.set_message(800, 'HR_7208_API_BUS_GRP_INVALID');
    hr_utility.raise_error;
  END IF;

  IF g_trace THEN
     hr_utility.set_location(l_proc, 20);
  END IF ;


  l_pension_number :=p_pension_number;

  IF p_pension_number IS NULL THEN
    l_pension_number :=p_pf_number;
  END IF;

hr_contingent_worker_api.create_cwk
  (p_validate                      => p_validate
  ,p_start_date                    => p_start_date
  ,p_business_group_id             => p_business_group_id
  ,p_last_name                     => p_last_name
  ,p_person_type_id                => p_person_type_id
  ,p_npw_number                    => p_npw_number
  ,p_background_check_status       => p_background_check_status
  ,p_background_date_check         => p_background_date_check
  ,p_blood_type                    => p_blood_type
  ,p_comments                      => p_comments
  ,p_correspondence_language       => p_correspondence_language
  ,p_country_of_birth              => p_country_of_birth
  ,p_date_of_birth                 => p_date_of_birth
  ,p_date_of_death                 => p_date_of_death
  ,p_dpdnt_adoption_date           => p_dpdnt_adoption_date
  ,p_dpdnt_vlntry_svce_flag        => p_dpdnt_vlntry_svce_flag
  ,p_email_address                 => p_email_address
  ,p_first_name                    => p_first_name
  ,p_fte_capacity                  => p_fte_capacity
  ,p_honors                        => p_honors
  ,p_internal_location             => p_internal_location
  ,p_known_as                      => p_alias_name
  ,p_last_medical_test_by          => p_last_medical_test_by
  ,p_last_medical_test_date        => p_last_medical_test_date
  ,p_mailstop                      => p_mailstop
  ,p_marital_status                => p_marital_status
  ,p_middle_names                  => p_middle_name
  ,p_national_identifier           => p_national_identifier
  ,p_nationality                   => p_nationality
  ,p_office_number                 => p_office_number
  ,p_on_military_service           => p_on_military_service
  ,p_party_id                      => p_party_id
  ,p_pre_name_adjunct              => p_pre_name_adjunct
  ,p_previous_last_name            => p_previous_last_name
  ,p_projected_placement_end       => p_projected_placement_end
  ,p_receipt_of_death_cert_date    => p_receipt_of_death_cert_date
  ,p_region_of_birth               => p_region_of_birth
  ,p_registered_disabled_flag      => p_registered_disabled_flag
  ,p_resume_exists                 => p_resume_exists
  ,p_resume_last_updated           => p_resume_last_updated
  ,p_second_passport_exists        => p_second_passport_exists
  ,p_sex                           => p_sex
  ,p_student_status                => p_student_status
  ,p_title                         => p_title
  ,p_town_of_birth                 => p_place_of_birth
  ,p_uses_tobacco_flag             => p_uses_tobacco_flag
  ,p_vendor_id                     => p_vendor_id
  ,p_work_schedule                 => p_work_schedule
  ,p_work_telephone                => p_work_telephone
  ,p_exp_check_send_to_address     => p_exp_check_send_to_address
  ,p_hold_applicant_date_until     => p_hold_applicant_date_until
  ,p_date_employee_data_verified   => p_date_employee_data_verified
  ,p_benefit_group_id              => p_benefit_group_id
  ,p_coord_ben_med_pln_no          => p_coord_ben_med_pln_no
  ,p_coord_ben_no_cvg_flag         => p_coord_ben_no_cvg_flag
  ,p_original_date_of_hire         => p_original_date_of_hire
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
  ,p_per_information_category      => 'IN'
  ,p_per_information4          	   => p_pan
  ,p_per_information5              => p_pan_af
  ,p_per_information6              => p_ex_serviceman
  ,p_per_information7              => p_resident_status
  ,p_per_information8              => p_pf_number
  ,p_per_information9          	   => p_esi_number
  ,p_per_information10             => p_superannuation_number
  ,p_per_information11             => p_gi_number
  ,p_per_information12             => p_gratuity_number
  ,p_per_information13             => l_pension_number
  ,p_person_id                     => p_person_id
  ,p_per_object_version_number     => p_per_object_version_number
  ,p_per_effective_start_date      => p_per_effective_start_date
  ,p_per_effective_end_date        => p_per_effective_end_date
  ,p_pdp_object_version_number     => p_pdp_object_version_number
  ,p_full_name                     => p_full_name
  ,p_comment_id                    => p_comment_id
  ,p_assignment_id                 => p_assignment_id
  ,p_asg_object_version_number     => p_asg_object_version_number
  ,p_assignment_sequence           => p_assignment_sequence
  ,p_assignment_number             => p_assignment_number
  ,p_name_combination_warning      => p_name_combination_warning
  );

  --
 IF g_trace THEN
  hr_utility.set_location(' Leaving:'||l_proc, 7);
 END IF;
  --

END create_in_cwk;
END hr_in_contingent_worker_api;

/
