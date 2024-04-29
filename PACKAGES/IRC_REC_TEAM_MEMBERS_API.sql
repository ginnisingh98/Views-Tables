--------------------------------------------------------
--  DDL for Package IRC_REC_TEAM_MEMBERS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_REC_TEAM_MEMBERS_API" AUTHID CURRENT_USER as
/* $Header: irrtmapi.pkh 120.3.12010000.3 2008/11/17 11:00:56 avarri ship $ */
/*#
 * This package contains APIs for recruiting team members.
 * @rep:scope public
 * @rep:product irc
 * @rep:displayname Recruiting Team Member
*/
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_rec_team_member >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API adds a member to the recruiting team for a vacancy.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The vacancy and the person must already exist
 *
 * <p><b>Post Success</b><br>
 * The person is added to the recruiting team for the vacancy
 *
 * <p><b>Post Failure</b><br>
 * The person will not be added to the recruiting team and an error will be
 * raised
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_person_id Identifies the person for whom you create the recruiting
 * team record.
 * @param p_vacancy_id Identifies the vacancy for the recruiting team member
 * @param p_job_id Reserved for future use
 * @param p_start_date Reserved for future use
 * @param p_end_date Reserved for future use
 * @param p_update_allowed Specifies whether the person can update the vacancy
 * (Y or N)
 * @param p_delete_allowed Specifies whether the person can delete the vacancy
 * (Y or N)
 * @param p_rec_team_member_id If p_validate is false, then this uniquely
 * identifies the recruiting team member created. If p_validate is true, then
 * set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created recruiting team member. If p_validate is true,
 * then the value will be null.
 * @param p_interview_security This determines the interviews to which the
 * recruiting team member has access.
 * @rep:displayname Create Recruiting Team Member
 * @rep:category BUSINESS_ENTITY IRC_RECRUITING_TEAM
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_rec_team_member
  (p_validate                      in     boolean  default false
  ,p_person_id                     in     number
  ,p_vacancy_id                    in     number
  ,p_job_id                        in     number   default null
  ,p_start_date                    in     date     default null
  ,p_end_date                      in     date     default null
  ,p_update_allowed                in     varchar2 default 'Y'
  ,p_delete_allowed                in     varchar2 default 'Y'
  ,p_rec_team_member_id            out nocopy number
  ,p_object_version_number         out nocopy    number
  ,p_interview_security             in     varchar2 default 'SELF'
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_rec_team_member >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the details of a recruiting team member.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The recruiting team member must exist already
 *
 * <p><b>Post Success</b><br>
 * The recruiting team member will be updated in the database
 *
 * <p><b>Post Failure</b><br>
 * The recruiting team member will not be updated in the database and an error
 * will be raised
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_rec_team_member_id Identifies the recruiting team member
 * @param p_person_id Identifies the person for whom you update the recruiting
 * team record.
 * @param p_vacancy_id Identifies the vacancy for the recruiting team member
 * @param p_party_id Obsolete parameter. Do not use
 * @param p_object_version_number Pass in the current version number of the
 * recruiting team entry to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated recruiting team
 * entry. If p_validate is true will be set to the same value which was passed
 * in.
 * @param p_job_id Reserved for future use
 * @param p_start_date Reserved for future use
 * @param p_end_date Reserved for future use
 * @param p_update_allowed Specifies whether the person can update the vacancy
 * (Y or N)
 * @param p_delete_allowed Specifies whether the person can delete the vacancy
 * (Y or N)
 * @param p_interview_security This determines the interviews to which the
 * recruiting team member has access.
 * @rep:displayname Update Recruiting Team Member
 * @rep:category BUSINESS_ENTITY IRC_RECRUITING_TEAM
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_rec_team_member
  (p_validate                      in     boolean  default false
  ,p_rec_team_member_id            in     number
  ,p_person_id                     in     number   default hr_api.g_number
  ,p_vacancy_id                    in     number   default hr_api.g_number
  ,p_party_id                      in     number   default hr_api.g_number
  ,p_object_version_number         in out nocopy number
  ,p_job_id                        in     number   default hr_api.g_number
  ,p_start_date                    in     date     default hr_api.g_date
  ,p_end_date                      in     date     default hr_api.g_date
  ,p_update_allowed                in     varchar2 default hr_api.g_varchar2
  ,p_delete_allowed                in     varchar2 default hr_api.g_varchar2
  ,p_interview_security             in     varchar2 default 'SELF'
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_rec_team_member >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API removes a member of a recruiting team.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The recruiting team member must exist already
 *
 * <p><b>Post Success</b><br>
 * The recruiting team member will be removed from the database
 *
 * <p><b>Post Failure</b><br>
 * The recruiting team member will not be removed from the database and an
 * error will be raised
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_rec_team_member_id Identifies the recruiting team member
 * @param p_object_version_number Current version number of the recruiting team
 * entry to be deleted.
 * @rep:displayname Delete Recruiting Team Member
 * @rep:category BUSINESS_ENTITY IRC_RECRUITING_TEAM
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_rec_team_member
  (p_validate                      in     boolean  default false
  ,p_rec_team_member_id            in     number
  ,p_object_version_number         in     number
  );
--
end IRC_REC_TEAM_MEMBERS_API;

/
