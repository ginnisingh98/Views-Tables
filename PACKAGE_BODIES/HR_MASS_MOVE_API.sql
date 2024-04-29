--------------------------------------------------------
--  DDL for Package Body HR_MASS_MOVE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_MASS_MOVE_API" as
/* $Header: pemmvapi.pkb 120.2 2006/06/27 00:18:04 hsajja ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'hr_mass_move_api.';
--
-- ----------------------------------------------------------------------------
-- |---------------------------< MOVE_CWK_ASG >-------------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE  move_cwk_asg
  (p_validate                     IN     BOOLEAN  DEFAULT FALSE
  ,p_effective_date               IN     DATE
  ,p_datetrack_update_mode        IN     VARCHAR2
  ,p_assignment_id                IN     NUMBER
  ,p_object_version_number        IN OUT NOCOPY NUMBER
  ,p_grade_id                     IN     NUMBER   DEFAULT HR_API.G_NUMBER
  ,p_position_id                  IN     NUMBER   DEFAULT HR_API.G_NUMBER
  ,p_job_id                       IN     NUMBER   DEFAULT HR_API.G_NUMBER
  ,p_location_id                  IN     NUMBER   DEFAULT HR_API.G_NUMBER
  ,p_organization_id              IN     NUMBER   DEFAULT HR_API.G_NUMBER
  ,p_people_group_name               OUT NOCOPY VARCHAR2
  ,p_effective_start_date            OUT NOCOPY DATE
  ,p_effective_end_date              OUT NOCOPY DATE
  ,p_people_group_id                 OUT NOCOPY NUMBER
  ,p_org_now_no_manager_warning      OUT NOCOPY BOOLEAN
  ,p_other_manager_warning           OUT NOCOPY BOOLEAN
  ,p_spp_delete_warning              OUT NOCOPY BOOLEAN
  ,p_entries_changed_warning         OUT NOCOPY VARCHAR2
  ,p_tax_district_changed_warning    OUT NOCOPY BOOLEAN) IS
  --
  -- Declare Local Variables
  --
  l_proc VARCHAR2(72) := g_package||'upd_cwk_asg ';
  l_ovn  NUMBER       := p_object_version_number;
  --
  -- Out Parameters
  --
  l_people_group_name                VARCHAR2(240);
  l_effective_start_date             DATE;
  l_effective_end_date               DATE;
  l_people_group_id                  NUMBER;
  l_org_now_no_manager_warning       BOOLEAN;
  l_other_manager_warning            BOOLEAN;
  l_spp_delete_warning               BOOLEAN;
  l_entries_changed_warning          VARCHAR2(1);
  l_tax_district_changed_warning     BOOLEAN;
  --
BEGIN
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  -- Issue a savepoint for rollbacks
  --
  SAVEPOINT move_cwk_asg;
  --
  hr_assignment_api.update_cwk_asg_criteria
    (p_validate                     => p_validate
    ,p_effective_date               => p_effective_date
    ,p_datetrack_update_mode        => p_datetrack_update_mode
    ,p_assignment_id                => p_assignment_Id
    ,p_object_version_number        => l_ovn
    ,p_grade_id                     => p_grade_id
    ,p_position_id                  => p_position_id
    ,p_job_id                       => p_job_id
    ,p_location_id                  => p_location_id
    ,p_organization_id              => p_organization_id
    ,p_people_group_name            => l_people_group_name
    ,p_effective_start_date         => l_effective_start_date
    ,p_effective_end_date           => l_effective_end_date
    ,p_people_group_id              => l_people_group_Id
    ,p_org_now_no_manager_warning   => l_org_now_no_manager_warning
    ,p_other_manager_warning        => l_other_manager_warning
    ,p_spp_delete_warning           => l_spp_delete_warning
    ,p_entries_changed_warning      => l_entries_changed_warning
    ,p_tax_district_changed_warning => l_tax_district_changed_warning);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 997);
  --
EXCEPTION
  --
  WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO move_cwk_asg;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number        := NULL;
    p_effective_start_date         := NULL;
    p_effective_end_date           := NULL;
    p_people_group_name            := l_people_group_name;
    p_people_group_id              := l_people_group_id;
    p_org_now_no_manager_warning   := l_org_now_no_manager_warning;
    p_other_manager_warning        := l_other_manager_warning;
    p_spp_delete_warning           := l_spp_delete_warning;
    p_entries_changed_warning      := l_entries_changed_warning;
    p_tax_district_changed_warning := l_tax_district_changed_warning;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 998);
    --
  WHEN OTHERS THEN
    --
    -- A validation or unexpected error has occurred
    --
    ROLLBACK TO move_cwk_asg;
    --
    -- set in out parameters and set out parameters
    --
    p_object_version_number        := NULL;
    p_effective_start_date         := NULL;
    p_effective_end_date           := NULL;
    p_people_group_name            := NULL;
    p_people_group_id              := NULL;
    p_org_now_no_manager_warning   := FALSE;
    p_other_manager_warning        := FALSE;
    p_spp_delete_warning           := FALSE;
    p_entries_changed_warning      := NULL;
    p_tax_district_changed_warning := FALSE;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 999);
    --
    RAISE;
    --
END move_cwk_asg;
--
-- ----------------------------------------------------------------------------
-- |------------------------< move_emp_asg >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure move_emp_asg
  (p_validate                      in     boolean  default false
  ,p_mass_move_id	                 in     number   default hr_api.g_number
  ,p_effective_date                in     date
  ,p_assignment_id	                in     number
  ,p_object_version_number         in out nocopy number
  ,p_grade_id                      in     number   default hr_api.g_number
  ,p_position_id                   in     number   default hr_api.g_number
  ,p_job_id                        in     number   default hr_api.g_number
  ,p_organization_id	              in     number   default hr_api.g_number
  ,p_location_id	                  in     number   default hr_api.g_number
  ,p_frequency	                    in     varchar2 default hr_api.g_varchar2
  ,p_normal_hours	                 in     number   default hr_api.g_number
  ,p_time_normal_finish            in     varchar2 default hr_api.g_varchar2
  ,p_time_normal_start             in     varchar2 default hr_api.g_varchar2
  ,p_segment1                      in     varchar2 default hr_api.g_varchar2
  ,p_segment2                      in     varchar2 default hr_api.g_varchar2
  ,p_segment3                      in     varchar2 default hr_api.g_varchar2
  ,p_segment4                      in     varchar2 default hr_api.g_varchar2
  ,p_segment5                      in     varchar2 default hr_api.g_varchar2
  ,p_segment6                      in     varchar2 default hr_api.g_varchar2
  ,p_segment7                      in     varchar2 default hr_api.g_varchar2
  ,p_segment8                      in     varchar2 default hr_api.g_varchar2
  ,p_segment9                      in     varchar2 default hr_api.g_varchar2
  ,p_segment10                     in     varchar2 default hr_api.g_varchar2
  ,p_segment11                     in     varchar2 default hr_api.g_varchar2
  ,p_segment12                     in     varchar2 default hr_api.g_varchar2
  ,p_segment13                     in     varchar2 default hr_api.g_varchar2
  ,p_segment14                     in     varchar2 default hr_api.g_varchar2
  ,p_segment15                     in     varchar2 default hr_api.g_varchar2
  ,p_segment16                     in     varchar2 default hr_api.g_varchar2
  ,p_segment17                     in     varchar2 default hr_api.g_varchar2
  ,p_segment18                     in     varchar2 default hr_api.g_varchar2
  ,p_segment19                     in     varchar2 default hr_api.g_varchar2
  ,p_segment20                     in     varchar2 default hr_api.g_varchar2
  ,p_segment21                     in     varchar2 default hr_api.g_varchar2
  ,p_segment22                     in     varchar2 default hr_api.g_varchar2
  ,p_segment23                     in     varchar2 default hr_api.g_varchar2
  ,p_segment24                     in     varchar2 default hr_api.g_varchar2
  ,p_segment25                     in     varchar2 default hr_api.g_varchar2
  ,p_segment26                     in     varchar2 default hr_api.g_varchar2
  ,p_segment27                     in     varchar2 default hr_api.g_varchar2
  ,p_segment28                     in     varchar2 default hr_api.g_varchar2
  ,p_segment29                     in     varchar2 default hr_api.g_varchar2
  ,p_segment30                     in     varchar2 default hr_api.g_varchar2
  ,p_soft_coding_keyflex_id           out nocopy number
  ,p_effective_start_date             out nocopy date
  ,p_effective_end_date	              out nocopy date
  ,p_concatenated_segments            out nocopy varchar2
  ,p_org_now_no_manager_warning       out nocopy boolean
  ,p_other_manager_warning            out nocopy boolean
  ,p_entries_changed_warning          out nocopy varchar2
  ,p_spp_delete_warning               out nocopy boolean
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                            varchar2(72) := g_package||'move_emp_asg';
  l_api_updating                    boolean;
  l_scl_api_updating                boolean;
  l_object_version_number           number(15);
  l_ovn number := p_object_version_number;
  l_special_ceiling_step_id         number(15) default hr_api.g_number;
  l_people_group_id                 number(15);
  l_group_name                      varchar2(240);
  l_spp_delete_warning              boolean;
  l_tax_district_changed_warning    boolean;
  l_no_managers_warning             boolean;
  l_org_now_no_manager_warning      boolean;
  l_other_manager_warning           boolean;
  l_entries_changed_warning         varchar2(1);
  l_comment_id                      number(15);
  l_effective_start_date            date;
  l_scl_updated_flag                boolean default FALSE;
  l_effective_end_date              date;
  l_soft_coding_keyflex_id          number(15) default null;
  l_concatenated_segments           hr_soft_coding_keyflex.concatenated_segments%TYPE default null;
  l_exists                          varchar2(1);
  l_old_asg_eff_start_date          date default null;
  l_old_asg_object_version_num      number(15);
  --
  --
  cursor csr_get_old_asg_data is
    select asg1.effective_start_date
    ,	   asg1.object_version_number
    from   per_assignments_f asg1
    where  asg1.assignment_id = p_assignment_id
           and asg1.effective_start_date =
           (select max(asg2.effective_start_date)
            from   per_assignments_f asg2
	      where  asg1.assignment_id = asg2.assignment_id
    	             and asg2.effective_start_date < p_effective_date);
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint move_emp_asg;
  --
  l_object_version_number := p_object_version_number;
  --
  -- Retrieve current Assignment details
  --
  l_api_updating := per_asg_shd.api_updating
    (p_assignment_id          => p_assignment_id
    ,p_effective_date         => p_effective_date
    ,p_object_version_number  => l_object_version_number);
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Validate that at least one of P_POSITION_ID, P_ORGANIZATION_ID,P_GRADE or
  -- P_LOCATION_ID is being updated.
  --
  if ( ( (nvl(p_organization_id, hr_api.g_number) <> hr_api.g_number )
        and nvl(per_asg_shd.g_old_rec.organization_id, hr_api.g_number) <>
          nvl(p_organization_id, hr_api.g_number) )
     or ( (nvl(p_position_id, hr_api.g_number) <> hr_api.g_number )
          and nvl(per_asg_shd.g_old_rec.position_id, hr_api.g_number) <>                                                                                                                                                nvl(p_position_id,hr_api.g_number) )
     or ( (nvl(p_grade_id, hr_api.g_number) <> hr_api.g_number )
          and nvl(per_asg_shd.g_old_rec.grade_id, hr_api.g_number) <>
          nvl(p_grade_id,hr_api.g_number) )
     or ( ( nvl(p_location_id, hr_api.g_number) <> hr_api.g_number )
          and nvl(per_asg_shd.g_old_rec.location_id, hr_api.g_number) <>
          nvl(p_location_id, hr_api.g_number) ) ) then
     null;
  else
    hr_utility.set_message(801, 'HR_51104_MMV_MUST_UPD_ASG');
    hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location( l_proc, 30 );
  --
  -- Call the pre-core move assignment customer stub
  --
  hr_mass_move_cus.pre_move_emp_asg
  (p_effective_date        => p_effective_date
  ,p_assignment_id         => p_assignment_id
  ,p_object_version_number => p_object_version_number
  ,p_mass_move_id	         => p_mass_move_id
  ,p_position_id           => p_position_id
  ,p_organization_id       => p_organization_id
  ,p_location_id	         => p_location_id
  ,p_frequency	         => p_frequency
  ,p_normal_hours	         => p_normal_hours
  ,p_time_normal_finish    => p_time_normal_finish
  ,p_time_normal_start     => p_time_normal_start
  ,p_segment1              => p_segment1
  ,p_segment2              => p_segment2
  ,p_segment3              => p_segment3
  ,p_segment4              => p_segment4
  ,p_segment5              => p_segment5
  ,p_segment6              => p_segment6
  ,p_segment7              => p_segment7
  ,p_segment8              => p_segment8
  ,p_segment9              => p_segment9
  ,p_segment10             => p_segment10
  ,p_segment11             => p_segment11
  ,p_segment12             => p_segment12
  ,p_segment13             => p_segment13
  ,p_segment14             => p_segment14
  ,p_segment15             => p_segment15
  ,p_segment16             => p_segment16
  ,p_segment17             => p_segment17
  ,p_segment18             => p_segment18
  ,p_segment19             => p_segment19
  ,p_segment20             => p_segment20
  ,p_segment21             => p_segment21
  ,p_segment22             => p_segment22
  ,p_segment23             => p_segment23
  ,p_segment24             => p_segment24
  ,p_segment25             => p_segment25
  ,p_segment26             => p_segment26
  ,p_segment27             => p_segment27
  ,p_segment28             => p_segment28
  ,p_segment29             => p_segment29
  ,p_segment30             => p_segment30
  );
  --
  hr_utility.set_location( l_proc, 40 );
  --
  hr_assignment_api.update_emp_asg_criteria
    (p_validate                     => FALSE
    ,p_effective_date               => p_effective_date
    ,p_datetrack_update_mode        => 'UPDATE'
    ,p_assignment_id                => p_assignment_id
    ,p_object_version_number        => l_object_version_number
    ,p_position_id                  => p_position_id
    ,p_job_id                       => p_job_id
    ,p_location_id                  => p_location_id
    ,p_organization_id	            => p_organization_id
    ,p_grade_id                     => p_grade_id
    ,p_effective_start_date         => l_effective_start_date
    ,p_effective_end_date           => l_effective_end_date
    ,p_special_ceiling_step_id      => l_special_ceiling_step_id
    ,p_people_group_id	            => l_people_group_id
    ,p_group_name	                  => l_group_name
    ,p_org_now_no_manager_warning   => l_org_now_no_manager_warning
    ,p_other_manager_warning        => l_other_manager_warning
    ,p_spp_delete_warning           => l_spp_delete_warning
    ,p_entries_changed_warning      => l_entries_changed_warning
    ,p_tax_district_changed_warning => l_tax_district_changed_warning
    );
  --
  hr_utility.set_location( l_proc, 45 );
  --
  -- Save the object version number and effective start date as of this update
  -- so that they may be passed to the post_move_emp_asg stub package, where
  -- the customer can do further corrections if necessary.
  --
  hr_utility.trace('p_effective_date '|| p_effective_date);
  --
  open csr_get_old_asg_data;
  fetch csr_get_old_asg_data
  into  l_old_asg_eff_start_date
  , 	l_old_asg_object_version_num;
  if csr_get_old_asg_data%notfound then
    hr_utility.set_location( l_proc, 47 );
    l_old_asg_eff_start_date := p_effective_date;
    l_old_asg_object_version_num := l_object_version_number;
  end if;
  close csr_get_old_asg_data;
  --
  hr_utility.set_location( l_proc, 50 );
  --
  -- If the assignment currently has SCL information :
  --
  if per_asg_shd.g_old_rec.soft_coding_keyflex_id is not null then
    hr_utility.set_location( l_proc, 55 );
    --
    l_scl_api_updating := hr_scl_shd.api_updating
                             (p_soft_coding_keyflex_id =>
                                 per_asg_shd.g_old_rec.soft_coding_keyflex_id);
    --
    --    Check whether any of the SCL segments are being updated.
    --
    if ( ( (nvl(p_segment1, hr_api.g_varchar2) <> hr_api.g_varchar2)
            and nvl(hr_scl_shd.g_old_rec.segment1, hr_api.g_varchar2) <>
                                       nvl(p_segment1, hr_api.g_varchar2) )
        or ( (nvl(p_segment2, hr_api.g_varchar2) <> hr_api.g_varchar2)
            and nvl(hr_scl_shd.g_old_rec.segment2, hr_api.g_varchar2) <>
                                       nvl(p_segment2, hr_api.g_varchar2) )
        or ( (nvl(p_segment3, hr_api.g_varchar2) <> hr_api.g_varchar2)
            and nvl(hr_scl_shd.g_old_rec.segment3, hr_api.g_varchar2) <>
                                       nvl(p_segment3, hr_api.g_varchar2) )
        or ( (nvl(p_segment4, hr_api.g_varchar2) <> hr_api.g_varchar2)
            and nvl(hr_scl_shd.g_old_rec.segment4, hr_api.g_varchar2) <>
                                       nvl(p_segment4, hr_api.g_varchar2) )
        or ( (nvl(p_segment5, hr_api.g_varchar2) <> hr_api.g_varchar2)
            and nvl(hr_scl_shd.g_old_rec.segment5, hr_api.g_varchar2) <>
                                       nvl(p_segment5, hr_api.g_varchar2) )
        or ( (nvl(p_segment6, hr_api.g_varchar2) <> hr_api.g_varchar2)
            and nvl(hr_scl_shd.g_old_rec.segment6, hr_api.g_varchar2) <>
                                       nvl(p_segment6, hr_api.g_varchar2) )
        or ( (nvl(p_segment7, hr_api.g_varchar2) <> hr_api.g_varchar2)
            and nvl(hr_scl_shd.g_old_rec.segment7, hr_api.g_varchar2) <>
                                       nvl(p_segment7, hr_api.g_varchar2) )
        or ( (nvl(p_segment8, hr_api.g_varchar2) <> hr_api.g_varchar2)
            and nvl(hr_scl_shd.g_old_rec.segment8, hr_api.g_varchar2) <>
                                       nvl(p_segment8, hr_api.g_varchar2) )
        or ( (nvl(p_segment9, hr_api.g_varchar2) <> hr_api.g_varchar2)
            and nvl(hr_scl_shd.g_old_rec.segment9, hr_api.g_varchar2) <>
                                       nvl(p_segment9, hr_api.g_varchar2) )
        or ( (nvl(p_segment10, hr_api.g_varchar2) <> hr_api.g_varchar2)
            and nvl(hr_scl_shd.g_old_rec.segment10, hr_api.g_varchar2) <>
                                       nvl(p_segment10, hr_api.g_varchar2) )
        or ( (nvl(p_segment11, hr_api.g_varchar2) <> hr_api.g_varchar2)
            and nvl(hr_scl_shd.g_old_rec.segment11, hr_api.g_varchar2) <>
                                       nvl(p_segment11, hr_api.g_varchar2) )
        or ( (nvl(p_segment12, hr_api.g_varchar2) <> hr_api.g_varchar2)
            and nvl(hr_scl_shd.g_old_rec.segment12, hr_api.g_varchar2) <>
                                       nvl(p_segment12, hr_api.g_varchar2) )
        or ( (nvl(p_segment13, hr_api.g_varchar2) <> hr_api.g_varchar2)
            and nvl(hr_scl_shd.g_old_rec.segment13, hr_api.g_varchar2) <>
                                       nvl(p_segment13, hr_api.g_varchar2) )
        or ( (nvl(p_segment14, hr_api.g_varchar2) <> hr_api.g_varchar2)
            and nvl(hr_scl_shd.g_old_rec.segment14, hr_api.g_varchar2) <>
                                       nvl(p_segment14, hr_api.g_varchar2) )
        or ( (nvl(p_segment15, hr_api.g_varchar2) <> hr_api.g_varchar2)
            and nvl(hr_scl_shd.g_old_rec.segment15, hr_api.g_varchar2) <>
                                       nvl(p_segment15, hr_api.g_varchar2) )
        or ( (nvl(p_segment16, hr_api.g_varchar2) <> hr_api.g_varchar2)
            and nvl(hr_scl_shd.g_old_rec.segment16, hr_api.g_varchar2) <>
                                       nvl(p_segment16, hr_api.g_varchar2) )
        or ( (nvl(p_segment17, hr_api.g_varchar2) <> hr_api.g_varchar2)
            and nvl(hr_scl_shd.g_old_rec.segment17, hr_api.g_varchar2) <>
                                       nvl(p_segment17, hr_api.g_varchar2) )
        or ( (nvl(p_segment18, hr_api.g_varchar2) <> hr_api.g_varchar2)
            and nvl(hr_scl_shd.g_old_rec.segment18, hr_api.g_varchar2) <>
                                       nvl(p_segment18, hr_api.g_varchar2) )
        or ( (nvl(p_segment19, hr_api.g_varchar2) <> hr_api.g_varchar2)
            and nvl(hr_scl_shd.g_old_rec.segment19, hr_api.g_varchar2) <>
                                       nvl(p_segment19, hr_api.g_varchar2) )
        or ( (nvl(p_segment20, hr_api.g_varchar2) <> hr_api.g_varchar2)
            and nvl(hr_scl_shd.g_old_rec.segment20, hr_api.g_varchar2) <>
                                       nvl(p_segment20, hr_api.g_varchar2) )
        or ( (nvl(p_segment21, hr_api.g_varchar2) <> hr_api.g_varchar2)
            and nvl(hr_scl_shd.g_old_rec.segment21, hr_api.g_varchar2) <>
                                       nvl(p_segment21, hr_api.g_varchar2) )
        or ( (nvl(p_segment22, hr_api.g_varchar2) <> hr_api.g_varchar2)
            and nvl(hr_scl_shd.g_old_rec.segment22, hr_api.g_varchar2) <>
                                       nvl(p_segment22, hr_api.g_varchar2) )
        or ( (nvl(p_segment23, hr_api.g_varchar2) <> hr_api.g_varchar2)
            and nvl(hr_scl_shd.g_old_rec.segment23, hr_api.g_varchar2) <>
                                       nvl(p_segment23, hr_api.g_varchar2) )
        or ( (nvl(p_segment24, hr_api.g_varchar2) <> hr_api.g_varchar2)
            and nvl(hr_scl_shd.g_old_rec.segment24, hr_api.g_varchar2) <>
                                       nvl(p_segment24, hr_api.g_varchar2) )
        or ( (nvl(p_segment25, hr_api.g_varchar2) <> hr_api.g_varchar2)
            and nvl(hr_scl_shd.g_old_rec.segment25, hr_api.g_varchar2) <>
                                       nvl(p_segment25, hr_api.g_varchar2) )
        or ( (nvl(p_segment26, hr_api.g_varchar2) <> hr_api.g_varchar2)
            and nvl(hr_scl_shd.g_old_rec.segment26, hr_api.g_varchar2) <>
                                       nvl(p_segment26, hr_api.g_varchar2) )
        or ( (nvl(p_segment27, hr_api.g_varchar2) <> hr_api.g_varchar2)
            and nvl(hr_scl_shd.g_old_rec.segment27, hr_api.g_varchar2) <>
                                       nvl(p_segment27, hr_api.g_varchar2) )
        or ( (nvl(p_segment28, hr_api.g_varchar2) <> hr_api.g_varchar2)
            and nvl(hr_scl_shd.g_old_rec.segment28, hr_api.g_varchar2) <>
                                       nvl(p_segment28, hr_api.g_varchar2) )
        or ( (nvl(p_segment29, hr_api.g_varchar2) <> hr_api.g_varchar2)
            and nvl(hr_scl_shd.g_old_rec.segment29, hr_api.g_varchar2) <>
                                       nvl(p_segment29, hr_api.g_varchar2) )
        or ( (nvl(p_segment30, hr_api.g_varchar2) <> hr_api.g_varchar2)
            and nvl(hr_scl_shd.g_old_rec.segment30, hr_api.g_varchar2) <>
                                       nvl(p_segment30, hr_api.g_varchar2) )
       ) then
         --
         hr_utility.set_location( l_proc, 60 );
         --
         l_scl_updated_flag := TRUE;
         --
    else
         --
         hr_utility.set_location( l_proc, 65 );
         --
         l_scl_updated_flag := FALSE;
         --
    end if;
  elsif per_asg_shd.g_old_rec.soft_coding_keyflex_id is null then
    --
    --  Otherwise, if the assignment does not currently have SCL information
    --  check whether any of the SCL segments are being set for the first time
    --
    hr_utility.set_location( l_proc, 70 );
    --
    if nvl(p_segment1, hr_api.g_varchar2) <> hr_api.g_varchar2
       or nvl(p_segment2, hr_api.g_varchar2) <> hr_api.g_varchar2
       or nvl(p_segment3, hr_api.g_varchar2) <> hr_api.g_varchar2
       or nvl(p_segment4, hr_api.g_varchar2) <> hr_api.g_varchar2
       or nvl(p_segment5, hr_api.g_varchar2) <> hr_api.g_varchar2
       or nvl(p_segment6, hr_api.g_varchar2) <> hr_api.g_varchar2
       or nvl(p_segment7, hr_api.g_varchar2) <> hr_api.g_varchar2
       or nvl(p_segment8, hr_api.g_varchar2) <> hr_api.g_varchar2
       or nvl(p_segment9, hr_api.g_varchar2) <> hr_api.g_varchar2
       or nvl(p_segment10, hr_api.g_varchar2) <> hr_api.g_varchar2
       or nvl(p_segment11, hr_api.g_varchar2) <> hr_api.g_varchar2
       or nvl(p_segment12, hr_api.g_varchar2) <> hr_api.g_varchar2
       or nvl(p_segment13, hr_api.g_varchar2) <> hr_api.g_varchar2
       or nvl(p_segment14, hr_api.g_varchar2) <> hr_api.g_varchar2
       or nvl(p_segment15, hr_api.g_varchar2) <> hr_api.g_varchar2
       or nvl(p_segment16, hr_api.g_varchar2) <> hr_api.g_varchar2
       or nvl(p_segment17, hr_api.g_varchar2) <> hr_api.g_varchar2
       or nvl(p_segment18, hr_api.g_varchar2) <> hr_api.g_varchar2
       or nvl(p_segment19, hr_api.g_varchar2) <> hr_api.g_varchar2
       or nvl(p_segment20, hr_api.g_varchar2) <> hr_api.g_varchar2
       or nvl(p_segment21, hr_api.g_varchar2) <> hr_api.g_varchar2
       or nvl(p_segment22, hr_api.g_varchar2) <> hr_api.g_varchar2
       or nvl(p_segment23, hr_api.g_varchar2) <> hr_api.g_varchar2
       or nvl(p_segment24, hr_api.g_varchar2) <> hr_api.g_varchar2
       or nvl(p_segment25, hr_api.g_varchar2) <> hr_api.g_varchar2
       or nvl(p_segment26, hr_api.g_varchar2) <> hr_api.g_varchar2
       or nvl(p_segment27, hr_api.g_varchar2) <> hr_api.g_varchar2
       or nvl(p_segment28, hr_api.g_varchar2) <> hr_api.g_varchar2
       or nvl(p_segment29, hr_api.g_varchar2) <> hr_api.g_varchar2
       or nvl(p_segment30, hr_api.g_varchar2) <> hr_api.g_varchar2 then
         --
         hr_utility.set_location( l_proc, 75 );
         --
         l_scl_updated_flag := TRUE;
         --
    else
         --
         hr_utility.set_location( l_proc, 80 );
         --
         l_scl_updated_flag := FALSE;
         --
    end if;
  end if;
  --
  if ( l_scl_updated_flag
      or ((nvl(p_frequency, hr_api.g_varchar2) <> hr_api.g_varchar2)
         and nvl(per_asg_shd.g_old_rec.frequency, hr_api.g_varchar2) <>
                                  nvl(p_frequency, hr_api.g_varchar2) )
      or ((nvl(p_normal_hours, hr_api.g_number) <> hr_api.g_number)
         and nvl(per_asg_shd.g_old_rec.normal_hours, hr_api.g_number) <>
                                  nvl(p_normal_hours, hr_api.g_number) )
      or ((nvl(p_time_normal_finish, hr_api.g_varchar2) <> hr_api.g_varchar2)
         and nvl(per_asg_shd.g_old_rec.time_normal_finish,hr_api.g_varchar2) <>
                                  nvl(p_time_normal_finish,hr_api.g_varchar2) )
      or ((nvl(p_time_normal_start, hr_api.g_varchar2) <> hr_api.g_varchar2)
         and nvl(per_asg_shd.g_old_rec.time_normal_start, hr_api.g_varchar2) <>
                                  nvl(p_time_normal_start, hr_api.g_varchar2) )
       ) then
       --
       hr_utility.set_location( l_proc, 85 );
       --
       hr_assignment_api.update_emp_asg
         (p_validate                => FALSE
         ,p_effective_date          => p_effective_date
         ,p_datetrack_update_mode   => 'CORRECTION'
         ,p_assignment_id           => p_assignment_id
         ,p_object_version_number   => l_object_version_number
         ,p_frequency               => p_frequency
         ,p_normal_hours            => p_normal_hours
         ,p_time_normal_finish      => p_time_normal_finish
         ,p_time_normal_start       => p_time_normal_start
         ,p_segment1                => p_segment1
         ,p_segment2                => p_segment2
         ,p_segment3                => p_segment3
         ,p_segment4                => p_segment4
         ,p_segment5                => p_segment5
         ,p_segment6                => p_segment6
         ,p_segment7                => p_segment7
         ,p_segment8                => p_segment8
         ,p_segment9                => p_segment9
         ,p_segment10               => p_segment10
         ,p_segment11               => p_segment11
         ,p_segment12               => p_segment12
         ,p_segment13               => p_segment13
         ,p_segment14               => p_segment14
         ,p_segment15               => p_segment15
         ,p_segment16               => p_segment16
         ,p_segment17               => p_segment17
         ,p_segment18               => p_segment18
         ,p_segment19               => p_segment19
         ,p_segment20               => p_segment20
         ,p_segment21               => p_segment21
         ,p_segment22               => p_segment22
         ,p_segment23               => p_segment23
         ,p_segment24               => p_segment24
         ,p_segment25               => p_segment25
         ,p_segment26               => p_segment26
         ,p_segment27               => p_segment27
         ,p_segment28               => p_segment28
         ,p_segment29               => p_segment29
         ,p_segment30               => p_segment30
         ,p_soft_coding_keyflex_id  => l_soft_coding_keyflex_id
         ,p_comment_id              => l_comment_id
         ,p_effective_start_date    => l_effective_start_date
         ,p_effective_end_date      => l_effective_end_date
         ,p_concatenated_segments   => l_concatenated_segments
         ,p_no_managers_warning     => l_no_managers_warning
         ,p_other_manager_warning   => l_other_manager_warning );
  end if;
  --
  hr_utility.set_location( l_proc, 87 );
  --
  -- Call the post-core move assignment customer stub
  -- NOTE : if l_effective_start_date is null assign l_old_asg_eff_start_date
  -- to the p_new_asg_eff_start_date.  l_effective_start_date will be null,
  -- when p_validate = TRUE.
  --
  l_effective_start_date :=
                nvl(l_effective_start_date,l_old_asg_eff_start_date);
 --
  hr_mass_move_cus.post_move_emp_asg
  (p_validate                   => FALSE
  ,p_old_asg_eff_start_date     => l_old_asg_eff_start_date
  ,p_new_asg_eff_start_date     => l_effective_start_date
  ,p_assignment_id	        => p_assignment_id
  ,p_old_asg_object_version_num => l_old_asg_object_version_num
  ,p_new_asg_object_version_num => l_object_version_number
  ,p_mass_move_id	              => p_mass_move_id
  );
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  p_object_version_number       := l_object_version_number;
  p_soft_coding_keyflex_id      := l_soft_coding_keyflex_id;
  p_effective_start_date        := l_effective_start_date;
  p_effective_end_date          := l_effective_end_date;
  p_concatenated_segments       := l_concatenated_segments;
  p_org_now_no_manager_warning  := l_org_now_no_manager_warning;
  p_other_manager_warning       := l_other_manager_warning;
  p_entries_changed_warning     := l_entries_changed_warning;
  p_spp_delete_warning          := l_spp_delete_warning;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 997);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO move_emp_asg;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number       := p_object_version_number;
    p_soft_coding_keyflex_id      := null;
    p_effective_start_date        := null;
    p_effective_end_date          := null;
    p_concatenated_segments       := null;
    p_org_now_no_manager_warning  := l_org_now_no_manager_warning;
    p_other_manager_warning       := l_other_manager_warning;
    p_entries_changed_warning     := l_entries_changed_warning;
    p_spp_delete_warning          := l_spp_delete_warning;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 998);
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of the fix to bug 632479
    --
    ROLLBACK TO move_emp_asg;
    --
    -- set in out parameters and set out parameters
    --
    p_object_version_number       := l_ovn;
    p_soft_coding_keyflex_id      := null;
    p_effective_start_date        := null;
    p_effective_end_date          := null;
    p_concatenated_segments       := null;
    p_org_now_no_manager_warning  := false;
    p_other_manager_warning       := false;
    p_entries_changed_warning     := null;
    p_spp_delete_warning          := false;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 999);
    --
    raise;
    --
end move_emp_asg;
--
-- ----------------------------------------------------------------------------
-- |----------------------< move_position >-----------------------------------|
-- ----------------------------------------------------------------------------
--
procedure move_position
  (p_validate                      in     boolean  default false
  ,p_batch_run_number              in     number
  ,p_position_id                   in     number
  ,p_job_id                        in     number
  ,p_object_version_number         in out nocopy number
  ,p_date_effective                in     date
  ,p_organization_id               in     number
  ,p_segment1                      in     varchar2 default null
  ,p_segment2                      in     varchar2 default null
  ,p_segment3                      in     varchar2 default null
  ,p_segment4                      in     varchar2 default null
  ,p_segment5                      in     varchar2 default null
  ,p_segment6                      in     varchar2 default null
  ,p_segment7                      in     varchar2 default null
  ,p_segment8                      in     varchar2 default null
  ,p_segment9                      in     varchar2 default null
  ,p_segment10                     in     varchar2 default null
  ,p_segment11                     in     varchar2 default null
  ,p_segment12                     in     varchar2 default null
  ,p_segment13                     in     varchar2 default null
  ,p_segment14                     in     varchar2 default null
  ,p_segment15                     in     varchar2 default null
  ,p_segment16                     in     varchar2 default null
  ,p_segment17                     in     varchar2 default null
  ,p_segment18                     in     varchar2 default null
  ,p_segment19                     in     varchar2 default null
  ,p_segment20                     in     varchar2 default null
  ,p_segment21                     in     varchar2 default null
  ,p_segment22                     in     varchar2 default null
  ,p_segment23                     in     varchar2 default null
  ,p_segment24                     in     varchar2 default null
  ,p_segment25                     in     varchar2 default null
  ,p_segment26                     in     varchar2 default null
  ,p_segment27                     in     varchar2 default null
  ,p_segment28                     in     varchar2 default null
  ,p_segment29                     in     varchar2 default null
  ,p_segment30                     in     varchar2 default null
  ,p_concat_segments               in     varchar2 default null
  ,p_deactivate_old_position       in     boolean  default false
  ,p_mass_move_id                  in     number   default null
  ,p_time_normal_start             in     varchar2
  ,p_time_normal_finish            in     varchar2
  ,p_normal_hours                  in     number
  ,p_frequency                     in     varchar2
  ,p_location_id                   in     number
  ,p_new_position_id                  out nocopy number
  ,p_new_job_id                       out nocopy number
  ,p_new_object_version_number        out nocopy number
  ,p_valid_grades_changed_warning     out nocopy boolean
  ,p_pos_exists_warning               out nocopy boolean
  ,p_pos_date_range_warning           out nocopy boolean
  ,p_pos_pending_close_warning        out nocopy boolean
  ,p_pos_jbe_not_moved_warning        out nocopy boolean
  ,p_pos_vac_not_moved_warning        out nocopy boolean
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                         varchar2(72) := g_package||'move_position';
  l_effective_start_date	     date;
  l_ovn number := p_object_version_number;
  l_effective_end_date		     date;
  l_business_group_id            number;
  l_position_definition_id       number(15);
  l_name                         varchar2(240);
  l_successor_position_id        number(15);
  l_relief_position_id           number(15);
  l_comments                     varchar2(2000);
  l_probation_period             number(22,2);
  l_probation_period_units       varchar2(30);
  l_replacement_required_flag    varchar2(30);
  l_attribute_category           varchar2(30);
  l_attribute1                   varchar2(150);
  l_attribute2                   varchar2(150);
  l_attribute3                   varchar2(150);
  l_attribute4                   varchar2(150);
  l_attribute5                   varchar2(150);
  l_attribute6                   varchar2(150);
  l_attribute7                   varchar2(150);
  l_attribute8                   varchar2(150);
  l_attribute9                   varchar2(150);
  l_attribute10                  varchar2(150);
  l_attribute11                  varchar2(150);
  l_attribute12                  varchar2(150);
  l_attribute13                  varchar2(150);
  l_attribute14                  varchar2(150);
  l_attribute15                  varchar2(150);
  l_attribute16                  varchar2(150);
  l_attribute17                  varchar2(150);
  l_attribute18                  varchar2(150);
  l_attribute19                  varchar2(150);
  l_attribute20                  varchar2(150);
  l_date_end                     date;
  l_valid_grades_changed_warning boolean;
  l_pos_exists_warning           boolean;
  l_pos_date_range_warning       boolean;
  l_pos_pending_close_warning    boolean;
  l_pos_jbe_not_moved_warning    boolean;
  l_pos_vac_not_moved_warning    boolean;
  l_new_position_id              number(15);
  l_new_job_id                   number(15);
  l_new_object_version_number    number(15);
  l_analysis_criteria_id         number(15);
  l_job_requirement_id           number(15);
  l_jbr_object_version_number    number(15);
  l_old_position_def             number(15);
  l_old_name                     varchar2(240);
  l_valid_grade_id               number(15);
  l_vgr_object_version_number    number(15);
  l_object_version_number        number(15);
  l_new_pos_date_effective       date;
  l_new_position_date_end        date;
  l_new_pos_org                  number(15);
  l_exists                       varchar2(1);
  l_dummy_line_id                number(15);
  l_flex_num                     fnd_id_flex_segments.id_flex_num%TYPE;

p_effective_date		date;
p_availability_status_id	number(15);
p_entry_step_id			number(15);
p_entry_grade_rule_id		number(15);
p_pay_freq_payroll_id		number(15);
p_position_transaction_id   number(15);
p_prior_position_id		number(15);
p_entry_grade_id		number(15);
p_supervisor_position_id	number(15);
p_amendment_date		date;
p_amendment_recommendation	varchar2(240);
p_amendment_ref_number		varchar2(30);
p_bargaining_unit_cd		varchar2(80);
p_current_job_prop_end_date	date;
p_current_org_prop_end_date	date;
p_avail_status_prop_end_date	date;
p_earliest_hire_date		date;
p_fill_by_date			date;
p_fte				number(9,2);
p_max_persons			number(9,2);
p_overlap_period		number(15);
p_overlap_unit_cd		varchar2(80);
p_pay_term_end_day_cd		varchar2(80);
p_pay_term_end_month_cd		varchar2(80);
p_permanent_temporary_flag	varchar2(80);
p_permit_recruitment_flag	varchar2(80);
p_position_type			varchar2(80);
p_posting_description		varchar2(240);
p_review_flag			varchar2(80);
p_seasonal_flag			varchar2(80);
p_security_requirements		varchar2(240);
p_status			varchar2(80);
p_term_start_day_cd		varchar2(80);
p_term_start_month_cd		varchar2(80);
p_update_source_cd		varchar2(80);
p_works_council_approval_flag	varchar2(80);
p_work_period_type_cd		varchar2(80);
p_work_term_end_day_cd		varchar2(80);
p_work_term_end_month_cd	varchar2(80);
p_proposed_fte_for_layoff	number(9,2);
p_proposed_date_for_layoff	date;
p_pay_basis_id			number(15);
p_supervisor_id			number(15);
p_copied_to_old_table_flag	varchar2(80);
--
-- Added as part of fix for bug 2943725
--
l_system_type_cd         per_shared_types.system_type_cd%TYPE;
l_current_system_type_cd per_shared_types.system_type_cd%TYPE;
  --
  cursor csr_old_pos is
    select
    position_definition_id
    ,name
    ,business_group_id
      ,successor_position_id
      ,relief_position_id
      ,comments
      ,probation_period
      ,probation_period_unit_cd
      ,replacement_required_flag
      ,attribute_category
      ,attribute1
      ,attribute2
      ,attribute3
      ,attribute4
      ,attribute5
      ,attribute6
      ,attribute7
      ,attribute8
      ,attribute9
      ,attribute10
      ,attribute11
      ,attribute12
      ,attribute13
      ,attribute14
      ,attribute15
      ,attribute16
      ,attribute17
      ,attribute18
      ,attribute19
      ,attribute20
--,effective_date
,availability_status_id
,entry_step_id
,entry_grade_rule_id
,pay_freq_payroll_id
,position_transaction_id
,prior_position_id
,entry_grade_id
,p_supervisor_position_id
,amendment_date
,amendment_recommendation
,amendment_ref_number
,bargaining_unit_cd
,current_job_prop_end_date
,current_org_prop_end_date
,avail_status_prop_end_date
,earliest_hire_date
,fill_by_date
,fte
,max_persons
,overlap_period
,overlap_unit_cd
,pay_term_end_day_cd
,pay_term_end_month_cd
,permanent_temporary_flag
,permit_recruitment_flag
,position_type
,posting_description
,review_flag
,seasonal_flag
,security_requirements
,status
,term_start_day_cd
,term_start_month_cd
,update_source_cd
,works_council_approval_flag
,work_period_type_cd
,work_term_end_day_cd
,work_term_end_month_cd
,proposed_fte_for_layoff
,proposed_date_for_layoff
,pay_basis_id
,supervisor_id
--,copied_to_old_table_flag
    from hr_positions_f
    where position_id = p_position_id
    and p_date_effective
    between effective_start_date
    and effective_end_date;
  --
  cursor csr_new_pos is
   select position_id
     ,job_id
     ,object_version_number
     ,date_effective
     ,date_end
     ,organization_id
   from hr_positions_f
   where position_definition_id = l_position_definition_id
    and business_group_id = l_business_group_id
    and p_date_effective
    between effective_start_date
    and effective_end_date;
  --
  cursor csr_jbr is
   select pjr.analysis_criteria_id
         ,business_group_id
         ,attribute_category
         ,attribute1
         ,attribute2
         ,attribute3
         ,attribute4
         ,attribute5
         ,attribute6
         ,attribute7
         ,attribute8
         ,attribute9
         ,attribute10
         ,attribute11
         ,attribute12
         ,attribute13
         ,attribute14
         ,attribute15
         ,attribute16
         ,attribute17
         ,attribute18
         ,attribute19
         ,attribute20
         ,comments
         ,essential
         ,job_id
         ,position_id
         ,id_flex_num
         ,segment1
         ,segment2
         ,segment3
         ,segment4
         ,segment5
         ,segment6
         ,segment7
         ,segment8
         ,segment9
         ,segment10
         ,segment11
         ,segment12
         ,segment13
         ,segment14
         ,segment15
         ,segment16
         ,segment17
         ,segment18
         ,segment19
         ,segment20
         ,segment21
         ,segment22
         ,segment23
         ,segment24
         ,segment25
         ,segment26
         ,segment27
         ,segment28
         ,segment29
         ,segment30
  from per_job_requirements pjr, per_analysis_criteria pac
  where pjr.position_id = p_position_id
        and pjr.analysis_criteria_id = pac.analysis_criteria_id
        and not exists
         (select 'x'
            from per_job_requirements jbr2
            where jbr2.analysis_criteria_id = pjr.analysis_criteria_id
                  and jbr2.position_id = l_new_position_id
                  and jbr2.business_group_id = l_business_group_id);
  --
  cursor csr_vgr is
  select mmvgr.target_grade_id
         ,mmvgr.position_id
         ,mmvgr.attribute_category
         ,mmvgr.attribute1
         ,mmvgr.attribute2
         ,mmvgr.attribute3
         ,mmvgr.attribute4
         ,mmvgr.attribute5
         ,mmvgr.attribute6
         ,mmvgr.attribute7
         ,mmvgr.attribute8
         ,mmvgr.attribute9
         ,mmvgr.attribute10
         ,mmvgr.attribute11
         ,mmvgr.attribute12
         ,mmvgr.attribute13
         ,mmvgr.attribute14
         ,mmvgr.attribute15
         ,mmvgr.attribute16
         ,mmvgr.attribute17
         ,mmvgr.attribute18
         ,mmvgr.attribute19
         ,mmvgr.attribute20
    from per_mm_valid_grades mmvgr
    where mmvgr.mass_move_id = p_mass_move_id
         and mmvgr.position_id = p_position_id
         and not exists
           (select vgr.grade_id
             from per_valid_grades vgr
               where vgr.position_id = l_new_position_id
               and vgr.grade_id = mmvgr.target_grade_id
               and vgr.business_group_id = l_business_group_id);
  --
  cursor csr_pos_job_eval is
    select null
    from   per_job_evaluations jbe
    where  jbe.position_id = p_position_id;
  --
  cursor csr_pos_vacancy  is
    select null
    from   per_vacancies vac
    where  vac.position_id = p_position_id
           and p_date_effective between vac.date_from
           and nvl(vac.date_to, hr_api.g_eot);
  --
   cursor isdel is
     select pbg.position_structure
     from per_business_groups pbg
     where pbg.business_group_id = l_business_group_id;
  --
  -- Moved and modified as part of fix for bug 2943725
  --
  cursor csr_avail_status(p_system_type_cd IN per_shared_types.system_type_cd%TYPE) is
    select shared_type_id
    from   per_shared_types
    where  lookup_type = 'POSITION_AVAILABILITY_STATUS'
    and    system_type_cd = p_system_type_cd
    and    business_group_id IS NULL;
  --
  -- Add as part of fix for bug 2943725
  --
  cursor csr_current_status is
    select pst.system_type_cd
    from   hr_positions_f hpf,
           per_shared_types pst
    where  lookup_type = 'POSITION_AVAILABILITY_STATUS'
    and    pst.shared_type_id = hpf.availability_status_id
    and    hpf.position_id = p_position_id
    and    p_date_effective between hpf.effective_start_date
                                and hpf.effective_end_date;
  --
  cursor csr_pos_current_esd(p_position_id number, p_effective_date date) is
  select 'CORRECTION'
  from hr_all_positions_f
  where position_id = p_position_id
  and p_effective_date = effective_start_date
  and effective_end_date = hr_general.end_of_time;
  --
  l_pos_dt_mode varchar2(30);
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint
  --
  savepoint move_position;
  --
  l_object_version_number := p_object_version_number;
  --
  --  Make sure p_position_id is not null
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                           p_argument         => 'p_position_id',
                           p_argument_value   => p_position_id);
  --
  -- Get business_group_id, and all attributes of 'old' position.
  --
  hr_utility.set_location(l_proc, 10);
  --
  open  csr_old_pos;
  fetch csr_old_pos
  into
l_old_position_def
,l_old_name
  ,l_business_group_id
            ,l_successor_position_id
            ,l_relief_position_id
            ,l_comments
            ,l_probation_period
            ,l_probation_period_units
            ,l_replacement_required_flag
            ,l_attribute_category
            ,l_attribute1
            ,l_attribute2
            ,l_attribute3
            ,l_attribute4
            ,l_attribute5
            ,l_attribute6
            ,l_attribute7
            ,l_attribute8
            ,l_attribute9
            ,l_attribute10
            ,l_attribute11
            ,l_attribute12
            ,l_attribute13
            ,l_attribute14
            ,l_attribute15
            ,l_attribute16
            ,l_attribute17
            ,l_attribute18
            ,l_attribute19
            ,l_attribute20
,p_availability_status_id
,p_entry_step_id
,p_entry_grade_rule_id
,p_pay_freq_payroll_id
,p_position_transaction_id
,p_prior_position_id
,p_entry_grade_id
,p_supervisor_position_id
,p_amendment_date
,p_amendment_recommendation
,p_amendment_ref_number
,p_bargaining_unit_cd
,p_current_job_prop_end_date
,p_current_org_prop_end_date
,p_avail_status_prop_end_date
,p_earliest_hire_date
,p_fill_by_date
,p_fte
,p_max_persons
,p_overlap_period
,p_overlap_unit_cd
,p_pay_term_end_day_cd
,p_pay_term_end_month_cd
,p_permanent_temporary_flag
,p_permit_recruitment_flag
,p_position_type
,p_posting_description
,p_review_flag
,p_seasonal_flag
,p_security_requirements
,p_status
,p_term_start_day_cd
,p_term_start_month_cd
,p_update_source_cd
,p_works_council_approval_flag
,p_work_period_type_cd
,p_work_term_end_day_cd
,p_work_term_end_month_cd
,p_proposed_fte_for_layoff
,p_proposed_date_for_layoff
,p_pay_basis_id
,p_supervisor_id;
  --
  if csr_old_pos%notfound then
    --
    hr_utility.set_location(l_proc, 20);
    --
    close csr_old_pos;
    hr_utility.set_message(801, 'HR_51093_POS_NOT_EXIST');
    hr_utility.raise_error;
    --
  else
    close csr_old_pos;
  end if;
  --
  hr_utility.set_location(l_proc, 30);

open isdel;
  fetch isdel into l_flex_num;
  if isdel%notfound then
    close isdel;
    --
    -- the flex structure has not been found
    --
    hr_utility.set_message(801, 'HR_7471_FLEX_POS_INVLALID_ID');
    hr_utility.raise_error;
  end if;
  close isdel;
  hr_utility.set_location(l_proc, 40);
  --
  --  Determine if the 'new' position exists by calling ins_or_sel
  --  to get position definition id
  --
  hr_kflex_utility.ins_or_sel_keyflex_comb
    (p_appl_short_name		    => 'PER'
    ,p_flex_code		    => 'POS'
    ,p_flex_num                     => l_flex_num
    ,p_segment1                     => p_segment1
    ,p_segment2                     => p_segment2
    ,p_segment3                     => p_segment3
    ,p_segment4                     => p_segment4
    ,p_segment5                     => p_segment5
    ,p_segment6                     => p_segment6
    ,p_segment7                     => p_segment7
    ,p_segment8                     => p_segment8
    ,p_segment9                     => p_segment9
    ,p_segment10                    => p_segment10
    ,p_segment11                    => p_segment11
    ,p_segment12                    => p_segment12
    ,p_segment13                    => p_segment13
    ,p_segment14                    => p_segment14
    ,p_segment15                    => p_segment15
    ,p_segment16                    => p_segment16
    ,p_segment17                    => p_segment17
    ,p_segment18                    => p_segment18
    ,p_segment19                    => p_segment19
    ,p_segment20                    => p_segment20
    ,p_segment21                    => p_segment21
    ,p_segment22                    => p_segment22
    ,p_segment23                    => p_segment23
    ,p_segment24                    => p_segment24
    ,p_segment25                    => p_segment25
    ,p_segment26                    => p_segment26
    ,p_segment27                    => p_segment27
    ,p_segment28                    => p_segment28
    ,p_segment29                    => p_segment29
    ,p_segment30                    => p_segment30
    ,p_concat_segments_in           => p_concat_segments
    ,p_ccid		            => l_position_definition_id
    ,p_concat_segments_out          => l_name
    );
  --
  --  Check if 'new' position already exists within date range
  --
  hr_utility.set_location(l_proc, 50);
  --
  open  csr_new_pos;
  fetch csr_new_pos into
     l_new_position_id
    ,l_new_job_id
    ,l_new_object_version_number
    ,l_new_pos_date_effective
    ,l_new_position_date_end
    ,l_new_pos_org;
  --
  if csr_new_pos%found then
    --  Check if 'new' position exists but in a different organization
    hr_utility.set_location(l_proc, 60);
    --
    --  Warn if 'new' position exists but in a different organization
    --
    if l_new_pos_org <> p_organization_id then
      l_pos_exists_warning := TRUE;
    --
    --  Warn if mass_move_effective date is outside range of target position.
    --
    elsif (p_date_effective < l_new_pos_date_effective or
    p_date_effective > l_new_position_date_end) then
      l_pos_date_range_warning := TRUE;
    --
    --  Warn if the target position date has a future end date.
    --
    elsif l_new_position_date_end is not null then
      l_pos_pending_close_warning := TRUE;
    --
    end if;  --l_new_pos_org <> p_organization_id
  end if;  --csr_new_pos%found
  close csr_new_pos;
  --
  --
  open  csr_pos_job_eval;
  fetch csr_pos_job_eval
  into l_exists;
  if csr_pos_job_eval%found then
    l_pos_jbe_not_moved_warning := TRUE;
  end if;
  close csr_pos_job_eval;
  --
  open  csr_pos_vacancy;
  fetch csr_pos_vacancy
  into l_exists;
  if csr_pos_vacancy%found then
     l_pos_vac_not_moved_warning := TRUE;
  end if;
  close csr_pos_vacancy;
  --
  --  Call the pre_move_position stub for any customer specific processing
  --
  hr_utility.set_location(l_proc, 70);
  --
  hr_mass_move_cus.pre_move_position
  (p_position_id           => p_position_id
  ,p_object_version_number => l_object_version_number
  ,p_date_effective        => p_date_effective
  ,p_organization_id       => p_organization_id
  ,p_business_group_id     => l_business_group_id
  ,p_segment1              => p_segment1
  ,p_segment2              => p_segment2
  ,p_segment3              => p_segment3
  ,p_segment4              => p_segment4
  ,p_segment5              => p_segment5
  ,p_segment6              => p_segment6
  ,p_segment7              => p_segment7
  ,p_segment8              => p_segment8
  ,p_segment9              => p_segment9
  ,p_segment10             => p_segment10
  ,p_segment11             => p_segment11
  ,p_segment12             => p_segment12
  ,p_segment13             => p_segment13
  ,p_segment14             => p_segment14
  ,p_segment15             => p_segment15
  ,p_segment16             => p_segment16
  ,p_segment17             => p_segment17
  ,p_segment18             => p_segment18
  ,p_segment19             => p_segment19
  ,p_segment20             => p_segment20
  ,p_segment21             => p_segment21
  ,p_segment22             => p_segment22
  ,p_segment23             => p_segment23
  ,p_segment24             => p_segment24
  ,p_segment25             => p_segment25
  ,p_segment26             => p_segment26
  ,p_segment27             => p_segment27
  ,p_segment28             => p_segment28
  ,p_segment29             => p_segment29
  ,p_segment30             => p_segment30
  ,p_deactivate_old_position => p_deactivate_old_position
  ,p_mass_move_id          => p_mass_move_id
  );
  --
  -- If the 'new' position did not exist then create the 'new' position
  --
  if l_new_position_id is null then
    --
    hr_utility.set_location(l_proc, 80);
    --
        hr_position_api.create_position
     (p_validate                   => FALSE
     ,p_position_id                => l_new_position_id
     ,p_effective_start_date	   => l_effective_start_date
     ,p_effective_end_date	       => l_effective_end_date
     ,p_position_definition_id     => l_position_definition_id
     ,p_name                       => l_name
     ,p_object_version_number      => l_new_object_version_number
     ,p_job_id                     => p_job_id
     ,p_organization_id            => p_organization_id
     ,p_effective_date             => p_date_effective    --p_effective_date
     ,p_date_effective             => p_date_effective
     ,p_availability_status_id     => p_availability_status_id
     ,p_business_group_id	   => l_business_group_id
     ,p_entry_step_id 		   => p_entry_step_id
     ,p_entry_grade_rule_id	   => p_entry_grade_rule_id
     ,p_location_id		   => p_location_id
     ,p_pay_freq_payroll_id 	   => p_pay_freq_payroll_id
     ,p_position_transaction_id	   => p_position_transaction_id
     ,p_prior_position_id	   => p_prior_position_id
     ,p_relief_position_id         => l_relief_position_id
     ,p_entry_grade_id		   => p_entry_grade_id
     ,p_successor_position_id      => l_successor_position_id
     ,p_supervisor_position_id     => p_supervisor_position_id
     ,p_amendment_date		   => p_amendment_date
     ,p_amendment_recommendation   => p_amendment_recommendation
     ,p_amendment_ref_number	   => p_amendment_ref_number
     ,p_bargaining_unit_cd	   => p_bargaining_unit_cd
     ,p_comments                   => l_comments
     ,p_current_job_prop_end_date  => p_current_job_prop_end_date
     ,p_current_org_prop_end_date  => p_current_org_prop_end_date
     ,p_avail_status_prop_end_date => p_avail_status_prop_end_date
     ,p_date_end		   => l_date_end
     ,p_earliest_hire_date	   => p_earliest_hire_date
     ,p_fill_by_date		   => p_fill_by_date
     ,p_frequency                  => p_frequency
     ,p_fte			   => p_fte
     ,p_max_persons		   => p_max_persons
     ,p_overlap_period		   => p_overlap_period
     ,p_overlap_unit_cd	  	   => p_overlap_unit_cd
     ,p_pay_term_end_day_cd	   => p_pay_term_end_day_cd
     ,p_pay_term_end_month_cd	   => p_pay_term_end_month_cd
     ,p_permanent_temporary_flag   => p_permanent_temporary_flag
     ,p_permit_recruitment_flag    => p_permit_recruitment_flag
     ,p_position_type		   => p_position_type
     ,p_posting_description	   => p_posting_description
     ,p_probation_period           => l_probation_period
     ,p_probation_period_unit_cd   => l_probation_period_units
     ,p_replacement_required_flag  => l_replacement_required_flag
     ,p_review_flag		   => p_review_flag
     ,p_seasonal_flag		   => p_seasonal_flag
     ,p_security_requirements	   => p_security_requirements
     ,p_status			   => p_status
     ,p_term_start_day_cd	   => p_term_start_day_cd
     ,p_term_start_month_cd	   => p_term_start_month_cd
     ,p_time_normal_finish         => p_time_normal_finish
     ,p_time_normal_start          => p_time_normal_start
     ,p_update_source_cd	   => p_update_source_cd
     ,p_working_hours              => p_normal_hours
     ,p_works_council_approval_flag=> p_works_council_approval_flag
     ,p_work_period_type_cd	   => p_work_period_type_cd
     ,p_work_term_end_day_cd	   => p_work_term_end_day_cd
     ,p_work_term_end_month_cd	   => p_work_term_end_month_cd
     ,p_proposed_fte_for_layoff	   => p_proposed_fte_for_layoff
     ,p_proposed_date_for_layoff   => p_proposed_date_for_layoff
     ,p_pay_basis_id		   => p_pay_basis_id
     ,p_supervisor_id		   => p_supervisor_id
--     ,p_copied_to_old_table_flag   => p_copied_to_old_table_flag
     /*
     ,p_information_category         => l_information_category
     ,p_information1                 => l_information1
     ,p_information2                 => l_information2
     ,p_information3                 => l_information3
     ,p_information4                 => l_information4
     ,p_information5                 => l_information5
     ,p_information6                 => l_information6
     ,p_information7                 => l_information7
     ,p_information8                 => l_information8
     ,p_information9                 => l_information9
     ,p_information10                => l_information10
     ,p_information11                => l_information11
     ,p_information12                => l_information12
     ,p_information13                => l_information13
     ,p_information14                => l_information14
     ,p_information15                => l_information15
     ,p_information16                => l_information16
     ,p_information17                => l_information17
     ,p_information18                => l_information18
     ,p_information19                => l_information19
     ,p_information20                => l_information20
     ,p_information21                => l_information21
     ,p_information22                => l_information22
     ,p_information23                => l_information23
     ,p_information24                => l_information24
     ,p_information25                => l_information25
     ,p_information26                => l_information26
     ,p_information27                => l_information27
     ,p_information28                => l_information28
     ,p_information29                => l_information29
     ,p_information30                => l_information30
     */
     ,p_attribute_category         => l_attribute_category
     ,p_attribute1                 => l_attribute1
     ,p_attribute2                 => l_attribute2
     ,p_attribute3                 => l_attribute3
     ,p_attribute4                 => l_attribute4
     ,p_attribute5                 => l_attribute5
     ,p_attribute6                 => l_attribute6
     ,p_attribute7                 => l_attribute7
     ,p_attribute8                 => l_attribute8
     ,p_attribute9                 => l_attribute9
     ,p_attribute10                => l_attribute10
     ,p_attribute11                => l_attribute11
     ,p_attribute12                => l_attribute12
     ,p_attribute13                => l_attribute13
     ,p_attribute14                => l_attribute14
     ,p_attribute15                => l_attribute15
     ,p_attribute16                => l_attribute16
     ,p_attribute17                => l_attribute17
     ,p_attribute18                => l_attribute18
     ,p_attribute19                => l_attribute19
     ,p_attribute20                => l_attribute20
     /*
     ,p_attribute21                => l_attribute21
     ,p_attribute22                => l_attribute22
     ,p_attribute23                => l_attribute23
     ,p_attribute24                => l_attribute24
     ,p_attribute25                => l_attribute25
     ,p_attribute26                => l_attribute26
     ,p_attribute27                => l_attribute27
     ,p_attribute28                => l_attribute28
     ,p_attribute29                => l_attribute29
     ,p_attribute30                => l_attribute30
     */
     ,p_segment1                   => p_segment1
     ,p_segment2                   => p_segment2
     ,p_segment3                   => p_segment3
     ,p_segment4                   => p_segment4
     ,p_segment5                   => p_segment5
     ,p_segment6                   => p_segment6
     ,p_segment7                   => p_segment7
     ,p_segment8                   => p_segment8
     ,p_segment9                   => p_segment9
     ,p_segment10                  => p_segment10
     ,p_segment11                  => p_segment11
     ,p_segment12                  => p_segment12
     ,p_segment13                  => p_segment13
     ,p_segment14                  => p_segment14
     ,p_segment15                  => p_segment15
     ,p_segment16                  => p_segment16
     ,p_segment17                  => p_segment17
     ,p_segment18                  => p_segment18
     ,p_segment19                  => p_segment19
     ,p_segment20                  => p_segment20
     ,p_segment21                  => p_segment21
     ,p_segment22                  => p_segment22
     ,p_segment23                  => p_segment23
     ,p_segment24                  => p_segment24
     ,p_segment25                  => p_segment25
     ,p_segment26                  => p_segment26
     ,p_segment27                  => p_segment27
     ,p_segment28                  => p_segment28
     ,p_segment29                  => p_segment29
     ,p_segment30                  => p_segment30
     ,p_concat_segments		   => p_concat_segments
     );
    /*
    hr_position_api.create_position
     (p_validate                   => FALSE
     ,p_job_id                     => p_job_id
     ,p_organization_id            => p_organization_id
     ,p_date_effective             => p_date_effective
     ,p_successor_position_id      => l_successor_position_id
     ,p_relief_position_id         => l_relief_position_id
     ,p_location_id                => p_location_id
     ,p_comments                   => l_comments
     ,p_frequency                  => p_frequency
     ,p_probation_period           => l_probation_period
     ,p_probation_period_units     => l_probation_period_units
     ,p_replacement_required_flag  => l_replacement_required_flag
     ,p_time_normal_finish         => p_time_normal_finish
     ,p_time_normal_start          => p_time_normal_start
     ,p_working_hours              => p_normal_hours
     ,p_attribute_category         => l_attribute_category
     ,p_attribute1                 => l_attribute1
     ,p_attribute2                 => l_attribute2
     ,p_attribute3                 => l_attribute3
     ,p_attribute4                 => l_attribute4
     ,p_attribute5                 => l_attribute5
     ,p_attribute6                 => l_attribute6
     ,p_attribute7                 => l_attribute7
     ,p_attribute8                 => l_attribute8
     ,p_attribute9                 => l_attribute9
     ,p_attribute10                => l_attribute10
     ,p_attribute11                => l_attribute11
     ,p_attribute12                => l_attribute12
     ,p_attribute13                => l_attribute13
     ,p_attribute14                => l_attribute14
     ,p_attribute15                => l_attribute15
     ,p_attribute16                => l_attribute16
     ,p_attribute17                => l_attribute17
     ,p_attribute18                => l_attribute18
     ,p_attribute19                => l_attribute19
     ,p_attribute20                => l_attribute20
     ,p_segment1                   => p_segment1
     ,p_segment2                   => p_segment2
     ,p_segment3                   => p_segment3
     ,p_segment4                   => p_segment4
     ,p_segment5                   => p_segment5
     ,p_segment6                   => p_segment6
     ,p_segment7                   => p_segment7
     ,p_segment8                   => p_segment8
     ,p_segment9                   => p_segment9
     ,p_segment10                  => p_segment10
     ,p_segment11                  => p_segment11
     ,p_segment12                  => p_segment12
     ,p_segment13                  => p_segment13
     ,p_segment14                  => p_segment14
     ,p_segment15                  => p_segment15
     ,p_segment16                  => p_segment16
     ,p_segment17                  => p_segment17
     ,p_segment18                  => p_segment18
     ,p_segment19                  => p_segment19
     ,p_segment20                  => p_segment20
     ,p_segment21                  => p_segment21
     ,p_segment22                  => p_segment22
     ,p_segment23                  => p_segment23
     ,p_segment24                  => p_segment24
     ,p_segment25                  => p_segment25
     ,p_segment26                  => p_segment26
     ,p_segment27                  => p_segment27
     ,p_segment28                  => p_segment28
     ,p_segment29                  => p_segment29
     ,p_segment30                  => p_segment30
     ,p_position_id                => l_new_position_id
     ,p_object_version_number      => l_new_object_version_number
     ,p_position_definition_id     => l_position_definition_id
     ,p_name                       => l_name
     );
     */
    --
    l_new_position_date_end := null;
    l_new_job_id := p_job_id;
  end if;

  --
  --  Create job requirements for the 'new' position based on the
  --  job requirements from the 'old' position.  If the 'new' position
  --  already existed, only create job requirements from the old position
  --  that the 'new' position doesn't already have defined.
  --
  hr_utility.set_location(l_proc, 90);
  --
  for csr_jbr_rec in csr_jbr loop
    --
    -- fixed error in call: changed call from
    -- hr_position_requirements_api.create_position_requirements to
    -- hr_position_requirement_api.create_position_requirement
    -- Rod Fine 24-Jul-96.
    --
    hr_position_requirement_api.create_position_requirement
     (p_validate               => FALSE
     ,p_id_flex_num            => csr_jbr_rec.id_flex_num
     ,p_position_id            => l_new_position_id
     ,p_comments               => csr_jbr_rec.comments
     ,p_essential              => csr_jbr_rec.essential
     ,p_attribute_category     => csr_jbr_rec.attribute_category
     ,p_attribute1             => csr_jbr_rec.attribute1
     ,p_attribute2             => csr_jbr_rec.attribute2
     ,p_attribute3             => csr_jbr_rec.attribute3
     ,p_attribute4             => csr_jbr_rec.attribute4
     ,p_attribute5             => csr_jbr_rec.attribute5
     ,p_attribute6             => csr_jbr_rec.attribute6
     ,p_attribute7             => csr_jbr_rec.attribute7
     ,p_attribute8             => csr_jbr_rec.attribute8
     ,p_attribute9             => csr_jbr_rec.attribute9
     ,p_attribute10            => csr_jbr_rec.attribute10
     ,p_attribute11            => csr_jbr_rec.attribute11
     ,p_attribute12            => csr_jbr_rec.attribute12
     ,p_attribute13            => csr_jbr_rec.attribute13
     ,p_attribute14            => csr_jbr_rec.attribute14
     ,p_attribute15            => csr_jbr_rec.attribute15
     ,p_attribute16            => csr_jbr_rec.attribute16
     ,p_attribute17            => csr_jbr_rec.attribute17
     ,p_attribute18            => csr_jbr_rec.attribute18
     ,p_attribute19            => csr_jbr_rec.attribute19
     ,p_attribute20            => csr_jbr_rec.attribute20
     ,p_segment1               => csr_jbr_rec.segment1
     ,p_segment2               => csr_jbr_rec.segment2
     ,p_segment3               => csr_jbr_rec.segment3
     ,p_segment4               => csr_jbr_rec.segment4
     ,p_segment5               => csr_jbr_rec.segment5
     ,p_segment6               => csr_jbr_rec.segment6
     ,p_segment7               => csr_jbr_rec.segment7
     ,p_segment8               => csr_jbr_rec.segment8
     ,p_segment9               => csr_jbr_rec.segment9
     ,p_segment10              => csr_jbr_rec.segment10
     ,p_segment11              => csr_jbr_rec.segment11
     ,p_segment12              => csr_jbr_rec.segment12
     ,p_segment13              => csr_jbr_rec.segment13
     ,p_segment14              => csr_jbr_rec.segment14
     ,p_segment15              => csr_jbr_rec.segment15
     ,p_segment16              => csr_jbr_rec.segment16
     ,p_segment17              => csr_jbr_rec.segment17
     ,p_segment18              => csr_jbr_rec.segment18
     ,p_segment19              => csr_jbr_rec.segment19
     ,p_segment20              => csr_jbr_rec.segment20
     ,p_segment21              => csr_jbr_rec.segment21
     ,p_segment22              => csr_jbr_rec.segment22
     ,p_segment23              => csr_jbr_rec.segment23
     ,p_segment24              => csr_jbr_rec.segment24
     ,p_segment25              => csr_jbr_rec.segment25
     ,p_segment26              => csr_jbr_rec.segment26
     ,p_segment27              => csr_jbr_rec.segment27
     ,p_segment28              => csr_jbr_rec.segment28
     ,p_segment29              => csr_jbr_rec.segment29
     ,p_segment30              => csr_jbr_rec.segment30
     ,p_job_requirement_id     => l_job_requirement_id
     ,p_object_version_number  => l_jbr_object_version_number
     ,p_analysis_criteria_id   => l_analysis_criteria_id
     );
  end loop;
  --
  -- For each valid grade that is in mm valid grades but not in per
  -- valid grades will be inserted into per valid grades.
  --
  for csr_vgr_rec in csr_vgr loop
    --
    hr_utility.set_location(l_proc, 100);
    --
    hr_valid_grade_api.create_valid_grade
      (p_grade_id               => csr_vgr_rec.target_grade_id
      ,p_date_from              => p_date_effective
      ,p_effective_date	        => p_date_effective  --Added for Bug# 1760707
      ,p_position_id            => l_new_position_id
      ,p_attribute_category     => csr_vgr_rec.attribute_category
      ,p_attribute1             => csr_vgr_rec.attribute1
      ,p_attribute2             => csr_vgr_rec.attribute2
      ,p_attribute3             => csr_vgr_rec.attribute3
      ,p_attribute4             => csr_vgr_rec.attribute4
      ,p_attribute5             => csr_vgr_rec.attribute5
      ,p_attribute6             => csr_vgr_rec.attribute6
      ,p_attribute7             => csr_vgr_rec.attribute7
      ,p_attribute8             => csr_vgr_rec.attribute8
      ,p_attribute9             => csr_vgr_rec.attribute9
      ,p_attribute10            => csr_vgr_rec.attribute10
      ,p_attribute11            => csr_vgr_rec.attribute11
      ,p_attribute12            => csr_vgr_rec.attribute12
      ,p_attribute13            => csr_vgr_rec.attribute13
      ,p_attribute14            => csr_vgr_rec.attribute14
      ,p_attribute15            => csr_vgr_rec.attribute15
      ,p_attribute16            => csr_vgr_rec.attribute16
      ,p_attribute17            => csr_vgr_rec.attribute17
      ,p_attribute18            => csr_vgr_rec.attribute18
      ,p_attribute19            => csr_vgr_rec.attribute19
      ,p_attribute20            => csr_vgr_rec.attribute20
      ,p_valid_grade_id         => l_valid_grade_id
      ,p_object_version_number  => l_vgr_object_version_number
      );
  end loop;
  --
  --  If deactivate_old_position is true then close down the 'old'
  --  position
  --
  hr_utility.set_location(l_proc, 110);
  --
  -- If the old position is to be deactivated then
  -- determine the availability status
  --
  if p_deactivate_old_position then
    --
    hr_utility.set_location(l_proc, 120);
    --
    l_date_end := p_date_effective - 1;
    --
    -- Added as part of fix for bug 2943725
    --
    --
    -- Get the current availability status of the position
    --
    open  csr_current_status;
    fetch csr_current_status into l_current_system_type_cd;
    close csr_current_status;
    --
    hr_utility.set_location(l_proc||'/'||l_current_system_type_cd, 130);
    hr_utility.set_location(l_proc||'/'||p_position_id, 131);
    hr_utility.set_location(l_proc||'/'||p_date_effective, 132);
    --
    -- If the status is Active then change the status to Eliminated
    --
    if l_current_system_type_cd = 'ACTIVE' then
      --
      hr_utility.set_location(l_proc, 140);
      --
      l_system_type_cd := 'ELIMINATED';
    --
    -- Else if the status is Proposed then the status will
    -- become Deleted.
    --
    elsif l_current_system_type_cd = 'PROPOSED' then
      --
      hr_utility.set_location(l_proc, 150);
      --
      l_system_type_cd := 'DELETED';
      --
    end if;
    --
    -- Get the appropriate avialability status
    --
    open  csr_avail_status(p_system_type_cd => l_system_type_cd);
    fetch csr_avail_status into p_availability_status_id;
    close csr_avail_status;
    --
    hr_utility.set_location(l_proc||'/'||l_system_type_cd, 160);
    --
    -- End of fix for bug 2943725
    --
    l_pos_dt_mode := 'UPDATE';
    --
    open csr_pos_current_esd(p_position_id , p_date_effective);
    fetch csr_pos_current_esd into l_pos_dt_mode;
    close csr_pos_current_esd;
    --
    hr_position_api.update_position
      (p_position_id                  => p_position_id
      ,p_object_version_number        => l_object_version_number
      ,p_effective_start_date           =>l_effective_start_date
      ,p_effective_end_date             =>l_effective_end_date
      --,p_date_end                     => l_date_end
      ,p_position_definition_id       => l_old_position_def
      ,p_name                         => l_old_name
      ,p_valid_grades_changed_warning => l_valid_grades_changed_warning
      ,p_availability_status_id         => p_availability_status_id
      ,p_effective_date                 => p_date_effective      --p_effective_date
      ,p_datetrack_mode                 => l_pos_dt_mode
      );
    /*
    hr_position_api.update_position
      (p_position_id                  => p_position_id
      ,p_object_version_number        => l_object_version_number
      ,p_date_end                     => l_date_end
      ,p_position_definition_id       => l_old_position_def
      ,p_name                         => l_old_name
      ,p_valid_grades_changed_warning => l_valid_grades_changed_warning
      );
    */
    --
    hr_utility.set_location(l_proc, 170);
    --
  end if;
  --
  --  This is customer specific processing
  --
  hr_mass_move_cus.post_move_position
   (p_validate                  => FALSE
   ,p_position_id               => p_position_id
   ,p_object_version_number     => l_object_version_number
   ,p_date_effective            => p_date_effective
   ,p_business_group_id         => l_business_group_id
   ,p_organization_id           => p_organization_id
   ,p_deactivate_old_position   => p_deactivate_old_position
   ,p_mass_move_id              => p_mass_move_id
   ,p_new_position_id           => l_new_position_id
   ,p_new_object_version_number => l_new_object_version_number
   );
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  --  Set all out arguments
  --
  p_object_version_number        := l_object_version_number;
  p_new_position_id              := l_new_position_id;
  p_new_job_id                   := l_new_job_id;
  p_new_object_version_number    := l_new_object_version_number;
  p_valid_grades_changed_warning := l_valid_grades_changed_warning;
  p_pos_exists_warning           := l_pos_exists_warning;
  p_pos_date_range_warning       := l_pos_date_range_warning;
  p_pos_pending_close_warning    := l_pos_pending_close_warning;
  p_pos_jbe_not_moved_warning    := l_pos_jbe_not_moved_warning;
  p_pos_vac_not_moved_warning    := l_pos_vac_not_moved_warning;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 997);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    --
       ROLLBACK TO move_position;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number        := p_object_version_number;
    p_new_position_id              := null;
    p_new_job_id                   := null;
    p_new_object_version_number    := null;
    p_valid_grades_changed_warning := l_valid_grades_changed_warning;
    p_pos_exists_warning           := l_pos_exists_warning;
    p_pos_date_range_warning       := l_pos_date_range_warning;
    p_pos_pending_close_warning    := l_pos_pending_close_warning;
    p_pos_jbe_not_moved_warning    := l_pos_jbe_not_moved_warning;
    p_pos_vac_not_moved_warning    := l_pos_vac_not_moved_warning;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 998);
    --
  when others then
    --
    hr_utility.set_location(' Leaving:'||l_proc, 999);
    --
    --  if it is an business rule violation error then only rollback
    --  this positon record.
    --
    if sqlcode = -20001 then
      --
      rollback to move_position;
      --
      hr_batch_message_line_api.create_message_line
          (p_validate               => FALSE
          ,p_batch_run_number       => p_batch_run_number
          ,p_api_name               => 'hr_mass_move_api.mass_move'
          ,p_status                 => 'S'
          ,p_error_number           => sqlcode
          ,p_error_message          => sqlerrm
          ,p_extended_error_message => fnd_message.get
          ,p_source_row_information => l_name
          ,p_line_id                => l_dummy_line_id);
      --
      -- set in out parameters and set out parameters
      --
      p_object_version_number        := l_ovn;
      p_new_position_id              := null;
      p_new_job_id                   := null;
      p_new_object_version_number    := null;
      p_valid_grades_changed_warning := false;
      p_pos_exists_warning           := false;
      p_pos_date_range_warning       := false;
      p_pos_pending_close_warning    := false;
      p_pos_jbe_not_moved_warning    := false;
      p_pos_vac_not_moved_warning    := false;
      --
    else
      --
      raise;
      --
    end if;
  --
end move_position;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< move_assignments >----------------------------|
-- ----------------------------------------------------------------------------
procedure move_assignments
  (p_validate                      in     boolean  default false
  ,p_mass_move_id                  in     number
  ,p_old_position_id               in     number
  ,p_new_position_id		     in     number
  ,p_new_job_id                    in     number
  ,p_effective_date                in     date
  ,p_new_organization_id           in     number
  ,p_pos_time_normal_start         in     varchar2
  ,p_pos_time_normal_finish        in     varchar2
  ,p_pos_normal_hours              in     number
  ,p_pos_frequency                 in     varchar2
  ,p_pos_location_id               in     number
  ,p_org_time_normal_start         in     varchar2
  ,p_org_time_normal_finish        in     varchar2
  ,p_org_normal_hours              in     number
  ,p_org_frequency                 in     varchar2
  ,p_org_location_id               in     number
  ,p_legislation_code              in     varchar2
  ,p_bg_time_normal_start          in     varchar2
  ,p_bg_time_normal_finish         in     varchar2
  ,p_bg_normal_hours               in     number
  ,p_bg_frequency                  in     varchar2
  ,p_bg_location_id                in    number
  ,p_batch_run_number              in    number
  )
  is
  --
  l_proc                        varchar2(72) := g_package||'move_assignments';
  l_vacancies_exist             varchar2(1);
  l_apl_asg_new_ovn             number;
  l_out_comment_id              number;
  l_out_people_group_id         number;
  l_new_job_id                  number;
  l_out_group_name              varchar2(240);
-- Added new dummy var
-- Bug 944911
  l_out_concatenated_segments   varchar2(240);
  l_out_soft_coding_keyflx_id   number;
  l_out_effective_start_date    date;
  l_out_effective_end_date      date;
  l_apl_asg_pos_vacancy_warning boolean;
  l_org_now_no_manager_warning  boolean;
  l_other_manager_warning       boolean;
  l_soft_coding_keyflex_id      number(15);
  l_entries_changed_warning     varchar2(1);
  l_time_normal_start           varchar2(150);
  l_time_normal_finish          varchar2(150);
  l_normal_hours                number(22,3);
  l_frequency                   varchar2(1);
  l_location_id                 number(15);
  l_mm_assignment_id            number(15);
  l_effective_start_date	  date;
  l_effective_end_date  	  date;
  l_concatenated_segments       hr_soft_coding_keyflex.concatenated_segments%TYPE;
  l_batch_run_number            number(15);
  l_dummy_line_id               number(15);
  l_segment1                    varchar2(150);
  l_cagr_concatenated_segments  varchar2(240);
  l_cagr_grade_def_id           number(15);
  asg_vacancy_warning           exception;
  future_asg_warning            exception;
  l_exists                      varchar2(1);
  --
  -- Out Parameters for CWK Assignments
  --
  l_people_group_name                VARCHAR2(240);
  l_people_group_id                  NUMBER;
  --l_org_now_no_manager_warning       BOOLEAN;
  --l_other_manager_warning            BOOLEAN;
  l_spp_delete_warning               BOOLEAN;
  --l_entries_changed_warning          VARCHAR2(1);
  l_tax_district_changed_warning     BOOLEAN;
  --
  cursor csr_future_asg_changes is
    select null
    from   per_assignments_f asg,
           per_mass_moves mm,
           per_mm_assignments mmasg
    where  mmasg.assignment_id = l_mm_assignment_id
    and    asg.assignment_id = mmasg.assignment_id
    and    mmasg.mass_move_id = p_mass_move_id
    and    mmasg.mass_move_id = mm.mass_move_id
    and    mmasg.position_id = p_old_position_id
    and    asg.effective_start_date > p_effective_date;
  --
  cursor csr_get_mm_asg is
    select mm_asg.assignment_id,
           mm_asg.default_from,
           mm_asg.grade_id,
           mm_asg.tax_unit_id,
           asg.location_id,
           asg.frequency,
           asg.normal_hours,
           asg.time_normal_start,
           asg.time_normal_finish,
           asg.assignment_type,
           asg.object_version_number,
           asg.vacancy_id,
           per.full_name,
           org.name orgname,
           neworg.name neworgname
       from per_mm_assignments mm_asg,
           per_assignments_f asg,
           per_people_f per,
           per_organization_units org,
           per_mass_moves mm,
           per_organization_units neworg
       where mm_asg.position_id = p_old_position_id
       and mm_asg.assignment_id = asg.assignment_id
       and mm_asg.mass_move_id = p_mass_move_id
       and mm_asg.mass_move_id = mm.mass_move_id
       and mm.new_organization_id = neworg.organization_id
       and asg.organization_id = org.organization_id
       and p_effective_date between asg.effective_start_date
                                and asg.effective_end_date
       and p_effective_date between per.effective_start_date
                                and per.effective_end_date
       and asg.person_id = per.person_id
       and assignment_moved = 'N'
       and select_assignment = 'Y';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint move_assignment;
  --
  --
  for mmasgrec in csr_get_mm_asg loop
    --
    begin
    --
    savepoint move_asg;
    --
    hr_utility.set_location(l_proc||'/'||mmasgrec.assignment_id, 20);
    --
    --  GRE/Legal Entity will only move for US legislation.
    --
    if p_legislation_code = 'US' then
      --
      l_segment1 := to_char(mmasgrec.tax_unit_id);
      --
    else
      --
      l_segment1 := hr_api.g_varchar2;
      --
    end if;
    --
    if mmasgrec.default_from = 'B' then
      --
      hr_utility.set_location(l_proc, 30);
      --
      l_location_id         := p_bg_location_id;
      l_frequency	          := p_bg_frequency;
      l_normal_hours	       := p_bg_normal_hours;
      l_time_normal_finish  := p_bg_time_normal_finish;
      l_time_normal_start   := p_bg_time_normal_start;
      --
    elsif mmasgrec.default_from = 'O' then
      --
      hr_utility.set_location(l_proc, 40);
      --
      l_location_id         := p_org_location_id;
      l_frequency	          := p_org_frequency;
      l_normal_hours	       := p_org_normal_hours;
      l_time_normal_finish  := p_org_time_normal_finish;
      l_time_normal_start   := p_org_time_normal_start;
      --
    elsif mmasgrec.default_from = 'P' then
      --
      hr_utility.set_location(l_proc, 50);
      --
      l_location_id         := p_pos_location_id;
      l_frequency	          := p_pos_frequency;
      l_normal_hours	       := p_pos_normal_hours;
      l_time_normal_finish  := p_pos_time_normal_finish;
      l_time_normal_start   := p_pos_time_normal_start;
      --
    elsif mmasgrec.default_from = 'A' then
      --
      hr_utility.set_location(l_proc, 60);
      --
      l_location_id         := mmasgrec.location_id;
      l_frequency	          := mmasgrec.frequency;
      l_normal_hours	       := mmasgrec.normal_hours;
      l_time_normal_finish  := mmasgrec.time_normal_finish;
      l_time_normal_start   := mmasgrec.time_normal_start;
      --
    end if;
    --
    if mmasgrec.vacancy_id is not null then
      --
      hr_utility.set_location(l_proc, 70);
      --
      raise asg_vacancy_warning;
      --
    end if;
    --
    open  csr_future_asg_changes;
    fetch csr_future_asg_changes into l_exists;
    --
    l_mm_assignment_id := mmasgrec.assignment_id;
    --
    if csr_future_asg_changes%found then
      --
      hr_utility.set_location(l_proc, 80);
      close csr_future_asg_changes;
      raise future_asg_warning;
      --
    end if;
    --
    close csr_future_asg_changes;
    --
    if mmasgrec.assignment_type = 'A' then
      --
      hr_utility.set_location(l_proc, 90);
      --
      hr_assignment_api.update_apl_asg
        (p_validate                   => FALSE
        ,p_effective_date             => p_effective_date
        ,p_datetrack_update_mode      => 'UPDATE'
        ,p_assignment_id              => mmasgrec.assignment_id
        ,p_object_version_number      => mmasgrec.object_version_number
        ,p_grade_id                   => mmasgrec.grade_id
        ,p_position_id	               => p_new_position_id
        ,p_job_id                     => p_new_job_id
        ,p_organization_id            => p_new_organization_id
        ,p_location_id	               => l_location_id
        ,p_frequency	                 => l_frequency
        ,p_normal_hours	              => l_normal_hours
        ,p_time_normal_finish         => l_time_normal_finish
        ,p_time_normal_start          => l_time_normal_start
        ,p_comment_id                 => l_out_comment_id
        ,p_people_group_id            => l_out_people_group_id
        ,p_group_name                 => l_out_group_name
        ,p_effective_start_date       => l_out_effective_start_date
        ,p_cagr_concatenated_segments => l_cagr_concatenated_segments
        ,p_cagr_grade_def_id          => l_cagr_grade_def_id
         --
         -- Bug 944911 Added out param into a dummy var
         --
       	,p_concatenated_segments      => l_out_concatenated_segments
        ,p_soft_coding_keyflex_id     => l_out_soft_coding_keyflx_id
        ,p_effective_end_date         => l_out_effective_end_date);
    --
    -- Assignment is for a Contingent Worker
    --
    elsif mmasgrec.assignment_type = 'C' then
      --
      hr_utility.set_location(l_proc, 95);
      --
      hr_mass_move_api.move_cwk_asg
        (p_validate                     => p_validate
        ,p_effective_date               => p_effective_date
        ,p_datetrack_update_mode        => 'UPDATE'
        ,p_assignment_id                => mmasgrec.assignment_id
        ,p_object_version_number        => mmasgrec.object_version_number
        ,p_grade_id                     => mmasgrec.grade_id
        ,p_position_id                  => p_new_position_id
        ,p_job_id                       => p_new_job_id
        ,p_location_id                  => l_location_id
        ,p_organization_id              => p_new_organization_id
        ,p_people_group_name            => l_people_group_name
        ,p_effective_start_date         => l_effective_start_date
        ,p_effective_end_date           => l_effective_end_date
        ,p_people_group_id              => l_people_group_id
        ,p_org_now_no_manager_warning   => l_org_now_no_manager_warning
        ,p_other_manager_warning        => l_other_manager_warning
        ,p_spp_delete_warning           => l_spp_delete_warning
        ,p_entries_changed_warning      => l_entries_changed_warning
        ,p_tax_district_changed_warning => l_tax_district_changed_warning);
      --
    else  -- assignment_type = 'E'
      --
      hr_utility.set_location(l_proc, 100);
      --
      hr_mass_move_api.move_emp_asg
        (p_validate                   => FALSE
        ,p_mass_move_id	              => p_mass_move_id
        ,p_effective_date             => p_effective_date
        ,p_assignment_id              => mmasgrec.assignment_id
        ,p_object_version_number      => mmasgrec.object_version_number
        ,p_grade_id                   => mmasgrec.grade_id
        ,p_position_id                => p_new_position_id
        ,p_job_id                     => p_new_job_id
        ,p_organization_id	           => p_new_organization_id
        ,p_location_id	               => l_location_id
        ,p_frequency	                 => l_frequency
        ,p_normal_hours	              => l_normal_hours
        ,p_time_normal_finish         => l_time_normal_finish
        ,p_time_normal_start          => l_time_normal_start
        ,p_segment1                   => l_segment1
        ,p_soft_coding_keyflex_id     => l_soft_coding_keyflex_id     --out
        ,p_effective_start_date       => l_effective_start_date       --out
        ,p_effective_end_date	        => l_effective_end_date         --out
        ,p_concatenated_segments      => l_concatenated_segments      --out
        ,p_org_now_no_manager_warning => l_org_now_no_manager_warning --out
        ,p_other_manager_warning      => l_other_manager_warning      --out
        ,p_entries_changed_warning    => l_entries_changed_warning    --out
        ,p_spp_delete_warning         => l_spp_delete_warning);       --out
      --
    end if; /* if assignment type = 'E' */
    --
    if l_spp_delete_warning then
      --
      hr_utility.set_message(800,'HR_289826_SPP_DELETE_WARN_API');
      --
      hr_batch_message_line_api.create_message_line
          (p_validate               => FALSE
          ,p_batch_run_number       => p_batch_run_number
          ,p_api_name               => 'hr_mass_move_api.move_emp_asg'
          ,p_status                 => 'S'
          ,p_error_number           => '289286'
          ,p_error_message          => hr_utility.get_message
          ,p_extended_error_message => fnd_message.get
          ,p_source_row_information => mmasgrec.full_name
          ,p_line_id                => l_dummy_line_id);
       --
    end if;
    --
    if l_org_now_no_manager_warning then
      --
      hr_utility.set_message(801,'HR_51124_MMV_NO_MGR_EXIST_ORG');
      --
      hr_batch_message_line_api.create_message_line
          (p_validate               => FALSE
          ,p_batch_run_number       => p_batch_run_number
          ,p_api_name               => 'hr_mass_move_api.move_emp_asg'
          ,p_status                 => 'S'
          ,p_error_number           => '51124'
          ,p_error_message          => hr_utility.get_message
          ,p_extended_error_message => fnd_message.get
          ,p_source_row_information => mmasgrec.full_name
          ,p_line_id                => l_dummy_line_id);
      --
    end if;
    --
    if l_other_manager_warning then
      --
      hr_utility.set_message(801,'HR_51125_MMV_MRE_MGR_EXIST_ORG');
      --
      hr_batch_message_line_api.create_message_line
          (p_validate               => FALSE
          ,p_batch_run_number       => p_batch_run_number
          ,p_api_name               => 'hr_mass_move_api.move_emp_asg'
          ,p_status                 => 'S'
          ,p_error_number           => '51125'
          ,p_error_message          => hr_utility.get_message
          ,p_extended_error_message => fnd_message.get
          ,p_source_row_information => mmasgrec.full_name
          ,p_line_id                => l_dummy_line_id);
       --
    end if;
    --
    if l_entries_changed_warning = 'S' then
      --
      hr_utility.set_message(801,'HR_51126_MMV_SAL_ENT_ALTERED');
      --
      hr_batch_message_line_api.create_message_line
          (p_validate               => FALSE
          ,p_batch_run_number       => p_batch_run_number
          ,p_api_name               => 'hr_mass_move_api.move_emp_asg'
          ,p_status                 => 'S'
          ,p_error_number           => '51126'
          ,p_error_message          => hr_utility.get_message
          ,p_extended_error_message => fnd_message.get
          ,p_source_row_information => mmasgrec.full_name
          ,p_line_id                => l_dummy_line_id);
      --
    end if;
    --
    if l_entries_changed_warning = 'Y' then
      --
      hr_utility.set_message(801,'HR_51127_MMV_NON_SAL_ENT_ALR');
      --
      hr_batch_message_line_api.create_message_line
          (p_validate               => FALSE
          ,p_batch_run_number       => p_batch_run_number
          ,p_api_name               => 'hr_mass_move_api.move_emp_asg'
          ,p_status                 => 'S'
          ,p_error_number           => '51127'
          ,p_error_message          => hr_utility.get_message
          ,p_extended_error_message => fnd_message.get
          ,p_source_row_information => mmasgrec.full_name
          ,p_line_id                => l_dummy_line_id);
       --
    end if;
    --
    hr_utility.set_location(l_proc, 110);
    --
    --
    -- if it has made it this far, the applicant/employee assignment was moved
    --
    update per_mm_assignments
    set    assignment_moved = 'Y'
    where  assignment_id = mmasgrec.assignment_id
    and    mass_move_id = p_mass_move_id;
    --
    exception
    when asg_vacancy_warning then
      --
      rollback to move_asg;
      --
      hr_utility.set_message(801,'HR_51129_MMV_ASG_NOT_MOVED');
      --
      hr_batch_message_line_api.create_message_line
          (p_validate               => FALSE
          ,p_batch_run_number       => p_batch_run_number
          ,p_api_name               => 'hr_mass_move_api.move_assignment'
          ,p_status                 => 'S'
          ,p_error_number           => '51129'
          ,p_error_message          => hr_utility.get_message
          ,p_extended_error_message => fnd_message.get
          ,p_source_row_information => mmasgrec.full_name
          ,p_line_id                => l_dummy_line_id);
    --
    when future_asg_warning then
      --
      rollback to move_asg;
      --
      hr_utility.set_message(801,'HR_51103_MMV_ASG_FUTURE_CHG');
      --
      hr_batch_message_line_api.create_message_line
          (p_validate               => FALSE
          ,p_batch_run_number       => p_batch_run_number
          ,p_api_name               => 'hr_mass_move_api.move_assignment'
          ,p_status                 => 'S'
          ,p_error_number           => '51103'
          ,p_error_message          => hr_utility.get_message
          ,p_extended_error_message => fnd_message.get
          ,p_source_row_information => mmasgrec.full_name
          ,p_line_id                => l_dummy_line_id);
    --
    when others then
      --
      hr_utility.set_location(l_proc, 120);
      --
      if sqlcode = -20001 then
        --
        rollback to move_asg;
        --
        hr_batch_message_line_api.create_message_line
          (p_validate               => FALSE
          ,p_batch_run_number       => p_batch_run_number
          ,p_api_name               => 'hr_mass_move_api.mass_move'
          ,p_status                 => 'S'
          ,p_error_number           => sqlcode
          ,p_error_message          => sqlerrm
          ,p_extended_error_message => fnd_message.get
          ,p_source_row_information => mmasgrec.full_name
          ,p_line_id                => l_dummy_line_id);
        --
      else
        --
        raise;
        --
      end if;
    --
    end;  --begin
    --
  end loop; -- for mmasgrec in cursor
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 997);
  --
  exception
    --
    when hr_api.validate_enabled then
      --
      -- As the Validate_Enabled exception has been raised
      -- we must rollback to the savepoint
      --
      ROLLBACK TO move_assignment;
      --
      hr_utility.set_location(' Leaving:'||l_proc, 998);
      --
    when others then
      --
      -- A validation or unexpected error has occurred
      --
      -- Added as part of the fix to bug 632479
      --
      ROLLBACK TO move_assignment;
      --
      hr_utility.set_location(' Leaving:'||l_proc, 999);
      --
      raise;
      --
end move_assignments;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< mass_move >-------------------------------|
-- ----------------------------------------------------------------------------
--
procedure mass_move
  ( p_validate             in         boolean default false,
    p_mass_move_id         in         number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                              varchar2(72) := g_package||'mass_move ';
  l_api_updatin                       boolean;
  l_new_organization_id               number(15);
  l_effective_date                    date;
  l_business_group_id                 number(15);
  l_time_normal_start                 varchar2(150);
  l_time_normal_finish                varchar2(150);
  l_normal_hours                      number(22,3);
  l_frequency                         varchar2(1);
  l_location_id                       number(15);
  l_org_time_normal_start             varchar2(150);
  l_org_time_normal_finish            varchar2(150);
  l_org_normal_hours                  number(22,3);
  l_org_frequency                     varchar2(30);
  l_org_location_id                   number(15);
  l_legislation_code                  varchar2(150);
  l_bg_time_normal_start              varchar2(150);
  l_bg_time_normal_finish             varchar2(150);
  l_bg_normal_hours                   number(22,3);
  l_bg_frequency                      varchar2(30);
  l_bg_location_id                    number(15);
  l_new_pos_time_normal_start         varchar2(150);
  l_new_pos_time_normal_finish        varchar2(150);
  l_new_pos_normal_hours              number(22,3);
  l_new_pos_frequency                 varchar2(30);
  l_new_pos_location_id               number(15);
  l_old_pos_time_normal_start         varchar2(150);
  l_old_pos_time_normal_finish        varchar2(150);
  l_old_pos_normal_hours              number(22,3);
  l_old_pos_frequency                 varchar2(30);
  l_old_pos_location_id               number(15);
  l_deactivate_boolean                boolean;
  l_new_position_id                   number(15);
  l_new_job_id                        number(15);
  l_new_pos_ovn                       number(15);
  l_batch_run_number                  number(15);
  l_dummy_line_id                     number(15);
  l_apl_asg_updated_warning           boolean;
  l_apl_asg_pos_vacancy_warning       boolean;
  l_errors_exist                      varchar2(1);
  l_warnings_exist                    varchar2(1);
  l_valid_grade_id                    number(15);
  l_object_version_number             number(15);
  l_position_name                     varchar2(240);
  l_position_id                       number(15);
  l_valid_grades_changed_warning      boolean;
  l_pos_exists_warning                boolean;
  l_pos_date_range_warning            boolean;
  l_pos_pending_close_warning         boolean;
  l_pos_jbe_not_moved_warning         boolean;
  l_pos_vac_not_moved_warning         boolean;

  --
  cursor csr_batch_run_number is
    select hr_api_batch_message_lines_s.nextval
        from dual;
  --
  cursor csr_lock_per_mass_moves is
  select null
  from   per_mass_moves
  where  mass_move_id = p_mass_move_id
  for    update nowait;
  --
  cursor csr_lock_per_mm_positions is
  select null
  from   per_mm_positions
  where  mass_move_id = p_mass_move_id
  for    update nowait;
  --
  cursor csr_lock_per_mm_assignments is
  select null
  from   per_mm_assignments
  where  mass_move_id = p_mass_move_id
  for    update nowait;
  --
  cursor csr_lock_per_mm_valid_grades is
  select null
  from   per_mm_valid_grades
  where  mass_move_id = p_mass_move_id
  for    update nowait;
  --
  cursor csr_lock_per_mm_job_reqts is
  select null
  from   per_mm_job_requirements
  where  mass_move_id = p_mass_move_id
  for    update nowait;
  --
  cursor csr_get_mass_move_info is
  select new_organization_id,
         effective_date
    from per_mass_moves
   where mass_move_id = p_mass_move_id;
  --
  cursor csr_get_org_defaults is
    select business_group_id,
           default_start_time,
           default_end_time,
           fnd_number.canonical_to_number(working_hours),
           frequency,
           location_id
    from   per_organization_units
    where  organization_id = l_new_organization_id;
  --
  cursor csr_get_busgrp_defaults is
    select legislation_code,
           default_start_time,
           default_end_time,
           fnd_number.canonical_to_number(working_hours),
           frequency,
           location_id
    from   per_business_groups
    where  business_group_id = l_business_group_id;
  --
  cursor csr_get_old_pos_defaults is
    select pos.time_normal_start,
           pos.time_normal_finish,
           fnd_number.canonical_to_number(pos.working_hours),
           pos.frequency,
           pos.location_id
    from   hr_positions_f pos
    where  position_id = l_position_id
    and l_effective_date
    between effective_start_date
    and effective_end_date;
  --
  cursor csr_get_new_pos_defaults is
    select pos.time_normal_start,
           pos.time_normal_finish,
           fnd_number.canonical_to_number(pos.working_hours),
           pos.frequency,
           pos.location_id
    from   hr_positions_f pos
    where  position_id = l_new_position_id
    and l_effective_date
    between effective_start_date
    and effective_end_date;
  --
  cursor csr_get_mm_valid_grades is
    select mmvgr.position_id,
           mmvgr.target_grade_id,
           mmvgr.attribute_category,
           mmvgr.attribute1,
           mmvgr.attribute2,
           mmvgr.attribute3,
           mmvgr.attribute4,
           mmvgr.attribute5,
           mmvgr.attribute6,
           mmvgr.attribute7,
           mmvgr.attribute8,
           mmvgr.attribute9,
           mmvgr.attribute10,
           mmvgr.attribute11,
           mmvgr.attribute12,
           mmvgr.attribute13,
           mmvgr.attribute14,
           mmvgr.attribute15,
           mmvgr.attribute16,
           mmvgr.attribute17,
           mmvgr.attribute18,
           mmvgr.attribute19,
           mmvgr.attribute20
      from per_mm_valid_grades mmvgr
     where mmvgr.mass_move_id = p_mass_move_id;

 --
  cursor csr_get_mm_positions is
    select pos.name,
           mmpos.position_id,
           mmpos.object_version_number,
           mmpos.deactivate_old_position,
           mmpos.new_position_id,
           mmpos.target_job_id,
           mmpos.position_moved,
           mmpos.default_from,
           mmpos.segment1,
           mmpos.segment2,
           mmpos.segment3,
           mmpos.segment4,
           mmpos.segment5,
           mmpos.segment6,
           mmpos.segment7,
           mmpos.segment8,
           mmpos.segment9,
           mmpos.segment10,
           mmpos.segment11,
           mmpos.segment12,
           mmpos.segment13,
           mmpos.segment14,
           mmpos.segment15,
           mmpos.segment16,
           mmpos.segment17,
           mmpos.segment18,
           mmpos.segment19,
           mmpos.segment20,
           mmpos.segment21,
           mmpos.segment22,
           mmpos.segment23,
           mmpos.segment24,
           mmpos.segment25,
           mmpos.segment26,
           mmpos.segment27,
           mmpos.segment28,
           mmpos.segment29,
           mmpos.segment30
      from per_mm_positions mmpos,
           hr_positions_f pos
     where mmpos.mass_move_id = p_mass_move_id
       and mmpos.position_id = pos.position_id
       and mmpos.select_position = 'Y'
       and l_effective_date BETWEEN pos.effective_start_date
                                AND pos.effective_end_date;
  --
  -- Check for errors at the end of the mass move
  --
  cursor csr_chk_errors is
    select 'Y'
      from hr_api_batch_message_lines
     where batch_run_number = l_batch_run_number
       and status = 'F';
  --
   cursor csr_chk_warnings is
    select 'Y'
      from hr_api_batch_message_lines
     where batch_run_number = l_batch_run_number
       and status = 'S';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint.
  --
  savepoint activate_mass_move;
  --
  -- Get a unique run number to identify errors
  --
  open csr_batch_run_number;
  fetch csr_batch_run_number into
    l_batch_run_number;
  close csr_batch_run_number;
  --
  --  Get information about the mass move if ID is not null
  --  and is valid.
  --
  if p_mass_move_id is not null then
    --
    hr_utility.set_location(l_proc, 20);
    --
    open  csr_get_mass_move_info;
    fetch csr_get_mass_move_info into l_new_organization_id,
                                      l_effective_date;
    --
    if csr_get_mass_move_info%notfound then
      --
      close csr_get_mass_move_info;
      --
      hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
      hr_utility.raise_error;
      --
    end if;
    --
    close csr_get_mass_move_info;
    --
  else
    --
    hr_utility.set_message(801, 'HR_7207_API_MANDATORY_ARG');
    hr_utility.raise_error;
    --
  end if;
  --
  -- Issue a savepoint
  --
  savepoint massmove;
  --
  -- Lock all tables holding mass move information
  --
  open  csr_lock_per_mass_moves;
  close csr_lock_per_mass_moves;
  open  csr_lock_per_mm_positions;
  close csr_lock_per_mm_positions;
  open  csr_lock_per_mm_assignments;
  close csr_lock_per_mm_assignments;
  open  csr_lock_per_mm_valid_grades;
  close csr_lock_per_mm_valid_grades;
  open  csr_lock_per_mm_job_reqts;
  close csr_lock_per_mm_job_reqts;
  --
  hr_utility.set_location(l_proc, 30);
  --
  -- Get default location and working conditions from the new
  -- organization
  --
  open  csr_get_org_defaults;
  fetch csr_get_org_defaults into
    l_business_group_id,
    l_org_time_normal_start,
    l_org_time_normal_finish,
    l_org_normal_hours,
    l_org_frequency,
    l_org_location_id;
  --
  close csr_get_org_defaults;
  --
  hr_utility.set_location(l_proc, 40);
  --
  -- Get default location and working conditions from the
  -- business group
  --
  open  csr_get_busgrp_defaults;
  fetch csr_get_busgrp_defaults into
    l_legislation_code,
    l_bg_time_normal_start,
    l_bg_time_normal_finish,
    l_bg_normal_hours,
    l_bg_frequency,
    l_bg_location_id;
  --
  close csr_get_busgrp_defaults;
  --
  hr_utility.set_location(l_proc, 50);
  --
  begin
    --
    -- Start of API User Hook for the before hook of mass_move
    -- Specifically placed after the business_group_id is retrieved, based on
    -- the new organization.
    --
    hr_mass_move_bk1.mass_move_b
      (p_mass_move_id                => p_mass_move_id
      ,p_business_group_id           => l_business_group_id
      );
   exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'MASS_MOVE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of mass_move
    --
  end;
  --
  -- Call Customer-Specific stub to handle pre-mass move validation
  --
  hr_mass_move_cus.pre_mass_move
    (p_mass_move_id              => p_mass_move_id);
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- Loop through the position records in per_mm_positions, and
  -- process the position, applicant assignments, and employee
  -- assignment records.
  --
  for mmposrec in csr_get_mm_positions loop
    --
    begin
      --
      savepoint position;
      --
      l_position_name := mmposrec.name;
      l_position_id   := mmposrec.position_id;
      --
      hr_utility.set_location(l_proc||'/'||
                              l_position_name||'/'||
                              l_position_id, 70);
      --
      if mmposrec.deactivate_old_position = 'Y' then
        --
        l_deactivate_boolean := TRUE;
        --
      else
        --
        l_deactivate_boolean := FALSE;
        --
      end if;
      --
      hr_utility.set_location(l_proc, 80);
      --
      -- Get default location and working conditions from the
      -- old position business group
      --
      open csr_get_old_pos_defaults;
      fetch csr_get_old_pos_defaults into
         l_old_pos_time_normal_start,
         l_old_pos_time_normal_finish,
         l_old_pos_normal_hours,
         l_old_pos_frequency,
         l_old_pos_location_id;
      --
      close csr_get_old_pos_defaults;
      --
      hr_utility.set_location(l_proc, 90);
      --
      if mmposrec.default_from = 'B' then
        --
        hr_utility.set_location(l_proc, 100);
        --
        l_location_id         := l_bg_location_id;
        l_frequency	          := l_bg_frequency;
        l_normal_hours	       := l_bg_normal_hours;
        l_time_normal_finish  := l_bg_time_normal_finish;
        l_time_normal_start   := l_bg_time_normal_start;
        --
      elsif mmposrec.default_from = 'O' then
        --
        hr_utility.set_location(l_proc, 110);
        --
        l_location_id         := l_org_location_id;
        l_frequency	          := l_org_frequency;
        l_normal_hours	       := l_org_normal_hours;
        l_time_normal_finish  := l_org_time_normal_finish;
        l_time_normal_start   := l_org_time_normal_start;
        --
      elsif mmposrec.default_from = 'P' then
        --
        hr_utility.set_location(l_proc, 120);
        --
        l_location_id         := l_old_pos_location_id;
        l_frequency	          := l_old_pos_frequency;
        l_normal_hours	       := l_old_pos_normal_hours;
        l_time_normal_finish  := l_old_pos_time_normal_finish;
        l_time_normal_start   := l_old_pos_time_normal_start;
        --
      end if;
      --
      -- Call the move position process to create the new position
      --
      if mmposrec.position_moved = 'N' then
        --
        hr_utility.set_location(l_proc, 130);
        --
        hr_mass_move_api.move_position
        (p_validate                     => FALSE
        ,p_batch_run_number             => l_batch_run_number
        ,p_position_id                  => mmposrec.position_id
        ,p_job_id                       => mmposrec.target_job_id
        ,p_object_version_number        => mmposrec.object_version_number
        ,p_date_effective               => l_effective_date
        ,p_organization_id              => l_new_organization_id
        ,p_deactivate_old_position      => l_deactivate_boolean
        ,p_mass_move_id                 => p_mass_move_id
        ,p_time_normal_start            => l_time_normal_start
        ,p_time_normal_finish           => l_time_normal_finish
        ,p_normal_hours                 => l_normal_hours
        ,p_frequency                    => l_frequency
        ,p_location_id                  => l_location_id
        ,p_segment1                     => mmposrec.segment1
        ,p_segment2                     => mmposrec.segment2
        ,p_segment3                     => mmposrec.segment3
        ,p_segment4                     => mmposrec.segment4
        ,p_segment5                     => mmposrec.segment5
        ,p_segment6                     => mmposrec.segment6
        ,p_segment7                     => mmposrec.segment7
        ,p_segment8                     => mmposrec.segment8
        ,p_segment9                     => mmposrec.segment9
        ,p_segment10                    => mmposrec.segment10
        ,p_segment11                    => mmposrec.segment11
        ,p_segment12                    => mmposrec.segment12
        ,p_segment13                    => mmposrec.segment13
        ,p_segment14                    => mmposrec.segment14
        ,p_segment15                    => mmposrec.segment15
        ,p_segment16                    => mmposrec.segment16
        ,p_segment17                    => mmposrec.segment17
        ,p_segment18                    => mmposrec.segment18
        ,p_segment19                    => mmposrec.segment19
        ,p_segment20                    => mmposrec.segment20
        ,p_segment21                    => mmposrec.segment21
        ,p_segment22                    => mmposrec.segment22
        ,p_segment23                    => mmposrec.segment23
        ,p_segment24                    => mmposrec.segment24
        ,p_segment25                    => mmposrec.segment25
        ,p_segment26                    => mmposrec.segment26
        ,p_segment27                    => mmposrec.segment27
        ,p_segment28                    => mmposrec.segment28
        ,p_segment29                    => mmposrec.segment29
        ,p_segment30                    => mmposrec.segment30
        ,p_new_position_id              => l_new_position_id              --out
        ,p_new_job_id                   => l_new_job_id                   --out
        ,p_new_object_version_number    => l_new_pos_ovn                  --out
        ,p_valid_grades_changed_warning => l_valid_grades_changed_warning --out
        ,p_pos_exists_warning           => l_pos_exists_warning           --out
        ,p_pos_date_range_warning       => l_pos_date_range_warning       --out
        ,p_pos_pending_close_warning    => l_pos_pending_close_warning    --out
        ,p_pos_jbe_not_moved_warning    => l_pos_jbe_not_moved_warning    --out
        ,p_pos_vac_not_moved_warning    => l_pos_vac_not_moved_warning    --out
        );
        --
        hr_utility.set_location(l_proc, 140);
        --
        if (l_new_position_id is not null) then
          --
          -- If it made it this far, update the position to 'moved'
          --
          update per_mm_positions
          set   position_moved = 'Y',
              target_job_id = l_new_job_id,
              new_position_id = l_new_position_id
          where position_id = mmposrec.position_id
          and   mass_move_id = p_mass_move_id;
          --
        end if;
        --
        hr_utility.set_location(l_proc, 150);
      --
      -- in the case of a reexecution, set the vals from the table.
      --
      else
        --
        hr_utility.set_location(l_proc, 160);
        --
        l_new_position_id := mmposrec.new_position_id;
        l_new_job_id := mmposrec.target_job_id;
        --
      end if; /* end if position_moved = 'N' */
      --
      -- Get the location and working condition information from the new
      -- position.
      --
      open  csr_get_new_pos_defaults;
      fetch csr_get_new_pos_defaults into
        l_new_pos_time_normal_start,
        l_new_pos_time_normal_finish,
        l_new_pos_normal_hours,
        l_new_pos_frequency,
        l_new_pos_location_id;
      --
      close csr_get_new_pos_defaults;
      --
      hr_utility.set_location(l_proc, 170);
      --
      move_assignments
        (p_mass_move_id             => p_mass_move_id
        ,p_old_position_id          => mmposrec.position_id
        ,p_new_position_id          => l_new_position_id
        ,p_new_job_id               => l_new_job_id
        ,p_effective_date           => l_effective_date
        ,p_new_organization_id      => l_new_organization_id
        ,p_pos_time_normal_start    => l_new_pos_time_normal_start
        ,p_pos_time_normal_finish   => l_new_pos_time_normal_finish
        ,p_pos_normal_hours         => l_new_pos_normal_hours
        ,p_pos_frequency            => l_new_pos_frequency
        ,p_pos_location_id          => l_new_pos_location_id
        ,p_org_time_normal_start    => l_org_time_normal_start
        ,p_org_time_normal_finish   => l_org_time_normal_finish
        ,p_org_normal_hours         => l_org_normal_hours
        ,p_org_frequency            => l_org_frequency
        ,p_org_location_id          => l_org_location_id
        ,p_legislation_code         => l_legislation_code
        ,p_bg_time_normal_start     => l_bg_time_normal_start
        ,p_bg_time_normal_finish    => l_bg_time_normal_finish
        ,p_bg_normal_hours          => l_bg_normal_hours
        ,p_bg_frequency             => l_bg_frequency
        ,p_bg_location_id           => l_bg_location_id
        ,p_batch_run_number         => l_batch_run_number);
      --
      hr_utility.set_location(l_proc, 180);
      --
      -- Check for position warning messages
      --
      if l_pos_exists_warning = TRUE then
        --
        hr_utility.set_location(l_proc, 190);
        --
        ROLLBACK TO move_position;
        --
        hr_utility.set_message(801,'HR_51330_MMV_POS_EXISTS');
        --
        hr_batch_message_line_api.create_message_line
          (p_validate               => FALSE
          ,p_batch_run_number       => l_batch_run_number
          ,p_api_name               => 'hr_mass_move_api.move_position'
          ,p_status                 => 'S'
          ,p_error_number           => '51130'
          ,p_error_message          =>  hr_utility.get_message
          ,p_extended_error_message => fnd_message.get
          ,p_source_row_information => l_position_name
          ,p_line_id                => l_dummy_line_id);
        --
      end if;
      --
      if l_pos_date_range_warning = TRUE then
        --
        hr_utility.set_location(l_proc, 200);
        --
        ROLLBACK TO move_position;
        --
        hr_utility.set_message(801,'HR_51331_MMV_POS_INVALID_DATE');
        --
        hr_batch_message_line_api.create_message_line
          (p_validate               => FALSE
          ,p_batch_run_number       => l_batch_run_number
          ,p_api_name               => 'hr_mass_move_api.move_position'
          ,p_status                 => 'S'
          ,p_error_number           => '51331'
          ,p_error_message          => hr_utility.get_message
          ,p_extended_error_message => fnd_message.get
          ,p_source_row_information => l_position_name
          ,p_line_id                => l_dummy_line_id);
        --
      end if;
      --
      if l_pos_pending_close_warning = TRUE then
        --
        hr_utility.set_location(l_proc, 210);
        --
        hr_utility.set_message(801,'HR_51335_MMV_POS_CLOSED');
        --
        hr_batch_message_line_api.create_message_line
          (p_validate               => FALSE
          ,p_batch_run_number       => l_batch_run_number
          ,p_api_name               => 'hr_mass_move_api.move_position'
          ,p_status                 => 'S'
          ,p_error_number           => '51335'
          ,p_error_message          => hr_utility.get_message
          ,p_extended_error_message => fnd_message.get
          ,p_source_row_information => l_position_name
          ,p_line_id                => l_dummy_line_id);
        --
      end if;
      --
      if l_valid_grades_changed_warning = TRUE then
        --
        hr_utility.set_location(l_proc, 220);
        --
        hr_utility.set_message(801,'HR_51128_MMV_VGR_ALTERED');
        --
        hr_batch_message_line_api.create_message_line
            (p_validate               => FALSE
            ,p_batch_run_number       => l_batch_run_number
            ,p_api_name               => 'hr_mass_move_api.move_position'
            ,p_status                 => 'S'
            ,p_error_number           => '51128'
            ,p_error_message          => hr_utility.get_message
            ,p_extended_error_message => fnd_message.get
            ,p_source_row_information => l_position_name
            ,p_line_id                => l_dummy_line_id);
        --
      end if;
      --
      if l_pos_jbe_not_moved_warning = TRUE then
        --
        hr_utility.set_location(l_proc, 230);
        --
        hr_utility.set_message(801,'HR_51334_MMV_POS_JBE_NOT_MOVED');
        --
        hr_batch_message_line_api.create_message_line
          (p_validate               => FALSE
          ,p_batch_run_number       => l_batch_run_number
          ,p_api_name               => 'hr_mass_move_api.move_position'
          ,p_status                 => 'S'
          ,p_error_number           => '51334'
          ,p_error_message          => hr_utility.get_message
          ,p_extended_error_message => fnd_message.get
          ,p_source_row_information => l_position_name
          ,p_line_id                => l_dummy_line_id);
        --
      end if;
      --
      if l_pos_vac_not_moved_warning = TRUE then
        --
        hr_utility.set_location(l_proc, 240);
        --
        hr_utility.set_message(801,'HR_51333_MMV_POS_VAC_NOT_MOVED');
        --
        hr_batch_message_line_api.create_message_line
          (p_validate               => FALSE
          ,p_batch_run_number       => l_batch_run_number
          ,p_api_name               => 'hr_mass_move_api.move_position'
          ,p_status                 => 'S'
          ,p_error_number           => '51333'
          ,p_error_message          => hr_utility.get_message
          ,p_extended_error_message => fnd_message.get
          ,p_source_row_information => l_position_name
          ,p_line_id                => l_dummy_line_id);
        --
    end if;
    --
  end;   --begin
    --
  end loop; /* end loop through positions in per_mm_positions */
  --
  hr_utility.set_location(l_proc, 250);
  --
  -- Call Customer-Specific stub to handle post-mass move validation
  --
  hr_mass_move_cus.post_mass_move
   (p_mass_move_id              => p_mass_move_id);
  --
  -- If everything has completed successfully, update the massmove status
  --
  l_errors_exist := 'N';
  open csr_chk_errors;
  fetch csr_chk_errors into l_errors_exist;
  close csr_chk_errors;
  --
  hr_utility.set_location(l_proc, 260);
  --
  l_warnings_exist := 'N';
  open csr_chk_warnings;
  fetch csr_chk_warnings into l_warnings_exist;
  close csr_chk_warnings;
  --
  if l_errors_exist = 'Y' then
    --
    hr_utility.set_location(l_proc, 270);
    --
    rollback to massmove;
    --
    update per_mass_moves
       set batch_run_number = l_batch_run_number,
           status = 'ER'
     where mass_move_id = p_mass_move_id;
    --
  elsif l_warnings_exist = 'Y' then
    --
    hr_utility.set_location(l_proc, 280);
    --
    update per_mass_moves
       set batch_run_number = l_batch_run_number,
           status = 'WA'
     where mass_move_id = p_mass_move_id;
    --
  else
    --
    hr_utility.set_location(l_proc, 290);
    --
    update per_mass_moves
       set batch_run_number = l_batch_run_number,
           status = 'CO'
     where mass_move_id = p_mass_move_id;
    --
  end if;
  --
  begin
    --
    -- Start of API User Hook for the after hook of mass_move
    --
    hr_mass_move_bk1.mass_move_a
      (p_mass_move_id                => p_mass_move_id
      ,p_business_group_id           => l_business_group_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'MASS_MOVE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of mass_move
    --
  end;
  --
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    --
    raise hr_api.validate_enabled;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 997);
  --
  exception
    --
    when hr_api.validate_enabled then
      --
      hr_utility.set_location(' Leaving:'||l_proc, 998);
      --
      -- As the Validate_Enabled exception has been raised
      -- we must rollback to the savepoint
      --
      ROLLBACK TO activate_mass_move;
      --
    when others then
      --
      hr_utility.set_location(' Leaving:'||l_proc, 999);
      --
      rollback to massmove;
      --
      hr_batch_message_line_api.create_message_line
          (p_validate               => FALSE
          ,p_batch_run_number       => l_batch_run_number
          ,p_api_name               => 'hr_mass_move_api.mass_move'
          ,p_status                 => 'F'
          ,p_error_number           => sqlcode
          ,p_error_message          => sqlerrm
          ,p_extended_error_message => fnd_message.get
          ,p_source_row_information => l_position_name
          ,p_line_id                => l_dummy_line_id);
      --
      update per_mass_moves
       set batch_run_number = l_batch_run_number,
           status = 'ER'
       where mass_move_id = p_mass_move_id;
      --
end mass_move;
--
end hr_mass_move_api;

/
