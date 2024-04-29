--------------------------------------------------------
--  DDL for Package Body HR_EMPLOYEE_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_EMPLOYEE_SWI" As
/* $Header: hrempswi.pkb 120.1 2005/09/13 15:04:00 ndorai noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'hr_employee_swi.';
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_employee >---------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_employee
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_hire_date                    in     date
  ,p_business_group_id            in     number
  ,p_last_name                    in     varchar2
  ,p_sex                          in     varchar2
  ,p_person_type_id               in     number    default null
  ,p_per_comments                 in     varchar2  default null
  ,p_date_employee_data_verified  in     date      default null
  ,p_date_of_birth                in     date      default null
  ,p_email_address                in     varchar2  default null
  ,p_employee_number              in out nocopy varchar2
  ,p_expense_check_send_to_addres in     varchar2  default null
  ,p_first_name                   in     varchar2  default null
  ,p_known_as                     in     varchar2  default null
  ,p_marital_status               in     varchar2  default null
  ,p_middle_names                 in     varchar2  default null
  ,p_nationality                  in     varchar2  default null
  ,p_national_identifier          in     varchar2  default null
  ,p_previous_last_name           in     varchar2  default null
  ,p_registered_disabled_flag     in     varchar2  default null
  ,p_title                        in     varchar2  default null
  ,p_vendor_id                    in     number    default null
  ,p_work_telephone               in     varchar2  default null
  ,p_attribute_category           in     varchar2  default null
  ,p_attribute1                   in     varchar2  default null
  ,p_attribute2                   in     varchar2  default null
  ,p_attribute3                   in     varchar2  default null
  ,p_attribute4                   in     varchar2  default null
  ,p_attribute5                   in     varchar2  default null
  ,p_attribute6                   in     varchar2  default null
  ,p_attribute7                   in     varchar2  default null
  ,p_attribute8                   in     varchar2  default null
  ,p_attribute9                   in     varchar2  default null
  ,p_attribute10                  in     varchar2  default null
  ,p_attribute11                  in     varchar2  default null
  ,p_attribute12                  in     varchar2  default null
  ,p_attribute13                  in     varchar2  default null
  ,p_attribute14                  in     varchar2  default null
  ,p_attribute15                  in     varchar2  default null
  ,p_attribute16                  in     varchar2  default null
  ,p_attribute17                  in     varchar2  default null
  ,p_attribute18                  in     varchar2  default null
  ,p_attribute19                  in     varchar2  default null
  ,p_attribute20                  in     varchar2  default null
  ,p_attribute21                  in     varchar2  default null
  ,p_attribute22                  in     varchar2  default null
  ,p_attribute23                  in     varchar2  default null
  ,p_attribute24                  in     varchar2  default null
  ,p_attribute25                  in     varchar2  default null
  ,p_attribute26                  in     varchar2  default null
  ,p_attribute27                  in     varchar2  default null
  ,p_attribute28                  in     varchar2  default null
  ,p_attribute29                  in     varchar2  default null
  ,p_attribute30                  in     varchar2  default null
  ,p_per_information_category     in     varchar2  default null
  ,p_per_information1             in     varchar2  default null
  ,p_per_information2             in     varchar2  default null
  ,p_per_information3             in     varchar2  default null
  ,p_per_information4             in     varchar2  default null
  ,p_per_information5             in     varchar2  default null
  ,p_per_information6             in     varchar2  default null
  ,p_per_information7             in     varchar2  default null
  ,p_per_information8             in     varchar2  default null
  ,p_per_information9             in     varchar2  default null
  ,p_per_information10            in     varchar2  default null
  ,p_per_information11            in     varchar2  default null
  ,p_per_information12            in     varchar2  default null
  ,p_per_information13            in     varchar2  default null
  ,p_per_information14            in     varchar2  default null
  ,p_per_information15            in     varchar2  default null
  ,p_per_information16            in     varchar2  default null
  ,p_per_information17            in     varchar2  default null
  ,p_per_information18            in     varchar2  default null
  ,p_per_information19            in     varchar2  default null
  ,p_per_information20            in     varchar2  default null
  ,p_per_information21            in     varchar2  default null
  ,p_per_information22            in     varchar2  default null
  ,p_per_information23            in     varchar2  default null
  ,p_per_information24            in     varchar2  default null
  ,p_per_information25            in     varchar2  default null
  ,p_per_information26            in     varchar2  default null
  ,p_per_information27            in     varchar2  default null
  ,p_per_information28            in     varchar2  default null
  ,p_per_information29            in     varchar2  default null
  ,p_per_information30            in     varchar2  default null
  ,p_date_of_death                in     date      default null
  ,p_background_check_status      in     varchar2  default null
  ,p_background_date_check        in     date      default null
  ,p_blood_type                   in     varchar2  default null
  ,p_correspondence_language      in     varchar2  default null
  ,p_fast_path_employee           in     varchar2  default null
  ,p_fte_capacity                 in     number    default null
  ,p_honors                       in     varchar2  default null
  ,p_internal_location            in     varchar2  default null
  ,p_last_medical_test_by         in     varchar2  default null
  ,p_last_medical_test_date       in     date      default null
  ,p_mailstop                     in     varchar2  default null
  ,p_office_number                in     varchar2  default null
  ,p_on_military_service          in     varchar2  default null
  ,p_pre_name_adjunct             in     varchar2  default null
  ,p_projected_start_date         in     date      default null
  ,p_resume_exists                in     varchar2  default null
  ,p_resume_last_updated          in     date      default null
  ,p_second_passport_exists       in     varchar2  default null
  ,p_student_status               in     varchar2  default null
  ,p_work_schedule                in     varchar2  default null
  ,p_suffix                       in     varchar2  default null
  ,p_benefit_group_id             in     number    default null
  ,p_receipt_of_death_cert_date   in     date      default null
  ,p_coord_ben_med_pln_no         in     varchar2  default null
  ,p_coord_ben_no_cvg_flag        in     varchar2  default null
  ,p_coord_ben_med_ext_er         in     varchar2  default null
  ,p_coord_ben_med_pl_name        in     varchar2  default null
  ,p_coord_ben_med_insr_crr_name  in     varchar2  default null
  ,p_coord_ben_med_insr_crr_ident in     varchar2  default null
  ,p_coord_ben_med_cvg_strt_dt    in     date      default null
  ,p_coord_ben_med_cvg_end_dt     in     date      default null
  ,p_uses_tobacco_flag            in     varchar2  default null
  ,p_dpdnt_adoption_date          in     date      default null
  ,p_dpdnt_vlntry_svce_flag       in     varchar2  default null
  ,p_original_date_of_hire        in     date      default null
  ,p_adjusted_svc_date            in     date      default null
  ,p_town_of_birth                in     varchar2  default null
  ,p_region_of_birth              in     varchar2  default null
  ,p_country_of_birth             in     varchar2  default null
  ,p_global_person_id             in     varchar2  default null
  ,p_party_id                     in     number    default null
  ,p_person_id                       out nocopy number
  ,p_assignment_id                   out nocopy number
  ,p_per_object_version_number       out nocopy number
  ,p_asg_object_version_number       out nocopy number
  ,p_per_effective_start_date        out nocopy date
  ,p_per_effective_end_date          out nocopy date
  ,p_full_name                       out nocopy varchar2
  ,p_per_comment_id                  out nocopy number
  ,p_assignment_sequence             out nocopy number
  ,p_assignment_number               out nocopy varchar2
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  l_name_combination_warning      boolean;
  l_assign_payroll_warning        boolean;
  l_orig_hire_warning             boolean;
  --
  -- Variables for IN/OUT parameters
  l_employee_number               varchar2(240);
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'create_employee';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_employee_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  l_employee_number               := p_employee_number;
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => p_validate);
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  hr_employee_api.create_employee
    (p_validate                     => l_validate
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
    ,p_per_information_category     => p_per_information_category
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
    ,p_name_combination_warning     => l_name_combination_warning
    ,p_assign_payroll_warning       => l_assign_payroll_warning
    ,p_orig_hire_warning            => l_orig_hire_warning
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  if l_name_combination_warning then
     fnd_message.set_name('PER', 'PER_52076_PER_NULL_LAST_NAME');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;
  if l_assign_payroll_warning then
     fnd_message.set_name('PER', 'HR_EMP_ASS_NO_DOB');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;
  if l_orig_hire_warning then
     fnd_message.set_name('PER', 'PER_52474_PER_ORIG_ST_DATE');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;  --
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  p_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to create_employee_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_employee_number              := l_employee_number;
    p_person_id                    := null;
    p_assignment_id                := null;
    p_per_object_version_number    := null;
    p_asg_object_version_number    := null;
    p_per_effective_start_date     := null;
    p_per_effective_end_date       := null;
    p_full_name                    := null;
    p_per_comment_id               := null;
    p_assignment_sequence          := null;
    p_assignment_number            := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc, 30);
  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to create_employee_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_employee_number              := l_employee_number;
    p_person_id                    := null;
    p_assignment_id                := null;
    p_per_object_version_number    := null;
    p_asg_object_version_number    := null;
    p_per_effective_start_date     := null;
    p_per_effective_end_date       := null;
    p_full_name                    := null;
    p_per_comment_id               := null;
    p_assignment_sequence          := null;
    p_assignment_number            := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_employee;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_employee >---------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_employee
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_hire_date                    in     date
  ,p_business_group_id            in     number
  ,p_last_name                    in     varchar2
  ,p_sex                          in     varchar2
  ,p_person_type_id               in     number    default null
  ,p_per_comments                 in     varchar2  default null
  ,p_date_employee_data_verified  in     date      default null
  ,p_date_of_birth                in     date      default null
  ,p_email_address                in     varchar2  default null
  ,p_employee_number              in out nocopy varchar2
  ,p_expense_check_send_to_addres in     varchar2  default null
  ,p_first_name                   in     varchar2  default null
  ,p_known_as                     in     varchar2  default null
  ,p_marital_status               in     varchar2  default null
  ,p_middle_names                 in     varchar2  default null
  ,p_nationality                  in     varchar2  default null
  ,p_national_identifier          in     varchar2  default null
  ,p_previous_last_name           in     varchar2  default null
  ,p_registered_disabled_flag     in     varchar2  default null
  ,p_title                        in     varchar2  default null
  ,p_vendor_id                    in     number    default null
  ,p_work_telephone               in     varchar2  default null
  ,p_attribute_category           in     varchar2  default null
  ,p_attribute1                   in     varchar2  default null
  ,p_attribute2                   in     varchar2  default null
  ,p_attribute3                   in     varchar2  default null
  ,p_attribute4                   in     varchar2  default null
  ,p_attribute5                   in     varchar2  default null
  ,p_attribute6                   in     varchar2  default null
  ,p_attribute7                   in     varchar2  default null
  ,p_attribute8                   in     varchar2  default null
  ,p_attribute9                   in     varchar2  default null
  ,p_attribute10                  in     varchar2  default null
  ,p_attribute11                  in     varchar2  default null
  ,p_attribute12                  in     varchar2  default null
  ,p_attribute13                  in     varchar2  default null
  ,p_attribute14                  in     varchar2  default null
  ,p_attribute15                  in     varchar2  default null
  ,p_attribute16                  in     varchar2  default null
  ,p_attribute17                  in     varchar2  default null
  ,p_attribute18                  in     varchar2  default null
  ,p_attribute19                  in     varchar2  default null
  ,p_attribute20                  in     varchar2  default null
  ,p_attribute21                  in     varchar2  default null
  ,p_attribute22                  in     varchar2  default null
  ,p_attribute23                  in     varchar2  default null
  ,p_attribute24                  in     varchar2  default null
  ,p_attribute25                  in     varchar2  default null
  ,p_attribute26                  in     varchar2  default null
  ,p_attribute27                  in     varchar2  default null
  ,p_attribute28                  in     varchar2  default null
  ,p_attribute29                  in     varchar2  default null
  ,p_attribute30                  in     varchar2  default null
  ,p_per_information_category     in     varchar2  default null
  ,p_per_information1             in     varchar2  default null
  ,p_per_information2             in     varchar2  default null
  ,p_per_information3             in     varchar2  default null
  ,p_per_information4             in     varchar2  default null
  ,p_per_information5             in     varchar2  default null
  ,p_per_information6             in     varchar2  default null
  ,p_per_information7             in     varchar2  default null
  ,p_per_information8             in     varchar2  default null
  ,p_per_information9             in     varchar2  default null
  ,p_per_information10            in     varchar2  default null
  ,p_per_information11            in     varchar2  default null
  ,p_per_information12            in     varchar2  default null
  ,p_per_information13            in     varchar2  default null
  ,p_per_information14            in     varchar2  default null
  ,p_per_information15            in     varchar2  default null
  ,p_per_information16            in     varchar2  default null
  ,p_per_information17            in     varchar2  default null
  ,p_per_information18            in     varchar2  default null
  ,p_per_information19            in     varchar2  default null
  ,p_per_information20            in     varchar2  default null
  ,p_per_information21            in     varchar2  default null
  ,p_per_information22            in     varchar2  default null
  ,p_per_information23            in     varchar2  default null
  ,p_per_information24            in     varchar2  default null
  ,p_per_information25            in     varchar2  default null
  ,p_per_information26            in     varchar2  default null
  ,p_per_information27            in     varchar2  default null
  ,p_per_information28            in     varchar2  default null
  ,p_per_information29            in     varchar2  default null
  ,p_per_information30            in     varchar2  default null
  ,p_date_of_death                in     date      default null
  ,p_background_check_status      in     varchar2  default null
  ,p_background_date_check        in     date      default null
  ,p_blood_type                   in     varchar2  default null
  ,p_correspondence_language      in     varchar2  default null
  ,p_fast_path_employee           in     varchar2  default null
  ,p_fte_capacity                 in     number    default null
  ,p_honors                       in     varchar2  default null
  ,p_internal_location            in     varchar2  default null
  ,p_last_medical_test_by         in     varchar2  default null
  ,p_last_medical_test_date       in     date      default null
  ,p_mailstop                     in     varchar2  default null
  ,p_office_number                in     varchar2  default null
  ,p_on_military_service          in     varchar2  default null
  ,p_pre_name_adjunct             in     varchar2  default null
  ,p_projected_start_date         in     date      default null
  ,p_resume_exists                in     varchar2  default null
  ,p_resume_last_updated          in     date      default null
  ,p_second_passport_exists       in     varchar2  default null
  ,p_student_status               in     varchar2  default null
  ,p_work_schedule                in     varchar2  default null
  ,p_suffix                       in     varchar2  default null
  ,p_benefit_group_id             in     number    default null
  ,p_receipt_of_death_cert_date   in     date      default null
  ,p_coord_ben_med_pln_no         in     varchar2  default null
  ,p_coord_ben_no_cvg_flag        in     varchar2  default null
  ,p_coord_ben_med_ext_er         in     varchar2  default null
  ,p_coord_ben_med_pl_name        in     varchar2  default null
  ,p_coord_ben_med_insr_crr_name  in     varchar2  default null
  ,p_coord_ben_med_insr_crr_ident in     varchar2  default null
  ,p_coord_ben_med_cvg_strt_dt    in     date      default null
  ,p_coord_ben_med_cvg_end_dt     in     date      default null
  ,p_uses_tobacco_flag            in     varchar2  default null
  ,p_dpdnt_adoption_date          in     date      default null
  ,p_dpdnt_vlntry_svce_flag       in     varchar2  default null
  ,p_original_date_of_hire        in     date      default null
  ,p_adjusted_svc_date            in     date      default null
  ,p_town_of_birth                in     varchar2  default null
  ,p_region_of_birth              in     varchar2  default null
  ,p_country_of_birth             in     varchar2  default null
  ,p_global_person_id             in     varchar2  default null
  ,p_party_id                     in     number    default null
  ,p_person_id                       out nocopy number
  ,p_assignment_id                   out nocopy number
  ,p_per_object_version_number       out nocopy number
  ,p_asg_object_version_number       out nocopy number
  ,p_per_effective_start_date        out nocopy date
  ,p_per_effective_end_date          out nocopy date
  ,p_full_name                       out nocopy varchar2
  ,p_per_comment_id                  out nocopy number
  ,p_assignment_sequence             out nocopy number
  ,p_assignment_number               out nocopy varchar2
  ,p_return_status                   out nocopy varchar2
  ,p_addr_validate                     in     number    default hr_api.g_false_num
  ,p_addr_effective_date               in     date
  ,p_pradd_ovlapval_override           in     number    default null
  ,p_addr_validate_county              in     number    default null
  ,p_addr_person_id                    in     number    default null
  ,p_addr_primary_flag                 in     varchar2
  ,p_addr_style                        in     varchar2
  ,p_addr_date_from                    in     date
  ,p_addr_date_to                      in     date      default null
  ,p_addr_address_type                 in     varchar2  default null
  ,p_addr_comments                     in     long      default null
  ,p_addr_address_line1                in     varchar2  default null
  ,p_addr_address_line2                in     varchar2  default null
  ,p_addr_address_line3                in     varchar2  default null
  ,p_addr_town_or_city                 in     varchar2  default null
  ,p_addr_region_1                     in     varchar2  default null
  ,p_addr_region_2                     in     varchar2  default null
  ,p_addr_region_3                     in     varchar2  default null
  ,p_addr_postal_code                  in     varchar2  default null
  ,p_addr_country                      in     varchar2  default null
  ,p_addr_telephone_number_1           in     varchar2  default null
  ,p_addr_telephone_number_2           in     varchar2  default null
  ,p_addr_telephone_number_3           in     varchar2  default null
  ,p_addr_attribute_category      in     varchar2  default null
  ,p_addr_attribute1              in     varchar2  default null
  ,p_addr_attribute2              in     varchar2  default null
  ,p_addr_attribute3              in     varchar2  default null
  ,p_addr_attribute4              in     varchar2  default null
  ,p_addr_attribute5              in     varchar2  default null
  ,p_addr_attribute6              in     varchar2  default null
  ,p_addr_attribute7              in     varchar2  default null
  ,p_addr_attribute8              in     varchar2  default null
  ,p_addr_attribute9              in     varchar2  default null
  ,p_addr_attribute10             in     varchar2  default null
  ,p_addr_attribute11             in     varchar2  default null
  ,p_addr_attribute12             in     varchar2  default null
  ,p_addr_attribute13             in     varchar2  default null
  ,p_addr_attribute14             in     varchar2  default null
  ,p_addr_attribute15             in     varchar2  default null
  ,p_addr_attribute16             in     varchar2  default null
  ,p_addr_attribute17             in     varchar2  default null
  ,p_addr_attribute18             in     varchar2  default null
  ,p_addr_attribute19             in     varchar2  default null
  ,p_addr_attribute20             in     varchar2  default null
  ,p_addr_add_information13            in     varchar2  default null
  ,p_addr_add_information14            in     varchar2  default null
  ,p_addr_add_information15            in     varchar2  default null
  ,p_addr_add_information16            in     varchar2  default null
  ,p_addr_add_information17            in     varchar2  default null
  ,p_addr_add_information18            in     varchar2  default null
  ,p_addr_add_information19            in     varchar2  default null
  ,p_addr_add_information20            in     varchar2  default null
  ,p_addr_party_id                     in     number    default null
  ,p_addr_address_id                   in     number
  ,p_addr_object_version_number           out nocopy number
  ,p_addr_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  l_name_combination_warning      boolean;
  l_assign_payroll_warning        boolean;
  l_orig_hire_warning             boolean;
  --
  -- Variables for IN/OUT parameters
  l_employee_number               varchar2(240);
  l_addr_return_status            varchar2(1);
  l_addr_ovn                      number(3);
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'create_employee';
--
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_employee_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  l_employee_number               := p_employee_number;
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => p_validate);
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  hr_employee_api.create_employee
    (p_validate                     => l_validate
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
    ,p_per_information_category     => p_per_information_category
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
    ,p_name_combination_warning     => l_name_combination_warning
    ,p_assign_payroll_warning       => l_assign_payroll_warning
    ,p_orig_hire_warning            => l_orig_hire_warning
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  if l_name_combination_warning then
     fnd_message.set_name('PER', 'PER_52076_PER_NULL_LAST_NAME');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;
  if l_assign_payroll_warning then
     fnd_message.set_name('PER', 'HR_EMP_ASS_NO_DOB');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;
  if l_orig_hire_warning then
     fnd_message.set_name('PER', 'PER_52474_PER_ORIG_ST_DATE');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;  --
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --

  hr_person_address_swi.create_person_address
    (p_validate                     => p_addr_validate
    ,p_effective_date               => p_addr_effective_date
    ,p_pradd_ovlapval_override      => p_pradd_ovlapval_override
    ,p_validate_county              => p_addr_validate_county
    ,p_person_id                    => p_person_id
    ,p_primary_flag                 => p_addr_primary_flag
    ,p_style                        => p_addr_style
    ,p_date_from                    => p_addr_date_from
    ,p_date_to                      => p_addr_date_to
    ,p_address_type                 => p_addr_address_type
    ,p_comments                     => p_addr_comments
    ,p_address_line1                => p_addr_address_line1
    ,p_address_line2                => p_addr_address_line2
    ,p_address_line3                => p_addr_address_line3
    ,p_town_or_city                 => p_addr_town_or_city
    ,p_region_1                     => p_addr_region_1
    ,p_region_2                     => p_addr_region_2
    ,p_region_3                     => p_addr_region_3
    ,p_postal_code                  => p_addr_postal_code
    ,p_country                      => p_addr_country
    ,p_telephone_number_1           => p_addr_telephone_number_1
    ,p_telephone_number_2           => p_addr_telephone_number_2
    ,p_telephone_number_3           => p_addr_telephone_number_3
    ,p_addr_attribute_category      => p_addr_attribute_category
    ,p_addr_attribute1              => p_addr_attribute1
    ,p_addr_attribute2              => p_addr_attribute2
    ,p_addr_attribute3              => p_addr_attribute3
    ,p_addr_attribute4              => p_addr_attribute4
    ,p_addr_attribute5              => p_addr_attribute5
    ,p_addr_attribute6              => p_addr_attribute6
    ,p_addr_attribute7              => p_addr_attribute7
    ,p_addr_attribute8              => p_addr_attribute8
    ,p_addr_attribute9              => p_addr_attribute9
    ,p_addr_attribute10             => p_addr_attribute10
    ,p_addr_attribute11             => p_addr_attribute11
    ,p_addr_attribute12             => p_addr_attribute12
    ,p_addr_attribute13             => p_addr_attribute13
    ,p_addr_attribute14             => p_addr_attribute14
    ,p_addr_attribute15             => p_addr_attribute15
    ,p_addr_attribute16             => p_addr_attribute16
    ,p_addr_attribute17             => p_addr_attribute17
    ,p_addr_attribute18             => p_addr_attribute18
    ,p_addr_attribute19             => p_addr_attribute19
    ,p_addr_attribute20             => p_addr_attribute20
    ,p_add_information13            => p_addr_add_information13
    ,p_add_information14            => p_addr_add_information14
    ,p_add_information15            => p_addr_add_information15
    ,p_add_information16            => p_addr_add_information16
    ,p_add_information17            => p_addr_add_information17
    ,p_add_information18            => p_addr_add_information18
    ,p_add_information19            => p_addr_add_information19
    ,p_add_information20            => p_addr_add_information20
    ,p_party_id                     => p_addr_party_id
    ,p_address_id                   => p_addr_address_id
    ,p_object_version_number        => l_addr_ovn
    ,p_return_status                => l_addr_return_status
    );

  p_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to create_employee_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_employee_number              := l_employee_number;
    p_person_id                    := null;
    p_assignment_id                := null;
    p_per_object_version_number    := null;
    p_asg_object_version_number    := null;
    p_per_effective_start_date     := null;
    p_per_effective_end_date       := null;
    p_full_name                    := null;
    p_per_comment_id               := null;
    p_assignment_sequence          := null;
    p_assignment_number            := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc, 30);
  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to create_employee_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_employee_number              := l_employee_number;
    p_person_id                    := null;
    p_assignment_id                := null;
    p_per_object_version_number    := null;
    p_asg_object_version_number    := null;
    p_per_effective_start_date     := null;
    p_per_effective_end_date       := null;
    p_full_name                    := null;
    p_per_comment_id               := null;
    p_assignment_sequence          := null;
    p_assignment_number            := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_employee;
-- ----------------------------------------------------------------------------
-- |----------------------< apply_for_internal_vacancy >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE apply_for_internal_vacancy
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_person_id                    in     number
  ,p_applicant_number             in out nocopy varchar2
  ,p_per_object_version_number    in out nocopy number
  ,p_vacancy_id                   in     number    default hr_api.g_number
  ,p_person_type_id               in     number    default hr_api.g_number
  ,p_application_id                  out nocopy number
  ,p_assignment_id                   out nocopy number
  ,p_apl_object_version_number       out nocopy number
  ,p_asg_object_version_number       out nocopy number
  ,p_assignment_sequence             out nocopy number
  ,p_per_effective_start_date        out nocopy date
  ,p_per_effective_end_date          out nocopy date
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  l_applicant_number              varchar2(240);
  l_per_object_version_number     number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'apply_for_internal_vacancy';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint apply_for_internal_vacancy_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  l_applicant_number              := p_applicant_number;
  l_per_object_version_number     := p_per_object_version_number;
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => p_validate);
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  hr_employee_api.apply_for_internal_vacancy
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_person_id                    => p_person_id
    ,p_applicant_number             => p_applicant_number
    ,p_per_object_version_number    => p_per_object_version_number
    ,p_vacancy_id                   => p_vacancy_id
    ,p_person_type_id               => p_person_type_id
    ,p_application_id               => p_application_id
    ,p_assignment_id                => p_assignment_id
    ,p_apl_object_version_number    => p_apl_object_version_number
    ,p_asg_object_version_number    => p_asg_object_version_number
    ,p_assignment_sequence          => p_assignment_sequence
    ,p_per_effective_start_date     => p_per_effective_start_date
    ,p_per_effective_end_date       => p_per_effective_end_date
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  --
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  p_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to apply_for_internal_vacancy_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_applicant_number             := l_applicant_number;
    p_per_object_version_number    := l_per_object_version_number;
    p_application_id               := null;
    p_assignment_id                := null;
    p_apl_object_version_number    := null;
    p_asg_object_version_number    := null;
    p_assignment_sequence          := null;
    p_per_effective_start_date     := null;
    p_per_effective_end_date       := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc, 30);
  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to apply_for_internal_vacancy_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_applicant_number             := l_applicant_number;
    p_per_object_version_number    := l_per_object_version_number;
    p_application_id               := null;
    p_assignment_id                := null;
    p_apl_object_version_number    := null;
    p_asg_object_version_number    := null;
    p_assignment_sequence          := null;
    p_per_effective_start_date     := null;
    p_per_effective_end_date       := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end apply_for_internal_vacancy;
-- ----------------------------------------------------------------------------
-- |-----------------------------< hire_into_job >----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE hire_into_job
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_person_id                    in     number
  ,p_object_version_number        in out nocopy number
  ,p_employee_number              in out nocopy varchar2
  ,p_datetrack_update_mode        in     varchar2  default hr_api.g_varchar2
  ,p_person_type_id               in     number    default hr_api.g_number
  ,p_national_identifier          in     varchar2  default hr_api.g_varchar2
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  l_assign_payroll_warning        boolean;
  l_orig_hire_warning             boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  l_employee_number               varchar2(240);
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'hire_into_job';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint hire_into_job_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  l_object_version_number         := p_object_version_number;
  l_employee_number               := p_employee_number;
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => p_validate);
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  hr_employee_api.hire_into_job
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_person_id                    => p_person_id
    ,p_object_version_number        => p_object_version_number
    ,p_employee_number              => p_employee_number
    ,p_datetrack_update_mode        => p_datetrack_update_mode
    ,p_person_type_id               => p_person_type_id
    ,p_national_identifier          => p_national_identifier
    ,p_effective_start_date         => p_effective_start_date
    ,p_effective_end_date           => p_effective_end_date
    ,p_assign_payroll_warning       => l_assign_payroll_warning
    ,p_orig_hire_warning            => l_orig_hire_warning
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  if l_assign_payroll_warning then
     fnd_message.set_name('PER', 'HR_EMP_ASS_NO_DOB');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;
  if l_orig_hire_warning then
     fnd_message.set_name('PER', 'PER_52474_PER_ORIG_ST_DATE');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;  --
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  p_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to hire_into_job_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_employee_number              := l_employee_number;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc, 30);
  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to hire_into_job_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_employee_number              := l_employee_number;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end hire_into_job;
-- ----------------------------------------------------------------------------
-- |--------------------------< re_hire_ex_employee >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE re_hire_ex_employee
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_hire_date                    in     date
  ,p_person_id                    in     number
  ,p_per_object_version_number    in out nocopy number
  ,p_person_type_id               in     number    default hr_api.g_number
  ,p_rehire_reason                in     varchar2
  ,p_assignment_id                   out nocopy number
  ,p_asg_object_version_number       out nocopy number
  ,p_per_effective_start_date        out nocopy date
  ,p_per_effective_end_date          out nocopy date
  ,p_assignment_sequence             out nocopy number
  ,p_assignment_number               out nocopy varchar2
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  l_assign_payroll_warning        boolean;
  --
  -- Variables for IN/OUT parameters
  l_per_object_version_number     number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'re_hire_ex_employee';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint re_hire_ex_employee_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  l_per_object_version_number     := p_per_object_version_number;
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => p_validate);
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  hr_employee_api.re_hire_ex_employee
    (p_validate                     => l_validate
    ,p_hire_date                    => p_hire_date
    ,p_person_id                    => p_person_id
    ,p_per_object_version_number    => p_per_object_version_number
    ,p_person_type_id               => p_person_type_id
    ,p_rehire_reason                => p_rehire_reason
    ,p_assignment_id                => p_assignment_id
    ,p_asg_object_version_number    => p_asg_object_version_number
    ,p_per_effective_start_date     => p_per_effective_start_date
    ,p_per_effective_end_date       => p_per_effective_end_date
    ,p_assignment_sequence          => p_assignment_sequence
    ,p_assignment_number            => p_assignment_number
    ,p_assign_payroll_warning       => l_assign_payroll_warning
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  if l_assign_payroll_warning then
     fnd_message.set_name('PER', 'HR_EMP_ASS_NO_DOB');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;  --
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  p_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to re_hire_ex_employee_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_per_object_version_number    := l_per_object_version_number;
    p_assignment_id                := null;
    p_asg_object_version_number    := null;
    p_per_effective_start_date     := null;
    p_per_effective_end_date       := null;
    p_assignment_sequence          := null;
    p_assignment_number            := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc, 30);
  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to re_hire_ex_employee_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_per_object_version_number    := l_per_object_version_number;
    p_assignment_id                := null;
    p_asg_object_version_number    := null;
    p_per_effective_start_date     := null;
    p_per_effective_end_date       := null;
    p_assignment_sequence          := null;
    p_assignment_number            := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end re_hire_ex_employee;
-- ----------------------------------------------------------------------------
-- |-------------------< convert_to_manual_gen_method >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE convert_to_manual_gen_method
    (errbuf              OUT nocopy varchar2
    ,retcode             OUT nocopy number
    ,p_business_group_id IN  number
    ) IS
  --
  --  Local variables
  --
  c_proc_name   varchar2(100) := g_package||'.convert_to_manual_gen_method';

  e_ResourceBusy      EXCEPTION;
      PRAGMA EXCEPTION_INIT(e_ResourceBusy, -54);

  TYPE t_bgRecord IS RECORD
    (
      org_id            HR_ORGANIZATION_INFORMATION.Organization_id%TYPE,
      emp_method        HR_ORGANIZATION_INFORMATION.Org_information2%TYPE,
      apl_method        HR_ORGANIZATION_INFORMATION.Org_information3%TYPE,
      cwk_method        HR_ORGANIZATION_INFORMATION.Org_information16%TYPE
    );

  l_message          varchar2(200) := null;

  l_organization_id  per_all_people_f.business_group_id%TYPE;
  l_rec_per_bg_groups t_bgRecord;
  --
  -- Returns the current method of number generation
  --
  cursor csr_method(cp_bg_id per_all_people.business_group_id%TYPE) is
     SELECT organization_id,
            org_information2,
            org_information3,
            org_information16
       FROM hr_organization_information
      WHERE organization_id = cp_bg_id
        AND ORG_INFORMATION_CONTEXT  = 'Business Group Information'
      FOR UPDATE of Org_information3          -- method_of_generation_apl_num
                  , Org_information2          -- method_of_generation_emp_num
                  , Org_information16 NOWAIT; -- method_of_generation_cwk_num
BEGIN
   --hr_utility.trace_on(null,'oracle');

   hr_utility.set_location('Entering: '||c_proc_name,10);
   hr_utility.trace('Parameters:');
   hr_utility.trace('  business_group_id = '||to_char(p_business_group_id));
   --
   BEGIN
     l_organization_id := p_business_group_id;

     -- Lock per_all_people_f to ensure person records are not
     -- created/updated/deleted
     --
     hr_utility.set_location(c_proc_name,20);

     --LOCK TABLE per_all_people_f
     -- IN EXCLUSIVE MODE NOWAIT;
     --
     open csr_method(p_business_group_id);
     fetch csr_method into l_rec_per_bg_groups;

     if csr_method%FOUND then

        hr_utility.set_location(c_proc_name,30);
        -- -------------------------------------------------------------+
        --  Processing Applicants, Employee, Contigent Workers          +
        -- -------------------------------------------------------------+

           hr_utility.set_location(c_proc_name,40);

           UPDATE HR_ORGANIZATION_INFORMATION
              SET org_information2  = 'M'  -- method_of_generation_emp_num
                 /*,org_information3  = 'M'  -- method_of_generation_apl_num
                 ,org_information16 = 'M'  -- method_of_generation_cwk_num
                 */
            WHERE organization_id = l_organization_id
              AND ORG_INFORMATION_CONTEXT  = 'Business Group Information';

           hr_utility.set_location(c_proc_name,40);

     end if; -- csr_method cursor
     --
     hr_utility.set_location(c_proc_name,50);
     --
     close csr_method;
  EXCEPTION
    WHEN TIMEOUT_ON_RESOURCE OR e_ResourceBusy THEN
         hr_utility.set_location(c_proc_name,60);
         -- The required resources are used by some other process.

         hr_utility.set_message(800,'PER_289849_RESOURCE_BUSY');
         hr_utility.raise_error;

    WHEN OTHERS THEN
         hr_utility.set_location(c_proc_name,70);
         hr_utility.trace(SQLERRM);

         RAISE;

   END; -- Lock table
   hr_utility.set_location('Leaving: '||c_proc_name,80);
   --hr_utility.trace_off;

END convert_to_manual_gen_method;
--
end hr_employee_swi;

/
