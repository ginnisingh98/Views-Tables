--------------------------------------------------------
--  DDL for Package HR_SALARY_SURVEY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_SALARY_SURVEY_API" AUTHID CURRENT_USER as
/* $Header: pepssapi.pkh 120.1 2005/10/02 02:22:51 aroussel $ */
/*#
 * This package contains APIs to create and maintain salary survey master
 * details, namely create_salary_survey, update_salary_survey, and
 * delete_salary_survey.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Salary Survey
*/
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_salary_survey >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new Salary Survey.
 *
 * The API sets up a salary survey header with details such as Survey Name,
 * Identifier, Survey Company, Survey Type, and so on.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The list of companies providing the survey data must be set up in the lookup
 * 'SURVEY_COMPANY'.
 *
 * <p><b>Post Success</b><br>
 * A salary survey header record is created in the database.
 *
 * <p><b>Post Failure</b><br>
 * The Salary Survey is not created and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_survey_name {@rep:casecolumn PER_SALARY_SURVEYS.SURVEY_NAME}
 * @param p_survey_company_code Company code that the survey applies to. Valid
 * values are defined by 'SURVEY_COMPANY' lookup type.
 * @param p_identifier {@rep:casecolumn PER_SALARY_SURVEYS.IDENTIFIER}
 * @param p_survey_type_code The time basis for recording actual salary values,
 * such as Annual, Monthly, or Hourly. Valid values are identified by the
 * 'PAY_BASIS' lookup type.
 * @param p_base_region {@rep:casecolumn PER_SALARY_SURVEYS.BASE_REGION}
 * @param p_effective_date Reference date for validating lookup values,
 * applicable within the active date range. This date does not determine when
 * the changes take effect.
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
 * @param p_salary_survey_id If p_validate is false, uniquely identifies the
 * survey created. If p_validate is true, set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created Salary Survey. If p_validate is true, then the
 * value will be null.
 * @rep:displayname Create Salary Survey
 * @rep:category BUSINESS_ENTITY PER_SALARY_SURVEY
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_salary_survey
  (p_validate                      in     boolean  default false
  ,p_survey_name                   in     varchar2
  ,p_survey_company_code           in     varchar2
  ,p_identifier                    in     varchar2
--ras  ,p_currency_code                 in     varchar2
  ,p_survey_type_code              in     varchar2
  ,p_base_region                   in     varchar2 default null
  ,p_effective_date                in     date     default null
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
  ,p_salary_survey_id                 out nocopy number
  ,p_object_version_number            out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_salary_survey >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an existing Salary Survey header record.
 *
 * After updating the record, the API sets values for all the out parameters.
 * If any validation check fails the process raises an error.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * You must pass a salary_survey_id and object_version_number for an existing
 * survey to the API.
 *
 * <p><b>Post Success</b><br>
 * Salary survey header is updated with the details provided.
 *
 * <p><b>Post Failure</b><br>
 * The Salary Survey will not be updated and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_survey_name {@rep:casecolumn PER_SALARY_SURVEYS.SURVEY_NAME}
 * @param p_survey_type_code The time basis for recording actual salary values,
 * such as Annual, Monthly, or Hourly. Valid values are identified by the
 * 'PAY_BASIS' lookup type.
 * @param p_base_region {@rep:casecolumn PER_SALARY_SURVEYS.BASE_REGION}
 * @param p_effective_date Reference date for validating lookup values,
 * applicable within the active date range. This date does not determine when
 * the changes take effect.
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
 * @param p_salary_survey_id Identifies the salary survey to be updated.
 * @param p_object_version_number Pass in the current version number of the
 * salary survey to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated salary survey. If
 * p_validate is true will be set to the same value which was passed in.
 * @rep:displayname Update Salary Survey
 * @rep:category BUSINESS_ENTITY PER_SALARY_SURVEY
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_salary_survey
  (p_validate                      in     boolean  default false
  ,p_survey_name                   in     varchar2 default hr_api.g_varchar2
--ras  ,p_currency_code                 in     varchar2 default hr_api.g_varchar2
  ,p_survey_type_code              in     varchar2 default hr_api.g_varchar2
  ,p_base_region                   in     varchar2 default hr_api.g_varchar2
  ,p_effective_date                in     date     default hr_api.g_date
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
  ,p_salary_survey_id              in     number
  ,p_object_version_number         in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_salary_survey >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a Salary Survey header.
 *
 * You can delete Salary Survey details only when there are no existing survey
 * lines or mappings for the survey.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A salary_survey_id and object version number for a survey that exists must
 * be passed to the API.
 *
 * <p><b>Post Success</b><br>
 * The survey is deleted.
 *
 * <p><b>Post Failure</b><br>
 * The Salary Survey is not deleted and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_salary_survey_id Identifies the salary survey to be deleted.
 * @param p_object_version_number Current version number of the salary survey
 * to be deleted.
 * @rep:displayname Delete Salary Survey
 * @rep:category BUSINESS_ENTITY PER_SALARY_SURVEY
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_salary_survey
  (p_validate                      in     boolean  default false
  ,p_salary_survey_id              in     number
  ,p_object_version_number         in     number
  );
--
end hr_salary_survey_api;

 

/
