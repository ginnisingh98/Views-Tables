--------------------------------------------------------
--  DDL for Package FF_FUNCTION_CONTEXT_USG_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FF_FUNCTION_CONTEXT_USG_API" AUTHID CURRENT_USER as
/* $Header: fffcuapi.pkh 120.1.12010000.2 2008/08/05 10:20:06 ubhat ship $ */
/*#
 * This package is used to Create, Update and Delete the Context Usages
 * to a Formula Function.
 * @rep:scope public
 * @rep:product pay
 * @rep:displayname Context Usages For Formula Functions
*/
-- ----------------------------------------------------------------------------
-- |------------------------------< create_context >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API is used to Create Context Usages to a specific Formula function.
 *
  * <p><b>Licensing</b><br>
 * This API is licensed for use with Oracle Payroll.
 *
 * <p><b>Prerequisites</b><br>
 * The specified Formula Function should exist.
 *
 * <p><b>Post Success</b><br>
 * A Context Usage to the specified Formula Function will be created and
 * the out parameters will be set.
 *
 * <p><b>Post Failure</b><br>
 * Context Usage to the specified Formula function will not be created
 * and appropriate error message will be prompted.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_function_id Formula Function ID.
 * @param p_context_id Formula Function Context.
 * @param p_sequence_number Identifies Number for each parameter in a
 * specific sequence.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created event procedure. If p_validate is true, then
 * the value will be null.
 * @rep:displayname Create Context Usage to a Formula Function
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
procedure create_context
  (p_validate                      in     boolean  default false
  ,p_function_id                   in     number
  ,p_context_id                    in     number
  ,p_sequence_number                  out nocopy   number
  ,p_object_version_number            out nocopy   number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_context >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This Business Process will be used to update Context Usages of a specific
 * Formula function.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Oracle Payroll.
 *
 * <p><b>Prerequisites</b><br>
 * The Context Usage of the specific Formula Function should exist.
 *
 * <p><b>Post Success</b><br>
 * The Context Usage of the specified Formula will be successfully updated
 * into the database and all the parameter will be set.
 *
 * <p><b>Post Failure</b><br>
 * Error Messages will be raised if any business rule is violated and the
 * specified Context Usage will not be updated.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_function_id Formula Function ID.
 * @param p_sequence_number Identifies Number for each parameter in a
 * specific sequence.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created event procedure. If p_validate is true, then
 * the value will be null.
 * @param p_context_id Formula Function Context.
 * @rep:displayname Update Context Usage
 * @rep:category BUSINESS_ENTITY FF_FORMULA_FUNCTION
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_context
  (p_validate                      in     boolean  default false
  ,p_function_id                   in     number
  ,p_sequence_number               in     number
  ,p_object_version_number         in out nocopy   number
  ,p_context_id                    in     number   default hr_api.g_number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_context >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This Business Process will be used to delete Context Usage of a specific
 * Formula function.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Oracle Payroll.
 *
 * <p><b>Prerequisites</b><br>
 * The Context Usage of the specific Formula Function should exist.
 *
 * <p><b>Post Success</b><br>
 * The Context Usage of the specified Formula Function will be
 * successfully deleted from the database.
 *
 * <p><b>Post Failure</b><br>
 * Error Messages are raised if any business rule is violated and the Formula
 * Function Context Usage will not be deleted.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_function_id Formula Function ID.
 * @param p_sequence_number Identifies Number for each parameter in a
 * specific sequence.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created event procedure. If p_validate is true, then
 * the value will be null.
 *
 * @rep:displayname Delete Context Usage
 * @rep:category BUSINESS_ENTITY FF_FORMULA_FUNCTION
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--

procedure delete_context
  (p_validate                      in     boolean  default false
  ,p_function_id                   in     number
  ,p_sequence_number               in     number
  ,p_object_version_number         in     number
  );

--
end FF_FUNCTION_CONTEXT_USG_API;

/
