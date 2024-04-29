--------------------------------------------------------
--  DDL for Package PQH_BDGT_CMMTMNT_ELMNTS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_BDGT_CMMTMNT_ELMNTS_API" AUTHID CURRENT_USER as
/* $Header: pqbceapi.pkh 120.1 2005/10/02 02:25:33 aroussel $ */
/*#
 * This package contains APIs to create, update and delete the elements for
 * Budget Commitments.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Budget Commitment Element
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_bdgt_cmmtmnt_elmnt >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates the elements for Budget Commitments.
 *
 * The elements created are used for computing commitments for a budget.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The budget should already exist. There should be valid elements created.
 *
 * <p><b>Post Success</b><br>
 * Commitment element for a budget will be successfully inserted in the
 * database.
 *
 * <p><b>Post Failure</b><br>
 * The commitment element will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_bdgt_cmmtmnt_elmnt_id If p_validate is false, then this uniquely
 * identifies the commitment element created. If p_validate is true, then set
 * to null.
 * @param p_budget_id Identifies the budget for which the element record is
 * created.
 * @param p_actual_commitment_type Identifies if the defined element should be
 * used for actual or commitment computation or both.
 * @param p_element_type_id {@rep:casecolumn
 * PQH_BDGT_CMMTMNT_ELMNTS.ELEMENT_TYPE_ID}
 * @param p_salary_basis_flag Indicates if salary basis is used for commitment
 * computation. Valid values are defined by 'YES_NO'lookup type.
 * @param p_element_input_value_id Identifies element input value.
 * @param p_balance_type_id Balance type to be used for actuals computation.
 * @param p_frequency_input_value_id Identifies frequency input value.
 * @param p_formula_id Identifies formula.
 * @param p_dflt_elmnt_frequency {@rep:casecolumn
 * PQH_BDGT_CMMTMNT_ELMNTS.DFLT_ELMNT_FREQUENCY}
 * @param p_overhead_percentage Tolerance to be added to commitment element
 * amount.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created element. If p_validate is true, then the value
 * will be null.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @rep:displayname Create Budget Commitment Element
 * @rep:category BUSINESS_ENTITY HR_BUDGET
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_bdgt_cmmtmnt_elmnt
(
   p_validate                       in boolean    default false
  ,p_bdgt_cmmtmnt_elmnt_id          out nocopy number
  ,p_budget_id                      in  number    default null
  ,p_actual_commitment_type         in  varchar2  default null
  ,p_element_type_id                in  number    default null
  ,p_salary_basis_flag              in  varchar2  default 'N'
  ,p_element_input_value_id         in  number    default null
  ,p_balance_type_id                in  number    default null
  ,p_frequency_input_value_id       in  number    default null
  ,p_formula_id                     in  number    default null
  ,p_dflt_elmnt_frequency           in  varchar2  default null
  ,p_overhead_percentage            in  number    default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date            in  date
 );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_bdgt_cmmtmnt_elmnt >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the elements for Budget Commitments.
 *
 * The element used for commitment computation of a budget can be changed to
 * another element.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid budget commitment element must already exist to be able to update
 * it.
 *
 * <p><b>Post Success</b><br>
 * The commitment element details will be successfully updated.
 *
 * <p><b>Post Failure</b><br>
 * The commitment element will not be updated and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_bdgt_cmmtmnt_elmnt_id This uniquely identifies the commitment
 * element record that needs to be updated.
 * @param p_budget_id Identifies the budget for which the element record is
 * created.
 * @param p_actual_commitment_type Identifies if the defined element should be
 * used for actual or commitment computation or both.
 * @param p_element_type_id Identifies the element type.
 * @param p_salary_basis_flag Indicates if salary basis is used for commitment
 * computation. Valid values are defined by 'YES_NO' lookup type.
 * @param p_element_input_value_id Identifies element input value.
 * @param p_balance_type_id Balance type to be used for actuals computation.
 * @param p_frequency_input_value_id Identifies frequency input value.
 * @param p_formula_id Identifies formula.
 * @param p_dflt_elmnt_frequency {@rep:casecolumn
 * PQH_BDGT_CMMTMNT_ELMNTS.DFLT_ELMNT_FREQUENCY}
 * @param p_overhead_percentage Tolerance to be added to commitment element
 * amount.
 * @param p_object_version_number Pass in the current version number of the
 * element to be updated. When the API completes if p_validate is false, will
 * be set to the new version number of the updated element. If p_validate is
 * true will be set to the same value which was passed in.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @rep:displayname Update Budget Commitment Element
 * @rep:category BUSINESS_ENTITY HR_BUDGET
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_bdgt_cmmtmnt_elmnt
  (
   p_validate                       in boolean    default false
  ,p_bdgt_cmmtmnt_elmnt_id          in  number
  ,p_budget_id                      in  number    default hr_api.g_number
  ,p_actual_commitment_type         in  varchar2  default hr_api.g_varchar2
  ,p_element_type_id                in  number    default hr_api.g_number
  ,p_salary_basis_flag              in  varchar2  default hr_api.g_varchar2
  ,p_element_input_value_id         in  number    default hr_api.g_number
  ,p_balance_type_id                in  number    default hr_api.g_number
  ,p_frequency_input_value_id       in  number    default hr_api.g_number
  ,p_formula_id                     in  number    default hr_api.g_number
  ,p_dflt_elmnt_frequency           in  varchar2  default hr_api.g_varchar2
  ,p_overhead_percentage            in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date            in  date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_bdgt_cmmtmnt_elmnt >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes the element created for Budget Commitments.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid budget commitment element must already exist to be able to delete
 * it.
 *
 * <p><b>Post Success</b><br>
 * Budget commitment element will be successfully deleted.
 *
 * <p><b>Post Failure</b><br>
 * Commitment element for a budget will not be deleted and an error will be
 * raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_bdgt_cmmtmnt_elmnt_id This uniquely identifies the budget
 * commitment element.
 * @param p_object_version_number Current version number of the element to be
 * deleted.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @rep:displayname Delete Budget Commitment Element
 * @rep:category BUSINESS_ENTITY HR_BUDGET
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_bdgt_cmmtmnt_elmnt
  (
   p_validate                       in boolean        default false
  ,p_bdgt_cmmtmnt_elmnt_id          in  number
  ,p_object_version_number          in  number
  ,p_effective_date            in date
  );
--
end pqh_bdgt_cmmtmnt_elmnts_api;

 

/
