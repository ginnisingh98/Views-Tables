--------------------------------------------------------
--  DDL for Package HR_GRADE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_GRADE_API" AUTHID CURRENT_USER as
/* $Header: pegrdapi.pkh 120.1.12010000.3 2008/12/05 08:02:39 sidsaxen ship $ */
/*#
 * The package contains APIs that maintain grade information.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Grade
*/
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< create_grade >---------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a grade.
 *
 * A component of an employee assignment that defines their level and can be
 * used to control the value of their salary and other compensation elements.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A business group must exist. A grade keyflex field must be defined for the
 * business group the grade is to be created in. At least one segment of this
 * flexfield must have a value.
 *
 * <p><b>Post Success</b><br>
 * A grade will be created.
 *
 * <p><b>Post Failure</b><br>
 * A grade will not be created and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_business_group_id The identifier of the business group that the
 * grade will be created in.
 * @param p_date_from The date on which the grade is active.
 * @param p_sequence Numerical identifier that orders the sequence of grades.
 * Must be unique within the business group.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_date_to The date after which the grade is no longer active
 * @param p_request_id When the API is executed from a concurrent program set
 * to the concurrent request identifier.
 * @param p_program_application_id When the API is executed from a concurrent
 * program set to the program's Application.
 * @param p_program_id When the API is executed from a concurrent program set
 * to the program's identifier.
 * @param p_program_update_date When the API is executed from a concurrent
 * program set to when the program was ran.
 * @param p_last_update_date The date upon which the record was last updated.
 * @param p_last_updated_by The system identifier of the user who last updated
 * the record.
 * @param p_last_update_login The operating system login of the user who last
 * updated the record.
 * @param p_created_by The system identifier of the user who created the
 * record.
 * @param p_creation_date The date upon which the record was created.
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
 * @param p_information_category This context value determines which flexfield
 * structure to use with the developer descriptive flexfield segments.
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
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @param p_concat_segments Alternative to passing in individual key flexfield
 * segments.
 * @param p_short_name Short name for the grade, used in grade step
 * progression. Has to be unique within the business group.
 * @param p_grade_id If p_validate is false, uniquely identifies the grade
 * created. If p_validate is true, set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created grade. If p_validate is true, then the value
 * will be null.
 * @param p_grade_definition_id If p_validate is false, uniquely identifies the
 * combination of segments passed. If p_validate is true, set to null.
 * @param p_name If p_validate is false, concatenation of all segments. If
 * p_validate is true, set to null.
 * @rep:displayname Create Grade
 * @rep:category BUSINESS_ENTITY PER_GRADE
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_grade
  (p_validate                      in     boolean  default false
  ,p_business_group_id             in     number
  ,p_date_from                     in     date
  ,p_sequence			   in	  number
  ,p_effective_date	           in     date     default null
  ,p_date_to                       in     date     default null
  ,p_request_id			   in 	  number   default null
  ,p_program_application_id        in 	  number   default null
  ,p_program_id                    in 	  number   default null
  ,p_program_update_date           in 	  date     default null
  ,p_last_update_date              in 	  date     default null
  ,p_last_updated_by               in 	  number   default null
  ,p_last_update_login             in 	  number   default null
  ,p_created_by                    in 	  number   default null
  ,p_creation_date                 in 	  date     default null
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
  ,p_information_category          in     varchar2 default null
  ,p_information1 	           in     varchar2 default null
  ,p_information2 	           in     varchar2 default null
  ,p_information3 	           in     varchar2 default null
  ,p_information4 	           in     varchar2 default null
  ,p_information5 	           in     varchar2 default null
  ,p_information6 	           in     varchar2 default null
  ,p_information7 	           in     varchar2 default null
  ,p_information8 	           in     varchar2 default null
  ,p_information9 	           in     varchar2 default null
  ,p_information10 	           in     varchar2 default null
  ,p_information11 	           in     varchar2 default null
  ,p_information12 	           in     varchar2 default null
  ,p_information13 	           in     varchar2 default null
  ,p_information14 	           in     varchar2 default null
  ,p_information15 	           in     varchar2 default null
  ,p_information16 	           in     varchar2 default null
  ,p_information17 	           in     varchar2 default null
  ,p_information18 	           in     varchar2 default null
  ,p_information19 	           in     varchar2 default null
  ,p_information20 	           in     varchar2 default null
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
  ,p_language_code                 in     varchar2 default hr_api.userenv_lang
  ,p_concat_segments               in     varchar2 default null
  ,p_short_name                    in     varchar2 default null
  ,p_grade_id                      out nocopy    number
  ,p_object_version_number         out nocopy    number
  ,p_grade_definition_id           in out nocopy number
  ,p_name                          in out nocopy varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< update_grade >---------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a grade.
 *
 * A component of an employee assignment that defines their level and can be
 * used to control the value of their salary and other compensation elements.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A grade must exist.
 *
 * <p><b>Post Success</b><br>
 * The grade will be updated.
 *
 * <p><b>Post Failure</b><br>
 * The grade is not updated and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_grade_id Uniquely identifies the grade to be updated.
 * @param p_sequence Numerical identifier that orders the sequence of grades.
 * Must be unique within the business group.
 * @param p_date_from The date on which the grade is active.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_date_to The date after which the grade is no longer active
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
 * @param p_information_category This context value determines which flexfield
 * structure to use with the developer descriptive flexfield segments.
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
 * @param p_last_update_date The date upon which the record was last updated.
 * @param p_last_updated_by The system identifier of the user who last updated
 * the record.
 * @param p_last_update_login The operating system login of the user who last
 * updated the record.
 * @param p_created_by The system identifier of the user who created the
 * record.
 * @param p_creation_date The date upon which the record was created.
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
 * @param p_language_code Specifies to which language the translation values
 * apply. You can set to the base or any installed language. The default value
 * of hr_api.userenv_lang is equivalent to the RDBMS userenv('LANG') function
 * value.
 * @param p_short_name Short name for the grade, used in grade step
 * progression. Has to be unique within the business group.
 * @param p_concat_segments Alternative to passing in individual key flexfield
 * segments.
 * @param p_name If p_validate is false, concatenation of all segments. If
 * p_validate is true, set to null.
 * @param p_object_version_number Pass in the current version number of the
 * grade to be updated. When the API completes if p_validate is false, will be
 * set to the new version number of the updated grade If p_validate is true
 * will be set to the same value which was passed in.
 * @param p_grade_definition_id If p_validate is false, uniquely identifies the
 * combination of segments passed. If p_validate is true, set to null.
 * @param p_form_calling Specifies where the API is being called from and perform
 * action according to it. If p_form_calling is true, update only the grade
 * definition. If p_form_calling is false then along with grade definition update
 * call other APIs to update its dependent records.
 * @rep:displayname Update Grade
 * @rep:category BUSINESS_ENTITY PER_GRADE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
 procedure update_grade
  (P_VALIDATE			    IN	  BOOLEAN default false
   ,P_GRADE_ID             	    IN    NUMBER
   ,P_SEQUENCE                      IN    NUMBER default hr_api.g_number
   ,P_DATE_FROM                     IN    DATE default hr_api.g_date
   ,p_effective_date		    in    date default hr_api.g_date
   ,P_DATE_TO                       IN    DATE default hr_api.g_date
   ,P_REQUEST_ID                    IN    NUMBER default hr_api.g_number
   ,P_PROGRAM_APPLICATION_ID        IN    NUMBER default hr_api.g_number
   ,P_PROGRAM_ID                    IN    NUMBER default hr_api.g_number
   ,P_PROGRAM_UPDATE_DATE           IN    DATE default hr_api.g_date
   ,P_ATTRIBUTE_CATEGORY            IN    VARCHAR2 default hr_api.g_varchar2
   ,P_ATTRIBUTE1                    IN    VARCHAR2 default hr_api.g_varchar2
   ,P_ATTRIBUTE2                    IN    VARCHAR2 default hr_api.g_varchar2
   ,P_ATTRIBUTE3                    IN    VARCHAR2 default hr_api.g_varchar2
   ,P_ATTRIBUTE4                    IN    VARCHAR2 default hr_api.g_varchar2
   ,P_ATTRIBUTE5                    IN    VARCHAR2 default hr_api.g_varchar2
   ,P_ATTRIBUTE6                    IN    VARCHAR2 default hr_api.g_varchar2
   ,P_ATTRIBUTE7                    IN    VARCHAR2 default hr_api.g_varchar2
   ,P_ATTRIBUTE8                    IN    VARCHAR2 default hr_api.g_varchar2
   ,P_ATTRIBUTE9                    IN    VARCHAR2 default hr_api.g_varchar2
   ,P_ATTRIBUTE10                   IN    VARCHAR2 default hr_api.g_varchar2
   ,P_ATTRIBUTE11                   IN    VARCHAR2 default hr_api.g_varchar2
   ,P_ATTRIBUTE12                   IN    VARCHAR2 default hr_api.g_varchar2
   ,P_ATTRIBUTE13                   IN    VARCHAR2 default hr_api.g_varchar2
   ,P_ATTRIBUTE14                   IN    VARCHAR2 default hr_api.g_varchar2
   ,P_ATTRIBUTE15                   IN    VARCHAR2 default hr_api.g_varchar2
   ,P_ATTRIBUTE16                   IN    VARCHAR2 default hr_api.g_varchar2
   ,P_ATTRIBUTE17                   IN    VARCHAR2 default hr_api.g_varchar2
   ,P_ATTRIBUTE18                   IN    VARCHAR2 default hr_api.g_varchar2
   ,P_ATTRIBUTE19                   IN    VARCHAR2 default hr_api.g_varchar2
   ,P_ATTRIBUTE20                   IN    VARCHAR2 default hr_api.g_varchar2
   ,P_INFORMATION_CATEGORY          IN    VARCHAR2 default hr_api.g_varchar2
   ,P_INFORMATION1                  IN    VARCHAR2 default hr_api.g_varchar2
   ,P_INFORMATION2                  IN    VARCHAR2 default hr_api.g_varchar2
   ,P_INFORMATION3                  IN    VARCHAR2 default hr_api.g_varchar2
   ,P_INFORMATION4                  IN    VARCHAR2 default hr_api.g_varchar2
   ,P_INFORMATION5                  IN    VARCHAR2 default hr_api.g_varchar2
   ,P_INFORMATION6                  IN    VARCHAR2 default hr_api.g_varchar2
   ,P_INFORMATION7                  IN    VARCHAR2 default hr_api.g_varchar2
   ,P_INFORMATION8                  IN    VARCHAR2 default hr_api.g_varchar2
   ,P_INFORMATION9                  IN    VARCHAR2 default hr_api.g_varchar2
   ,P_INFORMATION10                 IN    VARCHAR2 default hr_api.g_varchar2
   ,P_INFORMATION11                 IN    VARCHAR2 default hr_api.g_varchar2
   ,P_INFORMATION12                 IN    VARCHAR2 default hr_api.g_varchar2
   ,P_INFORMATION13                 IN    VARCHAR2 default hr_api.g_varchar2
   ,P_INFORMATION14                 IN    VARCHAR2 default hr_api.g_varchar2
   ,P_INFORMATION15                 IN    VARCHAR2 default hr_api.g_varchar2
   ,P_INFORMATION16                 IN    VARCHAR2 default hr_api.g_varchar2
   ,P_INFORMATION17                 IN    VARCHAR2 default hr_api.g_varchar2
   ,P_INFORMATION18                 IN    VARCHAR2 default hr_api.g_varchar2
   ,P_INFORMATION19                 IN    VARCHAR2 default hr_api.g_varchar2
   ,P_INFORMATION20                 IN    VARCHAR2 default hr_api.g_varchar2
   ,P_LAST_UPDATE_DATE              IN    DATE default hr_api.g_date
   ,P_LAST_UPDATED_BY               IN    NUMBER default hr_api.g_number
   ,P_LAST_UPDATE_LOGIN             IN    NUMBER default hr_api.g_number
   ,P_CREATED_BY                    IN    NUMBER default hr_api.g_number
   ,P_CREATION_DATE                 IN    DATE default hr_api.g_date
   ,P_SEGMENT1                      IN    VARCHAR2 default hr_api.g_varchar2
   ,P_SEGMENT2                      IN    VARCHAR2 default hr_api.g_varchar2
   ,P_SEGMENT3                      IN    VARCHAR2 default hr_api.g_varchar2
   ,P_SEGMENT4                      IN    VARCHAR2 default hr_api.g_varchar2
   ,P_SEGMENT5                      IN    VARCHAR2 default hr_api.g_varchar2
   ,P_SEGMENT6                      IN    VARCHAR2 default hr_api.g_varchar2
   ,P_SEGMENT7                      IN    VARCHAR2 default hr_api.g_varchar2
   ,P_SEGMENT8                      IN    VARCHAR2 default hr_api.g_varchar2
   ,P_SEGMENT9                      IN    VARCHAR2 default hr_api.g_varchar2
   ,P_SEGMENT10                     IN    VARCHAR2 default hr_api.g_varchar2
   ,P_SEGMENT11                     IN    VARCHAR2 default hr_api.g_varchar2
   ,P_SEGMENT12                     IN    VARCHAR2 default hr_api.g_varchar2
   ,P_SEGMENT13                     IN    VARCHAR2 default hr_api.g_varchar2
   ,P_SEGMENT14                     IN    VARCHAR2 default hr_api.g_varchar2
   ,P_SEGMENT15                     IN    VARCHAR2 default hr_api.g_varchar2
   ,P_SEGMENT16                     IN    VARCHAR2 default hr_api.g_varchar2
   ,P_SEGMENT17                     IN    VARCHAR2 default hr_api.g_varchar2
   ,P_SEGMENT18                     IN    VARCHAR2 default hr_api.g_varchar2
   ,P_SEGMENT19                     IN    VARCHAR2 default hr_api.g_varchar2
   ,P_SEGMENT20                     IN    VARCHAR2 default hr_api.g_varchar2
   ,P_SEGMENT21                     IN    VARCHAR2 default hr_api.g_varchar2
   ,P_SEGMENT22                     IN    VARCHAR2 default hr_api.g_varchar2
   ,P_SEGMENT23                     IN    VARCHAR2 default hr_api.g_varchar2
   ,P_SEGMENT24                     IN    VARCHAR2 default hr_api.g_varchar2
   ,P_SEGMENT25                     IN    VARCHAR2 default hr_api.g_varchar2
   ,P_SEGMENT26                     IN    VARCHAR2 default hr_api.g_varchar2
   ,P_SEGMENT27                     IN    VARCHAR2 default hr_api.g_varchar2
   ,P_SEGMENT28                     IN    VARCHAR2 default hr_api.g_varchar2
   ,P_SEGMENT29                     IN    VARCHAR2 default hr_api.g_varchar2
   ,P_SEGMENT30                     IN    VARCHAR2 default hr_api.g_varchar2
   ,P_LANGUAGE_CODE                 IN    VARCHAR2 default hr_api.userenv_lang
   ,P_SHORT_NAME   		    IN    VARCHAR2 default hr_api.g_varchar2
   ,P_CONCAT_SEGMENTS               IN OUT NOCOPY VARCHAR2
   ,P_NAME                          IN OUT NOCOPY varchar2
   ,P_OBJECT_VERSION_NUMBER	    IN OUT NOCOPY NUMBER
   ,P_GRADE_DEFINITION_ID           IN OUT NOCOPY NUMBER
   ,P_FORM_CALLING                  IN    BOOLEAN default false  --for bug 6522394
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< delete_grade >---------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a grade.
 *
 * A component of an employee assignment that defines their level and can be
 * used to control the value of their salary and other compensation elements.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A grade must exist and not be attached to any assignment.
 *
 * <p><b>Post Success</b><br>
 * The grade will be deleted.
 *
 * <p><b>Post Failure</b><br>
 * The grade will not be deleted and en error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_grade_id Uniquely identifies the grade to be deleted.
 * @param p_object_version_number Current version number of the grade to be
 * deleted.
 * @rep:displayname Delete Grade
 * @rep:category BUSINESS_ENTITY PER_GRADE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_grade
  (p_validate                      in     boolean  default false
  ,p_grade_id                      in     number
  ,p_object_version_number         in out nocopy number);

--
end hr_grade_api;
--

/
