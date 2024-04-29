--------------------------------------------------------
--  DDL for Package PER_KW_DISABILITY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_KW_DISABILITY_API" AUTHID CURRENT_USER as
/* $Header: pediskwi.pkh 120.1 2005/10/02 02:41:00 aroussel $ */
/*#
 * This API creates a disability record for a person.
 * @rep:scope public
 * @rep:product PER
 * @rep:displayname Kuwait Disability APIs
*/
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_kw_disability >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a disability record for a person.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Person must exist on the validation start date.
 *
 * <p><b>Post Success</b><br>
 * Disability is created.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the disability and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date The effective start date of this disability.
 * @param p_person_id The person for whom the disability applies to.
 * @param p_category The person's official disability category.
 * @param p_status The status of the disability record.
 * @param p_quota_fte Disability full time earnings measure (default is 1.00).
 * @param p_organization_id The system ID of the official disability
 * organization the person is registered with.
 * @param p_registration_id The registration code given to the person by the
 * disability organization.
 * @param p_registration_date The date the person was registered as disabled.
 * @param p_registration_exp_date The date disability registration would
 * expire.
 * @param p_description Text description of disability.
 * @param p_degree The person's disability percentage in degrees.
 * @param p_reason The reason for disability.
 * @param p_work_restriction Text describing any restrictions for the disabled
 * person to work.
 * @param p_incident_id The surrogate key for work incident.
 * @param p_medical_assessment_id The surrogate key for medical assessment.
 * @param p_pre_registration_job The person's job on the registration date.
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
 * @param p_range_of_disability Range of Disability.
 * @param p_reporting_description Reporting Description.
 * @param p_disability_id Unique ID for the disability created by the API.
 * @param p_object_version_number Version number of the new disability.
 * @param p_effective_start_date Effective start date of this disability.
 * @param p_effective_end_date Effective end date of this disability.
 * @rep:displayname Create Kuwait Disability
 * @rep:category BUSINESS_ENTITY PER_DISABILITY
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_kw_disability
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
  ,p_range_of_disability           in     varchar2 default null
  ,p_reporting_description         in     varchar2 default null
  ,p_disability_id                    out nocopy number
  ,p_object_version_number            out nocopy number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_kw_disability >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a disability record for a person as identified by
 * p_disability_id and p_object_version_number.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The disability record identified by p_disability_id and
 * object_version_number must exist.
 *
 * <p><b>Post Success</b><br>
 * Disability is updated.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the disability, and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Application effective date.
 * @param p_datetrack_mode Update mode.
 * @param p_disability_id Surrogate ID of the disability record.
 * @param p_object_version_number Version number of the disability record.
 * @param p_category The official disability category of the person.
 * @param p_status The status of the disability record.
 * @param p_quota_fte Disability full time earnings measure.
 * @param p_organization_id The system ID of the official disability
 * organization the person is registered with.
 * @param p_registration_id The person's registration code given by the
 * disability organization.
 * @param p_registration_date The date the person was registered as disabled.
 * @param p_registration_exp_date The date the person's disability registration
 * would expire.
 * @param p_description Text description of disability.
 * @param p_degree The person's disability percentage in degrees.
 * @param p_reason The reason for disability.
 * @param p_work_restriction Text describing any restrictions to work the
 * disabled person has.
 * @param p_incident_id The surrogate key for work incident.
 * @param p_medical_assessment_id The surrogate key for medical assessment.
 * @param p_pre_registration_job The job the person was doing on the
 * registration_date.
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
 * @param p_range_of_disability Range of Disability.
 * @param p_reporting_description Reporting Description.
 * @param p_effective_start_date Effective start date of the disability
 * changes.
 * @param p_effective_end_date Effective end date of the disability changes.
 * @rep:displayname Update Kuwait Disability
 * @rep:category BUSINESS_ENTITY PER_DISABILITY
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_kw_disability
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
  ,p_range_of_disability           in     varchar2 default hr_api.g_varchar2
  ,p_reporting_description         in     varchar2 default hr_api.g_varchar2
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  );

end per_kw_disability_api;

 

/
