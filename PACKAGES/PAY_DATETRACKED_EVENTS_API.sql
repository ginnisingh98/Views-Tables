--------------------------------------------------------
--  DDL for Package PAY_DATETRACKED_EVENTS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_DATETRACKED_EVENTS_API" AUTHID CURRENT_USER as
/* $Header: pydteapi.pkh 120.1 2005/10/02 02:30:27 aroussel $ */
/*#
 * This package contains APIs for Datetracked Events.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname DateTrack Events
*/
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_datetracked_event >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates Datetracked Events.
 *
 * Created Datetracked Events will then be used by the event model.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Requires an event group and a datetracked table.
 *
 * <p><b>Post Success</b><br>
 * The datetracked event has been successfully created.
 *
 * <p><b>Post Failure</b><br>
 * If the column argument is not a column on the dated table we are trying to
 * create, then raise error HR_xxxx_INVALID_COLUMN_NAME. Also if the
 * update_type is not a recognisable value for the lookup type UPDATE_TYPE,
 * then raise error HR_xxxx_INVALID_UPDATE_TYPE.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_event_group_id Proration Group.
 * @param p_dated_table_id Dated Table
 * @param p_update_type Taken from UPDATE_TYPE lookup.
 * @param p_column_name Mandatory only if update_type ='UPDATE'. Should be a
 * column name of the dated table.
 * @param p_business_group_id Business Group of the Record.
 * @param p_legislation_code Legislation Code
 * @param p_proration_style Proration Style Out Parameters: Name Type
 * Description
 * @param p_datetracked_event_id {@rep:casecolumn
 * PAY_DATETRACKED_EVENTS.DATETRACKED_EVENT_ID}
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created datetracked event. If p_validate is true, then
 * the value will be null.
 * @rep:displayname Create DateTrack Event
 * @rep:category BUSINESS_ENTITY PAY_PAYROLL_EVENT_GROUP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_datetracked_event
  (
   p_validate                       in     boolean default false
  ,p_effective_date               in     date
  ,p_event_group_id                 in     number
  ,p_dated_table_id                 in     number
  ,p_update_type                    in     varchar2
  ,p_column_name                    in     varchar2
  ,p_business_group_id              in     number
  ,p_legislation_code               in     varchar2
  ,p_proration_style                in     varchar2 default null
  ,p_datetracked_event_id           out nocopy number
  ,p_object_version_number          out nocopy number
  ) ;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_datetracked_event >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a datetracked event.
 *
 * The updated datetracked event will be used by the event model.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The datetracked event to be updated should exists.
 *
 * <p><b>Post Success</b><br>
 * The datetracked event has been successfully updated.
 *
 * <p><b>Post Failure</b><br>
 * If the column argument is not a column on the dated table we are trying to
 * create, then raise error HR_xxxx_INVALID_COLUMN_NAME. Also if the
 * update_type is not a recognisable value for the lookup type UPDATE_TYPE,
 * then raise error HR_xxxx_INVALID_UPDATE_TYPE.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_datetracked_event_id Primary Key of the record.
 * @param p_object_version_number Pass in the current version number of the
 * datetracked event to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated datetracked
 * event. If p_validate is true will be set to the same value which was passed
 * in.
 * @param p_event_group_id Proration Group.
 * @param p_dated_table_id Dated Table
 * @param p_update_type Taken from UPDATE_TYPE lookup.
 * @param p_column_name Mandatory only if update_type ='UPDATE'. Should be a
 * column name of the dated table.
 * @param p_business_group_id Business Group of the Record.
 * @param p_legislation_code Legislation Code
 * @param p_proration_style Proration Style
 * @rep:displayname Update DateTrack Event
 * @rep:category BUSINESS_ENTITY PAY_PAYROLL_EVENT_GROUP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_datetracked_event
  (
   p_validate                       in     boolean default false
  ,p_effective_date               in     date
  ,p_datetracked_event_id         in     number
  ,p_object_version_number        in out nocopy number
  ,p_event_group_id               in     number    default hr_api.g_number
  ,p_dated_table_id               in     number    default hr_api.g_number
  ,p_update_type                  in     varchar2  default hr_api.g_varchar2
  ,p_column_name                  in     varchar2  default hr_api.g_varchar2
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_legislation_code             in     varchar2  default hr_api.g_varchar2
  ,p_proration_style              in     varchar2  default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_datetracked_event >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a datetracked event.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The datetracked event to be deleted should exists.
 *
 * <p><b>Post Success</b><br>
 * The event group has been successfully deleted.
 *
 * <p><b>Post Failure</b><br>
 * An error will be raised and the Datetracked Event will not be deleted.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_datetracked_event_id Primary Key of the record.
 * @param p_object_version_number Pass in the current version number of the
 * Datetracked Event to be deleted. When the API completes if p_validate is
 * false, will be set to the new version number of the deleted Datetracked
 * Event. If p_validate is true will be set to the same value which was passed
 * in.
 * @rep:displayname Delete DateTrack Event
 * @rep:category BUSINESS_ENTITY PAY_PAYROLL_EVENT_GROUP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_datetracked_event
  (
   p_validate                       in     boolean default false
  ,p_datetracked_event_id                 in     number
  ,p_object_version_number                in     number
  );
--
end pay_datetracked_events_api;
--

 

/
