--------------------------------------------------------
--  DDL for Package Body PQH_FR_STAT_SIT_RULES_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_FR_STAT_SIT_RULES_SWI" As
/* $Header: pqstrswi.pkb 115.2 2003/10/16 11:43 svorugan noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'pqh_fr_stat_sit_rules_swi.';

g_debug boolean := hr_utility.debug_enabled;

--
-- ----------------------------------------------------------------------------
-- |----------------------< create_stat_situation_rule >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_stat_situation_rule
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date      default null
  ,p_statutory_situation_id       in     number
  ,p_processing_sequence          in     number
  ,p_txn_category_attribute_id    in     number
  ,p_from_value                   in     varchar2
  ,p_to_value                     in     varchar2  default null
  ,p_enabled_flag                 in     varchar2  default null
  ,p_required_flag                in     varchar2  default null
  ,p_exclude_flag                 in     varchar2  default null
  ,p_stat_situation_rule_id          out nocopy number
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
  l_stat_situation_rule_id       number;
  l_proc    varchar2(72) := g_package ||'create_stat_situation_rule';
Begin

  if g_debug then
  --
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  End if;

  --
  -- Issue a savepoint
  --
  savepoint create_stat_situation_rule_swi;
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
  pqh_str_ins.set_base_key_value
    (p_stat_situation_rule_id => p_stat_situation_rule_id
    );
  --
  -- Call API
  --
  pqh_fr_stat_sit_rules_api.create_stat_situation_rule
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_statutory_situation_id       => p_statutory_situation_id
    ,p_processing_sequence          => p_processing_sequence
    ,p_txn_category_attribute_id    => p_txn_category_attribute_id
    ,p_from_value                   => p_from_value
    ,p_to_value                     => p_to_value
    ,p_enabled_flag                 => p_enabled_flag
    ,p_required_flag                => p_required_flag
    ,p_exclude_flag                 => p_exclude_flag
    ,p_stat_situation_rule_id       => l_stat_situation_rule_id
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

  p_stat_situation_rule_id := l_stat_situation_rule_id;

  p_return_status := hr_multi_message.get_return_status_disable;

  if g_debug then
  --
  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
  End if;
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to create_stat_situation_rule_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := null;
    p_return_status := hr_multi_message.get_return_status_disable;

    if g_debug then
      --
    hr_utility.set_location(' Leaving:' || l_proc, 30);
    --
    End if;

  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to create_stat_situation_rule_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then

      if g_debug then
       --
      hr_utility.set_location(' Leaving:' || l_proc,40);
      --
      End if;

      raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := null;
    p_return_status := hr_multi_message.get_return_status_disable;

       if g_debug then
       --
        hr_utility.set_location(' Leaving:' || l_proc,50);
      --
      End if;

end create_stat_situation_rule;
-- ----------------------------------------------------------------------------
-- |----------------------< delete_stat_situation_rule >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_stat_situation_rule
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_stat_situation_rule_id       in     number
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
  l_proc    varchar2(72) := g_package ||'delete_stat_situation_rule';
Begin

  if g_debug then
    --
     hr_utility.set_location(' Entering:' || l_proc,10);
   --
   End if;

  --
  -- Issue a savepoint
  --
  savepoint delete_stat_situation_rule_swi;
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
  pqh_fr_stat_sit_rules_api.delete_stat_situation_rule
    (p_validate                     => l_validate
    ,p_stat_situation_rule_id       => p_stat_situation_rule_id
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

  if g_debug then
    --
  hr_utility.set_location(' Leaving:' || l_proc,20);
   --
   End if;

  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to delete_stat_situation_rule_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;

    if g_debug then
    --
    hr_utility.set_location(' Leaving:' || l_proc, 30);
    --
    End if;

  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to delete_stat_situation_rule_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
      if g_debug then
      --
       hr_utility.set_location(' Leaving:' || l_proc,40);
       --
       End if;

       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;

    if g_debug then
    --
    hr_utility.set_location(' Leaving:' || l_proc,50);
    --
    End if;

end delete_stat_situation_rule;
-- ----------------------------------------------------------------------------
-- |----------------------< update_stat_situation_rule >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_stat_situation_rule
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date      default hr_api.g_date
  ,p_stat_situation_rule_id       in     number
  ,p_object_version_number        in out nocopy number
  ,p_statutory_situation_id       in     number    default hr_api.g_number
  ,p_processing_sequence          in     number    default hr_api.g_number
  ,p_txn_category_attribute_id    in     number    default hr_api.g_number
  ,p_from_value                   in     varchar2  default hr_api.g_varchar2
  ,p_to_value                     in     varchar2  default hr_api.g_varchar2
  ,p_enabled_flag                 in     varchar2  default hr_api.g_varchar2
  ,p_required_flag                in     varchar2  default hr_api.g_varchar2
  ,p_exclude_flag                 in     varchar2  default hr_api.g_varchar2
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
  l_proc    varchar2(72) := g_package ||'update_stat_situation_rule';
Begin

  if g_debug then
    --
  hr_utility.set_location(' Entering:' || l_proc,10);
   --
   End if;

  --
  -- Issue a savepoint
  --
  savepoint update_stat_situation_rule_swi;
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
  pqh_fr_stat_sit_rules_api.update_stat_situation_rule
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_stat_situation_rule_id       => p_stat_situation_rule_id
    ,p_object_version_number        => p_object_version_number
    ,p_statutory_situation_id       => p_statutory_situation_id
    ,p_processing_sequence          => p_processing_sequence
    ,p_txn_category_attribute_id    => p_txn_category_attribute_id
    ,p_from_value                   => p_from_value
    ,p_to_value                     => p_to_value
    ,p_enabled_flag                 => p_enabled_flag
    ,p_required_flag                => p_required_flag
    ,p_exclude_flag                 => p_exclude_flag
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

  if g_debug then
    --
  hr_utility.set_location(' Leaving:' || l_proc,20);
    --
    End if;

  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to update_stat_situation_rule_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_return_status := hr_multi_message.get_return_status_disable;

    if g_debug then
    --
    hr_utility.set_location(' Leaving:' || l_proc, 30);
    --
    End if;

  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to update_stat_situation_rule_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then

       if g_debug then
       --
       hr_utility.set_location(' Leaving:' || l_proc,40);
       --
       End if;

       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_return_status := hr_multi_message.get_return_status_disable;

    if g_debug then
    --
    hr_utility.set_location(' Leaving:' || l_proc,50);
    --
    End if;

end update_stat_situation_rule;
end pqh_fr_stat_sit_rules_swi;

/
