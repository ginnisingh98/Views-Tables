--------------------------------------------------------
--  DDL for Package Body PQH_TXN_CAT_DOCUMENTS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_TXN_CAT_DOCUMENTS_SWI" As
/* $Header: pqtcdswi.pkb 115.0 2003/05/11 12:45:51 svorugan noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'pqh_txn_cat_documents_swi.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_txn_cat_document >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_txn_cat_document
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_document_id                  in     number
  ,p_transaction_category_id      in     number
  ,p_type_code                    in     varchar2
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
  l_proc    varchar2(72) := g_package ||'create_txn_cat_document';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_txn_cat_document_swi;
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
  pqh_txn_cat_documents_api.create_txn_cat_document
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_document_id                  => p_document_id
    ,p_transaction_category_id      => p_transaction_category_id
    ,p_type_code                    => p_type_code
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
    rollback to create_txn_cat_document_swi;
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
    rollback to create_txn_cat_document_swi;
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
end create_txn_cat_document;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_txn_cat_document >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_txn_cat_document
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_document_id                  in     number
  ,p_transaction_category_id      in     number
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
  l_proc    varchar2(72) := g_package ||'delete_txn_cat_document';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_txn_cat_document_swi;
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
  pqh_txn_cat_documents_api.delete_txn_cat_document
    (p_validate                     => l_validate
    ,p_document_id                  => p_document_id
    ,p_transaction_category_id      => p_transaction_category_id
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
    rollback to delete_txn_cat_document_swi;
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
    rollback to delete_txn_cat_document_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_txn_cat_document;
--- svorugan--

-- ----------------------------------------------------------------------------
-- |------------------------< delete_group >-----------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_group
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_transaction_category_id      in     number
  ,p_object_version_number        in     number
  ,p_effective_date               in     date      default sysdate
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'delete_group';
  ---
  ---
  Cursor group_document_csr is
  Select document_id , object_version_number
  from pqh_txn_category_documents
  where transaction_category_id = p_transaction_category_id;

Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_txn_cat_document_swi;
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
  -- Call API for Child Records
  --
            for l_rec in group_document_csr
             loop
              --
		pqh_txn_cat_documents_api.delete_txn_cat_document
    		(p_validate                     => l_validate
    		,p_document_id                  => l_rec.document_id
    		,p_transaction_category_id      => p_transaction_category_id
    		,p_object_version_number        => l_rec.object_version_number
    		);
               --
             end loop;

  --
  -- Call API
  --
  pqh_tran_category_api.delete_tran_category
    (p_validate                     => l_validate
    ,p_transaction_category_id      => p_transaction_category_id
    ,p_object_version_number        => p_object_version_number
    ,p_effective_date               => trunc(p_effective_date)
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
    rollback to delete_txn_cat_document_swi;
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
    rollback to delete_txn_cat_document_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_group;
-- ----------------------------------------------------------------------------


-- svorugan --
-- ----------------------------------------------------------------------------
-- |------------------------< update_txn_cat_document >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_txn_cat_document
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_document_id                  in     number
  ,p_transaction_category_id      in     number
  ,p_type_code                    in     varchar2  default hr_api.g_varchar2
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
  l_proc    varchar2(72) := g_package ||'update_txn_cat_document';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_txn_cat_document_swi;
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
  pqh_txn_cat_documents_api.update_txn_cat_document
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_document_id                  => p_document_id
    ,p_transaction_category_id      => p_transaction_category_id
    ,p_type_code                    => p_type_code
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
    rollback to update_txn_cat_document_swi;
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
    rollback to update_txn_cat_document_swi;
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
end update_txn_cat_document;
end pqh_txn_cat_documents_swi;

/
