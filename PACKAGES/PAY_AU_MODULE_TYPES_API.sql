--------------------------------------------------------
--  DDL for Package PAY_AU_MODULE_TYPES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_AU_MODULE_TYPES_API" AUTHID CURRENT_USER as
/* $Header: pyamtapi.pkh 120.1 2005/10/02 02:45 aroussel $ */
/*#
 * This package contains module type APIs for Australia.
 * @rep:scope public
 * @rep:product PAY
 * @rep:displayname Module Types for Australia
*/
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_au_module_type >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a module type for Australia.
 *
 * This API creates an entry on the table that lists the module types using for
 * Australia Leave Liability process.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Payroll.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * The module type will be sucessfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The module type will not be created and an error will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_name The name for the module type.
 * @param p_enabled_flag This flag indicates whether the module type is
 * classified as enabled.
 * @param p_description The description for the module type.
 * @param p_module_type_id If p_validate is false, then this uniquely
 * identifies the module type created. If p_validate is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created module type. If p_validate is true, then the
 * value will be null.
 * @rep:displayname Create Module Type for Australia
 * @rep:category BUSINESS_ENTITY PAY_LEAVE_LIABILITY
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_au_module_type
  (p_validate                      in      boolean  default false,
   p_name                          in      varchar2,
   p_enabled_flag                  in      varchar2,
   p_description                   in      varchar2   default null,
   p_module_type_id                out nocopy number,
   p_object_version_number         out nocopy number );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_au_module_type >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a module type record for Australia.
 *
 * This API deletes a row on the table that lists the module types using for
 * Australia Leave Liability process. A module type cannot be deleted if it is
 * reference by a row in the pay_au_modules table.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Payroll.
 *
 * <p><b>Prerequisites</b><br>
 * The module type should already exist.
 *
 * <p><b>Post Success</b><br>
 * The API deletes the module type.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the module type and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_module_type_id Unique identifier of the module type being deleted.
 * @param p_object_version_number Current version number of the module type to
 * be deleted.
 * @rep:displayname Delete Module Type for Australia
 * @rep:category BUSINESS_ENTITY PAY_LEAVE_LIABILITY
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_au_module_type
  (p_validate                      in      boolean  default false,
   p_module_type_id                in      number,
   p_object_version_number         in      number);
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_au_module_type >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a module type for Australia.
 *
 * This API updates a existing row on the table that lists the module types
 * using for Australia Leave Liability process.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Payroll.
 *
 * <p><b>Prerequisites</b><br>
 * The module type should already exist.
 *
 * <p><b>Post Success</b><br>
 * The API updates the module type.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the module type and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_module_type_id Unique identifier of the module type being updated.
 * @param p_name The name for the module type.
 * @param p_enabled_flag This flag indicates whether the module type is
 * classified as enabled.
 * @param p_description The description for the module type.
 * @param p_object_version_number Pass in the current version number of the
 * module type to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated module type. If
 * p_validate is true will be set to the same value which was passed in.
 * @rep:displayname Update Module Type for Australia
 * @rep:category BUSINESS_ENTITY PAY_LEAVE_LIABILITY
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_au_module_type
  (p_validate                      in      boolean  default false,
   p_module_type_id                in      number,
   p_name                          IN      varchar2,
   p_enabled_flag                  IN      varchar2,
   p_description                   IN      varchar2,
   p_object_version_number         in out  nocopy   number
  );
--
--
end pay_au_module_types_api;

 

/
