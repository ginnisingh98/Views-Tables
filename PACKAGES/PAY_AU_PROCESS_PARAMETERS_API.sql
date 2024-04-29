--------------------------------------------------------
--  DDL for Package PAY_AU_PROCESS_PARAMETERS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_AU_PROCESS_PARAMETERS_API" AUTHID CURRENT_USER as
/* $Header: pyappapi.pkh 120.1 2005/10/02 02:45 aroussel $ */
/*#
 * This package contains process parameter APIs for Australia.
 * @rep:scope public
 * @rep:product PAY
 * @rep:displayname Process Parameters for Australia
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_au_process_parameter >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a process parameter for Australia.
 *
 * This API creates an entry on the table that lists the process parameters
 * using for Australia Leave Liability process.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Payroll.
 *
 * <p><b>Prerequisites</b><br>
 * A process must be specified.
 *
 * <p><b>Post Success</b><br>
 * The process parameter will be sucessfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The process parameter will not be created and an error will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_process_id {@rep:casecolumn PAY_AU_PROCESSES.PROCESS_ID}
 * @param p_internal_name The internal name for the process parameter.
 * @param p_data_type The data type for the process parameter.
 * @param p_enabled_flag This flag indicates whether the process parameter is
 * classified as enabled.
 * @param p_process_parameter_id If p_validate is false, then this uniquely
 * identifies the process parameter created. If p_validate is true, then set to
 * null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created process parameter. If p_validate is true, then
 * the value will be null.
 * @rep:displayname Create Process Parameter for Australia
 * @rep:category BUSINESS_ENTITY PAY_LEAVE_LIABILITY
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_au_process_parameter
  (p_validate                      in      boolean  default false,
   p_process_id                    in      number,
   p_internal_name                 in      varchar2,
   p_data_type                     in      varchar2,
   p_enabled_flag                  in      varchar2,
   p_process_parameter_id          out nocopy number,
   p_object_version_number         out nocopy number );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_au_process_parameter >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a process parameter record for Australia.
 *
 * This API deletes a row on the table that lists the process parameters using
 * for Australia Leave Liability process.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Payroll.
 *
 * <p><b>Prerequisites</b><br>
 * The process parameter should already exist.
 *
 * <p><b>Post Success</b><br>
 * The API deletes the process parameter.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the process parameter and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_process_parameter_id Unique identifier of the process parameter
 * being deleted.
 * @param p_object_version_number Current version number of the process
 * parameter to be deleted.
 * @rep:displayname Delete Process Parameter for Australia
 * @rep:category BUSINESS_ENTITY PAY_LEAVE_LIABILITY
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_au_process_parameter
  (p_validate                      in      boolean  default false,
   p_process_parameter_id          in      number,
   p_object_version_number         in      number);
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_au_process_parameter >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a process parameter record for Australia.
 *
 * This API updates a existing row on the table that lists the process
 * parameters using for Australia Leave Liability process.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Payroll.
 *
 * <p><b>Prerequisites</b><br>
 * The process parameter should already exist.
 *
 * <p><b>Post Success</b><br>
 * The API updates the process parameter.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the process parameter and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_process_parameter_id Unique identifier of the process parameter
 * being updated.
 * @param p_process_id {@rep:casecolumn PAY_AU_PROCESSES.PROCESS_ID}
 * @param p_internal_name The internal name for the process parameter.
 * @param p_data_type The data type for the process parameter.
 * @param p_enabled_flag This flag indicates whether the process parameter is
 * classified as enabled.
 * @param p_object_version_number Pass in the current version number of the
 * process parameter to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated process
 * parameter. If p_validate is true will be set to the same value which was
 * passed in.
 * @rep:displayname Update Process Parameter for Australia
 * @rep:category BUSINESS_ENTITY PAY_LEAVE_LIABILITY
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_au_process_parameter
  (p_validate                      in      boolean  default false,
   p_process_parameter_id          in      number,
   p_process_id                    in      number,
   p_internal_name                 IN      varchar2,
   p_data_type                     IN      varchar2,
   p_enabled_flag                  IN      varchar2,
   p_object_version_number         in out  nocopy   number
  );
--
--
end pay_au_process_parameters_api;

 

/
