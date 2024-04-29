--------------------------------------------------------
--  DDL for Package PQH_BUDGET_SETS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_BUDGET_SETS_API" AUTHID CURRENT_USER as
/* $Header: pqbstapi.pkh 120.1 2005/10/02 02:26:16 aroussel $ */
/*#
 * This package contains APIs to create, update and delete the budget sets for
 * a budget period.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Budget Set
*/
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_budget_set >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates budget element sets with default distribution.
 *
 * Default budget set values will be pulled in for a budget period.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Budget period should exist in order to create a budget set.
 *
 * <p><b>Post Success</b><br>
 * Budget set will be inserted in the database.
 *
 * <p><b>Post Failure</b><br>
 * Budget set will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_budget_set_id If p_validate is false, then this uniquely identifies
 * the budget set record created. If p_validate is true, then set to null.
 * @param p_dflt_budget_set_id {@rep:casecolumn
 * PQH_BUDGET_SETS.DFLT_BUDGET_SET_ID}
 * @param p_budget_period_id Budget period identifier.
 * @param p_budget_unit1_percent {@rep:casecolumn
 * PQH_BUDGET_SETS.BUDGET_UNIT1_PERCENT}
 * @param p_budget_unit2_percent {@rep:casecolumn
 * PQH_BUDGET_SETS.BUDGET_UNIT2_PERCENT}
 * @param p_budget_unit3_percent {@rep:casecolumn
 * PQH_BUDGET_SETS.BUDGET_UNIT3_PERCENT}
 * @param p_budget_unit1_value {@rep:casecolumn
 * PQH_BUDGET_SETS.BUDGET_UNIT1_VALUE}
 * @param p_budget_unit2_value {@rep:casecolumn
 * PQH_BUDGET_SETS.BUDGET_UNIT2_VALUE}
 * @param p_budget_unit3_value {@rep:casecolumn
 * PQH_BUDGET_SETS.BUDGET_UNIT3_VALUE}
 * @param p_budget_unit1_available {@rep:casecolumn
 * PQH_BUDGET_SETS.BUDGET_UNIT1_AVAILABLE}
 * @param p_budget_unit2_available {@rep:casecolumn
 * PQH_BUDGET_SETS.BUDGET_UNIT2_AVAILABLE}
 * @param p_budget_unit3_available {@rep:casecolumn
 * PQH_BUDGET_SETS.BUDGET_UNIT3_AVAILABLE}
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created budget set. If p_validate is true, then the
 * value will be null.
 * @param p_budget_unit1_value_type_cd Identifies the budget input value type.
 * Valid values are defined by 'PQH_BUDGET_UNIT_VALUE_TYPE' lookup type.
 * @param p_budget_unit2_value_type_cd Identifies the budget input value type.
 * Valid values are defined by 'PQH_BUDGET_UNIT_VALUE_TYPE' lookup type.
 * @param p_budget_unit3_value_type_cd Identifies the budget input value type.
 * Valid values are defined by 'PQH_BUDGET_UNIT_VALUE_TYPE' lookup type.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @rep:displayname Create Budget Set
 * @rep:category BUSINESS_ENTITY HR_BUDGET
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_budget_set
(
   p_validate                       in boolean    default false
  ,p_budget_set_id                  out nocopy number
  ,p_dflt_budget_set_id             in  number    default null
  ,p_budget_period_id               in  number    default null
  ,p_budget_unit1_percent           in  number    default null
  ,p_budget_unit2_percent           in  number    default null
  ,p_budget_unit3_percent           in  number    default null
  ,p_budget_unit1_value             in  number    default null
  ,p_budget_unit2_value             in  number    default null
  ,p_budget_unit3_value             in  number    default null
  ,p_budget_unit1_available          in  number    default null
  ,p_budget_unit2_available          in  number    default null
  ,p_budget_unit3_available          in  number    default null
  ,p_object_version_number          out nocopy number
  ,p_budget_unit1_value_type_cd     in  varchar2  default null
  ,p_budget_unit2_value_type_cd     in  varchar2  default null
  ,p_budget_unit3_value_type_cd     in  varchar2  default null
  ,p_effective_date            in  date
 );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_budget_set >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates budget sets with default distribution.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Budget set to be updated should already exist. Budget period should already
 * exist.
 *
 * <p><b>Post Success</b><br>
 * Budget set will be updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * Budget set will not be updated and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_budget_set_id Identifies the budget set to be updated.
 * @param p_dflt_budget_set_id {@rep:casecolumn
 * PQH_BUDGET_SETS.DFLT_BUDGET_SET_ID}
 * @param p_budget_period_id Budget period identifier.
 * @param p_budget_unit1_percent {@rep:casecolumn
 * PQH_BUDGET_SETS.BUDGET_UNIT1_PERCENT}
 * @param p_budget_unit2_percent {@rep:casecolumn
 * PQH_BUDGET_SETS.BUDGET_UNIT2_PERCENT}
 * @param p_budget_unit3_percent {@rep:casecolumn
 * PQH_BUDGET_SETS.BUDGET_UNIT3_PERCENT}
 * @param p_budget_unit1_value {@rep:casecolumn
 * PQH_BUDGET_SETS.BUDGET_UNIT1_VALUE}
 * @param p_budget_unit2_value {@rep:casecolumn
 * PQH_BUDGET_SETS.BUDGET_UNIT2_VALUE}
 * @param p_budget_unit3_value {@rep:casecolumn
 * PQH_BUDGET_SETS.BUDGET_UNIT3_VALUE}
 * @param p_budget_unit1_available {@rep:casecolumn
 * PQH_BUDGET_SETS.BUDGET_UNIT1_AVAILABLE}
 * @param p_budget_unit2_available {@rep:casecolumn
 * PQH_BUDGET_SETS.BUDGET_UNIT2_AVAILABLE}
 * @param p_budget_unit3_available {@rep:casecolumn
 * PQH_BUDGET_SETS.BUDGET_UNIT3_AVAILABLE}
 * @param p_object_version_number Pass in the current version number of the
 * budget set to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated budget set. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_budget_unit1_value_type_cd Identifies the budget input value type.
 * Valid values are defined by 'PQH_BUDGET_UNIT_VALUE_TYPE' lookup type.
 * @param p_budget_unit2_value_type_cd Identifies the budget input value type.
 * Valid values are defined by 'PQH_BUDGET_UNIT_VALUE_TYPE' lookup type.
 * @param p_budget_unit3_value_type_cd Identifies the budget input value type.
 * Valid values are defined by 'PQH_BUDGET_UNIT_VALUE_TYPE' lookup type.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @rep:displayname Update Budget Set
 * @rep:category BUSINESS_ENTITY HR_BUDGET
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_budget_set
  (
   p_validate                       in boolean    default false
  ,p_budget_set_id                  in  number
  ,p_dflt_budget_set_id             in  number    default hr_api.g_number
  ,p_budget_period_id               in  number    default hr_api.g_number
  ,p_budget_unit1_percent           in  number    default hr_api.g_number
  ,p_budget_unit2_percent           in  number    default hr_api.g_number
  ,p_budget_unit3_percent           in  number    default hr_api.g_number
  ,p_budget_unit1_value             in  number    default hr_api.g_number
  ,p_budget_unit2_value             in  number    default hr_api.g_number
  ,p_budget_unit3_value             in  number    default hr_api.g_number
  ,p_budget_unit1_available          in  number    default hr_api.g_number
  ,p_budget_unit2_available          in  number    default hr_api.g_number
  ,p_budget_unit3_available          in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_budget_unit1_value_type_cd     in  varchar2  default hr_api.g_varchar2
  ,p_budget_unit2_value_type_cd     in  varchar2  default hr_api.g_varchar2
  ,p_budget_unit3_value_type_cd     in  varchar2  default hr_api.g_varchar2
  ,p_effective_date            in  date
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_budget_set >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a budget set.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Budget set to be deleted should already exist.
 *
 * <p><b>Post Success</b><br>
 * Budget set will be deleted from the database.
 *
 * <p><b>Post Failure</b><br>
 * Budget set will not be deleted and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_budget_set_id This uniquely identifies the budget set.
 * @param p_object_version_number Current version number of the budget set to
 * be deleted.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @rep:displayname Delete Budget Set
 * @rep:category BUSINESS_ENTITY HR_BUDGET
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_budget_set
  (
   p_validate                       in boolean        default false
  ,p_budget_set_id                  in  number
  ,p_object_version_number          in  number
  ,p_effective_date            in date
  );
--
end pqh_budget_sets_api;

 

/
