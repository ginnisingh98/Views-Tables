--------------------------------------------------------
--  DDL for Package FF_FUNCTION_PARAMETERS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FF_FUNCTION_PARAMETERS_API" AUTHID CURRENT_USER as
/* $Header: ffffpapi.pkh 120.1.12010000.2 2008/08/05 10:20:39 ubhat ship $ */
/*#
 * This package is used to Create, Update and Delete the  parameters
 * of a Formula Function.
 * @rep:scope public
 * @rep:product pay
 * @rep:displayname Parameters of a Formula Function
*/
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_parameter >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This Business Process is used to insert definitions for the parameters
 * of a specific Formula function.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Oracle Payroll.
 *
 * <p><b>Prerequisites</b><br>
 * The specified Formula Function should exist.
 *
 * <p><b>Post Success</b><br>
 * The Formula Function Parameter will be successfully inserted into the
 * database and all the out parameter will be set.
 *
 * <p><b>Post Failure</b><br>
 * The Formula Function Parameter will not be created and appropriate error
 * message wiil be prompted.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_function_id Formula Function ID.
 * @param p_class Identifies whether the parameter is an IN parameter, an OUT
 * parameter, or an IN-OUT parameter.
 * @param p_data_type Data type of the parameter.
 * @param p_name Name of the parameter.
 * @param p_optional 'N' if the parameter is mandatory, else Y.
 * @param p_continuing_parameter Y if there can be one or more of the
 * parameter, else N.
 * @param p_sequence_number Identifies Number for each parameter in a
 * specific sequence.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created event procedure. If p_validate is true, then
 * the value will be null.
 * @rep:displayname Create Parameter For A Formula Function
 * @rep:category BUSINESS_ENTITY FF_FORMULA_FUNCTION
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}

procedure create_parameter
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_function_id                   in     number
  ,p_class                         in     varchar2
  ,p_data_type                     in     varchar2
  ,p_name                          in     varchar2
  ,p_optional                      in     varchar2 default 'N'
  ,p_continuing_parameter          in     varchar2 default 'N'
  ,p_sequence_number                  out nocopy   number
  ,p_object_version_number            out nocopy   number
  );
-- ----------------------------------------------------------------------------
-- |-----------------------------< update_parameter >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This Business Process is used to update definitions of the parameters
 * of a specific Formula function.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Oracle Payroll.
 *
 * <p><b>Prerequisites</b><br>
 * The parameters of a specific Formula function to be updated should exist.
 * The Formula Function is specified, then it should exist.
 *
 * <p><b>Post Success</b><br>
 * The Formula Function Parameter will be successfully updated into the
 * database and all the out parameter will be set.
 *
 * <p><b>Post Failure</b><br>
 * The Formula Function Parameter will not be updated and appropriate error
 * message wiil be prompted.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_function_id Formula Function ID
 * @param p_sequence_number Identifies Number for each parameter in a
 * specific sequence.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created event procedure. If p_validate is true, then
 * the value will be null.
 * @param p_class Identifies whether the parameter is an IN parameter,an OUT
 * parameter, or an IN-OUT parameter.
 * @param p_data_type Data type of the parameter.
 * @param p_name Name of the parameter.
 * @param p_optional 'N' if the parameter is mandatory, else Y.
 * @param p_continuing_parameter 'Y' if there can be one or more of the
 * parameter, else 'N'.
 * @rep:displayname Update Parameter Of a Formula Function.
 * @rep:category BUSINESS_ENTITY FF_FORMULA_FUNCTION
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_parameter
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_function_id                   in     number
  ,p_sequence_number               in     number
  ,p_object_version_number         in out nocopy   number
  ,p_class                         in     varchar2 default hr_api.g_varchar2
  ,p_data_type                     in     varchar2 default hr_api.g_varchar2
  ,p_name                          in     varchar2 default hr_api.g_varchar2
  ,p_optional                      in     varchar2 default hr_api.g_varchar2
  ,p_continuing_parameter          in     varchar2 default hr_api.g_varchar2
  );
-- ----------------------------------------------------------------------------
-- |-----------------------------< delete_parameter >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This Business Process is used to delete definitions of the parameters
 * of a specific Formula function.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Oracle Payroll
 *
 * <p><b>Prerequisites</b><br>
 * The parameters of a specific Formula function to be deleted should exist.
 *
 * <p><b>Post Success</b><br>
 * Specified Parameter of the Formula Function will be deleted.
 *
 * <p><b>Post Failure</b><br>
 * Error Messages will be raised if any business rule is violated and the
 * Formula Function Parameter will not be deleted.
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
 * @rep:displayname Delete Parameter Of A Formula Function
 * @rep:category BUSINESS_ENTITY FF_FORMULA_FUNCTION
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_parameter
  (p_validate                      in     boolean  default false
  ,p_function_id                   in     number
  ,p_sequence_number               in     number
  ,p_object_version_number         in     number
  );

--
end FF_FUNCTION_PARAMETERS_API;

/
