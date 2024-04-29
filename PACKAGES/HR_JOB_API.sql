--------------------------------------------------------
--  DDL for Package HR_JOB_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_JOB_API" AUTHID CURRENT_USER as
/* $Header: pejobapi.pkh 120.1.12010000.1 2008/07/28 04:55:31 appldev ship $ */
/*#
 * This package contains APIs for maintaining job details.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Job
*/
--
-- ----------------------------------------------------------------------------
-- |--------------------------------< create_job >----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a job in the specified business group.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources and HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * At least one segment of the job key flexfield must have a value.
 *
 * <p><b>Post Success</b><br>
 * The API creates the job.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the job and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
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
 * @param p_job_group_id Identifies the job group with which the job is to be
 * associated.
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
 * @param p_job_information_category This context value determines which
 * Flexfield Structure to use with the Developer Descriptive flexfield
 * segments.
 * @param p_job_information1 Developer Descriptive flexfield segment.
 * @param p_job_information2 Developer Descriptive flexfield segment.
 * @param p_job_information3 Developer Descriptive flexfield segment.
 * @param p_job_information4 Developer Descriptive flexfield segment.
 * @param p_job_information5 Developer Descriptive flexfield segment.
 * @param p_job_information6 Developer Descriptive flexfield segment.
 * @param p_job_information7 Developer Descriptive flexfield segment.
 * @param p_job_information8 Developer Descriptive flexfield segment.
 * @param p_job_information9 Developer Descriptive flexfield segment.
 * @param p_job_information10 Developer Descriptive flexfield segment.
 * @param p_job_information11 Developer Descriptive flexfield segment.
 * @param p_job_information12 Developer Descriptive flexfield segment.
 * @param p_job_information13 Developer Descriptive flexfield segment.
 * @param p_job_information14 Developer Descriptive flexfield segment.
 * @param p_job_information15 Developer Descriptive flexfield segment.
 * @param p_job_information16 Developer Descriptive flexfield segment.
 * @param p_job_information17 Developer Descriptive flexfield segment.
 * @param p_job_information18 Developer Descriptive flexfield segment.
 * @param p_job_information19 Developer Descriptive flexfield segment.
 * @param p_job_information20 Developer Descriptive flexfield segment.
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
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
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
 * @rep:displayname Create Job
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
procedure create_job
  (p_validate                      in     boolean  default false
  ,p_business_group_id             in     number
  ,p_date_from                     in     date
  ,p_comments                      in     varchar2 default null
  ,p_date_to                       in     date     default null
  ,p_approval_authority            in     number   default null
  ,p_benchmark_job_flag            in     varchar2 default 'N'
  ,p_benchmark_job_id              in     number   default null
  ,p_emp_rights_flag               in     varchar2 default 'N'
  ,p_job_group_id                  in     number
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
  ,p_job_information_category      in     varchar2 default null
  ,p_job_information1              in     varchar2 default null
  ,p_job_information2              in     varchar2 default null
  ,p_job_information3              in     varchar2 default null
  ,p_job_information4              in     varchar2 default null
  ,p_job_information5              in     varchar2 default null
  ,p_job_information6              in     varchar2 default null
  ,p_job_information7              in     varchar2 default null
  ,p_job_information8              in     varchar2 default null
  ,p_job_information9              in     varchar2 default null
  ,p_job_information10             in     varchar2 default null
  ,p_job_information11             in     varchar2 default null
  ,p_job_information12             in     varchar2 default null
  ,p_job_information13             in     varchar2 default null
  ,p_job_information14             in     varchar2 default null
  ,p_job_information15             in     varchar2 default null
  ,p_job_information16             in     varchar2 default null
  ,p_job_information17             in     varchar2 default null
  ,p_job_information18             in     varchar2 default null
  ,p_job_information19             in     varchar2 default null
  ,p_job_information20             in     varchar2 default null
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
  ,p_language_code                 in     varchar2 default hr_api.userenv_lang
  ,p_job_id                           out nocopy number
  ,p_object_version_number            out nocopy number
  ,p_job_definition_id             in out nocopy number
  ,p_name                             out nocopy varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< update_job >--------------------------------
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API updates a job as identified by the in parameter
--   p_job_id and the in out parameter p_object_version_number.
--
--
-- Prerequisites:
--   The job as identified by the in parameter p_job_id and the in
--   out parameter p_object_version_number must already exist.
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     No   boolean  If true, the database
--                                                remains unchanged. If false,
--                                                the job is updated.
--   p_job_id                       Yes  number   The primary key of the
--                                                job.
--   p_object_version_number        Yes  number   The current version of the
--                                                job to be updated.
--   p_date_from                    No   date     Start date of job
--   p_comments                     No   varchar2 Comments
--   p_date_to                      No   date     The end date of the job.
--   p_benchmark_job_flag           No   varchar2 Flag to indicate whether
--                                                the job is a benchmark job.
--   p_benchmark_job_id             No   number   ID of the benchmark job.
--   p_emp_rights_flag              No   varchar2 Flag to indicate whether
--                                                there are extended
--                                                employment rights
--                                                associated with this job.
--   p_attribute_category           No   varchar2 Determines context of the
--                                                attribute Descriptive
--                                                flexfield in parameters.
--   p_attribute1                   No   varchar2 Descriptive flexfield.
--   p_attribute2                   No   varchar2 Descriptive flexfield.
--   p_attribute3                   No   varchar2 Descriptive flexfield.
--   p_attribute4                   No   varchar2 Descriptive flexfield.
--   p_attribute5                   No   varchar2 Descriptive flexfield.
--   p_attribute6                   No   varchar2 Descriptive flexfield.
--   p_attribute7                   No   varchar2 Descriptive flexfield.
--   p_attribute8                   No   varchar2 Descriptive flexfield.
--   p_attribute9                   No   varchar2 Descriptive flexfield.
--   p_attribute10                  No   varchar2 Descriptive flexfield.
--   p_attribute11                  No   varchar2 Descriptive flexfield.
--   p_attribute12                  No   varchar2 Descriptive flexfield.
--   p_attribute13                  No   varchar2 Descriptive flexfield.
--   p_attribute14                  No   varchar2 Descriptive flexfield.
--   p_attribute15                  No   varchar2 Descriptive flexfield.
--   p_attribute16                  No   varchar2 Descriptive flexfield.
--   p_attribute17                  No   varchar2 Descriptive flexfield.
--   p_attribute18                  No   varchar2 Descriptive flexfield.
--   p_attribute19                  No   varchar2 Descriptive flexfield.
--   p_attribute20                  No   varchar2 Descriptive flexfield.
--   p_job_information_category      No   varchar2 Developer descriptive flexfield
--   p_job_information1        No   varchar2 Developer descriptive flexfield
--   p_job_information2        No   varchar2 Developer descriptive flexfield
--   p_job_information3        No   varchar2 Developer descriptive flexfield
--   p_job_information4        No   varchar2 Developer descriptive flexfield
--   p_job_information5        No   varchar2 Developer descriptive flexfield
--   p_job_information6        No   varchar2 Developer descriptive flexfield
--   p_job_information7        No   varchar2 Developer descriptive flexfield
--   p_job_information8        No   varchar2 Developer descriptive flexfield
--   p_job_information9        No   varchar2 Developer descriptive flexfield
--   p_job_information10       No   varchar2 Developer descriptive flexfield
--   p_job_information11       No   varchar2 Developer descriptive flexfield
--   p_job_information12       No   varchar2 Developer descriptive flexfield
--   p_job_information13       No   varchar2 Developer descriptive flexfield
--   p_job_information14       No   varchar2 Developer descriptive flexfield
--   p_job_information15       No   varchar2 Developer descriptive flexfield
--   p_job_information16       No   varchar2 Developer descriptive flexfield
--   p_job_information17       No   varchar2 Developer descriptive flexfield
--   p_job_information18       No   varchar2 Developer descriptive flexfield
--   p_job_information19       No   varchar2 Developer descriptive flexfield
--   p_job_information20       No   varchar2 Developer descriptive flexfield
--   p_segment1                     No   varchar2 For the Job key flexfield
--   p_segment2                     No   varchar2 For the Job key flexfield
--   p_segment3                     No   varchar2 For the Job key flexfield
--   p_segment4                     No   varchar2 For the Job key flexfield
--   p_segment5                     No   varchar2 For the Job key flexfield
--   p_segment6                     No   varchar2 For the Job key flexfield
--   p_segment7                     No   varchar2 For the Job key flexfield
--   p_segment8                     No   varchar2 For the Job key flexfield
--   p_segment9                     No   varchar2 For the Job key flexfield
--   p_segment10                    No   varchar2 For the Job key flexfield
--   p_segment11                    No   varchar2 For the Job key flexfield
--   p_segment12                    No   varchar2 For the Job key flexfield
--   p_segment13                    No   varchar2 For the Job key flexfield
--   p_segment14                    No   varchar2 For the Job key flexfield
--   p_segment15                    No   varchar2 For the Job key flexfield
--   p_segment16                    No   varchar2 For the Job key flexfield
--   p_segment17                    No   varchar2 For the Job key flexfield
--   p_segment18                    No   varchar2 For the Job key flexfield
--   p_segment19                    No   varchar2 For the Job key flexfield
--   p_segment20                    No   varchar2 For the Job key flexfield
--   p_segment21                    No   varchar2 For the Job key flexfield
--   p_segment22                    No   varchar2 For the Job key flexfield
--   p_segment23                    No   varchar2 For the Job key flexfield
--   p_segment24                    No   varchar2 For the Job key flexfield
--   p_segment25                    No   varchar2 For the Job key flexfield
--   p_segment26                    No   varchar2 For the Job key flexfield
--   p_segment27                    No   varchar2 For the Job key flexfield
--   p_segment28                    No   varchar2 For the Job key flexfield
--   p_segment29                    No   varchar2 For the Job key flexfield
--   p_segment30                    No   varchar2 For the Job key flexfield
--   p_language_code                No   varchar2 The current language
--   p_effective_date          Yes  date    Effective date
-- Post Success:
--   When the job is valid, the API updates the job and sets the
--   following out parameters.
--
--   Name                           Type     Description
--   p_object_version_number        number   If p_validate is false, set to
--                                           the version number of this
--                                           job. If p_validate is true,
--                                           set to null.
--   p_job_definition_id            number   Set to the code combination ID of
--                                           the Job key flexfield.
--   p_name                         varchar2 Set to the concatenated segments
--                                           as on the per_job_definitions
--                                           table.
--   p_valid_grade_changed_warning  boolean  Set to true when either the
--                                           job date to or date
--                                           from has been modified and at
--                                           least one valid grade has been
--                                           updated or deleted.  Set to false
--                                           when neither the job date
--                                           from or date to has been
--                                           modified, or, either of them has
--                                           been modified but no valid grades
--                                           were altered.
--
-- Post Failure:
--   The API does not update the job and raises an error.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
-- ----------------------------------------------------------------------------
 procedure update_job
  (p_validate                      in     boolean  default false
  ,p_job_id                        in     number
  ,p_object_version_number         in out nocopy number
  ,p_date_from                     in     date     default hr_api.g_date
  ,p_comments                      in     varchar2 default hr_api.g_varchar2
  ,p_date_to                       in     date     default hr_api.g_date
  ,p_benchmark_job_flag            in     varchar2 default hr_api.g_varchar2
  ,p_benchmark_job_id              in     number   default hr_api.g_number
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
  ,p_job_information_category      in    varchar2 default hr_api.g_varchar2
  ,p_job_information1              in    varchar2 default hr_api.g_varchar2
  ,p_job_information2              in    varchar2 default hr_api.g_varchar2
  ,p_job_information3              in    varchar2 default hr_api.g_varchar2
  ,p_job_information4              in    varchar2 default hr_api.g_varchar2
  ,p_job_information5              in    varchar2 default hr_api.g_varchar2
  ,p_job_information6              in    varchar2 default hr_api.g_varchar2
  ,p_job_information7              in    varchar2 default hr_api.g_varchar2
  ,p_job_information8              in    varchar2 default hr_api.g_varchar2
  ,p_job_information9              in    varchar2 default hr_api.g_varchar2
  ,p_job_information10             in    varchar2 default hr_api.g_varchar2
  ,p_job_information11             in    varchar2 default hr_api.g_varchar2
  ,p_job_information12             in    varchar2 default hr_api.g_varchar2
  ,p_job_information13             in    varchar2 default hr_api.g_varchar2
  ,p_job_information14             in    varchar2 default hr_api.g_varchar2
  ,p_job_information15             in    varchar2 default hr_api.g_varchar2
  ,p_job_information16             in    varchar2 default hr_api.g_varchar2
  ,p_job_information17             in    varchar2 default hr_api.g_varchar2
  ,p_job_information18             in    varchar2 default hr_api.g_varchar2
  ,p_job_information19             in    varchar2 default hr_api.g_varchar2
  ,p_job_information20             in    varchar2 default hr_api.g_varchar2
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
  ,p_concat_segments               in     varchar2 default hr_api.g_varchar2
  ,p_approval_authority            in     number   default hr_api.g_number
  ,p_language_code                 in     varchar2 default hr_api.userenv_lang
  ,p_job_definition_id             in out nocopy number
  ,p_name                             out nocopy varchar2
  ,p_valid_grades_changed_warning     out nocopy boolean
  ,p_effective_date        in      date default hr_api.g_date --Added for bug# 1760707
  );

-- ------------------------------------------------------------------------+
-- |-----------------------------< delete_job >----------------------------|
-- ------------------------------------------------------------------------+
-- {Start Of Comments}
--
-- Description:
--   This API deletes a job as identified by the in parameter
--   p_job_id and the in out parameter p_object_version_number.
--
-- Pre Conditions:
--   The job as identified by the in parameter p_job_id and the in
--   out parameter p_object_version_number must already exist.
--
-- In Arguments:
--   Name                           Reqd Type     Description
--   p_validate                     No   boolean  If true, the database
--                                                remains unchanged. If false,
--                                                the job is updated.
--   p_job_id                       Yes  number   The primary key of the
--                                                job.
--   p_object_version_number        Yes  number   The current version of the
--                                                job to be updated.
--
-- Post Success:
--   Job is deleted
--
-- Post Failure:
--   The API does not delete the job and raises an error.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
----------------------------------------------------------------------------
procedure delete_job
  (p_validate                      in     boolean  default false
  ,p_job_id                        in     number
  ,p_object_version_number         in out nocopy number);

--

-- ------------------------------------------------------------------------+
-- |-----------------------------< get_next_sequence >---------------------|
-- ------------------------------------------------------------------------+
-- {Start Of Comments}
--
-- Description:
--   This procedure will get the next available sequence number from
--   per_jobs_s
--
-- Pre Conditions:
--   Sequence must be existing
--
-- In Arguments:
--   p_job_id
--
-- Post Success:
--   Next available sequence will be returned
--
-- Post Failure:
--   None
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
----------------------------------------------------------------------------
procedure get_next_sequence(p_job_id       IN OUT NOCOPY NUMBER);
--
-- ------------------------------------------------------------------------+
-- |-----------------------------< get_job_flex_structure >----------------|
-- ------------------------------------------------------------------------+
-- {Start Of Comments}
--
-- Description:
--   This procedure will return job_flex_structure_id for a given job
--
-- Pre Conditions:
--   A valid job must be existing
--
-- In Arguments:
--   p_job_id
--   p_structure_defining_column
--
-- Post Success:
--   Will return job_flex_structure_id for the given job
--
-- Post Failure:
--   None
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
----------------------------------------------------------------------------
procedure get_job_flex_structure(
                          p_structure_defining_column in out nocopy varchar2,
           p_job_group_id              in number);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_valid_grades >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This procedure updates the valid grades for a given job.
 *
 * Update valid grade end dates to match the job end date, where the job end
 * date is earlier than the grade end date or the previous end dates matched.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Atleast one valid grade must exist for the given job.
 *
 * <p><b>Post Success</b><br>
 * Will update the valid grades end dates.
 *
 * <p><b>Post Failure</b><br>
 * An error will be raised, and an appropriate message will be shown to the
 * user.
 *
 * @param p_business_group_id Identifies the business group in which the valid
 * grades exist.
 * @param p_job_id Identifies the job for which you are updating the valid
 * grades.
 * @param p_date_to End date to set for the valid grades.
 * @param p_end_of_time If the parameter p_date_to is passed as null, a date
 * well in future should be set as the end date for valid grades.
 * @rep:displayname Update Valid Grades
 * @rep:category BUSINESS_ENTITY PER_JOB
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_valid_grades(p_business_group_id  number,
               p_job_id             number,
               p_date_to            date,
               p_end_of_time        date);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_valid_grades >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This procedure deletes the valid grades.
 *
 * Valid grades are deleted if the end date of the job has been made earlier
 * than the start date of the valid grade.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid grade must exist for the given job.
 *
 * <p><b>Post Success</b><br>
 * Valid grades will be deleted based on the end date of the job.
 *
 * <p><b>Post Failure</b><br>
 * An error will be raised, and an appropriate message will be shown to the
 * user.
 *
 * @param p_business_group_id Identifies the business group in which valid
 * grades exist.
 * @param p_job_id Identifies the job for which you are deleting the valid
 * grades.
 * @param p_date_to Date after which the valid grades are deleted.
 * @rep:displayname Delete Valid Grades
 * @rep:category BUSINESS_ENTITY PER_JOB
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_valid_grades(p_business_group_id  number,
                     p_job_id             number,
               p_date_to            date);
--
end hr_job_api;

/
