--------------------------------------------------------
--  DDL for Package IRC_VACANCY_CONSIDERATIONS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_VACANCY_CONSIDERATIONS_API" AUTHID CURRENT_USER as
/* $Header: irivcapi.pkh 120.2.12010000.1 2008/07/28 12:46:49 appldev ship $ */
/*#
 * This package contains APIs for marking the consideration status of a
 * candidate for a vacancy.
 * @rep:scope public
 * @rep:product irc
 * @rep:displayname Vacancy Consideration
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_vacancy_consideration >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a consideration status for a candidate for a vacancy.
 *
 * If the consideration status is PURSUE then a notification will be sent to
 * the candidate to ask them to apply for the vacancy. If the consideration
 * status is REJECT then the candidate will not show up in searches for
 * candidates for this vacancy. If the status is CONSIDER then no further
 * action is taken.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The vacancy and the candidate must exist in the database
 *
 * <p><b>Post Success</b><br>
 * The vacancy consideration status is recorded in the database, and a
 * notification may be sent to the candidate
 *
 * <p><b>Post Failure</b><br>
 * The vacancy consideration status will not be stored and an error will be
 * raised
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_person_id Identifies the person for whom you create the
 * consideration status record.
 * @param p_vacancy_id Identifies the vacancy that the candidate is being
 * considered for
 * @param p_consideration_status Indicates the consideration status (PURSUE,
 * CONSIDER or NO)
 * @param p_vacancy_consideration_id If p_validate is false, then this uniquely
 * identifies the consideration status recorded. If p_validate is true, then
 * set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created consideration status. If p_validate is true,
 * then the value will be null.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @rep:displayname Create Vacancy Consideration
 * @rep:category BUSINESS_ENTITY IRC_VACANCY_CONSIDERATION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_vacancy_consideration
  (p_validate                      in     boolean  default false
  ,p_person_id                     in     number
  ,p_vacancy_id                    in     number
  ,p_consideration_status          in     varchar2 default 'CONSIDER'
  ,p_vacancy_consideration_id      out nocopy     number
  ,p_object_version_number         out nocopy    number
  ,p_effective_date                in     date
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_vacancy_consideration >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a consideration status for a candidate for a vacancy.
 *
 * If the consideration status is PURSUE then a notification will be sent to
 * the candidate to ask them to apply for the vacancy. If the consideration
 * status is NO then the candidate will not show up in searches for candidates
 * for this vacancy. If the status is CONSIDER then no further action is taken.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The vacancy consideration must already exist
 *
 * <p><b>Post Success</b><br>
 * The vacancy consideration record is updated
 *
 * <p><b>Post Failure</b><br>
 * The vacancy consideration record will not be updated and an error will be
 * raised
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_vacancy_consideration_id Identifies the vacancy consideration
 * record to be updated
 * @param p_party_id Obsolete parameter. Do not use
 * @param p_consideration_status Indicates the consideration status (PURSUE,
 * CONSIDER or NO)
 * @param p_object_version_number Pass in the current version number of the
 * consideration status to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated consideration
 * status. If p_validate is true will be set to the same value which was passed
 * in.
 * @param p_effective_date Reference date for validating lookup values are
 * applicable during the start to end active date range. This date does not
 * determine when the changes take effect.
 * @rep:displayname Update Vacancy Consideration
 * @rep:category BUSINESS_ENTITY IRC_VACANCY_CONSIDERATION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_vacancy_consideration
  (p_validate                      in     boolean  default false
  ,p_vacancy_consideration_id      in     number
  ,p_party_id                      in     number   default hr_api.g_number
  ,p_consideration_status          in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy number
  ,p_effective_date                in     date
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_vacancy_consideration >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API removes a vacancy consideration status.
 *
 * If a notification has been sent to the candidate, it will not be unsent.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The vacancy consideration must already exist
 *
 * <p><b>Post Success</b><br>
 * The vacancy consideration record is deleted
 *
 * <p><b>Post Failure</b><br>
 * The vacancy consideration record will not be deleted and an error will be
 * raised
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_vacancy_consideration_id Identifies the vacancy consideration
 * record to be deleted
 * @param p_object_version_number Current version number of the consideration
 * status to be deleted.
 * @rep:displayname Delete Vacancy Consideration
 * @rep:category BUSINESS_ENTITY IRC_VACANCY_CONSIDERATION
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_vacancy_consideration
  (p_validate                      in     boolean  default false
  ,p_vacancy_consideration_id      in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< NOTIFY_SEEKER_IF_REQUIRED >-------------------|
-- ----------------------------------------------------------------------------
-- Comment
--   This procedure will send an email to a job seeker under certain
--   circumstances.
--
-- Access Status:
--   Private
--
-- {End Of Comments}
--
procedure notify_seeker_if_required
  (
   p_person_id                     in     number
  ,p_vacancy_id                    in     number
  ,p_consideration_status          in     varchar2
  ,p_effective_date                in     date
  ,p_validate_only                 in     boolean);
 end IRC_VACANCY_CONSIDERATIONS_API;

/
