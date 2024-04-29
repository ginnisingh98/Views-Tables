--------------------------------------------------------
--  DDL for Package Body IRC_TEMPLATE_ASSOCIATION_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_TEMPLATE_ASSOCIATION_SWI" As
/* $Header: iritaswi.pkb 120.0 2005/09/27 08:12 sayyampe noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'irc_template_association_swi.';
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_template_association >---------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_template_association
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_template_id                  in     number
  ,p_effective_date               in     date      default null
  ,p_default_association          in     varchar2  default null
  ,p_job_id                       in     number    default null
  ,p_position_id                  in     number    default null
  ,p_organization_id              in     number    default null
  ,p_start_date                   in     date      default null
  ,p_end_date                     in     date      default null
  ,p_object_version_number           out nocopy number
  ,p_template_association_id      in     number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_template_association_id      number;
  l_proc    varchar2(72) := g_package ||'create_template_association';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_template_assoc_swi;
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
  irc_ita_ins.set_base_key_value
    (p_template_association_id => p_template_association_id
    );
  --
  -- Call API
  --
  irc_template_association_api.create_template_association
    (p_validate                     => l_validate
    ,p_template_id                  => p_template_id
    ,p_effective_date               => p_effective_date
    ,p_default_association          => p_default_association
    ,p_job_id                       => p_job_id
    ,p_position_id                  => p_position_id
    ,p_organization_id              => p_organization_id
    ,p_start_date                   => p_start_date
    ,p_end_date                     => p_end_date
    ,p_object_version_number        => p_object_version_number
    ,p_template_association_id      => l_template_association_id
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
    rollback to create_template_assoc_swi;
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
    rollback to create_template_assoc_swi;
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
end create_template_association;
-- ----------------------------------------------------------------------------
-- |----------------------< update_template_association >---------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_template_association
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date      default hr_api.g_date
  ,p_template_association_id      in     number
  ,p_template_id                  in     number
  ,p_default_association          in     varchar2  default hr_api.g_varchar2
  ,p_job_id                       in     number    default hr_api.g_number
  ,p_position_id                  in     number    default hr_api.g_number
  ,p_organization_id              in     number    default hr_api.g_number
  ,p_start_date                   in     date      default hr_api.g_date
  ,p_end_date                     in     date      default hr_api.g_date
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
  l_proc    varchar2(72) := g_package ||'update_template_association';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_template_assoc_swi;
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
  irc_template_association_api.update_template_association
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_template_association_id      => p_template_association_id
    ,p_template_id                  => p_template_id
    ,p_default_association          => p_default_association
    ,p_job_id                       => p_job_id
    ,p_position_id                  => p_position_id
    ,p_organization_id              => p_organization_id
    ,p_start_date                   => p_start_date
    ,p_end_date                     => p_end_date
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
    rollback to update_template_assoc_swi;
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
    rollback to update_template_assoc_swi;
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
end update_template_association;
-- ----------------------------------------------------------------------------
-- |----------------------< delete_template_association >---------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_template_association
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_template_association_id      in     number
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
  l_proc    varchar2(72) := g_package ||'delete_template_association';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_template_assoc_swi;
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
  irc_template_association_api.delete_template_association
    (p_validate                     => l_validate
    ,p_template_association_id      => p_template_association_id
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
    rollback to delete_template_assoc_swi;
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
    rollback to delete_template_assoc_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_template_association;
end irc_template_association_swi;

/
