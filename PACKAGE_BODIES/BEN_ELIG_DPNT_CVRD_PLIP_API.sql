--------------------------------------------------------
--  DDL for Package Body BEN_ELIG_DPNT_CVRD_PLIP_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ELIG_DPNT_CVRD_PLIP_API" as
/* $Header: beediapi.pkb 120.0 2005/05/28 01:59:14 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_ELIG_DPNT_CVRD_PLIP_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_ELIG_DPNT_CVRD_PLIP >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ELIG_DPNT_CVRD_PLIP
  (p_validate                       in  boolean   default false
  ,p_elig_dpnt_cvrd_plip_id         out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_excld_flag                     in  varchar2  default 'N'
  ,p_ordr_num                       in  number    default null
  ,p_enrl_det_dt_cd                 in  varchar2  default null
  ,p_plip_id                        in  number    default null
  ,p_eligy_prfl_id                  in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_edi_attribute_category         in  varchar2  default null
  ,p_edi_attribute1                 in  varchar2  default null
  ,p_edi_attribute2                 in  varchar2  default null
  ,p_edi_attribute3                 in  varchar2  default null
  ,p_edi_attribute4                 in  varchar2  default null
  ,p_edi_attribute5                 in  varchar2  default null
  ,p_edi_attribute6                 in  varchar2  default null
  ,p_edi_attribute7                 in  varchar2  default null
  ,p_edi_attribute8                 in  varchar2  default null
  ,p_edi_attribute9                 in  varchar2  default null
  ,p_edi_attribute10                in  varchar2  default null
  ,p_edi_attribute11                in  varchar2  default null
  ,p_edi_attribute12                in  varchar2  default null
  ,p_edi_attribute13                in  varchar2  default null
  ,p_edi_attribute14                in  varchar2  default null
  ,p_edi_attribute15                in  varchar2  default null
  ,p_edi_attribute16                in  varchar2  default null
  ,p_edi_attribute17                in  varchar2  default null
  ,p_edi_attribute18                in  varchar2  default null
  ,p_edi_attribute19                in  varchar2  default null
  ,p_edi_attribute20                in  varchar2  default null
  ,p_edi_attribute21                in  varchar2  default null
  ,p_edi_attribute22                in  varchar2  default null
  ,p_edi_attribute23                in  varchar2  default null
  ,p_edi_attribute24                in  varchar2  default null
  ,p_edi_attribute25                in  varchar2  default null
  ,p_edi_attribute26                in  varchar2  default null
  ,p_edi_attribute27                in  varchar2  default null
  ,p_edi_attribute28                in  varchar2  default null
  ,p_edi_attribute29                in  varchar2  default null
  ,p_edi_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_elig_dpnt_cvrd_plip_id ben_elig_dpnt_cvrd_plip_f.elig_dpnt_cvrd_plip_id%TYPE;
  l_effective_start_date ben_elig_dpnt_cvrd_plip_f.effective_start_date%TYPE;
  l_effective_end_date ben_elig_dpnt_cvrd_plip_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_ELIG_DPNT_CVRD_PLIP';
  l_object_version_number ben_elig_dpnt_cvrd_plip_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_ELIG_DPNT_CVRD_PLIP;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_ELIG_DPNT_CVRD_PLIP
    --
    ben_ELIG_DPNT_CVRD_PLIP_bk1.create_ELIG_DPNT_CVRD_PLIP_b
      (
       p_excld_flag                     =>  p_excld_flag
      ,p_ordr_num                       =>  p_ordr_num
      ,p_enrl_det_dt_cd                 =>  p_enrl_det_dt_cd
      ,p_plip_id                        =>  p_plip_id
      ,p_eligy_prfl_id                  =>  p_eligy_prfl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_edi_attribute_category         =>  p_edi_attribute_category
      ,p_edi_attribute1                 =>  p_edi_attribute1
      ,p_edi_attribute2                 =>  p_edi_attribute2
      ,p_edi_attribute3                 =>  p_edi_attribute3
      ,p_edi_attribute4                 =>  p_edi_attribute4
      ,p_edi_attribute5                 =>  p_edi_attribute5
      ,p_edi_attribute6                 =>  p_edi_attribute6
      ,p_edi_attribute7                 =>  p_edi_attribute7
      ,p_edi_attribute8                 =>  p_edi_attribute8
      ,p_edi_attribute9                 =>  p_edi_attribute9
      ,p_edi_attribute10                =>  p_edi_attribute10
      ,p_edi_attribute11                =>  p_edi_attribute11
      ,p_edi_attribute12                =>  p_edi_attribute12
      ,p_edi_attribute13                =>  p_edi_attribute13
      ,p_edi_attribute14                =>  p_edi_attribute14
      ,p_edi_attribute15                =>  p_edi_attribute15
      ,p_edi_attribute16                =>  p_edi_attribute16
      ,p_edi_attribute17                =>  p_edi_attribute17
      ,p_edi_attribute18                =>  p_edi_attribute18
      ,p_edi_attribute19                =>  p_edi_attribute19
      ,p_edi_attribute20                =>  p_edi_attribute20
      ,p_edi_attribute21                =>  p_edi_attribute21
      ,p_edi_attribute22                =>  p_edi_attribute22
      ,p_edi_attribute23                =>  p_edi_attribute23
      ,p_edi_attribute24                =>  p_edi_attribute24
      ,p_edi_attribute25                =>  p_edi_attribute25
      ,p_edi_attribute26                =>  p_edi_attribute26
      ,p_edi_attribute27                =>  p_edi_attribute27
      ,p_edi_attribute28                =>  p_edi_attribute28
      ,p_edi_attribute29                =>  p_edi_attribute29
      ,p_edi_attribute30                =>  p_edi_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_ELIG_DPNT_CVRD_PLIP'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_ELIG_DPNT_CVRD_PLIP
    --
  end;
  --
  ben_edi_ins.ins
    (
     p_elig_dpnt_cvrd_plip_id        => l_elig_dpnt_cvrd_plip_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_excld_flag                    => p_excld_flag
    ,p_ordr_num                      => p_ordr_num
    ,p_enrl_det_dt_cd                => p_enrl_det_dt_cd
    ,p_plip_id                       => p_plip_id
    ,p_eligy_prfl_id                 => p_eligy_prfl_id
    ,p_business_group_id             => p_business_group_id
    ,p_edi_attribute_category        => p_edi_attribute_category
    ,p_edi_attribute1                => p_edi_attribute1
    ,p_edi_attribute2                => p_edi_attribute2
    ,p_edi_attribute3                => p_edi_attribute3
    ,p_edi_attribute4                => p_edi_attribute4
    ,p_edi_attribute5                => p_edi_attribute5
    ,p_edi_attribute6                => p_edi_attribute6
    ,p_edi_attribute7                => p_edi_attribute7
    ,p_edi_attribute8                => p_edi_attribute8
    ,p_edi_attribute9                => p_edi_attribute9
    ,p_edi_attribute10               => p_edi_attribute10
    ,p_edi_attribute11               => p_edi_attribute11
    ,p_edi_attribute12               => p_edi_attribute12
    ,p_edi_attribute13               => p_edi_attribute13
    ,p_edi_attribute14               => p_edi_attribute14
    ,p_edi_attribute15               => p_edi_attribute15
    ,p_edi_attribute16               => p_edi_attribute16
    ,p_edi_attribute17               => p_edi_attribute17
    ,p_edi_attribute18               => p_edi_attribute18
    ,p_edi_attribute19               => p_edi_attribute19
    ,p_edi_attribute20               => p_edi_attribute20
    ,p_edi_attribute21               => p_edi_attribute21
    ,p_edi_attribute22               => p_edi_attribute22
    ,p_edi_attribute23               => p_edi_attribute23
    ,p_edi_attribute24               => p_edi_attribute24
    ,p_edi_attribute25               => p_edi_attribute25
    ,p_edi_attribute26               => p_edi_attribute26
    ,p_edi_attribute27               => p_edi_attribute27
    ,p_edi_attribute28               => p_edi_attribute28
    ,p_edi_attribute29               => p_edi_attribute29
    ,p_edi_attribute30               => p_edi_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_ELIG_DPNT_CVRD_PLIP
    --
    ben_ELIG_DPNT_CVRD_PLIP_bk1.create_ELIG_DPNT_CVRD_PLIP_a
      (
       p_elig_dpnt_cvrd_plip_id         =>  l_elig_dpnt_cvrd_plip_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_excld_flag                     =>  p_excld_flag
      ,p_ordr_num                       =>  p_ordr_num
      ,p_enrl_det_dt_cd                 =>  p_enrl_det_dt_cd
      ,p_plip_id                        =>  p_plip_id
      ,p_eligy_prfl_id                  =>  p_eligy_prfl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_edi_attribute_category         =>  p_edi_attribute_category
      ,p_edi_attribute1                 =>  p_edi_attribute1
      ,p_edi_attribute2                 =>  p_edi_attribute2
      ,p_edi_attribute3                 =>  p_edi_attribute3
      ,p_edi_attribute4                 =>  p_edi_attribute4
      ,p_edi_attribute5                 =>  p_edi_attribute5
      ,p_edi_attribute6                 =>  p_edi_attribute6
      ,p_edi_attribute7                 =>  p_edi_attribute7
      ,p_edi_attribute8                 =>  p_edi_attribute8
      ,p_edi_attribute9                 =>  p_edi_attribute9
      ,p_edi_attribute10                =>  p_edi_attribute10
      ,p_edi_attribute11                =>  p_edi_attribute11
      ,p_edi_attribute12                =>  p_edi_attribute12
      ,p_edi_attribute13                =>  p_edi_attribute13
      ,p_edi_attribute14                =>  p_edi_attribute14
      ,p_edi_attribute15                =>  p_edi_attribute15
      ,p_edi_attribute16                =>  p_edi_attribute16
      ,p_edi_attribute17                =>  p_edi_attribute17
      ,p_edi_attribute18                =>  p_edi_attribute18
      ,p_edi_attribute19                =>  p_edi_attribute19
      ,p_edi_attribute20                =>  p_edi_attribute20
      ,p_edi_attribute21                =>  p_edi_attribute21
      ,p_edi_attribute22                =>  p_edi_attribute22
      ,p_edi_attribute23                =>  p_edi_attribute23
      ,p_edi_attribute24                =>  p_edi_attribute24
      ,p_edi_attribute25                =>  p_edi_attribute25
      ,p_edi_attribute26                =>  p_edi_attribute26
      ,p_edi_attribute27                =>  p_edi_attribute27
      ,p_edi_attribute28                =>  p_edi_attribute28
      ,p_edi_attribute29                =>  p_edi_attribute29
      ,p_edi_attribute30                =>  p_edi_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_ELIG_DPNT_CVRD_PLIP'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_ELIG_DPNT_CVRD_PLIP
    --
  end;
  --
  ben_profile_handler.event_handler
    (p_event                       => 'CREATE',
     p_base_table                  => 'BEN_ELIGY_PRFL_F',
     p_base_table_column           => 'ELIGY_PRFL_ID',
     p_base_table_column_value     => p_eligy_prfl_id,
     p_base_table_reference_column => 'ELIG_DPNT_CVRD_PLIP_FLAG',
     p_reference_table             => 'BEN_ELIG_DPNT_CVRD_PLIP_F',
     p_reference_table_column      => 'ELIGY_PRFL_ID');
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
  p_elig_dpnt_cvrd_plip_id := l_elig_dpnt_cvrd_plip_id;
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
    ROLLBACK TO create_ELIG_DPNT_CVRD_PLIP;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_elig_dpnt_cvrd_plip_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_ELIG_DPNT_CVRD_PLIP;
    raise;
    --
end create_ELIG_DPNT_CVRD_PLIP;
-- ----------------------------------------------------------------------------
-- |------------------------< update_ELIG_DPNT_CVRD_PLIP >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_ELIG_DPNT_CVRD_PLIP
  (p_validate                       in  boolean   default false
  ,p_elig_dpnt_cvrd_plip_id         in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_excld_flag                     in  varchar2  default hr_api.g_varchar2
  ,p_ordr_num                       in  number    default hr_api.g_number
  ,p_enrl_det_dt_cd                 in  varchar2  default hr_api.g_varchar2
  ,p_plip_id                        in  number    default hr_api.g_number
  ,p_eligy_prfl_id                  in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_edi_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_edi_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_edi_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_edi_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_edi_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_edi_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_edi_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_edi_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_edi_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_edi_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_edi_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_edi_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_edi_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_edi_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_edi_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_edi_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_edi_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_edi_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_edi_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_edi_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_edi_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_edi_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_edi_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_edi_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_edi_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_edi_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_edi_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_edi_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_edi_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_edi_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_edi_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_ELIG_DPNT_CVRD_PLIP';
  l_object_version_number ben_elig_dpnt_cvrd_plip_f.object_version_number%TYPE;
  l_effective_start_date ben_elig_dpnt_cvrd_plip_f.effective_start_date%TYPE;
  l_effective_end_date ben_elig_dpnt_cvrd_plip_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_ELIG_DPNT_CVRD_PLIP;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_ELIG_DPNT_CVRD_PLIP
    --
    ben_ELIG_DPNT_CVRD_PLIP_bk2.update_ELIG_DPNT_CVRD_PLIP_b
      (
       p_elig_dpnt_cvrd_plip_id         =>  p_elig_dpnt_cvrd_plip_id
      ,p_excld_flag                     =>  p_excld_flag
      ,p_ordr_num                       =>  p_ordr_num
      ,p_enrl_det_dt_cd                 =>  p_enrl_det_dt_cd
      ,p_plip_id                        =>  p_plip_id
      ,p_eligy_prfl_id                  =>  p_eligy_prfl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_edi_attribute_category         =>  p_edi_attribute_category
      ,p_edi_attribute1                 =>  p_edi_attribute1
      ,p_edi_attribute2                 =>  p_edi_attribute2
      ,p_edi_attribute3                 =>  p_edi_attribute3
      ,p_edi_attribute4                 =>  p_edi_attribute4
      ,p_edi_attribute5                 =>  p_edi_attribute5
      ,p_edi_attribute6                 =>  p_edi_attribute6
      ,p_edi_attribute7                 =>  p_edi_attribute7
      ,p_edi_attribute8                 =>  p_edi_attribute8
      ,p_edi_attribute9                 =>  p_edi_attribute9
      ,p_edi_attribute10                =>  p_edi_attribute10
      ,p_edi_attribute11                =>  p_edi_attribute11
      ,p_edi_attribute12                =>  p_edi_attribute12
      ,p_edi_attribute13                =>  p_edi_attribute13
      ,p_edi_attribute14                =>  p_edi_attribute14
      ,p_edi_attribute15                =>  p_edi_attribute15
      ,p_edi_attribute16                =>  p_edi_attribute16
      ,p_edi_attribute17                =>  p_edi_attribute17
      ,p_edi_attribute18                =>  p_edi_attribute18
      ,p_edi_attribute19                =>  p_edi_attribute19
      ,p_edi_attribute20                =>  p_edi_attribute20
      ,p_edi_attribute21                =>  p_edi_attribute21
      ,p_edi_attribute22                =>  p_edi_attribute22
      ,p_edi_attribute23                =>  p_edi_attribute23
      ,p_edi_attribute24                =>  p_edi_attribute24
      ,p_edi_attribute25                =>  p_edi_attribute25
      ,p_edi_attribute26                =>  p_edi_attribute26
      ,p_edi_attribute27                =>  p_edi_attribute27
      ,p_edi_attribute28                =>  p_edi_attribute28
      ,p_edi_attribute29                =>  p_edi_attribute29
      ,p_edi_attribute30                =>  p_edi_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ELIG_DPNT_CVRD_PLIP'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_ELIG_DPNT_CVRD_PLIP
    --
  end;
  --
  ben_edi_upd.upd
    (
     p_elig_dpnt_cvrd_plip_id        => p_elig_dpnt_cvrd_plip_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_excld_flag                    => p_excld_flag
    ,p_ordr_num                      => p_ordr_num
    ,p_enrl_det_dt_cd                => p_enrl_det_dt_cd
    ,p_plip_id                       => p_plip_id
    ,p_eligy_prfl_id                 => p_eligy_prfl_id
    ,p_business_group_id             => p_business_group_id
    ,p_edi_attribute_category        => p_edi_attribute_category
    ,p_edi_attribute1                => p_edi_attribute1
    ,p_edi_attribute2                => p_edi_attribute2
    ,p_edi_attribute3                => p_edi_attribute3
    ,p_edi_attribute4                => p_edi_attribute4
    ,p_edi_attribute5                => p_edi_attribute5
    ,p_edi_attribute6                => p_edi_attribute6
    ,p_edi_attribute7                => p_edi_attribute7
    ,p_edi_attribute8                => p_edi_attribute8
    ,p_edi_attribute9                => p_edi_attribute9
    ,p_edi_attribute10               => p_edi_attribute10
    ,p_edi_attribute11               => p_edi_attribute11
    ,p_edi_attribute12               => p_edi_attribute12
    ,p_edi_attribute13               => p_edi_attribute13
    ,p_edi_attribute14               => p_edi_attribute14
    ,p_edi_attribute15               => p_edi_attribute15
    ,p_edi_attribute16               => p_edi_attribute16
    ,p_edi_attribute17               => p_edi_attribute17
    ,p_edi_attribute18               => p_edi_attribute18
    ,p_edi_attribute19               => p_edi_attribute19
    ,p_edi_attribute20               => p_edi_attribute20
    ,p_edi_attribute21               => p_edi_attribute21
    ,p_edi_attribute22               => p_edi_attribute22
    ,p_edi_attribute23               => p_edi_attribute23
    ,p_edi_attribute24               => p_edi_attribute24
    ,p_edi_attribute25               => p_edi_attribute25
    ,p_edi_attribute26               => p_edi_attribute26
    ,p_edi_attribute27               => p_edi_attribute27
    ,p_edi_attribute28               => p_edi_attribute28
    ,p_edi_attribute29               => p_edi_attribute29
    ,p_edi_attribute30               => p_edi_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_ELIG_DPNT_CVRD_PLIP
    --
    ben_ELIG_DPNT_CVRD_PLIP_bk2.update_ELIG_DPNT_CVRD_PLIP_a
      (
       p_elig_dpnt_cvrd_plip_id         =>  p_elig_dpnt_cvrd_plip_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_excld_flag                     =>  p_excld_flag
      ,p_ordr_num                       =>  p_ordr_num
      ,p_enrl_det_dt_cd                 =>  p_enrl_det_dt_cd
      ,p_plip_id                        =>  p_plip_id
      ,p_eligy_prfl_id                  =>  p_eligy_prfl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_edi_attribute_category         =>  p_edi_attribute_category
      ,p_edi_attribute1                 =>  p_edi_attribute1
      ,p_edi_attribute2                 =>  p_edi_attribute2
      ,p_edi_attribute3                 =>  p_edi_attribute3
      ,p_edi_attribute4                 =>  p_edi_attribute4
      ,p_edi_attribute5                 =>  p_edi_attribute5
      ,p_edi_attribute6                 =>  p_edi_attribute6
      ,p_edi_attribute7                 =>  p_edi_attribute7
      ,p_edi_attribute8                 =>  p_edi_attribute8
      ,p_edi_attribute9                 =>  p_edi_attribute9
      ,p_edi_attribute10                =>  p_edi_attribute10
      ,p_edi_attribute11                =>  p_edi_attribute11
      ,p_edi_attribute12                =>  p_edi_attribute12
      ,p_edi_attribute13                =>  p_edi_attribute13
      ,p_edi_attribute14                =>  p_edi_attribute14
      ,p_edi_attribute15                =>  p_edi_attribute15
      ,p_edi_attribute16                =>  p_edi_attribute16
      ,p_edi_attribute17                =>  p_edi_attribute17
      ,p_edi_attribute18                =>  p_edi_attribute18
      ,p_edi_attribute19                =>  p_edi_attribute19
      ,p_edi_attribute20                =>  p_edi_attribute20
      ,p_edi_attribute21                =>  p_edi_attribute21
      ,p_edi_attribute22                =>  p_edi_attribute22
      ,p_edi_attribute23                =>  p_edi_attribute23
      ,p_edi_attribute24                =>  p_edi_attribute24
      ,p_edi_attribute25                =>  p_edi_attribute25
      ,p_edi_attribute26                =>  p_edi_attribute26
      ,p_edi_attribute27                =>  p_edi_attribute27
      ,p_edi_attribute28                =>  p_edi_attribute28
      ,p_edi_attribute29                =>  p_edi_attribute29
      ,p_edi_attribute30                =>  p_edi_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ELIG_DPNT_CVRD_PLIP'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_ELIG_DPNT_CVRD_PLIP
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
    ROLLBACK TO update_ELIG_DPNT_CVRD_PLIP;
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
    ROLLBACK TO update_ELIG_DPNT_CVRD_PLIP;
    p_object_version_number := l_object_version_number;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end update_ELIG_DPNT_CVRD_PLIP;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_ELIG_DPNT_CVRD_PLIP >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ELIG_DPNT_CVRD_PLIP
  (p_validate                       in  boolean  default false
  ,p_elig_dpnt_cvrd_plip_id         in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_ELIG_DPNT_CVRD_PLIP';
  l_object_version_number ben_elig_dpnt_cvrd_plip_f.object_version_number%TYPE;
  l_effective_start_date ben_elig_dpnt_cvrd_plip_f.effective_start_date%TYPE;
  l_effective_end_date ben_elig_dpnt_cvrd_plip_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_ELIG_DPNT_CVRD_PLIP;
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
    -- Start of API User Hook for the before hook of delete_ELIG_DPNT_CVRD_PLIP
    --
    ben_ELIG_DPNT_CVRD_PLIP_bk3.delete_ELIG_DPNT_CVRD_PLIP_b
      (
       p_elig_dpnt_cvrd_plip_id         =>  p_elig_dpnt_cvrd_plip_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ELIG_DPNT_CVRD_PLIP'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_ELIG_DPNT_CVRD_PLIP
    --
  end;
  --
  ben_edi_del.del
    (
     p_elig_dpnt_cvrd_plip_id        => p_elig_dpnt_cvrd_plip_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_ELIG_DPNT_CVRD_PLIP
    --
    ben_ELIG_DPNT_CVRD_PLIP_bk3.delete_ELIG_DPNT_CVRD_PLIP_a
      (
       p_elig_dpnt_cvrd_plip_id         =>  p_elig_dpnt_cvrd_plip_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ELIG_DPNT_CVRD_PLIP'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_ELIG_DPNT_CVRD_PLIP
    --
  end;
  --
  ben_profile_handler.event_handler
    (p_event                       => 'DELETE',
     p_base_table                  => 'BEN_ELIGY_PRFL_F',
     p_base_table_column           => 'ELIGY_PRFL_ID',
     p_base_table_column_value     => ben_edi_shd.g_old_rec.eligy_prfl_id,
     p_base_table_reference_column => 'ELIG_DPNT_CVRD_PLIP_FLAG',
     p_reference_table             => 'BEN_ELIG_DPNT_CVRD_PLIP_F',
     p_reference_table_column      => 'ELIGY_PRFL_ID');
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
    ROLLBACK TO delete_ELIG_DPNT_CVRD_PLIP;
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
    ROLLBACK TO delete_ELIG_DPNT_CVRD_PLIP;
    p_object_version_number := l_object_version_number;
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end delete_ELIG_DPNT_CVRD_PLIP;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_elig_dpnt_cvrd_plip_id                   in     number
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
  ben_edi_shd.lck
    (
      p_elig_dpnt_cvrd_plip_id                 => p_elig_dpnt_cvrd_plip_id
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
end ben_ELIG_DPNT_CVRD_PLIP_api;

/
