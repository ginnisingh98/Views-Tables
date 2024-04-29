--------------------------------------------------------
--  DDL for Package PQH_FR_VALIDATIONS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_FR_VALIDATIONS_API" AUTHID CURRENT_USER as
/* $Header: pqvldapi.pkh 120.1 2005/10/02 02:28:42 aroussel $ */
/*#
 * This package contains APIs to create, update and delete services validation.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Service Validation for France
*/
--
-- ----------------------------------------------------------------------------
-- |----------------------------< insert_validation >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API validates and creates a services validation record in the database.
 *
 * Services validation is a process of validating a civil servant's
 * contributions to non-public sector pension funds. The process involves
 * recording the details of previous services of the civil servant, wherein he
 * was contributing to a non-public sector pension fund and then recording
 * various events that happen during the validation process and finally
 * defining the validation amount that is to be collected from the employer and
 * the employee.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Employee whose services validation is being processed must exist with in the
 * current business group.
 *
 * <p><b>Post Success</b><br>
 * A new services validation record is created in the database.
 *
 * <p><b>Post Failure</b><br>
 * A services validation record is not created in the database and an error is
 * raised
 * @param p_effective_date Specifies the reference date for validating lookup
 * values, applicable within the active date range. This date does not
 * determine when the changes take effect.
 * @param p_pension_fund_type_code Identifies the pension fund type to which
 * the civil servant was contributing prior to joining the current
 * organization. Valid values are identified by lookup type
 * 'FR_PQH_PENSION_FUND_TYPE'
 * @param p_pension_fund_id Pension fund name that the employee had with the
 * previous employer
 * @param p_business_group_id Business group identifier to which the employee
 * is associated. References HR_ALL_ORGANIZATION_UNITS.
 * @param p_person_id Identifies the person for whom services validation is
 * processed.
 * @param p_previously_validated_flag {@rep:casecolumn
 * PQH_FR_VALIDATIONS.PREVIOUSLY_VALIDATED_FLAG}
 * @param p_request_date {@rep:casecolumn PQH_FR_VALIDATIONS.REQUEST_DATE}
 * @param p_completion_date {@rep:casecolumn
 * PQH_FR_VALIDATIONS.COMPLETION_DATE}
 * @param p_previous_employer_id {@rep:casecolumn
 * PQH_FR_VALIDATIONS.PREVIOUS_EMPLOYER_ID}
 * @param p_status Identifies the status of the services validation process,
 * for example, pre-process, accepted etc. Valid values are identified by
 * lookup type 'FR_PQH_PROCESS_STATUS'
 * @param p_employer_amount Amount of money contributed by the employer towards
 * the pension fund of the employee
 * @param p_employer_currency_code Currency in terms of which money was
 * contributed by the employer towards the pension fund of the employee
 * @param p_employee_amount Amount of money contributed by the employee towards
 * his pension fund
 * @param p_employee_currency_code Currency in terms of which money was
 * contributed by the employee towards his pension fund
 * @param p_deduction_per_period {@rep:casecolumn
 * PQH_FR_VALIDATIONS.DEDUCTION_PER_PERIOD}
 * @param p_deduction_currency_code Currency in terms of which the employee pay
 * is deducted per pay period
 * @param p_percent_of_salary Percent of the salary that is deducted from the
 * employee pay per period to make contribution towards his pension fund
 * @param p_validation_id The process returns the unique validation identifier
 * generated for the new service validation record
 * @param p_object_version_number The process returns the version number of the
 * created service validation record
 * @rep:displayname Create Validation
 * @rep:category BUSINESS_ENTITY PQH_FR_SERVICES_VALIDATION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure Insert_Validation
  (p_effective_date               in     date
  ,p_pension_fund_type_code         in     varchar2
  ,p_pension_fund_id                in     number
  ,p_business_group_id              in     number
  ,p_person_id                      in     number
  ,p_previously_validated_flag      in     varchar2
  ,p_request_date                   in     date     default null
  ,p_completion_date                in     date     default null
  ,p_previous_employer_id           in     number   default null
  ,p_status                         in     varchar2 default null
  ,p_employer_amount                in     number   default null
  ,p_employer_currency_code         in     varchar2 default null
  ,p_employee_amount                in     number   default null
  ,p_employee_currency_code         in     varchar2 default null
  ,p_deduction_per_period           in     number   default null
  ,p_deduction_currency_code        in     varchar2 default null
  ,p_percent_of_salary              in     number   default null
  ,p_validation_id                     out nocopy number
  ,p_object_version_number             out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_validation >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API validates the record when an existing services validation record is
 * changed and updates the record in the database.
 *
 * It validates the business group identifier to which employee is associated
 * before updating the record .The record is updated in PQH_FR_VALIDATIONS
 * table
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Employee whose services validation is being updated should belong to an
 * existing business group and the record should exist with the specified
 * object version number.
 *
 * <p><b>Post Success</b><br>
 * The services validation is updated in the database with the current changes.
 *
 * <p><b>Post Failure</b><br>
 * The services validation is not updated in the database and an error is
 * raised
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect
 * @param p_validation_id {@rep:casecolumn PQH_FR_VALIDATIONS.VALIDATION_ID}
 * @param p_object_version_number Passes the current version number of the
 * services validation record to be updated. When the API completes, the
 * process returns the new version number of the updated services validation
 * record
 * @param p_pension_fund_type_code Identifies the pension fund type to which
 * the civil servant was contributing prior to joining the current
 * organization. Valid values are identified by lookup type
 * 'FR_PQH_PENSION_FUND_TYPE'
 * @param p_pension_fund_id Pension fund identifier name that employee had with
 * the previous employer
 * @param p_business_group_id Business group identifier to which the employee
 * is associated with the current employer
 * @param p_person_id Identifies the person for whom the services validation
 * record is created
 * @param p_previously_validated_flag {@rep:casecolumn
 * PQH_FR_VALIDATIONS.PREVIOUSLY_VALIDATED_FLAG}
 * @param p_request_date {@rep:casecolumn PQH_FR_VALIDATIONS.REQUEST_DATE}
 * @param p_completion_date {@rep:casecolumn
 * PQH_FR_VALIDATIONS.COMPLETION_DATE}
 * @param p_previous_employer_id {@rep:casecolumn
 * PQH_FR_VALIDATIONS.PREVIOUS_EMPLOYER_ID}
 * @param p_status Identifies the status of the services validation process,
 * for example, pre-process, accepted etc. Valid values are identified by
 * lookup type 'FR_PQH_PROCESS_STATUS'
 * @param p_employer_amount Amount of money contributed by the employer towards
 * the pension fund of the employee
 * @param p_employer_currency_code Currency in terms of which money was
 * contributed by the employer towards the pension fund of the employee
 * @param p_employee_amount Amount of money contributed by the employee towards
 * his pension fund
 * @param p_employee_currency_code Currency in terms of which money was
 * contributed by the employee towards his pension fund
 * @param p_deduction_per_period {@rep:casecolumn
 * PQH_FR_VALIDATIONS.DEDUCTION_PER_PERIOD}
 * @param p_deduction_currency_code Currency in terms of which the employee pay
 * is deducted per pay period
 * @param p_percent_of_salary Percent of the salary that is deducted from the
 * employee pay per period to make contribution towards his pension fund
 * @rep:displayname Update Validation
 * @rep:category BUSINESS_ENTITY PQH_FR_SERVICES_VALIDATION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure Update_Validation
  (p_effective_date               in     date
  ,p_validation_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_pension_fund_type_code       in     varchar2  default hr_api.g_varchar2
  ,p_pension_fund_id              in     number    default hr_api.g_number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_person_id                    in     number    default hr_api.g_number
  ,p_previously_validated_flag    in     varchar2  default hr_api.g_varchar2
  ,p_request_date                 in     date      default hr_api.g_date
  ,p_completion_date              in     date      default hr_api.g_date
  ,p_previous_employer_id         in     number    default hr_api.g_number
  ,p_status                       in     varchar2  default hr_api.g_varchar2
  ,p_employer_amount              in     number    default hr_api.g_number
  ,p_employer_currency_code       in     varchar2  default hr_api.g_varchar2
  ,p_employee_amount              in     number    default hr_api.g_number
  ,p_employee_currency_code       in     varchar2  default hr_api.g_varchar2
  ,p_deduction_per_period         in     number    default hr_api.g_number
  ,p_deduction_currency_code      in     varchar2  default hr_api.g_varchar2
  ,p_percent_of_salary            in     number    default hr_api.g_number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_validation >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a services validation record from the database.
 *
 * There must not be any service periods or validation events recorded for the
 * services validation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * All the service period and validation event records corresponding to this
 * services validation must have been deleted first.
 *
 * <p><b>Post Success</b><br>
 * Services validation record is deleted from the database.
 *
 * <p><b>Post Failure</b><br>
 * Services validation record is not deleted from the database and an error is
 * raised
 * @param p_validation_id {@rep:casecolumn PQH_FR_VALIDATIONS.VALIDATION_ID}
 * @param p_object_version_number Current version number of the services
 * validation record to be deleted
 * @rep:displayname Delete Validation
 * @rep:category BUSINESS_ENTITY PQH_FR_SERVICES_VALIDATION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
Procedure Delete_Validation
  (p_validation_id                        in     number
  ,p_object_version_number                in     number);
--
end  PQH_FR_VALIDATIONS_API;

 

/
