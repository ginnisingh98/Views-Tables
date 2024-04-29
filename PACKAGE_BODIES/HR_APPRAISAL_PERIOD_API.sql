--------------------------------------------------------
--  DDL for Package Body HR_APPRAISAL_PERIOD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_APPRAISAL_PERIOD_API" as
/* $Header: pepmaapi.pkb 120.3.12010000.2 2009/10/23 13:38:58 schowdhu ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_appraisal_period_api.';
g_debug    boolean      := hr_utility.debug_enabled;

--
-- ----------------------------------------------------------------------------
-- |--------------------------< set_plan_status >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure set_plan_status
  (p_plan_id                       in     number
  ,p_effective_date                in     date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                   varchar2(72) := g_package||'set_plan_status';
  l_ovn                    number;
  l_status_code            per_perf_mgmt_plans.status_code%TYPE;
  l_dummy                  boolean;

begin

  IF g_debug THEN hr_utility.set_location('Entering:'|| l_proc, 10); END IF;

  --
  -- Only attempt to set the plan's status if the procedure has been
  -- called correctly.
  --
  IF p_plan_id IS NOT NULL THEN

    IF per_pmp_bus.return_status_code(p_plan_id) = 'PUBLISHED' THEN
      --
      -- Call the plan update row-handler.
      --
      IF g_debug THEN hr_utility.set_location(l_proc, 30); END IF;

      l_ovn         := per_pmp_bus.return_ovn(p_plan_id);
      l_status_code := 'UPDATED';

      per_pmp_upd.upd
        (p_plan_id                => p_plan_id
        ,p_effective_date         => p_effective_date
        ,p_object_version_number  => l_ovn
        ,p_status_code            => l_status_code
        ,p_duplicate_name_warning => l_dummy
        ,p_no_life_events_warning => l_dummy);
    END IF;
  END IF;

  IF g_debug THEN hr_utility.set_location('Leaving:'|| l_proc, 980); END IF;

end set_plan_status;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_appraisal_period >---------------------|
-- ----------------------------------------------------------------------------
--
procedure create_appraisal_period
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_plan_id                       in     number
  ,p_appraisal_template_id         in     number
  ,p_start_date                    in     date
  ,p_end_date                      in     date
  ,p_task_start_date               in     date
  ,p_task_end_date                 in     date
  ,p_initiator_code                in     varchar2 default null
  ,p_appraisal_system_type         in     varchar2 default null
  ,p_appraisal_type                in     varchar2 default null
  ,p_appraisal_assmt_status        in     varchar2 default null
  ,p_auto_conc_process             in     varchar2 default null
  ,p_days_before_task_st_dt        in     number   default null
  ,p_participation_type          in varchar2  default null
  ,p_questionnaire_template_id   in number  default null
  ,p_attribute_category            in     varchar2 default null
  ,p_attribute1                    in     varchar2 default null
  ,p_attribute2                    in     varchar2 default null
  ,p_attribute3                    in     varchar2 default null
  ,p_attribute4                    in     varchar2 default null
  ,p_attribute5                    in     varchar2 default null
  ,p_attribute6                    in     varchar2 default null
  ,p_attribute7                    in     varchar2 default null
  ,p_attribute8                    in     varchar2 default null
  ,p_attribute9                    in     varchar2 default null
  ,p_attribute10                   in     varchar2 default null
  ,p_attribute11                   in     varchar2 default null
  ,p_attribute12                   in     varchar2 default null
  ,p_attribute13                   in     varchar2 default null
  ,p_attribute14                   in     varchar2 default null
  ,p_attribute15                   in     varchar2 default null
  ,p_attribute16                   in     varchar2 default null
  ,p_attribute17                   in     varchar2 default null
  ,p_attribute18                   in     varchar2 default null
  ,p_attribute19                   in     varchar2 default null
  ,p_attribute20                   in     varchar2 default null
  ,p_attribute21                   in     varchar2 default null
  ,p_attribute22                   in     varchar2 default null
  ,p_attribute23                   in     varchar2 default null
  ,p_attribute24                   in     varchar2 default null
  ,p_attribute25                   in     varchar2 default null
  ,p_attribute26                   in     varchar2 default null
  ,p_attribute27                   in     varchar2 default null
  ,p_attribute28                   in     varchar2 default null
  ,p_attribute29                   in     varchar2 default null
  ,p_attribute30                   in     varchar2 default null
  ,p_appraisal_period_id              out nocopy   number
  ,p_object_version_number            out nocopy   number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                   varchar2(72) := g_package||'create_appraisal_period';
  l_effective_date         date;
  l_start_date             date;
  l_end_date               date;
  l_task_start_date        date;
  l_task_end_date          date;
  l_appraisal_period_id    number;
  l_object_version_number  number;

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
    hr_utility.trace('  p_plan_id                        '||
                        to_char(p_plan_id));
    hr_utility.trace('  p_appraisal_template_id          '||
                        to_char(p_appraisal_template_id));
    hr_utility.trace('  p_start_date                     '||
                        to_char(p_start_date));
    hr_utility.trace('  p_end_date                       '||
                        to_char(p_end_date));
    hr_utility.trace('  p_task_start_date                '||
                        to_char(p_task_start_date));
    hr_utility.trace('  p_task_end_date                  '||
                        to_char(p_task_end_date));
    hr_utility.trace('  p_initiator_code                 '||
                        p_initiator_code);
    hr_utility.trace(' --------------------------------'||
                     '+--------------------------------');
    hr_utility.trace('  p_effective_date                 '||
                        to_char(p_effective_date));
    hr_utility.trace(' --------------------------------'||
                     '---------------------------------');
    hr_utility.trace(' ');

  END IF;

  --
  -- Issue a savepoint
  --
  savepoint create_appraisal_period;

  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date  := trunc(p_effective_date);
  l_start_date      := trunc(p_start_date);
  l_end_date        := trunc(p_end_date);
  l_task_start_date := trunc(p_task_start_date);
  l_task_end_date   := trunc(p_task_end_date);

  --
  -- Call Before Process User Hook
  --
  begin
    hr_appraisal_period_bk1.create_appraisal_period_b
      (p_effective_date                => l_effective_date
      ,p_plan_id                       => p_plan_id
      ,p_appraisal_template_id         => p_appraisal_template_id
      ,p_start_date                    => l_start_date
      ,p_end_date                      => l_end_date
      ,p_task_start_date               => l_task_start_date
      ,p_task_end_date                 => l_task_end_date
      ,p_initiator_code                => p_initiator_code
      ,p_appraisal_system_type         => p_appraisal_system_type
      ,p_appraisal_type                => p_appraisal_type
      ,p_appraisal_assmt_status        => p_appraisal_assmt_status
      ,p_auto_conc_process             => p_auto_conc_process
      ,p_days_before_task_st_dt        => p_days_before_task_st_dt
      ,p_participation_type        => p_participation_type
      ,p_questionnaire_template_id        => p_questionnaire_template_id
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
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_APPRAISAL_PERIOD'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --
  IF g_debug THEN hr_utility.set_location(l_proc, 30); END IF;

  per_pma_ins.ins
    (p_effective_date                => l_effective_date
    ,p_plan_id                       => p_plan_id
    ,p_appraisal_template_id         => p_appraisal_template_id
    ,p_start_date                    => l_start_date
    ,p_end_date                      => l_end_date
    ,p_task_start_date               => l_task_start_date
    ,p_task_end_date                 => l_task_end_date
    ,p_initiator_code                => p_initiator_code
    ,p_appraisal_system_type         => p_appraisal_system_type
    ,p_appraisal_type                => p_appraisal_type
    ,p_appraisal_assmt_status        => p_appraisal_assmt_status
    ,p_auto_conc_process             => p_auto_conc_process
    ,p_days_before_task_st_dt        => p_days_before_task_st_dt
    ,p_participation_type        => p_participation_type
    ,p_questionnaire_template_id        => p_questionnaire_template_id
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
    ,p_appraisal_period_id           => l_appraisal_period_id
    ,p_object_version_number         => l_object_version_number
    );

  --
  -- Call After Process User Hook
  --
  begin
    hr_appraisal_period_bk1.create_appraisal_period_a
      (p_effective_date                => l_effective_date
      ,p_plan_id                       => p_plan_id
      ,p_appraisal_template_id         => p_appraisal_template_id
      ,p_start_date                    => l_start_date
      ,p_end_date                      => l_end_date
      ,p_task_start_date               => l_task_start_date
      ,p_task_end_date                 => l_task_end_date
      ,p_initiator_code                => p_initiator_code
      ,p_appraisal_system_type         => p_appraisal_system_type
      ,p_appraisal_type                => p_appraisal_type
      ,p_appraisal_assmt_status        => p_appraisal_assmt_status
      ,p_auto_conc_process             => p_auto_conc_process
      ,p_days_before_task_st_dt        => p_days_before_task_st_dt
      ,p_participation_type        => p_participation_type
      ,p_questionnaire_template_id        => p_questionnaire_template_id
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
      ,p_appraisal_period_id           => l_appraisal_period_id
      ,p_object_version_number         => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_APPRAISAL_PERIOD'
        ,p_hook_type   => 'AP'
        );
  end;

  --
  -- Update the plan's status to Updated if the plan is already
  -- published.
  --
  set_plan_status(p_plan_id,p_start_date);


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
  p_appraisal_period_id    := l_appraisal_period_id;
  p_object_version_number  := l_object_version_number;

  --
  -- Pipe the main IN OUT / OUT parameters for ease of debugging.
  --
  IF g_debug THEN

    hr_utility.trace(' ');
    hr_utility.trace(' --------------------------------'||
                     '---------------------------------');
    hr_utility.trace(' IN OUT / OUT PARAMETER          '||
                     ' VALUE');
    hr_utility.trace(' --------------------------------'||
                     '+--------------------------------');
    hr_utility.trace('  p_appraisal_period_id          '||
                        to_char(p_appraisal_period_id));
    hr_utility.trace('  p_object_version_number        '||
                        to_char(p_object_version_number));
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
    rollback to create_appraisal_period;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_appraisal_period_id    := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 980);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_appraisal_period;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_appraisal_period_id    := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 990);
    raise;
end create_appraisal_period;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_appraisal_period >---------------------|
-- ----------------------------------------------------------------------------
--
procedure update_appraisal_period
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_appraisal_period_id           in     number
  ,p_object_version_number         in out nocopy   number
  ,p_start_date                    in     date     default hr_api.g_date
  ,p_end_date                      in     date     default hr_api.g_date
  ,p_task_start_date               in     date     default hr_api.g_date
  ,p_task_end_date                 in     date     default hr_api.g_date
  ,p_initiator_code                in     varchar2 default hr_api.g_varchar2
  ,p_appraisal_system_type         in     varchar2 default hr_api.g_varchar2
  ,p_appraisal_type                in     varchar2 default hr_api.g_varchar2
  ,p_appraisal_assmt_status        in     varchar2 default hr_api.g_varchar2
  ,p_auto_conc_process             in     varchar2 default hr_api.g_varchar2
  ,p_days_before_task_st_dt        in     number   default hr_api.g_number
  ,p_participation_type        in     varchar2   default hr_api.g_varchar2
  ,p_questionnaire_template_id        in     number   default hr_api.g_number
  ,p_attribute_category            in     varchar2 default hr_api.g_varchar2
  ,p_attribute1                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute2                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute3                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute4                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute5                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute6                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute7                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute8                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute9                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute10                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute11                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute12                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute13                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute14                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute15                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute16                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute17                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute18                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute19                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute20                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute21                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute22                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute23                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute24                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute25                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute26                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute27                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute28                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute29                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute30                   in     varchar2 default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_effective_date         date;
  l_proc                   varchar2(72) := g_package||'update_appraisal_period';
  l_start_date             date;
  l_end_date               date;
  l_task_start_date        date;
  l_task_end_date          date;
  l_object_version_number  number := p_object_version_number;

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
    hr_utility.trace('  p_appraisal_period_id            '||
                        to_char(p_appraisal_period_id));
    hr_utility.trace('  p_object_version_number          '||
                        to_char(p_object_version_number));
    hr_utility.trace('  p_start_date                     '||
                        to_char(p_start_date));
    hr_utility.trace('  p_end_date                       '||
                        to_char(p_end_date));
    hr_utility.trace('  p_task_start_date                '||
                        to_char(p_task_start_date));
    hr_utility.trace('  p_task_end_date                  '||
                        to_char(p_task_end_date));
    hr_utility.trace('  p_initiator_code                 '||
                        p_initiator_code);
    hr_utility.trace('  p_effective_date                 '||
                        to_char(p_effective_date));
    hr_utility.trace(' --------------------------------'||
                     '---------------------------------');
    hr_utility.trace(' ');

  END IF;

  --
  -- Issue a savepoint
  --
  savepoint update_appraisal_period;

  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date         := trunc(p_effective_date);
  l_start_date      := trunc(p_start_date);
  l_end_date        := trunc(p_end_date);
  l_task_start_date := trunc(p_task_start_date);
  l_task_end_date   := trunc(p_task_end_date);

  --
  -- Call Before Process User Hook
  --
  begin
    hr_appraisal_period_bk2.update_appraisal_period_b
      (p_effective_date                => l_effective_date
      ,p_appraisal_period_id           => p_appraisal_period_id
      ,p_object_version_number         => l_object_version_number
      ,p_start_date                    => l_start_date
      ,p_end_date                      => l_end_date
      ,p_task_start_date               => l_task_start_date
      ,p_task_end_date                 => l_task_end_date
      ,p_initiator_code                => p_initiator_code
      ,p_appraisal_system_type         => p_appraisal_system_type
      ,p_appraisal_type                => p_appraisal_type
      ,p_appraisal_assmt_status        => p_appraisal_assmt_status
      ,p_auto_conc_process             => p_auto_conc_process
      ,p_days_before_task_st_dt        => p_days_before_task_st_dt
      ,p_participation_type        => p_participation_type
      ,p_questionnaire_template_id        => p_questionnaire_template_id
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
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_APPRAISAL_PERIOD'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --
  IF g_debug THEN hr_utility.set_location(l_proc, 30); END IF;

  per_pma_upd.upd
    (p_effective_date                => l_effective_date
    ,p_appraisal_period_id           => p_appraisal_period_id
    ,p_object_version_number         => l_object_version_number
    ,p_start_date                    => l_start_date
    ,p_end_date                      => l_end_date
    ,p_task_start_date               => l_task_start_date
    ,p_task_end_date                 => l_task_end_date
    ,p_initiator_code                => p_initiator_code
    ,p_appraisal_system_type         => p_appraisal_system_type
    ,p_appraisal_type                => p_appraisal_type
    ,p_appraisal_assmt_status        => p_appraisal_assmt_status
    ,p_auto_conc_process             => p_auto_conc_process
    ,p_days_before_task_st_dt        => p_days_before_task_st_dt
    ,p_participation_type        => p_participation_type
    ,p_questionnaire_template_id        => p_questionnaire_template_id
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
    );

  --
  -- Call After Process User Hook
  --
  begin
    hr_appraisal_period_bk2.update_appraisal_period_a
      (p_effective_date                => l_effective_date
      ,p_appraisal_period_id           => p_appraisal_period_id
      ,p_object_version_number         => l_object_version_number
      ,p_start_date                    => l_start_date
      ,p_end_date                      => l_end_date
      ,p_task_start_date               => l_task_start_date
      ,p_task_end_date                 => l_task_end_date
      ,p_initiator_code                => p_initiator_code
      ,p_appraisal_system_type         => p_appraisal_system_type
      ,p_appraisal_type                => p_appraisal_type
      ,p_appraisal_assmt_status        => p_appraisal_assmt_status
      ,p_auto_conc_process             => p_auto_conc_process
      ,p_days_before_task_st_dt        => p_days_before_task_st_dt
      ,p_participation_type        => p_participation_type
      ,p_questionnaire_template_id        => p_questionnaire_template_id
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
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_APPRAISAL_PERIOD'
        ,p_hook_type   => 'AP'
        );
  end;

  --
  -- Update the plan's status to Updated if the plan is already
  -- published.
  --
  set_plan_status(per_pma_shd.g_old_rec.plan_id
                 ,per_pma_shd.g_old_rec.start_date);

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
  p_object_version_number  := l_object_version_number;

  --
  -- Pipe the main IN OUT / OUT parameters for ease of debugging.
  --
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
    rollback to update_appraisal_period;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 980);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_appraisal_period;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 990);
    raise;
end update_appraisal_period;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_appraisal_period >---------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_appraisal_period
  (p_validate                      in     boolean  default false
  ,p_appraisal_period_id           in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||'delete_appraisal_period';

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
    hr_utility.trace('  p_appraisal_period_id            '||
                        to_char(p_appraisal_period_id));
    hr_utility.trace('  p_object_version_number          '||
                        to_char(p_object_version_number));
    hr_utility.trace(' --------------------------------'||
                     '---------------------------------');
    hr_utility.trace(' ');

  END IF;

  --
  -- Issue a savepoint
  --
  savepoint delete_appraisal_period;

  --
  -- Call Before Process User Hook
  --
  begin
    hr_appraisal_period_bk3.delete_appraisal_period_b
      (p_appraisal_period_id           => p_appraisal_period_id
      ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_APPRAISAL_PERIOD'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --
  IF g_debug THEN hr_utility.set_location(l_proc, 30); END IF;

  per_pma_del.del
    (p_appraisal_period_id           => p_appraisal_period_id
    ,p_object_version_number         => p_object_version_number
    );

  --
  -- Call After Process User Hook
  --
  begin
    hr_appraisal_period_bk3.delete_appraisal_period_a
      (p_appraisal_period_id           => p_appraisal_period_id
      ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_APPRAISAL_PERIOD'
        ,p_hook_type   => 'AP'
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
  IF g_debug THEN

    hr_utility.trace(' ');
    hr_utility.trace(' --------------------------------'||
                     '---------------------------------');
    hr_utility.trace(' IN OUT / OUT PARAMETER          '||
                     ' VALUE');
    hr_utility.trace(' --------------------------------'||
                     '+--------------------------------');
    hr_utility.trace(' ');
    hr_utility.set_location(' Leaving:'||l_proc, 970);

  END IF;

exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_appraisal_period;
    hr_utility.set_location(' Leaving:'||l_proc, 980);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_appraisal_period;
    hr_utility.set_location(' Leaving:'||l_proc, 990);
    raise;
end delete_appraisal_period;
--
end hr_appraisal_period_api;

/
