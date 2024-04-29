--------------------------------------------------------
--  DDL for Package HR_SIT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_SIT_API" AUTHID CURRENT_USER as
/* $Header: pesitapi.pkh 120.2.12010000.1 2008/07/28 05:57:54 appldev ship $ */
/*#
 * This package contains APIs which create and maintain special information
 * types.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Special Information Type
*/
--
-- ----------------------------------------------------------------------------
-- |--------------------------------< create_sit >----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a special information record for a person.
 *
 * This API creates a special information type which is an additional set of
 * structured data captured for a person, implemented by means of an instance
 * of the per person analysis key flexfield. An example may be the use of
 * special information types to hold medical details or disciplinary records
 * for a person. This special information types prove a flexible means to
 * capture multiple additional types of data about a person, beyond that stored
 * directly on the person record. Special information types are comprised of
 * component fields or segments, organised as predefined structures, and
 * validation logic may be attached to each segment to ensure the data held for
 * the information type for the person is valid.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The person for whom the special information type is to be created must
 * exist. The structure of the special information type to be created must have
 * been defined previously.
 *
 * <p><b>Post Success</b><br>
 * A special information record is created for the person.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the special information record for the person and
 * raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_person_id Uniquely identifies the person for whom the special
 * information applies.
 * @param p_business_group_id Uniquely identifies the business group.
 * @param p_id_flex_num Uniquely identifies the special information type
 * structure of the key flexfield.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_comments Comment text.
 * @param p_date_from The date the special information type is valid from.
 * @param p_date_to The date the special information type is valid until.
 * @param p_request_id When the API is executed from a concurrent program set
 * to the concurrent request identifier.
 * @param p_program_application_id When the API is executed from a concurrent
 * program set to the program's Application.
 * @param p_program_id When the API is executed from a concurrent program set
 * to the program's identifier.
 * @param p_program_update_date When the API is executed from a concurrent
 * program set to when the program was ran.
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
 * @param p_segment1 Component of the special information type for the person.
 * @param p_segment2 Component of the special information type for the person.
 * @param p_segment3 Component of the special information type for the person.
 * @param p_segment4 Component of the special information type for the person.
 * @param p_segment5 Component of the special information type for the person.
 * @param p_segment6 Component of the special information type for the person.
 * @param p_segment7 Component of the special information type for the person.
 * @param p_segment8 Component of the special information type for the person.
 * @param p_segment9 Component of the special information type for the person.
 * @param p_segment10 Component of the special information type for the person.
 * @param p_segment11 Component of the special information type for the person.
 * @param p_segment12 Component of the special information type for the person.
 * @param p_segment13 Component of the special information type for the person.
 * @param p_segment14 Component of the special information type for the person.
 * @param p_segment15 Component of the special information type for the person.
 * @param p_segment16 Component of the special information type for the person.
 * @param p_segment17 Component of the special information type for the person.
 * @param p_segment18 Component of the special information type for the person.
 * @param p_segment19 Component of the special information type for the person.
 * @param p_segment20 Component of the special information type for the person.
 * @param p_segment21 Component of the special information type for the person.
 * @param p_segment22 Component of the special information type for the person.
 * @param p_segment23 Component of the special information type for the person.
 * @param p_segment24 Component of the special information type for the person.
 * @param p_segment25 Component of the special information type for the person.
 * @param p_segment26 Component of the special information type for the person.
 * @param p_segment27 Component of the special information type for the person.
 * @param p_segment28 Component of the special information type for the person.
 * @param p_segment29 Component of the special information type for the person.
 * @param p_segment30 Component of the special information type for the person.
 * @param p_concat_segments The concatenation of all segment values for the
 * special information type.
 * @param p_analysis_criteria_id Uniquely identifies the analysis criteria
 * record holding the details for the special information type (person
 * analysis).
 * @param p_person_analysis_id If p_validate is false, uniquely identifies the
 * person analysis (information type) for the person. if p_validate is true,
 * set to null.
 * @param p_pea_object_version_number If p_validate is false, set to the
 * version number of the person analysis created. If p_validate is true, set to
 * null.
 * @rep:displayname Create Special Information Type
 * @rep:category BUSINESS_ENTITY HR_PERSON
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_sit
  (p_validate                  in     boolean default false
  ,p_person_id                 in     number
  ,p_business_group_id         in     number
  ,p_id_flex_num               in     number
  ,p_effective_date            in     date
  ,p_comments                  in     varchar2 default null
  ,p_date_from                 in     date     default null
  ,p_date_to                   in     date     default null
  ,p_request_id                in     number   default null
  ,p_program_application_id    in     number   default null
  ,p_program_id                in     number   default null
  ,p_program_update_date       in     date     default null
  ,p_attribute_category        in     varchar2 default null
  ,p_attribute1                in     varchar2 default null
  ,p_attribute2                in     varchar2 default null
  ,p_attribute3                in     varchar2 default null
  ,p_attribute4                in     varchar2 default null
  ,p_attribute5                in     varchar2 default null
  ,p_attribute6                in     varchar2 default null
  ,p_attribute7                in     varchar2 default null
  ,p_attribute8                in     varchar2 default null
  ,p_attribute9                in     varchar2 default null
  ,p_attribute10               in     varchar2 default null
  ,p_attribute11               in     varchar2 default null
  ,p_attribute12               in     varchar2 default null
  ,p_attribute13               in     varchar2 default null
  ,p_attribute14               in     varchar2 default null
  ,p_attribute15               in     varchar2 default null
  ,p_attribute16               in     varchar2 default null
  ,p_attribute17               in     varchar2 default null
  ,p_attribute18               in     varchar2 default null
  ,p_attribute19               in     varchar2 default null
  ,p_attribute20               in     varchar2 default null
  ,p_segment1                  in     varchar2 default null
  ,p_segment2                  in     varchar2 default null
  ,p_segment3                  in     varchar2 default null
  ,p_segment4                  in     varchar2 default null
  ,p_segment5                  in     varchar2 default null
  ,p_segment6                  in     varchar2 default null
  ,p_segment7                  in     varchar2 default null
  ,p_segment8                  in     varchar2 default null
  ,p_segment9                  in     varchar2 default null
  ,p_segment10                 in     varchar2 default null
  ,p_segment11                 in     varchar2 default null
  ,p_segment12                 in     varchar2 default null
  ,p_segment13                 in     varchar2 default null
  ,p_segment14                 in     varchar2 default null
  ,p_segment15                 in     varchar2 default null
  ,p_segment16                 in     varchar2 default null
  ,p_segment17                 in     varchar2 default null
  ,p_segment18                 in     varchar2 default null
  ,p_segment19                 in     varchar2 default null
  ,p_segment20                 in     varchar2 default null
  ,p_segment21                 in     varchar2 default null
  ,p_segment22                 in     varchar2 default null
  ,p_segment23                 in     varchar2 default null
  ,p_segment24                 in     varchar2 default null
  ,p_segment25                 in     varchar2 default null
  ,p_segment26                 in     varchar2 default null
  ,p_segment27                 in     varchar2 default null
  ,p_segment28                 in     varchar2 default null
  ,p_segment29                 in     varchar2 default null
  ,p_segment30                 in     varchar2 default null
  ,p_concat_segments           in     varchar2 default null
  ,p_analysis_criteria_id      in out nocopy number
  ,p_person_analysis_id        out nocopy    number
  ,p_pea_object_version_number out nocopy    number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------------< update_sit >----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a special information type for a person.
 *
 * This API updates a special information type which is an additional set of
 * structured data captured for a person, implemented by means of an instance
 * of the per person analysis key flexfield. An example may be the use of
 * special information types to hold medical details or disciplinary records
 * for a person. This special information types prove a flexible means to
 * capture multiple additional types of data about a person, beyond that stored
 * directly on the person record. Special information types are comprised of
 * component fields or segments, organised as predefined structures, and
 * validation logic may be attached to each segment to ensure the data held for
 * the information type for the person is valid.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The person to whom the special information type is to be updated must exist.
 * The structure of the special information type to be updated must have been
 * defined previously.
 *
 * <p><b>Post Success</b><br>
 * The special information record is updated.
 *
 * <p><b>Post Failure</b><br>
 * API does not update a special information record and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_person_analysis_id Uniquely identifies the person analysis
 * (information type) for the person.
 * @param p_pea_object_version_number If p_validate is false, set to the
 * version number of the person analysis updated. If p_validate is true, set to
 * the supplied value.
 * @param p_comments Comment text.
 * @param p_date_from The date the special information type is valid from.
 * @param p_date_to The date the special information type is valid until.
 * @param p_request_id When the API is executed from a concurrent program set
 * to the concurrent request identifier.
 * @param p_program_application_id When the API is executed from a concurrent
 * program set to the program's Application.
 * @param p_program_id When the API is executed from a concurrent program set
 * to the program's identifier.
 * @param p_program_update_date When the API is executed from a concurrent
 * program set to when the program was ran.
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
 * @param p_segment1 Component of the special information type for the person.
 * @param p_segment2 Component of the special information type for the person.
 * @param p_segment3 Component of the special information type for the person.
 * @param p_segment4 Component of the special information type for the person.
 * @param p_segment5 Component of the special information type for the person.
 * @param p_segment6 Component of the special information type for the person.
 * @param p_segment7 Component of the special information type for the person.
 * @param p_segment8 Component of the special information type for the person.
 * @param p_segment9 Component of the special information type for the person.
 * @param p_segment10 Component of the special information type for the person.
 * @param p_segment11 Component of the special information type for the person.
 * @param p_segment12 Component of the special information type for the person.
 * @param p_segment13 Component of the special information type for the person.
 * @param p_segment14 Component of the special information type for the person.
 * @param p_segment15 Component of the special information type for the person.
 * @param p_segment16 Component of the special information type for the person.
 * @param p_segment17 Component of the special information type for the person.
 * @param p_segment18 Component of the special information type for the person.
 * @param p_segment19 Component of the special information type for the person.
 * @param p_segment20 Component of the special information type for the person.
 * @param p_segment21 Component of the special information type for the person.
 * @param p_segment22 Component of the special information type for the person.
 * @param p_segment23 Component of the special information type for the person.
 * @param p_segment24 Component of the special information type for the person.
 * @param p_segment25 Component of the special information type for the person.
 * @param p_segment26 Component of the special information type for the person.
 * @param p_segment27 Component of the special information type for the person.
 * @param p_segment28 Component of the special information type for the person.
 * @param p_segment29 Component of the special information type for the person.
 * @param p_segment30 Component of the special information type for the person.
 * @param p_concat_segments The concatenation of all segment values for the
 * special information type.
 * @param p_analysis_criteria_id If p_validate is false, uniquely identifies
 * the combination of segments passed. If p_validate is true, set to supplied
 * value. (It derives segment values from the analysis criteria).
 * @rep:displayname Update Special Information Type
 * @rep:category BUSINESS_ENTITY HR_PERSON
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_sit
  (p_validate                  in     boolean default false
  ,p_person_analysis_id        in     number
  ,p_pea_object_version_number in out nocopy number
  ,p_comments                  in     varchar2 default hr_api.g_varchar2
  ,p_date_from                 in     date     default hr_api.g_date
  ,p_date_to                   in     date     default hr_api.g_date
  ,p_request_id                in     number   default hr_api.g_number
  ,p_program_application_id    in     number   default hr_api.g_number
  ,p_program_id                in     number   default hr_api.g_number
  ,p_program_update_date       in     date     default hr_api.g_date
  ,p_attribute_category        in     varchar2 default hr_api.g_varchar2
  ,p_attribute1                in     varchar2 default hr_api.g_varchar2
  ,p_attribute2                in     varchar2 default hr_api.g_varchar2
  ,p_attribute3                in     varchar2 default hr_api.g_varchar2
  ,p_attribute4                in     varchar2 default hr_api.g_varchar2
  ,p_attribute5                in     varchar2 default hr_api.g_varchar2
  ,p_attribute6                in     varchar2 default hr_api.g_varchar2
  ,p_attribute7                in     varchar2 default hr_api.g_varchar2
  ,p_attribute8                in     varchar2 default hr_api.g_varchar2
  ,p_attribute9                in     varchar2 default hr_api.g_varchar2
  ,p_attribute10               in     varchar2 default hr_api.g_varchar2
  ,p_attribute11               in     varchar2 default hr_api.g_varchar2
  ,p_attribute12               in     varchar2 default hr_api.g_varchar2
  ,p_attribute13               in     varchar2 default hr_api.g_varchar2
  ,p_attribute14               in     varchar2 default hr_api.g_varchar2
  ,p_attribute15               in     varchar2 default hr_api.g_varchar2
  ,p_attribute16               in     varchar2 default hr_api.g_varchar2
  ,p_attribute17               in     varchar2 default hr_api.g_varchar2
  ,p_attribute18               in     varchar2 default hr_api.g_varchar2
  ,p_attribute19               in     varchar2 default hr_api.g_varchar2
  ,p_attribute20               in     varchar2 default hr_api.g_varchar2
  ,p_segment1                  in     varchar2 default hr_api.g_varchar2
  ,p_segment2                  in     varchar2 default hr_api.g_varchar2
  ,p_segment3                  in     varchar2 default hr_api.g_varchar2
  ,p_segment4                  in     varchar2 default hr_api.g_varchar2
  ,p_segment5                  in     varchar2 default hr_api.g_varchar2
  ,p_segment6                  in     varchar2 default hr_api.g_varchar2
  ,p_segment7                  in     varchar2 default hr_api.g_varchar2
  ,p_segment8                  in     varchar2 default hr_api.g_varchar2
  ,p_segment9                  in     varchar2 default hr_api.g_varchar2
  ,p_segment10                 in     varchar2 default hr_api.g_varchar2
  ,p_segment11                 in     varchar2 default hr_api.g_varchar2
  ,p_segment12                 in     varchar2 default hr_api.g_varchar2
  ,p_segment13                 in     varchar2 default hr_api.g_varchar2
  ,p_segment14                 in     varchar2 default hr_api.g_varchar2
  ,p_segment15                 in     varchar2 default hr_api.g_varchar2
  ,p_segment16                 in     varchar2 default hr_api.g_varchar2
  ,p_segment17                 in     varchar2 default hr_api.g_varchar2
  ,p_segment18                 in     varchar2 default hr_api.g_varchar2
  ,p_segment19                 in     varchar2 default hr_api.g_varchar2
  ,p_segment20                 in     varchar2 default hr_api.g_varchar2
  ,p_segment21                 in     varchar2 default hr_api.g_varchar2
  ,p_segment22                 in     varchar2 default hr_api.g_varchar2
  ,p_segment23                 in     varchar2 default hr_api.g_varchar2
  ,p_segment24                 in     varchar2 default hr_api.g_varchar2
  ,p_segment25                 in     varchar2 default hr_api.g_varchar2
  ,p_segment26                 in     varchar2 default hr_api.g_varchar2
  ,p_segment27                 in     varchar2 default hr_api.g_varchar2
  ,p_segment28                 in     varchar2 default hr_api.g_varchar2
  ,p_segment29                 in     varchar2 default hr_api.g_varchar2
  ,p_segment30                 in     varchar2 default hr_api.g_varchar2
  ,p_concat_segments           in     varchar2 default hr_api.g_varchar2
  ,p_analysis_criteria_id      in out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------------< delete_sit >----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a special information type for a person.
 *
 * This API deletes a special information type which is an additional set of
 * structured data captured for a person, implemented by means of an instance
 * of the per person analyses key flexfield. An example may be the use of
 * special information types to hold medical details or disciplinary records
 * for a person. This special information types prove a flexible means to
 * capture multiple additional types of data about a person, beyond that stored
 * directly on the person record. Special information types are comprised of
 * component fields or segments, organised as predefined structures, and
 * validation logic may be attached to each segment to ensure the data held for
 * the information type for the person is valid.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The special information type specified must exist.
 *
 * <p><b>Post Success</b><br>
 * The API deletes the special information type record.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the special information type and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_person_analysis_id The identifier of the special information type
 * to be deleted.
 * @param p_pea_object_version_number Current version number of the special
 * information type (per person analysis) to be deleted.
 * @rep:displayname Delete Special Information Type
 * @rep:category BUSINESS_ENTITY HR_PERSON
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_sit
  (p_validate                       in     boolean  default false
  ,p_person_analysis_id             in     number
  ,p_pea_object_version_number      in     number
  );
--

-- ----------------------------------------------------------------------------
-- |----------------------------<  lck  >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API locks a SIT record on the PER_PERSON_ANALYSES table.
--
-- Prerequisites:
--   The SIT specified by p_perosn_analysis_id and p_pea_object_version_number
--   must exist.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_person_analysis_id            Y   number   Person Analysis id.
--   p_pea_object_version_number     Y   number   Version number of the SIT
--                                                record on PER_PERSON_ANALYSIS
--                                                not that of
--                                                PER_ANALYSIS_CRITERIA
-- Post Success:
--   The API locks the SIT record.
--
-- Post Failure:
--   The API does not lock the SIT and raises an error.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure lck
  (p_person_analysis_id             in     number
  ,p_pea_object_version_number      in     number
  );
--



end HR_SIT_API;

/
