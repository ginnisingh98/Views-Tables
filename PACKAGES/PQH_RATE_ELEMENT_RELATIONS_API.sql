--------------------------------------------------------
--  DDL for Package PQH_RATE_ELEMENT_RELATIONS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RATE_ELEMENT_RELATIONS_API" AUTHID CURRENT_USER as
/* $Header: pqrerapi.pkh 120.2 2005/11/30 15:00:33 srajakum noship $ */
/*#
 * This package contains rate element relation APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Rate Element Relation
*/
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_rate_element_relation >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
/*#
 * This API creates a new rate element relation.
 *
 * Any element type that is used to record rate within the rate by criteria system,
 * can have associated elements and overidden element. An associated element is one
 * for which rate will be calculated when calculating the rate for the current element.
 * An overidden element is one whose rate value is overidden by the current element's
 * rate value.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * Any element type that is selected as an associated element or overidden element
 * must be linked to a criteria rate definition.
 *
 * <p><b>Post Success</b><br>
 * A rate element relation is created.
 *
 * <p><b>Post Failure</b><br>
 * A rate element relation is not created and error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and
 * the database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * effective during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_rate_element_relation_id If p_validate is false, then this
 * uniquely identifies the rate element relation created. If p_validate is true,
 * then set to null.
 * @param p_criteria_rate_element_id Element type used to record person's
 * rate value for a criteria rate definition within rate by criteria system.
 * @param p_relation_type_cd Relationship between two element types used
 * in the rate by criteria system. Valid values are identified by lookup_type
 * PQH_RBC_ELMNT_RELATION_TYPE.
 * @param p_rel_element_type_id Element Type within the rate by criteria
 * system which has a relationship with the current criteria rate element.
 * @param p_rel_input_value_id Input value where the rate for the related
 * element type is stored.
 * @param p_business_group_id Business group of the rate element relation.
 * @param p_legislation_code Legislation of the rate element relation.
 * @param p_object_version_number If p_validate is false, then set to
 * the version number of the created rate element relation. If p_validate is true, then set
 * to null.
 * @rep:displayname Create rate element relation
 * @rep:category BUSINESS_ENTITY PQH_RBC_RATE_MATRIX
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--

procedure create_rate_element_relation
  (p_validate                     in     boolean   default false
  ,p_effective_date               in     date
  ,p_rate_element_relation_id     in out nocopy number
  ,p_criteria_rate_element_id     in     number
  ,p_relation_type_cd             in     varchar2
  ,p_rel_element_type_id          in     number
  ,p_rel_input_value_id           in     number    default null
  ,p_business_group_id            in     number    default null
  ,p_legislation_code             in     varchar2  default null
  ,p_object_version_number           out nocopy number
  );
--

--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_rate_element_relation >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
/*#
 * This API updates a rate element relation.
 *
 * Any element type that is used to record rate within the rate by criteria system,
 * can have associated elements and overidden element. An associated element is one
 * for which rate will be calculated when calculating the rate for the current element.
 * An overidden element is one whose rate value is overidden by the current element's
 * rate value.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * For a element type to be selected as an associated element or overidden element
 * for current criteria rate element, it must be linked to  a criteria rate definition
 * in the rate by criteria system.
 *
 * <p><b>Post Success</b><br>
 * The rate element relation is updated.
 *
 * <p><b>Post Failure</b><br>
 * The rate element relation is not updated and error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and
 * the database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * effective during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_rate_element_relation_id Identifies the rate element relation to be
 * updated.
 * @param p_criteria_rate_element_id Element type used to record person's
 * rate value for a criteria rate definition within rate by criteria system.
 * @param p_relation_type_cd Relationship between two element types used
 * in the rate by criteria system. Valid values are identified by lookup_type
 * PQH_RBC_ELMNT_RELATION_TYPE.
 * @param p_rel_element_type_id Element Type within the rate by criteria
 * system which has a relationship with the current criteria rate element.
 * @param p_rel_input_value_id Input value where the rate for the related
 * element type is stored.
 * @param p_business_group_id Business group of the rate element relation.
 * @param p_legislation_code Legislation of the rate element relation.
 * @param p_object_version_number Pass in the current version number of the rate matrix
 * node to be updated. When the API completes if p_validate is false, will be set to the
 * new version number of the updated rate element relation. If p_validate is true will
 * be set to the same value which was passed in.
 * @rep:displayname Update rate element relation
 * @rep:category BUSINESS_ENTITY PQH_RBC_RATE_MATRIX
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--

procedure update_rate_element_relation
  (p_validate                     in     boolean   default false
  ,p_effective_date               in     date
  ,p_rate_element_relation_id     in     number
  ,p_criteria_rate_element_id     in     number    default hr_api.g_number
  ,p_relation_type_cd             in     varchar2  default hr_api.g_varchar2
  ,p_rel_element_type_id          in     number    default hr_api.g_number
  ,p_rel_input_value_id           in     number    default hr_api.g_number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_legislation_code             in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  );


--

--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_rate_element_relation >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
/*#
 * This API deletes a rate element relation.
 *
 * The API only deletes the relationship between two element types within the
 * rate by criteria system and does not actually remove the element type details.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * The rate element relation that is to be removed must exist.
 *
 * <p><b>Post Success</b><br>
 * The rate element relation is deleted.
 *
 * <p><b>Post Failure</b><br>
 * The rate element relation is not deleted and error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and
 * the database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values
 * are applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_rate_element_relation_id Identifies the rate element relation to be
 * deleted.
 * @param p_object_version_number Current version number of the rate element
 * relation to be deleted.
 * @rep:displayname Delete rate element relation
 * @rep:category BUSINESS_ENTITY PQH_RBC_RATE_MATRIX
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--

procedure delete_rate_element_relation
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_rate_element_relation_id      in     number
  ,p_object_version_number         in     number
  );


--

end PQH_RATE_ELEMENT_RELATIONS_API;


 

/
