--------------------------------------------------------
--  DDL for Package Body HR_HK_EMPLOYEE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_HK_EMPLOYEE_API" AS
/* $Header: hrhkwree.pkb 120.2 2005/11/03 02:47:32 sclarke noship $ */
--
  g_package  VARCHAR2(33) := 'hr_hk_employee_api.';
-- -----------------------------------------------------------------------------
-- |-----------------------< create_hk_employee >------------------------------|
-- -----------------------------------------------------------------------------
-- {Start of Comments}
--
--  Description:
--      Calls standard API to create an employee.  Performs mapping of Developer
--      Descriptive Flexfield segments.  No need to include validation for the
--      national identifier as this is now being included as a legislative hook,
--      so the appropriate formula will be called depending on legislation.
--      Ensures appropriate indentification information has been entered ie.
--      national identifier or passport information.
--
--  Pre Conditions:
--
--
--  In Arguments:
--
--
--  Post Success:
--
--
--  Post Failure:
--    A failure can only occur under two circumstances:
--    1) The value of reference field is not supported.
--    2) If when the reference field value is NULL and not all
--       the information arguments are not NULL(i.e. information
--       arguments cannot be set without a corresponding reference
--       field value).
--
--  Developer Implementation Notes:
--    Developer defined.
--
--  Access Status:
--    Internal Development Use Only.
--
--  {End of Comments}
-- -----------------------------------------------------------------------------

PROCEDURE create_hk_employee
  (p_validate                       IN      BOOLEAN  DEFAULT false
  ,p_hire_date                      IN      DATE
  ,p_business_group_id              IN      NUMBER
  ,p_last_name                      IN      VARCHAR2
  ,p_sex                            IN      VARCHAR2
  ,p_person_type_id                 IN      NUMBER   DEFAULT NULL
  ,p_comments                       IN      VARCHAR2 DEFAULT NULL
  ,p_date_employee_data_verified    IN      DATE     DEFAULT NULL
  ,p_date_of_birth                  IN      DATE     DEFAULT NULL
  ,p_email_address                  IN      VARCHAR2 DEFAULT NULL
  ,p_employee_number                IN OUT NOCOPY VARCHAR2
  ,p_expense_check_send_to_addres   IN      VARCHAR2 DEFAULT NULL
  ,p_first_name                     IN      VARCHAR2 DEFAULT NULL
  ,p_known_as                       IN      VARCHAR2 DEFAULT NULL
  ,p_marital_status                 IN      VARCHAR2 DEFAULT NULL
  ,p_middle_names                   IN      VARCHAR2 DEFAULT NULL
  ,p_nationality                    IN      VARCHAR2 DEFAULT NULL
  ,p_hkid_number                    IN      VARCHAR2 DEFAULT NULL
  ,p_previous_last_name             IN      VARCHAR2 DEFAULT NULL
  ,p_registered_disabled_flag       IN      VARCHAR2 DEFAULT NULL
  ,p_title                          IN      VARCHAR2 DEFAULT NULL
  ,p_vendor_id                      IN      NUMBER   DEFAULT NULL
  ,p_work_telephone                 IN      VARCHAR2 DEFAULT NULL
  ,p_attribute_category             IN      VARCHAR2 DEFAULT NULL
  ,p_attribute1                     IN      VARCHAR2 DEFAULT NULL
  ,p_attribute2                     IN      VARCHAR2 DEFAULT NULL
  ,p_attribute3                     IN      VARCHAR2 DEFAULT NULL
  ,p_attribute4                     IN      VARCHAR2 DEFAULT NULL
  ,p_attribute5                     IN      VARCHAR2 DEFAULT NULL
  ,p_attribute6                     IN      VARCHAR2 DEFAULT NULL
  ,p_attribute7                     IN      VARCHAR2 DEFAULT NULL
  ,p_attribute8                     IN      VARCHAR2 DEFAULT NULL
  ,p_attribute9                     IN      VARCHAR2 DEFAULT NULL
  ,p_attribute10                    IN      VARCHAR2 DEFAULT NULL
  ,p_attribute11                    IN      VARCHAR2 DEFAULT NULL
  ,p_attribute12                    IN      VARCHAR2 DEFAULT NULL
  ,p_attribute13                    IN      VARCHAR2 DEFAULT NULL
  ,p_attribute14                    IN      VARCHAR2 DEFAULT NULL
  ,p_attribute15                    IN      VARCHAR2 DEFAULT NULL
  ,p_attribute16                    IN      VARCHAR2 DEFAULT NULL
  ,p_attribute17                    IN      VARCHAR2 DEFAULT NULL
  ,p_attribute18                    IN      VARCHAR2 DEFAULT NULL
  ,p_attribute19                    IN      VARCHAR2 DEFAULT NULL
  ,p_attribute20                    IN      VARCHAR2 DEFAULT NULL
  ,p_attribute21                    IN      VARCHAR2 DEFAULT NULL
  ,p_attribute22                    IN      VARCHAR2 DEFAULT NULL
  ,p_attribute23                    IN      VARCHAR2 DEFAULT NULL
  ,p_attribute24                    IN      VARCHAR2 DEFAULT NULL
  ,p_attribute25                    IN      VARCHAR2 DEFAULT NULL
  ,p_attribute26                    IN      VARCHAR2 DEFAULT NULL
  ,p_attribute27                    IN      VARCHAR2 DEFAULT NULL
  ,p_attribute28                    IN      VARCHAR2 DEFAULT NULL
  ,p_attribute29                    IN      VARCHAR2 DEFAULT NULL
  ,p_attribute30                    IN      VARCHAR2 DEFAULT NULL
  ,p_passport_number                IN      VARCHAR2 DEFAULT NULL
  ,p_country_of_issue               IN      VARCHAR2 DEFAULT NULL
  ,p_work_permit_number             IN      VARCHAR2 DEFAULT NULL
  ,p_work_permit_expiry_date        IN      VARCHAR2 DEFAULT NULL
  ,p_chinese_name                   IN      VARCHAR2 DEFAULT NULL
  ,p_hk_full_name                   IN      VARCHAR2
  ,p_previous_employer_name         IN      VARCHAR2 DEFAULT NULL
  ,p_previous_employer_address      IN      VARCHAR2 DEFAULT NULL
  ,p_employee_tax_file_number       IN      VARCHAR2 DEFAULT NULL
  ,p_date_of_death                  IN      DATE     DEFAULT NULL
  ,p_background_check_status        IN      VARCHAR2 DEFAULT NULL
  ,p_background_date_check          IN      DATE     DEFAULT NULL
  ,p_blood_type                     IN      VARCHAR2 DEFAULT NULL
  ,p_correspondence_language        IN      VARCHAR2 DEFAULT NULL
  ,p_fast_path_employee             IN      VARCHAR2 DEFAULT NULL
  ,p_fte_capacity                   IN      NUMBER   DEFAULT NULL
  ,p_honors                         IN      VARCHAR2 DEFAULT NULL
  ,p_internal_location              IN      VARCHAR2 DEFAULT NULL
  ,p_last_medical_test_by           IN      VARCHAR2 DEFAULT NULL
  ,p_last_medical_test_date         IN      DATE     DEFAULT NULL
  ,p_mailstop                       IN      VARCHAR2 DEFAULT NULL
  ,p_office_number                  IN      VARCHAR2 DEFAULT NULL
  ,p_on_military_service            IN      VARCHAR2 DEFAULT NULL
  ,p_pre_name_adjunct               IN      VARCHAR2 DEFAULT NULL
  ,p_rehire_recommendation          IN      VARCHAR2 DEFAULT NULL
  ,p_projected_start_date           IN      DATE     DEFAULT NULL
  ,p_resume_exists                  IN      VARCHAR2 DEFAULT NULL
  ,p_resume_last_updated            IN      DATE     DEFAULT NULL
  ,p_second_passport_exists         IN      VARCHAR2 DEFAULT NULL
  ,p_student_status                 IN      VARCHAR2 DEFAULT NULL
  ,p_work_schedule                  IN      VARCHAR2 DEFAULT NULL
  ,p_suffix                         IN      VARCHAR2 DEFAULT NULL
  ,p_benefit_group_id               IN      NUMBER   DEFAULT NULL
  ,p_receipt_of_death_cert_date     IN      DATE     DEFAULT NULL
  ,p_coord_ben_med_pln_no           IN      VARCHAR2 DEFAULT NULL
  ,p_coord_ben_no_cvg_flag          IN      VARCHAR2 DEFAULT 'N'
  ,p_coord_ben_med_ext_er           IN      VARCHAR2 DEFAULT NULL
  ,p_coord_ben_med_pl_name          IN      VARCHAR2 DEFAULT NULL
  ,p_coord_ben_med_insr_crr_name    IN      VARCHAR2 DEFAULT NULL
  ,p_coord_ben_med_insr_crr_ident   IN      VARCHAR2 DEFAULT NULL
  ,p_coord_ben_med_cvg_strt_dt      IN      DATE     DEFAULT NULL
  ,p_coord_ben_med_cvg_end_dt       IN      DATE     DEFAULT NULL
  ,p_uses_tobacco_flag              IN      VARCHAR2 DEFAULT NULL
  ,p_dpdnt_adoption_date            IN      DATE     DEFAULT NULL
  ,p_dpdnt_vlntry_svce_flag         IN      VARCHAR2 DEFAULT 'N'
  ,p_original_date_of_hire          IN      DATE     DEFAULT NULL
  ,p_adjusted_svc_date              IN      DATE     DEFAULT NULL
  ,p_town_of_birth                  IN      VARCHAR2 DEFAULT NULL
  ,p_region_of_birth                IN      VARCHAR2 DEFAULT NULL
  ,p_country_of_birth               IN      VARCHAR2 DEFAULT NULL
  ,p_global_person_id               IN      VARCHAR2 DEFAULT NULL
  ,p_party_id                       IN      NUMBER   DEFAULT NULL
  ,p_person_id                      OUT NOCOPY    NUMBER
  ,p_assignment_id                  OUT NOCOPY    NUMBER
  ,p_per_object_version_number      OUT NOCOPY    NUMBER
  ,p_asg_object_version_number      OUT NOCOPY    NUMBER
  ,p_per_effective_start_date       OUT NOCOPY    DATE
  ,p_per_effective_end_date         OUT NOCOPY    DATE
  ,p_full_name                      OUT NOCOPY    VARCHAR2
  ,p_per_comment_id                 OUT NOCOPY    NUMBER
  ,p_assignment_sequence            OUT NOCOPY    NUMBER
  ,p_assignment_number              OUT NOCOPY    VARCHAR2
  ,p_name_combination_warning       OUT NOCOPY    BOOLEAN
  ,p_assign_payroll_warning         OUT NOCOPY    BOOLEAN
  ,p_orig_hire_warning              OUT NOCOPY    BOOLEAN
  )
IS

   -- Declare cursors and local variables
    --
    l_proc                 VARCHAR2(72) := g_package||'create_hk_employee';
    l_legislation_code     VARCHAR2(2);
    l_territory_code       VARCHAR2(2);

    --
    CURSOR csr_bg IS
      SELECT    legislation_code
      FROM      per_business_groups pbg
      WHERE     pbg.business_group_id = p_business_group_id;
    --
  BEGIN
    hr_utility.set_location('Entering:'|| l_proc, 10);
    --
    -- Validation IN addition to Row Handlers
    --
    -- Check that the specified business group is valid.
    --
    OPEN    csr_bg;
    FETCH   csr_bg
    INTO    l_legislation_code;
    IF csr_bg%notfound THEN
      CLOSE csr_bg;
      hr_utility.set_message(801, 'HR_7208_API_BUS_GRP_INVALID');
      hr_utility.raise_error;
    END IF;
    CLOSE csr_bg;
    hr_utility.set_location(l_proc, 20);
    --
    -- Check that the legislation of the specified business group is 'HK'.
    --
    IF l_legislation_code <> 'HK' THEN
      hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
      hr_utility.set_message_token('LEG_CODE','HK');
      hr_utility.raise_error;
    END IF;
    hr_utility.set_location(l_proc, 30);
    --
    -- Call the person business process
    --
    hr_employee_api.create_employee
      (p_validate                     => p_validate
      ,p_hire_date                    => p_hire_date
      ,p_business_group_id            => p_business_group_id
      ,p_last_name                    => p_last_name
      ,p_sex                          => p_sex
      ,p_person_type_id               => p_person_type_id
      ,p_per_comments                 => p_comments
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
      ,p_national_identifier          => p_hkid_number
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
      ,p_per_information_category     => 'HK'
      ,p_per_information1             => p_passport_number
      ,p_per_information2             => p_country_of_issue
      ,p_per_information3             => p_work_permit_number
      ,p_per_information4             => p_work_permit_expiry_date
      ,p_per_information5             => p_chinese_name
      ,p_per_information6             => p_hk_full_name
      ,p_per_information7             => p_previous_employer_name
      ,p_per_information8             => p_previous_employer_address
      ,p_per_information9             => p_employee_tax_file_number
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
      ,p_rehire_recommendation        => p_rehire_recommendation
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
      --
      ,p_town_of_birth                => p_town_of_birth
      ,p_region_of_birth              => p_region_of_birth
      ,p_country_of_birth             => p_country_of_birth
      ,p_global_person_id             => p_global_person_id
      ,p_party_id                     => p_party_id
      --
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
    --
  hr_utility.set_location(' Leaving:'||l_proc, 40);
  --
  END create_hk_employee;

PROCEDURE create_hk_employee
  (p_validate                       IN      BOOLEAN  DEFAULT false
  ,p_hire_date                      IN      DATE
  ,p_business_group_id              IN      NUMBER
  ,p_last_name                      IN      VARCHAR2
  ,p_sex                            IN      VARCHAR2
  ,p_person_type_id                 IN      NUMBER   DEFAULT NULL
  ,p_comments                       IN      VARCHAR2 DEFAULT NULL
  ,p_date_employee_data_verified    IN      DATE     DEFAULT NULL
  ,p_date_of_birth                  IN      DATE     DEFAULT NULL
  ,p_email_address                  IN      VARCHAR2 DEFAULT NULL
  ,p_employee_number                IN OUT NOCOPY VARCHAR2
  ,p_expense_check_send_to_addres   IN      VARCHAR2 DEFAULT NULL
  ,p_first_name                     IN      VARCHAR2 DEFAULT NULL
  ,p_known_as                       IN      VARCHAR2 DEFAULT NULL
  ,p_marital_status                 IN      VARCHAR2 DEFAULT NULL
  ,p_middle_names                   IN      VARCHAR2 DEFAULT NULL
  ,p_nationality                    IN      VARCHAR2 DEFAULT NULL
  ,p_hkid_number                    IN      VARCHAR2 DEFAULT NULL
  ,p_previous_last_name             IN      VARCHAR2 DEFAULT NULL
  ,p_registered_disabled_flag       IN      VARCHAR2 DEFAULT NULL
  ,p_title                          IN      VARCHAR2 DEFAULT NULL
  ,p_vendor_id                      IN      NUMBER   DEFAULT NULL
  ,p_work_telephone                 IN      VARCHAR2 DEFAULT NULL
  ,p_attribute_category             IN      VARCHAR2 DEFAULT NULL
  ,p_attribute1                     IN      VARCHAR2 DEFAULT NULL
  ,p_attribute2                     IN      VARCHAR2 DEFAULT NULL
  ,p_attribute3                     IN      VARCHAR2 DEFAULT NULL
  ,p_attribute4                     IN      VARCHAR2 DEFAULT NULL
  ,p_attribute5                     IN      VARCHAR2 DEFAULT NULL
  ,p_attribute6                     IN      VARCHAR2 DEFAULT NULL
  ,p_attribute7                     IN      VARCHAR2 DEFAULT NULL
  ,p_attribute8                     IN      VARCHAR2 DEFAULT NULL
  ,p_attribute9                     IN      VARCHAR2 DEFAULT NULL
  ,p_attribute10                    IN      VARCHAR2 DEFAULT NULL
  ,p_attribute11                    IN      VARCHAR2 DEFAULT NULL
  ,p_attribute12                    IN      VARCHAR2 DEFAULT NULL
  ,p_attribute13                    IN      VARCHAR2 DEFAULT NULL
  ,p_attribute14                    IN      VARCHAR2 DEFAULT NULL
  ,p_attribute15                    IN      VARCHAR2 DEFAULT NULL
  ,p_attribute16                    IN      VARCHAR2 DEFAULT NULL
  ,p_attribute17                    IN      VARCHAR2 DEFAULT NULL
  ,p_attribute18                    IN      VARCHAR2 DEFAULT NULL
  ,p_attribute19                    IN      VARCHAR2 DEFAULT NULL
  ,p_attribute20                    IN      VARCHAR2 DEFAULT NULL
  ,p_attribute21                    IN      VARCHAR2 DEFAULT NULL
  ,p_attribute22                    IN      VARCHAR2 DEFAULT NULL
  ,p_attribute23                    IN      VARCHAR2 DEFAULT NULL
  ,p_attribute24                    IN      VARCHAR2 DEFAULT NULL
  ,p_attribute25                    IN      VARCHAR2 DEFAULT NULL
  ,p_attribute26                    IN      VARCHAR2 DEFAULT NULL
  ,p_attribute27                    IN      VARCHAR2 DEFAULT NULL
  ,p_attribute28                    IN      VARCHAR2 DEFAULT NULL
  ,p_attribute29                    IN      VARCHAR2 DEFAULT NULL
  ,p_attribute30                    IN      VARCHAR2 DEFAULT NULL
  ,p_passport_number                IN      VARCHAR2 DEFAULT NULL
  ,p_country_of_issue               IN      VARCHAR2 DEFAULT NULL
  ,p_work_permit_number             IN      VARCHAR2 DEFAULT NULL
  ,p_work_permit_expiry_date        IN      VARCHAR2 DEFAULT NULL
  ,p_chinese_name                   IN      VARCHAR2 DEFAULT NULL
  ,p_hk_full_name                   IN      VARCHAR2
  ,p_previous_employer_name         IN      VARCHAR2 DEFAULT NULL
  ,p_previous_employer_address      IN      VARCHAR2 DEFAULT NULL
  ,p_employee_tax_file_number       IN      VARCHAR2 DEFAULT NULL
  ,p_date_of_death                  IN      DATE     DEFAULT NULL
  ,p_background_check_status        IN      VARCHAR2 DEFAULT NULL
  ,p_background_date_check          IN      DATE     DEFAULT NULL
  ,p_blood_type                     IN      VARCHAR2 DEFAULT NULL
  ,p_correspondence_language        IN      VARCHAR2 DEFAULT NULL
  ,p_fast_path_employee             IN      VARCHAR2 DEFAULT NULL
  ,p_fte_capacity                   IN      NUMBER   DEFAULT NULL
  ,p_honors                         IN      VARCHAR2 DEFAULT NULL
  ,p_internal_location              IN      VARCHAR2 DEFAULT NULL
  ,p_last_medical_test_by           IN      VARCHAR2 DEFAULT NULL
  ,p_last_medical_test_date         IN      DATE     DEFAULT NULL
  ,p_mailstop                       IN      VARCHAR2 DEFAULT NULL
  ,p_office_number                  IN      VARCHAR2 DEFAULT NULL
  ,p_on_military_service            IN      VARCHAR2 DEFAULT NULL
  ,p_pre_name_adjunct               IN      VARCHAR2 DEFAULT NULL
  ,p_rehire_recommendation          IN      VARCHAR2 DEFAULT NULL
  ,p_projected_start_date           IN      DATE     DEFAULT NULL
  ,p_resume_exists                  IN      VARCHAR2 DEFAULT NULL
  ,p_resume_last_updated            IN      DATE     DEFAULT NULL
  ,p_second_passport_exists         IN      VARCHAR2 DEFAULT NULL
  ,p_student_status                 IN      VARCHAR2 DEFAULT NULL
  ,p_work_schedule                  IN      VARCHAR2 DEFAULT NULL
  ,p_suffix                         IN      VARCHAR2 DEFAULT NULL
  ,p_benefit_group_id               IN      NUMBER   DEFAULT NULL
  ,p_receipt_of_death_cert_date     IN      DATE     DEFAULT NULL
  ,p_coord_ben_med_pln_no           IN      VARCHAR2 DEFAULT NULL
  ,p_coord_ben_no_cvg_flag          IN      VARCHAR2 DEFAULT 'N'
  ,p_coord_ben_med_ext_er           IN      VARCHAR2 DEFAULT NULL
  ,p_coord_ben_med_pl_name          IN      VARCHAR2 DEFAULT NULL
  ,p_coord_ben_med_insr_crr_name    IN      VARCHAR2 DEFAULT NULL
  ,p_coord_ben_med_insr_crr_ident   IN      VARCHAR2 DEFAULT NULL
  ,p_coord_ben_med_cvg_strt_dt      IN      DATE     DEFAULT NULL
  ,p_coord_ben_med_cvg_end_dt       IN      DATE     DEFAULT NULL
  ,p_uses_tobacco_flag              IN      VARCHAR2 DEFAULT NULL
  ,p_dpdnt_adoption_date            IN      DATE     DEFAULT NULL
  ,p_dpdnt_vlntry_svce_flag         IN      VARCHAR2 DEFAULT 'N'
  ,p_original_date_of_hire          IN      DATE     DEFAULT NULL
  ,p_adjusted_svc_date              IN      DATE     DEFAULT NULL
  ,p_town_of_birth                  IN      VARCHAR2 DEFAULT NULL
  ,p_region_of_birth                IN      VARCHAR2 DEFAULT NULL
  ,p_country_of_birth               IN      VARCHAR2 DEFAULT NULL
  ,p_global_person_id               IN      VARCHAR2 DEFAULT NULL
  ,p_party_id                       IN      NUMBER   DEFAULT NULL
  ,p_person_id                      OUT NOCOPY    NUMBER
  ,p_assignment_id                  OUT NOCOPY    NUMBER
  ,p_per_object_version_number      OUT NOCOPY    NUMBER
  ,p_asg_object_version_number      OUT NOCOPY    NUMBER
  ,p_per_effective_start_date       OUT NOCOPY    DATE
  ,p_per_effective_end_date         OUT NOCOPY    DATE
  ,p_full_name                      OUT NOCOPY    VARCHAR2
  ,p_per_comment_id                 OUT NOCOPY    NUMBER
  ,p_assignment_sequence            OUT NOCOPY    NUMBER
  ,p_assignment_number              OUT NOCOPY    VARCHAR2
  ,p_name_combination_warning       OUT NOCOPY    BOOLEAN
  ,p_assign_payroll_warning         OUT NOCOPY    BOOLEAN
  )
IS

   -- Declare cursors and local variables
    --
    l_proc                 VARCHAR2(72) := g_package||'create_hk_employee';
    l_legislation_code     VARCHAR2(2);
    l_territory_code       VARCHAR2(2);
    l_orig_hire_warning    BOOLEAN      := false;
    --
  BEGIN
    hr_utility.set_location('Entering:'|| l_proc, 10);
    --
    hr_hk_employee_api.create_hk_employee
      (p_validate                     => p_validate
      ,p_hire_date                    => p_hire_date
      ,p_business_group_id            => p_business_group_id
      ,p_last_name                    => p_last_name
      ,p_sex                          => p_sex
      ,p_person_type_id               => p_person_type_id
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
      ,p_hkid_number                  => p_hkid_number
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
      ,p_passport_number              => p_passport_number
      ,p_country_of_issue             => p_country_of_issue
      ,p_work_permit_number           => p_work_permit_number
      ,p_work_permit_expiry_date      => p_work_permit_expiry_date
      ,p_chinese_name                 => p_chinese_name
      ,p_hk_full_name		      => p_hk_full_name
      ,p_previous_employer_name       => p_previous_employer_name
      ,p_previous_employer_address    => p_previous_employer_address
      ,p_employee_tax_file_number     => p_employee_tax_file_number
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
      ,p_rehire_recommendation        => p_rehire_recommendation
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
      --
      ,p_town_of_birth                => p_town_of_birth
      ,p_region_of_birth              => p_region_of_birth
      ,p_country_of_birth             => p_country_of_birth
      ,p_global_person_id             => p_global_person_id
      ,p_party_id                     => p_party_id
      --
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
      ,p_orig_hire_warning            => l_orig_hire_warning
    );
    --
  hr_utility.set_location(' Leaving:'||l_proc, 40);
--
  END create_hk_employee;

END hr_hk_employee_api;

/
