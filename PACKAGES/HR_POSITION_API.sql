--------------------------------------------------------
--  DDL for Package HR_POSITION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_POSITION_API" AUTHID CURRENT_USER as
/* $Header: peposapi.pkh 120.5.12010000.1 2008/07/28 05:23:44 appldev ship $ */
/*#
 * This package contains position APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Position
*/
FULL_HR   boolean;
--
--
g_debug boolean := hr_utility.debug_enabled;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_position >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a position which is a specific occurrence of a job within
 * an organization and should be used if you are a Shared HR (HR Foundation)
 * user and do not have HR fully installed.
 *
 * Based on the position definition segments which are passed a position
 * definition id is selected for the position, or a new position definition
 * record is created.
 *
 * <p><b>Licensing</b><br>
 * This API version is licensed for use with HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * A valid organization and job must be passed to the API. Also at least one
 * segment for position definition must have a value.
 *
 * <p><b>Restricted Usage Notes</b><br>
 * You can use all of the parameters in the version of this API that is
 * specifically for HR Foundation users.
 *
 * <p><b>Post Success</b><br>
 * The API creates the position successfully in the database.
 *
 * <p><b>Post Failure</b><br>
 * The position is not created in the database and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_job_id The job for the position.
 * @param p_organization_id The organization for which the position belongs.
 * @param p_date_effective The date on which the position becomes active.
 * @param p_successor_position_id Identifies the successor position.
 * @param p_relief_position_id Identifies the relief position.
 * @param p_location_id The location of the position.
 * @param p_comments Comment text.
 * @param p_date_end The date on which the position is no longer active.
 * @param p_frequency Frequency of working hours. Valid values are defined by
 * 'FREQUENCY' lookup_type.
 * @param p_probation_period Length of probation period.
 * @param p_probation_period_units Units that the probation period is measured
 * in. Valid values are defined by 'QUALIFYING_UNITS' lookup_type.
 * @param p_replacement_required_flag Identifies if a replacement is required
 * when person assigned is absent. Valid values are defined by 'YES_NO' lookup
 * type.
 * @param p_time_normal_finish Normal end time.
 * @param p_time_normal_start Normal start time.
 * @param p_status Position status. Valid values are defined by
 * 'POSITION_STATUS' lookup type.
 * @param p_working_hours Number of normal working hours.
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
 * @param p_concat_segments Concatenated string of segment values
 * @param p_position_id If p_validate is false, then this uniquely identifies
 * the position created. If p_validate is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created position. If p_validate is true, then the
 * value will be null.
 * @param p_position_definition_id If p_validate is false, then this uniquely
 * identifies the combination of position segments created. If p_validate is
 * true, then set to null.
 * @param p_name If p_validate is false, then this identifies concatenation of
 * all name segments. If p_validate is true, then set to null.
 * @rep:displayname Create Position
 * @rep:category BUSINESS_ENTITY PER_POSITION
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_position
  (p_validate                      in     boolean  default false
  ,p_job_id                        in     number
  ,p_organization_id               in     number
  ,p_date_effective                in     date
  ,p_successor_position_id         in     number   default null
  ,p_relief_position_id            in     number   default null
  ,p_location_id                   in     number   default null
  ,p_comments                      in     varchar2 default null
  ,p_date_end                      in     date     default null
  ,p_frequency                     in     varchar2 default null
  ,p_probation_period              in     number   default null
  ,p_probation_period_units        in     varchar2 default null
  ,p_replacement_required_flag     in     varchar2 default null
  ,p_time_normal_finish            in     varchar2 default null
  ,p_time_normal_start             in     varchar2 default null
  ,p_status                        in     varchar2 default null
  ,p_working_hours                 in     number   default null
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
  ,p_position_id                        out nocopy number
  ,p_object_version_number              out nocopy number
  ,p_position_definition_id        in   out nocopy number
  ,p_name                          in   out nocopy varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< update_position >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a position and should be used if you are a Shared HR (HR
 * Foundation) user and do not have HR fully installed.
 *
 * The position to be updated is identified by the in parameter p_position_id
 * and the in out parameter p_object_version_number.
 *
 * <p><b>Licensing</b><br>
 * This API version is licensed for use with HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * The position that is to be updated must already exist.
 *
 * <p><b>Post Success</b><br>
 * The position is updated successfully in the database.
 *
 * <p><b>Post Failure</b><br>
 * The position is not updated in the database and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_position_id Identifies the position to be modified.
 * @param p_object_version_number Pass in the current version number of the
 * position to be updated. When the API completes if p_validate is false, will
 * be set to the new version number of the updated position. If p_validate is
 * true will be set to the same value which was passed in.
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @param p_successor_position_id Identifies the successor position.
 * @param p_relief_position_id Identifies the relief position.
 * @param p_location_id The location of the position.
 * @param p_date_effective The date on which the position becomes active.
 * @param p_comments Comment text.
 * @param p_date_end The date on which the position is no longer active.
 * @param p_frequency Frequency of working hours. Valid values are defined by
 * 'FREQUENCY' lookup_type.
 * @param p_probation_period Length of probation period.
 * @param p_probation_period_units Units that the probation period is measured
 * in. Valid values are defined by 'QUALIFYING_UNITS' lookup_type.
 * @param p_replacement_required_flag Identifies if a replacement is required
 * when person assigned is absent. Valid values are defined by 'YES_NO' lookup
 * type.
 * @param p_time_normal_finish Normal end time.
 * @param p_time_normal_start Normal start time.
 * @param p_status Position status. Valid values are defined by
 * 'POSITION_STATUS' lookup type.
 * @param p_working_hours Number of normal working hours.
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
 * @param p_concat_segments Concatenated string of segment values
 * @param p_position_definition_id If p_validate is false, then this uniquely
 * identifies the combination of position segments created. If p_validate is
 * true, then set to null.
 * @param p_name If p_validate is false, then this identifies concatenation of
 * all name segments. If p_validate is true, then set to null.
 * @param p_valid_grades_changed_warning Set to true when either the position
 * date effective or date end have been modified and at least one valid grade
 * has been updated or deleted. Set to false when neither the position date
 * effective or date end have been modified, or either of them has been
 * modified but no valid grades were altered.
 * @rep:displayname Update Position
 * @rep:category BUSINESS_ENTITY PER_POSITION
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_position
  (p_validate                      in     boolean  default false
  ,p_position_id                   in     number
  ,p_object_version_number         in out nocopy number
  ,p_language_code                 in     varchar2 default hr_api.userenv_lang
  ,p_successor_position_id         in     number   default hr_api.g_number
  ,p_relief_position_id            in     number   default hr_api.g_number
  ,p_location_id                   in     number   default hr_api.g_number
  ,p_date_effective                in     date     default hr_api.g_date
  ,p_comments                      in     varchar2 default hr_api.g_varchar2
  ,p_date_end                      in     date     default hr_api.g_date
  ,p_frequency                     in     varchar2 default hr_api.g_varchar2
  ,p_probation_period              in     number   default hr_api.g_number
  ,p_probation_period_units        in     varchar2 default hr_api.g_varchar2
  ,p_replacement_required_flag     in     varchar2 default hr_api.g_varchar2
  ,p_time_normal_finish	           in     varchar2 default hr_api.g_varchar2
  ,p_time_normal_start             in     varchar2 default hr_api.g_varchar2
  ,p_status                        in     varchar2 default hr_api.g_varchar2
  ,p_working_hours                 in     number   default hr_api.g_number
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
  ,p_position_definition_id        in   out nocopy number
  ,p_name                          in   out nocopy varchar2
  ,p_valid_grades_changed_warning       out nocopy boolean
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< delete_position >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a position and should be used if you are a Shared HR (HR
 * Foundation) user and do not have HR fully installed.
 *
 * The position to be deleted is identified by the in parameter p_position_id
 * and the in parameter p_object_version_number.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with HR Foundation.
 *
 * <p><b>Prerequisites</b><br>
 * The position to be deleted must already exist. The position to be deleted
 * must not be used in any assignment.
 *
 * <p><b>Post Success</b><br>
 * The position is deleted successfully from the database.
 *
 * <p><b>Post Failure</b><br>
 * The position is not deleted from the database and error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_position_id Identifies the position to be deleted.
 * @param p_object_version_number Current version number of the position to be
 * deleted.
 * @rep:displayname Delete Position
 * @rep:category BUSINESS_ENTITY PER_POSITION
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_position(
  p_validate boolean  default false,
  p_position_id number,
  p_object_version_number number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< lck >-------------------------------------------|
-- ----------------------------------------------------------------------------
-- NON DATETRACK LOCK
procedure lck
  (
   p_position_id                   in     number
  ,p_object_version_number          in     number
  ,p_language_code                 in     varchar2 default hr_api.userenv_lang
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_position >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a position which is a specific occurrence of a job within
 * an organization and should be used if you have HR fully installed.
 *
 * This overload version provides DateTrack features. Based on the position
 * definition segments which are passed a position definition id is selected
 * for the position, or a new position definition record is created.
 *
 * <p><b>Licensing</b><br>
 * This API version is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid organization and job must be passed to the API. Also at least one
 * segment for position definition must have a value.
 *
 * <p><b>Post Success</b><br>
 * The position will be created successfully in the database.
 *
 * <p><b>Post Failure</b><br>
 * The position will not be created and an error will be raised.
 * @param p_position_id If p_validate is false, then this uniquely identifies
 * the position created. If p_validate is true, then set to null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created position. If p_validate is
 * true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created position. If p_validate is true, then set
 * to null.
 * @param p_position_definition_id If p_validate is false, then this uniquely
 * identifies the combination of position segments created. If p_validate is
 * true, then set to null.
 * @param p_name If p_validate is false, then this identifies concatenation of
 * all name segments. If p_validate is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created position. If p_validate is true, then the
 * value will be null.
 * @param p_job_id The job for the position.
 * @param p_organization_id The organization to which the position belongs.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_date_effective The date on which the position becomes active.
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_availability_status_id Current status of the position. Refers to
 * PER_SHARED_TYPES.
 * @param p_business_group_id {@rep:casecolumn
 * HR_ALL_POSITIONS_F.BUSINESS_GROUP_ID}
 * @param p_entry_step_id {@rep:casecolumn HR_ALL_POSITIONS_F.ENTRY_STEP_ID}
 * @param p_entry_grade_rule_id {@rep:casecolumn
 * HR_ALL_POSITIONS_F.ENTRY_GRADE_RULE_ID}
 * @param p_location_id {@rep:casecolumn HR_ALL_POSITIONS_F.LOCATION_ID}
 * @param p_pay_freq_payroll_id {@rep:casecolumn
 * HR_ALL_POSITIONS_F.PAY_FREQ_PAYROLL_ID}
 * @param p_position_transaction_id {@rep:casecolumn
 * HR_ALL_POSITIONS_F.POSITION_TRANSACTION_ID}
 * @param p_prior_position_id {@rep:casecolumn
 * HR_ALL_POSITIONS_F.PRIOR_POSITION_ID}
 * @param p_relief_position_id {@rep:casecolumn
 * HR_ALL_POSITIONS_F.RELIEF_POSITION_ID}
 * @param p_entry_grade_id {@rep:casecolumn HR_ALL_POSITIONS_F.ENTRY_GRADE_ID}
 * @param p_successor_position_id {@rep:casecolumn
 * HR_ALL_POSITIONS_F.SUCCESSOR_POSITION_ID}
 * @param p_supervisor_position_id {@rep:casecolumn
 * HR_ALL_POSITIONS_F.SUPERVISOR_POSITION_ID}
 * @param p_amendment_date {@rep:casecolumn HR_ALL_POSITIONS_F.AMENDMENT_DATE}
 * @param p_amendment_recommendation {@rep:casecolumn
 * HR_ALL_POSITIONS_F.AMENDMENT_RECOMMENDATION}
 * @param p_amendment_ref_number {@rep:casecolumn
 * HR_ALL_POSITIONS_F.AMENDMENT_REF_NUMBER}
 * @param p_bargaining_unit_cd Identifies the bargaining unit. Valid values are
 * defined by 'BARGAINING_UNIT_CODE' lookup_type.
 * @param p_comments Comment text.
 * @param p_current_job_prop_end_date {@rep:casecolumn
 * HR_ALL_POSITIONS_F.CURRENT_JOB_PROP_END_DATE}
 * @param p_current_org_prop_end_date {@rep:casecolumn
 * HR_ALL_POSITIONS_F.CURRENT_ORG_PROP_END_DATE}
 * @param p_avail_status_prop_end_date {@rep:casecolumn
 * HR_ALL_POSITIONS_F.AVAIL_STATUS_PROP_END_DATE}
 * @param p_date_end {@rep:casecolumn HR_ALL_POSITIONS_F.DATE_END}
 * @param p_earliest_hire_date {@rep:casecolumn
 * HR_ALL_POSITIONS_F.EARLIEST_HIRE_DATE}
 * @param p_fill_by_date {@rep:casecolumn HR_ALL_POSITIONS_F.FILL_BY_DATE}
 * @param p_frequency Frequency of working hours. Valid values are defined by
 * 'FREQUENCY' lookup_type.
 * @param p_fte {@rep:casecolumn HR_ALL_POSITIONS_F.FTE}
 * @param p_max_persons Maximum number of employees allowed for this position.
 * @param p_overlap_period {@rep:casecolumn HR_ALL_POSITIONS_F.OVERLAP_PERIOD}
 * @param p_overlap_unit_cd Unit of period. Valid values are defined by
 * 'QUALIFYING_UNITS' lookup_type.
 * @param p_pay_term_end_day_cd End day of pay term. Valid values are defined
 * by 'DAY_CODE' lookup_type.
 * @param p_pay_term_end_month_cd End month of pay term. Valid values are
 * defined by 'MONTH_CODE' lookup_type.
 * @param p_permanent_temporary_flag Indicates whether position is temporary or
 * permanent. Valid values are defined by 'YES_NO' lookup_type
 * @param p_permit_recruitment_flag Indicates if recruitment can start for the
 * position or not. Valid values are defined by 'YES_NO' lookup_type
 * @param p_position_type Indicates position type. Valid values are defined by
 * 'POSITION_TYPE' lookup_type
 * @param p_posting_description Posting description.
 * @param p_probation_period Length of probation period.
 * @param p_probation_period_unit_cd Qualifying units. Valid values are defined
 * by 'QUALIFYING_UNITS' lookup_type.
 * @param p_replacement_required_flag Identifies if replacement is required
 * when person assigned is absent. Valid values are defined by 'YES_NO' lookup
 * type.
 * @param p_review_flag Identifies whether the characteristics of the position
 * are under going review or change. Valid values are defined by 'YES_NO'
 * lookup_type
 * @param p_seasonal_flag Identifies if the position is seasonal or not. Valid
 * values are defined by 'YES_NO' lookup_type
 * @param p_security_requirements Security requirements.
 * @param p_status Position status. Valid values are defined by
 * 'POSITION_STATUS' lookup type.
 * @param p_term_start_day_cd Start day of work term. Valid values are defined
 * by 'DAY_CODE' lookup_type.
 * @param p_term_start_month_cd Start month of work term. Valid values are
 * defined by 'MONTH_CODE' lookup_type.
 * @param p_time_normal_finish Normal end time.
 * @param p_time_normal_start Normal start time.
 * @param p_update_source_cd Identifies if the position has to be copied into
 * the non datetracked table per_all_positions.Valid values are defined by
 * 'YES_NO' lookup_type
 * @param p_working_hours Number of normal working hours.
 * @param p_works_council_approval_flag Identifies if work council approval is
 * needed or not. Valid values are defined by 'YES_NO' lookup_type
 * @param p_work_period_type_cd Identifies that the position is only used
 * during part of the year. Valid values are defined by 'YES_NO' lookup_type
 * @param p_work_term_end_day_cd End day of work term. Valid values are defined
 * by 'DAY_CODE' lookup_type.
 * @param p_work_term_end_month_cd Start day of work term. Valid values are
 * defined by 'MONTH_CODE' lookup_type.
 * @param p_proposed_fte_for_layoff Proposed FTE for layoff
 * @param p_proposed_date_for_layoff Proposed date for layoff
 * @param p_pay_basis_id Foreign Key to per_pay_bases.
 * @param p_supervisor_id Foreign Key to per_all_people_f.
 * @param p_information1 Developer descriptive flexfield segment.
 * @param p_information2 Developer descriptive flexfield segment.
 * @param p_information3 Developer descriptive flexfield segment.
 * @param p_information4 Developer descriptive flexfield segment.
 * @param p_information5 Developer descriptive flexfield segment.
 * @param p_information6 Developer descriptive flexfield segment.
 * @param p_information7 Developer descriptive flexfield segment.
 * @param p_information8 Developer descriptive flexfield segment.
 * @param p_information9 Developer descriptive flexfield segment.
 * @param p_information10 Developer descriptive flexfield segment.
 * @param p_information11 Developer descriptive flexfield segment.
 * @param p_information12 Developer descriptive flexfield segment.
 * @param p_information13 Developer descriptive flexfield segment.
 * @param p_information14 Developer descriptive flexfield segment.
 * @param p_information15 Developer descriptive flexfield segment.
 * @param p_information16 Developer descriptive flexfield segment.
 * @param p_information17 Developer descriptive flexfield segment.
 * @param p_information18 Developer descriptive flexfield segment.
 * @param p_information19 Developer descriptive flexfield segment.
 * @param p_information20 Developer descriptive flexfield segment.
 * @param p_information21 Developer descriptive flexfield segment.
 * @param p_information22 Developer descriptive flexfield segment.
 * @param p_information23 Developer descriptive flexfield segment.
 * @param p_information24 Developer descriptive flexfield segment.
 * @param p_information25 Developer descriptive flexfield segment.
 * @param p_information26 Developer descriptive flexfield segment.
 * @param p_information27 Developer descriptive flexfield segment.
 * @param p_information28 Developer descriptive flexfield segment.
 * @param p_information29 Developer descriptive flexfield segment.
 * @param p_information30 Developer descriptive flexfield segment.
 * @param p_information_category This context value determines which flexfield
 * structure to use with the developer descriptive flexfield segments.
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
 * @param p_attribute_category This context value determines which flexfield
 * structure to use with the descriptive flexfield segments.
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
 * @param p_concat_segments Concatenated string of segment values
 * @param p_request_id When the API is executed from a concurrent program set
 * to the concurrent request identifier.
 * @param p_program_application_id When the API is executed from a concurrent
 * program set to the program's Application.
 * @param p_program_id When the API is executed from a concurrent program set
 * to the program's identifier.
 * @param p_program_update_date When the API is executed from a concurrent
 * program set to when the program was ran.
 * @param p_security_profile_id Security Profile to which the position is
 * added.
 * @rep:displayname Create Position
 * @rep:category BUSINESS_ENTITY PER_POSITION
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:primaryinstance
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_position
  (p_position_id                    out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_position_definition_id         in out nocopy number
  ,p_name                           in out nocopy varchar2
  ,p_object_version_number          out nocopy number
  ,p_job_id                         in  number
  ,p_organization_id                in  number
  ,p_effective_date                 in  date
  ,p_date_effective                 in  date
  ,p_language_code                  in  varchar2  default hr_api.userenv_lang
  ,p_validate                       in  boolean   default false
  ,p_availability_status_id         in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_entry_step_id                  in  number    default null
  ,p_entry_grade_rule_id            in  number    default null
  ,p_location_id                    in  number    default null
  ,p_pay_freq_payroll_id            in  number    default null
  ,p_position_transaction_id        in  number    default null
  ,p_prior_position_id              in  number    default null
  ,p_relief_position_id             in  number    default null
  ,p_entry_grade_id                 in  number    default null
  ,p_successor_position_id          in  number    default null
  ,p_supervisor_position_id         in  number    default null
  ,p_amendment_date                 in  date      default null
  ,p_amendment_recommendation       in  varchar2  default null
  ,p_amendment_ref_number           in  varchar2  default null
  ,p_bargaining_unit_cd             in  varchar2  default null
  ,p_comments                       in  long      default null
  ,p_current_job_prop_end_date      in  date      default null
  ,p_current_org_prop_end_date      in  date      default null
  ,p_avail_status_prop_end_date     in  date      default null
  ,p_date_end                       in  date      default null
  ,p_earliest_hire_date             in  date      default null
  ,p_fill_by_date                   in  date      default null
  ,p_frequency                      in  varchar2  default null
  ,p_fte                            in  number    default null
  ,p_max_persons                    in  number    default null
  ,p_overlap_period                 in  number    default null
  ,p_overlap_unit_cd                in  varchar2  default null
  ,p_pay_term_end_day_cd            in  varchar2  default null
  ,p_pay_term_end_month_cd          in  varchar2  default null
  ,p_permanent_temporary_flag       in  varchar2  default null
  ,p_permit_recruitment_flag        in  varchar2  default null
  ,p_position_type                  in  varchar2  default 'NONE'
  ,p_posting_description            in  varchar2  default null
  ,p_probation_period               in  number    default null
  ,p_probation_period_unit_cd       in  varchar2  default null
  ,p_replacement_required_flag      in  varchar2  default null
  ,p_review_flag                    in  varchar2  default null
  ,p_seasonal_flag                  in  varchar2  default null
  ,p_security_requirements          in  varchar2  default null
  ,p_status                         in  varchar2  default null
  ,p_term_start_day_cd              in  varchar2  default null
  ,p_term_start_month_cd            in  varchar2  default null
  ,p_time_normal_finish             in  varchar2  default null
  ,p_time_normal_start              in  varchar2  default null
  ,p_update_source_cd               in  varchar2  default null
  ,p_working_hours                  in  number    default null
  ,p_works_council_approval_flag    in  varchar2  default null
  ,p_work_period_type_cd            in  varchar2  default null
  ,p_work_term_end_day_cd           in  varchar2  default null
  ,p_work_term_end_month_cd         in  varchar2  default null
  ,p_proposed_fte_for_layoff        in  number    default null
  ,p_proposed_date_for_layoff       in  date      default null
  ,p_pay_basis_id                   in  number    default null
  ,p_supervisor_id                  in  number    default null
  -- ,p_copied_to_old_table_flag       in  varchar2  default null
  ,p_information1                   in  varchar2  default null
  ,p_information2                   in  varchar2  default null
  ,p_information3                   in  varchar2  default null
  ,p_information4                   in  varchar2  default null
  ,p_information5                   in  varchar2  default null
  ,p_information6                   in  varchar2  default null
  ,p_information7                   in  varchar2  default null
  ,p_information8                   in  varchar2  default null
  ,p_information9                   in  varchar2  default null
  ,p_information10                  in  varchar2  default null
  ,p_information11                  in  varchar2  default null
  ,p_information12                  in  varchar2  default null
  ,p_information13                  in  varchar2  default null
  ,p_information14                  in  varchar2  default null
  ,p_information15                  in  varchar2  default null
  ,p_information16                  in  varchar2  default null
  ,p_information17                  in  varchar2  default null
  ,p_information18                  in  varchar2  default null
  ,p_information19                  in  varchar2  default null
  ,p_information20                  in  varchar2  default null
  ,p_information21                  in  varchar2  default null
  ,p_information22                  in  varchar2  default null
  ,p_information23                  in  varchar2  default null
  ,p_information24                  in  varchar2  default null
  ,p_information25                  in  varchar2  default null
  ,p_information26                  in  varchar2  default null
  ,p_information27                  in  varchar2  default null
  ,p_information28                  in  varchar2  default null
  ,p_information29                  in  varchar2  default null
  ,p_information30                  in  varchar2  default null
  ,p_information_category           in  varchar2  default null
  ,p_attribute1                     in  varchar2  default null
  ,p_attribute2                     in  varchar2  default null
  ,p_attribute3                     in  varchar2  default null
  ,p_attribute4                     in  varchar2  default null
  ,p_attribute5                     in  varchar2  default null
  ,p_attribute6                     in  varchar2  default null
  ,p_attribute7                     in  varchar2  default null
  ,p_attribute8                     in  varchar2  default null
  ,p_attribute9                     in  varchar2  default null
  ,p_attribute10                    in  varchar2  default null
  ,p_attribute11                    in  varchar2  default null
  ,p_attribute12                    in  varchar2  default null
  ,p_attribute13                    in  varchar2  default null
  ,p_attribute14                    in  varchar2  default null
  ,p_attribute15                    in  varchar2  default null
  ,p_attribute16                    in  varchar2  default null
  ,p_attribute17                    in  varchar2  default null
  ,p_attribute18                    in  varchar2  default null
  ,p_attribute19                    in  varchar2  default null
  ,p_attribute20                    in  varchar2  default null
  ,p_attribute21                    in  varchar2  default null
  ,p_attribute22                    in  varchar2  default null
  ,p_attribute23                    in  varchar2  default null
  ,p_attribute24                    in  varchar2  default null
  ,p_attribute25                    in  varchar2  default null
  ,p_attribute26                    in  varchar2  default null
  ,p_attribute27                    in  varchar2  default null
  ,p_attribute28                    in  varchar2  default null
  ,p_attribute29                    in  varchar2  default null
  ,p_attribute30                    in  varchar2  default null
  ,p_attribute_category             in  varchar2  default null
  ,p_segment1                       in  varchar2  default null
  ,p_segment2                       in  varchar2  default null
  ,p_segment3                       in  varchar2  default null
  ,p_segment4                       in  varchar2  default null
  ,p_segment5                       in  varchar2  default null
  ,p_segment6                       in  varchar2  default null
  ,p_segment7                       in  varchar2  default null
  ,p_segment8                       in  varchar2  default null
  ,p_segment9                       in  varchar2  default null
  ,p_segment10                      in  varchar2  default null
  ,p_segment11                      in  varchar2  default null
  ,p_segment12                      in  varchar2  default null
  ,p_segment13                      in  varchar2  default null
  ,p_segment14                      in  varchar2  default null
  ,p_segment15                      in  varchar2  default null
  ,p_segment16                      in  varchar2  default null
  ,p_segment17                      in  varchar2  default null
  ,p_segment18                      in  varchar2  default null
  ,p_segment19                      in  varchar2  default null
  ,p_segment20                      in  varchar2  default null
  ,p_segment21                      in  varchar2  default null
  ,p_segment22                      in  varchar2  default null
  ,p_segment23                      in  varchar2  default null
  ,p_segment24                      in  varchar2  default null
  ,p_segment25                      in  varchar2  default null
  ,p_segment26                      in  varchar2  default null
  ,p_segment27                      in  varchar2  default null
  ,p_segment28                      in  varchar2  default null
  ,p_segment29                      in  varchar2  default null
  ,p_segment30                      in  varchar2  default null
  ,p_concat_segments                in  varchar2  default null
  ,p_request_id                     in  number    default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_program_update_date            in  date      default null
  ,p_security_profile_id	    in number	  default hr_security.get_security_profile
  ) ;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< update_position >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a position and should be used if you have HR fully
 * installed.
 *
 * This overload version provides DateTrack features.
 *
 * <p><b>Licensing</b><br>
 * This API version is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The position to be updated must already exist.
 *
 * <p><b>Post Success</b><br>
 * When the position is valid, the API updates the position successfully in the
 * database.
 *
 * <p><b>Post Failure</b><br>
 * The position will not be updated and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_position_id Identifies the position to be modified.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated position row which now exists as of the
 * effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated position row which now exists as of the
 * effective date. If p_validate is true, then set to null.
 * @param p_position_definition_id If p_validate is false, then this uniquely
 * identifes the combination of segments passed. If p_validate is true, then
 * set to null.
 * @param p_valid_grades_changed_warning Set to true when either the position
 * date effective or date end have been modified and at least one valid grade
 * has been updated or deleted. Set to false when neither the position date
 * effective or date end have been modified, or either of them has been
 * modified but no valid grades were altered.
 * @param p_name If p_validate is false, then this identifies concatenation of
 * all name segments. If p_validate is true, then set to null.
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @param p_availability_status_id Current Status of the Position. Refers to
 * PER_SHARED_TYPES.
 * @param p_entry_step_id {@rep:casecolumn HR_ALL_POSITIONS_F.ENTRY_STEP_ID}
 * @param p_entry_grade_rule_id {@rep:casecolumn
 * HR_ALL_POSITIONS_F.ENTRY_GRADE_RULE_ID}
 * @param p_location_id {@rep:casecolumn HR_ALL_POSITIONS_F.LOCATION_ID}
 * @param p_pay_freq_payroll_id {@rep:casecolumn
 * HR_ALL_POSITIONS_F.PAY_FREQ_PAYROLL_ID}
 * @param p_position_transaction_id {@rep:casecolumn
 * HR_ALL_POSITIONS_F.POSITION_TRANSACTION_ID}
 * @param p_prior_position_id {@rep:casecolumn
 * HR_ALL_POSITIONS_F.PRIOR_POSITION_ID}
 * @param p_relief_position_id {@rep:casecolumn
 * HR_ALL_POSITIONS_F.RELIEF_POSITION_ID}
 * @param p_entry_grade_id {@rep:casecolumn HR_ALL_POSITIONS_F.ENTRY_GRADE_ID}
 * @param p_successor_position_id {@rep:casecolumn
 * HR_ALL_POSITIONS_F.SUCCESSOR_POSITION_ID}
 * @param p_supervisor_position_id {@rep:casecolumn
 * HR_ALL_POSITIONS_F.SUPERVISOR_POSITION_ID}
 * @param p_amendment_date {@rep:casecolumn HR_ALL_POSITIONS_F.AMENDMENT_DATE}
 * @param p_amendment_recommendation {@rep:casecolumn
 * HR_ALL_POSITIONS_F.AMENDMENT_RECOMMENDATION}
 * @param p_amendment_ref_number {@rep:casecolumn
 * HR_ALL_POSITIONS_F.AMENDMENT_REF_NUMBER}
 * @param p_bargaining_unit_cd Identifies the bargaining unit. Valid values are
 * defined by 'BARGAINING_UNIT_CODE' lookup_type.
 * @param p_comments Comment text.
 * @param p_current_job_prop_end_date {@rep:casecolumn
 * HR_ALL_POSITIONS_F.CURRENT_JOB_PROP_END_DATE}
 * @param p_current_org_prop_end_date {@rep:casecolumn
 * HR_ALL_POSITIONS_F.CURRENT_ORG_PROP_END_DATE}
 * @param p_avail_status_prop_end_date {@rep:casecolumn
 * HR_ALL_POSITIONS_F.AVAIL_STATUS_PROP_END_DATE}
 * @param p_date_effective The date on which the position becomes active.
 * @param p_date_end {@rep:casecolumn HR_ALL_POSITIONS_F.DATE_END}
 * @param p_earliest_hire_date {@rep:casecolumn
 * HR_ALL_POSITIONS_F.EARLIEST_HIRE_DATE}
 * @param p_fill_by_date {@rep:casecolumn HR_ALL_POSITIONS_F.FILL_BY_DATE}
 * @param p_frequency Frequency of working hours. Valid values are defined by
 * 'FREQUENCY' lookup_type.
 * @param p_fte {@rep:casecolumn HR_ALL_POSITIONS_F.FTE}
 * @param p_max_persons Maximum number of employees allowed for this position.
 * @param p_overlap_period {@rep:casecolumn HR_ALL_POSITIONS_F.OVERLAP_PERIOD}
 * @param p_overlap_unit_cd Unit of period. Valid values are defined by
 * 'QUALIFYING_UNITS' lookup_type.
 * @param p_pay_term_end_day_cd End day of pay term. Valid values are defined
 * by 'DAY_CODE' lookup_type.
 * @param p_pay_term_end_month_cd End month of pay term. Valid values are
 * defined by 'MONTH_CODE' lookup_type.
 * @param p_permanent_temporary_flag Indicates whether position is temporary or
 * permanent. Valid values are defined by 'YES_NO' lookup_type
 * @param p_permit_recruitment_flag Indicates if recruitment can start for the
 * position or not. Valid values are defined by 'YES_NO' lookup_type
 * @param p_position_type Indicates position type. Valid values are defined by
 * 'POSITION_TYPE' lookup_type
 * @param p_posting_description Posting Description.
 * @param p_probation_period Length of probation period.
 * @param p_probation_period_unit_cd Qualifying units. Valid values are defined
 * by 'QUALIFYING_UNITS' lookup_type.
 * @param p_replacement_required_flag Identifies if replacement is required
 * when person assigned is absent. Valid values are defined by 'YES_NO' lookup
 * type.
 * @param p_review_flag Identifies whether the characteristics of the position
 * are under going review or change. Valid values are defined by 'YES_NO'
 * lookup_type
 * @param p_seasonal_flag Identifies if the position is seasonal or not. Valid
 * values are defined by 'YES_NO' lookup_type
 * @param p_security_requirements Security Requirements.
 * @param p_status Position status. Valid values are defined by
 * 'POSITION_STATUS' lookup type.
 * @param p_term_start_day_cd Start day of work term. Valid values are defined
 * by 'DAY_CODE' lookup_type.
 * @param p_term_start_month_cd Start month of work term. Valid values are
 * defined by 'MONTH_CODE' lookup_type.
 * @param p_time_normal_finish Normal end time.
 * @param p_time_normal_start Normal start time.
 * @param p_update_source_cd Identifies if the position has to be copied into
 * the non datetracked table per_all_positions.Valid values are defined by
 * 'YES_NO' lookup_type
 * @param p_working_hours Number of normal working hours.
 * @param p_works_council_approval_flag Identifies if work council approval is
 * needed or not. Valid values are defined by 'YES_NO' lookup_type
 * @param p_work_period_type_cd Identifies that the position is only used
 * during part of the year. Valid values are defined by 'YES_NO' lookup_type
 * @param p_work_term_end_day_cd End day of work term. Valid values are defined
 * by 'DAY_CODE' lookup_type.
 * @param p_work_term_end_month_cd Start day of work term. Valid values are
 * defined by 'MONTH_CODE' lookup_type.
 * @param p_proposed_fte_for_layoff Proposed FTE for layoff
 * @param p_proposed_date_for_layoff Proposed date for layoff
 * @param p_pay_basis_id Foreign Key to per_pay_bases.
 * @param p_supervisor_id Foreign Key to per_all_people_f.
 * @param p_information1 Developer descriptive flexfield segment.
 * @param p_information2 Developer descriptive flexfield segment.
 * @param p_information3 Developer descriptive flexfield segment.
 * @param p_information4 Developer descriptive flexfield segment.
 * @param p_information5 Developer descriptive flexfield segment.
 * @param p_information6 Developer descriptive flexfield segment.
 * @param p_information7 Developer descriptive flexfield segment.
 * @param p_information8 Developer descriptive flexfield segment.
 * @param p_information9 Developer descriptive flexfield segment.
 * @param p_information10 Developer descriptive flexfield segment.
 * @param p_information11 Developer descriptive flexfield segment.
 * @param p_information12 Developer descriptive flexfield segment.
 * @param p_information13 Developer descriptive flexfield segment.
 * @param p_information14 Developer descriptive flexfield segment.
 * @param p_information15 Developer descriptive flexfield segment.
 * @param p_information16 Developer descriptive flexfield segment.
 * @param p_information17 Developer descriptive flexfield segment.
 * @param p_information18 Developer descriptive flexfield segment.
 * @param p_information19 Developer descriptive flexfield segment.
 * @param p_information20 Developer descriptive flexfield segment.
 * @param p_information21 Developer descriptive flexfield segment.
 * @param p_information22 Developer descriptive flexfield segment.
 * @param p_information23 Developer descriptive flexfield segment.
 * @param p_information24 Developer descriptive flexfield segment.
 * @param p_information25 Developer descriptive flexfield segment.
 * @param p_information26 Developer descriptive flexfield segment.
 * @param p_information27 Developer descriptive flexfield segment.
 * @param p_information28 Developer descriptive flexfield segment.
 * @param p_information29 Developer descriptive flexfield segment.
 * @param p_information30 Developer descriptive flexfield segment.
 * @param p_information_category This context value determines which flexfield
 * structure to use with the developer descriptive flexfield segments.
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
 * @param p_attribute_category This context value determines which flexfield
 * structure to use with the descriptive flexfield segments.
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
 * @param p_concat_segments Concatenated string of segment values
 * @param p_request_id When the API is executed from a concurrent program set
 * to the concurrent request identifier.
 * @param p_program_application_id When the API is executed from a concurrent
 * program set to the program's Application.
 * @param p_program_id When the API is executed from a concurrent program set
 * to the program's identifier.
 * @param p_program_update_date When the API is executed from a concurrent
 * program set to when the program was ran.
 * @param p_object_version_number Pass in the current version number of the
 * position to be updated. When the API completes if p_validate is false, will
 * be set to the new version number of the updated position. If p_validate is
 * true will be set to the same value which was passed in.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_datetrack_mode Indicates which DateTrack mode to use when updating
 * the record. You must set to either UPDATE, CORRECTION, UPDATE_OVERRIDE or
 * UPDATE_CHANGE_INSERT. Modes available for use with a particular record
 * depend on the dates of previous record changes and the effective date of
 * this change.
 * @rep:displayname Update Position
 * @rep:category BUSINESS_ENTITY PER_POSITION
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:primaryinstance
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_position
  (p_validate                       in  boolean   default false
  ,p_position_id                    in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_position_definition_id         in out nocopy number
  ,p_valid_grades_changed_warning   out nocopy boolean
  ,p_name                           in out nocopy varchar2
  ,p_language_code                  in  varchar2  default hr_api.userenv_lang
  ,p_availability_status_id         in  number    default hr_api.g_number
--  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_entry_step_id                  in  number    default hr_api.g_number
  ,p_entry_grade_rule_id            in  number    default hr_api.g_number
--  ,p_job_id                         in  number    default hr_api.g_number
  ,p_location_id                    in  number    default hr_api.g_number
--  ,p_organization_id                in  number    default hr_api.g_number
  ,p_pay_freq_payroll_id            in  number    default hr_api.g_number
  ,p_position_transaction_id        in  number    default hr_api.g_number
  ,p_prior_position_id              in  number    default hr_api.g_number
  ,p_relief_position_id             in  number    default hr_api.g_number
  ,p_entry_grade_id                 in  number    default hr_api.g_number
  ,p_successor_position_id          in  number    default hr_api.g_number
  ,p_supervisor_position_id         in  number    default hr_api.g_number
  ,p_amendment_date                 in  date      default hr_api.g_date
  ,p_amendment_recommendation       in  varchar2  default hr_api.g_varchar2
  ,p_amendment_ref_number           in  varchar2  default hr_api.g_varchar2
  ,p_bargaining_unit_cd             in  varchar2  default hr_api.g_varchar2
  ,p_comments                       in  long      default hr_api.g_varchar2
  ,p_current_job_prop_end_date      in  date      default hr_api.g_date
  ,p_current_org_prop_end_date      in  date      default hr_api.g_date
  ,p_avail_status_prop_end_date     in  date      default hr_api.g_date
  ,p_date_effective                 in  date      default hr_api.g_date
  ,p_date_end                       in  date      default hr_api.g_date
  ,p_earliest_hire_date             in  date      default hr_api.g_date
  ,p_fill_by_date                   in  date      default hr_api.g_date
  ,p_frequency                      in  varchar2  default hr_api.g_varchar2
  ,p_fte                            in  number    default hr_api.g_number
  ,p_max_persons                    in  number    default hr_api.g_number
  ,p_overlap_period                 in  number    default hr_api.g_number
  ,p_overlap_unit_cd                in  varchar2  default hr_api.g_varchar2
  ,p_pay_term_end_day_cd            in  varchar2  default hr_api.g_varchar2
  ,p_pay_term_end_month_cd          in  varchar2  default hr_api.g_varchar2
  ,p_permanent_temporary_flag       in  varchar2  default hr_api.g_varchar2
  ,p_permit_recruitment_flag        in  varchar2  default hr_api.g_varchar2
  ,p_position_type                  in  varchar2  default hr_api.g_varchar2
  ,p_posting_description            in  varchar2  default hr_api.g_varchar2
  ,p_probation_period               in  number    default hr_api.g_number
  ,p_probation_period_unit_cd       in  varchar2  default hr_api.g_varchar2
  ,p_replacement_required_flag      in  varchar2  default hr_api.g_varchar2
  ,p_review_flag                    in  varchar2  default hr_api.g_varchar2
  ,p_seasonal_flag                  in  varchar2  default hr_api.g_varchar2
  ,p_security_requirements          in  varchar2  default hr_api.g_varchar2
  ,p_status                         in  varchar2  default hr_api.g_varchar2
  ,p_term_start_day_cd              in  varchar2  default hr_api.g_varchar2
  ,p_term_start_month_cd            in  varchar2  default hr_api.g_varchar2
  ,p_time_normal_finish             in  varchar2  default hr_api.g_varchar2
  ,p_time_normal_start              in  varchar2  default hr_api.g_varchar2
  ,p_update_source_cd               in  varchar2  default hr_api.g_varchar2
  ,p_working_hours                  in  number    default hr_api.g_number
  ,p_works_council_approval_flag    in  varchar2  default hr_api.g_varchar2
  ,p_work_period_type_cd            in  varchar2  default hr_api.g_varchar2
  ,p_work_term_end_day_cd           in  varchar2  default hr_api.g_varchar2
  ,p_work_term_end_month_cd         in  varchar2  default hr_api.g_varchar2
  ,p_proposed_fte_for_layoff        in  number    default hr_api.g_number
  ,p_proposed_date_for_layoff       in  date      default hr_api.g_date
  ,p_pay_basis_id                   in  number    default hr_api.g_number
  ,p_supervisor_id                  in  number    default hr_api.g_number
  --,p_copied_to_old_table_flag       in  varchar2    default hr_api.g_varchar2
  ,p_information1                   in  varchar2  default hr_api.g_varchar2
  ,p_information2                   in  varchar2  default hr_api.g_varchar2
  ,p_information3                   in  varchar2  default hr_api.g_varchar2
  ,p_information4                   in  varchar2  default hr_api.g_varchar2
  ,p_information5                   in  varchar2  default hr_api.g_varchar2
  ,p_information6                   in  varchar2  default hr_api.g_varchar2
  ,p_information7                   in  varchar2  default hr_api.g_varchar2
  ,p_information8                   in  varchar2  default hr_api.g_varchar2
  ,p_information9                   in  varchar2  default hr_api.g_varchar2
  ,p_information10                  in  varchar2  default hr_api.g_varchar2
  ,p_information11                  in  varchar2  default hr_api.g_varchar2
  ,p_information12                  in  varchar2  default hr_api.g_varchar2
  ,p_information13                  in  varchar2  default hr_api.g_varchar2
  ,p_information14                  in  varchar2  default hr_api.g_varchar2
  ,p_information15                  in  varchar2  default hr_api.g_varchar2
  ,p_information16                  in  varchar2  default hr_api.g_varchar2
  ,p_information17                  in  varchar2  default hr_api.g_varchar2
  ,p_information18                  in  varchar2  default hr_api.g_varchar2
  ,p_information19                  in  varchar2  default hr_api.g_varchar2
  ,p_information20                  in  varchar2  default hr_api.g_varchar2
  ,p_information21                  in  varchar2  default hr_api.g_varchar2
  ,p_information22                  in  varchar2  default hr_api.g_varchar2
  ,p_information23                  in  varchar2  default hr_api.g_varchar2
  ,p_information24                  in  varchar2  default hr_api.g_varchar2
  ,p_information25                  in  varchar2  default hr_api.g_varchar2
  ,p_information26                  in  varchar2  default hr_api.g_varchar2
  ,p_information27                  in  varchar2  default hr_api.g_varchar2
  ,p_information28                  in  varchar2  default hr_api.g_varchar2
  ,p_information29                  in  varchar2  default hr_api.g_varchar2
  ,p_information30                  in  varchar2  default hr_api.g_varchar2
  ,p_information_category           in  varchar2  default hr_api.g_varchar2
  ,p_attribute1                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute2                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute3                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute4                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute5                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute6                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute7                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute8                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute9                     in  varchar2  default hr_api.g_varchar2
  ,p_attribute10                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute11                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute12                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute13                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute14                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute15                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute16                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute17                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute18                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute19                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute20                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute21                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute22                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute23                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute24                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute25                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute26                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute27                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute28                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute29                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute30                    in  varchar2  default hr_api.g_varchar2
  ,p_attribute_category             in  varchar2  default hr_api.g_varchar2
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
  ,p_request_id                     in  number    default hr_api.g_number
  ,p_program_application_id         in  number    default hr_api.g_number
  ,p_program_id                     in  number    default hr_api.g_number
  ,p_program_update_date            in  date      default hr_api.g_date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< delete_position >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a position and should be used if you have HR fully
 * installed.
 *
 * This overload version of the delete API provides DateTrack features.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The position to be deleted must already exist. The position to be deleted
 * must not be used in any assignment.
 *
 * <p><b>Post Success</b><br>
 * The position is deleted successfully from the database.
 *
 * <p><b>Post Failure</b><br>
 * The position is not deleted and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_position_id Identifies the position to be deleted.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date for the deleted position row which now exists as of the
 * effective date. If p_validate is true or all row instances have been deleted
 * then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the deleted position row which now exists as of the
 * effective date. If p_validate is true or all row instances have been deleted
 * then set to null.
 * @param p_object_version_number Current version number of the position to be
 * deleted.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_datetrack_mode Indicates which DateTrack mode to use when deleting
 * the record. You must set to either ZAP, DELETE, FUTURE_CHANGE or
 * DELETE_NEXT_CHANGE. Modes available for use with a particular record depend
 * on the dates of previous record changes and the effective date of this
 * change.
 * @param p_security_profile_id Security Profile of the current responsibility.
 * @rep:displayname Delete Position
 * @rep:category BUSINESS_ENTITY PER_POSITION
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:primaryinstance
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_position
  (
   p_validate                       in boolean        default false
  ,p_position_id                    in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in date
  ,p_datetrack_mode                 in varchar2
  ,p_security_profile_id	    in number	  default hr_security.get_security_profile
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
--   p_position_id                 Yes  number   PK of record
--   p_object_version_number        Yes  number   OVN of record
--   p_effective_date               Yes  date     Session Date.
--   p_datetrack_mode               Yes  varchar2 Datetrack mode.
--
-- Post Success:
--
--   Name                           Type     Description
--   p_validation_start_date        Yes      Derived Effective Start Date.
--   p_validation_end_date          Yes      Derived Effective End Date.
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
    p_position_id                 in number
   ,p_object_version_number        in number
   ,p_effective_date              in date
   ,p_datetrack_mode              in varchar2
   ,p_validation_start_date        out nocopy date
   ,p_validation_end_date          out nocopy date
   ,p_language_code               in  varchar2  default hr_api.userenv_lang
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< regenerate_position_name >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  Regenerate_position_name to rebuild position name for only one position
--  from current flexfield values
--
--
-- Prerequisites:
--  If this process is called at the server-side ensure that
--  fnd_profiles are initialized when position flexfield valuesets
--  uses profile values
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_position_id                  Yes  Number   Position_id of the position
--
--
-- Post Success:
--   regenerates position name
--
-- Post Failure:
--   Throws error message
--
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure regenerate_position_name(p_position_id number);
--
-- ----------------------------------------------------------------------------
-- |------------------------< regenerate_position_names >---------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  Regenerate Position Names process is used to rebuild
--  position names using current Position flexfield values.
--  This procedure is called by concurrent program
--
--  Pass p_organization_id if the position names need to be regenerated
--  for all the positions under that organization.
--
--  Pass p_business_group_id if the position name needs to be regenerated
--  for all the positions under that business group
--
--  Pass null to both p_business_group_id and  p_organization_id
--  if the position name needs to be regenerated
--  for all the positions in all the business groups
--
-- Prerequisites:
--  None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_business_group_id            Yes  Number   business_group_id or null
--   p_organization_id              Yes  Number   organization_id or null
--
--
-- Post Success:
--   regenerates position names
--
--   Name                           Type     Description
--   retcode                        Number   returns completion status
--                                           0 for success,

--
-- Post Failure:
--
--   Name                           Type     Description
--   errbuf                         Varchar2 return any error messages
--   retcode                        Number   to return any completion status
--                                           0 for success,
--                                           1 for success with warnings,
--                                           and 2 for error
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< regenerate_position_names >---------------------|
-- ----------------------------------------------------------------------------
--  Regenerate Position Names process is used to rebuild
--  position names using current Position flexfield values
--
procedure regenerate_position_names(
                            errbuf   out nocopy varchar2
                          , retcode   out nocopy number
                          , p_business_group_id number,
                            p_organization_id number);
--
--
-- end of date tracked position apis
--
--
end hr_position_api;

/
