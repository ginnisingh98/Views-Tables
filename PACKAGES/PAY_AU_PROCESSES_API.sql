--------------------------------------------------------
--  DDL for Package PAY_AU_PROCESSES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_AU_PROCESSES_API" AUTHID CURRENT_USER as
/* $Header: pyaprapi.pkh 120.1 2005/10/02 02:45 aroussel $ */
/*#
 * This package contains process APIs for Australia.
 * @rep:scope public
 * @rep:product PAY
 * @rep:displayname Processes for Australia
*/
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_au_process >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a process for Australia.
 *
 * This API creates an entry on the table that lists the processes using for
 * Australia Leave Liability process.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Payroll.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * The process will be sucessfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The process will not be created and an error will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_short_name The short name for the process.
 * @param p_name The name for the process.
 * @param p_enabled_flag This flag indicates whether the process is classified
 * as enabled.
 * @param p_business_group_id The business group id for the process. It should
 * be a valid business group for Australia.
 * @param p_legislation_code The legislation code for the process.
 * @param p_description The description for the process.
 * @param p_accrual_category The accrual plan category used for the process.
 * @param p_process_id If p_validate is false, then this uniquely identifies
 * the process created. If p_validate is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created process. If p_validate is true, then the value
 * will be null.
 * @rep:displayname Create Process for Australia
 * @rep:category BUSINESS_ENTITY PAY_LEAVE_LIABILITY
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_au_process
  (p_validate                      in      boolean  default false,
   p_short_name                    in      varchar2,
   p_name                          in      varchar2,
   p_enabled_flag                  in      varchar2,
   p_business_group_id             in      number,
   p_legislation_code              in      varchar2   default null,
   p_description                   in      varchar2   default null,
   p_accrual_category              in      varchar2   default null,
   p_process_id                    out nocopy number,
   p_object_version_number         out nocopy number );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_au_process >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a process record for Australia.
 *
 * This API deletes a row on the table that lists the processes using for
 * Australia Leave Liability process. A process cannot be deleted if it is
 * reference by a row in the table pay_au_process_modules or
 * pay_au_process_parameters.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Payroll.
 *
 * <p><b>Prerequisites</b><br>
 * The process should already exist.
 *
 * <p><b>Post Success</b><br>
 * The API deletes the process.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the process and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_process_id Unique identifier of the process being deleted.
 * @param p_object_version_number Current version number of the process to be
 * deleted.
 * @rep:displayname Delete Process for Australia
 * @rep:category BUSINESS_ENTITY PAY_LEAVE_LIABILITY
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_au_process
  (p_validate                      in      boolean  default false,
   p_process_id                    in      number,
   p_object_version_number         in      number);
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_au_process >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a process for Australia.
 *
 * This API updates a existing row on the table that lists the processes using
 * for Australia Leave Liability process.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Payroll.
 *
 * <p><b>Prerequisites</b><br>
 * The process should already exist.
 *
 * <p><b>Post Success</b><br>
 * The API updates the process.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the process and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_process_id Unique identifier of the process being updated.
 * @param p_short_name The short name for the process.
 * @param p_name The name for the process.
 * @param p_enabled_flag This flag indicates whether the process is classified
 * as enabled.
 * @param p_business_group_id The business group id for the process. It should
 * be a valid business group for Australia.
 * @param p_legislation_code The legislation code for the process. It should be
 * 'AU'.
 * @param p_description The description for the process.
 * @param p_accrual_category The accrual plan category used for the process.
 * @param p_object_version_number Pass in the current version number of the
 * process to be updated. When the API completes if p_validate is false, will
 * be set to the new version number of the updated process. If p_validate is
 * true will be set to the same value which was passed in.
 * @rep:displayname Update Process for Australia
 * @rep:category BUSINESS_ENTITY PAY_LEAVE_LIABILITY
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_au_process
  (p_validate                      in      boolean  default false,
   p_process_id                    in      number,
   p_short_name                    IN      varchar2,
   p_name                          IN      varchar2,
   p_enabled_flag                  IN      varchar2,
   p_business_group_id             IN      number,
   p_legislation_code              IN      varchar2,
   p_description                   IN      varchar2,
   p_accrual_category              IN      varchar2,
   p_object_version_number         in out  nocopy   number
  );
--
--
end pay_au_processes_api;

 

/
