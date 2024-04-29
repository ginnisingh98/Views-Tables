--------------------------------------------------------
--  DDL for Package Body OTA_ACTIVITY_CATEGORY_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_ACTIVITY_CATEGORY_SWI" As
/* $Header: otaciswi.pkb 115.1 2003/12/30 17:45:16 dhmulia noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'ota_activity_category_swi.';
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_act_cat_inclusion >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_act_cat_inclusion
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_activity_version_id          in     number
  ,p_activity_category            in     varchar2
  ,p_comments                     in     varchar2  default null
  ,p_object_version_number           out nocopy number
  ,p_aci_information_category     in     varchar2  default null
  ,p_aci_information1             in     varchar2  default null
  ,p_aci_information2             in     varchar2  default null
  ,p_aci_information3             in     varchar2  default null
  ,p_aci_information4             in     varchar2  default null
  ,p_aci_information5             in     varchar2  default null
  ,p_aci_information6             in     varchar2  default null
  ,p_aci_information7             in     varchar2  default null
  ,p_aci_information8             in     varchar2  default null
  ,p_aci_information9             in     varchar2  default null
  ,p_aci_information10            in     varchar2  default null
  ,p_aci_information11            in     varchar2  default null
  ,p_aci_information12            in     varchar2  default null
  ,p_aci_information13            in     varchar2  default null
  ,p_aci_information14            in     varchar2  default null
  ,p_aci_information15            in     varchar2  default null
  ,p_aci_information16            in     varchar2  default null
  ,p_aci_information17            in     varchar2  default null
  ,p_aci_information18            in     varchar2  default null
  ,p_aci_information19            in     varchar2  default null
  ,p_aci_information20            in     varchar2  default null
  ,p_start_date_active            in     date      default null
  ,p_end_date_active              in     date      default null
  ,p_primary_flag                 in     varchar2  default null
  ,p_category_usage_id            in     number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_activity_version_id          number;
  l_category_usage_id            number;
  l_proc    varchar2(72) := g_package ||'create_act_cat_inclusion';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_act_cat_inclusion_swi;
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
  ota_aci_ins.set_base_key_value
    (p_activity_version_id => p_activity_version_id
    ,p_category_usage_id => p_category_usage_id
    );
  --
  -- Call API
  --
  ota_activity_category_api.create_act_cat_inclusion
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_activity_version_id          => p_activity_version_id
    ,p_activity_category            => p_activity_category
    ,p_comments                     => p_comments
    ,p_object_version_number        => p_object_version_number
    ,p_aci_information_category     => p_aci_information_category
    ,p_aci_information1             => p_aci_information1
    ,p_aci_information2             => p_aci_information2
    ,p_aci_information3             => p_aci_information3
    ,p_aci_information4             => p_aci_information4
    ,p_aci_information5             => p_aci_information5
    ,p_aci_information6             => p_aci_information6
    ,p_aci_information7             => p_aci_information7
    ,p_aci_information8             => p_aci_information8
    ,p_aci_information9             => p_aci_information9
    ,p_aci_information10            => p_aci_information10
    ,p_aci_information11            => p_aci_information11
    ,p_aci_information12            => p_aci_information12
    ,p_aci_information13            => p_aci_information13
    ,p_aci_information14            => p_aci_information14
    ,p_aci_information15            => p_aci_information15
    ,p_aci_information16            => p_aci_information16
    ,p_aci_information17            => p_aci_information17
    ,p_aci_information18            => p_aci_information18
    ,p_aci_information19            => p_aci_information19
    ,p_aci_information20            => p_aci_information20
    ,p_start_date_active            => p_start_date_active
    ,p_end_date_active              => p_end_date_active
    ,p_primary_flag                 => p_primary_flag
    ,p_category_usage_id            => p_category_usage_id
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
    rollback to create_act_cat_inclusion_swi;
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
    rollback to create_act_cat_inclusion_swi;
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
end create_act_cat_inclusion;
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_act_cat_inclusion >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_act_cat_inclusion
  (p_activity_version_id          in     number
  ,p_category_usage_id            in     varchar2
  ,p_object_version_number        in     number
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'delete_act_cat_inclusion';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_act_cat_inclusion_swi;
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
  ota_activity_category_api.delete_act_cat_inclusion
    (p_activity_version_id          => p_activity_version_id
    ,p_category_usage_id            => p_category_usage_id
    ,p_object_version_number        => p_object_version_number
    ,p_validate                     => l_validate
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
    rollback to delete_act_cat_inclusion_swi;
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
    rollback to delete_act_cat_inclusion_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_act_cat_inclusion;
-- ----------------------------------------------------------------------------
-- |-----------------------< update_act_cat_inclusion >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_act_cat_inclusion
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_activity_version_id          in     number
  ,p_activity_category            in     varchar2
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_aci_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_aci_information1             in     varchar2  default hr_api.g_varchar2
  ,p_aci_information2             in     varchar2  default hr_api.g_varchar2
  ,p_aci_information3             in     varchar2  default hr_api.g_varchar2
  ,p_aci_information4             in     varchar2  default hr_api.g_varchar2
  ,p_aci_information5             in     varchar2  default hr_api.g_varchar2
  ,p_aci_information6             in     varchar2  default hr_api.g_varchar2
  ,p_aci_information7             in     varchar2  default hr_api.g_varchar2
  ,p_aci_information8             in     varchar2  default hr_api.g_varchar2
  ,p_aci_information9             in     varchar2  default hr_api.g_varchar2
  ,p_aci_information10            in     varchar2  default hr_api.g_varchar2
  ,p_aci_information11            in     varchar2  default hr_api.g_varchar2
  ,p_aci_information12            in     varchar2  default hr_api.g_varchar2
  ,p_aci_information13            in     varchar2  default hr_api.g_varchar2
  ,p_aci_information14            in     varchar2  default hr_api.g_varchar2
  ,p_aci_information15            in     varchar2  default hr_api.g_varchar2
  ,p_aci_information16            in     varchar2  default hr_api.g_varchar2
  ,p_aci_information17            in     varchar2  default hr_api.g_varchar2
  ,p_aci_information18            in     varchar2  default hr_api.g_varchar2
  ,p_aci_information19            in     varchar2  default hr_api.g_varchar2
  ,p_aci_information20            in     varchar2  default hr_api.g_varchar2
  ,p_start_date_active            in     date      default hr_api.g_date
  ,p_end_date_active              in     date      default hr_api.g_date
  ,p_primary_flag                 in     varchar2  default hr_api.g_varchar2
  ,p_category_usage_id            in     number
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
  l_proc    varchar2(72) := g_package ||'update_act_cat_inclusion';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_act_cat_inclusion_swi;
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
  ota_activity_category_api.update_act_cat_inclusion
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_activity_version_id          => p_activity_version_id
    ,p_activity_category            => p_activity_category
    ,p_comments                     => p_comments
    ,p_object_version_number        => p_object_version_number
    ,p_aci_information_category     => p_aci_information_category
    ,p_aci_information1             => p_aci_information1
    ,p_aci_information2             => p_aci_information2
    ,p_aci_information3             => p_aci_information3
    ,p_aci_information4             => p_aci_information4
    ,p_aci_information5             => p_aci_information5
    ,p_aci_information6             => p_aci_information6
    ,p_aci_information7             => p_aci_information7
    ,p_aci_information8             => p_aci_information8
    ,p_aci_information9             => p_aci_information9
    ,p_aci_information10            => p_aci_information10
    ,p_aci_information11            => p_aci_information11
    ,p_aci_information12            => p_aci_information12
    ,p_aci_information13            => p_aci_information13
    ,p_aci_information14            => p_aci_information14
    ,p_aci_information15            => p_aci_information15
    ,p_aci_information16            => p_aci_information16
    ,p_aci_information17            => p_aci_information17
    ,p_aci_information18            => p_aci_information18
    ,p_aci_information19            => p_aci_information19
    ,p_aci_information20            => p_aci_information20
    ,p_start_date_active            => p_start_date_active
    ,p_end_date_active              => p_end_date_active
    ,p_primary_flag                 => p_primary_flag
    ,p_category_usage_id            => p_category_usage_id
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
    rollback to update_act_cat_inclusion_swi;
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
    rollback to update_act_cat_inclusion_swi;
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
end update_act_cat_inclusion;
-- ----------------------------------------------------------------------------
-- |------------------------< validate_delete_aci >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE validate_delete_aci
  (p_activity_version_id          in     number
  ,p_category_usage_id          in     number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'validate_delete_aci';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint validate_delete_aci_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  --
  --
  -- Call API
  --
  ota_aci_bus.check_if_primary_category( p_activity_version_id
                                        ,p_category_usage_id);

  --
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
    rollback to validate_delete_aci_swi;
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
    rollback to validate_delete_aci_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end validate_delete_aci;

end ota_activity_category_swi;

/
