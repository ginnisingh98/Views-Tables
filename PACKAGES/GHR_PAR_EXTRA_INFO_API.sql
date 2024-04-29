--------------------------------------------------------
--  DDL for Package GHR_PAR_EXTRA_INFO_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_PAR_EXTRA_INFO_API" AUTHID CURRENT_USER as
/* $Header: ghreiapi.pkh 120.9.12000000.1 2007/01/18 14:10:48 appldev noship $ */
/*#
 * This package contains the procedures for creating, updating, and deleting
 * Extra Information for a Request for Personnel Action (RPA) request.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Request for Personnel Action Extra Information
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_pa_request_extra_info >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates Extra Information for a given Request for Personnel Action
 * (RPA).
 *
 * This API creates US Federal Extra Information types for a given Request for
 * Personnel Action (RPA) which is determined by the Nature of Action Code
 * (NOAC) entered on the RPA.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Request for Personnel Action (RPA) must exist. Request for Personnel Action
 * (RPA) Information Type must already exist.
 *
 * <p><b>Post Success</b><br>
 * The API creates the Request for Personnel Action (RPA) Extra Information
 * record in the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the Request for Personnel Action (RPA) Extra
 * Information and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_pa_request_id The Extra Information applies to this Request for
 * Personnel Action (RPA).
 * @param p_information_type Extra Information applies to this Information
 * Type.
 * @param p_rei_attribute_category Determines context of the rei_attribute
 * descriptive flexfield in parameters.
 * @param p_rei_attribute1 Descriptive flexfield
 * @param p_rei_attribute2 Descriptive flexfield
 * @param p_rei_attribute3 Descriptive flexfield
 * @param p_rei_attribute4 Descriptive flexfield
 * @param p_rei_attribute5 Descriptive flexfield
 * @param p_rei_attribute6 Descriptive flexfield
 * @param p_rei_attribute7 Descriptive flexfield
 * @param p_rei_attribute8 Descriptive flexfield
 * @param p_rei_attribute9 Descriptive flexfield
 * @param p_rei_attribute10 Descriptive flexfield
 * @param p_rei_attribute11 Descriptive flexfield
 * @param p_rei_attribute12 Descriptive flexfield
 * @param p_rei_attribute13 Descriptive flexfield
 * @param p_rei_attribute14 Descriptive flexfield
 * @param p_rei_attribute15 Descriptive flexfield
 * @param p_rei_attribute16 Descriptive flexfield
 * @param p_rei_attribute17 Descriptive flexfield
 * @param p_rei_attribute18 Descriptive flexfield
 * @param p_rei_attribute19 Descriptive flexfield
 * @param p_rei_attribute20 Descriptive flexfield
 * @param p_rei_information_category Determines context of the rei_attribute
 * developer descriptive flexfield in parameters.
 * @param p_rei_information1 Developer descriptive flexfield
 * @param p_rei_information2 Developer descriptive flexfield
 * @param p_rei_information3 Developer descriptive flexfield
 * @param p_rei_information4 Developer descriptive flexfield
 * @param p_rei_information5 Developer descriptive flexfield
 * @param p_rei_information6 Developer descriptive flexfield
 * @param p_rei_information7 Developer descriptive flexfield
 * @param p_rei_information8 Developer descriptive flexfield
 * @param p_rei_information9 Developer descriptive flexfield
 * @param p_rei_information10 Developer descriptive flexfield
 * @param p_rei_information11 Developer descriptive flexfield
 * @param p_rei_information12 Developer descriptive flexfield
 * @param p_rei_information13 Developer descriptive flexfield
 * @param p_rei_information14 Developer descriptive flexfield
 * @param p_rei_information15 Developer descriptive flexfield
 * @param p_rei_information16 Developer descriptive flexfield
 * @param p_rei_information17 Developer descriptive flexfield
 * @param p_rei_information18 Developer descriptive flexfield
 * @param p_rei_information19 Developer descriptive flexfield
 * @param p_rei_information20 Developer descriptive flexfield
 * @param p_rei_information21 Developer descriptive flexfield
 * @param p_rei_information22 Developer descriptive flexfield
 * @param p_rei_information23 Developer descriptive flexfield
 * @param p_rei_information24 Developer descriptive flexfield
 * @param p_rei_information25 Developer descriptive flexfield
 * @param p_rei_information26 Developer descriptive flexfield
 * @param p_rei_information27 Developer descriptive flexfield
 * @param p_rei_information28 Developer descriptive flexfield
 * @param p_rei_information29 Developer descriptive flexfield
 * @param p_rei_information30 Developer descriptive flexfield
 * @param p_pa_request_extra_info_id If p_validate is false, this parameter
 * uniquely identifies the Request for Personnel Action (RPA) Extra Information
 * created. If p_validate is true, sets null.
 * @param p_object_version_number If p_validate is false will be set to the
 * version number of the created Request for Personnel Action (RPA) id. If
 * p_validate is true, then the value will be null.
 * @param p_ben_ei_validate If true, then validate the US Fed Benefits EIT
 * changes, otherwise if false, do not validate the US Fed Benefits
 * EIT changes.
 * @rep:displayname Create Request for Personnel Action Extra Information
 * @rep:category BUSINESS_ENTITY GHR_REQ_FOR_PERSONNEL_ACTION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_pa_request_extra_info
  (p_validate                     in     boolean  default false
  ,p_pa_request_id                       in     number
  ,p_information_type             in     varchar2
  ,p_rei_attribute_category       in     varchar2 default null
  ,p_rei_attribute1               in     varchar2 default null
  ,p_rei_attribute2               in     varchar2 default null
  ,p_rei_attribute3               in     varchar2 default null
  ,p_rei_attribute4               in     varchar2 default null
  ,p_rei_attribute5               in     varchar2 default null
  ,p_rei_attribute6               in     varchar2 default null
  ,p_rei_attribute7               in     varchar2 default null
  ,p_rei_attribute8               in     varchar2 default null
  ,p_rei_attribute9               in     varchar2 default null
  ,p_rei_attribute10              in     varchar2 default null
  ,p_rei_attribute11              in     varchar2 default null
  ,p_rei_attribute12              in     varchar2 default null
  ,p_rei_attribute13              in     varchar2 default null
  ,p_rei_attribute14              in     varchar2 default null
  ,p_rei_attribute15              in     varchar2 default null
  ,p_rei_attribute16              in     varchar2 default null
  ,p_rei_attribute17              in     varchar2 default null
  ,p_rei_attribute18              in     varchar2 default null
  ,p_rei_attribute19              in     varchar2 default null
  ,p_rei_attribute20              in     varchar2 default null
  ,p_rei_information_category     in     varchar2 default null
  ,p_rei_information1             in     varchar2 default null
  ,p_rei_information2             in     varchar2 default null
  ,p_rei_information3             in     varchar2 default null
  ,p_rei_information4             in     varchar2 default null
  ,p_rei_information5             in     varchar2 default null
  ,p_rei_information6             in     varchar2 default null
  ,p_rei_information7             in     varchar2 default null
  ,p_rei_information8             in     varchar2 default null
  ,p_rei_information9             in     varchar2 default null
  ,p_rei_information10            in     varchar2 default null
  ,p_rei_information11            in     varchar2 default null
  ,p_rei_information12            in     varchar2 default null
  ,p_rei_information13            in     varchar2 default null
  ,p_rei_information14            in     varchar2 default null
  ,p_rei_information15            in     varchar2 default null
  ,p_rei_information16            in     varchar2 default null
  ,p_rei_information17            in     varchar2 default null
  ,p_rei_information18            in     varchar2 default null
  ,p_rei_information19            in     varchar2 default null
  ,p_rei_information20            in     varchar2 default null
  ,p_rei_information21            in     varchar2 default null
  ,p_rei_information22            in     varchar2 default null
  ,p_rei_information23            in     varchar2 default null
  ,p_rei_information24            in     varchar2 default null
  ,p_rei_information25            in     varchar2 default null
  ,p_rei_information26            in     varchar2 default null
  ,p_rei_information27            in     varchar2 default null
  ,p_rei_information28            in     varchar2 default null
  ,p_rei_information29            in     varchar2 default null
  ,p_rei_information30            in     varchar2 default null
  ,p_pa_request_extra_info_id     out    NOCOPY number
  ,p_object_version_number        out    NOCOPY number
  ,p_ben_ei_validate			  in     varchar2 default 'FALSE'
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_pa_request_extra_info >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates Extra Information for a given Request for Personnel Action
 * (RPA).
 *
 * This API updates Extra Information for a given Request for Personnel Action
 * (RPA) as identified by the parameters p_pa_request_extra_info_id and
 * p_object_version_number.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The Request for Personnel Action (RPA) Extra Information must exist. The
 * Request for Personnel Action (RPA) Extra Information is identified by the
 * parameters p_pa_request_extra_info_id and p_object_version_number.
 *
 * <p><b>Post Success</b><br>
 * The API updates the Request for Personnel Action (RPA) Extra Information
 * record in the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the Request for Personnel Action (RPA) Extra
 * Information record and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_pa_request_extra_info_id Uniquely identifies the Request for
 * Personnel Action (RPA) Extra Information record.
 * @param p_object_version_number Pass in the current version number of the
 * Personnel Action Request id to be updated. When the API completes if
 * p_validate is false, will be set to the new version number of the updated
 * Personnel Action Request id. If p_validate is true will be set to the same
 * value which was passed in.
 * @param p_rei_attribute_category Determines context of the rei_attribute
 * descriptive flexfield in parameters
 * @param p_rei_attribute1 Descriptive flexfield
 * @param p_rei_attribute2 Descriptive flexfield
 * @param p_rei_attribute3 Descriptive flexfield
 * @param p_rei_attribute4 Descriptive flexfield
 * @param p_rei_attribute5 Descriptive flexfield
 * @param p_rei_attribute6 Descriptive flexfield
 * @param p_rei_attribute7 Descriptive flexfield
 * @param p_rei_attribute8 Descriptive flexfield
 * @param p_rei_attribute9 Descriptive flexfield
 * @param p_rei_attribute10 Descriptive flexfield
 * @param p_rei_attribute11 Descriptive flexfield
 * @param p_rei_attribute12 Descriptive flexfield
 * @param p_rei_attribute13 Descriptive flexfield
 * @param p_rei_attribute14 Descriptive flexfield
 * @param p_rei_attribute15 Descriptive flexfield
 * @param p_rei_attribute16 Descriptive flexfield
 * @param p_rei_attribute17 Descriptive flexfield
 * @param p_rei_attribute18 Descriptive flexfield
 * @param p_rei_attribute19 Descriptive flexfield
 * @param p_rei_attribute20 Descriptive flexfield
 * @param p_rei_information_category Determines context of the rei_attribute
 * developer descriptive flexfield in parameters
 * @param p_rei_information1 Developer descriptive flexfield
 * @param p_rei_information2 Developer descriptive flexfield
 * @param p_rei_information3 Developer descriptive flexfield
 * @param p_rei_information4 Developer descriptive flexfield
 * @param p_rei_information5 Developer descriptive flexfield
 * @param p_rei_information6 Developer descriptive flexfield
 * @param p_rei_information7 Developer descriptive flexfield
 * @param p_rei_information8 Developer descriptive flexfield
 * @param p_rei_information9 Developer descriptive flexfield
 * @param p_rei_information10 Developer descriptive flexfield
 * @param p_rei_information11 Developer descriptive flexfield
 * @param p_rei_information12 Developer descriptive flexfield
 * @param p_rei_information13 Developer descriptive flexfield
 * @param p_rei_information14 Developer descriptive flexfield
 * @param p_rei_information15 Developer descriptive flexfield
 * @param p_rei_information16 Developer descriptive flexfield
 * @param p_rei_information17 Developer descriptive flexfield
 * @param p_rei_information18 Developer descriptive flexfield
 * @param p_rei_information19 Developer descriptive flexfield
 * @param p_rei_information20 Developer descriptive flexfield
 * @param p_rei_information21 Developer descriptive flexfield
 * @param p_rei_information22 Developer descriptive flexfield
 * @param p_rei_information23 Developer descriptive flexfield
 * @param p_rei_information24 Developer descriptive flexfield
 * @param p_rei_information25 Developer descriptive flexfield
 * @param p_rei_information26 Developer descriptive flexfield
 * @param p_rei_information27 Developer descriptive flexfield
 * @param p_rei_information28 Developer descriptive flexfield
 * @param p_rei_information29 Developer descriptive flexfield
 * @param p_rei_information30 Developer descriptive flexfield
 * @param p_ben_ei_validate If true, then validate the US Fed Benefits EIT
 * changes, otherwise if false, do not validate the US Fed Benefits
 * EIT changes.
 * @rep:displayname Update Request for Personnel Action Extra Information
 * @rep:category BUSINESS_ENTITY GHR_REQ_FOR_PERSONNEL_ACTION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_pa_request_extra_info
  (p_validate                     in     boolean  default false
  ,p_pa_request_extra_info_id            in     number
  ,p_object_version_number        in out NOCOPY number
  ,p_rei_attribute_category       in     varchar2 default hr_api.g_varchar2
  ,p_rei_attribute1               in     varchar2 default hr_api.g_varchar2
  ,p_rei_attribute2               in     varchar2 default hr_api.g_varchar2
  ,p_rei_attribute3               in     varchar2 default hr_api.g_varchar2
  ,p_rei_attribute4               in     varchar2 default hr_api.g_varchar2
  ,p_rei_attribute5               in     varchar2 default hr_api.g_varchar2
  ,p_rei_attribute6               in     varchar2 default hr_api.g_varchar2
  ,p_rei_attribute7               in     varchar2 default hr_api.g_varchar2
  ,p_rei_attribute8               in     varchar2 default hr_api.g_varchar2
  ,p_rei_attribute9               in     varchar2 default hr_api.g_varchar2
  ,p_rei_attribute10              in     varchar2 default hr_api.g_varchar2
  ,p_rei_attribute11              in     varchar2 default hr_api.g_varchar2
  ,p_rei_attribute12              in     varchar2 default hr_api.g_varchar2
  ,p_rei_attribute13              in     varchar2 default hr_api.g_varchar2
  ,p_rei_attribute14              in     varchar2 default hr_api.g_varchar2
  ,p_rei_attribute15              in     varchar2 default hr_api.g_varchar2
  ,p_rei_attribute16              in     varchar2 default hr_api.g_varchar2
  ,p_rei_attribute17              in     varchar2 default hr_api.g_varchar2
  ,p_rei_attribute18              in     varchar2 default hr_api.g_varchar2
  ,p_rei_attribute19              in     varchar2 default hr_api.g_varchar2
  ,p_rei_attribute20              in     varchar2 default hr_api.g_varchar2
  ,p_rei_information_category     in     varchar2 default hr_api.g_varchar2
  ,p_rei_information1             in     varchar2 default hr_api.g_varchar2
  ,p_rei_information2             in     varchar2 default hr_api.g_varchar2
  ,p_rei_information3             in     varchar2 default hr_api.g_varchar2
  ,p_rei_information4             in     varchar2 default hr_api.g_varchar2
  ,p_rei_information5             in     varchar2 default hr_api.g_varchar2
  ,p_rei_information6             in     varchar2 default hr_api.g_varchar2
  ,p_rei_information7             in     varchar2 default hr_api.g_varchar2
  ,p_rei_information8             in     varchar2 default hr_api.g_varchar2
  ,p_rei_information9             in     varchar2 default hr_api.g_varchar2
  ,p_rei_information10            in     varchar2 default hr_api.g_varchar2
  ,p_rei_information11            in     varchar2 default hr_api.g_varchar2
  ,p_rei_information12            in     varchar2 default hr_api.g_varchar2
  ,p_rei_information13            in     varchar2 default hr_api.g_varchar2
  ,p_rei_information14            in     varchar2 default hr_api.g_varchar2
  ,p_rei_information15            in     varchar2 default hr_api.g_varchar2
  ,p_rei_information16            in     varchar2 default hr_api.g_varchar2
  ,p_rei_information17            in     varchar2 default hr_api.g_varchar2
  ,p_rei_information18            in     varchar2 default hr_api.g_varchar2
  ,p_rei_information19            in     varchar2 default hr_api.g_varchar2
  ,p_rei_information20            in     varchar2 default hr_api.g_varchar2
  ,p_rei_information21            in     varchar2 default hr_api.g_varchar2
  ,p_rei_information22            in     varchar2 default hr_api.g_varchar2
  ,p_rei_information23            in     varchar2 default hr_api.g_varchar2
  ,p_rei_information24            in     varchar2 default hr_api.g_varchar2
  ,p_rei_information25            in     varchar2 default hr_api.g_varchar2
  ,p_rei_information26            in     varchar2 default hr_api.g_varchar2
  ,p_rei_information27            in     varchar2 default hr_api.g_varchar2
  ,p_rei_information28            in     varchar2 default hr_api.g_varchar2
  ,p_rei_information29            in     varchar2 default hr_api.g_varchar2
  ,p_rei_information30            in     varchar2 default hr_api.g_varchar2
  ,p_ben_ei_validate			  in     varchar2 default 'FALSE'
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_pa_request_extra_info >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes Extra Information for a given Request for Personnel Action
 * (RPA).
 *
 * This API deletes Extra Information for a given Request for Personnel Action
 * (RPA) as identified by the parameters p_pa_request_extra_info_id and
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The Request for Personnel Action (RPA) Extra Information must exist. The
 * Request for Personnel Action (RPA) Extra Information is identified by the
 * parameters p_pa_request_extra_info_id and p_object_version_number.
 *
 * <p><b>Post Success</b><br>
 * The Request for Personnel Action (RPA) Extra Information record is deleted.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the Request for Personnel Action (RPA) Extra
 * Information and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_pa_request_extra_info_id Uniquely identifies the Request for
 * Personnel Action (RPA) Extra Information record.
 * @param p_object_version_number Current version number of the Personnel
 * Action Request Extra Information record to be deleted.
 * @rep:displayname Delete Request for Personnel Action Extra Information
 * @rep:category BUSINESS_ENTITY GHR_REQ_FOR_PERSONNEL_ACTION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_pa_request_extra_info
  (p_validate                      	in     boolean  default false
  ,p_pa_request_extra_info_id      	in     number
  ,p_object_version_number         	in     number
  );
--
end ghr_par_extra_info_api;

 

/
