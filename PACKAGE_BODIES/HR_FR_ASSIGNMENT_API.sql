--------------------------------------------------------
--  DDL for Package Body HR_FR_ASSIGNMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_FR_ASSIGNMENT_API" as
/* $Header: peasgfri.pkb 120.1 2006/06/23 11:24:43 nmuthusa noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_fr_assignment_api.';
--
-- ----------------------------------------------------------------------------
-- |---------------------< create_fr_secondary_emp_asg >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_fr_secondary_emp_asg
(p_validate                     in     boolean
  ,p_effective_date               in     date
  ,p_person_id                    in     number
  ,p_organization_id              in     number
  ,p_grade_id                     in     number
  ,p_position_id                  in     number
  ,p_job_id                       in     number
  ,p_assignment_status_type_id    in     number
  ,p_payroll_id                   in     number
  ,p_location_id                  in     number
  ,p_supervisor_id                in     number
  ,p_special_ceiling_step_id      in     number
  ,p_pay_basis_id                 in     number
  ,p_assignment_number            in out nocopy varchar2
  ,p_change_reason                in     varchar2
  ,p_comments                     in     varchar2
  ,p_date_probation_end           in     date
  ,p_default_code_comb_id         in     number
  ,p_employment_category          in     varchar2
  ,p_frequency                    in     varchar2
  ,p_internal_address_line        in     varchar2
  ,p_manager_flag                 in     varchar2
  ,p_normal_hours                 in     number
  ,p_perf_review_period           in     number
  ,p_perf_review_period_frequency in     varchar2
  ,p_probation_period             in     number
  ,p_probation_unit               in     varchar2
  ,p_sal_review_period            in     number
  ,p_sal_review_period_frequency  in     varchar2
  ,p_set_of_books_id              in     number
  ,p_source_type                  in     varchar2
  ,p_time_normal_finish           in     varchar2
  ,p_time_normal_start            in     varchar2
  ,p_bargaining_unit_code         in     varchar2
  ,p_labour_union_member_flag     in     varchar2
  ,p_ass_attribute_category       in     varchar2
  ,p_ass_attribute1               in     varchar2
  ,p_ass_attribute2               in     varchar2
  ,p_ass_attribute3               in     varchar2
  ,p_ass_attribute4               in     varchar2
  ,p_ass_attribute5               in     varchar2
  ,p_ass_attribute6               in     varchar2
  ,p_ass_attribute7               in     varchar2
  ,p_ass_attribute8               in     varchar2
  ,p_ass_attribute9               in     varchar2
  ,p_ass_attribute10              in     varchar2
  ,p_ass_attribute11              in     varchar2
  ,p_ass_attribute12              in     varchar2
  ,p_ass_attribute13              in     varchar2
  ,p_ass_attribute14              in     varchar2
  ,p_ass_attribute15              in     varchar2
  ,p_ass_attribute16              in     varchar2
  ,p_ass_attribute17              in     varchar2
  ,p_ass_attribute18              in     varchar2
  ,p_ass_attribute19              in     varchar2
  ,p_ass_attribute20              in     varchar2
  ,p_ass_attribute21              in     varchar2
  ,p_ass_attribute22              in     varchar2
  ,p_ass_attribute23              in     varchar2
  ,p_ass_attribute24              in     varchar2
  ,p_ass_attribute25              in     varchar2
  ,p_ass_attribute26              in     varchar2
  ,p_ass_attribute27              in     varchar2
  ,p_ass_attribute28              in     varchar2
  ,p_ass_attribute29              in     varchar2
  ,p_ass_attribute30              in     varchar2
  ,p_title                        in     varchar2
  ,p_employee_category            in     varchar2
  ,p_starting_reason              in     varchar2
  ,p_ending_reason                in     varchar2
  ,p_work_pattern                 in     varchar2
  ,p_work_pattern_start_day       in     number
  ,p_working_days_per_year        in     number
  ,p_detache_status               in     varchar2
  ,p_address_abroad               in     varchar2
  ,p_border_worker                in     varchar2
  ,p_urssaf_code                  in     varchar2
  ,p_professional_status	  in	 varchar2
  ,p_grouping_employer		  in	 varchar2
  ,p_fr_concat_segments           in     varchar2
  ,p_pgp_segment1                 in     varchar2
  ,p_pgp_segment2                 in     varchar2
  ,p_pgp_segment3                 in     varchar2
  ,p_pgp_segment4                 in     varchar2
  ,p_pgp_segment5                 in     varchar2
  ,p_pgp_segment6                 in     varchar2
  ,p_pgp_segment7                 in     varchar2
  ,p_pgp_segment8                 in     varchar2
  ,p_pgp_segment9                 in     varchar2
  ,p_pgp_segment10                in     varchar2
  ,p_pgp_segment11                in     varchar2
  ,p_pgp_segment12                in     varchar2
  ,p_pgp_segment13                in     varchar2
  ,p_pgp_segment14                in     varchar2
  ,p_pgp_segment15                in     varchar2
  ,p_pgp_segment16                in     varchar2
  ,p_pgp_segment17                in     varchar2
  ,p_pgp_segment18                in     varchar2
  ,p_pgp_segment19                in     varchar2
  ,p_pgp_segment20                in     varchar2
  ,p_pgp_segment21                in     varchar2
  ,p_pgp_segment22                in     varchar2
  ,p_pgp_segment23                in     varchar2
  ,p_pgp_segment24                in     varchar2
  ,p_pgp_segment25                in     varchar2
  ,p_pgp_segment26                in     varchar2
  ,p_pgp_segment27                in     varchar2
  ,p_pgp_segment28                in     varchar2
  ,p_pgp_segment29                in     varchar2
  ,p_pgp_segment30                in     varchar2
  ,p_pgp_concat_segments          in     varchar2
  ,p_contract_id                  in     number
  ,p_establishment_id             in     number
  ,p_collective_agreement_id      in     number
  ,p_cagr_id_flex_num             in     number
  ,p_cag_segment1                 in     varchar2
  ,p_cag_segment2                 in     varchar2
  ,p_cag_segment3                 in     varchar2
  ,p_cag_segment4                 in     varchar2
  ,p_cag_segment5                 in     varchar2
  ,p_cag_segment6                 in     varchar2
  ,p_cag_segment7                 in     varchar2
  ,p_cag_segment8                 in     varchar2
  ,p_cag_segment9                 in     varchar2
  ,p_cag_segment10                in     varchar2
  ,p_cag_segment11                in     varchar2
  ,p_cag_segment12                in     varchar2
  ,p_cag_segment13                in     varchar2
  ,p_cag_segment14                in     varchar2
  ,p_cag_segment15                in     varchar2
  ,p_cag_segment16                in     varchar2
  ,p_cag_segment17                in     varchar2
  ,p_cag_segment18                in     varchar2
  ,p_cag_segment19                in     varchar2
  ,p_cag_segment20                in     varchar2
  ,p_cagr_grade_def_id               out nocopy number
  ,p_cagr_concatenated_segments      out nocopy varchar2
  ,p_assignment_id                   out nocopy number
  ,p_soft_coding_keyflex_id          out nocopy number
  ,p_people_group_id                 out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_assignment_sequence             out nocopy number
  ,p_comment_id                      out nocopy number
  ,p_concatenated_segments           out nocopy varchar2
  ,p_group_name                      out nocopy varchar2
  ,p_other_manager_warning           out nocopy boolean
  ) is
  --
  -- Declare cursors and local variables
  --
  l_assignment_number  per_assignments_f.assignment_number%TYPE;
  l_effective_date     date;
  l_legislation_code   per_business_groups.legislation_code%TYPE;
  l_proc               varchar2(72) := g_package||'create_fr_secondary_emp_asg';
  --
  -- Declare dummy variables
  l_concatenated_segments  hr_soft_coding_keyflex.concatenated_segments%TYPE;
  l_soft_coding_keyflex_id per_assignments_f.soft_coding_keyflex_id%TYPE;
  --
  -- Declare cursors
  --
  cursor csr_legislation is
    select null
    from per_assignments_f paf,
         per_business_groups pbg
    where paf.person_id = p_person_id
    and   l_effective_date between paf.effective_start_date
                           and     paf.effective_end_date
    and   pbg.business_group_id = paf.business_group_id
    and   pbg.legislation_code = 'FR';
  --
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Initialise local variable
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Validation in addition to Table Handlers
  --
  -- Ensure that the employee is within a FR business group
  --
  open csr_legislation;
  fetch csr_legislation
  into l_legislation_code;
  if csr_legislation%notfound then
    close csr_legislation;
    hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
    hr_utility.set_message_token('LEG_CODE', 'FR');
    hr_utility.raise_error;
  end if;
  close csr_legislation;
  --
  hr_utility.set_location(l_proc, 20);
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
  ,p_scl_segment2                 =>     p_employee_category
  ,p_scl_segment3                 =>     p_starting_reason
  ,p_scl_segment4                 =>     p_ending_reason
  ,p_scl_segment5                 =>     p_work_pattern
  ,p_scl_segment6                 =>     p_urssaf_code
  ,p_scl_segment11                =>     p_work_pattern_start_day
  ,p_scl_segment12                =>     p_detache_status
  ,p_scl_segment13                =>     p_address_abroad
  ,p_scl_segment14                =>     p_border_worker
  ,p_scl_segment15                =>     p_working_days_per_year
  ,p_scl_segment16		  =>     p_professional_status
  ,p_scl_segment28		  =>	 p_grouping_employer
  ,p_scl_concat_segments          =>	 p_fr_concat_segments
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
  ,p_pgp_concat_segments	  =>     p_pgp_concat_segments
  ,p_contract_id                  =>     p_contract_id
  ,p_establishment_id             =>     p_establishment_id
  ,p_collective_agreement_id      =>     p_collective_agreement_id
  ,p_cagr_id_flex_num             =>     p_cagr_id_flex_num
  ,p_cag_segment1                 =>     p_cag_segment1
  ,p_cag_segment2                 =>     p_cag_segment2
  ,p_cag_segment3                 =>     p_cag_segment3
  ,p_cag_segment4                 =>     p_cag_segment4
  ,p_cag_segment5                 =>     p_cag_segment5
  ,p_cag_segment6                 =>     p_cag_segment6
  ,p_cag_segment7                 =>     p_cag_segment7
  ,p_cag_segment8                 =>     p_cag_segment8
  ,p_cag_segment9                 =>     p_cag_segment9
  ,p_cag_segment10                =>     p_cag_segment10
  ,p_cag_segment11                =>     p_cag_segment11
  ,p_cag_segment12                =>     p_cag_segment12
  ,p_cag_segment13                =>     p_cag_segment13
  ,p_cag_segment14                =>     p_cag_segment14
  ,p_cag_segment15                =>     p_cag_segment15
  ,p_cag_segment16                =>     p_cag_segment16
  ,p_cag_segment17                =>     p_cag_segment17
  ,p_cag_segment18                =>     p_cag_segment18
  ,p_cag_segment19                =>     p_cag_segment19
  ,p_cag_segment20                =>     p_cag_segment20
  ,p_cagr_grade_def_id            =>     p_cagr_grade_def_id
  ,p_cagr_concatenated_segments   =>     p_cagr_concatenated_segments
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
end create_fr_secondary_emp_asg;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_fr_emp_asg >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_fr_emp_asg
  (p_validate                     in     boolean
  ,p_effective_date               in     date
  ,p_datetrack_update_mode        in     varchar2
  ,p_assignment_id                in     number
  ,p_object_version_number        in out nocopy number
  ,p_supervisor_id                in     number
  ,p_assignment_number            in     varchar2
  ,p_change_reason                in     varchar2
  ,p_comments                     in     varchar2
  ,p_date_probation_end           in     date
  ,p_default_code_comb_id         in     number
  ,p_frequency                    in     varchar2
  ,p_internal_address_line        in     varchar2
  ,p_labour_union_member_flag     in     varchar2
  ,p_manager_flag                 in     varchar2
  ,p_normal_hours                 in     number
  ,p_perf_review_period           in     number
  ,p_perf_review_period_frequency in     varchar2
  ,p_probation_period             in     number
  ,p_probation_unit               in     varchar2
  ,p_sal_review_period            in     number
  ,p_sal_review_period_frequency  in     varchar2
  ,p_set_of_books_id              in     number
  ,p_source_type                  in     varchar2
  ,p_time_normal_finish           in     varchar2
  ,p_time_normal_start            in     varchar2
  ,p_ass_attribute_category       in     varchar2
  ,p_ass_attribute1               in     varchar2
  ,p_ass_attribute2               in     varchar2
  ,p_ass_attribute3               in     varchar2
  ,p_ass_attribute4               in     varchar2
  ,p_ass_attribute5               in     varchar2
  ,p_ass_attribute6               in     varchar2
  ,p_ass_attribute7               in     varchar2
  ,p_ass_attribute8               in     varchar2
  ,p_ass_attribute9               in     varchar2
  ,p_ass_attribute10              in     varchar2
  ,p_ass_attribute11              in     varchar2
  ,p_ass_attribute12              in     varchar2
  ,p_ass_attribute13              in     varchar2
  ,p_ass_attribute14              in     varchar2
  ,p_ass_attribute15              in     varchar2
  ,p_ass_attribute16              in     varchar2
  ,p_ass_attribute17              in     varchar2
  ,p_ass_attribute18              in     varchar2
  ,p_ass_attribute19              in     varchar2
  ,p_ass_attribute20              in     varchar2
  ,p_ass_attribute21              in     varchar2
  ,p_ass_attribute22              in     varchar2
  ,p_ass_attribute23              in     varchar2
  ,p_ass_attribute24              in     varchar2
  ,p_ass_attribute25              in     varchar2
  ,p_ass_attribute26              in     varchar2
  ,p_ass_attribute27              in     varchar2
  ,p_ass_attribute28              in     varchar2
  ,p_ass_attribute29              in     varchar2
  ,p_ass_attribute30              in     varchar2
  ,p_title                        in     varchar2
  ,p_employee_category            in     varchar2
  ,p_starting_reason              in     varchar2
  ,p_ending_reason                in     varchar2
  ,p_work_pattern                 in     varchar2
  ,p_work_pattern_start_day       in     number
  ,p_working_days_per_year        in     number
  ,p_detache_status               in     varchar2
  ,p_address_abroad               in     varchar2
  ,p_border_worker                in     varchar2
  ,p_urssaf_code                  in     varchar2
  ,p_professional_status	  in	 varchar2
  ,p_grouping_employer		  in	 varchar2
  ,p_fr_concat_segments           in     varchar2
  ,p_contract_id                  in     number
  ,p_establishment_id             in     number
  ,p_collective_agreement_id      in     number
  ,p_cagr_id_flex_num             in     number
  ,p_cag_segment1                 in     varchar2
  ,p_cag_segment2                 in     varchar2
  ,p_cag_segment3                 in     varchar2
  ,p_cag_segment4                 in     varchar2
  ,p_cag_segment5                 in     varchar2
  ,p_cag_segment6                 in     varchar2
  ,p_cag_segment7                 in     varchar2
  ,p_cag_segment8                 in     varchar2
  ,p_cag_segment9                 in     varchar2
  ,p_cag_segment10                in     varchar2
  ,p_cag_segment11                in     varchar2
  ,p_cag_segment12                in     varchar2
  ,p_cag_segment13                in     varchar2
  ,p_cag_segment14                in     varchar2
  ,p_cag_segment15                in     varchar2
  ,p_cag_segment16                in     varchar2
  ,p_cag_segment17                in     varchar2
  ,p_cag_segment18                in     varchar2
  ,p_cag_segment19                in     varchar2
  ,p_cag_segment20                in     varchar2
  ,p_cagr_grade_def_id               out nocopy number
  ,p_cagr_concatenated_segments      out nocopy varchar2
  ,p_soft_coding_keyflex_id          out nocopy number
  ,p_comment_id                      out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_concatenated_segments           out nocopy varchar2
  ,p_no_managers_warning             out nocopy boolean
  ,p_other_manager_warning           out nocopy boolean
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                       varchar2(72) := g_package||'update_fr_emp_asg';
  l_effective_date             date;
  l_soft_coding_keyflex_id     per_assignments_f.soft_coding_keyflex_id%TYPE;
  l_concatenated_segments      varchar2(2000);
  l_legislation_code           per_business_groups.legislation_code%TYPE;
  l_work_pattern_start_date    varchar2(20);
  l_working_days_per_year      varchar2(20);
  --
  cursor check_legislation
    (c_assignment_id  per_assignments_f.assignment_id%TYPE,
     c_effective_date date
    )
  is
    select bgp.legislation_code
    from per_assignments_f asg,
         per_business_groups bgp
    where asg.business_group_id = bgp.business_group_id
    and   asg.assignment_id     = c_assignment_id
    and   c_effective_date
      between effective_start_date and effective_end_date;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Truncate date variables
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Validate in addition to Table Handlers
  --
  -- Check that the assignment exists.
  --
  open check_legislation(p_assignment_id, l_effective_date);
  fetch check_legislation into l_legislation_code;
  if check_legislation%notfound then
    close check_legislation;
    hr_utility.set_message(801,'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  end if;
  close check_legislation;
  hr_utility.set_location(l_proc, 20);
  --
  -- Check that the legislation of the specified business group is 'FR'.
  --
  if l_legislation_code <> 'FR' then
    hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
    hr_utility.set_message_token('LEG_CODE','FR');
    hr_utility.raise_error;
  end if;
  hr_utility.set_location(l_proc, 30);
  --
  -- Check that valid value for parameters p_work_pattern_start_day and p_working_days_per_year.
  --
  if p_work_pattern_start_day = hr_api.g_number then
    l_work_pattern_start_date := hr_api.g_varchar2;
  else
    l_work_pattern_start_date := p_work_pattern_start_day;
  end if;
  if  p_working_days_per_year = hr_api.g_number then
    l_working_days_per_year := hr_api.g_varchar2;
  else
    l_working_days_per_year := p_working_days_per_year;
  end if;
  --
  -- Call update_emp_asg business process
  --
  hr_assignment_api.update_emp_asg
  (p_validate                     =>     p_validate
  ,p_effective_date               =>     l_effective_date
  ,p_datetrack_update_mode        =>     p_datetrack_update_mode
  ,p_assignment_id                =>     p_assignment_id
  ,p_object_version_number        =>     p_object_version_number
  ,p_supervisor_id                =>     p_supervisor_id
  ,p_assignment_number            =>     p_assignment_number
  ,p_change_reason                =>     p_change_reason
  ,p_comments                     =>     p_comments
  ,p_date_probation_end           =>     trunc(p_date_probation_end)
  ,p_default_code_comb_id         =>     p_default_code_comb_id
  ,p_frequency                    =>     p_frequency
  ,p_internal_address_line        =>     p_internal_address_line
  ,p_labour_union_member_flag     =>     p_labour_union_member_flag
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
  ,p_segment2                     =>     p_employee_category
  ,p_segment3                     =>     p_starting_reason
  ,p_segment4                     =>     p_ending_reason
  ,p_segment5                     =>     p_work_pattern
  ,p_segment6                     =>     p_urssaf_code
  ,p_segment11                    =>     l_work_pattern_start_date
  ,p_segment12                    =>     p_detache_status
  ,p_segment13                    =>     p_address_abroad
  ,p_segment14                    =>     p_border_worker
  ,p_segment15                    =>     l_working_days_per_year
  ,p_segment16			  =>     p_professional_status
  ,p_segment28			  =>	 p_grouping_employer
  ,p_concat_segments              =>	 p_fr_concat_segments
  ,p_contract_id                  =>     p_contract_id
  ,p_establishment_id             =>     p_establishment_id
  ,p_collective_agreement_id      =>     p_collective_agreement_id
  ,p_cagr_id_flex_num             =>     p_cagr_id_flex_num
  ,p_cag_segment1                 =>     p_cag_segment1
  ,p_cag_segment2                 =>     p_cag_segment2
  ,p_cag_segment3                 =>     p_cag_segment3
  ,p_cag_segment4                 =>     p_cag_segment4
  ,p_cag_segment5                 =>     p_cag_segment5
  ,p_cag_segment6                 =>     p_cag_segment6
  ,p_cag_segment7                 =>     p_cag_segment7
  ,p_cag_segment8                 =>     p_cag_segment8
  ,p_cag_segment9                 =>     p_cag_segment9
  ,p_cag_segment10                =>     p_cag_segment10
  ,p_cag_segment11                =>     p_cag_segment11
  ,p_cag_segment12                =>     p_cag_segment12
  ,p_cag_segment13                =>     p_cag_segment13
  ,p_cag_segment14                =>     p_cag_segment14
  ,p_cag_segment15                =>     p_cag_segment15
  ,p_cag_segment16                =>     p_cag_segment16
  ,p_cag_segment17                =>     p_cag_segment17
  ,p_cag_segment18                =>     p_cag_segment18
  ,p_cag_segment19                =>     p_cag_segment19
  ,p_cag_segment20                =>     p_cag_segment20
  ,p_cagr_grade_def_id            =>     p_cagr_grade_def_id
  ,p_cagr_concatenated_segments   =>     p_cagr_concatenated_segments
  ,p_soft_coding_keyflex_id       =>     p_soft_coding_keyflex_id
  ,p_comment_id                   =>     p_comment_id
  ,p_effective_start_date         =>     p_effective_start_date
  ,p_effective_end_date           =>     p_effective_end_date
  ,p_concatenated_segments        =>     p_concatenated_segments
  ,p_no_managers_warning          =>     p_no_managers_warning
  ,p_other_manager_warning        =>     p_other_manager_warning
   );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 30);
  --
  end update_fr_emp_asg;
--
end hr_fr_assignment_api;

/
