--------------------------------------------------------
--  DDL for Package HR_MAINTAIN_PROPOSAL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_MAINTAIN_PROPOSAL_API" AUTHID CURRENT_USER as
/* $Header: hrpypapi.pkh 120.11.12010000.3 2008/12/05 14:33:06 vkodedal ship $ */
/*#
 * This package contains APIs for creating and maintaining Salary Proposal
 * information.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Maintain Proposal
*/
--vkodedal 04-dec-2008 7386307
g_deleted_from_oa varchar2(1):='N';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< insert_salary_proposal >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API inserts a salary proposal into the per_pay_proposals table.
 *
 * If the proposal is an approved one, this procedure will also insert into the
 * pay_element_entries table to create a new salary proposal.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Assignment for which salary proposal is created must exist as of the
 * effective date and have a salary basis defined.
 *
 * <p><b>Post Success</b><br>
 * The specified data will be validated and inserted for the specified entity
 * without being committed (or rollbacked depending on the p_validate status).
 *
 * <p><b>Post Failure</b><br>
 * If an error has occurred, the process will raise an error message and roll
 * back the work.
 * @param p_pay_proposal_id A sequential, process-generated primary key value.
 * @param p_assignment_id Identifies the assignment for which you create the
 * salary proposal record.
 * @param p_business_group_id Uniquely identifies the business group of the
 * person associated with the salary proposal. References
 * HR_ALL_ORGANIZATION_UNITS.
 * @param p_change_date The date on which the proposal takes effect.
 * @param p_comments Comment text.
 * @param p_next_sal_review_date The date of the next salary review.
 * @param p_proposal_reason The proposal reason. Valid values are defined by
 * lookup type 'PROPOSAL_REASON'.
 * @param p_proposed_salary_n The proposed salary for the employee.
 * @param p_forced_ranking The ranking of the person associated with the salary
 * proposal.
 * @param p_date_to The end date of salary proposal.
 * @param p_performance_review_id The performance_review_id of the performance
 * review associated with this salary review.
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
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created salary proposal. If p_validate is true, then
 * the value will be null.
 * @param p_multiple_components Flag specifying if multiple components are
 * associated with this salary proposal. Valid values are 'Y' or 'N'.
 * @param p_approved Flag specifying if the proposal is approved. Valid values
 * are 'Y' or 'N'.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_element_entry_id Returns the id of the created element entry here.
 * @param p_inv_next_sal_date_warning If set to true, the salary date specified
 * is invalid.
 * @param p_proposed_salary_warning If set to true, the proposed salary is not
 * within the range specified by the assignment's grade rate.
 * @param p_approved_warning If set to true, there were errors during the
 * approval process.
 * @param p_payroll_warning If set to true, the person's payroll is invalid.
 * @rep:displayname Insert Salary Proposal
 * @rep:category BUSINESS_ENTITY PER_SALARY_PROPOSAL
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
Procedure insert_salary_proposal(
  p_pay_proposal_id              out nocopy number,
  p_assignment_id                in number,
  p_business_group_id            in number,
  p_change_date                  in date             default null, -- Bug 918219
  p_comments                     in varchar2         default null,
  p_next_sal_review_date         in date             default null,
  p_proposal_reason              in varchar2         default null,
  p_proposed_salary_n            in number           default null,
  p_forced_ranking               in number           default null,
  p_date_to			 in date	     ,
  p_performance_review_id        in number           default null,
  p_attribute_category           in varchar2         default null,
  p_attribute1                   in varchar2         default null,
  p_attribute2                   in varchar2         default null,
  p_attribute3                   in varchar2         default null,
  p_attribute4                   in varchar2         default null,
  p_attribute5                   in varchar2         default null,
  p_attribute6                   in varchar2         default null,
  p_attribute7                   in varchar2         default null,
  p_attribute8                   in varchar2         default null,
  p_attribute9                   in varchar2         default null,
  p_attribute10                  in varchar2         default null,
  p_attribute11                  in varchar2         default null,
  p_attribute12                  in varchar2         default null,
  p_attribute13                  in varchar2         default null,
  p_attribute14                  in varchar2         default null,
  p_attribute15                  in varchar2         default null,
  p_attribute16                  in varchar2         default null,
  p_attribute17                  in varchar2         default null,
  p_attribute18                  in varchar2         default null,
  p_attribute19                  in varchar2         default null,
  p_attribute20                  in varchar2         default null,
  p_object_version_number        out nocopy number,
  p_multiple_components          in varchar2         default null, -- 918219
  p_approved                     in varchar2         default null, -- 918219
  p_validate                     in boolean          default false,
  p_element_entry_id             in out nocopy number,
  p_inv_next_sal_date_warning	 out nocopy boolean,
  p_proposed_salary_warning      out nocopy boolean,
  p_approved_warning             out nocopy boolean,
  p_payroll_warning		 out nocopy boolean );

Procedure insert_salary_proposal(
  p_pay_proposal_id              out nocopy number,
  p_assignment_id                in number,
  p_business_group_id            in number,
  p_change_date                  in date             default null, -- Bug 918219
  p_comments                     in varchar2         default null,
  p_next_sal_review_date         in date             default null,
  p_proposal_reason              in varchar2         default null,
  p_proposed_salary_n            in number           default null,
  p_forced_ranking               in number           default null,
  p_performance_review_id        in number           default null,
  p_attribute_category           in varchar2         default null,
  p_attribute1                   in varchar2         default null,
  p_attribute2                   in varchar2         default null,
  p_attribute3                   in varchar2         default null,
  p_attribute4                   in varchar2         default null,
  p_attribute5                   in varchar2         default null,
  p_attribute6                   in varchar2         default null,
  p_attribute7                   in varchar2         default null,
  p_attribute8                   in varchar2         default null,
  p_attribute9                   in varchar2         default null,
  p_attribute10                  in varchar2         default null,
  p_attribute11                  in varchar2         default null,
  p_attribute12                  in varchar2         default null,
  p_attribute13                  in varchar2         default null,
  p_attribute14                  in varchar2         default null,
  p_attribute15                  in varchar2         default null,
  p_attribute16                  in varchar2         default null,
  p_attribute17                  in varchar2         default null,
  p_attribute18                  in varchar2         default null,
  p_attribute19                  in varchar2         default null,
  p_attribute20                  in varchar2         default null,
  p_object_version_number        out nocopy number,
  p_multiple_components          in varchar2         default null, -- 918219
  p_approved                     in varchar2         default null, -- 918219
  p_validate                     in boolean          default false,
  p_element_entry_id             in out nocopy number,
  p_inv_next_sal_date_warning	 out nocopy boolean,
  p_proposed_salary_warning      out nocopy boolean,
  p_approved_warning             out nocopy boolean,
  p_payroll_warning		 out nocopy boolean );
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_salary_proposal >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a salary proposal associated with an assignment.
 *
 * If the updated proposal is approved, it also inserts a new record in the
 * pay_element_entries table.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Proposal to be updated must exist with the specified object version number.
 *
 * <p><b>Post Success</b><br>
 * The specified data will be validated and updated for the specified entity
 * without being committed (or rollbacked depending on the status of
 * p_validate).
 *
 * <p><b>Post Failure</b><br>
 * If an error has occurred, an error message will be supplied and the work
 * rolled back.
 * @param p_pay_proposal_id pay_proposal_id of the proposal to be updated
 * @param p_change_date The date on which the proposal takes effect.
 * @param p_comments Comment text.
 * @param p_next_sal_review_date The date of the next salary review.
 * @param p_proposal_reason The proposal reason. Valid values are defined by
 * lookup type 'PROPOSAL_REASON'.
 * @param p_proposed_salary_n The proposed salary for the employee.
 * @param p_forced_ranking The ranking of the person associated with the salary
 * proposal.
 * @param p_date_to The end date of salary proposal.
 * @param p_performance_review_id The performance_review_id of the performance
 * review associated with this salary review.
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
 * @param p_object_version_number Pass in the current version number of the
 * salary proposal to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated salary proposal.
 * If p_validate is true will be set to the same value which was passed in.
 * @param p_multiple_components Flag specifying if multiple components are
 * associated with this salary proposal. Valid values are 'Y' or 'N'.
 * @param p_approved Flag specifying if the proposal is approved. Valid values
 * are 'Y' or 'N'.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_inv_next_sal_date_warning If set to true, the salary date specified
 * is invalid.
 * @param p_proposed_salary_warning If set to true, the proposed salary is not
 * within the range specified by the assignment's grade rate.
 * @param p_approved_warning If set to true, there were errors during the
 * approval process.
 * @param p_payroll_warning If set to true, the person's payroll is invalid.
 * @rep:displayname Update Salary Proposal
 * @rep:category BUSINESS_ENTITY PER_SALARY_PROPOSAL
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
Procedure update_salary_proposal(
  p_pay_proposal_id              in number,
  p_change_date                  in date             default hr_api.g_date,
  p_comments                     in varchar2         default hr_api.g_varchar2,
  p_next_sal_review_date         in date             default hr_api.g_date,
  p_proposal_reason              in varchar2         default hr_api.g_varchar2,
  p_proposed_salary_n            in number           default hr_api.g_number,
  p_forced_ranking               in number           default hr_api.g_number,
  p_date_to                      in date             ,
  p_performance_review_id        in number           default hr_api.g_number,
  p_attribute_category           in varchar2         default hr_api.g_varchar2,
  p_attribute1                   in varchar2         default hr_api.g_varchar2,
  p_attribute2                   in varchar2         default hr_api.g_varchar2,
  p_attribute3                   in varchar2         default hr_api.g_varchar2,
  p_attribute4                   in varchar2         default hr_api.g_varchar2,
  p_attribute5                   in varchar2         default hr_api.g_varchar2,
  p_attribute6                   in varchar2         default hr_api.g_varchar2,
  p_attribute7                   in varchar2         default hr_api.g_varchar2,
  p_attribute8                   in varchar2         default hr_api.g_varchar2,
  p_attribute9                   in varchar2         default hr_api.g_varchar2,
  p_attribute10                  in varchar2         default hr_api.g_varchar2,
  p_attribute11                  in varchar2         default hr_api.g_varchar2,
  p_attribute12                  in varchar2         default hr_api.g_varchar2,
  p_attribute13                  in varchar2         default hr_api.g_varchar2,
  p_attribute14                  in varchar2         default hr_api.g_varchar2,
  p_attribute15                  in varchar2         default hr_api.g_varchar2,
  p_attribute16                  in varchar2         default hr_api.g_varchar2,
  p_attribute17                  in varchar2         default hr_api.g_varchar2,
  p_attribute18                  in varchar2         default hr_api.g_varchar2,
  p_attribute19                  in varchar2         default hr_api.g_varchar2,
  p_attribute20                  in varchar2         default hr_api.g_varchar2,
  p_object_version_number        in out nocopy number,
  p_multiple_components          in varchar2         default hr_api.g_varchar2,
  p_approved                     in varchar2         default hr_api.g_varchar2,
  p_validate                     in boolean          default false,
  p_inv_next_sal_date_warning    out nocopy boolean,
  p_proposed_salary_warning	 out nocopy boolean,
  p_approved_warning	         out nocopy boolean,
  p_payroll_warning	         out nocopy boolean
);
Procedure update_salary_proposal(
  p_pay_proposal_id              in number,
  p_change_date                  in date             default hr_api.g_date,
  p_comments                     in varchar2         default hr_api.g_varchar2,
  p_next_sal_review_date         in date             default hr_api.g_date,
  p_proposal_reason              in varchar2         default hr_api.g_varchar2,
  p_proposed_salary_n            in number           default hr_api.g_number,
  p_forced_ranking               in number           default hr_api.g_number,
  p_performance_review_id        in number           default hr_api.g_number,
  p_attribute_category           in varchar2         default hr_api.g_varchar2,
  p_attribute1                   in varchar2         default hr_api.g_varchar2,
  p_attribute2                   in varchar2         default hr_api.g_varchar2,
  p_attribute3                   in varchar2         default hr_api.g_varchar2,
  p_attribute4                   in varchar2         default hr_api.g_varchar2,
  p_attribute5                   in varchar2         default hr_api.g_varchar2,
  p_attribute6                   in varchar2         default hr_api.g_varchar2,
  p_attribute7                   in varchar2         default hr_api.g_varchar2,
  p_attribute8                   in varchar2         default hr_api.g_varchar2,
  p_attribute9                   in varchar2         default hr_api.g_varchar2,
  p_attribute10                  in varchar2         default hr_api.g_varchar2,
  p_attribute11                  in varchar2         default hr_api.g_varchar2,
  p_attribute12                  in varchar2         default hr_api.g_varchar2,
  p_attribute13                  in varchar2         default hr_api.g_varchar2,
  p_attribute14                  in varchar2         default hr_api.g_varchar2,
  p_attribute15                  in varchar2         default hr_api.g_varchar2,
  p_attribute16                  in varchar2         default hr_api.g_varchar2,
  p_attribute17                  in varchar2         default hr_api.g_varchar2,
  p_attribute18                  in varchar2         default hr_api.g_varchar2,
  p_attribute19                  in varchar2         default hr_api.g_varchar2,
  p_attribute20                  in varchar2         default hr_api.g_varchar2,
  p_object_version_number        in out nocopy number,
  p_multiple_components          in varchar2         default hr_api.g_varchar2,
  p_approved                     in varchar2         default hr_api.g_varchar2,
  p_validate                     in boolean          default false,
  p_inv_next_sal_date_warning    out nocopy boolean,
  p_proposed_salary_warning	 out nocopy boolean,
  p_approved_warning	         out nocopy boolean,
  p_payroll_warning	         out nocopy boolean
);
--
-- ----------------------------------------------------------------------------
-- |-------------------------< approve_salary_proposal >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API approves a person's salary.
 *
 * Use it to approve salary proposals you enter in the salary managment form.
 * If the proposal has multiple components, all components must be approved.
 * The process does not approve individual components.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * Proposal to be approved must exist with the specified version number. If the
 * proposal has multiple components, all the components must be approved.
 *
 * <p><b>Post Success</b><br>
 * The specified data will be validated and updated for the specified entity
 * without being committed (or rollbacked, depending on the status of
 * p_validate).
 *
 * <p><b>Post Failure</b><br>
 * If an error has occurred, an error message will be supplied with the work
 * rolled back. The error will NOT be raised, but the error text will be passed
 * out. Developer Implementation Note: you call this from forms (PERPIPYP).
 * @param p_pay_proposal_id The pay_proposal_id of the proposal to be updated.
 * @param p_change_date The date on which the proposal takes effect.
 * @param p_proposed_salary_n The proposed salary.
 * @param p_object_version_number Pass in the current version number of the
 * salary proposal to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated proposal. If
 * p_validate is true will be set to the same value which was passed in. If
 * p_pay_proposal_id is null and p_validate is false, then set to the version
 * number of the newly created salary proposal and if p_validate is true, then
 * the value will be null.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_inv_next_sal_date_warning If set to true, the salary date specified
 * is invalid.
 * @param p_proposed_salary_warning If set to true, the proposed salary is not
 * within the range specified by the assignment's grade rate.
 * @param p_approved_warning If set to true, there were errors during the
 * approval process.
 * @param p_payroll_warning If set to true, the person's payroll is invalid.
 * @param p_error_text Error text explaining the error encountered while
 * approving the proposal.
 * @rep:displayname Approve Salary Proposal
 * @rep:category BUSINESS_ENTITY PER_SALARY_PROPOSAL
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
Procedure approve_salary_proposal(
  p_pay_proposal_id              in number,
  p_change_date                  in date             default hr_api.g_date,
  p_proposed_salary_n            in number           default hr_api.g_number,
  p_object_version_number        in out nocopy number,
  p_validate                     in boolean          default false,
  p_inv_next_sal_date_warning    out nocopy boolean,
  p_proposed_salary_warning	 out nocopy boolean,
  p_approved_warning	         out nocopy boolean,
  p_payroll_warning              out nocopy boolean,
  p_error_text                   out nocopy varchar2);
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_salary_proposal >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a salary proposal.
 *
 * This API deletes an entire salary proposal, including it's components. It is
 * necessary to code this separately, because you cannot delete the components
 * of an approved salary. After deleting all of the components the process
 * deletes the associated element, using the appropriate date track mode. It
 * then deletes the actual proposal.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The proposal to be deleted must exist with the specified object version
 * number.
 *
 * <p><b>Post Success</b><br>
 * The specified row will be validated and deleted for the specified entity
 * without being committed (or rollbacked depending on the p_validate status).
 *
 * <p><b>Post Failure</b><br>
 * If an error has occurred, an error message will be supplied with the work
 * rolled back. Developer Implementation Notes: you call this from forms. You
 * must remove the standard ON-CHECK-MASTER-DELETE code to allow this
 * (non-standard) behaviour.
 * @param p_pay_proposal_id The pay_proposal_id of the proposal to be deleted.
 * @param p_business_group_id The business_group_id of the proposal to be
 * deleted.
 * @param p_object_version_number The current version number of the salary
 * proposal to be deleted.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_salary_warning If set to true, an error occurred while deleting the
 * proposal.
 * @rep:displayname Delete Salary Proposal
 * @rep:category BUSINESS_ENTITY PER_SALARY_PROPOSAL
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
Procedure delete_salary_proposal(p_pay_proposal_id       in number
                                ,p_business_group_id     in number
                                ,p_object_version_number in number
                                ,p_validate              in boolean default false
                                ,p_salary_warning        out nocopy boolean);
--
-- ----------------------------------------------------------------------------
-- |------------------------< insert_proposal_component >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API inserts a Salary Proposal component.
 *
 * The process inserts a component of a pay proposal in the
 * per_pay_proposal_components table.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid proposal must exist with MULTIPLE_COMPONENTS set to Y and it must
 * have a status of unapproved.
 *
 * <p><b>Post Success</b><br>
 * The specified data will be validated and inserted for the specified entity
 * without being committed (or rollbacked, depending on the status of
 * p_validate).
 *
 * <p><b>Post Failure</b><br>
 * If an error has occurred, an error message will be supplied with the work
 * rolled back. Developer Implementation Notes: you call this from forms.
 * @param p_component_id A sequential, process-generated primary key value.
 * @param p_pay_proposal_id The pay proposal id associated with the component.
 * References PER_PAY_PROPOSALS.
 * @param p_business_group_id Uniquely identifies the business group of the
 * person associated with the proposal component. References
 * HR_ALL_ORGANIZATION_UNITS.
 * @param p_approved Flag specifying if the proposal is approved. Valid values
 * are 'Y' or 'N'.
 * @param p_component_reason The reason for the proposal component. Valid
 * values are defined by lookup type 'PROPOSAL_REASON'.
 * @param p_change_amount_n The amount associated with the change.
 * @param p_change_percentage change as a percentage of the previous salary
 * @param p_comments Comment text.
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
 * @param p_validation_strength Specifies how strong the validation should be.
 * Should always be set to STRONG, unless called from the insert component API,
 * which is trying to insert a component into a proposal which is about to be
 * changed. In this case it should be set to WEAK, and the process ignores
 * conditions specifying you cannot insert components for an approved proposal,
 * or insert components for a proposal with multiple components set to 'N'.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created component. If p_validate is true, then the
 * value will be null.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @rep:displayname Insert Proposal Component
 * @rep:category BUSINESS_ENTITY PER_SALARY_PROPOSAL
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
Procedure insert_proposal_component(
  p_component_id                 out nocopy number,
  p_pay_proposal_id              in number,
  p_business_group_id            in number,
  p_approved                     in varchar2,
  p_component_reason             in varchar2,
  p_change_amount_n              in number           default null,
  p_change_percentage            in number           default null,
  p_comments                     in varchar2         default null,
  p_attribute_category           in varchar2         default null,
  p_attribute1                   in varchar2         default null,
  p_attribute2                   in varchar2         default null,
  p_attribute3                   in varchar2         default null,
  p_attribute4                   in varchar2         default null,
  p_attribute5                   in varchar2         default null,
  p_attribute6                   in varchar2         default null,
  p_attribute7                   in varchar2         default null,
  p_attribute8                   in varchar2         default null,
  p_attribute9                   in varchar2         default null,
  p_attribute10                  in varchar2         default null,
  p_attribute11                  in varchar2         default null,
  p_attribute12                  in varchar2         default null,
  p_attribute13                  in varchar2         default null,
  p_attribute14                  in varchar2         default null,
  p_attribute15                  in varchar2         default null,
  p_attribute16                  in varchar2         default null,
  p_attribute17                  in varchar2         default null,
  p_attribute18                  in varchar2         default null,
  p_attribute19                  in varchar2         default null,
  p_attribute20                  in varchar2         default null,
  p_validation_strength          in varchar2         default 'STRONG',
  p_object_version_number        out nocopy number,
  p_validate                     in boolean   default false);
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_proposal_component >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a proposal component.
 *
 * The process updates a component of a pay proposal in the table
 * per_pay_proposal_components.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * A valid proposal must exist with MULTIPLE_COMPONENTS set to Y and it must
 * have a status of unapproved
 *
 * <p><b>Post Success</b><br>
 * The specified data will be validated and inserted for the specified entity
 * without being committed (or rollbacked depending on the status of
 * p_validate).
 *
 * <p><b>Post Failure</b><br>
 * If an error has occurred, an error message will be supplied with the work
 * rolled back. Developer Implementation Notes: you call this from forms.
 * @param p_component_id The component_id of the created component.
 * @param p_approved Flag specifying if the proposal is approved. Valid values
 * are 'Y' or 'N'.
 * @param p_component_reason The reason for the proposal component. Valid
 * values are defined by lookup type 'PROPOSAL_REASON'.
 * @param p_change_amount_n The amount associated with the change.
 * @param p_change_percentage The change amount as a percentage of the previous
 * salary.
 * @param p_comments Comment text.
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
 * @param p_validation_strength Specifies how strong the validation should be.
 * Should always be set to STRONG, unless called from the update component API,
 * which is trying to update a component into a proposal which is about to
 * change. In this case it should be set to WEAK, and the process ignores
 * conditions specifying you cannot update components for an approved proposal,
 * or update components for a proposal with multiple components set to 'N'.
 * @param p_object_version_number Pass in the current version number of the
 * component to be updated. When the API completes if p_validate is false, will
 * be set to the new version number of the updated component. If p_validate is
 * true will be set to the same value which was passed in.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @rep:displayname Update Proposal Component
 * @rep:category BUSINESS_ENTITY PER_SALARY_PROPOSAL
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_proposal_component(
  p_component_id                 in number,
  p_approved                     in varchar2         default hr_api.g_varchar2,
  p_component_reason             in varchar2         default hr_api.g_varchar2,
  p_change_amount_n              in number           default hr_api.g_number,
  p_change_percentage            in number           default hr_api.g_number,
  p_comments                     in varchar2         default hr_api.g_varchar2,
  p_attribute_category           in varchar2         default hr_api.g_varchar2,
  p_attribute1                   in varchar2         default hr_api.g_varchar2,
  p_attribute2                   in varchar2         default hr_api.g_varchar2,
  p_attribute3                   in varchar2         default hr_api.g_varchar2,
  p_attribute4                   in varchar2         default hr_api.g_varchar2,
  p_attribute5                   in varchar2         default hr_api.g_varchar2,
  p_attribute6                   in varchar2         default hr_api.g_varchar2,
  p_attribute7                   in varchar2         default hr_api.g_varchar2,
  p_attribute8                   in varchar2         default hr_api.g_varchar2,
  p_attribute9                   in varchar2         default hr_api.g_varchar2,
  p_attribute10                  in varchar2         default hr_api.g_varchar2,
  p_attribute11                  in varchar2         default hr_api.g_varchar2,
  p_attribute12                  in varchar2         default hr_api.g_varchar2,
  p_attribute13                  in varchar2         default hr_api.g_varchar2,
  p_attribute14                  in varchar2         default hr_api.g_varchar2,
  p_attribute15                  in varchar2         default hr_api.g_varchar2,
  p_attribute16                  in varchar2         default hr_api.g_varchar2,
  p_attribute17                  in varchar2         default hr_api.g_varchar2,
  p_attribute18                  in varchar2         default hr_api.g_varchar2,
  p_attribute19                  in varchar2         default hr_api.g_varchar2,
  p_attribute20                  in varchar2         default hr_api.g_varchar2,
  p_validation_strength          in varchar2         default 'STRONG',
  p_object_version_number        in out nocopy number,
  p_validate                     in boolean          default false
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_proposal_component >---------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API deletes a salary proposal component.
 *
 * This procedure deletes a salary proposal component without checking if the
 * proposal is approved, so you can delete an entire proposal.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The specified Salary Component must exist with the specified version number.
 *
 * <p><b>Post Success</b><br>
 * The specified row will be fully validated and deleted for the specified
 * entity without being committed (or rollbacked depending on the status of
 * p_validate).
 *
 * <p><b>Post Failure</b><br>
 * If an error has occurred, an error message will be supplied with the work
 * rolled back. Developer Implementation Notes: This is intended for forms use
 * only.
 * @param p_component_id Uniquely identifies the component to delete.
 * @param p_validation_strength Set this value to specify that the process can
 * delete the components of an approved proposal. This enables you to delete an
 * entire approved proposal.
 * @param p_object_version_number Current version number of the salary
 * component to be deleted.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @rep:displayname Delete Proposal Component
 * @rep:category BUSINESS_ENTITY PER_SALARY_PROPOSAL
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
Procedure delete_proposal_component(
  p_component_id                       in number,
  p_validation_strength                in varchar2 default 'STRONG',
  p_object_version_number              in number,
  p_validate                           in boolean default false);
--
-- ----------------------------------------------------------------------------
-- |------------------------< cre_or_upd_salary_proposal >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates or updates a Salary Proposal.
 *
 * The API creates a new proposal if you pass no proposal id. Otherwise, it
 * updates the associated salary proposal with the details you specify.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The assignment for which the salary proposal is created must exist as of the
 * effective date, and have a salary basis defined.
 *
 * <p><b>Post Success</b><br>
 * The specified data will be validated and updated for the specified entity
 * without being committed (or rollbacked depending on the p_validate status).
 *
 * <p><b>Post Failure</b><br>
 * If an error has occurred, an error message will be supplied with the work
 * rolled back. Developer Implementation Notes: you call this from forms.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_pay_proposal_id Uniquely identifies the pay proposal to update.
 * @param p_object_version_number Pass in the current version number of the
 * Proposal to be updated, otherwise pass null. When the API completes if
 * p_validate is false, will be set to the new version number of the updated
 * proposal. If p_validate is true will be set to the same value which was
 * passed in.
 * @param p_business_group_id Uniquely identifies the business_group associated
 * with the salary proposal. References HR_ALL_ORGANIZATION_UNITS.
 * @param p_assignment_id Uniquely identifies the assignment for which you
 * create the salary proposal record.
 * @param p_change_date The date on which the proposal takes effect.
 * @param p_comments Comment text.
 * @param p_next_sal_review_date The date of the next salary review.
 * @param p_proposal_reason The reason for the proposal. Valid values are
 * identified by the lookup "PROPOSAL_REASON".
 * @param p_proposed_salary_n The proposed salary.
 * @param p_forced_ranking The employee's ranking.
 * @param p_date_to The end date of salary proposal.
 * @param p_performance_review_id The performance_review_id of the performance
 * review associated with this salary proposal.
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
 * @param p_multiple_components Flag specifying if multiple components are
 * associated with this salary proposal. Valid values are 'Y' or 'N'.
 * @param p_approved Flag specifying if the proposal is approved. Valid values
 * are 'Y' or 'N'.
 * @param p_inv_next_sal_date_warning If set to true, the salary date specified
 * is invalid.
 * @param p_proposed_salary_warning If set to true, the proposed salary is not
 * within the range specified by the assignment's grade rate.
 * @param p_approved_warning If set to true, there were errors during the
 * approval process.
 * @param p_payroll_warning If set to true, the person's payroll is invalid.
 * @rep:displayname Create or Update a Salary Proposal
 * @rep:category BUSINESS_ENTITY PER_SALARY_PROPOSAL
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure cre_or_upd_salary_proposal(
  p_validate                     in boolean          default false,
  p_pay_proposal_id              in out nocopy number,
  p_object_version_number        in out nocopy number,
  p_business_group_id            in number           default hr_api.g_number,
  p_assignment_id                in number           default hr_api.g_number,
  p_change_date                  in date             default hr_api.g_date,
  p_comments                     in varchar2         default hr_api.g_varchar2,
  p_next_sal_review_date         in date             default hr_api.g_date,
  p_proposal_reason              in varchar2         default hr_api.g_varchar2,
  p_proposed_salary_n            in number           default hr_api.g_number,
  p_forced_ranking               in number           default hr_api.g_number,
  p_date_to			 in date	     ,
  p_performance_review_id        in number           default hr_api.g_number,
  p_attribute_category           in varchar2         default hr_api.g_varchar2,
  p_attribute1                   in varchar2         default hr_api.g_varchar2,
  p_attribute2                   in varchar2         default hr_api.g_varchar2,
  p_attribute3                   in varchar2         default hr_api.g_varchar2,
  p_attribute4                   in varchar2         default hr_api.g_varchar2,
  p_attribute5                   in varchar2         default hr_api.g_varchar2,
  p_attribute6                   in varchar2         default hr_api.g_varchar2,
  p_attribute7                   in varchar2         default hr_api.g_varchar2,
  p_attribute8                   in varchar2         default hr_api.g_varchar2,
  p_attribute9                   in varchar2         default hr_api.g_varchar2,
  p_attribute10                  in varchar2         default hr_api.g_varchar2,
  p_attribute11                  in varchar2         default hr_api.g_varchar2,
  p_attribute12                  in varchar2         default hr_api.g_varchar2,
  p_attribute13                  in varchar2         default hr_api.g_varchar2,
  p_attribute14                  in varchar2         default hr_api.g_varchar2,
  p_attribute15                  in varchar2         default hr_api.g_varchar2,
  p_attribute16                  in varchar2         default hr_api.g_varchar2,
  p_attribute17                  in varchar2         default hr_api.g_varchar2,
  p_attribute18                  in varchar2         default hr_api.g_varchar2,
  p_attribute19                  in varchar2         default hr_api.g_varchar2,
  p_attribute20                  in varchar2         default hr_api.g_varchar2,
  p_multiple_components          in varchar2         default hr_api.g_varchar2,
  p_approved                     in varchar2         default hr_api.g_varchar2,
  p_inv_next_sal_date_warning    out nocopy boolean,
  p_proposed_salary_warning	 out nocopy boolean,
  p_approved_warning	         out nocopy boolean,
  p_payroll_warning	         out nocopy boolean
);
procedure cre_or_upd_salary_proposal(
  p_validate                     in boolean          default false,
  p_pay_proposal_id              in out nocopy number,
  p_object_version_number        in out nocopy number,
  p_business_group_id            in number           default hr_api.g_number,
  p_assignment_id                in number           default hr_api.g_number,
  p_change_date                  in date             default hr_api.g_date,
  p_comments                     in varchar2         default hr_api.g_varchar2,
  p_next_sal_review_date         in date             default hr_api.g_date,
  p_proposal_reason              in varchar2         default hr_api.g_varchar2,
  p_proposed_salary_n            in number           default hr_api.g_number,
  p_forced_ranking               in number           default hr_api.g_number,
  p_performance_review_id        in number           default hr_api.g_number,
  p_attribute_category           in varchar2         default hr_api.g_varchar2,
  p_attribute1                   in varchar2         default hr_api.g_varchar2,
  p_attribute2                   in varchar2         default hr_api.g_varchar2,
  p_attribute3                   in varchar2         default hr_api.g_varchar2,
  p_attribute4                   in varchar2         default hr_api.g_varchar2,
  p_attribute5                   in varchar2         default hr_api.g_varchar2,
  p_attribute6                   in varchar2         default hr_api.g_varchar2,
  p_attribute7                   in varchar2         default hr_api.g_varchar2,
  p_attribute8                   in varchar2         default hr_api.g_varchar2,
  p_attribute9                   in varchar2         default hr_api.g_varchar2,
  p_attribute10                  in varchar2         default hr_api.g_varchar2,
  p_attribute11                  in varchar2         default hr_api.g_varchar2,
  p_attribute12                  in varchar2         default hr_api.g_varchar2,
  p_attribute13                  in varchar2         default hr_api.g_varchar2,
  p_attribute14                  in varchar2         default hr_api.g_varchar2,
  p_attribute15                  in varchar2         default hr_api.g_varchar2,
  p_attribute16                  in varchar2         default hr_api.g_varchar2,
  p_attribute17                  in varchar2         default hr_api.g_varchar2,
  p_attribute18                  in varchar2         default hr_api.g_varchar2,
  p_attribute19                  in varchar2         default hr_api.g_varchar2,
  p_attribute20                  in varchar2         default hr_api.g_varchar2,
  p_multiple_components          in varchar2         default hr_api.g_varchar2,
  p_approved                     in varchar2         default hr_api.g_varchar2,
  p_inv_next_sal_date_warning    out nocopy boolean,
  p_proposed_salary_warning	 out nocopy boolean,
  p_approved_warning	         out nocopy boolean,
  p_payroll_warning	         out nocopy boolean
);
--
--
-------------------------------------------------------------------------------
-- |----------------------< delete_salary_history >---------------------------|
-------------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  Procedure to delete salary proposals and components
--  of an assignment before a given date.
--
-- Prerequisites:
--  None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_assignment_id                Yes  Number   business_group_id or null
--   p_date                         Yes  Date     organization_id or null
--
-- Post Success:
--   Deletes salary proposals and components but not element entries
--   of the assignment before a given date
--
-- Post Failure:
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
Procedure delete_salary_history( p_assignment_id      in number
                                ,p_date               in date);

--
end hr_maintain_proposal_api;

/
