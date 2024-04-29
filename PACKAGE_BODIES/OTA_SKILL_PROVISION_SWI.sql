--------------------------------------------------------
--  DDL for Package Body OTA_SKILL_PROVISION_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_SKILL_PROVISION_SWI" As
/* $Header: ottspswi.pkb 115.0 2003/12/31 00:49 arkashya noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'ota_skill_provision_swi.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_skill_provision >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_skill_provision
  (p_skill_provision_id           in     number
  ,p_activity_version_id          in     number
  ,p_object_version_number           out nocopy number
  ,p_type                         in     varchar2
  ,p_comments                     in     varchar2  default null
  ,p_tsp_information_category     in     varchar2  default null
  ,p_tsp_information1             in     varchar2  default null
  ,p_tsp_information2             in     varchar2  default null
  ,p_tsp_information3             in     varchar2  default null
  ,p_tsp_information4             in     varchar2  default null
  ,p_tsp_information5             in     varchar2  default null
  ,p_tsp_information6             in     varchar2  default null
  ,p_tsp_information7             in     varchar2  default null
  ,p_tsp_information8             in     varchar2  default null
  ,p_tsp_information9             in     varchar2  default null
  ,p_tsp_information10            in     varchar2  default null
  ,p_tsp_information11            in     varchar2  default null
  ,p_tsp_information12            in     varchar2  default null
  ,p_tsp_information13            in     varchar2  default null
  ,p_tsp_information14            in     varchar2  default null
  ,p_tsp_information15            in     varchar2  default null
  ,p_tsp_information16            in     varchar2  default null
  ,p_tsp_information17            in     varchar2  default null
  ,p_tsp_information18            in     varchar2  default null
  ,p_tsp_information19            in     varchar2  default null
  ,p_tsp_information20            in     varchar2  default null
  ,p_analysis_criteria_id         in     number
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
  l_skill_provision_id           number;
  l_proc    varchar2(72) := g_package ||'create_skill_provision';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_skill_provision_swi;
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
  ota_tsp_ins.set_base_key_value
    (p_skill_provision_id => p_skill_provision_id
    );
  --
  -- Call API
  --
  ota_skill_provision_api.create_skill_provision
    (p_skill_provision_id           => l_skill_provision_id
    ,p_activity_version_id          => p_activity_version_id
    ,p_object_version_number        => p_object_version_number
    ,p_type                         => p_type
    ,p_comments                     => p_comments
    ,p_tsp_information_category     => p_tsp_information_category
    ,p_tsp_information1             => p_tsp_information1
    ,p_tsp_information2             => p_tsp_information2
    ,p_tsp_information3             => p_tsp_information3
    ,p_tsp_information4             => p_tsp_information4
    ,p_tsp_information5             => p_tsp_information5
    ,p_tsp_information6             => p_tsp_information6
    ,p_tsp_information7             => p_tsp_information7
    ,p_tsp_information8             => p_tsp_information8
    ,p_tsp_information9             => p_tsp_information9
    ,p_tsp_information10            => p_tsp_information10
    ,p_tsp_information11            => p_tsp_information11
    ,p_tsp_information12            => p_tsp_information12
    ,p_tsp_information13            => p_tsp_information13
    ,p_tsp_information14            => p_tsp_information14
    ,p_tsp_information15            => p_tsp_information15
    ,p_tsp_information16            => p_tsp_information16
    ,p_tsp_information17            => p_tsp_information17
    ,p_tsp_information18            => p_tsp_information18
    ,p_tsp_information19            => p_tsp_information19
    ,p_tsp_information20            => p_tsp_information20
    ,p_analysis_criteria_id         => p_analysis_criteria_id
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
    rollback to create_skill_provision_swi;
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
    rollback to create_skill_provision_swi;
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
end create_skill_provision;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_skill_provision >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_skill_provision
  (p_skill_provision_id           in     number
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
  l_proc    varchar2(72) := g_package ||'delete_skill_provision';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_skill_provision_swi;
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
  ota_skill_provision_api.delete_skill_provision
    (p_skill_provision_id           => p_skill_provision_id
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
    rollback to delete_skill_provision_swi;
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
    rollback to delete_skill_provision_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_skill_provision;
-- ----------------------------------------------------------------------------
-- |------------------------< update_skill_provision >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_skill_provision
  (p_skill_provision_id           in     number
  ,p_activity_version_id          in     number    default hr_api.g_number
  ,p_object_version_number        in out nocopy number
  ,p_type                         in     varchar2  default hr_api.g_varchar2
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_tsp_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_tsp_information1             in     varchar2  default hr_api.g_varchar2
  ,p_tsp_information2             in     varchar2  default hr_api.g_varchar2
  ,p_tsp_information3             in     varchar2  default hr_api.g_varchar2
  ,p_tsp_information4             in     varchar2  default hr_api.g_varchar2
  ,p_tsp_information5             in     varchar2  default hr_api.g_varchar2
  ,p_tsp_information6             in     varchar2  default hr_api.g_varchar2
  ,p_tsp_information7             in     varchar2  default hr_api.g_varchar2
  ,p_tsp_information8             in     varchar2  default hr_api.g_varchar2
  ,p_tsp_information9             in     varchar2  default hr_api.g_varchar2
  ,p_tsp_information10            in     varchar2  default hr_api.g_varchar2
  ,p_tsp_information11            in     varchar2  default hr_api.g_varchar2
  ,p_tsp_information12            in     varchar2  default hr_api.g_varchar2
  ,p_tsp_information13            in     varchar2  default hr_api.g_varchar2
  ,p_tsp_information14            in     varchar2  default hr_api.g_varchar2
  ,p_tsp_information15            in     varchar2  default hr_api.g_varchar2
  ,p_tsp_information16            in     varchar2  default hr_api.g_varchar2
  ,p_tsp_information17            in     varchar2  default hr_api.g_varchar2
  ,p_tsp_information18            in     varchar2  default hr_api.g_varchar2
  ,p_tsp_information19            in     varchar2  default hr_api.g_varchar2
  ,p_tsp_information20            in     varchar2  default hr_api.g_varchar2
  ,p_analysis_criteria_id         in     number    default hr_api.g_number
  ,p_validate                     in     number    default hr_api.g_false_num
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
  l_proc    varchar2(72) := g_package ||'update_skill_provision';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_skill_provision_swi;
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
  ota_skill_provision_api.update_skill_provision
    (p_skill_provision_id           => p_skill_provision_id
    ,p_activity_version_id          => p_activity_version_id
    ,p_object_version_number        => p_object_version_number
    ,p_type                         => p_type
    ,p_comments                     => p_comments
    ,p_tsp_information_category     => p_tsp_information_category
    ,p_tsp_information1             => p_tsp_information1
    ,p_tsp_information2             => p_tsp_information2
    ,p_tsp_information3             => p_tsp_information3
    ,p_tsp_information4             => p_tsp_information4
    ,p_tsp_information5             => p_tsp_information5
    ,p_tsp_information6             => p_tsp_information6
    ,p_tsp_information7             => p_tsp_information7
    ,p_tsp_information8             => p_tsp_information8
    ,p_tsp_information9             => p_tsp_information9
    ,p_tsp_information10            => p_tsp_information10
    ,p_tsp_information11            => p_tsp_information11
    ,p_tsp_information12            => p_tsp_information12
    ,p_tsp_information13            => p_tsp_information13
    ,p_tsp_information14            => p_tsp_information14
    ,p_tsp_information15            => p_tsp_information15
    ,p_tsp_information16            => p_tsp_information16
    ,p_tsp_information17            => p_tsp_information17
    ,p_tsp_information18            => p_tsp_information18
    ,p_tsp_information19            => p_tsp_information19
    ,p_tsp_information20            => p_tsp_information20
    ,p_analysis_criteria_id         => p_analysis_criteria_id
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
    rollback to update_skill_provision_swi;
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
    rollback to update_skill_provision_swi;
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
end update_skill_provision;
end ota_skill_provision_swi;

/
