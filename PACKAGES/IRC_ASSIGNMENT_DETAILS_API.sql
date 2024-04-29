--------------------------------------------------------
--  DDL for Package IRC_ASSIGNMENT_DETAILS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_ASSIGNMENT_DETAILS_API" AUTHID CURRENT_USER as
/* $Header: iriadapi.pkh 120.5.12010000.3 2010/05/18 14:44:03 vmummidi ship $ */
/*#
 * This package contains assignment details APIs.
 * @rep:scope public
 * @rep:product irc
 * @rep:displayname Assignment Detail
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_assignment_details >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates additional assignment detail values.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Irecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The assignment must exist on the effective date.
 *
 * <p><b>Post Success</b><br>
 * The assignment details will be successfully inserted into the database.
 *
 * <p><b>Post Failure</b><br>
 * The assignment details will not be created and an error will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_assignment_id Identifies the assignment record, whose details
 * are being created.
 * @param p_attempt_id Identifies the application assignment assessment
 * attempt.
 * @param p_qualified Identifies if the applicant is qualified.
 * @param p_considered Identifies if the applicant is considered.
 * @param p_assignment_details_id If p_validate is false, then this uniquely
 * identifies the assignment detail created. If p_validate is true, then set
 * to null.
 * @param p_details_version If p_validate is false, then this identifies the
 * version of the assignment detail with in the same effective date range.
 * If p_validate is true, then set to null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created assignment detail. If
 * p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created assignment detail. If p_validate is true,
 * then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created assignment detail. If p_validate is true,
 * then the value will be null.
 * @rep:displayname Create Assignment Detail
 * @rep:category BUSINESS_ENTITY PER_APPLICANT_ASG
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_assignment_details
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_assignment_id                 in     number
  ,p_attempt_id                    in     number   default null
  ,p_qualified                     in     varchar2 default null
  ,p_considered                    in     varchar2 default null
  ,p_assignment_details_id            out nocopy   number
  ,p_details_version                  out nocopy   number
  ,p_effective_start_date             out nocopy   date
  ,p_effective_end_date               out nocopy   date
  ,p_object_version_number            out nocopy   number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_assignment_details >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates additional assignment detail values.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Irecruitment.
 *
 * <p><b>Prerequisites</b><br>
 * The assignment and assignment detail must exist on the effective date.
 *
 * <p><b>Post Success</b><br>
 * The assignment details will have been updated.
 *
 * <p><b>Post Failure</b><br>
 * The assignment details will not be updated and an error will be raised.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_datetrack_update_mode Indicates which DateTrack mode to use when
 * updating the record. You must set to either UPDATE, CORRECTION,
 * UPDATE_OVERRIDE or UPDATE_CHANGE_INSERT. Modes available for use with a
 * particular record depend on the dates of previous record changes and the
 * effective date of this change.
 * @param p_assignment_id Identifies the assignment record, whose details
 * are being updated.
 * @param p_attempt_id Identifies the application assignment assessment
 * attempt.
 * @param p_qualified Identifies if the applicant is qualified.
 * @param p_considered Identifies if the applicant is considered.
 * @param p_assignment_details_id Pass in the id of the assignment detail that
 * will be updated. When the API completes if p_validate is false then will be
 * set to the new assignment detail id. If p_validate is true then will be set
 * to the passed value.
 * @param p_object_version_number Pass in the current version number of the
 * assignment detail to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated assignment
 * detail. If p_validate is true will be set to the same value which was
 * passed in.
 * @param p_details_version If p_validate is false, then this identifies the
 * version of the assignment detail with in the same effective date range.
 * If p_validate is true, then set to null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated assignment detail row which now
 * exists as of the effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated assignment detail row which now exists
 * as of the effective date. If p_validate is true, then set to null.
 * @rep:displayname Update Assignment Detail
 * @rep:category BUSINESS_ENTITY PER_APPLICANT_ASG
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_assignment_details
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_datetrack_update_mode         in     varchar2
  ,p_assignment_id                 in     number   default hr_api.g_number
  ,p_attempt_id                    in     number   default hr_api.g_number
  ,p_qualified                     in     varchar2 default hr_api.g_varchar2
  ,p_considered                    in     varchar2 default hr_api.g_varchar2
  ,p_assignment_details_id         in out nocopy   number
  ,p_object_version_number         in out nocopy   number
  ,p_details_version                  out nocopy   number
  ,p_effective_start_date             out nocopy   date
  ,p_effective_end_date               out nocopy   date
  );
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< copy_assignment_details >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- {End Of Comments}
--
procedure copy_assignment_details
  (p_source_assignment_id in number
  ,p_target_assignment_id in number
  );
--
--
end irc_assignment_details_api;

/
