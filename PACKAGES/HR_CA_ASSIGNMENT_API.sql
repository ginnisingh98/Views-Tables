--------------------------------------------------------
--  DDL for Package HR_CA_ASSIGNMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CA_ASSIGNMENT_API" AUTHID CURRENT_USER as
/* $Header: peasgcai.pkh 120.1 2005/10/02 02:10:59 aroussel $ */
/*#
 * This package contains person assignment APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Assignment for Canada
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_ca_secondary_emp_asg >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates additional non-primary assignments for an existing employee
 * in a Canadian Business Group,however this API cannot be used to create the
 * primary assignment, which gets created at the time of creating an employee.
 *
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The person (p_person_id) and the organization (p_organization_id) must exist
 * at the effective start date of the assignment (p_effective_date).
 *
 * <p><b>Post Success</b><br>
 * The secondary assignments will have been successfully inserted into the
 * database.
 *
 * <p><b>Post Failure</b><br>
 * The secondary assignments will not get created and an error will be raised.
 * @param p_validate If true,the database remains unchanged.If false a valid
 * assignment is created in the database.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force
 * @param p_person_id Identifies the person for whom you create the secondary
 * assignment record.
 * @param p_organization_id Organization
 * @param p_grade_id Grade
 * @param p_position_id Position
 * @param p_job_id Job
 * @param p_assignment_status_type_id Assigmnent status type, the list of
 * status types come from per_assignment_status_types table .
 * @param p_payroll_id Payroll
 * @param p_location_id Location
 * @param p_supervisor_id Supervisor
 * @param p_special_ceiling_step_id Special ceiling step
 * @param p_pay_basis_id Salary basis
 * @param p_assignment_number Assignment number If an assignment number is not
 * passed in, a value is generated.
 * @param p_change_reason Change reason
 * @param p_comments Secondary Assignment Comments text
 * @param p_date_probation_end End date of probation period
 * @param p_default_code_comb_id Foreign key to GL_CODE_COMBINATIONS
 * @param p_employment_category Employment category
 * @param p_frequency Frequency for quoting working hours (eg per week)
 * @param p_internal_address_line Internal address line
 * @param p_manager_flag Indicates whether employee is a manager
 * @param p_normal_hours Normal working hours
 * @param p_perf_review_period Performance review period
 * @param p_perf_review_period_frequency Units for quoting performance review
 * period (eg months)
 * @param p_probation_period Length of probation period
 * @param p_probation_unit Units for quoting probation period (eg months)
 * @param p_sal_review_period Salary review period
 * @param p_sal_review_period_frequency Units for quoting salary review period
 * (eg months)
 * @param p_set_of_books_id Set of books (GL)
 * @param p_source_type Recruitment activity source
 * @param p_time_normal_finish Normal work finish time
 * @param p_time_normal_start Normal work start time
 * @param p_bargaining_unit_code Code for bargaining unit
 * @param p_labour_union_member_flag Indicates whether employee is a labour
 * union member
 * @param p_hourly_salaried_code Hourly or salaried pay code
 * @param p_ass_attribute_category Descriptive flexfield attribute category
 * @param p_ass_attribute1 Descriptive flexfield segment.
 * @param p_ass_attribute2 Descriptive flexfield segment.
 * @param p_ass_attribute3 Descriptive flexfield segment.
 * @param p_ass_attribute4 Descriptive flexfield segment.
 * @param p_ass_attribute5 Descriptive flexfield segment.
 * @param p_ass_attribute6 Descriptive flexfield segment.
 * @param p_ass_attribute7 Descriptive flexfield segment.
 * @param p_ass_attribute8 Descriptive flexfield segment.
 * @param p_ass_attribute9 Descriptive flexfield segment.
 * @param p_ass_attribute10 Descriptive flexfield segment.
 * @param p_ass_attribute11 Descriptive flexfield segment.
 * @param p_ass_attribute12 Descriptive flexfield segment.
 * @param p_ass_attribute13 Descriptive flexfield segment.
 * @param p_ass_attribute14 Descriptive flexfield segment.
 * @param p_ass_attribute15 Descriptive flexfield segment.
 * @param p_ass_attribute16 Descriptive flexfield segment.
 * @param p_ass_attribute17 Descriptive flexfield segment.
 * @param p_ass_attribute18 Descriptive flexfield segment.
 * @param p_ass_attribute19 Descriptive flexfield segment.
 * @param p_ass_attribute20 Descriptive flexfield segment.
 * @param p_ass_attribute21 Descriptive flexfield segment.
 * @param p_ass_attribute22 Descriptive flexfield segment.
 * @param p_ass_attribute23 Descriptive flexfield segment.
 * @param p_ass_attribute24 Descriptive flexfield segment.
 * @param p_ass_attribute25 Descriptive flexfield segment.
 * @param p_ass_attribute26 Descriptive flexfield segment.
 * @param p_ass_attribute27 Descriptive flexfield segment.
 * @param p_ass_attribute28 Descriptive flexfield segment.
 * @param p_ass_attribute29 Descriptive flexfield segment.
 * @param p_ass_attribute30 Descriptive flexfield segment.
 * @param p_title Obsolete parameter, do not use.
 * @param p_tax_unit Tax Unit
 * @param p_timecard_approver Timecard approver
 * @param p_timecard_required Timecard required
 * @param p_work_schedule Work Schedule
 * @param p_shift Shift
 * @param p_naic_override_code NAIC override code
 * @param p_seasonal_worker Seasonal worker
 * @param p_officer_code Officer code
 * @param p_wci_account_number WCI account number
 * @param p_wci_code_override WCI code override
 * @param p_ca_concat_segments Concat segments for Canada
 * @param p_pgp_segment1 People group segment
 * @param p_pgp_segment2 People group segment
 * @param p_pgp_segment3 People group segment
 * @param p_pgp_segment4 People group segment
 * @param p_pgp_segment5 People group segment
 * @param p_pgp_segment6 People group segment
 * @param p_pgp_segment7 People group segment
 * @param p_pgp_segment8 People group segment
 * @param p_pgp_segment9 People group segment
 * @param p_pgp_segment10 People group segment
 * @param p_pgp_segment11 People group segment
 * @param p_pgp_segment12 People group segment
 * @param p_pgp_segment13 People group segment
 * @param p_pgp_segment14 People group segment
 * @param p_pgp_segment15 People group segment
 * @param p_pgp_segment16 People group segment
 * @param p_pgp_segment17 People group segment
 * @param p_pgp_segment18 People group segment
 * @param p_pgp_segment19 People group segment
 * @param p_pgp_segment20 People group segment
 * @param p_pgp_segment21 People group segment
 * @param p_pgp_segment22 People group segment
 * @param p_pgp_segment23 People group segment
 * @param p_pgp_segment24 People group segment
 * @param p_pgp_segment25 People group segment
 * @param p_pgp_segment26 People group segment
 * @param p_pgp_segment27 People group segment
 * @param p_pgp_segment28 People group segment
 * @param p_pgp_segment29 People group segment
 * @param p_pgp_segment30 People group segment
 * @param p_pgp_concat_segments People group concat segments
 * @param p_contract_id Contract
 * @param p_establishment_id Establishment
 * @param p_collective_agreement_id Collective Agreement
 * @param p_cagr_id_flex_num Collective Agreement grade structure
 * @param p_cag_segment1 Collective agreement grade
 * @param p_cag_segment2 Collective agreement grade
 * @param p_cag_segment3 Collective agreement grade
 * @param p_cag_segment4 Collective agreement grade
 * @param p_cag_segment5 Collective agreement grade
 * @param p_cag_segment6 Collective agreement grade
 * @param p_cag_segment7 Collective agreement grade
 * @param p_cag_segment8 Collective agreement grade
 * @param p_cag_segment9 Collective agreement grade
 * @param p_cag_segment10 Collective agreement grade
 * @param p_cag_segment11 Collective agreement grade
 * @param p_cag_segment12 Collective agreement grade
 * @param p_cag_segment13 Collective agreement grade
 * @param p_cag_segment14 Collective agreement grade
 * @param p_cag_segment15 Collective agreement grade
 * @param p_cag_segment16 Collective agreement grade
 * @param p_cag_segment17 Collective agreement grade
 * @param p_cag_segment18 Collective agreement grade
 * @param p_cag_segment19 Collective agreement grade
 * @param p_cag_segment20 Collective agreement grade
 * @param p_cagr_grade_def_id Set to the ID value of the grade if cag_segments
 * and a cagr_id_flex_num are available
 * @param p_cagr_concatenated_segments If p_validate is false and any p_segment
 * parameters have set text, set to the concatenation of all p_segment
 * parameters with set text. If p_validate is true, or no p_segment parameters
 * have set text, this will be null.
 * @param p_assignment_id If p_validate is false, then this uniquely identifies
 * the created secondary assignment ID. If p_validate is true, then set to
 * null.
 * @param p_soft_coding_keyflex_id Soft coding combination ID
 * @param p_people_group_id People Group combination ID
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created secondary assignment ID. If p_validate is
 * true, then the value will be null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created secondary assignment ID. If
 * p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created secondary assignment ID. If p_validate is
 * true, then set to null.
 * @param p_assignment_sequence If p_validate is false this will be set to the
 * sequence number of the primary assignment. If p_validate is true this will
 * be null.
 * @param p_comment_id If p_validate is false and comment text was provided,
 * then will be set to the identifier of the created employee assignment
 * comment record. If p_validate is true or no comment text was provided, then
 * will be null.
 * @param p_concatenated_segments Soft Coding combination name
 * @param p_group_name People Group name
 * @param p_other_manager_warning Set to true if manager_flag is 'Y' and a
 * manager already exists in the organization as on the effective date.
 * @rep:displayname Create Secondary Employee Assignment for Canada
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE_ASG
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_ca_secondary_emp_asg
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
  ,p_naic_override_code           in     varchar2 default null
  ,p_seasonal_worker              in     varchar2 default null
  ,p_officer_code                 in     varchar2 default null
  ,p_wci_account_number           in     varchar2 default null
  ,p_wci_code_override            in     varchar2 default null
  ,p_ca_concat_segments           in     varchar2 default null
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
  ,p_pgp_concat_segments          in     varchar2 default null
  ,p_contract_id                  in     number   default null
  ,p_establishment_id             in     number   default null
  ,p_collective_agreement_id      in     number   default null
  ,p_cagr_id_flex_num             in     number   default null
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
  ,p_cagr_grade_def_id               out nocopy number
  ,p_cagr_concatenated_segments      out nocopy varchar2
  ,p_assignment_id                   out nocopy number
  ,p_soft_coding_keyflex_id          out nocopy number
  ,p_people_group_id                 out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_assignment_sequence             out nocopy number
  ,p_comment_id                      out nocopy number
  ,p_concatenated_segments           out nocopy varchar2
  ,p_group_name                      out nocopy varchar2
  ,p_other_manager_warning           out nocopy boolean
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_ca_emp_asg >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This package contains person assignment APIs.
 *
 * This API updates information for an existing employee assignment with
 * Canadian legislation by calling the generic API update_emp_asg, with
 * parameters set as appropriate for a Canadian employee assignment.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The assignment (p_assignment_id) must exist as of the effective date of the
 * update (p_effective_date).
 *
 * <p><b>Post Success</b><br>
 * Updates The Assignment
 *
 * <p><b>Post Failure</b><br>
 * The Assignment will not get updated and an error will be raised.
 * @param p_validate If true ,the database remains unchanged.if false a valid
 * assignment is created in the database.
 * @param p_effective_date The effective start date of this assignment.
 * @param p_datetrack_update_mode Indicates which DateTrack mode to use when
 * updating the record. You must set to either UPDATE, CORRECTION,
 * UPDATE_OVERRIDE or UPDATE_CHANGE_INSERT. Modes available for use with a
 * particular record depend on the dates of previous record changes and the
 * effective date of this change.
 * @param p_assignment_id Unique ID for the assignment created by the API.
 * @param p_object_version_number Pass in the current version number of the
 * assignment to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated assignment. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_supervisor_id Supervisor
 * @param p_assignment_number Assignment number
 * @param p_change_reason Reason for the change
 * @param p_comments Secondary Assignment Comment text.
 * @param p_date_probation_end End date of probation period
 * @param p_default_code_comb_id Foreign key to GL_CODE_COMBINATIONS
 * @param p_frequency Frequency for quoting working hours (eg per week)
 * @param p_internal_address_line Internal address line
 * @param p_manager_flag Indicates whether the employee is a manager
 * @param p_normal_hours Normal working hours
 * @param p_perf_review_period Performance review period
 * @param p_perf_review_period_frequency Units for quoting performance review
 * period (eg months)
 * @param p_probation_period Length of probation period
 * @param p_probation_unit Units for quoting probation period (eg months)
 * @param p_sal_review_period Salary review period
 * @param p_sal_review_period_frequency Units for quoting salary review period
 * (eg months)
 * @param p_set_of_books_id Set of books (GL)
 * @param p_source_type Recruitment activity source
 * @param p_time_normal_finish Normal work finish time
 * @param p_time_normal_start Normal work start time
 * @param p_bargaining_unit_code Code for bargaining unit
 * @param p_labour_union_member_flag Indicates whether employee is a labour
 * union member
 * @param p_hourly_salaried_code Hourly or salaried pay code
 * @param p_ass_attribute_category Descriptive flexfield attribute category
 * @param p_ass_attribute1 Descriptive flexfield segment.
 * @param p_ass_attribute2 Descriptive flexfield segment.
 * @param p_ass_attribute3 Descriptive flexfield segment.
 * @param p_ass_attribute4 Descriptive flexfield segment.
 * @param p_ass_attribute5 Descriptive flexfield segment.
 * @param p_ass_attribute6 Descriptive flexfield segment.
 * @param p_ass_attribute7 Descriptive flexfield segment.
 * @param p_ass_attribute8 Descriptive flexfield segment.
 * @param p_ass_attribute9 Descriptive flexfield segment.
 * @param p_ass_attribute10 Descriptive flexfield segment.
 * @param p_ass_attribute11 Descriptive flexfield segment.
 * @param p_ass_attribute12 Descriptive flexfield segment.
 * @param p_ass_attribute13 Descriptive flexfield segment.
 * @param p_ass_attribute14 Descriptive flexfield segment.
 * @param p_ass_attribute15 Descriptive flexfield segment.
 * @param p_ass_attribute16 Descriptive flexfield segment.
 * @param p_ass_attribute17 Descriptive flexfield segment.
 * @param p_ass_attribute18 Descriptive flexfield segment.
 * @param p_ass_attribute19 Descriptive flexfield segment.
 * @param p_ass_attribute20 Descriptive flexfield segment.
 * @param p_ass_attribute21 Descriptive flexfield segment.
 * @param p_ass_attribute22 Descriptive flexfield segment.
 * @param p_ass_attribute23 Descriptive flexfield segment.
 * @param p_ass_attribute24 Descriptive flexfield segment.
 * @param p_ass_attribute25 Descriptive flexfield segment.
 * @param p_ass_attribute26 Descriptive flexfield segment.
 * @param p_ass_attribute27 Descriptive flexfield segment.
 * @param p_ass_attribute28 Descriptive flexfield segment.
 * @param p_ass_attribute29 Descriptive flexfield segment.
 * @param p_ass_attribute30 Descriptive flexfield segment.
 * @param p_title Obsolete parameter, do not use.
 * @param p_tax_unit Tax Unit
 * @param p_timecard_approver Timecard approver
 * @param p_timecard_required Timecard required
 * @param p_work_schedule Work Schedule
 * @param p_shift Shift
 * @param p_naic_override_code NAIC override code
 * @param p_seasonal_worker Seasonal worker
 * @param p_officer_code Officer code
 * @param p_wci_account_number WCI account number
 * @param p_wci_code_override WCI code override
 * @param p_ca_concat_segments Concat segments for Canada
 * @param p_contract_id Collective Agreement
 * @param p_establishment_id Establishment ID
 * @param p_collective_agreement_id Collective Agreement ID
 * @param p_cagr_id_flex_num Collective Agreement grade structure
 * @param p_cag_segment1 Collective agreement grade
 * @param p_cag_segment2 Collective agreement grade
 * @param p_cag_segment3 Collective agreement grade
 * @param p_cag_segment4 Collective agreement grade
 * @param p_cag_segment5 Collective agreement grade
 * @param p_cag_segment6 Collective agreement grade
 * @param p_cag_segment7 Collective agreement grade
 * @param p_cag_segment8 Collective agreement grade
 * @param p_cag_segment9 Collective agreement grade
 * @param p_cag_segment10 Collective agreement grade
 * @param p_cag_segment11 Collective agreement grade
 * @param p_cag_segment12 Collective agreement grade
 * @param p_cag_segment13 Collective agreement grade
 * @param p_cag_segment14 Collective agreement grade
 * @param p_cag_segment15 Collective agreement grade
 * @param p_cag_segment16 Collective agreement grade
 * @param p_cag_segment17 Collective agreement grade
 * @param p_cag_segment18 Collective agreement grade
 * @param p_cag_segment19 Collective agreement grade
 * @param p_cag_segment20 Collective agreement grade
 * @param p_cagr_grade_def_id Set to the ID value of the grade if cag_segments
 * and a cagr_id_flex_num are available
 * @param p_cagr_concatenated_segments If p_validate is false and any p_segment
 * parameters have set text, set to the concatenation of all p_segment
 * parameters with set text. If p_validate is true, or no p_segment parameters
 * have set text, this will be null.
 * @param p_soft_coding_keyflex_id If p_validate is false and any p_segment
 * parameters have set text, set to the id of the corresponding soft coding
 * keyflex row. If p_validate is true, or no p_segment parameters have set
 * text, this will be null.
 * @param p_comment_id If p_validate is false and new or existing comment text
 * exists, then will be set to the identifier of the employee's secondary
 * assignment comment record. If p_validate is true or no comment text exists,
 * then will be null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated assignment row which now exists as of
 * the effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created assignment. If p_validate is true, then
 * set to null.
 * @param p_concatenated_segments If p_validate is false and any p_segment
 * parameters have set text, set to the concatenation of all p_segment
 * parameters with set text. If p_validate is true, or no p_segment parameters
 * have set text, this will be null.
 * @param p_no_managers_warning Set to true if manager_flag is updated from 'Y'
 * to 'N' and no other manager exists in
 * @param p_other_manager_warning Set to true if manager flag is changed from
 * 'N' to 'Y' and a manager already exist in the
 * organization(p_organization_id) at p_effective_date. Set to false if no
 * other managers exist in p_organization.This is always set to false if
 * manager_flag is not updated.
 * @rep:displayname Update Secondary Employee Assignment for Canada
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE_ASG
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_ca_emp_asg
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_supervisor_id                in     number   default hr_api.g_number
  ,p_assignment_number            in out nocopy varchar2
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
  ,p_naic_override_code           in     varchar2 default hr_api.g_varchar2
  ,p_seasonal_worker              in     varchar2 default hr_api.g_varchar2
  ,p_officer_code                 in     varchar2 default hr_api.g_varchar2
  ,p_wci_account_number           in     varchar2 default hr_api.g_varchar2
  ,p_wci_code_override            in     varchar2 default hr_api.g_varchar2
  ,p_ca_concat_segments           in     varchar2 default hr_api.g_varchar2
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
  ,p_cagr_grade_def_id               out nocopy number
  ,p_cagr_concatenated_segments      out nocopy varchar2
  ,p_soft_coding_keyflex_id          out nocopy number
  ,p_comment_id                      out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_concatenated_segments           out nocopy varchar2
  ,p_no_managers_warning             out nocopy boolean
  ,p_other_manager_warning           out nocopy boolean
  );
--
end hr_ca_assignment_api;

 

/
