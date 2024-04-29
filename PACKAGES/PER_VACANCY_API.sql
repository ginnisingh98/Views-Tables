--------------------------------------------------------
--  DDL for Package PER_VACANCY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_VACANCY_API" AUTHID CURRENT_USER as
/* $Header: pevacapi.pkh 120.1.12000000.1 2007/01/22 04:59:40 appldev noship $ */
/*#
 * This package contains HR Vacancy APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Vacancy
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------------< create_vacancy >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a vacancy.
 *
 * Use this API to create a new vacancy and record details such as the
 * organization, job, recruiter, and budget values.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The requisition that this vacancy will belong to must already have been
 * created.
 *
 * <p><b>Post Success</b><br>
 * The vacancy will have been created.
 *
 * <p><b>Post Failure</b><br>
 * The vacancy will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_requisition_id Uniquely identifies the requisition associated with
 * this vacancy.
 * @param p_date_from Start date of the vacancy.
 * @param p_name The name of the vacancy.
 * @param p_security_method The security method of the vacancy. Valid values
 * are defined by the 'IRC_SECURITY_METHOD' lookup type.
 * @param p_business_group_id Uniquely identifies the business group under
 * which the vacancy is created.
 * @param p_position_id Uniquely identifies the position that this vacancy will
 * fill.
 * @param p_job_id Uniquely identifies the job that this vacancy will fill.
 * @param p_grade_id Uniquely identifies the grade of the position.
 * @param p_organization_id Uniquely identifies the organization of the
 * position.
 * @param p_people_group_id Uniquely identifies the people group of the
 * position.
 * @param p_location_id Uniquely identifies the location of the position.
 * @param p_recruiter_id Uniquely identifies the person who is recruiting for
 * this position.
 * @param p_date_to End date of the vacancy.
 * @param p_description Description of the vacancy.
 * @param p_number_of_openings Number of openings available for this vacancy.
 * @param p_status Status of the vacancy. Valid values are defined by the
 * 'VACANCY_STATUS' lookup type.
 * @param p_budget_measurement_type Budget measurement unit of measure. Valid
 * values are defined by the 'BUDGET_MEASUREMENT_TYPE' lookup.
 * @param p_budget_measurement_value Budget measurement value.
 * @param p_vacancy_category Category of the vacancy. Valid values are defined
 * by the 'VACANCY_CATEGORY' lookup type.
 * @param p_manager_id Uniquely identifies the person who is the manager of the
 * position.
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
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created vacancy. If p_validate is true, then the value
 * will be null.
 * @param p_vacancy_id If p_validate is false, then this uniquely identifies
 * the vacancy created. If p_validate is true, then this is set to null.
 * @param p_inv_pos_grade_warning If set to true, this serves as a warning that
 * the position is not valid for the grade.
 * @param p_inv_job_grade_warning If set to true, this serves as a warning that
 * the job is not valid for the grade.
 * @param p_assessment_id New parameter, available on the latest version of
 * this API.
 * @param p_primary_posting_id New parameter, available on the latest version
 * of this API.
 * @rep:displayname Create Vacancy
 * @rep:category BUSINESS_ENTITY PER_VACANCY
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_vacancy
  (
    P_VALIDATE                  in  boolean  default false
  , P_EFFECTIVE_DATE            in  date     default null
  , P_REQUISITION_ID            in  number
  , P_DATE_FROM                 in  date
  , P_NAME                      in  varchar2
  , P_SECURITY_METHOD           in  varchar2 default 'B'
  , P_BUSINESS_GROUP_ID         in  number
  , P_POSITION_ID               in  number   default null
  , P_JOB_ID                    in  number   default null
  , P_GRADE_ID                  in  number   default null
  , P_ORGANIZATION_ID           in  number   default null
  , P_PEOPLE_GROUP_ID           in  number   default null
  , P_LOCATION_ID               in  number   default null
  , P_RECRUITER_ID              in  number   default null
  , P_DATE_TO                   in  date     default null
  , P_DESCRIPTION               in  varchar2 default null
  , P_NUMBER_OF_OPENINGS        in  number   default null
  , P_STATUS                    in  varchar2 default null
  , P_BUDGET_MEASUREMENT_TYPE   in  varchar2 default null
  , P_BUDGET_MEASUREMENT_VALUE  in  number   default null
  , P_VACANCY_CATEGORY          in  varchar2 default null
  , P_MANAGER_ID                in  number   default null
  , P_PRIMARY_POSTING_ID        in  number   default null
  , P_ASSESSMENT_ID             in  number   default null
  , P_ATTRIBUTE_CATEGORY        in  varchar2 default null
  , P_ATTRIBUTE1                in  varchar2 default null
  , P_ATTRIBUTE2                in  varchar2 default null
  , P_ATTRIBUTE3                in  varchar2 default null
  , P_ATTRIBUTE4                in  varchar2 default null
  , P_ATTRIBUTE5                in  varchar2 default null
  , P_ATTRIBUTE6                in  varchar2 default null
  , P_ATTRIBUTE7                in  varchar2 default null
  , P_ATTRIBUTE8                in  varchar2 default null
  , P_ATTRIBUTE9                in  varchar2 default null
  , P_ATTRIBUTE10               in  varchar2 default null
  , P_ATTRIBUTE11               in  varchar2 default null
  , P_ATTRIBUTE12               in  varchar2 default null
  , P_ATTRIBUTE13               in  varchar2 default null
  , P_ATTRIBUTE14               in  varchar2 default null
  , P_ATTRIBUTE15               in  varchar2 default null
  , P_ATTRIBUTE16               in  varchar2 default null
  , P_ATTRIBUTE17               in  varchar2 default null
  , P_ATTRIBUTE18               in  varchar2 default null
  , P_ATTRIBUTE19               in  varchar2 default null
  , P_ATTRIBUTE20               in  varchar2 default null
  , P_ATTRIBUTE21               in  varchar2 default null
  , P_ATTRIBUTE22               in  varchar2 default null
  , P_ATTRIBUTE23               in  varchar2 default null
  , P_ATTRIBUTE24               in  varchar2 default null
  , P_ATTRIBUTE25               in  varchar2 default null
  , P_ATTRIBUTE26               in  varchar2 default null
  , P_ATTRIBUTE27               in  varchar2 default null
  , P_ATTRIBUTE28               in  varchar2 default null
  , P_ATTRIBUTE29               in  varchar2 default null
  , P_ATTRIBUTE30               in  varchar2 default null
  , P_OBJECT_VERSION_NUMBER         out nocopy number
  , P_VACANCY_ID                    out nocopy number
  , p_inv_pos_grade_warning         out nocopy boolean
  , p_inv_job_grade_warning         out nocopy boolean
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_vacancy >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a vacancy.
 *
 * Use this API to update a vacancy and update details such as the
 * organization, job, recruiter and budget values.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The vacancy must have already been created.
 *
 * <p><b>Post Success</b><br>
 * The vacancy will have been updated.
 *
 * <p><b>Post Failure</b><br>
 * The vacancy will not be updated and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_vacancy_id Uniquely identifies the vacancy being updated.
 * @param p_object_version_number Pass in the current version number of the
 * vacancy to be updated. When the API completes if p_validate is false, will
 * be set to the new version number of the updated vacancy. If p_validate is
 * true will be set to the same value which was passed in.
 * @param p_date_from Start date of the vacancy.
 * @param p_position_id Uniquely identifies the position that this vacancy will
 * fill.
 * @param p_job_id Uniquely identifies the job that this vacancy will fill.
 * @param p_grade_id Uniquely identifies the grade of the position.
 * @param p_organization_id Uniquely identifies the organization of the
 * position.
 * @param p_people_group_id Uniquely identifies the people group of the
 * position.
 * @param p_location_id Uniquely identifies the location of the position.
 * @param p_recruiter_id Uniquely identifies the person who is recruiting for
 * this position.
 * @param p_date_to End date of the vacancy.
 * @param p_security_method The security method of the vacancy. Valid values
 * are defined by the 'IRC_SECURITY_METHOD' lookup type.
 * @param p_description Description of the vacancy.
 * @param p_number_of_openings Number of openings available for this vacancy.
 * @param p_status Status of the vacancy. Valid values are defined by the
 * 'VACANCY_STATUS' lookup type.
 * @param p_budget_measurement_type Budget measurement unit of measure. Valid
 * values are defined by the 'BUDGET_MEASUREMENT_TYPE' lookup.
 * @param p_budget_measurement_value Budget measurement value.
 * @param p_vacancy_category Category of the vacancy. Valid values are defined
 * by the 'VACANCY_CATEGORY' lookup type.
 * @param p_manager_id Uniquely identifies the person who is the manager of the
 * position.
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
 * @param p_assignment_changed If set to true, this serves as a warning that
 * the process has changed assignments to reflect the new vacancy criteria.
 * @param p_inv_pos_grade_warning If set to true, this serves as a warning that
 * the position is not valid for the grade.
 * @param p_inv_job_grade_warning If set to true, this serves as a warning that
 * the job is not valid for the grade.
 * @param p_assessment_id New parameter, available on the latest version of
 * this API.
 * @param p_primary_posting_id New parameter, available on the latest version
 * of this API.
 * @rep:displayname Update Vacancy
 * @rep:category BUSINESS_ENTITY PER_VACANCY
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_vacancy
(
  P_VALIDATE                    in     boolean  default false
, P_EFFECTIVE_DATE              in     date     default null
, P_VACANCY_ID                  in     number
, P_OBJECT_VERSION_NUMBER       in out nocopy number
, P_DATE_FROM                   in     date     default hr_api.g_date
, P_POSITION_ID                 in     number   default hr_api.g_number
, P_JOB_ID                      in     number   default hr_api.g_number
, P_GRADE_ID                    in     number   default hr_api.g_number
, P_ORGANIZATION_ID             in     number   default hr_api.g_number
, P_PEOPLE_GROUP_ID             in     number   default hr_api.g_number
, P_LOCATION_ID                 in     number   default hr_api.g_number
, P_RECRUITER_ID                in     number   default hr_api.g_number
, P_DATE_TO                     in     date     default hr_api.g_date
, P_SECURITY_METHOD             in     varchar2 default hr_api.g_varchar2
, P_DESCRIPTION                 in     varchar2 default hr_api.g_varchar2
, P_NUMBER_OF_OPENINGS          in     number   default hr_api.g_number
, P_STATUS                      in     varchar2 default hr_api.g_varchar2
, P_BUDGET_MEASUREMENT_TYPE     in     varchar2 default hr_api.g_varchar2
, P_BUDGET_MEASUREMENT_VALUE    in     number   default hr_api.g_number
, P_VACANCY_CATEGORY            in     varchar2 default hr_api.g_varchar2
, P_MANAGER_ID                  in     number   default hr_api.g_number
, P_PRIMARY_POSTING_ID          in     number   default hr_api.g_number
, P_ASSESSMENT_ID               in     number   default hr_api.g_number
, P_ATTRIBUTE_CATEGORY          in     varchar2 default hr_api.g_varchar2
, P_ATTRIBUTE1                  in     varchar2 default hr_api.g_varchar2
, P_ATTRIBUTE2                  in     varchar2 default hr_api.g_varchar2
, P_ATTRIBUTE3                  in     varchar2 default hr_api.g_varchar2
, P_ATTRIBUTE4                  in     varchar2 default hr_api.g_varchar2
, P_ATTRIBUTE5                  in     varchar2 default hr_api.g_varchar2
, P_ATTRIBUTE6                  in     varchar2 default hr_api.g_varchar2
, P_ATTRIBUTE7                  in     varchar2 default hr_api.g_varchar2
, P_ATTRIBUTE8                  in     varchar2 default hr_api.g_varchar2
, P_ATTRIBUTE9                  in     varchar2 default hr_api.g_varchar2
, P_ATTRIBUTE10                 in     varchar2 default hr_api.g_varchar2
, P_ATTRIBUTE11                 in     varchar2 default hr_api.g_varchar2
, P_ATTRIBUTE12                 in     varchar2 default hr_api.g_varchar2
, P_ATTRIBUTE13                 in     varchar2 default hr_api.g_varchar2
, P_ATTRIBUTE14                 in     varchar2 default hr_api.g_varchar2
, P_ATTRIBUTE15                 in     varchar2 default hr_api.g_varchar2
, P_ATTRIBUTE16                 in     varchar2 default hr_api.g_varchar2
, P_ATTRIBUTE17                 in     varchar2 default hr_api.g_varchar2
, P_ATTRIBUTE18                 in     varchar2 default hr_api.g_varchar2
, P_ATTRIBUTE19                 in     varchar2 default hr_api.g_varchar2
, P_ATTRIBUTE20                 in     varchar2 default hr_api.g_varchar2
, P_ATTRIBUTE21                 in     varchar2 default hr_api.g_varchar2
, P_ATTRIBUTE22                 in     varchar2 default hr_api.g_varchar2
, P_ATTRIBUTE23                 in     varchar2 default hr_api.g_varchar2
, P_ATTRIBUTE24                 in     varchar2 default hr_api.g_varchar2
, P_ATTRIBUTE25                 in     varchar2 default hr_api.g_varchar2
, P_ATTRIBUTE26                 in     varchar2 default hr_api.g_varchar2
, P_ATTRIBUTE27                 in     varchar2 default hr_api.g_varchar2
, P_ATTRIBUTE28                 in     varchar2 default hr_api.g_varchar2
, P_ATTRIBUTE29                 in     varchar2 default hr_api.g_varchar2
, P_ATTRIBUTE30                 in     varchar2 default hr_api.g_varchar2
, P_ASSIGNMENT_CHANGED             out nocopy boolean
,p_inv_pos_grade_warning           out nocopy boolean
,p_inv_job_grade_warning           out nocopy boolean
);
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_vacancy >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a vacancy within a requisition.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The vacancy must exist.
 *
 * <p><b>Post Success</b><br>
 * The vacancy is deleted.
 *
 * <p><b>Post Failure</b><br>
 * The vacancy is not deleted and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_object_version_number Current version number of the Vacancy to be
 * deleted.
 * @param p_vacancy_id Uniquely identifies the vacancy being deleted.
 * @rep:displayname Delete Vacancy
 * @rep:category BUSINESS_ENTITY PER_VACANCY
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_vacancy
(
  P_VALIDATE                    in boolean default false
, P_OBJECT_VERSION_NUMBER       in number
, P_VACANCY_ID                  in number
);
--
end PER_VACANCY_API;

 

/
