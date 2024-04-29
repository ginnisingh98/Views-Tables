--------------------------------------------------------
--  DDL for Package HR_JOB_REQUIREMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_JOB_REQUIREMENT_API" AUTHID CURRENT_USER as
/* $Header: pejbrapi.pkh 120.1 2005/10/02 02:17:51 aroussel $ */
/*#
 * This package contains APIs for maintaining job requirement information.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Job Requirement
*/
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_job_requirement >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a requirement information relating to a job.
 *
 * The job requirement is a Special Information Type relating to a job.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The job must exist. The combination of job and the key flexfield segments
 * must not have been used already.
 *
 * <p><b>Post Success</b><br>
 * The API will create the job requirement.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the job requirement and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_id_flex_num Identifies the structure of the Personal Analysis Key
 * Flexfield to use for this job requirement.
 * @param p_job_id Identifies the job of the assignment
 * @param p_comments Comment text.
 * @param p_essential Value 'Y' indicates the requirement is an essential
 * requirement. Otherwise, must be set to 'N'
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
 * @param p_segment1 Key flexfield segment of Personal Analysis Key Flexfield
 * @param p_segment2 Key flexfield segment of Personal Analysis Key Flexfield
 * @param p_segment3 Key flexfield segment of Personal Analysis Key Flexfield
 * @param p_segment4 Key flexfield segment of Personal Analysis Key Flexfield
 * @param p_segment5 Key flexfield segment of Personal Analysis Key Flexfield
 * @param p_segment6 Key flexfield segment of Personal Analysis Key Flexfield
 * @param p_segment7 Key flexfield segment of Personal Analysis Key Flexfield
 * @param p_segment8 Key flexfield segment of Personal Analysis Key Flexfield
 * @param p_segment9 Key flexfield segment of Personal Analysis Key Flexfield
 * @param p_segment10 Key flexfield segment of Personal Analysis Key Flexfield
 * @param p_segment11 Key flexfield segment of Personal Analysis Key Flexfield
 * @param p_segment12 Key flexfield segment of Personal Analysis Key Flexfield
 * @param p_segment13 Key flexfield segment of Personal Analysis Key Flexfield
 * @param p_segment14 Key flexfield segment of Personal Analysis Key Flexfield
 * @param p_segment15 Key flexfield segment of Personal Analysis Key Flexfield
 * @param p_segment16 Key flexfield segment of Personal Analysis Key Flexfield
 * @param p_segment17 Key flexfield segment of Personal Analysis Key Flexfield
 * @param p_segment18 Key flexfield segment of Personal Analysis Key Flexfield
 * @param p_segment19 Key flexfield segment of Personal Analysis Key Flexfield
 * @param p_segment20 Key flexfield segment of Personal Analysis Key Flexfield
 * @param p_segment21 Key flexfield segment of Personal Analysis Key Flexfield
 * @param p_segment22 Key flexfield segment of Personal Analysis Key Flexfield
 * @param p_segment23 Key flexfield segment of Personal Analysis Key Flexfield
 * @param p_segment24 Key flexfield segment of Personal Analysis Key Flexfield
 * @param p_segment25 Key flexfield segment of Personal Analysis Key Flexfield
 * @param p_segment26 Key flexfield segment of Personal Analysis Key Flexfield
 * @param p_segment27 Key flexfield segment of Personal Analysis Key Flexfield
 * @param p_segment28 Key flexfield segment of Personal Analysis Key Flexfield
 * @param p_segment29 Key flexfield segment of Personal Analysis Key Flexfield
 * @param p_segment30 Key flexfield segment of Personal Analysis Key Flexfield
 * @param p_concat_segments Concatenated segments of Personal Analysis Key
 * Flexfield
 * @param p_job_requirement_id If p_validate is false, uniquely identifies the
 * job requirement created. If p_validate is true, set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created job requirement. If p_validate is true, then
 * the value will be null.
 * @param p_analysis_criteria_id If p_validate is false, uniquely identifies
 * the combination of segments of Personal Analysis Key Flexfield recorded for
 * this job requirement. If p_validate is true, then the value is set to null.
 * @rep:displayname Create Job Requirement
 * @rep:category BUSINESS_ENTITY PER_JOB
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_job_requirement
  (p_validate                      in     boolean  default false
  ,p_id_flex_num                   in     number
  ,p_job_id                        in     number
  ,p_comments                      in     varchar2 default null
  ,p_essential                     in     varchar2 default 'N'
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
  ,p_segment1                      in     varchar2 default null
  ,p_segment2                      in     varchar2 default null
  ,p_segment3                      in     varchar2 default null
  ,p_segment4                      in     varchar2 default null
  ,p_segment5                      in     varchar2 default null
  ,p_segment6                      in     varchar2 default null
  ,p_segment7                      in     varchar2 default null
  ,p_segment8                      in     varchar2 default null
  ,p_segment9                      in     varchar2 default null
  ,p_segment10                     in     varchar2 default null
  ,p_segment11                     in     varchar2 default null
  ,p_segment12                     in     varchar2 default null
  ,p_segment13                     in     varchar2 default null
  ,p_segment14                     in     varchar2 default null
  ,p_segment15                     in     varchar2 default null
  ,p_segment16                     in     varchar2 default null
  ,p_segment17                     in     varchar2 default null
  ,p_segment18                     in     varchar2 default null
  ,p_segment19                     in     varchar2 default null
  ,p_segment20                     in     varchar2 default null
  ,p_segment21                     in     varchar2 default null
  ,p_segment22                     in     varchar2 default null
  ,p_segment23                     in     varchar2 default null
  ,p_segment24                     in     varchar2 default null
  ,p_segment25                     in     varchar2 default null
  ,p_segment26                     in     varchar2 default null
  ,p_segment27                     in     varchar2 default null
  ,p_segment28                     in     varchar2 default null
  ,p_segment29                     in     varchar2 default null
  ,p_segment30                     in     varchar2 default null
  ,p_concat_segments               in     varchar2 default null
  ,p_job_requirement_id               out nocopy number
  ,p_object_version_number            out nocopy number
  ,p_analysis_criteria_id          in out nocopy number
  );
--
--
end hr_job_requirement_api;
--

 

/
