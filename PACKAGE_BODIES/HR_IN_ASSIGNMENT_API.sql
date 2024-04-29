--------------------------------------------------------
--  DDL for Package Body HR_IN_ASSIGNMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_IN_ASSIGNMENT_API" AS
/* $Header: peasgini.pkb 120.1 2005/08/05 05:31 sukukuma noship $ */
g_package  VARCHAR2(33) := 'hr_in_assignment_api.';
g_trace BOOLEAN ;


-- ----------------------------------------------------------------------------
-- |---------------------------< check_person >-------------------------------|
-- ----------------------------------------------------------------------------

PROCEDURE check_person (p_person_id         IN NUMBER
                       ,p_legislation_code  IN VARCHAR2
                       ,p_effective_date    IN DATE
                        )
IS
   l_legislation_code    per_business_groups.legislation_code%type;
   --
   CURSOR csr_emp_leg
      (l_person_id         per_people_f.person_id%TYPE,
       l_effective_date DATE
      )
   IS
      SELECT bgp.legislation_code
        FROM per_people_f per,
             per_business_groups bgp
       WHERE per.business_group_id = bgp.business_group_id
         AND per.person_id       = l_person_id
         AND l_effective_date  between per.effective_start_date and per.effective_END_date;

BEGIN

   OPEN csr_emp_leg(p_person_id, trunc(p_effective_date));
   FETCH csr_emp_leg into l_legislation_code;

   IF csr_emp_leg%notfound THEN
      CLOSE csr_emp_leg;
      hr_utility.set_message(801,'HR_7220_INVALID_PRIMARY_KEY');
      hr_utility.raise_error;
   END IF;
   CLOSE csr_emp_leg;

   --
   -- Check that the legislation of the specified business group is 'IN'.
   --
   IF l_legislation_code <> p_legislation_code THEN
      hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
      hr_utility.set_message_token('LEG_CODE','IN');
      hr_utility.raise_error;
   END IF;

EXCEPTION
    WHEN OTHERS THEN
       IF csr_emp_leg%ISOPEN THEN
          CLOSE csr_emp_leg;
       END IF;
          RAISE;

END check_person;

-- ----------------------------------------------------------------------------
-- |---------------------< create_in_secondary_emp_asg >--------------------------|
-- ----------------------------------------------------------------------------

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
,p_scl_concat_segments    	IN     VARCHAR2  DEFAULT   null
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
,p_pgp_concat_segments	        IN     VARCHAR2  DEFAULT   null
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
,p_notice_period		IN     NUMBER    DEFAULT   null
,p_notice_period_uom		IN     VARCHAR2  DEFAULT   null
,p_employee_category		IN     VARCHAR2  DEFAULT   null
,p_work_at_home		        IN     VARCHAR2  DEFAULT   null
,p_job_post_source_name         IN     VARCHAR2  DEFAULT   null
,p_grade_ladder_pgm_id          IN     NUMBER	   DEFAULT   null
,p_supervisor_assignment_id     IN     NUMBER	   DEFAULT   null
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
,p_gsp_post_process_warning        OUT NOCOPY VARCHAR2
) IS
--
-- Declare variables
--
l_effective_date     DATE;
l_proc               VARCHAR2(72);
--
BEGIN


  l_proc := g_package||'create_secondary_emp_asg';
  l_effective_date := trunc(p_effective_date);
  g_trace := hr_utility.debug_enabled ;

  IF g_trace THEN
    hr_utility.set_location('Entering: '||l_proc, 10);
  END IF ;

  check_person (p_person_id ,'IN', l_effective_date);

  IF g_trace THEN
       hr_utility.set_location(l_proc, 20);
  END IF ;

  hr_assignment_api.create_secondary_emp_asg
  (p_validate                    =>  p_validate
  ,p_effective_date              =>  p_effective_date
  ,p_person_id                	 =>  p_person_id
  ,p_organization_id             =>  p_organization_id
  ,p_grade_id                    =>  p_grade_id
  ,p_position_id                 =>  p_position_id
  ,p_job_id                      =>  p_job_id
  ,p_assignment_status_type_id   =>  p_assignment_status_type_id
  ,p_payroll_id                  =>  p_payroll_id
  ,p_location_id                 =>  p_location_id
  ,p_supervisor_id               =>  p_supervisor_id
  ,p_special_ceiling_step_id     =>  p_special_ceiling_step_id
  ,p_pay_basis_id                =>  p_pay_basis_id
  ,p_assignment_number           =>  p_assignment_number
  ,p_change_reason               =>  p_change_reason
  ,p_comments                    =>  p_comments
  ,p_date_probation_end          =>  p_date_probation_end
  ,p_default_code_comb_id        =>  p_default_code_comb_id
  ,p_employment_category         =>  p_employment_category
  ,p_frequency                   =>  p_frequency
  ,p_internal_address_line       =>  p_internal_address_line
  ,p_manager_flag                =>  p_manager_flag
  ,p_normal_hours                =>  p_normal_hours
  ,p_perf_review_period          =>  p_perf_review_period
  ,p_perf_review_period_frequency=>  p_perf_review_period_frequency
  ,p_probation_period            =>  p_probation_period
  ,p_probation_unit              =>  p_probation_unit
  ,p_sal_review_period           =>  p_sal_review_period
  ,p_sal_review_period_frequency =>  p_sal_review_period_frequency
  ,p_set_of_books_id             =>  p_set_of_books_id
  ,p_source_type                 =>  p_source_type
  ,p_time_normal_finish          =>  p_time_normal_finish
  ,p_time_normal_start           =>  p_time_normal_start
  ,p_bargaining_unit_code        =>  p_bargaining_unit_code
  ,p_labour_union_member_flag    =>  p_labour_union_member_flag
  ,p_hourly_salaried_code        =>  p_hourly_salaried_code
  ,p_ass_attribute_category      =>  p_ass_attribute_category
  ,p_ass_attribute1              =>  p_ass_attribute1
  ,p_ass_attribute2              =>  p_ass_attribute2
  ,p_ass_attribute3              =>  p_ass_attribute3
  ,p_ass_attribute4              =>  p_ass_attribute4
  ,p_ass_attribute5              =>  p_ass_attribute5
  ,p_ass_attribute6              =>  p_ass_attribute6
  ,p_ass_attribute7              =>  p_ass_attribute7
  ,p_ass_attribute8              =>  p_ass_attribute8
  ,p_ass_attribute9              =>  p_ass_attribute9
  ,p_ass_attribute10             =>  p_ass_attribute10
  ,p_ass_attribute11             =>  p_ass_attribute11
  ,p_ass_attribute12             =>  p_ass_attribute12
  ,p_ass_attribute13             =>  p_ass_attribute13
  ,p_ass_attribute14             =>  p_ass_attribute14
  ,p_ass_attribute15             =>  p_ass_attribute15
  ,p_ass_attribute16             =>  p_ass_attribute16
  ,p_ass_attribute17             =>  p_ass_attribute17
  ,p_ass_attribute18             =>  p_ass_attribute18
  ,p_ass_attribute19             =>  p_ass_attribute19
  ,p_ass_attribute20             =>  p_ass_attribute20
  ,p_ass_attribute21             =>  p_ass_attribute21
  ,p_ass_attribute22             =>  p_ass_attribute22
  ,p_ass_attribute23             =>  p_ass_attribute23
  ,p_ass_attribute24             =>  p_ass_attribute24
  ,p_ass_attribute25             =>  p_ass_attribute25
  ,p_ass_attribute26             =>  p_ass_attribute26
  ,p_ass_attribute27             =>  p_ass_attribute27
  ,p_ass_attribute28             =>  p_ass_attribute28
  ,p_ass_attribute29             =>  p_ass_attribute29
  ,p_ass_attribute30             =>  p_ass_attribute30
  ,p_title                       =>  p_title
  ,p_scl_segment1                =>  p_gre_legal_entity
  ,p_scl_segment2                =>  p_pf_organization
  ,p_scl_segment3                =>  p_prof_tax_organization
  ,p_scl_segment4                =>  p_esi_organization
  ,p_scl_segment5                =>  p_factory
  ,p_scl_segment6                =>  p_establishment
  ,p_scl_segment8                =>  p_covered_by_gratuity_act
  ,p_scl_segment9                =>  p_having_substantial_interest
  ,p_scl_segment10               =>  p_director
  ,p_scl_segment11               =>  p_specified
  ,p_scl_concat_segments    	 =>  p_scl_concat_segments
  ,p_pgp_segment1                =>  p_pgp_segment1
  ,p_pgp_segment2                =>  p_pgp_segment2
  ,p_pgp_segment3                =>  p_pgp_segment3
  ,p_pgp_segment4                =>  p_pgp_segment4
  ,p_pgp_segment5                =>  p_pgp_segment5
  ,p_pgp_segment6                =>  p_pgp_segment6
  ,p_pgp_segment7                =>  p_pgp_segment7
  ,p_pgp_segment8                =>  p_pgp_segment8
  ,p_pgp_segment9                =>  p_pgp_segment9
  ,p_pgp_segment10               =>  p_pgp_segment10
  ,p_pgp_segment11               =>  p_pgp_segment11
  ,p_pgp_segment12               =>  p_pgp_segment12
  ,p_pgp_segment13               =>  p_pgp_segment13
  ,p_pgp_segment14               =>  p_pgp_segment14
  ,p_pgp_segment15               =>  p_pgp_segment15
  ,p_pgp_segment16               =>  p_pgp_segment16
  ,p_pgp_segment17               =>  p_pgp_segment17
  ,p_pgp_segment18               =>  p_pgp_segment18
  ,p_pgp_segment19               =>  p_pgp_segment19
  ,p_pgp_segment20               =>  p_pgp_segment20
  ,p_pgp_segment21               =>  p_pgp_segment21
  ,p_pgp_segment22               =>  p_pgp_segment22
  ,p_pgp_segment23               =>  p_pgp_segment23
  ,p_pgp_segment24               =>  p_pgp_segment24
  ,p_pgp_segment25               =>  p_pgp_segment25
  ,p_pgp_segment26               =>  p_pgp_segment26
  ,p_pgp_segment27               =>  p_pgp_segment27
  ,p_pgp_segment28               =>  p_pgp_segment28
  ,p_pgp_segment29               =>  p_pgp_segment29
  ,p_pgp_segment30               =>  p_pgp_segment30
  ,p_pgp_concat_segments	 =>  p_pgp_concat_segments
  ,p_contract_id                 =>  p_contract_id
  ,p_establishment_id            =>  p_establishment_id
  ,p_collective_agreement_id     =>  p_collective_agreement_id
  ,p_cagr_id_flex_num            =>  p_cagr_id_flex_num
  ,p_cag_segment1                =>  p_cag_segment1
  ,p_cag_segment2                =>  p_cag_segment2
  ,p_cag_segment3                =>  p_cag_segment3
  ,p_cag_segment4                =>  p_cag_segment4
  ,p_cag_segment5                =>  p_cag_segment5
  ,p_cag_segment6                =>  p_cag_segment6
  ,p_cag_segment7                =>  p_cag_segment7
  ,p_cag_segment8                =>  p_cag_segment8
  ,p_cag_segment9                =>  p_cag_segment9
  ,p_cag_segment10               =>  p_cag_segment10
  ,p_cag_segment11               =>  p_cag_segment11
  ,p_cag_segment12               =>  p_cag_segment12
  ,p_cag_segment13               =>  p_cag_segment13
  ,p_cag_segment14               =>  p_cag_segment14
  ,p_cag_segment15               =>  p_cag_segment15
  ,p_cag_segment16               =>  p_cag_segment16
  ,p_cag_segment17               =>  p_cag_segment17
  ,p_cag_segment18               =>  p_cag_segment18
  ,p_cag_segment19               =>  p_cag_segment19
  ,p_cag_segment20               =>  p_cag_segment20
  ,p_notice_period		 =>  p_notice_period
  ,p_notice_period_uom		 =>  p_notice_period_uom
  ,p_employee_category		 =>  p_employee_category
  ,p_work_at_home		 =>  p_work_at_home
  ,p_job_post_source_name        =>  p_job_post_source_name
  ,p_grade_ladder_pgm_id	 =>  p_grade_ladder_pgm_id
  ,p_supervisor_assignment_id	 =>  p_supervisor_assignment_id
  ,p_group_name                  =>  p_group_name
  ,p_concatenated_segments       =>  p_concatenated_segments
  ,p_cagr_grade_def_id           =>  p_cagr_grade_def_id
  ,p_cagr_concatenated_segments  =>  p_cagr_concatenated_segments
  ,p_assignment_id               =>  p_assignment_id
  ,p_soft_coding_keyflex_id      =>  p_soft_coding_keyflex_id
  ,p_people_group_id             =>  p_people_group_id
  ,p_object_version_number       =>  p_object_version_number
  ,p_effective_start_date        =>  p_effective_start_date
  ,p_effective_end_date          =>  p_effective_end_date
  ,p_assignment_sequence         =>  p_assignment_sequence
  ,p_comment_id                  =>  p_comment_id
  ,p_other_manager_warning       =>  p_other_manager_warning
  ,p_hourly_salaried_warning     =>  p_hourly_salaried_warning
  ,p_gsp_post_process_warning    =>  p_gsp_post_process_warning);

   IF g_trace THEN
      hr_utility.set_location('Leaving: '||l_proc, 30);
    END IF ;

  END create_in_secondary_emp_asg;

-- ----------------------------------------------------------------------------
-- |--------------------------< update_in_emp_asg >------------------------------|
-- ----------------------------------------------------------------------------

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
  ,p_notice_period		  IN     NUMBER   DEFAULT HR_API.G_NUMBER
  ,p_notice_period_uom	      	  IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_employee_category	          IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_work_at_home		  IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
  ,p_job_post_source_name	  IN     VARCHAR2 DEFAULT HR_API.G_VARCHAR2
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
  ) IS
  --
  -- Declare variables
  --
  l_proc               VARCHAR2(72);
  --
BEGIN

  l_proc := g_package||'update_emp_asg';
  g_trace := hr_utility.debug_enabled ;

  IF g_trace THEN
    hr_utility.set_location('Entering: '||l_proc, 10);
  END IF ;

  hr_assignment_api.update_emp_asg
  (p_validate                       =>	p_validate
  ,p_effective_date                 =>	p_effective_date
  ,p_datetrack_update_mode          =>	p_datetrack_update_mode
  ,p_assignment_id                  =>	p_assignment_id
  ,p_object_version_number          =>	p_object_version_number
  ,p_supervisor_id                  =>	p_supervisor_id
  ,p_assignment_number              =>	p_assignment_number
  ,p_change_reason                  =>	p_change_reason
  ,p_assignment_status_type_id      =>	p_assignment_status_type_id
  ,p_comments                       =>	p_comments
  ,p_date_probation_end             =>	p_date_probation_end
  ,p_default_code_comb_id           =>	p_default_code_comb_id
  ,p_frequency                      =>	p_frequency
  ,p_internal_address_line          =>	p_internal_address_line
  ,p_manager_flag                   =>	p_manager_flag
  ,p_normal_hours                   =>	p_normal_hours
  ,p_perf_review_period             =>	p_perf_review_period
  ,p_perf_review_period_frequency   =>	p_perf_review_period_frequency
  ,p_probation_period               =>	p_probation_period
  ,p_probation_unit                 =>	p_probation_unit
  ,p_sal_review_period              =>	p_sal_review_period
  ,p_sal_review_period_frequency    =>	p_sal_review_period_frequency
  ,p_set_of_books_id                =>	p_set_of_books_id
  ,p_source_type                    =>	p_source_type
  ,p_time_normal_finish             =>	p_time_normal_finish
  ,p_time_normal_start              =>	p_time_normal_start
  ,p_bargaining_unit_code           =>	p_bargaining_unit_code
  ,p_labour_union_member_flag       =>	p_labour_union_member_flag
  ,p_hourly_salaried_code           =>	p_hourly_salaried_code
  ,p_ass_attribute_category         =>	p_ass_attribute_category
  ,p_ass_attribute1                 =>	p_ass_attribute1
  ,p_ass_attribute2                 =>	p_ass_attribute2
  ,p_ass_attribute3                 =>	p_ass_attribute3
  ,p_ass_attribute4                 =>	p_ass_attribute4
  ,p_ass_attribute5                 =>	p_ass_attribute5
  ,p_ass_attribute6                 =>	p_ass_attribute6
  ,p_ass_attribute7                 =>	p_ass_attribute7
  ,p_ass_attribute8                 =>	p_ass_attribute8
  ,p_ass_attribute9                 =>	p_ass_attribute9
  ,p_ass_attribute10                =>	p_ass_attribute10
  ,p_ass_attribute11                =>	p_ass_attribute11
  ,p_ass_attribute12                =>	p_ass_attribute12
  ,p_ass_attribute13                =>	p_ass_attribute13
  ,p_ass_attribute14                =>	p_ass_attribute14
  ,p_ass_attribute15                =>	p_ass_attribute15
  ,p_ass_attribute16                =>	p_ass_attribute16
  ,p_ass_attribute17                =>	p_ass_attribute17
  ,p_ass_attribute18                =>	p_ass_attribute18
  ,p_ass_attribute19                =>	p_ass_attribute19
  ,p_ass_attribute20                =>	p_ass_attribute20
  ,p_ass_attribute21                =>	p_ass_attribute21
  ,p_ass_attribute22                =>	p_ass_attribute22
  ,p_ass_attribute23                =>	p_ass_attribute23
  ,p_ass_attribute24                =>	p_ass_attribute24
  ,p_ass_attribute25                =>	p_ass_attribute25
  ,p_ass_attribute26                =>	p_ass_attribute26
  ,p_ass_attribute27                =>	p_ass_attribute27
  ,p_ass_attribute28                =>	p_ass_attribute28
  ,p_ass_attribute29                =>	p_ass_attribute29
  ,p_ass_attribute30                =>	p_ass_attribute30
  ,p_title                          =>	p_title
  ,p_segment1                       =>	p_gre_legal_entity
  ,p_segment2                       =>	p_pf_organization
  ,p_segment3                       =>	p_prof_tax_organization
  ,p_segment4                       =>	p_esi_organization
  ,p_segment5                       =>	p_factory
  ,p_segment6                       =>	p_establishment
  ,p_segment8                       =>  p_covered_by_gratuity_act
  ,p_segment9                       =>  p_having_substantial_interest
  ,p_segment10                      =>  p_director
  ,p_segment11                      =>  p_specified
  ,p_concat_segments                =>	p_concat_segments
  ,p_contract_id                    =>	p_contract_id
  ,p_establishment_id               =>	p_establishment_id
  ,p_collective_agreement_id        =>	p_collective_agreement_id
  ,p_cagr_id_flex_num               =>	p_cagr_id_flex_num
  ,p_cag_segment1                   =>	p_cag_segment1
  ,p_cag_segment2                   =>	p_cag_segment2
  ,p_cag_segment3                   =>	p_cag_segment3
  ,p_cag_segment4                   =>	p_cag_segment4
  ,p_cag_segment5                   =>	p_cag_segment5
  ,p_cag_segment6                   =>	p_cag_segment6
  ,p_cag_segment7                   =>	p_cag_segment7
  ,p_cag_segment8                   =>	p_cag_segment8
  ,p_cag_segment9                   =>	p_cag_segment9
  ,p_cag_segment10                  =>	p_cag_segment10
  ,p_cag_segment11                  =>	p_cag_segment11
  ,p_cag_segment12                  =>	p_cag_segment12
  ,p_cag_segment13                  =>	p_cag_segment13
  ,p_cag_segment14                  =>	p_cag_segment14
  ,p_cag_segment15                  =>	p_cag_segment15
  ,p_cag_segment16                  =>	p_cag_segment16
  ,p_cag_segment17                  =>	p_cag_segment17
  ,p_cag_segment18                  =>	p_cag_segment18
  ,p_cag_segment19                  =>	p_cag_segment19
  ,p_cag_segment20                  =>	p_cag_segment20
  ,p_notice_period		    =>	p_notice_period
  ,p_notice_period_uom	      	    =>	p_notice_period_uom
  ,p_employee_category	            =>	p_employee_category
  ,p_work_at_home		    =>	p_work_at_home
  ,p_job_post_source_name	    =>	p_job_post_source_name
  ,p_supervisor_assignment_id       =>	p_supervisor_assignment_id
  ,p_cagr_grade_def_id              =>	p_cagr_grade_def_id
  ,p_cagr_concatenated_segments     =>	p_cagr_concatenated_segments
  ,p_concatenated_segments          =>	p_concatenated_segments
  ,p_soft_coding_keyflex_id         =>	p_soft_coding_keyflex_id
  ,p_comment_id                     =>	p_comment_id
  ,p_effective_start_date           =>	p_effective_start_date
  ,p_effective_end_date             =>	p_effective_end_date
  ,p_no_managers_warning            =>	p_no_managers_warning
  ,p_other_manager_warning          =>	p_other_manager_warning
  ,p_hourly_salaried_warning        =>	p_hourly_salaried_warning
  ,p_gsp_post_process_warning       =>	p_gsp_post_process_warning
  );

  IF g_trace THEN
       hr_utility.set_location(l_proc, 20);
  END IF ;

END update_in_emp_asg;

-- ----------------------------------------------------------------------------
-- |-----------------------< create_in_secondary_cwk_asg >-------------------------|
-- ----------------------------------------------------------------------------

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
  ,p_soft_coding_keyflex_id          OUT NOCOPY NUMBER
  ) IS
  --
  -- Declare variables
  --
  l_effective_date     DATE;
  l_proc               VARCHAR2(72);
  l_cwk_check          NUMBER;

  CURSOR csr_cwk_leg
      (l_person_id         per_people_f.person_id%TYPE,
       l_effective_date    DATE,
       l_business_group_id per_people_f.business_group_id%TYPE
      )
   IS
      SELECT 1
        FROM per_people_f
       WHERE business_group_id = l_business_group_id
         AND person_id       = l_person_id
         AND l_effective_date  between effective_start_date and effective_END_date;
BEGIN

  l_proc := g_package||'create_in_secondary_cwk_asg';
  l_effective_date := trunc(p_effective_date);
  g_trace := hr_utility.debug_enabled ;
  l_cwk_check := 0;

  IF g_trace THEN
    hr_utility.set_location('Entering: '||l_proc, 10);
  END IF ;

  OPEN csr_cwk_leg(p_person_id, l_effective_date, p_business_group_id);
  FETCH csr_cwk_leg into l_cwk_check;

   IF l_cwk_check = 0 THEN
      CLOSE csr_cwk_leg;
      hr_utility.set_message(801,'HR_7220_INVALID_PRIMARY_KEY');
      hr_utility.raise_error;
   END IF;
   CLOSE csr_cwk_leg;

  IF g_trace THEN
       hr_utility.set_location(l_proc, 20);
  END IF ;

  hr_assignment_api.create_secondary_cwk_asg
  ( p_validate                     =>  p_validate
  ,p_effective_date            	  =>  p_effective_date
  ,p_business_group_id         	  =>  p_business_group_id
  ,p_person_id                 	  =>  p_person_id
  ,p_organization_id           	  =>  p_organization_id
  ,p_assignment_number         	  =>  p_assignment_number
  ,p_assignment_category       	  =>  p_assignment_category
  ,p_assignment_status_type_id 	  =>  p_assignment_status_type_id
  ,p_change_reason             	  =>  p_change_reason
  ,p_comments                  	  =>  p_comments
  ,p_default_code_comb_id      	  =>  p_default_code_comb_id
  ,p_establishment_id          	  =>  p_establishment_id
  ,p_frequency                 	  =>  p_frequency
  ,p_internal_address_line     	  =>  p_internal_address_line
  ,p_job_id                    	  =>  p_job_id
  ,p_labour_union_member_flag  	  =>  p_labour_union_member_flag
  ,p_location_id               	  =>  p_location_id
  ,p_manager_flag              	  =>  p_manager_flag
  ,p_normal_hours              	  =>  p_normal_hours
  ,p_position_id               	  =>  p_position_id
  ,p_grade_id                  	  =>  p_grade_id
  ,p_project_title             	  =>  p_project_title
  ,p_set_of_books_id           	  =>  p_set_of_books_id
  ,p_source_type               	  =>  p_source_type
  ,p_supervisor_id             	  =>  p_supervisor_id
  ,p_time_normal_finish        	  =>  p_time_normal_finish
  ,p_time_normal_start         	  =>  p_time_normal_start
  ,p_title                     	  =>  p_title
  ,p_vendor_assignment_number  	  =>  p_vendor_assignment_number
  ,p_vendor_employee_number    	  =>  p_vendor_employee_number
  ,p_vendor_id                 	  =>  p_vendor_id
  ,p_vendor_site_id            	  =>  p_vendor_site_id
  ,p_po_header_id              	  =>  p_po_header_id
  ,p_po_line_id                	  =>  p_po_line_id
  ,p_projected_assignment_end  	  =>  p_projected_assignment_end
  ,p_attribute_category        	  =>  p_attribute_category
  ,p_attribute1                	  =>  p_attribute1
  ,p_attribute2                	  =>  p_attribute2
  ,p_attribute3                	  =>  p_attribute3
  ,p_attribute4                	  =>  p_attribute4
  ,p_attribute5                	  =>  p_attribute5
  ,p_attribute6                	  =>  p_attribute6
  ,p_attribute7                	  =>  p_attribute7
  ,p_attribute8                	  =>  p_attribute8
  ,p_attribute9                	  =>  p_attribute9
  ,p_attribute10               	  =>  p_attribute10
  ,p_attribute11               	  =>  p_attribute11
  ,p_attribute12               	  =>  p_attribute12
  ,p_attribute13               	  =>  p_attribute13
  ,p_attribute14               	  =>  p_attribute14
  ,p_attribute15               	  =>  p_attribute15
  ,p_attribute16               	  =>  p_attribute16
  ,p_attribute17               	  =>  p_attribute17
  ,p_attribute18               	  =>  p_attribute18
  ,p_attribute19               	  =>  p_attribute19
  ,p_attribute20               	  =>  p_attribute20
  ,p_attribute21               	  =>  p_attribute21
  ,p_attribute22               	  =>  p_attribute22
  ,p_attribute23               	  =>  p_attribute23
  ,p_attribute24               	  =>  p_attribute24
  ,p_attribute25               	  =>  p_attribute25
  ,p_attribute26               	  =>  p_attribute26
  ,p_attribute27               	  =>  p_attribute27
  ,p_attribute28               	  =>  p_attribute28
  ,p_attribute29               	  =>  p_attribute29
  ,p_attribute30               	  =>  p_attribute30
  ,p_pgp_segment1              	  =>  p_pgp_segment1
  ,p_pgp_segment2              	  =>  p_pgp_segment2
  ,p_pgp_segment3              	  =>  p_pgp_segment3
  ,p_pgp_segment4              	  =>  p_pgp_segment4
  ,p_pgp_segment5              	  =>  p_pgp_segment5
  ,p_pgp_segment6              	  =>  p_pgp_segment6
  ,p_pgp_segment7              	  =>  p_pgp_segment7
  ,p_pgp_segment8              	  =>  p_pgp_segment8
  ,p_pgp_segment9              	  =>  p_pgp_segment9
  ,p_pgp_segment10             	  =>  p_pgp_segment10
  ,p_pgp_segment11             	  =>  p_pgp_segment11
  ,p_pgp_segment12             	  =>  p_pgp_segment12
  ,p_pgp_segment13             	  =>  p_pgp_segment13
  ,p_pgp_segment14             	  =>  p_pgp_segment14
  ,p_pgp_segment15             	  =>  p_pgp_segment15
  ,p_pgp_segment16             	  =>  p_pgp_segment16
  ,p_pgp_segment17             	  =>  p_pgp_segment17
  ,p_pgp_segment18             	  =>  p_pgp_segment18
  ,p_pgp_segment19             	  =>  p_pgp_segment19
  ,p_pgp_segment20             	  =>  p_pgp_segment20
  ,p_pgp_segment21             	  =>  p_pgp_segment21
  ,p_pgp_segment22             	  =>  p_pgp_segment22
  ,p_pgp_segment23             	  =>  p_pgp_segment23
  ,p_pgp_segment24             	  =>  p_pgp_segment24
  ,p_pgp_segment25             	  =>  p_pgp_segment25
  ,p_pgp_segment26             	  =>  p_pgp_segment26
  ,p_pgp_segment27             	  =>  p_pgp_segment27
  ,p_pgp_segment28             	  =>  p_pgp_segment28
  ,p_pgp_segment29             	  =>  p_pgp_segment29
  ,p_pgp_segment30             	  =>  p_pgp_segment30
  ,p_scl_segment1       	  =>  p_scl_contractor_name
  ,p_scl_concat_segments       	  =>  p_scl_concat_segments
  ,p_pgp_concat_segments       	  =>  p_pgp_concat_segments
  ,p_supervisor_assignment_id  	  =>  p_supervisor_assignment_id
  ,p_assignment_id             	  =>  p_assignment_id
  ,p_object_version_number     	  =>  p_object_version_number
  ,p_effective_start_date      	  =>  p_effective_start_date
  ,p_effective_end_date        	  =>  p_effective_end_date
  ,p_assignment_sequence       	  =>  p_assignment_sequence
  ,p_comment_id                	  =>  p_comment_id
  ,p_people_group_id           	  =>  p_people_group_id
  ,p_people_group_name         	  =>  p_people_group_name
  ,p_other_manager_warning     	  =>  p_other_manager_warning
  ,p_hourly_salaried_warning   	  =>  p_hourly_salaried_warning
  ,p_soft_coding_keyflex_id    	  =>  p_soft_coding_keyflex_id );

   IF g_trace THEN
      hr_utility.set_location('Leaving: '||l_proc, 30);
    END IF ;

END create_in_secondary_cwk_asg;

-- ----------------------------------------------------------------------------
-- |--------------------------< update_in_cwk_asg >------------------------------|
-- ----------------------------------------------------------------------------

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
   ) IS
  --
  -- Declare cursors and local variables
  --
  l_proc VARCHAR2(72);

BEGIN

  l_proc  := g_package||'update_cwk_asg';
  g_trace := hr_utility.debug_enabled ;

  IF g_trace THEN
    hr_utility.set_location('Entering: '||l_proc, 10);
  END IF ;

  hr_assignment_api.update_cwk_asg
  (p_validate                  =>    p_validate
  ,p_effective_date            =>    p_effective_date
  ,p_datetrack_update_mode     =>    p_datetrack_update_mode
  ,p_assignment_id             =>    p_assignment_id
  ,p_object_version_number     =>    p_object_version_number
  ,p_assignment_category       =>    p_assignment_category
  ,p_assignment_number         =>    p_assignment_number
  ,p_change_reason             =>    p_change_reason
  ,p_comments                  =>    p_comments
  ,p_default_code_comb_id      =>    p_default_code_comb_id
  ,p_establishment_id          =>    p_establishment_id
  ,p_frequency                 =>    p_frequency
  ,p_internal_address_line     =>    p_internal_address_line
  ,p_labour_union_member_flag  =>    p_labour_union_member_flag
  ,p_manager_flag              =>    p_manager_flag
  ,p_normal_hours              =>    p_normal_hours
  ,p_project_title             =>    p_project_title
  ,p_set_of_books_id           =>    p_set_of_books_id
  ,p_source_type               =>    p_source_type
  ,p_supervisor_id             =>    p_supervisor_id
  ,p_time_normal_finish        =>    p_time_normal_finish
  ,p_time_normal_start         =>    p_time_normal_start
  ,p_title                     =>    p_title
  ,p_vendor_assignment_number  =>    p_vendor_assignment_number
  ,p_vendor_employee_number    =>    p_vendor_employee_number
  ,p_vendor_id                 =>    p_vendor_id
  ,p_vendor_site_id            =>    p_vendor_site_id
  ,p_po_header_id              =>    p_po_header_id
  ,p_po_line_id                =>    p_po_line_id
  ,p_projected_assignment_end  =>    p_projected_assignment_end
  ,p_assignment_status_type_id =>    p_assignment_status_type_id
  ,p_concat_segments           =>    p_concat_segments
  ,p_attribute_category        =>    p_attribute_category
  ,p_attribute1                =>    p_attribute1
  ,p_attribute2                =>    p_attribute2
  ,p_attribute3                =>    p_attribute3
  ,p_attribute4                =>    p_attribute4
  ,p_attribute5                =>    p_attribute5
  ,p_attribute6                =>    p_attribute6
  ,p_attribute7                =>    p_attribute7
  ,p_attribute8                =>    p_attribute8
  ,p_attribute9                =>    p_attribute9
  ,p_attribute10               =>    p_attribute10
  ,p_attribute11               =>    p_attribute11
  ,p_attribute12               =>    p_attribute12
  ,p_attribute13               =>    p_attribute13
  ,p_attribute14               =>    p_attribute14
  ,p_attribute15               =>    p_attribute15
  ,p_attribute16               =>    p_attribute16
  ,p_attribute17               =>    p_attribute17
  ,p_attribute18               =>    p_attribute18
  ,p_attribute19               =>    p_attribute19
  ,p_attribute20               =>    p_attribute20
  ,p_attribute21               =>    p_attribute21
  ,p_attribute22               =>    p_attribute22
  ,p_attribute23               =>    p_attribute23
  ,p_attribute24               =>    p_attribute24
  ,p_attribute25               =>    p_attribute25
  ,p_attribute26               =>    p_attribute26
  ,p_attribute27               =>    p_attribute27
  ,p_attribute28               =>    p_attribute28
  ,p_attribute29               =>    p_attribute29
  ,p_attribute30               =>    p_attribute30
  ,p_scl_segment1              =>    p_scl_contractor_name
  ,p_supervisor_assignment_id  =>    p_supervisor_assignment_id
  ,p_org_now_no_manager_warning=>    p_org_now_no_manager_warning
  ,p_effective_start_date      =>    p_effective_start_date
  ,p_effective_end_date        =>    p_effective_end_date
  ,p_comment_id                =>    p_comment_id
  ,p_no_managers_warning       =>    p_no_managers_warning
  ,p_other_manager_warning     =>    p_other_manager_warning
  ,p_soft_coding_keyflex_id    =>    p_soft_coding_keyflex_id
  ,p_concatenated_segments     =>    p_concatenated_segments
  ,p_hourly_salaried_warning   =>    p_hourly_salaried_warning );

  IF g_trace THEN
    hr_utility.set_location('Entering: '||l_proc, 20);
  END IF ;

END update_in_cwk_asg;

END hr_in_assignment_api;

/
