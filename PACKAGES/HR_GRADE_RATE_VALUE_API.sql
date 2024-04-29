--------------------------------------------------------
--  DDL for Package HR_GRADE_RATE_VALUE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_GRADE_RATE_VALUE_API" AUTHID CURRENT_USER as
/* $Header: pygrrapi.pkh 120.1 2005/10/02 02:31:40 aroussel $ */
/*#
 * This package contains APIs that will maintain rate values for grades.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Grade Rate Value
*/
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_grade_rate_value >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a grade rate value for a grade.
 *
 * You can assign a rate (such as an amount for overtime) to an employee based
 * on their grade. You can define a rate as a specific value or a range of
 * values.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * When creating a rate value for a grade, a grade must exist on the start date
 * of the rate value.
 *
 * <p><b>Post Success</b><br>
 * A grade rate value will be created.
 *
 * <p><b>Post Failure</b><br>
 * A grade rate value will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force
 * @param p_rate_id If p_validate is false, uniquely identifies the rate value
 * id created. If p_validate is true, set to null.
 * @param p_grade_id The grade for which this rate value applies
 * @param p_currency_code For pay rates that have the unit of 'MONEY', this
 * parameter must be set to a value from the column
 * FND_CURRENCIES.CURRENCY_CODE.
 * @param p_maximum The maximum value allowed for the rate value.
 * @param p_mid_value The median value for the rate value. This does not have
 * to be the mean of the minimum and maximum value, it can take any value
 * between the two extremes.
 * @param p_minimum The minimum value allowed for the rate value.
 * @param p_value The explicit value for the rate value. Must be set if the
 * minimum and maximum values are not set.
 * @param p_sequence Must be set to the sequence of the grade to which the rate
 * value is attached.
 * @param p_grade_rule_id If p_validate is false, uniquely identifies the grade
 * rate value created. If p_validate is true, set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created grade rate value. If p_validate is true, then
 * the value will be null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created grade rate value. If
 * p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created grade rate value. If p_validate is true,
 * then set to null.
 * @rep:displayname Create Grade Rate Value
 * @rep:category BUSINESS_ENTITY PER_GRADE
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_grade_rate_value
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_rate_id                       in     number
  ,p_grade_id                      in     number
  ,p_currency_code		   in 	  varchar2 default null
  ,p_maximum                       in     varchar2 default null
  ,p_mid_value                     in     varchar2 default null
  ,p_minimum                       in     varchar2 default null
  ,p_value                         in     varchar2 default null
  ,p_sequence                      in     number   default null
  ,p_grade_rule_id                    out nocopy number
  ,p_object_version_number            out nocopy number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_grade_rate_value >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a grade rate value for a grade.
 *
 * You can assign a rate (such as an amount for overtime) to an employee based
 * on their grade. You can define a rate as a specific value or a range of
 * values.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The grade rate value must exist on the effective date of the update.
 *
 * <p><b>Post Success</b><br>
 * The grade rate value will be updated.
 *
 * <p><b>Post Failure</b><br>
 * The grade rate value will not be updated and an error will be raised.
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
 * @param p_grade_rule_id Uniquely identifies the grade rate value to be
 * updated.
 * @param p_currency_code For pay rates that have the unit of 'MONEY', this
 * parameter must be set to a value from the column
 * FND_CURRENCIES.CURRENCY_CODE.
 * @param p_object_version_number Pass in the current version number of the
 * grade rate value to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated grade rate
 * value. If p_validate is true will be set to the same value which was passed
 * in.
 * @param p_maximum The maximum value allowed for the rate value.
 * @param p_mid_value The median value for the rate value. This does not have
 * to be the mean of the minimum and maximum value, it can take any value
 * between the two extremes.
 * @param p_minimum The minimum value allowed for the rate value.
 * @param p_value The explicit value for the rate value. Must be set if the
 * minimum and maximum values are not set.
 * @param p_sequence Must be set to the sequence of the grade to which the rate
 * value is attached.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated grade rate value row which now exists as
 * of the effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated grade rate value row which now exists as
 * of the effective date. If p_validate is true, then set to null.
 * @rep:displayname Update Grade Rate Value
 * @rep:category BUSINESS_ENTITY PER_GRADE
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_grade_rate_value
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_update_mode         in     varchar2
  ,p_grade_rule_id                 in     number
  ,p_currency_code		   in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy number
  ,p_maximum                       in     varchar2 default hr_api.g_varchar2
  ,p_mid_value                     in     varchar2 default hr_api.g_varchar2
  ,p_minimum                       in     varchar2 default hr_api.g_varchar2
  ,p_value                         in     varchar2 default hr_api.g_varchar2
  ,p_sequence                      in     number   default hr_api.g_number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_grade_rate_value >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * The API deletes a grade rate value for a grade.
 *
 * You can assign a rate (such as an amount for overtime) to an employee based
 * on their grade. You can define a rate as a specific value or a range of
 * values.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The grade rate value must exist on the effective date of the delete.
 *
 * <p><b>Post Success</b><br>
 * The grade rate value will be deleted.
 *
 * <p><b>Post Failure</b><br>
 * The grade rate value will not be deleted and an error will be raised.
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
 * @param p_grade_rule_id Uniquely identifies the grade rate value to be
 * deleted.
 * @param p_object_version_number Current version number of the grade rate
 * value to be deleted.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date for the deleted grade rate value row which now exists
 * as of the effective date. If p_validate is true or all row instances have
 * been deleted then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the deleted grade rate value row which now exists as
 * of the effective date. If p_validate is true or all row instances have been
 * deleted then set to null.
 * @rep:displayname Delete Grade Rate Value
 * @rep:category BUSINESS_ENTITY PER_GRADE
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_grade_rate_value
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_delete_mode         in     varchar2
  ,p_grade_rule_id                 in     number
  ,p_object_version_number         in out nocopy number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  );
end hr_grade_rate_value_api;

 

/
