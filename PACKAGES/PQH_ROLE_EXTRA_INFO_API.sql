--------------------------------------------------------
--  DDL for Package PQH_ROLE_EXTRA_INFO_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_ROLE_EXTRA_INFO_API" AUTHID CURRENT_USER as
/* $Header: pqreiapi.pkh 120.1 2005/10/02 02:27:16 aroussel $ */
/*#
 * This package contains role extra information APIs .
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Role Extra Information
*/
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_role_extra_info >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates role extra information.
 *
 * The user can define as many extra information types as required to hold
 * additional information about roles. Some predefined extra information types
 * for roles are: French Public Sector Committee Rules, French Public Sector
 * Committee Election, French Public Sector Committee Vote Rules, French Public
 * Sector Establishments and Corps.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The role for which the extra information is created must already exist. The
 * role information type must already exist.
 *
 * <p><b>Post Success</b><br>
 * The role extra information is successfully created in the database.
 *
 * <p><b>Post Failure</b><br>
 * The role extra information is not created and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_role_id The role for which the extra information applies.
 * @param p_information_type Information type of the extra information stored
 * for the role.
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
 * @param p_information_category This context value determines which flexfield
 * structure to use with the developer descriptive flexfield segments.
 * @param p_information1 Developer descriptive flexfield segment.
 * @param p_information2 Developer descriptive flexfield segment.
 * @param p_information3 Developer descriptive flexfield segment.
 * @param p_information4 Developer descriptive flexfield segment.
 * @param p_information5 Developer descriptive flexfield segment.
 * @param p_information6 Developer descriptive flexfield segment.
 * @param p_information7 Developer descriptive flexfield segment.
 * @param p_information8 Developer descriptive flexfield segment.
 * @param p_information9 Developer descriptive flexfield segment.
 * @param p_information10 Developer descriptive flexfield segment.
 * @param p_information11 Developer descriptive flexfield segment.
 * @param p_information12 Developer descriptive flexfield segment.
 * @param p_information13 Developer descriptive flexfield segment.
 * @param p_information14 Developer descriptive flexfield segment.
 * @param p_information15 Developer descriptive flexfield segment.
 * @param p_information16 Developer descriptive flexfield segment.
 * @param p_information17 Developer descriptive flexfield segment.
 * @param p_information18 Developer descriptive flexfield segment.
 * @param p_information19 Developer descriptive flexfield segment.
 * @param p_information20 Developer descriptive flexfield segment.
 * @param p_information21 Developer descriptive flexfield segment.
 * @param p_information22 Developer descriptive flexfield segment.
 * @param p_information23 Developer descriptive flexfield segment.
 * @param p_information24 Developer descriptive flexfield segment.
 * @param p_information25 Developer descriptive flexfield segment.
 * @param p_information26 Developer descriptive flexfield segment.
 * @param p_information27 Developer descriptive flexfield segment.
 * @param p_information28 Developer descriptive flexfield segment.
 * @param p_information29 Developer descriptive flexfield segment.
 * @param p_information30 Developer descriptive flexfield segment.
 * @param p_role_extra_info_id If p_validate is false, uniquely identifies the
 * role extra information created. If p_validate is true, set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created role extra information. If p_validate is true,
 * then the value will be null.
 * @rep:displayname Create Role Extra Information
 * @rep:category BUSINESS_ENTITY HR_ROLE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_role_extra_info
  (p_validate                      in     boolean  default false
  ,p_role_id                       in     number
  ,p_information_type              in     varchar2
  ,p_attribute_category       in     varchar2 default null
  ,p_attribute1               in     varchar2 default null
  ,p_attribute2               in     varchar2 default null
  ,p_attribute3               in     varchar2 default null
  ,p_attribute4               in     varchar2 default null
  ,p_attribute5               in     varchar2 default null
  ,p_attribute6               in     varchar2 default null
  ,p_attribute7               in     varchar2 default null
  ,p_attribute8               in     varchar2 default null
  ,p_attribute9               in     varchar2 default null
  ,p_attribute10              in     varchar2 default null
  ,p_attribute11              in     varchar2 default null
  ,p_attribute12              in     varchar2 default null
  ,p_attribute13              in     varchar2 default null
  ,p_attribute14              in     varchar2 default null
  ,p_attribute15              in     varchar2 default null
  ,p_attribute16              in     varchar2 default null
  ,p_attribute17              in     varchar2 default null
  ,p_attribute18              in     varchar2 default null
  ,p_attribute19              in     varchar2 default null
  ,p_attribute20              in     varchar2 default null
  ,p_attribute21              in     varchar2 default null
  ,p_attribute22              in     varchar2 default null
  ,p_attribute23              in     varchar2 default null
  ,p_attribute24              in     varchar2 default null
  ,p_attribute25              in     varchar2 default null
  ,p_attribute26              in     varchar2 default null
  ,p_attribute27              in     varchar2 default null
  ,p_attribute28              in     varchar2 default null
  ,p_attribute29              in     varchar2 default null
  ,p_attribute30              in     varchar2 default null
  ,p_information_category     in     varchar2 default null
  ,p_information1             in     varchar2 default null
  ,p_information2             in     varchar2 default null
  ,p_information3             in     varchar2 default null
  ,p_information4             in     varchar2 default null
  ,p_information5             in     varchar2 default null
  ,p_information6             in     varchar2 default null
  ,p_information7             in     varchar2 default null
  ,p_information8             in     varchar2 default null
  ,p_information9             in     varchar2 default null
  ,p_information10            in     varchar2 default null
  ,p_information11            in     varchar2 default null
  ,p_information12            in     varchar2 default null
  ,p_information13            in     varchar2 default null
  ,p_information14            in     varchar2 default null
  ,p_information15            in     varchar2 default null
  ,p_information16            in     varchar2 default null
  ,p_information17            in     varchar2 default null
  ,p_information18            in     varchar2 default null
  ,p_information19            in     varchar2 default null
  ,p_information20            in     varchar2 default null
  ,p_information21            in     varchar2 default null
  ,p_information22            in     varchar2 default null
  ,p_information23            in     varchar2 default null
  ,p_information24            in     varchar2 default null
  ,p_information25            in     varchar2 default null
  ,p_information26            in     varchar2 default null
  ,p_information27            in     varchar2 default null
  ,p_information28            in     varchar2 default null
  ,p_information29            in     varchar2 default null
  ,p_information30            in     varchar2 default null
  ,p_role_extra_info_id           out nocopy number
  ,p_object_version_number        out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_role_extra_info >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates extra information for a given role.
 *
 * The API validates all the developer descriptive flexfield values and
 * descriptive flexfield values before updating the role extra information.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The role extra information record must already exist. The role information
 * type must already exist.
 *
 * <p><b>Post Success</b><br>
 * The role extra information is updated successfully in the database.
 *
 * <p><b>Post Failure</b><br>
 * The role extra information is not updated and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_role_extra_info_id Identifies the role extra information record to
 * be modified
 * @param p_object_version_number Pass in the current version number of the
 * role extra information record to be updated. When the API completes if
 * p_validate is false, will be set to the new version number of the updated
 * role extra information record . If p_validate is true will be set to the
 * same value which was passed in.
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
 * @param p_information_category This context value determines which flexfield
 * structure to use with the developer descriptive flexfield segments.
 * @param p_information1 Developer descriptive flexfield segment.
 * @param p_information2 Developer descriptive flexfield segment.
 * @param p_information3 Developer descriptive flexfield segment.
 * @param p_information4 Developer descriptive flexfield segment.
 * @param p_information5 Developer descriptive flexfield segment.
 * @param p_information6 Developer descriptive flexfield segment.
 * @param p_information7 Developer descriptive flexfield segment.
 * @param p_information8 Developer descriptive flexfield segment.
 * @param p_information9 Developer descriptive flexfield segment.
 * @param p_information10 Developer descriptive flexfield segment.
 * @param p_information11 Developer descriptive flexfield segment.
 * @param p_information12 Developer descriptive flexfield segment.
 * @param p_information13 Developer descriptive flexfield segment.
 * @param p_information14 Developer descriptive flexfield segment.
 * @param p_information15 Developer descriptive flexfield segment.
 * @param p_information16 Developer descriptive flexfield segment.
 * @param p_information17 Developer descriptive flexfield segment.
 * @param p_information18 Developer descriptive flexfield segment.
 * @param p_information19 Developer descriptive flexfield segment.
 * @param p_information20 Developer descriptive flexfield segment.
 * @param p_information21 Developer descriptive flexfield segment.
 * @param p_information22 Developer descriptive flexfield segment.
 * @param p_information23 Developer descriptive flexfield segment.
 * @param p_information24 Developer descriptive flexfield segment.
 * @param p_information25 Developer descriptive flexfield segment.
 * @param p_information26 Developer descriptive flexfield segment.
 * @param p_information27 Developer descriptive flexfield segment.
 * @param p_information28 Developer descriptive flexfield segment.
 * @param p_information29 Developer descriptive flexfield segment.
 * @param p_information30 Developer descriptive flexfield segment.
 * @rep:displayname Update Role Extra Information
 * @rep:category BUSINESS_ENTITY HR_ROLE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_role_extra_info
  (p_validate                      in     boolean  default false
  ,p_role_extra_info_id            in     number
  ,p_object_version_number         in out nocopy number
  ,p_attribute_category       in     varchar2 default hr_api.g_varchar2
  ,p_attribute1               in     varchar2 default hr_api.g_varchar2
  ,p_attribute2               in     varchar2 default hr_api.g_varchar2
  ,p_attribute3               in     varchar2 default hr_api.g_varchar2
  ,p_attribute4               in     varchar2 default hr_api.g_varchar2
  ,p_attribute5               in     varchar2 default hr_api.g_varchar2
  ,p_attribute6               in     varchar2 default hr_api.g_varchar2
  ,p_attribute7               in     varchar2 default hr_api.g_varchar2
  ,p_attribute8               in     varchar2 default hr_api.g_varchar2
  ,p_attribute9               in     varchar2 default hr_api.g_varchar2
  ,p_attribute10              in     varchar2 default hr_api.g_varchar2
  ,p_attribute11              in     varchar2 default hr_api.g_varchar2
  ,p_attribute12              in     varchar2 default hr_api.g_varchar2
  ,p_attribute13              in     varchar2 default hr_api.g_varchar2
  ,p_attribute14              in     varchar2 default hr_api.g_varchar2
  ,p_attribute15              in     varchar2 default hr_api.g_varchar2
  ,p_attribute16              in     varchar2 default hr_api.g_varchar2
  ,p_attribute17              in     varchar2 default hr_api.g_varchar2
  ,p_attribute18              in     varchar2 default hr_api.g_varchar2
  ,p_attribute19              in     varchar2 default hr_api.g_varchar2
  ,p_attribute20              in     varchar2 default hr_api.g_varchar2
  ,p_attribute21              in     varchar2 default hr_api.g_varchar2
  ,p_attribute22              in     varchar2 default hr_api.g_varchar2
  ,p_attribute23              in     varchar2 default hr_api.g_varchar2
  ,p_attribute24              in     varchar2 default hr_api.g_varchar2
  ,p_attribute25              in     varchar2 default hr_api.g_varchar2
  ,p_attribute26              in     varchar2 default hr_api.g_varchar2
  ,p_attribute27              in     varchar2 default hr_api.g_varchar2
  ,p_attribute28              in     varchar2 default hr_api.g_varchar2
  ,p_attribute29              in     varchar2 default hr_api.g_varchar2
  ,p_attribute30              in     varchar2 default hr_api.g_varchar2
  ,p_information_category     in     varchar2 default hr_api.g_varchar2
  ,p_information1             in     varchar2 default hr_api.g_varchar2
  ,p_information2             in     varchar2 default hr_api.g_varchar2
  ,p_information3             in     varchar2 default hr_api.g_varchar2
  ,p_information4             in     varchar2 default hr_api.g_varchar2
  ,p_information5             in     varchar2 default hr_api.g_varchar2
  ,p_information6             in     varchar2 default hr_api.g_varchar2
  ,p_information7             in     varchar2 default hr_api.g_varchar2
  ,p_information8             in     varchar2 default hr_api.g_varchar2
  ,p_information9             in     varchar2 default hr_api.g_varchar2
  ,p_information10            in     varchar2 default hr_api.g_varchar2
  ,p_information11            in     varchar2 default hr_api.g_varchar2
  ,p_information12            in     varchar2 default hr_api.g_varchar2
  ,p_information13            in     varchar2 default hr_api.g_varchar2
  ,p_information14            in     varchar2 default hr_api.g_varchar2
  ,p_information15            in     varchar2 default hr_api.g_varchar2
  ,p_information16            in     varchar2 default hr_api.g_varchar2
  ,p_information17            in     varchar2 default hr_api.g_varchar2
  ,p_information18            in     varchar2 default hr_api.g_varchar2
  ,p_information19            in     varchar2 default hr_api.g_varchar2
  ,p_information20            in     varchar2 default hr_api.g_varchar2
  ,p_information21            in     varchar2 default hr_api.g_varchar2
  ,p_information22            in     varchar2 default hr_api.g_varchar2
  ,p_information23            in     varchar2 default hr_api.g_varchar2
  ,p_information24            in     varchar2 default hr_api.g_varchar2
  ,p_information25            in     varchar2 default hr_api.g_varchar2
  ,p_information26            in     varchar2 default hr_api.g_varchar2
  ,p_information27            in     varchar2 default hr_api.g_varchar2
  ,p_information28            in     varchar2 default hr_api.g_varchar2
  ,p_information29            in     varchar2 default hr_api.g_varchar2
  ,p_information30            in     varchar2 default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_role_extra_info >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes extra information for a given role.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The role extra information record must already exist.
 *
 * <p><b>Post Success</b><br>
 * The role extra information record is deleted successfully from the database.
 *
 * <p><b>Post Failure</b><br>
 * The role extra information is not deleted and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_role_extra_info_id Identifies the role extra information record to
 * be deleted.
 * @param p_object_version_number Current version number of the role extra
 * information to be deleted.
 * @rep:displayname Delete Role Extra Information
 * @rep:category BUSINESS_ENTITY HR_ROLE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_role_extra_info
  (p_validate                      	in     boolean  default false
  ,p_role_extra_info_id          	in     number
  ,p_object_version_number         	in     number
  );
--
end pqh_role_extra_info_api;

 

/
