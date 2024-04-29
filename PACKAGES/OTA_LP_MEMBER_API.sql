--------------------------------------------------------
--  DDL for Package OTA_LP_MEMBER_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_LP_MEMBER_API" AUTHID CURRENT_USER as
/* $Header: otlpmapi.pkh 120.1 2005/10/02 02:07:38 aroussel $ */
/*#
 * This package contains Learning Path Component APIs.
 * @rep:scope public
 * @rep:product ota
 * @rep:displayname Learning Path Component
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_learning_path_member >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a learning path component.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The Learning Path and the course must exist and the course must be valid
 * within the Learning Path dates; i.e., the course should not start after the
 * learning path end date and should not end before the learning path start
 * date.
 *
 * <p><b>Post Success</b><br>
 * The Learning Path Component will be successfully created.
 *
 * <p><b>Post Failure</b><br>
 * The learning path component will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_business_group_id The unique idetifier of the business group that
 * owns the learning path component record and the Learning Path.
 * @param p_learning_path_id The unique identifier of the learning path in
 * which the component is being created.
 * @param p_activity_version_id The unique identifier of the course that is
 * being added as component.
 * @param p_course_sequence The sequence number of this component in the
 * learning path.
 * @param p_duration The estimated length of the learning path component.
 * @param p_duration_units The completion target units of the learning path
 * component. Valid values are defined by the 'OTA_DURATION_UNITS' lookup type.
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
 * @param p_learning_path_member_id The unique identifier for the member
 * record.
 * @param p_object_version_number If p_validate is false, then the number is
 * set to the version number of the created learning path member. If p_validate
 * is true, then the value is null.
 * @param p_notify_days_before_target New parameter, available on the latest
 * version of this API.
 * @param p_learning_path_section_id New parameter, available on the latest
 * version of this API.
 * @rep:displayname Create Learning Path Component
 * @rep:category BUSINESS_ENTITY OTA_LEARNING_PATH_COMPONENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_learning_path_member
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_learning_path_id              in     number
  ,p_activity_version_id           in     number
  ,p_course_sequence               in     number
  ,p_duration                      in     number   default null
  ,p_duration_units                in     varchar2 default null
  ,p_attribute_category            in     varchar2 default null
  ,p_attribute1                    in     varchar2 default null
  ,p_attribute2                    in     varchar2 default null
  ,p_attribute3                    in     varchar2 default null
  ,p_attribute4                    in     varchar2 default null
  ,p_attribute5                    in     varchar2 default null
  ,p_attribute6                    in     varchar2 default null
  ,p_attribute7                    in     varchar2 default null
  ,p_attribute8                    in     varchar2 default null
  ,p_attribute9                    in     varchar2 default null
  ,p_attribute10                   in     varchar2 default null
  ,p_attribute11                   in     varchar2 default null
  ,p_attribute12                   in     varchar2 default null
  ,p_attribute13                   in     varchar2 default null
  ,p_attribute14                   in     varchar2 default null
  ,p_attribute15                   in     varchar2 default null
  ,p_attribute16                   in     varchar2 default null
  ,p_attribute17                   in     varchar2 default null
  ,p_attribute18                   in     varchar2 default null
  ,p_attribute19                   in     varchar2 default null
  ,p_attribute20                   in     varchar2 default null
  ,p_learning_path_section_id      in     number
  ,p_notify_days_before_target     in     number default null
  ,p_learning_path_member_id          out nocopy number
  ,p_object_version_number            out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_learning_path_member >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a learning path component.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The learning path component should exist.
 *
 * <p><b>Post Success</b><br>
 * The learning path component will be successfully updated.
 *
 * <p><b>Post Failure</b><br>
 * The learning path component will not be updated and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_learning_path_member_id The unique identifier for the member
 * record.
 * @param p_object_version_number Pass in the current version number of the
 * learning path component to be updated. When the API completes, if p_validate
 * is false, the number is set to the new version number of the updated
 * learning path component. If p_validate is true, the number remains
 * unchanged.
 * @param p_activity_version_id The unique identifier of the course that is
 * added to the learning path as component.
 * @param p_course_sequence The sequence number of this component in the
 * learning path.
 * @param p_duration The estimated length of the learning path component.
 * @param p_duration_units The completion target units of the learning path
 * component. Valid values are defined by the 'OTA_DURATION_UNITS' lookup type.
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
 * @param p_notify_days_before_target New parameter, available on the latest
 * version of this API.
 * @rep:displayname Update Learning Path Component
 * @rep:category BUSINESS_ENTITY OTA_LEARNING_PATH_COMPONENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_learning_path_member
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_learning_path_member_id       in     number
  ,p_object_version_number         in out nocopy number
  ,p_activity_version_id           in     number   default hr_api.g_number
  ,p_course_sequence               in     number   default hr_api.g_number
  ,p_duration                      in     number   default hr_api.g_number
  ,p_duration_units                in     varchar2 default hr_api.g_varchar2
  ,p_attribute_category            in     varchar2 default hr_api.g_varchar2
  ,p_attribute1                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute2                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute3                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute4                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute5                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute6                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute7                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute8                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute9                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute10                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute11                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute12                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute13                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute14                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute15                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute16                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute17                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute18                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute19                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute20                   in     varchar2 default hr_api.g_varchar2
  ,p_notify_days_before_target     in     number default hr_api.g_number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_learning_path_member >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a learning path component.
 *
 * Warning: Learning Path components should not be deleted after a learner has
 * subscribed to the catalog Learning Path.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * There should not be any learners subscribed to the Learning Path.
 *
 * <p><b>Post Success</b><br>
 * The learning path component will be deleted from the database.
 *
 * <p><b>Post Failure</b><br>
 * The learning path component will not be deleted and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_learning_path_member_id The unique identifier for the learning path
 * component record.
 * @param p_object_version_number Current version number of the learning path
 * component to be deleted.
 * @rep:displayname Delete Learning Path Component
 * @rep:category BUSINESS_ENTITY OTA_LEARNING_PATH_COMPONENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_learning_path_member
  (p_validate                      in     boolean  default false
  ,p_learning_path_member_id       in     number
  ,p_object_version_number         in     number
  );
end ota_lp_member_api;

 

/
