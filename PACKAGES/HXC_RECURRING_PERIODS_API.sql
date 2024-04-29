--------------------------------------------------------
--  DDL for Package HXC_RECURRING_PERIODS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_RECURRING_PERIODS_API" AUTHID CURRENT_USER as
/* $Header: hxchrpapi.pkh 120.1 2005/10/02 02:06:51 aroussel $ */
/*#
 * This package contains Recurring Periods APIs.
 * @rep:scope public
 * @rep:product hxt
 * @rep:displayname Recurring Period
*/
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_recurring_periods >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates the Recurring Periods required by the Time Store.
 *
 * The Recurring Periods created here are used across the OTL application as
 * Timecard Periods, Approval Periods, and overtime Recurring Periods.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Time and Labor.
 *
 * <p><b>Prerequisites</b><br>
 * The table PER_TIME_PERIOD_TYPES should have been created.
 *
 * <p><b>Post Success</b><br>
 * The Recurring Periods will be successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The Recurring Periods will not be created and an application error will be
 * raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_recurring_period_id Primary Key of the new Recurring Periods.
 * @param p_object_version_number If P_VALIDATE is false, then set the version
 * number of the created Recurring Periods. If P_VALIDATE is true, then the
 * value will be null.
 * @param p_name Name of the Recurring Periods.
 * @param p_period_type Select a Period Type if it is a Recurring Periods.
 * @param p_duration_in_days Duration of a period. For example, the number of
 * days in the Recurring Periods.
 * @param p_start_date Start Date for the Recurring Periods.
 * @param p_end_date End Date for the Recurring Periods.
 * @param p_effective_date Not used in the Create API. Passed in as NULL.
 * @rep:displayname Create Recurring Period
 * @rep:category BUSINESS_ENTITY HXC_TIMECARD_RECURRING_PERIOD
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_recurring_periods
  (p_validate                      in     boolean  default false
  ,p_recurring_period_id           in out nocopy number
  ,p_object_version_number         in out nocopy number
  ,p_name                          in     varchar2
  ,p_period_type                   in     varchar2 default null
  ,p_duration_in_days              in     number   default null
  ,p_start_date                    in     date
  ,p_end_date                      in     date     default null
  ,p_effective_date                in     date     default null
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_recurring_periods >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an existing Recurring Periods.
 *
 * The updates created are valid, irrespective of any dates determining when
 * the change took place.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Time and Labor.
 *
 * <p><b>Prerequisites</b><br>
 * The Recurring Periods must exist.
 *
 * <p><b>Post Success</b><br>
 * The Recurring Periods will be updated successfully in the database.
 *
 * <p><b>Post Failure</b><br>
 * The Recurring Periods will not be updated and an application error will be
 * raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_recurring_period_id Primary Key for entity.
 * @param p_object_version_number Pass in the current version number of the
 * Recurring Periods to be updated. When the API completes, if P_VALIDATE is
 * false, then this will be set to the new version number of the updated
 * Recurring Periods. If P_VALIDATE is true, then this will be set to the same
 * value that was passed.
 * @param p_name Name of the Recurring Periods.
 * @param p_period_type Update a Period Type if it is a Recurring Periods and
 * its Period Type needs to be changed.
 * @param p_duration_in_days Duration of a period.
 * @param p_start_date Start Date for the Recurring Periods.
 * @param p_end_date End Date for the Recurring Periods.
 * @param p_effective_date Not used.
 * @rep:displayname Update Recurring Period
 * @rep:category BUSINESS_ENTITY HXC_TIMECARD_RECURRING_PERIOD
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_recurring_periods
  (p_validate                      in     boolean  default false
  ,p_recurring_period_id           in     number
  ,p_object_version_number         in out nocopy number
  ,p_name                          in     varchar2
  ,p_period_type                   in     varchar2 default null
  ,p_duration_in_days              in     number   default null
  ,p_start_date                    in     date     default null
  ,p_end_date                      in     date     default null
  ,p_effective_date                in     date     default null
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_recurring_periods >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes an existing Recurring Periods.
 *
 * There is a check which verifies if the Recurring Periods being deleted is a
 * system data or a period that is being referenced across the OTL application.
 * If yes, the deletion of the Recurring Periods will not be allowed.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Time and Labor.
 *
 * <p><b>Prerequisites</b><br>
 * The Recurring Periods must exist.
 *
 * <p><b>Post Success</b><br>
 * The Recurring Periods will be successfully deleted from the database.
 *
 * <p><b>Post Failure</b><br>
 * The Recurring Periods will not be deleted and an application error will be
 * raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_recurring_period_id Primary Key for entity.
 * @param p_object_version_number Current version number of the Recurring
 * Periods to be deleted.
 * @rep:displayname Delete Recurring Period
 * @rep:category BUSINESS_ENTITY HXC_TIMECARD_RECURRING_PERIOD
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_recurring_periods
  (p_validate                       in  boolean  default false
  ,p_recurring_period_id            in  number
  ,p_object_version_number          in  number
  );
--
--
END hxc_recurring_periods_api;

 

/
