--------------------------------------------------------
--  DDL for Package OTA_LEARNING_PATH_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_LEARNING_PATH_API" AUTHID CURRENT_USER as
/* $Header: otlpsapi.pkh 120.3 2005/11/07 03:26:28 rdola noship $ */
/*#
 * This package contains the Learning Path APIs.
 * @rep:scope public
 * @rep:product ota
 * @rep:displayname Learning Path
*/
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_learning_path >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a Learning Path, which is a collection of Courses
 * associated with Completion Targets.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The business group must exist.
 *
 * <p><b>Post Success</b><br>
 * The learning path will be successfully created.
 *
 * <p><b>Post Failure</b><br>
 * The learning path will not be created and an error will be raised.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_path_name The translated name associated with this learning path.
 * @param p_business_group_id The unique identifier of the business group that
 * owns the learning path.
 * @param p_duration {@rep:casecolumn OTA_LEARNING_PATHS.DURATION}.
 * @param p_duration_units The completion target units of the learning path.
 * Valid values are defined by the 'OTA_DURATION_UNITS' lookup type.
 * @param p_start_date_active The date on which learners can begin to subscribe
 * to the learning path.
 * @param p_end_date_active The date on which the learning path becomes no
 * longer available to learners.
 * @param p_description The translated description associated with this
 * learning path.
 * @param p_objectives The translated objectives associated with this learning
 * path.
 * @param p_keywords The translated keyword associated with this learning path.
 * @param p_purpose The translated purpose associated with this learning path.
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
 * @param p_learning_path_id The unique identifier for the learning path.
 * @param p_object_version_number If p_validate is false, then the number is
 * set to the version number of the created learning path. If p_validate is
 * true, then the value is null.
 * @param p_person_id Identifies the person for whom the learning path is
 * created. Applies only to personal learning paths.
 * @param p_public_flag Identifies whether the catalog learning path is public.
 * Permissible values are Y and N.
 * @param p_source_function_code Source of the learning path when created from
 * Talent Management. Valid values are defined by the
 * 'OTA_PLAN_COMPONENT_SOURCE' lookup.
 * @param p_contact_id Identifies the external contact for whom you create the
 * learning path record. Applies only to personal learning paths.
 * @param p_source_id Learning path source identifier: Appraisal ID,
 * for example, if the learning path is created from Appraisals.
 * @param p_assignment_id Identifies the assignment for which you create the
 * learning path record.
 * @param p_display_to_learner_flag Decides whether the learning path should be
 * visible to the learner. Applies only to personal learning paths.
 * @param p_notify_days_before_target Days before which a reminder notification
 * is sent to the learners subscribed to the learning path. Applies only to
 * catalog learning paths.
 * @param p_path_source_code Source of creation of the learning path. Valid
 * values are CATALOG, EMPLOYEE, MANAGER, TALENT_MGMT.
 * @param p_competency_update_level Valid values are defined by the
 * 'OTA_COMPETENCY_UPDATE_LEVEL' lookup type. Specifies the mode of competency
 * update. This value overrides the value set at the workflow level.
 * @rep:displayname Create Learning Path
 * @rep:category BUSINESS_ENTITY OTA_LEARNING_PATH
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_learning_path
  (
  p_effective_date               in date,
  p_validate                     in boolean   default false ,
  p_path_name                    in varchar2,
  p_business_group_id            in number,
  p_duration                     in number           default null,
  p_duration_units               in varchar2         default null,
  p_start_date_active            in date             default null,
  p_end_date_active              in date             default null,
  p_description                  in varchar2         default null,
  p_objectives                   in varchar2         default null,
  p_keywords                     in varchar2         default null,
  p_purpose                      in varchar2         default null,
  p_attribute_category           in varchar2         default null,
  p_attribute1                   in varchar2         default null,
  p_attribute2                   in varchar2         default null,
  p_attribute3                   in varchar2         default null,
  p_attribute4                   in varchar2         default null,
  p_attribute5                   in varchar2         default null,
  p_attribute6                   in varchar2         default null,
  p_attribute7                   in varchar2         default null,
  p_attribute8                   in varchar2         default null,
  p_attribute9                   in varchar2         default null,
  p_attribute10                  in varchar2         default null,
  p_attribute11                  in varchar2         default null,
  p_attribute12                  in varchar2         default null,
  p_attribute13                  in varchar2         default null,
  p_attribute14                  in varchar2         default null,
  p_attribute15                  in varchar2         default null,
  p_attribute16                  in varchar2         default null,
  p_attribute17                  in varchar2         default null,
  p_attribute18                  in varchar2         default null,
  p_attribute19                  in varchar2         default null,
  p_attribute20                  in varchar2         default null,
  p_path_source_code             in varchar2         default null,
  p_source_function_code         in varchar2         default null,
  p_assignment_id                in number           default null,
  p_source_id                    in number           default null,
  p_notify_days_before_target    in number           default null,
  p_person_id                    in number           default null,
  p_contact_id                   in number           default null,
  p_display_to_learner_flag      in varchar2         default null,
  p_public_flag                  in varchar2         default 'Y',
  p_competency_update_level        in     varchar2  default null ,
  p_learning_path_id             out nocopy number,
  p_object_version_number        out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_learning_path >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a Learning Path.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The learning path record with the given object version number should exist.
 *
 * <p><b>Post Success</b><br>
 * The learning path will be successfully updated.
 *
 * <p><b>Post Failure</b><br>
 * The learning path will not be updated and an error will be raised.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_learning_path_id The unique identifer for the learning path.
 * @param p_object_version_number Pass in the current version number of the
 * learning path to be updated. When the API completes if p_validate is false,
 * the number is set to the new version number of the updated learning path. If
 * p_validate is true the number remains unchanged.
 * @param p_path_name The translated name associated with this learning path.
 * @param p_description The translated description associated with this
 * learning path.
 * @param p_objectives The translated objectives associated with this learning
 * path.
 * @param p_keywords The translated keyword associated with this learning path.
 * @param p_purpose The translated purpose associated with this learning path.
 * @param p_duration {@rep:casecolumn OTA_LEARNING_PATHS.DURATION}.
 * @param p_duration_units The completion target units of the learning path.
 * Valid values are defined by the 'OTA_DURATION_UNITS' lookup type.
 * @param p_start_date_active The date on which learners can begin to subscribe
 * to the learning path.
 * @param p_end_date_active The date on which the learning path becomes no
 * longer available to learners.
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
 * @param p_business_group_id The unique identifier of the business group that
 * owns this learning path.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_assignment_id Identifies the assignment for which you create the
 * learning path record.
 * @param p_source_id Learning path source identifier: Appraisal ID, for
 * example, if the learning path is created from Appraisals.
 * @param p_public_flag Identifies whether the catalog learning path is public.
 * Permissible values are Y and N.
 * @param p_path_source_code Source of creation of the learning path. Valid
 * values are CATALOG, EMPLOYEE, MANAGER, TALENT_MGMT.
 * @param p_contact_id Identifies the external contact for whom you create the
 * learning path record. Applies only to personal learning paths.
 * @param p_display_to_learner_flag Decides whether the learning path should be
 * visible to the learner. Applies only to personal learning paths.
 * @param p_source_function_code Source of the learning path when created from
 * Talent Management. Valid values are defined by the
 * 'OTA_PLAN_COMPONENT_SOURCE' lookup.
 * @param p_notify_days_before_target Days before which a reminder notification
 * is sent to the learners subscribed to the learning path. Applies only to
 * catalog learning paths.
 * @param p_person_id Identifies the person for whom the learning path is
 * created. Applies only to personal learning paths.
 * @param p_competency_update_level Valid values are defined by the
 * 'OTA_COMPETENCY_UPDATE_LEVEL' lookup type. Specifies the mode of competency
 * update. This value overrides the value set at the workflow level.
 * @rep:displayname Update Learning Path
 * @rep:category BUSINESS_ENTITY OTA_LEARNING_PATH
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure Update_learning_path
  (
  p_effective_date               in date,
  p_learning_path_id             in number,
  p_object_version_number        in out nocopy number,
  p_path_name                    in varchar2         default hr_api.g_varchar2,
  p_description                  in varchar2         default hr_api.g_varchar2,
  p_objectives                   in varchar2         default hr_api.g_varchar2,
  p_keywords                     in varchar2         default hr_api.g_varchar2,
  p_purpose                      in varchar2         default hr_api.g_varchar2,
  p_duration                     in number           default hr_api.g_number,
  p_duration_units               in varchar2         default hr_api.g_varchar2,
  p_start_date_active            in date             default hr_api.g_date,
  p_end_date_active              in date             default hr_api.g_date,
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
  p_business_group_id            in number           default hr_api.g_number,
  p_path_source_code             in varchar2         default hr_api.g_varchar2,
  p_source_function_code         in varchar2         default hr_api.g_varchar2,
  p_assignment_id                in number           default hr_api.g_number,
  p_source_id                    in number           default hr_api.g_number,
  p_notify_days_before_target    in number           default hr_api.g_number,
  p_person_id                    in number           default hr_api.g_number,
  p_contact_id                   in number           default hr_api.g_number,
  p_display_to_learner_flag      in varchar2         default hr_api.g_varchar2,
  p_public_flag                  in varchar2         default hr_api.g_varchar2,
  p_validate                     in boolean          default false
  ,p_competency_update_level        in     varchar2  default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_learning_path >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes the Learning Path.
 *
 * A Learning Path cannot be deleted if any learners have subscribed to it.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The learning path should not have any subscribers.
 *
 * <p><b>Post Success</b><br>
 * The learning path will be deleted from the database.
 *
 * <p><b>Post Failure</b><br>
 * The learning path will not be deleted and an error will be raised.
 * @param p_learning_path_id The unique identifier for the learning path.
 * @param p_object_version_number Current version number of the learning path
 * to be deleted.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @rep:displayname Delete Learning Path
 * @rep:category BUSINESS_ENTITY OTA_LEARNING_PATH
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_learning_path
  (p_learning_path_id           in     number
  ,p_object_version_number         in     number
  ,p_validate                      in     boolean  default false
  );
end ota_learning_path_api;

 

/
