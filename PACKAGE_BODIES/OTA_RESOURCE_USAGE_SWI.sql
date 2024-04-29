--------------------------------------------------------
--  DDL for Package Body OTA_RESOURCE_USAGE_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_RESOURCE_USAGE_SWI" As
/* $Header: otrudswi.pkb 115.1 2003/12/30 19:14 asud noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'ota_resource_usage_swi.';
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_resource >---------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_resource
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_activity_version_id          in     number    default null
  ,p_required_flag                in     varchar2
  ,p_start_date                   in     date
  ,p_supplied_resource_id         in     number    default null
  ,p_comments                     in     varchar2  default null
  ,p_end_date                     in     date      default null
  ,p_quantity                     in     number    default null
  ,p_resource_type                in     varchar2  default null
  ,p_role_to_play                 in     varchar2  default null
  ,p_usage_reason                 in     varchar2  default null
  ,p_rud_information_category     in     varchar2  default null
  ,p_rud_information1             in     varchar2  default null
  ,p_rud_information2             in     varchar2  default null
  ,p_rud_information3             in     varchar2  default null
  ,p_rud_information4             in     varchar2  default null
  ,p_rud_information5             in     varchar2  default null
  ,p_rud_information6             in     varchar2  default null
  ,p_rud_information7             in     varchar2  default null
  ,p_rud_information8             in     varchar2  default null
  ,p_rud_information9             in     varchar2  default null
  ,p_rud_information10            in     varchar2  default null
  ,p_rud_information11            in     varchar2  default null
  ,p_rud_information12            in     varchar2  default null
  ,p_rud_information13            in     varchar2  default null
  ,p_rud_information14            in     varchar2  default null
  ,p_rud_information15            in     varchar2  default null
  ,p_rud_information16            in     varchar2  default null
  ,p_rud_information17            in     varchar2  default null
  ,p_rud_information18            in     varchar2  default null
  ,p_rud_information19            in     varchar2  default null
  ,p_rud_information20            in     varchar2  default null
  ,p_resource_usage_id            in     number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  ,p_offering_id                  in     number    default null
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_resource_usage_id            number;
  l_proc    varchar2(72) := g_package ||'create_resource';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_resource_swi;
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
  ota_rud_ins.set_base_key_value
    (p_resource_usage_id => p_resource_usage_id
    );
  --
  -- Call API
  --
  ota_resource_usage_api.create_resource
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_activity_version_id          => p_activity_version_id
    ,p_required_flag                => p_required_flag
    ,p_start_date                   => p_start_date
    ,p_supplied_resource_id         => p_supplied_resource_id
    ,p_comments                     => p_comments
    ,p_end_date                     => p_end_date
    ,p_quantity                     => p_quantity
    ,p_resource_type                => p_resource_type
    ,p_role_to_play                 => p_role_to_play
    ,p_usage_reason                 => p_usage_reason
    ,p_rud_information_category     => p_rud_information_category
    ,p_rud_information1             => p_rud_information1
    ,p_rud_information2             => p_rud_information2
    ,p_rud_information3             => p_rud_information3
    ,p_rud_information4             => p_rud_information4
    ,p_rud_information5             => p_rud_information5
    ,p_rud_information6             => p_rud_information6
    ,p_rud_information7             => p_rud_information7
    ,p_rud_information8             => p_rud_information8
    ,p_rud_information9             => p_rud_information9
    ,p_rud_information10            => p_rud_information10
    ,p_rud_information11            => p_rud_information11
    ,p_rud_information12            => p_rud_information12
    ,p_rud_information13            => p_rud_information13
    ,p_rud_information14            => p_rud_information14
    ,p_rud_information15            => p_rud_information15
    ,p_rud_information16            => p_rud_information16
    ,p_rud_information17            => p_rud_information17
    ,p_rud_information18            => p_rud_information18
    ,p_rud_information19            => p_rud_information19
    ,p_rud_information20            => p_rud_information20
    ,p_resource_usage_id            => l_resource_usage_id
    ,p_object_version_number        => p_object_version_number
    ,p_offering_id                  => p_offering_id
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
    rollback to create_resource_swi;
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
    rollback to create_resource_swi;
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
end create_resource;
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_resource >---------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_resource
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_resource_usage_id            in     number
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
  l_proc    varchar2(72) := g_package ||'delete_resource';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_resource_swi;
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
  ota_resource_usage_api.delete_resource
    (p_validate                     => l_validate
    ,p_resource_usage_id            => p_resource_usage_id
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
    rollback to delete_resource_swi;
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
    rollback to delete_resource_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_resource;
-- ----------------------------------------------------------------------------
-- |----------------------------< update_resource >---------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_resource
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_resource_usage_id            in     number
  ,p_object_version_number        in out nocopy number
  ,p_activity_version_id          in     number    default hr_api.g_number
  ,p_required_flag                in     varchar2  default hr_api.g_varchar2
  ,p_start_date                   in     date      default hr_api.g_date
  ,p_supplied_resource_id         in     number    default hr_api.g_number
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_end_date                     in     date      default hr_api.g_date
  ,p_quantity                     in     number    default hr_api.g_number
  ,p_resource_type                in     varchar2  default hr_api.g_varchar2
  ,p_role_to_play                 in     varchar2  default hr_api.g_varchar2
  ,p_usage_reason                 in     varchar2  default hr_api.g_varchar2
  ,p_rud_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_rud_information1             in     varchar2  default hr_api.g_varchar2
  ,p_rud_information2             in     varchar2  default hr_api.g_varchar2
  ,p_rud_information3             in     varchar2  default hr_api.g_varchar2
  ,p_rud_information4             in     varchar2  default hr_api.g_varchar2
  ,p_rud_information5             in     varchar2  default hr_api.g_varchar2
  ,p_rud_information6             in     varchar2  default hr_api.g_varchar2
  ,p_rud_information7             in     varchar2  default hr_api.g_varchar2
  ,p_rud_information8             in     varchar2  default hr_api.g_varchar2
  ,p_rud_information9             in     varchar2  default hr_api.g_varchar2
  ,p_rud_information10            in     varchar2  default hr_api.g_varchar2
  ,p_rud_information11            in     varchar2  default hr_api.g_varchar2
  ,p_rud_information12            in     varchar2  default hr_api.g_varchar2
  ,p_rud_information13            in     varchar2  default hr_api.g_varchar2
  ,p_rud_information14            in     varchar2  default hr_api.g_varchar2
  ,p_rud_information15            in     varchar2  default hr_api.g_varchar2
  ,p_rud_information16            in     varchar2  default hr_api.g_varchar2
  ,p_rud_information17            in     varchar2  default hr_api.g_varchar2
  ,p_rud_information18            in     varchar2  default hr_api.g_varchar2
  ,p_rud_information19            in     varchar2  default hr_api.g_varchar2
  ,p_rud_information20            in     varchar2  default hr_api.g_varchar2
  ,p_return_status                   out nocopy varchar2
  ,p_offering_id                  in     number    default hr_api.g_number
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_resource';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_resource_swi;
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
  ota_resource_usage_api.update_resource
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_resource_usage_id            => p_resource_usage_id
    ,p_object_version_number        => p_object_version_number
    ,p_activity_version_id          => p_activity_version_id
    ,p_required_flag                => p_required_flag
    ,p_start_date                   => p_start_date
    ,p_supplied_resource_id         => p_supplied_resource_id
    ,p_comments                     => p_comments
    ,p_end_date                     => p_end_date
    ,p_quantity                     => p_quantity
    ,p_resource_type                => p_resource_type
    ,p_role_to_play                 => p_role_to_play
    ,p_usage_reason                 => p_usage_reason
    ,p_rud_information_category     => p_rud_information_category
    ,p_rud_information1             => p_rud_information1
    ,p_rud_information2             => p_rud_information2
    ,p_rud_information3             => p_rud_information3
    ,p_rud_information4             => p_rud_information4
    ,p_rud_information5             => p_rud_information5
    ,p_rud_information6             => p_rud_information6
    ,p_rud_information7             => p_rud_information7
    ,p_rud_information8             => p_rud_information8
    ,p_rud_information9             => p_rud_information9
    ,p_rud_information10            => p_rud_information10
    ,p_rud_information11            => p_rud_information11
    ,p_rud_information12            => p_rud_information12
    ,p_rud_information13            => p_rud_information13
    ,p_rud_information14            => p_rud_information14
    ,p_rud_information15            => p_rud_information15
    ,p_rud_information16            => p_rud_information16
    ,p_rud_information17            => p_rud_information17
    ,p_rud_information18            => p_rud_information18
    ,p_rud_information19            => p_rud_information19
    ,p_rud_information20            => p_rud_information20
    ,p_offering_id                  => p_offering_id
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
    rollback to update_resource_swi;
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
    rollback to update_resource_swi;
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
end update_resource;
end ota_resource_usage_swi;

/
