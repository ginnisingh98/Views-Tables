--------------------------------------------------------
--  DDL for Package Body OTA_OPEN_FC_ENROLLMENT_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_OPEN_FC_ENROLLMENT_SWI" As
/* $Header: otfceswi.pkb 120.0 2005/06/24 07:54 appldev noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'ota_open_fc_enrollment_swi.';
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_open_fc_enrollment >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_open_fc_enrollment
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_business_group_id            in     number
  ,p_forum_id                     in     number    default null
  ,p_person_id                    in     number    default null
  ,p_contact_id                   in     number    default null
  ,p_chat_id                      in     number    default null
  ,p_enrollment_id                   in  number
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
  l_proc    varchar2(72) := g_package ||'create_open_fc_enrollment';
  l_enrollment_id number;
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_open_fc_enrollment_swi;
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

  ota_fce_ins.set_base_key_value
    (
      p_enrollment_id => p_enrollment_id
    );

  --
  -- Call API
  --
  ota_open_fc_enrollment_api.create_open_fc_enrollment
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_business_group_id            => p_business_group_id
    ,p_forum_id                     => p_forum_id
    ,p_person_id                    => p_person_id
    ,p_contact_id                   => p_contact_id
    ,p_chat_id                      => p_chat_id
    ,p_enrollment_id                => l_enrollment_id
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
    rollback to create_open_fc_enrollment_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    l_enrollment_id                := null;
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
    rollback to create_open_fc_enrollment_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    l_enrollment_id                := null;
    p_object_version_number        := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_open_fc_enrollment;
-- ----------------------------------------------------------------------------
-- |-----------------------< update_open_fc_enrollment >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_open_fc_enrollment
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_enrollment_id                in     number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_forum_id                     in     number    default hr_api.g_number
  ,p_person_id                    in     number    default hr_api.g_number
  ,p_contact_id                   in     number    default hr_api.g_number
  ,p_chat_id                      in     number    default hr_api.g_number
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
  l_proc    varchar2(72) := g_package ||'update_open_fc_enrollment';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_open_fc_enrollment_swi;
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
  ota_open_fc_enrollment_api.update_open_fc_enrollment
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_enrollment_id                => p_enrollment_id
    ,p_business_group_id            => p_business_group_id
    ,p_forum_id                     => p_forum_id
    ,p_person_id                    => p_person_id
    ,p_contact_id                   => p_contact_id
    ,p_chat_id                      => p_chat_id
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
    rollback to update_open_fc_enrollment_swi;
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
    rollback to update_open_fc_enrollment_swi;
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
end update_open_fc_enrollment;
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_open_fc_enrollment >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_open_fc_enrollment
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_enrollment_id                in     number
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
  l_proc    varchar2(72) := g_package ||'delete_open_fc_enrollment';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_open_fc_enrollment_swi;
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
  ota_open_fc_enrollment_api.delete_open_fc_enrollment
    (p_validate                     => l_validate
    ,p_enrollment_id                => p_enrollment_id
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
    rollback to delete_open_fc_enrollment_swi;
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
    rollback to delete_open_fc_enrollment_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_open_fc_enrollment;
end ota_open_fc_enrollment_swi;

/
