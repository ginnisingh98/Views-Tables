--------------------------------------------------------
--  DDL for Package Body HR_APPRAISAL_TEMPLATES_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_APPRAISAL_TEMPLATES_SWI" As
/* $Header: peaptswi.pkb 120.1.12010000.5 2010/02/09 14:59:54 psugumar ship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'hr_appraisal_templates_swi.';
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_appraisal_template >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_appraisal_template
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_business_group_id            in     number
  ,p_appraisal_template_id        in     number
  ,p_name                         in     varchar2
  ,p_description                  in     varchar2  default null
  ,p_instructions                 in     varchar2  default null
  ,p_date_from                    in     date      default null
  ,p_date_to                      in     date      default null
  ,p_assessment_type_id           in     number    default null
  ,p_rating_scale_id              in     number    default null
  ,p_questionnaire_template_id    in     number    default null
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
  ,p_objective_asmnt_type_id      in     number    default null
  ,p_ma_quest_template_id         in     number    default null
  ,p_link_appr_to_learning_path   in     varchar2  default null
  ,p_final_score_formula_id       in     number    default null
  ,p_update_personal_comp_profile in     varchar2  default null
  ,p_comp_profile_source_type     in     varchar2  default null
  ,p_show_competency_ratings      in     varchar2  default null
  ,p_show_objective_ratings       in     varchar2  default null
  ,p_show_overall_ratings         in     varchar2  default null
  ,p_show_overall_comments        in     varchar2  default null
  ,p_provide_overall_feedback     in     varchar2  default null
  ,p_show_participant_details     in     varchar2  default null
  ,p_allow_add_participant        in     varchar2  default null
  ,p_show_additional_details      in     varchar2  default null
  ,p_show_participant_names       in     varchar2  default null
  ,p_show_participant_ratings     in     varchar2  default null
  ,p_available_flag               in     varchar2  default null
  ,p_show_questionnaire_info      in     varchar2  default null
  ,p_ma_off_template_code		      in 	   varchar2  default null
  ,p_appraisee_off_template_code  in	   varchar2  default null
  ,p_other_part_off_template_code in	   varchar2  default null
  ,p_part_app_off_template_code	  in     varchar2  default null
  ,p_part_rev_off_template_code   in	   varchar2  default null
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  ,p_show_participant_comments     in varchar2            default null  -- 8651478 bug fix

  ,p_show_term_employee            in varchar2            default null  -- 6181267 bug fix
  ,p_show_term_contigent           in varchar2            default null  -- 6181267 bug fix
  ,p_disp_term_emp_period_from     in     number            default null  -- 6181267 bug fix
  ,p_SHOW_FUTURE_TERM_EMPLOYEE          in varchar2            default null  -- 6181267 bug fix

  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'create_appraisal_template';
  l_assessment_type_id    per_assessment_types.assessment_type_id%Type;
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_appraisal_template_swi;
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
    per_apt_ins.set_base_key_value(
     p_appraisal_template_id => p_appraisal_template_id );
  --
  -- Call API
  --
  hr_appraisal_templates_api.create_appraisal_template
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_business_group_id            => p_business_group_id
    ,p_name                         => p_name
    ,p_description                  => p_description
    ,p_instructions                 => p_instructions
    ,p_date_from                    => p_date_from
    ,p_date_to                      => p_date_to
    ,p_assessment_type_id           => p_assessment_type_id
    ,p_rating_scale_id              => p_rating_scale_id
    ,p_questionnaire_template_id    => p_questionnaire_template_id
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
    ,p_objective_asmnt_type_id      => p_objective_asmnt_type_id
    ,p_ma_quest_template_id         => p_ma_quest_template_id
    ,p_link_appr_to_learning_path   => p_link_appr_to_learning_path
    ,p_final_score_formula_id       => p_final_score_formula_id
    ,p_update_personal_comp_profile => p_update_personal_comp_profile
    ,p_comp_profile_source_type     => p_comp_profile_source_type
    ,p_show_competency_ratings      => p_show_competency_ratings
    ,p_show_objective_ratings       => p_show_objective_ratings
    ,p_show_overall_ratings         => p_show_overall_ratings
    ,p_show_overall_comments        => p_show_overall_comments
    ,p_provide_overall_feedback     => p_provide_overall_feedback
    ,p_show_participant_details     => p_show_participant_details
    ,p_allow_add_participant        => p_allow_add_participant
    ,p_show_additional_details      => p_show_additional_details
    ,p_show_participant_names       => p_show_participant_names
    ,p_show_participant_ratings     => p_show_participant_ratings
    ,p_available_flag               => p_available_flag
    ,p_show_questionnaire_info      => p_show_questionnaire_info
    ,p_ma_off_template_code			    => p_ma_off_template_code
    ,p_appraisee_off_template_code	=> p_appraisee_off_template_code
    ,p_other_part_off_template_code	=> p_other_part_off_template_code
    ,p_part_app_off_template_code	  => p_part_app_off_template_code
    ,p_part_rev_off_template_code	  => p_part_rev_off_template_code
    ,p_appraisal_template_id        => l_assessment_type_id
    ,p_object_version_number        => p_object_version_number
   ,p_show_participant_comments     =>     p_show_participant_comments -- 8651478 bug fix
    ,p_show_term_employee           => p_show_term_employee  -- 6181267 bug fix
    ,p_show_term_contigent          => p_show_term_contigent   -- 6181267 bug fix
    ,p_disp_term_emp_period_from    => p_disp_term_emp_period_from   -- 6181267 bug fix
    ,p_SHOW_FUTURE_TERM_EMPLOYEE         => p_SHOW_FUTURE_TERM_EMPLOYEE -- 6181267 bug fix
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
    rollback to create_appraisal_template_swi;
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
    rollback to create_appraisal_template_swi;
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
end create_appraisal_template;
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_appraisal_template >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_appraisal_template
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_appraisal_template_id        in     number
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
  l_proc    varchar2(72) := g_package ||'delete_appraisal_template';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_appraisal_template_swi;
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
  hr_appraisal_templates_api.delete_appraisal_template
    (p_validate                     => l_validate
    ,p_appraisal_template_id        => p_appraisal_template_id
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
    rollback to delete_appraisal_template_swi;
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
    rollback to delete_appraisal_template_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_appraisal_template;
-- ----------------------------------------------------------------------------
-- |-----------------------< update_appraisal_template >----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_appraisal_template
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_appraisal_template_id        in     number
  ,p_object_version_number        in out nocopy number
  ,p_name                         in     varchar2  default hr_api.g_varchar2
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_instructions                 in     varchar2  default hr_api.g_varchar2
  ,p_date_from                    in     date      default hr_api.g_date
  ,p_date_to                      in     date      default hr_api.g_date
  ,p_assessment_type_id           in     number    default hr_api.g_number
  ,p_rating_scale_id              in     number    default hr_api.g_number
  ,p_questionnaire_template_id    in     number    default hr_api.g_number
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
  ,p_objective_asmnt_type_id      in     number    default hr_api.g_number
  ,p_ma_quest_template_id         in     number    default hr_api.g_number
  ,p_link_appr_to_learning_path   in     varchar2  default hr_api.g_varchar2
  ,p_final_score_formula_id       in     number    default hr_api.g_number
  ,p_update_personal_comp_profile in     varchar2  default hr_api.g_varchar2
  ,p_comp_profile_source_type     in     varchar2  default hr_api.g_varchar2
  ,p_show_competency_ratings      in     varchar2  default hr_api.g_varchar2
  ,p_show_objective_ratings       in     varchar2  default hr_api.g_varchar2
  ,p_show_overall_ratings         in     varchar2  default hr_api.g_varchar2
  ,p_show_overall_comments        in     varchar2  default hr_api.g_varchar2
  ,p_provide_overall_feedback     in     varchar2  default hr_api.g_varchar2
  ,p_show_participant_details     in     varchar2  default hr_api.g_varchar2
  ,p_allow_add_participant        in     varchar2  default hr_api.g_varchar2
  ,p_show_additional_details      in     varchar2  default hr_api.g_varchar2
  ,p_show_participant_names       in     varchar2  default hr_api.g_varchar2
  ,p_show_participant_ratings     in     varchar2  default hr_api.g_varchar2
  ,p_available_flag               in     varchar2  default hr_api.g_varchar2
  ,p_show_questionnaire_info      in     varchar2  default hr_api.g_varchar2
  ,p_ma_off_template_code		      in 	   varchar2  default hr_api.g_varchar2
  ,p_appraisee_off_template_code  in	   varchar2  default hr_api.g_varchar2
  ,p_other_part_off_template_code in	   varchar2  default hr_api.g_varchar2
  ,p_part_app_off_template_code	  in     varchar2  default hr_api.g_varchar2
  ,p_part_rev_off_template_code   in	   varchar2  default hr_api.g_varchar2
  ,p_return_status                   out nocopy varchar2
  , p_show_participant_comments     in varchar2         default hr_api.g_varchar2  -- 8651478 bug fix
  ,p_show_term_employee            in varchar2            default hr_api.g_varchar2  -- 6181267 bug fix
  ,p_show_term_contigent           in varchar2            default hr_api.g_varchar2  -- 6181267 bug fix
  ,p_disp_term_emp_period_from     in     number            default hr_api.g_number  -- 6181267 bug fix
  ,p_SHOW_FUTURE_TERM_EMPLOYEE          in varchar2            default hr_api.g_varchar2  -- 6181267 bug fix
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_appraisal_template';
Begin


  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_appraisal_template_swi;
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
  hr_appraisal_templates_api.update_appraisal_template
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_appraisal_template_id        => p_appraisal_template_id
    ,p_object_version_number        => p_object_version_number
    ,p_name                         => p_name
    ,p_description                  => p_description
    ,p_instructions                 => p_instructions
    ,p_date_from                    => p_date_from
    ,p_date_to                      => p_date_to
    ,p_assessment_type_id           => p_assessment_type_id
    ,p_rating_scale_id              => p_rating_scale_id
    ,p_questionnaire_template_id    => p_questionnaire_template_id
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
    ,p_objective_asmnt_type_id      => p_objective_asmnt_type_id
    ,p_ma_quest_template_id         => p_ma_quest_template_id
    ,p_link_appr_to_learning_path   => p_link_appr_to_learning_path
    ,p_final_score_formula_id       => p_final_score_formula_id
    ,p_update_personal_comp_profile => p_update_personal_comp_profile
    ,p_comp_profile_source_type     => p_comp_profile_source_type
    ,p_show_competency_ratings      => p_show_competency_ratings
    ,p_show_objective_ratings       => p_show_objective_ratings
    ,p_show_overall_ratings         => p_show_overall_ratings
    ,p_show_overall_comments        => p_show_overall_comments
    ,p_provide_overall_feedback     => p_provide_overall_feedback
    ,p_show_participant_details     => p_show_participant_details
    ,p_allow_add_participant        => p_allow_add_participant
    ,p_show_additional_details      => p_show_additional_details
    ,p_show_participant_names       => p_show_participant_names
    ,p_show_participant_ratings     => p_show_participant_ratings
    ,p_available_flag               => p_available_flag
    ,p_show_questionnaire_info      => p_show_questionnaire_info
    ,p_ma_off_template_code			=> p_ma_off_template_code
  	,p_appraisee_off_template_code	=> p_appraisee_off_template_code
  	,p_other_part_off_template_code	=> p_other_part_off_template_code
  	,p_part_app_off_template_code  	=> p_part_app_off_template_code
  	,p_part_rev_off_template_code	=> p_part_rev_off_template_code
                          ,p_show_participant_comments     =>     p_show_participant_comments -- 8651478 bug fix
    ,p_show_term_employee           => p_show_term_employee  -- 6181267 bug fix
    ,p_show_term_contigent          => p_show_term_contigent   -- 6181267 bug fix
    ,p_disp_term_emp_period_from    => p_disp_term_emp_period_from   -- 6181267 bug fix
    ,p_SHOW_FUTURE_TERM_EMPLOYEE         => p_SHOW_FUTURE_TERM_EMPLOYEE -- 6181267 bug fix

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
    rollback to update_appraisal_template_swi;
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
    rollback to update_appraisal_template_swi;
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

end update_appraisal_template;
end hr_appraisal_templates_swi;

/
