--------------------------------------------------------
--  DDL for Package Body PER_RECRUITMENT_ACTIVITY_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_RECRUITMENT_ACTIVITY_SWI" As
/* $Header: peraaswi.pkb 120.2 2006/12/19 01:19:14 gjaggava noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'per_recruitment_activity_swi.';
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_recruitment_activity >---------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_recruitment_activity
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_business_group_id            in     number
  ,p_date_start                   in     date
  ,p_name                         in     varchar2
  ,p_authorising_person_id        in     number    default null
  ,p_run_by_organization_id       in     number    default null
  ,p_internal_contact_person_id   in     number    default null
  ,p_parent_recruitment_activity  in     number    default null
  ,p_currency_code                in     varchar2  default null
  ,p_actual_cost                  in     varchar2  default null
  ,p_comments                     in     long      default null
  ,p_contact_telephone_number     in     varchar2  default null
  ,p_date_closing                 in     date      default null
  ,p_date_end                     in     date      default null
  ,p_external_contact             in     varchar2  default null
  ,p_planned_cost                 in     varchar2  default null
  ,p_recruiting_site_id           in     number    default null
  ,p_recruiting_site_response     in     varchar2  default null
  ,p_last_posted_date             in     date      default null
  ,p_type                         in     varchar2  default null
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
  ,p_posting_content_id           in     number    default null
  ,p_status                       in     varchar2  default null
  ,p_object_version_number           out nocopy number
  ,p_recruitment_activity_id      in     number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_recruitment_activity_id      number;
  l_proc    varchar2(72) := g_package ||'create_recruitment_activity';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_rec_activity_swi;
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
  per_raa_ins.set_base_key_value
    (p_recruitment_activity_id => p_recruitment_activity_id
    );
  --
  -- Call API
  --
  per_recruitment_activity_api.create_recruitment_activity
    (p_validate                     => l_validate
    ,p_business_group_id            => p_business_group_id
    ,p_date_start                   => p_date_start
    ,p_name                         => p_name
    ,p_authorising_person_id        => p_authorising_person_id
    ,p_run_by_organization_id       => p_run_by_organization_id
    ,p_internal_contact_person_id   => p_internal_contact_person_id
    ,p_parent_recruitment_activity  => p_parent_recruitment_activity
    ,p_currency_code                => p_currency_code
    ,p_actual_cost                  => p_actual_cost
    ,p_comments                     => p_comments
    ,p_contact_telephone_number     => p_contact_telephone_number
    ,p_date_closing                 => p_date_closing
    ,p_date_end                     => p_date_end
    ,p_external_contact             => p_external_contact
    ,p_planned_cost                 => p_planned_cost
    ,p_recruiting_site_id           => p_recruiting_site_id
    ,p_recruiting_site_response     => p_recruiting_site_response
    ,p_last_posted_date             => p_last_posted_date
    ,p_type                         => p_type
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
    ,p_posting_content_id           => p_posting_content_id
    ,p_status                       => p_status
    ,p_object_version_number        => p_object_version_number
    ,p_recruitment_activity_id      => l_recruitment_activity_id
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
    rollback to create_rec_activity_swi;
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
    rollback to create_rec_activity_swi;
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
end create_recruitment_activity;
-- ----------------------------------------------------------------------------
-- |----------------------< delete_recruitment_activity >---------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_recruitment_activity
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_object_version_number        in     number
  ,p_recruitment_activity_id      in     number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'delete_recruitment_activity';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_rec_activity_swi;
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
  per_recruitment_activity_api.delete_recruitment_activity
    (p_validate                     => l_validate
    ,p_object_version_number        => p_object_version_number
    ,p_recruitment_activity_id      => p_recruitment_activity_id
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
    rollback to delete_rec_activity_swi;
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
    rollback to delete_rec_activity_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_recruitment_activity;
-- ----------------------------------------------------------------------------
-- |----------------------< update_recruitment_activity >---------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_recruitment_activity
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_recruitment_activity_id      in     number
  ,p_authorising_person_id        in     number    default hr_api.g_number
  ,p_run_by_organization_id       in     number    default hr_api.g_number
  ,p_internal_contact_person_id   in     number    default hr_api.g_number
  ,p_parent_recruitment_activity  in     number    default hr_api.g_number
  ,p_currency_code                in     varchar2  default hr_api.g_varchar2
  ,p_date_start                   in     date      default hr_api.g_date
  ,p_name                         in     varchar2  default hr_api.g_varchar2
  ,p_actual_cost                  in     varchar2  default hr_api.g_varchar2
  ,p_comments                     in     long      default hr_api.g_varchar2
  ,p_contact_telephone_number     in     varchar2  default hr_api.g_varchar2
  ,p_date_closing                 in     date      default hr_api.g_date
  ,p_date_end                     in     date      default hr_api.g_date
  ,p_external_contact             in     varchar2  default hr_api.g_varchar2
  ,p_planned_cost                 in     varchar2  default hr_api.g_varchar2
  ,p_recruiting_site_id           in     number    default hr_api.g_number
  ,p_recruiting_site_response     in     varchar2  default hr_api.g_varchar2
  ,p_last_posted_date             in     date      default hr_api.g_date
  ,p_type                         in     varchar2  default hr_api.g_varchar2
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
  ,p_posting_content_id           in     number    default hr_api.g_number
  ,p_status                       in     varchar2  default hr_api.g_varchar2
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
  l_proc    varchar2(72) := g_package ||'update_recruitment_activity';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_rec_activity_swi;
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
  per_recruitment_activity_api.update_recruitment_activity
    (p_validate                     => l_validate
    ,p_recruitment_activity_id      => p_recruitment_activity_id
    ,p_authorising_person_id        => p_authorising_person_id
    ,p_run_by_organization_id       => p_run_by_organization_id
    ,p_internal_contact_person_id   => p_internal_contact_person_id
    ,p_parent_recruitment_activity  => p_parent_recruitment_activity
    ,p_currency_code                => p_currency_code
    ,p_date_start                   => p_date_start
    ,p_name                         => p_name
    ,p_actual_cost                  => p_actual_cost
    ,p_comments                     => p_comments
    ,p_contact_telephone_number     => p_contact_telephone_number
    ,p_date_closing                 => p_date_closing
    ,p_date_end                     => p_date_end
    ,p_external_contact             => p_external_contact
    ,p_planned_cost                 => p_planned_cost
    ,p_recruiting_site_id           => p_recruiting_site_id
    ,p_recruiting_site_response     => p_recruiting_site_response
    ,p_last_posted_date             => p_last_posted_date
    ,p_type                         => p_type
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
    ,p_posting_content_id           => p_posting_content_id
    ,p_status                       => p_status
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
    rollback to update_rec_activity_swi;
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
    rollback to update_rec_activity_swi;
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
end update_recruitment_activity;
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
   l_recruitment_activity_id   number;
   l_commitElement           xmldom.DOMElement;
   l_parser                  xmlparser.Parser;
   l_CommitNode              xmldom.DOMNode;

   l_proc               varchar2(72)  := g_package || 'process_api';
   l_effective_date     date          :=  trunc(sysdate);
   l_posting_date       date;

   cursor csr_rec_act_for(rec_act_id in number) is
     select recruitment_activity_for_id, object_version_number
     from per_recruitment_activity_for
     where recruitment_activity_id = rec_act_id;

   cursor csr_rec_act_ovn(rec_act_id in number) is
     select object_version_number
     from per_recruitment_activities
     where recruitment_activity_id = rec_act_id;

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
   l_recruitment_activity_id := hr_transaction_swi.getNumberValue(l_CommitNode,'RecruitmentActivityId');
--
   if p_effective_date is null then
     l_effective_date := trunc(sysdate);
   else
     l_effective_date := p_effective_date;
   end if;
--
  l_posting_date := get_posting_date
  ( p_type_flag           => hr_transaction_swi.getVarchar2Value(l_CommitNode,'RecruitingSiteType',NULL)
  , p_current_start_date  => hr_transaction_swi.getDateValue(l_CommitNode,'DateStart',NULL)
  , p_internal_start_date => hr_transaction_swi.getDateValue(l_CommitNode,'InternalStartDate',NULL)
  , p_dates_editable      => hr_transaction_swi.getVarchar2Value(l_CommitNode,'DatesEditable',NULL));
--
   if l_postState = '0' then
--
   hr_utility.set_location('creating :' || l_proc,30);
     --
     create_recruitment_activity
     (p_validate                     => p_validate
     ,p_business_group_id            => hr_transaction_swi.getNumberValue(l_CommitNode,'BusinessGroupId',NULL)
     ,p_date_start                   => l_posting_date
     ,p_name                         => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Name',NULL)
     ,p_date_closing                 => hr_transaction_swi.getDateValue(l_CommitNode,'DateClosing',NULL)
     ,p_date_end                     => hr_transaction_swi.getDateValue(l_CommitNode,'DateEnd',NULL)
     ,p_recruiting_site_id           => hr_transaction_swi.getNumberValue(l_CommitNode,'RecruitingSiteId',NULL)
     ,p_last_posted_date             => hr_transaction_swi.getDateValue(l_CommitNode,'LastPostedDate',NULL)
     ,p_attribute_category           => hr_transaction_swi.getVarchar2Value(l_CommitNode,'AttributeCategory',NULL)
     ,p_attribute1                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute1',NULL)
     ,p_attribute2                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute2',NULL)
     ,p_attribute3                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute3',NULL)
     ,p_attribute4                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute4',NULL)
     ,p_attribute5                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute5',NULL)
     ,p_attribute6                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute6',NULL)
     ,p_attribute7                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute7',NULL)
     ,p_attribute8                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute8',NULL)
     ,p_attribute9                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute9',NULL)
     ,p_attribute10                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute10',NULL)
     ,p_attribute11                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute11',NULL)
     ,p_attribute12                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute12',NULL)
     ,p_attribute13                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute13',NULL)
     ,p_attribute14                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute14',NULL)
     ,p_attribute15                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute15',NULL)
     ,p_attribute16                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute16',NULL)
     ,p_attribute17                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute17',NULL)
     ,p_attribute18                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute18',NULL)
     ,p_attribute19                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute19',NULL)
     ,p_attribute20                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute20',NULL)
     ,p_posting_content_id           => hr_transaction_swi.getNumberValue(l_CommitNode,'PostingContentId',NULL)
     ,p_recruitment_activity_id      => l_recruitment_activity_id
     ,p_object_version_number        => l_object_version_number
     ,p_return_status                => l_return_status
     );
     --
   elsif l_postState = '2' then
--
   hr_utility.set_location('updating :' || l_proc,32);
     --
     update_recruitment_activity
     (p_validate                     => p_validate
     ,p_recruitment_activity_id      => l_recruitment_activity_id
     ,p_authorising_person_id        => hr_transaction_swi.getNumberValue(l_CommitNode,'AuthorisingPersonId',NULL)
     ,p_run_by_organization_id       => hr_transaction_swi.getNumberValue(l_CommitNode,'RunByOrganizationId',NULL)
     ,p_internal_contact_person_id   => hr_transaction_swi.getNumberValue(l_CommitNode,'InternalContactPersonId',NULL)
     ,p_parent_recruitment_activity  => hr_transaction_swi.getNumberValue(l_CommitNode,'ParentRecruitmentActivity',NULL)
     ,p_currency_code                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'CurrencyCode',NULL)
     ,p_date_start                   => l_posting_date
     ,p_name                         => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Name',NULL)
     ,p_actual_cost                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'ActualCost',NULL)
     ,p_contact_telephone_number     => hr_transaction_swi.getVarchar2Value(l_CommitNode,'ContactTelephoneNumber',NULL)
     ,p_date_closing                 => hr_transaction_swi.getDateValue(l_CommitNode,'DateClosing',NULL)
     ,p_date_end                     => hr_transaction_swi.getDateValue(l_CommitNode,'DateEnd',NULL)
     ,p_external_contact             => hr_transaction_swi.getVarchar2Value(l_CommitNode,'ExternalContact',NULL)
     ,p_planned_cost                 => hr_transaction_swi.getVarchar2Value(l_CommitNode,'PlannedCost',NULL)
     ,p_recruiting_site_id           => hr_transaction_swi.getNumberValue(l_CommitNode,'RecruitingSiteId',NULL)
     ,p_recruiting_site_response     => hr_transaction_swi.getVarchar2Value(l_CommitNode,'RecruitingSiteResponse',NULL)
     ,p_last_posted_date             => hr_transaction_swi.getDateValue(l_CommitNode,'LastPostedDate',NULL)
     ,p_type                         => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Type',NULL)
     ,p_attribute_category           => hr_transaction_swi.getVarchar2Value(l_CommitNode,'AttributeCategory',NULL)
     ,p_attribute1                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute1',NULL)
     ,p_attribute2                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute2',NULL)
     ,p_attribute3                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute3',NULL)
     ,p_attribute4                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute4',NULL)
     ,p_attribute5                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute5',NULL)
     ,p_attribute6                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute6',NULL)
     ,p_attribute7                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute7',NULL)
     ,p_attribute8                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute8',NULL)
     ,p_attribute9                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute9',NULL)
     ,p_attribute10                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute10',NULL)
     ,p_attribute11                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute11',NULL)
     ,p_attribute12                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute12',NULL)
     ,p_attribute13                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute13',NULL)
     ,p_attribute14                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute14',NULL)
     ,p_attribute15                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute15',NULL)
     ,p_attribute16                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute16',NULL)
     ,p_attribute17                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute17',NULL)
     ,p_attribute18                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute18',NULL)
     ,p_attribute19                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute19',NULL)
     ,p_attribute20                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute20',NULL)
     ,p_posting_content_id           => hr_transaction_swi.getNumberValue(l_CommitNode,'PostingContentId',NULL)
     ,p_status                       => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Status',NULL)
     ,p_object_version_number        => l_object_version_number
     ,p_return_status                => l_return_status
     );
     --
   elsif l_postState = '3' then
--
   hr_utility.set_location('deleting :' || l_proc,33);
     --
     -- delete all child recruitment_activity_for rows before deleting
     -- the parent entity
     for rec_act_for in csr_rec_act_for(l_recruitment_activity_id) loop
       per_rec_activity_for_swi.delete_rec_activity_for
       (p_validate               => p_validate
       ,p_object_version_number  => rec_act_for.object_version_number
       ,p_rec_activity_for_id    => rec_act_for.recruitment_activity_for_id
       ,p_return_status          => l_return_status
       );
     end loop;

     -- the following if block is a work around for SSHR bug 5353275
     if l_object_version_number = hr_api.g_number then
       hr_utility.set_location('OVN is NULL for delete ' || l_proc, 36);
       open csr_rec_act_ovn(l_recruitment_activity_id);
       fetch csr_rec_act_ovn into l_object_version_number;
       close csr_rec_act_ovn;
     end if;
     --
     delete_recruitment_activity
     (p_validate                     => p_validate
     ,p_object_version_number        => l_object_version_number
     ,p_recruitment_activity_id      => l_recruitment_activity_id
     ,p_return_status                => l_return_status
     );
     --
   end if;

   p_return_status := l_return_status;

   hr_utility.set_location
     ('Exiting :'|| l_proc || ': return status :'|| l_return_status || ':',40);

end process_api;
--




--
--  If the start date of the external posting was not enterable
--  because the IRC: Internal Posting Days profile option was set then
--    the start date of the external posting will be set to be that
--    number of days after the start date of the internal posting.
--
--  find the internal site and determine any correction to
--  the start date required
--
--  If the start date of the internal posting is before the approval date then
--    the start date of the internal posting will be moved to the approval date
--    the start date of the external posting will be moved by the same amount.
--
function get_posting_date
  (p_type_flag varchar2, p_current_start_date date,
   p_internal_start_date date, p_dates_editable varchar2)
return date is
--
  return_date date;
--
begin
--
hr_utility.trace('Entering get_posting_date');
--
  return_date := p_current_start_date;
--
  if (p_type_flag = 'I' AND p_current_start_date < sysdate() AND p_dates_editable = 'Y') then
--
hr_utility.trace('Moving internal date to approval date');
--
    return_date := sysdate;
  end if;
--
  if (p_type_flag = 'X') then
    if (p_dates_editable = 'N') then
--
hr_utility.trace('External date not editable - moving to internal date plus posting days');
--
    return_date := p_internal_start_date + get_internal_posting_days();
  else
--
hr_utility.trace('Dates Editable');
--
    if (p_type_flag = 'X' AND p_current_start_date < sysdate()) then
--
hr_utility.trace('moving external date');
--
      return_date := p_current_start_date + (sysdate - p_internal_start_date);
    end if;
  end if;
  end if;
--
hr_utility.trace('Exiting get_posting_date returning :' || to_char(return_date) || ':');
--
  return return_date;
--
end get_posting_date;
--
----------------------------------------------------------
FUNCTION get_internal_posting_days return number IS
--
number_of_days varchar2(10);
--
BEGIN
--
hr_utility.trace('Entering get_internal_posting_days');
--
number_of_days := fnd_profile.value('IRC_INTERNAL_POSTING_DAYS');

if (number_of_days is null) then
hr_utility.trace('Number of days is null - returning -1');
  return -1;
else
hr_utility.trace('Returning number of days as :' || number_of_days || ':');
  return to_number(number_of_days);
end if;
--
END get_internal_posting_days;
--
--
----------------------------------------------------------
end per_recruitment_activity_swi;

/
