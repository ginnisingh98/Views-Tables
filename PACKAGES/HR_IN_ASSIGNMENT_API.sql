--------------------------------------------------------
--  DDL for Package HR_IN_ASSIGNMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_IN_ASSIGNMENT_API" AUTHID CURRENT_USER AS
/* $Header: peasgini.pkh 120.4 2005/10/20 03:00 abhjain noship $ */
/*#
 * This package contains the assignment APIs.
 * @rep:scope public
 * @rep:product PER
 * @rep:displayname Assignment for India
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_in_secondary_emp_asg >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates secondary employment assignment for an employee.
 *
 * It creates additional non-primary assignments for an existing employee in a
 * IN business Group. It calls create_secondary_emp_asg. You cannot use it to
 * create the primary assignment. The primary assignment is created when you
 * create the employee.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The person (p_person_id) and the organization (p_organization_id) must exist
 * at the effective start date of the assignment (p_effective_date).
 *
 * <p><b>Post Success</b><br>
 * A new secondary assignment is created for the employee.
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
 * secondary assignment. Valid values are defined by 'PER_ASS_SYS_STATUS'
 * lookup type.
 * @param p_payroll_id Identifies the payroll for the secondary assignment.
 * @param p_location_id Identifies the location of the secondary assignment.
 * @param p_supervisor_id Identifies the supervisor for the secondary
 * assignment. The value refers to the supervisor's person record.
 * @param p_special_ceiling_step_id Highest allowed step for the grade scale
 * associated with the grade of the secondary assignment.
 * @param p_pay_basis_id Salary basis for the secondary assignment.
 * @param p_assignment_number If p_validate is false then the parameter value
 * passed is used as the assignment number. If no value is passed then the
 * assignment number is generated. If p_validate is true null is returned.
 * @param p_change_reason Reason for the assignment status change. If there is
 * no change reason the parameter can be null. Valid values are defined in the
 * 'EMP_ASSIGN_REASON' lookup type.
 * @param p_comments Comment text.
 * @param p_date_probation_end End date of probation period.
 * @param p_default_code_comb_id Identifier for the General Ledger Accounting
 * Flexfield combination that applies to this assignment.
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
 * is salaried. Valid values are defined in the 'HOURLY_SALARIED_CODE' lookup
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
 * @param p_gre_legal_entity GRE or Legal Entity
 * @param p_pf_organization PF Organization
 * @param p_prof_tax_organization Professional Tax Organization
 * @param p_esi_organization ESI Organization
 * @param p_factory Factory
 * @param p_establishment Establishment
 * @param p_covered_by_gratuity_act Covered by Gratuity act flag. Valid values
 * are defined by 'YES_NO' lookup type
 * @param p_having_substantial_interest Having substantial interest flag.Valid
 * values are defined by 'YES_NO' lookup type
 * @param p_director Director flag. Valid values are defined by 'YES_NO' lookup
 * type
 * @param p_specified Specified Employee flag. Valid values are defined by
 * 'YES_NO' lookup type.
 * @param p_scl_concat_segments Concatenated segments for Soft Coded Key
 * Flexfield. Concatenated segments can be supplied instead of individual
 * segments.
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
 * @param p_contract_id Contract associated with this assignment.
 * @param p_establishment_id This identifies the establishment Legal Entity for
 * this assignment.
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
 * in the 'QUALIFYING_UNITS' lookup type.
 * @param p_employee_category Employee Category of the assignment. Valid values
 * are defined in the 'EMPLOYEE_CATG' lookup type.
 * @param p_work_at_home Indicate whether this assignment is to work at home.
 * Valid values are defined in the 'YES_NO' lookup type.
 * @param p_job_post_source_name The source of the job posting that was
 * answered for this assignment.
 * @param p_grade_ladder_pgm_id Grade Ladder for this assignment.
 * @param p_supervisor_assignment_id Supervisor's assignment identification
 * that is responsible for supervising this assignment.
 * @param p_group_name If p_validate is false, set to the People Group Key
 * Flexfield concatenated segments. If p_validate is true, set to null.
 * @param p_concatenated_segments If p_validate is false, set to Soft Coded Key
 * Flexfield concatenated segments, if p_validate is true, set to null.
 * @param p_cagr_grade_def_id If a value is passed in for this parameter, it
 * identifies an existing CAGR Key Flexfield combination to associate with the
 * assignment, and the segment values are ignored. If a value is not passed in,
 * then the individual CAGR Key Flexfield segments supplied will be used to
 * choose an existing combination or create a new combination. When the API
 * completes, if p_validate is false, then this uniquely identifies the
 * associated combination of the CAGR Key flexfield for this assignment. If
 * p_validate is true, then set to null.
 * @param p_cagr_concatenated_segments If p_validate is false CAGR Key
 * Flexfield concatenated segments is generated. If p_validate is true, it is
 * set to null.
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
 * number of assignment which already exist. If p_validate is true then set to
 * null.
 * @param p_comment_id If p_validate is false and comment text was provided,
 * then will be set to the identifier of the created secondary assignment
 * comment record. If p_validate is true or no comment text was provided, then
 * will be null.
 * @param p_other_manager_warning If set to true, then a manager existed in the
 * organization prior to calling this API and the manager flag has been set to
 * 'Y' for yes.
 * @param p_hourly_salaried_warning Set to true if combination values entered
 * for pay_basis and hourly_salaried_code are invalid date p_effective_date.
 * @param p_gsp_post_process_warning Warning message name from
 * pqh_gsp_post_process.
 * @rep:displayname Create Secondary Employee Assignment for India
 * @rep:category BUSINESS_ENTITY PER_CWK_ASG
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE create_in_secondary_emp_asg
(p_validate                     IN     BOOLEAN   DEFAULT   false
,p_effective_date               IN     DATE
,p_person_id                    IN     NUMBER
,p_organization_id              IN     NUMBER
,p_grade_id                     IN     NUMBER    DEFAULT   null
,p_position_id                  IN     NUMBER    DEFAULT   null
,p_job_id                       IN     NUMBER    DEFAULT   null
,p_assignment_status_type_id    IN     NUMBER    DEFAULT   null
,p_payroll_id                   IN     NUMBER    DEFAULT   null
,p_location_id                  IN     NUMBER    DEFAULT   null
,p_supervisor_id                IN     NUMBER    DEFAULT   null
,p_special_ceiling_step_id      IN     NUMBER    DEFAULT   null
,p_pay_basis_id                 IN     NUMBER    DEFAULT   null
,p_assignment_number            IN OUT NOCOPY    VARCHAR2
,p_change_reason                IN     VARCHAR2  DEFAULT   null
,p_comments                     IN     VARCHAR2  DEFAULT   null
,p_date_probation_end           IN     DATE      DEFAULT   null
,p_default_code_comb_id         IN     NUMBER    DEFAULT   null
,p_employment_category          IN     VARCHAR2  DEFAULT   null
,p_frequency                    IN     VARCHAR2  DEFAULT   null
,p_internal_address_line        IN     VARCHAR2  DEFAULT   null
,p_manager_flag                 IN     VARCHAR2  DEFAULT   null
,p_normal_hours                 IN     NUMBER    DEFAULT   null
,p_perf_review_period           IN     NUMBER    DEFAULT   null
,p_perf_review_period_frequency IN     VARCHAR2  DEFAULT   null
,p_probation_period             IN     NUMBER    DEFAULT   null
,p_probation_unit               IN     VARCHAR2  DEFAULT   null
,p_sal_review_period            IN     NUMBER    DEFAULT   null
,p_sal_review_period_frequency  IN     VARCHAR2  DEFAULT   null
,p_set_of_books_id              IN     NUMBER    DEFAULT   null
,p_source_type                  IN     VARCHAR2  DEFAULT   null
,p_time_normal_finish           IN     VARCHAR2  DEFAULT   null
,p_time_normal_start            IN     VARCHAR2  DEFAULT   null
,p_bargaining_unit_code         IN     VARCHAR2  DEFAULT   null
,p_labour_union_member_flag     IN     VARCHAR2  DEFAULT   null
,p_hourly_salaried_code         IN     VARCHAR2  DEFAULT   null
,p_ass_attribute_category       IN     VARCHAR2  DEFAULT   null
,p_ass_attribute1               IN     VARCHAR2  DEFAULT   null
,p_ass_attribute2               IN     VARCHAR2  DEFAULT   null
,p_ass_attribute3               IN     VARCHAR2  DEFAULT   null
,p_ass_attribute4               IN     VARCHAR2  DEFAULT   null
,p_ass_attribute5               IN     VARCHAR2  DEFAULT   null
,p_ass_attribute6               IN     VARCHAR2  DEFAULT   null
,p_ass_attribute7               IN     VARCHAR2  DEFAULT   null
,p_ass_attribute8               IN     VARCHAR2  DEFAULT   null
,p_ass_attribute9               IN     VARCHAR2  DEFAULT   null
,p_ass_attribute10              IN     VARCHAR2  DEFAULT   null
,p_ass_attribute11              IN     VARCHAR2  DEFAULT   null
,p_ass_attribute12              IN     VARCHAR2  DEFAULT   null
,p_ass_attribute13              IN     VARCHAR2  DEFAULT   null
,p_ass_attribute14              IN     VARCHAR2  DEFAULT   null
,p_ass_attribute15              IN     VARCHAR2  DEFAULT   null
,p_ass_attribute16              IN     VARCHAR2  DEFAULT   null
,p_ass_attribute17              IN     VARCHAR2  DEFAULT   null
,p_ass_attribute18              IN     VARCHAR2  DEFAULT   null
,p_ass_attribute19              IN     VARCHAR2  DEFAULT   null
,p_ass_attribute20              IN     VARCHAR2  DEFAULT   null
,p_ass_attribute21              IN     VARCHAR2  DEFAULT   null
,p_ass_attribute22              IN     VARCHAR2  DEFAULT   null
,p_ass_attribute23              IN     VARCHAR2  DEFAULT   null
,p_ass_attribute24              IN     VARCHAR2  DEFAULT   null
,p_ass_attribute25              IN     VARCHAR2  DEFAULT   null
,p_ass_attribute26              IN     VARCHAR2  DEFAULT   null
,p_ass_attribute27              IN     VARCHAR2  DEFAULT   null
,p_ass_attribute28              IN     VARCHAR2  DEFAULT   null
,p_ass_attribute29              IN     VARCHAR2  DEFAULT   null
,p_ass_attribute30              IN     VARCHAR2  DEFAULT   null
,p_title                        IN     VARCHAR2  DEFAULT   null
,p_gre_legal_entity             IN     VARCHAR2
,p_pf_organization              IN     VARCHAR2  DEFAULT   null
,p_prof_tax_organization        IN     VARCHAR2  DEFAULT   null
,p_esi_organization             IN     VARCHAR2  DEFAULT   null
,p_factory                      IN     VARCHAR2  DEFAULT   null
,p_establishment                IN     VARCHAR2  DEFAULT   null
,p_covered_by_gratuity_act      IN     VARCHAR2  DEFAULT   'N'
,p_having_substantial_interest  IN     VARCHAR2  DEFAULT   'N'
,p_director                     IN     VARCHAR2  DEFAULT   'N'
,p_specified                    IN     VARCHAR2  DEFAULT   'Y'
,p_scl_concat_segments          IN     VARCHAR2  DEFAULT   null
,p_pgp_segment1                 IN     VARCHAR2  DEFAULT   null
,p_pgp_segment2                 IN     VARCHAR2  DEFAULT   null
,p_pgp_segment3                 IN     VARCHAR2  DEFAULT   null
,p_pgp_segment4                 IN     VARCHAR2  DEFAULT   null
,p_pgp_segment5                 IN     VARCHAR2  DEFAULT   null
,p_pgp_segment6                 IN     VARCHAR2  DEFAULT   null
,p_pgp_segment7                 IN     VARCHAR2  DEFAULT   null
,p_pgp_segment8                 IN     VARCHAR2  DEFAULT   null
,p_pgp_segment9                 IN     VARCHAR2  DEFAULT   null
,p_pgp_segment10                IN     VARCHAR2  DEFAULT   null
,p_pgp_segment11                IN     VARCHAR2  DEFAULT   null
,p_pgp_segment12                IN     VARCHAR2  DEFAULT   null
,p_pgp_segment13                IN     VARCHAR2  DEFAULT   null
,p_pgp_segment14                IN     VARCHAR2  DEFAULT   null
,p_pgp_segment15                IN     VARCHAR2  DEFAULT   null
,p_pgp_segment16                IN     VARCHAR2  DEFAULT   null
,p_pgp_segment17                IN     VARCHAR2  DEFAULT   null
,p_pgp_segment18                IN     VARCHAR2  DEFAULT   null
,p_pgp_segment19                IN     VARCHAR2  DEFAULT   null
,p_pgp_segment20                IN     VARCHAR2  DEFAULT   null
,p_pgp_segment21                IN     VARCHAR2  DEFAULT   null
,p_pgp_segment22                IN     VARCHAR2  DEFAULT   null
,p_pgp_segment23                IN     VARCHAR2  DEFAULT   null
,p_pgp_segment24                IN     VARCHAR2  DEFAULT   null
,p_pgp_segment25                IN     VARCHAR2  DEFAULT   null
,p_pgp_segment26                IN     VARCHAR2  DEFAULT   null
,p_pgp_segment27                IN     VARCHAR2  DEFAULT   null
,p_pgp_segment28                IN     VARCHAR2  DEFAULT   null
,p_pgp_segment29                IN     VARCHAR2  DEFAULT   null
,p_pgp_segment30                IN     VARCHAR2  DEFAULT   null
,p_pgp_concat_segments          IN     VARCHAR2  DEFAULT   null
,p_contract_id                  IN     NUMBER    DEFAULT   null
,p_establishment_id             IN     NUMBER    DEFAULT   null
,p_collective_agreement_id      IN     NUMBER    DEFAULT   null
,p_cagr_id_flex_num             IN     NUMBER    DEFAULT   null
,p_cag_segment1                 IN     VARCHAR2  DEFAULT   null
,p_cag_segment2                 IN     VARCHAR2  DEFAULT   null
,p_cag_segment3                 IN     VARCHAR2  DEFAULT   null
,p_cag_segment4                 IN     VARCHAR2  DEFAULT   null
,p_cag_segment5                 IN     VARCHAR2  DEFAULT   null
,p_cag_segment6                 IN     VARCHAR2  DEFAULT   null
,p_cag_segment7                 IN     VARCHAR2  DEFAULT   null
,p_cag_segment8                 IN     VARCHAR2  DEFAULT   null
,p_cag_segment9                 IN     VARCHAR2  DEFAULT   null
,p_cag_segment10                IN     VARCHAR2  DEFAULT   null
,p_cag_segment11                IN     VARCHAR2  DEFAULT   null
,p_cag_segment12                IN     VARCHAR2  DEFAULT   null
,p_cag_segment13                IN     VARCHAR2  DEFAULT   null
,p_cag_segment14                IN     VARCHAR2  DEFAULT   null
,p_cag_segment15                IN     VARCHAR2  DEFAULT   null
,p_cag_segment16                IN     VARCHAR2  DEFAULT   null
,p_cag_segment17                IN     VARCHAR2  DEFAULT   null
,p_cag_segment18                IN     VARCHAR2  DEFAULT   null
,p_cag_segment19                IN     VARCHAR2  DEFAULT   null
,p_cag_segment20                IN     VARCHAR2  DEFAULT   null
,p_notice_period                IN     NUMBER    DEFAULT   null
,p_notice_period_uom            IN     VARCHAR2  DEFAULT   null
,p_employee_category            IN     VARCHAR2  DEFAULT   null
,p_work_at_home                 IN     VARCHAR2  DEFAULT   null
,p_job_post_source_name         IN     VARCHAR2  DEFAULT   null
,p_grade_ladder_pgm_id          IN     NUMBER    DEFAULT   null
,p_supervisor_assignment_id     IN     NUMBER    DEFAULT   null
,p_group_name                      OUT NOCOPY VARCHAR2
,p_concatenated_segments           OUT NOCOPY VARCHAR2
,p_cagr_grade_def_id            IN OUT NOCOPY NUMBER
,p_cagr_concatenated_segments   OUT NOCOPY VARCHAR2
,p_assignment_id                OUT NOCOPY NUMBER
,p_soft_coding_keyflex_id       IN OUT NOCOPY NUMBER
,p_people_group_id              IN OUT NOCOPY NUMBER
,p_object_version_number           OUT NOCOPY NUMBER
,p_effective_start_date            OUT NOCOPY DATE
,p_effective_end_date              OUT NOCOPY DATE
,p_assignment_sequence             OUT NOCOPY NUMBER
,p_comment_id                      OUT NOCOPY NUMBER
,p_other_manager_warning           OUT NOCOPY BOOLEAN
,p_hourly_salaried_warning         OUT NOCOPY BOOLEAN
,p_gsp_post_process_warning        OUT NOCOPY VARCHAR2);
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_in_emp_asg >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates employment assignment for an employee.
 *
 * It updates information for an existing employee assignment with a IN
 * legislation. It calls the generic API update_emp_asg, with parameters set as
 * appropriate for a IN employee assignment.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The assignment (p_assignment_id) must exist as of the effective date of the
 * update (p_effective_date).
 *
 * <p><b>Post Success</b><br>
 * Updates the assignment of the employee.
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
 * @param p_assignment_status_type_id Assignment status. The system status must
 * be the same as before the update, otherwise one of the status change APIs
 * should be used.
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
 * @param p_labour_union_member_flag Indicates whether the employee is a labor
 * union member. Value 'Y' indicates employee is a labor union member.
 * @param p_hourly_salaried_code Identifies if the assignment is paid hourly or
 * is salaried. Valid values defined in the 'HOURLY_SALARIED_CODE' lookup type.
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
 * @param p_gre_legal_entity Obsolete parameter, do not use.
 * @param p_pf_organization PF Organization
 * @param p_prof_tax_organization Professional Tax Organization
 * @param p_esi_organization ESI Organization
 * @param p_factory Factory
 * @param p_establishment Establishment
 * @param p_covered_by_gratuity_act Covered by Gratuity act flag. Valid values
 * are defined by 'YES_NO' lookup type.
 * @param p_having_substantial_interest Having substantial interest flag.Valid
 * values are defined by 'YES_NO' lookup type.
 * @param p_director Director flag. Valid values are defined by 'YES_NO' lookup
 * type.
 * @param p_specified Specified Employee flag. Valid values are defined by
 * 'YES_NO' lookup type.
 * @param p_concat_segments Concatenated segments for Soft Coded Key Flexfield.
 * Concatenated segments can be supplied instead of individual segments.
 * @param p_contract_id Contract associated with this assignment.
 * @param p_establishment_id This identifies the establishment Legal Entity for
 * this assignment.
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
 * in the 'QUALIFYING_UNITS' lookup type.
 * @param p_employee_category Employee Category of the assignment. Valid values
 * are defined in the 'EMPLOYEE_CATG' lookup type.
 * @param p_work_at_home Indicates whether this assignment is to work at home.
 * Valid values are defined in the 'YES_NO' lookup type.
 * @param p_job_post_source_name Name of the source of the job posting that was
 * answered for this assignment.
 * @param p_supervisor_assignment_id Supervisor's assignment identification
 * that is responsible for supervising this assignment.
 * @param p_cagr_grade_def_id If a value is passed in for this parameter, it
 * identifies an existing CAGR Key Flexfield combination to associate with the
 * assignment, and the segment values are ignored. If a value is not passed in,
 * then the individual CAGR Key Flexfield segments supplied will be used to
 * choose an existing combination or create a new combination. When the API
 * completes, if p_validate is false, then this uniquely identifies the
 * associated combination of the CAGR Key flexfield for this assignment. If
 * p_validate is true, then set to null.
 * @param p_cagr_concatenated_segments If p_validate is false CAGR Key
 * Flexfield concatenated segments is generated. If p_validate is true, it is
 * set to null.
 * @param p_concatenated_segments If p_validate is false, set to Soft Coded Key
 * Flexfield concatenated segments, if p_validate is true, set to null.
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
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated assignment row which now exists as of
 * the effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated assignment row which now exists as of the
 * effective date. If p_validate is true, then set to null.
 * @param p_no_managers_warning Set to true if as a result of the update there
 * is no manager in the organization. Otherwise set to false.
 * @param p_other_manager_warning If set to true, then a manager existed in the
 * organization prior to calling this API and the manager flag has been set to
 * 'Y' for yes.
 * @param p_hourly_salaried_warning Set to true if values entered for Salary
 * Basis and Hourly Salaried Code are invalid as of the effective date.
 * @param p_gsp_post_process_warning Set to the name of the warning message
 * from the Message Dictionary if any Grade Ladder related errors have been
 * encountered while running this API.
 * @rep:displayname Update Employee Assignment for India
 * @rep:category BUSINESS_ENTITY PER_CWK_ASG
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE update_in_emp_asg
  (p_validate                     IN     BOOLEAN  DEFAULT FALSE
  ,p_effective_date               IN     DATE
  ,p_datetrack_update_mode        IN     VARCHAR2
  ,p_assignment_id                IN     NUMBER
  ,p_object_version_number        IN OUT NOCOPY NUMBER
  ,p_supervisor_id                IN     NUMBER   DEFAULT HR_API.G_NUMBER
  ,p_assignment_number            IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_change_reason                IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_assignment_status_type_id    IN     NUMBER   DEFAULT HR_API.G_NUMBER
  ,p_comments                     IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_date_probation_end           IN     DATE     DEFAULT HR_API.G_DATE
  ,p_default_code_comb_id         IN     NUMBER   DEFAULT HR_API.G_NUMBER
  ,p_frequency                    IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_internal_address_line        IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_manager_flag                 IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_normal_hours                 IN     NUMBER   DEFAULT HR_API.G_NUMBER
  ,p_perf_review_period           IN     NUMBER   DEFAULT HR_API.G_NUMBER
  ,p_perf_review_period_frequency IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_probation_period             IN     NUMBER   DEFAULT HR_API.G_NUMBER
  ,p_probation_unit               IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_sal_review_period            IN     NUMBER   DEFAULT HR_API.G_NUMBER
  ,p_sal_review_period_frequency  IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_set_of_books_id              IN     NUMBER   DEFAULT HR_API.G_NUMBER
  ,p_source_type                  IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_time_normal_finish           IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_time_normal_start            IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_bargaining_unit_code         IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_labour_union_member_flag     IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_hourly_salaried_code         IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_ass_attribute_category       IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_ass_attribute1               IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_ass_attribute2               IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_ass_attribute3               IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_ass_attribute4               IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_ass_attribute5               IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_ass_attribute6               IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_ass_attribute7               IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_ass_attribute8               IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_ass_attribute9               IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_ass_attribute10              IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_ass_attribute11              IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_ass_attribute12              IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_ass_attribute13              IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_ass_attribute14              IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_ass_attribute15              IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_ass_attribute16              IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_ass_attribute17              IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_ass_attribute18              IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_ass_attribute19              IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_ass_attribute20              IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_ass_attribute21              IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_ass_attribute22              IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_ass_attribute23              IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_ass_attribute24              IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_ass_attribute25              IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_ass_attribute26              IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_ass_attribute27              IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_ass_attribute28              IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_ass_attribute29              IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_ass_attribute30              IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_title                        IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_gre_legal_entity             IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_pf_organization              IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_prof_tax_organization        IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_esi_organization             IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_factory                      IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_establishment                IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_covered_by_gratuity_act      IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_having_substantial_interest  IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_director                     IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_specified                    IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_concat_segments              IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_contract_id                  IN     NUMBER DEFAULT HR_API.G_NUMBER
  ,p_establishment_id             IN     NUMBER DEFAULT HR_API.G_NUMBER
  ,p_collective_agreement_id      IN     NUMBER DEFAULT HR_API.G_NUMBER
  ,p_cagr_id_flex_num             IN     NUMBER DEFAULT HR_API.G_NUMBER
  ,p_cag_segment1                 IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_cag_segment2                 IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_cag_segment3                 IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_cag_segment4                 IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_cag_segment5                 IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_cag_segment6                 IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_cag_segment7                 IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_cag_segment8                 IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_cag_segment9                 IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_cag_segment10                IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_cag_segment11                IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_cag_segment12                IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_cag_segment13                IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_cag_segment14                IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_cag_segment15                IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_cag_segment16                IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_cag_segment17                IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_cag_segment18                IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_cag_segment19                IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_cag_segment20                IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_notice_period                IN     NUMBER   DEFAULT HR_API.G_NUMBER
  ,p_notice_period_uom            IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_employee_category            IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_work_at_home                 IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_job_post_source_name         IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_supervisor_assignment_id     IN     NUMBER   DEFAULT HR_API.G_NUMBER
  ,p_cagr_grade_def_id            IN OUT NOCOPY NUMBER
  ,p_cagr_concatenated_segments      OUT NOCOPY VARCHAR2
  ,p_concatenated_segments           OUT NOCOPY VARCHAR2
  ,p_soft_coding_keyflex_id       IN OUT NOCOPY NUMBER
  ,p_comment_id                      OUT NOCOPY NUMBER
  ,p_effective_start_date            OUT NOCOPY DATE
  ,p_effective_end_date              OUT NOCOPY DATE
  ,p_no_managers_warning             OUT NOCOPY BOOLEAN
  ,p_other_manager_warning           OUT NOCOPY BOOLEAN
  ,p_hourly_salaried_warning         OUT NOCOPY BOOLEAN
  ,p_gsp_post_process_warning        OUT NOCOPY VARCHAR2
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_in_secondary_cwk_asg >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a secondary contingent worker assignment.
 *
 * This API creates additional non-primary assignments for an existing
 * contingent worker in a IN business Group.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The business group (p_business_group_id) and the organization
 * (p_organization_id) must exist at the effective start date of the assignment
 * (p_effective_date).
 *
 * <p><b>Post Success</b><br>
 * A new secondary assignment is created for the contingent worker.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the assignment and raises an error.
 *
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_business_group_id Identifier for the Business Group.
 * @param p_person_id Identifies the person for whom you create the secondary
 * contingent worker assignment record.
 * @param p_organization_id Identifies the organization of the secondary
 * assignment.
 * @param p_assignment_number Unique ID for the assignment created by the API
 * @param p_assignment_category Assignment Category.
 * @param p_assignment_status_type_id Identifies the assignment status of the
 * secondary assignment. Valid values are defined by 'PER_ASS_SYS_STATUS'
 * lookup type.
 * @param p_change_reason Reason for the assignment status change. If there is
 * no change reason the parameter can be null. Valid values are defined in the
 * 'EMP_ASSIGN_REASON' lookup type. If there is no change reason please
 * explicitly set this to null (else there is a risk of inadvertantly recording
 * promotions).
 * @param p_comments Comment text.
 * @param p_default_code_comb_id Identifier for the General Ledger Accounting
 * Flexfield combination that applies to this assignment.
 * @param p_establishment_id This identifies the establishment Legal Entity for
 * this secondary contingent worker assignment.
 * @param p_frequency Frequency for quoting working hours (eg per week).
 * @param p_internal_address_line Internal address line.
 * @param p_job_id Identifies the job of the secondary contingent worker
 * assignment.
 * @param p_labour_union_member_flag Indicates whether the employee is a labour
 * union member. A value 'Y' indicates that the employee is a labour union
 * member.
 * @param p_location_id Identifies the location of the secondary contingent
 * worker assignment.
 * @param p_manager_flag Indicates whether the employee is a manager.
 * @param p_normal_hours Normal working hours.
 * @param p_position_id Identifies the position of the secondary contingent
 * worker assignment.
 * @param p_grade_id Identifies the grade of the secondary contingent worker
 * assignment.
 * @param p_project_title Project title.
 * @param p_set_of_books_id Set of books (GL).
 * @param p_source_type Recruitment activity which this assignment is sourced
 * from. Valid values are defined in the 'REC_TYPE' lookup type.
 * @param p_supervisor_id Identifies the supervisor for the secondary
 * contingent worker assignment. The value refers to the supervisor's person
 * record.
 * @param p_time_normal_finish Normal work finish time.
 * @param p_time_normal_start Normal work start time.
 * @param p_title Obsolete parameter, do not use.
 * @param p_vendor_assignment_number Supplier's assignment number
 * @param p_vendor_employee_number Supplier's employee number
 * @param p_vendor_id Supplier of assignment.
 * @param p_vendor_site_id Supplier site of assignment.
 * @param p_po_header_id Assignment purchase order reference.
 * @param p_po_line_id Assignment purchase order line.
 * @param p_projected_assignment_end Projected end of assignment Reserved for
 * future use.
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
 * @param p_attribute21 Descriptive flexfield segment.
 * @param p_attribute22 Descriptive flexfield segment.
 * @param p_attribute23 Descriptive flexfield segment.
 * @param p_attribute24 Descriptive flexfield segment.
 * @param p_attribute25 Descriptive flexfield segment.
 * @param p_attribute26 Descriptive flexfield segment.
 * @param p_attribute27 Descriptive flexfield segment.
 * @param p_attribute28 Descriptive flexfield segment.
 * @param p_attribute29 Descriptive flexfield segment.
 * @param p_attribute30 Descriptive flexfield segment.
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
 * @param p_scl_contractor_name Contractor's Name.
 * @param p_scl_concat_segments Concatenated segments for Soft Coded Key
 * Flexfield. Concatenated segments can be supplied instead of individual
 * segments.
 * @param p_pgp_concat_segments Concatenated segments for People Group Key
 * Flexfield. Concatenated segments can be supplied instead of individual
 * segments.
 * @param p_supervisor_assignment_id Supervisor's assignment identification
 * that is responsible for supervising this assignment.
 * @param p_assignment_id If p_validate is false, then this uniquely identifies
 * the created secondary contingent worker assignment. If p_validate is true,
 * then set to null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created secondary contingent worker assignment. If
 * p_validate is true, then the value will be null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created secondary contingent worker
 * assignment. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created secondary contingent worker assignment.
 * If p_validate is true, then set to null.
 * @param p_assignment_sequence If p_validate is false, then an automatically
 * incremented number is associated with this secondary contingent worker
 * assignment, depending on the number of assignment which already exist. If
 * p_validate is true then set to null.
 * @param p_comment_id If p_validate is false and comment text was provided,
 * then will be set to the identifier of the created secondary contingent
 * worker assignment comment record. If p_validate is true or no comment text
 * was provided, then will be null.
 * @param p_people_group_id If a value is passed in for this parameter, it
 * identifies an existing People Group Key Flexfield combination to associate
 * with the secondary contingent worker assignment, and segment values are
 * ignored. If a value is not passed in, then the individual People Group Key
 * Flexfield segments supplied will be used to choose an existing combination
 * or create a new combination. When the API completes, if p_validate is false,
 * then this uniquely identifies the associated combination of the People Group
 * Key flexfield for this secondary contingent worker assignment. If p_validate
 * is true, then set to null.
 * @param p_people_group_name If p_validate is false, set to the People Group
 * Name concatenated segments. If p_validate is true, set to null.
 * @param p_other_manager_warning If set to true, then a manager existed in the
 * organization prior to calling this API and the manager flag has been set to
 * 'Y' for yes.
 * @param p_hourly_salaried_warning Set to true if values entered for Salary
 * Basis and Hourly Salaried Code are invalid as of p_effective_date.
 * @param p_soft_coding_keyflex_id If a value is passed in for this parameter,
 * it identifies an existing Soft Coded Key Flexfield combination to associate
 * with the secondary contingent worker assignment, and segment values are
 * ignored. If a value is not passed in, then the individual Soft Coded Key
 * Flexfield segments supplied will be used to choose an existing combination
 * or create a new combination. When the API completes, if p_validate is false,
 * then this uniquely identifies the associated combination of the Soft Coded
 * Key flexfield for this secondary contingent worker assignment. If p_validate
 * is true, then set to null.
 * @rep:displayname Create Secondary Contingent Worker Assignment for India
 * @rep:category BUSINESS_ENTITY PER_CWK_ASG
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE create_in_secondary_cwk_asg
  (p_validate                     IN     BOOLEAN  DEFAULT false
  ,p_effective_date               IN     DATE
  ,p_business_group_id            IN     NUMBER
  ,p_person_id                    IN     NUMBER
  ,p_organization_id              IN     NUMBER
  ,p_assignment_number            IN OUT NOCOPY VARCHAR2
  ,p_assignment_category          IN     VARCHAR2 DEFAULT null
  ,p_assignment_status_type_id    IN     NUMBER   DEFAULT null
  ,p_change_reason                IN     VARCHAR2 DEFAULT null
  ,p_comments                     IN     VARCHAR2 DEFAULT null
  ,p_default_code_comb_id         IN     NUMBER   DEFAULT null
  ,p_establishment_id             IN     NUMBER   DEFAULT null
  ,p_frequency                    IN     VARCHAR2 DEFAULT null
  ,p_internal_address_line        IN     VARCHAR2 DEFAULT null
  ,p_job_id                       IN     NUMBER   DEFAULT null
  ,p_labour_union_member_flag     IN     VARCHAR2 DEFAULT 'N'
  ,p_location_id                  IN     NUMBER   DEFAULT null
  ,p_manager_flag                 IN     VARCHAR2 DEFAULT null
  ,p_normal_hours                 IN     NUMBER   DEFAULT null
  ,p_position_id                  IN     NUMBER   DEFAULT null
  ,p_grade_id                     IN     NUMBER   DEFAULT null
  ,p_project_title                IN     VARCHAR2 DEFAULT null
  ,p_set_of_books_id              IN     NUMBER   DEFAULT null
  ,p_source_type                  IN     VARCHAR2 DEFAULT null
  ,p_supervisor_id                IN     NUMBER   DEFAULT null
  ,p_time_normal_finish           IN     VARCHAR2 DEFAULT null
  ,p_time_normal_start            IN     VARCHAR2 DEFAULT null
  ,p_title                        IN     VARCHAR2 DEFAULT null
  ,p_vendor_assignment_number     IN     VARCHAR2 DEFAULT null
  ,p_vendor_employee_number       IN     VARCHAR2 DEFAULT null
  ,p_vendor_id                    IN     NUMBER   DEFAULT null
  ,p_vendor_site_id               IN     NUMBER   DEFAULT null
  ,p_po_header_id                 IN     NUMBER   DEFAULT null
  ,p_po_line_id                   IN     NUMBER   DEFAULT null
  ,p_projected_assignment_end     IN     DATE     DEFAULT null
  ,p_attribute_category           IN     VARCHAR2 DEFAULT null
  ,p_attribute1                   IN     VARCHAR2 DEFAULT null
  ,p_attribute2                   IN     VARCHAR2 DEFAULT null
  ,p_attribute3                   IN     VARCHAR2 DEFAULT null
  ,p_attribute4                   IN     VARCHAR2 DEFAULT null
  ,p_attribute5                   IN     VARCHAR2 DEFAULT null
  ,p_attribute6                   IN     VARCHAR2 DEFAULT null
  ,p_attribute7                   IN     VARCHAR2 DEFAULT null
  ,p_attribute8                   IN     VARCHAR2 DEFAULT null
  ,p_attribute9                   IN     VARCHAR2 DEFAULT null
  ,p_attribute10                  IN     VARCHAR2 DEFAULT null
  ,p_attribute11                  IN     VARCHAR2 DEFAULT null
  ,p_attribute12                  IN     VARCHAR2 DEFAULT null
  ,p_attribute13                  IN     VARCHAR2 DEFAULT null
  ,p_attribute14                  IN     VARCHAR2 DEFAULT null
  ,p_attribute15                  IN     VARCHAR2 DEFAULT null
  ,p_attribute16                  IN     VARCHAR2 DEFAULT null
  ,p_attribute17                  IN     VARCHAR2 DEFAULT null
  ,p_attribute18                  IN     VARCHAR2 DEFAULT null
  ,p_attribute19                  IN     VARCHAR2 DEFAULT null
  ,p_attribute20                  IN     VARCHAR2 DEFAULT null
  ,p_attribute21                  IN     VARCHAR2 DEFAULT null
  ,p_attribute22                  IN     VARCHAR2 DEFAULT null
  ,p_attribute23                  IN     VARCHAR2 DEFAULT null
  ,p_attribute24                  IN     VARCHAR2 DEFAULT null
  ,p_attribute25                  IN     VARCHAR2 DEFAULT null
  ,p_attribute26                  IN     VARCHAR2 DEFAULT null
  ,p_attribute27                  IN     VARCHAR2 DEFAULT null
  ,p_attribute28                  IN     VARCHAR2 DEFAULT null
  ,p_attribute29                  IN     VARCHAR2 DEFAULT null
  ,p_attribute30                  IN     VARCHAR2 DEFAULT null
  ,p_pgp_segment1                 IN     VARCHAR2 DEFAULT null
  ,p_pgp_segment2                 IN     VARCHAR2 DEFAULT null
  ,p_pgp_segment3                 IN     VARCHAR2 DEFAULT null
  ,p_pgp_segment4                 IN     VARCHAR2 DEFAULT null
  ,p_pgp_segment5                 IN     VARCHAR2 DEFAULT null
  ,p_pgp_segment6                 IN     VARCHAR2 DEFAULT null
  ,p_pgp_segment7                 IN     VARCHAR2 DEFAULT null
  ,p_pgp_segment8                 IN     VARCHAR2 DEFAULT null
  ,p_pgp_segment9                 IN     VARCHAR2 DEFAULT null
  ,p_pgp_segment10                IN     VARCHAR2 DEFAULT null
  ,p_pgp_segment11                IN     VARCHAR2 DEFAULT null
  ,p_pgp_segment12                IN     VARCHAR2 DEFAULT null
  ,p_pgp_segment13                IN     VARCHAR2 DEFAULT null
  ,p_pgp_segment14                IN     VARCHAR2 DEFAULT null
  ,p_pgp_segment15                IN     VARCHAR2 DEFAULT null
  ,p_pgp_segment16                IN     VARCHAR2 DEFAULT null
  ,p_pgp_segment17                IN     VARCHAR2 DEFAULT null
  ,p_pgp_segment18                IN     VARCHAR2 DEFAULT null
  ,p_pgp_segment19                IN     VARCHAR2 DEFAULT null
  ,p_pgp_segment20                IN     VARCHAR2 DEFAULT null
  ,p_pgp_segment21                IN     VARCHAR2 DEFAULT null
  ,p_pgp_segment22                IN     VARCHAR2 DEFAULT null
  ,p_pgp_segment23                IN     VARCHAR2 DEFAULT null
  ,p_pgp_segment24                IN     VARCHAR2 DEFAULT null
  ,p_pgp_segment25                IN     VARCHAR2 DEFAULT null
  ,p_pgp_segment26                IN     VARCHAR2 DEFAULT null
  ,p_pgp_segment27                IN     VARCHAR2 DEFAULT null
  ,p_pgp_segment28                IN     VARCHAR2 DEFAULT null
  ,p_pgp_segment29                IN     VARCHAR2 DEFAULT null
  ,p_pgp_segment30                IN     VARCHAR2 DEFAULT null
  ,p_scl_contractor_name          IN     VARCHAR2 DEFAULT null
  ,p_scl_concat_segments          IN     VARCHAR2 DEFAULT null
  ,p_pgp_concat_segments          IN     VARCHAR2 DEFAULT null
  ,p_supervisor_assignment_id     IN     NUMBER   DEFAULT null
  ,p_assignment_id                   OUT NOCOPY NUMBER
  ,p_object_version_number           OUT NOCOPY NUMBER
  ,p_effective_start_date            OUT NOCOPY DATE
  ,p_effective_end_date              OUT NOCOPY DATE
  ,p_assignment_sequence             OUT NOCOPY NUMBER
  ,p_comment_id                      OUT NOCOPY NUMBER
  ,p_people_group_id                 OUT NOCOPY NUMBER
  ,p_people_group_name               OUT NOCOPY VARCHAR2
  ,p_other_manager_warning           OUT NOCOPY BOOLEAN
  ,p_hourly_salaried_warning         OUT NOCOPY BOOLEAN
  ,p_soft_coding_keyflex_id          OUT NOCOPY NUMBER);
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_in_cwk_asg >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates a contingent worker assignment.
 *
 * This API updates information for an existing contingent worker assignment
 * with a IN legislation. This changes attributes of the contingent worker
 * assignment that are not part of any other update.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The assignment (p_assignment_id) must exist as of the effective date of the
 * update (p_effective_date).
 *
 * <p><b>Post Success</b><br>
 * Updates the assignment of the contingent worker.
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
 * @param p_assignment_id Identifies the contingent worker assignment record to
 * modify.
 * @param p_object_version_number Pass in the current version number of the
 * contingent worker assignment to be updated. When the API completes if
 * p_validate is false, will be set to the new version number of the updated
 * contingent worker assignment. If p_validate is true will be set to the same
 * value which was passed in.
 * @param p_assignment_category Assignment Category.
 * @param p_assignment_number Assignment Number.
 * @param p_change_reason Reason for the assignment status change. If there is
 * no change reason, then the parameter can be null. Valid values are defined
 * in the 'EMP_ASSIGN_REASON' lookup type.. If there is no change reason please
 * explicitly set this to null. (else there is a risk of inadvertantly
 * recording promotions)
 * @param p_comments Comment text.
 * @param p_default_code_comb_id Identifier for the General Ledger Accounting
 * Flexfield combination that applies to this assignment.
 * @param p_establishment_id This identifies the establishment Legal Entity for
 * this assignment.
 * @param p_frequency Frequency associated with the defined normal working
 * hours. Valid values are defined in the 'FREQUENCY' lookup type.
 * @param p_internal_address_line Internal address identified with this
 * assignment.
 * @param p_labour_union_member_flag Indicates whether the employee is a labor
 * union member. Value 'Y' indicates employee is a labor union member.
 * @param p_manager_flag Indicates whether the employee is a manager.
 * @param p_normal_hours Normal working hours for this assignment.
 * @param p_project_title Project title.
 * @param p_set_of_books_id Identifies General Ledger set of books.
 * @param p_source_type Recruitment activity which this assignment is sourced
 * from. Valid values are defined in the 'REC_TYPE' lookup type.
 * @param p_supervisor_id Supervisor for the assignment. The value refers to
 * the supervisor's person record.
 * @param p_time_normal_finish Normal work finish time.
 * @param p_time_normal_start Normal work start time.
 * @param p_title Obsolete parameter, do not use.
 * @param p_vendor_assignment_number Supplier's assignment number.
 * @param p_vendor_employee_number Supplier's employee number.
 * @param p_vendor_id Supplier of assignment.
 * @param p_vendor_site_id Supplier site of assignment.
 * @param p_po_header_id Assignment purchase order reference.
 * @param p_po_line_id Assignment purchase order line.
 * @param p_projected_assignment_end Projected end of assignment Reserved for
 * future use.
 * @param p_assignment_status_type_id Assignment status. The system status must
 * be the same as before the update, otherwise one of the status change APIs
 * should be used.
 * @param p_concat_segments Concatenated segments for Soft Coded Key Flexfield.
 * Concatenated segments can be supplied instead of individual segments.
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
 * @param p_attribute21 Descriptive flexfield segment.
 * @param p_attribute22 Descriptive flexfield segment.
 * @param p_attribute23 Descriptive flexfield segment.
 * @param p_attribute24 Descriptive flexfield segment.
 * @param p_attribute25 Descriptive flexfield segment.
 * @param p_attribute26 Descriptive flexfield segment.
 * @param p_attribute27 Descriptive flexfield segment.
 * @param p_attribute28 Descriptive flexfield segment.
 * @param p_attribute29 Descriptive flexfield segment.
 * @param p_attribute30 Descriptive flexfield segment.
 * @param p_scl_contractor_name Contractor's Name.
 * @param p_supervisor_assignment_id Supervisor assignment id.
 * @param p_org_now_no_manager_warning Set to true if this assignment is a
 * manager, organization_id is updated and there is now no manager in the
 * previous organization. Set to false if another manager exists in the
 * previous organization. This parameter is always false if organization_id is
 * not updated. The warning value applies only as of p_effective_date
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated contingent worker assignment row which
 * now exists as of the effective date. If p_validate is true, then set to
 * null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated contingent worker assignment row which now
 * exists as of the effective date. If p_validate is true, then set to null.
 * @param p_comment_id If p_validate is false and comment text was provided,
 * then will be set to the identifier of the created contingent worker
 * assignment comment record.
 * @param p_no_managers_warning Set to true if as a result of the update there
 * is no manager in the organization. Otherwise set to false.
 * @param p_other_manager_warning If set to true, then a manager existed in the
 * organization prior to calling this API and the manager flag has been set to
 * 'Y' for yes.
 * @param p_soft_coding_keyflex_id If a value is passed in for this parameter,
 * it identifies an existing Soft Coded Key Flexfield combination to associate
 * with the assignment, and segment values are ignored. If a value is not
 * passed in, then the individual Soft Coded Key Flexfield segments supplied
 * will be used to choose an existing combination or create a new combination.
 * When the API completes, if p_validate is false, then this uniquely
 * identifies the associated combination of the Soft Coded Key flexfield for
 * this assignment. If p_validate is true, then set to null.
 * @param p_concatenated_segments If p_validate is false, set to Soft Coded Key
 * Flexfield concatenated segments, if p_validate is true, set to null.
 * @param p_hourly_salaried_warning Set to true if values entered for Salary
 * Basis and Hourly Salaried Code are invalid as of the effective date.
 * @rep:displayname Update Contingent Worker Assignment for India
 * @rep:category BUSINESS_ENTITY PER_CWK_ASG
 * @rep:lifecycle active
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
  PROCEDURE update_in_cwk_asg
  (p_validate                     IN     BOOLEAN  DEFAULT FALSE
  ,p_effective_date               IN     DATE
  ,p_datetrack_update_mode        IN     VARCHAR2
  ,p_assignment_id                IN     NUMBER
  ,p_object_version_number        IN OUT NOCOPY NUMBER
  ,p_assignment_category          IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_assignment_number            IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_change_reason                IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_comments                     IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_default_code_comb_id         IN     NUMBER   DEFAULT HR_API.G_NUMBER
  ,p_establishment_id             IN     NUMBER   DEFAULT HR_API.G_NUMBER
  ,p_frequency                    IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_internal_address_line        IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_labour_union_member_flag     IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_manager_flag                 IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_normal_hours                 IN     NUMBER   DEFAULT HR_API.G_NUMBER
  ,p_project_title                IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_set_of_books_id              IN     NUMBER   DEFAULT HR_API.G_NUMBER
  ,p_source_type                  IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_supervisor_id                IN     NUMBER   DEFAULT HR_API.G_NUMBER
  ,p_time_normal_finish           IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_time_normal_start            IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_title                        IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_vendor_assignment_number     IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_vendor_employee_number       IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_vendor_id                    IN     NUMBER   DEFAULT HR_API.G_NUMBER
  ,p_vendor_site_id               IN     NUMBER   DEFAULT HR_API.G_NUMBER
  ,p_po_header_id                 IN     NUMBER   DEFAULT HR_API.G_NUMBER
  ,p_po_line_id                   IN     NUMBER   DEFAULT HR_API.G_NUMBER
  ,p_projected_assignment_end     IN     DATE     DEFAULT HR_API.G_DATE
  ,p_assignment_status_type_id    IN     NUMBER   DEFAULT HR_API.G_NUMBER
  ,p_concat_segments              IN     VARCHAR2 DEFAULT NULL
  ,p_attribute_category           IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_attribute1                   IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_attribute2                   IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_attribute3                   IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_attribute4                   IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_attribute5                   IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_attribute6                   IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_attribute7                   IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_attribute8                   IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_attribute9                   IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_attribute10                  IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_attribute11                  IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_attribute12                  IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_attribute13                  IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_attribute14                  IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_attribute15                  IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_attribute16                  IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_attribute17                  IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_attribute18                  IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_attribute19                  IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_attribute20                  IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_attribute21                  IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_attribute22                  IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_attribute23                  IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_attribute24                  IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_attribute25                  IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_attribute26                  IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_attribute27                  IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_attribute28                  IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_attribute29                  IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_attribute30                  IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_scl_contractor_name          IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_supervisor_assignment_id     IN     NUMBER   DEFAULT HR_API.G_NUMBER
  ,p_org_now_no_manager_warning      OUT NOCOPY BOOLEAN
  ,p_effective_start_date            OUT NOCOPY DATE
  ,p_effective_end_date              OUT NOCOPY DATE
  ,p_comment_id                      OUT NOCOPY NUMBER
  ,p_no_managers_warning             OUT NOCOPY BOOLEAN
  ,p_other_manager_warning           OUT NOCOPY BOOLEAN
  ,p_soft_coding_keyflex_id          OUT NOCOPY NUMBER
  ,p_concatenated_segments           OUT NOCOPY VARCHAR2
  ,p_hourly_salaried_warning         OUT NOCOPY BOOLEAN
   );

END hr_in_assignment_api;

 

/
