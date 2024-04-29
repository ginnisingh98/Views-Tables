--------------------------------------------------------
--  DDL for Package HR_CAGR_PARAMETER_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CAGR_PARAMETER_API" AUTHID CURRENT_USER as
/* $Header: pecpaapi.pkh 120.1 2005/10/02 02:13:43 aroussel $ */
/*#
 * This package contains APIs which maintain collective agreement parameters.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Collective Agreement Parameter
*/
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_cagr_parameter >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a collective agreement parameter.
 *
 * Each parameter record holds meta data that describes a specific piece of
 * data stored on the HRMS system, providing it with a name, a data type and
 * unit of measure. This information is used by the collective agreement
 * process to populate eligible entitlement results for a specific entitlement
 * item to the relevant field on the HRMS system.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The collective agreement API to which this API parameter belongs must exist.
 *
 * <p><b>Post Success</b><br>
 * The collective agreement API parameter is created.
 *
 * <p><b>Post Failure</b><br>
 * The collective agreement API parameter is not created and an error is
 * raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_cagr_api_id Uniquely identifies the collective agreement API to
 * which this parameter belongs.
 * @param p_display_name The display name of the API parameter.
 * @param p_parameter_name The system name of the API parameter.
 * @param p_column_type The data type of the API parameter. Valid values are
 * defined by the 'CAGR_PARAM_TYPES' lookup type.
 * @param p_column_size The maximum permitted size data supported by the API
 * parameter.
 * @param p_uom_parameter The name of the parameter that supplies the
 * associated unit of measure value for this parameter.
 * @param p_uom_lookup The name of the lookup type providing the unit of
 * measure values for the p_uom_parameter.
 * @param p_default_uom The unit of measure if there is not an associated unit
 * of measure (p_uom_parameter) parameter. Valid values are defined by the
 * 'UNITS' lookup type.
 * @param p_hidden Indicates whether the API parameter is visible or hidden.
 * Valid values are defined by the 'YES_NO' lookup type.
 * @param p_cagr_api_param_id If p_validate is false, then this uniquely
 * identifies the collective agreement API parameter created. If p_validate is
 * true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created collective agreement API parameter. If
 * p_validate is true, then the value will be null.
 * @rep:displayname Create Collective Agreement Parameter
 * @rep:category BUSINESS_ENTITY PER_COLLECTIVE_AGREEMENT
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_cagr_parameter
(
   p_validate                       in     boolean    default false
  ,p_effective_date                 in     date
  ,p_cagr_api_id                    in     number
  ,p_display_name                   in     varchar2
  ,p_parameter_name                 in     varchar2
  ,p_column_type                    in     varchar2
  ,p_column_size                    in     number
  ,p_uom_parameter                  in     varchar2  default null
  ,p_uom_lookup                     in     varchar2  default null
  ,p_default_uom                    in     varchar2  default null
  ,p_hidden                         in     varchar2
  ,p_cagr_api_param_id                 out nocopy number
  ,p_object_version_number             out nocopy number
 );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_cagr_parameter >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a collective agreement parameter.
 *
 * This API updates a collective agreement parameter. Each parameter record is
 * meta data describing a specific piece of data stored on the HRMS system,
 * providing it with a name, a data type and unit of measure. This information
 * is used by the collective agreement process to populate eligible entitlement
 * results for a specific entitlement item to the relevant field on the HRMS
 * system.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The API parameter to be updated must exist. The collective agreement API to
 * which this API parameter belongs must exist.
 *
 * <p><b>Post Success</b><br>
 * The collective agreement API parameter is updated.
 *
 * <p><b>Post Failure</b><br>
 * The collective agreement API parameter is not updated and an error is
 * raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_cagr_api_param_id Uniquely identifies the collective agreement API
 * parameter to be updated.
 * @param p_cagr_api_id Uniquely identifies the collective agreement API to
 * which this parameter belongs.
 * @param p_display_name The display name of the API parameter.
 * @param p_parameter_name The system name of the API parameter.
 * @param p_column_type The data type of the API parameter. Valid values are
 * defined by the 'CAGR_PARAM_TYPES' lookup type.
 * @param p_column_size The maximum permitted size data supported by the API
 * parameter.
 * @param p_uom_parameter This name of the parameter that supplies the
 * associated unit of measure value for this parameter.
 * @param p_uom_lookup The name of the lookup type providing the unit of
 * measure values for the p_uom_parameter.
 * @param p_default_uom The unit of measure if there is not an associated unit
 * of measure (p_uom_parameter) parameter. Valid values are defined by the
 * 'UNITS' lookup type.
 * @param p_hidden Indicates whether the API parameter is visible or hidden.
 * Valid values are defined by the 'YES_NO' lookup type.
 * @param p_object_version_number Pass in the current version number of the
 * collective agreement API parameter to be updated. When the API completes if
 * p_validate is false, will be set to the new version number of the updated
 * collective agreement API parameter. If p_validate is true will be set to the
 * same value which was passed in.
 * @rep:displayname Update Collective Agreement Parameter
 * @rep:category BUSINESS_ENTITY PER_COLLECTIVE_AGREEMENT
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_cagr_parameter
  (
   p_validate                       in     boolean    default false
  ,p_effective_date                 in     date
  ,p_cagr_api_param_id              in     number    default hr_api.g_number
  ,p_cagr_api_id                    in     number    default hr_api.g_number
  ,p_display_name                   in     varchar2  default hr_api.g_varchar2
  ,p_parameter_name                 in     varchar2  default hr_api.g_varchar2
  ,p_column_type                    in     varchar2  default hr_api.g_varchar2
  ,p_column_size                    in     number    default hr_api.g_number
  ,p_uom_parameter                  in     varchar2  default hr_api.g_varchar2
  ,p_uom_lookup                     in     varchar2  default hr_api.g_varchar2
  ,p_default_uom                    in     varchar2  default hr_api.g_varchar2
  ,p_hidden                         in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_cagr_parameter >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a collective agreement parameter.
 *
 * Each parameter record holds meta data that describes a specific piece of
 * data stored on the HRMS system, providing it with a name, a data type and
 * unit of measure. This information is used by the collective agreement
 * process to populate eligible entitlement results for a specific entitlement
 * item to the relevant field on the HRMS system.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The API parameter to be deleted must exist.
 *
 * <p><b>Post Success</b><br>
 * The collective agreement API parameter is deleted.
 *
 * <p><b>Post Failure</b><br>
 * The collective agreement API parameter is not deleted and an error is
 * raised.
 * @param p_cagr_api_param_id Uniquely identifies the collective agreement API
 * parameter to be deleted.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_object_version_number Current version number of the collective
 * agreement API parameter to be deleted.
 * @rep:displayname Delete Collective Agreement Parameter
 * @rep:category BUSINESS_ENTITY PER_COLLECTIVE_AGREEMENT
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_cagr_parameter
  (
   p_cagr_api_param_id              in     number
  ,p_validate                       in     boolean    default false
  ,p_object_version_number          in out nocopy number
  );
--
end hr_cagr_parameter_api;

 

/
