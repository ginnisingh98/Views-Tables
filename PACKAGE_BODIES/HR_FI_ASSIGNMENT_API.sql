--------------------------------------------------------
--  DDL for Package Body HR_FI_ASSIGNMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_FI_ASSIGNMENT_API" AS
/* $Header: peasgfii.pkb 120.0 2005/05/31 05:40:34 appldev noship $ */

g_package  VARCHAR2(33) := 'hr_fi_assignment_api.';
--
-- ----------------------------------------------------------------------------
-- |---------------------< create_fi_secondary_emp_asg >-----------------------|
-- ----------------------------------------------------------------------------
--

PROCEDURE create_fi_secondary_emp_asg
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
  ,p_local_unit		          IN     VARCHAR2 DEFAULT NULL
  ,p_employment_type              IN     VARCHAR2 DEFAULT NULL
  ,p_working_time_type		  IN     VARCHAR2 DEFAULT NULL
  ,p_shift_work_type		  IN     VARCHAR2 DEFAULT NULL
  ,p_shift_work_type_days	  IN     VARCHAR2 DEFAULT NULL
  ,p_community_price_category	  IN     VARCHAR2 DEFAULT NULL
  ,p_employee_status		  IN     VARCHAR2 DEFAULT NULL
  ,p_personnel_group		  IN     VARCHAR2 DEFAULT NULL
  ,p_insurance_occupational_group IN     VARCHAR2 DEFAULT NULL
  ,p_union_occupational_group     IN     VARCHAR2 DEFAULT NULL
  ,p_reported_assignment	  IN     VARCHAR2 DEFAULT NULL
  ,p_tax_category       	  IN     VARCHAR2 DEFAULT NULL
  ,p_social_security_liable	  IN     VARCHAR2 DEFAULT NULL
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
  l_proc               VARCHAR2(72) := g_package||'create_fi_secondary_emp_asg';
  v_field	VARCHAR2(20);
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
    AND     pbg.legislation_code = 'FI';
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
  -- Ensure that the employee IS within a FI business group
  --
  OPEN  csr_legislation;
  FETCH csr_legislation
  INTO l_legislation_code;
  IF csr_legislation%notfound THEN
    CLOSE csr_legislation;
    hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
    hr_utility.set_message_token('LEG_CODE', 'FI');
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
  ,p_change_reason                =>     p_change_reason
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
  ,p_scl_segment2                 =>     p_local_unit
  ,p_scl_segment3                 =>     p_employment_type
  ,p_scl_segment4                 =>     p_working_time_type
  ,p_scl_segment5                 =>     p_shift_work_type
  ,p_scl_segment6                 =>     p_shift_work_type_days
  ,p_scl_segment7                 =>     p_community_price_category
  ,p_scl_segment8                 =>     p_employee_status
  ,p_scl_segment9                 =>     p_personnel_group
  ,p_scl_segment10                =>	 p_insurance_occupational_group
  ,p_scl_segment11                =>	 p_union_occupational_group
  ,p_scl_segment12                =>	 p_reported_assignment
  ,p_scl_segment13                =>     p_tax_category
  ,p_scl_segment14                =>     p_social_security_liable
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
  ,p_assignment_id                =>     p_assignment_id
  ,p_soft_coding_keyflex_id       =>     p_soft_coding_keyflex_id
  ,p_people_group_id              =>     p_people_group_id
  ,p_object_version_number        =>     p_object_version_number
  ,p_effective_start_date         =>     p_effective_start_date
  ,p_effective_end_date           =>     p_effective_end_date
  ,p_assignment_sequence          =>     p_assignment_sequence
  ,p_comment_id                   =>     p_comment_id
  ,p_concatenated_segments        =>     p_concatenated_segments
  ,p_group_name                   =>     p_group_name
  ,p_other_manager_warning        =>     p_other_manager_warning
  );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 30);
  --
  END create_fi_secondary_emp_asg;

  -- ----------------------------------------------------------------------------
  -- |--------------------------< update_fi_emp_asg >---------------------------|
  -- ----------------------------------------------------------------------------
  --
PROCEDURE update_fi_emp_asg
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
  ,p_local_unit		          IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_employment_type              IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_working_time_type		  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_shift_work_type		  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_shift_work_type_days	  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_community_price_category	  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_employee_status		  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_personnel_group		  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_insurance_occupational_group IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_union_occupational_group     IN    VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_reported_assignment	  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_tax_category       	  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_social_security_liable	  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_comment_id                      OUT NOCOPY NUMBER
  ,p_soft_coding_keyflex_id          OUT NOCOPY NUMBER
  ,p_effective_start_date            OUT NOCOPY DATE
  ,p_effective_end_date              OUT NOCOPY DATE
  ,p_concatenated_segments           OUT NOCOPY VARCHAR2
  ,p_no_managers_warning             OUT NOCOPY BOOLEAN
  ,p_other_manager_warning           OUT NOCOPY BOOLEAN
  ) is

 --
    -- Declare cursors AND local variables
    --
    l_proc                       VARCHAR2(72) := g_package||'update_fi_emp_asg';
    l_effective_date             DATE;
    l_legislation_code           per_business_groups.legislation_code%TYPE;
    l_business_group_id          per_business_groups.business_group_id%type;
    a              varchar2(100);
    v_field varchar2(20);
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
    -- Check that the legislation of the specified business group IS 'FI'.
    --
    IF l_legislation_code <> 'FI' THEN
      hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
      hr_utility.set_message_token('LEG_CODE','FI');
      hr_utility.raise_error;
    END IF;
    hr_utility.set_location(l_proc, 30);
    --

    --
    -- Call update_emp_asg business process
    --
       hr_assignment_api.update_emp_asg
      (p_validate                     => p_validate
      ,p_effective_date               => p_effective_date
      ,p_datetrack_update_mode        => p_datetrack_update_mode
      ,p_assignment_id                => p_assignment_id
      ,p_object_version_number        => p_object_version_number
      ,p_supervisor_id                => p_supervisor_id
      ,p_assignment_number            => p_assignment_number
      ,p_change_reason                => p_change_reason
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
      ,p_segment2                     => p_local_unit
      ,p_segment3                     => p_employment_type
      ,p_segment4                     => p_working_time_type
      ,p_segment5                     => p_shift_work_type
      ,p_segment6                     => p_shift_work_type_days
      ,p_segment7                     => p_community_price_category
      ,p_segment8                     => p_employee_status
      ,p_segment9                     => p_personnel_group
      ,p_segment10                    => p_insurance_occupational_group
      ,p_segment11                    => p_union_occupational_group
      ,p_segment12                    => p_reported_assignment
      ,p_segment13                    => p_tax_category
      ,p_segment14                    => p_social_security_liable
      ,p_soft_coding_keyflex_id       => p_soft_coding_keyflex_id
      ,p_comment_id                   => p_comment_id
      ,p_effective_start_date         => p_effective_start_date
      ,p_effective_END_date           => p_effective_end_date
      ,p_concatenated_segments        => p_concatenated_segments
      ,p_no_managers_warning          => p_no_managers_warning
      ,p_other_manager_warning        => p_other_manager_warning
      );

    hr_utility.set_location(' Leaving:'||l_proc, 40);
  END update_fi_emp_asg;


END hr_fi_assignment_api;

/
