--------------------------------------------------------
--  DDL for Package Body HR_QUEST_FIELDS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_QUEST_FIELDS_SWI" As
/* $Header: hrqsfswi.pkb 120.0 2005/05/31 02:28:22 appldev noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'hr_quest_fields_swi.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< insert_quest_fields >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE insert_quest_fields
  (p_field_id                     in	 number
  ,p_questionnaire_template_id    in     number
  ,p_name                         in     varchar2
  ,p_type                         in     varchar2
  ,p_html_text                    in     varchar2
  ,p_sql_required_flag            in     varchar2
  ,p_sql_text                     in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        out    nocopy number
  ,p_effective_date               in     date
  ,p_validate			  in	 number default hr_api.g_false_num
  ,p_return_status                out	 nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_field_id		number;
  l_proc    varchar2(72) := g_package ||'insert_quest_fields';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint insert_quest_fields;
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
  hr_qsf_ins.set_base_key_value
    (p_field_id => p_field_id
    );
  --
  -- Call API
  --
  hr_quest_fields_api.insert_quest_fields
    (p_field_id                     => l_field_id
    ,p_questionnaire_template_id    => p_questionnaire_template_id
    ,p_name                         => p_name
    ,p_type                         => p_type
    ,p_html_text                    => p_html_text
    ,p_sql_required_flag            => p_sql_required_flag
    ,p_sql_text                     => p_sql_text
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
  If l_validate = TRUE Then
	rollback to insert_quest_fields;
  End If;
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
    rollback to insert_quest_fields;
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
    rollback to insert_quest_fields;
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
end insert_quest_fields;

-- ----------------------------------------------------------------------------
-- |---------------------------< update_quest_fields >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_quest_fields
  (p_field_id                     in     number
  ,p_sql_text                     in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_effective_date               in     date
  ,p_validate			  in	 number default hr_api.g_false_num
  ,p_return_status                out	 nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_quest_fields';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_quest_fields;
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
  hr_quest_fields_api.update_quest_fields
    (p_field_id                     => p_field_id
    ,p_sql_text                     => p_sql_text
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
  If l_validate = TRUE Then
	rollback to update_quest_fields;
  End If;
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
    rollback to update_quest_fields;
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
    rollback to update_quest_fields;
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
end update_quest_fields;

-- ----------------------------------------------------------------------------
-- |-------------------------< delete_quest_fields >--------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_quest_fields
  (p_field_id                     in     number
  ,p_object_version_number        in     number
  ,p_validate			  in	 number default hr_api.g_false_num
  ,p_return_status                out	 nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'delete_quest_fields';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_quest_fields;
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
  hr_quest_fields_api.delete_quest_fields
    (p_field_id                     => p_field_id
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
  If l_validate = TRUE Then
	rollback to delete_quest_fields;
  End If;
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
    rollback to delete_quest_fields;
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
    rollback to delete_quest_fields;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_quest_fields;

-- ----------------------------------------------------------------------------
-- |-------------------------< delete_quest_fields >--------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_quest_fields
  (p_field_id                     in     number
  ,p_validate			  in	 number default hr_api.g_false_num
  ,p_return_status                out	 nocopy varchar2
  ) is

  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'delete_quest_fields';
  --
  CURSOR delete_fields (fldId number) IS
	select field_id, object_version_number
	from   hr_quest_fields
	where field_id <= fldId;
 --
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_fields;

  --
  --
  For t in delete_fields(p_field_id) Loop

	delete_quest_fields
	   (p_field_id                     =>     t.field_id
	   ,p_object_version_number        =>	 t.object_version_number
	   ,p_validate			   =>	 p_validate
	   ,p_return_status                =>	 p_return_status
	);
  End Loop;
  --
  --
  If l_validate = TRUE Then
     rollback to delete_quest_fields;
  End If;
  --
Exception
  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to delete_fields;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);

end delete_quest_fields;

end hr_quest_fields_swi;

/
