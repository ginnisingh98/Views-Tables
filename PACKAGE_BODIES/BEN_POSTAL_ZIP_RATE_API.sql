--------------------------------------------------------
--  DDL for Package Body BEN_POSTAL_ZIP_RATE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_POSTAL_ZIP_RATE_API" as
/* $Header: bepzrapi.pkb 115.3 2002/12/13 08:31:53 bmanyam ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_POSTAL_ZIP_RATE_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_POSTAL_ZIP_RATE >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_POSTAL_ZIP_RATE
  (p_validate                       in  boolean   default false
  ,p_pstl_zip_rt_id                 out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_excld_flag                     in  varchar2  default null
  ,p_ordr_num                       in  number    default null
  ,p_pstl_zip_rng_id                in  number    default null
  ,p_vrbl_rt_prfl_id                in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_pzr_attribute_category         in  varchar2  default null
  ,p_pzr_attribute1                 in  varchar2  default null
  ,p_pzr_attribute2                 in  varchar2  default null
  ,p_pzr_attribute3                 in  varchar2  default null
  ,p_pzr_attribute4                 in  varchar2  default null
  ,p_pzr_attribute5                 in  varchar2  default null
  ,p_pzr_attribute6                 in  varchar2  default null
  ,p_pzr_attribute7                 in  varchar2  default null
  ,p_pzr_attribute8                 in  varchar2  default null
  ,p_pzr_attribute9                 in  varchar2  default null
  ,p_pzr_attribute10                in  varchar2  default null
  ,p_pzr_attribute11                in  varchar2  default null
  ,p_pzr_attribute12                in  varchar2  default null
  ,p_pzr_attribute13                in  varchar2  default null
  ,p_pzr_attribute14                in  varchar2  default null
  ,p_pzr_attribute15                in  varchar2  default null
  ,p_pzr_attribute16                in  varchar2  default null
  ,p_pzr_attribute17                in  varchar2  default null
  ,p_pzr_attribute18                in  varchar2  default null
  ,p_pzr_attribute19                in  varchar2  default null
  ,p_pzr_attribute20                in  varchar2  default null
  ,p_pzr_attribute21                in  varchar2  default null
  ,p_pzr_attribute22                in  varchar2  default null
  ,p_pzr_attribute23                in  varchar2  default null
  ,p_pzr_attribute24                in  varchar2  default null
  ,p_pzr_attribute25                in  varchar2  default null
  ,p_pzr_attribute26                in  varchar2  default null
  ,p_pzr_attribute27                in  varchar2  default null
  ,p_pzr_attribute28                in  varchar2  default null
  ,p_pzr_attribute29                in  varchar2  default null
  ,p_pzr_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_pstl_zip_rt_id ben_pstl_zip_rt_f.pstl_zip_rt_id%TYPE;
  l_effective_start_date ben_pstl_zip_rt_f.effective_start_date%TYPE;
  l_effective_end_date ben_pstl_zip_rt_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_POSTAL_ZIP_RATE';
  l_object_version_number ben_pstl_zip_rt_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_POSTAL_ZIP_RATE;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_POSTAL_ZIP_RATE
    --
    ben_POSTAL_ZIP_RATE_bk1.create_POSTAL_ZIP_RATE_b
      (
       p_excld_flag                     =>  p_excld_flag
      ,p_ordr_num                       =>  p_ordr_num
      ,p_pstl_zip_rng_id                =>  p_pstl_zip_rng_id
      ,p_vrbl_rt_prfl_id                =>  p_vrbl_rt_prfl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pzr_attribute_category         =>  p_pzr_attribute_category
      ,p_pzr_attribute1                 =>  p_pzr_attribute1
      ,p_pzr_attribute2                 =>  p_pzr_attribute2
      ,p_pzr_attribute3                 =>  p_pzr_attribute3
      ,p_pzr_attribute4                 =>  p_pzr_attribute4
      ,p_pzr_attribute5                 =>  p_pzr_attribute5
      ,p_pzr_attribute6                 =>  p_pzr_attribute6
      ,p_pzr_attribute7                 =>  p_pzr_attribute7
      ,p_pzr_attribute8                 =>  p_pzr_attribute8
      ,p_pzr_attribute9                 =>  p_pzr_attribute9
      ,p_pzr_attribute10                =>  p_pzr_attribute10
      ,p_pzr_attribute11                =>  p_pzr_attribute11
      ,p_pzr_attribute12                =>  p_pzr_attribute12
      ,p_pzr_attribute13                =>  p_pzr_attribute13
      ,p_pzr_attribute14                =>  p_pzr_attribute14
      ,p_pzr_attribute15                =>  p_pzr_attribute15
      ,p_pzr_attribute16                =>  p_pzr_attribute16
      ,p_pzr_attribute17                =>  p_pzr_attribute17
      ,p_pzr_attribute18                =>  p_pzr_attribute18
      ,p_pzr_attribute19                =>  p_pzr_attribute19
      ,p_pzr_attribute20                =>  p_pzr_attribute20
      ,p_pzr_attribute21                =>  p_pzr_attribute21
      ,p_pzr_attribute22                =>  p_pzr_attribute22
      ,p_pzr_attribute23                =>  p_pzr_attribute23
      ,p_pzr_attribute24                =>  p_pzr_attribute24
      ,p_pzr_attribute25                =>  p_pzr_attribute25
      ,p_pzr_attribute26                =>  p_pzr_attribute26
      ,p_pzr_attribute27                =>  p_pzr_attribute27
      ,p_pzr_attribute28                =>  p_pzr_attribute28
      ,p_pzr_attribute29                =>  p_pzr_attribute29
      ,p_pzr_attribute30                =>  p_pzr_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_POSTAL_ZIP_RATE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_POSTAL_ZIP_RATE
    --
  end;
  --
  ben_pzr_ins.ins
    (
     p_pstl_zip_rt_id                => l_pstl_zip_rt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_excld_flag                    => p_excld_flag
    ,p_ordr_num                      => p_ordr_num
    ,p_pstl_zip_rng_id               => p_pstl_zip_rng_id
    ,p_vrbl_rt_prfl_id               => p_vrbl_rt_prfl_id
    ,p_business_group_id             => p_business_group_id
    ,p_pzr_attribute_category        => p_pzr_attribute_category
    ,p_pzr_attribute1                => p_pzr_attribute1
    ,p_pzr_attribute2                => p_pzr_attribute2
    ,p_pzr_attribute3                => p_pzr_attribute3
    ,p_pzr_attribute4                => p_pzr_attribute4
    ,p_pzr_attribute5                => p_pzr_attribute5
    ,p_pzr_attribute6                => p_pzr_attribute6
    ,p_pzr_attribute7                => p_pzr_attribute7
    ,p_pzr_attribute8                => p_pzr_attribute8
    ,p_pzr_attribute9                => p_pzr_attribute9
    ,p_pzr_attribute10               => p_pzr_attribute10
    ,p_pzr_attribute11               => p_pzr_attribute11
    ,p_pzr_attribute12               => p_pzr_attribute12
    ,p_pzr_attribute13               => p_pzr_attribute13
    ,p_pzr_attribute14               => p_pzr_attribute14
    ,p_pzr_attribute15               => p_pzr_attribute15
    ,p_pzr_attribute16               => p_pzr_attribute16
    ,p_pzr_attribute17               => p_pzr_attribute17
    ,p_pzr_attribute18               => p_pzr_attribute18
    ,p_pzr_attribute19               => p_pzr_attribute19
    ,p_pzr_attribute20               => p_pzr_attribute20
    ,p_pzr_attribute21               => p_pzr_attribute21
    ,p_pzr_attribute22               => p_pzr_attribute22
    ,p_pzr_attribute23               => p_pzr_attribute23
    ,p_pzr_attribute24               => p_pzr_attribute24
    ,p_pzr_attribute25               => p_pzr_attribute25
    ,p_pzr_attribute26               => p_pzr_attribute26
    ,p_pzr_attribute27               => p_pzr_attribute27
    ,p_pzr_attribute28               => p_pzr_attribute28
    ,p_pzr_attribute29               => p_pzr_attribute29
    ,p_pzr_attribute30               => p_pzr_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_POSTAL_ZIP_RATE
    --
    ben_POSTAL_ZIP_RATE_bk1.create_POSTAL_ZIP_RATE_a
      (
       p_pstl_zip_rt_id                 =>  l_pstl_zip_rt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_excld_flag                     =>  p_excld_flag
      ,p_ordr_num                       =>  p_ordr_num
      ,p_pstl_zip_rng_id                =>  p_pstl_zip_rng_id
      ,p_vrbl_rt_prfl_id                =>  p_vrbl_rt_prfl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pzr_attribute_category         =>  p_pzr_attribute_category
      ,p_pzr_attribute1                 =>  p_pzr_attribute1
      ,p_pzr_attribute2                 =>  p_pzr_attribute2
      ,p_pzr_attribute3                 =>  p_pzr_attribute3
      ,p_pzr_attribute4                 =>  p_pzr_attribute4
      ,p_pzr_attribute5                 =>  p_pzr_attribute5
      ,p_pzr_attribute6                 =>  p_pzr_attribute6
      ,p_pzr_attribute7                 =>  p_pzr_attribute7
      ,p_pzr_attribute8                 =>  p_pzr_attribute8
      ,p_pzr_attribute9                 =>  p_pzr_attribute9
      ,p_pzr_attribute10                =>  p_pzr_attribute10
      ,p_pzr_attribute11                =>  p_pzr_attribute11
      ,p_pzr_attribute12                =>  p_pzr_attribute12
      ,p_pzr_attribute13                =>  p_pzr_attribute13
      ,p_pzr_attribute14                =>  p_pzr_attribute14
      ,p_pzr_attribute15                =>  p_pzr_attribute15
      ,p_pzr_attribute16                =>  p_pzr_attribute16
      ,p_pzr_attribute17                =>  p_pzr_attribute17
      ,p_pzr_attribute18                =>  p_pzr_attribute18
      ,p_pzr_attribute19                =>  p_pzr_attribute19
      ,p_pzr_attribute20                =>  p_pzr_attribute20
      ,p_pzr_attribute21                =>  p_pzr_attribute21
      ,p_pzr_attribute22                =>  p_pzr_attribute22
      ,p_pzr_attribute23                =>  p_pzr_attribute23
      ,p_pzr_attribute24                =>  p_pzr_attribute24
      ,p_pzr_attribute25                =>  p_pzr_attribute25
      ,p_pzr_attribute26                =>  p_pzr_attribute26
      ,p_pzr_attribute27                =>  p_pzr_attribute27
      ,p_pzr_attribute28                =>  p_pzr_attribute28
      ,p_pzr_attribute29                =>  p_pzr_attribute29
      ,p_pzr_attribute30                =>  p_pzr_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_POSTAL_ZIP_RATE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_POSTAL_ZIP_RATE
    --
  end;
  --
  ben_profile_handler.event_handler
    (p_event                       => 'CREATE',
     p_base_table                  => 'BEN_VRBL_RT_PRFL_F',
     p_base_table_column           => 'VRBL_RT_PRFL_ID',
     p_base_table_column_value     => p_vrbl_rt_prfl_id,
     p_base_table_reference_column => 'RT_PSTL_CD_FLAG',
     p_reference_table             => 'BEN_PSTl_ZIP_RT_F',
     p_reference_table_column      => 'VRBL_RT_PRFL_ID');
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
  p_pstl_zip_rt_id := l_pstl_zip_rt_id;
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
    ROLLBACK TO create_POSTAL_ZIP_RATE;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_pstl_zip_rt_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_POSTAL_ZIP_RATE;
	-- NOCOPY Changes
    p_pstl_zip_rt_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    -- NOCOPY Changes

    raise;
    --
end create_POSTAL_ZIP_RATE;
-- ----------------------------------------------------------------------------
-- |------------------------< update_POSTAL_ZIP_RATE >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_POSTAL_ZIP_RATE
  (p_validate                       in  boolean   default false
  ,p_pstl_zip_rt_id                 in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_excld_flag                     in  varchar2  default hr_api.g_varchar2
  ,p_ordr_num                       in  number    default hr_api.g_number
  ,p_pstl_zip_rng_id                in  number    default hr_api.g_number
  ,p_vrbl_rt_prfl_id                in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_pzr_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_pzr_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_pzr_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_pzr_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_pzr_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_pzr_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_pzr_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_pzr_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_pzr_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_pzr_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_pzr_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_pzr_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_pzr_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_pzr_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_pzr_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_pzr_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_pzr_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_pzr_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_pzr_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_pzr_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_pzr_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_pzr_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_pzr_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_pzr_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_pzr_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_pzr_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_pzr_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_pzr_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_pzr_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_pzr_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_pzr_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_POSTAL_ZIP_RATE';
  l_object_version_number ben_pstl_zip_rt_f.object_version_number%TYPE;
  l_effective_start_date ben_pstl_zip_rt_f.effective_start_date%TYPE;
  l_effective_end_date ben_pstl_zip_rt_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_POSTAL_ZIP_RATE;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_POSTAL_ZIP_RATE
    --
    ben_POSTAL_ZIP_RATE_bk2.update_POSTAL_ZIP_RATE_b
      (
       p_pstl_zip_rt_id                 =>  p_pstl_zip_rt_id
      ,p_excld_flag                     =>  p_excld_flag
      ,p_ordr_num                       =>  p_ordr_num
      ,p_pstl_zip_rng_id                =>  p_pstl_zip_rng_id
      ,p_vrbl_rt_prfl_id                =>  p_vrbl_rt_prfl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pzr_attribute_category         =>  p_pzr_attribute_category
      ,p_pzr_attribute1                 =>  p_pzr_attribute1
      ,p_pzr_attribute2                 =>  p_pzr_attribute2
      ,p_pzr_attribute3                 =>  p_pzr_attribute3
      ,p_pzr_attribute4                 =>  p_pzr_attribute4
      ,p_pzr_attribute5                 =>  p_pzr_attribute5
      ,p_pzr_attribute6                 =>  p_pzr_attribute6
      ,p_pzr_attribute7                 =>  p_pzr_attribute7
      ,p_pzr_attribute8                 =>  p_pzr_attribute8
      ,p_pzr_attribute9                 =>  p_pzr_attribute9
      ,p_pzr_attribute10                =>  p_pzr_attribute10
      ,p_pzr_attribute11                =>  p_pzr_attribute11
      ,p_pzr_attribute12                =>  p_pzr_attribute12
      ,p_pzr_attribute13                =>  p_pzr_attribute13
      ,p_pzr_attribute14                =>  p_pzr_attribute14
      ,p_pzr_attribute15                =>  p_pzr_attribute15
      ,p_pzr_attribute16                =>  p_pzr_attribute16
      ,p_pzr_attribute17                =>  p_pzr_attribute17
      ,p_pzr_attribute18                =>  p_pzr_attribute18
      ,p_pzr_attribute19                =>  p_pzr_attribute19
      ,p_pzr_attribute20                =>  p_pzr_attribute20
      ,p_pzr_attribute21                =>  p_pzr_attribute21
      ,p_pzr_attribute22                =>  p_pzr_attribute22
      ,p_pzr_attribute23                =>  p_pzr_attribute23
      ,p_pzr_attribute24                =>  p_pzr_attribute24
      ,p_pzr_attribute25                =>  p_pzr_attribute25
      ,p_pzr_attribute26                =>  p_pzr_attribute26
      ,p_pzr_attribute27                =>  p_pzr_attribute27
      ,p_pzr_attribute28                =>  p_pzr_attribute28
      ,p_pzr_attribute29                =>  p_pzr_attribute29
      ,p_pzr_attribute30                =>  p_pzr_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_POSTAL_ZIP_RATE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_POSTAL_ZIP_RATE
    --
  end;
  --
  ben_pzr_upd.upd
    (
     p_pstl_zip_rt_id                => p_pstl_zip_rt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_excld_flag                    => p_excld_flag
    ,p_ordr_num                      => p_ordr_num
    ,p_pstl_zip_rng_id               => p_pstl_zip_rng_id
    ,p_vrbl_rt_prfl_id               => p_vrbl_rt_prfl_id
    ,p_business_group_id             => p_business_group_id
    ,p_pzr_attribute_category        => p_pzr_attribute_category
    ,p_pzr_attribute1                => p_pzr_attribute1
    ,p_pzr_attribute2                => p_pzr_attribute2
    ,p_pzr_attribute3                => p_pzr_attribute3
    ,p_pzr_attribute4                => p_pzr_attribute4
    ,p_pzr_attribute5                => p_pzr_attribute5
    ,p_pzr_attribute6                => p_pzr_attribute6
    ,p_pzr_attribute7                => p_pzr_attribute7
    ,p_pzr_attribute8                => p_pzr_attribute8
    ,p_pzr_attribute9                => p_pzr_attribute9
    ,p_pzr_attribute10               => p_pzr_attribute10
    ,p_pzr_attribute11               => p_pzr_attribute11
    ,p_pzr_attribute12               => p_pzr_attribute12
    ,p_pzr_attribute13               => p_pzr_attribute13
    ,p_pzr_attribute14               => p_pzr_attribute14
    ,p_pzr_attribute15               => p_pzr_attribute15
    ,p_pzr_attribute16               => p_pzr_attribute16
    ,p_pzr_attribute17               => p_pzr_attribute17
    ,p_pzr_attribute18               => p_pzr_attribute18
    ,p_pzr_attribute19               => p_pzr_attribute19
    ,p_pzr_attribute20               => p_pzr_attribute20
    ,p_pzr_attribute21               => p_pzr_attribute21
    ,p_pzr_attribute22               => p_pzr_attribute22
    ,p_pzr_attribute23               => p_pzr_attribute23
    ,p_pzr_attribute24               => p_pzr_attribute24
    ,p_pzr_attribute25               => p_pzr_attribute25
    ,p_pzr_attribute26               => p_pzr_attribute26
    ,p_pzr_attribute27               => p_pzr_attribute27
    ,p_pzr_attribute28               => p_pzr_attribute28
    ,p_pzr_attribute29               => p_pzr_attribute29
    ,p_pzr_attribute30               => p_pzr_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_POSTAL_ZIP_RATE
    --
    ben_POSTAL_ZIP_RATE_bk2.update_POSTAL_ZIP_RATE_a
      (
       p_pstl_zip_rt_id                 =>  p_pstl_zip_rt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_excld_flag                     =>  p_excld_flag
      ,p_ordr_num                       =>  p_ordr_num
      ,p_pstl_zip_rng_id                =>  p_pstl_zip_rng_id
      ,p_vrbl_rt_prfl_id                =>  p_vrbl_rt_prfl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pzr_attribute_category         =>  p_pzr_attribute_category
      ,p_pzr_attribute1                 =>  p_pzr_attribute1
      ,p_pzr_attribute2                 =>  p_pzr_attribute2
      ,p_pzr_attribute3                 =>  p_pzr_attribute3
      ,p_pzr_attribute4                 =>  p_pzr_attribute4
      ,p_pzr_attribute5                 =>  p_pzr_attribute5
      ,p_pzr_attribute6                 =>  p_pzr_attribute6
      ,p_pzr_attribute7                 =>  p_pzr_attribute7
      ,p_pzr_attribute8                 =>  p_pzr_attribute8
      ,p_pzr_attribute9                 =>  p_pzr_attribute9
      ,p_pzr_attribute10                =>  p_pzr_attribute10
      ,p_pzr_attribute11                =>  p_pzr_attribute11
      ,p_pzr_attribute12                =>  p_pzr_attribute12
      ,p_pzr_attribute13                =>  p_pzr_attribute13
      ,p_pzr_attribute14                =>  p_pzr_attribute14
      ,p_pzr_attribute15                =>  p_pzr_attribute15
      ,p_pzr_attribute16                =>  p_pzr_attribute16
      ,p_pzr_attribute17                =>  p_pzr_attribute17
      ,p_pzr_attribute18                =>  p_pzr_attribute18
      ,p_pzr_attribute19                =>  p_pzr_attribute19
      ,p_pzr_attribute20                =>  p_pzr_attribute20
      ,p_pzr_attribute21                =>  p_pzr_attribute21
      ,p_pzr_attribute22                =>  p_pzr_attribute22
      ,p_pzr_attribute23                =>  p_pzr_attribute23
      ,p_pzr_attribute24                =>  p_pzr_attribute24
      ,p_pzr_attribute25                =>  p_pzr_attribute25
      ,p_pzr_attribute26                =>  p_pzr_attribute26
      ,p_pzr_attribute27                =>  p_pzr_attribute27
      ,p_pzr_attribute28                =>  p_pzr_attribute28
      ,p_pzr_attribute29                =>  p_pzr_attribute29
      ,p_pzr_attribute30                =>  p_pzr_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_POSTAL_ZIP_RATE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_POSTAL_ZIP_RATE
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
    ROLLBACK TO update_POSTAL_ZIP_RATE;
    --
	-- NOCOPY Changes
    p_effective_start_date := null;
    p_effective_end_date := null;
    -- NOCOPY Changes
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
    ROLLBACK TO update_POSTAL_ZIP_RATE;
	-- NOCOPY Changes
    p_effective_start_date := null;
    p_effective_end_date := null;
    -- NOCOPY Changes

    raise;
    --
end update_POSTAL_ZIP_RATE;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_POSTAL_ZIP_RATE >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_POSTAL_ZIP_RATE
  (p_validate                       in  boolean  default false
  ,p_pstl_zip_rt_id                 in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_POSTAL_ZIP_RATE';
  l_object_version_number ben_pstl_zip_rt_f.object_version_number%TYPE;
  l_effective_start_date ben_pstl_zip_rt_f.effective_start_date%TYPE;
  l_effective_end_date ben_pstl_zip_rt_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_POSTAL_ZIP_RATE;
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
    -- Start of API User Hook for the before hook of delete_POSTAL_ZIP_RATE
    --
    ben_POSTAL_ZIP_RATE_bk3.delete_POSTAL_ZIP_RATE_b
      (
       p_pstl_zip_rt_id                 =>  p_pstl_zip_rt_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_POSTAL_ZIP_RATE'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_POSTAL_ZIP_RATE
    --
  end;
  --
  ben_pzr_del.del
    (
     p_pstl_zip_rt_id                => p_pstl_zip_rt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_POSTAL_ZIP_RATE
    --
    ben_POSTAL_ZIP_RATE_bk3.delete_POSTAL_ZIP_RATE_a
      (
       p_pstl_zip_rt_id                 =>  p_pstl_zip_rt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_POSTAL_ZIP_RATE'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_POSTAL_ZIP_RATE
    --
  end;
  --
  ben_profile_handler.event_handler
    (p_event                       => 'DELETE',
     p_base_table                  => 'BEN_VRBL_RT_PRFL_F',
     p_base_table_column           => 'VRBL_RT_PRFL_ID',
     p_base_table_column_value     => ben_pzr_shd.g_old_rec.vrbl_rt_prfl_id,
     p_base_table_reference_column => 'RT_PSTL_CD_FLAG',
     p_reference_table             => 'BEN_PSTl_ZIP_RT_F',
     p_reference_table_column      => 'VRBL_RT_PRFL_ID');
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
    ROLLBACK TO delete_POSTAL_ZIP_RATE;
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
    ROLLBACK TO delete_POSTAL_ZIP_RATE;
	-- NOCOPY Changes
    p_effective_start_date := null;
    p_effective_end_date := null;
    -- NOCOPY Changes
    raise;
    --
end delete_POSTAL_ZIP_RATE;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_pstl_zip_rt_id                   in     number
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
  ben_pzr_shd.lck
    (
      p_pstl_zip_rt_id                 => p_pstl_zip_rt_id
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
end ben_POSTAL_ZIP_RATE_api;

/
