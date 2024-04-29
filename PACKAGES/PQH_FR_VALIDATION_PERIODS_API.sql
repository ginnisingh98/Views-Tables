--------------------------------------------------------
--  DDL for Package PQH_FR_VALIDATION_PERIODS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_FR_VALIDATION_PERIODS_API" AUTHID CURRENT_USER as
/* $Header: pqvlpapi.pkh 120.1 2005/10/02 02:28:53 aroussel $ */
/*#
 * This package contains APIs to create, update and delete service periods.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Service Validation Period for France
*/
--
-- ----------------------------------------------------------------------------
-- |-------------------------< insert_validation_period >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API validates and creates a service period record.
 *
 * This API validates the new service periods against the already recorded
 * service periods for overlapping. Only periods that are marked as Validated
 * are counted for length of service computations.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A service period can only be recorded for an existing services validation
 * record.
 *
 * <p><b>Post Success</b><br>
 * A new service period is created for the services validation in the database.
 *
 * <p><b>Post Failure</b><br>
 * A service period is not created in the database and an error is raised
 * @param p_effective_date Specifies the reference date for validating lookup
 * values, applicable within the active date range. This date does not
 * determine when the changes take effect.
 * @param p_validation_id Identifier of the service validation for which the
 * service period is being created. It references PQH_FR_VALIDATIONS.
 * @param p_start_date Start date of a service period with a previous employer
 * @param p_end_date End date of a service period with a previous employer
 * @param p_previous_employer_id Identifier of the previous employer.
 * References PER_PREVIOUS_EMPLOYERS.
 * @param p_assignment_category Specifies the working type of the employee with
 * the previous employer. Valid values are identified by lookup type EMP_CAT.
 * @param p_normal_hours Number of hours the employee used to work with the
 * previous employer with respect to the given frequency
 * @param p_frequency Unit of time with respect to which number of working
 * hours is provided. It may be day, month etc. Valid values are identified by
 * lookup type FREQUENCY.
 * @param p_period_years The total effective service period taken into
 * consideration for the employee with the employer expressed in terms of
 * years, months and days, this parameter refers to the year fraction of the
 * period
 * @param p_period_months The total effective service period taken into
 * consideration for the employee with the employer expressed in terms of
 * years, months and days, this parameter refers to the month fraction of the
 * period
 * @param p_period_days The total effective service period taken into
 * consideration for the employee with the employer expressed in terms of
 * years, months and days, this parameter refers to the day fraction of the
 * period
 * @param p_comments Comment text
 * @param p_validation_status Indicate whether the service period can be
 * validated or not. Valid values are identified by lookup type
 * 'FR_PQH_VALIDATION_STATUS'.
 * @param p_validation_period_id The process returns the unique validation
 * period identifier generated for the new service period record
 * @param p_object_version_number It is set to the version number of the
 * created service period record
 * @rep:displayname Create Service Validation Period
 * @rep:category BUSINESS_ENTITY PQH_FR_SERVICES_VALIDATION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure Insert_Validation_Period
  (p_effective_date               in     date
  ,p_validation_id                  in     number
  ,p_start_date                     in     date     default null
  ,p_end_date                       in     date     default null
  ,p_previous_employer_id           in     number   default null
  ,p_assignment_category            in     varchar2 default null
  ,p_normal_hours                   in     number   default null
  ,p_frequency                      in     varchar2 default null
  ,p_period_years                   in     number   default null
  ,p_period_months                  in     number   default null
  ,p_period_days                    in     number   default null
  ,p_comments                       in     varchar2 default null
  ,p_validation_status              in     varchar2 default null
  ,p_validation_period_id              out nocopy number
  ,p_object_version_number             out nocopy number);
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_validation_period >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API validates the record when an existing service period record is
 * changed and updates the record in the database.
 *
 * API validates the updated service period against the existing service
 * periods to ensure there are no overlapping dates. The record is updated in
 * PQH_FR_VALIDATION_PERIODS table
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The record should exist with the specified object version number.
 *
 * <p><b>Post Success</b><br>
 * The service period is updated in the database with the current changes.
 *
 * <p><b>Post Failure</b><br>
 * The service period is not updated in the database and an error is raised
 * @param p_effective_date Specifies the reference date for validating lookup
 * values, applicable within the active date range. This date does not
 * determine when the changes take effect.
 * @param p_validation_period_id {@rep:casecolumn
 * PQH_FR_VALIDATION_PERIODS.VALIDATION_PERIOD_ID}
 * @param p_object_version_number Passes the current version number of the
 * service period record to be updated. When the API completes the process
 * returns the new version number of the updated service period record
 * @param p_validation_id Identifier of the service validation for which the
 * service period is being created. It references PQH_FR_VALIDATIONS.
 * @param p_start_date Start date of a service period with a previous employer
 * @param p_end_date End date of a service period with a previous employer
 * @param p_previous_employer_id Identifier of the previous employer.
 * References PER_PREVIOUS_EMPLOYERS.
 * @param p_assignment_category Specifies the working type of the employee with
 * the previous employer. Valid values are identified by lookup type EMP_CAT.
 * @param p_normal_hours Number of hours the employee used to work with the
 * previous employer with respect to the given frequency
 * @param p_frequency It is the unit of time with respect to which number of
 * working hours is provided. It may be day, month etc. Valid values are
 * identified by lookup type FREQUENCY.
 * @param p_period_years The total effective service period taken into
 * consideration for the employee with the employer expressed in terms of
 * years, months and days, this parameter refers to the year fraction of the
 * period
 * @param p_period_months The total effective service period taken into
 * consideration for the employee with the employer expressed in terms of
 * years, months and days, this parameter refers to the month fraction of the
 * period
 * @param p_period_days The total effective service period taken into
 * consideration for the employee with the employer expressed in terms of
 * years, months and days, this parameter refers to the day fraction of the
 * period
 * @param p_comments Comment text
 * @param p_validation_status Indicate whether the Service Period can be
 * validated or is impossible to validate. Valid values are identified by
 * lookup type FR_PQH_VALIDATION_STATUS.
 * @rep:displayname Update Service Validation Period
 * @rep:category BUSINESS_ENTITY PQH_FR_SERVICES_VALIDATION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure Update_Validation_Period
  (p_effective_date               in     date
  ,p_validation_period_id         in     number
  ,p_object_version_number        in out nocopy number
  ,p_validation_id                in     number    default hr_api.g_number
  ,p_start_date                   in     date      default hr_api.g_date
  ,p_end_date                     in     date      default hr_api.g_date
  ,p_previous_employer_id         in     number    default hr_api.g_number
  ,p_assignment_category          in     varchar2  default hr_api.g_varchar2
  ,p_normal_hours                 in     number    default hr_api.g_number
  ,p_frequency                    in     varchar2  default hr_api.g_varchar2
  ,p_period_years                 in     number    default hr_api.g_number
  ,p_period_months                in     number    default hr_api.g_number
  ,p_period_days                  in     number    default hr_api.g_number
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ,p_validation_status            in     varchar2  default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_validation_period >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a service period record from the database.
 *
 * The record is deleted from PQH_FR_VALIDATION_PERIODS table
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The record should exist with the specified object version number.
 *
 * <p><b>Post Success</b><br>
 * A service period record is deleted from the database.
 *
 * <p><b>Post Failure</b><br>
 * A service period record is not deleted from the database and an error is
 * raised
 * @param p_validation_period_id {@rep:casecolumn
 * PQH_FR_VALIDATION_PERIODS.VALIDATION_PERIOD_ID}
 * @param p_object_version_number Current version number of the service period
 * record to be deleted
 * @rep:displayname Delete Service Validation Period
 * @rep:category BUSINESS_ENTITY PQH_FR_SERVICES_VALIDATION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
Procedure Delete_Validation_Period
  (p_validation_period_id                        in     number
  ,p_object_version_number                in     number);
--
end  PQH_FR_VALIDATION_PERIODS_API;

 

/
