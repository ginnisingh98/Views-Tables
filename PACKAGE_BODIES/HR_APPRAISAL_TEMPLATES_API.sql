--------------------------------------------------------
--  DDL for Package Body HR_APPRAISAL_TEMPLATES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_APPRAISAL_TEMPLATES_API" as
/* $Header: peaptapi.pkb 120.2.12010000.4 2010/02/09 15:03:32 psugumar ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_appraisal_templates_api.';
--
-- ---------------------------------------------------------------------------
-- |-----------------------< <create_appraisal_template> >--------------------------|
-- ---------------------------------------------------------------------------
--
procedure create_appraisal_template
 (p_validate                     in     boolean  	default false,
  p_effective_date               in     date,
  p_business_group_id            in 	number,
  p_name                         in 	varchar2,
  p_description                  in 	varchar2         default null,
  p_instructions                 in 	varchar2         default null,
  p_date_from                    in 	date             default null,
  p_date_to                      in 	date             default null,
  p_assessment_type_id           in 	number           default null,
  p_rating_scale_id              in 	number           default null,
  p_questionnaire_template_id    in 	number           default null,
  p_attribute_category           in 	varchar2         default null,
  p_attribute1                   in 	varchar2         default null,
  p_attribute2                   in 	varchar2         default null,
  p_attribute3                   in 	varchar2         default null,
  p_attribute4                   in 	varchar2         default null,
  p_attribute5                   in 	varchar2         default null,
  p_attribute6                   in 	varchar2         default null,
  p_attribute7                   in 	varchar2         default null,
  p_attribute8                   in 	varchar2         default null,
  p_attribute9                   in 	varchar2         default null,
  p_attribute10                  in 	varchar2         default null,
  p_attribute11                  in 	varchar2         default null,
  p_attribute12                  in 	varchar2         default null,
  p_attribute13                  in 	varchar2         default null,
  p_attribute14                  in 	varchar2         default null,
  p_attribute15                  in 	varchar2         default null,
  p_attribute16                  in 	varchar2         default null,
  p_attribute17                  in 	varchar2         default null,
  p_attribute18                  in 	varchar2         default null,
  p_attribute19                  in 	varchar2         default null,
  p_attribute20                  in 	varchar2         default null
  ,p_objective_asmnt_type_id        in     number   default null
  ,p_ma_quest_template_id           in     number   default null
  ,p_link_appr_to_learning_path     in     varchar2 default null
  ,p_final_score_formula_id         in     number   default null
  ,p_update_personal_comp_profile   in     varchar2 default null
  ,p_comp_profile_source_type       in     varchar2 default null
  ,p_show_competency_ratings        in     varchar2 default null
  ,p_show_objective_ratings         in     varchar2 default null
  ,p_show_overall_ratings           in     varchar2 default null
  ,p_show_overall_comments          in     varchar2 default null
  ,p_provide_overall_feedback       in     varchar2 default null
  ,p_show_participant_details       in     varchar2 default null
  ,p_allow_add_participant          in     varchar2 default null
  ,p_show_additional_details        in     varchar2 default null
  ,p_show_participant_names         in     varchar2 default null
  ,p_show_participant_ratings       in     varchar2 default null
  ,p_available_flag                 in     varchar2 default null
  ,p_show_questionnaire_info        in     varchar2  default null
  ,p_ma_off_template_code			      in 	   varchar2 default null
  ,p_appraisee_off_template_code	  in	   varchar2 default null
  ,p_other_part_off_template_code	  in	   varchar2 default null
  ,p_part_app_off_template_code	    in     varchar2 default null
  ,p_part_rev_off_template_code 	  in	   varchar2 default null,
  p_appraisal_template_id        out nocopy    number,
  p_object_version_number        out nocopy 	number,
p_show_participant_comments     in varchar2            default null  -- 8651478 bug fix
  ,p_show_term_employee            in varchar2            default null  -- 6181267 bug fix
  ,p_show_term_contigent           in varchar2            default null  -- 6181267 bug fix
  ,p_disp_term_emp_period_from     in     number            default null  -- 6181267 bug fix
  ,p_SHOW_FUTURE_TERM_EMPLOYEE          in varchar2            default null  -- 6181267 bug fix
)
 is
  --
  -- Declare cursors and local variables
  --
  --
  l_proc                	varchar2(72) := g_package||'create_appraisal_template';
  l_appraisal_template_id	per_appraisal_templates.appraisal_template_id%TYPE;
  l_object_version_number	per_appraisal_templates.object_version_number%TYPE;
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint.
  --
  savepoint create_appraisal_template;
  hr_utility.set_location(l_proc, 6);
  --
  -- Call Before Process User Hook
  --
  begin
	hr_appraisal_templates_bk1.create_appraisal_template_b	(
       p_effective_date               =>     p_effective_date,
       p_business_group_id            =>     p_business_group_id,
       p_name                         =>     p_name,
       p_description                  =>     p_description,
       p_instructions                 =>     p_instructions,
       p_date_from                    =>     trunc(p_date_from),
       p_date_to                      =>     trunc(p_date_to),
       p_assessment_type_id           =>     p_assessment_type_id,
       p_rating_scale_id              =>     p_rating_scale_id,
       p_questionnaire_template_id    =>     p_questionnaire_template_id,
       p_attribute_category           =>     p_attribute_category,
       p_attribute1                   =>     p_attribute1,
       p_attribute2                   =>     p_attribute2,
       p_attribute3                   =>     p_attribute3,
       p_attribute4                   =>     p_attribute4,
       p_attribute5                   =>     p_attribute5,
       p_attribute6                   =>     p_attribute6,
       p_attribute7                   =>     p_attribute7,
       p_attribute8                   =>     p_attribute8,
       p_attribute9                   =>     p_attribute9,
       p_attribute10                  =>     p_attribute10,
       p_attribute11                  =>     p_attribute11,
       p_attribute12                  =>     p_attribute12,
       p_attribute13                  =>     p_attribute13,
       p_attribute14                  =>     p_attribute14,
       p_attribute15                  =>     p_attribute15,
       p_attribute16                  =>     p_attribute16,
       p_attribute17                  =>     p_attribute17,
       p_attribute18                  =>     p_attribute18,
       p_attribute19                  =>     p_attribute19,
       p_attribute20                  =>     p_attribute20
        ,p_objective_asmnt_type_id
      => p_objective_asmnt_type_id
      ,p_ma_quest_template_id
      => p_ma_quest_template_id
      ,p_link_appr_to_learning_path
      => p_link_appr_to_learning_path
      ,p_final_score_formula_id
      => p_final_score_formula_id
      ,p_update_personal_comp_profile
      => p_update_personal_comp_profile
      ,p_comp_profile_source_type
      => p_comp_profile_source_type
      ,p_show_competency_ratings
      => p_show_competency_ratings
      ,p_show_objective_ratings
      => p_show_objective_ratings
      ,p_show_overall_ratings
      => p_show_overall_ratings
      ,p_show_overall_comments
      => p_show_overall_comments
      ,p_provide_overall_feedback
      => p_provide_overall_feedback
      ,p_show_participant_details
      => p_show_participant_details
      ,p_allow_add_participant
      => p_allow_add_participant
      ,p_show_additional_details
      => p_show_additional_details
      ,p_show_participant_names
      => p_show_participant_names
      ,p_show_participant_ratings
      => p_show_participant_ratings
      ,p_available_flag
      => p_available_flag
	  ,p_show_questionnaire_info => p_show_questionnaire_info
    ,p_ma_off_template_code		 => p_ma_off_template_code
	  ,p_appraisee_off_template_code 	=> p_appraisee_off_template_code
	  ,p_other_part_off_template_code	=> p_other_part_off_template_code
	  ,p_part_app_off_template_code	=> p_part_app_off_template_code
	  ,p_part_rev_off_template_code	=> p_part_rev_off_template_code
                           ,p_show_participant_comments     =>     p_show_participant_comments -- 8651478 bug fix
    ,p_show_term_employee           => p_show_term_employee  -- 6181267 bug fix
    ,p_show_term_contigent          => p_show_term_contigent   -- 6181267 bug fix
    ,p_disp_term_emp_period_from    => p_disp_term_emp_period_from   -- 6181267 bug fix
    ,p_SHOW_FUTURE_TERM_EMPLOYEE         => p_SHOW_FUTURE_TERM_EMPLOYEE -- 6181267 bug fix

      );
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'create_appraisal_template',
				 p_hook_type	=> 'BP'
				);
  end;
  --
  -- End of Before Process User Hook call
  --
  -- Validation in addition to Table Handlers
  --
  hr_utility.set_location(l_proc, 7);
  --
  -- Process Logic
  --
  per_apt_ins.ins
 (p_validate                     =>     p_validate,
  p_effective_date               =>     p_effective_date,
  p_business_group_id            =>     p_business_group_id,
  p_name                         =>     p_name,
  p_description                  =>     p_description,
  p_instructions                 =>     p_instructions,
  p_date_from                    =>     trunc(p_date_from),
  p_date_to                      =>     trunc(p_date_to),
  p_assessment_type_id           =>     p_assessment_type_id,
  p_rating_scale_id              =>     p_rating_scale_id,
  p_questionnaire_template_id    =>     p_questionnaire_template_id,
  p_attribute_category           =>     p_attribute_category,
  p_attribute1                   =>     p_attribute1,
  p_attribute2                   =>     p_attribute2,
  p_attribute3                   =>     p_attribute3,
  p_attribute4                   =>     p_attribute4,
  p_attribute5                   =>     p_attribute5,
  p_attribute6                   =>     p_attribute6,
  p_attribute7                   =>     p_attribute7,
  p_attribute8                   =>     p_attribute8,
  p_attribute9                   =>     p_attribute9,
  p_attribute10                  =>     p_attribute10,
  p_attribute11                  =>     p_attribute11,
  p_attribute12                  =>     p_attribute12,
  p_attribute13                  =>     p_attribute13,
  p_attribute14                  =>     p_attribute14,
  p_attribute15                  =>     p_attribute15,
  p_attribute16                  =>     p_attribute16,
  p_attribute17                  =>     p_attribute17,
  p_attribute18                  =>     p_attribute18,
  p_attribute19                  =>     p_attribute19,
  p_attribute20                  =>     p_attribute20
   ,p_objective_asmnt_type_id
      => p_objective_asmnt_type_id
      ,p_ma_quest_template_id
      => p_ma_quest_template_id
      ,p_link_appr_to_learning_path
      => p_link_appr_to_learning_path
      ,p_final_score_formula_id
      => p_final_score_formula_id
      ,p_update_personal_comp_profile
      => p_update_personal_comp_profile
      ,p_comp_profile_source_type
      => p_comp_profile_source_type
      ,p_show_competency_ratings
      => p_show_competency_ratings
      ,p_show_objective_ratings
      => p_show_objective_ratings
      ,p_show_overall_ratings
      => p_show_overall_ratings
      ,p_show_overall_comments
      => p_show_overall_comments
      ,p_provide_overall_feedback
      => p_provide_overall_feedback
      ,p_show_participant_details
      => p_show_participant_details
      ,p_allow_add_participant
      => p_allow_add_participant
      ,p_show_additional_details
      => p_show_additional_details
      ,p_show_participant_names
      => p_show_participant_names
      ,p_show_participant_ratings
      => p_show_participant_ratings
      ,p_available_flag
      => p_available_flag
	  ,p_show_questionnaire_info => p_show_questionnaire_info
    ,p_ma_off_template_code		      => p_ma_off_template_code
	  ,p_appraisee_off_template_code 	=> p_appraisee_off_template_code
	  ,p_other_part_off_template_code	=> p_other_part_off_template_code
	  ,p_part_app_off_template_code	  => p_part_app_off_template_code
	  ,p_part_rev_off_template_code	  => p_part_rev_off_template_code,
  p_appraisal_template_id        =>     l_appraisal_template_id,
  p_object_version_number        =>     l_object_version_number,
p_show_participant_comments     =>     p_show_participant_comments -- 8651478 bug fix
    ,p_show_term_employee           => p_show_term_employee  -- 6181267 bug fix
    ,p_show_term_contigent          => p_show_term_contigent   -- 6181267 bug fix
    ,p_disp_term_emp_period_from    => p_disp_term_emp_period_from   -- 6181267 bug fix
    ,p_SHOW_FUTURE_TERM_EMPLOYEE         => p_SHOW_FUTURE_TERM_EMPLOYEE -- 6181267 bug fix

  );
  --
  hr_utility.set_location(l_proc, 8);
  --
  -- Call After Process User Hook
  --
  begin
	hr_appraisal_templates_bk1.create_appraisal_template_a	(
       p_appraisal_template_id        =>     l_appraisal_template_id,
       p_object_version_number        =>     l_object_version_number,
       p_effective_date               =>     p_effective_date,
       p_business_group_id            =>     p_business_group_id,
       p_name                         =>     p_name,
       p_description                  =>     p_description,
       p_instructions                 =>     p_instructions,
       p_date_from                    =>     trunc(p_date_from),
       p_date_to                      =>     trunc(p_date_to),
       p_assessment_type_id           =>     p_assessment_type_id,
       p_rating_scale_id              =>     p_rating_scale_id,
       p_questionnaire_template_id    =>     p_questionnaire_template_id,
       p_attribute_category           =>     p_attribute_category,
       p_attribute1                   =>     p_attribute1,
       p_attribute2                   =>     p_attribute2,
       p_attribute3                   =>     p_attribute3,
       p_attribute4                   =>     p_attribute4,
       p_attribute5                   =>     p_attribute5,
       p_attribute6                   =>     p_attribute6,
       p_attribute7                   =>     p_attribute7,
       p_attribute8                   =>     p_attribute8,
       p_attribute9                   =>     p_attribute9,
       p_attribute10                  =>     p_attribute10,
       p_attribute11                  =>     p_attribute11,
       p_attribute12                  =>     p_attribute12,
       p_attribute13                  =>     p_attribute13,
       p_attribute14                  =>     p_attribute14,
       p_attribute15                  =>     p_attribute15,
       p_attribute16                  =>     p_attribute16,
       p_attribute17                  =>     p_attribute17,
       p_attribute18                  =>     p_attribute18,
       p_attribute19                  =>     p_attribute19,
       p_attribute20                  =>     p_attribute20
        ,p_objective_asmnt_type_id
      => p_objective_asmnt_type_id
      ,p_ma_quest_template_id
      => p_ma_quest_template_id
      ,p_link_appr_to_learning_path
      => p_link_appr_to_learning_path
      ,p_final_score_formula_id
      => p_final_score_formula_id
      ,p_update_personal_comp_profile
      => p_update_personal_comp_profile
      ,p_comp_profile_source_type
      => p_comp_profile_source_type
      ,p_show_competency_ratings
      => p_show_competency_ratings
      ,p_show_objective_ratings
      => p_show_objective_ratings
      ,p_show_overall_ratings
      => p_show_overall_ratings
      ,p_show_overall_comments
      => p_show_overall_comments
      ,p_provide_overall_feedback
      => p_provide_overall_feedback
      ,p_show_participant_details
      => p_show_participant_details
      ,p_allow_add_participant
      => p_allow_add_participant
      ,p_show_additional_details
      => p_show_additional_details
      ,p_show_participant_names
      => p_show_participant_names
      ,p_show_participant_ratings
      => p_show_participant_ratings
      ,p_available_flag
      => p_available_flag
	  ,p_show_questionnaire_info => p_show_questionnaire_info
    ,p_ma_off_template_code		 => p_ma_off_template_code
	  ,p_appraisee_off_template_code 	=> p_appraisee_off_template_code
	  ,p_other_part_off_template_code	=> p_other_part_off_template_code
	  ,p_part_app_off_template_code	=> p_part_app_off_template_code
	  ,p_part_rev_off_template_code	=> p_part_rev_off_template_code
                              ,p_show_participant_comments     =>     p_show_participant_comments -- 8651478 bug fix
    ,p_show_term_employee           => p_show_term_employee  -- 6181267 bug fix
    ,p_show_term_contigent          => p_show_term_contigent   -- 6181267 bug fix
    ,p_disp_term_emp_period_from    => p_disp_term_emp_period_from   -- 6181267 bug fix
    ,p_SHOW_FUTURE_TERM_EMPLOYEE         => p_SHOW_FUTURE_TERM_EMPLOYEE -- 6181267 bug fix

      );
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'create_appraisal_template',
				 p_hook_type	=> 'AP'
				);
  end;
  --
  -- End of After process user hook
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_appraisal_template_id	:= l_appraisal_template_id;
  p_object_version_number  	:= l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 11);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_appraisal_template;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_appraisal_template_id  := null;
    p_object_version_number  := null;
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632482
    --
    ROLLBACK TO create_appraisal_template;
    raise;
    --
    -- End of fix.
    --
    hr_utility.set_location(' Leaving:'||l_proc, 12);
end create_appraisal_template;
--
--
-- ---------------------------------------------------------------------------
-- |-----------------------< <update_appraisal_template> >--------------------------|
-- ---------------------------------------------------------------------------
--
procedure update_appraisal_template
 (p_validate                     in boolean	default false,
  p_effective_date               in date,
  p_appraisal_template_id        in number,
  p_object_version_number        in out nocopy number,
  p_name                         in varchar2         default hr_api.g_varchar2,
  p_description                  in varchar2         default hr_api.g_varchar2,
  p_instructions                 in varchar2         default hr_api.g_varchar2,
  p_date_from                    in date             default hr_api.g_date,
  p_date_to                      in date             default hr_api.g_date,
  p_assessment_type_id           in number           default hr_api.g_number,
  p_rating_scale_id              in number           default hr_api.g_number,
  p_questionnaire_template_id    in number           default hr_api.g_number,
  p_attribute_category           in varchar2         default hr_api.g_varchar2,
  p_attribute1                   in varchar2         default hr_api.g_varchar2,
  p_attribute2                   in varchar2         default hr_api.g_varchar2,
  p_attribute3                   in varchar2         default hr_api.g_varchar2,
  p_attribute4                   in varchar2         default hr_api.g_varchar2,
  p_attribute5                   in varchar2         default hr_api.g_varchar2,
  p_attribute6                   in varchar2         default hr_api.g_varchar2,
  p_attribute7                   in varchar2         default hr_api.g_varchar2,
  p_attribute8                   in varchar2         default hr_api.g_varchar2,
  p_attribute9                   in varchar2         default hr_api.g_varchar2,
  p_attribute10                  in varchar2         default hr_api.g_varchar2,
  p_attribute11                  in varchar2         default hr_api.g_varchar2,
  p_attribute12                  in varchar2         default hr_api.g_varchar2,
  p_attribute13                  in varchar2         default hr_api.g_varchar2,
  p_attribute14                  in varchar2         default hr_api.g_varchar2,
  p_attribute15                  in varchar2         default hr_api.g_varchar2,
  p_attribute16                  in varchar2         default hr_api.g_varchar2,
  p_attribute17                  in varchar2         default hr_api.g_varchar2,
  p_attribute18                  in varchar2         default hr_api.g_varchar2,
  p_attribute19                  in varchar2         default hr_api.g_varchar2,
  p_attribute20                  in varchar2         default hr_api.g_varchar2,
  p_objective_asmnt_type_id      in     number    default hr_api.g_number
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
  ,p_show_questionnaire_info       in     varchar2  default hr_api.g_varchar2
  ,p_ma_off_template_code		      in 	   varchar2  default hr_api.g_varchar2
  ,p_appraisee_off_template_code  in	   varchar2  default hr_api.g_varchar2
  ,p_other_part_off_template_code in	   varchar2  default hr_api.g_varchar2
  ,p_part_app_off_template_code	  in     varchar2  default hr_api.g_varchar2
  ,p_part_rev_off_template_code   in	   varchar2  default hr_api.g_varchar2
  ,p_show_participant_comments     in varchar2         default hr_api.g_varchar2  -- 8651478 bug fix

  ,p_show_term_employee            in varchar2            default  hr_api.g_varchar2  -- 6181267 bug fix
  ,p_show_term_contigent           in varchar2            default  hr_api.g_varchar2  -- 6181267 bug fix
  ,p_disp_term_emp_period_from     in     number            default   hr_api.g_number  -- 6181267 bug fix
  ,p_SHOW_FUTURE_TERM_EMPLOYEE          in varchar2            default  hr_api.g_varchar2  -- 6181267 bug fix

  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                	 varchar2(72) := g_package||'update_appraisal_template';
  l_object_version_number	 per_appraisal_templates.object_version_number%TYPE;
 --
  lv_object_version_number       per_appraisal_templates.object_version_number%TYPE := p_object_version_number ;
 --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint.
  --
  savepoint update_appraisal_template;
  hr_utility.set_location(l_proc, 6);
  --
  --
  -- Call Before Process User Hook
  --
  begin
	hr_appraisal_templates_bk2.update_appraisal_template_b	(
       p_effective_date               =>     p_effective_date,
       p_appraisal_template_id        =>     p_appraisal_template_id,
       p_object_version_number        =>     p_object_version_number,
       p_name                         =>     p_name,
       p_description                  =>     p_description,
       p_instructions                 =>     p_instructions,
       p_date_from                    =>     trunc(p_date_from),
       p_date_to                      =>     trunc(p_date_to),
       p_assessment_type_id           =>     p_assessment_type_id,
       p_rating_scale_id              =>     p_rating_scale_id,
       p_questionnaire_template_id    =>     p_questionnaire_template_id,
       p_attribute_category           =>     p_attribute_category,
       p_attribute1                   =>     p_attribute1,
       p_attribute2                   =>     p_attribute2,
       p_attribute3                   =>     p_attribute3,
       p_attribute4                   =>     p_attribute4,
       p_attribute5                   =>     p_attribute5,
       p_attribute6                   =>     p_attribute6,
       p_attribute7                   =>     p_attribute7,
       p_attribute8                   =>     p_attribute8,
       p_attribute9                   =>     p_attribute9,
       p_attribute10                  =>     p_attribute10,
       p_attribute11                  =>     p_attribute11,
       p_attribute12                  =>     p_attribute12,
       p_attribute13                  =>     p_attribute13,
       p_attribute14                  =>     p_attribute14,
       p_attribute15                  =>     p_attribute15,
       p_attribute16                  =>     p_attribute16,
       p_attribute17                  =>     p_attribute17,
       p_attribute18                  =>     p_attribute18,
       p_attribute19                  =>     p_attribute19,
       p_attribute20                  =>     p_attribute20
        ,p_objective_asmnt_type_id
      => p_objective_asmnt_type_id
      ,p_ma_quest_template_id
      => p_ma_quest_template_id
      ,p_link_appr_to_learning_path
      => p_link_appr_to_learning_path
      ,p_final_score_formula_id
      => p_final_score_formula_id
      ,p_update_personal_comp_profile
      => p_update_personal_comp_profile
      ,p_comp_profile_source_type
      => p_comp_profile_source_type
      ,p_show_competency_ratings
      => p_show_competency_ratings
      ,p_show_objective_ratings
      => p_show_objective_ratings
      ,p_show_overall_ratings
      => p_show_overall_ratings
      ,p_show_overall_comments
      => p_show_overall_comments
      ,p_provide_overall_feedback
      => p_provide_overall_feedback
      ,p_show_participant_details
      => p_show_participant_details
      ,p_allow_add_participant
      => p_allow_add_participant
      ,p_show_additional_details
      => p_show_additional_details
      ,p_show_participant_names
      => p_show_participant_names
      ,p_show_participant_ratings
      => p_show_participant_ratings
      ,p_available_flag
      => p_available_flag
	  ,p_show_questionnaire_info => p_show_questionnaire_info
    ,p_ma_off_template_code 	       =>	 p_ma_off_template_code
	  ,p_appraisee_off_template_code	 => p_appraisee_off_template_code
	  ,p_other_part_off_template_code	 =>	p_other_part_off_template_code
	  ,p_part_app_off_template_code	   =>	p_part_app_off_template_code
	  ,p_part_rev_off_template_code	   =>	p_part_rev_off_template_code
                            , p_show_participant_comments     =>     p_show_participant_comments -- 8651478 bug fix
    ,p_show_term_employee           => p_show_term_employee  -- 6181267 bug fix
    ,p_show_term_contigent          => p_show_term_contigent   -- 6181267 bug fix
    ,p_disp_term_emp_period_from    => p_disp_term_emp_period_from   -- 6181267 bug fix
    ,p_SHOW_FUTURE_TERM_EMPLOYEE         => p_SHOW_FUTURE_TERM_EMPLOYEE -- 6181267 bug fix

      );
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'update_appraisal_template',
				 p_hook_type	=> 'BP'
				);
  end;
  --
  -- Validation in addition to Table Handlers
  --
  hr_utility.set_location(l_proc, 7);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  per_apt_upd.upd
 (p_validate                     =>     p_validate,
  p_effective_date               =>     p_effective_date,
  p_appraisal_template_id        =>     p_appraisal_template_id,
  p_object_version_number        =>     l_object_version_number,
  p_name                         =>     p_name,
  p_description                  =>     p_description,
  p_instructions                 =>     p_instructions,
  p_date_from                    =>     trunc(p_date_from),
  p_date_to                      =>     trunc(p_date_to),
  p_assessment_type_id           =>     p_assessment_type_id,
  p_rating_scale_id              =>     p_rating_scale_id,
  p_questionnaire_template_id    =>     p_questionnaire_template_id,
  p_attribute_category           =>     p_attribute_category,
  p_attribute1                   =>     p_attribute1,
  p_attribute2                   =>     p_attribute2,
  p_attribute3                   =>     p_attribute3,
  p_attribute4                   =>     p_attribute4,
  p_attribute5                   =>     p_attribute5,
  p_attribute6                   =>     p_attribute6,
  p_attribute7                   =>     p_attribute7,
  p_attribute8                   =>     p_attribute8,
  p_attribute9                   =>     p_attribute9,
  p_attribute10                  =>     p_attribute10,
  p_attribute11                  =>     p_attribute11,
  p_attribute12                  =>     p_attribute12,
  p_attribute13                  =>     p_attribute13,
  p_attribute14                  =>     p_attribute14,
  p_attribute15                  =>     p_attribute15,
  p_attribute16                  =>     p_attribute16,
  p_attribute17                  =>     p_attribute17,
  p_attribute18                  =>     p_attribute18,
  p_attribute19                  =>     p_attribute19,
  p_attribute20                  =>     p_attribute20
   ,p_objective_asmnt_type_id
      => p_objective_asmnt_type_id
      ,p_ma_quest_template_id
      => p_ma_quest_template_id
      ,p_link_appr_to_learning_path
      => p_link_appr_to_learning_path
      ,p_final_score_formula_id
      => p_final_score_formula_id
      ,p_update_personal_comp_profile
      => p_update_personal_comp_profile
      ,p_comp_profile_source_type
      => p_comp_profile_source_type
      ,p_show_competency_ratings
      => p_show_competency_ratings
      ,p_show_objective_ratings
      => p_show_objective_ratings
      ,p_show_overall_ratings
      => p_show_overall_ratings
      ,p_show_overall_comments
      => p_show_overall_comments
      ,p_provide_overall_feedback
      => p_provide_overall_feedback
      ,p_show_participant_details
      => p_show_participant_details
      ,p_allow_add_participant
      => p_allow_add_participant
      ,p_show_additional_details
      => p_show_additional_details
      ,p_show_participant_names
      => p_show_participant_names
      ,p_show_participant_ratings
      => p_show_participant_ratings
      ,p_available_flag
      => p_available_flag
	  ,p_show_questionnaire_info => p_show_questionnaire_info
    ,p_ma_off_template_code		 =>	 p_ma_off_template_code
	  ,p_appraisee_off_template_code	 => p_appraisee_off_template_code
	  ,p_other_part_off_template_code	 =>	p_other_part_off_template_code
	  ,p_part_app_off_template_code	 =>	p_part_app_off_template_code
	  ,p_part_rev_off_template_code	 =>	p_part_rev_off_template_code
                           , p_show_participant_comments     =>     p_show_participant_comments -- 8651478 bug fix
    ,p_show_term_employee           => p_show_term_employee  -- 6181267 bug fix
    ,p_show_term_contigent          => p_show_term_contigent   -- 6181267 bug fix
    ,p_disp_term_emp_period_from    => p_disp_term_emp_period_from   -- 6181267 bug fix
    ,p_SHOW_FUTURE_TERM_EMPLOYEE         => p_SHOW_FUTURE_TERM_EMPLOYEE -- 6181267 bug fix

  );
  --
  --
  hr_utility.set_location(l_proc, 8);
  --
  -- Call After Process User Hook
  --
  begin
	hr_appraisal_templates_bk2.update_appraisal_template_a	(
       p_effective_date               =>     p_effective_date,
       p_appraisal_template_id        =>     p_appraisal_template_id,
       p_object_version_number        =>     l_object_version_number,
       p_name                         =>     p_name,
       p_description                  =>     p_description,
       p_instructions                 =>     p_instructions,
       p_date_from                    =>     trunc(p_date_from),
       p_date_to                      =>     trunc(p_date_to),
       p_assessment_type_id           =>     p_assessment_type_id,
       p_rating_scale_id              =>     p_rating_scale_id,
       p_questionnaire_template_id    =>     p_questionnaire_template_id,
       p_attribute_category           =>     p_attribute_category,
       p_attribute1                   =>     p_attribute1,
       p_attribute2                   =>     p_attribute2,
       p_attribute3                   =>     p_attribute3,
       p_attribute4                   =>     p_attribute4,
       p_attribute5                   =>     p_attribute5,
       p_attribute6                   =>     p_attribute6,
       p_attribute7                   =>     p_attribute7,
       p_attribute8                   =>     p_attribute8,
       p_attribute9                   =>     p_attribute9,
       p_attribute10                  =>     p_attribute10,
       p_attribute11                  =>     p_attribute11,
       p_attribute12                  =>     p_attribute12,
       p_attribute13                  =>     p_attribute13,
       p_attribute14                  =>     p_attribute14,
       p_attribute15                  =>     p_attribute15,
       p_attribute16                  =>     p_attribute16,
       p_attribute17                  =>     p_attribute17,
       p_attribute18                  =>     p_attribute18,
       p_attribute19                  =>     p_attribute19,
       p_attribute20                  =>     p_attribute20
        ,p_objective_asmnt_type_id
      => p_objective_asmnt_type_id
      ,p_ma_quest_template_id
      => p_ma_quest_template_id
      ,p_link_appr_to_learning_path
      => p_link_appr_to_learning_path
      ,p_final_score_formula_id
      => p_final_score_formula_id
      ,p_update_personal_comp_profile
      => p_update_personal_comp_profile
      ,p_comp_profile_source_type
      => p_comp_profile_source_type
      ,p_show_competency_ratings
      => p_show_competency_ratings
      ,p_show_objective_ratings
      => p_show_objective_ratings
      ,p_show_overall_ratings
      => p_show_overall_ratings
      ,p_show_overall_comments
      => p_show_overall_comments
      ,p_provide_overall_feedback
      => p_provide_overall_feedback
      ,p_show_participant_details
      => p_show_participant_details
      ,p_allow_add_participant
      => p_allow_add_participant
      ,p_show_additional_details
      => p_show_additional_details
      ,p_show_participant_names
      => p_show_participant_names
      ,p_show_participant_ratings
      => p_show_participant_ratings
      ,p_available_flag
      => p_available_flag
  	  ,p_show_questionnaire_info => p_show_questionnaire_info
      ,p_ma_off_template_code 	 =>	 p_ma_off_template_code
	    ,p_appraisee_off_template_code	 => p_appraisee_off_template_code
	    ,p_other_part_off_template_code	 =>	p_other_part_off_template_code
	    ,p_part_app_off_template_code	 =>	p_part_app_off_template_code
	    ,p_part_rev_off_template_code	 =>	p_part_rev_off_template_code
                               , p_show_participant_comments     =>     p_show_participant_comments -- 8651478 bug fix
    ,p_show_term_employee           => p_show_term_employee  -- 6181267 bug fix
    ,p_show_term_contigent          => p_show_term_contigent   -- 6181267 bug fix
    ,p_disp_term_emp_period_from    => p_disp_term_emp_period_from   -- 6181267 bug fix
    ,p_SHOW_FUTURE_TERM_EMPLOYEE         => p_SHOW_FUTURE_TERM_EMPLOYEE -- 6181267 bug fix

      );
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'update_appraisal_template',
				 p_hook_type	=> 'AP'
				);
  end;
  --
  -- End After Process User Hook
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments. l_object_version_number now has the new
  -- object version number as the update was successful
  --
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 11);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_appraisal_template;
    --
    -- Only set output warning arguments and in out arguments back
    -- to their IN value
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := l_object_version_number;
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632482
    --
    p_object_version_number  := lv_object_version_number;

    ROLLBACK TO update_appraisal_template;
    raise;
    --
    -- End of fix.
    --
    hr_utility.set_location(' Leaving:'||l_proc, 12);
--
end update_appraisal_template;
--
--
-- ---------------------------------------------------------------------------
-- |-----------------------< <delete_appraisal_template> >--------------------------|
-- ---------------------------------------------------------------------------
--
procedure delete_appraisal_template
(p_validate                           in boolean default false,
 p_appraisal_template_id              in number,
 p_object_version_number              in number
) is
  --
  -- Declare cursors and local variables
  --
  --
  l_proc                varchar2(72) := g_package||'delete_appraisal_template';
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint.
  --
  savepoint delete_appraisal_template;
  hr_utility.set_location(l_proc, 6);
  --
  -- Call Before Process User Hook
  --
  begin
	hr_appraisal_templates_bk3.delete_appraisal_template_b
		(
		p_appraisal_template_id    =>  p_appraisal_template_id,
		p_object_version_number    =>  p_object_version_number
		);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'delete_appraisal_template',
				 p_hook_type	=> 'BP'
				);
  end;
  --
  -- End of Before Process User hook
  --
  -- Validation in addition to Table Handlers
  --
  hr_utility.set_location(l_proc, 7);
  --
  -- Process Logic
  --
  -- now delete the appraisal template
  --
     per_apt_del.del
     (p_validate                    => FALSE
     ,p_appraisal_template_id	      => p_appraisal_template_id
     ,p_object_version_number       => p_object_version_number
     );
  --
  hr_utility.set_location(l_proc, 8);
  --
  -- Call After Process User Hook
  --
  begin
	hr_appraisal_templates_bk3.delete_appraisal_template_a	(
		p_appraisal_template_id    =>  p_appraisal_template_id,
		p_object_version_number    =>  p_object_version_number  );
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'delete_appraisal_template',
				 p_hook_type	=> 'AP'
				);
  end;
  --
  -- End of After Process User hook
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 11);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_appraisal_template;
    --
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632482
    --
    ROLLBACK TO delete_appraisal_template;
    raise;
    --
    -- End of fix.
    --
    hr_utility.set_location(' Leaving:'||l_proc, 12);
end delete_appraisal_template;
--
end hr_appraisal_templates_api;

/
