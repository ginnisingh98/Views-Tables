--------------------------------------------------------
--  DDL for Package PQH_DFLT_BUDGET_SETS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DFLT_BUDGET_SETS_API" AUTHID CURRENT_USER as
/* $Header: pqdstapi.pkh 120.1 2005/10/02 02:26:48 aroussel $ */
/*#
 * This package contains APIs to create, update and delete a default budget
 * set.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Default Budget Set
*/
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_dflt_budget_set >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a default budget set.
 *
 * Elements and funding sources are grouped under a set.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The business group in which the default budget set is created should already
 * exist.
 *
 * <p><b>Post Success</b><br>
 * Default budget set will be inserted in the database.
 *
 * <p><b>Post Failure</b><br>
 * Default budget set will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_dflt_budget_set_id If p_validate is false, then this uniquely
 * identifies the default budget set created. If p_validate is true, then set
 * to null.
 * @param p_dflt_budget_set_name Default budget set name.
 * @param p_business_group_id Business group identifier.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created default budget set. If p_validate is true,
 * then the value will be null.
 * @rep:displayname Create Default Budget Set
 * @rep:category BUSINESS_ENTITY PQH_DEFAULT_HR_BUDGET_SET
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_dflt_budget_set
(
   p_validate                       in boolean    default false
  ,p_dflt_budget_set_id             out nocopy number
  ,p_dflt_budget_set_name           in  varchar2  default null
  ,p_business_group_id              in  number    default null
  ,p_object_version_number          out nocopy number
 );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_dflt_budget_set >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a default budget set.
 *
 * Elements and funding sources grouped under a set are updated.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Default budget set to be updated should already exist. Business group should
 * already exist.
 *
 * <p><b>Post Success</b><br>
 * Default budget set will be updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * Default budget set will not be updated and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_dflt_budget_set_id Identifies the default budget set.
 * @param p_dflt_budget_set_name Default budget set name.
 * @param p_business_group_id Business group identifier.
 * @param p_object_version_number Pass in the current version number of the
 * default budget set to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated default budget
 * set. If p_validate is true will be set to the same value which was passed
 * in.
 * @rep:displayname Update Default Budget Set
 * @rep:category BUSINESS_ENTITY PQH_DEFAULT_HR_BUDGET_SET
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_dflt_budget_set
  (
   p_validate                       in boolean    default false
  ,p_dflt_budget_set_id             in  number
  ,p_dflt_budget_set_name           in  varchar2  default hr_api.g_varchar2
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_dflt_budget_set >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes the default budget set.
 *
 * Elements and funding souces under a budget set are deleted.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Default budget set to be deleted should already exist.
 *
 * <p><b>Post Success</b><br>
 * Default budget set will be deleted from the database.
 *
 * <p><b>Post Failure</b><br>
 * Default budget set will not be deleted and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_dflt_budget_set_id This uniquely identifies the default budget set.
 * @param p_object_version_number Current version number of the default budget
 * set to be deleted.
 * @rep:displayname Delete Default Budget Set
 * @rep:category BUSINESS_ENTITY PQH_DEFAULT_HR_BUDGET_SET
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_dflt_budget_set
  (
   p_validate                       in boolean        default false
  ,p_dflt_budget_set_id             in  number
  ,p_object_version_number          in  number
  );
--
end pqh_dflt_budget_sets_api;

 

/
