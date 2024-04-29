--------------------------------------------------------
--  DDL for Package HR_NL_ASSIGNMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_NL_ASSIGNMENT_API" AUTHID CURRENT_USER AS
/* $Header: peasgnli.pkh 120.4 2006/01/20 01:50:59 summohan noship $ */
/*#
 * This package contains assignment APIs for the Netherlands.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Assignment for Netherlands
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_nl_secondary_emp_asg >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates secondary employee assignments for the Netherlands.
 *
 * Create a secondary employee assignment for a person. The API calls the
 * generic API create_secondary_emp_asg, with the parameters set as appropriate
 * for a Dutch employee assignment. As this API is effectively an alternative
 * to the API create_secondary_emp_asg, see that API for further explanation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * See API create_secondary_emp_asg.
 *
 * <p><b>Post Success</b><br>
 * When an employee assignment has been successfully created, the following out
 * parameters are set.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create an employee assignment and raises an error.
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
 * @param p_regular_working_hrs Regular Working Hours. These are the normal
 * expected working hours.
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
 * @param p_employment_type Employment Type. Valid values are defined by the
 * lookup type 'NL_EMPLOYMENT_TYPE'.
 * @param p_employment_subtype Employment Sub-type. Valid values are defined by
 * the lookup types 'NL_FICT_EMPLOYMENT_SUBTYPES',
 * 'NL_PREV_EMPLOYMENT_SUBTYPES' and 'NL_REAL_EMPLOYMENT_SUBTYPES'. The lookup
 * type that applies, depends on the value selected for Employment Type.
 * @param p_tax_reductions_apply General Tax Reduction Indicator. Valid values
 * are defined by the lookup type 'HR_NL_YES_NO'.
 * @param p_work_pattern Work Pattern. Valid values are defined by the lookup
 * type 'HR_NL_SHI_WRK_PTN'.
 * @param p_labour_tax_apply Labour Tax Reduction Indicator. Valid values are
 * defined by the lookup type 'HR_NL_YES_NO'.
 * @param p_income_code Income Code. Valid values are defined by the lookup
 * type 'NL_INCOME_CODE'.
 * @param p_addl_snr_tax_apply Additional Senior Tax Reduction Indicator. Valid
 * values are defined by the lookup type 'HR_NL_YES_NO'.
 * @param p_special_indicators Special Tax Indicators. This contains several
 * indicators (two digit codes), where codes are concatenated together into one
 * string. Valid indicator codes are defined by the lookup type
 * 'NL_SPECIAL_INDICATORS'.
 * @param p_tax_code Tax Code. This is a three digit code.
 * @param p_last_year_salary Override for Previous Years' Salary.
 * @param p_low_wages_apply Low Wages Indicator. Valid values are defined by
 * the lookup type 'HR_NL_YES_NO'.
 * @param p_education_apply Education Indicator. Valid values are defined by
 * the lookup type 'HR_NL_YES_NO'.
 * @param p_child_day_care_apply Obsolete parameter, do not use.
 * @param p_long_term_unemployed Long Term Unemployed Indicator. Valid values
 * are defined by the lookup type 'HR_NL_YES_NO'.
 * @param p_foreigner_with_spl_knowledge Foreigner With Special Knowledge (30%
 * Rule) Indicator. Valid values are defined by the lookup type 'HR_NL_YES_NO'.
 * @param p_beneficial_rule_apply Beneficial Rule Indicator for special rate
 * taxation. Valid values are defined by the lookup type 'HR_NL_YES_NO'.
 * @param p_individual_percentage Individual Percentage for special rate
 * taxation. This percentage value overrides any derived percentage rate.
 * @param p_commencing_from Commencing Date for Individual Percentage.
 * @param p_date_approved Approved Date for Individual Percentage.
 * @param p_date_ending Ending Date for Individual Percentage.
 * @param p_foreigner_tax_expiry Expiry Date for Foreigner With Special
 * Knowledge (30% Rule) Indicator.
 * @param p_job_level Job Level. Valid values are defined by the lookup type
 * 'HR_NL_JOB_LEVEL'.
 * @param p_max_days_method Maximum Days Method used in Social Insurance
 * calculations. Valid values are defined by the lookup type
 * 'NL_MAX_DAYS_METHOD'.
 * @param p_override_real_si_days Override for Real Social Insurance Days.
 * @param p_indiv_working_hrs Individual Working Hours. These are the hours
 * worked by an employee, for the assignment, during a specific time period.
 * @param p_part_time_percentage Part-time Percentage, based on Individual
 * Working Hours as opposed to Regular Working Hours.
 * @param p_scl_concat_segments Concatenated segments for Soft Coded Key
 * Flexfield. Concatenated segments can be supplied instead of individual
 * segments.
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
 * @param p_notice_period Length of notice period
 * @param p_notice_period_uom Units for notice period. Valid values are defined
 * in the QUALIFYING_UNITS lookup type.
 * @param p_employee_category Employee Category. Valid values are defined in
 * the EMPLOYEE_CATG lookup type.
 * @param p_work_at_home Indicate whether this assignment is to work at home.
 * Valid values are defined in the YES_NO lookup type.
 * @param p_job_post_source_name The source of the job posting that was
 * answered for this assignment.
 * @param p_grade_ladder_pgm_id Grade Ladder for this assignment
 * @param p_supervisor_assignment_id Supervisor's assignment that is
 * responsible for supervising this assignment.
 * @param p_group_name If p_validate is false, set to the People Group Key
 * Flexfield concatenated segments. If p_validate is true, set to null.
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
 * @param p_other_manager_warning If set to true, then a manager existed in the
 * organization prior to calling this API and the manager flag has been set to
 * 'Y' for yes.
 * @param p_hourly_salaried_warning Set to true if values entered for Salary
 * Basis and Hourly Salaried Code are invalid as of p_effective_date.
 * @param p_gsp_post_process_warning Set to the name of a warning message from
 * the Message Dictionary if any Grade Ladder related errors have been
 * encountered while running this API.
 * @param p_si_special_indicators SI Special Indicators. Valid values are
 * defined in the NL_SI_SPECIAL_INDICATORS lookup type.
 * @param p_incidental_worker Incidental Worker Flag. Valid values are defined
 * in the HR_NL_YES_NO lookup type.
 * @param p_paid_parental_leave_apply Paid Parental Leave. Valid values are
 * defined in the HR_NL_YES_NO lookup type.
 * @param p_deviating_working_hours Reasons for deviating working hours. Valid
 * values are defined in the NL_DEVIATING_WORKING_HOURS lookup type.
 * @param p_anonymous_employee Anonymous Employee. Valid values are defined in
 * the HR_NL_YES_NO lookup type.
 * @rep:displayname Create Secondary Employee Assignment for Netherlands
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE_ASG
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE create_nl_secondary_emp_asg
    (p_validate                     IN     BOOLEAN  DEFAULT   false
    ,p_effective_date               IN     DATE
    ,p_person_id                    IN     NUMBER
    ,p_organization_id              IN     NUMBER
    ,p_grade_id                     IN     NUMBER    DEFAULT null
    ,p_position_id                  IN     NUMBER    DEFAULT null
    ,p_job_id                       IN     NUMBER    DEFAULT null
    ,p_assignment_status_type_id    IN     NUMBER    DEFAULT null
    ,p_payroll_id                   IN     NUMBER    DEFAULT null
    ,p_location_id                  IN     NUMBER    DEFAULT null
    ,p_supervisor_id                IN     NUMBER    DEFAULT null
    ,p_special_ceiling_step_id      IN     NUMBER    DEFAULT null
    ,p_pay_basis_id                 IN     NUMBER    DEFAULT null
    ,p_assignment_number            IN OUT NOCOPY VARCHAR2
    ,p_change_reason                IN     VARCHAR2  DEFAULT null
    ,p_comments                     IN     VARCHAR2  DEFAULT null
    ,p_date_probation_end           IN     DATE      DEFAULT null
    ,p_default_code_comb_id         IN     NUMBER    DEFAULT null
    ,p_employment_category          IN     VARCHAR2  DEFAULT null
    ,p_frequency                    IN     VARCHAR2  DEFAULT null
    ,p_internal_address_line        IN     VARCHAR2  DEFAULT null
    ,p_manager_flag                 IN     VARCHAR2  DEFAULT null
    ,p_regular_working_hrs          IN     NUMBER    DEFAULT null
    ,p_perf_review_period           IN     NUMBER    DEFAULT null
    ,p_perf_review_period_frequency IN     VARCHAR2  DEFAULT null
    ,p_probation_period             IN     NUMBER    DEFAULT null
    ,p_probation_unit               IN     VARCHAR2  DEFAULT null
    ,p_sal_review_period            IN     NUMBER    DEFAULT null
    ,p_sal_review_period_frequency  IN     VARCHAR2  DEFAULT null
    ,p_set_of_books_id              IN     NUMBER    DEFAULT null
    ,p_source_type                  IN     VARCHAR2  DEFAULT null
    ,p_time_normal_finish           IN     VARCHAR2  DEFAULT null
    ,p_time_normal_start            IN     VARCHAR2  DEFAULT null
    ,p_bargaining_unit_code         IN     VARCHAR2  DEFAULT null
    ,p_labour_union_member_flag     IN     VARCHAR2  DEFAULT null
    ,p_hourly_salaried_code         IN     VARCHAR2  DEFAULT null
    ,p_ass_attribute_category       IN     VARCHAR2  DEFAULT null
    ,p_ass_attribute1               IN     VARCHAR2  DEFAULT null
    ,p_ass_attribute2               IN     VARCHAR2  DEFAULT null
    ,p_ass_attribute3               IN     VARCHAR2  DEFAULT null
    ,p_ass_attribute4               IN     VARCHAR2  DEFAULT null
    ,p_ass_attribute5               IN     VARCHAR2  DEFAULT null
    ,p_ass_attribute6               IN     VARCHAR2  DEFAULT null
    ,p_ass_attribute7               IN     VARCHAR2  DEFAULT null
    ,p_ass_attribute8               IN     VARCHAR2  DEFAULT null
    ,p_ass_attribute9               IN     VARCHAR2  DEFAULT null
    ,p_ass_attribute10              IN     VARCHAR2  DEFAULT null
    ,p_ass_attribute11              IN     VARCHAR2  DEFAULT null
    ,p_ass_attribute12              IN     VARCHAR2  DEFAULT null
    ,p_ass_attribute13              IN     VARCHAR2  DEFAULT null
    ,p_ass_attribute14              IN     VARCHAR2  DEFAULT null
    ,p_ass_attribute15              IN     VARCHAR2  DEFAULT null
    ,p_ass_attribute16              IN     VARCHAR2  DEFAULT null
    ,p_ass_attribute17              IN     VARCHAR2  DEFAULT null
    ,p_ass_attribute18              IN     VARCHAR2  DEFAULT null
    ,p_ass_attribute19              IN     VARCHAR2  DEFAULT null
    ,p_ass_attribute20              IN     VARCHAR2  DEFAULT null
    ,p_ass_attribute21              IN     VARCHAR2  DEFAULT null
    ,p_ass_attribute22              IN     VARCHAR2  DEFAULT null
    ,p_ass_attribute23              IN     VARCHAR2  DEFAULT null
    ,p_ass_attribute24              IN     VARCHAR2  DEFAULT null
    ,p_ass_attribute25              IN     VARCHAR2  DEFAULT null
    ,p_ass_attribute26              IN     VARCHAR2  DEFAULT null
    ,p_ass_attribute27              IN     VARCHAR2  DEFAULT null
    ,p_ass_attribute28              IN     VARCHAR2  DEFAULT null
    ,p_ass_attribute29              IN     VARCHAR2  DEFAULT null
    ,p_ass_attribute30              IN     VARCHAR2  DEFAULT null
    ,p_title                        IN     VARCHAR2  DEFAULT null
    ,p_employment_type              IN     VARCHAR2  DEFAULT null
    ,p_employment_subtype           IN     VARCHAR2  DEFAULT null
    ,p_tax_reductions_apply         IN     VARCHAR2  DEFAULT null
    ,p_paid_parental_leave_apply    IN     VARCHAR2  DEFAULT null
    ,p_work_pattern                 IN     VARCHAR2  DEFAULT null
    ,p_labour_tax_apply             IN     VARCHAR2  DEFAULT null
    ,p_income_code                  IN     VARCHAR2  DEFAULT null
    ,p_addl_snr_tax_apply           IN     VARCHAR2  DEFAULT null
    ,p_special_indicators           IN     VARCHAR2  DEFAULT null
    ,p_tax_code                     IN     VARCHAR2  DEFAULT null
    ,p_last_year_salary             IN     VARCHAR2  DEFAULT null
    ,p_low_wages_apply              IN     VARCHAR2  DEFAULT null
    ,p_education_apply              IN     VARCHAR2  DEFAULT null
    ,p_child_day_care_apply         IN     VARCHAR2  DEFAULT null
    ,p_anonymous_employee           IN     VARCHAR2  DEFAULT null
    ,p_long_term_unemployed         IN     VARCHAR2  DEFAULT null
    ,p_foreigner_with_spl_knowledge IN     VARCHAR2  DEFAULT null
    ,p_beneficial_rule_apply        IN     VARCHAR2  DEFAULT null
    ,p_individual_percentage        IN     NUMBER    DEFAULT null
    ,p_commencing_from              IN     DATE      DEFAULT null
    ,p_date_approved                IN     DATE      DEFAULT null
    ,p_date_ending                  IN     DATE      DEFAULT null
    ,p_foreigner_tax_expiry         IN     DATE      DEFAULT null
    ,p_job_level                    IN     VARCHAR2  DEFAULT null
    ,p_max_days_method              IN     VARCHAR2  DEFAULT null
    ,p_override_real_si_days        IN     NUMBER    DEFAULT null
    ,p_indiv_working_hrs            IN     NUMBER    DEFAULT null
    ,p_part_time_percentage         IN     NUMBER    DEFAULT null
    ,p_si_special_indicators        IN     VARCHAR2  DEFAULT null
    ,p_deviating_working_hours      IN     VARCHAR2  DEFAULT null
    ,p_incidental_worker            IN     VARCHAR2  DEFAULT null
    ,p_scl_concat_segments          IN     VARCHAR2  DEFAULT null
    ,p_pgp_segment1                 IN     VARCHAR2  DEFAULT null
    ,p_pgp_segment2                 IN     VARCHAR2  DEFAULT null
    ,p_pgp_segment3                 IN     VARCHAR2  DEFAULT null
    ,p_pgp_segment4                 IN     VARCHAR2  DEFAULT null
    ,p_pgp_segment5                 IN     VARCHAR2  DEFAULT null
    ,p_pgp_segment6                 IN     VARCHAR2  DEFAULT null
    ,p_pgp_segment7                 IN     VARCHAR2  DEFAULT null
    ,p_pgp_segment8                 IN     VARCHAR2  DEFAULT null
    ,p_pgp_segment9                 IN     VARCHAR2  DEFAULT null
    ,p_pgp_segment10                IN     VARCHAR2  DEFAULT null
    ,p_pgp_segment11                IN     VARCHAR2  DEFAULT null
    ,p_pgp_segment12                IN     VARCHAR2  DEFAULT null
    ,p_pgp_segment13                IN     VARCHAR2  DEFAULT null
    ,p_pgp_segment14                IN     VARCHAR2  DEFAULT null
    ,p_pgp_segment15                IN     VARCHAR2  DEFAULT null
    ,p_pgp_segment16                IN     VARCHAR2  DEFAULT null
    ,p_pgp_segment17                IN     VARCHAR2  DEFAULT null
    ,p_pgp_segment18                IN     VARCHAR2  DEFAULT null
    ,p_pgp_segment19                IN     VARCHAR2  DEFAULT null
    ,p_pgp_segment20                IN     VARCHAR2  DEFAULT null
    ,p_pgp_segment21                IN     VARCHAR2  DEFAULT null
    ,p_pgp_segment22                IN     VARCHAR2  DEFAULT null
    ,p_pgp_segment23                IN     VARCHAR2  DEFAULT null
    ,p_pgp_segment24                IN     VARCHAR2  DEFAULT null
    ,p_pgp_segment25                IN     VARCHAR2  DEFAULT null
    ,p_pgp_segment26                IN     VARCHAR2  DEFAULT null
    ,p_pgp_segment27                IN     VARCHAR2  DEFAULT null
    ,p_pgp_segment28                IN     VARCHAR2  DEFAULT null
    ,p_pgp_segment29                IN     VARCHAR2  DEFAULT null
    ,p_pgp_segment30                IN     VARCHAR2  DEFAULT null
    ,p_pgp_concat_segments          IN     VARCHAR2  DEFAULT null
    ,p_contract_id                  IN     NUMBER    DEFAULT null
    ,p_establishment_id             IN     NUMBER    DEFAULT null
    ,p_collective_agreement_id      IN     NUMBER    DEFAULT null
    ,p_cagr_id_flex_num             IN     NUMBER    DEFAULT null
    ,p_cag_segment1                 IN     VARCHAR2  DEFAULT null
    ,p_cag_segment2                 IN     VARCHAR2  DEFAULT null
    ,p_cag_segment3                 IN     VARCHAR2  DEFAULT null
    ,p_cag_segment4                 IN     VARCHAR2  DEFAULT null
    ,p_cag_segment5                 IN     VARCHAR2  DEFAULT null
    ,p_cag_segment6                 IN     VARCHAR2  DEFAULT null
    ,p_cag_segment7                 IN     VARCHAR2  DEFAULT null
    ,p_cag_segment8                 IN     VARCHAR2  DEFAULT null
    ,p_cag_segment9                 IN     VARCHAR2  DEFAULT null
    ,p_cag_segment10                IN     VARCHAR2  DEFAULT null
    ,p_cag_segment11                IN     VARCHAR2  DEFAULT null
    ,p_cag_segment12                IN     VARCHAR2  DEFAULT null
    ,p_cag_segment13                IN     VARCHAR2  DEFAULT null
    ,p_cag_segment14                IN     VARCHAR2  DEFAULT null
    ,p_cag_segment15                IN     VARCHAR2  DEFAULT null
    ,p_cag_segment16                IN     VARCHAR2  DEFAULT null
    ,p_cag_segment17                IN     VARCHAR2  DEFAULT null
    ,p_cag_segment18                IN     VARCHAR2  DEFAULT null
    ,p_cag_segment19                IN     VARCHAR2  DEFAULT null
    ,p_cag_segment20                IN     VARCHAR2  DEFAULT null
    ,p_notice_period                IN     NUMBER     DEFAULT null
    ,p_notice_period_uom            IN     VARCHAR2    DEFAULT null
    ,p_employee_category            IN     VARCHAR2    DEFAULT null
    ,p_work_at_home                 IN     VARCHAR2   DEFAULT null
    ,p_job_post_source_name         IN     VARCHAR2    DEFAULT null
    ,p_grade_ladder_pgm_id          in     number
    ,p_supervisor_assignment_id     in     number
    ,p_group_name                   OUT    NOCOPY VARCHAR2
    ,p_concatenated_segments        OUT    NOCOPY VARCHAR2
    ,p_cagr_grade_def_id            IN     OUT NOCOPY NUMBER
    ,p_cagr_concatenated_segments   OUT    NOCOPY VARCHAR2
    ,p_assignment_id                OUT    NOCOPY NUMBER
    ,p_soft_coding_keyflex_id       IN OUT NOCOPY NUMBER
    ,p_people_group_id              IN OUT NOCOPY NUMBER
    ,p_object_version_number        OUT   NOCOPY NUMBER
    ,p_effective_start_date         OUT   NOCOPY DATE
    ,p_effective_end_date           OUT   NOCOPY DATE
    ,p_assignment_sequence          OUT   NOCOPY NUMBER
    ,p_comment_id                   OUT   NOCOPY NUMBER
    ,p_other_manager_warning        OUT   NOCOPY BOOLEAN
    ,p_hourly_salaried_warning      OUT   NOCOPY BOOLEAN
    ,p_gsp_post_process_warning        out nocopy varchar2) ;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_nl_emp_asg >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates employee assignments for the Netherlands.
 *
 * Update an employee assignment for a person. The API calls the generic API
 * update_emp_asg, with the parameters set as appropriate for a Dutch employee
 * assignment. As this API is effectively an alternative to the API
 * update_emp_asg, see that API for further explanation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * See API update_emp_asg.
 *
 * <p><b>Post Success</b><br>
 * When an employee assignment has been successfully updated, the following out
 * parameters are set.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update an employee assignment and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation comes into
 * force.
 * @param p_person_id Obsolete parameter, do not use.
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
 * @param p_assignment_status_type_id Assignment status. The system status must
 * be the same as before the update, otherwise one of the status change APIs
 * should be used.
 * @param p_comments Comment text.
 * @param p_date_probation_end End date of probation period
 * @param p_default_code_comb_id Identifier for the General Ledger Accounting
 * Flexfield combination that applies to this assignment
 * @param p_frequency Frequency associated with the defined normal working
 * hours. Valid values are defined in the FREQUENCY lookup type.
 * @param p_internal_address_line Internal address identified with this
 * assignment.
 * @param p_manager_flag Indicates whether the employee is a manager
 * @param p_regular_working_hrs Regular Working Hours. These are the normal
 * expected working hours.
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
 * @param p_employment_type Employment Type. Valid values are defined by the
 * lookup type 'NL_EMPLOYMENT_TYPE'.
 * @param p_employment_subtype Employment Sub-type. Valid values are defined by
 * the lookup types 'NL_FICT_EMPLOYMENT_SUBTYPES',
 * 'NL_PREV_EMPLOYMENT_SUBTYPES' and 'NL_REAL_EMPLOYMENT_SUBTYPES'. The lookup
 * type that applies, depends on the value selected for Employment Type.
 * @param p_tax_reductions_apply General Tax Reduction Indicator. Valid values
 * are defined by the lookup type 'HR_NL_YES_NO'.
 * @param p_work_pattern Work Pattern. Valid values are defined by the lookup
 * type 'HR_NL_SHI_WRK_PTN'.
 * @param p_labour_tax_apply Labour Tax Reduction Indicator. Valid values are
 * defined by the lookup type 'HR_NL_YES_NO'.
 * @param p_income_code Income Code. Valid values are defined by the lookup
 * type 'NL_INCOME_CODE'.
 * @param p_addl_snr_tax_apply Additional Senior Tax Reduction Indicator. Valid
 * values are defined by the lookup type 'HR_NL_YES_NO'.
 * @param p_special_indicators Special Tax Indicators. This contains several
 * indicators (two digit codes), where codes are concatenated together in to
 * one string. Valid indicator codes are defined by the lookup type
 * 'NL_SPECIAL_INDICATORS'.
 * @param p_tax_code Tax Code. This is a three digit code.
 * @param p_last_year_salary Override for Previous Years' Salary.
 * @param p_low_wages_apply Low Wages Indicator. Valid values are defined by
 * the lookup type 'HR_NL_YES_NO'.
 * @param p_education_apply Education Indicator. Valid values are defined by
 * the lookup type 'HR_NL_YES_NO'.
 * @param p_child_day_care_apply Obsolete parameter, do not use.
 * @param p_long_term_unemployed Long Term Unemployed Indicator. Valid values
 * are defined by the lookup type 'HR_NL_YES_NO'.
 * @param p_foreigner_with_spl_knowledge Foreigner With Special Knowledge (30%
 * Rule) Indicator. Valid values are defined by the lookup type 'HR_NL_YES_NO'.
 * @param p_beneficial_rule_apply Beneficial Rule Indicator for special rate
 * taxation. Valid values are defined by the lookup type 'HR_NL_YES_NO'.
 * @param p_individual_percentage Individual Percentage for special rate
 * taxation. This is a percentage value to override any derived percentage
 * rate.
 * @param p_commencing_from Commencing Date for Individual Percentage.
 * @param p_date_approved Approved Date for Individual Percentage.
 * @param p_date_ending Ending Date for Individual Percentage.
 * @param p_foreigner_tax_expiry Expiry Date for Foreigner With Special
 * Knowledge (30% Rule) Indicator.
 * @param p_job_level Job Level. Valid values are defined by the lookup type
 * 'HR_NL_JOB_LEVEL'.
 * @param p_max_days_method Maximum Days Method used in Social Insurance
 * calculations. Valid values are defined by the lookup type
 * 'NL_MAX_DAYS_METHOD'.
 * @param p_override_real_si_days Override for Real Social Insurance Days.
 * @param p_indiv_working_hrs Individual Working Hours. These are the hours
 * worked by an employee, for the assignment, during a specific time period.
 * @param p_part_time_percentage Part-time Percentage, based on Individual
 * Working Hours as opposed to Regular Working Hours.
 * @param p_concat_segments Concatenated segments for Soft Coded Key Flexfield.
 * Concatenated segments can be supplied instead of individual segments.
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
 * @param p_notice_period Length of notice period
 * @param p_notice_period_uom Units for notice period. Valid values are defined
 * in the QUALIFYING_UNITS lookup type.
 * @param p_employee_category Employee Category. Valid values are defined in
 * the EMPLOYEE_CATG lookup type.
 * @param p_work_at_home Indicate whether this assignment is to work at home.
 * Valid values are defined in the YES_NO lookup type.
 * @param p_job_post_source_name Name of the source of the job posting that was
 * answered for this assignment.
 * @param p_cagr_grade_def_id If a value is passed in for this parameter, it
 * identifies an existing CAGR Key Flexfield combination to associate with the
 * assignment, and segment values are ignored. If a value is not passed in,
 * then the individual CAGR Key Flexfield segments supplied will be used to
 * choose an existing combination or create a new combination. When the API
 * completes, if p_validate is false, then this uniquely identifies the
 * associated combination of the CAGR Key flexfield for this assignment. If
 * p_validate is true, then set to null.
 * @param p_cagr_concatenated_segments CAGR Key Flexfield concatenated segments
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
 * @param p_paid_parental_leave_apply Paid Parental Leave. Valid values are
 * defined in the HR_NL_YES_NO lookup type.
 * @param p_si_special_indicators SI Special Indicators. Valid values are
 * defined in the NL_SI_SPECIAL_INDICATORS lookup type.
 * @param p_deviating_working_hours Reasons for deviating working hours. Valid
 * values are defined in the NL_DEVIATING_WORKING_HOURS lookup type.
 * @param p_incidental_worker Incidental Worker Flag. Valid values are defined
 * in the HR_NL_YES_NO lookup type.
 * @param p_anonymous_employee Anonymous Employee. Valid values are defined in
 * the HR_NL_YES_NO lookup type.
 * @rep:displayname Update Employee Assignment for Netherlands
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE_ASG
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE update_nl_emp_asg
    (p_validate                     IN     BOOLEAN    default false
    ,p_effective_date               IN     DATE
    ,p_person_id                    IN     NUMBER
    ,p_datetrack_update_mode        IN     VARCHAR2
    ,p_assignment_id                IN     NUMBER
    ,p_object_version_number        IN OUT NOCOPY NUMBER
    ,p_supervisor_id                IN     NUMBER    default hr_api.g_number
    ,p_assignment_number            IN     VARCHAR2  default hr_api.g_varchar2
    ,p_change_reason                IN     VARCHAR2  default hr_api.g_varchar2
    ,p_assignment_status_type_id    IN     NUMBER    default hr_api.g_number
    ,p_comments                     IN     VARCHAR2  default hr_api.g_varchar2
    ,p_date_probation_end           IN     DATE      default hr_api.g_date
    ,p_default_code_comb_id         IN     NUMBER    default hr_api.g_number
    ,p_frequency                    IN     VARCHAR2  default hr_api.g_varchar2
    ,p_internal_address_line        IN     VARCHAR2  default hr_api.g_varchar2
    ,p_manager_flag                 IN     VARCHAR2  default hr_api.g_varchar2
    ,p_regular_working_hrs          IN     NUMBER    default hr_api.g_number
    ,p_perf_review_period           IN     NUMBER    default hr_api.g_number
    ,p_perf_review_period_frequency IN     VARCHAR2  default hr_api.g_varchar2
    ,p_probation_period             IN     NUMBER    default hr_api.g_number
    ,p_probation_unit               IN     VARCHAR2  default hr_api.g_varchar2
    ,p_sal_review_period            IN     NUMBER    default hr_api.g_number
    ,p_sal_review_period_frequency  IN     VARCHAR2  default hr_api.g_varchar2
    ,p_set_of_books_id              IN     NUMBER    default hr_api.g_number
    ,p_source_type                  IN     VARCHAR2  default hr_api.g_varchar2
    ,p_time_normal_finish           IN     VARCHAR2  default hr_api.g_varchar2
    ,p_time_normal_start            IN     VARCHAR2  default hr_api.g_varchar2
    ,p_bargaining_unit_code         IN     VARCHAR2  default hr_api.g_varchar2
    ,p_labour_union_member_flag     IN     VARCHAR2  default hr_api.g_varchar2
    ,p_hourly_salaried_code         IN     VARCHAR2  default hr_api.g_varchar2
    ,p_ass_attribute_category       IN     VARCHAR2  default hr_api.g_varchar2
    ,p_ass_attribute1               IN     VARCHAR2  default hr_api.g_varchar2
    ,p_ass_attribute2               IN     VARCHAR2  default hr_api.g_varchar2
    ,p_ass_attribute3               IN     VARCHAR2  default hr_api.g_varchar2
    ,p_ass_attribute4               IN     VARCHAR2  default hr_api.g_varchar2
    ,p_ass_attribute5               IN     VARCHAR2  default hr_api.g_varchar2
    ,p_ass_attribute6               IN     VARCHAR2  default hr_api.g_varchar2
    ,p_ass_attribute7               IN     VARCHAR2  default hr_api.g_varchar2
    ,p_ass_attribute8               IN     VARCHAR2  default hr_api.g_varchar2
    ,p_ass_attribute9               IN     VARCHAR2  default hr_api.g_varchar2
    ,p_ass_attribute10              IN     VARCHAR2  default hr_api.g_varchar2
    ,p_ass_attribute11              IN     VARCHAR2  default hr_api.g_varchar2
    ,p_ass_attribute12              IN     VARCHAR2  default hr_api.g_varchar2
    ,p_ass_attribute13              IN     VARCHAR2  default hr_api.g_varchar2
    ,p_ass_attribute14              IN     VARCHAR2  default hr_api.g_varchar2
    ,p_ass_attribute15              IN     VARCHAR2  default hr_api.g_varchar2
    ,p_ass_attribute16              IN     VARCHAR2  default hr_api.g_varchar2
    ,p_ass_attribute17              IN     VARCHAR2  default hr_api.g_varchar2
    ,p_ass_attribute18              IN     VARCHAR2  default hr_api.g_varchar2
    ,p_ass_attribute19              IN     VARCHAR2  default hr_api.g_varchar2
    ,p_ass_attribute20              IN     VARCHAR2  default hr_api.g_varchar2
    ,p_ass_attribute21              IN     VARCHAR2  default hr_api.g_varchar2
    ,p_ass_attribute22              IN     VARCHAR2  default hr_api.g_varchar2
    ,p_ass_attribute23              IN     VARCHAR2  default hr_api.g_varchar2
    ,p_ass_attribute24              IN     VARCHAR2  default hr_api.g_varchar2
    ,p_ass_attribute25              IN     VARCHAR2  default hr_api.g_varchar2
    ,p_ass_attribute26              IN     VARCHAR2  default hr_api.g_varchar2
    ,p_ass_attribute27              IN     VARCHAR2  default hr_api.g_varchar2
    ,p_ass_attribute28              IN     VARCHAR2  default hr_api.g_varchar2
    ,p_ass_attribute29              IN     VARCHAR2  default hr_api.g_varchar2
    ,p_ass_attribute30              IN     VARCHAR2  default hr_api.g_varchar2
    ,p_title                        IN     VARCHAR2  default hr_api.g_varchar2
    ,p_employment_type              IN     VARCHAR2  default hr_api.g_varchar2
    ,p_employment_subtype           IN     VARCHAR2  default hr_api.g_varchar2
    ,p_tax_reductions_apply         IN     VARCHAR2  default hr_api.g_varchar2
    ,p_paid_parental_leave_apply    IN     VARCHAR2  default hr_api.g_varchar2
    ,p_work_pattern                 IN     VARCHAR2  default hr_api.g_varchar2
    ,p_labour_tax_apply             IN     VARCHAR2  default hr_api.g_varchar2
    ,p_income_code                  IN     VARCHAR2  default hr_api.g_varchar2
    ,p_addl_snr_tax_apply           IN     VARCHAR2  default hr_api.g_varchar2
    ,p_special_indicators           IN     VARCHAR2  default hr_api.g_varchar2
    ,p_tax_code                     IN     VARCHAR2  default hr_api.g_varchar2
    ,p_last_year_salary             IN     VARCHAR2  default hr_api.g_varchar2
    ,p_low_wages_apply              IN     VARCHAR2  default hr_api.g_varchar2
    ,p_education_apply              IN     VARCHAR2  default hr_api.g_varchar2
    ,p_child_day_care_apply         IN     VARCHAR2  default hr_api.g_varchar2
    ,p_anonymous_employee           IN     VARCHAR2  default hr_api.g_varchar2
    ,p_long_term_unemployed         IN     VARCHAR2  default hr_api.g_varchar2
    ,p_foreigner_with_spl_knowledge IN     VARCHAR2  default hr_api.g_varchar2
    ,p_beneficial_rule_apply        IN     VARCHAR2  default hr_api.g_varchar2
    ,p_individual_percentage        IN     NUMBER    default hr_api.g_number
    ,p_commencing_from              IN     DATE      default hr_api.g_date
    ,p_date_approved                IN     DATE      default hr_api.g_date
    ,p_date_ending                  IN     DATE      default hr_api.g_date
    ,p_foreigner_tax_expiry         IN     DATE      default hr_api.g_date
    ,p_job_level                    IN     VARCHAR2  default hr_api.g_varchar2
    ,p_max_days_method              IN     VARCHAR2  default hr_api.g_varchar2
    ,p_override_real_si_days        IN     NUMBER    default hr_api.g_number
    ,p_indiv_working_hrs            IN     NUMBER    default hr_api.g_number
    ,p_part_time_percentage         IN     NUMBER    default hr_api.g_number
    ,p_si_special_indicators        IN     VARCHAR2  default hr_api.g_varchar2
    ,p_deviating_working_hours      IN     VARCHAR2  default hr_api.g_varchar2
    ,p_incidental_worker     	    IN     VARCHAR2  default hr_api.g_varchar2
    ,p_concat_segments              IN     VARCHAR2  default hr_api.g_varchar2
    ,p_contract_id                  IN     NUMBER    DEFAULT   hr_api.g_number
    ,p_establishment_id             IN     NUMBER    DEFAULT   hr_api.g_number
    ,p_collective_agreement_id      IN     NUMBER    DEFAULT   hr_api.g_number
    ,p_cagr_id_flex_num             IN     NUMBER    DEFAULT   hr_api.g_number
    ,p_cag_segment1                 IN     VARCHAR2  DEFAULT   hr_api.g_varchar2
    ,p_cag_segment2                 IN     VARCHAR2  DEFAULT   hr_api.g_varchar2
    ,p_cag_segment3                 IN     VARCHAR2  DEFAULT   hr_api.g_varchar2
    ,p_cag_segment4                 IN     VARCHAR2  DEFAULT   hr_api.g_varchar2
    ,p_cag_segment5                 IN     VARCHAR2  DEFAULT   hr_api.g_varchar2
    ,p_cag_segment6                 IN     VARCHAR2  DEFAULT   hr_api.g_varchar2
    ,p_cag_segment7                 IN     VARCHAR2  DEFAULT   hr_api.g_varchar2
    ,p_cag_segment8                 IN     VARCHAR2  DEFAULT   hr_api.g_varchar2
    ,p_cag_segment9                 IN     VARCHAR2  DEFAULT   hr_api.g_varchar2
    ,p_cag_segment10                IN     VARCHAR2  DEFAULT   hr_api.g_varchar2
    ,p_cag_segment11                IN     VARCHAR2  DEFAULT   hr_api.g_varchar2
    ,p_cag_segment12                IN     VARCHAR2  DEFAULT   hr_api.g_varchar2
    ,p_cag_segment13                IN     VARCHAR2  DEFAULT   hr_api.g_varchar2
    ,p_cag_segment14                IN     VARCHAR2  DEFAULT   hr_api.g_varchar2
    ,p_cag_segment15                IN     VARCHAR2  DEFAULT   hr_api.g_varchar2
    ,p_cag_segment16                IN     VARCHAR2  DEFAULT   hr_api.g_varchar2
    ,p_cag_segment17                IN     VARCHAR2  DEFAULT   hr_api.g_varchar2
    ,p_cag_segment18                IN     VARCHAR2  DEFAULT   hr_api.g_varchar2
    ,p_cag_segment19                IN     VARCHAR2  DEFAULT   hr_api.g_varchar2
    ,p_cag_segment20                IN     VARCHAR2  DEFAULT   hr_api.g_varchar2
    ,p_notice_period                IN     NUMBER    DEFAULT   hr_api.g_number
    ,p_notice_period_uom            IN     VARCHAR2  DEFAULT   hr_api.g_varchar2
    ,p_employee_category            IN     VARCHAR2  DEFAULT   hr_api.g_varchar2
    ,p_work_at_home                 IN     VARCHAR2  DEFAULT   hr_api.g_varchar2
    ,p_job_post_source_name         IN     VARCHAR2  DEFAULT   hr_api.g_varchar2
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
    ,p_gsp_post_process_warning        out nocopy varchar2
);

end hr_nl_assignment_api;

 

/
