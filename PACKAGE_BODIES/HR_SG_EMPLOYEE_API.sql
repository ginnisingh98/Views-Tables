--------------------------------------------------------
--  DDL for Package Body HR_SG_EMPLOYEE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_SG_EMPLOYEE_API" as
/* $Header: hrsgwree.pkb 120.5 2007/10/26 01:34:44 jalin noship $ */
--
  g_package  varchar2(33) := 'hr_sg_employee_api.';
-- -----------------------------------------------------------------------------
-- |-----------------------< create_sg_employee >------------------------------|
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
--  In Arguments:
--
--  Post Success:
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

procedure create_sg_employee
  (p_validate                       in      boolean  default false
  ,p_hire_date                      in      date
  ,p_business_group_id              in      number
  ,p_last_name                      in      varchar2
  ,p_sex                            in      varchar2
  ,p_person_type_id                 in      number   default null
  ,p_comments                       in      varchar2 default null
  ,p_date_employee_data_verified    in      date     default null
  ,p_date_of_birth                  in      date     default null
  ,p_email_address                  in      varchar2 default null
  ,p_employee_number                in out  nocopy varchar2
  ,p_expense_check_send_to_addres   in      varchar2 default null
  ,p_first_name                     in      varchar2 default null
  ,p_known_as                       in      varchar2 default null
  ,p_marital_status                 in      varchar2 default null
  ,p_middle_names                   in      varchar2 default null
  ,p_nationality                    in      varchar2 default null
  ,p_national_identifier            in      varchar2 default null
  ,p_previous_last_name             in      varchar2 default null
  ,p_registered_disabled_flag       in      varchar2 default null
  ,p_title                          in      varchar2 default null
  ,p_vendor_id                      in      number   default null
  ,p_work_telephone                 in      varchar2 default null
  ,p_attribute_category             in      varchar2 default null
  ,p_attribute1                     in      varchar2 default null
  ,p_attribute2                     in      varchar2 default null
  ,p_attribute3                     in      varchar2 default null
  ,p_attribute4                     in      varchar2 default null
  ,p_attribute5                     in      varchar2 default null
  ,p_attribute6                     in      varchar2 default null
  ,p_attribute7                     in      varchar2 default null
  ,p_attribute8                     in      varchar2 default null
  ,p_attribute9                     in      varchar2 default null
  ,p_attribute10                    in      varchar2 default null
  ,p_attribute11                    in      varchar2 default null
  ,p_attribute12                    in      varchar2 default null
  ,p_attribute13                    in      varchar2 default null
  ,p_attribute14                    in      varchar2 default null
  ,p_attribute15                    in      varchar2 default null
  ,p_attribute16                    in      varchar2 default null
  ,p_attribute17                    in      varchar2 default null
  ,p_attribute18                    in      varchar2 default null
  ,p_attribute19                    in      varchar2 default null
  ,p_attribute20                    in      varchar2 default null
  ,p_attribute21                    in      varchar2 default null
  ,p_attribute22                    in      varchar2 default null
  ,p_attribute23                    in      varchar2 default null
  ,p_attribute24                    in      varchar2 default null
  ,p_attribute25                    in      varchar2 default null
  ,p_attribute26                    in      varchar2 default null
  ,p_attribute27                    in      varchar2 default null
  ,p_attribute28                    in      varchar2 default null
  ,p_attribute29                    in      varchar2 default null
  ,p_attribute30                    in      varchar2 default null
  ,p_legal_name                     in      varchar2
  ,p_passport_number                in      varchar2 default null
  ,p_passport_country_of_issue      in      varchar2 default null
  ,p_passport_date_issued           in      date     default null
  ,p_passport_expiry_date           in      date     default null
  ,p_permit_type                    in      varchar2
  ,p_permit_number                  in      varchar2 default null
  ,p_permit_category                in      varchar2 default null
  ,p_permit_date_issued             in      date     default null
  ,p_permit_expiry_date             in      date     default null
  ,p_permit_date_cancelled          in      date     default null
  ,p_income_tax_number              in      varchar2 default null
  ,p_income_tax_number_spouse       in      varchar2 default null
  ,p_cpf_account_number             in      varchar2 default null
  ,p_nric_colour                    in      varchar2 default null
  ,p_religion                       in      varchar2 default null
  ,p_cpf_category                   in      varchar2 default null
  ,p_race                           in      varchar2 default null
  ,p_community_fund_category        in      varchar2
  ,p_date_of_death                  in      date     default null
  ,p_background_check_status        in      varchar2 default null
  ,p_background_date_check          in      date     default null
  ,p_blood_type                     in      varchar2 default null
  ,p_correspondence_language        in      varchar2 default null
  ,p_fast_path_employee             in      varchar2 default null
  ,p_fte_capacity                   in      number   default null
  ,p_honors                         in      varchar2 default null
  ,p_internal_location              in      varchar2 default null
  ,p_last_medical_test_by           in      varchar2 default null
  ,p_last_medical_test_date         in      date     default null
  ,p_mailstop                       in      varchar2 default null
  ,p_office_number                  in      varchar2 default null
  ,p_on_military_service            in      varchar2 default null
  ,p_pre_name_adjunct               in      varchar2 default null
  ,p_rehire_recommendation          in      varchar2 default null  /* 4595488 */
  ,p_projected_start_date           in      date     default null
  ,p_resume_exists                  in      varchar2 default null
  ,p_resume_last_updated            in      date     default null
  ,p_second_passport_exists         in      varchar2 default null
  ,p_student_status                 in      varchar2 default null
  ,p_work_schedule                  in      varchar2 default null
  ,p_suffix                         in      varchar2 default null
  ,p_benefit_group_id               in      number   default null
  ,p_receipt_of_death_cert_date     in      date     default null
  ,p_coord_ben_med_pln_no           in      varchar2 default null
  ,p_coord_ben_no_cvg_flag          in      varchar2 default 'N'
  ,p_coord_ben_med_ext_er           in      varchar2 default null /* 4595488 */
  ,p_coord_ben_med_pl_name          in      varchar2 default null /* 4595488 */
  ,p_coord_ben_med_insr_crr_name    in      varchar2 default null /* 4595488 */
  ,p_coord_ben_med_insr_crr_ident   in      varchar2 default null /* 4595488 */
  ,p_coord_ben_med_cvg_strt_dt      in      date     default null /* 4595488 */
  ,p_coord_ben_med_cvg_end_dt       in      date     default null /* 4595488 */
  ,p_uses_tobacco_flag              in      varchar2 default null
  ,p_dpdnt_adoption_date            in      date     default null
  ,p_dpdnt_vlntry_svce_flag         in      varchar2 default 'N'
  ,p_original_date_of_hire          in      date     default null
  ,p_adjusted_svc_date              in      date     default null
  ,p_town_of_birth                  in      varchar2 default null
  ,p_region_of_birth                in      varchar2 default null
  ,p_country_of_birth               in      varchar2 default null
  ,p_global_person_id               in      varchar2 default null
  ,p_party_id                       in      number   default null /* 4595488 */
  ,p_payee_id_type                  in      varchar2 default null /* 5435088 */
  ,p_ee_er_rate                     in      varchar2 default null /* 6393528 */
  ,p_mbf                            in      varchar2 default null /* 6393528,6526444 */
  ,p_mdk                            in      varchar2 default null /* 6393528,6526444*/
  ,p_person_id                      out     nocopy number
  ,p_assignment_id                  out     nocopy number
  ,p_per_object_version_number      out     nocopy number
  ,p_asg_object_version_number      out     nocopy number
  ,p_per_effective_start_date       out     nocopy date
  ,p_per_effective_end_date         out     nocopy date
  ,p_full_name                      out     nocopy varchar2
  ,p_per_comment_id                 out     nocopy number
  ,p_assignment_sequence            out     nocopy number
  ,p_assignment_number              out     nocopy varchar2
  ,p_name_combination_warning       out     nocopy boolean
  ,p_assign_payroll_warning         out     nocopy boolean
  ,p_orig_hire_warning              out     nocopy boolean)
is
    -- Declare cursors and local variables
    l_proc                 VARCHAR2(72) := g_package||'create_sg_employee';
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
    -- Check that the legislation of the specified business group is 'SG'.
    --
    IF l_legislation_code <> 'SG' THEN
      hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
      hr_utility.set_message_token('LEG_CODE','SG');
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
      ,p_per_information_category     => 'SG'
      ,p_per_information1             => p_legal_name
      ,p_per_information2             => p_passport_number
      ,p_per_information3             => p_passport_country_of_issue
      ,p_per_information4             => p_passport_date_issued
      ,p_per_information5             => p_passport_expiry_date
      ,p_per_information6             => p_permit_type
      ,p_per_information7             => p_permit_number
      ,p_per_information8             => p_permit_category
      ,p_per_information9             => p_permit_date_issued
      ,p_per_information10            => p_permit_expiry_date
      ,p_per_information11            => p_permit_date_cancelled
      ,p_per_information12            => p_income_tax_number
      ,p_per_information13            => p_income_tax_number_spouse
      ,p_per_information14            => p_cpf_account_number
      ,p_per_information15            => p_nric_colour
      ,p_per_information16            => p_religion
      ,p_per_information17            => p_cpf_category
      ,p_per_information18            => p_race
      ,p_per_information19            => p_community_fund_category
      ,p_per_information20            => p_ee_er_rate /* 6393528 */
      ,p_per_information21            => p_mbf /* 6393528 */
      ,p_per_information22            => p_mdk /* 6393528 */
      ,p_per_information23            => p_payee_id_type
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
      ,p_orig_hire_warning            => p_orig_hire_warning);
    --
  hr_utility.set_location(' Leaving:'||l_proc, 40);
--
  end create_sg_employee;

--
  procedure create_sg_employee
    (p_validate                       in      boolean  default false
    ,p_hire_date                      in      date
    ,p_business_group_id              in      number
    ,p_last_name                      in      varchar2
    ,p_sex                            in      varchar2
    ,p_person_type_id                 in      number   default null
    ,p_comments                       in      varchar2 default null
    ,p_date_employee_data_verified    in      date     default null
    ,p_date_of_birth                  in      date     default null
    ,p_email_address                  in      varchar2 default null
    ,p_employee_number                in out  nocopy varchar2
    ,p_expense_check_send_to_addres   in      varchar2 default null
    ,p_first_name                     in      varchar2 default null
    ,p_known_as                       in      varchar2 default null
    ,p_marital_status                 in      varchar2 default null
    ,p_middle_names                   in      varchar2 default null
    ,p_nationality                    in      varchar2 default null
    ,p_national_identifier            in      varchar2 default null
    ,p_previous_last_name             in      varchar2 default null
    ,p_registered_disabled_flag       in      varchar2 default null
    ,p_title                          in      varchar2 default null
    ,p_vendor_id                      in      number   default null
    ,p_work_telephone                 in      varchar2 default null
    ,p_attribute_category             in      varchar2 default null
    ,p_attribute1                     in      varchar2 default null
    ,p_attribute2                     in      varchar2 default null
    ,p_attribute3                     in      varchar2 default null
    ,p_attribute4                     in      varchar2 default null
    ,p_attribute5                     in      varchar2 default null
    ,p_attribute6                     in      varchar2 default null
    ,p_attribute7                     in      varchar2 default null
    ,p_attribute8                     in      varchar2 default null
    ,p_attribute9                     in      varchar2 default null
    ,p_attribute10                    in      varchar2 default null
    ,p_attribute11                    in      varchar2 default null
    ,p_attribute12                    in      varchar2 default null
    ,p_attribute13                    in      varchar2 default null
    ,p_attribute14                    in      varchar2 default null
    ,p_attribute15                    in      varchar2 default null
    ,p_attribute16                    in      varchar2 default null
    ,p_attribute17                    in      varchar2 default null
    ,p_attribute18                    in      varchar2 default null
    ,p_attribute19                    in      varchar2 default null
    ,p_attribute20                    in      varchar2 default null
    ,p_attribute21                    in      varchar2 default null
    ,p_attribute22                    in      varchar2 default null
    ,p_attribute23                    in      varchar2 default null
    ,p_attribute24                    in      varchar2 default null
    ,p_attribute25                    in      varchar2 default null
    ,p_attribute26                    in      varchar2 default null
    ,p_attribute27                    in      varchar2 default null
    ,p_attribute28                    in      varchar2 default null
    ,p_attribute29                    in      varchar2 default null
    ,p_attribute30                    in      varchar2 default null
    ,p_legal_name                     in      varchar2
    ,p_passport_number                in      varchar2 default null
    ,p_passport_country_of_issue      in      varchar2 default null
    ,p_passport_date_issued           in      date     default null
    ,p_passport_expiry_date           in      date     default null
    ,p_permit_type                    in      varchar2
    ,p_permit_number                  in      varchar2 default null
    ,p_permit_category                in      varchar2 default null
    ,p_permit_date_issued             in      date     default null
    ,p_permit_expiry_date             in      date     default null
    ,p_permit_date_cancelled          in      date     default null
    ,p_income_tax_number              in      varchar2 default null
    ,p_income_tax_number_spouse       in      varchar2 default null
    ,p_cpf_account_number             in      varchar2 default null
    ,p_nric_colour                    in      varchar2 default null
    ,p_religion                       in      varchar2 default null
    ,p_cpf_category                   in      varchar2 default null
    ,p_race                           in      varchar2 default null
    ,p_community_fund_category        in      varchar2
    ,p_date_of_death                  in      date     default null
    ,p_background_check_status        in      varchar2 default null
    ,p_background_date_check          in      date     default null
    ,p_blood_type                     in      varchar2 default null
    ,p_correspondence_language        in      varchar2 default null
    ,p_fast_path_employee             in      varchar2 default null
    ,p_fte_capacity                   in      number   default null
    ,p_honors                         in      varchar2 default null
    ,p_internal_location              in      varchar2 default null
    ,p_last_medical_test_by           in      varchar2 default null
    ,p_last_medical_test_date         in      date     default null
    ,p_mailstop                       in      varchar2 default null
    ,p_office_number                  in      varchar2 default null
    ,p_on_military_service            in      varchar2 default null
    ,p_pre_name_adjunct               in      varchar2 default null
    ,p_rehire_recommendation          in      varchar2 default null
    ,p_projected_start_date           in      date     default null
    ,p_resume_exists                  in      varchar2 default null
    ,p_resume_last_updated            in      date     default null
    ,p_second_passport_exists         in      varchar2 default null
    ,p_student_status                 in      varchar2 default null
    ,p_work_schedule                  in      varchar2 default null
    ,p_suffix                         in      varchar2 default null
    ,p_benefit_group_id               in      number   default null
    ,p_receipt_of_death_cert_date     in      date     default null
    ,p_coord_ben_med_pln_no           in      varchar2 default null
    ,p_coord_ben_no_cvg_flag          in      varchar2 default 'N'
    ,p_coord_ben_med_ext_er           in      varchar2 default null
    ,p_coord_ben_med_pl_name          in      varchar2 default null
    ,p_coord_ben_med_insr_crr_name    in      varchar2 default null
    ,p_coord_ben_med_insr_crr_ident   in      varchar2 default null
    ,p_coord_ben_med_cvg_strt_dt      in      date     default null
    ,p_coord_ben_med_cvg_end_dt       in      date     default null
    ,p_uses_tobacco_flag              in      varchar2 default null
    ,p_dpdnt_adoption_date            in      date     default null
    ,p_dpdnt_vlntry_svce_flag         in      varchar2 default 'N'
    ,p_original_date_of_hire          in      date     default null
    ,p_adjusted_svc_date              in      date     default null
    ,p_town_of_birth                  in      varchar2 default null
    ,p_region_of_birth                in      varchar2 default null
    ,p_country_of_birth               in      varchar2 default null
    ,p_global_person_id               in      varchar2 default null
    ,p_party_id                       in      number   default null
    ,p_payee_id_type                  in      varchar2 default null
    ,p_ee_er_rate                     in      varchar2 default null
    ,p_mbf                            in      varchar2 default null
    ,p_mdk                            in      varchar2 default null
    ,p_person_id                      out     nocopy number
    ,p_assignment_id                  out     nocopy number
    ,p_per_object_version_number      out     nocopy number
    ,p_asg_object_version_number      out     nocopy number
    ,p_per_effective_start_date       out     nocopy date
    ,p_per_effective_end_date         out     nocopy date
    ,p_full_name                      out     nocopy varchar2
    ,p_per_comment_id                 out     nocopy number
    ,p_assignment_sequence            out     nocopy number
    ,p_assignment_number              out     nocopy varchar2
    ,p_name_combination_warning       out     nocopy boolean
    ,p_assign_payroll_warning         out     nocopy boolean
    )
is
    -- Declare local variables
    --
    l_proc                 VARCHAR2(72);
    l_orig_hire_warning    BOOLEAN;
    --
  begin
    l_proc                 := g_package||'create_sg_employee';
    l_orig_hire_warning    := false;
    hr_utility.set_location('Entering:'|| l_proc, 10);
    --
    hr_sg_employee_api.create_sg_employee
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
      ,p_legal_name                   => p_legal_name
      ,p_passport_number              => p_passport_number
      ,p_passport_country_of_issue    => p_passport_country_of_issue
      ,p_passport_date_issued         => p_passport_date_issued
      ,p_passport_expiry_date         => p_passport_expiry_date
      ,p_permit_type                  => p_permit_type
      ,p_permit_number                => p_permit_number
      ,p_permit_category              => p_permit_category
      ,p_permit_date_issued           => p_permit_date_issued
      ,p_permit_expiry_date           => p_permit_expiry_date
      ,p_permit_date_cancelled        => p_permit_date_cancelled
      ,p_income_tax_number            => p_income_tax_number
      ,p_income_tax_number_spouse     => p_income_tax_number_spouse
      ,p_cpf_account_number           => p_cpf_account_number
      ,p_nric_colour                  => p_nric_colour
      ,p_religion                     => p_religion
      ,p_cpf_category                 => p_cpf_category
      ,p_race                         => p_race
      ,p_community_fund_category      => p_community_fund_category
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
      ,p_town_of_birth                => p_town_of_birth
      ,p_region_of_birth              => p_region_of_birth
      ,p_country_of_birth             => p_country_of_birth
      ,p_global_person_id             => p_global_person_id
      ,p_party_id                     => p_party_id
      ,p_payee_id_type                => p_payee_id_type
      ,p_ee_er_rate                   => p_ee_er_rate /* 6393528 */
      ,p_mbf                          => p_mbf /* 6393528 */
      ,p_mdk                          => p_mdk /* 6393528 */
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
  hr_utility.set_location(' Leaving:'||l_proc, 40);
  --
  end create_sg_employee;

end hr_sg_employee_api;

/
