--------------------------------------------------------
--  DDL for Package PQH_RT_MATRIX_NODE_VALUES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RT_MATRIX_NODE_VALUES_API" AUTHID CURRENT_USER as
/* $Header: pqrmvapi.pkh 120.6 2006/03/14 11:28:14 srajakum noship $ */
/*#
 * This package contains rate matrix node value APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Rate matrix node value
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_rt_matrix_node_value >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
/*#
 * This API creates a new rate matrix node value.
 *
 * More than one rate matrix node value can be associated with the same rate
 * matrix node.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * The rate matrix node for which the node value is created must already
 * exist.
 *
 * <p><b>Post Success</b><br>
 * The rate matrix node value is created.
 *
 * <p><b>Post Failure</b><br>
 * The rate matrix node value is not created and error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and
 * the database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * effective during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_node_value_id If p_validate is false, then this uniquely
 * identifies the rate matrix node value created. If p_validate is true, then
 * set to null.
 * @param p_rate_matrix_node_id Identifies the rate matrix node to which
 * the node value is associated.
 * @param p_short_code Unique short code.
 * @param p_char_value1 Contains character value. If the criteria takes a
 * range of values, it stores the start of the range. Otherwise it stores
 * the criteria value.
 * @param p_char_value2 Contains character value. If the criteria takes a
 * range of values, it stores the end value of the range. Otherwise, it contains
 * null.
 * @param p_char_value3 Contains character value. A value will be stored in
 * this field only if the criteria associated with the rate matrix node has two
 * subcriteria. If the criteria takes a range of values this column stores the
 * start value of the range. Otherwise, it contains null.
 * @param p_char_value4 Contains character value. A value will be stored in
 * this field only if the criteria associated with the rate matrix node has two
 * subcriteria. If the criteria takes a range of values this column stores the
 * end value of the range. Otherwise, it contains null.
 * @param p_number_value1 Contains number value. If the criteria takes a
 * range of values, it stores the start of the range. Otherwise it stores
 * the criteria value.
 * @param p_number_value2 Contains number value. If the criteria takes a
 * range of values, it stores the end value of the range. Otherwise, it contains
 * null.
 * @param p_number_value3 Contains number value. A value will be stored in
 * this field only if the criteria associated with the rate matrix node has two
 * subcriteria. If the criteria takes a range of values this column stores the
 * start value of the range, otherwise it contains null.
 * @param p_number_value4 Contains number value. A value will be stored in
 * this field only if the criteria associated with the rate matrix node has two
 * subcriteria. If the criteria takes a range of values this column stores the
 * end value of the range, otherwise it contains null.
 * @param p_date_value1 Contains date value. If the criteria takes a
 * range of values, it stores the start of the range. Otherwise it stores
 * the criteria value.
 * @param p_date_value2 Contains date value. If the criteria takes a
 * range of values, it stores the end value of the range. Otherwise, it contains
 * null.
 * @param p_date_value3 Contains date value. A value will be stored in
 * this field only if the criteria associated with the rate matrix node has two
 * subcriteria. If the criteria takes a range of values this column stores the
 * start value of the range, otherwise it contains null.
 * @param p_date_value4 Contains date value. A value will be stored in
 * this field only if the criteria associated with the rate matrix node has two
 * subcriteria. If the criteria takes a range of values this column stores the
 * end value of the range, otherwise it contains null.
 * @param p_business_group_id Business group of the current rate matrix
 * node value.
 * @param p_legislation_code Legislation code of the current rate matrix
 * node value.
 * @param p_object_version_number If p_validate is false, then set to
 * the version number of the created rate matrix node value. If p_validate
 * is true, then the value will be null.
 * @rep:displayname Create rate matrix node value
 * @rep:category BUSINESS_ENTITY PQH_RBC_RATE_MATRIX
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_rt_matrix_node_value
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_NODE_VALUE_ID                 out nocopy number
  ,p_RATE_MATRIX_NODE_ID           in number
  ,p_SHORT_CODE                    in varchar2
  ,p_CHAR_VALUE1                   in varchar2  default null
  ,p_CHAR_VALUE2                   in varchar2  default null
  ,p_CHAR_VALUE3                   in varchar2  default null
  ,p_CHAR_VALUE4                   in varchar2  default null
  ,p_NUMBER_VALUE1                 in number  default null
  ,p_NUMBER_VALUE2                 in number  default null
  ,p_NUMBER_VALUE3                 in number  default null
  ,p_NUMBER_VALUE4                 in number  default null
  ,p_DATE_VALUE1                   in date default null
  ,p_DATE_VALUE2                   in date default null
  ,p_DATE_VALUE3                   in date default null
  ,p_DATE_VALUE4                   in date default null
  ,p_BUSINESS_GROUP_ID             in number    default null
  ,p_LEGISLATION_CODE              in varchar2    default null
  ,p_object_version_number           out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_rt_matrix_node_value >---------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
/*#
 * This API updates a rate matrix node value.
 *
 * More than one rate matrix node value can be associated with the same rate
 * matrix node.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * The rate matrix node for which the node value is created must already
 * exist.
 *
 * <p><b>Post Success</b><br>
 * The rate matrix node value details are successfully updated.
 *
 * <p><b>Post Failure</b><br>
 * The rate matrix node value details will not be updated and error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and
 * the database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup
 * values are effective during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_node_value_id Identifies the rate matrix node value
 * record to be modified.
 * @param p_rate_matrix_node_id Identifies the rate matrix node to which
 * the node value is associated.
 * @param p_short_code Unique short code.
 * @param p_char_value1 Contains character value. If the criteria takes a
 * range of values, it stores the start of the range. Otherwise it stores
 * the criteria value.
 * @param p_char_value2 Contains character value. If the criteria takes a
 * range of values, it stores the end value of the range. Otherwise, it contains
 * null.
 * @param p_char_value3 Contains character value. A value will be stored in
 * this field only if the criteria associated with the rate matrix node has two
 * subcriteria. If the criteria takes a range of values this column stores the
 * start value of the range. Otherwise, it contains null.
 * @param p_char_value4 Contains character value. A value will be stored in
 * this field only if the criteria associated with the rate matrix node has two
 * subcriteria. If the criteria takes a range of values this column stores the
 * end value of the range. Otherwise, it contains null.
 * @param p_number_value1 Contains number value. If the criteria takes a
 * range of values, it stores the start of the range. Otherwise it stores
 * the criteria value.
 * @param p_number_value2 Contains number value. If the criteria takes a
 * range of values, it stores the end value of the range. Otherwise, it contains
 * null.
 * @param p_number_value3 Contains number value. A value will be stored in
 * this field only if the criteria associated with the rate matrix node has two
 * subcriteria. If the criteria takes a range of values this column stores the
 * start value of the range, otherwise it contains null.
 * @param p_number_value4 Contains number value. A value will be stored in
 * this field only if the criteria associated with the rate matrix node has two
 * subcriteria. If the criteria takes a range of values this column stores the
 * end value of the range, otherwise it contains null.
 * @param p_date_value1 Contains date value. If the criteria takes a
 * range of values, it stores the start of the range. Otherwise it stores
 * the criteria value.
 * @param p_date_value2 Contains date value. If the criteria takes a
 * range of values, it stores the end value of the range. Otherwise, it contains
 * null.
 * @param p_date_value3 Contains date value. A value will be stored in
 * this field only if the criteria associated with the rate matrix node has two
 * subcriteria. If the criteria takes a range of values this column stores the
 * start value of the range, otherwise it contains null.
 * @param p_date_value4 Contains date value. A value will be stored in
 * this field only if the criteria associated with the rate matrix node has two
 * subcriteria. If the criteria takes a range of values this column stores the
 * end value of the range, otherwise it contains null.
 * @param p_business_group_id Business group of the current rate matrix
 * node value.
 * @param p_legislation_code Legislation code of the current rate matrix
 * node value.
 * @param p_object_version_number Pass in the current version number of the
 * rate matrix node value to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated rate matrix node
 * value. If p_validate is true will be set to the same value which was passed in.
 * @rep:displayname Update rate matrix node value
 * @rep:category BUSINESS_ENTITY PQH_RBC_RATE_MATRIX
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_rt_matrix_node_value
  (p_validate                     in     boolean  default false
  ,p_effective_date                in     date
  ,p_NODE_VALUE_ID                 in number
  ,p_RATE_MATRIX_NODE_ID           in number
  ,p_SHORT_CODE                    in varchar2
  ,p_CHAR_VALUE1                   in varchar2  default hr_api.g_varchar2
  ,p_CHAR_VALUE2                   in varchar2  default hr_api.g_varchar2
  ,p_CHAR_VALUE3                   in varchar2  default hr_api.g_varchar2
  ,p_CHAR_VALUE4                   in varchar2  default hr_api.g_varchar2
  ,p_NUMBER_VALUE1                 in number  default hr_api.g_number
  ,p_NUMBER_VALUE2                 in number  default hr_api.g_number
  ,p_NUMBER_VALUE3                 in number  default hr_api.g_number
  ,p_NUMBER_VALUE4                 in number  default hr_api.g_number
  ,p_DATE_VALUE1                   in date default hr_api.g_date
  ,p_DATE_VALUE2                   in date default hr_api.g_date
  ,p_DATE_VALUE3                   in date default hr_api.g_date
  ,p_DATE_VALUE4                   in date default hr_api.g_date
  ,p_BUSINESS_GROUP_ID             in number default hr_api.g_number
  ,p_LEGISLATION_CODE              in varchar2  default hr_api.g_varchar2
  ,p_object_version_number           in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_rt_matrix_node_value >---------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
/*#
 * This API deletes a rate matrix node value.
 *
 * Removing a rate matrix node value does not remove the eligibility profile
 * associated with a rate matrix node which determines if a person is
 * eligible for the rate associated with the node.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * The criteria value attached to the eligibility profile associated with
 * the rate matrix node must be deleted to maintain consistency.
 *
 * <p><b>Post Success</b><br>
 * The rate matrix node value is deleted.
 *
 * <p><b>Post Failure</b><br>
 * The rate matrix node value is not deleted and error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and
 * the database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values
 * are applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_node_value_id Identifies the rate matrix node value
 * to be deleted.
 * @param p_object_version_number Current version number of the rate
 * matrix node value to be deleted.
 * @rep:displayname Delete rate matrix node value
 * @rep:category BUSINESS_ENTITY PQH_RBC_RATE_MATRIX
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_rt_matrix_node_value
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_NODE_VALUE_ID	  	   in     number
  ,p_object_version_number         in     number
  );
--
end PQH_RT_MATRIX_NODE_VALUES_API;

 

/
