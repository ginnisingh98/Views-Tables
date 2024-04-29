--------------------------------------------------------
--  DDL for Package HR_MX_ASSIGNMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_MX_ASSIGNMENT_API" AUTHID CURRENT_USER AS
/* $Header: pemxwras.pkh 120.3 2005/11/04 05:36:57 jcolman noship $ */
/*#
 * This package contains APIs for maintaining employee, applicant and
 * contingent worker assignment details for Mexico.
 * @rep:scope public
 * @rep:product PER
 * @rep:displayname Assignment for Mexico
*/
 g_leaving_reason VARCHAR2(2);
 g_old_gre        hr_soft_coding_keyflex.segment1%TYPE;
 g_old_location   hr_locations.location_id%TYPE;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_mx_secondary_emp_asg >--------------------|
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
 * A new secondary assignment is created for the employee.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the secondary assignment and raises an error.
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
 * secondary assignment.
 * @param p_payroll_id Identifies the payroll for the secondary assignment.
 * @param p_location_id Identifies the location of the secondary assignment.
 * @param p_supervisor_id Identifies the supervisor for the secondary
 * assignment. The value refers to the supervisor's person record.
 * @param p_special_ceiling_step_id Highest allowed step for the grade scale
 * associated with the grade of the secondary assignment.
 * @param p_pay_basis_id Salary basis for the secondary assignment.
 * @param p_assignment_number If a value is passed in, this is used as the
 * assignment number. If no value is passed in an assignment number is
 * generated.
 * @param p_change_reason Reason for the assignment status change. If there is
 * no change reason the parameter can be null. Valid values are defined in the
 * EMP_ASSIGN_REASON lookup type.
 * @param p_comments Comment text.
 * @param p_date_probation_end End date of probation period.
 * @param p_default_code_comb_id Identifier for the General Ledger Accounting
 * Flexfield combination that applies to this assignment.
 * @param p_employment_category Employment category. Valid values are defined
 * in the EMP_CAT lookup type.
 * @param p_frequency Frequency associated with the defined normal working
 * hours. Valid values are defined in the FREQUENCY lookup type.
 * @param p_internal_address_line Internal address identified with the
 * secondary assignment.
 * @param p_manager_flag Indicates whether the employee is a manager.
 * @param p_normal_hours Normal working hours for this assignment.
 * @param p_perf_review_period Length of performance review period.
 * @param p_perf_review_period_frequency Units of performance review period.
 * Valid values are defined in the FREQUENCY lookup type.
 * @param p_probation_period Length of probation period.
 * @param p_probation_unit Units of probation period. Valid values are defined
 * in the QUALIFYING_UNITS lookup type.
 * @param p_sal_review_period Length of salary review period.
 * @param p_sal_review_period_frequency Units of salary review period. Valid
 * values are defined in the FREQUENCY lookup type.
 * @param p_set_of_books_id Identifies General Ledger set of books.
 * @param p_source_type Recruitment activity which this assignment is sourced
 * from. Valid values are defined in the REC_TYPE lookup type.
 * @param p_time_normal_finish Normal work finish time.
 * @param p_time_normal_start Normal work start time
 * @param p_bargaining_unit_code Code for bargaining unit. Valid values are
 * defined in the BARGAINING_UNIT_CODE lookup type.
 * @param p_labour_union_member_flag Value 'Y' indicates employee is a labour
 * union member. Other values indicate not a member.
 * @param p_hourly_salaried_code Identifies if the assignment is paid hourly or
 * is salaried. Valid values defined in the HOURLY_SALARIED_CODE lookup type.
 * @param p_ass_attribute_category This context value determines which
 * Flexfield Structure to use with the Descriptive flexfield segments.
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
 * @param p_tax_unit Government Reporting Entity.
 * @param p_timecard_approver Timecard Approver.
 * @param p_timecard_required Indicates whether timecard is required.
 * @param p_work_schedule Indicates the pattern of work for the assignment.
 * @param p_gov_emp_sector Federal Government Sector (Rama del Gobierno
 * Federal).
 * @param p_ss_salary_type Social Security Salary Type.
 * @param p_scl_concat_segments Concatenated segments for Soft Coded Key
 * Flexfield. Concatenated segments can be supplied instead of individual
 * segments.
 * @param p_pgp_segment1 People Group Key flexfield segment.
 * @param p_pgp_segment2 People Group Key flexfield segment.
 * @param p_pgp_segment3 People Group Key flexfield segment.
 * @param p_pgp_segment4 People Group Key flexfield segment.
 * @param p_pgp_segment5 People Group Key flexfield segment.
 * @param p_pgp_segment6 People Group Key flexfield segment.
 * @param p_pgp_segment7 People Group Key flexfield segment.
 * @param p_pgp_segment8 People Group Key flexfield segment.
 * @param p_pgp_segment9 People Group Key flexfield segment.
 * @param p_pgp_segment10 People Group Key flexfield segment.
 * @param p_pgp_segment11 People Group Key flexfield segment.
 * @param p_pgp_segment12 People Group Key flexfield segment.
 * @param p_pgp_segment13 People Group Key flexfield segment.
 * @param p_pgp_segment14 People Group Key flexfield segment.
 * @param p_pgp_segment15 People Group Key flexfield segment.
 * @param p_pgp_segment16 People Group Key flexfield segment.
 * @param p_pgp_segment17 People Group Key flexfield segment.
 * @param p_pgp_segment18 People Group Key flexfield segment.
 * @param p_pgp_segment19 People Group Key flexfield segment.
 * @param p_pgp_segment20 People Group Key flexfield segment.
 * @param p_pgp_segment21 People Group Key flexfield segment.
 * @param p_pgp_segment22 People Group Key flexfield segment.
 * @param p_pgp_segment23 People Group Key flexfield segment.
 * @param p_pgp_segment24 People Group Key flexfield segment.
 * @param p_pgp_segment25 People Group Key flexfield segment.
 * @param p_pgp_segment26 People Group Key flexfield segment.
 * @param p_pgp_segment27 People Group Key flexfield segment.
 * @param p_pgp_segment28 People Group Key flexfield segment.
 * @param p_pgp_segment29 People Group Key flexfield segment.
 * @param p_pgp_segment30 People Group Key flexfield segment.
 * @param p_pgp_concat_segments Concatenated segments for People Group Key
 * Flexfield. Concatenated segments can be supplied instead of individual
 * segments.
 * @param p_contract_id Contract associated with this assignment.
 * @param p_establishment_id For French business groups, this identifies the
 * Establishment Legal Entity for this assignment.
 * @param p_collective_agreement_id Collective Agreement that applies to this
 * assignment.
 * @param p_cagr_id_flex_num Identifier for the structure from CAGR Key
 * flexfield to use for this assignment.
 * @param p_cag_segment1 CAGR Key Flexfield segment.
 * @param p_cag_segment2 CAGR Key Flexfield segment.
 * @param p_cag_segment3 CAGR Key Flexfield segment.
 * @param p_cag_segment4 CAGR Key Flexfield segment.
 * @param p_cag_segment5 CAGR Key Flexfield segment.
 * @param p_cag_segment6 CAGR Key Flexfield segment.
 * @param p_cag_segment7 CAGR Key Flexfield segment.
 * @param p_cag_segment8 CAGR Key Flexfield segment.
 * @param p_cag_segment9 CAGR Key Flexfield segment.
 * @param p_cag_segment10 CAGR Key Flexfield segment.
 * @param p_cag_segment11 CAGR Key Flexfield segment.
 * @param p_cag_segment12 CAGR Key Flexfield segment.
 * @param p_cag_segment13 CAGR Key Flexfield segment.
 * @param p_cag_segment14 CAGR Key Flexfield segment.
 * @param p_cag_segment15 CAGR Key Flexfield segment.
 * @param p_cag_segment16 CAGR Key Flexfield segment.
 * @param p_cag_segment17 CAGR Key Flexfield segment.
 * @param p_cag_segment18 CAGR Key Flexfield segment.
 * @param p_cag_segment19 CAGR Key Flexfield segment.
 * @param p_cag_segment20 CAGR Key Flexfield segment.
 * @param p_notice_period Length of notice period.
 * @param p_notice_period_uom Units for notice period. Valid values are defined
 * in the QUALIFYING_UNITS lookup type.
 * @param p_employee_category Employee Category. Valid values are defined in
 * the EMPLOYEE_CATG lookup type.
 * @param p_work_at_home Indicates whether this assignment is to work at home.
 * Valid values are defined in the YES_NO lookup type.
 * @param p_job_post_source_name The source of the job posting that was
 * answered for this assignment.
 * @param p_grade_ladder_pgm_id Grade Ladder for this assignment.
 * @param p_supervisor_assignment_id Supervisor's assignment that is
 * responsible for supervising this assignment.
 * @param p_group_name If p_validate is false, then set to the People Group Key
 * Flexfield concatenated segments. If p_validate is true, then set to null.
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
 * @param p_cagr_concatenated_segments CAGR Key Flexfield concatenated
 * segments.
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
 * @rep:displayname Create Secondary Employee Assignment for Mexico
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE_ASG
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE create_mx_secondary_emp_asg
  (p_validate                     IN     BOOLEAN  DEFAULT   false
  ,p_effective_date               IN     DATE
  ,p_person_id                    IN     NUMBER
  ,p_organization_id              IN     NUMBER
  ,p_grade_id                     IN     NUMBER   DEFAULT   null
  ,p_position_id                  IN     NUMBER   DEFAULT   null
  ,p_job_id                       IN     NUMBER   DEFAULT   null
  ,p_assignment_status_type_id    IN     NUMBER   DEFAULT   null
  ,p_payroll_id                   IN     NUMBER   DEFAULT   null
  ,p_location_id                  IN     NUMBER   DEFAULT   null
  ,p_supervisor_id                IN     NUMBER   DEFAULT   null
  ,p_special_ceiling_step_id      IN     NUMBER   DEFAULT   null
  ,p_pay_basis_id                 IN     NUMBER   DEFAULT   null
  ,p_assignment_number            IN OUT NOCOPY   VARCHAR2
  ,p_change_reason                IN     VARCHAR2 DEFAULT   null
  ,p_comments                     IN     VARCHAR2 DEFAULT   null
  ,p_date_probation_end           IN     DATE     DEFAULT   null
  ,p_default_code_comb_id         IN     NUMBER   DEFAULT   null
  ,p_employment_category          IN     VARCHAR2 DEFAULT   null
  ,p_frequency                    IN     VARCHAR2 DEFAULT   null
  ,p_internal_address_line        IN     VARCHAR2 DEFAULT   null
  ,p_manager_flag                 IN     VARCHAR2 DEFAULT   null
  ,p_normal_hours                 IN     NUMBER   DEFAULT   null
  ,p_perf_review_period           IN     NUMBER   DEFAULT   null
  ,p_perf_review_period_frequency IN     VARCHAR2 DEFAULT   null
  ,p_probation_period             IN     NUMBER   DEFAULT   null
  ,p_probation_unit               IN     VARCHAR2 DEFAULT   null
  ,p_sal_review_period            IN     NUMBER   DEFAULT   null
  ,p_sal_review_period_frequency  IN     VARCHAR2 DEFAULT   null
  ,p_set_of_books_id              IN     NUMBER   DEFAULT   null
  ,p_source_type                  IN     VARCHAR2 DEFAULT   null
  ,p_time_normal_finish           IN     VARCHAR2 DEFAULT   null
  ,p_time_normal_start            IN     VARCHAR2 DEFAULT   null
  ,p_bargaining_unit_code         IN     VARCHAR2 DEFAULT   null
  ,p_labour_union_member_flag     IN     VARCHAR2 DEFAULT   null
  ,p_hourly_salaried_code         IN     VARCHAR2 DEFAULT   null
  ,p_ass_attribute_category       IN     VARCHAR2 DEFAULT   null
  ,p_ass_attribute1               IN     VARCHAR2 DEFAULT   null
  ,p_ass_attribute2               IN     VARCHAR2 DEFAULT   null
  ,p_ass_attribute3               IN     VARCHAR2 DEFAULT   null
  ,p_ass_attribute4               IN     VARCHAR2 DEFAULT   null
  ,p_ass_attribute5               IN     VARCHAR2 DEFAULT   null
  ,p_ass_attribute6               IN     VARCHAR2 DEFAULT   null
  ,p_ass_attribute7               IN     VARCHAR2 DEFAULT   null
  ,p_ass_attribute8               IN     VARCHAR2 DEFAULT   null
  ,p_ass_attribute9               IN     VARCHAR2 DEFAULT   null
  ,p_ass_attribute10              IN     VARCHAR2 DEFAULT   null
  ,p_ass_attribute11              IN     VARCHAR2 DEFAULT   null
  ,p_ass_attribute12              IN     VARCHAR2 DEFAULT   null
  ,p_ass_attribute13              IN     VARCHAR2 DEFAULT   null
  ,p_ass_attribute14              IN     VARCHAR2 DEFAULT   null
  ,p_ass_attribute15              IN     VARCHAR2 DEFAULT   null
  ,p_ass_attribute16              IN     VARCHAR2 DEFAULT   null
  ,p_ass_attribute17              IN     VARCHAR2 DEFAULT   null
  ,p_ass_attribute18              IN     VARCHAR2 DEFAULT   null
  ,p_ass_attribute19              IN     VARCHAR2 DEFAULT   null
  ,p_ass_attribute20              IN     VARCHAR2 DEFAULT   null
  ,p_ass_attribute21              IN     VARCHAR2 DEFAULT   null
  ,p_ass_attribute22              IN     VARCHAR2 DEFAULT   null
  ,p_ass_attribute23              IN     VARCHAR2 DEFAULT   null
  ,p_ass_attribute24              IN     VARCHAR2 DEFAULT   null
  ,p_ass_attribute25              IN     VARCHAR2 DEFAULT   null
  ,p_ass_attribute26              IN     VARCHAR2 DEFAULT   null
  ,p_ass_attribute27              IN     VARCHAR2 DEFAULT   null
  ,p_ass_attribute28              IN     VARCHAR2 DEFAULT   null
  ,p_ass_attribute29              IN     VARCHAR2 DEFAULT   null
  ,p_ass_attribute30              IN     VARCHAR2 DEFAULT   null
  ,p_title                        IN     VARCHAR2 DEFAULT   null
  ,p_tax_unit                     IN     VARCHAR2 DEFAULT   null
  ,p_timecard_approver            IN     VARCHAR2 DEFAULT   null
  ,p_timecard_required            IN     VARCHAR2 DEFAULT   null
  ,p_work_schedule                IN     VARCHAR2 DEFAULT   null
  ,p_gov_emp_sector               IN     VARCHAR2 DEFAULT   null
  ,p_ss_salary_type               IN     VARCHAR2 DEFAULT   null
  ,p_scl_concat_segments    	  IN 	 VARCHAR2 DEFAULT   null
  ,p_pgp_segment1                 IN     VARCHAR2 DEFAULT   null
  ,p_pgp_segment2                 IN     VARCHAR2 DEFAULT   null
  ,p_pgp_segment3                 IN     VARCHAR2 DEFAULT   null
  ,p_pgp_segment4                 IN     VARCHAR2 DEFAULT   null
  ,p_pgp_segment5                 IN     VARCHAR2 DEFAULT   null
  ,p_pgp_segment6                 IN     VARCHAR2 DEFAULT   null
  ,p_pgp_segment7                 IN     VARCHAR2 DEFAULT   null
  ,p_pgp_segment8                 IN     VARCHAR2 DEFAULT   null
  ,p_pgp_segment9                 IN     VARCHAR2 DEFAULT   null
  ,p_pgp_segment10                IN     VARCHAR2 DEFAULT   null
  ,p_pgp_segment11                IN     VARCHAR2 DEFAULT   null
  ,p_pgp_segment12                IN     VARCHAR2 DEFAULT   null
  ,p_pgp_segment13                IN     VARCHAR2 DEFAULT   null
  ,p_pgp_segment14                IN     VARCHAR2 DEFAULT   null
  ,p_pgp_segment15                IN     VARCHAR2 DEFAULT   null
  ,p_pgp_segment16                IN     VARCHAR2 DEFAULT   null
  ,p_pgp_segment17                IN     VARCHAR2 DEFAULT   null
  ,p_pgp_segment18                IN     VARCHAR2 DEFAULT   null
  ,p_pgp_segment19                IN     VARCHAR2 DEFAULT   null
  ,p_pgp_segment20                IN     VARCHAR2 DEFAULT   null
  ,p_pgp_segment21                IN     VARCHAR2 DEFAULT   null
  ,p_pgp_segment22                IN     VARCHAR2 DEFAULT   null
  ,p_pgp_segment23                IN     VARCHAR2 DEFAULT   null
  ,p_pgp_segment24                IN     VARCHAR2 DEFAULT   null
  ,p_pgp_segment25                IN     VARCHAR2 DEFAULT   null
  ,p_pgp_segment26                IN     VARCHAR2 DEFAULT   null
  ,p_pgp_segment27                IN     VARCHAR2 DEFAULT   null
  ,p_pgp_segment28                IN     VARCHAR2 DEFAULT   null
  ,p_pgp_segment29                IN     VARCHAR2 DEFAULT   null
  ,p_pgp_segment30                IN     VARCHAR2 DEFAULT   null
  ,p_pgp_concat_segments	  IN     VARCHAR2 DEFAULT   null
  ,p_contract_id                  IN     NUMBER   DEFAULT   null
  ,p_establishment_id             IN     NUMBER   DEFAULT   null
  ,p_collective_agreement_id      IN     NUMBER   DEFAULT   null
  ,p_cagr_id_flex_num             IN     NUMBER   DEFAULT   null
  ,p_cag_segment1                 IN     VARCHAR2 DEFAULT   null
  ,p_cag_segment2                 IN     VARCHAR2 DEFAULT   null
  ,p_cag_segment3                 IN     VARCHAR2 DEFAULT   null
  ,p_cag_segment4                 IN     VARCHAR2 DEFAULT   null
  ,p_cag_segment5                 IN     VARCHAR2 DEFAULT   null
  ,p_cag_segment6                 IN     VARCHAR2 DEFAULT   null
  ,p_cag_segment7                 IN     VARCHAR2 DEFAULT   null
  ,p_cag_segment8                 IN     VARCHAR2 DEFAULT   null
  ,p_cag_segment9                 IN     VARCHAR2 DEFAULT   null
  ,p_cag_segment10                IN     VARCHAR2 DEFAULT   null
  ,p_cag_segment11                IN     VARCHAR2 DEFAULT   null
  ,p_cag_segment12                IN     VARCHAR2 DEFAULT   null
  ,p_cag_segment13                IN     VARCHAR2 DEFAULT   null
  ,p_cag_segment14                IN     VARCHAR2 DEFAULT   null
  ,p_cag_segment15                IN     VARCHAR2 DEFAULT   null
  ,p_cag_segment16                IN     VARCHAR2 DEFAULT   null
  ,p_cag_segment17                IN     VARCHAR2 DEFAULT   null
  ,p_cag_segment18                IN     VARCHAR2 DEFAULT   null
  ,p_cag_segment19                IN     VARCHAR2 DEFAULT   null
  ,p_cag_segment20                IN     VARCHAR2 DEFAULT   null
  ,p_notice_period		  IN	 NUMBER   DEFAULT   null
  ,p_notice_period_uom		  IN     VARCHAR2 DEFAULT   null
  ,p_employee_category		  IN     VARCHAR2 DEFAULT   null
  ,p_work_at_home		  IN	 VARCHAR2 DEFAULT   null
  ,p_job_post_source_name         IN     VARCHAR2 DEFAULT   null
  ,p_grade_ladder_pgm_id	  IN	 NUMBER   DEFAULT   null
  ,p_supervisor_assignment_id	  IN	 NUMBER   DEFAULT   null
  ,p_group_name                      OUT NOCOPY   VARCHAR2
  ,p_concatenated_segments           OUT NOCOPY   VARCHAR2
  ,p_cagr_grade_def_id            IN OUT NOCOPY   NUMBER
  ,p_cagr_concatenated_segments      OUT NOCOPY   VARCHAR2
  ,p_assignment_id                   OUT NOCOPY   NUMBER
  ,p_soft_coding_keyflex_id       IN OUT NOCOPY   NUMBER
  ,p_people_group_id              IN OUT NOCOPY   NUMBER
  ,p_object_version_number           OUT NOCOPY   NUMBER
  ,p_effective_start_date            OUT NOCOPY   DATE
  ,p_effective_end_date              OUT NOCOPY   DATE
  ,p_assignment_sequence             OUT NOCOPY   NUMBER
  ,p_comment_id                      OUT NOCOPY   NUMBER
  ,p_other_manager_warning           OUT NOCOPY   BOOLEAN
  ,p_hourly_salaried_warning         OUT NOCOPY   BOOLEAN
  ,p_gsp_post_process_warning        OUT NOCOPY   VARCHAR2);
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_mx_emp_asg >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates employee assignment details that do not affect entitlement
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
 * @param p_assignment_id Identifies the assignment record to be modified.
 * @param p_object_version_number Pass in the current version number of the
 * assignment to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated assignment. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_supervisor_id Supervisor for the assignment. The value refers to
 * the supervisor's person record.
 * @param p_assignment_number Assignment number.
 * @param p_change_reason Reason for the assignment status change. If there is
 * no change reason the parameter can be null. Valid values are defined in the
 * EMP_ASSIGN_REASON lookup type.
 * @param p_assignment_status_type_id Assignment status. The system status must
 * be the same as before the update, otherwise one of the status change APIs
 * should be used.
 * @param p_comments Comment text.
 * @param p_date_probation_end End date of probation period.
 * @param p_default_code_comb_id Identifier for the General Ledger Accounting
 * Flexfield combination that applies to this assignment.
 * @param p_frequency Frequency associated with the defined normal working
 * hours. Valid values are defined in the FREQUENCY lookup type.
 * @param p_internal_address_line Internal address identified with this
 * assignment.
 * @param p_manager_flag Indicates whether the employee is a manager.
 * @param p_normal_hours Normal working hours for this assignment.
 * @param p_perf_review_period Length of performance review period.
 * @param p_perf_review_period_frequency Units of performance review period.
 * Valid values are defined in the FREQUENCY lookup type.
 * @param p_probation_period Length of probation period.
 * @param p_probation_unit Units of probation period. Valid values are defined
 * in the QUALIFYING_UNITS lookup type.
 * @param p_sal_review_period Length of salary review period.
 * @param p_sal_review_period_frequency Units of salary review period. Valid
 * values are defined in the FREQUENCY lookup type.
 * @param p_set_of_books_id Identifies General Ledger set of books.
 * @param p_source_type Recruitment activity which this assignment is sourced
 * from. Valid values are defined in the REC_TYPE lookup type.
 * @param p_time_normal_finish Normal work finish time.
 * @param p_time_normal_start Normal work start time.
 * @param p_bargaining_unit_code Code for bargaining unit. Valid values are
 * defined in the BARGAINING_UNIT_CODE lookup type.
 * @param p_labour_union_member_flag Value 'Y' indicates employee is a labour
 * union member. Other values indicate not a member.
 * @param p_hourly_salaried_code Identifies if the assignment is paid hourly or
 * is salaried. Valid values are defined in the HOURLY_SALARIED_CODE lookup
 * type.
 * @param p_ass_attribute_category This context value determines which
 * Flexfield Structure to use with the Descriptive flexfield segments.
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
 * @param p_tax_unit Government Reporting Entity.
 * @param p_timecard_approver Timecard Approver.
 * @param p_timecard_required Indicates whether timecard is required.
 * @param p_work_schedule Indicates the pattern of work for the assignment.
 * @param p_gov_emp_sector Federal Government Sector (Rama del Gobierno
 * Federal).
 * @param p_ss_salary_type Social Security Salary Type.
 * @param p_scl_concat_segments Obsolete parameter, do not use.
 * @param p_concat_segments Concatenated segments for Soft Coded Key Flexfield.
 * Concatenated segments can be supplied instead of individual segments.
 * @param p_contract_id Contract associated with this assignment.
 * @param p_establishment_id For French business groups, this identifies the
 * Establishment Legal Entity for this assignment.
 * @param p_collective_agreement_id Collective Agreement that applies to this
 * assignment.
 * @param p_cagr_id_flex_num Identifier for the structure from CAGR Key
 * flexfield to use for this assignment.
 * @param p_cag_segment1 CAGR Key Flexfield segment.
 * @param p_cag_segment2 CAGR Key Flexfield segment.
 * @param p_cag_segment3 CAGR Key Flexfield segment.
 * @param p_cag_segment4 CAGR Key Flexfield segment.
 * @param p_cag_segment5 CAGR Key Flexfield segment.
 * @param p_cag_segment6 CAGR Key Flexfield segment.
 * @param p_cag_segment7 CAGR Key Flexfield segment.
 * @param p_cag_segment8 CAGR Key Flexfield segment.
 * @param p_cag_segment9 CAGR Key Flexfield segment.
 * @param p_cag_segment10 CAGR Key Flexfield segment.
 * @param p_cag_segment11 CAGR Key Flexfield segment.
 * @param p_cag_segment12 CAGR Key Flexfield segment.
 * @param p_cag_segment13 CAGR Key Flexfield segment.
 * @param p_cag_segment14 CAGR Key Flexfield segment.
 * @param p_cag_segment15 CAGR Key Flexfield segment.
 * @param p_cag_segment16 CAGR Key Flexfield segment.
 * @param p_cag_segment17 CAGR Key Flexfield segment.
 * @param p_cag_segment18 CAGR Key Flexfield segment.
 * @param p_cag_segment19 CAGR Key Flexfield segment.
 * @param p_cag_segment20 CAGR Key Flexfield segment.
 * @param p_notice_period Length of notice period.
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
 * @param p_ss_leaving_reason If a value is passed in for this parameter, it
 * identifies an existing CAGR Key Flexfield combination to associate with the
 * assignment, and segment values are ignored. If a value is not passed in,
 * then the individual CAGR Key Flexfield segments supplied will be used to
 * choose an existing combination or create a new combination. When the API
 * completes, if p_validate is false, then this uniquely identifies the
 * associated combination of the CAGR Key flexfield for this assignment. If
 * p_validate is true, then set to null.
 * @param p_cagr_grade_def_id CAGR Key Flexfield concatenated segments.
 * @param p_cagr_concatenated_segments If p_validate is false, then set to CAGR
 * Key Flexfield concatenated segments. If p_validate is true, then set to
 * null.
 * @param p_concatenated_segments If p_validate is false, then set to Soft
 * Coded Key Flexfield concatenated segments. If p_validate is true, then set
 * to null.
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
 * @rep:displayname Update Employee Assignment for Mexico
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE_ASG
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
 PROCEDURE update_mx_emp_asg
 ( p_validate                     IN     BOOLEAN  DEFAULT   false
  ,p_effective_date               IN     DATE
  ,p_datetrack_update_mode        IN     VARCHAR2
  ,p_assignment_id                IN     NUMBER
  ,p_object_version_number        IN OUT NOCOPY   NUMBER
  ,p_supervisor_id                IN     NUMBER   DEFAULT   hr_api.g_number
  ,p_assignment_number            IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_change_reason                IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_assignment_status_type_id    IN     NUMBER   DEFAULT   hr_api.g_number
  ,p_comments                     IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_date_probation_end           IN     DATE     DEFAULT   hr_api.g_date
  ,p_default_code_comb_id         IN     NUMBER   DEFAULT   hr_api.g_number
  ,p_frequency                    IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_internal_address_line        IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_manager_flag                 IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_normal_hours                 IN     NUMBER   DEFAULT   hr_api.g_number
  ,p_perf_review_period           IN     NUMBER   DEFAULT   hr_api.g_number
  ,p_perf_review_period_frequency IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_probation_period             IN     NUMBER   DEFAULT   hr_api.g_number
  ,p_probation_unit               IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_sal_review_period            IN     NUMBER   DEFAULT   hr_api.g_number
  ,p_sal_review_period_frequency  IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_set_of_books_id              IN     NUMBER   DEFAULT   hr_api.g_number
  ,p_source_type                  IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_time_normal_finish           IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_time_normal_start            IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_bargaining_unit_code         IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_labour_union_member_flag     IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_hourly_salaried_code         IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_ass_attribute_category       IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_ass_attribute1               IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_ass_attribute2               IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_ass_attribute3               IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_ass_attribute4               IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_ass_attribute5               IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_ass_attribute6               IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_ass_attribute7               IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_ass_attribute8               IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_ass_attribute9               IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_ass_attribute10              IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_ass_attribute11              IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_ass_attribute12              IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_ass_attribute13              IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_ass_attribute14              IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_ass_attribute15              IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_ass_attribute16              IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_ass_attribute17              IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_ass_attribute18              IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_ass_attribute19              IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_ass_attribute20              IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_ass_attribute21              IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_ass_attribute22              IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_ass_attribute23              IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_ass_attribute24              IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_ass_attribute25              IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_ass_attribute26              IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_ass_attribute27              IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_ass_attribute28              IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_ass_attribute29              IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_ass_attribute30              IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_title                        IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_tax_unit                     IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_timecard_approver            IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_timecard_required            IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_work_schedule                IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_gov_emp_sector               IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_ss_salary_type               IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_scl_concat_segments    	  IN 	 VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_concat_segments              IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_contract_id                  IN     NUMBER   DEFAULT   hr_api.g_number
  ,p_establishment_id             IN     NUMBER   DEFAULT   hr_api.g_number
  ,p_collective_agreement_id      IN     NUMBER   DEFAULT   hr_api.g_number
  ,p_cagr_id_flex_num             IN     NUMBER   DEFAULT   hr_api.g_number
  ,p_cag_segment1                 IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_cag_segment2                 IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_cag_segment3                 IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_cag_segment4                 IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_cag_segment5                 IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_cag_segment6                 IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_cag_segment7                 IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_cag_segment8                 IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_cag_segment9                 IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_cag_segment10                IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_cag_segment11                IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_cag_segment12                IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_cag_segment13                IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_cag_segment14                IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_cag_segment15                IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_cag_segment16                IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_cag_segment17                IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_cag_segment18                IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_cag_segment19                IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_cag_segment20                IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_notice_period		  IN     NUMBER   DEFAULT   hr_api.g_number
  ,p_notice_period_uom            IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_employee_category		  IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_work_at_home		  IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_job_post_source_name	  IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_supervisor_assignment_id     IN     NUMBER   DEFAULT   hr_api.g_number
  ,p_ss_leaving_reason            IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_cagr_grade_def_id            IN OUT NOCOPY   NUMBER
  ,p_cagr_concatenated_segments      OUT NOCOPY   VARCHAR2
  ,p_concatenated_segments           OUT NOCOPY   VARCHAR2
  ,p_soft_coding_keyflex_id       IN OUT NOCOPY   NUMBER
  ,p_comment_id                      OUT NOCOPY   NUMBER
  ,p_effective_start_date            OUT NOCOPY   DATE
  ,p_effective_end_date              OUT NOCOPY   DATE
  ,p_no_managers_warning             OUT NOCOPY   BOOLEAN
  ,p_other_manager_warning           OUT NOCOPY   BOOLEAN
  ,p_hourly_salaried_warning         OUT NOCOPY   BOOLEAN
  ,p_gsp_post_process_warning        OUT NOCOPY   VARCHAR2 );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_mx_emp_asg_criteria >--------------------|
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
 *
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
 * @param p_grade_id Identifies the grade of the assignment.
 * @param p_position_id Identifies the position of the assignment.
 * @param p_job_id Identifies the job of the assignment.
 * @param p_payroll_id Identifies the payroll of this assignment.
 * @param p_location_id Identifies the location of the assignment.
 * @param p_organization_id Identifies the organization of the assignment.
 * @param p_pay_basis_id Salary basis for the assignment.
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
 * @param p_concat_segments Concatenated Key Flexfield segments.
 * @param p_contract_id Contract associated with this assignment.
 * @param p_establishment_id For French business groups, this identifies the
 * Establishment Legal Entity for this assignment.
 * @param p_tax_unit Government Reporting Entity.
 * @param p_grade_ladder_pgm_id Grade Ladder for this assignment.
 * @param p_supervisor_assignment_id Supervisor's assignment which is
 * responsible for supervising this assignment.
 * @param p_ss_leaving_reason Social Security Leaving Reason to be specified in
 * case there is a change in the assignment's Government Reporting Entity
 * (GRE).
 * @param p_object_version_number Pass in the current version number of the
 * assignment to be updated. When the API completes if p_validate is false,
 * will be set to the new version number of the updated assignment. If
 * p_validate is true will be set to the same value which was passed in.
 * @param p_special_ceiling_step_id Pass in the highest allowed step for the
 * grade scale associated with the grade of the assignment. Will be set to null
 * if the Grade is updated to null. If p_validate is false, then set to the
 * value of the Ceiling step from the database. If p_validate is true, then set
 * to the value passed in.
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
 * @param p_group_name If p_validate is false, then set to the People Group Key
 * Flexfield concatenated segments. If p_validate is true, then set to null.
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
 * United Kingdom legislation and the payroll has changed to reflect that.
 * Otherwise, set to false.
 * @param p_concatenated_segments If p_validate is false, then set to Soft
 * Coded Key Flexfield concatenated segments. If p_validate is true, then set
 * to null.
 * @param p_gsp_post_process_warning Set to the name of a warning message from
 * the Message Dictionary if any Grade Ladder related errors have been
 * encountered while running this API.
 * @rep:displayname Update Employee Assignment Criteria for Mexico
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE_ASG
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE update_mx_emp_asg_criteria
 (p_effective_date                IN     DATE
  ,p_datetrack_update_mode        IN     VARCHAR2
  ,p_assignment_id                IN     NUMBER
  ,p_validate                     IN     BOOLEAN  DEFAULT FALSE
  ,p_called_from_mass_update      IN     BOOLEAN  DEFAULT FALSE
  ,p_grade_id                     IN     NUMBER   DEFAULT HR_API.G_NUMBER
  ,p_position_id                  IN     NUMBER   DEFAULT HR_API.G_NUMBER
  ,p_job_id                       IN     NUMBER   DEFAULT HR_API.G_NUMBER
  ,p_payroll_id                   IN     NUMBER   DEFAULT HR_API.G_NUMBER
  ,p_location_id                  IN     NUMBER   DEFAULT HR_API.G_NUMBER
  ,p_organization_id              IN     NUMBER   DEFAULT HR_API.G_NUMBER
  ,p_pay_basis_id                 IN     NUMBER   DEFAULT HR_API.G_NUMBER
  ,p_segment1                     IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_segment2                     IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_segment3                     IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_segment4                     IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_segment5                     IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_segment6                     IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_segment7                     IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_segment8                     IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_segment9                     IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_segment10                    IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_segment11                    IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_segment12                    IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_segment13                    IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_segment14                    IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_segment15                    IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_segment16                    IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_segment17                    IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_segment18                    IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_segment19                    IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_segment20                    IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_segment21                    IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_segment22                    IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_segment23                    IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_segment24                    IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_segment25                    IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_segment26                    IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_segment27                    IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_segment28                    IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_segment29                    IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_segment30                    IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_employment_category          IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_concat_segments              IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_contract_id                  IN     NUMBER   DEFAULT HR_API.G_NUMBER
  ,p_establishment_id             IN     NUMBER   DEFAULT HR_API.G_NUMBER
  ,p_tax_unit                     IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_grade_ladder_pgm_id          IN     NUMBER   DEFAULT HR_API.G_NUMBER
  ,p_supervisor_assignment_id     IN     NUMBER   DEFAULT HR_API.G_NUMBER
  ,p_ss_leaving_reason            IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_object_version_number        IN OUT NOCOPY NUMBER
  ,p_special_ceiling_step_id      IN OUT NOCOPY NUMBER
  ,p_people_group_id              IN OUT NOCOPY NUMBER
  ,p_soft_coding_keyflex_id       IN OUT NOCOPY NUMBER
  ,p_group_name                      OUT NOCOPY VARCHAR2
  ,p_effective_start_date            OUT NOCOPY DATE
  ,p_effective_end_date              OUT NOCOPY DATE
  ,p_org_now_no_manager_warning      OUT NOCOPY BOOLEAN
  ,p_other_manager_warning           OUT NOCOPY BOOLEAN
  ,p_spp_delete_warning              OUT NOCOPY BOOLEAN
  ,p_entries_changed_warning         OUT NOCOPY VARCHAR2
  ,p_tax_district_changed_warning    OUT NOCOPY BOOLEAN
  ,p_concatenated_segments           OUT NOCOPY VARCHAR2
  ,p_gsp_post_process_warning        OUT NOCOPY VARCHAR2 );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< mx_final_process_emp_asg >---------------------|
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
 * later than the final process date.Any cost allocations, grade step/point
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
 *
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
 * @param p_ss_leaving_reason Social Security Leaving Reason for the
 * assignment's termination.
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
 * @rep:displayname Final Process Employee Assignment for Mexico
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE_ASG
 * @rep:lifecycle active
 * @rep:scope public
*/
--
-- {End Of Comments}
--
PROCEDURE mx_final_process_emp_asg
  (p_validate                      IN     BOOLEAN  DEFAULT FALSE
  ,p_assignment_id                 IN     NUMBER
  ,p_object_version_number         IN OUT NOCOPY NUMBER
  ,p_final_process_date            IN     DATE
  ,p_ss_leaving_reason             IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_effective_start_date             OUT NOCOPY DATE
  ,p_effective_end_date               OUT NOCOPY DATE
  ,p_org_now_no_manager_warning       OUT NOCOPY BOOLEAN
  ,p_asg_future_changes_warning       OUT NOCOPY BOOLEAN
  ,p_entries_changed_warning          OUT NOCOPY VARCHAR2
  );

END hr_mx_assignment_api ;

 

/
