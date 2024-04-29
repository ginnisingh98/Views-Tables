--------------------------------------------------------
--  DDL for Package Body HR_CN_ASSIGNMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_CN_ASSIGNMENT_API" AS
/* $Header: hrcnwras.pkb 120.0 2005/05/30 23:18:46 appldev noship $ */


     g_package  VARCHAR2(33);

-- ----------------------------------------------------------------------------
-- |---------------------< create_cn_secondary_emp_asg >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Procedure creates secondary employment assignment for an employee.
--
-- Prerequisites:
--   The person (p_person_id) and the organization (p_organization_id)
--   must exist at the effective start date of the assignment (p_effective_date).
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                          boolean  If true, the database remains
--                                                unchanged. If false a valid
--                                                assignment is created in
--                                                the database.
--   p_effective_date                Yes date     The effective start date of
--                                                this assignment
--   p_person_id                     Yes number   The person for whom this
--                                                assigment applies
--   p_organization_id               Yes number   Organization
--   p_grade_id                          number   Grade
--   p_position_id                       number   Position
--   p_job_id                            number   Job
--   p_assignment_status_type_id         number   Assigmnent status
--   p_payroll_id                        number   Payroll
--   p_location_id                       number   Location
--   p_supervisor_id                     number   Supervisor
--   p_special_ceiling_step_id           number   Special ceiling step
--   p_pay_basis_id                      number   Salary basis
--   p_assignment_number                 varchar2 Assignment number
--   p_change_reason                     varchar2 Change reason
--   p_comments                          varchar2 Comments
--   p_date_probation_end                date     End date of probation period
--   p_default_code_comb_id              number   Foreign key to
--                                                GL_CODE_COMBINATIONS
--   p_employment_category               varchar2 Employment category
--   p_frequency                         varchar2 Frequency for quoting --                                                working hours (eg per week)
--   p_internal_address_line             varchar2 Internal address line
--   p_manager_flag                      varchar2 Indicates whether employee
--                                                is a manager
--   p_normal_hours                      number   Normal working hours
--   p_perf_review_period                number   Performance review period
--   p_perf_review_period_frequency      varchar2 Units for quoting performance
--                                                review period (eg months)
--   p_probation_period                  number   Length of probation period
--   p_probation_unit                    varchar2 Units for quoting --                                                probation period (eg months)
--   p_sal_review_period                 number   Salary review period
--   p_sal_review_period_frequency       varchar2 Units for quoting salary
--                                                review period (eg months)
--   p_set_of_books_id                   number   Set of books (GL)
--   p_source_type                       varchar2 Recruitment activity source
--   p_time_normal_finish                varchar2 Normal work finish time
--   p_time_normal_start                 varchar2 Normal work start time
--   p_bargaining_unit_code              varchar2 Code for bargaining unit
--   p_labour_union_member_flag          varchar2 Indicates whether employee
--                                                is a labour union member
--   p_hourly_salaried_code              varchar2 Hourly or salaried pay code
--   p_ass_attribute_category            varchar2 Descriptive flexfield
--                                                attribute category
--   p_ass_attribute1                    varchar2 Descriptive flexfield
--   p_ass_attribute2                    varchar2 Descriptive flexfield
--   p_ass_attribute3                    varchar2 Descriptive flexfield
--   p_ass_attribute4                    varchar2 Descriptive flexfield
--   p_ass_attribute5                    varchar2 Descriptive flexfield
--   p_ass_attribute6                    varchar2 Descriptive flexfield
--   p_ass_attribute7                    varchar2 Descriptive flexfield
--   p_ass_attribute8                    varchar2 Descriptive flexfield
--   p_ass_attribute9                    varchar2 Descriptive flexfield
--   p_ass_attribute10                   varchar2 Descriptive flexfield
--   p_ass_attribute11                   varchar2 Descriptive flexfield
--   p_ass_attribute12                   varchar2 Descriptive flexfield
--   p_ass_attribute13                   varchar2 Descriptive flexfield
--   p_ass_attribute14                   varchar2 Descriptive flexfield
--   p_ass_attribute15                   varchar2 Descriptive flexfield
--   p_ass_attribute16                   varchar2 Descriptive flexfield
--   p_ass_attribute17                   varchar2 Descriptive flexfield
--   p_ass_attribute18                   varchar2 Descriptive flexfield
--   p_ass_attribute19                   varchar2 Descriptive flexfield
--   p_ass_attribute20                   varchar2 Descriptive flexfield
--   p_ass_attribute21                   varchar2 Descriptive flexfield
--   p_ass_attribute22                   varchar2 Descriptive flexfield
--   p_ass_attribute23                   varchar2 Descriptive flexfield
--   p_ass_attribute24                   varchar2 Descriptive flexfield
--   p_ass_attribute25                   varchar2 Descriptive flexfield
--   p_ass_attribute26                   varchar2 Descriptive flexfield
--   p_ass_attribute27                   varchar2 Descriptive flexfield
--   p_ass_attribute28                   varchar2 Descriptive flexfield
--   p_ass_attribute29                   varchar2 Descriptive flexfield
--   p_ass_attribute30                   varchar2 Descriptive flexfield
--   p_title                             varchar2 Title -must be NULL
--   p_employer_id                  Yes  varchar2 Employer ID
--   p_tax_area_code                Yes  varchar2 Tax Area Code
--   p_sic_area_code                     varchar2 SIC Area Code
--   p_salary_payout_locn                varchar2 Salary Payout Location
--   p_special_tax_exmp_category         varchar2 Special Tax Exemption Category --   Bug 3828396 Added
--   p_pgp_segment1                      varchar2 People group segment
--   p_pgp_segment2                      varchar2 People group segment
--   p_pgp_segment3                      varchar2 People group segment
--   p_pgp_segment4                      varchar2 People group segment
--   p_pgp_segment5                      varchar2 People group segment
--   p_pgp_segment6                      varchar2 People group segment
--   p_pgp_segment7                      varchar2 People group segment
--   p_pgp_segment8                      varchar2 People group segment
--   p_pgp_segment9                      varchar2 People group segment
--   p_pgp_segment10                     varchar2 People group segment
--   p_pgp_segment11                     varchar2 People group segment
--   p_pgp_segment12                     varchar2 People group segment
--   p_pgp_segment13                     varchar2 People group segment
--   p_pgp_segment14                     varchar2 People group segment
--   p_pgp_segment15                     varchar2 People group segment
--   p_pgp_segment16                     varchar2 People group segment
--   p_pgp_segment17                     varchar2 People group segment
--   p_pgp_segment18                     varchar2 People group segment
--   p_pgp_segment19                     varchar2 People group segment
--   p_pgp_segment20                     varchar2 People group segment
--   p_pgp_segment21                     varchar2 People group segment
--   p_pgp_segment22                     varchar2 People group segment
--   p_pgp_segment23                     varchar2 People group segment
--   p_pgp_segment24                     varchar2 People group segment
--   p_pgp_segment25                     varchar2 People group segment
--   p_pgp_segment26                     varchar2 People group segment
--   p_pgp_segment27                     varchar2 People group segment
--   p_pgp_segment28                     varchar2 People group segment
--   p_pgp_segment29                     varchar2 People group segment
--   p_pgp_segment30                     varchar2 People group segment
--   p_contract_id                       in number contract
--   p_establishment_id                  in number establishment
--   p_collective_agreement_id           in number collective_agreement
--   p_cagr_id_flex_num                  in number collective_Agreement
--                                                 grade structure
--   p_cag_segment1                      in varchar2 Collective agreement grade
--   p_cag_segment2                      in varchar2 Collective agreement grade
--   p_cag_segment3                      in varchar2 Collective agreement grade
--   p_cag_segment4                      in varchar2 Collective agreement grade
--   p_cag_segment5                      in varchar2 Collective agreement grade
--   p_cag_segment6                      in varchar2 Collective agreement grade
--   p_cag_segment7                      in varchar2 Collective agreement grade
--   p_cag_segment8                      in varchar2 Collective agreement grade
--   p_cag_segment9                      in varchar2 Collective agreement grade
--   p_cag_segment10                     in varchar2 Collective agreement grade
--   p_cag_segment11                     in varchar2 Collective agreement grade
--   p_cag_segment12                     in varchar2 Collective agreement grade
--   p_cag_segment13                     in varchar2 Collective agreement grade
--   p_cag_segment14                     in varchar2 Collective agreement grade
--   p_cag_segment15                     in varchar2 Collective agreement grade
--   p_cag_segment16                     in varchar2 Collective agreement grade
--   p_cag_segment17                     in varchar2 Collective agreement grade
--   p_cag_segment18                     in varchar2 Collective agreement grade
--   p_cag_segment19                     in varchar2 Collective agreement grade
--   p_cag_segment20                     in varchar2 Collective agreement grade
--   p_notice_period                     in number   Notice Period
--   p_notice_period_uom                 in varchar2 Notice Period Units
--   p_employee_category                 in varchar2 Employee Category
--   p_work_at_home                      in varchar2 Work At Home
--   p_job_post_source_name		 in varchar2 Job Source
--
-- Post Success:
--   The API sets the following out parameters:
--
--   Name                           Type     Description
--   p_assignment_number            varchar2 If an assignment number is not
--                                           passed in, a value is generated.
--   p_assignment_id                number   Unique ID for the assignment
--                                           created by the API
--   p_soft_coding_keyflex_id       number   Soft coding combination ID
--   p_people_group_id              number   People Group combination ID
--   p_object_version_number        number   Version number of the new
--                                           assignment
--   p_effective_start_date         date     Effective start date of this
--                                           assignment
--   p_effective_end_date           date     Effective end date of this
--                                           assignment
--   p_assignment_sequence          number
--   p_comment_id                   number
--   p_concatenated_segments        varchar2 Soft Coding combination name
--   p_group_name                   varchar2 People Group name
--   p_other_manager_warning        boolean  Set to true if manager_flag is 'Y'
--                                           and a manager already exists in
--                                           the organization
--                                           (p_organization_id) at
--   p_hourly_salaried_warning      boolean  Set to true if combination values
--                                           entered for pay_basis and
--                                           hourly_salaried_code are invalid
--                                  date     p_effective_date
--
--  p_cagr_grade_def_id             number   Set to the ID value of the grade if
--                                           cag_segments and a cagr_id_flex_num
--                                           are available
--  p_cagr_concatenated_segments    varchar2 If p_validate is false and any
--                                           p_segment parameters have set
--                                           text, set to the concatenation
--                                           of all p_segment parameters with
--                                           set text. If p_validate is
--                                           true, or no p_segment parameters
--                                           have set text, this will be null.
-- Post Failure:
--   The API does not create the assignment and raises an error.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--



PROCEDURE create_cn_secondary_emp_asg
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
  ,p_default_code_comb_id         IN     NUMBER   DEFAULT     null
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
  ,p_employer_id                  IN     VARCHAR2
  ,p_tax_area_code                IN     VARCHAR2
  ,p_sic_area_code                IN     VARCHAR2                -- Bug 2955433 Removed DEFAULT
  ,p_salary_payout_locn           IN     VARCHAR2 DEFAULT   null
  ,p_special_tax_exmp_category    IN     VARCHAR2 DEFAULT   null -- Bug 3828396 Added segment
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
  ,p_hourly_salaried_warning         OUT NOCOPY   BOOLEAN  )
 IS
--
  -- Declare cursors AND local variables
  --
  -- Declare variables
  --

  l_assignment_number  per_assignments_f.assignment_number%TYPE;
  l_effective_date     DATE;
  --
  l_proc               VARCHAR2(72);
  --
  --
BEGIN

  l_proc := g_package||'create_cn_secondary_emp_asg';
  hr_cn_api.set_location(g_trace, 'Entering:'|| l_proc, 10);

  --
  -- Initialise local variable
  --
  l_effective_date := trunc(p_effective_date);

  --
  -- Ensure that the employee IS within a cn business group
  --
  hr_cn_api.check_person (p_person_id, 'CN', l_effective_date);

  hr_cn_api.set_location(g_trace, l_proc, 20);

  --
  --
  -- Call create_secondary_emp_asg
  --

  hr_assignment_api.create_secondary_emp_asg
  (p_validate                    	=>	  p_validate
  ,p_effective_date             	=>	  p_effective_date
  ,p_person_id                		=>	  p_person_id
  ,p_organization_id             	=>	  p_organization_id
  ,p_grade_id                    	=>	  p_grade_id
  ,p_position_id                	=>	  p_position_id
  ,p_job_id                      	=>	  p_job_id
  ,p_assignment_status_type_id   	=>	  p_assignment_status_type_id
  ,p_payroll_id                  	=>	  p_payroll_id
  ,p_location_id                 	=>	  p_location_id
  ,p_supervisor_id              	=>	  p_supervisor_id
  ,p_special_ceiling_step_id     	=>	  p_special_ceiling_step_id
  ,p_pay_basis_id                	=>	  p_pay_basis_id
  ,p_assignment_number           	=>	  p_assignment_number
  ,p_change_reason                	=>	  p_change_reason
  ,p_comments                     	=>	  p_comments
  ,p_date_probation_end         	=>	  p_date_probation_end
  ,p_default_code_comb_id        	=>	  p_default_code_comb_id
  ,p_employment_category         	=>	  p_employment_category
  ,p_frequency                  	=>	  p_frequency
  ,p_internal_address_line       	=>	  p_internal_address_line
  ,p_manager_flag                	=>	  p_manager_flag
  ,p_normal_hours                	=>	  p_normal_hours
  ,p_perf_review_period          	=>	  p_perf_review_period
  ,p_perf_review_period_frequency 	=>	  p_perf_review_period_frequency
  ,p_probation_period            	=>	  p_probation_period
  ,p_probation_unit              	=>	  p_probation_unit
  ,p_sal_review_period             	=>	  p_sal_review_period
  ,p_sal_review_period_frequency 	=>	  p_sal_review_period_frequency
  ,p_set_of_books_id               	=>	  p_set_of_books_id
  ,p_source_type                 	=>	  p_source_type
  ,p_time_normal_finish          	=>	  p_time_normal_finish
  ,p_time_normal_start           	=>	  p_time_normal_start
  ,p_bargaining_unit_code        	=>	  p_bargaining_unit_code
  ,p_labour_union_member_flag    	=>	  p_labour_union_member_flag
  ,p_hourly_salaried_code        	=>	  p_hourly_salaried_code
  ,p_ass_attribute_category      	=>	  p_ass_attribute_category
  ,p_ass_attribute1              	=>	  p_ass_attribute1
  ,p_ass_attribute2              	=>	  p_ass_attribute2
  ,p_ass_attribute3              	=>	  p_ass_attribute3
  ,p_ass_attribute4              	=>	  p_ass_attribute4
  ,p_ass_attribute5              	=>	  p_ass_attribute5
  ,p_ass_attribute6              	=>	  p_ass_attribute6
  ,p_ass_attribute7              	=>	  p_ass_attribute7
  ,p_ass_attribute8              	=>	  p_ass_attribute8
  ,p_ass_attribute9              	=>	  p_ass_attribute9
  ,p_ass_attribute10             	=>	  p_ass_attribute10
  ,p_ass_attribute11             	=>	  p_ass_attribute11
  ,p_ass_attribute12             	=>	  p_ass_attribute12
  ,p_ass_attribute13             	=>	  p_ass_attribute13
  ,p_ass_attribute14             	=>	  p_ass_attribute14
  ,p_ass_attribute15             	=>	  p_ass_attribute15
  ,p_ass_attribute16             	=>	  p_ass_attribute16
  ,p_ass_attribute17             	=>	  p_ass_attribute17
  ,p_ass_attribute18             	=>	  p_ass_attribute18
  ,p_ass_attribute19             	=>	  p_ass_attribute19
  ,p_ass_attribute20             	=>	  p_ass_attribute20
  ,p_ass_attribute21             	=>	  p_ass_attribute21
  ,p_ass_attribute22             	=>	  p_ass_attribute22
  ,p_ass_attribute23             	=>	  p_ass_attribute23
  ,p_ass_attribute24             	=>	  p_ass_attribute24
  ,p_ass_attribute25             	=>	  p_ass_attribute25
  ,p_ass_attribute26             	=>	  p_ass_attribute26
  ,p_ass_attribute27             	=>	  p_ass_attribute27
  ,p_ass_attribute28             	=>	  p_ass_attribute28
  ,p_ass_attribute29             	=>	  p_ass_attribute29
  ,p_ass_attribute30             	=>	  p_ass_attribute30
  ,p_title                       	=>	  p_title
  ,p_scl_segment1                	=>	  p_employer_id
  ,p_scl_segment20               	=>	  p_tax_area_code
  ,p_scl_segment21               	=>	  p_sic_area_code
  ,p_scl_segment22               	=>	  p_salary_payout_locn
  ,p_scl_segment23                      =>        p_special_tax_exmp_category -- Bug 3828396 Added segment
  ,p_scl_concat_segments    		=>	  p_scl_concat_segments
  ,p_pgp_segment1                	=>	  p_pgp_segment1
  ,p_pgp_segment2                	=>	  p_pgp_segment2
  ,p_pgp_segment3                	=>	  p_pgp_segment3
  ,p_pgp_segment4                	=>	  p_pgp_segment4
  ,p_pgp_segment5                	=>	  p_pgp_segment5
  ,p_pgp_segment6                	=>	  p_pgp_segment6
  ,p_pgp_segment7                	=>	  p_pgp_segment7
  ,p_pgp_segment8                	=>	  p_pgp_segment8
  ,p_pgp_segment9                	=>	  p_pgp_segment9
  ,p_pgp_segment10               	=>	  p_pgp_segment10
  ,p_pgp_segment11               	=>	  p_pgp_segment11
  ,p_pgp_segment12               	=>	  p_pgp_segment12
  ,p_pgp_segment13               	=>	  p_pgp_segment13
  ,p_pgp_segment14               	=>	  p_pgp_segment14
  ,p_pgp_segment15               	=>	  p_pgp_segment15
  ,p_pgp_segment16               	=>	  p_pgp_segment16
  ,p_pgp_segment17               	=>	  p_pgp_segment17
  ,p_pgp_segment18               	=>	  p_pgp_segment18
  ,p_pgp_segment19               	=>	  p_pgp_segment19
  ,p_pgp_segment20               	=>	  p_pgp_segment20
  ,p_pgp_segment21               	=>	  p_pgp_segment21
  ,p_pgp_segment22               	=>	  p_pgp_segment22
  ,p_pgp_segment23               	=>	  p_pgp_segment23
  ,p_pgp_segment24               	=>	  p_pgp_segment24
  ,p_pgp_segment25               	=>	  p_pgp_segment25
  ,p_pgp_segment26               	=>	  p_pgp_segment26
  ,p_pgp_segment27               	=>	  p_pgp_segment27
  ,p_pgp_segment28               	=>	  p_pgp_segment28
  ,p_pgp_segment29               	=>	  p_pgp_segment29
  ,p_pgp_segment30               	=>	  p_pgp_segment30
  ,p_pgp_concat_segments		=>	  p_pgp_concat_segments
  ,p_contract_id                   	=>	  p_contract_id
  ,p_establishment_id              	=>	  p_establishment_id
  ,p_collective_agreement_id       	=>	  p_collective_agreement_id
  ,p_cagr_id_flex_num              	=>	  p_cagr_id_flex_num
  ,p_cag_segment1                	=>	  p_cag_segment1
  ,p_cag_segment2                	=>	  p_cag_segment2
  ,p_cag_segment3                	=>	  p_cag_segment3
  ,p_cag_segment4                	=>	  p_cag_segment4
  ,p_cag_segment5                	=>	  p_cag_segment5
  ,p_cag_segment6                	=>	  p_cag_segment6
  ,p_cag_segment7                	=>	  p_cag_segment7
  ,p_cag_segment8                	=>	  p_cag_segment8
  ,p_cag_segment9                	=>	  p_cag_segment9
  ,p_cag_segment10               	=>	  p_cag_segment10
  ,p_cag_segment11               	=>	  p_cag_segment11
  ,p_cag_segment12               	=>	  p_cag_segment12
  ,p_cag_segment13               	=>	  p_cag_segment13
  ,p_cag_segment14               	=>	  p_cag_segment14
  ,p_cag_segment15               	=>	  p_cag_segment15
  ,p_cag_segment16               	=>	  p_cag_segment16
  ,p_cag_segment17               	=>	  p_cag_segment17
  ,p_cag_segment18               	=>	  p_cag_segment18
  ,p_cag_segment19               	=>	  p_cag_segment19
  ,p_cag_segment20               	=>	  p_cag_segment20
  ,p_notice_period			=>	  p_notice_period
  ,p_notice_period_uom			=>	  p_notice_period_uom
  ,p_employee_category			=>	  p_employee_category
  ,p_work_at_home			=>	  p_work_at_home
  ,p_job_post_source_name        	=>	  p_job_post_source_name
  ,p_group_name                     	=>	  p_group_name
  ,p_concatenated_segments          	=>	  p_concatenated_segments
  ,p_cagr_grade_def_id            	=>	  p_cagr_grade_def_id
  ,p_cagr_concatenated_segments      	=>	  p_cagr_concatenated_segments
  ,p_assignment_id                  	=>	  p_assignment_id
  ,p_soft_coding_keyflex_id       	=>	  p_soft_coding_keyflex_id
  ,p_people_group_id              	=>	  p_people_group_id
  ,p_object_version_number          	=>	  p_object_version_number
  ,p_effective_start_date            	=>	  p_effective_start_date
  ,p_effective_end_date             	=>	  p_effective_end_date
  ,p_assignment_sequence             	=>	  p_assignment_sequence
  ,p_comment_id                      	=>	  p_comment_id
  ,p_other_manager_warning          	=>	  p_other_manager_warning
  ,p_hourly_salaried_warning        	=>	  p_hourly_salaried_warning );

  hr_cn_api.set_location(g_trace, 'Leaving:'|| l_proc, 30);

END create_cn_secondary_emp_asg;

-- ----------------------------------------------------------------------------
-- |--------------------------< update_cn_emp_asg >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   procedure to update employee assignment.
--
-- Prerequisites:
--   The assignment (p_assignment_id) must exist as of the effective date
--   of the update (p_effective_date).
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                          boolean  If true, the database remains
--                                                unchanged. If false a valid
--                                                assignment is created in
--                                                the database.
--   p_effective_date                Yes date     The effective date of the
--                                                change
--   p_datetrack_update_mode         Yes varchar2 Update mode
--   p_assignment_id                     number   ID of the assignment
--   p_object_version_number         Yes number   Version number of the
--                                                assignment record
--   p_supervisor_id                     number   Supervisor
--   p_assignment_number                 number   Assignment number
--   p_change_reason                     varchar2 Reason for the change
--   p_assignment_status_type_id         varchar2 Assignment status
--   p_comments                          varchar2 Comments
--   p_date_probation_end                date     End date of probation period
--   p_default_code_comb_id              number   Foreign key to
--                                                GL_CODE_COMBINATIONS
--   p_frequency                         varchar2 Frequency for quoting working hours (eg per week)
--   p_internal_address_line             varchar2 Internal address line
--   p_manager_flag                      varchar2 Indicates whether the
--                                                employee is a manager
--   p_normal_hours                      number   Normal working hours
--   p_perf_review_period                number   Performance review period
--   p_perf_review_period_frequency      varchar2 Units for quoting  performance
--                                                review period (eg months)
--   p_probation_period                  number   Length of probation period
--   p_probation_unit                    varchar2 Units for quoting probation period (eg months)
--   p_sal_review_period                 number   Salary review period
--   p_sal_review_period_frequency       varchar2 Units for quoting salary review
--                                                period (eg months)
--   p_set_of_books_id                   number   Set of books (GL)
--   p_source_type                       varchar2 Recruitment activity source
--   p_time_normal_finish                varchar2 Normal work finish time
--   p_time_normal_start                 varchar2 Normal work start time
--   p_bargaining_unit_code              varchar2 Code for bargaining unit
--   p_labour_union_member_flag          varchar2 Indicates whether employee is--                                                union member
--   p_hourly_salaried_code              varchar2 Hourly or salaried pay code
--   p_ass_attribute_category            varchar2 Descriptive flexfield
--                                                attribute category
--   p_ass_attribute1                    varchar2 Descriptive flexfield
--   p_ass_attribute2                    varchar2 Descriptive flexfield
--   p_ass_attribute3                    varchar2 Descriptive flexfield
--   p_ass_attribute4                    varchar2 Descriptive flexfield
--   p_ass_attribute5                    varchar2 Descriptive flexfield
--   p_ass_attribute6                    varchar2 Descriptive flexfield
--   p_ass_attribute7                    varchar2 Descriptive flexfield
--   p_ass_attribute8                    varchar2 Descriptive flexfield
--   p_ass_attribute9                    varchar2 Descriptive flexfield
--   p_ass_attribute10                   varchar2 Descriptive flexfield
--   p_ass_attribute11                   varchar2 Descriptive flexfield
--   p_ass_attribute12                   varchar2 Descriptive flexfield
--   p_ass_attribute13                   varchar2 Descriptive flexfield
--   p_ass_attribute14                   varchar2 Descriptive flexfield
--   p_ass_attribute15                   varchar2 Descriptive flexfield
--   p_ass_attribute16                   varchar2 Descriptive flexfield
--   p_ass_attribute17                   varchar2 Descriptive flexfield
--   p_ass_attribute18                   varchar2 Descriptive flexfield
--   p_ass_attribute19                   varchar2 Descriptive flexfield
--   p_ass_attribute20                   varchar2 Descriptive flexfield
--   p_ass_attribute21                   varchar2 Descriptive flexfield
--   p_ass_attribute22                   varchar2 Descriptive flexfield
--   p_ass_attribute23                   varchar2 Descriptive flexfield
--   p_ass_attribute24                   varchar2 Descriptive flexfield
--   p_ass_attribute25                   varchar2 Descriptive flexfield
--   p_ass_attribute26                   varchar2 Descriptive flexfield
--   p_ass_attribute27                   varchar2 Descriptive flexfield
--   p_ass_attribute28                   varchar2 Descriptive flexfield
--   p_ass_attribute29                   varchar2 Descriptive flexfield
--   p_ass_attribute30                   varchar2 Descriptive flexfield
--   p_title                             varchar2 Title -must be NULL
--   p_employer_id                  Yes  varchar2 Employer Id
--   p_tax_area_code                Yes  varchar2 Tax Area Code
--   p_sic_area_code                     varchar2 SIC Area Code
--   p_salary_payout_locn                varchar2 Salary Payout Location
--   p_special_tax_exmp_category         varchar2 Special tax Exemption Category -- Bug 3828396 Added segment
--   p_contract_id                       in number collective agreement
--   p_establishment_id                  in number establishment
--   p_collective_agreement_id           in number collective_agreement
--   p_cagr_id_flex_num                  in number collective_Agreement
--                                                 grade structure
--   p_cag_segment1                      in varchar2 Collective agreement grade
--   p_cag_segment2                      in varchar2 Collective agreement grade
--   p_cag_segment3                      in varchar2 Collective agreement grade
--   p_cag_segment4                      in varchar2 Collective agreement grade
--   p_cag_segment5                      in varchar2 Collective agreement grade
--   p_cag_segment6                      in varchar2 Collective agreement grade
--   p_cag_segment7                      in varchar2 Collective agreement grade
--   p_cag_segment8                      in varchar2 Collective agreement grade
--   p_cag_segment9                      in varchar2 Collective agreement grade
--   p_cag_segment10                     in varchar2 Collective agreement grade
--   p_cag_segment11                     in varchar2 Collective agreement grade
--   p_cag_segment12                     in varchar2 Collective agreement grade
--   p_cag_segment13                     in varchar2 Collective agreement grade
--   p_cag_segment14                     in varchar2 Collective agreement grade
--   p_cag_segment15                     in varchar2 Collective agreement grade
--   p_cag_segment16                     in varchar2 Collective agreement grade
--   p_cag_segment17                     in varchar2 Collective agreement grade
--   p_cag_segment18                     in varchar2 Collective agreement grade
--   p_cag_segment19                     in varchar2 Collective agreement grade
--   p_cag_segment20                     in varchar2 Collective agreement grade
--   p_notice_period                     in number   Notice Period
--   p_notice_period_uom                 in varchar2 Notice Period Units
--   p_employee_category                 in varchar2 Employee Category
--   p_work_at_home                      in varchar2 Work At Home
--   p_job_post_source_name		 in varchar2 Job Source
--
-- Post Success:
--
--   The API sets the following out parameters:
--
--   Name                           Type     Description
--   p_object_version_number        number   New version number of the
--                                           assignment
--   p_soft_coding_keyflex_id       number   If p_validate is false and any
--                                           p_segment parameters have set
--                                           text, set to the id
--                                           of the corresponding soft coding
--                                           keyflex row.  If p_validate is
--                                           true, or no p_segment parameters
--                                           have set text, this will be null.
--   p_comment_id                   number   If p_validate is false and any
--                                           comment text exists, set to the id
--                                           of the corresponding person
--                                           comment row.  If p_validate is
--                                           true, or no comment text exists
--                                           this will be null.
--   p_effective_start_date         date     The effective start date for the
--                                           assignment changes
--   p_effective_end_date           date     The effective end date for the
--                                           assignment changes
--   p_concatenated_segments        varchar2 If p_validate is false and any
--                                           p_segment parameters have set
--                                           text, set to the concatenation
--                                           of all p_segment parameters with
--                                           set text. If p_validate is
--                                           true, or no p_segment parameters
--                                           have set text, this will be null.
--   p_no_managers_warning          boolean  Set to true if manager_flag is
--                                           updated from 'Y' to 'N' and no
--                                           other manager exists in
--                                           p_organization_id.
--                                           Set to false if another manager
--                                           exists in p_organization_id.
--                                           This parameter is always set
--                                           to false if manager_flag is
--                                           not updated. The warning value
--                                           only applies as of
--                                           p_effective_date.
--   p_other_manager_warning        boolean  Set to true if manager_flag is
--                                           changed from 'N' to 'Y' and a
--                                           manager already exists in the
--                                           organization, p_organization_id,
--                                           at p_effective_date.
--                                           Set to false if no other managers
--                                           exist in p_organization_id.
--                                           This is always set to false
--                                           if manager_flag is not updated.
--                                           The warning value only applies as
--                                           of p_effective_date.
--  p_hourly_salaried_warning       boolean  Set to True if Invalid Combination
--					     for pay_basis and hourly_salaried_code
--  p_cagr_grade_def_id             number   Set to the ID value of the grade if
--                                           cag_segments and a cagr_id_flex_num
--                                           are available
--  p_cagr_concatenated_segments    varchar2 If p_validate is false and any
--                                           p_segment parameters have set
--                                           text, set to the concatenation
--                                           of all p_segment parameters with
--                                           set text. If p_validate is
--                                           true, or no p_segment parameters
--                                           have set text, this will be null.
--
-- Post Failure:
--   The API does not update the assignment and raises an error.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--

 PROCEDURE update_cn_emp_asg
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
  ,p_employer_id                  IN     VARCHAR2 DEFAULT   hr_api.g_varchar2 -- Bug 2955433 Added DEFAULT
  ,p_tax_area_code                IN     VARCHAR2 DEFAULT   hr_api.g_varchar2 -- Bug 2955433 Added DEFAULT
  ,p_sic_area_code                IN     VARCHAR2 DEFAULT   hr_api.g_varchar2 -- Bug 2955433 Added DEFAULT
  ,p_salary_payout_locn           IN     VARCHAR2 DEFAULT   hr_api.g_varchar2
  ,p_special_tax_exmp_category    IN     VARCHAR2 DEFAULT   hr_api.g_varchar2 -- Bug 3828396 Added segment
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
  ,p_cagr_grade_def_id            IN OUT NOCOPY   NUMBER
  ,p_cagr_concatenated_segments      OUT NOCOPY   VARCHAR2
  ,p_concatenated_segments           OUT NOCOPY   VARCHAR2
  ,p_soft_coding_keyflex_id       IN OUT NOCOPY   NUMBER
  ,p_comment_id                      OUT NOCOPY   NUMBER
  ,p_effective_start_date            OUT NOCOPY   DATE
  ,p_effective_end_date              OUT NOCOPY   DATE
  ,p_no_managers_warning             OUT NOCOPY   BOOLEAN
  ,p_other_manager_warning           OUT NOCOPY   BOOLEAN
  ,p_hourly_salaried_warning         OUT NOCOPY   BOOLEAN  )
   IS
   --
   -- Declare cursors AND local variables
   --
   l_proc                       VARCHAR2(72);
   l_effective_date             DATE;
   l_legislation_code           per_business_groups.legislation_code%TYPE;
   --


 BEGIN

  l_proc  := g_package||'update_cn_emp_asg';
  hr_cn_api.set_location(g_trace, 'Entering:'|| l_proc, 10);

   --
   -- Truncate DATE variables
   --
    l_effective_date := trunc(p_effective_date);
   --
   hr_cn_api.check_assignment(p_assignment_id, 'CN', l_effective_date);
   --

   hr_cn_api.set_location(g_trace, l_proc, 20);

    --
    -- Call update_emp_asg business process
    --    --
   hr_assignment_api.update_emp_asg
  (p_validate                   	=>	  p_validate
  ,p_effective_date              	=>	  p_effective_date
  ,p_datetrack_update_mode      	=>	  p_datetrack_update_mode
  ,p_assignment_id                	=>	  p_assignment_id
  ,p_object_version_number       	=>	  p_object_version_number
  ,p_supervisor_id                 	=>	  p_supervisor_id
  ,p_assignment_number           	=>	  p_assignment_number
  ,p_change_reason               	=>	  p_change_reason
  ,p_assignment_status_type_id     	=>	  p_assignment_status_type_id
  ,p_comments                    	=>	  p_comments
  ,p_date_probation_end               	=>	  p_date_probation_end
  ,p_default_code_comb_id          	=>	  p_default_code_comb_id
  ,p_frequency                   	=>	  p_frequency
  ,p_internal_address_line       	=>	  p_internal_address_line
  ,p_manager_flag                	=>	  p_manager_flag
  ,p_normal_hours                  	=>	  p_normal_hours
  ,p_perf_review_period            	=>	  p_perf_review_period
  ,p_perf_review_period_frequency	=>	  p_perf_review_period_frequency
  ,p_probation_period              	=>	  p_probation_period
  ,p_probation_unit              	=>	  p_probation_unit
  ,p_sal_review_period             	=>	  p_sal_review_period
  ,p_sal_review_period_frequency 	=>	  p_sal_review_period_frequency
  ,p_set_of_books_id               	=>	  p_set_of_books_id
  ,p_source_type                 	=>	  p_source_type
  ,p_time_normal_finish          	=>	  p_time_normal_finish
  ,p_time_normal_start           	=>	  p_time_normal_start
  ,p_bargaining_unit_code        	=>	  p_bargaining_unit_code
  ,p_labour_union_member_flag    	=>	  p_labour_union_member_flag
  ,p_hourly_salaried_code        	=>	  p_hourly_salaried_code
  ,p_ass_attribute_category      	=>	  p_ass_attribute_category
  ,p_ass_attribute1              	=>	  p_ass_attribute1
  ,p_ass_attribute2              	=>	  p_ass_attribute2
  ,p_ass_attribute3              	=>	  p_ass_attribute3
  ,p_ass_attribute4              	=>	  p_ass_attribute4
  ,p_ass_attribute5              	=>	  p_ass_attribute5
  ,p_ass_attribute6              	=>	  p_ass_attribute6
  ,p_ass_attribute7              	=>	  p_ass_attribute7
  ,p_ass_attribute8              	=>	  p_ass_attribute8
  ,p_ass_attribute9              	=>	  p_ass_attribute9
  ,p_ass_attribute10             	=>	  p_ass_attribute10
  ,p_ass_attribute11             	=>	  p_ass_attribute11
  ,p_ass_attribute12             	=>	  p_ass_attribute12
  ,p_ass_attribute13             	=>	  p_ass_attribute13
  ,p_ass_attribute14             	=>	  p_ass_attribute14
  ,p_ass_attribute15             	=>	  p_ass_attribute15
  ,p_ass_attribute16             	=>	  p_ass_attribute16
  ,p_ass_attribute17             	=>	  p_ass_attribute17
  ,p_ass_attribute18             	=>	  p_ass_attribute18
  ,p_ass_attribute19             	=>	  p_ass_attribute19
  ,p_ass_attribute20             	=>	  p_ass_attribute20
  ,p_ass_attribute21             	=>	  p_ass_attribute21
  ,p_ass_attribute22             	=>	  p_ass_attribute22
  ,p_ass_attribute23             	=>	  p_ass_attribute23
  ,p_ass_attribute24             	=>	  p_ass_attribute24
  ,p_ass_attribute25             	=>	  p_ass_attribute25
  ,p_ass_attribute26             	=>	  p_ass_attribute26
  ,p_ass_attribute27             	=>	  p_ass_attribute27
  ,p_ass_attribute28             	=>	  p_ass_attribute28
  ,p_ass_attribute29             	=>	  p_ass_attribute29
  ,p_ass_attribute30             	=>	  p_ass_attribute30
  ,p_title                       	=>	  p_title
  ,p_segment1                    	=>	  p_employer_id
  ,p_segment20                   	=>	  p_tax_area_code
  ,p_segment21                   	=>	  p_sic_area_code
  ,p_segment22                   	=>	  p_salary_payout_locn
  ,p_segment23                          =>        p_special_tax_exmp_category -- Bug 3828396 Added segment
  ,p_concat_segments             	=>	  p_concat_segments
  ,p_contract_id                 	=>	  p_contract_id
  ,p_establishment_id            	=>	  p_establishment_id
  ,p_collective_agreement_id     	=>	  p_collective_agreement_id
  ,p_cagr_id_flex_num            	=>	  p_cagr_id_flex_num
  ,p_cag_segment1                	=>	  p_cag_segment1
  ,p_cag_segment2                	=>	  p_cag_segment2
  ,p_cag_segment3                	=>	  p_cag_segment3
  ,p_cag_segment4                	=>	  p_cag_segment4
  ,p_cag_segment5                	=>	  p_cag_segment5
  ,p_cag_segment6                	=>	  p_cag_segment6
  ,p_cag_segment7                	=>	  p_cag_segment7
  ,p_cag_segment8                	=>	  p_cag_segment8
  ,p_cag_segment9                	=>	  p_cag_segment9
  ,p_cag_segment10               	=>	  p_cag_segment10
  ,p_cag_segment11               	=>	  p_cag_segment11
  ,p_cag_segment12               	=>	  p_cag_segment12
  ,p_cag_segment13               	=>	  p_cag_segment13
  ,p_cag_segment14               	=>	  p_cag_segment14
  ,p_cag_segment15               	=>	  p_cag_segment15
  ,p_cag_segment16               	=>	  p_cag_segment16
  ,p_cag_segment17               	=>	  p_cag_segment17
  ,p_cag_segment18               	=>	  p_cag_segment18
  ,p_cag_segment19               	=>	  p_cag_segment19
  ,p_cag_segment20               	=>	  p_cag_segment20
  ,p_notice_period			=>	  p_notice_period
  ,p_notice_period_uom			=>	  p_notice_period_uom
  ,p_employee_category			=>	  p_employee_category
  ,p_work_at_home			=>	  p_work_at_home
  ,p_job_post_source_name		=>	  p_job_post_source_name
  ,p_cagr_grade_def_id          	=>	  p_cagr_grade_def_id
  ,p_cagr_concatenated_segments     	=>	  p_cagr_concatenated_segments
  ,p_concatenated_segments           	=>	  p_concatenated_segments
  ,p_soft_coding_keyflex_id       	=>	  p_soft_coding_keyflex_id
  ,p_comment_id                      	=>	  p_comment_id
  ,p_effective_start_date            	=>	  p_effective_start_date
  ,p_effective_end_date              	=>	  p_effective_end_date
  ,p_no_managers_warning            	=>	  p_no_managers_warning
  ,p_other_manager_warning           	=>	  p_other_manager_warning
  ,p_hourly_salaried_warning         	=>	  p_hourly_salaried_warning );


  hr_cn_api.set_location(g_trace, 'Leaving:'|| l_proc, 30);

--
End update_cn_emp_asg;

BEGIN
  g_package := 'hr_cn_assignment_api.';
END hr_cn_assignment_api;

/
