--------------------------------------------------------
--  DDL for Package HR_SG_ASSIGNMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_SG_ASSIGNMENT_API" AUTHID CURRENT_USER as
/* $Header: hrsgwras.pkh 120.1 2005/10/02 02:06:08 aroussel $ */
/*#
 * This package contains assignment related APIs.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Assignment for Singapore
*/
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_sg_secondary_emp_asg >--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API creates a secondary assignment for an existing Singapore employee.
 *
 * The API calls the generic API hr_assignment_api.create_secondary_emp_asg.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The employee and primary assignment must exist at the effective start date
 * of the assignment creation.
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
 * @param p_person_id Identifies the person for whom you create the secondary
 * assignment record.
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
 * @param p_perf_review_period_frequency The Frequency units is used with
 * PERF_REVIEW_PERIOD to define time between reviews. Valid values are defined
 * by 'FREQUENCY' lookup type.
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
 * @param p_labour_union_member_flag Indicates if the employee is an Assignment
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
 * @param p_title Title e.g. Mr, Mrs, Dr. Valid values are defined by 'TITLE'
 * lookup type.
 * @param p_legal_employer_id Indicates the Legal employer ID for the current
 * assignment
 * @param p_contract_id Indicates the Contract ID for the assignment
 * @param p_establishment_id Indicates the Establishment ID of the assignment
 * @param p_collective_agreement_id Indicates the Collective agreement ID of
 * the assignment
 * @param p_cagr_id_flex_num This context value determines which Flexfield
 * Structure to use with the Descriptive flexfield segments.
 * @param p_cag_segment1 Descriptive flexfield segment.
 * @param p_cag_segment2 Descriptive flexfield segment.
 * @param p_cag_segment3 Descriptive flexfield segment.
 * @param p_cag_segment4 Descriptive flexfield segment.
 * @param p_cag_segment5 Descriptive flexfield segment.
 * @param p_cag_segment6 Descriptive flexfield segment.
 * @param p_cag_segment7 Descriptive flexfield segment.
 * @param p_cag_segment8 Descriptive flexfield segment.
 * @param p_cag_segment9 Descriptive flexfield segment.
 * @param p_cag_segment10 Descriptive flexfield segment.
 * @param p_cag_segment11 Descriptive flexfield segment.
 * @param p_cag_segment12 Descriptive flexfield segment.
 * @param p_cag_segment13 Descriptive flexfield segment.
 * @param p_cag_segment14 Descriptive flexfield segment.
 * @param p_cag_segment15 Descriptive flexfield segment.
 * @param p_cag_segment16 Descriptive flexfield segment.
 * @param p_cag_segment17 Descriptive flexfield segment.
 * @param p_cag_segment18 Descriptive flexfield segment.
 * @param p_cag_segment19 Descriptive flexfield segment.
 * @param p_cag_segment20 Descriptive flexfield segment.
 * @param p_group_name if p_validate is false, returns the existing group name.
 * If p_validate is true then returns the new group name.
 * @param p_concatenated_segments If p_validate is false, returns the
 * concatenation of all p_segment parameters. If p_validate is true or no
 * p_segment parameters have been set, this will be null.
 * @param p_cagr_grade_def_id Indicates the Category grate definition id for
 * the current assignment
 * @param p_cagr_concatenated_segments If p_validate is false, returns the
 * concatenation of all p_cag_segment parameters. If p_validate is true or no
 * p_cag_segment parameters have been set, this will be null.
 * @param p_assignment_id If p_validate is false, then this uniquely identifies
 * the created assignment. If p_validate is true, then set to null.
 * @param p_soft_coding_keyflex_id If p_validate is false and the Soft coding
 * key combination already exists, then retrun the current ID. If p_validate is
 * true, the ID will be the assignments current value.
 * @param p_people_group_id If p_validate is false, if the people group key
 * combination already exists then the current people group id will be
 * returned. If p_validate is true, the id will be the assignments current
 * value.
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
 * @rep:displayname Create Secondary Employee Assignment for Singapore
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE_ASG
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE create_sg_secondary_emp_asg
 (p_validate                         in        boolean    default false
 ,p_effective_date                   in	       date
 ,p_person_id                        in	       number
 ,p_organization_id                  in	       number
 ,p_grade_id                         in        number     default null
 ,p_position_id                      in        number     default null
 ,p_job_id                           in        number     default null
 ,p_assignment_status_type_id        in        number     default null
 ,p_payroll_id                       in        number     default null
 ,p_location_id                      in        number     default null
 ,p_supervisor_id                    in        number     default null
 ,p_special_ceiling_step_id          in        number     default null
 ,p_pay_basis_id                     in        number     default null
 ,p_assignment_number                in out    nocopy varchar2
 ,p_change_reason                    in        varchar2   default null
 ,p_comments                         in        varchar2   default null
 ,p_date_probation_end               in        date       default null
 ,p_default_code_comb_id             in        number     default null
 ,p_employment_category              in        varchar2   default null
 ,p_frequency                        in        varchar2   default null
 ,p_internal_address_line            in        varchar2   default null
 ,p_manager_flag                     in        varchar2   default null
 ,p_normal_hours                     in        number     default null
 ,p_perf_review_period               in        number     default null
 ,p_perf_review_period_frequency     in        varchar2   default null
 ,p_probation_period                 in        number     default null
 ,p_probation_unit                   in        varchar2   default null
 ,p_sal_review_period                in        number     default null
 ,p_sal_review_period_frequency      in        varchar2   default null
 ,p_set_of_books_id                  in        number     default null
 ,p_source_type                      in        varchar2   default null
 ,p_time_normal_finish               in        varchar2   default null
 ,p_time_normal_start                in        varchar2   default null
 ,p_bargaining_unit_code             in        varchar2   default null
 ,p_labour_union_member_flag         in        varchar2   default null
 ,p_hourly_salaried_code             in        varchar2   default null
 ,p_ass_attribute_category           in        varchar2   default null
 ,p_ass_attribute1                   in        varchar2   default null
 ,p_ass_attribute2                   in        varchar2   default null
 ,p_ass_attribute3                   in        varchar2   default null
 ,p_ass_attribute4                   in        varchar2   default null
 ,p_ass_attribute5                   in        varchar2   default null
 ,p_ass_attribute6                   in        varchar2   default null
 ,p_ass_attribute7                   in        varchar2   default null
 ,p_ass_attribute8                   in        varchar2   default null
 ,p_ass_attribute9                   in        varchar2   default null
 ,p_ass_attribute10                  in        varchar2   default null
 ,p_ass_attribute11                  in        varchar2   default null
 ,p_ass_attribute12                  in        varchar2   default null
 ,p_ass_attribute13                  in        varchar2   default null
 ,p_ass_attribute14                  in        varchar2   default null
 ,p_ass_attribute15                  in        varchar2   default null
 ,p_ass_attribute16                  in        varchar2   default null
 ,p_ass_attribute17                  in        varchar2   default null
 ,p_ass_attribute18                  in        varchar2   default null
 ,p_ass_attribute19                  in        varchar2   default null
 ,p_ass_attribute20                  in        varchar2   default null
 ,p_ass_attribute21                  in        varchar2   default null
 ,p_ass_attribute22                  in        varchar2   default null
 ,p_ass_attribute23                  in        varchar2   default null
 ,p_ass_attribute24                  in        varchar2   default null
 ,p_ass_attribute25                  in        varchar2   default null
 ,p_ass_attribute26                  in        varchar2   default null
 ,p_ass_attribute27                  in        varchar2   default null
 ,p_ass_attribute28                  in        varchar2   default null
 ,p_ass_attribute29                  in        varchar2   default null
 ,p_ass_attribute30                  in        varchar2   default null
 ,p_title                            in        varchar2   default null
 ,p_legal_employer_id                in        varchar2   default null
 ,p_contract_id                      in        number     default null
 ,p_establishment_id                 in        number     default null
 ,p_collective_agreement_id          in        number     default null
 ,p_cagr_id_flex_num                 in        number     default null
 ,p_cag_segment1                     in        varchar2   default null
 ,p_cag_segment2                     in        varchar2   default null
 ,p_cag_segment3                     in        varchar2   default null
 ,p_cag_segment4                     in        varchar2   default null
 ,p_cag_segment5                     in        varchar2   default null
 ,p_cag_segment6                     in        varchar2   default null
 ,p_cag_segment7                     in        varchar2   default null
 ,p_cag_segment8                     in        varchar2   default null
 ,p_cag_segment9                     in        varchar2   default null
 ,p_cag_segment10                    in        varchar2   default null
 ,p_cag_segment11                    in        varchar2   default null
 ,p_cag_segment12                    in        varchar2   default null
 ,p_cag_segment13                    in        varchar2   default null
 ,p_cag_segment14                    in        varchar2   default null
 ,p_cag_segment15                    in        varchar2   default null
 ,p_cag_segment16                    in        varchar2   default null
 ,p_cag_segment17                    in        varchar2   default null
 ,p_cag_segment18                    in        varchar2   default null
 ,p_cag_segment19                    in        varchar2   default null
 ,p_cag_segment20                    in        varchar2   default null
 ,p_group_name                       out       nocopy varchar2
 ,p_concatenated_segments            out       nocopy  varchar2
 ,p_cagr_grade_def_id                out       nocopy number
 ,p_cagr_concatenated_segments       out       nocopy varchar2
 ,p_assignment_id                    out       nocopy number
 ,p_soft_coding_keyflex_id           out       nocopy number
 ,p_people_group_id                  out       nocopy number
 ,p_object_version_number            out       nocopy number
 ,p_effective_start_date             out       nocopy date
 ,p_effective_end_date               out       nocopy date
 ,p_assignment_sequence              out       nocopy number
 ,p_comment_id                       out       nocopy number
 ,p_other_manager_warning            out       nocopy boolean);
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_sg_emp_asg >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * This API updates employee assignment details for Singapore.
 *
 * The API calls the generic API update_emp_asg, with parameters set as
 * appropriate for Singapore.
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
 * will be set to the new version number of the updated assignment. If
 * p_validate is true will be set to the same value which was passed in.
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
 * @param p_perf_review_period_frequency The Frequency units will be used along
 * with PERF_REVIEW_PERIOD to define the time between reviews. Valid values are
 * defined by 'FREQUENCY' lookup type.
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
 * type.
 * @param p_time_normal_finish {@rep:casecolumn
 * PER_ALL_ASSIGNMENTS_F.TIME_NORMAL_FINISH}
 * @param p_time_normal_start {@rep:casecolumn
 * PER_ALL_ASSIGNMENTS_F.TIME_NORMAL_START}
 * @param p_bargaining_unit_code Bargaining unit code. Valid values are defined
 * by 'BARGAINING_UNIT_CODE' lookup type.
 * @param p_labour_union_member_flag Indicates if the employee is an Assignment
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
 * @param p_title Title e.g. Mr, Mrs, Dr. Valid values are defined by 'TITLE'
 * lookup type.
 * @param p_legal_employer_id Indicates the Legal employer ID for the current
 * assignment
 * @param p_cagr_grade_def_id Indicates the Category grate definition id for
 * the current assignment
 * @param p_cagr_concatenated_segments If p_validate is false, returns the
 * concatenation of all p_cag_segment parameters. If p_validate is true or no
 * p_cag_segment parameters have been set, this will be null.
 * @param p_concatenated_segments If p_validate is false, returns the
 * concatenation of all p_segment parameters. If p_validate is true or no
 * p_segment parameters have been set, this will be null.
 * @param p_soft_coding_keyflex_id If p_validate is false, returns the
 * corresponding soft coding keyflex row. If p_validate is true or no p_segment
 * parameters have been set text, this will be null.
 * @param p_comment_id If p_validate is false and new or existing comment text
 * exists, then will be set to the identifier of the assignment comment record.
 * If p_validate is true or no comment text exists, then will be null.
 * @param p_effective_start_date If p_validate is false, then set to the
 * effective start date on the updated assignment row which now exists as of
 * the effective date. If p_validate is true, then set to null.
 * @param p_effective_end_date If p_validate is false, then set to the
 * effective end date on the updated assignment row which now exists as of the
 * effective date. If p_validate is true, then set to null.
 * @param p_no_managers_warning If manager_flag has been updated from 'Y' to
 * 'N' and no other manager exists in p_organization_id, then set to true. If
 * another manager exists in p_organization_id, then set to false. If
 * manager_flag is not updated, then always set the value to false.
 * @param p_other_manager_warning If set to true, then a manager existed in the
 * organization prior to calling this API and the manager flag has been set to
 * 'Y' for yes.
 * @rep:displayname Update Employee Assignment for Singapore
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE_ASG
 * @rep:category MISC_EXTENSIONS HR_DATAPUMP
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
 PROCEDURE update_sg_emp_asg
 (p_validate                        in 	 boolean  default false
 ,p_effective_date               	in 	 date
 ,p_datetrack_update_mode        	in 	 varchar2
 ,p_assignment_id                	in 	 number
 ,p_object_version_number        	in out nocopy number
 ,p_supervisor_id                	in  	 number   default null
 ,p_assignment_number            	in  	 varchar2 default null
 ,p_change_reason                	in  	 varchar2 default null
 ,p_comments                     	in  	 varchar2 default null
 ,p_date_probation_end           	in  	 date     default null
 ,p_default_code_comb_id         	in  	 number   default null
 ,p_frequency                    	in  	varchar2 default null
 ,p_internal_address_line        	in  	varchar2 default null
 ,p_manager_flag                 	in  	varchar2 default null
 ,p_normal_hours                 	in  	number   default null
 ,p_perf_review_period           	in  	number   default null
 ,p_perf_review_period_frequency 	in  	varchar2 default null
 ,p_probation_period             	in  	number   default null
 ,p_probation_unit               	in  	varchar2 default null
 ,p_sal_review_period            	in  	number   default null
 ,p_sal_review_period_frequency  	in  	varchar2 default null
 ,p_set_of_books_id              	in  	number   default null
 ,p_source_type                  	in  	varchar2 default null
 ,p_time_normal_finish           	in  	varchar2 default null
 ,p_time_normal_start            	in  	varchar2 default null
 ,p_bargaining_unit_code         	in  	varchar2 default null
 ,p_labour_union_member_flag     	in  	varchar2 default null
 ,p_hourly_salaried_code         	in  	varchar2 default null
 ,p_ass_attribute_category       	in  	varchar2 default null
 ,p_ass_attribute1               	in  	varchar2 default null
 ,p_ass_attribute2               	in  	varchar2 default null
 ,p_ass_attribute3               	in  	varchar2 default null
 ,p_ass_attribute4               	in  	varchar2 default null
 ,p_ass_attribute5               	in  	varchar2 default null
 ,p_ass_attribute6               	in  	varchar2 default null
 ,p_ass_attribute7               	in  	varchar2 default null
 ,p_ass_attribute8               	in  	varchar2 default null
 ,p_ass_attribute9               	in  	varchar2 default null
 ,p_ass_attribute10              	in  	varchar2 default null
 ,p_ass_attribute11              	in  	varchar2 default null
 ,p_ass_attribute12              	in  	varchar2 default null
 ,p_ass_attribute13              	in  	varchar2 default null
 ,p_ass_attribute14              	in  	varchar2 default null
 ,p_ass_attribute15              	in  	varchar2 default null
 ,p_ass_attribute16              	in  	varchar2 default null
 ,p_ass_attribute17              	in  	varchar2 default null
 ,p_ass_attribute18              	in  	varchar2 default null
 ,p_ass_attribute19              	in  	varchar2 default null
 ,p_ass_attribute20              	in  	varchar2 default null
 ,p_ass_attribute21              	in  	varchar2 default null
 ,p_ass_attribute22              	in  	varchar2 default null
 ,p_ass_attribute23              	in  	varchar2 default null
 ,p_ass_attribute24              	in  	varchar2 default null
 ,p_ass_attribute25              	in  	varchar2 default null
 ,p_ass_attribute26              	in  	varchar2 default null
 ,p_ass_attribute27              	in  	varchar2 default null
 ,p_ass_attribute28              	in  	varchar2 default null
 ,p_ass_attribute29              	in  	varchar2 default null
 ,p_ass_attribute30              	in  	varchar2 default null
 ,p_title                        	in  	varchar2 default null
 ,p_legal_employer_id                   in 	varchar2 default null
 ,p_cagr_grade_def_id            	out 	nocopy varchar2
 ,p_cagr_concatenated_segments   	out 	nocopy varchar2
 ,p_concatenated_segments        	out 	nocopy varchar2
 ,p_soft_coding_keyflex_id       	out 	nocopy number
 ,p_comment_id                   	out 	nocopy number
 ,p_effective_start_date         	out 	nocopy date
 ,p_effective_end_date           	out 	nocopy date
 ,p_no_managers_warning          	out 	nocopy boolean
 ,p_other_manager_warning		out	nocopy boolean);

END hr_sg_assignment_api;

 

/
