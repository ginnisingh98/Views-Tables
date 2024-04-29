--------------------------------------------------------
--  DDL for Package HR_APPRAISAL_TEMPLATES_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_APPRAISAL_TEMPLATES_SWI" AUTHID CURRENT_USER As
/* $Header: peaptswi.pkh 120.1.12010000.5 2010/02/09 15:01:46 psugumar ship $ */
-- ----------------------------------------------------------------------------
-- |-----------------------< create_appraisal_template >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_appraisal_templates_api.create_appraisal_template
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
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
  ,p_ma_off_template_code		      in 	 varchar2  default null
  ,p_appraisee_off_template_code  in	 varchar2  default null
  ,p_other_part_off_template_code in	 varchar2  default null
  ,p_part_app_off_template_code	  in	 varchar2  default null
  ,p_part_rev_off_template_code   in	 varchar2  default null
  ,p_object_version_number           out nocopy number
  ,p_return_status                   out nocopy varchar2
  ,p_show_participant_comments     in varchar2            default null  -- 8651478 bug fix

  ,p_show_term_employee            in varchar2            default null  -- 6181267 bug fix
  ,p_show_term_contigent           in varchar2            default null  -- 6181267 bug fix
  ,p_disp_term_emp_period_from     in     number            default null  -- 6181267 bug fix
  ,p_SHOW_FUTURE_TERM_EMPLOYEE          in varchar2            default null  -- 6181267 bug fix

  );
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_appraisal_template >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_appraisal_templates_api.delete_appraisal_template
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
-- ----------------------------------------------------------------------------
PROCEDURE delete_appraisal_template
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_appraisal_template_id        in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------< update_appraisal_template >----------------------|
-- ----------------------------------------------------------------------------
-- {Start of comments}
--
-- Description:
--  This procedure is the self-service wrapper procedure to the following
--  API: hr_appraisal_templates_api.update_appraisal_template
--
-- Pre-requisites
--  All 'IN' parameters to this procedure have been appropriately derived.
--
-- Post Success:
--  p_return_status will return value indicating success.
--
-- Post Failure:
--  p_return_status will return value indication failure.
--
-- Access Status:
--  Internal Development use only.
--
-- {End of comments}
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
  ,p_ma_off_template_code		  in 	 varchar2  default hr_api.g_varchar2
  ,p_appraisee_off_template_code  in	 varchar2  default hr_api.g_varchar2
  ,p_other_part_off_template_code in	 varchar2  default hr_api.g_varchar2
  ,p_part_app_off_template_code	  in	 varchar2  default hr_api.g_varchar2
  ,p_part_rev_off_template_code   in	 varchar2  default hr_api.g_varchar2
  ,p_return_status                   out nocopy varchar2
 ,p_show_participant_comments     in varchar2         default hr_api.g_varchar2  -- 8651478 bug fix
  ,p_show_term_employee            in varchar2            default hr_api.g_varchar2  -- 6181267 bug fix
  ,p_show_term_contigent           in varchar2            default hr_api.g_varchar2  -- 6181267 bug fix
  ,p_disp_term_emp_period_from     in     number            default hr_api.g_number  -- 6181267 bug fix
  ,p_SHOW_FUTURE_TERM_EMPLOYEE          in varchar2            default hr_api.g_varchar2  -- 6181267 bug fix
  );
 end hr_appraisal_templates_swi;

/
