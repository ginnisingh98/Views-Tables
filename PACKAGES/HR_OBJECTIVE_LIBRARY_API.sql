--------------------------------------------------------
--  DDL for Package HR_OBJECTIVE_LIBRARY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_OBJECTIVE_LIBRARY_API" AUTHID CURRENT_USER as
/* $Header: pepmlapi.pkh 120.5 2006/10/20 04:03:46 tpapired noship $ */
/*#
 * This package contains objective library APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Objective Library
*/

--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_library_objective >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new objective.
 *
 * This API allows for a new objective to be added into the objectives library.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 *
 *
 * <p><b>Post Success</b><br>
 * An objective is added to the objectives library.
 *
 * <p><b>Post Failure</b><br>
 * The objective is not created and an appropriate error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Current date
 * @param p_objective_name Objective name.
 * @param p_valid_from The date from which the objective is valid.
 * @param p_valid_to The date after which the objective is no longer valid.
 * @param p_target_date The date by when the objective should be met.
 * @param p_next_review_date Information only date to indicate when the
 * objective should next be reviewed.
 * @param p_group_code Uses the lookup type HR_WPM_GROUP to categorize
 * objectives.
 * @param p_priority_code Uses the lookup type HR_WPM_PRIORITY to
 * provide a default priority.
 * @param p_appraise_flag Uses the lookup type YES_NO to provide a default
 * for whether this objective should be appraised.
 * @param p_weighting_percent Provides a default weighting for this objective,
 * used to score overall appraisal ratings.
 * @param p_measurement_style_code Uses the lookup type HR_WPM_MEASUREMENT_STYLE
 * to indicate the style of measurement.
 * @param p_measure_name The measure by which this objectives' completion
 * should be scored against.
 * @param p_target_value The target measure, either a maximum target or a
 * minimum target, depending on the measure type.
 * @param p_uom_code Uses the lookup type HR_WPM_MEASURE_UOM to determine the
 * measures' unit of measure.
 * @param p_measure_type_code Uses the lookup type HR_WPM_MEASURE_TYPE to
 * determine whether the target measure is a minimum or maximum.
 * @param p_measure_comments Comments regarding the measure and target.
 * @param p_eligibility_type_code Uses the lookup type HR_WPM_ELIGIBILITY to
 * determine the eligibility.
 * @param p_details Provides further objective details.
 * @param p_success_criteria Additional criteria that determines the success
 * of this objective.
 * @param p_comments General comments about this objective.
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
 * @param p_objective_id Objective id system generated objective primary key.
 * @param p_object_version_number System generated version of row. Increments by
 * one with each update.
 * @param p_duplicate_name_warning Set to true if an objective with the same
 * name already exists.
 * @param p_weighting_over_100_warning Set to true if the weighting has been set
 * to a value greater than 100 or to a negative value.
 * @param p_weighting_appraisal_warning Set to true if a weighting has been
 * defined but the objective has not been marked to be included in appraisals.
 * @rep:displayname Create Library Objective
 * @rep:category BUSINESS_ENTITY PER_OBJECTIVE_LIBRARY
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--

procedure create_library_objective
  (p_validate                      in   boolean   	default false
  ,p_effective_date                in   date
  ,p_objective_name	           in	varchar2
  ,p_valid_from	                   in	date	    	default null
  ,p_valid_to	                   in	date	    	default null
  ,p_target_date	           in	date	    	default null
  ,p_next_review_date	           in	date	    	default null
  ,p_group_code	         	   in	varchar2  	default null
  ,p_priority_code	  	   in	varchar2  	default null
  ,p_appraise_flag	           in	varchar2  	default 'Y'
  ,p_weighting_percent	           in	number          default null
  ,p_measurement_style_code	   in	varchar2        default 'N_M'
  ,p_measure_name	           in	varchar2        default null
  ,p_target_value                  in   number          default null
  ,p_uom_code	   	           in	varchar2	default null
  ,p_measure_type_code		   in	varchar2	default null
  ,p_measure_comments		   in	varchar2	default null
  ,p_eligibility_type_code	   in	varchar2	default 'N_P'
  ,p_details			   in	varchar2	default null
  ,p_success_criteria		   in	varchar2	default null
  ,p_comments			   in	varchar2	default null
  ,p_attribute_category		   in	varchar2	default null
  ,p_attribute1			   in	varchar2	default null
  ,p_attribute2			   in	varchar2	default null
  ,p_attribute3			   in	varchar2	default null
  ,p_attribute4			   in	varchar2	default null
  ,p_attribute5			   in	varchar2	default null
  ,p_attribute6			   in	varchar2	default null
  ,p_attribute7			   in	varchar2	default null
  ,p_attribute8			   in	varchar2	default null
  ,p_attribute9			   in	varchar2	default null
  ,p_attribute10		   in	varchar2	default null
  ,p_attribute11		   in	varchar2	default null
  ,p_attribute12		   in	varchar2	default null
  ,p_attribute13		   in	varchar2	default null
  ,p_attribute14		   in	varchar2	default null
  ,p_attribute15		   in	varchar2	default null
  ,p_attribute16		   in	varchar2	default null
  ,p_attribute17		   in	varchar2	default null
  ,p_attribute18		   in	varchar2	default null
  ,p_attribute19	 	   in	varchar2	default null
  ,p_attribute20		   in	varchar2	default null
  ,p_attribute21		   in	varchar2	default null
  ,p_attribute22		   in	varchar2	default null
  ,p_attribute23		   in	varchar2	default null
  ,p_attribute24		   in	varchar2	default null
  ,p_attribute25		   in	varchar2	default null
  ,p_attribute26		   in	varchar2	default null
  ,p_attribute27		   in	varchar2	default null
  ,p_attribute28		   in	varchar2	default null
  ,p_attribute29		   in	varchar2	default null
  ,p_attribute30		   in	varchar2	default null
  ,p_objective_id		      out nocopy   number
  ,p_object_version_number	      out nocopy   number
  ,p_duplicate_name_warning           out nocopy   boolean
  ,p_weighting_over_100_warning       out nocopy   boolean
  ,p_weighting_appraisal_warning      out nocopy   boolean
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_library_objective >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an objective.
 *
 * This API updates an existing objective in the objectives library.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The objective id must exist in the objectives library.
 *
 * <p><b>Post Success</b><br>
 * The objective is updated.
 *
 * <p><b>Post Failure</b><br>
 * The objective is not updated and an error raised and any changes rolled back.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Current date.
 * @param p_objective_id Objective id system generated objective primary key.
 * @param p_objective_name Objective name.
 * @param p_valid_from The date from which the objective is valid.
 * @param p_valid_to The date after which the objective is no longer valid.
 * @param p_target_date The date by when the objective should be met.
 * @param p_next_review_date Information only date to indicate when the
 * objective should next be reviewed.
 * @param p_group_code Uses the lookup type HR_WPM_GROUP to categorize
 * objectives.
 * @param p_priority_code Uses the lookup type HR_WPM_PRIORITY to
 * provide a default priority.
 * @param p_appraise_flag Uses the lookup type YES_NO to provide a default
 * for whether this objective should be appraised.
 * @param p_weighting_percent Provides a default weighting for this objective,
 * used to score overall appraisal ratings.
 * @param p_measurement_style_code Uses the lookup type HR_WPM_MEASUREMENT_STYLE
 * to indicate the style of measurement.
 * @param p_measure_name The measure by which this objective's completion
 * should be scored against.
 * @param p_target_value The target measure, either a maximum target or a
 * minimum target, depending on the measure type.
 * @param p_uom_code Uses the lookup type HR_WPM_MEASURE_UOM to determine the
 * measure's unit of measure.
 * @param p_measure_type_code Uses the lookup type HR_WPM_MEASURE_TYPE to
 * determine whether the target measure is a minimum or maximum.
 * @param p_measure_comments Comments regarding the measure and target.
 * @param p_eligibility_type_code Uses the lookup type HR_WPM_ELIGIBILITY to
 * determine the eligibility.
 * @param p_details Provides further objective details.
 * @param p_success_criteria Additional criteria that determines the success
 * of this objective.
 * @param p_comments General comments about this objective.
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
 * @param p_object_version_number System generated version of row. Increments by
 * one with each update.
 * @param p_duplicate_name_warning Set to true if an objective with the same
 * name already exists.
 * @param p_weighting_over_100_warning Set to true if the weighting has been set
 * to a value greater than 100 or to a negative value.
 * @param p_weighting_appraisal_warning Set to true if a weighting has been
 * defined but the objective has not been marked to be included in appraisals.
 * @rep:displayname Update Library Objective
 * @rep:category BUSINESS_ENTITY PER_OBJECTIVE_LIBRARY
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_library_objective
  (p_validate                      in   boolean    default false
  ,p_effective_date                in   date
  ,p_objective_id                  in   number
  ,p_objective_name                in   varchar2   default hr_api.g_varchar2
  ,p_valid_from                    in   date       default hr_api.g_date
  ,p_valid_to                      in   date       default hr_api.g_date
  ,p_target_date             	   in   date       default hr_api.g_date
  ,p_next_review_date              in   date       default hr_api.g_date
  ,p_group_code             	   in   varchar2   default hr_api.g_varchar2
  ,p_priority_code         	   in   varchar2   default hr_api.g_varchar2
  ,p_appraise_flag                 in   varchar2   default hr_api.g_varchar2
  ,p_weighting_percent             in   number     default hr_api.g_number
  ,p_measurement_style_code        in   varchar2   default hr_api.g_varchar2
  ,p_measure_name                  in   varchar2   default hr_api.g_varchar2
  ,p_target_value                  in   number     default hr_api.g_number
  ,p_uom_code       		   in   varchar2   default hr_api.g_varchar2
  ,p_measure_type_code             in   varchar2   default hr_api.g_varchar2
  ,p_measure_comments              in   varchar2   default hr_api.g_varchar2
  ,p_eligibility_type_code         in   varchar2   default hr_api.g_varchar2
  ,p_details                       in   varchar2   default hr_api.g_varchar2
  ,p_success_criteria              in   varchar2   default hr_api.g_varchar2
  ,p_comments                      in   varchar2   default hr_api.g_varchar2
  ,p_attribute_category            in   varchar2   default hr_api.g_varchar2
  ,p_attribute1                    in   varchar2   default hr_api.g_varchar2
  ,p_attribute2                    in   varchar2   default hr_api.g_varchar2
  ,p_attribute3                    in   varchar2   default hr_api.g_varchar2
  ,p_attribute4                    in   varchar2   default hr_api.g_varchar2
  ,p_attribute5                    in   varchar2   default hr_api.g_varchar2
  ,p_attribute6                    in   varchar2   default hr_api.g_varchar2
  ,p_attribute7                    in   varchar2   default hr_api.g_varchar2
  ,p_attribute8                    in   varchar2   default hr_api.g_varchar2
  ,p_attribute9                    in   varchar2   default hr_api.g_varchar2
  ,p_attribute10                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute11                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute12                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute13                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute14                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute15                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute16                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute17                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute18                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute19                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute20                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute21                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute22                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute23                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute24                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute25                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute26                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute27                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute28                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute29                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute30                   in   varchar2   default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy   number
  ,p_duplicate_name_warning           out nocopy   boolean
  ,p_weighting_over_100_warning       out nocopy   boolean
  ,p_weighting_appraisal_warning      out nocopy   boolean
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_library_objective >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes an objective.
 *
 * This API removes an objective from the objectives library.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The objective id must exist.
 *
 * <p><b>Post Success</b><br>
 * The objective is deleted.
 *
 * <p><b>Post Failure</b><br>
 * The objective is not deleted and an error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_objective_id Objective id system generated objective primary key.
 * @param p_object_version_number System generated version of row.
 * @rep:displayname Delete Library Objective.
 * @rep:category BUSINESS_ENTITY PER_OBJECTIVE_LIBRARY
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--

procedure delete_library_objective
  (p_validate                      in   boolean default false
  ,p_objective_id                  in   number
  ,p_object_version_number         in   number
  );
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_eligy_profile >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--
--
-- Post Success:
--
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure create_eligy_profile
 (p_validate            in    boolean   default false
 ,p_effective_date      in    date
 ,p_business_group_id   in    number
 ,p_name                in    varchar2  default null
 ,p_bnft_cagr_prtn_cd   in    varchar2  default null
 ,p_stat_cd             in    varchar2  default null
 ,p_asmt_to_use_cd      in    varchar2  default null
 ,p_elig_grd_flag       in    varchar2  default 'N'
 ,p_elig_org_unit_flag  in    varchar2  default 'N'
 ,p_elig_job_flag       in    varchar2  default 'N'
 ,p_elig_pstn_flag      in    varchar2  default 'N'
 ,p_eligy_prfl_id         out nocopy number
 ,p_object_version_number out nocopy number
 ,p_effective_start_date  out nocopy date
 ,p_effective_end_date    out nocopy date
 );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_eligy_profile >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--
--
-- Post Success:
--
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure update_eligy_profile
 ( p_validate             in    boolean   default false
  ,p_effective_date       in    date
  ,p_business_group_id    in    number
  ,p_name                 in    varchar2  default null
  ,p_bnft_cagr_prtn_cd     in    varchar2  default null
  ,p_stat_cd               in    varchar2  default null
  ,p_asmt_to_use_cd        in    varchar2  default null
  ,p_elig_grd_flag         in    varchar2  default 'N'
  ,p_elig_org_unit_flag    in    varchar2  default 'N'
  ,p_elig_job_flag         in    varchar2  default 'N'
  ,p_elig_pstn_flag        in    varchar2  default 'N'
  ,p_eligy_prfl_id         in   number
  ,p_object_version_number in out nocopy number
  ,p_effective_start_date   out nocopy date
  ,p_effective_end_date     out nocopy date
  ,p_datetrack_mode   in varchar2
 );
-- ----------------------------------------------------------------------------
-- |--------------------------< create_eligy_object >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--
-- Post Success:
--
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--
-- Post Failure:
--
--
-- Access Status:
-- Internal Development Use Only.
--
-- {End Of Comments}
--
procedure create_eligy_object
  (p_validate                       in boolean    default false
  ,p_elig_obj_id                    out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number
  ,p_table_name                     in  varchar2
  ,p_column_name                    in  varchar2
  ,p_column_value                   in  varchar2
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
 );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_eligy_object >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure update_eligy_object
  (p_validate                       in boolean    default false
  ,p_elig_obj_id                    in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_table_name                     in  varchar2  default hr_api.g_varchar2
  ,p_column_name                    in  varchar2  default hr_api.g_varchar2
  ,p_column_value                   in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
);
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_eligy_object >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure delete_eligy_object
  (p_validate                       in boolean        default false
  ,p_elig_obj_id                    in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in date
  ,p_datetrack_mode                 in varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_elig_obj_elig_prfl >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure create_elig_obj_elig_prfl
  (p_validate                   in    boolean    default false
  ,p_elig_obj_elig_prfl_id        out nocopy number
  ,p_effective_start_date         out nocopy date
  ,p_effective_end_date           out nocopy date
  ,p_business_group_id          in    number    default null
  ,p_elig_obj_id                in    number    default null
  ,p_elig_prfl_id               in    number    default null
  ,p_object_version_number        out nocopy number
  ,p_effective_date             in    date
 );
-- ----------------------------------------------------------------------------
-- |-----------------------< update_elig_obj_elig_prfl >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure update_elig_obj_elig_prfl
  (p_validate                       in boolean    default false
  ,p_elig_obj_elig_prfl_id         in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_elig_obj_id                    in  number    default hr_api.g_number
  ,p_elig_prfl_id                   in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_elig_obj_elig_prfl >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure delete_elig_obj_elig_prfl
  (p_validate                       in boolean    default false
  ,p_elig_obj_elig_prfl_id         in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_eligy_grade >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--   p_eligy_prfl_id                Yes  number    PK of record
--
-- Post Failure:
--
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure create_eligy_grade
 (p_validate            	 in    boolean   default false
 ,p_elig_grd_prte_id               out nocopy number
 ,p_effective_start_date           out nocopy date
 ,p_effective_end_date             out nocopy date
 ,p_business_group_id            in    number    default null
 ,p_eligy_prfl_id                in    number    default null
 ,p_grade_id                     in    number    default null
 ,p_ordr_num                     in    number    default null
 ,p_object_version_number          out nocopy number
 ,p_effective_date                 in  date
);
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_eligy_grade >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--   p_eligy_prfl_id                Yes  number    PK of record
--
-- Post Failure:
--
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure update_eligy_grade
  (p_validate                       in boolean    default false
  ,p_elig_grd_prte_id               in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_eligy_prfl_id                  in  number    default hr_api.g_number
  ,p_grade_id                       in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_eligy_grade >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--   p_eligy_prfl_id                Yes  number    PK of record
--
-- Post Failure:
--
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure delete_eligy_grade
  (p_validate                       in boolean    default false
  ,p_elig_grd_prte_id               in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_eligy_org >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--   p_eligy_prfl_id                Yes  number    PK of record
--
-- Post Failure:
--
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure create_eligy_org
 (p_validate                     in    boolean   default false
 ,p_elig_org_unit_prte_id          out nocopy number
 ,p_effective_start_date           out nocopy date
 ,p_effective_end_date             out nocopy date
 ,p_business_group_id            in    number    default null
 ,p_eligy_prfl_id                in    number    default null
 ,p_organization_id              in    number    default null
 ,p_ordr_num                     in    number    default null
 ,p_object_version_number          out nocopy number
 ,p_effective_date                 in  date
);
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_eligy_org >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--   p_eligy_prfl_id                Yes  number    PK of record
--
-- Post Failure:
--
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure update_eligy_org
  (p_validate                       in boolean    default false
  ,p_elig_org_unit_prte_id          in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_eligy_prfl_id                  in  number    default hr_api.g_number
  ,p_organization_id                in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_eligy_org >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--   p_eligy_prfl_id                Yes  number    PK of record
--
-- Post Failure:
--
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure delete_eligy_org
  (p_validate                       in boolean    default false
  ,p_elig_org_unit_prte_id          in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );

--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_eligy_position >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--   p_eligy_prfl_id                Yes  number    PK of record
--
-- Post Failure:
--
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure create_eligy_position
 (p_validate                     in    boolean   default false
 ,p_elig_pstn_prte_id               out nocopy number
 ,p_effective_start_date           out nocopy date
 ,p_effective_end_date             out nocopy date
 ,p_business_group_id            in    number    default null
 ,p_eligy_prfl_id                in    number    default null
 ,p_position_id                  in    number    default null
 ,p_ordr_num                     in    number    default null
 ,p_object_version_number          out nocopy number
 ,p_effective_date                 in  date
);
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_eligy_position >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--   p_eligy_prfl_id                Yes  number    PK of record
--
-- Post Failure:
--
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure update_eligy_position
  (p_validate                       in boolean    default false
  ,p_elig_pstn_prte_id               in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_eligy_prfl_id                  in  number    default hr_api.g_number
  ,p_position_id                    in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_eligy_position >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--   p_eligy_prfl_id                Yes  number    PK of record
--
-- Post Failure:
--
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure delete_eligy_position
  (p_validate                       in boolean    default false
  ,p_elig_pstn_prte_id               in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );

--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_eligy_job >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--   p_eligy_prfl_id                Yes  number    PK of record
--
-- Post Failure:
--
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure create_eligy_job
 (p_validate                     in    boolean   default false
 ,p_elig_job_prte_id               out nocopy number
 ,p_effective_start_date           out nocopy date
 ,p_effective_end_date             out nocopy date
 ,p_business_group_id            in    number    default null
 ,p_eligy_prfl_id                in    number    default null
 ,p_job_id                       in    number    default null
 ,p_ordr_num                     in    number    default null
 ,p_object_version_number          out nocopy number
 ,p_effective_date                 in  date
);
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_eligy_job >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--   p_eligy_prfl_id                Yes  number    PK of record
--
-- Post Failure:
--
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure update_eligy_job
  (p_validate                       in boolean    default false
  ,p_elig_job_prte_id               in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_eligy_prfl_id                  in  number    default hr_api.g_number
  ,p_job_id                       in  number    default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_eligy_job >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  Commit or Rollback.
--
-- Post Success:
--
-- Out Parameters:
--   Name                           Reqd Type     Description
--   p_eligy_prfl_id                Yes  number    PK of record
--
-- Post Failure:
--
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure delete_eligy_job
  (p_validate                       in boolean    default false
  ,p_elig_job_prte_id               in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
end HR_OBJECTIVE_LIBRARY_API;

 

/
