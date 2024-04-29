--------------------------------------------------------
--  DDL for Package PAY_AU_MODULE_PARAMETERS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_AU_MODULE_PARAMETERS_API" AUTHID CURRENT_USER as
/* $Header: pyampapi.pkh 120.1 2005/10/02 02:45 aroussel $ */
/*#
 * This package contains module parameter APIs for Australia.
 * @rep:scope public
 * @rep:product PAY
 * @rep:displayname Module Parameters for Australia
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_au_module_parameter >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a module parameter for Australia.
 *
 * This API creates an entry on the table that lists the module parameters
 * using for Australia Leave Liability process.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Payroll.
 *
 * <p><b>Prerequisites</b><br>
 * A module must be specified.
 *
 * <p><b>Post Success</b><br>
 * The module parameter will be sucessfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The module parameter will not be created and an error will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_module_id {@rep:casecolumn PAY_AU_MODULES.MODULE_ID}
 * @param p_internal_name The internal name for the module parameter.
 * @param p_data_type The data type for the module parameter.
 * @param p_input_flag This flag indicates whether the module parameter is
 * classified as an input parameter.
 * @param p_context_flag This flag indicates whether the module parameter is
 * classified as a context parameter.
 * @param p_output_flag This flag indicates whether the module parameter is
 * classified as a output parameter.
 * @param p_result_flag This flag indicates whether the module parameter is
 * classified as a result parameter.
 * @param p_error_message_flag This flag indicates whether the module parameter
 * is classified as a error message parameter.
 * @param p_enabled_flag This flag indicates whether the module parameter is
 * classified as enabled.
 * @param p_function_return_flag This flag indicates whether the module
 * parameter is classified as a function return parameter.
 * @param p_external_name The external name for the module parameter.
 * @param p_database_item_name The database item name for the module parameter.
 * @param p_constant_value The constant value for the module parameter.
 * @param p_module_parameter_id If p_validate is false, then this uniquely
 * identifies the module parameter created. If p_validate is true, then set to
 * null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created module type. If p_validate is true, then the
 * value will be null.
 * @rep:displayname Create Module Parameter for Australia
 * @rep:category BUSINESS_ENTITY PAY_LEAVE_LIABILITY
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_au_module_parameter
  (p_validate                      in      boolean  default false,
   p_module_id                     in      number,
   p_internal_name                 in      varchar2,
   p_data_type                     in      varchar2,
   p_input_flag                    in      varchar2,
   p_context_flag                  in      varchar2,
   p_output_flag                   in      varchar2,
   p_result_flag                   in      varchar2,
   p_error_message_flag            in      varchar2,
   p_enabled_flag                  in      varchar2,
   p_function_return_flag          in      varchar2,
   p_external_name                 in      varchar2,
   p_database_item_name            in      varchar2,
   p_constant_value                in      varchar2,
   p_module_parameter_id           out nocopy number,
   p_object_version_number         out nocopy number );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_au_module_parameter >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a module parameter record for Australia.
 *
 * This API deletes a row on the table that lists the module parameters using
 * for Australia Leave Liability process.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Payroll.
 *
 * <p><b>Prerequisites</b><br>
 * The module parameter should already exist.
 *
 * <p><b>Post Success</b><br>
 * The API deletes the module parameter.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the module parameter and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_module_parameter_id Unique identifier of the module parameter being
 * deleted.
 * @param p_object_version_number Current version number of the module
 * parameter to be deleted.
 * @rep:displayname Delete Module Parameter for Australia
 * @rep:category BUSINESS_ENTITY PAY_LEAVE_LIABILITY
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_au_module_parameter
  (p_validate                      in      boolean  default false,
   p_module_parameter_id           in      number,
   p_object_version_number         in      number);
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_au_module_parameter >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a module parameter for Australia.
 *
 * This API updates a existing row on the table that lists the module
 * parameters using for Australia Leave Liability process.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Payroll.
 *
 * <p><b>Prerequisites</b><br>
 * The module parameter should already exist.
 *
 * <p><b>Post Success</b><br>
 * The API updates the module parameter.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the module parameter and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_module_parameter_id Unique identifier of the module parameter being
 * updated.
 * @param p_module_id {@rep:casecolumn PAY_AU_MODULES.MODULE_ID}
 * @param p_internal_name The internal name for the module parameter.
 * @param p_data_type The data type for the module parameter.
 * @param p_input_flag This flag indicates whether the module parameter is
 * classified as an input parameter.
 * @param p_context_flag This flag indicates whether the module parameter is
 * classified as a context parameter.
 * @param p_output_flag This flag indicates whether the module parameter is
 * classified as a output parameter.
 * @param p_result_flag This flag indicates whether the module parameter is
 * classified as a result parameter.
 * @param p_error_message_flag This flag indicates whether the module parameter
 * is classified as a error message parameter.
 * @param p_enabled_flag This flag indicates whether the module parameter is
 * classified as enabled.
 * @param p_function_return_flag This flag indicates whether the module
 * parameter is classified as a function return parameter.
 * @param p_external_name The external name for the module parameter.
 * @param p_database_item_name The database item name for the module parameter.
 * @param p_constant_value The constant value for the module parameter.
 * @param p_object_version_number Pass in the current version number of the
 * module parameter to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated module
 * parameter. If p_validate is true will be set to the same value which was
 * passed in.
 * @rep:displayname Update Module Parameter for Australia
 * @rep:category BUSINESS_ENTITY PAY_LEAVE_LIABILITY
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_au_module_parameter
  (p_validate                      in      boolean  default false,
   p_module_parameter_id           in      number,
   p_module_id                     in      number,
   p_internal_name                 in      varchar2,
   p_data_type                     in      varchar2,
   p_input_flag                    in      varchar2,
   p_context_flag                  in      varchar2,
   p_output_flag                   in      varchar2,
   p_result_flag                   in      varchar2,
   p_error_message_flag            in      varchar2,
   p_enabled_flag                  in      varchar2,
   p_function_return_flag          in      varchar2,
   p_external_name                 in      varchar2,
   p_database_item_name            in      varchar2,
   p_constant_value                in      varchar2,
   p_object_version_number         in out nocopy number
  );
--
--
end pay_au_module_parameters_api;

 

/
