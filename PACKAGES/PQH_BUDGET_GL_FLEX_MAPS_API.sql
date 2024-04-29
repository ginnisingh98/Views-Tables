--------------------------------------------------------
--  DDL for Package PQH_BUDGET_GL_FLEX_MAPS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_BUDGET_GL_FLEX_MAPS_API" AUTHID CURRENT_USER as
/* $Header: pqbgmapi.pkh 120.2 2006/06/05 19:10:33 nsanghal noship $ */
/*#
 * This package contains APIs to create, update or delete cost allocations with
 * GL code combinations.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Budget General Ledger Flexfield Mapping
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_budget_gl_flex_map >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates mapping of cost allocations with GL code combinations.
 *
 * When GL mapping is enabled, this API allows the mapping of HR's cost
 * allocations with GL's Ledger.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Budget should exist and transfer to GL should be enabled. Cost allocation
 * should exist. Ledger should exist.
 *
 * <p><b>Post Success</b><br>
 * Budget GL flexfield mapping for a budget will be inserted in the database.
 *
 * <p><b>Post Failure</b><br>
 * Budget GL flexfield mapping will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_budget_gl_flex_map_id If p_validate is false, then this uniquely
 * identifies the budget GL Flex Map created. If p_validate is true, then set
 * to null.
 * @param p_budget_id Budget identifier.
 * @param p_gl_account_segment GL account combination segment.
 * @param p_payroll_cost_segment Payroll cost allocation segment.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created budget GL Flex Map. If p_validate is true,
 * then the value will be null.
 * @rep:displayname Create Budget General Ledger Flexfield Mapping
 * @rep:category BUSINESS_ENTITY HR_BUDGET
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_budget_gl_flex_map
(
   p_validate                       in boolean    default false
  ,p_budget_gl_flex_map_id          out nocopy number
  ,p_budget_id                      in  number    default null
  ,p_gl_account_segment             in  varchar2  default null
  ,p_payroll_cost_segment           in  varchar2  default null
  ,p_object_version_number          out nocopy number
 );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_budget_gl_flex_map >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates cost allocations mapped with GL code combinations.
 *
 * When GL mapping is enabled, this API updates the mapping of HR's cost
 * allocations with GL's Ledger.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The GL flexfield mapping to be updated should exist. Budget should exist and
 * transfer to GL should be enabled. Cost allocation should exist. Ledger
 * should exist.
 *
 * <p><b>Post Success</b><br>
 * Budget GL flexfield mapping for a budget will be updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * Budget GL flexfield mapping will not be updated and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_budget_gl_flex_map_id Identifies the budget GL flexfield mapping.
 * @param p_budget_id Budget identifier.
 * @param p_gl_account_segment GL account combination segment.
 * @param p_payroll_cost_segment Cost allocation.
 * @param p_object_version_number Pass in the current version number of the
 * budget GL Flex Maps to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated budget GL Flex
 * Map. If p_validate is true will be set to the same value which was passed
 * in.
 * @rep:displayname Update Budget General Ledger Flexfield Mapping
 * @rep:category BUSINESS_ENTITY HR_BUDGET
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_budget_gl_flex_map
  (
   p_validate                       in boolean    default false
  ,p_budget_gl_flex_map_id          in  number
  ,p_budget_id                      in  number    default hr_api.g_number
  ,p_gl_account_segment             in  varchar2  default hr_api.g_varchar2
  ,p_payroll_cost_segment           in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_budget_gl_flex_map >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes cost allocations mapped with GL code combinations.
 *
 * When GL mapping is enabled, this API deletes the mapping of HR's cost
 * allocations with GL's Ledger.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The GL flexfield mapping to be deleted should exist.
 *
 * <p><b>Post Success</b><br>
 * Budget GL flexfield mapping for a budget will be deleted in the database.
 *
 * <p><b>Post Failure</b><br>
 * Budget GL flexfield mapping will not be deleted and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_budget_gl_flex_map_id This uniquely identifies the budget GL
 * flexfield mapping.
 * @param p_object_version_number Current version number of the budget GL
 * flexfield mapping to be deleted.
 * @rep:displayname Delete Budget General Ledger Flexfield Mapping
 * @rep:category BUSINESS_ENTITY HR_BUDGET
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_budget_gl_flex_map
  (
   p_validate                       in boolean        default false
  ,p_budget_gl_flex_map_id          in  number
  ,p_object_version_number          in number
  );
--
end pqh_budget_gl_flex_maps_api;

 

/
