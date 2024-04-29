--------------------------------------------------------
--  DDL for Package Body PQH_BDGT_POOL_REALLOCTIONS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_BDGT_POOL_REALLOCTIONS_SWI" As
/* $Header: pqbreswi.pkb 115.0 2003/02/06 15:19:53 kgowripe noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'pqh_bdgt_pool_realloctions_swi.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_realloc_txn_dtl >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_realloc_txn_dtl
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_transaction_id               in     number
  ,p_transaction_type             in     varchar2
  ,p_entity_id                    in     number    default null
  ,p_budget_detail_id             in     number    default null
  ,p_txn_detail_id                   out nocopy number
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
  l_proc    varchar2(72) := g_package ||'create_realloc_txn_dtl';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_realloc_txn_dtl_swi;
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
  pqh_bdgt_pool_realloctions_api.create_realloc_txn_dtl
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_transaction_id               => p_transaction_id
    ,p_transaction_type             => p_transaction_type
    ,p_entity_id                    => p_entity_id
    ,p_budget_detail_id             => p_budget_detail_id
    ,p_txn_detail_id                => p_txn_detail_id
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
    rollback to create_realloc_txn_dtl_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_txn_detail_id                := null;
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
    rollback to create_realloc_txn_dtl_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_txn_detail_id                := null;
    p_object_version_number        := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_realloc_txn_dtl;
-- ----------------------------------------------------------------------------
-- |-----------------------< create_realloc_txn_period >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_realloc_txn_period
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_txn_detail_id                in     number
  ,p_transaction_type             in     varchar2
  ,p_entity_id                    in     number    default null
  ,p_budget_period_id             in     number    default null
  ,p_start_date                   in     date      default null
  ,p_end_date                     in     date      default null
  ,p_reallocation_amt             in     number
  ,p_reserved_amt                 in     number    default null
  ,p_reallocation_period_id          out nocopy number
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
  l_proc    varchar2(72) := g_package ||'create_realloc_txn_period';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_realloc_txn_period_swi;
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
  pqh_bdgt_pool_realloctions_api.create_realloc_txn_period
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_txn_detail_id                => p_txn_detail_id
    ,p_transaction_type             => p_transaction_type
    ,p_entity_id                    => p_entity_id
    ,p_budget_period_id             => p_budget_period_id
    ,p_start_date                   => p_start_date
    ,p_end_date                     => p_end_date
    ,p_reallocation_amt             => p_reallocation_amt
    ,p_reserved_amt                 => p_reserved_amt
    ,p_reallocation_period_id       => p_reallocation_period_id
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
    rollback to create_realloc_txn_period_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_reallocation_period_id       := null;
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
    rollback to create_realloc_txn_period_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_reallocation_period_id       := null;
    p_object_version_number        := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_realloc_txn_period;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_realloc_txn_dtl >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_realloc_txn_dtl
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_txn_detail_id                in     number
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
  l_proc    varchar2(72) := g_package ||'delete_realloc_txn_dtl';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_realloc_txn_dtl_swi;
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
  pqh_bdgt_pool_realloctions_api.delete_realloc_txn_dtl
    (p_validate                     => l_validate
    ,p_txn_detail_id                => p_txn_detail_id
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
    rollback to delete_realloc_txn_dtl_swi;
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
    rollback to delete_realloc_txn_dtl_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_realloc_txn_dtl;
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_realloc_txn_period >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_realloc_txn_period
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_reallocation_period_id       in     number
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
  l_proc    varchar2(72) := g_package ||'delete_realloc_txn_period';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_realloc_txn_period_swi;
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
  pqh_bdgt_pool_realloctions_api.delete_realloc_txn_period
    (p_validate                     => l_validate
    ,p_reallocation_period_id       => p_reallocation_period_id
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
    rollback to delete_realloc_txn_period_swi;
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
    rollback to delete_realloc_txn_period_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_realloc_txn_period;
-- ----------------------------------------------------------------------------
-- |------------------------< update_realloc_txn_dtl >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_realloc_txn_dtl
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_transaction_id               in     number    default hr_api.g_number
  ,p_transaction_type             in     varchar2  default hr_api.g_varchar2
  ,p_entity_id                    in     number    default hr_api.g_number
  ,p_budget_detail_id             in     number    default hr_api.g_number
  ,p_txn_detail_id                in     number
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
  l_proc    varchar2(72) := g_package ||'update_realloc_txn_dtl';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_realloc_txn_dtl_swi;
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
  pqh_bdgt_pool_realloctions_api.update_realloc_txn_dtl
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_transaction_id               => p_transaction_id
    ,p_transaction_type             => p_transaction_type
    ,p_entity_id                    => p_entity_id
    ,p_budget_detail_id             => p_budget_detail_id
    ,p_txn_detail_id                => p_txn_detail_id
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
    rollback to update_realloc_txn_dtl_swi;
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
    rollback to update_realloc_txn_dtl_swi;
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
end update_realloc_txn_dtl;
-- ----------------------------------------------------------------------------
-- |-----------------------< update_realloc_txn_period >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_realloc_txn_period
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_txn_detail_id                in     number    default hr_api.g_number
  ,p_transaction_type             in     varchar2  default hr_api.g_varchar2
  ,p_entity_id                    in     number    default hr_api.g_number
  ,p_budget_period_id             in     number    default hr_api.g_number
  ,p_start_date                   in     date      default hr_api.g_date
  ,p_end_date                     in     date      default hr_api.g_date
  ,p_reallocation_amt             in     number    default hr_api.g_number
  ,p_reserved_amt                 in     number    default hr_api.g_number
  ,p_reallocation_period_id       in     number
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
  l_proc    varchar2(72) := g_package ||'update_realloc_txn_period';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_realloc_txn_period_swi;
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
  pqh_bdgt_pool_realloctions_api.update_realloc_txn_period
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_txn_detail_id                => p_txn_detail_id
    ,p_transaction_type             => p_transaction_type
    ,p_entity_id                    => p_entity_id
    ,p_budget_period_id             => p_budget_period_id
    ,p_start_date                   => p_start_date
    ,p_end_date                     => p_end_date
    ,p_reallocation_amt             => p_reallocation_amt
    ,p_reserved_amt                 => p_reserved_amt
    ,p_reallocation_period_id       => p_reallocation_period_id
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
    rollback to update_realloc_txn_period_swi;
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
    rollback to update_realloc_txn_period_swi;
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
end update_realloc_txn_period;
end pqh_bdgt_pool_realloctions_swi;

/
