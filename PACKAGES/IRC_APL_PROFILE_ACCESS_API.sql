--------------------------------------------------------
--  DDL for Package IRC_APL_PROFILE_ACCESS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_APL_PROFILE_ACCESS_API" AUTHID CURRENT_USER as
/* $Header: irapaapi.pkh 120.1 2008/02/21 13:38:56 viviswan noship $ */
/*#
 * This package contains APIs for maintaining  Applicant Profile Access
 * @rep:scope public
 * @rep:product irc
 * @rep:displayname Create Applicant Profile Access
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_apl_profile_access >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new   Applicant Profile Access.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * applicant profile access  is created only for BGs that have Applicant
 * Tracking enabled.
 *
 * <p><b>Post Success</b><br>
 * Applicant profile access is successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the Applicant Profile Access and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.

 * @param p_person_id Person id of the Person.
 * @param p_apl_profile_access_id If p_validate is false, then this uniquely
 * identifies the Applicant Profile Access created. If p_validate is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created applicant profile access. If p_validate is true,
 * then the value will be null.
 * @rep:displayname Save Applicant Profile Access
 * @rep:category BUSINESS_ENTITY IRC_RECRUITMENT_CANDIDATE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_apl_profile_access
  (p_validate				in     boolean  default false
  ,p_person_id				in     number
  ,p_apl_profile_access_id              in out nocopy number
  ,p_object_version_number		out    nocopy   number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_apl_profile_access >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an existing Saved Applicant Profile Access.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * Saved Applicant Profile Access should exist.
 *
 * <p><b>Post Success</b><br>
 * Successfully updates the Saved Applicant Profile Access.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the Saved Applicant Profile Access and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_person_id Person id of the Person.
 * @param p_apl_profile_access_id If p_validate is false, then this uniquely
 * identifies the Applicant Profile Access is saved. If p_validate is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the saved applicant profile access. If p_validate is true,
 * then the value will be null.
 * @rep:displayname Update Saved Applicant Profile Access
 * @rep:category BUSINESS_ENTITY IRC_RECRUITMENT_CANDIDATE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_apl_profile_access
  (p_validate				in     boolean  default false
  ,p_person_id				in     number
  ,p_apl_profile_access_id           in out nocopy   number
  ,p_object_version_number		in out nocopy   number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< delete_apl_profile_access >----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes an existing Saved Applicant Profile Access.
 *
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * Saved Applicant Profile Access should exist.
 *
 * <p><b>Post Success</b><br>
 * Successfully deletes the Saved Applicant Profile Access.
 *
 * <p><b>Post Failure</b><br>
 * The API does not delete the Saved Applicant Profile Access and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_person_id Person id of the Person.
 * @param p_apl_profile_access_id If p_validate is false, then this uniquely
 * identifies the Applicant Profile Access is saved. If p_validate is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the saved applicant profile access. If p_validate is true,
 * then the value will be null.
 * @rep:displayname Update Saved Applicant Profile Access
 * @rep:category BUSINESS_ENTITY IRC_RECRUITMENT_CANDIDATE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
 */
--
-- {End Of Comments}
--
procedure delete_apl_profile_access
  (p_validate				in     boolean  default false
   ,p_person_id			in     number
   ,p_apl_profile_access_id          in   number
   ,p_object_version_number		in number
  );
end irc_apl_profile_access_api;

/
