--------------------------------------------------------
--  DDL for Package HR_APPRAISALS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_APPRAISALS_API" AUTHID CURRENT_USER as
/* $Header: peaprapi.pkh 120.5.12010000.4 2009/08/12 14:17:07 rvagvala ship $*/
/*#
 * This package contains Appraisals APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Appraisal
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_appraisal >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 *  This API creates an appraisal for a person. An appraisal holds the
 *  evaluation details of a person by others for a performance review and
 *  can include objective setting etc.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 *  A valid appraisal template must exist. Person records for whom the
 *  appraisal is being performed and the person who is performing this
 *  appraisal must exist.
 *
 * <p><b>Post Success</b><br>
 * Appraisal is created.
 *
 * <p><b>Post Failure</b><br>
 * Appraisal is not created and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_business_group_id Business group to which the appraisal belongs.
 * @param p_appraisal_template_id Appraisal template to be used for this
 * appraisal.
 * @param p_appraisee_person_id Person on whom the appraisal is being
 * performed.
 * @param p_appraiser_person_id Person who is performing the appraisal.
 * @param p_appraisal_date {@rep:casecolumn PER_APPRAISALS.APPRAISAL_DATE}
 * @param p_appraisal_period_start_date {@rep:casecolumn
 * PER_APPRAISALS.APPRAISAL_PERIOD_START_DATE}
 * @param p_appraisal_period_end_date {@rep:casecolumn
 * PER_APPRAISALS.APPRAISAL_PERIOD_END_DATE}
 * @param p_type Type of appraisal used. Valid values are defined by the
 * APPRAISAL_TYPE lookup type.
 * @param p_next_appraisal_date Proposed date when the next appraisal will be
 * performed.
 * @param p_status Status of the appraisal within approval process. Valid
 * values are defined by the APPRAISAL_ASSESSMENT_STATUS lookup type.
 * @param p_group_date The date the group was created.
 * @param p_group_initiator_id Person who created the group.
 * @param p_comments Comments text.
 * @param p_overall_performance_level_id Performance rating level of the
 * appraisee.
 * @param p_open Indicates whether the appraisal is open for modification.
 * Valid values are defined by the YES_NO lookup type.
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
 * @param p_system_type Appraisal system type. Indicates the type of person
 * filling out the appraisal, e.g., manager, peer feedback etc.. Valid values
 * are defined by the APPRAISAL_SYSTEM_TYPE lookup type
 * @param p_system_params Different attributes can be put together into this single
 * parameter. This parameter holds data for many attributes together in a form of
 * free text. Attribute name and values are separated by an equal '=' sign. If
 * multiple attributes are used, then these are separated by an ampersand '&'.
 * Attributes can be of any of the following: SystemType, ItemType, ProcessName,
 * ApprovalReqd, AMETranType, AMEAppId, TransactionType, FunctionId etc. For a
 * single attribute the entry will be of the format: SystemType=EMP360. If more
 * than one attribute is passed then the entry will be of the format:
 * SystemType=EMP360amp;ItemType=HRSSAamp;ProcessName=HR_APPRAISAL_DETAILS_JSP_PRC
 * @param p_appraisee_access Determines the information to which the appraisee
 * has access.
 * @param p_main_appraiser_id Person who is the main appraiser and gives the
 * final ratings for the appraisal
 * @param p_assignment_id Identifies the assignment for which this appraisal is
 * performed.
 * @param p_assignment_start_date Start date of the assignment.
 * @param p_asg_business_group_id Business group of the assignment considered
 * for the appraisal
 * @param p_assignment_organization_id Organization of the assignment.
 * @param p_assignment_job_id Job for this assignment.
 * @param p_assignment_position_id Position of this assignment.
 * @param p_assignment_grade_id Grade of this assignment.
 * @param p_appraisal_id If p_validate is false, uniquely identifies the
 * appraisal created. If p_validate is true, set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created appraisal. If p_validate is true, then the
 * value will be null.
 * @param p_appraisal_system_status Current system status of the appraisal
 * @param p_potential_readiness_level Readiness level. Valid values are defined
 * in READINESS_LEVEL lookup type.
 * @param p_potential_short_term_workopp Short term work opportunity identified
 * for the employee during final ratings. (eg. If the employee is 'Application
 * Developer' now, then 'Sr. Developer' is the short term opportunity, where as
 * 'Product Development Manager' can be regarded as long term opportunity.)
 * @param p_potential_long_term_workopp Long term work opportunities identified
 * for the employee. (eg. Development Manager/Product Director etc.) given
 * during final ratings.
 * @param p_potential_details Details identified by the appraiser about the
 * potential of the employee during the final appraisal ratings.
 * @param p_event_id Event recorded for this appraisal
 * @param p_show_competency_ratings Flag to indicate if appraisee can view main appraiser competency ratings.
 * @param p_show_objective_ratings Flag to indicate if appraisee can view main appraiser objective ratings.
 * @param p_show_questionnaire_info Flag to indicate if appraisee can view main appraiser answered questionnaire.
 * @param p_show_participant_details Flag to indicate if appraisee can view participants details.
 * @param p_show_participant_ratings Flag to indicate if appraisee can view participants ratings.
 * @param p_show_participant_names Flag to indicate if appraisee can view participants names.
 * @param p_show_overall_ratings Flag to indicate if appraisee can view main appraiser overall ratings.
 * @param p_show_overall_comments Flag to indicate if appraisee can view main appraiser overall comments.
 * @param p_update_appraisal Flag to indicate if appraisee can update appraisal.
 * @param p_provide_overall_feedback Flag to indicate if appraisee can provide overall feedback on appraisal.
 * @param p_appraisee_comments Stores appraisee overall feedback on appraisal.
 * @param p_plan_id If not null stores the performance management plan identifier.
 * @param p_offline_status  Indicates the offline status of the appraisal document.
 * Valid values are defined by the APPRAISAL_OFFLINE_STATUS lookup type.
 * @rep:displayname Create Appraisal
 * @rep:category BUSINESS_ENTITY PER_APPRAISAL
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_appraisal
 (p_validate                     in     boolean  	default false,
  p_effective_date               in     date,
  p_business_group_id            in 	number,
  p_appraisal_template_id        in   	number,
  p_appraisee_person_id          in 	number,
  p_appraiser_person_id          in  	number,
  p_appraisal_date               in  	date		 default null,
  p_appraisal_period_start_date  in  	date,
  p_appraisal_period_end_date    in  	date ,
  p_type                         in    	varchar2	 default null,
  p_next_appraisal_date          in     date		 default null,
  p_status                       in    	varchar2 	 default null,
  p_group_date			 in     date             default null,
  p_group_initiator_id	  	 in     number           default null,
  p_comments                     in     varchar2	 default null,
  p_overall_performance_level_id in     number 		 default null,
  p_open	 	         in 	varchar2         default 'Y',
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
  p_attribute20                  in 	varchar2         default null,
  p_system_type                  in     varchar2         default null,
  p_system_params                in     varchar2         default null,
  p_appraisee_access             in     varchar2 	 default null,
  p_main_appraiser_id            in     number 	 	 default null,
  p_assignment_id                in     number 		 default null,
  p_assignment_start_date        in     date  		 default null,
  p_asg_business_group_id        in     number		 default null,
  p_assignment_organization_id   in     number		 default null,
  p_assignment_job_id            in     number		 default null,
  p_assignment_position_id       in     number		 default null,
  p_assignment_grade_id          in     number		 default null,
  p_appraisal_id                 out nocopy    number,
  p_object_version_number        out nocopy 	number,
  p_appraisal_system_status      in     varchar2         default null,
  p_potential_readiness_level    in varchar2         default null,
  p_potential_short_term_workopp in varchar2         default null,
  p_potential_long_term_workopp  in varchar2         default null,
  p_potential_details            in varchar2         default null,
  p_event_id                     in number           default null,
  p_show_competency_ratings      in varchar2         default null,
  p_show_objective_ratings       in varchar2         default null,
  p_show_questionnaire_info      in varchar2         default null,
  p_show_participant_details     in varchar2         default null,
  p_show_participant_ratings     in varchar2         default null,
  p_show_participant_names       in varchar2         default null,
  p_show_overall_ratings         in varchar2         default null,
  p_show_overall_comments        in varchar2         default null,
  p_update_appraisal             in varchar2         default null,
  p_provide_overall_feedback     in varchar2         default null,
  p_appraisee_comments           in varchar2         default null,
  p_plan_id                      in number           default null,
  p_offline_status               in varchar2         default null,
p_retention_potential          in varchar2           default null,
p_show_participant_comments     in varchar2            default null  -- 8651478 bug fix
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< update_appraisal >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an existing appraisal for a person. An appraisal
 * holds the evaluation details of a person by others for a performance
 * review and can include objective setting etc.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid appraisal must exist.
 *
 * <p><b>Post Success</b><br>
 * Appraisal is updated.
 *
 * <p><b>Post Failure</b><br>
 * Appraisal remains unchanged and an error is raised.
 * @param p_validate If true, then only validation will be performed and the
 * database remains unchanged. If false, then all validation checks pass the
 * database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_appraisal_id The appraisal to be updated.
 * @param p_object_version_number Pass in the current version number of the
 * appraisal to be updated. When the API completes if p_validate is false, will
 * be set to the new version number of the updated appraisal. If p_validate is
 * true will be set to the same value which was passed in.
 * @param p_appraiser_person_id Person who is performing the appraisal.
 * @param p_appraisal_date Date when the appraisal is to take place.
 * @param p_appraisal_period_end_date End date of the appraisal period.
 * @param p_appraisal_period_start_date The start date of appraisal period.
 * @param p_type Type of appraisal used. Valid values are defined by the
 * APPRAISAL_TYPE lookup type.
 * @param p_next_appraisal_date Proposed date when the next appraisal will be
 * performed.
 * @param p_status Indicates the status of this appraisal. Valid values are
 * defined by the APPRAISAL_ASSESSMENT_STATUS lookup type. (possible values are
 * ongoing, planned, complete, incomplete, waiting on feedback)
 * @param p_comments Comments text.
 * @param p_overall_performance_level_id Performance rating level of the
 * appraisee.
 * @param p_open Whether appraisal is open for modification. Valid values are
 * defined by the YES_NO lookup type.
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
 * @param p_system_type Appraisal system type. Indicates the type of person
 * filling out the appraisal, e.g., manager, peer feedback etc.. Valid values
 * are defined by the APPRAISAL_SYSTEM_TYPE lookup type
 * @param p_system_params Different attributes can be put together into this
 * single parameter. This parameter holds data for many attributes together in
 * a form of free text. Attribute name and values are separated by an equal '=' sign.
 * If multiple attributes are used, then these are separated by an ampersand '&'.
 * Attributes can be of any of the following: SystemType, ItemType, ProcessName,
 * ApprovalReqd, AMETranType, AMEAppId, TransactionType, FunctionId etc. For a
 * single attribute the entry will be of the format: SystemType=EMP360. If
 * more than one attribute is passed then the entry will be of the format:
 * SystemType=EMP360amp;ItemType=HRSSAamp;ProcessName=HR_APPRAISAL_DETAILS_JSP_PRC
 * @param p_appraisee_access Determines the information to which the appraisee
 * has access.
 * @param p_main_appraiser_id Person who is the main appraiser and gives the
 * final ratings for the appraisal
 * @param p_assignment_id Identifies the assignment for which this appraisal is
 * performed.
 * @param p_assignment_start_date Start date of the assignment.
 * @param p_asg_business_group_id Business group of the assignment considered
 * for the appraisal
 * @param p_assignment_organization_id Organization of the assignment.
 * @param p_assignment_job_id Job for this assignment.
 * @param p_assignment_position_id Position of this assignment.
 * @param p_assignment_grade_id Grade of this assignment.
 * @param p_appraisal_system_status Current system status of the appraisal
 * @param p_potential_readiness_level Readiness level. Valid values are defined
 * in READINESS_LEVEL lookup type.
 * @param p_potential_short_term_workopp Short term work opportunity identified for
 * the employee during final ratings. (eg. If the employee is 'Application Developer'
 * now, then 'Sr. Developer' is the short term opportunity, where as 'Product
 * Development Manager' can be regarded as long term opportunity.)
 * @param p_potential_long_term_workopp Long term work opportunities identified for
 * the employee. (eg. Development Manager/Product Director etc.) given during final
 * ratings.
 * @param p_potential_details Details identified by the appraiser about the
 * potential of the employee during the final appraisal ratings.
 * @param p_event_id Event recorded for this appraisal
 * @param p_show_competency_ratings Flag to indicate if appraisee can view main appraiser competency ratings.
 * @param p_show_objective_ratings Flag to indicate if appraisee can view main appraiser objective ratings.
 * @param p_show_questionnaire_info Flag to indicate if appraisee can view main appraiser answered
 * questionnaire.
 * @param p_show_participant_details Flag to indicate if appraisee can view participants details.
 * @param p_show_participant_ratings Flag to indicate if appraisee can view participants ratings.
 * @param p_show_participant_names Flag to indicate if appraisee can view participants names.
 * @param p_show_overall_ratings Flag to indicate if appraisee can view main appraiser overall ratings.
 * @param p_show_overall_comments Flag to indicate if appraisee can view main appraiser overall comments.
 * @param p_update_appraisal Flag to indicate if appraisee can update appraisal.
 * @param p_provide_overall_feedback Flag to indicate if appraisee can provide overall feedback on appraisal.
 * @param p_appraisee_comments Stores appraisee overall feedback on appraisal.
 * @param p_plan_id If not null stores the performance management plan identifier.
 * @param p_offline_status  Indicates the offline status of the appraisal document.
 * Valid values are defined by the APPRAISAL_OFFLINE_STATUS lookup type.
 * @rep:displayname Update Appraisal
 * @rep:category BUSINESS_ENTITY PER_APPRAISAL
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_appraisal
 (p_validate                     in boolean         default false,
  p_effective_date               in date,
  p_appraisal_id                 in number,
  p_object_version_number        in out nocopy number,
  p_appraiser_person_id          in number,
  p_appraisal_date    		 in date             default hr_api.g_date,
  p_appraisal_period_end_date    in date             default hr_api.g_date,
  p_appraisal_period_start_date  in date             default hr_api.g_date,
  p_type                         in varchar2         default hr_api.g_varchar2,
  p_next_appraisal_date          in date             default hr_api.g_date,
  p_status                       in varchar2         default hr_api.g_varchar2,
  p_comments                     in varchar2         default hr_api.g_varchar2,
  p_overall_performance_level_id in number           default hr_api.g_number,
  p_open	                 in varchar2         default hr_api.g_varchar2,
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
  p_system_type                  in varchar2         default hr_api.g_varchar2,
  p_system_params                in varchar2         default hr_api.g_varchar2,
  p_appraisee_access             in varchar2         default hr_api.g_varchar2,
  p_main_appraiser_id            in number 	     default hr_api.g_number,
  p_assignment_id                in number 	     default hr_api.g_number,
  p_assignment_start_date        in date  	     default hr_api.g_date,
  p_asg_business_group_id        in number	     default hr_api.g_number,
  p_assignment_organization_id   in number	     default hr_api.g_number,
  p_assignment_job_id            in number	     default hr_api.g_number,
  p_assignment_position_id       in number	     default hr_api.g_number,
  p_assignment_grade_id          in number	     default hr_api.g_number,
  p_appraisal_system_status      in varchar2         default hr_api.g_varchar2,
  p_potential_readiness_level    in varchar2         default hr_api.g_varchar2,
  p_potential_short_term_workopp in varchar2         default hr_api.g_varchar2,
  p_potential_long_term_workopp  in varchar2         default hr_api.g_varchar2,
  p_potential_details            in varchar2         default hr_api.g_varchar2,
  p_event_id                     in number           default hr_api.g_number,
  p_show_competency_ratings      in varchar2         default hr_api.g_varchar2,
  p_show_objective_ratings       in varchar2         default hr_api.g_varchar2,
  p_show_questionnaire_info      in varchar2         default hr_api.g_varchar2,
  p_show_participant_details     in varchar2         default hr_api.g_varchar2,
  p_show_participant_ratings     in varchar2         default hr_api.g_varchar2,
  p_show_participant_names       in varchar2         default hr_api.g_varchar2,
  p_show_overall_ratings         in varchar2         default hr_api.g_varchar2,
  p_show_overall_comments        in varchar2         default hr_api.g_varchar2,
  p_update_appraisal             in varchar2         default hr_api.g_varchar2,
  p_provide_overall_feedback     in varchar2         default hr_api.g_varchar2,
  p_appraisee_comments           in varchar2         default hr_api.g_varchar2,
  p_plan_id                      in number           default hr_api.g_number,
  p_offline_status               in varchar2         default hr_api.g_varchar2,
p_retention_potential                in varchar2         default hr_api.g_varchar2,
p_show_participant_comments     in varchar2         default hr_api.g_varchar2  -- 8651478 bug fix
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< delete_appraisal >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes an existing appraisal for a person. An appraisal
 * holds the evaluation details of a person by others for a performance
 * review and can include objective setting etc.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid appraisal must already exist.
 *
 * <p><b>Post Success</b><br>
 * Appraisal is deleted.
 *
 * <p><b>Post Failure</b><br>
 * Appraisal is not deleted and an error is raised.
 * @param p_validate If true, then only validation will be performed and the
 * database remains unchanged. If false, then all validation checks pass the
 * database will be modified.
 * @param p_appraisal_id Appraisal to be deleted. If p_validate is false,
 * uniquely identifies the appraisal to be deleted. If p_validate is true, set
 * to null.
 * @param p_object_version_number Current version number of the appraisal to be
 * deleted.
 * @rep:displayname Delete Appraisal
 * @rep:category BUSINESS_ENTITY PER_APPRAISAL
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_appraisal
(p_validate                           in boolean default false,
 p_appraisal_id                       in number,
 p_object_version_number              in number
);
--
end hr_appraisals_api;

/
