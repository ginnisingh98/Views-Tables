--------------------------------------------------------
--  DDL for Package Body PER_VACANCY_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_VACANCY_SWI" As
/* $Header: pevacswi.pkb 120.8 2008/02/27 15:17:53 amikukum noship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'per_vacancy_swi.';
g_commiting_via_workflow varchar2(30);
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_vacancy >----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_vacancy
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_requisition_id               in     number
  ,p_date_from                    in     date
  ,p_name                         in     varchar2
  ,p_security_method              in     varchar2  default null
  ,p_business_group_id            in     number
  ,p_position_id                  in     number    default null
  ,p_job_id                       in     number    default null
  ,p_grade_id                     in     number    default null
  ,p_organization_id              in     number    default null
  ,p_people_group_id              in     number    default null
  ,p_location_id                  in     number    default null
  ,p_recruiter_id                 in     number    default null
  ,p_date_to                      in     date      default null
  ,p_description                  in     varchar2  default null
  ,p_number_of_openings           in     number    default null
  ,p_status                       in     varchar2  default null
  ,p_budget_measurement_type      in     varchar2  default null
  ,p_budget_measurement_value     in     number    default null
  ,p_vacancy_category             in     varchar2  default null
  ,p_manager_id                   in     number    default null
  ,p_primary_posting_id           in     number    default null
  ,p_assessment_id                in     number    default null
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
  ,p_object_version_number        out nocopy number
  ,p_vacancy_id                   in     number
  ,p_return_status                out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  l_inv_pos_grade_warning         boolean;
  l_inv_job_grade_warning         boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_vacancy_id                   number;
  l_proc    varchar2(72) := g_package ||'create_vacancy';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_vacancy_swi;
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
  per_vac_ins.set_base_key_value
    (p_vacancy_id => p_vacancy_id
    );
  --
  -- Call API
  --
  per_vacancy_api.create_vacancy
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_requisition_id               => p_requisition_id
    ,p_date_from                    => p_date_from
    ,p_name                         => p_name
    ,p_security_method              => p_security_method
    ,p_business_group_id            => p_business_group_id
    ,p_position_id                  => p_position_id
    ,p_job_id                       => p_job_id
    ,p_grade_id                     => p_grade_id
    ,p_organization_id              => p_organization_id
    ,p_people_group_id              => p_people_group_id
    ,p_location_id                  => p_location_id
    ,p_recruiter_id                 => p_recruiter_id
    ,p_date_to                      => p_date_to
    ,p_description                  => p_description
    ,p_number_of_openings           => p_number_of_openings
    ,p_status                       => p_status
    ,p_budget_measurement_type      => p_budget_measurement_type
    ,p_budget_measurement_value     => p_budget_measurement_value
    ,p_vacancy_category             => p_vacancy_category
    ,p_manager_id                   => p_manager_id
    ,p_primary_posting_id           => p_primary_posting_id
    ,p_assessment_id                => p_assessment_id
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
    ,p_vacancy_id                   => l_vacancy_id
    ,p_inv_pos_grade_warning        => l_inv_pos_grade_warning
    ,p_inv_job_grade_warning        => l_inv_job_grade_warning
    );
  --
  if (nvl(g_commiting_via_workflow,'FALSE')='FALSE') then
    -- we are not commiting from workflow, so check for warnings
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  if l_inv_pos_grade_warning then
    fnd_message.set_name('PER', 'HR_POS_GRADE_CHK');
    hr_multi_message.add
      (p_associated_column1      => 'PER_ALL_VACANCIES.POSITION_ID'
      ,p_associated_column2      => 'PER_ALL_VACANCIES.GRADE_ID'
      ,p_message_type => hr_multi_message.g_warning_msg
      );
  end if;
  if l_inv_job_grade_warning then
   fnd_message.set_name('PER', 'HR_JOB_GRADE_CHK');
   hr_multi_message.add
      (p_associated_column1      => 'PER_ALL_VACANCIES.JOB_ID'
      ,p_associated_column2      => 'PER_ALL_VACANCIES.GRADE_ID'
      ,p_message_type => hr_multi_message.g_warning_msg
      );
  end if;
  end if;
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
    rollback to create_vacancy_swi;
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
    rollback to create_vacancy_swi;
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
end create_vacancy;
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_vacancy >----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_vacancy
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_object_version_number        in     number
  ,p_vacancy_id                   in     number
  ,p_return_status                out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'delete_vacancy';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_vacancy_swi;
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
  per_vacancy_api.delete_vacancy
    (p_validate                     => l_validate
    ,p_object_version_number        => p_object_version_number
    ,p_vacancy_id                   => p_vacancy_id
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
    rollback to delete_vacancy_swi;
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
    rollback to delete_vacancy_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc, 40);
       raise;
    end if;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving: ' || l_proc, 50);
end delete_vacancy;
-- ----------------------------------------------------------------------------
-- |----------------------------< update_vacancy >----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_vacancy
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_vacancy_id                   in     number
  ,p_object_version_number        in out nocopy number
  ,p_date_from                    in     date      default hr_api.g_date
  ,p_position_id                  in     number    default hr_api.g_number
  ,p_job_id                       in     number    default hr_api.g_number
  ,p_grade_id                     in     number    default hr_api.g_number
  ,p_organization_id              in     number    default hr_api.g_number
  ,p_people_group_id              in     number    default hr_api.g_number
  ,p_location_id                  in     number    default hr_api.g_number
  ,p_recruiter_id                 in     number    default hr_api.g_number
  ,p_date_to                      in     date      default hr_api.g_date
  ,p_security_method              in     varchar2  default hr_api.g_varchar2
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_number_of_openings           in     number    default hr_api.g_number
  ,p_status                       in     varchar2  default hr_api.g_varchar2
  ,p_budget_measurement_type      in     varchar2  default hr_api.g_varchar2
  ,p_budget_measurement_value     in     number    default hr_api.g_number
  ,p_vacancy_category             in     varchar2  default hr_api.g_varchar2
  ,p_manager_id                   in     number    default hr_api.g_number
  ,p_primary_posting_id           in     number    default hr_api.g_number
  ,p_assessment_id                in     number    default hr_api.g_number
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
  ,p_assignment_changed              out nocopy number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  l_assignment_changed            boolean;
  l_inv_pos_grade_warning         boolean;
  l_inv_job_grade_warning         boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_vacancy';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_vacancy_swi;
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
  l_assignment_changed :=
    hr_api.constant_to_boolean
      (p_constant_value => p_assignment_changed);
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  per_vacancy_api.update_vacancy
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_vacancy_id                   => p_vacancy_id
    ,p_object_version_number        => p_object_version_number
    ,p_date_from                    => p_date_from
    ,p_position_id                  => p_position_id
    ,p_job_id                       => p_job_id
    ,p_grade_id                     => p_grade_id
    ,p_organization_id              => p_organization_id
    ,p_people_group_id              => p_people_group_id
    ,p_location_id                  => p_location_id
    ,p_recruiter_id                 => p_recruiter_id
    ,p_date_to                      => p_date_to
    ,p_security_method              => p_security_method
    ,p_description                  => p_description
    ,p_number_of_openings           => p_number_of_openings
    ,p_status                       => p_status
    ,p_budget_measurement_type      => p_budget_measurement_type
    ,p_budget_measurement_value     => p_budget_measurement_value
    ,p_vacancy_category             => p_vacancy_category
    ,p_manager_id                   => p_manager_id
    ,p_primary_posting_id           => p_primary_posting_id
    ,p_assessment_id                => p_assessment_id
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
    ,p_assignment_changed           => l_assignment_changed
    ,p_inv_pos_grade_warning        => l_inv_pos_grade_warning
    ,p_inv_job_grade_warning        => l_inv_job_grade_warning
    );
  --
  if (nvl(g_commiting_via_workflow,'FALSE')='FALSE') then
    -- we are not commiting from workflow, so check for warnings
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  if l_inv_pos_grade_warning then
    fnd_message.set_name('PER', 'HR_POS_GRADE_CHK');
    hr_multi_message.add
      (p_message_type => hr_multi_message.g_warning_msg
      );
  end if;
  if l_inv_job_grade_warning then
    fnd_message.set_name('PER', 'HR_JOB_GRADE_CHK');
    hr_multi_message.add
      (p_message_type => hr_multi_message.g_warning_msg
      );
  end if;
  end if;
  --
  -- Convert API non-warning boolean parameter values
  --
  p_assignment_changed :=
     hr_api.boolean_to_constant
      (p_boolean_value => l_assignment_changed
      );
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
    rollback to update_vacancy_swi;
    --
    -- Reset IN OUT paramters and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_assignment_changed           := null;
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
    rollback to update_vacancy_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc, 40);
       raise;
    end if;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number        := l_object_version_number;
    p_assignment_changed           := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving: ' || l_proc, 50);
end update_vacancy;
--
procedure process_api
(
  p_document            in         CLOB
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

   -- Variables for OUT parameters
   l_effective_date     date  :=  trunc(sysdate);
   l_vacancy_id         number;
   l_assignment_changed number;
   l_update_status VARCHAR2(30);

   --

BEGIN
--
   hr_utility.set_location(' Entering:' || l_proc,10);
   hr_utility.set_location(' CLOB --> xmldom.DOMNode:' || l_proc,15);
--
   g_commiting_via_workflow:='TRUE';
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
   l_vacancy_id := hr_transaction_swi.getNumberValue(l_CommitNode,'VacancyId');
   l_update_status := hr_transaction_swi.getVarchar2Value(l_CommitNode,'Status',NULL);
   if l_update_status = 'PENDING'
   then
     l_update_status := 'APPROVED';
   end if;
--
   if p_effective_date is null
   then
   --
     l_effective_date := trunc(sysdate);
   --
   else
   --
     l_effective_date := p_effective_date;
   --
   end if;
--
   if l_postState = '0' then
--
   hr_utility.set_location('creating :' || l_proc,30);
     --
     create_vacancy
       (p_validate                     =>   p_validate
       ,p_effective_date               =>   l_effective_date
       ,p_requisition_id               =>   hr_transaction_swi.getNumberValue(l_CommitNode,'RequisitionId',NULL)
       ,p_date_from                    =>   hr_transaction_swi.getDateValue(l_CommitNode,'DateFrom',NULL)
       ,p_name                         =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'Name',NULL)
       ,p_security_method              =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'SecurityMethod',NULL)
       ,p_business_group_id            =>   hr_transaction_swi.getNumberValue(l_CommitNode,'BusinessGroupId',NULL)
       ,p_position_id                  =>   hr_transaction_swi.getNumberValue(l_CommitNode,'PositionId',NULL)
       ,p_job_id                       =>   hr_transaction_swi.getNumberValue(l_CommitNode,'JobId',NULL)
       ,p_grade_id                     =>   hr_transaction_swi.getNumberValue(l_CommitNode,'GradeId',NULL)
       ,p_organization_id              =>   hr_transaction_swi.getNumberValue(l_CommitNode,'OrganizationId',NULL)
       ,p_people_group_id              =>   hr_transaction_swi.getNumberValue(l_CommitNode,'PeopleGroupId',NULL)
       ,p_location_id                  =>   hr_transaction_swi.getNumberValue(l_CommitNode,'LocationId',NULL)
       ,p_recruiter_id                 =>   hr_transaction_swi.getNumberValue(l_CommitNode,'RecruiterId',NULL)
       ,p_date_to                      =>   hr_transaction_swi.getDateValue(l_CommitNode,'DateTo',NULL)
       ,p_description                  =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'Description',NULL)
       ,p_number_of_openings           =>   hr_transaction_swi.getNumberValue(l_CommitNode,'NumberOfOpenings',NULL)
       ,p_status                       =>   'APPROVED'
       ,p_budget_measurement_type      =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'BudgetMeasurementType',NULL)
       ,p_budget_measurement_value     =>   getNumberValueP2(l_CommitNode,'BudgetMeasurementValue',NULL)
       ,p_vacancy_category             =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'VacancyCategory',NULL)
       ,p_manager_id                   =>   hr_transaction_swi.getNumberValue(l_CommitNode,'ManagerId',NULL)
       ,p_primary_posting_id           =>   hr_transaction_swi.getNumberValue(l_CommitNode,'PrimaryPostingId',NULL)
       ,p_assessment_id                =>   hr_transaction_swi.getNumberValue(l_CommitNode,'AssessmentId',NULL)
       ,p_attribute_category           =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'AttributeCategory',NULL)
       ,p_attribute1                   =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute1',NULL)
       ,p_attribute2                   =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute2',NULL)
       ,p_attribute3                   =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute3',NULL)
       ,p_attribute4                   =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute4',NULL)
       ,p_attribute5                   =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute5',NULL)
       ,p_attribute6                   =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute6',NULL)
       ,p_attribute7                   =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute7',NULL)
       ,p_attribute8                   =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute8',NULL)
       ,p_attribute9                   =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute9',NULL)
       ,p_attribute10                  =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute10',NULL)
       ,p_attribute11                  =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute11',NULL)
       ,p_attribute12                  =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute12',NULL)
       ,p_attribute13                  =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute13',NULL)
       ,p_attribute14                  =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute14',NULL)
       ,p_attribute15                  =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute15',NULL)
       ,p_attribute16                  =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute16',NULL)
       ,p_attribute17                  =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute17',NULL)
       ,p_attribute18                  =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute18',NULL)
       ,p_attribute19                  =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute19',NULL)
       ,p_attribute20                  =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute20',NULL)
       ,p_attribute21                  =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute21',NULL)
       ,p_attribute22                  =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute22',NULL)
       ,p_attribute23                  =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute23',NULL)
       ,p_attribute24                  =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute24',NULL)
       ,p_attribute25                  =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute25',NULL)
       ,p_attribute26                  =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute26',NULL)
       ,p_attribute27                  =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute27',NULL)
       ,p_attribute28                  =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute28',NULL)
       ,p_attribute29                  =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute29',NULL)
       ,p_attribute30                  =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute30',NULL)
       ,p_object_version_number        =>   l_object_version_number
       ,p_vacancy_id                   =>   l_vacancy_id
       ,p_return_status                =>   l_return_status
     );
     --
     elsif l_postState = '2' then
--
   hr_utility.set_location('updating :' || l_proc,32);
     --
     -- call update vacancy
     --
     update_vacancy
       (p_validate                     =>   p_validate
       ,p_effective_date               =>   l_effective_date
       ,p_vacancy_id                   =>   l_vacancy_id
       ,p_object_version_number        =>   l_object_version_number
       ,p_date_from                    =>   hr_transaction_swi.getDateValue(l_CommitNode,'DateFrom',NULL)
       ,p_position_id                  =>   hr_transaction_swi.getNumberValue(l_CommitNode,'PositionId',NULL)
       ,p_job_id                       =>   hr_transaction_swi.getNumberValue(l_CommitNode,'JobId',NULL)
       ,p_grade_id                     =>   hr_transaction_swi.getNumberValue(l_CommitNode,'GradeId',NULL)
       ,p_organization_id              =>   hr_transaction_swi.getNumberValue(l_CommitNode,'OrganizationId',NULL)
       ,p_people_group_id              =>   hr_transaction_swi.getNumberValue(l_CommitNode,'PeopleGroupId',NULL)
       ,p_location_id                  =>   hr_transaction_swi.getNumberValue(l_CommitNode,'LocationId',NULL)
       ,p_recruiter_id                 =>   hr_transaction_swi.getNumberValue(l_CommitNode,'RecruiterId',NULL)
       ,p_date_to                      =>   hr_transaction_swi.getDateValue(l_CommitNode,'DateTo',NULL)
       ,p_security_method              =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'SecurityMethod',NULL)
       ,p_description                  =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'Description',NULL)
       ,p_number_of_openings           =>   hr_transaction_swi.getNumberValue(l_CommitNode,'NumberOfOpenings',NULL)
       ,p_status                       =>   l_update_status
       ,p_budget_measurement_type      =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'BudgetMeasurementType',NULL)
       ,p_budget_measurement_value     =>   getNumberValueP2(l_CommitNode,'BudgetMeasurementValue',NULL)
       ,p_vacancy_category             =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'VacancyCategory',NULL)
       ,p_manager_id                   =>   hr_transaction_swi.getNumberValue(l_CommitNode,'ManagerId',NULL)
       ,p_primary_posting_id           =>   hr_transaction_swi.getNumberValue(l_CommitNode,'PrimaryPostingId',NULL)
       ,p_assessment_id                =>   hr_transaction_swi.getNumberValue(l_CommitNode,'AssessmentId',NULL)
       ,p_attribute_category           =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'AttributeCategory',NULL)
       ,p_attribute1                   =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute1',NULL)
       ,p_attribute2                   =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute2',NULL)
       ,p_attribute3                   =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute3',NULL)
       ,p_attribute4                   =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute4',NULL)
       ,p_attribute5                   =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute5',NULL)
       ,p_attribute6                   =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute6',NULL)
       ,p_attribute7                   =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute7',NULL)
       ,p_attribute8                   =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute8',NULL)
       ,p_attribute9                   =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute9',NULL)
       ,p_attribute10                  =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute10',NULL)
       ,p_attribute11                  =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute11',NULL)
       ,p_attribute12                  =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute12',NULL)
       ,p_attribute13                  =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute13',NULL)
       ,p_attribute14                  =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute14',NULL)
       ,p_attribute15                  =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute15',NULL)
       ,p_attribute16                  =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute16',NULL)
       ,p_attribute17                  =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute17',NULL)
       ,p_attribute18                  =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute18',NULL)
       ,p_attribute19                  =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute19',NULL)
       ,p_attribute20                  =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute20',NULL)
       ,p_attribute21                  =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute21',NULL)
       ,p_attribute22                  =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute22',NULL)
       ,p_attribute23                  =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute23',NULL)
       ,p_attribute24                  =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute24',NULL)
       ,p_attribute25                  =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute25',NULL)
       ,p_attribute26                  =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute26',NULL)
       ,p_attribute27                  =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute27',NULL)
       ,p_attribute28                  =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute28',NULL)
       ,p_attribute29                  =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute29',NULL)
       ,p_attribute30                  =>   hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute30',NULL)
       ,p_assignment_changed           =>   l_assignment_changed
       ,p_return_status                =>   l_return_status
     );
--
   end if;

   p_return_status := l_return_status;
   g_commiting_via_workflow:='FALSE';

   hr_utility.set_location
     ('Exiting :'|| l_proc || ': return status :'|| l_return_status || ':',40);
  exception
  when others then
    g_commiting_via_workflow:='FALSE';

end process_api;
--
Function getNumberValueP2(
  commitNode in xmldom.DOMNode,
  attributeName in VARCHAR2,
  gmisc_value in number default hr_api.g_number)
  return NUMBER IS
--
  l_number NUMBER(22,2);
  l_isNull VARCHAR2(22);
  l_element xmldom.DOMElement;
  l_proc    varchar2(72) := g_package || 'getNumberValue';
--
Begin
--
  hr_utility.set_location(' Entering:' || l_proc,10);
  l_number := xslprocessor.valueof(commitNode,attributeName);
  l_element := xmldom.makeElement(commitNode);
  l_isNull := xmldom.getAttribute(l_element, 'null');
  if l_isNull = 'true' then
    l_number := NULL;
  else
    l_number := NVL(l_number, gmisc_value);
  end if;
  hr_utility.set_location(' Exiting :' || l_proc,15);
--
  return l_number;
--
End getNumberValueP2;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< handleAttachmentsWhenCommit >---------------|
-- ----------------------------------------------------------------------------
--
procedure handleAttachmentsWhenCommit(p_vacancy_id in number) is
PRAGMA AUTONOMOUS_TRANSACTION;
  l_proc    varchar2(72) := g_package || 'handleAttachmentsWhenCommit';
 begin
 hr_utility.set_location(' Entering:' || l_proc,10);
 fnd_attached_documents2_pkg.delete_attachments(X_entity_name=>'IRC_EXT_VAC_APPROVED',X_pk1_value=>p_vacancy_id,X_delete_document_flag=>'Y');
 fnd_attached_documents2_pkg.delete_attachments(X_entity_name=>'IRC_INT_VAC_APPROVED',X_pk1_value=>p_vacancy_id,X_delete_document_flag=>'Y');

 fnd_attached_documents2_pkg.copy_attachments(X_from_entity_name =>'IRC_INT_VAC',X_from_pk1_value => p_vacancy_id,X_to_entity_name=>'IRC_INT_VAC_APPROVED',X_to_pk1_value=>p_vacancy_id);
 fnd_attached_documents2_pkg.copy_attachments(X_from_entity_name =>'IRC_EXT_VAC',X_from_pk1_value => p_vacancy_id,X_to_entity_name=>'IRC_EXT_VAC_APPROVED',X_to_pk1_value=>p_vacancy_id);

 fnd_attached_documents2_pkg.delete_attachments(X_entity_name=>'IRC_EXT_VAC',X_pk1_value=>p_vacancy_id,X_delete_document_flag=>'Y');
 fnd_attached_documents2_pkg.delete_attachments(X_entity_name=>'IRC_INT_VAC',X_pk1_value=>p_vacancy_id,X_delete_document_flag=>'Y');
 commit;
 hr_utility.set_location(' Exiting:' || l_proc,20);
 end;
 --
-- ----------------------------------------------------------------------------
-- |-----------------------------< handleAttachmentsWhenRejected >-------------|
-- ----------------------------------------------------------------------------
--
procedure handleAttachmentsWhenRejected(p_vacancy_id in number) is
PRAGMA AUTONOMOUS_TRANSACTION;
  l_proc    varchar2(72) := g_package || 'handleAttachmentsWhenRejected';
 begin
 hr_utility.set_location(' Entering:' || l_proc,10);
 fnd_attached_documents2_pkg.delete_attachments(X_entity_name=>'IRC_EXT_VAC',X_pk1_value=>p_vacancy_id,X_delete_document_flag=>'Y');
 fnd_attached_documents2_pkg.delete_attachments(X_entity_name=>'IRC_INT_VAC',X_pk1_value=>p_vacancy_id,X_delete_document_flag=>'Y');
 commit;
  hr_utility.set_location(' Exiting:' || l_proc,20);
 end;

 -- ---------------------------------------------------------------------------
-- |-----------------------------< handleAttachmentsWhenEditing >--------------|
-- ----------------------------------------------------------------------------
--
procedure handleAttachmentsWhenEdit(p_vacancy_id in number) is
PRAGMA AUTONOMOUS_TRANSACTION;
  l_proc    varchar2(72) := g_package || 'handleAttachmentsWhenEdit';
 begin
 hr_utility.set_location(' Entering:' || l_proc,10);

 fnd_attached_documents2_pkg.delete_attachments(X_entity_name=>'IRC_EXT_VAC',X_pk1_value=>p_vacancy_id,X_delete_document_flag=>'Y');
 fnd_attached_documents2_pkg.delete_attachments(X_entity_name=>'IRC_INT_VAC',X_pk1_value=>p_vacancy_id,X_delete_document_flag=>'Y');

 fnd_attached_documents2_pkg.copy_attachments(X_from_entity_name =>'IRC_INT_VAC_APPROVED',X_from_pk1_value => p_vacancy_id,X_to_entity_name=>'IRC_INT_VAC',X_to_pk1_value=>p_vacancy_id);
 fnd_attached_documents2_pkg.copy_attachments(X_from_entity_name =>'IRC_EXT_VAC_APPROVED',X_from_pk1_value => p_vacancy_id,X_to_entity_name=>'IRC_EXT_VAC',X_to_pk1_value=>p_vacancy_id);
 commit;
 hr_utility.set_location(' Exiting:' || l_proc,20);
 end;

 -- ---------------------------------------------------------------------------
-- |-----------------------------< copyAttachments >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure copyAttachments(p_from_vacancy_id in number,p_to_vacancy_id in number) is
PRAGMA AUTONOMOUS_TRANSACTION;
  l_proc    varchar2(72) := g_package || 'copyAttachments';
 begin
 hr_utility.set_location(' Entering:' || l_proc,10);

 fnd_attached_documents2_pkg.copy_attachments(X_from_entity_name =>'IRC_INT_VAC_APPROVED',X_from_pk1_value => p_from_vacancy_id,X_to_entity_name=>'IRC_INT_VAC',X_to_pk1_value=>p_to_vacancy_id);
 fnd_attached_documents2_pkg.copy_attachments(X_from_entity_name =>'IRC_EXT_VAC_APPROVED',X_from_pk1_value => p_from_vacancy_id,X_to_entity_name=>'IRC_EXT_VAC',X_to_pk1_value=>p_to_vacancy_id);
 commit;
 hr_utility.set_location(' Exiting:' || l_proc,20);
 end;

 -- --------------------------------------------------------------------------
-- |-----------------------------< finalize_transaction >---------------------|
-- ----------------------------------------------------------------------------

procedure finalize_transaction
(
 p_transaction_id       in         number
,p_event                in         varchar2
,p_return_status        out nocopy varchar2
)
is
   l_vacancy_id                    number;
   l_return_status                 varchar2(1);
   l_proc    varchar2(72) := g_package || 'finalize_transaction';
   --
   cursor csr_vacancy_id is
      select transaction_ref_id
      from hr_api_transactions hrt
      where hrt.transaction_id = p_transaction_id;
   --
begin
   --
   hr_utility.set_location(' Entering:' || l_proc,10);
   hr_utility.set_location(l_proc || ' Event:' || p_event,20);
   --
   open csr_vacancy_id;
   fetch csr_vacancy_id into l_vacancy_id;

   if csr_vacancy_id%found then
     close csr_vacancy_id;
     --
     hr_utility.set_location(l_proc,30);

     if p_event = 'APPROVED'  then
       hr_utility.set_location(l_proc, 40);
       handleAttachmentsWhenCommit(l_vacancy_id);

     elsif p_event = 'REJECTED' OR p_event = 'DELETED' OR p_event = 'CANCEL' then
        hr_utility.set_location(l_proc, 50);
        handleAttachmentsWhenRejected(l_vacancy_id);
     end if;

   end if;
   --
   close csr_vacancy_id;
   p_return_status := hr_multi_message.get_return_status_disable;
   hr_utility.set_location('Exiting:' || l_proc,60);
   --
end finalize_transaction;


end per_vacancy_swi;

/
