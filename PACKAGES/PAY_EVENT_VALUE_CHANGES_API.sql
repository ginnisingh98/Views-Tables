--------------------------------------------------------
--  DDL for Package PAY_EVENT_VALUE_CHANGES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_EVENT_VALUE_CHANGES_API" AUTHID CURRENT_USER as
/* $Header: pyevcapi.pkh 120.1 2005/10/02 02:31:07 aroussel $ */
/*#
 * This package contains APIs for Event Value Changes.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Event Value Change
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_event_value_change >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates event value changes.
 *
 * Enforcing the required business rules. Event Value Changes Extend on Event
 * Qualifiers to further qualify Datetracked Events. These provide an optional
 * advanced qualifying mechanism These are used in the Interpretation phase of
 * the Payroll Events Model.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The business group where this record to be created should exist. Also the
 * datetracked event and the event qualifier should exist for the same business
 * group.
 *
 * <p><b>Post Success</b><br>
 * The Event Value Change has been successfully created.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the event value change and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_event_qualifier_id The seeded qualifier for which this change
 * details are relevant
 * @param p_default_event A flag stating if this row gives the default
 * behaviour for all value changes related to this qualifier.
 * @param p_valid_event A flag stating if this change causes the owning event
 * to be valid and therefore recalculated.
 * @param p_datetracked_event_id The event that these changes relate
 * @param p_business_group_id Business Group of the Record.
 * @param p_legislation_code Legislation Code
 * @param p_from_value The original value
 * @param p_to_value The new value which has resulted
 * @param p_proration_style Type of proration to be pursued. (Usually null,
 * French localisation)
 * @param p_qualifier_value Exact value of qualifier
 * @param p_event_value_change_id If p_validate is false, this uniquely
 * identifies the value change created. If p_validate is set to true, this
 * parameter will be null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created event value change. If p_validate is true,
 * then the value will be null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective end date for the created Value Change. If p_validate is true, then
 * set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created Value Change row which now exists as of
 * the effective date. If p_validate is true or all row instances have been
 * deleted then set to null.
 * @rep:displayname Create Event Value Change
 * @rep:category BUSINESS_ENTITY PAY_PAYROLL_EVENT_GROUP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
Procedure create_event_value_change
  (p_validate                       in     boolean  default false
  ,p_effective_date                 in     date
  ,p_event_qualifier_id             in     number
  ,p_default_event                  in     varchar2
  ,p_valid_event                    in     varchar2
  ,p_datetracked_event_id           in     number   default null
  ,p_business_group_id              in     number   default null
  ,p_legislation_code               in     varchar2 default null
  ,p_from_value                     in     varchar2 default null
  ,p_to_value                       in     varchar2 default null
  ,p_proration_style                in     varchar2 default null
  ,p_qualifier_value                in     varchar2 default null
  ,p_event_value_change_id             out nocopy number
  ,p_object_version_number             out nocopy number
  ,p_effective_start_date              out nocopy date
  ,p_effective_end_date                out nocopy date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_event_value_change >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an Event Value Change.
 *
 * Enforcing the required business rules. Event Value Changes Extend on Event
 * Qualifiers to further qualify Datetracked Events. These provide an optional
 * advanced qualifying mechanism These are used in the Interpretation phase of
 * the Payroll Events Model.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The event value change as identified by the in parameters
 * event_value_change_id and p_object_version_number.
 *
 * <p><b>Post Success</b><br>
 * The Event Qualifier has been successfully updated.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the event value change and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_datetrack_mode Indicates which DateTrack mode to use when updating
 * the record. You must set to either UPDATE, CORRECTION, UPDATE_OVERRIDE or
 * UPDATE_CHANGE_INSERT. Modes available for use with a particular record
 * depend on the dates of previous record changes and the effective date of
 * this change.
 * @param p_event_qualifier_id The seeded qualifier for which this change
 * details are relevant
 * @param p_default_event A flag stating if this row gives the default
 * behaviour for all value changes related to this qualifier.
 * @param p_valid_event A flag stating if this change causes the owning event
 * to be valid and therefore recalculated.
 * @param p_datetracked_event_id The event that to which these changes relate
 * @param p_business_group_id Business Group of the Record.
 * @param p_legislation_code Legislation Code
 * @param p_from_value The original value
 * @param p_to_value The new value which has resulted
 * @param p_proration_style Type of proration to be pursued. (Usually null,
 * French localisation)
 * @param p_qualifier_value Exact value of qualifier
 * @param p_event_value_change_id Identifier of the event value change being
 * deleted.
 * @param p_object_version_number Pass in the current version number of the
 * event value change to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated event value
 * change. If p_validate is true will be set to the same value which was passed
 * in.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective end date for the updated Value Change. If p_validate is true, then
 * set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the updated Value Change row which now exists as of
 * the effective date. If p_validate is true or all row instances have been
 * deleted then set to null.
 * @rep:displayname Update Event Value Change
 * @rep:category BUSINESS_ENTITY PAY_PAYROLL_EVENT_GROUP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_event_value_change
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_event_qualifier_id           in     number
  ,p_default_event                in     varchar2
  ,p_valid_event                  in     varchar2
  ,p_datetracked_event_id         in     number   default hr_api.g_number
  ,p_business_group_id            in     number   default hr_api.g_number
  ,p_legislation_code             in     varchar2 default hr_api.g_varchar2
  ,p_from_value                   in     varchar2 default hr_api.g_varchar2
  ,p_to_value                     in     varchar2 default hr_api.g_varchar2
  ,p_proration_style              in     varchar2 default hr_api.g_varchar2
  ,p_qualifier_value              in     varchar2 default hr_api.g_varchar2
  ,p_event_value_change_id        in     number
  ,p_object_version_number        in out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_event_value_change >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes an event value change.
 *
 * Enforcing the required business rules. Event Value Changes Extend on Event
 * Qualifiers to further qualify Datetracked Events. These provide an optional
 * advanced qualifying mechanism These are used in the Interpretation phase of
 * the Payroll Events Model.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The event value change as identified by the in parameters
 * p_event_value_change_id and p_object_version_number must already exist.
 *
 * <p><b>Post Success</b><br>
 * The Event Value Change has been successfully deleted.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the event value change and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_datetrack_mode Indicates which DateTrack mode to use when deleting
 * the record. You must set to either ZAP, DELETE, FUTURE_CHANGE or
 * DELETE_NEXT_CHANGE. Modes available for use with a particular record depend
 * on the dates of previous record changes and the effective date of this
 * change.
 * @param p_event_value_change_id Identifier of the event value change being
 * deleted.
 * @param p_object_version_number Pass in the current version number of the
 * Event Value Change to be deleted to be deleted. When the API completes if
 * p_validate is false, will be set to the new version number of the deleted
 * Event Value Change to be deleted. If p_validate is true will be set to the
 * same value which was passed in.
 * @param p_business_group_id Business Group of the Record.
 * @param p_legislation_code Legislation Code
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective end date for the deleted Value Change If p_validate is true, then
 * set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the deleted Value Change row which now exists as of
 * the effective date. If p_validate is true or all row instances have been
 * deleted then set to null.
 * @rep:displayname Delete Event Value Change
 * @rep:category BUSINESS_ENTITY PAY_PAYROLL_EVENT_GROUP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_event_value_change
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_mode                in     varchar2
  ,p_event_value_change_id         in     number
  ,p_object_version_number         in out nocopy number
  ,p_business_group_id             in     number   default hr_api.g_number
  ,p_legislation_code              in     varchar2 default hr_api.g_varchar2
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  );
--

end pay_event_value_changes_api;

 

/
