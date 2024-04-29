--------------------------------------------------------
--  DDL for Package PQH_BUDGET_PERIODS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_BUDGET_PERIODS_API" AUTHID CURRENT_USER as
/* $Header: pqbprapi.pkh 120.1 2005/10/02 02:26:04 aroussel $ */
/*#
 * This package contains APIs to create, update and delete period level
 * distribution of a budget detail.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Budget Periods
*/
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_budget_period >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates the period details for a budget.
 *
 * Period level values for a budget unit corresponding to a budget detail is
 * created.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Budget detail should already exist. Start time period and end time period
 * should already exist.
 *
 * <p><b>Post Success</b><br>
 * Budget period detail will be inserted in the database.
 *
 * <p><b>Post Failure</b><br>
 * Budget period detail will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_budget_period_id If p_validate is false, then this uniquely
 * identifies the budget period record created. If p_validate is true, then set
 * to null.
 * @param p_budget_detail_id Budget detail identifier.
 * @param p_start_time_period_id Start date for the identifier.
 * @param p_end_time_period_id End date for the identifier.
 * @param p_budget_unit1_percent {@rep:casecolumn
 * PQH_BUDGET_PERIODS.BUDGET_UNIT1_PERCENT}
 * @param p_budget_unit2_percent {@rep:casecolumn
 * PQH_BUDGET_PERIODS.BUDGET_UNIT2_PERCENT}
 * @param p_budget_unit3_percent {@rep:casecolumn
 * PQH_BUDGET_PERIODS.BUDGET_UNIT3_PERCENT}
 * @param p_budget_unit1_value {@rep:casecolumn
 * PQH_BUDGET_PERIODS.BUDGET_UNIT1_VALUE}
 * @param p_budget_unit2_value {@rep:casecolumn
 * PQH_BUDGET_PERIODS.BUDGET_UNIT2_VALUE}
 * @param p_budget_unit3_value {@rep:casecolumn
 * PQH_BUDGET_PERIODS.BUDGET_UNIT3_VALUE}
 * @param p_budget_unit1_value_type_cd Identifies the budget input value type.
 * Valid values are defined by 'PQH_BUDGET_UNIT_VALUE_TYPE' lookup type.
 * @param p_budget_unit2_value_type_cd Identifies the budget input value type.
 * Valid values are defined by 'PQH_BUDGET_UNIT_VALUE_TYPE' lookup type.
 * @param p_budget_unit3_value_type_cd Identifies the budget input value type.
 * Valid values are defined by 'PQH_BUDGET_UNIT_VALUE_TYPE' lookup type.
 * @param p_budget_unit1_available {@rep:casecolumn
 * PQH_BUDGET_PERIODS.BUDGET_UNIT1_AVAILABLE}
 * @param p_budget_unit2_available {@rep:casecolumn
 * PQH_BUDGET_PERIODS.BUDGET_UNIT2_AVAILABLE}
 * @param p_budget_unit3_available {@rep:casecolumn
 * PQH_BUDGET_PERIODS.BUDGET_UNIT3_AVAILABLE}
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created budget period. If p_validate is true, then the
 * value will be null.
 * @rep:displayname Create Budget Period
 * @rep:category BUSINESS_ENTITY HR_BUDGET
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_budget_period
(
   p_validate                       in boolean    default false
  ,p_budget_period_id               out nocopy number
  ,p_budget_detail_id               in  number    default null
  ,p_start_time_period_id           in  number    default null
  ,p_end_time_period_id             in  number    default null
  ,p_budget_unit1_percent           in  number    default null
  ,p_budget_unit2_percent           in  number    default null
  ,p_budget_unit3_percent           in  number    default null
  ,p_budget_unit1_value             in  number    default null
  ,p_budget_unit2_value             in  number    default null
  ,p_budget_unit3_value             in  number    default null
  ,p_budget_unit1_value_type_cd              in  varchar2  default null
  ,p_budget_unit2_value_type_cd              in  varchar2  default null
  ,p_budget_unit3_value_type_cd              in  varchar2  default null
  ,p_budget_unit1_available          in  number    default null
  ,p_budget_unit2_available          in  number    default null
  ,p_budget_unit3_available          in  number    default null
  ,p_object_version_number          out nocopy number
 );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_budget_period >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the period details for a budget.
 *
 * Period level values for a budget unit corresponding to a budget detail are
 * updated.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Budget period detail to be updated should already exist. Start time period
 * and end time period should be valid for the budget period detail to be
 * updated.
 *
 * <p><b>Post Success</b><br>
 * Budget period detail will be updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * Budget period detail will not be updated and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_budget_period_id Identifies the budget period.
 * @param p_budget_detail_id Budget detail identifier.
 * @param p_start_time_period_id Start date for the identifier.
 * @param p_end_time_period_id End date for the identifier.
 * @param p_budget_unit1_percent {@rep:casecolumn
 * PQH_BUDGET_PERIODS.BUDGET_UNIT1_PERCENT}
 * @param p_budget_unit2_percent {@rep:casecolumn
 * PQH_BUDGET_PERIODS.BUDGET_UNIT2_PERCENT}
 * @param p_budget_unit3_percent {@rep:casecolumn
 * PQH_BUDGET_PERIODS.BUDGET_UNIT3_PERCENT}
 * @param p_budget_unit1_value {@rep:casecolumn
 * PQH_BUDGET_PERIODS.BUDGET_UNIT1_VALUE}
 * @param p_budget_unit2_value {@rep:casecolumn
 * PQH_BUDGET_PERIODS.BUDGET_UNIT2_VALUE}
 * @param p_budget_unit3_value {@rep:casecolumn
 * PQH_BUDGET_PERIODS.BUDGET_UNIT3_VALUE}
 * @param p_budget_unit1_value_type_cd Identifies the budget input value type.
 * Valid values are defined by 'PQH_BUDGET_UNIT_VALUE_TYPE' lookup type.
 * @param p_budget_unit2_value_type_cd Identifies the budget input value type.
 * Valid values are defined by 'PQH_BUDGET_UNIT_VALUE_TYPE' lookup type.
 * @param p_budget_unit3_value_type_cd Identifies the budget input value type.
 * Valid values are defined by 'PQH_BUDGET_UNIT_VALUE_TYPE' lookup type.
 * @param p_budget_unit1_available {@rep:casecolumn
 * PQH_BUDGET_PERIODS.BUDGET_UNIT1_AVAILABLE}
 * @param p_budget_unit2_available {@rep:casecolumn
 * PQH_BUDGET_PERIODS.BUDGET_UNIT2_AVAILABLE}
 * @param p_budget_unit3_available {@rep:casecolumn
 * PQH_BUDGET_PERIODS.BUDGET_UNIT3_AVAILABLE}
 * @param p_object_version_number Pass in the current version number of the
 * budget period to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated budget period. If
 * p_validate is true will be set to the same value which was passed in.
 * @rep:displayname Update Budget Period
 * @rep:category BUSINESS_ENTITY HR_BUDGET
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_budget_period
  (
   p_validate                       in boolean    default false
  ,p_budget_period_id               in  number
  ,p_budget_detail_id               in  number    default hr_api.g_number
  ,p_start_time_period_id           in  number    default hr_api.g_number
  ,p_end_time_period_id             in  number    default hr_api.g_number
  ,p_budget_unit1_percent           in  number    default hr_api.g_number
  ,p_budget_unit2_percent           in  number    default hr_api.g_number
  ,p_budget_unit3_percent           in  number    default hr_api.g_number
  ,p_budget_unit1_value             in  number    default hr_api.g_number
  ,p_budget_unit2_value             in  number    default hr_api.g_number
  ,p_budget_unit3_value             in  number    default hr_api.g_number
  ,p_budget_unit1_value_type_cd              in  varchar2  default hr_api.g_varchar2
  ,p_budget_unit2_value_type_cd              in  varchar2  default hr_api.g_varchar2
  ,p_budget_unit3_value_type_cd              in  varchar2  default hr_api.g_varchar2
  ,p_budget_unit1_available          in  number    default hr_api.g_number
  ,p_budget_unit2_available          in  number    default hr_api.g_number
  ,p_budget_unit3_available          in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_budget_period >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes the period details for a budget.
 *
 * Period level values for a budget unit corresponding to a budget detail are
 * deleted.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Budget period details to be deleted should already exist.
 *
 * <p><b>Post Success</b><br>
 * Budget period detail will be deleted in the database.
 *
 * <p><b>Post Failure</b><br>
 * Budget period detail will not be deleted and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_budget_period_id This uniquely identifies the budget period.
 * @param p_object_version_number Current version number of the budget period
 * to be deleted.
 * @rep:displayname Delete Budget Period
 * @rep:category BUSINESS_ENTITY HR_BUDGET
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_budget_period
  (
   p_validate                       in boolean        default false
  ,p_budget_period_id               in  number
  ,p_object_version_number          in number
  );
--
end pqh_budget_periods_api;

 

/
