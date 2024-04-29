--------------------------------------------------------
--  DDL for Package Body HR_CONTACT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_CONTACT_API" as
/* $Header: peconapi.pkb 120.0 2005/05/31 07:03:45 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'hr_contact_api';
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_person >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_person
  (p_validate                      in     boolean  default false
  ,p_start_date                    in     date
  ,p_business_group_id             in     number
  ,p_last_name                     in     varchar2
  ,p_sex                           in     varchar2
  ,p_person_type_id                in     number   default null -- Bug 918219
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
  ,p_national_identifier           in     varchar2 default null
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
  ,p_per_information1              in     varchar2 default null
  ,p_per_information2              in     varchar2 default null
  ,p_per_information3              in     varchar2 default null
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
  ) is
  --
  -- Declare cursors and local variables
  --

  -- Bug 3406332 starts here.
  cursor csr_get_legislation_code is
    select legislation_code
    from per_business_groups
    where business_group_id = p_business_group_id;
  l_legislation_code             per_business_groups.legislation_code%type;
  -- 3406332 ends here.
  l_proc                varchar2(72) := g_package||'create_person';
  l_person_type_id      per_person_types.person_type_id%type:=
                        p_person_type_id;
  l_person_id           per_people_f.person_id%type;
  l_start_date                   per_all_people_f.start_date%TYPE;
  l_date_employee_data_verified  per_all_people_f.date_employee_data_verified%TYPE;
  l_date_of_birth                per_all_people_f.date_of_birth%TYPE;
  l_applicant_number             number := null;
  l_employee_number              number;
  l_npw_number                   number;
  l_dummy_var                    varchar2(30);
  l_dummy_boolean                boolean;
  l_phn_object_version_number    per_phones.object_version_number%TYPE;
  l_phone_id                     per_phones.phone_id%TYPE;
  --
  -- Declare additional OUT variables
  --
  l_effective_start_date         per_all_people_f.effective_start_date%TYPE;
  l_effective_end_date           per_all_people_f.effective_end_date%TYPE;
  l_object_version_number        per_all_people_f.object_version_number%TYPE;
  l_full_name                    per_all_people_f.full_name%TYPE;
  l_comment_id                   per_all_people_f.comment_id%TYPE;
  l_name_combination_warning     boolean;
  l_orig_hire_warning            boolean;

begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint.
  --
  savepoint create_person_contact;
  hr_utility.set_location(l_proc, 10);
  --
  -- Truncate the start date, as could use in a few areas.
  --
  l_start_date                   := trunc(p_start_date);
  l_date_employee_data_verified  := trunc(p_date_employee_data_verified);
  l_date_of_birth                := trunc(p_date_of_birth);
  --
  -- Bug fix 3406332 starts here.
  open csr_get_legislation_code;
  fetch csr_get_legislation_code into l_legislation_code;
  close  csr_get_legislation_code;
  -- 3406332 end here.
  begin
  --
  -- Start of API for the before process hook for create_person.
  --
  hr_contact_bk1.create_person_b
    (p_start_date                    => l_start_date
    ,p_business_group_id             => p_business_group_id
    ,p_last_name                     => p_last_name
    ,p_sex                           => p_sex
    ,p_person_type_id                => p_person_type_id
    ,p_comments                      => p_comments
    ,p_date_employee_data_verified   => l_date_employee_data_verified
    ,p_date_of_birth                 => l_date_of_birth
    ,p_email_address                 => p_email_address
    ,p_expense_check_send_to_addres  => p_expense_check_send_to_addres
    ,p_first_name                    => p_first_name
    ,p_known_as                      => p_known_as
    ,p_marital_status                => p_marital_status
    ,p_middle_names                  => p_middle_names
    ,p_nationality                   => p_nationality
    ,p_national_identifier           => p_national_identifier
    ,p_previous_last_name            => p_previous_last_name
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
    --,p_per_information_category      => p_per_information_category
    ,p_per_information_category      => l_legislation_code -- bug fix 3406332.
    ,p_per_information1              => p_per_information1
    ,p_per_information2              => p_per_information2
    ,p_per_information3              => p_per_information3
    ,p_per_information4              => p_per_information4
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
    ,p_pre_name_adjunct              => p_pre_name_adjunct
    ,p_suffix                        => p_suffix
    ,p_town_of_birth                 => p_town_of_birth
    ,p_region_of_birth               => p_region_of_birth
    ,p_country_of_birth              => p_country_of_birth
    ,p_global_person_id              => p_global_person_id
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_PERSON'
        ,p_hook_type   => 'BP'
        );
  --
  -- End of the before process hook for create_person
  --
  end;
  --
  --
  -- Validation in addition to Table Handlers
  --
  -- If the specified person type id is not null then check that it
  -- corresponds to type 'OTHER', is currently active and is in the correct
  -- business group, otherwise set person type to the active default for OTHER
  -- in the current business group.
  --
  per_per_bus.chk_person_type
    (p_person_type_id    => l_person_type_id
    ,p_business_group_id => p_business_group_id
    ,p_expected_sys_type => 'OTHER'
    );
  l_applicant_number := null;
  l_employee_number  := null;
  l_npw_number       := null;
  hr_utility.set_location(l_proc, 20);
  --
  -- Create the person details
  --
  -- added for PTU:
  l_person_type_id :=
     hr_person_type_usage_info.get_default_person_type_id(l_person_type_id);
  --
  per_per_ins.ins
    (p_business_group_id            => p_business_group_id
    ,p_person_type_id               => l_person_type_id
    ,p_last_name                    => p_last_name
    ,p_start_date                   => l_start_date
    ,p_effective_date               => l_start_date
    ,p_applicant_number             => l_applicant_number
    ,p_current_applicant_flag       => l_dummy_var
    ,p_current_emp_or_apl_flag      => l_dummy_var
    ,p_current_employee_flag        => l_dummy_var
    ,p_employee_number              => l_employee_number
    --
    ,p_comments                     => p_comments
    ,p_date_employee_data_verified  => l_date_employee_data_verified
    ,p_date_of_birth                => l_date_of_birth
    ,p_email_address                => p_email_address
    ,p_expense_check_send_to_addres => p_expense_check_send_to_addres
    ,p_first_name                   => p_first_name
    ,p_known_as                     => p_known_as
    ,p_marital_status               => p_marital_status
    ,p_middle_names                 => p_middle_names
    ,p_nationality                  => p_nationality
    ,p_national_identifier          => p_national_identifier
    ,p_previous_last_name           => p_previous_last_name
    ,p_registered_disabled_flag     => p_registered_disabled_flag
    ,p_sex                          => p_sex
    ,p_title                        => p_title
    ,p_vendor_id                    => p_vendor_id
--  ,p_work_telephone               => p_work_telephone -- Now handled by create_phone
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
    --,p_per_information_category     => p_per_information_category
    ,p_per_information_category     => l_legislation_code -- bug fix 3406332.
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
    ,p_correspondence_language      => p_correspondence_language
    ,p_honors                       => p_honors
    ,p_benefit_group_id             => p_benefit_group_id
    ,p_on_military_service          => p_on_military_service
    ,p_student_status               => p_student_status
    ,p_uses_tobacco_flag            => p_uses_tobacco_flag
    ,p_coord_ben_no_cvg_flag        => p_coord_ben_no_cvg_flag
    ,p_pre_name_adjunct             => p_pre_name_adjunct
    ,p_suffix                       => p_suffix
    ,p_town_of_birth                => p_town_of_birth
    ,p_region_of_birth              => p_region_of_birth
    ,p_country_of_birth             => p_country_of_birth
    ,p_global_person_id             => p_global_person_id
    ,p_validate                     => false
    --
    ,p_person_id                    => l_person_id
    ,p_effective_start_date         => l_effective_start_date
    ,p_effective_end_date           => l_effective_end_date
    ,p_comment_id                   => p_comment_id
    ,p_full_name                    => p_full_name
    ,p_object_version_number        => l_object_version_number
    ,p_name_combination_warning     => l_name_combination_warning
    ,p_dob_null_warning             => l_dummy_boolean
    ,p_orig_hire_warning            => l_orig_hire_warning
    ,p_npw_number                   => l_npw_number
    );
  --
  hr_utility.set_location(l_proc, 30);
  --
  -- Maintain security access to profiles which restrict access to contacts.
  --
  hr_security_internal.populate_new_contact(
             p_business_group_id => p_business_group_id,
             p_person_id => l_person_id);
  --
  -- added for PTU
  --
  if p_person_type_id is not null and p_person_type_id <> hr_api.g_number then
    begin
      select   person_type_id into l_person_type_id
      from     per_person_types
      where    person_type_id = p_person_type_id
      and      business_group_id = p_business_group_id
      and      active_flag = 'Y'
      and      system_person_type = 'OTHER';
    exception
      when no_data_found then
   hr_utility.set_message(801, 'HR_7513_PER_TYPE_INVALID');
   hr_utility.raise_error;
    end;
    l_person_type_id := p_person_type_id;
  else
    l_person_type_id :=  hr_person_type_usage_info.get_default_person_type_id
             (p_business_group_id,
         'OTHER');
  end if;
  --
  hr_per_type_usage_internal.maintain_person_type_usage
      (p_effective_date       => p_start_date
      ,p_person_id            => l_person_id
      ,p_person_type_id       => l_person_type_id
      );
  --
  -- end of PTU changes
  --
  --
  -- Create a phone row using the newly created person as the parent row.
  -- This phone row replaces the work_telephone column on the person.
  --
  if p_work_telephone is not null then
     hr_phone_api.create_phone
       (p_date_from                 => l_start_date
       ,p_date_to                   => null
       ,p_phone_type                => 'W1'
       ,p_phone_number              => p_work_telephone
       ,p_parent_id                 => l_person_id
       ,p_parent_table              => 'PER_ALL_PEOPLE_F'
       ,p_validate                  => FALSE
       ,p_effective_date            => l_start_date
       ,p_object_version_number     => l_phn_object_version_number  --out
       ,p_phone_id                  => l_phone_id                   --out
       );
  end if;
  --
  begin
  --
  -- Start of API for the after process hook for create_person.
  --
  hr_contact_bk1.create_person_a
    (p_start_date                    => l_start_date
    ,p_business_group_id             => p_business_group_id
    ,p_last_name                     => p_last_name
    ,p_sex                           => p_sex
    ,p_person_type_id                => p_person_type_id
    ,p_comments                      => p_comments
    ,p_date_employee_data_verified   => l_date_employee_data_verified
    ,p_date_of_birth                 => l_date_of_birth
    ,p_email_address                 => p_email_address
    ,p_expense_check_send_to_addres  => p_expense_check_send_to_addres
    ,p_first_name                    => p_first_name
    ,p_known_as                      => p_known_as
    ,p_marital_status                => p_marital_status
    ,p_middle_names                  => p_middle_names
    ,p_nationality                   => p_nationality
    ,p_national_identifier           => p_national_identifier
    ,p_previous_last_name            => p_previous_last_name
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
    --,p_per_information_category      => p_per_information_category
    ,p_per_information_category      => l_legislation_code -- bug fix 3406332.
    ,p_per_information1              => p_per_information1
    ,p_per_information2              => p_per_information2
    ,p_per_information3              => p_per_information3
    ,p_per_information4              => p_per_information4
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
    ,p_pre_name_adjunct              => p_pre_name_adjunct
    ,p_suffix                        => p_suffix
    ,p_town_of_birth                 => p_town_of_birth
    ,p_region_of_birth               => p_region_of_birth
    ,p_country_of_birth              => p_country_of_birth
    ,p_global_person_id              => p_global_person_id
    ,p_person_id                     => l_person_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_full_name                     => l_full_name
    ,p_comment_id                    => l_comment_id
    ,p_name_combination_warning      => l_name_combination_warning
    ,p_orig_hire_warning             => l_orig_hire_warning
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_PERSON'
        ,p_hook_type   => 'AP'
        );
  --
  -- End of the after process hook for create_person
  --
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;

  -- Fix 3637708 Start
  SELECT object_version_number
   INTO p_object_version_number
   FROM per_all_people_f
   WHERE person_id = l_person_id
   And effective_start_Date = l_effective_start_date
   and effective_end_Date = l_effective_end_date;
  -- Fix 3637708 End

  --
  -- Set all output arguments
  --
  p_person_id                   := l_person_id;
  p_effective_start_date        := l_effective_start_date;
  p_effective_end_date          := l_effective_end_date;
  p_full_name                   := l_full_name;
  p_comment_id                  := l_comment_id;
  p_name_combination_warning    := l_name_combination_warning;
  p_orig_hire_warning           := l_orig_hire_warning;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 40);
  --
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_person_contact;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_person_id                 := null;
    p_object_version_number     := null;
    p_effective_start_date      := null;
    p_effective_end_date        := null;
    p_full_name                 := null;
    p_comment_id                := null;
    p_name_combination_warning  := l_name_combination_warning;
    p_orig_hire_warning         := l_orig_hire_warning;
   --
    hr_utility.set_location(' Leaving:'||l_proc, 50);
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632479
    --
    ROLLBACK TO create_person_contact;
    --
    -- Set Out parameters [part of nocopy changes]
    p_person_id                 := null;
    p_object_version_number     := null;
    p_effective_start_date      := null;
    p_effective_end_date        := null;
    p_full_name                 := null;
    p_comment_id                := null;
    p_name_combination_warning  := FALSE;
    p_orig_hire_warning         := FALSE;
    --
    raise;
    --
    -- End of fix.
    --
end create_person;
--
end hr_contact_api;

/
