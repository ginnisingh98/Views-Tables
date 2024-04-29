--------------------------------------------------------
--  DDL for Package HR_DK_ASSIGNMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DK_ASSIGNMENT_API" AUTHID CURRENT_USER AS
/* $Header: peasgdki.pkh 120.2.12000000.2 2007/05/08 07:24:18 saurai ship $ */
/*#
 * This package contains assignment APIs for Denmark.
 * @rep:scope public
 * @rep:product PER
 * @rep:displayname Assignment for Denmark
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_dk_secondary_emp_asg >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates additional non-primary assignments for an existing employee
 * in the Denmark business group.
 *
 * This API creates additional non-primary assignments for an existing employee
 * in the Denmark business group. It calls create_secondary_emp_asg. You cannot
 * use this API to create the primary assignment. The primary assignment is
 * created when you create the employee.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The person and the organization must exist on the effective date.
 *
 * <p><b>Post Success</b><br>
 * A new secondary assignment is successfully created for the employee in the
 * database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the assignment and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_person_id Identifies the person for whom you create the secondary
 * assignment record.
 * @param p_organization_id Identifies the organization of the secondary
 * assignment.
 * @param p_grade_id Identifies the grade of the secondary assignment.
 * @param p_position_id Identifies the position of the secondary assignment.
 * @param p_job_id Identifies the job of the secondary assignment.
 * @param p_assignment_status_type_id Identifies the assignment status of the
 * secondary assignment. Valid values are defined by the 'PER_ASS_SYS_STATUS'
 * lookup type.
 * @param p_payroll_id Identifies the payroll for the secondary assignment.
 * @param p_location_id Identifies the location of the secondary assignment.
 * @param p_supervisor_id Identifies the supervisor for the secondary
 * assignment. The value refers to the supervisor's person record.
 * @param p_special_ceiling_step_id Highest allowed step for the grade scale
 * associated with the grade of the secondary assignment.
 * @param p_pay_basis_id Salary basis for the secondary assignment.
 * @param p_assignment_number If a value is passed in, this is used as the
 * assignment number. If no value is passed in, an assignment number is
 * generated.
 * @param p_change_reason Reason for the assignment status change. If there is
 * no change reason the parameter can be null. Valid values are defined in the
 * 'EMP_ASSIGN_REASON' lookup type.
 * @param p_comments Comment text.
 * @param p_date_probation_end End date of probation period.
 * @param p_default_code_comb_id Identifier for the General Ledger Accounting
 * flexfield combination that applies to this assignment.
 * @param p_employment_category Employment category of the assignment. Valid
 * values are defined in the 'EMP_CAT' lookup type.
 * @param p_frequency Frequency associated with the defined normal working
 * hours. Valid values are defined in the 'FREQUENCY' lookup type.
 * @param p_internal_address_line Internal address identified with the
 * secondary assignment.
 * @param p_manager_flag Indicates whether the employee is a manager.
 * @param p_normal_hours Normal working hours for this assignment.
 * @param p_perf_review_period Length of performance review period.
 * @param p_perf_review_period_frequency Units of performance review period.
 * Valid values are defined in the 'FREQUENCY' lookup type.
 * @param p_probation_period Length of probation period
 * @param p_probation_unit Units of probation period. Valid values are defined
 * in the 'QUALIFYING_UNITS' lookup type.
 * @param p_sal_review_period Length of salary review period.
 * @param p_sal_review_period_frequency Units of salary review period. Valid
 * values are defined in the 'FREQUENCY' lookup type.
 * @param p_set_of_books_id Identifies General Ledger set of books.
 * @param p_source_type Recruitment activity which this assignment is sourced
 * from. Valid values are defined in the 'REC_TYPE' lookup type.
 * @param p_time_normal_finish Normal work finish time.
 * @param p_time_normal_start Normal work start time.
 * @param p_bargaining_unit_code Code for bargaining unit. Valid values are
 * defined in the 'BARGAINING_UNIT_CODE' lookup type.
 * @param p_labour_union_member_flag Indicates whether the employee is a labour
 * union member. A value 'Y' indicates that the employee is a labour union
 * member.
 * @param p_hourly_salaried_code Identifies if the assignment is paid hourly or
 * is salaried. Valid values are defined in the 'HOURLY_SALARIED_CODE' lookup
 * type.
 * @param p_ass_attribute_category This context value determines which
 * flexfield structure to use with the descriptive flexfield segments.
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
 * @param p_legal_entity Legal Entity of the assignment. Valid values are
 * defined in the 'HR_DK_LEGAL_ENTITY' lookup type.
 * @param p_cond_of_emp Employee Category. Valid values are defined in the
 * lookup type 'DK_COND_OF_EMP'
 * @param p_emp_group Employee type. Valid values are defined in the
 * 'DK_EMP_TYPE' lookup type
 * @param p_union_membership Union membership. Valid values are defined in the
 * 'DK_UNION_MEMBERSHIP' lookup type.
 * @param p_termination_reason Reason for terminating the assignment.
 * @param p_notified_date Notified date.
 * @param p_termination_date Termination date.
 * @param p_adjusted_seniority_date Adjusted seniority date.
 * @param p_default_work_pattern  Default Work Pattern  for Holiday Entitlement
 * Valid values are defined in the Value set 'DK_WORK_PATTERNS'
 * @param p_hourly_accrual_rate  Hourly Accrual Rate  for Holiday Entitlement
 * Valid values are defined in the Value set 'HR_DK_2_DIGIT'
 * @param p_accrual_type  Accrual Type  for Holiday Entitlement
 * Valid values are defined in the Value set 'DK_ACCRUAL_TYPES'
 * @param p_salaried_allowance_rate  Salaried Allowance Rate  for Holiday Entitlement
 * Valid values are defined in the Value set 'HR_DK_2_DIGIT'
 * @param p_job_occupation_employee_code  Job Occupation Employee Code  for DA Office codes
 * Valid values are defined in the Value set 'HR_DK_JOB_OCC_MKODE'
 * @param p_job_status_employee_code  Job Status Employee Code  for DA Office codes
 * Valid values are defined in the Value set 'HR_DK_JOB_STATUS_MKODE'
 * @param p_salary_basis_employee_code  Salary Basis Employee Code  for DA Office codes
 * Valid values are defined in the Value set 'HR_DK_SALARY_BASIS_MKODE'
 * @param p_time_off_in_lieu  Time Off in Lieu  for DA Office codes
 * Valid values are defined in the Value set 'HR_DK_YES_NO'
 * @param p_section_28_registration  Section 28 Registration  for Sick Pay Defaults
 * Valid values are defined in the Value set 'HR_DK_YES_NO'
 * @param p_pgp_segment1 People group key flexfield segment.
 * @param p_pgp_segment2 People group key flexfield segment.
 * @param p_pgp_segment3 People group key flexfield segment.
 * @param p_pgp_segment4 People group key flexfield segment.
 * @param p_pgp_segment5 People group key flexfield segment.
 * @param p_pgp_segment6 People group key flexfield segment.
 * @param p_pgp_segment7 People group key flexfield segment.
 * @param p_pgp_segment8 People group key flexfield segment.
 * @param p_pgp_segment9 People group key flexfield segment.
 * @param p_pgp_segment10 People group key flexfield segment.
 * @param p_pgp_segment11 People group key flexfield segment.
 * @param p_pgp_segment12 People group key flexfield segment.
 * @param p_pgp_segment13 People group key flexfield segment.
 * @param p_pgp_segment14 People group key flexfield segment.
 * @param p_pgp_segment15 People group key flexfield segment.
 * @param p_pgp_segment16 People group key flexfield segment.
 * @param p_pgp_segment17 People group key flexfield segment.
 * @param p_pgp_segment18 People group key flexfield segment.
 * @param p_pgp_segment19 People group key flexfield segment.
 * @param p_pgp_segment20 People group key flexfield segment.
 * @param p_pgp_segment21 People group key flexfield segment.
 * @param p_pgp_segment22 People group key flexfield segment.
 * @param p_pgp_segment23 People group key flexfield segment.
 * @param p_pgp_segment24 People group key flexfield segment.
 * @param p_pgp_segment25 People group key flexfield segment.
 * @param p_pgp_segment26 People group key flexfield segment.
 * @param p_pgp_segment27 People group key flexfield segment.
 * @param p_pgp_segment28 People group key flexfield segment.
 * @param p_pgp_segment29 People group key flexfield segment.
 * @param p_pgp_segment30 People group key flexfield segment.
 * @param p_pgp_concat_segments Concatenated segments for People Group Key
 * Flexfield. Concatenated segments can be supplied instead of individual
 * segments.
 * @param p_assignment_id If p_validate is false, then this uniquely identifies
 * the created secondary assignment. If p_validate is true, then set to null.
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
 * version number of the created secondary assignment. If p_validate is true,
 * then the value will be null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created secondary assignment. If
 * p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created secondary assignment. If p_validate is
 * true, then set to null.
 * @param p_assignment_sequence If p_validate is false, then an automatically
 * incremented number is associated with this assignment, depending on the
 * number of assignment which already exist. If p_validate is true, then set to
 * null.
 * @param p_comment_id If p_validate is false and comment text was provided,
 * then will be set to the identifier of the created secondary assignment
 * comment record. If p_validate is true or no comment text was provided, then
 * will be null.
 * @param p_concatenated_segments If p_validate is false, set to soft coded key
 * flexfield concatenated segments. If p_validate is true, set to null.
 * @param p_group_name If p_validate is false, set to the people group key
 * flexfield concatenated segments. If p_validate is true, set to null.
 * @param p_other_manager_warning If set to true, then a manager existed in the
 * organization prior to calling this API and the manager flag has been set to
 * 'Y' for yes.
 * @rep:displayname Create Secondary Employee Assignment for Denmark
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE_ASG
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE create_dk_secondary_emp_asg
  (p_validate                     IN     BOOLEAN  DEFAULT FALSE
  ,p_effective_date               IN     DATE
  ,p_person_id                    IN     NUMBER
  ,p_organization_id              IN     NUMBER
  ,p_grade_id                     IN     NUMBER   DEFAULT NULL
  ,p_position_id                  IN     NUMBER   DEFAULT NULL
  ,p_job_id                       IN     NUMBER   DEFAULT NULL
  ,p_assignment_status_type_id    IN     NUMBER   DEFAULT NULL
  ,p_payroll_id                   IN     NUMBER   DEFAULT NULL
  ,p_location_id                  IN     NUMBER   DEFAULT NULL
  ,p_supervisor_id                IN     NUMBER   DEFAULT NULL
  ,p_special_ceiling_step_id      IN     NUMBER   DEFAULT NULL
  ,p_pay_basis_id                 IN     NUMBER   DEFAULT NULL
  ,p_assignment_number            IN OUT NOCOPY VARCHAR2
  ,p_change_reason                IN     VARCHAR2 DEFAULT NULL
  ,p_comments                     IN     VARCHAR2 DEFAULT NULL
  ,p_date_probation_end           IN     DATE     DEFAULT NULL
  ,p_default_code_comb_id         IN     NUMBER   DEFAULT NULL
  ,p_employment_category          IN     VARCHAR2 DEFAULT NULL
  ,p_frequency                    IN     VARCHAR2 DEFAULT NULL
  ,p_internal_address_line        IN     VARCHAR2 DEFAULT NULL
  ,p_manager_flag                 IN     VARCHAR2 DEFAULT NULL
  ,p_normal_hours                 IN     NUMBER   DEFAULT NULL
  ,p_perf_review_period           IN     NUMBER   DEFAULT NULL
  ,p_perf_review_period_frequency IN     VARCHAR2 DEFAULT NULL
  ,p_probation_period             IN     NUMBER   DEFAULT NULL
  ,p_probation_unit               IN     VARCHAR2 DEFAULT NULL
  ,p_sal_review_period            IN     NUMBER   DEFAULT NULL
  ,p_sal_review_period_frequency  IN     VARCHAR2 DEFAULT NULL
  ,p_set_of_books_id              IN     NUMBER   DEFAULT NULL
  ,p_source_type                  IN     VARCHAR2 DEFAULT NULL
  ,p_time_normal_finish           IN     VARCHAR2 DEFAULT NULL
  ,p_time_normal_start            IN     VARCHAR2 DEFAULT NULL
  ,p_bargaining_unit_code         in     varchar2 default null
  ,p_labour_union_member_flag     in     varchar2 default 'N'
  ,p_hourly_salaried_code         in     varchar2 default null
  ,p_ass_attribute_category       IN     VARCHAR2 DEFAULT NULL
  ,p_ass_attribute1               IN     VARCHAR2 DEFAULT NULL
  ,p_ass_attribute2               IN     VARCHAR2 DEFAULT NULL
  ,p_ass_attribute3               IN     VARCHAR2 DEFAULT NULL
  ,p_ass_attribute4               IN     VARCHAR2 DEFAULT NULL
  ,p_ass_attribute5               IN     VARCHAR2 DEFAULT NULL
  ,p_ass_attribute6               IN     VARCHAR2 DEFAULT NULL
  ,p_ass_attribute7               IN     VARCHAR2 DEFAULT NULL
  ,p_ass_attribute8               IN     VARCHAR2 DEFAULT NULL
  ,p_ass_attribute9               IN     VARCHAR2 DEFAULT NULL
  ,p_ass_attribute10              IN     VARCHAR2 DEFAULT NULL
  ,p_ass_attribute11              IN     VARCHAR2 DEFAULT NULL
  ,p_ass_attribute12              IN     VARCHAR2 DEFAULT NULL
  ,p_ass_attribute13              IN     VARCHAR2 DEFAULT NULL
  ,p_ass_attribute14              IN     VARCHAR2 DEFAULT NULL
  ,p_ass_attribute15              IN     VARCHAR2 DEFAULT NULL
  ,p_ass_attribute16              IN     VARCHAR2 DEFAULT NULL
  ,p_ass_attribute17              IN     VARCHAR2 DEFAULT NULL
  ,p_ass_attribute18              IN     VARCHAR2 DEFAULT NULL
  ,p_ass_attribute19              IN     VARCHAR2 DEFAULT NULL
  ,p_ass_attribute20              IN     VARCHAR2 DEFAULT NULL
  ,p_ass_attribute21              IN     VARCHAR2 DEFAULT NULL
  ,p_ass_attribute22              IN     VARCHAR2 DEFAULT NULL
  ,p_ass_attribute23              IN     VARCHAR2 DEFAULT NULL
  ,p_ass_attribute24              IN     VARCHAR2 DEFAULT NULL
  ,p_ass_attribute25              IN     VARCHAR2 DEFAULT NULL
  ,p_ass_attribute26              IN     VARCHAR2 DEFAULT NULL
  ,p_ass_attribute27              IN     VARCHAR2 DEFAULT NULL
  ,p_ass_attribute28              IN     VARCHAR2 DEFAULT NULL
  ,p_ass_attribute29              IN     VARCHAR2 DEFAULT NULL
  ,p_ass_attribute30              IN     VARCHAR2 DEFAULT NULL
  ,p_title                        IN     VARCHAR2 DEFAULT NULL
  ,p_legal_entity	   	  IN     VARCHAR2 DEFAULT NULL
  --,p_pension_provider	          IN     VARCHAR2 DEFAULT NULL  Removed from assignment level and it's captured at Element entry level
  ,p_cond_of_emp	          IN     VARCHAR2 DEFAULT NULL -- Condition of Employment
  ,p_emp_group		          IN     VARCHAR2 DEFAULT NULL -- Employee Group
  ,p_union_membership	          IN     VARCHAR2 DEFAULT NULL -- Union Membership
  ,p_termination_reason		  IN	 VARCHAR2 DEFAULT NULL
  ,p_notified_date		  IN	 DATE	  DEFAULT NULL
  ,p_termination_date		  IN	 DATE	  DEFAULT NULL
  ,p_adjusted_seniority_date	  IN	 DATE	  DEFAULT NULL
  ,p_default_work_pattern	  IN     VARCHAR2 DEFAULT NULL	-- Holiday Entitlement
  ,p_hourly_accrual_rate	  IN     NUMBER   DEFAULT NULL	-- Holiday Entitlement
  ,p_accrual_type		  IN     VARCHAR2 DEFAULT NULL	-- Holiday Entitlement
  ,p_salaried_allowance_rate	  IN     NUMBER   DEFAULT NULL	-- Holiday Entitlement
  ,p_job_occupation_employee_code IN     VARCHAR2 DEFAULT NULL	-- DA Office codes
  ,p_job_status_employee_code	  IN     VARCHAR2 DEFAULT NULL	-- DA Office codes
  ,p_salary_basis_employee_code	  IN     VARCHAR2 DEFAULT NULL	-- DA Office codes
  ,p_time_off_in_lieu		  IN     VARCHAR2 DEFAULT NULL	-- DA Office codes
  ,p_section_28_registration	  IN     VARCHAR2 DEFAULT NULL	-- Sick Pay Defaults
  ,p_pgp_segment1                 IN     VARCHAR2 DEFAULT NULL
  ,p_pgp_segment2                 IN     VARCHAR2 DEFAULT NULL
  ,p_pgp_segment3                 IN     VARCHAR2 DEFAULT NULL
  ,p_pgp_segment4                 IN     VARCHAR2 DEFAULT NULL
  ,p_pgp_segment5                 IN     VARCHAR2 DEFAULT NULL
  ,p_pgp_segment6                 IN     VARCHAR2 DEFAULT NULL
  ,p_pgp_segment7                 IN     VARCHAR2 DEFAULT NULL
  ,p_pgp_segment8                 IN     VARCHAR2 DEFAULT NULL
  ,p_pgp_segment9                 IN     VARCHAR2 DEFAULT NULL
  ,p_pgp_segment10                IN     VARCHAR2 DEFAULT NULL
  ,p_pgp_segment11                IN     VARCHAR2 DEFAULT NULL
  ,p_pgp_segment12                IN     VARCHAR2 DEFAULT NULL
  ,p_pgp_segment13                IN     VARCHAR2 DEFAULT NULL
  ,p_pgp_segment14                IN     VARCHAR2 DEFAULT NULL
  ,p_pgp_segment15                IN     VARCHAR2 DEFAULT NULL
  ,p_pgp_segment16                IN     VARCHAR2 DEFAULT NULL
  ,p_pgp_segment17                IN     VARCHAR2 DEFAULT NULL
  ,p_pgp_segment18                IN     VARCHAR2 DEFAULT NULL
  ,p_pgp_segment19                IN     VARCHAR2 DEFAULT NULL
  ,p_pgp_segment20                IN     VARCHAR2 DEFAULT NULL
  ,p_pgp_segment21                IN     VARCHAR2 DEFAULT NULL
  ,p_pgp_segment22                IN     VARCHAR2 DEFAULT NULL
  ,p_pgp_segment23                IN     VARCHAR2 DEFAULT NULL
  ,p_pgp_segment24                IN     VARCHAR2 DEFAULT NULL
  ,p_pgp_segment25                IN     VARCHAR2 DEFAULT NULL
  ,p_pgp_segment26                IN     VARCHAR2 DEFAULT NULL
  ,p_pgp_segment27                IN     VARCHAR2 DEFAULT NULL
  ,p_pgp_segment28                IN     VARCHAR2 DEFAULT NULL
  ,p_pgp_segment29                IN     VARCHAR2 DEFAULT NULL
  ,p_pgp_segment30                IN     VARCHAR2 DEFAULT NULL
  ,p_pgp_concat_segments          IN     VARCHAR2 DEFAULT NULL
  ,p_assignment_id                   OUT NOCOPY NUMBER
  ,p_soft_coding_keyflex_id          OUT NOCOPY NUMBER
  ,p_people_group_id                 OUT NOCOPY NUMBER
  ,p_object_version_number           OUT NOCOPY NUMBER
  ,p_effective_start_date            OUT NOCOPY DATE
  ,p_effective_end_date              OUT NOCOPY DATE
  ,p_assignment_sequence             OUT NOCOPY NUMBER
  ,p_comment_id                      OUT NOCOPY NUMBER
  ,p_concatenated_segments           OUT NOCOPY VARCHAR2
  ,p_group_name                      OUT NOCOPY VARCHAR2
  ,p_other_manager_warning           OUT NOCOPY BOOLEAN
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_dk_emp_asg >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates employee assignment details which do not affect entitlement
 * to element entries.
 *
 * This API is effectively an alternative to the API update_emp_asg. If
 * p_validate is set to false, then the assignment record is updated. Also,
 * this API updates an employee assignment status. The new status must have a
 * system status of ACTIVE_ASSIGN. If the assignment status is already a type
 * of ACTIVE_ASSIGN, this API can be used to set a different active status. If
 * the calling routine does not explicitly pass in a status, the API uses the
 * default ACTIVE_ASSIGN status for the assignment's business group. Note: Only
 * employee assignments can be altered with this API. Updates to an applicant
 * assignment status are not allowed.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The assignment must exist as of the effective date and must be an employee
 * assignment.
 *
 * <p><b>Post Success</b><br>
 * The API updates the assignment record in the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the assignment record and raises an error.
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
 * @param p_assignment_id Identifies the assignment record to modify.
 * @param p_object_version_number Pass in the current version number of the
 * assignment to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated assignment. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_supervisor_id Supervisor for the assignment. The value refers to
 * the supervisor's person record.
 * @param p_assignment_number Assignment number.
 * @param p_change_reason Reason for the assignment status change. If there is
 * no change reason, then the parameter can be null. Valid values are defined
 * in the 'EMP_ASSIGN_REASON' lookup type.
 * @param p_comments Comment text.
 * @param p_date_probation_end End date of probation period.
 * @param p_default_code_comb_id Identifier for the General Ledger Accounting
 * Flexfield combination that applies to this assignment.
 * @param p_frequency Frequency associated with the defined normal working
 * hours. Valid values are defined in the 'FREQUENCY' lookup type.
 * @param p_internal_address_line Internal address identified with this
 * assignment.
 * @param p_manager_flag Indicates whether the employee is a manager.
 * @param p_normal_hours Normal working hours for this assignment.
 * @param p_perf_review_period Length of performance review period.
 * @param p_perf_review_period_frequency Units of performance review period.
 * Valid values are defined in the 'FREQUENCY' lookup type.
 * @param p_probation_period Length of probation period.
 * @param p_probation_unit Units of probation period. Valid values are defined
 * in the 'QUALIFYING_UNITS' lookup type.
 * @param p_sal_review_period Length of salary review period.
 * @param p_sal_review_period_frequency Units of salary review period. Valid
 * values are defined in the 'FREQUENCY' lookup type.
 * @param p_set_of_books_id Identifies General Ledger set of books.
 * @param p_source_type Recruitment activity which this assignment is sourced
 * from. Valid values are defined in the 'REC_TYPE' lookup type.
 * @param p_time_normal_finish Normal work finish time.
 * @param p_time_normal_start Normal work start time.
 * @param p_bargaining_unit_code Code for bargaining unit. Valid values are
 * defined in the 'BARGAINING_UNIT_CODE' lookup type.
 * @param p_labour_union_member_flag Indicates whether the employee is a labour
 * union member. A value 'Y' indicates that the employee is a labour union
 * member.
 * @param p_hourly_salaried_code Identifies if the assignment is paid hourly or
 * is salaried. Valid values defined in the 'HOURLY_SALARIED_CODE' lookup type.
 * @param p_ass_attribute_category This context value determines which
 * flexfield structure to use with the descriptive flexfield segments.
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
 * @param p_legal_entity Legal Entity of the assignment. Valid values are
 * defined in the 'HR_DK_LEGAL_ENTITY' lookup type.
 * @param p_cond_of_emp Employee category. Valid values are defined in the
 * lookup type 'DK_COND_OF_EMP'
 * @param p_emp_group Employee type. Valid values are defined in the
 * 'DK_EMP_TYPE' lookup type.
 * @param p_union_membership Union membership. Valid values are defined in the
 * 'DK_UNION_MEMBERSHIP' lookup type.
 * @param p_termination_reason Reason for terminating the assignment.
 * @param p_notified_date Notified date.
 * @param p_termination_date Termination date.
 * @param p_adjusted_seniority_date Adjusted seniority date.
 * @param p_default_work_pattern  Default Work Pattern  for Holiday Entitlement
 * Valid values are defined in the Value set 'DK_WORK_PATTERNS'
 * @param p_hourly_accrual_rate  Hourly Accrual Rate  for Holiday Entitlement
 * Valid values are defined in the Value set 'HR_DK_2_DIGIT'
 * @param p_accrual_type  Accrual Type  for Holiday Entitlement
 * Valid values are defined in the Value set 'DK_ACCRUAL_TYPES'
 * @param p_salaried_allowance_rate  Salaried Allowance Rate  for Holiday Entitlement
 * Valid values are defined in the Value set 'HR_DK_2_DIGIT'
 * @param p_job_occupation_employee_code  Job Occupation Employee Code  for DA Office codes
 * Valid values are defined in the Value set 'HR_DK_JOB_OCC_MKODE'
 * @param p_job_status_employee_code  Job Status Employee Code  for DA Office codes
 * Valid values are defined in the Value set 'HR_DK_JOB_STATUS_MKODE'
 * @param p_salary_basis_employee_code  Salary Basis Employee Code  for DA Office codes
 * Valid values are defined in the Value set 'HR_DK_SALARY_BASIS_MKODE'
 * @param p_time_off_in_lieu  Time Off in Lieu  for DA Office codes
 * Valid values are defined in the Value set 'HR_DK_YES_NO'
 * @param p_section_28_registration  Section 28 Registration  for Sick Pay Defaults
 * Valid values are defined in the Value set 'HR_DK_YES_NO'
 * @param p_comment_id If p_validate is false and comment text was provided,
 * then will be set to the identifier of the created assignment comment record.
 * If p_validate is true or no comment text was provided, then will be null.
 * @param p_soft_coding_keyflex_id If p_validate is FALSE and any p_segment
 * parameters have set text, set to the ID of the corresponding soft coding
 * keyflex row. If p_validate is true, or no p_segment parameters have set
 * text, this will be NULL.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated assignment row which now exists as of
 * the effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated assignment row which now exists as of the
 * effective date. If p_validate is true, then set to null.
 * @param p_concatenated_segments If p_validate is false, set to soft coded key
 * flexfield concatenated segments. If p_validate is true, set to null.
 * @param p_no_managers_warning Set to true if as a result of the update there
 * is no manager in the organization. Otherwise set to false.
 * @param p_other_manager_warning If set to true, then a manager existed in the
 * organization prior to calling this API and the manager flag has been set to
 * 'Y' for yes.
 * @rep:displayname Update Employee Assignment for Denmark
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE_ASG
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE update_dk_emp_asg
  (p_validate                     IN     BOOLEAN  DEFAULT FALSE
  ,p_effective_date               IN     DATE
  ,p_datetrack_update_mode        IN     VARCHAR2
  ,p_assignment_id                IN     NUMBER
  ,p_object_version_number        IN OUT NOCOPY NUMBER
  ,p_supervisor_id                IN     NUMBER   DEFAULT hr_api.g_number
  ,p_assignment_number            IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_change_reason                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_comments                     IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_date_probation_end           IN     DATE     DEFAULT hr_api.g_date
  ,p_default_code_comb_id         IN     NUMBER   DEFAULT hr_api.g_number
  ,p_frequency                    IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_internal_address_line        IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_manager_flag                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_normal_hours                 IN     NUMBER   DEFAULT hr_api.g_number
  ,p_perf_review_period           IN     NUMBER   DEFAULT hr_api.g_number
  ,p_perf_review_period_frequency IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_probation_period             IN     NUMBER   DEFAULT hr_api.g_number
  ,p_probation_unit               IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_sal_review_period            IN     NUMBER   DEFAULT hr_api.g_number
  ,p_sal_review_period_frequency  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_set_of_books_id              IN     NUMBER   DEFAULT hr_api.g_number
  ,p_source_type                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_time_normal_finish           IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_time_normal_start            IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_bargaining_unit_code         IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_labour_union_member_flag     IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_hourly_salaried_code         IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_ass_attribute_category       IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_ass_attribute1               IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_ass_attribute2               IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_ass_attribute3               IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_ass_attribute4               IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_ass_attribute5               IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_ass_attribute6               IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_ass_attribute7               IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_ass_attribute8               IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_ass_attribute9               IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_ass_attribute10              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_ass_attribute11              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_ass_attribute12              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_ass_attribute13              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_ass_attribute14              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_ass_attribute15              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_ass_attribute16              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_ass_attribute17              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_ass_attribute18              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_ass_attribute19              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_ass_attribute20              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_ass_attribute21              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_ass_attribute22              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_ass_attribute23              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_ass_attribute24              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_ass_attribute25              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_ass_attribute26              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_ass_attribute27              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_ass_attribute28              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_ass_attribute29              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_ass_attribute30              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_title                        IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_legal_entity                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  --,p_pension_provider             IN     VARCHAR2 DEFAULT hr_api.g_varchar2 Removed from assignment level and it's captured at Element entry level
  ,p_cond_of_emp	          IN     VARCHAR2 DEFAULT hr_api.g_varchar2  -- Condition of Employment
  ,p_emp_group		          IN     VARCHAR2 DEFAULT hr_api.g_varchar2  -- Employee Group
  ,p_union_membership             IN     VARCHAR2 DEFAULT hr_api.g_varchar2  -- Union Membership
   ,p_termination_reason	  IN	 VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_notified_date		  IN	 DATE	  DEFAULT hr_api.g_date
  ,p_termination_date		  IN	 DATE	  DEFAULT hr_api.g_date
  ,p_adjusted_seniority_date	  IN	 DATE	  DEFAULT hr_api.g_date
  ,p_default_work_pattern	  IN     VARCHAR2 DEFAULT hr_api.g_varchar2  -- Holiday Entitlement
  ,p_hourly_accrual_rate	  IN     NUMBER   DEFAULT hr_api.g_number    -- Holiday Entitlement
  ,p_accrual_type		  IN     VARCHAR2 DEFAULT hr_api.g_varchar2  -- Holiday Entitlement
  ,p_salaried_allowance_rate	  IN     NUMBER   DEFAULT hr_api.g_number    -- Holiday Entitlement
  ,p_job_occupation_employee_code IN     VARCHAR2 DEFAULT hr_api.g_varchar2  -- DA Office codes
  ,p_job_status_employee_code	  IN     VARCHAR2 DEFAULT hr_api.g_varchar2  -- DA Office codes
  ,p_salary_basis_employee_code	  IN     VARCHAR2 DEFAULT hr_api.g_varchar2  -- DA Office codes
  ,p_time_off_in_lieu		  IN     VARCHAR2 DEFAULT hr_api.g_varchar2  -- DA Office codes
  ,p_section_28_registration	  IN     VARCHAR2 DEFAULT hr_api.g_varchar2  -- Sick Pay Defaults
  ,p_comment_id                      OUT NOCOPY NUMBER
  ,p_soft_coding_keyflex_id          OUT NOCOPY NUMBER
  ,p_effective_start_date            OUT NOCOPY DATE
  ,p_effective_end_date              OUT NOCOPY DATE
  ,p_concatenated_segments           OUT NOCOPY VARCHAR2
  ,p_no_managers_warning             OUT NOCOPY BOOLEAN
  ,p_other_manager_warning           OUT NOCOPY BOOLEAN
  );
END hr_dk_assignment_api;

 

/
