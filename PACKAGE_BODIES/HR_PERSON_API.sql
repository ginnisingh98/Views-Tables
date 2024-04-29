--------------------------------------------------------
--  DDL for Package Body HR_PERSON_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PERSON_API" as
/* $Header: peperapi.pkb 120.4.12010000.9 2010/05/19 12:30:10 pchowdav ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'hr_person_api.';
g_debug boolean := hr_utility.debug_enabled;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_person >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_person
  (p_validate                     in      boolean   default false
  ,p_effective_date               in      date
  ,p_datetrack_update_mode        in      varchar2
  ,p_person_id                    in      number
  ,p_object_version_number        in out nocopy  number
  ,p_person_type_id               in      number   default hr_api.g_number
  ,p_last_name                    in      varchar2 default hr_api.g_varchar2
  ,p_applicant_number             in      varchar2 default hr_api.g_varchar2
  ,p_comments                     in      varchar2 default hr_api.g_varchar2
  ,p_date_employee_data_verified  in      date     default hr_api.g_date
  ,p_date_of_birth                in      date     default hr_api.g_date
  ,p_email_address                in      varchar2 default hr_api.g_varchar2
  ,p_employee_number              in out nocopy  varchar2
  ,p_expense_check_send_to_addres in      varchar2 default hr_api.g_varchar2
  ,p_first_name                   in      varchar2 default hr_api.g_varchar2
  ,p_known_as                     in      varchar2 default hr_api.g_varchar2
  ,p_marital_status               in      varchar2 default hr_api.g_varchar2
  ,p_middle_names                 in      varchar2 default hr_api.g_varchar2
  ,p_nationality                  in      varchar2 default hr_api.g_varchar2
  ,p_national_identifier          in      varchar2 default hr_api.g_varchar2
  ,p_previous_last_name           in      varchar2 default hr_api.g_varchar2
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
  ,p_per_information_category     in      varchar2 default hr_api.g_varchar2
  ,p_per_information1             in      varchar2 default hr_api.g_varchar2
  ,p_per_information2             in      varchar2 default hr_api.g_varchar2
  ,p_per_information3             in      varchar2 default hr_api.g_varchar2
  ,p_per_information4             in      varchar2 default hr_api.g_varchar2
  ,p_per_information5             in      varchar2 default hr_api.g_varchar2
  ,p_per_information6             in      varchar2 default hr_api.g_varchar2
  ,p_per_information7             in      varchar2 default hr_api.g_varchar2
  ,p_per_information8             in      varchar2 default hr_api.g_varchar2
  ,p_per_information9             in      varchar2 default hr_api.g_varchar2
  ,p_per_information10            in      varchar2 default hr_api.g_varchar2
  ,p_per_information11            in      varchar2 default hr_api.g_varchar2
  ,p_per_information12            in      varchar2 default hr_api.g_varchar2
  ,p_per_information13            in      varchar2 default hr_api.g_varchar2
  ,p_per_information14            in      varchar2 default hr_api.g_varchar2
  ,p_per_information15            in      varchar2 default hr_api.g_varchar2
  ,p_per_information16            in      varchar2 default hr_api.g_varchar2
  ,p_per_information17            in      varchar2 default hr_api.g_varchar2
  ,p_per_information18            in      varchar2 default hr_api.g_varchar2
  ,p_per_information19            in      varchar2 default hr_api.g_varchar2
  ,p_per_information20            in      varchar2 default hr_api.g_varchar2
  ,p_per_information21            in      varchar2 default hr_api.g_varchar2
  ,p_per_information22            in      varchar2 default hr_api.g_varchar2
  ,p_per_information23            in      varchar2 default hr_api.g_varchar2
  ,p_per_information24            in      varchar2 default hr_api.g_varchar2
  ,p_per_information25            in      varchar2 default hr_api.g_varchar2
  ,p_per_information26            in      varchar2 default hr_api.g_varchar2
  ,p_per_information27            in      varchar2 default hr_api.g_varchar2
  ,p_per_information28            in      varchar2 default hr_api.g_varchar2
  ,p_per_information29            in      varchar2 default hr_api.g_varchar2
  ,p_per_information30            in      varchar2 default hr_api.g_varchar2
  ,p_date_of_death                in      date     default hr_api.g_date
  ,p_background_check_status      in      varchar2 default hr_api.g_varchar2
  ,p_background_date_check        in      date     default hr_api.g_date
  ,p_blood_type                   in      varchar2 default hr_api.g_varchar2
  ,p_correspondence_language      in      varchar2 default hr_api.g_varchar2
  ,p_fast_path_employee           in      varchar2 default hr_api.g_varchar2
  ,p_fte_capacity                 in      number   default hr_api.g_number
  ,p_hold_applicant_date_until    in      date     default hr_api.g_date
  ,p_honors                       in      varchar2 default hr_api.g_varchar2
  ,p_internal_location            in      varchar2 default hr_api.g_varchar2
  ,p_last_medical_test_by         in      varchar2 default hr_api.g_varchar2
  ,p_last_medical_test_date       in      date     default hr_api.g_date
  ,p_mailstop                     in      varchar2 default hr_api.g_varchar2
  ,p_office_number                in      varchar2 default hr_api.g_varchar2
  ,p_on_military_service          in      varchar2 default hr_api.g_varchar2
  ,p_pre_name_adjunct             in      varchar2 default hr_api.g_varchar2
  ,p_projected_start_date         in      date     default hr_api.g_date
  ,p_rehire_authorizor            in      varchar2 default hr_api.g_varchar2
  ,p_rehire_recommendation        in      varchar2 default hr_api.g_varchar2
  ,p_resume_exists                in      varchar2 default hr_api.g_varchar2
  ,p_resume_last_updated          in      date     default hr_api.g_date
  ,p_second_passport_exists       in      varchar2 default hr_api.g_varchar2
  ,p_student_status               in      varchar2 default hr_api.g_varchar2
  ,p_work_schedule                in      varchar2 default hr_api.g_varchar2
  ,p_rehire_reason                in      varchar2 default hr_api.g_varchar2
  ,p_suffix                       in      varchar2 default hr_api.g_varchar2
  ,p_benefit_group_id             in      number   default hr_api.g_number
  ,p_receipt_of_death_cert_date   in      date     default hr_api.g_date
  ,p_coord_ben_med_pln_no         in      varchar2 default hr_api.g_varchar2
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
  l_proc                         varchar2(72) := g_package||'update_person';
  l_effective_date               date;
  l_person_type_id               per_person_types.person_type_id%type :=
                  p_person_type_id;
  l_person_type_id1              per_person_types.person_type_id%type :=
                  p_person_type_id;
  l_business_group_id            per_people_f.business_group_id%type;
  l_old_person_type_id      per_all_people_f.person_type_id%type;
  l_current_system_person_type   per_person_types.system_person_type%type;
  l_validate                     boolean := false;
  l_discard_varchar2             varchar2(40);
  l_applicant_number             per_people_f.applicant_number%TYPE;
  l_object_version_number        per_people_f.object_version_number%TYPE;
  l_employee_number              per_people_f.employee_number%TYPE;
  l_npw_number                   per_people_f.npw_number%TYPE := p_npw_number;
  l_date_employee_data_verified  per_people_f.date_employee_data_verified%TYPE;
  l_date_of_birth                per_people_f.date_of_birth%TYPE;
  l_date_of_death                date;
  l_receipt_of_death_cert_date   date;
  l_dpdnt_adoption_date          date;
  l_original_date_of_hire        date;
  --
  l_effective_start_date         date;
  l_effective_end_date           date;
  l_full_name                    per_people_f.full_name%type;
  l_comment_id                   per_people_f.comment_id%type;
  l_name_combination_warning     boolean;
  l_assign_payroll_warning       boolean;
  l_orig_hire_warning            boolean;
  --
  l_old_work_telephone           per_phones.phone_number%TYPE;
  l_phn_object_version_number    per_phones.object_version_number%TYPE;
  l_phone_id                     per_phones.phone_id%TYPE;
  l_phn_date_to          per_phones.date_to%TYPE;  --Line added for bug# 878827
  --
  l_pds_object_version_number    per_periods_of_service.object_version_number%TYPE;
  l_pds_adjusted_svc_date        per_periods_of_service.adjusted_svc_date%type;
  l_adjusted_svc_date            date;
  l_period_of_service_id         per_periods_of_service.period_of_service_id%type;
  --
  cursor csr_bg is
    select per.business_group_id
    from per_people_f per
    where per.person_id = p_person_id
    and   l_effective_date between per.effective_start_date
                                     and per.effective_end_date;
  --
  cursor csr_system_type(p_person_type_id1 number) is
    select pet.system_person_type
    from per_person_types pet
    where pet.person_type_id=p_person_type_id1;
  --
  cursor csr_period_of_service is
    select pds.period_of_service_id, pds.object_version_number, pds.adjusted_svc_date
    from per_periods_of_service pds
    where pds.person_id = p_person_id
    and   l_effective_date between
              nvl(pds.date_start, hr_general.start_of_time)
          and nvl(pds.actual_termination_date,hr_general.end_of_time);
  --
  cursor csr_phones is
         select    phone_number,
                   phone_id,
                   object_version_number,
                   date_to          --Line added for bug# 878827
         from      per_phones phn
         where     phn.parent_id = p_person_id
         and       phn.parent_table = 'PER_ALL_PEOPLE_F'
         and       phn.phone_type = 'W1'
         and       p_effective_date between phn.date_from and
                        nvl(phn.date_to,p_effective_date);

begin
 if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 5);
 end if;
  --

  -- Store initial values for IN OUT parameters
  --
  l_object_version_number := p_object_version_number;
  l_employee_number       := p_employee_number;
  --
  -- Initialise local variables before call to hr_person_bk1.update_person_b
  --
  l_effective_date              := trunc(p_effective_date);
  l_applicant_number            := p_applicant_number;
  l_date_employee_data_verified := trunc(p_date_employee_data_verified);
  l_date_of_birth               := trunc(p_date_of_birth);
  l_date_of_death               := trunc(p_date_of_death);
  l_receipt_of_death_cert_date  := trunc(p_receipt_of_death_cert_date);
  l_dpdnt_adoption_date         := trunc(p_dpdnt_adoption_date);
  l_original_date_of_hire       := trunc(p_original_date_of_hire);
  l_adjusted_svc_date           := trunc(p_adjusted_svc_date);
  l_validate                    := p_validate ;

  --
  -- Issue a savepoint.
  --
  savepoint hr_update_person; --bug3040309
  begin
    --
    -- Start of API User Hook for the before hook of update_person
    --
    hr_person_bk1.update_person_b
      (p_effective_date               => l_effective_date
      ,p_datetrack_update_mode        => p_datetrack_update_mode
      ,p_person_id                    => p_person_id
      ,p_object_version_number        => p_object_version_number
      ,p_person_type_id               => p_person_type_id
      ,p_last_name                    => p_last_name
      ,p_applicant_number             => p_applicant_number
      ,p_comments                     => p_comments
      ,p_date_employee_data_verified  => l_date_employee_data_verified
      ,p_date_of_birth                => l_date_of_birth
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
      ,p_date_of_death                => l_date_of_death
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
      ,p_receipt_of_death_cert_date   => l_receipt_of_death_cert_date
      ,p_coord_ben_med_pln_no         => p_coord_ben_med_pln_no
      ,p_coord_ben_no_cvg_flag        => p_coord_ben_no_cvg_flag
      ,p_coord_ben_med_ext_er         => p_coord_ben_med_ext_er
      ,p_coord_ben_med_pl_name        => p_coord_ben_med_pl_name
      ,p_coord_ben_med_insr_crr_name  => p_coord_ben_med_insr_crr_name
      ,p_coord_ben_med_insr_crr_ident => p_coord_ben_med_insr_crr_ident
      ,p_coord_ben_med_cvg_strt_dt    => p_coord_ben_med_cvg_strt_dt
      ,p_coord_ben_med_cvg_end_dt     => p_coord_ben_med_cvg_end_dt
      ,p_uses_tobacco_flag            => p_uses_tobacco_flag
      ,p_dpdnt_adoption_date          => l_dpdnt_adoption_date
      ,p_dpdnt_vlntry_svce_flag       => p_dpdnt_vlntry_svce_flag
      ,p_original_date_of_hire        => l_original_date_of_hire
      ,p_adjusted_svc_date            => l_adjusted_svc_date
    ,p_town_of_birth                => p_town_of_birth
    ,p_region_of_birth              => p_region_of_birth
    ,p_country_of_birth             => p_country_of_birth
    ,p_global_person_id             => p_global_person_id
         ,p_party_id                     => p_party_id
     ,p_npw_number                    => l_npw_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PERSON'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_person
    --
  end;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 6);
 end if;
  --
  -- Validation in addition to Table Handlers
  --
  -- Fetch the person's business group id
  --
  open csr_bg;
  fetch csr_bg
  into l_business_group_id;
  --
  if csr_bg%notfound then
    close csr_bg;
    hr_utility.set_message(801, 'HR_7971_PER_PER_IN_PERSON');
    hr_utility.raise_error;
  end if;
  close csr_bg;
  --
 if g_debug then
  hr_utility.set_location(l_proc, 7);
 end if;
  --
/*
This is obsolete. With introduction of Contingent Workers using the PTU model
(ie per_all_people_f stores only a person type of OTHER) this
check raises erroneous errors. Comment out nocopy also person_type_id in the call to per_per_upd
This ensures that PT is unchanged on per_all_people_f
Instead added validation before the PTU call below.

  if p_person_type_id <> hr_api.g_number then
    open csr_current_type;
    fetch csr_current_type
    into l_current_system_person_type;
    if csr_current_type%notfound then
      close csr_current_type;
    else
      close csr_current_type;
      per_per_bus.chk_person_type
      (p_person_type_id    => l_person_type_id
      ,p_business_group_id => l_business_group_id
      ,p_expected_sys_type => l_current_system_person_type);
      l_person_type_id1 :=
         hr_person_type_usage_info.get_default_person_type_id(l_person_type_id);
    end if;
end if;
*/
  --
 if g_debug then
  hr_utility.set_location(l_proc, 8);
 end if;
  --
  -- Update the person record
  --
  per_per_upd.upd
    (p_person_id                    => p_person_id
    ,p_effective_start_date         => l_effective_start_date
    ,p_effective_end_date           => l_effective_end_date
--    ,p_person_type_id               => l_person_type_id1
    ,p_last_name                    => p_last_name
    ,p_applicant_number             => l_applicant_number
    ,p_comment_id                   => l_comment_id
    ,p_comments                     => p_comments
    ,p_current_applicant_flag       => l_discard_varchar2
    ,p_current_emp_or_apl_flag      => l_discard_varchar2
    ,p_current_employee_flag        => l_discard_varchar2
    ,p_date_employee_data_verified  => l_date_employee_data_verified
    ,p_date_of_birth                => l_date_of_birth
    ,p_email_address                => p_email_address
    ,p_employee_number              => p_employee_number
    ,p_expense_check_send_to_addres => p_expense_check_send_to_addres
    ,p_first_name                   => p_first_name
    ,p_full_name                    => l_full_name
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
  -- ,p_work_telephone               => p_work_telephone -- Now handled by create_phone
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
    ,p_date_of_death                => l_date_of_death
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
    ,p_receipt_of_death_cert_date   => l_receipt_of_death_cert_date
    ,p_coord_ben_med_pln_no         => p_coord_ben_med_pln_no
    ,p_coord_ben_no_cvg_flag        => p_coord_ben_no_cvg_flag
    ,p_coord_ben_med_ext_er         => p_coord_ben_med_ext_er
    ,p_coord_ben_med_pl_name        => p_coord_ben_med_pl_name
    ,p_coord_ben_med_insr_crr_name  => p_coord_ben_med_insr_crr_name
    ,p_coord_ben_med_insr_crr_ident => p_coord_ben_med_insr_crr_ident
    ,p_coord_ben_med_cvg_strt_dt    => p_coord_ben_med_cvg_strt_dt
    ,p_coord_ben_med_cvg_end_dt     => p_coord_ben_med_cvg_end_dt
    ,p_uses_tobacco_flag            => p_uses_tobacco_flag
    ,p_dpdnt_adoption_date          => l_dpdnt_adoption_date
    ,p_dpdnt_vlntry_svce_flag       => p_dpdnt_vlntry_svce_flag
    ,p_original_date_of_hire        => p_original_date_of_hire
    ,p_town_of_birth                => p_town_of_birth
    ,p_region_of_birth              => p_region_of_birth
    ,p_country_of_birth             => p_country_of_birth
    ,p_global_person_id             => p_global_person_id
    ,p_party_id                     => p_party_id
    ,p_object_version_number        => p_object_version_number
    ,p_effective_date               => l_effective_date
    ,p_datetrack_mode               => p_datetrack_update_mode
    ,p_validate                       => l_validate
    ,p_name_combination_warning     => l_name_combination_warning
    ,p_dob_null_warning             => l_assign_payroll_warning
    ,p_orig_hire_warning            => l_orig_hire_warning
    ,p_npw_number                   => l_npw_number
    );
  --
  -- PTU : Following Code has been added since the user PT flavour may have changed
  -- 07/03/2002: adhunter: changed this check. Now raise error if user is trying to
  -- update a person_type_id corresponding to a system type that is not on PTU.
  -- This is required because of a "feature" of PERWSQHM that people can be created
  -- and PT updated immediately.

  -- Composite person types are not allowed for p_person_type_id, unless it is
  -- the same person type the person is holding on the p_effective_date.
  -- Bug# 2777435

    if p_person_type_id <> hr_api.g_number then
       --
       -- get the current system person type from per_all_people_f
       -- Bug 4030116
       -- modifed the following SQL to check whether the person_type_id
       -- is already exists for the PTU table instead of per_all_people_f
       l_old_person_type_id := null;
       begin
         select person_type_id into l_old_person_type_id
         from per_person_type_usages_f ptu
         where ptu.person_id=p_person_id
         and ptu.person_type_id = p_person_type_id
         and p_effective_date between ptu.effective_start_date
             and ptu.effective_end_date;
       exception
         when no_data_found then
	  l_old_person_type_id := null;
       end;
       --
       -- get the new system person type

       open csr_system_type(p_person_type_id);
       fetch csr_system_type into l_current_system_person_type;
       close csr_system_type;

       --
       -- if both matches and it is a composite type then do no more validation
       --
       -- Bug 3472119
       -- Modified if condition.
       -- If there is no change in the person type id, there is no need to
       -- update PTU.
       -- Bug 4030116
       -- changed condition to is not null
       --
       if l_old_person_type_id is not null
           then null;
       else
          --
          -- if both does not match and new type is a composite then raise error
          -- Bug 4030116
	  -- removed the match condition as its already checked.
	  --
           if l_current_system_person_type in ('EMP_APL','EX_EMP_APL','APL_EX_APL')
           then
              fnd_message.set_name('PER','PER_289965_COMP_PER_TYPE_INVLD');
              fnd_message.raise_error;
           end if;
           --
           -- Check if the new person type is valid for current person type

           if not hr_general2.is_person_type
                (p_person_id,l_current_system_person_type,l_effective_date) then
              fnd_message.set_name('PER','PER_289603_CWK_INV_PERSON_TYPE');
              fnd_message.raise_error;
           end if;

           hr_per_type_usage_internal.maintain_person_type_usage
           (p_effective_date       => l_effective_start_date
           ,p_person_id            => p_person_id
           ,p_person_type_id       => p_person_type_id
           ,p_datetrack_update_mode => p_datetrack_update_mode
           );
       end if;
    end if;
  -- PTU : End of changes
  --
  -- Update per_periods_of_service
  --
   open csr_period_of_service;
   fetch csr_period_of_service
   into l_period_of_service_id, l_pds_object_version_number,l_pds_adjusted_svc_date;
   if csr_period_of_service%FOUND then
   -- Bug#885806. DBMS_OUTPUT.PUT_LINE calls were replaced with HR_UTILITY.TRACE...
   hr_utility.trace('doing the PDS update');
   hr_utility.trace('PDS id '||to_char(l_period_of_service_id));
   hr_utility.trace('PDS ovn '||to_char(l_pds_object_version_number));
   -- dbms_output.put_line('doing the PDS update');
   -- dbms_output.put_line('PDS id '||to_char(l_period_of_service_id));
   -- dbms_output.put_line('PDS ovn '||to_char(l_pds_object_version_number));

-- Bug # 2679759 : Added nvl to l_adjusted_svc_date and l_pds_adjusted_svc_date.
-- Fix for bug 5941249.
     if  (l_adjusted_svc_date is null or l_adjusted_svc_date <> hr_api.g_date)  --fix for 2497699
     and nvl(l_pds_adjusted_svc_date,hr_api.g_date) <> nvl(l_adjusted_svc_date,hr_api.g_date)
     then
      if g_debug then
        hr_utility.set_location('In '||l_proc||' in the If condition of SVC date ',52);
       end if;
       per_pds_upd.upd
         (p_adjusted_svc_date           => l_adjusted_svc_date
         ,p_effective_date              => l_effective_date
         ,p_period_of_service_id        => l_period_of_service_id
         ,p_object_version_number       => l_pds_object_version_number
         );
   /*----------------------- start for the bug  4924261 ----------------------------------*/
    /*  elsif  nvl(l_adjusted_svc_date,hr_api.g_date) = hr_api.g_date  --fix for 4924261
         and nvl(l_pds_adjusted_svc_date,hr_api.g_date) <> nvl(l_adjusted_svc_date,hr_api.g_date)
     then
       if g_debug then
         hr_utility.set_location('In '||l_proc||' in the If condition of (SVC -null) date ',54);
       end if;
       per_pds_upd.upd
         (p_adjusted_svc_date           => l_adjusted_svc_date
         ,p_effective_date              => l_effective_date
         ,p_period_of_service_id        => l_period_of_service_id
         ,p_object_version_number       => l_pds_object_version_number
         );*/
   /*----------------------- end for the bug  4924261 -----------------------------------*/
     end if;

   -- Bug#885806. DBMS_OUTPUT.PUT_LINE calls were replaced with HR_UTILITY.TRACE...
   -- dbms_output.put_line('PDS id '||to_char(l_period_of_service_id));
   -- dbms_output.put_line('PDS ovn '||to_char(l_pds_object_version_number));
   hr_utility.trace('PDS id '||to_char(l_period_of_service_id));
   hr_utility.trace('PDS ovn '||to_char(l_pds_object_version_number));
   end if;
   close csr_period_of_service;
  --
  -- Beginning of logic for the update of the phones table
  --
  -- Firstly, find the number, ovn and id for the old work_telephone (if it exists)
  --
  open csr_phones;
  fetch csr_phones into l_old_work_telephone,
                        l_phone_id,
                        l_phn_object_version_number,
                        l_phn_date_to; -- Line added for bug# 878827
  close csr_phones;


 if g_debug then
  hr_utility.set_location('In '||l_proc||' and phone no is: '||p_work_telephone, 63);
 end if;
 if g_debug then
  hr_utility.set_location('In '||l_proc||' and old phone no is: '||l_old_work_telephone, 64);
 end if;
 if g_debug then
  hr_utility.set_location('In '||l_proc||' and ovn is: '||l_phn_object_version_number, 65);
 end if;
 if g_debug then
  hr_utility.set_location('In '||l_proc||' and phone id is: '||l_phone_id, 66);
 end if;
  --
  -- If old entry is null and new entry is not null then just use the create
  -- phone B.P. This step is the same regardless of dt upd mode.
  --
  if (p_work_telephone <> hr_api.g_varchar2) then
  if (l_old_work_telephone is null and
      p_work_telephone is not null) then
 if g_debug then
  hr_utility.set_location('Creating new phone', 67);
 end if;
     hr_phone_api.create_phone
       (p_date_from                 => l_effective_date
       ,p_date_to                   => null
       ,p_phone_type                => 'W1'
       ,p_phone_number              => p_work_telephone
       ,p_parent_id                 => p_person_id
       ,p_parent_table              => 'PER_ALL_PEOPLE_F'
       ,p_validate                  => FALSE
       ,p_effective_date            => l_effective_date
       ,p_object_version_number     => l_phn_object_version_number  --out
       ,p_phone_id                  => l_phone_id                   --out
       );
  --
  -- The way we deal with the update of the phones table now depends on
  -- p_datetrack_update_mode, so switch on this parameter.
  --
  elsif p_datetrack_update_mode = 'CORRECTION' then
    --
    -- If old entry is not null and corrected entry is null then delete the phone.
    --
    if l_old_work_telephone is not null and p_work_telephone is null then
 if g_debug then
  hr_utility.set_location('Deleting phone', 68);
 end if;
       hr_phone_api.delete_phone(FALSE, l_phone_id, l_phn_object_version_number);

    --
    -- If old and corrected entries are both not null then update the row with
    -- no changes to start and to dates.
    --
    elsif l_old_work_telephone is not null and p_work_telephone is not null then
 if g_debug then
  hr_utility.set_location('Updating phone in correction mode', 67);
 end if;
       hr_phone_api.update_phone
                    (p_phone_id              => l_phone_id,
                     p_phone_number          => p_work_telephone,
                     p_object_version_number => l_phn_object_version_number,
                     p_effective_date        => l_effective_date);
    end if;
  --
  -- Logic for updating phones table when dt upd mode is an UPDATE one.
  --
  elsif p_datetrack_update_mode = 'UPDATE' or
        p_datetrack_update_mode = 'UPDATE_OVERRIDE' or
        p_datetrack_update_mode = 'UPDATE_CHANGE_INSERT' then
    --
    -- If old entry is not null and updated entry is null then update current
    -- phone to have an end date of the day before the effective date.
    --
    if l_old_work_telephone is not null and p_work_telephone is null then
 if g_debug then
  hr_utility.set_location('Updating old phone in update mode', 69);
 end if;
       hr_phone_api.update_phone
                    (p_phone_id             => l_phone_id,
                     p_date_to              => l_effective_date - 1,
                     p_object_version_number => l_phn_object_version_number,
                     p_effective_date        => l_effective_date);
    --
    -- If old and updated entries are both not null then cap the old row by
    -- updating the date to with the effective date minus 1 and then create a new
    -- row with a date from as the effective date.
    --
    elsif l_old_work_telephone is not null and p_work_telephone is not null then

 if g_debug then
  hr_utility.set_location('Capping old phone in update mode', 70);
 end if;
       hr_phone_api.update_phone
                    (p_phone_id              => l_phone_id,
                     p_date_to               => l_effective_date -1,
                     p_object_version_number => l_phn_object_version_number,
                     p_effective_date        => l_effective_date);

 if g_debug then
  hr_utility.set_location('Creating new phone in update mode', 71);
 end if;
       hr_phone_api.create_phone
         (p_date_from                 => l_effective_date
         ,p_date_to                   => l_phn_date_to
                     --replaced null with l_phn_date_to for bug# 878827
         ,p_phone_type                => 'W1'
         ,p_phone_number              => p_work_telephone
         ,p_parent_id                 => p_person_id
         ,p_parent_table              => 'PER_ALL_PEOPLE_F'
         ,p_validate                  => FALSE
         ,p_effective_date            => l_effective_date
         ,p_object_version_number     => l_phn_object_version_number  --out
         ,p_phone_id                  => l_phone_id                   --out
         );
    end if;
  end if;
  end if;
  --
  -- End of logic for the update of the phones table
  --

if l_name_combination_warning = FALSE then
 if g_debug then
  hr_utility.set_location(l_proc,87);
 end if;
elsif l_name_combination_warning = TRUE then
 if g_debug then
  hr_utility.set_location(l_proc,88);
 end if;
else
 if g_debug then
  hr_utility.set_location(l_proc,89);
 end if;
end if;
 if g_debug then
  hr_utility.set_location(l_proc, 90);
 end if;
  begin
    --
    -- Start of API User Hook for the after hook of update_person
    --
    hr_person_bk1.update_person_a
      (p_effective_date               => l_effective_date
      ,p_datetrack_update_mode        => p_datetrack_update_mode
      ,p_person_id                    => p_person_id
      ,p_object_version_number        => p_object_version_number
      ,p_person_type_id               => p_person_type_id
      ,p_last_name                    => p_last_name
      ,p_applicant_number             => p_applicant_number
      ,p_comments                     => p_comments
      ,p_date_employee_data_verified  => l_date_employee_data_verified
      ,p_date_of_birth                => l_date_of_birth
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
      ,p_sex                          => p_sex
      ,p_title                        => p_title
      ,p_vendor_id                    => p_vendor_id
  --    ,p_work_telephone               => p_work_telephone
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
      ,p_date_of_death                => l_date_of_death
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
      ,p_receipt_of_death_cert_date   => l_receipt_of_death_cert_date
      ,p_coord_ben_med_pln_no         => p_coord_ben_med_pln_no
      ,p_coord_ben_no_cvg_flag        => p_coord_ben_no_cvg_flag
      ,p_coord_ben_med_ext_er         => p_coord_ben_med_ext_er
      ,p_coord_ben_med_pl_name        => p_coord_ben_med_pl_name
      ,p_coord_ben_med_insr_crr_name  => p_coord_ben_med_insr_crr_name
      ,p_coord_ben_med_insr_crr_ident => p_coord_ben_med_insr_crr_ident
      ,p_coord_ben_med_cvg_strt_dt    => p_coord_ben_med_cvg_strt_dt
      ,p_coord_ben_med_cvg_end_dt     => p_coord_ben_med_cvg_end_dt
      ,p_uses_tobacco_flag            => p_uses_tobacco_flag
      ,p_dpdnt_adoption_date          => l_dpdnt_adoption_date
      ,p_dpdnt_vlntry_svce_flag       => p_dpdnt_vlntry_svce_flag
      ,p_original_date_of_hire        => p_original_date_of_hire
      ,p_adjusted_svc_date            => l_adjusted_svc_date
      ,p_effective_start_date         => l_effective_start_date
      ,p_effective_end_date           => l_effective_end_date
      ,p_full_name                    => l_full_name
      ,p_comment_id                   => l_comment_id
      ,p_town_of_birth                => p_town_of_birth
      ,p_region_of_birth              => p_region_of_birth
      ,p_country_of_birth             => p_country_of_birth
      ,p_global_person_id             => p_global_person_id
      ,p_party_id                     => p_party_id
      ,p_npw_number                   => l_npw_number
      ,p_name_combination_warning     => l_name_combination_warning
      ,p_assign_payroll_warning       => l_assign_payroll_warning
      ,p_orig_hire_warning            => l_orig_hire_warning
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PERSON'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_person
    --
  end;
  --
  -- Populating the OUT parameters.
  --
  p_effective_start_date      := l_effective_start_date;
  p_effective_end_date        := l_effective_end_date;
  p_full_name                 := l_full_name;
  p_comment_id                := l_comment_id;
  p_name_combination_warning  := l_name_combination_warning;
  p_assign_payroll_warning    := l_assign_payroll_warning;
  p_orig_hire_warning         := l_orig_hire_warning;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 10);
 end if;
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO hr_update_person; --bug3040309
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number    := l_object_version_number;
    p_employee_number          := l_employee_number;
    p_effective_start_date     := null;
    p_effective_end_date       := null;
    p_full_name                := null;
    p_comment_id               := null;
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632479
    --
    p_object_version_number    := l_object_version_number;
    p_employee_number          := l_employee_number;
    p_effective_start_date     := null;
    p_effective_end_date       := null;
    p_full_name                := null;
    p_comment_id               := null;
    p_orig_hire_warning        := null;
    p_name_combination_warning := null;
    p_assign_payroll_warning   := null;
    ROLLBACK TO hr_update_person; --bug3040309
    raise;
    --
    -- End of fix.
    --
end update_person;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_gb_person >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_gb_person
  (p_validate                     in      boolean   default false
  ,p_effective_date               in      date
  ,p_datetrack_update_mode        in      varchar2
  ,p_person_id                    in      number
  ,p_object_version_number        in out nocopy  number
  ,p_person_type_id               in      number   default hr_api.g_number
  ,p_last_name                    in      varchar2 default hr_api.g_varchar2
  ,p_applicant_number             in      varchar2 default hr_api.g_varchar2
  ,p_comments                     in      varchar2 default hr_api.g_varchar2
  ,p_date_employee_data_verified  in      date     default hr_api.g_date
  ,p_date_of_birth                in      date     default hr_api.g_date
  ,p_email_address                in      varchar2 default hr_api.g_varchar2
  ,p_employee_number              in out nocopy  varchar2
  ,p_expense_check_send_to_addres in      varchar2 default hr_api.g_varchar2
  ,p_first_name                   in      varchar2 default hr_api.g_varchar2
  ,p_known_as                     in      varchar2 default hr_api.g_varchar2
  ,p_marital_status               in      varchar2 default hr_api.g_varchar2
  ,p_middle_names                 in      varchar2 default hr_api.g_varchar2
  ,p_nationality                  in      varchar2 default hr_api.g_varchar2
  ,p_ni_number                    in      varchar2 default hr_api.g_varchar2
  ,p_previous_last_name           in      varchar2 default hr_api.g_varchar2
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
  ,p_ethnic_origin                in      varchar2 default hr_api.g_varchar2
  ,p_director                     in      varchar2 default hr_api.g_varchar2
  ,p_pensioner                    in      varchar2 default hr_api.g_varchar2
  ,p_work_permit_number           in      varchar2 default hr_api.g_varchar2
  ,p_addl_pension_years           in      varchar2 default hr_api.g_varchar2
  ,p_addl_pension_months          in      varchar2 default hr_api.g_varchar2
  ,p_addl_pension_days            in      varchar2 default hr_api.g_varchar2
  ,p_ni_multiple_asg              in      varchar2 default hr_api.g_varchar2
  ,p_paye_aggregate_assignment    in      varchar2 default hr_api.g_varchar2
  ,p_date_of_death                in      date     default hr_api.g_date
  ,p_background_check_status      in      varchar2 default hr_api.g_varchar2
  ,p_background_date_check        in      date     default hr_api.g_date
  ,p_blood_type                   in      varchar2 default hr_api.g_varchar2
  ,p_correspondence_language      in      varchar2 default hr_api.g_varchar2
  ,p_fast_path_employee           in      varchar2 default hr_api.g_varchar2
  ,p_fte_capacity                 in      number   default hr_api.g_number
  ,p_hold_applicant_date_until    in      date     default hr_api.g_date
  ,p_honors                       in      varchar2 default hr_api.g_varchar2
  ,p_internal_location            in      varchar2 default hr_api.g_varchar2
  ,p_last_medical_test_by         in      varchar2 default hr_api.g_varchar2
  ,p_last_medical_test_date       in      date     default hr_api.g_date
  ,p_mailstop                     in      varchar2 default hr_api.g_varchar2
  ,p_office_number                in      varchar2 default hr_api.g_varchar2
  ,p_on_military_service          in      varchar2 default hr_api.g_varchar2
  ,p_pre_name_adjunct             in      varchar2 default hr_api.g_varchar2
  ,p_projected_start_date         in      date     default hr_api.g_date
  ,p_rehire_authorizor            in      varchar2 default hr_api.g_varchar2
  ,p_rehire_recommendation        in      varchar2 default hr_api.g_varchar2
  ,p_resume_exists                in      varchar2 default hr_api.g_varchar2
  ,p_resume_last_updated          in      date     default hr_api.g_date
  ,p_second_passport_exists       in      varchar2 default hr_api.g_varchar2
  ,p_student_status               in      varchar2 default hr_api.g_varchar2
  ,p_work_schedule                in      varchar2 default hr_api.g_varchar2
  ,p_rehire_reason                in      varchar2 default hr_api.g_varchar2
  ,p_suffix                       in      varchar2 default hr_api.g_varchar2
  ,p_benefit_group_id             in      number   default hr_api.g_number
  ,p_receipt_of_death_cert_date   in      date     default hr_api.g_date
  ,p_coord_ben_med_pln_no         in      varchar2 default hr_api.g_varchar2
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
  ,p_effective_start_date         out nocopy     date
  ,p_effective_end_date           out nocopy     date
  ,p_full_name                    out nocopy     varchar2
  ,p_comment_id                   out nocopy     number
  ,p_name_combination_warning     out nocopy     boolean
  ,p_assign_payroll_warning       out nocopy     boolean
  ,p_orig_hire_warning            out nocopy     boolean
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                 varchar2(72) := g_package||'update_gb_person';
  l_effective_date       date;
  l_legislation_code     per_business_groups.legislation_code%type;
  l_discard_varchar2     varchar2(30);
  --
  /*cursor check_legislation
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

      Modified the cursor for the bug 6131445 and 6064284 */

  cursor check_legislation
    (c_person_id      per_people_f.person_id%TYPE,
     c_effective_date date
    )
  is
    select bgp.legislation_code
    from per_people_f per,
         per_business_groups_perf bgp
    where per.business_group_id+0 = bgp.business_group_id
    and   per.person_id     = c_person_id
    and   c_effective_date
      between per.effective_start_date and per.effective_end_date;
  --
begin

 if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 5);
 end if;
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
 if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;
  --
  -- Check that the legislation of the specified business group is 'GB'.
  --
  if l_legislation_code <> 'GB' then
    hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
    hr_utility.set_message_token('LEG_CODE','GB');
    hr_utility.raise_error;
  end if;
 if g_debug then
  hr_utility.set_location(l_proc, 30);
 end if;
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
  ,p_national_identifier          => p_ni_number
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
  ,p_per_information_category     => 'GB'
  ,p_per_information1             => p_ethnic_origin
  ,p_per_information2             => p_director
  ,p_per_information4             => p_pensioner
  ,p_per_information5             => p_work_permit_number
  ,p_per_information6             => p_addl_pension_years
  ,p_per_information7             => p_addl_pension_months
  ,p_per_information8             => p_addl_pension_days
  ,p_per_information9             => p_ni_multiple_asg
  ,p_per_information10            => p_paye_aggregate_assignment
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
  ,p_name_combination_warning     => p_name_combination_warning
  ,p_assign_payroll_warning       => p_assign_payroll_warning
  ,p_orig_hire_warning            => p_orig_hire_warning
  );
  --
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 7);
 end if;
  --
end update_gb_person;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_us_person >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_us_person
  (p_validate                     in      boolean   default false
  ,p_effective_date               in      date
  ,p_datetrack_update_mode        in      varchar2
  ,p_person_id                    in      number
  ,p_object_version_number        in out nocopy  number
  ,p_person_type_id               in      number   default hr_api.g_number
  ,p_last_name                    in      varchar2 default hr_api.g_varchar2
  ,p_applicant_number             in      varchar2 default hr_api.g_varchar2
  ,p_comments                     in      varchar2 default hr_api.g_varchar2
  ,p_date_employee_data_verified  in      date     default hr_api.g_date
  ,p_date_of_birth                in      date     default hr_api.g_date
  ,p_email_address                in      varchar2 default hr_api.g_varchar2
  ,p_employee_number              in out nocopy  varchar2
  ,p_expense_check_send_to_addres in      varchar2 default hr_api.g_varchar2
  ,p_first_name                   in      varchar2 default hr_api.g_varchar2
  ,p_known_as                     in      varchar2 default hr_api.g_varchar2
  ,p_marital_status               in      varchar2 default hr_api.g_varchar2
  ,p_middle_names                 in      varchar2 default hr_api.g_varchar2
  ,p_nationality                  in      varchar2 default hr_api.g_varchar2
  ,p_ss_number                    in      varchar2 default hr_api.g_varchar2
  ,p_previous_last_name           in      varchar2 default hr_api.g_varchar2
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
  ,p_ethnic_origin                in      varchar2 default hr_api.g_varchar2
  ,p_I_9                          in      varchar2 default hr_api.g_varchar2
  ,p_I_9_expiration_date          in      varchar2 default hr_api.g_varchar2
--  ,p_visa_type                    in      varchar2 default hr_api.g_varchar2
  ,p_veteran_status               in      varchar2 default hr_api.g_varchar2
  ,p_new_hire                     in      varchar2 default hr_api.g_varchar2
  ,p_exception_reason             in      varchar2 default hr_api.g_varchar2
  ,p_child_support_obligation     in      varchar2 default hr_api.g_varchar2
  ,p_opted_for_medicare_flag      in      varchar2 default hr_api.g_varchar2
  ,p_date_of_death                in      date     default hr_api.g_date
  ,p_background_check_status      in      varchar2 default hr_api.g_varchar2
  ,p_background_date_check        in      date     default hr_api.g_date
  ,p_blood_type                   in      varchar2 default hr_api.g_varchar2
  ,p_correspondence_language      in      varchar2 default hr_api.g_varchar2
  ,p_fast_path_employee           in      varchar2 default hr_api.g_varchar2
  ,p_fte_capacity                 in      number   default hr_api.g_number
  ,p_hold_applicant_date_until    in      date     default hr_api.g_date
  ,p_honors                       in      varchar2 default hr_api.g_varchar2
  ,p_internal_location            in      varchar2 default hr_api.g_varchar2
  ,p_last_medical_test_by         in      varchar2 default hr_api.g_varchar2
  ,p_last_medical_test_date       in      date     default hr_api.g_date
  ,p_mailstop                     in      varchar2 default hr_api.g_varchar2
  ,p_office_number                in      varchar2 default hr_api.g_varchar2
  ,p_on_military_service          in      varchar2 default hr_api.g_varchar2
  ,p_pre_name_adjunct             in      varchar2 default hr_api.g_varchar2
  ,p_projected_start_date         in      date     default hr_api.g_date
  ,p_rehire_authorizor            in      varchar2 default hr_api.g_varchar2
  ,p_rehire_recommendation        in      varchar2 default hr_api.g_varchar2
  ,p_resume_exists                in      varchar2 default hr_api.g_varchar2
  ,p_resume_last_updated          in      date     default hr_api.g_date
  ,p_second_passport_exists       in      varchar2 default hr_api.g_varchar2
  ,p_student_status               in      varchar2 default hr_api.g_varchar2
  ,p_work_schedule                in      varchar2 default hr_api.g_varchar2
  ,p_rehire_reason                in      varchar2 default hr_api.g_varchar2
  ,p_suffix                       in      varchar2 default hr_api.g_varchar2
  ,p_benefit_group_id             in      number   default hr_api.g_number
  ,p_receipt_of_death_cert_date   in      date     default hr_api.g_date
  ,p_coord_ben_med_pln_no         in      varchar2 default hr_api.g_varchar2
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
  ,p_effective_start_date            out nocopy  date
  ,p_effective_end_date              out nocopy  date
  ,p_full_name                       out nocopy  varchar2
  ,p_comment_id                      out nocopy  number
  ,p_name_combination_warning        out nocopy  boolean
  ,p_assign_payroll_warning          out nocopy  boolean
  ,p_orig_hire_warning               out nocopy  boolean
  ) is

  l_vets100A    varchar2(100);

  --
  -- Declare cursors and local variables
  --
   l_effective_date       date;

 /*
 l_proc                 varchar2(72) := g_package||'update_us_person';
  l_effective_date       date;
  l_legislation_code     per_business_groups.legislation_code%type;
  l_discard_varchar2     varchar2(30);
 */
  --
/*
cursor check_legislation
    (c_person_id      per_people_f.person_id%TYPE,
     c_effective_date date
    )
  is
    select bgp.legislation_code
    from per_people_f per,
--         per_business_groups bgp -- 6131445
--    where per.business_group_id = bgp.business_group_id
         per_business_groups_perf bgp
    where per.business_group_id+0 = bgp.business_group_id
    and   per.person_id     = c_person_id
    and   c_effective_date
      between per.effective_start_date and per.effective_end_date;
*/
  --
begin
l_effective_date := trunc(p_effective_date);
/*
if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 5);
 end if;
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
 if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;
  --
  -- Check that the legislation of the specified business group is 'US'.
  --
  if l_legislation_code <> 'US' then
    hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
    hr_utility.set_message_token('LEG_CODE','US');
    hr_utility.raise_error;
  end if;
 if g_debug then
  hr_utility.set_location(l_proc, 30);
 end if;
 */
  --
  -- Update the person record using the update_person BP
  --
  --hr_person_api.update_person

  hr_person_api.update_US_person
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
    ,p_ss_number          => p_ss_number
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
--    ,p_per_information_category     => 'US'
    ,p_ethnic_origin             => p_ethnic_origin
    ,p_I_9             => p_I_9
    ,p_I_9_expiration_date             => p_I_9_expiration_date
--    ,p_visa_type             => p_visa_type
    ,p_veteran_status             => p_veteran_status
    ,p_vets100A             => l_vets100A
    ,p_new_hire             => p_new_hire
    ,p_exception_reason             => p_exception_reason
    ,p_child_support_obligation             => p_child_support_obligation
    ,p_opted_for_medicare_flag            => p_opted_for_medicare_flag
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
    ,p_name_combination_warning     => p_name_combination_warning
    ,p_assign_payroll_warning       => p_assign_payroll_warning
    ,p_orig_hire_warning            => p_orig_hire_warning
    );
/* if g_debug then
  hr_utility.set_location('Leaving: '||l_proc, 30);
 end if;
 */
  --
end update_us_person;
--

-- Overloaded the function Create_US_employee for bug 8277596

procedure update_us_person
  (p_validate                     in      boolean   default false
  ,p_effective_date               in      date
  ,p_datetrack_update_mode        in      varchar2
  ,p_person_id                    in      number
  ,p_object_version_number        in out nocopy  number
  ,p_person_type_id               in      number   default hr_api.g_number
  ,p_last_name                    in      varchar2 default hr_api.g_varchar2
  ,p_applicant_number             in      varchar2 default hr_api.g_varchar2
  ,p_comments                     in      varchar2 default hr_api.g_varchar2
  ,p_date_employee_data_verified  in      date     default hr_api.g_date
  ,p_date_of_birth                in      date     default hr_api.g_date
  ,p_email_address                in      varchar2 default hr_api.g_varchar2
  ,p_employee_number              in out nocopy  varchar2
  ,p_expense_check_send_to_addres in      varchar2 default hr_api.g_varchar2
  ,p_first_name                   in      varchar2 default hr_api.g_varchar2
  ,p_known_as                     in      varchar2 default hr_api.g_varchar2
  ,p_marital_status               in      varchar2 default hr_api.g_varchar2
  ,p_middle_names                 in      varchar2 default hr_api.g_varchar2
  ,p_nationality                  in      varchar2 default hr_api.g_varchar2
  ,p_ss_number                    in      varchar2 default hr_api.g_varchar2
  ,p_previous_last_name           in      varchar2 default hr_api.g_varchar2
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
  ,p_ethnic_origin                in      varchar2 default hr_api.g_varchar2
  ,p_I_9                          in      varchar2 default hr_api.g_varchar2
  ,p_I_9_expiration_date          in      varchar2 default hr_api.g_varchar2
--  ,p_visa_type                    in      varchar2 default hr_api.g_varchar2
  ,p_veteran_status               in      varchar2 default hr_api.g_varchar2
  ,p_vets100A                in     varchar2 -- default hr_api.g_varchar2 -- Fix For Bug # 8833244
  ,p_new_hire                     in      varchar2 default hr_api.g_varchar2
  ,p_exception_reason             in      varchar2 default hr_api.g_varchar2
  ,p_child_support_obligation     in      varchar2 default hr_api.g_varchar2
  ,p_opted_for_medicare_flag      in      varchar2 default hr_api.g_varchar2
  ,p_date_of_death                in      date     default hr_api.g_date
  ,p_background_check_status      in      varchar2 default hr_api.g_varchar2
  ,p_background_date_check        in      date     default hr_api.g_date
  ,p_blood_type                   in      varchar2 default hr_api.g_varchar2
  ,p_correspondence_language      in      varchar2 default hr_api.g_varchar2
  ,p_fast_path_employee           in      varchar2 default hr_api.g_varchar2
  ,p_fte_capacity                 in      number   default hr_api.g_number
  ,p_hold_applicant_date_until    in      date     default hr_api.g_date
  ,p_honors                       in      varchar2 default hr_api.g_varchar2
  ,p_internal_location            in      varchar2 default hr_api.g_varchar2
  ,p_last_medical_test_by         in      varchar2 default hr_api.g_varchar2
  ,p_last_medical_test_date       in      date     default hr_api.g_date
  ,p_mailstop                     in      varchar2 default hr_api.g_varchar2
  ,p_office_number                in      varchar2 default hr_api.g_varchar2
  ,p_on_military_service          in      varchar2 default hr_api.g_varchar2
  ,p_pre_name_adjunct             in      varchar2 default hr_api.g_varchar2
  ,p_projected_start_date         in      date     default hr_api.g_date
  ,p_rehire_authorizor            in      varchar2 default hr_api.g_varchar2
  ,p_rehire_recommendation        in      varchar2 default hr_api.g_varchar2
  ,p_resume_exists                in      varchar2 default hr_api.g_varchar2
  ,p_resume_last_updated          in      date     default hr_api.g_date
  ,p_second_passport_exists       in      varchar2 default hr_api.g_varchar2
  ,p_student_status               in      varchar2 default hr_api.g_varchar2
  ,p_work_schedule                in      varchar2 default hr_api.g_varchar2
  ,p_rehire_reason                in      varchar2 default hr_api.g_varchar2
  ,p_suffix                       in      varchar2 default hr_api.g_varchar2
  ,p_benefit_group_id             in      number   default hr_api.g_number
  ,p_receipt_of_death_cert_date   in      date     default hr_api.g_date
  ,p_coord_ben_med_pln_no         in      varchar2 default hr_api.g_varchar2
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
  l_proc                 varchar2(72) := g_package||'update_us_person';
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
--         per_business_groups bgp -- 6131445
--    where per.business_group_id = bgp.business_group_id
         per_business_groups_perf bgp
    where per.business_group_id+0 = bgp.business_group_id
    and   per.person_id     = c_person_id
    and   c_effective_date
      between per.effective_start_date and per.effective_end_date;
  --
begin
 if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 5);
 end if;
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
 if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;
  --
  -- Check that the legislation of the specified business group is 'US'.
  --
  if l_legislation_code <> 'US' then
    hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
    hr_utility.set_message_token('LEG_CODE','US');
    hr_utility.raise_error;
  end if;
 if g_debug then
  hr_utility.set_location(l_proc, 30);
 end if;
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
    ,p_national_identifier          => p_ss_number
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
    ,p_per_information_category     => 'US'
    ,p_per_information1             => p_ethnic_origin
    ,p_per_information2             => p_I_9
    ,p_per_information3             => p_I_9_expiration_date
--    ,p_per_information4             => p_visa_type
    ,p_per_information5             => p_veteran_status
    ,p_per_information7             => p_new_hire
    ,p_per_information8             => p_exception_reason
    ,p_per_information9             => p_child_support_obligation
    ,p_per_information10            => p_opted_for_medicare_flag
    ,p_per_information25             => p_vets100A
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
    ,p_name_combination_warning     => p_name_combination_warning
    ,p_assign_payroll_warning       => p_assign_payroll_warning
    ,p_orig_hire_warning            => p_orig_hire_warning
    );
 if g_debug then
  hr_utility.set_location('Leaving: '||l_proc, 30);
 end if;
  --
end update_us_person;

-- Fix for 3908271 starts here.
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_person >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_person
     (p_validate        in boolean default false
     ,p_effective_date  in date
     ,p_person_id       in number
     ,p_perform_predel_validation boolean default false
     ,p_person_org_manager_warning out nocopy varchar2) is
  --
   /*## Cursor to fetch the Release Versions
     ## For bug 3945358                       */
    cursor RelVersion is
    select RELEASE_NAME from  FND_PRODUCT_groups;
  --

  --for bug 7369431
  cursor chk_person_type is
     SELECT typ.system_person_type
     FROM per_person_types typ
          ,per_person_type_usages_f ptu
     WHERE typ.person_type_id = ptu.person_type_id
     AND p_effective_date BETWEEN ptu.effective_start_date
                              AND ptu.effective_end_date
     AND ptu.person_id = p_person_id;

  l_system_person_type  VARCHAR2(2000);
  --

  l_effective_date	date;
  l_validate		boolean;
  l_party_id		per_all_people_f.party_id%type;
  --
  l_proc    varchar2(72) := g_package||'delete_person';
  --
begin

  -- Fetch party Id for the TCA bug 3945358
     select party_id into l_party_id from per_all_people_f
      where person_id = p_person_id and rownum =1;
  --

  -- added for bug 7369431
  Open chk_person_type;
  fetch chk_person_type into l_system_person_type;
  close chk_person_type;
  --

  if g_debug then
    hr_utility.set_location('Entering:'|| l_proc, 5);
    hr_utility.set_location('p_effective_date:'||
                                       to_char(p_effective_date,'DD/MM/YYYY'), 5);
    hr_utility.set_location('p_person_id :'|| p_person_id, 5);
  end if;
  --
  -- Initialise local variables before call to hr_person_bk2.delete_person_b
  --
  l_effective_date  := trunc(p_effective_date);
  l_validate        := p_validate ;
  --
  -- Issue a savepoint.
  --
  savepoint hr_delete_person;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_person
    --
    hr_person_bk2.delete_person_b
      (p_effective_date               => l_effective_date
      ,p_person_id                    => p_person_id
      );
    --
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PERSON'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_person
    --
  end;
  --
  if g_debug then
    hr_utility.set_location(l_proc, 6);
  end if;
  --
  -- Check whether the person is manager for any organization.
  -- If so, set the out warning parameter.
  --
  hr_person_internal.delete_org_manager(p_person_id => p_person_id
                ,p_effective_date  => p_effective_date
                ,p_person_org_manager_warning => p_person_org_manager_warning);
  --
  -- Perform minimal Core HR pre-delete validations.
  --
  -- The following procedure need to be modified to remove the
  -- other product validations like BEN.
  --
  HR_PERSON_INTERNAL.weak_predel_validation
              (p_person_id    => p_person_id
              ,p_effective_date => l_effective_date);
  --
  if g_debug then
    hr_utility.set_location(l_proc, 7);
  end if;
  --
  -- Depending on the parameter p_perform_predel_validation,
  -- additional Core HR validations (strong validations).
  --
  IF p_perform_predel_validation THEN
    --
    -- The following procedure now will contains only
    -- Core HR specific validations as other product validations
    -- will be commented out and should be done through hooks.
    --
    HR_PERSON_INTERNAL.strong_predel_validation
              (p_person_id    => p_person_id
              ,p_effective_date => l_effective_date);
    --
  END IF;
  --
  -- Now perform the deletion of the person.
  --
  HR_PERSON_INTERNAL.delete_person
           (p_person_id     => p_person_id
           ,p_effective_date  => l_effective_date);
  --
  if g_debug then
    hr_utility.set_location(l_proc, 8);
  end if;
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_person
    --
    hr_person_bk2.delete_person_a
      (p_effective_date               => l_effective_date
      ,p_person_id                    => p_person_id
     ,p_person_org_manager_warning => p_person_org_manager_warning);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PERSON'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_person
    --
  end;
  --
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --

  /*----- for TCA person Purge  Start for the bug 3945358 -*/
  hr_utility.set_location('before calling purge_person ', 90);
  begin
   for I in RelVersion
   loop
    if I.RELEASE_NAME not in ('11.5.1', '11.5.2','11.5.3','11.5.4','11.5.5') then
       begin
        -- for bug 7369431
        if l_party_id is not null and nvl(l_system_person_type,'OTHER') not in('OTHER') THEN
            per_hrtca_merge.purge_person (p_person_id => p_person_id,p_party_id  => l_party_id);
        end if;
        --
      exception
       when others then
          ROLLBACK TO hr_delete_person;
      end;
    end if;
   end loop;
     hr_utility.set_location('After calling purge_person ', 91);
  end;
    /*----- End for TCA person Purge  -*/

  if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 100);
  end if;
  --
  exception
   when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    p_person_org_manager_warning := null;
    --
    ROLLBACK TO hr_delete_person;
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    p_person_org_manager_warning := null;
    --
    ROLLBACK TO hr_delete_person;
    raise;
  --
end delete_person;

--
-- Fix for 3908271 ends here.
--

-- ----------------------------------------------------------------------------
-- |---------------------------< update_assign_records >----------------------|
-- ----------------------------------------------------------------------------
--

PROCEDURE Update_assign_records(s_assignment_id         in NUMBER
                               ,t_assignment_id         in number
			       ,apl_ass_start_date      in DATE
			       ,p_object_version_number in number
			       ,p_application_id        in number default null)
  IS
    CURSOR get_pgp(p_people_group_id NUMBER) IS
      SELECT *
      FROM   pay_people_groups
      WHERE  people_group_id = p_people_group_id;
    l_pgp_rec                 pay_people_groups%ROWTYPE := NULL;
    CURSOR get_scl(p_soft_coding_keyflex_id NUMBER) IS
      SELECT *
      FROM   hr_soft_coding_keyflex
      WHERE  soft_coding_keyflex_id = p_soft_coding_keyflex_id;
    l_scl_rec                 hr_soft_coding_keyflex%ROWTYPE := NULL;
    CURSOR get_cag(p_cagr_grade_def_id NUMBER) IS
      SELECT *
      FROM   per_cagr_grades_def
      WHERE  cagr_grade_def_id = p_cagr_grade_def_id;
    l_cag_rec                 per_cagr_grades_def%ROWTYPE := NULL;
    CURSOR assignment_record_update IS
      SELECT   *
      FROM     per_all_assignments_f
      WHERE    assignment_id = s_assignment_id
               AND apl_ass_start_date <effective_start_date
      ORDER BY effective_start_date;


      cursor csr_old_asg_status(p_date date) is
  select ast.per_system_status,asg.assignment_status_type_id
  from per_assignment_status_types ast,
       per_all_assignments_f asg
  where ast.assignment_status_type_id = asg.assignment_status_type_id
  and   asg.assignment_id = t_assignment_id
  and   p_date between asg.effective_start_date and asg.effective_end_date;

    cursor csr_new_asg_status(p_assignment_status_type_id number) is
  select ast.per_system_status
  from per_assignment_status_types ast
  where ast.assignment_status_type_id = p_assignment_status_type_id;

    l_assignment_id  NUMBER;
    l_cagr_id_flex_num            NUMBER;
    l_cagr_grade_def_id           NUMBER;
    l_people_group_id             NUMBER;
    l_soft_coding_keyflex_id      NUMBER;
    l_asg_effective_start_date    DATE;
    l_asg_effective_end_date      DATE;
    l_group_name                  VARCHAR2(1000);
    l_concatenated_segments       VARCHAR2(1000);
    l_comment_id                  NUMBER;
    l_asg_object_version_number   NUMBER;
    l_cagr_concatenated_segments  VARCHAR2(1000);
    l_application_id number;
    l_datetrack_update_mode VARCHAR2(20);
    l_effective_date date;
    l_old_asg_status VARCHAR2(50);
    l_assignment_status_type_id number;
    l_max_eff_end_date date;
    l_new_asg_status VARCHAR2(50);
    l_old_asg_status_id number;
    l_proc        varchar2(72) := g_package||'update_assign_records';
  BEGIN
    FOR ass_rec IN assignment_record_update LOOP
      EXIT WHEN assignment_record_update%NOTFOUND;

      IF ass_rec.people_group_id IS NOT NULL THEN
        OPEN get_pgp(ass_rec.people_group_id);

        FETCH get_pgp INTO l_pgp_rec;

        CLOSE get_pgp;
      END IF;

  if g_debug then
    hr_utility.set_location(l_proc, 1);
  end if;

      IF ass_rec.soft_coding_keyflex_id IS NOT NULL THEN
        OPEN get_scl(ass_rec.soft_coding_keyflex_id);

        FETCH get_scl INTO l_scl_rec;

        CLOSE get_scl;
      END IF;

      IF ass_rec.cagr_grade_def_id IS NOT NULL THEN
        OPEN get_cag(ass_rec.cagr_grade_def_id);

        FETCH get_cag INTO l_cag_rec;

        CLOSE get_cag;
      END IF;

      l_people_group_id := ass_rec.people_group_id;

      l_soft_coding_keyflex_id := ass_rec.soft_coding_keyflex_id;

      l_cagr_grade_def_id := ass_rec.cagr_grade_def_id;




l_assignment_id := t_assignment_id;
if assignment_record_update%rowcount = 1 then
l_asg_object_version_number:=p_object_version_number;
end if;
hr_utility.set_location('l_assignment_id ' || t_assignment_id,10);
hr_utility.set_location('l_asg_object_version_number' || l_asg_object_version_number,10);


    open csr_old_asg_status(ass_rec.effective_start_date);
    fetch csr_old_asg_status into l_old_asg_status,l_old_asg_status_id;
    close csr_old_asg_status;

     OPEN csr_new_asg_status( ass_rec.assignment_status_type_id );
    FETCH csr_new_asg_status INTO l_new_asg_status;
       CLOSE csr_new_asg_status;
    if l_old_asg_status =l_new_asg_status then

       l_assignment_status_type_id :=ass_rec.assignment_status_type_id;

    else
    l_assignment_status_type_id :=l_old_asg_status_id;
      end if;
  if g_debug then
    hr_utility.set_location(l_proc, 2);
  end if;
         hr_assignment_api.update_apl_asg
    (p_effective_date               =>     ass_rec.effective_start_date  --p_effective_date
    ,p_datetrack_update_mode        =>     'UPDATE'
    ,p_assignment_id                =>     l_assignment_id
    ,p_object_version_number        =>     l_asg_object_version_number
    ,p_grade_id                     =>     ass_rec.grade_id
    ,p_grade_ladder_pgm_id          =>     ass_rec.grade_ladder_pgm_id
    ,p_job_id                       =>     ass_rec.job_id
    ,p_payroll_id                   =>     ass_rec.payroll_id
    ,p_location_id                  =>     ass_rec.location_id
    ,p_organization_id              =>     ass_rec.organization_id
    ,p_position_id                  =>     ass_rec.position_id
    ,p_special_ceiling_step_id      =>     ass_rec.special_ceiling_step_id
    ,p_recruiter_id                 =>     ass_rec.recruiter_id
    ,p_recruitment_activity_id      =>     ass_rec.recruitment_activity_id
    ,p_vacancy_id                   =>     ass_rec.vacancy_id
    ,p_pay_basis_id                 =>     ass_rec.pay_basis_id
    ,p_person_referred_by_id        =>     ass_rec.person_referred_by_id
    ,p_supervisor_id                =>     ass_rec.supervisor_id
    ,p_supervisor_assignment_id     =>     ass_rec.supervisor_assignment_id
    ,p_source_organization_id       =>     ass_rec.source_organization_id
    ,p_change_reason                =>     ass_rec.change_reason
    ,p_assignment_status_type_id    =>     l_assignment_status_type_id
    ,p_internal_address_line        =>     ass_rec.internal_address_line
    ,p_default_code_comb_id         =>     ass_rec.default_code_comb_id
    ,p_employment_category          =>     ass_rec.employment_category
    ,p_frequency                    =>     ass_rec.frequency
    ,p_manager_flag                 =>     ass_rec.manager_flag
    ,p_normal_hours                 =>     ass_rec.normal_hours
    ,p_perf_review_period           =>     ass_rec.perf_review_period
    ,p_perf_review_period_frequency =>     ass_rec.perf_review_period_frequency
    ,p_probation_period             =>     ass_rec.probation_period
    ,p_probation_unit               =>     ass_rec.probation_unit
    ,p_sal_review_period            =>     ass_rec.sal_review_period
    ,p_sal_review_period_frequency  =>     ass_rec.sal_review_period_frequency
    ,p_set_of_books_id              =>     ass_rec.set_of_books_id
    ,p_title                        =>     ass_rec.title
    ,p_source_type                  =>     ass_rec.source_type
    ,p_time_normal_finish           =>     ass_rec.time_normal_finish
    ,p_time_normal_start            =>     ass_rec.time_normal_start
    ,p_bargaining_unit_code         =>     ass_rec.bargaining_unit_code
    ,p_date_probation_end           =>     ass_rec.date_probation_end
    ,p_ass_attribute_category       =>     ass_rec.ass_attribute_category
   ,p_ass_attribute1               =>     ass_rec.ass_attribute1
    ,p_ass_attribute2               =>    ass_rec.ass_attribute2
    ,p_ass_attribute3               =>    ass_rec.ass_attribute3
    ,p_ass_attribute4               =>    ass_rec.ass_attribute4
    ,p_ass_attribute5               =>    ass_rec.ass_attribute5
    ,p_ass_attribute6               =>    ass_rec.ass_attribute6
    ,p_ass_attribute7               =>    ass_rec.ass_attribute7
    ,p_ass_attribute8               =>    ass_rec.ass_attribute8
    ,p_ass_attribute9               =>    ass_rec.ass_attribute9
    ,p_ass_attribute10              =>    ass_rec.ass_attribute10
    ,p_ass_attribute11              =>    ass_rec.ass_attribute11
    ,p_ass_attribute12              =>    ass_rec.ass_attribute12
    ,p_ass_attribute13              =>    ass_rec.ass_attribute13
    ,p_ass_attribute14              =>    ass_rec.ass_attribute14
    ,p_ass_attribute15              =>    ass_rec.ass_attribute15
    ,p_ass_attribute16              =>    ass_rec.ass_attribute16
    ,p_ass_attribute17              =>    ass_rec.ass_attribute17
    ,p_ass_attribute18              =>    ass_rec.ass_attribute18
    ,p_ass_attribute19              =>    ass_rec.ass_attribute19
    ,p_ass_attribute20              =>    ass_rec.ass_attribute20
    ,p_ass_attribute21              =>    ass_rec.ass_attribute21
    ,p_ass_attribute22              =>    ass_rec.ass_attribute22
    ,p_ass_attribute23              =>    ass_rec.ass_attribute23
    ,p_ass_attribute24              =>    ass_rec.ass_attribute24
    ,p_ass_attribute25              =>    ass_rec.ass_attribute25
    ,p_ass_attribute26              =>    ass_rec.ass_attribute26
    ,p_ass_attribute27              =>    ass_rec.ass_attribute27
    ,p_ass_attribute28              =>    ass_rec.ass_attribute28
    ,p_ass_attribute29              =>    ass_rec.ass_attribute29
    ,p_ass_attribute30              =>    ass_rec.ass_attribute30
    ,p_scl_segment1                 =>    l_scl_rec.segment1
    ,p_scl_segment2                 =>    l_scl_rec.segment2
    ,p_scl_segment3                 =>    l_scl_rec.segment3
    ,p_scl_segment4                 =>    l_scl_rec.segment4
    ,p_scl_segment5                 =>    l_scl_rec.segment5
    ,p_scl_segment6                 =>    l_scl_rec.segment6
    ,p_scl_segment7                 =>    l_scl_rec.segment7
    ,p_scl_segment8                 =>    l_scl_rec.segment8
    ,p_scl_segment9                 =>    l_scl_rec.segment9
    ,p_scl_segment10                =>    l_scl_rec.segment10
    ,p_scl_segment11                =>    l_scl_rec.segment11
    ,p_scl_segment12                =>    l_scl_rec.segment12
    ,p_scl_segment13                =>    l_scl_rec.segment13
    ,p_scl_segment14                =>    l_scl_rec.segment14
    ,p_scl_segment15                =>    l_scl_rec.segment15
    ,p_scl_segment16                =>    l_scl_rec.segment16
    ,p_scl_segment17                =>    l_scl_rec.segment17
    ,p_scl_segment18                =>    l_scl_rec.segment18
    ,p_scl_segment19                =>    l_scl_rec.segment19
    ,p_scl_segment20                =>    l_scl_rec.segment20
    ,p_scl_segment21                =>    l_scl_rec.segment21
    ,p_scl_segment22                =>    l_scl_rec.segment22
    ,p_scl_segment23                =>    l_scl_rec.segment23
    ,p_scl_segment24                =>    l_scl_rec.segment24
    ,p_scl_segment25                =>    l_scl_rec.segment25
    ,p_scl_segment26                =>    l_scl_rec.segment26
    ,p_scl_segment27                =>    l_scl_rec.segment27
    ,p_scl_segment28                =>    l_scl_rec.segment28
    ,p_scl_segment29                =>    l_scl_rec.segment29
    ,p_scl_segment30                =>    l_scl_rec.segment30
    ,p_pgp_segment1                 =>    l_pgp_rec.segment1
    ,p_pgp_segment2                 =>    l_pgp_rec.segment2
    ,p_pgp_segment3                 =>    l_pgp_rec.segment3
    ,p_pgp_segment4                 =>    l_pgp_rec.segment4
    ,p_pgp_segment5                 =>    l_pgp_rec.segment5
    ,p_pgp_segment6                 =>    l_pgp_rec.segment6
    ,p_pgp_segment7                 =>    l_pgp_rec.segment7
    ,p_pgp_segment8                 =>    l_pgp_rec.segment8
    ,p_pgp_segment9                 =>    l_pgp_rec.segment9
    ,p_pgp_segment10                =>    l_pgp_rec.segment10
    ,p_pgp_segment11                =>    l_pgp_rec.segment11
    ,p_pgp_segment12                =>    l_pgp_rec.segment12
    ,p_pgp_segment13                =>    l_pgp_rec.segment13
    ,p_pgp_segment14                =>    l_pgp_rec.segment14
    ,p_pgp_segment15                =>    l_pgp_rec.segment15
    ,p_pgp_segment16                =>    l_pgp_rec.segment16
    ,p_pgp_segment17                =>    l_pgp_rec.segment17
    ,p_pgp_segment18                =>    l_pgp_rec.segment18
    ,p_pgp_segment19                =>    l_pgp_rec.segment19
    ,p_pgp_segment20                =>    l_pgp_rec.segment20
    ,p_pgp_segment21                =>    l_pgp_rec.segment21
    ,p_pgp_segment22                =>    l_pgp_rec.segment22
    ,p_pgp_segment23                =>    l_pgp_rec.segment23
    ,p_pgp_segment24                =>    l_pgp_rec.segment24
    ,p_pgp_segment25                =>    l_pgp_rec.segment25
    ,p_pgp_segment26                =>    l_pgp_rec.segment26
    ,p_pgp_segment27                =>    l_pgp_rec.segment27
    ,p_pgp_segment28                =>    l_pgp_rec.segment28
    ,p_pgp_segment29                =>    l_pgp_rec.segment29
    ,p_pgp_segment30                =>    l_pgp_rec.segment30
    ,p_contract_id                  =>    ass_rec.contract_id
    ,p_establishment_id             =>    ass_rec.establishment_id
    ,p_collective_agreement_id      =>    ass_rec.collective_agreement_id
    ,p_cagr_grade_def_id            =>     l_cagr_grade_def_id
    ,p_work_at_home                 =>    ass_rec.work_at_home
    ,p_notice_period                =>    ass_rec.notice_period
    ,p_notice_period_uom            =>    ass_rec.notice_period_uom
   ,p_cagr_concatenated_segments   =>     l_cagr_concatenated_segments
    ,p_group_name                   =>     l_group_name
    ,p_concatenated_segments        =>     l_concatenated_segments
    ,p_comment_id                   =>     l_comment_id
    ,p_people_group_id              =>     l_people_group_id
    ,p_soft_coding_keyflex_id       =>     l_soft_coding_keyflex_id
    ,p_effective_start_date         =>     l_asg_effective_start_date
    ,p_effective_end_date           =>     l_asg_effective_end_date
    -- fix for bug 9718515 starts here.
    ,p_job_post_source_name         =>    ass_rec.job_post_source_name
    ,p_applicant_rank               =>    ass_rec.applicant_rank
    ,p_posting_content_id           =>    ass_rec.posting_content_id
    ,p_employee_category            =>    ass_rec.employee_category
    -- fix for bug 9718515 ends here.
    );

    if l_old_asg_status <>    l_new_asg_status then

        If l_new_asg_status = 'ACTIVE_APL' then
        hr_assignment_api.activate_apl_asg
          (p_effective_date               => ass_rec.effective_start_date
          ,p_datetrack_update_mode        => 'CORRECTION'
          ,p_assignment_id                => l_assignment_id
          ,p_object_version_number        => l_asg_object_version_number
          ,p_assignment_status_type_id    => ass_rec.assignment_status_type_id
          ,p_change_reason                => ass_rec.change_reason
          ,p_effective_start_date         => l_asg_effective_start_date
          ,p_effective_end_date           => l_asg_effective_end_date
          );

    elsif l_new_asg_status = 'OFFER' then
          hr_assignment_api.offer_apl_asg
          (p_effective_date               => ass_rec.effective_start_date
          ,p_datetrack_update_mode        => 'CORRECTION'
          ,p_assignment_id                => l_assignment_id
          ,p_object_version_number        => l_asg_object_version_number
          ,p_assignment_status_type_id    => ass_rec.assignment_status_type_id
          ,p_change_reason                => ass_rec.change_reason
          ,p_effective_start_date         => l_asg_effective_start_date
          ,p_effective_end_date           => l_asg_effective_end_date
          );

    elsif l_new_asg_status = 'ACCEPTED' then
          hr_assignment_api.accept_apl_asg
          (p_effective_date               => ass_rec.effective_start_date
          ,p_datetrack_update_mode        => 'CORRECTION'
          ,p_assignment_id                => l_assignment_id
          ,p_object_version_number        => l_asg_object_version_number
          ,p_assignment_status_type_id    => ass_rec.assignment_status_type_id
          ,p_change_reason                => ass_rec.change_reason
          ,p_effective_start_date         => l_asg_effective_start_date
          ,p_effective_end_date           => l_asg_effective_end_date
          );

    elsif l_new_asg_status = 'INTERVIEW1' then
          hr_assignment_api.interview1_apl_asg
          (p_effective_date               => ass_rec.effective_start_date
          ,p_datetrack_update_mode        => 'CORRECTION'
          ,p_assignment_id                => l_assignment_id
          ,p_object_version_number        => l_asg_object_version_number
          ,p_assignment_status_type_id    => ass_rec.assignment_status_type_id
          ,p_change_reason                => ass_rec.change_reason
          ,p_effective_start_date         => l_asg_effective_start_date
          ,p_effective_end_date           => l_asg_effective_end_date
          );

    elsif l_new_asg_status = 'INTERVIEW2' then
    hr_assignment_api.interview2_apl_asg
          (p_effective_date               => ass_rec.effective_start_date
          ,p_datetrack_update_mode        => 'CORRECTION'
          ,p_assignment_id                => l_assignment_id
          ,p_object_version_number        => l_asg_object_version_number
          ,p_assignment_status_type_id    => ass_rec.assignment_status_type_id
          ,p_change_reason                => ass_rec.change_reason
          ,p_effective_start_date         => l_asg_effective_start_date
          ,p_effective_end_date           => l_asg_effective_end_date
          );

    end if;

    end if;


    END LOOP;
  if g_debug then
    hr_utility.set_location(l_proc, 3);
  end if;
select max(effective_end_date) into l_max_eff_end_date
from per_all_assignments_f
where assignment_id=s_assignment_id;
if l_max_eff_end_date <> to_date('31/12/4712','DD/MM/YYYY') then

 hr_assignment_api.terminate_apl_asg
          (p_effective_date               => l_max_eff_end_date
          ,p_assignment_id                => l_assignment_id
          ,p_object_version_number        => l_asg_object_version_number
          ,p_effective_start_date         => l_asg_effective_start_date
          ,p_effective_end_date           => l_asg_effective_end_date
          );

end if;
  if g_debug then
    hr_utility.set_location(l_proc, 4);
  end if;
  END update_assign_records;

--
-- ----------------------------------------------------------------------------
-- |---------------------------< merge_person >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure merge_person(p_target_person_id        in number
                      ,p_source_person_id        in number
               	      ,p_term_or_purge_s         in varchar2 default null
		      ,p_create_new_application  in varchar2 default 'Y')
IS

      CURSOR appl_assignments IS
      SELECT   assignment_id,
               Min(effective_start_date) eff_start_date
      FROM     per_all_assignments_f
      WHERE    person_id = p_source_person_id
      GROUP BY assignment_id;

      CURSOR assign_record(c_apl_ass_start_date DATE,
                           c_assignment_id NUMBER) IS
      SELECT *
      FROM   per_all_assignments_f
      WHERE  assignment_id = c_assignment_id
      AND c_apl_ass_start_date BETWEEN effective_start_date AND effective_end_date;

      CURSOR csr_sys_person_type(c_person_id NUMBER) IS
      SELECT pet.system_person_type
      FROM   per_all_people_f per,
             per_person_types pet
      WHERE  per.person_type_id = pet.person_type_id
             AND per.person_id = c_person_id
             AND trunc(sysdate) BETWEEN per.effective_start_date AND per.effective_end_date;

      CURSOR csr_ptu_details(c_person_id NUMBER) IS
      SELECT person_type_usage_id
      FROM   per_person_type_usages_f
      WHERE  person_id = c_person_id
      AND trunc(sysdate) BETWEEN effective_start_date AND effective_end_date;


      CURSOR get_pgp(c_people_group_id NUMBER) IS
      SELECT *
      FROM   pay_people_groups
      WHERE  people_group_id = c_people_group_id;

      CURSOR get_scl(c_soft_coding_keyflex_id NUMBER) IS
      SELECT *
      FROM   hr_soft_coding_keyflex
      WHERE  soft_coding_keyflex_id = c_soft_coding_keyflex_id;

      CURSOR get_cag(c_cagr_grade_def_id NUMBER) IS
      SELECT *
      FROM   per_cagr_grades_def
      WHERE  cagr_grade_def_id = c_cagr_grade_def_id;

    l_t_person_type               VARCHAR2(39);
    l_s_person_type               VARCHAR2(39);
    l_ptu_id                      NUMBER;
    l_bg_id                       NUMBER;
    l_t_start_date                  DATE;
    l_apl_ass_start_date            DATE;
    l_party_id                    NUMBER;
    l_person_org_manager_warning  VARCHAR2(1000);
    l_per_assign_record             assign_record%ROWTYPE;
    l_pgp_rec                     pay_people_groups%ROWTYPE := NULL;
    l_primary_pgp_rec             pay_people_groups%ROWTYPE;
    l_scl_rec                     hr_soft_coding_keyflex%ROWTYPE := NULL;
    l_primary_scl_rec             hr_soft_coding_keyflex%ROWTYPE := NULL;
    l_cag_rec                     per_cagr_grades_def%ROWTYPE := NULL;
    l_primary_cag_rec             per_cagr_grades_def%ROWTYPE;
    l_concatenated_segments       VARCHAR2(1000);
    l_cagr_grade_def_id           NUMBER;
    l_people_group_id             NUMBER;
    l_soft_coding_keyflex_id      NUMBER;
    l_cagr_concatenated_segments  VARCHAR2(1000);
    l_group_name                  VARCHAR2(1000);
    l_assignment_id               NUMBER;
    l_comment_id                  NUMBER;
    l_object_version_number       NUMBER;
    l_effective_start_date        DATE;
    l_effective_end_date          DATE;
    l_assignment_sequence         NUMBER;
    l_appl_override_warning       BOOLEAN;
    l_scl_concat_segments         VARCHAR2(1000);
    l_applicant_number            NUMBER;
    l_per_object_version_number   NUMBER;
    l_assignment_status_type_id   NUMBER;
    l_application_id              NUMBER;
    l_apl_object_version_number   NUMBER;
    l_asg_object_version_number   NUMBER;
    l_per_effective_start_date    DATE;
    l_per_effective_end_date      DATE;
    l_exists                      number :=0;
    l_can_exists                  number :=1;
    l_vac_exists                  number :=0;
    l_t_party_id                    number;
    l_prev_exists                 varchar2(1) := 'N';
    l_create_new_application      varchar2(1):= 'Y';
    l_proc                        varchar2(72) := g_package||'merge_person';


  BEGIN
  if g_debug then
    hr_utility.set_location('Entering:'|| l_proc, 5);
  end if;

   OPEN csr_sys_person_type(p_source_person_id);
   FETCH csr_sys_person_type INTO l_s_person_type;
   CLOSE csr_sys_person_type;

   SELECT business_group_id
   INTO   l_bg_id
   FROM   per_all_people_f
   WHERE  person_id = p_source_person_id
   AND effective_start_date = start_date;

   BEGIN
   select 1 into l_exists
   from per_person_type_usages_f ptuf, per_person_types ppt
   where ppt.system_person_type = 'IRC_REG_USER'
   and ptuf.person_type_id = ppt.person_type_id
   and ppt.business_group_id + 0 = nvl(l_bg_id,ppt.business_group_id)
   and not exists (select null from per_all_assignments_f paaf where paaf.person_id = ptuf.person_id)
   and not exists (select null from per_contact_relationships pcr where pcr.contact_person_id = ptuf.person_id)
   and ptuf.person_id=p_source_person_id;
   EXCEPTION
   WHEN OTHERS THEN
   NULL;
   END;

   OPEN csr_ptu_details(p_source_person_id);
   FETCH csr_ptu_details INTO l_ptu_id;
   CLOSE csr_ptu_details;

  if g_debug then
    hr_utility.set_location(l_proc, 6);
  end if;


    IF (l_exists = 1
        AND p_term_or_purge_s = 'PURGE') THEN
      hr_person_api.Delete_person(p_validate => false,
                                  p_effective_date => trunc(sysdate),
                                  p_person_id => p_source_person_id,
                                  p_perform_predel_validation => false,
                                  p_person_org_manager_warning => l_person_org_manager_warning);
    ELSIF (l_exists = 1
           AND p_term_or_purge_s = 'TERM') THEN
     --  hr_utility.set_message(800, 'HR_7092_WFLOW_INV_ACTION'); fix for bug 9691817.
     --  hr_utility.raise_error;
     null;
    END IF;

  if g_debug then
    hr_utility.set_location(l_proc, 7);
  end if;


 IF (l_s_person_type = 'APL') THEN


    IF  (hr_person_type_usage_info.Futsyspertypechgexists(l_ptu_id
                                                        ,trunc(sysdate)
							,p_source_person_id)
							) THEN
       hr_utility.set_message(800, 'HR_7193_PER_FUT_TYPE_EXISTS');
       hr_utility.raise_error;
    END IF;

  if g_debug then
    hr_utility.set_location(l_proc, 8);
  end if;

--fix for bug 9692642

begin
select 'Y' into l_prev_exists
from sys.dual where exists (
select 'Previous Person type exists'
from per_person_types ppt
   , per_person_type_usages_f ptu
where ptu.person_id = p_source_person_id
and ppt.business_group_id +0= l_bg_id
and ptu.person_type_id = ppt.person_type_id
and ppt.system_person_type <>'APL'
AND (ppt.system_person_type='OTHER' and not exists (select 1
                                                    from per_person_type_usages_f ptu1,per_person_types ppt1
						    where  ptu1.person_id=p_source_person_id
						    and ppt1.person_type_id=ptu1.person_type_id
						    and ppt1.system_person_type='IRC_REG_USER') )
and ppt.system_person_type<>'IRC_REG_USER'
and sysdate between ptu.effective_start_date and ptu.effective_end_date
union
select 'Previous Person type exists'
from per_periods_of_service pps
where pps.person_id =p_source_person_id
and sysdate >= nvl(pps.actual_termination_date,sysdate)
union
select 'Previous Person type exists'
from per_periods_of_placement ppp
where ppp.person_id = p_source_person_id
and sysdate >= nvl(ppp.actual_termination_date,sysdate));

EXCEPTION
WHEN OTHERS THEN
NULL;
  if g_debug then
    hr_utility.set_location(l_proc, 8.1);
  end if;
end;

       IF (l_prev_exists='Y')
           THEN
      hr_utility.set_message(800, 'PER_442266_PERSON_CANNOT_MERGE');
      hr_utility.raise_error;
          END IF;

  if g_debug then
    hr_utility.set_location(l_proc, 9);
  end if;

        SELECT start_date,party_id
        INTO   l_t_start_date,l_t_party_id
        FROM   per_all_people_f
        WHERE  person_id = p_target_person_id
        AND effective_start_date = start_date;


        FOR app_rec IN appl_assignments LOOP
          IF app_rec.eff_start_date < l_t_start_date THEN
            l_apl_ass_start_date := trunc(sysdate);
            l_create_new_application:=p_create_new_application;
          ELSE
          l_create_new_application:='Y';
            l_apl_ass_start_date := app_rec.eff_start_date;
          END IF;

          OPEN csr_sys_person_type(p_target_person_id);

          FETCH csr_sys_person_type INTO l_t_person_type;

          CLOSE csr_sys_person_type;


            OPEN assign_record(l_apl_ass_start_date,app_rec.assignment_id);

            FETCH assign_record INTO l_per_assign_record;

            CLOSE assign_record;


            IF l_per_assign_record.people_group_id IS NOT NULL THEN
              OPEN get_pgp(l_per_assign_record.people_group_id);

              FETCH get_pgp INTO l_pgp_rec;

              CLOSE get_pgp;
            END IF;

            IF l_per_assign_record.soft_coding_keyflex_id IS NOT NULL THEN
              OPEN get_scl(l_per_assign_record.soft_coding_keyflex_id);

              FETCH get_scl INTO l_scl_rec;

              CLOSE get_scl;
            END IF;

            IF l_per_assign_record.cagr_grade_def_id IS NOT NULL THEN
              OPEN get_cag(l_per_assign_record.cagr_grade_def_id);

              FETCH get_cag INTO l_cag_rec;

              CLOSE get_cag;
            END IF;
             l_cagr_grade_def_id := l_per_assign_record.cagr_grade_def_id;

              l_people_group_id := l_per_assign_record.people_group_id;

              l_soft_coding_keyflex_id := l_per_assign_record.soft_coding_keyflex_id;

   l_vac_exists:=0;
   BEGIN
   select 1 into l_vac_exists from dual
   where exists(select 1 from per_all_assignments_f
   where vacancy_id=l_per_assign_record.vacancy_id
   and person_id=p_target_person_id
   and assignment_type='A');
   EXCEPTION
WHEN OTHERS THEN
NULL;
END;

  if g_debug then
    hr_utility.set_location(l_proc, 10);
  end if;

        IF l_t_person_type IN ('APL','EMP_APL','EX_EMP_APL') and l_vac_exists<>1 and l_create_new_application='Y' THEN

	  if g_debug then
    hr_utility.set_location(l_proc, 11);
  end if;

            BEGIN

hr_assignment_api.create_secondary_apl_asg
  (p_validate                     =>  false
  ,p_effective_date               =>  l_apl_ass_start_date
  ,p_person_id                    =>  p_target_person_id
  ,p_organization_id              =>  l_per_assign_record.organization_id
  ,p_recruiter_id                 =>  l_per_assign_record.recruiter_id
  ,p_grade_id                     =>  l_per_assign_record.grade_id
  ,p_position_id                  =>  l_per_assign_record.position_id
  ,p_job_id                       =>  l_per_assign_record.job_id
  ,p_assignment_status_type_id    =>  l_per_assign_record.assignment_status_type_id
  ,p_payroll_id                   =>  l_per_assign_record.payroll_id
  ,p_location_id                  =>  l_per_assign_record.location_id
  ,p_person_referred_by_id        =>  l_per_assign_record.person_referred_by_id
  ,p_supervisor_id                =>  l_per_assign_record.supervisor_id
  ,p_special_ceiling_step_id      =>  l_per_assign_record.special_ceiling_step_id
  ,p_recruitment_activity_id      =>  l_per_assign_record.recruitment_activity_id
  ,p_source_organization_id       =>  l_per_assign_record.source_organization_id
  ,p_vacancy_id                   =>  l_per_assign_record.vacancy_id
  ,p_pay_basis_id                 =>  l_per_assign_record.pay_basis_id
  ,p_change_reason                =>  l_per_assign_record.change_reason
  ,p_date_probation_end           =>  l_per_assign_record.date_probation_end
  ,p_default_code_comb_id         =>  l_per_assign_record.default_code_comb_id
  ,p_employment_category          =>  l_per_assign_record.employment_category
  ,p_frequency                    =>  l_per_assign_record.frequency
  ,p_internal_address_line        =>  l_per_assign_record.internal_address_line
  ,p_manager_flag                 =>  l_per_assign_record.manager_flag
  ,p_normal_hours                 =>  l_per_assign_record.normal_hours
  ,p_perf_review_period           =>  l_per_assign_record.perf_review_period
  ,p_perf_review_period_frequency =>  l_per_assign_record.perf_review_period_frequency
  ,p_probation_period             =>  l_per_assign_record.probation_period
  ,p_probation_unit               =>  l_per_assign_record.probation_unit
  ,p_sal_review_period            =>  l_per_assign_record.sal_review_period
  ,p_sal_review_period_frequency  =>  l_per_assign_record.sal_review_period_frequency
  ,p_set_of_books_id              =>  l_per_assign_record.set_of_books_id
  ,p_source_type                  =>  l_per_assign_record.source_type
  ,p_time_normal_finish           =>  l_per_assign_record.time_normal_finish
  ,p_time_normal_start            =>  l_per_assign_record.time_normal_start
  ,p_bargaining_unit_code         =>  l_per_assign_record.bargaining_unit_code
  ,p_ass_attribute_category       =>  l_per_assign_record.ass_attribute_category
  ,p_ass_attribute1               =>  l_per_assign_record.ass_attribute1
  ,p_ass_attribute2               =>  l_per_assign_record.ass_attribute2
  ,p_ass_attribute3               =>  l_per_assign_record.ass_attribute3
  ,p_ass_attribute4               =>  l_per_assign_record.ass_attribute4
  ,p_ass_attribute5               =>  l_per_assign_record.ass_attribute5
  ,p_ass_attribute6               =>  l_per_assign_record.ass_attribute6
  ,p_ass_attribute7               =>  l_per_assign_record.ass_attribute7
  ,p_ass_attribute8               =>  l_per_assign_record.ass_attribute8
  ,p_ass_attribute9               =>  l_per_assign_record.ass_attribute9
  ,p_ass_attribute10              =>  l_per_assign_record.ass_attribute10
  ,p_ass_attribute11              =>  l_per_assign_record.ass_attribute11
  ,p_ass_attribute12              =>  l_per_assign_record.ass_attribute12
  ,p_ass_attribute13              =>  l_per_assign_record.ass_attribute13
  ,p_ass_attribute14              =>  l_per_assign_record.ass_attribute14
  ,p_ass_attribute15              =>  l_per_assign_record.ass_attribute15
  ,p_ass_attribute16              =>  l_per_assign_record.ass_attribute16
  ,p_ass_attribute17              =>  l_per_assign_record.ass_attribute17
  ,p_ass_attribute18              =>  l_per_assign_record.ass_attribute18
  ,p_ass_attribute19              =>  l_per_assign_record.ass_attribute19
  ,p_ass_attribute20              =>  l_per_assign_record.ass_attribute20
  ,p_ass_attribute21              =>  l_per_assign_record.ass_attribute21
  ,p_ass_attribute22              =>  l_per_assign_record.ass_attribute22
  ,p_ass_attribute23              =>  l_per_assign_record.ass_attribute23
  ,p_ass_attribute24              =>  l_per_assign_record.ass_attribute24
  ,p_ass_attribute25              =>  l_per_assign_record.ass_attribute25
  ,p_ass_attribute26              =>  l_per_assign_record.ass_attribute26
  ,p_ass_attribute27              =>  l_per_assign_record.ass_attribute27
  ,p_ass_attribute28              =>  l_per_assign_record.ass_attribute28
  ,p_ass_attribute29              =>  l_per_assign_record.ass_attribute29
  ,p_ass_attribute30              =>  l_per_assign_record.ass_attribute30
  ,p_title                        =>  l_per_assign_record.title
  ,p_scl_segment1                 =>  l_scl_rec.segment1
  ,p_scl_segment2                 =>  l_scl_rec.segment2
  ,p_scl_segment3                 =>  l_scl_rec.segment3
  ,p_scl_segment4                 =>  l_scl_rec.segment4
  ,p_scl_segment5                 =>  l_scl_rec.segment5
  ,p_scl_segment6                 =>  l_scl_rec.segment6
  ,p_scl_segment7                 =>  l_scl_rec.segment7
  ,p_scl_segment8                 =>  l_scl_rec.segment8
  ,p_scl_segment9                 =>  l_scl_rec.segment9
  ,p_scl_segment10                =>  l_scl_rec.segment10
  ,p_scl_segment11                =>  l_scl_rec.segment11
  ,p_scl_segment12                =>  l_scl_rec.segment12
  ,p_scl_segment13                =>  l_scl_rec.segment13
  ,p_scl_segment14                =>  l_scl_rec.segment14
  ,p_scl_segment15                =>  l_scl_rec.segment15
  ,p_scl_segment16                =>  l_scl_rec.segment16
  ,p_scl_segment17                =>  l_scl_rec.segment17
  ,p_scl_segment18                =>  l_scl_rec.segment18
  ,p_scl_segment19                =>  l_scl_rec.segment19
  ,p_scl_segment20                =>  l_scl_rec.segment20
  ,p_scl_segment21                =>  l_scl_rec.segment21
  ,p_scl_segment22                =>  l_scl_rec.segment22
  ,p_scl_segment23                =>  l_scl_rec.segment23
  ,p_scl_segment24                =>  l_scl_rec.segment24
  ,p_scl_segment25                =>  l_scl_rec.segment25
  ,p_scl_segment26                =>  l_scl_rec.segment26
  ,p_scl_segment27                =>  l_scl_rec.segment27
  ,p_scl_segment28                =>  l_scl_rec.segment28
  ,p_scl_segment29                =>  l_scl_rec.segment29
  ,p_scl_segment30                =>  l_scl_rec.segment30
  ,p_scl_concat_segments          =>  l_scl_concat_segments
  ,p_concatenated_segments        =>  l_concatenated_segments
  ,p_pgp_segment1                 =>  l_pgp_rec.segment1
  ,p_pgp_segment2                 =>  l_pgp_rec.segment2
  ,p_pgp_segment3                 =>  l_pgp_rec.segment3
  ,p_pgp_segment4                 =>  l_pgp_rec.segment4
  ,p_pgp_segment5                 =>  l_pgp_rec.segment5
  ,p_pgp_segment6                 =>  l_pgp_rec.segment6
  ,p_pgp_segment7                 =>  l_pgp_rec.segment7
  ,p_pgp_segment8                 =>  l_pgp_rec.segment8
  ,p_pgp_segment9                 =>  l_pgp_rec.segment9
  ,p_pgp_segment10                =>  l_pgp_rec.segment10
  ,p_pgp_segment11                =>  l_pgp_rec.segment11
  ,p_pgp_segment12                =>  l_pgp_rec.segment12
  ,p_pgp_segment13                =>  l_pgp_rec.segment13
  ,p_pgp_segment14                =>  l_pgp_rec.segment14
  ,p_pgp_segment15                =>  l_pgp_rec.segment15
  ,p_pgp_segment16                =>  l_pgp_rec.segment16
  ,p_pgp_segment17                =>  l_pgp_rec.segment17
  ,p_pgp_segment18                =>  l_pgp_rec.segment18
  ,p_pgp_segment19                =>  l_pgp_rec.segment19
  ,p_pgp_segment20                =>  l_pgp_rec.segment20
  ,p_pgp_segment21                =>  l_pgp_rec.segment21
  ,p_pgp_segment22                =>  l_pgp_rec.segment22
  ,p_pgp_segment23                =>  l_pgp_rec.segment23
  ,p_pgp_segment24                =>  l_pgp_rec.segment24
  ,p_pgp_segment25                =>  l_pgp_rec.segment25
  ,p_pgp_segment26                =>  l_pgp_rec.segment26
  ,p_pgp_segment27                =>  l_pgp_rec.segment27
  ,p_pgp_segment28                =>  l_pgp_rec.segment28
  ,p_pgp_segment29                =>  l_pgp_rec.segment29
  ,p_pgp_segment30                =>  l_pgp_rec.segment30
  ,p_contract_id                  =>  l_per_assign_record.contract_id
  ,p_establishment_id             =>  l_per_assign_record.establishment_id
  ,p_collective_agreement_id      =>  l_per_assign_record.collective_agreement_id
  ,p_cag_segment1                 =>  l_cag_rec.segment1
  ,p_cag_segment2                 =>  l_cag_rec.segment2
  ,p_cag_segment3                 =>  l_cag_rec.segment3
  ,p_cag_segment4                 =>  l_cag_rec.segment4
  ,p_cag_segment5                 =>  l_cag_rec.segment5
  ,p_cag_segment6                 =>  l_cag_rec.segment6
  ,p_cag_segment7                 =>  l_cag_rec.segment7
  ,p_cag_segment8                 =>  l_cag_rec.segment8
  ,p_cag_segment9                 =>  l_cag_rec.segment9
  ,p_cag_segment10                =>  l_cag_rec.segment10
  ,p_cag_segment11                =>  l_cag_rec.segment11
  ,p_cag_segment12                =>  l_cag_rec.segment12
  ,p_cag_segment13                =>  l_cag_rec.segment13
  ,p_cag_segment14                =>  l_cag_rec.segment14
  ,p_cag_segment15                =>  l_cag_rec.segment15
  ,p_cag_segment16                =>  l_cag_rec.segment16
  ,p_cag_segment17                =>  l_cag_rec.segment17
  ,p_cag_segment18                =>  l_cag_rec.segment18
  ,p_cag_segment19                =>  l_cag_rec.segment19
  ,p_cag_segment20                =>  l_cag_rec.segment20
  ,p_notice_period                =>  l_per_assign_record.notice_period
  ,p_notice_period_uom            =>  l_per_assign_record.notice_period_uom
  ,p_employee_category            =>  l_per_assign_record.employee_category
  ,p_work_at_home                 =>  l_per_assign_record.work_at_home
  ,p_job_post_source_name         =>  l_per_assign_record.job_post_source_name
  ,p_applicant_rank               =>  l_per_assign_record.applicant_rank
  ,p_posting_content_id           =>  l_per_assign_record.posting_content_id
  ,p_grade_ladder_pgm_id          =>  l_per_assign_record.grade_ladder_pgm_id
  ,p_supervisor_assignment_id     =>  l_per_assign_record.supervisor_assignment_id

  ,p_cagr_grade_def_id            =>   l_cagr_grade_def_id

  ,p_cagr_concatenated_segments   => l_cagr_concatenated_segments
  ,p_group_name                   => l_group_name
  ,p_assignment_id                => l_assignment_id
  ,p_people_group_id              => l_people_group_id
  ,p_soft_coding_keyflex_id      =>  l_soft_coding_keyflex_id
  ,p_comment_id                   => l_comment_id
  ,p_object_version_number        => l_object_version_number
  ,p_effective_start_date         => l_effective_start_date
  ,p_effective_end_date           => l_effective_end_date
  ,p_assignment_sequence          => l_assignment_sequence
  ,p_appl_override_warning        => l_appl_override_warning
  );

  if g_debug then
    hr_utility.set_location(l_proc, 12);
  end if;


            Update_assign_records(l_per_assign_record.assignment_id,
                                  l_assignment_id,
                                  l_apl_ass_start_date,
                                  l_object_version_number);
  if g_debug then
    hr_utility.set_location(l_proc, 13);
  end if;
IRC_INTERVIEW_DETAILS_API.copy_interview_details
  (p_source_assignment_id          =>   l_per_assign_record.assignment_id
  ,p_target_assignment_id          =>  l_assignment_id
  ,p_target_party_id               =>  l_t_party_id
  );

IRC_COMMUNICATIONS_API.copy_comm_to_apl_asg
  (p_target_asg_id                 =>  l_assignment_id
  ,p_source_asg_id                 =>   l_per_assign_record.assignment_id
  );

-- Fix for bug 9718515 .

irc_assignment_details_api.copy_assignment_details
  (p_source_assignment_id          =>   l_per_assign_record.assignment_id
  ,p_target_assignment_id          =>   l_assignment_id
  );
--
irc_referral_info_api.copy_referral_details
  (p_source_assignment_id          =>   l_per_assign_record.assignment_id
  ,p_target_assignment_id          =>   l_assignment_id
  );
--
 fnd_attached_documents2_pkg.copy_attachments
 ( X_from_entity_name =>'PER_ASSIGNMENTS_F'
 , X_from_pk1_value   => l_per_assign_record.assignment_id
 , X_to_entity_name   =>'PER_ASSIGNMENTS_F'
 , X_to_pk1_value     => l_assignment_id
 );


   END;

BEGIN
select 1 into l_can_exists
from per_person_type_usages_f ptuf, per_person_types ppt
where ppt.system_person_type = 'IRC_REG_USER'
and ptuf.person_type_id = ppt.person_type_id
and ppt.business_group_id + 0 = nvl(l_bg_id,ppt.business_group_id)
and not exists (select null from per_all_assignments_f paaf where paaf.person_id = ptuf.person_id)
and not exists (select null from per_contact_relationships pcr where pcr.contact_person_id = ptuf.person_id)
and ptuf.person_id=p_target_person_id;
EXCEPTION
WHEN OTHERS THEN
NULL;
END;

  if g_debug then
    hr_utility.set_location(l_proc, 14);
  end if;

          ELSIF (l_t_person_type IN ('EMP','EX_EMP')
                  or (l_t_person_type='OTHER' and l_t_party_id is null)
                   or (l_t_person_type='OTHER' and l_can_exists =1 ) ) -- condition to chk whether person is canditate
                 AND   l_create_new_application='Y'   THEN

  BEGIN

 hr_applicant_api.apply_for_job_anytime
  (p_validate              => false
  ,p_effective_date        => l_apl_ass_start_date
  ,p_person_id             => p_target_person_id
  ,p_applicant_number      => l_applicant_number
  ,p_per_object_version_number   => l_per_object_version_number
  ,p_assignment_status_type_id    => l_assignment_status_type_id
  ,p_application_id       => l_application_id
  ,p_assignment_id        => l_assignment_id
  ,p_apl_object_version_number      => l_apl_object_version_number
  ,p_asg_object_version_number      => l_asg_object_version_number
  ,p_assignment_sequence            => l_assignment_sequence
  ,p_per_effective_start_date       => l_per_effective_start_date
  ,p_per_effective_end_date         => l_per_effective_end_date
  ,p_appl_override_warning          => l_appl_override_warning);

  if g_debug then
    hr_utility.set_location(l_proc, 15);
  end if;

   hr_assignment_api.update_apl_asg
    (p_effective_date               =>     l_apl_ass_start_date  --p_effective_date
    ,p_datetrack_update_mode        =>     'CORRECTION'
    ,p_assignment_id                =>     l_assignment_id
    ,p_object_version_number        =>     l_asg_object_version_number
    ,p_grade_id                     =>     l_per_assign_record.grade_id
    ,p_grade_ladder_pgm_id          =>     l_per_assign_record.grade_ladder_pgm_id
    ,p_job_id                       =>     l_per_assign_record.job_id
    ,p_payroll_id                   =>     l_per_assign_record.payroll_id
    ,p_location_id                  =>     l_per_assign_record.location_id
    ,p_organization_id              =>     l_per_assign_record.organization_id
    ,p_position_id                  =>     l_per_assign_record.position_id
    ,p_application_id               =>     l_application_id
    ,p_special_ceiling_step_id      =>     l_per_assign_record.special_ceiling_step_id
    ,p_recruiter_id                 =>     l_per_assign_record.recruiter_id
    ,p_recruitment_activity_id      =>     l_per_assign_record.recruitment_activity_id
    ,p_vacancy_id                   =>     l_per_assign_record.vacancy_id
    ,p_pay_basis_id                 =>     l_per_assign_record.pay_basis_id
    ,p_person_referred_by_id        =>     l_per_assign_record.person_referred_by_id
    ,p_supervisor_id                =>     l_per_assign_record.supervisor_id
    ,p_supervisor_assignment_id     =>     l_per_assign_record.supervisor_assignment_id
    ,p_source_organization_id       =>     l_per_assign_record.source_organization_id
    ,p_change_reason                =>     l_per_assign_record.change_reason
    ,p_assignment_status_type_id    =>     l_per_assign_record.assignment_status_type_id
    ,p_internal_address_line        =>     l_per_assign_record.internal_address_line
    ,p_default_code_comb_id         =>     l_per_assign_record.default_code_comb_id
    ,p_employment_category          =>     l_per_assign_record.employment_category
    ,p_frequency                    =>     l_per_assign_record.frequency
    ,p_manager_flag                 =>     l_per_assign_record.manager_flag
    ,p_normal_hours                 =>     l_per_assign_record.normal_hours
    ,p_perf_review_period           =>     l_per_assign_record.perf_review_period
    ,p_perf_review_period_frequency =>     l_per_assign_record.perf_review_period_frequency
    ,p_probation_period             =>     l_per_assign_record.probation_period
    ,p_probation_unit               =>     l_per_assign_record.probation_unit
    ,p_sal_review_period            =>     l_per_assign_record.sal_review_period
    ,p_sal_review_period_frequency  =>     l_per_assign_record.sal_review_period_frequency
    ,p_set_of_books_id              =>     l_per_assign_record.set_of_books_id
    ,p_title                        =>     l_per_assign_record.title
    ,p_source_type                  =>     l_per_assign_record.source_type
    ,p_time_normal_finish           =>     l_per_assign_record.time_normal_finish
    ,p_time_normal_start            =>     l_per_assign_record.time_normal_start
    ,p_bargaining_unit_code         =>     l_per_assign_record.bargaining_unit_code
    ,p_date_probation_end           =>     l_per_assign_record.date_probation_end
    ,p_ass_attribute_category       =>     l_per_assign_record.ass_attribute_category
   ,p_ass_attribute1               =>     l_per_assign_record.ass_attribute1
    ,p_ass_attribute2               =>    l_per_assign_record.ass_attribute2
    ,p_ass_attribute3               =>    l_per_assign_record.ass_attribute3
    ,p_ass_attribute4               =>    l_per_assign_record.ass_attribute4
    ,p_ass_attribute5               =>    l_per_assign_record.ass_attribute5
    ,p_ass_attribute6               =>    l_per_assign_record.ass_attribute6
    ,p_ass_attribute7               =>    l_per_assign_record.ass_attribute7
    ,p_ass_attribute8               =>    l_per_assign_record.ass_attribute8
    ,p_ass_attribute9               =>    l_per_assign_record.ass_attribute9
    ,p_ass_attribute10              =>    l_per_assign_record.ass_attribute10
    ,p_ass_attribute11              =>    l_per_assign_record.ass_attribute11
    ,p_ass_attribute12              =>    l_per_assign_record.ass_attribute12
    ,p_ass_attribute13              =>    l_per_assign_record.ass_attribute13
    ,p_ass_attribute14              =>    l_per_assign_record.ass_attribute14
    ,p_ass_attribute15              =>    l_per_assign_record.ass_attribute15
    ,p_ass_attribute16              =>    l_per_assign_record.ass_attribute16
    ,p_ass_attribute17              =>    l_per_assign_record.ass_attribute17
    ,p_ass_attribute18              =>    l_per_assign_record.ass_attribute18
    ,p_ass_attribute19              =>    l_per_assign_record.ass_attribute19
    ,p_ass_attribute20              =>    l_per_assign_record.ass_attribute20
    ,p_ass_attribute21              =>    l_per_assign_record.ass_attribute21
    ,p_ass_attribute22              =>   l_per_assign_record.ass_attribute22
    ,p_ass_attribute23              =>    l_per_assign_record.ass_attribute23
    ,p_ass_attribute24              =>    l_per_assign_record.ass_attribute24
    ,p_ass_attribute25              =>    l_per_assign_record.ass_attribute25
    ,p_ass_attribute26              =>    l_per_assign_record.ass_attribute26
    ,p_ass_attribute27              =>    l_per_assign_record.ass_attribute27
    ,p_ass_attribute28              =>    l_per_assign_record.ass_attribute28
    ,p_ass_attribute29              =>    l_per_assign_record.ass_attribute29
    ,p_ass_attribute30              =>    l_per_assign_record.ass_attribute30
    ,p_scl_segment1                 =>    l_scl_rec.segment1
    ,p_scl_segment2                 =>    l_scl_rec.segment2
    ,p_scl_segment3                 =>    l_scl_rec.segment3
    ,p_scl_segment4                 =>    l_scl_rec.segment4
    ,p_scl_segment5                 =>    l_scl_rec.segment5
    ,p_scl_segment6                 =>    l_scl_rec.segment6
    ,p_scl_segment7                 =>    l_scl_rec.segment7
    ,p_scl_segment8                 =>    l_scl_rec.segment8
    ,p_scl_segment9                 =>    l_scl_rec.segment9
    ,p_scl_segment10                =>    l_scl_rec.segment10
    ,p_scl_segment11                =>    l_scl_rec.segment11
    ,p_scl_segment12                =>    l_scl_rec.segment12
    ,p_scl_segment13                =>    l_scl_rec.segment13
    ,p_scl_segment14                =>    l_scl_rec.segment14
    ,p_scl_segment15                =>    l_scl_rec.segment15
    ,p_scl_segment16                =>    l_scl_rec.segment16
    ,p_scl_segment17                =>    l_scl_rec.segment17
    ,p_scl_segment18                =>    l_scl_rec.segment18
    ,p_scl_segment19                =>    l_scl_rec.segment19
    ,p_scl_segment20                =>    l_scl_rec.segment20
    ,p_scl_segment21                =>    l_scl_rec.segment21
    ,p_scl_segment22                =>    l_scl_rec.segment22
    ,p_scl_segment23                =>    l_scl_rec.segment23
    ,p_scl_segment24                =>    l_scl_rec.segment24
    ,p_scl_segment25                =>    l_scl_rec.segment25
    ,p_scl_segment26                =>    l_scl_rec.segment26
    ,p_scl_segment27                =>    l_scl_rec.segment27
    ,p_scl_segment28                =>    l_scl_rec.segment28
    ,p_scl_segment29                =>    l_scl_rec.segment29
    ,p_scl_segment30                =>    l_scl_rec.segment30
    ,p_pgp_segment1                 =>    l_pgp_rec.segment1
    ,p_pgp_segment2                 =>    l_pgp_rec.segment2
    ,p_pgp_segment3                 =>    l_pgp_rec.segment3
    ,p_pgp_segment4                 =>    l_pgp_rec.segment4
    ,p_pgp_segment5                 =>    l_pgp_rec.segment5
    ,p_pgp_segment6                 =>    l_pgp_rec.segment6
    ,p_pgp_segment7                 =>    l_pgp_rec.segment7
    ,p_pgp_segment8                 =>    l_pgp_rec.segment8
    ,p_pgp_segment9                 =>    l_pgp_rec.segment9
    ,p_pgp_segment10                =>    l_pgp_rec.segment10
    ,p_pgp_segment11                =>    l_pgp_rec.segment11
    ,p_pgp_segment12                =>    l_pgp_rec.segment12
    ,p_pgp_segment13                =>    l_pgp_rec.segment13
    ,p_pgp_segment14                =>    l_pgp_rec.segment14
    ,p_pgp_segment15                =>    l_pgp_rec.segment15
    ,p_pgp_segment16                =>    l_pgp_rec.segment16
    ,p_pgp_segment17                =>    l_pgp_rec.segment17
    ,p_pgp_segment18                =>    l_pgp_rec.segment18
    ,p_pgp_segment19                =>    l_pgp_rec.segment19
    ,p_pgp_segment20                =>    l_pgp_rec.segment20
    ,p_pgp_segment21                =>    l_pgp_rec.segment21
    ,p_pgp_segment22                =>    l_pgp_rec.segment22
    ,p_pgp_segment23                =>    l_pgp_rec.segment23
    ,p_pgp_segment24                =>    l_pgp_rec.segment24
    ,p_pgp_segment25                =>    l_pgp_rec.segment25
    ,p_pgp_segment26                =>    l_pgp_rec.segment26
    ,p_pgp_segment27                =>    l_pgp_rec.segment27
    ,p_pgp_segment28                =>    l_pgp_rec.segment28
    ,p_pgp_segment29                =>    l_pgp_rec.segment29
    ,p_pgp_segment30                =>    l_pgp_rec.segment30
    ,p_contract_id                  =>    l_per_assign_record.contract_id
    ,p_establishment_id             =>    l_per_assign_record.establishment_id
    ,p_collective_agreement_id      =>    l_per_assign_record.collective_agreement_id
    ,p_cagr_grade_def_id            =>     l_cagr_grade_def_id
    ,p_work_at_home                 =>    l_per_assign_record.work_at_home
    ,p_notice_period                =>    l_per_assign_record.notice_period
    ,p_notice_period_uom            =>    l_per_assign_record.notice_period_uom
   ,p_cagr_concatenated_segments   =>     l_cagr_concatenated_segments
    ,p_group_name                   =>     l_group_name
    ,p_concatenated_segments        =>     l_concatenated_segments
    ,p_comment_id                   =>     l_comment_id
    ,p_people_group_id              =>     l_people_group_id
    ,p_soft_coding_keyflex_id       =>     l_soft_coding_keyflex_id
    ,p_effective_start_date         =>     l_effective_start_date
    ,p_effective_end_date           =>     l_effective_end_date
        -- fix for bug 9718515 Starts here.
    ,p_job_post_source_name         =>    l_per_assign_record.job_post_source_name
    ,p_applicant_rank               =>    l_per_assign_record.applicant_rank
    ,p_posting_content_id           =>    l_per_assign_record.posting_content_id
    ,p_employee_category            =>    l_per_assign_record.employee_category
            -- fix for bug 9718515 Starts here.
    );

  if g_debug then
    hr_utility.set_location(l_proc, 16);
  end if;

   Update_assign_records(l_per_assign_record.assignment_id
                          ,l_assignment_id
			  ,l_apl_ass_start_date
			  ,l_asg_object_version_number
			  ,l_application_id );

  if g_debug then
    hr_utility.set_location(l_proc, 17);
  end if;

IRC_INTERVIEW_DETAILS_API.copy_interview_details
  (p_source_assignment_id          =>    l_per_assign_record.assignment_id
  ,p_target_assignment_id          =>   l_assignment_id
  ,p_target_party_id               =>  l_t_party_id
  );

IRC_COMMUNICATIONS_API.copy_comm_to_apl_asg
  (p_target_asg_id                 => l_assignment_id
  ,p_source_asg_id                 =>   l_per_assign_record.assignment_id
  );

  -- Fix for bug 9718515 .

irc_assignment_details_api.copy_assignment_details
  (p_source_assignment_id          =>   l_per_assign_record.assignment_id
  ,p_target_assignment_id          =>   l_assignment_id
  );
--
irc_referral_info_api.copy_referral_details
  (p_source_assignment_id          =>   l_per_assign_record.assignment_id
  ,p_target_assignment_id          =>   l_assignment_id
  );
--
 fnd_attached_documents2_pkg.copy_attachments
 ( X_from_entity_name =>'PER_ASSIGNMENTS_F'
 , X_from_pk1_value   => l_per_assign_record.assignment_id
 , X_to_entity_name   =>'PER_ASSIGNMENTS_F'
 , X_to_pk1_value     => l_assignment_id
 );


            END;
        END IF;
        END LOOP;

  if g_debug then
    hr_utility.set_location(l_proc, 18);
  end if;

        DECLARE
          l_object_version_number  NUMBER;
          l_effective_start_date   per_all_people_f.effective_start_date%TYPE;
          l_effective_end_date     per_all_people_f.effective_end_date%TYPE;
          l_person_org_manager_warning  VARCHAR2(1000);
        BEGIN
         IF p_term_or_purge_s = 'TERM' THEN
          hr_applicant_api.Terminate_applicant(p_validate => false,
                                               p_effective_date => trunc(sysdate) -1,
                                               p_person_id => p_source_person_id,
                                               p_object_version_number => l_object_version_number,
                                               p_effective_start_date => l_effective_start_date,
                                               p_effective_end_date => l_effective_end_date);

  if g_debug then
    hr_utility.set_location(l_proc, 19);
  end if;



         ELSIF p_term_or_purge_s = 'PURGE' THEN

          hr_person_api.Delete_person(p_validate => false,
                                      p_effective_date => trunc(sysdate),
                                      p_person_id => p_source_person_id,
                                      p_perform_predel_validation => false,
                                      p_person_org_manager_warning => l_person_org_manager_warning);
          END IF;
        END;

  if g_debug then
    hr_utility.set_location(l_proc, 20);
  end if;


      elsif l_exists <> 1 then
            hr_utility.set_message(800, 'HR_7092_WFLOW_INV_ACTION');
      hr_utility.raise_error;

    END IF;
  END merge_person;


--
-- ----------------------------------------------------------------------------
-- |---------------------------< merge_party >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure merge_party(p_validate               in boolean default false
                     ,p_target_party_id        in number
		     ,p_source_party_id        in number
		     ,p_term_or_purge_s        in varchar2 default null
		     ,p_create_new_application in varchar2 default 'Y') is

 cursor c_get_per_details(c_party_id number) is
 select person_id,business_group_id from per_all_people_f
 where party_id=c_party_id;

 l_t_person_id         number;
 l_t_bg_id             number;
 l_proc                varchar2(72) := g_package||'merge_party';


 begin


 if g_debug then
    hr_utility.set_location('Entering:'|| l_proc, 5);
    hr_utility.set_location('p_target_party_id:'|| p_target_party_id, 5);
    hr_utility.set_location('p_source_party_id:'|| p_source_party_id, 5);
 end if;

 savepoint hr_merge_party;

 -- get the person details that belong to source party

 for s_per_det in c_get_per_details(p_source_party_id)
 loop

    l_t_person_id:=null;
    l_t_bg_id    :=null;

    if g_debug then
    hr_utility.set_location(l_proc, 6);
    end if;

  begin
  -- check if person exists with target party_id in same bg as of source person.
  -- if yes, call merge person procedure to copy applications from source to target person
  -- if not, update the party_id of source person with target party_id.

  select distinct person_id,business_group_id
  into l_t_person_id,l_t_bg_id
  from per_all_people_f
  where party_id=p_target_party_id
  and business_group_id=s_per_det.business_group_id;


  merge_person(l_t_person_id,s_per_det.person_id,p_term_or_purge_s,p_create_new_application);


    exception
    when no_data_found then
    null;
  end;

  end loop;
  if g_debug then
    hr_utility.set_location(l_proc, 7);
  end if;

  update per_all_people_f paaf
  set party_id=p_target_party_id
  where party_id=p_source_party_id
  and not exists(select 1 from per_all_people_f
                 where business_group_id=paaf.business_group_id
                 and party_id=p_target_party_id);

  if p_validate then
    raise hr_api.validate_enabled;
  end if;

exception
   when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO hr_merge_party;
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    --
    ROLLBACK TO hr_merge_party;
    raise;

  END;

end hr_person_api;

/
