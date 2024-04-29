--------------------------------------------------------
--  DDL for Package HR_UPLOAD_PROPOSAL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_UPLOAD_PROPOSAL_API" AUTHID CURRENT_USER as
/* $Header: hrpypapi.pkh 120.11.12010000.3 2008/12/05 14:33:06 vkodedal ship $ */
/*#
 * This package contains APIs to create and maintain salary proposals.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Upload Proposal API
*/
--
-- ----------------------------------------------------------------------------
-- |--------------------------< upload_salary_proposal >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates or updates a salary proposal record in the table
 * PER_PAY_PROPOSALS.
 *
 * This API inserts, updates, or deletes salary proposal records in the table
 * PER_PAY_PROPOSAL_ COMPONENTS, depending on the values of the input
 * parameters. The API allows the user to insert up to ten components for a
 * salary proposal. If a salary proposal has more than ten components, then the
 * process calculates PROPOSED_SALARY by summing the first ten components plus
 * any_others, and places the result in the table per_pay_proposals. With the
 * first salary proposal the API creates, the process sets the approved flag in
 * the table PER_PAY_PROPOSALS to 'Y'. With the first salary proposal the
 * process creates, or when you have set none of the components attributes, the
 * process sets the MULTIPLE_COMPONENTS flag of the called API
 * insert_salary_proposal to 'N'. Otherwise it sets the MULTIPLE_COMPONENTS
 * flag to 'Y'. Note: The CHANGE_AMOUNT and CHANGE_PERCENTAGE fields in the
 * table PER_PAY_PROPOSAL_COMPONENTS are interrelated. If you provide the value
 * of one of these attributes, then the the process calculates the value of the
 * other. If If you provide the value of both attributes, then the process
 * recalculates the value of CHANGE_PERCENTAGE based on the value of
 * CHANGE_AMOUNT. If existing values for CHANGE_PERCENTAGE and CHANGE_AMOUNT
 * become null, then the api deletes the existing record.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The Assignment must exist on the change date of the proposal.
 *
 * <p><b>Post Success</b><br>
 * The process updates the existing salary proposal record when the
 * p_pay_proposal_id and p_object_version_number parameters passed in are not
 * null, and one of the attributes has changed; otherwise the process creates a
 * new salary proposal (if p_change_date is not null). The process creates a
 * new component record when the p_component_id and p_ppc_object_version_number
 * parameters passed in are null, and the p_change_amount or
 * p_change_percentage parameters for that component is not null. The process
 * updates a component record if the p_component_id and p_ppc_object_
 * version_numbers are not null, and the p_component_reason or p_change _amount
 * or p_change_percentage has changed.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the proposal,or components and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_change_date Effective start date of the salary proposal.
 * @param p_business_group_id Employee's business_group_id
 * @param p_assignment_id Uniquely identifies the assignment for which the
 * salary proposal is created.
 * @param p_proposed_salary The proposed salary.
 * @param p_proposal_reason The proposal reason. Valid values are defined by
 * lookup type 'PROPOSAL_REASON'.
 * @param p_next_sal_review_date Next salary review date.
 * @param p_forced_ranking The person's ranking
 * @param p_date_to The end date of salary proposal.
 * @param p_pay_proposal_id Identifies the salary proposal to be updated (not
 * required for creating a new salary proposal). If this API is called to
 * create a new salary proposal, this uniquely identifies the newly created
 * salary proposal.
 * @param p_object_version_number Pass in the current version number of the
 * salary proposal to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated proposal. If
 * p_validate is true will be set to the same value which was passed in. If
 * p_pay_proposal_id is null and p_validate is false, then set to the version
 * number of the newly created salary proposal and if p_validate is true, then
 * the value will be null.
 * @param p_component_reason_1 The component reason for the first component.
 * Valid values are defined by lookup type 'PROPOSAL_REASON'.
 * @param p_change_amount_1 The salary change amount for the first component.
 * @param p_change_percentage_1 The salary change percentage for the first
 * component.
 * @param p_approved_1 The approved flag for the component. It is set to 'Y' if
 * the component is approved and 'N' otherwise.
 * @param p_component_id_1 Identifies the first component. This is required
 * when updating and not required on insert.
 * @param p_ppc_object_version_number_1 Pass in the current version number of
 * the first component to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated component. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_component_reason_2 The component reason for the second component.
 * Valid values are defined by lookup type 'PROPOSAL_REASON'.
 * @param p_change_amount_2 The salary change amount for the second component.
 * @param p_change_percentage_2 The salary change percentage for the second
 * component.
 * @param p_approved_2 The approved flag for the component. It is set to 'Y' if
 * the component is approved and 'N' otherwise.
 * @param p_component_id_2 Identifies the second component. This is required
 * when updating and not required on insert.
 * @param p_ppc_object_version_number_2 Pass in the current version number of
 * the second component to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated second
 * component. If p_validate is true will be set to the same value which was
 * passed in.
 * @param p_component_reason_3 The component reason for the third component.
 * Valid values are defined by lookup type 'PROPOSAL_REASON'.
 * @param p_change_amount_3 The salary change amount for the third component.
 * @param p_change_percentage_3 The salary change percentage for the third
 * component.
 * @param p_approved_3 The approved flag for the component. It is set to 'Y' if
 * the component is approved and 'N' otherwise.
 * @param p_component_id_3 Identifies the third component. This is required
 * when updating and not required on insert.
 * @param p_ppc_object_version_number_3 Pass in the current version number of
 * the third component to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated third component.
 * If p_validate is true will be set to the same value which was passed in.
 * @param p_component_reason_4 The component reason for the 4th component.
 * Valid values are defined by lookup type 'PROPOSAL_REASON'.
 * @param p_change_amount_4 The salary change amount for the 4th component.
 * @param p_change_percentage_4 The salary change percentage for the 4th
 * component.
 * @param p_approved_4 The approved flag for the component. It is set to 'Y' if
 * the component is approved and 'N' otherwise.
 * @param p_component_id_4 Identifies the 4th component. This is required when
 * updating and not required on insert.
 * @param p_ppc_object_version_number_4 Pass in the current version number of
 * the 4th component to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated 4th component.
 * If p_validate is true will be set to the same value which was passed in.
 * @param p_component_reason_5 The component reason for the 5th component.
 * Valid values are defined by lookup type 'PROPOSAL_REASON'.
 * @param p_change_amount_5 The salary change amount for the 5th component.
 * @param p_change_percentage_5 The salary change percentage for the 5th
 * component.
 * @param p_approved_5 The approved flag for the component. It is set to 'Y' if
 * the component is approved and 'N' otherwise.
 * @param p_component_id_5 Identifies the 5th component. This is required when
 * updating and not required on insert.
 * @param p_ppc_object_version_number_5 Pass in the current version number of
 * the 5th component to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated 5th component.
 * If p_validate is true will be set to the same value which was passed in.
 * @param p_component_reason_6 The component reason for the 6th component.
 * Valid values are defined by lookup type 'PROPOSAL_REASON'.
 * @param p_change_amount_6 The salary change amount for the 6th component.
 * @param p_change_percentage_6 The salary change percentage for the 6th
 * component.
 * @param p_approved_6 The approved flag for the 6th component. It is set to
 * 'Y' if the component is approved and 'N' otherwise.
 * @param p_component_id_6 Identifies the 6th component. This is required when
 * updating and not required on insert.
 * @param p_ppc_object_version_number_6 Pass in the current version number of
 * the 6th component to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated 6th component.
 * If p_validate is true will be set to the same value which was passed in.
 * @param p_component_reason_7 The component reason for the 7th component.
 * Valid values are defined by lookup type 'PROPOSAL_REASON'.
 * @param p_change_amount_7 The salary change amount for the 7th component.
 * @param p_change_percentage_7 The salary change percentage for the 7th
 * component.
 * @param p_approved_7 The approved flag for the component. It is set to 'Y' if
 * the component is approved and 'N' otherwise.
 * @param p_component_id_7 Identifies the 7th component. This is required when
 * updating and not required on insert.
 * @param p_ppc_object_version_number_7 Pass in the current version number of
 * the 7th component to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated 7th component.
 * If p_validate is true will be set to the same value which was passed in.
 * @param p_component_reason_8 The component reason for the 8th component.
 * Valid values are defined by lookup type 'PROPOSAL_REASON'.
 * @param p_change_amount_8 The salary change amount for the 8th component.
 * @param p_change_percentage_8 The salary change percentage for the 8th
 * component.
 * @param p_approved_8 The approved flag for the component. It is set to 'Y' if
 * the component is approved and 'N' otherwise.
 * @param p_component_id_8 Identifies the 8th component. This is required when
 * updating and not required on insert.
 * @param p_ppc_object_version_number_8 Pass in the current version number of
 * the 8th component to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated 8th component.
 * If p_validate is true will be set to the same value which was passed in.
 * @param p_component_reason_9 The component reason for the 9th component.
 * Valid values are defined by lookup type 'PROPOSAL_REASON'.
 * @param p_change_amount_9 The salary change amount for the 9th component.
 * @param p_change_percentage_9 The salary change percentage for the 9th
 * component.
 * @param p_approved_9 The approved flag for the component. It is set to 'Y' if
 * the component is approved and 'N' otherwise.
 * @param p_component_id_9 Identifies the 9th component. This is required when
 * updating and not required on insert.
 * @param p_ppc_object_version_number_9 Pass in the current version number of
 * the 9th component to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated 9th component.
 * If p_validate is true will be set to the same value which was passed in.
 * @param p_component_reason_10 The component reason for the 10th component.
 * Valid values are defined by lookup type 'PROPOSAL_REASON'.
 * @param p_change_amount_10 The salary change amount for the 10th component.
 * @param p_change_percentage_10 The salary change percentage for the 10th
 * component.
 * @param p_approved_10 The approved flag for the component. It is set to 'Y'
 * if the component is approved and 'N' otherwise.
 * @param p_component_id_10 Identifies the 10th component. This is required
 * when updating and not required on insert.
 * @param p_ppc_object_version_number_10 Pass in the current version number of
 * the 10th component to be updated. When the API completes if p_validate is
 * false, will be set to the new version number of the updated 10th component.
 * If p_validate is true will be set to the same value which was passed in.
 * @param p_pyp_proposed_sal_warning If set to true, the proposed salary is not
 * within the range determined by the assignment's grade rate.
 * @param p_additional_comp_warning If set to true, the proposed salary has
 * more than ten components.
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
 * @rep:displayname Upload Salary Proposal
 * @rep:category BUSINESS_ENTITY PER_SALARY_PROPOSAL
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:category MISC_EXTENSIONS HR_USER_HOOKS
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure upload_salary_proposal
  (p_validate                      in     boolean  default false
  ,p_change_date                   in     date
  ,p_business_group_id             in     number
  ,p_assignment_id		   in     number
  ,p_proposed_salary               in     number   default null
  ,p_proposal_reason		   in     varchar2 default null
  ,p_next_sal_review_date          in     date     default hr_api.g_date
						-- Bug 1620922
  ,p_forced_ranking                in     number   default null
  ,p_date_to			   in     date     default null
  ,p_pay_proposal_id               in out nocopy number
  ,p_object_version_number         in out nocopy number
  --
  ,p_component_reason_1		   in     varchar2
  ,p_change_amount_1		   in     number   default null
  ,p_change_percentage_1	   in     number   default null
  ,p_approved_1			   in 	  varchar2
  ,p_component_id_1		   in out nocopy number
  ,p_ppc_object_version_number_1   in out nocopy number
  --
  ,p_component_reason_2		   in     varchar2
  ,p_change_amount_2		   in     number   default null
  ,p_change_percentage_2	   in     number   default null
  ,p_approved_2			   in 	  varchar2
  ,p_component_id_2		   in out nocopy number
  ,p_ppc_object_version_number_2   in out nocopy number
  --
  ,p_component_reason_3		   in     varchar2
  ,p_change_amount_3		   in     number   default null
  ,p_change_percentage_3	   in     number   default null
  ,p_approved_3			   in 	  varchar2
  ,p_component_id_3		   in out nocopy number
  ,p_ppc_object_version_number_3   in out nocopy number
  --
  ,p_component_reason_4		   in     varchar2
  ,p_change_amount_4		   in     number   default null
  ,p_change_percentage_4	   in     number   default null
  ,p_approved_4			   in 	  varchar2
  ,p_component_id_4		   in out nocopy number
  ,p_ppc_object_version_number_4   in out nocopy number
  --
  ,p_component_reason_5		   in     varchar2
  ,p_change_amount_5		   in     number   default null
  ,p_change_percentage_5	   in     number   default null
  ,p_approved_5			   in 	  varchar2
  ,p_component_id_5		   in out nocopy number
  ,p_ppc_object_version_number_5   in out nocopy number
  --
  ,p_component_reason_6		   in     varchar2
  ,p_change_amount_6		   in     number   default null
  ,p_change_percentage_6	   in     number   default null
  ,p_approved_6			   in 	  varchar2
  ,p_component_id_6		   in out nocopy number
  ,p_ppc_object_version_number_6   in out nocopy number
  --
  ,p_component_reason_7		   in     varchar2
  ,p_change_amount_7		   in     number   default null
  ,p_change_percentage_7	   in     number   default null
  ,p_approved_7			   in 	  varchar2
  ,p_component_id_7		   in out nocopy number
  ,p_ppc_object_version_number_7   in out nocopy number
  --
  ,p_component_reason_8		   in     varchar2
  ,p_change_amount_8		   in     number   default null
  ,p_change_percentage_8	   in     number   default null
  ,p_approved_8			   in 	  varchar2
  ,p_component_id_8		   in out nocopy number
  ,p_ppc_object_version_number_8   in out nocopy number
  --
  ,p_component_reason_9		   in     varchar2
  ,p_change_amount_9		   in     number   default null
  ,p_change_percentage_9	   in     number   default null
  ,p_approved_9			   in 	  varchar2
  ,p_component_id_9		   in out nocopy number
  ,p_ppc_object_version_number_9   in out nocopy number
  --
  ,p_component_reason_10	   in     varchar2
  ,p_change_amount_10		   in     number   default null
  ,p_change_percentage_10	   in     number   default null
  ,p_approved_10		   in 	  varchar2
  ,p_component_id_10		   in out nocopy number
  ,p_ppc_object_version_number_10  in out nocopy number
  --
  ,p_pyp_proposed_sal_warning      out nocopy boolean
  ,p_additional_comp_warning	   out nocopy boolean
/* Added for desc flex Web ADI Support */
  ,p_attribute_category            in varchar2   default null
  ,p_attribute1                    in varchar2   default null
  ,p_attribute2                    in varchar2   default null
  ,p_attribute3                    in varchar2   default null
  ,p_attribute4                    in varchar2   default null
  ,p_attribute5                    in varchar2   default null
  ,p_attribute6                    in varchar2   default null
  ,p_attribute7                    in varchar2   default null
  ,p_attribute8                    in varchar2   default null
  ,p_attribute9                    in varchar2   default null
  ,p_attribute10                   in varchar2   default null
  ,p_attribute11                   in varchar2   default null
  ,p_attribute12                   in varchar2   default null
  ,p_attribute13                   in varchar2   default null
  ,p_attribute14                   in varchar2   default null
  ,p_attribute15                   in varchar2   default null
  ,p_attribute16                   in varchar2   default null
  ,p_attribute17                   in varchar2   default null
  ,p_attribute18                   in varchar2   default null
  ,p_attribute19                   in varchar2   default null
  ,p_attribute20                   in varchar2   default null
  );
--
end hr_upload_proposal_api;

/
