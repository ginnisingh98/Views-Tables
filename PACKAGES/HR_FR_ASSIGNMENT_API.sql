--------------------------------------------------------
--  DDL for Package HR_FR_ASSIGNMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_FR_ASSIGNMENT_API" AUTHID CURRENT_USER as
/* $Header: peasgfri.pkh 120.2 2006/06/23 11:22:59 nmuthusa noship $ */
/*#
 * This package contains Assignment APIs for France.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Assignment for France
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_fr_secondary_emp_asg >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a new assignment for an existing employee for France.
 *
 * A secondary assignment for an existing person is created. The API calls the
 * generic API create_secondary_emp_asg, with the parameters set as appropriate
 * for the French person. As this API is an alternative to the generic
 * create_secondary_emp_asg, see create_secondary_emp_asg API for more details.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The person (p_person_id) and the organization (p_organization_id) must exist
 * at the effective start date of the assignment (p_effective_date).
 *
 * <p><b>Post Success</b><br>
 * The secondary assignment is successfully created in the database.
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
 * @param p_employee_category Employee category. Valid values exist in the
 * 'EMP_CAT' lookup type.
 * @param p_starting_reason Starting reason. Valid values exist in the
 * 'FR_STARTING_REASON' lookup type.
 * @param p_ending_reason Ending reason. Valid values exist in the
 * 'FR_ENDING_REASON' lookup type.
 * @param p_work_pattern Work pattern. Valid values exist in the
 * 'FR_WORK_PATTERN' lookup type.
 * @param p_work_pattern_start_day Work pattern start day
 * @param p_working_days_per_year Working days per year
 * @param p_detache_status Detache status. Valid values exist in the
 * 'FR_DETACHE_STATUS' lookup type.
 * @param p_address_abroad Address abroad. Valid values exist in the
 * 'FR_ADDRESS_ABROAD' lookup type.
 * @param p_border_worker Border worker. Valid values exist in the
 * 'FR_BORDER_WORKER' lookup type.
 * @param p_urssaf_code URSSAF organization code. Valid values exist in the
 * 'FR_URSSAF_CODE' lookup type.
 * @param p_professional_status Professional status. Valid values exist in the
 * 'FR_DADS_PROF_STATUS_CODE' lookup type.
 * @param p_grouping_employer Grouping employer name.
 * @param p_fr_concat_segments The concatenated segments of the SCL key
 * flexfield.
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
 * @param p_concatenated_segments If p_validate is false, set to Soft Coded Key
 * Flexfield concatenated segments, if p_validate is true, set to null.
 * @param p_group_name If p_validate is false, set to the People Group Key
 * Flexfield concatenated segments. If p_validate is true, set to null.
 * @param p_other_manager_warning If set to true, then a manager existed in the
 * organization prior to calling this API and the manager flag has been set to
 * 'Y' for yes.
 * @rep:displayname Create Secondary Employee Assignment for France
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE_ASG
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure create_fr_secondary_emp_asg
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
  ,p_employee_category            in     varchar2 default null
  ,p_starting_reason              in     varchar2 default null
  ,p_ending_reason                in     varchar2 default null
  ,p_work_pattern                 in     varchar2 default null
  ,p_work_pattern_start_day       in     number   default null
  ,p_working_days_per_year        in     number   default null
  ,p_detache_status               in     varchar2 default null
  ,p_address_abroad               in     varchar2 default null
  ,p_border_worker                in     varchar2 default null
  ,p_urssaf_code                  in     varchar2 default null
  ,p_professional_status	  in	 varchar2 default null
  ,p_grouping_employer		  in	 varchar2 default null
  ,p_fr_concat_segments           in     varchar2 default null
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
-- |----------------------------< update_fr_emp_asg >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a person's employee assignment in a business group for
 * France.
 *
 * The API calls the generic API update_emp_asg, with parameters set as
 * appropriate for a French employee assignment.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The assignment (p_assignment_id) must exist as of the effective date of the
 * update (p_effective_date).
 *
 * <p><b>Post Success</b><br>
 * The employee's assignment will be updated into the database.
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
 * Flexfield combination that applies to this assignment
 * @param p_frequency Frequency associated with the defined normal working
 * hours. Valid values are defined in the FREQUENCY lookup type.
 * @param p_internal_address_line Internal address identified with this
 * assignment.
 * @param p_labour_union_member_flag Value 'Y' indicates employee is a labour
 * union member. Other values indicate not a member.
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
 * @param p_employee_category Employee category. Valid values exist in the
 * 'EMP_CAT' lookup type.
 * @param p_starting_reason Starting reason. Valid values exist in the
 * 'FR_STARTING_REASON' lookup type.
 * @param p_ending_reason Ending reason. Valid values exist in the
 * 'FR_ENDING_REASON' lookup type.
 * @param p_work_pattern Work pattern. Valid values exist in the
 * 'FR_WORK_PATTERN' lookup type.
 * @param p_work_pattern_start_day Work pattern start day
 * @param p_working_days_per_year Working days per year
 * @param p_detache_status Detache status. Valid values exist in the
 * 'FR_DETACHE_STATUS' lookup type.
 * @param p_address_abroad Address abroad. Valid values exist in the
 * 'FR_ADDRESS_ABROAD' lookup type.
 * @param p_border_worker Border worker. Valid values exist in the
 * 'FR_BORDER_WORKER' lookup type.
 * @param p_urssaf_code URSSAF organization code. Valid values exist in the
 * 'FR_URSSAF_CODE' lookup type.
 * @param p_professional_status Professional status. Valid values exist in the
 * 'FR_DADS_PROF_STATUS_CODE' lookup type.
 * @param p_grouping_employer Grouping employer name.
 * @param p_fr_concat_segments The concatenated segments of the SCL key
 * flexfield.
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
 * @param p_cagr_grade_def_id If a value is passed in for this parameter, it
 * identifies an existing CAGR Key Flexfield combination to associate with the
 * assignment, and segment values are ignored. If a value is not passed in,
 * then the individual CAGR Key Flexfield segments supplied will be used to
 * choose an existing combination or create a new combination. When the API
 * completes, if p_validate is false, then this uniquely identifies the
 * associated combination of the CAGR Key flexfield for this assignment. If
 * p_validate is true, then set to null.
 * @param p_cagr_concatenated_segments CAGR Key Flexfield concatenated segments
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
 * @param p_concatenated_segments If p_validate is false, set to Soft Coded Key
 * Flexfield concatenated segments, if p_validate is true, set to null.
 * @param p_no_managers_warning Set to true if as a result of the update there
 * is no manager in the organization. Otherwise set to false.
 * @param p_other_manager_warning If set to true, then a manager existed in the
 * organization prior to calling this API and the manager flag has been set to
 * 'Y' for yes.
 * @rep:displayname Update Employee Assignment for France
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE_ASG
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
procedure update_fr_emp_asg
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
  ,p_labour_union_member_flag     in     varchar2 default hr_api.g_varchar2
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
  ,p_employee_category            in     varchar2 default hr_api.g_varchar2
  ,p_starting_reason              in     varchar2 default hr_api.g_varchar2
  ,p_ending_reason                in     varchar2 default hr_api.g_varchar2
  ,p_work_pattern                 in     varchar2 default hr_api.g_varchar2
  ,p_work_pattern_start_day       in     number   default hr_api.g_number
  ,p_working_days_per_year        in     number   default hr_api.g_number
  ,p_detache_status               in     varchar2 default hr_api.g_varchar2
  ,p_address_abroad               in     varchar2 default hr_api.g_varchar2
  ,p_border_worker                in     varchar2 default hr_api.g_varchar2
  ,p_urssaf_code                  in     varchar2 default hr_api.g_varchar2
  ,p_professional_status	  in	 varchar2 default hr_api.g_varchar2
  ,p_grouping_employer		  in	 varchar2 default hr_api.g_varchar2
  ,p_fr_concat_segments           in     varchar2 default hr_api.g_varchar2
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
end hr_fr_assignment_api;

 

/
