--------------------------------------------------------
--  DDL for Package HR_SA_ASSIGNMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_SA_ASSIGNMENT_API" AUTHID CURRENT_USER AS
/* $Header: peasgsai.pkh 120.1 2005/10/02 02:11:28 aroussel $ */
/*#
 * This package contains assignment APIs for Saudi Arabia.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Assignment for Saudi Arabia
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_sa_secondary_emp_asg >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a secondary employee assignment for Saudi Arabia.
 *
 * The API calls the generic API create_secondary_emp_asg, with parameters set
 * as appropriate for the Saudi person. As this API is effectively an
 * alternative to the API create_secondary_emp_asg, see that API for further
 * explanation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * See API create_secondary_emp_asg
 *
 * <p><b>Post Success</b><br>
 * The API successfully creates the secondary employee assignment record in the
 * database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the secondary employee assignment record and raises
 * an error.
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
 * @param p_employer Saudi Employer. Valid value are all organizations
 * classified as GRE / Legal Entity.
 * @param p_gosi_num GOSI Number
 * @param p_gosi_annuities Specifies whether GOSI Annuities should be deducted
 * or not. Valid values are defined by the 'YES_NO' lookup type.
 * @param p_annuities_branch_join_date Date of joining the GOSI Annuities
 * branch.
 * @param p_gosi_hazards Specifies whether GOSI Hazards should be deducted or
 * not. Valid values are defined by the 'YES_NO' lookup type.
 * @param p_hazards_branch_join_date Date of joining the GOSI Hazards branch.
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
 * @rep:displayname Create Secondary Employee Assignment for Saudi Arabia
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE_ASG
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE create_sa_secondary_emp_asg
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
  ,p_employer		          IN     VARCHAR2 DEFAULT NULL
  ,p_gosi_num                     IN     VARCHAR2 DEFAULT NULL
  ,p_gosi_annuities               IN     VARCHAR2 DEFAULT NULL
  ,p_annuities_branch_join_date   IN     VARCHAR2 DEFAULT NULL
  ,p_gosi_hazards                 IN     VARCHAR2 DEFAULT NULL
  ,p_hazards_branch_join_date     IN     VARCHAR2 DEFAULT NULL
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
-- |----------------------------< update_sa_emp_asg >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates information for an existing employee assignment in a Saudi
 * Arabia business group.
 *
 * The API calls the generic API update_emp_asg, with parameters set as
 * appropriate for the Saudi employee assignment. As this API is effectively an
 * alternative to the API update_emp_asg, see that API for further explanation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * See API update_emp_asg
 *
 * <p><b>Post Success</b><br>
 * The employee assignment record is successfully updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the employee assignment record and raises an error.
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
 * @param p_employer Saudi Employer. Valid values are all organizations
 * classified as GRE / Legal Entity.
 * @param p_gosi_num GOSI Number
 * @param p_gosi_annuities Specifies whether GOSI Annuities should be deducted
 * or not. Valid values are defined by the 'YES_NO' lookup type.
 * @param p_annuities_branch_join_date Date of joining the GOSI Annuities
 * branch.
 * @param p_gosi_hazards Specifies whether GOSI Hazards should be deducted or
 * not. Valid values are defined by the 'YES_NO' lookup type.
 * @param p_hazards_branch_join_date Date of joining the GOSI Hazards branch.
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
 * @param p_no_managers_warning Set to true if as a result of the update there
 * is no manager in the organization. Otherwise set to false.
 * @param p_other_manager_warning If set to true, then a manager existed in the
 * organization prior to calling this API and the manager flag has been set to
 * 'Y' for yes.
 * @rep:displayname Update Employee Assignment for Saudi Arabia
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE_ASG
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE update_sa_emp_asg
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
  ,p_employer                     IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_gosi_num                     IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_gosi_annuities               IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_annuities_branch_join_date   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_gosi_hazards                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_hazards_branch_join_date     IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_comment_id                      OUT NOCOPY NUMBER
  ,p_soft_coding_keyflex_id          OUT NOCOPY NUMBER
  ,p_effective_start_date            OUT NOCOPY DATE
  ,p_effective_end_date              OUT NOCOPY DATE
  ,p_concatenated_segments           OUT NOCOPY VARCHAR2
  ,p_no_managers_warning             OUT NOCOPY BOOLEAN
  ,p_other_manager_warning           OUT NOCOPY BOOLEAN
  );
END hr_sa_assignment_api;

 

/
