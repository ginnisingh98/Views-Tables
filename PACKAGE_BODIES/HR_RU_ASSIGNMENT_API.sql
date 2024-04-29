--------------------------------------------------------
--  DDL for Package Body HR_RU_ASSIGNMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_RU_ASSIGNMENT_API" AS
/* $Header: peasgrui.pkb 120.0 2005/05/31 05:46:02 appldev noship $ */
/*
 +==========================================================================================
 |              Copyright (c) 1999 Oracle Corporation Ltd
 |                           All rights reserved.
 +==========================================================================================
 |SQL Script File Name : HR RU WR AS . PKB
 |                Name : hr_ru_assignment_api
 |         Description : Assignment API Wrapper for RU
 |
 |   Name           Date         Version Bug     Text
 |   -------------- ----------   ------- -----   ----
 |   sgajula       27-Dec-2004  115.0           Initial Version
 |   sgajula       29-Dec-2004  115.1           Changed the issue date,end date to date type and changed the default values
 |   sgajula       29-Dec-2004  115.2           Interchanged segment8,segment9
 |   sgajula       15-Feb-2005  115.3           Added few more parameters
 |NOTES
 +==========================================================================================
*/

g_package  VARCHAR2(33) := 'hr_ru_assignment_api.';
--
-- ----------------------------------------------------------------------------
-- |---------------------< create_ru_secondary_emp_asg >-----------------------|
-- ----------------------------------------------------------------------------
--

PROCEDURE create_ru_secondary_emp_asg
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
  ,p_start_reason                 IN     VARCHAR2 DEFAULT NULL
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
  ,p_sec_emp                      IN     VARCHAR2 DEFAULT NULL
  ,p_contract_number              IN     VARCHAR2 DEFAULT NULL
  ,p_issue_date     		  IN     DATE     DEFAULT NULL
  ,p_cont_end_date                IN     DATE     DEFAULT NULL
  ,p_limit_reason                 IN     VARCHAR2 DEFAULT NULL
  ,p_end_reason                   IN     VARCHAR2 DEFAULT NULL
  ,p_territory_cond               IN     VARCHAR2 DEFAULT NULL
  ,p_spl_work_cond                IN     VARCHAR2 DEFAULT NULL
  ,p_csr                          IN     VARCHAR2 DEFAULT NULL
  ,p_csr_add_info                 IN     VARCHAR2 DEFAULT NULL
  ,p_lsr	                  IN     VARCHAR2 DEFAULT NULL
  ,p_lsr_add_info                 IN     VARCHAR2 DEFAULT NULL
  ,p_unint_service_rec            IN     VARCHAR2 DEFAULT NULL
  ,p_total_service_rec            IN     VARCHAR2 DEFAULT NULL
  ,p_pension_years		  IN     VARCHAR2 DEFAULT NULL
  ,p_pension_months		  IN     VARCHAR2 DEFAULT NULL
  ,p_pension_days		  IN     VARCHAR2 DEFAULT NULL
  ,p_scl_concat_segments          IN     VARCHAR2 DEFAULT NULL
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
  ,p_contract_id		  IN     NUMBER   DEFAULT NULL
  ,p_establishment_id             IN     NUMBER   DEFAULT NULL
  ,p_collective_agreement_id      IN     NUMBER   DEFAULT NULL
  ,p_cagr_id_flex_num             IN     NUMBER   DEFAULT NULL
  ,p_cag_segment1                 IN     VARCHAR2 DEFAULT NULL
  ,p_cag_segment2                 IN     VARCHAR2 DEFAULT NULL
  ,p_cag_segment3                 IN     VARCHAR2 DEFAULT NULL
  ,p_cag_segment4                 IN     VARCHAR2 DEFAULT NULL
  ,p_cag_segment5                 IN     VARCHAR2 DEFAULT NULL
  ,p_cag_segment6                 IN     VARCHAR2 DEFAULT NULL
  ,p_cag_segment7                 IN     VARCHAR2 DEFAULT NULL
  ,p_cag_segment8                 IN     VARCHAR2 DEFAULT NULL
  ,p_cag_segment9                 IN     VARCHAR2 DEFAULT NULL
  ,p_cag_segment10                IN     VARCHAR2 DEFAULT NULL
  ,p_cag_segment11                IN     VARCHAR2 DEFAULT NULL
  ,p_cag_segment12                IN     VARCHAR2 DEFAULT NULL
  ,p_cag_segment13                IN     VARCHAR2 DEFAULT NULL
  ,p_cag_segment14                IN     VARCHAR2 DEFAULT NULL
  ,p_cag_segment15                IN     VARCHAR2 DEFAULT NULL
  ,p_cag_segment16                IN     VARCHAR2 DEFAULT NULL
  ,p_cag_segment17                IN     VARCHAR2 DEFAULT NULL
  ,p_cag_segment18                IN     VARCHAR2 DEFAULT NULL
  ,p_cag_segment19                IN     VARCHAR2 DEFAULT NULL
  ,p_cag_segment20                IN     VARCHAR2 DEFAULT NULL
  ,p_notice_period		  IN	 NUMBER   DEFAULT NULL
  ,p_notice_period_uom		  IN     VARCHAR2 DEFAULT NULL
  ,p_employee_category		  IN     VARCHAR2 DEFAULT NULL
  ,p_work_at_home		  IN	 VARCHAR2 DEFAULT NULL
  ,p_job_post_source_name         IN     VARCHAR2 DEFAULT NULL
  ,p_grade_ladder_pgm_id	  IN	 NUMBER   DEFAULT NULL
  ,p_supervisor_assignment_id	  IN	 NUMBER   DEFAULT NULL
  ,p_cagr_grade_def_id            IN OUT NOCOPY NUMBER
  ,p_cagr_concatenated_segments      OUT NOCOPY VARCHAR2
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
  ,p_hourly_salaried_warning         OUT NOCOPY BOOLEAN
  ,p_gsp_post_process_warning        OUT NOCOPY VARCHAR2
  ) is

  -- Declare cursors AND local variables
  --
  -- Declare variables
  --

  l_assignment_number  per_assignments_f.assignment_number%TYPE;
  l_effective_date     DATE;
  --
  l_business_group_id  per_business_groups.business_group_id%TYPE;
  l_legislation_code   per_business_groups.legislation_code%TYPE;
  l_proc               VARCHAR2(72) := g_package||'create_ru_secondary_emp_asg';
  --
  -- Declare cursors
  --
  CURSOR csr_legislation IS
    SELECT  NULL
    FROM    per_assignments_f paf,
            per_business_groups pbg
    WHERE   paf.person_id = p_person_id
    AND     l_effective_date BETWEEN paf.effective_start_date AND     paf.effective_end_date
    AND     pbg.business_group_id = paf.business_group_id
    AND     pbg.legislation_code = 'RU';
  --
  --
BEGIN
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Initialise local variable
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Validation IN addition to Table Handlers
  --
  -- Ensure that the employee IS within a sa business group
  --
  OPEN  csr_legislation;
  FETCH csr_legislation
  INTO l_legislation_code;
  IF csr_legislation%notfound THEN
    CLOSE csr_legislation;
    hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
    hr_utility.set_message_token('LEG_CODE', 'RU');
    hr_utility.raise_error;
  END IF;
  CLOSE csr_legislation;
  --
  --
  -- Call create_secondary_emp_asg
  --


 hr_assignment_api.create_secondary_emp_asg
  (p_validate                     =>     p_validate
  ,p_effective_date               =>     l_effective_date
  ,p_person_id                    =>     p_person_id
  ,p_organization_id              =>     p_organization_id
  ,p_grade_id                     =>     p_grade_id
  ,p_position_id                  =>     p_position_id
  ,p_job_id                       =>     p_job_id
  ,p_assignment_status_type_id    =>     p_assignment_status_type_id
  ,p_payroll_id                   =>     p_payroll_id
  ,p_location_id                  =>     p_location_id
  ,p_supervisor_id                =>     p_supervisor_id
  ,p_special_ceiling_step_id      =>     p_special_ceiling_step_id
  ,p_pay_basis_id                 =>     p_pay_basis_id
  ,p_assignment_number            =>     l_assignment_number
  ,p_change_reason                =>     p_start_reason
  ,p_comments                     =>     p_comments
  ,p_date_probation_end           =>     trunc(p_date_probation_end)
  ,p_default_code_comb_id         =>     p_default_code_comb_id
  ,p_employment_category          =>     p_employment_category
  ,p_frequency                    =>     p_frequency
  ,p_internal_address_line        =>     p_internal_address_line
  ,p_manager_flag                 =>     p_manager_flag
  ,p_normal_hours                 =>     p_normal_hours
  ,p_perf_review_period           =>     p_perf_review_period
  ,p_perf_review_period_frequency =>     p_perf_review_period_frequency
  ,p_probation_period             =>     p_probation_period
  ,p_probation_unit               =>     p_probation_unit
  ,p_sal_review_period            =>     p_sal_review_period
  ,p_sal_review_period_frequency  =>     p_sal_review_period_frequency
  ,p_set_of_books_id              =>     p_set_of_books_id
  ,p_source_type                  =>     p_source_type
  ,p_time_normal_finish           =>     p_time_normal_finish
  ,p_time_normal_start            =>     p_time_normal_start
  ,p_bargaining_unit_code         =>     p_bargaining_unit_code
  ,p_labour_union_member_flag     =>     p_labour_union_member_flag
  ,p_hourly_salaried_code         =>     p_hourly_salaried_code
  ,p_ass_attribute_category       =>     p_ass_attribute_category
  ,p_ass_attribute1               =>     p_ass_attribute1
  ,p_ass_attribute2               =>     p_ass_attribute2
  ,p_ass_attribute3               =>     p_ass_attribute3
  ,p_ass_attribute4               =>     p_ass_attribute4
  ,p_ass_attribute5               =>     p_ass_attribute5
  ,p_ass_attribute6               =>     p_ass_attribute6
  ,p_ass_attribute7               =>     p_ass_attribute7
  ,p_ass_attribute8               =>     p_ass_attribute8
  ,p_ass_attribute9               =>     p_ass_attribute9
  ,p_ass_attribute10              =>     p_ass_attribute10
  ,p_ass_attribute11              =>     p_ass_attribute11
  ,p_ass_attribute12              =>     p_ass_attribute12
  ,p_ass_attribute13              =>     p_ass_attribute13
  ,p_ass_attribute14              =>     p_ass_attribute14
  ,p_ass_attribute15              =>     p_ass_attribute15
  ,p_ass_attribute16              =>     p_ass_attribute16
  ,p_ass_attribute17              =>     p_ass_attribute17
  ,p_ass_attribute18              =>     p_ass_attribute18
  ,p_ass_attribute19              =>     p_ass_attribute19
  ,p_ass_attribute20              =>     p_ass_attribute20
  ,p_ass_attribute21              =>     p_ass_attribute21
  ,p_ass_attribute22              =>     p_ass_attribute22
  ,p_ass_attribute23              =>     p_ass_attribute23
  ,p_ass_attribute24              =>     p_ass_attribute24
  ,p_ass_attribute25              =>     p_ass_attribute25
  ,p_ass_attribute26              =>     p_ass_attribute26
  ,p_ass_attribute27              =>     p_ass_attribute27
  ,p_ass_attribute28              =>     p_ass_attribute28
  ,p_ass_attribute29              =>     p_ass_attribute29
  ,p_ass_attribute30              =>     p_ass_attribute30
  ,p_title                        =>     p_title
  ,p_scl_segment1                 =>     p_employer
  ,p_scl_segment2                 =>     p_sec_emp
  ,p_scl_segment3                 =>     p_contract_number
  ,p_scl_segment4                 =>     fnd_date.date_to_canonical(p_issue_date)
  ,p_scl_segment5                 =>     fnd_date.date_to_canonical(p_cont_end_date)
  ,p_scl_segment6                 =>     p_limit_reason
  ,p_scl_segment7                 =>     p_end_reason
  ,p_scl_segment9                 =>     p_territory_cond
  ,p_scl_segment8                 =>     p_spl_work_cond
  ,p_scl_segment10                =>     p_csr
  ,p_scl_segment11                =>     p_csr_add_info
  ,p_scl_segment12                =>     p_lsr
  ,p_scl_segment13                =>     p_lsr_add_info
  ,p_scl_segment14                =>     p_unint_service_rec
  ,p_scl_segment15                =>     p_total_service_rec
  ,p_scl_segment16                =>	 p_pension_years
  ,p_scl_segment17                =>	 p_pension_months
  ,p_scl_segment18                =>	 p_pension_days
  ,p_scl_concat_segments   	  =>	 p_scl_concat_segments
  ,p_pgp_segment1                 =>     p_pgp_segment1
  ,p_pgp_segment2                 =>     p_pgp_segment2
  ,p_pgp_segment3                 =>     p_pgp_segment3
  ,p_pgp_segment4                 =>     p_pgp_segment4
  ,p_pgp_segment5                 =>     p_pgp_segment5
  ,p_pgp_segment6                 =>     p_pgp_segment6
  ,p_pgp_segment7                 =>     p_pgp_segment7
  ,p_pgp_segment8                 =>     p_pgp_segment8
  ,p_pgp_segment9                 =>     p_pgp_segment9
  ,p_pgp_segment10                =>     p_pgp_segment10
  ,p_pgp_segment11                =>     p_pgp_segment11
  ,p_pgp_segment12                =>     p_pgp_segment12
  ,p_pgp_segment13                =>     p_pgp_segment13
  ,p_pgp_segment14                =>     p_pgp_segment14
  ,p_pgp_segment15                =>     p_pgp_segment15
  ,p_pgp_segment16                =>     p_pgp_segment16
  ,p_pgp_segment17                =>     p_pgp_segment17
  ,p_pgp_segment18                =>     p_pgp_segment18
  ,p_pgp_segment19                =>     p_pgp_segment19
  ,p_pgp_segment20                =>     p_pgp_segment20
  ,p_pgp_segment21                =>     p_pgp_segment21
  ,p_pgp_segment22                =>     p_pgp_segment22
  ,p_pgp_segment23                =>     p_pgp_segment23
  ,p_pgp_segment24                =>     p_pgp_segment24
  ,p_pgp_segment25                =>     p_pgp_segment25
  ,p_pgp_segment26                =>     p_pgp_segment26
  ,p_pgp_segment27                =>     p_pgp_segment27
  ,p_pgp_segment28                =>     p_pgp_segment28
  ,p_pgp_segment29                =>     p_pgp_segment29
  ,p_pgp_segment30                =>     p_pgp_segment30
  ,p_pgp_concat_segments          =>     p_pgp_concat_segments
   ,p_contract_id           	  =>	 p_contract_id
   ,p_establishment_id            =>	 p_establishment_id
   ,p_collective_agreement_id     =>     p_collective_agreement_id
   ,p_cagr_id_flex_num            =>	 p_cagr_id_flex_num
   ,p_cag_segment1          	  =>	 p_cag_segment1
   ,p_cag_segment2          	  =>	 p_cag_segment2
   ,p_cag_segment3          	  =>	 p_cag_segment3
   ,p_cag_segment4          	  =>	 p_cag_segment4
   ,p_cag_segment5          	  =>	 p_cag_segment5
   ,p_cag_segment6          	  =>	 p_cag_segment6
   ,p_cag_segment7          	  =>	 p_cag_segment7
   ,p_cag_segment8          	  =>	 p_cag_segment8
   ,p_cag_segment9          	  =>	 p_cag_segment9
   ,p_cag_segment10         	  =>	 p_cag_segment10
   ,p_cag_segment11         	  =>	 p_cag_segment11
   ,p_cag_segment12         	  =>	 p_cag_segment12
   ,p_cag_segment13         	  =>	 p_cag_segment13
   ,p_cag_segment14         	  =>	 p_cag_segment14
   ,p_cag_segment15         	  =>	 p_cag_segment15
   ,p_cag_segment16         	  =>	 p_cag_segment16
   ,p_cag_segment17         	  =>	 p_cag_segment17
   ,p_cag_segment18         	  =>	 p_cag_segment18
   ,p_cag_segment19         	  =>	 p_cag_segment19
   ,p_cag_segment20         	  =>	 p_cag_segment20
   ,p_notice_period	    	  =>	 p_notice_period
   ,p_notice_period_uom	          =>     p_notice_period_uom
   ,p_employee_category	          =>	 p_employee_category
   ,p_work_at_home	    	  =>     p_work_at_home
   ,p_job_post_source_name  	  =>	 p_job_post_source_name
   ,p_grade_ladder_pgm_id   	  =>     p_grade_ladder_pgm_id
   ,p_supervisor_assignment_id 	  =>     p_supervisor_assignment_id
   ,p_group_name                  =>	 p_group_name
   ,p_concatenated_segments       =>     p_concatenated_segments
   ,p_cagr_grade_def_id     	  =>	 p_cagr_grade_def_id
   ,p_cagr_concatenated_segments  =>     p_cagr_concatenated_segments
   ,p_assignment_id               =>     p_assignment_id
  ,p_soft_coding_keyflex_id       =>     p_soft_coding_keyflex_id
  ,p_people_group_id              =>     p_people_group_id
  ,p_object_version_number        =>     p_object_version_number
  ,p_effective_start_date         =>     p_effective_start_date
  ,p_effective_end_date           =>     p_effective_end_date
  ,p_assignment_sequence          =>     p_assignment_sequence
  ,p_comment_id                   =>     p_comment_id
  ,p_other_manager_warning        =>     p_other_manager_warning
  ,p_hourly_salaried_warning   	  =>     p_hourly_salaried_warning
  ,p_gsp_post_process_warning     =>     p_gsp_post_process_warning
  );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 30);
  --
  END create_ru_secondary_emp_asg;

  -- ----------------------------------------------------------------------------
  -- |--------------------------< update_ru_emp_asg >---------------------------|
  -- ----------------------------------------------------------------------------
  --
PROCEDURE update_ru_emp_asg
  (p_validate                     IN     BOOLEAN  DEFAULT FALSE
  ,p_effective_date               IN     DATE
  ,p_datetrack_update_mode        IN     VARCHAR2
  ,p_assignment_id                IN     NUMBER
  ,p_object_version_number        IN OUT NOCOPY NUMBER
  ,p_supervisor_id                IN     NUMBER   DEFAULT hr_api.g_number
  ,p_assignment_number            IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_change_reason                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_assignment_status_type_id    IN     NUMBER   DEFAULT hr_api.g_number
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
  ,p_sec_emp                      IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_contract_number              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_issue_date     		  IN     DATE     DEFAULT hr_api.g_date
  ,p_cont_end_date                IN     DATE     DEFAULT hr_api.g_date
  ,p_limit_reason                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_end_reason                   IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_territory_cond               IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_spl_work_cond                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_csr                          IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_csr_add_info                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_lsr	                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_lsr_add_info                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_unint_service_rec            IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_total_service_rec            IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_pension_years		  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_pension_months		  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_pension_days		  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_concat_segments              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_contract_id		  IN     NUMBER   DEFAULT hr_api.g_number
  ,p_establishment_id             IN     NUMBER   DEFAULT hr_api.g_number
  ,p_collective_agreement_id      IN     NUMBER   DEFAULT hr_api.g_number
  ,p_cagr_id_flex_num             IN     NUMBER   DEFAULT hr_api.g_number
  ,p_cag_segment1                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_cag_segment2                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_cag_segment3                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_cag_segment4                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_cag_segment5                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_cag_segment6                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_cag_segment7                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_cag_segment8                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_cag_segment9                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_cag_segment10                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_cag_segment11                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_cag_segment12                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_cag_segment13                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_cag_segment14                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_cag_segment15                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_cag_segment16                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_cag_segment17                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_cag_segment18                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_cag_segment19                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_cag_segment20                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_notice_period		  IN	 NUMBER   DEFAULT hr_api.g_varchar2
  ,p_notice_period_uom		  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_employee_category		  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_work_at_home		  IN	 VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_job_post_source_name         IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_supervisor_assignment_id	  IN	 NUMBER   DEFAULT hr_api.g_number
  ,p_cagr_grade_def_id            IN OUT NOCOPY NUMBER
  ,p_cagr_concatenated_segments      OUT NOCOPY VARCHAR2
  ,p_soft_coding_keyflex_id       IN OUT NOCOPY NUMBER
  ,p_effective_start_date            OUT NOCOPY DATE
  ,p_effective_end_date              OUT NOCOPY DATE
  ,p_comment_id                      OUT NOCOPY NUMBER
  ,p_concatenated_segments           OUT NOCOPY VARCHAR2
  ,p_no_managers_warning             OUT NOCOPY BOOLEAN
  ,p_other_manager_warning           OUT NOCOPY BOOLEAN
  ,p_hourly_salaried_warning         OUT NOCOPY BOOLEAN
  ,p_gsp_post_process_warning        OUT NOCOPY VARCHAR2
  ) is

 --
    -- Declare cursors AND local variables
    --
    l_proc                       VARCHAR2(72) := g_package||'update_ru_emp_asg';
    l_effective_date             DATE;
    l_legislation_code           per_business_groups.legislation_code%TYPE;
    l_business_group_id          per_business_groups.business_group_id%type;
    l_issue_date         hr_soft_coding_keyflex.segment4%TYPE;
    l_cont_end_date      hr_soft_coding_keyflex.segment5%TYPE;

   --
    CURSOR check_legislation
      (c_assignment_id  per_assignments_f.assignment_id%TYPE,
       c_effective_date DATE
      )
    IS
      SELECT    bgp.legislation_code
      FROM      per_assignments_f asg,
                per_business_groups bgp
      WHERE     asg.business_group_id = bgp.business_group_id
      AND       asg.assignment_id     = c_assignment_id
      AND       c_effective_date BETWEEN effective_start_date AND effective_end_date;
    --


  BEGIN
    hr_utility.set_location('Entering:'|| l_proc, 10);

    --
    -- Truncate DATE variables
    --
    l_effective_date := trunc(p_effective_date);
    --
    -- Validate IN addition to Table Handlers
    --
    -- Check that the assignment exists.
    --
    OPEN    check_legislation(p_assignment_id, l_effective_date);
    FETCH   check_legislation into l_legislation_code;
    IF check_legislation%notfound THEN
      CLOSE check_legislation;
      hr_utility.set_message(801,'HR_7220_INVALID_PRIMARY_KEY');
      hr_utility.raise_error;
    END IF;
    CLOSE check_legislation;
    hr_utility.set_location(l_proc, 20);
    --
    -- Check that the legislation of the specified business group IS 'RU'.
    --
    IF l_legislation_code <> 'RU' THEN
      hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
      hr_utility.set_message_token('LEG_CODE','RU');
      hr_utility.raise_error;
    END IF;
    hr_utility.set_location(l_proc, 30);
    --
    --
    -- Call update_emp_asg business process
    --
    if p_issue_date = hr_api.g_date THEN
       l_issue_date := hr_api.g_varchar2;
    else
       l_issue_date := fnd_date.date_to_canonical(p_issue_date);
    end if;

    if p_cont_end_date = hr_api.g_date THEN
       l_cont_end_date := hr_api.g_varchar2;
    else
       l_cont_end_date := fnd_date.date_to_canonical(p_cont_end_date);
    end if;

       hr_assignment_api.update_emp_asg
      (p_validate                     => p_validate
      ,p_effective_date               => p_effective_date
      ,p_datetrack_update_mode        => p_datetrack_update_mode
      ,p_assignment_id                => p_assignment_id
      ,p_object_version_number        => p_object_version_number
      ,p_supervisor_id                => p_supervisor_id
      ,p_assignment_number            => p_assignment_number
      ,p_change_reason                => p_change_reason
      ,p_assignment_status_type_id    => p_assignment_status_type_id
      ,p_comments                     => p_comments
      ,p_date_probation_end           => p_date_probation_end
      ,p_default_code_comb_id         => p_default_code_comb_id
      ,p_frequency                    => p_frequency
      ,p_internal_address_line        => p_internal_address_line
      ,p_manager_flag                 => p_manager_flag
      ,p_normal_hours                 => p_normal_hours
      ,p_perf_review_period           => p_perf_review_period
      ,p_perf_review_period_frequency => p_perf_review_period_frequency
      ,p_probation_period             => p_probation_period
      ,p_probation_unit               => p_probation_unit
      ,p_sal_review_period            => p_sal_review_period
      ,p_sal_review_period_frequency  => p_sal_review_period_frequency
      ,p_set_of_books_id              => p_set_of_books_id
      ,p_source_type                  => p_source_type
      ,p_time_normal_finish           => p_time_normal_finish
      ,p_time_normal_start            => p_time_normal_start
      ,p_bargaining_unit_code         => p_bargaining_unit_code
      ,p_labour_union_member_flag     => p_labour_union_member_flag
      ,p_hourly_salaried_code         => p_hourly_salaried_code
      ,p_ass_attribute_category       => p_ass_attribute_category
      ,p_ass_attribute1               => p_ass_attribute1
      ,p_ass_attribute2               => p_ass_attribute2
      ,p_ass_attribute3               => p_ass_attribute3
      ,p_ass_attribute4               => p_ass_attribute4
      ,p_ass_attribute5               => p_ass_attribute5
      ,p_ass_attribute6               => p_ass_attribute6
      ,p_ass_attribute7               => p_ass_attribute7
      ,p_ass_attribute8               => p_ass_attribute8
      ,p_ass_attribute9               => p_ass_attribute9
      ,p_ass_attribute10              => p_ass_attribute10
      ,p_ass_attribute11              => p_ass_attribute11
      ,p_ass_attribute12              => p_ass_attribute12
      ,p_ass_attribute13              => p_ass_attribute13
      ,p_ass_attribute14              => p_ass_attribute14
      ,p_ass_attribute15              => p_ass_attribute15
      ,p_ass_attribute16              => p_ass_attribute16
      ,p_ass_attribute17              => p_ass_attribute17
      ,p_ass_attribute18              => p_ass_attribute18
      ,p_ass_attribute19              => p_ass_attribute19
      ,p_ass_attribute20              => p_ass_attribute20
      ,p_ass_attribute21              => p_ass_attribute21
      ,p_ass_attribute22              => p_ass_attribute22
      ,p_ass_attribute23              => p_ass_attribute23
      ,p_ass_attribute24              => p_ass_attribute24
      ,p_ass_attribute25              => p_ass_attribute25
      ,p_ass_attribute26              => p_ass_attribute26
      ,p_ass_attribute27              => p_ass_attribute27
      ,p_ass_attribute28              => p_ass_attribute28
      ,p_ass_attribute29              => p_ass_attribute29
      ,p_ass_attribute30              => p_ass_attribute30
      ,p_title                        => p_title
      ,p_segment1                 => p_employer
      ,p_segment2                 => p_sec_emp
      ,p_segment3                 => p_contract_number
      ,p_segment4                 => l_issue_date
      ,p_segment5                 => l_cont_end_date
      ,p_segment6                 => p_limit_reason
      ,p_segment7                 => p_end_reason
      ,p_segment9                 => p_territory_cond
      ,p_segment8                 => p_spl_work_cond
      ,p_segment10                => p_csr
      ,p_segment11                => p_csr_add_info
      ,p_segment12                => p_lsr
      ,p_segment13                => p_lsr_add_info
      ,p_segment14                => p_unint_service_rec
      ,p_segment15                => p_total_service_rec
      ,p_segment16                => p_pension_years
      ,p_segment17                => p_pension_months
      ,p_segment18                => p_pension_days
      ,p_concat_segments                   =>         p_concat_segments
      ,p_contract_id                       =>         p_contract_id
      ,p_establishment_id                  =>         p_establishment_id
      ,p_collective_agreement_id           =>         p_collective_agreement_id
      ,p_cagr_id_flex_num                  =>         p_cagr_id_flex_num
      ,p_cag_segment1                      =>         p_cag_segment1
      ,p_cag_segment2                      =>         p_cag_segment2
      ,p_cag_segment3                      =>         p_cag_segment3
      ,p_cag_segment4                      =>         p_cag_segment4
      ,p_cag_segment5                      =>         p_cag_segment5
      ,p_cag_segment6                      =>         p_cag_segment6
      ,p_cag_segment7                      =>         p_cag_segment7
      ,p_cag_segment8                      =>         p_cag_segment8
      ,p_cag_segment9                      =>         p_cag_segment9
      ,p_cag_segment10                     =>         p_cag_segment10
      ,p_cag_segment11                     =>         p_cag_segment11
      ,p_cag_segment12                     =>         p_cag_segment12
      ,p_cag_segment13                     =>         p_cag_segment13
      ,p_cag_segment14                     =>         p_cag_segment14
      ,p_cag_segment15                     =>         p_cag_segment15
      ,p_cag_segment16                     =>         p_cag_segment16
      ,p_cag_segment17                     =>         p_cag_segment17
      ,p_cag_segment18                     =>         p_cag_segment18
      ,p_cag_segment19                     =>         p_cag_segment19
      ,p_cag_segment20                     =>         p_cag_segment20
      ,p_notice_period		      =>         p_notice_period
      ,p_notice_period_uom	      	      =>         p_notice_period_uom
      ,p_employee_category	              =>         p_employee_category
      ,p_work_at_home		      => 	 p_work_at_home
      ,p_job_post_source_name	      => 	 p_job_post_source_name
      ,p_supervisor_assignment_id          =>         p_supervisor_assignment_id
      ,p_cagr_grade_def_id                 =>         p_cagr_grade_def_id
      ,p_cagr_concatenated_segments        =>	 p_cagr_concatenated_segments
      ,p_concatenated_segments             =>         p_concatenated_segments
      ,p_soft_coding_keyflex_id   => p_soft_coding_keyflex_id
      ,p_comment_id               => p_comment_id
      ,p_effective_start_date     => p_effective_start_date
      ,p_effective_end_date       => p_effective_end_date
      ,p_no_managers_warning      => p_no_managers_warning
      ,p_other_manager_warning    => p_other_manager_warning
      ,p_hourly_salaried_warning           =>         p_hourly_salaried_warning
      ,p_gsp_post_process_warning => p_gsp_post_process_warning

      );


    hr_utility.set_location(' Leaving:'||l_proc, 40);
  END update_ru_emp_asg;


END hr_ru_assignment_api;

/
