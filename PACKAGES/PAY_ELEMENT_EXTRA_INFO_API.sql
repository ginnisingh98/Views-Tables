--------------------------------------------------------
--  DDL for Package PAY_ELEMENT_EXTRA_INFO_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ELEMENT_EXTRA_INFO_API" AUTHID CURRENT_USER as
/* $Header: pyeeiapi.pkh 120.1 2005/10/02 02:30:38 aroussel $ */
/*#
 * This package contains element extra information APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Element Extra Information
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_element_extra_info >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates extra information for a given element.
 *
 * The role of this process is to insert a fully validated row into the
 * pay_element_type_extra_info table of the HR schema
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The element type must already exist. Element information types must already
 * exist.
 *
 * <p><b>Post Success</b><br>
 * The element extra information will be successfully inserted into the
 * database.
 *
 * <p><b>Post Failure</b><br>
 * The element extra information will not be created and an error will be
 * raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_element_type_id {@rep:casecolumn
 * PAY_ELEMENT_TYPES_F.ELEMENT_TYPE_ID}
 * @param p_information_type {@rep:casecolumn
 * PAY_ELEMENT_TYPE_EXTRA_INFO.INFORMATION_TYPE}
 * @param p_eei_attribute_category This context value determines which
 * Flexfield Structure to use with the Descriptive flexfield segments.
 * @param p_eei_attribute1 Descriptive flexfield segment.
 * @param p_eei_attribute2 Descriptive flexfield segment.
 * @param p_eei_attribute3 Descriptive flexfield segment.
 * @param p_eei_attribute4 Descriptive flexfield segment.
 * @param p_eei_attribute5 Descriptive flexfield segment.
 * @param p_eei_attribute6 Descriptive flexfield segment.
 * @param p_eei_attribute7 Descriptive flexfield segment.
 * @param p_eei_attribute8 Descriptive flexfield segment.
 * @param p_eei_attribute9 Descriptive flexfield segment.
 * @param p_eei_attribute10 Descriptive flexfield segment.
 * @param p_eei_attribute11 Descriptive flexfield segment.
 * @param p_eei_attribute12 Descriptive flexfield segment.
 * @param p_eei_attribute13 Descriptive flexfield segment.
 * @param p_eei_attribute14 Descriptive flexfield segment.
 * @param p_eei_attribute15 Descriptive flexfield segment.
 * @param p_eei_attribute16 Descriptive flexfield segment.
 * @param p_eei_attribute17 Descriptive flexfield segment.
 * @param p_eei_attribute18 Descriptive flexfield segment.
 * @param p_eei_attribute19 Descriptive flexfield segment.
 * @param p_eei_attribute20 Descriptive flexfield segment.
 * @param p_eei_information_category This context value determines which
 * Flexfield Structure to use with the Developer Descriptive flexfield
 * segments.
 * @param p_eei_information1 Developer Descriptive flexfield segment.
 * @param p_eei_information2 Developer Descriptive flexfield segment.
 * @param p_eei_information3 Developer Descriptive flexfield segment.
 * @param p_eei_information4 Developer Descriptive flexfield segment.
 * @param p_eei_information5 Developer Descriptive flexfield segment.
 * @param p_eei_information6 Developer Descriptive flexfield segment.
 * @param p_eei_information7 Developer Descriptive flexfield segment.
 * @param p_eei_information8 Developer Descriptive flexfield segment.
 * @param p_eei_information9 Developer Descriptive flexfield segment.
 * @param p_eei_information10 Developer Descriptive flexfield segment.
 * @param p_eei_information11 Developer Descriptive flexfield segment.
 * @param p_eei_information12 Developer Descriptive flexfield segment.
 * @param p_eei_information13 Developer Descriptive flexfield segment.
 * @param p_eei_information14 Developer Descriptive flexfield segment.
 * @param p_eei_information15 Developer Descriptive flexfield segment.
 * @param p_eei_information16 Developer Descriptive flexfield segment.
 * @param p_eei_information17 Developer Descriptive flexfield segment.
 * @param p_eei_information18 Developer Descriptive flexfield segment.
 * @param p_eei_information19 Developer Descriptive flexfield segment.
 * @param p_eei_information20 Developer Descriptive flexfield segment.
 * @param p_eei_information21 Developer Descriptive flexfield segment.
 * @param p_eei_information22 Developer Descriptive flexfield segment.
 * @param p_eei_information23 Developer Descriptive flexfield segment.
 * @param p_eei_information24 Developer Descriptive flexfield segment.
 * @param p_eei_information25 Developer Descriptive flexfield segment.
 * @param p_eei_information26 Developer Descriptive flexfield segment.
 * @param p_eei_information27 Developer Descriptive flexfield segment.
 * @param p_eei_information28 Developer Descriptive flexfield segment.
 * @param p_eei_information29 Developer Descriptive flexfield segment.
 * @param p_eei_information30 Developer Descriptive flexfield segment.
 * @param p_element_type_extra_info_id If p_validate is false, uniquely
 * identifies the element extra info created. If p_validate is true, set to
 * null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created element type extra information. If p_validate
 * is true, then the value will be null.
 * @rep:displayname Create Extra Information for an Element
 * @rep:category BUSINESS_ENTITY PAY_ELEMENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_element_extra_info
  (p_validate                     in     boolean  default false
  ,p_element_type_id              in     number
  ,p_information_type             in     varchar2
  ,p_eei_attribute_category       in     varchar2 default null
  ,p_eei_attribute1               in     varchar2 default null
  ,p_eei_attribute2               in     varchar2 default null
  ,p_eei_attribute3               in     varchar2 default null
  ,p_eei_attribute4               in     varchar2 default null
  ,p_eei_attribute5               in     varchar2 default null
  ,p_eei_attribute6               in     varchar2 default null
  ,p_eei_attribute7               in     varchar2 default null
  ,p_eei_attribute8               in     varchar2 default null
  ,p_eei_attribute9               in     varchar2 default null
  ,p_eei_attribute10              in     varchar2 default null
  ,p_eei_attribute11              in     varchar2 default null
  ,p_eei_attribute12              in     varchar2 default null
  ,p_eei_attribute13              in     varchar2 default null
  ,p_eei_attribute14              in     varchar2 default null
  ,p_eei_attribute15              in     varchar2 default null
  ,p_eei_attribute16              in     varchar2 default null
  ,p_eei_attribute17              in     varchar2 default null
  ,p_eei_attribute18              in     varchar2 default null
  ,p_eei_attribute19              in     varchar2 default null
  ,p_eei_attribute20              in     varchar2 default null
  ,p_eei_information_category     in     varchar2 default null
  ,p_eei_information1             in     varchar2 default null
  ,p_eei_information2             in     varchar2 default null
  ,p_eei_information3             in     varchar2 default null
  ,p_eei_information4             in     varchar2 default null
  ,p_eei_information5             in     varchar2 default null
  ,p_eei_information6             in     varchar2 default null
  ,p_eei_information7             in     varchar2 default null
  ,p_eei_information8             in     varchar2 default null
  ,p_eei_information9             in     varchar2 default null
  ,p_eei_information10            in     varchar2 default null
  ,p_eei_information11            in     varchar2 default null
  ,p_eei_information12            in     varchar2 default null
  ,p_eei_information13            in     varchar2 default null
  ,p_eei_information14            in     varchar2 default null
  ,p_eei_information15            in     varchar2 default null
  ,p_eei_information16            in     varchar2 default null
  ,p_eei_information17            in     varchar2 default null
  ,p_eei_information18            in     varchar2 default null
  ,p_eei_information19            in     varchar2 default null
  ,p_eei_information20            in     varchar2 default null
  ,p_eei_information21            in     varchar2 default null
  ,p_eei_information22            in     varchar2 default null
  ,p_eei_information23            in     varchar2 default null
  ,p_eei_information24            in     varchar2 default null
  ,p_eei_information25            in     varchar2 default null
  ,p_eei_information26            in     varchar2 default null
  ,p_eei_information27            in     varchar2 default null
  ,p_eei_information28            in     varchar2 default null
  ,p_eei_information29            in     varchar2 default null
  ,p_eei_information30            in     varchar2 default null
  ,p_element_type_extra_info_id      out nocopy number
  ,p_object_version_number           out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_element_extra_info >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates extra information for a given element.
 *
 * The role of this process is to perform a validated update of an existing row
 * in the pay_element_type_extra_info table of the HR schema.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The element extra info as identified by the in parameter
 * p_element_type_extra_info_id and the in out parameter
 * p_object_version_number must already exist.
 *
 * <p><b>Post Success</b><br>
 * The element extra information will have been successfully updated in the
 * database.
 *
 * <p><b>Post Failure</b><br>
 * The element extra information will not be updated and an error will be
 * raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_element_type_extra_info_id {@rep:casecolumn
 * PAY_ELEMENT_TYPE_EXTRA_INFO.ELEMENT_TYPE_EXTRA_INFO_ID}
 * @param p_object_version_number Pass in the current version number of the
 * element type extra information to be updated. When the API completes if
 * p_validate is false, will be set to the new version number of the updated
 * element type extra information. If p_validate is true will be set to the
 * same value which was passed in.
 * @param p_eei_attribute_category This context value determines which
 * Flexfield Structure to use with the Descriptive flexfield segments.
 * @param p_eei_attribute1 Descriptive flexfield segment.
 * @param p_eei_attribute2 Descriptive flexfield segment.
 * @param p_eei_attribute3 Descriptive flexfield segment.
 * @param p_eei_attribute4 Descriptive flexfield segment.
 * @param p_eei_attribute5 Descriptive flexfield segment.
 * @param p_eei_attribute6 Descriptive flexfield segment.
 * @param p_eei_attribute7 Descriptive flexfield segment.
 * @param p_eei_attribute8 Descriptive flexfield segment.
 * @param p_eei_attribute9 Descriptive flexfield segment.
 * @param p_eei_attribute10 Descriptive flexfield segment.
 * @param p_eei_attribute11 Descriptive flexfield segment.
 * @param p_eei_attribute12 Descriptive flexfield segment.
 * @param p_eei_attribute13 Descriptive flexfield segment.
 * @param p_eei_attribute14 Descriptive flexfield segment.
 * @param p_eei_attribute15 Descriptive flexfield segment.
 * @param p_eei_attribute16 Descriptive flexfield segment.
 * @param p_eei_attribute17 Descriptive flexfield segment.
 * @param p_eei_attribute18 Descriptive flexfield segment.
 * @param p_eei_attribute19 Descriptive flexfield segment.
 * @param p_eei_attribute20 Descriptive flexfield segment.
 * @param p_eei_information_category This context value determines which
 * Flexfield Structure to use with the Developer Descriptive flexfield
 * segments.
 * @param p_eei_information1 Developer Descriptive flexfield segment.
 * @param p_eei_information2 Developer Descriptive flexfield segment.
 * @param p_eei_information3 Developer Descriptive flexfield segment.
 * @param p_eei_information4 Developer Descriptive flexfield segment.
 * @param p_eei_information5 Developer Descriptive flexfield segment.
 * @param p_eei_information6 Developer Descriptive flexfield segment.
 * @param p_eei_information7 Developer Descriptive flexfield segment.
 * @param p_eei_information8 Developer Descriptive flexfield segment.
 * @param p_eei_information9 Developer Descriptive flexfield segment.
 * @param p_eei_information10 Developer Descriptive flexfield segment.
 * @param p_eei_information11 Developer Descriptive flexfield segment.
 * @param p_eei_information12 Developer Descriptive flexfield segment.
 * @param p_eei_information13 Developer Descriptive flexfield segment.
 * @param p_eei_information14 Developer Descriptive flexfield segment.
 * @param p_eei_information15 Developer Descriptive flexfield segment.
 * @param p_eei_information16 Developer Descriptive flexfield segment.
 * @param p_eei_information17 Developer Descriptive flexfield segment.
 * @param p_eei_information18 Developer Descriptive flexfield segment.
 * @param p_eei_information19 Developer Descriptive flexfield segment.
 * @param p_eei_information20 Developer Descriptive flexfield segment.
 * @param p_eei_information21 Developer Descriptive flexfield segment.
 * @param p_eei_information22 Developer Descriptive flexfield segment.
 * @param p_eei_information23 Developer Descriptive flexfield segment.
 * @param p_eei_information24 Developer Descriptive flexfield segment.
 * @param p_eei_information25 Developer Descriptive flexfield segment.
 * @param p_eei_information26 Developer Descriptive flexfield segment.
 * @param p_eei_information27 Developer Descriptive flexfield segment.
 * @param p_eei_information28 Developer Descriptive flexfield segment.
 * @param p_eei_information29 Developer Descriptive flexfield segment.
 * @param p_eei_information30 Developer Descriptive flexfield segment.
 * @rep:displayname Update Extra Information for an Element
 * @rep:category BUSINESS_ENTITY PAY_ELEMENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_element_extra_info
  (p_validate                     in     boolean  default false
  ,p_element_type_extra_info_id   in     number
  ,p_object_version_number        in out nocopy number
  ,p_eei_attribute_category       in     varchar2 default hr_api.g_varchar2
  ,p_eei_attribute1               in     varchar2 default hr_api.g_varchar2
  ,p_eei_attribute2               in     varchar2 default hr_api.g_varchar2
  ,p_eei_attribute3               in     varchar2 default hr_api.g_varchar2
  ,p_eei_attribute4               in     varchar2 default hr_api.g_varchar2
  ,p_eei_attribute5               in     varchar2 default hr_api.g_varchar2
  ,p_eei_attribute6               in     varchar2 default hr_api.g_varchar2
  ,p_eei_attribute7               in     varchar2 default hr_api.g_varchar2
  ,p_eei_attribute8               in     varchar2 default hr_api.g_varchar2
  ,p_eei_attribute9               in     varchar2 default hr_api.g_varchar2
  ,p_eei_attribute10              in     varchar2 default hr_api.g_varchar2
  ,p_eei_attribute11              in     varchar2 default hr_api.g_varchar2
  ,p_eei_attribute12              in     varchar2 default hr_api.g_varchar2
  ,p_eei_attribute13              in     varchar2 default hr_api.g_varchar2
  ,p_eei_attribute14              in     varchar2 default hr_api.g_varchar2
  ,p_eei_attribute15              in     varchar2 default hr_api.g_varchar2
  ,p_eei_attribute16              in     varchar2 default hr_api.g_varchar2
  ,p_eei_attribute17              in     varchar2 default hr_api.g_varchar2
  ,p_eei_attribute18              in     varchar2 default hr_api.g_varchar2
  ,p_eei_attribute19              in     varchar2 default hr_api.g_varchar2
  ,p_eei_attribute20              in     varchar2 default hr_api.g_varchar2
  ,p_eei_information_category     in     varchar2 default hr_api.g_varchar2
  ,p_eei_information1             in     varchar2 default hr_api.g_varchar2
  ,p_eei_information2             in     varchar2 default hr_api.g_varchar2
  ,p_eei_information3             in     varchar2 default hr_api.g_varchar2
  ,p_eei_information4             in     varchar2 default hr_api.g_varchar2
  ,p_eei_information5             in     varchar2 default hr_api.g_varchar2
  ,p_eei_information6             in     varchar2 default hr_api.g_varchar2
  ,p_eei_information7             in     varchar2 default hr_api.g_varchar2
  ,p_eei_information8             in     varchar2 default hr_api.g_varchar2
  ,p_eei_information9             in     varchar2 default hr_api.g_varchar2
  ,p_eei_information10            in     varchar2 default hr_api.g_varchar2
  ,p_eei_information11            in     varchar2 default hr_api.g_varchar2
  ,p_eei_information12            in     varchar2 default hr_api.g_varchar2
  ,p_eei_information13            in     varchar2 default hr_api.g_varchar2
  ,p_eei_information14            in     varchar2 default hr_api.g_varchar2
  ,p_eei_information15            in     varchar2 default hr_api.g_varchar2
  ,p_eei_information16            in     varchar2 default hr_api.g_varchar2
  ,p_eei_information17            in     varchar2 default hr_api.g_varchar2
  ,p_eei_information18            in     varchar2 default hr_api.g_varchar2
  ,p_eei_information19            in     varchar2 default hr_api.g_varchar2
  ,p_eei_information20            in     varchar2 default hr_api.g_varchar2
  ,p_eei_information21            in     varchar2 default hr_api.g_varchar2
  ,p_eei_information22            in     varchar2 default hr_api.g_varchar2
  ,p_eei_information23            in     varchar2 default hr_api.g_varchar2
  ,p_eei_information24            in     varchar2 default hr_api.g_varchar2
  ,p_eei_information25            in     varchar2 default hr_api.g_varchar2
  ,p_eei_information26            in     varchar2 default hr_api.g_varchar2
  ,p_eei_information27            in     varchar2 default hr_api.g_varchar2
  ,p_eei_information28            in     varchar2 default hr_api.g_varchar2
  ,p_eei_information29            in     varchar2 default hr_api.g_varchar2
  ,p_eei_information30            in     varchar2 default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_element_extra_info >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes extra information for a given element.
 *
 * The role of this process is to perform a validated delete of an existing row
 * in the pay_element_type_extra_info table of the HR schema.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The element extra info as identified by the in parameter
 * p_element_type_extra_info_id and the in out parameter
 * p_object_version_number must already exist.
 *
 * <p><b>Post Success</b><br>
 * The element extra information will have been successfully removed from the
 * database.
 *
 * <p><b>Post Failure</b><br>
 * The element extra information will not be deleted and an error will be
 * raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_element_type_extra_info_id {@rep:casecolumn
 * PAY_ELEMENT_TYPE_EXTRA_INFO.ELEMENT_TYPE_EXTRA_INFO_ID}
 * @param p_object_version_number Pass in the current version number of the
 * element type extra information to be deleted. When the API completes if
 * p_validate is false, will be set to the new version number of the deleted
 * element type extra information. If p_validate is true will be set to the
 * same value which was passed in.
 * @rep:displayname Delete Extra Information for an Element
 * @rep:category BUSINESS_ENTITY PAY_ELEMENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_element_extra_info
  (p_validate                      in     boolean  default false
  ,p_element_type_extra_info_id    in     number
  ,p_object_version_number         in     number
  );
--
end pay_element_extra_info_api;

 

/
