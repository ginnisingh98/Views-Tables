--------------------------------------------------------
--  DDL for Package Body OTA_EXTERNAL_LEARNING_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_EXTERNAL_LEARNING_SWI" As
/* $Header: otnhsswi.pkb 120.1 2006/01/09 03:20 dbatra noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'ota_external_learning_swi.';
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_external_learning >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_external_learning
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_nota_history_id              in     number
  ,p_person_id                    in     number
  ,p_contact_id                   in     number    default null
  ,p_trng_title                   in     varchar2
  ,p_provider                     in     varchar2
  ,p_type                         in     varchar2  default null
  ,p_centre                       in     varchar2  default null
  ,p_completion_date              in     date
  ,p_award                        in     varchar2  default null
  ,p_rating                       in     varchar2  default null
  ,p_duration                     in     number    default null
  ,p_duration_units               in     varchar2  default null
  ,p_activity_version_id          in     number    default null
  ,p_status                       in     varchar2  default null
  ,p_verified_by_id               in     number    default null
  ,p_nth_information_category     in     varchar2  default null
  ,p_nth_information1             in     varchar2  default null
  ,p_nth_information2             in     varchar2  default null
  ,p_nth_information3             in     varchar2  default null
  ,p_nth_information4             in     varchar2  default null
  ,p_nth_information5             in     varchar2  default null
  ,p_nth_information6             in     varchar2  default null
  ,p_nth_information7             in     varchar2  default null
  ,p_nth_information8             in     varchar2  default null
  ,p_nth_information9             in     varchar2  default null
  ,p_nth_information10            in     varchar2  default null
  ,p_nth_information11            in     varchar2  default null
  ,p_nth_information12            in     varchar2  default null
  ,p_nth_information13            in     varchar2  default null
  ,p_nth_information15            in     varchar2  default null
  ,p_nth_information16            in     varchar2  default null
  ,p_nth_information17            in     varchar2  default null
  ,p_nth_information18            in     varchar2  default null
  ,p_nth_information19            in     varchar2  default null
  ,p_nth_information20            in     varchar2  default null
  ,p_org_id                       in     number    default null
  ,p_object_version_number           out nocopy number
  ,p_business_group_id            in     number
  ,p_nth_information14            in     varchar2  default null
  ,p_customer_id                  in     number    default null
  ,p_organization_id              in     number    default null
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  l_some_warning                  boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_nota_history_id number;
  l_proc    varchar2(72) := g_package ||'create_external_learning';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_external_learning_swi;
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
  ota_nhs_ins.set_base_key_value
      (p_nota_history_id => p_nota_history_id
    );
  --
  -- Call API
  --
  ota_nhs_api.create_non_ota_histories
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_nota_history_id              => l_nota_history_id
    ,p_person_id                    => p_person_id
    ,p_contact_id                   => p_contact_id
    ,p_trng_title                   => p_trng_title
    ,p_provider                     => p_provider
    ,p_type                         => p_type
    ,p_centre                       => p_centre
    ,p_completion_date              => p_completion_date
    ,p_award                        => p_award
    ,p_rating                       => p_rating
    ,p_duration                     => p_duration
    ,p_duration_units               => p_duration_units
    ,p_activity_version_id          => p_activity_version_id
    ,p_status                       => p_status
    ,p_verified_by_id               => p_verified_by_id
    ,p_nth_information_category     => p_nth_information_category
    ,p_nth_information1             => p_nth_information1
    ,p_nth_information2             => p_nth_information2
    ,p_nth_information3             => p_nth_information3
    ,p_nth_information4             => p_nth_information4
    ,p_nth_information5             => p_nth_information5
    ,p_nth_information6             => p_nth_information6
    ,p_nth_information7             => p_nth_information7
    ,p_nth_information8             => p_nth_information8
    ,p_nth_information9             => p_nth_information9
    ,p_nth_information10            => p_nth_information10
    ,p_nth_information11            => p_nth_information11
    ,p_nth_information12            => p_nth_information12
    ,p_nth_information13            => p_nth_information13
    ,p_nth_information15            => p_nth_information15
    ,p_nth_information16            => p_nth_information16
    ,p_nth_information17            => p_nth_information17
    ,p_nth_information18            => p_nth_information18
    ,p_nth_information19            => p_nth_information19
    ,p_nth_information20            => p_nth_information20
    ,p_org_id                       => p_org_id
    ,p_object_version_number        => p_object_version_number
    ,p_business_group_id            => p_business_group_id
    ,p_nth_information14            => p_nth_information14
    ,p_customer_id                  => p_customer_id
    ,p_organization_id              => p_organization_id
    ,p_some_warning                 => l_some_warning
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
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
    rollback to create_external_learning_swi;
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
    rollback to create_external_learning_swi;
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
end create_external_learning;
-- ----------------------------------------------------------------------------
-- |-----------------------< update_external_learning >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_external_learning
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_nota_history_id              in     number
  ,p_person_id                    in     number
  ,p_contact_id                   in     number    default hr_api.g_number
  ,p_trng_title                   in     varchar2
  ,p_provider                     in     varchar2
  ,p_type                         in     varchar2  default hr_api.g_varchar2
  ,p_centre                       in     varchar2  default hr_api.g_varchar2
  ,p_completion_date              in     date
  ,p_award                        in     varchar2  default hr_api.g_varchar2
  ,p_rating                       in     varchar2  default hr_api.g_varchar2
  ,p_duration                     in     number    default hr_api.g_number
  ,p_duration_units               in     varchar2  default hr_api.g_varchar2
  ,p_activity_version_id          in     number    default hr_api.g_number
  ,p_status                       in     varchar2  default hr_api.g_varchar2
  ,p_verified_by_id               in     number    default hr_api.g_number
  ,p_nth_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_nth_information1             in     varchar2  default hr_api.g_varchar2
  ,p_nth_information2             in     varchar2  default hr_api.g_varchar2
  ,p_nth_information3             in     varchar2  default hr_api.g_varchar2
  ,p_nth_information4             in     varchar2  default hr_api.g_varchar2
  ,p_nth_information5             in     varchar2  default hr_api.g_varchar2
  ,p_nth_information6             in     varchar2  default hr_api.g_varchar2
  ,p_nth_information7             in     varchar2  default hr_api.g_varchar2
  ,p_nth_information8             in     varchar2  default hr_api.g_varchar2
  ,p_nth_information9             in     varchar2  default hr_api.g_varchar2
  ,p_nth_information10            in     varchar2  default hr_api.g_varchar2
  ,p_nth_information11            in     varchar2  default hr_api.g_varchar2
  ,p_nth_information12            in     varchar2  default hr_api.g_varchar2
  ,p_nth_information13            in     varchar2  default hr_api.g_varchar2
  ,p_nth_information15            in     varchar2  default hr_api.g_varchar2
  ,p_nth_information16            in     varchar2  default hr_api.g_varchar2
  ,p_nth_information17            in     varchar2  default hr_api.g_varchar2
  ,p_nth_information18            in     varchar2  default hr_api.g_varchar2
  ,p_nth_information19            in     varchar2  default hr_api.g_varchar2
  ,p_nth_information20            in     varchar2  default hr_api.g_varchar2
  ,p_org_id                       in     number    default hr_api.g_number
  ,p_object_version_number        in out nocopy number
  ,p_business_group_id            in     number
  ,p_nth_information14            in     varchar2  default hr_api.g_varchar2
  ,p_customer_id                  in     number    default hr_api.g_number
  ,p_organization_id              in     number    default hr_api.g_number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  l_some_warning                  boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_external_learning';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_external_learning_swi;
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
  ota_nhs_api.update_non_ota_histories
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_nota_history_id              => p_nota_history_id
    ,p_person_id                    => p_person_id
    ,p_contact_id                   => p_contact_id
    ,p_trng_title                   => p_trng_title
    ,p_provider                     => p_provider
    ,p_type                         => p_type
    ,p_centre                       => p_centre
    ,p_completion_date              => p_completion_date
    ,p_award                        => p_award
    ,p_rating                       => p_rating
    ,p_duration                     => p_duration
    ,p_duration_units               => p_duration_units
    ,p_activity_version_id          => p_activity_version_id
    ,p_status                       => p_status
    ,p_verified_by_id               => p_verified_by_id
    ,p_nth_information_category     => p_nth_information_category
    ,p_nth_information1             => p_nth_information1
    ,p_nth_information2             => p_nth_information2
    ,p_nth_information3             => p_nth_information3
    ,p_nth_information4             => p_nth_information4
    ,p_nth_information5             => p_nth_information5
    ,p_nth_information6             => p_nth_information6
    ,p_nth_information7             => p_nth_information7
    ,p_nth_information8             => p_nth_information8
    ,p_nth_information9             => p_nth_information9
    ,p_nth_information10            => p_nth_information10
    ,p_nth_information11            => p_nth_information11
    ,p_nth_information12            => p_nth_information12
    ,p_nth_information13            => p_nth_information13
    ,p_nth_information15            => p_nth_information15
    ,p_nth_information16            => p_nth_information16
    ,p_nth_information17            => p_nth_information17
    ,p_nth_information18            => p_nth_information18
    ,p_nth_information19            => p_nth_information19
    ,p_nth_information20            => p_nth_information20
    ,p_org_id                       => p_org_id
    ,p_object_version_number        => p_object_version_number
    ,p_business_group_id            => p_business_group_id
    ,p_nth_information14            => p_nth_information14
    ,p_customer_id                  => p_customer_id
    ,p_organization_id              => p_organization_id
    ,p_some_warning                 => l_some_warning
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
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
    rollback to update_external_learning_swi;
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
    rollback to update_external_learning_swi;
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
end update_external_learning;
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_external_learning >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_external_learning
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_nota_history_id              in     number
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
  l_proc    varchar2(72) := g_package ||'delete_external_learning';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_external_learning_swi;
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
  ota_nhs_api.delete_external_learning
    (p_validate                     => l_validate
    ,p_nota_history_id              => p_nota_history_id
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
    rollback to delete_external_learning_swi;
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
    rollback to delete_external_learning_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_external_learning;
end ota_external_learning_swi;

/
