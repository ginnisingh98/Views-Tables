--------------------------------------------------------
--  DDL for Package PAY_AU_MODULES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_AU_MODULES_API" AUTHID CURRENT_USER as
/* $Header: pyamoapi.pkh 120.1 2005/10/02 02:45 aroussel $ */
/*#
 * This package contains module APIs for Australia.
 * @rep:scope public
 * @rep:product PAY
 * @rep:displayname Modules for Australia
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_au_module >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a module for Australia.
 *
 * This API creates an entry on the table that lists the modules used for
 * Australia Leave Liability process.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Payroll.
 *
 * <p><b>Prerequisites</b><br>
 * A business group for Australia legislation must be specified. A module type
 * must be specified.
 *
 * <p><b>Post Success</b><br>
 * The module will be sucessfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The module will not be created and an error will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_name The name for the module.
 * @param p_enabled_flag This flag indicates whether the module is classified
 * as enabled.
 * @param p_module_type_id {@rep:casecolumn PAY_AU_MODULE_TYPES.MODULE_TYPE_ID}
 * @param p_business_group_id The business group id for the module. It should
 * be a valid business group for Australia.
 * @param p_legislation_code The legislation code for the module. It should be
 * 'AU'.
 * @param p_description The description for the module.
 * @param p_package_name The package name for the module.
 * @param p_procedure_function_name The procedure function name for the module.
 * @param p_formula_name The formula name for the module.
 * @param p_module_id If p_validate is false, then this uniquely identifies the
 * module created. If p_validate is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created module. If p_validate is true, then the value
 * will be null.
 * @rep:displayname Create Module for Australia
 * @rep:category BUSINESS_ENTITY PAY_LEAVE_LIABILITY
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_au_module
  (p_validate                      in      boolean  default false,
   p_name                          in      varchar2,
   p_enabled_flag                  in      varchar2,
   p_module_type_id                in      number,
   p_business_group_id             in      number,
   p_legislation_code              in      varchar2,
   p_description                   in      varchar2,
   p_package_name                  in      varchar2,
   p_procedure_function_name       in      varchar2,
   p_formula_name                  in      varchar2,
   p_module_id                     out nocopy number,
   p_object_version_number         out nocopy number );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< delete_au_module >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a module record for Australia.
 *
 * This API deletes a row on the table that lists the modules used for
 * Australia Leave Liability process. A module cannot be deleted if it is
 * reference by a row in the table pay_au_process_modules or
 * pay_au_module_parameters.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Payroll.
 *
 * <p><b>Prerequisites</b><br>
 * The module should already exist.
 *
 * <p><b>Post Success</b><br>
 * The API deletes the module.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the module and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_module_id Unique identifier of the module being deleted.
 * @param p_object_version_number Current version number of the module to be
 * deleted.
 * @rep:displayname Delete Module for Australia
 * @rep:category BUSINESS_ENTITY PAY_LEAVE_LIABILITY
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_au_module
  (p_validate                      in      boolean  default false,
   p_module_id                     in      number,
   p_object_version_number         in      number);
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< update_au_module >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a module for Australia.
 *
 * This API updates a existing row on the table that lists the modules used for
 * Australia Leave Liability process.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Payroll.
 *
 * <p><b>Prerequisites</b><br>
 * The module should already exist.
 *
 * <p><b>Post Success</b><br>
 * The API updates the module.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the module and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_module_id Unique identifier of the module being updated.
 * @param p_name The name for the module.
 * @param p_enabled_flag This flag indicates whether the module is classified
 * as enabled.
 * @param p_module_type_id {@rep:casecolumn PAY_AU_MODULE_TYPES.MODULE_TYPE_ID}
 * @param p_business_group_id The business group id for the module. It should
 * be a valid business group for Australia.
 * @param p_legislation_code The legislation code for the module, it should be
 * 'AU'.
 * @param p_description The description for the module.
 * @param p_package_name The package name using for the module.
 * @param p_procedure_function_name The procedure function name for the module.
 * @param p_formula_name The formula name for the module.
 * @param p_object_version_number Pass in the current version number of the
 * module to be updated. When the API completes if p_validate is false, will be
 * set to the new version number of the updated module. If p_validate is true
 * will be set to the same value which was passed in.
 * @rep:displayname Update Module for Australia
 * @rep:category BUSINESS_ENTITY PAY_LEAVE_LIABILITY
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_au_module
  (p_validate                      in      boolean  default false,
   p_module_id                     in      number,
   p_name                          in      varchar2,
   p_enabled_flag                  in      varchar2,
   p_module_type_id                in      number,
   p_business_group_id             in      number,
   p_legislation_code              in      varchar2,
   p_description                   in      varchar2,
   p_package_name                  in      varchar2,
   p_procedure_function_name       in      varchar2,
   p_formula_name                  in      varchar2,
   p_object_version_number         in out  nocopy   number
  );
--
--
end pay_au_modules_api;

 

/
