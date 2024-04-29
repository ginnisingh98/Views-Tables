--------------------------------------------------------
--  DDL for Package Body IRC_DOCUMENT_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_DOCUMENT_SWI" As
/* $Header: iridoswi.pkb 120.0.12000000.3 2007/03/27 18:57:38 mganapat noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'irc_document_swi.';
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_document >---------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_document
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_type                         in     varchar2
  ,p_person_id                    in     number
  ,p_mime_type                    in     varchar2
  ,p_assignment_id                in     number    default null
  ,p_file_name                    in     varchar2  default null
  ,p_description                  in     varchar2  default null
  ,p_document_id                  in     number
  ,p_end_date			  in     Date      default null
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
  l_document_id                  number;
  l_proc    varchar2(72) := g_package ||'create_document';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_document_swi;
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
  irc_ido_ins.set_base_key_value
    (p_document_id => p_document_id
    );
  --
  -- Call API
  --
  irc_document_api.create_document
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_type                         => p_type
    ,p_person_id                    => p_person_id
    ,p_mime_type                    => p_mime_type
    ,p_assignment_id                => p_assignment_id
    ,p_file_name                    => p_file_name
    ,p_description                  => p_description
    ,p_end_date			    => p_end_date
    ,p_document_id                  => l_document_id
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
    rollback to create_document_swi;
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
    rollback to create_document_swi;
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
end create_document;
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_document >---------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_document
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_document_id                  in     number
  ,p_object_version_number        in     number
  ,p_person_id                    in     number
  ,p_party_id			  in	 number
  ,p_end_date			  in     Date
  ,p_type                         in     varchar2
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'delete_document';
Begin


  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_document_swi;
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
  irc_document_api.delete_document
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_document_id                  => p_document_id
    ,p_object_version_number        => p_object_version_number
    ,p_person_id		    => p_person_id
    ,p_party_id			    => p_party_id
    ,p_end_date			    => p_end_date
    ,p_type                         => p_type
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

  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to delete_document_swi;
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
    rollback to delete_document_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);


end delete_document;
-- ----------------------------------------------------------------------------
-- |----------------------------< update_document >---------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_document
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_document_id                  in     number
  ,p_mime_type                    in     varchar2  default hr_api.g_varchar2
  ,p_type                         in     varchar2  default hr_api.g_varchar2
  ,p_file_name                    in     varchar2  default hr_api.g_varchar2
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_person_id			  In     number	   default hr_api.g_number
  ,p_party_id			  in	 number    default hr_api.g_number
  ,p_end_date			  In     Date      default hr_api.g_date
  ,p_assignment_id		  In     number	   default hr_api.g_number
  ,p_object_version_number        in out nocopy number
  ,p_new_doc_id			  out nocopy number
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
  l_proc    varchar2(72) := g_package ||'update_document';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --

  -- Issue a savepoint
  --
  savepoint update_document_swi;
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
  irc_document_api.update_document_track
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_document_id                  => p_document_id
    ,p_mime_type                    => p_mime_type
    ,p_type                         => p_type
    ,p_file_name                    => p_file_name
    ,p_description                  => p_description
    ,p_person_id		    => p_person_id
    ,p_party_id			    => p_party_id
    ,p_end_date			    => p_end_date
    ,p_assignment_id		    => p_assignment_id
    ,p_object_version_number        => p_object_version_number
    ,p_new_doc_id		    => p_new_doc_id
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
    rollback to update_document_swi;
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
    rollback to update_document_swi;
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
end update_document;
end irc_document_swi;

/
