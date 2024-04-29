--------------------------------------------------------
--  DDL for Package Body PER_ESTAB_ATTENDANCES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ESTAB_ATTENDANCES_API" as
/* $Header: peesaapi.pkb 115.6 2003/02/12 16:39:09 pkakar noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'per_estab_attendances_api.';
--
-- ----------------------------------------------------------------------------
-- |-----------------------< CREATE_ATTENDED_ESTAB >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_ATTENDED_ESTAB
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_fulltime                      in     varchar2
  ,p_attended_start_date           in     date     default null
  ,p_attended_end_date             in     date     default null
  ,p_establishment                 in     varchar2 default null
  ,p_business_group_id             in     number   default null
  ,p_person_id                     in     number   default null
  ,p_party_id                      in     number   default null
  ,p_address			   in	  varchar2 default null
  ,p_establishment_id              in     number   default null
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
  ,p_attendance_id                    out nocopy number
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                   varchar2(72) := g_package||'create_attended_estab';
  l_effective_date         date;
  l_attended_start_date    date;
  l_attended_end_date      date;
  l_attendance_id          number;
  l_object_version_number  number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_ATTENDED_ESTAB;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date     := TRUNC(p_effective_date);
  l_attended_start_date:= TRUNC(p_attended_start_date);
  l_attended_end_date  := TRUNC(p_attended_end_date);
  --
  -- Call Before Process User Hook
  --
  begin
  PER_ESTAB_ATTENDANCES_BK1.CREATE_ATTENDED_ESTAB_b
  (p_effective_date               => l_effective_date
  ,p_business_group_id            => p_business_group_id
  ,p_person_id                    => p_person_id
  ,p_party_id                     => p_party_id
  ,p_establishment_id             => p_establishment_id
  ,p_establishment                => p_establishment
  ,p_attended_start_date          => l_attended_start_date
  ,p_attended_end_date            => l_attended_end_date
  ,p_fulltime                     => p_fulltime
  ,p_attribute_category           => p_attribute_category
  ,p_attribute1                   => p_attribute1
  ,p_attribute2                   => p_attribute2
  ,p_attribute3                   => p_attribute3
  ,p_attribute4                   => p_attribute4
  ,p_attribute5                   => p_attribute5
  ,p_attribute6                   => p_attribute6
  ,p_attribute7                   => p_attribute7
  ,p_attribute8                   => p_attribute8
  ,p_attribute9                   => p_attribute9
  ,p_attribute10                  => p_attribute10
  ,p_attribute11                  => p_attribute11
  ,p_attribute12                  => p_attribute12
  ,p_attribute13                  => p_attribute13
  ,p_attribute14                  => p_attribute14
  ,p_attribute15                  => p_attribute15
  ,p_attribute16                  => p_attribute16
  ,p_attribute17                  => p_attribute17
  ,p_attribute18                  => p_attribute18
  ,p_attribute19                  => p_attribute19
  ,p_attribute20                  => p_attribute20
  ,p_address   			  => p_address
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_ATTENDED_ESTAB_b'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --
  per_esa_ins.ins
  (p_validate                     => false
  ,p_effective_date               => l_effective_date
  ,p_business_group_id            => p_business_group_id
  ,p_person_id                    => p_person_id
  ,p_establishment_id             => p_establishment_id
  ,p_establishment                => p_establishment
  ,p_attended_start_date          => l_attended_start_date
  ,p_attended_end_date            => l_attended_end_date
  ,p_full_time                    => p_fulltime
  ,p_attribute_category           => p_attribute_category
  ,p_attribute1                   => p_attribute1
  ,p_attribute2                   => p_attribute2
  ,p_attribute3                   => p_attribute3
  ,p_attribute4                   => p_attribute4
  ,p_attribute5                   => p_attribute5
  ,p_attribute6                   => p_attribute6
  ,p_attribute7                   => p_attribute7
  ,p_attribute8                   => p_attribute8
  ,p_attribute9                   => p_attribute9
  ,p_attribute10                  => p_attribute10
  ,p_attribute11                  => p_attribute11
  ,p_attribute12                  => p_attribute12
  ,p_attribute13                  => p_attribute13
  ,p_attribute14                  => p_attribute14
  ,p_attribute15                  => p_attribute15
  ,p_attribute16                  => p_attribute16
  ,p_attribute17                  => p_attribute17
  ,p_attribute18                  => p_attribute18
  ,p_attribute19                  => p_attribute19
  ,p_attribute20                  => p_attribute20
  ,p_object_version_number        => l_object_version_number
  ,p_attendance_id                => l_attendance_id
  ,p_party_id                     => p_party_id
  ,p_address			  => p_address
  );

  --
  -- Call After Process User Hook
  --
  begin
  PER_ESTAB_ATTENDANCES_BK1.CREATE_ATTENDED_ESTAB_a
  (p_effective_date               => l_effective_date
  ,p_business_group_id            => p_business_group_id
  ,p_person_id                    => p_person_id
  ,p_party_id                     => p_party_id
  ,p_establishment_id             => p_establishment_id
  ,p_establishment                => p_establishment
  ,p_attended_start_date          => l_attended_start_date
  ,p_attended_end_date            => l_attended_end_date
  ,p_fulltime                     => p_fulltime
  ,p_attribute_category           => p_attribute_category
  ,p_attribute1                   => p_attribute1
  ,p_attribute2                   => p_attribute2
  ,p_attribute3                   => p_attribute3
  ,p_attribute4                   => p_attribute4
  ,p_attribute5                   => p_attribute5
  ,p_attribute6                   => p_attribute6
  ,p_attribute7                   => p_attribute7
  ,p_attribute8                   => p_attribute8
  ,p_attribute9                   => p_attribute9
  ,p_attribute10                  => p_attribute10
  ,p_attribute11                  => p_attribute11
  ,p_attribute12                  => p_attribute12
  ,p_attribute13                  => p_attribute13
  ,p_attribute14                  => p_attribute14
  ,p_attribute15                  => p_attribute15
  ,p_attribute16                  => p_attribute16
  ,p_attribute17                  => p_attribute17
  ,p_attribute18                  => p_attribute18
  ,p_attribute19                  => p_attribute19
  ,p_attribute20                  => p_attribute20
  ,p_address                      => p_address
  );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_ATTENDED_ESTAB_a'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  --
  p_attendance_id := l_attendance_id;
  p_object_version_number := l_object_version_number;
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_ATTENDED_ESTAB;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_attendance_id := null;
    p_object_version_number := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_ATTENDED_ESTAB;
    --
    -- set in out parameters and set out parameters
    --
    p_attendance_id := null;
    p_object_version_number := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end CREATE_ATTENDED_ESTAB;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< UPDATE_ATTENDED_ESTAB >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure UPDATE_ATTENDED_ESTAB
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_attendance_id                 in     number
  ,p_fulltime                      in     varchar2
  ,p_attended_start_date           in     date     default hr_api.g_date
  ,p_attended_end_date             in     date     default hr_api.g_date
  ,p_establishment                 in     varchar2 default hr_api.g_varchar2
  ,p_establishment_id              in     number   default hr_api.g_number
  ,p_address			   in     varchar2 default hr_api.g_varchar2
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
  ,p_object_version_number         in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72) := g_package||'update_attended_estab';
  l_effective_date      date;
  l_attended_start_date date;
  l_attended_end_date   date;
  l_object_version_number number;
  l_ovn number := p_object_version_number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_ATTENDED_ESTAB;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date     := TRUNC(p_effective_date);
  l_attended_start_date:= TRUNC(p_attended_start_date);
  l_attended_end_date  := TRUNC(p_attended_end_date);
  l_object_version_number := p_object_version_number;
  --
  -- Call Before Process User Hook
  --
  begin
  PER_ESTAB_ATTENDANCES_BK2.UPDATE_ATTENDED_ESTAB_b
  (p_effective_date               => l_effective_date
  ,p_attendance_id                => p_attendance_id
  ,p_establishment_id             => p_establishment_id
  ,p_establishment                => p_establishment
  ,p_attended_start_date          => l_attended_start_date
  ,p_attended_end_date            => l_attended_end_date
  ,p_fulltime                     => p_fulltime
  ,p_attribute_category           => p_attribute_category
  ,p_attribute1                   => p_attribute1
  ,p_attribute2                   => p_attribute2
  ,p_attribute3                   => p_attribute3
  ,p_attribute4                   => p_attribute4
  ,p_attribute5                   => p_attribute5
  ,p_attribute6                   => p_attribute6
  ,p_attribute7                   => p_attribute7
  ,p_attribute8                   => p_attribute8
  ,p_attribute9                   => p_attribute9
  ,p_attribute10                  => p_attribute10
  ,p_attribute11                  => p_attribute11
  ,p_attribute12                  => p_attribute12
  ,p_attribute13                  => p_attribute13
  ,p_attribute14                  => p_attribute14
  ,p_attribute15                  => p_attribute15
  ,p_attribute16                  => p_attribute16
  ,p_attribute17                  => p_attribute17
  ,p_attribute18                  => p_attribute18
  ,p_attribute19                  => p_attribute19
  ,p_attribute20                  => p_attribute20
  ,p_object_version_number        => l_object_version_number
  ,p_address			  => p_address
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ATTENDED_ESTAB_b'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --
  per_esa_upd.upd
  (p_validate                     => false
  ,p_effective_date               => l_effective_date
  ,p_establishment_id             => p_establishment_id
  ,p_establishment                => p_establishment
  ,p_attended_start_date          => l_attended_start_date
  ,p_attended_end_date            => l_attended_end_date
  ,p_full_time                    => p_fulltime
  ,p_attribute_category           => p_attribute_category
  ,p_attribute1                   => p_attribute1
  ,p_attribute2                   => p_attribute2
  ,p_attribute3                   => p_attribute3
  ,p_attribute4                   => p_attribute4
  ,p_attribute5                   => p_attribute5
  ,p_attribute6                   => p_attribute6
  ,p_attribute7                   => p_attribute7
  ,p_attribute8                   => p_attribute8
  ,p_attribute9                   => p_attribute9
  ,p_attribute10                  => p_attribute10
  ,p_attribute11                  => p_attribute11
  ,p_attribute12                  => p_attribute12
  ,p_attribute13                  => p_attribute13
  ,p_attribute14                  => p_attribute14
  ,p_attribute15                  => p_attribute15
  ,p_attribute16                  => p_attribute16
  ,p_attribute17                  => p_attribute17
  ,p_attribute18                  => p_attribute18
  ,p_attribute19                  => p_attribute19
  ,p_attribute20                  => p_attribute20
  ,p_object_version_number        => l_object_version_number
  ,p_attendance_id                => p_attendance_id
  ,p_address			  => p_address
  );

  --
  -- Call After Process User Hook
  --
  begin
  PER_ESTAB_ATTENDANCES_BK2.UPDATE_ATTENDED_ESTAB_a
  (p_effective_date               => l_effective_date
  ,p_attendance_id                => p_attendance_id
  ,p_establishment_id             => p_establishment_id
  ,p_establishment                => p_establishment
  ,p_attended_start_date          => l_attended_start_date
  ,p_attended_end_date            => l_attended_end_date
  ,p_fulltime                     => p_fulltime
  ,p_attribute_category           => p_attribute_category
  ,p_attribute1                   => p_attribute1
  ,p_attribute2                   => p_attribute2
  ,p_attribute3                   => p_attribute3
  ,p_attribute4                   => p_attribute4
  ,p_attribute5                   => p_attribute5
  ,p_attribute6                   => p_attribute6
  ,p_attribute7                   => p_attribute7
  ,p_attribute8                   => p_attribute8
  ,p_attribute9                   => p_attribute9
  ,p_attribute10                  => p_attribute10
  ,p_attribute11                  => p_attribute11
  ,p_attribute12                  => p_attribute12
  ,p_attribute13                  => p_attribute13
  ,p_attribute14                  => p_attribute14
  ,p_attribute15                  => p_attribute15
  ,p_attribute16                  => p_attribute16
  ,p_attribute17                  => p_attribute17
  ,p_attribute18                  => p_attribute18
  ,p_attribute19                  => p_attribute19
  ,p_attribute20                  => p_attribute20
  ,p_object_version_number        => l_object_version_number
  ,p_address			  => p_address
  );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ATTENDED_ESTAB_a'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  --
  p_object_version_number := l_object_version_number;
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to UPDATE_ATTENDED_ESTAB;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to UPDATE_ATTENDED_ESTAB;
    --
    -- set in out parameters and set out parameters
    --
    p_object_version_number := l_ovn;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end UPDATE_ATTENDED_ESTAB;
--

--
-- ----------------------------------------------------------------------------
-- |-----------------------< DELETE_ATTENDED_ESTAB >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_ATTENDED_ESTAB
  (p_validate                      in     boolean  default false
  ,p_attendance_id                 in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72) := g_package||'delete_attended_estab';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint DELETE_ATTENDED_ESTAB;
  --
  -- Call Before Process User Hook
  --
  begin
  PER_ESTAB_ATTENDANCES_BK3.DELETE_ATTENDED_ESTAB_b
  (p_attendance_id                => p_attendance_id
  ,p_object_version_number        => p_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ATTENDED_ESTAB_b'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --
  per_esa_del.del
  (p_validate                     => false
  ,p_attendance_id                => p_attendance_id
  ,p_object_version_number        => p_object_version_number
  );


  --
  -- Call After Process User Hook
  --
  begin
  PER_ESTAB_ATTENDANCES_BK3.DELETE_ATTENDED_ESTAB_a
  (p_attendance_id                => p_attendance_id
  ,p_object_version_number        => p_object_version_number
  );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ATTENDED_ESTAB_a'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to DELETE_ATTENDED_ESTAB;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to DELETE_ATTENDED_ESTAB;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end DELETE_ATTENDED_ESTAB;
--
end PER_ESTAB_ATTENDANCES_API;

/
