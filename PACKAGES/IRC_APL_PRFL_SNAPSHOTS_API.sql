--------------------------------------------------------
--  DDL for Package IRC_APL_PRFL_SNAPSHOTS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_APL_PRFL_SNAPSHOTS_API" AUTHID CURRENT_USER as
/* $Header: irapsapi.pkh 120.1 2008/02/21 13:57:08 viviswan noship $ */
/*#
 * This package contains APIs for maintaining Applicant Profile Snapshots
 * @rep:scope public
 * @rep:product irc
 * @rep:displayname Applicant Profile Snapshots
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_applicant_snapshot >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new Applicant Profile Snapshot.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * Snapshot of Applicant Profile  is created only for BGs that have Applicant
 * Tracking enabled.
 *
 * <p><b>Post Success</b><br>
 * Snapshot of Applicant Profile is successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the Applicant Snapshot and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Effective date for the creation of Applicant
 * Snapshot.
 * @param p_person_id Person id of the Applicant.
 * @param p_profile_snapshot_id If p_validate is false, then this uniquely
 * identifies the Snapshot created. If p_validate is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created applicant snapshot. If p_validate is true,
 * then the value will be null.
 * @rep:displayname Create Applicant Snapshot
 * @rep:category BUSINESS_ENTITY IRC_RECRUITMENT_CANDIDATE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_applicant_snapshot
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_person_id                     in     number
  ,p_profile_snapshot_id           out    nocopy   number
  ,p_object_version_number         out    nocopy   number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_applicant_snapshot >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates an existing Applicant Snapshot.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * Snapshot of Applicant Profile should exist.
 *
 * <p><b>Post Success</b><br>
 * Successfully updates the Applicant Profile Snapshot.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the Applicant Profile Snapshot and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Effective date for the creation of Applicant
 * Snapshot.
 * @param p_person_id Person id of the Applicant.
 * @param p_profile_snapshot_id If p_validate is false, then this uniquely
 * identifies the Snapshot created. If p_validate is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created applicant snapshot. If p_validate is true,
 * then the value will be null.
 * @rep:displayname Update Applicant Snapshot
 * @rep:category BUSINESS_ENTITY IRC_RECRUITMENT_CANDIDATE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_applicant_snapshot
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_person_id                     in     number
  ,p_profile_snapshot_id           in out nocopy   number
  ,p_object_version_number         in out nocopy   number
  );
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_applicant_snapshot >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a new Applicant Profile Snapshot.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with iRecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * Snapshot of Applicant Profile  is created only for BGs that have Applicant
 * Tracking enabled.
 *
 * <p><b>Post Success</b><br>
 * Snapshot of Applicant Profile is successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the Applicant Snapshot and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Effective date for the creation of Applicant
 * Snapshot.
 * @param p_person_id Person id of the Applicant.
 * @param p_profile_snapshot_id If p_validate is false, then this uniquely
 * identifies the Snapshot created. If p_validate is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created applicant snapshot. If p_validate is true,
 * then the value will be null.
 * @rep:displayname Create Applicant Snapshot
 * @rep:category BUSINESS_ENTITY IRC_RECRUITMENT_CANDIDATE
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure delete_applicant_snapshot
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_person_id                     in     number
  ,p_profile_snapshot_id           in     number
  ,p_object_version_number         in     number
  );
--
end irc_apl_prfl_snapshots_api;

/
