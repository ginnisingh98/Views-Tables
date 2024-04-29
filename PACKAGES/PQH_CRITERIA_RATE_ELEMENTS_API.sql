--------------------------------------------------------
--  DDL for Package PQH_CRITERIA_RATE_ELEMENTS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_CRITERIA_RATE_ELEMENTS_API" AUTHID CURRENT_USER as
/* $Header: pqcreapi.pkh 120.4 2006/04/21 15:18:07 srajakum noship $ */
/*#
 * This package contains criteria rate elements APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Criteria rate element
*/


--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_criteria_rate_element >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
/*#
 * This API creates a new criteria rate element.
 *
 * An element type can be associated to only one criteria rate definition.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * The element that is linked to the criteria rate definition must already
 * exist.
 *
 * <p><b>Post Success</b><br>
 * A criteria rate element row is created.
 *
 * <p><b>Post Failure</b><br>
 * A criteria rate element is not created and error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and
 * the database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * effective during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_criteria_rate_element_id If p_validate is false, then this uniquely
 * identifies the criteria rate element created. If p_validate is true, then set to null.
 * @param p_criteria_rate_defn_id The criteria rate definition to which the
 * element is linked.
 * @param p_element_type_id Element type linked to the criteria rate definition.
 * @param p_input_value_id Input value for element in which a person's rate for
 * the current criteria rate definition will be recorded.
 * @param p_business_group_id Business group of the criteria rate element.
 * @param p_legislation_code Legislation of the criteria rate element.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created criteria rate element. If p_validate is true,
 * then set to null.
 * @rep:displayname Create criteria rate element
 * @rep:category BUSINESS_ENTITY PQH_RBC_RATE_MATRIX
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/

--
-- {End Of Comments}
--

procedure create_criteria_rate_element
  (p_validate                     in     boolean   default false
  ,p_effective_date               in     date
  ,p_criteria_rate_element_id        out nocopy number
  ,p_criteria_rate_defn_id        in     number
  ,p_element_type_id              in     number
  ,p_input_value_id               in     number
  ,p_business_group_id            in     number	   default null
  ,p_legislation_code             in     varchar2  default null
  ,p_object_version_number          out nocopy number
  );

--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_criteria_rate_element >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
/*#
 * This API updates a criteria rate element.
 *
 * An element type can be associated to only one criteria rate definition.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * The criteria rate element record that is modified must already exist.
 *
 * <p><b>Post Success</b><br>
 * The criteria rate element is updated.
 *
 * <p><b>Post Failure</b><br>
 * The criteria rate element is not updated and error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and
 * the database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * effective during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_criteria_rate_element_id If p_validate is false, then this
 * uniquely identifies the criteria rate element created. If p_validate is true,
 * then set to null.
 * @param p_criteria_rate_defn_id The criteria rate definition to which the
 * element is linked.
 * @param p_element_type_id Element type linked to the criteria rate definition.
 * @param p_input_value_id Input value for element in which a person's rate for
 * the current criteria rate definition will be recorded.
 * @param p_business_group_id Business group of the criteria rate element.
 * @param p_legislation_code Legislation of the criteria rate element.
 * @param p_object_version_number Pass in the current version number of the
 * criteria rate element to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated criteria rate element.
 * If p_validate is true will be set to the same value which was passed in.
 * @rep:displayname Update criteria rate element
 * @rep:category BUSINESS_ENTITY PQH_RBC_RATE_MATRIX
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--

procedure update_criteria_rate_element
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_criteria_rate_element_id     in     number
  ,p_criteria_rate_defn_id        in     number    default hr_api.g_number
  ,p_element_type_id              in     number    default hr_api.g_number
  ,p_input_value_id               in     number    default hr_api.g_number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_legislation_code             in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  );

--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_criteria_rate_element >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
/*#
 * This API deletes the criteria rate element.
 *
 * The API deletes only the link between the criteria rate definition
 * and the element type. The actual criteria rate definition and the
 * element type is not deleted.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * The associated elements for the criteria rate element and rate factor
 * on element details must be deleted.
 *
 * <p><b>Post Success</b><br>
 * The criteria rate element is deleted.
 *
 * <p><b>Post Failure</b><br>
 * The criteria rate element is not deleted and error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and
 * the database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values
 * are applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_criteria_rate_element_id Identifies the criteria rate element to be
 * deleted.
 * @param p_object_version_number Current version number of the criteria
 * rate element to be deleted.
 * @rep:displayname Delete criteria rate element
 * @rep:category BUSINESS_ENTITY PQH_RBC_RATE_MATRIX
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--

procedure delete_criteria_rate_element
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_criteria_rate_element_id      in     number
  ,p_object_version_number         in     number
  );


--

end PQH_CRITERIA_RATE_ELEMENTS_API;


 

/
