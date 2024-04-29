--------------------------------------------------------
--  DDL for Package Body IRC_VARIABLE_COMP_ELEMENT_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_VARIABLE_COMP_ELEMENT_SWI" As
/* $Header: irvceswi.pkb 120.1.12010000.2 2009/10/05 18:32:13 amikukum ship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'irc_variable_comp_element_swi.';
--
-- ----------------------------------------------------------------------------
-- |---------------------< create_variable_compensation >---------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_variable_compensation
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_vacancy_id                   in     number
  ,p_variable_comp_lookup         in     varchar2
  ,p_effective_date               in     date
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
  l_proc    varchar2(72) := g_package ||'create_variable_compensation';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_variable_comp_swi;
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
  irc_variable_comp_element_api.create_variable_compensation
    (p_validate                     => l_validate
    ,p_vacancy_id                   => p_vacancy_id
    ,p_variable_comp_lookup         => p_variable_comp_lookup
    ,p_effective_date               => p_effective_date
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
    --  at least one error message exists in the list.
    --
    rollback to create_variable_comp_swi;
    --
    -- Reset IN OUT paramters and set OUT parameters
    --
    p_object_version_number        := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,30);
  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise
    -- the error.
    --
    rollback to create_variable_comp_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc, 40);
       raise;
    end if;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving: ' || l_proc, 50);
end create_variable_compensation;
-- ----------------------------------------------------------------------------
-- |---------------------< delete_variable_compensation >---------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_variable_compensation
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_vacancy_id                   in     number
  ,p_variable_comp_lookup         in     varchar2
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  --
  l_object_version_number irc_variable_comp_elements.object_version_number%TYPE;
  --
  cursor get_object_version_number(p_vacancy_id irc_variable_comp_elements.vacancy_id%TYPE,
                                   p_variable_comp_lookup irc_variable_comp_elements.variable_comp_lookup%TYPE) is
    select object_version_number
    from   irc_variable_comp_elements
    where  vacancy_id = p_vacancy_id
     and   variable_comp_lookup = p_variable_comp_lookup;
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'delete_variable_compensation';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_variable_comp_swi;
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
  l_object_version_number := p_object_version_number;
  if(p_object_version_number is null or p_object_version_number < 0) then
    open get_object_version_number(p_vacancy_id,p_variable_comp_lookup);
    fetch get_object_version_number into l_object_version_number;
    close get_object_version_number;
  end if;
  --
  --
  irc_variable_comp_element_api.delete_variable_compensation
    (p_validate                     => l_validate
    ,p_vacancy_id                   => p_vacancy_id
    ,p_variable_comp_lookup         => p_variable_comp_lookup
    ,p_object_version_number        => l_object_version_number
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
    --  at least one error message exists in the list.
    --
    rollback to delete_variable_comp_swi;
    --
    -- Reset IN OUT paramters and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,30);
  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise
    -- the error.
    --
    rollback to delete_variable_comp_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc, 40);
       raise;
    end if;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving: ' || l_proc, 50);
end delete_variable_compensation;
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
   l_commitElement           xmldom.DOMElement;
   l_parser                  xmlparser.Parser;
   l_CommitNode              xmldom.DOMNode;

   l_proc               varchar2(72)  := g_package || 'process_offers_api';
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
     create_variable_compensation
     (p_validate               => p_validate
     ,p_effective_date         => l_effective_date
     ,p_vacancy_id             => hr_transaction_swi.getNumberValue(l_CommitNode,'VacancyId',NULL)
     ,p_variable_comp_lookup   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'VariableCompLookup',NULL)
     ,p_object_version_number  => l_object_version_number
     ,p_return_status          => l_return_status
     );
     --
   elsif l_postState = '3' then
--
   hr_utility.set_location('deleting :' || l_proc,33);
--
     delete_variable_compensation
     (p_validate               => p_validate
     ,p_object_version_number  => l_object_version_number
     ,p_vacancy_id             => hr_transaction_swi.getNumberValue(l_CommitNode,'VacancyId',NULL)
     ,p_variable_comp_lookup   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'VariableCompLookup',NULL)
     ,p_return_status          => l_return_status
     );
     --
   end if;

   p_return_status := l_return_status;

   hr_utility.set_location
     ('Exiting :'|| l_proc || ': return status :'|| l_return_status || ':',40);

end process_api;
--
end irc_variable_comp_element_swi;

/
