--------------------------------------------------------
--  DDL for Package Body HR_FR_EMPLOYEE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_FR_EMPLOYEE_API" as
/* $Header: peempfri.pkb 115.3 2002/12/12 15:13:22 sfmorris noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'hr_fr_employee_api.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_fr_employee >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_fr_employee
  (p_validate                      in     boolean
  ,p_hire_date                     in     date
  ,p_business_group_id             in     number
  ,p_last_name                     in     varchar2
  ,p_sex                           in     varchar2
  ,p_person_type_id                in     number
  ,p_comments                      in     varchar2
  ,p_date_employee_data_verified   in     date
  ,p_date_of_birth                 in     date
  ,p_email_address                 in     varchar2
  ,p_employee_number               in out nocopy varchar2
  ,p_expense_check_send_to_addres  in     varchar2
  ,p_first_name                    in     varchar2
  ,p_known_as                      in     varchar2
  ,p_marital_status                in     varchar2
  ,p_middle_names                  in     varchar2
  ,p_nationality                   in     varchar2
  ,p_ni_number                     in     varchar2
  ,p_previous_last_name            in     varchar2
  ,p_registered_disabled_flag      in     varchar2
  ,p_title                         in     varchar2
  ,p_vendor_id                     in     number
  ,p_work_telephone                in     varchar2
  ,p_attribute_category            in     varchar2
  ,p_attribute1                    in     varchar2
  ,p_attribute2                    in     varchar2
  ,p_attribute3                    in     varchar2
  ,p_attribute4                    in     varchar2
  ,p_attribute5                    in     varchar2
  ,p_attribute6                    in     varchar2
  ,p_attribute7                    in     varchar2
  ,p_attribute8                    in     varchar2
  ,p_attribute9                    in     varchar2
  ,p_attribute10                   in     varchar2
  ,p_attribute11                   in     varchar2
  ,p_attribute12                   in     varchar2
  ,p_attribute13                   in     varchar2
  ,p_attribute14                   in     varchar2
  ,p_attribute15                   in     varchar2
  ,p_attribute16                   in     varchar2
  ,p_attribute17                   in     varchar2
  ,p_attribute18                   in     varchar2
  ,p_attribute19                   in     varchar2
  ,p_attribute20                   in     varchar2
  ,p_attribute21                   in     varchar2
  ,p_attribute22                   in     varchar2
  ,p_attribute23                   in     varchar2
  ,p_attribute24                   in     varchar2
  ,p_attribute25                   in     varchar2
  ,p_attribute26                   in     varchar2
  ,p_attribute27                   in     varchar2
  ,p_attribute28                   in     varchar2
  ,p_attribute29                   in     varchar2
  ,p_attribute30                   in     varchar2
  ,p_date_of_death                 in     date
  ,p_maiden_name                   in     varchar2
  ,p_department_of_birth           in     varchar2
  ,p_town_of_birth                 in     varchar2
  ,p_country_of_birth              in     varchar2
  ,p_military_status               in     varchar2
  ,p_date_last_school_certificate  in     varchar2
  ,p_school_name                   in     varchar2
  ,p_level_of_education            in     varchar2
  ,p_date_first_entry_into_france  in     varchar2
  ,p_cpam_name                     in     varchar2
  ,p_correspondence_language       in     varchar2
  ,p_fast_path_employee            in     varchar2
  ,p_fte_capacity                  in     number
  ,p_honors                        in     varchar2
  ,p_internal_location             in     varchar2
  ,p_mailstop                      in     varchar2
  ,p_office_number                 in     varchar2
  ,p_pre_name_adjunct              in     varchar2
  ,p_projected_start_date          in     date
  ,p_resume_exists                 in     varchar2
  ,p_resume_last_updated           in     date
  ,p_student_status                in     varchar2
  ,p_work_schedule                 in     varchar2
  ,p_suffix                        in     varchar2
  ,p_person_id                        out nocopy number
  ,p_assignment_id                    out nocopy number
  ,p_per_object_version_number        out nocopy number
  ,p_asg_object_version_number        out nocopy number
  ,p_per_effective_start_date         out nocopy date
  ,p_per_effective_end_date           out nocopy date
  ,p_full_name                        out nocopy varchar2
  ,p_per_comment_id                   out nocopy number
  ,p_assignment_sequence              out nocopy number
  ,p_assignment_number                out nocopy varchar2
  ,p_name_combination_warning         out nocopy boolean
  ,p_assign_payroll_warning           out nocopy boolean
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                 varchar2(72) := g_package||'create_fr_employee';
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
  -- Check that the legislation of the specified business group is 'FR'.
  --
  if l_legislation_code <> 'FR' then
    hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
    hr_utility.set_message_token('LEG_CODE','FR');
    hr_utility.raise_error;
  end if;

  hr_utility.set_location(l_proc, 6);
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
  ,p_national_identifier          => p_ni_number
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
  ,p_per_information_category     => 'FR'
  ,p_per_information1             => p_maiden_name
  ,p_per_information6             => p_military_status
  ,p_per_information7             => p_date_last_school_certificate
  ,p_per_information8             => p_school_name
  ,p_per_information9             => p_level_of_education
  ,p_per_information10            => p_date_first_entry_into_france
  ,p_per_information11            => p_cpam_name
  ,p_date_of_death                => p_date_of_death
  ,p_correspondence_language      => p_correspondence_language
  ,p_fast_path_employee           => p_fast_path_employee
  ,p_fte_capacity                 => p_fte_capacity
  ,p_honors                       => p_honors
  ,p_internal_location            => p_internal_location
  ,p_mailstop                     => p_mailstop
  ,p_office_number                => p_office_number
  ,p_pre_name_adjunct             => p_pre_name_adjunct
  ,p_projected_start_date         => p_projected_start_date
  ,p_resume_exists                => p_resume_exists
  ,p_resume_last_updated          => p_resume_last_updated
  ,p_student_status               => p_student_status
  ,p_work_schedule                => p_work_schedule
  ,p_suffix                       => p_suffix
  ,p_town_of_birth                => p_town_of_birth
  ,p_region_of_birth              => p_department_of_birth
  ,p_country_of_birth             => p_country_of_birth
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
  );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 7);
--
end create_fr_employee;
--
end hr_fr_employee_api;

/
