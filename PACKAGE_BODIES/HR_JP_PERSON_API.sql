--------------------------------------------------------
--  DDL for Package Body HR_JP_PERSON_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_JP_PERSON_API" as
/* $Header: pejppapi.pkb 115.3 2003/02/07 11:29:25 pkakar ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'hr_jp_person_api.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_jp_person >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_jp_person
  (p_validate                     in      boolean   default false
  ,p_effective_date               in      date
  ,p_datetrack_update_mode        in      varchar2
  ,p_person_id                    in      number
  ,p_object_version_number        in out nocopy  number
  ,p_person_type_id               in      number   default hr_api.g_number
  ,p_last_name_kana               in      varchar2 default hr_api.g_varchar2
  ,p_applicant_number             in      varchar2 default hr_api.g_varchar2
  ,p_comments                     in      varchar2 default hr_api.g_varchar2
  ,p_date_employee_data_verified  in      date     default hr_api.g_date
  ,p_date_of_birth                in      date     default hr_api.g_date
  ,p_email_address                in      varchar2 default hr_api.g_varchar2
  ,p_employee_number              in out nocopy  varchar2
  ,p_expense_check_send_to_addres in      varchar2 default hr_api.g_varchar2
  ,p_first_name_kana              in      varchar2 default hr_api.g_varchar2
  ,p_known_as                     in      varchar2 default hr_api.g_varchar2
  ,p_marital_status               in      varchar2 default hr_api.g_varchar2
  ,p_middle_names                 in      varchar2 default hr_api.g_varchar2
  ,p_nationality                  in      varchar2 default hr_api.g_varchar2
  ,p_national_identifier          in      varchar2 default hr_api.g_varchar2
  ,p_previous_last_name_kana      in      varchar2 default hr_api.g_varchar2
  ,p_registered_disabled_flag     in      varchar2 default hr_api.g_varchar2
  ,p_sex                          in      varchar2 default hr_api.g_varchar2
  ,p_title                        in      varchar2 default hr_api.g_varchar2
  ,p_vendor_id                    in      number   default hr_api.g_number
  ,p_work_telephone               in      varchar2 default hr_api.g_varchar2
  ,p_attribute_category           in      varchar2 default hr_api.g_varchar2
  ,p_attribute1                   in      varchar2 default hr_api.g_varchar2
  ,p_attribute2                   in      varchar2 default hr_api.g_varchar2
  ,p_attribute3                   in      varchar2 default hr_api.g_varchar2
  ,p_attribute4                   in      varchar2 default hr_api.g_varchar2
  ,p_attribute5                   in      varchar2 default hr_api.g_varchar2
  ,p_attribute6                   in      varchar2 default hr_api.g_varchar2
  ,p_attribute7                   in      varchar2 default hr_api.g_varchar2
  ,p_attribute8                   in      varchar2 default hr_api.g_varchar2
  ,p_attribute9                   in      varchar2 default hr_api.g_varchar2
  ,p_attribute10                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute11                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute12                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute13                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute14                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute15                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute16                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute17                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute18                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute19                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute20                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute21                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute22                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute23                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute24                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute25                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute26                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute27                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute28                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute29                  in      varchar2 default hr_api.g_varchar2
  ,p_attribute30                  in      varchar2 default hr_api.g_varchar2
  ,p_last_name                    in      varchar2 default hr_api.g_varchar2
  ,p_first_name                   in      varchar2 default hr_api.g_varchar2
  ,p_previous_last_name           in      varchar2 default hr_api.g_varchar2
  ,p_suffix                       in      varchar2 default hr_api.g_varchar2
  ,p_effective_start_date            out nocopy  date
  ,p_effective_end_date              out nocopy  date
  ,p_full_name                       out nocopy  varchar2
  ,p_comment_id                      out nocopy  number
  ,p_name_combination_warning        out nocopy  boolean
  ,p_assign_payroll_warning          out nocopy  boolean
  ,p_orig_hire_warning               out nocopy  boolean
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                 varchar2(72) := g_package||'update_jp_person';
  l_effective_date       date;
  l_legislation_code     per_business_groups.legislation_code%type;
  l_discard_varchar2     varchar2(30);
  --
  cursor check_legislation
    (c_person_id      per_people_f.person_id%TYPE,
     c_effective_date date
    )
  is
    select bgp.legislation_code
    from per_people_f per,
         per_business_groups bgp
    where per.business_group_id = bgp.business_group_id
    and   per.person_id     = c_person_id
    and   c_effective_date
      between per.effective_start_date and per.effective_end_date;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Initialise local variables
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Validation in addition to Row Handlers
  --
  -- Check that the person exists.
  --
  open check_legislation(p_person_id, l_effective_date);
  fetch check_legislation into l_legislation_code;
  if check_legislation%notfound then
    close check_legislation;
    hr_utility.set_message(801,'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  end if;
  close check_legislation;
  hr_utility.set_location(l_proc, 20);
  --
  -- Check that the legislation of the specified business group is 'JP'.
  --
  if l_legislation_code <> 'JP' then
    hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
    hr_utility.set_message_token('LEG_CODE','JP');
    hr_utility.raise_error;
  end if;
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
    ,p_last_name                    => p_last_name_kana
    ,p_applicant_number             => p_applicant_number
    ,p_comments                     => p_comments
    ,p_date_employee_data_verified  => p_date_employee_data_verified
    ,p_date_of_birth                => p_date_of_birth
    ,p_email_address                => p_email_address
    ,p_employee_number              => p_employee_number
    ,p_expense_check_send_to_addres => p_expense_check_send_to_addres
    ,p_first_name                   => p_first_name_kana
    ,p_known_as                     => p_known_as
    ,p_marital_status               => p_marital_status
    ,p_middle_names                 => p_middle_names
    ,p_nationality                  => p_nationality
    ,p_national_identifier          => p_national_identifier
    ,p_previous_last_name           => p_previous_last_name_kana
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
    ,p_per_information_category     => 'JP'
    ,p_per_information18            => p_last_name
    ,p_per_information19            => p_first_name
    ,p_per_information20            => p_previous_last_name
    ,p_suffix                       => p_suffix
    ,p_effective_start_date         => p_effective_start_date
    ,p_effective_end_date           => p_effective_end_date
    ,p_full_name                    => p_full_name
    ,p_comment_id                   => p_comment_id
    ,p_name_combination_warning     => p_name_combination_warning
    ,p_assign_payroll_warning       => p_assign_payroll_warning
    ,p_orig_hire_warning            => p_orig_hire_warning
    );
  hr_utility.set_location('Leaving: '||l_proc, 40);
  --
end update_jp_person;
--
end hr_jp_person_api;

/
