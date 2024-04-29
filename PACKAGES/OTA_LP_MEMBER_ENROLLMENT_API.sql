--------------------------------------------------------
--  DDL for Package OTA_LP_MEMBER_ENROLLMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_LP_MEMBER_ENROLLMENT_API" AUTHID CURRENT_USER as
/* $Header: otlmeapi.pkh 120.1.12010000.3 2009/05/27 13:15:43 pekasi ship $ */
/*#
 * This package contains learning path component enrollment APIs.
 * @rep:scope public
 * @rep:product OTA
 * @rep:displayname Learning Path Component Enrollment
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_lp_member_enrollment >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a learning path component enrollment record.
 *
 * This business process allows the user to create a learning path component
 * enrollment record within the context of a learning path.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * Learning Path, Learning Path Section, Learning Path Component and Learning
 * Path Enrollment records must exist.
 *
 * <p><b>Post Success</b><br>
 * The learning path component enrollment record is successfully created.
 *
 * <p><b>Post Failure</b><br>
 * The learning path component enrollment record is not created and an error is
 * raised.
 *
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_lp_enrollment_id The unique identifier of the learning path
 * enrollment under which the component enrollment record is being created.
 * @param p_learning_path_section_id The unique identifier of the learning path
 * section to which the learning path component belongs.
 * @param p_learning_path_member_id The unique identifer of the learning path
 * component to which the enrollment is being made.
 * @param p_member_status_code Status of the learning path component
 * enrollment. Valid values are defined by 'OTA_LP_MEMBER_STATUS' lookup type.
 * @param p_completion_target_date Date before which the learner has to
 * complete the learning path component.
 * @param p_completion_date Date on which the learner has completed the
 * learning path component.
 * @param p_business_group_id The unique identifer of the business group to
 * which the learning path belongs.
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
 * @param p_attribute21 Descriptive flexfield segment.
 * @param p_attribute22 Descriptive flexfield segment.
 * @param p_attribute23 Descriptive flexfield segment.
 * @param p_attribute24 Descriptive flexfield segment.
 * @param p_attribute25 Descriptive flexfield segment.
 * @param p_attribute26 Descriptive flexfield segment.
 * @param p_attribute27 Descriptive flexfield segment.
 * @param p_attribute28 Descriptive flexfield segment.
 * @param p_attribute29 Descriptive flexfield segment.
 * @param p_attribute30 Descriptive flexfield segment.
 * @param p_creator_person_id Unique identifier of the person who created the
 * learning path component.
 * @param p_event_id to identify whether this class is enrolled through
 * learning path or not.
 * @param p_lp_member_enrollment_id The unique identifier of the learning path
 * component enrollment record which is being updated.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created learning path component enrollment. If
 * p_validate is true, then the value will be null.
 * @rep:displayname Create Learning Path Component Enrollment
 * @rep:category BUSINESS_ENTITY OTA_LP_SUBSCRIPTION
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_lp_member_enrollment
  (
  p_effective_date               in date,
  p_validate                     in boolean          default false ,
  p_lp_enrollment_id             in number,
  p_learning_path_section_id     in number           default null,
  p_learning_path_member_id      in number           default null,
  p_member_status_code                in varchar2,
  p_completion_target_date       in date             default null,
  p_completion_date               in date             default null,
  p_business_group_id            in number,
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
  p_attribute21                  in varchar2         default null,
  p_attribute22                  in varchar2         default null,
  p_attribute23                  in varchar2         default null,
  p_attribute24                  in varchar2         default null,
  p_attribute25                  in varchar2         default null,
  p_attribute26                  in varchar2         default null,
  p_attribute27                  in varchar2         default null,
  p_attribute28                  in varchar2         default null,
  p_attribute29                  in varchar2         default null,
  p_attribute30                  in varchar2         default null,
  p_creator_person_id            in number           default null,
  p_event_id                     in number           default null,
  p_lp_member_enrollment_id      out nocopy number,
  p_object_version_number        out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_lp_member_enrollment >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the learning path component enrollment record.
 *
 * This business process allows the user to update a learning path component
 * enrollment record within the context of a learning path.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The learning path component enrollment record with the given object version
 * number must exist.
 *
 * <p><b>Post Success</b><br>
 * The learning path component enrollment record is successfully updated.
 *
 * <p><b>Post Failure</b><br>
 * The learning path component enrollment record is not updated and an error is
 * raised.
 *
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_lp_member_enrollment_id The unique identifier of the learning path
 * component enrollment record which is being updated.
 * @param p_object_version_number Pass in the current version number of the
 * learning path component enrollment to be updated. When the API completes if
 * p_validate is false, will be set to the new version number of the updated
 * learning path component enrollment. If p_validate is true will be set to the
 * same value which was passed in.
 * @param p_lp_enrollment_id The unique identifier of the learning path
 * component enrollment record which is being updated.
 * @param p_learning_path_section_id The unique identifier of the learning path
 * section to which the learning path component belongs.
 * @param p_learning_path_member_id The unique identifer of the learning path
 * component to which the enrollment is being made.
 * @param p_member_status_code Status of the learning path component
 * enrollment. Valid values are defined by 'OTA_LP_MEMBER_STATUS' lookup type.
 * @param p_completion_target_date Date before which the learner has to
 * complete the learning path component.
 * @param p_completion_date Date on which the learner has completed the
 * learning path component.
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
 * @param p_attribute21 Descriptive flexfield segment.
 * @param p_attribute22 Descriptive flexfield segment.
 * @param p_attribute23 Descriptive flexfield segment.
 * @param p_attribute24 Descriptive flexfield segment.
 * @param p_attribute25 Descriptive flexfield segment.
 * @param p_attribute26 Descriptive flexfield segment.
 * @param p_attribute27 Descriptive flexfield segment.
 * @param p_attribute28 Descriptive flexfield segment.
 * @param p_attribute29 Descriptive flexfield segment.
 * @param p_attribute30 Descriptive flexfield segment.
 * @param p_creator_person_id The unique identifier of the person who created
 * the learning path component.
 * @param p_business_group_id The unique identifer of the business group to
 * which the learning path belongs.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_event_id to identify whether this class is enrolled through
 * learning path or not.
 * @rep:displayname Update Learning Path Component Enrollment
 * @rep:category BUSINESS_ENTITY OTA_LP_SUBSCRIPTION
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure Update_lp_member_enrollment
  (
  p_effective_date               in date,
  p_lp_member_enrollment_id      in number,
  p_object_version_number        in out nocopy number,
  p_lp_enrollment_id             in number           default hr_api.g_number,
  p_learning_path_section_id     in number           default hr_api.g_number,
  p_learning_path_member_id      in number           default hr_api.g_number,
  p_member_status_code                in varchar2         default hr_api.g_varchar2,
  p_completion_target_date       in date             default hr_api.g_date,
  p_completion_date               in date             default hr_api.g_date,
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
  p_attribute21                  in varchar2         default hr_api.g_varchar2,
  p_attribute22                  in varchar2         default hr_api.g_varchar2,
  p_attribute23                  in varchar2         default hr_api.g_varchar2,
  p_attribute24                  in varchar2         default hr_api.g_varchar2,
  p_attribute25                  in varchar2         default hr_api.g_varchar2,
  p_attribute26                  in varchar2         default hr_api.g_varchar2,
  p_attribute27                  in varchar2         default hr_api.g_varchar2,
  p_attribute28                  in varchar2         default hr_api.g_varchar2,
  p_attribute29                  in varchar2         default hr_api.g_varchar2,
  p_attribute30                  in varchar2         default hr_api.g_varchar2,
  p_creator_person_id            in number           default hr_api.g_number,
  p_business_group_id            in number           default hr_api.g_number,
  p_validate                     in boolean          default false,
  p_event_id                     in number           default hr_api.g_number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_lp_member_enrollment >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a learning path component enrollment record.
 *
 * This business process allows the user to delete a learning path component
 * enrollment within the Learning Path functionality.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The learning path component enrollment record with the given object version
 * number must exist.
 *
 * <p><b>Post Success</b><br>
 * The learning path component enrollment record is successfully removed from
 * the database.
 *
 * <p><b>Post Failure</b><br>
 * The learning path component enrollment record is not deleted and an error is
 * raised.
 *
 * @param p_lp_member_enrollment_id The unique identifier of the learning path
 * component enrollment record which is being deleted.
 * @param p_object_version_number Current version number of the learning path
 * component enrollment to be deleted.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @rep:displayname Delete learning path component enrollment
 * @rep:category BUSINESS_ENTITY OTA_LP_SUBSCRIPTION
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_lp_member_enrollment
  (p_lp_member_enrollment_id           in     number
  ,p_object_version_number         in     number
  ,p_validate                      in     boolean  default false
  );
end ota_lp_member_enrollment_api;

/
