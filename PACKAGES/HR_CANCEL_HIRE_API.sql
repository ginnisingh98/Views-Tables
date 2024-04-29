--------------------------------------------------------
--  DDL for Package HR_CANCEL_HIRE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CANCEL_HIRE_API" AUTHID CURRENT_USER as
/* $Header: pecahapi.pkh 120.1.12010000.2 2008/10/01 10:42:23 ghshanka ship $ */
/*#
 * This package contains APIs relating to canceling employee hires.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Cancel Hire
*/
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< cancel_hire >----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API cancels the hire of an employee.
 *
 * The API deletes all record of a hire that exists on the effective date and
 * restores the personal data from the period of time immediately before the
 * hire.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The person must exist, must not have future person type changes, and must
 * have a previous person record before the hire to which the system can revert
 * the data.
 *
 * <p><b>Post Success</b><br>
 * The current period of service is deleted along with the employee
 * assignments. The person data from the period of time prior to becoming an
 * employee are reinstated.
 *
 * <p><b>Post Failure</b><br>
 * An error is raised and the period of service and related employee assignment
 * records are not deleted.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_person_id Identifies the person record for which the cancellation
 * is to be processed.
 * @param p_effective_date Identifies the date on which the period of service
 * that is to be cancelled should exist.
 * @param p_supervisor_warning Set to true if employee was a supervisor,
 * otherwise set to false.
 * @param p_recruiter_warning Set to true if employee was a recruiter for any
 * assignments, otherwise set to false.
 * @param p_event_warning Set to true if the employee was registered for any
 * outstanding events, otherwise set to false.
 * @param p_interview_warning Set to true if the employee had any interviews
 * scheduled, otherwise set to false.
 * @param p_review_warning Set to true if the employee has a review scheduled,
 * otherwise set to false.
 * @param p_vacancy_warning Set to true if employee was a recruiter for a
 * vacancy, otherwise set to false.
 * @param p_requisition_warning Set to true if the employee raised a
 * requisition, otherwise set to false.
 * @param p_budget_warning Set to true if the employee had assignment budget
 * values defined for any assignment. Otherwise set to false.
 * @param p_payment_warning Set to true if the employee has a personal payment
 * method registered. Otherwise set to false.
 * @param p_pay_proposal_warning Set to true if the employee has a future dated salary
 * proposals entry. Otherwise set to false.
 * @rep:displayname Cancel Hire
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
--
procedure cancel_hire
  (p_validate            IN     BOOLEAN  DEFAULT FALSE
  ,p_person_id           IN     NUMBER
  ,p_effective_date      IN     DATE
  ,p_supervisor_warning     OUT NOCOPY BOOLEAN
  ,p_recruiter_warning      OUT NOCOPY BOOLEAN
  ,p_event_warning          OUT NOCOPY BOOLEAN
  ,p_interview_warning      OUT NOCOPY BOOLEAN
  ,p_review_warning         OUT NOCOPY BOOLEAN
  ,p_vacancy_warning        OUT NOCOPY BOOLEAN
  ,p_requisition_warning    OUT NOCOPY BOOLEAN
  ,p_budget_warning         OUT NOCOPY BOOLEAN
  ,p_payment_warning        OUT NOCOPY BOOLEAN
  ,p_pay_proposal_warning   out nocopy boolean );
--
--

-- ----------------------------------------------------------------------------
-- |-------------------------------< cancel_hire (Overloaded)>----------------|
-- ----------------------------------------------------------------------------
--
procedure cancel_hire
  (p_validate            IN     BOOLEAN  DEFAULT FALSE
  ,p_person_id           IN     NUMBER
  ,p_effective_date      IN     DATE
  ,p_supervisor_warning     OUT NOCOPY BOOLEAN
  ,p_recruiter_warning      OUT NOCOPY BOOLEAN
  ,p_event_warning          OUT NOCOPY BOOLEAN
  ,p_interview_warning      OUT NOCOPY BOOLEAN
  ,p_review_warning         OUT NOCOPY BOOLEAN
  ,p_vacancy_warning        OUT NOCOPY BOOLEAN
  ,p_requisition_warning    OUT NOCOPY BOOLEAN
  ,p_budget_warning         OUT NOCOPY BOOLEAN
  ,p_payment_warning        OUT NOCOPY BOOLEAN);
  --

end hr_cancel_hire_api;


/
