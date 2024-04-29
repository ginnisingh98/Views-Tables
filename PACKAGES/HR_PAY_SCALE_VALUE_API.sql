--------------------------------------------------------
--  DDL for Package HR_PAY_SCALE_VALUE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PAY_SCALE_VALUE_API" AUTHID CURRENT_USER as
/* $Header: pypsrapi.pkh 120.1 2005/10/02 02:33:23 aroussel $ */
/*#
 * This package contains APIs that will maintain rate values for pay scale
 * points.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Scale Rate Value
*/
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_pay_scale_value >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a rate value for a defined point on a pay scale.
 *
 * You can assign a rate (such as an amount for overtime) to an employee based
 * on their pay scale point. You can define a rate as a specific value or a
 * range of values.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid pay scale and point must exist as of the start date of the pay scale
 * rate value.
 *
 * <p><b>Post Success</b><br>
 * A pay scale rate value will be created.
 *
 * <p><b>Post Failure</b><br>
 * A pay scale rate value will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force
 * @param p_rate_id If p_validate is false, uniquely identifies the pay scale
 * rate value created. If p_validate is true, set to null.
 * @param p_currency_code For pay rates that have the unit of 'MONEY', this
 * parameter must be set to a value from the column
 * FND_CURRENCIES.CURRENCY_CODE.
 * @param p_spinal_point_id The pay scale point for which the rate value is
 * created.
 * @param p_value The actual rate value that applies to this pay scale point.
 * @param p_grade_rule_id If p_validate is false, uniquely identifies the pay
 * scale rate value created. If p_validate is true, set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created pay scale rate value. If p_validate is true,
 * then the value will be null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created pay scale rate value. If
 * p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created pay scale rate value. If p_validate is
 * true, then set to null.
 * @rep:displayname Create Pay Scale Rate Value
 * @rep:category BUSINESS_ENTITY HR_PAY_SCALE
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_pay_scale_value
  (p_validate                      in            boolean  default false
  ,p_effective_date                in            date
  ,p_rate_id                       in            number
  ,p_currency_code                 in            varchar2
  ,p_spinal_point_id               in            number
  ,p_value                         in            varchar2 default null
  ,p_grade_rule_id                    out nocopy number
  ,p_object_version_number            out nocopy number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_pay_scale_value >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a rate value for a defined point on a pay scale.
 *
 * You can assign a rate (such as an amount for overtime) to an employee based
 * on their pay scale point. You can define a rate as a specific value or a
 * range of values.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The pay scale rate value must exist on the effective date of the update.
 *
 * <p><b>Post Success</b><br>
 * The pay scale rate value will be updated.
 *
 * <p><b>Post Failure</b><br>
 * The pay scale rate value will not be updated and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force
 * @param p_datetrack_update_mode Indicates which DateTrack mode to use when
 * updating the record. You must set to either UPDATE, CORRECTION,
 * UPDATE_OVERRIDE or UPDATE_CHANGE_INSERT. Modes available for use with a
 * particular record depend on the dates of previous record changes and the
 * effective date of this change.
 * @param p_grade_rule_id Uniquely identifies the pay scale rate value to be
 * updated.
 * @param p_object_version_number Pass in the current version number of the pay
 * scale rate value to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated pay scale rate
 * value. If p_validate is true will be set to the same value which was passed
 * in.
 * @param p_currency_code For pay rates that have the unit of 'MONEY', this
 * parameter must be set to a value from the column
 * FND_CURRENCIES.CURRENCY_CODE.
 * @param p_maximum Cannot be set for pay scale rate values. Do not pass in.
 * @param p_mid_value Cannot be set for pay scale rate values. Do not pass in.
 * @param p_minimum Cannot be set for pay scale rate values. Do not pass in.
 * @param p_value The actual rate value that applies to this pay scale point.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated pay scale rate value row which now
 * exists as of the effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated pay scale rate value row which now exists
 * as of the effective date. If p_validate is true, then set to null.
 * @rep:displayname Update Pay Scale Rate Value
 * @rep:category BUSINESS_ENTITY HR_PAY_SCALE
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_pay_scale_value
  (p_validate                      in            boolean  default false
  ,p_effective_date                in            date
  ,p_datetrack_update_mode         in            varchar2
  ,p_grade_rule_id                 in            number
  ,p_object_version_number         in out nocopy number
  ,p_currency_code                 in            varchar2
  ,p_maximum                       in            varchar2 default null
  ,p_mid_value                     in            varchar2 default null
  ,p_minimum                       in            varchar2 default null
  ,p_value                         in            varchar2 default null
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_pay_scale_value >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a rate value for a defined point on a pay scale.
 *
 * You can assign a rate (such as an amount for overtime) to an employee based
 * on their pay scale point. You can define a rate as a specific value or a
 * range of values.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The pay scale rate value must exist on the effective date of the delete.
 *
 * <p><b>Post Success</b><br>
 * The pay scale rate value will be deleted.
 *
 * <p><b>Post Failure</b><br>
 * The pay scale rate value will not be deleted and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force
 * @param p_datetrack_delete_mode Indicates which DateTrack mode to use when
 * deleting the record. You must set to either ZAP, DELETE, FUTURE_CHANGE or
 * DELETE_NEXT_CHANGE. Modes available for use with a particular record depend
 * on the dates of previous record changes and the effective date of this
 * change.
 * @param p_grade_rule_id Uniquely identifies the pay scale rate value to be
 * deleted.
 * @param p_object_version_number Current version number of the pay scale rate
 * value to be deleted.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date for the deleted pay scale rate value row which now
 * exists as of the effective date. If p_validate is true or all row instances
 * have been deleted then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the deleted pay scale rate value row which now exists
 * as of the effective date. If p_validate is true or all row instances have
 * been deleted then set to null.
 * @rep:displayname Delete Pay Scale Rate Value
 * @rep:category BUSINESS_ENTITY HR_PAY_SCALE
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_pay_scale_value
  (p_validate                      in            boolean  default false
  ,p_effective_date                in            date
  ,p_datetrack_delete_mode         in            varchar2
  ,p_grade_rule_id                 in            number
  ,p_object_version_number         in out nocopy number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  );
end hr_pay_scale_value_api;

 

/
