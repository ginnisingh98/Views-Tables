--------------------------------------------------------
--  DDL for Package HR_ACCRUAL_PLAN_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ACCRUAL_PLAN_API" AUTHID CURRENT_USER as
/* $Header: hrpapapi.pkh 120.1.12010000.1 2008/07/28 03:37:27 appldev ship $ */
/*#
 * This package contains accrual plan APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Accrual Plan
*/
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_accrual_plan >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates an accrual plan and tracks employee paid time-off
 * entitlements.
 *
 * Use this API to create an accrual plan and accrual plan elements. Accrual
 * plans define the paid time-off entitlement criteria used to calculate
 * accruals for each employee enrolled in the plan. You enroll employees in the
 * plan by giving them the accrual plan element.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * An absence type, linked to an absence element, must have already been
 * created. It is recommended that the absence element is linked otherwise
 * element links will not automatically be created for the system-generated
 * accrual plan elements.
 *
 * <p><b>Post Success</b><br>
 * The accrual plan, default net calculation rules, accrual plan elements and,
 * where applicable, element links, payroll balances and formula result rules
 * will have been created.
 *
 * <p><b>Post Failure</b><br>
 * The accrual plan will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_business_group_id The business group of the accrual plan.
 * @param p_accrual_formula_id The Fast Formula used to calculate accrual
 * entitlements.
 * @param p_co_formula_id The Fast Formula used to calculate how much paid time
 * off should be carried over to the following accrual year.
 * @param p_pto_input_value_id The input value of the absence element used to
 * record the number of days or hours absent, and to calculate the accrual plan
 * net entitlement.
 * @param p_accrual_plan_name The name of the accrual plan. The name must be
 * unique within the business group.
 * @param p_accrual_units_of_measure The unit of measure used to express
 * accruals. Valid values are defined by the 'HOURS_OR_DAYS' lookup type.
 * @param p_accrual_category The category to which this accrual plan belongs.
 * Valid values are defined by the 'US_PTO_ACCRUAL' lookup type.
 * @param p_accrual_start Defines when an employee actually starts to accrue.
 * Valid values are defined by the 'US_ACCRUAL_START_TYPE' lookup type.
 * @param p_ineligible_period_length The length of the ineligibility period.
 * The unit of measure is defined by the ineligibility period type.
 * @param p_ineligible_period_type The unit of measure used to express the
 * ineligibility period. Valid values are defined by the 'PROC_PERIOD_TYPE'
 * lookup type.
 * @param p_description The accrual plan's description.
 * @param p_ineligibility_formula_id The unique identifier of the fast formula
 * used to calculate paid time-off eligibility when absence records are entered
 * through Batch Element Entry.
 * @param p_balance_dimension_id The payroll balance dimension that determines
 * the date the balance resets when the application stores paid time-off
 * entitlements in payroll balances.
 * @param p_information_category This context value determines which flexfield
 * structure to use with the developer descriptive flexfield segments.
 * @param p_information1 Developer descriptive flexfield segment.
 * @param p_information2 Developer descriptive flexfield segment.
 * @param p_information3 Developer descriptive flexfield segment.
 * @param p_information4 Developer descriptive flexfield segment.
 * @param p_information5 Developer descriptive flexfield segment.
 * @param p_information6 Developer descriptive flexfield segment.
 * @param p_information7 Developer descriptive flexfield segment.
 * @param p_information8 Developer descriptive flexfield segment.
 * @param p_information9 Developer descriptive flexfield segment.
 * @param p_information10 Developer descriptive flexfield segment.
 * @param p_information11 Developer descriptive flexfield segment.
 * @param p_information12 Developer descriptive flexfield segment.
 * @param p_information13 Developer descriptive flexfield segment.
 * @param p_information14 Developer descriptive flexfield segment.
 * @param p_information15 Developer descriptive flexfield segment.
 * @param p_information16 Developer descriptive flexfield segment.
 * @param p_information17 Developer descriptive flexfield segment.
 * @param p_information18 Developer descriptive flexfield segment.
 * @param p_information19 Developer descriptive flexfield segment.
 * @param p_information20 Developer descriptive flexfield segment.
 * @param p_information21 Developer descriptive flexfield segment.
 * @param p_information22 Developer descriptive flexfield segment.
 * @param p_information23 Developer descriptive flexfield segment.
 * @param p_information24 Developer descriptive flexfield segment.
 * @param p_information25 Developer descriptive flexfield segment.
 * @param p_information26 Developer descriptive flexfield segment.
 * @param p_information27 Developer descriptive flexfield segment.
 * @param p_information28 Developer descriptive flexfield segment.
 * @param p_information29 Developer descriptive flexfield segment.
 * @param p_information30 Developer descriptive flexfield segment.
 * @param p_accrual_plan_id If p_validate is false, then this uniquely
 * identifies the accrual plan created. If p_validate is true, then the process
 * returns null.
 * @param p_accrual_plan_element_type_id If p_validate is false, then this
 * uniquely identifies the element created to enroll employees on the accrual
 * plan. If p_validate is true, then the process returns null.
 * @param p_co_element_type_id If p_validate is false, this uniquely identifies
 * the element created to store paid time-off entitlements carried over from
 * one accrual year to the next. If p_validate is true, then the process
 * returns null.
 * @param p_co_input_value_id If p_validate is false, this uniquely identifies
 * the input value used to store carried-over amounts. If p_validate is true,
 * the process returns null.
 * @param p_co_date_input_value_id If p_validate is false, this uniquely
 * identifies the input value used to store the effective date of the amount
 * carried over. If p_validate is true, then the process returns null.
 * @param p_co_exp_date_input_value_id If p_validate is false, this uniquely
 * identifies the input value used to store the expiration date of the amount
 * carried over. If p_validate is true, the procss returns null.
 * @param p_residual_element_type_id If p_validate is false, this uniquely
 * identifies the element created to store the residual amounts (the amount
 * that exceeds the carry over maximum). If p_validate is true, the process
 * returns null.
 * @param p_residual_input_value_id If p_validate is false, this uniquely
 * identifies the input value used to store the residual amount. If p_validate
 * is true, the process returns null.
 * @param p_residual_date_input_value_id If p_validate is false, this uniquely
 * identifies the input value used to store the effective date of the residual
 * amount. If p_validate is true, the process returns null.
 * @param p_payroll_formula_id If p_validate is false, this uniquely identifies
 * the system-generated Fast Formula used by formula result rules during the
 * payroll process to calculate the stored balance. If p_validate is true, the
 * process returns null.
 * @param p_defined_balance_id If p_validate is false, this uniquely identifies
 * the system-generated defined balance used to store the payroll balance. If
 * p_validate is true, the process returns null.
 * @param p_balance_element_type_id If p_validate is false, this uniquely
 * identifies the element created to feed the stored balance. If p_validate is
 * true, then the process returns null.
 * @param p_tagging_element_type_id If p_validate is false, returns the unique
 * identifier of a newly-created tagging element. If p_validate is true, the
 * process returns null. Note: Tagging elements, in this context, tag net
 * calculation rules entered retrospectively, such as retrospective absence
 * records. Net calculation rules force the recalculation of the stored
 * balance.
 * @param p_object_version_number If p_validate is false, returns the version
 * number of the created accrual plan. If p_validate is true, the process
 * returns null.
 * @param p_no_link_message If set to true, then the process could not create
 * element links for the system-generated elements.
 * @param p_check_accrual_ff If the process returns true, this value is a
 * warning that the customer-defined Fast Formula used as the accrual Fast
 * Formula must support stored balances.
 * @rep:displayname Create Accrual Plan
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE_ABSENCE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_accrual_plan
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_accrual_formula_id            in     number
  ,p_co_formula_id                 in     number
  ,p_pto_input_value_id            in     number
  ,p_accrual_plan_name             in     varchar2
  ,p_accrual_units_of_measure      in     varchar2
  ,p_accrual_category              in     varchar2 default null
  ,p_accrual_start                 in     varchar2 default null
  ,p_ineligible_period_length      in     number   default null
  ,p_ineligible_period_type        in     varchar2 default null
  ,p_description                   in     varchar2 default null
  ,p_ineligibility_formula_id      in     number   default null
  ,p_balance_dimension_id          in     number   default null
  ,p_information_category          in     varchar2 default null
  ,p_information1		   in	  varchar2 default null
  ,p_information2                  in     varchar2 default null
  ,p_information3                  in     varchar2 default null
  ,p_information4                  in     varchar2 default null
  ,p_information5                  in     varchar2 default null
  ,p_information6                  in     varchar2 default null
  ,p_information7                  in     varchar2 default null
  ,p_information8                  in     varchar2 default null
  ,p_information9                  in     varchar2 default null
  ,p_information10                 in     varchar2 default null
  ,p_information11                 in     varchar2 default null
  ,p_information12                 in     varchar2 default null
  ,p_information13                 in     varchar2 default null
  ,p_information14                 in     varchar2 default null
  ,p_information15                 in     varchar2 default null
  ,p_information16                 in     varchar2 default null
  ,p_information17                 in     varchar2 default null
  ,p_information18                 in     varchar2 default null
  ,p_information19                 in     varchar2 default null
  ,p_information20                 in     varchar2 default null
  ,p_information21                 in     varchar2 default null
  ,p_information22                 in     varchar2 default null
  ,p_information23                 in     varchar2 default null
  ,p_information24                 in     varchar2 default null
  ,p_information25                 in     varchar2 default null
  ,p_information26                 in     varchar2 default null
  ,p_information27                 in     varchar2 default null
  ,p_information28                 in     varchar2 default null
  ,p_information29                 in     varchar2 default null
  ,p_information30                 in     varchar2 default null
  ,p_accrual_plan_id               out nocopy    number
  ,p_accrual_plan_element_type_id  out nocopy    number
  ,p_co_element_type_id            out nocopy    number
  ,p_co_input_value_id             out nocopy    number
  ,p_co_date_input_value_id        out nocopy    number
  ,p_co_exp_date_input_value_id    out nocopy    number
  ,p_residual_element_type_id      out nocopy    number
  ,p_residual_input_value_id       out nocopy    number
  ,p_residual_date_input_value_id  out nocopy    number
  ,p_payroll_formula_id            out nocopy    number
  ,p_defined_balance_id            out nocopy    number
  ,p_balance_element_type_id       out nocopy    number
  ,p_tagging_element_type_id       out nocopy    number
  ,p_object_version_number         out nocopy    number
  ,p_no_link_message               out nocopy    boolean
  ,p_check_accrual_ff              out nocopy    boolean
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_accrual_plan >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an accrual plan and tracks employee paid time-off
 * entitlements.
 *
 * Use this API to update an accrual plan. Accrual plans define the paid
 * time-off entitlement criteria used to calculate accruals for each employee
 * enrolled in the plan. You enroll employees in the plan by giving them the
 * accrual plan element. You cannot update some attributes of an accrual plan
 * because they would invalidate existing accruals, such as the balance reset
 * date.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The accrual plan that is being updated must already exist.
 *
 * <p><b>Post Success</b><br>
 * The accrual plan details will have been updated.
 *
 * <p><b>Post Failure</b><br>
 * The accrual plan will not be updated and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_accrual_plan_id The unique identifier of the accrual plan to be
 * updated.
 * @param p_pto_input_value_id The input value of the absence element used to
 * record the number of days or hours absent and to calculate the accrual plan
 * net entitlement.
 * @param p_accrual_category The category to which this accrual plan belongs.
 * Valid values are defined by the 'US_PTO_ACCRUAL' lookup type.
 * @param p_accrual_start Defines when an employee actually starts to accrue.
 * Valid values are defined by the 'US_ACCRUAL_START_TYPE' lookup type.
 * @param p_ineligible_period_length The length of the ineligibility period.
 * The unit of measure is defined by the ineligibility period type.
 * @param p_ineligible_period_type The unit of measure used to express the
 * ineligibility period. Valid values are defined by the 'PROC_PERIOD_TYPE'
 * lookup type.
 * @param p_accrual_formula_id The Fast Formula used to calculate accrual
 * entitlements.
 * @param p_co_formula_id The Fast Formula used to calculate how much paid time
 * off should be carried over to the following accrual year.
 * @param p_description The accrual plan's description.
 * @param p_ineligibility_formula_id The Fast Formula used to determine paid
 * time-off eligibility when absence records are entered through Batch Element
 * Entry.
 * @param p_balance_dimension_id The payroll balance dimension that determines
 * the date the balance should reset when paid time-off entitlements are stored
 * in payroll balances.
 * @param p_information_category This context value determines which flexfield
 * structure to use with the developer descriptive flexfield segments.
 * @param p_information1 Developer descriptive flexfield segment.
 * @param p_information2 Developer descriptive flexfield segment.
 * @param p_information3 Developer descriptive flexfield segment.
 * @param p_information4 Developer descriptive flexfield segment.
 * @param p_information5 Developer descriptive flexfield segment.
 * @param p_information6 Developer descriptive flexfield segment.
 * @param p_information7 Developer descriptive flexfield segment.
 * @param p_information8 Developer descriptive flexfield segment.
 * @param p_information9 Developer descriptive flexfield segment.
 * @param p_information10 Developer descriptive flexfield segment.
 * @param p_information11 Developer descriptive flexfield segment.
 * @param p_information12 Developer descriptive flexfield segment.
 * @param p_information13 Developer descriptive flexfield segment.
 * @param p_information14 Developer descriptive flexfield segment.
 * @param p_information15 Developer descriptive flexfield segment.
 * @param p_information16 Developer descriptive flexfield segment.
 * @param p_information17 Developer descriptive flexfield segment.
 * @param p_information18 Developer descriptive flexfield segment.
 * @param p_information19 Developer descriptive flexfield segment.
 * @param p_information20 Developer descriptive flexfield segment.
 * @param p_information21 Developer descriptive flexfield segment.
 * @param p_information22 Developer descriptive flexfield segment.
 * @param p_information23 Developer descriptive flexfield segment.
 * @param p_information24 Developer descriptive flexfield segment.
 * @param p_information25 Developer descriptive flexfield segment.
 * @param p_information26 Developer descriptive flexfield segment.
 * @param p_information27 Developer descriptive flexfield segment.
 * @param p_information28 Developer descriptive flexfield segment.
 * @param p_information29 Developer descriptive flexfield segment.
 * @param p_information30 Developer descriptive flexfield segment.
 * @param p_object_version_number Passes the current version number of the
 * accrual plan to update. If p_validate is false on completion, the process
 * returns the new version number of the updated accrual plan. If p_validate is
 * true, the process sets the input value.
 * @param p_payroll_formula_id If p_validate is false, and the payroll formula
 * is not already defined, this uniquely identifies the system-generated Fast
 * Formula used by formula result rules during the payroll process to calculate
 * the stored balance. If p_validate is true, the process returns null.
 * @param p_defined_balance_id If p_validate is false, and the balance reset
 * date is not already defined, this uniquely identifies the defined balance
 * the process creates to store the payroll balance. If p_validate is true, the
 * process returns to null.
 * @param p_balance_element_type_id If p_validate is false, and the balance
 * element is not already created, this uniquely identifies the element the
 * process creates to feed the stored balance. If p_validate is true, the
 * process returns null.
 * @param p_tagging_element_type_id If p_validate is false, and the tagging
 * element has not already been created, returns the unique identifier of the
 * tagging element the process creates. If p_validate is true, the process
 * returns null. Note: Tagging elements, in this context, tag net calculation
 * rules entered retrospectively, such as retrospective absence records. Net
 * calculation rules force the recalculation of the stored balance.
 * @param p_check_accrual_ff If the process returns true, this value is a
 * warning that the customer-defined Fast Formula used as the accrual Fast
 * Formula must support stored balances.
 * @rep:displayname Update Accrual Plan
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE_ABSENCE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_accrual_plan
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_accrual_plan_id               in     number
  ,p_pto_input_value_id            in     number   default hr_api.g_number
  ,p_accrual_category              in     varchar2 default hr_api.g_varchar2
  ,p_accrual_start                 in     varchar2 default hr_api.g_varchar2
  ,p_ineligible_period_length      in     number   default hr_api.g_number
  ,p_ineligible_period_type        in     varchar2 default hr_api.g_varchar2
  ,p_accrual_formula_id            in     number   default hr_api.g_number
  ,p_co_formula_id                 in     number   default hr_api.g_number
  ,p_description                   in     varchar2 default hr_api.g_varchar2
  ,p_ineligibility_formula_id      in     number   default hr_api.g_number
  ,p_balance_dimension_id          in     number   default hr_api.g_number
  ,p_information_category          in     varchar2 default hr_api.g_varchar2
  ,p_information1                  in     varchar2 default hr_api.g_varchar2
  ,p_information2                  in     varchar2 default hr_api.g_varchar2
  ,p_information3                  in     varchar2 default hr_api.g_varchar2
  ,p_information4                  in     varchar2 default hr_api.g_varchar2
  ,p_information5                  in     varchar2 default hr_api.g_varchar2
  ,p_information6                  in     varchar2 default hr_api.g_varchar2
  ,p_information7                  in     varchar2 default hr_api.g_varchar2
  ,p_information8                  in     varchar2 default hr_api.g_varchar2
  ,p_information9                  in     varchar2 default hr_api.g_varchar2
  ,p_information10                 in     varchar2 default hr_api.g_varchar2
  ,p_information11                 in     varchar2 default hr_api.g_varchar2
  ,p_information12                 in     varchar2 default hr_api.g_varchar2
  ,p_information13                 in     varchar2 default hr_api.g_varchar2
  ,p_information14                 in     varchar2 default hr_api.g_varchar2
  ,p_information15                 in     varchar2 default hr_api.g_varchar2
  ,p_information16                 in     varchar2 default hr_api.g_varchar2
  ,p_information17                 in     varchar2 default hr_api.g_varchar2
  ,p_information18                 in     varchar2 default hr_api.g_varchar2
  ,p_information19                 in     varchar2 default hr_api.g_varchar2
  ,p_information20                 in     varchar2 default hr_api.g_varchar2
  ,p_information21                 in     varchar2 default hr_api.g_varchar2
  ,p_information22                 in     varchar2 default hr_api.g_varchar2
  ,p_information23                 in     varchar2 default hr_api.g_varchar2
  ,p_information24                 in     varchar2 default hr_api.g_varchar2
  ,p_information25                 in     varchar2 default hr_api.g_varchar2
  ,p_information26                 in     varchar2 default hr_api.g_varchar2
  ,p_information27                 in     varchar2 default hr_api.g_varchar2
  ,p_information28                 in     varchar2 default hr_api.g_varchar2
  ,p_information29                 in     varchar2 default hr_api.g_varchar2
  ,p_information30                 in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy number
  ,p_payroll_formula_id               out nocopy number
  ,p_defined_balance_id               out nocopy number
  ,p_balance_element_type_id          out nocopy number
  ,p_tagging_element_type_id          out nocopy number
  ,p_check_accrual_ff                 out nocopy boolean
    );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_accrual_plan >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes an accrual plan and all of its accrual band, net
 * calculation rule, and element type records.
 *
 * Use this API to delete an accrual plan. You cannot delete accrual plans when
 * element entries or links exist for any of the accrual plan's element types,
 * or if you have set up formula result rules.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The accrual plan that is being deleted must already exist.
 *
 * <p><b>Post Success</b><br>
 * The accrual plan and its accrual bands, net calculation rules and element
 * types will have been deleted.
 *
 * <p><b>Post Failure</b><br>
 * The accrual plan and associated records will not be deleted and an error
 * will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_accrual_plan_id The unique identifier of the accrual plan that will
 * be deleted.
 * @param p_accrual_plan_element_type_id The unique identifier of the accrual
 * plan element type.
 * @param p_co_element_type_id The unique identifier of the carry over element
 * type.
 * @param p_residual_element_type_id The unique identifier of the residual
 * element type.
 * @param p_balance_element_type_id The unique identifier of the balance
 * element type.
 * @param p_tagging_element_type_id The unique identifier of the tagging
 * element type.
 * @param p_object_version_number Current version number of the accrual plan to
 * be deleted.
 * @rep:displayname Delete Accrual Plan
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE_ABSENCE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_accrual_plan
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_accrual_plan_id               in     number
  ,p_accrual_plan_element_type_id  in     number
  ,p_co_element_type_id            in     number
  ,p_residual_element_type_id      in     number
  ,p_balance_element_type_id       in     number
  ,p_tagging_element_type_id       in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_input_value >--------------------------|
-- ----------------------------------------------------------------------------
--
function create_input_value(p_element_name              IN varchar2,
                            p_input_value_name          IN varchar2,
                            p_uom_code                  IN varchar2,
                            p_bg_name                   IN varchar2,
                            p_element_type_id           IN number,
                            p_primary_classification_id IN number,
                            p_business_group_id         IN number,
                            p_recurring_flag            IN varchar2,
                            p_legislation_code          IN varchar2,
                            p_classification_type       IN varchar2,
                            p_mandatory_flag            IN varchar2
                            ) RETURN number;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_element >------------------------------|
-- ----------------------------------------------------------------------------
--
--    NAME        create_element
--
--    DESCRIPTION calls the function PAY_DB_PAY_SETUP.CREATE_ELEMENT,The sole
--                reason for this is to cut down on space and reduce the margin
--                for errors in the call, passing only the things that change.
--
--    NOTES       anticipate the only use for this is to be called from the
--                pre_insert routine.
--
FUNCTION create_element(p_element_name          IN varchar2,
                        p_element_description   IN varchar2,
                        p_processing_type       IN varchar2,
                        p_bg_name               IN varchar2,
                        p_classification_name   IN varchar2,
                        p_legislation_code      IN varchar2,
                        p_currency_code         IN varchar2,
                        p_post_termination_rule IN varchar2,
                        p_mult_entries_allowed  IN varchar2,
                        p_indirect_only_flag    IN varchar2,
                        p_formula_id            IN number,
                        p_processing_priority   IN number) return number;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_element_link >------------------------|
-- ----------------------------------------------------------------------------
--
--    NAME
--      create_element_link
--
--    DESCRIPTION
--      Creates a default link for a given element, based on the link for a
--      plan's absence element.
--
--    NOTES
--      none
--
PROCEDURE create_element_link(p_element_type_id  IN number,
                              p_absence_link_rec IN pay_element_links_f%rowtype,
                              p_legislation_code IN varchar2);
--
-- ----------------------------------------------------------------------------
-- |---------------------< create_payroll_formula >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_payroll_formula(
   p_formula_id           out nocopy number,
   p_effective_start_date in date,
   p_effective_end_date   in date,
   p_accrual_plan_name    in varchar2,
   p_defined_balance_id   in number,
   p_business_group_id    in number,
   p_legislation_code     in varchar2
  );
--
end hr_accrual_plan_api;

/
