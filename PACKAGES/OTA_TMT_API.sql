--------------------------------------------------------
--  DDL for Package OTA_TMT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_TMT_API" AUTHID CURRENT_USER as
/* $Header: ottmtapi.pkh 120.1 2005/10/02 02:08:25 aroussel $ */
/*#
 * This package contains the measurement type APIs for use by Organization
 * Training Plans.
 * @rep:scope public
 * @rep:product ota
 * @rep:displayname Measurement Type
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------------< create_measure >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a measurement type.
 *
 * The created measurement type is used against budget or cost values within
 * the Organization Training Plans functionality.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The referenced values must exist in the database.
 *
 * <p><b>Post Success</b><br>
 * The measurement type is successfully created.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create a measurement type, and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_business_group_id The business group owning the measurement type.
 * @param p_tp_measurement_code What the measure is measuring. Valid values
 * exist in the 'OTA_PLAN_MEASUREMENT_TYPE' lookup type.
 * @param p_unit The units of measure. Valid values are 'I', 'M','N', from the
 * 'UNITS' lookup type.
 * @param p_budget_level The level at which this can be used for budgeting.
 * Valid values exist in the 'OTA_TRAINING_PLAN_BUDGET_LEVEL' lookup type.
 * @param p_cost_level The level at which this can be used for recording costs.
 * Valid values exist in the 'OTA_TRAINING_PLAN_COST_LEVEL' lookup type.
 * @param p_many_budget_values_flag If many budget values can be recorded
 * against one budget, this allows breakdowns of budget values.
 * @param p_reporting_sequence The sort order to report measures.
 * @param p_item_type_usage_id The calculation function used to derive cost
 * values.
 * @param p_attribute_category This context value determines which flexfield
 * structure to use with the descriptive flexfield segments.
 * @param p_attribute1 Descriptive flexfield segment.
 * @param p_attribute2 Descriptive flexfield segment.
 * @param p_attribute3 Descriptive flexfield segment.
 * @param p_attribute4 Descriptive flexfield segment.
 * @param p_attribute5 Descriptive flexfield segment.
 * @param p_attribute6 Descriptive flexfield segment.
 * @param p_attribute7 Descriptive flexfield segment.
 * @param p_attribute8 Descriptive flexfield segment.
 * @param p_attribute9 Descriptive flexfield segment.
 * @param p_attribute10 Descriptive flexfield segment.
 * @param p_attribute11 Descriptive flexfield segment.
 * @param p_attribute12 Descriptive flexfield segment.
 * @param p_attribute13 Descriptive flexfield segment.
 * @param p_attribute14 Descriptive flexfield segment.
 * @param p_attribute15 Descriptive flexfield segment.
 * @param p_attribute16 Descriptive flexfield segment.
 * @param p_attribute17 Descriptive flexfield segment.
 * @param p_attribute18 Descriptive flexfield segment.
 * @param p_attribute19 Descriptive flexfield segment.
 * @param p_attribute20 Descriptive flexfield segment.
 * @param p_attribute21 Descriptive flexfield segment.
 * @param p_attribute22 Descriptive flexfield segment.
 * @param p_attribute23 Descriptive flexfield segment.
 * @param p_attribute24 Descriptive flexfield segment.
 * @param p_attribute25 Descriptive flexfield segment.
 * @param p_attribute26 Descriptive flexfield segment.
 * @param p_attribute27 Descriptive flexfield segment.
 * @param p_attribute28 Descriptive flexfield segment.
 * @param p_attribute29 Descriptive flexfield segment.
 * @param p_attribute30 Descriptive flexfield segment.
 * @param p_tp_measurement_type_id If p_validate is false, then the ID is set
 * to the unique identifier for the created measurement type. If p_validate is
 * true, then it is null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created measurement type. If p_validate is true, then
 * the value will be null.
 * @rep:displayname Create Measurement Type
 * @rep:category BUSINESS_ENTITY OTA_TRAINING_PLAN
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure Create_measure
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_tp_measurement_code           in     varchar2
  ,p_unit                          in     varchar2
  ,p_budget_level                  in     varchar2
  ,p_cost_level                    in     varchar2
  ,p_many_budget_values_flag       in     varchar2
  ,p_reporting_sequence            in     number   default null
  ,p_item_type_usage_id            in     number   default null
  ,p_attribute_category            in     varchar2 default null
  ,p_attribute1                    in     varchar2 default null
  ,p_attribute2                    in     varchar2 default null
  ,p_attribute3                    in     varchar2 default null
  ,p_attribute4                    in     varchar2 default null
  ,p_attribute5                    in     varchar2 default null
  ,p_attribute6                    in     varchar2 default null
  ,p_attribute7                    in     varchar2 default null
  ,p_attribute8                    in     varchar2 default null
  ,p_attribute9                    in     varchar2 default null
  ,p_attribute10                   in     varchar2 default null
  ,p_attribute11                   in     varchar2 default null
  ,p_attribute12                   in     varchar2 default null
  ,p_attribute13                   in     varchar2 default null
  ,p_attribute14                   in     varchar2 default null
  ,p_attribute15                   in     varchar2 default null
  ,p_attribute16                   in     varchar2 default null
  ,p_attribute17                   in     varchar2 default null
  ,p_attribute18                   in     varchar2 default null
  ,p_attribute19                   in     varchar2 default null
  ,p_attribute20                   in     varchar2 default null
  ,p_attribute21                   in     varchar2 default null
  ,p_attribute22                   in     varchar2 default null
  ,p_attribute23                   in     varchar2 default null
  ,p_attribute24                   in     varchar2 default null
  ,p_attribute25                   in     varchar2 default null
  ,p_attribute26                   in     varchar2 default null
  ,p_attribute27                   in     varchar2 default null
  ,p_attribute28                   in     varchar2 default null
  ,p_attribute29                   in     varchar2 default null
  ,p_attribute30                   in     varchar2 default null
  ,p_tp_measurement_type_id           out nocopy number
  ,p_object_version_number            out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_measure >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a measurement type.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The measurement type to be updated must exist.
 *
 * <p><b>Post Success</b><br>
 * The measurement type is successfully updated.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the measurement type, and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_tp_measurement_type_id The unique identifier for the measurement
 * type to be updated.
 * @param p_object_version_number Pass in the current version number of the
 * measurement type to be updated. When the API completes, if p_validate is
 * false, will be set to the new version number of the updated measurement
 * type. If p_validate is true will be set to the same value which is passed
 * in.
 * @param p_unit The units of measure. Valid values are 'I', 'M','N', from the
 * 'UNITS' lookup type.
 * @param p_budget_level The level at which this can be used for budgeting.
 * Valid values exist in the 'OTA_TRAINING_PLAN_BUDGET_LEVEL' lookup type.
 * @param p_cost_level The level at which this can be used for recording costs.
 * Valid values exist in the 'OTA_TRAINING_PLAN_COST_LEVEL' lookup type.
 * @param p_many_budget_values_flag If many budget values can be recorded
 * against one budget, this allows breakdowns of budget values.
 * @param p_reporting_sequence The sort order to report measures
 * @param p_item_type_usage_id The calculation function used to derive cost
 * values.
 * @param p_attribute_category This context value determines which flexfield
 * structure to use with the descriptive flexfield segments.
 * @param p_attribute1 Descriptive flexfield segment.
 * @param p_attribute2 Descriptive flexfield segment.
 * @param p_attribute3 Descriptive flexfield segment.
 * @param p_attribute4 Descriptive flexfield segment.
 * @param p_attribute5 Descriptive flexfield segment.
 * @param p_attribute6 Descriptive flexfield segment.
 * @param p_attribute7 Descriptive flexfield segment.
 * @param p_attribute8 Descriptive flexfield segment.
 * @param p_attribute9 Descriptive flexfield segment.
 * @param p_attribute10 Descriptive flexfield segment.
 * @param p_attribute11 Descriptive flexfield segment.
 * @param p_attribute12 Descriptive flexfield segment.
 * @param p_attribute13 Descriptive flexfield segment.
 * @param p_attribute14 Descriptive flexfield segment.
 * @param p_attribute15 Descriptive flexfield segment.
 * @param p_attribute16 Descriptive flexfield segment.
 * @param p_attribute17 Descriptive flexfield segment.
 * @param p_attribute18 Descriptive flexfield segment.
 * @param p_attribute19 Descriptive flexfield segment.
 * @param p_attribute20 Descriptive flexfield segment.
 * @param p_attribute21 Descriptive flexfield segment.
 * @param p_attribute22 Descriptive flexfield segment.
 * @param p_attribute23 Descriptive flexfield segment.
 * @param p_attribute24 Descriptive flexfield segment.
 * @param p_attribute25 Descriptive flexfield segment.
 * @param p_attribute26 Descriptive flexfield segment.
 * @param p_attribute27 Descriptive flexfield segment.
 * @param p_attribute28 Descriptive flexfield segment.
 * @param p_attribute29 Descriptive flexfield segment.
 * @param p_attribute30 Descriptive flexfield segment.
 * @rep:displayname Update Measurement Type
 * @rep:category BUSINESS_ENTITY OTA_TRAINING_PLAN
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure Update_measure
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_tp_measurement_type_id        in     number
  ,p_object_version_number         in out nocopy number
  ,p_unit                          in     varchar2 default hr_api.g_varchar2
  ,p_budget_level                  in     varchar2 default hr_api.g_varchar2
  ,p_cost_level                    in     varchar2 default hr_api.g_varchar2
  ,p_many_budget_values_flag       in     varchar2 default hr_api.g_varchar2
  ,p_reporting_sequence            in     number   default hr_api.g_number
  ,p_item_type_usage_id            in     number   default hr_api.g_number
  ,p_attribute_category            in     varchar2 default hr_api.g_varchar2
  ,p_attribute1                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute2                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute3                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute4                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute5                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute6                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute7                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute8                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute9                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute10                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute11                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute12                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute13                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute14                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute15                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute16                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute17                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute18                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute19                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute20                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute21                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute22                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute23                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute24                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute25                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute26                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute27                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute28                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute29                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute30                   in     varchar2 default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_measure >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a measurement type used for recording budget or cost values
 * within an OTA organization training plan.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Learning Management.
 *
 * <p><b>Prerequisites</b><br>
 * The measurement type to be deleted must exist.
 *
 * <p><b>Post Success</b><br>
 * The measurement type is successfully deleted from the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the measurement type, and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_tp_measurement_type_id The unique identifier for the measurement
 * type to be deleted.
 * @param p_object_version_number Current version number of the measurement
 * type to be deleted.
 * @rep:displayname Delete Measurement Type
 * @rep:category BUSINESS_ENTITY OTA_TRAINING_PLAN
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_measure
  (p_validate                      in     boolean  default false
  ,p_tp_measurement_type_id        in     number
  ,p_object_version_number         in     number
  );
end ota_tmt_api;

 

/
