--------------------------------------------------------
--  DDL for Package Body HR_MX_ASSIGNMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_MX_ASSIGNMENT_API" AS
/* $Header: pemxwras.pkb 120.0 2005/05/31 11:31:08 appldev noship $ */

-- Global variables
--
     g_package  VARCHAR2(33);
     g_debug    BOOLEAN;

--   --------------------------------------------------------------------------
-- |--------------------< create_mx_secondary_emp_asg >-------------------------|
--   --------------------------------------------------------------------------

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
  ,p_gsp_post_process_warning        OUT NOCOPY   VARCHAR2)
 IS
--
  -- Declare cursors AND local variables
  --
  -- Declare variables
  --

  l_assignment_number  per_assignments_f.assignment_number%TYPE;
  l_effective_date     DATE;
  l_business_group_id  per_all_people_f.business_group_id%TYPE;

  --
  l_proc               VARCHAR2(72);
  --
  --
BEGIN

  l_proc := g_package||'create_mx_secondary_emp_asg';

  if g_debug then
   hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;

  -----------------------------------------------------------------
  -- Initialise local variable
  -----------------------------------------------------------------
  l_effective_date := trunc(p_effective_date);

  -----------------------------------------------------------------
  -- Check that the business group of the person is in 'MX'
  -- legislation.
  -----------------------------------------------------------------
  l_business_group_id := hr_mx_utility.get_bg_from_person(p_person_id);

 if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;

  hr_mx_utility.check_bus_grp(l_business_group_id, 'MX');

 if g_debug then
  hr_utility.set_location(l_proc, 30);
 end if;

  -----------------------------------------------------------------
  -- Call create_secondary_emp_asg
  -----------------------------------------------------------------

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
  ,p_scl_segment1                	=>	  p_tax_unit
  ,p_scl_segment2               	=>	  p_timecard_approver
  ,p_scl_segment3               	=>	  p_timecard_required
  ,p_scl_segment4               	=>	  p_work_schedule
  ,p_scl_segment5               	=>	  p_gov_emp_sector
  ,p_scl_segment6               	=>	  p_ss_salary_type
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
  ,p_grade_ladder_pgm_id	    	=>	  p_grade_ladder_pgm_id
  ,p_supervisor_assignment_id    	=>	  p_supervisor_assignment_id
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
  ,p_hourly_salaried_warning        	=>	  p_hourly_salaried_warning
  ,p_gsp_post_process_warning       	=>	  p_gsp_post_process_warning );

if g_debug then
  hr_utility.set_location('Leaving: '||l_proc, 40);
end if;

END create_mx_secondary_emp_asg;

-- ----------------------------------------------------------------------------
-- |--------------------------< update_mx_emp_asg >------------------------------|
-- ----------------------------------------------------------------------------

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
  ,p_gsp_post_process_warning        OUT NOCOPY   VARCHAR2 )
   IS
   --
   -- Declare cursors AND local variables
   --
   l_proc                       VARCHAR2(72);
   l_effective_date             DATE;
   l_legislation_code           per_business_groups.legislation_code%TYPE;
   l_business_group_id          per_assignments_f.business_group_id%TYPE;

   --


 BEGIN

  l_proc  := g_package||'update_mx_emp_asg';

  if g_debug then
   hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;

  -----------------------------------------------------------------
   -- Check that the Business Group for the assignment is in 'MX'
  -----------------------------------------------------------------
   l_business_group_id := hr_mx_utility.get_bg_from_assignment(p_assignment_id);

 if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;

   hr_mx_utility.check_bus_grp(l_business_group_id, 'MX');

 if g_debug then
  hr_utility.set_location(l_proc, 30);
 end if;

  -----------------------------------------------------------------
   -- Truncate DATE variables
  -----------------------------------------------------------------
   l_effective_date := trunc(p_effective_date);

  -----------------------------------------------------------------
   -- Validate the Leaving Reason entered, if any.
  -----------------------------------------------------------------
   if p_ss_leaving_reason <> hr_api.g_varchar2 then   -- Bug 3777663
      per_mx_validations.check_SS_Leaving_Reason(p_ss_leaving_reason);

       if g_debug then
          hr_utility.set_location(l_proc, 40);
       end if;

  -----------------------------------------------------------------
   -- Load the Leaving Reason onto the Global Variable.
  -----------------------------------------------------------------
       g_leaving_reason := p_ss_leaving_reason;
   else
       g_leaving_reason := NULL;
   end if;

  -----------------------------------------------------------------
    -- Call update_emp_asg business process
  -----------------------------------------------------------------
   hr_assignment_api.update_emp_asg
  (p_validate                   	=>	  p_validate
  ,p_effective_date              	=>	  l_effective_date
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
  ,p_segment1				=>	  p_tax_unit
  ,p_segment2			  	=>	  p_timecard_approver
  ,p_segment3			  	=>	  p_timecard_required
  ,p_segment4			  	=>	  p_work_schedule
  ,p_segment5			  	=>	  p_gov_emp_sector
  ,p_segment6			 	=>	  p_ss_salary_type
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
  ,p_supervisor_assignment_id    	=>	  p_supervisor_assignment_id
  ,p_cagr_grade_def_id          	=>	  p_cagr_grade_def_id
  ,p_cagr_concatenated_segments     	=>	  p_cagr_concatenated_segments
  ,p_concatenated_segments           	=>	  p_concatenated_segments
  ,p_soft_coding_keyflex_id       	=>	  p_soft_coding_keyflex_id
  ,p_comment_id                      	=>	  p_comment_id
  ,p_effective_start_date            	=>	  p_effective_start_date
  ,p_effective_end_date              	=>	  p_effective_end_date
  ,p_no_managers_warning            	=>	  p_no_managers_warning
  ,p_other_manager_warning           	=>	  p_other_manager_warning
  ,p_hourly_salaried_warning         	=>	  p_hourly_salaried_warning
  ,p_gsp_post_process_warning        	=>	  p_gsp_post_process_warning );


   if g_debug then
       hr_utility.set_location('Leaving: '||l_proc, 50);
   end if;
--
End update_mx_emp_asg;


--   --------------------------------------------------------------------------
-- |--------------------< update_mx_emp_asg_criteria >-------------------------|
--   --------------------------------------------------------------------------

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
  ,p_gsp_post_process_warning        OUT NOCOPY VARCHAR2 )
   IS
--
  -- Declare cursors AND local variables
  --
  -- Declare variables
  --
  l_effective_date  DATE;
  l_business_group_id          per_assignments_f.business_group_id%TYPE;

  --
  l_proc            VARCHAR2(72);
  --
  --
BEGIN

  l_proc := g_package||'update_mx_emp_asg_criteria';

  if g_debug then
   hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;

  -----------------------------------------------------------------
  -- Initialise local variable
  -----------------------------------------------------------------
  l_effective_date := trunc(p_effective_date);

  -----------------------------------------------------------------
   -- Check that the Business Group for the assignment is in 'MX'
  -----------------------------------------------------------------
   l_business_group_id := hr_mx_utility.get_bg_from_assignment(p_assignment_id);

 if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;

   hr_mx_utility.check_bus_grp(l_business_group_id, 'MX');

 if g_debug then
  hr_utility.set_location(l_proc, 30);
 end if;

  -----------------------------------------------------------------
  -- Validate the Leaving Reason entered, if any.
  -----------------------------------------------------------------
  per_mx_validations.check_SS_Leaving_Reason(p_ss_leaving_reason);

   if g_debug then
       hr_utility.set_location(l_proc, 40);
   end if;

  -----------------------------------------------------------------
  -- Load the Leaving Reason onto the Global Variable.
  -----------------------------------------------------------------
  g_leaving_reason := p_ss_leaving_reason;

  -----------------------------------------------------------------
  -- Call update_mx_emp_asg_criteria
  -----------------------------------------------------------------

  hr_assignment_api.update_emp_asg_criteria
  (p_effective_date               =>	 l_effective_date
  ,p_datetrack_update_mode        =>	 p_datetrack_update_mode
  ,p_assignment_id                =>	 p_assignment_id
  ,p_validate                     =>	 p_validate
  ,p_called_from_mass_update      =>	 p_called_from_mass_update
  ,p_grade_id                     =>	 p_grade_id
  ,p_position_id                  =>	 p_position_id
  ,p_job_id                       =>	 p_job_id
  ,p_payroll_id                   =>	 p_payroll_id
  ,p_location_id                  =>	 p_location_id
  ,p_organization_id              =>	 p_organization_id
  ,p_pay_basis_id                 =>	 p_pay_basis_id
  ,p_segment1                     =>	 p_segment1
  ,p_segment2                     =>	 p_segment2
  ,p_segment3                     =>	 p_segment3
  ,p_segment4                     =>	 p_segment4
  ,p_segment5                     =>	 p_segment5
  ,p_segment6                     =>	 p_segment6
  ,p_segment7                     =>	 p_segment7
  ,p_segment8                     =>	 p_segment8
  ,p_segment9                     =>	 p_segment9
  ,p_segment10                    =>	 p_segment10
  ,p_segment11                    =>	 p_segment11
  ,p_segment12                    =>	 p_segment12
  ,p_segment13                    =>	 p_segment13
  ,p_segment14                    =>	 p_segment14
  ,p_segment15                    =>	 p_segment15
  ,p_segment16                    =>	 p_segment16
  ,p_segment17                    =>	 p_segment17
  ,p_segment18                    =>	 p_segment18
  ,p_segment19                    =>	 p_segment19
  ,p_segment20                    =>	 p_segment20
  ,p_segment21                    =>	 p_segment21
  ,p_segment22                    =>	 p_segment22
  ,p_segment23                    =>	 p_segment23
  ,p_segment24                    =>	 p_segment24
  ,p_segment25                    =>	 p_segment25
  ,p_segment26                    =>	 p_segment26
  ,p_segment27                    =>	 p_segment27
  ,p_segment28                    =>	 p_segment28
  ,p_segment29                    =>	 p_segment29
  ,p_segment30                    =>	 p_segment30
  ,p_employment_category          =>	 p_employment_category
  ,p_concat_segments              =>	 p_concat_segments
  ,p_contract_id                  =>	 p_contract_id
  ,p_establishment_id             =>	 p_establishment_id
  ,p_scl_segment1                 =>	 p_tax_unit
  ,p_grade_ladder_pgm_id          =>	 p_grade_ladder_pgm_id
  ,p_supervisor_assignment_id     =>	 p_supervisor_assignment_id
  ,p_object_version_number        =>	 p_object_version_number
  ,p_special_ceiling_step_id      =>	 p_special_ceiling_step_id
  ,p_people_group_id              =>	 p_people_group_id
  ,p_soft_coding_keyflex_id       =>	 p_soft_coding_keyflex_id
  ,p_group_name                   =>	 p_group_name
  ,p_effective_start_date         =>	 p_effective_start_date
  ,p_effective_end_date           =>	 p_effective_end_date
  ,p_org_now_no_manager_warning   =>	 p_org_now_no_manager_warning
  ,p_other_manager_warning        =>	 p_other_manager_warning
  ,p_spp_delete_warning           =>	 p_spp_delete_warning
  ,p_entries_changed_warning      =>	 p_entries_changed_warning
  ,p_tax_district_changed_warning =>	 p_tax_district_changed_warning
  ,p_concatenated_segments        =>	 p_concatenated_segments
  ,p_gsp_post_process_warning     =>	 p_gsp_post_process_warning );

   if g_debug then
       hr_utility.set_location('Leaving: '||l_proc, 50);
   end if;

END update_mx_emp_asg_criteria;


--   --------------------------------------------------------------------------
-- |--------------------< mx_final_process_emp_asg >-------------------------|
--   --------------------------------------------------------------------------

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
  ) IS
--
  -- Declare cursors AND local variables
  --
  -- Declare variables
  --
  l_final_process_date  DATE;
  l_business_group_id   per_assignments_f.business_group_id%TYPE;

  --
  l_proc            VARCHAR2(72);
  --
  --
BEGIN

  l_proc := g_package||'mx_final_process_emp_asg';

  if g_debug then
   hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;

  -----------------------------------------------------------------
  -- Initialise local variable
  -----------------------------------------------------------------
  l_final_process_date := trunc(p_final_process_date);

  -----------------------------------------------------------------
   -- Check that the Business Group for the assignment is in 'MX'
  -----------------------------------------------------------------
   l_business_group_id := hr_mx_utility.get_bg_from_assignment(p_assignment_id);

 if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;

   hr_mx_utility.check_bus_grp(l_business_group_id, 'MX');

 if g_debug then
  hr_utility.set_location(l_proc, 30);
 end if;

  -----------------------------------------------------------------
  -- Validate the Leaving Reason entered.
  -----------------------------------------------------------------
  per_mx_validations.check_SS_Leaving_Reason(p_ss_leaving_reason);

   if g_debug then
       hr_utility.set_location(l_proc, 40);
   end if;

  -----------------------------------------------------------------
  -- Load the Leaving Reason onto the Global Variable.
  -----------------------------------------------------------------
  g_leaving_reason := p_ss_leaving_reason;

  -----------------------------------------------------------------
  -- Call update_mx_emp_asg_criteria
  -----------------------------------------------------------------

  hr_assignment_api.final_process_emp_asg
  (p_validate                      =>	p_validate
  ,p_assignment_id                 =>	p_assignment_id
  ,p_object_version_number         =>	p_object_version_number
  ,p_final_process_date            =>	l_final_process_date
  ,p_effective_start_date          =>	p_effective_start_date
  ,p_effective_end_date            =>	p_effective_end_date
  ,p_org_now_no_manager_warning    =>	p_org_now_no_manager_warning
  ,p_asg_future_changes_warning    =>	p_asg_future_changes_warning
  ,p_entries_changed_warning       =>	p_entries_changed_warning );

   if g_debug then
       hr_utility.set_location('Leaving: '||l_proc, 50);
   end if;

END mx_final_process_emp_asg;

BEGIN
	g_debug    := hr_utility.debug_enabled;
	g_package  := 'hr_mx_assignment_api.';

END hr_mx_assignment_api;

/
