--------------------------------------------------------
--  DDL for Package Body BEN_POSTAL_ZIP_RANGE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_POSTAL_ZIP_RANGE_API" as
/* $Header: berzrapi.pkb 115.2 2002/12/16 09:37:41 hnarayan ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_postal_zip_range_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_postal_zip_range >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_postal_zip_range
  (p_validate                       in  boolean   default false
  ,p_pstl_zip_rng_id                out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_from_value                     in  varchar2      default null
  ,p_to_value                       in  varchar2  default null
  ,p_business_group_id              in  number    default null
  ,p_rzr_attribute_category         in  varchar2  default null
  ,p_rzr_attribute1                 in  varchar2  default null
  ,p_rzr_attribute10                in  varchar2  default null
  ,p_rzr_attribute11                in  varchar2  default null
  ,p_rzr_attribute12                in  varchar2  default null
  ,p_rzr_attribute13                in  varchar2  default null
  ,p_rzr_attribute14                in  varchar2  default null
  ,p_rzr_attribute15                in  varchar2  default null
  ,p_rzr_attribute16                in  varchar2  default null
  ,p_rzr_attribute17                in  varchar2  default null
  ,p_rzr_attribute18                in  varchar2  default null
  ,p_rzr_attribute19                in  varchar2  default null
  ,p_rzr_attribute2                 in  varchar2  default null
  ,p_rzr_attribute20                in  varchar2  default null
  ,p_rzr_attribute21                in  varchar2  default null
  ,p_rzr_attribute22                in  varchar2  default null
  ,p_rzr_attribute23                in  varchar2  default null
  ,p_rzr_attribute24                in  varchar2  default null
  ,p_rzr_attribute25                in  varchar2  default null
  ,p_rzr_attribute26                in  varchar2  default null
  ,p_rzr_attribute27                in  varchar2  default null
  ,p_rzr_attribute28                in  varchar2  default null
  ,p_rzr_attribute29                in  varchar2  default null
  ,p_rzr_attribute3                 in  varchar2  default null
  ,p_rzr_attribute30                in  varchar2  default null
  ,p_rzr_attribute4                 in  varchar2  default null
  ,p_rzr_attribute5                 in  varchar2  default null
  ,p_rzr_attribute6                 in  varchar2  default null
  ,p_rzr_attribute7                 in  varchar2  default null
  ,p_rzr_attribute8                 in  varchar2  default null
  ,p_rzr_attribute9                 in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_pstl_zip_rng_id ben_pstl_zip_rng_f.pstl_zip_rng_id%TYPE;
  l_effective_start_date ben_pstl_zip_rng_f.effective_start_date%TYPE;
  l_effective_end_date ben_pstl_zip_rng_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_postal_zip_range';
  l_object_version_number ben_pstl_zip_rng_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_postal_zip_range;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_postal_zip_range
    --
    ben_postal_zip_range_bk1.create_postal_zip_range_b
      (
       p_from_value                     =>  p_from_value
      ,p_to_value                       =>  p_to_value
      ,p_business_group_id              =>  p_business_group_id
      ,p_rzr_attribute_category         =>  p_rzr_attribute_category
      ,p_rzr_attribute1                 =>  p_rzr_attribute1
      ,p_rzr_attribute10                =>  p_rzr_attribute10
      ,p_rzr_attribute11                =>  p_rzr_attribute11
      ,p_rzr_attribute12                =>  p_rzr_attribute12
      ,p_rzr_attribute13                =>  p_rzr_attribute13
      ,p_rzr_attribute14                =>  p_rzr_attribute14
      ,p_rzr_attribute15                =>  p_rzr_attribute15
      ,p_rzr_attribute16                =>  p_rzr_attribute16
      ,p_rzr_attribute17                =>  p_rzr_attribute17
      ,p_rzr_attribute18                =>  p_rzr_attribute18
      ,p_rzr_attribute19                =>  p_rzr_attribute19
      ,p_rzr_attribute2                 =>  p_rzr_attribute2
      ,p_rzr_attribute20                =>  p_rzr_attribute20
      ,p_rzr_attribute21                =>  p_rzr_attribute21
      ,p_rzr_attribute22                =>  p_rzr_attribute22
      ,p_rzr_attribute23                =>  p_rzr_attribute23
      ,p_rzr_attribute24                =>  p_rzr_attribute24
      ,p_rzr_attribute25                =>  p_rzr_attribute25
      ,p_rzr_attribute26                =>  p_rzr_attribute26
      ,p_rzr_attribute27                =>  p_rzr_attribute27
      ,p_rzr_attribute28                =>  p_rzr_attribute28
      ,p_rzr_attribute29                =>  p_rzr_attribute29
      ,p_rzr_attribute3                 =>  p_rzr_attribute3
      ,p_rzr_attribute30                =>  p_rzr_attribute30
      ,p_rzr_attribute4                 =>  p_rzr_attribute4
      ,p_rzr_attribute5                 =>  p_rzr_attribute5
      ,p_rzr_attribute6                 =>  p_rzr_attribute6
      ,p_rzr_attribute7                 =>  p_rzr_attribute7
      ,p_rzr_attribute8                 =>  p_rzr_attribute8
      ,p_rzr_attribute9                 =>  p_rzr_attribute9
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_postal_zip_range'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_postal_zip_range
    --
  end;
  --
  ben_rzr_ins.ins
    (
     p_pstl_zip_rng_id               => l_pstl_zip_rng_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_from_value                    => p_from_value
    ,p_to_value                      => p_to_value
    ,p_business_group_id             => p_business_group_id
    ,p_rzr_attribute_category        => p_rzr_attribute_category
    ,p_rzr_attribute1                => p_rzr_attribute1
    ,p_rzr_attribute10               => p_rzr_attribute10
    ,p_rzr_attribute11               => p_rzr_attribute11
    ,p_rzr_attribute12               => p_rzr_attribute12
    ,p_rzr_attribute13               => p_rzr_attribute13
    ,p_rzr_attribute14               => p_rzr_attribute14
    ,p_rzr_attribute15               => p_rzr_attribute15
    ,p_rzr_attribute16               => p_rzr_attribute16
    ,p_rzr_attribute17               => p_rzr_attribute17
    ,p_rzr_attribute18               => p_rzr_attribute18
    ,p_rzr_attribute19               => p_rzr_attribute19
    ,p_rzr_attribute2                => p_rzr_attribute2
    ,p_rzr_attribute20               => p_rzr_attribute20
    ,p_rzr_attribute21               => p_rzr_attribute21
    ,p_rzr_attribute22               => p_rzr_attribute22
    ,p_rzr_attribute23               => p_rzr_attribute23
    ,p_rzr_attribute24               => p_rzr_attribute24
    ,p_rzr_attribute25               => p_rzr_attribute25
    ,p_rzr_attribute26               => p_rzr_attribute26
    ,p_rzr_attribute27               => p_rzr_attribute27
    ,p_rzr_attribute28               => p_rzr_attribute28
    ,p_rzr_attribute29               => p_rzr_attribute29
    ,p_rzr_attribute3                => p_rzr_attribute3
    ,p_rzr_attribute30               => p_rzr_attribute30
    ,p_rzr_attribute4                => p_rzr_attribute4
    ,p_rzr_attribute5                => p_rzr_attribute5
    ,p_rzr_attribute6                => p_rzr_attribute6
    ,p_rzr_attribute7                => p_rzr_attribute7
    ,p_rzr_attribute8                => p_rzr_attribute8
    ,p_rzr_attribute9                => p_rzr_attribute9
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_postal_zip_range
    --
    ben_postal_zip_range_bk1.create_postal_zip_range_a
      (
       p_pstl_zip_rng_id                =>  l_pstl_zip_rng_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_from_value                     =>  p_from_value
      ,p_to_value                       =>  p_to_value
      ,p_business_group_id              =>  p_business_group_id
      ,p_rzr_attribute_category         =>  p_rzr_attribute_category
      ,p_rzr_attribute1                 =>  p_rzr_attribute1
      ,p_rzr_attribute10                =>  p_rzr_attribute10
      ,p_rzr_attribute11                =>  p_rzr_attribute11
      ,p_rzr_attribute12                =>  p_rzr_attribute12
      ,p_rzr_attribute13                =>  p_rzr_attribute13
      ,p_rzr_attribute14                =>  p_rzr_attribute14
      ,p_rzr_attribute15                =>  p_rzr_attribute15
      ,p_rzr_attribute16                =>  p_rzr_attribute16
      ,p_rzr_attribute17                =>  p_rzr_attribute17
      ,p_rzr_attribute18                =>  p_rzr_attribute18
      ,p_rzr_attribute19                =>  p_rzr_attribute19
      ,p_rzr_attribute2                 =>  p_rzr_attribute2
      ,p_rzr_attribute20                =>  p_rzr_attribute20
      ,p_rzr_attribute21                =>  p_rzr_attribute21
      ,p_rzr_attribute22                =>  p_rzr_attribute22
      ,p_rzr_attribute23                =>  p_rzr_attribute23
      ,p_rzr_attribute24                =>  p_rzr_attribute24
      ,p_rzr_attribute25                =>  p_rzr_attribute25
      ,p_rzr_attribute26                =>  p_rzr_attribute26
      ,p_rzr_attribute27                =>  p_rzr_attribute27
      ,p_rzr_attribute28                =>  p_rzr_attribute28
      ,p_rzr_attribute29                =>  p_rzr_attribute29
      ,p_rzr_attribute3                 =>  p_rzr_attribute3
      ,p_rzr_attribute30                =>  p_rzr_attribute30
      ,p_rzr_attribute4                 =>  p_rzr_attribute4
      ,p_rzr_attribute5                 =>  p_rzr_attribute5
      ,p_rzr_attribute6                 =>  p_rzr_attribute6
      ,p_rzr_attribute7                 =>  p_rzr_attribute7
      ,p_rzr_attribute8                 =>  p_rzr_attribute8
      ,p_rzr_attribute9                 =>  p_rzr_attribute9
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_postal_zip_range'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_postal_zip_range
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
  p_pstl_zip_rng_id := l_pstl_zip_rng_id;
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
    ROLLBACK TO create_postal_zip_range;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_pstl_zip_rng_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_postal_zip_range;
    p_pstl_zip_rng_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    raise;
    --
end create_postal_zip_range;
-- ----------------------------------------------------------------------------
-- |------------------------< update_postal_zip_range >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_postal_zip_range
  (p_validate                       in  boolean   default false
  ,p_pstl_zip_rng_id                in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_from_value                     in  varchar2
  ,p_to_value                       in  varchar2  default hr_api.g_varchar2
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_rzr_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_rzr_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_rzr_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_rzr_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_rzr_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_rzr_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_rzr_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_rzr_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_rzr_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_rzr_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_rzr_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_rzr_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_rzr_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_rzr_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_rzr_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_rzr_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_rzr_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_rzr_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_rzr_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_rzr_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_rzr_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_rzr_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_rzr_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_rzr_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_rzr_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_rzr_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_rzr_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_rzr_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_rzr_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_rzr_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_rzr_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_postal_zip_range';
  l_object_version_number ben_pstl_zip_rng_f.object_version_number%TYPE;
  l_effective_start_date ben_pstl_zip_rng_f.effective_start_date%TYPE;
  l_effective_end_date ben_pstl_zip_rng_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_postal_zip_range;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_postal_zip_range
    --
    ben_postal_zip_range_bk2.update_postal_zip_range_b
      (
       p_pstl_zip_rng_id                =>  p_pstl_zip_rng_id
      ,p_from_value                     =>  p_from_value
      ,p_to_value                       =>  p_to_value
      ,p_business_group_id              =>  p_business_group_id
      ,p_rzr_attribute_category         =>  p_rzr_attribute_category
      ,p_rzr_attribute1                 =>  p_rzr_attribute1
      ,p_rzr_attribute10                =>  p_rzr_attribute10
      ,p_rzr_attribute11                =>  p_rzr_attribute11
      ,p_rzr_attribute12                =>  p_rzr_attribute12
      ,p_rzr_attribute13                =>  p_rzr_attribute13
      ,p_rzr_attribute14                =>  p_rzr_attribute14
      ,p_rzr_attribute15                =>  p_rzr_attribute15
      ,p_rzr_attribute16                =>  p_rzr_attribute16
      ,p_rzr_attribute17                =>  p_rzr_attribute17
      ,p_rzr_attribute18                =>  p_rzr_attribute18
      ,p_rzr_attribute19                =>  p_rzr_attribute19
      ,p_rzr_attribute2                 =>  p_rzr_attribute2
      ,p_rzr_attribute20                =>  p_rzr_attribute20
      ,p_rzr_attribute21                =>  p_rzr_attribute21
      ,p_rzr_attribute22                =>  p_rzr_attribute22
      ,p_rzr_attribute23                =>  p_rzr_attribute23
      ,p_rzr_attribute24                =>  p_rzr_attribute24
      ,p_rzr_attribute25                =>  p_rzr_attribute25
      ,p_rzr_attribute26                =>  p_rzr_attribute26
      ,p_rzr_attribute27                =>  p_rzr_attribute27
      ,p_rzr_attribute28                =>  p_rzr_attribute28
      ,p_rzr_attribute29                =>  p_rzr_attribute29
      ,p_rzr_attribute3                 =>  p_rzr_attribute3
      ,p_rzr_attribute30                =>  p_rzr_attribute30
      ,p_rzr_attribute4                 =>  p_rzr_attribute4
      ,p_rzr_attribute5                 =>  p_rzr_attribute5
      ,p_rzr_attribute6                 =>  p_rzr_attribute6
      ,p_rzr_attribute7                 =>  p_rzr_attribute7
      ,p_rzr_attribute8                 =>  p_rzr_attribute8
      ,p_rzr_attribute9                 =>  p_rzr_attribute9
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_postal_zip_range'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_postal_zip_range
    --
  end;
  --
  ben_rzr_upd.upd
    (
     p_pstl_zip_rng_id               => p_pstl_zip_rng_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_from_value                    => p_from_value
    ,p_to_value                      => p_to_value
    ,p_business_group_id             => p_business_group_id
    ,p_rzr_attribute_category        => p_rzr_attribute_category
    ,p_rzr_attribute1                => p_rzr_attribute1
    ,p_rzr_attribute10               => p_rzr_attribute10
    ,p_rzr_attribute11               => p_rzr_attribute11
    ,p_rzr_attribute12               => p_rzr_attribute12
    ,p_rzr_attribute13               => p_rzr_attribute13
    ,p_rzr_attribute14               => p_rzr_attribute14
    ,p_rzr_attribute15               => p_rzr_attribute15
    ,p_rzr_attribute16               => p_rzr_attribute16
    ,p_rzr_attribute17               => p_rzr_attribute17
    ,p_rzr_attribute18               => p_rzr_attribute18
    ,p_rzr_attribute19               => p_rzr_attribute19
    ,p_rzr_attribute2                => p_rzr_attribute2
    ,p_rzr_attribute20               => p_rzr_attribute20
    ,p_rzr_attribute21               => p_rzr_attribute21
    ,p_rzr_attribute22               => p_rzr_attribute22
    ,p_rzr_attribute23               => p_rzr_attribute23
    ,p_rzr_attribute24               => p_rzr_attribute24
    ,p_rzr_attribute25               => p_rzr_attribute25
    ,p_rzr_attribute26               => p_rzr_attribute26
    ,p_rzr_attribute27               => p_rzr_attribute27
    ,p_rzr_attribute28               => p_rzr_attribute28
    ,p_rzr_attribute29               => p_rzr_attribute29
    ,p_rzr_attribute3                => p_rzr_attribute3
    ,p_rzr_attribute30               => p_rzr_attribute30
    ,p_rzr_attribute4                => p_rzr_attribute4
    ,p_rzr_attribute5                => p_rzr_attribute5
    ,p_rzr_attribute6                => p_rzr_attribute6
    ,p_rzr_attribute7                => p_rzr_attribute7
    ,p_rzr_attribute8                => p_rzr_attribute8
    ,p_rzr_attribute9                => p_rzr_attribute9
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_postal_zip_range
    --
    ben_postal_zip_range_bk2.update_postal_zip_range_a
      (
       p_pstl_zip_rng_id                =>  p_pstl_zip_rng_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_from_value                     =>  p_from_value
      ,p_to_value                       =>  p_to_value
      ,p_business_group_id              =>  p_business_group_id
      ,p_rzr_attribute_category         =>  p_rzr_attribute_category
      ,p_rzr_attribute1                 =>  p_rzr_attribute1
      ,p_rzr_attribute10                =>  p_rzr_attribute10
      ,p_rzr_attribute11                =>  p_rzr_attribute11
      ,p_rzr_attribute12                =>  p_rzr_attribute12
      ,p_rzr_attribute13                =>  p_rzr_attribute13
      ,p_rzr_attribute14                =>  p_rzr_attribute14
      ,p_rzr_attribute15                =>  p_rzr_attribute15
      ,p_rzr_attribute16                =>  p_rzr_attribute16
      ,p_rzr_attribute17                =>  p_rzr_attribute17
      ,p_rzr_attribute18                =>  p_rzr_attribute18
      ,p_rzr_attribute19                =>  p_rzr_attribute19
      ,p_rzr_attribute2                 =>  p_rzr_attribute2
      ,p_rzr_attribute20                =>  p_rzr_attribute20
      ,p_rzr_attribute21                =>  p_rzr_attribute21
      ,p_rzr_attribute22                =>  p_rzr_attribute22
      ,p_rzr_attribute23                =>  p_rzr_attribute23
      ,p_rzr_attribute24                =>  p_rzr_attribute24
      ,p_rzr_attribute25                =>  p_rzr_attribute25
      ,p_rzr_attribute26                =>  p_rzr_attribute26
      ,p_rzr_attribute27                =>  p_rzr_attribute27
      ,p_rzr_attribute28                =>  p_rzr_attribute28
      ,p_rzr_attribute29                =>  p_rzr_attribute29
      ,p_rzr_attribute3                 =>  p_rzr_attribute3
      ,p_rzr_attribute30                =>  p_rzr_attribute30
      ,p_rzr_attribute4                 =>  p_rzr_attribute4
      ,p_rzr_attribute5                 =>  p_rzr_attribute5
      ,p_rzr_attribute6                 =>  p_rzr_attribute6
      ,p_rzr_attribute7                 =>  p_rzr_attribute7
      ,p_rzr_attribute8                 =>  p_rzr_attribute8
      ,p_rzr_attribute9                 =>  p_rzr_attribute9
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_postal_zip_range'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_postal_zip_range
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
    ROLLBACK TO update_postal_zip_range;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_effective_start_date := null;
    p_effective_end_date := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO update_postal_zip_range;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end update_postal_zip_range;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_postal_zip_range >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_postal_zip_range
  (p_validate                       in  boolean  default false
  ,p_pstl_zip_rng_id                in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_postal_zip_range';
  l_object_version_number ben_pstl_zip_rng_f.object_version_number%TYPE;
  l_effective_start_date ben_pstl_zip_rng_f.effective_start_date%TYPE;
  l_effective_end_date ben_pstl_zip_rng_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_postal_zip_range;
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
    -- Start of API User Hook for the before hook of delete_postal_zip_range
    --
    ben_postal_zip_range_bk3.delete_postal_zip_range_b
      (
       p_pstl_zip_rng_id                =>  p_pstl_zip_rng_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_postal_zip_range'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_postal_zip_range
    --
  end;
  --
  ben_rzr_del.del
    (
     p_pstl_zip_rng_id               => p_pstl_zip_rng_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_postal_zip_range
    --
    ben_postal_zip_range_bk3.delete_postal_zip_range_a
      (
       p_pstl_zip_rng_id                =>  p_pstl_zip_rng_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_postal_zip_range'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_postal_zip_range
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
    ROLLBACK TO delete_postal_zip_range;
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
    ROLLBACK TO delete_postal_zip_range;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end delete_postal_zip_range;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_pstl_zip_rng_id                   in     number
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
  ben_rzr_shd.lck
    (
      p_pstl_zip_rng_id                 => p_pstl_zip_rng_id
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
end ben_postal_zip_range_api;

/
