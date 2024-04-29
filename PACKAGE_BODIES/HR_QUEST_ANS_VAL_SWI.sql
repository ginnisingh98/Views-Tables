--------------------------------------------------------
--  DDL for Package Body HR_QUEST_ANS_VAL_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_QUEST_ANS_VAL_SWI" As
/* $Header: hrqsvswi.pkb 120.0.12000000.2 2007/07/17 08:42:39 rapandi ship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'hr_quest_ans_val_swi.';
--
-- ----------------------------------------------------------------------------
-- |----------------------< insert_quest_answer_val >-------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE insert_quest_answer_val
  (p_quest_answer_val_id          in	 number
  ,p_questionnaire_answer_id      in     number
  ,p_field_id                     in     number
  ,p_object_version_number           out nocopy number
  ,p_value                        in     varchar2  default hr_api.g_varchar2
  ,p_validate			  in	 number default hr_api.g_false_num
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_quest_answer_val_id		number;
  l_proc    varchar2(72) := g_package ||'insert_quest_answer_val';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint insert_quest_answer_val;
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

  hr_qsv_ins.set_base_key_value
  ( p_quest_answer_val_id => p_quest_answer_val_id
  );

  --
  --
  -- Call API
  --
    hr_quest_ans_val_api.insert_quest_answer_val
    (p_quest_answer_val_id          => l_quest_answer_val_id
    ,p_questionnaire_answer_id      => p_questionnaire_answer_id
    ,p_field_id                     => p_field_id
    ,p_object_version_number        => p_object_version_number
    ,p_value                        => p_value
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
	rollback to insert_quest_answer_val;
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
    rollback to insert_quest_answer_val;
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
    rollback to insert_quest_answer_val;
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
end insert_quest_answer_val;
-- ----------------------------------------------------------------------------
-- |--------------------------< set_base_key_value >--------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE set_base_key_value
  (p_quest_answer_val_id          in     number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'set_base_key_value';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint set_base_key_value_swi;
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
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  hr_qsv_ins.set_base_key_value
    (p_quest_answer_val_id          => p_quest_answer_val_id
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
    rollback to set_base_key_value_swi;
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
    rollback to set_base_key_value_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end set_base_key_value;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_quest_answer_val >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_quest_answer_val
  (p_quest_answer_val_id          in     number
  ,p_object_version_number        in     number
  ,p_validate			  in	 number default hr_api.g_false_num
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'delete_quest_answer_val';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_quest_answer_val;
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
   hr_quest_ans_val_api.delete_quest_answer_val
    (p_quest_answer_val_id          => p_quest_answer_val_id
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
	rollback to delete_quest_answer_val;
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
    rollback to delete_quest_answer_val;
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
    rollback to delete_quest_answer_val;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_quest_answer_val;
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_quest_answer_val >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_quest_answer_val
  (p_quest_answer_val_id          in     number
  ,p_object_version_number        in out nocopy number
  ,p_value                        in     varchar2  default hr_api.g_varchar2
  ,p_validate			  in	 number default hr_api.g_false_num
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
  l_proc    varchar2(72) := g_package ||'update_quest_answer_val';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_quest_answer_val;
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
    hr_quest_ans_val_api.update_quest_answer_val
    (p_quest_answer_val_id          => p_quest_answer_val_id
    ,p_object_version_number        => p_object_version_number
    ,p_value                        => p_value
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
	rollback to update_quest_answer_val;
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
    rollback to update_quest_answer_val;
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
    rollback to update_quest_answer_val;
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
end update_quest_answer_val;

-- ----------------------------------------------------------------------------
-- |---------------------------< process_api >--------------------------------|
-- ----------------------------------------------------------------------------

Procedure process_api
(
  p_document            in         CLOB
 ,p_return_status       out nocopy VARCHAR2
 ,p_validate            in         number    default hr_api.g_false_num
 ,p_effective_date      in         date      default null
)
IS
   l_postState VARCHAR2(2);
   l_return_status VARCHAR2(1);
   l_commitElement xmldom.DOMElement;
   l_object_version_number number;
   l_parser xmlparser.Parser;
   l_CommitNode xmldom.DOMNode;
   l_proc    varchar2(72) := g_package || 'process_api';

BEGIN

   hr_utility.set_location(' Entering:' || l_proc,10);
   hr_utility.set_location(' CLOB --> xmldom.DOMNode:' || l_proc,15);

   l_parser      := xmlparser.newParser;
   xmlparser.ParseCLOB(l_parser,p_document);
   l_CommitNode  := xmldom.makeNode(xmldom.getDocumentElement(xmlparser.getDocument(l_parser)));

   hr_utility.set_location('Extracting the PostState:' || l_proc,20);

   l_commitElement := xmldom.makeElement(l_CommitNode);
   l_postState := xmldom.getAttribute(l_commitElement, 'PS');
   l_object_version_number := hr_transaction_swi.getNumberValue(l_CommitNode,'ObjectVersionNumber');

   if l_postState = '0' then

        insert_quest_answer_val
      ( p_quest_answer_val_id          => hr_transaction_swi.getNumberValue(l_CommitNode,'QuestAnswerValId',null)
       ,p_questionnaire_answer_id      => hr_transaction_swi.getNumberValue(l_CommitNode,'QuestionnaireAnswerId',null)
       ,p_field_id                     => hr_transaction_swi.getNumberValue(l_CommitNode,'FieldId',null)
       ,p_object_version_number        => l_object_version_number
       ,p_value                        => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Value',null)
       ,p_validate                     => p_validate
       ,p_return_status                => l_return_status
      );

   elsif l_postState = '2' then

        update_quest_answer_val
      ( p_quest_answer_val_id          => hr_transaction_swi.getNumberValue(l_CommitNode,'QuestAnswerValId')
       ,p_object_version_number        => l_object_version_number
       ,p_value                        => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Value')
       ,p_validate                     => p_validate
       ,p_return_status                => l_return_status
      );

   elsif l_postState = '3' then

        delete_quest_answer_val
      ( p_quest_answer_val_id          => hr_transaction_swi.getNumberValue(l_CommitNode,'QuestAnswerValId')
       ,p_object_version_number        => l_object_version_number
       ,p_validate                     => p_validate
       ,p_return_status                => l_return_status
      );

      p_return_status := l_return_status;

   end if;

   hr_utility.set_location('Exiting:' || l_proc,40);

END process_api;

end hr_quest_ans_val_swi;

/
