--------------------------------------------------------
--  DDL for Package HR_CANCEL_PLACEMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CANCEL_PLACEMENT_API" AUTHID CURRENT_USER AS
/* $Header: pecplapi.pkh 120.1.12010000.1 2008/07/28 04:25:57 appldev ship $ */
/*#
 * This package contains APIs relating to canceling contingent worker
 * placements.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Cancel Placement
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< cancel_placement >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API cancels the placement of a contingent worker.
 *
 * The API deletes all record of a placement that exists on the effective date
 * specified, and restores the personal data from the period of time
 * immediately before the placement.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The person must exist, must not have future person type changes, and must
 * have a previous person record before the period of placement to which the
 * system can revert the data.
 *
 * <p><b>Post Success</b><br>
 * The current period of placement is deleted along with the contingent worker
 * assignments. The person data from the period of time prior to becoming an
 * contingent worker are reinstated.
 *
 * <p><b>Post Failure</b><br>
 * An error is raised and the period of placement and related contingent worker
 * assignment records are not deleted.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_person_id Identifies the person record for which the cancellation
 * is to be processed.
 * @param p_effective_date Identifies the date on which the period of placement
 * that is to be cancelled should exist.
 * @param p_supervisor_warning Set to true if contingent worker was a
 * supervisor, otherwise set to false.
 * @param p_recruiter_warning Set to true if contingent worker was a recruiter
 * for any assignments, otherwise set to false.
 * @param p_event_warning Set to true if the contingent worker was registered
 * for any outstanding events, otherwise set to false.
 * @param p_interview_warning Set to true if the contingent worker had any
 * interviews scheduled, otherwise set to false.
 * @param p_review_warning Set to true if the contingent worker has a review
 * scheduled, otherwise set to false.
 * @param p_vacancy_warning Set to true if contingent worker was a recruiter
 * for a vacancy, otherwise set to false.
 * @param p_requisition_warning Set to true if the contingent worker raised a
 * requisition, otherwise set to false.
 * @param p_budget_warning Set to true if the contingent worker had assignment
 * budget values defined for any assignment. Otherwise set to false.
 * @param p_payment_warning Set to true if the contingent worker has a personal
 * payment method registered. Otherwise set to false.
 * @rep:displayname Cancel Placement
 * @rep:category BUSINESS_ENTITY PER_CWK
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE cancel_placement
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
END hr_cancel_placement_api;

/
