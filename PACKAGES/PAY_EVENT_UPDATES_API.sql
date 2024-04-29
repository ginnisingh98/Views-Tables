--------------------------------------------------------
--  DDL for Package PAY_EVENT_UPDATES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_EVENT_UPDATES_API" AUTHID CURRENT_USER as
/* $Header: pypeuapi.pkh 120.1 2005/10/02 02:32:43 aroussel $ */
/*#
 * This package contains APIs for Event Updates.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Event Update
*/
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_event_update >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates an Event Update.
 *
 * Event Updates are child rows of Dated Tables and are used in the Capture
 * phase of the Payroll Events Model.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The business group where this record to be created should exist.
 *
 * <p><b>Post Success</b><br>
 * The Event Update has been successfully created.
 *
 * <p><b>Post Failure</b><br>
 * If the change type argument is not a recognisable value for the lookup type
 * PROCESS_EVENT_TYPE, then raise error HR_xxxx_INVALID_CHANGE_TYPE. Also if
 * the event type argument is not a recognisable value for the lookup type
 * EVENT_TYPE, then raise error HR_xxxx_INVALID_EVENT_TYPE.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_dated_table_id Dated Table
 * @param p_change_type Taken from PROCESS_EVENT_TYPE lookup
 * @param p_table_name Dated Table Name.
 * @param p_column_name Mandatory only if update_type ='UPDATE'. Should be a
 * column name off the dated table.
 * @param p_business_group_id Business Group of the Record.
 * @param p_legislation_code Legislation Code
 * @param p_event_type Taken from EVENT_TYPE lookup. Out Parameters: Name Type
 * Description
 * @param p_event_update_id If p_validate is false, this uniquely identifies
 * the created even update. If p_validate is set to true, this parameter will
 * be null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created event update. If p_validate is true, then the
 * value will be null.
 * @rep:displayname Create Event Update
 * @rep:category BUSINESS_ENTITY PAY_PAYROLL_TABLE_REC_EVENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_event_update
  (
   p_validate                       in     boolean default false
  ,p_effective_date               in     date
  ,p_dated_table_id                 in     number
  ,p_change_type                    in     varchar2
  ,p_table_name                     in     varchar2 default null
  ,p_column_name                    in     varchar2 default null
  ,p_business_group_id              in     number   default null
  ,p_legislation_code               in     varchar2 default null
  ,p_event_type                     in     varchar2 default null
  ,p_event_update_id                   out nocopy number
  ,p_object_version_number             out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_event_update >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an Event Update.
 *
 * Event Updates are child rows of Dated Tables and are used in the Capture
 * phase of the Payroll Events Model.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The event update to be updated should exist.
 *
 * <p><b>Post Success</b><br>
 * The Event Update has been successfully updated.
 *
 * <p><b>Post Failure</b><br>
 * If the change type argument is not a recognisable value for the lookup type
 * PROCESS_EVENT_TYPE, then raise error HR_xxxx_INVALID_CHANGE_TYPE. Also if
 * the event type argument is not a recognisable value for the lookup type
 * EVENT_TYPE, then raise error HR_xxxx_INVALID_EVENT_TYPE.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_event_update_id Primary Key of the record.
 * @param p_object_version_number Pass in the current version number of the
 * event update to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated event update. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_dated_table_id Dated Table
 * @param p_change_type Taken from PROCESS_EVENT_TYPE lookup
 * @param p_table_name Dated Table Name.
 * @param p_column_name Mandatory only if update_type ='UPDATE'. Should be a
 * column name of the dated table.
 * @param p_business_group_id Business Group of the Record.
 * @param p_legislation_code Legislation Code
 * @param p_event_type Taken from EVENT_TYPE lookup. Out Parameters Name Type
 * Description/Valid Values
 * @rep:displayname Update Event Update
 * @rep:category BUSINESS_ENTITY PAY_PAYROLL_TABLE_REC_EVENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_event_update
  (
   p_validate                       in     boolean default false
  ,p_effective_date               in     date
  ,p_event_update_id              in     number
  ,p_object_version_number        in out nocopy number
  ,p_dated_table_id               in     number    default hr_api.g_number
  ,p_change_type                  in     varchar2  default hr_api.g_varchar2
  ,p_table_name                   in     varchar2  default hr_api.g_varchar2
  ,p_column_name                  in     varchar2  default hr_api.g_varchar2
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_legislation_code             in     varchar2  default hr_api.g_varchar2
  ,p_event_type                   in     varchar2  default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_event_update >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes an Event Update.
 *
 * Event Updates are child rows of Dated Tables and are used in the Capture
 * phase of the Payroll Events Model.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The event update to be deleted should exist.
 *
 * <p><b>Post Success</b><br>
 * The Event Update has been successfully deleted.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the event update and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_event_update_id Primary Key of the record.
 * @param p_object_version_number Pass in the current version number of the
 * Event Update to be deleted. When the API completes if p_validate is false,
 * will be set to the new version number of the deleted Event Update. If
 * p_validate is true will be set to the same value which was passed in.
 * @rep:displayname Delete Event Update
 * @rep:category BUSINESS_ENTITY PAY_PAYROLL_TABLE_REC_EVENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_event_update
  (
   p_validate                       in     boolean default false
  ,p_event_update_id                      in     number
  ,p_object_version_number                in     number
  );
end pay_event_updates_api;

 

/
