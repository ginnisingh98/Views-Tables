--------------------------------------------------------
--  DDL for Package Body PER_REC_ACTIVITY_FOR_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_REC_ACTIVITY_FOR_SWI" As
/* $Header: percfswi.pkb 120.2 2006/12/19 01:24:22 gjaggava noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'per_rec_activity_for_swi.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_rec_activity_for >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_rec_activity_for
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_rec_activity_for_id          in     number
  ,p_business_group_id            in     number
  ,p_vacancy_id                   in     number
  ,p_rec_activity_id              in     number
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
  l_rec_activity_for_id          number;
  l_proc    varchar2(72) := g_package ||'create_rec_activity_for';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_rec_activity_for_swi;
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
  per_rcf_ins.set_base_key_value
    (p_rec_activity_for_id => p_rec_activity_for_id
    );
  --
  -- Call API
  --
  per_rec_activity_for_api.create_rec_activity_for
    (p_validate                     => l_validate
    ,p_rec_activity_for_id          => l_rec_activity_for_id
    ,p_business_group_id            => p_business_group_id
    ,p_vacancy_id                   => p_vacancy_id
    ,p_rec_activity_id              => p_rec_activity_id
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
    rollback to create_rec_activity_for_swi;
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
    rollback to create_rec_activity_for_swi;
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
end create_rec_activity_for;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_rec_activity_for >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_rec_activity_for
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_rec_activity_for_id          in     number
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
  l_proc    varchar2(72) := g_package ||'delete_rec_activity_for';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_rec_activity_for_swi;
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
  per_rec_activity_for_api.delete_rec_activity_for
    (p_validate                     => l_validate
    ,p_rec_activity_for_id          => p_rec_activity_for_id
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
    rollback to delete_rec_activity_for_swi;
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
    rollback to delete_rec_activity_for_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_rec_activity_for;
-- ----------------------------------------------------------------------------
-- |------------------------< update_rec_activity_for >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_rec_activity_for
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_rec_activity_for_id          in     number
  ,p_vacancy_id                   in     number    default hr_api.g_number
  ,p_rec_activity_id              in     number    default hr_api.g_number
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
  l_proc    varchar2(72) := g_package ||'update_rec_activity_for';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_rec_activity_for_swi;
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
  per_rec_activity_for_api.update_rec_activity_for
    (p_validate                     => l_validate
    ,p_rec_activity_for_id          => p_rec_activity_for_id
    ,p_vacancy_id                   => p_vacancy_id
    ,p_rec_activity_id              => p_rec_activity_id
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
    rollback to update_rec_activity_for_swi;
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
    rollback to update_rec_activity_for_swi;
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
end update_rec_activity_for;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< process_api >-------------------------------|
-- ----------------------------------------------------------------------------

procedure process_api
(
  p_document            in         CLOB
 ,p_return_status       out nocopy VARCHAR2
 ,p_validate            in         number    default hr_api.g_false_num
 ,p_effective_date      in         date      default null
)
IS
   l_postState               VARCHAR2(2);
   l_return_status           VARCHAR2(1);
   l_object_version_number   number;
   l_rec_activity_for_id     number;
   l_commitElement           xmldom.DOMElement;
   l_parser                  xmlparser.Parser;
   l_CommitNode              xmldom.DOMNode;

   l_proc               varchar2(72)  := g_package || 'process_api';
   l_effective_date     date          :=  trunc(sysdate);

BEGIN
--
   hr_utility.set_location(' Entering:' || l_proc,10);
   hr_utility.set_location(' CLOB --> xmldom.DOMNode:' || l_proc,15);
--
   l_parser      := xmlparser.newParser;
   xmlparser.ParseCLOB(l_parser,p_document);
   l_CommitNode  := xmldom.makeNode(xmldom.getDocumentElement(xmlparser.getDocument(l_parser)));
--
   hr_utility.set_location('Extracting the PostState:' || l_proc,20);

   l_commitElement := xmldom.makeElement(l_CommitNode);
   l_postState := xmldom.getAttribute(l_commitElement, 'PS');
--
--Get the values for in/out parameters
--
   l_object_version_number := hr_transaction_swi.getNumberValue(l_CommitNode,'ObjectVersionNumber');
   l_rec_activity_for_id := hr_transaction_swi.getNumberValue(l_CommitNode,'RecruitmentActivityForId');
--
   if p_effective_date is null then
     l_effective_date := trunc(sysdate);
   else
     l_effective_date := p_effective_date;
   end if;
--
   if l_postState = '0' then
--
   hr_utility.set_location('creating :' || l_proc,30);
     --
     create_rec_activity_for
     (p_validate               => p_validate
     ,p_rec_activity_for_id    => l_rec_activity_for_id
     ,p_business_group_id      => hr_transaction_swi.getNumberValue(l_CommitNode,'BusinessGroupId',NULL)
     ,p_vacancy_id             => hr_transaction_swi.getNumberValue(l_CommitNode,'VacancyId',NULL)
     ,p_rec_activity_id        => hr_transaction_swi.getNumberValue(l_CommitNode,'RecruitmentActivityId',NULL)
     ,p_object_version_number  => l_object_version_number
     ,p_return_status          => l_return_status
     );
     --
   elsif l_postState = '2' then
--
   hr_utility.set_location('updating :' || l_proc,32);
     --
     update_rec_activity_for
     (p_validate               => p_validate
     ,p_rec_activity_for_id    => l_rec_activity_for_id
     ,p_vacancy_id             => hr_transaction_swi.getNumberValue(l_CommitNode,'VacancyId',NULL)
     ,p_rec_activity_id        => hr_transaction_swi.getNumberValue(l_CommitNode,'RecruitmentActivityId',NULL)
     ,p_object_version_number  => l_object_version_number
     ,p_return_status          => l_return_status
     );
     --
   elsif l_postState = '3' then
--
   hr_utility.set_location('deleting :' || l_proc,33);
     --
     -- we completely ignore deletes here as parent
     -- recruitment_activity.process_api removes all child
     -- recruitment_activity_for entities. This is needed to avoid
     -- constraint violation as we have little control on the order of
     -- process_api invocation
     --
   end if;

   p_return_status := l_return_status;

   hr_utility.set_location
     ('Exiting :'|| l_proc || ': return status :'|| l_return_status || ':',40);

end process_api;

--
end per_rec_activity_for_swi;

/
