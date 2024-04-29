--------------------------------------------------------
--  DDL for Package PQH_BUDGET_ELEMENTS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_BUDGET_ELEMENTS_API" AUTHID CURRENT_USER as
/* $Header: pqbelapi.pkh 120.1 2005/10/02 02:25:41 aroussel $ */
/*#
 * This package contains APIs to create, update and delete the elements
 * associated with a budget set.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Budget Element
*/
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_budget_element >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a budget element.
 *
 * Elements and the distribution of elements for a budget set is inserted.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Budget set identifier should already exist.
 *
 * <p><b>Post Success</b><br>
 * Element for a budget set will be successfully inserted in the database.
 *
 * <p><b>Post Failure</b><br>
 * Element for a budget set will not be inserted and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_budget_element_id If p_validate is false, then this uniquely
 * identifies the budget element record created. If p_validate is true, then
 * set to null.
 * @param p_budget_set_id Budget set identifier.
 * @param p_element_type_id Element type identifier.
 * @param p_distribution_percentage Percentage of budget set for given element.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created budget element. If p_validate is true, then
 * the value will be null.
 * @rep:displayname Create Budget Element
 * @rep:category BUSINESS_ENTITY HR_BUDGET
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_budget_element
(
   p_validate                       in boolean    default false
  ,p_budget_element_id              out nocopy number
  ,p_budget_set_id                  in  number    default null
  ,p_element_type_id                in  number    default null
  ,p_distribution_percentage        in  number    default null
  ,p_object_version_number          out nocopy number
 );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_budget_element >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a budget element.
 *
 * The element itself or the distribution of elements for a budget set is
 * updated.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Budget element to be updated for a budget set should already exist.
 *
 * <p><b>Post Success</b><br>
 * Element for a budget set will be updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * Element for a budget set will not be updated and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_budget_element_id Identifies the budget element record updated.
 * @param p_budget_set_id Budget set identifier.
 * @param p_element_type_id Element type identifier.
 * @param p_distribution_percentage Percentage of budget set for given element.
 * @param p_object_version_number Pass in the current version number of the
 * budget element record to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated budget element.
 * If p_validate is true will be set to the same value which was passed in.
 * @rep:displayname Update Budget Element
 * @rep:category BUSINESS_ENTITY HR_BUDGET
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_budget_element
  (
   p_validate                       in boolean    default false
  ,p_budget_element_id              in  number
  ,p_budget_set_id                  in  number    default hr_api.g_number
  ,p_element_type_id                in  number    default hr_api.g_number
  ,p_distribution_percentage        in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_budget_element >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a budget element.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Budget element to be deleted for a budget set should exist.
 *
 * <p><b>Post Success</b><br>
 * Element for a budget set will be deleted in the database.
 *
 * <p><b>Post Failure</b><br>
 * Element for a budget set will not be deleted and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_budget_element_id This uniquely identifies the budget element.
 * @param p_object_version_number Current version number of the budget element
 * to be deleted.
 * @rep:displayname Delete Budget Element
 * @rep:category BUSINESS_ENTITY HR_BUDGET
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_budget_element
  (
   p_validate                       in boolean        default false
  ,p_budget_element_id              in  number
  ,p_object_version_number          in number
  );
--
end pqh_budget_elements_api;

 

/
