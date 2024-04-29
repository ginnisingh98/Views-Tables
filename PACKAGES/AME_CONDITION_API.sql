--------------------------------------------------------
--  DDL for Package AME_CONDITION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_CONDITION_API" AUTHID CURRENT_USER as
/* $Header: amconapi.pkh 120.2 2006/12/23 09:58:45 avarri noship $ */
/*#
 * This package contains the AME Condition APIs.
 * @rep:scope public
 * @rep:product AME
 * @rep:displayname Condition
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------< CREATE_AME_CONDITION >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new condition.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * No known prerequisites.
 *
 * <p><b>Post Success</b><br>
 * The condition is created.
 *
 * <p><b>Post Failure</b><br>
 * The condition is not created and an error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and
 * the database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified. Default value is False.
 * @param p_condition_key The unique key of the condition.
 * @param p_condition_type This indicates the type of the condition.
 * The AME_CONDITION_LOOKUP lookup type defines valid values.
 * @param p_attribute_id This uniquely identifies the attribute on which the
 * condition is based. This parameter is mandatory for ordinary and exception
 * conditions. It is not required for list modification conditions.
 * @param p_parameter_one For date, number and currency attributes
 * this parameter contains the lower limit. For boolean attributes this
 * parameter will be either 'true' or 'false'. For string attributes this
 * parameter will be null. For list modification conditions this parameter
 * indicates the approver order.
 * @param p_parameter_two For date, number and currency attributes
 * this parameter contains the upper limit. For boolean and string attributes
 * this parameter will be null. For list modification conditions
 * this parameter contains the role name.
 * @param p_parameter_three This parameter is used for conditions that
 * are based on currency attributes. For these conditions this parameter
 * contains the currency code. For other conditions it will be null.
 * @param p_include_upper_limit Indicates whether the upper limit is inclusive.
 * Valid for the conditions based on number, date and currency attributes.
 * @param p_include_lower_limit Indicates whether the lower limit is
 * inclusive. Valid for the conditions based on number, date and
 * currency attributes.
 * @param p_string_value This parameter contains the allowed string value
 * for string attributes.
 * @param p_condition_id If p_validate is false, then this uniquely identifies
 * the condition created. If p_validate is true, then it is set to null.
 * @param p_con_start_date If p_validate is false, then it is set to the
 * effective start date for the created condition. If p_validate is true,
 * then it is set to null.
 * @param p_con_end_date It is the date up to, which the condition is
 * effective. If p_validate is false, then it is set to 31-Dec-4712.
 * If p_validate is true, then it is set to null.
 * @param p_con_object_version_number If p_validate is false, then it is set
 * to version number of the created condition. If p_validate is true,
 * then it is set to null.
 * @param p_stv_start_date If p_validate is false, then it is set to the
 * effective start date for the created string value. If p_validate is true,
 * then it is set to null. Set only when string value is created.
 * @param p_stv_end_date It is the date up to, which the string value is
 * effective. If p_validate is false, then it is set to 31-Dec-4712.
 * If p_validate is true, then it is set to null. Set only when string value
 * is created.
 * @param p_stv_object_version_number If p_validate is false, then it is
 * set to version number of the created string value. If p_validate is true,
 * then it is set to null. Set only when string value is created.
 * @rep:displayname Create Ame Condition
 * @rep:category BUSINESS_ENTITY AME_CONDITION
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
*/
--
-- {End Of Comments}
--
procedure create_ame_condition
  (p_validate                  in     boolean  default false
  ,p_condition_key             in     varchar2
  ,p_condition_type            in     varchar2
  ,p_attribute_id              in     number   default null
  ,p_parameter_one             in     varchar2 default null
  ,p_parameter_two             in     varchar2 default null
  ,p_parameter_three           in     varchar2 default null
  ,p_include_upper_limit       in     varchar2 default null
  ,p_include_lower_limit       in     varchar2 default null
  ,p_string_value              in     varchar2 default null
  ,p_condition_id                 out nocopy   number
  ,p_con_start_date               out nocopy   date
  ,p_con_end_date                 out nocopy   date
  ,p_con_object_version_number    out nocopy   number
  ,p_stv_start_date               out nocopy   date
  ,p_stv_end_date                 out nocopy   date
  ,p_stv_object_version_number    out nocopy   number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------<UPDATE_AME_CONDITION >---------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the given condition.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * The condition id should be valid.
 *
 * <p><b>Post Success</b><br>
 * The given condition is updated.
 *
 * <p><b>Post Failure</b><br>
 * The condition is not updated and an error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified. Default value is False.
 * @param p_condition_id This uniquely identifies the condition to be updated.
 * @param p_parameter_one For date, number and currency attributes
 * this parameter contains the lower limit.
 * For boolean attributes this parameter will be either 'true' or 'false'.
 * For string attributes this parameter will be null.
 * For list modification conditions this parameter indicates the approver order.
 * @param p_parameter_two For date, number and currency attributes
 * this parameter contains the upper limit.
 * For boolean and string attributes this parameter will be null.
 * For list modification conditions this parameter contains the role name.
 * @param p_parameter_three This parameter is used for conditions that are
 * based on currency attributes. For these conditions this parameter contains
 * the currency code. For other conditions it will be null.
 * @param p_include_upper_limit Indicates whether the upper limit is inclusive.
 * Valid for the conditions based on number, date and currency attributes.
 * @param p_include_lower_limit Indicates whether the lower limit is inclusive.
 * Valid for the conditions based on number, date and currency attributes.
 * @param p_object_version_number Pass in the current version number of the
 * condition to be updated. When the API completes, if p_validate is false,
 * it will be set to the new version number of the updated condition. If
 * p_validate is true, will be set to the same value which was passed in.
 * @param p_start_date If p_validate is false, it is set to present date.
 * If p_validate is true, it is set to the same date which was passed in.
 * @param p_end_date It is the date up to, which the updated condition is
 * effective. If p_validate is false, it is set to 31-Dec-4712.
 * If p_validate is true, it is set to the same date which was passed in.
 * @rep:displayname Update Ame Condition
 * @rep:category BUSINESS_ENTITY AME_CONDITION
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
*/
--
-- {End Of Comments}
--
procedure update_ame_condition
  (p_validate                    in     boolean  default false
  ,p_condition_id                in     number
  ,p_parameter_one               in     varchar2 default hr_api.g_varchar2
  ,p_parameter_two               in     varchar2 default hr_api.g_varchar2
  ,p_parameter_three             in     varchar2 default hr_api.g_varchar2
  ,p_include_upper_limit         in     varchar2 default hr_api.g_varchar2
  ,p_include_lower_limit         in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number       in out nocopy   number
  ,p_start_date                     out nocopy   date
  ,p_end_date                       out nocopy   date
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< DELETE_AME_CONDITION >---------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes the given condition.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * The condition id that identifies the condition should be valid.
 *
 * <p><b>Post Success</b><br>
 * The condition is deleted.
 *
 * <p><b>Post Failure</b><br>
 * The condition is not deleted and an error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified. Default value is False.
 * @param p_condition_id This uniquely identifies the condition to be deleted.
 * @param p_object_version_number Pass in the current version number of the
 * condition to be deleted. When the API completes if p_validate is false,
 * will be set to the new version number of the deleted condition. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_start_date If p_validate is false, it is set to the date from
 * which the deleted condition was effective.
 * If p_validate is true, it is set to the same date which was passed in.
 * @param p_end_date If p_validate is false, it is set to present date.
 * If p_validate is true, it is set to the same date which was passed in.
 * @rep:displayname Delete Ame Condition
 * @rep:category BUSINESS_ENTITY AME_CONDITION
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
*/
--
-- {End Of Comments}
--
procedure delete_ame_condition
  (p_validate              in     boolean  default false
  ,p_condition_id          in     number
  ,p_object_version_number in out nocopy   number
  ,p_start_date               out nocopy   date
  ,p_end_date                 out nocopy   date
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< CREATE_AME_STRING_VALUE >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates and adds a new string value to the given condition.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * The condition id that identifies the condition should be valid.
 *
 * <p><b>Post Success</b><br>
 * The string value is created and added to the given condition.
 *
 * <p><b>Post Failure</b><br>
 * The string value is not created and an error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified. Default value is false.
 * @param p_condition_id This uniquely identifies the condition to which
 * the string value is to be added.
 * @param p_string_value This parameter contains the string value that is to be
 * added for the condition.
 * @param p_object_version_number If p_validate is false, then it is set to
 * version number of the created string value. If p_validate is true,
 * then it is set to null.
 * @param p_start_date If p_validate is false, then it is set to the
 * effective start date for the created string value. If p_validate is true,
 * then it is set to null.
 * @param p_end_date It is the date up to, which the string value is effective.
 * If p_validate is false, then it is set to 31-Dec-4712. If p_validate
 * is true, then it is set to null.
 * @rep:displayname Create Ame String Value
 * @rep:category BUSINESS_ENTITY AME_CONDITION
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
*/
--
-- {End Of Comments}
--
procedure create_ame_string_value
  (p_validate             in     boolean  default false
  ,p_condition_id         in     number
  ,p_string_value         in     varchar2
  ,p_object_version_number   out nocopy   number
  ,p_start_date              out nocopy   date
  ,p_end_date                out nocopy   date
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< DELETE_AME_STRING_VALUE >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a string value associated with the given condition.
 *
 * <p><b>Licensing</b><br>
 * This API is available for use with any licensed component of the e-business
 * suite.
 *
 * <p><b>Prerequisites</b><br>
 * The condition id that identifies the condition should be valid.
 *
 * <p><b>Post Success</b><br>
 * The string value associated with the given condition is deleted.
 *
 * <p><b>Post Failure</b><br>
 * The string value is not deleted and an error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified. Default value is false.
 * @param p_condition_id This uniquely identifies the condition to which
 * the string value is attached.
 * @param p_string_value The string value that is to be deleted
 * @param p_object_version_number Pass in the current version number of the
 * string value to be deleted. When the API completes if p_validate is false,
 * will be set to the new version number of the deleted string value. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_start_date If p_validate is false, it is set to
 * the date from which the deleted string value was effective.
 * If p_validate is true, it is set to the same date which was passed in.
 * @param p_end_date If p_validate is false, it is set to present date.
 * If p_validate is true, it is set to the same date which was passed in.
 * @rep:displayname Delete Ame String Value
 * @rep:category BUSINESS_ENTITY AME_CONDITION
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
*/
--
-- {End Of Comments}
--
procedure delete_ame_string_value
  (p_validate              in     boolean  default false
  ,p_condition_id          in     number
  ,p_string_value          in     varchar2
  ,p_object_version_number in out nocopy   number
  ,p_start_date               out nocopy   date
  ,p_end_date                 out nocopy   date
  );
end AME_CONDITION_API;

/
