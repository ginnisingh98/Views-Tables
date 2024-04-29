--------------------------------------------------------
--  DDL for Package HR_APPLICATION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_APPLICATION_API" AUTHID CURRENT_USER as
/* $Header: peaplapi.pkh 120.1 2005/10/02 02:09:51 aroussel $ */
/*#
 * This package contains applications APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Application
*/
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_apl_details >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates application details.
 *
 * This API updates the application record identified by p_application_id and
 * p_object_version_number. An application may be for one or more vacancies,
 * and is similar to a period of service for an employee. This API allows
 * changes to attributes of an application other than those related to changes
 * in the applicant assignment. You can change these attributes of an
 * application at any time before the termination of the application.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The application must exist in the relevant business group on the effective
 * date.
 *
 * <p><b>Post Success</b><br>
 * The API successfully updates the application record.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the application record and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_application_id Application record that needs to be modified.
 * @param p_object_version_number Pass in the current version number of the
 * application to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated application. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_comments Comment text.
 * @param p_current_employer Current employer of the applicant.
 * @param p_projected_hire_date Projected hire date.
 * @param p_termination_reason Termination Reason. Valid values are defined by
 * the TERM_APL_REASON lookup type.
 * @param p_appl_attribute_category This context value determines which
 * flexfield structure to use with the descriptive flexfield segments.
 * @param p_appl_attribute1 Descriptive flexfield segment.
 * @param p_appl_attribute2 Descriptive flexfield segment.
 * @param p_appl_attribute3 Descriptive flexfield segment.
 * @param p_appl_attribute4 Descriptive flexfield segment.
 * @param p_appl_attribute5 Descriptive flexfield segment.
 * @param p_appl_attribute6 Descriptive flexfield segment.
 * @param p_appl_attribute7 Descriptive flexfield segment.
 * @param p_appl_attribute8 Descriptive flexfield segment.
 * @param p_appl_attribute9 Descriptive flexfield segment.
 * @param p_appl_attribute10 Descriptive flexfield segment.
 * @param p_appl_attribute11 Descriptive flexfield segment.
 * @param p_appl_attribute12 Descriptive flexfield segment.
 * @param p_appl_attribute13 Descriptive flexfield segment.
 * @param p_appl_attribute14 Descriptive flexfield segment.
 * @param p_appl_attribute15 Descriptive flexfield segment.
 * @param p_appl_attribute16 Descriptive flexfield segment.
 * @param p_appl_attribute17 Descriptive flexfield segment.
 * @param p_appl_attribute18 Descriptive flexfield segment.
 * @param p_appl_attribute19 Descriptive flexfield segment.
 * @param p_appl_attribute20 Descriptive flexfield segment.
 * @rep:displayname Update Application Details
 * @rep:category BUSINESS_ENTITY PER_APPLICANT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_apl_details
  (p_validate                     in      boolean  default false
  ,p_application_id               in      number
  ,p_object_version_number        in out nocopy  number
  ,p_effective_date               in      date
  ,p_comments                     in      varchar2 default hr_api.g_varchar2
  ,p_current_employer             in      varchar2 default hr_api.g_varchar2
  ,p_projected_hire_date          in      date     default hr_api.g_date
  ,p_termination_reason           in      varchar2 default hr_api.g_varchar2
  ,p_appl_attribute_category      in      varchar2 default hr_api.g_varchar2
  ,p_appl_attribute1              in      varchar2 default hr_api.g_varchar2
  ,p_appl_attribute2              in      varchar2 default hr_api.g_varchar2
  ,p_appl_attribute3              in      varchar2 default hr_api.g_varchar2
  ,p_appl_attribute4              in      varchar2 default hr_api.g_varchar2
  ,p_appl_attribute5              in      varchar2 default hr_api.g_varchar2
  ,p_appl_attribute6              in      varchar2 default hr_api.g_varchar2
  ,p_appl_attribute7              in      varchar2 default hr_api.g_varchar2
  ,p_appl_attribute8              in      varchar2 default hr_api.g_varchar2
  ,p_appl_attribute9              in      varchar2 default hr_api.g_varchar2
  ,p_appl_attribute10             in      varchar2 default hr_api.g_varchar2
  ,p_appl_attribute11             in      varchar2 default hr_api.g_varchar2
  ,p_appl_attribute12             in      varchar2 default hr_api.g_varchar2
  ,p_appl_attribute13             in      varchar2 default hr_api.g_varchar2
  ,p_appl_attribute14             in      varchar2 default hr_api.g_varchar2
  ,p_appl_attribute15             in      varchar2 default hr_api.g_varchar2
  ,p_appl_attribute16             in      varchar2 default hr_api.g_varchar2
  ,p_appl_attribute17             in      varchar2 default hr_api.g_varchar2
  ,p_appl_attribute18             in      varchar2 default hr_api.g_varchar2
  ,p_appl_attribute19             in      varchar2 default hr_api.g_varchar2
  ,p_appl_attribute20             in      varchar2 default hr_api.g_varchar2
  );
end hr_application_api;

 

/
