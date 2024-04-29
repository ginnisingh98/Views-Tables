--------------------------------------------------------
--  DDL for Package PQH_BUDGETS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_BUDGETS_API" AUTHID CURRENT_USER as
/* $Header: pqbgtapi.pkh 120.2 2006/06/05 19:09:59 nsanghal noship $ */
/*#
 * This package contains APIs to create, update and delete budgets.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Budget
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------------< create_budget >---------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates the budget.
 *
 * Budget information, for example, start and end dates of the budget, or
 * budget measurement unit, or entity budgeted, is created.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Period set name and budget unit should already exist.
 *
 * <p><b>Post Success</b><br>
 * Budget information will be inserted in the database.
 *
 * <p><b>Post Failure</b><br>
 * Budget information will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_budget_id If p_validate is false, then this uniquely identifies the
 * budget record created. If p_validate is true, then set to null.
 * @param p_business_group_id Business group identifier.
 * @param p_start_organization_id Identifier of the starting organization
 * within organization hierarchy tree. Starting organization and those below
 * will be budgeted.
 * @param p_org_structure_version_id {@rep:casecolumn
 * PQH_BUDGETS.ORG_STRUCTURE_VERSION_ID}
 * @param p_budgeted_entity_cd Indicates the budget entity. Valid values are
 * defined by 'PQH_BUDGET_ENTITY' lookup type.
 * @param p_budget_style_cd Indicates the budget style. Valid values are
 * defined by 'PQH_BUDGET_STYLE' lookup type.
 * @param p_budget_name {@rep:casecolumn PQH_BUDGETS.BUDGET_NAME}
 * @param p_period_set_name {@rep:casecolumn PQH_BUDGETS.PERIOD_SET_NAME}
 * @param p_budget_start_date {@rep:casecolumn PQH_BUDGETS.BUDGET_START_DATE}
 * @param p_budget_end_date {@rep:casecolumn PQH_BUDGETS.BUDGET_END_DATE}
 * @param p_gl_budget_name {@rep:casecolumn PQH_BUDGETS.GL_BUDGET_NAME}
 * @param p_psb_budget_flag Indicates if this budget was transferred from PSB.
 * Also this identifies if only GL commitment are to be processed. Valid values
 * are defined by 'YES_NO' lookup type.
 * @param p_transfer_to_gl_flag Indicates whether to transfer to GL or not.
 * Valid values are defined by 'YES_NO' lookup type.
 * @param p_transfer_to_grants_flag Indicates whether to transfer to grants or
 * not. Valid values are defined by 'YES_NO' lookup type.
 * @param p_status Budget is frozen or open.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created budget. If p_validate is true, then the value
 * will be null.
 * @param p_budget_unit1_id Budget identifier for measurement unit 1.
 * @param p_budget_unit2_id Budget identifier for measurement unit 2.
 * @param p_budget_unit3_id Budget identifier for measurement unit 3.
 * @param p_gl_set_of_books_id Identifier for the GL Ledger that will be
 * mapped for transfer to GL.
 * @param p_budget_unit1_aggregate Used to compare period values against budget
 * values. Valid values are defined by 'PQH_BGT_UOM_AGGREGATE' lookup type.
 * @param p_budget_unit2_aggregate Used to compare period values against budget
 * values. Valid values are defined by 'PQH_BGT_UOM_AGGREGATE' lookup type.
 * @param p_budget_unit3_aggregate Used to compare period values against budget
 * values. Valid values are defined by 'PQH_BGT_UOM_AGGREGATE' lookup type.
 * @param p_position_control_flag Indicates if this budget is used for position
 * control or not. Valid values are defined by 'YES_NO' lookup type.
 * @param p_valid_grade_reqd_flag Indicates if a valid grade is required. Valid
 * values are defined by 'YES_NO' lookup type.
 * @param p_currency_code Currency type identifier.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_dflt_budget_set_id New parameter, available on the latest version
 * of this API.
 * @rep:displayname Create Budget
 * @rep:category BUSINESS_ENTITY HR_BUDGET
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_budget
(
   p_validate                       in boolean    default false
  ,p_budget_id                      out nocopy number
  ,p_business_group_id              in  number    default null
  ,p_start_organization_id          in  number    default null
  ,p_org_structure_version_id       in  number    default null
  ,p_budgeted_entity_cd             in  varchar2  default null
  ,p_budget_style_cd                in  varchar2  default null
  ,p_budget_name                    in  varchar2  default null
  ,p_period_set_name                in  varchar2  default null
  ,p_budget_start_date              in  date      default null
  ,p_budget_end_date                in  date      default null
  ,p_gl_budget_name                 in  varchar2  default null
  ,p_psb_budget_flag                in  varchar2  default 'N'
  ,p_transfer_to_gl_flag            in  varchar2  default null
  ,p_transfer_to_grants_flag        in  varchar2  default null
  ,p_status                         in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_budget_unit1_id                in  number    default null
  ,p_budget_unit2_id                in  number    default null
  ,p_budget_unit3_id                in  number    default null
  ,p_gl_set_of_books_id             in  number    default null
  ,p_budget_unit1_aggregate         in varchar2   default null
  ,p_budget_unit2_aggregate         in varchar2   default null
  ,p_budget_unit3_aggregate         in varchar2   default null
  ,p_position_control_flag          in varchar2   default null
  ,p_valid_grade_reqd_flag          in varchar2   default null
  ,p_currency_code                  in varchar2   default null
  ,p_dflt_budget_set_id             in number     default null
  ,p_effective_date                 in  date
 );
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_budget >---------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the budget.
 *
 * Budget information, for example, start and end dates of the budget, or
 * budget measurement unit, or entity budgeted, are updated.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Budget to be updated should already exist. Period set name and budget unit
 * should already exist.
 *
 * <p><b>Post Success</b><br>
 * Budget information will be updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * Budget information will not be updated and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_budget_id Identifies the budget to be updated.
 * @param p_business_group_id Business group identifier.
 * @param p_start_organization_id Identifier of the starting organization
 * within organization hierarchy tree. Starting organization and those below
 * will be budgeted.
 * @param p_org_structure_version_id {@rep:casecolumn
 * PQH_BUDGETS.ORG_STRUCTURE_VERSION_ID}
 * @param p_budgeted_entity_cd Indicates the budget style. Valid values are
 * defined by 'PQH_BUDGET_ENTITY' lookup type.
 * @param p_budget_style_cd Indicates the budget style. Valid values are
 * defined by 'PQH_BUDGET_STYLE' lookup type.
 * @param p_budget_name {@rep:casecolumn PQH_BUDGETS.BUDGET_NAME}
 * @param p_period_set_name {@rep:casecolumn PQH_BUDGETS.PERIOD_SET_NAME}
 * @param p_budget_start_date {@rep:casecolumn PQH_BUDGETS.BUDGET_START_DATE}
 * @param p_budget_end_date {@rep:casecolumn PQH_BUDGETS.BUDGET_END_DATE}
 * @param p_gl_budget_name {@rep:casecolumn PQH_BUDGETS.GL_BUDGET_NAME}
 * @param p_psb_budget_flag Indicates if this budget was transferred from PSB.
 * Also this identifies if only GL commitment are to be processed. Valid values
 * are defined by 'YES_NO' lookup type.
 * @param p_transfer_to_gl_flag Indicates whether to transfer to GL or not.
 * Valid values are defined by 'YES_NO' lookup type.
 * @param p_transfer_to_grants_flag Indicates whether to transfer to grants or
 * not. Valid values are defined by 'YES_NO' lookup type.
 * @param p_status Budget is frozen or open.
 * @param p_object_version_number Pass in the current version number of the
 * budget to be updated. When the API completes if p_validate is false, will be
 * set to the new version number of the updated budget. If p_validate is true
 * will be set to the same value which was passed in.
 * @param p_budget_unit1_id Budget identifier for measurement unit 1.
 * @param p_budget_unit2_id Budget identifier for measurement unit 2.
 * @param p_budget_unit3_id Budget identifier for measurement unit 3.
 * @param p_gl_set_of_books_id Identifier for the GL Ledger that will be
 * mapped for transfer to GL.
 * @param p_budget_unit1_aggregate Used to compare period values against budget
 * values. Valid values are defined by 'PQH_BGT_UOM_AGGREGATE' lookup type.
 * @param p_budget_unit2_aggregate Used to compare period values against budget
 * values. Valid values are defined by 'PQH_BGT_UOM_AGGREGATE' lookup type.
 * @param p_budget_unit3_aggregate Used to compare period values against budget
 * values. Valid values are defined by 'PQH_BGT_UOM_AGGREGATE' lookup type.
 * @param p_position_control_flag Indicates if this budget is used for position
 * control or not. Valid values are defined by 'YES_NO' lookup type.
 * @param p_valid_grade_reqd_flag Indicates if a valid grade is required. Valid
 * values are defined by 'YES_NO' lookup type.
 * @param p_currency_code Currency type identifier.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_dflt_budget_set_id New parameter, available on the latest version
 * of this API.
 * @rep:displayname Update Budget
 * @rep:category BUSINESS_ENTITY HR_BUDGET
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_budget
  (
   p_validate                       in boolean    default false
  ,p_budget_id                      in  number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_start_organization_id          in  number    default hr_api.g_number
  ,p_org_structure_version_id       in  number    default hr_api.g_number
  ,p_budgeted_entity_cd             in  varchar2  default hr_api.g_varchar2
  ,p_budget_style_cd                in  varchar2  default hr_api.g_varchar2
  ,p_budget_name                    in  varchar2  default hr_api.g_varchar2
  ,p_period_set_name                in  varchar2  default hr_api.g_varchar2
  ,p_budget_start_date              in  date      default hr_api.g_date
  ,p_budget_end_date                in  date      default hr_api.g_date
  ,p_gl_budget_name                 in  varchar2  default hr_api.g_varchar2
  ,p_psb_budget_flag                in  varchar2  default hr_api.g_varchar2
  ,p_transfer_to_gl_flag            in  varchar2  default hr_api.g_varchar2
  ,p_transfer_to_grants_flag        in  varchar2  default hr_api.g_varchar2
  ,p_status                         in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_budget_unit1_id                in  number    default hr_api.g_number
  ,p_budget_unit2_id                in  number    default hr_api.g_number
  ,p_budget_unit3_id                in  number    default hr_api.g_number
  ,p_gl_set_of_books_id             in  number    default hr_api.g_number
  ,p_budget_unit1_aggregate         in  varchar2  default hr_api.g_varchar2
  ,p_budget_unit2_aggregate         in  varchar2  default hr_api.g_varchar2
  ,p_budget_unit3_aggregate         in  varchar2  default hr_api.g_varchar2
  ,p_position_control_flag          in  varchar2  default hr_api.g_varchar2
  ,p_valid_grade_reqd_flag          in  varchar2  default hr_api.g_varchar2
  ,p_currency_code                  in  varchar2  default hr_api.g_varchar2
  ,p_dflt_budget_set_id             in  number    default hr_api.g_number
  ,p_effective_date            in  date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_budget >---------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes the budget.
 *
 * Budget information will be deleted.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Budget to be deleted should already exist.
 *
 * <p><b>Post Success</b><br>
 * Budget information will be deleted from the database.
 *
 * <p><b>Post Failure</b><br>
 * Budget information will not be deleted and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_budget_id This uniquely identifies the budget.
 * @param p_object_version_number Current version number of the budget to be
 * deleted.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @rep:displayname Delete Budget
 * @rep:category BUSINESS_ENTITY HR_BUDGET
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_budget
  (
   p_validate                       in boolean        default false
  ,p_budget_id                      in  number
  ,p_object_version_number          in number
  ,p_effective_date            in date
  );
--
end pqh_budgets_api;

 

/
