--------------------------------------------------------
--  DDL for Package PER_JOB_EXTRA_INFO_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_JOB_EXTRA_INFO_API" AUTHID CURRENT_USER as
/* $Header: pejeiapi.pkh 120.1 2005/10/02 02:17:57 aroussel $ */
/*#
 * This package contains APIs which create and maintain extra information
 * records for a job.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Job Extra Information
*/
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_job_extra_info >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates extra information for a job.
 *
 * Extra information provides the ability for users to easily extend and
 * configure information the system holds about a particular job, allowing the
 * system to capture multiple additional sets of structured data in relation to
 * a specific parent job record. Extra information is based on descriptive
 * flexfields and so the user must first define the job extra information
 * flexfield structures, in terms of the number and type of segments for each
 * structure, and any validation which should be applied to each segment. These
 * structures correspond to extra information types. The user is then able to
 * populate one or more instances of each of the predefined job extra
 * information types (structures), for each of the jobs that they have set up
 * on the system, using this API.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The job and the job extra information type (flexfield structure) must
 * already exist.
 *
 * <p><b>Post Success</b><br>
 * The job extra information is created.
 *
 * <p><b>Post Failure</b><br>
 * The job extra information is not created and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_job_id Uniquely identifies the job to which this extra information
 * record applies.
 * @param p_information_type The name of the information type corresponding to
 * the flexfield context which provides the structure of the extra information
 * record.
 * @param p_jei_attribute_category This context value determines which
 * Flexfield Structure to use with the Descriptive flexfield segments.
 * @param p_jei_attribute1 Descriptive flexfield segment.
 * @param p_jei_attribute2 Descriptive flexfield segment.
 * @param p_jei_attribute3 Descriptive flexfield segment.
 * @param p_jei_attribute4 Descriptive flexfield segment.
 * @param p_jei_attribute5 Descriptive flexfield segment.
 * @param p_jei_attribute6 Descriptive flexfield segment.
 * @param p_jei_attribute7 Descriptive flexfield segment.
 * @param p_jei_attribute8 Descriptive flexfield segment.
 * @param p_jei_attribute9 Descriptive flexfield segment.
 * @param p_jei_attribute10 Descriptive flexfield segment.
 * @param p_jei_attribute11 Descriptive flexfield segment.
 * @param p_jei_attribute12 Descriptive flexfield segment.
 * @param p_jei_attribute13 Descriptive flexfield segment.
 * @param p_jei_attribute14 Descriptive flexfield segment.
 * @param p_jei_attribute15 Descriptive flexfield segment.
 * @param p_jei_attribute16 Descriptive flexfield segment.
 * @param p_jei_attribute17 Descriptive flexfield segment.
 * @param p_jei_attribute18 Descriptive flexfield segment.
 * @param p_jei_attribute19 Descriptive flexfield segment.
 * @param p_jei_attribute20 Descriptive flexfield segment.
 * @param p_jei_information_category This context value determines which
 * Flexfield Structure to use with the Developer Descriptive flexfield
 * segments.
 * @param p_jei_information1 Developer Descriptive flexfield segment.
 * @param p_jei_information2 Developer Descriptive flexfield segment.
 * @param p_jei_information3 Developer Descriptive flexfield segment.
 * @param p_jei_information4 Developer Descriptive flexfield segment.
 * @param p_jei_information5 Developer Descriptive flexfield segment.
 * @param p_jei_information6 Developer Descriptive flexfield segment.
 * @param p_jei_information7 Developer Descriptive flexfield segment.
 * @param p_jei_information8 Developer Descriptive flexfield segment.
 * @param p_jei_information9 Developer Descriptive flexfield segment.
 * @param p_jei_information10 Developer Descriptive flexfield segment.
 * @param p_jei_information11 Developer Descriptive flexfield segment.
 * @param p_jei_information12 Developer Descriptive flexfield segment.
 * @param p_jei_information13 Developer Descriptive flexfield segment.
 * @param p_jei_information14 Developer Descriptive flexfield segment.
 * @param p_jei_information15 Developer Descriptive flexfield segment.
 * @param p_jei_information16 Developer Descriptive flexfield segment.
 * @param p_jei_information17 Developer Descriptive flexfield segment.
 * @param p_jei_information18 Developer Descriptive flexfield segment.
 * @param p_jei_information19 Developer Descriptive flexfield segment.
 * @param p_jei_information20 Developer Descriptive flexfield segment.
 * @param p_jei_information21 Developer Descriptive flexfield segment.
 * @param p_jei_information22 Developer Descriptive flexfield segment.
 * @param p_jei_information23 Developer Descriptive flexfield segment.
 * @param p_jei_information24 Developer Descriptive flexfield segment.
 * @param p_jei_information25 Developer Descriptive flexfield segment.
 * @param p_jei_information26 Developer Descriptive flexfield segment.
 * @param p_jei_information27 Developer Descriptive flexfield segment.
 * @param p_jei_information28 Developer Descriptive flexfield segment.
 * @param p_jei_information29 Developer Descriptive flexfield segment.
 * @param p_jei_information30 Developer Descriptive flexfield segment.
 * @param p_job_extra_info_id If p_validate is false, uniquely identifies the
 * job extra information created. If p_validate is true, set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created job extra information. If p_validate is true,
 * then the value will be null.
 * @rep:displayname Create Job Extra Information
 * @rep:category BUSINESS_ENTITY PER_JOB
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_job_extra_info
  (p_validate                     in     boolean  default false
  ,p_job_id                       in     number
  ,p_information_type             in     varchar2
  ,p_jei_attribute_category       in     varchar2 default null
  ,p_jei_attribute1               in     varchar2 default null
  ,p_jei_attribute2               in     varchar2 default null
  ,p_jei_attribute3               in     varchar2 default null
  ,p_jei_attribute4               in     varchar2 default null
  ,p_jei_attribute5               in     varchar2 default null
  ,p_jei_attribute6               in     varchar2 default null
  ,p_jei_attribute7               in     varchar2 default null
  ,p_jei_attribute8               in     varchar2 default null
  ,p_jei_attribute9               in     varchar2 default null
  ,p_jei_attribute10              in     varchar2 default null
  ,p_jei_attribute11              in     varchar2 default null
  ,p_jei_attribute12              in     varchar2 default null
  ,p_jei_attribute13              in     varchar2 default null
  ,p_jei_attribute14              in     varchar2 default null
  ,p_jei_attribute15              in     varchar2 default null
  ,p_jei_attribute16              in     varchar2 default null
  ,p_jei_attribute17              in     varchar2 default null
  ,p_jei_attribute18              in     varchar2 default null
  ,p_jei_attribute19              in     varchar2 default null
  ,p_jei_attribute20              in     varchar2 default null
  ,p_jei_information_category     in     varchar2 default null
  ,p_jei_information1             in     varchar2 default null
  ,p_jei_information2             in     varchar2 default null
  ,p_jei_information3             in     varchar2 default null
  ,p_jei_information4             in     varchar2 default null
  ,p_jei_information5             in     varchar2 default null
  ,p_jei_information6             in     varchar2 default null
  ,p_jei_information7             in     varchar2 default null
  ,p_jei_information8             in     varchar2 default null
  ,p_jei_information9             in     varchar2 default null
  ,p_jei_information10            in     varchar2 default null
  ,p_jei_information11            in     varchar2 default null
  ,p_jei_information12            in     varchar2 default null
  ,p_jei_information13            in     varchar2 default null
  ,p_jei_information14            in     varchar2 default null
  ,p_jei_information15            in     varchar2 default null
  ,p_jei_information16            in     varchar2 default null
  ,p_jei_information17            in     varchar2 default null
  ,p_jei_information18            in     varchar2 default null
  ,p_jei_information19            in     varchar2 default null
  ,p_jei_information20            in     varchar2 default null
  ,p_jei_information21            in     varchar2 default null
  ,p_jei_information22            in     varchar2 default null
  ,p_jei_information23            in     varchar2 default null
  ,p_jei_information24            in     varchar2 default null
  ,p_jei_information25            in     varchar2 default null
  ,p_jei_information26            in     varchar2 default null
  ,p_jei_information27            in     varchar2 default null
  ,p_jei_information28            in     varchar2 default null
  ,p_jei_information29            in     varchar2 default null
  ,p_jei_information30            in     varchar2 default null
  ,p_job_extra_info_id           out nocopy number
  ,p_object_version_number            out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_job_extra_info >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates extra information for a job.
 *
 * Extra information provides the ability for users to easily extend and
 * configure information the system holds about a particular job, allowing the
 * system to capture multiple additional sets of structured data in relation to
 * a specific parent job record. Extra information is based on descriptive
 * flexfields and so the user must first define the job extra information
 * flexfield structures, in terms of the number and type of segments for each
 * structure, and any validation which should be applied to each segment. These
 * structures correspond to extra information types. The user is then able to
 * maintain one or more instances of each of the predefined job extra
 * information types (structures), for each of the jobs that they have set up
 * on the system, using this API.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The job extra information must already exist.
 *
 * <p><b>Post Success</b><br>
 * The job extra information is updated.
 *
 * <p><b>Post Failure</b><br>
 * The job extra information is not updated and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_job_extra_info_id Uniquely identifies the job extra information
 * record to be updated.
 * @param p_object_version_number Pass in the current version number of the job
 * extra information to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated job extra
 * information. If p_validate is true will be set to the same value which was
 * passed in.
 * @param p_jei_attribute_category This context value determines which
 * Flexfield Structure to use with the Descriptive flexfield segments.
 * @param p_jei_attribute1 Descriptive flexfield segment.
 * @param p_jei_attribute2 Descriptive flexfield segment.
 * @param p_jei_attribute3 Descriptive flexfield segment.
 * @param p_jei_attribute4 Descriptive flexfield segment.
 * @param p_jei_attribute5 Descriptive flexfield segment.
 * @param p_jei_attribute6 Descriptive flexfield segment.
 * @param p_jei_attribute7 Descriptive flexfield segment.
 * @param p_jei_attribute8 Descriptive flexfield segment.
 * @param p_jei_attribute9 Descriptive flexfield segment.
 * @param p_jei_attribute10 Descriptive flexfield segment.
 * @param p_jei_attribute11 Descriptive flexfield segment.
 * @param p_jei_attribute12 Descriptive flexfield segment.
 * @param p_jei_attribute13 Descriptive flexfield segment.
 * @param p_jei_attribute14 Descriptive flexfield segment.
 * @param p_jei_attribute15 Descriptive flexfield segment.
 * @param p_jei_attribute16 Descriptive flexfield segment.
 * @param p_jei_attribute17 Descriptive flexfield segment.
 * @param p_jei_attribute18 Descriptive flexfield segment.
 * @param p_jei_attribute19 Descriptive flexfield segment.
 * @param p_jei_attribute20 Descriptive flexfield segment.
 * @param p_jei_information_category This context value determines which
 * Flexfield Structure to use with the Developer Descriptive flexfield
 * segments.
 * @param p_jei_information1 Developer Descriptive flexfield segment.
 * @param p_jei_information2 Developer Descriptive flexfield segment.
 * @param p_jei_information3 Developer Descriptive flexfield segment.
 * @param p_jei_information4 Developer Descriptive flexfield segment.
 * @param p_jei_information5 Developer Descriptive flexfield segment.
 * @param p_jei_information6 Developer Descriptive flexfield segment.
 * @param p_jei_information7 Developer Descriptive flexfield segment.
 * @param p_jei_information8 Developer Descriptive flexfield segment.
 * @param p_jei_information9 Developer Descriptive flexfield segment.
 * @param p_jei_information10 Developer Descriptive flexfield segment.
 * @param p_jei_information11 Developer Descriptive flexfield segment.
 * @param p_jei_information12 Developer Descriptive flexfield segment.
 * @param p_jei_information13 Developer Descriptive flexfield segment.
 * @param p_jei_information14 Developer Descriptive flexfield segment.
 * @param p_jei_information15 Developer Descriptive flexfield segment.
 * @param p_jei_information16 Developer Descriptive flexfield segment.
 * @param p_jei_information17 Developer Descriptive flexfield segment.
 * @param p_jei_information18 Developer Descriptive flexfield segment.
 * @param p_jei_information19 Developer Descriptive flexfield segment.
 * @param p_jei_information20 Developer Descriptive flexfield segment.
 * @param p_jei_information21 Developer Descriptive flexfield segment.
 * @param p_jei_information22 Developer Descriptive flexfield segment.
 * @param p_jei_information23 Developer Descriptive flexfield segment.
 * @param p_jei_information24 Developer Descriptive flexfield segment.
 * @param p_jei_information25 Developer Descriptive flexfield segment.
 * @param p_jei_information26 Developer Descriptive flexfield segment.
 * @param p_jei_information27 Developer Descriptive flexfield segment.
 * @param p_jei_information28 Developer Descriptive flexfield segment.
 * @param p_jei_information29 Developer Descriptive flexfield segment.
 * @param p_jei_information30 Developer Descriptive flexfield segment.
 * @rep:displayname Update Job Extra Information
 * @rep:category BUSINESS_ENTITY PER_JOB
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_job_extra_info
  (p_validate                     in     boolean  default false
  ,p_job_extra_info_id            in     number
  ,p_object_version_number        in out nocopy number
  ,p_jei_attribute_category       in     varchar2 default hr_api.g_varchar2
  ,p_jei_attribute1               in     varchar2 default hr_api.g_varchar2
  ,p_jei_attribute2               in     varchar2 default hr_api.g_varchar2
  ,p_jei_attribute3               in     varchar2 default hr_api.g_varchar2
  ,p_jei_attribute4               in     varchar2 default hr_api.g_varchar2
  ,p_jei_attribute5               in     varchar2 default hr_api.g_varchar2
  ,p_jei_attribute6               in     varchar2 default hr_api.g_varchar2
  ,p_jei_attribute7               in     varchar2 default hr_api.g_varchar2
  ,p_jei_attribute8               in     varchar2 default hr_api.g_varchar2
  ,p_jei_attribute9               in     varchar2 default hr_api.g_varchar2
  ,p_jei_attribute10              in     varchar2 default hr_api.g_varchar2
  ,p_jei_attribute11              in     varchar2 default hr_api.g_varchar2
  ,p_jei_attribute12              in     varchar2 default hr_api.g_varchar2
  ,p_jei_attribute13              in     varchar2 default hr_api.g_varchar2
  ,p_jei_attribute14              in     varchar2 default hr_api.g_varchar2
  ,p_jei_attribute15              in     varchar2 default hr_api.g_varchar2
  ,p_jei_attribute16              in     varchar2 default hr_api.g_varchar2
  ,p_jei_attribute17              in     varchar2 default hr_api.g_varchar2
  ,p_jei_attribute18              in     varchar2 default hr_api.g_varchar2
  ,p_jei_attribute19              in     varchar2 default hr_api.g_varchar2
  ,p_jei_attribute20              in     varchar2 default hr_api.g_varchar2
  ,p_jei_information_category     in     varchar2 default hr_api.g_varchar2
  ,p_jei_information1             in     varchar2 default hr_api.g_varchar2
  ,p_jei_information2             in     varchar2 default hr_api.g_varchar2
  ,p_jei_information3             in     varchar2 default hr_api.g_varchar2
  ,p_jei_information4             in     varchar2 default hr_api.g_varchar2
  ,p_jei_information5             in     varchar2 default hr_api.g_varchar2
  ,p_jei_information6             in     varchar2 default hr_api.g_varchar2
  ,p_jei_information7             in     varchar2 default hr_api.g_varchar2
  ,p_jei_information8             in     varchar2 default hr_api.g_varchar2
  ,p_jei_information9             in     varchar2 default hr_api.g_varchar2
  ,p_jei_information10            in     varchar2 default hr_api.g_varchar2
  ,p_jei_information11            in     varchar2 default hr_api.g_varchar2
  ,p_jei_information12            in     varchar2 default hr_api.g_varchar2
  ,p_jei_information13            in     varchar2 default hr_api.g_varchar2
  ,p_jei_information14            in     varchar2 default hr_api.g_varchar2
  ,p_jei_information15            in     varchar2 default hr_api.g_varchar2
  ,p_jei_information16            in     varchar2 default hr_api.g_varchar2
  ,p_jei_information17            in     varchar2 default hr_api.g_varchar2
  ,p_jei_information18            in     varchar2 default hr_api.g_varchar2
  ,p_jei_information19            in     varchar2 default hr_api.g_varchar2
  ,p_jei_information20            in     varchar2 default hr_api.g_varchar2
  ,p_jei_information21            in     varchar2 default hr_api.g_varchar2
  ,p_jei_information22            in     varchar2 default hr_api.g_varchar2
  ,p_jei_information23            in     varchar2 default hr_api.g_varchar2
  ,p_jei_information24            in     varchar2 default hr_api.g_varchar2
  ,p_jei_information25            in     varchar2 default hr_api.g_varchar2
  ,p_jei_information26            in     varchar2 default hr_api.g_varchar2
  ,p_jei_information27            in     varchar2 default hr_api.g_varchar2
  ,p_jei_information28            in     varchar2 default hr_api.g_varchar2
  ,p_jei_information29            in     varchar2 default hr_api.g_varchar2
  ,p_jei_information30            in     varchar2 default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_job_extra_info >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes extra information for a job.
 *
 * Extra information provides the ability for users to easily extend and
 * configure information the system holds about a particular job, allowing the
 * system to capture multiple additional sets of structured data in relation to
 * a specific parent job record. Extra information is based on descriptive
 * flexfields and so the user must first define the job extra information
 * flexfield structures, in terms of the number and type of segments for each
 * structure, and any validation which should be applied to each segment. These
 * structures correspond to extra information types. The user is then able to
 * populate one or more instances of each of the predefined job extra
 * information types (structures), for each of the jobs that they have set up
 * on the system.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The job extra information must exist.
 *
 * <p><b>Post Success</b><br>
 * The job extra information is deleted.
 *
 * <p><b>Post Failure</b><br>
 * The job extra information is not deleted and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_job_extra_info_id Uniquely identifies the job extra information
 * record to be deleted.
 * @param p_object_version_number Current version number of the job extra
 * information to be deleted.
 * @rep:displayname Delete Job Extra Information
 * @rep:category BUSINESS_ENTITY PER_JOB
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_job_extra_info
  (p_validate                      	in     boolean  default false
  ,p_job_extra_info_id        	in     number
  ,p_object_version_number         	in     number
  );
--
end per_job_extra_info_api;

 

/
