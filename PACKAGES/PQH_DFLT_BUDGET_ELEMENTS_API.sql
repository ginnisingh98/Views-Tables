--------------------------------------------------------
--  DDL for Package PQH_DFLT_BUDGET_ELEMENTS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DFLT_BUDGET_ELEMENTS_API" AUTHID CURRENT_USER as
/* $Header: pqdelapi.pkh 120.1 2005/10/02 02:26:38 aroussel $ */
/*#
 * This package contains APIs to create, update and delete the default budget
 * elements.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Default Budget Element
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_dflt_budget_element >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates the default budget elements.
 *
 * Budget elements for default budget set is created.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Default budget set should already exist.
 *
 * <p><b>Post Success</b><br>
 * Default budget element will be inserted in the database.
 *
 * <p><b>Post Failure</b><br>
 * Default budget element will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_dflt_budget_element_id If p_validate is false, then this uniquely
 * identifies the default budget element record created. If p_validate is true,
 * then set to null.
 * @param p_dflt_budget_set_id {@rep:casecolumn
 * PQH_DFLT_BUDGET_ELEMENTS.DFLT_BUDGET_SET_ID}
 * @param p_element_type_id {@rep:casecolumn
 * PQH_DFLT_BUDGET_ELEMENTS.ELEMENT_TYPE_ID}
 * @param p_dflt_dist_percentage {@rep:casecolumn
 * PQH_DFLT_BUDGET_ELEMENTS.DFLT_DIST_PERCENTAGE}
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created default budget element. If p_validate is true,
 * then the value will be null.
 * @rep:displayname Create Default Budget Element
 * @rep:category BUSINESS_ENTITY PQH_DEFAULT_HR_BUDGET_SET
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_dflt_budget_element
(
   p_validate                       in boolean    default false
  ,p_dflt_budget_element_id         out nocopy number
  ,p_dflt_budget_set_id             in  number    default null
  ,p_element_type_id                in  number    default null
  ,p_dflt_dist_percentage           in  number    default null
  ,p_object_version_number          out nocopy number
 );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_dflt_budget_element >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the default budget element.
 *
 * Budget element for a default budget set is updated.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The budget element to be updated should already exist. Default budget set
 * should already exist.
 *
 * <p><b>Post Success</b><br>
 * Default budget element will be updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * Default budget element will not be updated and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_dflt_budget_element_id Identifies the default budget element.
 * @param p_dflt_budget_set_id {@rep:casecolumn
 * PQH_DFLT_BUDGET_ELEMENTS.DFLT_BUDGET_SET_ID}
 * @param p_element_type_id {@rep:casecolumn
 * PQH_DFLT_BUDGET_ELEMENTS.ELEMENT_TYPE_ID}
 * @param p_dflt_dist_percentage {@rep:casecolumn
 * PQH_DFLT_BUDGET_ELEMENTS.DFLT_DIST_PERCENTAGE}
 * @param p_object_version_number Pass in the current version number of the
 * default budget element to be updated. When the API completes if p_validate
 * is false, will be set to the new version number of the updated default
 * budget element. If p_validate is true will be set to the same value which
 * was passed in.
 * @rep:displayname Update Default Budget Element
 * @rep:category BUSINESS_ENTITY PQH_DEFAULT_HR_BUDGET_SET
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_dflt_budget_element
  (
   p_validate                       in boolean    default false
  ,p_dflt_budget_element_id         in  number
  ,p_dflt_budget_set_id             in  number    default hr_api.g_number
  ,p_element_type_id                in  number    default hr_api.g_number
  ,p_dflt_dist_percentage           in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_dflt_budget_element >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes the default budget element.
 *
 * Budget element for a default budget set is deleted.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The budget element to be deleted should already exist.
 *
 * <p><b>Post Success</b><br>
 * Default budget element will be deleted from the database.
 *
 * <p><b>Post Failure</b><br>
 * Default budget element will not be deleted and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_dflt_budget_element_id This uniquely identifies the default budget
 * element.
 * @param p_object_version_number Current version number of the default budget
 * element to be deleted.
 * @rep:displayname Delete Default Budget Element
 * @rep:category BUSINESS_ENTITY PQH_DEFAULT_HR_BUDGET_SET
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_dflt_budget_element
  (
   p_validate                       in boolean        default false
  ,p_dflt_budget_element_id         in  number
  ,p_object_version_number          in number
  );
--
end pqh_dflt_budget_elements_api;

 

/
