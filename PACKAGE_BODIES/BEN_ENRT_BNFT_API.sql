--------------------------------------------------------
--  DDL for Package Body BEN_ENRT_BNFT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ENRT_BNFT_API" as
/* $Header: beenbapi.pkb 115.11 2002/12/16 07:02:01 rpgupta ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_enrt_bnft_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_enrt_bnft >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_enrt_bnft
  (p_validate                       in  boolean   default false
  ,p_enrt_bnft_id                   out nocopy number
  ,p_dflt_flag                      in  varchar2  default 'N'
  ,p_val_has_bn_prortd_flag         in  varchar2  default 'N'
  ,p_bndry_perd_cd                  in  varchar2  default null
  ,p_val                            in  number    default null
  ,p_nnmntry_uom                    in  varchar2  default null
  ,p_bnft_typ_cd                    in  varchar2  default null
  ,p_entr_val_at_enrt_flag          in  varchar2  default 'N'
  ,p_mn_val                         in  number    default null
  ,p_mx_val                         in  number    default null
  ,p_incrmt_val                     in  number    default null
  ,p_dflt_val                       in  number    default null
  ,p_rt_typ_cd                      in  varchar2  default null
  ,p_cvg_mlt_cd                     in  varchar2  default null
  ,p_ctfn_rqd_flag                  in  varchar2  default 'N'
  ,p_ordr_num                       in  number    default null
  ,p_crntly_enrld_flag              in  varchar2  default 'N'
  ,p_elig_per_elctbl_chc_id         in  number    default null
  ,p_prtt_enrt_rslt_id              in  number    default null
  ,p_comp_lvl_fctr_id               in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_enb_attribute_category         in  varchar2  default null
  ,p_enb_attribute1                 in  varchar2  default null
  ,p_enb_attribute2                 in  varchar2  default null
  ,p_enb_attribute3                 in  varchar2  default null
  ,p_enb_attribute4                 in  varchar2  default null
  ,p_enb_attribute5                 in  varchar2  default null
  ,p_enb_attribute6                 in  varchar2  default null
  ,p_enb_attribute7                 in  varchar2  default null
  ,p_enb_attribute8                 in  varchar2  default null
  ,p_enb_attribute9                 in  varchar2  default null
  ,p_enb_attribute10                in  varchar2  default null
  ,p_enb_attribute11                in  varchar2  default null
  ,p_enb_attribute12                in  varchar2  default null
  ,p_enb_attribute13                in  varchar2  default null
  ,p_enb_attribute14                in  varchar2  default null
  ,p_enb_attribute15                in  varchar2  default null
  ,p_enb_attribute16                in  varchar2  default null
  ,p_enb_attribute17                in  varchar2  default null
  ,p_enb_attribute18                in  varchar2  default null
  ,p_enb_attribute19                in  varchar2  default null
  ,p_enb_attribute20                in  varchar2  default null
  ,p_enb_attribute21                in  varchar2  default null
  ,p_enb_attribute22                in  varchar2  default null
  ,p_enb_attribute23                in  varchar2  default null
  ,p_enb_attribute24                in  varchar2  default null
  ,p_enb_attribute25                in  varchar2  default null
  ,p_enb_attribute26                in  varchar2  default null
  ,p_enb_attribute27                in  varchar2  default null
  ,p_enb_attribute28                in  varchar2  default null
  ,p_enb_attribute29                in  varchar2  default null
  ,p_enb_attribute30                in  varchar2  default null
  ,p_request_id                     in  number    default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_program_update_date            in  date      default null
  ,p_mx_wout_ctfn_val               in  number    default null
  ,p_mx_wo_ctfn_flag                in  varchar2  default 'N'
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_enrt_bnft_id ben_enrt_bnft.enrt_bnft_id%TYPE;
  l_proc varchar2(72) := g_package||'create_enrt_bnft';
  l_object_version_number ben_enrt_bnft.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_enrt_bnft;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_enrt_bnft
    --
    ben_enrt_bnft_bk1.create_enrt_bnft_b
      (
       p_dflt_flag                    =>  p_dflt_flag
      ,p_val_has_bn_prortd_flag       =>  p_val_has_bn_prortd_flag
      ,p_bndry_perd_cd                =>  p_bndry_perd_cd
      ,p_val                          =>  p_val
      ,p_nnmntry_uom                  =>  p_nnmntry_uom
      ,p_bnft_typ_cd                  =>  p_bnft_typ_cd
      ,p_entr_val_at_enrt_flag        =>  p_entr_val_at_enrt_flag
      ,p_mn_val                       =>  p_mn_val
      ,p_mx_val                       =>  p_mx_val
      ,p_incrmt_val                   =>  p_incrmt_val
      ,p_dflt_val                     =>  p_dflt_val
      ,p_rt_typ_cd                    =>  p_rt_typ_cd
      ,p_cvg_mlt_cd                   =>  p_cvg_mlt_cd
      ,p_ctfn_rqd_flag                =>  p_ctfn_rqd_flag
      ,p_ordr_num                     =>  p_ordr_num
      ,p_crntly_enrld_flag            =>  p_crntly_enrld_flag
      ,p_elig_per_elctbl_chc_id       =>  p_elig_per_elctbl_chc_id
      ,p_prtt_enrt_rslt_id            =>  p_prtt_enrt_rslt_id
      ,p_comp_lvl_fctr_id             =>  p_comp_lvl_fctr_id
      ,p_business_group_id            =>  p_business_group_id
      ,p_enb_attribute_category       =>  p_enb_attribute_category
      ,p_enb_attribute1               =>  p_enb_attribute1
      ,p_enb_attribute2               =>  p_enb_attribute2
      ,p_enb_attribute3               =>  p_enb_attribute3
      ,p_enb_attribute4               =>  p_enb_attribute4
      ,p_enb_attribute5               =>  p_enb_attribute5
      ,p_enb_attribute6               =>  p_enb_attribute6
      ,p_enb_attribute7               =>  p_enb_attribute7
      ,p_enb_attribute8               =>  p_enb_attribute8
      ,p_enb_attribute9               =>  p_enb_attribute9
      ,p_enb_attribute10              =>  p_enb_attribute10
      ,p_enb_attribute11              =>  p_enb_attribute11
      ,p_enb_attribute12              =>  p_enb_attribute12
      ,p_enb_attribute13              =>  p_enb_attribute13
      ,p_enb_attribute14              =>  p_enb_attribute14
      ,p_enb_attribute15              =>  p_enb_attribute15
      ,p_enb_attribute16              =>  p_enb_attribute16
      ,p_enb_attribute17              =>  p_enb_attribute17
      ,p_enb_attribute18              =>  p_enb_attribute18
      ,p_enb_attribute19              =>  p_enb_attribute19
      ,p_enb_attribute20              =>  p_enb_attribute20
      ,p_enb_attribute21              =>  p_enb_attribute21
      ,p_enb_attribute22              =>  p_enb_attribute22
      ,p_enb_attribute23              =>  p_enb_attribute23
      ,p_enb_attribute24              =>  p_enb_attribute24
      ,p_enb_attribute25              =>  p_enb_attribute25
      ,p_enb_attribute26              =>  p_enb_attribute26
      ,p_enb_attribute27              =>  p_enb_attribute27
      ,p_enb_attribute28              =>  p_enb_attribute28
      ,p_enb_attribute29              =>  p_enb_attribute29
      ,p_enb_attribute30              =>  p_enb_attribute30
      ,p_request_id                   =>  p_request_id
      ,p_program_application_id       =>  p_program_application_id
      ,p_program_id                   =>  p_program_id
      ,p_program_update_date          =>  p_program_update_date
      ,p_mx_wout_ctfn_val             =>  p_mx_wout_ctfn_val
      ,p_mx_wo_ctfn_flag              =>  p_mx_wo_ctfn_flag
      ,p_object_version_number        =>  l_object_version_number
      ,p_effective_date               =>  trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_enrt_bnft'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_enrt_bnft
    --
  end;
  --
  ben_enb_ins.ins
    (
     p_effective_date                => trunc(p_effective_date)
    ,p_enrt_bnft_id                  => l_enrt_bnft_id
    ,p_dflt_flag                     => p_dflt_flag
    ,p_val_has_bn_prortd_flag        => p_val_has_bn_prortd_flag
    ,p_bndry_perd_cd                 => p_bndry_perd_cd
    ,p_val                           => p_val
    ,p_nnmntry_uom                   => p_nnmntry_uom
    ,p_bnft_typ_cd                   => p_bnft_typ_cd
    ,p_entr_val_at_enrt_flag         => p_entr_val_at_enrt_flag
    ,p_mn_val                        => p_mn_val
    ,p_mx_val                        => p_mx_val
    ,p_incrmt_val                    => p_incrmt_val
    ,p_dflt_val                      => p_dflt_val
    ,p_rt_typ_cd                     => p_rt_typ_cd
    ,p_cvg_mlt_cd                    => p_cvg_mlt_cd
    ,p_ctfn_rqd_flag                 => p_ctfn_rqd_flag
    ,p_ordr_num                      => p_ordr_num
    ,p_crntly_enrld_flag             => p_crntly_enrld_flag
    ,p_elig_per_elctbl_chc_id        => p_elig_per_elctbl_chc_id
    ,p_prtt_enrt_rslt_id             => p_prtt_enrt_rslt_id
    ,p_comp_lvl_fctr_id              => p_comp_lvl_fctr_id
    ,p_business_group_id             => p_business_group_id
    ,p_enb_attribute_category        => p_enb_attribute_category
    ,p_enb_attribute1                => p_enb_attribute1
    ,p_enb_attribute2                => p_enb_attribute2
    ,p_enb_attribute3                => p_enb_attribute3
    ,p_enb_attribute4                => p_enb_attribute4
    ,p_enb_attribute5                => p_enb_attribute5
    ,p_enb_attribute6                => p_enb_attribute6
    ,p_enb_attribute7                => p_enb_attribute7
    ,p_enb_attribute8                => p_enb_attribute8
    ,p_enb_attribute9                => p_enb_attribute9
    ,p_enb_attribute10               => p_enb_attribute10
    ,p_enb_attribute11               => p_enb_attribute11
    ,p_enb_attribute12               => p_enb_attribute12
    ,p_enb_attribute13               => p_enb_attribute13
    ,p_enb_attribute14               => p_enb_attribute14
    ,p_enb_attribute15               => p_enb_attribute15
    ,p_enb_attribute16               => p_enb_attribute16
    ,p_enb_attribute17               => p_enb_attribute17
    ,p_enb_attribute18               => p_enb_attribute18
    ,p_enb_attribute19               => p_enb_attribute19
    ,p_enb_attribute20               => p_enb_attribute20
    ,p_enb_attribute21               => p_enb_attribute21
    ,p_enb_attribute22               => p_enb_attribute22
    ,p_enb_attribute23               => p_enb_attribute23
    ,p_enb_attribute24               => p_enb_attribute24
    ,p_enb_attribute25               => p_enb_attribute25
    ,p_enb_attribute26               => p_enb_attribute26
    ,p_enb_attribute27               => p_enb_attribute27
    ,p_enb_attribute28               => p_enb_attribute28
    ,p_enb_attribute29               => p_enb_attribute29
    ,p_enb_attribute30               => p_enb_attribute30
    ,p_request_id                    => p_request_id
    ,p_program_application_id        => p_program_application_id
    ,p_program_id                    => p_program_id
    ,p_mx_wout_ctfn_val              => p_mx_wout_ctfn_val
    ,p_mx_wo_ctfn_flag               =>  p_mx_wo_ctfn_flag
    ,p_program_update_date           => p_program_update_date
    ,p_object_version_number         => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_enrt_bnft
    --
    ben_enrt_bnft_bk1.create_enrt_bnft_a
      (
       p_enrt_bnft_id                  => l_enrt_bnft_id
      ,p_dflt_flag                     => p_dflt_flag
      ,p_val_has_bn_prortd_flag        => p_val_has_bn_prortd_flag
      ,p_bndry_perd_cd                 => p_bndry_perd_cd
      ,p_val                           => p_val
      ,p_nnmntry_uom                   => p_nnmntry_uom
      ,p_bnft_typ_cd                   => p_bnft_typ_cd
      ,p_entr_val_at_enrt_flag         => p_entr_val_at_enrt_flag
      ,p_mn_val                        => p_mn_val
      ,p_mx_val                        => p_mx_val
      ,p_incrmt_val                    => p_incrmt_val
      ,p_dflt_val                      => p_dflt_val
      ,p_rt_typ_cd                     => p_rt_typ_cd
      ,p_cvg_mlt_cd                    => p_cvg_mlt_cd
      ,p_ctfn_rqd_flag                 => p_ctfn_rqd_flag
      ,p_ordr_num                      => p_ordr_num
      ,p_crntly_enrld_flag             => p_crntly_enrld_flag
      ,p_elig_per_elctbl_chc_id        => p_elig_per_elctbl_chc_id
      ,p_prtt_enrt_rslt_id             => p_prtt_enrt_rslt_id
      ,p_comp_lvl_fctr_id              => p_comp_lvl_fctr_id
      ,p_business_group_id             => p_business_group_id
      ,p_enb_attribute_category        => p_enb_attribute_category
      ,p_enb_attribute1                => p_enb_attribute1
      ,p_enb_attribute2                => p_enb_attribute2
      ,p_enb_attribute3                => p_enb_attribute3
      ,p_enb_attribute4                => p_enb_attribute4
      ,p_enb_attribute5                => p_enb_attribute5
      ,p_enb_attribute6                => p_enb_attribute6
      ,p_enb_attribute7                => p_enb_attribute7
      ,p_enb_attribute8                => p_enb_attribute8
      ,p_enb_attribute9                => p_enb_attribute9
      ,p_enb_attribute10               => p_enb_attribute10
      ,p_enb_attribute11               => p_enb_attribute11
      ,p_enb_attribute12               => p_enb_attribute12
      ,p_enb_attribute13               => p_enb_attribute13
      ,p_enb_attribute14               => p_enb_attribute14
      ,p_enb_attribute15               => p_enb_attribute15
      ,p_enb_attribute16               => p_enb_attribute16
      ,p_enb_attribute17               => p_enb_attribute17
      ,p_enb_attribute18               => p_enb_attribute18
      ,p_enb_attribute19               => p_enb_attribute19
      ,p_enb_attribute20               => p_enb_attribute20
      ,p_enb_attribute21               => p_enb_attribute21
      ,p_enb_attribute22               => p_enb_attribute22
      ,p_enb_attribute23               => p_enb_attribute23
      ,p_enb_attribute24               => p_enb_attribute24
      ,p_enb_attribute25               => p_enb_attribute25
      ,p_enb_attribute26               => p_enb_attribute26
      ,p_enb_attribute27               => p_enb_attribute27
      ,p_enb_attribute28               => p_enb_attribute28
      ,p_enb_attribute29               => p_enb_attribute29
      ,p_enb_attribute30               => p_enb_attribute30
      ,p_request_id                    => p_request_id
      ,p_program_application_id        => p_program_application_id
      ,p_program_id                    => p_program_id
      ,p_program_update_date           => p_program_update_date
      ,p_mx_wout_ctfn_val              => p_mx_wout_ctfn_val
      ,p_mx_wo_ctfn_flag               => p_mx_wo_ctfn_flag
      ,p_object_version_number         => l_object_version_number
      ,p_effective_date                => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_enrt_bnft'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_enrt_bnft
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
  p_enrt_bnft_id := l_enrt_bnft_id;
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
    ROLLBACK TO create_enrt_bnft;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_enrt_bnft_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_enrt_bnft;
    p_enrt_bnft_id := null; --nocopy change
    p_object_version_number  := null; --nocopy change
    raise;
    --
end create_enrt_bnft;

-- ----------------------------------------------------------------------------
-- |------------------------< update_enrt_bnft >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_enrt_bnft
  (
   p_validate                       in  boolean   default false
  ,p_enrt_bnft_id                   in  number
  ,p_dflt_flag                      in  varchar2  default hr_api.g_varchar2
  ,p_val_has_bn_prortd_flag         in  varchar2  default hr_api.g_varchar2
  ,p_bndry_perd_cd                  in  varchar2  default hr_api.g_varchar2
  ,p_val                            in  number    default hr_api.g_number
  ,p_nnmntry_uom                    in  varchar2  default hr_api.g_varchar2
  ,p_bnft_typ_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_entr_val_at_enrt_flag          in  varchar2  default hr_api.g_varchar2
  ,p_mn_val                         in  number    default hr_api.g_number
  ,p_mx_val                         in  number    default hr_api.g_number
  ,p_incrmt_val                     in  number    default hr_api.g_number
  ,p_dflt_val                       in  number    default hr_api.g_number
  ,p_rt_typ_cd                      in  varchar2  default hr_api.g_varchar2
  ,p_cvg_mlt_cd                     in  varchar2  default hr_api.g_varchar2
  ,p_ctfn_rqd_flag                  in  varchar2  default hr_api.g_varchar2
  ,p_ordr_num                       in  number    default hr_api.g_number
  ,p_crntly_enrld_flag              in  varchar2  default hr_api.g_varchar2
  ,p_elig_per_elctbl_chc_id         in  number    default hr_api.g_number
  ,p_prtt_enrt_rslt_id              in  number    default hr_api.g_number
  ,p_comp_lvl_fctr_id               in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_enb_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_enb_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_request_id                     in  number    default hr_api.g_number
  ,p_program_application_id         in  number    default hr_api.g_number
  ,p_program_id                     in  number    default hr_api.g_number
  ,p_program_update_date            in  date      default hr_api.g_date
  ,p_mx_wout_ctfn_val               in  number    default hr_api.g_number
  ,p_mx_wo_ctfn_flag                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_enrt_bnft';
  l_object_version_number ben_enrt_bnft.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_enrt_bnft;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_enrt_bnft
    --
    ben_enrt_bnft_bk2.update_enrt_bnft_b
      (
       p_enrt_bnft_id                  => p_enrt_bnft_id
      ,p_dflt_flag                     => p_dflt_flag
      ,p_val_has_bn_prortd_flag        => p_val_has_bn_prortd_flag
      ,p_bndry_perd_cd                 => p_bndry_perd_cd
      ,p_val                           => p_val
      ,p_nnmntry_uom                   => p_nnmntry_uom
      ,p_bnft_typ_cd                   => p_bnft_typ_cd
      ,p_entr_val_at_enrt_flag         => p_entr_val_at_enrt_flag
      ,p_mn_val                        => p_mn_val
      ,p_mx_val                        => p_mx_val
      ,p_incrmt_val                    => p_incrmt_val
      ,p_dflt_val                      => p_dflt_val
      ,p_rt_typ_cd                     => p_rt_typ_cd
      ,p_cvg_mlt_cd                    => p_cvg_mlt_cd
      ,p_ctfn_rqd_flag                 => p_ctfn_rqd_flag
      ,p_ordr_num                      => p_ordr_num
      ,p_crntly_enrld_flag             => p_crntly_enrld_flag
      ,p_elig_per_elctbl_chc_id        => p_elig_per_elctbl_chc_id
      ,p_prtt_enrt_rslt_id             => p_prtt_enrt_rslt_id
      ,p_comp_lvl_fctr_id              => p_comp_lvl_fctr_id
      ,p_business_group_id             => p_business_group_id
      ,p_enb_attribute_category        => p_enb_attribute_category
      ,p_enb_attribute1                => p_enb_attribute1
      ,p_enb_attribute2                => p_enb_attribute2
      ,p_enb_attribute3                => p_enb_attribute3
      ,p_enb_attribute4                => p_enb_attribute4
      ,p_enb_attribute5                => p_enb_attribute5
      ,p_enb_attribute6                => p_enb_attribute6
      ,p_enb_attribute7                => p_enb_attribute7
      ,p_enb_attribute8                => p_enb_attribute8
      ,p_enb_attribute9                => p_enb_attribute9
      ,p_enb_attribute10               => p_enb_attribute10
      ,p_enb_attribute11               => p_enb_attribute11
      ,p_enb_attribute12               => p_enb_attribute12
      ,p_enb_attribute13               => p_enb_attribute13
      ,p_enb_attribute14               => p_enb_attribute14
      ,p_enb_attribute15               => p_enb_attribute15
      ,p_enb_attribute16               => p_enb_attribute16
      ,p_enb_attribute17               => p_enb_attribute17
      ,p_enb_attribute18               => p_enb_attribute18
      ,p_enb_attribute19               => p_enb_attribute19
      ,p_enb_attribute20               => p_enb_attribute20
      ,p_enb_attribute21               => p_enb_attribute21
      ,p_enb_attribute22               => p_enb_attribute22
      ,p_enb_attribute23               => p_enb_attribute23
      ,p_enb_attribute24               => p_enb_attribute24
      ,p_enb_attribute25               => p_enb_attribute25
      ,p_enb_attribute26               => p_enb_attribute26
      ,p_enb_attribute27               => p_enb_attribute27
      ,p_enb_attribute28               => p_enb_attribute28
      ,p_enb_attribute29               => p_enb_attribute29
      ,p_enb_attribute30               => p_enb_attribute30
      ,p_request_id                    => p_request_id
      ,p_program_application_id        => p_program_application_id
      ,p_program_id                    => p_program_id
      ,p_program_update_date           => p_program_update_date
      ,p_mx_wout_ctfn_val              => p_mx_wout_ctfn_val
      ,p_mx_wo_ctfn_flag               => p_mx_wo_ctfn_flag
      ,p_object_version_number         => l_object_version_number
      ,p_effective_date                => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_enrt_bnft'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_enrt_bnft
    --
  end;
  --
  ben_enb_upd.upd
    (
       p_enrt_bnft_id                  => p_enrt_bnft_id
      ,p_dflt_flag                     => p_dflt_flag
      ,p_val_has_bn_prortd_flag        => p_val_has_bn_prortd_flag
      ,p_bndry_perd_cd                 => p_bndry_perd_cd
      ,p_val                           => p_val
      ,p_nnmntry_uom                   => p_nnmntry_uom
      ,p_bnft_typ_cd                   => p_bnft_typ_cd
      ,p_entr_val_at_enrt_flag         => p_entr_val_at_enrt_flag
      ,p_mn_val                        => p_mn_val
      ,p_mx_val                        => p_mx_val
      ,p_incrmt_val                    => p_incrmt_val
      ,p_dflt_val                      => p_dflt_val
      ,p_rt_typ_cd                     => p_rt_typ_cd
      ,p_cvg_mlt_cd                    => p_cvg_mlt_cd
      ,p_ctfn_rqd_flag                 => p_ctfn_rqd_flag
      ,p_ordr_num                      => p_ordr_num
      ,p_crntly_enrld_flag             => p_crntly_enrld_flag
      ,p_elig_per_elctbl_chc_id        => p_elig_per_elctbl_chc_id
      ,p_prtt_enrt_rslt_id             => p_prtt_enrt_rslt_id
      ,p_comp_lvl_fctr_id              => p_comp_lvl_fctr_id
      ,p_business_group_id             => p_business_group_id
      ,p_enb_attribute_category        => p_enb_attribute_category
      ,p_enb_attribute1                => p_enb_attribute1
      ,p_enb_attribute2                => p_enb_attribute2
      ,p_enb_attribute3                => p_enb_attribute3
      ,p_enb_attribute4                => p_enb_attribute4
      ,p_enb_attribute5                => p_enb_attribute5
      ,p_enb_attribute6                => p_enb_attribute6
      ,p_enb_attribute7                => p_enb_attribute7
      ,p_enb_attribute8                => p_enb_attribute8
      ,p_enb_attribute9                => p_enb_attribute9
      ,p_enb_attribute10               => p_enb_attribute10
      ,p_enb_attribute11               => p_enb_attribute11
      ,p_enb_attribute12               => p_enb_attribute12
      ,p_enb_attribute13               => p_enb_attribute13
      ,p_enb_attribute14               => p_enb_attribute14
      ,p_enb_attribute15               => p_enb_attribute15
      ,p_enb_attribute16               => p_enb_attribute16
      ,p_enb_attribute17               => p_enb_attribute17
      ,p_enb_attribute18               => p_enb_attribute18
      ,p_enb_attribute19               => p_enb_attribute19
      ,p_enb_attribute20               => p_enb_attribute20
      ,p_enb_attribute21               => p_enb_attribute21
      ,p_enb_attribute22               => p_enb_attribute22
      ,p_enb_attribute23               => p_enb_attribute23
      ,p_enb_attribute24               => p_enb_attribute24
      ,p_enb_attribute25               => p_enb_attribute25
      ,p_enb_attribute26               => p_enb_attribute26
      ,p_enb_attribute27               => p_enb_attribute27
      ,p_enb_attribute28               => p_enb_attribute28
      ,p_enb_attribute29               => p_enb_attribute29
      ,p_enb_attribute30               => p_enb_attribute30
      ,p_request_id                    => p_request_id
      ,p_program_application_id        => p_program_application_id
      ,p_program_id                    => p_program_id
      ,p_program_update_date           => p_program_update_date
      ,p_mx_wout_ctfn_val              => p_mx_wout_ctfn_val
      ,p_mx_wo_ctfn_flag               => p_mx_wo_ctfn_flag
      ,p_object_version_number         => l_object_version_number
      ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_enrt_bnft
    --
    ben_enrt_bnft_bk2.update_enrt_bnft_a
      (
       p_enrt_bnft_id                  => p_enrt_bnft_id
      ,p_dflt_flag                     => p_dflt_flag
      ,p_val_has_bn_prortd_flag        => p_val_has_bn_prortd_flag
      ,p_bndry_perd_cd                 => p_bndry_perd_cd
      ,p_val                           => p_val
      ,p_nnmntry_uom                   => p_nnmntry_uom
      ,p_bnft_typ_cd                   => p_bnft_typ_cd
      ,p_entr_val_at_enrt_flag         => p_entr_val_at_enrt_flag
      ,p_mn_val                        => p_mn_val
      ,p_mx_val                        => p_mx_val
      ,p_incrmt_val                    => p_incrmt_val
      ,p_dflt_val                      => p_dflt_val
      ,p_rt_typ_cd                     => p_rt_typ_cd
      ,p_cvg_mlt_cd                    => p_cvg_mlt_cd
      ,p_ctfn_rqd_flag                 => p_ctfn_rqd_flag
      ,p_ordr_num                      => p_ordr_num
      ,p_crntly_enrld_flag             => p_crntly_enrld_flag
      ,p_elig_per_elctbl_chc_id        => p_elig_per_elctbl_chc_id
      ,p_prtt_enrt_rslt_id             => p_prtt_enrt_rslt_id
      ,p_comp_lvl_fctr_id              => p_comp_lvl_fctr_id
      ,p_business_group_id             => p_business_group_id
      ,p_enb_attribute_category        => p_enb_attribute_category
      ,p_enb_attribute1                => p_enb_attribute1
      ,p_enb_attribute2                => p_enb_attribute2
      ,p_enb_attribute3                => p_enb_attribute3
      ,p_enb_attribute4                => p_enb_attribute4
      ,p_enb_attribute5                => p_enb_attribute5
      ,p_enb_attribute6                => p_enb_attribute6
      ,p_enb_attribute7                => p_enb_attribute7
      ,p_enb_attribute8                => p_enb_attribute8
      ,p_enb_attribute9                => p_enb_attribute9
      ,p_enb_attribute10               => p_enb_attribute10
      ,p_enb_attribute11               => p_enb_attribute11
      ,p_enb_attribute12               => p_enb_attribute12
      ,p_enb_attribute13               => p_enb_attribute13
      ,p_enb_attribute14               => p_enb_attribute14
      ,p_enb_attribute15               => p_enb_attribute15
      ,p_enb_attribute16               => p_enb_attribute16
      ,p_enb_attribute17               => p_enb_attribute17
      ,p_enb_attribute18               => p_enb_attribute18
      ,p_enb_attribute19               => p_enb_attribute19
      ,p_enb_attribute20               => p_enb_attribute20
      ,p_enb_attribute21               => p_enb_attribute21
      ,p_enb_attribute22               => p_enb_attribute22
      ,p_enb_attribute23               => p_enb_attribute23
      ,p_enb_attribute24               => p_enb_attribute24
      ,p_enb_attribute25               => p_enb_attribute25
      ,p_enb_attribute26               => p_enb_attribute26
      ,p_enb_attribute27               => p_enb_attribute27
      ,p_enb_attribute28               => p_enb_attribute28
      ,p_enb_attribute29               => p_enb_attribute29
      ,p_enb_attribute30               => p_enb_attribute30
      ,p_request_id                    => p_request_id
      ,p_program_application_id        => p_program_application_id
      ,p_program_id                    => p_program_id
      ,p_program_update_date           => p_program_update_date
      ,p_mx_wout_ctfn_val              => p_mx_wout_ctfn_val
      ,p_mx_wo_ctfn_flag               => p_mx_wo_ctfn_flag
      ,p_object_version_number         => l_object_version_number
      ,p_effective_date                => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_enrt_bnft'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_enrt_bnft
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
    ROLLBACK TO update_enrt_bnft;
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
    ROLLBACK TO update_enrt_bnft;
    p_object_version_number := l_object_version_number; --nocopy change
    raise;
    --
end update_enrt_bnft;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_enrt_bnft >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_enrt_bnft
  (p_validate                       in  boolean  default false
  ,p_enrt_bnft_id                   in  number
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_enrt_bnft';
  l_object_version_number ben_enrt_bnft.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_enrt_bnft;
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
    -- Start of API User Hook for the before hook of delete_enrt_bnft
    --
    ben_enrt_bnft_bk3.delete_enrt_bnft_b
      (
       p_enrt_bnft_id                   =>  p_enrt_bnft_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_enrt_bnft'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_enrt_bnft
    --
  end;
  --
  ben_enb_del.del
    (
     p_enrt_bnft_id                  => p_enrt_bnft_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_enrt_bnft
    --
    ben_enrt_bnft_bk3.delete_enrt_bnft_a
      (
       p_enrt_bnft_id                   =>  p_enrt_bnft_id
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_enrt_bnft'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_enrt_bnft
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
    ROLLBACK TO delete_enrt_bnft;
    p_object_version_number := l_object_version_number; --nocopy change
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_enrt_bnft;
    p_object_version_number := l_object_version_number; --nocopy change
    raise;
    --
end delete_enrt_bnft;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_enrt_bnft_id                   in     number
  ,p_object_version_number          in     number
  ) is
  --
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'lck';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  ben_enb_shd.lck
    (
      p_enrt_bnft_id                 => p_enrt_bnft_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end ben_enrt_bnft_api;

/
