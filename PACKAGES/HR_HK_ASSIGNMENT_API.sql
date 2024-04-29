--------------------------------------------------------
--  DDL for Package HR_HK_ASSIGNMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_HK_ASSIGNMENT_API" AUTHID CURRENT_USER AS
/* $Header: hrhkwras.pkh 120.1 2005/10/02 02:02:16 aroussel $ */
/*#
 * This Package contains assignment related APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Assignment for Hong Kong
*/
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_hk_emp_asg >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This procedure updates employee assignment details for Hong Kong.
 *
 * The API calls the generic API update_emp_asg, with parameters set as
 * appropriate for a Hong Kong employee assignment.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The assignment (p_assignment_id) must exist as of the effective date of the
 * update (p_effective_date).
 *
 * <p><b>Post Success</b><br>
 * The employee assignment is successfully updated in the database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not update the assignment and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation takes
 * effect.
 * @param p_datetrack_update_mode Indicates which DateTrack mode to use when
 * updating the record. You must set to either UPDATE, CORRECTION,
 * UPDATE_OVERRIDE or UPDATE_CHANGE_INSERT. Modes available for use with a
 * particular record depend on the dates of previous record changes and the
 * effective date of this change.
 * @param p_assignment_id Identifies the assignment for which you update
 * Assignment record.
 * @param p_object_version_number Pass in the current version number of the
 * assignment to be updated. When the API completes if p_validate is false,
 * then set to the version number of the updated assignment. If p_validate is
 * true, then the value will be null.
 * @param p_supervisor_id {@rep:casecolumn PER_ALL_ASSIGNMENTS_F.SUPERVISOR_ID}
 * @param p_assignment_number {@rep:casecolumn
 * PER_ALL_ASSIGNMENTS_F.ASSIGNMENT_NUMBER}
 * @param p_change_reason Indicates the reason for the last change in the
 * assignment. Valid values are defined by 'EMP_ASSIGN_REASON' lookup type.
 * @param p_comments Comment text.
 * @param p_date_probation_end {@rep:casecolumn
 * PER_ALL_ASSIGNMENTS_F.DATE_PROBATION_END}
 * @param p_default_code_comb_id {@rep:casecolumn
 * PER_ALL_ASSIGNMENTS_F.DEFAULT_CODE_COMB_ID}
 * @param p_frequency Frequency of normal working hours, - week, month, year.
 * Valid values are defined by 'FREQUENCY' lookup type.
 * @param p_internal_address_line {@rep:casecolumn
 * PER_ALL_ASSIGNMENTS_F.INTERNAL_ADDRESS_LINE}
 * @param p_manager_flag {@rep:casecolumn PER_ALL_ASSIGNMENTS_F.MANAGER_FLAG}
 * @param p_normal_hours {@rep:casecolumn PER_ALL_ASSIGNMENTS_F.NORMAL_HOURS}
 * @param p_perf_review_period {@rep:casecolumn
 * PER_ALL_ASSIGNMENTS_F.PERF_REVIEW_PERIOD}
 * @param p_perf_review_period_frequency The Performance Review Frequency units
 * will be used along with Performance Review Period to define the time between
 * reviews. Valid values are defined by 'FREQUENCY' lookup type.
 * @param p_probation_period {@rep:casecolumn
 * PER_ALL_ASSIGNMENTS_F.PROBATION_PERIOD}
 * @param p_probation_unit Units of probation period duration. Valid values are
 * defined by 'QUALIFYING_UNITS' lookup type.
 * @param p_sal_review_period {@rep:casecolumn
 * PER_ALL_ASSIGNMENTS_F.SAL_REVIEW_PERIOD}
 * @param p_sal_review_period_frequency The Salary Review Frequence Units will
 * be used with Salary Review Period to define time between salary reviews.
 * Valid values are defined by 'FREQUENCY' lookup type.
 * @param p_set_of_books_id {@rep:casecolumn
 * PER_ALL_ASSIGNMENTS_F.SET_OF_BOOKS_ID}
 * @param p_source_type Recruitment activity source for applicant assignment,
 * for example, Advertisement. Valid values are defined by 'REC_TYPE' lookup
 * type
 * @param p_time_normal_finish {@rep:casecolumn
 * PER_ALL_ASSIGNMENTS_F.TIME_NORMAL_FINISH}
 * @param p_time_normal_start {@rep:casecolumn
 * PER_ALL_ASSIGNMENTS_F.TIME_NORMAL_START}
 * @param p_bargaining_unit_code Bargaining unit code. Valid values are defined
 * by 'BARGAINING_UNIT_CODE' lookup type.
 * @param p_labour_union_member_flag Indicates whether the employee was in the
 * dependent voluntary service. Valid values are defined by 'YES_NO' lookup
 * type.
 * @param p_hourly_salaried_code Identifies if the assignment is paid by the
 * hour or by a salary. Valid values are defined by 'HOURLY_SALARIED_CODE'
 * lookup type.
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
 * @param p_title Assignment's Title e.g. Mr, Mrs, Dr. Valid values are defined
 * by 'TITLE' lookup type.
 * @param p_legal_employer_id Identifies the resgistered employer for the
 * current assignment.
 * @param p_principal_employer_name Indentifies the name of the Main employer
 * if the employee is working Part time.
 * @param p_include_on_ir56b Include this assignment on the IR56B report, valid
 * values as applicable defined by YES_NO lookup_type
 * @param p_exclusion_reason Indicates the reason why the assignment should not
 * to appear on the IR56B report.
 * @param p_ir56b_message Indicates the message to appear in the IR56B report.
 * @param p_monies_held Indicates if any amount is to be withheld by the
 * employer when the Assignment is leaving the country, Valid values as
 * applicable are defined by YES_NO lookup_type.
 * @param p_estimated_amount_held The amount to be withheld by the employer
 * when the employee is leaving the country.
 * @param p_soft_coding_keyflex_id If p_segments is set and the Soft coding key
 * combination already exists, then set to the existing ID else create a new
 * Soft coding key combination and return its value. If p_segments is not set
 * and the Soft coding key combination already exists, then set
 * @param p_comment_id If p_validate is false and new or existing comment text
 * exists, then will be set to the identifier of the Assignment comment record.
 * If p_validate is true or no comment text exists, then will be null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated Assignment row which now exists as of
 * the effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated Assignment row which now exists as of the
 * effective date. If p_validate is true, then set to null.
 * @param p_concatenated_segments If p_validate is false, returns the
 * concatenation of all p_segment parameters. If p_validate is true or no
 * p_segment parameters have been set, this will be null.
 * @param p_no_managers_warning If p_validate is false, the manager_flag has
 * been updated from 'Y' to 'N' and no other manager exists in
 * p_organization_id, then set to true. If p_validate is false, the
 * manager_flag has been updated from 'Y' to 'N' and another manager exists in
 * p_organiz
 * @param p_other_manager_warning If set to true, then a manager existed in the
 * organization prior to calling this API and the manager flag has been set to
 * 'Y' for yes.
 * @rep:displayname Update Employee Assignment for Hong Kong
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE_ASG
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
 PROCEDURE update_hk_emp_asg
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
  ,p_legal_employer_id            IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_principal_employer_name            IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_include_on_ir56b            IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_exclusion_reason            IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_ir56b_message            IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_Monies_held            IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_estimated_amount_held            IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_soft_coding_keyflex_id          OUT NOCOPY NUMBER
  ,p_comment_id                      OUT NOCOPY NUMBER
  ,p_effective_start_date            OUT NOCOPY DATE
  ,p_effective_end_date              OUT NOCOPY DATE
  ,p_concatenated_segments           OUT NOCOPY VARCHAR2
  ,p_no_managers_warning             OUT NOCOPY BOOLEAN
  ,p_other_manager_warning           OUT NOCOPY BOOLEAN
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_hk_secondary_emp_asg >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a secondary employee assignment for Hong Kong.
 *
 * The API calls the generic API create_secondary_emp_asg. This API cannot be
 * used to create the primary assignment. The primary assignment is created
 * when you create the employee.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The person (p_person_id) and the organization (p_organization_id) must exist
 * at the effective start date of the assignment (p_effective_date).
 *
 * <p><b>Post Success</b><br>
 * The API successfully creates the secondary employee assignment record in the
 * database.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the secondary assignment record and raises an error.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_effective_date Determines when the DateTrack operation takes
 * effect.
 * @param p_person_id Identifies the person for whom you create the Secondary
 * Assignment record.
 * @param p_organization_id {@rep:casecolumn
 * PER_ALL_ASSIGNMENTS_F.ORGANIZATION_ID}
 * @param p_grade_id {@rep:casecolumn PER_ALL_ASSIGNMENTS_F.GRADE_ID}
 * @param p_position_id {@rep:casecolumn PER_ALL_ASSIGNMENTS_F.POSITION_ID}
 * @param p_job_id {@rep:casecolumn PER_ALL_ASSIGNMENTS_F.JOB_ID}
 * @param p_assignment_status_type_id {@rep:casecolumn
 * PER_ALL_ASSIGNMENTS_F.ASSIGNMENT_STATUS_TYPE_ID}
 * @param p_payroll_id {@rep:casecolumn PER_ALL_ASSIGNMENTS_F.PAYROLL_ID}
 * @param p_location_id {@rep:casecolumn PER_ALL_ASSIGNMENTS_F.LOCATION_ID}
 * @param p_supervisor_id {@rep:casecolumn PER_ALL_ASSIGNMENTS_F.SUPERVISOR_ID}
 * @param p_special_ceiling_step_id {@rep:casecolumn
 * PER_ALL_ASSIGNMENTS_F.SPECIAL_CEILING_STEP_ID}
 * @param p_pay_basis_id {@rep:casecolumn PER_ALL_ASSIGNMENTS_F.PAY_BASIS_ID}
 * @param p_assignment_number If the number generation method is Manual then
 * this parameter is mandatory. If the number generation method is Automatic
 * then the value of this parameter must be NULL. When the API Completes, if
 * p_validate is false and the assignment number generation method is Automatic
 * this will be set to the generated assignment number of the person created.
 * If p_validate is false and the assignment number generation method is manual
 * or if p_validate is true this will be set to the value passed.
 * @param p_change_reason Indicates the reason for the last change in the
 * assignment. Valid values are defined by 'EMP_ASSIGN_REASON' lookup type.
 * @param p_comments Comment text.
 * @param p_date_probation_end {@rep:casecolumn
 * PER_ALL_ASSIGNMENTS_F.DATE_PROBATION_END}
 * @param p_default_code_comb_id {@rep:casecolumn
 * PER_ALL_ASSIGNMENTS_F.DEFAULT_CODE_COMB_ID}
 * @param p_employment_category User defined category. For example Full-Time
 * Permanent or Part-Time Permanent. Known as Assignment Category. Valid values
 * are defined by 'EMP_CAT' lookup type.
 * @param p_frequency Determines the Frequency of normal working hours, - week,
 * month, year. Valid values are defined by 'FREQUENCY' lookup type.
 * @param p_internal_address_line {@rep:casecolumn
 * PER_ALL_ASSIGNMENTS_F.INTERNAL_ADDRESS_LINE}
 * @param p_manager_flag {@rep:casecolumn PER_ALL_ASSIGNMENTS_F.MANAGER_FLAG}
 * @param p_normal_hours {@rep:casecolumn PER_ALL_ASSIGNMENTS_F.NORMAL_HOURS}
 * @param p_perf_review_period {@rep:casecolumn
 * PER_ALL_ASSIGNMENTS_F.PERF_REVIEW_PERIOD}
 * @param p_perf_review_period_frequency The Performance Review Frequency units
 * is used with Performance Review Period to define time between reviews. Valid
 * values are defined by 'FREQUENCY' lookup type.
 * @param p_probation_period {@rep:casecolumn
 * PER_ALL_ASSIGNMENTS_F.PROBATION_PERIOD}
 * @param p_probation_unit Determines the Units of probation period duration.
 * Valid values are defined by 'QUALIFYING_UNITS' lookup type.
 * @param p_sal_review_period {@rep:casecolumn
 * PER_ALL_ASSIGNMENTS_F.SAL_REVIEW_PERIOD}
 * @param p_sal_review_period_frequency The Salary Review Frequence Units is
 * used with Salary Review Period to define time between salary reviews. Valid
 * values are defined by 'FREQUENCY' lookup type.
 * @param p_set_of_books_id {@rep:casecolumn
 * PER_ALL_ASSIGNMENTS_F.SET_OF_BOOKS_ID}
 * @param p_source_type Determines the Recruitment activity source for
 * applicant assignment, for example, Advertisement. Valid values are defined
 * by 'REC_TYPE' lookup type.
 * @param p_time_normal_finish {@rep:casecolumn
 * PER_ALL_ASSIGNMENTS_F.TIME_NORMAL_FINISH}
 * @param p_time_normal_start {@rep:casecolumn
 * PER_ALL_ASSIGNMENTS_F.TIME_NORMAL_START}
 * @param p_bargaining_unit_code Determines the Bargaining unit code. Valid
 * values are defined by 'BARGAINING_UNIT_CODE' lookup type.
 * @param p_labour_union_member_flag Indicates if the employee is anAssignment
 * Labour union member. Valid values as applicable are defined by 'YES_NO'
 * lookup type.
 * @param p_hourly_salaried_code Identifies if the assignment is paid by the
 * hour or by a salary. Valid values are defined by 'HOURLY_SALARIED_CODE'
 * lookup type.
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
 * @param p_title Assignment's Title e.g. Mr, Mrs, Dr. Valid values are defined
 * by 'TITLE' lookup type.
 * @param p_legal_employer_id Identifies the resgistered employer for the
 * current assignment.
 * @param p_principal_employer_name Indentifies the name of the Main employer
 * if the employee is working Part time.
 * @param p_include_on_ir56b Include this assignment on the IR56B report, valid
 * values as applicable defined by YES_NO lookup_type
 * @param p_exclusion_reason Indicates the reason why the assignment should not
 * to appear on the IR56B report.
 * @param p_ir56b_message Indicates the message to appear in the IR56B report.
 * @param p_monies_held Indicates if any amount is to be withheld by the
 * employer when the Assignment is leaving the country, Valid values as
 * applicable are defined by YES_NO lookup_type.
 * @param p_estimated_amount_held The amount to be withheld by the employer
 * when the employee is leaving the country.
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
 * @param p_pgp_concat_segments Determines the Concatenated segments for all
 * the people group segments.
 * @param p_assignment_id If p_validate is false, then this uniquely identifies
 * the created Secondary Assignment. If p_validate is true, then set to null.
 * @param p_people_group_id If p_validate is false and if the people group key
 * combination already exists then the existing people group id will be
 * returned else a new poeple group key combination would be created with the
 * segments entered and its people group id returned. If p_validate is
 * true,then the value will be null.
 * @param p_soft_coding_keyflex_id If p_validate is set and the Soft coding key
 * combination already exists, then set to the existing ID else create a new
 * Soft coding key combination and return its value. If p_validate is true or
 * no values are entered for segments contributing to the Soft coding key, then
 * the value will be null.
 * @param p_object_version_number If p_validate is false, then set to the
 * version number of the created Secondary Assignment. If p_validate is true,
 * then the value will be null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * earliest effective start date for the created Secondary Assignment. If
 * p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date for the created Secondary Assignment. If p_validate is
 * true, then set to null.
 * @param p_assignment_sequence If p_validate is false, returns the sequence of
 * the current assignment. If p_validate is true, this value will be null.
 * @param p_comment_id If p_validate is false and comment text was provided,
 * then will be set to the identifier of the created Secondary Assignment
 * comment record. If p_validate is true or no comment text was provided, then
 * will be null.
 * @param p_concatenated_segments If p_validate is false, returns the
 * concatenation of all p_segment parameters. If p_validate is true or no
 * p_segment parameters have been set, this will be null.
 * @param p_group_name if p_validate is false, returns the existing group name.
 * If p_validate is true then returns the new group name.
 * @param p_other_manager_warning If set to true, then a manager existed in the
 * organization prior to calling this API and the manager flag has been set to
 * 'Y' for yes.
 * @rep:displayname Create Secondary Employee Assignment for Hong Kong
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE_ASG
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE create_hk_secondary_emp_asg
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
  ,p_bargaining_unit_code         IN     VARCHAR2 DEFAULT NULL
  ,p_labour_union_member_flag     in     varchar2 default 'N'
  ,p_hourly_salaried_code         IN     VARCHAR2 DEFAULT NULL
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
  ,p_title                                   IN     VARCHAR2 DEFAULT NULL
  ,p_legal_employer_id         IN     VARCHAR2 DEFAULT NULL
  ,p_principal_employer_name         IN     VARCHAR2 DEFAULT NULL
  ,p_include_on_ir56b          IN     VARCHAR2 DEFAULT NULL
  ,p_exclusion_reason          IN     VARCHAR2 DEFAULT NULL
  ,p_ir56b_message               IN     VARCHAR2 DEFAULT NULL
  ,p_Monies_held                 IN     VARCHAR2 DEFAULT NULL
  ,p_estimated_amount_held         IN     VARCHAR2 DEFAULT NULL
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
  ,p_people_group_id                 OUT NOCOPY NUMBER
  ,p_soft_coding_keyflex_id          OUT NOCOPY NUMBER
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
END hr_hk_assignment_api;

 

/
