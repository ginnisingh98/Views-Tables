--------------------------------------------------------
--  DDL for Package PER_DISABILITY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_DISABILITY_API" AUTHID CURRENT_USER as
/* $Header: pedisapi.pkh 120.1 2005/10/02 02:14:49 aroussel $ */
/*#
 * This package contains APIs which maintain a history of any disabilities a
 * person may have.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Disability
*/
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_disability >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a disability record for a person.
 *
 * The disability entity holds details describing the registered type of
 * disability the person has, its extent, any restrictions to work which it
 * causes, and how the disability changes over time. The disability may also be
 * linked to a work incident.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The person must exist on the validation start date.
 *
 * <p><b>Post Success</b><br>
 * The API has created the disability for the person.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the disability and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_person_id Identifies the person for whom you create the disability
 * record.
 * @param p_category The official category of the disability the person has.
 * Valid values are defined by the 'DISABILITY_CATEGORY' lookup type.
 * @param p_status The status of the disability record. Valid values are
 * defined by the 'DISABILITY_STATUS' lookup type.
 * @param p_quota_fte The full time earnings measure that is accorded to the
 * person due to the disability. The default value created is 1.00.
 * @param p_organization_id Uniquely identifies the official disability
 * organisation the person is registered with.
 * @param p_registration_id The registration code given to the person by the
 * disability organisation.
 * @param p_registration_date The date the person was registered disabled.
 * @param p_registration_exp_date The date the disability registration expires.
 * @param p_description Text description of the disability.
 * @param p_degree The percentage degree of disability the person has. This is
 * an officially assessed figure, provided during the process of disability
 * registration.
 * @param p_reason The reason for disability. Valid values are defined by the
 * 'DISABILITY_REASON' lookup type.
 * @param p_work_restriction Text describing any restrictions to work the
 * disabled person has.
 * @param p_incident_id Uniquely identifies a work incident record which is
 * being linked as a causal factor in the disability.
 * @param p_medical_assessment_id Uniquely identifies the medical assessment
 * record for this disability.
 * @param p_pre_registration_job The name of the job the person was doing on
 * the date they were registered disabled.
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
 * @param p_dis_information_category This context value determines which
 * Flexfield Structure to use with the Developer Descriptive flexfield
 * segments.
 * @param p_dis_information1 Developer Descriptive flexfield segment.
 * @param p_dis_information2 Developer Descriptive flexfield segment.
 * @param p_dis_information3 Developer Descriptive flexfield segment.
 * @param p_dis_information4 Developer Descriptive flexfield segment.
 * @param p_dis_information5 Developer Descriptive flexfield segment.
 * @param p_dis_information6 Developer Descriptive flexfield segment.
 * @param p_dis_information7 Developer Descriptive flexfield segment.
 * @param p_dis_information8 Developer Descriptive flexfield segment.
 * @param p_dis_information9 Developer Descriptive flexfield segment.
 * @param p_dis_information10 Developer Descriptive flexfield segment.
 * @param p_dis_information11 Developer Descriptive flexfield segment.
 * @param p_dis_information12 Developer Descriptive flexfield segment.
 * @param p_dis_information13 Developer Descriptive flexfield segment.
 * @param p_dis_information14 Developer Descriptive flexfield segment.
 * @param p_dis_information15 Developer Descriptive flexfield segment.
 * @param p_dis_information16 Developer Descriptive flexfield segment.
 * @param p_dis_information17 Developer Descriptive flexfield segment.
 * @param p_dis_information18 Developer Descriptive flexfield segment.
 * @param p_dis_information19 Developer Descriptive flexfield segment.
 * @param p_dis_information20 Developer Descriptive flexfield segment.
 * @param p_dis_information21 Developer Descriptive flexfield segment.
 * @param p_dis_information22 Developer Descriptive flexfield segment.
 * @param p_dis_information23 Developer Descriptive flexfield segment.
 * @param p_dis_information24 Developer Descriptive flexfield segment.
 * @param p_dis_information25 Developer Descriptive flexfield segment.
 * @param p_dis_information26 Developer Descriptive flexfield segment.
 * @param p_dis_information27 Developer Descriptive flexfield segment.
 * @param p_dis_information28 Developer Descriptive flexfield segment.
 * @param p_dis_information29 Developer Descriptive flexfield segment.
 * @param p_dis_information30 Developer Descriptive flexfield segment.
 * @param p_disability_id If p_validate is false, uniquely identifies the
 * disability created by the API. If p_validate is true then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created disability. If p_validate is true, then the
 * value will be null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created disability. If p_validate is
 * true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created disability. If p_validate is true, then
 * set to null.
 * @rep:displayname Create Disability
 * @rep:category BUSINESS_ENTITY PER_DISABILITY
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_disability
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_person_id                     in     number
  ,p_category                      in     varchar2
  ,p_status                        in     varchar2
  ,p_quota_fte                     in     number   default 1.00
  ,p_organization_id               in     number   default null
  ,p_registration_id               in     varchar2 default null
  ,p_registration_date             in     date     default null
  ,p_registration_exp_date         in     date     default null
  ,p_description                   in     varchar2 default null
  ,p_degree                        in     number   default null
  ,p_reason                        in     varchar2 default null
  ,p_work_restriction              in     varchar2 default null
  ,p_incident_id                   in     number   default null
  ,p_medical_assessment_id         in     number   default null
  ,p_pre_registration_job          in     varchar2 default null
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
  ,p_attribute21                   in     varchar2 default null
  ,p_attribute22                   in     varchar2 default null
  ,p_attribute23                   in     varchar2 default null
  ,p_attribute24                   in     varchar2 default null
  ,p_attribute25                   in     varchar2 default null
  ,p_attribute26                   in     varchar2 default null
  ,p_attribute27                   in     varchar2 default null
  ,p_attribute28                   in     varchar2 default null
  ,p_attribute29                   in     varchar2 default null
  ,p_attribute30                   in     varchar2 default null
  ,p_dis_information_category      in     varchar2 default null
  ,p_dis_information1              in     varchar2 default null
  ,p_dis_information2              in     varchar2 default null
  ,p_dis_information3              in     varchar2 default null
  ,p_dis_information4              in     varchar2 default null
  ,p_dis_information5              in     varchar2 default null
  ,p_dis_information6              in     varchar2 default null
  ,p_dis_information7              in     varchar2 default null
  ,p_dis_information8              in     varchar2 default null
  ,p_dis_information9              in     varchar2 default null
  ,p_dis_information10             in     varchar2 default null
  ,p_dis_information11             in     varchar2 default null
  ,p_dis_information12             in     varchar2 default null
  ,p_dis_information13             in     varchar2 default null
  ,p_dis_information14             in     varchar2 default null
  ,p_dis_information15             in     varchar2 default null
  ,p_dis_information16             in     varchar2 default null
  ,p_dis_information17             in     varchar2 default null
  ,p_dis_information18             in     varchar2 default null
  ,p_dis_information19             in     varchar2 default null
  ,p_dis_information20             in     varchar2 default null
  ,p_dis_information21             in     varchar2 default null
  ,p_dis_information22             in     varchar2 default null
  ,p_dis_information23             in     varchar2 default null
  ,p_dis_information24             in     varchar2 default null
  ,p_dis_information25             in     varchar2 default null
  ,p_dis_information26             in     varchar2 default null
  ,p_dis_information27             in     varchar2 default null
  ,p_dis_information28             in     varchar2 default null
  ,p_dis_information29             in     varchar2 default null
  ,p_dis_information30             in     varchar2 default null
  ,p_disability_id                    out nocopy number
  ,p_object_version_number            out nocopy number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_disability >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a disability record for a person.
 *
 * The disability entity holds details describing the registered type of
 * disability the person has, its extent, any restrictions to work which it
 * causes, and how the disability changes over time. The disability may also be
 * linked to a work incident.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The disability record must exist.
 *
 * <p><b>Post Success</b><br>
 * The disability record is updated.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the disability record and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_datetrack_mode Indicates which DateTrack mode to use when updating
 * the record. You must set to either UPDATE, CORRECTION, UPDATE_OVERRIDE or
 * UPDATE_CHANGE_INSERT. Modes available for use with a particular record
 * depend on the dates of previous record changes and the effective date of
 * this change.
 * @param p_disability_id Uniquely identifies the disability to be updated.
 * @param p_object_version_number Pass in the current version number of the
 * disability to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated disability. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_category The official category of the disability the person has.
 * Valid values are defined by the 'DISABILITY_CATEGORY' lookup type.
 * @param p_status The status of the disability record. Valid values are
 * defined by the 'DISABILITY_STATUS' lookup type.
 * @param p_quota_fte The full time earnings measure that is accorded to the
 * person due to the disability. The default value created is 1.00.
 * @param p_organization_id Uniquely identifies the official disability
 * organisation the person is registered with.
 * @param p_registration_id The registration code given to the person by the
 * disability organisation.
 * @param p_registration_date The date the person was registered disabled.
 * @param p_registration_exp_date The date the disability registration expires.
 * @param p_description Text description of the disability.
 * @param p_degree The percentage degree of disability the person has. This is
 * an officially assessed figure, provided during the process of disability
 * registration.
 * @param p_reason The reason for disability. Valid values are defined by the
 * 'DISABILITY_REASON' lookup type.
 * @param p_work_restriction Text describing any restrictions to work the
 * disabled person has.
 * @param p_incident_id Uniquely identifies a work incident record which is
 * being linked as a causal factor in the disability.
 * @param p_medical_assessment_id Uniquely identifies the medical assessment
 * record for this disability.
 * @param p_pre_registration_job The name of the job the person was doing on
 * the date they were registered disabled.
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
 * @param p_dis_information_category This context value determines which
 * Flexfield Structure to use with the Developer Descriptive flexfield
 * segments.
 * @param p_dis_information1 Developer Descriptive flexfield segment.
 * @param p_dis_information2 Developer Descriptive flexfield segment.
 * @param p_dis_information3 Developer Descriptive flexfield segment.
 * @param p_dis_information4 Developer Descriptive flexfield segment.
 * @param p_dis_information5 Developer Descriptive flexfield segment.
 * @param p_dis_information6 Developer Descriptive flexfield segment.
 * @param p_dis_information7 Developer Descriptive flexfield segment.
 * @param p_dis_information8 Developer Descriptive flexfield segment.
 * @param p_dis_information9 Developer Descriptive flexfield segment.
 * @param p_dis_information10 Developer Descriptive flexfield segment.
 * @param p_dis_information11 Developer Descriptive flexfield segment.
 * @param p_dis_information12 Developer Descriptive flexfield segment.
 * @param p_dis_information13 Developer Descriptive flexfield segment.
 * @param p_dis_information14 Developer Descriptive flexfield segment.
 * @param p_dis_information15 Developer Descriptive flexfield segment.
 * @param p_dis_information16 Developer Descriptive flexfield segment.
 * @param p_dis_information17 Developer Descriptive flexfield segment.
 * @param p_dis_information18 Developer Descriptive flexfield segment.
 * @param p_dis_information19 Developer Descriptive flexfield segment.
 * @param p_dis_information20 Developer Descriptive flexfield segment.
 * @param p_dis_information21 Developer Descriptive flexfield segment.
 * @param p_dis_information22 Developer Descriptive flexfield segment.
 * @param p_dis_information23 Developer Descriptive flexfield segment.
 * @param p_dis_information24 Developer Descriptive flexfield segment.
 * @param p_dis_information25 Developer Descriptive flexfield segment.
 * @param p_dis_information26 Developer Descriptive flexfield segment.
 * @param p_dis_information27 Developer Descriptive flexfield segment.
 * @param p_dis_information28 Developer Descriptive flexfield segment.
 * @param p_dis_information29 Developer Descriptive flexfield segment.
 * @param p_dis_information30 Developer Descriptive flexfield segment.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated disability row which now exists as of
 * the effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated disability row which now exists as of the
 * effective date. If p_validate is true, then set to null.
 * @rep:displayname Update Disability
 * @rep:category BUSINESS_ENTITY PER_DISABILITY
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_disability
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_mode                in     varchar2
  ,p_disability_id                 in     number
  ,p_object_version_number         in out nocopy number
  ,p_category                      in     varchar2 default hr_api.g_varchar2
  ,p_status                        in     varchar2 default hr_api.g_varchar2
  ,p_quota_fte                     in     number   default hr_api.g_number
  ,p_organization_id               in     number   default hr_api.g_number
  ,p_registration_id               in     varchar2 default hr_api.g_varchar2
  ,p_registration_date             in     date     default hr_api.g_date
  ,p_registration_exp_date         in     date     default hr_api.g_date
  ,p_description                   in     varchar2 default hr_api.g_varchar2
  ,p_degree                        in     number   default hr_api.g_number
  ,p_reason                        in     varchar2 default hr_api.g_varchar2
  ,p_work_restriction              in     varchar2 default hr_api.g_varchar2
  ,p_incident_id                   in     number   default hr_api.g_number
  ,p_medical_assessment_id         in     number   default hr_api.g_number
  ,p_pre_registration_job          in     varchar2 default hr_api.g_varchar2
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
  ,p_attribute21                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute22                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute23                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute24                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute25                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute26                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute27                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute28                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute29                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute30                   in     varchar2 default hr_api.g_varchar2
  ,p_dis_information_category      in     varchar2 default hr_api.g_varchar2
  ,p_dis_information1              in     varchar2 default hr_api.g_varchar2
  ,p_dis_information2              in     varchar2 default hr_api.g_varchar2
  ,p_dis_information3              in     varchar2 default hr_api.g_varchar2
  ,p_dis_information4              in     varchar2 default hr_api.g_varchar2
  ,p_dis_information5              in     varchar2 default hr_api.g_varchar2
  ,p_dis_information6              in     varchar2 default hr_api.g_varchar2
  ,p_dis_information7              in     varchar2 default hr_api.g_varchar2
  ,p_dis_information8              in     varchar2 default hr_api.g_varchar2
  ,p_dis_information9              in     varchar2 default hr_api.g_varchar2
  ,p_dis_information10             in     varchar2 default hr_api.g_varchar2
  ,p_dis_information11             in     varchar2 default hr_api.g_varchar2
  ,p_dis_information12             in     varchar2 default hr_api.g_varchar2
  ,p_dis_information13             in     varchar2 default hr_api.g_varchar2
  ,p_dis_information14             in     varchar2 default hr_api.g_varchar2
  ,p_dis_information15             in     varchar2 default hr_api.g_varchar2
  ,p_dis_information16             in     varchar2 default hr_api.g_varchar2
  ,p_dis_information17             in     varchar2 default hr_api.g_varchar2
  ,p_dis_information18             in     varchar2 default hr_api.g_varchar2
  ,p_dis_information19             in     varchar2 default hr_api.g_varchar2
  ,p_dis_information20             in     varchar2 default hr_api.g_varchar2
  ,p_dis_information21             in     varchar2 default hr_api.g_varchar2
  ,p_dis_information22             in     varchar2 default hr_api.g_varchar2
  ,p_dis_information23             in     varchar2 default hr_api.g_varchar2
  ,p_dis_information24             in     varchar2 default hr_api.g_varchar2
  ,p_dis_information25             in     varchar2 default hr_api.g_varchar2
  ,p_dis_information26             in     varchar2 default hr_api.g_varchar2
  ,p_dis_information27             in     varchar2 default hr_api.g_varchar2
  ,p_dis_information28             in     varchar2 default hr_api.g_varchar2
  ,p_dis_information29             in     varchar2 default hr_api.g_varchar2
  ,p_dis_information30             in     varchar2 default hr_api.g_varchar2
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_disability >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a disability record for a person.
 *
 * The disability entity holds details describing the registered type of
 * disability the person has, its extent, any restrictions to work which it
 * causes, and how the disability changes over time. The disability may also be
 * linked to a work incident.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The disability record to be deleted must already exist.
 *
 * <p><b>Post Success</b><br>
 * The disability record is deleted.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the disability and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_datetrack_mode Indicates which DateTrack mode to use when deleting
 * the record. You must set to either ZAP, DELETE, FUTURE_CHANGE or
 * DELETE_NEXT_CHANGE. Modes available for use with a particular record depend
 * on the dates of previous record changes and the effective date of this
 * change.
 * @param p_disability_id Uniquely identifies the disability to be deleted.
 * @param p_object_version_number Current version number of the disability to
 * be deleted.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date for the deleted disability row which now exists as of
 * the effective date. If p_validate is true or all row instances have been
 * deleted then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the deleted disability row which now exists as of the
 * effective date. If p_validate is true or all row instances have been deleted
 * then set to null.
 * @rep:displayname Delete Disability
 * @rep:category BUSINESS_ENTITY PER_DISABILITY
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_disability
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_mode                in     varchar2
  ,p_disability_id                 in     number
  ,p_object_version_number         in out nocopy number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  );
--
end per_disability_api;

 

/
