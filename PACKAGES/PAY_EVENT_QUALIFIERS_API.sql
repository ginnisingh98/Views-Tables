--------------------------------------------------------
--  DDL for Package PAY_EVENT_QUALIFIERS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_EVENT_QUALIFIERS_API" AUTHID CURRENT_USER as
/* $Header: pyevqapi.pkh 120.1 2005/10/02 02:31:23 aroussel $ */
/*#
 * This package contains APIs for Event Qualifiers.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Event Qualifiers
*/
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_event_qualifier >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates an Event Qualifier.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The business group where this record to be created should exist.
 *
 * <p><b>Post Success</b><br>
 * The Event Qualifier has been successfully created.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the event qualifier and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_dated_table_id The table for which this qualifier is relevant.
 * @param p_column_name The column for which this qualifier is relevant.
 * @param p_qualifier_name The name of this event qualifier.
 * @param p_legislation_code Legislation Code
 * @param p_business_group_id Business Group of the Record.
 * @param p_comparison_column The column for which this qualifier is relevant.
 * (In SQL syntax)
 * @param p_qualifier_definition The explicit details of the qualifier
 * @param p_qualifier_where_clause The explicit details of the dynamic query
 * clause.
 * @param p_entry_qualification {@rep:casecolumn
 * PAY_EVENT_QUALIFIERS_F.ENTRY_QUALIFICATION}
 * @param p_assignment_qualification {@rep:casecolumn
 * PAY_EVENT_QUALIFIERS_F.ASSIGNMENT_QUALIFICATION}
 * @param p_multi_event_sql SQL to find multiple
 * @param p_event_qualifier_id If p_validate is false, this uniquely identifies
 * the event qualifier created. If p_validate is set to true, this parameter
 * will be null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created Event Qualifier. If p_validate is true, then
 * the value will be null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created Event Qualifier. If p_validate
 * is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created Event Qualifier. If p_validate is true,
 * then set to null.
 * @rep:displayname Create Event Qualifier
 * @rep:category BUSINESS_ENTITY PAY_PAYROLL_EVENT_GROUP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
Procedure create_event_qualifier
  (p_validate                       in     boolean  default false
  ,p_effective_date                 in     date
  ,p_dated_table_id                 in     number
  ,p_column_name                    in     varchar2
  ,p_qualifier_name                 in     varchar2
  ,p_legislation_code               in     varchar2 default null
  ,p_business_group_id              in     number   default null
  ,p_comparison_column              in     varchar2 default null
  ,p_qualifier_definition           in     varchar2 default null
  ,p_qualifier_where_clause         in     varchar2 default null
  ,p_entry_qualification            in     varchar2 default null
  ,p_assignment_qualification       in     varchar2 default null
  ,p_multi_event_sql                in     varchar2 default null
  ,p_event_qualifier_id                out nocopy number
  ,p_object_version_number             out nocopy number
  ,p_effective_start_date              out nocopy date
  ,p_effective_end_date                out nocopy date
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_event_qualifier >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an Event Qualifier.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The event qualifier as identified by the in parameters event_qualifier_id
 * and p_object_version_number.
 *
 * <p><b>Post Success</b><br>
 * The Event Qualifier has been successfully updated.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the event qualifiers and raises an error.
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
 * @param p_event_qualifier_id Primary Key of the record.
 * @param p_dated_table_id The table for which this qualifier is relevant.
 * @param p_column_name The column for which this qualifier is relevant.
 * @param p_qualifier_name The name of this event qualifier.
 * @param p_object_version_number Pass in the current version number of the
 * Event Qualifier to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated Event Qualifier.
 * If p_validate is true will be set to the same value which was passed in.
 * @param p_legislation_code Legislation Code
 * @param p_business_group_id Business Group of the Record
 * @param p_comparison_column The column for which this qualifier is relevant.
 * (In SQL syntax)
 * @param p_qualifier_definition The explicit details of the qualifier
 * @param p_qualifier_where_clause The explicit details of the dynamic query
 * clause.
 * @param p_entry_qualification {@rep:casecolumn
 * PAY_EVENT_QUALIFIERS_F.ENTRY_QUALIFICATION}
 * @param p_assignment_qualification {@rep:casecolumn
 * PAY_EVENT_QUALIFIERS_F.ASSIGNMENT_QUALIFICATION}
 * @param p_multi_event_sql SQL to find multiple
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated Event Qualifier row which now exists as
 * of the effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated Event Qualifier row which now exists as of
 * the effective date. If p_validate is true, then set to null.
 * @rep:displayname Update Event Qualifier
 * @rep:category BUSINESS_ENTITY PAY_PAYROLL_EVENT_GROUP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_event_qualifier
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_event_qualifier_id           in     number
  ,p_dated_table_id               in     number
  ,p_column_name                  in     varchar2
  ,p_qualifier_name               in     varchar2
  ,p_object_version_number        in out nocopy number
  ,p_legislation_code             in     varchar2  default hr_api.g_varchar2
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_comparison_column            in     varchar2  default hr_api.g_varchar2
  ,p_qualifier_definition         in     varchar2  default hr_api.g_varchar2
  ,p_qualifier_where_clause       in     varchar2  default hr_api.g_varchar2
  ,p_entry_qualification          in     varchar2  default hr_api.g_varchar2
  ,p_assignment_qualification     in     varchar2  default hr_api.g_varchar2
  ,p_multi_event_sql              in     varchar2  default hr_api.g_varchar2
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_event_qualifier >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes an Event Qualifier.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The event qualifier as identified by the in parameters p_event_qualifier_id
 * and p_object_version_number must already exist.
 *
 * <p><b>Post Success</b><br>
 * The Event Qualifier has been successfully deleted.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the event qualifier and raises an error.
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
 * @param p_event_qualifier_id Identifier of the event qualifier being deleted.
 * @param p_object_version_number Pass in the current version number of the
 * event qualifier to be deleted. When the API completes if p_validate is
 * false, will be set to the new version number of the deleted event qualifier.
 * If p_validate is true will be set to the same value which was passed in.
 * @param p_business_group_id Business Group of the Record
 * @param p_legislation_code Legislation Code
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date for the deleted Event Qualifier row which now exists as
 * of the effective date. If p_validate is true or all row instances have been
 * deleted then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the deleted Event Qualifier row which now exists as
 * of the effective date. If p_validate is true or all row instances have been
 * deleted then set to null.
 * @rep:displayname Delete Event Qualifier
 * @rep:category BUSINESS_ENTITY PAY_PAYROLL_EVENT_GROUP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_event_qualifier
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_delete_mode         in     varchar2
  ,p_event_qualifier_id            in     number
  ,p_object_version_number         in out nocopy number
  ,p_business_group_id             in     number   default hr_api.g_number
  ,p_legislation_code              in     varchar2 default hr_api.g_varchar2
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  );
--

end pay_event_qualifiers_api;

 

/
