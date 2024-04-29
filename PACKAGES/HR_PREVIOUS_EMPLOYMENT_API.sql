--------------------------------------------------------
--  DDL for Package HR_PREVIOUS_EMPLOYMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PREVIOUS_EMPLOYMENT_API" AUTHID CURRENT_USER as
/* $Header: pepemapi.pkh 120.1.12010000.1 2008/07/28 05:11:13 appldev ship $ */
/*#
 * This package contains APIs that maintain previous employment information for
 * an employee.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Previous Employment
*/
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_previous_employer >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates new previous employer details.
 *
 * Details can include the previous employer's name, address, and type of
 * industry. You can specify how long a person worked for the previous
 * employer, and the associated start and end dates. With public sector
 * industries in particular, rules associated with previous employment details
 * can affect multiple assignments, such as determining the speed in which
 * employees move up a grade scale.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A person must exist before a period of previous employment can be entered.
 * Previous employment can be recorded for all person types except people of
 * person type 'OTHER'.
 *
 * <p><b>Post Success</b><br>
 * The previous employer record will be created.
 *
 * <p><b>Post Failure</b><br>
 * The previous employer record will not be created and an error will be
 * raised.
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
 * @param p_pem_information_category Developer Descriptive flexfield defining
 * column
 * @param p_pem_information1 Developer Descriptive flexfield defining column
 * @param p_pem_information2 Developer Descriptive flexfield defining column
 * @param p_pem_information3 Developer Descriptive flexfield defining column
 * @param p_pem_information4 Developer Descriptive flexfield defining column
 * @param p_pem_information5 Developer Descriptive flexfield defining column
 * @param p_pem_information6 Developer Descriptive flexfield defining column
 * @param p_pem_information7 Developer Descriptive flexfield defining column
 * @param p_pem_information8 Developer Descriptive flexfield defining column
 * @param p_pem_information9 Developer Descriptive flexfield defining column
 * @param p_pem_information10 Developer Descriptive flexfield defining column
 * @param p_pem_information11 Developer Descriptive flexfield defining column
 * @param p_pem_information12 Developer Descriptive flexfield defining column
 * @param p_pem_information13 Developer Descriptive flexfield defining column
 * @param p_pem_information14 Developer Descriptive flexfield defining column
 * @param p_pem_information15 Developer Descriptive flexfield defining column
 * @param p_pem_information16 Developer Descriptive flexfield defining column
 * @param p_pem_information17 Developer Descriptive flexfield defining column
 * @param p_pem_information18 Developer Descriptive flexfield defining column
 * @param p_pem_information19 Developer Descriptive flexfield defining column
 * @param p_pem_information20 Developer Descriptive flexfield defining column
 * @param p_pem_information21 Developer Descriptive flexfield defining column
 * @param p_pem_information22 Developer Descriptive flexfield defining column
 * @param p_pem_information23 Developer Descriptive flexfield defining column
 * @param p_pem_information24 Developer Descriptive flexfield defining column
 * @param p_pem_information25 Developer Descriptive flexfield defining column
 * @param p_pem_information26 Developer Descriptive flexfield defining column
 * @param p_pem_information27 Developer Descriptive flexfield defining column
 * @param p_pem_information28 Developer Descriptive flexfield defining column
 * @param p_pem_information29 Developer Descriptive flexfield defining column
 * @param p_pem_information30 Developer Descriptive flexfield defining column
 * @param p_previous_employer_id If p_validate is false, then this uniquely
 * identifies the previous employer created. If p_validate is true, then set to
 * null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created previous employer. If p_validate is true, then
 * the value will be null.
 * @rep:displayname Create Previous Employer
 * @rep:category BUSINESS_ENTITY PER_PREVIOUS_EMPLOYMENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_previous_employer
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
  ,p_pem_information_category     IN      varchar2  default null
  ,p_pem_information1             IN      varchar2  default null
  ,p_pem_information2             IN      varchar2  default null
  ,p_pem_information3             IN      varchar2  default null
  ,p_pem_information4             IN      varchar2  default null
  ,p_pem_information5             IN      varchar2  default null
  ,p_pem_information6             IN      varchar2  default null
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
-- |-------------------------< update_previous_employer >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates previous employer details.
 *
 * Details can include the previous employer's name, address, and type of
 * industry. You can specify how long a person worked for the previous
 * employer, and the associated start and end dates. With public sector
 * industries in particular, rules associated with previous employment details
 * can affect multiple assignments, such as determining the speed in which
 * employees move up a grade scale.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The previous employer record must exist for the person
 *
 * <p><b>Post Success</b><br>
 * The previous employer record will be updated.
 *
 * <p><b>Post Failure</b><br>
 * The previous employer record will not be updated and an error will be
 * raised.
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
 * @param p_pem_information_category Developer Descriptive flexfield defining
 * column
 * @param p_pem_information1 Developer Descriptive flexfield defining column
 * @param p_pem_information2 Developer Descriptive flexfield defining column
 * @param p_pem_information3 Developer Descriptive flexfield defining column
 * @param p_pem_information4 Developer Descriptive flexfield defining column
 * @param p_pem_information5 Developer Descriptive flexfield defining column
 * @param p_pem_information6 Developer Descriptive flexfield defining column
 * @param p_pem_information7 Developer Descriptive flexfield defining column
 * @param p_pem_information8 Developer Descriptive flexfield defining column
 * @param p_pem_information9 Developer Descriptive flexfield defining column
 * @param p_pem_information10 Developer Descriptive flexfield defining column
 * @param p_pem_information11 Developer Descriptive flexfield defining column
 * @param p_pem_information12 Developer Descriptive flexfield defining column
 * @param p_pem_information13 Developer Descriptive flexfield defining column
 * @param p_pem_information14 Developer Descriptive flexfield defining column
 * @param p_pem_information15 Developer Descriptive flexfield defining column
 * @param p_pem_information16 Developer Descriptive flexfield defining column
 * @param p_pem_information17 Developer Descriptive flexfield defining column
 * @param p_pem_information18 Developer Descriptive flexfield defining column
 * @param p_pem_information19 Developer Descriptive flexfield defining column
 * @param p_pem_information20 Developer Descriptive flexfield defining column
 * @param p_pem_information21 Developer Descriptive flexfield defining column
 * @param p_pem_information22 Developer Descriptive flexfield defining column
 * @param p_pem_information23 Developer Descriptive flexfield defining column
 * @param p_pem_information24 Developer Descriptive flexfield defining column
 * @param p_pem_information25 Developer Descriptive flexfield defining column
 * @param p_pem_information26 Developer Descriptive flexfield defining column
 * @param p_pem_information27 Developer Descriptive flexfield defining column
 * @param p_pem_information28 Developer Descriptive flexfield defining column
 * @param p_pem_information29 Developer Descriptive flexfield defining column
 * @param p_pem_information30 Developer Descriptive flexfield defining column
 * @param p_object_version_number Pass in the current version number of the
 * previous employer to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated previous
 * employer. If p_validate is true will be set to the same value which was
 * passed in.
 * @rep:displayname Update Previous Employer
 * @rep:category BUSINESS_ENTITY PER_PREVIOUS_EMPLOYMENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_previous_employer
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
  ,p_pem_information1           IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information2           IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information3           IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information4           IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information5           IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information6           IN      varchar2  default hr_api.g_varchar2
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
-- |-------------------------< delete_previous_employer >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a previous employer.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The previous employer must exist and have no previous job, previous job
 * extra information or previous job usages records.
 *
 * <p><b>Post Success</b><br>
 * The previous employer is deleted.
 *
 * <p><b>Post Failure</b><br>
 * The previous employer is not deleted and an error will be raised
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_previous_employer_id Uniquely identifies the previous employer
 * record to be deleted.
 * @param p_object_version_number Current version number of the previous
 * employer to be deleted.
 * @rep:displayname Delete Previous Employer
 * @rep:category BUSINESS_ENTITY PER_PREVIOUS_EMPLOYMENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_previous_employer
  (p_validate                      in     boolean  default false
  ,p_previous_employer_id          in     number
  ,p_object_version_number         in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_previous_job >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a previous job held with a previous employer.
 *
 * Each job an employee performed with a previous employer can affect current
 * employment. For example, a person with four years of teaching experience may
 * have spent one of those years as a Head Teacher. Creating a previous job
 * enables HRMS to account for the Head Teacher experience.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A previous employer must exist for this person.
 *
 * <p><b>Post Success</b><br>
 * The previous job record will be created.
 *
 * <p><b>Post Failure</b><br>
 * The previous job record will not be created and an error will be raised.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_previous_employer_id Uniquely identifies the previous employer for
 * which the previous job was performed
 * @param p_start_date The start date of the previous job.
 * @param p_end_date The end date of the previous job.
 * @param p_period_years The number of years the employee worked on the
 * previous job. If left null, the process calculates this based on the start
 * date and end date. For example, if the start date is '01-JAN-2000' and the
 * end date is '05-MAR-2004', the process sets four years.
 * @param p_period_months The number of months the employee worked on the
 * previous job over and above the years worked. If left null, the process
 * calculates this from the start and end date. For example, if the start date
 * is '01-JAN-2000' and the end date is '05-MAR-2004', the process sets two
 * months.
 * @param p_period_days The number of days the employee worked on the previous
 * job over and above the years and months worked. If left null, the process
 * calculates this from the start and end date. For example, if the start date
 * is '01-JAN-2000' and the end date is '05-MAR-2004', the process sets five
 * days.
 * @param p_job_name The name of the previous job. This is free text, and
 * should not be confused with jobs held with the current employer stored
 * within Oracle Human Resources.
 * @param p_employment_category The employee category of the previous job.
 * Valid values are defined by the lookup type 'EMPLOYEE_CATG'. Examples are
 * 'Civil Servant', 'Blue Collar' and 'Technical White Collar'.
 * @param p_description The description of the previous job.
 * @param p_all_assignments Set to 'Y' if the previous employment applies to
 * all of the employee's assignments. Otherwise set to 'N'. In order to create
 * previous job usage records (using the create_previous_job_usage API), set
 * this flag to 'N'.
 * @param p_pjo_attribute_category Descriptive flexfield Structure defining
 * column.
 * @param p_pjo_attribute1 Descriptive flexfield column
 * @param p_pjo_attribute2 Descriptive flexfield column
 * @param p_pjo_attribute3 Descriptive flexfield column
 * @param p_pjo_attribute4 Descriptive flexfield column
 * @param p_pjo_attribute5 Descriptive flexfield column
 * @param p_pjo_attribute6 Descriptive flexfield column
 * @param p_pjo_attribute7 Descriptive flexfield column
 * @param p_pjo_attribute8 Descriptive flexfield column
 * @param p_pjo_attribute9 Descriptive flexfield column
 * @param p_pjo_attribute10 Descriptive flexfield column
 * @param p_pjo_attribute11 Descriptive flexfield column
 * @param p_pjo_attribute12 Descriptive flexfield column
 * @param p_pjo_attribute13 Descriptive flexfield column
 * @param p_pjo_attribute14 Descriptive flexfield column
 * @param p_pjo_attribute15 Descriptive flexfield column
 * @param p_pjo_attribute16 Descriptive flexfield column
 * @param p_pjo_attribute17 Descriptive flexfield column
 * @param p_pjo_attribute18 Descriptive flexfield column
 * @param p_pjo_attribute19 Descriptive flexfield column
 * @param p_pjo_attribute20 Descriptive flexfield column
 * @param p_pjo_attribute21 Descriptive flexfield column
 * @param p_pjo_attribute22 Descriptive flexfield column
 * @param p_pjo_attribute23 Descriptive flexfield column
 * @param p_pjo_attribute24 Descriptive flexfield column
 * @param p_pjo_attribute25 Descriptive flexfield column
 * @param p_pjo_attribute26 Descriptive flexfield column
 * @param p_pjo_attribute27 Descriptive flexfield column
 * @param p_pjo_attribute28 Descriptive flexfield column
 * @param p_pjo_attribute29 Descriptive flexfield column
 * @param p_pjo_attribute30 Descriptive flexfield column
 * @param p_pjo_information_category Developer Descriptive flexfield structure
 * defining column
 * @param p_pjo_information1 Developer Descriptive flexfield column
 * @param p_pjo_information2 Developer Descriptive flexfield column
 * @param p_pjo_information3 Developer Descriptive flexfield column
 * @param p_pjo_information4 Developer Descriptive flexfield column
 * @param p_pjo_information5 Developer Descriptive flexfield column
 * @param p_pjo_information6 Developer Descriptive flexfield column
 * @param p_pjo_information7 Developer Descriptive flexfield column
 * @param p_pjo_information8 Developer Descriptive flexfield column
 * @param p_pjo_information9 Developer Descriptive flexfield column
 * @param p_pjo_information10 Developer Descriptive flexfield column
 * @param p_pjo_information11 Developer Descriptive flexfield column
 * @param p_pjo_information12 Developer Descriptive flexfield column
 * @param p_pjo_information13 Developer Descriptive flexfield column
 * @param p_pjo_information14 Developer Descriptive flexfield column
 * @param p_pjo_information15 Developer Descriptive flexfield column
 * @param p_pjo_information16 Developer Descriptive flexfield column
 * @param p_pjo_information17 Developer Descriptive flexfield column
 * @param p_pjo_information18 Developer Descriptive flexfield column
 * @param p_pjo_information19 Developer Descriptive flexfield column
 * @param p_pjo_information20 Developer Descriptive flexfield column
 * @param p_pjo_information21 Developer Descriptive flexfield column
 * @param p_pjo_information22 Developer Descriptive flexfield column
 * @param p_pjo_information23 Developer Descriptive flexfield column
 * @param p_pjo_information24 Developer Descriptive flexfield column
 * @param p_pjo_information25 Developer Descriptive flexfield column
 * @param p_pjo_information26 Developer Descriptive flexfield column
 * @param p_pjo_information27 Developer Descriptive flexfield column
 * @param p_pjo_information28 Developer Descriptive flexfield column
 * @param p_pjo_information29 Developer Descriptive flexfield column
 * @param p_pjo_information30 Developer Descriptive flexfield column
 * @param p_previous_job_id If p_validate is false, then this uniquely
 * identifies the previous job created. If p_validate is true, then set to
 * null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the previous job created. If p_validate is true, then set
 * to null.
 * @rep:displayname Create Previous Job
 * @rep:category BUSINESS_ENTITY PER_PREVIOUS_EMPLOYMENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_previous_job
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
  ,p_pjo_information1               in     varchar2 default null
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
-- |---------------------------< update_previous_job >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a previous job held with a previous employer.
 *
 * Each job an employee performed with a previous employer can affect current
 * employment. For example, a person with four years of teaching experience may
 * have spent one of those years as a Head Teacher. Creating a previous job
 * enables HRMS to account for the Head Teacher experience.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A previous job must exist for this previous employer.
 *
 * <p><b>Post Success</b><br>
 * The previous job will be updated.
 *
 * <p><b>Post Failure</b><br>
 * The previous job will not be updated.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_previous_job_id Uniquely identifes the previous job to be updated.
 * @param p_start_date The start date of the previous job.
 * @param p_end_date The end date of the previous job.
 * @param p_period_years The number of years the employee worked on the
 * previous job. If left null, the process calculates this based on the start
 * date and end date. For example, if the start date is '01-JAN-2000' and the
 * end date is '05-MAR-2004', the process sets four years.
 * @param p_period_months The number of months the employee worked on the
 * previous job over and above the years worked. If left null, the process
 * calculates this from the start and end date. For example, if the start date
 * is '01-JAN-2000' and the end date is '05-MAR-2004', the process sets two
 * months.
 * @param p_period_days The number of days the employee worked on the previous
 * job over and above the years and months worked. If left null, the process
 * calculates this from the start and end date. For example, if the start date
 * is '01-JAN-2000' and the end date is '05-MAR-2004', the process sets five
 * days.
 * @param p_job_name The name of the previous job. This is free text, and
 * should not be confused with jobs held with the current employer stored
 * within Oracle Human Resources.
 * @param p_employment_category The employee category of the previous job.
 * Valid values are defined by the lookup type 'EMPLOYEE_CATG'. Examples are
 * 'Civil Servant', 'Blue Collar' and 'Technical White Collar'.
 * @param p_description The description of the previous job.
 * @param p_all_assignments Set to 'Y' if the previous employment applies to
 * all of the employee's assignments. Otherwise set to 'N'. In order to create
 * previous job usage records (using the create_previous_job_usage API), set
 * this flag to 'N'.
 * @param p_pjo_attribute_category Descriptive flexfield Structure defining
 * column.
 * @param p_pjo_attribute1 Descriptive flexfield column
 * @param p_pjo_attribute2 Descriptive flexfield column
 * @param p_pjo_attribute3 Descriptive flexfield column
 * @param p_pjo_attribute4 Descriptive flexfield column
 * @param p_pjo_attribute5 Descriptive flexfield column
 * @param p_pjo_attribute6 Descriptive flexfield column
 * @param p_pjo_attribute7 Descriptive flexfield column
 * @param p_pjo_attribute8 Descriptive flexfield column
 * @param p_pjo_attribute9 Descriptive flexfield column
 * @param p_pjo_attribute10 Descriptive flexfield column
 * @param p_pjo_attribute11 Descriptive flexfield column
 * @param p_pjo_attribute12 Descriptive flexfield column
 * @param p_pjo_attribute13 Descriptive flexfield column
 * @param p_pjo_attribute14 Descriptive flexfield column
 * @param p_pjo_attribute15 Descriptive flexfield column
 * @param p_pjo_attribute16 Descriptive flexfield column
 * @param p_pjo_attribute17 Descriptive flexfield column
 * @param p_pjo_attribute18 Descriptive flexfield column
 * @param p_pjo_attribute19 Descriptive flexfield column
 * @param p_pjo_attribute20 Descriptive flexfield column
 * @param p_pjo_attribute21 Descriptive flexfield column
 * @param p_pjo_attribute22 Descriptive flexfield column
 * @param p_pjo_attribute23 Descriptive flexfield column
 * @param p_pjo_attribute24 Descriptive flexfield column
 * @param p_pjo_attribute25 Descriptive flexfield column
 * @param p_pjo_attribute26 Descriptive flexfield column
 * @param p_pjo_attribute27 Descriptive flexfield column
 * @param p_pjo_attribute28 Descriptive flexfield column
 * @param p_pjo_attribute29 Descriptive flexfield column
 * @param p_pjo_attribute30 Descriptive flexfield column
 * @param p_pjo_information_category Developer Descriptive flexfield structure
 * defining column
 * @param p_pjo_information1 Developer Descriptive flexfield column
 * @param p_pjo_information2 Developer Descriptive flexfield column
 * @param p_pjo_information3 Developer Descriptive flexfield column
 * @param p_pjo_information4 Developer Descriptive flexfield column
 * @param p_pjo_information5 Developer Descriptive flexfield column
 * @param p_pjo_information6 Developer Descriptive flexfield column
 * @param p_pjo_information7 Developer Descriptive flexfield column
 * @param p_pjo_information8 Developer Descriptive flexfield column
 * @param p_pjo_information9 Developer Descriptive flexfield column
 * @param p_pjo_information10 Developer Descriptive flexfield column
 * @param p_pjo_information11 Developer Descriptive flexfield column
 * @param p_pjo_information12 Developer Descriptive flexfield column
 * @param p_pjo_information13 Developer Descriptive flexfield column
 * @param p_pjo_information14 Developer Descriptive flexfield column
 * @param p_pjo_information15 Developer Descriptive flexfield column
 * @param p_pjo_information16 Developer Descriptive flexfield column
 * @param p_pjo_information17 Developer Descriptive flexfield column
 * @param p_pjo_information18 Developer Descriptive flexfield column
 * @param p_pjo_information19 Developer Descriptive flexfield column
 * @param p_pjo_information20 Developer Descriptive flexfield column
 * @param p_pjo_information21 Developer Descriptive flexfield column
 * @param p_pjo_information22 Developer Descriptive flexfield column
 * @param p_pjo_information23 Developer Descriptive flexfield column
 * @param p_pjo_information24 Developer Descriptive flexfield column
 * @param p_pjo_information25 Developer Descriptive flexfield column
 * @param p_pjo_information26 Developer Descriptive flexfield column
 * @param p_pjo_information27 Developer Descriptive flexfield column
 * @param p_pjo_information28 Developer Descriptive flexfield column
 * @param p_pjo_information29 Developer Descriptive flexfield column
 * @param p_pjo_information30 Developer Descriptive flexfield column
 * @param p_object_version_number Pass in the current version number of the
 * previous job to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated previous job. If
 * p_validate is true will be set to the same value which was passed in.
 * @rep:displayname Update Previous Job
 * @rep:category BUSINESS_ENTITY PER_PREVIOUS_EMPLOYMENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_previous_job
  (p_effective_date               in     date
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
  ,p_pjo_information1             in     varchar2  default hr_api.g_varchar2
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
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_previous_job >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a previous job held with a previous employer.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A previous job must exist for this previous employer.
 *
 * <p><b>Post Success</b><br>
 * The previous job will be deleted.
 *
 * <p><b>Post Failure</b><br>
 * The previous job will not be deleted.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_previous_job_id Uniquely identifes the previous job to be deleted.
 * @param p_object_version_number Current version number of the previous job to
 * be deleted.
 * @rep:displayname Delete Previous Job
 * @rep:category BUSINESS_ENTITY PER_PREVIOUS_EMPLOYMENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_previous_job
  (p_validate                      in     boolean  default false
  ,p_previous_job_id               in     number
  ,p_object_version_number         in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_prev_job_extra_info >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates extra information for a previous job.
 *
 * The type of information the process captures will vary, depending on the
 * legislation of the person's business group.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A previous job must exist for this previous employer.
 *
 * <p><b>Post Success</b><br>
 * Extra information is created for this previous job.
 *
 * <p><b>Post Failure</b><br>
 * Extra information is not created for this previous job and an error will be
 * raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_previous_job_id Uniquely identifies the previous job for which the
 * extra information will be created.
 * @param p_information_type The type of information being captured. Valid
 * values are stored in the column PER_PREV_INFO_TYPES.INFORMATION_TYPE.
 * @param p_pji_attribute_category Descriptive flexfield structure defining
 * column.
 * @param p_pji_attribute1 Descriptive flexfield column
 * @param p_pji_attribute2 Descriptive flexfield column
 * @param p_pji_attribute3 Descriptive flexfield column
 * @param p_pji_attribute4 Descriptive flexfield column
 * @param p_pji_attribute5 Descriptive flexfield column
 * @param p_pji_attribute6 Descriptive flexfield column
 * @param p_pji_attribute7 Descriptive flexfield column
 * @param p_pji_attribute8 Descriptive flexfield column
 * @param p_pji_attribute9 Descriptive flexfield column
 * @param p_pji_attribute10 Descriptive flexfield column
 * @param p_pji_attribute11 Descriptive flexfield column
 * @param p_pji_attribute12 Descriptive flexfield column
 * @param p_pji_attribute13 Descriptive flexfield column
 * @param p_pji_attribute14 Descriptive flexfield column
 * @param p_pji_attribute15 Descriptive flexfield column
 * @param p_pji_attribute16 Descriptive flexfield column
 * @param p_pji_attribute17 Descriptive flexfield column
 * @param p_pji_attribute18 Descriptive flexfield column
 * @param p_pji_attribute19 Descriptive flexfield column
 * @param p_pji_attribute20 Descriptive flexfield column
 * @param p_pji_attribute21 Descriptive flexfield column
 * @param p_pji_attribute22 Descriptive flexfield column
 * @param p_pji_attribute23 Descriptive flexfield column
 * @param p_pji_attribute24 Descriptive flexfield column
 * @param p_pji_attribute25 Descriptive flexfield column
 * @param p_pji_attribute26 Descriptive flexfield column
 * @param p_pji_attribute27 Descriptive flexfield column
 * @param p_pji_attribute28 Descriptive flexfield column
 * @param p_pji_attribute29 Descriptive flexfield column
 * @param p_pji_attribute30 Descriptive flexfield column
 * @param p_pji_information_category Developer descriptive flexfield structure
 * defining column
 * @param p_pji_information1 Developer descriptive flexfield column
 * @param p_pji_information2 Developer descriptive flexfield column
 * @param p_pji_information3 Developer descriptive flexfield column
 * @param p_pji_information4 Developer descriptive flexfield column
 * @param p_pji_information5 Developer descriptive flexfield column
 * @param p_pji_information6 Developer descriptive flexfield column
 * @param p_pji_information7 Developer descriptive flexfield column
 * @param p_pji_information8 Developer descriptive flexfield column
 * @param p_pji_information9 Developer descriptive flexfield column
 * @param p_pji_information10 Developer descriptive flexfield column
 * @param p_pji_information11 Developer descriptive flexfield column
 * @param p_pji_information12 Developer descriptive flexfield column
 * @param p_pji_information13 Developer descriptive flexfield column
 * @param p_pji_information14 Developer descriptive flexfield column
 * @param p_pji_information15 Developer descriptive flexfield column
 * @param p_pji_information16 Developer descriptive flexfield column
 * @param p_pji_information17 Developer descriptive flexfield column
 * @param p_pji_information18 Developer descriptive flexfield column
 * @param p_pji_information19 Developer descriptive flexfield column
 * @param p_pji_information20 Developer descriptive flexfield column
 * @param p_pji_information21 Developer descriptive flexfield column
 * @param p_pji_information22 Developer descriptive flexfield column
 * @param p_pji_information23 Developer descriptive flexfield column
 * @param p_pji_information24 Developer descriptive flexfield column
 * @param p_pji_information25 Developer descriptive flexfield column
 * @param p_pji_information26 Developer descriptive flexfield column
 * @param p_pji_information27 Developer descriptive flexfield column
 * @param p_pji_information28 Developer descriptive flexfield column
 * @param p_pji_information29 Developer descriptive flexfield column
 * @param p_pji_information30 Developer descriptive flexfield column
 * @param p_previous_job_extra_info_id If p_validate is false, then this
 * uniquely identifies the previous job extra information created. If
 * p_validate is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created previous job information. If p_validate is
 * true, then the value will be null.
 * @rep:displayname Create Previous Job Extra Information
 * @rep:category BUSINESS_ENTITY PER_PREVIOUS_EMPLOYMENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_prev_job_extra_info
  (p_validate                       in  boolean   default false
  ,p_previous_job_id                in  number
  ,p_information_type               in  varchar2  default null
  ,p_pji_attribute_category         in  varchar2  default null
  ,p_pji_attribute1                 in  varchar2  default null
  ,p_pji_attribute2                 in  varchar2  default null
  ,p_pji_attribute3                 in  varchar2  default null
  ,p_pji_attribute4                 in  varchar2  default null
  ,p_pji_attribute5                 in  varchar2  default null
  ,p_pji_attribute6                 in  varchar2  default null
  ,p_pji_attribute7                 in  varchar2  default null
  ,p_pji_attribute8                 in  varchar2  default null
  ,p_pji_attribute9                 in  varchar2  default null
  ,p_pji_attribute10                in  varchar2  default null
  ,p_pji_attribute11                in  varchar2  default null
  ,p_pji_attribute12                in  varchar2  default null
  ,p_pji_attribute13                in  varchar2  default null
  ,p_pji_attribute14                in  varchar2  default null
  ,p_pji_attribute15                in  varchar2  default null
  ,p_pji_attribute16                in  varchar2  default null
  ,p_pji_attribute17                in  varchar2  default null
  ,p_pji_attribute18                in  varchar2  default null
  ,p_pji_attribute19                in  varchar2  default null
  ,p_pji_attribute20                in  varchar2  default null
  ,p_pji_attribute21                in  varchar2  default null
  ,p_pji_attribute22                in  varchar2  default null
  ,p_pji_attribute23                in  varchar2  default null
  ,p_pji_attribute24                in  varchar2  default null
  ,p_pji_attribute25                in  varchar2  default null
  ,p_pji_attribute26                in  varchar2  default null
  ,p_pji_attribute27                in  varchar2  default null
  ,p_pji_attribute28                in  varchar2  default null
  ,p_pji_attribute29                in  varchar2  default null
  ,p_pji_attribute30                in  varchar2  default null
  ,p_pji_information_category       in  varchar2  default null
  ,p_pji_information1               in  varchar2  default null
  ,p_pji_information2               in  varchar2  default null
  ,p_pji_information3               in  varchar2  default null
  ,p_pji_information4               in  varchar2  default null
  ,p_pji_information5               in  varchar2  default null
  ,p_pji_information6               in  varchar2  default null
  ,p_pji_information7               in  varchar2  default null
  ,p_pji_information8               in  varchar2  default null
  ,p_pji_information9               in  varchar2  default null
  ,p_pji_information10              in  varchar2  default null
  ,p_pji_information11              in  varchar2  default null
  ,p_pji_information12              in  varchar2  default null
  ,p_pji_information13              in  varchar2  default null
  ,p_pji_information14              in  varchar2  default null
  ,p_pji_information15              in  varchar2  default null
  ,p_pji_information16              in  varchar2  default null
  ,p_pji_information17              in  varchar2  default null
  ,p_pji_information18              in  varchar2  default null
  ,p_pji_information19              in  varchar2  default null
  ,p_pji_information20              in  varchar2  default null
  ,p_pji_information21              in  varchar2  default null
  ,p_pji_information22              in  varchar2  default null
  ,p_pji_information23              in  varchar2  default null
  ,p_pji_information24              in  varchar2  default null
  ,p_pji_information25              in  varchar2  default null
  ,p_pji_information26              in  varchar2  default null
  ,p_pji_information27              in  varchar2  default null
  ,p_pji_information28              in  varchar2  default null
  ,p_pji_information29              in  varchar2  default null
  ,p_pji_information30              in  varchar2  default null
  ,p_previous_job_extra_info_id     out nocopy number
  ,p_object_version_number          out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_prev_job_extra_info >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates extra information for a previous job.
 *
 * The type of information the process captures will vary, depending on the
 * legislation of the person's business group.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Extra information for the previous job must exist.
 *
 * <p><b>Post Success</b><br>
 * Extra information is updated for this previous job.
 *
 * <p><b>Post Failure</b><br>
 * Extra information is not updated for this previous job and an error will be
 * raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_previous_job_id Uniquely identifies the previous job for which this
 * extra information will be updated. Cannot be updated.
 * @param p_information_type The type of information being captured. Valid
 * values are stored in the column PER_PREV_INFO_TYPES.INFORMATION_TYPE.
 * @param p_pji_attribute_category Descriptive flexfield structure defining
 * column.
 * @param p_pji_attribute1 Descriptive flexfield column
 * @param p_pji_attribute2 Descriptive flexfield column
 * @param p_pji_attribute3 Descriptive flexfield column
 * @param p_pji_attribute4 Descriptive flexfield column
 * @param p_pji_attribute5 Descriptive flexfield column
 * @param p_pji_attribute6 Descriptive flexfield column
 * @param p_pji_attribute7 Descriptive flexfield column
 * @param p_pji_attribute8 Descriptive flexfield column
 * @param p_pji_attribute9 Descriptive flexfield column
 * @param p_pji_attribute10 Descriptive flexfield column
 * @param p_pji_attribute11 Descriptive flexfield column
 * @param p_pji_attribute12 Descriptive flexfield column
 * @param p_pji_attribute13 Descriptive flexfield column
 * @param p_pji_attribute14 Descriptive flexfield column
 * @param p_pji_attribute15 Descriptive flexfield column
 * @param p_pji_attribute16 Descriptive flexfield column
 * @param p_pji_attribute17 Descriptive flexfield column
 * @param p_pji_attribute18 Descriptive flexfield column
 * @param p_pji_attribute19 Descriptive flexfield column
 * @param p_pji_attribute20 Descriptive flexfield column
 * @param p_pji_attribute21 Descriptive flexfield column
 * @param p_pji_attribute22 Descriptive flexfield column
 * @param p_pji_attribute23 Descriptive flexfield column
 * @param p_pji_attribute24 Descriptive flexfield column
 * @param p_pji_attribute25 Descriptive flexfield column
 * @param p_pji_attribute26 Descriptive flexfield column
 * @param p_pji_attribute27 Descriptive flexfield column
 * @param p_pji_attribute28 Descriptive flexfield column
 * @param p_pji_attribute29 Descriptive flexfield column
 * @param p_pji_attribute30 Descriptive flexfield column
 * @param p_pji_information_category Developer Descriptive structure defining
 * column.
 * @param p_pji_information1 Developer Descriptive flexfield column
 * @param p_pji_information2 Developer Descriptive flexfield column
 * @param p_pji_information3 Developer Descriptive flexfield column
 * @param p_pji_information4 Developer Descriptive flexfield column
 * @param p_pji_information5 Developer Descriptive flexfield column
 * @param p_pji_information6 Developer Descriptive flexfield column
 * @param p_pji_information7 Developer Descriptive flexfield column
 * @param p_pji_information8 Developer Descriptive flexfield column
 * @param p_pji_information9 Developer Descriptive flexfield column
 * @param p_pji_information10 Developer Descriptive flexfield column
 * @param p_pji_information11 Developer Descriptive flexfield column
 * @param p_pji_information12 Developer Descriptive flexfield column
 * @param p_pji_information13 Developer Descriptive flexfield column
 * @param p_pji_information14 Developer Descriptive flexfield column
 * @param p_pji_information15 Developer Descriptive flexfield column
 * @param p_pji_information16 Developer Descriptive flexfield column
 * @param p_pji_information17 Developer Descriptive flexfield column
 * @param p_pji_information18 Developer Descriptive flexfield column
 * @param p_pji_information19 Developer Descriptive flexfield column
 * @param p_pji_information20 Developer Descriptive flexfield column
 * @param p_pji_information21 Developer Descriptive flexfield column
 * @param p_pji_information22 Developer Descriptive flexfield column
 * @param p_pji_information23 Developer Descriptive flexfield column
 * @param p_pji_information24 Developer Descriptive flexfield column
 * @param p_pji_information25 Developer Descriptive flexfield column
 * @param p_pji_information26 Developer Descriptive flexfield column
 * @param p_pji_information27 Developer Descriptive flexfield column
 * @param p_pji_information28 Developer Descriptive flexfield column
 * @param p_pji_information29 Developer Descriptive flexfield column
 * @param p_pji_information30 Developer Descriptive flexfield column
 * @param p_previous_job_extra_info_id Uniquely identifies the extra
 * information record to be updated.
 * @param p_object_version_number Pass in the current version number of the
 * previous job extra information to be updated. When the API completes if
 * p_validate is false, will be set to the new version number of the updated
 * previous job extra information. If p_validate is true will be set to the
 * same value which was passed in.
 * @rep:displayname Update Previous Job Extra Information
 * @rep:category BUSINESS_ENTITY PER_PREVIOUS_EMPLOYMENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_prev_job_extra_info
 (p_validate                       in boolean  default false
 ,p_previous_job_id                in number
 ,p_information_type               in varchar2 default hr_api.g_varchar2
 ,p_pji_attribute_category         in varchar2 default hr_api.g_varchar2
 ,p_pji_attribute1                 in varchar2 default hr_api.g_varchar2
 ,p_pji_attribute2                 in varchar2 default hr_api.g_varchar2
 ,p_pji_attribute3                 in varchar2 default hr_api.g_varchar2
 ,p_pji_attribute4                 in varchar2 default hr_api.g_varchar2
 ,p_pji_attribute5                 in varchar2 default hr_api.g_varchar2
 ,p_pji_attribute6                 in varchar2 default hr_api.g_varchar2
 ,p_pji_attribute7                 in varchar2 default hr_api.g_varchar2
 ,p_pji_attribute8                 in varchar2 default hr_api.g_varchar2
 ,p_pji_attribute9                 in varchar2 default hr_api.g_varchar2
 ,p_pji_attribute10                in varchar2 default hr_api.g_varchar2
 ,p_pji_attribute11                in varchar2 default hr_api.g_varchar2
 ,p_pji_attribute12                in varchar2 default hr_api.g_varchar2
 ,p_pji_attribute13                in varchar2 default hr_api.g_varchar2
 ,p_pji_attribute14                in varchar2 default hr_api.g_varchar2
 ,p_pji_attribute15                in varchar2 default hr_api.g_varchar2
 ,p_pji_attribute16                in varchar2 default hr_api.g_varchar2
 ,p_pji_attribute17                in varchar2 default hr_api.g_varchar2
 ,p_pji_attribute18                in varchar2 default hr_api.g_varchar2
 ,p_pji_attribute19                in varchar2 default hr_api.g_varchar2
 ,p_pji_attribute20                in varchar2 default hr_api.g_varchar2
 ,p_pji_attribute21                in varchar2 default hr_api.g_varchar2
 ,p_pji_attribute22                in varchar2 default hr_api.g_varchar2
 ,p_pji_attribute23                in varchar2 default hr_api.g_varchar2
 ,p_pji_attribute24                in varchar2 default hr_api.g_varchar2
 ,p_pji_attribute25                in varchar2 default hr_api.g_varchar2
 ,p_pji_attribute26                in varchar2 default hr_api.g_varchar2
 ,p_pji_attribute27                in varchar2 default hr_api.g_varchar2
 ,p_pji_attribute28                in varchar2 default hr_api.g_varchar2
 ,p_pji_attribute29                in varchar2 default hr_api.g_varchar2
 ,p_pji_attribute30                in varchar2 default hr_api.g_varchar2
 ,p_pji_information_category       in varchar2 default hr_api.g_varchar2
 ,p_pji_information1               in varchar2 default hr_api.g_varchar2
 ,p_pji_information2               in varchar2 default hr_api.g_varchar2
 ,p_pji_information3               in varchar2 default hr_api.g_varchar2
 ,p_pji_information4               in varchar2 default hr_api.g_varchar2
 ,p_pji_information5               in varchar2 default hr_api.g_varchar2
 ,p_pji_information6               in varchar2 default hr_api.g_varchar2
 ,p_pji_information7               in varchar2 default hr_api.g_varchar2
 ,p_pji_information8               in varchar2 default hr_api.g_varchar2
 ,p_pji_information9               in varchar2 default hr_api.g_varchar2
 ,p_pji_information10              in varchar2 default hr_api.g_varchar2
 ,p_pji_information11              in varchar2 default hr_api.g_varchar2
 ,p_pji_information12              in varchar2 default hr_api.g_varchar2
 ,p_pji_information13              in varchar2 default hr_api.g_varchar2
 ,p_pji_information14              in varchar2 default hr_api.g_varchar2
 ,p_pji_information15              in varchar2 default hr_api.g_varchar2
 ,p_pji_information16              in varchar2 default hr_api.g_varchar2
 ,p_pji_information17              in varchar2 default hr_api.g_varchar2
 ,p_pji_information18              in varchar2 default hr_api.g_varchar2
 ,p_pji_information19              in varchar2 default hr_api.g_varchar2
 ,p_pji_information20              in varchar2 default hr_api.g_varchar2
 ,p_pji_information21              in varchar2 default hr_api.g_varchar2
 ,p_pji_information22              in varchar2 default hr_api.g_varchar2
 ,p_pji_information23              in varchar2 default hr_api.g_varchar2
 ,p_pji_information24              in varchar2 default hr_api.g_varchar2
 ,p_pji_information25              in varchar2 default hr_api.g_varchar2
 ,p_pji_information26              in varchar2 default hr_api.g_varchar2
 ,p_pji_information27              in varchar2 default hr_api.g_varchar2
 ,p_pji_information28              in varchar2 default hr_api.g_varchar2
 ,p_pji_information29              in varchar2 default hr_api.g_varchar2
 ,p_pji_information30              in varchar2 default hr_api.g_varchar2
 ,p_previous_job_extra_info_id     in number
 ,p_object_version_number          in out nocopy number
 );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_prev_job_extra_info >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes extra information for a previous job.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Extra information for the previous job must exist.
 *
 * <p><b>Post Success</b><br>
 * Extra information is deleted for this previous job.
 *
 * <p><b>Post Failure</b><br>
 * Extra information is not deleted for this previous job and an error will be
 * raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_previous_job_extra_info_id Uniquely identifies the previous job
 * extra information record to be deleted.
 * @param p_object_version_number Current version number of the previous job
 * extra information to be deleted.
 * @rep:displayname Delete Previous Job Extra Information
 * @rep:category BUSINESS_ENTITY PER_PREVIOUS_EMPLOYMENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_prev_job_extra_info
  (p_validate                       in     boolean
  ,p_previous_job_extra_info_id     in     number
  ,p_object_version_number          in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_previous_job_usage >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a previous job usage.
 *
 * A job usage record stores information about which previous job records (and
 * which durations of time worked on previous jobs) apply to which of the
 * employee's current assignments. Job usage applies mainly to public sector
 * enterprises that enforce strict rules for grade step progression based on
 * previous periods of employment. For example, an employee's past teaching
 * experience may only be relevant to the employee's primary assignment.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The person must have a previous job with a previous employer. The previous
 * employer must have the 'Applies to all assignments' flag set to 'N'.
 *
 * <p><b>Post Success</b><br>
 * A previous job usage is created.
 *
 * <p><b>Post Failure</b><br>
 * A previous job is not created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_assignment_id Indicates which assigment record this previous period
 * of employment is relevant to.
 * @param p_previous_employer_id Uniquely identifies the employer associated
 * with the previous job.
 * @param p_previous_job_id Uniquely indicates which previous job is relevant
 * to the specified assignment. If you do not specify a value, the process
 * assumes that all previous jobs are relevant to the specified assignment.
 * @param p_start_date The start date of the period of service in the previous
 * job relevant to the specified assignment. If left null, the process assumes
 * that the start date of either the parent previous job or previous employment
 * is relevant to the assigment.
 * @param p_end_date The end date of the period of service for the previous job
 * relevant to the specified assignment. If left null, the process assumes that
 * the end date of either the parent previous job or the previous employment is
 * relevant to the assigment.
 * @param p_period_years The number of years of previous employment time
 * relevant to the specified assignment. If left null, the process calculates
 * this based on the start date and end date. For example, if the start date is
 * '01-JAN-2000' and the end date is '05-MAR-2004', the process sets four
 * years.
 * @param p_period_months The number of months of previous employment time
 * relevant to the specified assignment, over and above years. If left null,
 * the process calculates this from the start and end date. For example, if the
 * start date is '01-JAN-2000' and the end date is '05-MAR-2004', the process
 * sets two months.
 * @param p_period_days The number of days of previous employment time relevant
 * to the specified assignment, over and above years and months. If left null,
 * the process calculates this from the start and end date. For example, if the
 * start date is '01-JAN-2000' and the end date is '05-MAR-2004', the process
 * sets five days.
 * @param p_pju_attribute_category Descriptive flexfield structure defining
 * column.
 * @param p_pju_attribute1 Descriptive flexfield column
 * @param p_pju_attribute2 Descriptive flexfield column
 * @param p_pju_attribute3 Descriptive flexfield column
 * @param p_pju_attribute4 Descriptive flexfield column
 * @param p_pju_attribute5 Descriptive flexfield column
 * @param p_pju_attribute6 Descriptive flexfield column
 * @param p_pju_attribute7 Descriptive flexfield column
 * @param p_pju_attribute8 Descriptive flexfield column
 * @param p_pju_attribute9 Descriptive flexfield column
 * @param p_pju_attribute10 Descriptive flexfield column
 * @param p_pju_attribute11 Descriptive flexfield column
 * @param p_pju_attribute12 Descriptive flexfield column
 * @param p_pju_attribute13 Descriptive flexfield column
 * @param p_pju_attribute14 Descriptive flexfield column
 * @param p_pju_attribute15 Descriptive flexfield column
 * @param p_pju_attribute16 Descriptive flexfield column
 * @param p_pju_attribute17 Descriptive flexfield column
 * @param p_pju_attribute18 Descriptive flexfield column
 * @param p_pju_attribute19 Descriptive flexfield column
 * @param p_pju_attribute20 Descriptive flexfield column
 * @param p_pju_information_category Developer Descriptive flexfield structure
 * defining column.
 * @param p_pju_information1 Developer Descriptive flexfield column
 * @param p_pju_information2 Developer Descriptive flexfield column
 * @param p_pju_information3 Developer Descriptive flexfield column
 * @param p_pju_information4 Developer Descriptive flexfield column
 * @param p_pju_information5 Developer Descriptive flexfield column
 * @param p_pju_information6 Developer Descriptive flexfield column
 * @param p_pju_information7 Developer Descriptive flexfield column
 * @param p_pju_information8 Developer Descriptive flexfield column
 * @param p_pju_information9 Developer Descriptive flexfield column
 * @param p_pju_information10 Developer Descriptive flexfield column
 * @param p_pju_information11 Developer Descriptive flexfield column
 * @param p_pju_information12 Developer Descriptive flexfield column
 * @param p_pju_information13 Developer Descriptive flexfield column
 * @param p_pju_information14 Developer Descriptive flexfield column
 * @param p_pju_information15 Developer Descriptive flexfield column
 * @param p_pju_information16 Developer Descriptive flexfield column
 * @param p_pju_information17 Developer Descriptive flexfield column
 * @param p_pju_information18 Developer Descriptive flexfield column
 * @param p_pju_information19 Developer Descriptive flexfield column
 * @param p_pju_information20 Developer Descriptive flexfield column
 * @param p_previous_job_usage_id If p_validate is false, then this uniquely
 * identifies the previous job usage created. If p_validate is true, then set
 * to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created previous job usage. If p_validate is true,
 * then the value will be null.
 * @rep:displayname Create Previous Job Usage
 * @rep:category BUSINESS_ENTITY PER_PREVIOUS_EMPLOYMENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_previous_job_usage
  (p_validate                       in      boolean
  ,p_assignment_id                  in      number
  ,p_previous_employer_id           in      number
  ,p_previous_job_id                in      number
  ,p_start_date                     in      date     default null
  ,p_end_date                       in      date     default null
  ,p_period_years                   in      number   default null
  ,p_period_months                  in      number   default null
  ,p_period_days                    in      number   default null
  ,p_pju_attribute_category         in      varchar2 default null
  ,p_pju_attribute1                 in      varchar2 default null
  ,p_pju_attribute2                 in      varchar2 default null
  ,p_pju_attribute3                 in      varchar2 default null
  ,p_pju_attribute4                 in      varchar2 default null
  ,p_pju_attribute5                 in      varchar2 default null
  ,p_pju_attribute6                 in      varchar2 default null
  ,p_pju_attribute7                 in      varchar2 default null
  ,p_pju_attribute8                 in      varchar2 default null
  ,p_pju_attribute9                 in      varchar2 default null
  ,p_pju_attribute10                in      varchar2 default null
  ,p_pju_attribute11                in      varchar2 default null
  ,p_pju_attribute12                in      varchar2 default null
  ,p_pju_attribute13                in      varchar2 default null
  ,p_pju_attribute14                in      varchar2 default null
  ,p_pju_attribute15                in      varchar2 default null
  ,p_pju_attribute16                in      varchar2 default null
  ,p_pju_attribute17                in      varchar2 default null
  ,p_pju_attribute18                in      varchar2 default null
  ,p_pju_attribute19                in      varchar2 default null
  ,p_pju_attribute20                in      varchar2 default null
  ,p_pju_information_category       in      varchar2 default null
  ,p_pju_information1               in      varchar2 default null
  ,p_pju_information2               in      varchar2 default null
  ,p_pju_information3               in      varchar2 default null
  ,p_pju_information4               in      varchar2 default null
  ,p_pju_information5               in      varchar2 default null
  ,p_pju_information6               in      varchar2 default null
  ,p_pju_information7               in      varchar2 default null
  ,p_pju_information8               in      varchar2 default null
  ,p_pju_information9               in      varchar2 default null
  ,p_pju_information10              in      varchar2 default null
  ,p_pju_information11              in      varchar2 default null
  ,p_pju_information12              in      varchar2 default null
  ,p_pju_information13              in      varchar2 default null
  ,p_pju_information14              in      varchar2 default null
  ,p_pju_information15              in      varchar2 default null
  ,p_pju_information16              in      varchar2 default null
  ,p_pju_information17              in      varchar2 default null
  ,p_pju_information18              in      varchar2 default null
  ,p_pju_information19              in      varchar2 default null
  ,p_pju_information20              in      varchar2 default null
  ,p_previous_job_usage_id          out nocopy     number
  ,p_object_version_number          out nocopy     number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_previous_job_usage >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a previous job usage.
 *
 * A job usage record stores information about which previous job records (and
 * which durations of time worked on previous jobs) apply to which of the
 * employee's current assignments. Job usage applies mainly to public sector
 * enterprises that enforce strict rules for grade step progression based on
 * previous periods of employment. For example, an employee's past teaching
 * experience may only be relevant to the employee's primary assignment.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A previous job usage must exist.
 *
 * <p><b>Post Success</b><br>
 * The previous job usage is updated
 *
 * <p><b>Post Failure</b><br>
 * The previous job usage is not updated and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_previous_job_usage_id Uniquely identifies the previous job usage to
 * be updated.
 * @param p_assignment_id Indicates which assigment record this previous period
 * of employment is relevant to.
 * @param p_previous_employer_id Uniquely identifies the employer associated
 * with the previous job.
 * @param p_previous_job_id Uniquely indicates which previous job is relevant
 * to the specified assignment. If you do not specify a value, the process
 * assumes that all previous jobs are relevant to the specified assignment.
 * @param p_start_date The start date of the period of service in the previous
 * job relevant to the specified assignment. If left null, the process assumes
 * that the start date of either the parent previous job or previous employment
 * is relevant to the assigment.
 * @param p_end_date The end date of the period of service for the previous job
 * relevant to the specified assignment. If left null, the process assumes that
 * the end date of either the parent previous job or the previous employment is
 * relevant to the assigment.
 * @param p_period_years The number of years of previous employment time
 * relevant to the specified assignment. If left null, the process calculates
 * this based on the start date and end date. For example, if the start date is
 * '01-JAN-2000' and the end date is '05-MAR-2004', the process sets four
 * years.
 * @param p_period_months The number of months of previous employment time
 * relevant to the specified assignment, over and above years. If left null,
 * the process calculates this from the start and end date. For example, if the
 * start date is '01-JAN-2000' and the end date is '05-MAR-2004', the process
 * sets two months.
 * @param p_period_days The number of days of previous employment time relevant
 * to the specified assignment, over and above years and months. If left null,
 * the process calculates this from the start and end date. For example, if the
 * start date is '01-JAN-2000' and the end date is '05-MAR-2004', the process
 * sets five days.
 * @param p_pju_attribute_category Descriptive flexfield structure defining
 * column.
 * @param p_pju_attribute1 Descriptive flexfield column
 * @param p_pju_attribute2 Descriptive flexfield column
 * @param p_pju_attribute3 Descriptive flexfield column
 * @param p_pju_attribute4 Descriptive flexfield column
 * @param p_pju_attribute5 Descriptive flexfield column
 * @param p_pju_attribute6 Descriptive flexfield column
 * @param p_pju_attribute7 Descriptive flexfield column
 * @param p_pju_attribute8 Descriptive flexfield column
 * @param p_pju_attribute9 Descriptive flexfield column
 * @param p_pju_attribute10 Descriptive flexfield column
 * @param p_pju_attribute11 Descriptive flexfield column
 * @param p_pju_attribute12 Descriptive flexfield column
 * @param p_pju_attribute13 Descriptive flexfield column
 * @param p_pju_attribute14 Descriptive flexfield column
 * @param p_pju_attribute15 Descriptive flexfield column
 * @param p_pju_attribute16 Descriptive flexfield column
 * @param p_pju_attribute17 Descriptive flexfield column
 * @param p_pju_attribute18 Descriptive flexfield column
 * @param p_pju_attribute19 Descriptive flexfield column
 * @param p_pju_attribute20 Descriptive flexfield column
 * @param p_pju_information_category Developer Descriptive flexfield structure
 * defining column.
 * @param p_pju_information1 Developer Descriptive flexfield column
 * @param p_pju_information2 Developer Descriptive flexfield column
 * @param p_pju_information3 Developer Descriptive flexfield column
 * @param p_pju_information4 Developer Descriptive flexfield column
 * @param p_pju_information5 Developer Descriptive flexfield column
 * @param p_pju_information6 Developer Descriptive flexfield column
 * @param p_pju_information7 Developer Descriptive flexfield column
 * @param p_pju_information8 Developer Descriptive flexfield column
 * @param p_pju_information9 Developer Descriptive flexfield column
 * @param p_pju_information10 Developer Descriptive flexfield column
 * @param p_pju_information11 Developer Descriptive flexfield column
 * @param p_pju_information12 Developer Descriptive flexfield column
 * @param p_pju_information13 Developer Descriptive flexfield column
 * @param p_pju_information14 Developer Descriptive flexfield column
 * @param p_pju_information15 Developer Descriptive flexfield column
 * @param p_pju_information16 Developer Descriptive flexfield column
 * @param p_pju_information17 Developer Descriptive flexfield column
 * @param p_pju_information18 Developer Descriptive flexfield column
 * @param p_pju_information19 Developer Descriptive flexfield column
 * @param p_pju_information20 Developer Descriptive flexfield column
 * @param p_object_version_number Pass in the current version number of the
 * previous job usage to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated previous job
 * usage. If p_validate is true will be set to the same value which was passed
 * in.
 * @rep:displayname Update Previous Job Usage
 * @rep:category BUSINESS_ENTITY PER_PREVIOUS_EMPLOYMENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_previous_job_usage
  (p_validate                       in boolean
  ,p_previous_job_usage_id          in number
  ,p_assignment_id                  in number
  ,p_previous_employer_id           in number
  ,p_previous_job_id                in number
  ,p_start_date                     in date     default hr_api.g_date
  ,p_end_date                       in date     default hr_api.g_date
  ,p_period_years                   in number   default hr_api.g_number
  ,p_period_months                  in number   default hr_api.g_number
  ,p_period_days                    in number   default hr_api.g_number
  ,p_pju_attribute_category         in varchar2 default hr_api.g_varchar2
  ,p_pju_attribute1                 in varchar2 default hr_api.g_varchar2
  ,p_pju_attribute2                 in varchar2 default hr_api.g_varchar2
  ,p_pju_attribute3                 in varchar2 default hr_api.g_varchar2
  ,p_pju_attribute4                 in varchar2 default hr_api.g_varchar2
  ,p_pju_attribute5                 in varchar2 default hr_api.g_varchar2
  ,p_pju_attribute6                 in varchar2 default hr_api.g_varchar2
  ,p_pju_attribute7                 in varchar2 default hr_api.g_varchar2
  ,p_pju_attribute8                 in varchar2 default hr_api.g_varchar2
  ,p_pju_attribute9                 in varchar2 default hr_api.g_varchar2
  ,p_pju_attribute10                in varchar2 default hr_api.g_varchar2
  ,p_pju_attribute11                in varchar2 default hr_api.g_varchar2
  ,p_pju_attribute12                in varchar2 default hr_api.g_varchar2
  ,p_pju_attribute13                in varchar2 default hr_api.g_varchar2
  ,p_pju_attribute14                in varchar2 default hr_api.g_varchar2
  ,p_pju_attribute15                in varchar2 default hr_api.g_varchar2
  ,p_pju_attribute16                in varchar2 default hr_api.g_varchar2
  ,p_pju_attribute17                in varchar2 default hr_api.g_varchar2
  ,p_pju_attribute18                in varchar2 default hr_api.g_varchar2
  ,p_pju_attribute19                in varchar2 default hr_api.g_varchar2
  ,p_pju_attribute20                in varchar2 default hr_api.g_varchar2
  ,p_pju_information_category       in varchar2 default hr_api.g_varchar2
  ,p_pju_information1               in varchar2 default hr_api.g_varchar2
  ,p_pju_information2               in varchar2 default hr_api.g_varchar2
  ,p_pju_information3               in varchar2 default hr_api.g_varchar2
  ,p_pju_information4               in varchar2 default hr_api.g_varchar2
  ,p_pju_information5               in varchar2 default hr_api.g_varchar2
  ,p_pju_information6               in varchar2 default hr_api.g_varchar2
  ,p_pju_information7               in varchar2 default hr_api.g_varchar2
  ,p_pju_information8               in varchar2 default hr_api.g_varchar2
  ,p_pju_information9               in varchar2 default hr_api.g_varchar2
  ,p_pju_information10              in varchar2 default hr_api.g_varchar2
  ,p_pju_information11              in varchar2 default hr_api.g_varchar2
  ,p_pju_information12              in varchar2 default hr_api.g_varchar2
  ,p_pju_information13              in varchar2 default hr_api.g_varchar2
  ,p_pju_information14              in varchar2 default hr_api.g_varchar2
  ,p_pju_information15              in varchar2 default hr_api.g_varchar2
  ,p_pju_information16              in varchar2 default hr_api.g_varchar2
  ,p_pju_information17              in varchar2 default hr_api.g_varchar2
  ,p_pju_information18              in varchar2 default hr_api.g_varchar2
  ,p_pju_information19              in varchar2 default hr_api.g_varchar2
  ,p_pju_information20              in varchar2 default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_previous_job_usage >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a previous job usage.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A previous job usage must exist.
 *
 * <p><b>Post Success</b><br>
 * The previous job usage is deleted.
 *
 * <p><b>Post Failure</b><br>
 * The previous job usage is not deleted and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_previous_job_usage_id Uniquely identifies the previous job usage to
 * be deleted.
 * @param p_object_version_number Current version number of the previous job
 * usage to be deleted.
 * @rep:displayname Delete Previous Job Usage
 * @rep:category BUSINESS_ENTITY PER_PREVIOUS_EMPLOYMENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_previous_job_usage
  (p_validate                       in     boolean
  ,p_previous_job_usage_id          in     number
  ,p_object_version_number          in out nocopy number
  );
--

--
end hr_previous_employment_api;

/
