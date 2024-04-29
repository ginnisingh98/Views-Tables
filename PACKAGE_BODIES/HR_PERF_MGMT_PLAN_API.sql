--------------------------------------------------------
--  DDL for Package Body HR_PERF_MGMT_PLAN_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PERF_MGMT_PLAN_API" as
/* $Header: pepmpapi.pkb 120.2.12010000.3 2010/01/27 15:20:19 rsykam ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_perf_mgmt_plan_api.';
g_debug    boolean      := hr_utility.debug_enabled;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_perf_mgmt_plan >------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_perf_mgmt_plan
  (p_validate                      in   boolean    default false
  ,p_effective_date                in   date
  ,p_plan_name                     in   varchar2
  ,p_administrator_person_id       in   number
  ,p_previous_plan_id              in   number     default null
  ,p_start_date                    in   date
  ,p_end_date                      in   date
  ,p_hierarchy_type_code           in   varchar2   default null
  ,p_supervisor_id                 in   number     default null
  ,p_supervisor_assignment_id      in   number     default null
  ,p_organization_structure_id     in   number     default null
  ,p_org_structure_version_id      in   number     default null
  ,p_top_organization_id           in   number     default null
  ,p_position_structure_id         in   number     default null
  ,p_pos_structure_version_id      in   number     default null
  ,p_top_position_id               in   number     default null
  ,p_hierarchy_levels              in   number     default null
  ,p_automatic_enrollment_flag     in   varchar2   default 'N'
  ,p_assignment_types_code         in   varchar2   default 'E'
  ,p_primary_asg_only_flag         in   varchar2   default 'Y'
  ,p_include_obj_setting_flag      in   varchar2   default 'Y'
  ,p_obj_setting_start_date        in   date       default null
  ,p_obj_setting_deadline          in   date       default null
  ,p_obj_set_outside_period_flag   in   varchar2   default 'N'
  ,p_method_code                   in   varchar2   default 'CAS'
  ,p_notify_population_flag        in   varchar2   default 'Y'
  ,p_automatic_allocation_flag     in   varchar2   default 'N'
  ,p_copy_past_objectives_flag     in   varchar2   default 'N'
  ,p_sharing_alignment_task_flag   in   varchar2   default 'Y'
  ,p_include_appraisals_flag       in   varchar2   default 'Y'
  ,p_change_sc_status_flag  in   varchar2   default 'N'
  ,p_attribute_category            in   varchar2   default null
  ,p_attribute1                    in   varchar2   default null
  ,p_attribute2                    in   varchar2   default null
  ,p_attribute3                    in   varchar2   default null
  ,p_attribute4                    in   varchar2   default null
  ,p_attribute5                    in   varchar2   default null
  ,p_attribute6                    in   varchar2   default null
  ,p_attribute7                    in   varchar2   default null
  ,p_attribute8                    in   varchar2   default null
  ,p_attribute9                    in   varchar2   default null
  ,p_attribute10                   in   varchar2   default null
  ,p_attribute11                   in   varchar2   default null
  ,p_attribute12                   in   varchar2   default null
  ,p_attribute13                   in   varchar2   default null
  ,p_attribute14                   in   varchar2   default null
  ,p_attribute15                   in   varchar2   default null
  ,p_attribute16                   in   varchar2   default null
  ,p_attribute17                   in   varchar2   default null
  ,p_attribute18                   in   varchar2   default null
  ,p_attribute19                   in   varchar2   default null
  ,p_attribute20                   in   varchar2   default null
  ,p_attribute21                   in   varchar2   default null
  ,p_attribute22                   in   varchar2   default null
  ,p_attribute23                   in   varchar2   default null
  ,p_attribute24                   in   varchar2   default null
  ,p_attribute25                   in   varchar2   default null
  ,p_attribute26                   in   varchar2   default null
  ,p_attribute27                   in   varchar2   default null
  ,p_attribute28                   in   varchar2   default null
  ,p_attribute29                   in   varchar2   default null
  ,p_attribute30                   in   varchar2   default null
  ,p_plan_id                          out nocopy   number
  ,p_object_version_number            out nocopy   number
  ,p_status_code                      out nocopy   varchar2
  ,p_duplicate_name_warning           out nocopy   boolean
  ,p_no_life_events_warning           out nocopy   boolean
  ,p_update_library_objectives in varchar2  default null    -- 8740021 bug fix
  ,p_automatic_approval_flag in varchar2  default null
  ) is
  --
  -- Declare cursors and local variables
  --
    l_proc                         varchar2(72) := g_package||'create_perf_mgmt_plan';
    l_effective_date               date;
    l_start_date                   date;
    l_end_date                     date;
    l_obj_setting_start_date       date;
    l_obj_setting_deadline         date;
    l_object_version_number        number;
    l_plan_id                      number;
    l_status_code                  per_perf_mgmt_plans.status_code%TYPE;
    l_duplicate_name_warning       boolean := false;
    l_no_life_events_warning       boolean := false;

  begin

  IF g_debug THEN

    hr_utility.set_location('Entering:'|| l_proc, 10);

    hr_utility.trace(' ');
    hr_utility.trace(' --------------------------------'||
                     '---------------------------------');
    hr_utility.trace(' IN / IN OUT PARAMETER           '||
                     ' VALUE');
    hr_utility.trace(' --------------------------------'||
                     '+--------------------------------');
    hr_utility.trace('  p_effective_date                 '||
                        to_char(p_effective_date));
    hr_utility.trace('  p_plan_name                      '||
                        p_plan_name);
    hr_utility.trace('  p_administrator_person_id        '||
                        to_char(p_administrator_person_id));
    hr_utility.trace('  p_previous_plan_id               '||
                        to_char(p_previous_plan_id));
    hr_utility.trace('  p_start_date                     '||
                        to_char(p_start_date));
    hr_utility.trace('  p_end_date                       '||
                        to_char(p_end_date));
    hr_utility.trace('  p_hierarchy_type_code            '||
                        p_hierarchy_type_code);
    hr_utility.trace('  p_supervisor_id                  '||
                        to_char(p_supervisor_id));
    hr_utility.trace('  p_supervisor_assignment_id       '||
                        to_char(p_supervisor_assignment_id));
    hr_utility.trace('  p_organization_structure_id      '||
                        to_char(p_organization_structure_id));
    hr_utility.trace('  p_org_structure_version_id       '||
                        to_char(p_org_structure_version_id));
    hr_utility.trace('  p_top_organization_id            '||
                        to_char(p_top_organization_id));
    hr_utility.trace('  p_position_structure_id          '||
                        to_char(p_position_structure_id));
    hr_utility.trace('  p_pos_structure_version_id       '||
                        to_char(p_pos_structure_version_id));
    hr_utility.trace('  p_top_position_id                '||
                        to_char(p_top_position_id));
    hr_utility.trace('  p_hierarchy_levels               '||
                        to_char(p_hierarchy_levels));
    hr_utility.trace('  p_automatic_enrollment_flag      '||
                        p_automatic_enrollment_flag);
    hr_utility.trace('  p_assignment_types_code          '||
                        p_assignment_types_code);
    hr_utility.trace('  p_primary_asg_only_flag          '||
                        p_primary_asg_only_flag);
    hr_utility.trace('  p_include_obj_setting_flag       '||
                        p_include_obj_setting_flag);
    hr_utility.trace('  p_obj_setting_start_date         '||
                        to_char(p_obj_setting_start_date));
    hr_utility.trace('  p_obj_setting_deadline           '||
                        to_char(p_obj_setting_deadline));
    hr_utility.trace('  p_obj_set_outside_period_flag    '||
                        p_obj_set_outside_period_flag);
    hr_utility.trace('  p_method_code                    '||
                        p_method_code);
    hr_utility.trace('  p_notify_population_flag         '||
                        p_notify_population_flag);
    hr_utility.trace('  p_automatic_allocation_flag      '||
                        p_automatic_allocation_flag);
    hr_utility.trace('  p_copy_past_objectives_flag      '||
                        p_copy_past_objectives_flag);
    hr_utility.trace('  p_sharing_alignment_task_flag    '||
                        p_sharing_alignment_task_flag);
    hr_utility.trace('  p_include_appraisals_flag        '||
                        p_include_appraisals_flag);
    hr_utility.trace('  p_change_sc_status_flag   '||
                        p_change_sc_status_flag);
    hr_utility.trace(' --------------------------------'||
                     '---------------------------------');
    hr_utility.trace(' ');

  END IF;

  --
  -- Issue a savepoint
  --
     savepoint create_perf_mgmt_plan;

  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date         := trunc(p_effective_date);
  l_start_date             := trunc(p_start_date);
  l_end_date               := trunc(p_end_date);
  l_obj_setting_start_date := trunc(p_obj_setting_start_date);
  l_obj_setting_deadline   := trunc(p_obj_setting_deadline);

  --
  -- Call Before Process User Hook
  --
 begin
   hr_perf_mgmt_plan_bk1.create_perf_mgmt_plan_b
     (p_effective_date                => l_effective_date
     ,p_plan_name                     => p_plan_name
     ,p_administrator_person_id       => p_administrator_person_id
     ,p_previous_plan_id              => p_previous_plan_id
     ,p_start_date                    => l_start_date
     ,p_end_date                      => l_end_date
     ,p_hierarchy_type_code           => p_hierarchy_type_code
     ,p_supervisor_id                 => p_supervisor_id
     ,p_supervisor_assignment_id      => p_supervisor_assignment_id
     ,p_organization_structure_id     => p_organization_structure_id
     ,p_org_structure_version_id      => p_org_structure_version_id
     ,p_top_organization_id           => p_top_organization_id
     ,p_position_structure_id         => p_position_structure_id
     ,p_pos_structure_version_id      => p_pos_structure_version_id
     ,p_top_position_id               => p_top_position_id
     ,p_hierarchy_levels              => p_hierarchy_levels
     ,p_automatic_enrollment_flag     => p_automatic_enrollment_flag
     ,p_assignment_types_code         => p_assignment_types_code
     ,p_primary_asg_only_flag         => p_primary_asg_only_flag
     ,p_include_obj_setting_flag      => p_include_obj_setting_flag
     ,p_obj_setting_start_date        => l_obj_setting_start_date
     ,p_obj_setting_deadline          => l_obj_setting_deadline
     ,p_obj_set_outside_period_flag   => p_obj_set_outside_period_flag
     ,p_method_code                   => p_method_code
     ,p_notify_population_flag        => p_notify_population_flag
     ,p_automatic_allocation_flag     => p_automatic_allocation_flag
     ,p_copy_past_objectives_flag     => p_copy_past_objectives_flag
     ,p_sharing_alignment_task_flag   => p_sharing_alignment_task_flag
     ,p_include_appraisals_flag       => p_include_appraisals_flag
     ,p_change_sc_status_flag  => p_change_sc_status_flag
     ,p_attribute_category            => p_attribute_category
     ,p_attribute1                    => p_attribute1
     ,p_attribute2                    => p_attribute2
     ,p_attribute3                    => p_attribute3
     ,p_attribute4                    => p_attribute4
     ,p_attribute5                    => p_attribute5
     ,p_attribute6                    => p_attribute6
     ,p_attribute7                    => p_attribute7
     ,p_attribute8                    => p_attribute8
     ,p_attribute9                    => p_attribute9
     ,p_attribute10                   => p_attribute10
     ,p_attribute11                   => p_attribute11
     ,p_attribute12                   => p_attribute12
     ,p_attribute13                   => p_attribute13
     ,p_attribute14                   => p_attribute14
     ,p_attribute15                   => p_attribute15
     ,p_attribute16                   => p_attribute16
     ,p_attribute17                   => p_attribute17
     ,p_attribute18                   => p_attribute18
     ,p_attribute19                   => p_attribute19
     ,p_attribute20                   => p_attribute20
     ,p_attribute21                   => p_attribute21
     ,p_attribute22                   => p_attribute22
     ,p_attribute23                   => p_attribute23
     ,p_attribute24                   => p_attribute24
     ,p_attribute25                   => p_attribute25
     ,p_attribute26                   => p_attribute26
     ,p_attribute27                   => p_attribute27
     ,p_attribute28                   => p_attribute28
     ,p_attribute29                   => p_attribute29
     ,p_attribute30                   => p_attribute30
    ,p_update_library_objectives    => p_update_library_objectives  -- 8740021 bug fix
    ,p_automatic_approval_flag      => p_automatic_approval_flag
    );

   exception
     when hr_api.cannot_find_prog_unit then
     hr_api.cannot_find_prog_unit_error
      (p_module_name => 'CREATE_PERF_MGMT_PLAN',
       p_hook_type   => 'BP'
      );
  end;
  --
  -- End of Before Process User Hook call
  --
  IF g_debug THEN hr_utility.set_location(l_proc, 30); END IF;

  --
  -- Call the row handler insert
  --
  per_pmp_ins.ins
  (p_effective_date                => l_effective_date
  ,p_plan_name                     => p_plan_name
  ,p_administrator_person_id       => p_administrator_person_id
  ,p_previous_plan_id              => p_previous_plan_id
  ,p_start_date                    => l_start_date
  ,p_end_date                      => l_end_date
  ,p_hierarchy_type_code           => p_hierarchy_type_code
  ,p_supervisor_id                 => p_supervisor_id
  ,p_supervisor_assignment_id	   => p_supervisor_assignment_id
  ,p_organization_structure_id     => p_organization_structure_id
  ,p_org_structure_version_id      => p_org_structure_version_id
  ,p_top_organization_id           => p_top_organization_id
  ,p_position_structure_id         => p_position_structure_id
  ,p_pos_structure_version_id      => p_pos_structure_version_id
  ,p_top_position_id               => p_top_position_id
  ,p_hierarchy_levels              => p_hierarchy_levels
  ,p_automatic_enrollment_flag     => p_automatic_enrollment_flag
  ,p_assignment_types_code         => p_assignment_types_code
  ,p_primary_asg_only_flag         => p_primary_asg_only_flag
  ,p_include_obj_setting_flag      => p_include_obj_setting_flag
  ,p_obj_setting_start_date        => l_obj_setting_start_date
  ,p_obj_setting_deadline          => l_obj_setting_deadline
  ,p_obj_set_outside_period_flag   => p_obj_set_outside_period_flag
  ,p_method_code                   => p_method_code
  ,p_notify_population_flag        => p_notify_population_flag
  ,p_automatic_allocation_flag     => p_automatic_allocation_flag
  ,p_copy_past_objectives_flag     => p_copy_past_objectives_flag
  ,p_sharing_alignment_task_flag   => p_sharing_alignment_task_flag
  ,p_include_appraisals_flag       => p_include_appraisals_flag
  ,p_change_sc_status_flag  => p_change_sc_status_flag
  ,p_attribute_category            => p_attribute_category
  ,p_attribute1                    => p_attribute1
  ,p_attribute2                    => p_attribute2
  ,p_attribute3                    => p_attribute3
  ,p_attribute4                    => p_attribute4
  ,p_attribute5                    => p_attribute5
  ,p_attribute6                    => p_attribute6
  ,p_attribute7                    => p_attribute7
  ,p_attribute8                    => p_attribute8
  ,p_attribute9                    => p_attribute9
  ,p_attribute10                   => p_attribute10
  ,p_attribute11                   => p_attribute11
  ,p_attribute12                   => p_attribute12
  ,p_attribute13                   => p_attribute13
  ,p_attribute14                   => p_attribute14
  ,p_attribute15                   => p_attribute15
  ,p_attribute16                   => p_attribute16
  ,p_attribute17                   => p_attribute17
  ,p_attribute18                   => p_attribute18
  ,p_attribute19                   => p_attribute19
  ,p_attribute20                   => p_attribute20
  ,p_attribute21                   => p_attribute21
  ,p_attribute22                   => p_attribute22
  ,p_attribute23                   => p_attribute23
  ,p_attribute24                   => p_attribute24
  ,p_attribute25                   => p_attribute25
  ,p_attribute26                   => p_attribute26
  ,p_attribute27                   => p_attribute27
  ,p_attribute28                   => p_attribute28
  ,p_attribute29                   => p_attribute29
  ,p_attribute30                   => p_attribute30
  ,p_plan_id                      =>  l_plan_id
  ,p_object_version_number         => l_object_version_number
  ,p_status_code                   => l_status_code
  ,p_duplicate_name_warning        => l_duplicate_name_warning
  ,p_no_life_events_warning        => p_no_life_events_warning
  ,p_update_library_objectives    => p_update_library_objectives  -- 8740021 bug fix
  ,p_automatic_approval_flag      => p_automatic_approval_flag
  );

  IF g_debug THEN hr_utility.set_location(l_proc, 30); END IF;

   --
   -- Call After Process User Hook
   --

   begin

  hr_perf_mgmt_plan_bk1.create_perf_mgmt_plan_a
  (p_effective_date                => l_effective_date
  ,p_plan_id                       => l_plan_id
  ,p_plan_name                     => p_plan_name
  ,p_administrator_person_id       => p_administrator_person_id
  ,p_previous_plan_id              => p_previous_plan_id
  ,p_start_date                    => l_start_date
  ,p_end_date                      => l_end_date
  ,p_hierarchy_type_code           => p_hierarchy_type_code
  ,p_supervisor_id                 => p_supervisor_id
  ,p_supervisor_assignment_id      => p_supervisor_assignment_id
  ,p_organization_structure_id     => p_organization_structure_id
  ,p_org_structure_version_id      => p_org_structure_version_id
  ,p_top_organization_id           => p_top_organization_id
  ,p_position_structure_id         => p_position_structure_id
  ,p_pos_structure_version_id      => p_pos_structure_version_id
  ,p_top_position_id               => p_top_position_id
  ,p_hierarchy_levels              => p_hierarchy_levels
  ,p_automatic_enrollment_flag     => p_automatic_enrollment_flag
  ,p_assignment_types_code         => p_assignment_types_code
  ,p_primary_asg_only_flag         => p_primary_asg_only_flag
  ,p_include_obj_setting_flag      => p_include_obj_setting_flag
  ,p_obj_setting_start_date        => l_obj_setting_start_date
  ,p_obj_setting_deadline          => l_obj_setting_deadline
  ,p_obj_set_outside_period_flag   => p_obj_set_outside_period_flag
  ,p_method_code                   => p_method_code
  ,p_notify_population_flag        => p_notify_population_flag
  ,p_automatic_allocation_flag     => p_automatic_allocation_flag
  ,p_copy_past_objectives_flag     => p_copy_past_objectives_flag
  ,p_sharing_alignment_task_flag   => p_sharing_alignment_task_flag
  ,p_include_appraisals_flag       => p_include_appraisals_flag
  ,p_change_sc_status_flag  => p_change_sc_status_flag
  ,p_attribute_category            => p_attribute_category
  ,p_attribute1                    => p_attribute1
  ,p_attribute2                    => p_attribute2
  ,p_attribute3                    => p_attribute3
  ,p_attribute4                    => p_attribute4
  ,p_attribute5                    => p_attribute5
  ,p_attribute6                    => p_attribute6
  ,p_attribute7                    => p_attribute7
  ,p_attribute8                    => p_attribute8
  ,p_attribute9                    => p_attribute9
  ,p_attribute10                   => p_attribute10
  ,p_attribute11                   => p_attribute11
  ,p_attribute12                   => p_attribute12
  ,p_attribute13                   => p_attribute13
  ,p_attribute14                   => p_attribute14
  ,p_attribute15                   => p_attribute15
  ,p_attribute16                   => p_attribute16
  ,p_attribute17                   => p_attribute17
  ,p_attribute18                   => p_attribute18
  ,p_attribute19                   => p_attribute19
  ,p_attribute20                   => p_attribute20
  ,p_attribute21                   => p_attribute21
  ,p_attribute22                   => p_attribute22
  ,p_attribute23                   => p_attribute23
  ,p_attribute24                   => p_attribute24
  ,p_attribute25                   => p_attribute25
  ,p_attribute26                   => p_attribute26
  ,p_attribute27                   => p_attribute27
  ,p_attribute28                   => p_attribute28
  ,p_attribute29                   => p_attribute29
  ,p_attribute30                   => p_attribute30
  ,p_object_version_number         => l_object_version_number
  ,p_status_code                   => l_status_code
  ,p_duplicate_name_warning        => l_duplicate_name_warning
  ,p_no_life_events_warning        => l_no_life_events_warning
  ,p_update_library_objectives    => p_update_library_objectives  -- 8740021 bug fix
  ,p_automatic_approval_flag      => p_automatic_approval_flag
  );

  exception
   when hr_api.cannot_find_prog_unit then
   hr_api.cannot_find_prog_unit_error
    (p_module_name => 'CREATE_PERF_MGMT_PLAN',
     p_hook_type   => 'AP'
    );

  end;

  IF g_debug THEN hr_utility.set_location(l_proc, 50); END IF;

  --
  -- End of After Process User Hook call
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  --
  -- Set all IN OUT and OUT parameters with out values
  --
  p_plan_id                     := l_plan_id;
  p_status_code                 := l_status_code;
  p_object_version_number       := l_object_version_number;
  p_duplicate_name_warning      := l_duplicate_name_warning;
  p_no_life_events_warning      := l_no_life_events_warning;


  IF g_debug THEN

    hr_utility.trace(' ');
    hr_utility.trace('+--------------------------------'||
                     '---------------------------------');
    hr_utility.trace(' IN OUT / OUT PARAMETER          '||
                     ' VALUE');
    hr_utility.trace(' --------------------------------'||
                     '---------------------------------');
    hr_utility.trace('  p_plan_id                      '||
                        to_char(p_plan_id));
    hr_utility.trace('  p_object_version_number        '||
                        to_char(p_object_version_number));
    hr_utility.trace('  p_status_code                  '||
                        p_status_code);
    IF p_duplicate_name_warning THEN
      hr_utility.trace('  p_duplicate_name_warning       '||
                          'TRUE');
    ELSE
      hr_utility.trace('  p_duplicate_name_warning       '||
                          'FALSE');
    END IF;
    IF p_no_life_events_warning THEN
      hr_utility.trace('  p_no_life_events_warning       '||
                          'TRUE');
    ELSE
      hr_utility.trace('  p_no_life_events_warning       '||
                          'FALSE');
    END IF;
    hr_utility.trace(' --------------------------------'||
                     '---------------------------------');
    hr_utility.trace(' ');
    hr_utility.set_location(' Leaving:'||l_proc, 970);

  END IF;

exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_perf_mgmt_plan;
    --
    --  Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_plan_id           	  := null;
    p_object_version_number  	  := null;
    p_duplicate_name_warning 	  := l_duplicate_name_warning;
    p_no_life_events_warning      := l_no_life_events_warning;

    --
    hr_utility.set_location(' Leaving:'||l_proc, 980);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_perf_mgmt_plan;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_plan_id               	  := null;
    p_object_version_number  	  := null;
    p_duplicate_name_warning 	  := null;
    p_no_life_events_warning      := null;

    hr_utility.set_location(' Leaving:'||l_proc, 990);
    raise;

  end create_perf_mgmt_plan;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_perf_mgmt_plan >------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_perf_mgmt_plan
  (p_validate                      in   boolean    default false
  ,p_effective_date                in   date
  ,p_plan_id                       in   number
  ,p_plan_name                     in   varchar2   default hr_api.g_varchar2
  ,p_administrator_person_id       in   number     default hr_api.g_number
  ,p_previous_plan_id              in   number     default hr_api.g_number
  ,p_start_date                    in   date       default hr_api.g_date
  ,p_end_date                      in   date       default hr_api.g_date
  ,p_hierarchy_type_code           in   varchar2   default hr_api.g_varchar2
  ,p_supervisor_id                 in   number     default hr_api.g_number
  ,p_supervisor_assignment_id      in   number     default hr_api.g_number
  ,p_organization_structure_id     in   number     default hr_api.g_number
  ,p_org_structure_version_id      in   number     default hr_api.g_number
  ,p_top_organization_id           in   number     default hr_api.g_number
  ,p_position_structure_id         in   number     default hr_api.g_number
  ,p_pos_structure_version_id      in   number     default hr_api.g_number
  ,p_top_position_id               in   number     default hr_api.g_number
  ,p_hierarchy_levels              in   number     default hr_api.g_number
  ,p_automatic_enrollment_flag     in   varchar2   default hr_api.g_varchar2
  ,p_assignment_types_code         in   varchar2   default hr_api.g_varchar2
  ,p_primary_asg_only_flag         in   varchar2   default hr_api.g_varchar2
  ,p_include_obj_setting_flag      in   varchar2   default hr_api.g_varchar2
  ,p_obj_setting_start_date        in   date       default hr_api.g_date
  ,p_obj_setting_deadline          in   date       default hr_api.g_date
  ,p_obj_set_outside_period_flag   in   varchar2   default hr_api.g_varchar2
  ,p_method_code                   in   varchar2   default hr_api.g_varchar2
  ,p_notify_population_flag        in   varchar2   default hr_api.g_varchar2
  ,p_automatic_allocation_flag     in   varchar2   default hr_api.g_varchar2
  ,p_copy_past_objectives_flag     in   varchar2   default hr_api.g_varchar2
  ,p_sharing_alignment_task_flag   in   varchar2   default hr_api.g_varchar2
  ,p_include_appraisals_flag       in   varchar2   default hr_api.g_varchar2
  ,p_change_sc_status_flag  in   varchar2   default hr_api.g_varchar2
  ,p_attribute_category            in   varchar2   default hr_api.g_varchar2
  ,p_attribute1                    in   varchar2   default hr_api.g_varchar2
  ,p_attribute2                    in   varchar2   default hr_api.g_varchar2
  ,p_attribute3                    in   varchar2   default hr_api.g_varchar2
  ,p_attribute4                    in   varchar2   default hr_api.g_varchar2
  ,p_attribute5                    in   varchar2   default hr_api.g_varchar2
  ,p_attribute6                    in   varchar2   default hr_api.g_varchar2
  ,p_attribute7                    in   varchar2   default hr_api.g_varchar2
  ,p_attribute8                    in   varchar2   default hr_api.g_varchar2
  ,p_attribute9                    in   varchar2   default hr_api.g_varchar2
  ,p_attribute10                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute11                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute12                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute13                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute14                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute15                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute16                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute17                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute18                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute19                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute20                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute21                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute22                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute23                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute24                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute25                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute26                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute27                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute28                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute29                   in   varchar2   default hr_api.g_varchar2
  ,p_attribute30                   in   varchar2   default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy   number
  ,p_status_code                      out nocopy   varchar2
  ,p_duplicate_name_warning           out nocopy   boolean
  ,p_no_life_events_warning           out nocopy   boolean
  ,p_update_library_objectives in varchar2  default hr_api.g_varchar2     -- 8740021 bug fix
  ,p_automatic_approval_flag in varchar2  default hr_api.g_varchar2
  ) is

  --
  -- Declare cursors and local variables
  --
  --
  l_proc                       varchar2(72) := g_package||'update_perf_mgmt_plan';
  l_effective_date             date;
  l_start_date                 date;
  l_end_date                   date;
  l_obj_setting_start_date     date;
  l_obj_setting_deadline       date;
  l_object_version_number      number;
  l_status_code                varchar2(30);
  l_duplicate_name_warning     boolean := false;
  l_no_life_events_warning     boolean := false;


  begin

  IF g_debug THEN

    hr_utility.set_location('Entering:'|| l_proc, 10);

    hr_utility.trace(' ');
    hr_utility.trace(' --------------------------------'||
                     '---------------------------------');
    hr_utility.trace(' IN / IN OUT PARAMETER           '||
                     ' VALUE');
    hr_utility.trace(' --------------------------------'||
                     '+--------------------------------');
    hr_utility.trace('  p_effective_date                 '||
                        to_char(p_effective_date));
    hr_utility.trace('  p_plan_id                        '||
                        to_char(p_plan_id));
    hr_utility.trace('  p_object_version_number          '||
                        to_char(p_object_version_number));
    hr_utility.trace('  p_plan_name                      '||
                        p_plan_name);
    hr_utility.trace('  p_administrator_person_id        '||
                        to_char(p_administrator_person_id));
    hr_utility.trace('  p_previous_plan_id               '||
                        to_char(p_previous_plan_id));
    hr_utility.trace('  p_start_date                     '||
                        to_char(p_start_date));
    hr_utility.trace('  p_end_date                       '||
                        to_char(p_end_date));
    hr_utility.trace('  p_hierarchy_type_code            '||
                        p_hierarchy_type_code);
    hr_utility.trace('  p_supervisor_id                  '||
                        to_char(p_supervisor_id));
    hr_utility.trace('  p_supervisor_assignment_id       '||
                        to_char(p_supervisor_assignment_id));
    hr_utility.trace('  p_organization_structure_id      '||
                        to_char(p_organization_structure_id));
    hr_utility.trace('  p_org_structure_version_id       '||
                        to_char(p_org_structure_version_id));
    hr_utility.trace('  p_top_organization_id            '||
                        to_char(p_top_organization_id));
    hr_utility.trace('  p_position_structure_id          '||
                        to_char(p_position_structure_id));
    hr_utility.trace('  p_pos_structure_version_id       '||
                        to_char(p_pos_structure_version_id));
    hr_utility.trace('  p_top_position_id                '||
                        to_char(p_top_position_id));
    hr_utility.trace('  p_hierarchy_levels               '||
                        to_char(p_hierarchy_levels));
    hr_utility.trace('  p_automatic_enrollment_flag      '||
                        p_automatic_enrollment_flag);
    hr_utility.trace('  p_assignment_types_code          '||
                        p_assignment_types_code);
    hr_utility.trace('  p_primary_asg_only_flag          '||
                        p_primary_asg_only_flag);
    hr_utility.trace('  p_include_obj_setting_flag       '||
                        p_include_obj_setting_flag);
    hr_utility.trace('  p_obj_setting_start_date         '||
                        to_char(p_obj_setting_start_date));
    hr_utility.trace('  p_obj_setting_deadline           '||
                        to_char(p_obj_setting_deadline));
    hr_utility.trace('  p_obj_set_outside_period_flag    '||
                        p_obj_set_outside_period_flag);
    hr_utility.trace('  p_method_code                    '||
                        p_method_code);
    hr_utility.trace('  p_notify_population_flag         '||
                        p_notify_population_flag);
    hr_utility.trace('  p_automatic_allocation_flag      '||
                        p_automatic_allocation_flag);
    hr_utility.trace('  p_copy_past_objectives_flag      '||
                        p_copy_past_objectives_flag);
    hr_utility.trace('  p_sharing_alignment_task_flag    '||
                        p_sharing_alignment_task_flag);
    hr_utility.trace('  p_include_appraisals_flag        '||
                        p_include_appraisals_flag);
    hr_utility.trace('  p_change_sc_status_flag   '||
                        p_change_sc_status_flag);
    hr_utility.trace(' --------------------------------'||
                     '---------------------------------');
    hr_utility.trace(' ');

  END IF;

  --
  -- Issue a savepoint
  --
  savepoint update_perf_mgmt_plan;
  --
  -- Remember IN OUT parameter IN values
  --
  l_object_version_number := p_object_version_number;

  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date         := trunc(p_effective_date);
  l_start_date             := trunc(p_start_date);
  l_end_date               := trunc(p_end_date);
  l_obj_setting_start_date := trunc(p_obj_setting_start_date);
  l_obj_setting_deadline   := trunc(p_obj_setting_deadline);

  --
  -- Call Before Process User Hook
  --
  begin

   hr_perf_mgmt_plan_bk2.update_perf_mgmt_plan_b
  (p_effective_date                => l_effective_date
  ,p_plan_id                       => p_plan_id
  ,p_plan_name                     => p_plan_name
  ,p_administrator_person_id       => p_administrator_person_id
  ,p_previous_plan_id              => p_previous_plan_id
  ,p_start_date                    => l_start_date
  ,p_end_date                      => l_end_date
  ,p_hierarchy_type_code           => p_hierarchy_type_code
  ,p_supervisor_id                 => p_supervisor_id
  ,p_supervisor_assignment_id	   => p_supervisor_assignment_id
  ,p_organization_structure_id     => p_organization_structure_id
  ,p_org_structure_version_id      => p_org_structure_version_id
  ,p_top_organization_id           => p_top_organization_id
  ,p_position_structure_id         => p_position_structure_id
  ,p_pos_structure_version_id      => p_pos_structure_version_id
  ,p_top_position_id               => p_top_position_id
  ,p_hierarchy_levels              => p_hierarchy_levels
  ,p_automatic_enrollment_flag     => p_automatic_enrollment_flag
  ,p_assignment_types_code         => p_assignment_types_code
  ,p_primary_asg_only_flag         => p_primary_asg_only_flag
  ,p_include_obj_setting_flag      => p_include_obj_setting_flag
  ,p_obj_setting_start_date        => l_obj_setting_start_date
  ,p_obj_setting_deadline          => l_obj_setting_deadline
  ,p_obj_set_outside_period_flag   => p_obj_set_outside_period_flag
  ,p_method_code                   => p_method_code
  ,p_notify_population_flag        => p_notify_population_flag
  ,p_automatic_allocation_flag     => p_automatic_allocation_flag
  ,p_copy_past_objectives_flag     => p_copy_past_objectives_flag
  ,p_sharing_alignment_task_flag   => p_sharing_alignment_task_flag
  ,p_include_appraisals_flag       => p_include_appraisals_flag
  ,p_change_sc_status_flag  => p_change_sc_status_flag
  ,p_attribute_category            => p_attribute_category
  ,p_attribute1                    => p_attribute1
  ,p_attribute2                    => p_attribute2
  ,p_attribute3                    => p_attribute3
  ,p_attribute4                    => p_attribute4
  ,p_attribute5                    => p_attribute5
  ,p_attribute6                    => p_attribute6
  ,p_attribute7                    => p_attribute7
  ,p_attribute8                    => p_attribute8
  ,p_attribute9                    => p_attribute9
  ,p_attribute10                   => p_attribute10
  ,p_attribute11                   => p_attribute11
  ,p_attribute12                   => p_attribute12
  ,p_attribute13                   => p_attribute13
  ,p_attribute14                   => p_attribute14
  ,p_attribute15                   => p_attribute15
  ,p_attribute16                   => p_attribute16
  ,p_attribute17                   => p_attribute17
  ,p_attribute18                   => p_attribute18
  ,p_attribute19                   => p_attribute19
  ,p_attribute20                   => p_attribute20
  ,p_attribute21                   => p_attribute21
  ,p_attribute22                   => p_attribute22
  ,p_attribute23                   => p_attribute23
  ,p_attribute24                   => p_attribute24
  ,p_attribute25                   => p_attribute25
  ,p_attribute26                   => p_attribute26
  ,p_attribute27                   => p_attribute27
  ,p_attribute28                   => p_attribute28
  ,p_attribute29                   => p_attribute29
  ,p_attribute30                   => p_attribute30
  ,p_object_version_number         => l_object_version_number
  ,p_update_library_objectives    => p_update_library_objectives  -- 8740021 bug fix
  ,p_automatic_approval_flag      => p_automatic_approval_flag
  );

  exception
    when hr_api.cannot_find_prog_unit then
    hr_api.cannot_find_prog_unit_error
     (p_module_name => 'UPDATE_PERF_MGMT_PLAN',
      p_hook_type   => 'BP'
     );

  end;

  --
  -- Process Logic
  --
  IF g_debug THEN hr_utility.set_location(l_proc, 30); END IF;

  --
  -- Change the plan's status to updated if it's currently
  -- published.
  --
  l_status_code := per_pmp_bus.return_status_code(p_plan_id);
  IF l_status_code = 'PUBLISHED' THEN
    l_status_code := 'UPDATED';
  END IF;

  --
  -- Call the row handler update
  --
  per_pmp_upd.upd
  (p_effective_date                => l_effective_date
  ,p_plan_id		           => p_plan_id
  ,p_object_version_number         => l_object_version_number
  ,p_plan_name                     => p_plan_name
  ,p_administrator_person_id       => p_administrator_person_id
  ,p_previous_plan_id              => p_previous_plan_id
  ,p_start_date                    => l_start_date
  ,p_end_date                      => l_end_date
  ,p_hierarchy_type_code           => p_hierarchy_type_code
  ,p_supervisor_id                 => p_supervisor_id
  ,p_supervisor_assignment_id      => p_supervisor_assignment_id
  ,p_organization_structure_id     => p_organization_structure_id
  ,p_org_structure_version_id      => p_org_structure_version_id
  ,p_top_organization_id           => p_top_organization_id
  ,p_position_structure_id         => p_position_structure_id
  ,p_pos_structure_version_id      => p_pos_structure_version_id
  ,p_top_position_id               => p_top_position_id
  ,p_hierarchy_levels              => p_hierarchy_levels
  ,p_automatic_enrollment_flag     => p_automatic_enrollment_flag
  ,p_assignment_types_code         => p_assignment_types_code
  ,p_primary_asg_only_flag         => p_primary_asg_only_flag
  ,p_include_obj_setting_flag      => p_include_obj_setting_flag
  ,p_obj_setting_start_date        => l_obj_setting_start_date
  ,p_obj_setting_deadline          => l_obj_setting_deadline
  ,p_obj_set_outside_period_flag   => p_obj_set_outside_period_flag
  ,p_method_code                   => p_method_code
  ,p_notify_population_flag        => p_notify_population_flag
  ,p_automatic_allocation_flag     => p_automatic_allocation_flag
  ,p_copy_past_objectives_flag     => p_copy_past_objectives_flag
  ,p_sharing_alignment_task_flag   => p_sharing_alignment_task_flag
  ,p_include_appraisals_flag       => p_include_appraisals_flag
  ,p_change_sc_status_flag  => p_change_sc_status_flag
  ,p_attribute_category            => p_attribute_category
  ,p_attribute1                    => p_attribute1
  ,p_attribute2                    => p_attribute2
  ,p_attribute3                    => p_attribute3
  ,p_attribute4                    => p_attribute4
  ,p_attribute5                    => p_attribute5
  ,p_attribute6                    => p_attribute6
  ,p_attribute7                    => p_attribute7
  ,p_attribute8                    => p_attribute8
  ,p_attribute9                    => p_attribute9
  ,p_attribute10                   => p_attribute10
  ,p_attribute11                   => p_attribute11
  ,p_attribute12                   => p_attribute12
  ,p_attribute13                   => p_attribute13
  ,p_attribute14                   => p_attribute14
  ,p_attribute15                   => p_attribute15
  ,p_attribute16                   => p_attribute16
  ,p_attribute17                   => p_attribute17
  ,p_attribute18                   => p_attribute18
  ,p_attribute19                   => p_attribute19
  ,p_attribute20                   => p_attribute20
  ,p_attribute21                   => p_attribute21
  ,p_attribute22                   => p_attribute22
  ,p_attribute23                   => p_attribute23
  ,p_attribute24                   => p_attribute24
  ,p_attribute25                   => p_attribute25
  ,p_attribute26                   => p_attribute26
  ,p_attribute27                   => p_attribute27
  ,p_attribute28                   => p_attribute28
  ,p_attribute29                   => p_attribute29
  ,p_attribute30                   => p_attribute30
  ,p_status_code                   => l_status_code
  ,p_duplicate_name_warning        => l_duplicate_name_warning
  ,p_no_life_events_warning        => l_no_life_events_warning
  ,p_update_library_objectives    => p_update_library_objectives  -- 8740021 bug fix
  ,p_automatic_approval_flag      => p_automatic_approval_flag
  );

  IF g_debug THEN hr_utility.set_location(l_proc, 40); END IF;
  --
  -- Call After Process User Hook
  --
  begin
  hr_perf_mgmt_plan_bk2.update_perf_mgmt_plan_a
  (p_effective_date                => l_effective_date
  ,p_plan_id                       => p_plan_id
  ,p_plan_name                     => p_plan_name
  ,p_administrator_person_id       => p_administrator_person_id
  ,p_previous_plan_id              => p_previous_plan_id
  ,p_start_date                    => l_start_date
  ,p_end_date                      => l_end_date
  ,p_hierarchy_type_code           => p_hierarchy_type_code
  ,p_supervisor_id                 => p_supervisor_id
  ,p_supervisor_assignment_id	   => p_supervisor_assignment_id
  ,p_organization_structure_id     => p_organization_structure_id
  ,p_org_structure_version_id      => p_org_structure_version_id
  ,p_top_organization_id           => p_top_organization_id
  ,p_position_structure_id         => p_position_structure_id
  ,p_pos_structure_version_id      => p_pos_structure_version_id
  ,p_top_position_id               => p_top_position_id
  ,p_hierarchy_levels              => p_hierarchy_levels
  ,p_automatic_enrollment_flag     => p_automatic_enrollment_flag
  ,p_assignment_types_code         => p_assignment_types_code
  ,p_primary_asg_only_flag         => p_primary_asg_only_flag
  ,p_include_obj_setting_flag      => p_include_obj_setting_flag
  ,p_obj_setting_start_date        => l_obj_setting_start_date
  ,p_obj_setting_deadline          => l_obj_setting_deadline
  ,p_obj_set_outside_period_flag   => p_obj_set_outside_period_flag
  ,p_method_code                   => p_method_code
  ,p_notify_population_flag        => p_notify_population_flag
  ,p_automatic_allocation_flag     => p_automatic_allocation_flag
  ,p_copy_past_objectives_flag     => p_copy_past_objectives_flag
  ,p_sharing_alignment_task_flag   => p_sharing_alignment_task_flag
  ,p_include_appraisals_flag       => p_include_appraisals_flag
  ,p_change_sc_status_flag  => p_change_sc_status_flag
  ,p_attribute_category            => p_attribute_category
  ,p_attribute1                    => p_attribute1
  ,p_attribute2                    => p_attribute2
  ,p_attribute3                    => p_attribute3
  ,p_attribute4                    => p_attribute4
  ,p_attribute5                    => p_attribute5
  ,p_attribute6                    => p_attribute6
  ,p_attribute7                    => p_attribute7
  ,p_attribute8                    => p_attribute8
  ,p_attribute9                    => p_attribute9
  ,p_attribute10                   => p_attribute10
  ,p_attribute11                   => p_attribute11
  ,p_attribute12                   => p_attribute12
  ,p_attribute13                   => p_attribute13
  ,p_attribute14                   => p_attribute14
  ,p_attribute15                   => p_attribute15
  ,p_attribute16                   => p_attribute16
  ,p_attribute17                   => p_attribute17
  ,p_attribute18                   => p_attribute18
  ,p_attribute19                   => p_attribute19
  ,p_attribute20                   => p_attribute20
  ,p_attribute21                   => p_attribute21
  ,p_attribute22                   => p_attribute22
  ,p_attribute23                   => p_attribute23
  ,p_attribute24                   => p_attribute24
  ,p_attribute25                   => p_attribute25
  ,p_attribute26                   => p_attribute26
  ,p_attribute27                   => p_attribute27
  ,p_attribute28                   => p_attribute28
  ,p_attribute29                   => p_attribute29
  ,p_attribute30                   => p_attribute30
  ,p_object_version_number         => l_object_version_number
  ,p_status_code                   => l_status_code
  ,p_duplicate_name_warning        => l_duplicate_name_warning
  ,p_no_life_events_warning        => l_no_life_events_warning
  ,p_update_library_objectives    => p_update_library_objectives  -- 8740021 bug fix
  ,p_automatic_approval_flag      => p_automatic_approval_flag
  );
  exception
   when hr_api.cannot_find_prog_unit then
     hr_api.cannot_find_prog_unit_error
      (p_module_name => 'UPDATE_PERF_MGMT_PLAN',
       p_hook_type   => 'AP'
      );
  end;

  IF g_debug THEN hr_utility.set_location(l_proc, 50); END IF;

  --
  -- End of After Process User Hook call
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;

  --
  -- Set all IN OUT and OUT parameters with out values
  --
  p_object_version_number         := l_object_version_number;
  p_status_code                   := l_status_code;
  p_duplicate_name_warning        := l_duplicate_name_warning;
  p_no_life_events_warning        := l_no_life_events_warning;

  IF g_debug THEN

    hr_utility.trace(' ');
    hr_utility.trace(' --------------------------------'||
                     '---------------------------------');
    hr_utility.trace(' IN OUT / OUT PARAMETER          '||
                     ' VALUE');
    hr_utility.trace(' --------------------------------'||
                     '+--------------------------------');
    hr_utility.trace('  p_object_version_number        '||
                        to_char(p_object_version_number));
    hr_utility.trace('  p_status_code                  '||
                        p_status_code);
    IF p_duplicate_name_warning THEN
      hr_utility.trace('  p_duplicate_name_warning       '||
                          'TRUE');
    ELSE
      hr_utility.trace('  p_duplicate_name_warning       '||
                          'FALSE');
    END IF;
    IF p_no_life_events_warning THEN
      hr_utility.trace('  p_no_life_events_warning       '||
                          'TRUE');
    ELSE
      hr_utility.trace('  p_no_life_events_warning       '||
                          'FALSE');
    END IF;
    hr_utility.trace(' --------------------------------'||
                     '---------------------------------');
    hr_utility.trace(' ');
    hr_utility.set_location(' Leaving:'||l_proc, 970);

  END IF;

  exception
    when hr_api.validate_enabled then
      --
      -- As the Validate_Enabled exception has been raised
      -- we must rollback to the savepoint
      --
      ROLLBACK TO update_perf_mgmt_plan;
      --
      -- Reset IN OUT parameters and set OUT parameters
      -- (Any key or derived arguments must be set to null
      -- when validation only mode is being used.)
      --
      p_object_version_number         := null;
      p_status_code                   := l_status_code;
      p_duplicate_name_warning        := l_duplicate_name_warning;
      p_no_life_events_warning        := l_no_life_events_warning;
      --
      hr_utility.set_location(' Leaving:'||l_proc, 980);
      --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_perf_mgmt_plan;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_object_version_number       := null;
    p_status_code                 := null;
    p_duplicate_name_warning      := null;
    p_no_life_events_warning      := null;

    hr_utility.set_location(' Leaving:'||l_proc, 990);
    raise;

end update_perf_mgmt_plan;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_perf_mgmt_plan >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_perf_mgmt_plan
  (p_validate                 in   boolean         default false
  ,p_plan_id                  in   number
  ,p_object_version_number    in   number
  ) is

  --
  -- Declare cursors and local variables
  --
     l_proc                  varchar2(72) := g_package||'delete_perf_mgmt_plan';
  --

  begin

  IF g_debug THEN

    hr_utility.set_location('Entering:'|| l_proc, 10);

    hr_utility.trace(' ');
    hr_utility.trace(' --------------------------------'||
                     '---------------------------------');
    hr_utility.trace(' IN / IN OUT PARAMETER           '||
                     ' VALUE');
    hr_utility.trace(' --------------------------------'||
                     '+--------------------------------');
    hr_utility.trace('  p_plan_id                      '||
                        to_char(p_plan_id));
    hr_utility.trace('  p_object_version_number        '||
                        to_char(p_object_version_number));
    hr_utility.trace(' --------------------------------'||
                     '---------------------------------');
    hr_utility.trace(' ');

  END IF;

  --
  -- Issue a savepoint
  --
     savepoint delete_perf_mgmt_plan;
  --
  -- Call Before Process User Hook
  --
  begin

    hr_perf_mgmt_plan_bk3.delete_perf_mgmt_plan_b
    (p_plan_id                => p_plan_id
    ,p_object_version_number  => p_object_version_number
    );
  exception
   when hr_api.cannot_find_prog_unit then
     hr_api.cannot_find_prog_unit_error
      (p_module_name => 'DELETE_PERF_MGMT_PLAN',
       p_hook_type   => 'BP'
      );
  end;

  --
  -- End of Before Process User Hook call
  --
     hr_utility.set_location(l_proc, 7);
  --
  -- Process Logic - Delete Plan
  --

   per_pmp_del.del
    (p_plan_id           => p_plan_id
    ,p_object_version_number  => p_object_version_number
    );

  hr_utility.set_location(l_proc, 8);
  --
  -- Call After Process User Hook
  --
  begin
  hr_perf_mgmt_plan_bk3.delete_perf_mgmt_plan_a
    (p_plan_id                => p_plan_id
    ,p_object_version_number  => p_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
     hr_api.cannot_find_prog_unit_error
      (p_module_name => 'DELETE_PERF_MGMT_PLAN',
       p_hook_type   => 'AP'
      );
  end;

  IF g_debug THEN hr_utility.set_location(l_proc, 40); END IF;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;

  --
  -- Pipe the main IN OUT / OUT parameters for ease of debugging.
  --
  IF g_debug THEN hr_utility.set_location(' Leaving:'||l_proc, 970); END IF;

exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_perf_mgmt_plan;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 980);

  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_perf_mgmt_plan;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    hr_utility.set_location(' Leaving:'||l_proc, 990);
    raise;

 end delete_perf_mgmt_plan;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------------< publish_plan >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure publish_plan
  (p_validate                      in   boolean    default false
  ,p_effective_date                in   date
  ,p_plan_id                       in   number
  ,p_object_version_number         in out nocopy   number
  ) is

  --
  -- Declare local variables
  --
     l_proc                  varchar2(72) := g_package||'publish_plan';
     l_what_if               varchar2(1);
     l_object_version_number number;

  --

  begin

  IF g_debug THEN

    hr_utility.set_location('Entering:'|| l_proc, 10);

    hr_utility.trace(' ');
    hr_utility.trace(' --------------------------------'||
                     '---------------------------------');
    hr_utility.trace(' IN / IN OUT PARAMETER           '||
                     ' VALUE');
    hr_utility.trace(' --------------------------------'||
                     '+--------------------------------');
    hr_utility.trace('  p_plan_id                      '||
                        to_char(p_plan_id));
    hr_utility.trace('  p_object_version_number        '||
                        to_char(p_object_version_number));
    hr_utility.trace(' --------------------------------'||
                     '---------------------------------');
    hr_utility.trace(' ');

  END IF;

  --
  -- Issue a savepoint
  --
     savepoint publish_plan;
  --
  -- Remember IN OUT parameter IN values
  --
  l_object_version_number := p_object_version_number;


  --
  -- Call Before Process User Hook
  --
  begin

    hr_perf_mgmt_plan_bk4.publish_plan_b
    (p_effective_date         => p_effective_date
    ,p_plan_id                => p_plan_id
    ,p_object_version_number  => l_object_version_number
    );
  exception
   when hr_api.cannot_find_prog_unit then
     hr_api.cannot_find_prog_unit_error
      (p_module_name => 'PUBLISH',
       p_hook_type   => 'BP'
      );
  end;

  --
  -- End of Before Process User Hook call
  --
     hr_utility.set_location(l_proc, 7);
  --
  -- What if mode
  --
   if (p_validate) then
     l_what_if := 'Y';
   else
     l_what_if := 'N';
   end if;
  --
  -- Process Logic - Publish Plan
  --
   hr_perf_mgmt_plan_internal.publish_plan
    (p_effective_date            => p_effective_date
    ,p_plan_id                   => p_plan_id
    ,p_object_version_number     => l_object_version_number
    ,p_reverse_mode              => 'N'
    ,p_what_if                   => l_what_if
    );

  hr_utility.set_location(l_proc, 8);
  --
  -- Call After Process User Hook
  --
  begin
  hr_perf_mgmt_plan_bk4.publish_plan_a
    (p_effective_date         => p_effective_date
    ,p_plan_id                => p_plan_id
    ,p_object_version_number  => l_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
     hr_api.cannot_find_prog_unit_error
      (p_module_name => 'PUBLISH_A',
       p_hook_type   => 'AP'
      );
  end;

  IF g_debug THEN hr_utility.set_location(l_proc, 40); END IF;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;

  --
  -- Set all IN OUT and OUT parameters with out values
  --
  p_object_version_number         := l_object_version_number;

  --
  -- Pipe the main IN OUT / OUT parameters for ease of debugging.
  --
  IF g_debug THEN hr_utility.set_location(' Leaving:'||l_proc, 970); END IF;

exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to publish_plan;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 980);

  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to publish_plan;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    hr_utility.set_location(' Leaving:'||l_proc, 990);
    raise;

 end publish_plan;

--
-- ----------------------------------------------------------------------------
-- |----------------------------< reverse_publish_plan >----------------------|
-- ----------------------------------------------------------------------------
--
procedure reverse_publish_plan
  (p_validate                      in   boolean    default false
  ,p_plan_id                       in   number
  ,p_object_version_number         in out nocopy   number
  ) is

  --
  -- Declare cursors and local variables
  --
     l_proc                  varchar2(72) := g_package||'reverse_publish_plan';
     l_what_if               varchar2(1);
     l_object_version_number number;
     l_effective_date        date;
  --

 begin

  IF g_debug THEN

    hr_utility.set_location('Entering:'|| l_proc, 10);

    hr_utility.trace(' ');
    hr_utility.trace(' --------------------------------'||
                     '---------------------------------');
    hr_utility.trace(' IN / IN OUT PARAMETER           '||
                     ' VALUE');
    hr_utility.trace(' --------------------------------'||
                     '+--------------------------------');
    hr_utility.trace('  p_plan_id                      '||
                        to_char(p_plan_id));
    hr_utility.trace('  p_object_version_number        '||
                        to_char(p_object_version_number));
    hr_utility.trace(' --------------------------------'||
                     '---------------------------------');
    hr_utility.trace(' ');

  END IF;

  --
  -- Issue a savepoint
  --
     savepoint reverse_publish_plan;
  --
  -- Remember IN OUT parameter IN values
  --
  l_object_version_number := p_object_version_number;

  --
  -- Call Before Process User Hook
  --
  begin

    hr_perf_mgmt_plan_bk5.reverse_publish_plan_b
    (p_plan_id                => p_plan_id
    ,p_object_version_number  => l_object_version_number
    );
  exception
   when hr_api.cannot_find_prog_unit then
     hr_api.cannot_find_prog_unit_error
      (p_module_name => 'REVERSE_PUBLISH',
       p_hook_type   => 'BP'
      );
  end;

  --
  -- End of Before Process User Hook call
  --
     hr_utility.set_location(l_proc, 7);
  --
  -- What if mode
  --
   if (p_validate) then
     l_what_if := 'Y';
   else
     l_what_if := 'N';
   end if;
  --
  -- Process Logic - Publish Plan
  --
   hr_perf_mgmt_plan_internal.publish_plan
    (p_effective_date            => l_effective_date
    ,p_plan_id                   => p_plan_id
    ,p_object_version_number     => l_object_version_number
    ,p_reverse_mode              => 'Y'
    ,p_what_if                   => l_what_if);



  hr_utility.set_location(l_proc, 8);
  --
  -- Call After Process User Hook
  --
  begin
  hr_perf_mgmt_plan_bk5.reverse_publish_plan_a
    (p_plan_id                => p_plan_id
    ,p_object_version_number  => l_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
     hr_api.cannot_find_prog_unit_error
      (p_module_name => 'REVERSE_PUBLISH_A',
       p_hook_type   => 'AP'
      );
  end;

  IF g_debug THEN hr_utility.set_location(l_proc, 40); END IF;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;

  --
  -- Set all IN OUT and OUT parameters with out values
  --
  p_object_version_number         := l_object_version_number;

  --
  -- Pipe the main IN OUT / OUT parameters for ease of debugging.
  --
  IF g_debug THEN hr_utility.set_location(' Leaving:'||l_proc, 970); END IF;

exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to reverse_publish_plan;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 980);

  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to reverse_publish_plan;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    hr_utility.set_location(' Leaving:'||l_proc, 990);
    raise;

 end reverse_publish_plan;


end HR_PERF_MGMT_PLAN_API;

/
