--------------------------------------------------------
--  DDL for Package PQH_DFLT_FUND_SRCS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DFLT_FUND_SRCS_API" AUTHID CURRENT_USER as
/* $Header: pqdfsapi.pkh 120.1 2005/10/02 02:26:43 aroussel $ */
/*#
 * This package contains APIs to create, update and delete the default funding
 * source.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Default Funding Source
*/
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_dflt_fund_src >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a default funding source.
 *
 * Cost allocation information for budget elements is created.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Default budget element should already exist. Cost allocation flex or PTEAO
 * information should already exist.
 *
 * <p><b>Post Success</b><br>
 * Default funding source will be inserted in the database.
 *
 * <p><b>Post Failure</b><br>
 * Default funding source will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_dflt_fund_src_id If p_validate is false, then this uniquely
 * identifies the default funding source created. If p_validate is true, then
 * set to null.
 * @param p_dflt_budget_element_id {@rep:casecolumn
 * PQH_DFLT_FUND_SRCS.DFLT_BUDGET_ELEMENT_ID}
 * @param p_dflt_dist_percentage {@rep:casecolumn
 * PQH_DFLT_FUND_SRCS.DFLT_DIST_PERCENTAGE}
 * @param p_project_id {@rep:casecolumn PQH_DFLT_FUND_SRCS.PROJECT_ID}
 * @param p_award_id {@rep:casecolumn PQH_DFLT_FUND_SRCS.AWARD_ID}
 * @param p_task_id {@rep:casecolumn PQH_DFLT_FUND_SRCS.TASK_ID}
 * @param p_expenditure_type {@rep:casecolumn
 * PQH_DFLT_FUND_SRCS.EXPENDITURE_TYPE}
 * @param p_organization_id {@rep:casecolumn
 * PQH_DFLT_FUND_SRCS.ORGANIZATION_ID}
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created default funding source. If p_validate is true,
 * then the value will be null.
 * @param p_cost_allocation_keyflex_id Cost allocation keyflex field
 * identifier.
 * @rep:displayname Create Default Funding Source
 * @rep:category BUSINESS_ENTITY PQH_DEFAULT_HR_BUDGET_SET
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_dflt_fund_src
(
   p_validate                       in boolean    default false
  ,p_dflt_fund_src_id               out nocopy number
  ,p_dflt_budget_element_id         in  number    default null
  ,p_dflt_dist_percentage           in  number    default null
  ,p_project_id                     in  number    default null
  ,p_award_id                       in  number    default null
  ,p_task_id                        in  number    default null
  ,p_expenditure_type               in  varchar2  default null
  ,p_organization_id                in  number    default null
  ,p_object_version_number          out nocopy number
  ,p_cost_allocation_keyflex_id     in  number    default null
 );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_dflt_fund_src >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the default funding source.
 *
 * Cost allocation information for budget elements is updated.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The default funding source to be updated should already exist.
 *
 * <p><b>Post Success</b><br>
 * Default funding source will be updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * Default funding Source will not be updated and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_dflt_fund_src_id Identifies the default funding source.
 * @param p_dflt_budget_element_id {@rep:casecolumn
 * PQH_DFLT_FUND_SRCS.DFLT_BUDGET_ELEMENT_ID}
 * @param p_dflt_dist_percentage {@rep:casecolumn
 * PQH_DFLT_FUND_SRCS.DFLT_DIST_PERCENTAGE}
 * @param p_project_id {@rep:casecolumn PQH_DFLT_FUND_SRCS.PROJECT_ID}
 * @param p_award_id {@rep:casecolumn PQH_DFLT_FUND_SRCS.AWARD_ID}
 * @param p_task_id {@rep:casecolumn PQH_DFLT_FUND_SRCS.TASK_ID}
 * @param p_expenditure_type {@rep:casecolumn
 * PQH_DFLT_FUND_SRCS.EXPENDITURE_TYPE}
 * @param p_organization_id {@rep:casecolumn
 * PQH_DFLT_FUND_SRCS.ORGANIZATION_ID}
 * @param p_object_version_number Pass in the current version number of the
 * default funding source to be updated. When the API completes if p_validate
 * is false, will be set to the new version number of the updated default
 * funding source. If p_validate is true will be set to the same value which
 * was passed in.
 * @param p_cost_allocation_keyflex_id Cost allocation keyflex field
 * identifier.
 * @rep:displayname Update Default Funding Source
 * @rep:category BUSINESS_ENTITY PQH_DEFAULT_HR_BUDGET_SET
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_dflt_fund_src
  (
   p_validate                       in boolean    default false
  ,p_dflt_fund_src_id               in  number
  ,p_dflt_budget_element_id         in  number    default hr_api.g_number
  ,p_dflt_dist_percentage           in  number    default hr_api.g_number
  ,p_project_id                     in  number    default hr_api.g_number
  ,p_award_id                       in  number    default hr_api.g_number
  ,p_task_id                        in  number    default hr_api.g_number
  ,p_expenditure_type               in  varchar2  default hr_api.g_varchar2
  ,p_organization_id                in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_cost_allocation_keyflex_id     in  number    default hr_api.g_number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_dflt_fund_src >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes the default funding source.
 *
 * Cost allocation information for budget elements is deleted.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The default funding source to be deleted should already exist.
 *
 * <p><b>Post Success</b><br>
 * Default funding source will be deleted from the database.
 *
 * <p><b>Post Failure</b><br>
 * Default funding source will not be deleted and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_dflt_fund_src_id This uniquely identifies the default funding
 * source.
 * @param p_object_version_number Current version number of the default funding
 * source to be deleted.
 * @rep:displayname Delete Default Funding Source
 * @rep:category BUSINESS_ENTITY PQH_DEFAULT_HR_BUDGET_SET
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_dflt_fund_src
  (
   p_validate                       in boolean        default false
  ,p_dflt_fund_src_id               in  number
  ,p_object_version_number          in number
  );
--
--
end pqh_dflt_fund_srcs_api;

 

/
