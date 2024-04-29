--------------------------------------------------------
--  DDL for Package PAY_AU_PROCESS_MODULES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_AU_PROCESS_MODULES_API" AUTHID CURRENT_USER as
/* $Header: pyapmapi.pkh 120.1 2005/10/02 02:45 aroussel $ */
/*#
 * This package contains process module APIs for Australia.
 * @rep:scope public
 * @rep:product PAY
 * @rep:displayname Process Modules for Australia
*/
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_au_process_module >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a process module for Australia.
 *
 * This API creates an entry on the table that lists the process modules using
 * for Australia Leave Liability process.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Payroll.
 *
 * <p><b>Prerequisites</b><br>
 * A process must be specified. A module must be specified.
 *
 * <p><b>Post Success</b><br>
 * The process module will be sucessfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The process module will not be created and an error will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_process_id {@rep:casecolumn PAY_AU_PROCESSES.PROCESS_ID}
 * @param p_module_id {@rep:casecolumn PAY_AU_MODULES.MODULE_ID}
 * @param p_process_sequence The process sequence for the process module.
 * @param p_enabled_flag This flag indicates whether the process module is
 * classified as enabled.
 * @param p_process_module_id If p_validate is false, then this uniquely
 * identifies the process module created. If p_validate is true, then set to
 * null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created process module. If p_validate is true, then
 * the value will be null.
 * @rep:displayname Create Process Module for Australia
 * @rep:category BUSINESS_ENTITY PAY_LEAVE_LIABILITY
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_au_process_module
  (p_validate                      in      boolean  default false,
   p_process_id                    in      number,
   p_module_id                     in      number,
   p_process_sequence              in      number,
   p_enabled_flag                  in      varchar2,
   p_process_module_id             out nocopy number,
   p_object_version_number         out nocopy number );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_au_process_module >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a process module record for Australia.
 *
 * This API deletes a row on the table that lists the process modules using for
 * Australia Leave Liability process.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Payroll.
 *
 * <p><b>Prerequisites</b><br>
 * The process module should already exist.
 *
 * <p><b>Post Success</b><br>
 * The API deletes the process module.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the process module and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_process_module_id Unique identifier of the process module being
 * deleted.
 * @param p_object_version_number Current version number of the process module
 * to be deleted.
 * @rep:displayname Delete Process Module for Australia
 * @rep:category BUSINESS_ENTITY PAY_LEAVE_LIABILITY
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_au_process_module
  (p_validate                      in      boolean  default false,
   p_process_module_id             in      number,
   p_object_version_number         in      number);
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_au_process_module >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a process module record for Australia.
 *
 * This API updates a existing row on the table that lists the process modules
 * using for Australia Leave Liability process.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Payroll.
 *
 * <p><b>Prerequisites</b><br>
 * The process module should already exist.
 *
 * <p><b>Post Success</b><br>
 * The API updates the process module.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the process module and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_process_module_id Unique identifier of the process module being
 * updated.
 * @param p_process_id {@rep:casecolumn PAY_AU_PROCESSES.PROCESS_ID}
 * @param p_module_id {@rep:casecolumn PAY_AU_MODULES.MODULE_ID}
 * @param p_process_sequence The process sequence for the process module.
 * @param p_enabled_flag This flag indicates whether the process module is
 * classified as enabled.
 * @param p_object_version_number Pass in the current version number of the
 * process module to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated process module. If
 * p_validate is true will be set to the same value which was passed in.
 * @rep:displayname Update Process Module for Australia
 * @rep:category BUSINESS_ENTITY PAY_LEAVE_LIABILITY
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_au_process_module
  (p_validate                      in      boolean  default false,
   p_process_module_id             in      number,
   p_process_id                    in      number,
   p_module_id                     in      number,
   p_process_sequence              in      number,
   p_enabled_flag                  IN      varchar2,
   p_object_version_number         in out  nocopy   number
  );
--
--
end pay_au_process_modules_api;

 

/
