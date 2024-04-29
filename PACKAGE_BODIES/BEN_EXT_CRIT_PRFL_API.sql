--------------------------------------------------------
--  DDL for Package Body BEN_EXT_CRIT_PRFL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EXT_CRIT_PRFL_API" as
/* $Header: bexcrapi.pkb 120.0 2005/05/28 12:25:07 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_EXT_CRIT_PRFL_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_EXT_CRIT_PRFL >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_EXT_CRIT_PRFL
  (p_validate                       in  boolean   default false
  ,p_ext_crit_prfl_id               out nocopy number
  ,p_name                           in  varchar2  default null
  ,p_business_group_id              in  number    default null
  ,p_legislation_code               in  varchar2  default null
  ,p_xcr_attribute_category         in  varchar2  default null
  ,p_xcr_attribute1                 in  varchar2  default null
  ,p_xcr_attribute2                 in  varchar2  default null
  ,p_xcr_attribute3                 in  varchar2  default null
  ,p_xcr_attribute4                 in  varchar2  default null
  ,p_xcr_attribute5                 in  varchar2  default null
  ,p_xcr_attribute6                 in  varchar2  default null
  ,p_xcr_attribute7                 in  varchar2  default null
  ,p_xcr_attribute8                 in  varchar2  default null
  ,p_xcr_attribute9                 in  varchar2  default null
  ,p_xcr_attribute10                in  varchar2  default null
  ,p_xcr_attribute11                in  varchar2  default null
  ,p_xcr_attribute12                in  varchar2  default null
  ,p_xcr_attribute13                in  varchar2  default null
  ,p_xcr_attribute14                in  varchar2  default null
  ,p_xcr_attribute15                in  varchar2  default null
  ,p_xcr_attribute16                in  varchar2  default null
  ,p_xcr_attribute17                in  varchar2  default null
  ,p_xcr_attribute18                in  varchar2  default null
  ,p_xcr_attribute19                in  varchar2  default null
  ,p_xcr_attribute20                in  varchar2  default null
  ,p_xcr_attribute21                in  varchar2  default null
  ,p_xcr_attribute22                in  varchar2  default null
  ,p_xcr_attribute23                in  varchar2  default null
  ,p_xcr_attribute24                in  varchar2  default null
  ,p_xcr_attribute25                in  varchar2  default null
  ,p_xcr_attribute26                in  varchar2  default null
  ,p_xcr_attribute27                in  varchar2  default null
  ,p_xcr_attribute28                in  varchar2  default null
  ,p_xcr_attribute29                in  varchar2  default null
  ,p_xcr_attribute30                in  varchar2  default null
  ,p_ext_global_flag                in  varchar2  default 'N'
  ,p_object_version_number          out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_ext_crit_prfl_id ben_ext_crit_prfl.ext_crit_prfl_id%TYPE;
  l_proc varchar2(72) := g_package||'create_EXT_CRIT_PRFL';
  l_object_version_number ben_ext_crit_prfl.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_EXT_CRIT_PRFL;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_EXT_CRIT_PRFL
    --
    ben_EXT_CRIT_PRFL_bk1.create_EXT_CRIT_PRFL_b
      (
       p_name                           =>  p_name
      ,p_business_group_id              =>  p_business_group_id
      ,p_legislation_code               =>  p_legislation_code
      ,p_xcr_attribute_category         =>  p_xcr_attribute_category
      ,p_xcr_attribute1                 =>  p_xcr_attribute1
      ,p_xcr_attribute2                 =>  p_xcr_attribute2
      ,p_xcr_attribute3                 =>  p_xcr_attribute3
      ,p_xcr_attribute4                 =>  p_xcr_attribute4
      ,p_xcr_attribute5                 =>  p_xcr_attribute5
      ,p_xcr_attribute6                 =>  p_xcr_attribute6
      ,p_xcr_attribute7                 =>  p_xcr_attribute7
      ,p_xcr_attribute8                 =>  p_xcr_attribute8
      ,p_xcr_attribute9                 =>  p_xcr_attribute9
      ,p_xcr_attribute10                =>  p_xcr_attribute10
      ,p_xcr_attribute11                =>  p_xcr_attribute11
      ,p_xcr_attribute12                =>  p_xcr_attribute12
      ,p_xcr_attribute13                =>  p_xcr_attribute13
      ,p_xcr_attribute14                =>  p_xcr_attribute14
      ,p_xcr_attribute15                =>  p_xcr_attribute15
      ,p_xcr_attribute16                =>  p_xcr_attribute16
      ,p_xcr_attribute17                =>  p_xcr_attribute17
      ,p_xcr_attribute18                =>  p_xcr_attribute18
      ,p_xcr_attribute19                =>  p_xcr_attribute19
      ,p_xcr_attribute20                =>  p_xcr_attribute20
      ,p_xcr_attribute21                =>  p_xcr_attribute21
      ,p_xcr_attribute22                =>  p_xcr_attribute22
      ,p_xcr_attribute23                =>  p_xcr_attribute23
      ,p_xcr_attribute24                =>  p_xcr_attribute24
      ,p_xcr_attribute25                =>  p_xcr_attribute25
      ,p_xcr_attribute26                =>  p_xcr_attribute26
      ,p_xcr_attribute27                =>  p_xcr_attribute27
      ,p_xcr_attribute28                =>  p_xcr_attribute28
      ,p_xcr_attribute29                =>  p_xcr_attribute29
      ,p_xcr_attribute30                =>  p_xcr_attribute30
      ,p_ext_global_flag                =>  p_ext_global_flag
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_EXT_CRIT_PRFL'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_EXT_CRIT_PRFL
    --
  end;
  --
  ben_xcr_ins.ins
    (
     p_ext_crit_prfl_id              => l_ext_crit_prfl_id
    ,p_name                          => p_name
    ,p_business_group_id             => p_business_group_id
    ,p_legislation_code              => p_legislation_code
    ,p_xcr_attribute_category        => p_xcr_attribute_category
    ,p_xcr_attribute1                => p_xcr_attribute1
    ,p_xcr_attribute2                => p_xcr_attribute2
    ,p_xcr_attribute3                => p_xcr_attribute3
    ,p_xcr_attribute4                => p_xcr_attribute4
    ,p_xcr_attribute5                => p_xcr_attribute5
    ,p_xcr_attribute6                => p_xcr_attribute6
    ,p_xcr_attribute7                => p_xcr_attribute7
    ,p_xcr_attribute8                => p_xcr_attribute8
    ,p_xcr_attribute9                => p_xcr_attribute9
    ,p_xcr_attribute10               => p_xcr_attribute10
    ,p_xcr_attribute11               => p_xcr_attribute11
    ,p_xcr_attribute12               => p_xcr_attribute12
    ,p_xcr_attribute13               => p_xcr_attribute13
    ,p_xcr_attribute14               => p_xcr_attribute14
    ,p_xcr_attribute15               => p_xcr_attribute15
    ,p_xcr_attribute16               => p_xcr_attribute16
    ,p_xcr_attribute17               => p_xcr_attribute17
    ,p_xcr_attribute18               => p_xcr_attribute18
    ,p_xcr_attribute19               => p_xcr_attribute19
    ,p_xcr_attribute20               => p_xcr_attribute20
    ,p_xcr_attribute21               => p_xcr_attribute21
    ,p_xcr_attribute22               => p_xcr_attribute22
    ,p_xcr_attribute23               => p_xcr_attribute23
    ,p_xcr_attribute24               => p_xcr_attribute24
    ,p_xcr_attribute25               => p_xcr_attribute25
    ,p_xcr_attribute26               => p_xcr_attribute26
    ,p_xcr_attribute27               => p_xcr_attribute27
    ,p_xcr_attribute28               => p_xcr_attribute28
    ,p_xcr_attribute29               => p_xcr_attribute29
    ,p_xcr_attribute30               => p_xcr_attribute30
    ,p_ext_global_flag               => p_ext_global_flag
    ,p_object_version_number         => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_EXT_CRIT_PRFL
    --
    ben_EXT_CRIT_PRFL_bk1.create_EXT_CRIT_PRFL_a
      (
       p_ext_crit_prfl_id               =>  l_ext_crit_prfl_id
      ,p_name                           =>  p_name
      ,p_business_group_id              =>  p_business_group_id
      ,p_legislation_code               =>  p_legislation_code
      ,p_xcr_attribute_category         =>  p_xcr_attribute_category
      ,p_xcr_attribute1                 =>  p_xcr_attribute1
      ,p_xcr_attribute2                 =>  p_xcr_attribute2
      ,p_xcr_attribute3                 =>  p_xcr_attribute3
      ,p_xcr_attribute4                 =>  p_xcr_attribute4
      ,p_xcr_attribute5                 =>  p_xcr_attribute5
      ,p_xcr_attribute6                 =>  p_xcr_attribute6
      ,p_xcr_attribute7                 =>  p_xcr_attribute7
      ,p_xcr_attribute8                 =>  p_xcr_attribute8
      ,p_xcr_attribute9                 =>  p_xcr_attribute9
      ,p_xcr_attribute10                =>  p_xcr_attribute10
      ,p_xcr_attribute11                =>  p_xcr_attribute11
      ,p_xcr_attribute12                =>  p_xcr_attribute12
      ,p_xcr_attribute13                =>  p_xcr_attribute13
      ,p_xcr_attribute14                =>  p_xcr_attribute14
      ,p_xcr_attribute15                =>  p_xcr_attribute15
      ,p_xcr_attribute16                =>  p_xcr_attribute16
      ,p_xcr_attribute17                =>  p_xcr_attribute17
      ,p_xcr_attribute18                =>  p_xcr_attribute18
      ,p_xcr_attribute19                =>  p_xcr_attribute19
      ,p_xcr_attribute20                =>  p_xcr_attribute20
      ,p_xcr_attribute21                =>  p_xcr_attribute21
      ,p_xcr_attribute22                =>  p_xcr_attribute22
      ,p_xcr_attribute23                =>  p_xcr_attribute23
      ,p_xcr_attribute24                =>  p_xcr_attribute24
      ,p_xcr_attribute25                =>  p_xcr_attribute25
      ,p_xcr_attribute26                =>  p_xcr_attribute26
      ,p_xcr_attribute27                =>  p_xcr_attribute27
      ,p_xcr_attribute28                =>  p_xcr_attribute28
      ,p_xcr_attribute29                =>  p_xcr_attribute29
      ,p_xcr_attribute30                =>  p_xcr_attribute30
      ,p_ext_global_flag                =>  p_ext_global_flag
      ,p_object_version_number          =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_EXT_CRIT_PRFL'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_EXT_CRIT_PRFL
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
  p_ext_crit_prfl_id := l_ext_crit_prfl_id;
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
    ROLLBACK TO create_EXT_CRIT_PRFL;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_ext_crit_prfl_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_EXT_CRIT_PRFL;
    /* Inserted for nocopy changes */
    p_ext_crit_prfl_id := null;
    p_object_version_number  := null;
    raise;
    --
end create_EXT_CRIT_PRFL;
-- ----------------------------------------------------------------------------
-- |------------------------< update_EXT_CRIT_PRFL >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_EXT_CRIT_PRFL
  (p_validate                       in  boolean   default false
  ,p_ext_crit_prfl_id               in  number
  ,p_name                           in  varchar2  default hr_api.g_varchar2
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_legislation_code               in  varchar2  default hr_api.g_varchar2
  ,p_xcr_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_xcr_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_xcr_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_xcr_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_xcr_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_xcr_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_xcr_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_xcr_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_xcr_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_xcr_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_xcr_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_xcr_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_xcr_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_xcr_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_xcr_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_xcr_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_xcr_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_xcr_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_xcr_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_xcr_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_xcr_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_xcr_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_xcr_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_xcr_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_xcr_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_xcr_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_xcr_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_xcr_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_xcr_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_xcr_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_xcr_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_ext_global_flag                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_EXT_CRIT_PRFL';
  l_object_version_number ben_ext_crit_prfl.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_EXT_CRIT_PRFL;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_EXT_CRIT_PRFL
    --
    ben_EXT_CRIT_PRFL_bk2.update_EXT_CRIT_PRFL_b
      (
       p_ext_crit_prfl_id               =>  p_ext_crit_prfl_id
      ,p_name                           =>  p_name
      ,p_business_group_id              =>  p_business_group_id
      ,p_legislation_code               =>  p_legislation_code
      ,p_xcr_attribute_category         =>  p_xcr_attribute_category
      ,p_xcr_attribute1                 =>  p_xcr_attribute1
      ,p_xcr_attribute2                 =>  p_xcr_attribute2
      ,p_xcr_attribute3                 =>  p_xcr_attribute3
      ,p_xcr_attribute4                 =>  p_xcr_attribute4
      ,p_xcr_attribute5                 =>  p_xcr_attribute5
      ,p_xcr_attribute6                 =>  p_xcr_attribute6
      ,p_xcr_attribute7                 =>  p_xcr_attribute7
      ,p_xcr_attribute8                 =>  p_xcr_attribute8
      ,p_xcr_attribute9                 =>  p_xcr_attribute9
      ,p_xcr_attribute10                =>  p_xcr_attribute10
      ,p_xcr_attribute11                =>  p_xcr_attribute11
      ,p_xcr_attribute12                =>  p_xcr_attribute12
      ,p_xcr_attribute13                =>  p_xcr_attribute13
      ,p_xcr_attribute14                =>  p_xcr_attribute14
      ,p_xcr_attribute15                =>  p_xcr_attribute15
      ,p_xcr_attribute16                =>  p_xcr_attribute16
      ,p_xcr_attribute17                =>  p_xcr_attribute17
      ,p_xcr_attribute18                =>  p_xcr_attribute18
      ,p_xcr_attribute19                =>  p_xcr_attribute19
      ,p_xcr_attribute20                =>  p_xcr_attribute20
      ,p_xcr_attribute21                =>  p_xcr_attribute21
      ,p_xcr_attribute22                =>  p_xcr_attribute22
      ,p_xcr_attribute23                =>  p_xcr_attribute23
      ,p_xcr_attribute24                =>  p_xcr_attribute24
      ,p_xcr_attribute25                =>  p_xcr_attribute25
      ,p_xcr_attribute26                =>  p_xcr_attribute26
      ,p_xcr_attribute27                =>  p_xcr_attribute27
      ,p_xcr_attribute28                =>  p_xcr_attribute28
      ,p_xcr_attribute29                =>  p_xcr_attribute29
      ,p_xcr_attribute30                =>  p_xcr_attribute30
      ,p_ext_global_flag                =>  p_ext_global_flag
      ,p_object_version_number          =>  p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_EXT_CRIT_PRFL'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_EXT_CRIT_PRFL
    --
  end;
  --
  ben_xcr_upd.upd
    (
     p_ext_crit_prfl_id              => p_ext_crit_prfl_id
    ,p_name                          => p_name
    ,p_business_group_id             => p_business_group_id
    ,p_legislation_code              => p_legislation_code
    ,p_xcr_attribute_category        => p_xcr_attribute_category
    ,p_xcr_attribute1                => p_xcr_attribute1
    ,p_xcr_attribute2                => p_xcr_attribute2
    ,p_xcr_attribute3                => p_xcr_attribute3
    ,p_xcr_attribute4                => p_xcr_attribute4
    ,p_xcr_attribute5                => p_xcr_attribute5
    ,p_xcr_attribute6                => p_xcr_attribute6
    ,p_xcr_attribute7                => p_xcr_attribute7
    ,p_xcr_attribute8                => p_xcr_attribute8
    ,p_xcr_attribute9                => p_xcr_attribute9
    ,p_xcr_attribute10               => p_xcr_attribute10
    ,p_xcr_attribute11               => p_xcr_attribute11
    ,p_xcr_attribute12               => p_xcr_attribute12
    ,p_xcr_attribute13               => p_xcr_attribute13
    ,p_xcr_attribute14               => p_xcr_attribute14
    ,p_xcr_attribute15               => p_xcr_attribute15
    ,p_xcr_attribute16               => p_xcr_attribute16
    ,p_xcr_attribute17               => p_xcr_attribute17
    ,p_xcr_attribute18               => p_xcr_attribute18
    ,p_xcr_attribute19               => p_xcr_attribute19
    ,p_xcr_attribute20               => p_xcr_attribute20
    ,p_xcr_attribute21               => p_xcr_attribute21
    ,p_xcr_attribute22               => p_xcr_attribute22
    ,p_xcr_attribute23               => p_xcr_attribute23
    ,p_xcr_attribute24               => p_xcr_attribute24
    ,p_xcr_attribute25               => p_xcr_attribute25
    ,p_xcr_attribute26               => p_xcr_attribute26
    ,p_xcr_attribute27               => p_xcr_attribute27
    ,p_xcr_attribute28               => p_xcr_attribute28
    ,p_xcr_attribute29               => p_xcr_attribute29
    ,p_xcr_attribute30               => p_xcr_attribute30
    ,p_ext_global_flag               => p_ext_global_flag
    ,p_object_version_number         => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_EXT_CRIT_PRFL
    --
    ben_EXT_CRIT_PRFL_bk2.update_EXT_CRIT_PRFL_a
      (
       p_ext_crit_prfl_id               =>  p_ext_crit_prfl_id
      ,p_name                           =>  p_name
      ,p_business_group_id              =>  p_business_group_id
      ,p_legislation_code               =>  p_legislation_code
      ,p_xcr_attribute_category         =>  p_xcr_attribute_category
      ,p_xcr_attribute1                 =>  p_xcr_attribute1
      ,p_xcr_attribute2                 =>  p_xcr_attribute2
      ,p_xcr_attribute3                 =>  p_xcr_attribute3
      ,p_xcr_attribute4                 =>  p_xcr_attribute4
      ,p_xcr_attribute5                 =>  p_xcr_attribute5
      ,p_xcr_attribute6                 =>  p_xcr_attribute6
      ,p_xcr_attribute7                 =>  p_xcr_attribute7
      ,p_xcr_attribute8                 =>  p_xcr_attribute8
      ,p_xcr_attribute9                 =>  p_xcr_attribute9
      ,p_xcr_attribute10                =>  p_xcr_attribute10
      ,p_xcr_attribute11                =>  p_xcr_attribute11
      ,p_xcr_attribute12                =>  p_xcr_attribute12
      ,p_xcr_attribute13                =>  p_xcr_attribute13
      ,p_xcr_attribute14                =>  p_xcr_attribute14
      ,p_xcr_attribute15                =>  p_xcr_attribute15
      ,p_xcr_attribute16                =>  p_xcr_attribute16
      ,p_xcr_attribute17                =>  p_xcr_attribute17
      ,p_xcr_attribute18                =>  p_xcr_attribute18
      ,p_xcr_attribute19                =>  p_xcr_attribute19
      ,p_xcr_attribute20                =>  p_xcr_attribute20
      ,p_xcr_attribute21                =>  p_xcr_attribute21
      ,p_xcr_attribute22                =>  p_xcr_attribute22
      ,p_xcr_attribute23                =>  p_xcr_attribute23
      ,p_xcr_attribute24                =>  p_xcr_attribute24
      ,p_xcr_attribute25                =>  p_xcr_attribute25
      ,p_xcr_attribute26                =>  p_xcr_attribute26
      ,p_xcr_attribute27                =>  p_xcr_attribute27
      ,p_xcr_attribute28                =>  p_xcr_attribute28
      ,p_xcr_attribute29                =>  p_xcr_attribute29
      ,p_xcr_attribute30                =>  p_xcr_attribute30
      ,p_ext_global_flag                =>  p_ext_global_flag
      ,p_object_version_number          =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_EXT_CRIT_PRFL'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_EXT_CRIT_PRFL
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
    ROLLBACK TO update_EXT_CRIT_PRFL;
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
    ROLLBACK TO update_EXT_CRIT_PRFL;
    /* Inserted for nocopy changes */
    p_object_version_number := l_object_version_number;
    raise;
    --
end update_EXT_CRIT_PRFL;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_EXT_CRIT_PRFL >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_EXT_CRIT_PRFL
  (p_validate                       in  boolean  default false
  ,p_ext_crit_prfl_id               in  number
  ,p_legislation_code               in  varchar2 default null
  ,p_object_version_number          in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_EXT_CRIT_PRFL';
  l_object_version_number ben_ext_crit_prfl.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_EXT_CRIT_PRFL;
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
    -- Start of API User Hook for the before hook of delete_EXT_CRIT_PRFL
    --
    ben_EXT_CRIT_PRFL_bk3.delete_EXT_CRIT_PRFL_b
      (
       p_ext_crit_prfl_id               =>  p_ext_crit_prfl_id
      ,p_legislation_code               =>  p_legislation_code
      ,p_object_version_number          =>  p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_EXT_CRIT_PRFL'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_EXT_CRIT_PRFL
    --
  end;
  --
  ben_xcr_del.del
    (
     p_ext_crit_prfl_id              => p_ext_crit_prfl_id
     ,p_legislation_code             => p_legislation_code
    ,p_object_version_number         => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_EXT_CRIT_PRFL
    --
    ben_EXT_CRIT_PRFL_bk3.delete_EXT_CRIT_PRFL_a
      (
       p_ext_crit_prfl_id               =>  p_ext_crit_prfl_id
      ,p_legislation_code               =>  p_legislation_code
      ,p_object_version_number          =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_EXT_CRIT_PRFL'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_EXT_CRIT_PRFL
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
    ROLLBACK TO delete_EXT_CRIT_PRFL;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_EXT_CRIT_PRFL;
    /* Inserted for nocopy changes */
    p_object_version_number := l_object_version_number;
    raise;
    --
end delete_EXT_CRIT_PRFL;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_ext_crit_prfl_id                   in     number
  ,p_object_version_number          in     number
  ) is
  --
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'lck';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  ben_xcr_shd.lck
    (
      p_ext_crit_prfl_id                 => p_ext_crit_prfl_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_EXT_CRIT_PRFL_api;

/
