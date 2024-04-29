--------------------------------------------------------
--  DDL for Package Body IRC_ASSIGNMENT_DETAILS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_ASSIGNMENT_DETAILS_SWI" As
/* $Header: iriadswi.pkb 120.2.12010000.2 2010/01/11 10:36:33 uuddavol ship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'irc_assignment_details_swi.';
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_assignment_details >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_assignment_details
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_assignment_id                in     number
  ,p_attempt_id                   in     number    default null
  ,p_assignment_details_id        in     number
  ,p_qualified                    in     varchar2  default null
  ,p_considered                   in     varchar2  default null
  ,p_details_version                 out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
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
  l_assignment_details_id        number;
  l_proc    varchar2(72) := g_package ||'create_assignment_details';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_assignment_details_swi;
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
  irc_iad_ins.set_base_key_value
    (p_assignment_details_id => p_assignment_details_id
    );
  --
  -- Call API
  --
  irc_assignment_details_api.create_assignment_details
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_assignment_id                => p_assignment_id
    ,p_attempt_id                   => p_attempt_id
    ,p_assignment_details_id        => l_assignment_details_id
    ,p_qualified                    => p_qualified
    ,p_considered                   => p_considered
    ,p_details_version              => p_details_version
    ,p_effective_start_date         => p_effective_start_date
    ,p_effective_end_date           => p_effective_end_date
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
    rollback to create_assignment_details_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_details_version              := null;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
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
    rollback to create_assignment_details_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_details_version              := null;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_object_version_number        := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_assignment_details;
-- ----------------------------------------------------------------------------
-- |-----------------------< update_assignment_details >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_assignment_details
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number    default hr_api.g_number
  ,p_attempt_id                   in     number    default hr_api.g_number
  ,p_qualified                    in     varchar2  default hr_api.g_varchar2
  ,p_considered                   in     varchar2  default hr_api.g_varchar2
  ,p_assignment_details_id        in out nocopy number
  ,p_object_version_number        in out nocopy number
  ,p_details_version                 out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  l_assignment_details_id         number;
  l_object_version_number         number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_assignment_details';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_assignment_details_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  l_assignment_details_id         := p_assignment_details_id;
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
  irc_assignment_details_api.update_assignment_details
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_datetrack_update_mode        => p_datetrack_update_mode
    ,p_assignment_id                => p_assignment_id
    ,p_attempt_id                   => p_attempt_id
    ,p_qualified                    => p_qualified
    ,p_considered                   => p_considered
    ,p_assignment_details_id        => p_assignment_details_id
    ,p_object_version_number        => p_object_version_number
    ,p_details_version              => p_details_version
    ,p_effective_start_date         => p_effective_start_date
    ,p_effective_end_date           => p_effective_end_date
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
    rollback to update_assignment_details_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_assignment_details_id        := l_assignment_details_id;
    p_object_version_number        := l_object_version_number;
    p_details_version              := null;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
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
    rollback to update_assignment_details_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_assignment_details_id        := l_assignment_details_id;
    p_object_version_number        := l_object_version_number;
    p_details_version              := null;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end update_assignment_details;
end irc_assignment_details_swi;

/
