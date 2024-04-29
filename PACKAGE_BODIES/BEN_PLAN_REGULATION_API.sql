--------------------------------------------------------
--  DDL for Package Body BEN_PLAN_REGULATION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PLAN_REGULATION_API" as
/* $Header: beprgapi.pkb 115.3 2002/12/16 07:24:07 rpgupta ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_Plan_regulation_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_Plan_regulation >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_Plan_regulation
  (p_validate                       in  boolean   default false
  ,p_pl_regn_id                     out nocopy number
  ,p_effective_end_date             out nocopy date
  ,p_effective_start_date           out nocopy date
  ,p_business_group_id              in  number    default null
  ,p_regn_id                        in  number    default null
  ,p_pl_id                          in  number    default null
  ,p_rptg_grp_id                    in  number    default null
  ,p_hghly_compd_det_rl             in  number    default null
  ,p_key_ee_det_rl                  in  number    default null
  ,p_cntr_nndscrn_rl                in  number    default null
  ,p_cvg_nndscrn_rl                 in  number    default null
  ,p_five_pct_ownr_rl               in  number    default null
  ,p_regy_pl_typ_cd                 in  varchar2  default null
  ,p_prg_attribute_category         in  varchar2  default null
  ,p_prg_attribute1                 in  varchar2  default null
  ,p_prg_attribute2                 in  varchar2  default null
  ,p_prg_attribute3                 in  varchar2  default null
  ,p_prg_attribute4                 in  varchar2  default null
  ,p_prg_attribute5                 in  varchar2  default null
  ,p_prg_attribute6                 in  varchar2  default null
  ,p_prg_attribute7                 in  varchar2  default null
  ,p_prg_attribute8                 in  varchar2  default null
  ,p_prg_attribute9                 in  varchar2  default null
  ,p_prg_attribute10                in  varchar2  default null
  ,p_prg_attribute11                in  varchar2  default null
  ,p_prg_attribute12                in  varchar2  default null
  ,p_prg_attribute13                in  varchar2  default null
  ,p_prg_attribute14                in  varchar2  default null
  ,p_prg_attribute15                in  varchar2  default null
  ,p_prg_attribute16                in  varchar2  default null
  ,p_prg_attribute17                in  varchar2  default null
  ,p_prg_attribute18                in  varchar2  default null
  ,p_prg_attribute19                in  varchar2  default null
  ,p_prg_attribute20                in  varchar2  default null
  ,p_prg_attribute21                in  varchar2  default null
  ,p_prg_attribute22                in  varchar2  default null
  ,p_prg_attribute23                in  varchar2  default null
  ,p_prg_attribute24                in  varchar2  default null
  ,p_prg_attribute25                in  varchar2  default null
  ,p_prg_attribute26                in  varchar2  default null
  ,p_prg_attribute27                in  varchar2  default null
  ,p_prg_attribute28                in  varchar2  default null
  ,p_prg_attribute29                in  varchar2  default null
  ,p_prg_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_pl_regn_id ben_pl_regn_f.pl_regn_id%TYPE;
  l_effective_end_date ben_pl_regn_f.effective_end_date%TYPE;
  l_effective_start_date ben_pl_regn_f.effective_start_date%TYPE;
  l_proc varchar2(72) := g_package||'create_Plan_regulation';
  l_object_version_number ben_pl_regn_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_Plan_regulation;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_Plan_regulation
    --
    ben_Plan_regulation_bk1.create_Plan_regulation_b
      (
       p_business_group_id              =>  p_business_group_id
      ,p_regn_id                        =>  p_regn_id
      ,p_pl_id                          =>  p_pl_id
      ,p_rptg_grp_id                    =>  p_rptg_grp_id
      ,p_hghly_compd_det_rl             =>  p_hghly_compd_det_rl
      ,p_key_ee_det_rl                  =>  p_key_ee_det_rl
      ,p_cntr_nndscrn_rl                =>  p_cntr_nndscrn_rl
      ,p_cvg_nndscrn_rl                 =>  p_cvg_nndscrn_rl
      ,p_five_pct_ownr_rl               =>  p_five_pct_ownr_rl
      ,p_regy_pl_typ_cd                 =>  p_regy_pl_typ_cd
      ,p_prg_attribute_category         =>  p_prg_attribute_category
      ,p_prg_attribute1                 =>  p_prg_attribute1
      ,p_prg_attribute2                 =>  p_prg_attribute2
      ,p_prg_attribute3                 =>  p_prg_attribute3
      ,p_prg_attribute4                 =>  p_prg_attribute4
      ,p_prg_attribute5                 =>  p_prg_attribute5
      ,p_prg_attribute6                 =>  p_prg_attribute6
      ,p_prg_attribute7                 =>  p_prg_attribute7
      ,p_prg_attribute8                 =>  p_prg_attribute8
      ,p_prg_attribute9                 =>  p_prg_attribute9
      ,p_prg_attribute10                =>  p_prg_attribute10
      ,p_prg_attribute11                =>  p_prg_attribute11
      ,p_prg_attribute12                =>  p_prg_attribute12
      ,p_prg_attribute13                =>  p_prg_attribute13
      ,p_prg_attribute14                =>  p_prg_attribute14
      ,p_prg_attribute15                =>  p_prg_attribute15
      ,p_prg_attribute16                =>  p_prg_attribute16
      ,p_prg_attribute17                =>  p_prg_attribute17
      ,p_prg_attribute18                =>  p_prg_attribute18
      ,p_prg_attribute19                =>  p_prg_attribute19
      ,p_prg_attribute20                =>  p_prg_attribute20
      ,p_prg_attribute21                =>  p_prg_attribute21
      ,p_prg_attribute22                =>  p_prg_attribute22
      ,p_prg_attribute23                =>  p_prg_attribute23
      ,p_prg_attribute24                =>  p_prg_attribute24
      ,p_prg_attribute25                =>  p_prg_attribute25
      ,p_prg_attribute26                =>  p_prg_attribute26
      ,p_prg_attribute27                =>  p_prg_attribute27
      ,p_prg_attribute28                =>  p_prg_attribute28
      ,p_prg_attribute29                =>  p_prg_attribute29
      ,p_prg_attribute30                =>  p_prg_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_Plan_regulation'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_Plan_regulation
    --
  end;
  --
  ben_prg_ins.ins
    (
     p_pl_regn_id                    => l_pl_regn_id
    ,p_effective_end_date            => l_effective_end_date
    ,p_effective_start_date          => l_effective_start_date
    ,p_business_group_id             => p_business_group_id
    ,p_regn_id                       => p_regn_id
    ,p_pl_id                         => p_pl_id
    ,p_rptg_grp_id                   => p_rptg_grp_id
    ,p_hghly_compd_det_rl            => p_hghly_compd_det_rl
    ,p_key_ee_det_rl                 => p_key_ee_det_rl
    ,p_cntr_nndscrn_rl               => p_cntr_nndscrn_rl
    ,p_cvg_nndscrn_rl                => p_cvg_nndscrn_rl
    ,p_five_pct_ownr_rl              => p_five_pct_ownr_rl
    ,p_regy_pl_typ_cd                => p_regy_pl_typ_cd
    ,p_prg_attribute_category        => p_prg_attribute_category
    ,p_prg_attribute1                => p_prg_attribute1
    ,p_prg_attribute2                => p_prg_attribute2
    ,p_prg_attribute3                => p_prg_attribute3
    ,p_prg_attribute4                => p_prg_attribute4
    ,p_prg_attribute5                => p_prg_attribute5
    ,p_prg_attribute6                => p_prg_attribute6
    ,p_prg_attribute7                => p_prg_attribute7
    ,p_prg_attribute8                => p_prg_attribute8
    ,p_prg_attribute9                => p_prg_attribute9
    ,p_prg_attribute10               => p_prg_attribute10
    ,p_prg_attribute11               => p_prg_attribute11
    ,p_prg_attribute12               => p_prg_attribute12
    ,p_prg_attribute13               => p_prg_attribute13
    ,p_prg_attribute14               => p_prg_attribute14
    ,p_prg_attribute15               => p_prg_attribute15
    ,p_prg_attribute16               => p_prg_attribute16
    ,p_prg_attribute17               => p_prg_attribute17
    ,p_prg_attribute18               => p_prg_attribute18
    ,p_prg_attribute19               => p_prg_attribute19
    ,p_prg_attribute20               => p_prg_attribute20
    ,p_prg_attribute21               => p_prg_attribute21
    ,p_prg_attribute22               => p_prg_attribute22
    ,p_prg_attribute23               => p_prg_attribute23
    ,p_prg_attribute24               => p_prg_attribute24
    ,p_prg_attribute25               => p_prg_attribute25
    ,p_prg_attribute26               => p_prg_attribute26
    ,p_prg_attribute27               => p_prg_attribute27
    ,p_prg_attribute28               => p_prg_attribute28
    ,p_prg_attribute29               => p_prg_attribute29
    ,p_prg_attribute30               => p_prg_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_Plan_regulation
    --
    ben_Plan_regulation_bk1.create_Plan_regulation_a
      (
       p_pl_regn_id                     =>  l_pl_regn_id
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_business_group_id              =>  p_business_group_id
      ,p_regn_id                        =>  p_regn_id
      ,p_pl_id                          =>  p_pl_id
      ,p_rptg_grp_id                    =>  p_rptg_grp_id
      ,p_hghly_compd_det_rl             =>  p_hghly_compd_det_rl
      ,p_key_ee_det_rl                  =>  p_key_ee_det_rl
      ,p_cntr_nndscrn_rl                =>  p_cntr_nndscrn_rl
      ,p_cvg_nndscrn_rl                 =>  p_cvg_nndscrn_rl
      ,p_five_pct_ownr_rl               =>  p_five_pct_ownr_rl
      ,p_regy_pl_typ_cd                 =>  p_regy_pl_typ_cd
      ,p_prg_attribute_category         =>  p_prg_attribute_category
      ,p_prg_attribute1                 =>  p_prg_attribute1
      ,p_prg_attribute2                 =>  p_prg_attribute2
      ,p_prg_attribute3                 =>  p_prg_attribute3
      ,p_prg_attribute4                 =>  p_prg_attribute4
      ,p_prg_attribute5                 =>  p_prg_attribute5
      ,p_prg_attribute6                 =>  p_prg_attribute6
      ,p_prg_attribute7                 =>  p_prg_attribute7
      ,p_prg_attribute8                 =>  p_prg_attribute8
      ,p_prg_attribute9                 =>  p_prg_attribute9
      ,p_prg_attribute10                =>  p_prg_attribute10
      ,p_prg_attribute11                =>  p_prg_attribute11
      ,p_prg_attribute12                =>  p_prg_attribute12
      ,p_prg_attribute13                =>  p_prg_attribute13
      ,p_prg_attribute14                =>  p_prg_attribute14
      ,p_prg_attribute15                =>  p_prg_attribute15
      ,p_prg_attribute16                =>  p_prg_attribute16
      ,p_prg_attribute17                =>  p_prg_attribute17
      ,p_prg_attribute18                =>  p_prg_attribute18
      ,p_prg_attribute19                =>  p_prg_attribute19
      ,p_prg_attribute20                =>  p_prg_attribute20
      ,p_prg_attribute21                =>  p_prg_attribute21
      ,p_prg_attribute22                =>  p_prg_attribute22
      ,p_prg_attribute23                =>  p_prg_attribute23
      ,p_prg_attribute24                =>  p_prg_attribute24
      ,p_prg_attribute25                =>  p_prg_attribute25
      ,p_prg_attribute26                =>  p_prg_attribute26
      ,p_prg_attribute27                =>  p_prg_attribute27
      ,p_prg_attribute28                =>  p_prg_attribute28
      ,p_prg_attribute29                =>  p_prg_attribute29
      ,p_prg_attribute30                =>  p_prg_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_Plan_regulation'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_Plan_regulation
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
  p_pl_regn_id := l_pl_regn_id;
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
    ROLLBACK TO create_Plan_regulation;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_pl_regn_id := null;
    p_effective_end_date := null;
    p_effective_start_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_Plan_regulation;
    p_pl_regn_id := null; --nocopy change
    p_effective_end_date := null; --nocopy change
    p_effective_start_date := null; --nocopy change
    p_object_version_number  := null; --nocopy change
    raise;
    --
end create_Plan_regulation;
-- ----------------------------------------------------------------------------
-- |------------------------< update_Plan_regulation >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_Plan_regulation
  (p_validate                       in  boolean   default false
  ,p_pl_regn_id                     in  number
  ,p_effective_end_date             out nocopy date
  ,p_effective_start_date           out nocopy date
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_regn_id                        in  number    default hr_api.g_number
  ,p_pl_id                          in  number    default hr_api.g_number
  ,p_rptg_grp_id                    in  number    default hr_api.g_number
  ,p_hghly_compd_det_rl             in  number    default hr_api.g_number
  ,p_key_ee_det_rl                  in  number    default hr_api.g_number
  ,p_cntr_nndscrn_rl                in  number    default hr_api.g_number
  ,p_cvg_nndscrn_rl                 in  number    default hr_api.g_number
  ,p_five_pct_ownr_rl               in  number    default hr_api.g_number
  ,p_regy_pl_typ_cd                 in  varchar2  default hr_api.g_varchar2
  ,p_prg_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_prg_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_prg_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_prg_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_prg_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_prg_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_prg_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_prg_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_prg_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_prg_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_prg_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_prg_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_prg_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_prg_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_prg_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_prg_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_prg_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_prg_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_prg_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_prg_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_prg_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_prg_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_prg_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_prg_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_prg_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_prg_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_prg_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_prg_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_prg_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_prg_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_prg_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Plan_regulation';
  l_object_version_number ben_pl_regn_f.object_version_number%TYPE;
  l_effective_end_date ben_pl_regn_f.effective_end_date%TYPE;
  l_effective_start_date ben_pl_regn_f.effective_start_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_Plan_regulation;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_Plan_regulation
    --
    ben_Plan_regulation_bk2.update_Plan_regulation_b
      (
       p_pl_regn_id                     =>  p_pl_regn_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_regn_id                        =>  p_regn_id
      ,p_pl_id                          =>  p_pl_id
      ,p_rptg_grp_id                    =>  p_rptg_grp_id
      ,p_hghly_compd_det_rl             =>  p_hghly_compd_det_rl
      ,p_key_ee_det_rl                  =>  p_key_ee_det_rl
      ,p_cntr_nndscrn_rl                =>  p_cntr_nndscrn_rl
      ,p_cvg_nndscrn_rl                 =>  p_cvg_nndscrn_rl
      ,p_five_pct_ownr_rl               =>  p_five_pct_ownr_rl
      ,p_regy_pl_typ_cd                 =>  p_regy_pl_typ_cd
      ,p_prg_attribute_category         =>  p_prg_attribute_category
      ,p_prg_attribute1                 =>  p_prg_attribute1
      ,p_prg_attribute2                 =>  p_prg_attribute2
      ,p_prg_attribute3                 =>  p_prg_attribute3
      ,p_prg_attribute4                 =>  p_prg_attribute4
      ,p_prg_attribute5                 =>  p_prg_attribute5
      ,p_prg_attribute6                 =>  p_prg_attribute6
      ,p_prg_attribute7                 =>  p_prg_attribute7
      ,p_prg_attribute8                 =>  p_prg_attribute8
      ,p_prg_attribute9                 =>  p_prg_attribute9
      ,p_prg_attribute10                =>  p_prg_attribute10
      ,p_prg_attribute11                =>  p_prg_attribute11
      ,p_prg_attribute12                =>  p_prg_attribute12
      ,p_prg_attribute13                =>  p_prg_attribute13
      ,p_prg_attribute14                =>  p_prg_attribute14
      ,p_prg_attribute15                =>  p_prg_attribute15
      ,p_prg_attribute16                =>  p_prg_attribute16
      ,p_prg_attribute17                =>  p_prg_attribute17
      ,p_prg_attribute18                =>  p_prg_attribute18
      ,p_prg_attribute19                =>  p_prg_attribute19
      ,p_prg_attribute20                =>  p_prg_attribute20
      ,p_prg_attribute21                =>  p_prg_attribute21
      ,p_prg_attribute22                =>  p_prg_attribute22
      ,p_prg_attribute23                =>  p_prg_attribute23
      ,p_prg_attribute24                =>  p_prg_attribute24
      ,p_prg_attribute25                =>  p_prg_attribute25
      ,p_prg_attribute26                =>  p_prg_attribute26
      ,p_prg_attribute27                =>  p_prg_attribute27
      ,p_prg_attribute28                =>  p_prg_attribute28
      ,p_prg_attribute29                =>  p_prg_attribute29
      ,p_prg_attribute30                =>  p_prg_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Plan_regulation'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_Plan_regulation
    --
  end;
  --
  ben_prg_upd.upd
    (
     p_pl_regn_id                    => p_pl_regn_id
    ,p_effective_end_date            => l_effective_end_date
    ,p_effective_start_date          => l_effective_start_date
    ,p_business_group_id             => p_business_group_id
    ,p_regn_id                       => p_regn_id
    ,p_pl_id                         => p_pl_id
    ,p_rptg_grp_id                   => p_rptg_grp_id
    ,p_hghly_compd_det_rl            => p_hghly_compd_det_rl
    ,p_key_ee_det_rl                 => p_key_ee_det_rl
    ,p_cntr_nndscrn_rl               => p_cntr_nndscrn_rl
    ,p_cvg_nndscrn_rl                => p_cvg_nndscrn_rl
    ,p_five_pct_ownr_rl              => p_five_pct_ownr_rl
    ,p_regy_pl_typ_cd                => p_regy_pl_typ_cd
    ,p_prg_attribute_category        => p_prg_attribute_category
    ,p_prg_attribute1                => p_prg_attribute1
    ,p_prg_attribute2                => p_prg_attribute2
    ,p_prg_attribute3                => p_prg_attribute3
    ,p_prg_attribute4                => p_prg_attribute4
    ,p_prg_attribute5                => p_prg_attribute5
    ,p_prg_attribute6                => p_prg_attribute6
    ,p_prg_attribute7                => p_prg_attribute7
    ,p_prg_attribute8                => p_prg_attribute8
    ,p_prg_attribute9                => p_prg_attribute9
    ,p_prg_attribute10               => p_prg_attribute10
    ,p_prg_attribute11               => p_prg_attribute11
    ,p_prg_attribute12               => p_prg_attribute12
    ,p_prg_attribute13               => p_prg_attribute13
    ,p_prg_attribute14               => p_prg_attribute14
    ,p_prg_attribute15               => p_prg_attribute15
    ,p_prg_attribute16               => p_prg_attribute16
    ,p_prg_attribute17               => p_prg_attribute17
    ,p_prg_attribute18               => p_prg_attribute18
    ,p_prg_attribute19               => p_prg_attribute19
    ,p_prg_attribute20               => p_prg_attribute20
    ,p_prg_attribute21               => p_prg_attribute21
    ,p_prg_attribute22               => p_prg_attribute22
    ,p_prg_attribute23               => p_prg_attribute23
    ,p_prg_attribute24               => p_prg_attribute24
    ,p_prg_attribute25               => p_prg_attribute25
    ,p_prg_attribute26               => p_prg_attribute26
    ,p_prg_attribute27               => p_prg_attribute27
    ,p_prg_attribute28               => p_prg_attribute28
    ,p_prg_attribute29               => p_prg_attribute29
    ,p_prg_attribute30               => p_prg_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_Plan_regulation
    --
    ben_Plan_regulation_bk2.update_Plan_regulation_a
      (
       p_pl_regn_id                     =>  p_pl_regn_id
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_business_group_id              =>  p_business_group_id
      ,p_regn_id                        =>  p_regn_id
      ,p_pl_id                          =>  p_pl_id
      ,p_rptg_grp_id                    =>  p_rptg_grp_id
      ,p_hghly_compd_det_rl             =>  p_hghly_compd_det_rl
      ,p_key_ee_det_rl                  =>  p_key_ee_det_rl
      ,p_cntr_nndscrn_rl                =>  p_cntr_nndscrn_rl
      ,p_cvg_nndscrn_rl                 =>  p_cvg_nndscrn_rl
      ,p_five_pct_ownr_rl               =>  p_five_pct_ownr_rl
      ,p_regy_pl_typ_cd                 =>  p_regy_pl_typ_cd
      ,p_prg_attribute_category         =>  p_prg_attribute_category
      ,p_prg_attribute1                 =>  p_prg_attribute1
      ,p_prg_attribute2                 =>  p_prg_attribute2
      ,p_prg_attribute3                 =>  p_prg_attribute3
      ,p_prg_attribute4                 =>  p_prg_attribute4
      ,p_prg_attribute5                 =>  p_prg_attribute5
      ,p_prg_attribute6                 =>  p_prg_attribute6
      ,p_prg_attribute7                 =>  p_prg_attribute7
      ,p_prg_attribute8                 =>  p_prg_attribute8
      ,p_prg_attribute9                 =>  p_prg_attribute9
      ,p_prg_attribute10                =>  p_prg_attribute10
      ,p_prg_attribute11                =>  p_prg_attribute11
      ,p_prg_attribute12                =>  p_prg_attribute12
      ,p_prg_attribute13                =>  p_prg_attribute13
      ,p_prg_attribute14                =>  p_prg_attribute14
      ,p_prg_attribute15                =>  p_prg_attribute15
      ,p_prg_attribute16                =>  p_prg_attribute16
      ,p_prg_attribute17                =>  p_prg_attribute17
      ,p_prg_attribute18                =>  p_prg_attribute18
      ,p_prg_attribute19                =>  p_prg_attribute19
      ,p_prg_attribute20                =>  p_prg_attribute20
      ,p_prg_attribute21                =>  p_prg_attribute21
      ,p_prg_attribute22                =>  p_prg_attribute22
      ,p_prg_attribute23                =>  p_prg_attribute23
      ,p_prg_attribute24                =>  p_prg_attribute24
      ,p_prg_attribute25                =>  p_prg_attribute25
      ,p_prg_attribute26                =>  p_prg_attribute26
      ,p_prg_attribute27                =>  p_prg_attribute27
      ,p_prg_attribute28                =>  p_prg_attribute28
      ,p_prg_attribute29                =>  p_prg_attribute29
      ,p_prg_attribute30                =>  p_prg_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Plan_regulation'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_Plan_regulation
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
    ROLLBACK TO update_Plan_regulation;
    p_effective_end_date := null; --nocopy change
    p_effective_start_date := null; --nocopy change
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
    ROLLBACK TO update_Plan_regulation;

    p_effective_end_date := null; --nocopy change
    p_effective_start_date := null; --nocopy change
    raise;
    --
end update_Plan_regulation;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_Plan_regulation >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Plan_regulation
  (p_validate                       in  boolean  default false
  ,p_pl_regn_id                     in  number
  ,p_effective_end_date             out nocopy date
  ,p_effective_start_date           out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Plan_regulation';
  l_object_version_number ben_pl_regn_f.object_version_number%TYPE;
  l_effective_end_date ben_pl_regn_f.effective_end_date%TYPE;
  l_effective_start_date ben_pl_regn_f.effective_start_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_Plan_regulation;
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
    -- Start of API User Hook for the before hook of delete_Plan_regulation
    --
    ben_Plan_regulation_bk3.delete_Plan_regulation_b
      (
       p_pl_regn_id                     =>  p_pl_regn_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Plan_regulation'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_Plan_regulation
    --
  end;
  --
  ben_prg_del.del
    (
     p_pl_regn_id                    => p_pl_regn_id
    ,p_effective_end_date            => l_effective_end_date
    ,p_effective_start_date          => l_effective_start_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_Plan_regulation
    --
    ben_Plan_regulation_bk3.delete_Plan_regulation_a
      (
       p_pl_regn_id                     =>  p_pl_regn_id
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Plan_regulation'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_Plan_regulation
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
    ROLLBACK TO delete_Plan_regulation;
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
    ROLLBACK TO delete_Plan_regulation;
    p_effective_end_date := null; --nocopy change
    p_effective_start_date := null; --nocopy change

    raise;
    --
end delete_Plan_regulation;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_pl_regn_id                   in     number
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
  ben_prg_shd.lck
    (
      p_pl_regn_id                 => p_pl_regn_id
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
end ben_Plan_regulation_api;

/
