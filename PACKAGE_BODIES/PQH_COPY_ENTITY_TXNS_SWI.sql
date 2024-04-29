--------------------------------------------------------
--  DDL for Package Body PQH_COPY_ENTITY_TXNS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_COPY_ENTITY_TXNS_SWI" As
/* $Header: pqcetswi.pkb 115.0 2003/07/29 22:55 rpasapul noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'pqh_copy_entity_txns_swi.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_copy_entity_txn >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_copy_entity_txn
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_copy_entity_txn_id              out nocopy number
  ,p_transaction_category_id      in     number    default null
  ,p_txn_category_attribute_id    in     number    default null
  ,p_context_business_group_id    in     number    default null
  ,p_datetrack_mode               in     varchar2  default null
  ,p_context                      in     varchar2  default null
  ,p_action_date                  in     date      default null
  ,p_src_effective_date           in     date      default null
  ,p_number_of_copies             in     number    default null
  ,p_display_name                 in     varchar2  default null
  ,p_replacement_type_cd          in     varchar2  default null
  ,p_start_with                   in     varchar2  default null
  ,p_increment_by                 in     number    default null
  ,p_status                       in     varchar2  default null
  ,p_object_version_number           out nocopy number
  ,p_effective_date               in     date
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'create_copy_entity_txn';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_copy_entity_txn_swi;
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
  pqh_copy_entity_txns_api.create_copy_entity_txn
    (p_validate                     => l_validate
    ,p_copy_entity_txn_id           => p_copy_entity_txn_id
    ,p_transaction_category_id      => p_transaction_category_id
    ,p_txn_category_attribute_id    => p_txn_category_attribute_id
    ,p_context_business_group_id    => p_context_business_group_id
    ,p_datetrack_mode               => p_datetrack_mode
    ,p_context                      => p_context
    ,p_action_date                  => p_action_date
    ,p_src_effective_date           => p_src_effective_date
    ,p_number_of_copies             => p_number_of_copies
    ,p_display_name                 => p_display_name
    ,p_replacement_type_cd          => p_replacement_type_cd
    ,p_start_with                   => p_start_with
    ,p_increment_by                 => p_increment_by
    ,p_status                       => p_status
    ,p_object_version_number        => p_object_version_number
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
    rollback to create_copy_entity_txn_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_copy_entity_txn_id           := null;
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
    rollback to create_copy_entity_txn_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_copy_entity_txn_id           := null;
    p_object_version_number        := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_copy_entity_txn;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_copy_entity_txn >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_copy_entity_txn
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_copy_entity_txn_id           in     number
  ,p_object_version_number        in     number
  ,p_effective_date               in     date
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'delete_copy_entity_txn';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_copy_entity_txn_swi;
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
  pqh_copy_entity_txns_api.delete_copy_entity_txn
    (p_validate                     => l_validate
    ,p_copy_entity_txn_id           => p_copy_entity_txn_id
    ,p_object_version_number        => p_object_version_number
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
    rollback to delete_copy_entity_txn_swi;
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
    rollback to delete_copy_entity_txn_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_copy_entity_txn;
-- ----------------------------------------------------------------------------
-- |------------------------< update_copy_entity_txn >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_copy_entity_txn
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_copy_entity_txn_id           in     number
  ,p_transaction_category_id      in     number    default hr_api.g_number
  ,p_txn_category_attribute_id    in     number    default hr_api.g_number
  ,p_context_business_group_id    in     number    default hr_api.g_number
  ,p_datetrack_mode               in     varchar2  default hr_api.g_varchar2
  ,p_context                      in     varchar2  default hr_api.g_varchar2
  ,p_action_date                  in     date      default hr_api.g_date
  ,p_src_effective_date           in     date      default hr_api.g_date
  ,p_number_of_copies             in     number    default hr_api.g_number
  ,p_display_name                 in     varchar2  default hr_api.g_varchar2
  ,p_replacement_type_cd          in     varchar2  default hr_api.g_varchar2
  ,p_start_with                   in     varchar2  default hr_api.g_varchar2
  ,p_increment_by                 in     number    default hr_api.g_number
  ,p_status                       in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_effective_date               in     date
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
  l_proc    varchar2(72) := g_package ||'update_copy_entity_txn';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_copy_entity_txn_swi;
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
  pqh_copy_entity_txns_api.update_copy_entity_txn
    (p_validate                     => l_validate
    ,p_copy_entity_txn_id           => p_copy_entity_txn_id
    ,p_transaction_category_id      => p_transaction_category_id
    ,p_txn_category_attribute_id    => p_txn_category_attribute_id
    ,p_context_business_group_id    => p_context_business_group_id
    ,p_datetrack_mode               => p_datetrack_mode
    ,p_context                      => p_context
    ,p_action_date                  => p_action_date
    ,p_src_effective_date           => p_src_effective_date
    ,p_number_of_copies             => p_number_of_copies
    ,p_display_name                 => p_display_name
    ,p_replacement_type_cd          => p_replacement_type_cd
    ,p_start_with                   => p_start_with
    ,p_increment_by                 => p_increment_by
    ,p_status                       => p_status
    ,p_object_version_number        => p_object_version_number
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
    rollback to update_copy_entity_txn_swi;
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
    rollback to update_copy_entity_txn_swi;
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
end update_copy_entity_txn;
end pqh_copy_entity_txns_swi;

/
