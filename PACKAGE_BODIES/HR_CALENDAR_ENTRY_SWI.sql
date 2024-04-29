--------------------------------------------------------
--  DDL for Package Body HR_CALENDAR_ENTRY_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_CALENDAR_ENTRY_SWI" As
/* $Header: hrentswi.pkb 120.0 2005/05/31 00:08:16 appldev noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'hr_calendar_entry_swi.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_calendar_entry >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_calendar_entry
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_name                         in     varchar2
  ,p_type                         in     varchar2
  ,p_start_date                   in     date
  ,p_start_hour                   in     varchar2  default null
  ,p_start_min                    in     varchar2  default null
  ,p_end_date                     in     date
  ,p_end_hour                     in     varchar2  default null
  ,p_end_min                      in     varchar2  default null
  ,p_business_group_id            in     number    default null
  ,p_description                  in     varchar2  default null
  ,p_hierarchy_id                 in     number    default null
  ,p_value_set_id                 in     number    default null
  ,p_organization_structure_id    in     number    default null
  ,p_org_structure_version_id     in     number    default null
  ,p_legislation_code             in     varchar2  default null
  ,p_identifier_key               in     varchar2  default null
  ,p_calendar_entry_id            in     number
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
  l_calendar_entry_id            number;
  l_proc    varchar2(72) := g_package ||'create_calendar_entry';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_calendar_entry_swi;

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

  per_ent_ins.set_base_key_value
    (p_calendar_entry_id => p_calendar_entry_id
    );
  --
  -- Call API
  --

  hr_calendar_entry_api.create_calendar_entry
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_name                         => p_name
    ,p_type                         => p_type
    ,p_start_date                   => p_start_date
    ,p_start_hour                   => p_start_hour
    ,p_start_min                    => p_start_min
    ,p_end_date                     => p_end_date
    ,p_end_hour                     => p_end_hour
    ,p_end_min                      => p_end_min
    ,p_business_group_id            => p_business_group_id
    ,p_description                  => p_description
    ,p_hierarchy_id                 => p_hierarchy_id
    ,p_value_set_id                 => p_value_set_id
    ,p_organization_structure_id    => p_organization_structure_id
    ,p_org_structure_version_id     => p_org_structure_version_id
    ,p_legislation_code             => p_legislation_code
    ,p_identifier_key               => p_identifier_key
    ,p_calendar_entry_id            => l_calendar_entry_id
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
  --
  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to create_calendar_entry_swi;
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
    rollback to create_calendar_entry_swi;
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
end create_calendar_entry;
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_calendar_entry >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_calendar_entry
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_calendar_entry_id            in     number
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
  l_proc    varchar2(72) := g_package ||'delete_calendar_entry';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_calendar_entry_swi;
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
  hr_calendar_entry_api.delete_calendar_entry
    (p_validate                     => l_validate
    ,p_calendar_entry_id            => p_calendar_entry_id
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
    rollback to delete_calendar_entry_swi;
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
    rollback to delete_calendar_entry_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_calendar_entry;
-- ----------------------------------------------------------------------------
-- |-------------------------< update_calendar_entry >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_calendar_entry
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_calendar_entry_id            in     number
  ,p_object_version_number        in out nocopy number
  ,p_name                         in     varchar2  default hr_api.g_varchar2
  ,p_type                         in     varchar2  default hr_api.g_varchar2
  ,p_start_date                   in     date      default hr_api.g_date
  ,p_start_hour                   in     varchar2  default hr_api.g_varchar2
  ,p_start_min                    in     varchar2  default hr_api.g_varchar2
  ,p_end_date                     in     date      default hr_api.g_date
  ,p_end_hour                     in     varchar2  default hr_api.g_varchar2
  ,p_end_min                      in     varchar2  default hr_api.g_varchar2
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_hierarchy_id                 in     number    default hr_api.g_number
  ,p_value_set_id                 in     number    default hr_api.g_number
  ,p_organization_structure_id    in     number    default hr_api.g_number
  ,p_org_structure_version_id     in     number    default hr_api.g_number
  ,p_business_group_id            in     number    default null
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
  l_proc    varchar2(72) := g_package ||'update_calendar_entry';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_calendar_entry_swi;
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
  hr_calendar_entry_api.update_calendar_entry
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_calendar_entry_id            => p_calendar_entry_id
    ,p_object_version_number        => p_object_version_number
    ,p_name                         => p_name
    ,p_type                         => p_type
    ,p_start_date                   => p_start_date
    ,p_start_hour                   => p_start_hour
    ,p_start_min                    => p_start_min
    ,p_end_date                     => p_end_date
    ,p_end_hour                     => p_end_hour
    ,p_end_min                      => p_end_min
    ,p_description                  => p_description
    ,p_hierarchy_id                 => p_hierarchy_id
    ,p_value_set_id                 => p_value_set_id
    ,p_organization_structure_id    => p_organization_structure_id
    ,p_org_structure_version_id     => p_org_structure_version_id
    ,p_business_group_id            => p_business_group_id
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
    rollback to update_calendar_entry_swi;
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

    rollback to update_calendar_entry_swi;
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
end update_calendar_entry;
end hr_calendar_entry_swi;

/
