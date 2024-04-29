--------------------------------------------------------
--  DDL for Package Body BEN_BENEFIT_PRVDR_POOL_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BENEFIT_PRVDR_POOL_API" as
/* $Header: bebppapi.pkb 120.0 2005/05/28 00:48:09 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_Benefit_Prvdr_Pool_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_Benefit_Prvdr_Pool >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_Benefit_Prvdr_Pool
  (p_validate                       in  boolean   default false
  ,p_bnft_prvdr_pool_id             out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_name                           in  varchar2  default null
  ,p_pgm_pool_flag                  in  varchar2  default 'N'
  ,p_excs_alwys_fftd_flag           in  varchar2  default 'N'
  ,p_use_for_pgm_pool_flag          in  varchar2  default 'N'
  ,p_pct_rndg_cd                    in  varchar2  default null
  ,p_pct_rndg_rl                    in  number    default null
  ,p_val_rndg_cd                    in  varchar2  default null
  ,p_val_rndg_rl                    in  number    default null
  ,p_dflt_excs_trtmt_cd             in  varchar2  default null
  ,p_dflt_excs_trtmt_rl             in  number    default null
  ,p_rlovr_rstrcn_cd                in  varchar2  default null
  ,p_no_mn_dstrbl_pct_flag          in  varchar2  default 'N'
  ,p_no_mn_dstrbl_val_flag          in  varchar2  default 'N'
  ,p_no_mx_dstrbl_pct_flag          in  varchar2  default 'N'
  ,p_no_mx_dstrbl_val_flag          in  varchar2  default 'N'
  ,p_auto_alct_excs_flag            in  varchar2  default 'N'
  ,p_alws_ngtv_crs_flag             in  varchar2  default 'N'
  ,p_uses_net_crs_mthd_flag         in  varchar2  default 'N'
  ,p_mx_dfcit_pct_pool_crs_num      in  number    default null
  ,p_mx_dfcit_pct_comp_num          in  number    default null
  ,p_comp_lvl_fctr_id               in  number    default null
  ,p_mn_dstrbl_pct_num              in  number    default null
  ,p_mn_dstrbl_val                  in  number    default null
  ,p_mx_dstrbl_pct_num              in  number    default null
  ,p_mx_dstrbl_val                  in  number    default null
  ,p_excs_trtmt_cd                  in  varchar2  default null
  ,p_ptip_id                        in  number    default null
  ,p_plip_id                        in  number    default null
  ,p_pgm_id                         in  number    default null
  ,p_oiplip_id                      in  number    default null
  ,p_cmbn_plip_id                   in  number    default null
  ,p_cmbn_ptip_id                   in  number    default null
  ,p_cmbn_ptip_opt_id               in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_bpp_attribute_category         in  varchar2  default null
  ,p_bpp_attribute1                 in  varchar2  default null
  ,p_bpp_attribute2                 in  varchar2  default null
  ,p_bpp_attribute3                 in  varchar2  default null
  ,p_bpp_attribute4                 in  varchar2  default null
  ,p_bpp_attribute5                 in  varchar2  default null
  ,p_bpp_attribute6                 in  varchar2  default null
  ,p_bpp_attribute7                 in  varchar2  default null
  ,p_bpp_attribute8                 in  varchar2  default null
  ,p_bpp_attribute9                 in  varchar2  default null
  ,p_bpp_attribute10                in  varchar2  default null
  ,p_bpp_attribute11                in  varchar2  default null
  ,p_bpp_attribute12                in  varchar2  default null
  ,p_bpp_attribute13                in  varchar2  default null
  ,p_bpp_attribute14                in  varchar2  default null
  ,p_bpp_attribute15                in  varchar2  default null
  ,p_bpp_attribute16                in  varchar2  default null
  ,p_bpp_attribute17                in  varchar2  default null
  ,p_bpp_attribute18                in  varchar2  default null
  ,p_bpp_attribute19                in  varchar2  default null
  ,p_bpp_attribute20                in  varchar2  default null
  ,p_bpp_attribute21                in  varchar2  default null
  ,p_bpp_attribute22                in  varchar2  default null
  ,p_bpp_attribute23                in  varchar2  default null
  ,p_bpp_attribute24                in  varchar2  default null
  ,p_bpp_attribute25                in  varchar2  default null
  ,p_bpp_attribute26                in  varchar2  default null
  ,p_bpp_attribute27                in  varchar2  default null
  ,p_bpp_attribute28                in  varchar2  default null
  ,p_bpp_attribute29                in  varchar2  default null
  ,p_bpp_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_bnft_prvdr_pool_id ben_bnft_prvdr_pool_f.bnft_prvdr_pool_id%TYPE;
  l_effective_start_date ben_bnft_prvdr_pool_f.effective_start_date%TYPE;
  l_effective_end_date ben_bnft_prvdr_pool_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_Benefit_Prvdr_Pool';
  l_object_version_number ben_bnft_prvdr_pool_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_Benefit_Prvdr_Pool;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_Benefit_Prvdr_Pool
    --
    ben_Benefit_Prvdr_Pool_bk1.create_Benefit_Prvdr_Pool_b
      (
       p_name                           =>  p_name
      ,p_pgm_pool_flag                  =>  p_pgm_pool_flag
      ,p_excs_alwys_fftd_flag           =>  p_excs_alwys_fftd_flag
      ,p_use_for_pgm_pool_flag          =>  p_use_for_pgm_pool_flag
      ,p_pct_rndg_cd                    =>  p_pct_rndg_cd
      ,p_pct_rndg_rl                    =>  p_pct_rndg_rl
      ,p_val_rndg_cd                    =>  p_val_rndg_cd
      ,p_val_rndg_rl                    =>  p_val_rndg_rl
      ,p_dflt_excs_trtmt_cd             =>  p_dflt_excs_trtmt_cd
      ,p_dflt_excs_trtmt_rl             =>  p_dflt_excs_trtmt_rl
      ,p_rlovr_rstrcn_cd                =>  p_rlovr_rstrcn_cd
      ,p_no_mn_dstrbl_pct_flag          =>  p_no_mn_dstrbl_pct_flag
      ,p_no_mn_dstrbl_val_flag          =>  p_no_mn_dstrbl_val_flag
      ,p_no_mx_dstrbl_pct_flag          =>  p_no_mx_dstrbl_pct_flag
      ,p_no_mx_dstrbl_val_flag          =>  p_no_mx_dstrbl_val_flag
      ,p_auto_alct_excs_flag            =>  p_auto_alct_excs_flag
      ,p_alws_ngtv_crs_flag             =>  p_alws_ngtv_crs_flag
      ,p_uses_net_crs_mthd_flag         =>  p_uses_net_crs_mthd_flag
      ,p_mx_dfcit_pct_pool_crs_num      =>  p_mx_dfcit_pct_pool_crs_num
      ,p_mx_dfcit_pct_comp_num          =>  p_mx_dfcit_pct_comp_num
      ,p_comp_lvl_fctr_id               =>  p_comp_lvl_fctr_id
      ,p_mn_dstrbl_pct_num              =>  p_mn_dstrbl_pct_num
      ,p_mn_dstrbl_val                  =>  p_mn_dstrbl_val
      ,p_mx_dstrbl_pct_num              =>  p_mx_dstrbl_pct_num
      ,p_mx_dstrbl_val                  =>  p_mx_dstrbl_val
      ,p_excs_trtmt_cd                  =>  p_excs_trtmt_cd
      ,p_ptip_id                        =>  p_ptip_id
      ,p_plip_id                        =>  p_plip_id
      ,p_pgm_id                         =>  p_pgm_id
      ,p_oiplip_id                      =>  p_oiplip_id
      ,p_cmbn_plip_id                   =>  p_cmbn_plip_id
      ,p_cmbn_ptip_id                   =>  p_cmbn_ptip_id
      ,p_cmbn_ptip_opt_id               =>  p_cmbn_ptip_opt_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_bpp_attribute_category         =>  p_bpp_attribute_category
      ,p_bpp_attribute1                 =>  p_bpp_attribute1
      ,p_bpp_attribute2                 =>  p_bpp_attribute2
      ,p_bpp_attribute3                 =>  p_bpp_attribute3
      ,p_bpp_attribute4                 =>  p_bpp_attribute4
      ,p_bpp_attribute5                 =>  p_bpp_attribute5
      ,p_bpp_attribute6                 =>  p_bpp_attribute6
      ,p_bpp_attribute7                 =>  p_bpp_attribute7
      ,p_bpp_attribute8                 =>  p_bpp_attribute8
      ,p_bpp_attribute9                 =>  p_bpp_attribute9
      ,p_bpp_attribute10                =>  p_bpp_attribute10
      ,p_bpp_attribute11                =>  p_bpp_attribute11
      ,p_bpp_attribute12                =>  p_bpp_attribute12
      ,p_bpp_attribute13                =>  p_bpp_attribute13
      ,p_bpp_attribute14                =>  p_bpp_attribute14
      ,p_bpp_attribute15                =>  p_bpp_attribute15
      ,p_bpp_attribute16                =>  p_bpp_attribute16
      ,p_bpp_attribute17                =>  p_bpp_attribute17
      ,p_bpp_attribute18                =>  p_bpp_attribute18
      ,p_bpp_attribute19                =>  p_bpp_attribute19
      ,p_bpp_attribute20                =>  p_bpp_attribute20
      ,p_bpp_attribute21                =>  p_bpp_attribute21
      ,p_bpp_attribute22                =>  p_bpp_attribute22
      ,p_bpp_attribute23                =>  p_bpp_attribute23
      ,p_bpp_attribute24                =>  p_bpp_attribute24
      ,p_bpp_attribute25                =>  p_bpp_attribute25
      ,p_bpp_attribute26                =>  p_bpp_attribute26
      ,p_bpp_attribute27                =>  p_bpp_attribute27
      ,p_bpp_attribute28                =>  p_bpp_attribute28
      ,p_bpp_attribute29                =>  p_bpp_attribute29
      ,p_bpp_attribute30                =>  p_bpp_attribute30
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_Benefit_Prvdr_Pool'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_Benefit_Prvdr_Pool
    --
  end;
  --
  ben_bpp_ins.ins
    (
     p_bnft_prvdr_pool_id            => l_bnft_prvdr_pool_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_name                          => p_name
    ,p_pgm_pool_flag                 => p_pgm_pool_flag
    ,p_excs_alwys_fftd_flag          => p_excs_alwys_fftd_flag
    ,p_use_for_pgm_pool_flag         => p_use_for_pgm_pool_flag
    ,p_pct_rndg_cd                   => p_pct_rndg_cd
    ,p_pct_rndg_rl                   => p_pct_rndg_rl
    ,p_val_rndg_cd                   => p_val_rndg_cd
    ,p_val_rndg_rl                   => p_val_rndg_rl
    ,p_dflt_excs_trtmt_cd            => p_dflt_excs_trtmt_cd
    ,p_dflt_excs_trtmt_rl            => p_dflt_excs_trtmt_rl
    ,p_rlovr_rstrcn_cd               => p_rlovr_rstrcn_cd
    ,p_no_mn_dstrbl_pct_flag         => p_no_mn_dstrbl_pct_flag
    ,p_no_mn_dstrbl_val_flag         => p_no_mn_dstrbl_val_flag
    ,p_no_mx_dstrbl_pct_flag         => p_no_mx_dstrbl_pct_flag
    ,p_no_mx_dstrbl_val_flag         => p_no_mx_dstrbl_val_flag
    ,p_auto_alct_excs_flag           => p_auto_alct_excs_flag
    ,p_alws_ngtv_crs_flag            => p_alws_ngtv_crs_flag
    ,p_uses_net_crs_mthd_flag        => p_uses_net_crs_mthd_flag
    ,p_mx_dfcit_pct_pool_crs_num     => p_mx_dfcit_pct_pool_crs_num
    ,p_mx_dfcit_pct_comp_num         => p_mx_dfcit_pct_comp_num
    ,p_comp_lvl_fctr_id              => p_comp_lvl_fctr_id
    ,p_mn_dstrbl_pct_num             => p_mn_dstrbl_pct_num
    ,p_mn_dstrbl_val                 => p_mn_dstrbl_val
    ,p_mx_dstrbl_pct_num             => p_mx_dstrbl_pct_num
    ,p_mx_dstrbl_val                 => p_mx_dstrbl_val
    ,p_excs_trtmt_cd                 => p_excs_trtmt_cd
    ,p_ptip_id                       => p_ptip_id
    ,p_plip_id                       => p_plip_id
    ,p_pgm_id                        => p_pgm_id
    ,p_oiplip_id                     => p_oiplip_id
    ,p_cmbn_plip_id                  => p_cmbn_plip_id
    ,p_cmbn_ptip_id                  => p_cmbn_ptip_id
    ,p_cmbn_ptip_opt_id              => p_cmbn_ptip_opt_id
    ,p_business_group_id             => p_business_group_id
    ,p_bpp_attribute_category        => p_bpp_attribute_category
    ,p_bpp_attribute1                => p_bpp_attribute1
    ,p_bpp_attribute2                => p_bpp_attribute2
    ,p_bpp_attribute3                => p_bpp_attribute3
    ,p_bpp_attribute4                => p_bpp_attribute4
    ,p_bpp_attribute5                => p_bpp_attribute5
    ,p_bpp_attribute6                => p_bpp_attribute6
    ,p_bpp_attribute7                => p_bpp_attribute7
    ,p_bpp_attribute8                => p_bpp_attribute8
    ,p_bpp_attribute9                => p_bpp_attribute9
    ,p_bpp_attribute10               => p_bpp_attribute10
    ,p_bpp_attribute11               => p_bpp_attribute11
    ,p_bpp_attribute12               => p_bpp_attribute12
    ,p_bpp_attribute13               => p_bpp_attribute13
    ,p_bpp_attribute14               => p_bpp_attribute14
    ,p_bpp_attribute15               => p_bpp_attribute15
    ,p_bpp_attribute16               => p_bpp_attribute16
    ,p_bpp_attribute17               => p_bpp_attribute17
    ,p_bpp_attribute18               => p_bpp_attribute18
    ,p_bpp_attribute19               => p_bpp_attribute19
    ,p_bpp_attribute20               => p_bpp_attribute20
    ,p_bpp_attribute21               => p_bpp_attribute21
    ,p_bpp_attribute22               => p_bpp_attribute22
    ,p_bpp_attribute23               => p_bpp_attribute23
    ,p_bpp_attribute24               => p_bpp_attribute24
    ,p_bpp_attribute25               => p_bpp_attribute25
    ,p_bpp_attribute26               => p_bpp_attribute26
    ,p_bpp_attribute27               => p_bpp_attribute27
    ,p_bpp_attribute28               => p_bpp_attribute28
    ,p_bpp_attribute29               => p_bpp_attribute29
    ,p_bpp_attribute30               => p_bpp_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_Benefit_Prvdr_Pool
    --
    ben_Benefit_Prvdr_Pool_bk1.create_Benefit_Prvdr_Pool_a
      (
       p_bnft_prvdr_pool_id             =>  l_bnft_prvdr_pool_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_name                           =>  p_name
      ,p_pgm_pool_flag                  =>  p_pgm_pool_flag
      ,p_excs_alwys_fftd_flag           =>  p_excs_alwys_fftd_flag
      ,p_use_for_pgm_pool_flag          =>  p_use_for_pgm_pool_flag
      ,p_pct_rndg_cd                    =>  p_pct_rndg_cd
      ,p_pct_rndg_rl                    =>  p_pct_rndg_rl
      ,p_val_rndg_cd                    =>  p_val_rndg_cd
      ,p_val_rndg_rl                    =>  p_val_rndg_rl
      ,p_dflt_excs_trtmt_cd             =>  p_dflt_excs_trtmt_cd
      ,p_dflt_excs_trtmt_rl             =>  p_dflt_excs_trtmt_rl
      ,p_rlovr_rstrcn_cd                =>  p_rlovr_rstrcn_cd
      ,p_no_mn_dstrbl_pct_flag          =>  p_no_mn_dstrbl_pct_flag
      ,p_no_mn_dstrbl_val_flag          =>  p_no_mn_dstrbl_val_flag
      ,p_no_mx_dstrbl_pct_flag          =>  p_no_mx_dstrbl_pct_flag
      ,p_no_mx_dstrbl_val_flag          =>  p_no_mx_dstrbl_val_flag
      ,p_auto_alct_excs_flag            =>  p_auto_alct_excs_flag
      ,p_alws_ngtv_crs_flag             =>  p_alws_ngtv_crs_flag
      ,p_uses_net_crs_mthd_flag         =>  p_uses_net_crs_mthd_flag
      ,p_mx_dfcit_pct_pool_crs_num      =>  p_mx_dfcit_pct_pool_crs_num
      ,p_mx_dfcit_pct_comp_num          =>  p_mx_dfcit_pct_comp_num
      ,p_comp_lvl_fctr_id               =>  p_comp_lvl_fctr_id
      ,p_mn_dstrbl_pct_num              =>  p_mn_dstrbl_pct_num
      ,p_mn_dstrbl_val                  =>  p_mn_dstrbl_val
      ,p_mx_dstrbl_pct_num              =>  p_mx_dstrbl_pct_num
      ,p_mx_dstrbl_val                  =>  p_mx_dstrbl_val
      ,p_excs_trtmt_cd                  =>  p_excs_trtmt_cd
      ,p_ptip_id                        =>  p_ptip_id
      ,p_plip_id                        =>  p_plip_id
      ,p_pgm_id                         =>  p_pgm_id
      ,p_oiplip_id                      =>  p_oiplip_id
      ,p_cmbn_plip_id                   =>  p_cmbn_plip_id
      ,p_cmbn_ptip_id                   =>  p_cmbn_ptip_id
      ,p_cmbn_ptip_opt_id               =>  p_cmbn_ptip_opt_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_bpp_attribute_category         =>  p_bpp_attribute_category
      ,p_bpp_attribute1                 =>  p_bpp_attribute1
      ,p_bpp_attribute2                 =>  p_bpp_attribute2
      ,p_bpp_attribute3                 =>  p_bpp_attribute3
      ,p_bpp_attribute4                 =>  p_bpp_attribute4
      ,p_bpp_attribute5                 =>  p_bpp_attribute5
      ,p_bpp_attribute6                 =>  p_bpp_attribute6
      ,p_bpp_attribute7                 =>  p_bpp_attribute7
      ,p_bpp_attribute8                 =>  p_bpp_attribute8
      ,p_bpp_attribute9                 =>  p_bpp_attribute9
      ,p_bpp_attribute10                =>  p_bpp_attribute10
      ,p_bpp_attribute11                =>  p_bpp_attribute11
      ,p_bpp_attribute12                =>  p_bpp_attribute12
      ,p_bpp_attribute13                =>  p_bpp_attribute13
      ,p_bpp_attribute14                =>  p_bpp_attribute14
      ,p_bpp_attribute15                =>  p_bpp_attribute15
      ,p_bpp_attribute16                =>  p_bpp_attribute16
      ,p_bpp_attribute17                =>  p_bpp_attribute17
      ,p_bpp_attribute18                =>  p_bpp_attribute18
      ,p_bpp_attribute19                =>  p_bpp_attribute19
      ,p_bpp_attribute20                =>  p_bpp_attribute20
      ,p_bpp_attribute21                =>  p_bpp_attribute21
      ,p_bpp_attribute22                =>  p_bpp_attribute22
      ,p_bpp_attribute23                =>  p_bpp_attribute23
      ,p_bpp_attribute24                =>  p_bpp_attribute24
      ,p_bpp_attribute25                =>  p_bpp_attribute25
      ,p_bpp_attribute26                =>  p_bpp_attribute26
      ,p_bpp_attribute27                =>  p_bpp_attribute27
      ,p_bpp_attribute28                =>  p_bpp_attribute28
      ,p_bpp_attribute29                =>  p_bpp_attribute29
      ,p_bpp_attribute30                =>  p_bpp_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_Benefit_Prvdr_Pool'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_Benefit_Prvdr_Pool
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
  p_bnft_prvdr_pool_id := l_bnft_prvdr_pool_id;
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
    ROLLBACK TO create_Benefit_Prvdr_Pool;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_bnft_prvdr_pool_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_Benefit_Prvdr_Pool;
    raise;
    --
end create_Benefit_Prvdr_Pool;
-- ----------------------------------------------------------------------------
-- |------------------------< update_Benefit_Prvdr_Pool >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_Benefit_Prvdr_Pool
  (p_validate                       in  boolean   default false
  ,p_bnft_prvdr_pool_id             in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_name                           in  varchar2  default hr_api.g_varchar2
  ,p_pgm_pool_flag                  in  varchar2  default hr_api.g_varchar2
  ,p_excs_alwys_fftd_flag           in  varchar2  default hr_api.g_varchar2
  ,p_use_for_pgm_pool_flag          in  varchar2  default hr_api.g_varchar2
  ,p_pct_rndg_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_pct_rndg_rl                    in  number    default hr_api.g_number
  ,p_val_rndg_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_val_rndg_rl                    in  number    default hr_api.g_number
  ,p_dflt_excs_trtmt_cd             in  varchar2  default hr_api.g_varchar2
  ,p_dflt_excs_trtmt_rl             in  number    default hr_api.g_number
  ,p_rlovr_rstrcn_cd                in  varchar2  default hr_api.g_varchar2
  ,p_no_mn_dstrbl_pct_flag          in  varchar2  default hr_api.g_varchar2
  ,p_no_mn_dstrbl_val_flag          in  varchar2  default hr_api.g_varchar2
  ,p_no_mx_dstrbl_pct_flag          in  varchar2  default hr_api.g_varchar2
  ,p_no_mx_dstrbl_val_flag          in  varchar2  default hr_api.g_varchar2
  ,p_auto_alct_excs_flag            in  varchar2  default hr_api.g_varchar2
  ,p_alws_ngtv_crs_flag             in  varchar2  default hr_api.g_varchar2
  ,p_uses_net_crs_mthd_flag         in  varchar2  default hr_api.g_varchar2
  ,p_mx_dfcit_pct_pool_crs_num      in  number    default hr_api.g_number
  ,p_mx_dfcit_pct_comp_num          in  number    default hr_api.g_number
  ,p_comp_lvl_fctr_id               in  number    default hr_api.g_number
  ,p_mn_dstrbl_pct_num              in  number    default hr_api.g_number
  ,p_mn_dstrbl_val                  in  number    default hr_api.g_number
  ,p_mx_dstrbl_pct_num              in  number    default hr_api.g_number
  ,p_mx_dstrbl_val                  in  number    default hr_api.g_number
  ,p_excs_trtmt_cd                  in  varchar2  default hr_api.g_varchar2
  ,p_ptip_id                        in  number    default hr_api.g_number
  ,p_plip_id                        in  number    default hr_api.g_number
  ,p_pgm_id                         in  number    default hr_api.g_number
  ,p_oiplip_id                      in  number    default hr_api.g_number
  ,p_cmbn_plip_id                   in  number    default hr_api.g_number
  ,p_cmbn_ptip_id                   in  number    default hr_api.g_number
  ,p_cmbn_ptip_opt_id               in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_bpp_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_bpp_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_bpp_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_bpp_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_bpp_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_bpp_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_bpp_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_bpp_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_bpp_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_bpp_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_bpp_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_bpp_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_bpp_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_bpp_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_bpp_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_bpp_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_bpp_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_bpp_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_bpp_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_bpp_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_bpp_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_bpp_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_bpp_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_bpp_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_bpp_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_bpp_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_bpp_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_bpp_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_bpp_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_bpp_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_bpp_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Benefit_Prvdr_Pool';
  l_object_version_number ben_bnft_prvdr_pool_f.object_version_number%TYPE;
  l_effective_start_date ben_bnft_prvdr_pool_f.effective_start_date%TYPE;
  l_effective_end_date ben_bnft_prvdr_pool_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_Benefit_Prvdr_Pool;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_Benefit_Prvdr_Pool
    --
    ben_Benefit_Prvdr_Pool_bk2.update_Benefit_Prvdr_Pool_b
      (
       p_bnft_prvdr_pool_id             =>  p_bnft_prvdr_pool_id
      ,p_name                           =>  p_name
      ,p_pgm_pool_flag                  =>  p_pgm_pool_flag
      ,p_excs_alwys_fftd_flag           =>  p_excs_alwys_fftd_flag
      ,p_use_for_pgm_pool_flag          =>  p_use_for_pgm_pool_flag
      ,p_pct_rndg_cd                    =>  p_pct_rndg_cd
      ,p_pct_rndg_rl                    =>  p_pct_rndg_rl
      ,p_val_rndg_cd                    =>  p_val_rndg_cd
      ,p_val_rndg_rl                    =>  p_val_rndg_rl
      ,p_dflt_excs_trtmt_cd             =>  p_dflt_excs_trtmt_cd
      ,p_dflt_excs_trtmt_rl             =>  p_dflt_excs_trtmt_rl
      ,p_rlovr_rstrcn_cd                =>  p_rlovr_rstrcn_cd
      ,p_no_mn_dstrbl_pct_flag          =>  p_no_mn_dstrbl_pct_flag
      ,p_no_mn_dstrbl_val_flag          =>  p_no_mn_dstrbl_val_flag
      ,p_no_mx_dstrbl_pct_flag          =>  p_no_mx_dstrbl_pct_flag
      ,p_no_mx_dstrbl_val_flag          =>  p_no_mx_dstrbl_val_flag
      ,p_auto_alct_excs_flag            =>  p_auto_alct_excs_flag
      ,p_alws_ngtv_crs_flag             =>  p_alws_ngtv_crs_flag
      ,p_uses_net_crs_mthd_flag         =>  p_uses_net_crs_mthd_flag
      ,p_mx_dfcit_pct_pool_crs_num      =>  p_mx_dfcit_pct_pool_crs_num
      ,p_mx_dfcit_pct_comp_num          =>  p_mx_dfcit_pct_comp_num
      ,p_comp_lvl_fctr_id               =>  p_comp_lvl_fctr_id
      ,p_mn_dstrbl_pct_num              =>  p_mn_dstrbl_pct_num
      ,p_mn_dstrbl_val                  =>  p_mn_dstrbl_val
      ,p_mx_dstrbl_pct_num              =>  p_mx_dstrbl_pct_num
      ,p_mx_dstrbl_val                  =>  p_mx_dstrbl_val
      ,p_excs_trtmt_cd                  =>  p_excs_trtmt_cd
      ,p_ptip_id                        =>  p_ptip_id
      ,p_plip_id                        =>  p_plip_id
      ,p_pgm_id                         =>  p_pgm_id
      ,p_oiplip_id                      =>  p_oiplip_id
      ,p_cmbn_plip_id                   =>  p_cmbn_plip_id
      ,p_cmbn_ptip_id                   =>  p_cmbn_ptip_id
      ,p_cmbn_ptip_opt_id               =>  p_cmbn_ptip_opt_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_bpp_attribute_category         =>  p_bpp_attribute_category
      ,p_bpp_attribute1                 =>  p_bpp_attribute1
      ,p_bpp_attribute2                 =>  p_bpp_attribute2
      ,p_bpp_attribute3                 =>  p_bpp_attribute3
      ,p_bpp_attribute4                 =>  p_bpp_attribute4
      ,p_bpp_attribute5                 =>  p_bpp_attribute5
      ,p_bpp_attribute6                 =>  p_bpp_attribute6
      ,p_bpp_attribute7                 =>  p_bpp_attribute7
      ,p_bpp_attribute8                 =>  p_bpp_attribute8
      ,p_bpp_attribute9                 =>  p_bpp_attribute9
      ,p_bpp_attribute10                =>  p_bpp_attribute10
      ,p_bpp_attribute11                =>  p_bpp_attribute11
      ,p_bpp_attribute12                =>  p_bpp_attribute12
      ,p_bpp_attribute13                =>  p_bpp_attribute13
      ,p_bpp_attribute14                =>  p_bpp_attribute14
      ,p_bpp_attribute15                =>  p_bpp_attribute15
      ,p_bpp_attribute16                =>  p_bpp_attribute16
      ,p_bpp_attribute17                =>  p_bpp_attribute17
      ,p_bpp_attribute18                =>  p_bpp_attribute18
      ,p_bpp_attribute19                =>  p_bpp_attribute19
      ,p_bpp_attribute20                =>  p_bpp_attribute20
      ,p_bpp_attribute21                =>  p_bpp_attribute21
      ,p_bpp_attribute22                =>  p_bpp_attribute22
      ,p_bpp_attribute23                =>  p_bpp_attribute23
      ,p_bpp_attribute24                =>  p_bpp_attribute24
      ,p_bpp_attribute25                =>  p_bpp_attribute25
      ,p_bpp_attribute26                =>  p_bpp_attribute26
      ,p_bpp_attribute27                =>  p_bpp_attribute27
      ,p_bpp_attribute28                =>  p_bpp_attribute28
      ,p_bpp_attribute29                =>  p_bpp_attribute29
      ,p_bpp_attribute30                =>  p_bpp_attribute30
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Benefit_Prvdr_Pool'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_Benefit_Prvdr_Pool
    --
  end;
  --
  hr_utility.set_location('deficit: '||p_mx_dfcit_pct_comp_num, 20);
  ben_bpp_upd.upd
    (
     p_bnft_prvdr_pool_id            => p_bnft_prvdr_pool_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_name                          => p_name
    ,p_pgm_pool_flag                 => p_pgm_pool_flag
    ,p_excs_alwys_fftd_flag          => p_excs_alwys_fftd_flag
    ,p_use_for_pgm_pool_flag         => p_use_for_pgm_pool_flag
    ,p_pct_rndg_cd                   => p_pct_rndg_cd
    ,p_pct_rndg_rl                   => p_pct_rndg_rl
    ,p_val_rndg_cd                   => p_val_rndg_cd
    ,p_val_rndg_rl                   => p_val_rndg_rl
    ,p_dflt_excs_trtmt_cd            => p_dflt_excs_trtmt_cd
    ,p_dflt_excs_trtmt_rl            => p_dflt_excs_trtmt_rl
    ,p_rlovr_rstrcn_cd               => p_rlovr_rstrcn_cd
    ,p_no_mn_dstrbl_pct_flag         => p_no_mn_dstrbl_pct_flag
    ,p_no_mn_dstrbl_val_flag         => p_no_mn_dstrbl_val_flag
    ,p_no_mx_dstrbl_pct_flag         => p_no_mx_dstrbl_pct_flag
    ,p_no_mx_dstrbl_val_flag         => p_no_mx_dstrbl_val_flag
    ,p_auto_alct_excs_flag           => p_auto_alct_excs_flag
    ,p_alws_ngtv_crs_flag            => p_alws_ngtv_crs_flag
    ,p_uses_net_crs_mthd_flag        => p_uses_net_crs_mthd_flag
    ,p_mx_dfcit_pct_pool_crs_num     => p_mx_dfcit_pct_pool_crs_num
    ,p_mx_dfcit_pct_comp_num         => p_mx_dfcit_pct_comp_num
    ,p_comp_lvl_fctr_id              => p_comp_lvl_fctr_id
    ,p_mn_dstrbl_pct_num             => p_mn_dstrbl_pct_num
    ,p_mn_dstrbl_val                 => p_mn_dstrbl_val
    ,p_mx_dstrbl_pct_num             => p_mx_dstrbl_pct_num
    ,p_mx_dstrbl_val                 => p_mx_dstrbl_val
    ,p_excs_trtmt_cd                 => p_excs_trtmt_cd
    ,p_ptip_id                       => p_ptip_id
    ,p_plip_id                       => p_plip_id
    ,p_pgm_id                        => p_pgm_id
    ,p_oiplip_id                     =>  p_oiplip_id
    ,p_cmbn_plip_id                  => p_cmbn_plip_id
    ,p_cmbn_ptip_id                  => p_cmbn_ptip_id
    ,p_cmbn_ptip_opt_id              => p_cmbn_ptip_opt_id
    ,p_business_group_id             => p_business_group_id
    ,p_bpp_attribute_category        => p_bpp_attribute_category
    ,p_bpp_attribute1                => p_bpp_attribute1
    ,p_bpp_attribute2                => p_bpp_attribute2
    ,p_bpp_attribute3                => p_bpp_attribute3
    ,p_bpp_attribute4                => p_bpp_attribute4
    ,p_bpp_attribute5                => p_bpp_attribute5
    ,p_bpp_attribute6                => p_bpp_attribute6
    ,p_bpp_attribute7                => p_bpp_attribute7
    ,p_bpp_attribute8                => p_bpp_attribute8
    ,p_bpp_attribute9                => p_bpp_attribute9
    ,p_bpp_attribute10               => p_bpp_attribute10
    ,p_bpp_attribute11               => p_bpp_attribute11
    ,p_bpp_attribute12               => p_bpp_attribute12
    ,p_bpp_attribute13               => p_bpp_attribute13
    ,p_bpp_attribute14               => p_bpp_attribute14
    ,p_bpp_attribute15               => p_bpp_attribute15
    ,p_bpp_attribute16               => p_bpp_attribute16
    ,p_bpp_attribute17               => p_bpp_attribute17
    ,p_bpp_attribute18               => p_bpp_attribute18
    ,p_bpp_attribute19               => p_bpp_attribute19
    ,p_bpp_attribute20               => p_bpp_attribute20
    ,p_bpp_attribute21               => p_bpp_attribute21
    ,p_bpp_attribute22               => p_bpp_attribute22
    ,p_bpp_attribute23               => p_bpp_attribute23
    ,p_bpp_attribute24               => p_bpp_attribute24
    ,p_bpp_attribute25               => p_bpp_attribute25
    ,p_bpp_attribute26               => p_bpp_attribute26
    ,p_bpp_attribute27               => p_bpp_attribute27
    ,p_bpp_attribute28               => p_bpp_attribute28
    ,p_bpp_attribute29               => p_bpp_attribute29
    ,p_bpp_attribute30               => p_bpp_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_Benefit_Prvdr_Pool
    --
    ben_Benefit_Prvdr_Pool_bk2.update_Benefit_Prvdr_Pool_a
      (
       p_bnft_prvdr_pool_id             =>  p_bnft_prvdr_pool_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_name                           =>  p_name
      ,p_pgm_pool_flag                  =>  p_pgm_pool_flag
      ,p_excs_alwys_fftd_flag           =>  p_excs_alwys_fftd_flag
      ,p_use_for_pgm_pool_flag          =>  p_use_for_pgm_pool_flag
      ,p_pct_rndg_cd                    =>  p_pct_rndg_cd
      ,p_pct_rndg_rl                    =>  p_pct_rndg_rl
      ,p_val_rndg_cd                    =>  p_val_rndg_cd
      ,p_val_rndg_rl                    =>  p_val_rndg_rl
      ,p_dflt_excs_trtmt_cd             =>  p_dflt_excs_trtmt_cd
      ,p_dflt_excs_trtmt_rl             =>  p_dflt_excs_trtmt_rl
      ,p_rlovr_rstrcn_cd                =>  p_rlovr_rstrcn_cd
      ,p_no_mn_dstrbl_pct_flag          =>  p_no_mn_dstrbl_pct_flag
      ,p_no_mn_dstrbl_val_flag          =>  p_no_mn_dstrbl_val_flag
      ,p_no_mx_dstrbl_pct_flag          =>  p_no_mx_dstrbl_pct_flag
      ,p_no_mx_dstrbl_val_flag          =>  p_no_mx_dstrbl_val_flag
      ,p_auto_alct_excs_flag            =>  p_auto_alct_excs_flag
      ,p_alws_ngtv_crs_flag             =>  p_alws_ngtv_crs_flag
      ,p_uses_net_crs_mthd_flag         =>  p_uses_net_crs_mthd_flag
      ,p_mx_dfcit_pct_pool_crs_num      =>  p_mx_dfcit_pct_pool_crs_num
      ,p_mx_dfcit_pct_comp_num          =>  p_mx_dfcit_pct_comp_num
      ,p_comp_lvl_fctr_id               =>  p_comp_lvl_fctr_id
      ,p_mn_dstrbl_pct_num              =>  p_mn_dstrbl_pct_num
      ,p_mn_dstrbl_val                  =>  p_mn_dstrbl_val
      ,p_mx_dstrbl_pct_num              =>  p_mx_dstrbl_pct_num
      ,p_mx_dstrbl_val                  =>  p_mx_dstrbl_val
      ,p_excs_trtmt_cd                  =>  p_excs_trtmt_cd
      ,p_ptip_id                        =>  p_ptip_id
      ,p_plip_id                        =>  p_plip_id
      ,p_pgm_id                         =>  p_pgm_id
      ,p_oiplip_id                      =>  p_oiplip_id
      ,p_cmbn_plip_id                   =>  p_cmbn_plip_id
      ,p_cmbn_ptip_id                   =>  p_cmbn_ptip_id
      ,p_cmbn_ptip_opt_id               =>  p_cmbn_ptip_opt_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_bpp_attribute_category         =>  p_bpp_attribute_category
      ,p_bpp_attribute1                 =>  p_bpp_attribute1
      ,p_bpp_attribute2                 =>  p_bpp_attribute2
      ,p_bpp_attribute3                 =>  p_bpp_attribute3
      ,p_bpp_attribute4                 =>  p_bpp_attribute4
      ,p_bpp_attribute5                 =>  p_bpp_attribute5
      ,p_bpp_attribute6                 =>  p_bpp_attribute6
      ,p_bpp_attribute7                 =>  p_bpp_attribute7
      ,p_bpp_attribute8                 =>  p_bpp_attribute8
      ,p_bpp_attribute9                 =>  p_bpp_attribute9
      ,p_bpp_attribute10                =>  p_bpp_attribute10
      ,p_bpp_attribute11                =>  p_bpp_attribute11
      ,p_bpp_attribute12                =>  p_bpp_attribute12
      ,p_bpp_attribute13                =>  p_bpp_attribute13
      ,p_bpp_attribute14                =>  p_bpp_attribute14
      ,p_bpp_attribute15                =>  p_bpp_attribute15
      ,p_bpp_attribute16                =>  p_bpp_attribute16
      ,p_bpp_attribute17                =>  p_bpp_attribute17
      ,p_bpp_attribute18                =>  p_bpp_attribute18
      ,p_bpp_attribute19                =>  p_bpp_attribute19
      ,p_bpp_attribute20                =>  p_bpp_attribute20
      ,p_bpp_attribute21                =>  p_bpp_attribute21
      ,p_bpp_attribute22                =>  p_bpp_attribute22
      ,p_bpp_attribute23                =>  p_bpp_attribute23
      ,p_bpp_attribute24                =>  p_bpp_attribute24
      ,p_bpp_attribute25                =>  p_bpp_attribute25
      ,p_bpp_attribute26                =>  p_bpp_attribute26
      ,p_bpp_attribute27                =>  p_bpp_attribute27
      ,p_bpp_attribute28                =>  p_bpp_attribute28
      ,p_bpp_attribute29                =>  p_bpp_attribute29
      ,p_bpp_attribute30                =>  p_bpp_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Benefit_Prvdr_Pool'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_Benefit_Prvdr_Pool
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
    ROLLBACK TO update_Benefit_Prvdr_Pool;
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
    ROLLBACK TO update_Benefit_Prvdr_Pool;
    raise;
    --
end update_Benefit_Prvdr_Pool;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_Benefit_Prvdr_Pool >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Benefit_Prvdr_Pool
  (p_validate                       in  boolean  default false
  ,p_bnft_prvdr_pool_id             in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Benefit_Prvdr_Pool';
  l_object_version_number ben_bnft_prvdr_pool_f.object_version_number%TYPE;
  l_effective_start_date ben_bnft_prvdr_pool_f.effective_start_date%TYPE;
  l_effective_end_date ben_bnft_prvdr_pool_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_Benefit_Prvdr_Pool;
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
    -- Start of API User Hook for the before hook of delete_Benefit_Prvdr_Pool
    --
    ben_Benefit_Prvdr_Pool_bk3.delete_Benefit_Prvdr_Pool_b
      (
       p_bnft_prvdr_pool_id             =>  p_bnft_prvdr_pool_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Benefit_Prvdr_Pool'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_Benefit_Prvdr_Pool
    --
  end;
  --
  ben_bpp_del.del
    (
     p_bnft_prvdr_pool_id            => p_bnft_prvdr_pool_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_Benefit_Prvdr_Pool
    --
    ben_Benefit_Prvdr_Pool_bk3.delete_Benefit_Prvdr_Pool_a
      (
       p_bnft_prvdr_pool_id             =>  p_bnft_prvdr_pool_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Benefit_Prvdr_Pool'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_Benefit_Prvdr_Pool
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
    ROLLBACK TO delete_Benefit_Prvdr_Pool;
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
    ROLLBACK TO delete_Benefit_Prvdr_Pool;
    raise;
    --
end delete_Benefit_Prvdr_Pool;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_bnft_prvdr_pool_id                   in     number
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
  ben_bpp_shd.lck
    (
      p_bnft_prvdr_pool_id                 => p_bnft_prvdr_pool_id
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
end ben_Benefit_Prvdr_Pool_api;

/
