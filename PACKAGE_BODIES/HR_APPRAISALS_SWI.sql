--------------------------------------------------------
--  DDL for Package Body HR_APPRAISALS_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_APPRAISALS_SWI" As
/* $Header: peaprswi.pkb 120.1.12010000.3 2009/08/12 14:16:28 rvagvala ship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'hr_appraisals_swi.';
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_appraisal >---------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_appraisal
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_business_group_id            in     number
  ,p_appraisal_template_id        in     number
  ,p_appraisee_person_id          in     number
  ,p_appraiser_person_id          in     number
  ,p_appraisal_date               in     date      default null
  ,p_appraisal_period_start_date  in     date
  ,p_appraisal_period_end_date    in     date
  ,p_type                         in     varchar2  default null
  ,p_next_appraisal_date          in     date      default null
  ,p_status                       in     varchar2  default null
  ,p_group_date                   in     date      default null
  ,p_group_initiator_id           in     number    default null
  ,p_comments                     in     varchar2  default null
  ,p_overall_performance_level_id in     number    default null
  ,p_open                         in     varchar2  default null
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
  ,p_system_type                  in     varchar2  default null
  ,p_system_params                in     varchar2  default null
  ,p_appraisee_access             in     varchar2  default null
  ,p_main_appraiser_id            in     number    default null
  ,p_assignment_id                in     number    default null
  ,p_assignment_start_date        in     date      default null
  ,p_asg_business_group_id        in     number    default null
  ,p_assignment_organization_id   in     number    default null
  ,p_assignment_job_id            in     number    default null
  ,p_assignment_position_id       in     number    default null
  ,p_assignment_grade_id          in     number    default null
  ,p_appraisal_id                 in     number
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  ,p_appraisal_system_status	  in     varchar2  default null
  ,p_potential_readiness_level    in 	varchar2   default null
  ,p_potential_short_term_workopp in 	varchar2   default null
  ,p_potential_long_term_workopp  in 	varchar2   default null
  ,p_potential_details            in 	varchar2   default null
  ,p_event_id                     in 	number     default null
  ,p_show_competency_ratings      in    varchar2   default null
  ,p_show_objective_ratings       in    varchar2   default null
  ,p_show_questionnaire_info      in    varchar2   default null
  ,p_show_participant_details     in    varchar2   default null
  ,p_show_participant_ratings     in    varchar2   default null
  ,p_show_participant_names       in    varchar2   default null
  ,p_show_overall_ratings         in    varchar2   default null
  ,p_show_overall_comments        in    varchar2   default null
  ,p_update_appraisal             in    varchar2   default null
  ,p_provide_overall_feedback     in    varchar2   default null
  ,p_appraisee_comments           in    varchar2   default null
  ,p_offline_status               in     varchar2  default null
,p_retention_potential          in varchar2           default null
,p_show_participant_comments     in varchar2            default null  -- 8651478 bug fix
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  l_appraisal_id number;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'create_appraisal';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_appraisal_swi;
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
  per_apr_ins.set_base_key_value
    (p_appraisal_id => p_appraisal_id
    );

  --
  -- Call API
  --
  hr_appraisals_api.create_appraisal
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_business_group_id            => p_business_group_id
    ,p_appraisal_template_id        => p_appraisal_template_id
    ,p_appraisee_person_id          => p_appraisee_person_id
    ,p_appraiser_person_id          => p_appraiser_person_id
    ,p_appraisal_date               => p_appraisal_date
    ,p_appraisal_period_start_date  => p_appraisal_period_start_date
    ,p_appraisal_period_end_date    => p_appraisal_period_end_date
    ,p_type                         => p_type
    ,p_next_appraisal_date          => p_next_appraisal_date
    ,p_status                       => p_status
    ,p_group_date                   => p_group_date
    ,p_group_initiator_id           => p_group_initiator_id
    ,p_comments                     => p_comments
    ,p_overall_performance_level_id => p_overall_performance_level_id
    ,p_open                         => p_open
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
    ,p_system_type                  => p_system_type
    ,p_system_params                => p_system_params
    ,p_appraisee_access             => p_appraisee_access
    ,p_main_appraiser_id            => p_main_appraiser_id
    ,p_assignment_id                => p_assignment_id
    ,p_assignment_start_date        => p_assignment_start_date
    ,p_asg_business_group_id        => p_asg_business_group_id
    ,p_assignment_organization_id   => p_assignment_organization_id
    ,p_assignment_job_id            => p_assignment_job_id
    ,p_assignment_position_id       => p_assignment_position_id
    ,p_assignment_grade_id          => p_assignment_grade_id
    ,p_appraisal_id                 => l_appraisal_id
    ,p_object_version_number        => p_object_version_number
    ,p_appraisal_system_status      => p_appraisal_system_status
    ,p_potential_readiness_level    => p_potential_readiness_level
    ,p_potential_short_term_workopp => p_potential_short_term_workopp
    ,p_potential_long_term_workopp  => p_potential_long_term_workopp
    ,p_potential_details      	    => p_potential_details
    ,p_event_id                     => p_event_id
    ,p_show_competency_ratings      => p_show_competency_ratings
    ,p_show_objective_ratings       => p_show_objective_ratings
    ,p_show_questionnaire_info      => p_show_questionnaire_info
    ,p_show_participant_details     => p_show_participant_details
    ,p_show_participant_ratings     => p_show_participant_ratings
    ,p_show_participant_names       => p_show_participant_names
    ,p_show_overall_ratings         => p_show_overall_ratings
    ,p_show_overall_comments        => p_show_overall_comments
    ,p_update_appraisal             => p_update_appraisal
    ,p_provide_overall_feedback     => p_provide_overall_feedback
    ,p_appraisee_comments           => p_appraisee_comments
    ,p_offline_status               => p_offline_status
,p_retention_potential               =>     p_retention_potential
,p_show_participant_comments     =>     p_show_participant_comments -- 8651478 bug fix
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
    rollback to create_appraisal_swi;
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
    rollback to create_appraisal_swi;
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
end create_appraisal;
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_appraisal >---------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_appraisal
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_appraisal_id                 in     number
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
  l_proc    varchar2(72) := g_package ||'delete_appraisal';
  l_apr_status per_appraisals.appraisal_system_status%TYPE;
  l_del_mode boolean;
  l_del_status varchar2(10);
  l_ovn per_appraisals.appraisal_id%TYPE;

  -- Cursor to get the appraisal_system_status

  cursor cs_apr_status is
  select appraisal_system_status
  from per_appraisals
  where appraisal_id= p_appraisal_id ;
 --

Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_appraisal_swi;
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


  open cs_apr_status;

  fetch cs_apr_status into l_apr_status;

  	IF cs_apr_status%NOTFOUND then
  	null;  --   REVISIT Throw exception after closing the cursor.
  	END IF;

  close cs_apr_status;

  --

  IF l_apr_status = 'PLANNED' OR l_apr_status = 'SAVED' THEN
  	l_del_mode := true;
  ELSE
  	l_del_mode := false;
  END IF;

-- If appraisal_system_status = PLANNED or SAVED , we actually delete the appraisal
-- For appraisals of other status, we have to update the appraisal record with
-- appraisal_system_status=DELETED

  IF l_del_mode = true THEN

  --
  -- Register Surrogate ID or user key values
  --

  --
  -- Call API
  --
  hr_appraisals_api.delete_appraisal
    (p_validate                     => l_validate
    ,p_appraisal_id                 => p_appraisal_id
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

  ELSE

  -- To update appraisal record with appraisal_system_status=DELETED


  l_ovn := p_object_version_number;

  update_appraisal
  (
  p_validate => p_validate
  ,p_effective_date => sysdate
  ,p_appraisal_id => p_appraisal_id
  ,p_object_version_number => l_ovn
  ,p_appraisal_system_status => 'DELETED'
  ,p_return_status => p_return_status
  );

  END IF; -- l_del_mode


  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to delete_appraisal_swi;
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
    rollback to delete_appraisal_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_appraisal;
-- ----------------------------------------------------------------------------
-- |---------------------------< update_appraisal >---------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_appraisal
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_appraisal_id                 in     number
  ,p_object_version_number        in out nocopy number
  ,p_appraiser_person_id          in     number    default hr_api.g_number
  ,p_appraisal_date               in     date      default hr_api.g_date
  ,p_appraisal_period_end_date    in     date      default hr_api.g_date
  ,p_appraisal_period_start_date  in     date      default hr_api.g_date
  ,p_type                         in     varchar2  default hr_api.g_varchar2
  ,p_next_appraisal_date          in     date      default hr_api.g_date
  ,p_status                       in     varchar2  default hr_api.g_varchar2
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_overall_performance_level_id in     number    default hr_api.g_number
  ,p_open                         in     varchar2  default hr_api.g_varchar2
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
  ,p_system_type                  in     varchar2  default hr_api.g_varchar2
  ,p_system_params                in     varchar2  default hr_api.g_varchar2
  ,p_appraisee_access             in     varchar2  default hr_api.g_varchar2
  ,p_main_appraiser_id            in     number    default hr_api.g_number
  ,p_assignment_id                in     number    default hr_api.g_number
  ,p_assignment_start_date        in     date      default hr_api.g_date
  ,p_asg_business_group_id        in     number    default hr_api.g_number
  ,p_assignment_organization_id   in     number    default hr_api.g_number
  ,p_assignment_job_id            in     number    default hr_api.g_number
  ,p_assignment_position_id       in     number    default hr_api.g_number
  ,p_assignment_grade_id          in     number    default hr_api.g_number
  ,p_return_status                   out nocopy varchar2
  ,p_appraisal_system_status      in     varchar2  default hr_api.g_varchar2
  ,p_potential_readiness_level    in     varchar2  default hr_api.g_varchar2
  ,p_potential_short_term_workopp in     varchar2  default hr_api.g_varchar2
  ,p_potential_long_term_workopp  in     varchar2  default hr_api.g_varchar2
  ,p_potential_details            in     varchar2  default hr_api.g_varchar2
  ,p_event_id                     in     number    default hr_api.g_number
  ,p_show_competency_ratings      in     varchar2  default hr_api.g_varchar2
  ,p_show_objective_ratings       in     varchar2  default hr_api.g_varchar2
  ,p_show_questionnaire_info      in     varchar2  default hr_api.g_varchar2
  ,p_show_participant_details     in     varchar2  default hr_api.g_varchar2
  ,p_show_participant_ratings     in     varchar2  default hr_api.g_varchar2
  ,p_show_participant_names       in     varchar2  default hr_api.g_varchar2
  ,p_show_overall_ratings         in     varchar2  default hr_api.g_varchar2
  ,p_show_overall_comments        in     varchar2  default hr_api.g_varchar2
  ,p_update_appraisal             in     varchar2  default hr_api.g_varchar2
  ,p_provide_overall_feedback     in     varchar2  default hr_api.g_varchar2
  ,p_appraisee_comments           in     varchar2  default hr_api.g_varchar2
  ,p_offline_status               in     varchar2  default hr_api.g_varchar2
,p_retention_potential                in varchar2         default hr_api.g_varchar2
,p_show_participant_comments     in varchar2         default hr_api.g_varchar2  -- 8651478 bug fix
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_appraisal';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_appraisal_swi;
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
  hr_appraisals_api.update_appraisal
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_appraisal_id                 => p_appraisal_id
    ,p_object_version_number        => p_object_version_number
    ,p_appraiser_person_id          => p_appraiser_person_id
    ,p_appraisal_date               => p_appraisal_date
    ,p_appraisal_period_end_date    => p_appraisal_period_end_date
    ,p_appraisal_period_start_date  => p_appraisal_period_start_date
    ,p_type                         => p_type
    ,p_next_appraisal_date          => p_next_appraisal_date
    ,p_status                       => p_status
    ,p_comments                     => p_comments
    ,p_overall_performance_level_id => p_overall_performance_level_id
    ,p_open                         => p_open
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
    ,p_system_type                  => p_system_type
    ,p_system_params                => p_system_params
    ,p_appraisee_access             => p_appraisee_access
    ,p_main_appraiser_id            => p_main_appraiser_id
    ,p_assignment_id                => p_assignment_id
    ,p_assignment_start_date        => p_assignment_start_date
    ,p_asg_business_group_id        => p_asg_business_group_id
    ,p_assignment_organization_id   => p_assignment_organization_id
    ,p_assignment_job_id            => p_assignment_job_id
    ,p_assignment_position_id       => p_assignment_position_id
    ,p_assignment_grade_id          => p_assignment_grade_id
    ,p_appraisal_system_status      => p_appraisal_system_status
    ,p_potential_readiness_level    => p_potential_readiness_level
    ,p_potential_short_term_workopp => p_potential_short_term_workopp
    ,p_potential_long_term_workopp  => p_potential_long_term_workopp
    ,p_potential_details      	    => p_potential_details
    ,p_event_id                     => p_event_id
    ,p_show_competency_ratings      => p_show_competency_ratings
    ,p_show_objective_ratings       => p_show_objective_ratings
    ,p_show_questionnaire_info      => p_show_questionnaire_info
    ,p_show_participant_details     => p_show_participant_details
    ,p_show_participant_ratings     => p_show_participant_ratings
    ,p_show_participant_names       => p_show_participant_names
    ,p_show_overall_ratings         => p_show_overall_ratings
    ,p_show_overall_comments        => p_show_overall_comments
    ,p_update_appraisal             => p_update_appraisal
    ,p_provide_overall_feedback     => p_provide_overall_feedback
    ,p_appraisee_comments           => p_appraisee_comments
    ,p_offline_status               => p_offline_status
  ,p_retention_potential               =>     p_retention_potential
  ,p_show_participant_comments     =>     p_show_participant_comments -- 8651478 bug fix
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
    rollback to update_appraisal_swi;
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
    rollback to update_appraisal_swi;
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
end update_appraisal;

-- ----------------------------------------------------------------------------
-- |---------------------------< process_api >--------------------------------|
-- ----------------------------------------------------------------------------

Procedure process_api
(p_document            in         CLOB
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

       create_appraisal
      ( p_validate                     => p_validate
       ,p_effective_date               => p_effective_date
       ,p_business_group_id            => hr_transaction_swi.getNumberValue(l_CommitNode,'BusinessGroupId',null)
       ,p_appraisal_template_id        => hr_transaction_swi.getNumberValue(l_CommitNode,'AppraisalTemplateId',null)
       ,p_appraisee_person_id          => hr_transaction_swi.getNumberValue(l_CommitNode,'AppraiseePersonId',null)
       ,p_appraiser_person_id          => hr_transaction_swi.getNumberValue(l_CommitNode,'AppraiserPersonId',null)
       ,p_appraisal_date               => hr_transaction_swi.getDateValue(l_CommitNode,'AppraisalDate',null)
       ,p_appraisal_period_start_date  => hr_transaction_swi.getDateValue(l_CommitNode,'AppraisalPeriodStartDate',null)
       ,p_appraisal_period_end_date    => hr_transaction_swi.getDateValue(l_CommitNode,'AppraisalPeriodEndDate',null)
       ,p_type                         => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Type',null)
       ,p_next_appraisal_date          => hr_transaction_swi.getDateValue(l_CommitNode,'NextAppraisalDate',null)
       ,p_status                       => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Status',null)
       ,p_group_date                   => hr_transaction_swi.getDateValue(l_CommitNode,'GroupDate',null)
       ,p_group_initiator_id           => hr_transaction_swi.getNumberValue(l_CommitNode,'GroupInitiatorId',null)
       ,p_comments                     => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Comments',null)
       ,p_overall_performance_level_id => hr_transaction_swi.getNumberValue(l_CommitNode,'OverallPerformanceLevelId',null)
       ,p_open                         => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Open',null)
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
       ,p_system_type                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'SystemType',null)
       ,p_system_params                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'SystemParams',null)
       ,p_appraisee_access             => hr_transaction_swi.getVarchar2Value(l_CommitNode,'AppraiseeAccess',null)
       ,p_main_appraiser_id            => hr_transaction_swi.getNumberValue(l_CommitNode,'MainAppraiserId',null)
       ,p_assignment_id                => hr_transaction_swi.getNumberValue(l_CommitNode,'AssignmentId',null)
       ,p_assignment_start_date        => hr_transaction_swi.getDateValue(l_CommitNode,'AssignmentStartDate',null)
       ,p_asg_business_group_id        => hr_transaction_swi.getNumberValue(l_CommitNode,'AsgBusinessGroupId',null)
       ,p_assignment_organization_id   => hr_transaction_swi.getNumberValue(l_CommitNode,'AssignmentOrganizationId',null)
       ,p_assignment_job_id            => hr_transaction_swi.getNumberValue(l_CommitNode,'AssignmentJobId',null)
       ,p_assignment_position_id       => hr_transaction_swi.getNumberValue(l_CommitNode,'AssignmentPositionId',null)
       ,p_assignment_grade_id          => hr_transaction_swi.getNumberValue(l_CommitNode,'AssignmentGradeId',null)
       ,p_appraisal_id                 => hr_transaction_swi.getNumberValue(l_CommitNode,'AppraisalId',null)
       ,p_object_version_number        => l_object_version_number
       ,p_return_status                => l_return_status
       ,p_appraisal_system_status      => hr_transaction_swi.getVarchar2Value(l_CommitNode,'AppraisalSystemStatus',null)
       ,p_potential_readiness_level    => hr_transaction_swi.getVarchar2Value(l_CommitNode,'PotentialReadinessLevel',null)
       ,p_potential_short_term_workopp => hr_transaction_swi.getVarchar2Value(l_CommitNode,'PotentialShortTermWorkopp',null)
       ,p_potential_long_term_workopp  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'PotentialLongTermWorkopp',null)
       ,p_potential_details            => hr_transaction_swi.getVarchar2Value(l_CommitNode,'PotentialDetails',null)
       ,p_event_id                     => hr_transaction_swi.getNumberValue(l_CommitNode,'EventId',null)
       ,p_show_competency_ratings      => hr_transaction_swi.getVarchar2Value(l_CommitNode,'ShowCompetencyRatings',null)
       ,p_show_objective_ratings       => hr_transaction_swi.getVarchar2Value(l_CommitNode,'ShowObjectiveRatings',null)
       ,p_show_questionnaire_info      => hr_transaction_swi.getVarchar2Value(l_CommitNode,'ShowQuestionnaireInfo',null)
       ,p_show_participant_details     => hr_transaction_swi.getVarchar2Value(l_CommitNode,'ShowParticipantDetails',null)
       ,p_show_participant_ratings     => hr_transaction_swi.getVarchar2Value(l_CommitNode,'ShowParticipantRatings',null)
       ,p_show_participant_names       => hr_transaction_swi.getVarchar2Value(l_CommitNode,'ShowParticipantNames',null)
       ,p_show_overall_ratings         => hr_transaction_swi.getVarchar2Value(l_CommitNode,'ShowOverallRatings',null)
       ,p_show_overall_comments        => hr_transaction_swi.getVarchar2Value(l_CommitNode,'ShowOverallComments',null)
       ,p_update_appraisal             => hr_transaction_swi.getVarchar2Value(l_CommitNode,'UpdateAppraisal',null)
       ,p_provide_overall_feedback     => hr_transaction_swi.getVarchar2Value(l_CommitNode,'ProvideOverallFeedback',null)
       ,p_appraisee_comments           => hr_transaction_swi.getVarchar2Value(l_CommitNode,'AppraiseeComments',null)
       ,p_retention_potential           => hr_transaction_swi.getVarchar2Value(l_CommitNode,'RetentionPotential',null)
      ,p_show_participant_comments     => hr_transaction_swi.getVarchar2Value(l_CommitNode,'ShowParticipantComments',null)  -- 8651478 bug fix
       );

   elsif l_postState = '2' then

       update_appraisal
      ( p_validate                     => p_validate
       ,p_effective_date               => p_effective_date
       ,p_appraisal_id                 => hr_transaction_swi.getNumberValue(l_CommitNode,'AppraisalId')
       ,p_object_version_number        => l_object_version_number
       ,p_appraiser_person_id          => hr_transaction_swi.getNumberValue(l_CommitNode,'AppraiserPersonId')
       ,p_appraisal_date               => hr_transaction_swi.getDateValue(l_CommitNode,'AppraisalDate')
       ,p_appraisal_period_end_date    => hr_transaction_swi.getDateValue(l_CommitNode,'AppraisalPeriodEndDate')
       ,p_appraisal_period_start_date  => hr_transaction_swi.getDateValue(l_CommitNode,'AppraisalPeriodStartDate')
       ,p_type                         => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Type')
       ,p_next_appraisal_date          => hr_transaction_swi.getDateValue(l_CommitNode,'NextAppraisalDate')
       ,p_status                       => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Status')
       ,p_comments                     => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Comments')
       ,p_overall_performance_level_id => hr_transaction_swi.getNumberValue(l_CommitNode,'OverallPerformanceLevelId')
       ,p_open                         => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Open')
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
       ,p_system_type                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'SystemType')
       ,p_system_params                => hr_transaction_swi.getVarchar2Value(l_CommitNode,'SystemParams')
       ,p_appraisee_access             => hr_transaction_swi.getVarchar2Value(l_CommitNode,'AppraiseeAccess')
       ,p_main_appraiser_id            => hr_transaction_swi.getNumberValue(l_CommitNode,'MainAppraiserId')
       ,p_assignment_id                => hr_transaction_swi.getNumberValue(l_CommitNode,'AssignmentId')
       ,p_assignment_start_date        => hr_transaction_swi.getDateValue(l_CommitNode,'AssignmentStartDate')
       ,p_asg_business_group_id        => hr_transaction_swi.getNumberValue(l_CommitNode,'AsgBusinessGroupId')
       ,p_assignment_organization_id   => hr_transaction_swi.getNumberValue(l_CommitNode,'AssignmentOrganizationId')
       ,p_assignment_job_id            => hr_transaction_swi.getNumberValue(l_CommitNode,'AssignmentJobId')
       ,p_assignment_position_id       => hr_transaction_swi.getNumberValue(l_CommitNode,'AssignmentPositionId')
       ,p_assignment_grade_id          => hr_transaction_swi.getNumberValue(l_CommitNode,'AssignmentGradeId')
       ,p_return_status                => l_return_status
       ,p_appraisal_system_status      => hr_transaction_swi.getVarchar2Value(l_CommitNode,'AppraisalSystemStatus')
       ,p_potential_readiness_level    => hr_transaction_swi.getVarchar2Value(l_CommitNode,'PotentialReadinessLevel')
       ,p_potential_short_term_workopp => hr_transaction_swi.getVarchar2Value(l_CommitNode,'PotentialShortTermWorkopp')
       ,p_potential_long_term_workopp  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'PotentialLongTermWorkopp')
       ,p_potential_details            => hr_transaction_swi.getVarchar2Value(l_CommitNode,'PotentialDetails')
       ,p_event_id                     => hr_transaction_swi.getNumberValue(l_CommitNode,'EventId')
       ,p_show_competency_ratings      => hr_transaction_swi.getVarchar2Value(l_CommitNode,'ShowCompetencyRatings')
       ,p_show_objective_ratings       => hr_transaction_swi.getVarchar2Value(l_CommitNode,'ShowObjectiveRatings')
       ,p_show_questionnaire_info      => hr_transaction_swi.getVarchar2Value(l_CommitNode,'ShowQuestionnaireInfo')
       ,p_show_participant_details     => hr_transaction_swi.getVarchar2Value(l_CommitNode,'ShowParticipantDetails')
       ,p_show_participant_ratings     => hr_transaction_swi.getVarchar2Value(l_CommitNode,'ShowParticipantRatings')
       ,p_show_participant_names       => hr_transaction_swi.getVarchar2Value(l_CommitNode,'ShowParticipantNames')
       ,p_show_overall_ratings         => hr_transaction_swi.getVarchar2Value(l_CommitNode,'ShowOverallRatings')
       ,p_show_overall_comments        => hr_transaction_swi.getVarchar2Value(l_CommitNode,'ShowOverallComments')
       ,p_update_appraisal             => hr_transaction_swi.getVarchar2Value(l_CommitNode,'UpdateAppraisal')
       ,p_provide_overall_feedback     => hr_transaction_swi.getVarchar2Value(l_CommitNode,'ProvideOverallFeedback')
       ,p_appraisee_comments           => hr_transaction_swi.getVarchar2Value(l_CommitNode,'AppraiseeComments')
       ,p_retention_potential           => hr_transaction_swi.getVarchar2Value(l_CommitNode,'RetentionPotential')
       ,p_show_participant_comments     => hr_transaction_swi.getVarchar2Value(l_CommitNode,'ShowParticipantComments')  -- 8651478 bug fix
      );

   elsif l_postState = '3' then

       delete_appraisal
      ( p_validate                     => p_validate
       ,p_appraisal_id                 => hr_transaction_swi.getNumberValue(l_CommitNode,'AppraisalId')
       ,p_object_version_number        => l_object_version_number
       ,p_return_status                => l_return_status
      );

      p_return_status := l_return_status;

   end if;

   hr_utility.set_location('Exiting:' || l_proc,40);

END process_api;
end hr_appraisals_swi;

/
