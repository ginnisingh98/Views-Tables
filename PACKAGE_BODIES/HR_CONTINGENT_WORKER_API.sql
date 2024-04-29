--------------------------------------------------------
--  DDL for Package Body HR_CONTINGENT_WORKER_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_CONTINGENT_WORKER_API" as
/* $Header: pecwkapi.pkb 120.4.12010000.1 2008/07/28 04:28:10 appldev ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_contingent_worker_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------------< create_cwk >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_cwk
  (p_validate                      in     boolean  default false
  ,p_start_date                    in     date
  ,p_business_group_id             in     number
  ,p_last_name                     in     varchar2
  ,p_person_type_id                in     number   default null
  ,p_npw_number                    in out nocopy varchar2
  ,p_background_check_status       in     varchar2 default null
  ,p_background_date_check         in     date     default null
  ,p_blood_type                    in     varchar2 default null
  ,p_comments                      in     varchar2 default null
  ,p_correspondence_language       in     varchar2 default null
  ,p_country_of_birth              in     varchar2 default null
  ,p_date_of_birth                 in     date     default null
  ,p_date_of_death                 in     date     default null
  ,p_dpdnt_adoption_date           in     date     default null
  ,p_dpdnt_vlntry_svce_flag        in     varchar2 default null
  ,p_email_address                 in     varchar2 default null
  ,p_first_name                    in     varchar2 default null
  ,p_fte_capacity                  in     number   default null
  ,p_honors                        in     varchar2 default null
  ,p_internal_location             in     varchar2 default null
  ,p_known_as                      in     varchar2 default null
  ,p_last_medical_test_by          in     varchar2 default null
  ,p_last_medical_test_date        in     date     default null
  ,p_mailstop                      in     varchar2 default null
  ,p_marital_status                in     varchar2 default null
  ,p_middle_names                  in     varchar2 default null
  ,p_national_identifier           in     varchar2 default null
  ,p_nationality                   in     varchar2 default null
  ,p_office_number                 in     varchar2 default null
  ,p_on_military_service           in     varchar2 default null
  ,p_party_id                      in     number   default null
  ,p_pre_name_adjunct              in     varchar2 default null
  ,p_previous_last_name            in     varchar2 default null
  ,p_projected_placement_end       in     date     default null
  ,p_receipt_of_death_cert_date    in     date     default null
  ,p_region_of_birth               in     varchar2 default null
  ,p_registered_disabled_flag      in     varchar2 default null
  ,p_resume_exists                 in     varchar2 default null
  ,p_resume_last_updated           in     date     default null
  ,p_second_passport_exists        in     varchar2 default null
  ,p_sex                           in     varchar2 default null
  ,p_student_status                in     varchar2 default null
  ,p_suffix                        in     varchar2 default null
  ,p_title                         in     varchar2 default null
  ,p_town_of_birth                 in     varchar2 default null
  ,p_uses_tobacco_flag             in     varchar2 default null
  ,p_vendor_id                     in     number   default null
  ,p_work_schedule                 in     varchar2 default null
  ,p_work_telephone                in     varchar2 default null
  ,p_exp_check_send_to_address     in     varchar2 default null
  ,p_hold_applicant_date_until     in     date     default null
  ,p_date_employee_data_verified   in     date     default null
  ,p_benefit_group_id              in     number   default null
  ,p_coord_ben_med_pln_no          in     varchar2 default null
  ,p_coord_ben_no_cvg_flag         in     varchar2 default null
  ,p_original_date_of_hire         in     date     default null
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
  ,p_per_information16             in       varchar2 default null
  ,p_per_information17             in       varchar2 default null
  ,p_per_information18             in       varchar2 default null
  ,p_per_information19             in       varchar2 default null
  ,p_per_information20             in       varchar2 default null
  ,p_per_information21             in       varchar2 default null
  ,p_per_information22             in       varchar2 default null
  ,p_per_information23             in       varchar2 default null
  ,p_per_information24             in       varchar2 default null
  ,p_per_information25             in       varchar2 default null
  ,p_per_information26             in       varchar2 default null
  ,p_per_information27             in       varchar2 default null
  ,p_per_information28             in       varchar2 default null
  ,p_per_information29             in       varchar2 default null
  ,p_per_information30             in       varchar2 default null
  ,p_person_id                        out nocopy   number
  ,p_per_object_version_number        out nocopy   number
  ,p_per_effective_start_date         out nocopy   date
  ,p_per_effective_end_date           out nocopy   date
  ,p_pdp_object_version_number        out nocopy   number
  ,p_full_name                        out nocopy   varchar2
  ,p_comment_id                       out nocopy   number
  ,p_assignment_id                    out nocopy   number
  ,p_asg_object_version_number        out nocopy   number
  ,p_assignment_sequence              out nocopy   number
  ,p_assignment_number                out nocopy   varchar2
  ,p_name_combination_warning         out nocopy   boolean
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72) := g_package||'create_cwk';
  l_person_id                         number;
  l_person_type_id                    per_person_types.person_type_id%type  := p_person_type_id;
  l_person_type_id1                   per_person_types.person_type_id%type;
  l_start_date                        date;
  l_date_of_birth                     date;
  l_date_of_death                     date;
  l_receipt_of_death_cert_date        date;
  l_dpdnt_adoption_date               date;
  l_per_object_version_number         number;
  l_per_effective_start_date          date;
  l_per_effective_end_date            date;
  l_current_npw_flag                  per_people_f.current_npw_flag%type;
  l_current_applicant_flag            per_people_f.current_applicant_flag%type;
  l_current_employee_flag             per_people_f.current_employee_flag%type;
  l_current_emp_or_apl_flag           per_people_f.current_emp_or_apl_flag%type;
  l_employee_number                   per_people_f.employee_number%TYPE;
  l_applicant_number                  per_people_f.applicant_number%TYPE;
  l_npw_number                        per_people_f.npw_number%TYPE;
  l_full_name                         per_people_f.full_name%type;
  l_comment_id                        number;
  l_dob_null_warning                  boolean;
  l_orig_hire_warning                 boolean;
  l_assignment_id                     number;
  l_asg_object_version_number         number;
  l_assignment_sequence               per_assignments_f.assignment_sequence%type;
  l_assignment_number                 per_assignments_f.assignment_number%type;
  l_name_combination_warning          boolean;
  l_period_of_placement_id            number;
  l_pdp_object_version_number         number;
  l_phn_object_version_number         number;
  l_phone_id                          number;
--
begin

  hr_utility.set_location('Entering:'|| l_proc, 10);

  --
  -- Issue a savepoint
  --
  savepoint create_cwk;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_start_date                  := trunc(p_start_date);
  l_date_of_birth               := trunc(p_date_of_birth);
  l_date_of_death               := trunc(p_date_of_death);
  l_receipt_of_death_cert_date  := trunc(p_receipt_of_death_cert_date);
  l_dpdnt_adoption_date         := trunc(p_dpdnt_adoption_date);
  --
  -- Call Before Process User Hook
  --
  begin
    hr_contingent_worker_bk1.create_cwk_b
      (p_start_date                    => l_start_date
      ,p_business_group_id             => p_business_group_id
      ,p_last_name                     => p_last_name
      ,p_person_type_id                => p_person_type_id
      ,p_npw_number                    => p_npw_number
      ,p_background_check_status       => p_background_check_status
      ,p_background_date_check         => p_background_date_check
      ,p_blood_type                    => p_blood_type
      ,p_comments                      => p_comments
      ,p_correspondence_language       => p_correspondence_language
      ,p_country_of_birth              => p_country_of_birth
      ,p_date_of_birth                 => l_date_of_birth
      ,p_date_of_death                 => l_date_of_death
      ,p_dpdnt_adoption_date           => l_dpdnt_adoption_date
      ,p_dpdnt_vlntry_svce_flag        => p_dpdnt_vlntry_svce_flag
      ,p_email_address                 => p_email_address
      ,p_first_name                    => p_first_name
      ,p_fte_capacity                  => p_fte_capacity
      ,p_honors                        => p_honors
      ,p_internal_location             => p_internal_location
      ,p_known_as                      => p_known_as
      ,p_last_medical_test_by          => p_last_medical_test_by
      ,p_last_medical_test_date        => p_last_medical_test_date
      ,p_mailstop                      => p_mailstop
      ,p_marital_status                => p_marital_status
      ,p_middle_names                  => p_middle_names
      ,p_national_identifier           => p_national_identifier
      ,p_nationality                   => p_nationality
      ,p_office_number                 => p_office_number
      ,p_on_military_service           => p_on_military_service
      ,p_party_id                      => p_party_id
      ,p_pre_name_adjunct              => p_pre_name_adjunct
      ,p_previous_last_name            => p_previous_last_name
      ,p_projected_placement_end       => null
      ,p_receipt_of_death_cert_date    => l_receipt_of_death_cert_date
      ,p_region_of_birth               => p_region_of_birth
      ,p_registered_disabled_flag      => p_registered_disabled_flag
      ,p_resume_exists                 => p_resume_exists
      ,p_resume_last_updated           => p_resume_last_updated
      ,p_second_passport_exists        => p_second_passport_exists
      ,p_sex                           => p_sex
      ,p_student_status                => p_student_status
      ,p_suffix                        => p_suffix
      ,p_title                         => p_title
      ,p_town_of_birth                 => p_town_of_birth
      ,p_uses_tobacco_flag             => p_uses_tobacco_flag
      ,p_vendor_id                     => p_vendor_id
      ,p_work_schedule                 => p_work_schedule
      ,p_work_telephone                => p_work_telephone
      ,p_exp_check_send_to_address     => p_exp_check_send_to_address
      ,p_hold_applicant_date_until     => p_hold_applicant_date_until
      ,p_date_employee_data_verified   => p_date_employee_data_verified
      ,p_benefit_group_id              => p_benefit_group_id
      ,p_coord_ben_med_pln_no          => p_coord_ben_med_pln_no
      ,p_coord_ben_no_cvg_flag         => p_coord_ben_no_cvg_flag
      ,p_original_date_of_hire         => p_original_date_of_hire
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
      ,p_per_information_category      => p_per_information_category
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
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_cwk'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Validation in addition to Row Handlers
  --
  -- If the specified person type id is not null then check that it
  -- corresponds to type 'CWK', is currently active and is in the correct
  -- business group, otherwise set person type to the active default for CWK
  -- in the current business group.
  --
  per_per_bus.chk_person_type
    (p_person_type_id    => l_person_type_id
    ,p_business_group_id => p_business_group_id
    ,p_expected_sys_type => 'CWK'
    );
  --
  hr_utility.set_location(l_proc, 30);
  --
  -- Initialise local variables as appropriate
  --
  l_applicant_number := null;
  l_employee_number := null;
  l_npw_number := p_npw_number;
  l_current_npw_flag := 'Y';
  l_person_type_id1   := hr_person_type_usage_info.get_default_person_type_id
                                         (p_business_group_id,
                                          'OTHER');
  --
  -- Process Logic
  --
  per_per_ins.ins
     (p_start_date                   => l_start_date
     ,p_effective_date               => l_start_date
     ,p_business_group_id            => p_business_group_id
     ,p_person_type_id               => l_person_type_id1
     ,p_last_name                    => p_last_name
     ,p_background_check_status      => p_background_check_status
     ,p_background_date_check        => p_background_date_check
     ,p_blood_type                   => p_blood_type
     ,p_comments                     => p_comments
     ,p_correspondence_language      => p_correspondence_language
     ,p_country_of_birth             => p_country_of_birth
     ,p_current_npw_flag             => l_current_npw_flag
     ,p_date_of_birth                => l_date_of_birth
     ,p_date_of_death                => l_date_of_death
     ,p_dpdnt_adoption_date          => l_dpdnt_adoption_date
     ,p_dpdnt_vlntry_svce_flag       => p_dpdnt_vlntry_svce_flag
     ,p_email_address                => p_email_address
     ,p_first_name                   => p_first_name
     ,p_fte_capacity                 => p_fte_capacity
     ,p_honors                       => p_honors
     ,p_internal_location            => p_internal_location
     ,p_known_as                     => p_known_as
     ,p_last_medical_test_by         => p_last_medical_test_by
     ,p_last_medical_test_date       => p_last_medical_test_date
     ,p_mailstop                     => p_mailstop
     ,p_marital_status               => p_marital_status
     ,p_middle_names                 => p_middle_names
     ,p_national_identifier          => p_national_identifier
     ,p_nationality                  => p_nationality
     ,p_office_number                => p_office_number
     ,p_on_military_service          => p_on_military_service
     ,p_party_id                     => p_party_id
     ,p_pre_name_adjunct             => p_pre_name_adjunct
     ,p_previous_last_name           => p_previous_last_name
     ,p_receipt_of_death_cert_date   => l_receipt_of_death_cert_date
     ,p_region_of_birth              => p_region_of_birth
     ,p_registered_disabled_flag     => p_registered_disabled_flag
     ,p_resume_exists                => p_resume_exists
     ,p_resume_last_updated          => p_resume_last_updated
     ,p_second_passport_exists       => p_second_passport_exists
     ,p_sex                          => p_sex
     ,p_student_status               => p_student_status
     ,p_suffix                       => p_suffix
     ,p_title                        => p_title
     ,p_town_of_birth                => p_town_of_birth
     ,p_uses_tobacco_flag            => p_uses_tobacco_flag
     ,p_work_schedule                => p_work_schedule
     ,p_expense_check_send_to_addres => p_exp_check_send_to_address
     ,p_hold_applicant_date_until    => p_hold_applicant_date_until
     ,p_date_employee_data_verified  => p_date_employee_data_verified
     ,p_benefit_group_id             => p_benefit_group_id
     ,p_coord_ben_med_pln_no         => p_coord_ben_med_pln_no
     ,p_coord_ben_no_cvg_flag        => p_coord_ben_no_cvg_flag
     ,p_original_date_of_hire        => p_original_date_of_hire
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
     --
     ,p_applicant_number             => l_applicant_number
     ,p_employee_number              => l_employee_number
     ,p_npw_number                   => p_npw_number
     ,p_person_id                    => l_person_id
     ,p_object_version_number        => l_per_object_version_number
     ,p_effective_start_date         => l_per_effective_start_date
     ,p_effective_end_date           => l_per_effective_end_date
     ,p_full_name                    => l_full_name
     ,p_comment_id                   => l_comment_id
     ,p_current_applicant_flag       => l_current_applicant_flag
     ,p_current_employee_flag        => l_current_employee_flag
     ,p_current_emp_or_apl_flag      => l_current_emp_or_apl_flag
     ,p_name_combination_warning     => l_name_combination_warning
     ,p_dob_null_warning             => l_dob_null_warning
     ,p_orig_hire_warning            => l_orig_hire_warning
      );
  --
  hr_utility.set_location(l_proc, 40);

  --
  -- Add this person to the relevant security definitions.
  --
  hr_security_internal.populate_new_person
    (p_person_id         => l_person_id
    ,p_business_group_id => p_business_group_id);

  hr_utility.set_location(l_proc, 45);

  --
  -- Create the period of placement record
  --
  per_pdp_ins.ins
    (p_date_start                   => l_start_date
    ,p_effective_date               => l_start_date
    ,p_business_group_id            => p_business_group_id
    ,p_person_id                    => l_person_id
    ,p_projected_termination_date   => null
    ,p_validate_df_flex             => false
    --
    ,p_object_version_number        => l_pdp_object_version_number
     );

  hr_utility.set_location(l_proc, 60);

  --
  -- Maintain Person Type Usages
  --
  hr_per_type_usage_internal.maintain_person_type_usage
   (p_effective_date       => l_start_date
   ,p_person_id            => l_person_id
   ,p_person_type_id       => l_person_type_id
   );
  --
  --
  hr_utility.set_location(l_proc, 70);
  --
  -- Create the default non-payrolled assignment
  --
  hr_assignment_internal.create_default_cwk_asg
    (p_effective_date                  => l_start_date
    ,p_business_group_id               => p_business_group_id
    ,p_person_id                       => l_person_id
    ,p_placement_date_start            => l_start_date
    --
    ,p_assignment_id                   => l_assignment_id
    ,p_object_version_number           => l_asg_object_version_number
    ,p_assignment_sequence             => l_assignment_sequence
    ,p_assignment_number               => l_assignment_number
    );
  --
  hr_utility.set_location(l_proc, 80);
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
  -- Call After Process User Hook
  --
  begin
    hr_contingent_worker_bk1.create_cwk_a
      (p_start_date                    => l_start_date
      ,p_business_group_id             => p_business_group_id
      ,p_last_name                     => p_last_name
      ,p_person_type_id                => p_person_type_id
      ,p_npw_number                    => p_npw_number
      ,p_background_check_status       => p_background_check_status
      ,p_background_date_check         => p_background_date_check
      ,p_blood_type                    => p_blood_type
      ,p_comments                      => p_comments
      ,p_correspondence_language       => p_correspondence_language
      ,p_country_of_birth              => p_country_of_birth
      ,p_date_of_birth                 => l_date_of_birth
      ,p_date_of_death                 => l_date_of_death
      ,p_dpdnt_adoption_date           => l_dpdnt_adoption_date
      ,p_dpdnt_vlntry_svce_flag        => p_dpdnt_vlntry_svce_flag
      ,p_email_address                 => p_email_address
      ,p_first_name                    => p_first_name
      ,p_fte_capacity                  => p_fte_capacity
      ,p_honors                        => p_honors
      ,p_internal_location             => p_internal_location
      ,p_known_as                      => p_known_as
      ,p_last_medical_test_by          => p_last_medical_test_by
      ,p_last_medical_test_date        => p_last_medical_test_date
      ,p_mailstop                      => p_mailstop
      ,p_marital_status                => p_marital_status
      ,p_middle_names                  => p_middle_names
      ,p_national_identifier           => p_national_identifier
      ,p_nationality                   => p_nationality
      ,p_office_number                 => p_office_number
      ,p_on_military_service           => p_on_military_service
      ,p_party_id                      => p_party_id
      ,p_pre_name_adjunct              => p_pre_name_adjunct
      ,p_previous_last_name            => p_previous_last_name
      ,p_projected_placement_end       => null
      ,p_receipt_of_death_cert_date    => l_receipt_of_death_cert_date
      ,p_region_of_birth               => p_region_of_birth
      ,p_registered_disabled_flag      => p_registered_disabled_flag
      ,p_resume_exists                 => p_resume_exists
      ,p_resume_last_updated           => p_resume_last_updated
      ,p_second_passport_exists        => p_second_passport_exists
      ,p_sex                           => p_sex
      ,p_student_status                => p_student_status
      ,p_suffix                        => p_suffix
      ,p_title                         => p_title
      ,p_town_of_birth                 => p_town_of_birth
      ,p_uses_tobacco_flag             => p_uses_tobacco_flag
      ,p_vendor_id                     => p_vendor_id
      ,p_work_schedule                 => p_work_schedule
      ,p_work_telephone                => p_work_telephone
      ,p_exp_check_send_to_address     => p_exp_check_send_to_address
      ,p_hold_applicant_date_until     => p_hold_applicant_date_until
      ,p_date_employee_data_verified   => p_date_employee_data_verified
      ,p_benefit_group_id              => p_benefit_group_id
      ,p_coord_ben_med_pln_no          => p_coord_ben_med_pln_no
      ,p_coord_ben_no_cvg_flag         => p_coord_ben_no_cvg_flag
      ,p_original_date_of_hire         => p_original_date_of_hire
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
      ,p_per_information_category      => p_per_information_category
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
      ,p_person_id                     => l_person_id
      ,p_per_object_version_number     => l_per_object_version_number
      ,p_per_effective_start_date      => l_per_effective_start_date
      ,p_per_effective_end_date        => l_per_effective_end_date
      ,p_pdp_object_version_number     => l_pdp_object_version_number
      ,p_full_name                     => l_full_name
      ,p_comment_id                    => l_comment_id
      ,p_assignment_id                 => l_assignment_id
      ,p_asg_object_version_number     => l_asg_object_version_number
      ,p_assignment_sequence           => l_assignment_sequence
      ,p_assignment_number             => l_assignment_number
      ,p_name_combination_warning      => l_name_combination_warning
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_cwk'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --

  --
  -- Start of fix for bug 3684087 by risgupta on 12092005 as done in bug# 3062967
  --
  begin
    SELECT object_version_number
      INTO p_per_object_Version_number
      FROM per_all_people_f
     WHERE person_id = l_person_id
       And effective_start_Date = l_per_effective_start_date
       and effective_end_Date = l_per_effective_end_date;
  exception
    when no_data_found then
      p_per_object_Version_number := l_per_object_version_number;
  end;
  --
  -- END of fix for bug 3684087
  --

  p_person_id                 := l_person_id;
  p_assignment_sequence       := l_assignment_sequence;
  p_assignment_number         := l_assignment_number;
  p_assignment_id             := l_assignment_id;
  -- commented for bug# 3684087
  --p_per_object_version_number := l_per_object_version_number;
  p_asg_object_version_number := l_asg_object_version_number;
  p_pdp_object_version_number := l_pdp_object_version_number;
  p_per_effective_start_date  := l_per_effective_start_date;
  p_per_effective_end_date    := l_per_effective_end_date;
  p_full_name                 := l_full_name;
  p_comment_id                := l_comment_id;
  p_name_combination_warning  := l_name_combination_warning;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_cwk;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
  p_person_id                 := null;
  p_npw_number                 := l_npw_number;
  p_assignment_sequence       := null;
  p_assignment_number         := null;
  p_assignment_id             := null;
  p_per_object_version_number := null;
  p_asg_object_version_number := null;
  p_pdp_object_version_number := null;
  p_per_effective_start_date  := null;
  p_per_effective_end_date    := null;
  p_full_name                 := null;
  p_comment_id                := null;
  p_name_combination_warning  := l_name_combination_warning;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_cwk;
    --
    -- set in out parameters and set out parameters
    --
  p_person_id                 := null;
  p_npw_number                 := l_npw_number;
  p_assignment_sequence       := null;
  p_assignment_number         := null;
  p_assignment_id             := null;
  p_per_object_version_number := null;
  p_asg_object_version_number := null;
  p_pdp_object_version_number := null;
  p_per_effective_start_date  := null;
  p_per_effective_end_date    := null;
  p_full_name                 := null;
  p_comment_id                := null;
  p_name_combination_warning  := l_name_combination_warning;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_cwk;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< convert_to_cwk >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure convert_to_cwk
  (p_validate                      in     boolean default false
  ,p_effective_date                in     date
  ,p_person_id                     in     number
  ,p_object_version_number         in out nocopy number
  ,p_npw_number                    in out nocopy varchar2
  ,p_projected_placement_end       in     date     default null
  ,p_person_type_id                in     number  default null
  ,p_datetrack_update_mode         in     varchar2
  ,p_per_effective_start_date         out nocopy date
  ,p_per_effective_end_date           out nocopy date
  ,p_pdp_object_version_number        out nocopy   number
  ,p_assignment_id                    out nocopy number
  ,p_asg_object_version_number        out nocopy number
  ,p_assignment_sequence              out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'convert_to_cwk';
  l_object_version_number per_people_f.object_version_number%type;
  l_npw_number            per_people_f.npw_number%type;
  l_person_type_id        number := p_person_type_id;
  l_person_type_id1       number;
  l_effective_date        date;
  l_datetrack_update_mode      varchar2(30);
  l_ptu_update_mode            varchar2(30);
  l_per_effective_start_date   date;
  l_per_effective_end_date     date;
  l_comment_id                 number;
  l_current_applicant_flag     varchar2(1);
  l_current_emp_or_apl_flag    varchar2(1);
  l_current_employee_flag      varchar2(1);
  l_full_name                  per_all_people_f.full_name%TYPE;
  l_name_combination_warning   boolean;
  l_dob_null_warning           boolean;
  l_orig_hire_warning          boolean;
  l_pdp_object_version_number  number;
  l_assignment_id              number;
  l_asg_object_version_number  number;
  l_assignment_sequence        number;
  l_assignment_number          per_assignments_f.assignment_number%type;
  --
  cursor csr_per_details
    (p_person_id number
    ,p_effective_date date
    )
  IS
    SELECT ppf.business_group_id
          ,ppf.person_type_id
          ,ppt.system_person_type
          ,ppf.npw_number
          ,ppf.applicant_number
          ,ppf.employee_number
     FROM  per_all_people_f ppf
          ,per_person_types ppt
    WHERE ppt.person_type_id = ppf.person_type_id
      AND ppf.person_id = p_person_id
      AND p_effective_date between ppf.effective_start_date and ppf.effective_end_date;
  --
  l_per_details_rec   csr_per_details%rowtype;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);

  --
  -- Ensure mandatory arguments have been passed
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'person_id'
    ,p_argument_value               => p_person_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'effective_date'
    ,p_argument_value               => p_effective_date
    );
  --
  -- Issue a savepoint
  --
  savepoint convert_to_cwk;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  l_object_version_number := p_object_version_number;
  l_npw_number       := p_npw_number;
  --
  -- Call Before Process User Hook
  --
  begin
    hr_contingent_worker_bk2.convert_to_cwk_b
      (p_effective_date                => l_effective_date
      ,p_person_id                     => p_person_id
      ,p_object_version_number         => p_object_version_number
      ,p_npw_number                    => p_npw_number
      ,p_projected_placement_end       => null
      ,p_person_type_id                => p_person_type_id
      ,p_datetrack_update_mode         => p_datetrack_update_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'convert_to_cwk'
        ,p_hook_type   => 'BP'
        );
  end;
  hr_utility.set_location(l_proc, 20);
  --
  -- Validation in addition to Row Handlers
  --
  -- Get derived details for person on effective date
  --
  OPEN csr_per_details
    (p_person_id                    => p_person_id
    ,p_effective_date               => p_effective_date
    );
  FETCH csr_per_details INTO l_per_details_rec;
  IF csr_per_details%NOTFOUND
  THEN
    CLOSE csr_per_details;
    fnd_message.set_name('PER','PER_289602_CWK_INV_PERSON_ID');
    fnd_message.raise_error;
  END IF;
  CLOSE csr_per_details;
  --
  -- If the specified person type id is not null then check that it
  -- corresponds to type 'CWK', is currently active and is in the correct
  -- business group, otherwise set person type to the active default for CWK
  -- in the current business group.
  --
  per_per_bus.chk_person_type
    (p_person_type_id    => l_person_type_id
    ,p_business_group_id => l_per_details_rec.business_group_id
    ,p_expected_sys_type => 'CWK'
    );
  hr_utility.set_location(l_proc, 30);
  --
  -- Check for future person_type_changes
  --
  if hr_person.chk_future_person_type(l_per_details_rec.system_person_type
                                     ,p_person_id
                                     ,l_per_details_rec.business_group_id
                                     ,p_effective_date) then
    fnd_message.set_name('PAY','HR_7193_PER_FUT_TYPE_EXISTS');
    fnd_message.raise_error;
  end if;
  --
  -- Check against the existing person type records.
  --
  if hr_general2.is_person_type(p_person_id
                               ,'EMP'
                               ,l_effective_date)
   or hr_general2.is_person_type(p_person_id
                               ,'CWK'
                               ,l_effective_date) then
    fnd_message.set_name('PER','PER_289603_CWK_INV_PERSON_TYPE');
    fnd_message.raise_error;
  elsif l_per_details_rec.system_person_type = 'OTHER' then
      l_person_type_id1 :=  hr_person_type_usage_info.get_default_person_type_id
                                         (l_per_details_rec.business_group_id,
                                          'OTHER');
  else
      l_person_type_id1 := l_per_details_rec.person_type_id;
    hr_utility.set_location(l_proc,50);
  end if;
  --
  -- Ensure the npw_number will not be changed if it exists
  --
  IF l_per_details_rec.npw_number IS NOT NULL
    AND NVL(p_npw_number,hr_api.g_number) <> l_per_details_rec.npw_number
  THEN
    hr_utility.set_location(l_proc,60);
     p_npw_number := l_per_details_rec.npw_number;
  END IF;
  --
  -- Check: is this back-to-back contract?
  --
  if hr_general2.is_person_type(p_person_id
                               ,'EX_CWK'
                               ,l_effective_date)
    and hr_general2.is_person_type(p_person_id
                                  ,'CWK'
                                  ,l_effective_date-1) then
     l_datetrack_update_mode := 'CORRECTION';
     l_ptu_update_mode := 'CORRECTION';
   hr_utility.set_location(l_proc,70);
  elsif hr_general2.is_person_type(p_person_id
                                  ,'EX_EMP'
                                  ,l_effective_date)
     and hr_general2.is_person_type(p_person_id
                                   ,'EMP'
                                   ,l_effective_date-1) then
     l_datetrack_update_mode := 'CORRECTION';
     l_ptu_update_mode := 'UPDATE';
   hr_utility.set_location(l_proc,80);
  else
     --
     -- Support the use of CORRECTION for the person table handler routines.
     --
     if p_datetrack_update_mode = 'CORRECTION' then
       l_datetrack_update_mode := p_datetrack_update_mode;
     else
       l_datetrack_update_mode := 'UPDATE';
     end if;
     l_ptu_update_mode := 'UPDATE';
  end if;
  --
  -- Process Logic
  --
  per_per_upd.upd
  (p_person_id                    => p_person_id
  ,p_effective_date               => l_effective_date
  ,p_datetrack_mode               => l_datetrack_update_mode
  ,p_person_type_id               => l_person_type_id1
  ,p_applicant_number             => l_per_details_rec.applicant_number
  ,p_employee_number              => l_per_details_rec.employee_number
  ,p_npw_number                   => p_npw_number
  ,p_current_npw_flag             => 'Y'
  ,p_object_version_number        => p_object_version_number

  ,p_effective_start_date         => l_per_effective_start_date
  ,p_effective_end_date           => l_per_effective_end_date
  ,p_comment_id                   => l_comment_id
  ,p_current_applicant_flag       => l_current_applicant_flag
  ,p_current_emp_or_apl_flag      => l_current_emp_or_apl_flag
  ,p_current_employee_flag        => l_current_employee_flag
  ,p_full_name                    => l_full_name
  ,p_name_combination_warning     => l_name_combination_warning
  ,p_dob_null_warning             => l_dob_null_warning
  ,p_orig_hire_warning            => l_orig_hire_warning
  );

  hr_utility.set_location(l_proc, 90);

  hr_security_internal.populate_new_person
     (p_business_group_id            => l_per_details_rec.business_group_id
     ,p_person_id                    => p_person_id);

  hr_utility.set_location(l_proc, 93);

  --
  -- Maintain PTU
  --
  hr_per_type_usage_internal.maintain_person_type_usage
   (p_effective_date        => l_effective_date
   ,p_person_id             => p_person_id
   ,p_person_type_id        => l_person_type_id
   ,p_datetrack_update_mode => l_ptu_update_mode
   );

  hr_utility.set_location(l_proc, 95);

  --
  -- Create the period of placement record
  --
  per_pdp_ins.ins
    (p_date_start                   => l_effective_date
    ,p_effective_date               => l_effective_date
    ,p_business_group_id            => l_per_details_rec.business_group_id
    ,p_person_id                    => p_person_id
    ,p_projected_termination_date   => null
    ,p_validate_df_flex             => false
    --
    ,p_object_version_number        => l_pdp_object_version_number
     );
  --
  hr_utility.set_location(l_proc, 100);
  --
  -- Create the default non-payrolled assignment
  --
  hr_assignment_internal.create_default_cwk_asg
    (p_effective_date                  => l_effective_date
    ,p_business_group_id               => l_per_details_rec.business_group_id
    ,p_person_id                       => p_person_id
    ,p_placement_date_start            => l_effective_date
    --
    ,p_assignment_id                   => l_assignment_id
    ,p_object_version_number           => l_asg_object_version_number
    ,p_assignment_sequence             => l_assignment_sequence
    ,p_assignment_number               => l_assignment_number
    );
  --
  hr_utility.set_location(l_proc, 110);
  --
  -- Call After Process User Hook
  --
  begin
    hr_contingent_worker_bk2.convert_to_cwk_a
      (p_effective_date                => l_effective_date
      ,p_person_id                     => p_person_id
      ,p_object_version_number         => p_object_version_number
      ,p_npw_number                    => p_npw_number
      ,p_projected_placement_end       => null
      ,p_person_type_id                => l_person_type_id
      ,p_datetrack_update_mode         => p_datetrack_update_mode
      ,p_per_effective_start_date      => l_per_effective_start_date
      ,p_per_effective_end_date        => l_per_effective_end_date
      ,p_pdp_object_version_number     => l_pdp_object_version_number
      ,p_assignment_id                 => l_assignment_id
      ,p_asg_object_version_number     => l_asg_object_version_number
      ,p_assignment_sequence           => l_assignment_sequence
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'convert_to_cwk'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_per_effective_start_date  := l_per_effective_start_date;
  p_per_effective_end_date    := l_per_effective_end_date;
  p_pdp_object_version_number := l_pdp_object_version_number;
  p_assignment_id             := l_assignment_id;
  p_asg_object_version_number := l_asg_object_version_number;
  p_assignment_sequence       := l_assignment_sequence;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 170);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to convert_to_cwk;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
  p_object_version_number     := l_object_version_number;
  p_npw_number                := l_npw_number;
  p_pdp_object_version_number := null;
  p_per_effective_start_date  := null;
  p_per_effective_end_date    := null;
  p_assignment_id             := null;
  p_asg_object_version_number := null;
  p_assignment_sequence       := null;
  hr_utility.set_location(' Leaving:'||l_proc, 180);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to convert_to_cwk;
   --
    -- set in out parameters and set out parameters
    --
p_object_version_number     := l_object_version_number;
  p_npw_number                := l_npw_number;
  p_pdp_object_version_number := null;
  p_per_effective_start_date  := null;
  p_per_effective_end_date    := null;
  p_assignment_id             := null;
  p_asg_object_version_number := null;
  p_assignment_sequence       := null;
   --
    hr_utility.set_location(' Leaving:'||l_proc, 190);
    raise;
end convert_to_cwk;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< apply_for_job >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure apply_for_job
  (p_validate                      in     boolean default false
  ,p_effective_date                in     date
  ,p_person_id                     in     number
  ,p_object_version_number         in out nocopy number
  ,p_applicant_number              in out nocopy varchar2
  ,p_person_type_id                in     number  default null
  ,p_vacancy_id                    in     number  default null
  ,p_per_effective_start_date         out nocopy date
  ,p_per_effective_end_date           out nocopy date
  ,p_application_id                   out nocopy number
  ,p_apl_object_version_number        out nocopy number
  ,p_assignment_id                    out nocopy number
  ,p_asg_object_version_number        out nocopy number
  ,p_assignment_sequence              out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'apply_for_job';
  l_effective_date             date;
  l_person_type_id             number := p_person_type_id;
  l_person_type_id1            number;
  l_comment_id                 number;
  l_current_applicant_flag     varchar2(1);
  l_current_emp_or_apl_flag    varchar2(1);
  l_current_employee_flag      varchar2(1);
  l_full_name                  per_all_people_f.full_name%TYPE;
  l_name_combination_warning   boolean;
  l_dob_null_warning           boolean;
  l_orig_hire_warning          boolean;
  l_per_effective_start_date   date;
  l_per_effective_end_date     date;
  l_application_id            number;
  l_apl_object_version_number number;
  l_assignment_id             number;
  l_asg_object_version_number number;
  l_assignment_sequence       number;
  l_object_version_number     number;
  l_applicant_number          per_people_f.applicant_number%type;
  l_dummy                     varchar2(1);
  --
  cursor csr_per_details
    (p_person_id number
    ,p_effective_date date
    )
  IS
    SELECT ppf.business_group_id
          ,ppf.person_type_id
          ,ppt.system_person_type
          ,ppf.npw_number
          ,ppf.applicant_number
          ,ppf.employee_number
     FROM  per_all_people_f ppf
          ,per_person_types ppt
    WHERE ppt.person_type_id = ppf.person_type_id
      AND ppf.person_id = p_person_id
      AND p_effective_date between ppf.effective_start_date and ppf.effective_end_date;
  --
  l_per_details_rec   csr_per_details%rowtype;
  --
  cursor csr_fut_apl
    (p_person_id number
    ,p_effective_date date
    )
  IS
   select 'Y'
   from dual
   where exists (select 'Y'
                 from per_person_type_usages_f ptu
                     ,per_person_types ppt
                 where ptu.person_id = p_person_id
                     and ppt.person_type_id = ptu.person_type_id
                     and ptu.effective_start_date >= p_effective_date
                     and ppt.system_person_type = 'APL');
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure mandatory arguments have been passed
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'person_id'
    ,p_argument_value               => p_person_id
    );
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'effective_date'
    ,p_argument_value               => p_effective_date
    );
  --
  -- Issue a savepoint
  --
  savepoint apply_for_job;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  l_object_version_number := p_object_version_number;
  l_applicant_number       := p_applicant_number;
  --
  -- Call Before Process User Hook
  --
  begin
    hr_contingent_worker_bk3.apply_for_job_b
      (p_effective_date                => l_effective_date
      ,p_person_id                     => p_person_id
      ,p_object_version_number         => p_object_version_number
      ,p_applicant_number              => p_applicant_number
      ,p_person_type_id                => p_person_type_id
      ,p_vacancy_id                    => p_vacancy_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'apply_for_job'
        ,p_hook_type   => 'BP'
        );
  end;
  hr_utility.set_location(l_proc, 20);
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Get derived details for person on effective date
  --
  OPEN csr_per_details
    (p_person_id                    => p_person_id
    ,p_effective_date               => p_effective_date
    );
  FETCH csr_per_details INTO l_per_details_rec;
  IF csr_per_details%NOTFOUND
  THEN
    CLOSE csr_per_details;
    fnd_message.set_name('PER','PER_289602_CWK_INV_PERSON_ID');
    fnd_message.raise_error;
  END IF;
  CLOSE csr_per_details;
  hr_utility.set_location(l_proc, 25);
  --
  -- Check for future person_type_changes
  --
  if hr_person.chk_future_person_type(l_per_details_rec.system_person_type
                                     ,p_person_id
                                     ,l_per_details_rec.business_group_id
                                     ,p_effective_date) then
    fnd_message.set_name('PAY','HR_7193_PER_FUT_TYPE_EXISTS');
    fnd_message.raise_error;
  end if;

  hr_utility.set_location(l_proc, 28);
  --
  -- Check against the existing person type records.
  --
  open csr_fut_apl(p_person_id,l_effective_date);
  fetch csr_fut_apl into l_dummy;
  if csr_fut_apl%found
   or not hr_general2.is_person_type(p_person_id
                               ,'CWK'
                               ,l_effective_date) then
    close csr_fut_apl;
    fnd_message.set_name('PER','PER_289603_CWK_INV_PERSON_TYPE');
    fnd_message.raise_error;
  else
    close csr_fut_apl;
  end if;
  hr_utility.set_location(l_proc, 30);
  --
  -- If the specified person type id is not null then check that it
  -- corresponds to type 'APL', is currently active and is in the correct
  -- business group, otherwise set person type to the active default for APL
  -- in the current business group.
  --
  per_per_bus.chk_person_type
    (p_person_type_id    => l_person_type_id
    ,p_business_group_id => l_per_details_rec.business_group_id
    ,p_expected_sys_type => 'APL'
    );
  hr_utility.set_location(l_proc, 40);
  --
  -- Ensure the applicant number will not be changed if it exists
  --
  IF l_per_details_rec.applicant_number IS NOT NULL
    AND NVL(p_applicant_number,hr_api.g_number) <> l_per_details_rec.applicant_number
  THEN
    hr_utility.set_location(l_proc,50);
     p_applicant_number := l_per_details_rec.applicant_number;
  END IF;
  --
  l_person_type_id1 :=  hr_person_type_usage_info.get_default_person_type_id
            (l_per_details_rec.business_group_id,
          'APL');
  --
  -- Process Logic
  --
  per_per_upd.upd
  (p_person_id                    => p_person_id
  ,p_effective_date               => l_effective_date
  ,p_datetrack_mode               => hr_api.g_update
  ,p_person_type_id               => l_person_type_id1
  ,p_applicant_number             => p_applicant_number
  ,p_employee_number              => l_per_details_rec.employee_number
  ,p_npw_number                   => l_per_details_rec.npw_number
  ,p_current_npw_flag             => 'Y'
  ,p_object_version_number        => p_object_version_number

  ,p_effective_start_date         => l_per_effective_start_date
  ,p_effective_end_date           => l_per_effective_end_date
  ,p_comment_id                   => l_comment_id
  ,p_current_applicant_flag       => l_current_applicant_flag
  ,p_current_emp_or_apl_flag      => l_current_emp_or_apl_flag
  ,p_current_employee_flag        => l_current_employee_flag
  ,p_full_name                    => l_full_name
  ,p_name_combination_warning     => l_name_combination_warning
  ,p_dob_null_warning             => l_dob_null_warning
  ,p_orig_hire_warning            => l_orig_hire_warning
  );
  hr_utility.set_location(l_proc, 60);
  --
  hr_security_internal.populate_new_person
       (p_business_group_id            => l_per_details_rec.business_group_id
       ,p_person_id                    => p_person_id
       );
  hr_utility.set_location(l_proc, 70);
  --
  -- Maintain PTU
  --
  hr_per_type_usage_internal.maintain_person_type_usage
  (p_effective_date       => l_effective_date
  ,p_person_id            => p_person_id
  ,p_person_type_id       => l_person_type_id
  );
  hr_utility.set_location(l_proc, 80);
  --
  -- create an application.
  --
  per_apl_ins.ins
    (p_application_id            => l_application_id
    ,p_business_group_id         => l_per_details_rec.business_group_id
    ,p_person_id                 => p_person_id
    ,p_date_received             => l_effective_date
    ,p_object_version_number     => l_apl_object_version_number
    ,p_effective_date            => l_effective_date
    );
  hr_utility.set_location(l_proc, 90);
  --
  hr_assignment_internal.create_default_apl_asg
     (p_effective_date               => l_effective_date
     ,p_person_id                    => p_person_id
     ,p_business_group_id            => l_per_details_rec.business_group_id
     ,p_application_id               => l_application_id
     ,p_assignment_id                => l_assignment_id
     ,p_object_version_number        => l_asg_object_version_number
     ,p_assignment_sequence          => l_assignment_sequence
     );
  hr_utility.set_location(l_proc, 100);
  --
  -- Call After Process User Hook
  --
  begin
    hr_contingent_worker_bk3.apply_for_job_a
      (p_effective_date                => l_effective_date
      ,p_person_id                     => p_person_id
      ,p_object_version_number         => p_object_version_number
      ,p_applicant_number              => p_applicant_number
      ,p_person_type_id                => l_person_type_id
      ,p_vacancy_id                    => p_vacancy_id
      ,p_per_effective_start_date      => l_per_effective_start_date
      ,p_per_effective_end_date        => l_per_effective_end_date
      ,p_application_id                => l_application_id
      ,p_apl_object_version_number     => l_apl_object_version_number
      ,p_assignment_id                 => l_assignment_id
      ,p_asg_object_version_number     => l_asg_object_version_number
      ,p_assignment_sequence           => l_assignment_sequence
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'apply_for_job'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_per_effective_start_date  := l_per_effective_start_date;
  p_per_effective_end_date    := l_per_effective_end_date;
  p_application_id            := l_application_id;
  p_apl_object_version_number := l_apl_object_version_number;
  p_assignment_id             := l_assignment_id;
  p_asg_object_version_number := l_asg_object_version_number;
  p_assignment_sequence       := l_assignment_sequence;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 170);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to apply_for_job;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number     := l_object_version_number;
    p_applicant_number          := l_applicant_number;
    p_per_effective_start_date  := null;
    p_per_effective_end_date    := null;
    p_application_id            := null;
    p_apl_object_version_number := null;
    p_assignment_id             := null;
    p_asg_object_version_number := null;
    p_assignment_sequence       := null;
    hr_utility.set_location(' Leaving:'||l_proc, 180);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to apply_for_job;
    --
    --
    -- set in out parameters and set out parameters
    --
    p_object_version_number     := l_object_version_number;
    p_applicant_number          := l_applicant_number;
    p_per_effective_start_date  := null;
    p_per_effective_end_date    := null;
    p_application_id            := null;
    p_apl_object_version_number := null;
    p_assignment_id             := null;
    p_asg_object_version_number := null;
    p_assignment_sequence       := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 190);
    raise;
end apply_for_job;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< pre_term_check >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure pre_term_check(p_status              IN OUT NOCOPY VARCHAR2
                        ,p_business_group_id   IN     NUMBER
                        ,p_person_id           IN     NUMBER
                        ,p_session_date        IN     DATE
         )is
--
--
v_dummy VARCHAR2(1);
l_proc varchar2(45) := g_package||'pre_term_check';
--
begin
   if p_status = 'SUPERVISOR' then
      begin
         hr_utility.set_location(l_proc,10);
         Select 'X'
         into v_dummy
         from   sys.dual
         where  exists (select 'Assignments Exist'
                        from   per_all_assignments_f paf
                        where  paf.supervisor_id     = p_person_id
                        and    paf.business_group_id = p_business_group_id
                        and    p_session_date between paf.effective_start_date
                                   and paf.effective_end_date);
         p_status := 'WARNING';
         return;
      exception
        when no_data_found then
          return;
      end;
   elsif p_status = 'EVENT' then
      begin
         hr_utility.set_location(l_proc,30);
         select 'X'
         into v_dummy
         from   sys.dual
         where  exists ( select 'Events exist'
                         from   per_events pe
                         ,      per_bookings pb
                         where  pe.business_group_id = pb.business_group_id
                         and    (pb.business_group_id = p_business_group_id OR
                      nvl(fnd_profile.value('HR_CROSS_BUSINESS_GROUP'),'N')='Y')
                         and    pe.event_id           = pb.event_id
                         and    pe.event_or_interview = 'E'
                         and    pb.person_id          = p_person_id
          and    pe.date_start         > p_session_date
                        );
         p_status := 'WARNING';
         return;
      exception
        when no_data_found then
          return;
      end;
   end if;
   if p_status = 'INTERVIEW' then
      begin
         hr_utility.set_location(l_proc,40);
         select 'X'
         into v_dummy
         from   sys.dual
         where  exists(select 'Interview rows exist'
                       from   per_events pe
                       where  pe.business_group_id          = p_business_group_id
                       and    pe.event_or_interview         = 'I'
                       and    pe.internal_contact_person_id = p_person_id
             and    pe.date_start                 > p_session_date
                      )
       OR
      exists(select 'Interview rows exist'
             from    per_events pe
                               ,per_bookings pb
                       where  pe.business_group_id = pb.business_group_id
                       and    (pb.business_group_id  = p_business_group_id OR
                       nvl(fnd_profile.value('HR_CROSS_BUSINESS_GROUP'),'N')='Y')
                       and    pe.event_id           = pb.event_id
                       and    pe.event_or_interview = 'I'
                       and    pb.person_id          = p_person_id
             and    pe.date_start         > p_session_date
                      );
         p_status := 'WARNING';
         return;
      exception
        when no_data_found then
          return;
      end;
   end if;
   if p_status = 'REVIEW' then
      begin
         hr_utility.set_location(l_proc,50);
         select 'X'
         into v_dummy
         from   sys.dual
         where  exists ( select 'Perf Review rows exist'
                      from   per_performance_reviews ppr
            where  ppr.person_id          = p_person_id
              and  review_date > p_session_date
                    );
         p_status := 'WARNING';
         return;
      exception
        when no_data_found then
          return;
      end;
   end if;
   if p_status = 'RECRUITER' then
      begin
         hr_utility.set_location(l_proc,60);
         select 'X'
         into v_dummy
         from   sys.dual
         where  exists (select 'Recruiter for vacancy'
                        from  per_vacancies pv
                        where
                          -- Fix for bug 3446782. This condition exists in the view.
                          /*(pv.business_group_id = p_business_group_id OR
                              nvl(fnd_profile.value('HR_CROSS_BUSINESS_GROUP'),'N')='Y')
                             and */
                          pv.recruiter_id         = p_person_id
             and   nvl(pv.date_to, p_session_date) >= p_session_date);
         p_status := 'WARNING';
         return;
      exception
        when no_data_found then
          return;
      end;
   end if;
end pre_term_check;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< actual_termination_placement >-------------------|
-- ----------------------------------------------------------------------------
--
procedure actual_termination_placement
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_person_id                    in     number
  ,p_date_start                   in     date
  ,p_object_version_number        in out nocopy number
  ,p_actual_termination_date      in     date
  ,p_last_standard_process_date   in out nocopy date
  ,p_person_type_id               in     number   default hr_api.g_number
  ,p_assignment_status_type_id    in     number   default hr_api.g_number
  ,p_termination_reason           in     varchar2 default hr_api.g_varchar2
  ,p_supervisor_warning              out nocopy boolean
  ,p_event_warning                   out nocopy boolean
  ,p_interview_warning               out nocopy boolean
  ,p_review_warning                  out nocopy boolean
  ,p_recruiter_warning               out nocopy boolean
  ,p_asg_future_changes_warning      out nocopy boolean
  ,p_entries_changed_warning         out nocopy varchar2
  ,p_pay_proposal_warning            out nocopy boolean
  ,p_dod_warning                     out nocopy boolean
  ) is
  --
  -- Declare cursors and local variables
  --
  -- Out variables
  --
  l_asg_future_changes_warning boolean     := FALSE;
  l_entries_changed_warning    varchar2(1) := 'N';
  l_event_warning              boolean     := FALSE;
  l_interview_warning          boolean     := FALSE;
  l_last_standard_process_date date;
  l_pdp_object_version_number  number;
  l_recruiter_warning          boolean     := FALSE;
  l_review_warning             boolean     := FALSE;
  l_supervisor_warning         boolean     := FALSE;
  l_dod_warning                boolean     := FALSE;
  --
  l_assignment_status_type_id  number;
  l_business_group_id          number;
  l_comment_id                 number;
  l_cr_asg_future_changes_warn boolean     := FALSE;
  l_cr_entries_changed_warn    varchar2(1) := 'N';
  l_pay_proposal_warn          boolean     := FALSE;
  l_current_npw_flag           varchar2(1);
  l_dob_null_warning           boolean;
  l_effective_date             date;
  l_effective_end_date         date;
  l_effective_start_date       date;
  l_npw_number                 per_people_f.npw_number%TYPE;
  l_exists                     varchar2(1);
  l_full_name                  per_all_people_f.full_name%TYPE;
  l_legislation_code           per_business_groups.legislation_code%TYPE;
  l_max_tpe_end_date           date;
  l_name_combination_warning   boolean;
  l_orig_hire_warning          boolean;
  l_per_object_version_number  number;
  l_per_system_status          per_assignment_status_types.per_system_status%TYPE;
  l_person_id                  number;
  l_date_start                 date;
  l_person_type_id             number;
  l_proc                       varchar2(72)
                                       := g_package ||
                                         'actual_termination_placement';
  l_system_person_type1        per_person_types.system_person_type%TYPE;
  l_per_effective_start_date   date;
  l_datetrack_mode             varchar2(30);
  l_validation_start_date      date;
  l_validation_end_date        date;
  l_actual_termination_date    date;
  l_status                     varchar2(11);
  l_current_dod                date;
  l_date_of_death              date;
  l_ptu_object_version_number  number;
  l_person_type_usage_id       number;
  l_applicant_number           per_all_people_f.applicant_number%TYPE;
  l_employee_number            per_all_people_f.employee_number%TYPE := hr_api.g_varchar2;
  l_current_applicant_flag     per_all_people_f.current_applicant_flag%TYPE;
  l_current_emp_or_apl_flag    per_all_people_f.current_emp_or_apl_flag%TYPE;
  l_current_employee_flag      per_all_people_f.current_employee_flag%TYPE;
  --

  cursor csr_future_per_changes is
    select null
      from per_all_people_f per
     where per.person_id            = l_person_id
       and per.effective_start_date > l_actual_termination_date;
  --
  cursor csr_get_asgs_to_terminate is
    select asg.assignment_id
         , asg.object_version_number
      from per_all_assignments_f asg
     where asg.person_id      = l_person_id
       and asg.period_of_placement_date_start     = l_date_start
       and l_actual_termination_date + 1 between asg.effective_start_date
                                         and     asg.effective_end_date
     order by asg.primary_flag;
  --
  cursor csr_get_derived_details is
    select bus.business_group_id
         , bus.legislation_code
         , per.person_id
         , per.effective_start_date
         , per.object_version_number
         , per.npw_number
         , per.applicant_number
      from per_all_people_f         per
         , per_business_groups      bus
         , per_periods_of_placement pdp
     where pdp.person_id = p_person_id
     and   pdp.date_start = p_date_start
     and   bus.business_group_id     = pdp.business_group_id
     and   per.person_id             = pdp.person_id
     and   l_actual_termination_date between per.effective_start_date
                                     and     per.effective_end_date;
  --
  cursor csr_get_max_tpe_end_date is
    select max(tpe.end_date)
    from   per_time_periods  tpe
          ,per_all_assignments_f asg
    where  asg.person_id = l_person_id
    and    asg.period_of_placement_date_start = l_date_start
    and    l_actual_termination_date between asg.effective_start_date
                                     and     asg.effective_end_date
    and    asg.payroll_id            is not null
    and    tpe.payroll_id            = asg.payroll_id
    and    l_actual_termination_date between tpe.start_date
                                     and     tpe.end_date;
  --
  cursor csr_date_of_death is
    select date_of_death
    from per_all_people_f
    where person_id = l_person_id;
  --
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Issue a savepoint.
  --
  savepoint actual_termination_placement;
  --
  -- Initialise local variables
  --
  l_person_type_id             := p_person_type_id;
  l_assignment_status_type_id  := p_assignment_status_type_id;
  l_last_standard_process_date := trunc(p_last_standard_process_date);
  l_pdp_object_version_number  := p_object_version_number;
  l_actual_termination_date    := trunc(p_actual_termination_date);
  l_effective_date             := trunc(p_effective_date);
  l_date_start                 := trunc(p_date_start);
  --
  hr_utility.set_location(l_proc, 10);
  --
  -- Validation in addition to Table Handlers
  --
  -- Check period of placement and get business group details for validation.
  --
  hr_api.mandatory_arg_error
     (p_api_name       => l_proc
     ,p_argument       => 'person_id'
     ,p_argument_value => p_person_id
     );
  --
  hr_api.mandatory_arg_error
     (p_api_name       => l_proc
     ,p_argument       => 'date_start'
     ,p_argument_value => p_date_start
     );
  --
  hr_api.mandatory_arg_error
     (p_api_name       => l_proc
     ,p_argument       => 'actual_termination_date'
     ,p_argument_value => l_actual_termination_date
     );
  --
  hr_utility.set_location(l_proc, 20);
  --
  open  csr_get_derived_details;
  fetch csr_get_derived_details
   into l_business_group_id
      , l_legislation_code
      , l_person_id
      , l_per_effective_start_date
      , l_per_object_version_number
      , l_npw_number
      , l_applicant_number;
  --
  if csr_get_derived_details%NOTFOUND
  then
    --
    hr_utility.set_location(l_proc, 30);
    --
    close csr_get_derived_details;
    --
    fnd_message.set_name('PER','HR_289609_PDP_NOT_EXISTS');
    fnd_message.raise_error;
  end if;
  --
  close csr_get_derived_details;

  hr_utility.set_location(l_proc, 40);
  --
  -- Check that the corresponding person has a person type usage of
  -- contingent worker at the actual termination date.
  --
  if not (hr_general2.is_person_type
           (p_person_id       => p_person_id
           ,p_person_type     => 'CWK'
           ,p_effective_date  => l_actual_termination_date))
  then

    hr_utility.set_location(l_proc, 50);

    fnd_message.set_name('PER','HR_289612_PDP_NOT_PTU_CWK');
    fnd_message.raise_error;

  end if;

  hr_utility.set_location(l_proc, 60);

  --
  -- Check that there are not any future changes to the person.
  --
  open  csr_future_per_changes;
  fetch csr_future_per_changes
   into l_exists;
  --
  if csr_future_per_changes%FOUND
  then
    --
    hr_utility.set_location(l_proc, 70);
    --
    close csr_future_per_changes;
    --
    fnd_message.set_name('PAY','HR_7957_PDS_INV_ATT_FUTURE');
    fnd_message.raise_error;
  end if;
  --
  hr_utility.set_location(l_proc, 80);
  --
  close csr_future_per_changes;

  --
  -- if p_person_type_id is entered, is should be of an ex-
  -- contingent worker person type.  l_person_type_id is
  -- passed because it is an IN OUT parameter and is populated
  -- with the default person_type_id if it was null.
  --
  per_per_bus.chk_person_type
      (p_person_type_id    => l_person_type_id
      ,p_business_group_id => l_business_group_id
      ,p_expected_sys_type => 'EX_CWK'
      );
  --
  hr_utility.set_location(l_proc, 90);
  hr_utility.trace('l_assignment_status_type_id: '||
                    to_char(l_assignment_status_type_id));
  hr_utility.trace('l_business_group_id: '||
                    to_char(l_business_group_id));
  hr_utility.trace('l_legislation_code: '||l_legislation_code);


  --
  -- If l_assignment_status_type_id is g_number then derive it's
  -- default value, otherwise validate it (the parameter is an
  -- IN OUT).
  --
  -- For CWK Phase I we bypass this check because we are not
  -- changing the assignment status to 'terminated'.
  --
/*
  per_asg_bus1.chk_assignment_status_type
    (p_assignment_status_type_id => l_assignment_status_type_id
    ,p_business_group_id         => l_business_group_id
    ,p_legislation_code          => l_legislation_code
    ,p_expected_system_status    => 'TERM_CWK_ASG'
    );
*/
  --
  hr_utility.set_location(l_proc, 100);
  --
  -- Validate/derive the last standard process date.
  --
  --
  hr_utility.set_location(l_proc, 130);
  --
  if l_last_standard_process_date is not null
  then
      --
      hr_utility.set_location(l_proc, 140);
      --
      -- Check that the last standard process date is on or after the actual
      -- termination date.
      --
      if not l_last_standard_process_date >= l_actual_termination_date
      then
        --
        hr_utility.set_location(l_proc, 150);
        --
        fnd_message.set_name('PAY','HR_7505_PDS_INV_LSP_ATT_DT');
        fnd_message.raise_error;
      end if;
  else
      --
      hr_utility.set_location(l_proc, 160);
      --
      -- Last standard process date is null => derive it.
      --
      -- Find the max tpe end date of any payrolls that are assigned.
      --
      open  csr_get_max_tpe_end_date;
      fetch csr_get_max_tpe_end_date
       into l_max_tpe_end_date;
      --
      if csr_get_max_tpe_end_date%NOTFOUND
      then
        --
        hr_utility.set_location(l_proc, 170);
        --
        close csr_get_max_tpe_end_date;
        --
        -- As the cursor should always return at least a null value, this
        -- should never happen!
        --
        fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
        fnd_message.set_token('PROCEDURE', l_proc);
        fnd_message.set_token('STEP','175');
        fnd_message.raise_error;
      end if;
      --
      close csr_get_max_tpe_end_date;
      --
      hr_utility.set_location(l_proc, 180);
      --
      if l_max_tpe_end_date is not null
      then
        --
        hr_utility.set_location(l_proc, 190);
        --
        -- A time period end date has been found, so set the last standard
        -- process date to that.
        --
        l_last_standard_process_date := l_max_tpe_end_date;
      else
        --
        hr_utility.set_location(l_proc, 200);
        --
        -- Either there was not an assignment assigned to a payroll, or
        -- there was no time period for that payroll as of the actual
        -- termination date. It doesn't matter which as we will default
   -- the LSPD to the ATD.
        --
        l_last_standard_process_date := l_actual_termination_date;
      end if;
  end if;
  --
  hr_utility.set_location(l_proc, 240);
  --
  -- Lock the person record in PER_PEOPLE_F ready for UPDATE at a later point.
  -- (Note: This is necessary because calling the table handlers in locking
  --        ladder order invokes an error in per_pdp_upd.upd due to the person
  --        being modified by the per_per_upd.upd table handler.)
  --
  l_datetrack_mode     := 'UPDATE';
  --
  per_per_shd.lck
    (p_effective_date                 => l_actual_termination_date + 1
    ,p_datetrack_mode                 => l_datetrack_mode
    ,p_person_id                      => l_person_id
    ,p_object_version_number          => l_per_object_version_number
    ,p_validation_start_date          => l_validation_start_date
    ,p_validation_end_date            => l_validation_end_date
    );

hr_utility.set_location(l_proc, 245);
  --
  -- Update actual termination date and last standard process date in
  -- periods of placement table.

  per_pdp_upd.upd
    (p_effective_date             => p_actual_termination_date + 1
    ,p_object_version_number      => l_pdp_object_version_number
    ,p_person_id                  => l_person_id
    ,p_date_start                 => l_date_start
    ,p_actual_termination_date    => l_actual_termination_date
    ,p_last_standard_process_date => l_last_standard_process_date
    ,p_termination_reason         => p_termination_reason);

--
  if p_termination_reason = 'D' then
    open csr_date_of_death;
    fetch csr_date_of_death into l_current_dod;
    if l_current_dod is null then
      l_date_of_death := p_actual_termination_date;
      l_dod_warning := TRUE;
    else
      l_date_of_death := l_current_dod;
    end if;
    close csr_date_of_death;
  end if;
--
if l_dod_warning = TRUE then
  hr_utility.set_location(l_proc, 998);
else
  hr_utility.set_location(l_proc,999);
end if;
--
  -- Update person type in person table.
  --
  hr_utility.set_location(l_proc, 250);
  per_per_upd.upd
    (p_person_id                => l_person_id
    ,p_effective_start_date     => l_effective_start_date
    ,p_effective_end_date       => l_effective_end_date
    ,p_comment_id               => l_comment_id
    ,p_current_npw_flag         => l_current_npw_flag
    ,p_npw_number               => l_npw_number
    ,p_applicant_number         => l_applicant_number
    ,p_employee_number          => l_employee_number
    ,p_current_applicant_flag   => l_current_applicant_flag
    ,p_current_emp_or_apl_flag  => l_current_emp_or_apl_flag
    ,p_current_employee_flag    => l_current_employee_flag
    ,p_full_name                => l_full_name
    ,p_object_version_number    => l_per_object_version_number
    ,p_effective_date           => l_actual_termination_date + 1
    ,p_datetrack_mode           => 'UPDATE'
    ,p_date_of_death            => l_date_of_death
    ,p_validate                 => p_validate
    ,p_name_combination_warning => l_name_combination_warning
    ,p_dob_null_warning         => l_dob_null_warning
    ,p_orig_hire_warning        => l_orig_hire_warning
    );
  --
  hr_utility.set_location(l_proc, 260);
  --
  -- Terminate the assignments, ensuring that the non-primaries are
  -- processed before the primary (implemented via 'order by primary_flag'
  -- clause in cursor declaration).
  --
  for csr_rec in csr_get_asgs_to_terminate
  loop
    --
    hr_utility.set_location(l_proc, 270);
    --
    hr_assignment_internal.actual_term_cwk_asg
      (p_assignment_id              => csr_rec.assignment_id
      ,p_object_version_number      => csr_rec.object_version_number
      ,p_actual_termination_date    => l_actual_termination_date
      ,p_last_standard_process_date => l_last_standard_process_date
      ,p_assignment_status_type_id  => l_assignment_status_type_id
      ,p_effective_start_date       => l_effective_start_date
      ,p_effective_end_date         => l_effective_end_date
      ,p_asg_future_changes_warning => l_cr_asg_future_changes_warn
      ,p_entries_changed_warning    => l_cr_entries_changed_warn
      ,p_pay_proposal_warning       => l_pay_proposal_warn
      );
    --
    hr_utility.set_location(l_proc, 280);
    --
    -- Set entries changed warning using the precedence of 'S', then 'Y', then
    -- 'N'.
    --
    if l_cr_entries_changed_warn = 'S' or
       l_entries_changed_warning = 'S' then
      --
      hr_utility.set_location(l_proc, 290);
      --
       l_entries_changed_warning := 'S';
      --
    elsif l_cr_entries_changed_warn = 'Y' or
        l_entries_changed_warning = 'Y' then
      --
      hr_utility.set_location(l_proc, 300);
      --
      l_entries_changed_warning := 'Y';

    else
      --
      hr_utility.set_location(l_proc, 305);
      --
      l_entries_changed_warning := 'N';

    end if;
    --
    hr_utility.set_location(l_proc, 310);
    --
    -- Set future changes warning.
    --
    if l_cr_asg_future_changes_warn or l_asg_future_changes_warning
    then
      --
      hr_utility.set_location(l_proc, 320);
      --
      l_asg_future_changes_warning := TRUE;

    end if;

  end loop;
  --
  hr_utility.set_location(l_proc, 330);
  --
  -- Added code to support the following Out warning parameters.
  --
  l_status := 'SUPERVISOR';
  pre_term_check(l_status,
       l_business_group_id,
       l_person_id,
       l_actual_termination_date);
  if l_status = 'WARNING' then
    p_supervisor_warning := TRUE;
  else
    p_supervisor_warning := FALSE;
  end if;
  --
  l_status := 'EVENT';
  pre_term_check(l_status,
       l_business_group_id,
       l_person_id,
       l_actual_termination_date);
  if l_status = 'WARNING' then
    p_event_warning := TRUE;
  else
    p_event_warning := FALSE;
  end if;
  --
  l_status := 'INTERVIEW';
  pre_term_check(l_status,
       l_business_group_id,
       l_person_id,
       l_actual_termination_date);
  if l_status = 'WARNING' then
    p_interview_warning := TRUE;
  else
    p_interview_warning := FALSE;
  end if;
  --
  l_status := 'REVIEW';
  pre_term_check(l_status,
       l_business_group_id,
       l_person_id,
       l_actual_termination_date);
  if l_status = 'WARNING' then
    p_review_warning := TRUE;
  else
    p_review_warning := FALSE;
  end if;
  --
  l_status := 'RECRUITER';
  pre_term_check(l_status,
       l_business_group_id,
       l_person_id,
       l_actual_termination_date);
  if l_status = 'WARNING' then
    p_recruiter_warning := TRUE;
  else
    p_recruiter_warning := FALSE;
  end if;
  --

  --
  -- Make the PTU changes for terminating a contingent worker.
  -- l_person_type_id holds validated flavour of EX_EMP

  hr_per_type_usage_internal.maintain_person_type_usage
       (p_effective_date        =>  p_actual_termination_date +1
       ,p_person_id             => l_person_id
       ,p_person_type_id        => l_person_type_id
       ,p_datetrack_update_mode => 'UPDATE'
       );
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_asg_future_changes_warning := l_asg_future_changes_warning;
  p_entries_changed_warning    := l_entries_changed_warning;
  p_pay_proposal_warning       := l_pay_proposal_warn;
  p_dod_warning                := l_dod_warning;
  p_last_standard_process_date := l_last_standard_process_date;
  p_object_version_number      := l_pdp_object_version_number;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 340);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO actual_termination_placement;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_asg_future_changes_warning := l_asg_future_changes_warning;
    p_entries_changed_warning    := l_entries_changed_warning;
    p_pay_proposal_warning       := l_pay_proposal_warn;
    p_dod_warning                := l_dod_warning;
    --
    -- p_object_version_number and p_last_standard_process_date
    -- should return their IN values, they still hold their IN values
    -- so do nothing here.
    --
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    ROLLBACK TO actual_termination_placement;
    --
    -- set in out parameters and set out parameters
    --
  p_object_version_number  := l_pdp_object_version_number;
 p_last_standard_process_date   := l_last_standard_process_date;
  p_supervisor_warning          := null;
  p_event_warning               := null;
  p_interview_warning           := null;
  p_review_warning              := null;
  p_recruiter_warning           := null;
  p_asg_future_changes_warning  := null;
  p_entries_changed_warning     := null;
  p_pay_proposal_warning        := null;
  p_dod_warning                 := null;

    raise;
    --
    -- End of fix.
    --
end actual_termination_placement;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< final_process_placement >----------------------|
-- ----------------------------------------------------------------------------
--
procedure final_process_placement
  (p_validate                     in     boolean  default false
  ,p_person_id                    in     number
  ,p_date_start                   in     date
  ,p_object_version_number        in out nocopy number
  ,p_final_process_date           in out nocopy date
  ,p_org_now_no_manager_warning      out nocopy boolean
  ,p_asg_future_changes_warning      out nocopy boolean
  ,p_entries_changed_warning         out nocopy varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  -- Out variables
  --
  l_asg_future_changes_warning boolean     := FALSE;
  l_entries_changed_warning    varchar2(1) := 'N';
  l_final_process_date         date;
  l_org_now_no_manager_warning boolean     := FALSE;
  l_pdp_object_version_number  number;
  --
  l_actual_termination_date    date;
  l_cr_asg_future_changes_warn boolean     := FALSE;
  l_cr_entries_changed_warn    varchar2(1) := 'N';
  l_cr_org_now_no_manager_warn boolean     := FALSE;
  l_effective_end_date         date;
  l_effective_start_date       date;
  l_exists                     varchar2(1);
  l_last_standard_process_date date;
  l_legislation_code           per_business_groups.legislation_code%TYPE;
  l_object_version_number      number;
  l_person_id                  number;
  l_proc                       varchar2(72) := g_package ||
                                            'final_process_placement';
  l_exemppet_eff_date          date;
  --
  cursor csr_get_derived_details is
    select bus.legislation_code
         , pdp.actual_termination_date
         , pdp.last_standard_process_date
         , pdp.person_id
    , pdp.object_version_number
      from per_business_groups    bus
         , per_periods_of_placement pdp
     where pdp.person_id = p_person_id
     and   pdp.date_start = p_date_start
     and   bus.business_group_id    = pdp.business_group_id;
  --
  cursor csr_get_asgs_to_final_proc is
    select asg.assignment_id
         , asg.object_version_number
         , asg.primary_flag
      from per_all_assignments_f asg
     where asg.person_id = p_person_id
       and asg.period_of_placement_date_start = p_date_start
       and l_final_process_date     between asg.effective_start_date
                                    and     asg.effective_end_date
     order by asg.primary_flag;
  --

begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  l_final_process_date          := trunc(p_final_process_date);
  --
  -- Issue a savepoint.
  --
  savepoint final_process_placement;

  hr_utility.set_location(l_proc, 10);
  --
  -- Validation in addition to Table Handlers
  --
  -- Check person id.
  --
  hr_api.mandatory_arg_error
     (p_api_name       => l_proc
     ,p_argument       => 'person_id'
     ,p_argument_value => p_person_id
     );
  --
  -- Check date start.
  --
  hr_api.mandatory_arg_error
     (p_api_name       => l_proc
     ,p_argument       => 'date_start'
     ,p_argument_value => p_date_start
     );
  --
  -- Check object version number.
  --
  hr_api.mandatory_arg_error
     (p_api_name       => l_proc
     ,p_argument       => 'object_version_number'
     ,p_argument_value => p_object_version_number
     );
  --
  hr_utility.set_location(l_proc, 20);
  --
  open  csr_get_derived_details;
  fetch csr_get_derived_details
   into l_legislation_code
       ,l_actual_termination_date
       ,l_last_standard_process_date
       ,l_person_id
       ,l_object_version_number;
  --
  if csr_get_derived_details%NOTFOUND
  then
    --
    hr_utility.set_location(l_proc, 30);
    --
    close csr_get_derived_details;
    --
    fnd_message.set_name('PER','HR_289609_PDP_NOT_EXISTS');
    fnd_message.raise_error;
  end if;
  --
  close csr_get_derived_details;
  --
  -- Validate the derived OVN with passed OVN.

  if  l_object_version_number <> p_object_version_number
  then

    fnd_message.set_name('PAY','HR_7155_OBJECT_INVALID');
    fnd_message.raise_error;
  end if;

  hr_utility.set_location(l_proc, 40);
  --
  -- Check that the actual termination date has already been set.
  --
  if l_actual_termination_date is null
  then
    --
    hr_utility.set_location(l_proc, 50);
    --
    fnd_message.set_name('PAY','HR_51007_ASG_INV_NOT_ACT_TERM');
    fnd_message.raise_error;
  end if;
  --
  -- Check if the final process date is set
  --
  if l_legislation_code = 'US'
    and p_final_process_date is null
  then
    --
    -- Default the FPD to the LSPD
    --
    l_final_process_date := l_actual_termination_date;
    --
    -- Add one day to the last standard process date to get the
    -- validation date
    --
    -- Set the EX CWK effective date to the FPD + 1
    --
    --   Note: Since the FPD equals the ATD then the cwk
    --         has not been Ex CWK for at least one day
    --
    l_exemppet_eff_date := l_final_process_date+1;
    --
  elsif p_final_process_date is null
  then
    --
    -- Default the FPD to the LSPD
    --
    l_final_process_date := l_last_standard_process_date;
    --
    -- Add one day to the last standard process date to get the
    -- validation date
    --
    -- Set the EX CWK effective date to the FPD + 1
    --
    --   Note: Since the FPD equals the LSPD then the cwk
    --         has not been Ex CWK for at least one day
    --
    l_exemppet_eff_date := l_final_process_date+1;
    --
  elsif p_final_process_date = l_actual_termination_date then
    --
    l_final_process_date := p_final_process_date;
    --
    -- Set the EX CWK effective date to the FPD + 1
    --
    --   Note: Since the FPD equals the ATD then the cwk
    --         has not been Ex CWK for at least one day
    --
    l_exemppet_eff_date := p_final_process_date+1;
    --
  else
    --
    l_final_process_date := p_final_process_date;
    --
    l_exemppet_eff_date := p_final_process_date;
    --
  end if;
  --
  hr_utility.set_location(l_proc, 90);
  --
  -- Check that the corresponding person is of EX_CWK system person type.
  --
  if not (hr_general2.is_person_type
           (p_person_id       => p_person_id
           ,p_person_type     => 'EX_CWK'
           ,p_effective_date  => l_exemppet_eff_date))
  then
    --
    hr_utility.set_location(l_proc, 100);
    --
    fnd_message.set_name('PER','HR_289613_PDP_NOT_PTU_EX_CWK');
    fnd_message.raise_error;
    --
  end if;
  --
  hr_utility.set_location(l_proc, 110);
  --
  --
  -- Check that there are no COBRA benefits after the final process date.
  --
  -- Not implemented yet due to outstanding issues.
  --
  -- Update final process date in periods of placement table.
  --
  per_pdp_upd.upd
    (p_person_id                  => p_person_id
    ,p_date_start                 => p_date_start
    ,p_final_process_date         => l_final_process_date
    ,p_object_version_number      => l_object_version_number
    ,p_effective_date             => l_final_process_date
    );

  --
  hr_utility.set_location(l_proc, 120);
  --
  -- Final process the assignments, ensuring that the non-primaries are
  -- processed before the primary (implemented via 'order by primary_flag'
  -- clause in cursor declaration).
  --
  for csr_rec in csr_get_asgs_to_final_proc
  loop
    --
    hr_utility.set_location(l_proc, 130);
    --
    hr_assignment_internal.final_process_cwk_asg
      (p_assignment_id              => csr_rec.assignment_id
      ,p_object_version_number      => csr_rec.object_version_number
      ,p_actual_termination_date    => l_actual_termination_date
      ,p_final_process_date         => l_final_process_date
      ,p_effective_start_date       => l_effective_start_date
      ,p_effective_end_date         => l_effective_end_date
      ,p_org_now_no_manager_warning => l_cr_org_now_no_manager_warn
      ,p_asg_future_changes_warning => l_cr_asg_future_changes_warn
      ,p_entries_changed_warning    => l_cr_entries_changed_warn
      );
    --
    hr_utility.set_location(l_proc, 140);
    --
    -- Set entries changed warning using the precedence of 'S', then 'Y', then
    -- 'N'.
    --
    if l_cr_entries_changed_warn = 'S'
       or l_entries_changed_warning = 'S'
    then
      --
      hr_utility.set_location(l_proc, 150);
      --
      l_entries_changed_warning := 'S';
      --
    elsif l_cr_entries_changed_warn = 'Y'
     or  l_entries_changed_warning = 'Y'
    then
      --
      hr_utility.set_location(l_proc, 160);
      --
      l_entries_changed_warning := 'Y';
      --
     else
      --
      hr_utility.set_location(l_proc, 165);
      --
      l_entries_changed_warning := 'N';
      --
    end if;
    --
    hr_utility.set_location(l_proc, 170);
    --
    -- Set future changes warning.
    --
    if l_cr_asg_future_changes_warn
    then
      --
      hr_utility.set_location(l_proc, 180);
      --
      l_asg_future_changes_warning := TRUE;
    end if;
    --
    -- Set org now no manager warning.
    --
    if l_cr_org_now_no_manager_warn
    then
      --
      hr_utility.set_location(l_proc, 190);
      --
      l_org_now_no_manager_warning := TRUE;
    end if;
  end loop;

  hr_utility.set_location(l_proc, 200);

  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_asg_future_changes_warning := l_asg_future_changes_warning;
  p_entries_changed_warning    := l_entries_changed_warning;
  p_final_process_date         := l_final_process_date;
  p_object_version_number      := l_object_version_number;
  p_org_now_no_manager_warning := l_org_now_no_manager_warning;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 400);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO final_process_placement;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_asg_future_changes_warning := l_asg_future_changes_warning;
    p_entries_changed_warning    := l_entries_changed_warning;
    p_org_now_no_manager_warning := l_org_now_no_manager_warning;
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    ROLLBACK TO final_process_placement;
    --
    -- set in out parameters and set out parameters
    --
 p_object_version_number      := l_object_version_number;
 p_final_process_date         := l_final_process_date;
 p_org_now_no_manager_warning := l_org_now_no_manager_warning;
 p_asg_future_changes_warning := l_asg_future_changes_warning;
 p_entries_changed_warning    := null;
    --
    raise;
    --
end final_process_placement;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< terminate_placement >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure terminate_placement
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_person_id                     in     number
  ,p_date_start                    in     date
  ,p_object_version_number         in out nocopy number
  ,p_person_type_id                in     number   default hr_api.g_number
  ,p_assignment_status_type_id     in     number   default hr_api.g_number
  ,p_actual_termination_date       in     date     default hr_api.g_date

/*
   The following two parameters are available for internal-use only until
   payroll support for contingent workers is introduced. Setting them has
   no impact.
*/
  ,p_final_process_date            in out nocopy date
  ,p_last_standard_process_date    in out nocopy date

  ,p_termination_reason            in     varchar2 default hr_api.g_varchar2
  ,p_projected_termination_date    in     date     default hr_api.g_date
  ,p_attribute_category            in     varchar2 default hr_api.g_varchar2
  ,p_attribute1                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute2                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute3                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute4                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute5                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute6                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute7                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute8                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute9                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute10                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute11                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute12                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute13                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute14                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute15                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute16                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute17                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute18                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute19                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute20                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute21                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute22                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute23                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute24                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute25                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute26                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute27                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute28                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute29                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute30                   in     varchar2 default hr_api.g_varchar2
  ,p_information_category          in     varchar2 default hr_api.g_varchar2
  ,p_information1                  in     varchar2 default hr_api.g_varchar2
  ,p_information2                  in     varchar2 default hr_api.g_varchar2
  ,p_information3                  in     varchar2 default hr_api.g_varchar2
  ,p_information4                  in     varchar2 default hr_api.g_varchar2
  ,p_information5                  in     varchar2 default hr_api.g_varchar2
  ,p_information6                  in     varchar2 default hr_api.g_varchar2
  ,p_information7                  in     varchar2 default hr_api.g_varchar2
  ,p_information8                  in     varchar2 default hr_api.g_varchar2
  ,p_information9                  in     varchar2 default hr_api.g_varchar2
  ,p_information10                 in     varchar2 default hr_api.g_varchar2
  ,p_information11                 in     varchar2 default hr_api.g_varchar2
  ,p_information12                 in     varchar2 default hr_api.g_varchar2
  ,p_information13                 in     varchar2 default hr_api.g_varchar2
  ,p_information14                 in     varchar2 default hr_api.g_varchar2
  ,p_information15                 in     varchar2 default hr_api.g_varchar2
  ,p_information16                 in     varchar2 default hr_api.g_varchar2
  ,p_information17                 in     varchar2 default hr_api.g_varchar2
  ,p_information18                 in     varchar2 default hr_api.g_varchar2
  ,p_information19                 in     varchar2 default hr_api.g_varchar2
  ,p_information20                 in     varchar2 default hr_api.g_varchar2
  ,p_information21                 in     varchar2 default hr_api.g_varchar2
  ,p_information22                 in     varchar2 default hr_api.g_varchar2
  ,p_information23                 in     varchar2 default hr_api.g_varchar2
  ,p_information24                 in     varchar2 default hr_api.g_varchar2
  ,p_information25                 in     varchar2 default hr_api.g_varchar2
  ,p_information26                 in     varchar2 default hr_api.g_varchar2
  ,p_information27                 in     varchar2 default hr_api.g_varchar2
  ,p_information28                 in     varchar2 default hr_api.g_varchar2
  ,p_information29                 in     varchar2 default hr_api.g_varchar2
  ,p_information30                 in     varchar2 default hr_api.g_varchar2
  ,p_supervisor_warning               out nocopy boolean
  ,p_event_warning                    out nocopy boolean
  ,p_interview_warning                out nocopy boolean
  ,p_review_warning                   out nocopy boolean
  ,p_recruiter_warning                out nocopy boolean
  ,p_asg_future_changes_warning       out nocopy boolean
  ,p_entries_changed_warning          out nocopy varchar2
  ,p_pay_proposal_warning             out nocopy boolean
  ,p_dod_warning                      out nocopy boolean
  ,p_org_now_no_manager_warning       out nocopy boolean
  ,p_addl_rights_warning              out nocopy boolean -- Fix 1370960
  ) is

l_proc varchar2(80) := g_package||'terminate_placement';
l_curr_actual_termination_date    date;
l_curr_final_process_date         date;
l_final_process_date              date;
dummy                             number := 0; -- fix 1370960

cursor csr_get_pdp_details is
    select actual_termination_date
          ,final_process_date
      from per_periods_of_placement
     where person_id  = p_person_id
     and   date_start = p_date_start;

-- fix 1370960
cursor csr_roles_to_terminate is
  select
    role_id
  , object_version_number
  , end_date
  from per_roles
  where person_id = p_person_id
  and p_actual_termination_date
  between start_date
  and nvl(end_date, hr_api.g_eot);

cursor csr_chk_addl_rights is
  select role_id
  from per_roles
  where person_id = p_person_id
  and EMP_RIGHTS_FLAG = 'Y'
  and nvl(end_of_rights_date, hr_api.g_eot) > p_actual_termination_date;
-- end fix 1370960

begin

  hr_utility.set_location('Entering: '||l_proc, 10);

  --
  -- Issue a savepoint
  --
  savepoint terminate_placement;

  hr_utility.set_location(l_proc, 15);

  /* For CWK Phase I we default the final process
     and last standard process date to the actual
     termination date so that assignments are immediately
     ended.
     For CWK Phase II, this defaulting will be removed
     so that the behaviour supports CWKs on payrolls. */

--  l_final_process_date := p_final_process_date;
  l_final_process_date := p_actual_termination_date;
  p_last_standard_process_date := p_actual_termination_date;

  --
  -- Start of API User Hook for the before hook of terminate_placement
  --
  begin
     hr_contingent_worker_bk4.terminate_placement_b
       (p_effective_date                => p_effective_date
       ,p_person_id                     => p_person_id
       ,p_date_start                    => p_date_start
       ,p_object_version_number         => p_object_version_number
       ,p_person_type_id                => p_person_type_id
       ,p_assignment_status_type_id     => p_assignment_status_type_id
       ,p_actual_termination_date       => p_actual_termination_date
       ,p_final_process_date            => l_final_process_date
       ,p_last_standard_process_date    => p_last_standard_process_date
       ,p_termination_reason            => p_termination_reason
       ,p_projected_termination_date    => null
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
       ,p_information_category          => p_information_category
       ,p_information1                  => p_information1
       ,p_information2                  => p_information2
       ,p_information3                  => p_information3
       ,p_information4                  => p_information4
       ,p_information5                  => p_information5
       ,p_information6                  => p_information6
       ,p_information7                  => p_information7
       ,p_information8                  => p_information8
       ,p_information9                  => p_information9
       ,p_information10                 => p_information10
       ,p_information11                 => p_information11
       ,p_information12                 => p_information12
       ,p_information13                 => p_information13
       ,p_information14                 => p_information14
       ,p_information15                 => p_information15
       ,p_information16                 => p_information16
       ,p_information17                 => p_information17
       ,p_information18                 => p_information18
       ,p_information19                 => p_information19
       ,p_information20                 => p_information20
       ,p_information21                 => p_information21
       ,p_information22                 => p_information22
       ,p_information23                 => p_information23
       ,p_information24                 => p_information24
       ,p_information25                 => p_information25
       ,p_information26                 => p_information26
       ,p_information27                 => p_information27
       ,p_information28                 => p_information28
       ,p_information29                 => p_information29
       ,p_information30                 => p_information30
       );
  exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'TERMINATE_PLACEMENT',
          p_hook_type         => 'BP'
         );
  end;
  --
  -- End of API User Hook for the before hook of actual_termination
  --
  hr_utility.set_location(l_proc, 20);

  /*
  ** We need to get the details currently on the PDP record so that
  ** we know if the person has already been partially or fully terminated.
  ** If partial termination (ATD set but FPD not set) then don't call
  ** actual_termination_emp API. If full termination (ATD and FPD both set)
  ** then don't call either termination API and just update the details.
  */
  open  csr_get_pdp_details;
  fetch csr_get_pdp_details
   into l_curr_actual_termination_date
       ,l_curr_final_process_date;
  close csr_get_pdp_details;

  hr_utility.set_location(l_proc, 30);

  /*
  ** Save the non-termination related PDP information....
  */
  hr_periods_of_placement_api.update_pdp_details
     (p_validate                    => FALSE
     ,p_effective_date              => p_effective_date
     ,p_object_version_number       => p_object_version_number
     ,p_person_id                   => p_person_id
     ,p_date_start                  => p_date_start
     ,p_termination_reason          => p_termination_reason
     ,p_projected_termination_date  => null
     ,p_attribute_category          => p_attribute_category
     ,p_attribute1                  => p_attribute1
     ,p_attribute2                  => p_attribute2
     ,p_attribute3                  => p_attribute3
     ,p_attribute4                  => p_attribute4
     ,p_attribute5                  => p_attribute5
     ,p_attribute6                  => p_attribute6
     ,p_attribute7                  => p_attribute7
     ,p_attribute8                  => p_attribute8
     ,p_attribute9                  => p_attribute9
     ,p_attribute10                 => p_attribute10
     ,p_attribute11                 => p_attribute11
     ,p_attribute12                 => p_attribute12
     ,p_attribute13                 => p_attribute13
     ,p_attribute14                 => p_attribute14
     ,p_attribute15                 => p_attribute15
     ,p_attribute16                 => p_attribute16
     ,p_attribute17                 => p_attribute17
     ,p_attribute18                 => p_attribute18
     ,p_attribute19                 => p_attribute19
     ,p_attribute20                 => p_attribute20
     ,p_attribute21                 => p_attribute21
     ,p_attribute22                 => p_attribute22
     ,p_attribute23                 => p_attribute23
     ,p_attribute24                 => p_attribute24
     ,p_attribute25                 => p_attribute25
     ,p_attribute26                 => p_attribute26
     ,p_attribute27                 => p_attribute27
     ,p_attribute28                 => p_attribute28
     ,p_attribute29                 => p_attribute29
     ,p_attribute30                 => p_attribute30
     ,p_information_category        => p_information_category
     ,p_information1                => p_information1
     ,p_information2                => p_information2
     ,p_information3                => p_information3
     ,p_information4                => p_information4
     ,p_information5                => p_information5
     ,p_information6                => p_information6
     ,p_information7                => p_information7
     ,p_information8                => p_information8
     ,p_information9                => p_information9
     ,p_information10               => p_information10
     ,p_information11               => p_information11
     ,p_information12               => p_information12
     ,p_information13               => p_information13
     ,p_information14               => p_information14
     ,p_information15               => p_information15
     ,p_information16               => p_information16
     ,p_information17               => p_information17
     ,p_information18               => p_information18
     ,p_information19               => p_information19
     ,p_information20               => p_information20
     ,p_information21               => p_information21
     ,p_information22               => p_information22
     ,p_information23               => p_information23
     ,p_information24               => p_information24
     ,p_information25               => p_information25
     ,p_information26               => p_information26
     ,p_information27               => p_information27
     ,p_information28               => p_information28
     ,p_information29               => p_information29
     ,p_information30               => p_information30
  );

  hr_utility.set_location(l_proc, 40);

  /*
  ** Process actual termination date if it's set for the first time....
  */
  if     l_curr_actual_termination_date is null
     and p_actual_termination_date is not null
  then

    hr_utility.set_location(l_proc, 50);

    hr_contingent_worker_api.actual_termination_placement
       (p_validate                   => FALSE
       ,p_effective_date             => p_effective_date
       ,p_person_id                  => p_person_id
       ,p_date_start                 => p_date_start
       ,p_object_version_number      => p_object_version_number
       ,p_actual_termination_date    => p_actual_termination_date
       ,p_last_standard_process_date => p_last_standard_process_date
       ,p_person_type_id             => p_person_type_id
       ,p_assignment_status_type_id  => p_assignment_status_type_id
       ,p_termination_reason         => p_termination_reason
       ,p_supervisor_warning         => p_supervisor_warning
       ,p_event_warning              => p_event_warning
       ,p_interview_warning          => p_interview_warning
       ,p_review_warning             => p_review_warning
       ,p_recruiter_warning          => p_recruiter_warning
       ,p_asg_future_changes_warning => p_asg_future_changes_warning
       ,p_entries_changed_warning    => p_entries_changed_warning
       ,p_pay_proposal_warning       => p_pay_proposal_warning
       ,p_dod_warning                => p_dod_warning
       );

      -- fix 1370960
      -- Terminate the roles
      for roles_rec in csr_roles_to_terminate
      loop
        per_supplementary_role_api.update_supplementary_role(
        p_effective_date                => p_effective_date
        ,p_role_id                      => roles_rec.role_id
        ,p_object_version_number        => roles_rec.object_version_number
        ,p_end_date                     => p_actual_termination_date
        ,p_old_end_date                 => roles_rec.end_date
        );
      end loop;

      -- Raise a warning if extra rights are there for the person
      open csr_chk_addl_rights;
      fetch csr_chk_addl_rights into dummy;
      if csr_chk_addl_rights%found then
        p_addl_rights_warning := TRUE;
      else
        p_addl_rights_warning := FALSE;
      end if;
      close csr_chk_addl_rights;
      -- end fix 1370960

   end if;

  hr_utility.set_location(l_proc, 60);

  /*
  ** If it's set process final process date....
  */
  if l_curr_final_process_date is null
     and l_final_process_date is not null
  then

    hr_utility.set_location(l_proc, 70);

    hr_contingent_worker_api.final_process_placement
       (p_validate                    => FALSE
       ,p_person_id                   => p_person_id
       ,p_date_start                  => p_date_start
       ,p_object_version_number       => p_object_version_number
       ,p_final_process_date          => l_final_process_date
       ,p_org_now_no_manager_warning  => p_org_now_no_manager_warning
       ,p_asg_future_changes_warning  => p_asg_future_changes_warning
       ,p_entries_changed_warning     => p_entries_changed_warning
       );
  end if;

  hr_utility.set_location(l_proc, 80);
  --
  -- Added HR workflow for the termination process. Bug 3829474
  -- Even though the following call is psecific to period of service,
  -- used the same forperiod of placement.
  --

  /* Bug 5504659
  PER_HRWF_SYNCH.per_pds_wf(
       p_person_id      => p_person_id
      ,p_date_start     => p_actual_termination_date
      ,p_date           => p_actual_termination_date
      ,p_action         => 'TERMINATION');
Note : added p_date_start to test, earlier code does not work*/

  --
  -- Fix for bug 3829474 ends here.
  --
  -- Start of API User Hook for the after hook of terminate_placement
  --
  begin
     hr_contingent_worker_bk4.terminate_placement_a
       (p_effective_date                => p_effective_date
       ,p_person_id                     => p_person_id
       ,p_date_start                    => p_date_start
       ,p_object_version_number         => p_object_version_number
       ,p_person_type_id                => p_person_type_id
       ,p_assignment_status_type_id     => p_assignment_status_type_id
       ,p_actual_termination_date       => p_actual_termination_date
       ,p_final_process_date            => l_final_process_date
       ,p_last_standard_process_date    => p_last_standard_process_date
       ,p_termination_reason            => p_termination_reason
       ,p_projected_termination_date    => null
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
       ,p_information_category          => p_information_category
       ,p_information1                  => p_information1
       ,p_information2                  => p_information2
       ,p_information3                  => p_information3
       ,p_information4                  => p_information4
       ,p_information5                  => p_information5
       ,p_information6                  => p_information6
       ,p_information7                  => p_information7
       ,p_information8                  => p_information8
       ,p_information9                  => p_information9
       ,p_information10                 => p_information10
       ,p_information11                 => p_information11
       ,p_information12                 => p_information12
       ,p_information13                 => p_information13
       ,p_information14                 => p_information14
       ,p_information15                 => p_information15
       ,p_information16                 => p_information16
       ,p_information17                 => p_information17
       ,p_information18                 => p_information18
       ,p_information19                 => p_information19
       ,p_information20                 => p_information20
       ,p_information21                 => p_information21
       ,p_information22                 => p_information22
       ,p_information23                 => p_information23
       ,p_information24                 => p_information24
       ,p_information25                 => p_information25
       ,p_information26                 => p_information26
       ,p_information27                 => p_information27
       ,p_information28                 => p_information28
       ,p_information29                 => p_information29
       ,p_information30                 => p_information30
       ,p_supervisor_warning            => p_supervisor_warning
       ,p_event_warning                 => p_event_warning
       ,p_interview_warning             => p_interview_warning
       ,p_review_warning                => p_review_warning
       ,p_recruiter_warning             => p_recruiter_warning
       ,p_asg_future_changes_warning    => p_asg_future_changes_warning
       ,p_entries_changed_warning       => p_entries_changed_warning
       ,p_pay_proposal_warning          => p_pay_proposal_warning
       ,p_dod_warning                   => p_dod_warning
       ,p_org_now_no_manager_warning    => p_org_now_no_manager_warning
       ,p_addl_rights_warning           => p_addl_rights_warning -- Fix 1370960
       );
  exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'TERMINATE_PLACEMENT',
          p_hook_type         => 'AP'
         );
  end;

  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  IF p_validate THEN
    RAISE hr_api.validate_enabled;
  END IF;

  hr_utility.set_location('Leaving: '||l_proc, 90);

EXCEPTION
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO terminate_placement;

  when others then
    --
    -- A validation or unexpected error has occurred
    --
    ROLLBACK TO terminate_placement;
    --
    -- set in out parameters and set out parameters
    --
    --p_object_version_number := l_object_version_number;
    --
    raise;
    --
    hr_utility.set_location('Leaving: '||l_proc, 100);

end terminate_placement;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< reverse_terminate_placement >------------------|
-- ----------------------------------------------------------------------------
--
procedure reverse_terminate_placement
  (p_validate                      in     boolean  default false
  ,p_person_id                     in     number
  ,p_actual_termination_date       in     date
  ,p_clear_details                 in     varchar2 default 'N'
  ,p_fut_actns_exist_warning       out nocopy    boolean
  ) is

  l_proc varchar2(80) := g_package||'reverse_terminate_placement';
  l_final_process_date         DATE;
  l_last_standard_process_date DATE;
  l_per_system_status          VARCHAR2(30);
  l_max_end_date               DATE;
  l_effective_end_date         DATE;
  l_action_chk                 VARCHAR2(1) := 'N';
  l_action_date                DATE;
  l_asg_status_type_id         NUMBER;
  FPD_FLAG                     BOOLEAN;
  b_future_person_type_err     BOOLEAN := FALSE;

  CURSOR c_assignment IS
  SELECT assignment_id
  ,      assignment_status_type_id
  ,      business_group_id
  FROM   per_all_assignments_f ass
  WHERE  ass.person_id = p_person_id
  AND    ass.effective_end_date = p_actual_termination_date
  FOR UPDATE;
  --
  CURSOR  future_person_types IS
  SELECT  pt.system_person_type
  FROM    per_person_type_usages_f ptu,
          per_person_types pt
  WHERE   ptu.person_id = p_person_id
  AND     ptu.person_type_id = pt.person_type_id
  AND     ptu.effective_start_date > p_actual_termination_date;

  cursor c1 is
    select *
    from   per_periods_of_placement
    where  person_id = p_person_id
    and    actual_termination_date = p_actual_termination_date;
  --

  -- fix 1370960
    cursor csr_roles is
    select role_id
    ,object_version_number
    ,old_end_date from
    per_roles
    where person_id = p_person_id
    and end_date = p_actual_termination_date
    for update nowait;
  -- fix 1370960 end

  l_c1 c1%rowtype;
  --
  --
  -- START WWBUG fix for 1390173
  --
  l_old   ben_pps_ler.g_pps_ler_rec;
  l_new   ben_pps_ler.g_pps_ler_rec;
  --
  -- END WWBUG fix for 1390173
  --
  --
  -- Start of Fix for WWBUG 1408379
  --
  cursor c2(p_assignment_id number) is
    select *
    from   per_assignment_budget_values_f
    where  assignment_id = p_assignment_id
    and    effective_end_date = l_final_process_date;
  --
  l_old_abv   ben_abv_ler.g_abv_ler_rec;
  l_new_abv   ben_abv_ler.g_abv_ler_rec;
  l_c2 c2%rowtype;
  --
  -- End of Fix for WWBUG 1408379
  --

begin

  hr_utility.set_location('Entering: '||l_proc, 10);

  --
  -- Issue a savepoint.
  --
  savepoint reverse_terminate_placement;

  hr_api.mandatory_arg_error
     (p_api_name       => l_proc
     ,p_argument       => 'person_id'
     ,p_argument_value => p_person_id
     );
  --
  hr_api.mandatory_arg_error
     (p_api_name       => l_proc
     ,p_argument       => 'actual_termination_date'
     ,p_argument_value => p_actual_termination_date
     );

  --
  -- Start of API User Hook for the before hook of reverse_terminate_placement
  --
  begin
     hr_contingent_worker_bk5.reverse_terminate_placement_b
       (p_validate                      => p_validate
       ,p_person_id                     => p_person_id
       ,p_actual_termination_date       => p_actual_termination_date
       ,p_clear_details                 => p_clear_details
       );
  exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'REVERSE_TERMINATE_PLACEMENT',
          p_hook_type         => 'BP'
         );
  end;
  --
  -- End of API User Hook for the before hook of reverse_terminate_placement
  --
  hr_utility.set_location(l_proc, 20);

  hr_utility.trace('Entered reverse termination for '||p_person_id);
  --
  hr_utility.set_location(l_proc,25);
  begin
  SELECT pdp.final_process_date
  ,      pdp.last_standard_process_date
  INTO   l_final_process_date
  ,      l_last_standard_process_date
  FROM   per_periods_of_placement pdp
  WHERE  pdp.person_id = p_person_id
  AND    pdp.actual_termination_date = p_actual_termination_date;
  --
  exception when NO_DATA_FOUND then

    fnd_message.set_name('PER','HR_289614_PDP_STILL_OPEN');
    fnd_message.raise_error;
  end;
  --
  hr_utility.set_location(l_proc,30);

  --
  -- Check for future person types
  --
  for fpt_rec in future_person_types loop

    hr_utility.set_location(l_proc,35);
    hr_utility.trace('System person type: '||fpt_rec.system_person_type);
-- start of bug 4457651
-- commented out the if condition and redifined it
--    if fpt_rec.system_person_type <> 'EX_CWK' then
    if fpt_rec.system_person_type in ('EMP','APL','CWK') then
      b_future_person_type_err := TRUE;
    end if;

  end loop;

  if b_future_person_type_err = TRUE then
     fnd_message.set_name('PAY','HR_7122_EMP_CNCL_TERM_INVLD');
     fnd_message.raise_error;
  end if;
  --
  hr_utility.set_location(l_proc,40);

  --
  -- Check for future completed actions.
  --
  if l_last_standard_process_date is not null then

    if p_actual_termination_date is not null
    and l_last_standard_process_date > p_actual_termination_date then
      l_action_date := l_last_standard_process_date;
    else
      l_action_date := null;
    end if;

  else

    l_action_date := p_actual_termination_date;

  end if;

  BEGIN
    SELECT 'Y'
      INTO   l_action_chk
      FROM   dual
      WHERE  exists
           (SELECT null
            FROM   pay_payroll_actions pac,
                   pay_assignment_actions act,
                   per_all_assignments_f asg
            WHERE  asg.person_id = p_person_id
            AND    act.assignment_id = asg.assignment_id
            AND    pac.payroll_action_id = act.payroll_action_id
            AND    pac.action_type not in  ('X','BEE')    -- Bug 889806,2711532
            AND    pac.effective_date > l_final_process_date);
    exception when NO_DATA_FOUND then null;
    END;
    --
    hr_utility.set_location(l_proc,45);

    IF l_action_chk = 'N' THEN
      BEGIN
        SELECT 'W'
        INTO   l_action_chk
        FROM   sys.dual
        WHERE  exists
          (SELECT null
           FROM    pay_payroll_actions pac,
                   pay_assignment_actions act,
                   per_all_assignments_f asg
           WHERE   asg.person_id = p_person_id
           AND     act.assignment_id = asg.assignment_id
           AND     pac.payroll_action_id = act.payroll_action_id
           AND     pac.action_status = 'C'
           AND    (pac.effective_date BETWEEN l_action_date AND l_final_process_date));
        --
        hr_utility.set_location(l_proc,7);
        exception when NO_DATA_FOUND then null;
        END;
    END IF;

  --
  IF l_action_chk = 'W' THEN

    fnd_message.set_name('PER','HR_289615_FUTURE_ACTIONS_EXIST');
    fnd_message.raise_error;
  END IF;
  --
  if l_action_chk = 'Y' then
    p_fut_actns_exist_warning := TRUE;
  end if;
  --
  hr_utility.set_location(l_proc,50);

  FPD_FLAG := (l_final_process_date IS NOT NULL);
  --
  hr_utility.set_location(l_proc,55);
  UPDATE per_people_f pp
  SET    pp.effective_end_date = hr_api.g_eot
  WHERE  pp.person_id          = p_person_id
  AND    p_actual_termination_date
         BETWEEN pp.effective_start_date
         AND     pp.effective_end_date;
  --
  hr_utility.set_location(l_proc,60);
  DELETE per_people_f pp
  WHERE  pp.person_id = p_person_id
  AND    pp.effective_start_date > p_actual_termination_date;
  --
  hr_utility.set_location(l_proc,65);
  --
  -- WWBUG #       - CERN want to keep old details
  --    was a feature of rel 9
  if (p_clear_details = 'N') then
     --
--
-- START WWBUG fix for 1390173
--
/*     open c1;
       fetch c1 into l_c1;
       if c1%found then
         --
         l_old.PERSON_ID := l_c1.person_id;
         l_old.BUSINESS_GROUP_ID := l_c1.business_group_id;
         l_old.DATE_START := l_c1.date_start;
         l_old.ACTUAL_TERMINATION_DATE := l_c1.actual_termination_date;
         l_old.TERMINATION_REASON := l_c1.termination_reason;
         l_old.ATTRIBUTE1 := l_c1.attribute1;
         l_old.ATTRIBUTE2 := l_c1.attribute2;
         l_old.ATTRIBUTE3 := l_c1.attribute3;
         l_old.ATTRIBUTE4 := l_c1.attribute4;
         l_old.ATTRIBUTE5 := l_c1.attribute5;
         l_old.FINAL_PROCESS_DATE := l_c1.FINAL_PROCESS_DATE;
         l_new.PERSON_ID := l_c1.person_id;
         l_new.BUSINESS_GROUP_ID := l_c1.business_group_id;
         l_new.DATE_START := l_c1.date_start;
         l_new.ACTUAL_TERMINATION_DATE := null;
         l_new.TERMINATION_REASON := null;
         l_new.ATTRIBUTE1 := l_c1.attribute1;
         l_new.ATTRIBUTE2 := l_c1.attribute2;
         l_new.ATTRIBUTE3 := l_c1.attribute3;
         l_new.ATTRIBUTE4 := l_c1.attribute4;
         l_new.ATTRIBUTE5 := l_c1.attribute5;
         l_new.FINAL_PROCESS_DATE := l_c1.FINAL_PROCESS_DATE;
         --
         ben_pps_ler.ler_chk(p_old            => l_old
                            ,p_new            => l_new
                            ,p_event          => 'UPDATING'
                            ,p_effective_date => l_c1.date_start);
         --
       end if;
     close c1;
     --
*/
--
-- END WWBUG fix for 1390173
--
     UPDATE per_periods_of_placement pdp
     SET    pdp.actual_termination_date     = null
     ,      pdp.last_standard_process_date  = null
     ,      pdp.final_process_date          = null
     ,      pdp.termination_reason          = null
     ,      pdp.projected_termination_date  = null
     WHERE  pdp.person_id                   = p_person_id
     AND    pdp.actual_termination_date     = p_actual_termination_date;
  else
     --
--
-- START WWBUG fix for 1390173
--
/*
     open c1;
       fetch c1 into l_c1;
       if c1%found then
         --
         l_old.PERSON_ID := l_c1.person_id;
         l_old.BUSINESS_GROUP_ID := l_c1.business_group_id;
         l_old.DATE_START := l_c1.date_start;
         l_old.ACTUAL_TERMINATION_DATE := l_c1.actual_termination_date;
         l_old.TERMINATION_REASON := l_c1.leaving_reason;
         l_old.ATTRIBUTE1 := l_c1.attribute1;
         l_old.ATTRIBUTE2 := l_c1.attribute2;
         l_old.ATTRIBUTE3 := l_c1.attribute3;
         l_old.ATTRIBUTE4 := l_c1.attribute4;
         l_old.ATTRIBUTE5 := l_c1.attribute5;
         l_old.FINAL_PROCESS_DATE := l_c1.FINAL_PROCESS_DATE;
         l_new.PERSON_ID := l_c1.person_id;
         l_new.BUSINESS_GROUP_ID := l_c1.business_group_id;
         l_new.DATE_START := l_c1.date_start;
         l_new.ACTUAL_TERMINATION_DATE := null;
         l_new.TERMINATION_REASON := null;
         l_new.ATTRIBUTE1 := l_c1.attribute1;
         l_new.ATTRIBUTE2 := l_c1.attribute2;
         l_new.ATTRIBUTE3 := l_c1.attribute3;
         l_new.ATTRIBUTE4 := l_c1.attribute4;
         l_new.ATTRIBUTE5 := l_c1.attribute5;
         l_new.FINAL_PROCESS_DATE := l_c1.FINAL_PROCESS_DATE;
         --
         ben_pps_ler.ler_chk(p_old            => l_old
                            ,p_new            => l_new
                            ,p_event          => 'UPDATING'
                            ,p_effective_date => l_c1.date_start);
         --
       end if;
     close c1;
*/
     --
--
-- END WWBUG fix for 1390173
--
     UPDATE per_periods_of_placement pdp
     SET    pdp.actual_termination_date     = null
     ,      pdp.last_standard_process_date  = null
     ,      pdp.final_process_date          = null
     ,      pdp.termination_reason          = null
     ,      pdp.projected_termination_date  = null
     WHERE  pdp.person_id                   = p_person_id
     AND    pdp.actual_termination_date     = p_actual_termination_date;
     --
  end if;

  --
  -- FIX to WWBUG 1176101
  --
/*
  ben_dt_trgr_handle.periods_of_service
    (p_rowid              => null
    ,p_person_id          => p_person_id
    ,p_pds_atd            => null
    ,p_pds_leaving_reason => null
    -- Bug 1854968
    ,p_pds_old_atd        => l_old.actual_termination_date
    ,p_pds_fpd            => null);
*/
  --
  --
  --
  hr_utility.set_location(l_proc,70);
  FOR c_asg_rec IN c_assignment LOOP
  --
    hr_utility.set_location(l_proc,75);
    SELECT per_system_status
    INTO   l_per_system_status
    FROM   per_assignment_status_types
    WHERE  assignment_status_type_id = c_asg_rec.assignment_status_type_id;
    --
    -- Get the assignment_status_id from the record which ended on ATD
    -- so that we can set the other records for this assignment which
    -- are currently TERM_CWK_ASG back to the appropriate ACTIVE_CWK_ASG status.
    --
    SELECT assignment_status_type_id
    INTO   l_asg_status_type_id
    FROM   per_all_assignments_f
    WHERE  assignment_id = c_asg_rec.assignment_id
    AND    effective_end_date = p_actual_termination_date;
    --
    hr_utility.set_location(l_proc,80);

    SELECT  max(asg.effective_end_date)
    INTO    l_max_end_date
    FROM    per_all_assignments_f asg
    WHERE   asg.assignment_id = c_asg_rec.assignment_id;

    --
    if l_per_system_status <> 'TERM_CWK_ASG' then
      hr_utility.set_location(l_proc,85);
      if FPD_FLAG then
        hr_utility.set_location(l_proc,90);
        if l_max_end_date <> l_final_process_date then
           l_effective_end_date := l_max_end_date;
        else
           hr_utility.set_location(l_proc,95);
           l_effective_end_date := hr_api.g_eot;
        end if;
      else
         hr_utility.set_location(l_proc,100);
         l_effective_end_date := l_max_end_date;
      end if;
      --
      hr_utility.set_location(l_proc,105);
      --
      -- Open out the last dated assignment record to the end of time or
      -- max_end_date based on above logic.
      --
      UPDATE per_all_assignments_f ass
      SET    ass.effective_end_date = l_effective_end_date
      WHERE  assignment_id = c_asg_rec.assignment_id
        AND  effective_end_date = l_max_end_date;
      --
      -- We want to keep all the assignment records after the ATD so
      -- update them all to the same assignment_status as the record
      -- which ends on ATD.
      --
      -- As a result of the changes due to bug 1271513 as a result of
      -- terminating and reverse terminating an additional assignment
      -- record will exist which runs from ATD+1 to the start date-1
      -- of the next date effective record for the person or EOT
      -- depending on the data present at time of termination.
      --
      UPDATE per_all_assignments_f ass
      SET    ass.assignment_status_type_id = l_asg_status_type_id
      WHERE  assignment_id = c_asg_rec.assignment_id
        AND  effective_start_date >= p_actual_termination_date;
      --
    end if;
    --
    if FPD_FLAG then
      hr_utility.set_location(l_proc,110);
      if l_max_end_date <> l_final_process_date then
        null;
      else
        hr_utility.set_location(l_proc,115);
        l_effective_end_date := hr_api.g_eot;
        --
        hr_utility.set_location(l_proc,120);
        UPDATE per_secondary_ass_statuses sas
        SET    sas.end_date = null
        WHERE  sas.assignment_id = c_asg_rec.assignment_id
        AND    sas.end_date = l_final_process_date;
        --
        hr_utility.set_location(l_proc,125);
        UPDATE pay_personal_payment_methods_f ppm
        SET    ppm.effective_end_date = l_effective_end_date
        WHERE  ppm.assignment_id      = c_asg_rec.assignment_id
        AND    ppm.effective_end_date = l_final_process_date;
        --
        hr_utility.set_location(l_proc,130);
        UPDATE pay_cost_allocations_f pca
        SET    pca.effective_end_date = l_effective_end_date
        WHERE  pca.assignment_id      = c_asg_rec.assignment_id
        AND    pca.effective_end_date = l_final_process_date;
        --
        hr_utility.set_location(l_proc,135);
        UPDATE per_spinal_point_placements_f spp
        SET    spp.effective_end_date = l_effective_end_date
        WHERE  spp.assignment_id      = c_asg_rec.assignment_id
        AND    spp.effective_end_date = l_final_process_date;
        --
        UPDATE pay_grade_rules_f pgr
        SET    pgr.effective_end_date = l_effective_end_date
        WHERE  pgr.grade_or_spinal_point_Id = c_asg_rec.assignment_id
        AND    pgr.rate_type          = 'A'
        AND    pgr.effective_end_date = l_final_process_date;
        --
        --
        -- Adding code to update the date tracked tax tables to resolve bug
        -- 920233.
        -- Adding an extra verification to make sure the tax records are reverse
        -- only for US legislation. This extra verification is done because
        -- this package peempter.pkb is part of the CORE HR code and UK
        -- customer do not use these TAX tables. Only Customers with HR/CERIDIAN
        -- use this TAX tables.

        if hr_general.chk_geocodes_installed ='Y' then
          hr_utility.set_location(l_proc,140);
          pay_us_update_tax_rec_pkg.reverse_term_emp_tax_records
                                   (c_asg_rec.assignment_id
                                   ,l_final_process_date);

        end if; /* verification chk_geocodes_installed */
        --
        -- SASmith 30-APR-1998
        -- Due to date tracking of assignment_budget_values

        hr_utility.set_location(l_proc,145);
        --
        -- Start of Fix for WWBUG 1408379
        --
        open c2(c_asg_rec.assignment_id);
          --
          loop
            --
            fetch c2 into l_c2;
            exit when c2%notfound;
            --
            l_old_abv.assignment_id := l_c2.assignment_id;
            l_old_abv.business_group_id := l_c2.business_group_id;
            l_old_abv.value := l_c2.value;
            l_old_abv.assignment_budget_value_id := l_c2.assignment_budget_value_id;
            l_old_abv.effective_start_date := l_c2.effective_start_date;
            l_old_abv.effective_end_date := l_c2.effective_end_date;
            l_new_abv.assignment_id := l_c2.assignment_id;
            l_new_abv.business_group_id := l_c2.business_group_id;
            l_new_abv.value := l_c2.value;
            l_new_abv.assignment_budget_value_id := l_c2.assignment_budget_value_id;
            l_new_abv.effective_start_date := l_c2.effective_start_date;
            l_new_abv.effective_end_date := l_effective_end_date;
            --
            update per_assignment_budget_values_f abv
            set    abv.effective_end_date = l_effective_end_date
            where  abv.assignment_id      = c_asg_rec.assignment_id
            and    abv.assignment_budget_value_id = l_c2.assignment_budget_value_id
            and    abv.effective_end_date = l_final_process_date;
/*            --
            ben_abv_ler.ler_chk(p_old            => l_old_abv,
                                p_new            => l_new_abv,
                                p_effective_date => l_c2.effective_start_date);
*/            --
          end loop;
          --
        close c2;
        --
        -- End of Fix for WWBUG 1408379
        --
      end if;
    --
    end if;
  --
  -- open up element entries closed down by the termination
  --
  hr_utility.set_location(l_proc,150);
  hrentmnt.maintain_entries_asg(c_asg_rec.assignment_id
                               ,c_asg_rec.business_group_id
                               ,'CNCL_TERM'
                               ,p_actual_termination_date
                               ,l_last_standard_process_date
                               ,l_final_process_date
                               ,'DELETE_NEXT_CHANGE'
                               ,null
                               ,null);
  --
  --
  END LOOP;

  --
  -- Change the person type usage record back to contingent worker
  --
  hr_per_type_usage_internal.cancel_person_type_usage
    (p_effective_date         => p_actual_termination_date+1
    ,p_person_id              => p_person_id
    ,p_system_person_type     => 'EX_CWK'
    );

  hr_utility.set_location(l_proc, 155);

  --
  -- Start of API User Hook for the after hook of reverse_terminate_placement
  --
  begin
     hr_contingent_worker_bk5.reverse_terminate_placement_a
       (p_validate                      => p_validate
       ,p_person_id                     => p_person_id
       ,p_actual_termination_date       => p_actual_termination_date
       ,p_clear_details                 => p_clear_details
       ,p_fut_actns_exist_warning       => p_fut_actns_exist_warning
       );
  exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'REVERSE_TERMINATE_PLACEMENT',
          p_hook_type         => 'AP'
         );
  end;
  --
  -- End of API User Hook for the after hook of reverse_terminate_placement
  --

  -- fix 1370960
  for roles_rec in csr_roles
  loop
    per_supplementary_role_api.update_supplementary_role(
        p_effective_date                => p_actual_termination_date+1
        ,p_role_id                      => roles_rec.role_id
        ,p_object_version_number        => roles_rec.object_version_number
        ,p_end_date                     => roles_rec.old_end_date
        );
  end loop;
  -- 1370960 end

  hr_utility.set_location('Leaving: '||l_proc, 200);

exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO reverse_terminate_placement;

  when others then
    --
    -- A validation or unexpected error has occurred
    --
    ROLLBACK TO reverse_terminate_placement;
    --
    -- set in out parameters and set out parameters
    --
    --p_object_version_number := l_object_version_number;
    --
    raise;
    --
end reverse_terminate_placement;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< Get_Length_of_Placement >---------------------|
-- ----------------------------------------------------------------------------
--
procedure get_length_of_placement
  (p_effective_date     in    date
  ,p_business_group_id  in    number
  ,p_person_id          in    number
  ,p_date_start         in    date
  ,p_total_years        out nocopy   number
  ,p_total_months       out nocopy   number) is

  l_proc         varchar2(80) := g_package||'get_length_of_placement';
  l_total_years  number := 0;
  l_total_months number := 0;

  cursor c_get_length is
  select trunc(sum(months_between
                    (least
                      (nvl(ACTUAL_TERMINATION_DATE + 1, p_effective_date + 1),
                       p_effective_date + 1)
                    ,DATE_START)) / 12, 0) total_years,
         trunc(mod(sum(months_between
                         (least
                           (nvl(ACTUAL_TERMINATION_DATE + 1, p_effective_date + 1),
                            p_effective_date + 1)
                         ,DATE_START)), 12), 0) total_months
  from   PER_PERIODS_OF_PLACEMENT
  where  PERSON_ID          = p_person_id
  and    business_group_id  = p_business_group_id
  and    DATE_START         = p_date_start
  and    DATE_START        <= p_effective_date;


begin

  hr_utility.set_location('Entering: '||l_proc, 10);
  --
  -- Get the total length of the placement
  --
  open  c_get_length;
  fetch c_get_length into l_total_years,
                          l_total_months;

  if c_get_length%NOTFOUND then

    --
    -- The person could not be found.
    --
    hr_utility.set_location(l_proc, 30);

  end if;

  close c_get_length;

  --
  -- Set the out parameters
  --
  p_total_years  := l_total_years;
  p_total_months := l_total_months;

  hr_utility.set_location('Leaving: '||l_proc, 30);

end get_length_of_placement;

end hr_contingent_worker_api;

/
