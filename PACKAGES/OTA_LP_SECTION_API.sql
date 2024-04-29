--------------------------------------------------------
--  DDL for Package OTA_LP_SECTION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_LP_SECTION_API" AUTHID CURRENT_USER as
/* $Header: otlpcapi.pkh 120.1 2005/10/02 02:36:59 aroussel $ */
/*#
 * This package contains learning path section APIs.
 * @rep:scope public
 * @rep:product OTA
 * @rep:displayname Learning Path Section
*/
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_lp_section >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates the learning path section.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * Learning Path record must exist.
 *
 * <p><b>Post Success</b><br>
 * The learning path section is created successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create a learning path section record and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_business_group_id The business group owning the section record and
 * the Learning Path.
 * @param p_section_name The name of the learning path section.
 * @param p_description The description for the learning path section.
 * @param p_learning_path_id The Learning Path which will have the section
 * record added to it.
 * @param p_section_sequence The sequence number of the section of a particular
 * learning path.
 * @param p_completion_type_code Completion type of the Learning Path section.
 * Valid values are defined by 'OTA_LP_SECTION_COMPLETION_TYPE'lookup type.
 * @param p_no_of_mandatory_courses The total number of courses that are
 * required to complete the learning path section.
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
 * @param p_learning_path_section_id The unique identifier for the section
 * record.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created learning path section. If p_validate is true,
 * then the value will be null.
 * @rep:displayname Create Learning Path Section
 * @rep:category BUSINESS_ENTITY OTA_LEARNING_PATH
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_lp_section
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_section_name                  in     varchar2
  ,p_description                   in     varchar2 default null
  ,p_learning_path_id              in     number
  ,p_section_sequence              in     number
  ,p_completion_type_code          in     varchar2
  ,p_no_of_mandatory_courses       in     number default null
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
  ,p_learning_path_section_id          out nocopy number
  ,p_object_version_number            out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_lp_section >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the learning path section.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The learning path section record with the given object version number should
 * exist.
 *
 * <p><b>Post Success</b><br>
 * The learning path section is updated successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the section record, and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_learning_path_section_id The unique identifier for the section
 * record.
 * @param p_section_name The name of the learning path section
 * @param p_description The description for the learning path section
 * @param p_object_version_number Pass in the current version number of the
 * learning path section to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated learning path
 * section. If p_validate is true will be set to the same value which was
 * passed in.
 * @param p_section_sequence The sequence number of the section in a particular
 * learning path.
 * @param p_completion_type_code Completion type of the Learning Path section.
 * Valid values are defined by 'OTA_LP_SECTION_COMPLETION_TYPE'lookup type.
 * @param p_no_of_mandatory_courses The total number of courses that are
 * required to complete the learning path section.
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
 * @rep:displayname Update Learning Path Section
 * @rep:category BUSINESS_ENTITY OTA_LEARNING_PATH
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_lp_section
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_learning_path_section_id      in     number
  ,p_section_name                  in     varchar2
  ,p_description                   in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy number
  ,p_section_sequence              in     number   default hr_api.g_number
  ,p_completion_type_code          in     varchar2 default hr_api.g_varchar2
  ,p_no_of_mandatory_courses       in     number   default hr_api.g_number
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
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_lp_section >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes the learning path section.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The learning path section record with the given object version number should
 * exist.
 *
 * <p><b>Post Success</b><br>
 * The learning path section is deleted successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the section record, and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_learning_path_section_id The unique identifier for the section
 * record.
 * @param p_object_version_number Current version number of the learning path
 * section to be deleted.
 * @rep:displayname Delete Learning Path Section
 * @rep:category BUSINESS_ENTITY OTA_LEARNING_PATH
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_lp_section
  (p_validate                      in     boolean  default false
  ,p_learning_path_section_id       in     number
  ,p_object_version_number         in     number
  );
end ota_lp_section_api;

 

/
