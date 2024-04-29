--------------------------------------------------------
--  DDL for Package HR_OBJECTIVES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_OBJECTIVES_API" AUTHID CURRENT_USER as
/* $Header: peobjapi.pkh 120.6 2006/05/05 07:17:16 tpapired noship $*/
/*#
 * This package contains objective APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Objective
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_objective >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new objective. An objective is a target or goal which
 * may be evaluated during an appraisal (performance review). An objective is
 * for a specific person. An objective may change over  time.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The person for whom the objective is created must exist.
 *
 * <p><b>Post Success</b><br>
 * Objective is created.
 *
 * <p><b>Post Failure</b><br>
 * Objective is not created and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_business_group_id Business group of the person who owns this
 * objective.
 * @param p_name Objective name.
 * @param p_start_date Start date of the objective.
 * @param p_owning_person_id Person for whom the objective is being created.
 * @param p_target_date Target date for this objective to be achieved.
 * @param p_achievement_date Date when objective is achieved.
 * @param p_detail Detailed definition of the objective.
 * @param p_comments Comments text.
 * @param p_success_criteria Success criteria or performance matrices used for
 * this objective.
 * @param p_appraisal_id Identifies the appraisal record.
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
 * @param p_scorecard_id Identifies the personal scorecard to which
 * the objective belongs.
 * @param p_copied_from_library_id Identifies the library objective from which this objective
 * is copied.
 * @param p_copied_from_objective_id Identifies the objective from which this objective was
 * copied.
 * @param p_aligned_with_objective_id Identifies the objective to which this objective
 * is aligned.
 * @param p_next_review_date Indicates when the objective should next be reviewed.
 * @param p_group_code     Group to which this objective belongs. Valid values are
 * defined by "HR_WPM_GROUP" lookup type
 * @param p_priority_code Priority of the objective. Valid values are defined by
 * "HR_WPM_PRIORITY" lookup type.
 * @param p_appraise_flag  Indicates whether this objective should be appraised.
 * Valid values are defined by "YES_NO" lookup type.
 * @param p_verified_flag Indicates whether the objective's achievement has been verified
 * against the measure. Valid values are defined by "YES_NO" lookup type.
 * @param p_target_value The target measure, either a maximum or minimum target, depending
 * on the measure type.
 * @param p_actual_value   The actual quantity achieved against the target measure.
 * @param p_weighting_percent Weighting for this objective, used to score overall
 * appraisal ratings.
 * @param p_complete_percent  The percentage complete.
 * @param p_uom_code  Determine the measure's unit of measure. Valid values are defined by
 * "HR_WPM_MEASURE_UOM" lookup type.
 * @param p_measurement_style_code Measurement style of this objective's measure. Valid
 * values are defined by "HR_WPM_MEASUREMENT_STYLE" lookup type.
 * @param p_measure_name The measure by which this objective's completion should be
 * scored against
 * @param p_measure_type_code Measure type for this measure to determine whether the target
 * measure is a minimum or maximum. Valid values are defined by "HR_WPM_MEASURE_TYPE" lookup type
 * @param p_measure_comments   Comments regarding the measure and target.
 * @param p_sharing_access_code Access permissions on this objective. Valid values are
 * defined by "HR_WPM_OBJECTIVE_SHARING" lookup type.
 * @param  p_weighting_over_100_warning  If set to true, then the combined weighting of
 * objective in the scorecard is greater than 100%
 * @param  p_weighting_appraisal_warning If set to true, then weighting of this objective
 * is not marked to be included in the appraisals
 * @param p_objective_id If p_validate is false, uniquely identifies the
 * objective created. If p_validate is true, set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created objective. If p_validate is true, then the
 * value will be null.
 * @rep:displayname Create Objective
 * @rep:category BUSINESS_ENTITY PER_APPRAISAL
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_objective
 (p_validate                     in     boolean  	default false,
  p_effective_date               in     date,
  p_business_group_id            in 	number,
  p_name                         in     varchar2,
  p_start_date                   in 	date,
  p_owning_person_id             in 	number,
  p_target_date                  in 	date             default null,
  p_achievement_date             in 	date             default null,
  p_detail                       in 	varchar2         default null,
  p_comments                     in 	varchar2         default null,
  p_success_criteria             in 	varchar2         default null,
  p_appraisal_id                 in 	number           default null,
  p_attribute_category           in 	varchar2         default null,
  p_attribute1                   in 	varchar2         default null,
  p_attribute2                   in 	varchar2         default null,
  p_attribute3                   in 	varchar2         default null,
  p_attribute4                   in 	varchar2         default null,
  p_attribute5                   in 	varchar2         default null,
  p_attribute6                   in 	varchar2         default null,
  p_attribute7                   in 	varchar2         default null,
  p_attribute8                   in 	varchar2         default null,
  p_attribute9                   in 	varchar2         default null,
  p_attribute10                  in 	varchar2         default null,
  p_attribute11                  in 	varchar2         default null,
  p_attribute12                  in 	varchar2         default null,
  p_attribute13                  in 	varchar2         default null,
  p_attribute14                  in 	varchar2         default null,
  p_attribute15                  in 	varchar2         default null,
  p_attribute16                  in 	varchar2         default null,
  p_attribute17                  in 	varchar2         default null,
  p_attribute18                  in 	varchar2         default null,
  p_attribute19                  in 	varchar2         default null,
  p_attribute20                  in 	varchar2         default null,

  p_attribute21                  in 	varchar2         default null,
  p_attribute22                  in 	varchar2         default null,
  p_attribute23                  in 	varchar2         default null,
  p_attribute24                  in 	varchar2         default null,
  p_attribute25                  in 	varchar2         default null,
  p_attribute26                  in 	varchar2         default null,
  p_attribute27                  in 	varchar2         default null,
  p_attribute28                  in 	varchar2         default null,
  p_attribute29                  in 	varchar2         default null,
  p_attribute30                  in 	varchar2         default null,

  p_scorecard_id                 in     number           default null,
  p_copied_from_library_id       in     number           default null,
  p_copied_from_objective_id     in     number           default null,
  p_aligned_with_objective_id    in     number           default null,

  p_next_review_date             in     date             default null,
  p_group_code                   in     varchar2         default null,
  p_priority_code                in     varchar2         default null,
  p_appraise_flag                in     varchar2         default null,
  p_verified_flag                in     varchar2         default null,

  p_target_value                 in     number           default null,
  p_actual_value                 in     number           default null,
  p_weighting_percent            in     number           default null,
  p_complete_percent             in     number           default null,
  p_uom_code                     in     varchar2         default null,

  p_measurement_style_code       in     varchar2         default null,
  p_measure_name                 in     varchar2         default null,
  p_measure_type_code            in     varchar2         default null,
  p_measure_comments             in     varchar2         default null,
  p_sharing_access_code          in     varchar2         default null,

  p_weighting_over_100_warning   out nocopy   boolean,
  p_weighting_appraisal_warning  out nocopy   boolean,

  p_objective_id                 out nocopy    number,
  p_object_version_number        out nocopy 	number
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< update_objective >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an existing objective. An objective is a target or
 * goal which may be evaluated during an appraisal (performance review).
 * An objective is for a specific person. An objective may change over time.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid objective to be modified must exist.
 *
 * <p><b>Post Success</b><br>
 * Objective is updated.
 *
 * <p><b>Post Failure</b><br>
 * Objective remains unchanged and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_objective_id Identifies the objective to be updated.
 * @param p_object_version_number Pass in the current version number of the
 * objective to be updated. When the API completes if p_validate is false, will
 * be set to the new version number of the updated objective If p_validate is
 * true will be set to the same value which was passed in.
 * @param p_name Objective name.
 * @param p_target_date Target date for this objective to be achieved.
 * @param p_start_date Start date of the objective.
 * @param p_achievement_date Date when objective is achieved.
 * @param p_detail Detailed definition of the objective.
 * @param p_comments Comments text.
 * @param p_success_criteria Success criteria or performance matrices used for
 * this objective.
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
 * @param p_scorecard_id Identifies the personal scorecard to which
 * the objective belongs.
 * @param p_copied_from_library_id Identifies the library objective from which
 * this objective is copied.
 * @param p_copied_from_objective_id Identifies the objective from which this
 * objective was copied.
 * @param p_aligned_with_objective_id Identifies the objective to which this objective
 * is aligned.
 * @param p_next_review_date Indicates when the objective should next be reviewed.
 * @param p_group_code     Group to which this objective belongs. Valid values are
 * defined by "HR_WPM_GROUP" lookup type
 * @param p_priority_code Priority of the objective. Valid values are defined by
 * "HR_WPM_PRIORITY" lookup type.
 * @param p_appraise_flag  Indicates whether this objective should be appraised.
 * Valid values are defined by "YES_NO" lookup type
 * @param p_verified_flag Indicates whether the objective's achievement has been
 * verified against the measure. Valid values are defined by "YES_NO" lookup type.
 * @param p_target_value The target measure, either a maximum or minimum target,
 * depending on the measure type.
 * @param p_actual_value   The actual quantity achieved against the target measure.
 * @param p_weighting_percent Weighting for this objective, used to score overall
 * appraisal ratings.
 * @param p_complete_percent  The percentage complete.
 * @param p_uom_code Determine the measure's unit of measure. Valid values are
 * defined by "HR_WPM_MEASURE_UOM" lookup type.
 * @param p_measurement_style_code Measurement style of this objective's measure.
 * Valid values are defined by "HR_WPM_MEASUREMENT_STYLE" lookup type.
 * @param p_measure_name The measure by which this objective's completion should be
 * scored against
 * @param p_measure_type_code Measure type for this measure to determine whether the target
 * measure is a minimum or maximum. Valid values are defined by "HR_WPM_MEASURE_TYPE" lookup type
 * @param p_measure_comments   Comments regarding the measure and target.
 * @param p_sharing_access_code Access permissions on this objective. Valid values
 * are defined by "HR_WPM_OBJECTIVE_SHARING" lookup type.
 * @param  p_weighting_over_100_warning  If set to true, then the combined weighting of
 * objective in the scorecard is greater than 100%
 * @param  p_weighting_appraisal_warning If set to true, then weighting of this objective
 * is not marked to be included in the appraisals
 * @param p_appraisal_id Identifies the appraisal record.
 * @rep:displayname Update Objective
 * @rep:category BUSINESS_ENTITY PER_APPRAISAL
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_objective
 (p_validate                     in boolean         default false,
  p_effective_date               in date,
  p_objective_id                 in number,
  p_object_version_number        in out nocopy number,
  p_name                         in varchar2         default hr_api.g_varchar2,
  p_target_date                  in date             default hr_api.g_date,
  p_start_date                   in date             default hr_api.g_date,
  p_achievement_date             in date             default hr_api.g_date,
  p_detail                       in varchar2         default hr_api.g_varchar2,
  p_comments                     in varchar2         default hr_api.g_varchar2,
  p_success_criteria             in varchar2         default hr_api.g_varchar2,
  p_attribute_category           in varchar2         default hr_api.g_varchar2,
  p_attribute1                   in varchar2         default hr_api.g_varchar2,
  p_attribute2                   in varchar2         default hr_api.g_varchar2,
  p_attribute3                   in varchar2         default hr_api.g_varchar2,
  p_attribute4                   in varchar2         default hr_api.g_varchar2,
  p_attribute5                   in varchar2         default hr_api.g_varchar2,
  p_attribute6                   in varchar2         default hr_api.g_varchar2,
  p_attribute7                   in varchar2         default hr_api.g_varchar2,
  p_attribute8                   in varchar2         default hr_api.g_varchar2,
  p_attribute9                   in varchar2         default hr_api.g_varchar2,
  p_attribute10                  in varchar2         default hr_api.g_varchar2,
  p_attribute11                  in varchar2         default hr_api.g_varchar2,
  p_attribute12                  in varchar2         default hr_api.g_varchar2,
  p_attribute13                  in varchar2         default hr_api.g_varchar2,
  p_attribute14                  in varchar2         default hr_api.g_varchar2,
  p_attribute15                  in varchar2         default hr_api.g_varchar2,
  p_attribute16                  in varchar2         default hr_api.g_varchar2,
  p_attribute17                  in varchar2         default hr_api.g_varchar2,
  p_attribute18                  in varchar2         default hr_api.g_varchar2,
  p_attribute19                  in varchar2         default hr_api.g_varchar2,
  p_attribute20                  in varchar2         default hr_api.g_varchar2,

  p_attribute21                  in varchar2         default hr_api.g_varchar2,
  p_attribute22                  in varchar2         default hr_api.g_varchar2,
  p_attribute23                  in varchar2         default hr_api.g_varchar2,
  p_attribute24                  in varchar2         default hr_api.g_varchar2,
  p_attribute25                  in varchar2         default hr_api.g_varchar2,
  p_attribute26                  in varchar2         default hr_api.g_varchar2,
  p_attribute27                  in varchar2         default hr_api.g_varchar2,
  p_attribute28                  in varchar2         default hr_api.g_varchar2,
  p_attribute29                  in varchar2         default hr_api.g_varchar2,
  p_attribute30                  in varchar2         default hr_api.g_varchar2,

  p_scorecard_id                 in number           default hr_api.g_number,
  p_copied_from_library_id       in number           default hr_api.g_number,
  p_copied_from_objective_id     in number           default hr_api.g_number,
  p_aligned_with_objective_id    in number           default hr_api.g_number,

  p_next_review_date             in date             default hr_api.g_date,
  p_group_code                   in varchar2         default hr_api.g_varchar2,
  p_priority_code                in varchar2         default hr_api.g_varchar2,
  p_appraise_flag                in varchar2         default hr_api.g_varchar2,
  p_verified_flag                in varchar2         default hr_api.g_varchar2,

  p_target_value                 in number           default hr_api.g_number,
  p_actual_value                 in number           default hr_api.g_number,
  p_weighting_percent            in number           default hr_api.g_number,
  p_complete_percent             in number           default hr_api.g_number,
  p_uom_code                     in varchar2         default hr_api.g_varchar2,

  p_measurement_style_code       in varchar2         default hr_api.g_varchar2,
  p_measure_name                 in varchar2         default hr_api.g_varchar2,
  p_measure_type_code            in varchar2         default hr_api.g_varchar2,
  p_measure_comments             in varchar2         default hr_api.g_varchar2,
  p_sharing_access_code          in varchar2         default hr_api.g_varchar2,

  p_weighting_over_100_warning   out nocopy   boolean,
  p_weighting_appraisal_warning  out nocopy   boolean,
  p_appraisal_id                 in number           default hr_api.g_number

  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< delete_objective >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes an existing objective. An objective is a target or
 * goal which may be evaluated during an appraisal (performance review).
 * An objective is for a specific person. An objective may change over
 * time.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid objective must already exist.
 *
 * <p><b>Post Success</b><br>
 * Objective is deleted.
 *
 * <p><b>Post Failure</b><br>
 * Objective is not deleted and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_objective_id Objective to be deleted. If p_validate is false,
 * uniquely identifies the objective to be deleted. If p_validate is true, set
 * to null.
 * @param p_object_version_number Current version number of the objective to be
 * deleted.
 * @rep:displayname Delete Objective
 * @rep:category BUSINESS_ENTITY PER_APPRAISAL
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_objective
(p_validate                           in boolean default false,
 p_objective_id                       in number,
 p_object_version_number              in number
);
--
end hr_objectives_api;

 

/
