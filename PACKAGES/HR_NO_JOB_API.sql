--------------------------------------------------------
--  DDL for Package HR_NO_JOB_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_NO_JOB_API" AUTHID CURRENT_USER as
/* $Header: pejobnoi.pkh 120.1 2005/10/02 02:42:31 aroussel $ */
/*#
 * This package contains job APIs for Norway.
 * @rep:scope public
 * @rep:product PER
 * @rep:displayname Create Job for Norway
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------------< create_no_job >---------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new job for Norway.
 *
 * The API calls the generic API create_job, with the parameters set as
 * appropriate for a Norway employee.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * At least one segment of the job key flexfield must have a value.
 *
 * <p><b>Post Success</b><br>
 * A new job record is successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The job is not created and an error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_job_group_id Identifies the job group for which you create the job
 * record.
 * @param p_business_group_id Identifies the business group for which you
 * create the job record.
 * @param p_date_from Start date of job.
 * @param p_comments Comment text.
 * @param p_date_to End date of job.
 * @param p_approval_authority Approval authority.
 * @param p_benchmark_job_flag Flag to indicate whether the job is a benchmark
 * job.
 * @param p_benchmark_job_id ID of benchmark job.
 * @param p_emp_rights_flag Flag to indicate whether there are extended
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
 * @param p_ssb_position_code SSB position code of the job. Valid values are
 * defined in HR_NO_POSITION_CODES lookup type.
 * @param p_working_title Working title of the job.
 * @param p_segment1 Key flexfield segment.
 * @param p_segment2 Key flexfield segment.
 * @param p_segment3 Key flexfield segment.
 * @param p_segment4 Key flexfield segment.
 * @param p_segment5 Key flexfield segment.
 * @param p_segment6 Key flexfield segment.
 * @param p_segment7 Key flexfield segment.
 * @param p_segment8 Key flexfield segment.
 * @param p_segment9 Key flexfield segment.
 * @param p_segment10 Key flexfield segment.
 * @param p_segment11 Key flexfield segment.
 * @param p_segment12 Key flexfield segment.
 * @param p_segment13 Key flexfield segment.
 * @param p_segment14 Key flexfield segment.
 * @param p_segment15 Key flexfield segment.
 * @param p_segment16 Key flexfield segment.
 * @param p_segment17 Key flexfield segment.
 * @param p_segment18 Key flexfield segment.
 * @param p_segment19 Key flexfield segment.
 * @param p_segment20 Key flexfield segment.
 * @param p_segment21 Key flexfield segment.
 * @param p_segment22 Key flexfield segment.
 * @param p_segment23 Key flexfield segment.
 * @param p_segment24 Key flexfield segment.
 * @param p_segment25 Key flexfield segment.
 * @param p_segment26 Key flexfield segment.
 * @param p_segment27 Key flexfield segment.
 * @param p_segment28 Key flexfield segment.
 * @param p_segment29 Key flexfield segment.
 * @param p_segment30 Key flexfield segment.
 * @param p_concat_segments For the Job key flexfield.
 * @param p_job_id If p_validate is false, uniquely identifies the job created.
 * If p_validate is true, set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created job. If p_validate is true, then the value
 * will be null.
 * @param p_job_definition_id If p_validate is false, uniquely identifies the
 * combination of segments passed. If p_validate is true, set to null.
 * @param p_name If p_validate is false, concatenation of all segments. If
 * p_validate is true, set to null.
 * @rep:displayname Create Job for Norway.
 * @rep:category BUSINESS_ENTITY PER_JOB
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_no_job
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
    ,p_ssb_position_code             in     varchar2 default null
    ,p_working_title                 in     varchar2 default null
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
-- ----------------------------------------------------------------------------
-- |------------------------------< update_no_job >---------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a Norway job.
 *
 * This API updates a Norway job as identified by the in parameter p_job_id and
 * the in out parameter p_object_version_number.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The job as identified by the in parameter p_job_id and the in out parameter
 * p_object_version_number must already exist.
 *
 * <p><b>Post Success</b><br>
 * When the job is valid, the API updates the job and sets the out parameters.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the job and an error is raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_job_id The primary key of the job.
 * @param p_object_version_number Pass in the current version number of the job
 * to be updated. When the API completes if p_validate is false, will be set to
 * the new version number of the updated job. If p_validate is true will be set
 * to the same value which was passed in.
 * @param p_date_from Start date of job.
 * @param p_comments Comment text.
 * @param p_date_to End date of job.
 * @param p_benchmark_job_flag Flag to indicate whether the job is a benchmark
 * job.
 * @param p_benchmark_job_id ID of benchmark job.
 * @param p_emp_rights_flag Flag to indicate whether there are extended
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
 * @param p_ssb_position_code SSB position code of the job. Valid values are
 * defined in HR_NO_POSITION_CODES lookup type.
 * @param p_working_title Working title of the job.
 * @param p_segment1 Key flexfield segment.
 * @param p_segment2 Key flexfield segment.
 * @param p_segment3 Key flexfield segment.
 * @param p_segment4 Key flexfield segment.
 * @param p_segment5 Key flexfield segment.
 * @param p_segment6 Key flexfield segment.
 * @param p_segment7 Key flexfield segment.
 * @param p_segment8 Key flexfield segment.
 * @param p_segment9 Key flexfield segment.
 * @param p_segment10 Key flexfield segment.
 * @param p_segment11 Key flexfield segment.
 * @param p_segment12 Key flexfield segment.
 * @param p_segment13 Key flexfield segment.
 * @param p_segment14 Key flexfield segment.
 * @param p_segment15 Key flexfield segment.
 * @param p_segment16 Key flexfield segment.
 * @param p_segment17 Key flexfield segment.
 * @param p_segment18 Key flexfield segment.
 * @param p_segment19 Key flexfield segment.
 * @param p_segment20 Key flexfield segment.
 * @param p_segment21 Key flexfield segment.
 * @param p_segment22 Key flexfield segment.
 * @param p_segment23 Key flexfield segment.
 * @param p_segment24 Key flexfield segment.
 * @param p_segment25 Key flexfield segment.
 * @param p_segment26 Key flexfield segment.
 * @param p_segment27 Key flexfield segment.
 * @param p_segment28 Key flexfield segment.
 * @param p_segment29 Key flexfield segment.
 * @param p_segment30 Key flexfield segment.
 * @param p_job_definition_id Set to the code combination ID of the Job key
 * flexfield.
 * @param p_name Set to the concatenated segments as for the
 * per_job_definitions table.
 * @param p_valid_grades_changed_warning Set to true when either the job date
 * to or date from has been modified and at least one valid grade has been
 * updated or deleted. Set to false when neither the job date from or date to
 * has been modified, or, either of them has been modified but no valid grades
 * were altered.
 * @param p_effective_date If p_validate is false, then set to the effective
 * start date on the updated job row which now exists as of the effective date.
 * If p_validate is true, then set to null.
 * @rep:displayname Update Job for Norway.
 * @rep:category BUSINESS_ENTITY PER_JOB
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_no_job
  (p_validate                      in     boolean  default false
  ,p_job_id                        in     number
  ,p_object_version_number         in out nocopy number
  ,p_date_from                     in     date     default hr_api.g_date
  ,p_comments                      in     varchar2 default hr_api.g_varchar2
  ,p_date_to                       in     date     default hr_api.g_date
  ,p_benchmark_job_flag            in     varchar2 default hr_api.g_varchar2
  ,p_benchmark_job_id              in     number   default hr_api.g_varchar2
  ,p_emp_rights_flag               in     varchar2 default hr_api.g_varchar2
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
  ,p_ssb_position_code             in     varchar2 default hr_api.g_varchar2
  ,p_working_title                 in     varchar2 default hr_api.g_varchar2
  ,p_segment1                      in     varchar2 default hr_api.g_varchar2
  ,p_segment2                      in     varchar2 default hr_api.g_varchar2
  ,p_segment3                      in     varchar2 default hr_api.g_varchar2
  ,p_segment4                      in     varchar2 default hr_api.g_varchar2
  ,p_segment5                      in     varchar2 default hr_api.g_varchar2
  ,p_segment6                      in     varchar2 default hr_api.g_varchar2
  ,p_segment7                      in     varchar2 default hr_api.g_varchar2
  ,p_segment8                      in     varchar2 default hr_api.g_varchar2
  ,p_segment9                      in     varchar2 default hr_api.g_varchar2
  ,p_segment10                     in     varchar2 default hr_api.g_varchar2
  ,p_segment11                     in     varchar2 default hr_api.g_varchar2
  ,p_segment12                     in     varchar2 default hr_api.g_varchar2
  ,p_segment13                     in     varchar2 default hr_api.g_varchar2
  ,p_segment14                     in     varchar2 default hr_api.g_varchar2
  ,p_segment15                     in     varchar2 default hr_api.g_varchar2
  ,p_segment16                     in     varchar2 default hr_api.g_varchar2
  ,p_segment17                     in     varchar2 default hr_api.g_varchar2
  ,p_segment18                     in     varchar2 default hr_api.g_varchar2
  ,p_segment19                     in     varchar2 default hr_api.g_varchar2
  ,p_segment20                     in     varchar2 default hr_api.g_varchar2
  ,p_segment21                     in     varchar2 default hr_api.g_varchar2
  ,p_segment22                     in     varchar2 default hr_api.g_varchar2
  ,p_segment23                     in     varchar2 default hr_api.g_varchar2
  ,p_segment24                     in     varchar2 default hr_api.g_varchar2
  ,p_segment25                     in     varchar2 default hr_api.g_varchar2
  ,p_segment26                     in     varchar2 default hr_api.g_varchar2
  ,p_segment27                     in     varchar2 default hr_api.g_varchar2
  ,p_segment28                     in     varchar2 default hr_api.g_varchar2
  ,p_segment29                     in     varchar2 default hr_api.g_varchar2
  ,p_segment30                     in     varchar2 default hr_api.g_varchar2
  ,p_job_definition_id               out nocopy  number
  ,p_name                            out nocopy  varchar2
  ,p_valid_grades_changed_warning    out nocopy  boolean
  ,p_effective_date                in      date
  );
--
end hr_no_job_api;

 

/
