--------------------------------------------------------
--  DDL for Package Body IRC_AGENCY_VACANCIES_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_AGENCY_VACANCIES_SWI" As
/* $Header: iriavswi.pkb 120.1.12010000.2 2008/08/05 10:48:12 ubhat ship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'irc_agency_vacancies_swi.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_agency_vacancy >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_agency_vacancy
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_agency_id                    in     number
  ,p_vacancy_id                   in     number
  ,p_start_date                   in     date      default null
  ,p_end_date                     in     date      default null
  ,p_max_allowed_applicants       in     number    default null
  ,p_manage_applicants_allowed    in     varchar2  default null
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
  ,p_attribute21                  in     varchar2  default null
  ,p_attribute22                  in     varchar2  default null
  ,p_attribute23                  in     varchar2  default null
  ,p_attribute24                  in     varchar2  default null
  ,p_attribute25                  in     varchar2  default null
  ,p_attribute26                  in     varchar2  default null
  ,p_attribute27                  in     varchar2  default null
  ,p_attribute28                  in     varchar2  default null
  ,p_attribute29                  in     varchar2  default null
  ,p_attribute30                  in     varchar2  default null
  ,p_object_version_number           out nocopy number
  ,p_agency_vacancy_id            in     number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_agency_vacancy_id            number;
  l_proc    varchar2(72) := g_package ||'create_agency_vacancy';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_agency_vacancy_swi;
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
  irc_iav_ins.set_base_key_value
    (p_agency_vacancy_id => p_agency_vacancy_id
    );
  --
  -- Call API
  --
  irc_agency_vacancies_api.create_agency_vacancy
    (p_validate                     => l_validate
    ,p_agency_id                    => p_agency_id
    ,p_vacancy_id                   => p_vacancy_id
    ,p_start_date                   => p_start_date
    ,p_end_date                     => p_end_date
    ,p_max_allowed_applicants       => p_max_allowed_applicants
    ,p_manage_applicants_allowed    => p_manage_applicants_allowed
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
    ,p_attribute21                  => p_attribute21
    ,p_attribute22                  => p_attribute22
    ,p_attribute23                  => p_attribute23
    ,p_attribute24                  => p_attribute24
    ,p_attribute25                  => p_attribute25
    ,p_attribute26                  => p_attribute26
    ,p_attribute27                  => p_attribute27
    ,p_attribute28                  => p_attribute28
    ,p_attribute29                  => p_attribute29
    ,p_attribute30                  => p_attribute30
    ,p_object_version_number        => p_object_version_number
    ,p_agency_vacancy_id            => l_agency_vacancy_id
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
    rollback to create_agency_vacancy_swi;
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
    rollback to create_agency_vacancy_swi;
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
end create_agency_vacancy;
-- ----------------------------------------------------------------------------
-- |-------------------------< update_agency_vacancy >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_agency_vacancy
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_agency_vacancy_id            in     number
  ,p_agency_id                    in     number
  ,p_vacancy_id                   in     number
  ,p_start_date                   in     date
  ,p_end_date                     in     date
  ,p_max_allowed_applicants       in     number    default hr_api.g_number
  ,p_manage_applicants_allowed    in     varchar2  default hr_api.g_varchar2
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
  ,p_attribute21                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute22                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute23                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute24                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute25                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute26                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute27                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute28                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute29                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute30                  in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  l_object_version_number         number;

  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_agency_vacancy';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_agency_vacancy_swi;
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
  irc_agency_vacancies_api.update_agency_vacancy
    (p_validate                     => l_validate
    ,p_agency_vacancy_id            => p_agency_vacancy_id
    ,p_agency_id                    => p_agency_id
    ,p_vacancy_id                   => p_vacancy_id
    ,p_start_date                   => p_start_date
    ,p_end_date                     => p_end_date
    ,p_max_allowed_applicants       => p_max_allowed_applicants
    ,p_manage_applicants_allowed    => p_manage_applicants_allowed
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
    ,p_attribute21                  => p_attribute21
    ,p_attribute22                  => p_attribute22
    ,p_attribute23                  => p_attribute23
    ,p_attribute24                  => p_attribute24
    ,p_attribute25                  => p_attribute25
    ,p_attribute26                  => p_attribute26
    ,p_attribute27                  => p_attribute27
    ,p_attribute28                  => p_attribute28
    ,p_attribute29                  => p_attribute29
    ,p_attribute30                  => p_attribute30
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
    rollback to update_agency_vacancy_swi;
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
    rollback to update_agency_vacancy_swi;
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
end update_agency_vacancy;
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_agency_vacancy >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_agency_vacancy
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_agency_vacancy_id            in     number
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
  l_proc    varchar2(72) := g_package ||'delete_agency_vacancy';
  l_object_version_number irc_agency_vacancies.object_version_number%TYPE;

  cursor get_object_version_number(p_agency_vacancy_id irc_agency_vacancies.agency_vacancy_id%TYPE) is
  select object_version_number
    from irc_agency_vacancies
   where agency_vacancy_id = p_agency_vacancy_id;
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_agency_vacancy_swi;
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
    open get_object_version_number(p_agency_vacancy_id);
    fetch get_object_version_number into l_object_version_number;
    close get_object_version_number;
  end if;
  --
  irc_agency_vacancies_api.delete_agency_vacancy
    (p_validate                     => l_validate
    ,p_agency_vacancy_id            => p_agency_vacancy_id
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
    -- at least one message exists in the list.
    --
    rollback to delete_agency_vacancy_swi;
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
    rollback to delete_agency_vacancy_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_agency_vacancy;
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
   l_agency_vacancy_id       number;
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
   l_agency_vacancy_id := hr_transaction_swi.getNumberValue(l_CommitNode,'AgencyVacancyId');
--
   if p_effective_date is null then
     l_effective_date := trunc(sysdate);
   else
     l_effective_date := p_effective_date;
   end if;
--
   if l_postState = '0' then
--
   hr_utility.set_location('Extracting the PostState:' || l_proc,31);
     --
     create_agency_vacancy
     (p_validate                   => p_validate
     ,p_agency_id                  => hr_transaction_swi.getNumberValue(l_CommitNode,'AgencyId',NULL)
     ,p_vacancy_id                 => hr_transaction_swi.getNumberValue(l_CommitNode,'VacancyId',NULL)
     ,p_start_date                 => hr_transaction_swi.getDateValue(l_CommitNode,'StartDate',NULL)
     ,p_end_date                   => hr_transaction_swi.getDateValue(l_CommitNode,'EndDate',NULL)
     ,p_max_allowed_applicants     => hr_transaction_swi.getNumberValue(l_CommitNode,'MaxAllowedApplicants',NULL)
     ,p_manage_applicants_allowed  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'ManageApplicantsAllowed',NULL)
     ,p_attribute_category         => hr_transaction_swi.getVarchar2Value(l_CommitNode,'AttributeCategory',NULL)
     ,p_attribute1                 => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute1',NULL)
     ,p_attribute2                 => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute2',NULL)
     ,p_attribute3                 => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute3',NULL)
     ,p_attribute4                 => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute4',NULL)
     ,p_attribute5                 => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute5',NULL)
     ,p_attribute6                 => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute6',NULL)
     ,p_attribute7                 => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute7',NULL)
     ,p_attribute8                 => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute8',NULL)
     ,p_attribute9                 => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute9',NULL)
     ,p_attribute10                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute10',NULL)
     ,p_attribute11                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute11',NULL)
     ,p_attribute12                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute12',NULL)
     ,p_attribute13                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute13',NULL)
     ,p_attribute14                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute14',NULL)
     ,p_attribute15                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute15',NULL)
     ,p_attribute16                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute16',NULL)
     ,p_attribute17                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute17',NULL)
     ,p_attribute18                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute18',NULL)
     ,p_attribute19                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute19',NULL)
     ,p_attribute20                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute20',NULL)
     ,p_attribute21                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute21',NULL)
     ,p_attribute22                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute22',NULL)
     ,p_attribute23                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute23',NULL)
     ,p_attribute24                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute24',NULL)
     ,p_attribute25                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute25',NULL)
     ,p_attribute26                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute26',NULL)
     ,p_attribute27                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute27',NULL)
     ,p_attribute28                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute28',NULL)
     ,p_attribute29                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute29',NULL)
     ,p_attribute30                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute30',NULL)
     ,p_agency_vacancy_id          => l_agency_vacancy_id
     ,p_object_version_number      => l_object_version_number
     ,p_return_status              => l_return_status
     );
     --
   elsif l_postState = '2' then
--
   hr_utility.set_location('Extracting the PostState:' || l_proc,32);
     --
     update_agency_vacancy
     (p_validate                   => p_validate
     ,p_agency_vacancy_id          => hr_transaction_swi.getNumberValue(l_CommitNode,'AgencyVacancyId',NULL)
     ,p_agency_id                  => hr_transaction_swi.getNumberValue(l_CommitNode,'AgencyId',NULL)
     ,p_vacancy_id                 => hr_transaction_swi.getNumberValue(l_CommitNode,'VacancyId',NULL)
     ,p_start_date                 => hr_transaction_swi.getDateValue(l_CommitNode,'StartDate',NULL)
     ,p_end_date                   => hr_transaction_swi.getDateValue(l_CommitNode,'EndDate',NULL)
     ,p_max_allowed_applicants     => hr_transaction_swi.getNumberValue(l_CommitNode,'MaxAllowedApplicants',NULL)
     ,p_manage_applicants_allowed  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'ManageApplicantsAllowed',NULL)
     ,p_attribute_category         => hr_transaction_swi.getVarchar2Value(l_CommitNode,'AttributeCategory',NULL)
     ,p_attribute1                 => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute1',NULL)
     ,p_attribute2                 => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute2',NULL)
     ,p_attribute3                 => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute3',NULL)
     ,p_attribute4                 => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute4',NULL)
     ,p_attribute5                 => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute5',NULL)
     ,p_attribute6                 => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute6',NULL)
     ,p_attribute7                 => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute7',NULL)
     ,p_attribute8                 => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute8',NULL)
     ,p_attribute9                 => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute9',NULL)
     ,p_attribute10                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute10',NULL)
     ,p_attribute11                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute11',NULL)
     ,p_attribute12                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute12',NULL)
     ,p_attribute13                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute13',NULL)
     ,p_attribute14                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute14',NULL)
     ,p_attribute15                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute15',NULL)
     ,p_attribute16                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute16',NULL)
     ,p_attribute17                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute17',NULL)
     ,p_attribute18                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute18',NULL)
     ,p_attribute19                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute19',NULL)
     ,p_attribute20                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute20',NULL)
     ,p_attribute21                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute21',NULL)
     ,p_attribute22                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute22',NULL)
     ,p_attribute23                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute23',NULL)
     ,p_attribute24                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute24',NULL)
     ,p_attribute25                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute25',NULL)
     ,p_attribute26                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute26',NULL)
     ,p_attribute27                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute27',NULL)
     ,p_attribute28                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute28',NULL)
     ,p_attribute29                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute29',NULL)
     ,p_attribute30                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute30',NULL)
     ,p_object_version_number      => l_object_version_number
     ,p_return_status              => l_return_status
     );
     --
   elsif l_postState = '3' then
--
   hr_utility.set_location('Extracting the PostState:' || l_proc,33);
     --
     delete_agency_vacancy
     (p_validate               => p_validate
     ,p_object_version_number  => l_object_version_number
     ,p_agency_vacancy_id      => hr_transaction_swi.getNumberValue(l_CommitNode,'AgencyVacancyId',NULL)
     ,p_return_status          => l_return_status
     );
     --
   end if;

   p_return_status := l_return_status;
   hr_utility.set_location
     ('Exiting :'|| l_proc || ': return status :'|| l_return_status || ':',40);

--
end process_api;
--
end irc_agency_vacancies_swi;

/
