--------------------------------------------------------
--  DDL for Package Body HR_STD_HOL_ABS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_STD_HOL_ABS_API" as
/* $Header: peshaapi.pkb 115.7 2002/12/11 15:21:12 eumenyio ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'hr_std_hol_abs_api';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_std_hol_abs >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_std_hol_abs
 (p_date_not_taken               in     date,
  p_person_id                    in     number,
  p_standard_holiday_id          in     number,
  p_actual_date_taken            in     date             default null,
  p_reason                       in     varchar2         default null,
  p_expired                      in     varchar2         default null,
  p_attribute_category           in     varchar2         default null,
  p_attribute1                   in     varchar2         default null,
  p_attribute2                   in     varchar2         default null,
  p_attribute3                   in     varchar2         default null,
  p_attribute4                   in     varchar2         default null,
  p_attribute5                   in     varchar2         default null,
  p_attribute6                   in     varchar2         default null,
  p_attribute7                   in     varchar2         default null,
  p_attribute8                   in     varchar2         default null,
  p_attribute9                   in     varchar2         default null,
  p_attribute10                  in     varchar2         default null,
  p_attribute11                  in     varchar2         default null,
  p_attribute12                  in     varchar2         default null,
  p_attribute13                  in     varchar2         default null,
  p_attribute14                  in     varchar2         default null,
  p_attribute15                  in     varchar2         default null,
  p_attribute16                  in     varchar2         default null,
  p_attribute17                  in     varchar2         default null,
  p_attribute18                  in     varchar2         default null,
  p_attribute19                  in     varchar2         default null,
  p_attribute20                  in     varchar2         default null,
  p_validate                     in     boolean          default false,
  p_effective_date               in     date,
  p_object_version_number           out nocopy number,
  p_std_holiday_absences_id         out nocopy number)
is
  --
  l_proc      varchar2(72) := g_package||'create_std_hol_abs';
  l_object_version_number     number;
  l_std_holiday_absences_id   number;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_std_hol_abs;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  --
  -- Start of API User Hook for the before hook
  --
  --
  begin
     hr_std_hol_abs_bk1.create_std_hol_abs_b
    (p_date_not_taken               =>  p_date_not_taken
    ,p_person_id                    =>  p_person_id
    ,p_standard_holiday_id          =>  p_standard_holiday_id
    ,p_actual_date_taken            =>  p_actual_date_taken
    ,p_reason                       =>  p_reason
    ,p_expired                      =>  p_expired
    ,p_attribute_category           =>  p_attribute_category
    ,p_attribute1                   =>  p_attribute1
    ,p_attribute2                   =>  p_attribute2
    ,p_attribute3                   =>  p_attribute3
    ,p_attribute4                   =>  p_attribute4
    ,p_attribute5                   =>  p_attribute5
    ,p_attribute6                   =>  p_attribute6
    ,p_attribute7                   =>  p_attribute7
    ,p_attribute8                   =>  p_attribute8
    ,p_attribute9                   =>  p_attribute9
    ,p_attribute10                  =>  p_attribute10
    ,p_attribute11                  =>  p_attribute11
    ,p_attribute12                  =>  p_attribute12
    ,p_attribute13                  =>  p_attribute13
    ,p_attribute14                  =>  p_attribute14
    ,p_attribute15                  =>  p_attribute15
    ,p_attribute16                  =>  p_attribute16
    ,p_attribute17                  =>  p_attribute17
    ,p_attribute18                  =>  p_attribute18
    ,p_attribute19                  =>  p_attribute19
    ,p_attribute20                  =>  p_attribute20
    ,p_effective_date               =>  p_effective_date
    );
    exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'CREATE_STD_HOL_ABS',
          p_hook_type         => 'BP'
          );
  end;
  --
  --
  per_sha_ins.ins
  (p_std_holiday_absences_id      => l_std_holiday_absences_id
  ,p_date_not_taken               => p_date_not_taken
  ,p_person_id                    => p_person_id
  ,p_standard_holiday_id          => p_standard_holiday_id
  ,p_actual_date_taken            => p_actual_date_taken
  ,p_reason                       => p_reason
  ,p_expired                      => p_expired
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
  ,p_object_version_number        => l_object_version_number );
  --
  hr_utility.set_location(l_proc, 8);
  --
  --
  -- Start of API User Hook for the after hook
  --
  begin
  hr_std_hol_abs_bk1.create_std_hol_abs_a
    (p_date_not_taken               =>  p_date_not_taken
    ,p_person_id                    =>  p_person_id
    ,p_standard_holiday_id          =>  p_standard_holiday_id
    ,p_actual_date_taken            =>  p_actual_date_taken
    ,p_reason                       =>  p_reason
    ,p_expired                      =>  p_expired
    ,p_attribute_category           =>  p_attribute_category
    ,p_attribute1                   =>  p_attribute1
    ,p_attribute2                   =>  p_attribute2
    ,p_attribute3                   =>  p_attribute3
    ,p_attribute4                   =>  p_attribute4
    ,p_attribute5                   =>  p_attribute5
    ,p_attribute6                   =>  p_attribute6
    ,p_attribute7                   =>  p_attribute7
    ,p_attribute8                   =>  p_attribute8
    ,p_attribute9                   =>  p_attribute9
    ,p_attribute10                  =>  p_attribute10
    ,p_attribute11                  =>  p_attribute11
    ,p_attribute12                  =>  p_attribute12
    ,p_attribute13                  =>  p_attribute13
    ,p_attribute14                  =>  p_attribute14
    ,p_attribute15                  =>  p_attribute15
    ,p_attribute16                  =>  p_attribute16
    ,p_attribute17                  =>  p_attribute17
    ,p_attribute18                  =>  p_attribute18
    ,p_attribute19                  =>  p_attribute19
    ,p_attribute20                  =>  p_attribute20
    ,p_effective_date               =>  p_effective_date
    ,p_object_version_number        =>  l_object_version_number
    ,p_std_holiday_absences_id      =>  l_std_holiday_absences_id
    );
    exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'CREATE_STD_HOL_ABS',
          p_hook_type         => 'AP'
          );
  end;
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  p_object_version_number    := l_object_version_number;
  p_std_holiday_absences_id  := l_std_holiday_absences_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 11);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_std_hol_abs;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_std_holiday_absences_id := null;
    p_object_version_number   := null;
    --
  when others then
  --
  -- A validation or unexpected error has occurred
  --
  -- Added as part of the fix to bug 632479
  --
  p_std_holiday_absences_id := null;
  p_object_version_number   := null;
  ROLLBACK TO create_std_hol_abs;
  --
  raise;
  --
end create_std_hol_abs;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_std_hol_abs >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_std_hol_abs
 (p_std_holiday_absences_id      in number,
  p_date_not_taken               in date             default hr_api.g_date,
  p_standard_holiday_id          in number           default hr_api.g_number,
  p_actual_date_taken            in date             default hr_api.g_date,
  p_reason                       in varchar2         default hr_api.g_varchar2,
  p_expired                      in varchar2         default hr_api.g_varchar2,
  p_attribute_category           in varchar2         default hr_api.g_varchar2,
  p_attribute1                   in varchar2         default hr_api.g_varchar2,
  p_attribute2                   in varchar2         default hr_api.g_varchar2,
  p_attribute3                   in varchar2         default hr_api.g_varchar2,
  p_attribute4                   in varchar2         default hr_api.g_varchar2,
  p_attribute5                   in varchar2         default hr_api.g_varchar2,
  p_attribute6                   in varchar2         default hr_api.g_varchar2,
  p_attribute7                   in varchar2         default hr_api.g_varchar2,
  p_attribute8                   in varchar2         default hr_api.g_varchar2,
  p_attribute9                   in varchar2         default hr_api.g_varchar2,
  p_attribute10                  in varchar2         default hr_api.g_varchar2,
  p_attribute11                  in varchar2         default hr_api.g_varchar2,
  p_attribute12                  in varchar2         default hr_api.g_varchar2,
  p_attribute13                  in varchar2         default hr_api.g_varchar2,
  p_attribute14                  in varchar2         default hr_api.g_varchar2,
  p_attribute15                  in varchar2         default hr_api.g_varchar2,
  p_attribute16                  in varchar2         default hr_api.g_varchar2,
  p_attribute17                  in varchar2         default hr_api.g_varchar2,
  p_attribute18                  in varchar2         default hr_api.g_varchar2,
  p_attribute19                  in varchar2         default hr_api.g_varchar2,
  p_attribute20                  in varchar2         default hr_api.g_varchar2,
  p_object_version_number        in out nocopy number,
  p_validate                     in boolean          default false,
  p_effective_date               in date
 )

is
  --
  -- Declare cursors and local variables
  --
  l_object_version_number per_std_holiday_absences.object_version_number%TYPE;
  l_object_version_number_temp
                          per_std_holiday_absences.object_version_number%TYPE;
  l_proc                  varchar2(72) := g_package||'update_std_hol_abs';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint
  --
  savepoint update_std_hol_abs;
  --
  hr_utility.set_location(l_proc, 6);
  --
  l_object_version_number_temp := p_object_version_number;
  l_object_version_number      := p_object_version_number;
  --
  -- Start of API User Hook for the before hook
  --
  begin
  hr_std_hol_abs_bk2.update_std_hol_abs_b
  (p_std_holiday_absences_id    =>  p_std_holiday_absences_id
  ,p_date_not_taken             =>  p_date_not_taken
  ,p_standard_holiday_id        =>  p_standard_holiday_id
  ,p_actual_date_taken          =>  p_actual_date_taken
  ,p_reason                     =>  p_reason
  ,p_expired                    =>  p_expired
  ,p_attribute_category         =>  p_attribute_category
  ,p_attribute1                 =>  p_attribute1
  ,p_attribute2                 =>  p_attribute2
  ,p_attribute3                 =>  p_attribute3
  ,p_attribute4                 =>  p_attribute4
  ,p_attribute5                 =>  p_attribute5
  ,p_attribute6                 =>  p_attribute6
  ,p_attribute7                 =>  p_attribute7
  ,p_attribute8                 =>  p_attribute8
  ,p_attribute9                 =>  p_attribute9
  ,p_attribute10                =>  p_attribute10
  ,p_attribute11                =>  p_attribute11
  ,p_attribute12                =>  p_attribute12
  ,p_attribute13                =>  p_attribute13
  ,p_attribute14                =>  p_attribute14
  ,p_attribute15                =>  p_attribute15
  ,p_attribute16                =>  p_attribute16
  ,p_attribute17                =>  p_attribute17
  ,p_attribute18                =>  p_attribute18
  ,p_attribute19                =>  p_attribute19
  ,p_attribute20                =>  p_attribute20
  ,p_object_version_number      =>  p_object_version_number
  ,p_effective_date             =>  p_effective_date
  );
    exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'UPDATE_STD_HOL_ABS',
          p_hook_type         => 'BP'
          );
  end;
  --
  --
  -- Update Phone details.
  --
  per_sha_upd.upd
  (p_std_holiday_absences_id      => p_std_holiday_absences_id
  ,p_date_not_taken               => p_date_not_taken
  ,p_standard_holiday_id          => p_standard_holiday_id
  ,p_actual_date_taken            => p_actual_date_taken
  ,p_reason                       => p_reason
  ,p_expired                      => p_expired
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
  );
  --
  hr_utility.set_location(l_proc, 8);
  --
  -- Start of API User Hook for the after
  --
 begin
 hr_std_hol_abs_bk2.update_std_hol_abs_a
  (p_std_holiday_absences_id    =>  p_std_holiday_absences_id
  ,p_date_not_taken             =>  p_date_not_taken
  ,p_standard_holiday_id        =>  p_standard_holiday_id
  ,p_actual_date_taken          =>  p_actual_date_taken
  ,p_reason                     =>  p_reason
  ,p_expired                    =>  p_expired
  ,p_attribute_category         =>  p_attribute_category
  ,p_attribute1                 =>  p_attribute1
  ,p_attribute2                 =>  p_attribute2
  ,p_attribute3                 =>  p_attribute3
  ,p_attribute4                 =>  p_attribute4
  ,p_attribute5                 =>  p_attribute5
  ,p_attribute6                 =>  p_attribute6
  ,p_attribute7                 =>  p_attribute7
  ,p_attribute8                 =>  p_attribute8
  ,p_attribute9                 =>  p_attribute9
  ,p_attribute10                =>  p_attribute10
  ,p_attribute11                =>  p_attribute11
  ,p_attribute12                =>  p_attribute12
  ,p_attribute13                =>  p_attribute13
  ,p_attribute14                =>  p_attribute14
  ,p_attribute15                =>  p_attribute15
  ,p_attribute16                =>  p_attribute16
  ,p_attribute17                =>  p_attribute17
  ,p_attribute18                =>  p_attribute18
  ,p_attribute19                =>  p_attribute19
  ,p_attribute20                =>  p_attribute20
  ,p_object_version_number      =>  l_object_version_number
  ,p_effective_date             =>  p_effective_date
   );
    exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'UPDATE_STD_HOL_ABS',
          p_hook_type         => 'AP'
          );
  end;
  --
  -- End of API User Hook for the after hook of update_phone.
  --
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  p_object_version_number := l_object_version_number;
  hr_utility.set_location(' Leaving:'||l_proc, 11);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_std_hol_abs;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number := l_object_version_number_temp;
    --
  when others then
  --
  -- A validation or unexpected error has occurred
  --
  -- Added as part of the fix to bug 632479
  --
  p_object_version_number := l_object_version_number_temp;
  ROLLBACK TO update_std_hol_abs;
  --
  raise;
  --
end update_std_hol_abs;
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_std_hol_abs >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_std_hol_abs
  (p_validate                       in     boolean  default false
  ,p_std_holiday_absences_id        in     number
  ,p_object_version_number          in     number
  ) is
  --
  l_proc                varchar2(72) := g_package||'delete_std_hol_abs';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint
  --
  savepoint delete_std_hol_abs;
  --
  hr_utility.set_location(l_proc, 7);
  --
  -- Process Logic
  --
  --
  -- Start of API User Hook for the before hook.
  --
begin
hr_std_hol_abs_bk3.delete_std_hol_abs_b
  (p_std_holiday_absences_id    => p_std_holiday_absences_id
  ,p_object_version_number      => p_object_version_number
   );
    exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'DELETE_STD_HOL_ABS',
          p_hook_type         => 'BP'
          );
  end;

  --
  per_sha_del.del
    (p_std_holiday_absences_id  => p_std_holiday_absences_id
    ,p_object_version_number    => p_object_version_number);
  --
  hr_utility.set_location(l_proc, 8);
  --
  -- Start of API User Hook for the after hook of delete_phone
  --
begin
hr_std_hol_abs_bk3.delete_std_hol_abs_a
  (p_std_holiday_absences_id    => p_std_holiday_absences_id
  ,p_object_version_number      => p_object_version_number
   );
    exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name       => 'DELETE_STD_HOL_ABS',
          p_hook_type         => 'AP'
          );
  end;
  --
  -- End of API User Hook for the after hook of delete_phone.
  --
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 11);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_std_hol_abs;
    --
  when others then
  --
  -- A validation or unexpected error has occurred
  --
  -- Added as part of the fix to bug 632479
  --
  ROLLBACK TO delete_std_hol_abs;
  --
  raise;
  --
end delete_std_hol_abs;
--
end hr_std_hol_abs_api;

/
