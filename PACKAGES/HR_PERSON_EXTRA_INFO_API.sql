--------------------------------------------------------
--  DDL for Package HR_PERSON_EXTRA_INFO_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PERSON_EXTRA_INFO_API" AUTHID CURRENT_USER as
/* $Header: pepeiapi.pkh 120.1.12010000.1 2008/07/28 05:10:44 appldev ship $ */
/*#
 * This API maintains person extra information.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Person Extra Information
*/
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_person_extra_info >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates person extra information.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The person and the person extra information type must exist in the relevant
 * business group.
 *
 * <p><b>Post Success</b><br>
 * Person extra information is successfully created.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the person extra information and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_person_id Identifies the person for whom you create the person
 * extra information record.
 * @param p_information_type Type of extra information being created.
 * @param p_pei_attribute_category This context value determines which
 * flexfield structure to use with the descriptive flexfield segments.
 * @param p_pei_attribute1 Descriptive flexfield segment.
 * @param p_pei_attribute2 Descriptive flexfield segment.
 * @param p_pei_attribute3 Descriptive flexfield segment.
 * @param p_pei_attribute4 Descriptive flexfield segment.
 * @param p_pei_attribute5 Descriptive flexfield segment.
 * @param p_pei_attribute6 Descriptive flexfield segment.
 * @param p_pei_attribute7 Descriptive flexfield segment.
 * @param p_pei_attribute8 Descriptive flexfield segment.
 * @param p_pei_attribute9 Descriptive flexfield segment.
 * @param p_pei_attribute10 Descriptive flexfield segment.
 * @param p_pei_attribute11 Descriptive flexfield segment.
 * @param p_pei_attribute12 Descriptive flexfield segment.
 * @param p_pei_attribute13 Descriptive flexfield segment.
 * @param p_pei_attribute14 Descriptive flexfield segment.
 * @param p_pei_attribute15 Descriptive flexfield segment.
 * @param p_pei_attribute16 Descriptive flexfield segment.
 * @param p_pei_attribute17 Descriptive flexfield segment.
 * @param p_pei_attribute18 Descriptive flexfield segment.
 * @param p_pei_attribute19 Descriptive flexfield segment.
 * @param p_pei_attribute20 Descriptive flexfield segment.
 * @param p_pei_information_category This context value determines which
 * flexfield structure to use with the developer descriptive flexfield
 * segments.
 * @param p_pei_information1 Developer Descriptive flexfield segment.
 * @param p_pei_information2 Developer Descriptive flexfield segment.
 * @param p_pei_information3 Developer Descriptive flexfield segment.
 * @param p_pei_information4 Developer Descriptive flexfield segment.
 * @param p_pei_information5 Developer Descriptive flexfield segment.
 * @param p_pei_information6 Developer Descriptive flexfield segment.
 * @param p_pei_information7 Developer Descriptive flexfield segment.
 * @param p_pei_information8 Developer Descriptive flexfield segment.
 * @param p_pei_information9 Developer Descriptive flexfield segment.
 * @param p_pei_information10 Developer Descriptive flexfield segment.
 * @param p_pei_information11 Developer Descriptive flexfield segment.
 * @param p_pei_information12 Developer Descriptive flexfield segment.
 * @param p_pei_information13 Developer Descriptive flexfield segment.
 * @param p_pei_information14 Developer Descriptive flexfield segment.
 * @param p_pei_information15 Developer Descriptive flexfield segment.
 * @param p_pei_information16 Developer Descriptive flexfield segment.
 * @param p_pei_information17 Developer Descriptive flexfield segment.
 * @param p_pei_information18 Developer Descriptive flexfield segment.
 * @param p_pei_information19 Developer Descriptive flexfield segment.
 * @param p_pei_information20 Developer Descriptive flexfield segment.
 * @param p_pei_information21 Developer Descriptive flexfield segment.
 * @param p_pei_information22 Developer Descriptive flexfield segment.
 * @param p_pei_information23 Developer Descriptive flexfield segment.
 * @param p_pei_information24 Developer Descriptive flexfield segment.
 * @param p_pei_information25 Developer Descriptive flexfield segment.
 * @param p_pei_information26 Developer Descriptive flexfield segment.
 * @param p_pei_information27 Developer Descriptive flexfield segment.
 * @param p_pei_information28 Developer Descriptive flexfield segment.
 * @param p_pei_information29 Developer Descriptive flexfield segment.
 * @param p_pei_information30 Developer Descriptive flexfield segment.
 * @param p_person_extra_info_id If p_validate is false, then this uniquely
 * identifies the person extra info created. If p_validate is true, then set to
 * null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created person extra information. If p_validate is
 * true, then the value will be null.
 * @rep:displayname Create Person Extra Information
 * @rep:category BUSINESS_ENTITY HR_PERSON
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_person_extra_info
  (p_validate                      in     boolean  default false
  ,p_person_id                     in     number
  ,p_information_type              in     varchar2
  ,p_pei_attribute_category        in     varchar2 default null
  ,p_pei_attribute1                in     varchar2 default null
  ,p_pei_attribute2                in     varchar2 default null
  ,p_pei_attribute3                in     varchar2 default null
  ,p_pei_attribute4                in     varchar2 default null
  ,p_pei_attribute5                in     varchar2 default null
  ,p_pei_attribute6                in     varchar2 default null
  ,p_pei_attribute7                in     varchar2 default null
  ,p_pei_attribute8                in     varchar2 default null
  ,p_pei_attribute9                in     varchar2 default null
  ,p_pei_attribute10               in     varchar2 default null
  ,p_pei_attribute11               in     varchar2 default null
  ,p_pei_attribute12               in     varchar2 default null
  ,p_pei_attribute13               in     varchar2 default null
  ,p_pei_attribute14               in     varchar2 default null
  ,p_pei_attribute15               in     varchar2 default null
  ,p_pei_attribute16               in     varchar2 default null
  ,p_pei_attribute17               in     varchar2 default null
  ,p_pei_attribute18               in     varchar2 default null
  ,p_pei_attribute19               in     varchar2 default null
  ,p_pei_attribute20               in     varchar2 default null
  ,p_pei_information_category      in     varchar2 default null
  ,p_pei_information1              in     varchar2 default null
  ,p_pei_information2              in     varchar2 default null
  ,p_pei_information3              in     varchar2 default null
  ,p_pei_information4              in     varchar2 default null
  ,p_pei_information5              in     varchar2 default null
  ,p_pei_information6              in     varchar2 default null
  ,p_pei_information7              in     varchar2 default null
  ,p_pei_information8              in     varchar2 default null
  ,p_pei_information9              in     varchar2 default null
  ,p_pei_information10             in     varchar2 default null
  ,p_pei_information11             in     varchar2 default null
  ,p_pei_information12             in     varchar2 default null
  ,p_pei_information13             in     varchar2 default null
  ,p_pei_information14             in     varchar2 default null
  ,p_pei_information15             in     varchar2 default null
  ,p_pei_information16             in     varchar2 default null
  ,p_pei_information17             in     varchar2 default null
  ,p_pei_information18             in     varchar2 default null
  ,p_pei_information19             in     varchar2 default null
  ,p_pei_information20             in     varchar2 default null
  ,p_pei_information21             in     varchar2 default null
  ,p_pei_information22             in     varchar2 default null
  ,p_pei_information23             in     varchar2 default null
  ,p_pei_information24             in     varchar2 default null
  ,p_pei_information25             in     varchar2 default null
  ,p_pei_information26             in     varchar2 default null
  ,p_pei_information27             in     varchar2 default null
  ,p_pei_information28             in     varchar2 default null
  ,p_pei_information29             in     varchar2 default null
  ,p_pei_information30             in     varchar2 default null
  ,p_person_extra_info_id             out nocopy number
  ,p_object_version_number            out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_person_extra_info >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates person extra information.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Person extra information must exist in the relevant business group.
 *
 * <p><b>Post Success</b><br>
 * Person extra information is successfully created.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the person extra information and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_person_extra_info_id Identifies the person extra information record
 * to be modified.
 * @param p_object_version_number Pass in the current version number of the
 * person extra information to be updated. When the API completes if p_validate
 * is false, will be set to the new version number of the updated person extra
 * information. If p_validate is true will be set to the same value which was
 * passed in.
 * @param p_pei_attribute_category This context value determines which
 * flexfield structure to use with the descriptive flexfield segments.
 * @param p_pei_attribute1 Descriptive flexfield segment.
 * @param p_pei_attribute2 Descriptive flexfield segment.
 * @param p_pei_attribute3 Descriptive flexfield segment.
 * @param p_pei_attribute4 Descriptive flexfield segment.
 * @param p_pei_attribute5 Descriptive flexfield segment.
 * @param p_pei_attribute6 Descriptive flexfield segment.
 * @param p_pei_attribute7 Descriptive flexfield segment.
 * @param p_pei_attribute8 Descriptive flexfield segment.
 * @param p_pei_attribute9 Descriptive flexfield segment.
 * @param p_pei_attribute10 Descriptive flexfield segment.
 * @param p_pei_attribute11 Descriptive flexfield segment.
 * @param p_pei_attribute12 Descriptive flexfield segment.
 * @param p_pei_attribute13 Descriptive flexfield segment.
 * @param p_pei_attribute14 Descriptive flexfield segment.
 * @param p_pei_attribute15 Descriptive flexfield segment.
 * @param p_pei_attribute16 Descriptive flexfield segment.
 * @param p_pei_attribute17 Descriptive flexfield segment.
 * @param p_pei_attribute18 Descriptive flexfield segment.
 * @param p_pei_attribute19 Descriptive flexfield segment.
 * @param p_pei_attribute20 Descriptive flexfield segment.
 * @param p_pei_information_category This context value determines which
 * flexfield structure to use with the developer descriptive flexfield
 * segments.
 * @param p_pei_information1 Developer Descriptive flexfield segment.
 * @param p_pei_information2 Developer Descriptive flexfield segment.
 * @param p_pei_information3 Developer Descriptive flexfield segment.
 * @param p_pei_information4 Developer Descriptive flexfield segment.
 * @param p_pei_information5 Developer Descriptive flexfield segment.
 * @param p_pei_information6 Developer Descriptive flexfield segment.
 * @param p_pei_information7 Developer Descriptive flexfield segment.
 * @param p_pei_information8 Developer Descriptive flexfield segment.
 * @param p_pei_information9 Developer Descriptive flexfield segment.
 * @param p_pei_information10 Developer Descriptive flexfield segment.
 * @param p_pei_information11 Developer Descriptive flexfield segment.
 * @param p_pei_information12 Developer Descriptive flexfield segment.
 * @param p_pei_information13 Developer Descriptive flexfield segment.
 * @param p_pei_information14 Developer Descriptive flexfield segment.
 * @param p_pei_information15 Developer Descriptive flexfield segment.
 * @param p_pei_information16 Developer Descriptive flexfield segment.
 * @param p_pei_information17 Developer Descriptive flexfield segment.
 * @param p_pei_information18 Developer Descriptive flexfield segment.
 * @param p_pei_information19 Developer Descriptive flexfield segment.
 * @param p_pei_information20 Developer Descriptive flexfield segment.
 * @param p_pei_information21 Developer Descriptive flexfield segment.
 * @param p_pei_information22 Developer Descriptive flexfield segment.
 * @param p_pei_information23 Developer Descriptive flexfield segment.
 * @param p_pei_information24 Developer Descriptive flexfield segment.
 * @param p_pei_information25 Developer Descriptive flexfield segment.
 * @param p_pei_information26 Developer Descriptive flexfield segment.
 * @param p_pei_information27 Developer Descriptive flexfield segment.
 * @param p_pei_information28 Developer Descriptive flexfield segment.
 * @param p_pei_information29 Developer Descriptive flexfield segment.
 * @param p_pei_information30 Developer Descriptive flexfield segment.
 * @rep:displayname Update Person Extra Information
 * @rep:category BUSINESS_ENTITY HR_PERSON
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_person_extra_info
  (p_validate                      in     boolean  default false
  ,p_person_extra_info_id          in     number
  ,p_object_version_number         in out nocopy number
  ,p_pei_attribute_category        in     varchar2 default hr_api.g_varchar2
  ,p_pei_attribute1                in     varchar2 default hr_api.g_varchar2
  ,p_pei_attribute2                in     varchar2 default hr_api.g_varchar2
  ,p_pei_attribute3                in     varchar2 default hr_api.g_varchar2
  ,p_pei_attribute4                in     varchar2 default hr_api.g_varchar2
  ,p_pei_attribute5                in     varchar2 default hr_api.g_varchar2
  ,p_pei_attribute6                in     varchar2 default hr_api.g_varchar2
  ,p_pei_attribute7                in     varchar2 default hr_api.g_varchar2
  ,p_pei_attribute8                in     varchar2 default hr_api.g_varchar2
  ,p_pei_attribute9                in     varchar2 default hr_api.g_varchar2
  ,p_pei_attribute10               in     varchar2 default hr_api.g_varchar2
  ,p_pei_attribute11               in     varchar2 default hr_api.g_varchar2
  ,p_pei_attribute12               in     varchar2 default hr_api.g_varchar2
  ,p_pei_attribute13               in     varchar2 default hr_api.g_varchar2
  ,p_pei_attribute14               in     varchar2 default hr_api.g_varchar2
  ,p_pei_attribute15               in     varchar2 default hr_api.g_varchar2
  ,p_pei_attribute16               in     varchar2 default hr_api.g_varchar2
  ,p_pei_attribute17               in     varchar2 default hr_api.g_varchar2
  ,p_pei_attribute18               in     varchar2 default hr_api.g_varchar2
  ,p_pei_attribute19               in     varchar2 default hr_api.g_varchar2
  ,p_pei_attribute20               in     varchar2 default hr_api.g_varchar2
  ,p_pei_information_category      in     varchar2 default hr_api.g_varchar2
  ,p_pei_information1              in     varchar2 default hr_api.g_varchar2
  ,p_pei_information2              in     varchar2 default hr_api.g_varchar2
  ,p_pei_information3              in     varchar2 default hr_api.g_varchar2
  ,p_pei_information4              in     varchar2 default hr_api.g_varchar2
  ,p_pei_information5              in     varchar2 default hr_api.g_varchar2
  ,p_pei_information6              in     varchar2 default hr_api.g_varchar2
  ,p_pei_information7              in     varchar2 default hr_api.g_varchar2
  ,p_pei_information8              in     varchar2 default hr_api.g_varchar2
  ,p_pei_information9              in     varchar2 default hr_api.g_varchar2
  ,p_pei_information10             in     varchar2 default hr_api.g_varchar2
  ,p_pei_information11             in     varchar2 default hr_api.g_varchar2
  ,p_pei_information12             in     varchar2 default hr_api.g_varchar2
  ,p_pei_information13             in     varchar2 default hr_api.g_varchar2
  ,p_pei_information14             in     varchar2 default hr_api.g_varchar2
  ,p_pei_information15             in     varchar2 default hr_api.g_varchar2
  ,p_pei_information16             in     varchar2 default hr_api.g_varchar2
  ,p_pei_information17             in     varchar2 default hr_api.g_varchar2
  ,p_pei_information18             in     varchar2 default hr_api.g_varchar2
  ,p_pei_information19             in     varchar2 default hr_api.g_varchar2
  ,p_pei_information20             in     varchar2 default hr_api.g_varchar2
  ,p_pei_information21             in     varchar2 default hr_api.g_varchar2
  ,p_pei_information22             in     varchar2 default hr_api.g_varchar2
  ,p_pei_information23             in     varchar2 default hr_api.g_varchar2
  ,p_pei_information24             in     varchar2 default hr_api.g_varchar2
  ,p_pei_information25             in     varchar2 default hr_api.g_varchar2
  ,p_pei_information26             in     varchar2 default hr_api.g_varchar2
  ,p_pei_information27             in     varchar2 default hr_api.g_varchar2
  ,p_pei_information28             in     varchar2 default hr_api.g_varchar2
  ,p_pei_information29             in     varchar2 default hr_api.g_varchar2
  ,p_pei_information30             in     varchar2 default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_person_extra_info >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes person extra information.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Person extra information must exist in the relevant business group.
 *
 * <p><b>Post Success</b><br>
 * Person extra information is successfully deleted.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the person extra information and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_person_extra_info_id Identifies the person extra information record
 * to be deleted.
 * @param p_object_version_number Current version number of the person extra
 * information to be deleted.
 * @rep:displayname Delete Person Extra Information
 * @rep:category BUSINESS_ENTITY HR_PERSON
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_person_extra_info
  (p_validate                      in     boolean  default false
  ,p_person_extra_info_id          in     number
  ,p_object_version_number         in     number
  );
--
end hr_person_extra_info_api;

/
