--------------------------------------------------------
--  DDL for Package Body HR_NL_ABSENCE_ACTION_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_NL_ABSENCE_ACTION_SWI" As
/* $Header: hrnaaswi.pkb 120.0.12000000.1 2007/01/21 17:24:29 appldev ship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'hr_nl_absence_action_swi.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_absence_action >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_absence_action
  (p_validate                     in     number
  ,p_absence_attendance_id        in     number
  ,p_expected_date                in     date
  ,p_description                  in     varchar2
  ,p_actual_start_date            in     date
  ,p_actual_end_date              in     date
  ,p_holder                       in     varchar2
  ,p_comments                     in     varchar2
  ,p_document_file_name           in     varchar2
  ,p_absence_action_id            out nocopy     number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  ,p_enabled                      in     varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_absence_action_id            number;
  l_proc    varchar2(72) := g_package ||'create_absence_action';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_absence_action_swi;
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
  per_naa_ins.set_base_key_value
    (p_absence_action_id => p_absence_action_id
    );
  --
  -- Call API
  --
  hr_nl_absence_action_api.create_absence_action
    (p_validate                     => l_validate
    ,p_absence_attendance_id        => p_absence_attendance_id
    ,p_expected_date                => p_expected_date
    ,p_description                  => p_description
    ,p_actual_start_date            => p_actual_start_date
    ,p_actual_end_date              => p_actual_end_date
    ,p_holder                       => p_holder
    ,p_comments                     => p_comments
    ,p_document_file_name           => p_document_file_name
    ,p_absence_action_id            => p_absence_action_id
    ,p_object_version_number        => p_object_version_number
    ,p_enabled                      => p_enabled
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
    rollback to create_absence_action_swi;
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
    rollback to create_absence_action_swi;
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
end create_absence_action;
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_absence_action >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_absence_action
  (p_validate                     in     number
  ,p_absence_action_id            in     number
  ,p_object_version_number        in     number
  ,p_return_status                out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'delete_absence_action';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_absence_action_swi;
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
  hr_nl_absence_action_api.delete_absence_action
    (p_validate                     => l_validate
    ,p_absence_action_id            => p_absence_action_id
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
    rollback to delete_absence_action_swi;
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
    rollback to delete_absence_action_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_absence_action;
-- ----------------------------------------------------------------------------
-- |-------------------------< update_absence_action >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_absence_action
  (p_validate                     in     number
  ,p_absence_attendance_id        in     number
  ,p_absence_action_id            in     number
  ,p_object_version_number        in out nocopy number
  ,p_expected_date                in     date
  ,p_description                  in     varchar2
  ,p_actual_start_date            in     date
  ,p_actual_end_date              in     date
  ,p_holder                       in     varchar2
  ,p_comments                     in     varchar2
  ,p_document_file_name           in     varchar2
  ,p_return_status                out nocopy varchar2
  ,p_enabled                      in     varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_absence_action';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_absence_action_swi;
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
  hr_nl_absence_action_api.update_absence_action
    (p_validate                     => l_validate
    ,p_absence_attendance_id        => p_absence_attendance_id
    ,p_absence_action_id            => p_absence_action_id
    ,p_object_version_number        => p_object_version_number
    ,p_expected_date                => p_expected_date
    ,p_description                  => p_description
    ,p_actual_start_date            => p_actual_start_date
    ,p_actual_end_date              => p_actual_end_date
    ,p_holder                       => p_holder
    ,p_comments                     => p_comments
    ,p_document_file_name           => p_document_file_name
    ,p_enabled                      => p_enabled
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
    rollback to update_absence_action_swi;
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
    rollback to update_absence_action_swi;
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
end update_absence_action;
end hr_nl_absence_action_swi;

/
