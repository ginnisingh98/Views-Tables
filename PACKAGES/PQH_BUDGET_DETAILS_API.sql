--------------------------------------------------------
--  DDL for Package PQH_BUDGET_DETAILS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_BUDGET_DETAILS_API" AUTHID CURRENT_USER as
/* $Header: pqbdtapi.pkh 120.1 2005/10/02 02:25:37 aroussel $ */
/*#
 * This package contains APIs to create, update and delete the budget details.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Budget Detail
*/
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_budget_detail >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates budget details.
 *
 * Enter a value for a budgeted entity like position, job, grade or
 * organization, or calculate the value of a line item as a percentage of the
 * total amount allocated for the budget measurement unit. The application
 * supports the entry of currency values of any length with variable decimal
 * point placement.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid budget version should already exist. The entities (organization,
 * position, job or grade) for which the budget values are to be entered should
 * already exist.
 *
 * <p><b>Post Success</b><br>
 * Budget detail will be successfully created in the database.
 *
 * <p><b>Post Failure</b><br>
 * Budget detail will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_budget_detail_id If p_validate is false, then this uniquely
 * identifies the budget detail record created. If p_validate is true, then set
 * to null.
 * @param p_organization_id Identifies budgeted organization.
 * @param p_job_id Identifies budgeted job.
 * @param p_position_id Identifies budgeted position.
 * @param p_grade_id Identifies budgeted grade.
 * @param p_budget_version_id Identifies budget version.
 * @param p_budget_unit1_percent Budget unit 1 percentage.
 * @param p_budget_unit1_value_type_cd Identifies the budget input value type.
 * Valid values are defined by 'PQH_BUDGET_UNIT_VALUE_TYPE' lookup type.
 * @param p_budget_unit1_value Budget unit 1 value.
 * @param p_budget_unit1_available {@rep:casecolumn
 * PQH_BUDGET_DETAILS.BUDGET_UNIT1_AVAILABLE}
 * @param p_budget_unit2_percent Budget unit 2 percentage.
 * @param p_budget_unit2_value_type_cd Identifies the budget input value type.
 * Valid values are defined by 'PQH_BUDGET_UNIT_VALUE_TYPE' lookup type.
 * @param p_budget_unit2_value Budget unit 2 value.
 * @param p_budget_unit2_available {@rep:casecolumn
 * PQH_BUDGET_DETAILS.BUDGET_UNIT2_AVAILABLE}
 * @param p_budget_unit3_percent Budget unit 3 percentage.
 * @param p_budget_unit3_value_type_cd Identifies the budget input value type.
 * Valid values are defined by 'PQH_BUDGET_UNIT_VALUE_TYPE' lookup type.
 * @param p_budget_unit3_value Budget unit 3 value.
 * @param p_budget_unit3_available {@rep:casecolumn
 * PQH_BUDGET_DETAILS.BUDGET_UNIT3_AVAILABLE}
 * @param p_gl_status Posting to GL status. Possible values are Post, Error or
 * Null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created budget element. If p_validate is true, then
 * the value will be null.
 * @rep:displayname Create Budget Detail
 * @rep:category BUSINESS_ENTITY HR_BUDGET
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_budget_detail
(
   p_validate                       in boolean    default false
  ,p_budget_detail_id               out nocopy number
  ,p_organization_id                in  number    default null
  ,p_job_id                         in  number    default null
  ,p_position_id                    in  number    default null
  ,p_grade_id                       in  number    default null
  ,p_budget_version_id              in  number    default null
  ,p_budget_unit1_percent           in  number    default null
  ,p_budget_unit1_value_type_cd              in  varchar2  default null
  ,p_budget_unit1_value             in  number    default null
  ,p_budget_unit1_available          in  number    default null
  ,p_budget_unit2_percent           in  number    default null
  ,p_budget_unit2_value_type_cd              in  varchar2  default null
  ,p_budget_unit2_value             in  number    default null
  ,p_budget_unit2_available          in  number    default null
  ,p_budget_unit3_percent           in  number    default null
  ,p_budget_unit3_value_type_cd              in  varchar2  default null
  ,p_budget_unit3_value             in  number    default null
  ,p_budget_unit3_available          in  number    default null
  ,p_gl_status                               in  varchar2  default null
  ,p_object_version_number          out nocopy number
 );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_budget_detail >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates budget details.
 *
 * Update a value or percentage for a entity like position, job, grade or
 * organization, or update the entity itself.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Budget detail record to be updated should already exist. The entities
 * (organization, position, job or grade) should be valid.
 *
 * <p><b>Post Success</b><br>
 * Budget detail will be successfully updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * Budget detail will not be updated and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_budget_detail_id Identifies the budget detail record updated.
 * @param p_organization_id Identifies budgeted organization.
 * @param p_job_id Identifies budgeted job.
 * @param p_position_id Identifies budgeted position.
 * @param p_grade_id Identifies budgeted grade.
 * @param p_budget_version_id Identifies budget version.
 * @param p_budget_unit1_percent Budget unit 1 percentage.
 * @param p_budget_unit1_value_type_cd Identifies the budget input value type.
 * Valid values are defined by 'PQH_BUDGET_UNIT_VALUE_TYPE' lookup type.
 * @param p_budget_unit1_value Budget unit 1 value.
 * @param p_budget_unit1_available {@rep:casecolumn
 * PQH_BUDGET_DETAILS.BUDGET_UNIT1_AVAILABLE}
 * @param p_budget_unit2_percent Budget unit 2 percentage.
 * @param p_budget_unit2_value_type_cd Identifies the budget input value type.
 * Valid values are defined by 'PQH_BUDGET_UNIT_VALUE_TYPE' lookup type.
 * @param p_budget_unit2_value Budget unit 2 value.
 * @param p_budget_unit2_available {@rep:casecolumn
 * PQH_BUDGET_DETAILS.BUDGET_UNIT2_AVAILABLE}
 * @param p_budget_unit3_percent Budget unit 3 percentage.
 * @param p_budget_unit3_value_type_cd Identifies the budget input value type.
 * Valid values are defined by 'PQH_BUDGET_UNIT_VALUE_TYPE' lookup type.
 * @param p_budget_unit3_value Budget unit 3 value.
 * @param p_budget_unit3_available {@rep:casecolumn
 * PQH_BUDGET_DETAILS.BUDGET_UNIT3_AVAILABLE}
 * @param p_gl_status Posting to GL status. Possible values are Post, Error or
 * Null.
 * @param p_object_version_number Pass in the current version number of the
 * budget detail to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated budget detail. If
 * p_validate is true will be set to the same value which was passed in.
 * @rep:displayname Update Budget Detail
 * @rep:category BUSINESS_ENTITY HR_BUDGET
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_budget_detail
  (
   p_validate                       in boolean    default false
  ,p_budget_detail_id               in  number
  ,p_organization_id                in  number    default hr_api.g_number
  ,p_job_id                         in  number    default hr_api.g_number
  ,p_position_id                    in  number    default hr_api.g_number
  ,p_grade_id                       in  number    default hr_api.g_number
  ,p_budget_version_id              in  number    default hr_api.g_number
  ,p_budget_unit1_percent           in  number    default hr_api.g_number
  ,p_budget_unit1_value_type_cd              in  varchar2  default hr_api.g_varchar2
  ,p_budget_unit1_value             in  number    default hr_api.g_number
  ,p_budget_unit1_available          in  number    default hr_api.g_number
  ,p_budget_unit2_percent           in  number    default hr_api.g_number
  ,p_budget_unit2_value_type_cd              in  varchar2  default hr_api.g_varchar2
  ,p_budget_unit2_value             in  number    default hr_api.g_number
  ,p_budget_unit2_available          in  number    default hr_api.g_number
  ,p_budget_unit3_percent           in  number    default hr_api.g_number
  ,p_budget_unit3_value_type_cd              in  varchar2  default hr_api.g_varchar2
  ,p_budget_unit3_value             in  number    default hr_api.g_number
  ,p_budget_unit3_available          in  number    default hr_api.g_number
  ,p_gl_status                               in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_budget_detail >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This procedure deletes budget details record.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Budget detail record should already exist.
 *
 * <p><b>Post Success</b><br>
 * Budget detail will be successfully deleted in the database.
 *
 * <p><b>Post Failure</b><br>
 * Budget detail will not be deleted and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_budget_detail_id This uniquely identifies the budget detail.
 * @param p_object_version_number Current version number of the budget detail
 * to be deleted.
 * @rep:displayname Delete Budget Detail
 * @rep:category BUSINESS_ENTITY HR_BUDGET
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_budget_detail
  (
   p_validate                       in boolean        default false
  ,p_budget_detail_id               in  number
  ,p_object_version_number          in number
  );
--
end pqh_budget_details_api;

 

/
