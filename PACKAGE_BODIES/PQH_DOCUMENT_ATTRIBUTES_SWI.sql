--------------------------------------------------------
--  DDL for Package Body PQH_DOCUMENT_ATTRIBUTES_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_DOCUMENT_ATTRIBUTES_SWI" As
/* $Header: pqdoaswi.pkb 115.0 2003/01/06 09:22:29 svorugan noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'pqh_document_attributes_swi.';
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_document_attribute >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_document_attribute
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_document_id                  in     number
  ,p_attribute_id                 in     number
  ,p_tag_name                     in     varchar2
  ,p_document_attribute_id           out NOCOPY number
  ,p_object_version_number           out NOCOPY number
  ,p_effective_start_date            out NOCOPY date
  ,p_effective_end_date              out NOCOPY date
  ,p_return_status                   out NOCOPY varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'create_document_attribute';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_document_attribute_swi;
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
  pqh_document_attributes_api.create_document_attribute
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_document_id                  => p_document_id
    ,p_attribute_id                 => p_attribute_id
    ,p_tag_name                     => p_tag_name
    ,p_document_attribute_id        => p_document_attribute_id
    ,p_object_version_number        => p_object_version_number
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
    rollback to create_document_attribute_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_document_attribute_id        := null;
    p_object_version_number        := null;
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
    rollback to create_document_attribute_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_document_attribute_id        := null;
    p_object_version_number        := null;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_document_attribute;
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_document_attribute >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_document_attribute
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_document_attribute_id        in     number
  ,p_object_version_number        in out NOCOPY number
  ,p_effective_start_date            out NOCOPY date
  ,p_effective_end_date              out NOCOPY date
  ,p_return_status                   out NOCOPY varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'delete_document_attribute';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_document_attribute_swi;
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
  pqh_document_attributes_api.delete_document_attribute
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_datetrack_mode               => p_datetrack_mode
    ,p_document_attribute_id        => p_document_attribute_id
    ,p_object_version_number        => p_object_version_number
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
    rollback to delete_document_attribute_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
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
    rollback to delete_document_attribute_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_document_attribute;
-- ----------------------------------------------------------------------------
-- |-----------------------< update_document_attribute >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_document_attribute
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_document_attribute_id        in     number
  ,p_object_version_number        in out NOCOPY number
  ,p_document_id                  in     number    default hr_api.g_number
  ,p_attribute_id                 in     number    default hr_api.g_number
  ,p_tag_name                     in     varchar2  default hr_api.g_varchar2
  ,p_effective_start_date            out NOCOPY date
  ,p_effective_end_date              out NOCOPY date
  ,p_return_status                   out NOCOPY varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_document_attribute';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_document_attribute_swi;
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
  pqh_document_attributes_api.update_document_attribute
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_datetrack_mode               => p_datetrack_mode
    ,p_document_attribute_id        => p_document_attribute_id
    ,p_object_version_number        => p_object_version_number
    ,p_document_id                  => p_document_id
    ,p_attribute_id                 => p_attribute_id
    ,p_tag_name                     => p_tag_name
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
    rollback to update_document_attribute_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
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
    rollback to update_document_attribute_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_effective_start_date         := null;
    p_effective_end_date           := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end update_document_attribute;
end pqh_document_attributes_swi;

/
