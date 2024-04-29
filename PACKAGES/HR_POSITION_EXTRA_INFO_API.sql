--------------------------------------------------------
--  DDL for Package HR_POSITION_EXTRA_INFO_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_POSITION_EXTRA_INFO_API" AUTHID CURRENT_USER as
/* $Header: pepoiapi.pkh 120.1 2005/10/02 02:21:45 aroussel $ */
/*#
 * This package contains APIs that create and maintain position extra
 * information.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Position Extra Information
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_position_extra_info >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates extra information for a given position.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Position and position information type must already exist
 *
 * <p><b>Post Success</b><br>
 * Position extra info is created.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the position extra information and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_position_id Uniquely identifies the position to which the extra
 * information applies.
 * @param p_information_type Information type the extra info applies to
 * @param p_poei_attribute_category This context value determines which
 * flexfield structure to use with the poei_attribute descriptive flexfield
 * segments.
 * @param p_poei_attribute1 Descriptive flexfield
 * @param p_poei_attribute2 Descriptive flexfield
 * @param p_poei_attribute3 Descriptive flexfield
 * @param p_poei_attribute4 Descriptive flexfield
 * @param p_poei_attribute5 Descriptive flexfield
 * @param p_poei_attribute6 Descriptive flexfield
 * @param p_poei_attribute7 Descriptive flexfield
 * @param p_poei_attribute8 Descriptive flexfield
 * @param p_poei_attribute9 Descriptive flexfield
 * @param p_poei_attribute10 Descriptive flexfield
 * @param p_poei_attribute11 Descriptive flexfield
 * @param p_poei_attribute12 Descriptive flexfield
 * @param p_poei_attribute13 Descriptive flexfield
 * @param p_poei_attribute14 Descriptive flexfield
 * @param p_poei_attribute15 Descriptive flexfield
 * @param p_poei_attribute16 Descriptive flexfield
 * @param p_poei_attribute17 Descriptive flexfield
 * @param p_poei_attribute18 Descriptive flexfield
 * @param p_poei_attribute19 Descriptive flexfield
 * @param p_poei_attribute20 Descriptive flexfield
 * @param p_poei_information_category This context value determines which
 * flexfield structure to use with the poei_information developer descriptive
 * flexfield segments.
 * @param p_poei_information1 Developer descriptive flexfield
 * @param p_poei_information2 Developer descriptive flexfield
 * @param p_poei_information3 Developer descriptive flexfield
 * @param p_poei_information4 Developer descriptive flexfield
 * @param p_poei_information5 Developer descriptive flexfield
 * @param p_poei_information6 Developer descriptive flexfield
 * @param p_poei_information7 Developer descriptive flexfield
 * @param p_poei_information8 Developer descriptive flexfield
 * @param p_poei_information9 Developer descriptive flexfield
 * @param p_poei_information10 Developer descriptive flexfield
 * @param p_poei_information11 Developer descriptive flexfield
 * @param p_poei_information12 Developer descriptive flexfield
 * @param p_poei_information13 Developer descriptive flexfield
 * @param p_poei_information14 Developer descriptive flexfield
 * @param p_poei_information15 Developer descriptive flexfield
 * @param p_poei_information16 Developer descriptive flexfield
 * @param p_poei_information17 Developer descriptive flexfield
 * @param p_poei_information18 Developer descriptive flexfield
 * @param p_poei_information19 Developer descriptive flexfield
 * @param p_poei_information20 Developer descriptive flexfield
 * @param p_poei_information21 Developer descriptive flexfield
 * @param p_poei_information22 Developer descriptive flexfield
 * @param p_poei_information23 Developer descriptive flexfield
 * @param p_poei_information24 Developer descriptive flexfield
 * @param p_poei_information25 Developer descriptive flexfield
 * @param p_poei_information26 Developer descriptive flexfield
 * @param p_poei_information27 Developer descriptive flexfield
 * @param p_poei_information28 Developer descriptive flexfield
 * @param p_poei_information29 Developer descriptive flexfield
 * @param p_poei_information30 Developer descriptive flexfield
 * @param p_position_extra_info_id If p_validate is false, uniquely identifies
 * the position extra information created. If p_validate is true, set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created Position Extra Information. If p_validate is
 * true, then the value will be null.
 * @rep:displayname Create Position Extra Information
 * @rep:category BUSINESS_ENTITY PER_POSITION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_position_extra_info
  (p_validate                      in     boolean  default false
  ,p_position_id                   in     number
  ,p_information_type              in     varchar2
  ,p_poei_attribute_category       in     varchar2 default null
  ,p_poei_attribute1               in     varchar2 default null
  ,p_poei_attribute2               in     varchar2 default null
  ,p_poei_attribute3               in     varchar2 default null
  ,p_poei_attribute4               in     varchar2 default null
  ,p_poei_attribute5               in     varchar2 default null
  ,p_poei_attribute6               in     varchar2 default null
  ,p_poei_attribute7               in     varchar2 default null
  ,p_poei_attribute8               in     varchar2 default null
  ,p_poei_attribute9               in     varchar2 default null
  ,p_poei_attribute10              in     varchar2 default null
  ,p_poei_attribute11              in     varchar2 default null
  ,p_poei_attribute12              in     varchar2 default null
  ,p_poei_attribute13              in     varchar2 default null
  ,p_poei_attribute14              in     varchar2 default null
  ,p_poei_attribute15              in     varchar2 default null
  ,p_poei_attribute16              in     varchar2 default null
  ,p_poei_attribute17              in     varchar2 default null
  ,p_poei_attribute18              in     varchar2 default null
  ,p_poei_attribute19              in     varchar2 default null
  ,p_poei_attribute20              in     varchar2 default null
  ,p_poei_information_category     in     varchar2 default null
  ,p_poei_information1             in     varchar2 default null
  ,p_poei_information2             in     varchar2 default null
  ,p_poei_information3             in     varchar2 default null
  ,p_poei_information4             in     varchar2 default null
  ,p_poei_information5             in     varchar2 default null
  ,p_poei_information6             in     varchar2 default null
  ,p_poei_information7             in     varchar2 default null
  ,p_poei_information8             in     varchar2 default null
  ,p_poei_information9             in     varchar2 default null
  ,p_poei_information10            in     varchar2 default null
  ,p_poei_information11            in     varchar2 default null
  ,p_poei_information12            in     varchar2 default null
  ,p_poei_information13            in     varchar2 default null
  ,p_poei_information14            in     varchar2 default null
  ,p_poei_information15            in     varchar2 default null
  ,p_poei_information16            in     varchar2 default null
  ,p_poei_information17            in     varchar2 default null
  ,p_poei_information18            in     varchar2 default null
  ,p_poei_information19            in     varchar2 default null
  ,p_poei_information20            in     varchar2 default null
  ,p_poei_information21            in     varchar2 default null
  ,p_poei_information22            in     varchar2 default null
  ,p_poei_information23            in     varchar2 default null
  ,p_poei_information24            in     varchar2 default null
  ,p_poei_information25            in     varchar2 default null
  ,p_poei_information26            in     varchar2 default null
  ,p_poei_information27            in     varchar2 default null
  ,p_poei_information28            in     varchar2 default null
  ,p_poei_information29            in     varchar2 default null
  ,p_poei_information30            in     varchar2 default null
  ,p_position_extra_info_id           out nocopy number
  ,p_object_version_number            out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_position_extra_info >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates extra information for a given position.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The position extra info as identified by the in parameter
 * p_position_extra_info_id and the in out parameter p_object_version_number
 * must already exist.
 *
 * <p><b>Post Success</b><br>
 * The position extra info is updated.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the position extra info and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_position_extra_info_id Identifies the position extra info record to
 * modify.
 * @param p_object_version_number Pass in the current version number of the
 * Position Extra Information to be updated. When the API completes if
 * p_validate is false, will be set to the new version number of the updated
 * Position Extra Information. If p_validate is true will be set to the same
 * value which was passed in.
 * @param p_poei_attribute_category This context value determines which
 * flexfield structure to use with the poei_attribute descriptive flexfield
 * segments.
 * @param p_poei_attribute1 Descriptive flexfield
 * @param p_poei_attribute2 Descriptive flexfield
 * @param p_poei_attribute3 Descriptive flexfield
 * @param p_poei_attribute4 Descriptive flexfield
 * @param p_poei_attribute5 Descriptive flexfield
 * @param p_poei_attribute6 Descriptive flexfield
 * @param p_poei_attribute7 Descriptive flexfield
 * @param p_poei_attribute8 Descriptive flexfield
 * @param p_poei_attribute9 Descriptive flexfield
 * @param p_poei_attribute10 Descriptive flexfield
 * @param p_poei_attribute11 Descriptive flexfield
 * @param p_poei_attribute12 Descriptive flexfield
 * @param p_poei_attribute13 Descriptive flexfield
 * @param p_poei_attribute14 Descriptive flexfield
 * @param p_poei_attribute15 Descriptive flexfield
 * @param p_poei_attribute16 Descriptive flexfield
 * @param p_poei_attribute17 Descriptive flexfield
 * @param p_poei_attribute18 Descriptive flexfield
 * @param p_poei_attribute19 Descriptive flexfield
 * @param p_poei_attribute20 Descriptive flexfield
 * @param p_poei_information_category This context value determines which
 * flexfield structure to use with the poei_information developer descriptive
 * flexfield segments.
 * @param p_poei_information1 Developer descriptive flexfield
 * @param p_poei_information2 Developer descriptive flexfield
 * @param p_poei_information3 Developer descriptive flexfield
 * @param p_poei_information4 Developer descriptive flexfield
 * @param p_poei_information5 Developer descriptive flexfield
 * @param p_poei_information6 Developer descriptive flexfield
 * @param p_poei_information7 Developer descriptive flexfield
 * @param p_poei_information8 Developer descriptive flexfield
 * @param p_poei_information9 Developer descriptive flexfield
 * @param p_poei_information10 Developer descriptive flexfield
 * @param p_poei_information11 Developer descriptive flexfield
 * @param p_poei_information12 Developer descriptive flexfield
 * @param p_poei_information13 Developer descriptive flexfield
 * @param p_poei_information14 Developer descriptive flexfield
 * @param p_poei_information15 Developer descriptive flexfield
 * @param p_poei_information16 Developer descriptive flexfield
 * @param p_poei_information17 Developer descriptive flexfield
 * @param p_poei_information18 Developer descriptive flexfield
 * @param p_poei_information19 Developer descriptive flexfield
 * @param p_poei_information20 Developer descriptive flexfield
 * @param p_poei_information21 Developer descriptive flexfield
 * @param p_poei_information22 Developer descriptive flexfield
 * @param p_poei_information23 Developer descriptive flexfield
 * @param p_poei_information24 Developer descriptive flexfield
 * @param p_poei_information25 Developer descriptive flexfield
 * @param p_poei_information26 Developer descriptive flexfield
 * @param p_poei_information27 Developer descriptive flexfield
 * @param p_poei_information28 Developer descriptive flexfield
 * @param p_poei_information29 Developer descriptive flexfield
 * @param p_poei_information30 Developer descriptive flexfield
 * @rep:displayname Update Position Extra Information
 * @rep:category BUSINESS_ENTITY PER_POSITION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_position_extra_info
  (p_validate                      in     boolean  default false
  ,p_position_extra_info_id        in     number
  ,p_object_version_number         in out nocopy number
  ,p_poei_attribute_category       in     varchar2 default hr_api.g_varchar2
  ,p_poei_attribute1               in     varchar2 default hr_api.g_varchar2
  ,p_poei_attribute2               in     varchar2 default hr_api.g_varchar2
  ,p_poei_attribute3               in     varchar2 default hr_api.g_varchar2
  ,p_poei_attribute4               in     varchar2 default hr_api.g_varchar2
  ,p_poei_attribute5               in     varchar2 default hr_api.g_varchar2
  ,p_poei_attribute6               in     varchar2 default hr_api.g_varchar2
  ,p_poei_attribute7               in     varchar2 default hr_api.g_varchar2
  ,p_poei_attribute8               in     varchar2 default hr_api.g_varchar2
  ,p_poei_attribute9               in     varchar2 default hr_api.g_varchar2
  ,p_poei_attribute10              in     varchar2 default hr_api.g_varchar2
  ,p_poei_attribute11              in     varchar2 default hr_api.g_varchar2
  ,p_poei_attribute12              in     varchar2 default hr_api.g_varchar2
  ,p_poei_attribute13              in     varchar2 default hr_api.g_varchar2
  ,p_poei_attribute14              in     varchar2 default hr_api.g_varchar2
  ,p_poei_attribute15              in     varchar2 default hr_api.g_varchar2
  ,p_poei_attribute16              in     varchar2 default hr_api.g_varchar2
  ,p_poei_attribute17              in     varchar2 default hr_api.g_varchar2
  ,p_poei_attribute18              in     varchar2 default hr_api.g_varchar2
  ,p_poei_attribute19              in     varchar2 default hr_api.g_varchar2
  ,p_poei_attribute20              in     varchar2 default hr_api.g_varchar2
  ,p_poei_information_category     in     varchar2 default hr_api.g_varchar2
  ,p_poei_information1             in     varchar2 default hr_api.g_varchar2
  ,p_poei_information2             in     varchar2 default hr_api.g_varchar2
  ,p_poei_information3             in     varchar2 default hr_api.g_varchar2
  ,p_poei_information4             in     varchar2 default hr_api.g_varchar2
  ,p_poei_information5             in     varchar2 default hr_api.g_varchar2
  ,p_poei_information6             in     varchar2 default hr_api.g_varchar2
  ,p_poei_information7             in     varchar2 default hr_api.g_varchar2
  ,p_poei_information8             in     varchar2 default hr_api.g_varchar2
  ,p_poei_information9             in     varchar2 default hr_api.g_varchar2
  ,p_poei_information10            in     varchar2 default hr_api.g_varchar2
  ,p_poei_information11            in     varchar2 default hr_api.g_varchar2
  ,p_poei_information12            in     varchar2 default hr_api.g_varchar2
  ,p_poei_information13            in     varchar2 default hr_api.g_varchar2
  ,p_poei_information14            in     varchar2 default hr_api.g_varchar2
  ,p_poei_information15            in     varchar2 default hr_api.g_varchar2
  ,p_poei_information16            in     varchar2 default hr_api.g_varchar2
  ,p_poei_information17            in     varchar2 default hr_api.g_varchar2
  ,p_poei_information18            in     varchar2 default hr_api.g_varchar2
  ,p_poei_information19            in     varchar2 default hr_api.g_varchar2
  ,p_poei_information20            in     varchar2 default hr_api.g_varchar2
  ,p_poei_information21            in     varchar2 default hr_api.g_varchar2
  ,p_poei_information22            in     varchar2 default hr_api.g_varchar2
  ,p_poei_information23            in     varchar2 default hr_api.g_varchar2
  ,p_poei_information24            in     varchar2 default hr_api.g_varchar2
  ,p_poei_information25            in     varchar2 default hr_api.g_varchar2
  ,p_poei_information26            in     varchar2 default hr_api.g_varchar2
  ,p_poei_information27            in     varchar2 default hr_api.g_varchar2
  ,p_poei_information28            in     varchar2 default hr_api.g_varchar2
  ,p_poei_information29            in     varchar2 default hr_api.g_varchar2
  ,p_poei_information30            in     varchar2 default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_position_extra_info >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes extra information for a given position.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The position extra info as identified by the in parameter
 * p_position_extra_info_id and the in out parameter p_object_version_number
 * must already exist.
 *
 * <p><b>Post Success</b><br>
 * The position extra info is deleted
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the position extra info and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_position_extra_info_id Uniquely identifies the position extra
 * information record to be deleted.
 * @param p_object_version_number Current version number of the Position Extra
 * Information to be deleted.
 * @rep:displayname Delete Position Extra Information
 * @rep:category BUSINESS_ENTITY PER_POSITION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_position_extra_info
  (p_validate                      in     boolean  default false
  ,p_position_extra_info_id        in     number
  ,p_object_version_number         in     number
  );
--
end hr_position_extra_info_api;

 

/
