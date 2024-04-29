--------------------------------------------------------
--  DDL for Package Body BEN_ELIG_OBJ_ELIG_PROFL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ELIG_OBJ_ELIG_PROFL_API" as
/* $Header: bebepapi.pkb 120.0 2005/05/28 00:39:02 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_ELIG_OBJ_ELIG_PROFL_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_ELIG_OBJ_ELIG_PROFL >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ELIG_OBJ_ELIG_PROFL
  (p_validate                       in  boolean   default false
  ,p_elig_obj_elig_prfl_id          out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default null
  ,p_elig_obj_id                    in  number    default null
  ,p_elig_prfl_id                   in  number    default null
  ,p_mndtry_flag                    in  varchar2  default null
  ,p_bep_attribute_category         in  varchar2  default null
  ,p_bep_attribute1                 in  varchar2  default null
  ,p_bep_attribute2                 in  varchar2  default null
  ,p_bep_attribute3                 in  varchar2  default null
  ,p_bep_attribute4                 in  varchar2  default null
  ,p_bep_attribute5                 in  varchar2  default null
  ,p_bep_attribute6                 in  varchar2  default null
  ,p_bep_attribute7                 in  varchar2  default null
  ,p_bep_attribute8                 in  varchar2  default null
  ,p_bep_attribute9                 in  varchar2  default null
  ,p_bep_attribute10                in  varchar2  default null
  ,p_bep_attribute11                in  varchar2  default null
  ,p_bep_attribute12                in  varchar2  default null
  ,p_bep_attribute13                in  varchar2  default null
  ,p_bep_attribute14                in  varchar2  default null
  ,p_bep_attribute15                in  varchar2  default null
  ,p_bep_attribute16                in  varchar2  default null
  ,p_bep_attribute17                in  varchar2  default null
  ,p_bep_attribute18                in  varchar2  default null
  ,p_bep_attribute19                in  varchar2  default null
  ,p_bep_attribute20                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_elig_obj_elig_prfl_id ben_elig_obj_elig_profl_f.elig_obj_elig_prfl_id%TYPE;
  l_effective_start_date ben_elig_obj_elig_profl_f.effective_start_date%TYPE;
  l_effective_end_date ben_elig_obj_elig_profl_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_ELIG_OBJ_ELIG_PROFL';
  l_object_version_number ben_elig_obj_elig_profl_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_ELIG_OBJ_ELIG_PROFL;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_ELIG_OBJ_ELIG_PROFL
    --
    ben_ELIG_OBJ_ELIG_PROFL_bk1.create_ELIG_OBJ_ELIG_PROFL_b
      (
       p_business_group_id              =>  p_business_group_id
      ,p_elig_obj_id                    =>  p_elig_obj_id
      ,p_elig_prfl_id                   =>  p_elig_prfl_id
      ,p_mndtry_flag                    =>  p_mndtry_flag
      ,p_bep_attribute_category         =>  p_bep_attribute_category
      ,p_bep_attribute1                 =>  p_bep_attribute1
      ,p_bep_attribute2                 =>  p_bep_attribute2
      ,p_bep_attribute3                 =>  p_bep_attribute3
      ,p_bep_attribute4                 =>  p_bep_attribute4
      ,p_bep_attribute5                 =>  p_bep_attribute5
      ,p_bep_attribute6                 =>  p_bep_attribute6
      ,p_bep_attribute7                 =>  p_bep_attribute7
      ,p_bep_attribute8                 =>  p_bep_attribute8
      ,p_bep_attribute9                 =>  p_bep_attribute9
      ,p_bep_attribute10                =>  p_bep_attribute10
      ,p_bep_attribute11                =>  p_bep_attribute11
      ,p_bep_attribute12                =>  p_bep_attribute12
      ,p_bep_attribute13                =>  p_bep_attribute13
      ,p_bep_attribute14                =>  p_bep_attribute14
      ,p_bep_attribute15                =>  p_bep_attribute15
      ,p_bep_attribute16                =>  p_bep_attribute16
      ,p_bep_attribute17                =>  p_bep_attribute17
      ,p_bep_attribute18                =>  p_bep_attribute18
      ,p_bep_attribute19                =>  p_bep_attribute19
      ,p_bep_attribute20                =>  p_bep_attribute20
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_ELIG_OBJ_ELIG_PROFL'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_ELIG_OBJ_ELIG_PROFL
    --
  end;
  --
  ben_bep_ins.ins
    (
     p_elig_obj_elig_prfl_id              => l_elig_obj_elig_prfl_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_business_group_id             => p_business_group_id
    ,p_elig_obj_id                    =>  p_elig_obj_id
    ,p_elig_prfl_id                   =>  p_elig_prfl_id
    ,p_mndtry_flag                    =>  p_mndtry_flag
    ,p_bep_attribute_category        => p_bep_attribute_category
    ,p_bep_attribute1                => p_bep_attribute1
    ,p_bep_attribute2                => p_bep_attribute2
    ,p_bep_attribute3                => p_bep_attribute3
    ,p_bep_attribute4                => p_bep_attribute4
    ,p_bep_attribute5                => p_bep_attribute5
    ,p_bep_attribute6                => p_bep_attribute6
    ,p_bep_attribute7                => p_bep_attribute7
    ,p_bep_attribute8                => p_bep_attribute8
    ,p_bep_attribute9                => p_bep_attribute9
    ,p_bep_attribute10               => p_bep_attribute10
    ,p_bep_attribute11               => p_bep_attribute11
    ,p_bep_attribute12               => p_bep_attribute12
    ,p_bep_attribute13               => p_bep_attribute13
    ,p_bep_attribute14               => p_bep_attribute14
    ,p_bep_attribute15               => p_bep_attribute15
    ,p_bep_attribute16               => p_bep_attribute16
    ,p_bep_attribute17               => p_bep_attribute17
    ,p_bep_attribute18               => p_bep_attribute18
    ,p_bep_attribute19               => p_bep_attribute19
    ,p_bep_attribute20               => p_bep_attribute20
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_ELIG_OBJ_ELIG_PROFL
    --
    ben_ELIG_OBJ_ELIG_PROFL_bk1.create_ELIG_OBJ_ELIG_PROFL_a
      (
       p_elig_obj_elig_prfl_id               =>  l_elig_obj_elig_prfl_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_business_group_id              =>  p_business_group_id
      ,p_elig_obj_id                    =>  p_elig_obj_id
      ,p_elig_prfl_id                   =>  p_elig_prfl_id
      ,p_mndtry_flag                    =>  p_mndtry_flag
      ,p_bep_attribute_category         =>  p_bep_attribute_category
      ,p_bep_attribute1                 =>  p_bep_attribute1
      ,p_bep_attribute2                 =>  p_bep_attribute2
      ,p_bep_attribute3                 =>  p_bep_attribute3
      ,p_bep_attribute4                 =>  p_bep_attribute4
      ,p_bep_attribute5                 =>  p_bep_attribute5
      ,p_bep_attribute6                 =>  p_bep_attribute6
      ,p_bep_attribute7                 =>  p_bep_attribute7
      ,p_bep_attribute8                 =>  p_bep_attribute8
      ,p_bep_attribute9                 =>  p_bep_attribute9
      ,p_bep_attribute10                =>  p_bep_attribute10
      ,p_bep_attribute11                =>  p_bep_attribute11
      ,p_bep_attribute12                =>  p_bep_attribute12
      ,p_bep_attribute13                =>  p_bep_attribute13
      ,p_bep_attribute14                =>  p_bep_attribute14
      ,p_bep_attribute15                =>  p_bep_attribute15
      ,p_bep_attribute16                =>  p_bep_attribute16
      ,p_bep_attribute17                =>  p_bep_attribute17
      ,p_bep_attribute18                =>  p_bep_attribute18
      ,p_bep_attribute19                =>  p_bep_attribute19
      ,p_bep_attribute20                =>  p_bep_attribute20
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_ELIG_OBJ_ELIG_PROFL'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_ELIG_OBJ_ELIG_PROFL
    --
  end;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_elig_obj_elig_prfl_id := l_elig_obj_elig_prfl_id;
  p_effective_start_date := l_effective_start_date;
  p_effective_end_date := l_effective_end_date;
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_ELIG_OBJ_ELIG_PROFL;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_elig_obj_elig_prfl_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_ELIG_OBJ_ELIG_PROFL;
    raise;
    --
end create_ELIG_OBJ_ELIG_PROFL;
-- ----------------------------------------------------------------------------
-- |------------------------< update_ELIG_OBJ_ELIG_PROFL >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_ELIG_OBJ_ELIG_PROFL
  (p_validate                       in  boolean   default false
  ,p_elig_obj_elig_prfl_id          in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_elig_obj_id                    in  number    default hr_api.g_number
  ,p_elig_prfl_id                   in  number    default hr_api.g_number
  ,p_mndtry_flag                    in  varchar2  default hr_api.g_varchar2
  ,p_bep_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_bep_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_bep_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_bep_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_bep_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_bep_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_bep_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_bep_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_bep_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_bep_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_bep_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_bep_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_bep_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_bep_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_bep_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_bep_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_bep_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_bep_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_bep_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_bep_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_bep_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_ELIG_OBJ_ELIG_PROFL';
  l_object_version_number ben_elig_obj_elig_profl_f.object_version_number%TYPE;
  l_effective_start_date ben_elig_obj_elig_profl_f.effective_start_date%TYPE;
  l_effective_end_date ben_elig_obj_elig_profl_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_ELIG_OBJ_ELIG_PROFL;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_ELIG_OBJ_ELIG_PROFL
    --
    ben_ELIG_OBJ_ELIG_PROFL_bk2.update_ELIG_OBJ_ELIG_PROFL_b
      (
       p_elig_obj_elig_prfl_id               =>  p_elig_obj_elig_prfl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_elig_obj_id                    =>  p_elig_obj_id
      ,p_elig_prfl_id                   =>  p_elig_prfl_id
      ,p_mndtry_flag                    =>  p_mndtry_flag
      ,p_bep_attribute_category         =>  p_bep_attribute_category
      ,p_bep_attribute1                 =>  p_bep_attribute1
      ,p_bep_attribute2                 =>  p_bep_attribute2
      ,p_bep_attribute3                 =>  p_bep_attribute3
      ,p_bep_attribute4                 =>  p_bep_attribute4
      ,p_bep_attribute5                 =>  p_bep_attribute5
      ,p_bep_attribute6                 =>  p_bep_attribute6
      ,p_bep_attribute7                 =>  p_bep_attribute7
      ,p_bep_attribute8                 =>  p_bep_attribute8
      ,p_bep_attribute9                 =>  p_bep_attribute9
      ,p_bep_attribute10                =>  p_bep_attribute10
      ,p_bep_attribute11                =>  p_bep_attribute11
      ,p_bep_attribute12                =>  p_bep_attribute12
      ,p_bep_attribute13                =>  p_bep_attribute13
      ,p_bep_attribute14                =>  p_bep_attribute14
      ,p_bep_attribute15                =>  p_bep_attribute15
      ,p_bep_attribute16                =>  p_bep_attribute16
      ,p_bep_attribute17                =>  p_bep_attribute17
      ,p_bep_attribute18                =>  p_bep_attribute18
      ,p_bep_attribute19                =>  p_bep_attribute19
      ,p_bep_attribute20                =>  p_bep_attribute20
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ELIG_OBJ_ELIG_PROFL'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_ELIG_OBJ_ELIG_PROFL
    --
  end;
  --
  ben_bep_upd.upd
    (
     p_elig_obj_elig_prfl_id              => p_elig_obj_elig_prfl_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_business_group_id             => p_business_group_id
    ,p_elig_obj_id                    =>  p_elig_obj_id
    ,p_elig_prfl_id                   =>  p_elig_prfl_id
    ,p_mndtry_flag                    =>  p_mndtry_flag
    ,p_bep_attribute_category        => p_bep_attribute_category
    ,p_bep_attribute1                => p_bep_attribute1
    ,p_bep_attribute2                => p_bep_attribute2
    ,p_bep_attribute3                => p_bep_attribute3
    ,p_bep_attribute4                => p_bep_attribute4
    ,p_bep_attribute5                => p_bep_attribute5
    ,p_bep_attribute6                => p_bep_attribute6
    ,p_bep_attribute7                => p_bep_attribute7
    ,p_bep_attribute8                => p_bep_attribute8
    ,p_bep_attribute9                => p_bep_attribute9
    ,p_bep_attribute10               => p_bep_attribute10
    ,p_bep_attribute11               => p_bep_attribute11
    ,p_bep_attribute12               => p_bep_attribute12
    ,p_bep_attribute13               => p_bep_attribute13
    ,p_bep_attribute14               => p_bep_attribute14
    ,p_bep_attribute15               => p_bep_attribute15
    ,p_bep_attribute16               => p_bep_attribute16
    ,p_bep_attribute17               => p_bep_attribute17
    ,p_bep_attribute18               => p_bep_attribute18
    ,p_bep_attribute19               => p_bep_attribute19
    ,p_bep_attribute20               => p_bep_attribute20
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_ELIG_OBJ_ELIG_PROFL
    --
    ben_ELIG_OBJ_ELIG_PROFL_bk2.update_ELIG_OBJ_ELIG_PROFL_a
      (
       p_elig_obj_elig_prfl_id               =>  p_elig_obj_elig_prfl_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_business_group_id              =>  p_business_group_id
      ,p_elig_obj_id                    =>  p_elig_obj_id
      ,p_elig_prfl_id                   =>  p_elig_prfl_id
      ,p_mndtry_flag                    =>  p_mndtry_flag
      ,p_bep_attribute_category         =>  p_bep_attribute_category
      ,p_bep_attribute1                 =>  p_bep_attribute1
      ,p_bep_attribute2                 =>  p_bep_attribute2
      ,p_bep_attribute3                 =>  p_bep_attribute3
      ,p_bep_attribute4                 =>  p_bep_attribute4
      ,p_bep_attribute5                 =>  p_bep_attribute5
      ,p_bep_attribute6                 =>  p_bep_attribute6
      ,p_bep_attribute7                 =>  p_bep_attribute7
      ,p_bep_attribute8                 =>  p_bep_attribute8
      ,p_bep_attribute9                 =>  p_bep_attribute9
      ,p_bep_attribute10                =>  p_bep_attribute10
      ,p_bep_attribute11                =>  p_bep_attribute11
      ,p_bep_attribute12                =>  p_bep_attribute12
      ,p_bep_attribute13                =>  p_bep_attribute13
      ,p_bep_attribute14                =>  p_bep_attribute14
      ,p_bep_attribute15                =>  p_bep_attribute15
      ,p_bep_attribute16                =>  p_bep_attribute16
      ,p_bep_attribute17                =>  p_bep_attribute17
      ,p_bep_attribute18                =>  p_bep_attribute18
      ,p_bep_attribute19                =>  p_bep_attribute19
      ,p_bep_attribute20                =>  p_bep_attribute20
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ELIG_OBJ_ELIG_PROFL'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_ELIG_OBJ_ELIG_PROFL
    --
  end;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_object_version_number := l_object_version_number;
  p_effective_start_date := l_effective_start_date;
  p_effective_end_date := l_effective_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_ELIG_OBJ_ELIG_PROFL;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO update_ELIG_OBJ_ELIG_PROFL;
    raise;
    --
end update_ELIG_OBJ_ELIG_PROFL;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_ELIG_OBJ_ELIG_PROFL >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ELIG_OBJ_ELIG_PROFL
  (p_validate                       in  boolean  default false
  ,p_elig_obj_elig_prfl_id               in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_ELIG_OBJ_ELIG_PROFL';
  l_object_version_number ben_elig_obj_elig_profl_f.object_version_number%TYPE;
  l_effective_start_date ben_elig_obj_elig_profl_f.effective_start_date%TYPE;
  l_effective_end_date ben_elig_obj_elig_profl_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_ELIG_OBJ_ELIG_PROFL;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  --
  begin
    --
    -- Start of API User Hook for the before hook of delete_ELIG_OBJ_ELIG_PROFL
    --
    ben_ELIG_OBJ_ELIG_PROFL_bk3.delete_ELIG_OBJ_ELIG_PROFL_b
      (
       p_elig_obj_elig_prfl_id               =>  p_elig_obj_elig_prfl_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ELIG_OBJ_ELIG_PROFL'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_ELIG_OBJ_ELIG_PROFL
    --
  end;
  --
  ben_bep_del.del
    (
     p_elig_obj_elig_prfl_id              => p_elig_obj_elig_prfl_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_ELIG_OBJ_ELIG_PROFL
    --
    ben_ELIG_OBJ_ELIG_PROFL_bk3.delete_ELIG_OBJ_ELIG_PROFL_a
      (
       p_elig_obj_elig_prfl_id               =>  p_elig_obj_elig_prfl_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ELIG_OBJ_ELIG_PROFL'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_ELIG_OBJ_ELIG_PROFL
    --
  end;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_ELIG_OBJ_ELIG_PROFL;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_effective_start_date := null;
    p_effective_end_date := null;
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_ELIG_OBJ_ELIG_PROFL;
    raise;
    --
end delete_ELIG_OBJ_ELIG_PROFL;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_elig_obj_elig_prfl_id                   in     number
  ,p_object_version_number          in     number
  ,p_effective_date                 in     date
  ,p_datetrack_mode                 in     varchar2
  ,p_validation_start_date          out nocopy    date
  ,p_validation_end_date            out nocopy    date
  ) is
  --
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'lck';
  l_validation_start_date date;
  l_validation_end_date date;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  ben_bep_shd.lck
    (
      p_elig_obj_elig_prfl_id                 => p_elig_obj_elig_prfl_id
     ,p_validation_start_date      => l_validation_start_date
     ,p_validation_end_date        => l_validation_end_date
     ,p_object_version_number      => p_object_version_number
     ,p_effective_date             => p_effective_date
     ,p_datetrack_mode             => p_datetrack_mode
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_ELIG_OBJ_ELIG_PROFL_api;

/
