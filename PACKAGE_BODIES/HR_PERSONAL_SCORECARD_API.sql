--------------------------------------------------------
--  DDL for Package Body HR_PERSONAL_SCORECARD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PERSONAL_SCORECARD_API" as
/* $Header: pepmsapi.pkb 120.2 2006/02/27 11:29:46 tpapired noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_personal_scorecard_api.';
g_debug    boolean      := hr_utility.debug_enabled;

--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_scorecard >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_scorecard
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_scorecard_name                in     varchar2
  ,p_assignment_id                 in     number
  ,p_start_date                    in     date
  ,p_end_date                      in     date
  ,p_plan_id                       in     number   default null
  ,p_creator_type                  in     varchar2 default 'MANUAL'
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
  ,p_scorecard_id                     out nocopy   number
  ,p_object_version_number            out nocopy   number
  ,p_status_code                   in     varchar2
  ,p_duplicate_name_warning           out nocopy   boolean
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                   varchar2(72) := g_package||'create_scorecard';
  l_effective_date         date;
  l_start_date             date;
  l_end_date               date;
  l_scorecard_id           number;
  l_object_version_number  number;
  l_status_code            per_personal_scorecards.status_code%TYPE;
  l_duplicate_name_warning boolean;

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
    hr_utility.trace('  p_scorecard_name                 '||
                        p_scorecard_name);
    hr_utility.trace('  p_assignment_id                  '||
                        to_char(p_assignment_id));
    hr_utility.trace('  p_start_date                     '||
                        to_char(p_start_date));
    hr_utility.trace('  p_end_date                       '||
                        to_char(p_end_date));
    hr_utility.trace('  p_plan_id                        '||
                        to_char(p_plan_id));
    hr_utility.trace('  p_creator_type                   '||
                        p_creator_type);
    hr_utility.trace('  p_status_code                    '||
                        p_status_code);
    hr_utility.trace(' --------------------------------'||
                     '---------------------------------');
    hr_utility.trace(' ');

  END IF;

  --
  -- Issue a savepoint
  --
  savepoint create_scorecard;

  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  l_start_date     := trunc(p_start_date);
  l_end_date       := trunc(p_end_date);

  --
  -- Call Before Process User Hook
  --
  begin
    hr_personal_scorecard_bk1.create_scorecard_b
      (p_effective_date                => l_effective_date
      ,p_scorecard_name                => p_scorecard_name
      ,p_assignment_id                 => p_assignment_id
      ,p_start_date                    => l_start_date
      ,p_end_date                      => l_end_date
      ,p_plan_id                       => p_plan_id
      ,p_creator_type                  => p_creator_type
      ,p_status_code                   => p_status_code
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
        (p_module_name => 'CREATE_SCORECARD'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --
  IF g_debug THEN hr_utility.set_location(l_proc, 30); END IF;

  per_pms_ins.ins
    (p_effective_date                => l_effective_date
    ,p_scorecard_name                => p_scorecard_name
    ,p_assignment_id                 => p_assignment_id
    ,p_start_date                    => l_start_date
    ,p_end_date                      => l_end_date
    ,p_plan_id                       => p_plan_id
    ,p_creator_type                  => p_creator_type
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
    ,p_scorecard_id                  => l_scorecard_id
    ,p_object_version_number         => l_object_version_number
    ,p_status_code                   => p_status_code
    ,p_duplicate_name_warning        => l_duplicate_name_warning
    );


  --
  -- Call After Process User Hook
  --
  begin
    hr_personal_scorecard_bk1.create_scorecard_a
      (p_effective_date                => l_effective_date
      ,p_scorecard_name                => p_scorecard_name
      ,p_assignment_id                 => p_assignment_id
      ,p_start_date                    => l_start_date
      ,p_end_date                      => l_end_date
      ,p_plan_id                       => p_plan_id
      ,p_creator_type                  => p_creator_type
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
      ,p_scorecard_id                  => l_scorecard_id
      ,p_object_version_number         => l_object_version_number
      ,p_status_code                   => p_status_code
      ,p_duplicate_name_warning        => l_duplicate_name_warning
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_SCORECARD'
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
  -- Set all IN OUT and OUT parameters with out values
  --
  p_scorecard_id           := l_scorecard_id;
  p_object_version_number  := l_object_version_number;
--  p_status_code            := l_status_code;
  p_duplicate_name_warning := l_duplicate_name_warning;

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
    hr_utility.trace('  p_scorecard_id                 '||
                        to_char(p_scorecard_id));
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
    rollback to create_scorecard;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_scorecard_id           := null;
    p_object_version_number  := null;
    --p_status_code            := l_status_code;
    p_duplicate_name_warning := l_duplicate_name_warning;
    hr_utility.set_location(' Leaving:'||l_proc, 980);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_scorecard;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_scorecard_id           := null;
    p_object_version_number  := null;
    --p_status_code            := null;
    p_duplicate_name_warning := null;
    hr_utility.set_location(' Leaving:'||l_proc, 990);
    raise;
end create_scorecard;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_scorecard >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_scorecard
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_scorecard_id                  in     number
  ,p_object_version_number         in out nocopy   number
  ,p_scorecard_name                in     varchar2 default hr_api.g_varchar2
  ,p_start_date                    in     date     default hr_api.g_date
  ,p_end_date                      in     date     default hr_api.g_date
  ,p_plan_id                       in     number   default hr_api.g_number
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
  ,p_status_code                   in     varchar2 default hr_api.g_varchar2
  ,p_duplicate_name_warning           out nocopy   boolean
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                   varchar2(72) := g_package||'update_scorecard';
  l_effective_date         date;
  l_start_date             date;
  l_end_date               date;
  l_object_version_number  number := p_object_version_number;
  l_duplicate_name_warning boolean;

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
    hr_utility.trace('  p_scorecard_id                   '||
                        to_char(p_scorecard_id));
    hr_utility.trace('  p_object_version_number          '||
                        to_char(p_object_version_number));
    hr_utility.trace('  p_scorecard_name                 '||
                        p_scorecard_name);
    hr_utility.trace('  p_plan_id                        '||
                        to_char(p_plan_id));
    hr_utility.trace('  p_start_date                     '||
                        to_char(p_start_date));
    hr_utility.trace('  p_end_date                       '||
                        to_char(p_end_date));
    hr_utility.trace(' --------------------------------'||
                     '---------------------------------');
    hr_utility.trace(' ');

  END IF;

  --
  -- Issue a savepoint
  --
  savepoint update_scorecard;

  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  l_start_date     := trunc(p_start_date);
  l_end_date       := trunc(p_end_date);

  --
  -- Call Before Process User Hook
  --
  begin
    hr_personal_scorecard_bk2.update_scorecard_b
      (p_effective_date                => l_effective_date
      ,p_scorecard_id                  => p_scorecard_id
      ,p_object_version_number         => l_object_version_number
      ,p_scorecard_name                => p_scorecard_name
      ,p_start_date                    => l_start_date
      ,p_end_date                      => l_end_date
      ,p_plan_id                       => p_plan_id
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
      ,p_status_code                   => p_status_code
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_SCORECARD'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --
  IF g_debug THEN hr_utility.set_location(l_proc, 30); END IF;

  per_pms_upd.upd
    (p_effective_date                => l_effective_date
    ,p_scorecard_id                  => p_scorecard_id
    ,p_object_version_number         => l_object_version_number
    ,p_scorecard_name                => p_scorecard_name
    ,p_start_date                    => l_start_date
    ,p_end_date                      => l_end_date
    ,p_plan_id                       => p_plan_id
    ,p_status_code                   => p_status_code
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
    ,p_duplicate_name_warning        => l_duplicate_name_warning
    );

  --
  -- Call After Process User Hook
  --
  begin
    hr_personal_scorecard_bk2.update_scorecard_a
      (p_effective_date                => l_effective_date
      ,p_scorecard_id                  => p_scorecard_id
      ,p_object_version_number         => l_object_version_number
      ,p_scorecard_name                => p_scorecard_name
      ,p_start_date                    => l_start_date
      ,p_end_date                      => l_end_date
      ,p_plan_id                       => p_plan_id
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
      ,p_status_code                   => p_status_code
      ,p_duplicate_name_warning        => l_duplicate_name_warning
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_SCORECARD'
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
  -- Set all IN OUT and OUT parameters with out values
  --
  p_object_version_number  := l_object_version_number;
  p_duplicate_name_warning := l_duplicate_name_warning;

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
    IF p_duplicate_name_warning THEN
      hr_utility.trace('  p_duplicate_name_warning       '||
                          'TRUE');
    ELSE
      hr_utility.trace('  p_duplicate_name_warning       '||
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
    rollback to update_scorecard;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := null;
    p_duplicate_name_warning := l_duplicate_name_warning;
    hr_utility.set_location(' Leaving:'||l_proc, 980);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_scorecard;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_object_version_number  := null;
    p_duplicate_name_warning := null;
    hr_utility.set_location(' Leaving:'||l_proc, 990);
    raise;
end update_scorecard;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_scorecard_status >---------------------|
-- ----------------------------------------------------------------------------
--
procedure update_scorecard_status
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_scorecard_id                  in     number
  ,p_object_version_number         in out nocopy   number
  ,p_status_code                   in     varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                   varchar2(72) := g_package||'update_scorecard_status';
  l_effective_date         date;
  l_object_version_number  number := p_object_version_number;
  l_dummy                  boolean;

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
    hr_utility.trace('  p_scorecard_id                   '||
                        to_char(p_scorecard_id));
    hr_utility.trace('  p_object_version_number          '||
                        to_char(p_object_version_number));
    hr_utility.trace('  p_status_code                    '||
                        p_status_code);
    hr_utility.trace(' --------------------------------'||
                     '---------------------------------');
    hr_utility.trace(' ');

  END IF;

  --
  -- Issue a savepoint
  --
  savepoint update_scorecard_status;

  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);

  --
  -- Call Before Process User Hook
  --
  begin
    hr_personal_scorecard_bk3.update_scorecard_status_b
      (p_effective_date                => l_effective_date
      ,p_scorecard_id                  => p_scorecard_id
      ,p_object_version_number         => l_object_version_number
      ,p_status_code                   => p_status_code
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_SCORECARD_STATUS'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --
  IF g_debug THEN hr_utility.set_location(l_proc, 30); END IF;

  per_pms_upd.upd
    (p_effective_date                => l_effective_date
    ,p_scorecard_id                  => p_scorecard_id
    ,p_object_version_number         => l_object_version_number
    ,p_status_code                   => p_status_code
    ,p_duplicate_name_warning        => l_dummy
    );

  --
  -- Call After Process User Hook
  --
  begin
    hr_personal_scorecard_bk3.update_scorecard_status_a
      (p_effective_date                => l_effective_date
      ,p_scorecard_id                  => p_scorecard_id
      ,p_object_version_number         => l_object_version_number
      ,p_status_code                   => p_status_code
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_SCORECARD_STATUS'
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

  END IF;

exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_scorecard_status;
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
    rollback to update_scorecard_status;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 990);
    raise;
end update_scorecard_status;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_scorecard >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_scorecard
  (p_validate                      in     boolean  default false
  ,p_scorecard_id                  in     number
  ,p_object_version_number         in     number
  ,p_created_by_plan_warning          out nocopy   boolean
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||'delete_scorecard';
  l_created_by_plan_warning boolean;

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
    hr_utility.trace('  p_scorecard_id                   '||
                        to_char(p_scorecard_id));
    hr_utility.trace('  p_object_version_number          '||
                        to_char(p_object_version_number));
    hr_utility.trace(' --------------------------------'||
                     '---------------------------------');
    hr_utility.trace(' ');

  END IF;

  --
  -- Issue a savepoint
  --
  savepoint delete_scorecard;

  --
  -- Call Before Process User Hook
  --
  begin
    hr_personal_scorecard_bk4.delete_scorecard_b
      (p_scorecard_id                  => p_scorecard_id
      ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_SCORECARD'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --
  IF g_debug THEN hr_utility.set_location(l_proc, 30); END IF;

  per_pms_del.del
    (p_scorecard_id                  => p_scorecard_id
    ,p_object_version_number         => p_object_version_number
    ,p_created_by_plan_warning       => l_created_by_plan_warning
    );

  --
  -- Call After Process User Hook
  --
  begin
    hr_personal_scorecard_bk4.delete_scorecard_a
      (p_scorecard_id                  => p_scorecard_id
      ,p_object_version_number         => p_object_version_number
      ,p_created_by_plan_warning       => l_created_by_plan_warning
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_SCORECARD'
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
  -- Set all IN OUT and OUT parameters with out values
  --
  p_created_by_plan_warning := l_created_by_plan_warning;

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
    IF p_created_by_plan_warning THEN
      hr_utility.trace('  p_created_by_plan_warning      '||
                          'TRUE');
    ELSE
      hr_utility.trace('  p_created_by_plan_warning      '||
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
    rollback to delete_scorecard;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_created_by_plan_warning := l_created_by_plan_warning;
    hr_utility.set_location(' Leaving:'||l_proc, 980);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_scorecard;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_created_by_plan_warning := null;
    hr_utility.set_location(' Leaving:'||l_proc, 990);
    raise;
end delete_scorecard;
--
end hr_personal_scorecard_api;

/
