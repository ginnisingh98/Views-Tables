--------------------------------------------------------
--  DDL for Package HR_ASSIGNMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ASSIGNMENT_API" AUTHID CURRENT_USER as
/* $Header: peasgapi.pkh 120.11.12010000.4 2009/07/28 10:08:56 ghshanka ship $ */
/*#
 * This package contains APIs for maintaining employee, applicant and
 * contingent worker assignment details.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Assignment
*/
--
-- -----------------------------------------------------------------------------
-- |--------------------------< last_apl_asg >---------------------------------|
-- -----------------------------------------------------------------------------
--
-- {Start of Comments}
--
-- Description:
--   Determines if the assignment is the last applicant assignment on a given
--   date
--
-- Prerequisites:
--   None
--
-- In Parameters
--   Name                           Reqd Type     Description
--   p_assignment_id                Yes  number   Assignment id
--   p_effective_date               Yes  date     Effective date
--
-- Post Success:
--   A boolean indicator signifying if the assignment is the last applicant
--   assignment on the effective date is returned.
--
-- Post Failure:
--   An error is raised
--
-- Access Status:
--   Internal Development Use Only
--
-- {End of Comments}
--
FUNCTION last_apl_asg
  (p_assignment_id                IN     per_all_assignments_f.assignment_id%TYPE
  ,p_effective_date               IN     DATE
  )
RETURN BOOLEAN;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< activate_emp_asg >----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the status of an employee assignment to an Active status.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The assignment must be an employee assignment. The assignment must exist as
 * of the effective date of the change
 *
 * <p><b>Post Success</b><br>
 * The employee assignment will be set to an active status
 *
 * <p><b>Post Failure</b><br>
 * The status of the employee assignment will not be changed and an error will
 * be raised
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
 * @param p_assignment_id Identifies the assignment record to be modified.
 * @param p_change_reason Reason for the assignment status change. If there is
 * no change reason the parameter can be null. Valid values are defined in the
 * EMP_ASSIGN_REASON lookup type.
 * @param p_object_version_number Pass in the current version number of the
 * assignment to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated assignment. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_assignment_status_type_id The new assignment status must have a
 * system assignment status of ACTIVE_ASSIGN. If the assignment status is
 * already a type of ACTIVE_ASSIGN, this API can be used to set a different
 * active status. If no value is supplied, this API uses the default
 * ACTIVE_ASSIGN status for the business group in which this assignment exists.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated assignment row which now exists as of
 * the effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated assignment row which now exists as of the
 * effective date. If p_validate is true, then set to null.
 * @rep:displayname Activate Employee Assignment
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE_ASG
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure activate_emp_asg
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_change_reason                in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_assignment_status_type_id    in     number   default hr_api.g_number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< activate_cwk_asg >----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the status of a contingent worker assignment to an Active
 * status.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The assignment must be an contingent worker assignment. The assignment must
 * exist as of the effective date of the change
 *
 * <p><b>Post Success</b><br>
 * The contingent worker assignment will be set to an active status
 *
 * <p><b>Post Failure</b><br>
 * The status of the contingent worker assignment will not be changed and an
 * error will be raised
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
 * @param p_assignment_id Identifies the assignment record to be modified.
 * @param p_change_reason Reason for the assignment status change. If there is
 * no change reason the parameter can be null. Valid values are defined in the
 * CWK_ASSIGN_REASON lookup_type.
 * @param p_object_version_number Pass in the current version number of the
 * assignment to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated assignment. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_assignment_status_type_id The new assignment status must have a
 * system assignment status of ACTIVE_CWK. If the assignment status is already
 * a type of ACTIVE_CWK, this API can be used to set a different active status.
 * If no value is supplied, this API uses the default ACTIVE_CWK status for the
 * business group in which this assignment exists.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated assignment row which now exists as of
 * the effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated assignment row which now exists as of the
 * effective date. If p_validate is true, then set to null.
 * @rep:displayname Activate Contingent Worker assignment
 * @rep:category BUSINESS_ENTITY PER_CWK_ASG
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure activate_cwk_asg
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_change_reason                in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_assignment_status_type_id    in     number   default hr_api.g_number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------< actual_termination_emp_asg >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates the status of an employee assignment to a Termination
 * status.
 *
 * This API covers the first step in terminating an employee assignment. When
 * an employee has more than one assignment, this API will terminate any
 * secondary assignment, but cannot terminate the primary assignment. The
 * second step of the termination process should be performed using the API
 * final_process_emp_asg. actual_termination_emp_asg is used to set the actual
 * termination date and to change the assignment status to a type of
 * TERM_ASSIGN. If you want to change the actual termination date after it has
 * been entered, you must cancel the termination and then re-apply the
 * termination as of the new date.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The assignment must be a secondary employee assignment, and must exist on
 * the effective date.
 *
 * <p><b>Post Success</b><br>
 * The API updates the assignment status. Using this API may have an effect on
 * element entries. Element entries for the assignment that have an element
 * termination rule of 'Actual Termination' are ended as of the actual
 * termination date. Element entries for the assignment that have an element
 * termination rule of 'Final Close' are not affected by this API. These
 * entries are updated by the final_process_emp_asg API. In non-US
 * legislations, element entries for the assignment that have an element
 * termination rule of 'Last Standard Process' are ended. (In a US legislation,
 * the element termination rule of 'Last Standard Process' is not used.) The
 * date used depends on the payroll component of the employee's assignment.
 * When the assignment does not include a payroll, the entries are ended as of
 * the actual termination date. When the assignment includes a payroll, the
 * entries are ended as of the end date of the payroll period in which the
 * actual termination date occurs.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the assignment or element entries and raises an
 * error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_assignment_id Identifies the assignment record to be modified.
 * @param p_object_version_number Pass in the current version number of the
 * assignment to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated assignment. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_actual_termination_date Actual termination date
 * @param p_assignment_status_type_id The new assignment status must have a
 * system assignment status of TERM_ASSIGN. If no value is supplied, this API
 * uses the default TERM_ASSIGN status for the business group in which this
 * assignment exists.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated assignment row which now exists as of
 * the effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated assignment row which now exists as of the
 * effective date. If p_validate is true, then set to null.
 * @param p_asg_future_changes_warning Set to true if at least one assignment
 * change, after the actual termination date, has been overwritten with the new
 * assignment status. Set to false when there were no changes in the future.
 * @param p_entries_changed_warning This is set to 'Y', if at least one element
 * entry was altered due to the assignment change. It is set to 'S', if at
 * least one salary element entry was affected (This is a more specific case
 * than 'Y').
 * Otherwise set to 'N', if no element entries were changed.
 * @param p_pay_proposal_warning Set to true if any salary proposal existing
 * after the actual termination date has been deleted. Set to false when there
 * are no salary proposals after actual termination date.
 * @rep:displayname Actual Termination Employee Assignment
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE_ASG
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure actual_termination_emp_asg
  (p_validate                      in     boolean  default false
  ,p_assignment_id                 in     number
  ,p_object_version_number         in out nocopy number
  ,p_actual_termination_date       in     date
  ,p_assignment_status_type_id     in     number   default hr_api.g_number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ,p_asg_future_changes_warning       out nocopy boolean
  ,p_entries_changed_warning          out nocopy varchar2
  ,p_pay_proposal_warning             out nocopy boolean
  );
  --
-- ----------------------------------------------------------------------------
-- |----------------------< actual_termination_cwk_asg >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API covers the first step in terminating a placement
--   assignment.  When a placement has more than one assignment, you can
--   use this API to terminate any assignment except the primary assignment.
--
--   Note:  If the placement has only one assignment, or if you want to
--          terminate all current assignments, you should use the
--          hr_cwk_api.terminate_placement API.
--          Also, you cannot use this API to update an applicant or
--          employee assignment status.
--
--   The termination process has two distinct steps, using two
--   APIs.  Use the actual_termination_cwk_asg API to set the actual
--   termination date and to change the assignment status to a type of
--   TERM_CWK_ASSIGN.  Then use the final_process_cwk_asg API to date
--   effectively delete the assignment with effect from the final process
--   date.
--
--   The new assignment status must have a corresponding system status of
--   TERM_CWK_ASSIGN. If a status is not passed into the API, the default
--   TERM_CWK_ASSIGN status for the assignment's business group is used. The
--   new status takes affect on the day after the actual termination date.
--
--   If you want to change the actual termination date after it has been
--   entered, you must cancel the termination and then re-apply the termination
--   as of the new date.
--
--   Element entries for the assignment that have an element
--   termination rule of 'Actual Termination' are date effectively
--   deleted as of the actual termination date.
--
--   Element entries for the assignment that have an element
--   termination rule of 'Final Close' are not affected by this API.
--   These entries are updated by the 'final_process_cwk_asg' API.
--
--   In a US legislation, the element termination rule of 'Last Standard
--   Process' is not used.
--
--   In non-US legislations, element entries for the
--   assignment that have an element termination rule of 'Last Standard
--   Process' are date effectively deleted. The date used depends on
--   the payroll component of the contingent worker assignment.
--         When the assignment does not include a payroll, the entries are
--         deleted as of the actual termination date.
--         When the assignment includes a payroll, the entries are deleted
--         as of the end date of the payroll period in which the actual
--         termination date occurs.
--
-- Prerequisites:
--   The assignment record, identified by p_assignment_id and
--   p_object_version_number, must exist as a secondary contingent worker
--   assignment.
--   The assignment status type, identified by p_assignment_status_type_id,
--   must exist for the same business group as the assignment, must be active,
--   and must have a system status of TERM_CWK_ASSIGN.  If no assignment status
--   is specified, the API uses the default user status for TERM_CWK_ASSIGN.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     No   boolean  If true, the database
--                                                remains unchanged. If false
--                                                then the assignment and
--                                                element entries are
--                                                updated.
--   p_assignment_id                Yes  number   ID of the assignment
--   p_object_version_number        Yes  number   Version number of the
--                                                assignment record
--   p_actual_termination_date      Yes  date     Actual termination date
--   p_assignment_status_type_id    No   number   Assignment status type
--
-- Post Success:
--   The API updates the assignment, modifies the element entries, and sets
--   the following out parameters:
--
--   Name                           Type     Description
--   p_object_version_number        number   If p_validate is false, set to
--                                           the new version number of the
--                                           actual termination date
--                                           assignment record. If p_validate
--                                           is true, set to the same value
--                                           you passed in.
--   p_effective_start_date         date     If p_validate is false, set to
--                                           the effective start date of the
--                                           actual termination date assignment
--                                           record. If p_validate is true set
--                                           to null.
--   p_effective_end_date           date     If p_validate is false, set to
--                                           the effective end date of the
--                                           actual termination date assignment
--                                           record. If p_validate is true set
--                                           to null.
--   p_asg_future_changes_warning   boolean  Set to true if at least one
--                                           assignment change, after the
--                                           actual termination date, has been
--                                           overwritten with the new
--                                           assignment status. Set to
--                                           false when there were no changes
--                                           in the future.
--   p_entries_changed_warning      varchar2 Set to 'Y' if at least one
--                                           element entry was altered due to
--                                           the assignment change.
--                                           Set to 'S' if at least one salary
--                                           element entry was affected. (This
--                                           (is a more specific case than
--                                           'Y'.) Otherwise set to 'N', if
--                                           no element entries were changed.
--
--   p_pay_proposal_warning         boolean  Set to true if any salary proposal
--                                           existing after the
--                                           actual_termination_date has been
--                                           deleted. Set to false when there
--                                           are no salary proposals after actual_
--                                           termination_date.
-- Post Failure:
--   The API does not update the assignment or element entries and raises an
--   error.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure actual_termination_cwk_asg
  (p_validate                      in     boolean  default false
  ,p_assignment_id                 in     number
  ,p_object_version_number         in out nocopy number
  ,p_actual_termination_date       in     date
  ,p_assignment_status_type_id     in     number   default hr_api.g_number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ,p_asg_future_changes_warning       out nocopy boolean
  ,p_entries_changed_warning          out nocopy varchar2
  ,p_pay_proposal_warning             out nocopy boolean
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< final_process_cwk_asg >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API covers the second step in terminating an individual cwk
--   assignment.  You can use this API to terminate any assignment except
--   the primary assignment.
--
--   Note:  If the person has only one assignment, or if you want to
--          terminate all current assignments, you should use the
--          'terminate_placement' API.
--
--   The termination process has two distinct steps, using two APIs.
--   Use the actual_termination_cwk_asg API to set the actual termination
--   date and to change the assignment status to a type of TERM_CWK_ASSIGN.
--   Then use the final_process_cwk_asg API to date-effectively delete the
--   assignment with effect from the final process date.
--
--   Note: The cwk assignment must already have an actual termination
--         date.  The actual termination date is not held on the assignment
--         record.  It is derived from the date when the assignment status
--         first changes to a TERM_CWK_ASSIGN system status.
--
--   Element entries for the assignment that have an element
--   termination rule of 'Final Close' are date effectively deleted as
--   of the final process date.
--
--   Element entries for the assignment that have an element
--   termination rule of 'Last Standard Process' are date effectively
--   deleted as of the final process date, if the last standard process date
--   is later than the final process date.
--
--   Any cost allocations, grade step/point placements, cobra coverage benefits
--   and personal payment methods for this assignment are date effectively
--   deleted as of the final process date.
--
-- Prerequisites:
--   The assignment must be a secondary contingent worker assignment.
--   The assignment must already have an actual termination date.
--   The final process date cannot be earlier than the actual termination
--   date.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     No   boolean  If true, the database
--                                                remains unchanged. If false
--                                                then the assignment and
--                                                element entries are
--                                                changed.
--   p_assignment_id                Yes  number   ID of the assignment
--   p_object_version_number        Yes  number   Version number of the
--                                                assignment record
--   p_final_process_date           Yes  date     Final Process Date
--
-- Post Success:
--   The API date effectively deletes the assignment and element entries,
--   and sets the following out parameters:
--
--   Name                           Type     Description
--   p_object_version_number        number   If p_validate is false, set to
--                                           the new version number of the
--                                           modified assignment record. If
--                                           p_validate is true, set to the
--                                           same value you passed in.
--   p_effective_start_date         date     If p_validate is false, set to
--                                           the effective start date for
--                                           this assignment change. If
--                                           p_validate is true set to null.
--   p_effective_end_date           date     If p_validate is false, set to
--                                           the effective end date for
--                                           this assignment change. If
--                                           p_validate is true set to null.
--   p_org_now_no_manager_warning   boolean  Set to true if this assignment
--                                           had the manager flag set to 'Y'
--                                           and there are no other managers
--                                           in the assignment's organization.
--                                           Set to false if there is another manager
--                                           in the assignment's organization
--                                           or if this assignment did not have
--                                           the manager flag set to 'Y'.
--                                           The warning value only applies as
--                                           of the final process date.
--   p_asg_future_changes_warning   boolean  Set to true if at least one
--                                           assignment change, after the final
--                                           process date, has been deleted
--                                           as a result of terminating the
--                                           assignment. (The only valid change after the
--                                           actual termination date is setting the
--                                           assignment status to another
--                                           TERM_CWK_ASSIGN status.) Set to false
--                                           when there were no changes after
--                                           final process date.
--   p_entries_changed_warning      varchar2 Set to 'Y' when at least one
--                                           element entry was altered due to
--                                           the assignment change.
--                                           Set to 'S' if at least one salary
--                                           element entry was affected. (This
--                                           (is a more specific case than
--                                           'Y'.) Otherwise set to 'N', when
--                                           no element entries were changed.
--
-- Post Failure:
--   The API does not update the assignment or element entries and raises an
--   error.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure final_process_cwk_asg
  (p_validate                      in     boolean  default false
  ,p_assignment_id                 in     number
  ,p_object_version_number         in out nocopy number
  ,p_final_process_date            in     date
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ,p_org_now_no_manager_warning       out nocopy boolean
  ,p_asg_future_changes_warning       out nocopy boolean
  ,p_entries_changed_warning          out nocopy varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< suspend_cwk_asg >----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API changes the status of a contingent worker assignment to a Suspended
 * status.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The assignment must be a contingent worker assignment, and must exist on the
 * effective date.
 *
 * <p><b>Post Success</b><br>
 * The contingent worker assignment will be set to a suspended status.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the assignment and raises an error.
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
 * @param p_assignment_id Identifies the assignment record to be modified.
 * @param p_change_reason Reason for the assignment status change. If there is
 * no change reason the parameter can be null. Valid values are defined in the
 * CWK_ASSIGN_REASON lookup_type.
 * @param p_object_version_number Pass in the current version number of the
 * assignment to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated assignment. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_assignment_status_type_id The new assignment status. The new status
 * must have a system status of SUSP_CWK_ASG. If the assignment status is
 * already a type of SUSP_CWK_ASG this API can be used to set a different
 * suspend status. If this parameter is not explicitly passed, the API uses the
 * default SUSP_CWK_ASG status for the assignment's business group.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated assignment row which now exists as of
 * the effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated assignment row which now exists as of the
 * effective date. If p_validate is true, then set to null.
 * @rep:displayname Suspend Contingent Worker assignment
 * @rep:category BUSINESS_ENTITY PER_CWK_ASG
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure suspend_cwk_asg
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_change_reason                in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_assignment_status_type_id    in     number   default hr_api.g_number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_secondary_emp_asg >---------------------|
-- ----------------------------------------------------------------------------
--
-- This version of the API is now out-of-date however it has been provided to
-- you for backward compatibility support and will be removed in the future.
-- Oracle recommends you to modify existing calling programs in advance of the
-- support being withdrawn thus avoiding any potential disruption.
--
procedure create_secondary_emp_asg
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_person_id                    in     number
  ,p_organization_id              in     number
  ,p_grade_id                     in     number   default null
  ,p_position_id                  in     number   default null
  ,p_job_id                       in     number   default null
  ,p_assignment_status_type_id    in     number   default null
  ,p_payroll_id                   in     number   default null
  ,p_location_id                  in     number   default null
  ,p_supervisor_id                in     number   default null
  ,p_special_ceiling_step_id      in     number   default null
  ,p_pay_basis_id                 in     number   default null
  ,p_assignment_number            in out nocopy varchar2
  ,p_change_reason                in     varchar2 default null
  ,p_comments                     in     varchar2 default null
  ,p_date_probation_end           in     date     default null
  ,p_default_code_comb_id         in     number   default null
  ,p_employment_category          in     varchar2 default null
  ,p_frequency                    in     varchar2 default null
  ,p_internal_address_line        in     varchar2 default null
  ,p_manager_flag                 in     varchar2 default null
  ,p_normal_hours                 in     number   default null
  ,p_perf_review_period           in     number   default null
  ,p_perf_review_period_frequency in     varchar2 default null
  ,p_probation_period             in     number   default null
  ,p_probation_unit               in     varchar2 default null
  ,p_sal_review_period            in     number   default null
  ,p_sal_review_period_frequency  in     varchar2 default null
  ,p_set_of_books_id              in     number   default null
  ,p_source_type                  in     varchar2 default null
  ,p_time_normal_finish           in     varchar2 default null
  ,p_time_normal_start            in     varchar2 default null
  ,p_bargaining_unit_code         in     varchar2 default null
  ,p_labour_union_member_flag     in     varchar2 default 'N'
  ,p_hourly_salaried_code         in     varchar2 default null
  ,p_ass_attribute_category       in     varchar2 default null
  ,p_ass_attribute1               in     varchar2 default null
  ,p_ass_attribute2               in     varchar2 default null
  ,p_ass_attribute3               in     varchar2 default null
  ,p_ass_attribute4               in     varchar2 default null
  ,p_ass_attribute5               in     varchar2 default null
  ,p_ass_attribute6               in     varchar2 default null
  ,p_ass_attribute7               in     varchar2 default null
  ,p_ass_attribute8               in     varchar2 default null
  ,p_ass_attribute9               in     varchar2 default null
  ,p_ass_attribute10              in     varchar2 default null
  ,p_ass_attribute11              in     varchar2 default null
  ,p_ass_attribute12              in     varchar2 default null
  ,p_ass_attribute13              in     varchar2 default null
  ,p_ass_attribute14              in     varchar2 default null
  ,p_ass_attribute15              in     varchar2 default null
  ,p_ass_attribute16              in     varchar2 default null
  ,p_ass_attribute17              in     varchar2 default null
  ,p_ass_attribute18              in     varchar2 default null
  ,p_ass_attribute19              in     varchar2 default null
  ,p_ass_attribute20              in     varchar2 default null
  ,p_ass_attribute21              in     varchar2 default null
  ,p_ass_attribute22              in     varchar2 default null
  ,p_ass_attribute23              in     varchar2 default null
  ,p_ass_attribute24              in     varchar2 default null
  ,p_ass_attribute25              in     varchar2 default null
  ,p_ass_attribute26              in     varchar2 default null
  ,p_ass_attribute27              in     varchar2 default null
  ,p_ass_attribute28              in     varchar2 default null
  ,p_ass_attribute29              in     varchar2 default null
  ,p_ass_attribute30              in     varchar2 default null
  ,p_title                        in     varchar2 default null
  ,p_scl_segment1                 in     varchar2 default null
  ,p_scl_segment2                 in     varchar2 default null
  ,p_scl_segment3                 in     varchar2 default null
  ,p_scl_segment4                 in     varchar2 default null
  ,p_scl_segment5                 in     varchar2 default null
  ,p_scl_segment6                 in     varchar2 default null
  ,p_scl_segment7                 in     varchar2 default null
  ,p_scl_segment8                 in     varchar2 default null
  ,p_scl_segment9                 in     varchar2 default null
  ,p_scl_segment10                in     varchar2 default null
  ,p_scl_segment11                in     varchar2 default null
  ,p_scl_segment12                in     varchar2 default null
  ,p_scl_segment13                in     varchar2 default null
  ,p_scl_segment14                in     varchar2 default null
  ,p_scl_segment15                in     varchar2 default null
  ,p_scl_segment16                in     varchar2 default null
  ,p_scl_segment17                in     varchar2 default null
  ,p_scl_segment18                in     varchar2 default null
  ,p_scl_segment19                in     varchar2 default null
  ,p_scl_segment20                in     varchar2 default null
  ,p_scl_segment21                in     varchar2 default null
  ,p_scl_segment22                in     varchar2 default null
  ,p_scl_segment23                in     varchar2 default null
  ,p_scl_segment24                in     varchar2 default null
  ,p_scl_segment25                in     varchar2 default null
  ,p_scl_segment26                in     varchar2 default null
  ,p_scl_segment27                in     varchar2 default null
  ,p_scl_segment28                in     varchar2 default null
  ,p_scl_segment29                in     varchar2 default null
  ,p_scl_segment30                in     varchar2 default null
-- Bug 944911
-- Added scl_concat_segments and amended scl_concatenated_segments
-- to be an out instead of in out
  ,p_scl_concat_segments          in     varchar2 default null
  ,p_pgp_segment1                 in     varchar2 default null
  ,p_pgp_segment2                 in     varchar2 default null
  ,p_pgp_segment3                 in     varchar2 default null
  ,p_pgp_segment4                 in     varchar2 default null
  ,p_pgp_segment5                 in     varchar2 default null
  ,p_pgp_segment6                 in     varchar2 default null
  ,p_pgp_segment7                 in     varchar2 default null
  ,p_pgp_segment8                 in     varchar2 default null
  ,p_pgp_segment9                 in     varchar2 default null
  ,p_pgp_segment10                in     varchar2 default null
  ,p_pgp_segment11                in     varchar2 default null
  ,p_pgp_segment12                in     varchar2 default null
  ,p_pgp_segment13                in     varchar2 default null
  ,p_pgp_segment14                in     varchar2 default null
  ,p_pgp_segment15                in     varchar2 default null
  ,p_pgp_segment16                in     varchar2 default null
  ,p_pgp_segment17                in     varchar2 default null
  ,p_pgp_segment18                in     varchar2 default null
  ,p_pgp_segment19                in     varchar2 default null
  ,p_pgp_segment20                in     varchar2 default null
  ,p_pgp_segment21                in     varchar2 default null
  ,p_pgp_segment22                in     varchar2 default null
  ,p_pgp_segment23                in     varchar2 default null
  ,p_pgp_segment24                in     varchar2 default null
  ,p_pgp_segment25                in     varchar2 default null
  ,p_pgp_segment26                in     varchar2 default null
  ,p_pgp_segment27                in     varchar2 default null
  ,p_pgp_segment28                in     varchar2 default null
  ,p_pgp_segment29                in     varchar2 default null
  ,p_pgp_segment30                in     varchar2 default null
-- Bug 944911
-- Changed this to out
-- Added new param p_concat_segments in for non sec asg
-- else added p_pgp_concat_segments
  ,p_pgp_concat_segments	  in     varchar2 default null
  ,p_supervisor_assignment_id     in     number   default null
  ,p_group_name                   out nocopy varchar2
-- Bug 944911
-- Added scl_concat_segments and amended scl_concatenated_segments
-- to be an out instead of in out
-- Amended this to be p_concatenated_segments
  ,p_concatenated_segments       out nocopy varchar2
  ,p_assignment_id                   out nocopy number
  ,p_soft_coding_keyflex_id      in  out nocopy number -- bug 2359997
  ,p_people_group_id             in  out nocopy number -- bug 2359997
  ,p_object_version_number           out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_assignment_sequence             out nocopy number
  ,p_comment_id                      out nocopy number
  ,p_other_manager_warning           out nocopy boolean
  );

--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_secondary_emp_asg >---------------------|
-- ----------------------------------------------------------------------------
--
-- This version of the API is now out-of-date however it has been provided to
-- you for backward compatibility support and will be removed in the future.
-- Oracle recommends you to modify existing calling programs in advance of the
-- support being withdrawn thus avoiding any potential disruption.
--
procedure create_secondary_emp_asg
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_person_id                    in     number
  ,p_organization_id              in     number
  ,p_grade_id                     in     number   default null
  ,p_position_id                  in     number   default null
  ,p_job_id                       in     number   default null
  ,p_assignment_status_type_id    in     number   default null
  ,p_payroll_id                   in     number   default null
  ,p_location_id                  in     number   default null
  ,p_supervisor_id                in     number   default null
  ,p_special_ceiling_step_id      in     number   default null
  ,p_pay_basis_id                 in     number   default null
  ,p_assignment_number            in out nocopy varchar2
  ,p_change_reason                in     varchar2 default null
  ,p_comments                     in     varchar2 default null
  ,p_date_probation_end           in     date     default null
  ,p_default_code_comb_id         in     number   default null
  ,p_employment_category          in     varchar2 default null
  ,p_frequency                    in     varchar2 default null
  ,p_internal_address_line        in     varchar2 default null
  ,p_manager_flag                 in     varchar2 default null
  ,p_normal_hours                 in     number   default null
  ,p_perf_review_period           in     number   default null
  ,p_perf_review_period_frequency in     varchar2 default null
  ,p_probation_period             in     number   default null
  ,p_probation_unit               in     varchar2 default null
  ,p_sal_review_period            in     number   default null
  ,p_sal_review_period_frequency  in     varchar2 default null
  ,p_set_of_books_id              in     number   default null
  ,p_source_type                  in     varchar2 default null
  ,p_time_normal_finish           in     varchar2 default null
  ,p_time_normal_start            in     varchar2 default null
  ,p_bargaining_unit_code         in     varchar2 default null
  ,p_labour_union_member_flag     in     varchar2 default 'N'
  ,p_hourly_salaried_code         in     varchar2 default null
  ,p_ass_attribute_category       in     varchar2 default null
  ,p_ass_attribute1               in     varchar2 default null
  ,p_ass_attribute2               in     varchar2 default null
  ,p_ass_attribute3               in     varchar2 default null
  ,p_ass_attribute4               in     varchar2 default null
  ,p_ass_attribute5               in     varchar2 default null
  ,p_ass_attribute6               in     varchar2 default null
  ,p_ass_attribute7               in     varchar2 default null
  ,p_ass_attribute8               in     varchar2 default null
  ,p_ass_attribute9               in     varchar2 default null
  ,p_ass_attribute10              in     varchar2 default null
  ,p_ass_attribute11              in     varchar2 default null
  ,p_ass_attribute12              in     varchar2 default null
  ,p_ass_attribute13              in     varchar2 default null
  ,p_ass_attribute14              in     varchar2 default null
  ,p_ass_attribute15              in     varchar2 default null
  ,p_ass_attribute16              in     varchar2 default null
  ,p_ass_attribute17              in     varchar2 default null
  ,p_ass_attribute18              in     varchar2 default null
  ,p_ass_attribute19              in     varchar2 default null
  ,p_ass_attribute20              in     varchar2 default null
  ,p_ass_attribute21              in     varchar2 default null
  ,p_ass_attribute22              in     varchar2 default null
  ,p_ass_attribute23              in     varchar2 default null
  ,p_ass_attribute24              in     varchar2 default null
  ,p_ass_attribute25              in     varchar2 default null
  ,p_ass_attribute26              in     varchar2 default null
  ,p_ass_attribute27              in     varchar2 default null
  ,p_ass_attribute28              in     varchar2 default null
  ,p_ass_attribute29              in     varchar2 default null
  ,p_ass_attribute30              in     varchar2 default null
  ,p_title                        in     varchar2 default null
  ,p_scl_segment1                 in     varchar2 default null
  ,p_scl_segment2                 in     varchar2 default null
  ,p_scl_segment3                 in     varchar2 default null
  ,p_scl_segment4                 in     varchar2 default null
  ,p_scl_segment5                 in     varchar2 default null
  ,p_scl_segment6                 in     varchar2 default null
  ,p_scl_segment7                 in     varchar2 default null
  ,p_scl_segment8                 in     varchar2 default null
  ,p_scl_segment9                 in     varchar2 default null
  ,p_scl_segment10                in     varchar2 default null
  ,p_scl_segment11                in     varchar2 default null
  ,p_scl_segment12                in     varchar2 default null
  ,p_scl_segment13                in     varchar2 default null
  ,p_scl_segment14                in     varchar2 default null
  ,p_scl_segment15                in     varchar2 default null
  ,p_scl_segment16                in     varchar2 default null
  ,p_scl_segment17                in     varchar2 default null
  ,p_scl_segment18                in     varchar2 default null
  ,p_scl_segment19                in     varchar2 default null
  ,p_scl_segment20                in     varchar2 default null
  ,p_scl_segment21                in     varchar2 default null
  ,p_scl_segment22                in     varchar2 default null
  ,p_scl_segment23                in     varchar2 default null
  ,p_scl_segment24                in     varchar2 default null
  ,p_scl_segment25                in     varchar2 default null
  ,p_scl_segment26                in     varchar2 default null
  ,p_scl_segment27                in     varchar2 default null
  ,p_scl_segment28                in     varchar2 default null
  ,p_scl_segment29                in     varchar2 default null
  ,p_scl_segment30                in     varchar2 default null
-- Bug 944911
-- Added scl_concat_segments and amended scl_concatenated_segments
-- to be an out instead of in out
  ,p_scl_concat_segments          in     varchar2 default null
  ,p_pgp_segment1                 in     varchar2 default null
  ,p_pgp_segment2                 in     varchar2 default null
  ,p_pgp_segment3                 in     varchar2 default null
  ,p_pgp_segment4                 in     varchar2 default null
  ,p_pgp_segment5                 in     varchar2 default null
  ,p_pgp_segment6                 in     varchar2 default null
  ,p_pgp_segment7                 in     varchar2 default null
  ,p_pgp_segment8                 in     varchar2 default null
  ,p_pgp_segment9                 in     varchar2 default null
  ,p_pgp_segment10                in     varchar2 default null
  ,p_pgp_segment11                in     varchar2 default null
  ,p_pgp_segment12                in     varchar2 default null
  ,p_pgp_segment13                in     varchar2 default null
  ,p_pgp_segment14                in     varchar2 default null
  ,p_pgp_segment15                in     varchar2 default null
  ,p_pgp_segment16                in     varchar2 default null
  ,p_pgp_segment17                in     varchar2 default null
  ,p_pgp_segment18                in     varchar2 default null
  ,p_pgp_segment19                in     varchar2 default null
  ,p_pgp_segment20                in     varchar2 default null
  ,p_pgp_segment21                in     varchar2 default null
  ,p_pgp_segment22                in     varchar2 default null
  ,p_pgp_segment23                in     varchar2 default null
  ,p_pgp_segment24                in     varchar2 default null
  ,p_pgp_segment25                in     varchar2 default null
  ,p_pgp_segment26                in     varchar2 default null
  ,p_pgp_segment27                in     varchar2 default null
  ,p_pgp_segment28                in     varchar2 default null
  ,p_pgp_segment29                in     varchar2 default null
  ,p_pgp_segment30                in     varchar2 default null
-- Bug 944911
-- Changed this to out
-- Added new param p_concat_segments in for non sec asg
-- else added p_pgp_concat_segments
  ,p_pgp_concat_segments	  in     varchar2 default null
  ,p_contract_id                  in     number default null
  ,p_establishment_id             in     number default null
  ,p_collective_agreement_id      in     number default null
  ,p_cagr_id_flex_num             in     number default null
  ,p_cag_segment1                 in     varchar2 default null
  ,p_cag_segment2                 in     varchar2 default null
  ,p_cag_segment3                 in     varchar2 default null
  ,p_cag_segment4                 in     varchar2 default null
  ,p_cag_segment5                 in     varchar2 default null
  ,p_cag_segment6                 in     varchar2 default null
  ,p_cag_segment7                 in     varchar2 default null
  ,p_cag_segment8                 in     varchar2 default null
  ,p_cag_segment9                 in     varchar2 default null
  ,p_cag_segment10                in     varchar2 default null
  ,p_cag_segment11                in     varchar2 default null
  ,p_cag_segment12                in     varchar2 default null
  ,p_cag_segment13                in     varchar2 default null
  ,p_cag_segment14                in     varchar2 default null
  ,p_cag_segment15                in     varchar2 default null
  ,p_cag_segment16                in     varchar2 default null
  ,p_cag_segment17                in     varchar2 default null
  ,p_cag_segment18                in     varchar2 default null
  ,p_cag_segment19                in     varchar2 default null
  ,p_cag_segment20                in     varchar2 default null
  ,p_notice_period		  in	 number   default null
  ,p_notice_period_uom		  in     varchar2 default null
  ,p_employee_category		  in     varchar2 default null
  ,p_work_at_home		  in	 varchar2 default null
  ,p_job_post_source_name         in     varchar2 default null
  ,p_grade_ladder_pgm_id          in     number   default null
  ,p_supervisor_assignment_id     in     number   default null
  ,p_group_name                   out nocopy varchar2
-- Bug 944911
-- Added scl_concat_segments and amended scl_concatenated_segments
-- to be an out instead of in out
-- Amended this to be p_concatenated_segments
  ,p_concatenated_segments           out nocopy varchar2
  ,p_cagr_grade_def_id            in out nocopy number -- bug 2359997
  ,p_cagr_concatenated_segments      out nocopy varchar2
  ,p_assignment_id                   out nocopy number
  ,p_soft_coding_keyflex_id       in out nocopy number -- bug 2359997
  ,p_people_group_id              in out nocopy number -- bug 2359997
  ,p_object_version_number           out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_assignment_sequence             out nocopy number
  ,p_comment_id                      out nocopy number
  ,p_other_manager_warning           out nocopy boolean
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_secondary_emp_asg >---------------------|
-- ----------------------------------------------------------------------------
--
-- This version of the API is now out-of-date however it has been provided to
-- you for backward compatibility support and will be removed in the future.
-- Oracle recommends you to modify existing calling programs in advance of the
-- support being withdrawn thus avoiding any potential disruption.
--
procedure create_secondary_emp_asg
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_person_id                    in     number
  ,p_organization_id              in     number
  ,p_grade_id                     in     number   default null
  ,p_position_id                  in     number   default null
  ,p_job_id                       in     number   default null
  ,p_assignment_status_type_id    in     number   default null
  ,p_payroll_id                   in     number   default null
  ,p_location_id                  in     number   default null
  ,p_supervisor_id                in     number   default null
  ,p_special_ceiling_step_id      in     number   default null
  ,p_pay_basis_id                 in     number   default null
  ,p_assignment_number            in out nocopy varchar2
  ,p_change_reason                in     varchar2 default null
  ,p_comments                     in     varchar2 default null
  ,p_date_probation_end           in     date     default null
  ,p_default_code_comb_id         in     number   default null
  ,p_employment_category          in     varchar2 default null
  ,p_frequency                    in     varchar2 default null
  ,p_internal_address_line        in     varchar2 default null
  ,p_manager_flag                 in     varchar2 default null
  ,p_normal_hours                 in     number   default null
  ,p_perf_review_period           in     number   default null
  ,p_perf_review_period_frequency in     varchar2 default null
  ,p_probation_period             in     number   default null
  ,p_probation_unit               in     varchar2 default null
  ,p_sal_review_period            in     number   default null
  ,p_sal_review_period_frequency  in     varchar2 default null
  ,p_set_of_books_id              in     number   default null
  ,p_source_type                  in     varchar2 default null
  ,p_time_normal_finish           in     varchar2 default null
  ,p_time_normal_start            in     varchar2 default null
  ,p_bargaining_unit_code         in     varchar2 default null
  ,p_labour_union_member_flag     in     varchar2 default 'N'
  ,p_hourly_salaried_code         in     varchar2 default null
  ,p_ass_attribute_category       in     varchar2 default null
  ,p_ass_attribute1               in     varchar2 default null
  ,p_ass_attribute2               in     varchar2 default null
  ,p_ass_attribute3               in     varchar2 default null
  ,p_ass_attribute4               in     varchar2 default null
  ,p_ass_attribute5               in     varchar2 default null
  ,p_ass_attribute6               in     varchar2 default null
  ,p_ass_attribute7               in     varchar2 default null
  ,p_ass_attribute8               in     varchar2 default null
  ,p_ass_attribute9               in     varchar2 default null
  ,p_ass_attribute10              in     varchar2 default null
  ,p_ass_attribute11              in     varchar2 default null
  ,p_ass_attribute12              in     varchar2 default null
  ,p_ass_attribute13              in     varchar2 default null
  ,p_ass_attribute14              in     varchar2 default null
  ,p_ass_attribute15              in     varchar2 default null
  ,p_ass_attribute16              in     varchar2 default null
  ,p_ass_attribute17              in     varchar2 default null
  ,p_ass_attribute18              in     varchar2 default null
  ,p_ass_attribute19              in     varchar2 default null
  ,p_ass_attribute20              in     varchar2 default null
  ,p_ass_attribute21              in     varchar2 default null
  ,p_ass_attribute22              in     varchar2 default null
  ,p_ass_attribute23              in     varchar2 default null
  ,p_ass_attribute24              in     varchar2 default null
  ,p_ass_attribute25              in     varchar2 default null
  ,p_ass_attribute26              in     varchar2 default null
  ,p_ass_attribute27              in     varchar2 default null
  ,p_ass_attribute28              in     varchar2 default null
  ,p_ass_attribute29              in     varchar2 default null
  ,p_ass_attribute30              in     varchar2 default null
  ,p_title                        in     varchar2 default null
  ,p_scl_segment1                 in     varchar2 default null
  ,p_scl_segment2                 in     varchar2 default null
  ,p_scl_segment3                 in     varchar2 default null
  ,p_scl_segment4                 in     varchar2 default null
  ,p_scl_segment5                 in     varchar2 default null
  ,p_scl_segment6                 in     varchar2 default null
  ,p_scl_segment7                 in     varchar2 default null
  ,p_scl_segment8                 in     varchar2 default null
  ,p_scl_segment9                 in     varchar2 default null
  ,p_scl_segment10                in     varchar2 default null
  ,p_scl_segment11                in     varchar2 default null
  ,p_scl_segment12                in     varchar2 default null
  ,p_scl_segment13                in     varchar2 default null
  ,p_scl_segment14                in     varchar2 default null
  ,p_scl_segment15                in     varchar2 default null
  ,p_scl_segment16                in     varchar2 default null
  ,p_scl_segment17                in     varchar2 default null
  ,p_scl_segment18                in     varchar2 default null
  ,p_scl_segment19                in     varchar2 default null
  ,p_scl_segment20                in     varchar2 default null
  ,p_scl_segment21                in     varchar2 default null
  ,p_scl_segment22                in     varchar2 default null
  ,p_scl_segment23                in     varchar2 default null
  ,p_scl_segment24                in     varchar2 default null
  ,p_scl_segment25                in     varchar2 default null
  ,p_scl_segment26                in     varchar2 default null
  ,p_scl_segment27                in     varchar2 default null
  ,p_scl_segment28                in     varchar2 default null
  ,p_scl_segment29                in     varchar2 default null
  ,p_scl_segment30                in     varchar2 default null
-- Bug 944911
-- Added scl_concat_segments and amended scl_concatenated_segments
-- to be an out instead of in out
  ,p_scl_concat_segments          in     varchar2 default null
  ,p_pgp_segment1                 in     varchar2 default null
  ,p_pgp_segment2                 in     varchar2 default null
  ,p_pgp_segment3                 in     varchar2 default null
  ,p_pgp_segment4                 in     varchar2 default null
  ,p_pgp_segment5                 in     varchar2 default null
  ,p_pgp_segment6                 in     varchar2 default null
  ,p_pgp_segment7                 in     varchar2 default null
  ,p_pgp_segment8                 in     varchar2 default null
  ,p_pgp_segment9                 in     varchar2 default null
  ,p_pgp_segment10                in     varchar2 default null
  ,p_pgp_segment11                in     varchar2 default null
  ,p_pgp_segment12                in     varchar2 default null
  ,p_pgp_segment13                in     varchar2 default null
  ,p_pgp_segment14                in     varchar2 default null
  ,p_pgp_segment15                in     varchar2 default null
  ,p_pgp_segment16                in     varchar2 default null
  ,p_pgp_segment17                in     varchar2 default null
  ,p_pgp_segment18                in     varchar2 default null
  ,p_pgp_segment19                in     varchar2 default null
  ,p_pgp_segment20                in     varchar2 default null
  ,p_pgp_segment21                in     varchar2 default null
  ,p_pgp_segment22                in     varchar2 default null
  ,p_pgp_segment23                in     varchar2 default null
  ,p_pgp_segment24                in     varchar2 default null
  ,p_pgp_segment25                in     varchar2 default null
  ,p_pgp_segment26                in     varchar2 default null
  ,p_pgp_segment27                in     varchar2 default null
  ,p_pgp_segment28                in     varchar2 default null
  ,p_pgp_segment29                in     varchar2 default null
  ,p_pgp_segment30                in     varchar2 default null
-- Bug 944911
-- Changed this to out
-- Added new param p_concat_segments in for non sec asg
-- else added p_pgp_concat_segments
  ,p_pgp_concat_segments	  in     varchar2 default null
  ,p_contract_id                  in     number default null
  ,p_establishment_id             in     number default null
  ,p_collective_agreement_id      in     number default null
  ,p_cagr_id_flex_num             in     number default null
  ,p_cag_segment1                 in     varchar2 default null
  ,p_cag_segment2                 in     varchar2 default null
  ,p_cag_segment3                 in     varchar2 default null
  ,p_cag_segment4                 in     varchar2 default null
  ,p_cag_segment5                 in     varchar2 default null
  ,p_cag_segment6                 in     varchar2 default null
  ,p_cag_segment7                 in     varchar2 default null
  ,p_cag_segment8                 in     varchar2 default null
  ,p_cag_segment9                 in     varchar2 default null
  ,p_cag_segment10                in     varchar2 default null
  ,p_cag_segment11                in     varchar2 default null
  ,p_cag_segment12                in     varchar2 default null
  ,p_cag_segment13                in     varchar2 default null
  ,p_cag_segment14                in     varchar2 default null
  ,p_cag_segment15                in     varchar2 default null
  ,p_cag_segment16                in     varchar2 default null
  ,p_cag_segment17                in     varchar2 default null
  ,p_cag_segment18                in     varchar2 default null
  ,p_cag_segment19                in     varchar2 default null
  ,p_cag_segment20                in     varchar2 default null
  ,p_notice_period		  in	 number   default null
  ,p_notice_period_uom		  in     varchar2 default null
  ,p_employee_category		  in     varchar2 default null
  ,p_work_at_home		  in	 varchar2 default null
  ,p_job_post_source_name         in     varchar2 default null
  ,p_grade_ladder_pgm_id	  in	 number   default null
  ,p_supervisor_assignment_id	  in	 number   default null
  ,p_group_name                   out nocopy varchar2
-- Bug 944911
-- Added scl_concat_segments and amended scl_concatenated_segments
-- to be an out instead of in out
-- Amended this to be p_concatenated_segments
  ,p_concatenated_segments           out nocopy varchar2
  ,p_cagr_grade_def_id            in out nocopy number  -- bug 2359997
  ,p_cagr_concatenated_segments      out nocopy varchar2
  ,p_assignment_id                   out nocopy number
  ,p_soft_coding_keyflex_id       in out nocopy number  -- bug 2359997
  ,p_people_group_id              in out nocopy number  -- bug 2359997
  ,p_object_version_number           out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_assignment_sequence             out nocopy number
  ,p_comment_id                      out nocopy number
  ,p_other_manager_warning           out nocopy boolean
  ,p_hourly_salaried_warning         out nocopy boolean
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_secondary_emp_asg >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new secondary assignment for an employee.
 *
 * This API cannot create a primary assignment.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The person and organization must exist at the effective start date of the
 * assignment.
 *
 * <p><b>Post Success</b><br>
 * A new secondary assignment is created for the employee
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the secondary assignment and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_person_id Identifies the person for whom you create the secondary
 * assignment record
 * @param p_organization_id Identifies the organization of the secondary
 * assignment
 * @param p_grade_id Identifies the grade of the secondary assignment
 * @param p_position_id Identifies the position of the secondary assignment
 * @param p_job_id Identifies the job of the secondary assignment
 * @param p_assignment_status_type_id Identifies the assignment status of the
 * secondary assignment.
 * @param p_payroll_id Identifies the payroll for the secondary assignment
 * @param p_location_id Identifies the location of the secondary assignment
 * @param p_supervisor_id Identifies the supervisor for the secondary
 * assignment. The value refers to the supervisor's person record.
 * @param p_special_ceiling_step_id Highest allowed step for the grade scale
 * associated with the grade of the secondary assignment.
 * @param p_pay_basis_id Salary basis for the secondary assignment
 * @param p_assignment_number If a value is passed in, this is used as the
 * assignment number. If no value is passed in an assignment number is
 * generated.
 * @param p_change_reason Reason for the assignment status change. If there is
 * no change reason the parameter can be null. Valid values are defined in the
 * EMP_ASSIGN_REASON lookup type.
 * @param p_comments Comment text.
 * @param p_date_probation_end End date of probation period
 * @param p_default_code_comb_id Identifier for the General Ledger Accounting
 * Flexfield combination that applies to this assignment
 * @param p_employment_category Employment category. Valid values are defined
 * in the EMP_CAT lookup type.
 * @param p_frequency Frequency associated with the defined normal working
 * hours. Valid values are defined in the FREQUENCY lookup type.
 * @param p_internal_address_line Internal address identified with the
 * secondary assignment.
 * @param p_manager_flag Indicates whether the employee is a manager
 * @param p_normal_hours Normal working hours for this assignment
 * @param p_perf_review_period Length of performance review period.
 * @param p_perf_review_period_frequency Units of performance review period.
 * Valid values are defined in the FREQUENCY lookup type.
 * @param p_probation_period Length of probation period
 * @param p_probation_unit Units of probation period. Valid values are defined
 * in the QUALIFYING_UNITS lookup type.
 * @param p_sal_review_period Length of salary review period
 * @param p_sal_review_period_frequency Units of salary review period. Valid
 * values are defined in the FREQUENCY lookup type.
 * @param p_set_of_books_id Identifies General Ledger set of books.
 * @param p_source_type Recruitment activity which this assignment is sourced
 * from. Valid values are defined in the REC_TYPE lookup type.
 * @param p_time_normal_finish Normal work finish time
 * @param p_time_normal_start Normal work start time
 * @param p_bargaining_unit_code Code for bargaining unit. Valid values are
 * defined in the BARGAINING_UNIT_CODE lookup type.
 * @param p_labour_union_member_flag Value 'Y' indicates employee is a labour
 * union member. Other values indicate not a member.
 * @param p_hourly_salaried_code Identifies if the assignment is paid hourly or
 * is salaried. Valid values defined in the HOURLY_SALARIED_CODE lookup type.
 * @param p_ass_attribute_category This context value determines which
 * Flexfield Structure to use with the Descriptive flexfield segments.
 * @param p_ass_attribute1 Descriptive flexfield segment
 * @param p_ass_attribute2 Descriptive flexfield segment
 * @param p_ass_attribute3 Descriptive flexfield segment
 * @param p_ass_attribute4 Descriptive flexfield segment
 * @param p_ass_attribute5 Descriptive flexfield segment
 * @param p_ass_attribute6 Descriptive flexfield segment
 * @param p_ass_attribute7 Descriptive flexfield segment
 * @param p_ass_attribute8 Descriptive flexfield segment
 * @param p_ass_attribute9 Descriptive flexfield segment
 * @param p_ass_attribute10 Descriptive flexfield segment
 * @param p_ass_attribute11 Descriptive flexfield segment
 * @param p_ass_attribute12 Descriptive flexfield segment
 * @param p_ass_attribute13 Descriptive flexfield segment
 * @param p_ass_attribute14 Descriptive flexfield segment
 * @param p_ass_attribute15 Descriptive flexfield segment
 * @param p_ass_attribute16 Descriptive flexfield segment
 * @param p_ass_attribute17 Descriptive flexfield segment
 * @param p_ass_attribute18 Descriptive flexfield segment
 * @param p_ass_attribute19 Descriptive flexfield segment
 * @param p_ass_attribute20 Descriptive flexfield segment
 * @param p_ass_attribute21 Descriptive flexfield segment
 * @param p_ass_attribute22 Descriptive flexfield segment
 * @param p_ass_attribute23 Descriptive flexfield segment
 * @param p_ass_attribute24 Descriptive flexfield segment
 * @param p_ass_attribute25 Descriptive flexfield segment
 * @param p_ass_attribute26 Descriptive flexfield segment
 * @param p_ass_attribute27 Descriptive flexfield segment
 * @param p_ass_attribute28 Descriptive flexfield segment
 * @param p_ass_attribute29 Descriptive flexfield segment
 * @param p_ass_attribute30 Descriptive flexfield segment
 * @param p_title Obsolete parameter, do not use.
 * @param p_scl_segment1 Soft Coded key flexfield segment
 * @param p_scl_segment2 Soft Coded key flexfield segment
 * @param p_scl_segment3 Soft Coded key flexfield segment
 * @param p_scl_segment4 Soft Coded key flexfield segment
 * @param p_scl_segment5 Soft Coded key flexfield segment
 * @param p_scl_segment6 Soft Coded key flexfield segment
 * @param p_scl_segment7 Soft Coded key flexfield segment
 * @param p_scl_segment8 Soft Coded key flexfield segment
 * @param p_scl_segment9 Soft Coded key flexfield segment
 * @param p_scl_segment10 Soft Coded key flexfield segment
 * @param p_scl_segment11 Soft Coded key flexfield segment
 * @param p_scl_segment12 Soft Coded key flexfield segment
 * @param p_scl_segment13 Soft Coded key flexfield segment
 * @param p_scl_segment14 Soft Coded key flexfield segment
 * @param p_scl_segment15 Soft Coded key flexfield segment
 * @param p_scl_segment16 Soft Coded key flexfield segment
 * @param p_scl_segment17 Soft Coded key flexfield segment
 * @param p_scl_segment18 Soft Coded key flexfield segment
 * @param p_scl_segment19 Soft Coded key flexfield segment
 * @param p_scl_segment20 Soft Coded key flexfield segment
 * @param p_scl_segment21 Soft Coded key flexfield segment
 * @param p_scl_segment22 Soft Coded key flexfield segment
 * @param p_scl_segment23 Soft Coded key flexfield segment
 * @param p_scl_segment24 Soft Coded key flexfield segment
 * @param p_scl_segment25 Soft Coded key flexfield segment
 * @param p_scl_segment26 Soft Coded key flexfield segment
 * @param p_scl_segment27 Soft Coded key flexfield segment
 * @param p_scl_segment28 Soft Coded key flexfield segment
 * @param p_scl_segment29 Soft Coded key flexfield segment
 * @param p_scl_segment30 Soft Coded key flexfield segment
 * @param p_scl_concat_segments Concatenated segments for Soft Coded Key
 * Flexfield. Concatenated segments can be supplied instead of individual
 * segments.
 * @param p_pgp_segment1 People group key flexfield segment
 * @param p_pgp_segment2 People group key flexfield segment
 * @param p_pgp_segment3 People group key flexfield segment
 * @param p_pgp_segment4 People group key flexfield segment
 * @param p_pgp_segment5 People group key flexfield segment
 * @param p_pgp_segment6 People group key flexfield segment
 * @param p_pgp_segment7 People group key flexfield segment
 * @param p_pgp_segment8 People group key flexfield segment
 * @param p_pgp_segment9 People group key flexfield segment
 * @param p_pgp_segment10 People group key flexfield segment
 * @param p_pgp_segment11 People group key flexfield segment
 * @param p_pgp_segment12 People group key flexfield segment
 * @param p_pgp_segment13 People group key flexfield segment
 * @param p_pgp_segment14 People group key flexfield segment
 * @param p_pgp_segment15 People group key flexfield segment
 * @param p_pgp_segment16 People group key flexfield segment
 * @param p_pgp_segment17 People group key flexfield segment
 * @param p_pgp_segment18 People group key flexfield segment
 * @param p_pgp_segment19 People group key flexfield segment
 * @param p_pgp_segment20 People group key flexfield segment
 * @param p_pgp_segment21 People group key flexfield segment
 * @param p_pgp_segment22 People group key flexfield segment
 * @param p_pgp_segment23 People group key flexfield segment
 * @param p_pgp_segment24 People group key flexfield segment
 * @param p_pgp_segment25 People group key flexfield segment
 * @param p_pgp_segment26 People group key flexfield segment
 * @param p_pgp_segment27 People group key flexfield segment
 * @param p_pgp_segment28 People group key flexfield segment
 * @param p_pgp_segment29 People group key flexfield segment
 * @param p_pgp_segment30 People group key flexfield segment
 * @param p_pgp_concat_segments Concatenated segments for People Group Key
 * Flexfield. Concatenated segments can be supplied instead of individual
 * segments.
 * @param p_contract_id Contract associated with this assignment
 * @param p_establishment_id For French business groups, this identifies the
 * Establishment Legal Entity for this assignment.
 * @param p_collective_agreement_id Collective Agreement that applies to this
 * assignment
 * @param p_cagr_id_flex_num Identifier for the structure from CAGR Key
 * flexfield to use for this assignment
 * @param p_cag_segment1 CAGR Key Flexfield segment
 * @param p_cag_segment2 CAGR Key Flexfield segment
 * @param p_cag_segment3 CAGR Key Flexfield segment
 * @param p_cag_segment4 CAGR Key Flexfield segment
 * @param p_cag_segment5 CAGR Key Flexfield segment
 * @param p_cag_segment6 CAGR Key Flexfield segment
 * @param p_cag_segment7 CAGR Key Flexfield segment
 * @param p_cag_segment8 CAGR Key Flexfield segment
 * @param p_cag_segment9 CAGR Key Flexfield segment
 * @param p_cag_segment10 CAGR Key Flexfield segment
 * @param p_cag_segment11 CAGR Key Flexfield segment
 * @param p_cag_segment12 CAGR Key Flexfield segment
 * @param p_cag_segment13 CAGR Key Flexfield segment
 * @param p_cag_segment14 CAGR Key Flexfield segment
 * @param p_cag_segment15 CAGR Key Flexfield segment
 * @param p_cag_segment16 CAGR Key Flexfield segment
 * @param p_cag_segment17 CAGR Key Flexfield segment
 * @param p_cag_segment18 CAGR Key Flexfield segment
 * @param p_cag_segment19 CAGR Key Flexfield segment
 * @param p_cag_segment20 CAGR Key Flexfield segment
 * @param p_notice_period Length of notice period
 * @param p_notice_period_uom Units for notice period. Valid values are defined
 * in the QUALIFYING_UNITS lookup type.
 * @param p_employee_category Employee Category. Valid values are defined in
 * the EMPLOYEE_CATG lookup type.
 * @param p_work_at_home Indicate whether this assignment is to work at home.
 * Valid values are defined in the YES_NO lookup type.
 * @param p_job_post_source_name The source of the job posting that was
 * answered for this assignment.
 * @param p_grade_ladder_pgm_id Grade Ladder for this assignment
 * @param p_supervisor_assignment_id Supervisor's assignment that is
 * responsible for supervising this assignment.
 * @param p_group_name If p_validate is false, set to the People Group Key
 * Flexfield concatenated segments. If p_validate is true, set to null.
 * @param p_concatenated_segments If p_validate is false, set to Soft Coded Key
 * Flexfield concatenated segments, if p_validate is true, set to null.
 * @param p_cagr_grade_def_id If a value is passed in for this parameter, it
 * identifies an existing CAGR Key Flexfield combination to associate with the
 * assignment, and segment values are ignored. If a value is not passed in,
 * then the individual CAGR Key Flexfield segments supplied will be used to
 * choose an existing combination or create a new combination. When the API
 * completes, if p_validate is false, then this uniquely identifies the
 * associated combination of the CAGR Key flexfield for this assignment. If
 * p_validate is true, then set to null.
 * @param p_cagr_concatenated_segments CAGR Key Flexfield concatenated segments
 * @param p_assignment_id If p_validate is false, then this uniquely identifies
 * the created assignment. If p_validate is true, then set to null.
 * @param p_soft_coding_keyflex_id If a value is passed in for this parameter,
 * it identifies an existing Soft Coded Key Flexfield combination to associate
 * with the assignment, and segment values are ignored. If a value is not
 * passed in, then the individual Soft Coded Key Flexfield segments supplied
 * will be used to choose an existing combination or create a new combination.
 * When the API completes, if p_validate is false, then this uniquely
 * identifies the associated combination of the Soft Coded Key flexfield for
 * this assignment. If p_validate is true, then set to null.
 * @param p_people_group_id If a value is passed in for this parameter, it
 * identifies an existing People Group Key Flexfield combination to associate
 * with the assignment, and segment values are ignored. If a value is not
 * passed in, then the individual People Group Key Flexfield segments supplied
 * will be used to choose an existing combination or create a new combination.
 * When the API completes, if p_validate is false, then this uniquely
 * identifies the associated combination of the People Group Key flexfield for
 * this assignment. If p_validate is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created assignment. If p_validate is true, then the
 * value will be null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created assignment. If p_validate is
 * true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created assignment. If p_validate is true, then
 * set to null.
 * @param p_assignment_sequence If p_validate is false, then an automatically
 * incremented number is associated with this assignment, depending on the
 * number of assignment which already exist. If p_validate is true then set to
 * null.
 * @param p_comment_id If p_validate is false and comment text was provided,
 * then will be set to the identifier of the created assignment comment record.
 * If p_validate is true or no comment text was provided, then will be null.
 * @param p_other_manager_warning If set to true, then a manager existed in the
 * organization prior to calling this API and the manager flag has been set to
 * 'Y' for yes.
 * @param p_hourly_salaried_warning Set to true if values entered for Salary
 * Basis and Hourly Salaried Code are invalid as of p_effective_date.
 * @param p_gsp_post_process_warning Set to the name of a warning message from
 * the Message Dictionary if any Grade Ladder related errors have been
 * encountered while running this API.
 * @rep:displayname Create Secondary Employee Assignment
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE_ASG
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_secondary_emp_asg
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_person_id                    in     number
  ,p_organization_id              in     number
  ,p_grade_id                     in     number   default null
  ,p_position_id                  in     number   default null
  ,p_job_id                       in     number   default null
  ,p_assignment_status_type_id    in     number   default null
  ,p_payroll_id                   in     number   default null
  ,p_location_id                  in     number   default null
  ,p_supervisor_id                in     number   default null
  ,p_special_ceiling_step_id      in     number   default null
  ,p_pay_basis_id                 in     number   default null
  ,p_assignment_number            in out nocopy varchar2
  ,p_change_reason                in     varchar2 default null
  ,p_comments                     in     varchar2 default null
  ,p_date_probation_end           in     date     default null
  ,p_default_code_comb_id         in     number   default null
  ,p_employment_category          in     varchar2 default null
  ,p_frequency                    in     varchar2 default null
  ,p_internal_address_line        in     varchar2 default null
  ,p_manager_flag                 in     varchar2 default null
  ,p_normal_hours                 in     number   default null
  ,p_perf_review_period           in     number   default null
  ,p_perf_review_period_frequency in     varchar2 default null
  ,p_probation_period             in     number   default null
  ,p_probation_unit               in     varchar2 default null
  ,p_sal_review_period            in     number   default null
  ,p_sal_review_period_frequency  in     varchar2 default null
  ,p_set_of_books_id              in     number   default null
  ,p_source_type                  in     varchar2 default null
  ,p_time_normal_finish           in     varchar2 default null
  ,p_time_normal_start            in     varchar2 default null
  ,p_bargaining_unit_code         in     varchar2 default null
  ,p_labour_union_member_flag     in     varchar2 default 'N'
  ,p_hourly_salaried_code         in     varchar2 default null
  ,p_ass_attribute_category       in     varchar2 default null
  ,p_ass_attribute1               in     varchar2 default null
  ,p_ass_attribute2               in     varchar2 default null
  ,p_ass_attribute3               in     varchar2 default null
  ,p_ass_attribute4               in     varchar2 default null
  ,p_ass_attribute5               in     varchar2 default null
  ,p_ass_attribute6               in     varchar2 default null
  ,p_ass_attribute7               in     varchar2 default null
  ,p_ass_attribute8               in     varchar2 default null
  ,p_ass_attribute9               in     varchar2 default null
  ,p_ass_attribute10              in     varchar2 default null
  ,p_ass_attribute11              in     varchar2 default null
  ,p_ass_attribute12              in     varchar2 default null
  ,p_ass_attribute13              in     varchar2 default null
  ,p_ass_attribute14              in     varchar2 default null
  ,p_ass_attribute15              in     varchar2 default null
  ,p_ass_attribute16              in     varchar2 default null
  ,p_ass_attribute17              in     varchar2 default null
  ,p_ass_attribute18              in     varchar2 default null
  ,p_ass_attribute19              in     varchar2 default null
  ,p_ass_attribute20              in     varchar2 default null
  ,p_ass_attribute21              in     varchar2 default null
  ,p_ass_attribute22              in     varchar2 default null
  ,p_ass_attribute23              in     varchar2 default null
  ,p_ass_attribute24              in     varchar2 default null
  ,p_ass_attribute25              in     varchar2 default null
  ,p_ass_attribute26              in     varchar2 default null
  ,p_ass_attribute27              in     varchar2 default null
  ,p_ass_attribute28              in     varchar2 default null
  ,p_ass_attribute29              in     varchar2 default null
  ,p_ass_attribute30              in     varchar2 default null
  ,p_title                        in     varchar2 default null
  ,p_scl_segment1                 in     varchar2 default null
  ,p_scl_segment2                 in     varchar2 default null
  ,p_scl_segment3                 in     varchar2 default null
  ,p_scl_segment4                 in     varchar2 default null
  ,p_scl_segment5                 in     varchar2 default null
  ,p_scl_segment6                 in     varchar2 default null
  ,p_scl_segment7                 in     varchar2 default null
  ,p_scl_segment8                 in     varchar2 default null
  ,p_scl_segment9                 in     varchar2 default null
  ,p_scl_segment10                in     varchar2 default null
  ,p_scl_segment11                in     varchar2 default null
  ,p_scl_segment12                in     varchar2 default null
  ,p_scl_segment13                in     varchar2 default null
  ,p_scl_segment14                in     varchar2 default null
  ,p_scl_segment15                in     varchar2 default null
  ,p_scl_segment16                in     varchar2 default null
  ,p_scl_segment17                in     varchar2 default null
  ,p_scl_segment18                in     varchar2 default null
  ,p_scl_segment19                in     varchar2 default null
  ,p_scl_segment20                in     varchar2 default null
  ,p_scl_segment21                in     varchar2 default null
  ,p_scl_segment22                in     varchar2 default null
  ,p_scl_segment23                in     varchar2 default null
  ,p_scl_segment24                in     varchar2 default null
  ,p_scl_segment25                in     varchar2 default null
  ,p_scl_segment26                in     varchar2 default null
  ,p_scl_segment27                in     varchar2 default null
  ,p_scl_segment28                in     varchar2 default null
  ,p_scl_segment29                in     varchar2 default null
  ,p_scl_segment30                in     varchar2 default null
-- Bug 944911
-- Added scl_concat_segments and amended scl_concatenated_segments
-- to be an out instead of in out
  ,p_scl_concat_segments          in     varchar2 default null
  ,p_pgp_segment1                 in     varchar2 default null
  ,p_pgp_segment2                 in     varchar2 default null
  ,p_pgp_segment3                 in     varchar2 default null
  ,p_pgp_segment4                 in     varchar2 default null
  ,p_pgp_segment5                 in     varchar2 default null
  ,p_pgp_segment6                 in     varchar2 default null
  ,p_pgp_segment7                 in     varchar2 default null
  ,p_pgp_segment8                 in     varchar2 default null
  ,p_pgp_segment9                 in     varchar2 default null
  ,p_pgp_segment10                in     varchar2 default null
  ,p_pgp_segment11                in     varchar2 default null
  ,p_pgp_segment12                in     varchar2 default null
  ,p_pgp_segment13                in     varchar2 default null
  ,p_pgp_segment14                in     varchar2 default null
  ,p_pgp_segment15                in     varchar2 default null
  ,p_pgp_segment16                in     varchar2 default null
  ,p_pgp_segment17                in     varchar2 default null
  ,p_pgp_segment18                in     varchar2 default null
  ,p_pgp_segment19                in     varchar2 default null
  ,p_pgp_segment20                in     varchar2 default null
  ,p_pgp_segment21                in     varchar2 default null
  ,p_pgp_segment22                in     varchar2 default null
  ,p_pgp_segment23                in     varchar2 default null
  ,p_pgp_segment24                in     varchar2 default null
  ,p_pgp_segment25                in     varchar2 default null
  ,p_pgp_segment26                in     varchar2 default null
  ,p_pgp_segment27                in     varchar2 default null
  ,p_pgp_segment28                in     varchar2 default null
  ,p_pgp_segment29                in     varchar2 default null
  ,p_pgp_segment30                in     varchar2 default null
-- Bug 944911
-- Changed this to out
-- Added new param p_concat_segments in for non sec asg
-- else added p_pgp_concat_segments
  ,p_pgp_concat_segments	  in     varchar2 default null
  ,p_contract_id                  in     number default null
  ,p_establishment_id             in     number default null
  ,p_collective_agreement_id      in     number default null
  ,p_cagr_id_flex_num             in     number default null
  ,p_cag_segment1                 in     varchar2 default null
  ,p_cag_segment2                 in     varchar2 default null
  ,p_cag_segment3                 in     varchar2 default null
  ,p_cag_segment4                 in     varchar2 default null
  ,p_cag_segment5                 in     varchar2 default null
  ,p_cag_segment6                 in     varchar2 default null
  ,p_cag_segment7                 in     varchar2 default null
  ,p_cag_segment8                 in     varchar2 default null
  ,p_cag_segment9                 in     varchar2 default null
  ,p_cag_segment10                in     varchar2 default null
  ,p_cag_segment11                in     varchar2 default null
  ,p_cag_segment12                in     varchar2 default null
  ,p_cag_segment13                in     varchar2 default null
  ,p_cag_segment14                in     varchar2 default null
  ,p_cag_segment15                in     varchar2 default null
  ,p_cag_segment16                in     varchar2 default null
  ,p_cag_segment17                in     varchar2 default null
  ,p_cag_segment18                in     varchar2 default null
  ,p_cag_segment19                in     varchar2 default null
  ,p_cag_segment20                in     varchar2 default null
  ,p_notice_period		  in	 number   default null
  ,p_notice_period_uom		  in     varchar2 default null
  ,p_employee_category		  in     varchar2 default null
  ,p_work_at_home		  in	 varchar2 default null
  ,p_job_post_source_name         in     varchar2 default null
  ,p_grade_ladder_pgm_id	  in	 number   default null
  ,p_supervisor_assignment_id	  in	 number   default null
  ,p_group_name                   out nocopy varchar2
-- Bug 944911
-- Added scl_concat_segments and amended scl_concatenated_segments
-- to be an out instead of in out
-- Amended this to be p_concatenated_segments
  ,p_concatenated_segments           out nocopy varchar2
  ,p_cagr_grade_def_id            in out nocopy number  -- bug 2359997
  ,p_cagr_concatenated_segments      out nocopy varchar2
  ,p_assignment_id                   out nocopy number
  ,p_soft_coding_keyflex_id       in out nocopy number  -- bug 2359997
  ,p_people_group_id              in out nocopy number  -- bug 2359997
  ,p_object_version_number           out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_assignment_sequence             out nocopy number
  ,p_comment_id                      out nocopy number
  ,p_other_manager_warning           out nocopy boolean
  ,p_hourly_salaried_warning         out nocopy boolean
  ,p_gsp_post_process_warning        out nocopy varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_secondary_cwk_asg >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new secondary assignment for a contingent worker.
 *
 * This API cannot create a primary assignment
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The person and organization must exist at the effective start date of the
 * assignment.
 *
 * <p><b>Post Success</b><br>
 * A new secondary assignment is created for the contingent worker
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the secondary assignment and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_business_group_id The business group associated with this
 * assignment. This should be the same as the business group associated with
 * the contingent worker
 * @param p_person_id Identifies the person for whom you create the secondary
 * assignment record
 * @param p_organization_id Identifies the organization of the secondary
 * assignment
 * @param p_assignment_number If a value is passed in, this is used as the
 * assignment number. If no value is passed in an assignment number is
 * generated.
 * @param p_assignment_category Identifies the assignment category for the
 * secondary contingent worker assignment. Valid values are defined in the
 * CWK_ASG_CATEGORY lookup type.
 * @param p_assignment_status_type_id Identifies the assignment status for the
 * secondary assignment.
 * @param p_change_reason Reason for the assignment status change. If there is
 * no change reason the parameter can be null. Valid values are defined in the
 * CWK_ASSIGN_REASON lookup_type.
 * @param p_comments Comment text.
 * @param p_default_code_comb_id Identifier for the General Ledger Accounting
 * Flexfield combination which applies to this assignment
 * @param p_establishment_id For French business groups, this identifies the
 * Establishment Legal Entity for this assignment.
 * @param p_frequency Frequency associated with the defined normal working
 * hours. Valid values are defined in the FREQUENCY lookup type.
 * @param p_internal_address_line Internal address identified with this
 * assignment.
 * @param p_job_id Identifies the job of the secondary assignment
 * @param p_labour_union_member_flag Value 'Y' indicates employee is a labour
 * union member. Other values indicate not a member.
 * @param p_location_id Identifies the location of the secondary assignment
 * @param p_manager_flag Indicates whether the contingent worker is a manager
 * @param p_normal_hours Normal working hours for this assignment
 * @param p_position_id Identifies the position of the secondary assignment
 * @param p_grade_id Identifies the grade of the secondary assignment
 * @param p_project_title Name of the project for which the contingent worker
 * is engaged on this assignment.
 * @param p_set_of_books_id Identifies General Ledger set of books.
 * @param p_source_type Recruitment activity that this assignment is sourced
 * from. Valid values are defined in the REC_TYPE lookup type.
 * @param p_supervisor_id Supervisor for this assignment. The value refers to
 * the supervisor's person record.
 * @param p_time_normal_finish Normal work finish time
 * @param p_time_normal_start Normal work start time
 * @param p_title Obsolete parameter, do not use.
 * @param p_vendor_assignment_number Identification number given by the
 * supplier to the contingent worker's assignment
 * @param p_vendor_employee_number Identification number given by the supplier
 * to the contingent worker
 * @param p_vendor_id Identifier of the Supplier of the contingent worker from
 * iProcurement
 * @param p_vendor_site_id Identifier of the Supplier site of the contingent
 * worker from iProcurement
 * @param p_po_header_id Identifier of the Purchase Order under which this
 * contingent workers assignment is being paid, from iProcurement
 * @param p_po_line_id Identifier of the Purchase Order Line under which this
 * contingent worker's assignment is being paid, from iProcurement
 * @param p_projected_assignment_end Projected end date of this assignment.
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
 * @param p_pgp_segment1 People group key flexfield segment
 * @param p_pgp_segment2 People group key flexfield segment
 * @param p_pgp_segment3 People group key flexfield segment
 * @param p_pgp_segment4 People group key flexfield segment
 * @param p_pgp_segment5 People group key flexfield segment
 * @param p_pgp_segment6 People group key flexfield segment
 * @param p_pgp_segment7 People group key flexfield segment
 * @param p_pgp_segment8 People group key flexfield segment
 * @param p_pgp_segment9 People group key flexfield segment
 * @param p_pgp_segment10 People group key flexfield segment
 * @param p_pgp_segment11 People group key flexfield segment
 * @param p_pgp_segment12 People group key flexfield segment
 * @param p_pgp_segment13 People group key flexfield segment
 * @param p_pgp_segment14 People group key flexfield segment
 * @param p_pgp_segment15 People group key flexfield segment
 * @param p_pgp_segment16 People group key flexfield segment
 * @param p_pgp_segment17 People group key flexfield segment
 * @param p_pgp_segment18 People group key flexfield segment
 * @param p_pgp_segment19 People group key flexfield segment
 * @param p_pgp_segment20 People group key flexfield segment
 * @param p_pgp_segment21 People group key flexfield segment
 * @param p_pgp_segment22 People group key flexfield segment
 * @param p_pgp_segment23 People group key flexfield segment
 * @param p_pgp_segment24 People group key flexfield segment
 * @param p_pgp_segment25 People group key flexfield segment
 * @param p_pgp_segment26 People group key flexfield segment
 * @param p_pgp_segment27 People group key flexfield segment
 * @param p_pgp_segment28 People group key flexfield segment
 * @param p_pgp_segment29 People group key flexfield segment
 * @param p_pgp_segment30 People group key flexfield segment
 * @param p_scl_segment1 Soft Coded key flexfield segment
 * @param p_scl_segment2 Soft Coded key flexfield segment
 * @param p_scl_segment3 Soft Coded key flexfield segment
 * @param p_scl_segment4 Soft Coded key flexfield segment
 * @param p_scl_segment5 Soft Coded key flexfield segment
 * @param p_scl_segment6 Soft Coded key flexfield segment
 * @param p_scl_segment7 Soft Coded key flexfield segment
 * @param p_scl_segment8 Soft Coded key flexfield segment
 * @param p_scl_segment9 Soft Coded key flexfield segment
 * @param p_scl_segment10 Soft Coded key flexfield segment
 * @param p_scl_segment11 Soft Coded key flexfield segment
 * @param p_scl_segment12 Soft Coded key flexfield segment
 * @param p_scl_segment13 Soft Coded key flexfield segment
 * @param p_scl_segment14 Soft Coded key flexfield segment
 * @param p_scl_segment15 Soft Coded key flexfield segment
 * @param p_scl_segment16 Soft Coded key flexfield segment
 * @param p_scl_segment17 Soft Coded key flexfield segment
 * @param p_scl_segment18 Soft Coded key flexfield segment
 * @param p_scl_segment19 Soft Coded key flexfield segment
 * @param p_scl_segment20 Soft Coded key flexfield segment
 * @param p_scl_segment21 Soft Coded key flexfield segment
 * @param p_scl_segment22 Soft Coded key flexfield segment
 * @param p_scl_segment23 Soft Coded key flexfield segment
 * @param p_scl_segment24 Soft Coded key flexfield segment
 * @param p_scl_segment25 Soft Coded key flexfield segment
 * @param p_scl_segment26 Soft Coded key flexfield segment
 * @param p_scl_segment27 Soft Coded key flexfield segment
 * @param p_scl_segment28 Soft Coded key flexfield segment
 * @param p_scl_segment29 Soft Coded key flexfield segment
 * @param p_scl_segment30 Soft Coded key flexfield segment
 * @param p_scl_concat_segments Concatenated segments for Soft Coded Key
 * Flexfield. Concatenated segments can be supplied instead of individual
 * segments.
 * @param p_pgp_concat_segments Concatenated segments for People Group Key
 * Flexfield. Concatenated segments can be supplied instead of individual
 * segments.
 * @param p_supervisor_assignment_id Supervisor's assignment that is
 * responsible for supervising this assignment.
 * @param p_assignment_id If p_validate is false, then this uniquely identifies
 * the created assignment. If p_validate is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created assignment. If p_validate is true, then the
 * value will be null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created assignment. If p_validate is
 * true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created assignment. If p_validate is true, then
 * set to null.
 * @param p_assignment_sequence If p_validate is false, then an automatically
 * incremented number is associated with this assignment, depending on the
 * number of assignment that already exist. If p_validate is true then set to
 * null.
 * @param p_comment_id If p_validate is false and comment text was provided,
 * then will be set to the identifier of the created assignment comment record.
 * If p_validate is true or no comment text was provided, then will be null.
 * @param p_people_group_id If p_validate is false, then this uniquely
 * identifies the associated combination of the People Group Key flexfield for
 * this assignment. If p_validate is true, then set to null.
 * @param p_people_group_name If p_validate is false, set to the People Group
 * Key Flexfield concatenated segments. If p_validate is true, set to null.
 * @param p_other_manager_warning If set to true, then a manager existed in the
 * organization prior to calling this API and the manager flag has been set to
 * 'Y' for yes.
 * @param p_hourly_salaried_warning Set to true if values entered for Salary
 * Basis and Hourly Salaried Code are invalid as of p_effective_date.
 * @param p_soft_coding_keyflex_id If p_validate is false, then this uniquely
 * identifies the associated combination of the Soft Coded Key flexfield for
 * this assignment. If p_validate is true, then set to null.
 * @rep:displayname Create Secondary Contingent Worker Assignment
 * @rep:category BUSINESS_ENTITY PER_CWK_ASG
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_secondary_cwk_asg
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_business_group_id            in     number
  ,p_person_id                    in     number
  ,p_organization_id              in     number
  ,p_assignment_number            in out nocopy varchar2
  ,p_assignment_category          in     varchar2 default null
  ,p_assignment_status_type_id    in     number   default null
  ,p_change_reason                in     varchar2 default null
  ,p_comments                     in     varchar2 default null
  ,p_default_code_comb_id         in     number   default null
  ,p_establishment_id             in     number   default null
  ,p_frequency                    in     varchar2 default null
  ,p_internal_address_line        in     varchar2 default null
  ,p_job_id                       in     number   default null
  ,p_labour_union_member_flag     in     varchar2 default 'N'
  ,p_location_id                  in     number   default null
  ,p_manager_flag                 in     varchar2 default null
  ,p_normal_hours                 in     number   default null
  ,p_position_id                  in     number   default null
  ,p_grade_id                     in     number   default null
  ,p_project_title                in     varchar2 default null
  ,p_set_of_books_id              in     number   default null
  ,p_source_type                  in     varchar2 default null
  ,p_supervisor_id                in     number   default null
  ,p_time_normal_finish           in     varchar2 default null
  ,p_time_normal_start            in     varchar2 default null
  ,p_title                        in     varchar2 default null
  ,p_vendor_assignment_number     in     varchar2 default null
  ,p_vendor_employee_number       in     varchar2 default null
  ,p_vendor_id                    in     number   default null
  ,p_vendor_site_id               in     number   default null
  ,p_po_header_id                 in     number   default null
  ,p_po_line_id                   in     number   default null
  ,p_projected_assignment_end     in     date     default null
  ,p_attribute_category           in     varchar2 default null
  ,p_attribute1                   in     varchar2 default null
  ,p_attribute2                   in     varchar2 default null
  ,p_attribute3                   in     varchar2 default null
  ,p_attribute4                   in     varchar2 default null
  ,p_attribute5                   in     varchar2 default null
  ,p_attribute6                   in     varchar2 default null
  ,p_attribute7                   in     varchar2 default null
  ,p_attribute8                   in     varchar2 default null
  ,p_attribute9                   in     varchar2 default null
  ,p_attribute10                  in     varchar2 default null
  ,p_attribute11                  in     varchar2 default null
  ,p_attribute12                  in     varchar2 default null
  ,p_attribute13                  in     varchar2 default null
  ,p_attribute14                  in     varchar2 default null
  ,p_attribute15                  in     varchar2 default null
  ,p_attribute16                  in     varchar2 default null
  ,p_attribute17                  in     varchar2 default null
  ,p_attribute18                  in     varchar2 default null
  ,p_attribute19                  in     varchar2 default null
  ,p_attribute20                  in     varchar2 default null
  ,p_attribute21                  in     varchar2 default null
  ,p_attribute22                  in     varchar2 default null
  ,p_attribute23                  in     varchar2 default null
  ,p_attribute24                  in     varchar2 default null
  ,p_attribute25                  in     varchar2 default null
  ,p_attribute26                  in     varchar2 default null
  ,p_attribute27                  in     varchar2 default null
  ,p_attribute28                  in     varchar2 default null
  ,p_attribute29                  in     varchar2 default null
  ,p_attribute30                  in     varchar2 default null
  ,p_pgp_segment1                 in     varchar2 default null
  ,p_pgp_segment2                 in     varchar2 default null
  ,p_pgp_segment3                 in     varchar2 default null
  ,p_pgp_segment4                 in     varchar2 default null
  ,p_pgp_segment5                 in     varchar2 default null
  ,p_pgp_segment6                 in     varchar2 default null
  ,p_pgp_segment7                 in     varchar2 default null
  ,p_pgp_segment8                 in     varchar2 default null
  ,p_pgp_segment9                 in     varchar2 default null
  ,p_pgp_segment10                in     varchar2 default null
  ,p_pgp_segment11                in     varchar2 default null
  ,p_pgp_segment12                in     varchar2 default null
  ,p_pgp_segment13                in     varchar2 default null
  ,p_pgp_segment14                in     varchar2 default null
  ,p_pgp_segment15                in     varchar2 default null
  ,p_pgp_segment16                in     varchar2 default null
  ,p_pgp_segment17                in     varchar2 default null
  ,p_pgp_segment18                in     varchar2 default null
  ,p_pgp_segment19                in     varchar2 default null
  ,p_pgp_segment20                in     varchar2 default null
  ,p_pgp_segment21                in     varchar2 default null
  ,p_pgp_segment22                in     varchar2 default null
  ,p_pgp_segment23                in     varchar2 default null
  ,p_pgp_segment24                in     varchar2 default null
  ,p_pgp_segment25                in     varchar2 default null
  ,p_pgp_segment26                in     varchar2 default null
  ,p_pgp_segment27                in     varchar2 default null
  ,p_pgp_segment28                in     varchar2 default null
  ,p_pgp_segment29                in     varchar2 default null
  ,p_pgp_segment30                in     varchar2 default null
  ,p_scl_segment1                 in     varchar2 default null
  ,p_scl_segment2                 in     varchar2 default null
  ,p_scl_segment3                 in     varchar2 default null
  ,p_scl_segment4                 in     varchar2 default null
  ,p_scl_segment5                 in     varchar2 default null
  ,p_scl_segment6                 in     varchar2 default null
  ,p_scl_segment7                 in     varchar2 default null
  ,p_scl_segment8                 in     varchar2 default null
  ,p_scl_segment9                 in     varchar2 default null
  ,p_scl_segment10                in     varchar2 default null
  ,p_scl_segment11                in     varchar2 default null
  ,p_scl_segment12                in     varchar2 default null
  ,p_scl_segment13                in     varchar2 default null
  ,p_scl_segment14                in     varchar2 default null
  ,p_scl_segment15                in     varchar2 default null
  ,p_scl_segment16                in     varchar2 default null
  ,p_scl_segment17                in     varchar2 default null
  ,p_scl_segment18                in     varchar2 default null
  ,p_scl_segment19                in     varchar2 default null
  ,p_scl_segment20                in     varchar2 default null
  ,p_scl_segment21                in     varchar2 default null
  ,p_scl_segment22                in     varchar2 default null
  ,p_scl_segment23                in     varchar2 default null
  ,p_scl_segment24                in     varchar2 default null
  ,p_scl_segment25                in     varchar2 default null
  ,p_scl_segment26                in     varchar2 default null
  ,p_scl_segment27                in     varchar2 default null
  ,p_scl_segment28                in     varchar2 default null
  ,p_scl_segment29                in     varchar2 default null
  ,p_scl_segment30                in     varchar2 default null
  ,p_scl_concat_segments          in     varchar2 default null
  ,p_pgp_concat_segments          in     varchar2 default null
  ,p_supervisor_assignment_id     in     number   default null
  ,p_assignment_id                   out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_assignment_sequence             out nocopy number
  ,p_comment_id                      out nocopy number
  ,p_people_group_id                 out nocopy number
  ,p_people_group_name               out nocopy varchar2
  ,p_other_manager_warning           out nocopy boolean
  ,p_hourly_salaried_warning         out nocopy boolean
  ,p_soft_coding_keyflex_id          out nocopy number);
--
-- ----------------------------------------------------------------------------
-- |---------------------< get_supplier_info_for_po >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This API returns the Supplier and Supplier given a Purchase Order.
--
-- Prerequisites:
--   This procedure assumes that the Purchase Order passed in is valid. The
--   procedure will not error if the PO is not valid but the OUT parameters
--   will be null.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_po_header_id                  Yes number   Purchase Order Header
--                                                reference.
-- Post Success:
--   The API sets the following out parameters:
--
--   Name                           Type     Description
--   p_vendor_id                    number   ID of the Supplier.
--   p_vendor_site_id               number   ID of the Supplier site.
--
-- Post Failure:
--   The API does not error and returns the OUT parameters as NULL.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
PROCEDURE get_supplier_info_for_po
  (p_po_header_id                 IN            NUMBER
  ,p_vendor_id                       OUT NOCOPY NUMBER
  ,p_vendor_site_id                  OUT NOCOPY NUMBER);
--
-- ----------------------------------------------------------------------------
-- |---------------------< get_supplier_for_site >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This API returns the Supplier given a Supplier Site.
--
-- Prerequisites:
--   This procedure assumes that the Supplier Site is valid. The
--   procedure will not error if the Site is not valid but the function
--   will return null.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_vendor_site_id                Yes number   ID of Supplier Site.
--
-- Post Success:
--   The API returns a number indicating the ID of the Supplier.
--
-- Post Failure:
--   The API does not error and returns NULL.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
FUNCTION get_supplier_for_site
  (p_vendor_site_id               IN     NUMBER)
RETURN NUMBER;
--
-- ----------------------------------------------------------------------------
-- |---------------------< get_po_for_line >-----------------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This API returns the Purchase Order (PO) given a PO Line.
--
-- Prerequisites:
--   This procedure assumes that the PO Line is valid. The procedure
--   will not error if the PO Line is not valid but the function
--   will return null.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_po_line_id                    Yes number   ID of PO Line.
--
-- Post Success:
--   The API returns a number indicating the Purchase Order Header ID.
--
-- Post Failure:
--   The API does not error and returns NULL.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
FUNCTION get_po_for_line
  (p_po_line_id                   IN     NUMBER)
RETURN NUMBER;
--
-- ----------------------------------------------------------------------------
-- |---------------------< get_job_for_po_line >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This API returns the Job given a PO Line.
--
-- Prerequisites:
--   This procedure assumes that the PO Line is valid. The procedure
--   will not error if the PO Line is not valid but the function
--   will return null.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_po_line_id                    Yes number   ID of PO Line.
--
-- Post Success:
--   The API returns a number indicating the job_id on the PO Line.
--
-- Post Failure:
--   The API does not error and returns NULL.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
FUNCTION get_job_for_po_line
  (p_po_line_id                   IN     NUMBER)
RETURN NUMBER;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_gb_secondary_emp_asg >--------------------|
-- ----------------------------------------------------------------------------
--
-- This version of the API is now out-of-date however it has been provided to
-- you for backward compatibility support and will be removed in the future.
-- Oracle recommends you to modify existing calling programs in advance of the
-- support being withdrawn thus avoiding any potential disruption.
--
procedure create_gb_secondary_emp_asg
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_person_id                    in     number
  ,p_organization_id              in     number
  ,p_grade_id                     in     number   default null
  ,p_position_id                  in     number   default null
  ,p_job_id                       in     number   default null
  ,p_assignment_status_type_id    in     number   default null
  ,p_payroll_id                   in     number   default null
  ,p_location_id                  in     number   default null
  ,p_supervisor_id                in     number   default null
  ,p_special_ceiling_step_id      in     number   default null
  ,p_pay_basis_id                 in     number   default null
  ,p_assignment_number            in out nocopy varchar2
  ,p_change_reason                in     varchar2 default null
  ,p_comments                     in     varchar2 default null
  ,p_date_probation_end           in     date     default null
  ,p_default_code_comb_id         in     number   default null
  ,p_employment_category          in     varchar2 default null
  ,p_frequency                    in     varchar2 default null
  ,p_internal_address_line        in     varchar2 default null
  ,p_manager_flag                 in     varchar2 default null
  ,p_normal_hours                 in     number   default null
  ,p_perf_review_period           in     number   default null
  ,p_perf_review_period_frequency in     varchar2 default null
  ,p_probation_period             in     number   default null
  ,p_probation_unit               in     varchar2 default null
  ,p_sal_review_period            in     number   default null
  ,p_sal_review_period_frequency  in     varchar2 default null
  ,p_set_of_books_id              in     number   default null
  ,p_source_type                  in     varchar2 default null
  ,p_time_normal_finish           in     varchar2 default null
  ,p_time_normal_start            in     varchar2 default null
  ,p_bargaining_unit_code         in     varchar2 default null
  ,p_labour_union_member_flag     in     varchar2 default 'N'
  ,p_hourly_salaried_code         in     varchar2 default null
  ,p_ass_attribute_category       in     varchar2 default null
  ,p_ass_attribute1               in     varchar2 default null
  ,p_ass_attribute2               in     varchar2 default null
  ,p_ass_attribute3               in     varchar2 default null
  ,p_ass_attribute4               in     varchar2 default null
  ,p_ass_attribute5               in     varchar2 default null
  ,p_ass_attribute6               in     varchar2 default null
  ,p_ass_attribute7               in     varchar2 default null
  ,p_ass_attribute8               in     varchar2 default null
  ,p_ass_attribute9               in     varchar2 default null
  ,p_ass_attribute10              in     varchar2 default null
  ,p_ass_attribute11              in     varchar2 default null
  ,p_ass_attribute12              in     varchar2 default null
  ,p_ass_attribute13              in     varchar2 default null
  ,p_ass_attribute14              in     varchar2 default null
  ,p_ass_attribute15              in     varchar2 default null
  ,p_ass_attribute16              in     varchar2 default null
  ,p_ass_attribute17              in     varchar2 default null
  ,p_ass_attribute18              in     varchar2 default null
  ,p_ass_attribute19              in     varchar2 default null
  ,p_ass_attribute20              in     varchar2 default null
  ,p_ass_attribute21              in     varchar2 default null
  ,p_ass_attribute22              in     varchar2 default null
  ,p_ass_attribute23              in     varchar2 default null
  ,p_ass_attribute24              in     varchar2 default null
  ,p_ass_attribute25              in     varchar2 default null
  ,p_ass_attribute26              in     varchar2 default null
  ,p_ass_attribute27              in     varchar2 default null
  ,p_ass_attribute28              in     varchar2 default null
  ,p_ass_attribute29              in     varchar2 default null
  ,p_ass_attribute30              in     varchar2 default null
  ,p_title                        in     varchar2 default null
  ,p_pgp_segment1                 in     varchar2 default null
  ,p_pgp_segment2                 in     varchar2 default null
  ,p_pgp_segment3                 in     varchar2 default null
  ,p_pgp_segment4                 in     varchar2 default null
  ,p_pgp_segment5                 in     varchar2 default null
  ,p_pgp_segment6                 in     varchar2 default null
  ,p_pgp_segment7                 in     varchar2 default null
  ,p_pgp_segment8                 in     varchar2 default null
  ,p_pgp_segment9                 in     varchar2 default null
  ,p_pgp_segment10                in     varchar2 default null
  ,p_pgp_segment11                in     varchar2 default null
  ,p_pgp_segment12                in     varchar2 default null
  ,p_pgp_segment13                in     varchar2 default null
  ,p_pgp_segment14                in     varchar2 default null
  ,p_pgp_segment15                in     varchar2 default null
  ,p_pgp_segment16                in     varchar2 default null
  ,p_pgp_segment17                in     varchar2 default null
  ,p_pgp_segment18                in     varchar2 default null
  ,p_pgp_segment19                in     varchar2 default null
  ,p_pgp_segment20                in     varchar2 default null
  ,p_pgp_segment21                in     varchar2 default null
  ,p_pgp_segment22                in     varchar2 default null
  ,p_pgp_segment23                in     varchar2 default null
  ,p_pgp_segment24                in     varchar2 default null
  ,p_pgp_segment25                in     varchar2 default null
  ,p_pgp_segment26                in     varchar2 default null
  ,p_pgp_segment27                in     varchar2 default null
  ,p_pgp_segment28                in     varchar2 default null
  ,p_pgp_segment29                in     varchar2 default null
  ,p_pgp_segment30                in     varchar2 default null
-- Bug 944911
-- Amended p_group_name to out
-- Added new param p_pgp_concat_segments - for sec asg procs
-- for others added p_concat_segments
  ,p_pgp_concat_segments	  in     varchar2 default null
  ,p_supervisor_assignment_id     in     number   default null
  ,p_group_name                      out nocopy varchar2
  ,p_assignment_id                   out nocopy number
  ,p_people_group_id                 out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_assignment_sequence             out nocopy number
  ,p_comment_id                      out nocopy number
  ,p_other_manager_warning           out nocopy boolean
  );

--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_gb_secondary_emp_asg >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a secondary employee assignment for an employee in a United
 * Kingdom business group.
 *
 * This API cannot create a primary assignment.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The person and organization must exist at the effective start date of the
 * assignment. The business group should be set to a United Kingdom
 * legislation.
 *
 * <p><b>Post Success</b><br>
 * A new secondary assignment is created for the employee
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the secondary assignment and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_person_id Identifies the person for whom you create the secondary
 * assignment record
 * @param p_organization_id Identifies the organization of the secondary
 * assignment
 * @param p_grade_id Identifies the grade of the secondary assignment
 * @param p_position_id Identifies the position of the secondary assignment
 * @param p_job_id Identifies the job of the secondary assignment
 * @param p_assignment_status_type_id Identifies the assignment status of the
 * secondary assignment.
 * @param p_payroll_id Identifies the payroll for the secondary assignment
 * @param p_location_id Identifies the location of the secondary assignment
 * @param p_supervisor_id Supervisor for the secondary assignment. The value
 * refers to the supervisor's person record.
 * @param p_special_ceiling_step_id Highest allowed step for the grade scale
 * associated with the grade of the secondary assignment.
 * @param p_pay_basis_id Salary basis for the secondary assignment
 * @param p_assignment_number If a value is passed in, this is used as the
 * assignment number. If no value is passed in an assignment number is
 * generated.
 * @param p_change_reason Reason for the assignment status change. If there is
 * no change reason the parameter can be null. Valid values are defined in the
 * EMP_ASSIGN_REASON lookup type.
 * @param p_comments Comment text.
 * @param p_date_probation_end End date of probation period
 * @param p_default_code_comb_id Identifier for the General Ledger Accounting
 * Flexfield combination which applies to this assignment
 * @param p_employment_category Employment category. Valid values are defined
 * in the EMP_CAT lookup type.
 * @param p_frequency Frequency associated with the defined normal working
 * hours. Valid values are defined in the FREQUENCY lookup type.
 * @param p_internal_address_line Internal address identified with this
 * assignment.
 * @param p_manager_flag Indicates whether the employee is a manager
 * @param p_normal_hours Normal working hours for this assignment
 * @param p_perf_review_period Length of performance review period
 * @param p_perf_review_period_frequency Units of performance review period.
 * Valid values are defined in the FREQUENCY lookup type.
 * @param p_probation_period Length of probation period
 * @param p_probation_unit Units of probation period. Valid values are defined
 * in the QUALIFYING_UNITS lookup type.
 * @param p_sal_review_period Length of salary review period
 * @param p_sal_review_period_frequency Units of salary review period. Valid
 * values are defined in the FREQUENCY lookup type.
 * @param p_set_of_books_id Identifies General Ledger set of books.
 * @param p_source_type Recruitment activity that this assignment is sourced
 * from. Valid values are defined in the REC_TYPE lookup type.
 * @param p_time_normal_finish Normal work finish time
 * @param p_time_normal_start Normal work start time
 * @param p_bargaining_unit_code Code for bargaining unit. Valid values are
 * defined in the BARGAINING_UNIT_CODE lookup type.
 * @param p_labour_union_member_flag Value 'Y' indicates employee is a labour
 * union member. Other values indicate not a member.
 * @param p_hourly_salaried_code Identifies if the assignment is paid hourly or
 * is salaried. Valid values defined in the HOURLY_SALARIED_CODE lookup type.
 * @param p_ass_attribute_category This context value determines which
 * Flexfield Structure to use with the Descriptive flexfield segments.
 * @param p_ass_attribute1 Descriptive flexfield segment
 * @param p_ass_attribute2 Descriptive flexfield segment
 * @param p_ass_attribute3 Descriptive flexfield segment
 * @param p_ass_attribute4 Descriptive flexfield segment
 * @param p_ass_attribute5 Descriptive flexfield segment
 * @param p_ass_attribute6 Descriptive flexfield segment
 * @param p_ass_attribute7 Descriptive flexfield segment
 * @param p_ass_attribute8 Descriptive flexfield segment
 * @param p_ass_attribute9 Descriptive flexfield segment
 * @param p_ass_attribute10 Descriptive flexfield segment
 * @param p_ass_attribute11 Descriptive flexfield segment
 * @param p_ass_attribute12 Descriptive flexfield segment
 * @param p_ass_attribute13 Descriptive flexfield segment
 * @param p_ass_attribute14 Descriptive flexfield segment
 * @param p_ass_attribute15 Descriptive flexfield segment
 * @param p_ass_attribute16 Descriptive flexfield segment
 * @param p_ass_attribute17 Descriptive flexfield segment
 * @param p_ass_attribute18 Descriptive flexfield segment
 * @param p_ass_attribute19 Descriptive flexfield segment
 * @param p_ass_attribute20 Descriptive flexfield segment
 * @param p_ass_attribute21 Descriptive flexfield segment
 * @param p_ass_attribute22 Descriptive flexfield segment
 * @param p_ass_attribute23 Descriptive flexfield segment
 * @param p_ass_attribute24 Descriptive flexfield segment
 * @param p_ass_attribute25 Descriptive flexfield segment
 * @param p_ass_attribute26 Descriptive flexfield segment
 * @param p_ass_attribute27 Descriptive flexfield segment
 * @param p_ass_attribute28 Descriptive flexfield segment
 * @param p_ass_attribute29 Descriptive flexfield segment
 * @param p_ass_attribute30 Descriptive flexfield segment
 * @param p_title Obsolete parameter, do not use.
 * @param p_pgp_segment1 People group key flexfield segment
 * @param p_pgp_segment2 People group key flexfield segment
 * @param p_pgp_segment3 People group key flexfield segment
 * @param p_pgp_segment4 People group key flexfield segment
 * @param p_pgp_segment5 People group key flexfield segment
 * @param p_pgp_segment6 People group key flexfield segment
 * @param p_pgp_segment7 People group key flexfield segment
 * @param p_pgp_segment8 People group key flexfield segment
 * @param p_pgp_segment9 People group key flexfield segment
 * @param p_pgp_segment10 People group key flexfield segment
 * @param p_pgp_segment11 People group key flexfield segment
 * @param p_pgp_segment12 People group key flexfield segment
 * @param p_pgp_segment13 People group key flexfield segment
 * @param p_pgp_segment14 People group key flexfield segment
 * @param p_pgp_segment15 People group key flexfield segment
 * @param p_pgp_segment16 People group key flexfield segment
 * @param p_pgp_segment17 People group key flexfield segment
 * @param p_pgp_segment18 People group key flexfield segment
 * @param p_pgp_segment19 People group key flexfield segment
 * @param p_pgp_segment20 People group key flexfield segment
 * @param p_pgp_segment21 People group key flexfield segment
 * @param p_pgp_segment22 People group key flexfield segment
 * @param p_pgp_segment23 People group key flexfield segment
 * @param p_pgp_segment24 People group key flexfield segment
 * @param p_pgp_segment25 People group key flexfield segment
 * @param p_pgp_segment26 People group key flexfield segment
 * @param p_pgp_segment27 People group key flexfield segment
 * @param p_pgp_segment28 People group key flexfield segment
 * @param p_pgp_segment29 People group key flexfield segment
 * @param p_pgp_segment30 People group key flexfield segment
 * @param p_pgp_concat_segments Concatenated segments for People Group Key
 * Flexfield. Concatenated segments can be supplied instead of individual
 * segments.
 * @param p_supervisor_assignment_id Supervisor's assignment that is
 * responsible for supervising this assignment.
 * @param p_group_name If p_validate is false, set to the People Group Key
 * Flexfield concatenated segments. If p_validate is true, set to null.
 * @param p_assignment_id If p_validate is false, then this uniquely identifies
 * the created assignment. If p_validate is true, then set to null.
 * @param p_people_group_id If p_validate is false, then this uniquely
 * identifies the associated combination of the People Group Key flexfield for
 * this assignment. If p_validate is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created assignment. If p_validate is true, then the
 * value will be null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created assignment. If p_validate is
 * true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created assignment. If p_validate is true, then
 * set to null.
 * @param p_assignment_sequence If p_validate is false, then an automatically
 * incremented number is associated with this assignment, depending on the
 * number of assignment which already exist. If p_validate is true then set to
 * null.
 * @param p_comment_id If p_validate is false and comment text was provided,
 * then will be set to the identifier of the created assignment comment record.
 * If p_validate is true or no comment text was provided, then will be null.
 * @param p_other_manager_warning If set to true, then a manager existed in the
 * organization prior to calling this API and the manager flag has been set to
 * 'Y' for yes.
 * @param p_hourly_salaried_warning Set to true if values entered for Salary
 * Basis and Hourly Salaried Code are invalid as of p_effective_date.
 * @param p_cagr_grade_def_id If a value is passed in for this parameter, it
 * identifies an existing CAGR Key Flexfield combination to associate with the
 * assignment, and segment values are ignored. If a value is not passed in,
 * then the individual CAGR Key Flexfield segments supplied will be used to
 * choose an existing combination or create a new combination. When the API
 * completes, if p_validate is false, then this uniquely identifies the
 * associated combination of the CAGR Key flexfield for this assignment. If
 * p_validate is true, then set to null.
 * @param p_cagr_concatenated_segments CAGR Key Flexfield concatenated segments
 * @rep:displayname Create Secondary Employee Assignment for United Kingdom
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE_ASG
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_gb_secondary_emp_asg
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_person_id                    in     number
  ,p_organization_id              in     number
  ,p_grade_id                     in     number   default null
  ,p_position_id                  in     number   default null
  ,p_job_id                       in     number   default null
  ,p_assignment_status_type_id    in     number   default null
  ,p_payroll_id                   in     number   default null
  ,p_location_id                  in     number   default null
  ,p_supervisor_id                in     number   default null
  ,p_special_ceiling_step_id      in     number   default null
  ,p_pay_basis_id                 in     number   default null
  ,p_assignment_number            in out nocopy varchar2
  ,p_change_reason                in     varchar2 default null
  ,p_comments                     in     varchar2 default null
  ,p_date_probation_end           in     date     default null
  ,p_default_code_comb_id         in     number   default null
  ,p_employment_category          in     varchar2 default null
  ,p_frequency                    in     varchar2 default null
  ,p_internal_address_line        in     varchar2 default null
  ,p_manager_flag                 in     varchar2 default null
  ,p_normal_hours                 in     number   default null
  ,p_perf_review_period           in     number   default null
  ,p_perf_review_period_frequency in     varchar2 default null
  ,p_probation_period             in     number   default null
  ,p_probation_unit               in     varchar2 default null
  ,p_sal_review_period            in     number   default null
  ,p_sal_review_period_frequency  in     varchar2 default null
  ,p_set_of_books_id              in     number   default null
  ,p_source_type                  in     varchar2 default null
  ,p_time_normal_finish           in     varchar2 default null
  ,p_time_normal_start            in     varchar2 default null
  ,p_bargaining_unit_code         in     varchar2 default null
  ,p_labour_union_member_flag     in     varchar2 default 'N'
  ,p_hourly_salaried_code         in     varchar2 default null
  ,p_ass_attribute_category       in     varchar2 default null
  ,p_ass_attribute1               in     varchar2 default null
  ,p_ass_attribute2               in     varchar2 default null
  ,p_ass_attribute3               in     varchar2 default null
  ,p_ass_attribute4               in     varchar2 default null
  ,p_ass_attribute5               in     varchar2 default null
  ,p_ass_attribute6               in     varchar2 default null
  ,p_ass_attribute7               in     varchar2 default null
  ,p_ass_attribute8               in     varchar2 default null
  ,p_ass_attribute9               in     varchar2 default null
  ,p_ass_attribute10              in     varchar2 default null
  ,p_ass_attribute11              in     varchar2 default null
  ,p_ass_attribute12              in     varchar2 default null
  ,p_ass_attribute13              in     varchar2 default null
  ,p_ass_attribute14              in     varchar2 default null
  ,p_ass_attribute15              in     varchar2 default null
  ,p_ass_attribute16              in     varchar2 default null
  ,p_ass_attribute17              in     varchar2 default null
  ,p_ass_attribute18              in     varchar2 default null
  ,p_ass_attribute19              in     varchar2 default null
  ,p_ass_attribute20              in     varchar2 default null
  ,p_ass_attribute21              in     varchar2 default null
  ,p_ass_attribute22              in     varchar2 default null
  ,p_ass_attribute23              in     varchar2 default null
  ,p_ass_attribute24              in     varchar2 default null
  ,p_ass_attribute25              in     varchar2 default null
  ,p_ass_attribute26              in     varchar2 default null
  ,p_ass_attribute27              in     varchar2 default null
  ,p_ass_attribute28              in     varchar2 default null
  ,p_ass_attribute29              in     varchar2 default null
  ,p_ass_attribute30              in     varchar2 default null
  ,p_title                        in     varchar2 default null
  ,p_pgp_segment1                 in     varchar2 default null
  ,p_pgp_segment2                 in     varchar2 default null
  ,p_pgp_segment3                 in     varchar2 default null
  ,p_pgp_segment4                 in     varchar2 default null
  ,p_pgp_segment5                 in     varchar2 default null
  ,p_pgp_segment6                 in     varchar2 default null
  ,p_pgp_segment7                 in     varchar2 default null
  ,p_pgp_segment8                 in     varchar2 default null
  ,p_pgp_segment9                 in     varchar2 default null
  ,p_pgp_segment10                in     varchar2 default null
  ,p_pgp_segment11                in     varchar2 default null
  ,p_pgp_segment12                in     varchar2 default null
  ,p_pgp_segment13                in     varchar2 default null
  ,p_pgp_segment14                in     varchar2 default null
  ,p_pgp_segment15                in     varchar2 default null
  ,p_pgp_segment16                in     varchar2 default null
  ,p_pgp_segment17                in     varchar2 default null
  ,p_pgp_segment18                in     varchar2 default null
  ,p_pgp_segment19                in     varchar2 default null
  ,p_pgp_segment20                in     varchar2 default null
  ,p_pgp_segment21                in     varchar2 default null
  ,p_pgp_segment22                in     varchar2 default null
  ,p_pgp_segment23                in     varchar2 default null
  ,p_pgp_segment24                in     varchar2 default null
  ,p_pgp_segment25                in     varchar2 default null
  ,p_pgp_segment26                in     varchar2 default null
  ,p_pgp_segment27                in     varchar2 default null
  ,p_pgp_segment28                in     varchar2 default null
  ,p_pgp_segment29                in     varchar2 default null
  ,p_pgp_segment30                in     varchar2 default null
-- Bug 944911
-- Amended p_group_name to out
-- Added new param p_pgp_concat_segments - for sec asg procs
-- for others added p_concat_segments
  ,p_pgp_concat_segments	  in     varchar2 default null
  ,p_supervisor_assignment_id     in     number   default null
  ,p_group_name                      out nocopy varchar2
  ,p_assignment_id                   out nocopy number
  ,p_people_group_id                 out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_assignment_sequence             out nocopy number
  ,p_comment_id                      out nocopy number
  ,p_other_manager_warning           out nocopy boolean
  ,p_hourly_salaried_warning         out nocopy boolean
  ,p_cagr_grade_def_id               out nocopy number
  ,p_cagr_concatenated_segments      out nocopy varchar2
  );

--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_us_secondary_emp_asg >--------------------|
-- ----------------------------------------------------------------------------
--
-- This version of the API is now out-of-date however it has been provided to
-- you for backward compatibility support and will be removed in the future.
-- Oracle recommends you to modify existing calling programs in advance of the
-- support being withdrawn thus avoiding any potential disruption.
--
procedure create_us_secondary_emp_asg
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_person_id                    in     number
  ,p_organization_id              in     number
  ,p_grade_id                     in     number   default null
  ,p_position_id                  in     number   default null
  ,p_job_id                       in     number   default null
  ,p_assignment_status_type_id    in     number   default null
  ,p_payroll_id                   in     number   default null
  ,p_location_id                  in     number   default null
  ,p_supervisor_id                in     number   default null
  ,p_special_ceiling_step_id      in     number   default null
  ,p_pay_basis_id                 in     number   default null
  ,p_assignment_number            in out nocopy varchar2
  ,p_change_reason                in     varchar2 default null
  ,p_comments                     in     varchar2 default null
  ,p_date_probation_end           in     date     default null
  ,p_default_code_comb_id         in     number   default null
  ,p_employment_category          in     varchar2 default null
  ,p_frequency                    in     varchar2 default null
  ,p_internal_address_line        in     varchar2 default null
  ,p_manager_flag                 in     varchar2 default null
  ,p_normal_hours                 in     number   default null
  ,p_perf_review_period           in     number   default null
  ,p_perf_review_period_frequency in     varchar2 default null
  ,p_probation_period             in     number   default null
  ,p_probation_unit               in     varchar2 default null
  ,p_sal_review_period            in     number   default null
  ,p_sal_review_period_frequency  in     varchar2 default null
  ,p_set_of_books_id              in     number   default null
  ,p_source_type                  in     varchar2 default null
  ,p_time_normal_finish           in     varchar2 default null
  ,p_time_normal_start            in     varchar2 default null
  ,p_bargaining_unit_code         in     varchar2 default null
  ,p_labour_union_member_flag     in     varchar2 default 'N'
  ,p_hourly_salaried_code         in     varchar2 default null
  ,p_ass_attribute_category       in     varchar2 default null
  ,p_ass_attribute1               in     varchar2 default null
  ,p_ass_attribute2               in     varchar2 default null
  ,p_ass_attribute3               in     varchar2 default null
  ,p_ass_attribute4               in     varchar2 default null
  ,p_ass_attribute5               in     varchar2 default null
  ,p_ass_attribute6               in     varchar2 default null
  ,p_ass_attribute7               in     varchar2 default null
  ,p_ass_attribute8               in     varchar2 default null
  ,p_ass_attribute9               in     varchar2 default null
  ,p_ass_attribute10              in     varchar2 default null
  ,p_ass_attribute11              in     varchar2 default null
  ,p_ass_attribute12              in     varchar2 default null
  ,p_ass_attribute13              in     varchar2 default null
  ,p_ass_attribute14              in     varchar2 default null
  ,p_ass_attribute15              in     varchar2 default null
  ,p_ass_attribute16              in     varchar2 default null
  ,p_ass_attribute17              in     varchar2 default null
  ,p_ass_attribute18              in     varchar2 default null
  ,p_ass_attribute19              in     varchar2 default null
  ,p_ass_attribute20              in     varchar2 default null
  ,p_ass_attribute21              in     varchar2 default null
  ,p_ass_attribute22              in     varchar2 default null
  ,p_ass_attribute23              in     varchar2 default null
  ,p_ass_attribute24              in     varchar2 default null
  ,p_ass_attribute25              in     varchar2 default null
  ,p_ass_attribute26              in     varchar2 default null
  ,p_ass_attribute27              in     varchar2 default null
  ,p_ass_attribute28              in     varchar2 default null
  ,p_ass_attribute29              in     varchar2 default null
  ,p_ass_attribute30              in     varchar2 default null
  ,p_title                        in     varchar2 default null
  ,p_tax_unit                     in     varchar2 default null
  ,p_timecard_approver            in     varchar2 default null
  ,p_timecard_required            in     varchar2 default null
  ,p_work_schedule                in     varchar2 default null
  ,p_shift                        in     varchar2 default null
  ,p_spouse_salary                in     varchar2 default null
  ,p_legal_representative         in     varchar2 default null
  ,p_wc_override_code             in     varchar2 default null
  ,p_eeo_1_establishment          in     varchar2 default null
  ,p_pgp_segment1                 in     varchar2 default null
  ,p_pgp_segment2                 in     varchar2 default null
  ,p_pgp_segment3                 in     varchar2 default null
  ,p_pgp_segment4                 in     varchar2 default null
  ,p_pgp_segment5                 in     varchar2 default null
  ,p_pgp_segment6                 in     varchar2 default null
  ,p_pgp_segment7                 in     varchar2 default null
  ,p_pgp_segment8                 in     varchar2 default null
  ,p_pgp_segment9                 in     varchar2 default null
  ,p_pgp_segment10                in     varchar2 default null
  ,p_pgp_segment11                in     varchar2 default null
  ,p_pgp_segment12                in     varchar2 default null
  ,p_pgp_segment13                in     varchar2 default null
  ,p_pgp_segment14                in     varchar2 default null
  ,p_pgp_segment15                in     varchar2 default null
  ,p_pgp_segment16                in     varchar2 default null
  ,p_pgp_segment17                in     varchar2 default null
  ,p_pgp_segment18                in     varchar2 default null
  ,p_pgp_segment19                in     varchar2 default null
  ,p_pgp_segment20                in     varchar2 default null
  ,p_pgp_segment21                in     varchar2 default null
  ,p_pgp_segment22                in     varchar2 default null
  ,p_pgp_segment23                in     varchar2 default null
  ,p_pgp_segment24                in     varchar2 default null
  ,p_pgp_segment25                in     varchar2 default null
  ,p_pgp_segment26                in     varchar2 default null
  ,p_pgp_segment27                in     varchar2 default null
  ,p_pgp_segment28                in     varchar2 default null
  ,p_pgp_segment29                in     varchar2 default null
  ,p_pgp_segment30                in     varchar2 default null
-- Bug 944911
-- Amended p_group_name to out
-- Added new param p_pgp_concat_segments - for sec asg procs
-- for others added p_concat_segments
  ,p_pgp_concat_segments	  in     varchar2 default null
  ,p_supervisor_assignment_id     in     number   default null
  ,p_group_name                      out nocopy varchar2
  ,p_assignment_id                   out nocopy number
  ,p_soft_coding_keyflex_id          out nocopy number
  ,p_people_group_id                 out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_assignment_sequence             out nocopy number
  ,p_comment_id                      out nocopy number
-- Bug 944911
-- Changed concatenated_segments to be out from in out
-- added new param p_concat_segments ( in )
  ,p_concatenated_segments           out nocopy varchar2
  ,p_concat_segments                 in  varchar2 default null
  ,p_other_manager_warning           out nocopy boolean
  );

--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_us_secondary_emp_asg >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a secondary employee assignment for an employee in a United
 * States business group.
 *
 * This API cannot create a primary assignment.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The person and organization must exist at the effective start date of the
 * assignment. The business group should be in a United States legislation.
 *
 * <p><b>Post Success</b><br>
 * A new secondary assignment is created for the employee
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the assignment and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_person_id Identifies the person for whom you create the secondary
 * assignment record
 * @param p_organization_id Identifies the organization of the secondary
 * assignment
 * @param p_grade_id Identifies the grade of the secondary assignment
 * @param p_position_id Identifies the position of the secondary assignment
 * @param p_job_id Identifies the job of the secondary assignment
 * @param p_assignment_status_type_id Identifies the assignment status of the
 * secondary assignment.
 * @param p_payroll_id Identifies the payroll for the secondary assignment
 * @param p_location_id Identifies the location of the secondary assignment
 * @param p_supervisor_id Supervisor for the assignment. The value refers to
 * the supervisor's person record.
 * @param p_special_ceiling_step_id Highest allowed step for the grade scale
 * associated with the grade of the secondary assignment.
 * @param p_pay_basis_id Salary basis for the secondary assignment
 * @param p_assignment_number If a value is passed in, this is used as the
 * assignment number. If no value is passed in an assignment number is
 * generated.
 * @param p_change_reason Reason for the assignment status change. If there is
 * no change reason the parameter can be null. Valid values are defined in the
 * EMP_ASSIGN_REASON lookup type.
 * @param p_comments Comment text.
 * @param p_date_probation_end End date of probation period
 * @param p_default_code_comb_id Identifier for the General Ledger Accounting
 * Flexfield combination that applies to this assignment
 * @param p_employment_category Employment category. Valid values are defined
 * in the EMP_CAT lookup type.
 * @param p_frequency Frequency associated with the defined normal working
 * hours. Valid values are defined in the FREQUENCY lookup type.
 * @param p_internal_address_line Internal address identified with this
 * assignment.
 * @param p_manager_flag Indicates whether the employee is a manager
 * @param p_normal_hours Normal working hours for this assignment
 * @param p_perf_review_period Length of performance review period
 * @param p_perf_review_period_frequency Units of performance review period.
 * Valid values are defined in the FREQUENCY lookup type.
 * @param p_probation_period Length of probation period
 * @param p_probation_unit Units of probation period. Valid values are defined
 * in the QUALIFYING_UNITS lookup type.
 * @param p_sal_review_period Length of salary review period
 * @param p_sal_review_period_frequency Units of salary review period. Valid
 * values are defined in the FREQUENCY lookup type.
 * @param p_set_of_books_id Identifies General Ledger set of books.
 * @param p_source_type Recruitment activity that this assignment is sourced
 * from. Valid values are defined in the REC_TYPE lookup type.
 * @param p_time_normal_finish Normal work finish time
 * @param p_time_normal_start Normal work start time
 * @param p_bargaining_unit_code Code for bargaining unit. Valid values are
 * defined in the BARGAINING_UNIT_CODE lookup type.
 * @param p_labour_union_member_flag Value 'Y' indicates employee is a labour
 * union member. Other values indicate not a member.
 * @param p_hourly_salaried_code Identifies if the assignment is paid hourly or
 * is salaried. Valid values defined in the HOURLY_SALARIED_CODE lookup type.
 * @param p_ass_attribute_category This context value determines which
 * Flexfield Structure to use with the Descriptive flexfield segments.
 * @param p_ass_attribute1 Descriptive flexfield segment
 * @param p_ass_attribute2 Descriptive flexfield segment
 * @param p_ass_attribute3 Descriptive flexfield segment
 * @param p_ass_attribute4 Descriptive flexfield segment
 * @param p_ass_attribute5 Descriptive flexfield segment
 * @param p_ass_attribute6 Descriptive flexfield segment
 * @param p_ass_attribute7 Descriptive flexfield segment
 * @param p_ass_attribute8 Descriptive flexfield segment
 * @param p_ass_attribute9 Descriptive flexfield segment
 * @param p_ass_attribute10 Descriptive flexfield segment
 * @param p_ass_attribute11 Descriptive flexfield segment
 * @param p_ass_attribute12 Descriptive flexfield segment
 * @param p_ass_attribute13 Descriptive flexfield segment
 * @param p_ass_attribute14 Descriptive flexfield segment
 * @param p_ass_attribute15 Descriptive flexfield segment
 * @param p_ass_attribute16 Descriptive flexfield segment
 * @param p_ass_attribute17 Descriptive flexfield segment
 * @param p_ass_attribute18 Descriptive flexfield segment
 * @param p_ass_attribute19 Descriptive flexfield segment
 * @param p_ass_attribute20 Descriptive flexfield segment
 * @param p_ass_attribute21 Descriptive flexfield segment
 * @param p_ass_attribute22 Descriptive flexfield segment
 * @param p_ass_attribute23 Descriptive flexfield segment
 * @param p_ass_attribute24 Descriptive flexfield segment
 * @param p_ass_attribute25 Descriptive flexfield segment
 * @param p_ass_attribute26 Descriptive flexfield segment
 * @param p_ass_attribute27 Descriptive flexfield segment
 * @param p_ass_attribute28 Descriptive flexfield segment
 * @param p_ass_attribute29 Descriptive flexfield segment
 * @param p_ass_attribute30 Descriptive flexfield segment
 * @param p_title Obsolete parameter, do not use.
 * @param p_tax_unit Identifies the Government Reporting Entity (GRE)
 * associated with this secondary assignment.
 * @param p_timecard_approver Timecard Approver
 * @param p_timecard_required Indicates whether timecard is required
 * @param p_work_schedule Indicates the pattern of work for the secondary
 * assignment
 * @param p_shift Defines the shift information for this assignment. Valid
 * values are defined in US_SHIFTS lookup type.
 * @param p_spouse_salary Spouse's Salary
 * @param p_legal_representative Indicates if employee is a legal
 * representative
 * @param p_wc_override_code Workers Comp Override Code
 * @param p_eeo_1_establishment Reporting Establishment
 * @param p_pgp_segment1 People group key flexfield segment
 * @param p_pgp_segment2 People group key flexfield segment
 * @param p_pgp_segment3 People group key flexfield segment
 * @param p_pgp_segment4 People group key flexfield segment
 * @param p_pgp_segment5 People group key flexfield segment
 * @param p_pgp_segment6 People group key flexfield segment
 * @param p_pgp_segment7 People group key flexfield segment
 * @param p_pgp_segment8 People group key flexfield segment
 * @param p_pgp_segment9 People group key flexfield segment
 * @param p_pgp_segment10 People group key flexfield segment
 * @param p_pgp_segment11 People group key flexfield segment
 * @param p_pgp_segment12 People group key flexfield segment
 * @param p_pgp_segment13 People group key flexfield segment
 * @param p_pgp_segment14 People group key flexfield segment
 * @param p_pgp_segment15 People group key flexfield segment
 * @param p_pgp_segment16 People group key flexfield segment
 * @param p_pgp_segment17 People group key flexfield segment
 * @param p_pgp_segment18 People group key flexfield segment
 * @param p_pgp_segment19 People group key flexfield segment
 * @param p_pgp_segment20 People group key flexfield segment
 * @param p_pgp_segment21 People group key flexfield segment
 * @param p_pgp_segment22 People group key flexfield segment
 * @param p_pgp_segment23 People group key flexfield segment
 * @param p_pgp_segment24 People group key flexfield segment
 * @param p_pgp_segment25 People group key flexfield segment
 * @param p_pgp_segment26 People group key flexfield segment
 * @param p_pgp_segment27 People group key flexfield segment
 * @param p_pgp_segment28 People group key flexfield segment
 * @param p_pgp_segment29 People group key flexfield segment
 * @param p_pgp_segment30 People group key flexfield segment
 * @param p_pgp_concat_segments Concatenated segments for People Group Key
 * Flexfield. Concatenated segments can be supplied instead of individual
 * segments.
 * @param p_supervisor_assignment_id Supervisor's assignment which is
 * responsible for supervising this assignment.
 * @param p_group_name If p_validate is false, set to the People Group Key
 * Flexfield concatenated segments. If p_validate is true, set to null.
 * @param p_assignment_id If p_validate is false, then this uniquely identifies
 * the created assignment. If p_validate is true, then set to null.
 * @param p_soft_coding_keyflex_id If p_validate is false, then this uniquely
 * identifies the associated combination of the Soft Coded Key flexfield for
 * this assignment. If p_validate is true, then set to null.
 * @param p_people_group_id If p_validate is false, then this uniquely
 * identifies the associated combination of the People Group Key flexfield for
 * this assignment. If p_validate is true, then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created assignment. If p_validate is true, then the
 * value will be null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created assignment. If p_validate is
 * true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created assignment. If p_validate is true, then
 * set to null.
 * @param p_assignment_sequence If p_validate is false, then an automatically
 * incremented number is associated with this assignment, depending on the
 * number of assignment which already exist. If p_validate is true then set to
 * null.
 * @param p_comment_id If p_validate is false and comment text was provided,
 * then will be set to the identifier of the created assignment comment record.
 * If p_validate is true or no comment text was provided, then will be null.
 * @param p_concatenated_segments If p_validate is false, set to Soft Coded Key
 * Flexfield concatenated segments, if p_validate is true, set to null.
 * @param p_concat_segments Concatenated segments for Soft Coded Key Flexfield.
 * Concatenated segments can be supplied instead of individual segments.
 * @param p_other_manager_warning If set to true, then a manager existed in the
 * organization prior to calling this API and the manager flag has been set to
 * 'Y' for yes.
 * @param p_hourly_salaried_warning Set to true if values entered for Salary
 * Basis and Hourly Salaried Code are invalid as of p_effective_date.
 * @param p_cagr_grade_def_id If a value is passed in for this parameter, it
 * identifies an existing CAGR Key Flexfield combination to associate with the
 * assignment, and segment values are ignored. If a value is not passed in,
 * then the individual CAGR Key Flexfield segments supplied will be used to
 * choose an existing combination or create a new combination. When the API
 * completes, if p_validate is false, then this uniquely identifies the
 * associated combination of the CAGR Key flexfield for this assignment. If
 * p_validate is true, then set to null.
 * @param p_cagr_concatenated_segments CAGR Key Flexfield concatenated segments
 * @rep:displayname Create Secondary Employee Assignment for United States
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE_ASG
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_us_secondary_emp_asg
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_person_id                    in     number
  ,p_organization_id              in     number
  ,p_grade_id                     in     number   default null
  ,p_position_id                  in     number   default null
  ,p_job_id                       in     number   default null
  ,p_assignment_status_type_id    in     number   default null
  ,p_payroll_id                   in     number   default null
  ,p_location_id                  in     number   default null
  ,p_supervisor_id                in     number   default null
  ,p_special_ceiling_step_id      in     number   default null
  ,p_pay_basis_id                 in     number   default null
  ,p_assignment_number            in out nocopy varchar2
  ,p_change_reason                in     varchar2 default null
  ,p_comments                     in     varchar2 default null
  ,p_date_probation_end           in     date     default null
  ,p_default_code_comb_id         in     number   default null
  ,p_employment_category          in     varchar2 default null
  ,p_frequency                    in     varchar2 default null
  ,p_internal_address_line        in     varchar2 default null
  ,p_manager_flag                 in     varchar2 default null
  ,p_normal_hours                 in     number   default null
  ,p_perf_review_period           in     number   default null
  ,p_perf_review_period_frequency in     varchar2 default null
  ,p_probation_period             in     number   default null
  ,p_probation_unit               in     varchar2 default null
  ,p_sal_review_period            in     number   default null
  ,p_sal_review_period_frequency  in     varchar2 default null
  ,p_set_of_books_id              in     number   default null
  ,p_source_type                  in     varchar2 default null
  ,p_time_normal_finish           in     varchar2 default null
  ,p_time_normal_start            in     varchar2 default null
  ,p_bargaining_unit_code         in     varchar2 default null
  ,p_labour_union_member_flag     in     varchar2 default 'N'
  ,p_hourly_salaried_code         in     varchar2 default null
  ,p_ass_attribute_category       in     varchar2 default null
  ,p_ass_attribute1               in     varchar2 default null
  ,p_ass_attribute2               in     varchar2 default null
  ,p_ass_attribute3               in     varchar2 default null
  ,p_ass_attribute4               in     varchar2 default null
  ,p_ass_attribute5               in     varchar2 default null
  ,p_ass_attribute6               in     varchar2 default null
  ,p_ass_attribute7               in     varchar2 default null
  ,p_ass_attribute8               in     varchar2 default null
  ,p_ass_attribute9               in     varchar2 default null
  ,p_ass_attribute10              in     varchar2 default null
  ,p_ass_attribute11              in     varchar2 default null
  ,p_ass_attribute12              in     varchar2 default null
  ,p_ass_attribute13              in     varchar2 default null
  ,p_ass_attribute14              in     varchar2 default null
  ,p_ass_attribute15              in     varchar2 default null
  ,p_ass_attribute16              in     varchar2 default null
  ,p_ass_attribute17              in     varchar2 default null
  ,p_ass_attribute18              in     varchar2 default null
  ,p_ass_attribute19              in     varchar2 default null
  ,p_ass_attribute20              in     varchar2 default null
  ,p_ass_attribute21              in     varchar2 default null
  ,p_ass_attribute22              in     varchar2 default null
  ,p_ass_attribute23              in     varchar2 default null
  ,p_ass_attribute24              in     varchar2 default null
  ,p_ass_attribute25              in     varchar2 default null
  ,p_ass_attribute26              in     varchar2 default null
  ,p_ass_attribute27              in     varchar2 default null
  ,p_ass_attribute28              in     varchar2 default null
  ,p_ass_attribute29              in     varchar2 default null
  ,p_ass_attribute30              in     varchar2 default null
  ,p_title                        in     varchar2 default null
  ,p_tax_unit                     in     varchar2 default null
  ,p_timecard_approver            in     varchar2 default null
  ,p_timecard_required            in     varchar2 default null
  ,p_work_schedule                in     varchar2 default null
  ,p_shift                        in     varchar2 default null
  ,p_spouse_salary                in     varchar2 default null
  ,p_legal_representative         in     varchar2 default null
  ,p_wc_override_code             in     varchar2 default null
  ,p_eeo_1_establishment          in     varchar2 default null
  ,p_pgp_segment1                 in     varchar2 default null
  ,p_pgp_segment2                 in     varchar2 default null
  ,p_pgp_segment3                 in     varchar2 default null
  ,p_pgp_segment4                 in     varchar2 default null
  ,p_pgp_segment5                 in     varchar2 default null
  ,p_pgp_segment6                 in     varchar2 default null
  ,p_pgp_segment7                 in     varchar2 default null
  ,p_pgp_segment8                 in     varchar2 default null
  ,p_pgp_segment9                 in     varchar2 default null
  ,p_pgp_segment10                in     varchar2 default null
  ,p_pgp_segment11                in     varchar2 default null
  ,p_pgp_segment12                in     varchar2 default null
  ,p_pgp_segment13                in     varchar2 default null
  ,p_pgp_segment14                in     varchar2 default null
  ,p_pgp_segment15                in     varchar2 default null
  ,p_pgp_segment16                in     varchar2 default null
  ,p_pgp_segment17                in     varchar2 default null
  ,p_pgp_segment18                in     varchar2 default null
  ,p_pgp_segment19                in     varchar2 default null
  ,p_pgp_segment20                in     varchar2 default null
  ,p_pgp_segment21                in     varchar2 default null
  ,p_pgp_segment22                in     varchar2 default null
  ,p_pgp_segment23                in     varchar2 default null
  ,p_pgp_segment24                in     varchar2 default null
  ,p_pgp_segment25                in     varchar2 default null
  ,p_pgp_segment26                in     varchar2 default null
  ,p_pgp_segment27                in     varchar2 default null
  ,p_pgp_segment28                in     varchar2 default null
  ,p_pgp_segment29                in     varchar2 default null
  ,p_pgp_segment30                in     varchar2 default null
-- Bug 944911
-- Amended p_group_name to out
-- Added new param p_pgp_concat_segments - for sec asg procs
-- for others added p_concat_segments
  ,p_pgp_concat_segments	  in     varchar2 default null
  ,p_supervisor_assignment_id     in     number   default null
  ,p_group_name                      out nocopy varchar2
  ,p_assignment_id                   out nocopy number
  ,p_soft_coding_keyflex_id          out nocopy number
  ,p_people_group_id                 out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_assignment_sequence             out nocopy number
  ,p_comment_id                      out nocopy number
-- Bug 944911
-- Changed concatenated_segments to be out from in out
-- added new param p_concat_segments ( in )
  ,p_concatenated_segments           out nocopy varchar2
  ,p_concat_segments                 in  varchar2 default null
  ,p_other_manager_warning           out nocopy boolean
  ,p_hourly_salaried_warning         out nocopy boolean
  ,p_cagr_grade_def_id               out nocopy number
  ,p_cagr_concatenated_segments      out nocopy varchar2
  );

--
-- ----------------------------------------------------------------------------
-- |--------------------------< final_process_emp_asg >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API terminates any assignment except the primary assignment.
 *
 * This API carries out the second step in terminating an individual employee
 * assignment. The employee assignment must already have an actual termination
 * date. The actual termination date is derived from the date when the
 * assignment status first changes to a TERM_ASSIGN system status. Element
 * entries for the assignment that have an element termination rule of 'Final
 * Close' are ended as of the final process date. Element entries for the
 * assignment that have an element termination rule of 'Last Standard Process'
 * are ended as of the final process date, if the last standard process date is
 * later than the final process date. Any cost allocations, grade step/point
 * placements, cobra coverage benefits and personal payment methods for this
 * assignment are ended as of the final process date.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The assignment must be a secondary employee assignment. The assignment must
 * already have been terminated by a previous call to
 * actual_termination_emp_asg.
 *
 * <p><b>Post Success</b><br>
 * The API ends the assignment on the final process date and ends any
 * associated element entries.
 *
 * <p><b>Post Failure</b><br>
 * The API does not end the assignment or element entries and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_assignment_id Identifies the assignment record to be modified.
 * @param p_object_version_number Pass in the current version number of the
 * assignment to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated assignment. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_final_process_date The last date on which the assignment should
 * exist.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated assignment row which now exists as of
 * the effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated assignment row which now exists as of the
 * effective date. If p_validate is true, then set to null.
 * @param p_org_now_no_manager_warning Set to true if this assignment had the
 * manager flag set to 'Y' and there are no other managers in the assignment's
 * organization. Set to false if there is another manager in the assignment's
 * organization or if this assignment did not have the manager flag set to 'Y'.
 * The warning value only applies as of the final process date.
 * @param p_asg_future_changes_warning Set to true if at least one assignment
 * change, after the final process date, has been deleted as a result of
 * terminating the assignment. (The only valid change after the actual
 * termination date is setting the assignment status to another TERM_ASSIGN
 * status.) Set to false when there were no changes after final process date.
 * @param p_entries_changed_warning Set to 'Y' when at least one element entry
 * was altered due to the assignment change. Set to 'S' if at least one salary
 * element entry was affected. This is a more specific case than 'Y'. Otherwise
 * set to 'N', when no element entries were changed.
 * @rep:displayname Final Process Employee Assignment
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE_ASG
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure final_process_emp_asg
  (p_validate                      in     boolean  default false
  ,p_assignment_id                 in     number
  ,p_object_version_number         in out nocopy number
  ,p_final_process_date            in     date
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date               out nocopy date
  ,p_org_now_no_manager_warning       out nocopy boolean
  ,p_asg_future_changes_warning       out nocopy boolean
  ,p_entries_changed_warning          out nocopy varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< suspend_emp_asg >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API changes the status of an employee assignment to a "Suspended"
 * status.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The assignment must be an employee assignment, and must exist on the
 * effective date.
 *
 * <p><b>Post Success</b><br>
 * The employee assignment will be set to a suspended status.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the assignment and raises an error.
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
 * @param p_assignment_id Identifies the assignment record to be modified.
 * @param p_change_reason Reason for the assignment status change. If there is
 * no change reason the parameter can be null. Valid values are defined in the
 * EMP_ASSIGN_REASON lookup type.
 * @param p_object_version_number Pass in the current version number of the
 * assignment to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated assignment. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_assignment_status_type_id The new assignment status. The new status
 * must have a system status of SUSP_ASSIGN. If the assignment status is
 * already a type of SUSP_ASSIGN this API can be used to set a different
 * suspend status. If this parameter is not explicitly passed, the API uses the
 * default SUSP_ASSIGN status for the assignment's business group.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated assignment row which now exists as of
 * the effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated assignment row which now exists as of the
 * effective date. If p_validate is true, then set to null.
 * @rep:displayname Suspend Employee Assignment
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE_ASG
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure suspend_emp_asg
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_change_reason                in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  ,p_assignment_status_type_id    in     number   default hr_api.g_number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_cwk_asg >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates contingent worker assignment.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The assignment must exist as of the effective date, and must be a contingent
 * worker assignment.
 *
 * <p><b>Post Success</b><br>
 * The API updates the assignment.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the assignment and raises an error.
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
 * @param p_assignment_id Identifies the assignment record to be updated.
 * @param p_object_version_number Pass in the current version number of the
 * assignment to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated assignment. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_assignment_category Assignment Category. Valid values are defined
 * in the CWK_ASG_CATEGORY lookup type.
 * @param p_assignment_number Assignment Number
 * @param p_change_reason Reason for the assignment status change. If there is
 * no change reason the parameter can be null. Valid values are defined in the
 * CWK_ASSIGN_REASON lookup_type.
 * @param p_comments Comment text.
 * @param p_default_code_comb_id Identifier for the General Ledger Accounting
 * Flexfield combination that applies to this assignment
 * @param p_establishment_id For French business groups, this identifies the
 * Establishment Legal Entity for this assignment.
 * @param p_frequency Frequency associated with the defined normal working
 * hours. Valid values are defined in the FREQUENCY lookup type.
 * @param p_internal_address_line Internal address identified with this
 * assignment.
 * @param p_labour_union_member_flag Labour union member
 * @param p_manager_flag Indicates whether the contingent worker is a manager
 * @param p_normal_hours Normal working hours for this assignment
 * @param p_project_title Project title
 * @param p_set_of_books_id Identifies General Ledger set of books.
 * @param p_source_type Recruitment activity which this assignment is sourced
 * from. Valid values are defined in the REC_TYPE lookup type.
 * @param p_supervisor_id Supervisor for the assignment. The value refers to
 * the supervisor's person record.
 * @param p_time_normal_finish Normal work finish time
 * @param p_time_normal_start Normal work start time
 * @param p_title Obsolete parameter, do not use.
 * @param p_vendor_assignment_number Identification number given by the
 * supplier to the contingent worker's assignment
 * @param p_vendor_employee_number Identification number given by the supplier
 * to the contingent worker
 * @param p_vendor_id Identifier of the Supplier of the contingent worker from
 * iProcurement
 * @param p_vendor_site_id Identifier of the Supplier site of the contingent
 * worker from iProcurement
 * @param p_po_header_id Identifier of the Purchase Order under which this
 * contingent workers assignment is being paid, from iProcurement
 * @param p_po_line_id Identifier of the Purchase Order Line under which this
 * contingent workers assignment is being paid, from iProcurement
 * @param p_projected_assignment_end Projected end date of this assignment.
 * @param p_assignment_status_type_id Assignment status. The system status must
 * be the same as before the update. Otherwise one of the status change APIs
 * should be used.
 * @param p_concat_segments Concatenated segments for Soft Coded Key Flexfield.
 * Concatenated segments can be supplied instead of individual segments.
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
 * @param p_scl_segment1 Soft Coded key flexfield segment
 * @param p_scl_segment2 Soft Coded key flexfield segment
 * @param p_scl_segment3 Soft Coded key flexfield segment
 * @param p_scl_segment4 Soft Coded key flexfield segment
 * @param p_scl_segment5 Soft Coded key flexfield segment
 * @param p_scl_segment6 Soft Coded key flexfield segment
 * @param p_scl_segment7 Soft Coded key flexfield segment
 * @param p_scl_segment8 Soft Coded key flexfield segment
 * @param p_scl_segment9 Soft Coded key flexfield segment
 * @param p_scl_segment10 Soft Coded key flexfield segment
 * @param p_scl_segment11 Soft Coded key flexfield segment
 * @param p_scl_segment12 Soft Coded key flexfield segment
 * @param p_scl_segment13 Soft Coded key flexfield segment
 * @param p_scl_segment14 Soft Coded key flexfield segment
 * @param p_scl_segment15 Soft Coded key flexfield segment
 * @param p_scl_segment16 Soft Coded key flexfield segment
 * @param p_scl_segment17 Soft Coded key flexfield segment
 * @param p_scl_segment18 Soft Coded key flexfield segment
 * @param p_scl_segment19 Soft Coded key flexfield segment
 * @param p_scl_segment20 Soft Coded key flexfield segment
 * @param p_scl_segment21 Soft Coded key flexfield segment
 * @param p_scl_segment22 Soft Coded key flexfield segment
 * @param p_scl_segment23 Soft Coded key flexfield segment
 * @param p_scl_segment24 Soft Coded key flexfield segment
 * @param p_scl_segment25 Soft Coded key flexfield segment
 * @param p_scl_segment26 Soft Coded key flexfield segment
 * @param p_scl_segment27 Soft Coded key flexfield segment
 * @param p_scl_segment28 Soft Coded key flexfield segment
 * @param p_scl_segment29 Soft Coded key flexfield segment
 * @param p_scl_segment30 Soft Coded key flexfield segment
 * @param p_supervisor_assignment_id Supervisor's assignment that is
 * responsible for supervising this assignment.
 * @param p_org_now_no_manager_warning Set to true if as a result of the update
 * there is no manager in the organization. Otherwise set to false.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created assignment. If p_validate is
 * true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created assignment. If p_validate is true, then
 * set to null.
 * @param p_comment_id If p_validate is false and comment text was provided,
 * then will be set to the identifier of the created assignment comment record.
 * If p_validate is true or no comment text was provided, then will be null.
 * @param p_no_managers_warning Set to true if as a result of the update there
 * is no manager in the organization. Otherwise set to false.
 * @param p_other_manager_warning If set to true, then a manager existed in the
 * organization prior to calling this API and the manager flag has been set to
 * 'Y' for yes.
 * @param p_soft_coding_keyflex_id If p_validate is false, then this uniquely
 * identifies the associated combination of the Soft Coded Key flexfield for
 * this assignment. If p_validate is true, then set to null.
 * @param p_concatenated_segments If p_validate is false, set to Soft Coded Key
 * Flexfield concatenated segments, if p_validate is true, set to null.
 * @param p_hourly_salaried_warning Set to true if values entered for Salary
 * Basis and Hourly Salaried Code are invalid date as of p_effective_date.
 * @rep:displayname Update Contingent Worker Assignment
 * @rep:category BUSINESS_ENTITY PER_CWK_ASG
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
  procedure update_cwk_asg
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_assignment_category          in     varchar2 default hr_api.g_varchar2
  ,p_assignment_number            in     varchar2 default hr_api.g_varchar2
  ,p_change_reason                in     varchar2 default hr_api.g_varchar2
  ,p_comments                     in     varchar2 default hr_api.g_varchar2
  ,p_default_code_comb_id         in     number   default hr_api.g_number
  ,p_establishment_id             in     number   default hr_api.g_number
  ,p_frequency                    in     varchar2 default hr_api.g_varchar2
  ,p_internal_address_line        in     varchar2 default hr_api.g_varchar2
  ,p_labour_union_member_flag     in     varchar2 default hr_api.g_varchar2
  ,p_manager_flag                 in     varchar2 default hr_api.g_varchar2
  ,p_normal_hours                 in     number   default hr_api.g_number
  ,p_project_title                in     varchar2 default hr_api.g_varchar2
  ,p_set_of_books_id              in     number   default hr_api.g_number
  ,p_source_type                  in     varchar2 default hr_api.g_varchar2
  ,p_supervisor_id                in     number   default hr_api.g_number
  ,p_time_normal_finish           in     varchar2 default hr_api.g_varchar2
  ,p_time_normal_start            in     varchar2 default hr_api.g_varchar2
  ,p_title                        in     varchar2 default hr_api.g_varchar2
  ,p_vendor_assignment_number     in     varchar2 default hr_api.g_varchar2
  ,p_vendor_employee_number       in     varchar2 default hr_api.g_varchar2
  ,p_vendor_id                    in     number   default hr_api.g_number
  ,p_vendor_site_id               in     number   default hr_api.g_number
  ,p_po_header_id                 in     number   default hr_api.g_number
  ,p_po_line_id                   in     number   default hr_api.g_number
  ,p_projected_assignment_end     in     date     default hr_api.g_date
  ,p_assignment_status_type_id    in     number   default hr_api.g_number
  ,p_concat_segments              in     varchar2 default null
  ,p_attribute_category           in     varchar2 default hr_api.g_varchar2
  ,p_attribute1                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute2                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute3                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute4                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute5                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute6                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute7                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute8                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute9                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute10                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute11                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute12                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute13                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute14                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute15                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute16                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute17                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute18                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute19                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute20                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute21                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute22                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute23                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute24                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute25                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute26                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute27                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute28                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute29                  in     varchar2 default hr_api.g_varchar2
  ,p_attribute30                  in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment1                 in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment2                 in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment3                 in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment4                 in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment5                 in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment6                 in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment7                 in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment8                 in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment9                 in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment10                in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment11                in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment12                in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment13                in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment14                in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment15                in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment16                in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment17                in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment18                in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment19                in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment20                in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment21                in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment22                in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment23                in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment24                in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment25                in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment26                in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment27                in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment28                in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment29                in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment30                in     varchar2 default hr_api.g_varchar2
  ,p_supervisor_assignment_id     in     number   default hr_api.g_number
  ,p_org_now_no_manager_warning      out nocopy boolean
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_comment_id                      out nocopy number
  ,p_no_managers_warning             out nocopy boolean
  ,p_other_manager_warning           out nocopy boolean
  ,p_soft_coding_keyflex_id          out nocopy number
  ,p_concatenated_segments           out nocopy varchar2
  ,p_hourly_salaried_warning         out nocopy boolean);

--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_cwk_asg_criteria >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates attributes of a contingent worker assignment that may
 * affect the entitlement to element entries - currently Contingent Workers may
 * not have element entries so this API is reserved for future use.
 *
 * To update other attributes, use the API update_cwk_asg. Contingent Workers
 * are not entitled to element entries, this API is provided for future
 * compatibility.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The assignment must be an contingent worker assignment. The assignment must
 * exist as of the effective date of the change
 *
 * <p><b>Post Success</b><br>
 * The API updates the attributes of assignment.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the assignment and raises an error.
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
 * @param p_assignment_id Identifies the assignment record to be modified.
 * @param p_called_from_mass_update Set to TRUE if the API is called from the
 * Mass Update Processes. This defaults Job and Organization information from
 * the Position information, if the first two are not supplied.
 * @param p_object_version_number Pass in the current version number of the
 * assignment to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated assignment. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_grade_id Identifies the grade of the assignment
 * @param p_position_id Identifies the position of the assignment
 * @param p_job_id Identifies the job of the assignment
 * @param p_location_id Identifies the location of the assignment
 * @param p_organization_id Identifies the organization of the assignment
 * @param p_pay_basis_id Salary basis for the assignment
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
 * @param p_concat_segments Concatenated Key Flexfield segments
 * @param p_people_group_name Concatenated Key Flexfield segments
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated assignment row which now exists as of
 * the effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated assignment row which now exists as of the
 * effective date. If p_validate is true, then set to null.
 * @param p_people_group_id Identifier of the People Group Key Flexfield
 * combinations row associated with the segments passed.
 * @param p_org_now_no_manager_warning Set to true if this assignment is a
 * manager, the organization is updated and there is now no manager in the
 * previous organization. Set to false if another manager exists in the
 * previous organization.
 * @param p_other_manager_warning If set to true, then a manager existed in the
 * organization prior to calling this API and the manager flag has been set to
 * 'Y' for yes.
 * @param p_spp_delete_warning Set to true when grade step and point placements
 * are date effectively ended or purged by the update of the assignment. Both
 * types of change occur when the Grade is changed and spinal point placements
 * exist over the updated date range. Set to false when no grade step and point
 * placements are affected.
 * @param p_entries_changed_warning Always set to 'N'. Contingent Workers are
 * not entitled to element entries so no entries can be changed as a result of
 * the update.
 * @param p_tax_district_changed_warning Always set to False, since contingent
 * worker assignments are not eligible to have a Payroll, therefore cannot be
 * included in the United Kingdom processing which determines the value of this
 * parameter.
 * @rep:displayname Update Contingent Worker Assignment Criteria
 * @rep:category BUSINESS_ENTITY PER_CWK_ASG
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_cwk_asg_criteria
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_called_from_mass_update      in     boolean  default false
  ,p_object_version_number        in out nocopy number
  ,p_grade_id                     in     number   default hr_api.g_number
  ,p_position_id                  in     number   default hr_api.g_number
  ,p_job_id                       in     number   default hr_api.g_number
  --
  -- p_payroll_id included for future phases of cwk
  --
  --,p_payroll_id                   in     number   default hr_api.g_number
  ,p_location_id                  in     number   default hr_api.g_number
  ,p_organization_id              in     number   default hr_api.g_number
  --
  -- p_pay_basis_id included for future phases of cwk
  --
  ,p_pay_basis_id                 in     number   default hr_api.g_number
  ,p_segment1                     in     varchar2 default hr_api.g_varchar2
  ,p_segment2                     in     varchar2 default hr_api.g_varchar2
  ,p_segment3                     in     varchar2 default hr_api.g_varchar2
  ,p_segment4                     in     varchar2 default hr_api.g_varchar2
  ,p_segment5                     in     varchar2 default hr_api.g_varchar2
  ,p_segment6                     in     varchar2 default hr_api.g_varchar2
  ,p_segment7                     in     varchar2 default hr_api.g_varchar2
  ,p_segment8                     in     varchar2 default hr_api.g_varchar2
  ,p_segment9                     in     varchar2 default hr_api.g_varchar2
  ,p_segment10                    in     varchar2 default hr_api.g_varchar2
  ,p_segment11                    in     varchar2 default hr_api.g_varchar2
  ,p_segment12                    in     varchar2 default hr_api.g_varchar2
  ,p_segment13                    in     varchar2 default hr_api.g_varchar2
  ,p_segment14                    in     varchar2 default hr_api.g_varchar2
  ,p_segment15                    in     varchar2 default hr_api.g_varchar2
  ,p_segment16                    in     varchar2 default hr_api.g_varchar2
  ,p_segment17                    in     varchar2 default hr_api.g_varchar2
  ,p_segment18                    in     varchar2 default hr_api.g_varchar2
  ,p_segment19                    in     varchar2 default hr_api.g_varchar2
  ,p_segment20                    in     varchar2 default hr_api.g_varchar2
  ,p_segment21                    in     varchar2 default hr_api.g_varchar2
  ,p_segment22                    in     varchar2 default hr_api.g_varchar2
  ,p_segment23                    in     varchar2 default hr_api.g_varchar2
  ,p_segment24                    in     varchar2 default hr_api.g_varchar2
  ,p_segment25                    in     varchar2 default hr_api.g_varchar2
  ,p_segment26                    in     varchar2 default hr_api.g_varchar2
  ,p_segment27                    in     varchar2 default hr_api.g_varchar2
  ,p_segment28                    in     varchar2 default hr_api.g_varchar2
  ,p_segment29                    in     varchar2 default hr_api.g_varchar2
  ,p_segment30                    in     varchar2 default hr_api.g_varchar2
  ,p_concat_segments              in     varchar2 default hr_api.g_varchar2
  ,p_people_group_name               out nocopy varchar2
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_people_group_id                 out nocopy number
  ,p_org_now_no_manager_warning      out nocopy boolean
  ,p_other_manager_warning           out nocopy boolean
  ,p_spp_delete_warning              out nocopy boolean
  --
  -- p_entries_changed_warning included for future phases of cwk
  --
  ,p_entries_changed_warning         out nocopy varchar2
  ,p_tax_district_changed_warning    out nocopy boolean
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_emp_asg >--------------------------|
-- ----------------------------------------------------------------------------
--
-- This version of the API is now out-of-date however it has been provided to
-- you for backward compatibility support and will be removed in the future.
-- Oracle recommends you to modify existing calling programs in advance of the
-- support being withdrawn thus avoiding any potential disruption.
--
procedure update_emp_asg
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_supervisor_id                in     number   default hr_api.g_number
  ,p_assignment_number            in     varchar2 default hr_api.g_varchar2
  ,p_change_reason                in     varchar2 default hr_api.g_varchar2
  ,p_comments                     in     varchar2 default hr_api.g_varchar2
  ,p_date_probation_end           in     date     default hr_api.g_date
  ,p_default_code_comb_id         in     number   default hr_api.g_number
  ,p_frequency                    in     varchar2 default hr_api.g_varchar2
  ,p_internal_address_line        in     varchar2 default hr_api.g_varchar2
  ,p_manager_flag                 in     varchar2 default hr_api.g_varchar2
  ,p_normal_hours                 in     number   default hr_api.g_number
  ,p_perf_review_period           in     number   default hr_api.g_number
  ,p_perf_review_period_frequency in     varchar2 default hr_api.g_varchar2
  ,p_probation_period             in     number   default hr_api.g_number
  ,p_probation_unit               in     varchar2 default hr_api.g_varchar2
  ,p_sal_review_period            in     number   default hr_api.g_number
  ,p_sal_review_period_frequency  in     varchar2 default hr_api.g_varchar2
  ,p_set_of_books_id              in     number   default hr_api.g_number
  ,p_source_type                  in     varchar2 default hr_api.g_varchar2
  ,p_time_normal_finish           in     varchar2 default hr_api.g_varchar2
  ,p_time_normal_start            in     varchar2 default hr_api.g_varchar2
  ,p_bargaining_unit_code         in     varchar2 default hr_api.g_varchar2
  ,p_labour_union_member_flag     in     varchar2 default hr_api.g_varchar2
  ,p_hourly_salaried_code         in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute_category       in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute1               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute2               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute3               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute4               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute5               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute6               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute7               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute8               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute9               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute10              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute11              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute12              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute13              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute14              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute15              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute16              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute17              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute18              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute19              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute20              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute21              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute22              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute23              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute24              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute25              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute26              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute27              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute28              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute29              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute30              in     varchar2 default hr_api.g_varchar2
  ,p_title                        in     varchar2 default hr_api.g_varchar2
  ,p_segment1                     in     varchar2 default hr_api.g_varchar2
  ,p_segment2                     in     varchar2 default hr_api.g_varchar2
  ,p_segment3                     in     varchar2 default hr_api.g_varchar2
  ,p_segment4                     in     varchar2 default hr_api.g_varchar2
  ,p_segment5                     in     varchar2 default hr_api.g_varchar2
  ,p_segment6                     in     varchar2 default hr_api.g_varchar2
  ,p_segment7                     in     varchar2 default hr_api.g_varchar2
  ,p_segment8                     in     varchar2 default hr_api.g_varchar2
  ,p_segment9                     in     varchar2 default hr_api.g_varchar2
  ,p_segment10                    in     varchar2 default hr_api.g_varchar2
  ,p_segment11                    in     varchar2 default hr_api.g_varchar2
  ,p_segment12                    in     varchar2 default hr_api.g_varchar2
  ,p_segment13                    in     varchar2 default hr_api.g_varchar2
  ,p_segment14                    in     varchar2 default hr_api.g_varchar2
  ,p_segment15                    in     varchar2 default hr_api.g_varchar2
  ,p_segment16                    in     varchar2 default hr_api.g_varchar2
  ,p_segment17                    in     varchar2 default hr_api.g_varchar2
  ,p_segment18                    in     varchar2 default hr_api.g_varchar2
  ,p_segment19                    in     varchar2 default hr_api.g_varchar2
  ,p_segment20                    in     varchar2 default hr_api.g_varchar2
  ,p_segment21                    in     varchar2 default hr_api.g_varchar2
  ,p_segment22                    in     varchar2 default hr_api.g_varchar2
  ,p_segment23                    in     varchar2 default hr_api.g_varchar2
  ,p_segment24                    in     varchar2 default hr_api.g_varchar2
  ,p_segment25                    in     varchar2 default hr_api.g_varchar2
  ,p_segment26                    in     varchar2 default hr_api.g_varchar2
  ,p_segment27                    in     varchar2 default hr_api.g_varchar2
  ,p_segment28                    in     varchar2 default hr_api.g_varchar2
  ,p_segment29                    in     varchar2 default hr_api.g_varchar2
  ,p_segment30                    in     varchar2 default hr_api.g_varchar2
-- Bug fix for 944911
-- p_concatenated_segments has been changed from in out to out
-- Added new param p_concat_segments as in param
  ,p_concat_segments              in     varchar2 default hr_api.g_varchar2
  ,p_supervisor_assignment_id     in     number   default hr_api.g_number
  ,p_concatenated_segments           out nocopy varchar2
-- bug 2359997 p_soft_coding_keyflex_id changed from out to in out
  ,p_soft_coding_keyflex_id       in out nocopy number
  ,p_comment_id                      out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_no_managers_warning             out nocopy boolean
  ,p_other_manager_warning           out nocopy boolean
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_emp_asg >--------------------------|
-- ----------------------------------------------------------------------------
--
-- This version of the API is now out-of-date however it has been provided to
-- you for backward compatibility support and will be removed in the future.
-- Oracle recommends you to modify existing calling programs in advance of the
-- support being withdrawn thus avoiding any potential disruption.
--
procedure update_emp_asg
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_supervisor_id                in     number   default hr_api.g_number
  ,p_assignment_number            in     varchar2 default hr_api.g_varchar2
  ,p_change_reason                in     varchar2 default hr_api.g_varchar2
  ,p_assignment_status_type_id    in     number   default hr_api.g_number
  ,p_comments                     in     varchar2 default hr_api.g_varchar2
  ,p_date_probation_end           in     date     default hr_api.g_date
  ,p_default_code_comb_id         in     number   default hr_api.g_number
  ,p_frequency                    in     varchar2 default hr_api.g_varchar2
  ,p_internal_address_line        in     varchar2 default hr_api.g_varchar2
  ,p_manager_flag                 in     varchar2 default hr_api.g_varchar2
  ,p_normal_hours                 in     number   default hr_api.g_number
  ,p_perf_review_period           in     number   default hr_api.g_number
  ,p_perf_review_period_frequency in     varchar2 default hr_api.g_varchar2
  ,p_probation_period             in     number   default hr_api.g_number
  ,p_probation_unit               in     varchar2 default hr_api.g_varchar2
  ,p_sal_review_period            in     number   default hr_api.g_number
  ,p_sal_review_period_frequency  in     varchar2 default hr_api.g_varchar2
  ,p_set_of_books_id              in     number   default hr_api.g_number
  ,p_source_type                  in     varchar2 default hr_api.g_varchar2
  ,p_time_normal_finish           in     varchar2 default hr_api.g_varchar2
  ,p_time_normal_start            in     varchar2 default hr_api.g_varchar2
  ,p_bargaining_unit_code         in     varchar2 default hr_api.g_varchar2
  ,p_labour_union_member_flag     in     varchar2 default hr_api.g_varchar2
  ,p_hourly_salaried_code         in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute_category       in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute1               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute2               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute3               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute4               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute5               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute6               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute7               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute8               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute9               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute10              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute11              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute12              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute13              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute14              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute15              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute16              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute17              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute18              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute19              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute20              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute21              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute22              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute23              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute24              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute25              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute26              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute27              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute28              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute29              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute30              in     varchar2 default hr_api.g_varchar2
  ,p_title                        in     varchar2 default hr_api.g_varchar2
  ,p_segment1                     in     varchar2 default hr_api.g_varchar2
  ,p_segment2                     in     varchar2 default hr_api.g_varchar2
  ,p_segment3                     in     varchar2 default hr_api.g_varchar2
  ,p_segment4                     in     varchar2 default hr_api.g_varchar2
  ,p_segment5                     in     varchar2 default hr_api.g_varchar2
  ,p_segment6                     in     varchar2 default hr_api.g_varchar2
  ,p_segment7                     in     varchar2 default hr_api.g_varchar2
  ,p_segment8                     in     varchar2 default hr_api.g_varchar2
  ,p_segment9                     in     varchar2 default hr_api.g_varchar2
  ,p_segment10                    in     varchar2 default hr_api.g_varchar2
  ,p_segment11                    in     varchar2 default hr_api.g_varchar2
  ,p_segment12                    in     varchar2 default hr_api.g_varchar2
  ,p_segment13                    in     varchar2 default hr_api.g_varchar2
  ,p_segment14                    in     varchar2 default hr_api.g_varchar2
  ,p_segment15                    in     varchar2 default hr_api.g_varchar2
  ,p_segment16                    in     varchar2 default hr_api.g_varchar2
  ,p_segment17                    in     varchar2 default hr_api.g_varchar2
  ,p_segment18                    in     varchar2 default hr_api.g_varchar2
  ,p_segment19                    in     varchar2 default hr_api.g_varchar2
  ,p_segment20                    in     varchar2 default hr_api.g_varchar2
  ,p_segment21                    in     varchar2 default hr_api.g_varchar2
  ,p_segment22                    in     varchar2 default hr_api.g_varchar2
  ,p_segment23                    in     varchar2 default hr_api.g_varchar2
  ,p_segment24                    in     varchar2 default hr_api.g_varchar2
  ,p_segment25                    in     varchar2 default hr_api.g_varchar2
  ,p_segment26                    in     varchar2 default hr_api.g_varchar2
  ,p_segment27                    in     varchar2 default hr_api.g_varchar2
  ,p_segment28                    in     varchar2 default hr_api.g_varchar2
  ,p_segment29                    in     varchar2 default hr_api.g_varchar2
  ,p_segment30                    in     varchar2 default hr_api.g_varchar2
-- Bug fix for 944911
-- Added new param p_concat_segments as in param
  ,p_concat_segments              in     varchar2 default hr_api.g_varchar2
  ,p_contract_id                  in     number default hr_api.g_number
  ,p_establishment_id             in     number default hr_api.g_number
  ,p_collective_agreement_id      in     number default hr_api.g_number
  ,p_cagr_id_flex_num             in     number default hr_api.g_number
  ,p_cag_segment1                 in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment2                 in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment3                 in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment4                 in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment5                 in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment6                 in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment7                 in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment8                 in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment9                 in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment10                in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment11                in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment12                in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment13                in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment14                in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment15                in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment16                in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment17                in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment18                in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment19                in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment20                in     varchar2 default hr_api.g_varchar2
  ,p_notice_period		  in     number   default hr_api.g_number
  ,p_notice_period_uom	      	  in     varchar2 default hr_api.g_varchar2
  ,p_employee_category	          in     varchar2 default hr_api.g_varchar2
  ,p_work_at_home		  in     varchar2 default hr_api.g_varchar2
  ,p_job_post_source_name	  in     varchar2 default hr_api.g_varchar2
  ,p_supervisor_assignment_id     in     number   default hr_api.g_number
    ,p_cagr_grade_def_id            in out nocopy number -- bug 2359997
-- Bug fix for 944911
-- p_concatenated_segments has been changed from in out to out
  ,p_cagr_concatenated_segments      out nocopy varchar2
  ,p_concatenated_segments           out nocopy varchar2
  ,p_soft_coding_keyflex_id       in out nocopy number -- bug 2359997
  ,p_comment_id                      out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_no_managers_warning             out nocopy boolean
  ,p_other_manager_warning           out nocopy boolean
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_emp_asg >--------------------------|
-- ----------------------------------------------------------------------------
--
-- This version of the API is now out-of-date however it has been provided to
-- you for backward compatibility support and will be removed in the future.
-- Oracle recommends you to modify existing calling programs in advance of the
-- support being withdrawn thus avoiding any potential disruption.
--
procedure update_emp_asg
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_supervisor_id                in     number   default hr_api.g_number
  ,p_assignment_number            in     varchar2 default hr_api.g_varchar2
  ,p_change_reason                in     varchar2 default hr_api.g_varchar2
  ,p_assignment_status_type_id    in     number   default hr_api.g_number
  ,p_comments                     in     varchar2 default hr_api.g_varchar2
  ,p_date_probation_end           in     date     default hr_api.g_date
  ,p_default_code_comb_id         in     number   default hr_api.g_number
  ,p_frequency                    in     varchar2 default hr_api.g_varchar2
  ,p_internal_address_line        in     varchar2 default hr_api.g_varchar2
  ,p_manager_flag                 in     varchar2 default hr_api.g_varchar2
  ,p_normal_hours                 in     number   default hr_api.g_number
  ,p_perf_review_period           in     number   default hr_api.g_number
  ,p_perf_review_period_frequency in     varchar2 default hr_api.g_varchar2
  ,p_probation_period             in     number   default hr_api.g_number
  ,p_probation_unit               in     varchar2 default hr_api.g_varchar2
  ,p_sal_review_period            in     number   default hr_api.g_number
  ,p_sal_review_period_frequency  in     varchar2 default hr_api.g_varchar2
  ,p_set_of_books_id              in     number   default hr_api.g_number
  ,p_source_type                  in     varchar2 default hr_api.g_varchar2
  ,p_time_normal_finish           in     varchar2 default hr_api.g_varchar2
  ,p_time_normal_start            in     varchar2 default hr_api.g_varchar2
  ,p_bargaining_unit_code         in     varchar2 default hr_api.g_varchar2
  ,p_labour_union_member_flag     in     varchar2 default hr_api.g_varchar2
  ,p_hourly_salaried_code         in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute_category       in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute1               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute2               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute3               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute4               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute5               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute6               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute7               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute8               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute9               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute10              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute11              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute12              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute13              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute14              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute15              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute16              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute17              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute18              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute19              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute20              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute21              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute22              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute23              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute24              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute25              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute26              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute27              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute28              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute29              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute30              in     varchar2 default hr_api.g_varchar2
  ,p_title                        in     varchar2 default hr_api.g_varchar2
  ,p_segment1                     in     varchar2 default hr_api.g_varchar2
  ,p_segment2                     in     varchar2 default hr_api.g_varchar2
  ,p_segment3                     in     varchar2 default hr_api.g_varchar2
  ,p_segment4                     in     varchar2 default hr_api.g_varchar2
  ,p_segment5                     in     varchar2 default hr_api.g_varchar2
  ,p_segment6                     in     varchar2 default hr_api.g_varchar2
  ,p_segment7                     in     varchar2 default hr_api.g_varchar2
  ,p_segment8                     in     varchar2 default hr_api.g_varchar2
  ,p_segment9                     in     varchar2 default hr_api.g_varchar2
  ,p_segment10                    in     varchar2 default hr_api.g_varchar2
  ,p_segment11                    in     varchar2 default hr_api.g_varchar2
  ,p_segment12                    in     varchar2 default hr_api.g_varchar2
  ,p_segment13                    in     varchar2 default hr_api.g_varchar2
  ,p_segment14                    in     varchar2 default hr_api.g_varchar2
  ,p_segment15                    in     varchar2 default hr_api.g_varchar2
  ,p_segment16                    in     varchar2 default hr_api.g_varchar2
  ,p_segment17                    in     varchar2 default hr_api.g_varchar2
  ,p_segment18                    in     varchar2 default hr_api.g_varchar2
  ,p_segment19                    in     varchar2 default hr_api.g_varchar2
  ,p_segment20                    in     varchar2 default hr_api.g_varchar2
  ,p_segment21                    in     varchar2 default hr_api.g_varchar2
  ,p_segment22                    in     varchar2 default hr_api.g_varchar2
  ,p_segment23                    in     varchar2 default hr_api.g_varchar2
  ,p_segment24                    in     varchar2 default hr_api.g_varchar2
  ,p_segment25                    in     varchar2 default hr_api.g_varchar2
  ,p_segment26                    in     varchar2 default hr_api.g_varchar2
  ,p_segment27                    in     varchar2 default hr_api.g_varchar2
  ,p_segment28                    in     varchar2 default hr_api.g_varchar2
  ,p_segment29                    in     varchar2 default hr_api.g_varchar2
  ,p_segment30                    in     varchar2 default hr_api.g_varchar2
-- Bug fix for 944911
-- Added new param p_concat_segments as in param
  ,p_concat_segments              in     varchar2 default hr_api.g_varchar2
  ,p_contract_id                  in     number default hr_api.g_number
  ,p_establishment_id             in     number default hr_api.g_number
  ,p_collective_agreement_id      in     number default hr_api.g_number
  ,p_cagr_id_flex_num             in     number default hr_api.g_number
  ,p_cag_segment1                 in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment2                 in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment3                 in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment4                 in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment5                 in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment6                 in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment7                 in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment8                 in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment9                 in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment10                in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment11                in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment12                in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment13                in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment14                in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment15                in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment16                in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment17                in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment18                in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment19                in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment20                in     varchar2 default hr_api.g_varchar2
  ,p_notice_period		  in     number   default hr_api.g_number
  ,p_notice_period_uom	      	  in     varchar2 default hr_api.g_varchar2
  ,p_employee_category	          in     varchar2 default hr_api.g_varchar2
  ,p_work_at_home		  in     varchar2 default hr_api.g_varchar2
  ,p_job_post_source_name	  in     varchar2 default hr_api.g_varchar2
  ,p_supervisor_assignment_id     in     number   default hr_api.g_number
  ,p_cagr_grade_def_id            in out nocopy number -- bug 2359997
-- Bug fix for 944911
-- p_concatenated_segments has been changed from in out to out
  ,p_cagr_concatenated_segments      out nocopy varchar2
  ,p_concatenated_segments           out nocopy varchar2
  ,p_soft_coding_keyflex_id       in out nocopy number -- bug 2359997
  ,p_comment_id                      out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_no_managers_warning             out nocopy boolean
  ,p_other_manager_warning           out nocopy boolean
  ,p_hourly_salaried_warning         out nocopy boolean
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_emp_asg >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates employee assignment details which do not affect entitlement
 * to element entries.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The assignment must exist as of the effective date and must be an employee
 * assignment.
 *
 * <p><b>Post Success</b><br>
 * The API updates the assignment.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the assignment and raises an error.
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
 * @param p_assignment_id Identifies the assignment record to be modified.
 * @param p_object_version_number Pass in the current version number of the
 * assignment to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated assignment. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_supervisor_id Supervisor for the assignment. The value refers to
 * the supervisor's person record.
 * @param p_assignment_number Assignment number
 * @param p_change_reason Reason for the assignment status change. If there is
 * no change reason the parameter can be null. Valid values are defined in the
 * EMP_ASSIGN_REASON lookup type.
 * @param p_assignment_status_type_id Assignment status. The system status must
 * be the same as before the update, otherwise one of the status change APIs
 * should be used.
 * @param p_comments Comment text.
 * @param p_date_probation_end End date of probation period
 * @param p_default_code_comb_id Identifier for the General Ledger Accounting
 * Flexfield combination that applies to this assignment
 * @param p_frequency Frequency associated with the defined normal working
 * hours. Valid values are defined in the FREQUENCY lookup type.
 * @param p_internal_address_line Internal address identified with this
 * assignment.
 * @param p_manager_flag Indicates whether the employee is a manager
 * @param p_normal_hours Normal working hours for this assignment
 * @param p_perf_review_period Length of performance review period
 * @param p_perf_review_period_frequency Units of performance review period.
 * Valid values are defined in the FREQUENCY lookup type.
 * @param p_probation_period Length of probation period
 * @param p_probation_unit Units of probation period. Valid values are defined
 * in the QUALIFYING_UNITS lookup type.
 * @param p_projected_assignment_end Projected end date of this assignment.
 * @param p_sal_review_period Length of salary review period
 * @param p_sal_review_period_frequency Units of salary review period. Valid
 * values are defined in the FREQUENCY lookup type.
 * @param p_set_of_books_id Identifies General Ledger set of books.
 * @param p_source_type Recruitment activity which this assignment is sourced
 * from. Valid values are defined in the REC_TYPE lookup type.
 * @param p_time_normal_finish Normal work finish time
 * @param p_time_normal_start Normal work start time
 * @param p_bargaining_unit_code Code for bargaining unit. Valid values are
 * defined in the BARGAINING_UNIT_CODE lookup type.
 * @param p_labour_union_member_flag Value 'Y' indicates employee is a labour
 * union member. Other values indicate not a member.
 * @param p_hourly_salaried_code Identifies if the assignment is paid hourly or
 * is salaried. Valid values defined in the HOURLY_SALARIED_CODE lookup type.
 * @param p_ass_attribute_category This context value determines which
 * Flexfield Structure to use with the Descriptive flexfield segments.
 * @param p_ass_attribute1 Descriptive flexfield segment
 * @param p_ass_attribute2 Descriptive flexfield segment
 * @param p_ass_attribute3 Descriptive flexfield segment
 * @param p_ass_attribute4 Descriptive flexfield segment
 * @param p_ass_attribute5 Descriptive flexfield segment
 * @param p_ass_attribute6 Descriptive flexfield segment
 * @param p_ass_attribute7 Descriptive flexfield segment
 * @param p_ass_attribute8 Descriptive flexfield segment
 * @param p_ass_attribute9 Descriptive flexfield segment
 * @param p_ass_attribute10 Descriptive flexfield segment
 * @param p_ass_attribute11 Descriptive flexfield segment
 * @param p_ass_attribute12 Descriptive flexfield segment
 * @param p_ass_attribute13 Descriptive flexfield segment
 * @param p_ass_attribute14 Descriptive flexfield segment
 * @param p_ass_attribute15 Descriptive flexfield segment
 * @param p_ass_attribute16 Descriptive flexfield segment
 * @param p_ass_attribute17 Descriptive flexfield segment
 * @param p_ass_attribute18 Descriptive flexfield segment
 * @param p_ass_attribute19 Descriptive flexfield segment
 * @param p_ass_attribute20 Descriptive flexfield segment
 * @param p_ass_attribute21 Descriptive flexfield segment
 * @param p_ass_attribute22 Descriptive flexfield segment
 * @param p_ass_attribute23 Descriptive flexfield segment
 * @param p_ass_attribute24 Descriptive flexfield segment
 * @param p_ass_attribute25 Descriptive flexfield segment
 * @param p_ass_attribute26 Descriptive flexfield segment
 * @param p_ass_attribute27 Descriptive flexfield segment
 * @param p_ass_attribute28 Descriptive flexfield segment
 * @param p_ass_attribute29 Descriptive flexfield segment
 * @param p_ass_attribute30 Descriptive flexfield segment
 * @param p_title Obsolete parameter, do not use.
 * @param p_segment1 Soft Coded key flexfield segment
 * @param p_segment2 Soft Coded key flexfield segment
 * @param p_segment3 Soft Coded key flexfield segment
 * @param p_segment4 Soft Coded key flexfield segment
 * @param p_segment5 Soft Coded key flexfield segment
 * @param p_segment6 Soft Coded key flexfield segment
 * @param p_segment7 Soft Coded key flexfield segment
 * @param p_segment8 Soft Coded key flexfield segment
 * @param p_segment9 Soft Coded key flexfield segment
 * @param p_segment10 Soft Coded key flexfield segment
 * @param p_segment11 Soft Coded key flexfield segment
 * @param p_segment12 Soft Coded key flexfield segment
 * @param p_segment13 Soft Coded key flexfield segment
 * @param p_segment14 Soft Coded key flexfield segment
 * @param p_segment15 Soft Coded key flexfield segment
 * @param p_segment16 Soft Coded key flexfield segment
 * @param p_segment17 Soft Coded key flexfield segment
 * @param p_segment18 Soft Coded key flexfield segment
 * @param p_segment19 Soft Coded key flexfield segment
 * @param p_segment20 Soft Coded key flexfield segment
 * @param p_segment21 Soft Coded key flexfield segment
 * @param p_segment22 Soft Coded key flexfield segment
 * @param p_segment23 Soft Coded key flexfield segment
 * @param p_segment24 Soft Coded key flexfield segment
 * @param p_segment25 Soft Coded key flexfield segment
 * @param p_segment26 Soft Coded key flexfield segment
 * @param p_segment27 Soft Coded key flexfield segment
 * @param p_segment28 Soft Coded key flexfield segment
 * @param p_segment29 Soft Coded key flexfield segment
 * @param p_segment30 Soft Coded key flexfield segment
 * @param p_concat_segments Concatenated segments for Soft Coded Key Flexfield.
 * Concatenated segments can be supplied instead of individual segments.
 * @param p_contract_id Contract associated with this assignment
 * @param p_establishment_id For French business groups, this identifies the
 * Establishment Legal Entity for this assignment.
 * @param p_collective_agreement_id Collective Agreement that applies to this
 * assignment
 * @param p_cagr_id_flex_num Identifier for the structure from CAGR Key
 * flexfield to use for this assignment
 * @param p_cag_segment1 CAGR Key Flexfield segment
 * @param p_cag_segment2 CAGR Key Flexfield segment
 * @param p_cag_segment3 CAGR Key Flexfield segment
 * @param p_cag_segment4 CAGR Key Flexfield segment
 * @param p_cag_segment5 CAGR Key Flexfield segment
 * @param p_cag_segment6 CAGR Key Flexfield segment
 * @param p_cag_segment7 CAGR Key Flexfield segment
 * @param p_cag_segment8 CAGR Key Flexfield segment
 * @param p_cag_segment9 CAGR Key Flexfield segment
 * @param p_cag_segment10 CAGR Key Flexfield segment
 * @param p_cag_segment11 CAGR Key Flexfield segment
 * @param p_cag_segment12 CAGR Key Flexfield segment
 * @param p_cag_segment13 CAGR Key Flexfield segment
 * @param p_cag_segment14 CAGR Key Flexfield segment
 * @param p_cag_segment15 CAGR Key Flexfield segment
 * @param p_cag_segment16 CAGR Key Flexfield segment
 * @param p_cag_segment17 CAGR Key Flexfield segment
 * @param p_cag_segment18 CAGR Key Flexfield segment
 * @param p_cag_segment19 CAGR Key Flexfield segment
 * @param p_cag_segment20 CAGR Key Flexfield segment
 * @param p_notice_period Length of notice period
 * @param p_notice_period_uom Units for notice period. Valid values are defined
 * in the QUALIFYING_UNITS lookup type.
 * @param p_employee_category Employee Category. Valid values are defined in
 * the EMPLOYEE_CATG lookup type.
 * @param p_work_at_home Indicate whether this assignment is to work at home.
 * Valid values are defined in the YES_NO lookup type.
 * @param p_job_post_source_name Name of the source of the job posting that was
 * answered for this assignment.
 * @param p_supervisor_assignment_id Supervisor's assignment that is
 * responsible for supervising this assignment.
 * @param p_cagr_grade_def_id If a value is passed in for this parameter, it
 * identifies an existing CAGR Key Flexfield combination to associate with the
 * assignment, and segment values are ignored. If a value is not passed in,
 * then the individual CAGR Key Flexfield segments supplied will be used to
 * choose an existing combination or create a new combination. When the API
 * completes, if p_validate is false, then this uniquely identifies the
 * associated combination of the CAGR Key flexfield for this assignment. If
 * p_validate is true, then set to null.
 * @param p_cagr_concatenated_segments CAGR Key Flexfield concatenated segments
 * @param p_concatenated_segments If p_validate is false, set to Soft Coded Key
 * Flexfield concatenated segments, if p_validate is true, set to null.
 * @param p_soft_coding_keyflex_id If a value is passed in for this parameter,
 * it identifies an existing Soft Coded Key Flexfield combination to associate
 * with the assignment, and segment values are ignored. If a value is not
 * passed in, then the individual Soft Coded Key Flexfield segments supplied
 * will be used to choose an existing combination or create a new combination.
 * When the API completes, if p_validate is false, then this uniquely
 * identifies the associated combination of the Soft Coded Key flexfield for
 * this assignment. If p_validate is true, then set to null.
 * @param p_comment_id If p_validate is false and comment text was provided,
 * then will be set to the identifier of the created assignment comment record.
 * If p_validate is true or no comment text was provided, then will be null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created assignment. If p_validate is
 * true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created assignment. If p_validate is true, then
 * set to null.
 * @param p_no_managers_warning Set to true if as a result of the update there
 * is no manager in the organization. Otherwise set to false.
 * @param p_other_manager_warning If set to true, then a manager existed in the
 * organization prior to calling this API and the manager flag has been set to
 * 'Y' for yes.
 * @param p_hourly_salaried_warning Set to true if values entered for Salary
 * Basis and Hourly Salaried Code are invalid date as of p_effective_date.
 * @param p_gsp_post_process_warning Set to the name of a warning message from
 * the Message Dictionary if any Grade Ladder related errors have been
 * encountered while running this API.
 * @rep:displayname Update Employee Assignment
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE_ASG
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_emp_asg
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_supervisor_id                in     number   default hr_api.g_number
  ,p_assignment_number            in     varchar2 default hr_api.g_varchar2
  ,p_change_reason                in     varchar2 default hr_api.g_varchar2
  ,p_assignment_status_type_id    in     number   default hr_api.g_number
  ,p_comments                     in     varchar2 default hr_api.g_varchar2
  ,p_date_probation_end           in     date     default hr_api.g_date
  ,p_default_code_comb_id         in     number   default hr_api.g_number
  ,p_frequency                    in     varchar2 default hr_api.g_varchar2
  ,p_internal_address_line        in     varchar2 default hr_api.g_varchar2
  ,p_manager_flag                 in     varchar2 default hr_api.g_varchar2
  ,p_normal_hours                 in     number   default hr_api.g_number
  ,p_perf_review_period           in     number   default hr_api.g_number
  ,p_perf_review_period_frequency in     varchar2 default hr_api.g_varchar2
  ,p_probation_period             in     number   default hr_api.g_number
  ,p_probation_unit               in     varchar2 default hr_api.g_varchar2
  ,p_projected_assignment_end     in     varchar2 default hr_api.g_date
  ,p_sal_review_period            in     number   default hr_api.g_number
  ,p_sal_review_period_frequency  in     varchar2 default hr_api.g_varchar2
  ,p_set_of_books_id              in     number   default hr_api.g_number
  ,p_source_type                  in     varchar2 default hr_api.g_varchar2
  ,p_time_normal_finish           in     varchar2 default hr_api.g_varchar2
  ,p_time_normal_start            in     varchar2 default hr_api.g_varchar2
  ,p_bargaining_unit_code         in     varchar2 default hr_api.g_varchar2
  ,p_labour_union_member_flag     in     varchar2 default hr_api.g_varchar2
  ,p_hourly_salaried_code         in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute_category       in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute1               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute2               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute3               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute4               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute5               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute6               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute7               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute8               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute9               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute10              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute11              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute12              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute13              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute14              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute15              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute16              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute17              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute18              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute19              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute20              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute21              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute22              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute23              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute24              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute25              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute26              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute27              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute28              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute29              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute30              in     varchar2 default hr_api.g_varchar2
  ,p_title                        in     varchar2 default hr_api.g_varchar2
  ,p_segment1                     in     varchar2 default hr_api.g_varchar2
  ,p_segment2                     in     varchar2 default hr_api.g_varchar2
  ,p_segment3                     in     varchar2 default hr_api.g_varchar2
  ,p_segment4                     in     varchar2 default hr_api.g_varchar2
  ,p_segment5                     in     varchar2 default hr_api.g_varchar2
  ,p_segment6                     in     varchar2 default hr_api.g_varchar2
  ,p_segment7                     in     varchar2 default hr_api.g_varchar2
  ,p_segment8                     in     varchar2 default hr_api.g_varchar2
  ,p_segment9                     in     varchar2 default hr_api.g_varchar2
  ,p_segment10                    in     varchar2 default hr_api.g_varchar2
  ,p_segment11                    in     varchar2 default hr_api.g_varchar2
  ,p_segment12                    in     varchar2 default hr_api.g_varchar2
  ,p_segment13                    in     varchar2 default hr_api.g_varchar2
  ,p_segment14                    in     varchar2 default hr_api.g_varchar2
  ,p_segment15                    in     varchar2 default hr_api.g_varchar2
  ,p_segment16                    in     varchar2 default hr_api.g_varchar2
  ,p_segment17                    in     varchar2 default hr_api.g_varchar2
  ,p_segment18                    in     varchar2 default hr_api.g_varchar2
  ,p_segment19                    in     varchar2 default hr_api.g_varchar2
  ,p_segment20                    in     varchar2 default hr_api.g_varchar2
  ,p_segment21                    in     varchar2 default hr_api.g_varchar2
  ,p_segment22                    in     varchar2 default hr_api.g_varchar2
  ,p_segment23                    in     varchar2 default hr_api.g_varchar2
  ,p_segment24                    in     varchar2 default hr_api.g_varchar2
  ,p_segment25                    in     varchar2 default hr_api.g_varchar2
  ,p_segment26                    in     varchar2 default hr_api.g_varchar2
  ,p_segment27                    in     varchar2 default hr_api.g_varchar2
  ,p_segment28                    in     varchar2 default hr_api.g_varchar2
  ,p_segment29                    in     varchar2 default hr_api.g_varchar2
  ,p_segment30                    in     varchar2 default hr_api.g_varchar2
-- Bug fix for 944911
-- Added new param p_concat_segments as in param
  ,p_concat_segments              in     varchar2 default hr_api.g_varchar2
  ,p_contract_id                  in     number default hr_api.g_number
  ,p_establishment_id             in     number default hr_api.g_number
  ,p_collective_agreement_id      in     number default hr_api.g_number
  ,p_cagr_id_flex_num             in     number default hr_api.g_number
  ,p_cag_segment1                 in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment2                 in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment3                 in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment4                 in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment5                 in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment6                 in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment7                 in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment8                 in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment9                 in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment10                in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment11                in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment12                in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment13                in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment14                in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment15                in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment16                in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment17                in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment18                in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment19                in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment20                in     varchar2 default hr_api.g_varchar2
  ,p_notice_period		  in     number   default hr_api.g_number
  ,p_notice_period_uom	      	  in     varchar2 default hr_api.g_varchar2
  ,p_employee_category	          in     varchar2 default hr_api.g_varchar2
  ,p_work_at_home		  in     varchar2 default hr_api.g_varchar2
  ,p_job_post_source_name	  in     varchar2 default hr_api.g_varchar2
  ,p_supervisor_assignment_id     in     number   default hr_api.g_number
  ,p_cagr_grade_def_id            in out nocopy number -- bug 2359997
-- Bug fix for 944911
-- p_concatenated_segments has been changed from in out to out
  ,p_cagr_concatenated_segments      out nocopy varchar2
  ,p_concatenated_segments           out nocopy varchar2
  ,p_soft_coding_keyflex_id       in out nocopy number -- bug 2359997
  ,p_comment_id                      out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_no_managers_warning             out nocopy boolean
  ,p_other_manager_warning           out nocopy boolean
  ,p_hourly_salaried_warning         out nocopy boolean
  ,p_gsp_post_process_warning        out nocopy varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_gb_emp_asg >-------------------------|
-- ----------------------------------------------------------------------------
--
-- This version of the API is now out-of-date however it has been provided to
-- you for backward compatibility support and will be removed in the future.
-- Oracle recommends you to modify existing calling programs in advance of the
-- support being withdrawn thus avoiding any potential disruption.
--
procedure update_gb_emp_asg
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_supervisor_id                in     number   default hr_api.g_number
  ,p_assignment_number            in     varchar2 default hr_api.g_varchar2
  ,p_change_reason                in     varchar2 default hr_api.g_varchar2
  ,p_comments                     in     varchar2 default hr_api.g_varchar2
  ,p_date_probation_end           in     date     default hr_api.g_date
  ,p_default_code_comb_id         in     number   default hr_api.g_number
  ,p_frequency                    in     varchar2 default hr_api.g_varchar2
  ,p_internal_address_line        in     varchar2 default hr_api.g_varchar2
  ,p_manager_flag                 in     varchar2 default hr_api.g_varchar2
  ,p_normal_hours                 in     number   default hr_api.g_number
  ,p_perf_review_period           in     number   default hr_api.g_number
  ,p_perf_review_period_frequency in     varchar2 default hr_api.g_varchar2
  ,p_probation_period             in     number   default hr_api.g_number
  ,p_probation_unit               in     varchar2 default hr_api.g_varchar2
  ,p_sal_review_period            in     number   default hr_api.g_number
  ,p_sal_review_period_frequency  in     varchar2 default hr_api.g_varchar2
  ,p_set_of_books_id              in     number   default hr_api.g_number
  ,p_source_type                  in     varchar2 default hr_api.g_varchar2
  ,p_time_normal_finish           in     varchar2 default hr_api.g_varchar2
  ,p_time_normal_start            in     varchar2 default hr_api.g_varchar2
  ,p_bargaining_unit_code         in     varchar2 default hr_api.g_varchar2
  ,p_labour_union_member_flag     in     varchar2 default hr_api.g_varchar2
  ,p_hourly_salaried_code         in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute_category       in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute1               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute2               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute3               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute4               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute5               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute6               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute7               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute8               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute9               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute10              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute11              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute12              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute13              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute14              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute15              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute16              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute17              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute18              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute19              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute20              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute21              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute22              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute23              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute24              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute25              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute26              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute27              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute28              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute29              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute30              in     varchar2 default hr_api.g_varchar2
  ,p_title                        in     varchar2 default hr_api.g_varchar2
  ,p_supervisor_assignment_id     in     number   default hr_api.g_number
  ,p_comment_id                      out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_no_managers_warning             out nocopy boolean
  ,p_other_manager_warning           out nocopy boolean
  );

--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_gb_emp_asg >-------------------------|
-- ----------------------------------------------------------------------------
--
-- This version of the API is now out-of-date however it has been provided to
-- you for backward compatibility support and will be removed in the future.
-- Oracle recommends you to modify existing calling programs in advance of the
-- support being withdrawn thus avoiding any potential disruption.
--
  procedure update_gb_emp_asg
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_supervisor_id                in     number   default hr_api.g_number
  ,p_assignment_number            in     varchar2 default hr_api.g_varchar2
  ,p_change_reason                in     varchar2 default hr_api.g_varchar2
  ,p_comments                     in     varchar2 default hr_api.g_varchar2
  ,p_date_probation_end           in     date     default hr_api.g_date
  ,p_default_code_comb_id         in     number   default hr_api.g_number
  ,p_frequency                    in     varchar2 default hr_api.g_varchar2
  ,p_internal_address_line        in     varchar2 default hr_api.g_varchar2
  ,p_manager_flag                 in     varchar2 default hr_api.g_varchar2
  ,p_normal_hours                 in     number   default hr_api.g_number
  ,p_perf_review_period           in     number   default hr_api.g_number
  ,p_perf_review_period_frequency in     varchar2 default hr_api.g_varchar2
  ,p_probation_period             in     number   default hr_api.g_number
  ,p_probation_unit               in     varchar2 default hr_api.g_varchar2
  ,p_sal_review_period            in     number   default hr_api.g_number
  ,p_sal_review_period_frequency  in     varchar2 default hr_api.g_varchar2
  ,p_set_of_books_id              in     number   default hr_api.g_number
  ,p_source_type                  in     varchar2 default hr_api.g_varchar2
  ,p_time_normal_finish           in     varchar2 default hr_api.g_varchar2
  ,p_time_normal_start            in     varchar2 default hr_api.g_varchar2
  ,p_bargaining_unit_code         in     varchar2 default hr_api.g_varchar2
  ,p_labour_union_member_flag     in     varchar2 default hr_api.g_varchar2
  ,p_hourly_salaried_code         in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute_category       in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute1               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute2               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute3               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute4               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute5               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute6               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute7               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute8               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute9               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute10              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute11              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute12              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute13              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute14              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute15              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute16              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute17              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute18              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute19              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute20              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute21              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute22              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute23              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute24              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute25              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute26              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute27              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute28              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute29              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute30              in     varchar2 default hr_api.g_varchar2
  ,p_title                        in     varchar2 default hr_api.g_varchar2
  ,p_contract_id		  in     number   default hr_api.g_number
  ,p_establishment_id		  in     number   default hr_api.g_number
  ,p_collective_agreement_id	  in 	 number   default hr_api.g_number
  ,p_cagr_id_flex_num		  in	 number   default hr_api.g_number
  ,p_notice_period		  in     number   default hr_api.g_number
  ,p_notice_period_uom	      	  in     varchar2 default hr_api.g_varchar2
  ,p_employee_category	          in     varchar2 default hr_api.g_varchar2
  ,p_work_at_home		  in     varchar2 default hr_api.g_varchar2
  ,p_job_post_source_name	  in     varchar2 default hr_api.g_varchar2
  ,p_supervisor_assignment_id     in     number   default hr_api.g_number
  ,p_cagr_grade_def_id               out nocopy number
  ,p_cagr_concatenated_segments      out nocopy varchar2
  ,p_concatenated_segments           out nocopy varchar2
  ,p_soft_coding_keyflex_id          out nocopy number
  ,p_comment_id                      out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_no_managers_warning             out nocopy boolean
  ,p_other_manager_warning           out nocopy boolean
  );

--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_gb_emp_asg >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates information for an existing employee assignment with a GB
 * legislation.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The assignment must exist as of the effective date, and must be an employee
 * assignment.
 *
 * <p><b>Post Success</b><br>
 * The API updates the assignment.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the assignment and raises an error.
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
 * @param p_assignment_id Identifies the assignment record to be modified.
 * @param p_object_version_number Pass in the current version number of the
 * assignment to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated assignment. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_supervisor_id Supervisor for the assignment. The value refers to
 * the supervisor's person record.
 * @param p_assignment_number Assignment number
 * @param p_change_reason Reason for the assignment status change. If there is
 * no change reason the parameter can be null. Valid values are defined in the
 * EMP_ASSIGN_REASON lookup type.
 * @param p_comments Comment text.
 * @param p_date_probation_end End date of probation period
 * @param p_default_code_comb_id Identifier for the General Ledger Accounting
 * Flexfield combination which applies to this assignment
 * @param p_frequency Frequency associated with the defined normal working
 * hours. Valid values are defined in the FREQUENCY lookup type.
 * @param p_internal_address_line Internal address identified with this
 * assignment.
 * @param p_manager_flag Indicates whether the employee is a manager
 * @param p_normal_hours Normal working hours for this assignment
 * @param p_perf_review_period Length of performance review period
 * @param p_perf_review_period_frequency Units of performance review period.
 * Valid values are defined in the FREQUENCY lookup type.
 * @param p_probation_period Length of probation period
 * @param p_probation_unit Units of probation period. Valid values are defined
 * in the QUALIFYING_UNITS lookup type.
 * @param p_sal_review_period Length of salary review period
 * @param p_sal_review_period_frequency Units of salary review period. Valid
 * values are defined in the FREQUENCY lookup type.
 * @param p_set_of_books_id Identifies General Ledger set of books.
 * @param p_source_type Recruitment activity which this assignment is sourced
 * from. Valid values are defined in the REC_TYPE lookup type.
 * @param p_time_normal_finish Normal work finish time
 * @param p_time_normal_start Normal work start time
 * @param p_bargaining_unit_code Code for bargaining unit. Valid values are
 * defined in the BARGAINING_UNIT_CODE lookup type.
 * @param p_labour_union_member_flag Value 'Y' indicates employee is a labour
 * union member. Other values indicate not a member.
 * @param p_hourly_salaried_code Identifies if the assignment is paid hourly or
 * is salaried. Valid values defined in the HOURLY_SALARIED_CODE lookup type.
 * @param p_ass_attribute_category This context value determines which
 * Flexfield Structure to use with the Descriptive flexfield segments.
 * @param p_ass_attribute1 Descriptive flexfield segment
 * @param p_ass_attribute2 Descriptive flexfield segment
 * @param p_ass_attribute3 Descriptive flexfield segment
 * @param p_ass_attribute4 Descriptive flexfield segment
 * @param p_ass_attribute5 Descriptive flexfield segment
 * @param p_ass_attribute6 Descriptive flexfield segment
 * @param p_ass_attribute7 Descriptive flexfield segment
 * @param p_ass_attribute8 Descriptive flexfield segment
 * @param p_ass_attribute9 Descriptive flexfield segment
 * @param p_ass_attribute10 Descriptive flexfield segment
 * @param p_ass_attribute11 Descriptive flexfield segment
 * @param p_ass_attribute12 Descriptive flexfield segment
 * @param p_ass_attribute13 Descriptive flexfield segment
 * @param p_ass_attribute14 Descriptive flexfield segment
 * @param p_ass_attribute15 Descriptive flexfield segment
 * @param p_ass_attribute16 Descriptive flexfield segment
 * @param p_ass_attribute17 Descriptive flexfield segment
 * @param p_ass_attribute18 Descriptive flexfield segment
 * @param p_ass_attribute19 Descriptive flexfield segment
 * @param p_ass_attribute20 Descriptive flexfield segment
 * @param p_ass_attribute21 Descriptive flexfield segment
 * @param p_ass_attribute22 Descriptive flexfield segment
 * @param p_ass_attribute23 Descriptive flexfield segment
 * @param p_ass_attribute24 Descriptive flexfield segment
 * @param p_ass_attribute25 Descriptive flexfield segment
 * @param p_ass_attribute26 Descriptive flexfield segment
 * @param p_ass_attribute27 Descriptive flexfield segment
 * @param p_ass_attribute28 Descriptive flexfield segment
 * @param p_ass_attribute29 Descriptive flexfield segment
 * @param p_ass_attribute30 Descriptive flexfield segment
 * @param p_title Obsolete parameter, do not use.
 * @param p_contract_id Contract associated with this assignment
 * @param p_establishment_id For French business groups, this identifies the
 * Establishment Legal Entity for this assignment.
 * @param p_collective_agreement_id Collective Agreement which applies to this
 * assignment
 * @param p_cagr_id_flex_num Identifier for the structure from CAGR Key
 * flexfield to use for this assignment
 * @param p_notice_period Length of notice period
 * @param p_notice_period_uom Units for notice period. Valid values are defined
 * in the QUALIFYING_UNITS lookup type.
 * @param p_employee_category Employee Category. Valid values are defined in
 * the EMPLOYEE_CATG lookup type.
 * @param p_work_at_home Indicate whether this assignment is to work at home.
 * Valid values are defined in the YES_NO lookup type.
 * @param p_job_post_source_name Name of the source of the job posting that was
 * answered for this assignment.
 * @param p_supervisor_assignment_id Supervisor's assignment that is
 * responsible for supervising this assignment.
 * @param p_cagr_grade_def_id If a value is passed in for this parameter, it
 * identifies an existing CAGR Key Flexfield combination to associate with the
 * assignment, and segment values are ignored. If a value is not passed in,
 * then the individual CAGR Key Flexfield segments supplied will be used to
 * choose an existing combination or create a new combination. When the API
 * completes, if p_validate is false, then this uniquely identifies the
 * associated combination of the CAGR Key flexfield for this assignment. If
 * p_validate is true, then set to null.
 * @param p_cagr_concatenated_segments CAGR Key Flexfield concatenated segments
 * @param p_concatenated_segments If p_validate is false, set to Soft Coded Key
 * Flexfield concatenated segments, if p_validate is true, set to null.
 * @param p_soft_coding_keyflex_id If a value is passed in for this parameter,
 * it identifies an existing Soft Coded Key Flexfield combination to associate
 * with the assignment, and segment values are ignored. If a value is not
 * passed in, then the individual Soft Coded Key Flexfield segments supplied
 * will be used to choose an existing combination or create a new combination.
 * When the API completes, if p_validate is false, then this uniquely
 * identifies the associated combination of the Soft Coded Key flexfield for
 * this assignment. If p_validate is true, then set to null.
 * @param p_comment_id If p_validate is false and comment text was provided,
 * then will be set to the identifier of the created assignment comment record.
 * If p_validate is true or no comment text was provided, then will be null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created assignment. If p_validate is
 * true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created assignment. If p_validate is true, then
 * set to null.
 * @param p_no_managers_warning Set to true if as a result of the update there
 * is no manager in the organization. Otherwise set to false.
 * @param p_other_manager_warning If set to true, then a manager existed in the
 * organization prior to calling this API and the manager flag has been set to
 * 'Y' for yes.
 * @param p_hourly_salaried_warning Set to true if values entered for Salary
 * Basis and Hourly Salaried Code are invalid date as of p_effective_date.
 * @rep:displayname Update Employee Assignment for United Kingdom
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE_ASG
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_gb_emp_asg
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_supervisor_id                in     number   default hr_api.g_number
  ,p_assignment_number            in     varchar2 default hr_api.g_varchar2
  ,p_change_reason                in     varchar2 default hr_api.g_varchar2
  ,p_comments                     in     varchar2 default hr_api.g_varchar2
  ,p_date_probation_end           in     date     default hr_api.g_date
  ,p_default_code_comb_id         in     number   default hr_api.g_number
  ,p_frequency                    in     varchar2 default hr_api.g_varchar2
  ,p_internal_address_line        in     varchar2 default hr_api.g_varchar2
  ,p_manager_flag                 in     varchar2 default hr_api.g_varchar2
  ,p_normal_hours                 in     number   default hr_api.g_number
  ,p_perf_review_period           in     number   default hr_api.g_number
  ,p_perf_review_period_frequency in     varchar2 default hr_api.g_varchar2
  ,p_probation_period             in     number   default hr_api.g_number
  ,p_probation_unit               in     varchar2 default hr_api.g_varchar2
  ,p_sal_review_period            in     number   default hr_api.g_number
  ,p_sal_review_period_frequency  in     varchar2 default hr_api.g_varchar2
  ,p_set_of_books_id              in     number   default hr_api.g_number
  ,p_source_type                  in     varchar2 default hr_api.g_varchar2
  ,p_time_normal_finish           in     varchar2 default hr_api.g_varchar2
  ,p_time_normal_start            in     varchar2 default hr_api.g_varchar2
  ,p_bargaining_unit_code         in     varchar2 default hr_api.g_varchar2
  ,p_labour_union_member_flag     in     varchar2 default hr_api.g_varchar2
  ,p_hourly_salaried_code         in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute_category       in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute1               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute2               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute3               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute4               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute5               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute6               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute7               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute8               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute9               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute10              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute11              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute12              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute13              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute14              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute15              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute16              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute17              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute18              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute19              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute20              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute21              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute22              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute23              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute24              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute25              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute26              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute27              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute28              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute29              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute30              in     varchar2 default hr_api.g_varchar2
  ,p_title                        in     varchar2 default hr_api.g_varchar2
  ,p_contract_id		  in     number   default hr_api.g_number
  ,p_establishment_id		  in     number   default hr_api.g_number
  ,p_collective_agreement_id	  in 	 number   default hr_api.g_number
  ,p_cagr_id_flex_num		  in	 number   default hr_api.g_number
  ,p_notice_period		  in     number   default hr_api.g_number
  ,p_notice_period_uom	      	  in     varchar2 default hr_api.g_varchar2
  ,p_employee_category	          in     varchar2 default hr_api.g_varchar2
  ,p_work_at_home		  in     varchar2 default hr_api.g_varchar2
  ,p_job_post_source_name	  in     varchar2 default hr_api.g_varchar2
  ,p_supervisor_assignment_id     in     number   default hr_api.g_number
  ,p_cagr_grade_def_id               out nocopy number
  ,p_cagr_concatenated_segments      out nocopy varchar2
  ,p_concatenated_segments           out nocopy varchar2
  ,p_soft_coding_keyflex_id          out nocopy number
  ,p_comment_id                      out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_no_managers_warning             out nocopy boolean
  ,p_other_manager_warning           out nocopy boolean
  ,p_hourly_salaried_warning         out nocopy boolean
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_us_emp_asg >-------------------------|
-- ----------------------------------------------------------------------------
--
-- This version of the API is now out-of-date however it has been provided to
-- you for backward compatibility support and will be removed in the future.
-- Oracle recommends you to modify existing calling programs in advance of the
-- support being withdrawn thus avoiding any potential disruption.
--
procedure update_us_emp_asg
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_supervisor_id                in     number   default hr_api.g_number
  ,p_assignment_number            in     varchar2 default hr_api.g_varchar2
  ,p_change_reason                in     varchar2 default hr_api.g_varchar2
  ,p_comments                     in     varchar2 default hr_api.g_varchar2
  ,p_date_probation_end           in     date     default hr_api.g_date
  ,p_default_code_comb_id         in     number   default hr_api.g_number
  ,p_frequency                    in     varchar2 default hr_api.g_varchar2
  ,p_internal_address_line        in     varchar2 default hr_api.g_varchar2
  ,p_manager_flag                 in     varchar2 default hr_api.g_varchar2
  ,p_normal_hours                 in     number   default hr_api.g_number
  ,p_perf_review_period           in     number   default hr_api.g_number
  ,p_perf_review_period_frequency in     varchar2 default hr_api.g_varchar2
  ,p_probation_period             in     number   default hr_api.g_number
  ,p_probation_unit               in     varchar2 default hr_api.g_varchar2
  ,p_sal_review_period            in     number   default hr_api.g_number
  ,p_sal_review_period_frequency  in     varchar2 default hr_api.g_varchar2
  ,p_set_of_books_id              in     number   default hr_api.g_number
  ,p_source_type                  in     varchar2 default hr_api.g_varchar2
  ,p_time_normal_finish           in     varchar2 default hr_api.g_varchar2
  ,p_time_normal_start            in     varchar2 default hr_api.g_varchar2
  ,p_bargaining_unit_code         in     varchar2 default hr_api.g_varchar2
  ,p_labour_union_member_flag     in     varchar2 default hr_api.g_varchar2
  ,p_hourly_salaried_code         in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute_category       in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute1               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute2               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute3               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute4               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute5               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute6               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute7               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute8               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute9               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute10              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute11              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute12              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute13              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute14              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute15              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute16              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute17              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute18              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute19              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute20              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute21              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute22              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute23              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute24              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute25              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute26              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute27              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute28              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute29              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute30              in     varchar2 default hr_api.g_varchar2
  ,p_title                        in     varchar2 default hr_api.g_varchar2
  ,p_tax_unit                     in     varchar2 default hr_api.g_varchar2
  ,p_timecard_approver            in     varchar2 default hr_api.g_varchar2
  ,p_timecard_required            in     varchar2 default hr_api.g_varchar2
  ,p_work_schedule                in     varchar2 default hr_api.g_varchar2
  ,p_shift                        in     varchar2 default hr_api.g_varchar2
  ,p_spouse_salary                in     varchar2 default hr_api.g_varchar2
  ,p_legal_representative         in     varchar2 default hr_api.g_varchar2
  ,p_wc_override_code             in     varchar2 default hr_api.g_varchar2
  ,p_eeo_1_establishment          in     varchar2 default hr_api.g_varchar2
  ,p_supervisor_assignment_id     in     number   default hr_api.g_number
  ,p_comment_id                      out nocopy number
  ,p_soft_coding_keyflex_id          out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
-- Bug 944911
-- Amended p_concatenated_segments to be out
-- Added p_concat_segments  - in param
  ,p_concatenated_segments           out nocopy varchar2
  ,p_concat_segments              in     varchar2 default hr_api.g_varchar2
  ,p_no_managers_warning             out nocopy boolean
  ,p_other_manager_warning           out nocopy boolean
  );

--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_us_emp_asg >-------------------------|
-- ----------------------------------------------------------------------------
--
-- This version of the API is now out-of-date however it has been provided to
-- you for backward compatibility support and will be removed in the future.
-- Oracle recommends you to modify existing calling programs in advance of the
-- support being withdrawn thus avoiding any potential disruption.
--
procedure update_us_emp_asg
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_supervisor_id                in     number   default hr_api.g_number
  ,p_assignment_number            in     varchar2 default hr_api.g_varchar2
  ,p_change_reason                in     varchar2 default hr_api.g_varchar2
  ,p_comments                     in     varchar2 default hr_api.g_varchar2
  ,p_date_probation_end           in     date     default hr_api.g_date
  ,p_default_code_comb_id         in     number   default hr_api.g_number
  ,p_frequency                    in     varchar2 default hr_api.g_varchar2
  ,p_internal_address_line        in     varchar2 default hr_api.g_varchar2
  ,p_manager_flag                 in     varchar2 default hr_api.g_varchar2
  ,p_normal_hours                 in     number   default hr_api.g_number
  ,p_perf_review_period           in     number   default hr_api.g_number
  ,p_perf_review_period_frequency in     varchar2 default hr_api.g_varchar2
  ,p_probation_period             in     number   default hr_api.g_number
  ,p_probation_unit               in     varchar2 default hr_api.g_varchar2
  ,p_sal_review_period            in     number   default hr_api.g_number
  ,p_sal_review_period_frequency  in     varchar2 default hr_api.g_varchar2
  ,p_set_of_books_id              in     number   default hr_api.g_number
  ,p_source_type                  in     varchar2 default hr_api.g_varchar2
  ,p_time_normal_finish           in     varchar2 default hr_api.g_varchar2
  ,p_time_normal_start            in     varchar2 default hr_api.g_varchar2
  ,p_bargaining_unit_code         in     varchar2 default hr_api.g_varchar2
  ,p_labour_union_member_flag     in     varchar2 default hr_api.g_varchar2
  ,p_hourly_salaried_code         in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute_category       in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute1               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute2               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute3               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute4               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute5               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute6               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute7               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute8               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute9               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute10              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute11              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute12              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute13              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute14              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute15              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute16              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute17              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute18              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute19              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute20              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute21              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute22              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute23              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute24              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute25              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute26              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute27              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute28              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute29              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute30              in     varchar2 default hr_api.g_varchar2
  ,p_title                        in     varchar2 default hr_api.g_varchar2
  ,p_tax_unit                     in     varchar2 default hr_api.g_varchar2
  ,p_timecard_approver            in     varchar2 default hr_api.g_varchar2
  ,p_timecard_required            in     varchar2 default hr_api.g_varchar2
  ,p_work_schedule                in     varchar2 default hr_api.g_varchar2
  ,p_shift                        in     varchar2 default hr_api.g_varchar2
  ,p_spouse_salary                in     varchar2 default hr_api.g_varchar2
  ,p_legal_representative         in     varchar2 default hr_api.g_varchar2
  ,p_wc_override_code             in     varchar2 default hr_api.g_varchar2
  ,p_eeo_1_establishment          in     varchar2 default hr_api.g_varchar2
  ,p_contract_id                  in     number   default hr_api.g_number
  ,p_establishment_id             in     number   default hr_api.g_number
  ,p_collective_agreement_id      in     number   default hr_api.g_number
  ,p_cagr_id_flex_num             in     number   default hr_api.g_number
  ,p_notice_period		  in     number   default hr_api.g_number
  ,p_notice_period_uom	      	  in     varchar2 default hr_api.g_varchar2
  ,p_employee_category	          in     varchar2 default hr_api.g_varchar2
  ,p_work_at_home		  in     varchar2 default hr_api.g_varchar2
  ,p_job_post_source_name	  in     varchar2 default hr_api.g_varchar2
  ,p_supervisor_assignment_id     in     number   default hr_api.g_number
  ,p_cagr_grade_def_id               out nocopy number
  ,p_cagr_concatenated_segments      out nocopy varchar2
  ,p_comment_id                      out nocopy number
  ,p_soft_coding_keyflex_id          out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
-- Bug 944911
-- Amended p_concatenated_segments to be out
-- Added p_concat_segments  - in param
  ,p_concatenated_segments           out nocopy varchar2
  ,p_concat_segments              in     varchar2 default hr_api.g_varchar2
  ,p_no_managers_warning             out nocopy boolean
  ,p_other_manager_warning           out nocopy boolean
  );

--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_us_emp_asg >-------------------------|
-- ----------------------------------------------------------------------------
--
-- This version of the API is now out-of-date however it has been provided to
-- you for backward compatibility support and will be removed in the future.
-- Oracle recommends you to modify existing calling programs in advance of the
-- support being withdrawn thus avoiding any potential disruption.
--
procedure update_us_emp_asg
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_supervisor_id                in     number   default hr_api.g_number
  ,p_assignment_number            in     varchar2 default hr_api.g_varchar2
  ,p_change_reason                in     varchar2 default hr_api.g_varchar2
  ,p_comments                     in     varchar2 default hr_api.g_varchar2
  ,p_date_probation_end           in     date     default hr_api.g_date
  ,p_default_code_comb_id         in     number   default hr_api.g_number
  ,p_frequency                    in     varchar2 default hr_api.g_varchar2
  ,p_internal_address_line        in     varchar2 default hr_api.g_varchar2
  ,p_manager_flag                 in     varchar2 default hr_api.g_varchar2
  ,p_normal_hours                 in     number   default hr_api.g_number
  ,p_perf_review_period           in     number   default hr_api.g_number
  ,p_perf_review_period_frequency in     varchar2 default hr_api.g_varchar2
  ,p_probation_period             in     number   default hr_api.g_number
  ,p_probation_unit               in     varchar2 default hr_api.g_varchar2
  ,p_sal_review_period            in     number   default hr_api.g_number
  ,p_sal_review_period_frequency  in     varchar2 default hr_api.g_varchar2
  ,p_set_of_books_id              in     number   default hr_api.g_number
  ,p_source_type                  in     varchar2 default hr_api.g_varchar2
  ,p_time_normal_finish           in     varchar2 default hr_api.g_varchar2
  ,p_time_normal_start            in     varchar2 default hr_api.g_varchar2
  ,p_bargaining_unit_code         in     varchar2 default hr_api.g_varchar2
  ,p_labour_union_member_flag     in     varchar2 default hr_api.g_varchar2
  ,p_hourly_salaried_code         in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute_category       in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute1               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute2               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute3               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute4               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute5               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute6               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute7               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute8               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute9               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute10              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute11              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute12              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute13              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute14              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute15              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute16              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute17              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute18              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute19              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute20              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute21              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute22              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute23              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute24              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute25              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute26              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute27              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute28              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute29              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute30              in     varchar2 default hr_api.g_varchar2
  ,p_title                        in     varchar2 default hr_api.g_varchar2
  ,p_tax_unit                     in     varchar2 default hr_api.g_varchar2
  ,p_timecard_approver            in     varchar2 default hr_api.g_varchar2
  ,p_timecard_required            in     varchar2 default hr_api.g_varchar2
  ,p_work_schedule                in     varchar2 default hr_api.g_varchar2
  ,p_shift                        in     varchar2 default hr_api.g_varchar2
  ,p_spouse_salary                in     varchar2 default hr_api.g_varchar2
  ,p_legal_representative         in     varchar2 default hr_api.g_varchar2
  ,p_wc_override_code             in     varchar2 default hr_api.g_varchar2
  ,p_eeo_1_establishment          in     varchar2 default hr_api.g_varchar2
  ,p_contract_id                  in     number   default hr_api.g_number
  ,p_establishment_id             in     number   default hr_api.g_number
  ,p_collective_agreement_id      in     number   default hr_api.g_number
  ,p_cagr_id_flex_num             in     number   default hr_api.g_number
  ,p_notice_period		  in     number   default hr_api.g_number
  ,p_notice_period_uom	      	  in     varchar2 default hr_api.g_varchar2
  ,p_employee_category	          in     varchar2 default hr_api.g_varchar2
  ,p_work_at_home		  in     varchar2 default hr_api.g_varchar2
  ,p_job_post_source_name	  in     varchar2 default hr_api.g_varchar2
  ,p_supervisor_assignment_id     in     number   default hr_api.g_number
  ,p_cagr_grade_def_id               out nocopy number
  ,p_cagr_concatenated_segments      out nocopy varchar2
  ,p_comment_id                      out nocopy number
  ,p_soft_coding_keyflex_id          out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
-- Bug 944911
-- Amended p_concatenated_segments to be out
-- Added p_concat_segments  - in param
  ,p_concatenated_segments           out nocopy varchar2
  ,p_concat_segments              in     varchar2 default hr_api.g_varchar2
  ,p_no_managers_warning             out nocopy boolean
  ,p_other_manager_warning           out nocopy boolean
  ,p_hourly_salaried_warning         out nocopy boolean
  );

--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_us_emp_asg >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates employee assignment details that do not affect entitlement
 * to element entries, for employees in a United States legislation.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The assignment must exist as of the effective date, and must be an employee
 * assignment.
 *
 * <p><b>Post Success</b><br>
 * The API updates the assignment.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the assignment and raises an error.
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
 * @param p_assignment_id Identifies the assignment record to be modified.
 * @param p_object_version_number Pass in the current version number of the
 * assignment to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated assignment. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_supervisor_id Supervisor for the assignment. The value refers to
 * the supervisor's person record.
 * @param p_assignment_number Assignment number
 * @param p_change_reason Reason for the assignment status change. If there is
 * no change reason the parameter can be null. Valid values are defined in the
 * EMP_ASSIGN_REASON lookup type.
 * @param p_comments Comment text.
 * @param p_date_probation_end End date of probation period
 * @param p_default_code_comb_id Identifier for the General Ledger Accounting
 * Flexfield combination which applies to this assignment
 * @param p_frequency Frequency associated with the defined normal working
 * hours. Valid values are defined in the FREQUENCY lookup type.
 * @param p_internal_address_line Internal address identified with this
 * assignment.
 * @param p_manager_flag Indicates whether the employee is a manager
 * @param p_normal_hours Normal working hours for this assignment
 * @param p_perf_review_period Length of performance review period
 * @param p_perf_review_period_frequency Units of performance review period.
 * Valid values are defined in the FREQUENCY lookup type.
 * @param p_probation_period Length of probation period
 * @param p_probation_unit Units of probation period. Valid values are defined
 * in the QUALIFYING_UNITS lookup type.
 * @param p_sal_review_period Length of salary review period
 * @param p_sal_review_period_frequency Units of salary review period. Valid
 * values are defined in the FREQUENCY lookup type.
 * @param p_set_of_books_id Identifies General Ledger set of books.
 * @param p_source_type Recruitment activity which this assignment is sourced
 * from. Valid values are defined in the REC_TYPE lookup type.
 * @param p_time_normal_finish Normal work finish time
 * @param p_time_normal_start Normal work start time
 * @param p_bargaining_unit_code Code for bargaining unit. Valid values are
 * defined in the BARGAINING_UNIT_CODE lookup type.
 * @param p_labour_union_member_flag Value 'Y' indicates employee is a labour
 * union member. Other values indicate not a member.
 * @param p_hourly_salaried_code Identifies if the assignment is paid hourly or
 * is salaried. Valid values defined in the HOURLY_SALARIED_CODE lookup type.
 * @param p_ass_attribute_category This context value determines which
 * Flexfield Structure to use with the Descriptive flexfield segments.
 * @param p_ass_attribute1 Descriptive flexfield segment
 * @param p_ass_attribute2 Descriptive flexfield segment
 * @param p_ass_attribute3 Descriptive flexfield segment
 * @param p_ass_attribute4 Descriptive flexfield segment
 * @param p_ass_attribute5 Descriptive flexfield segment
 * @param p_ass_attribute6 Descriptive flexfield segment
 * @param p_ass_attribute7 Descriptive flexfield segment
 * @param p_ass_attribute8 Descriptive flexfield segment
 * @param p_ass_attribute9 Descriptive flexfield segment
 * @param p_ass_attribute10 Descriptive flexfield segment
 * @param p_ass_attribute11 Descriptive flexfield segment
 * @param p_ass_attribute12 Descriptive flexfield segment
 * @param p_ass_attribute13 Descriptive flexfield segment
 * @param p_ass_attribute14 Descriptive flexfield segment
 * @param p_ass_attribute15 Descriptive flexfield segment
 * @param p_ass_attribute16 Descriptive flexfield segment
 * @param p_ass_attribute17 Descriptive flexfield segment
 * @param p_ass_attribute18 Descriptive flexfield segment
 * @param p_ass_attribute19 Descriptive flexfield segment
 * @param p_ass_attribute20 Descriptive flexfield segment
 * @param p_ass_attribute21 Descriptive flexfield segment
 * @param p_ass_attribute22 Descriptive flexfield segment
 * @param p_ass_attribute23 Descriptive flexfield segment
 * @param p_ass_attribute24 Descriptive flexfield segment
 * @param p_ass_attribute25 Descriptive flexfield segment
 * @param p_ass_attribute26 Descriptive flexfield segment
 * @param p_ass_attribute27 Descriptive flexfield segment
 * @param p_ass_attribute28 Descriptive flexfield segment
 * @param p_ass_attribute29 Descriptive flexfield segment
 * @param p_ass_attribute30 Descriptive flexfield segment
 * @param p_title Obsolete parameter, do not use.
 * @param p_tax_unit Government Reporting Entity
 * @param p_timecard_approver Timecard Approver
 * @param p_timecard_required Indicates whether timecard is required
 * @param p_work_schedule Indicates the pattern of work for the assignment
 * @param p_shift Shift. Valid values are defined in US_SHIFTS lookup type.
 * @param p_spouse_salary Spouse's Salary
 * @param p_legal_representative Indicates if employee is a legal
 * representative
 * @param p_wc_override_code Workers Comp Override Code
 * @param p_eeo_1_establishment Reporting Establishment
 * @param p_contract_id Contract associated with this assignment
 * @param p_establishment_id For French business groups, this identifies the
 * Establishment Legal Entity for this assignment.
 * @param p_collective_agreement_id Collective Agreement that applies to this
 * assignment
 * @param p_cagr_id_flex_num Identifier for the structure from CAGR Key
 * flexfield to use for this assignment
 * @param p_notice_period Length of notice period
 * @param p_notice_period_uom Units for notice period. Valid values are defined
 * in the QUALIFYING_UNITS lookup type.
 * @param p_employee_category Employee Category. Valid values are defined in
 * the EMPLOYEE_CATG lookup type.
 * @param p_work_at_home Indicate whether this assignment is to work at home.
 * Valid values are defined in the YES_NO lookup type.
 * @param p_job_post_source_name Name of the source of the job posting that was
 * answered for this assignment.
 * @param p_supervisor_assignment_id Supervisor's assignment that is
 * responsible for supervising this assignment.
 * @param p_cagr_grade_def_id If a value is passed in for this parameter, it
 * identifies an existing CAGR Key Flexfield combination to associate with the
 * assignment, and segment values are ignored. If a value is not passed in,
 * then the individual CAGR Key Flexfield segments supplied will be used to
 * choose an existing combination or create a new combination. When the API
 * completes, if p_validate is false, then this uniquely identifies the
 * associated combination of the CAGR Key flexfield for this assignment. If
 * p_validate is true, then set to null.
 * @param p_cagr_concatenated_segments CAGR Key Flexfield concatenated segments
 * @param p_comment_id If p_validate is false and comment text was provided,
 * then will be set to the identifier of the created assignment comment record.
 * If p_validate is true or no comment text was provided, then will be null.
 * @param p_soft_coding_keyflex_id If a value is passed in for this parameter,
 * it identifies an existing Soft Coded Key Flexfield combination to associate
 * with the assignment, and segment values are ignored. If a value is not
 * passed in, then the individual Soft Coded Key Flexfield segments supplied
 * will be used to choose an existing combination or create a new combination.
 * When the API completes, if p_validate is false, then this uniquely
 * identifies the associated combination of the Soft Coded Key flexfield for
 * this assignment. If p_validate is true, then set to null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created assignment. If p_validate is
 * true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created assignment. If p_validate is true, then
 * set to null.
 * @param p_concatenated_segments If p_validate is false, set to Soft Coded Key
 * Flexfield concatenated segments, if p_validate is true, set to null.
 * @param p_concat_segments Concatenated segments for Soft Coded Key Flexfield.
 * Concatenated segments can be supplied instead of individual segments.
 * @param p_no_managers_warning Set to true if as a result of the update there
 * is no manager in the organization. Otherwise set to false.
 * @param p_other_manager_warning If set to true, then a manager existed in the
 * organization prior to calling this API and the manager flag has been set to
 * 'Y' for yes.
 * @param p_hourly_salaried_warning Set to true if values entered for Salary
 * Basis and Hourly Salaried Code are invalid date as of p_effective_date.
 * @param p_gsp_post_process_warning Set to the name of a warning message from
 * the Message Dictionary if any Grade Ladder related errors have been
 * encountered while running this API.
 * @rep:displayname Update Employee Assignment for United States
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE_ASG
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_us_emp_asg
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_supervisor_id                in     number   default hr_api.g_number
  ,p_assignment_number            in     varchar2 default hr_api.g_varchar2
  ,p_change_reason                in     varchar2 default hr_api.g_varchar2
  ,p_comments                     in     varchar2 default hr_api.g_varchar2
  ,p_date_probation_end           in     date     default hr_api.g_date
  ,p_default_code_comb_id         in     number   default hr_api.g_number
  ,p_frequency                    in     varchar2 default hr_api.g_varchar2
  ,p_internal_address_line        in     varchar2 default hr_api.g_varchar2
  ,p_manager_flag                 in     varchar2 default hr_api.g_varchar2
  ,p_normal_hours                 in     number   default hr_api.g_number
  ,p_perf_review_period           in     number   default hr_api.g_number
  ,p_perf_review_period_frequency in     varchar2 default hr_api.g_varchar2
  ,p_probation_period             in     number   default hr_api.g_number
  ,p_probation_unit               in     varchar2 default hr_api.g_varchar2
  ,p_sal_review_period            in     number   default hr_api.g_number
  ,p_sal_review_period_frequency  in     varchar2 default hr_api.g_varchar2
  ,p_set_of_books_id              in     number   default hr_api.g_number
  ,p_source_type                  in     varchar2 default hr_api.g_varchar2
  ,p_time_normal_finish           in     varchar2 default hr_api.g_varchar2
  ,p_time_normal_start            in     varchar2 default hr_api.g_varchar2
  ,p_bargaining_unit_code         in     varchar2 default hr_api.g_varchar2
  ,p_labour_union_member_flag     in     varchar2 default hr_api.g_varchar2
  ,p_hourly_salaried_code         in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute_category       in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute1               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute2               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute3               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute4               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute5               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute6               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute7               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute8               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute9               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute10              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute11              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute12              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute13              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute14              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute15              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute16              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute17              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute18              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute19              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute20              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute21              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute22              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute23              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute24              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute25              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute26              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute27              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute28              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute29              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute30              in     varchar2 default hr_api.g_varchar2
  ,p_title                        in     varchar2 default hr_api.g_varchar2
  ,p_tax_unit                     in     varchar2 default hr_api.g_varchar2
  ,p_timecard_approver            in     varchar2 default hr_api.g_varchar2
  ,p_timecard_required            in     varchar2 default hr_api.g_varchar2
  ,p_work_schedule                in     varchar2 default hr_api.g_varchar2
  ,p_shift                        in     varchar2 default hr_api.g_varchar2
  ,p_spouse_salary                in     varchar2 default hr_api.g_varchar2
  ,p_legal_representative         in     varchar2 default hr_api.g_varchar2
  ,p_wc_override_code             in     varchar2 default hr_api.g_varchar2
  ,p_eeo_1_establishment          in     varchar2 default hr_api.g_varchar2
  ,p_contract_id                  in     number   default hr_api.g_number
  ,p_establishment_id             in     number   default hr_api.g_number
  ,p_collective_agreement_id      in     number   default hr_api.g_number
  ,p_cagr_id_flex_num             in     number   default hr_api.g_number
  ,p_notice_period		  in     number   default hr_api.g_number
  ,p_notice_period_uom	      	  in     varchar2 default hr_api.g_varchar2
  ,p_employee_category	          in     varchar2 default hr_api.g_varchar2
  ,p_work_at_home		  in     varchar2 default hr_api.g_varchar2
  ,p_job_post_source_name	  in     varchar2 default hr_api.g_varchar2
  ,p_supervisor_assignment_id     in     number   default hr_api.g_number
  ,p_cagr_grade_def_id               out nocopy number
  ,p_cagr_concatenated_segments      out nocopy varchar2
  ,p_comment_id                      out nocopy number
  ,p_soft_coding_keyflex_id          out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
-- Bug 944911
-- Amended p_concatenated_segments to be out
-- Added p_concat_segments  - in param
  ,p_concatenated_segments           out nocopy varchar2
  ,p_concat_segments              in     varchar2 default hr_api.g_varchar2
  ,p_no_managers_warning             out nocopy boolean
  ,p_other_manager_warning           out nocopy boolean
  ,p_hourly_salaried_warning         out nocopy boolean
  ,p_gsp_post_process_warning        out nocopy varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_emp_asg_criteria >----------------------|
-- ----------------------------------------------------------------------------
--
-- This version of the API is now out-of-date however it has been provided to
-- you for backward compatibility support and will be removed in the future.
-- Oracle recommends you to modify existing calling programs in advance of the
-- support being withdrawn thus avoiding any potential disruption.
--
procedure update_emp_asg_criteria
  (p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_validate                     in     boolean  default false
  ,p_called_from_mass_update      in     boolean  default false
  ,p_grade_id                     in     number   default hr_api.g_number
  ,p_position_id                  in     number   default hr_api.g_number
  ,p_job_id                       in     number   default hr_api.g_number
  ,p_payroll_id                   in     number   default hr_api.g_number
  ,p_location_id                  in     number   default hr_api.g_number
  ,p_organization_id              in     number   default hr_api.g_number
  ,p_pay_basis_id                 in     number   default hr_api.g_number
  ,p_segment1                     in     varchar2 default hr_api.g_varchar2
  ,p_segment2                     in     varchar2 default hr_api.g_varchar2
  ,p_segment3                     in     varchar2 default hr_api.g_varchar2
  ,p_segment4                     in     varchar2 default hr_api.g_varchar2
  ,p_segment5                     in     varchar2 default hr_api.g_varchar2
  ,p_segment6                     in     varchar2 default hr_api.g_varchar2
  ,p_segment7                     in     varchar2 default hr_api.g_varchar2
  ,p_segment8                     in     varchar2 default hr_api.g_varchar2
  ,p_segment9                     in     varchar2 default hr_api.g_varchar2
  ,p_segment10                    in     varchar2 default hr_api.g_varchar2
  ,p_segment11                    in     varchar2 default hr_api.g_varchar2
  ,p_segment12                    in     varchar2 default hr_api.g_varchar2
  ,p_segment13                    in     varchar2 default hr_api.g_varchar2
  ,p_segment14                    in     varchar2 default hr_api.g_varchar2
  ,p_segment15                    in     varchar2 default hr_api.g_varchar2
  ,p_segment16                    in     varchar2 default hr_api.g_varchar2
  ,p_segment17                    in     varchar2 default hr_api.g_varchar2
  ,p_segment18                    in     varchar2 default hr_api.g_varchar2
  ,p_segment19                    in     varchar2 default hr_api.g_varchar2
  ,p_segment20                    in     varchar2 default hr_api.g_varchar2
  ,p_segment21                    in     varchar2 default hr_api.g_varchar2
  ,p_segment22                    in     varchar2 default hr_api.g_varchar2
  ,p_segment23                    in     varchar2 default hr_api.g_varchar2
  ,p_segment24                    in     varchar2 default hr_api.g_varchar2
  ,p_segment25                    in     varchar2 default hr_api.g_varchar2
  ,p_segment26                    in     varchar2 default hr_api.g_varchar2
  ,p_segment27                    in     varchar2 default hr_api.g_varchar2
  ,p_segment28                    in     varchar2 default hr_api.g_varchar2
  ,p_segment29                    in     varchar2 default hr_api.g_varchar2
  ,p_segment30                    in     varchar2 default hr_api.g_varchar2
  ,p_employment_category          in     varchar2 default hr_api.g_varchar2
-- Bug 944911
-- Amended p_group_name to out
-- Added new param p_pgp_concat_segments for sec asg procs
-- for others added p_concat_segments
  ,p_concat_segments              in     varchar2 default hr_api.g_varchar2
  ,p_grade_ladder_pgm_id          in     number   default hr_api.g_number
  ,p_supervisor_assignment_id     in     number   default hr_api.g_number
  ,p_people_group_id              in out nocopy number -- bug 2359997
  ,p_object_version_number        in out nocopy number
  ,p_special_ceiling_step_id      in out nocopy number
  ,p_group_name                      out nocopy varchar2
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_org_now_no_manager_warning      out nocopy boolean
  ,p_other_manager_warning           out nocopy boolean
  ,p_spp_delete_warning              out nocopy boolean
  ,p_entries_changed_warning         out nocopy varchar2
  ,p_tax_district_changed_warning    out nocopy boolean
  );


--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_emp_asg_criteria >----------------------|
-- ----------------------------------------------------------------------------
--
-- This version of the API is now out-of-date however it has been provided to
-- you for backward compatibility support and will be removed in the future.
-- Oracle recommends you to modify existing calling programs in advance of the
-- support being withdrawn thus avoiding any potential disruption.
--

procedure update_emp_asg_criteria
  (p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_validate                     in     boolean  default false
  ,p_called_from_mass_update      in     boolean  default false
  ,p_grade_id                     in     number   default hr_api.g_number
  ,p_position_id                  in     number   default hr_api.g_number
  ,p_job_id                       in     number   default hr_api.g_number
  ,p_payroll_id                   in     number   default hr_api.g_number
  ,p_location_id                  in     number   default hr_api.g_number
  ,p_organization_id              in     number   default hr_api.g_number
  ,p_pay_basis_id                 in     number   default hr_api.g_number
  ,p_segment1                     in     varchar2 default hr_api.g_varchar2
  ,p_segment2                     in     varchar2 default hr_api.g_varchar2
  ,p_segment3                     in     varchar2 default hr_api.g_varchar2
  ,p_segment4                     in     varchar2 default hr_api.g_varchar2
  ,p_segment5                     in     varchar2 default hr_api.g_varchar2
  ,p_segment6                     in     varchar2 default hr_api.g_varchar2
  ,p_segment7                     in     varchar2 default hr_api.g_varchar2
  ,p_segment8                     in     varchar2 default hr_api.g_varchar2
  ,p_segment9                     in     varchar2 default hr_api.g_varchar2
  ,p_segment10                    in     varchar2 default hr_api.g_varchar2
  ,p_segment11                    in     varchar2 default hr_api.g_varchar2
  ,p_segment12                    in     varchar2 default hr_api.g_varchar2
  ,p_segment13                    in     varchar2 default hr_api.g_varchar2
  ,p_segment14                    in     varchar2 default hr_api.g_varchar2
  ,p_segment15                    in     varchar2 default hr_api.g_varchar2
  ,p_segment16                    in     varchar2 default hr_api.g_varchar2
  ,p_segment17                    in     varchar2 default hr_api.g_varchar2
  ,p_segment18                    in     varchar2 default hr_api.g_varchar2
  ,p_segment19                    in     varchar2 default hr_api.g_varchar2
  ,p_segment20                    in     varchar2 default hr_api.g_varchar2
  ,p_segment21                    in     varchar2 default hr_api.g_varchar2
  ,p_segment22                    in     varchar2 default hr_api.g_varchar2
  ,p_segment23                    in     varchar2 default hr_api.g_varchar2
  ,p_segment24                    in     varchar2 default hr_api.g_varchar2
  ,p_segment25                    in     varchar2 default hr_api.g_varchar2
  ,p_segment26                    in     varchar2 default hr_api.g_varchar2
  ,p_segment27                    in     varchar2 default hr_api.g_varchar2
  ,p_segment28                    in     varchar2 default hr_api.g_varchar2
  ,p_segment29                    in     varchar2 default hr_api.g_varchar2
  ,p_segment30                    in     varchar2 default hr_api.g_varchar2
  ,p_employment_category          in     varchar2 default hr_api.g_varchar2
-- Bug 944911
-- Amended p_group_name to out
-- Added new param p_pgp_concat_segments  for sec asg procs
-- for others added p_concat_segments
  ,p_concat_segments              in     varchar2 default hr_api.g_varchar2
  ,p_contract_id                  in     number  default hr_api.g_number   -- bug 2622747
  ,p_establishment_id             in     number  default hr_api.g_number   -- bug 2622747
  ,p_scl_segment1                 in     varchar2 default hr_api.g_varchar2   -- bug 2622747
  ,p_grade_ladder_pgm_id          in     number  default hr_api.g_number
  ,p_supervisor_assignment_id     in     number  default hr_api.g_number
  ,p_object_version_number        in out nocopy number
  ,p_special_ceiling_step_id      in out nocopy number
  ,p_people_group_id              in out nocopy number -- bug 2359997
  ,p_soft_coding_keyflex_id       in out nocopy number   -- bug 2622747
  ,p_group_name                      out nocopy varchar2
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_org_now_no_manager_warning      out nocopy boolean
  ,p_other_manager_warning           out nocopy boolean
  ,p_spp_delete_warning              out nocopy boolean
  ,p_entries_changed_warning         out nocopy varchar2
  ,p_tax_district_changed_warning    out nocopy boolean
  ,p_concatenated_segments           out nocopy varchar2 -- bug 2622747
  );

--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_emp_asg_criteria >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates attributes of the employee assignment that affect the
 * entitlement criteria for any element entry.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The assignment must be an employee assignment. The assignment must exist as
 * of the effective date of the change
 *
 * <p><b>Post Success</b><br>
 * The API updates the assignment.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the assignment and raises an error.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_datetrack_update_mode Indicates which DateTrack mode to use when
 * updating the record. You must set to either UPDATE, CORRECTION,
 * UPDATE_OVERRIDE or UPDATE_CHANGE_INSERT. Modes available for use with a
 * particular record depend on the dates of previous record changes and the
 * effective date of this change.
 * @param p_assignment_id Identifies the assignment record to be modified.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_called_from_mass_update Set to TRUE if the API is called from the
 * Mass Update Processes. This defaults Job and Organization information from
 * the Position information, if the first two are not supplied.
 * @param p_grade_id Identifies the grade of the assignment
 * @param p_position_id Identifies the position of the assignment
 * @param p_job_id Identifies the job of the assignment
 * @param p_payroll_id Identifies the payroll of this assignment.
 * @param p_location_id Identifies the location of the assignment
 * @param p_organization_id Identifies the organization of the assignment
 * @param p_pay_basis_id Salary basis for the assignment
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
 * @param p_employment_category Employment category. Valid values are defined
 * in the EMP_CAT lookup type.
 * @param p_concat_segments Concatenated Key Flexfield segments
 * @param p_contract_id Contract associated with this assignment
 * @param p_establishment_id For French business groups, this identifies the
 * Establishment Legal Entity for this assignment.
 * @param p_scl_segment1 First segment from Soft Coded Key Flexfield.
 * @param p_grade_ladder_pgm_id Grade Ladder for this assignment
 * @param p_supervisor_assignment_id Supervisor's assignment which is
 * responsible for supervising this assignment.
 * @param p_object_version_number Pass in the current version number of the
 * assignment to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated assignment. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_special_ceiling_step_id Pass in the highest allowed step for the
 * grade scale associated with the grade of the assignment. Will be set to null
 * if the Grade is updated to null. If p_validate is false, will be set to the
 * value of the Ceiling step from the database. If p_validate is true will be
 * set to the value passed in.
 * @param p_people_group_id If a value is passed in for this parameter, it
 * identifies an existing People Group Key Flexfield combination to associate
 * with the assignment, and segment values are ignored. If a value is not
 * passed in, then the individual People Group Key Flexfield segments supplied
 * will be used to choose an existing combination or create a new combination.
 * When the API completes, if p_validate is false, then this uniquely
 * identifies the associated combination of the People Group Key flexfield for
 * this assignment. If p_validate is true, then set to null.
 * @param p_soft_coding_keyflex_id If a value is passed in for this parameter,
 * it identifies an existing Soft Coded Key Flexfield combination to associate
 * with the assignment, and segment values are ignored. If a value is not
 * passed in, then the individual Soft Coded Key Flexfield segments supplied
 * will be used to choose an existing combination or create a new combination.
 * When the API completes, if p_validate is false, then this uniquely
 * identifies the associated combination of the Soft Coded Key flexfield for
 * this assignment. If p_validate is true, then set to null.
 * @param p_group_name If p_validate is false, set to the People Group Key
 * Flexfield concatenated segments. If p_validate is true, set to null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated assignment row which now exists as of
 * the effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated assignment row which now exists as of the
 * effective date. If p_validate is true, then set to null.
 * @param p_org_now_no_manager_warning Set to true if this assignment is a
 * manager, the organization is updated and there is now no manager in the
 * previous organization. Set to false if another manager exists in the
 * previous organization.
 * @param p_other_manager_warning If set to true, then a manager existed in the
 * organization prior to calling this API and the manager flag has been set to
 * 'Y' for yes.
 * @param p_spp_delete_warning Set to true when grade step and point placements
 * are date effectively ended or purged by this update. Both types of change
 * occur when the Grade is changed and spinal point placement rows exist over
 * the updated date range. Set to false when no grade step and point placements
 * are affected.
 * @param p_entries_changed_warning Set to 'Y' when one or more element entries
 * are changed due to the assignment change. Set to 'S' if at least one salary
 * element entry is affected. ('S' is a more specific case of 'Y') Set to 'N'
 * when no element entries are changed.
 * @param p_tax_district_changed_warning Set to true if the assignment is for a
 * United Kingdom legislation and the payroll has changed such that. Otherwise
 * set to false.
 * @param p_concatenated_segments If p_validate is false, set to Soft Coded Key
 * Flexfield concatenated segments, if p_validate is true, set to null.
 * @param p_gsp_post_process_warning Set to the name of a warning message from
 * the Message Dictionary if any Grade Ladder related errors have been
 * encountered while running this API.
 * @rep:displayname Update Employee Assignment Criteria
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE_ASG
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_emp_asg_criteria
  (p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_validate                     in     boolean  default false
  ,p_called_from_mass_update      in     boolean  default false
  ,p_grade_id                     in     number   default hr_api.g_number
  ,p_position_id                  in     number   default hr_api.g_number
  ,p_job_id                       in     number   default hr_api.g_number
  ,p_payroll_id                   in     number   default hr_api.g_number
  ,p_location_id                  in     number   default hr_api.g_number
  ,p_organization_id              in     number   default hr_api.g_number
  ,p_pay_basis_id                 in     number   default hr_api.g_number
  ,p_segment1                     in     varchar2 default hr_api.g_varchar2
  ,p_segment2                     in     varchar2 default hr_api.g_varchar2
  ,p_segment3                     in     varchar2 default hr_api.g_varchar2
  ,p_segment4                     in     varchar2 default hr_api.g_varchar2
  ,p_segment5                     in     varchar2 default hr_api.g_varchar2
  ,p_segment6                     in     varchar2 default hr_api.g_varchar2
  ,p_segment7                     in     varchar2 default hr_api.g_varchar2
  ,p_segment8                     in     varchar2 default hr_api.g_varchar2
  ,p_segment9                     in     varchar2 default hr_api.g_varchar2
  ,p_segment10                    in     varchar2 default hr_api.g_varchar2
  ,p_segment11                    in     varchar2 default hr_api.g_varchar2
  ,p_segment12                    in     varchar2 default hr_api.g_varchar2
  ,p_segment13                    in     varchar2 default hr_api.g_varchar2
  ,p_segment14                    in     varchar2 default hr_api.g_varchar2
  ,p_segment15                    in     varchar2 default hr_api.g_varchar2
  ,p_segment16                    in     varchar2 default hr_api.g_varchar2
  ,p_segment17                    in     varchar2 default hr_api.g_varchar2
  ,p_segment18                    in     varchar2 default hr_api.g_varchar2
  ,p_segment19                    in     varchar2 default hr_api.g_varchar2
  ,p_segment20                    in     varchar2 default hr_api.g_varchar2
  ,p_segment21                    in     varchar2 default hr_api.g_varchar2
  ,p_segment22                    in     varchar2 default hr_api.g_varchar2
  ,p_segment23                    in     varchar2 default hr_api.g_varchar2
  ,p_segment24                    in     varchar2 default hr_api.g_varchar2
  ,p_segment25                    in     varchar2 default hr_api.g_varchar2
  ,p_segment26                    in     varchar2 default hr_api.g_varchar2
  ,p_segment27                    in     varchar2 default hr_api.g_varchar2
  ,p_segment28                    in     varchar2 default hr_api.g_varchar2
  ,p_segment29                    in     varchar2 default hr_api.g_varchar2
  ,p_segment30                    in     varchar2 default hr_api.g_varchar2
  ,p_employment_category          in     varchar2 default hr_api.g_varchar2
-- Bug 944911
-- Amended p_group_name to out
-- Added new param p_pgp_concat_segments  for sec asg procs
-- for others added p_concat_segments
  ,p_concat_segments              in     varchar2 default hr_api.g_varchar2
  ,p_contract_id                  in     number  default hr_api.g_number   -- bug 2622747
  ,p_establishment_id             in     number  default hr_api.g_number   -- bug 2622747
  ,p_scl_segment1                 in     varchar2 default hr_api.g_varchar2   -- bug 2622747
  ,p_grade_ladder_pgm_id          in     number  default hr_api.g_number
  ,p_supervisor_assignment_id     in     number  default hr_api.g_number
  ,p_object_version_number        in out nocopy number
  ,p_special_ceiling_step_id      in out nocopy number
  ,p_people_group_id              in out nocopy number -- bug 2359997
  ,p_soft_coding_keyflex_id       in out nocopy number   -- bug 2622747
  ,p_group_name                      out nocopy varchar2
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_org_now_no_manager_warning      out nocopy boolean
  ,p_other_manager_warning           out nocopy boolean
  ,p_spp_delete_warning              out nocopy boolean
  ,p_entries_changed_warning         out nocopy varchar2
  ,p_tax_district_changed_warning    out nocopy boolean
  ,p_concatenated_segments           out nocopy varchar2 -- bug 2622747
  ,p_gsp_post_process_warning        out nocopy varchar2
  );

--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_apl_asg >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates applicant assignment details.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The assignment must exist as of the effective date, and must be an applicant
 * assignment.
 *
 * <p><b>Post Success</b><br>
 * The API updates the assignment.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the assignment and raises an error.
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
 * @param p_assignment_id Identifies the assignment record to be modified.
 * @param p_object_version_number Pass in the current version number of the
 * assignment to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated assignment. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_recruiter_id Recruiter for the assignment. The value refers to the
 * recruiter's person record.
 * @param p_grade_id Identifies the grade of the assignment
 * @param p_position_id Identifies the position of the assignment
 * @param p_job_id Identifies the job of the assignment
 * @param p_payroll_id Identifies the payroll of the assignment
 * @param p_location_id Identifies the location of the assignment
 * @param p_person_referred_by_id Identifies the person record of the person
 * who referred the applicant.
 * @param p_supervisor_id Supervisor for the assignment. The value refers to
 * the supervisor's person record.
 * @param p_special_ceiling_step_id Highest allowed step for the grade scale
 * associated with the grade of the assignment.
 * @param p_recruitment_activity_id Identifies the Recruitment Activity from
 * which the applicant was found.
 * @param p_source_organization_id Identifies the Source organization.
 * @param p_organization_id Identifies the organization of the assignment
 * @param p_vacancy_id Identifies the vacancy which the applicant applied for.
 * @param p_pay_basis_id Salary basis for the assignment
 * @param p_application_id Identifies the application record to which this
 * assignment belongs.
 * @param p_change_reason Reason for the change in the assignment. Valid values
 * are defined in the APL_ASSIGN_REASON lookup type.
 * @param p_assignment_status_type_id Assignment status. The system status must
 * be the same as before the update. Otherwise one of the status change APIs
 * should be used.
 * @param p_comments Comment text.
 * @param p_date_probation_end End date of probation period
 * @param p_default_code_comb_id Identifier for the General Ledger Accounting
 * Flexfield combination which applies to this assignment
 * @param p_employment_category Employment category. Valid values are defined
 * in the EMP_CAT lookup type.
 * @param p_frequency Frequency associated with the defined normal working
 * hours. Valid values are defined in the FREQUENCY lookup type.
 * @param p_internal_address_line Internal address identified with this
 * assignment.
 * @param p_manager_flag Indicates whether the applicant is a manager
 * @param p_normal_hours Normal working hours for this assignment
 * @param p_perf_review_period Length of performance review period
 * @param p_perf_review_period_frequency Units of performance review period.
 * Valid values are defined in the FREQUENCY lookup type.
 * @param p_probation_period Length of probation period
 * @param p_probation_unit Units of probation period. Valid values are defined
 * in the QUALIFYING_UNITS lookup type.
 * @param p_sal_review_period Length of salary review period
 * @param p_sal_review_period_frequency Units of salary review period. Valid
 * values are defined in the FREQUENCY lookup type.
 * @param p_set_of_books_id Identifies General Ledger set of books.
 * @param p_source_type Recruitment activity which this assignment is sourced
 * from. Valid values are defined in the REC_TYPE lookup type.
 * @param p_time_normal_finish Normal work finish time
 * @param p_time_normal_start Normal work start time
 * @param p_bargaining_unit_code Code for bargaining unit. Valid values are
 * defined in the BARGAINING_UNIT_CODE lookup type.
 * @param p_ass_attribute_category This context value determines which
 * Flexfield Structure to use with the Descriptive flexfield segments.
 * @param p_ass_attribute1 Descriptive flexfield segment
 * @param p_ass_attribute2 Descriptive flexfield segment
 * @param p_ass_attribute3 Descriptive flexfield segment
 * @param p_ass_attribute4 Descriptive flexfield segment
 * @param p_ass_attribute5 Descriptive flexfield segment
 * @param p_ass_attribute6 Descriptive flexfield segment
 * @param p_ass_attribute7 Descriptive flexfield segment
 * @param p_ass_attribute8 Descriptive flexfield segment
 * @param p_ass_attribute9 Descriptive flexfield segment
 * @param p_ass_attribute10 Descriptive flexfield segment
 * @param p_ass_attribute11 Descriptive flexfield segment
 * @param p_ass_attribute12 Descriptive flexfield segment
 * @param p_ass_attribute13 Descriptive flexfield segment
 * @param p_ass_attribute14 Descriptive flexfield segment
 * @param p_ass_attribute15 Descriptive flexfield segment
 * @param p_ass_attribute16 Descriptive flexfield segment
 * @param p_ass_attribute17 Descriptive flexfield segment
 * @param p_ass_attribute18 Descriptive flexfield segment
 * @param p_ass_attribute19 Descriptive flexfield segment
 * @param p_ass_attribute20 Descriptive flexfield segment
 * @param p_ass_attribute21 Descriptive flexfield segment
 * @param p_ass_attribute22 Descriptive flexfield segment
 * @param p_ass_attribute23 Descriptive flexfield segment
 * @param p_ass_attribute24 Descriptive flexfield segment
 * @param p_ass_attribute25 Descriptive flexfield segment
 * @param p_ass_attribute26 Descriptive flexfield segment
 * @param p_ass_attribute27 Descriptive flexfield segment
 * @param p_ass_attribute28 Descriptive flexfield segment
 * @param p_ass_attribute29 Descriptive flexfield segment
 * @param p_ass_attribute30 Descriptive flexfield segment
 * @param p_title Obsolete parameter, do not use.
 * @param p_scl_segment1 Soft Coded key flexfield segment
 * @param p_scl_segment2 Soft Coded key flexfield segment
 * @param p_scl_segment3 Soft Coded key flexfield segment
 * @param p_scl_segment4 Soft Coded key flexfield segment
 * @param p_scl_segment5 Soft Coded key flexfield segment
 * @param p_scl_segment6 Soft Coded key flexfield segment
 * @param p_scl_segment7 Soft Coded key flexfield segment
 * @param p_scl_segment8 Soft Coded key flexfield segment
 * @param p_scl_segment9 Soft Coded key flexfield segment
 * @param p_scl_segment10 Soft Coded key flexfield segment
 * @param p_scl_segment11 Soft Coded key flexfield segment
 * @param p_scl_segment12 Soft Coded key flexfield segment
 * @param p_scl_segment13 Soft Coded key flexfield segment
 * @param p_scl_segment14 Soft Coded key flexfield segment
 * @param p_scl_segment15 Soft Coded key flexfield segment
 * @param p_scl_segment16 Soft Coded key flexfield segment
 * @param p_scl_segment17 Soft Coded key flexfield segment
 * @param p_scl_segment18 Soft Coded key flexfield segment
 * @param p_scl_segment19 Soft Coded key flexfield segment
 * @param p_scl_segment20 Soft Coded key flexfield segment
 * @param p_scl_segment21 Soft Coded key flexfield segment
 * @param p_scl_segment22 Soft Coded key flexfield segment
 * @param p_scl_segment23 Soft Coded key flexfield segment
 * @param p_scl_segment24 Soft Coded key flexfield segment
 * @param p_scl_segment25 Soft Coded key flexfield segment
 * @param p_scl_segment26 Soft Coded key flexfield segment
 * @param p_scl_segment27 Soft Coded key flexfield segment
 * @param p_scl_segment28 Soft Coded key flexfield segment
 * @param p_scl_segment29 Soft Coded key flexfield segment
 * @param p_scl_segment30 Soft Coded key flexfield segment
 * @param p_scl_concat_segments Concatenated segments for Soft Coded Key
 * Flexfield. Concatenated segments can be supplied instead of individual
 * segments.
 * @param p_concatenated_segments If p_validate is false, set to Soft Coded Key
 * Flexfield concatenated segments, if p_validate is true, set to null.
 * @param p_pgp_segment1 People group key flexfield segment
 * @param p_pgp_segment2 People group key flexfield segment
 * @param p_pgp_segment3 People group key flexfield segment
 * @param p_pgp_segment4 People group key flexfield segment
 * @param p_pgp_segment5 People group key flexfield segment
 * @param p_pgp_segment6 People group key flexfield segment
 * @param p_pgp_segment7 People group key flexfield segment
 * @param p_pgp_segment8 People group key flexfield segment
 * @param p_pgp_segment9 People group key flexfield segment
 * @param p_pgp_segment10 People group key flexfield segment
 * @param p_pgp_segment11 People group key flexfield segment
 * @param p_pgp_segment12 People group key flexfield segment
 * @param p_pgp_segment13 People group key flexfield segment
 * @param p_pgp_segment14 People group key flexfield segment
 * @param p_pgp_segment15 People group key flexfield segment
 * @param p_pgp_segment16 People group key flexfield segment
 * @param p_pgp_segment17 People group key flexfield segment
 * @param p_pgp_segment18 People group key flexfield segment
 * @param p_pgp_segment19 People group key flexfield segment
 * @param p_pgp_segment20 People group key flexfield segment
 * @param p_pgp_segment21 People group key flexfield segment
 * @param p_pgp_segment22 People group key flexfield segment
 * @param p_pgp_segment23 People group key flexfield segment
 * @param p_pgp_segment24 People group key flexfield segment
 * @param p_pgp_segment25 People group key flexfield segment
 * @param p_pgp_segment26 People group key flexfield segment
 * @param p_pgp_segment27 People group key flexfield segment
 * @param p_pgp_segment28 People group key flexfield segment
 * @param p_pgp_segment29 People group key flexfield segment
 * @param p_pgp_segment30 People group key flexfield segment
 * @param p_concat_segments Concatenated segments for People Group Key
 * Flexfield. Concatenated segments can be supplied instead of individual
 * segments.
 * @param p_contract_id Contract associated with this assignment
 * @param p_establishment_id For French business groups, this identifies the
 * Establishment Legal Entity for this assignment.
 * @param p_collective_agreement_id Collective Agreement that applies to this
 * assignment
 * @param p_cagr_id_flex_num Identifier for the structure from CAGR Key
 * flexfield to use for this assignment
 * @param p_cag_segment1 CAGR Key Flexfield segment
 * @param p_cag_segment2 CAGR Key Flexfield segment
 * @param p_cag_segment3 CAGR Key Flexfield segment
 * @param p_cag_segment4 CAGR Key Flexfield segment
 * @param p_cag_segment5 CAGR Key Flexfield segment
 * @param p_cag_segment6 CAGR Key Flexfield segment
 * @param p_cag_segment7 CAGR Key Flexfield segment
 * @param p_cag_segment8 CAGR Key Flexfield segment
 * @param p_cag_segment9 CAGR Key Flexfield segment
 * @param p_cag_segment10 CAGR Key Flexfield segment
 * @param p_cag_segment11 CAGR Key Flexfield segment
 * @param p_cag_segment12 CAGR Key Flexfield segment
 * @param p_cag_segment13 CAGR Key Flexfield segment
 * @param p_cag_segment14 CAGR Key Flexfield segment
 * @param p_cag_segment15 CAGR Key Flexfield segment
 * @param p_cag_segment16 CAGR Key Flexfield segment
 * @param p_cag_segment17 CAGR Key Flexfield segment
 * @param p_cag_segment18 CAGR Key Flexfield segment
 * @param p_cag_segment19 CAGR Key Flexfield segment
 * @param p_cag_segment20 CAGR Key Flexfield segment
 * @param p_notice_period Length of notice period
 * @param p_notice_period_uom Units for notice period. Valid values are defined
 * in the QUALIFYING_UNITS lookup type.
 * @param p_employee_category Employee Category. Valid values are defined in
 * the EMPLOYEE_CATG lookup type.
 * @param p_work_at_home Indicate whether this assignment is to work at home.
 * Valid values are defined in the YES_NO lookup type.
 * @param p_job_post_source_name Name of the source of the job posting which
 * was answered for this assignment.
 * @param p_posting_content_id Identifies the posting to which the applicant
 * has applied.
 * @param p_applicant_rank Applicant's rank.
 * @param p_grade_ladder_pgm_id Grade Ladder for this assignment
 * @param p_supervisor_assignment_id Supervisor's assignment that is
 * responsible for supervising this assignment.
 * @param p_cagr_grade_def_id If a value is passed in for this parameter, it
 * identifies an existing CAGR Key Flexfield combination to associate with the
 * assignment, and segment values are ignored. If a value is not passed in,
 * then the individual CAGR Key Flexfield segments supplied will be used to
 * choose an existing combination or create a new combination. When the API
 * completes, if p_validate is false, then this uniquely identifies the
 * associated combination of the CAGR Key flexfield for this assignment. If
 * p_validate is true, then set to null.
 * @param p_cagr_concatenated_segments If p_validate is false, set to the
 * concatenation of all CAGR Key Flexfield segments. If p_validate is true, set
 * to null.
 * @param p_group_name If p_validate is false, set to the People Group Key
 * Flexfield concatenated segments. If p_validate is true, set to null.
 * @param p_comment_id If p_validate is false and comment text was provided,
 * then will be set to the identifier of the created assignment comment record.
 * If p_validate is true or no comment text was provided, then will be null.
 * @param p_people_group_id If a value is passed in for this parameter, it
 * identifies an existing People Group Key Flexfield combination to associate
 * with the assignment, and segment values are ignored. If a value is not
 * passed in, then the individual People Group Key Flexfield segments supplied
 * will be used to choose an existing combination or create a new combination.
 * When the API completes, if p_validate is false, then this uniquely
 * identifies the associated combination of the People Group Key flexfield for
 * this assignment. If p_validate is true, then set to null.
 * @param p_soft_coding_keyflex_id If a value is passed in for this parameter,
 * it identifies an existing Soft Coded Key Flexfield combination to associate
 * with the assignment, and segment values are ignored. If a value is not
 * passed in, then the individual Soft Coded Key Flexfield segments supplied
 * will be used to choose an existing combination or create a new combination.
 * When the API completes, if p_validate is false, then this uniquely
 * identifies the associated combination of the Soft Coded Key flexfield for
 * this assignment. If p_validate is true, then set to null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date for the assignment row which now exists as of the
 * effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the assignment row which now exists as of the
 * effective date. If p_validate is true, then set to null.
 * @rep:displayname Update Applicant Assignment
 * @rep:category BUSINESS_ENTITY PER_APPLICANT_ASG
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_apl_asg
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_recruiter_id                 in     number   default hr_api.g_number
  ,p_grade_id                     in     number   default hr_api.g_number
  ,p_position_id                  in     number   default hr_api.g_number
  ,p_job_id                       in     number   default hr_api.g_number
  ,p_payroll_id                   in     number   default hr_api.g_number
  ,p_location_id                  in     number   default hr_api.g_number
  ,p_person_referred_by_id        in     number   default hr_api.g_number
  ,p_supervisor_id                in     number   default hr_api.g_number
  ,p_special_ceiling_step_id      in     number   default hr_api.g_number
  ,p_recruitment_activity_id      in     number   default hr_api.g_number
  ,p_source_organization_id       in     number   default hr_api.g_number
  ,p_organization_id              in     number   default hr_api.g_number
  ,p_vacancy_id                   in     number   default hr_api.g_number
  ,p_pay_basis_id                 in     number   default hr_api.g_number
  ,p_application_id               in     number   default hr_api.g_number
  ,p_change_reason                in     varchar2 default hr_api.g_varchar2
  ,p_assignment_status_type_id    in     number   default hr_api.g_number
  ,p_comments                     in     varchar2 default hr_api.g_varchar2
  ,p_date_probation_end           in     date     default hr_api.g_date
  ,p_default_code_comb_id         in     number   default hr_api.g_number
  ,p_employment_category          in     varchar2 default hr_api.g_varchar2
  ,p_frequency                    in     varchar2 default hr_api.g_varchar2
  ,p_internal_address_line        in     varchar2 default hr_api.g_varchar2
  ,p_manager_flag                 in     varchar2 default hr_api.g_varchar2
  ,p_normal_hours                 in     number   default hr_api.g_number
  ,p_perf_review_period           in     number   default hr_api.g_number
  ,p_perf_review_period_frequency in     varchar2 default hr_api.g_varchar2
  ,p_probation_period             in     number   default hr_api.g_number
  ,p_probation_unit               in     varchar2 default hr_api.g_varchar2
  ,p_sal_review_period            in     number   default hr_api.g_number
  ,p_sal_review_period_frequency  in     varchar2 default hr_api.g_varchar2
  ,p_set_of_books_id              in     number   default hr_api.g_number
  ,p_source_type                  in     varchar2 default hr_api.g_varchar2
  ,p_time_normal_finish           in     varchar2 default hr_api.g_varchar2
  ,p_time_normal_start            in     varchar2 default hr_api.g_varchar2
  ,p_bargaining_unit_code         in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute_category       in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute1               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute2               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute3               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute4               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute5               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute6               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute7               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute8               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute9               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute10              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute11              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute12              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute13              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute14              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute15              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute16              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute17              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute18              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute19              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute20              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute21              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute22              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute23              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute24              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute25              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute26              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute27              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute28              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute29              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute30              in     varchar2 default hr_api.g_varchar2
  ,p_title                        in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment1                 in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment2                 in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment3                 in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment4                 in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment5                 in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment6                 in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment7                 in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment8                 in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment9                 in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment10                in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment11                in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment12                in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment13                in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment14                in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment15                in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment16                in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment17                in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment18                in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment19                in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment20                in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment21                in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment22                in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment23                in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment24                in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment25                in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment26                in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment27                in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment28                in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment29                in     varchar2 default hr_api.g_varchar2
  ,p_scl_segment30                in     varchar2 default hr_api.g_varchar2
-- Bug 944911
-- Amended p_scl_concatenated_segments to be an out instead of in out
-- Added p_scl_concat_segments ( in param )
-- Amended p_scl_concatenated_segments to be p_concatenated_segments
  ,p_scl_concat_segments          in     varchar2 default hr_api.g_varchar2
  ,p_concatenated_segments       out nocopy varchar2
  ,p_pgp_segment1                 in     varchar2 default hr_api.g_varchar2
  ,p_pgp_segment2                 in     varchar2 default hr_api.g_varchar2
  ,p_pgp_segment3                 in     varchar2 default hr_api.g_varchar2
  ,p_pgp_segment4                 in     varchar2 default hr_api.g_varchar2
  ,p_pgp_segment5                 in     varchar2 default hr_api.g_varchar2
  ,p_pgp_segment6                 in     varchar2 default hr_api.g_varchar2
  ,p_pgp_segment7                 in     varchar2 default hr_api.g_varchar2
  ,p_pgp_segment8                 in     varchar2 default hr_api.g_varchar2
  ,p_pgp_segment9                 in     varchar2 default hr_api.g_varchar2
  ,p_pgp_segment10                in     varchar2 default hr_api.g_varchar2
  ,p_pgp_segment11                in     varchar2 default hr_api.g_varchar2
  ,p_pgp_segment12                in     varchar2 default hr_api.g_varchar2
  ,p_pgp_segment13                in     varchar2 default hr_api.g_varchar2
  ,p_pgp_segment14                in     varchar2 default hr_api.g_varchar2
  ,p_pgp_segment15                in     varchar2 default hr_api.g_varchar2
  ,p_pgp_segment16                in     varchar2 default hr_api.g_varchar2
  ,p_pgp_segment17                in     varchar2 default hr_api.g_varchar2
  ,p_pgp_segment18                in     varchar2 default hr_api.g_varchar2
  ,p_pgp_segment19                in     varchar2 default hr_api.g_varchar2
  ,p_pgp_segment20                in     varchar2 default hr_api.g_varchar2
  ,p_pgp_segment21                in     varchar2 default hr_api.g_varchar2
  ,p_pgp_segment22                in     varchar2 default hr_api.g_varchar2
  ,p_pgp_segment23                in     varchar2 default hr_api.g_varchar2
  ,p_pgp_segment24                in     varchar2 default hr_api.g_varchar2
  ,p_pgp_segment25                in     varchar2 default hr_api.g_varchar2
  ,p_pgp_segment26                in     varchar2 default hr_api.g_varchar2
  ,p_pgp_segment27                in     varchar2 default hr_api.g_varchar2
  ,p_pgp_segment28                in     varchar2 default hr_api.g_varchar2
  ,p_pgp_segment29                in     varchar2 default hr_api.g_varchar2
  ,p_pgp_segment30                in     varchar2 default hr_api.g_varchar2
-- Bug 944911
-- Amended p_group_name to out
-- Added new param p_pgp_concat_segments - for sec asg procs
-- for others added p_concat_segments
  ,p_concat_segments		  in     varchar2 default hr_api.g_varchar2
  ,p_contract_id                  in     number default hr_api.g_number
  ,p_establishment_id             in     number default hr_api.g_number
  ,p_collective_agreement_id      in     number default hr_api.g_number
  ,p_cagr_id_flex_num             in     number default hr_api.g_number
  ,p_cag_segment1                 in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment2                 in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment3                 in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment4                 in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment5                 in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment6                 in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment7                 in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment8                 in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment9                 in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment10                in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment11                in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment12                in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment13                in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment14                in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment15                in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment16                in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment17                in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment18                in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment19                in     varchar2 default hr_api.g_varchar2
  ,p_cag_segment20                in     varchar2 default hr_api.g_varchar2
  ,p_notice_period		  in     number   default hr_api.g_number
  ,p_notice_period_uom	      	  in     varchar2 default hr_api.g_varchar2
  ,p_employee_category	          in     varchar2 default hr_api.g_varchar2
  ,p_work_at_home		  in     varchar2 default hr_api.g_varchar2
  ,p_job_post_source_name	  in     varchar2 default hr_api.g_varchar2
  ,p_posting_content_id           in     number   default hr_api.g_number
  ,p_applicant_rank               in     number   default hr_api.g_number
  ,p_grade_ladder_pgm_id          in     number   default hr_api.g_number
  ,p_supervisor_assignment_id     in     number   default hr_api.g_number
  ,p_cagr_grade_def_id            in out nocopy number
  ,p_cagr_concatenated_segments      out nocopy varchar2
  ,p_group_name                      out nocopy varchar2
  ,p_comment_id                      out nocopy number
  ,p_people_group_id              in out nocopy number
  ,p_soft_coding_keyflex_id       in out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
 );
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_apl_asg >--------------------------|
-- ----------------------------------------------------------------------------
--
-- This version of the API is now out-of-date however it has been provided to
-- you for backward compatibility support and will be removed in the future.
-- Oracle recommends you to modify existing calling programs in advance of the
-- support being withdrawn thus avoiding any potential disruption.
--
procedure update_apl_asg
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_grade_id                     in     number   default hr_api.g_number
  ,p_job_id                       in     number   default hr_api.g_number
  ,p_location_id                  in     number   default hr_api.g_number
  ,p_organization_id              in     number   default hr_api.g_number
  ,p_position_id                  in     number   default hr_api.g_number
  ,p_application_id               in     number   default hr_api.g_number
  ,p_recruiter_id                 in     number   default hr_api.g_number
  ,p_recruitment_activity_id      in     number   default hr_api.g_number
  ,p_vacancy_id                   in     number   default hr_api.g_number
  ,p_person_referred_by_id        in     number   default hr_api.g_number
  ,p_supervisor_id                in     number   default hr_api.g_number
  ,p_source_organization_id       in     number   default hr_api.g_number
  ,p_change_reason                in     varchar2 default hr_api.g_varchar2
  ,p_frequency                    in     varchar2 default hr_api.g_varchar2
  ,p_manager_flag                 in     varchar2 default hr_api.g_varchar2
  ,p_normal_hours                 in     number   default hr_api.g_number
  ,p_probation_period             in     number   default hr_api.g_number
  ,p_probation_unit               in     varchar2 default hr_api.g_varchar2
  ,p_source_type                  in     varchar2 default hr_api.g_varchar2
  ,p_time_normal_finish           in     varchar2 default hr_api.g_varchar2
  ,p_time_normal_start            in     varchar2 default hr_api.g_varchar2
  ,p_comments                     in     varchar2 default hr_api.g_varchar2
  ,p_date_probation_end           in     date     default hr_api.g_date
  ,p_title                        in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute_category       in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute1               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute2               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute3               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute4               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute5               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute6               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute7               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute8               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute9               in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute10              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute11              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute12              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute13              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute14              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute15              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute16              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute17              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute18              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute19              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute20              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute21              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute22              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute23              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute24              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute25              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute26              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute27              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute28              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute29              in     varchar2 default hr_api.g_varchar2
  ,p_ass_attribute30              in     varchar2 default hr_api.g_varchar2
  ,p_segment1                     in     varchar2 default hr_api.g_varchar2
  ,p_segment2                     in     varchar2 default hr_api.g_varchar2
  ,p_segment3                     in     varchar2 default hr_api.g_varchar2
  ,p_segment4                     in     varchar2 default hr_api.g_varchar2
  ,p_segment5                     in     varchar2 default hr_api.g_varchar2
  ,p_segment6                     in     varchar2 default hr_api.g_varchar2
  ,p_segment7                     in     varchar2 default hr_api.g_varchar2
  ,p_segment8                     in     varchar2 default hr_api.g_varchar2
  ,p_segment9                     in     varchar2 default hr_api.g_varchar2
  ,p_segment10                    in     varchar2 default hr_api.g_varchar2
  ,p_segment11                    in     varchar2 default hr_api.g_varchar2
  ,p_segment12                    in     varchar2 default hr_api.g_varchar2
  ,p_segment13                    in     varchar2 default hr_api.g_varchar2
  ,p_segment14                    in     varchar2 default hr_api.g_varchar2
  ,p_segment15                    in     varchar2 default hr_api.g_varchar2
  ,p_segment16                    in     varchar2 default hr_api.g_varchar2
  ,p_segment17                    in     varchar2 default hr_api.g_varchar2
  ,p_segment18                    in     varchar2 default hr_api.g_varchar2
  ,p_segment19                    in     varchar2 default hr_api.g_varchar2
  ,p_segment20                    in     varchar2 default hr_api.g_varchar2
  ,p_segment21                    in     varchar2 default hr_api.g_varchar2
  ,p_segment22                    in     varchar2 default hr_api.g_varchar2
  ,p_segment23                    in     varchar2 default hr_api.g_varchar2
  ,p_segment24                    in     varchar2 default hr_api.g_varchar2
  ,p_segment25                    in     varchar2 default hr_api.g_varchar2
  ,p_segment26                    in     varchar2 default hr_api.g_varchar2
  ,p_segment27                    in     varchar2 default hr_api.g_varchar2
  ,p_segment28                    in     varchar2 default hr_api.g_varchar2
  ,p_segment29                    in     varchar2 default hr_api.g_varchar2
  ,p_segment30                    in     varchar2 default hr_api.g_varchar2
  ,p_supervisor_assignment_id     in     number   default hr_api.g_number
-- Bug 944911
-- Amended p_concat_segments to be an in instead of in out
-- ,p_concat_segments             in     varchar2 default hr_api.g_varchar2
  ,p_concatenated_segments        in out nocopy varchar2
  ,p_comment_id                      out nocopy number -- in-out?
  ,p_people_group_id                 out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
 );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_secondary_apl_asg >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates an additional applicant assignment.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The person must exist as of the effective date. An application must be
 * active as of the effective date.
 *
 * <p><b>Post Success</b><br>
 * The API creates the applicant assignment.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the assignment and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_person_id Identifies the person for whom you create the assignment
 * record
 * @param p_organization_id Identifies the organization of the assignment
 * @param p_recruiter_id Recruiter for the assignment. The value refers to the
 * recruiter's person record.
 * @param p_grade_id Identifies the grade of the assignment
 * @param p_position_id Identifies the position of the assignment
 * @param p_job_id Identifies the job of the assignment
 * @param p_assignment_status_type_id Assignment status
 * @param p_payroll_id Identifies the payroll of the assignment
 * @param p_location_id Identifies the location of the assignment
 * @param p_person_referred_by_id Identifies the person record of the person
 * who referred the applicant.
 * @param p_supervisor_id Supervisor for the assignment. The value refers to
 * the supervisor's person record.
 * @param p_special_ceiling_step_id Highest allowed step for the grade scale
 * associated with the grade of the assignment.
 * @param p_recruitment_activity_id Identifies the Recruitment Activity from
 * which the applicant was found.
 * @param p_source_organization_id Identifies the Source organization.
 * @param p_vacancy_id Identifies the vacancy which the applicant applied for.
 * @param p_pay_basis_id Salary basis for the assignment
 * @param p_change_reason Reason for the change in the assignment. Valid values
 * are defined in the APL_ASSIGN_REASON lookup type.
 * @param p_comments Comment text.
 * @param p_date_probation_end End date of probation period
 * @param p_default_code_comb_id Identifier for the General Ledger Accounting
 * Flexfield combination that applies to this assignment
 * @param p_employment_category Employment category. Valid values are defined
 * in the EMP_CAT lookup type.
 * @param p_frequency Frequency associated with the defined normal working
 * hours. Valid values are defined in the FREQUENCY lookup type.
 * @param p_internal_address_line Internal address identified with this
 * assignment.
 * @param p_manager_flag Indicates whether the employee is a manager
 * @param p_normal_hours Normal working hours for this assignment
 * @param p_perf_review_period Length of performance review period
 * @param p_perf_review_period_frequency Units of performance review period.
 * Valid values are defined in the FREQUENCY lookup type.
 * @param p_probation_period Length of probation period
 * @param p_probation_unit Units of probation period. Valid values are defined
 * in the QUALIFYING_UNITS lookup type.
 * @param p_sal_review_period Length of salary review period
 * @param p_sal_review_period_frequency Units of salary review period. Valid
 * values are defined in the FREQUENCY lookup type.
 * @param p_set_of_books_id Identifies General Ledger set of books.
 * @param p_source_type Recruitment activity which this assignment is sourced
 * from. Valid values are defined in the REC_TYPE lookup type.
 * @param p_time_normal_finish Normal work finish time
 * @param p_time_normal_start Normal work start time
 * @param p_bargaining_unit_code Code for bargaining unit. Valid values are
 * defined in the BARGAINING_UNIT_CODE lookup type.
 * @param p_ass_attribute_category This context value determines which
 * Flexfield Structure to use with the Descriptive flexfield segments.
 * @param p_ass_attribute1 Descriptive flexfield segment
 * @param p_ass_attribute2 Descriptive flexfield segment
 * @param p_ass_attribute3 Descriptive flexfield segment
 * @param p_ass_attribute4 Descriptive flexfield segment
 * @param p_ass_attribute5 Descriptive flexfield segment
 * @param p_ass_attribute6 Descriptive flexfield segment
 * @param p_ass_attribute7 Descriptive flexfield segment
 * @param p_ass_attribute8 Descriptive flexfield segment
 * @param p_ass_attribute9 Descriptive flexfield segment
 * @param p_ass_attribute10 Descriptive flexfield segment
 * @param p_ass_attribute11 Descriptive flexfield segment
 * @param p_ass_attribute12 Descriptive flexfield segment
 * @param p_ass_attribute13 Descriptive flexfield segment
 * @param p_ass_attribute14 Descriptive flexfield segment
 * @param p_ass_attribute15 Descriptive flexfield segment
 * @param p_ass_attribute16 Descriptive flexfield segment
 * @param p_ass_attribute17 Descriptive flexfield segment
 * @param p_ass_attribute18 Descriptive flexfield segment
 * @param p_ass_attribute19 Descriptive flexfield segment
 * @param p_ass_attribute20 Descriptive flexfield segment
 * @param p_ass_attribute21 Descriptive flexfield segment
 * @param p_ass_attribute22 Descriptive flexfield segment
 * @param p_ass_attribute23 Descriptive flexfield segment
 * @param p_ass_attribute24 Descriptive flexfield segment
 * @param p_ass_attribute25 Descriptive flexfield segment
 * @param p_ass_attribute26 Descriptive flexfield segment
 * @param p_ass_attribute27 Descriptive flexfield segment
 * @param p_ass_attribute28 Descriptive flexfield segment
 * @param p_ass_attribute29 Descriptive flexfield segment
 * @param p_ass_attribute30 Descriptive flexfield segment
 * @param p_title Obsolete parameter, do not use.
 * @param p_scl_segment1 Soft Coded key flexfield segment
 * @param p_scl_segment2 Soft Coded key flexfield segment
 * @param p_scl_segment3 Soft Coded key flexfield segment
 * @param p_scl_segment4 Soft Coded key flexfield segment
 * @param p_scl_segment5 Soft Coded key flexfield segment
 * @param p_scl_segment6 Soft Coded key flexfield segment
 * @param p_scl_segment7 Soft Coded key flexfield segment
 * @param p_scl_segment8 Soft Coded key flexfield segment
 * @param p_scl_segment9 Soft Coded key flexfield segment
 * @param p_scl_segment10 Soft Coded key flexfield segment
 * @param p_scl_segment11 Soft Coded key flexfield segment
 * @param p_scl_segment12 Soft Coded key flexfield segment
 * @param p_scl_segment13 Soft Coded key flexfield segment
 * @param p_scl_segment14 Soft Coded key flexfield segment
 * @param p_scl_segment15 Soft Coded key flexfield segment
 * @param p_scl_segment16 Soft Coded key flexfield segment
 * @param p_scl_segment17 Soft Coded key flexfield segment
 * @param p_scl_segment18 Soft Coded key flexfield segment
 * @param p_scl_segment19 Soft Coded key flexfield segment
 * @param p_scl_segment20 Soft Coded key flexfield segment
 * @param p_scl_segment21 Soft Coded key flexfield segment
 * @param p_scl_segment22 Soft Coded key flexfield segment
 * @param p_scl_segment23 Soft Coded key flexfield segment
 * @param p_scl_segment24 Soft Coded key flexfield segment
 * @param p_scl_segment25 Soft Coded key flexfield segment
 * @param p_scl_segment26 Soft Coded key flexfield segment
 * @param p_scl_segment27 Soft Coded key flexfield segment
 * @param p_scl_segment28 Soft Coded key flexfield segment
 * @param p_scl_segment29 Soft Coded key flexfield segment
 * @param p_scl_segment30 Soft Coded key flexfield segment
 * @param p_scl_concat_segments Concatenated segments for Soft Coded Key
 * Flexfield. Concatenated segments can be supplied instead of individual
 * segments.
 * @param p_concatenated_segments If p_validate is false, set to Soft Coded Key
 * Flexfield concatenated segments, if p_validate is true, set to null.
 * @param p_pgp_segment1 People group key flexfield segment
 * @param p_pgp_segment2 People group key flexfield segment
 * @param p_pgp_segment3 People group key flexfield segment
 * @param p_pgp_segment4 People group key flexfield segment
 * @param p_pgp_segment5 People group key flexfield segment
 * @param p_pgp_segment6 People group key flexfield segment
 * @param p_pgp_segment7 People group key flexfield segment
 * @param p_pgp_segment8 People group key flexfield segment
 * @param p_pgp_segment9 People group key flexfield segment
 * @param p_pgp_segment10 People group key flexfield segment
 * @param p_pgp_segment11 People group key flexfield segment
 * @param p_pgp_segment12 People group key flexfield segment
 * @param p_pgp_segment13 People group key flexfield segment
 * @param p_pgp_segment14 People group key flexfield segment
 * @param p_pgp_segment15 People group key flexfield segment
 * @param p_pgp_segment16 People group key flexfield segment
 * @param p_pgp_segment17 People group key flexfield segment
 * @param p_pgp_segment18 People group key flexfield segment
 * @param p_pgp_segment19 People group key flexfield segment
 * @param p_pgp_segment20 People group key flexfield segment
 * @param p_pgp_segment21 People group key flexfield segment
 * @param p_pgp_segment22 People group key flexfield segment
 * @param p_pgp_segment23 People group key flexfield segment
 * @param p_pgp_segment24 People group key flexfield segment
 * @param p_pgp_segment25 People group key flexfield segment
 * @param p_pgp_segment26 People group key flexfield segment
 * @param p_pgp_segment27 People group key flexfield segment
 * @param p_pgp_segment28 People group key flexfield segment
 * @param p_pgp_segment29 People group key flexfield segment
 * @param p_pgp_segment30 People group key flexfield segment
 * @param p_concat_segments Concatenated segments for People Group Key
 * Flexfield. Concatenated segments can be supplied instead of individual
 * segments.
 * @param p_contract_id Contract associated with this assignment
 * @param p_establishment_id For French business groups, this identifies the
 * Establishment Legal Entity for this assignment.
 * @param p_collective_agreement_id Collective Agreement that applies to this
 * assignment
 * @param p_cagr_id_flex_num Identifier for the structure from CAGR Key
 * flexfield to use for this assignment
 * @param p_cag_segment1 CAGR Key Flexfield segment
 * @param p_cag_segment2 CAGR Key Flexfield segment
 * @param p_cag_segment3 CAGR Key Flexfield segment
 * @param p_cag_segment4 CAGR Key Flexfield segment
 * @param p_cag_segment5 CAGR Key Flexfield segment
 * @param p_cag_segment6 CAGR Key Flexfield segment
 * @param p_cag_segment7 CAGR Key Flexfield segment
 * @param p_cag_segment8 CAGR Key Flexfield segment
 * @param p_cag_segment9 CAGR Key Flexfield segment
 * @param p_cag_segment10 CAGR Key Flexfield segment
 * @param p_cag_segment11 CAGR Key Flexfield segment
 * @param p_cag_segment12 CAGR Key Flexfield segment
 * @param p_cag_segment13 CAGR Key Flexfield segment
 * @param p_cag_segment14 CAGR Key Flexfield segment
 * @param p_cag_segment15 CAGR Key Flexfield segment
 * @param p_cag_segment16 CAGR Key Flexfield segment
 * @param p_cag_segment17 CAGR Key Flexfield segment
 * @param p_cag_segment18 CAGR Key Flexfield segment
 * @param p_cag_segment19 CAGR Key Flexfield segment
 * @param p_cag_segment20 CAGR Key Flexfield segment
 * @param p_notice_period Length of notice period
 * @param p_notice_period_uom Units for notice period. Valid values are defined
 * in the QUALIFYING_UNITS lookup type.
 * @param p_employee_category Employee Category. Valid values are defined in
 * the EMPLOYEE_CATG lookup type.
 * @param p_work_at_home Indicate whether this assignment is to work at home.
 * Valid values are defined in the YES_NO lookup type.
 * @param p_job_post_source_name Name of the source of the job posting which
 * was answered for this assignment.
 * @param p_applicant_rank Applicant's rank.
 * @param p_posting_content_id Identifies the posting to which the applicant
 * has applied.
 * @param p_grade_ladder_pgm_id Grade Ladder for this assignment
 * @param p_supervisor_assignment_id Supervisor's assignment which is
 * responsible for supervising this assignment.
 * @param p_cagr_grade_def_id If a value is passed in for this parameter, it
 * identifies an existing CAGR Key Flexfield combination to associate with the
 * assignment, and segment values are ignored. If a value is not passed in,
 * then the individual CAGR Key Flexfield segments supplied will be used to
 * choose an existing combination or create a new combination. When the API
 * completes, if p_validate is false, then this uniquely identifies the
 * associated combination of the CAGR Key flexfield for this assignment. If
 * p_validate is true, then set to null.
 * @param p_cagr_concatenated_segments If p_validate is false, set to the
 * concatenation of all CAGR Key Flexfield segments. If p_validate is true, set
 * to null.
 * @param p_group_name If p_validate is false, set to the People Group Key
 * Flexfield concatenated segments. If p_validate is true, set to null.
 * @param p_assignment_id If p_validate is false, then this uniquely identifies
 * the created assignment. If p_validate is true, then set to null.
 * @param p_people_group_id If a value is passed in for this parameter, it
 * identifies an existing People Group Key Flexfield combination to associate
 * with the assignment, and segment values are ignored. If a value is not
 * passed in, then the individual People Group Key Flexfield segments supplied
 * will be used to choose an existing combination or create a new combination.
 * When the API completes, if p_validate is false, then this uniquely
 * identifies the associated combination of the People Group Key flexfield for
 * this assignment. If p_validate is true, then set to null.
 * @param p_soft_coding_keyflex_id If a value is passed in for this parameter,
 * it identifies an existing Soft Coded Key Flexfield combination to associate
 * with the assignment, and segment values are ignored. If a value is not
 * passed in, then the individual Soft Coded Key Flexfield segments supplied
 * will be used to choose an existing combination or create a new combination.
 * When the API completes, if p_validate is false, then this uniquely
 * identifies the associated combination of the Soft Coded Key flexfield for
 * this assignment. If p_validate is true, then set to null.
 * @param p_comment_id If p_validate is false and comment text was provided,
 * then will be set to the identifier of the created assignment comment record.
 * If p_validate is true or no comment text was provided, then will be null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created assignment. If p_validate is true, then the
 * value will be null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created assignment. If p_validate is
 * true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created assignment. If p_validate is true, then
 * set to null.
 * @param p_assignment_sequence If p_validate is false, set to assignment
 * sequence number. If p_validate is true, set to null.
 * @param p_appl_override_warning This value returns TRUE if any future
 * applications have been overriden.
 * @rep:displayname Create Secondary Applicant Assignment
 * @rep:category BUSINESS_ENTITY PER_APPLICANT_ASG
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_secondary_apl_asg
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_person_id                    in     number
  ,p_organization_id              in     number
  ,p_recruiter_id                 in     number   default null
  ,p_grade_id                     in     number   default null
  ,p_position_id                  in     number   default null
  ,p_job_id                       in     number   default null
  ,p_assignment_status_type_id    in     number   default null
  ,p_payroll_id                   in     number   default null
  ,p_location_id                  in     number   default null
  ,p_person_referred_by_id        in     number   default null
  ,p_supervisor_id                in     number   default null
  ,p_special_ceiling_step_id      in     number   default null
  ,p_recruitment_activity_id      in     number   default null
  ,p_source_organization_id       in     number   default null
  ,p_vacancy_id                   in     number   default null
  ,p_pay_basis_id                 in     number   default null
  ,p_change_reason                in     varchar2 default null
  ,p_comments                     in     varchar2 default null
  ,p_date_probation_end           in     date     default null
  ,p_default_code_comb_id         in     number   default null
  ,p_employment_category          in     varchar2 default null
  ,p_frequency                    in     varchar2 default null
  ,p_internal_address_line        in     varchar2 default null
  ,p_manager_flag                 in     varchar2 default 'N'
  ,p_normal_hours                 in     number   default null
  ,p_perf_review_period           in     number   default null
  ,p_perf_review_period_frequency in     varchar2 default null
  ,p_probation_period             in     number   default null
  ,p_probation_unit               in     varchar2 default null
  ,p_sal_review_period            in     number   default null
  ,p_sal_review_period_frequency  in     varchar2 default null
  ,p_set_of_books_id              in     number   default null
  ,p_source_type                  in     varchar2 default null
  ,p_time_normal_finish           in     varchar2 default null
  ,p_time_normal_start            in     varchar2 default null
  ,p_bargaining_unit_code         in     varchar2 default null
  ,p_ass_attribute_category       in     varchar2 default null
  ,p_ass_attribute1               in     varchar2 default null
  ,p_ass_attribute2               in     varchar2 default null
  ,p_ass_attribute3               in     varchar2 default null
  ,p_ass_attribute4               in     varchar2 default null
  ,p_ass_attribute5               in     varchar2 default null
  ,p_ass_attribute6               in     varchar2 default null
  ,p_ass_attribute7               in     varchar2 default null
  ,p_ass_attribute8               in     varchar2 default null
  ,p_ass_attribute9               in     varchar2 default null
  ,p_ass_attribute10              in     varchar2 default null
  ,p_ass_attribute11              in     varchar2 default null
  ,p_ass_attribute12              in     varchar2 default null
  ,p_ass_attribute13              in     varchar2 default null
  ,p_ass_attribute14              in     varchar2 default null
  ,p_ass_attribute15              in     varchar2 default null
  ,p_ass_attribute16              in     varchar2 default null
  ,p_ass_attribute17              in     varchar2 default null
  ,p_ass_attribute18              in     varchar2 default null
  ,p_ass_attribute19              in     varchar2 default null
  ,p_ass_attribute20              in     varchar2 default null
  ,p_ass_attribute21              in     varchar2 default null
  ,p_ass_attribute22              in     varchar2 default null
  ,p_ass_attribute23              in     varchar2 default null
  ,p_ass_attribute24              in     varchar2 default null
  ,p_ass_attribute25              in     varchar2 default null
  ,p_ass_attribute26              in     varchar2 default null
  ,p_ass_attribute27              in     varchar2 default null
  ,p_ass_attribute28              in     varchar2 default null
  ,p_ass_attribute29              in     varchar2 default null
  ,p_ass_attribute30              in     varchar2 default null
  ,p_title                        in     varchar2 default null
  ,p_scl_segment1                 in     varchar2 default null
  ,p_scl_segment2                 in     varchar2 default null
  ,p_scl_segment3                 in     varchar2 default null
  ,p_scl_segment4                 in     varchar2 default null
  ,p_scl_segment5                 in     varchar2 default null
  ,p_scl_segment6                 in     varchar2 default null
  ,p_scl_segment7                 in     varchar2 default null
  ,p_scl_segment8                 in     varchar2 default null
  ,p_scl_segment9                 in     varchar2 default null
  ,p_scl_segment10                in     varchar2 default null
  ,p_scl_segment11                in     varchar2 default null
  ,p_scl_segment12                in     varchar2 default null
  ,p_scl_segment13                in     varchar2 default null
  ,p_scl_segment14                in     varchar2 default null
  ,p_scl_segment15                in     varchar2 default null
  ,p_scl_segment16                in     varchar2 default null
  ,p_scl_segment17                in     varchar2 default null
  ,p_scl_segment18                in     varchar2 default null
  ,p_scl_segment19                in     varchar2 default null
  ,p_scl_segment20                in     varchar2 default null
  ,p_scl_segment21                in     varchar2 default null
  ,p_scl_segment22                in     varchar2 default null
  ,p_scl_segment23                in     varchar2 default null
  ,p_scl_segment24                in     varchar2 default null
  ,p_scl_segment25                in     varchar2 default null
  ,p_scl_segment26                in     varchar2 default null
  ,p_scl_segment27                in     varchar2 default null
  ,p_scl_segment28                in     varchar2 default null
  ,p_scl_segment29                in     varchar2 default null
  ,p_scl_segment30                in     varchar2 default null
-- Bug 944911
-- Amended p_scl_concatenated_segments to be an out instead of in out
-- Added new param p_scl_concat_segments
-- Amended p_scl_concatenated_segments to be p_concatenated_segments
  ,p_scl_concat_segments          in     varchar2 default null
  ,p_concatenated_segments       out nocopy varchar2
  ,p_pgp_segment1                 in     varchar2 default null
  ,p_pgp_segment2                 in     varchar2 default null
  ,p_pgp_segment3                 in     varchar2 default null
  ,p_pgp_segment4                 in     varchar2 default null
  ,p_pgp_segment5                 in     varchar2 default null
  ,p_pgp_segment6                 in     varchar2 default null
  ,p_pgp_segment7                 in     varchar2 default null
  ,p_pgp_segment8                 in     varchar2 default null
  ,p_pgp_segment9                 in     varchar2 default null
  ,p_pgp_segment10                in     varchar2 default null
  ,p_pgp_segment11                in     varchar2 default null
  ,p_pgp_segment12                in     varchar2 default null
  ,p_pgp_segment13                in     varchar2 default null
  ,p_pgp_segment14                in     varchar2 default null
  ,p_pgp_segment15                in     varchar2 default null
  ,p_pgp_segment16                in     varchar2 default null
  ,p_pgp_segment17                in     varchar2 default null
  ,p_pgp_segment18                in     varchar2 default null
  ,p_pgp_segment19                in     varchar2 default null
  ,p_pgp_segment20                in     varchar2 default null
  ,p_pgp_segment21                in     varchar2 default null
  ,p_pgp_segment22                in     varchar2 default null
  ,p_pgp_segment23                in     varchar2 default null
  ,p_pgp_segment24                in     varchar2 default null
  ,p_pgp_segment25                in     varchar2 default null
  ,p_pgp_segment26                in     varchar2 default null
  ,p_pgp_segment27                in     varchar2 default null
  ,p_pgp_segment28                in     varchar2 default null
  ,p_pgp_segment29                in     varchar2 default null
  ,p_pgp_segment30                in     varchar2 default null
-- Bug 944911
-- Amended p_group_name to out
-- Added new param p_pgp_concat_segments - for sec asg procs
-- for others added p_concat_segments
  ,p_concat_segments		  in     varchar2 default null
  ,p_contract_id                  in     number default null
  ,p_establishment_id             in     number default null
  ,p_collective_agreement_id      in     number default null
  ,p_cagr_id_flex_num             in     number default null
  ,p_cag_segment1                 in     varchar2  default null
  ,p_cag_segment2                 in     varchar2  default null
  ,p_cag_segment3                 in     varchar2  default null
  ,p_cag_segment4                 in     varchar2  default null
  ,p_cag_segment5                 in     varchar2  default null
  ,p_cag_segment6                 in     varchar2  default null
  ,p_cag_segment7                 in     varchar2  default null
  ,p_cag_segment8                 in     varchar2  default null
  ,p_cag_segment9                 in     varchar2  default null
  ,p_cag_segment10                in     varchar2  default null
  ,p_cag_segment11                in     varchar2  default null
  ,p_cag_segment12                in     varchar2  default null
  ,p_cag_segment13                in     varchar2  default null
  ,p_cag_segment14                in     varchar2  default null
  ,p_cag_segment15                in     varchar2  default null
  ,p_cag_segment16                in     varchar2  default null
  ,p_cag_segment17                in     varchar2  default null
  ,p_cag_segment18                in     varchar2  default null
  ,p_cag_segment19                in     varchar2  default null
  ,p_cag_segment20                in     varchar2  default null
  ,p_notice_period		  in	 number    default  null
  ,p_notice_period_uom		  in     varchar2  default  null
  ,p_employee_category		  in     varchar2  default  null
  ,p_work_at_home		  in	 varchar2  default  null
  ,p_job_post_source_name         in     varchar2  default  null
  ,p_applicant_rank               in     number    default  null
  ,p_posting_content_id           in     number    default  null
  ,p_grade_ladder_pgm_id          in     number    default  null
  ,p_supervisor_assignment_id     in     number    default  null
  ,p_cagr_grade_def_id            in out nocopy number
  ,p_cagr_concatenated_segments      out nocopy varchar2
  ,p_group_name                      out nocopy varchar2
  ,p_assignment_id                   out nocopy number
  ,p_people_group_id              in out nocopy number
  ,p_soft_coding_keyflex_id       in out nocopy number
  ,p_comment_id                      out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_assignment_sequence             out nocopy number
  ,p_appl_override_warning           OUT NOCOPY boolean  -- 3652025
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_secondary_apl_asg >---------------------|
-- ----------------------------------------------------------------------------
--
-- This version of the API is now out-of-date however it has been provided to
-- you for backward compatibility support and will be removed in the future.
-- Oracle recommends you to modify existing calling programs in advance of the
-- support being withdrawn thus avoiding any potential disruption.
--
procedure create_secondary_apl_asg
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_person_id                    in     number
  ,p_organization_id              in     number
  ,p_recruiter_id                 in     number   default null
  ,p_grade_id                     in     number   default null
  ,p_position_id                  in     number   default null
  ,p_job_id                       in     number   default null
  ,p_assignment_status_type_id    in     number   default null
  ,p_payroll_id                   in     number   default null
  ,p_location_id                  in     number   default null
  ,p_person_referred_by_id        in     number   default null
  ,p_supervisor_id                in     number   default null
  ,p_special_ceiling_step_id      in     number   default null
  ,p_recruitment_activity_id      in     number   default null
  ,p_source_organization_id       in     number   default null
  ,p_vacancy_id                   in     number   default null
  ,p_pay_basis_id                 in     number   default null
  ,p_change_reason                in     varchar2 default null
  ,p_comments                     in     varchar2 default null
  ,p_date_probation_end           in     date     default null
  ,p_default_code_comb_id         in     number   default null
  ,p_employment_category          in     varchar2 default null
  ,p_frequency                    in     varchar2 default null
  ,p_internal_address_line        in     varchar2 default null
  ,p_manager_flag                 in     varchar2 default 'N'
  ,p_normal_hours                 in     number   default null
  ,p_perf_review_period           in     number   default null
  ,p_perf_review_period_frequency in     varchar2 default null
  ,p_probation_period             in     number   default null
  ,p_probation_unit               in     varchar2 default null
  ,p_sal_review_period            in     number   default null
  ,p_sal_review_period_frequency  in     varchar2 default null
  ,p_set_of_books_id              in     number   default null
  ,p_source_type                  in     varchar2 default null
  ,p_time_normal_finish           in     varchar2 default null
  ,p_time_normal_start            in     varchar2 default null
  ,p_bargaining_unit_code         in     varchar2 default null
  ,p_ass_attribute_category       in     varchar2 default null
  ,p_ass_attribute1               in     varchar2 default null
  ,p_ass_attribute2               in     varchar2 default null
  ,p_ass_attribute3               in     varchar2 default null
  ,p_ass_attribute4               in     varchar2 default null
  ,p_ass_attribute5               in     varchar2 default null
  ,p_ass_attribute6               in     varchar2 default null
  ,p_ass_attribute7               in     varchar2 default null
  ,p_ass_attribute8               in     varchar2 default null
  ,p_ass_attribute9               in     varchar2 default null
  ,p_ass_attribute10              in     varchar2 default null
  ,p_ass_attribute11              in     varchar2 default null
  ,p_ass_attribute12              in     varchar2 default null
  ,p_ass_attribute13              in     varchar2 default null
  ,p_ass_attribute14              in     varchar2 default null
  ,p_ass_attribute15              in     varchar2 default null
  ,p_ass_attribute16              in     varchar2 default null
  ,p_ass_attribute17              in     varchar2 default null
  ,p_ass_attribute18              in     varchar2 default null
  ,p_ass_attribute19              in     varchar2 default null
  ,p_ass_attribute20              in     varchar2 default null
  ,p_ass_attribute21              in     varchar2 default null
  ,p_ass_attribute22              in     varchar2 default null
  ,p_ass_attribute23              in     varchar2 default null
  ,p_ass_attribute24              in     varchar2 default null
  ,p_ass_attribute25              in     varchar2 default null
  ,p_ass_attribute26              in     varchar2 default null
  ,p_ass_attribute27              in     varchar2 default null
  ,p_ass_attribute28              in     varchar2 default null
  ,p_ass_attribute29              in     varchar2 default null
  ,p_ass_attribute30              in     varchar2 default null
  ,p_title                        in     varchar2 default null
  ,p_scl_segment1                 in     varchar2 default null
  ,p_scl_segment2                 in     varchar2 default null
  ,p_scl_segment3                 in     varchar2 default null
  ,p_scl_segment4                 in     varchar2 default null
  ,p_scl_segment5                 in     varchar2 default null
  ,p_scl_segment6                 in     varchar2 default null
  ,p_scl_segment7                 in     varchar2 default null
  ,p_scl_segment8                 in     varchar2 default null
  ,p_scl_segment9                 in     varchar2 default null
  ,p_scl_segment10                in     varchar2 default null
  ,p_scl_segment11                in     varchar2 default null
  ,p_scl_segment12                in     varchar2 default null
  ,p_scl_segment13                in     varchar2 default null
  ,p_scl_segment14                in     varchar2 default null
  ,p_scl_segment15                in     varchar2 default null
  ,p_scl_segment16                in     varchar2 default null
  ,p_scl_segment17                in     varchar2 default null
  ,p_scl_segment18                in     varchar2 default null
  ,p_scl_segment19                in     varchar2 default null
  ,p_scl_segment20                in     varchar2 default null
  ,p_scl_segment21                in     varchar2 default null
  ,p_scl_segment22                in     varchar2 default null
  ,p_scl_segment23                in     varchar2 default null
  ,p_scl_segment24                in     varchar2 default null
  ,p_scl_segment25                in     varchar2 default null
  ,p_scl_segment26                in     varchar2 default null
  ,p_scl_segment27                in     varchar2 default null
  ,p_scl_segment28                in     varchar2 default null
  ,p_scl_segment29                in     varchar2 default null
  ,p_scl_segment30                in     varchar2 default null
-- Bug 944911
-- Amended p_scl_concatenated_segments to be an out instead of in out
-- Added new param p_scl_concat_segments
-- Amended p_scl_concatenated_segments to be p_concatenated_segments
  ,p_scl_concat_segments          in     varchar2 default null
  ,p_concatenated_segments       out nocopy varchar2
  ,p_pgp_segment1                 in     varchar2 default null
  ,p_pgp_segment2                 in     varchar2 default null
  ,p_pgp_segment3                 in     varchar2 default null
  ,p_pgp_segment4                 in     varchar2 default null
  ,p_pgp_segment5                 in     varchar2 default null
  ,p_pgp_segment6                 in     varchar2 default null
  ,p_pgp_segment7                 in     varchar2 default null
  ,p_pgp_segment8                 in     varchar2 default null
  ,p_pgp_segment9                 in     varchar2 default null
  ,p_pgp_segment10                in     varchar2 default null
  ,p_pgp_segment11                in     varchar2 default null
  ,p_pgp_segment12                in     varchar2 default null
  ,p_pgp_segment13                in     varchar2 default null
  ,p_pgp_segment14                in     varchar2 default null
  ,p_pgp_segment15                in     varchar2 default null
  ,p_pgp_segment16                in     varchar2 default null
  ,p_pgp_segment17                in     varchar2 default null
  ,p_pgp_segment18                in     varchar2 default null
  ,p_pgp_segment19                in     varchar2 default null
  ,p_pgp_segment20                in     varchar2 default null
  ,p_pgp_segment21                in     varchar2 default null
  ,p_pgp_segment22                in     varchar2 default null
  ,p_pgp_segment23                in     varchar2 default null
  ,p_pgp_segment24                in     varchar2 default null
  ,p_pgp_segment25                in     varchar2 default null
  ,p_pgp_segment26                in     varchar2 default null
  ,p_pgp_segment27                in     varchar2 default null
  ,p_pgp_segment28                in     varchar2 default null
  ,p_pgp_segment29                in     varchar2 default null
  ,p_pgp_segment30                in     varchar2 default null
-- Bug 944911
-- Amended p_group_name to out
-- Added new param p_pgp_concat_segments - for sec asg procs
-- for others added p_concat_segments
  ,p_concat_segments		  in     varchar2 default null
  ,p_contract_id                  in     number default null
  ,p_establishment_id             in     number default null
  ,p_collective_agreement_id      in     number default null
  ,p_cagr_id_flex_num             in     number default null
  ,p_cag_segment1                 in     varchar2  default null
  ,p_cag_segment2                 in     varchar2  default null
  ,p_cag_segment3                 in     varchar2  default null
  ,p_cag_segment4                 in     varchar2  default null
  ,p_cag_segment5                 in     varchar2  default null
  ,p_cag_segment6                 in     varchar2  default null
  ,p_cag_segment7                 in     varchar2  default null
  ,p_cag_segment8                 in     varchar2  default null
  ,p_cag_segment9                 in     varchar2  default null
  ,p_cag_segment10                in     varchar2  default null
  ,p_cag_segment11                in     varchar2  default null
  ,p_cag_segment12                in     varchar2  default null
  ,p_cag_segment13                in     varchar2  default null
  ,p_cag_segment14                in     varchar2  default null
  ,p_cag_segment15                in     varchar2  default null
  ,p_cag_segment16                in     varchar2  default null
  ,p_cag_segment17                in     varchar2  default null
  ,p_cag_segment18                in     varchar2  default null
  ,p_cag_segment19                in     varchar2  default null
  ,p_cag_segment20                in     varchar2  default null
  ,p_notice_period		  in	 number    default  null
  ,p_notice_period_uom		  in     varchar2  default  null
  ,p_employee_category		  in     varchar2  default  null
  ,p_work_at_home		  in	 varchar2  default  null
  ,p_job_post_source_name         in     varchar2  default  null
  ,p_applicant_rank               in     number    default  null
  ,p_posting_content_id           in     number    default  null
  ,p_grade_ladder_pgm_id          in     number    default  null
  ,p_supervisor_assignment_id     in     number    default  null
  ,p_cagr_grade_def_id            in out nocopy number
  ,p_cagr_concatenated_segments      out nocopy varchar2
  ,p_group_name                      out nocopy varchar2
  ,p_assignment_id                   out nocopy number
  ,p_people_group_id              in out nocopy number
  ,p_soft_coding_keyflex_id       in out nocopy number
  ,p_comment_id                      out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_assignment_sequence             out nocopy number
  );
-- ----------------------------------------------------------------------------
-- |---------------------< create_secondary_apl_asg >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API creates an additional applicant assignment for an existing
--   applicant. This second assignment indicates that the person is applying
--   for more than one vacancy, or is an internal transfer.
--    Note this is a limited subset of the parameters for R11 compatability.
--
-- Prerequisites:
--   The person (p_person_id) and the organization (p_organization_id)
--   must exist at the effective start date of the assignment (p_effective_date).
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                          boolean  If true, the database remains
--                                                unchanged. If false a valid
--                                                assignment is created in
--                                                the database.
--   p_effective_date               Yes  date     Effective start date of
--                                                this assignment
--   p_person_id                    Yes  number   Person identifier for this
--                                                assignment
--   p_organization_id              Yes  number   Organization
--   p_recruiter_id                 No   number   Recruiter
--   p_grade_id                     No   number   Grade
--   p_position_id                  No   number   Position
--   p_job_id                       No   number   Job
--   p_assignment_status_type_id    No   number   Assignment status
--   p_location_id                  No   number   Location
--   p_person_referred_by_id        No   number   Person who referred this
--                                                applicant for the assignment
--   p_supervisor_id                No   number   Supervisor
--   p_supervisor_assignment_id     No   number   Supervisor's assignment
--   p_recruitment_activity_id      No   number   Recruitment Activity
--   p_source_organization_id       No   number   Source Organization
--   p_vacancy_id                   No   number   Vacancy
--   p_change_reason                No   varchar2 Reason for the change.
--                                                If there is no change reason
--                                                please explicitly set this to
--                                                null. (else there is a risk
--                                                of inadvertantly recording
--                                                promotions - bug 2994473)
--   p_comments                     No   varchar2 Comments
--   p_date_probation_end           No   date     End date of probation period
--   p_frequency                    No   varchar2 Frequency for quoting working hours (eg per week)
--   p_manager_flag                 No   varchar2 Indicates whether assignment is a manager
--   p_normal_hours                 No   number   Normal working hours
--   p_probation_period             No   number   Length of probation period
--   p_probation_unit               No   varchar2 Units for quoting probation period (eg months)
--   p_source_type                  No   varchar2 Recruitment activity source
--   p_time_normal_finish           No   varchar2 Normal work finish time
--   p_time_normal_start            No   varchar2 Normal work start time
--   p_ass_attribute_category       No   varchar2 Descriptive flexfield
--                                                attribute category
--   p_ass_attribute1               No   varchar2 Descriptive flexfield
--   p_ass_attribute2               No   varchar2 Descriptive flexfield
--   p_ass_attribute3               No   varchar2 Descriptive flexfield
--   p_ass_attribute4               No   varchar2 Descriptive flexfield
--   p_ass_attribute5               No   varchar2 Descriptive flexfield
--   p_ass_attribute6               No   varchar2 Descriptive flexfield
--   p_ass_attribute7               No   varchar2 Descriptive flexfield
--   p_ass_attribute8               No   varchar2 Descriptive flexfield
--   p_ass_attribute9               No   varchar2 Descriptive flexfield
--   p_ass_attribute10              No   varchar2 Descriptive flexfield
--   p_ass_attribute11              No   varchar2 Descriptive flexfield
--   p_ass_attribute12              No   varchar2 Descriptive flexfield
--   p_ass_attribute13              No   varchar2 Descriptive flexfield
--   p_ass_attribute14              No   varchar2 Descriptive flexfield
--   p_ass_attribute15              No   varchar2 Descriptive flexfield
--   p_ass_attribute16              No   varchar2 Descriptive flexfield
--   p_ass_attribute17              No   varchar2 Descriptive flexfield
--   p_ass_attribute18              No   varchar2 Descriptive flexfield
--   p_ass_attribute19              No   varchar2 Descriptive flexfield
--   p_ass_attribute20              No   varchar2 Descriptive flexfield
--   p_ass_attribute21              No   varchar2 Descriptive flexfield
--   p_ass_attribute22              No   varchar2 Descriptive flexfield
--   p_ass_attribute23              No   varchar2 Descriptive flexfield
--   p_ass_attribute24              No   varchar2 Descriptive flexfield
--   p_ass_attribute25              No   varchar2 Descriptive flexfield
--   p_ass_attribute26              No   varchar2 Descriptive flexfield
--   p_ass_attribute27              No   varchar2 Descriptive flexfield
--   p_ass_attribute28              No   varchar2 Descriptive flexfield
--   p_ass_attribute29              No   varchar2 Descriptive flexfield
--   p_ass_attribute30              No   varchar2 Descriptive flexfield
--   p_title                        No   varchar2 Title -must be NULL
--   p_segment1                     No   varchar2 People group Coding segment
--   p_segment2                     No   varchar2 People group segment
--   p_segment3                     No   varchar2 People group segment
--   p_segment4                     No   varchar2 People group segment
--   p_segment5                     No   varchar2 People group segment
--   p_segment6                     No   varchar2 People group segment
--   p_segment7                     No   varchar2 People group segment
--   p_segment8                     No   varchar2 People group segment
--   p_segment9                     No   varchar2 People group segment
--   p_segment10                    No   varchar2 People group segment
--   p_segment11                    No   varchar2 People group segment
--   p_segment12                    No   varchar2 People group segment
--   p_segment13                    No   varchar2 People group segment
--   p_segment14                    No   varchar2 People group segment
--   p_segment15                    No   varchar2 People group segment
--   p_segment16                    No   varchar2 People group segment
--   p_segment17                    No   varchar2 People group segment
--   p_segment18                    No   varchar2 People group segment
--   p_segment19                    No   varchar2 People group segment
--   p_segment20                    No   varchar2 People group segment
--   p_segment21                    No   varchar2 People group segment
--   p_segment22                    No   varchar2 People group segment
--   p_segment23                    No   varchar2 People group segment
--   p_segment24                    No   varchar2 People group segment
--   p_segment25                    No   varchar2 People group segment
--   p_segment26                    No   varchar2 People group segment
--   p_segment27                    No   varchar2 People group segment
--   p_segment28                    No   varchar2 People group segment
--   p_segment29                    No   varchar2 People group segment
--   p_segment30                    No   varchar2 People group segment
--
--
-- Post Success:
--   The API creates the applicant assignment and set the following out
--   parameters:
--
--   Name                           Type     Description
--   p_assignment_id                number   If p_validate is false, set to
--                                           the unique ID for the assignment
--                                           created by the API. If
--                                           p_validate is true, set to null.
--   p_people_group_id              number   If p_validate is false and people
--                                           group segment values have been
--                                           specified, set to the
--                                           people group combination ID.
--                                           If p_validate is true or people
--                                           group segment values have not
--                                           been provided, set to null.
--   p_object_version_number        number   If p_validate is false, set to
--                                           version number of the new
--                                           assignment. If p_validate is
--                                           true, set to null.
--   p_effective_start_date         date     If p_validate is false, set to
--                                           the effective start date of this
--                                           assignment. If p_validate is
--                                           true, set to null.
--   p_effective_end_date           date     If p_validate is false, set to
--                                           the effective end date of this
--                                           assignment. If p_validate is
--                                           true, set to null.
--   p_assignment_sequence          number   If p_validate is false, set to
--                                           assignment sequence number.
--                                           If p_validate is true, set to
--                                           null.
--   p_comment_id                   number   If p_validate is false and
--                                           comment text has been provided,
--                                           set to the ID of the comments.
--                                           Otherwise set to null.
--   p_group_name                   varchar2 If p_validate is false and people
--                                           group segment values have been
--                                           specified, set to the
--                                           people group combination name.
--                                           If p_validate is true, or people
--                                           group segment values have not
--                                           been provided, set to
--                                           null.
--
-- Post Failure:
--   The API does not create the assignment and raises an error.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_secondary_apl_asg
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_person_id                    in     number
  ,p_organization_id              in     number
  ,p_recruiter_id                 in     number   default null
  ,p_grade_id                     in     number   default null
  ,p_position_id                  in     number   default null
  ,p_job_id                       in     number   default null
  ,p_assignment_status_type_id    in     number   default null
  ,p_location_id                  in     number   default null
  ,p_person_referred_by_id        in     number   default null
  ,p_supervisor_id                in     number   default null
  ,p_recruitment_activity_id      in     number   default null
  ,p_source_organization_id       in     number   default null
  ,p_vacancy_id                   in     number   default null
  ,p_change_reason                in     varchar2 default null
  ,p_comments                     in     varchar2 default null
  ,p_date_probation_end           in     date     default null
  ,p_frequency                    in     varchar2 default null
  ,p_manager_flag                 in     varchar2 default 'N'
  ,p_normal_hours                 in     number   default null
  ,p_probation_period             in     number   default null
  ,p_probation_unit               in     varchar2 default null
  ,p_source_type                  in     varchar2 default null
  ,p_time_normal_finish           in     varchar2 default null
  ,p_time_normal_start            in     varchar2 default null
  ,p_ass_attribute_category       in     varchar2 default null
  ,p_ass_attribute1               in     varchar2 default null
  ,p_ass_attribute2               in     varchar2 default null
  ,p_ass_attribute3               in     varchar2 default null
  ,p_ass_attribute4               in     varchar2 default null
  ,p_ass_attribute5               in     varchar2 default null
  ,p_ass_attribute6               in     varchar2 default null
  ,p_ass_attribute7               in     varchar2 default null
  ,p_ass_attribute8               in     varchar2 default null
  ,p_ass_attribute9               in     varchar2 default null
  ,p_ass_attribute10              in     varchar2 default null
  ,p_ass_attribute11              in     varchar2 default null
  ,p_ass_attribute12              in     varchar2 default null
  ,p_ass_attribute13              in     varchar2 default null
  ,p_ass_attribute14              in     varchar2 default null
  ,p_ass_attribute15              in     varchar2 default null
  ,p_ass_attribute16              in     varchar2 default null
  ,p_ass_attribute17              in     varchar2 default null
  ,p_ass_attribute18              in     varchar2 default null
  ,p_ass_attribute19              in     varchar2 default null
  ,p_ass_attribute20              in     varchar2 default null
  ,p_ass_attribute21              in     varchar2 default null
  ,p_ass_attribute22              in     varchar2 default null
  ,p_ass_attribute23              in     varchar2 default null
  ,p_ass_attribute24              in     varchar2 default null
  ,p_ass_attribute25              in     varchar2 default null
  ,p_ass_attribute26              in     varchar2 default null
  ,p_ass_attribute27              in     varchar2 default null
  ,p_ass_attribute28              in     varchar2 default null
  ,p_ass_attribute29              in     varchar2 default null
  ,p_ass_attribute30              in     varchar2 default null
  ,p_title                        in     varchar2 default null
  ,p_segment1                     in     varchar2 default null
  ,p_segment2                     in     varchar2 default null
  ,p_segment3                     in     varchar2 default null
  ,p_segment4                     in     varchar2 default null
  ,p_segment5                     in     varchar2 default null
  ,p_segment6                     in     varchar2 default null
  ,p_segment7                     in     varchar2 default null
  ,p_segment8                     in     varchar2 default null
  ,p_segment9                     in     varchar2 default null
  ,p_segment10                    in     varchar2 default null
  ,p_segment11                    in     varchar2 default null
  ,p_segment12                    in     varchar2 default null
  ,p_segment13                    in     varchar2 default null
  ,p_segment14                    in     varchar2 default null
  ,p_segment15                    in     varchar2 default null
  ,p_segment16                    in     varchar2 default null
  ,p_segment17                    in     varchar2 default null
  ,p_segment18                    in     varchar2 default null
  ,p_segment19                    in     varchar2 default null
  ,p_segment20                    in     varchar2 default null
  ,p_segment21                    in     varchar2 default null
  ,p_segment22                    in     varchar2 default null
  ,p_segment23                    in     varchar2 default null
  ,p_segment24                    in     varchar2 default null
  ,p_segment25                    in     varchar2 default null
  ,p_segment26                    in     varchar2 default null
  ,p_segment27                    in     varchar2 default null
  ,p_segment28                    in     varchar2 default null
  ,p_segment29                    in     varchar2 default null
  ,p_segment30                    in     varchar2 default null
-- Bug 944911
-- Amended p_group_name to out
-- Added new param p_pgp_concat_segments - for sec asg procs
-- for others added p_concat_segments
-- Revering these changes ar they are for R11
  -- ,p_concat_segments		  in     varchar2 default null
  ,p_supervisor_assignment_id     in     number   default null
  ,p_group_name                   in out nocopy varchar2
  ,p_assignment_id                   out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_assignment_sequence             out nocopy number
  ,p_comment_id                      out nocopy number
  ,p_people_group_id                 out nocopy number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------------< offer_apl_asg >---------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API changes the status of an applicant assignment to a status of the
 * 'Offer' type.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The assignment must be an applicant assignment. The assignment must exist as
 * of the effective date of the change.Also the assignment status must exist
 * with a system status of OFFER.
 *
 * <p><b>Post Success</b><br>
 * The API updates the assignment.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the assignment and raises an error.
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
 * @param p_assignment_id Identifies the assignment record to be modified.
 * @param p_object_version_number Pass in the current version number of the
 * assignment to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated assignment. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_assignment_status_type_id The new assignment status must have a
 * system assignment status of OFFER. If the assignment status is already a
 * type of OFFER, this API can be used to set a different offer status. If no
 * value is supplied, this API uses the default OFFER status for the business
 * group in which this assignment exists.
 * @param p_change_reason Reason for the change in the assignment. Valid values
 * are defined in the APL_ASSIGN_REASON lookup type.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created assignment. If p_validate is
 * true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created assignment. If p_validate is true, then
 * set to null.
 * @rep:displayname Offer Applicant Assignment
 * @rep:category BUSINESS_ENTITY PER_APPLICANT_ASG
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure offer_apl_asg
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
-- ----------------------------------------------------------------------------
-- |------------------------------< accept_apl_asg >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API changes the status of an applicant assignment to a status of the
 * 'Accepted' type.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The assignment must be an applicant assignment. The assignment must exist as
 * of the effective date of the change
 *
 * <p><b>Post Success</b><br>
 * The API updates the assignment.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the assignment and raises an error.
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
 * @param p_assignment_id Identifies the assignment record to be modified.
 * @param p_object_version_number Pass in the current version number of the
 * assignment to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated assignment. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_assignment_status_type_id The new assignment status must have a
 * system assignment status of ACCEPTED. If the assignment status is already a
 * type of ACCEPTED, this API can be used to set a different accepted status.
 * If no value is supplied, this API uses the default ACCEPTED status for the
 * business group in which this assignment exists.
 * @param p_change_reason Reason for the change in the assignment. Valid values
 * are defined in the APL_ASSIGN_REASON lookup type.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created assignment. If p_validate is
 * true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created assignment. If p_validate is true, then
 * set to null.
 * @rep:displayname Accept Applicant Assignment
 * @rep:category BUSINESS_ENTITY PER_APPLICANT_ASG
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
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
-- ----------------------------------------------------------------------------
-- |-----------------------------< activate_apl_asg >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API changes the status of an applicant assignment to a status of the
 * 'Active' type.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The assignment must be an applicant assignment. The assignment must exist as
 * of the effective date of the change
 *
 * <p><b>Post Success</b><br>
 * The API updates the assignment.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the assignment and raises an error.
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
 * @param p_assignment_id Identifies the assignment record to be modified.
 * @param p_object_version_number Pass in the current version number of the
 * assignment to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated assignment. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_assignment_status_type_id The new assignment status must have a
 * system assignment status of ACTIVE_APL. If the assignment status is already
 * a type of ACTIVE_APL, this API can be used to set a different accepted
 * status. If no value is supplied, this API uses the default ACTIVE_APL status
 * for the business group in which this assignment exists.
 * @param p_change_reason Reason for the change in the assignment. Valid values
 * are defined in the APL_ASSIGN_REASON lookup type.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created assignment. If p_validate is
 * true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created assignment. If p_validate is true, then
 * set to null.
 * @rep:displayname Activate Applicant Assignment
 * @rep:category BUSINESS_ENTITY PER_APPLICANT_ASG
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE activate_apl_asg
  (p_validate                     IN     BOOLEAN                                                    DEFAULT FALSE
  ,p_effective_date               IN     DATE
  ,p_datetrack_update_mode        IN     VARCHAR2
  ,p_assignment_id                IN     per_all_assignments_f.assignment_id%TYPE
  ,p_object_version_number        IN OUT NOCOPY per_all_assignments_f.object_version_number%TYPE
  ,p_assignment_status_type_id    IN     per_assignment_status_types.assignment_status_type_id%TYPE DEFAULT hr_api.g_number
  ,p_change_reason                IN     per_all_assignments_f.change_reason%TYPE                   DEFAULT hr_api.g_varchar2
  ,p_effective_start_date            OUT NOCOPY per_all_assignments_f.effective_start_date%TYPE
  ,p_effective_end_date              OUT NOCOPY per_all_assignments_f.effective_end_date%TYPE
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< terminate_apl_asg >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API ends an applicant assignment.
 *
 * A 'Terminate' status type is not explicitly stored against an applicant
 * assignment, this API will end date the assignment.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The assignment must be an applicant assignment. The assignment must exist as
 * of the effective date of the change
 *
 * <p><b>Post Success</b><br>
 * This API terminates the Applicant Assignment
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the assignment and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_assignment_id Identifies the assignment record to be terminated.
 * @param p_assignment_status_type_id The new assignment status must have a
 * system assignment status of TERM_APL. If no value is supplied, this API uses
 * the default TERM_APL status for the business group in which this assignment
 * exists.
 * @param p_object_version_number Pass in the current version number of the
 * assignment to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated assignment. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date for the terminated assignment. If p_validate is true,
 * then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the terminated assignment. If p_validate is true,
 * then set to null.
 * @rep:displayname Terminate Applicant Assignment
 * @rep:category BUSINESS_ENTITY PER_APPLICANT_ASG
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE terminate_apl_asg
  (p_validate                     IN     BOOLEAN                                          DEFAULT FALSE
  ,p_effective_date               IN     DATE
  ,p_assignment_id                IN     per_all_assignments_f.assignment_id%TYPE
  ,p_assignment_status_type_id    IN  per_all_assignments_f.assignment_status_type_id%TYPE DEFAULT NULL
  ,p_object_version_number        IN OUT NOCOPY per_all_assignments_f.object_version_number%TYPE
  ,p_effective_start_date            OUT NOCOPY per_all_assignments_f.effective_start_date%TYPE
  ,p_effective_end_date              OUT NOCOPY per_all_assignments_f.effective_end_date%TYPE
  );
-- -----------------------------------------------------------------------------
-- |-------------------------< terminate_apl_asg >-----------------------------|
-- -----------------------------------------------------------------------------
--
-- {Start of Comments}
--
-- Description:
--   This business process terminates an applicant assignment for a person. It
--   will not allow termination of the assignment if it is the last applicant
--   assignment for the person. In order to terminate the whole application use
--   the terminate_applicant API.
--
-- Pre-requisites:
--   None
--
-- In Parameters
--   Name                           Reqd Type     Description
--   p_validate                     No   boolean  If true, the database remains
--                                                unchanged. If false a valid
--                                                assignment is updated in the
--                                                database.
--   p_effective_date               Yes  date     Effective date of change of
--                                                status.
--   p_assignment_id                Yes  number   Assignment to be terminated.
--   p_assignment_status_type_id    No   number   Required for IRC status maintenance
--   p_object_version_number        Yes  number   Version number of the
--                                                assignment record.
--   p_change_reason                No   varchar2 Required for IRC status maintenance
--   p_status_change_comments       NO   varchar2 Required for IRC Status maintenance.
--
-- Post Success
--   The API updates the person and application and sets the following out
--   parameters:
--   Name                           Type     Description
--   p_object_version_number        Number   If p_validate is false, set to the
--                                           new version number of the
--                                           assignment record. If p_validate is
--                                           true, set to the value passed in.
--   p_effective_start_date         Date     If p_validate is false, set to the
--                                           effective start date of the updated
--                                           assignment record. If p_validate is
--                                           true, set to null.
--   p_effective_end_date           Date     If p_validate is false, set to the
--                                           effective end date of the updated
--                                           assignment record. If p_validate is
--                                           true, set to null.
--
-- Post Failure:
--   The API does not update the assignment and raises an error.
--
-- Access Status:
--   Public
--
-- {End of Comments}
--
PROCEDURE terminate_apl_asg
  (p_validate                     IN     BOOLEAN                                          DEFAULT FALSE
  ,p_effective_date               IN     DATE
  ,p_assignment_id                IN     per_all_assignments_f.assignment_id%TYPE
  ,p_assignment_status_type_id    IN  per_all_assignments_f.assignment_status_type_id%TYPE DEFAULT NULL
  ,p_change_reason                IN  per_all_assignments_f.change_reason%TYPE  -- 4066579
  ,p_status_change_comments       IN  irc_assignment_statuses.status_change_comments%TYPE DEFAULT NULL
  ,p_object_version_number        IN OUT NOCOPY per_all_assignments_f.object_version_number%TYPE
  ,p_effective_start_date            OUT NOCOPY per_all_assignments_f.effective_start_date%TYPE
  ,p_effective_end_date              OUT NOCOPY per_all_assignments_f.effective_end_date%TYPE
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< set_new_primary_asg >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API sets a chosen employee assignment as the primary assignment.
 *
 * The API also updates the previous primary assignment so that it becomes
 * secondary.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The assignment must exist as of the effective date of the change, must be an
 * employee assignment and must not be a primary assignment.
 *
 * <p><b>Post Success</b><br>
 * The speficied assignment is set as the primary assignment for the employee.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the primary employee assignment.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_person_id Identifies the person record that owns the assignments to
 * update.
 * @param p_assignment_id Identifies the secondary assignment that is to become
 * the primary assignment.
 * @param p_object_version_number Pass in the current version number of the
 * assignment to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated assignment. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created assignment. If p_validate is
 * true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created assignment. If p_validate is true, then
 * set to null.
 * @rep:displayname Set New Primary Employee Assignment
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE_ASG
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE set_new_primary_asg
  (p_validate                    IN     BOOLEAN                                          DEFAULT FALSE
  ,p_effective_date              IN     DATE
  ,p_person_id                   IN     per_all_people_f.person_id%TYPE
  ,p_assignment_id               IN     per_all_assignments_f.assignment_id%TYPE
  ,p_object_version_number       IN OUT NOCOPY per_all_assignments_f.object_version_number%TYPE
  ,p_effective_start_date           OUT NOCOPY per_all_assignments_f.effective_start_date%TYPE
  ,p_effective_end_date             OUT NOCOPY per_all_assignments_f.effective_end_date%TYPE
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< set_new_primary_cwk_asg >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API sets a chosen contingent worker assignment as the primary
 * assignment.
 *
 * The API also updates the previous primary assignment so that it becomes
 * secondary.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The assignment must exist as of the effective date of the change, must be a
 * contingent worker assignment and must not be a primary assignment.
 *
 * <p><b>Post Success</b><br>
 * The chosen assignment is set as the primary contingent worker assignment.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the primary contingent worker assignment.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_person_id Identifies the person record that owns the assignments to
 * update.
 * @param p_assignment_id Identifies the assignment that is to become the
 * primary assignment.
 * @param p_object_version_number Pass in the current version number of the
 * assignment to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated assignment. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created assignment. If p_validate is
 * true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created assignment. If p_validate is true, then
 * set to null.
 * @rep:displayname Set New Primary Contingent Worker Assignment
 * @rep:category BUSINESS_ENTITY PER_CWK_ASG
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE set_new_primary_cwk_asg
  (p_validate                    IN     BOOLEAN                                          DEFAULT FALSE
  ,p_effective_date              IN     DATE
  ,p_person_id                   IN     per_all_people_f.person_id%TYPE
  ,p_assignment_id               IN     per_all_assignments_f.assignment_id%TYPE
  ,p_object_version_number       IN OUT NOCOPY per_all_assignments_f.object_version_number%TYPE
  ,p_effective_start_date           OUT NOCOPY per_all_assignments_f.effective_start_date%TYPE
  ,p_effective_end_date             OUT NOCOPY per_all_assignments_f.effective_end_date%TYPE
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< interview1_apl_asg >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API changes the status of an applicant assignment to a status of the
 * 'First Interview' type.
 *
 * Obsolete letter requests may be deleted, and new letter requests may be
 * created if the assignment becomes eligible for those.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The assignment must be an applicant assignment. The assignment must exist as
 * of the effective date of the change.Also the assignment status must exist
 * with a system status of INTERVIEW1.
 *
 * <p><b>Post Success</b><br>
 * The API updates the assignment.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the assignment and raises an error.
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
 * @param p_assignment_id Identifies the assignment record to be modified.
 * @param p_object_version_number Pass in the current version number of the
 * assignment to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated assignment. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_assignment_status_type_id The new assignment status must have a
 * system assignment status of INTERVIEW1 If the assignment status is already a
 * type of INTERVIEW1, this API can be used to set a different First Interview
 * status. If no value is supplied, this API uses the default INTERVIEW1 status
 * for the business group in which this assignment exists.
 * @param p_change_reason Reason for the change in the assignment. Valid values
 * are defined in the APL_ASSIGN_REASON lookup type.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created assignment. If p_validate is
 * true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created assignment. If p_validate is true, then
 * set to null.
 * @rep:displayname Interview1 Applicant Assignment
 * @rep:category BUSINESS_ENTITY PER_APPLICANT_ASG
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE interview1_apl_asg
  (p_validate                     IN     BOOLEAN    DEFAULT FALSE
  ,p_effective_date               IN     DATE
  ,p_datetrack_update_mode        IN     VARCHAR2
  ,p_assignment_id                IN     per_all_assignments_f.assignment_id%TYPE
  ,p_object_version_number        IN OUT NOCOPY per_all_assignments_f.object_version_number%TYPE
  ,p_assignment_status_type_id    IN     per_assignment_status_types.assignment_status_type_id%TYPE DEFAULT hr_api.g_number
  ,p_change_reason                IN     per_all_assignments_f.change_reason%TYPE                   DEFAULT hr_api.g_varchar2
  ,p_effective_start_date            OUT NOCOPY per_all_assignments_f.effective_start_date%TYPE
  ,p_effective_end_date              OUT NOCOPY per_all_assignments_f.effective_end_date%TYPE
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< interview2_apl_asg >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API changes the status of an applicant assignment to a status of the
 * 'Second Interview' type.
 *
 * Obsolete letter requests may be deleted, and new letter requests may be
 * created if the assignment becomes eligible for those.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The assignment must be an applicant assignment. The assignment must exist on
 * the effective date of the change of status. Also the assignment status must
 * exist with a system status of INTERVIEW2.
 *
 * <p><b>Post Success</b><br>
 * The API updates the assignment.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the assignment and raises an error.
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
 * @param p_assignment_id Identifies the assignment record to be modified.
 * @param p_object_version_number Pass in the current version number of the
 * assignment to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated assignment. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_assignment_status_type_id The new assignment status must have a
 * system assignment status of INTERVIEW2. If the assignment status is already
 * a type of INTERVIEW2, this API can be used to set a different Second
 * Interview status. If no value is supplied, this API uses the default
 * INTERVIEW2 status for the business group in which this assignment exists.
 * @param p_change_reason Reason for the change in the assignment. Valid values
 * are defined in the APL_ASSIGN_REASON lookup type.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created assignment. If p_validate is
 * true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created assignment. If p_validate is true, then
 * set to null.
 * @rep:displayname Interview2 Applicant Assignment
 * @rep:category BUSINESS_ENTITY PER_APPLICANT_ASG
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE interview2_apl_asg
  (p_validate                     IN     BOOLEAN    DEFAULT FALSE
  ,p_effective_date               IN     DATE
  ,p_datetrack_update_mode        IN     VARCHAR2
  ,p_assignment_id                IN     per_all_assignments_f.assignment_id%TYPE
  ,p_object_version_number        IN OUT NOCOPY per_all_assignments_f.object_version_number%TYPE
  ,p_assignment_status_type_id    IN     per_assignment_status_types.assignment_status_type_id%TYPE DEFAULT hr_api.g_number
  ,p_change_reason                IN     per_all_assignments_f.change_reason%TYPE                   DEFAULT hr_api.g_varchar2
  ,p_effective_start_date            OUT NOCOPY per_all_assignments_f.effective_start_date%TYPE
  ,p_effective_end_date              OUT NOCOPY per_all_assignments_f.effective_end_date%TYPE
  );
--
--

-- ----------------------------------------------------------------------------
-- |----------------------------< reverse_term_apln>-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*
-- this procedure is specifically designed for the IRec team and can be used
-- to reverse terminate an application


-- @param p_effective_date date when the api has to perform validations.
-- @param p_business_group_id  business group id of the person
-- @param p_assignment_id assignment_id for which reverse termination should be processed
-- @param p_person_id person id of the person for whom the reverse termination should be processed
-- @param p_status_change_reason  the reason for reverse termination.
*/
PROCEDURE reverse_term_apln
   ( p_effective_date IN date ,
     p_business_group_id IN number ,
     p_assignment_id IN number  ,
     p_person_id IN number ,
      p_status_change_reason   in  varchar2 default null,
      p_return_status out nocopy varchar2);

--
--
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_assignment >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes an Assignment of type Employee, Applicant and CWK in the
 * required Datetrack mode.
 *
 * If the deleted Assignment is a Primary Assignment, then if there is a single
 * eligible candidate Primary Assignment, API converts that candidate Assignment
 * to Primary and deletes the original Primary Assignment. If there are multiple
 * eligible candidate Assignments, then an error is raised and user need to do
 * the delete operation using Assignment Form.
 *
 * If there are any warning conditions, then the necessary boolean OUT parameter
 * designated to different warning conditions are set to true so that user can
 * review them and commit the Delete Assignment changes.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The Assignment details provided must be valid and available in the system.
 * Benefits type Assignments cannot be deleted using this Delete Assignment API.
 *
 * <p><b>Post Success</b><br>
 * Assignment record will be deleted in the specified Datetrack mode.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the Delete Assignment changes and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_datetrack_mode Indicates which DateTrack mode to use when
 * deleting the record. You must set to either ZAP, DELETE_NEXT_CHANGE or
 * FUTURE_CHANGE. Modes available for use with a particular record depend on
 * the dates of previous record changes and the effective date of this change.
 * @param p_assignment_id Identifies the assignment record to be deleted.
 * @param p_object_version_number Pass in the current version number of the
 * assignment to be deleted. When the API completes if p_validate is false,
 * will be set to the new version number of the deleted assignment. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated assignment row which now exists as of
 * the effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated assignment row which now exists as of the
 * effective date. If p_validate is true, then set to null.
 * @param p_loc_change_tax_issues If there is a change in the location due to
 * the specified Datetrack Delete operation, and if there is a corresponding
 * Federal Tax record that gets affected, then this parameter is set to true.
 * @param p_delete_asg_budgets If set to true, then corresponding Assignment
 * Budget values may have been deleted.
 * @param p_org_now_no_manager_warning If set to true, then the current
 * Datetrack delete operation resulted in no organization manager.
 * @param p_element_salary_warning If set to true, then Element Entries
 * including at least one Salary Entry have changed.
 * @param p_element_entries_warning If set to true, then this action has
 * affected Element Entries.
 * @param p_spp_warning If set to true, then this action has deleted any
 * future dated grade steps for this assignment.
 * @param p_cost_warning If set to true, then there are costing records
 * associated with this assignment which have not been adjusted in a similar
 * manner due to the presence of costing information in the future.
 * @param p_life_events_exists If set to true, then there are Life Events
 * created for this Assignment with status "Started".
 * @param p_cobra_coverage_elements If set to true, then COBRA Coverage
 * Enrollments are invalidated.
 * @param p_assgt_term_elements If set to true, then an assignment record with
 * TERM_ASSIGN status has been deleted. Elements have not been replaced.
 * @rep:displayname Delete Assignment
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE_ASG
 * @rep:category BUSINESS_ENTITY PER_APPLICANT_ASG
 * @rep:category BUSINESS_ENTITY PER_CWK_ASG
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE delete_assignment
  (p_validate                     IN     boolean default false
  ,p_effective_date               IN     DATE
  ,p_datetrack_mode               IN     VARCHAR2
  ,p_assignment_id                IN     per_all_assignments_f.assignment_id%TYPE
  ,p_object_version_number        IN OUT NOCOPY per_all_assignments_f.object_version_number%TYPE
  ,p_effective_start_date            OUT NOCOPY per_all_assignments_f.effective_start_date%TYPE
  ,p_effective_end_date              OUT NOCOPY per_all_assignments_f.effective_end_date%TYPE
  ,p_loc_change_tax_issues           OUT NOCOPY boolean
  ,p_delete_asg_budgets              OUT NOCOPY boolean
  ,p_org_now_no_manager_warning      OUT NOCOPY boolean
  ,p_element_salary_warning          OUT NOCOPY boolean
  ,p_element_entries_warning         OUT NOCOPY boolean
  ,p_spp_warning                     OUT NOCOPY boolean
  ,P_cost_warning                    OUT NOCOPY Boolean
  ,p_life_events_exists   	     OUT NOCOPY Boolean
  ,p_cobra_coverage_elements         OUT NOCOPY Boolean
  ,p_assgt_term_elements             OUT NOCOPY Boolean);
--
end hr_assignment_api;

/
