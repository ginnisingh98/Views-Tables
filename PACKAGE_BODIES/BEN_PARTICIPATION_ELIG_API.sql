--------------------------------------------------------
--  DDL for Package Body BEN_PARTICIPATION_ELIG_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PARTICIPATION_ELIG_API" as
/* $Header: beepaapi.pkb 120.0 2005/05/28 02:34:54 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_Participation_Elig_api.';
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_Participation_Elig >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_Participation_Elig
  (p_validate                       in  boolean   default false
  ,p_prtn_elig_id                   out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default null
  ,p_pgm_id                         in  number    default null
  ,p_pl_id                          in  number    default null
  ,p_oipl_id                        in  number    default null
  ,p_ptip_id                        in  number    default null
  ,p_plip_id                        in  number    default null
  ,p_trk_scr_for_inelg_flag         in  varchar2  default null
  ,p_prtn_eff_strt_dt_cd            in  varchar2  default null
  ,p_prtn_eff_end_dt_cd             in  varchar2  default null
  ,p_prtn_eff_strt_dt_rl            in  number    default null
  ,p_prtn_eff_end_dt_rl             in  number    default null
  ,p_wait_perd_dt_to_use_cd         in  varchar2  default null
  ,p_wait_perd_dt_to_use_rl         in  number    default null
  ,p_wait_perd_val                  in  number    default null
  ,p_wait_perd_uom                  in  varchar2  default null
  ,p_wait_perd_rl                   in  number    default null
  ,p_mx_poe_det_dt_cd               in  varchar2  default null
  ,p_mx_poe_det_dt_rl               in  number    default null
  ,p_mx_poe_val                     in  number    default null
  ,p_mx_poe_uom                     in  varchar2  default null
  ,p_mx_poe_rl                      in  number    default null
  ,p_mx_poe_apls_cd                 in  varchar2  default null
  ,p_epa_attribute_category         in  varchar2  default null
  ,p_epa_attribute1                 in  varchar2  default null
  ,p_epa_attribute2                 in  varchar2  default null
  ,p_epa_attribute3                 in  varchar2  default null
  ,p_epa_attribute4                 in  varchar2  default null
  ,p_epa_attribute5                 in  varchar2  default null
  ,p_epa_attribute6                 in  varchar2  default null
  ,p_epa_attribute7                 in  varchar2  default null
  ,p_epa_attribute8                 in  varchar2  default null
  ,p_epa_attribute9                 in  varchar2  default null
  ,p_epa_attribute10                in  varchar2  default null
  ,p_epa_attribute11                in  varchar2  default null
  ,p_epa_attribute12                in  varchar2  default null
  ,p_epa_attribute13                in  varchar2  default null
  ,p_epa_attribute14                in  varchar2  default null
  ,p_epa_attribute15                in  varchar2  default null
  ,p_epa_attribute16                in  varchar2  default null
  ,p_epa_attribute17                in  varchar2  default null
  ,p_epa_attribute18                in  varchar2  default null
  ,p_epa_attribute19                in  varchar2  default null
  ,p_epa_attribute20                in  varchar2  default null
  ,p_epa_attribute21                in  varchar2  default null
  ,p_epa_attribute22                in  varchar2  default null
  ,p_epa_attribute23                in  varchar2  default null
  ,p_epa_attribute24                in  varchar2  default null
  ,p_epa_attribute25                in  varchar2  default null
  ,p_epa_attribute26                in  varchar2  default null
  ,p_epa_attribute27                in  varchar2  default null
  ,p_epa_attribute28                in  varchar2  default null
  ,p_epa_attribute29                in  varchar2  default null
  ,p_epa_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_prtn_elig_id ben_prtn_elig_f.prtn_elig_id%TYPE;
  l_effective_start_date ben_prtn_elig_f.effective_start_date%TYPE;
  l_effective_end_date ben_prtn_elig_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_Participation_Elig';
  l_object_version_number ben_prtn_elig_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_Participation_Elig;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_Participation_Elig
    --
    ben_Participation_Elig_bk1.create_Participation_Elig_b
      (p_business_group_id              =>  p_business_group_id
      ,p_pgm_id                         =>  p_pgm_id
      ,p_pl_id                          =>  p_pl_id
      ,p_oipl_id                        =>  p_oipl_id
      ,p_ptip_id                        =>  p_ptip_id
      ,p_plip_id                        =>  p_plip_id
      ,p_trk_scr_for_inelg_flag         =>  p_trk_scr_for_inelg_flag
      ,p_prtn_eff_strt_dt_cd            =>  p_prtn_eff_strt_dt_cd
      ,p_prtn_eff_end_dt_cd             =>  p_prtn_eff_end_dt_cd
      ,p_prtn_eff_strt_dt_rl            =>  p_prtn_eff_strt_dt_rl
      ,p_prtn_eff_end_dt_rl             =>  p_prtn_eff_end_dt_rl
      ,p_wait_perd_dt_to_use_cd         =>  p_wait_perd_dt_to_use_cd
      ,p_wait_perd_dt_to_use_rl         =>  p_wait_perd_dt_to_use_rl
      ,p_wait_perd_val                  =>  p_wait_perd_val
      ,p_wait_perd_uom                  =>  p_wait_perd_uom
      ,p_wait_perd_rl                   =>  p_wait_perd_rl
      ,p_mx_poe_det_dt_cd               =>  p_mx_poe_det_dt_cd
      ,p_mx_poe_det_dt_rl               =>  p_mx_poe_det_dt_rl
      ,p_mx_poe_val                     =>  p_mx_poe_val
      ,p_mx_poe_uom                     =>  p_mx_poe_uom
      ,p_mx_poe_rl                      =>  p_mx_poe_rl
      ,p_mx_poe_apls_cd                 =>  p_mx_poe_apls_cd
      ,p_epa_attribute_category         =>  p_epa_attribute_category
      ,p_epa_attribute1                 =>  p_epa_attribute1
      ,p_epa_attribute2                 =>  p_epa_attribute2
      ,p_epa_attribute3                 =>  p_epa_attribute3
      ,p_epa_attribute4                 =>  p_epa_attribute4
      ,p_epa_attribute5                 =>  p_epa_attribute5
      ,p_epa_attribute6                 =>  p_epa_attribute6
      ,p_epa_attribute7                 =>  p_epa_attribute7
      ,p_epa_attribute8                 =>  p_epa_attribute8
      ,p_epa_attribute9                 =>  p_epa_attribute9
      ,p_epa_attribute10                =>  p_epa_attribute10
      ,p_epa_attribute11                =>  p_epa_attribute11
      ,p_epa_attribute12                =>  p_epa_attribute12
      ,p_epa_attribute13                =>  p_epa_attribute13
      ,p_epa_attribute14                =>  p_epa_attribute14
      ,p_epa_attribute15                =>  p_epa_attribute15
      ,p_epa_attribute16                =>  p_epa_attribute16
      ,p_epa_attribute17                =>  p_epa_attribute17
      ,p_epa_attribute18                =>  p_epa_attribute18
      ,p_epa_attribute19                =>  p_epa_attribute19
      ,p_epa_attribute20                =>  p_epa_attribute20
      ,p_epa_attribute21                =>  p_epa_attribute21
      ,p_epa_attribute22                =>  p_epa_attribute22
      ,p_epa_attribute23                =>  p_epa_attribute23
      ,p_epa_attribute24                =>  p_epa_attribute24
      ,p_epa_attribute25                =>  p_epa_attribute25
      ,p_epa_attribute26                =>  p_epa_attribute26
      ,p_epa_attribute27                =>  p_epa_attribute27
      ,p_epa_attribute28                =>  p_epa_attribute28
      ,p_epa_attribute29                =>  p_epa_attribute29
      ,p_epa_attribute30                =>  p_epa_attribute30
      ,p_effective_date                 =>  trunc(p_effective_date));
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_Participation_Elig'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of create_Participation_Elig
    --
  end;
  --
  ben_epa_ins.ins
    (p_prtn_elig_id                  => l_prtn_elig_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_business_group_id             => p_business_group_id
    ,p_pgm_id                        => p_pgm_id
    ,p_pl_id                         => p_pl_id
    ,p_oipl_id                       => p_oipl_id
    ,p_ptip_id                       => p_ptip_id
    ,p_plip_id                       => p_plip_id
    ,p_trk_scr_for_inelg_flag        => p_trk_scr_for_inelg_flag
    ,p_prtn_eff_strt_dt_cd           => p_prtn_eff_strt_dt_cd
    ,p_prtn_eff_end_dt_cd            => p_prtn_eff_end_dt_cd
    ,p_prtn_eff_strt_dt_rl           => p_prtn_eff_strt_dt_rl
    ,p_prtn_eff_end_dt_rl            => p_prtn_eff_end_dt_rl
    ,p_wait_perd_dt_to_use_cd        =>  p_wait_perd_dt_to_use_cd
    ,p_wait_perd_dt_to_use_rl        =>  p_wait_perd_dt_to_use_rl
    ,p_wait_perd_val                 =>  p_wait_perd_val
    ,p_wait_perd_uom                 =>  p_wait_perd_uom
    ,p_wait_perd_rl                  =>  p_wait_perd_rl
    ,p_mx_poe_det_dt_cd              =>  p_mx_poe_det_dt_cd
    ,p_mx_poe_det_dt_rl              =>  p_mx_poe_det_dt_rl
    ,p_mx_poe_val                    =>  p_mx_poe_val
    ,p_mx_poe_uom                    =>  p_mx_poe_uom
    ,p_mx_poe_rl                     =>  p_mx_poe_rl
    ,p_mx_poe_apls_cd                => p_mx_poe_apls_cd
    ,p_epa_attribute_category        => p_epa_attribute_category
    ,p_epa_attribute1                => p_epa_attribute1
    ,p_epa_attribute2                => p_epa_attribute2
    ,p_epa_attribute3                => p_epa_attribute3
    ,p_epa_attribute4                => p_epa_attribute4
    ,p_epa_attribute5                => p_epa_attribute5
    ,p_epa_attribute6                => p_epa_attribute6
    ,p_epa_attribute7                => p_epa_attribute7
    ,p_epa_attribute8                => p_epa_attribute8
    ,p_epa_attribute9                => p_epa_attribute9
    ,p_epa_attribute10               => p_epa_attribute10
    ,p_epa_attribute11               => p_epa_attribute11
    ,p_epa_attribute12               => p_epa_attribute12
    ,p_epa_attribute13               => p_epa_attribute13
    ,p_epa_attribute14               => p_epa_attribute14
    ,p_epa_attribute15               => p_epa_attribute15
    ,p_epa_attribute16               => p_epa_attribute16
    ,p_epa_attribute17               => p_epa_attribute17
    ,p_epa_attribute18               => p_epa_attribute18
    ,p_epa_attribute19               => p_epa_attribute19
    ,p_epa_attribute20               => p_epa_attribute20
    ,p_epa_attribute21               => p_epa_attribute21
    ,p_epa_attribute22               => p_epa_attribute22
    ,p_epa_attribute23               => p_epa_attribute23
    ,p_epa_attribute24               => p_epa_attribute24
    ,p_epa_attribute25               => p_epa_attribute25
    ,p_epa_attribute26               => p_epa_attribute26
    ,p_epa_attribute27               => p_epa_attribute27
    ,p_epa_attribute28               => p_epa_attribute28
    ,p_epa_attribute29               => p_epa_attribute29
    ,p_epa_attribute30               => p_epa_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date));
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_Participation_Elig
    --
    ben_Participation_Elig_bk1.create_Participation_Elig_a
      (p_prtn_elig_id                   =>  l_prtn_elig_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_business_group_id              =>  p_business_group_id
      ,p_pgm_id                         =>  p_pgm_id
      ,p_pl_id                          =>  p_pl_id
      ,p_oipl_id                        =>  p_oipl_id
      ,p_ptip_id                        =>  p_ptip_id
      ,p_plip_id                        =>  p_plip_id
      ,p_trk_scr_for_inelg_flag         =>  p_trk_scr_for_inelg_flag
      ,p_prtn_eff_strt_dt_cd            =>  p_prtn_eff_strt_dt_cd
      ,p_prtn_eff_end_dt_cd             =>  p_prtn_eff_end_dt_cd
      ,p_prtn_eff_strt_dt_rl            =>  p_prtn_eff_strt_dt_rl
      ,p_prtn_eff_end_dt_rl             =>  p_prtn_eff_end_dt_rl
      ,p_wait_perd_dt_to_use_cd         =>  p_wait_perd_dt_to_use_cd
      ,p_wait_perd_dt_to_use_rl         =>  p_wait_perd_dt_to_use_rl
      ,p_wait_perd_val                  =>  p_wait_perd_val
      ,p_wait_perd_uom                  =>  p_wait_perd_uom
      ,p_wait_perd_rl                   =>  p_wait_perd_rl
      ,p_mx_poe_det_dt_cd               =>  p_mx_poe_det_dt_cd
      ,p_mx_poe_det_dt_rl               =>  p_mx_poe_det_dt_rl
      ,p_mx_poe_val                     =>  p_mx_poe_val
      ,p_mx_poe_uom                     =>  p_mx_poe_uom
      ,p_mx_poe_rl                      =>  p_mx_poe_rl
      ,p_mx_poe_apls_cd                 =>  p_mx_poe_apls_cd
      ,p_epa_attribute_category         =>  p_epa_attribute_category
      ,p_epa_attribute1                 =>  p_epa_attribute1
      ,p_epa_attribute2                 =>  p_epa_attribute2
      ,p_epa_attribute3                 =>  p_epa_attribute3
      ,p_epa_attribute4                 =>  p_epa_attribute4
      ,p_epa_attribute5                 =>  p_epa_attribute5
      ,p_epa_attribute6                 =>  p_epa_attribute6
      ,p_epa_attribute7                 =>  p_epa_attribute7
      ,p_epa_attribute8                 =>  p_epa_attribute8
      ,p_epa_attribute9                 =>  p_epa_attribute9
      ,p_epa_attribute10                =>  p_epa_attribute10
      ,p_epa_attribute11                =>  p_epa_attribute11
      ,p_epa_attribute12                =>  p_epa_attribute12
      ,p_epa_attribute13                =>  p_epa_attribute13
      ,p_epa_attribute14                =>  p_epa_attribute14
      ,p_epa_attribute15                =>  p_epa_attribute15
      ,p_epa_attribute16                =>  p_epa_attribute16
      ,p_epa_attribute17                =>  p_epa_attribute17
      ,p_epa_attribute18                =>  p_epa_attribute18
      ,p_epa_attribute19                =>  p_epa_attribute19
      ,p_epa_attribute20                =>  p_epa_attribute20
      ,p_epa_attribute21                =>  p_epa_attribute21
      ,p_epa_attribute22                =>  p_epa_attribute22
      ,p_epa_attribute23                =>  p_epa_attribute23
      ,p_epa_attribute24                =>  p_epa_attribute24
      ,p_epa_attribute25                =>  p_epa_attribute25
      ,p_epa_attribute26                =>  p_epa_attribute26
      ,p_epa_attribute27                =>  p_epa_attribute27
      ,p_epa_attribute28                =>  p_epa_attribute28
      ,p_epa_attribute29                =>  p_epa_attribute29
      ,p_epa_attribute30                =>  p_epa_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date));
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_Participation_Elig'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of create_Participation_Elig
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
  p_prtn_elig_id := l_prtn_elig_id;
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
    ROLLBACK TO create_Participation_Elig;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_prtn_elig_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_prtn_elig_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
    ROLLBACK TO create_Participation_Elig;
    raise;
    --
end create_Participation_Elig;
-- ----------------------------------------------------------------------------
-- |------------------------< update_Participation_Elig >---------------------|
-- ----------------------------------------------------------------------------
--
procedure update_Participation_Elig
  (p_validate                       in  boolean   default false
  ,p_prtn_elig_id                   in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_pgm_id                         in  number    default hr_api.g_number
  ,p_pl_id                          in  number    default hr_api.g_number
  ,p_oipl_id                        in  number    default hr_api.g_number
  ,p_ptip_id                        in  number    default hr_api.g_number
  ,p_plip_id                        in  number    default hr_api.g_number
  ,p_trk_scr_for_inelg_flag         in  varchar2  default hr_api.g_varchar2
  ,p_prtn_eff_strt_dt_cd            in  varchar2  default hr_api.g_varchar2
  ,p_prtn_eff_end_dt_cd             in  varchar2  default hr_api.g_varchar2
  ,p_prtn_eff_strt_dt_rl            in  number    default hr_api.g_number
  ,p_prtn_eff_end_dt_rl             in  number    default hr_api.g_number
  ,p_wait_perd_dt_to_use_cd         in  varchar2  default hr_api.g_varchar2
  ,p_wait_perd_dt_to_use_rl         in  number    default hr_api.g_number
  ,p_wait_perd_val                  in  number    default hr_api.g_number
  ,p_wait_perd_uom                  in  varchar2  default hr_api.g_varchar2
  ,p_wait_perd_rl                   in  number    default hr_api.g_number
  ,p_mx_poe_det_dt_cd               in  varchar2  default hr_api.g_varchar2
  ,p_mx_poe_det_dt_rl               in  number    default hr_api.g_number
  ,p_mx_poe_val                     in  number    default hr_api.g_number
  ,p_mx_poe_uom                     in  varchar2  default hr_api.g_varchar2
  ,p_mx_poe_rl                      in  number    default hr_api.g_number
  ,p_mx_poe_apls_cd                 in  varchar2  default hr_api.g_varchar2
  ,p_epa_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_epa_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_epa_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_epa_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_epa_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_epa_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_epa_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_epa_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_epa_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_epa_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_epa_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_epa_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_epa_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_epa_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_epa_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_epa_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_epa_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_epa_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_epa_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_epa_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_epa_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_epa_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_epa_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_epa_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_epa_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_epa_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_epa_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_epa_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_epa_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_epa_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_epa_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Participation_Elig';
  l_object_version_number ben_prtn_elig_f.object_version_number%TYPE;
  l_effective_start_date ben_prtn_elig_f.effective_start_date%TYPE;
  l_effective_end_date ben_prtn_elig_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_Participation_Elig;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_Participation_Elig
    --
    ben_Participation_Elig_bk2.update_Participation_Elig_b
      (p_prtn_elig_id                   =>  p_prtn_elig_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pgm_id                         =>  p_pgm_id
      ,p_pl_id                          =>  p_pl_id
      ,p_oipl_id                        =>  p_oipl_id
      ,p_ptip_id                        =>  p_ptip_id
      ,p_plip_id                        =>  p_plip_id
      ,p_trk_scr_for_inelg_flag         =>  p_trk_scr_for_inelg_flag
      ,p_prtn_eff_strt_dt_cd            =>  p_prtn_eff_strt_dt_cd
      ,p_prtn_eff_end_dt_cd             =>  p_prtn_eff_end_dt_cd
      ,p_prtn_eff_strt_dt_rl            =>  p_prtn_eff_strt_dt_rl
      ,p_prtn_eff_end_dt_rl             =>  p_prtn_eff_end_dt_rl
      ,p_wait_perd_dt_to_use_cd         =>  p_wait_perd_dt_to_use_cd
      ,p_wait_perd_dt_to_use_rl         =>  p_wait_perd_dt_to_use_rl
      ,p_wait_perd_val                  =>  p_wait_perd_val
      ,p_wait_perd_uom                  =>  p_wait_perd_uom
      ,p_wait_perd_rl                   =>  p_wait_perd_rl
      ,p_mx_poe_det_dt_cd               =>  p_mx_poe_det_dt_cd
      ,p_mx_poe_det_dt_rl               =>  p_mx_poe_det_dt_rl
      ,p_mx_poe_val                     =>  p_mx_poe_val
      ,p_mx_poe_uom                     =>  p_mx_poe_uom
      ,p_mx_poe_rl                      =>  p_mx_poe_rl
      ,p_mx_poe_apls_cd                 =>  p_mx_poe_apls_cd
      ,p_epa_attribute_category         =>  p_epa_attribute_category
      ,p_epa_attribute1                 =>  p_epa_attribute1
      ,p_epa_attribute2                 =>  p_epa_attribute2
      ,p_epa_attribute3                 =>  p_epa_attribute3
      ,p_epa_attribute4                 =>  p_epa_attribute4
      ,p_epa_attribute5                 =>  p_epa_attribute5
      ,p_epa_attribute6                 =>  p_epa_attribute6
      ,p_epa_attribute7                 =>  p_epa_attribute7
      ,p_epa_attribute8                 =>  p_epa_attribute8
      ,p_epa_attribute9                 =>  p_epa_attribute9
      ,p_epa_attribute10                =>  p_epa_attribute10
      ,p_epa_attribute11                =>  p_epa_attribute11
      ,p_epa_attribute12                =>  p_epa_attribute12
      ,p_epa_attribute13                =>  p_epa_attribute13
      ,p_epa_attribute14                =>  p_epa_attribute14
      ,p_epa_attribute15                =>  p_epa_attribute15
      ,p_epa_attribute16                =>  p_epa_attribute16
      ,p_epa_attribute17                =>  p_epa_attribute17
      ,p_epa_attribute18                =>  p_epa_attribute18
      ,p_epa_attribute19                =>  p_epa_attribute19
      ,p_epa_attribute20                =>  p_epa_attribute20
      ,p_epa_attribute21                =>  p_epa_attribute21
      ,p_epa_attribute22                =>  p_epa_attribute22
      ,p_epa_attribute23                =>  p_epa_attribute23
      ,p_epa_attribute24                =>  p_epa_attribute24
      ,p_epa_attribute25                =>  p_epa_attribute25
      ,p_epa_attribute26                =>  p_epa_attribute26
      ,p_epa_attribute27                =>  p_epa_attribute27
      ,p_epa_attribute28                =>  p_epa_attribute28
      ,p_epa_attribute29                =>  p_epa_attribute29
      ,p_epa_attribute30                =>  p_epa_attribute30
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_datetrack_mode                 =>  p_datetrack_mode);
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Participation_Elig'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of update_Participation_Elig
    --
  end;
  --
  ben_epa_upd.upd
    (p_prtn_elig_id                  => p_prtn_elig_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_business_group_id             => p_business_group_id
    ,p_pgm_id                        => p_pgm_id
    ,p_pl_id                         => p_pl_id
    ,p_oipl_id                       => p_oipl_id
    ,p_ptip_id                       => p_ptip_id
    ,p_plip_id                       => p_plip_id
    ,p_trk_scr_for_inelg_flag        => p_trk_scr_for_inelg_flag
    ,p_prtn_eff_strt_dt_cd           => p_prtn_eff_strt_dt_cd
    ,p_prtn_eff_end_dt_cd            => p_prtn_eff_end_dt_cd
    ,p_prtn_eff_strt_dt_rl           => p_prtn_eff_strt_dt_rl
    ,p_prtn_eff_end_dt_rl            => p_prtn_eff_end_dt_rl
    ,p_wait_perd_dt_to_use_cd        => p_wait_perd_dt_to_use_cd
    ,p_wait_perd_dt_to_use_rl        => p_wait_perd_dt_to_use_rl
    ,p_wait_perd_val                 => p_wait_perd_val
    ,p_wait_perd_uom                 => p_wait_perd_uom
    ,p_wait_perd_rl                  => p_wait_perd_rl
    ,p_mx_poe_det_dt_cd              => p_mx_poe_det_dt_cd
    ,p_mx_poe_det_dt_rl              => p_mx_poe_det_dt_rl
    ,p_mx_poe_val                    => p_mx_poe_val
    ,p_mx_poe_uom                    => p_mx_poe_uom
    ,p_mx_poe_rl                     => p_mx_poe_rl
    ,p_mx_poe_apls_cd                => p_mx_poe_apls_cd
    ,p_epa_attribute_category        => p_epa_attribute_category
    ,p_epa_attribute1                => p_epa_attribute1
    ,p_epa_attribute2                => p_epa_attribute2
    ,p_epa_attribute3                => p_epa_attribute3
    ,p_epa_attribute4                => p_epa_attribute4
    ,p_epa_attribute5                => p_epa_attribute5
    ,p_epa_attribute6                => p_epa_attribute6
    ,p_epa_attribute7                => p_epa_attribute7
    ,p_epa_attribute8                => p_epa_attribute8
    ,p_epa_attribute9                => p_epa_attribute9
    ,p_epa_attribute10               => p_epa_attribute10
    ,p_epa_attribute11               => p_epa_attribute11
    ,p_epa_attribute12               => p_epa_attribute12
    ,p_epa_attribute13               => p_epa_attribute13
    ,p_epa_attribute14               => p_epa_attribute14
    ,p_epa_attribute15               => p_epa_attribute15
    ,p_epa_attribute16               => p_epa_attribute16
    ,p_epa_attribute17               => p_epa_attribute17
    ,p_epa_attribute18               => p_epa_attribute18
    ,p_epa_attribute19               => p_epa_attribute19
    ,p_epa_attribute20               => p_epa_attribute20
    ,p_epa_attribute21               => p_epa_attribute21
    ,p_epa_attribute22               => p_epa_attribute22
    ,p_epa_attribute23               => p_epa_attribute23
    ,p_epa_attribute24               => p_epa_attribute24
    ,p_epa_attribute25               => p_epa_attribute25
    ,p_epa_attribute26               => p_epa_attribute26
    ,p_epa_attribute27               => p_epa_attribute27
    ,p_epa_attribute28               => p_epa_attribute28
    ,p_epa_attribute29               => p_epa_attribute29
    ,p_epa_attribute30               => p_epa_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode);
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_Participation_Elig
    --
    ben_Participation_Elig_bk2.update_Participation_Elig_a
      (p_prtn_elig_id                   =>  p_prtn_elig_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_business_group_id              =>  p_business_group_id
      ,p_pgm_id                         =>  p_pgm_id
      ,p_pl_id                          =>  p_pl_id
      ,p_oipl_id                        =>  p_oipl_id
      ,p_ptip_id                        =>  p_ptip_id
      ,p_plip_id                        =>  p_plip_id
      ,p_trk_scr_for_inelg_flag         =>  p_trk_scr_for_inelg_flag
      ,p_prtn_eff_strt_dt_cd            =>  p_prtn_eff_strt_dt_cd
      ,p_prtn_eff_end_dt_cd             =>  p_prtn_eff_end_dt_cd
      ,p_prtn_eff_strt_dt_rl            =>  p_prtn_eff_strt_dt_rl
      ,p_prtn_eff_end_dt_rl             =>  p_prtn_eff_end_dt_rl
      ,p_wait_perd_dt_to_use_cd         =>  p_wait_perd_dt_to_use_cd
      ,p_wait_perd_dt_to_use_rl         =>  p_wait_perd_dt_to_use_rl
      ,p_wait_perd_val                  =>  p_wait_perd_val
      ,p_wait_perd_uom                  =>  p_wait_perd_uom
      ,p_wait_perd_rl                   =>  p_wait_perd_rl
      ,p_mx_poe_det_dt_cd               =>  p_mx_poe_det_dt_cd
      ,p_mx_poe_det_dt_rl               =>  p_mx_poe_det_dt_rl
      ,p_mx_poe_val                     =>  p_mx_poe_val
      ,p_mx_poe_uom                     =>  p_mx_poe_uom
      ,p_mx_poe_rl                      =>  p_mx_poe_rl
      ,p_mx_poe_apls_cd                 =>  p_mx_poe_apls_cd
      ,p_epa_attribute_category         =>  p_epa_attribute_category
      ,p_epa_attribute1                 =>  p_epa_attribute1
      ,p_epa_attribute2                 =>  p_epa_attribute2
      ,p_epa_attribute3                 =>  p_epa_attribute3
      ,p_epa_attribute4                 =>  p_epa_attribute4
      ,p_epa_attribute5                 =>  p_epa_attribute5
      ,p_epa_attribute6                 =>  p_epa_attribute6
      ,p_epa_attribute7                 =>  p_epa_attribute7
      ,p_epa_attribute8                 =>  p_epa_attribute8
      ,p_epa_attribute9                 =>  p_epa_attribute9
      ,p_epa_attribute10                =>  p_epa_attribute10
      ,p_epa_attribute11                =>  p_epa_attribute11
      ,p_epa_attribute12                =>  p_epa_attribute12
      ,p_epa_attribute13                =>  p_epa_attribute13
      ,p_epa_attribute14                =>  p_epa_attribute14
      ,p_epa_attribute15                =>  p_epa_attribute15
      ,p_epa_attribute16                =>  p_epa_attribute16
      ,p_epa_attribute17                =>  p_epa_attribute17
      ,p_epa_attribute18                =>  p_epa_attribute18
      ,p_epa_attribute19                =>  p_epa_attribute19
      ,p_epa_attribute20                =>  p_epa_attribute20
      ,p_epa_attribute21                =>  p_epa_attribute21
      ,p_epa_attribute22                =>  p_epa_attribute22
      ,p_epa_attribute23                =>  p_epa_attribute23
      ,p_epa_attribute24                =>  p_epa_attribute24
      ,p_epa_attribute25                =>  p_epa_attribute25
      ,p_epa_attribute26                =>  p_epa_attribute26
      ,p_epa_attribute27                =>  p_epa_attribute27
      ,p_epa_attribute28                =>  p_epa_attribute28
      ,p_epa_attribute29                =>  p_epa_attribute29
      ,p_epa_attribute30                =>  p_epa_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_datetrack_mode                 =>  p_datetrack_mode);
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Participation_Elig'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of update_Participation_Elig
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
    ROLLBACK TO update_Participation_Elig;
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
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
    ROLLBACK TO update_Participation_Elig;
    raise;
    --
end update_Participation_Elig;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_Participation_Elig >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Participation_Elig
  (p_validate                       in  boolean  default false
  ,p_prtn_elig_id                   in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Participation_Elig';
  l_object_version_number ben_prtn_elig_f.object_version_number%TYPE;
  l_effective_start_date ben_prtn_elig_f.effective_start_date%TYPE;
  l_effective_end_date ben_prtn_elig_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_Participation_Elig;
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
    -- Start of API User Hook for the before hook of delete_Participation_Elig
    --
    ben_Participation_Elig_bk3.delete_Participation_Elig_b
      (p_prtn_elig_id                   =>  p_prtn_elig_id
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_datetrack_mode                 =>  p_datetrack_mode);
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Participation_Elig'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of delete_Participation_Elig
    --
  end;
  --
  ben_epa_del.del
    (p_prtn_elig_id                  => p_prtn_elig_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode);
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_Participation_Elig
    --
    ben_Participation_Elig_bk3.delete_Participation_Elig_a
      (p_prtn_elig_id                   =>  p_prtn_elig_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_datetrack_mode                 =>  p_datetrack_mode);
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Participation_Elig'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of delete_Participation_Elig
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
    ROLLBACK TO delete_Participation_Elig;
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
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
    ROLLBACK TO delete_Participation_Elig;
    raise;
    --
end delete_Participation_Elig;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (p_prtn_elig_id                   in     number
  ,p_object_version_number          in     number
  ,p_effective_date                 in     date
  ,p_datetrack_mode                 in     varchar2
  ,p_validation_start_date          out nocopy    date
  ,p_validation_end_date            out nocopy    date) is
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
  ben_epa_shd.lck
    (p_prtn_elig_id               => p_prtn_elig_id
    ,p_validation_start_date      => l_validation_start_date
    ,p_validation_end_date        => l_validation_end_date
    ,p_object_version_number      => p_object_version_number
    ,p_effective_date             => p_effective_date
    ,p_datetrack_mode             => p_datetrack_mode);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_Participation_Elig_api;

/
