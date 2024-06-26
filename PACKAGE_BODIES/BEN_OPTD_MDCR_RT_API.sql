--------------------------------------------------------
--  DDL for Package Body BEN_OPTD_MDCR_RT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_OPTD_MDCR_RT_API" as
/* $Header: beomrapi.pkb 115.1 2002/12/13 08:30:08 bmanyam noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_optd_mdcr_rt_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_OPTD_MDCR_RT >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_optd_mdcr_rt
  (p_validate                       in  boolean   default false
  ,p_optd_mdcr_rt_id         out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_optd_mdcr_flag                 in  varchar2  default 'N'
  ,p_exlcd_flag                     in  varchar2  default 'N'
  ,p_vrbl_rt_prfl_id                  in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_omr_attribute_category         in  varchar2  default null
  ,p_omr_attribute1                 in  varchar2  default null
  ,p_omr_attribute2                 in  varchar2  default null
  ,p_omr_attribute3                 in  varchar2  default null
  ,p_omr_attribute4                 in  varchar2  default null
  ,p_omr_attribute5                 in  varchar2  default null
  ,p_omr_attribute6                 in  varchar2  default null
  ,p_omr_attribute7                 in  varchar2  default null
  ,p_omr_attribute8                 in  varchar2  default null
  ,p_omr_attribute9                 in  varchar2  default null
  ,p_omr_attribute10                in  varchar2  default null
  ,p_omr_attribute11                in  varchar2  default null
  ,p_omr_attribute12                in  varchar2  default null
  ,p_omr_attribute13                in  varchar2  default null
  ,p_omr_attribute14                in  varchar2  default null
  ,p_omr_attribute15                in  varchar2  default null
  ,p_omr_attribute16                in  varchar2  default null
  ,p_omr_attribute17                in  varchar2  default null
  ,p_omr_attribute18                in  varchar2  default null
  ,p_omr_attribute19                in  varchar2  default null
  ,p_omr_attribute20                in  varchar2  default null
  ,p_omr_attribute21                in  varchar2  default null
  ,p_omr_attribute22                in  varchar2  default null
  ,p_omr_attribute23                in  varchar2  default null
  ,p_omr_attribute24                in  varchar2  default null
  ,p_omr_attribute25                in  varchar2  default null
  ,p_omr_attribute26                in  varchar2  default null
  ,p_omr_attribute27                in  varchar2  default null
  ,p_omr_attribute28                in  varchar2  default null
  ,p_omr_attribute29                in  varchar2  default null
  ,p_omr_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_optd_mdcr_rt_id ben_optd_mdcr_rt_f.optd_mdcr_rt_id%type;
  l_effective_start_date ben_optd_mdcr_rt_f.effective_start_date%type;
  l_effective_end_date ben_optd_mdcr_rt_f.effective_end_date%type;
  l_proc varchar2(72) := g_package||'create_optd_mdcr_rt';
  l_object_version_number ben_optd_mdcr_rt_f.object_version_number%type;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_OPTD_MDCR_RT;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_OPTD_MDCR_RT
    --
    ben_OPTD_MDCR_RT_bk1.create_OPTD_MDCR_RT_b
      (
       p_optd_mdcr_flag                 =>  p_optd_mdcr_flag
      ,p_exlcd_flag                     =>  p_exlcd_flag
      ,p_vrbl_rt_prfl_id                  =>  p_vrbl_rt_prfl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_omr_attribute_category         =>  p_omr_attribute_category
      ,p_omr_attribute1                 =>  p_omr_attribute1
      ,p_omr_attribute2                 =>  p_omr_attribute2
      ,p_omr_attribute3                 =>  p_omr_attribute3
      ,p_omr_attribute4                 =>  p_omr_attribute4
      ,p_omr_attribute5                 =>  p_omr_attribute5
      ,p_omr_attribute6                 =>  p_omr_attribute6
      ,p_omr_attribute7                 =>  p_omr_attribute7
      ,p_omr_attribute8                 =>  p_omr_attribute8
      ,p_omr_attribute9                 =>  p_omr_attribute9
      ,p_omr_attribute10                =>  p_omr_attribute10
      ,p_omr_attribute11                =>  p_omr_attribute11
      ,p_omr_attribute12                =>  p_omr_attribute12
      ,p_omr_attribute13                =>  p_omr_attribute13
      ,p_omr_attribute14                =>  p_omr_attribute14
      ,p_omr_attribute15                =>  p_omr_attribute15
      ,p_omr_attribute16                =>  p_omr_attribute16
      ,p_omr_attribute17                =>  p_omr_attribute17
      ,p_omr_attribute18                =>  p_omr_attribute18
      ,p_omr_attribute19                =>  p_omr_attribute19
      ,p_omr_attribute20                =>  p_omr_attribute20
      ,p_omr_attribute21                =>  p_omr_attribute21
      ,p_omr_attribute22                =>  p_omr_attribute22
      ,p_omr_attribute23                =>  p_omr_attribute23
      ,p_omr_attribute24                =>  p_omr_attribute24
      ,p_omr_attribute25                =>  p_omr_attribute25
      ,p_omr_attribute26                =>  p_omr_attribute26
      ,p_omr_attribute27                =>  p_omr_attribute27
      ,p_omr_attribute28                =>  p_omr_attribute28
      ,p_omr_attribute29                =>  p_omr_attribute29
      ,p_omr_attribute30                =>  p_omr_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_OPTD_MDCR_RT'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_OPTD_MDCR_RT
    --
  end;
  --
  ben_omr_ins.ins
    (
     p_OPTD_MDCR_RT_id        => l_OPTD_MDCR_RT_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_optd_mdcr_flag                => p_optd_mdcr_flag
    ,p_exlcd_flag                    => p_exlcd_flag
    ,p_vrbl_rt_prfl_id                 => p_vrbl_rt_prfl_id
    ,p_business_group_id             => p_business_group_id
    ,p_omr_attribute_category        => p_omr_attribute_category
    ,p_omr_attribute1                => p_omr_attribute1
    ,p_omr_attribute2                => p_omr_attribute2
    ,p_omr_attribute3                => p_omr_attribute3
    ,p_omr_attribute4                => p_omr_attribute4
    ,p_omr_attribute5                => p_omr_attribute5
    ,p_omr_attribute6                => p_omr_attribute6
    ,p_omr_attribute7                => p_omr_attribute7
    ,p_omr_attribute8                => p_omr_attribute8
    ,p_omr_attribute9                => p_omr_attribute9
    ,p_omr_attribute10               => p_omr_attribute10
    ,p_omr_attribute11               => p_omr_attribute11
    ,p_omr_attribute12               => p_omr_attribute12
    ,p_omr_attribute13               => p_omr_attribute13
    ,p_omr_attribute14               => p_omr_attribute14
    ,p_omr_attribute15               => p_omr_attribute15
    ,p_omr_attribute16               => p_omr_attribute16
    ,p_omr_attribute17               => p_omr_attribute17
    ,p_omr_attribute18               => p_omr_attribute18
    ,p_omr_attribute19               => p_omr_attribute19
    ,p_omr_attribute20               => p_omr_attribute20
    ,p_omr_attribute21               => p_omr_attribute21
    ,p_omr_attribute22               => p_omr_attribute22
    ,p_omr_attribute23               => p_omr_attribute23
    ,p_omr_attribute24               => p_omr_attribute24
    ,p_omr_attribute25               => p_omr_attribute25
    ,p_omr_attribute26               => p_omr_attribute26
    ,p_omr_attribute27               => p_omr_attribute27
    ,p_omr_attribute28               => p_omr_attribute28
    ,p_omr_attribute29               => p_omr_attribute29
    ,p_omr_attribute30               => p_omr_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_OPTD_MDCR_RT
    --
    ben_OPTD_MDCR_RT_bk1.create_OPTD_MDCR_RT_a
      (
       p_OPTD_MDCR_RT_id         =>  l_OPTD_MDCR_RT_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_optd_mdcr_flag                 =>  p_optd_mdcr_flag
      ,p_exlcd_flag                     =>  p_exlcd_flag
      ,p_vrbl_rt_prfl_id                  =>  p_vrbl_rt_prfl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_omr_attribute_category         =>  p_omr_attribute_category
      ,p_omr_attribute1                 =>  p_omr_attribute1
      ,p_omr_attribute2                 =>  p_omr_attribute2
      ,p_omr_attribute3                 =>  p_omr_attribute3
      ,p_omr_attribute4                 =>  p_omr_attribute4
      ,p_omr_attribute5                 =>  p_omr_attribute5
      ,p_omr_attribute6                 =>  p_omr_attribute6
      ,p_omr_attribute7                 =>  p_omr_attribute7
      ,p_omr_attribute8                 =>  p_omr_attribute8
      ,p_omr_attribute9                 =>  p_omr_attribute9
      ,p_omr_attribute10                =>  p_omr_attribute10
      ,p_omr_attribute11                =>  p_omr_attribute11
      ,p_omr_attribute12                =>  p_omr_attribute12
      ,p_omr_attribute13                =>  p_omr_attribute13
      ,p_omr_attribute14                =>  p_omr_attribute14
      ,p_omr_attribute15                =>  p_omr_attribute15
      ,p_omr_attribute16                =>  p_omr_attribute16
      ,p_omr_attribute17                =>  p_omr_attribute17
      ,p_omr_attribute18                =>  p_omr_attribute18
      ,p_omr_attribute19                =>  p_omr_attribute19
      ,p_omr_attribute20                =>  p_omr_attribute20
      ,p_omr_attribute21                =>  p_omr_attribute21
      ,p_omr_attribute22                =>  p_omr_attribute22
      ,p_omr_attribute23                =>  p_omr_attribute23
      ,p_omr_attribute24                =>  p_omr_attribute24
      ,p_omr_attribute25                =>  p_omr_attribute25
      ,p_omr_attribute26                =>  p_omr_attribute26
      ,p_omr_attribute27                =>  p_omr_attribute27
      ,p_omr_attribute28                =>  p_omr_attribute28
      ,p_omr_attribute29                =>  p_omr_attribute29
      ,p_omr_attribute30                =>  p_omr_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_OPTD_MDCR_RT'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_OPTD_MDCR_RT
    --
  end;
  --
  ben_profile_handler.event_handler
    (p_event                       => 'CREATE',
     p_base_table                  => 'BEN_VRBL_RT_PRFL_F',
     p_base_table_column           => 'vrbl_rt_prfl_id',
     p_base_table_column_value     =>  p_vrbl_rt_prfl_id,
     p_base_table_reference_column => 'RT_OPTD_MDCR_FLAG',
     p_reference_table             => 'BEN_OPTD_MDCR_RT_F',
     p_reference_table_column      => 'vrbl_rt_prfl_id');
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
  p_OPTD_MDCR_RT_id := l_OPTD_MDCR_RT_id;
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
    ROLLBACK TO create_OPTD_MDCR_RT;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_OPTD_MDCR_RT_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_OPTD_MDCR_RT;
    -- NOCOPY Changes
    p_OPTD_MDCR_RT_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    -- NOCOPY Changes

    raise;
    --
end create_OPTD_MDCR_RT;
-- ----------------------------------------------------------------------------
-- |------------------------< update_OPTD_MDCR_RT >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_OPTD_MDCR_RT
  (p_validate                       in  boolean   default false
  ,p_OPTD_MDCR_RT_id         in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_optd_mdcr_flag                 in  varchar2  default hr_api.g_varchar2
  ,p_exlcd_flag                     in  varchar2  default hr_api.g_varchar2
  ,p_vrbl_rt_prfl_id                  in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_omr_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_omr_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_omr_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_omr_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_omr_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_omr_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_omr_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_omr_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_omr_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_omr_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_omr_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_omr_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_omr_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_omr_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_omr_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_omr_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_omr_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_omr_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_omr_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_omr_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_omr_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_omr_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_omr_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_omr_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_omr_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_omr_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_omr_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_omr_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_omr_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_omr_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_omr_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_OPTD_MDCR_RT';
  l_object_version_number ben_OPTD_MDCR_RT_f.object_version_number%TYPE;
  l_effective_start_date ben_OPTD_MDCR_RT_f.effective_start_date%TYPE;
  l_effective_end_date ben_OPTD_MDCR_RT_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_OPTD_MDCR_RT;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_OPTD_MDCR_RT
    --
    ben_OPTD_MDCR_RT_bk2.update_OPTD_MDCR_RT_b
      (
       p_OPTD_MDCR_RT_id         =>  p_OPTD_MDCR_RT_id
      ,p_optd_mdcr_flag                 =>  p_optd_mdcr_flag
      ,p_exlcd_flag                     =>  p_exlcd_flag
      ,p_vrbl_rt_prfl_id                  =>  p_vrbl_rt_prfl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_omr_attribute_category         =>  p_omr_attribute_category
      ,p_omr_attribute1                 =>  p_omr_attribute1
      ,p_omr_attribute2                 =>  p_omr_attribute2
      ,p_omr_attribute3                 =>  p_omr_attribute3
      ,p_omr_attribute4                 =>  p_omr_attribute4
      ,p_omr_attribute5                 =>  p_omr_attribute5
      ,p_omr_attribute6                 =>  p_omr_attribute6
      ,p_omr_attribute7                 =>  p_omr_attribute7
      ,p_omr_attribute8                 =>  p_omr_attribute8
      ,p_omr_attribute9                 =>  p_omr_attribute9
      ,p_omr_attribute10                =>  p_omr_attribute10
      ,p_omr_attribute11                =>  p_omr_attribute11
      ,p_omr_attribute12                =>  p_omr_attribute12
      ,p_omr_attribute13                =>  p_omr_attribute13
      ,p_omr_attribute14                =>  p_omr_attribute14
      ,p_omr_attribute15                =>  p_omr_attribute15
      ,p_omr_attribute16                =>  p_omr_attribute16
      ,p_omr_attribute17                =>  p_omr_attribute17
      ,p_omr_attribute18                =>  p_omr_attribute18
      ,p_omr_attribute19                =>  p_omr_attribute19
      ,p_omr_attribute20                =>  p_omr_attribute20
      ,p_omr_attribute21                =>  p_omr_attribute21
      ,p_omr_attribute22                =>  p_omr_attribute22
      ,p_omr_attribute23                =>  p_omr_attribute23
      ,p_omr_attribute24                =>  p_omr_attribute24
      ,p_omr_attribute25                =>  p_omr_attribute25
      ,p_omr_attribute26                =>  p_omr_attribute26
      ,p_omr_attribute27                =>  p_omr_attribute27
      ,p_omr_attribute28                =>  p_omr_attribute28
      ,p_omr_attribute29                =>  p_omr_attribute29
      ,p_omr_attribute30                =>  p_omr_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_OPTD_MDCR_RT'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_OPTD_MDCR_RT
    --
  end;
  --
  ben_omr_upd.upd
    (
     p_OPTD_MDCR_RT_id        => p_OPTD_MDCR_RT_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_optd_mdcr_flag                => p_optd_mdcr_flag
    ,p_exlcd_flag                    => p_exlcd_flag
    ,p_vrbl_rt_prfl_id                 => p_vrbl_rt_prfl_id
    ,p_business_group_id             => p_business_group_id
    ,p_omr_attribute_category        => p_omr_attribute_category
    ,p_omr_attribute1                => p_omr_attribute1
    ,p_omr_attribute2                => p_omr_attribute2
    ,p_omr_attribute3                => p_omr_attribute3
    ,p_omr_attribute4                => p_omr_attribute4
    ,p_omr_attribute5                => p_omr_attribute5
    ,p_omr_attribute6                => p_omr_attribute6
    ,p_omr_attribute7                => p_omr_attribute7
    ,p_omr_attribute8                => p_omr_attribute8
    ,p_omr_attribute9                => p_omr_attribute9
    ,p_omr_attribute10               => p_omr_attribute10
    ,p_omr_attribute11               => p_omr_attribute11
    ,p_omr_attribute12               => p_omr_attribute12
    ,p_omr_attribute13               => p_omr_attribute13
    ,p_omr_attribute14               => p_omr_attribute14
    ,p_omr_attribute15               => p_omr_attribute15
    ,p_omr_attribute16               => p_omr_attribute16
    ,p_omr_attribute17               => p_omr_attribute17
    ,p_omr_attribute18               => p_omr_attribute18
    ,p_omr_attribute19               => p_omr_attribute19
    ,p_omr_attribute20               => p_omr_attribute20
    ,p_omr_attribute21               => p_omr_attribute21
    ,p_omr_attribute22               => p_omr_attribute22
    ,p_omr_attribute23               => p_omr_attribute23
    ,p_omr_attribute24               => p_omr_attribute24
    ,p_omr_attribute25               => p_omr_attribute25
    ,p_omr_attribute26               => p_omr_attribute26
    ,p_omr_attribute27               => p_omr_attribute27
    ,p_omr_attribute28               => p_omr_attribute28
    ,p_omr_attribute29               => p_omr_attribute29
    ,p_omr_attribute30               => p_omr_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_OPTD_MDCR_RT
    --
    ben_OPTD_MDCR_RT_bk2.update_OPTD_MDCR_RT_a
      (
       p_OPTD_MDCR_RT_id         =>  p_OPTD_MDCR_RT_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_optd_mdcr_flag                 =>  p_optd_mdcr_flag
      ,p_exlcd_flag                     =>  p_exlcd_flag
      ,p_vrbl_rt_prfl_id                  =>  p_vrbl_rt_prfl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_omr_attribute_category         =>  p_omr_attribute_category
      ,p_omr_attribute1                 =>  p_omr_attribute1
      ,p_omr_attribute2                 =>  p_omr_attribute2
      ,p_omr_attribute3                 =>  p_omr_attribute3
      ,p_omr_attribute4                 =>  p_omr_attribute4
      ,p_omr_attribute5                 =>  p_omr_attribute5
      ,p_omr_attribute6                 =>  p_omr_attribute6
      ,p_omr_attribute7                 =>  p_omr_attribute7
      ,p_omr_attribute8                 =>  p_omr_attribute8
      ,p_omr_attribute9                 =>  p_omr_attribute9
      ,p_omr_attribute10                =>  p_omr_attribute10
      ,p_omr_attribute11                =>  p_omr_attribute11
      ,p_omr_attribute12                =>  p_omr_attribute12
      ,p_omr_attribute13                =>  p_omr_attribute13
      ,p_omr_attribute14                =>  p_omr_attribute14
      ,p_omr_attribute15                =>  p_omr_attribute15
      ,p_omr_attribute16                =>  p_omr_attribute16
      ,p_omr_attribute17                =>  p_omr_attribute17
      ,p_omr_attribute18                =>  p_omr_attribute18
      ,p_omr_attribute19                =>  p_omr_attribute19
      ,p_omr_attribute20                =>  p_omr_attribute20
      ,p_omr_attribute21                =>  p_omr_attribute21
      ,p_omr_attribute22                =>  p_omr_attribute22
      ,p_omr_attribute23                =>  p_omr_attribute23
      ,p_omr_attribute24                =>  p_omr_attribute24
      ,p_omr_attribute25                =>  p_omr_attribute25
      ,p_omr_attribute26                =>  p_omr_attribute26
      ,p_omr_attribute27                =>  p_omr_attribute27
      ,p_omr_attribute28                =>  p_omr_attribute28
      ,p_omr_attribute29                =>  p_omr_attribute29
      ,p_omr_attribute30                =>  p_omr_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_OPTD_MDCR_RT'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_OPTD_MDCR_RT
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
    ROLLBACK TO update_OPTD_MDCR_RT;
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
    ROLLBACK TO update_OPTD_MDCR_RT;
    -- NOCOPY Changes
    p_effective_start_date := null;
    p_effective_end_date := null;
    -- NOCOPY Changes

    raise;
    --
end update_OPTD_MDCR_RT;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_OPTD_MDCR_RT >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_OPTD_MDCR_RT
  (p_validate                       in  boolean  default false
  ,p_OPTD_MDCR_RT_id         in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_OPTD_MDCR_RT';
  l_object_version_number ben_OPTD_MDCR_RT_f.object_version_number%TYPE;
  l_effective_start_date ben_OPTD_MDCR_RT_f.effective_start_date%TYPE;
  l_effective_end_date ben_OPTD_MDCR_RT_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_OPTD_MDCR_RT;
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
    -- Start of API User Hook for the before hook of delete_OPTD_MDCR_RT
    --
    ben_OPTD_MDCR_RT_bk3.delete_OPTD_MDCR_RT_b
      (
       p_OPTD_MDCR_RT_id         =>  p_OPTD_MDCR_RT_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_OPTD_MDCR_RT'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_OPTD_MDCR_RT
    --
  end;
  --
  ben_omr_del.del
    (
     p_OPTD_MDCR_RT_id        => p_OPTD_MDCR_RT_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_OPTD_MDCR_RT
    --
    ben_OPTD_MDCR_RT_bk3.delete_OPTD_MDCR_RT_a
      (
       p_OPTD_MDCR_RT_id         =>  p_OPTD_MDCR_RT_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_OPTD_MDCR_RT'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_OPTD_MDCR_RT
    --
  end;
  --
  ben_profile_handler.event_handler
    (p_event                       => 'DELETE',
     p_base_table                  => 'BEN_VRBL_RT_PRFL_F',
     p_base_table_column           => 'vrbl_rt_prfl_id',
     p_base_table_column_value     => ben_omr_shd.g_old_rec.vrbl_rt_prfl_id,
     p_base_table_reference_column => 'RT_OPTD_MDCR_FLAG',
     p_reference_table             => 'BEN_OPTD_MDCR_RT_F',
     p_reference_table_column      => 'vrbl_rt_prfl_id');
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
    ROLLBACK TO delete_optd_mdcr_rt;
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
    ROLLBACK TO delete_OPTD_MDCR_RT;
    -- NOCOPY Changes
    p_effective_start_date := null;
    p_effective_end_date := null;
    -- NOCOPY Changes

    raise;
    --
end delete_OPTD_MDCR_RT;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_OPTD_MDCR_RT_id                   in     number
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
  ben_omr_shd.lck
    (
      p_OPTD_MDCR_RT_id                 => p_OPTD_MDCR_RT_id
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
end ben_OPTD_MDCR_RT_api;

/
