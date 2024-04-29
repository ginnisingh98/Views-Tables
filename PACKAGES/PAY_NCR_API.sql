--------------------------------------------------------
--  DDL for Package PAY_NCR_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NCR_API" AUTHID CURRENT_USER as
/* $Header: pyncrapi.pkh 120.0.12010.3 2006/06/21 11:27:54 rvarshne noship $ */
/*#
 * This package contains Net Calculation Rule APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Net Calculation Rule
*/
--
-- ----------------------------------------------------------------------------
-- |---------------------< create_pay_net_calc_rule >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a net calculation rule for an accrual plan.
 *
 * Use this API to create additional net calculation rules. A net calculation
 * rule contains a reference to an element type and an input value. When
 * calculating net entitlements, the application adds or subtracts the entry
 * values for each element associated with a net calculation rule. When you
 * create a new accrual plan, the application automatically creates one net
 * calculation rule for Absences and one for carry over.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The accrual plan for which this net calculation rule is being created must
 * already exist. The element type and input value that is to be used as a net
 * calculation rule must already exist.
 *
 * <p><b>Post Success</b><br>
 * The net calculation rule will have been created.
 *
 * <p><b>Post Failure</b><br>
 * The net calculation rule will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_business_group_id The business group under which the net
 * calculation rule is created.
 * @param p_accrual_plan_id Uniquely identifies the accrual plan for which this
 * net calculation rule is created.
 * @param p_input_value_id Uniquely identifies the input value the application
 * uses to include additional element entries in the net entitlement
 * calculations for paid time off.
 * @param p_add_or_subtract Determines whether the entry value should add to or
 * subtract from the net entitlement. Valid values are 1 (Add) and -1
 * (Subtract).
 * @param p_date_input_value_id Uniquely identifies the date input value the
 * application uses to determine the date to adjust the paid time off net
 * entitlement balance.
 * @param p_net_calculation_rule_id If p_validate is false, then this uniquely
 * identifies the Net Calculation Rule. If p_validate is true, then this is set
 * to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created Net Calculation Rule. If p_validate is true,
 * then the value will be null.
 * @rep:displayname Create Net Calculation Rule
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE_ABSENCE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_pay_net_calc_rule
  (p_validate                      in            boolean  default false
  ,p_business_group_id             in            number
  ,p_accrual_plan_id               in            number
  ,p_input_value_id                in            number
  ,p_add_or_subtract               in            varchar2
  ,p_date_input_value_id           in            number   default null
  ,p_net_calculation_rule_id          out nocopy number
  ,p_object_version_number            out nocopy number
  );
--

-- ----------------------------------------------------------------------------
-- |-----------------------< update_pay_net_calc_rule >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
/*#
 * This API updates a net calculation rule for an accrual plan.
 *
 * Use this API to update net calculation rules. A net calculation rule
 * contains a reference to an element type and an input value. When calculating
 * net entitlements, the application adds or subtracts the entry values for
 * each element associated with a net calculation rule. When you create a new
 * accrual plan, the application automatically creates one net calculation rule
 * for Absences and one for carry over.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The net calculation rule being updated must already exist.
 *
 * <p><b>Post Success</b><br>
 * The net calculation rule will have been updated.
 *
 * <p><b>Post Failure</b><br>
 * The net calculation rule will not be updated and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_net_calculation_rule_id Uniquely identifies the net calculation
 * rule that is being updated.
 * @param p_accrual_plan_id Uniquely identifies the accrual plan for which this
 * net calculation rule is being updated, implying that the rule will move from
 * one accrual plan to another.
 * @param p_input_value_id Uniquely identifies the input value used by the
 * application to include additional element entries in the net entitlement
 * calculations for paid time off.
 * @param p_add_or_subtract Determines whether the entry value should add to or
 * subtract from the net entitlement. Valid values are 1 (Add) and -1
 * (Subtract).
 * @param p_date_input_value_id Uniquely identifies the date input value the
 * application uses to determine the date to adjust the paid time off net
 * entitlement balance.
 * @param p_object_version_number Pass in the current version number of the Net
 * Calculation Rule to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated Net Calculation
 * Rule. If p_validate is true will be set to the same value which was passed
 * in.
 * @rep:displayname Update Net Calculation Rule
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE_ABSENCE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_pay_net_calc_rule
  (p_validate                      in     boolean  default false
  ,p_net_calculation_rule_id       in     number
  ,p_accrual_plan_id               in     number   default hr_api.g_number
  ,p_input_value_id                in     number   default hr_api.g_number
  ,p_add_or_subtract               in     varchar2 default hr_api.g_varchar2
  ,p_date_input_value_id           in     number   default hr_api.g_number
  ,p_object_version_number         in out nocopy number
  );
--

-- ----------------------------------------------------------------------------
-- |-----------------------< delete_pay_net_calc_rule >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
/*#
 * This API deletes a net calculation rule for an accrual plan.
 *
 * A net calculation rule contains a reference to an element type and an input
 * value. When calculating net entitlements, the application adds or subtracts
 * the entry values for each element associated with a net calculation rule.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The net calculation rule being deleted must already exist.
 *
 * <p><b>Post Success</b><br>
 * The net calculation rule will have been deleted.
 *
 * <p><b>Post Failure</b><br>
 * The net calculation rule will not be deleted and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_net_calculation_rule_id Uniquely identifies the net calculation
 * rule that is being deleted.
 * @param p_object_version_number Current version number of the Net Calculation
 * Rule to be deleted.
 * @rep:displayname Delete Net Calculation Rule
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE_ABSENCE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_pay_net_calc_rule
  (p_validate                      in     boolean  default false
  ,p_net_calculation_rule_id       in     number
  ,p_object_version_number         in     number
  );
--
end pay_ncr_api;

 

/
