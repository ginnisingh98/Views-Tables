--------------------------------------------------------
--  DDL for Package Body HR_PL_CONTACT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PL_CONTACT_API" as
/* $Header: peconpli.pkb 120.2 2005/09/22 03:57:56 mseshadr noship $ */
--
-- Package Variables
--
g_package  CONSTANT varchar2(33) := 'hr_pl_contact_api.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_pl_person > --------------------------|
-- ----------------------------------------------------------------------------

procedure create_pl_person
  (p_validate                      in     boolean  default false
  ,p_start_date                    in     date
  ,p_business_group_id             in     number
  ,p_last_name                     in     varchar2
  ,p_sex                           in     varchar2
  ,p_person_type_id                in     number   default null
  ,p_comments                      in     varchar2 default null
  ,p_date_employee_data_verified   in     date     default null
  ,p_date_of_birth                 in     date     default null
  ,p_email_address                 in     varchar2 default null
  ,p_expense_check_send_to_addres  in     varchar2 default null
  ,p_first_name                    in     varchar2 default null
  ,p_known_as                      in     varchar2 default null
  ,p_marital_status                in     varchar2 default null
  ,p_middle_names                  in     varchar2 default null
  ,p_nationality                   in     varchar2 default null
  ,p_inn		           in     varchar2 default null
  ,p_previous_last_name            in     varchar2 default null
  ,p_registered_disabled_flag      in     varchar2 default null
  ,p_title                         in     varchar2 default null
  ,p_vendor_id                     in     number   default null
  ,p_work_telephone                in     varchar2 default null
  ,p_attribute_category            in     varchar2 default null
  ,p_attribute1                    in     varchar2 default null
  ,p_attribute2                    in     varchar2 default null
  ,p_attribute3                    in     varchar2 default null
  ,p_attribute4                    in     varchar2 default null
  ,p_attribute5                    in     varchar2 default null
  ,p_attribute6                    in     varchar2 default null
  ,p_attribute7                    in     varchar2 default null
  ,p_attribute8                    in     varchar2 default null
  ,p_attribute9                    in     varchar2 default null
  ,p_attribute10                   in     varchar2 default null
  ,p_attribute11                   in     varchar2 default null
  ,p_attribute12                   in     varchar2 default null
  ,p_attribute13                   in     varchar2 default null
  ,p_attribute14                   in     varchar2 default null
  ,p_attribute15                   in     varchar2 default null
  ,p_attribute16                   in     varchar2 default null
  ,p_attribute17                   in     varchar2 default null
  ,p_attribute18                   in     varchar2 default null
  ,p_attribute19                   in     varchar2 default null
  ,p_attribute20                   in     varchar2 default null
  ,p_attribute21                   in     varchar2 default null
  ,p_attribute22                   in     varchar2 default null
  ,p_attribute23                   in     varchar2 default null
  ,p_attribute24                   in     varchar2 default null
  ,p_attribute25                   in     varchar2 default null
  ,p_attribute26                   in     varchar2 default null
  ,p_attribute27                   in     varchar2 default null
  ,p_attribute28                   in     varchar2 default null
  ,p_attribute29                   in     varchar2 default null
  ,p_attribute30                   in     varchar2 default null
  ,p_per_information_category      in     varchar2 default null
  ,NIP	                           in     varchar2 default null
  ,Insured_by_Employee             in     varchar2 default null
  ,Inheritor                       in     varchar2 default null
  ,p_per_information4              in     varchar2 default null
  ,p_per_information5              in     varchar2 default null
  ,p_per_information6              in     varchar2 default null
  ,p_per_information7              in     varchar2 default null
  ,p_per_information8              in     varchar2 default null
  ,p_per_information9              in     varchar2 default null
  ,p_per_information10             in     varchar2 default null
  ,p_per_information11             in     varchar2 default null
  ,p_per_information12             in     varchar2 default null
  ,p_per_information13             in     varchar2 default null
  ,p_per_information14             in     varchar2 default null
  ,p_per_information15             in     varchar2 default null
  ,p_per_information16             in     varchar2 default null
  ,p_per_information17             in     varchar2 default null
  ,p_per_information18             in     varchar2 default null
  ,p_per_information19             in     varchar2 default null
  ,p_per_information20             in     varchar2 default null
  ,p_per_information21             in     varchar2 default null
  ,p_per_information22             in     varchar2 default null
  ,p_per_information23             in     varchar2 default null
  ,p_per_information24             in     varchar2 default null
  ,p_per_information25             in     varchar2 default null
  ,p_per_information26             in     varchar2 default null
  ,p_per_information27             in     varchar2 default null
  ,p_per_information28             in     varchar2 default null
  ,p_per_information29             in     varchar2 default null
  ,p_per_information30             in     varchar2 default null
  ,p_correspondence_language       in     varchar2 default null
  ,p_honors                        in     varchar2 default null
  ,p_benefit_group_id              in     number   default null
  ,p_on_military_service           in     varchar2 default null
  ,p_student_status                in     varchar2 default null
  ,p_uses_tobacco_flag             in     varchar2 default null
  ,p_coord_ben_no_cvg_flag         in     varchar2 default null
  ,p_pre_name_adjunct              in     varchar2 default null
  ,p_suffix                        in     varchar2 default null
  ,p_town_of_birth                 in     varchar2 default null
  ,p_region_of_birth               in     varchar2 default null
  ,p_country_of_birth              in     varchar2 default null
  ,p_global_person_id              in     varchar2 default null
  ,p_person_id                        out nocopy number
  ,p_object_version_number            out nocopy number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ,p_full_name                        out nocopy varchar2
  ,p_comment_id                       out nocopy number
  ,p_name_combination_warning         out nocopy boolean
  ,p_orig_hire_warning                out nocopy boolean
  ) IS
  --
  -- Declare cursors and local variables
  --
  l_proc                 varchar2(72) ;

  --
begin
  l_proc      := g_package||'create_pl_person OLD';
  hr_utility.set_location('Entering:'|| l_proc, 45);
  --
  -- Validation in addition to Table Handlers
  --
  -- Check that the specified business group is valid.
  --
 /*Bug 4340576 Polish HRMS Phase 2.Code replaced with call to new
   overloaded procedure.

  open csr_bg;
  fetch csr_bg
  into l_legislation_code;
  if csr_bg%notfound then
    close csr_bg;
    hr_utility.set_message(801, 'HR_7208_API_BUS_GRP_INVALID');
    hr_utility.raise_error;
  end if;
  close csr_bg;
  --
  -- Check that the legislation of the specified business group is 'RU'.
  --
  if l_legislation_code <> 'PL' then
    hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
    hr_utility.set_message_token('LEG_CODE','PL');
    hr_utility.raise_error;
  end if;

  hr_utility.set_location(l_proc, 50);
  --
  -- Call the person business process
  --
       hr_utility.set_location (l_proc, 50);
      --
      -- Call the person business process
      --
      hr_contact_api.create_person
*/  hr_pl_contact_api.create_pl_person
      (p_validate                          => p_validate
      ,p_start_date                        => p_start_date
      ,p_business_group_id                 => p_business_group_id
      ,p_last_name                         => p_last_name
      ,p_sex                               => p_sex
      ,p_person_type_id                    => p_person_type_id
      ,p_comments                          => p_comments
      ,p_date_employee_data_verified       => p_date_employee_data_verified
      ,p_date_of_birth                     => p_date_of_birth
      ,p_email_address                     => p_email_address
      ,p_expense_check_send_to_addres      => p_expense_check_send_to_addres
      ,p_first_name                        => p_first_name
      ,p_known_as                          => p_known_as
      ,p_marital_status                    => p_marital_status
      ,p_middle_names                      => p_middle_names
      ,p_nationality                       => p_nationality
      ,p_pesel                             => p_inn
      ,p_previous_last_name                => p_previous_last_name
      ,p_registered_disabled_flag          => p_registered_disabled_flag
      ,p_title                             => p_title
      ,p_vendor_id                         => p_vendor_id
      ,p_work_telephone                    => p_work_telephone
      ,p_attribute_category                => p_attribute_category
      ,p_attribute1                        => p_attribute1
      ,p_attribute2                        => p_attribute2
      ,p_attribute3                        => p_attribute3
      ,p_attribute4                        => p_attribute4
      ,p_attribute5                        => p_attribute5
      ,p_attribute6                        => p_attribute6
      ,p_attribute7                        => p_attribute7
      ,p_attribute8                        => p_attribute8
      ,p_attribute9                        => p_attribute9
      ,p_attribute10                       => p_attribute10
      ,p_attribute11                       => p_attribute11
      ,p_attribute12                       => p_attribute12
      ,p_attribute13                       => p_attribute13
      ,p_attribute14                       => p_attribute14
      ,p_attribute15                       => p_attribute15
      ,p_attribute16                       => p_attribute16
      ,p_attribute17                       => p_attribute17
      ,p_attribute18                       => p_attribute18
      ,p_attribute19                       => p_attribute19
      ,p_attribute20                       => p_attribute20
      ,p_attribute21                       => p_attribute21
      ,p_attribute22                       => p_attribute22
      ,p_attribute23                       => p_attribute23
      ,p_attribute24                       => p_attribute24
      ,p_attribute25                       => p_attribute25
      ,p_attribute26                       => p_attribute26
      ,p_attribute27                       => p_attribute27
      ,p_attribute28                       => p_attribute28
      ,p_attribute29                       => p_attribute29
      ,p_attribute30                       => p_attribute30
      ,p_per_information_category          => 'PL'
      ,p_nip                               => NIP
      ,p_insured_by_employee               => Insured_by_Employee
      ,p_inheritor                         => Inheritor
      ,p_oldage_pension_rights             => p_per_information4
      ,p_national_fund_of_health           => p_per_information5
      ,p_tax_office                        => p_per_information6
      ,p_legal_employer                    => p_per_information7
      ,p_citizenship                       => p_per_information8
      ,p_correspondence_language           => p_correspondence_language
      ,p_honors                            => p_honors
      ,p_benefit_group_id                  => p_benefit_group_id
      ,p_on_military_service               => p_on_military_service
      ,p_student_status                    => p_student_status
      ,p_uses_tobacco_flag                 => p_uses_tobacco_flag
      ,p_coord_ben_no_cvg_flag             => p_coord_ben_no_cvg_flag
      ,p_pre_name_adjunct                  => p_pre_name_adjunct
      ,p_suffix                            => p_suffix
      ,p_town_of_birth                     => p_town_of_birth
      ,p_region_of_birth                   => p_region_of_birth
      ,p_country_of_birth                  => p_country_of_birth
      ,p_global_person_id                  => p_global_person_id
      ,p_person_id                         => p_person_id
      ,p_object_version_number             => p_object_version_number
      ,p_effective_start_date              => p_effective_start_date
      ,p_effective_end_date                => p_effective_end_date
      ,p_full_name                         => p_full_name
      ,p_comment_id                        => p_comment_id
      ,p_name_combination_warning          => p_name_combination_warning
      ,p_orig_hire_warning                 => p_orig_hire_warning
      );

 --
  hr_utility.set_location(' Leaving:'||l_proc, 55);
end create_pl_person;

procedure create_pl_person
  (p_validate                      in     boolean  default false
  ,p_start_date                    in     date
  ,p_business_group_id             in     number
  ,p_last_name                     in     varchar2
  ,p_sex                           in     varchar2
  ,p_person_type_id                in     number   default null
  ,p_comments                      in     varchar2 default null
  ,p_date_employee_data_verified   in     date     default null
  ,p_date_of_birth                 in     date     default null
  ,p_email_address                 in     varchar2 default null
  ,p_expense_check_send_to_addres  in     varchar2 default null
  ,p_first_name                    in     varchar2 default null
  ,p_known_as                      in     varchar2 default null
  ,p_marital_status                in     varchar2 default null
  ,p_middle_names                  in     varchar2 default null
  ,p_nationality                   in     varchar2 default null
  ,p_pesel                         in     varchar2 default null
  ,p_previous_last_name            in     varchar2 default null
  ,p_registered_disabled_flag      in     varchar2 default null
  ,p_title                         in     varchar2 default null
  ,p_vendor_id                     in     number   default null
  ,p_work_telephone                in     varchar2 default null
  ,p_attribute_category            in     varchar2 default null
  ,p_attribute1                    in     varchar2 default null
  ,p_attribute2                    in     varchar2 default null
  ,p_attribute3                    in     varchar2 default null
  ,p_attribute4                    in     varchar2 default null
  ,p_attribute5                    in     varchar2 default null
  ,p_attribute6                    in     varchar2 default null
  ,p_attribute7                    in     varchar2 default null
  ,p_attribute8                    in     varchar2 default null
  ,p_attribute9                    in     varchar2 default null
  ,p_attribute10                   in     varchar2 default null
  ,p_attribute11                   in     varchar2 default null
  ,p_attribute12                   in     varchar2 default null
  ,p_attribute13                   in     varchar2 default null
  ,p_attribute14                   in     varchar2 default null
  ,p_attribute15                   in     varchar2 default null
  ,p_attribute16                   in     varchar2 default null
  ,p_attribute17                   in     varchar2 default null
  ,p_attribute18                   in     varchar2 default null
  ,p_attribute19                   in     varchar2 default null
  ,p_attribute20                   in     varchar2 default null
  ,p_attribute21                   in     varchar2 default null
  ,p_attribute22                   in     varchar2 default null
  ,p_attribute23                   in     varchar2 default null
  ,p_attribute24                   in     varchar2 default null
  ,p_attribute25                   in     varchar2 default null
  ,p_attribute26                   in     varchar2 default null
  ,p_attribute27                   in     varchar2 default null
  ,p_attribute28                   in     varchar2 default null
  ,p_attribute29                   in     varchar2 default null
  ,p_attribute30                   in     varchar2 default null
  ,p_per_information_category      in     varchar2 default null
  ,p_nip                           in     varchar2 default null
  ,p_insured_by_employee           in     varchar2 default null
  ,p_inheritor                     in     varchar2 default null
  ,p_oldage_pension_rights         in     varchar2 default null
  ,p_national_fund_of_health       in     varchar2 default null
  ,p_tax_office                    in     varchar2 default null
  ,p_legal_employer                in     varchar2 default null
  ,p_citizenship                   in     varchar2 default null
  ,p_correspondence_language       in     varchar2 default null
  ,p_honors                        in     varchar2 default null
  ,p_benefit_group_id              in     number   default null
  ,p_on_military_service           in     varchar2 default null
  ,p_student_status                in     varchar2 default null
  ,p_uses_tobacco_flag             in     varchar2 default null
  ,p_coord_ben_no_cvg_flag         in     varchar2 default null
  ,p_pre_name_adjunct              in     varchar2 default null
  ,p_suffix                        in     varchar2 default null
  ,p_town_of_birth                 in     varchar2 default null
  ,p_region_of_birth               in     varchar2 default null
  ,p_country_of_birth              in     varchar2 default null
  ,p_global_person_id              in     varchar2 default null
  ,p_person_id                       out nocopy number
  ,p_object_version_number            out nocopy number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ,p_full_name                        out nocopy varchar2
  ,p_comment_id                       out nocopy number
  ,p_name_combination_warning         out nocopy boolean
  ,p_orig_hire_warning                out nocopy boolean
  )is
  -- Declare cursors and local variables
  --
  l_proc                 varchar2(72) ;
  l_legislation_code     varchar2(2);

  --
  cursor csr_bg is
    select legislation_code
    from per_business_groups pbg
    where pbg.business_group_id = p_business_group_id;
Begin
l_proc      := g_package||'create_pl_person';
hr_utility.set_location('Entering:'|| l_proc, 45);
 open csr_bg;
  fetch csr_bg
  into l_legislation_code;
  if csr_bg%notfound then
    close csr_bg;
    hr_utility.set_message(801, 'HR_7208_API_BUS_GRP_INVALID');
    hr_utility.raise_error;
  end if;
  close csr_bg;
  --
  -- Check that the legislation of the specified business group is 'PL'.
  --
  if l_legislation_code <> 'PL' then
    hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
    hr_utility.set_message_token('LEG_CODE','PL');
    hr_utility.raise_error;
  end if;

  hr_utility.set_location(l_proc, 50);
  --
  -- Call the person business process
  --
       hr_utility.set_location (l_proc, 50);
      --
      -- Call the person business process
      --
      hr_contact_api.create_person
      (p_validate                          => p_validate
      ,p_start_date                        => p_start_date
      ,p_business_group_id                 => p_business_group_id
      ,p_last_name                         => p_last_name
      ,p_sex                               => p_sex
      ,p_person_type_id                    => p_person_type_id
      ,p_comments                          => p_comments
      ,p_date_employee_data_verified       => p_date_employee_data_verified
      ,p_date_of_birth                     => p_date_of_birth
      ,p_email_address                     => p_email_address
      ,p_expense_check_send_to_addres      => p_expense_check_send_to_addres
      ,p_first_name                        => p_first_name
      ,p_known_as                          => p_known_as
      ,p_marital_status                    => p_marital_status
      ,p_middle_names                      => p_middle_names
      ,p_nationality                       => p_nationality
      ,p_national_identifier               => p_pesel
      ,p_previous_last_name                => p_previous_last_name
      ,p_registered_disabled_flag          => p_registered_disabled_flag
      ,p_title                             => p_title
      ,p_vendor_id                         => p_vendor_id
      ,p_work_telephone                    => p_work_telephone
      ,p_attribute_category                => p_attribute_category
      ,p_attribute1                        => p_attribute1
      ,p_attribute2                        => p_attribute2
      ,p_attribute3                        => p_attribute3
      ,p_attribute4                        => p_attribute4
      ,p_attribute5                        => p_attribute5
      ,p_attribute6                        => p_attribute6
      ,p_attribute7                        => p_attribute7
      ,p_attribute8                        => p_attribute8
      ,p_attribute9                        => p_attribute9
      ,p_attribute10                       => p_attribute10
      ,p_attribute11                       => p_attribute11
      ,p_attribute12                       => p_attribute12
      ,p_attribute13                       => p_attribute13
      ,p_attribute14                       => p_attribute14
      ,p_attribute15                       => p_attribute15
      ,p_attribute16                       => p_attribute16
      ,p_attribute17                       => p_attribute17
      ,p_attribute18                       => p_attribute18
      ,p_attribute19                       => p_attribute19
      ,p_attribute20                       => p_attribute20
      ,p_attribute21                       => p_attribute21
      ,p_attribute22                       => p_attribute22
      ,p_attribute23                       => p_attribute23
      ,p_attribute24                       => p_attribute24
      ,p_attribute25                       => p_attribute25
      ,p_attribute26                       => p_attribute26
      ,p_attribute27                       => p_attribute27
      ,p_attribute28                       => p_attribute28
      ,p_attribute29                       => p_attribute29
      ,p_attribute30                       => p_attribute30
      ,p_per_information_category          => 'PL'
      ,p_per_information1                  => p_nip
      ,p_per_information2                  => p_insured_by_employee
      ,p_per_information3                  => p_inheritor
      ,p_per_information4                  => p_oldage_pension_rights
      ,p_per_information5                  => p_national_fund_of_health
      ,p_per_information6                  => p_tax_office
      ,p_per_information7                  => p_legal_employer
      ,p_per_information8                  => p_citizenship
      ,p_correspondence_language           => p_correspondence_language
      ,p_honors                            => p_honors
      ,p_benefit_group_id                  => p_benefit_group_id
      ,p_on_military_service               => p_on_military_service
      ,p_student_status                    => p_student_status
      ,p_uses_tobacco_flag                 => p_uses_tobacco_flag
      ,p_coord_ben_no_cvg_flag             => p_coord_ben_no_cvg_flag
      ,p_pre_name_adjunct                  => p_pre_name_adjunct
      ,p_suffix                            => p_suffix
      ,p_town_of_birth                     => p_town_of_birth
      ,p_region_of_birth                   => p_region_of_birth
      ,p_country_of_birth                  => p_country_of_birth
      ,p_global_person_id                  => p_global_person_id
      ,p_person_id                         => p_person_id
      ,p_object_version_number             => p_object_version_number
      ,p_effective_start_date              => p_effective_start_date
      ,p_effective_end_date                => p_effective_end_date
      ,p_full_name                         => p_full_name
      ,p_comment_id                        => p_comment_id
      ,p_name_combination_warning          => p_name_combination_warning
      ,p_orig_hire_warning                 => p_orig_hire_warning
      );
--
 hr_utility.set_location(' Leaving:'||l_proc, 55);
end create_pl_person;
end hr_pl_contact_api;

/
