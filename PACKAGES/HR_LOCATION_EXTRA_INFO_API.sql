--------------------------------------------------------
--  DDL for Package HR_LOCATION_EXTRA_INFO_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_LOCATION_EXTRA_INFO_API" AUTHID CURRENT_USER as
/* $Header: hrleiapi.pkh 120.1 2005/10/02 02:03:25 aroussel $ */
/*#
 * This package contains APIs to maintain location extra information records.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Location Extra Information
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_location_extra_info >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a location extra information record.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The location must exist. The location extra information type must exist.
 *
 * <p><b>Post Success</b><br>
 * The location extra information is created.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the location extra information record and raises an
 * error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_location_id Uniquely identifies the location with which to
 * associate the extra information record.
 * @param p_information_type Location extra information type.
 * @param p_lei_attribute_category This context value determines which
 * Flexfield Structure to use with the Descriptive flexfield segments.
 * @param p_lei_attribute1 Descriptive flexfield segment.
 * @param p_lei_attribute2 Descriptive flexfield segment.
 * @param p_lei_attribute3 Descriptive flexfield segment.
 * @param p_lei_attribute4 Descriptive flexfield segment.
 * @param p_lei_attribute5 Descriptive flexfield segment.
 * @param p_lei_attribute6 Descriptive flexfield segment.
 * @param p_lei_attribute7 Descriptive flexfield segment.
 * @param p_lei_attribute8 Descriptive flexfield segment.
 * @param p_lei_attribute9 Descriptive flexfield segment.
 * @param p_lei_attribute10 Descriptive flexfield segment.
 * @param p_lei_attribute11 Descriptive flexfield segment.
 * @param p_lei_attribute12 Descriptive flexfield segment.
 * @param p_lei_attribute13 Descriptive flexfield segment.
 * @param p_lei_attribute14 Descriptive flexfield segment.
 * @param p_lei_attribute15 Descriptive flexfield segment.
 * @param p_lei_attribute16 Descriptive flexfield segment.
 * @param p_lei_attribute17 Descriptive flexfield segment.
 * @param p_lei_attribute18 Descriptive flexfield segment.
 * @param p_lei_attribute19 Descriptive flexfield segment.
 * @param p_lei_attribute20 Descriptive flexfield segment.
 * @param p_lei_information_category This context value determines which
 * Flexfield Structure to use with the Developer Descriptive flexfield
 * segments.
 * @param p_lei_information1 Developer descriptive flexfield segment.
 * @param p_lei_information2 Developer descriptive flexfield segment.
 * @param p_lei_information3 Developer descriptive flexfield segment.
 * @param p_lei_information4 Developer descriptive flexfield segment.
 * @param p_lei_information5 Developer descriptive flexfield segment.
 * @param p_lei_information6 Developer descriptive flexfield segment.
 * @param p_lei_information7 Developer descriptive flexfield segment.
 * @param p_lei_information8 Developer descriptive flexfield segment.
 * @param p_lei_information9 Developer descriptive flexfield segment.
 * @param p_lei_information10 Developer descriptive flexfield segment.
 * @param p_lei_information11 Developer descriptive flexfield segment.
 * @param p_lei_information12 Developer descriptive flexfield segment.
 * @param p_lei_information13 Developer descriptive flexfield segment.
 * @param p_lei_information14 Developer descriptive flexfield segment.
 * @param p_lei_information15 Developer descriptive flexfield segment.
 * @param p_lei_information16 Developer descriptive flexfield segment.
 * @param p_lei_information17 Developer descriptive flexfield segment.
 * @param p_lei_information18 Developer descriptive flexfield segment.
 * @param p_lei_information19 Developer descriptive flexfield segment.
 * @param p_lei_information20 Developer descriptive flexfield segment.
 * @param p_lei_information21 Developer descriptive flexfield segment.
 * @param p_lei_information22 Developer descriptive flexfield segment.
 * @param p_lei_information23 Developer descriptive flexfield segment.
 * @param p_lei_information24 Developer descriptive flexfield segment.
 * @param p_lei_information25 Developer descriptive flexfield segment.
 * @param p_lei_information26 Developer descriptive flexfield segment.
 * @param p_lei_information27 Developer descriptive flexfield segment.
 * @param p_lei_information28 Developer descriptive flexfield segment.
 * @param p_lei_information29 Developer descriptive flexfield segment.
 * @param p_lei_information30 Developer descriptive flexfield segment.
 * @param p_location_extra_info_id If p_validate is false, uniquely identifies
 * the location extra information record created. If p_validate is true, set to
 * null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created location extra information record. If
 * p_validate is true, then the value will be null.
 * @rep:displayname Create Location Extra Information
 * @rep:category BUSINESS_ENTITY HR_LOCATION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_location_extra_info
  (p_validate                      in     boolean  default false
  ,p_location_id                   in     number
  ,p_information_type              in     varchar2
  ,p_lei_attribute_category       in     varchar2 default null
  ,p_lei_attribute1               in     varchar2 default null
  ,p_lei_attribute2               in     varchar2 default null
  ,p_lei_attribute3               in     varchar2 default null
  ,p_lei_attribute4               in     varchar2 default null
  ,p_lei_attribute5               in     varchar2 default null
  ,p_lei_attribute6               in     varchar2 default null
  ,p_lei_attribute7               in     varchar2 default null
  ,p_lei_attribute8               in     varchar2 default null
  ,p_lei_attribute9               in     varchar2 default null
  ,p_lei_attribute10              in     varchar2 default null
  ,p_lei_attribute11              in     varchar2 default null
  ,p_lei_attribute12              in     varchar2 default null
  ,p_lei_attribute13              in     varchar2 default null
  ,p_lei_attribute14              in     varchar2 default null
  ,p_lei_attribute15              in     varchar2 default null
  ,p_lei_attribute16              in     varchar2 default null
  ,p_lei_attribute17              in     varchar2 default null
  ,p_lei_attribute18              in     varchar2 default null
  ,p_lei_attribute19              in     varchar2 default null
  ,p_lei_attribute20              in     varchar2 default null
  ,p_lei_information_category     in     varchar2 default null
  ,p_lei_information1             in     varchar2 default null
  ,p_lei_information2             in     varchar2 default null
  ,p_lei_information3             in     varchar2 default null
  ,p_lei_information4             in     varchar2 default null
  ,p_lei_information5             in     varchar2 default null
  ,p_lei_information6             in     varchar2 default null
  ,p_lei_information7             in     varchar2 default null
  ,p_lei_information8             in     varchar2 default null
  ,p_lei_information9             in     varchar2 default null
  ,p_lei_information10            in     varchar2 default null
  ,p_lei_information11            in     varchar2 default null
  ,p_lei_information12            in     varchar2 default null
  ,p_lei_information13            in     varchar2 default null
  ,p_lei_information14            in     varchar2 default null
  ,p_lei_information15            in     varchar2 default null
  ,p_lei_information16            in     varchar2 default null
  ,p_lei_information17            in     varchar2 default null
  ,p_lei_information18            in     varchar2 default null
  ,p_lei_information19            in     varchar2 default null
  ,p_lei_information20            in     varchar2 default null
  ,p_lei_information21            in     varchar2 default null
  ,p_lei_information22            in     varchar2 default null
  ,p_lei_information23            in     varchar2 default null
  ,p_lei_information24            in     varchar2 default null
  ,p_lei_information25            in     varchar2 default null
  ,p_lei_information26            in     varchar2 default null
  ,p_lei_information27            in     varchar2 default null
  ,p_lei_information28            in     varchar2 default null
  ,p_lei_information29            in     varchar2 default null
  ,p_lei_information30            in     varchar2 default null
  ,p_location_extra_info_id           out nocopy number
  ,p_object_version_number            out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_location_extra_info >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates location extra information associated with a location.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The location extra information record must exist.
 *
 * <p><b>Post Success</b><br>
 * The location extra information record is updated.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the location extra information record and raises an
 * error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_location_extra_info_id Identifies the location extra information
 * record to update.
 * @param p_object_version_number Pass in the current version number of the
 * location extra information record to be updated. When the API completes if
 * p_validate is false, will be set to the new version number of the updated
 * location extra information record. If p_validate is true will be set to the
 * same value which was passed in.
 * @param p_lei_attribute_category This context value determines which
 * Flexfield Structure to use with the Descriptive flexfield segments.
 * @param p_lei_attribute1 Descriptive flexfield segment.
 * @param p_lei_attribute2 Descriptive flexfield segment.
 * @param p_lei_attribute3 Descriptive flexfield segment.
 * @param p_lei_attribute4 Descriptive flexfield segment.
 * @param p_lei_attribute5 Descriptive flexfield segment.
 * @param p_lei_attribute6 Descriptive flexfield segment.
 * @param p_lei_attribute7 Descriptive flexfield segment.
 * @param p_lei_attribute8 Descriptive flexfield segment.
 * @param p_lei_attribute9 Descriptive flexfield segment.
 * @param p_lei_attribute10 Descriptive flexfield segment.
 * @param p_lei_attribute11 Descriptive flexfield segment.
 * @param p_lei_attribute12 Descriptive flexfield segment.
 * @param p_lei_attribute13 Descriptive flexfield segment.
 * @param p_lei_attribute14 Descriptive flexfield segment.
 * @param p_lei_attribute15 Descriptive flexfield segment.
 * @param p_lei_attribute16 Descriptive flexfield segment.
 * @param p_lei_attribute17 Descriptive flexfield segment.
 * @param p_lei_attribute18 Descriptive flexfield segment.
 * @param p_lei_attribute19 Descriptive flexfield segment.
 * @param p_lei_attribute20 Descriptive flexfield segment.
 * @param p_lei_information_category This context value determines which
 * Flexfield Structure to use with the Developer Descriptive flexfield
 * segments.
 * @param p_lei_information1 Developer descriptive flexfield segment.
 * @param p_lei_information2 Developer descriptive flexfield segment.
 * @param p_lei_information3 Developer descriptive flexfield segment.
 * @param p_lei_information4 Developer descriptive flexfield segment.
 * @param p_lei_information5 Developer descriptive flexfield segment.
 * @param p_lei_information6 Developer descriptive flexfield segment.
 * @param p_lei_information7 Developer descriptive flexfield segment.
 * @param p_lei_information8 Developer descriptive flexfield segment.
 * @param p_lei_information9 Developer descriptive flexfield segment.
 * @param p_lei_information10 Developer descriptive flexfield segment.
 * @param p_lei_information11 Developer descriptive flexfield segment.
 * @param p_lei_information12 Developer descriptive flexfield segment.
 * @param p_lei_information13 Developer descriptive flexfield segment.
 * @param p_lei_information14 Developer descriptive flexfield segment.
 * @param p_lei_information15 Developer descriptive flexfield segment.
 * @param p_lei_information16 Developer descriptive flexfield segment.
 * @param p_lei_information17 Developer descriptive flexfield segment.
 * @param p_lei_information18 Developer descriptive flexfield segment.
 * @param p_lei_information19 Developer descriptive flexfield segment.
 * @param p_lei_information20 Developer descriptive flexfield segment.
 * @param p_lei_information21 Developer descriptive flexfield segment.
 * @param p_lei_information22 Developer descriptive flexfield segment.
 * @param p_lei_information23 Developer descriptive flexfield segment.
 * @param p_lei_information24 Developer descriptive flexfield segment.
 * @param p_lei_information25 Developer descriptive flexfield segment.
 * @param p_lei_information26 Developer descriptive flexfield segment.
 * @param p_lei_information27 Developer descriptive flexfield segment.
 * @param p_lei_information28 Developer descriptive flexfield segment.
 * @param p_lei_information29 Developer descriptive flexfield segment.
 * @param p_lei_information30 Developer descriptive flexfield segment.
 * @rep:displayname Update Location Extra Information
 * @rep:category BUSINESS_ENTITY HR_LOCATION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_location_extra_info
  (p_validate                      in     boolean  default false
  ,p_location_extra_info_id        in     number
  ,p_object_version_number         in out nocopy number
  ,p_lei_attribute_category       in     varchar2 default hr_api.g_varchar2
  ,p_lei_attribute1               in     varchar2 default hr_api.g_varchar2
  ,p_lei_attribute2               in     varchar2 default hr_api.g_varchar2
  ,p_lei_attribute3               in     varchar2 default hr_api.g_varchar2
  ,p_lei_attribute4               in     varchar2 default hr_api.g_varchar2
  ,p_lei_attribute5               in     varchar2 default hr_api.g_varchar2
  ,p_lei_attribute6               in     varchar2 default hr_api.g_varchar2
  ,p_lei_attribute7               in     varchar2 default hr_api.g_varchar2
  ,p_lei_attribute8               in     varchar2 default hr_api.g_varchar2
  ,p_lei_attribute9               in     varchar2 default hr_api.g_varchar2
  ,p_lei_attribute10              in     varchar2 default hr_api.g_varchar2
  ,p_lei_attribute11              in     varchar2 default hr_api.g_varchar2
  ,p_lei_attribute12              in     varchar2 default hr_api.g_varchar2
  ,p_lei_attribute13              in     varchar2 default hr_api.g_varchar2
  ,p_lei_attribute14              in     varchar2 default hr_api.g_varchar2
  ,p_lei_attribute15              in     varchar2 default hr_api.g_varchar2
  ,p_lei_attribute16              in     varchar2 default hr_api.g_varchar2
  ,p_lei_attribute17              in     varchar2 default hr_api.g_varchar2
  ,p_lei_attribute18              in     varchar2 default hr_api.g_varchar2
  ,p_lei_attribute19              in     varchar2 default hr_api.g_varchar2
  ,p_lei_attribute20              in     varchar2 default hr_api.g_varchar2
  ,p_lei_information_category     in     varchar2 default hr_api.g_varchar2
  ,p_lei_information1             in     varchar2 default hr_api.g_varchar2
  ,p_lei_information2             in     varchar2 default hr_api.g_varchar2
  ,p_lei_information3             in     varchar2 default hr_api.g_varchar2
  ,p_lei_information4             in     varchar2 default hr_api.g_varchar2
  ,p_lei_information5             in     varchar2 default hr_api.g_varchar2
  ,p_lei_information6             in     varchar2 default hr_api.g_varchar2
  ,p_lei_information7             in     varchar2 default hr_api.g_varchar2
  ,p_lei_information8             in     varchar2 default hr_api.g_varchar2
  ,p_lei_information9             in     varchar2 default hr_api.g_varchar2
  ,p_lei_information10            in     varchar2 default hr_api.g_varchar2
  ,p_lei_information11            in     varchar2 default hr_api.g_varchar2
  ,p_lei_information12            in     varchar2 default hr_api.g_varchar2
  ,p_lei_information13            in     varchar2 default hr_api.g_varchar2
  ,p_lei_information14            in     varchar2 default hr_api.g_varchar2
  ,p_lei_information15            in     varchar2 default hr_api.g_varchar2
  ,p_lei_information16            in     varchar2 default hr_api.g_varchar2
  ,p_lei_information17            in     varchar2 default hr_api.g_varchar2
  ,p_lei_information18            in     varchar2 default hr_api.g_varchar2
  ,p_lei_information19            in     varchar2 default hr_api.g_varchar2
  ,p_lei_information20            in     varchar2 default hr_api.g_varchar2
  ,p_lei_information21            in     varchar2 default hr_api.g_varchar2
  ,p_lei_information22            in     varchar2 default hr_api.g_varchar2
  ,p_lei_information23            in     varchar2 default hr_api.g_varchar2
  ,p_lei_information24            in     varchar2 default hr_api.g_varchar2
  ,p_lei_information25            in     varchar2 default hr_api.g_varchar2
  ,p_lei_information26            in     varchar2 default hr_api.g_varchar2
  ,p_lei_information27            in     varchar2 default hr_api.g_varchar2
  ,p_lei_information28            in     varchar2 default hr_api.g_varchar2
  ,p_lei_information29            in     varchar2 default hr_api.g_varchar2
  ,p_lei_information30            in     varchar2 default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_location_extra_info >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a location extra information record.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The location extra information record must exist.
 *
 * <p><b>Post Success</b><br>
 * The location extra information record is deleted.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the location extra information record, and raises an
 * error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_location_extra_info_id Identifies the location extra information
 * record to delete.
 * @param p_object_version_number Current version number of the location extra
 * information record to be deleted.
 * @rep:displayname Delete Location Extra Information
 * @rep:category BUSINESS_ENTITY HR_LOCATION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_location_extra_info
  (p_validate                      in     boolean  default false
  ,p_location_extra_info_id        in     number
  ,p_object_version_number         in     number
  );
--
end hr_location_extra_info_api;

 

/
