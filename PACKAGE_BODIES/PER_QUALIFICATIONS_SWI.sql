--------------------------------------------------------
--  DDL for Package Body PER_QUALIFICATIONS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_QUALIFICATIONS_SWI" As
/* $Header: pequaswi.pkb 115.2 2002/12/05 17:24:46 eumenyio ship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'per_qualifications_swi.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_qualification >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_qualification
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_qualification_type_id        in     number
  ,p_business_group_id            in     number    default null
  ,p_person_id                    in     number    default null
  ,p_title                        in     varchar2  default null
  ,p_grade_attained               in     varchar2  default null
  ,p_status                       in     varchar2  default null
  ,p_awarded_date                 in     date      default null
  ,p_fee                          in     number    default null
  ,p_fee_currency                 in     varchar2  default null
  ,p_training_completed_amount    in     number    default null
  ,p_reimbursement_arrangements   in     varchar2  default null
  ,p_training_completed_units     in     varchar2  default null
  ,p_total_training_amount        in     number    default null
  ,p_start_date                   in     date      default null
  ,p_end_date                     in     date      default null
  ,p_license_number               in     varchar2  default null
  ,p_expiry_date                  in     date      default null
  ,p_license_restrictions         in     varchar2  default null
  ,p_projected_completion_date    in     date      default null
  ,p_awarding_body                in     varchar2  default null
  ,p_tuition_method               in     varchar2  default null
  ,p_group_ranking                in     varchar2  default null
  ,p_comments                     in     varchar2  default null
  ,p_attendance_id                in     number    default null
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
  ,p_party_id                     in     number    default null
  ,p_qua_information_category     in     varchar2  default null
  ,p_qua_information1             in     varchar2  default null
  ,p_qua_information2             in     varchar2  default null
  ,p_qua_information3             in     varchar2  default null
  ,p_qua_information4             in     varchar2  default null
  ,p_qua_information5             in     varchar2  default null
  ,p_qua_information6             in     varchar2  default null
  ,p_qua_information7             in     varchar2  default null
  ,p_qua_information8             in     varchar2  default null
  ,p_qua_information9             in     varchar2  default null
  ,p_qua_information10            in     varchar2  default null
  ,p_qua_information11            in     varchar2  default null
  ,p_qua_information12            in     varchar2  default null
  ,p_qua_information13            in     varchar2  default null
  ,p_qua_information14            in     varchar2  default null
  ,p_qua_information15            in     varchar2  default null
  ,p_qua_information16            in     varchar2  default null
  ,p_qua_information17            in     varchar2  default null
  ,p_qua_information18            in     varchar2  default null
  ,p_qua_information19            in     varchar2  default null
  ,p_qua_information20            in     varchar2  default null
  ,p_professional_body_name       in     varchar2  default null
  ,p_membership_number            in     varchar2  default null
  ,p_membership_category          in     varchar2  default null
  ,p_subscription_payment_method  in     varchar2  default null
  ,p_qualification_id             in     number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_qualification_id             number;
  l_proc    varchar2(72) := g_package ||'create_qualification';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_qualification_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => p_validate);
  --
  -- Register Surrogate ID or user key values
  --
  per_qua_ins.set_base_key_value
    (p_qualification_id => p_qualification_id
    );
  --
  -- Call API
  --
  per_qualifications_api.create_qualification
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_qualification_type_id        => p_qualification_type_id
    ,p_business_group_id            => p_business_group_id
    ,p_person_id                    => p_person_id
    ,p_title                        => p_title
    ,p_grade_attained               => p_grade_attained
    ,p_status                       => p_status
    ,p_awarded_date                 => p_awarded_date
    ,p_fee                          => p_fee
    ,p_fee_currency                 => p_fee_currency
    ,p_training_completed_amount    => p_training_completed_amount
    ,p_reimbursement_arrangements   => p_reimbursement_arrangements
    ,p_training_completed_units     => p_training_completed_units
    ,p_total_training_amount        => p_total_training_amount
    ,p_start_date                   => p_start_date
    ,p_end_date                     => p_end_date
    ,p_license_number               => p_license_number
    ,p_expiry_date                  => p_expiry_date
    ,p_license_restrictions         => p_license_restrictions
    ,p_projected_completion_date    => p_projected_completion_date
    ,p_awarding_body                => p_awarding_body
    ,p_tuition_method               => p_tuition_method
    ,p_group_ranking                => p_group_ranking
    ,p_comments                     => p_comments
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
    ,p_party_id                     => p_party_id
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
    ,p_object_version_number        => p_object_version_number
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
    rollback to create_qualification_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := null;
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
    rollback to create_qualification_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_qualification;
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_qualification >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_qualification
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_qualification_id             in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'delete_qualification';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_qualification_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
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
  per_qualifications_api.delete_qualification
    (p_validate                     => l_validate
    ,p_qualification_id             => p_qualification_id
    ,p_object_version_number        => p_object_version_number
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
    rollback to delete_qualification_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
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
    rollback to delete_qualification_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_qualification;
-- ----------------------------------------------------------------------------
-- |-------------------------< update_qualification >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_qualification
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_qualification_id             in     number
  ,p_qualification_type_id        in     number    default hr_api.g_number
  ,p_title                        in     varchar2  default hr_api.g_varchar2
  ,p_grade_attained               in     varchar2  default hr_api.g_varchar2
  ,p_status                       in     varchar2  default hr_api.g_varchar2
  ,p_awarded_date                 in     date      default hr_api.g_date
  ,p_fee                          in     number    default hr_api.g_number
  ,p_fee_currency                 in     varchar2  default hr_api.g_varchar2
  ,p_training_completed_amount    in     number    default hr_api.g_number
  ,p_reimbursement_arrangements   in     varchar2  default hr_api.g_varchar2
  ,p_training_completed_units     in     varchar2  default hr_api.g_varchar2
  ,p_total_training_amount        in     number    default hr_api.g_number
  ,p_start_date                   in     date      default hr_api.g_date
  ,p_end_date                     in     date      default hr_api.g_date
  ,p_license_number               in     varchar2  default hr_api.g_varchar2
  ,p_expiry_date                  in     date      default hr_api.g_date
  ,p_license_restrictions         in     varchar2  default hr_api.g_varchar2
  ,p_projected_completion_date    in     date      default hr_api.g_date
  ,p_awarding_body                in     varchar2  default hr_api.g_varchar2
  ,p_tuition_method               in     varchar2  default hr_api.g_varchar2
  ,p_group_ranking                in     varchar2  default hr_api.g_varchar2
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_attendance_id                in     number    default hr_api.g_number
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
  ,p_qua_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_qua_information1             in     varchar2  default hr_api.g_varchar2
  ,p_qua_information2             in     varchar2  default hr_api.g_varchar2
  ,p_qua_information3             in     varchar2  default hr_api.g_varchar2
  ,p_qua_information4             in     varchar2  default hr_api.g_varchar2
  ,p_qua_information5             in     varchar2  default hr_api.g_varchar2
  ,p_qua_information6             in     varchar2  default hr_api.g_varchar2
  ,p_qua_information7             in     varchar2  default hr_api.g_varchar2
  ,p_qua_information8             in     varchar2  default hr_api.g_varchar2
  ,p_qua_information9             in     varchar2  default hr_api.g_varchar2
  ,p_qua_information10            in     varchar2  default hr_api.g_varchar2
  ,p_qua_information11            in     varchar2  default hr_api.g_varchar2
  ,p_qua_information12            in     varchar2  default hr_api.g_varchar2
  ,p_qua_information13            in     varchar2  default hr_api.g_varchar2
  ,p_qua_information14            in     varchar2  default hr_api.g_varchar2
  ,p_qua_information15            in     varchar2  default hr_api.g_varchar2
  ,p_qua_information16            in     varchar2  default hr_api.g_varchar2
  ,p_qua_information17            in     varchar2  default hr_api.g_varchar2
  ,p_qua_information18            in     varchar2  default hr_api.g_varchar2
  ,p_qua_information19            in     varchar2  default hr_api.g_varchar2
  ,p_qua_information20            in     varchar2  default hr_api.g_varchar2
  ,p_professional_body_name       in     varchar2  default hr_api.g_varchar2
  ,p_membership_number            in     varchar2  default hr_api.g_varchar2
  ,p_membership_category          in     varchar2  default hr_api.g_varchar2
  ,p_subscription_payment_method  in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_qualification';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_qualification_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  l_object_version_number         := p_object_version_number;
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
  per_qualifications_api.update_qualification
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_qualification_id             => p_qualification_id
    ,p_qualification_type_id        => p_qualification_type_id
    ,p_title                        => p_title
    ,p_grade_attained               => p_grade_attained
    ,p_status                       => p_status
    ,p_awarded_date                 => p_awarded_date
    ,p_fee                          => p_fee
    ,p_fee_currency                 => p_fee_currency
    ,p_training_completed_amount    => p_training_completed_amount
    ,p_reimbursement_arrangements   => p_reimbursement_arrangements
    ,p_training_completed_units     => p_training_completed_units
    ,p_total_training_amount        => p_total_training_amount
    ,p_start_date                   => p_start_date
    ,p_end_date                     => p_end_date
    ,p_license_number               => p_license_number
    ,p_expiry_date                  => p_expiry_date
    ,p_license_restrictions         => p_license_restrictions
    ,p_projected_completion_date    => p_projected_completion_date
    ,p_awarding_body                => p_awarding_body
    ,p_tuition_method               => p_tuition_method
    ,p_group_ranking                => p_group_ranking
    ,p_comments                     => p_comments
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
    ,p_object_version_number        => p_object_version_number
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
    rollback to update_qualification_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
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
    rollback to update_qualification_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end update_qualification;
end per_qualifications_swi;

/
