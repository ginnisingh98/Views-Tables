--------------------------------------------------------
--  DDL for Package Body HR_SCORECARD_SHARING_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_SCORECARD_SHARING_API" as
/* $Header: pepshapi.pkb 120.0 2006/03/14 19:41:56 tpapired noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_scorecard_sharing_api.';
g_debug    boolean      := hr_utility.debug_enabled;

--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_sharing_instance >---------------------|
-- ----------------------------------------------------------------------------
--
procedure create_sharing_instance
  (p_validate                      in     boolean  default false
  ,p_scorecard_id                  in     number
  ,p_person_id                     in     number
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
  ,p_sharing_instance_id              out nocopy   number
  ,p_object_version_number            out nocopy   number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                   varchar2(72) := g_package||'create_sharing_instance';
  l_sharing_instance_id    number;
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
    hr_utility.trace('  p_scorecard_id                   '||
                        to_char(p_scorecard_id));
    hr_utility.trace('  p_person_id                      '||
                        to_char(p_person_id));
    hr_utility.trace(' --------------------------------'||
                     '---------------------------------');
    hr_utility.trace(' ');

  END IF;

  --
  -- Issue a savepoint
  --
  savepoint create_sharing_instance;

  --
  -- Call Before Process User Hook
  --
  begin
    hr_scorecard_sharing_bk1.create_sharing_instance_b
      (p_scorecard_id                  => p_scorecard_id
      ,p_person_id                     => p_person_id
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
        (p_module_name => 'create_sharing_instance'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --
  IF g_debug THEN hr_utility.set_location(l_proc, 30); END IF;

  per_psh_ins.ins
    (p_scorecard_id                  => p_scorecard_id
    ,p_person_id                     => p_person_id
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
    ,p_sharing_instance_id           => l_sharing_instance_id
    ,p_object_version_number         => l_object_version_number
    );

  --
  -- Call After Process User Hook
  --
  begin
    hr_scorecard_sharing_bk1.create_sharing_instance_a
      (p_scorecard_id                  => p_scorecard_id
      ,p_person_id                     => p_person_id
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
      ,p_sharing_instance_id           => l_sharing_instance_id
      ,p_object_version_number         => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_sharing_instance'
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
  p_sharing_instance_id    := l_sharing_instance_id;
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
    hr_utility.trace('  p_sharing_instance_id          '||
                        to_char(p_sharing_instance_id));
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
    rollback to create_sharing_instance;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_sharing_instance_id    := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 980);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_sharing_instance;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_sharing_instance_id    := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 990);
    raise;
end create_sharing_instance;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_sharing_instance >---------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_sharing_instance
  (p_validate                      in     boolean  default false
  ,p_sharing_instance_id           in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'delete_sharing_instance';

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
    hr_utility.trace('  p_sharing_instance_id            '||
                        to_char(p_sharing_instance_id));
    hr_utility.trace('  p_object_version_number          '||
                        to_char(p_object_version_number));
    hr_utility.trace(' --------------------------------'||
                     '---------------------------------');
    hr_utility.trace(' ');

  END IF;

  --
  -- Issue a savepoint
  --
  savepoint delete_sharing_instance;

  --
  -- Call Before Process User Hook
  --
  begin
    hr_scorecard_sharing_bk2.delete_sharing_instance_b
      (p_sharing_instance_id           => p_sharing_instance_id
      ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_sharing_instance'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --
  IF g_debug THEN hr_utility.set_location(l_proc, 30); END IF;

  per_psh_del.del
    (p_sharing_instance_id           => p_sharing_instance_id
    ,p_object_version_number         => p_object_version_number
    );

  --
  -- Call After Process User Hook
  --
  begin
    hr_scorecard_sharing_bk2.delete_sharing_instance_a
      (p_sharing_instance_id           => p_sharing_instance_id
      ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_sharing_instance'
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
    rollback to delete_sharing_instance;
    hr_utility.set_location(' Leaving:'||l_proc, 980);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_sharing_instance;
    hr_utility.set_location(' Leaving:'||l_proc, 990);
    raise;
end delete_sharing_instance;
--
end hr_scorecard_sharing_api;

/
