--------------------------------------------------------
--  DDL for Package Body BEN_DPNT_CVRD_PLIP_RT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_DPNT_CVRD_PLIP_RT_API" as
/* $Header: bedcpapi.pkb 120.0 2005/05/28 01:33:38 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_DPNT_CVRD_PLIP_RT_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_DPNT_CVRD_PLIP_RT >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_DPNT_CVRD_PLIP_RT
  (p_validate                       in  boolean   default false
  ,p_dpnt_cvrd_plip_rt_id         out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_excld_flag                     in  varchar2  default 'N'
  ,p_ordr_num                       in  number    default null
  ,p_enrl_det_dt_cd                 in  varchar2  default null
  ,p_plip_id                        in  number    default null
  ,p_vrbl_rt_prfl_id                  in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_dcp_attribute_category         in  varchar2  default null
  ,p_dcp_attribute1                 in  varchar2  default null
  ,p_dcp_attribute2                 in  varchar2  default null
  ,p_dcp_attribute3                 in  varchar2  default null
  ,p_dcp_attribute4                 in  varchar2  default null
  ,p_dcp_attribute5                 in  varchar2  default null
  ,p_dcp_attribute6                 in  varchar2  default null
  ,p_dcp_attribute7                 in  varchar2  default null
  ,p_dcp_attribute8                 in  varchar2  default null
  ,p_dcp_attribute9                 in  varchar2  default null
  ,p_dcp_attribute10                in  varchar2  default null
  ,p_dcp_attribute11                in  varchar2  default null
  ,p_dcp_attribute12                in  varchar2  default null
  ,p_dcp_attribute13                in  varchar2  default null
  ,p_dcp_attribute14                in  varchar2  default null
  ,p_dcp_attribute15                in  varchar2  default null
  ,p_dcp_attribute16                in  varchar2  default null
  ,p_dcp_attribute17                in  varchar2  default null
  ,p_dcp_attribute18                in  varchar2  default null
  ,p_dcp_attribute19                in  varchar2  default null
  ,p_dcp_attribute20                in  varchar2  default null
  ,p_dcp_attribute21                in  varchar2  default null
  ,p_dcp_attribute22                in  varchar2  default null
  ,p_dcp_attribute23                in  varchar2  default null
  ,p_dcp_attribute24                in  varchar2  default null
  ,p_dcp_attribute25                in  varchar2  default null
  ,p_dcp_attribute26                in  varchar2  default null
  ,p_dcp_attribute27                in  varchar2  default null
  ,p_dcp_attribute28                in  varchar2  default null
  ,p_dcp_attribute29                in  varchar2  default null
  ,p_dcp_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_dpnt_cvrd_plip_rt_id ben_dpnt_cvrd_plip_rt_f.dpnt_cvrd_plip_rt_id%TYPE;
  l_effective_start_date ben_dpnt_cvrd_plip_rt_f.effective_start_date%TYPE;
  l_effective_end_date ben_dpnt_cvrd_plip_rt_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_DPNT_CVRD_PLIP_RT';
  l_object_version_number ben_dpnt_cvrd_plip_rt_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_DPNT_CVRD_PLIP_RT;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_DPNT_CVRD_PLIP_RT
    --
    ben_DPNT_CVRD_PLIP_RT_bk1.create_DPNT_CVRD_PLIP_RT_b
      (
       p_excld_flag                     =>  p_excld_flag
      ,p_ordr_num                       =>  p_ordr_num
      ,p_enrl_det_dt_cd                 =>  p_enrl_det_dt_cd
      ,p_plip_id                        =>  p_plip_id
      ,p_vrbl_rt_prfl_id                  =>  p_vrbl_rt_prfl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_dcp_attribute_category         =>  p_dcp_attribute_category
      ,p_dcp_attribute1                 =>  p_dcp_attribute1
      ,p_dcp_attribute2                 =>  p_dcp_attribute2
      ,p_dcp_attribute3                 =>  p_dcp_attribute3
      ,p_dcp_attribute4                 =>  p_dcp_attribute4
      ,p_dcp_attribute5                 =>  p_dcp_attribute5
      ,p_dcp_attribute6                 =>  p_dcp_attribute6
      ,p_dcp_attribute7                 =>  p_dcp_attribute7
      ,p_dcp_attribute8                 =>  p_dcp_attribute8
      ,p_dcp_attribute9                 =>  p_dcp_attribute9
      ,p_dcp_attribute10                =>  p_dcp_attribute10
      ,p_dcp_attribute11                =>  p_dcp_attribute11
      ,p_dcp_attribute12                =>  p_dcp_attribute12
      ,p_dcp_attribute13                =>  p_dcp_attribute13
      ,p_dcp_attribute14                =>  p_dcp_attribute14
      ,p_dcp_attribute15                =>  p_dcp_attribute15
      ,p_dcp_attribute16                =>  p_dcp_attribute16
      ,p_dcp_attribute17                =>  p_dcp_attribute17
      ,p_dcp_attribute18                =>  p_dcp_attribute18
      ,p_dcp_attribute19                =>  p_dcp_attribute19
      ,p_dcp_attribute20                =>  p_dcp_attribute20
      ,p_dcp_attribute21                =>  p_dcp_attribute21
      ,p_dcp_attribute22                =>  p_dcp_attribute22
      ,p_dcp_attribute23                =>  p_dcp_attribute23
      ,p_dcp_attribute24                =>  p_dcp_attribute24
      ,p_dcp_attribute25                =>  p_dcp_attribute25
      ,p_dcp_attribute26                =>  p_dcp_attribute26
      ,p_dcp_attribute27                =>  p_dcp_attribute27
      ,p_dcp_attribute28                =>  p_dcp_attribute28
      ,p_dcp_attribute29                =>  p_dcp_attribute29
      ,p_dcp_attribute30                =>  p_dcp_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_DPNT_CVRD_PLIP_RT'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_DPNT_CVRD_PLIP_RT
    --
  end;
  --
  ben_dcp_ins.ins
    (
     p_dpnt_cvrd_plip_rt_id        => l_dpnt_cvrd_plip_rt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_excld_flag                    => p_excld_flag
    ,p_ordr_num                      => p_ordr_num
    ,p_enrl_det_dt_cd                => p_enrl_det_dt_cd
    ,p_plip_id                       => p_plip_id
    ,p_vrbl_rt_prfl_id                 => p_vrbl_rt_prfl_id
    ,p_business_group_id             => p_business_group_id
    ,p_dcp_attribute_category        => p_dcp_attribute_category
    ,p_dcp_attribute1                => p_dcp_attribute1
    ,p_dcp_attribute2                => p_dcp_attribute2
    ,p_dcp_attribute3                => p_dcp_attribute3
    ,p_dcp_attribute4                => p_dcp_attribute4
    ,p_dcp_attribute5                => p_dcp_attribute5
    ,p_dcp_attribute6                => p_dcp_attribute6
    ,p_dcp_attribute7                => p_dcp_attribute7
    ,p_dcp_attribute8                => p_dcp_attribute8
    ,p_dcp_attribute9                => p_dcp_attribute9
    ,p_dcp_attribute10               => p_dcp_attribute10
    ,p_dcp_attribute11               => p_dcp_attribute11
    ,p_dcp_attribute12               => p_dcp_attribute12
    ,p_dcp_attribute13               => p_dcp_attribute13
    ,p_dcp_attribute14               => p_dcp_attribute14
    ,p_dcp_attribute15               => p_dcp_attribute15
    ,p_dcp_attribute16               => p_dcp_attribute16
    ,p_dcp_attribute17               => p_dcp_attribute17
    ,p_dcp_attribute18               => p_dcp_attribute18
    ,p_dcp_attribute19               => p_dcp_attribute19
    ,p_dcp_attribute20               => p_dcp_attribute20
    ,p_dcp_attribute21               => p_dcp_attribute21
    ,p_dcp_attribute22               => p_dcp_attribute22
    ,p_dcp_attribute23               => p_dcp_attribute23
    ,p_dcp_attribute24               => p_dcp_attribute24
    ,p_dcp_attribute25               => p_dcp_attribute25
    ,p_dcp_attribute26               => p_dcp_attribute26
    ,p_dcp_attribute27               => p_dcp_attribute27
    ,p_dcp_attribute28               => p_dcp_attribute28
    ,p_dcp_attribute29               => p_dcp_attribute29
    ,p_dcp_attribute30               => p_dcp_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_DPNT_CVRD_PLIP_RT
    --
    ben_DPNT_CVRD_PLIP_RT_bk1.create_DPNT_CVRD_PLIP_RT_a
      (
       p_dpnt_cvrd_plip_rt_id         =>  l_dpnt_cvrd_plip_rt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_excld_flag                     =>  p_excld_flag
      ,p_ordr_num                       =>  p_ordr_num
      ,p_enrl_det_dt_cd                 =>  p_enrl_det_dt_cd
      ,p_plip_id                        =>  p_plip_id
      ,p_vrbl_rt_prfl_id                  =>  p_vrbl_rt_prfl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_dcp_attribute_category         =>  p_dcp_attribute_category
      ,p_dcp_attribute1                 =>  p_dcp_attribute1
      ,p_dcp_attribute2                 =>  p_dcp_attribute2
      ,p_dcp_attribute3                 =>  p_dcp_attribute3
      ,p_dcp_attribute4                 =>  p_dcp_attribute4
      ,p_dcp_attribute5                 =>  p_dcp_attribute5
      ,p_dcp_attribute6                 =>  p_dcp_attribute6
      ,p_dcp_attribute7                 =>  p_dcp_attribute7
      ,p_dcp_attribute8                 =>  p_dcp_attribute8
      ,p_dcp_attribute9                 =>  p_dcp_attribute9
      ,p_dcp_attribute10                =>  p_dcp_attribute10
      ,p_dcp_attribute11                =>  p_dcp_attribute11
      ,p_dcp_attribute12                =>  p_dcp_attribute12
      ,p_dcp_attribute13                =>  p_dcp_attribute13
      ,p_dcp_attribute14                =>  p_dcp_attribute14
      ,p_dcp_attribute15                =>  p_dcp_attribute15
      ,p_dcp_attribute16                =>  p_dcp_attribute16
      ,p_dcp_attribute17                =>  p_dcp_attribute17
      ,p_dcp_attribute18                =>  p_dcp_attribute18
      ,p_dcp_attribute19                =>  p_dcp_attribute19
      ,p_dcp_attribute20                =>  p_dcp_attribute20
      ,p_dcp_attribute21                =>  p_dcp_attribute21
      ,p_dcp_attribute22                =>  p_dcp_attribute22
      ,p_dcp_attribute23                =>  p_dcp_attribute23
      ,p_dcp_attribute24                =>  p_dcp_attribute24
      ,p_dcp_attribute25                =>  p_dcp_attribute25
      ,p_dcp_attribute26                =>  p_dcp_attribute26
      ,p_dcp_attribute27                =>  p_dcp_attribute27
      ,p_dcp_attribute28                =>  p_dcp_attribute28
      ,p_dcp_attribute29                =>  p_dcp_attribute29
      ,p_dcp_attribute30                =>  p_dcp_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_DPNT_CVRD_PLIP_RT'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_DPNT_CVRD_PLIP_RT
    --
  end;
  --
  ben_profile_handler.event_handler
    (p_event                       => 'CREATE',
     p_base_table                  => 'BEN_VRBL_RT_PRFL_F',
     p_base_table_column           => 'VRBL_RT_PRFL_ID',
     p_base_table_column_value     => p_vrbl_rt_prfl_id,
     p_base_table_reference_column => 'RT_DPNT_CVRD_PLIP_FLAG',
     p_reference_table             => 'BEN_DPNT_CVRD_PLIP_RT_F',
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
  p_dpnt_cvrd_plip_rt_id := l_dpnt_cvrd_plip_rt_id;
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
    ROLLBACK TO create_DPNT_CVRD_PLIP_RT;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_dpnt_cvrd_plip_rt_id := null;
    p_effective_start_date := null;
    p_effective_end_date   := null;
    p_object_version_number:= null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    --Init to null for NOCOPY OUT variable
    --
    p_dpnt_cvrd_plip_rt_id :=null ;
    p_effective_start_date :=null ;
    p_object_version_number:= null;
    p_effective_end_date   := null ;
    --

    ROLLBACK TO create_DPNT_CVRD_PLIP_RT;
    raise;
    --
end create_DPNT_CVRD_PLIP_RT;
-- ----------------------------------------------------------------------------
-- |------------------------< update_DPNT_CVRD_PLIP_RT >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_DPNT_CVRD_PLIP_RT
  (p_validate                       in  boolean   default false
  ,p_dpnt_cvrd_plip_rt_id         in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_excld_flag                     in  varchar2  default hr_api.g_varchar2
  ,p_ordr_num                       in  number    default hr_api.g_number
  ,p_enrl_det_dt_cd                 in  varchar2  default hr_api.g_varchar2
  ,p_plip_id                        in  number    default hr_api.g_number
  ,p_vrbl_rt_prfl_id                  in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_dcp_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_dcp_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_dcp_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_dcp_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_dcp_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_dcp_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_dcp_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_dcp_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_dcp_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_dcp_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_dcp_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_dcp_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_dcp_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_dcp_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_dcp_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_dcp_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_dcp_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_dcp_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_dcp_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_dcp_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_dcp_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_dcp_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_dcp_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_dcp_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_dcp_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_dcp_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_dcp_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_dcp_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_dcp_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_dcp_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_dcp_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_DPNT_CVRD_PLIP_RT';
  l_object_version_number ben_dpnt_cvrd_plip_rt_f.object_version_number%TYPE;
  l_effective_start_date ben_dpnt_cvrd_plip_rt_f.effective_start_date%TYPE;
  l_effective_end_date ben_dpnt_cvrd_plip_rt_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_DPNT_CVRD_PLIP_RT;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_DPNT_CVRD_PLIP_RT
    --
    ben_DPNT_CVRD_PLIP_RT_bk2.update_DPNT_CVRD_PLIP_RT_b
      (
       p_dpnt_cvrd_plip_rt_id         =>  p_dpnt_cvrd_plip_rt_id
      ,p_excld_flag                     =>  p_excld_flag
      ,p_ordr_num                       =>  p_ordr_num
      ,p_enrl_det_dt_cd                 =>  p_enrl_det_dt_cd
      ,p_plip_id                        =>  p_plip_id
      ,p_vrbl_rt_prfl_id                  =>  p_vrbl_rt_prfl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_dcp_attribute_category         =>  p_dcp_attribute_category
      ,p_dcp_attribute1                 =>  p_dcp_attribute1
      ,p_dcp_attribute2                 =>  p_dcp_attribute2
      ,p_dcp_attribute3                 =>  p_dcp_attribute3
      ,p_dcp_attribute4                 =>  p_dcp_attribute4
      ,p_dcp_attribute5                 =>  p_dcp_attribute5
      ,p_dcp_attribute6                 =>  p_dcp_attribute6
      ,p_dcp_attribute7                 =>  p_dcp_attribute7
      ,p_dcp_attribute8                 =>  p_dcp_attribute8
      ,p_dcp_attribute9                 =>  p_dcp_attribute9
      ,p_dcp_attribute10                =>  p_dcp_attribute10
      ,p_dcp_attribute11                =>  p_dcp_attribute11
      ,p_dcp_attribute12                =>  p_dcp_attribute12
      ,p_dcp_attribute13                =>  p_dcp_attribute13
      ,p_dcp_attribute14                =>  p_dcp_attribute14
      ,p_dcp_attribute15                =>  p_dcp_attribute15
      ,p_dcp_attribute16                =>  p_dcp_attribute16
      ,p_dcp_attribute17                =>  p_dcp_attribute17
      ,p_dcp_attribute18                =>  p_dcp_attribute18
      ,p_dcp_attribute19                =>  p_dcp_attribute19
      ,p_dcp_attribute20                =>  p_dcp_attribute20
      ,p_dcp_attribute21                =>  p_dcp_attribute21
      ,p_dcp_attribute22                =>  p_dcp_attribute22
      ,p_dcp_attribute23                =>  p_dcp_attribute23
      ,p_dcp_attribute24                =>  p_dcp_attribute24
      ,p_dcp_attribute25                =>  p_dcp_attribute25
      ,p_dcp_attribute26                =>  p_dcp_attribute26
      ,p_dcp_attribute27                =>  p_dcp_attribute27
      ,p_dcp_attribute28                =>  p_dcp_attribute28
      ,p_dcp_attribute29                =>  p_dcp_attribute29
      ,p_dcp_attribute30                =>  p_dcp_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_DPNT_CVRD_PLIP_RT'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_DPNT_CVRD_PLIP_RT
    --
  end;
  --
  ben_dcp_upd.upd
    (
     p_dpnt_cvrd_plip_rt_id        => p_dpnt_cvrd_plip_rt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_excld_flag                    => p_excld_flag
    ,p_ordr_num                      => p_ordr_num
    ,p_enrl_det_dt_cd                => p_enrl_det_dt_cd
    ,p_plip_id                       => p_plip_id
    ,p_vrbl_rt_prfl_id                 => p_vrbl_rt_prfl_id
    ,p_business_group_id             => p_business_group_id
    ,p_dcp_attribute_category        => p_dcp_attribute_category
    ,p_dcp_attribute1                => p_dcp_attribute1
    ,p_dcp_attribute2                => p_dcp_attribute2
    ,p_dcp_attribute3                => p_dcp_attribute3
    ,p_dcp_attribute4                => p_dcp_attribute4
    ,p_dcp_attribute5                => p_dcp_attribute5
    ,p_dcp_attribute6                => p_dcp_attribute6
    ,p_dcp_attribute7                => p_dcp_attribute7
    ,p_dcp_attribute8                => p_dcp_attribute8
    ,p_dcp_attribute9                => p_dcp_attribute9
    ,p_dcp_attribute10               => p_dcp_attribute10
    ,p_dcp_attribute11               => p_dcp_attribute11
    ,p_dcp_attribute12               => p_dcp_attribute12
    ,p_dcp_attribute13               => p_dcp_attribute13
    ,p_dcp_attribute14               => p_dcp_attribute14
    ,p_dcp_attribute15               => p_dcp_attribute15
    ,p_dcp_attribute16               => p_dcp_attribute16
    ,p_dcp_attribute17               => p_dcp_attribute17
    ,p_dcp_attribute18               => p_dcp_attribute18
    ,p_dcp_attribute19               => p_dcp_attribute19
    ,p_dcp_attribute20               => p_dcp_attribute20
    ,p_dcp_attribute21               => p_dcp_attribute21
    ,p_dcp_attribute22               => p_dcp_attribute22
    ,p_dcp_attribute23               => p_dcp_attribute23
    ,p_dcp_attribute24               => p_dcp_attribute24
    ,p_dcp_attribute25               => p_dcp_attribute25
    ,p_dcp_attribute26               => p_dcp_attribute26
    ,p_dcp_attribute27               => p_dcp_attribute27
    ,p_dcp_attribute28               => p_dcp_attribute28
    ,p_dcp_attribute29               => p_dcp_attribute29
    ,p_dcp_attribute30               => p_dcp_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_DPNT_CVRD_PLIP_RT
    --
    ben_DPNT_CVRD_PLIP_RT_bk2.update_DPNT_CVRD_PLIP_RT_a
      (
       p_dpnt_cvrd_plip_rt_id         =>  p_dpnt_cvrd_plip_rt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_excld_flag                     =>  p_excld_flag
      ,p_ordr_num                       =>  p_ordr_num
      ,p_enrl_det_dt_cd                 =>  p_enrl_det_dt_cd
      ,p_plip_id                        =>  p_plip_id
      ,p_vrbl_rt_prfl_id                  =>  p_vrbl_rt_prfl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_dcp_attribute_category         =>  p_dcp_attribute_category
      ,p_dcp_attribute1                 =>  p_dcp_attribute1
      ,p_dcp_attribute2                 =>  p_dcp_attribute2
      ,p_dcp_attribute3                 =>  p_dcp_attribute3
      ,p_dcp_attribute4                 =>  p_dcp_attribute4
      ,p_dcp_attribute5                 =>  p_dcp_attribute5
      ,p_dcp_attribute6                 =>  p_dcp_attribute6
      ,p_dcp_attribute7                 =>  p_dcp_attribute7
      ,p_dcp_attribute8                 =>  p_dcp_attribute8
      ,p_dcp_attribute9                 =>  p_dcp_attribute9
      ,p_dcp_attribute10                =>  p_dcp_attribute10
      ,p_dcp_attribute11                =>  p_dcp_attribute11
      ,p_dcp_attribute12                =>  p_dcp_attribute12
      ,p_dcp_attribute13                =>  p_dcp_attribute13
      ,p_dcp_attribute14                =>  p_dcp_attribute14
      ,p_dcp_attribute15                =>  p_dcp_attribute15
      ,p_dcp_attribute16                =>  p_dcp_attribute16
      ,p_dcp_attribute17                =>  p_dcp_attribute17
      ,p_dcp_attribute18                =>  p_dcp_attribute18
      ,p_dcp_attribute19                =>  p_dcp_attribute19
      ,p_dcp_attribute20                =>  p_dcp_attribute20
      ,p_dcp_attribute21                =>  p_dcp_attribute21
      ,p_dcp_attribute22                =>  p_dcp_attribute22
      ,p_dcp_attribute23                =>  p_dcp_attribute23
      ,p_dcp_attribute24                =>  p_dcp_attribute24
      ,p_dcp_attribute25                =>  p_dcp_attribute25
      ,p_dcp_attribute26                =>  p_dcp_attribute26
      ,p_dcp_attribute27                =>  p_dcp_attribute27
      ,p_dcp_attribute28                =>  p_dcp_attribute28
      ,p_dcp_attribute29                =>  p_dcp_attribute29
      ,p_dcp_attribute30                =>  p_dcp_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_DPNT_CVRD_PLIP_RT'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_DPNT_CVRD_PLIP_RT
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
    ROLLBACK TO update_DPNT_CVRD_PLIP_RT;
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

    -- Init to null for NOCOPY OUT variable
    --
    p_effective_start_date :=null ;
    p_effective_end_date   :=null ;

    -- Init to local var for NOCOPY IN OUT variable
    --
    p_object_version_number := l_object_version_number ;
    --

    ROLLBACK TO update_DPNT_CVRD_PLIP_RT;
    raise;
    --
end update_DPNT_CVRD_PLIP_RT;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_DPNT_CVRD_PLIP_RT >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_DPNT_CVRD_PLIP_RT
  (p_validate                       in  boolean  default false
  ,p_dpnt_cvrd_plip_rt_id         in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_DPNT_CVRD_PLIP_RT';
  l_object_version_number ben_dpnt_cvrd_plip_rt_f.object_version_number%TYPE;
  l_effective_start_date ben_dpnt_cvrd_plip_rt_f.effective_start_date%TYPE;
  l_effective_end_date ben_dpnt_cvrd_plip_rt_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_DPNT_CVRD_PLIP_RT;
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
    -- Start of API User Hook for the before hook of delete_DPNT_CVRD_PLIP_RT
    --
    ben_DPNT_CVRD_PLIP_RT_bk3.delete_DPNT_CVRD_PLIP_RT_b
      (
       p_dpnt_cvrd_plip_rt_id         =>  p_dpnt_cvrd_plip_rt_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_DPNT_CVRD_PLIP_RT'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_DPNT_CVRD_PLIP_RT
    --
  end;
  --
  ben_dcp_del.del
    (
     p_dpnt_cvrd_plip_rt_id        => p_dpnt_cvrd_plip_rt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_DPNT_CVRD_PLIP_RT
    --
    ben_DPNT_CVRD_PLIP_RT_bk3.delete_DPNT_CVRD_PLIP_RT_a
      (
       p_dpnt_cvrd_plip_rt_id         =>  p_dpnt_cvrd_plip_rt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_DPNT_CVRD_PLIP_RT'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_DPNT_CVRD_PLIP_RT
    --
  end;
  --
  ben_profile_handler.event_handler
    (p_event                       => 'DELETE',
     p_base_table                  => 'BEN_VRBL_RT_PRFL_F',
     p_base_table_column           => 'VRBL_RT_PRFL_ID',
     p_base_table_column_value     => ben_dcp_shd.g_old_rec.vrbl_rt_prfl_id,
     p_base_table_reference_column => 'RT_DPNT_CVRD_PLIP_FLAG',
     p_reference_table             => 'BEN_DPNT_CVRD_PLIP_RT_F',
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
    ROLLBACK TO delete_DPNT_CVRD_PLIP_RT;
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

    -- Init to null for NOCOPY OUT variable

    p_effective_start_date  :=null ;
    p_effective_end_date    :=null ;

    --
    -- Init to local var for NOCOPY IN OUT variable
    p_object_version_number := l_object_version_number ;

    --
    ROLLBACK TO delete_DPNT_CVRD_PLIP_RT;
    raise;
    --
end delete_DPNT_CVRD_PLIP_RT;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_dpnt_cvrd_plip_rt_id                   in     number
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
  ben_dcp_shd.lck
    (
      p_dpnt_cvrd_plip_rt_id                 => p_dpnt_cvrd_plip_rt_id
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
end ben_DPNT_CVRD_PLIP_RT_api;

/
