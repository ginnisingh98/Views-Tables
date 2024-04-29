--------------------------------------------------------
--  DDL for Package HR_SA_PREVIOUS_EMPLOYMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_SA_PREVIOUS_EMPLOYMENT_API" AUTHID CURRENT_USER as
/* $Header: pepemsai.pkh 120.1 2005/10/02 02:20:34 aroussel $ */
/*#
 * This package contains previous employment APIs for Saudi Arabia.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Previous Employment for Saudi Arabia
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_sa_previous_employer >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a previous employer record for a person in a Saudi Arabia
 * business group.
 *
 * The API calls the generic API create_previous_employer, with parameters as
 * appropriate for the Saudi person. As this API is effectively an alternative
 * to the API create_previous_employer, see that API for further explanation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * See API create_previous_employer
 *
 * <p><b>Post Success</b><br>
 * The API successfully creates a previous employer record in the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the previous employer record and raises an error.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_business_group_id Uniquely identifies the business group in which
 * the previous employer record is created. It must be the same as the person's
 * own business group.
 * @param p_person_id Uniquely identifies the person for whom the previous
 * employer record is created. The person type cannot be 'OTHER'.
 * @param p_party_id Uniquely identiies employer information for a party, so
 * that users can see the information for all instances of the person in
 * different business groups.
 * @param p_start_date The start date of the employee's previous employment.
 * @param p_end_date The end date of the employee's previous employment.
 * @param p_period_years The number of years the employee worked with the
 * previous employer. If left null, the process calculates this based on the
 * start date and end date. For example, if the start date is '01-JAN-2000' and
 * the end date is '05-MAR-2004', the process sets four years.
 * @param p_period_months The number of months the employee worked over and
 * above the years worked. If left null, the process calculates this from the
 * start and end date. For example, if the start date is '01-JAN-2000' and the
 * end date is '05-MAR-2004', the the process sets two months.
 * @param p_period_days The number of days worked over and above the years and
 * months worked. If left null, the process calculatese this from the start and
 * end date. For example, if the start date is '01-JAN-2000' and the end date
 * is '05-MAR-2004', the process sets five days.
 * @param p_employer_name The name of the previous employer
 * @param p_employer_country The country in which the previous employer is
 * located. For global previous employers, set to the country in which the
 * company headquarters is located or the country in which the employment took
 * place.
 * @param p_employer_address The address of the previous employer.
 * @param p_employer_type Type of previous employer. Valid values for this
 * field are defined by the lookup type 'PREV_EMP_TYPE'. Values your enterprise
 * defines for this lookup type should be high level, vertical descriptions for
 * the industry, for example, 'Public Sector', 'Manufacturing', etc.
 * @param p_employer_subtype The subtype of the previous employer. Valid values
 * for this field are defined by the lookup type 'PREV_EMP_SUBTYPE'. Values
 * your enterprise defines for this lookup type should identify the employer
 * type more specifically. For example, for the employer type of 'Public
 * Sector', you can define subtypes such as 'Civil Service', 'Teaching', or
 * 'Health Care'.
 * @param p_description Description of the previous employer.
 * @param p_all_assignments Set to 'Y' if the previous employment applies to
 * all of the employee's assignments. Otherwise set to 'N'. In order to create
 * previous job usage records (using the create_previous_job_usage API), set
 * this flag to 'N'.
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
 * @param p_termination_reason Termination reason
 * @param p_previous_employer_id If p_validate is false, then this uniquely
 * identifies the previous employer created. If p_validate is true, then set to
 * null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created previous employer. If p_validate is true, then
 * the value will be null.
 * @rep:displayname Create Previous Employer for Saudi Arabia
 * @rep:category BUSINESS_ENTITY PER_PREVIOUS_EMPLOYMENT
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_sa_previous_employer
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
  ,p_employer_name                IN      varchar2  default null
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
-- |-----------------------< update_sa_previous_employer >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates information for an existing previous employer record for a
 * person in a Saudi Arabia business group.
 *
 * The API calls the generic API update_previous_employer, with parameters set
 * as appropriate for the Saudi person. As this API is effectively an
 * alternative to the API update_previous_employer, see that API for further
 * explanation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * See API update_previous_employer
 *
 * <p><b>Post Success</b><br>
 * The API successfully updates the previous employer record in the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the previous employer record and raises an error.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_previous_employer_id Uniquely identifies the previous employer
 * record to be updated.
 * @param p_start_date The start date of the employee's previous employment.
 * @param p_end_date The end date of the employee's previous employment.
 * @param p_period_years The number of years the employee worked with the
 * previous employer. If left null, the process calculates this based on the
 * start date and end date. For example, if the start date is '01-JAN-2000' and
 * the end date is '05-MAR-2004', the process sets four years.
 * @param p_period_months The number of months the employee worked over and
 * above the years worked. If left null, the process calculates this from the
 * start and end date. For example, if the start date is '01-JAN-2000' and the
 * end date is '05-MAR-2004', the the process sets two months.
 * @param p_period_days The number of days worked over and above the years and
 * months worked. If left null, the process calculatese this from the start and
 * end date. For example, if the start date is '01-JAN-2000' and the end date
 * is '05-MAR-2004', the process sets five days.
 * @param p_employer_name The name of the previous employer
 * @param p_employer_country The country in which the previous employer is
 * located. For global previous employers, set to the country in which the
 * company headquarters is located or the country in which the employment took
 * place.
 * @param p_employer_address The address of the previous employer.
 * @param p_employer_type Type of previous employer. Valid values for this
 * field are defined by the lookup type 'PREV_EMP_TYPE'. Values your enterprise
 * defines for this lookup type should be high level, vertical descriptions for
 * the industry, for example, 'Public Sector', 'Manufacturing', etc.
 * @param p_employer_subtype The subtype of the previous employer. Valid values
 * for this field are defined by the lookup type 'PREV_EMP_SUBTYPE'. Values
 * your enterprise defines for this lookup type should identify the employer
 * type more specifically. For example, for the employer type of 'Public
 * Sector', you can define subtypes such as 'Civil Service', 'Teaching', or
 * 'Health Care'.
 * @param p_description Description of the previous employer.
 * @param p_all_assignments Set to 'Y' if the previous employment applies to
 * all of the employee's assignments. Otherwise set to 'N'. In order to create
 * previous job usage records (using the create_previous_job_usage API), set
 * this flag to 'N'.
 * @param p_pem_attribute_category Descriptive flexfield structure defining
 * column.
 * @param p_pem_attribute1 Descriptive flexfield structure defining column.
 * @param p_pem_attribute2 Descriptive flexfield structure defining column.
 * @param p_pem_attribute3 Descriptive flexfield structure defining column.
 * @param p_pem_attribute4 Descriptive flexfield structure defining column.
 * @param p_pem_attribute5 Descriptive flexfield structure defining column.
 * @param p_pem_attribute6 Descriptive flexfield structure defining column.
 * @param p_pem_attribute7 Descriptive flexfield structure defining column.
 * @param p_pem_attribute8 Descriptive flexfield structure defining column.
 * @param p_pem_attribute9 Descriptive flexfield structure defining column.
 * @param p_pem_attribute10 Descriptive flexfield structure defining column.
 * @param p_pem_attribute11 Descriptive flexfield structure defining column.
 * @param p_pem_attribute12 Descriptive flexfield structure defining column.
 * @param p_pem_attribute13 Descriptive flexfield structure defining column.
 * @param p_pem_attribute14 Descriptive flexfield structure defining column.
 * @param p_pem_attribute15 Descriptive flexfield structure defining column.
 * @param p_pem_attribute16 Descriptive flexfield structure defining column.
 * @param p_pem_attribute17 Descriptive flexfield structure defining column.
 * @param p_pem_attribute18 Descriptive flexfield structure defining column.
 * @param p_pem_attribute19 Descriptive flexfield structure defining column.
 * @param p_pem_attribute20 Descriptive flexfield structure defining column.
 * @param p_pem_attribute21 Descriptive flexfield structure defining column.
 * @param p_pem_attribute22 Descriptive flexfield structure defining column.
 * @param p_pem_attribute23 Descriptive flexfield structure defining column.
 * @param p_pem_attribute24 Descriptive flexfield structure defining column.
 * @param p_pem_attribute25 Descriptive flexfield structure defining column.
 * @param p_pem_attribute26 Descriptive flexfield structure defining column.
 * @param p_pem_attribute27 Descriptive flexfield structure defining column.
 * @param p_pem_attribute28 Descriptive flexfield structure defining column.
 * @param p_pem_attribute29 Descriptive flexfield structure defining column.
 * @param p_pem_attribute30 Descriptive flexfield structure defining column.
 * @param p_termination_reason Termination Reason
 * @param p_object_version_number Pass in the current version number of the
 * previous employer to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated previous
 * employer. If p_validate is true will be set to the same value which was
 * passed in.
 * @rep:displayname Update Previous Employer for Saudi Arabia
 * @rep:category BUSINESS_ENTITY PER_PREVIOUS_EMPLOYMENT
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_sa_previous_employer
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
end hr_sa_previous_employment_api;

 

/
