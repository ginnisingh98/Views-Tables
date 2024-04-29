--------------------------------------------------------
--  DDL for Package HR_CAGR_GRADES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CAGR_GRADES_API" AUTHID CURRENT_USER as
/* $Header: pegraapi.pkh 120.1 2005/10/02 02:17:12 aroussel $ */
/*#
 * This package contains APIs which maintain collective agreement grades.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Collective Agreement Grade
*/
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_cagr_grades >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a collective agreement grade.
 *
 * There may be one or many collectively agreed grades for a specific
 * collective agreement. The grades are defined according to the grade
 * structure that has been defined for the collective agreement. The grades
 * that are set up are considered to be the reference grades for the collective
 * agreement, although it may be possible to define other grades if dynamic
 * inserts are allowed on the grade structure.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The grade structure according to which this grade will be defined must exist
 *
 * <p><b>Post Success</b><br>
 * The collective agreement grade is created.
 *
 * <p><b>Post Failure</b><br>
 * The collective agreement grade is not created and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_cagr_grade_id If p_validate is false, then this uniquely identifies
 * the collective agreement grade created. If p_validate is true, then set to
 * null.
 * @param p_cagr_grade_structure_id Uniquely identifies the grade structure
 * according to which this grade is defined.
 * @param p_segment1 Component of the collective agreement grade name.
 * @param p_segment2 Component of the collective agreement grade name.
 * @param p_segment3 Component of the collective agreement grade name.
 * @param p_segment4 Component of the collective agreement grade name.
 * @param p_segment5 Component of the collective agreement grade name.
 * @param p_segment6 Component of the collective agreement grade name.
 * @param p_segment7 Component of the collective agreement grade name.
 * @param p_segment8 Component of the collective agreement grade name.
 * @param p_segment9 Component of the collective agreement grade name.
 * @param p_segment10 Component of the collective agreement grade name.
 * @param p_segment11 Component of the collective agreement grade name.
 * @param p_segment12 Component of the collective agreement grade name.
 * @param p_segment13 Component of the collective agreement grade name.
 * @param p_segment14 Component of the collective agreement grade name.
 * @param p_segment15 Component of the collective agreement grade name.
 * @param p_segment16 Component of the collective agreement grade name.
 * @param p_segment17 Component of the collective agreement grade name.
 * @param p_segment18 Component of the collective agreement grade name.
 * @param p_segment19 Component of the collective agreement grade name.
 * @param p_segment20 Component of the collective agreement grade name.
 * @param p_concat_segments The concatenation of all segment values for this
 * grade.
 * @param p_sequence The sequence of this grade within the grade structure.
 * @param p_cagr_grade_def_id Uniquely identifies the specific combination of
 * segments used in this grade within the internal key flexfield combinations
 * table. May be supplied directly or derived.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created collective agreement grade. If p_validate is
 * true, then the value will be null.
 * @param p_name If p_validate is false, concatenation of all segments. If
 * p_validate is true, set to null.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @rep:displayname Create Collective Agreement Grade
 * @rep:category BUSINESS_ENTITY PER_COLLECTIVE_AGREEMENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_cagr_grades
  (p_validate                       in  boolean   default false
  ,p_cagr_grade_id                  out nocopy number
  ,p_cagr_grade_structure_id        in  number    default null
  ,p_segment1			    in  varchar2  default null
  ,p_segment2			    in  varchar2  default null
  ,p_segment3			    in  varchar2  default null
  ,p_segment4			    in  varchar2  default null
  ,p_segment5			    in  varchar2  default null
  ,p_segment6			    in  varchar2  default null
  ,p_segment7			    in  varchar2  default null
  ,p_segment8			    in  varchar2  default null
  ,p_segment9			    in  varchar2  default null
  ,p_segment10			    in  varchar2  default null
  ,p_segment11			    in  varchar2  default null
  ,p_segment12			    in  varchar2  default null
  ,p_segment13			    in  varchar2  default null
  ,p_segment14			    in  varchar2  default null
  ,p_segment15			    in  varchar2  default null
  ,p_segment16			    in  varchar2  default null
  ,p_segment17			    in  varchar2  default null
  ,p_segment18			    in  varchar2  default null
  ,p_segment19			    in  varchar2  default null
  ,p_segment20			    in  varchar2  default null
  ,p_concat_segments		    in  varchar2  default null
  ,p_sequence                       in  number    default null
  ,p_cagr_grade_def_id              in out nocopy number
  ,p_object_version_number          out nocopy number
  ,p_name		            out nocopy varchar2
  ,p_effective_date		    in date
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_cagr_grades >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a collective agreement grade.
 *
 * This API updates a collective agreement grade. There may be one or many
 * collectively agreed grades for a specific collective agreement. The grades
 * are defined according to the grade structure that has been defined for the
 * collective agreement.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The collective agreement grade to be updated must exist. The grade structure
 * according to which this grade will be defined must exist.
 *
 * <p><b>Post Success</b><br>
 * The collective agreement grade is updated.
 *
 * <p><b>Post Failure</b><br>
 * The collective agreement grade is not updated and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_cagr_grade_id Uniquely identifies the collective agreement grade to
 * be updated.
 * @param p_sequence The sequence of this grade within the grade structure.
 * @param p_segment1 Component of the collective agreement grade name.
 * @param p_segment2 Component of the collective agreement grade name.
 * @param p_segment3 Component of the collective agreement grade name.
 * @param p_segment4 Component of the collective agreement grade name.
 * @param p_segment5 Component of the collective agreement grade name.
 * @param p_segment6 Component of the collective agreement grade name.
 * @param p_segment7 Component of the collective agreement grade name.
 * @param p_segment8 Component of the collective agreement grade name.
 * @param p_segment9 Component of the collective agreement grade name.
 * @param p_segment10 Component of the collective agreement grade name.
 * @param p_segment11 Component of the collective agreement grade name.
 * @param p_segment12 Component of the collective agreement grade name.
 * @param p_segment13 Component of the collective agreement grade name.
 * @param p_segment14 Component of the collective agreement grade name.
 * @param p_segment15 Component of the collective agreement grade name.
 * @param p_segment16 Component of the collective agreement grade name.
 * @param p_segment17 Component of the collective agreement grade name.
 * @param p_segment18 Component of the collective agreement grade name.
 * @param p_segment19 Component of the collective agreement grade name.
 * @param p_segment20 Component of the collective agreement grade name.
 * @param p_concat_segments The concatenation of all segment values for this
 * grade.
 * @param p_object_version_number Pass in the current version number of the
 * collective agreement grade to be updated. When the API completes if
 * p_validate is false, will be set to the new version number of the updated
 * collective agreement grade. If p_validate is true will be set to the same
 * value which was passed in.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_name If p_validate is false, the concatenation of all segments. If
 * p_validate is true, set to null.
 * @param p_cagr_grade_def_id Uniquely identifies the specific combination of
 * segments used in this grade within the internal key flexfield combinations
 * table. May be supplied directly or derived.
 * @rep:displayname Update Collective Agreement Grade
 * @rep:category BUSINESS_ENTITY PER_COLLECTIVE_AGREEMENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_cagr_grades
  (p_validate                       in  boolean   default false
  ,p_cagr_grade_id                  in  number
  ,p_sequence                       in  number    default hr_api.g_number
  ,p_segment1			    in  varchar2  default hr_api.g_varchar2
  ,p_segment2			    in  varchar2  default hr_api.g_varchar2
  ,p_segment3			    in  varchar2  default hr_api.g_varchar2
  ,p_segment4			    in  varchar2  default hr_api.g_varchar2
  ,p_segment5			    in  varchar2  default hr_api.g_varchar2
  ,p_segment6			    in  varchar2  default hr_api.g_varchar2
  ,p_segment7			    in  varchar2  default hr_api.g_varchar2
  ,p_segment8			    in  varchar2  default hr_api.g_varchar2
  ,p_segment9			    in  varchar2  default hr_api.g_varchar2
  ,p_segment10			    in  varchar2  default hr_api.g_varchar2
  ,p_segment11			    in  varchar2  default hr_api.g_varchar2
  ,p_segment12			    in  varchar2  default hr_api.g_varchar2
  ,p_segment13			    in  varchar2  default hr_api.g_varchar2
  ,p_segment14			    in  varchar2  default hr_api.g_varchar2
  ,p_segment15			    in  varchar2  default hr_api.g_varchar2
  ,p_segment16			    in  varchar2  default hr_api.g_varchar2
  ,p_segment17			    in  varchar2  default hr_api.g_varchar2
  ,p_segment18			    in  varchar2  default hr_api.g_varchar2
  ,p_segment19			    in  varchar2  default hr_api.g_varchar2
  ,p_segment20			    in  varchar2  default hr_api.g_varchar2
  ,p_concat_segments		    in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date		    in  date
  ,p_name			    out nocopy varchar2
  ,p_cagr_grade_def_id              in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_cagr_grades >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a collective agreement grade.
 *
 * This API deletes a collective agreement grade. There may be one or many
 * collectively agreed grades for a specific collective agreement. The grades
 * are defined according to the grade structure that has been defined for the
 * collective agreement.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The collective agreement grade to be deleted must exist.
 *
 * <p><b>Post Success</b><br>
 * The collective agreement grade is deleted.
 *
 * <p><b>Post Failure</b><br>
 * The collective agreement grade is not deleted and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_cagr_grade_id Uniquely identifies the collective agreement grade to
 * be deleted.
 * @param p_object_version_number Current version number of the collective
 * agreement grade to be deleted
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @rep:displayname Delete Collective Agreement Grades
 * @rep:category BUSINESS_ENTITY PER_COLLECTIVE_AGREEMENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_cagr_grades
  (p_validate                       in  boolean  default false
  ,p_cagr_grade_id                  in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date		    in  date
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------------< lck >---------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_cagr_grade_id                 Yes  number   PK of record
--   p_object_version_number         Yes  number   OVN of record
--   p_effective_date	             No   date     Session date
--
-- Post Success:
--
--   Name                           Type     Description
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure lck
  (
    p_cagr_grade_id                 in number
   ,p_object_version_number         in number
   ,p_effective_date		    in date
  );
--
end hr_cagr_grades_api;

 

/
