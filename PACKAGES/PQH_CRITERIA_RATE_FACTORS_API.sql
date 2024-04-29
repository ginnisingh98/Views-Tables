--------------------------------------------------------
--  DDL for Package PQH_CRITERIA_RATE_FACTORS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_CRITERIA_RATE_FACTORS_API" AUTHID CURRENT_USER as
/* $Header: pqcrfapi.pkh 120.4 2006/04/21 15:17:33 srajakum noship $ */
/*#
 * This package contains criteria rate factor APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Criteria rate factor
*/


--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_criteria_rate_factor >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
/*#
 * This API creates a new criteria rate factor.
 *
 * A rate factor is another criteria rate definition in the same business group
 * whose rate value is used in the rate calculation for the current criteria rate
 * definition.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * The criteria rate definitions which are used as rate factors must already
 * exist. A criteria rate definition that is  a rate factor used in the
 * rate calculation of another criteria rate definition, must itself not use
 * rate factors for its rate calculation.
 *
 * <p><b>Post Success</b><br>
 * A criteria rate factor is created.
 *
 * <p><b>Post Failure</b><br>
 * A criteria rate factor is not created and error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and
 * the database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * effective during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_criteria_rate_factor_id If p_validate is false, then this
 * uniquely identifies the criteria rate factor created. If p_validate is true,
 * then set to null.
 * @param p_criteria_rate_defn_id The criteria rate definition for which the
 * the rate factor is defined.
 * @param p_parent_criteria_rate_defn_id Another criteria rate definition
 * in the same business group whose rate value is used in the rate calculation
 * for the current criteria rate definition.
 * @param p_parent_rate_matrix_id The rate matrix to which the parent
 * criteria rate definition is added to.
 * @param p_business_group_id Business group of the criteria rate factor.
 * @param p_legislation_code Legislation of the criteria rate factor.
 * @param p_object_version_number If p_validate is false, then set to
 * the version number of the created criteria rate factor. If p_validate is true,
 * then set to null.
 * @rep:displayname Create criteria rate factor
 * @rep:category BUSINESS_ENTITY PQH_RBC_RATE_MATRIX
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--

procedure create_criteria_rate_factor
  (p_validate                      in     boolean   default false
  ,p_effective_date                in     date
  ,p_criteria_rate_factor_id          out nocopy number
  ,p_criteria_rate_defn_id         in     number
  ,p_parent_criteria_rate_defn_id  in     number
  ,p_parent_rate_matrix_id         in     number    default null
  ,p_business_group_id             in     number    default null
  ,p_legislation_code              in     varchar2  default null
  ,p_object_version_number            out nocopy number
  );

--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_criteria_rate_factor >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
/*#
 * This API updates a criteria rate factor.
 *
 * A rate factor is another criteria rate definition in the same business group
 * whose rate value is used in the rate calculation for the current criteria rate
 * definition.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * The criteria rate definitions which are used as rate factors must already
 * exist. A criteria rate definition that is  a rate factor used in the
 * rate calculation of another criteria rate definition, must itself not use
 * rate factors for its rate calculation.
 *
 * <p><b>Post Success</b><br>
 * The criteria rate factor is updated.
 *
 * <p><b>Post Failure</b><br>
 * The criteria rate factor is not updated and error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and
 * the database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * effective during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_criteria_rate_factor_id If p_validate is false, then this uniquely
 * identifies the criteria rate factor created. If p_validate is true, then set
 * to null.
 * @param p_criteria_rate_defn_id The criteria rate definition for which the
 * the rate factor is defined.
 * @param p_parent_criteria_rate_defn_id Another criteria rate definition
 * in the same business group whose rate value is used in the rate calculation
 * for the current criteria rate definition.
 * @param p_parent_rate_matrix_id The rate matrix to which the parent
 * criteria rate definition is attached to.
 * @param p_business_group_id Business group of the criteria rate factor.
 * @param p_legislation_code Legislation of the criteria rate factor.
 * @param p_object_version_number Pass in the current version number of the
 * criteria rate factor to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated criteria rate factor.
 * If p_validate is true will be set to the same value which was passed in.
 * @rep:displayname Update criteria rate factor
 * @rep:category BUSINESS_ENTITY PQH_RBC_RATE_MATRIX
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--

procedure update_criteria_rate_factor
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_criteria_rate_factor_id       in     number
  ,p_criteria_rate_defn_id         in     number    default hr_api.g_number
  ,p_parent_criteria_rate_defn_id  in     number    default hr_api.g_number
  ,p_parent_rate_matrix_id         in     number    default hr_api.g_number
  ,p_business_group_id             in     number    default hr_api.g_number
  ,p_legislation_code              in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy number
  );

--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_criteria_rate_factor >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
/*#
 * This API deletes a criteria rate factor.
 *
 * The API only deletes the link between the current criteria rate definiton
 * and its parent criteria rate definitions on which it is dependent for
 * rate calculation. It does not delete the parent criteria rate definition
 * itself.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * The rate factor on element details must be deleted already.
 *
 * <p><b>Post Success</b><br>
 * The criteria rate factor is deleted.
 *
 * <p><b>Post Failure</b><br>
 * The criteria rate factor is not deleted and error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and
 * the database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values
 * are applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_criteria_rate_factor_id Identifies the criteria rate factor to
 * be deleted.
 * @param p_object_version_number Current version number of the criteria
 * rate factor to be deleted.
 * @rep:displayname Delete criteria rate factor
 * @rep:category BUSINESS_ENTITY PQH_RBC_RATE_MATRIX
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--

procedure delete_criteria_rate_factor
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_criteria_rate_factor_id       in     number
  ,p_object_version_number         in     number
  );


--

end PQH_CRITERIA_RATE_FACTORS_API;


 

/
