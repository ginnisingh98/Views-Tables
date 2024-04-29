--------------------------------------------------------
--  DDL for Package HR_APPRAISAL_TEMPLATES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_APPRAISAL_TEMPLATES_API" AUTHID CURRENT_USER as
/* $Header: peaptapi.pkh 120.4.12010000.6 2010/02/09 15:05:01 psugumar ship $*/
/*#
 * This API contains Appraisal Template APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Appraisal Template
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_appraisal_template >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new appraisal template.
 *
 * An appraisal template is the header or group for a number of appraisal
 * questions. Each appraisal template defines a type of appraisal.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid assessment type and rating scale must exist for the business group
 * of this template. A valid questionnaire template (proposal template) must
 * also exist.
 *
 * <p><b>Post Success</b><br>
 * An appraisal template is created.
 *
 * <p><b>Post Failure</b><br>
 * The appraisal template is not created and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_business_group_id Business group for which the appraisal template
 * is created.
 * @param p_name Unique name or title of the template.
 * @param p_description A description of the appraisal template
 * @param p_instructions General Instructions on how to complete the appraisal
 * @param p_date_from Date from which the template is valid
 * @param p_date_to The date until which the appraisal template is valid.
 * @param p_assessment_type_id The assessment type to be used in this template
 * @param p_rating_scale_id Default rating scale to be used for this appraisal.
 * @param p_questionnaire_template_id Appraisee Questionnaire template (proposal
 * template) for this appraisal template
 * @param p_attribute_category This context value determines which flexfield
 * structure to use with the descriptive flexfield segments.
 * @param p_attribute1 Descriptive flexfield segment.
 * @param p_attribute2 Descriptive flexfield segment.
 * @param p_attribute3 Descriptive flexfield segment.
 * @param p_attribute4 Descriptive flexfield segment.
 * @param p_attribute5 Descriptive flexfield segment.
 * @param p_attribute6 Descriptive flexfield segment.
 * @param p_attribute7 Descriptive flexfield segment.
 * @param p_attribute8 Descriptive flexfield segment.
 * @param p_attribute9 Descriptive flexfield segment.
 * @param p_attribute10 Descriptive flexfield segment.
 * @param p_attribute11 Descriptive flexfield segment.
 * @param p_attribute12 Descriptive flexfield segment.
 * @param p_attribute13 Descriptive flexfield segment.
 * @param p_attribute14 Descriptive flexfield segment.
 * @param p_attribute15 Descriptive flexfield segment.
 * @param p_attribute16 Descriptive flexfield segment.
 * @param p_attribute17 Descriptive flexfield segment.
 * @param p_attribute18 Descriptive flexfield segment.
 * @param p_attribute19 Descriptive flexfield segment.
 * @param p_attribute20 Descriptive flexfield segment.
 * @param p_objective_asmnt_type_id The objective assessment type to be used in this template
 * @param p_ma_quest_template_id   MA Questionnaire template (proposal
 * template) for this appraisal template
 * @param p_link_appr_to_learning_path indicates if appraisal would be linked to learning path
 * @param p_final_score_formula_id store fast formula id for calculating appraisal final score
 * @param p_update_personal_comp_profile indicates whether appraisal competencies should be updating
 *  personal competencies or not
 * @param p_comp_profile_source_type Value which will be passed to column source_of_proficiency_level
 * @param p_show_competency_ratings indicates if appraisee can see competency ratings or not
 * @param p_show_objective_ratings  indicates if appraisee can see objective ratings or not
 * @param p_show_overall_ratings   indicates if appraisee can see overall ratings or not
 * @param p_show_overall_comments  indicates if appraisee can see objective comments or not
 * @param p_provide_overall_feedback indicates if appraisee can provide overall feedback or not
 * @param p_show_participant_details indicates if appraisee can see participant details on
 *  appraisal completion
 * @param p_allow_add_participant  indicates if appraisee can add participant or not
 * @param p_show_additional_details  indicates if appraisee can see additional details on
 *  appraisal completion
 * @param p_show_participant_names indicates if appraisee can see participant names on
 *  appraisal completion
 * @param p_show_participant_ratings indicates if appraisee can see participant ratings on
 *  appraisal completion
 * @param p_available_flag  indicates if template is Unpublished or published.Values are
 *  validated against lookup TEMPLATE_AVAILABILITY_FLAG
 * @param p_show_questionnaire_info  indicates if appraisee can see ma completed questionnaire on
 *  appraisal completion
 * @param p_ma_off_template_code  Excel template code (registered in XML Publisher Templates)
 * for Main Appraiser.
 * @param p_appraisee_off_template_code  Excel template code (registered in XML Publisher
 * Templates) for appraisee.
 * @param p_other_part_off_template_code  Excel template code (registered in XML Publisher
 * Templates) for Other Participants.
 * @param p_part_app_off_template_code  Excel template code (registered in XML Publisher
 * Templates) for participants of type appraiser.
 * @param p_part_rev_off_template_code  Excel template code (registered in XML Publisher
 * Templates) for participants of type reviewer.
 * @param p_appraisal_template_id If p_validate is false, then this uniquely
 * identifies the appraisal template created. If p_validate is true, then set to
 * null.
 * @param p_object_version_number If p_validate is false, then set to
 * the version number of the created appraisal period. If p_validate is true,
 * then the value will be null.
 * @rep:displayname Create Appraisal Template
 * @rep:category BUSINESS_ENTITY PER_APPRAISAL
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_appraisal_template
 (p_validate                     in     boolean  	 default false,
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
  ,p_ma_off_template_code		        in 	   varchar2	default null
  ,p_appraisee_off_template_code    in	   varchar2	default null
  ,p_other_part_off_template_code   in	   varchar2	default null
  ,p_part_app_off_template_code	    in     varchar2 default null
  ,p_part_rev_off_template_code 	  in	   varchar2	default null,
  p_appraisal_template_id        out nocopy    number,
  p_object_version_number        out nocopy 	number,
 p_show_participant_comments     in varchar2            default null  -- 8651478 bug fix
   ,p_show_term_employee            in varchar2            default null  -- 6181267 bug fix
  ,p_show_term_contigent           in varchar2            default null  -- 6181267 bug fix
  ,p_disp_term_emp_period_from     in     number            default null  -- 6181267 bug fix
  ,p_SHOW_FUTURE_TERM_EMPLOYEE          in varchar2            default null  -- 6181267 bug fix
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_appraisal_template >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates appraisal template.
 *
 * An appraisal template is the header or group for a number of appraisal
 * questions. Each appraisal template defines a type of appraisal.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid existing appraisal template must be passed to the API.
 *
 * <p><b>Post Success</b><br>
 * Appraisal template is updated.
 *
 * <p><b>Post Failure</b><br>
 * Appraisal template remains unchanged and an error is raised.
 * @param p_validate If true, then only validation will be performed and the
 * database remains unchanged. If false, then all validation checks pass the
 * database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_appraisal_template_id Identifier of the appraisal template to be
 * updated.
 * @param p_object_version_number Pass in the current version number of the
 * appraisal template to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated appraisal
 * template. If p_validate is true will be set to the same value which was
 * passed in.
 * @param p_name Unique name or title of the template.
 * @param p_description A description of the appraisal template
 * @param p_instructions General Instructions on how to complete the appraisal
 * @param p_date_from Date from which the template is valid
 * @param p_date_to The date until which the appraisal template is valid.
 * @param p_assessment_type_id The assessment type to be used in this template
 * @param p_rating_scale_id Default rating scale to be used for this appraisal.
 * @param p_questionnaire_template_id Questionnaire template (proposal
 * template) for this appraisal template
 * @param p_attribute_category This context value determines which flexfield
 * structure to use with the descriptive flexfield segments.
 * @param p_attribute1 Descriptive flexfield segment.
 * @param p_attribute2 Descriptive flexfield segment.
 * @param p_attribute3 Descriptive flexfield segment.
 * @param p_attribute4 Descriptive flexfield segment.
 * @param p_attribute5 Descriptive flexfield segment.
 * @param p_attribute6 Descriptive flexfield segment.
 * @param p_attribute7 Descriptive flexfield segment.
 * @param p_attribute8 Descriptive flexfield segment.
 * @param p_attribute9 Descriptive flexfield segment.
 * @param p_attribute10 Descriptive flexfield segment.
 * @param p_attribute11 Descriptive flexfield segment.
 * @param p_attribute12 Descriptive flexfield segment.
 * @param p_attribute13 Descriptive flexfield segment.
 * @param p_attribute14 Descriptive flexfield segment.
 * @param p_attribute15 Descriptive flexfield segment.
 * @param p_attribute16 Descriptive flexfield segment.
 * @param p_attribute17 Descriptive flexfield segment.
 * @param p_attribute18 Descriptive flexfield segment.
 * @param p_attribute19 Descriptive flexfield segment.
 * @param p_attribute20 Descriptive flexfield segment.
 * @param p_objective_asmnt_type_id The objective assessment type to be used in this template
 * @param p_ma_quest_template_id   MA Questionnaire template (proposal
 * template) for this appraisal template
 * @param p_link_appr_to_learning_path indicates if appraisal would be linked to learning path
 * @param p_final_score_formula_id store fast formula id for calculating appraisal final score
 * @param p_update_personal_comp_profile indicates whether appraisal competencies should be updating
 *  personal competencies or not
 * @param p_comp_profile_source_type Value which will be passed to column source_of_proficiency_level
 * @param p_show_competency_ratings indicates if appraisee can see competency ratings or not
 * @param p_show_objective_ratings  indicates if appraisee can see objective ratings or not
 * @param p_show_overall_ratings   indicates if appraisee can see overall ratings or not
 * @param p_show_overall_comments  indicates if appraisee can see objective comments or not
 * @param p_provide_overall_feedback indicates if appraisee can provide overall feedback or not
 * @param p_show_participant_details indicates if appraisee can see participant details on
 *  appraisal completion
 * @param p_allow_add_participant  indicates if appraisee can add participant or not
 * @param p_show_additional_details  indicates if appraisee can see additional details on
 *  appraisal completion
 * @param p_show_participant_names indicates if appraisee can see participant names on
 *  appraisal completion
 * @param p_show_participant_ratings indicates if appraisee can see participant ratings on
 *  appraisal completion
 * @param p_available_flag  indicates if template is Unpublished or published.Values are
 *  validated against lookup TEMPLATE_AVAILABILITY_FLAG
 * @param p_show_questionnaire_info  indicates if appraisee can see ma completed questionnaire on
 *  appraisal completion
 * @param p_ma_off_template_code  Excel template code (registered in XML Publisher Templates)
 * for Main Appraiser.
 * @param p_appraisee_off_template_code  Excel template code (registered in XML Publisher
 * Templates) for appraisee.
 * @param p_other_part_off_template_code  Excel template code (registered in XML Publisher
 * Templates) for Other Participants.
 * @param p_part_app_off_template_code  Excel template code (registered in XML Publisher
 * Templates) for participants of type appraiser.
 * @param p_part_rev_off_template_code  Excel template code (registered in XML Publisher
 * Templates) for participants of type reviewer.
 * @rep:displayname Update Appraisal Template
 * @rep:category BUSINESS_ENTITY PER_APPRAISAL
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_appraisal_template
 (p_validate                     in boolean         default false,
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
 , p_show_participant_comments     in varchar2         default hr_api.g_varchar2  -- 8651478 bug fix
   ,p_show_term_employee            in varchar2            default hr_api.g_varchar2  -- 6181267 bug fix
  ,p_show_term_contigent           in varchar2            default hr_api.g_varchar2  -- 6181267 bug fix
  ,p_disp_term_emp_period_from     in     number            default hr_api.g_number  -- 6181267 bug fix
  ,p_SHOW_FUTURE_TERM_EMPLOYEE          in varchar2            default hr_api.g_varchar2  -- 6181267 bug fix
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_appraisal_template >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes appraisal template.
 *
 * You can not delete an appraisal template if this template is used in any
 * appraisal.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid appraisal template must already exist and this template must not be
 * used in any appraisals.
 *
 * <p><b>Post Success</b><br>
 * Appraisal template is deleted.
 *
 * <p><b>Post Failure</b><br>
 * Appraisal template is not deleted and an error is raised.
 * @param p_validate If true, then only validation will be performed and the
 * database remains unchanged. If false, then all validation checks pass the
 * database will be modified.
 * @param p_appraisal_template_id Appraisal template to be deleted. If
 * p_validate is false, uniquely identifies the appraisal template to be
 * deleted. If p_validate is true, set to null.
 * @param p_object_version_number Current version number of the appraisal
 * template to be deleted.
 * @rep:displayname Delete Appraisal Template
 * @rep:category BUSINESS_ENTITY PER_APPRAISAL
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_appraisal_template
(p_validate                           in boolean default false,
 p_appraisal_template_id              in number,
 p_object_version_number              in number
);
--
end hr_appraisal_templates_api;

/
