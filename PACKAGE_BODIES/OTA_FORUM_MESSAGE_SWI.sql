--------------------------------------------------------
--  DDL for Package Body OTA_FORUM_MESSAGE_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_FORUM_MESSAGE_SWI" As
/* $Header: otfmsswi.pkb 120.3 2006/03/28 02:19 aabalakr noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'ota_forum_message_swi.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_forum_message >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_forum_message
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_forum_id                     in     number
  ,p_forum_thread_id              in     number
  ,p_business_group_id            in     number
  ,p_message_scope                in     varchar2
  ,p_message_body                 in     varchar2  default null
  ,p_parent_message_id            in     number    default null
  ,p_person_id                    in     number    default null
  ,p_contact_id                   in     number    default null
  ,p_target_person_id             in     number    default null
  ,p_target_contact_id            in     number    default null
  ,p_forum_message_id                in  number
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
  l_proc    varchar2(72) := g_package ||'create_forum_message';
  l_forum_message_id number;
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_forum_message_swi;
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
  --
  -- Register Surrogate ID or user key values
    --
    ota_fms_ins.set_base_key_value
    (
      p_forum_message_id => p_forum_message_id
    );

  --
  -- Call API
  --
  ota_forum_message_api.create_forum_message
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_forum_id                     => p_forum_id
    ,p_forum_thread_id              => p_forum_thread_id
    ,p_business_group_id            => p_business_group_id
    ,p_message_scope                => p_message_scope
    ,p_message_body                 => p_message_body
    ,p_parent_message_id            => p_parent_message_id
    ,p_person_id                    => p_person_id
    ,p_contact_id                   => p_contact_id
    ,p_target_person_id             => p_target_person_id
    ,p_target_contact_id            => p_target_contact_id
    ,p_forum_message_id             => l_forum_message_id
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
    rollback to create_forum_message_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    l_forum_message_id             := null;
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
    rollback to create_forum_message_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    l_forum_message_id             := null;
    p_object_version_number        := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_forum_message;
-- ----------------------------------------------------------------------------
-- |-------------------------< update_forum_message >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_forum_message
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_forum_id                     in     number
  ,p_forum_thread_id              in     number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_message_scope                in     varchar2  default hr_api.g_varchar2
  ,p_message_body                 in     varchar2  default hr_api.g_varchar2
  ,p_parent_message_id            in     number    default hr_api.g_number
  ,p_person_id                    in     number    default hr_api.g_number
  ,p_contact_id                   in     number    default hr_api.g_number
  ,p_target_person_id             in     number    default hr_api.g_number
  ,p_target_contact_id            in     number    default hr_api.g_number
  ,p_forum_message_id                in  number
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_forum_message';
  l_forum_message_id number;
  l_object_version_number number := p_object_version_number;

Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_forum_message_swi;
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
  --
  -- Call API
  --
  ota_forum_message_api.update_forum_message
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_forum_id                     => p_forum_id
    ,p_forum_thread_id              => p_forum_thread_id
    ,p_business_group_id            => p_business_group_id
    ,p_message_scope                => p_message_scope
    ,p_message_body                 => p_message_body
    ,p_parent_message_id            => p_parent_message_id
    ,p_person_id                    => p_person_id
    ,p_contact_id                   => p_contact_id
    ,p_target_person_id             => p_target_person_id
    ,p_target_contact_id            => p_target_contact_id
    ,p_forum_message_id             => p_forum_message_id
    ,p_object_version_number        => l_object_version_number
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
  p_object_version_number := l_object_version_number;

  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to update_forum_message_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    l_forum_message_id             := null;
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
    rollback to update_forum_message_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    l_forum_message_id             := null;
    p_object_version_number        := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end update_forum_message;
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_forum_message >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_forum_message
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_forum_message_id             in     number
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
  l_proc    varchar2(72) := g_package ||'delete_forum_message';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_forum_message_swi;
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
  ota_forum_message_api.delete_forum_message
    (p_validate                     => l_validate
    ,p_forum_message_id             => p_forum_message_id
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
    rollback to delete_forum_message_swi;
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
    rollback to delete_forum_message_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_forum_message;
end ota_forum_message_swi;

/
