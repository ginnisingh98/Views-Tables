--------------------------------------------------------
--  DDL for Package Body HR_NZ_PERSON_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_NZ_PERSON_API" AS
/* $Header: hrnzwrup.pkb 120.2 2005/10/06 05:07:30 rpalli noship $ */
  --
  -- Package Variables
  --
  g_package  varchar2(33) := 'hr_nz_person_api.';


  ------------------------------------------------------------
  -- Private Procedures
  ------------------------------------------------------------


  ------------------------------------------------------------
  --  Private Functions
  ------------------------------------------------------------

  ------------------------------------------------------------
  -- Public Procedures
  ------------------------------------------------------------

  -- update_nz_person

  PROCEDURE update_nz_person
  	(p_validate                     IN      BOOLEAN   DEFAULT FALSE
  	,p_effective_date               IN      DATE
  	,p_datetrack_update_mode        IN      VARCHAR2
  	,p_person_id                    IN      NUMBER
  	,p_object_version_number        IN OUT NOCOPY NUMBER
  	,p_person_type_id               IN      NUMBER   DEFAULT hr_api.g_number
  	,p_last_name                    IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_applicant_number             IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_comments                     IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_date_employee_data_verified  IN      DATE     DEFAULT hr_api.g_date
  	,p_date_of_birth                IN      DATE     DEFAULT hr_api.g_date
  	,p_email_address                IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_employee_number              IN OUT NOCOPY VARCHAR2
  	,p_expense_check_send_to_addres IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_first_name                   IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_known_as                     IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_marital_status               IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_middle_names                 IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_nationality                  IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_ird_number                   IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_previous_last_name           IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_registered_disabled_flag     IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_sex                          IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_title                        IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_vendor_id                    IN      NUMBER   DEFAULT hr_api.g_number
  	,p_work_telephone               IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_attribute_category           IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_attribute1                   IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_attribute2                   IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_attribute3                   IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_attribute4                   IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_attribute5                   IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_attribute6                   IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_attribute7                   IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_attribute8                   IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_attribute9                   IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_attribute10                  IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_attribute11                  IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_attribute12                  IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_attribute13                  IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_attribute14                  IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_attribute15                  IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_attribute16                  IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_attribute17                  IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_attribute18                  IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_attribute19                  IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_attribute20                  IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_attribute21                  IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_attribute22                  IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_attribute23                  IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_attribute24                  IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_attribute25                  IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_attribute26                  IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_attribute27                  IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_attribute28                  IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_attribute29                  IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_attribute30                  IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_country_born                 IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_work_permit_number           IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_work_permit_expiry_date      IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_ethnic_origin            	IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_tribal_group                 IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_district_of_origin           IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_employment_category          IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_working_time                 IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_date_of_death                IN      DATE     DEFAULT hr_api.g_date
  	,p_background_check_status      IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_background_date_check        IN      DATE     DEFAULT hr_api.g_date
  	,p_blood_type                   IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_correspondence_language      IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_fast_path_employee           IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_fte_capacity                 IN      NUMBER   DEFAULT hr_api.g_number
  	,p_hold_applicant_date_until    IN      DATE     DEFAULT hr_api.g_date
  	,p_honors                       IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_internal_location            IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_last_medical_test_by         IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_last_medical_test_date       IN      DATE     DEFAULT hr_api.g_date
  	,p_mailstop                     IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_office_number                IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_on_military_service          IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_pre_name_adjunct             IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_projected_start_date         IN      DATE     DEFAULT hr_api.g_date
  	,p_rehire_authorizor            IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_rehire_recommendation        IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_resume_exists                IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_resume_last_updated          IN      DATE     DEFAULT hr_api.g_date
  	,p_second_passport_exists       IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_student_status               IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_work_schedule                IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_rehire_reason                IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  	,p_suffix                       IN      VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_benefit_group_id             in      number   default hr_api.g_number
  ,p_receipt_of_death_cert_date   in      date     default hr_api.g_date
  ,p_coord_ben_med_pln_no         in      VARCHAR2 default hr_api.g_varchar2
  ,p_coord_ben_no_cvg_flag        in      varchar2 default hr_api.g_varchar2
  ,p_coord_ben_med_ext_er         in      varchar2 default hr_api.g_varchar2
  ,p_coord_ben_med_pl_name        in      varchar2 default hr_api.g_varchar2
  ,p_coord_ben_med_insr_crr_name  in      varchar2 default hr_api.g_varchar2
  ,p_coord_ben_med_insr_crr_ident in      varchar2 default hr_api.g_varchar2
  ,p_coord_ben_med_cvg_strt_dt    in      date     default hr_api.g_date
  ,p_coord_ben_med_cvg_end_dt     in      date     default hr_api.g_date
  ,p_uses_tobacco_flag            in      varchar2 default hr_api.g_varchar2
  ,p_dpdnt_adoption_date          in      date     default hr_api.g_date
  ,p_dpdnt_vlntry_svce_flag       in      varchar2 default hr_api.g_varchar2
  ,p_original_date_of_hire        in      date     default hr_api.g_date
  ,p_adjusted_svc_date            in      date     default hr_api.g_date
  ,p_town_of_birth                in      varchar2 default hr_api.g_varchar2
  ,p_region_of_birth              in      varchar2 default hr_api.g_varchar2
  ,p_country_of_birth             in      varchar2 default hr_api.g_varchar2
  ,p_global_person_id             in      varchar2 default hr_api.g_varchar2
  ,p_party_id                     in      number   default hr_api.g_number
  ,p_npw_number                   in      varchar2 default hr_api.g_varchar2
  	,p_effective_start_date         OUT NOCOPY    DATE
  	,p_effective_end_date           OUT NOCOPY    DATE
  	,p_full_name                    OUT NOCOPY    VARCHAR2
  	,p_comment_id                   OUT NOCOPY    NUMBER
  	,p_name_combination_warning     OUT NOCOPY    BOOLEAN
  	,p_assign_payroll_warning       OUT NOCOPY    BOOLEAN
  	,p_orig_hire_warning            OUT NOCOPY    BOOLEAN
  	)
	IS
  	--
  	-- Declare cursors and local variables
  	--

  	l_proc                 VARCHAR2(72) := g_package||'update_nz_person';
  	l_effective_date       DATE;
  	l_legislation_code     per_business_groups.legislation_code%TYPE;
  	l_discard_varchar2     VARCHAR2(30);
  	--
  	CURSOR check_legislation
  	  (c_person_id      per_people_f.person_id%TYPE,
  	   c_effective_date DATE
  	  )
  	IS
	SELECT bgp.legislation_code
    FROM per_people_f per,
         per_business_groups bgp
    WHERE per.business_group_id = bgp.business_group_id
    AND   per.person_id     	= c_person_id
    AND   c_effective_date
    BETWEEN per.effective_start_date and per.effective_end_date;
  --
BEGIN
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Initialise local variables
  --
  l_effective_date := TRUNC(p_effective_date);
  --
  -- Validation in addition to Row Handlers
  --
  -- Check that the person exists.
  --
  OPEN check_legislation(p_person_id, l_effective_date);
  FETCH check_legislation into l_legislation_code;
  IF (check_legislation%NOTFOUND) THEN
    CLOSE check_legislation;
    hr_utility.set_message(801,'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  END IF;
  CLOSE check_legislation;
  hr_utility.set_location(l_proc, 20);
  --
  -- Check that the legislation of the specified business group is 'GB'.
  --
  IF (l_legislation_code <> 'NZ') THEN
    hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
    hr_utility.set_message_token('LEG_CODE','NZ');
    hr_utility.raise_error;
  END IF;
  hr_utility.set_location(l_proc, 30);
  --
  -- Update the person record using the update_person BP
  --
  hr_person_api.update_person
  (p_validate                     => p_validate
  ,p_effective_date               => l_effective_date
  ,p_datetrack_update_mode        => p_datetrack_update_mode
  ,p_person_id                    => p_person_id
  ,p_object_version_number        => p_object_version_number
  ,p_person_type_id               => p_person_type_id
  ,p_last_name                    => p_last_name
  ,p_applicant_number             => p_applicant_number
  ,p_comments                     => p_comments
  ,p_date_employee_data_verified  => p_date_employee_data_verified
  ,p_date_of_birth                => p_date_of_birth
  ,p_email_address                => p_email_address
  ,p_employee_number              => p_employee_number
  ,p_expense_check_send_to_addres => p_expense_check_send_to_addres
  ,p_first_name                   => p_first_name
  ,p_known_as                     => p_known_as
  ,p_marital_status               => p_marital_status
  ,p_middle_names                 => p_middle_names
  ,p_nationality                  => p_nationality
  ,p_national_identifier          => p_ird_number
  ,p_previous_last_name           => p_previous_last_name
  ,p_registered_disabled_flag     => p_registered_disabled_flag
  ,p_sex                          => p_sex
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
  ,p_per_information_category     => 'NZ'
  ,p_country_of_birth             => p_country_born
  ,p_per_information2             => p_work_permit_number
  ,p_per_information3             => p_work_permit_expiry_date
  ,p_per_information4             => p_ethnic_origin
  ,p_per_information5             => p_tribal_group
  ,p_per_information6             => p_district_of_origin
  ,p_per_information7             => p_employment_category
  ,p_per_information8             => p_working_time
  ,p_date_of_death                => p_date_of_death
  ,p_background_check_status      => p_background_check_status
  ,p_background_date_check        => p_background_date_check
  ,p_blood_type                   => p_blood_type
  ,p_correspondence_language      => p_correspondence_language
  ,p_fast_path_employee           => p_fast_path_employee
  ,p_fte_capacity                 => p_fte_capacity
  ,p_hold_applicant_date_until    => p_hold_applicant_date_until
  ,p_honors                       => p_honors
  ,p_internal_location            => p_internal_location
  ,p_last_medical_test_by         => p_last_medical_test_by
  ,p_last_medical_test_date       => p_last_medical_test_date
  ,p_mailstop                     => p_mailstop
  ,p_office_number                => p_office_number
  ,p_on_military_service          => p_on_military_service
  ,p_pre_name_adjunct             => p_pre_name_adjunct
  ,p_projected_start_date         => p_projected_start_date
  ,p_rehire_authorizor            => p_rehire_authorizor
  ,p_rehire_recommendation        => p_rehire_recommendation
  ,p_resume_exists                => p_resume_exists
  ,p_resume_last_updated          => p_resume_last_updated
  ,p_second_passport_exists       => p_second_passport_exists
  ,p_student_status               => p_student_status
  ,p_work_schedule                => p_work_schedule
  ,p_rehire_reason                => p_rehire_reason
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
  ,p_town_of_birth                => p_town_of_birth
  ,p_region_of_birth              => p_region_of_birth
  ,p_global_person_id             => p_global_person_id
  ,p_party_id                     => p_party_id
  ,p_npw_number                   => p_npw_number
  ,p_effective_start_date         => p_effective_start_date
  ,p_effective_end_date           => p_effective_end_date
  ,p_full_name                    => p_full_name
  ,p_comment_id                   => p_comment_id
  ,p_name_combination_warning     => p_name_combination_warning
  ,p_assign_payroll_warning       => p_assign_payroll_warning
  ,p_orig_hire_warning            => p_orig_hire_warning
  );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 7);
  --
  END update_nz_person;
END hr_nz_person_api;

/
