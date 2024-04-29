--------------------------------------------------------
--  DDL for Package HR_PARTICIPANTS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PARTICIPANTS_API" AUTHID CURRENT_USER as
/* $Header: peparapi.pkh 120.2.12010000.2 2008/08/06 09:20:39 ubhat ship $*/
/*#
 * This package contains participant APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Participant
*/
--
-- ----------------------------------------------------------------------------
-- |----------------------------< create_participant >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new participant.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The participating person, appraisal and questionnaire template must exist as
 * of effective date. Questionnaire template is optional depending upon the
 * type of participant.
 *
 * <p><b>Post Success</b><br>
 * The participant will be successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The participant will not be created and an error will be raised.
 * @param p_participant_id If p_validate is false, then this uniquely
 * identifies the participant created. If p_validate is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created participant. If p_validate is true, then the
 * value will be null.
 * @param p_questionnaire_template_id {@rep:casecolumn
 * HR_QUESTIONNAIRES.QUESTIONNAIRE_TEMPLATE_ID}
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_business_group_id Business group id in which the participant is
 * created.
 * @param p_participation_in_table Participating entity. For example
 * PER_APPRAISALS.
 * @param p_participation_in_column Participating entities reference column.
 * For example APPRAISAL_ID.
 * @param p_participation_in_id Participating entities ID. For example the
 * actual value of the APPRAISAL_ID.
 * @param p_participation_status Participant's Status. Valid values are defined
 * by 'PARTICIPATION_ACCESS' lookup type.
 * @param p_participation_type Participant's Type. Valid values are defined by
 * 'PARTICIPATION_TYPE' lookup type.
 * @param p_last_notified_date Date last notified.
 * @param p_date_completed Date last participation completed.
 * @param p_comments Comment text.
 * @param p_person_id Identifies the person for whom you create the participant
 * record.
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
 * @param p_participant_usage_status Used to track the offline status of the
 * Participant's appraisal. Valid values are defined by
 * 'APPRAISAL_OFFLINE_STATUS' lookup type.
 * @rep:displayname Create Participant
 * @rep:category BUSINESS_ENTITY PER_APPRAISAL
 * @rep:category BUSINESS_ENTITY PER_ASSESSMENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_participant
 (p_validate                     in     boolean  	default false,
  p_effective_date               in     date,
  p_business_group_id            in 	number,
  p_questionnaire_template_id    in number default null,
  p_participation_in_table       in 	varchar2,
  p_participation_in_column      in 	varchar2,
  p_participation_in_id          in 	number,
  p_participation_status         in     varchar2         default 'OPEN',
  p_participation_type           in     varchar2         default null,
  p_last_notified_date           in     date             default null,
  p_date_completed               in 	date             default null,
  p_comments                     in 	varchar2         default null,
  p_person_id                    in 	number,
  p_attribute_category           in 	varchar2         default null,
  p_attribute1                   in 	varchar2         default null,
  p_attribute2                   in 	varchar2         default null,
  p_attribute3                   in 	varchar2         default null,
  p_attribute4                   in 	varchar2         default null,
  p_attribute5                   in 	varchar2         default null,
  p_attribute6                   in 	varchar2         default null,
  p_attribute7                   in 	varchar2         default null,
  p_attribute8                   in 	varchar2         default null,
  p_attribute9                   in 	varchar2         default null,
  p_attribute10                  in 	varchar2         default null,
  p_attribute11                  in 	varchar2         default null,
  p_attribute12                  in 	varchar2         default null,
  p_attribute13                  in 	varchar2         default null,
  p_attribute14                  in 	varchar2         default null,
  p_attribute15                  in 	varchar2         default null,
  p_attribute16                  in 	varchar2         default null,
  p_attribute17                  in 	varchar2         default null,
  p_attribute18                  in 	varchar2         default null,
  p_attribute19                  in 	varchar2         default null,
  p_attribute20                  in 	varchar2         default null,
  p_participant_usage_status	   in 	varchar2		     default null,
  p_participant_id               out nocopy    number,
  p_object_version_number        out nocopy 	number
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_participant >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the participant as identified by the in parameter
 * p_participant_id and the in out parameter p_object_version_number.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The participant must exist as of effective date.
 *
 * <p><b>Post Success</b><br>
 * The participant record will be successfully updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * The participant will not be updated and an error will be raised.
 * @param p_participant_id {@rep:casecolumn PER_PARTICIPANTS.PARTICIPANT_ID}
 * @param p_object_version_number Pass in the current version number of the
 * participant to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated participant. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_questionnaire_template_id {@rep:casecolumn
 * HR_QUESTIONNAIRES.QUESTIONNAIRE_TEMPLATE_ID}
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @param p_participation_status Participant's Status. Valid values are defined
 * by 'PARTICIPATION_ACCESS' lookup type.
 * @param p_participation_type Participant's Type. Valid values are defined by
 * 'PARTICIPATION_TYPE' lookup type.
 * @param p_last_notified_date Date last notified.
 * @param p_date_completed Date last participation completed.
 * @param p_comments Comment text.
 * @param p_person_id Obsolete parameter, do not use.
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
 * @param p_participant_usage_status Used to track the offline status of the
 * Participant's appraisal. Valid values are defined by
 * 'APPRAISAL_OFFLINE_STATUS' lookup type.
 * @rep:displayname Update Participant
 * @rep:category BUSINESS_ENTITY PER_APPRAISAL
 * @rep:category BUSINESS_ENTITY PER_ASSESSMENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_participant
 (p_validate                     in boolean         default false,
  p_effective_date               in date,
  p_participant_id               in number,
  p_object_version_number        in out nocopy number,
  p_questionnaire_template_id    in number           default hr_api.g_number,
  p_participation_status         in varchar2         default hr_api.g_varchar2,
  p_participation_type           in varchar2         default hr_api.g_varchar2,
  p_last_notified_date           in date             default hr_api.g_date,
  p_date_completed               in date             default hr_api.g_date,
  p_comments                     in varchar2         default hr_api.g_varchar2,
  p_person_id                    in number           default hr_api.g_number,
  p_attribute_category           in varchar2         default hr_api.g_varchar2,
  p_attribute1                   in varchar2         default hr_api.g_varchar2,
  p_attribute2                   in varchar2         default hr_api.g_varchar2,
  p_attribute3                   in varchar2         default hr_api.g_varchar2,
  p_attribute4                   in varchar2         default hr_api.g_varchar2,
  p_attribute5                   in varchar2         default hr_api.g_varchar2,
  p_attribute6                   in varchar2         default hr_api.g_varchar2,
  p_attribute7                   in varchar2         default hr_api.g_varchar2,
  p_attribute8                   in varchar2         default hr_api.g_varchar2,
  p_attribute9                   in varchar2         default hr_api.g_varchar2,
  p_attribute10                  in varchar2         default hr_api.g_varchar2,
  p_attribute11                  in varchar2         default hr_api.g_varchar2,
  p_attribute12                  in varchar2         default hr_api.g_varchar2,
  p_attribute13                  in varchar2         default hr_api.g_varchar2,
  p_attribute14                  in varchar2         default hr_api.g_varchar2,
  p_attribute15                  in varchar2         default hr_api.g_varchar2,
  p_attribute16                  in varchar2         default hr_api.g_varchar2,
  p_attribute17                  in varchar2         default hr_api.g_varchar2,
  p_attribute18                  in varchar2         default hr_api.g_varchar2,
  p_attribute19                  in varchar2         default hr_api.g_varchar2,
  p_attribute20                  in varchar2         default hr_api.g_varchar2,
  p_participant_usage_status	 in varchar2		 default hr_api.g_varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_participant >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes the participant as identified by the in parameter
 * p_participant_id.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The participant must exist.
 *
 * <p><b>Post Success</b><br>
 * The participant record will be successfully deleted from the database.
 *
 * <p><b>Post Failure</b><br>
 * The participant will not be deleted and an error will be raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_participant_id {@rep:casecolumn PER_PARTICIPANTS.PARTICIPANT_ID}
 * @param p_object_version_number Current version number of the participant to
 * be deleted.
 * @rep:displayname Delete Participant
 * @rep:category BUSINESS_ENTITY PER_APPRAISAL
 * @rep:category BUSINESS_ENTITY PER_ASSESSMENT
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_participant
(p_validate                           in boolean default false,
 p_participant_id                     in number,
 p_object_version_number              in number
);
--
end hr_participants_api;

/
