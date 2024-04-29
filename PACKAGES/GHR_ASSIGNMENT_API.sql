--------------------------------------------------------
--  DDL for Package GHR_ASSIGNMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_ASSIGNMENT_API" AUTHID CURRENT_USER as
/* $Header: ghasgapi.pkh 120.2 2006/01/27 12:36:25 vravikan noship $ */
/*#
 * This package contains the Assignment API.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Assignment
*/
--
-- ----------------------------------------------------------------------------
-- |------------------------------< accept_apl_asg >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API changes an existing Applicant Assignment status to Accepted.
 *
 * This API changes an existing Applicant Assignment status to Accepted in
 * PER_ASSIGNMENTS_F table.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The assignment (p_assignment_id) must exist on the effective date that the
 * status changes, and the status (p_assignment_status_type_id) must exist with
 * an ACCEPTED system status.
 *
 * <p><b>Post Success</b><br>
 * The API changes the Applicant Assignment to ACCEPTED
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the Applicant Assignment status and raises an error.
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
 * @param p_assignment_id {@rep:casecolumn PER_ALL_ASSIGNMENTS_F.ASSIGNMENT_ID}
 * @param p_object_version_number Pass in the current version number of the
 * Applicant assignment to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated Applicant
 * assignment. If p_validate is true will be set to the same value which was
 * passed in.
 * @param p_assignment_status_type_id {@rep:casecolumn
 * PER_ALL_ASSIGNMENTS_F.ASSIGNMENT_STATUS_TYPE_ID}
 * @param p_change_reason Reason the Assignment last changed.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated Applicant Assignment row which now
 * exists as of the effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date in the updated Applicant Assignment row as of the
 * effective date. If p_validate is true, then set to null.
 * @rep:displayname Accept Applicant Assignment
 * @rep:category BUSINESS_ENTITY PER_APPLICANT_ASG
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
 procedure accept_apl_asg
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_assignment_status_type_id    in     number   default hr_api.g_number
  ,p_change_reason                in     varchar2 default hr_api.g_varchar2
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  );
--
end ghr_assignment_api;

 

/
