--------------------------------------------------------
--  DDL for Package PQH_FR_STAT_SITUATIONS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_FR_STAT_SITUATIONS_API" AUTHID CURRENT_USER as
/* $Header: pqstsapi.pkh 120.2 2005/10/28 17:50 deenath noship $ */
/*#
 * This package contains APIs to validate, create, update and delete statutory
 * situations.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Statutory Situation for France
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_statutory_situation >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API validates and creates a statutory situation record in the database.
 *
 * Statutory situation denotes the status of employment for civil servants in
 * French Public Sector. There are many entitlements that depend on the
 * statutory situation of a civil servant. It validates the situation name and
 * combination of type of public sector, situation type, sub type, location,
 * reason, source and business group id for uniqueness. The record is created
 * in PQH_FR_STAT_SITUATIONS table.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The statutory situation can be created only for an existing business group
 * with a type of public sector.
 *
 * <p><b>Post Success</b><br>
 * A new statutory situation record is created in the database.
 *
 * <p><b>Post Failure</b><br>
 * A statutory situation record is not created in the database and an error is
 * raised
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Specifies the reference date for validating lookup
 * values, applicable within the active date range. This date does not
 * determine when the changes take effect.
 * @param p_business_group_id Identifies the business group for which the
 * statutory situation is created. A foreign key to HR_ALL_ORGANIZATION_UNITS.
 * @param p_situation_name A unique name for the situation
 * @param p_type_of_ps Identifies the type of public sector for which the
 * statutory situation is created. Valid values are defined by
 * 'FR_PQH_ORG_CATEGORY' lookup type
 * @param p_situation_type Identifies the situation type. Valid values are
 * defined by 'FR_PQH_STAT_SIT_TYPE' lookup type
 * @param p_sub_type Identifies the situation sub type and the values are based
 * on the situation type above. Valid values are defined by
 * 'FR_PQH_STAT_SIT_SUB_TYPE' lookup type
 * @param p_source Indicates whether the civil servant to be placed on this
 * statutory situation belongs to your organization or an external organization
 * .Valid values are defined by 'FR_PQH_STAT_SIT_SOURCE' lookup type
 * @param p_location Indicates whether the civil servant is placed within or
 * outside your organization. Valid values are defined by
 * 'FR_PQH_STAT_SIT_PLCMENT' lookup type
 * @param p_reason Identifies the reason for placing the civil servant on the
 * statutory situation. Valid values are defined by 'FR_PQH_STAT_SIT_REASON'
 * lookup type
 * @param p_date_from Identifies the date from which the statutory situation is
 * active in the organization
 * @param p_date_to Identifies the date till which the statutory situation is
 * active in the organization
 * @param p_request_type Indicates the type of request to be made while
 * processing the statutory situation. Valid values are defined by
 * 'FR_PQH_STAT_SIT_RQST_TYPE' lookup type
 * @param p_employee_agreement_needed A flag indicating whether the employee's
 * agreement is required or not before placing him on the statutory situation
 * @param p_manager_agreement_needed A flag indicating whether the line
 * manager's agreement is required or not before placing an employee on the
 * statutory situation
 * @param p_print_arrette A flag indicating whether a printed decree is
 * required or not when a employee is placed on the statutory situation
 * @param p_reserve_position A flag indicating whether the position should be
 * reserved or not for the employee for the duration of the statutory situation
 * @param p_remuneration_paid A flag indicating whether the employee should per
 * paid any remuneration or not if he is placed on the statutory situation
 * @param p_pay_share The percentage of the actual pay that can be paid to the
 * employee when he is placed on the statutory situation. Valid values are
 * between 0 and 100. This can be specified only when the remuneration_paid
 * flag is set to Y.
 * @param p_pay_periods The number of pay periods for which the employee will
 * be paid after being placed on this statutory situation. Its value should
 * always be greater than 0. This can be specified only when the
 * remuneration_paid flag is set to Y.
 * @param p_frequency The unit of time period in terms of which various
 * duration limits for the statutory situation are defined Valid values are
 * defined by 'PROC_PERIOD_TYPE' lookup type
 * @param p_first_period_max_duration The maximum duration for which an
 * employee can be placed on the statutory situation for the first time. Its
 * value must be greater than 0. This can be specified only when the Frequency
 * for the duration limits is specified.
 * @param p_min_duration_per_request The minimum duration for which an employee
 * can be placed on the statutory situation for each request. Its value must be
 * greater than 0. This can be specified only when the Frequency for the
 * duration limits is specified.
 * @param p_max_duration_per_request The maximum duration for which an employee
 * can be placed on the statutory situation per request. Its value must be
 * greater than 0. This can be specified only when the Frequency for the
 * duration limits is specified.
 * @param p_max_duration_whole_career The maximum duration for which an
 * employee can be placed on the statutory situation in his whole career. Its
 * value must be greater than 0 and also must be greater than the maximum
 * duration for the first period. This can be specified only when the Frequency
 * for the duration limits is specified.
 * @param p_renewable_allowed A flag indicating whether the statutory situation
 * can be renewed or not for an employee. This can be specified only when the
 * Frequency for the duration limits is specified.
 * @param p_max_no_of_renewals The maximum number times the statutory situation
 * can be renewed for an employee. Its value must be greater than 0. This can
 * specified only when the statutory situation is renewable.
 * @param p_max_duration_per_renewal The maximum duration for which the
 * statutory situation can be renewed to an employee. Its value should always
 * be greater than 0. This can specified only when the statutory situation is
 * renewable.
 * @param p_max_tot_continuous_duration The maximum total of continuous
 * duration including renewals for which an employee can be placed on this
 * statutory situation Its value should always be greater than 0. This can be
 * specified only when Frequency value for duration limits is specified.
 * @param p_statutory_situation_id The process returns the unique statutory
 * situation identifier generated for the new statutory situation record
 * @param p_object_version_number If p_validate is false, the process returns
 * the version number of the created statutory situation. If p_validate is
 * true, it returns null
 * @param p_extend_probation_period A flag indicating whether the statutory
 * situation can be extended during Probation of an employee or not.
 * @param p_allow_progressions A flag indicating whether Progressions are
 * allowed for the employee or not during the statutory situation.
 * @param p_is_default A flag indicating whether the statutory situation
 * is the default statutory situation or not.
 * @param p_remunerate_assign_status_id If employee is going on a situation
 * and is going to be paid Remuneration while on the situation then this
 * identifier is used to indicate the Suspend With Pay Assignment Status.
 * @rep:displayname Create Statutory Situation
 * @rep:category BUSINESS_ENTITY PQH_FR_STATUTORY_SITUATION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_statutory_situation
  (p_validate                       in     boolean  default false
  ,p_effective_date                 in     date    default sysdate
  ,p_business_group_id              in     number
  ,p_situation_name                 in     varchar2
  ,p_type_of_ps                     in     varchar2
  ,p_situation_type                 in     varchar2
  ,p_sub_type                       in     varchar2 default null
  ,p_source                         in     varchar2 default null
  ,p_location                       in     varchar2 default null
  ,p_reason                         in     varchar2 default null
  ,p_is_default                     in     varchar2 default null
  ,p_date_from                      in     date     default null
  ,p_date_to                        in     date     default null
  ,p_request_type                   in     varchar2 default null
  ,p_employee_agreement_needed      in     varchar2 default null
  ,p_manager_agreement_needed       in     varchar2 default null
  ,p_print_arrette                  in     varchar2 default null
  ,p_reserve_position               in     varchar2 default null
  ,p_allow_progressions             in     varchar2 default null
  ,p_extend_probation_period        in     varchar2 default null
  ,p_remuneration_paid              in     varchar2 default null
  ,p_pay_share                      in     number   default null
  ,p_pay_periods                    in     number   default null
  ,p_frequency                      in     varchar2 default null
  ,p_first_period_max_duration      in     number   default null
  ,p_min_duration_per_request       in     number   default null
  ,p_max_duration_per_request       in     number   default null
  ,p_max_duration_whole_career      in     number   default null
  ,p_renewable_allowed              in     varchar2 default null
  ,p_max_no_of_renewals             in     number   default null
  ,p_max_duration_per_renewal       in     number   default null
  ,p_max_tot_continuous_duration    in     number   default null
  ,p_remunerate_assign_status_id    in     number   default null
  ,p_statutory_situation_id            out nocopy number
  ,p_object_version_number             out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_statutory_situation >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API validates the record when an existing statutory situation is
 * changed and updates the record in the database.
 *
 * It validates the Situation name for uniqueness. The record is updated in
 * PQH_FR_STAT_SITUATIONS table
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The statutory situation record must exist with the specified object version
 * number.
 *
 * <p><b>Post Success</b><br>
 * The existing record is updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * The existing record is not updated in the database and an error is raised
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Specifies the reference date for validating lookup
 * values, applicable within the active date range. This date does not
 * determine when the changes take effect.
 * @param p_statutory_situation_id {@rep:casecolumn
 * PQH_FR_STAT_SITUATIONS.STATUTORY_SITUATION_ID}
 * @param p_object_version_number Passes the current version number of the
 * statutory situation record to be updated. When the API completes if
 * p_validate is false, the process returns the new version number of the
 * updated statutory situation record. If p_validate is true, it returns the
 * same value which was passed in
 * @param p_business_group_id Identifies the business group for which the
 * statutory situation is created. A foreign key to HR_ALL_ORGANIZATION_UNITS.
 * @param p_situation_name A unique name for the situation
 * @param p_type_of_ps Identifies the type of public sector for which the
 * statutory situation is created. This cannot be updated.
 * @param p_situation_type Identifies the situation type. This cannot be
 * updated.
 * @param p_sub_type Identifies the situation sub type and the values are based
 * on the situation type above. This cannot be updated.
 * @param p_source Indicates whether the civil servant to be placed on this
 * statutory situation belongs to your organization or an external organization
 * .This cannot be updated.
 * @param p_location Indicates whether the civil servant is placed within or
 * outside your organization. This cannot be updated.
 * @param p_reason Identifies the reason for placing the civil servant on the
 * statutory situation. This cannot be updated.
 * @param p_date_from Identifies the date from which the statutory situation is
 * active in the organization
 * @param p_date_to Identifies the date till which the statutory situation is
 * active in the organization
 * @param p_request_type Indicates the type of request to be made while
 * processing the statutory situation. Valid values are defined by
 * 'FR_PQH_STAT_SIT_RQST_TYPE' lookup type
 * @param p_employee_agreement_needed A flag indicating whether the employee's
 * agreement is required or not before placing him on the statutory situation
 * @param p_manager_agreement_needed A flag indicating whether the line
 * manager's agreement is required or not before placing an employee on the
 * statutory situation
 * @param p_print_arrette A flag indicating whether a printed decree is
 * required or not when a employee is placed on the statutory situation
 * @param p_reserve_position A flag indicating whether the position should be
 * reserved or not for the employee for the duration of the statutory situation
 * @param p_remuneration_paid A flag indicating whether the employee should per
 * paid any remuneration or not if he is placed on the statutory situation
 * @param p_pay_share The percentage of the actual pay that can be paid to the
 * employee when he is placed on the statutory situation. Valid values are
 * between 0 and 100. This can be specified only when the remuneration_paid
 * flag is set to Y.
 * @param p_pay_periods The number of pay periods for which the employee will
 * be paid after being placed on this statutory situation. Its value should
 * always be greater than 0. This can be specified only when the
 * remuneration_paid flag is set to Y.
 * @param p_frequency The unit of time period in terms of which various
 * duration limits for the statutory situation are defined Valid values are
 * defined by 'PROC_PERIOD_TYPE' lookup type
 * @param p_first_period_max_duration The maximum duration for which an
 * employee can be placed on the statutory situation for the first time. Its
 * value must be greater than 0. This can be specified only when the Frequency
 * for the duration limits is specified.
 * @param p_min_duration_per_request The minimum duration for which an employee
 * can be placed on the statutory situation for each request. Its value must be
 * greater than 0. This can be specified only when the Frequency for the
 * duration limits is specified.
 * @param p_max_duration_per_request The maximum duration for which an employee
 * can be placed on the statutory situation per request. Its value must be
 * greater than 0. This can be specified only when the Frequency for the
 * duration limits is specified.
 * @param p_max_duration_whole_career The maximum duration for which an
 * employee can be placed on the statutory situation in his whole career. Its
 * value must be greater than 0 and also must be greater than the maximum
 * duration for the first period. This can be specified only when the Frequency
 * for the duration limits is specified.
 * @param p_renewable_allowed A flag indicating whether the statutory situation
 * can be renewed or not for an employee. This can be specified only when the
 * Frequency for the duration limits is specified.
 * @param p_max_no_of_renewals The maximum number times the statutory situation
 * can be renewed for an employee. Its value must be greater than 0. This can
 * specified only when the statutory situation is renewable.
 * @param p_max_duration_per_renewal The maximum duration for which the
 * statutory situation can be renewed to an employee. Its value should always
 * be greater than 0. This can specified only when the statutory situation is
 * renewable.
 * @param p_max_tot_continuous_duration The maximum total of continuous
 * duration including renewals for which an employee can be placed on this
 * statutory situation Its value should always be greater than 0. This can be
 * specified only when Frequency value for duration limits is specified.
 * @param p_is_default A flag indicating whether the statutory situation
 * is the default statutory situation or not.
 * @param p_extend_probation_period A flag indicating whether the statutory
 * situation can be extended during Probation of an employee or not.
 * @param p_allow_progressions A flag indicating whether Progressions are
 * allowed for the employee or not during the statutory situation.
 * @param p_remunerate_assign_status_id If employee is going on a situation
 * and is going to be paid Remuneration while on the situation then this
 * identifier is used to indicate the Suspend With Pay Assignment Status.
 * @rep:displayname Update Statutory Situation
 * @rep:category BUSINESS_ENTITY PQH_FR_STATUTORY_SITUATION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_statutory_situation
  (p_validate                     in     boolean   default false
  ,p_effective_date               in     date      default sysdate
  ,p_statutory_situation_id       in     number
  ,p_object_version_number        in out nocopy number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_situation_name               in     varchar2  default hr_api.g_varchar2
  ,p_type_of_ps                   in     varchar2  default hr_api.g_varchar2
  ,p_situation_type               in     varchar2  default hr_api.g_varchar2
  ,p_sub_type                     in     varchar2  default hr_api.g_varchar2
  ,p_source                       in     varchar2  default hr_api.g_varchar2
  ,p_location                     in     varchar2  default hr_api.g_varchar2
  ,p_reason                       in     varchar2  default hr_api.g_varchar2
  ,p_is_default                   in     varchar2  default hr_api.g_varchar2
  ,p_date_from                    in     date      default hr_api.g_date
  ,p_date_to                      in     date      default hr_api.g_date
  ,p_request_type                 in     varchar2  default hr_api.g_varchar2
  ,p_employee_agreement_needed    in     varchar2  default hr_api.g_varchar2
  ,p_manager_agreement_needed     in     varchar2  default hr_api.g_varchar2
  ,p_print_arrette                in     varchar2  default hr_api.g_varchar2
  ,p_reserve_position             in     varchar2  default hr_api.g_varchar2
  ,p_allow_progressions           in     varchar2  default hr_api.g_varchar2
  ,p_extend_probation_period      in     varchar2  default hr_api.g_varchar2
  ,p_remuneration_paid            in     varchar2  default hr_api.g_varchar2
  ,p_pay_share                    in     number    default hr_api.g_number
  ,p_pay_periods                  in     number    default hr_api.g_number
  ,p_frequency                    in     varchar2  default hr_api.g_varchar2
  ,p_first_period_max_duration    in     number    default hr_api.g_number
  ,p_min_duration_per_request     in     number    default hr_api.g_number
  ,p_max_duration_per_request     in     number    default hr_api.g_number
  ,p_max_duration_whole_career    in     number    default hr_api.g_number
  ,p_renewable_allowed            in     varchar2  default hr_api.g_varchar2
  ,p_max_no_of_renewals           in     number    default hr_api.g_number
  ,p_max_duration_per_renewal     in     number    default hr_api.g_number
  ,p_max_tot_continuous_duration  in     number    default hr_api.g_number
  ,p_remunerate_assign_status_id  in     number    default hr_api.g_number

  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_statutory_situation >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a statutory situation record from the database.
 *
 * The record is deleted from PQH_FR_STAT_SITUATIONS table
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * There should not be any civil servants placed on this statutory situation.
 * All the eligibility rule records corresponding to the statutory situation
 * should have been deleted. The record to be deleted should exist with the
 * specified object version number.
 *
 * <p><b>Post Success</b><br>
 * The statutory situation is deleted from the database.
 *
 * <p><b>Post Failure</b><br>
 * The statutory situation is not deleted from the database and an error is
 * raised
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_statutory_situation_id {@rep:casecolumn
 * PQH_FR_STAT_SITUATIONS.STATUTORY_SITUATION_ID}
 * @param p_object_version_number Current version number of the statutory
 * situation record to be deleted
 * @rep:displayname Delete Statutory Situation
 * @rep:category BUSINESS_ENTITY PQH_FR_STATUTORY_SITUATION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_statutory_situation
  (p_validate                      in     boolean  default false
  ,p_statutory_situation_id               in     number
  ,p_object_version_number                in     number
  );
--

end pqh_fr_stat_situations_api;

 

/
