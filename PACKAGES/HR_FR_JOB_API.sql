--------------------------------------------------------
--  DDL for Package HR_FR_JOB_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FR_JOB_API" AUTHID CURRENT_USER as
/* $Header: pejobfri.pkh 120.2 2006/10/12 09:48:23 nmuthusa noship $ */
/*#
 * This package contains a job API for France.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Job for France
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------------< create_fr_job >---------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a job for a business group for France.
 *
 * The API calls the generic API create_job, with the parameters set as
 * appropriate for a French Job.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * At least one segment of the job key flexfield must have a value.
 *
 * <p><b>Post Success</b><br>
 * The API creates the job successfully in the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the job and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_job_group_id Identifies the job group with which the job is to be
 * associated.
 * @param p_business_group_id Business group in which the job is to be created.
 * @param p_date_from The date on which the job becomes active.
 * @param p_comments Comment text.
 * @param p_date_to The date on which the job ceases to be active.
 * @param p_approval_authority Indicates if job has approval authority.
 * @param p_benchmark_job_flag Value 'Y' indicates that the job is a benchmark
 * job
 * @param p_benchmark_job_id Unique identifier for the benchmark job
 * @param p_emp_rights_flag Value 'Y' indicates that there are extended
 * employment rights associated with this job.
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
 * @param p_insee_pcs_code Insee pcs code. Valid values exist in the
 * 'FR_NEW_PCS_CODE' lookup type.
 * @param p_activity_type Activity Type. Valid values exist in the
 * 'FR_ACTIVITY_TYPE' lookup type.
 * @param p_segment1 Job Key flexfield segment.
 * @param p_segment2 Job Key flexfield segment.
 * @param p_segment3 Job Key flexfield segment.
 * @param p_segment4 Job Key flexfield segment.
 * @param p_segment5 Job Key flexfield segment.
 * @param p_segment6 Job Key flexfield segment.
 * @param p_segment7 Job Key flexfield segment.
 * @param p_segment8 Job Key flexfield segment.
 * @param p_segment9 Job Key flexfield segment.
 * @param p_segment10 Job Key flexfield segment.
 * @param p_segment11 Job Key flexfield segment.
 * @param p_segment12 Job Key flexfield segment.
 * @param p_segment13 Job Key flexfield segment.
 * @param p_segment14 Job Key flexfield segment.
 * @param p_segment15 Job Key flexfield segment.
 * @param p_segment16 Job Key flexfield segment.
 * @param p_segment17 Job Key flexfield segment.
 * @param p_segment18 Job Key flexfield segment.
 * @param p_segment19 Job Key flexfield segment.
 * @param p_segment20 Job Key flexfield segment.
 * @param p_segment21 Job Key flexfield segment.
 * @param p_segment22 Job Key flexfield segment.
 * @param p_segment23 Job Key flexfield segment.
 * @param p_segment24 Job Key flexfield segment.
 * @param p_segment25 Job Key flexfield segment.
 * @param p_segment26 Job Key flexfield segment.
 * @param p_segment27 Job Key flexfield segment.
 * @param p_segment28 Job Key flexfield segment.
 * @param p_segment29 Job Key flexfield segment.
 * @param p_segment30 Job Key flexfield segment.
 * @param p_concat_segments Concatenated segments for the Job Key Flexfield.
 * @param p_job_id If p_validate is false, uniquely identifies the job created.
 * If p_validate is true, set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created job. If p_validate is true, then the value
 * will be null.
 * @param p_job_definition_id If p_validate is false, uniquely identifies the
 * Job Key flexfield combination for this job. If p_validate is true, set to
 * null.
 * @param p_name If p_validate is false, concatenation of all key flexfield
 * segments. If p_validate is true, set to null.
 * @rep:displayname Create Job for France
 * @rep:category BUSINESS_ENTITY PER_JOB
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_fr_job
    (p_validate                      in     boolean  default false
    ,p_job_group_id                  in     number
    ,p_business_group_id             in     number
    ,p_date_from                     in     date
    ,p_comments                      in     varchar2 default null
    ,p_date_to                       in     date     default null
    ,p_approval_authority            in     number   default null
    ,p_benchmark_job_flag            in     varchar2 default 'N'
    ,p_benchmark_job_id              in     number   default null
    ,p_emp_rights_flag               in     varchar2 default 'N'
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
    ,p_insee_pcs_code                in     varchar2 default null
    ,p_activity_type                 in     varchar2 default null
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
    ,p_job_id                           out nocopy number
    ,p_object_version_number            out nocopy number
    ,p_job_definition_id                out nocopy number
    ,p_name                             out nocopy varchar2
    );
--
end hr_fr_job_api;

/
