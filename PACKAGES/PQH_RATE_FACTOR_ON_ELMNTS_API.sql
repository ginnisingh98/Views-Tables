--------------------------------------------------------
--  DDL for Package PQH_RATE_FACTOR_ON_ELMNTS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RATE_FACTOR_ON_ELMNTS_API" AUTHID CURRENT_USER as
/* $Header: pqrfeapi.pkh 120.2 2005/11/30 15:00:21 srajakum noship $ */
/*#
 * This package contains rate factor on elements APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Rate Factor on Element
*/

--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_rate_factor_on_elmnt >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
/*#
 * This API creates a new rate factor on element record.
 *
 * In addition to storing the person's rate value for a given criteria rate
 * definition on its associated element, this API allows user to store the value of
 * rate factors used in the rate calculation for a criteria rate definition. The rate
 * factor value can be stored either as a input value to the element or as a entry
 * value on the element entry record.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * The rate factor values for a given criteria rate definition can be stored
 * as a input value or as a entry value on the element entry record only for the
 * element types linked to the criteria rate definition.
 *
 * <p><b>Post Success</b><br>
 * The rate factor on element record is created.
 *
 * <p><b>Post Failure</b><br>
 * The rate factor on element record is not created and error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date p_effective_date Reference date for validating lookup values are
 * effective during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_rate_factor_on_elmnt_id If p_validate is false, then this uniquely
 * identifies the rate factor on element created. If p_validate is true, then set to null.
 * @param p_criteria_rate_element_id Element type linked to a criteria rate definition.
 * @param p_criteria_rate_factor_id Rate factor used to calculate the rate for a
 * criteria rate deinition.
 * @param p_rate_factor_val_record_tbl Table name where the rate factor value
 * is stored. Valid values are identified by lookup type PQH_RBC_RT_FACTOR_ELMNT_TBL.
 * @param p_rate_factor_val_record_col Column name where the rate factor
 * value must be stored.
 * @param p_business_group_id Business group of the rate factor on element.
 * @param p_legislation_code Legislation of the rate factor on element.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created rate factor on element. If p_validate is true,
 * then set to null.
 * @rep:displayname Create rate factor on element
 * @rep:category BUSINESS_ENTITY PQH_RBC_RATE_MATRIX
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--

procedure create_rate_factor_on_elmnt
  (p_validate                     in     boolean   default false
  ,p_effective_date               in     date
  ,p_rate_factor_on_elmnt_id         out nocopy number
  ,p_criteria_rate_element_id     in     number
  ,p_criteria_rate_factor_id      in     number
  ,p_rate_factor_val_record_tbl   in     varchar2
  ,p_rate_factor_val_record_col   in     varchar2
  ,p_business_group_id            in     number    default null
  ,p_legislation_code             in     varchar2  default null
  ,p_object_version_number           out nocopy number
  );
--

--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_rate_factor_on_elmnt >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
/*#
 * This API updates a rate factor on element.
 *
 * In addition to storing the person's rate value for a given criteria rate
 * definition on its associated element, this API allows user to store the value of
 * rate factors used in the rate calculation for a criteria rate definition. The rate
 * factor value can be stored either as a input value to the element or as a entry
 * value on the element entry record.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * The rate factor values for a given criteria rate definition can be stored
 * as a input value or as a entry value on the element entry record only for the
 * element types linked to the criteria rate definition.
 *
 * <p><b>Post Success</b><br>
 * The rate factor on element record is updated.
 *
 * <p><b>Post Failure</b><br>
 * The rate factor on element record is not updated and error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * effective during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_rate_factor_on_elmnt_id Identifies the rate factor on element
 * record to be modified.
 * @param p_criteria_rate_element_id Element type linked to a criteria rate definition.
 * @param p_criteria_rate_factor_id Rate factor used to calculate the rate for a
 * criteria rate deinition.
 * @param p_rate_factor_val_record_tbl Table name where the rate factor value
 * is stored. Valid values are identified by lookup type PQH_RBC_RT_FACTOR_ELMNT_TBL.
 * @param p_rate_factor_val_record_col Column name where the rate factor
 * value must be stored.
 * @param p_business_group_id Business group of the rate factor on element.
 * @param p_legislation_code Legislation of the rate factor on element.
 * @param p_object_version_number Pass in the current version number of the
 * rate factor on element to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated rate factor on element.
 * If p_validate is true will be set to the same value which was passed in.
 * @rep:displayname Update rate factor on element
 * @rep:category BUSINESS_ENTITY PQH_RBC_RATE_MATRIX
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--

procedure update_rate_factor_on_elmnt
  (p_validate                     in     boolean   default false
  ,p_effective_date               in     date
  ,p_rate_factor_on_elmnt_id      in     number
  ,p_criteria_rate_element_id     in     number    default hr_api.g_number
  ,p_criteria_rate_factor_id      in     number    default hr_api.g_number
  ,p_rate_factor_val_record_tbl   in     varchar2  default hr_api.g_varchar2
  ,p_rate_factor_val_record_col   in     varchar2  default hr_api.g_varchar2
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_legislation_code             in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  );
--

--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_rate_factor_on_elmnt >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
/*#
 * This API deletes a rate factor on element.
 *
 * The API only deletes the information about where the rate factors used in the
 * rate calculation for a criteria rate definition are stored. It does not delete
 * the rate factor details.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * The rate factor on element information that is to be deleted must exist.
 *
 * <p><b>Post Success</b><br>
 * The rate factor on element record is deleted.
 *
 * <p><b>Post Failure</b><br>
 * The rate factor on element record is not deleted and error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values
 * are applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_rate_factor_on_elmnt_id Identifies the rate factor on element
 * record to be deleted.
 * @param p_object_version_number Current version number of the rate
 * factor on element to be deleted.
 * @rep:displayname Delete rate factor on element
 * @rep:category BUSINESS_ENTITY PQH_RBC_RATE_MATRIX
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--

procedure delete_rate_factor_on_elmnt
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_rate_factor_on_elmnt_id       in     number
  ,p_object_version_number         in     number
  );


--

end PQH_RATE_FACTOR_ON_ELMNTS_API;


 

/
