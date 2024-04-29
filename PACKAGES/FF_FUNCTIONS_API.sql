--------------------------------------------------------
--  DDL for Package FF_FUNCTIONS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FF_FUNCTIONS_API" AUTHID CURRENT_USER as
/* $Header: ffffnapi.pkh 120.1.12010000.2 2008/08/05 10:20:27 ubhat ship $ */
/*#
 * This package is used to Create, Update and Delete Formula Function.
 * @rep:scope public
 * @rep:product pay
 * @rep:displayname Formula Functions
*/
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_function >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This Business Process is used to create Formula Function.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Oracle Payroll.
 *
 * <p><b>Prerequisites</b><br>
 * The specified business group, legislation code should exist.
 *
 * <p><b>Post Success</b><br>
 *  The Formula Function will be successfully Created in the database and
 *  all the out parameter will be set.
 *
 * <p><b>Post Failure</b><br>
 *  Error Messages will be raised if any business rule is violated and the
 *  Formula Function will not created.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_name The name of the function.
 * @param p_class Class of function determined by where it is defined.
 * @param p_business_group_id Business Group ID.
 * @param p_legislation_code Legislation Code.
 * @param p_alias_name Alternative name for the function.
 * @param p_data_type Data type of function or null for procedure.
 * @param p_definition Name of the PL/SQL package and function stored in the
 * database.
 * @param p_description Description of the function.
 * @param p_function_id Unique identifer for function.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created event procedure. If p_validate is true, then
 * the value will be null.
 * @rep:displayname Create Formula Function
 * @rep:category BUSINESS_ENTITY FF_FORMULA_FUNCTION
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_function
  (p_validate                      in      boolean  default false
  ,p_effective_date                in      date
  ,p_name                          in      varchar2
  ,p_class                         in      varchar2
  ,p_business_group_id              in     number   default null
  ,p_legislation_code               in     varchar2 default null
  ,p_alias_name                     in     varchar2 default null
  ,p_data_type                      in     varchar2 default null
  ,p_definition                     in     varchar2 default null
  ,p_description                    in     varchar2 default null
  ,p_function_id                       out nocopy number
  ,p_object_version_number             out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< update_function >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This Business Process will be used to update Formula function.
 *
  * <p><b>Licensing</b><br>
 * This API is licensed for use with Oracle Payroll
 *
 * <p><b>Prerequisites</b><br>
 * The specified Formula Function should exist.
 *
 * <p><b>Post Success</b><br>
 * The Formula Function will be successfully updated into the database and
 * all the out parameter will be set.
 *
 * <p><b>Post Failure</b><br>
 * Error Messages will be  raised if any business rule is violated and the Formula
 * Function will not updated.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_function_id Unique identifer for function
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created event procedure. If p_validate is true, then
 * the value will be null.
 * @param p_name The name of the function.
 * @param p_class Class of function determined by where it is defined.
 * @param p_alias_name Alternative name for the function.
 * @param p_data_type Data type of function or null for procedure.
 * @param p_definition Name of the PL/SQL package and function stored in the
 * database.
 * @param p_description Description of the function.
 * @rep:displayname Update Formula Function
 * @rep:category BUSINESS_ENTITY FF_FORMULA_FUNCTION
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_function
  (p_validate                     in      boolean  default false
  ,p_effective_date               in      date
  ,p_function_id                  in     number
  ,p_object_version_number        in out nocopy number
  ,p_name                         in     varchar2  default hr_api.g_varchar2
  ,p_class                        in     varchar2  default hr_api.g_varchar2
  ,p_alias_name                   in     varchar2  default hr_api.g_varchar2
  ,p_data_type                    in     varchar2  default hr_api.g_varchar2
  ,p_definition                   in     varchar2  default hr_api.g_varchar2
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< delete_function >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This Business Process will be used to Delete Formula function.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Oracle Payroll.
 *
 * <p><b>Prerequisites</b><br>
 * The specified Formula Function must exist.
 *
 * <p><b>Post Success</b><br>
 * The Formula Function will be successfully deleted from the database.
 *
 * <p><b>Post Failure</b><br>
 * Error Messages will be raised if any business rule is violated and the
 * Formula Function will not deleted.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_function_id Unique identifer for function
 * @param p_object_version_number  If p_validate is false, then set to the
 * version number of the created event procedure. If p_validate is true, then
 * the value will be null.
 * @rep:displayname Delete Formula Function
 * @rep:category BUSINESS_ENTITY FF_FORMULA_FUNCTION
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
--
procedure delete_function
  (p_validate                     in      boolean  default false
  ,p_function_id                  in      number
  ,p_object_version_number        in      number
  );
--

end FF_FUNCTIONS_API;

/
