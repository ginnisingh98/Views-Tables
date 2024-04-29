--------------------------------------------------------
--  DDL for Package HR_WPM_IMPORT_LIB_OBJ_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_WPM_IMPORT_LIB_OBJ_API" AUTHID CURRENT_USER as
/* $Header: perioapi.pkh 120.5 2006/10/24 15:49:34 tpapired noship $ */
/*#
 * This package contains importing objectives to objective library.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Import Objective Library
*/

-- ----------------------------------------------------------------------------
-- |-------------------------< import_library_objective >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API imports a new objective through external interfaces e.g. Excel.
 *
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
 * @param p_eligibility_profile_code Identifies elgibility profile to be used for this objective.
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
 * @param p_return_message Returns error messages if any error occured during import.
 * @rep:displayname Import Library Objective
 * @rep:category BUSINESS_ENTITY PER_OBJECTIVE_LIBRARY
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
 procedure IMPORT_LIBRARY_OBJECTIVES
  (
   p_objective_name	           in	varchar2
  ,p_valid_from		           in	date	    	default null
  ,p_valid_to	                   in	date	    	default null
  ,p_target_date	           in	date	    	default null
  ,p_next_review_date	           in	date	    	default null
  ,p_group_code	         	   in	varchar2  	default null
  ,p_priority_code		   in	varchar2  	default null
  ,p_appraise_flag	           in	varchar2  	default 'Y'
  ,p_weighting_percent	           in	number          default null
  ,p_measurement_style_code	   in	varchar2        default 'N_M'
  ,p_measure_name	           in	varchar2        default null
  ,p_measure_comments		   in	varchar2	default null
  ,p_target_value                  in   number          default null
  ,p_uom_code			   in	varchar2	default null
  ,p_measure_type_code		   in	varchar2	default null
  ,p_eligibility_type_code	   in	varchar2        default 'N_P'
  ,p_eligibility_profile_code	   in	number          default null
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
  ,p_return_message                out  nocopy  varchar2
  );

end HR_WPM_IMPORT_LIB_OBJ_API;

 

/
