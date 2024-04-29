--------------------------------------------------------
--  DDL for Package HR_KW_PREVIOUS_EMPLOYMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_KW_PREVIOUS_EMPLOYMENT_API" AUTHID CURRENT_USER as
/* $Header: pepemkwi.pkh 120.1 2005/10/02 02:43:42 aroussel $ */
/*#
 * This package contains previous employment APIs.
 * @rep:scope public
 * @rep:product PER
 * @rep:displayname Previous Employment for Kuwait
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_kw_previous_employer >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a previous employer record.
 *
 * This API is effectively an alternative to the API create_previous_employer.
 * If p_validate is set to false, a previous employer is created.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The employee must already exist.
 *
 * <p><b>Post Success</b><br>
 * The previous employer will be successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the previous employer and raises an error.
 *
 * @param p_effective_date Effective date of the program running
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_business_group_id Business group ID of the person.
 * @param p_person_id Pass the person_id of the employee for whom the previous
 * employer details are being entered.
 * @param p_party_id Party ID of the person.
 * @param p_start_date The date from which the employee worked with the
 * previous employer.
 * @param p_end_date The date on which the employee left the previous employer.
 * @param p_period_years Number of years of previous employment based on the
 * employment start date and end date.
 * @param p_period_months Number of months of previous employment based on the
 * employment start date and end date.
 * @param p_period_days Remaining number of days of employment based on number
 * of days in period.
 * @param p_employer_name Previous employer name.
 * @param p_employer_country The country in which the previous employer is
 * located.
 * @param p_employer_address Address of the previous employer.
 * @param p_employer_type Type of previous employer. Valid values for this
 * field are Public Sector, Commercial, and Unknown.
 * @param p_employer_subtype Subtype of the previous employer. This is
 * dependent on employer type.
 * @param p_description Description of the previous employer.
 * @param p_all_assignments Indicates whether previous employer is applicable
 * to all assignments of the current employer. The default value is N.The valid
 * values for this field are Y or N.If this previous employer is applicable to
 * all assignments of the current employer, pass Y.
 * @param p_pem_attribute_category Descriptive flexfield structure defining
 * column.
 * @param p_pem_attribute1 Descriptive flexfield column
 * @param p_pem_attribute2 Descriptive flexfield column
 * @param p_pem_attribute3 Descriptive flexfield column
 * @param p_pem_attribute4 Descriptive flexfield column
 * @param p_pem_attribute5 Descriptive flexfield column
 * @param p_pem_attribute6 Descriptive flexfield column
 * @param p_pem_attribute7 Descriptive flexfield column
 * @param p_pem_attribute8 Descriptive flexfield column
 * @param p_pem_attribute9 Descriptive flexfield column
 * @param p_pem_attribute10 Descriptive flexfield column
 * @param p_pem_attribute11 Descriptive flexfield column
 * @param p_pem_attribute12 Descriptive flexfield column
 * @param p_pem_attribute13 Descriptive flexfield column
 * @param p_pem_attribute14 Descriptive flexfield column
 * @param p_pem_attribute15 Descriptive flexfield column
 * @param p_pem_attribute16 Descriptive flexfield column
 * @param p_pem_attribute17 Descriptive flexfield column
 * @param p_pem_attribute18 Descriptive flexfield column
 * @param p_pem_attribute19 Descriptive flexfield column
 * @param p_pem_attribute20 Descriptive flexfield column
 * @param p_pem_attribute21 Descriptive flexfield column
 * @param p_pem_attribute22 Descriptive flexfield column
 * @param p_pem_attribute23 Descriptive flexfield column
 * @param p_pem_attribute24 Descriptive flexfield column
 * @param p_pem_attribute25 Descriptive flexfield column
 * @param p_pem_attribute26 Descriptive flexfield column
 * @param p_pem_attribute27 Descriptive flexfield column
 * @param p_pem_attribute28 Descriptive flexfield column
 * @param p_pem_attribute29 Descriptive flexfield column
 * @param p_pem_attribute30 Descriptive flexfield column
 * @param p_termination_reason Termination reason.
 * @param p_previous_employer_id Primary key of the table. This value is
 * generated by a sequence and will be passed to the calling procedure.
 * @param p_object_version_number After a new record is is created object
 * version number is set to 1.
 * @rep:displayname Create Previous Employer for Kuwait
 * @rep:category BUSINESS_ENTITY PER_PREVIOUS_EMPLOYMENT
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_kw_previous_employer
(  p_effective_date               IN      date
  ,p_validate                     IN      boolean   default false
  ,p_business_group_id            IN      number
  ,p_person_id                    IN      number
  ,p_party_id                     IN      number    default null
  ,p_start_date                   IN      date      default null
  ,p_end_date                     IN      date      default null
  ,p_period_years                 IN      number    default null
  ,p_period_months                IN      number    default null
  ,p_period_days                  IN      number    default null
  ,p_employer_name                IN      varchar2
  ,p_employer_country             IN      varchar2  default null
  ,p_employer_address             IN      varchar2  default null
  ,p_employer_type                IN      varchar2  default null
  ,p_employer_subtype             IN      varchar2  default null
  ,p_description                  IN      varchar2  default null
  ,p_all_assignments              IN      varchar2  default 'N'
  ,p_pem_attribute_category       IN      varchar2  default null
  ,p_pem_attribute1               IN      varchar2  default null
  ,p_pem_attribute2               IN      varchar2  default null
  ,p_pem_attribute3               IN      varchar2  default null
  ,p_pem_attribute4               IN      varchar2  default null
  ,p_pem_attribute5               IN      varchar2  default null
  ,p_pem_attribute6               IN      varchar2  default null
  ,p_pem_attribute7               IN      varchar2  default null
  ,p_pem_attribute8               IN      varchar2  default null
  ,p_pem_attribute9               IN      varchar2  default null
  ,p_pem_attribute10              IN      varchar2  default null
  ,p_pem_attribute11              IN      varchar2  default null
  ,p_pem_attribute12              IN      varchar2  default null
  ,p_pem_attribute13              IN      varchar2  default null
  ,p_pem_attribute14              IN      varchar2  default null
  ,p_pem_attribute15              IN      varchar2  default null
  ,p_pem_attribute16              IN      varchar2  default null
  ,p_pem_attribute17              IN      varchar2  default null
  ,p_pem_attribute18              IN      varchar2  default null
  ,p_pem_attribute19              IN      varchar2  default null
  ,p_pem_attribute20              IN      varchar2  default null
  ,p_pem_attribute21              IN      varchar2  default null
  ,p_pem_attribute22              IN      varchar2  default null
  ,p_pem_attribute23              IN      varchar2  default null
  ,p_pem_attribute24              IN      varchar2  default null
  ,p_pem_attribute25              IN      varchar2  default null
  ,p_pem_attribute26              IN      varchar2  default null
  ,p_pem_attribute27              IN      varchar2  default null
  ,p_pem_attribute28              IN      varchar2  default null
  ,p_pem_attribute29              IN      varchar2  default null
  ,p_pem_attribute30              IN      varchar2  default null
  ,p_termination_reason           IN      varchar2  default null
  ,p_previous_employer_id         OUT NOCOPY     number
  ,p_object_version_number        OUT NOCOPY     number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_kw_previous_employer >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the existing previous employer values.
 *
 * This API is effectively an alternative to the API update_previous_job. If
 * p_validate is set to false, the previous job is updated.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The previous job record identified by p_previous_job_id must already exist.
 *
 * <p><b>Post Success</b><br>
 * The previous employer values are changed.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the previous employer and raises an error.
 *
 * @param p_effective_date Effective date of the program running
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_previous_employer_id Primary key of the table. This value is
 * generated by a sequence and will be passed to the calling procedure.
 * @param p_start_date The date from which the employee worked with the
 * previous employer.
 * @param p_end_date The date on which the employee left the previous employer.
 * @param p_period_years OUT Number of years for the previous employment. This
 * is calculated based on the start date and end date.
 * @param p_period_months OUT Number of months for the previous employment.
 * This is calculated based on the start date and end date.
 * @param p_period_days OUT Remaining number of days. It is calculated from
 * period days.
 * @param p_employer_name Previous employer name.
 * @param p_employer_country The country in which the previous employer is
 * located.
 * @param p_employer_address Address of the previous employer.
 * @param p_employer_type Type of previous employer. Valid values for this
 * field are Public Sector, Commercial, and Unknown.
 * @param p_employer_subtype Subtype of the previous employer. This is
 * dependent on employer type.
 * @param p_description Description of the previous employer.
 * @param p_all_assignments Indicates whether previous employer is applicable
 * to all assignments of the current employer. The default value is N.The valid
 * values for this field are Y or N.If this previous employer is applicable to
 * all assignments of the current employer, pass Y.
 * @param p_pem_attribute_category Descriptive flexfield structure defining
 * column.
 * @param p_pem_attribute1 Descriptive flexfield column
 * @param p_pem_attribute2 Descriptive flexfield column
 * @param p_pem_attribute3 Descriptive flexfield column
 * @param p_pem_attribute4 Descriptive flexfield column
 * @param p_pem_attribute5 Descriptive flexfield column
 * @param p_pem_attribute6 Descriptive flexfield column
 * @param p_pem_attribute7 Descriptive flexfield column
 * @param p_pem_attribute8 Descriptive flexfield column
 * @param p_pem_attribute9 Descriptive flexfield column
 * @param p_pem_attribute10 Descriptive flexfield column
 * @param p_pem_attribute11 Descriptive flexfield column
 * @param p_pem_attribute12 Descriptive flexfield column
 * @param p_pem_attribute13 Descriptive flexfield column
 * @param p_pem_attribute14 Descriptive flexfield column
 * @param p_pem_attribute15 Descriptive flexfield column
 * @param p_pem_attribute16 Descriptive flexfield column
 * @param p_pem_attribute17 Descriptive flexfield column
 * @param p_pem_attribute18 Descriptive flexfield column
 * @param p_pem_attribute19 Descriptive flexfield column
 * @param p_pem_attribute20 Descriptive flexfield column
 * @param p_pem_attribute21 Descriptive flexfield column
 * @param p_pem_attribute22 Descriptive flexfield column
 * @param p_pem_attribute23 Descriptive flexfield column
 * @param p_pem_attribute24 Descriptive flexfield column
 * @param p_pem_attribute25 Descriptive flexfield column
 * @param p_pem_attribute26 Descriptive flexfield column
 * @param p_pem_attribute27 Descriptive flexfield column
 * @param p_pem_attribute28 Descriptive flexfield column
 * @param p_pem_attribute29 Descriptive flexfield column
 * @param p_pem_attribute30 Descriptive flexfield column
 * @param p_termination_reason Termination reason.
 * @param p_object_version_number After a new record is is created object
 * version number is set to 1.
 * @rep:displayname Update Previous Employer for Kuwait
 * @rep:category BUSINESS_ENTITY PER_PREVIOUS_EMPLOYMENT
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_kw_previous_employer
(  p_effective_date             IN      date
  ,p_validate                   IN      boolean   default false
  ,p_previous_employer_id       IN      number
  ,p_start_date                 IN      date      default hr_api.g_date
  ,p_end_date                   IN      date      default hr_api.g_date
  ,p_period_years               IN      number    default hr_api.g_number
  ,p_period_months              IN      number    default hr_api.g_number
  ,p_period_days                IN      number    default hr_api.g_number
  ,p_employer_name              IN      varchar2  default hr_api.g_varchar2
  ,p_employer_country           IN      varchar2  default hr_api.g_varchar2
  ,p_employer_address           IN      varchar2  default hr_api.g_varchar2
  ,p_employer_type              IN      varchar2  default hr_api.g_varchar2
  ,p_employer_subtype           IN      varchar2  default hr_api.g_varchar2
  ,p_description                IN      varchar2  default hr_api.g_varchar2
  ,p_all_assignments            IN      varchar2  default 'N'
  ,p_pem_attribute_category     IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute1             IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute2             IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute3             IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute4             IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute5             IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute6             IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute7             IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute8             IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute9             IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute10            IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute11            IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute12            IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute13            IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute14            IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute15            IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute16            IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute17            IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute18            IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute19            IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute20            IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute21            IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute22            IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute23            IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute24            IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute25            IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute26            IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute27            IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute28            IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute29            IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute30            IN      varchar2  default hr_api.g_varchar2
  ,p_termination_reason         IN      varchar2  default hr_api.g_varchar2
  ,p_object_version_number      IN OUT NOCOPY  number
  );
--
end hr_kw_previous_employment_api;

 

/
