--------------------------------------------------------
--  DDL for Package Body BEN_REIMBMT_CTFN_PRVDD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_REIMBMT_CTFN_PRVDD_API" as
/* $Header: bepqcapi.pkb 115.3 2002/12/13 06:55:26 hmani noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_reimbmt_ctfn_prvdd_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_reimbmt_ctfn_prvdd >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_reimbmt_ctfn_prvdd
  (p_validate                       in  boolean   default false
  ,p_prtt_rmt_rqst_ctfn_prvdd_id    out nocopy number
  ,p_prtt_clm_gd_or_svc_typ_id      in  number    default null
  ,p_pl_gd_r_svc_ctfn_id            in  number    default null
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_reimbmt_ctfn_rqd_flag          in  varchar2  default null
  ,p_business_group_id              in  number    default null
  ,p_prtt_enrt_actn_id              in  number    default null
  ,p_reimbmt_ctfn_recd_dt           in  date      default null
  ,p_reimbmt_ctfn_dnd_dt            in  date      default null
  ,p_reimbmt_ctfn_typ_cd            in  varchar2  default null
  ,p_pqc_attribute_category         in  varchar2  default null
  ,p_pqc_attribute1                 in  varchar2  default null
  ,p_pqc_attribute2                 in  varchar2  default null
  ,p_pqc_attribute3                 in  varchar2  default null
  ,p_pqc_attribute4                 in  varchar2  default null
  ,p_pqc_attribute5                 in  varchar2  default null
  ,p_pqc_attribute6                 in  varchar2  default null
  ,p_pqc_attribute7                 in  varchar2  default null
  ,p_pqc_attribute8                 in  varchar2  default null
  ,p_pqc_attribute9                 in  varchar2  default null
  ,p_pqc_attribute10                in  varchar2  default null
  ,p_pqc_attribute11                in  varchar2  default null
  ,p_pqc_attribute12                in  varchar2  default null
  ,p_pqc_attribute13                in  varchar2  default null
  ,p_pqc_attribute14                in  varchar2  default null
  ,p_pqc_attribute15                in  varchar2  default null
  ,p_pqc_attribute16                in  varchar2  default null
  ,p_pqc_attribute17                in  varchar2  default null
  ,p_pqc_attribute18                in  varchar2  default null
  ,p_pqc_attribute19                in  varchar2  default null
  ,p_pqc_attribute20                in  varchar2  default null
  ,p_pqc_attribute21                in  varchar2  default null
  ,p_pqc_attribute22                in  varchar2  default null
  ,p_pqc_attribute23                in  varchar2  default null
  ,p_pqc_attribute24                in  varchar2  default null
  ,p_pqc_attribute25                in  varchar2  default null
  ,p_pqc_attribute26                in  varchar2  default null
  ,p_pqc_attribute27                in  varchar2  default null
  ,p_pqc_attribute28                in  varchar2  default null
  ,p_pqc_attribute29                in  varchar2  default null
  ,p_pqc_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_prtt_rmt_rqst_ctfn_prvdd_id ben_prtt_rmt_rqst_ctfn_prvdd_f.prtt_rmt_rqst_ctfn_prvdd_id%TYPE;
  l_effective_start_date ben_prtt_rmt_rqst_ctfn_prvdd_f.effective_start_date%TYPE;
  l_effective_end_date ben_prtt_rmt_rqst_ctfn_prvdd_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_reimbmt_ctfn_prvdd';
  l_object_version_number ben_prtt_rmt_rqst_ctfn_prvdd_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_reimbmt_ctfn_prvdd;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_reimbmt_ctfn_prvdd
    --
    ben_reimbmt_ctfn_prvdd_bk1.create_reimbmt_ctfn_prvdd_b
      (
       p_prtt_clm_gd_or_svc_typ_id      =>  p_prtt_clm_gd_or_svc_typ_id
      ,p_pl_gd_r_svc_ctfn_id            =>  p_pl_gd_r_svc_ctfn_id
      ,p_reimbmt_ctfn_rqd_flag          =>  p_reimbmt_ctfn_rqd_flag
      ,p_business_group_id              =>  p_business_group_id
      ,p_prtt_enrt_actn_id              =>  p_prtt_enrt_actn_id
      ,p_reimbmt_ctfn_recd_dt           =>  p_reimbmt_ctfn_recd_dt
      ,p_reimbmt_ctfn_dnd_dt            =>  p_reimbmt_ctfn_dnd_dt
      ,p_reimbmt_ctfn_typ_cd            =>  p_reimbmt_ctfn_typ_cd
      ,p_pqc_attribute_category         =>  p_pqc_attribute_category
      ,p_pqc_attribute1                 =>  p_pqc_attribute1
      ,p_pqc_attribute2                 =>  p_pqc_attribute2
      ,p_pqc_attribute3                 =>  p_pqc_attribute3
      ,p_pqc_attribute4                 =>  p_pqc_attribute4
      ,p_pqc_attribute5                 =>  p_pqc_attribute5
      ,p_pqc_attribute6                 =>  p_pqc_attribute6
      ,p_pqc_attribute7                 =>  p_pqc_attribute7
      ,p_pqc_attribute8                 =>  p_pqc_attribute8
      ,p_pqc_attribute9                 =>  p_pqc_attribute9
      ,p_pqc_attribute10                =>  p_pqc_attribute10
      ,p_pqc_attribute11                =>  p_pqc_attribute11
      ,p_pqc_attribute12                =>  p_pqc_attribute12
      ,p_pqc_attribute13                =>  p_pqc_attribute13
      ,p_pqc_attribute14                =>  p_pqc_attribute14
      ,p_pqc_attribute15                =>  p_pqc_attribute15
      ,p_pqc_attribute16                =>  p_pqc_attribute16
      ,p_pqc_attribute17                =>  p_pqc_attribute17
      ,p_pqc_attribute18                =>  p_pqc_attribute18
      ,p_pqc_attribute19                =>  p_pqc_attribute19
      ,p_pqc_attribute20                =>  p_pqc_attribute20
      ,p_pqc_attribute21                =>  p_pqc_attribute21
      ,p_pqc_attribute22                =>  p_pqc_attribute22
      ,p_pqc_attribute23                =>  p_pqc_attribute23
      ,p_pqc_attribute24                =>  p_pqc_attribute24
      ,p_pqc_attribute25                =>  p_pqc_attribute25
      ,p_pqc_attribute26                =>  p_pqc_attribute26
      ,p_pqc_attribute27                =>  p_pqc_attribute27
      ,p_pqc_attribute28                =>  p_pqc_attribute28
      ,p_pqc_attribute29                =>  p_pqc_attribute29
      ,p_pqc_attribute30                =>  p_pqc_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_reimbmt_ctfn_prvdd'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_reimbmt_ctfn_prvdd
    --
  end;
  --
  ben_pqc_ins.ins
    (
     p_prtt_rmt_rqst_ctfn_prvdd_id   => l_prtt_rmt_rqst_ctfn_prvdd_id
    ,p_prtt_clm_gd_or_svc_typ_id     => p_prtt_clm_gd_or_svc_typ_id
    ,p_pl_gd_r_svc_ctfn_id           => p_pl_gd_r_svc_ctfn_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_reimbmt_ctfn_rqd_flag         => p_reimbmt_ctfn_rqd_flag
    ,p_business_group_id             => p_business_group_id
    ,p_prtt_enrt_actn_id             => p_prtt_enrt_actn_id
    ,p_reimbmt_ctfn_recd_dt          => p_reimbmt_ctfn_recd_dt
    ,p_reimbmt_ctfn_dnd_dt           => p_reimbmt_ctfn_dnd_dt
    ,p_reimbmt_ctfn_typ_cd           => p_reimbmt_ctfn_typ_cd
    ,p_pqc_attribute_category        => p_pqc_attribute_category
    ,p_pqc_attribute1                => p_pqc_attribute1
    ,p_pqc_attribute2                => p_pqc_attribute2
    ,p_pqc_attribute3                => p_pqc_attribute3
    ,p_pqc_attribute4                => p_pqc_attribute4
    ,p_pqc_attribute5                => p_pqc_attribute5
    ,p_pqc_attribute6                => p_pqc_attribute6
    ,p_pqc_attribute7                => p_pqc_attribute7
    ,p_pqc_attribute8                => p_pqc_attribute8
    ,p_pqc_attribute9                => p_pqc_attribute9
    ,p_pqc_attribute10               => p_pqc_attribute10
    ,p_pqc_attribute11               => p_pqc_attribute11
    ,p_pqc_attribute12               => p_pqc_attribute12
    ,p_pqc_attribute13               => p_pqc_attribute13
    ,p_pqc_attribute14               => p_pqc_attribute14
    ,p_pqc_attribute15               => p_pqc_attribute15
    ,p_pqc_attribute16               => p_pqc_attribute16
    ,p_pqc_attribute17               => p_pqc_attribute17
    ,p_pqc_attribute18               => p_pqc_attribute18
    ,p_pqc_attribute19               => p_pqc_attribute19
    ,p_pqc_attribute20               => p_pqc_attribute20
    ,p_pqc_attribute21               => p_pqc_attribute21
    ,p_pqc_attribute22               => p_pqc_attribute22
    ,p_pqc_attribute23               => p_pqc_attribute23
    ,p_pqc_attribute24               => p_pqc_attribute24
    ,p_pqc_attribute25               => p_pqc_attribute25
    ,p_pqc_attribute26               => p_pqc_attribute26
    ,p_pqc_attribute27               => p_pqc_attribute27
    ,p_pqc_attribute28               => p_pqc_attribute28
    ,p_pqc_attribute29               => p_pqc_attribute29
    ,p_pqc_attribute30               => p_pqc_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_reimbmt_ctfn_prvdd
    --
    ben_reimbmt_ctfn_prvdd_bk1.create_reimbmt_ctfn_prvdd_a
      (
       p_prtt_rmt_rqst_ctfn_prvdd_id    =>  l_prtt_rmt_rqst_ctfn_prvdd_id
      ,p_prtt_clm_gd_or_svc_typ_id      =>  p_prtt_clm_gd_or_svc_typ_id
      ,p_pl_gd_r_svc_ctfn_id            =>  p_pl_gd_r_svc_ctfn_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_reimbmt_ctfn_rqd_flag          =>  p_reimbmt_ctfn_rqd_flag
      ,p_business_group_id              =>  p_business_group_id
      ,p_prtt_enrt_actn_id              =>  p_prtt_enrt_actn_id
      ,p_reimbmt_ctfn_recd_dt           =>  p_reimbmt_ctfn_recd_dt
      ,p_reimbmt_ctfn_dnd_dt            =>  p_reimbmt_ctfn_dnd_dt
      ,p_reimbmt_ctfn_typ_cd            =>  p_reimbmt_ctfn_typ_cd
      ,p_pqc_attribute_category         =>  p_pqc_attribute_category
      ,p_pqc_attribute1                 =>  p_pqc_attribute1
      ,p_pqc_attribute2                 =>  p_pqc_attribute2
      ,p_pqc_attribute3                 =>  p_pqc_attribute3
      ,p_pqc_attribute4                 =>  p_pqc_attribute4
      ,p_pqc_attribute5                 =>  p_pqc_attribute5
      ,p_pqc_attribute6                 =>  p_pqc_attribute6
      ,p_pqc_attribute7                 =>  p_pqc_attribute7
      ,p_pqc_attribute8                 =>  p_pqc_attribute8
      ,p_pqc_attribute9                 =>  p_pqc_attribute9
      ,p_pqc_attribute10                =>  p_pqc_attribute10
      ,p_pqc_attribute11                =>  p_pqc_attribute11
      ,p_pqc_attribute12                =>  p_pqc_attribute12
      ,p_pqc_attribute13                =>  p_pqc_attribute13
      ,p_pqc_attribute14                =>  p_pqc_attribute14
      ,p_pqc_attribute15                =>  p_pqc_attribute15
      ,p_pqc_attribute16                =>  p_pqc_attribute16
      ,p_pqc_attribute17                =>  p_pqc_attribute17
      ,p_pqc_attribute18                =>  p_pqc_attribute18
      ,p_pqc_attribute19                =>  p_pqc_attribute19
      ,p_pqc_attribute20                =>  p_pqc_attribute20
      ,p_pqc_attribute21                =>  p_pqc_attribute21
      ,p_pqc_attribute22                =>  p_pqc_attribute22
      ,p_pqc_attribute23                =>  p_pqc_attribute23
      ,p_pqc_attribute24                =>  p_pqc_attribute24
      ,p_pqc_attribute25                =>  p_pqc_attribute25
      ,p_pqc_attribute26                =>  p_pqc_attribute26
      ,p_pqc_attribute27                =>  p_pqc_attribute27
      ,p_pqc_attribute28                =>  p_pqc_attribute28
      ,p_pqc_attribute29                =>  p_pqc_attribute29
      ,p_pqc_attribute30                =>  p_pqc_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_reimbmt_ctfn_prvdd'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_reimbmt_ctfn_prvdd
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
  p_prtt_rmt_rqst_ctfn_prvdd_id := l_prtt_rmt_rqst_ctfn_prvdd_id;
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
    ROLLBACK TO create_reimbmt_ctfn_prvdd;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_prtt_rmt_rqst_ctfn_prvdd_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_reimbmt_ctfn_prvdd;
    raise;
    --
end create_reimbmt_ctfn_prvdd;
-- ----------------------------------------------------------------------------
-- |------------------------< update_reimbmt_ctfn_prvdd >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_reimbmt_ctfn_prvdd
  (p_validate                       in  boolean   default false
  ,p_prtt_rmt_rqst_ctfn_prvdd_id    in  number
  ,p_prtt_clm_gd_or_svc_typ_id      in  number    default hr_api.g_number
  ,p_pl_gd_r_svc_ctfn_id            in  number    default hr_api.g_number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_reimbmt_ctfn_rqd_flag          in  varchar2  default hr_api.g_varchar2
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_prtt_enrt_actn_id              in  number    default hr_api.g_number
  ,p_reimbmt_ctfn_recd_dt           in  date      default hr_api.g_date
  ,p_reimbmt_ctfn_dnd_dt            in  date      default hr_api.g_date
  ,p_reimbmt_ctfn_typ_cd            in  varchar2  default hr_api.g_varchar2
  ,p_pqc_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_pqc_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_pqc_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_pqc_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_pqc_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_pqc_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_pqc_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_pqc_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_pqc_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_pqc_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_pqc_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_pqc_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_pqc_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_pqc_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_pqc_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_pqc_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_pqc_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_pqc_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_pqc_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_pqc_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_pqc_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_pqc_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_pqc_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_pqc_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_pqc_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_pqc_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_pqc_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_pqc_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_pqc_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_pqc_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_pqc_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_reimbmt_ctfn_prvdd';
  l_object_version_number ben_prtt_rmt_rqst_ctfn_prvdd_f.object_version_number%TYPE;
  l_effective_start_date ben_prtt_rmt_rqst_ctfn_prvdd_f.effective_start_date%TYPE;
  l_effective_end_date ben_prtt_rmt_rqst_ctfn_prvdd_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_reimbmt_ctfn_prvdd;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_reimbmt_ctfn_prvdd
    --
    ben_reimbmt_ctfn_prvdd_bk2.update_reimbmt_ctfn_prvdd_b
      (
       p_prtt_rmt_rqst_ctfn_prvdd_id    =>  p_prtt_rmt_rqst_ctfn_prvdd_id
      ,p_prtt_clm_gd_or_svc_typ_id      =>  p_prtt_clm_gd_or_svc_typ_id
      ,p_pl_gd_r_svc_ctfn_id            =>  p_pl_gd_r_svc_ctfn_id
      ,p_reimbmt_ctfn_rqd_flag          =>  p_reimbmt_ctfn_rqd_flag
      ,p_business_group_id              =>  p_business_group_id
      ,p_prtt_enrt_actn_id              =>  p_prtt_enrt_actn_id
      ,p_reimbmt_ctfn_recd_dt           =>  p_reimbmt_ctfn_recd_dt
      ,p_reimbmt_ctfn_dnd_dt            =>  p_reimbmt_ctfn_dnd_dt
      ,p_reimbmt_ctfn_typ_cd            =>  p_reimbmt_ctfn_typ_cd
      ,p_pqc_attribute_category         =>  p_pqc_attribute_category
      ,p_pqc_attribute1                 =>  p_pqc_attribute1
      ,p_pqc_attribute2                 =>  p_pqc_attribute2
      ,p_pqc_attribute3                 =>  p_pqc_attribute3
      ,p_pqc_attribute4                 =>  p_pqc_attribute4
      ,p_pqc_attribute5                 =>  p_pqc_attribute5
      ,p_pqc_attribute6                 =>  p_pqc_attribute6
      ,p_pqc_attribute7                 =>  p_pqc_attribute7
      ,p_pqc_attribute8                 =>  p_pqc_attribute8
      ,p_pqc_attribute9                 =>  p_pqc_attribute9
      ,p_pqc_attribute10                =>  p_pqc_attribute10
      ,p_pqc_attribute11                =>  p_pqc_attribute11
      ,p_pqc_attribute12                =>  p_pqc_attribute12
      ,p_pqc_attribute13                =>  p_pqc_attribute13
      ,p_pqc_attribute14                =>  p_pqc_attribute14
      ,p_pqc_attribute15                =>  p_pqc_attribute15
      ,p_pqc_attribute16                =>  p_pqc_attribute16
      ,p_pqc_attribute17                =>  p_pqc_attribute17
      ,p_pqc_attribute18                =>  p_pqc_attribute18
      ,p_pqc_attribute19                =>  p_pqc_attribute19
      ,p_pqc_attribute20                =>  p_pqc_attribute20
      ,p_pqc_attribute21                =>  p_pqc_attribute21
      ,p_pqc_attribute22                =>  p_pqc_attribute22
      ,p_pqc_attribute23                =>  p_pqc_attribute23
      ,p_pqc_attribute24                =>  p_pqc_attribute24
      ,p_pqc_attribute25                =>  p_pqc_attribute25
      ,p_pqc_attribute26                =>  p_pqc_attribute26
      ,p_pqc_attribute27                =>  p_pqc_attribute27
      ,p_pqc_attribute28                =>  p_pqc_attribute28
      ,p_pqc_attribute29                =>  p_pqc_attribute29
      ,p_pqc_attribute30                =>  p_pqc_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_reimbmt_ctfn_prvdd'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_reimbmt_ctfn_prvdd
    --
  end;
  --
  ben_pqc_upd.upd
    (
     p_prtt_rmt_rqst_ctfn_prvdd_id   => p_prtt_rmt_rqst_ctfn_prvdd_id
    ,p_prtt_clm_gd_or_svc_typ_id     => p_prtt_clm_gd_or_svc_typ_id
    ,p_pl_gd_r_svc_ctfn_id           => p_pl_gd_r_svc_ctfn_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_reimbmt_ctfn_rqd_flag         => p_reimbmt_ctfn_rqd_flag
    ,p_business_group_id             => p_business_group_id
    ,p_prtt_enrt_actn_id             => p_prtt_enrt_actn_id
    ,p_reimbmt_ctfn_recd_dt          => p_reimbmt_ctfn_recd_dt
    ,p_reimbmt_ctfn_dnd_dt           => p_reimbmt_ctfn_dnd_dt
    ,p_reimbmt_ctfn_typ_cd           => p_reimbmt_ctfn_typ_cd
    ,p_pqc_attribute_category        => p_pqc_attribute_category
    ,p_pqc_attribute1                => p_pqc_attribute1
    ,p_pqc_attribute2                => p_pqc_attribute2
    ,p_pqc_attribute3                => p_pqc_attribute3
    ,p_pqc_attribute4                => p_pqc_attribute4
    ,p_pqc_attribute5                => p_pqc_attribute5
    ,p_pqc_attribute6                => p_pqc_attribute6
    ,p_pqc_attribute7                => p_pqc_attribute7
    ,p_pqc_attribute8                => p_pqc_attribute8
    ,p_pqc_attribute9                => p_pqc_attribute9
    ,p_pqc_attribute10               => p_pqc_attribute10
    ,p_pqc_attribute11               => p_pqc_attribute11
    ,p_pqc_attribute12               => p_pqc_attribute12
    ,p_pqc_attribute13               => p_pqc_attribute13
    ,p_pqc_attribute14               => p_pqc_attribute14
    ,p_pqc_attribute15               => p_pqc_attribute15
    ,p_pqc_attribute16               => p_pqc_attribute16
    ,p_pqc_attribute17               => p_pqc_attribute17
    ,p_pqc_attribute18               => p_pqc_attribute18
    ,p_pqc_attribute19               => p_pqc_attribute19
    ,p_pqc_attribute20               => p_pqc_attribute20
    ,p_pqc_attribute21               => p_pqc_attribute21
    ,p_pqc_attribute22               => p_pqc_attribute22
    ,p_pqc_attribute23               => p_pqc_attribute23
    ,p_pqc_attribute24               => p_pqc_attribute24
    ,p_pqc_attribute25               => p_pqc_attribute25
    ,p_pqc_attribute26               => p_pqc_attribute26
    ,p_pqc_attribute27               => p_pqc_attribute27
    ,p_pqc_attribute28               => p_pqc_attribute28
    ,p_pqc_attribute29               => p_pqc_attribute29
    ,p_pqc_attribute30               => p_pqc_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_reimbmt_ctfn_prvdd
    --
    ben_reimbmt_ctfn_prvdd_bk2.update_reimbmt_ctfn_prvdd_a
      (
       p_prtt_rmt_rqst_ctfn_prvdd_id    =>  p_prtt_rmt_rqst_ctfn_prvdd_id
      ,p_prtt_clm_gd_or_svc_typ_id      =>  p_prtt_clm_gd_or_svc_typ_id
      ,p_pl_gd_r_svc_ctfn_id            =>  p_pl_gd_r_svc_ctfn_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_reimbmt_ctfn_rqd_flag          =>  p_reimbmt_ctfn_rqd_flag
      ,p_business_group_id              =>  p_business_group_id
      ,p_prtt_enrt_actn_id              =>  p_prtt_enrt_actn_id
      ,p_reimbmt_ctfn_recd_dt           =>  p_reimbmt_ctfn_recd_dt
      ,p_reimbmt_ctfn_dnd_dt            =>  p_reimbmt_ctfn_dnd_dt
      ,p_reimbmt_ctfn_typ_cd            =>  p_reimbmt_ctfn_typ_cd
      ,p_pqc_attribute_category         =>  p_pqc_attribute_category
      ,p_pqc_attribute1                 =>  p_pqc_attribute1
      ,p_pqc_attribute2                 =>  p_pqc_attribute2
      ,p_pqc_attribute3                 =>  p_pqc_attribute3
      ,p_pqc_attribute4                 =>  p_pqc_attribute4
      ,p_pqc_attribute5                 =>  p_pqc_attribute5
      ,p_pqc_attribute6                 =>  p_pqc_attribute6
      ,p_pqc_attribute7                 =>  p_pqc_attribute7
      ,p_pqc_attribute8                 =>  p_pqc_attribute8
      ,p_pqc_attribute9                 =>  p_pqc_attribute9
      ,p_pqc_attribute10                =>  p_pqc_attribute10
      ,p_pqc_attribute11                =>  p_pqc_attribute11
      ,p_pqc_attribute12                =>  p_pqc_attribute12
      ,p_pqc_attribute13                =>  p_pqc_attribute13
      ,p_pqc_attribute14                =>  p_pqc_attribute14
      ,p_pqc_attribute15                =>  p_pqc_attribute15
      ,p_pqc_attribute16                =>  p_pqc_attribute16
      ,p_pqc_attribute17                =>  p_pqc_attribute17
      ,p_pqc_attribute18                =>  p_pqc_attribute18
      ,p_pqc_attribute19                =>  p_pqc_attribute19
      ,p_pqc_attribute20                =>  p_pqc_attribute20
      ,p_pqc_attribute21                =>  p_pqc_attribute21
      ,p_pqc_attribute22                =>  p_pqc_attribute22
      ,p_pqc_attribute23                =>  p_pqc_attribute23
      ,p_pqc_attribute24                =>  p_pqc_attribute24
      ,p_pqc_attribute25                =>  p_pqc_attribute25
      ,p_pqc_attribute26                =>  p_pqc_attribute26
      ,p_pqc_attribute27                =>  p_pqc_attribute27
      ,p_pqc_attribute28                =>  p_pqc_attribute28
      ,p_pqc_attribute29                =>  p_pqc_attribute29
      ,p_pqc_attribute30                =>  p_pqc_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_reimbmt_ctfn_prvdd'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_reimbmt_ctfn_prvdd
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
    ROLLBACK TO update_reimbmt_ctfn_prvdd;
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
    ROLLBACK TO update_reimbmt_ctfn_prvdd;
    raise;
    --
end update_reimbmt_ctfn_prvdd;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_reimbmt_ctfn_prvdd >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_reimbmt_ctfn_prvdd
  (p_validate                       in  boolean  default false
  ,p_prtt_rmt_rqst_ctfn_prvdd_id    in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_reimbmt_ctfn_prvdd';
  l_object_version_number ben_prtt_rmt_rqst_ctfn_prvdd_f.object_version_number%TYPE;
  l_effective_start_date ben_prtt_rmt_rqst_ctfn_prvdd_f.effective_start_date%TYPE;
  l_effective_end_date ben_prtt_rmt_rqst_ctfn_prvdd_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_reimbmt_ctfn_prvdd;
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
    -- Start of API User Hook for the before hook of delete_reimbmt_ctfn_prvdd
    --
    ben_reimbmt_ctfn_prvdd_bk3.delete_reimbmt_ctfn_prvdd_b
      (
       p_prtt_rmt_rqst_ctfn_prvdd_id    =>  p_prtt_rmt_rqst_ctfn_prvdd_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_reimbmt_ctfn_prvdd'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_reimbmt_ctfn_prvdd
    --
  end;
  --
  ben_pqc_del.del
    (
     p_prtt_rmt_rqst_ctfn_prvdd_id   => p_prtt_rmt_rqst_ctfn_prvdd_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_reimbmt_ctfn_prvdd
    --
    ben_reimbmt_ctfn_prvdd_bk3.delete_reimbmt_ctfn_prvdd_a
      (
       p_prtt_rmt_rqst_ctfn_prvdd_id    =>  p_prtt_rmt_rqst_ctfn_prvdd_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_reimbmt_ctfn_prvdd'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_reimbmt_ctfn_prvdd
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
    ROLLBACK TO delete_reimbmt_ctfn_prvdd;
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
    ROLLBACK TO delete_reimbmt_ctfn_prvdd;
    raise;
    --
end delete_reimbmt_ctfn_prvdd;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_prtt_rmt_rqst_ctfn_prvdd_id                   in     number
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
  ben_pqc_shd.lck
    (
      p_prtt_rmt_rqst_ctfn_prvdd_id                 => p_prtt_rmt_rqst_ctfn_prvdd_id
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
end ben_reimbmt_ctfn_prvdd_api;

/
