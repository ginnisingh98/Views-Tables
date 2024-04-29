--------------------------------------------------------
--  DDL for Package PQH_RATE_MATRIX_RATES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RATE_MATRIX_RATES_API" AUTHID CURRENT_USER as
/* $Header: pqrmrapi.pkh 120.5 2006/03/14 11:27:52 srajakum noship $ */
/*#
 * This package contains rate matrix rate APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Rate matrix rate
*/
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_rate_matrix_rate >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
/*#
 * This API creates a new rate matrix rate.
 *
 * The rate is created for a given rate matrix node and criteria rate
 * definition.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * The rate matrix node and the criteria rate definition for which the
 * rate is created must already exist.
 *
 * <p><b>Post Success</b><br>
 * The rate matrix rate is created.
 *
 * <p><b>Post Failure</b><br>
 * The rate matrix rate is not created and error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and
 * the database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes
 * into force.
 * @param p_rate_matrix_rate_id If p_validate is false, then this uniquely
 * identifies the rate matrix rate created. If p_validate is true, then
 * set to null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest start date for the created rate matrix rate. If p_validate is true,
 * then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created rate matrix rate. If p_validate is true,
 * then set to null.
 * @param p_rate_matrix_node_id Identifies the rate matrix node for which
 * rate is created.
 * @param p_criteria_rate_defn_id Identifies the criteria rate definition
 * for which rate is created.
 * @param p_min_rate_value Minimum rate value.
 * @param p_max_rate_value Maximum rate value.
 * @param p_mid_rate_value Mid rate value.
 * @param p_rate_value Default rate value.
 * @param p_business_group_id Business group of the rate matrix rate.
 * @param p_legislation_code Legislation code of the rate matrix rate.
 * @param p_object_version_number If p_validate is false, then set to
 * the version number of the created rate matrix rate. If p_validate
 * is true, then the value will be null.
 * @rep:displayname Create rate matrix rate
 * @rep:category BUSINESS_ENTITY PQH_RBC_RATE_MATRIX
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_rate_matrix_rate
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_rate_matrix_rate_id           out nocopy number
  ,p_EFFECTIVE_START_DATE          out nocopy date
  ,p_EFFECTIVE_END_DATE            out nocopy date
  ,p_RATE_MATRIX_NODE_ID           in number
  ,p_CRITERIA_RATE_DEFN_ID         in number
  ,p_MIN_RATE_VALUE                in NUMBER default null
  ,p_MAX_RATE_VALUE                in NUMBER default null
  ,p_MID_RATE_VALUE                in NUMBER default null
  ,p_RATE_VALUE                    in NUMBER
  ,p_BUSINESS_GROUP_ID             in NUMBER default null
  ,p_LEGISLATION_CODE              in VARCHAR2 default null
  ,p_object_version_number           out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_rate_matrix_rate >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
/*#
 * This API updates a rate matrix rate.
 *
 * The API allows datetrack update of the rate matrix rate record.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * The rate matrix node and the criteria rate definition for which the
 * rate is updated must already exist.
 *
 * <p><b>Post Success</b><br>
 * The rate matrix rate is updated.
 *
 * <p><b>Post Failure</b><br>
 * The rate matrix rate is not updated and error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and
 * the database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes
 * into force.
 * @param p_datetrack_mode Indicates which DateTrack mode to use when
 * updating the record. You must set to either UPDATE, CORRECTION,
 * UPDATE_OVERRIDE, UPDATE_CHANGE_INSERT. Modes available for use with a
 * particular record depend on dates of the previous record changes and the
 * effective date of this change.
 * @param p_rate_matrix_rate_id Identifies the rate matrix rate to be
 * updated.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date of the updated rate matrix rate row which now exists
 * as of the effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date of the updated rate matrix rate row which now exists
 * as of the effective date. If p_validate is true, then set to null.
 * @param p_rate_matrix_node_id Identifies the rate matrix node for which
 * rate is updated.
 * @param p_criteria_rate_defn_id Identifies the criteria rate definition
 * for which rate is updated.
 * @param p_min_rate_value Minimum rate value.
 * @param p_max_rate_value Maximum rate value.
 * @param p_mid_rate_value Mid rate value.
 * @param p_rate_value Default rate value.
 * @param p_business_group_id Business group of the rate matrix rate.
 * @param p_legislation_code Legislation code of the rate matrix rate.
 * @param p_object_version_number Pass in the current version number of the
 * rate matrix rate to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated rate matrix rate.
 * If p_validate is true will be set to the same value which was passed in.
 * @rep:displayname Update rate matrix rate
 * @rep:category BUSINESS_ENTITY PQH_RBC_RATE_MATRIX
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_rate_matrix_rate
  (p_validate                     in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_mode                 in  varchar2
  ,p_RATE_MATRIX_RATE_ID           in number
  ,p_EFFECTIVE_START_DATE          out nocopy date
  ,p_EFFECTIVE_END_DATE            out nocopy date
  ,p_RATE_MATRIX_NODE_ID           in number
  ,p_CRITERIA_RATE_DEFN_ID         in number
  ,p_MIN_RATE_VALUE                in NUMBER default hr_api.g_number
  ,p_MAX_RATE_VALUE                in NUMBER default hr_api.g_number
  ,p_MID_RATE_VALUE                in NUMBER default hr_api.g_number
  ,p_RATE_VALUE                    in NUMBER
  ,p_BUSINESS_GROUP_ID             in NUMBER default hr_api.g_number
  ,p_LEGISLATION_CODE              in VARCHAR2 default hr_api.g_varchar2
  ,p_object_version_number         in  out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_rate_matrix_rate >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
/*#
 * This API deletes a rate matrix rate.
 *
 * The API allows datetrack delete of the rate value.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * The rate matrix rate that is to be deleted must exist.
 *
 * <p><b>Post Success</b><br>
 * The rate matrix rate is deleted.
 *
 * <p><b>Post Failure</b><br>
 * The rate matrix rate is not deleted and error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and
 * the database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_rate_matrix_rate_id Identifies the rate matrix rate to be
 * deleted.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date of the deleted rate matrix rate row which now exists
 * as of the effective date. If p_validate is true or all row instances have
 * been deleted then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date of the deleted rate matrix rate row which now exists
 * as of the effective date. If p_validate is true or all row instances have
 * been deleted then set to null.
 * @param p_object_version_number Current version number of the
 * rate matrix rate to be deleted.
 * @param p_effective_date Determines when the DateTrack operation comes
 * into force.
 * @param p_datetrack_mode Indicates which DateTrack mode to use when
 * deleting the record. You must set to either ZAP, DELETE,
 * FUTURE_CHANGE, DELETE_NEXT_CHANGE. Modes available for use with a
 * particular record depend on dates of the previous record changes and the
 * effective date of this change.
 * @rep:displayname Delete rate matrix rate
 * @rep:category BUSINESS_ENTITY PQH_RBC_RATE_MATRIX
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
--
-- {End Of Comments}
--
procedure delete_rate_matrix_rate
  (p_validate                      in     boolean  default false
  ,p_rate_matrix_rate_ID	   in     number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end PQH_RATE_MATRIX_RATES_API;

 

/
