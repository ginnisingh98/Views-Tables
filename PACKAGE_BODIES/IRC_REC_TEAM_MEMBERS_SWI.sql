--------------------------------------------------------
--  DDL for Package Body IRC_REC_TEAM_MEMBERS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_REC_TEAM_MEMBERS_SWI" As
/* $Header: irrtmswi.pkb 120.3.12010000.2 2008/09/05 10:10:34 pvelugul ship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'irc_rec_team_members_swi.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_rec_team_member >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_rec_team_member
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_rec_team_member_id           in     number
  ,p_person_id                     in     number
  ,p_vacancy_id                   in     number
  ,p_job_id                       in     number    default null
  ,p_start_date                   in     date      default null
  ,p_end_date                     in     date      default null
  ,p_update_allowed               in     varchar2  default null
  ,p_delete_allowed               in     varchar2  default null
  ,p_interview_security            in     varchar2  default 'SELF'
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  l_rec_team_member_id            number;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'create_rec_team_member';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_rec_team_member_swi;
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
  irc_rtm_ins.set_base_key_value
    (p_rec_team_member_id => p_rec_team_member_id
    );
  --
  -- Call API
  --
  irc_rec_team_members_api.create_rec_team_member
    (p_validate                     => l_validate
    ,p_rec_team_member_id           => l_rec_team_member_id
    ,p_person_id                    => p_person_id
    ,p_vacancy_id                   => p_vacancy_id
    ,p_job_id                       => p_job_id
    ,p_start_date                   => p_start_date
    ,p_end_date                     => p_end_date
    ,p_update_allowed               => p_update_allowed
    ,p_delete_allowed               => p_delete_allowed
    ,p_interview_security            => p_interview_security
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
    rollback to create_rec_team_member_swi;
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
    rollback to create_rec_team_member_swi;
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
end create_rec_team_member;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_rec_team_member >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_rec_team_member
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_rec_team_member_id           in     number
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
  l_proc    varchar2(72) := g_package ||'delete_rec_team_member';
  l_object_version_number irc_rec_team_members.object_version_number%TYPE;

  cursor get_object_version_number(p_rec_team_member_id irc_rec_team_members.rec_team_member_id%TYPE) is
  select object_version_number
    from irc_rec_team_members
   where rec_team_member_id = p_rec_team_member_id;

Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_rec_team_member_swi;
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
    open get_object_version_number(p_rec_team_member_id);
    fetch get_object_version_number into l_object_version_number;
    close get_object_version_number;
  end if;
  --
  irc_rec_team_members_api.delete_rec_team_member
    (p_validate                     => l_validate
    ,p_rec_team_member_id           => p_rec_team_member_id
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
    rollback to delete_rec_team_member_swi;
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
    rollback to delete_rec_team_member_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc, 40);
       raise;
    end if;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving: ' || l_proc, 50);
end delete_rec_team_member;
-- ----------------------------------------------------------------------------
-- |------------------------< update_rec_team_member >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_rec_team_member
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_rec_team_member_id           in     number
  ,p_person_id                    in     number    default hr_api.g_number
  ,p_party_id                     in     number    default hr_api.g_number
  ,p_vacancy_id                   in     number    default hr_api.g_number
  ,p_object_version_number        in out nocopy number
  ,p_job_id                       in     number    default hr_api.g_number
  ,p_start_date                   in     date      default hr_api.g_date
  ,p_end_date                     in     date      default hr_api.g_date
  ,p_update_allowed               in     varchar2  default hr_api.g_varchar2
  ,p_delete_allowed               in     varchar2  default hr_api.g_varchar2
  ,p_interview_security            in     varchar2  default 'SELF'
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
  l_proc    varchar2(72) := g_package ||'update_rec_team_member';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_rec_team_member_swi;
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
  irc_rec_team_members_api.update_rec_team_member
    (p_validate                     => l_validate
    ,p_rec_team_member_id           => p_rec_team_member_id
    ,p_person_id                    => p_person_id
    ,p_object_version_number        => p_object_version_number
    ,p_job_id                       => p_job_id
    ,p_party_id                     => p_party_id
    ,p_vacancy_id                   => p_vacancy_id
    ,p_start_date                   => p_start_date
    ,p_end_date                     => p_end_date
    ,p_update_allowed               => p_update_allowed
    ,p_delete_allowed               => p_delete_allowed
    ,p_interview_security            => p_interview_security
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
    rollback to update_rec_team_member_swi;
    --
    -- Reset IN OUT paramters and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
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
    rollback to update_rec_team_member_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc, 40);
       raise;
    end if;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving: ' || l_proc, 50);
end update_rec_team_member;
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
  l_rec_team_member_id      number;
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
  l_rec_team_member_id    := hr_transaction_swi.getNumberValue(l_CommitNode,'RecTeamMemberId');
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
    create_rec_team_member
    (p_validate               => p_validate
    ,p_rec_team_member_id     => l_rec_team_member_id
    ,p_person_id              => hr_transaction_swi.getNumberValue(l_CommitNode,'PersonId',NULL)
    ,p_vacancy_id             => hr_transaction_swi.getNumberValue(l_CommitNode,'VacancyId',NULL)
    ,p_job_id                 => hr_transaction_swi.getNumberValue(l_CommitNode,'JobId',NULL)
    ,p_start_date             => hr_transaction_swi.getDateValue(l_CommitNode,'StartDate',NULL)
    ,p_end_date               => hr_transaction_swi.getDateValue(l_CommitNode,'EndDate',NULL)
    ,p_update_allowed         => hr_transaction_swi.getVarchar2Value(l_CommitNode,'UpdateAllowed',NULL)
    ,p_delete_allowed         => hr_transaction_swi.getVarchar2Value(l_CommitNode,'DeleteAllowed',NULL)
    ,p_interview_security      => hr_transaction_swi.getVarchar2Value(l_CommitNode,'InterviewSecurity',NULL)
    ,p_object_version_number  => l_object_version_number
    ,p_return_status          => l_return_status
    );
  --
  elsif l_postState = '2' then
--
  hr_utility.set_location('updating :' || l_proc,32);
  --
    update_rec_team_member
    (p_validate               => p_validate
    ,p_rec_team_member_id     => l_rec_team_member_id
    ,p_person_id              => hr_transaction_swi.getNumberValue(l_CommitNode,'PersonId',NULL)
    ,p_party_id               => hr_transaction_swi.getNumberValue(l_CommitNode,'PartyId',NULL)
    ,p_vacancy_id             => hr_transaction_swi.getNumberValue(l_CommitNode,'VacancyId',NULL)
    ,p_job_id                 => hr_transaction_swi.getNumberValue(l_CommitNode,'JobId',NULL)
    ,p_start_date             => hr_transaction_swi.getDateValue(l_CommitNode,'StartDate',NULL)
    ,p_end_date               => hr_transaction_swi.getDateValue(l_CommitNode,'EndDate',NULL)
    ,p_update_allowed         => hr_transaction_swi.getVarchar2Value(l_CommitNode,'UpdateAllowed',NULL)
    ,p_delete_allowed         => hr_transaction_swi.getVarchar2Value(l_CommitNode,'DeleteAllowed',NULL)
    ,p_interview_security      => hr_transaction_swi.getVarchar2Value(l_CommitNode,'InterviewSecurity',NULL)
    ,p_object_version_number  => l_object_version_number
    ,p_return_status          => l_return_status
    );
  --
  elsif l_postState = '3' then
--
  hr_utility.set_location('deleting :' || l_proc,33);
  --
    delete_rec_team_member
    (p_validate               => p_validate
    ,p_object_version_number  => l_object_version_number
    ,p_rec_team_member_id     => l_rec_team_member_id
    ,p_return_status          => l_return_status
    );
  --
  end if;

  p_return_status := l_return_status;

  hr_utility.set_location
    ('Exiting :'|| l_proc || ': return status :'|| l_return_status || ':',40);

end process_api;
--
end irc_rec_team_members_swi;

/
