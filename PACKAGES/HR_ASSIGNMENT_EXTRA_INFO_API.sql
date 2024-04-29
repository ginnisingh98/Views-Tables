--------------------------------------------------------
--  DDL for Package HR_ASSIGNMENT_EXTRA_INFO_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ASSIGNMENT_EXTRA_INFO_API" AUTHID CURRENT_USER as
/* $Header: peaeiapi.pkh 120.2 2006/05/30 05:24:04 sspratur noship $ */
/*#
 * This package contains APIs for maintaining extra information for
 * assignments.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Assignment Extra Information
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_assignment_extra_info >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates an Assignment Extra Information record for a given
 * assignment.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The assignment must exist. The Extra Information Type must exist.
 *
 * <p><b>Post Success</b><br>
 * The assignment extra information record is created
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the assignment extra information record and raises
 * an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_assignment_id Identifies the assignment for which you create the
 * extra information record.
 * @param p_information_type Identifies the Assignment Extra Information Type.
 * Must be active.
 * @param p_aei_attribute_category This context value determines which
 * Flexfield Structure to use with the Descriptive flexfield segments.
 * @param p_aei_attribute1 Descriptive flexfield segment.
 * @param p_aei_attribute2 Descriptive flexfield segment.
 * @param p_aei_attribute3 Descriptive flexfield segment.
 * @param p_aei_attribute4 Descriptive flexfield segment.
 * @param p_aei_attribute5 Descriptive flexfield segment.
 * @param p_aei_attribute6 Descriptive flexfield segment.
 * @param p_aei_attribute7 Descriptive flexfield segment.
 * @param p_aei_attribute8 Descriptive flexfield segment.
 * @param p_aei_attribute9 Descriptive flexfield segment.
 * @param p_aei_attribute10 Descriptive flexfield segment.
 * @param p_aei_attribute11 Descriptive flexfield segment.
 * @param p_aei_attribute12 Descriptive flexfield segment.
 * @param p_aei_attribute13 Descriptive flexfield segment.
 * @param p_aei_attribute14 Descriptive flexfield segment.
 * @param p_aei_attribute15 Descriptive flexfield segment.
 * @param p_aei_attribute16 Descriptive flexfield segment.
 * @param p_aei_attribute17 Descriptive flexfield segment.
 * @param p_aei_attribute18 Descriptive flexfield segment.
 * @param p_aei_attribute19 Descriptive flexfield segment.
 * @param p_aei_attribute20 Descriptive flexfield segment.
 * @param p_aei_information_category This context value determines which
 * Flexfield Structure to use with the Developer Descriptive flexfield
 * segments. If any Developer Descriptive flexfield segment value i.e.
 * p_aei_information#, is passed then the context value becomes mandatory.
 * @param p_aei_information1 Developer Descriptive flexfield segment.
 * @param p_aei_information2 Developer Descriptive flexfield segment.
 * @param p_aei_information3 Developer Descriptive flexfield segment.
 * @param p_aei_information4 Developer Descriptive flexfield segment.
 * @param p_aei_information5 Developer Descriptive flexfield segment.
 * @param p_aei_information6 Developer Descriptive flexfield segment.
 * @param p_aei_information7 Developer Descriptive flexfield segment.
 * @param p_aei_information8 Developer Descriptive flexfield segment.
 * @param p_aei_information9 Developer Descriptive flexfield segment.
 * @param p_aei_information10 Developer Descriptive flexfield segment.
 * @param p_aei_information11 Developer Descriptive flexfield segment.
 * @param p_aei_information12 Developer Descriptive flexfield segment.
 * @param p_aei_information13 Developer Descriptive flexfield segment.
 * @param p_aei_information14 Developer Descriptive flexfield segment.
 * @param p_aei_information15 Developer Descriptive flexfield segment.
 * @param p_aei_information16 Developer Descriptive flexfield segment.
 * @param p_aei_information17 Developer Descriptive flexfield segment.
 * @param p_aei_information18 Developer Descriptive flexfield segment.
 * @param p_aei_information19 Developer Descriptive flexfield segment.
 * @param p_aei_information20 Developer Descriptive flexfield segment.
 * @param p_aei_information21 Developer Descriptive flexfield segment.
 * @param p_aei_information22 Developer Descriptive flexfield segment.
 * @param p_aei_information23 Developer Descriptive flexfield segment.
 * @param p_aei_information24 Developer Descriptive flexfield segment.
 * @param p_aei_information25 Developer Descriptive flexfield segment.
 * @param p_aei_information26 Developer Descriptive flexfield segment.
 * @param p_aei_information27 Developer Descriptive flexfield segment.
 * @param p_aei_information28 Developer Descriptive flexfield segment.
 * @param p_aei_information29 Developer Descriptive flexfield segment.
 * @param p_aei_information30 Developer Descriptive flexfield segment.
 * @param p_assignment_extra_info_id If p_validate is false, uniquely
 * identifies the assignment extra information record created. If p_validate is
 * true, set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created assignment extra information record. If
 * p_validate is true, then the value will be null.
 * @rep:displayname Create Assignment Extra Information
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE_ASG
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_assignment_extra_info
  (p_validate                      in     boolean  default false
  ,p_assignment_id                 in     number
  ,p_information_type              in     varchar2
  ,p_aei_attribute_category        in     varchar2 default null
  ,p_aei_attribute1                in     varchar2 default null
  ,p_aei_attribute2                in     varchar2 default null
  ,p_aei_attribute3                in     varchar2 default null
  ,p_aei_attribute4                in     varchar2 default null
  ,p_aei_attribute5                in     varchar2 default null
  ,p_aei_attribute6                in     varchar2 default null
  ,p_aei_attribute7                in     varchar2 default null
  ,p_aei_attribute8                in     varchar2 default null
  ,p_aei_attribute9                in     varchar2 default null
  ,p_aei_attribute10               in     varchar2 default null
  ,p_aei_attribute11               in     varchar2 default null
  ,p_aei_attribute12               in     varchar2 default null
  ,p_aei_attribute13               in     varchar2 default null
  ,p_aei_attribute14               in     varchar2 default null
  ,p_aei_attribute15               in     varchar2 default null
  ,p_aei_attribute16               in     varchar2 default null
  ,p_aei_attribute17               in     varchar2 default null
  ,p_aei_attribute18               in     varchar2 default null
  ,p_aei_attribute19               in     varchar2 default null
  ,p_aei_attribute20               in     varchar2 default null
  ,p_aei_information_category      in     varchar2 default null
  ,p_aei_information1              in     varchar2 default null
  ,p_aei_information2              in     varchar2 default null
  ,p_aei_information3              in     varchar2 default null
  ,p_aei_information4              in     varchar2 default null
  ,p_aei_information5              in     varchar2 default null
  ,p_aei_information6              in     varchar2 default null
  ,p_aei_information7              in     varchar2 default null
  ,p_aei_information8              in     varchar2 default null
  ,p_aei_information9              in     varchar2 default null
  ,p_aei_information10             in     varchar2 default null
  ,p_aei_information11             in     varchar2 default null
  ,p_aei_information12             in     varchar2 default null
  ,p_aei_information13             in     varchar2 default null
  ,p_aei_information14             in     varchar2 default null
  ,p_aei_information15             in     varchar2 default null
  ,p_aei_information16             in     varchar2 default null
  ,p_aei_information17             in     varchar2 default null
  ,p_aei_information18             in     varchar2 default null
  ,p_aei_information19             in     varchar2 default null
  ,p_aei_information20             in     varchar2 default null
  ,p_aei_information21             in     varchar2 default null
  ,p_aei_information22             in     varchar2 default null
  ,p_aei_information23             in     varchar2 default null
  ,p_aei_information24             in     varchar2 default null
  ,p_aei_information25             in     varchar2 default null
  ,p_aei_information26             in     varchar2 default null
  ,p_aei_information27             in     varchar2 default null
  ,p_aei_information28             in     varchar2 default null
  ,p_aei_information29             in     varchar2 default null
  ,p_aei_information30             in     varchar2 default null
  ,p_assignment_extra_info_id         out nocopy number
  ,p_object_version_number            out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_assignment_extra_info >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates Assignment Extra Information records.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The assignment extra information record must already exist.
 *
 * <p><b>Post Success</b><br>
 * The assignment extra information record is updated.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the assignment extra information record and raises
 * an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_assignment_extra_info_id Identifies the assignment extra
 * information record to update.
 * @param p_object_version_number Pass in the current version number of the
 * assignment extra information record to be updated. When the API completes if
 * p_validate is false, will be set to the new version number of the updated
 * assignment extra information record. If p_validate is true will be set to
 * the same value which was passed in.
 * @param p_aei_attribute_category This context value determines which
 * Flexfield Structure to use with the Descriptive flexfield segments.
 * @param p_aei_attribute1 Descriptive flexfield segment.
 * @param p_aei_attribute2 Descriptive flexfield segment.
 * @param p_aei_attribute3 Descriptive flexfield segment.
 * @param p_aei_attribute4 Descriptive flexfield segment.
 * @param p_aei_attribute5 Descriptive flexfield segment.
 * @param p_aei_attribute6 Descriptive flexfield segment.
 * @param p_aei_attribute7 Descriptive flexfield segment.
 * @param p_aei_attribute8 Descriptive flexfield segment.
 * @param p_aei_attribute9 Descriptive flexfield segment.
 * @param p_aei_attribute10 Descriptive flexfield segment.
 * @param p_aei_attribute11 Descriptive flexfield segment.
 * @param p_aei_attribute12 Descriptive flexfield segment.
 * @param p_aei_attribute13 Descriptive flexfield segment.
 * @param p_aei_attribute14 Descriptive flexfield segment.
 * @param p_aei_attribute15 Descriptive flexfield segment.
 * @param p_aei_attribute16 Descriptive flexfield segment.
 * @param p_aei_attribute17 Descriptive flexfield segment.
 * @param p_aei_attribute18 Descriptive flexfield segment.
 * @param p_aei_attribute19 Descriptive flexfield segment.
 * @param p_aei_attribute20 Descriptive flexfield segment.
 * @param p_aei_information_category This context value determines which
 * Flexfield Structure to use with the Developer Descriptive flexfield
 * segments.
 * @param p_aei_information1 Developer Descriptive flexfield segment.
 * @param p_aei_information2 Developer Descriptive flexfield segment.
 * @param p_aei_information3 Developer Descriptive flexfield segment.
 * @param p_aei_information4 Developer Descriptive flexfield segment.
 * @param p_aei_information5 Developer Descriptive flexfield segment.
 * @param p_aei_information6 Developer Descriptive flexfield segment.
 * @param p_aei_information7 Developer Descriptive flexfield segment.
 * @param p_aei_information8 Developer Descriptive flexfield segment.
 * @param p_aei_information9 Developer Descriptive flexfield segment.
 * @param p_aei_information10 Developer Descriptive flexfield segment.
 * @param p_aei_information11 Developer Descriptive flexfield segment.
 * @param p_aei_information12 Developer Descriptive flexfield segment.
 * @param p_aei_information13 Developer Descriptive flexfield segment.
 * @param p_aei_information14 Developer Descriptive flexfield segment.
 * @param p_aei_information15 Developer Descriptive flexfield segment.
 * @param p_aei_information16 Developer Descriptive flexfield segment.
 * @param p_aei_information17 Developer Descriptive flexfield segment.
 * @param p_aei_information18 Developer Descriptive flexfield segment.
 * @param p_aei_information19 Developer Descriptive flexfield segment.
 * @param p_aei_information20 Developer Descriptive flexfield segment.
 * @param p_aei_information21 Developer Descriptive flexfield segment.
 * @param p_aei_information22 Developer Descriptive flexfield segment.
 * @param p_aei_information23 Developer Descriptive flexfield segment.
 * @param p_aei_information24 Developer Descriptive flexfield segment.
 * @param p_aei_information25 Developer Descriptive flexfield segment.
 * @param p_aei_information26 Developer Descriptive flexfield segment.
 * @param p_aei_information27 Developer Descriptive flexfield segment.
 * @param p_aei_information28 Developer Descriptive flexfield segment.
 * @param p_aei_information29 Developer Descriptive flexfield segment.
 * @param p_aei_information30 Developer Descriptive flexfield segment.
 * @rep:displayname Update Assignment Extra Information
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE_ASG
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_assignment_extra_info
  (p_validate                      in     boolean  default false
  ,p_assignment_extra_info_id      in     number
  ,p_object_version_number         in out nocopy number
  ,p_aei_attribute_category        in     varchar2 default hr_api.g_varchar2
  ,p_aei_attribute1                in     varchar2 default hr_api.g_varchar2
  ,p_aei_attribute2                in     varchar2 default hr_api.g_varchar2
  ,p_aei_attribute3                in     varchar2 default hr_api.g_varchar2
  ,p_aei_attribute4                in     varchar2 default hr_api.g_varchar2
  ,p_aei_attribute5                in     varchar2 default hr_api.g_varchar2
  ,p_aei_attribute6                in     varchar2 default hr_api.g_varchar2
  ,p_aei_attribute7                in     varchar2 default hr_api.g_varchar2
  ,p_aei_attribute8                in     varchar2 default hr_api.g_varchar2
  ,p_aei_attribute9                in     varchar2 default hr_api.g_varchar2
  ,p_aei_attribute10               in     varchar2 default hr_api.g_varchar2
  ,p_aei_attribute11               in     varchar2 default hr_api.g_varchar2
  ,p_aei_attribute12               in     varchar2 default hr_api.g_varchar2
  ,p_aei_attribute13               in     varchar2 default hr_api.g_varchar2
  ,p_aei_attribute14               in     varchar2 default hr_api.g_varchar2
  ,p_aei_attribute15               in     varchar2 default hr_api.g_varchar2
  ,p_aei_attribute16               in     varchar2 default hr_api.g_varchar2
  ,p_aei_attribute17               in     varchar2 default hr_api.g_varchar2
  ,p_aei_attribute18               in     varchar2 default hr_api.g_varchar2
  ,p_aei_attribute19               in     varchar2 default hr_api.g_varchar2
  ,p_aei_attribute20               in     varchar2 default hr_api.g_varchar2
  ,p_aei_information_category      in     varchar2 default hr_api.g_varchar2
  ,p_aei_information1              in     varchar2 default hr_api.g_varchar2
  ,p_aei_information2              in     varchar2 default hr_api.g_varchar2
  ,p_aei_information3              in     varchar2 default hr_api.g_varchar2
  ,p_aei_information4              in     varchar2 default hr_api.g_varchar2
  ,p_aei_information5              in     varchar2 default hr_api.g_varchar2
  ,p_aei_information6              in     varchar2 default hr_api.g_varchar2
  ,p_aei_information7              in     varchar2 default hr_api.g_varchar2
  ,p_aei_information8              in     varchar2 default hr_api.g_varchar2
  ,p_aei_information9              in     varchar2 default hr_api.g_varchar2
  ,p_aei_information10             in     varchar2 default hr_api.g_varchar2
  ,p_aei_information11             in     varchar2 default hr_api.g_varchar2
  ,p_aei_information12             in     varchar2 default hr_api.g_varchar2
  ,p_aei_information13             in     varchar2 default hr_api.g_varchar2
  ,p_aei_information14             in     varchar2 default hr_api.g_varchar2
  ,p_aei_information15             in     varchar2 default hr_api.g_varchar2
  ,p_aei_information16             in     varchar2 default hr_api.g_varchar2
  ,p_aei_information17             in     varchar2 default hr_api.g_varchar2
  ,p_aei_information18             in     varchar2 default hr_api.g_varchar2
  ,p_aei_information19             in     varchar2 default hr_api.g_varchar2
  ,p_aei_information20             in     varchar2 default hr_api.g_varchar2
  ,p_aei_information21             in     varchar2 default hr_api.g_varchar2
  ,p_aei_information22             in     varchar2 default hr_api.g_varchar2
  ,p_aei_information23             in     varchar2 default hr_api.g_varchar2
  ,p_aei_information24             in     varchar2 default hr_api.g_varchar2
  ,p_aei_information25             in     varchar2 default hr_api.g_varchar2
  ,p_aei_information26             in     varchar2 default hr_api.g_varchar2
  ,p_aei_information27             in     varchar2 default hr_api.g_varchar2
  ,p_aei_information28             in     varchar2 default hr_api.g_varchar2
  ,p_aei_information29             in     varchar2 default hr_api.g_varchar2
  ,p_aei_information30             in     varchar2 default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_assignment_extra_info >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes an Assignment Extra Information record.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The assignment extra information record must already exist.
 *
 * <p><b>Post Success</b><br>
 * The assignment extra information record is deleted.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the assignment extra information record and raises
 * an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_assignment_extra_info_id Unique identifier of the assignment extra
 * information record to be deleted.
 * @param p_object_version_number Current version number of the assignment
 * extra information record to be deleted.
 * @rep:displayname Delete Assignment Extra Information
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE_ASG
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_assignment_extra_info
  (p_validate                      in     boolean  default false
  ,p_assignment_extra_info_id      in     number
  ,p_object_version_number         in     number
  );
--
end hr_assignment_extra_info_api;

 

/
