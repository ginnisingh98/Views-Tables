--------------------------------------------------------
--  DDL for Package Body HR_PARTICIPANTS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PARTICIPANTS_SWI" As
/* $Header: peparswi.pkb 120.1 2007/06/20 07:48:40 rapandi ship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'hr_participants_swi.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_participant >--------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_participant
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_business_group_id            in     number
  ,p_questionnaire_template_id    in     number    default null
  ,p_participation_in_table       in     varchar2
  ,p_participation_in_column      in     varchar2
  ,p_participation_in_id          in     number
  ,p_participation_status         in     varchar2  default null
  ,p_participation_type           in     varchar2  default null
  ,p_last_notified_date           in     date      default null
  ,p_date_completed               in     date      default null
  ,p_comments                     in     varchar2  default null
  ,p_person_id                    in     number
  ,p_attribute_category           in     varchar2  default null
  ,p_attribute1                   in     varchar2  default null
  ,p_attribute2                   in     varchar2  default null
  ,p_attribute3                   in     varchar2  default null
  ,p_attribute4                   in     varchar2  default null
  ,p_attribute5                   in     varchar2  default null
  ,p_attribute6                   in     varchar2  default null
  ,p_attribute7                   in     varchar2  default null
  ,p_attribute8                   in     varchar2  default null
  ,p_attribute9                   in     varchar2  default null
  ,p_attribute10                  in     varchar2  default null
  ,p_attribute11                  in     varchar2  default null
  ,p_attribute12                  in     varchar2  default null
  ,p_attribute13                  in     varchar2  default null
  ,p_attribute14                  in     varchar2  default null
  ,p_attribute15                  in     varchar2  default null
  ,p_attribute16                  in     varchar2  default null
  ,p_attribute17                  in     varchar2  default null
  ,p_attribute18                  in     varchar2  default null
  ,p_attribute19                  in     varchar2  default null
  ,p_attribute20                  in     varchar2  default null
  ,p_participant_id               in	 number
  ,p_participant_usage_status	  in 	 varchar2  default null
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  l_participant_id number;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'create_participant';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_participant_swi;
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
  per_par_ins.set_base_key_value
        (p_participant_id => p_participant_id
    );
  --
  -- Call API
  --
  hr_participants_api.create_participant
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_business_group_id            => p_business_group_id
    ,p_questionnaire_template_id    => p_questionnaire_template_id
    ,p_participation_in_table       => p_participation_in_table
    ,p_participation_in_column      => p_participation_in_column
    ,p_participation_in_id          => p_participation_in_id
    ,p_participation_status         => p_participation_status
    ,p_participation_type           => p_participation_type
    ,p_last_notified_date           => p_last_notified_date
    ,p_date_completed               => p_date_completed
    ,p_comments                     => p_comments
    ,p_person_id                    => p_person_id
    ,p_attribute_category           => p_attribute_category
    ,p_attribute1                   => p_attribute1
    ,p_attribute2                   => p_attribute2
    ,p_attribute3                   => p_attribute3
    ,p_attribute4                   => p_attribute4
    ,p_attribute5                   => p_attribute5
    ,p_attribute6                   => p_attribute6
    ,p_attribute7                   => p_attribute7
    ,p_attribute8                   => p_attribute8
    ,p_attribute9                   => p_attribute9
    ,p_attribute10                  => p_attribute10
    ,p_attribute11                  => p_attribute11
    ,p_attribute12                  => p_attribute12
    ,p_attribute13                  => p_attribute13
    ,p_attribute14                  => p_attribute14
    ,p_attribute15                  => p_attribute15
    ,p_attribute16                  => p_attribute16
    ,p_attribute17                  => p_attribute17
    ,p_attribute18                  => p_attribute18
    ,p_attribute19                  => p_attribute19
    ,p_attribute20                  => p_attribute20
    ,p_participant_id               => l_participant_id
    ,p_object_version_number        => p_object_version_number
    ,p_participant_usage_status		=> p_participant_usage_status
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
    rollback to create_participant_swi;
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
    rollback to create_participant_swi;
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
end create_participant;
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_participant >--------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_participant
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_participant_id               in     number
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
  l_proc    varchar2(72) := g_package ||'delete_participant';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_participant_swi;
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
  hr_participants_api.delete_participant
    (p_validate                     => l_validate
    ,p_participant_id               => p_participant_id
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
    rollback to delete_participant_swi;
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
    rollback to delete_participant_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_participant;
-- ----------------------------------------------------------------------------
-- |--------------------------< update_participant >--------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_participant
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_participant_id               in     number
  ,p_object_version_number        in out nocopy number
  ,p_questionnaire_template_id    in     number    default hr_api.g_number
  ,p_participation_status         in     varchar2  default hr_api.g_varchar2
  ,p_participation_type           in     varchar2  default hr_api.g_varchar2
  ,p_last_notified_date           in     date      default hr_api.g_date
  ,p_date_completed               in     date      default hr_api.g_date
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_person_id                    in     number    default hr_api.g_number
  ,p_attribute_category           in     varchar2  default hr_api.g_varchar2
  ,p_attribute1                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute2                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute3                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute4                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute5                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute6                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute7                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute8                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute9                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute10                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute11                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute12                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute13                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute14                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute15                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute16                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute17                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute18                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute19                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute20                  in     varchar2  default hr_api.g_varchar2
  ,p_participant_usage_status	    in 	   varchar2  default hr_api.g_varchar2
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
  l_proc    varchar2(72) := g_package ||'update_participant';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_participant_swi;
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
  hr_participants_api.update_participant
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_participant_id               => p_participant_id
    ,p_object_version_number        => p_object_version_number
    ,p_questionnaire_template_id    => p_questionnaire_template_id
    ,p_participation_status         => p_participation_status
    ,p_participation_type           => p_participation_type
    ,p_last_notified_date           => p_last_notified_date
    ,p_date_completed               => p_date_completed
    ,p_comments                     => p_comments
    ,p_person_id                    => p_person_id
    ,p_attribute_category           => p_attribute_category
    ,p_attribute1                   => p_attribute1
    ,p_attribute2                   => p_attribute2
    ,p_attribute3                   => p_attribute3
    ,p_attribute4                   => p_attribute4
    ,p_attribute5                   => p_attribute5
    ,p_attribute6                   => p_attribute6
    ,p_attribute7                   => p_attribute7
    ,p_attribute8                   => p_attribute8
    ,p_attribute9                   => p_attribute9
    ,p_attribute10                  => p_attribute10
    ,p_attribute11                  => p_attribute11
    ,p_attribute12                  => p_attribute12
    ,p_attribute13                  => p_attribute13
    ,p_attribute14                  => p_attribute14
    ,p_attribute15                  => p_attribute15
    ,p_attribute16                  => p_attribute16
    ,p_attribute17                  => p_attribute17
    ,p_attribute18                  => p_attribute18
    ,p_attribute19                  => p_attribute19
    ,p_attribute20                  => p_attribute20
    ,p_participant_usage_status	  	=> p_participant_usage_status
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
    rollback to update_participant_swi;
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
    rollback to update_participant_swi;
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
end update_participant;

-- ----------------------------------------------------------------------------
-- |---------------------------< process_api >--------------------------------|
-- ----------------------------------------------------------------------------

Procedure process_api
( p_document            in         CLOB
 ,p_return_status       out nocopy VARCHAR2
 ,p_validate            in         number    default hr_api.g_false_num
 ,p_effective_date      in         date      default null
)
IS
   l_postState VARCHAR2(2);
   l_return_status VARCHAR2(1);
   l_object_version_number number;
   l_commitElement xmldom.DOMElement;
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

       create_participant
      ( p_validate                     => p_validate
       ,p_effective_date               => p_effective_date
       ,p_business_group_id            => hr_transaction_swi.getNumberValue(l_CommitNode,'BusinessGroupId',null)
       ,p_questionnaire_template_id    => hr_transaction_swi.getNumberValue(l_CommitNode,'QuestionnaireTemplateId',null)
       ,p_participation_in_table       => hr_transaction_swi.getVarchar2Value(l_CommitNode,'ParticipationInTable',null)
       ,p_participation_in_column      => hr_transaction_swi.getVarchar2Value(l_CommitNode,'ParticipationInColumn',null)
       ,p_participation_in_id          => hr_transaction_swi.getNumberValue(l_CommitNode,'ParticipationInId',null)
       ,p_participation_status         => hr_transaction_swi.getVarchar2Value(l_CommitNode,'ParticipationStatus',null)
       ,p_participation_type           => hr_transaction_swi.getVarchar2Value(l_CommitNode,'ParticipationType',null)
       ,p_last_notified_date           => hr_transaction_swi.getDateValue(l_CommitNode,'LastNotifiedDate',null)
       ,p_date_completed               => hr_transaction_swi.getDateValue(l_CommitNode,'DateCompleted',null)
       ,p_comments                     => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Comments',null)
       ,p_person_id                    => hr_transaction_swi.getNumberValue(l_CommitNode,'PersonId',null)
       ,p_attribute_category           => hr_transaction_swi.getVarchar2Value(l_CommitNode,'AttributeCategory',null)
       ,p_attribute1                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute1',null)
       ,p_attribute2                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute2',null)
       ,p_attribute3                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute3',null)
       ,p_attribute4                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute4',null)
       ,p_attribute5                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute5',null)
       ,p_attribute6                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute6',null)
       ,p_attribute7                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute7',null)
       ,p_attribute8                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute8',null)
       ,p_attribute9                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute9',null)
       ,p_attribute10                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute10',null)
       ,p_attribute11                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute11',null)
       ,p_attribute12                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute12',null)
       ,p_attribute13                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute13',null)
       ,p_attribute14                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute14',null)
       ,p_attribute15                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute15',null)
       ,p_attribute16                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute16',null)
       ,p_attribute17                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute17',null)
       ,p_attribute18                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute18',null)
       ,p_attribute19                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute19',null)
       ,p_attribute20                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute20',null)
       ,p_participant_id               => hr_transaction_swi.getNumberValue(l_CommitNode,'ParticipantId',null)
       ,p_object_version_number        => l_object_version_number
       ,p_return_status                => l_return_status
      );

   elsif l_postState = '2' then

       update_participant
      ( p_validate                     => p_validate
       ,p_effective_date               => p_effective_date
       ,p_participant_id               => hr_transaction_swi.getNumberValue(l_CommitNode,'ParticipantId')
       ,p_object_version_number        => l_object_version_number
       ,p_questionnaire_template_id    => hr_transaction_swi.getNumberValue(l_CommitNode,'QuestionnaireTemplateId')
       ,p_participation_status         => hr_transaction_swi.getVarchar2Value(l_CommitNode,'ParticipationStatus')
       ,p_participation_type           => hr_transaction_swi.getVarchar2Value(l_CommitNode,'ParticipationType')
       ,p_last_notified_date           => hr_transaction_swi.getDateValue(l_CommitNode,'LastNotifiedDate')
       ,p_date_completed               => hr_transaction_swi.getDateValue(l_CommitNode,'DateCompleted')
       ,p_comments                     => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Comments')
       ,p_person_id                    => hr_transaction_swi.getNumberValue(l_CommitNode,'PersonId')
       ,p_attribute_category           => hr_transaction_swi.getVarchar2Value(l_CommitNode,'AttributeCategory')
       ,p_attribute1                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute1')
       ,p_attribute2                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute2')
       ,p_attribute3                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute3')
       ,p_attribute4                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute4')
       ,p_attribute5                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute5')
       ,p_attribute6                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute6')
       ,p_attribute7                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute7')
       ,p_attribute8                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute8')
       ,p_attribute9                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute9')
       ,p_attribute10                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute10')
       ,p_attribute11                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute11')
       ,p_attribute12                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute12')
       ,p_attribute13                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute13')
       ,p_attribute14                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute14')
       ,p_attribute15                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute15')
       ,p_attribute16                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute16')
       ,p_attribute17                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute17')
       ,p_attribute18                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute18')
       ,p_attribute19                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute19')
       ,p_attribute20                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute20')
       ,p_return_status                => l_return_status
      );

   elsif l_postState = '3' then

       delete_participant
      ( p_validate                     => p_validate
       ,p_participant_id               => hr_transaction_swi.getNumberValue(l_CommitNode,'ParticipantId')
       ,p_object_version_number        => l_object_version_number
       ,p_return_status                => l_return_status
      );

      p_return_status := l_return_status;

   end if;

   hr_utility.set_location('Exiting:' || l_proc,40);

END process_api;

end hr_participants_swi;

/
