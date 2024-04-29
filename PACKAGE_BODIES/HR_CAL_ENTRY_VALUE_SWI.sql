--------------------------------------------------------
--  DDL for Package Body HR_CAL_ENTRY_VALUE_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_CAL_ENTRY_VALUE_SWI" As
/* $Header: hrenvswi.pkb 120.0 2005/05/31 00:08:35 appldev noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'hr_cal_entry_value_swi.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_entry_value >--------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_entry_value
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_calendar_entry_id            in     number
  ,p_hierarchy_node_id            in     number    default null
  ,p_value                        in     varchar2  default null
  ,p_org_structure_element_id     in     number    default null
  ,p_organization_id              in     number    default null
  ,p_override_name                in     varchar2  default null
  ,p_override_type                in     varchar2  default null
  ,p_parent_entry_value_id        in     number    default null
  ,p_cal_entry_value_id           in     number
  ,p_usage_flag                   in     varchar2
  ,p_identifier_key               in     varchar2  default null
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
  l_cal_entry_value_id           number;
  l_proc    varchar2(72) := g_package ||'create_entry_value';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_entry_value_swi;
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
  per_env_ins.set_base_key_value
    (p_cal_entry_value_id => p_cal_entry_value_id
    );
  --
  -- Call API
  --
  hr_cal_entry_value_api.create_entry_value
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_calendar_entry_id            => p_calendar_entry_id
    ,p_hierarchy_node_id            => p_hierarchy_node_id
    ,p_value                        => p_value
    ,p_org_structure_element_id     => p_org_structure_element_id
    ,p_organization_id              => p_organization_id
    ,p_override_name                => p_override_name
    ,p_override_type                => p_override_type
    ,p_parent_entry_value_id        => p_parent_entry_value_id
    ,p_cal_entry_value_id           => l_cal_entry_value_id
    ,p_object_version_number        => p_object_version_number
    ,p_usage_flag                   => p_usage_flag
    ,p_identifier_key               => p_identifier_key
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
    rollback to create_entry_value_swi;
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
    rollback to create_entry_value_swi;
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
end create_entry_value;
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_entry_value >--------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_entry_value
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_cal_entry_value_id           in     number
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
  l_proc    varchar2(72) := g_package ||'delete_entry_value';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_entry_value_swi;
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
  hr_cal_entry_value_api.delete_entry_value
    (p_validate                     => l_validate
    ,p_cal_entry_value_id           => p_cal_entry_value_id
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
    rollback to delete_entry_value_swi;
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
    rollback to delete_entry_value_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_entry_value;
-- ----------------------------------------------------------------------------
-- |--------------------------< update_entry_value >--------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_entry_value
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_cal_entry_value_id           in     number
  ,p_object_version_number        in out nocopy number
  ,p_override_name                in     varchar2  default hr_api.g_varchar2
  ,p_override_type                in     varchar2  default hr_api.g_varchar2
  ,p_parent_entry_value_id        in     number    default hr_api.g_number
  ,p_usage_flag                   in     varchar2  default hr_api.g_varchar2
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
  l_proc    varchar2(72) := g_package ||'update_entry_value';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_entry_value_swi;
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
  hr_cal_entry_value_api.update_entry_value
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_cal_entry_value_id           => p_cal_entry_value_id
    ,p_object_version_number        => p_object_version_number
    ,p_override_name                => p_override_name
    ,p_override_type                => p_override_type
    ,p_parent_entry_value_id        => p_parent_entry_value_id
    ,p_usage_flag                   => p_usage_flag
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
    rollback to update_entry_value_swi;
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
    rollback to update_entry_value_swi;
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
end update_entry_value;
end hr_cal_entry_value_swi;

/
