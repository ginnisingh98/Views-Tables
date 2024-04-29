--------------------------------------------------------
--  DDL for Package PQH_BUDGET_FUND_SRCS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_BUDGET_FUND_SRCS_API" AUTHID CURRENT_USER as
/* $Header: pqbfsapi.pkh 120.1 2005/10/02 02:25:46 aroussel $ */
/*#
 * This package contains APIs to create, update and delete the Budget Costing
 * Information.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Budget Fund Source
*/
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_budget_fund_src >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates the budget funding source.
 *
 * Budget Cost allocation information is created or PTEAO information is
 * created.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Budget element should already exist. Cost allocation key flexfield or PTEAO
 * information should already exist.
 *
 * <p><b>Post Success</b><br>
 * Budget funding source for an element will be created in the database.
 *
 * <p><b>Post Failure</b><br>
 * Budget funding source for an element will not be created and an error will
 * be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_budget_fund_src_id If p_validate is false, then this uniquely
 * identifies the budget source fund created. If p_validate is true, then set
 * to null.
 * @param p_budget_element_id {@rep:casecolumn
 * PQH_BUDGET_FUND_SRCS.BUDGET_ELEMENT_ID}
 * @param p_cost_allocation_keyflex_id {@rep:casecolumn
 * PQH_BUDGET_FUND_SRCS.COST_ALLOCATION_KEYFLEX_ID}
 * @param p_project_id {@rep:casecolumn PQH_BUDGET_FUND_SRCS.PROJECT_ID}
 * @param p_award_id {@rep:casecolumn PQH_BUDGET_FUND_SRCS.AWARD_ID}
 * @param p_task_id {@rep:casecolumn PQH_BUDGET_FUND_SRCS.TASK_ID}
 * @param p_expenditure_type {@rep:casecolumn
 * PQH_BUDGET_FUND_SRCS.EXPENDITURE_TYPE}
 * @param p_organization_id {@rep:casecolumn
 * PQH_BUDGET_FUND_SRCS.ORGANIZATION_ID}
 * @param p_distribution_percentage Percentage of budget element value given
 * for funding source.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created budget source fund. If p_validate is true,
 * then the value will be null.
 * @rep:displayname Create Budget Fund Source
 * @rep:category BUSINESS_ENTITY HR_BUDGET
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_budget_fund_src
(
   p_validate                       in boolean    default false
  ,p_budget_fund_src_id             out nocopy number
  ,p_budget_element_id              in  number    default null
  ,p_cost_allocation_keyflex_id     in  number    default null
  ,p_project_id                     in  number    default null
  ,p_award_id                       in  number    default null
  ,p_task_id                        in  number    default null
  ,p_expenditure_type               in  varchar2  default null
  ,p_organization_id                in  number    default null
  ,p_distribution_percentage        in  number    default null
  ,p_object_version_number          out nocopy number
 );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_budget_fund_src >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the budget funding source.
 *
 * Budget cost allocation information is updated or PTEAO information is
 * updated.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Budget funding source to be updated should exist.
 *
 * <p><b>Post Success</b><br>
 * Budget funding source for a element will be updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * Budget funding source for a element will not be updated and an error will be
 * raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_budget_fund_src_id Identifies the budget fund source to be updated.
 * @param p_budget_element_id {@rep:casecolumn
 * PQH_BUDGET_FUND_SRCS.BUDGET_ELEMENT_ID}
 * @param p_cost_allocation_keyflex_id {@rep:casecolumn
 * PQH_BUDGET_FUND_SRCS.COST_ALLOCATION_KEYFLEX_ID}
 * @param p_project_id {@rep:casecolumn PQH_BUDGET_FUND_SRCS.PROJECT_ID}
 * @param p_award_id {@rep:casecolumn PQH_BUDGET_FUND_SRCS.AWARD_ID}
 * @param p_task_id {@rep:casecolumn PQH_BUDGET_FUND_SRCS.TASK_ID}
 * @param p_expenditure_type {@rep:casecolumn
 * PQH_BUDGET_FUND_SRCS.EXPENDITURE_TYPE}
 * @param p_organization_id {@rep:casecolumn
 * PQH_BUDGET_FUND_SRCS.ORGANIZATION_ID}
 * @param p_distribution_percentage Percentage of budget element value given
 * for funding source.
 * @param p_object_version_number Pass in the current version number of the
 * budget funding source to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated budget funding
 * source. If p_validate is true will be set to the same value which was passed
 * in.
 * @rep:displayname Update Budget Fund Source
 * @rep:category BUSINESS_ENTITY HR_BUDGET
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_budget_fund_src
  (
   p_validate                       in boolean    default false
  ,p_budget_fund_src_id             in  number
  ,p_budget_element_id              in  number    default hr_api.g_number
  ,p_cost_allocation_keyflex_id     in  number    default hr_api.g_number
  ,p_project_id                     in  number    default hr_api.g_number
  ,p_award_id                       in  number    default hr_api.g_number
  ,p_task_id                        in  number    default hr_api.g_number
  ,p_expenditure_type               in  varchar2  default hr_api.g_varchar2
  ,p_organization_id                in  number    default hr_api.g_number
  ,p_distribution_percentage        in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_budget_fund_src >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes the budget funding source.
 *
 * Budget cost allocation information is deleted or PTEAO information is
 * deleted.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Budget funding source to be deleted should exist.
 *
 * <p><b>Post Success</b><br>
 * Budget funding source for a element will be deleted in the database.
 *
 * <p><b>Post Failure</b><br>
 * Budget funding source for a element will not be deleted and an error will be
 * raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_budget_fund_src_id This uniquely identifies the budget funding
 * source
 * @param p_object_version_number Current version number of the budget funding
 * source to be deleted.
 * @rep:displayname Delete Budget Fund Source
 * @rep:category BUSINESS_ENTITY HR_BUDGET
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_budget_fund_src
  (
   p_validate                       in boolean        default false
  ,p_budget_fund_src_id             in  number
  ,p_object_version_number          in  number
  );
--
end pqh_budget_fund_srcs_api;

 

/
