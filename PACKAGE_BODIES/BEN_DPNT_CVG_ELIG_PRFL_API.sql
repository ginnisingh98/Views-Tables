--------------------------------------------------------
--  DDL for Package Body BEN_DPNT_CVG_ELIG_PRFL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_DPNT_CVG_ELIG_PRFL_API" as
/* $Header: bedceapi.pkb 120.0.12010000.2 2010/04/07 06:46:05 pvelvano ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_DPNT_CVG_ELIG_PRFL_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_DPNT_CVG_ELIG_PRFL >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_DPNT_CVG_ELIG_PRFL
  (p_validate                       in  boolean   default false
  ,p_dpnt_cvg_eligy_prfl_id         out nocopy number
  ,p_effective_end_date             out nocopy date
  ,p_effective_start_date           out nocopy date
  ,p_business_group_id              in  number    default null
  ,p_regn_id                        in  number    default null
  ,p_name                           in  varchar2  default null
  ,p_dpnt_cvg_eligy_prfl_stat_cd    in  varchar2  default null
  ,p_dce_desc                       in  varchar2  default null
  ,p_dpnt_cvg_elig_det_rl           in  number    default null
  ,p_dce_attribute_category         in  varchar2  default null
  ,p_dce_attribute1                 in  varchar2  default null
  ,p_dce_attribute2                 in  varchar2  default null
  ,p_dce_attribute3                 in  varchar2  default null
  ,p_dce_attribute4                 in  varchar2  default null
  ,p_dce_attribute5                 in  varchar2  default null
  ,p_dce_attribute6                 in  varchar2  default null
  ,p_dce_attribute7                 in  varchar2  default null
  ,p_dce_attribute8                 in  varchar2  default null
  ,p_dce_attribute9                 in  varchar2  default null
  ,p_dce_attribute10                in  varchar2  default null
  ,p_dce_attribute11                in  varchar2  default null
  ,p_dce_attribute12                in  varchar2  default null
  ,p_dce_attribute13                in  varchar2  default null
  ,p_dce_attribute14                in  varchar2  default null
  ,p_dce_attribute15                in  varchar2  default null
  ,p_dce_attribute16                in  varchar2  default null
  ,p_dce_attribute17                in  varchar2  default null
  ,p_dce_attribute18                in  varchar2  default null
  ,p_dce_attribute19                in  varchar2  default null
  ,p_dce_attribute20                in  varchar2  default null
  ,p_dce_attribute21                in  varchar2  default null
  ,p_dce_attribute22                in  varchar2  default null
  ,p_dce_attribute23                in  varchar2  default null
  ,p_dce_attribute24                in  varchar2  default null
  ,p_dce_attribute25                in  varchar2  default null
  ,p_dce_attribute26                in  varchar2  default null
  ,p_dce_attribute27                in  varchar2  default null
  ,p_dce_attribute28                in  varchar2  default null
  ,p_dce_attribute29                in  varchar2  default null
  ,p_dce_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_dpnt_rlshp_flag                in  varchar2  default 'N'
  ,p_dpnt_age_flag                  in  varchar2  default 'N'
  ,p_dpnt_stud_flag                 in  varchar2  default 'N'
  ,p_dpnt_dsbld_flag                in  varchar2  default 'N'
  ,p_dpnt_mrtl_flag                 in  varchar2  default 'N'
  ,p_dpnt_mltry_flag                in  varchar2  default 'N'
  ,p_dpnt_pstl_flag                 in  varchar2  default 'N'
  ,p_dpnt_cvrd_in_anthr_pl_flag     in  varchar2  default 'N'
  ,p_dpnt_dsgnt_crntly_enrld_flag   in  varchar2  default 'N'
  ,p_dpnt_crit_flag                 in  varchar2  default 'N'
  ) is
  --
  -- Declare cursors and local variables
  --
  l_dpnt_cvg_eligy_prfl_id ben_dpnt_cvg_eligy_prfl_f.dpnt_cvg_eligy_prfl_id%TYPE;
  l_effective_end_date ben_dpnt_cvg_eligy_prfl_f.effective_end_date%TYPE;
  l_effective_start_date ben_dpnt_cvg_eligy_prfl_f.effective_start_date%TYPE;
  l_proc varchar2(72) := g_package||'create_DPNT_CVG_ELIG_PRFL';
  l_object_version_number ben_dpnt_cvg_eligy_prfl_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_DPNT_CVG_ELIG_PRFL;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_DPNT_CVG_ELIG_PRFL
    --
    ben_DPNT_CVG_ELIG_PRFL_bk1.create_DPNT_CVG_ELIG_PRFL_b
      (
       p_business_group_id              =>  p_business_group_id
      ,p_regn_id                        =>  p_regn_id
      ,p_name                           =>  p_name
      ,p_dpnt_cvg_eligy_prfl_stat_cd    =>  p_dpnt_cvg_eligy_prfl_stat_cd
      ,p_dce_desc                       =>  p_dce_desc
      ,p_dpnt_cvg_elig_det_rl           =>  p_dpnt_cvg_elig_det_rl
      ,p_dce_attribute_category         =>  p_dce_attribute_category
      ,p_dce_attribute1                 =>  p_dce_attribute1
      ,p_dce_attribute2                 =>  p_dce_attribute2
      ,p_dce_attribute3                 =>  p_dce_attribute3
      ,p_dce_attribute4                 =>  p_dce_attribute4
      ,p_dce_attribute5                 =>  p_dce_attribute5
      ,p_dce_attribute6                 =>  p_dce_attribute6
      ,p_dce_attribute7                 =>  p_dce_attribute7
      ,p_dce_attribute8                 =>  p_dce_attribute8
      ,p_dce_attribute9                 =>  p_dce_attribute9
      ,p_dce_attribute10                =>  p_dce_attribute10
      ,p_dce_attribute11                =>  p_dce_attribute11
      ,p_dce_attribute12                =>  p_dce_attribute12
      ,p_dce_attribute13                =>  p_dce_attribute13
      ,p_dce_attribute14                =>  p_dce_attribute14
      ,p_dce_attribute15                =>  p_dce_attribute15
      ,p_dce_attribute16                =>  p_dce_attribute16
      ,p_dce_attribute17                =>  p_dce_attribute17
      ,p_dce_attribute18                =>  p_dce_attribute18
      ,p_dce_attribute19                =>  p_dce_attribute19
      ,p_dce_attribute20                =>  p_dce_attribute20
      ,p_dce_attribute21                =>  p_dce_attribute21
      ,p_dce_attribute22                =>  p_dce_attribute22
      ,p_dce_attribute23                =>  p_dce_attribute23
      ,p_dce_attribute24                =>  p_dce_attribute24
      ,p_dce_attribute25                =>  p_dce_attribute25
      ,p_dce_attribute26                =>  p_dce_attribute26
      ,p_dce_attribute27                =>  p_dce_attribute27
      ,p_dce_attribute28                =>  p_dce_attribute28
      ,p_dce_attribute29                =>  p_dce_attribute29
      ,p_dce_attribute30                =>  p_dce_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      ,p_dpnt_rlshp_flag                => p_dpnt_rlshp_flag
      ,p_dpnt_age_flag                  => p_dpnt_age_flag
      ,p_dpnt_stud_flag                 => p_dpnt_stud_flag
      ,p_dpnt_dsbld_flag                => p_dpnt_dsbld_flag
      ,p_dpnt_mrtl_flag                 => p_dpnt_mrtl_flag
      ,p_dpnt_mltry_flag                => p_dpnt_mltry_flag
      ,p_dpnt_pstl_flag                 => p_dpnt_pstl_flag
      ,p_dpnt_cvrd_in_anthr_pl_flag     => p_dpnt_cvrd_in_anthr_pl_flag
      ,p_dpnt_dsgnt_crntly_enrld_flag   => p_dpnt_dsgnt_crntly_enrld_flag
      ,p_dpnt_crit_flag                 => p_dpnt_crit_flag
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_DPNT_CVG_ELIG_PRFL'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_DPNT_CVG_ELIG_PRFL
    --
  end;
  --
  ben_dce_ins.ins
    (
     p_dpnt_cvg_eligy_prfl_id        => l_dpnt_cvg_eligy_prfl_id
    ,p_effective_end_date            => l_effective_end_date
    ,p_effective_start_date          => l_effective_start_date
    ,p_business_group_id             => p_business_group_id
    ,p_regn_id                       => p_regn_id
    ,p_name                          => p_name
    ,p_dpnt_cvg_eligy_prfl_stat_cd   => p_dpnt_cvg_eligy_prfl_stat_cd
    ,p_dce_desc                      => p_dce_desc
    ,p_dpnt_cvg_elig_det_rl          => p_dpnt_cvg_elig_det_rl
    ,p_dce_attribute_category        => p_dce_attribute_category
    ,p_dce_attribute1                => p_dce_attribute1
    ,p_dce_attribute2                => p_dce_attribute2
    ,p_dce_attribute3                => p_dce_attribute3
    ,p_dce_attribute4                => p_dce_attribute4
    ,p_dce_attribute5                => p_dce_attribute5
    ,p_dce_attribute6                => p_dce_attribute6
    ,p_dce_attribute7                => p_dce_attribute7
    ,p_dce_attribute8                => p_dce_attribute8
    ,p_dce_attribute9                => p_dce_attribute9
    ,p_dce_attribute10               => p_dce_attribute10
    ,p_dce_attribute11               => p_dce_attribute11
    ,p_dce_attribute12               => p_dce_attribute12
    ,p_dce_attribute13               => p_dce_attribute13
    ,p_dce_attribute14               => p_dce_attribute14
    ,p_dce_attribute15               => p_dce_attribute15
    ,p_dce_attribute16               => p_dce_attribute16
    ,p_dce_attribute17               => p_dce_attribute17
    ,p_dce_attribute18               => p_dce_attribute18
    ,p_dce_attribute19               => p_dce_attribute19
    ,p_dce_attribute20               => p_dce_attribute20
    ,p_dce_attribute21               => p_dce_attribute21
    ,p_dce_attribute22               => p_dce_attribute22
    ,p_dce_attribute23               => p_dce_attribute23
    ,p_dce_attribute24               => p_dce_attribute24
    ,p_dce_attribute25               => p_dce_attribute25
    ,p_dce_attribute26               => p_dce_attribute26
    ,p_dce_attribute27               => p_dce_attribute27
    ,p_dce_attribute28               => p_dce_attribute28
    ,p_dce_attribute29               => p_dce_attribute29
    ,p_dce_attribute30               => p_dce_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_dpnt_rlshp_flag                => p_dpnt_rlshp_flag
    ,p_dpnt_age_flag                  => p_dpnt_age_flag
    ,p_dpnt_stud_flag                 => p_dpnt_stud_flag
    ,p_dpnt_dsbld_flag                => p_dpnt_dsbld_flag
    ,p_dpnt_mrtl_flag                 => p_dpnt_mrtl_flag
    ,p_dpnt_mltry_flag                => p_dpnt_mltry_flag
    ,p_dpnt_pstl_flag                 => p_dpnt_pstl_flag
    ,p_dpnt_cvrd_in_anthr_pl_flag     => p_dpnt_cvrd_in_anthr_pl_flag
    ,p_dpnt_dsgnt_crntly_enrld_flag   => p_dpnt_dsgnt_crntly_enrld_flag
    ,p_dpnt_crit_flag                 => p_dpnt_crit_flag
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_DPNT_CVG_ELIG_PRFL
    --
    ben_DPNT_CVG_ELIG_PRFL_bk1.create_DPNT_CVG_ELIG_PRFL_a
      (
       p_dpnt_cvg_eligy_prfl_id         =>  l_dpnt_cvg_eligy_prfl_id
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_business_group_id              =>  p_business_group_id
      ,p_regn_id                        =>  p_regn_id
      ,p_name                           =>  p_name
      ,p_dpnt_cvg_eligy_prfl_stat_cd    =>  p_dpnt_cvg_eligy_prfl_stat_cd
      ,p_dce_desc                       =>  p_dce_desc
      ,p_dpnt_cvg_elig_det_rl           =>  p_dpnt_cvg_elig_det_rl
      ,p_dce_attribute_category         =>  p_dce_attribute_category
      ,p_dce_attribute1                 =>  p_dce_attribute1
      ,p_dce_attribute2                 =>  p_dce_attribute2
      ,p_dce_attribute3                 =>  p_dce_attribute3
      ,p_dce_attribute4                 =>  p_dce_attribute4
      ,p_dce_attribute5                 =>  p_dce_attribute5
      ,p_dce_attribute6                 =>  p_dce_attribute6
      ,p_dce_attribute7                 =>  p_dce_attribute7
      ,p_dce_attribute8                 =>  p_dce_attribute8
      ,p_dce_attribute9                 =>  p_dce_attribute9
      ,p_dce_attribute10                =>  p_dce_attribute10
      ,p_dce_attribute11                =>  p_dce_attribute11
      ,p_dce_attribute12                =>  p_dce_attribute12
      ,p_dce_attribute13                =>  p_dce_attribute13
      ,p_dce_attribute14                =>  p_dce_attribute14
      ,p_dce_attribute15                =>  p_dce_attribute15
      ,p_dce_attribute16                =>  p_dce_attribute16
      ,p_dce_attribute17                =>  p_dce_attribute17
      ,p_dce_attribute18                =>  p_dce_attribute18
      ,p_dce_attribute19                =>  p_dce_attribute19
      ,p_dce_attribute20                =>  p_dce_attribute20
      ,p_dce_attribute21                =>  p_dce_attribute21
      ,p_dce_attribute22                =>  p_dce_attribute22
      ,p_dce_attribute23                =>  p_dce_attribute23
      ,p_dce_attribute24                =>  p_dce_attribute24
      ,p_dce_attribute25                =>  p_dce_attribute25
      ,p_dce_attribute26                =>  p_dce_attribute26
      ,p_dce_attribute27                =>  p_dce_attribute27
      ,p_dce_attribute28                =>  p_dce_attribute28
      ,p_dce_attribute29                =>  p_dce_attribute29
      ,p_dce_attribute30                =>  p_dce_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      ,p_dpnt_rlshp_flag                => p_dpnt_rlshp_flag
      ,p_dpnt_age_flag                  => p_dpnt_age_flag
      ,p_dpnt_stud_flag                 => p_dpnt_stud_flag
      ,p_dpnt_dsbld_flag                => p_dpnt_dsbld_flag
      ,p_dpnt_mrtl_flag                 => p_dpnt_mrtl_flag
      ,p_dpnt_mltry_flag                => p_dpnt_mltry_flag
      ,p_dpnt_pstl_flag                 => p_dpnt_pstl_flag
      ,p_dpnt_cvrd_in_anthr_pl_flag     => p_dpnt_cvrd_in_anthr_pl_flag
      ,p_dpnt_dsgnt_crntly_enrld_flag   => p_dpnt_dsgnt_crntly_enrld_flag
      ,p_dpnt_crit_flag                 => p_dpnt_crit_flag
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_DPNT_CVG_ELIG_PRFL'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_DPNT_CVG_ELIG_PRFL
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
  p_dpnt_cvg_eligy_prfl_id := l_dpnt_cvg_eligy_prfl_id;
  p_effective_end_date := l_effective_end_date;
  p_effective_start_date := l_effective_start_date;
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
    ROLLBACK TO create_DPNT_CVG_ELIG_PRFL;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_dpnt_cvg_eligy_prfl_id := null;
    p_effective_end_date := null;
    p_effective_start_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_dpnt_cvg_eligy_prfl_id := null;
    p_effective_end_date := null;
    p_effective_start_date := null;
    p_object_version_number  := null;

    ROLLBACK TO create_DPNT_CVG_ELIG_PRFL;
    raise;
    --
end create_DPNT_CVG_ELIG_PRFL;
-- ----------------------------------------------------------------------------
-- |------------------------< update_DPNT_CVG_ELIG_PRFL >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_DPNT_CVG_ELIG_PRFL
  (p_validate                       in  boolean   default false
  ,p_dpnt_cvg_eligy_prfl_id         in  number
  ,p_effective_end_date             out nocopy date
  ,p_effective_start_date           out nocopy date
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_regn_id                        in  number    default hr_api.g_number
  ,p_name                           in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_cvg_eligy_prfl_stat_cd    in  varchar2  default hr_api.g_varchar2
  ,p_dce_desc                       in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_cvg_elig_det_rl           in  number    default hr_api.g_number
  ,p_dce_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_dce_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_dce_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_dce_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_dce_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_dce_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_dce_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_dce_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_dce_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_dce_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_dce_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_dce_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_dce_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_dce_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_dce_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_dce_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_dce_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_dce_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_dce_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_dce_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_dce_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_dce_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_dce_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_dce_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_dce_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_dce_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_dce_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_dce_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_dce_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_dce_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_dce_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ,p_dpnt_rlshp_flag                in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_age_flag                  in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_stud_flag                 in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_dsbld_flag                in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_mrtl_flag                 in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_mltry_flag                in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_pstl_flag                 in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_cvrd_in_anthr_pl_flag     in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_dsgnt_crntly_enrld_flag   in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_crit_flag                 in  varchar2  default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_DPNT_CVG_ELIG_PRFL';
  l_object_version_number ben_dpnt_cvg_eligy_prfl_f.object_version_number%TYPE;
  l_effective_end_date ben_dpnt_cvg_eligy_prfl_f.effective_end_date%TYPE;
  l_effective_start_date ben_dpnt_cvg_eligy_prfl_f.effective_start_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_DPNT_CVG_ELIG_PRFL;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_DPNT_CVG_ELIG_PRFL
    --
    ben_DPNT_CVG_ELIG_PRFL_bk2.update_DPNT_CVG_ELIG_PRFL_b
      (
       p_dpnt_cvg_eligy_prfl_id         =>  p_dpnt_cvg_eligy_prfl_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_regn_id                        =>  p_regn_id
      ,p_name                           =>  p_name
      ,p_dpnt_cvg_eligy_prfl_stat_cd    =>  p_dpnt_cvg_eligy_prfl_stat_cd
      ,p_dce_desc                       =>  p_dce_desc
      ,p_dpnt_cvg_elig_det_rl           =>  p_dpnt_cvg_elig_det_rl
      ,p_dce_attribute_category         =>  p_dce_attribute_category
      ,p_dce_attribute1                 =>  p_dce_attribute1
      ,p_dce_attribute2                 =>  p_dce_attribute2
      ,p_dce_attribute3                 =>  p_dce_attribute3
      ,p_dce_attribute4                 =>  p_dce_attribute4
      ,p_dce_attribute5                 =>  p_dce_attribute5
      ,p_dce_attribute6                 =>  p_dce_attribute6
      ,p_dce_attribute7                 =>  p_dce_attribute7
      ,p_dce_attribute8                 =>  p_dce_attribute8
      ,p_dce_attribute9                 =>  p_dce_attribute9
      ,p_dce_attribute10                =>  p_dce_attribute10
      ,p_dce_attribute11                =>  p_dce_attribute11
      ,p_dce_attribute12                =>  p_dce_attribute12
      ,p_dce_attribute13                =>  p_dce_attribute13
      ,p_dce_attribute14                =>  p_dce_attribute14
      ,p_dce_attribute15                =>  p_dce_attribute15
      ,p_dce_attribute16                =>  p_dce_attribute16
      ,p_dce_attribute17                =>  p_dce_attribute17
      ,p_dce_attribute18                =>  p_dce_attribute18
      ,p_dce_attribute19                =>  p_dce_attribute19
      ,p_dce_attribute20                =>  p_dce_attribute20
      ,p_dce_attribute21                =>  p_dce_attribute21
      ,p_dce_attribute22                =>  p_dce_attribute22
      ,p_dce_attribute23                =>  p_dce_attribute23
      ,p_dce_attribute24                =>  p_dce_attribute24
      ,p_dce_attribute25                =>  p_dce_attribute25
      ,p_dce_attribute26                =>  p_dce_attribute26
      ,p_dce_attribute27                =>  p_dce_attribute27
      ,p_dce_attribute28                =>  p_dce_attribute28
      ,p_dce_attribute29                =>  p_dce_attribute29
      ,p_dce_attribute30                =>  p_dce_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      ,p_dpnt_rlshp_flag                => p_dpnt_rlshp_flag
      ,p_dpnt_age_flag                  => p_dpnt_age_flag
      ,p_dpnt_stud_flag                 => p_dpnt_stud_flag
      ,p_dpnt_dsbld_flag                => p_dpnt_dsbld_flag
      ,p_dpnt_mrtl_flag                 => p_dpnt_mrtl_flag
      ,p_dpnt_mltry_flag                => p_dpnt_mltry_flag
      ,p_dpnt_pstl_flag                 => p_dpnt_pstl_flag
      ,p_dpnt_cvrd_in_anthr_pl_flag     => p_dpnt_cvrd_in_anthr_pl_flag
      ,p_dpnt_dsgnt_crntly_enrld_flag   => p_dpnt_dsgnt_crntly_enrld_flag
      ,p_dpnt_crit_flag                 => p_dpnt_crit_flag
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_DPNT_CVG_ELIG_PRFL'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_DPNT_CVG_ELIG_PRFL
    --
  end;
  --
  ben_dce_upd.upd
    (
     p_dpnt_cvg_eligy_prfl_id        => p_dpnt_cvg_eligy_prfl_id
    ,p_effective_end_date            => l_effective_end_date
    ,p_effective_start_date          => l_effective_start_date
    ,p_business_group_id             => p_business_group_id
    ,p_regn_id                       => p_regn_id
    ,p_name                          => p_name
    ,p_dpnt_cvg_eligy_prfl_stat_cd   => p_dpnt_cvg_eligy_prfl_stat_cd
    ,p_dce_desc                      => p_dce_desc
    ,p_dpnt_cvg_elig_det_rl          => p_dpnt_cvg_elig_det_rl
    ,p_dce_attribute_category        => p_dce_attribute_category
    ,p_dce_attribute1                => p_dce_attribute1
    ,p_dce_attribute2                => p_dce_attribute2
    ,p_dce_attribute3                => p_dce_attribute3
    ,p_dce_attribute4                => p_dce_attribute4
    ,p_dce_attribute5                => p_dce_attribute5
    ,p_dce_attribute6                => p_dce_attribute6
    ,p_dce_attribute7                => p_dce_attribute7
    ,p_dce_attribute8                => p_dce_attribute8
    ,p_dce_attribute9                => p_dce_attribute9
    ,p_dce_attribute10               => p_dce_attribute10
    ,p_dce_attribute11               => p_dce_attribute11
    ,p_dce_attribute12               => p_dce_attribute12
    ,p_dce_attribute13               => p_dce_attribute13
    ,p_dce_attribute14               => p_dce_attribute14
    ,p_dce_attribute15               => p_dce_attribute15
    ,p_dce_attribute16               => p_dce_attribute16
    ,p_dce_attribute17               => p_dce_attribute17
    ,p_dce_attribute18               => p_dce_attribute18
    ,p_dce_attribute19               => p_dce_attribute19
    ,p_dce_attribute20               => p_dce_attribute20
    ,p_dce_attribute21               => p_dce_attribute21
    ,p_dce_attribute22               => p_dce_attribute22
    ,p_dce_attribute23               => p_dce_attribute23
    ,p_dce_attribute24               => p_dce_attribute24
    ,p_dce_attribute25               => p_dce_attribute25
    ,p_dce_attribute26               => p_dce_attribute26
    ,p_dce_attribute27               => p_dce_attribute27
    ,p_dce_attribute28               => p_dce_attribute28
    ,p_dce_attribute29               => p_dce_attribute29
    ,p_dce_attribute30               => p_dce_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    ,p_dpnt_rlshp_flag                => p_dpnt_rlshp_flag
    ,p_dpnt_age_flag                  => p_dpnt_age_flag
    ,p_dpnt_stud_flag                 => p_dpnt_stud_flag
    ,p_dpnt_dsbld_flag                => p_dpnt_dsbld_flag
    ,p_dpnt_mrtl_flag                 => p_dpnt_mrtl_flag
    ,p_dpnt_mltry_flag                => p_dpnt_mltry_flag
    ,p_dpnt_pstl_flag                 => p_dpnt_pstl_flag
    ,p_dpnt_cvrd_in_anthr_pl_flag     => p_dpnt_cvrd_in_anthr_pl_flag
    ,p_dpnt_dsgnt_crntly_enrld_flag   => p_dpnt_dsgnt_crntly_enrld_flag
    ,p_dpnt_crit_flag                 => p_dpnt_crit_flag
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_DPNT_CVG_ELIG_PRFL
    --
    ben_DPNT_CVG_ELIG_PRFL_bk2.update_DPNT_CVG_ELIG_PRFL_a
      (
       p_dpnt_cvg_eligy_prfl_id         =>  p_dpnt_cvg_eligy_prfl_id
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_business_group_id              =>  p_business_group_id
      ,p_regn_id                        =>  p_regn_id
      ,p_name                           =>  p_name
      ,p_dpnt_cvg_eligy_prfl_stat_cd    =>  p_dpnt_cvg_eligy_prfl_stat_cd
      ,p_dce_desc                       =>  p_dce_desc
      ,p_dpnt_cvg_elig_det_rl           =>  p_dpnt_cvg_elig_det_rl
      ,p_dce_attribute_category         =>  p_dce_attribute_category
      ,p_dce_attribute1                 =>  p_dce_attribute1
      ,p_dce_attribute2                 =>  p_dce_attribute2
      ,p_dce_attribute3                 =>  p_dce_attribute3
      ,p_dce_attribute4                 =>  p_dce_attribute4
      ,p_dce_attribute5                 =>  p_dce_attribute5
      ,p_dce_attribute6                 =>  p_dce_attribute6
      ,p_dce_attribute7                 =>  p_dce_attribute7
      ,p_dce_attribute8                 =>  p_dce_attribute8
      ,p_dce_attribute9                 =>  p_dce_attribute9
      ,p_dce_attribute10                =>  p_dce_attribute10
      ,p_dce_attribute11                =>  p_dce_attribute11
      ,p_dce_attribute12                =>  p_dce_attribute12
      ,p_dce_attribute13                =>  p_dce_attribute13
      ,p_dce_attribute14                =>  p_dce_attribute14
      ,p_dce_attribute15                =>  p_dce_attribute15
      ,p_dce_attribute16                =>  p_dce_attribute16
      ,p_dce_attribute17                =>  p_dce_attribute17
      ,p_dce_attribute18                =>  p_dce_attribute18
      ,p_dce_attribute19                =>  p_dce_attribute19
      ,p_dce_attribute20                =>  p_dce_attribute20
      ,p_dce_attribute21                =>  p_dce_attribute21
      ,p_dce_attribute22                =>  p_dce_attribute22
      ,p_dce_attribute23                =>  p_dce_attribute23
      ,p_dce_attribute24                =>  p_dce_attribute24
      ,p_dce_attribute25                =>  p_dce_attribute25
      ,p_dce_attribute26                =>  p_dce_attribute26
      ,p_dce_attribute27                =>  p_dce_attribute27
      ,p_dce_attribute28                =>  p_dce_attribute28
      ,p_dce_attribute29                =>  p_dce_attribute29
      ,p_dce_attribute30                =>  p_dce_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      ,p_dpnt_rlshp_flag                => p_dpnt_rlshp_flag
      ,p_dpnt_age_flag                  => p_dpnt_age_flag
      ,p_dpnt_stud_flag                 => p_dpnt_stud_flag
      ,p_dpnt_dsbld_flag                => p_dpnt_dsbld_flag
      ,p_dpnt_mrtl_flag                 => p_dpnt_mrtl_flag
      ,p_dpnt_mltry_flag                => p_dpnt_mltry_flag
      ,p_dpnt_pstl_flag                 => p_dpnt_pstl_flag
      ,p_dpnt_cvrd_in_anthr_pl_flag     => p_dpnt_cvrd_in_anthr_pl_flag
      ,p_dpnt_dsgnt_crntly_enrld_flag   => p_dpnt_dsgnt_crntly_enrld_flag
      ,p_dpnt_crit_flag                 => p_dpnt_crit_flag
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_DPNT_CVG_ELIG_PRFL'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_DPNT_CVG_ELIG_PRFL
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
  p_effective_end_date := l_effective_end_date;
  p_effective_start_date := l_effective_start_date;
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
    ROLLBACK TO update_DPNT_CVG_ELIG_PRFL;
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
    p_effective_end_date := null;
    p_effective_start_date := null;
    p_object_version_number  := l_object_version_number;

    ROLLBACK TO update_DPNT_CVG_ELIG_PRFL;
    raise;
    --
end update_DPNT_CVG_ELIG_PRFL;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_DPNT_CVG_ELIG_PRFL >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_DPNT_CVG_ELIG_PRFL
  (p_validate                       in  boolean  default false
  ,p_dpnt_cvg_eligy_prfl_id         in  number
  ,p_effective_end_date             out nocopy date
  ,p_effective_start_date           out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_DPNT_CVG_ELIG_PRFL';
  l_object_version_number ben_dpnt_cvg_eligy_prfl_f.object_version_number%TYPE;
  l_effective_end_date ben_dpnt_cvg_eligy_prfl_f.effective_end_date%TYPE;
  l_effective_start_date ben_dpnt_cvg_eligy_prfl_f.effective_start_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_DPNT_CVG_ELIG_PRFL;
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
    -- Start of API User Hook for the before hook of delete_DPNT_CVG_ELIG_PRFL
    --
    ben_DPNT_CVG_ELIG_PRFL_bk3.delete_DPNT_CVG_ELIG_PRFL_b
      (
       p_dpnt_cvg_eligy_prfl_id         =>  p_dpnt_cvg_eligy_prfl_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_DPNT_CVG_ELIG_PRFL'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_DPNT_CVG_ELIG_PRFL
    --
  end;
  --
  ben_dce_del.del
    (
     p_dpnt_cvg_eligy_prfl_id        => p_dpnt_cvg_eligy_prfl_id
    ,p_effective_end_date            => l_effective_end_date
    ,p_effective_start_date          => l_effective_start_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_DPNT_CVG_ELIG_PRFL
    --
    ben_DPNT_CVG_ELIG_PRFL_bk3.delete_DPNT_CVG_ELIG_PRFL_a
      (
       p_dpnt_cvg_eligy_prfl_id         =>  p_dpnt_cvg_eligy_prfl_id
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_DPNT_CVG_ELIG_PRFL'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_DPNT_CVG_ELIG_PRFL
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
    ROLLBACK TO delete_DPNT_CVG_ELIG_PRFL;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_effective_end_date := null;
    p_effective_start_date := null;
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_effective_end_date := null;
    p_effective_start_date := null;
    ROLLBACK TO delete_DPNT_CVG_ELIG_PRFL;
    raise;
    --
end delete_DPNT_CVG_ELIG_PRFL;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_dpnt_cvg_eligy_prfl_id                   in     number
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
  ben_dce_shd.lck
    (
      p_dpnt_cvg_eligy_prfl_id                 => p_dpnt_cvg_eligy_prfl_id
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
end ben_DPNT_CVG_ELIG_PRFL_api;

/
