--------------------------------------------------------
--  DDL for Package Body HR_PERSON_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PERSON_SWI" As
/* $Header: hrperswi.pkb 115.4 2003/02/12 20:13:31 pzwalker ship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'hr_person_swi.';
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< update_person >----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_person
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_person_id                    in     number
  ,p_object_version_number        in out nocopy number
  ,p_person_type_id               in     number    default hr_api.g_number
  ,p_last_name                    in     varchar2  default hr_api.g_varchar2
  ,p_applicant_number             in     varchar2  default hr_api.g_varchar2
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_date_employee_data_verified  in     date      default hr_api.g_date
  ,p_date_of_birth                in     date      default hr_api.g_date
  ,p_email_address                in     varchar2  default hr_api.g_varchar2
  ,p_employee_number              in out nocopy varchar2
  ,p_expense_check_send_to_addres in     varchar2  default hr_api.g_varchar2
  ,p_first_name                   in     varchar2  default hr_api.g_varchar2
  ,p_known_as                     in     varchar2  default hr_api.g_varchar2
  ,p_marital_status               in     varchar2  default hr_api.g_varchar2
  ,p_middle_names                 in     varchar2  default hr_api.g_varchar2
  ,p_nationality                  in     varchar2  default hr_api.g_varchar2
  ,p_national_identifier          in     varchar2  default hr_api.g_varchar2
  ,p_previous_last_name           in     varchar2  default hr_api.g_varchar2
  ,p_registered_disabled_flag     in     varchar2  default hr_api.g_varchar2
  ,p_sex                          in     varchar2  default hr_api.g_varchar2
  ,p_title                        in     varchar2  default hr_api.g_varchar2
  ,p_vendor_id                    in     number    default hr_api.g_number
  ,p_work_telephone               in     varchar2  default hr_api.g_varchar2
  ,p_attribute_category           in     varchar2  default hr_api.g_varchar2
  ,p_attribute1                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute2                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute3                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute4                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute5                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute6                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute7                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute8                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute9                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute10                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute11                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute12                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute13                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute14                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute15                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute16                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute17                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute18                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute19                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute20                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute21                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute22                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute23                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute24                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute25                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute26                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute27                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute28                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute29                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute30                  in     varchar2  default hr_api.g_varchar2
  ,p_per_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_per_information1             in     varchar2  default hr_api.g_varchar2
  ,p_per_information2             in     varchar2  default hr_api.g_varchar2
  ,p_per_information3             in     varchar2  default hr_api.g_varchar2
  ,p_per_information4             in     varchar2  default hr_api.g_varchar2
  ,p_per_information5             in     varchar2  default hr_api.g_varchar2
  ,p_per_information6             in     varchar2  default hr_api.g_varchar2
  ,p_per_information7             in     varchar2  default hr_api.g_varchar2
  ,p_per_information8             in     varchar2  default hr_api.g_varchar2
  ,p_per_information9             in     varchar2  default hr_api.g_varchar2
  ,p_per_information10            in     varchar2  default hr_api.g_varchar2
  ,p_per_information11            in     varchar2  default hr_api.g_varchar2
  ,p_per_information12            in     varchar2  default hr_api.g_varchar2
  ,p_per_information13            in     varchar2  default hr_api.g_varchar2
  ,p_per_information14            in     varchar2  default hr_api.g_varchar2
  ,p_per_information15            in     varchar2  default hr_api.g_varchar2
  ,p_per_information16            in     varchar2  default hr_api.g_varchar2
  ,p_per_information17            in     varchar2  default hr_api.g_varchar2
  ,p_per_information18            in     varchar2  default hr_api.g_varchar2
  ,p_per_information19            in     varchar2  default hr_api.g_varchar2
  ,p_per_information20            in     varchar2  default hr_api.g_varchar2
  ,p_per_information21            in     varchar2  default hr_api.g_varchar2
  ,p_per_information22            in     varchar2  default hr_api.g_varchar2
  ,p_per_information23            in     varchar2  default hr_api.g_varchar2
  ,p_per_information24            in     varchar2  default hr_api.g_varchar2
  ,p_per_information25            in     varchar2  default hr_api.g_varchar2
  ,p_per_information26            in     varchar2  default hr_api.g_varchar2
  ,p_per_information27            in     varchar2  default hr_api.g_varchar2
  ,p_per_information28            in     varchar2  default hr_api.g_varchar2
  ,p_per_information29            in     varchar2  default hr_api.g_varchar2
  ,p_per_information30            in     varchar2  default hr_api.g_varchar2
  ,p_date_of_death                in     date      default hr_api.g_date
  ,p_background_check_status      in     varchar2  default hr_api.g_varchar2
  ,p_background_date_check        in     date      default hr_api.g_date
  ,p_blood_type                   in     varchar2  default hr_api.g_varchar2
  ,p_correspondence_language      in     varchar2  default hr_api.g_varchar2
  ,p_fast_path_employee           in     varchar2  default hr_api.g_varchar2
  ,p_fte_capacity                 in     number    default hr_api.g_number
  ,p_hold_applicant_date_until    in     date      default hr_api.g_date
  ,p_honors                       in     varchar2  default hr_api.g_varchar2
  ,p_internal_location            in     varchar2  default hr_api.g_varchar2
  ,p_last_medical_test_by         in     varchar2  default hr_api.g_varchar2
  ,p_last_medical_test_date       in     date      default hr_api.g_date
  ,p_mailstop                     in     varchar2  default hr_api.g_varchar2
  ,p_office_number                in     varchar2  default hr_api.g_varchar2
  ,p_on_military_service          in     varchar2  default hr_api.g_varchar2
  ,p_pre_name_adjunct             in     varchar2  default hr_api.g_varchar2
  ,p_projected_start_date         in     date      default hr_api.g_date
  ,p_rehire_authorizor            in     varchar2  default hr_api.g_varchar2
  ,p_rehire_recommendation        in     varchar2  default hr_api.g_varchar2
  ,p_resume_exists                in     varchar2  default hr_api.g_varchar2
  ,p_resume_last_updated          in     date      default hr_api.g_date
  ,p_second_passport_exists       in     varchar2  default hr_api.g_varchar2
  ,p_student_status               in     varchar2  default hr_api.g_varchar2
  ,p_work_schedule                in     varchar2  default hr_api.g_varchar2
  ,p_rehire_reason                in     varchar2  default hr_api.g_varchar2
  ,p_suffix                       in     varchar2  default hr_api.g_varchar2
  ,p_benefit_group_id             in     number    default hr_api.g_number
  ,p_receipt_of_death_cert_date   in     date      default hr_api.g_date
  ,p_coord_ben_med_pln_no         in     varchar2  default hr_api.g_varchar2
  ,p_coord_ben_no_cvg_flag        in     varchar2  default hr_api.g_varchar2
  ,p_coord_ben_med_ext_er         in     varchar2  default hr_api.g_varchar2
  ,p_coord_ben_med_pl_name        in     varchar2  default hr_api.g_varchar2
  ,p_coord_ben_med_insr_crr_name  in     varchar2  default hr_api.g_varchar2
  ,p_coord_ben_med_insr_crr_ident in     varchar2  default hr_api.g_varchar2
  ,p_coord_ben_med_cvg_strt_dt    in     date      default hr_api.g_date
  ,p_coord_ben_med_cvg_end_dt     in     date      default hr_api.g_date
  ,p_uses_tobacco_flag            in     varchar2  default hr_api.g_varchar2
  ,p_dpdnt_adoption_date          in     date      default hr_api.g_date
  ,p_dpdnt_vlntry_svce_flag       in     varchar2  default hr_api.g_varchar2
  ,p_original_date_of_hire        in     date      default hr_api.g_date
  ,p_adjusted_svc_date            in     date      default hr_api.g_date
  ,p_town_of_birth                in     varchar2  default hr_api.g_varchar2
  ,p_region_of_birth              in     varchar2  default hr_api.g_varchar2
  ,p_country_of_birth             in     varchar2  default hr_api.g_varchar2
  ,p_global_person_id             in     varchar2  default hr_api.g_varchar2
  ,p_party_id                     in     number    default hr_api.g_number
  ,p_npw_number                   in     varchar2  default hr_api.g_varchar2
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_party_last_update_date          out nocopy date
  ,p_full_name                       out nocopy varchar2
  ,p_comment_id                      out nocopy number
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
  l_object_version_number         number;
  l_employee_number               varchar2(30);
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_person';
  --
  -- Cursor to return party last update date
  cursor csr_party_last_update_date(p_party_id number,
                                    p_effective_date date) is
    select hzp.last_update_date
    from hz_person_profiles hzp
    where hzp.party_id = p_party_id
          and p_effective_date
              between hzp.effective_start_date
              and nvl(hzp.effective_end_date,hr_api.g_eot);
  --
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_person_swi;
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
  hr_person_api.update_person
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_datetrack_update_mode        => p_datetrack_update_mode
    ,p_person_id                    => p_person_id
    ,p_object_version_number        => p_object_version_number
    -- advised by core hr not to pass person_type_id
    -- bug 2660465
    --,p_person_type_id               => p_person_type_id
    ,p_last_name                    => p_last_name
    ,p_applicant_number             => p_applicant_number
    ,p_comments                     => p_comments
    ,p_date_employee_data_verified  => p_date_employee_data_verified
    ,p_date_of_birth                => p_date_of_birth
    ,p_email_address                => p_email_address
    ,p_employee_number              => l_employee_number
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
    ,p_country_of_birth             => p_country_of_birth
    ,p_global_person_id             => p_global_person_id
    ,p_party_id                     => p_party_id
    ,p_npw_number                   => p_npw_number
    ,p_effective_start_date         => p_effective_start_date
    ,p_effective_end_date           => p_effective_end_date
    ,p_full_name                    => p_full_name
    ,p_comment_id                   => p_comment_id
    ,p_name_combination_warning     => l_name_combination_warning
    ,p_assign_payroll_warning       => l_assign_payroll_warning
    ,p_orig_hire_warning            => l_orig_hire_warning
    );
  --
  -- set the party last update out parameter
  --
  open csr_party_last_update_date(p_party_id, p_effective_date);
  fetch csr_party_last_update_date into p_party_last_update_date;
  close csr_party_last_update_date;
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  if l_name_combination_warning then
     fnd_message.set_name('PER', 'PER_WEB_CONTACT_DUPLICATE');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;
  if l_assign_payroll_warning then
     fnd_message.set_name('PER', 'HR_EMP_ASS_NO_DOB ');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;
  if l_orig_hire_warning then
     fnd_message.set_name('PER', 'PER_52359_HIRE_DATES_WARN ');
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
    rollback to update_person_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_employee_number              := l_employee_number;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_full_name                    := null;
    p_comment_id                   := null;
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
    rollback to update_person_swi;
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
    p_full_name                    := null;
    p_comment_id                   := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end update_person;
end hr_person_swi;

/
