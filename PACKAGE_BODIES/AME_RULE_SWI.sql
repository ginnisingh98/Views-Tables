--------------------------------------------------------
--  DDL for Package Body AME_RULE_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AME_RULE_SWI" As
/* $Header: amrulswi.pkb 120.3 2005/10/25 02:49 tkolla noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'ame_rule_swi.';
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_ame_rule >---------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_ame_rule
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_rule_key                     in     varchar2
  ,p_description                  in     varchar2
  ,p_rule_type                    in     varchar2
  ,p_item_class_id                in     number    default null
  ,p_condition_id                 in     number    default null
  ,p_action_id                    in     number    default null
  ,p_application_id               in     number    default null
  ,p_priority                     in     number    default null
  ,p_approver_category            in     varchar2  default null
  ,p_rul_start_date               in out nocopy date
  ,p_rul_end_date                 in out nocopy date
  ,p_rule_id                      in     number
  ,p_rul_object_version_number       out nocopy number
  ,p_rlu_object_version_number       out nocopy number
  ,p_rlu_start_date                  out nocopy date
  ,p_rlu_end_date                    out nocopy date
  ,p_cnu_object_version_number       out nocopy number
  ,p_cnu_start_date                  out nocopy date
  ,p_cnu_end_date                    out nocopy date
  ,p_acu_object_version_number       out nocopy number
  ,p_acu_start_date                  out nocopy date
  ,p_acu_end_date                    out nocopy date
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  l_rul_start_date                date;
  l_rul_end_date                  date;
  --
  -- Other variables
  l_rule_id                      number;
  l_proc    varchar2(72) := g_package ||'create_ame_rule';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_ame_rule_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  l_rul_start_date                := p_rul_start_date;
  l_rul_end_date                  := p_rul_end_date;
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => p_validate);
  --
  -- Register Surrogate ID or user key values
  --
  ame_rul_ins.set_base_key_value
    (p_rule_id => p_rule_id
    );
  --
  -- Call API
  --
  ame_rule_api.create_ame_rule
    (p_validate                     => l_validate
    ,p_rule_key                     => p_rule_key
    ,p_description                  => p_description
    ,p_rule_type                    => p_rule_type
    ,p_item_class_id                => p_item_class_id
    ,p_condition_id                 => p_condition_id
    ,p_action_id                    => p_action_id
    ,p_application_id               => p_application_id
    ,p_priority                     => p_priority
    ,p_approver_category            => p_approver_category
    ,p_rul_start_date               => l_rul_start_date
    ,p_rul_end_date                 => l_rul_end_date
    ,p_rule_id                      => l_rule_id
    ,p_rul_object_version_number    => p_rul_object_version_number
    ,p_rlu_object_version_number    => p_rlu_object_version_number
    ,p_rlu_start_date               => p_rlu_start_date
    ,p_rlu_end_date                 => p_rlu_end_date
    ,p_cnu_object_version_number    => p_cnu_object_version_number
    ,p_cnu_start_date               => p_cnu_start_date
    ,p_cnu_end_date                 => p_cnu_end_date
    ,p_acu_object_version_number    => p_acu_object_version_number
    ,p_acu_start_date               => p_acu_start_date
    ,p_acu_end_date                 => p_acu_end_date
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
    rollback to create_ame_rule_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_rul_start_date               := l_rul_start_date;
    p_rul_end_date                 := l_rul_end_date;
    p_rul_object_version_number    := null;
    p_rlu_object_version_number    := null;
    p_rlu_start_date               := null;
    p_rlu_end_date                 := null;
    p_cnu_object_version_number    := null;
    p_cnu_start_date               := null;
    p_cnu_end_date                 := null;
    p_acu_object_version_number    := null;
    p_acu_start_date               := null;
    p_acu_end_date                 := null;
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
    rollback to create_ame_rule_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_rul_start_date               := l_rul_start_date;
    p_rul_end_date                 := l_rul_end_date;
    p_rul_object_version_number    := null;
    p_rlu_object_version_number    := null;
    p_rlu_start_date               := null;
    p_rlu_end_date                 := null;
    p_cnu_object_version_number    := null;
    p_cnu_start_date               := null;
    p_cnu_end_date                 := null;
    p_acu_object_version_number    := null;
    p_acu_start_date               := null;
    p_acu_end_date                 := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_ame_rule;
-- ----------------------------------------------------------------------------
-- |-------------------------< create_ame_rule_usage >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_ame_rule_usage
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_rule_id                      in     number
  ,p_application_id               in     number
  ,p_priority                     in     number    default null
  ,p_approver_category            in     varchar2  default null
  ,p_start_date                   in out nocopy date
  ,p_end_date                     in out nocopy date
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  l_start_date                    date;
  l_end_date                      date;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'create_ame_rule_usage';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_ame_rule_usage_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  l_start_date                := p_start_date;
  l_end_date                      := p_end_date;
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
  ame_rule_api.create_ame_rule_usage
    (p_validate                     => l_validate
    ,p_rule_id                      => p_rule_id
    ,p_application_id               => p_application_id
    ,p_priority                     => p_priority
    ,p_approver_category            => p_approver_category
    ,p_start_date                   => l_start_date
    ,p_end_date                     => l_end_date
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
    rollback to create_ame_rule_usage_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_start_date                   := l_start_date;
    p_end_date                     := l_end_date;
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
    rollback to create_ame_rule_usage_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_start_date                   := l_start_date;
    p_end_date                     := l_end_date;
    p_object_version_number        := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_ame_rule_usage;
-- ----------------------------------------------------------------------------
-- |---------------------< create_ame_condition_to_rule >---------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_ame_condition_to_rule
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_rule_id                      in     number
  ,p_condition_id                 in     number
  ,p_object_version_number           out nocopy number
  ,p_start_date                      out nocopy date
  ,p_end_date                        out nocopy date
  ,p_return_status                   out nocopy varchar2
  ,p_effective_date               in     date      default null
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'create_ame_condition_to_rule';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_ame_cond_to_rule_swi;
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
  ame_rule_api.create_ame_condition_to_rule
    (p_validate                     => l_validate
    ,p_rule_id                      => p_rule_id
    ,p_condition_id                 => p_condition_id
    ,p_object_version_number        => p_object_version_number
    ,p_start_date                   => p_start_date
    ,p_end_date                     => p_end_date
    ,p_effective_date               => p_effective_date
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
    rollback to create_ame_cond_to_rule_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := null;
    p_start_date                   := null;
    p_end_date                     := null;
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
    rollback to create_ame_cond_to_rule_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := null;
    p_start_date                   := null;
    p_end_date                     := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_ame_condition_to_rule;
-- ----------------------------------------------------------------------------
-- |-----------------------< create_ame_action_to_rule >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_ame_action_to_rule
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_rule_id                      in     number
  ,p_action_id                    in     number
  ,p_object_version_number           out nocopy number
  ,p_start_date                      out nocopy date
  ,p_end_date                        out nocopy date
  ,p_return_status                   out nocopy varchar2
  ,p_effective_date               in     date      default null
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'create_ame_action_to_rule';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_ame_action_to_rule_swi;
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
  ame_rule_api.create_ame_action_to_rule
    (p_validate                     => l_validate
    ,p_rule_id                      => p_rule_id
    ,p_action_id                    => p_action_id
    ,p_object_version_number        => p_object_version_number
    ,p_start_date                   => p_start_date
    ,p_end_date                     => p_end_date
    ,p_effective_date               => p_effective_date
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
    rollback to create_ame_action_to_rule_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := null;
    p_start_date                   := null;
    p_end_date                     := null;
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
    rollback to create_ame_action_to_rule_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := null;
    p_start_date                   := null;
    p_end_date                     := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_ame_action_to_rule;
-- ----------------------------------------------------------------------------
-- |----------------------------< update_ame_rule >---------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_ame_rule
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_rule_id                      in     number
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_start_date                   in out nocopy date
  ,p_end_date                     in out nocopy date
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  l_start_date                    date;
  l_end_date                      date;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_ame_rule';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_ame_rule_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  l_object_version_number         := p_object_version_number;
  l_start_date                    := p_start_date;
  l_end_date                      := p_end_date;
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
  ame_rule_api.update_ame_rule
    (p_validate                     => l_validate
    ,p_rule_id                      => p_rule_id
    ,p_description                  => p_description
    ,p_object_version_number        => p_object_version_number
    ,p_start_date                   => p_start_date
    ,p_end_date                     => p_end_date
    ,p_effective_date               => g_effective_date
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
    rollback to update_ame_rule_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_start_date                   := l_start_date;
    p_end_date                     := l_end_date;
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
    rollback to update_ame_rule_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_start_date                   := l_start_date;
    p_end_date                     := l_end_date;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end update_ame_rule;
-- ----------------------------------------------------------------------------
-- |-------------------------< update_ame_rule_usage >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_ame_rule_usage
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_rule_id                      in     number
  ,p_application_id               in     number
  ,p_priority                     in     number    default hr_api.g_number
  ,p_approver_category            in     varchar2  default hr_api.g_varchar2
  ,p_old_start_date               in     date
  ,p_object_version_number        in out nocopy number
  ,p_start_date                   in out nocopy date
  ,p_end_date                     in out nocopy date
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  l_start_date                    date;
  l_end_date                      date;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_ame_rule_usage';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_ame_rule_usage_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  l_object_version_number         := p_object_version_number;

  l_start_date                    := p_start_date;
  l_end_date                      := p_end_date;
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
  ame_rule_api.update_ame_rule_usage
    (p_validate                     => l_validate
    ,p_rule_id                      => p_rule_id
    ,p_application_id               => p_application_id
    ,p_priority                     => p_priority
    ,p_approver_category            => p_approver_category
    ,p_old_start_date               => p_old_start_date
    ,p_object_version_number        => p_object_version_number
    ,p_start_date                   => l_start_date
    ,p_end_date                     => l_end_date
    ,p_effective_date               => g_effective_date
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
    rollback to update_ame_rule_usage_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_start_date                   := l_start_date;
    p_end_date                     := l_end_date;
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
    rollback to update_ame_rule_usage_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_start_date                   := l_start_date;
    p_end_date                     := l_end_date;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end update_ame_rule_usage;
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_ame_rule_usage >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_ame_rule_usage
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_rule_id                      in     number
  ,p_application_id               in     number
  ,p_object_version_number        in out nocopy number
  ,p_start_date                   in out nocopy date
  ,p_end_date                     in out nocopy date
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  l_start_date                    date;
  l_end_date                      date;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'delete_ame_rule_usage';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_ame_rule_usage_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  l_object_version_number         := p_object_version_number;
  l_start_date                    := p_start_date;
  l_end_date                      := p_end_date;
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
  ame_rule_api.delete_ame_rule_usage
    (p_validate                     => l_validate
    ,p_rule_id                      => p_rule_id
    ,p_application_id               => p_application_id
    ,p_object_version_number        => p_object_version_number
    ,p_start_date                   => p_start_date
    ,p_end_date                     => p_end_date
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
    rollback to delete_ame_rule_usage_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_start_date                   := l_start_date;
    p_end_date                     := l_end_date;
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
    rollback to delete_ame_rule_usage_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_start_date                   := l_start_date;
    p_end_date                     := l_end_date;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_ame_rule_usage;
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_ame_rule_condition >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_ame_rule_condition
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_rule_id                      in     number
  ,p_condition_id                 in     number
  ,p_object_version_number        in out nocopy number
  ,p_start_date                      out nocopy date
  ,p_end_date                        out nocopy date
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
  l_proc    varchar2(72) := g_package ||'delete_ame_rule_condition';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_ame_rule_condition_swi;
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
  ame_rule_api.delete_ame_rule_condition
    (p_validate                     => l_validate
    ,p_rule_id                      => p_rule_id
    ,p_condition_id                 => p_condition_id
    ,p_object_version_number        => p_object_version_number
    ,p_start_date                   => p_start_date
    ,p_end_date                     => p_end_date
    ,p_effective_date               => g_effective_date
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
    rollback to delete_ame_rule_condition_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_start_date                   := null;
    p_end_date                     := null;
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
    rollback to delete_ame_rule_condition_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_start_date                   := null;
    p_end_date                     := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_ame_rule_condition;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_ame_rule_action >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_ame_rule_action
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_rule_id                      in     number
  ,p_action_id                    in     number
  ,p_object_version_number        in out nocopy number
  ,p_start_date                      out nocopy date
  ,p_end_date                        out nocopy date
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
  l_proc    varchar2(72) := g_package ||'delete_ame_rule_action';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_ame_rule_action_swi;
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
  ame_rule_api.delete_ame_rule_action
    (p_validate                     => l_validate
    ,p_rule_id                      => p_rule_id
    ,p_action_id                    => p_action_id
    ,p_object_version_number        => p_object_version_number
    ,p_start_date                   => p_start_date
    ,p_end_date                     => p_end_date
    ,p_effective_date               => g_effective_date
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
    rollback to delete_ame_rule_action_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_start_date                   := null;
    p_end_date                     := null;
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
    rollback to delete_ame_rule_action_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_start_date                   := null;
    p_end_date                     := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_ame_rule_action;

-- ----------------------------------------------------------------------------
-- |------------------------< set_effective_date >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE set_effective_date
  (p_effective_date                  in date
  ) is
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'set_effective_date';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);

  g_effective_date :=  p_effective_date;

  hr_utility.set_location(' Leaving:' || l_proc,20);
end set_effective_date;

end ame_rule_swi;

/
