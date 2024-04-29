--------------------------------------------------------
--  DDL for Package Body HR_ES_CONTACT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ES_CONTACT_API" as
/* $Header: peconesi.pkb 115.0 2004/03/18 01:20:57 vikgupta noship $ */

--
--   package variables
g_package  varchar2(33) := 'hr_es_contact_api.';
--
procedure create_es_person
  (p_validate                      in     boolean  default false
  ,p_start_date                    in     date
  ,p_business_group_id             in     number
  ,p_first_last_name               in     varchar2
  ,p_sex                           in     varchar2
  ,p_person_type_id                in     number   default null
  ,p_comments                      in     varchar2 default null
  ,p_date_employee_data_verified   in     date     default null
  ,p_date_of_birth                 in     date     default null
  ,p_email_address                 in     varchar2 default null
  ,p_expense_check_send_to_addres  in     varchar2 default null
  ,p_name                          in     varchar2 default null
  ,p_preferred_name                in     varchar2 default null
  ,p_marital_status                in     varchar2 default null
  ,p_middle_names                  in     varchar2 default null
  ,p_nationality                   in     varchar2 default null
  ,p_nif_value                     in     varchar2 default null
  ,p_maiden_name                   in     varchar2 default null
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
  ,p_second_last_name              in     varchar2 default null
  ,p_identifier_type               in     varchar2 default null
  ,p_identifier_value              in     varchar2 default null
  ,p_overtime_approval             in     varchar2 default null
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
  ,p_prefix                        in     varchar2 default null
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
  ) is

-- Declare cursors and local variables
  --
  l_proc                 varchar2(72) := g_package||'create_es_contact';
  l_legislation_code     varchar2(2);
  --
  cursor csr_bg is
    select legislation_code
    from per_business_groups pbg
    where pbg.business_group_id = p_business_group_id;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Validation in addition to Row Handlers
  --
  -- Check that the specified business group is valid.
  --
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
  -- Check that the legislation of the specified business group is 'ES'.
  --
  if l_legislation_code <> 'ES' then
    hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
    hr_utility.set_message_token('LEG_CODE','ES');
    hr_utility.raise_error;
  end if;


  hr_utility.set_location(l_proc, 6);

  --
  -- Call the person business process
hr_contact_api.create_person
  (p_validate                      => p_validate
  ,p_start_date                    => p_start_date
  ,p_business_group_id             => p_business_group_id
  ,p_last_name                     => p_first_last_name
  ,p_sex                           => p_sex
  ,p_person_type_id                => p_person_type_id
  ,p_comments                      => p_comments
  ,p_date_employee_data_verified   => p_date_employee_data_verified
  ,p_date_of_birth                 => p_date_of_birth
  ,p_email_address                 => p_email_address
  ,p_expense_check_send_to_addres  => p_expense_check_send_to_addres
  ,p_first_name                    => p_name
  ,p_known_as                      => p_preferred_name
  ,p_marital_status                => p_marital_status
  ,p_middle_names                  => p_middle_names
  ,p_nationality                   => p_nationality
  ,p_national_identifier           => p_nif_value
  ,p_previous_last_name            => p_maiden_name
  ,p_registered_disabled_flag      => p_registered_disabled_flag
  ,p_title                         => p_title
  ,p_vendor_id                     => p_vendor_id
  ,p_work_telephone                => p_work_telephone
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
  ,p_per_information_category      => 'ES'
  ,p_per_information1              => p_second_last_name
  ,p_per_information2              => p_identifier_type
  ,p_per_information3              => p_identifier_value
  ,p_per_information4              => p_overtime_approval
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
  ,p_correspondence_language       => p_correspondence_language
  ,p_honors                        => p_honors
  ,p_benefit_group_id              => p_benefit_group_id
  ,p_on_military_service           => p_on_military_service
  ,p_student_status                => p_student_status
  ,p_uses_tobacco_flag             => p_uses_tobacco_flag
  ,p_coord_ben_no_cvg_flag         => p_coord_ben_no_cvg_flag
  ,p_pre_name_adjunct              => p_prefix
  ,p_suffix                        => p_suffix
  ,p_town_of_birth                 => p_town_of_birth
  ,p_region_of_birth               => p_region_of_birth
  ,p_country_of_birth              => p_country_of_birth
  ,p_global_person_id              => p_global_person_id
  ,p_person_id                     => p_person_id
  ,p_object_version_number         => p_object_version_number
  ,p_effective_start_date          => p_effective_start_date
  ,p_effective_end_date            => p_effective_end_date
  ,p_full_name                     => p_full_name
  ,p_comment_id                    => p_comment_id
  ,p_name_combination_warning      => p_name_combination_warning
  ,p_orig_hire_warning             => p_orig_hire_warning
  );

  end create_es_person;

end hr_es_contact_api;

/
