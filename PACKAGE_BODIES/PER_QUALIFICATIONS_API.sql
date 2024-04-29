--------------------------------------------------------
--  DDL for Package Body PER_QUALIFICATIONS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_QUALIFICATIONS_API" as
/* $Header: pequaapi.pkb 120.0.12010000.3 2009/03/12 11:38:16 dparthas ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'per_qualifications_api.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------<CREATE_QUALIFICATION>--------------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_QUALIFICATION
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_qualification_type_id         in     number
  ,p_language_code                 in     varchar2 default hr_api.userenv_lang
  ,p_business_group_id             in     number   default null
  ,p_person_id                     in     number   default null
  ,p_title                         in     varchar2 default null
  ,p_grade_attained                in     varchar2 default null
  ,p_status                        in     varchar2 default null
  ,p_awarded_date                  in     date     default null
  ,p_fee                           in     number   default null
  ,p_fee_currency                  in     varchar2 default null
  ,p_training_completed_amount     in     number   default null
  ,p_reimbursement_arrangements    in     varchar2 default null
  ,p_training_completed_units      in     varchar2 default null
  ,p_total_training_amount         in     number   default null
  ,p_start_date                    in     date     default null
  ,p_end_date                      in     date     default null
  ,p_license_number                in     varchar2 default null
  ,p_expiry_date                   in     date     default null
  ,p_license_restrictions          in     varchar2 default null
  ,p_projected_completion_date     in     date     default null
  ,p_awarding_body                 in     varchar2 default null
  ,p_tuition_method                in     varchar2 default null
  ,p_group_ranking                 in     varchar2 default null
  ,p_comments                      in     varchar2 default null
  ,p_attendance_id                 in     number   default null
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
  ,p_party_id                      in     number   default null
  ,p_qua_information_category      in     varchar2 default null
  ,p_qua_information1              in     varchar2 default null
  ,p_qua_information2              in     varchar2 default null
  ,p_qua_information3              in     varchar2 default null
  ,p_qua_information4              in     varchar2 default null
  ,p_qua_information5              in     varchar2 default null
  ,p_qua_information6              in     varchar2 default null
  ,p_qua_information7              in     varchar2 default null
  ,p_qua_information8              in     varchar2 default null
  ,p_qua_information9              in     varchar2 default null
  ,p_qua_information10             in     varchar2 default null
  ,p_qua_information11             in     varchar2 default null
  ,p_qua_information12             in     varchar2 default null
  ,p_qua_information13             in     varchar2 default null
  ,p_qua_information14             in     varchar2 default null
  ,p_qua_information15             in     varchar2 default null
  ,p_qua_information16             in     varchar2 default null
  ,p_qua_information17             in     varchar2 default null
  ,p_qua_information18             in     varchar2 default null
  ,p_qua_information19             in     varchar2 default null
  ,p_qua_information20             in     varchar2 default null
  ,p_professional_body_name        in     varchar2 default null
  ,p_membership_number             in     varchar2 default null
  ,p_membership_category           in     varchar2 default null
  ,p_subscription_payment_method   in     varchar2 default null
  ,p_qualification_id                 out nocopy number
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                      varchar2(72) := g_package||'create_qualification';
  l_object_version_number     number(9);
  l_qualification_id          number(9);
  l_effective_date            date;
  l_awarded_date              date;
  l_start_date                date;
  l_end_date                  date;
  l_expiry_date               date;
  l_projected_completion_date date;
  l_language_code             varchar2(30);

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_QUALIFICATION;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date            := TRUNC(p_effective_date);
  l_awarded_date              := TRUNC(p_awarded_date);
  l_start_date                := TRUNC(p_start_date);
  l_end_date                  := TRUNC(p_end_date);
  l_expiry_date               := TRUNC(p_expiry_date);
  l_projected_completion_date := TRUNC(p_projected_completion_date);

  -- Validate the language parameter. l_language_code should be passed
  -- instead of p_language_code from now on, to allow an IN OUT parameter to
  -- be passed through.
  --
  l_language_code := p_language_code;
  hr_api.validate_language_code(p_language_code => l_language_code);

  --
  -- Call Before Process User Hook
  --
  begin
    PER_QUALIFICATIONS_BK1.CREATE_QUALIFICATION_B
  (p_effective_date                => l_effective_date
  ,p_business_group_id             => p_business_group_id
  ,p_qualification_type_id         => p_qualification_type_id
  ,p_person_id                     => p_person_id
  ,p_party_id                      => p_party_id
  ,p_title                         => p_title
  ,p_grade_attained                => p_grade_attained
  ,p_status                        => p_status
  ,p_awarded_date                  => l_awarded_date
  ,p_fee                           => p_fee
  ,p_fee_currency                  => p_fee_currency
  ,p_training_completed_amount     => p_training_completed_amount
  ,p_reimbursement_arrangements    => p_reimbursement_arrangements
  ,p_training_completed_units      => p_training_completed_units
  ,p_total_training_amount         => p_total_training_amount
  ,p_start_date                    => l_start_date
  ,p_end_date                      => l_end_date
  ,p_license_number                => p_license_number
  ,p_expiry_date                   => l_expiry_date
  ,p_license_restrictions          => p_license_restrictions
  ,p_projected_completion_date     => l_projected_completion_date
  ,p_awarding_body                 => p_awarding_body
  ,p_tuition_method                => p_tuition_method
  ,p_group_ranking                 => p_group_ranking
  ,p_comments                      => p_comments
  ,p_attendance_id                 => p_attendance_id
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
  ,p_qua_information_category      => p_qua_information_category
  ,p_qua_information1              => p_qua_information1
  ,p_qua_information2              => p_qua_information2
  ,p_qua_information3              => p_qua_information3
  ,p_qua_information4              => p_qua_information4
  ,p_qua_information5              => p_qua_information5
  ,p_qua_information6              => p_qua_information6
  ,p_qua_information7              => p_qua_information7
  ,p_qua_information8              => p_qua_information8
  ,p_qua_information9              => p_qua_information9
  ,p_qua_information10             => p_qua_information10
  ,p_qua_information11             => p_qua_information11
  ,p_qua_information12             => p_qua_information12
  ,p_qua_information13             => p_qua_information13
  ,p_qua_information14             => p_qua_information14
  ,p_qua_information15             => p_qua_information15
  ,p_qua_information16             => p_qua_information16
  ,p_qua_information17             => p_qua_information17
  ,p_qua_information18             => p_qua_information18
  ,p_qua_information19             => p_qua_information19
  ,p_qua_information20             => p_qua_information20
  ,p_professional_body_name        => p_professional_body_name
  ,p_membership_number             => p_membership_number
  ,p_membership_category           => p_membership_category
  ,p_subscription_payment_method   => p_subscription_payment_method
  ,p_language_code                 => l_language_code);
  exception
    when hr_Api.cannot_find_prog_unit then
      hr_Api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_QUALIFICATION'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --
  per_qua_ins.ins
  (p_validate                     => false
  ,p_effective_date               => l_effective_date
  ,p_business_group_id            => p_business_group_id
  ,p_person_id                    => p_person_id
  ,p_party_id                     => p_party_id
  ,p_title                        => p_title
  ,p_grade_attained               => p_grade_attained
  ,p_status                       => p_status
  ,p_awarded_date                 => l_awarded_date
  ,p_fee                          => p_fee
  ,p_fee_currency                 => p_fee_currency
  ,p_training_completed_amount    => p_training_completed_amount
  ,p_reimbursement_arrangements   => p_reimbursement_arrangements
  ,p_training_completed_units     => p_training_completed_units
  ,p_total_training_amount        => p_total_training_amount
  ,p_start_date                   => l_start_date
  ,p_end_date                     => l_end_date
  ,p_license_number               => p_license_number
  ,p_expiry_date                  => l_expiry_date
  ,p_license_restrictions         => p_license_restrictions
  ,p_projected_completion_date    => l_projected_completion_date
  ,p_awarding_body                => p_awarding_body
  ,p_tuition_method               => p_tuition_method
  ,p_group_ranking                => p_group_ranking
  ,p_comments                     => p_comments
  ,p_qualification_type_id        => p_qualification_type_id
  ,p_attendance_id                => p_attendance_id
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
  ,p_qua_information_category     => p_qua_information_category
  ,p_qua_information1             => p_qua_information1
  ,p_qua_information2             => p_qua_information2
  ,p_qua_information3             => p_qua_information3
  ,p_qua_information4             => p_qua_information4
  ,p_qua_information5             => p_qua_information5
  ,p_qua_information6             => p_qua_information6
  ,p_qua_information7             => p_qua_information7
  ,p_qua_information8             => p_qua_information8
  ,p_qua_information9             => p_qua_information9
  ,p_qua_information10            => p_qua_information10
  ,p_qua_information11            => p_qua_information11
  ,p_qua_information12            => p_qua_information12
  ,p_qua_information13            => p_qua_information13
  ,p_qua_information14            => p_qua_information14
  ,p_qua_information15            => p_qua_information15
  ,p_qua_information16            => p_qua_information16
  ,p_qua_information17            => p_qua_information17
  ,p_qua_information18            => p_qua_information18
  ,p_qua_information19            => p_qua_information19
  ,p_qua_information20            => p_qua_information20
  ,p_professional_body_name       => p_professional_body_name
  ,p_membership_number            => p_membership_number
  ,p_membership_category          => p_membership_category
  ,p_subscription_payment_method  => p_subscription_payment_method
  ,p_qualification_id             => l_qualification_id
  ,p_object_version_number        => l_object_version_number
  );

  --
  -- MLS Processing
  --
  per_qat_ins.ins_tl
  (p_language_code                => l_language_code
  ,p_qualification_id             => l_qualification_id
  ,p_title                        => p_title
  ,p_group_ranking                => p_group_ranking
  ,p_license_restrictions         => p_license_restrictions
  ,p_awarding_body                => p_awarding_body
  ,p_grade_attained               => p_grade_attained
  ,p_reimbursement_arrangements   => p_reimbursement_arrangements
  ,p_training_completed_units     => p_training_completed_units
  ,p_membership_category          => p_membership_category
  );

  --
  -- Call After Process User Hook
  --
  begin
  PER_QUALIFICATIONS_BK1.CREATE_QUALIFICATION_A
  (p_qualification_id              => l_qualification_id
  ,p_effective_date                => l_effective_date
  ,p_business_group_id             => p_business_group_id
  ,p_qualification_type_id         => p_qualification_type_id
  ,p_person_id                     => p_person_id
  ,p_party_id                      => p_party_id
  ,p_title                         => p_title
  ,p_grade_attained                => p_grade_attained
  ,p_status                        => p_status
  ,p_awarded_date                  => l_awarded_date
  ,p_fee                           => p_fee
  ,p_fee_currency                  => p_fee_currency
  ,p_training_completed_amount     => p_training_completed_amount
  ,p_reimbursement_arrangements    => p_reimbursement_arrangements
  ,p_training_completed_units      => p_training_completed_units
  ,p_total_training_amount         => p_total_training_amount
  ,p_start_date                    => l_start_date
  ,p_end_date                      => l_end_date
  ,p_license_number                => p_license_number
  ,p_expiry_date                   => l_expiry_date
  ,p_license_restrictions          => p_license_restrictions
  ,p_projected_completion_date     => l_projected_completion_date
  ,p_awarding_body                 => p_awarding_body
  ,p_tuition_method                => p_tuition_method
  ,p_group_ranking                 => p_group_ranking
  ,p_comments                      => p_comments
  ,p_attendance_id                 => p_attendance_id
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
  ,p_qua_information_category      => p_qua_information_category
  ,p_qua_information1              => p_qua_information1
  ,p_qua_information2              => p_qua_information2
  ,p_qua_information3              => p_qua_information3
  ,p_qua_information4              => p_qua_information4
  ,p_qua_information5              => p_qua_information5
  ,p_qua_information6              => p_qua_information6
  ,p_qua_information7              => p_qua_information7
  ,p_qua_information8              => p_qua_information8
  ,p_qua_information9              => p_qua_information9
  ,p_qua_information10             => p_qua_information10
  ,p_qua_information11             => p_qua_information11
  ,p_qua_information12             => p_qua_information12
  ,p_qua_information13             => p_qua_information13
  ,p_qua_information14             => p_qua_information14
  ,p_qua_information15             => p_qua_information15
  ,p_qua_information16             => p_qua_information16
  ,p_qua_information17             => p_qua_information17
  ,p_qua_information18             => p_qua_information18
  ,p_qua_information19             => p_qua_information19
  ,p_qua_information20             => p_qua_information20
  ,p_professional_body_name        => p_professional_body_name
  ,p_membership_number             => p_membership_number
  ,p_membership_category           => p_membership_category
  ,p_subscription_payment_method   => p_subscription_payment_method
  ,p_language_code                 => l_language_code);
  exception
    when hr_Api.cannot_find_prog_unit then
      hr_Api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_QUALIFICATION'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_Api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_qualification_id       := l_qualification_id;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_Api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_QUALIFICATION;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_qualification_id       := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_QUALIFICATION;
    --
    p_qualification_id       := null;
    p_object_version_number  := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end CREATE_QUALIFICATION;
--
-- ----------------------------------------------------------------------------
-- |--------------------------<UPDATE_QUALIFICATION>--------------------------|
-- ----------------------------------------------------------------------------
--
procedure UPDATE_QUALIFICATION
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_qualification_id              in     number
  ,p_language_code                 in     varchar2 default hr_api.userenv_lang
  ,p_qualification_type_id         in     number   default hr_api.g_number
  ,p_title                         in     varchar2 default hr_api.g_varchar2
  ,p_grade_attained                in     varchar2 default hr_api.g_varchar2
  ,p_status                        in     varchar2 default hr_api.g_varchar2
  ,p_awarded_date                  in     date     default hr_api.g_date
  ,p_fee                           in     number   default hr_api.g_number
  ,p_fee_currency                  in     varchar2 default hr_api.g_varchar2
  ,p_training_completed_amount     in     number   default hr_api.g_number
  ,p_reimbursement_arrangements    in     varchar2 default hr_api.g_varchar2
  ,p_training_completed_units      in     varchar2 default hr_api.g_varchar2
  ,p_total_training_amount         in     number   default hr_api.g_number
  ,p_start_date                    in     date     default hr_api.g_date
  ,p_end_date                      in     date     default hr_api.g_date
  ,p_license_number                in     varchar2 default hr_api.g_varchar2
  ,p_expiry_date                   in     date     default hr_api.g_date
  ,p_license_restrictions          in     varchar2 default hr_api.g_varchar2
  ,p_projected_completion_date     in     date     default hr_api.g_date
  ,p_awarding_body                 in     varchar2 default hr_api.g_varchar2
  ,p_tuition_method                in     varchar2 default hr_api.g_varchar2
  ,p_group_ranking                 in     varchar2 default hr_api.g_varchar2
  ,p_comments                      in     varchar2 default hr_api.g_varchar2
  ,p_attendance_id                 in     number   default hr_api.g_number
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
  ,p_qua_information_category      in     varchar2 default hr_api.g_varchar2
  ,p_qua_information1              in     varchar2 default hr_api.g_varchar2
  ,p_qua_information2              in     varchar2 default hr_api.g_varchar2
  ,p_qua_information3              in     varchar2 default hr_api.g_varchar2
  ,p_qua_information4              in     varchar2 default hr_api.g_varchar2
  ,p_qua_information5              in     varchar2 default hr_api.g_varchar2
  ,p_qua_information6              in     varchar2 default hr_api.g_varchar2
  ,p_qua_information7              in     varchar2 default hr_api.g_varchar2
  ,p_qua_information8              in     varchar2 default hr_api.g_varchar2
  ,p_qua_information9              in     varchar2 default hr_api.g_varchar2
  ,p_qua_information10             in     varchar2 default hr_api.g_varchar2
  ,p_qua_information11             in     varchar2 default hr_api.g_varchar2
  ,p_qua_information12             in     varchar2 default hr_api.g_varchar2
  ,p_qua_information13             in     varchar2 default hr_api.g_varchar2
  ,p_qua_information14             in     varchar2 default hr_api.g_varchar2
  ,p_qua_information15             in     varchar2 default hr_api.g_varchar2
  ,p_qua_information16             in     varchar2 default hr_api.g_varchar2
  ,p_qua_information17             in     varchar2 default hr_api.g_varchar2
  ,p_qua_information18             in     varchar2 default hr_api.g_varchar2
  ,p_qua_information19             in     varchar2 default hr_api.g_varchar2
  ,p_qua_information20             in     varchar2 default hr_api.g_varchar2
  ,p_professional_body_name        in     varchar2 default hr_api.g_varchar2
  ,p_membership_number             in     varchar2 default hr_api.g_varchar2
  ,p_membership_category           in     varchar2 default hr_api.g_varchar2
  ,p_subscription_payment_method   in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                      varchar2(72) := g_package||'update_qualification';
  l_effective_date            date;
  l_awarded_date              date;
  l_start_date                date;
  l_end_date                  date;
  l_expiry_date               date;
  l_projected_completion_date date;
  l_object_version_number     number;
  l_language_code             varchar2(30);
  l_temp_ovn                  number;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_QUALIFICATION;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date            := TRUNC(p_effective_date);
  l_awarded_date              := TRUNC(p_awarded_date);
  l_start_date                := TRUNC(p_start_date);
  l_end_date                  := TRUNC(p_end_date);
  l_expiry_date               := TRUNC(p_expiry_date);
  l_projected_completion_date := TRUNC(p_projected_completion_date);
  l_object_version_number     := p_object_version_number;
  l_temp_ovn                  := p_object_version_number;

  -- Validate the language parameter. l_language_code should be passed
  -- instead of p_language_code from now on, to allow an IN OUT parameter to
  -- be passed through.
  --
  l_language_code := p_language_code;
  hr_api.validate_language_code(p_language_code => l_language_code);

  --
  -- Call Before Process User Hook
  --
  begin
    PER_QUALIFICATIONS_BK2.UPDATE_QUALIFICATION_B
  (p_effective_date                => l_effective_date
  ,p_qualification_type_id         => p_qualification_type_id
  ,p_qualification_id              => p_qualification_id
  ,p_title                         => p_title
  ,p_grade_attained                => p_grade_attained
  ,p_status                        => p_status
  ,p_awarded_date                  => l_awarded_date
  ,p_fee                           => p_fee
  ,p_fee_currency                  => p_fee_currency
  ,p_training_completed_amount     => p_training_completed_amount
  ,p_reimbursement_arrangements    => p_reimbursement_arrangements
  ,p_training_completed_units      => p_training_completed_units
  ,p_total_training_amount         => p_total_training_amount
  ,p_start_date                    => l_start_date
  ,p_end_date                      => l_end_date
  ,p_license_number                => p_license_number
  ,p_expiry_date                   => l_expiry_date
  ,p_license_restrictions          => p_license_restrictions
  ,p_projected_completion_date     => l_projected_completion_date
  ,p_awarding_body                 => p_awarding_body
  ,p_tuition_method                => p_tuition_method
  ,p_group_ranking                 => p_group_ranking
  ,p_comments                      => p_comments
  ,p_attendance_id                 => p_attendance_id
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
  ,p_qua_information_category      => p_qua_information_category
  ,p_qua_information1              => p_qua_information1
  ,p_qua_information2              => p_qua_information2
  ,p_qua_information3              => p_qua_information3
  ,p_qua_information4              => p_qua_information4
  ,p_qua_information5              => p_qua_information5
  ,p_qua_information6              => p_qua_information6
  ,p_qua_information7              => p_qua_information7
  ,p_qua_information8              => p_qua_information8
  ,p_qua_information9              => p_qua_information9
  ,p_qua_information10             => p_qua_information10
  ,p_qua_information11             => p_qua_information11
  ,p_qua_information12             => p_qua_information12
  ,p_qua_information13             => p_qua_information13
  ,p_qua_information14             => p_qua_information14
  ,p_qua_information15             => p_qua_information15
  ,p_qua_information16             => p_qua_information16
  ,p_qua_information17             => p_qua_information17
  ,p_qua_information18             => p_qua_information18
  ,p_qua_information19             => p_qua_information19
  ,p_qua_information20             => p_qua_information20
  ,p_professional_body_name        => p_professional_body_name
  ,p_membership_number             => p_membership_number
  ,p_membership_category           => p_membership_category
  ,p_subscription_payment_method   => p_subscription_payment_method
  ,p_object_version_number         => l_object_version_number
  ,p_language_code                 => l_language_code);
  exception
    when hr_Api.cannot_find_prog_unit then
      hr_Api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_QUALIFICATION'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --


  per_qua_upd.upd
  (p_validate                     => false
  ,p_effective_date               => l_effective_date
  ,p_qualification_id             => p_qualification_id
  ,p_object_version_number        => l_object_version_number
  ,p_title                        => p_title
  ,p_grade_attained               => p_grade_attained
  ,p_status                       => p_status
  ,p_awarded_date                 => l_awarded_date
  ,p_fee                          => p_fee
  ,p_fee_currency                 => p_fee_currency
  ,p_training_completed_amount    => p_training_completed_amount
  ,p_reimbursement_arrangements   => p_reimbursement_arrangements
  ,p_training_completed_units     => p_training_completed_units
  ,p_total_training_amount        => p_total_training_amount
  ,p_start_date                   => l_start_date
  ,p_end_date                     => l_end_date
  ,p_license_number               => p_license_number
  ,p_expiry_date                  => l_expiry_date
  ,p_license_restrictions         => p_license_restrictions
  ,p_projected_completion_date    => l_projected_completion_date
  ,p_awarding_body                => p_awarding_body
  ,p_tuition_method               => p_tuition_method
  ,p_group_ranking                => p_group_ranking
  ,p_comments                     => p_comments
  ,p_qualification_type_id        => p_qualification_type_id
  ,p_attendance_id                => p_attendance_id
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
  ,p_qua_information_category     => p_qua_information_category
  ,p_qua_information1             => p_qua_information1
  ,p_qua_information2             => p_qua_information2
  ,p_qua_information3             => p_qua_information3
  ,p_qua_information4             => p_qua_information4
  ,p_qua_information5             => p_qua_information5
  ,p_qua_information6             => p_qua_information6
  ,p_qua_information7             => p_qua_information7
  ,p_qua_information8             => p_qua_information8
  ,p_qua_information9             => p_qua_information9
  ,p_qua_information10            => p_qua_information10
  ,p_qua_information11            => p_qua_information11
  ,p_qua_information12            => p_qua_information12
  ,p_qua_information13            => p_qua_information13
  ,p_qua_information14            => p_qua_information14
  ,p_qua_information15            => p_qua_information15
  ,p_qua_information16            => p_qua_information16
  ,p_qua_information17            => p_qua_information17
  ,p_qua_information18            => p_qua_information18
  ,p_qua_information19            => p_qua_information19
  ,p_qua_information20            => p_qua_information20
  ,p_professional_body_name       => p_professional_body_name
  ,p_membership_number            => p_membership_number
  ,p_membership_category          => p_membership_category
  ,p_subscription_payment_method  => p_subscription_payment_method
  );

  --
  -- MLS Processing
  --
  per_qat_upd.upd_tl
  (p_language_code                => l_language_code
  ,p_qualification_id             => p_qualification_id
  ,p_title                        => p_title
  ,p_group_ranking                => p_group_ranking
  ,p_license_restrictions         => p_license_restrictions
  ,p_awarding_body                => p_awarding_body
  ,p_grade_attained               => p_grade_attained
  ,p_reimbursement_arrangements   => p_reimbursement_arrangements
  ,p_training_completed_units     => p_training_completed_units
  ,p_membership_category          => p_membership_category
  );

  --
  -- Call After Process User Hook
  --
  begin
  PER_QUALIFICATIONS_BK2.UPDATE_QUALIFICATION_A
  (p_effective_date                => l_effective_date
  ,p_qualification_type_id         => p_qualification_type_id
  ,p_qualification_id              => p_qualification_id
  ,p_title                         => p_title
  ,p_grade_attained                => p_grade_attained
  ,p_status                        => p_status
  ,p_awarded_date                  => l_awarded_date
  ,p_fee                           => p_fee
  ,p_fee_currency                  => p_fee_currency
  ,p_training_completed_amount     => p_training_completed_amount
  ,p_reimbursement_arrangements    => p_reimbursement_arrangements
  ,p_training_completed_units      => p_training_completed_units
  ,p_total_training_amount         => p_total_training_amount
  ,p_start_date                    => l_start_date
  ,p_end_date                      => l_end_date
  ,p_license_number                => p_license_number
  ,p_expiry_date                   => l_expiry_date
  ,p_license_restrictions          => p_license_restrictions
  ,p_projected_completion_date     => l_projected_completion_date
  ,p_awarding_body                 => p_awarding_body
  ,p_tuition_method                => p_tuition_method
  ,p_group_ranking                 => p_group_ranking
  ,p_comments                      => p_comments
  ,p_attendance_id                 => p_attendance_id
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
  ,p_qua_information_category      => p_qua_information_category
  ,p_qua_information1              => p_qua_information1
  ,p_qua_information2              => p_qua_information2
  ,p_qua_information3              => p_qua_information3
  ,p_qua_information4              => p_qua_information4
  ,p_qua_information5              => p_qua_information5
  ,p_qua_information6              => p_qua_information6
  ,p_qua_information7              => p_qua_information7
  ,p_qua_information8              => p_qua_information8
  ,p_qua_information9              => p_qua_information9
  ,p_qua_information10             => p_qua_information10
  ,p_qua_information11             => p_qua_information11
  ,p_qua_information12             => p_qua_information12
  ,p_qua_information13             => p_qua_information13
  ,p_qua_information14             => p_qua_information14
  ,p_qua_information15             => p_qua_information15
  ,p_qua_information16             => p_qua_information16
  ,p_qua_information17             => p_qua_information17
  ,p_qua_information18             => p_qua_information18
  ,p_qua_information19             => p_qua_information19
  ,p_qua_information20             => p_qua_information20
  ,p_professional_body_name        => p_professional_body_name
  ,p_membership_number             => p_membership_number
  ,p_membership_category           => p_membership_category
  ,p_subscription_payment_method   => p_subscription_payment_method
  ,p_object_version_number         => l_object_version_number
  ,p_language_code                 => l_language_code);
  exception
    when hr_Api.cannot_find_prog_unit then
      hr_Api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_QUALIFICATION'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_Api.validate_enabled;
  end if;
  --
  -- Set all output arguements
  --
  p_object_version_number  := l_object_version_number;
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_Api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to UPDATE_QUALIFICATION;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_object_version_number    := l_temp_ovn;
    rollback to UPDATE_QUALIFICATION;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end UPDATE_QUALIFICATION;

--
-- ----------------------------------------------------------------------------
-- |--------------------------<DELETE_QUALIFICATION>--------------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_QUALIFICATION
  (p_validate                      in     boolean  default false
  ,p_qualification_id              in     number
  ,p_object_version_number         in     number
  ) is

  CURSOR get_person_info IS
  select person_id
  from PER_QUALIFICATIONS
  where QUALIFICATION_ID = p_qualification_id;
  --
  -- Declare cursors and local variables
  --
  l_proc                      varchar2(72) := g_package||'delete_qualification';
  l_object_version_number     number(9) := p_object_version_number;

   l_person_id number := -1;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);

   OPEN get_person_info;
   FETCH get_person_info INTO l_person_id;
   CLOSE get_person_info;
  --
  -- Issue a savepoint
  --
  savepoint DELETE_QUALIFICATION;
  --
  -- Call Before Process User Hook
  --
  begin
   PER_QUALIFICATIONS_BK3.DELETE_QUALIFICATION_B
  (p_qualification_id              => p_qualification_id
  ,p_object_version_number         => p_object_version_number
  );
  exception
    when hr_Api.cannot_find_prog_unit then
      hr_Api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_QUALIFICATION'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- MLS Processing
  --
  per_qat_del.del_tl
  (p_qualification_id              => p_qualification_id
  );

  --
  -- Process Logic
  --
  per_qua_del.del
  (p_validate                      => false
  ,p_qualification_id              => p_qualification_id
  ,p_object_version_number         => p_object_version_number
  );

  --
  -- Call After Process User Hook
  --
  begin
  PER_QUALIFICATIONS_BK3.DELETE_QUALIFICATION_A
  (p_qualification_id              => p_qualification_id
  ,p_object_version_number         => p_object_version_number
  ,p_person_id                     => l_person_id
  );
  exception
    when hr_Api.cannot_find_prog_unit then
      hr_Api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_QUALIFICATION'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_Api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_Api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to DELETE_QUALIFICATION;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to DELETE_QUALIFICATION;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end DELETE_QUALIFICATION;

end PER_QUALIFICATIONS_API;

/
