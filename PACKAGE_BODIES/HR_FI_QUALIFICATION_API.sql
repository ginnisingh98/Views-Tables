--------------------------------------------------------
--  DDL for Package Body HR_FI_QUALIFICATION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_FI_QUALIFICATION_API" as
/* $Header: pequafii.pkb 120.0 2005/05/31 16:20 appldev noship $ */
--
  g_package  varchar2(33) := 'hr_fi_qualification_api.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< CREATE_FI_QUALIFICATION >------------------------|
-- ----------------------------------------------------------------------------
procedure CREATE_FI_QUALIFICATION
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
  ,p_education_code                in     varchar2 default null
  ,p_preferred_level	     	   in    varchar2 default null
  ,p_professional_body_name        in     varchar2 default null
  ,p_membership_number             in     varchar2 default null
  ,p_membership_category           in     varchar2 default null
  ,p_subscription_payment_method   in     varchar2 default null
  ,p_qualification_id                 out nocopy number
  ,p_object_version_number            out nocopy number
  ) IS
    -- Declare cursors and local variables
    l_proc                 VARCHAR2(72) := g_package||'create_fi_qualification';
    l_legislation_code     VARCHAR2(2);
    l_territory_code       VARCHAR2(2);

    --
    CURSOR csr_leg_code IS
      SELECT    legislation_code
      FROM      per_business_groups pbg
      WHERE     pbg.business_group_id = p_business_group_id;
    --
  BEGIN
    hr_utility.set_location('Entering:'|| l_proc, 10);
    --
    -- Validation IN addition to Row Handlers
    --
    -- Check that the specified business group is valid.
    --
    OPEN    csr_leg_code;
    FETCH   csr_leg_code
    INTO    l_legislation_code;
    IF csr_leg_code%notfound THEN
      CLOSE csr_leg_code;
      hr_utility.set_message(801, 'HR_7208_API_BUS_GRP_INVALID');
      hr_utility.raise_error;
    END IF;
    CLOSE csr_leg_code;
    hr_utility.set_location(l_proc, 20);
    --
    -- Check that the legislation of the specified business group is 'FI'.
    --
    IF l_legislation_code <> 'FI' THEN
      hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
      hr_utility.set_message_token('LEG_CODE','FI');
      hr_utility.raise_error;
    END IF;
    hr_utility.set_location(l_proc, 30);
    --
    -- Call the person business process
    --
    per_qualifications_api.create_qualification
   (p_validate                      => p_validate
   ,p_effective_date                => p_effective_date
   ,p_qualification_type_id         => p_qualification_type_id
   ,p_language_code                 => p_language_code
   ,p_business_group_id             => p_business_group_id
   ,p_person_id                     => p_person_id
   ,p_title                         => p_title
   ,p_grade_attained                => p_grade_attained
   ,p_status                        => p_status
   ,p_awarded_date                  => p_awarded_date
   ,p_fee                           => p_fee
   ,p_fee_currency                  => p_fee_currency
   ,p_training_completed_amount     => p_training_completed_amount
   ,p_reimbursement_arrangements    => p_reimbursement_arrangements
   ,p_training_completed_units      => p_training_completed_units
   ,p_total_training_amount         => p_total_training_amount
   ,p_start_date                    => p_start_date
   ,p_end_date                      => p_end_date
   ,p_license_number                => p_license_number
   ,p_expiry_date                   => p_expiry_date
   ,p_license_restrictions          => p_license_restrictions
   ,p_projected_completion_date     => p_projected_completion_date
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
   ,p_party_id                      => p_party_id
   ,p_qua_information_category      => 'FI'
   ,p_qua_information1              => p_education_code
   ,p_qua_information2     	    => p_preferred_level
   ,p_professional_body_name        => p_professional_body_name
   ,p_membership_number             => p_membership_number
   ,p_membership_category           => p_membership_category
   ,p_subscription_payment_method   => p_subscription_payment_method
   ,p_qualification_id              => p_qualification_id
   ,p_object_version_number         => p_object_version_number
   );
    --
  hr_utility.set_location(' Leaving:'||l_proc, 40);
--
  end create_fi_qualification;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< UPDATE_FI_QUALIFICATION >------------------------|
-- ----------------------------------------------------------------------------
procedure UPDATE_FI_QUALIFICATION
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
  ,p_education_code                in     varchar2 default hr_api.g_varchar2
  ,p_preferred_level	     	   in     varchar2 default hr_api.g_varchar2
  ,p_professional_body_name        in     varchar2 default hr_api.g_varchar2
  ,p_membership_number             in     varchar2 default hr_api.g_varchar2
  ,p_membership_category           in     varchar2 default hr_api.g_varchar2
  ,p_subscription_payment_method   in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy number
  )  IS
    -- Declare cursors and local variables
    l_proc                 VARCHAR2(72) := g_package||'create_fi_qualification';
    l_legislation_code     VARCHAR2(2);
    l_territory_code       VARCHAR2(2);

    --
    cursor csr_leg_code is
    select pbg.legislation_code
    from per_business_groups_perf pbg
         , per_qualifications qua
     where qua.qualification_id = p_qualification_id
       and pbg.business_group_id (+) = qua.business_group_id;

    --
  BEGIN
    hr_utility.set_location('Entering:'|| l_proc, 10);
    --
    -- Validation IN addition to Row Handlers
    --
    -- Check that the specified business group is valid.
    --
    OPEN    csr_leg_code;
    FETCH   csr_leg_code
    INTO    l_legislation_code;
    IF csr_leg_code%notfound THEN
      CLOSE csr_leg_code;
      hr_utility.set_message(801, 'HR_7208_API_BUS_GRP_INVALID');
      hr_utility.raise_error;
    END IF;
    CLOSE csr_leg_code;
    hr_utility.set_location(l_proc, 20);
    --
    -- Check that the legislation of the specified business group is 'FI'.
    --
    IF l_legislation_code <> 'FI' THEN
      hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
      hr_utility.set_message_token('LEG_CODE','FI');
      hr_utility.raise_error;
    END IF;
    hr_utility.set_location(l_proc, 30);
    --
    -- Call the person business process
    --
    per_qualifications_api.update_qualification
   (p_validate                      => p_validate
   ,p_effective_date                => p_effective_date
   ,p_qualification_id              => p_qualification_id
   ,p_language_code                 => p_language_code
   ,p_qualification_type_id         => p_qualification_type_id
   ,p_title                         => p_title
   ,p_grade_attained                => p_grade_attained
   ,p_status                        => p_status
   ,p_awarded_date                  => p_awarded_date
   ,p_fee                           => p_fee
   ,p_fee_currency                  => p_fee_currency
   ,p_training_completed_amount     => p_training_completed_amount
   ,p_reimbursement_arrangements    => p_reimbursement_arrangements
   ,p_training_completed_units      => p_training_completed_units
   ,p_total_training_amount         => p_total_training_amount
   ,p_start_date                    => p_start_date
   ,p_end_date                      => p_end_date
   ,p_license_number                => p_license_number
   ,p_expiry_date                   => p_expiry_date
   ,p_license_restrictions          => p_license_restrictions
   ,p_projected_completion_date     => p_projected_completion_date
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
   ,p_qua_information_category      => 'FI'
   ,p_qua_information1              => p_education_code
   ,p_qua_information2     	    => p_preferred_level
   ,p_professional_body_name        => p_professional_body_name
   ,p_membership_number             => p_membership_number
   ,p_membership_category           => p_membership_category
   ,p_subscription_payment_method   => p_subscription_payment_method
   ,p_object_version_number         => p_object_version_number
   );
    --
  hr_utility.set_location(' Leaving:'||l_proc, 40);
   --
  end update_fi_qualification;


end hr_fi_qualification_api;

/
