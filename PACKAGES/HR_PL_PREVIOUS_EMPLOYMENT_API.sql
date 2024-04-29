--------------------------------------------------------
--  DDL for Package HR_PL_PREVIOUS_EMPLOYMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PL_PREVIOUS_EMPLOYMENT_API" AUTHID CURRENT_USER as
/* $Header: pepempli.pkh 120.1 2005/10/02 02:43:48 aroussel $ */
/*#
 * This package contains previous employment APIs.
 * @rep:scope public
 * @rep:product PER
 * @rep:displayname Previous Employment for Poland
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_pl_previous_employer >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates previous employer.
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
 * The previous employer will not be created and an error will be raised.
 *
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_business_group_id ID of person's business group.
 * @param p_person_id Identifies the person for whom you create the previous
 * employer record.
 * @param p_party_id Party ID.
 * @param p_start_date The date from which the employee worked with the
 * previous employer. This field is mandatory if employer type is 'Parallel'.
 * @param p_end_date The date on which the employee left the previous employer.
 * @param p_period_years Number of years the employee worked. This is
 * calculated based on the start date and the end date.
 * @param p_period_months Number of months the employee worked. This is
 * calculated based on the start date and end date.
 * @param p_period_days Remaining number of days and is calculated from period
 * days.
 * @param p_employer_name Previous employer name.
 * @param p_employer_country The country in which the previous employer is
 * located.
 * @param p_employer_address Address of the previous employer.
 * @param p_employer_type Type of previous employer. Valid values are defined
 * by PREV_EMP_TYPE lookup type.
 * @param p_employer_subtype Subtype of the previous employer. This is
 * dependent on employer type. Valid values are defined by PREV_EMP_SUBTYPE
 * lookup type.
 * @param p_description Description of the previous employer.
 * @param p_all_assignments Indicates whether previous employer is applicable
 * to all assignments of the current employer.
 * @param p_pem_attribute_category This context value determines which
 * flexfield structure to use with the descriptive flexfield columns.
 * @param p_pem_attribute1 Descriptive flexfield column.
 * @param p_pem_attribute2 Descriptive flexfield column.
 * @param p_pem_attribute3 Descriptive flexfield column.
 * @param p_pem_attribute4 Descriptive flexfield column.
 * @param p_pem_attribute5 Descriptive flexfield column.
 * @param p_pem_attribute6 Descriptive flexfield column.
 * @param p_pem_attribute7 Descriptive flexfield column.
 * @param p_pem_attribute8 Descriptive flexfield column.
 * @param p_pem_attribute9 Descriptive flexfield column.
 * @param p_pem_attribute10 Descriptive flexfield column.
 * @param p_pem_attribute11 Descriptive flexfield column.
 * @param p_pem_attribute12 Descriptive flexfield column.
 * @param p_pem_attribute13 Descriptive flexfield column.
 * @param p_pem_attribute14 Descriptive flexfield column.
 * @param p_pem_attribute15 Descriptive flexfield column.
 * @param p_pem_attribute16 Descriptive flexfield column.
 * @param p_pem_attribute17 Descriptive flexfield column.
 * @param p_pem_attribute18 Descriptive flexfield column.
 * @param p_pem_attribute19 Descriptive flexfield column.
 * @param p_pem_attribute20 Descriptive flexfield column.
 * @param p_pem_attribute21 Descriptive flexfield column.
 * @param p_pem_attribute22 Descriptive flexfield column.
 * @param p_pem_attribute23 Descriptive flexfield column.
 * @param p_pem_attribute24 Descriptive flexfield column.
 * @param p_pem_attribute25 Descriptive flexfield column.
 * @param p_pem_attribute26 Descriptive flexfield column.
 * @param p_pem_attribute27 Descriptive flexfield column.
 * @param p_pem_attribute28 Descriptive flexfield column.
 * @param p_pem_attribute29 Descriptive flexfield column.
 * @param p_pem_attribute30 Descriptive flexfield column.
 * @param p_pem_information_category This context value determines which
 * flexfield structure to use with the developer descriptive flexfield columns.
 * @param direction_number Direction number of the previous employer.
 * @param telephone Telephone number of the previous employer.
 * @param mobile Mobile number of the previous employer.
 * @param fax Fax number of the previous employer.
 * @param e_mail Email address of the previous employer.
 * @param contact_information Additional contact information for previous
 * employer.
 * @param p_pem_information7 Developer Descriptive flexfield column.
 * @param p_pem_information8 Developer Descriptive flexfield column.
 * @param p_pem_information9 Developer Descriptive flexfield column.
 * @param p_pem_information10 Developer Descriptive flexfield column.
 * @param p_pem_information11 Developer Descriptive flexfield column.
 * @param p_pem_information12 Developer Descriptive flexfield column.
 * @param p_pem_information13 Developer Descriptive flexfield column.
 * @param p_pem_information14 Developer Descriptive flexfield column.
 * @param p_pem_information15 Developer Descriptive flexfield column.
 * @param p_pem_information16 Developer Descriptive flexfield column.
 * @param p_pem_information17 Developer Descriptive flexfield column.
 * @param p_pem_information18 Developer Descriptive flexfield column.
 * @param p_pem_information19 Developer Descriptive flexfield column.
 * @param p_pem_information20 Developer Descriptive flexfield column.
 * @param p_pem_information21 Developer Descriptive flexfield column.
 * @param p_pem_information22 Developer Descriptive flexfield column.
 * @param p_pem_information23 Developer Descriptive flexfield column.
 * @param p_pem_information24 Developer Descriptive flexfield column.
 * @param p_pem_information25 Developer Descriptive flexfield column.
 * @param p_pem_information26 Developer Descriptive flexfield column.
 * @param p_pem_information27 Developer Descriptive flexfield column.
 * @param p_pem_information28 Developer Descriptive flexfield column.
 * @param p_pem_information29 Developer Descriptive flexfield column.
 * @param p_pem_information30 Developer Descriptive flexfield column.
 * @param p_previous_employer_id If p_validate is false, then this uniquely
 * identifies the created previous employer. If p_validate is true, then set to
 * null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created previous employer. If p_validate is true, then
 * the value will be null.
 * @rep:displayname Create Previous Employer for Poland
 * @rep:category BUSINESS_ENTITY PER_PREVIOUS_EMPLOYMENT
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_pl_previous_employer
(
   p_effective_date               IN      date
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
  ,p_pem_information_category     IN      varchar2  default null
  ,Direction_Number               IN      varchar2  default null
  ,Telephone			          IN      varchar2  default null
  ,Mobile			          IN      varchar2  default null
  ,Fax				          IN      varchar2  default null
  ,E_mail			          IN      varchar2  default null
  ,Contact_Information            IN      varchar2  default null
  ,p_pem_information7             IN      varchar2  default null
  ,p_pem_information8             IN      varchar2  default null
  ,p_pem_information9             IN      varchar2  default null
  ,p_pem_information10            IN      varchar2  default null
  ,p_pem_information11            IN      varchar2  default null
  ,p_pem_information12            IN      varchar2  default null
  ,p_pem_information13            IN      varchar2  default null
  ,p_pem_information14            IN      varchar2  default null
  ,p_pem_information15            IN      varchar2  default null
  ,p_pem_information16            IN      varchar2  default null
  ,p_pem_information17            IN      varchar2  default null
  ,p_pem_information18            IN      varchar2  default null
  ,p_pem_information19            IN      varchar2  default null
  ,p_pem_information20            IN      varchar2  default null
  ,p_pem_information21            IN      varchar2  default null
  ,p_pem_information22            IN      varchar2  default null
  ,p_pem_information23            IN      varchar2  default null
  ,p_pem_information24            IN      varchar2  default null
  ,p_pem_information25            IN      varchar2  default null
  ,p_pem_information26            IN      varchar2  default null
  ,p_pem_information27            IN      varchar2  default null
  ,p_pem_information28            IN      varchar2  default null
  ,p_pem_information29            IN      varchar2  default null
  ,p_pem_information30            IN      varchar2  default null
  ,p_previous_employer_id         OUT NOCOPY     number
  ,p_object_version_number        OUT NOCOPY     number
);
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_pl_previous_employer >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API modifies a previous employer.
 *
 * This API is effectively an alternative to the API update_previous_employer.
 * If p_validate is set to false, the previous employer is updated.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The previous employer identified by p_previous_employer_id must already
 * exist.
 *
 * <p><b>Post Success</b><br>
 * The previous employer will be updated.
 *
 * <p><b>Post Failure</b><br>
 * The previous employer will not be updated and an error will be raised.
 *
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_previous_employer_id Identifies the previous employer record to be
 * modified.
 * @param p_start_date The date from which the employee worked with the
 * previous employer. This field is mandatory if employer type is 'Parallel'.
 * @param p_end_date The date on which the employee left the previous employer.
 * @param p_period_years Number of years of previous employment based on the
 * employment start and end dates.
 * @param p_period_months Number of months of previous employment based on the
 * employment start and end dates.
 * @param p_period_days Remaining number of days of employment based on number
 * of days in period.
 * @param p_employer_name Previous employer name.
 * @param p_employer_country The country in which the previous employer is
 * located.
 * @param p_employer_address Address of the previous employer.
 * @param p_employer_type Type of previous employer. Valid values are defined
 * by PREV_EMP_TYPE lookup type.
 * @param p_employer_subtype Subtype of the previous employer. This is
 * dependent on employer type. Valid values are defined by PREV_EMP_SUBTYPE
 * lookup type.
 * @param p_description Description of the previous employer.
 * @param p_all_assignments Indicates whether previous employer is applicable
 * to all assignments of the current employer.
 * @param p_pem_attribute_category This context value determines which
 * flexfield structure to use with the descriptive flexfield columns.
 * @param p_pem_attribute1 Descriptive flexfield column.
 * @param p_pem_attribute2 Descriptive flexfield column.
 * @param p_pem_attribute3 Descriptive flexfield column.
 * @param p_pem_attribute4 Descriptive flexfield column.
 * @param p_pem_attribute5 Descriptive flexfield column.
 * @param p_pem_attribute6 Descriptive flexfield column.
 * @param p_pem_attribute7 Descriptive flexfield column.
 * @param p_pem_attribute8 Descriptive flexfield column.
 * @param p_pem_attribute9 Descriptive flexfield column.
 * @param p_pem_attribute10 Descriptive flexfield column.
 * @param p_pem_attribute11 Descriptive flexfield column.
 * @param p_pem_attribute12 Descriptive flexfield column.
 * @param p_pem_attribute13 Descriptive flexfield column.
 * @param p_pem_attribute14 Descriptive flexfield column.
 * @param p_pem_attribute15 Descriptive flexfield column.
 * @param p_pem_attribute16 Descriptive flexfield column.
 * @param p_pem_attribute17 Descriptive flexfield column.
 * @param p_pem_attribute18 Descriptive flexfield column.
 * @param p_pem_attribute19 Descriptive flexfield column.
 * @param p_pem_attribute20 Descriptive flexfield column.
 * @param p_pem_attribute21 Descriptive flexfield column.
 * @param p_pem_attribute22 Descriptive flexfield column.
 * @param p_pem_attribute23 Descriptive flexfield column.
 * @param p_pem_attribute24 Descriptive flexfield column.
 * @param p_pem_attribute25 Descriptive flexfield column.
 * @param p_pem_attribute26 Descriptive flexfield column.
 * @param p_pem_attribute27 Descriptive flexfield column.
 * @param p_pem_attribute28 Descriptive flexfield column.
 * @param p_pem_attribute29 Descriptive flexfield column.
 * @param p_pem_attribute30 Descriptive flexfield column.
 * @param p_pem_information_category This context value determines which
 * flexfield structure to use with the developer descriptive flexfield columns.
 * @param direction_number Direction number of the previous employer.
 * @param telephone Telephone number of the previous employer.
 * @param mobile Mobile number of the previous employer.
 * @param fax Fax number of the previous employer.
 * @param e_mail Email address of the previous employer.
 * @param contact_information Additional contact information for previous
 * employer.
 * @param p_pem_information7 Developer Descriptive flexfield column.
 * @param p_pem_information8 Developer Descriptive flexfield column.
 * @param p_pem_information9 Developer Descriptive flexfield column.
 * @param p_pem_information10 Developer Descriptive flexfield column.
 * @param p_pem_information11 Developer Descriptive flexfield column.
 * @param p_pem_information12 Developer Descriptive flexfield column.
 * @param p_pem_information13 Developer Descriptive flexfield column.
 * @param p_pem_information14 Developer Descriptive flexfield column.
 * @param p_pem_information15 Developer Descriptive flexfield column.
 * @param p_pem_information16 Developer Descriptive flexfield column.
 * @param p_pem_information17 Developer Descriptive flexfield column.
 * @param p_pem_information18 Developer Descriptive flexfield column.
 * @param p_pem_information19 Developer Descriptive flexfield column.
 * @param p_pem_information20 Developer Descriptive flexfield column.
 * @param p_pem_information21 Developer Descriptive flexfield column.
 * @param p_pem_information22 Developer Descriptive flexfield column.
 * @param p_pem_information23 Developer Descriptive flexfield column.
 * @param p_pem_information24 Developer Descriptive flexfield column.
 * @param p_pem_information25 Developer Descriptive flexfield column.
 * @param p_pem_information26 Developer Descriptive flexfield column.
 * @param p_pem_information27 Developer Descriptive flexfield column.
 * @param p_pem_information28 Developer Descriptive flexfield column.
 * @param p_pem_information29 Developer Descriptive flexfield column.
 * @param p_pem_information30 Developer Descriptive flexfield column.
 * @param p_object_version_number Pass in the current version number of the
 * previous employer to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated previous
 * employer. If p_validate is true will be set to the same value which was
 * passed in.
 * @rep:displayname Update Previous Employer for Poland
 * @rep:category BUSINESS_ENTITY PER_PREVIOUS_EMPLOYMENT
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_pl_previous_employer
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
  ,p_pem_information_category   IN      varchar2  default hr_api.g_varchar2
  ,Direction_Number	        	IN      varchar2  default hr_api.g_varchar2
  ,Telephone					IN      varchar2  default hr_api.g_varchar2
  ,Mobile					IN      varchar2  default hr_api.g_varchar2
  ,Fax						IN      varchar2  default hr_api.g_varchar2
  ,E_mail					IN      varchar2  default hr_api.g_varchar2
  ,Contact_Information          IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information7           IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information8           IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information9           IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information10          IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information11          IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information12          IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information13          IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information14          IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information15          IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information16          IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information17          IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information18          IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information19          IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information20          IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information21          IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information22          IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information23          IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information24          IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information25          IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information26          IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information27          IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information28          IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information29          IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information30          IN      varchar2  default hr_api.g_varchar2
  ,p_object_version_number      IN OUT NOCOPY  number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_pl_previous_job >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates previous job details.
 *
 * This API is effectively an alternative to the API create_previous_job. If
 * p_validate is set to false, a previous job is created.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The previous employer identified by p_previous_employer_id must already
 * exist.
 *
 * <p><b>Post Success</b><br>
 * The previous job will be successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The previous job will not be created and an error will be raised.
 *
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_previous_employer_id Identifies the previous employer for whom you
 * create the previous job record.
 * @param p_start_date The date from which the employee worked with the
 * previous job. The start date should be between the start and end dates of
 * the previous employer.
 * @param p_end_date The date on which the employee left the previous job.
 * @param p_period_years Number of years of previous employment based on the
 * employment start and end dates.
 * @param p_period_months Number of months of previous employment based on the
 * employment start and end dates.
 * @param p_period_days Remaining number of days of employment based on number
 * of days in period.
 * @param p_job_name Name of the previous job.
 * @param p_employment_category Obsolete parameter, do not use.
 * @param p_description Description of the previous job.
 * @param p_all_assignments Indicates whether previous employer is applicable
 * to all assignments of the current employer.
 * @param p_pjo_attribute_category This context value determines which
 * flexfield structure to use with the descriptive flexfield columns.
 * @param p_pjo_attribute1 Descriptive flexfield column.
 * @param p_pjo_attribute2 Descriptive flexfield column.
 * @param p_pjo_attribute3 Descriptive flexfield column.
 * @param p_pjo_attribute4 Descriptive flexfield column.
 * @param p_pjo_attribute5 Descriptive flexfield column.
 * @param p_pjo_attribute6 Descriptive flexfield column.
 * @param p_pjo_attribute7 Descriptive flexfield column.
 * @param p_pjo_attribute8 Descriptive flexfield column.
 * @param p_pjo_attribute9 Descriptive flexfield column.
 * @param p_pjo_attribute10 Descriptive flexfield column.
 * @param p_pjo_attribute11 Descriptive flexfield column.
 * @param p_pjo_attribute12 Descriptive flexfield column.
 * @param p_pjo_attribute13 Descriptive flexfield column.
 * @param p_pjo_attribute14 Descriptive flexfield column.
 * @param p_pjo_attribute15 Descriptive flexfield column.
 * @param p_pjo_attribute16 Descriptive flexfield column.
 * @param p_pjo_attribute17 Descriptive flexfield column.
 * @param p_pjo_attribute18 Descriptive flexfield column.
 * @param p_pjo_attribute19 Descriptive flexfield column.
 * @param p_pjo_attribute20 Descriptive flexfield column.
 * @param p_pjo_attribute21 Descriptive flexfield column.
 * @param p_pjo_attribute22 Descriptive flexfield column.
 * @param p_pjo_attribute23 Descriptive flexfield column.
 * @param p_pjo_attribute24 Descriptive flexfield column.
 * @param p_pjo_attribute25 Descriptive flexfield column.
 * @param p_pjo_attribute26 Descriptive flexfield column.
 * @param p_pjo_attribute27 Descriptive flexfield column.
 * @param p_pjo_attribute28 Descriptive flexfield column.
 * @param p_pjo_attribute29 Descriptive flexfield column.
 * @param p_pjo_attribute30 Descriptive flexfield column.
 * @param p_pjo_information_category This context value determines which
 * flexfield structure to use with the developer descriptive flexfield columns.
 * @param type_of_service Type of service. Valid values are defined by
 * PL_TYPE_OF_SERVICE lookup type.
 * @param p_pjo_information2 Developer Descriptive flexfield column.
 * @param p_pjo_information3 Developer Descriptive flexfield column.
 * @param p_pjo_information4 Developer Descriptive flexfield column.
 * @param p_pjo_information5 Developer Descriptive flexfield column.
 * @param p_pjo_information6 Developer Descriptive flexfield column.
 * @param p_pjo_information7 Developer Descriptive flexfield column.
 * @param p_pjo_information8 Developer Descriptive flexfield column.
 * @param p_pjo_information9 Developer Descriptive flexfield column.
 * @param p_pjo_information10 Developer Descriptive flexfield column.
 * @param p_pjo_information11 Developer Descriptive flexfield column.
 * @param p_pjo_information12 Developer Descriptive flexfield column.
 * @param p_pjo_information13 Developer Descriptive flexfield column.
 * @param p_pjo_information14 Developer Descriptive flexfield column.
 * @param p_pjo_information15 Developer Descriptive flexfield column.
 * @param p_pjo_information16 Developer Descriptive flexfield column.
 * @param p_pjo_information17 Developer Descriptive flexfield column.
 * @param p_pjo_information18 Developer Descriptive flexfield column.
 * @param p_pjo_information19 Developer Descriptive flexfield column.
 * @param p_pjo_information20 Developer Descriptive flexfield column.
 * @param p_pjo_information21 Developer Descriptive flexfield column.
 * @param p_pjo_information22 Developer Descriptive flexfield column.
 * @param p_pjo_information23 Developer Descriptive flexfield column.
 * @param p_pjo_information24 Developer Descriptive flexfield column.
 * @param p_pjo_information25 Developer Descriptive flexfield column.
 * @param p_pjo_information26 Developer Descriptive flexfield column
 * @param p_pjo_information27 Developer Descriptive flexfield column
 * @param p_pjo_information28 Developer Descriptive flexfield column
 * @param p_pjo_information29 Developer Descriptive flexfield column
 * @param p_pjo_information30 Developer Descriptive flexfield column
 * @param p_previous_job_id If p_validate is false, then this uniquely
 * identifies the created previous job. If p_validate is true, then set to
 * null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created previous job. If p_validate is true, then the
 * value will be null.
 * @rep:displayname Create Previous Job for Poland
 * @rep:category BUSINESS_ENTITY PER_PREVIOUS_EMPLOYMENT
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_pl_previous_job
(  p_effective_date                 in     date
  ,p_validate                       in     boolean  default false
  ,p_previous_employer_id           in     number
  ,p_start_date                     in     date     default null
  ,p_end_date                       in     date     default null
  ,p_period_years                   in     number   default null
  ,p_period_months                  in     number   default null
  ,p_period_days                    in     number   default null
  ,p_job_name                       in     varchar2 default null
  ,p_employment_category            in     varchar2 default null
  ,p_description                    in     varchar2 default null
  ,p_all_assignments                in     varchar2 default 'N'
  ,p_pjo_attribute_category         in     varchar2 default null
  ,p_pjo_attribute1                 in     varchar2 default null
  ,p_pjo_attribute2                 in     varchar2 default null
  ,p_pjo_attribute3                 in     varchar2 default null
  ,p_pjo_attribute4                 in     varchar2 default null
  ,p_pjo_attribute5                 in     varchar2 default null
  ,p_pjo_attribute6                 in     varchar2 default null
  ,p_pjo_attribute7                 in     varchar2 default null
  ,p_pjo_attribute8                 in     varchar2 default null
  ,p_pjo_attribute9                 in     varchar2 default null
  ,p_pjo_attribute10                in     varchar2 default null
  ,p_pjo_attribute11                in     varchar2 default null
  ,p_pjo_attribute12                in     varchar2 default null
  ,p_pjo_attribute13                in     varchar2 default null
  ,p_pjo_attribute14                in     varchar2 default null
  ,p_pjo_attribute15                in     varchar2 default null
  ,p_pjo_attribute16                in     varchar2 default null
  ,p_pjo_attribute17                in     varchar2 default null
  ,p_pjo_attribute18                in     varchar2 default null
  ,p_pjo_attribute19                in     varchar2 default null
  ,p_pjo_attribute20                in     varchar2 default null
  ,p_pjo_attribute21                in     varchar2 default null
  ,p_pjo_attribute22                in     varchar2 default null
  ,p_pjo_attribute23                in     varchar2 default null
  ,p_pjo_attribute24                in     varchar2 default null
  ,p_pjo_attribute25                in     varchar2 default null
  ,p_pjo_attribute26                in     varchar2 default null
  ,p_pjo_attribute27                in     varchar2 default null
  ,p_pjo_attribute28                in     varchar2 default null
  ,p_pjo_attribute29                in     varchar2 default null
  ,p_pjo_attribute30                in     varchar2 default null
  ,p_pjo_information_category       in     varchar2 default null
  ,Type_Of_Service                  in     varchar2
  ,p_pjo_information2               in     varchar2 default null
  ,p_pjo_information3               in     varchar2 default null
  ,p_pjo_information4               in     varchar2 default null
  ,p_pjo_information5               in     varchar2 default null
  ,p_pjo_information6               in     varchar2 default null
  ,p_pjo_information7               in     varchar2 default null
  ,p_pjo_information8               in     varchar2 default null
  ,p_pjo_information9               in     varchar2 default null
  ,p_pjo_information10              in     varchar2 default null
  ,p_pjo_information11              in     varchar2 default null
  ,p_pjo_information12              in     varchar2 default null
  ,p_pjo_information13              in     varchar2 default null
  ,p_pjo_information14              in     varchar2 default null
  ,p_pjo_information15              in     varchar2 default null
  ,p_pjo_information16              in     varchar2 default null
  ,p_pjo_information17              in     varchar2 default null
  ,p_pjo_information18              in     varchar2 default null
  ,p_pjo_information19              in     varchar2 default null
  ,p_pjo_information20              in     varchar2 default null
  ,p_pjo_information21              in     varchar2 default null
  ,p_pjo_information22              in     varchar2 default null
  ,p_pjo_information23              in     varchar2 default null
  ,p_pjo_information24              in     varchar2 default null
  ,p_pjo_information25              in     varchar2 default null
  ,p_pjo_information26              in     varchar2 default null
  ,p_pjo_information27              in     varchar2 default null
  ,p_pjo_information28              in     varchar2 default null
  ,p_pjo_information29              in     varchar2 default null
  ,p_pjo_information30              in     varchar2 default null
  ,p_previous_job_id                out nocopy    number
  ,p_object_version_number          out nocopy    number
);
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_pl_previous_job >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API modifies a previous job.
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
 * The previous job will be updated.
 *
 * <p><b>Post Failure</b><br>
 * The previous job will not be updated and an error will be raised.
 *
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_previous_job_id Identifies the previous job record to be modified.
 * @param p_start_date The date from which the employee worked with the
 * previous job. The start date should be between the start and end dates of
 * the previous employer record.
 * @param p_end_date The date on which the employee left the previous job.
 * @param p_period_years Number of years of previous employment based on the
 * employment start and end dates.
 * @param p_period_months Number of months of previous employment based on the
 * employment start and end dates.
 * @param p_period_days Remaining number of days of employment based on number
 * of days in period.
 * @param p_job_name Name of the previous job.
 * @param p_employment_category Obsolete parameter, do not use.
 * @param p_description Description of the previous job.
 * @param p_all_assignments Indicates whether previous employer is applicable
 * to all assignments of the current employer.
 * @param p_pjo_attribute_category This context value determines which
 * flexfield structure to use with the descriptive flexfield columns.
 * @param p_pjo_attribute1 Descriptive flexfield column.
 * @param p_pjo_attribute2 Descriptive flexfield column.
 * @param p_pjo_attribute3 Descriptive flexfield column.
 * @param p_pjo_attribute4 Descriptive flexfield column.
 * @param p_pjo_attribute5 Descriptive flexfield column.
 * @param p_pjo_attribute6 Descriptive flexfield column.
 * @param p_pjo_attribute7 Descriptive flexfield column.
 * @param p_pjo_attribute8 Descriptive flexfield column.
 * @param p_pjo_attribute9 Descriptive flexfield column.
 * @param p_pjo_attribute10 Descriptive flexfield column.
 * @param p_pjo_attribute11 Descriptive flexfield column.
 * @param p_pjo_attribute12 Descriptive flexfield column.
 * @param p_pjo_attribute13 Descriptive flexfield column.
 * @param p_pjo_attribute14 Descriptive flexfield column.
 * @param p_pjo_attribute15 Descriptive flexfield column.
 * @param p_pjo_attribute16 Descriptive flexfield column.
 * @param p_pjo_attribute17 Descriptive flexfield column.
 * @param p_pjo_attribute18 Descriptive flexfield column.
 * @param p_pjo_attribute19 Descriptive flexfield column.
 * @param p_pjo_attribute20 Descriptive flexfield column.
 * @param p_pjo_attribute21 Descriptive flexfield column.
 * @param p_pjo_attribute22 Descriptive flexfield column.
 * @param p_pjo_attribute23 Descriptive flexfield column.
 * @param p_pjo_attribute24 Descriptive flexfield column.
 * @param p_pjo_attribute25 Descriptive flexfield column.
 * @param p_pjo_attribute26 Descriptive flexfield column.
 * @param p_pjo_attribute27 Descriptive flexfield column.
 * @param p_pjo_attribute28 Descriptive flexfield column.
 * @param p_pjo_attribute29 Descriptive flexfield column.
 * @param p_pjo_attribute30 Descriptive flexfield column.
 * @param p_pjo_information_category This context value determines which
 * flexfield structure to use with the developer descriptive flexfield columns.
 * @param type_of_service Type of service. Valid values are defined by
 * PL_TYPE_OF_SERVICE lookup type.
 * @param p_pjo_information2 Developer Descriptive flexfield column.
 * @param p_pjo_information3 Developer Descriptive flexfield column.
 * @param p_pjo_information4 Developer Descriptive flexfield column.
 * @param p_pjo_information5 Developer Descriptive flexfield column.
 * @param p_pjo_information6 Developer Descriptive flexfield column.
 * @param p_pjo_information7 Developer Descriptive flexfield column.
 * @param p_pjo_information8 Developer Descriptive flexfield column.
 * @param p_pjo_information9 Developer Descriptive flexfield column.
 * @param p_pjo_information10 Developer Descriptive flexfield column.
 * @param p_pjo_information11 Developer Descriptive flexfield column.
 * @param p_pjo_information12 Developer Descriptive flexfield column.
 * @param p_pjo_information13 Developer Descriptive flexfield column.
 * @param p_pjo_information14 Developer Descriptive flexfield column.
 * @param p_pjo_information15 Developer Descriptive flexfield column.
 * @param p_pjo_information16 Developer Descriptive flexfield column.
 * @param p_pjo_information17 Developer Descriptive flexfield column.
 * @param p_pjo_information18 Developer Descriptive flexfield column.
 * @param p_pjo_information19 Developer Descriptive flexfield column.
 * @param p_pjo_information20 Developer Descriptive flexfield column.
 * @param p_pjo_information21 Developer Descriptive flexfield column.
 * @param p_pjo_information22 Developer Descriptive flexfield column.
 * @param p_pjo_information23 Developer Descriptive flexfield column.
 * @param p_pjo_information24 Developer Descriptive flexfield column.
 * @param p_pjo_information25 Developer Descriptive flexfield column.
 * @param p_pjo_information26 Developer Descriptive flexfield column.
 * @param p_pjo_information27 Developer Descriptive flexfield column.
 * @param p_pjo_information28 Developer Descriptive flexfield column.
 * @param p_pjo_information29 Developer Descriptive flexfield column.
 * @param p_pjo_information30 Developer Descriptive flexfield column.
 * @param p_object_version_number Pass in the current version number of the
 * previous job to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated previous job. If
 * p_validate is true will be set to the same value which was passed in.
 * @rep:displayname Update Previous Job for Poland
 * @rep:category BUSINESS_ENTITY PER_PREVIOUS_EMPLOYMENT
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_pl_previous_job
(  p_effective_date               in     date
  ,p_validate                     in     boolean   default false
  ,p_previous_job_id              in     number
  ,p_start_date                   in     date      default hr_api.g_date
  ,p_end_date                     in     date      default hr_api.g_date
  ,p_period_years                 in     number    default hr_api.g_number
  ,p_period_months                in     number    default hr_api.g_number
  ,p_period_days                  in     number    default hr_api.g_number
  ,p_job_name                     in     varchar2  default hr_api.g_varchar2
  ,p_employment_category          in     varchar2  default hr_api.g_varchar2
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_all_assignments              in     varchar2  default 'N'
  ,p_pjo_attribute_category       in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute1               in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute2               in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute3               in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute4               in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute5               in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute6               in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute7               in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute8               in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute9               in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute10              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute11              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute12              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute13              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute14              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute15              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute16              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute17              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute18              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute19              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute20              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute21              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute22              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute23              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute24              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute25              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute26              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute27              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute28              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute29              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute30              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information_category     in     varchar2  default hr_api.g_varchar2
  ,Type_Of_Service                in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information2             in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information3             in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information4             in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information5             in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information6             in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information7             in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information8             in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information9             in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information10            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information11            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information12            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information13            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information14            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information15            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information16            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information17            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information18            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information19            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information20            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information21            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information22            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information23            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information24            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information25            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information26            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information27            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information28            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information29            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information30            in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
);
End hr_pl_previous_employment_api;

 

/
