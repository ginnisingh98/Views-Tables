--------------------------------------------------------
--  DDL for Package PAY_FORMULA_RESULT_RULE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_FORMULA_RESULT_RULE_API" AUTHID CURRENT_USER as
/* $Header: pyfrrapi.pkh 120.1 2005/10/02 02:46:12 aroussel $ */
/*#
 * This package contains Formula Result Rule APIs.
 * @rep:scope public
 * @rep:product PAY
 * @rep:displayname Formula Result Rule
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_formula_result_rule >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This Business Process is used to create a new formula result rule as of the
 * effective date.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Payroll.
 *
 * <p><b>Prerequisites</b><br>
 * The formula and the element to be used should be valid.
 *
 * <p><b>Post Success</b><br>
 * The formula result rule will be successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * Error Messages are raised if any business rule is violated and the Formula
 * result rule is not created.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_status_processing_rule_id Foreign key to
 * PAY_STATUS_PROCESSING_RULES.
 * @param p_result_name Name of the variable returned by the formula.
 * @param p_result_rule_type Formula result type for the formula result rule.
 * Valid values are defined by the 'RESULT_RULE_TYPE' lookup type.
 * @param p_business_group_id Business group of the formula result rule.
 * @param p_legislation_code Legislation of the formula result rule.
 * @param p_element_type_id Target element type.
 * @param p_legislation_subgroup Identifies the startup data legislation for
 * the formula result rule.
 * @param p_severity_level Severity level for a message type result.
 * @param p_input_value_id Target input value.
 * @param p_formula_result_rule_id Primary Key If p_validate is true then this
 * will be set to null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created formula result rule. If
 * p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created formula result rule. If p_validate is
 * true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created formula result rule. If p_validate is true,
 * then the value will be null.
 * @rep:displayname Create Formula Result Rule
 * @rep:category BUSINESS_ENTITY PAY_FORMULA_RESULT
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure CREATE_FORMULA_RESULT_RULE
  (p_validate                    in     boolean   default false
  ,p_effective_date              in     date
  ,p_status_processing_rule_id   in     number
  ,p_result_name                 in     varchar2
  ,p_result_rule_type            in     varchar2
  ,p_business_group_id           in     number    default null
  ,p_legislation_code            in     varchar2  default null
  ,p_element_type_id             in     number    default null
  ,p_legislation_subgroup        in     varchar2  default null
  ,p_severity_level              in     varchar2  default null
  ,p_input_value_id              in     number    default null
  ,p_formula_result_rule_id         out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_formula_result_rule >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This Business Process is used to update a formula result rule as of the
 * effective date.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Payroll.
 *
 * <p><b>Prerequisites</b><br>
 * The formula result rule to be updated should exist and the formula should be
 * valid.
 *
 * <p><b>Post Success</b><br>
 * The formula result rule will be successfully updated into the database.
 *
 * <p><b>Post Failure</b><br>
 * Error Messages are raised if any business rule is violated and the Formula
 * result rule is not updated.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_datetrack_update_mode Indicates which DateTrack mode to use when
 * updating the record. You must set to either UPDATE, CORRECTION,
 * UPDATE_OVERRIDE or UPDATE_CHANGE_INSERT. Modes available for use with a
 * particular record depend on the dates of previous record changes and the
 * effective date of this change.
 * @param p_formula_result_rule_id Unique identifier of the formula result
 * being updated.
 * @param p_object_version_number Pass in the current version number of the
 * formula result rule to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated formula result
 * rule. If p_validate is true will be set to the same value which was passed
 * in.
 * @param p_result_rule_type Formula result type for the formula result rule.
 * Valid values are defined by the 'RESULT_RULE_TYPE' lookup type.
 * @param p_element_type_id Target element type.
 * @param p_severity_level Severity level for a message type result.
 * @param p_input_value_id Target input value.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated formula result rule row, which now
 * exists as of the effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated formula result rule row, which now exists
 * as of the effective date. If p_validate is true, then set to null.
 * @rep:displayname Update Formula Result Rule
 * @rep:category BUSINESS_ENTITY PAY_FORMULA_RESULT
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure UPDATE_FORMULA_RESULT_RULE
  (p_validate                    in     boolean   default false
  ,p_effective_date              in     date
  ,p_datetrack_update_mode       in     varchar2
  ,p_formula_result_rule_id      in     number
  ,p_object_version_number       in out nocopy number
  ,p_result_rule_type            in     varchar2  default hr_api.g_varchar2
  ,p_element_type_id             in     number    default hr_api.g_number
  ,p_severity_level              in     varchar2  default hr_api.g_varchar2
  ,p_input_value_id              in     number    default hr_api.g_number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_formula_result_rule >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This Business Process is used to delete a formula result rule as of the
 * effective date.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Payroll.
 *
 * <p><b>Prerequisites</b><br>
 * A formula result rule must exist.
 *
 * <p><b>Post Success</b><br>
 * The formula result rule will be successfully deleted from the database.
 *
 * <p><b>Post Failure</b><br>
 * Error Messages are raised if any business rule is violated and the Formula
 * result rule is not deleted.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_datetrack_delete_mode Indicates which DateTrack mode to use when
 * deleting the record. You must set to either ZAP, DELETE, FUTURE_CHANGE or
 * DELETE_NEXT_CHANGE. Modes available for use with a particular record depend
 * on the dates of previous record changes and the effective date of this
 * change.
 * @param p_formula_result_rule_id Unique identifier of the formula result
 * being deleted.
 * @param p_object_version_number Pass in the current version number of the
 * formula result rule to be deleted. When the API completes if p_validate is
 * false, will be set to the new version number of the deleted formula result
 * rule. If p_validate is true will be set to the same value which was passed
 * in.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date for the deleted formula result rule row, which now
 * exists as of the effective date. If p_validate is true or all row instances
 * have been deleted then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the deleted formula result rule row, which now exists
 * as of the effective date. If p_validate is true or all row instances have
 * been deleted, then set to null.
 * @rep:displayname Delete Formula Result Rule
 * @rep:category BUSINESS_ENTITY PAY_FORMULA_RESULT
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure DELETE_FORMULA_RESULT_RULE
  (p_validate                    in     boolean   default false
  ,p_effective_date              in     date
  ,p_datetrack_delete_mode       in     varchar2
  ,p_formula_result_rule_id      in     number
  ,p_object_version_number       in out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  );
--
end PAY_FORMULA_RESULT_RULE_API;

 

/
