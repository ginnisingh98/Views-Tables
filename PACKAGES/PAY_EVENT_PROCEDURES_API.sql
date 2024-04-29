--------------------------------------------------------
--  DDL for Package PAY_EVENT_PROCEDURES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_EVENT_PROCEDURES_API" AUTHID CURRENT_USER as
/* $Header: pyevpapi.pkh 120.2 2005/10/24 00:52:54 adkumar noship $*/
/*#
 * This package contains APIs for Event Procedures.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Event Procedure
*/
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_event_proc >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates an Event Procedure.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The event group to be deleted should exists.
 *
 * <p><b>Post Success</b><br>
 * The Event Procedure has been successfully created.
 *
 * <p><b>Post Failure</b><br>
 * If the column name argument is not a column on the table specified in the
 * table name argument, raise error HR_xxxx_INVALID_COLUMN_NAME.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_dated_table_id Identifies the dated table.
 * @param p_procedure_name Procedure name
 * @param p_business_group_id Business Group of the Record.
 * @param p_legislation_code Legislation Code
 * @param p_column_name Has to be a column on the dated table. Out Parameters:
 * Name Type Description
 * @param p_event_procedure_id Primary Key of the record.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created event procedure. If p_validate is true, then
 * the value will be null.
 * @rep:displayname Create Event Procedure
 * @rep:category BUSINESS_ENTITY PAY_PAYROLL_TABLE_REC_EVENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_event_proc
  (p_validate                       in            boolean  default false
  ,p_dated_table_id                 in            number
  ,p_procedure_name                 in            varchar2 default null
  ,p_business_group_id              in            number   default null
  ,p_legislation_code               in            varchar2 default null
  ,p_column_name                    in            varchar2 default null
  ,p_event_procedure_id                out nocopy number
  ,p_object_version_number             out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_event_proc >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an Event Procedure.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The event procedure to be updated should exists.
 *
 * <p><b>Post Success</b><br>
 * The Event Procedure has been successfully updated.
 *
 * <p><b>Post Failure</b><br>
 * If the column name argument is not a column on the table specified in the
 * table name argument, raise error HR_xxxx_INVALID_COLUMN_NAME.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_event_procedure_id Primary Key of the record.
 * @param p_object_version_number Pass in the current version number of the
 * event procedure to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated event procedure.
 * If p_validate is true will be set to the same value which was passed in.
 * @param p_dated_table_id Identifies the dated table.
 * @param p_procedure_name Procedure name
 * @param p_business_group_id Business Group of the Record.
 * @param p_legislation_code Legislation Code
 * @param p_column_name Has to be a column on the dated table. Out Parameters:
 * Name Type Description
 * @rep:displayname Update Event Procedure
 * @rep:category BUSINESS_ENTITY PAY_PAYROLL_TABLE_REC_EVENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
Procedure update_event_proc
  (p_validate                     in            boolean   default false
  ,p_event_procedure_id           in            number
  ,p_object_version_number        in out nocopy number
  ,p_dated_table_id               in            number    default hr_api.g_number
  ,p_procedure_name               in            varchar2  default hr_api.g_varchar2
  ,p_business_group_id            in            number    default hr_api.g_number
  ,p_legislation_code             in            varchar2  default hr_api.g_varchar2
  ,p_column_name                  in            varchar2  default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_event_proc >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes an Event Procedure.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The event procedure to be deleted should exists.
 *
 * <p><b>Post Success</b><br>
 * The Event Procedure has been successfully deleted.
 *
 * <p><b>Post Failure</b><br>
 * An error will be raised and the Event Procedure will not be deleted.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_event_procedure_id Primary Key of the record.
 * @param p_object_version_number Pass in the current version number of the
 * Event Group to be deleted. When the API completes if p_validate is false,
 * will be set to the new version number of the deleted Event Group. If
 * p_validate is true will be set to the same value which was passed in.
 * @rep:displayname Delete Event Procedure
 * @rep:category BUSINESS_ENTITY PAY_PAYROLL_TABLE_REC_EVENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
Procedure delete_event_proc
  (
   p_validate                             in     boolean  default false
  ,p_event_procedure_id                   in     number
  ,p_object_version_number                in out nocopy number
  );
--
end pay_event_procedures_api;
--

 

/
