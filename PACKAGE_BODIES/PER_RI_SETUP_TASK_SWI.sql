--------------------------------------------------------
--  DDL for Package Body PER_RI_SETUP_TASK_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_RI_SETUP_TASK_SWI" As
/* $Header: pestbswi.pkb 115.0 2003/07/03 06:36:09 kavenkat noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'per_ri_setup_task_swi.';
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_setup_task >--------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_setup_task
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_setup_task_code              in     varchar2
  ,p_workbench_item_code          in     varchar2
  ,p_setup_task_name              in     varchar2
  ,p_setup_task_description       in     varchar2
  ,p_setup_task_sequence          in     number
  ,p_setup_task_status            in     varchar2  default null
  ,p_setup_task_creation_date     in     date      default null
  ,p_setup_task_last_mod_date     in     date      default null
  ,p_setup_task_type              in     varchar2  default null
  ,p_setup_task_action            in     varchar2  default null
  ,p_language_code                in     varchar2  default null
  ,p_effective_date               in     date
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
  l_proc    varchar2(72) := g_package ||'create_setup_task';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_setup_task_swi;
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
  per_ri_setup_task_api.create_setup_task
    (p_validate                     => l_validate
    ,p_setup_task_code              => p_setup_task_code
    ,p_workbench_item_code          => p_workbench_item_code
    ,p_setup_task_name              => p_setup_task_name
    ,p_setup_task_description       => p_setup_task_description
    ,p_setup_task_sequence          => p_setup_task_sequence
    ,p_setup_task_status            => p_setup_task_status
    ,p_setup_task_creation_date     => p_setup_task_creation_date
    ,p_setup_task_last_mod_date     => p_setup_task_last_mod_date
    ,p_setup_task_type              => p_setup_task_type
    ,p_setup_task_action            => p_setup_task_action
    ,p_language_code                => p_language_code
    ,p_effective_date               => p_effective_date
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
    rollback to create_setup_task_swi;
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
    rollback to create_setup_task_swi;
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
end create_setup_task;
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_setup_task >--------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_setup_task
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_setup_task_code              in     varchar2
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
  l_proc    varchar2(72) := g_package ||'delete_setup_task';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_setup_task_swi;
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
  per_ri_setup_task_api.delete_setup_task
    (p_validate                     => l_validate
    ,p_setup_task_code              => p_setup_task_code
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
    rollback to delete_setup_task_swi;
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
    rollback to delete_setup_task_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_setup_task;
-- ----------------------------------------------------------------------------
-- |---------------------------< update_setup_task >--------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_setup_task
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_setup_task_code              in     varchar2
  ,p_workbench_item_code          in     varchar2  default hr_api.g_varchar2
  ,p_setup_task_name              in     varchar2  default hr_api.g_varchar2
  ,p_setup_task_description       in     varchar2  default hr_api.g_varchar2
  ,p_setup_task_sequence          in     number    default hr_api.g_number
  ,p_setup_task_status            in     varchar2  default hr_api.g_varchar2
  ,p_setup_task_creation_date     in     date      default hr_api.g_date
  ,p_setup_task_last_mod_date     in     date      default hr_api.g_date
  ,p_setup_task_type              in     varchar2  default hr_api.g_varchar2
  ,p_setup_task_action            in     varchar2  default hr_api.g_varchar2
  ,p_language_code                in     varchar2  default hr_api.g_varchar2
  ,p_effective_date               in     date
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
  l_proc    varchar2(72) := g_package ||'update_setup_task';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_setup_task_swi;
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
  per_ri_setup_task_api.update_setup_task
    (p_validate                     => l_validate
    ,p_setup_task_code              => p_setup_task_code
    ,p_workbench_item_code          => p_workbench_item_code
    ,p_setup_task_name              => p_setup_task_name
    ,p_setup_task_description       => p_setup_task_description
    ,p_setup_task_sequence          => p_setup_task_sequence
    ,p_setup_task_status            => p_setup_task_status
    ,p_setup_task_creation_date     => p_setup_task_creation_date
    ,p_setup_task_last_mod_date     => p_setup_task_last_mod_date
    ,p_setup_task_type              => p_setup_task_type
    ,p_setup_task_action            => p_setup_task_action
    ,p_language_code                => p_language_code
    ,p_effective_date               => p_effective_date
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
    rollback to update_setup_task_swi;
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
    rollback to update_setup_task_swi;
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
end update_setup_task;
end per_ri_setup_task_swi;

/
