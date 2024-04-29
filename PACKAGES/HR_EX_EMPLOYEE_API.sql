--------------------------------------------------------
--  DDL for Package HR_EX_EMPLOYEE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_EX_EMPLOYEE_API" AUTHID CURRENT_USER as
/* $Header: peexeapi.pkh 120.4.12010000.2 2009/04/30 10:46:10 dparthas ship $ */
/*#
 * This package contains Ex-Employee APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Ex-Employee
*/
--
-- 120.4 (START)
--
-- Added overloaded procedure for new ALU Warning parameter
--
-- ----------------------------------------------------------------------------
-- |--------------------------< actual_termination_emp >----------------------|
-- ----------------------------------------------------------------------------
--
-- This version of the API is now out-of-date however it has been provided to
-- you for backward compatibility support and will be removed in the future.
-- Oracle recommends you to modify existing calling programs in advance of the
-- support being withdrawn thus avoiding any potential disruption.
--
procedure actual_termination_emp
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_period_of_service_id          in     number
  ,p_object_version_number         in out nocopy number
  ,p_actual_termination_date       in     date
  ,p_last_standard_process_date    in     date     default hr_api.g_date
  ,p_person_type_id                in     number   default hr_api.g_number
  ,p_assignment_status_type_id     in     number   default hr_api.g_number
  ,p_leaving_reason                in     varchar2 default hr_api.g_varchar2
  ,p_atd_new                       in     number   default hr_api.g_true_num
  ,p_lspd_new                      in     number   default hr_api.g_true_num
  ,p_attribute_category            in     varchar2 default hr_api.g_varchar2
  ,p_attribute1                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute2                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute3                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute4                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute5                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute6                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute7                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute8                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute9                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute10                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute11                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute12                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute13                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute14                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute15                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute16                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute17                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute18                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute19                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute20                   in     varchar2 default hr_api.g_varchar2
  ,p_pds_information_category      in     varchar2 default hr_api.g_varchar2
  ,p_pds_information1              in     varchar2 default hr_api.g_varchar2
  ,p_pds_information2              in     varchar2 default hr_api.g_varchar2
  ,p_pds_information3              in     varchar2 default hr_api.g_varchar2
  ,p_pds_information4              in     varchar2 default hr_api.g_varchar2
  ,p_pds_information5              in     varchar2 default hr_api.g_varchar2
  ,p_pds_information6              in     varchar2 default hr_api.g_varchar2
  ,p_pds_information7              in     varchar2 default hr_api.g_varchar2
  ,p_pds_information8              in     varchar2 default hr_api.g_varchar2
  ,p_pds_information9              in     varchar2 default hr_api.g_varchar2
  ,p_pds_information10             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information11             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information12             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information13             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information14             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information15             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information16             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information17             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information18             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information19             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information20             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information21             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information22             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information23             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information24             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information25             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information26             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information27             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information28             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information29             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information30             in     varchar2 default hr_api.g_varchar2
  ,p_last_std_process_date_out        out nocopy date
  ,p_supervisor_warning               out nocopy boolean
  ,p_event_warning                    out nocopy boolean
  ,p_interview_warning                out nocopy boolean
  ,p_review_warning                   out nocopy boolean
  ,p_recruiter_warning                out nocopy boolean
  ,p_asg_future_changes_warning       out nocopy boolean
  ,p_entries_changed_warning          out nocopy varchar2
  ,p_pay_proposal_warning             out nocopy boolean
  ,p_dod_warning                      out nocopy boolean
  ,p_alu_change_warning               out nocopy varchar2
  );
--
-- 120.4 (END)
--
-- ----------------------------------------------------------------------------
-- |--------------------------< actual_termination_emp >----------------------|
-- ----------------------------------------------------------------------------
--
-- This version of the API is now out-of-date however it has been provided to
-- you for backward compatibility support and will be removed in the future.
-- Oracle recommends you to modify existing calling programs in advance of the
-- support being withdrawn thus avoiding any potential disruption.
--
  procedure actual_termination_emp
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_period_of_service_id          in     number
  ,p_object_version_number         in out nocopy number
  ,p_actual_termination_date       in     date
  ,p_last_standard_process_date    in     date     default hr_api.g_date
  ,p_person_type_id                in     number   default hr_api.g_number
  ,p_assignment_status_type_id     in     number   default hr_api.g_number
  ,p_leaving_reason                in     varchar2 default hr_api.g_varchar2
  ,p_attribute_category	           in     varchar2 default hr_api.g_varchar2
  ,p_attribute1		           in     varchar2 default hr_api.g_varchar2
  ,p_attribute2		           in     varchar2 default hr_api.g_varchar2
  ,p_attribute3		           in     varchar2 default hr_api.g_varchar2
  ,p_attribute4		           in     varchar2 default hr_api.g_varchar2
  ,p_attribute5		           in     varchar2 default hr_api.g_varchar2
  ,p_attribute6		           in     varchar2 default hr_api.g_varchar2
  ,p_attribute7		           in     varchar2 default hr_api.g_varchar2
  ,p_attribute8		           in     varchar2 default hr_api.g_varchar2
  ,p_attribute9		           in     varchar2 default hr_api.g_varchar2
  ,p_attribute10		   in     varchar2 default hr_api.g_varchar2
  ,p_attribute11		   in     varchar2 default hr_api.g_varchar2
  ,p_attribute12		   in     varchar2 default hr_api.g_varchar2
  ,p_attribute13		   in     varchar2 default hr_api.g_varchar2
  ,p_attribute14		   in     varchar2 default hr_api.g_varchar2
  ,p_attribute15		   in     varchar2 default hr_api.g_varchar2
  ,p_attribute16		   in     varchar2 default hr_api.g_varchar2
  ,p_attribute17		   in     varchar2 default hr_api.g_varchar2
  ,p_attribute18		   in     varchar2 default hr_api.g_varchar2
  ,p_attribute19		   in     varchar2 default hr_api.g_varchar2
  ,p_attribute20		   in     varchar2 default hr_api.g_varchar2
  ,p_pds_information_category      in     varchar2 default hr_api.g_varchar2
  ,p_pds_information1	           in     varchar2 default hr_api.g_varchar2
  ,p_pds_information2	           in     varchar2 default hr_api.g_varchar2
  ,p_pds_information3	           in     varchar2 default hr_api.g_varchar2
  ,p_pds_information4	           in     varchar2 default hr_api.g_varchar2
  ,p_pds_information5	           in     varchar2 default hr_api.g_varchar2
  ,p_pds_information6	           in     varchar2 default hr_api.g_varchar2
  ,p_pds_information7	           in     varchar2 default hr_api.g_varchar2
  ,p_pds_information8	           in     varchar2 default hr_api.g_varchar2
  ,p_pds_information9	           in     varchar2 default hr_api.g_varchar2
  ,p_pds_information10	           in     varchar2 default hr_api.g_varchar2
  ,p_pds_information11	           in     varchar2 default hr_api.g_varchar2
  ,p_pds_information12	           in     varchar2 default hr_api.g_varchar2
  ,p_pds_information13	           in     varchar2 default hr_api.g_varchar2
  ,p_pds_information14             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information15             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information16             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information17             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information18             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information19             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information20             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information21             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information22             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information23             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information24             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information25             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information26             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information27             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information28             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information29             in     varchar2 default hr_api.g_varchar2
  ,p_pds_information30             in     varchar2 default hr_api.g_varchar2
  ,p_last_std_process_date_out        out nocopy date
  ,p_supervisor_warning               out nocopy boolean
  ,p_event_warning                    out nocopy boolean
  ,p_interview_warning                out nocopy boolean
  ,p_review_warning                   out nocopy boolean
  ,p_recruiter_warning                out nocopy boolean
  ,p_asg_future_changes_warning       out nocopy boolean
  ,p_entries_changed_warning          out nocopy varchar2
  ,p_pay_proposal_warning             out nocopy boolean
  ,p_dod_warning                      out nocopy boolean
  );
--
-- 120.4 (START)
--
-- ----------------------------------------------------------------------------
-- |--------------------------< actual_termination_emp >----------------------|
-- ----------------------------------------------------------------------------
--
-- This version of the API is now out-of-date however it has been provided to
-- you for backward compatibility support and will be removed in the future.
-- Oracle recommends you to modify existing calling programs in advance of the
-- support being withdrawn thus avoiding any potential disruption.
--
procedure actual_termination_emp
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_period_of_service_id          in     number
  ,p_object_version_number         in out nocopy number
  ,p_actual_termination_date       in     date
  ,p_last_standard_process_date    in out nocopy date
  ,p_person_type_id                in     number   default hr_api.g_number
  ,p_assignment_status_type_id     in     number   default hr_api.g_number
  ,p_leaving_reason                in     varchar2 default hr_api.g_varchar2
  ,p_supervisor_warning               out nocopy boolean
  ,p_event_warning                    out nocopy boolean
  ,p_interview_warning                out nocopy boolean
  ,p_review_warning                   out nocopy boolean
  ,p_recruiter_warning                out nocopy boolean
  ,p_asg_future_changes_warning       out nocopy boolean
  ,p_entries_changed_warning          out nocopy varchar2
  ,p_pay_proposal_warning             out nocopy boolean
  ,p_dod_warning                      out nocopy boolean
  );
--
-- 120.4 (END)
--
-- ----------------------------------------------------------------------------
-- |--------------------------< actual_termination_emp >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API terminates an employee.
 *
 * This API converts a person of type Employee >to a person of type
 * Ex-Employee. The person's period of service and any employee assignments are
 * ended.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The employee must exist in the relevant business group.
 *
 * <p><b>Post Success</b><br>
 * The employee is terminated successfully.
 *
 * <p><b>Post Failure</b><br>
 * The employee is not terminated and an error is raised.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_period_of_service_id Period of service that is being terminated.
 * @param p_object_version_number Pass in the current version number of the
 * period of service to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated period of
 * service. If p_validate is true will be set to the same value which was
 * passed in.
 * @param p_actual_termination_date Actual termination date.
 * @param p_last_standard_process_date Last standard process date
 * @param p_person_type_id Type of employee being terminated.
 * @param p_assignment_status_type_id Status of an employee in a specific
 * assignment.
 * @param p_leaving_reason Termination Reason. Valid values are defined by the
 * LEAV_REAS lookup type.
 * @param p_atd_new New Actual Termination Date entered flag. Set to 1 when
 * a new date is entered else set to 0.
 * @param p_lspd_new New Last Standard Process Date entered flag. Set to 1 when
 * a new date is entered else set to 0.
 * @param p_supervisor_warning If set to true, then this person is a supervisor
 * for another, current or future assignment.
 * @param p_event_warning If set to true, then this person is booked on at
 * least one event in the past, present, or future.
 * @param p_interview_warning If set to true, then this person is scheduled to
 * be an interviewer or has interviews booked in the past, present, or future.
 * @param p_review_warning If set to true, then this person has a review
 * scheduled.
 * @param p_recruiter_warning If set to true, then this person is a recruiter
 * for a vacancy in the past, present, or future.
 * @param p_asg_future_changes_warning If set to true, then at least one
 * assignment change, after the actual termination date, has been overwritten
 * with the new assignment status.
 * @param p_entries_changed_warning Set to Y when at least one element entry is
 * affected by the assignment change. Set to S if at least one salary element
 * entry is affected. Otherwise, set to N.
 * @param p_pay_proposal_warning If set to true, then there is at least one pay
 * proposal existing after the actual termination date of this assignment.
 * @param p_dod_warning If set to true, then the date of death has been set on
 * terminating the person.
 * @param p_alu_change_warning Set to Y when at least one assignment link
 * usage is affected by the termination. Otherwise, set to N.
 * @rep:displayname Actual Employee Termination
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure actual_termination_emp
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_period_of_service_id          in     number
  ,p_object_version_number         in out nocopy number
  ,p_actual_termination_date       in     date
  ,p_last_standard_process_date    in out nocopy date
  ,p_person_type_id                in     number   default hr_api.g_number
  ,p_assignment_status_type_id     in     number   default hr_api.g_number
  ,p_leaving_reason                in     varchar2 default hr_api.g_varchar2
--
-- 120.4 (START)
--
  ,p_atd_new                       in     number   default hr_api.g_true_num
  ,p_lspd_new                      in     number   default hr_api.g_true_num
--
-- 120.4 (END)
--
  ,p_supervisor_warning               out nocopy boolean
  ,p_event_warning                    out nocopy boolean
  ,p_interview_warning                out nocopy boolean
  ,p_review_warning                   out nocopy boolean
  ,p_recruiter_warning                out nocopy boolean
  ,p_asg_future_changes_warning       out nocopy boolean
  ,p_entries_changed_warning          out nocopy varchar2
  ,p_pay_proposal_warning             out nocopy boolean
  ,p_dod_warning                      out nocopy boolean
--
-- 120.4 (START)
--
  ,p_alu_change_warning               out nocopy varchar2
--
-- 120.4 (END)
--
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< final_process_emp >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API set the final process date for a terminated employee.
 *
 * This API covers the second step in terminating a period of service and all
 * current assignments for an employee. It updates the period of service
 * details and date-effectively deletes all employee assignments as of the
 * final process date. If a final process date is not specified for the U.S.
 * legislation, this API uses the actual termination date. For other
 * legislations, it uses the last standard process date. <P> If you want to
 * change the final process date after it has been entered, you must cancel the
 * termination and reapply the termination from the new date. <P>Element
 * entries for any assignment that have an element termination rule of Final
 * Close are date-effectively deleted from the final process date. Cost
 * allocations, grade step/point placements, COBRA coverage benefits, and
 * personal payment methods for all assignments are date-effectively deleted
 * from the final process date.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The ex-employee must exist in the relevant business group.
 *
 * <p><b>Post Success</b><br>
 * The ex-employee is updated with the relevant final process date. The
 * ex-employee's assignments and other related records are deleted as of the
 * effective date.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the period of service, assignments, or element
 * entries and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_period_of_service_id Period of service that is being terminated.
 * @param p_object_version_number Pass in the current version number of the
 * period of service to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated period of
 * service. If p_validate is true will be set to the same value which was
 * passed in.
 * @param p_final_process_date Final Process Date. If p_validate is false, then
 * set to the final process date on the updated period of service row. If
 * p_validate is true, then set to the value passed in.
 * @param p_org_now_no_manager_warning If set to true, from the final process
 * date of this assignment there are no other managers in the assignment's
 * organization.
 * @param p_asg_future_changes_warning If set to true, then at least one
 * assignment change, after the actual termination date, has been overwritten
 * with the new assignment status.
 * @param p_entries_changed_warning Set to Y when at least one element entry is
 * affected by the assignment change. Set to S if at least one salary element
 * entry is affected. (This is a more specific case than Y.) Otherwise, set to
 * N when no element entries are affected.
 * @rep:displayname Final Process Employee
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure final_process_emp
  (p_validate                      in     boolean  default false
  ,p_period_of_service_id          in     number
  ,p_object_version_number         in out nocopy number
  ,p_final_process_date            in out nocopy date
  ,p_org_now_no_manager_warning       out nocopy boolean
  ,p_asg_future_changes_warning       out nocopy boolean
  ,p_entries_changed_warning          out nocopy varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_term_details_emp >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates employee termination information.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The ex-employee must exist in the relevant business group.
 *
 * <p><b>Post Success</b><br>
 * The ex-employee record is updated successfully.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the period of service record and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_period_of_service_id Period of service that is being terminated.
 * @param p_object_version_number Pass in the current version number of the
 * period of service to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated period of
 * service. If p_validate is true will be set to the same value which was
 * passed in.
 * @param p_termination_accepted_person Person who accepted this termination.
 * @param p_accepted_termination_date Date when the termination of employment
 * was accepted
 * @param p_comments Comment text.
 * @param p_leaving_reason Termination Reason. Valid values are defined by the
 * LEAV_REAS lookup type.
 * @param p_notified_termination_date Date on which the termination was
 * notified.
 * @param p_projected_termination_date Projected termination date.
 * @rep:displayname Update Employee Termination Details
 * @rep:category BUSINESS_ENTITY PER_EX-EMPLOYEE
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_term_details_emp
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_period_of_service_id          in     number
  ,p_object_version_number         in out nocopy number
  ,p_termination_accepted_person   in     number   default hr_api.g_number
  ,p_accepted_termination_date     in     date     default hr_api.g_date
  ,p_comments                      in     varchar2 default hr_api.g_varchar2
  ,p_leaving_reason                in     varchar2 default hr_api.g_varchar2
  ,p_notified_termination_date     in     date     default hr_api.g_date
  ,p_projected_termination_date    in     date     default hr_api.g_date
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< check_for_compl_actions >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This is a private function for checking payroll actions as part
--   of validation of the termination
--
-- Prerequisites:
--   The employee must exist in the database.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_person_id                    Yes  Number   person_id
--   p_act_date                     Yes  date     actual termination date
--   p_lsp_date                     Yes  date     last standard process date
--   p_fpr_date                     Yes  date     final process date
--
-- Post Success:
--   The function will return a VARCHAR2 to indicate level of success.
--
-- Access Status:
--   Internal development use only
--
-- {End Of Comments}
FUNCTION check_for_compl_actions(p_person_id   NUMBER
                                ,p_act_date DATE
                                ,p_lsp_date DATE
                                ,p_fpr_date DATE) RETURN VARCHAR2;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< reverse_terminate_employee >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This API is not published, hence not meant for public calls.
--
-- Prerequisites:
--   The employee must exist in the database.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     No   boolean  If true, then validation alone will
--                                                be performed and the database will
--				                  remain unchanged. If false and all
--						  validation checks pass, then the
--						  database will be modified.
--   p_person_id                    Yes  Number   person_id
--   p_actual_termination_date      Yes  date     Actual termination date
--   p_clear_details                Yes  varchar2
--
-- Post Success:
--   The procedure will raise a Business Event when an employee's termination
--   is cancelled.
--
-- Access Status:
--   Internal development use only
--
-- {End Of Comments}

procedure reverse_terminate_employee
  (p_validate                      in     boolean  default false
  ,p_person_id                     in     number
  ,p_actual_termination_date       in     date
  ,p_clear_details                 in     varchar2
  );

end hr_ex_employee_api;

/
