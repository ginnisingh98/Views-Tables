--------------------------------------------------------
--  DDL for Package Body BEN_ELIG_AGE_CVG_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ELIG_AGE_CVG_API" as
/* $Header: beeacapi.pkb 115.5 2002/12/11 10:40:08 lakrish ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_ELIG_AGE_CVG_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_ELIG_AGE_CVG >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ELIG_AGE_CVG
  (p_validate                       in  boolean   default false
  ,p_elig_age_cvg_id                out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default null
  ,p_dpnt_cvg_eligy_prfl_id         in  number    default null
  ,p_age_fctr_id                    in  number    default null
  ,p_cvg_strt_cd                    in  varchar2  default null
  ,p_cvg_strt_rl                    in  number    default null
  ,p_cvg_thru_cd                    in  varchar2  default null
  ,p_cvg_thru_rl                    in  number    default null
  ,p_excld_flag                     in  varchar2  default null
  ,p_eac_attribute_category         in  varchar2  default null
  ,p_eac_attribute1                 in  varchar2  default null
  ,p_eac_attribute2                 in  varchar2  default null
  ,p_eac_attribute3                 in  varchar2  default null
  ,p_eac_attribute4                 in  varchar2  default null
  ,p_eac_attribute5                 in  varchar2  default null
  ,p_eac_attribute6                 in  varchar2  default null
  ,p_eac_attribute7                 in  varchar2  default null
  ,p_eac_attribute8                 in  varchar2  default null
  ,p_eac_attribute9                 in  varchar2  default null
  ,p_eac_attribute10                in  varchar2  default null
  ,p_eac_attribute11                in  varchar2  default null
  ,p_eac_attribute12                in  varchar2  default null
  ,p_eac_attribute13                in  varchar2  default null
  ,p_eac_attribute14                in  varchar2  default null
  ,p_eac_attribute15                in  varchar2  default null
  ,p_eac_attribute16                in  varchar2  default null
  ,p_eac_attribute17                in  varchar2  default null
  ,p_eac_attribute18                in  varchar2  default null
  ,p_eac_attribute19                in  varchar2  default null
  ,p_eac_attribute20                in  varchar2  default null
  ,p_eac_attribute21                in  varchar2  default null
  ,p_eac_attribute22                in  varchar2  default null
  ,p_eac_attribute23                in  varchar2  default null
  ,p_eac_attribute24                in  varchar2  default null
  ,p_eac_attribute25                in  varchar2  default null
  ,p_eac_attribute26                in  varchar2  default null
  ,p_eac_attribute27                in  varchar2  default null
  ,p_eac_attribute28                in  varchar2  default null
  ,p_eac_attribute29                in  varchar2  default null
  ,p_eac_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_elig_age_cvg_id ben_elig_age_cvg_f.elig_age_cvg_id%TYPE;
  l_effective_start_date ben_elig_age_cvg_f.effective_start_date%TYPE;
  l_effective_end_date ben_elig_age_cvg_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_ELIG_AGE_CVG';
  l_object_version_number ben_elig_age_cvg_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_ELIG_AGE_CVG;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_ELIG_AGE_CVG
    --
    ben_ELIG_AGE_CVG_bk1.create_ELIG_AGE_CVG_b
      (
       p_business_group_id              =>  p_business_group_id
      ,p_dpnt_cvg_eligy_prfl_id         =>  p_dpnt_cvg_eligy_prfl_id
      ,p_age_fctr_id                    =>  p_age_fctr_id
      ,p_cvg_strt_cd                    =>  p_cvg_strt_cd
      ,p_cvg_strt_rl                    =>  p_cvg_strt_rl
      ,p_cvg_thru_cd                    =>  p_cvg_thru_cd
      ,p_cvg_thru_rl                    =>  p_cvg_thru_rl
      ,p_excld_flag                     =>  p_excld_flag
      ,p_eac_attribute_category         =>  p_eac_attribute_category
      ,p_eac_attribute1                 =>  p_eac_attribute1
      ,p_eac_attribute2                 =>  p_eac_attribute2
      ,p_eac_attribute3                 =>  p_eac_attribute3
      ,p_eac_attribute4                 =>  p_eac_attribute4
      ,p_eac_attribute5                 =>  p_eac_attribute5
      ,p_eac_attribute6                 =>  p_eac_attribute6
      ,p_eac_attribute7                 =>  p_eac_attribute7
      ,p_eac_attribute8                 =>  p_eac_attribute8
      ,p_eac_attribute9                 =>  p_eac_attribute9
      ,p_eac_attribute10                =>  p_eac_attribute10
      ,p_eac_attribute11                =>  p_eac_attribute11
      ,p_eac_attribute12                =>  p_eac_attribute12
      ,p_eac_attribute13                =>  p_eac_attribute13
      ,p_eac_attribute14                =>  p_eac_attribute14
      ,p_eac_attribute15                =>  p_eac_attribute15
      ,p_eac_attribute16                =>  p_eac_attribute16
      ,p_eac_attribute17                =>  p_eac_attribute17
      ,p_eac_attribute18                =>  p_eac_attribute18
      ,p_eac_attribute19                =>  p_eac_attribute19
      ,p_eac_attribute20                =>  p_eac_attribute20
      ,p_eac_attribute21                =>  p_eac_attribute21
      ,p_eac_attribute22                =>  p_eac_attribute22
      ,p_eac_attribute23                =>  p_eac_attribute23
      ,p_eac_attribute24                =>  p_eac_attribute24
      ,p_eac_attribute25                =>  p_eac_attribute25
      ,p_eac_attribute26                =>  p_eac_attribute26
      ,p_eac_attribute27                =>  p_eac_attribute27
      ,p_eac_attribute28                =>  p_eac_attribute28
      ,p_eac_attribute29                =>  p_eac_attribute29
      ,p_eac_attribute30                =>  p_eac_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_ELIG_AGE_CVG'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_ELIG_AGE_CVG
    --
  end;
  --
  ben_eac_ins.ins
    (
     p_elig_age_cvg_id               => l_elig_age_cvg_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_business_group_id             => p_business_group_id
    ,p_dpnt_cvg_eligy_prfl_id        => p_dpnt_cvg_eligy_prfl_id
    ,p_age_fctr_id                   => p_age_fctr_id
    ,p_cvg_strt_cd                   => p_cvg_strt_cd
    ,p_cvg_strt_rl                   => p_cvg_strt_rl
    ,p_cvg_thru_cd                   => p_cvg_thru_cd
    ,p_cvg_thru_rl                   => p_cvg_thru_rl
    ,p_excld_flag                    => p_excld_flag
    ,p_eac_attribute_category        => p_eac_attribute_category
    ,p_eac_attribute1                => p_eac_attribute1
    ,p_eac_attribute2                => p_eac_attribute2
    ,p_eac_attribute3                => p_eac_attribute3
    ,p_eac_attribute4                => p_eac_attribute4
    ,p_eac_attribute5                => p_eac_attribute5
    ,p_eac_attribute6                => p_eac_attribute6
    ,p_eac_attribute7                => p_eac_attribute7
    ,p_eac_attribute8                => p_eac_attribute8
    ,p_eac_attribute9                => p_eac_attribute9
    ,p_eac_attribute10               => p_eac_attribute10
    ,p_eac_attribute11               => p_eac_attribute11
    ,p_eac_attribute12               => p_eac_attribute12
    ,p_eac_attribute13               => p_eac_attribute13
    ,p_eac_attribute14               => p_eac_attribute14
    ,p_eac_attribute15               => p_eac_attribute15
    ,p_eac_attribute16               => p_eac_attribute16
    ,p_eac_attribute17               => p_eac_attribute17
    ,p_eac_attribute18               => p_eac_attribute18
    ,p_eac_attribute19               => p_eac_attribute19
    ,p_eac_attribute20               => p_eac_attribute20
    ,p_eac_attribute21               => p_eac_attribute21
    ,p_eac_attribute22               => p_eac_attribute22
    ,p_eac_attribute23               => p_eac_attribute23
    ,p_eac_attribute24               => p_eac_attribute24
    ,p_eac_attribute25               => p_eac_attribute25
    ,p_eac_attribute26               => p_eac_attribute26
    ,p_eac_attribute27               => p_eac_attribute27
    ,p_eac_attribute28               => p_eac_attribute28
    ,p_eac_attribute29               => p_eac_attribute29
    ,p_eac_attribute30               => p_eac_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_ELIG_AGE_CVG
    --
    ben_ELIG_AGE_CVG_bk1.create_ELIG_AGE_CVG_a
      (
       p_elig_age_cvg_id                =>  l_elig_age_cvg_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_business_group_id              =>  p_business_group_id
      ,p_dpnt_cvg_eligy_prfl_id         =>  p_dpnt_cvg_eligy_prfl_id
      ,p_age_fctr_id                    =>  p_age_fctr_id
      ,p_cvg_strt_cd                    =>  p_cvg_strt_cd
      ,p_cvg_strt_rl                    =>  p_cvg_strt_rl
      ,p_cvg_thru_cd                    =>  p_cvg_thru_cd
      ,p_cvg_thru_rl                    =>  p_cvg_thru_rl
      ,p_excld_flag                     =>  p_excld_flag
      ,p_eac_attribute_category         =>  p_eac_attribute_category
      ,p_eac_attribute1                 =>  p_eac_attribute1
      ,p_eac_attribute2                 =>  p_eac_attribute2
      ,p_eac_attribute3                 =>  p_eac_attribute3
      ,p_eac_attribute4                 =>  p_eac_attribute4
      ,p_eac_attribute5                 =>  p_eac_attribute5
      ,p_eac_attribute6                 =>  p_eac_attribute6
      ,p_eac_attribute7                 =>  p_eac_attribute7
      ,p_eac_attribute8                 =>  p_eac_attribute8
      ,p_eac_attribute9                 =>  p_eac_attribute9
      ,p_eac_attribute10                =>  p_eac_attribute10
      ,p_eac_attribute11                =>  p_eac_attribute11
      ,p_eac_attribute12                =>  p_eac_attribute12
      ,p_eac_attribute13                =>  p_eac_attribute13
      ,p_eac_attribute14                =>  p_eac_attribute14
      ,p_eac_attribute15                =>  p_eac_attribute15
      ,p_eac_attribute16                =>  p_eac_attribute16
      ,p_eac_attribute17                =>  p_eac_attribute17
      ,p_eac_attribute18                =>  p_eac_attribute18
      ,p_eac_attribute19                =>  p_eac_attribute19
      ,p_eac_attribute20                =>  p_eac_attribute20
      ,p_eac_attribute21                =>  p_eac_attribute21
      ,p_eac_attribute22                =>  p_eac_attribute22
      ,p_eac_attribute23                =>  p_eac_attribute23
      ,p_eac_attribute24                =>  p_eac_attribute24
      ,p_eac_attribute25                =>  p_eac_attribute25
      ,p_eac_attribute26                =>  p_eac_attribute26
      ,p_eac_attribute27                =>  p_eac_attribute27
      ,p_eac_attribute28                =>  p_eac_attribute28
      ,p_eac_attribute29                =>  p_eac_attribute29
      ,p_eac_attribute30                =>  p_eac_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_ELIG_AGE_CVG'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_ELIG_AGE_CVG
    --
  end;
  --
  ben_profile_handler.event_handler
         (p_event                       => 'CREATE',
          p_base_table                  => 'BEN_DPNT_CVG_ELIGY_PRFL_F',
          p_base_table_column           => 'DPNT_CVG_ELIGY_PRFL_ID',
          p_base_table_column_value     =>  p_dpnt_cvg_eligy_prfl_id,
          p_base_table_reference_column => 'DPNT_AGE_FLAG',
          p_reference_table             => 'BEN_ELIG_AGE_CVG_F',
          p_reference_table_column      => 'DPNT_CVG_ELIGY_PRFL_ID');
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
  p_elig_age_cvg_id := l_elig_age_cvg_id;
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
    ROLLBACK TO create_ELIG_AGE_CVG;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_elig_age_cvg_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_ELIG_AGE_CVG;
    raise;
    --
end create_ELIG_AGE_CVG;
-- ----------------------------------------------------------------------------
-- |------------------------< update_ELIG_AGE_CVG >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_ELIG_AGE_CVG
  (p_validate                       in  boolean   default false
  ,p_elig_age_cvg_id                in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_dpnt_cvg_eligy_prfl_id         in  number    default hr_api.g_number
  ,p_age_fctr_id                    in  number    default hr_api.g_number
  ,p_cvg_strt_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_cvg_strt_rl                    in  number    default hr_api.g_number
  ,p_cvg_thru_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_cvg_thru_rl                    in  number    default hr_api.g_number
  ,p_excld_flag                     in  varchar2  default hr_api.g_varchar2
  ,p_eac_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_eac_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_eac_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_eac_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_eac_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_eac_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_eac_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_eac_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_eac_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_eac_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_eac_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_eac_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_eac_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_eac_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_eac_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_eac_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_eac_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_eac_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_eac_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_eac_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_eac_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_eac_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_eac_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_eac_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_eac_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_eac_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_eac_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_eac_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_eac_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_eac_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_eac_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_ELIG_AGE_CVG';
  l_object_version_number ben_elig_age_cvg_f.object_version_number%TYPE;
  l_effective_start_date ben_elig_age_cvg_f.effective_start_date%TYPE;
  l_effective_end_date ben_elig_age_cvg_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_ELIG_AGE_CVG;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_ELIG_AGE_CVG
    --
    ben_ELIG_AGE_CVG_bk2.update_ELIG_AGE_CVG_b
      (
       p_elig_age_cvg_id                =>  p_elig_age_cvg_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_dpnt_cvg_eligy_prfl_id         =>  p_dpnt_cvg_eligy_prfl_id
      ,p_age_fctr_id                    =>  p_age_fctr_id
      ,p_cvg_strt_cd                    =>  p_cvg_strt_cd
      ,p_cvg_strt_rl                    =>  p_cvg_strt_rl
      ,p_cvg_thru_cd                    =>  p_cvg_thru_cd
      ,p_cvg_thru_rl                    =>  p_cvg_thru_rl
      ,p_excld_flag                     =>  p_excld_flag
      ,p_eac_attribute_category         =>  p_eac_attribute_category
      ,p_eac_attribute1                 =>  p_eac_attribute1
      ,p_eac_attribute2                 =>  p_eac_attribute2
      ,p_eac_attribute3                 =>  p_eac_attribute3
      ,p_eac_attribute4                 =>  p_eac_attribute4
      ,p_eac_attribute5                 =>  p_eac_attribute5
      ,p_eac_attribute6                 =>  p_eac_attribute6
      ,p_eac_attribute7                 =>  p_eac_attribute7
      ,p_eac_attribute8                 =>  p_eac_attribute8
      ,p_eac_attribute9                 =>  p_eac_attribute9
      ,p_eac_attribute10                =>  p_eac_attribute10
      ,p_eac_attribute11                =>  p_eac_attribute11
      ,p_eac_attribute12                =>  p_eac_attribute12
      ,p_eac_attribute13                =>  p_eac_attribute13
      ,p_eac_attribute14                =>  p_eac_attribute14
      ,p_eac_attribute15                =>  p_eac_attribute15
      ,p_eac_attribute16                =>  p_eac_attribute16
      ,p_eac_attribute17                =>  p_eac_attribute17
      ,p_eac_attribute18                =>  p_eac_attribute18
      ,p_eac_attribute19                =>  p_eac_attribute19
      ,p_eac_attribute20                =>  p_eac_attribute20
      ,p_eac_attribute21                =>  p_eac_attribute21
      ,p_eac_attribute22                =>  p_eac_attribute22
      ,p_eac_attribute23                =>  p_eac_attribute23
      ,p_eac_attribute24                =>  p_eac_attribute24
      ,p_eac_attribute25                =>  p_eac_attribute25
      ,p_eac_attribute26                =>  p_eac_attribute26
      ,p_eac_attribute27                =>  p_eac_attribute27
      ,p_eac_attribute28                =>  p_eac_attribute28
      ,p_eac_attribute29                =>  p_eac_attribute29
      ,p_eac_attribute30                =>  p_eac_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ELIG_AGE_CVG'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_ELIG_AGE_CVG
    --
  end;
  --
  ben_eac_upd.upd
    (
     p_elig_age_cvg_id               => p_elig_age_cvg_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_business_group_id             => p_business_group_id
    ,p_dpnt_cvg_eligy_prfl_id        => p_dpnt_cvg_eligy_prfl_id
    ,p_age_fctr_id                   => p_age_fctr_id
    ,p_cvg_strt_cd                   => p_cvg_strt_cd
    ,p_cvg_strt_rl                   => p_cvg_strt_rl
    ,p_cvg_thru_cd                   => p_cvg_thru_cd
    ,p_cvg_thru_rl                   => p_cvg_thru_rl
    ,p_excld_flag                    => p_excld_flag
    ,p_eac_attribute_category        => p_eac_attribute_category
    ,p_eac_attribute1                => p_eac_attribute1
    ,p_eac_attribute2                => p_eac_attribute2
    ,p_eac_attribute3                => p_eac_attribute3
    ,p_eac_attribute4                => p_eac_attribute4
    ,p_eac_attribute5                => p_eac_attribute5
    ,p_eac_attribute6                => p_eac_attribute6
    ,p_eac_attribute7                => p_eac_attribute7
    ,p_eac_attribute8                => p_eac_attribute8
    ,p_eac_attribute9                => p_eac_attribute9
    ,p_eac_attribute10               => p_eac_attribute10
    ,p_eac_attribute11               => p_eac_attribute11
    ,p_eac_attribute12               => p_eac_attribute12
    ,p_eac_attribute13               => p_eac_attribute13
    ,p_eac_attribute14               => p_eac_attribute14
    ,p_eac_attribute15               => p_eac_attribute15
    ,p_eac_attribute16               => p_eac_attribute16
    ,p_eac_attribute17               => p_eac_attribute17
    ,p_eac_attribute18               => p_eac_attribute18
    ,p_eac_attribute19               => p_eac_attribute19
    ,p_eac_attribute20               => p_eac_attribute20
    ,p_eac_attribute21               => p_eac_attribute21
    ,p_eac_attribute22               => p_eac_attribute22
    ,p_eac_attribute23               => p_eac_attribute23
    ,p_eac_attribute24               => p_eac_attribute24
    ,p_eac_attribute25               => p_eac_attribute25
    ,p_eac_attribute26               => p_eac_attribute26
    ,p_eac_attribute27               => p_eac_attribute27
    ,p_eac_attribute28               => p_eac_attribute28
    ,p_eac_attribute29               => p_eac_attribute29
    ,p_eac_attribute30               => p_eac_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_ELIG_AGE_CVG
    --
    ben_ELIG_AGE_CVG_bk2.update_ELIG_AGE_CVG_a
      (
       p_elig_age_cvg_id                =>  p_elig_age_cvg_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_business_group_id              =>  p_business_group_id
      ,p_dpnt_cvg_eligy_prfl_id         =>  p_dpnt_cvg_eligy_prfl_id
      ,p_age_fctr_id                    =>  p_age_fctr_id
      ,p_cvg_strt_cd                    =>  p_cvg_strt_cd
      ,p_cvg_strt_rl                    =>  p_cvg_strt_rl
      ,p_cvg_thru_cd                    =>  p_cvg_thru_cd
      ,p_cvg_thru_rl                    =>  p_cvg_thru_rl
      ,p_excld_flag                     =>  p_excld_flag
      ,p_eac_attribute_category         =>  p_eac_attribute_category
      ,p_eac_attribute1                 =>  p_eac_attribute1
      ,p_eac_attribute2                 =>  p_eac_attribute2
      ,p_eac_attribute3                 =>  p_eac_attribute3
      ,p_eac_attribute4                 =>  p_eac_attribute4
      ,p_eac_attribute5                 =>  p_eac_attribute5
      ,p_eac_attribute6                 =>  p_eac_attribute6
      ,p_eac_attribute7                 =>  p_eac_attribute7
      ,p_eac_attribute8                 =>  p_eac_attribute8
      ,p_eac_attribute9                 =>  p_eac_attribute9
      ,p_eac_attribute10                =>  p_eac_attribute10
      ,p_eac_attribute11                =>  p_eac_attribute11
      ,p_eac_attribute12                =>  p_eac_attribute12
      ,p_eac_attribute13                =>  p_eac_attribute13
      ,p_eac_attribute14                =>  p_eac_attribute14
      ,p_eac_attribute15                =>  p_eac_attribute15
      ,p_eac_attribute16                =>  p_eac_attribute16
      ,p_eac_attribute17                =>  p_eac_attribute17
      ,p_eac_attribute18                =>  p_eac_attribute18
      ,p_eac_attribute19                =>  p_eac_attribute19
      ,p_eac_attribute20                =>  p_eac_attribute20
      ,p_eac_attribute21                =>  p_eac_attribute21
      ,p_eac_attribute22                =>  p_eac_attribute22
      ,p_eac_attribute23                =>  p_eac_attribute23
      ,p_eac_attribute24                =>  p_eac_attribute24
      ,p_eac_attribute25                =>  p_eac_attribute25
      ,p_eac_attribute26                =>  p_eac_attribute26
      ,p_eac_attribute27                =>  p_eac_attribute27
      ,p_eac_attribute28                =>  p_eac_attribute28
      ,p_eac_attribute29                =>  p_eac_attribute29
      ,p_eac_attribute30                =>  p_eac_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_ELIG_AGE_CVG'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_ELIG_AGE_CVG
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
    ROLLBACK TO update_ELIG_AGE_CVG;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_effective_start_date := null;
    p_effective_end_date   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO update_ELIG_AGE_CVG;

    -- NOCOPY, Reset out parameters
    p_effective_start_date := null;
    p_effective_end_date   := null;

    raise;
    --
end update_ELIG_AGE_CVG;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_ELIG_AGE_CVG >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ELIG_AGE_CVG
  (p_validate                       in  boolean  default false
  ,p_elig_age_cvg_id                in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_ELIG_AGE_CVG';
  l_object_version_number ben_elig_age_cvg_f.object_version_number%TYPE;
  l_effective_start_date ben_elig_age_cvg_f.effective_start_date%TYPE;
  l_effective_end_date ben_elig_age_cvg_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_ELIG_AGE_CVG;
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
    -- Start of API User Hook for the before hook of delete_ELIG_AGE_CVG
    --
    ben_ELIG_AGE_CVG_bk3.delete_ELIG_AGE_CVG_b
      (
       p_elig_age_cvg_id                =>  p_elig_age_cvg_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ELIG_AGE_CVG'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_ELIG_AGE_CVG
    --
  end;
  --
  ben_eac_del.del
    (
     p_elig_age_cvg_id               => p_elig_age_cvg_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_ELIG_AGE_CVG
    --
    ben_ELIG_AGE_CVG_bk3.delete_ELIG_AGE_CVG_a
      (
       p_elig_age_cvg_id                =>  p_elig_age_cvg_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_ELIG_AGE_CVG'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_ELIG_AGE_CVG
    --
  end;
  --
  ben_profile_handler.event_handler
         (p_event                       => 'DELETE',
          p_base_table                  => 'BEN_DPNT_CVG_ELIGY_PRFL_F',
          p_base_table_column           => 'DPNT_CVG_ELIGY_PRFL_ID',
          p_base_table_column_value     =>  ben_eac_shd.g_old_rec.dpnt_cvg_eligy_prfl_id,
          p_base_table_reference_column => 'DPNT_AGE_FLAG',
          p_reference_table             => 'BEN_ELIG_AGE_CVG_F',
          p_reference_table_column      => 'DPNT_CVG_ELIGY_PRFL_ID');
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
    ROLLBACK TO delete_ELIG_AGE_CVG;
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
    ROLLBACK TO delete_ELIG_AGE_CVG;

    -- NOCOPY, Reset out parameters
    p_effective_start_date := null;
    p_effective_end_date   := null;

    raise;
    --
end delete_ELIG_AGE_CVG;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_elig_age_cvg_id                   in     number
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
  ben_eac_shd.lck
    (
      p_elig_age_cvg_id                 => p_elig_age_cvg_id
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
end ben_ELIG_AGE_CVG_api;

/
