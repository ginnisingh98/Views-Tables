--------------------------------------------------------
--  DDL for Package Body BEN_DSBLD_RT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_DSBLD_RT_API" as
/* $Header: bedbrapi.pkb 115.4 2002/12/23 12:33:47 nhunur ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_DSBLD_RT_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_DSBLD_RT >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_DSBLD_RT
  (p_validate                       in  boolean   default false
  ,p_dsbld_rt_id                    out nocopy number
  ,p_dsbld_cd                       in  varchar2  default null
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_ordr_num                       in  number    default null
  ,p_excld_flag                     in  varchar2  default 'N'
  ,p_vrbl_rt_prfl_id                in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_dbr_attribute_category         in  varchar2  default null
  ,p_dbr_attribute1                 in  varchar2  default null
  ,p_dbr_attribute2                 in  varchar2  default null
  ,p_dbr_attribute3                 in  varchar2  default null
  ,p_dbr_attribute4                 in  varchar2  default null
  ,p_dbr_attribute5                 in  varchar2  default null
  ,p_dbr_attribute6                 in  varchar2  default null
  ,p_dbr_attribute7                 in  varchar2  default null
  ,p_dbr_attribute8                 in  varchar2  default null
  ,p_dbr_attribute9                 in  varchar2  default null
  ,p_dbr_attribute10                in  varchar2  default null
  ,p_dbr_attribute11                in  varchar2  default null
  ,p_dbr_attribute12                in  varchar2  default null
  ,p_dbr_attribute13                in  varchar2  default null
  ,p_dbr_attribute14                in  varchar2  default null
  ,p_dbr_attribute15                in  varchar2  default null
  ,p_dbr_attribute16                in  varchar2  default null
  ,p_dbr_attribute17                in  varchar2  default null
  ,p_dbr_attribute18                in  varchar2  default null
  ,p_dbr_attribute19                in  varchar2  default null
  ,p_dbr_attribute20                in  varchar2  default null
  ,p_dbr_attribute21                in  varchar2  default null
  ,p_dbr_attribute22                in  varchar2  default null
  ,p_dbr_attribute23                in  varchar2  default null
  ,p_dbr_attribute24                in  varchar2  default null
  ,p_dbr_attribute25                in  varchar2  default null
  ,p_dbr_attribute26                in  varchar2  default null
  ,p_dbr_attribute27                in  varchar2  default null
  ,p_dbr_attribute28                in  varchar2  default null
  ,p_dbr_attribute29                in  varchar2  default null
  ,p_dbr_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_dsbld_rt_id ben_dsbld_rt_f.dsbld_rt_id%TYPE;
  l_effective_start_date ben_dsbld_rt_f.effective_start_date%TYPE;
  l_effective_end_date ben_dsbld_rt_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_DSBLD_RT';
  l_object_version_number ben_dsbld_rt_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_DSBLD_RT;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_DSBLD_RT
    --
    ben_DSBLD_RT_bk1.create_DSBLD_RT_b
      (
       p_dsbld_cd                       =>  p_dsbld_cd
      ,p_ordr_num                       =>  p_ordr_num
      ,p_excld_flag                     =>  p_excld_flag
      ,p_vrbl_rt_prfl_id                =>  p_vrbl_rt_prfl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_dbr_attribute_category         =>  p_dbr_attribute_category
      ,p_dbr_attribute1                 =>  p_dbr_attribute1
      ,p_dbr_attribute2                 =>  p_dbr_attribute2
      ,p_dbr_attribute3                 =>  p_dbr_attribute3
      ,p_dbr_attribute4                 =>  p_dbr_attribute4
      ,p_dbr_attribute5                 =>  p_dbr_attribute5
      ,p_dbr_attribute6                 =>  p_dbr_attribute6
      ,p_dbr_attribute7                 =>  p_dbr_attribute7
      ,p_dbr_attribute8                 =>  p_dbr_attribute8
      ,p_dbr_attribute9                 =>  p_dbr_attribute9
      ,p_dbr_attribute10                =>  p_dbr_attribute10
      ,p_dbr_attribute11                =>  p_dbr_attribute11
      ,p_dbr_attribute12                =>  p_dbr_attribute12
      ,p_dbr_attribute13                =>  p_dbr_attribute13
      ,p_dbr_attribute14                =>  p_dbr_attribute14
      ,p_dbr_attribute15                =>  p_dbr_attribute15
      ,p_dbr_attribute16                =>  p_dbr_attribute16
      ,p_dbr_attribute17                =>  p_dbr_attribute17
      ,p_dbr_attribute18                =>  p_dbr_attribute18
      ,p_dbr_attribute19                =>  p_dbr_attribute19
      ,p_dbr_attribute20                =>  p_dbr_attribute20
      ,p_dbr_attribute21                =>  p_dbr_attribute21
      ,p_dbr_attribute22                =>  p_dbr_attribute22
      ,p_dbr_attribute23                =>  p_dbr_attribute23
      ,p_dbr_attribute24                =>  p_dbr_attribute24
      ,p_dbr_attribute25                =>  p_dbr_attribute25
      ,p_dbr_attribute26                =>  p_dbr_attribute26
      ,p_dbr_attribute27                =>  p_dbr_attribute27
      ,p_dbr_attribute28                =>  p_dbr_attribute28
      ,p_dbr_attribute29                =>  p_dbr_attribute29
      ,p_dbr_attribute30                =>  p_dbr_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_DSBLD_RT'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_DSBLD_RT
    --
  end;
  --
  ben_dbr_ins.ins
    (
     p_dsbld_rt_id                   => l_dsbld_rt_id
    ,p_dsbld_cd                      => p_dsbld_cd
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_ordr_num                      => p_ordr_num
    ,p_excld_flag                    => p_excld_flag
    ,p_vrbl_rt_prfl_id               => p_vrbl_rt_prfl_id
    ,p_business_group_id             => p_business_group_id
    ,p_dbr_attribute_category        => p_dbr_attribute_category
    ,p_dbr_attribute1                => p_dbr_attribute1
    ,p_dbr_attribute2                => p_dbr_attribute2
    ,p_dbr_attribute3                => p_dbr_attribute3
    ,p_dbr_attribute4                => p_dbr_attribute4
    ,p_dbr_attribute5                => p_dbr_attribute5
    ,p_dbr_attribute6                => p_dbr_attribute6
    ,p_dbr_attribute7                => p_dbr_attribute7
    ,p_dbr_attribute8                => p_dbr_attribute8
    ,p_dbr_attribute9                => p_dbr_attribute9
    ,p_dbr_attribute10               => p_dbr_attribute10
    ,p_dbr_attribute11               => p_dbr_attribute11
    ,p_dbr_attribute12               => p_dbr_attribute12
    ,p_dbr_attribute13               => p_dbr_attribute13
    ,p_dbr_attribute14               => p_dbr_attribute14
    ,p_dbr_attribute15               => p_dbr_attribute15
    ,p_dbr_attribute16               => p_dbr_attribute16
    ,p_dbr_attribute17               => p_dbr_attribute17
    ,p_dbr_attribute18               => p_dbr_attribute18
    ,p_dbr_attribute19               => p_dbr_attribute19
    ,p_dbr_attribute20               => p_dbr_attribute20
    ,p_dbr_attribute21               => p_dbr_attribute21
    ,p_dbr_attribute22               => p_dbr_attribute22
    ,p_dbr_attribute23               => p_dbr_attribute23
    ,p_dbr_attribute24               => p_dbr_attribute24
    ,p_dbr_attribute25               => p_dbr_attribute25
    ,p_dbr_attribute26               => p_dbr_attribute26
    ,p_dbr_attribute27               => p_dbr_attribute27
    ,p_dbr_attribute28               => p_dbr_attribute28
    ,p_dbr_attribute29               => p_dbr_attribute29
    ,p_dbr_attribute30               => p_dbr_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_DSBLD_RT
    --
    ben_DSBLD_RT_bk1.create_DSBLD_RT_a
      (
       p_dsbld_rt_id                    =>  l_dsbld_rt_id
      ,p_dsbld_cd                       =>  p_dsbld_cd
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_ordr_num                       =>  p_ordr_num
      ,p_excld_flag                     =>  p_excld_flag
      ,p_vrbl_rt_prfl_id                =>  p_vrbl_rt_prfl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_dbr_attribute_category         =>  p_dbr_attribute_category
      ,p_dbr_attribute1                 =>  p_dbr_attribute1
      ,p_dbr_attribute2                 =>  p_dbr_attribute2
      ,p_dbr_attribute3                 =>  p_dbr_attribute3
      ,p_dbr_attribute4                 =>  p_dbr_attribute4
      ,p_dbr_attribute5                 =>  p_dbr_attribute5
      ,p_dbr_attribute6                 =>  p_dbr_attribute6
      ,p_dbr_attribute7                 =>  p_dbr_attribute7
      ,p_dbr_attribute8                 =>  p_dbr_attribute8
      ,p_dbr_attribute9                 =>  p_dbr_attribute9
      ,p_dbr_attribute10                =>  p_dbr_attribute10
      ,p_dbr_attribute11                =>  p_dbr_attribute11
      ,p_dbr_attribute12                =>  p_dbr_attribute12
      ,p_dbr_attribute13                =>  p_dbr_attribute13
      ,p_dbr_attribute14                =>  p_dbr_attribute14
      ,p_dbr_attribute15                =>  p_dbr_attribute15
      ,p_dbr_attribute16                =>  p_dbr_attribute16
      ,p_dbr_attribute17                =>  p_dbr_attribute17
      ,p_dbr_attribute18                =>  p_dbr_attribute18
      ,p_dbr_attribute19                =>  p_dbr_attribute19
      ,p_dbr_attribute20                =>  p_dbr_attribute20
      ,p_dbr_attribute21                =>  p_dbr_attribute21
      ,p_dbr_attribute22                =>  p_dbr_attribute22
      ,p_dbr_attribute23                =>  p_dbr_attribute23
      ,p_dbr_attribute24                =>  p_dbr_attribute24
      ,p_dbr_attribute25                =>  p_dbr_attribute25
      ,p_dbr_attribute26                =>  p_dbr_attribute26
      ,p_dbr_attribute27                =>  p_dbr_attribute27
      ,p_dbr_attribute28                =>  p_dbr_attribute28
      ,p_dbr_attribute29                =>  p_dbr_attribute29
      ,p_dbr_attribute30                =>  p_dbr_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_DSBLD_RT'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_DSBLD_RT
    --
  end;
  --
  ben_profile_handler.event_handler
    (p_event                       => 'CREATE',
     p_base_table                  => 'BEN_VRBL_RT_PRFL_F',
     p_base_table_column           => 'VRBL_RT_PRFL_ID',
     p_base_table_column_value     => p_vrbl_rt_prfl_id,
     p_base_table_reference_column => 'RT_DSBLD_FLAG',
     p_reference_table             => 'BEN_DSBLD_RT_F',
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
  p_dsbld_rt_id := l_dsbld_rt_id;
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
    ROLLBACK TO create_DSBLD_RT;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_dsbld_rt_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_dsbld_rt_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := l_object_version_number;

    ROLLBACK TO create_DSBLD_RT;
    raise;
    --
end create_DSBLD_RT;
-- ----------------------------------------------------------------------------
-- |------------------------< update_DSBLD_RT >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_DSBLD_RT
  (p_validate                       in  boolean   default false
  ,p_dsbld_rt_id                    in  number
  ,p_dsbld_cd                       in  varchar2  default hr_api.g_varchar2
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_ordr_num                       in  number    default hr_api.g_number
  ,p_excld_flag                     in  varchar2  default hr_api.g_varchar2
  ,p_vrbl_rt_prfl_id                in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_dbr_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_dbr_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_dbr_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_dbr_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_dbr_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_dbr_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_dbr_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_dbr_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_dbr_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_dbr_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_dbr_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_dbr_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_dbr_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_dbr_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_dbr_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_dbr_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_dbr_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_dbr_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_dbr_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_dbr_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_dbr_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_dbr_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_dbr_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_dbr_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_dbr_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_dbr_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_dbr_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_dbr_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_dbr_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_dbr_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_dbr_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_DSBLD_RT';
  l_object_version_number ben_dsbld_rt_f.object_version_number%TYPE;
  l_effective_start_date ben_dsbld_rt_f.effective_start_date%TYPE;
  l_effective_end_date ben_dsbld_rt_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_DSBLD_RT;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_DSBLD_RT
    --
    ben_DSBLD_RT_bk2.update_DSBLD_RT_b
      (
       p_dsbld_rt_id                    =>  p_dsbld_rt_id
      ,p_dsbld_cd                       =>  p_dsbld_cd
      ,p_ordr_num                       =>  p_ordr_num
      ,p_excld_flag                     =>  p_excld_flag
      ,p_vrbl_rt_prfl_id                =>  p_vrbl_rt_prfl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_dbr_attribute_category         =>  p_dbr_attribute_category
      ,p_dbr_attribute1                 =>  p_dbr_attribute1
      ,p_dbr_attribute2                 =>  p_dbr_attribute2
      ,p_dbr_attribute3                 =>  p_dbr_attribute3
      ,p_dbr_attribute4                 =>  p_dbr_attribute4
      ,p_dbr_attribute5                 =>  p_dbr_attribute5
      ,p_dbr_attribute6                 =>  p_dbr_attribute6
      ,p_dbr_attribute7                 =>  p_dbr_attribute7
      ,p_dbr_attribute8                 =>  p_dbr_attribute8
      ,p_dbr_attribute9                 =>  p_dbr_attribute9
      ,p_dbr_attribute10                =>  p_dbr_attribute10
      ,p_dbr_attribute11                =>  p_dbr_attribute11
      ,p_dbr_attribute12                =>  p_dbr_attribute12
      ,p_dbr_attribute13                =>  p_dbr_attribute13
      ,p_dbr_attribute14                =>  p_dbr_attribute14
      ,p_dbr_attribute15                =>  p_dbr_attribute15
      ,p_dbr_attribute16                =>  p_dbr_attribute16
      ,p_dbr_attribute17                =>  p_dbr_attribute17
      ,p_dbr_attribute18                =>  p_dbr_attribute18
      ,p_dbr_attribute19                =>  p_dbr_attribute19
      ,p_dbr_attribute20                =>  p_dbr_attribute20
      ,p_dbr_attribute21                =>  p_dbr_attribute21
      ,p_dbr_attribute22                =>  p_dbr_attribute22
      ,p_dbr_attribute23                =>  p_dbr_attribute23
      ,p_dbr_attribute24                =>  p_dbr_attribute24
      ,p_dbr_attribute25                =>  p_dbr_attribute25
      ,p_dbr_attribute26                =>  p_dbr_attribute26
      ,p_dbr_attribute27                =>  p_dbr_attribute27
      ,p_dbr_attribute28                =>  p_dbr_attribute28
      ,p_dbr_attribute29                =>  p_dbr_attribute29
      ,p_dbr_attribute30                =>  p_dbr_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_DSBLD_RT'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_DSBLD_RT
    --
  end;
  --
  ben_dbr_upd.upd
    (
     p_dsbld_rt_id                   => p_dsbld_rt_id
    ,p_dsbld_cd                      => p_dsbld_cd
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_ordr_num                      => p_ordr_num
    ,p_excld_flag                    => p_excld_flag
    ,p_vrbl_rt_prfl_id               => p_vrbl_rt_prfl_id
    ,p_business_group_id             => p_business_group_id
    ,p_dbr_attribute_category        => p_dbr_attribute_category
    ,p_dbr_attribute1                => p_dbr_attribute1
    ,p_dbr_attribute2                => p_dbr_attribute2
    ,p_dbr_attribute3                => p_dbr_attribute3
    ,p_dbr_attribute4                => p_dbr_attribute4
    ,p_dbr_attribute5                => p_dbr_attribute5
    ,p_dbr_attribute6                => p_dbr_attribute6
    ,p_dbr_attribute7                => p_dbr_attribute7
    ,p_dbr_attribute8                => p_dbr_attribute8
    ,p_dbr_attribute9                => p_dbr_attribute9
    ,p_dbr_attribute10               => p_dbr_attribute10
    ,p_dbr_attribute11               => p_dbr_attribute11
    ,p_dbr_attribute12               => p_dbr_attribute12
    ,p_dbr_attribute13               => p_dbr_attribute13
    ,p_dbr_attribute14               => p_dbr_attribute14
    ,p_dbr_attribute15               => p_dbr_attribute15
    ,p_dbr_attribute16               => p_dbr_attribute16
    ,p_dbr_attribute17               => p_dbr_attribute17
    ,p_dbr_attribute18               => p_dbr_attribute18
    ,p_dbr_attribute19               => p_dbr_attribute19
    ,p_dbr_attribute20               => p_dbr_attribute20
    ,p_dbr_attribute21               => p_dbr_attribute21
    ,p_dbr_attribute22               => p_dbr_attribute22
    ,p_dbr_attribute23               => p_dbr_attribute23
    ,p_dbr_attribute24               => p_dbr_attribute24
    ,p_dbr_attribute25               => p_dbr_attribute25
    ,p_dbr_attribute26               => p_dbr_attribute26
    ,p_dbr_attribute27               => p_dbr_attribute27
    ,p_dbr_attribute28               => p_dbr_attribute28
    ,p_dbr_attribute29               => p_dbr_attribute29
    ,p_dbr_attribute30               => p_dbr_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_DSBLD_RT
    --
    ben_DSBLD_RT_bk2.update_DSBLD_RT_a
      (
       p_dsbld_rt_id                    =>  p_dsbld_rt_id
      ,p_dsbld_cd                       =>  p_dsbld_cd
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_ordr_num                       =>  p_ordr_num
      ,p_excld_flag                     =>  p_excld_flag
      ,p_vrbl_rt_prfl_id                =>  p_vrbl_rt_prfl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_dbr_attribute_category         =>  p_dbr_attribute_category
      ,p_dbr_attribute1                 =>  p_dbr_attribute1
      ,p_dbr_attribute2                 =>  p_dbr_attribute2
      ,p_dbr_attribute3                 =>  p_dbr_attribute3
      ,p_dbr_attribute4                 =>  p_dbr_attribute4
      ,p_dbr_attribute5                 =>  p_dbr_attribute5
      ,p_dbr_attribute6                 =>  p_dbr_attribute6
      ,p_dbr_attribute7                 =>  p_dbr_attribute7
      ,p_dbr_attribute8                 =>  p_dbr_attribute8
      ,p_dbr_attribute9                 =>  p_dbr_attribute9
      ,p_dbr_attribute10                =>  p_dbr_attribute10
      ,p_dbr_attribute11                =>  p_dbr_attribute11
      ,p_dbr_attribute12                =>  p_dbr_attribute12
      ,p_dbr_attribute13                =>  p_dbr_attribute13
      ,p_dbr_attribute14                =>  p_dbr_attribute14
      ,p_dbr_attribute15                =>  p_dbr_attribute15
      ,p_dbr_attribute16                =>  p_dbr_attribute16
      ,p_dbr_attribute17                =>  p_dbr_attribute17
      ,p_dbr_attribute18                =>  p_dbr_attribute18
      ,p_dbr_attribute19                =>  p_dbr_attribute19
      ,p_dbr_attribute20                =>  p_dbr_attribute20
      ,p_dbr_attribute21                =>  p_dbr_attribute21
      ,p_dbr_attribute22                =>  p_dbr_attribute22
      ,p_dbr_attribute23                =>  p_dbr_attribute23
      ,p_dbr_attribute24                =>  p_dbr_attribute24
      ,p_dbr_attribute25                =>  p_dbr_attribute25
      ,p_dbr_attribute26                =>  p_dbr_attribute26
      ,p_dbr_attribute27                =>  p_dbr_attribute27
      ,p_dbr_attribute28                =>  p_dbr_attribute28
      ,p_dbr_attribute29                =>  p_dbr_attribute29
      ,p_dbr_attribute30                =>  p_dbr_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_DSBLD_RT'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_DSBLD_RT
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
    ROLLBACK TO update_DSBLD_RT;
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
    p_object_version_number := l_object_version_number;
    p_effective_start_date := null;
    p_effective_end_date := null;

    ROLLBACK TO update_DSBLD_RT;
    raise;
    --
end update_DSBLD_RT;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_DSBLD_RT >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_DSBLD_RT
  (p_validate                       in  boolean  default false
  ,p_dsbld_rt_id                    in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_DSBLD_RT';
  l_object_version_number ben_dsbld_rt_f.object_version_number%TYPE;
  l_effective_start_date ben_dsbld_rt_f.effective_start_date%TYPE;
  l_effective_end_date ben_dsbld_rt_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_DSBLD_RT;
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
    -- Start of API User Hook for the before hook of delete_DSBLD_RT
    --
    ben_DSBLD_RT_bk3.delete_DSBLD_RT_b
      (
       p_dsbld_rt_id                    =>  p_dsbld_rt_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_DSBLD_RT'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_DSBLD_RT
    --
  end;
  --
  ben_dbr_del.del
    (
     p_dsbld_rt_id                   => p_dsbld_rt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_DSBLD_RT
    --
    ben_DSBLD_RT_bk3.delete_DSBLD_RT_a
      (
       p_dsbld_rt_id                    =>  p_dsbld_rt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_DSBLD_RT'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_DSBLD_RT
    --
  end;
  --
  ben_profile_handler.event_handler
    (p_event                       => 'DELETE',
     p_base_table                  => 'BEN_VRBL_RT_PRFL_F',
     p_base_table_column           => 'VRBL_RT_PRFL_ID',
     p_base_table_column_value     => ben_dbr_shd.g_old_rec.vrbl_rt_prfl_id,
     p_base_table_reference_column => 'RT_DSBLD_FLAG',
     p_reference_table             => 'BEN_DSBLD_RT_F',
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
    ROLLBACK TO delete_DSBLD_RT;
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
    p_effective_start_date := null;
    p_effective_end_date := null;

    ROLLBACK TO delete_DSBLD_RT;
    raise;
    --
end delete_DSBLD_RT;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_dsbld_rt_id                   in     number
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
  ben_dbr_shd.lck
    (
      p_dsbld_rt_id                 => p_dsbld_rt_id
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
end ben_DSBLD_RT_api;

/
