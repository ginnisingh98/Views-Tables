--------------------------------------------------------
--  DDL for Package HR_AE_ASSIGNMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_AE_ASSIGNMENT_API" AUTHID CURRENT_USER AS
/* $Header: peasgaei.pkh 120.8 2006/04/27 01:12:26 spendhar noship $ */
/*#
 * This package contains assignment APIs.
 * @rep:scope public
 * @rep:product PER
 * @rep:displayname Assignment for UAE
*/
--
-- ----------------------------------------------------------------------------
-- |-------------------< create_ae_secondary_emp_asg >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
/*#
 * This API creates secondary assignment for an employee.
 *
 * The API calls the generic API create_secondary_emp_asg, with parameters set
 * as appropriate for the UAE person. As this API is effectively an
 * alternative to the API create_secondary_emp_asg, see that API for further
 * explanation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The employee must have been created already and must exist at the effective
 * start date of the assignment.
 *
 * <p><b>Post Success</b><br>
 * A new secondary assignment is created for the employee.
 *
 * <p><b>Post Failure</b><br>
 * The API does not create the assignment and raises an error.
 *
 * @param p_validate If true, the database remains unchanged. If FALSE a valid
 * assignment is created IN the database.
 * @param p_effective_date The effective date of the change
 * @param p_person_id Person for whom this assignment applies
 * @param p_organization_id Organization
 * @param p_grade_id Grade
 * @param p_position_id Position
 * @param p_job_id Job
 * @param p_assignment_status_type_id Assignment Status
 * @param p_payroll_id Payroll
 * @param p_location_id Location
 * @param p_special_ceiling_step_id Special ceiling step
 * @param p_pay_basis_id Salary basis
 * @param p_assignment_id ID of the assignment
 * @param p_supervisor_id Supervisor
 * @param p_assignment_number Assignment number
 * @param p_change_reason Reason for change
 * @param p_comments Comments
 * @param p_date_probation_end End date of probation period
 * @param p_default_code_comb_id Foreign key to GL_CODE_COMBINATIONS
 * @param p_employment_category Employment category
 * @param p_frequency Frequency for quoting working hours (eg per week)
 * @param p_internal_address_line Internal address line
 * @param p_manager_flag Indicates whether the employee is a manager
 * @param p_normal_hours Normal working hours
 * @param p_perf_review_period Performance review period
 * @param p_perf_review_period_frequency Units for quoting  performance
 * review period (eg months)
 * @param p_probation_period Length of probation period
 * @param p_probation_unit Units for quoting probation period (eg months)
 * @param p_sal_review_period Salary review period
 * @param p_sal_review_period_frequency Units for quoting salary review
 * period (eg months)
 * @param p_set_of_books_id Set of books (GL)
 * @param p_source_type Recruitment activity source
 * @param p_time_normal_finish Normal work finish time
 * @param p_time_normal_start Normal work start time
 * @param p_bargaining_unit_code Bargaining unit
 * @param p_labour_union_member_flag Labour union member flag
 * @param p_hourly_salaried_code Hourly Salaried code
 * @param p_ass_attribute_category Descriptive flexfield attribute category
 * @param p_ass_attribute1 Descriptive flexfield
 * @param p_ass_attribute2 Descriptive flexfield
 * @param p_ass_attribute3 Descriptive flexfield
 * @param p_ass_attribute4 Descriptive flexfield
 * @param p_ass_attribute5 Descriptive flexfield
 * @param p_ass_attribute6 Descriptive flexfield
 * @param p_ass_attribute7 Descriptive flexfield
 * @param p_ass_attribute8 Descriptive flexfield
 * @param p_ass_attribute9 Descriptive flexfield
 * @param p_ass_attribute10 Descriptive flexfield
 * @param p_ass_attribute11 Descriptive flexfield
 * @param p_ass_attribute12 Descriptive flexfield
 * @param p_ass_attribute13 Descriptive flexfield
 * @param p_ass_attribute14 Descriptive flexfield
 * @param p_ass_attribute15 Descriptive flexfield
 * @param p_ass_attribute16 Descriptive flexfield
 * @param p_ass_attribute17 Descriptive flexfield
 * @param p_ass_attribute18 Descriptive flexfield
 * @param p_ass_attribute19 Descriptive flexfield
 * @param p_ass_attribute20 Descriptive flexfield
 * @param p_ass_attribute21 Descriptive flexfield
 * @param p_ass_attribute22 Descriptive flexfield
 * @param p_ass_attribute23 Descriptive flexfield
 * @param p_ass_attribute24 Descriptive flexfield
 * @param p_ass_attribute25 Descriptive flexfield
 * @param p_ass_attribute26 Descriptive flexfield
 * @param p_ass_attribute27 Descriptive flexfield
 * @param p_ass_attribute28 Descriptive flexfield
 * @param p_ass_attribute29 Descriptive flexfield
 * @param p_ass_attribute30 Descriptive flexfield
 * @param p_title Title -must be NULL
 * @param p_employer Employer
 * @param p_civil_reg_number Civil Registration Number
 * @param p_social_sec_number Social Security Number
 * @param p_contribution_start_date Contribution Start Date
 * @param p_latest_qualification Latest Qualification
 * @param p_accommodation_provided Indicates whether Accommodation is provided
 * @param p_transportation_provided Indicates whether Transportation is provided
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
 * @param p_pgp_concat_segments Concatenated people group segments
 * @param p_people_group_id People group id
 * @param p_assignment_sequence Assignment sequence
 * @param p_group_name Group name
 * Post Success:
 * The API sets the following OUT parameters:
 * @param p_object_version_number If p_validate is FALSE, set to the new object
 * version number of the updated assignment record. If p_validate is true, set
 * to the passed IN value.
 * @param p_soft_coding_keyflex_id If p_validate is FALSE and any p_segment
 * parameters have set text, set to the id of the corresponding soft coding
 * keyflex row.  If p_validate is true, or no p_segment parameters have set
 * text, this will be NULL.
 * @param p_comment_id If p_validate is FALSE and any comment text exists,
 * set to the id of the corresponding assignment comment row.  If p_validate is
 * true, or no comment text exists this will be NULL.
 * @param p_effective_start_date  If p_validate is FALSE, set to the effective
 * start DATE of the assignment. If p_validate is true, set to NULL.
 * @param p_effective_end_date If p_validate is FALSE, set to the effective end
 * DATE of the assignment. If p_validate is true, set to NULL.
 * @param p_concatenated_segments If p_validate is FALSE and any p_segment
 * parameters have set text, set to the concatenation of all p_segment parameters with
 * set text. If p_validate is true, or no p_segment parameters have set text, this
 * will be NULL.
 * @param p_other_manager_warning If p_validate is FALSE then set to true if manager_flag is
 * changed from 'N' to 'Y' and a manager already exists IN the organization, p_organization_id,
 * at p_effective_date. Set to FALSE if no other managers exist IN p_organization_id.This is
 * always set to FALSE if manager_flag is not updated.The warning value only applies as of
 * p_effective_date.  If p_validate is true then set to FALSE.
 * @rep:displayname Create Secondary Employee Assignment for UAE
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE_ASG
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
--
PROCEDURE create_ae_secondary_emp_asg
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
  ,p_civil_reg_number             IN     VARCHAR2 DEFAULT NULL
  ,p_social_sec_number            IN     VARCHAR2 DEFAULT NULL
  ,p_contribution_start_date      IN     VARCHAR2 DEFAULT NULL
  ,p_latest_qualification         IN     VARCHAR2 DEFAULT NULL
  ,p_accommodation_provided       IN     VARCHAR2 DEFAULT NULL
  ,p_transportation_provided      IN     VARCHAR2 DEFAULT NULL
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

-- ----------------------------------------------------------------------------
-- |--------------------------< update_ae_emp_asg >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
/*#
 * This API updates employee assignment details which do not
 * affect entitlement to element entries.
 *
 * The API calls the generic API update_emp_asg, with parameters set as
 * appropriate for the UAE employee assignment. As this API is effectively an
 * alternative to the API update_emp_asg, see that API for further explanation.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * The assignment must exist as of the effective date and must be an employee
 * assignment.
 *
 * <p><b>Post Success</b><br>
 * The assignment will have been updated.
 *
 * <p><b>Post Failure</b><br>
 * The assignment will not be updated and an error will be raised.

 * @param p_validate If true, the database remains unchanged. If FALSE a valid
 * assignment is created IN the database.
 * @param p_effective_date The effective date of the change
 * @param p_datetrack_update_mode Update mode
 * @param p_assignment_id ID of the assignment
 * @param p_supervisor_id Supervisor
 * @param p_assignment_number Assignment number
 * @param p_change_reason Reason for change
 * @param p_comments Comments
 * @param p_date_probation_end End date of probation period
 * @param p_default_code_comb_id Foreign key to GL_CODE_COMBINATIONS
 * @param p_frequency Frequency for quoting working hours (eg per week)
 * @param p_internal_address_line Internal address line
 * @param p_manager_flag Indicates whether the employee is a manager
 * @param p_normal_hours Normal working hours
 * @param p_perf_review_period Performance review period
 * @param p_perf_review_period_frequency Units for quoting  performance
 * review period (eg months)
 * @param p_probation_period Length of probation period
 * @param p_probation_unit Units for quoting probation period (eg months)
 * @param p_sal_review_period Salary review period
 * @param p_sal_review_period_frequency Units for quoting salary review
 * period (eg months)
 * @param p_set_of_books_id Set of books (GL)
 * @param p_source_type Recruitment activity source
 * @param p_time_normal_finish Normal work finish time
 * @param p_time_normal_start Normal work start time
 * @param p_bargaining_unit_code Bargaining unit
 * @param p_labour_union_member_flag Labour union member flag
 * @param p_hourly_salaried_code Hourly Salaried code
 * @param p_ass_attribute_category Descriptive flexfield attribute category
 * @param p_ass_attribute1 Descriptive flexfield
 * @param p_ass_attribute2 Descriptive flexfield
 * @param p_ass_attribute3 Descriptive flexfield
 * @param p_ass_attribute4 Descriptive flexfield
 * @param p_ass_attribute5 Descriptive flexfield
 * @param p_ass_attribute6 Descriptive flexfield
 * @param p_ass_attribute7 Descriptive flexfield
 * @param p_ass_attribute8 Descriptive flexfield
 * @param p_ass_attribute9 Descriptive flexfield
 * @param p_ass_attribute10 Descriptive flexfield
 * @param p_ass_attribute11 Descriptive flexfield
 * @param p_ass_attribute12 Descriptive flexfield
 * @param p_ass_attribute13 Descriptive flexfield
 * @param p_ass_attribute14 Descriptive flexfield
 * @param p_ass_attribute15 Descriptive flexfield
 * @param p_ass_attribute16 Descriptive flexfield
 * @param p_ass_attribute17 Descriptive flexfield
 * @param p_ass_attribute18 Descriptive flexfield
 * @param p_ass_attribute19 Descriptive flexfield
 * @param p_ass_attribute20 Descriptive flexfield
 * @param p_ass_attribute21 Descriptive flexfield
 * @param p_ass_attribute22 Descriptive flexfield
 * @param p_ass_attribute23 Descriptive flexfield
 * @param p_ass_attribute24 Descriptive flexfield
 * @param p_ass_attribute25 Descriptive flexfield
 * @param p_ass_attribute26 Descriptive flexfield
 * @param p_ass_attribute27 Descriptive flexfield
 * @param p_ass_attribute28 Descriptive flexfield
 * @param p_ass_attribute29 Descriptive flexfield
 * @param p_ass_attribute30 Descriptive flexfield
 * @param p_title Title -must be NULL
 * @param p_employer Employer
 * @param p_civil_reg_number Civil Registration Number
 * @param p_social_sec_number Social Security Number
 * @param p_contribution_start_date Contribution Start Date
 * @param p_latest_qualification Latest Qualification
 * @param p_accommodation_provided Indicates whether Accommodation is provided
 * @param p_transportation_provided Indicates whether Transportation is provided
 * Post Success:
 * The API sets the following OUT parameters:
 * @param p_object_version_number If p_validate is FALSE, set to the new object
 * version NUMBER of the updated assignment record. If p_validate is true, set
 * to the passed IN value.
 * @param p_soft_coding_keyflex_id If p_validate is FALSE and any p_segment
 * parameters have set text, set to the id of the corresponding soft coding
 * keyflex row.  If p_validate is true, or no p_segment parameters have set
 * text, this will be NULL.
 * @param p_comment_id If p_validate is FALSE and any comment text exists,
 * set to the id of the corresponding assignment comment row.  If p_validate is
 * true, or no comment text exists this will be NULL.
 * @param p_effective_start_date  If p_validate is FALSE, set to the effective
 * start DATE of the assignment. If p_validate is true, set to NULL.
 * @param p_effective_end_date If p_validate is FALSE, set to the effective end
 * DATE of the assignment. If p_validate is true, set to NULL.
 * @param p_concatenated_segments If p_validate is FALSE and any p_segment
 * parameters have set text, set to the concatenation of all p_segment parameters with
 * set text. If p_validate is true, or no p_segment parameters have set text, this
 * will be NULL.
 * @param p_no_managers_warning If p_validate is FALSE then set to true if manager_flag is
 * updated from 'Y' to 'N' and no other manager exists IN p_organization_id. Set to FALSE
 * if another manager exists IN p_organization_id.This parameter is always set to FALSE if
 * manager_flag is not updated. The warning value only applies as of p_effective_date.
 * If p_validate is true then set to FALSE.
 * @param p_other_manager_warning If p_validate is FALSE then set to true if manager_flag is
 * changed from 'N' to 'Y' and a manager already exists IN the organization, p_organization_id,
 * at p_effective_date. Set to FALSE if no other managers exist IN p_organization_id.This is
 * always set to FALSE if manager_flag is not updated.The warning value only applies as of
 * p_effective_date.  If p_validate is true then set to FALSE.
 * @rep:displayname Updates Secondary Employee Assignment for UAE
 * @rep:category BUSINESS_ENTITY PER_EMPLOYEE_ASG
 * @rep:lifecycle active
 * @rep:scope public
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE update_ae_emp_asg
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
  ,p_employer		          IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_civil_reg_number             IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_social_sec_number            IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_contribution_start_date      IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_latest_qualification         IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_accommodation_provided       IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_transportation_provided      IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_comment_id                      OUT NOCOPY NUMBER
  ,p_soft_coding_keyflex_id          OUT NOCOPY NUMBER
  ,p_effective_start_date            OUT NOCOPY DATE
  ,p_effective_end_date              OUT NOCOPY DATE
  ,p_concatenated_segments           OUT NOCOPY VARCHAR2
  ,p_no_managers_warning             OUT NOCOPY BOOLEAN
  ,p_other_manager_warning           OUT NOCOPY BOOLEAN
  );
END hr_ae_assignment_api;

/
