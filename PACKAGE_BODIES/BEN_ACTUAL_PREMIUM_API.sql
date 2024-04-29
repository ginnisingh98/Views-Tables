--------------------------------------------------------
--  DDL for Package Body BEN_ACTUAL_PREMIUM_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ACTUAL_PREMIUM_API" as
/* $Header: beaprapi.pkb 120.0 2005/05/28 00:26:27 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_actual_premium_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_actual_premium >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_actual_premium
  (p_validate                       in  boolean   default false
  ,p_actl_prem_id                   out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_name                           in  varchar2  default null
  ,p_acty_ref_perd_cd               in  varchar2  default null
  ,p_uom                            in  varchar2  default null
  ,p_rt_typ_cd                      in  varchar2  default null
  ,p_bnft_rt_typ_cd                 in  varchar2  default null
  ,p_val                            in  number    default null
  ,p_mlt_cd                         in  varchar2  default null
  ,p_prdct_cd                       in  varchar2  default null
  ,p_rndg_cd                        in  varchar2  default null
  ,p_rndg_rl                        in  number    default null
  ,p_val_calc_rl                    in  number    default null
  ,p_prem_asnmt_cd                  in  varchar2  default null
  ,p_prem_asnmt_lvl_cd              in  varchar2  default null
  ,p_actl_prem_typ_cd               in  varchar2  default null
  ,p_prem_pyr_cd                    in  varchar2  default null
  ,p_cr_lkbk_val                    in  number    default null
  ,p_cr_lkbk_uom                    in  varchar2  default null
  ,p_cr_lkbk_crnt_py_only_flag      in  varchar2  default null
  ,p_prsptv_r_rtsptv_cd             in  varchar2  default null
  ,p_upr_lmt_val                    in  number    default null
  ,p_upr_lmt_calc_rl                in  number    default null
  ,p_lwr_lmt_val                    in  number    default null
  ,p_lwr_lmt_calc_rl                in  number    default null
  ,p_cost_allocation_keyflex_id     in  number    default null
  ,p_organization_id                in  number    default null
  ,p_oipl_id                        in  number    default null
  ,p_pl_id                          in  number    default null
  ,p_comp_lvl_fctr_id               in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_apr_attribute_category         in  varchar2  default null
  ,p_apr_attribute1                 in  varchar2  default null
  ,p_apr_attribute2                 in  varchar2  default null
  ,p_apr_attribute3                 in  varchar2  default null
  ,p_apr_attribute4                 in  varchar2  default null
  ,p_apr_attribute5                 in  varchar2  default null
  ,p_apr_attribute6                 in  varchar2  default null
  ,p_apr_attribute7                 in  varchar2  default null
  ,p_apr_attribute8                 in  varchar2  default null
  ,p_apr_attribute9                 in  varchar2  default null
  ,p_apr_attribute10                in  varchar2  default null
  ,p_apr_attribute11                in  varchar2  default null
  ,p_apr_attribute12                in  varchar2  default null
  ,p_apr_attribute13                in  varchar2  default null
  ,p_apr_attribute14                in  varchar2  default null
  ,p_apr_attribute15                in  varchar2  default null
  ,p_apr_attribute16                in  varchar2  default null
  ,p_apr_attribute17                in  varchar2  default null
  ,p_apr_attribute18                in  varchar2  default null
  ,p_apr_attribute19                in  varchar2  default null
  ,p_apr_attribute20                in  varchar2  default null
  ,p_apr_attribute21                in  varchar2  default null
  ,p_apr_attribute22                in  varchar2  default null
  ,p_apr_attribute23                in  varchar2  default null
  ,p_apr_attribute24                in  varchar2  default null
  ,p_apr_attribute25                in  varchar2  default null
  ,p_apr_attribute26                in  varchar2  default null
  ,p_apr_attribute27                in  varchar2  default null
  ,p_apr_attribute28                in  varchar2  default null
  ,p_apr_attribute29                in  varchar2  default null
  ,p_apr_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_prtl_mo_det_mthd_cd            in  varchar2  default null
  ,p_prtl_mo_det_mthd_rl            in  number    default null
  ,p_wsh_rl_dy_mo_num               in  number    default null
  ,p_vrbl_rt_add_on_calc_rl         in  number    default null
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_actl_prem_id ben_actl_prem_f.actl_prem_id%TYPE;
  l_effective_start_date ben_actl_prem_f.effective_start_date%TYPE;
  l_effective_end_date ben_actl_prem_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_actual_premium';
  l_object_version_number ben_actl_prem_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_actual_premium;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_actual_premium
    --
    ben_actual_premium_bk1.create_actual_premium_b
      (
       p_name                           =>  p_name
      ,p_acty_ref_perd_cd               =>  p_acty_ref_perd_cd
      ,p_uom                            =>  p_uom
      ,p_rt_typ_cd                      =>  p_rt_typ_cd
      ,p_bnft_rt_typ_cd                 =>  p_bnft_rt_typ_cd
      ,p_val                            =>  p_val
      ,p_mlt_cd                         =>  p_mlt_cd
      ,p_prdct_cd                       =>  p_prdct_cd
      ,p_rndg_cd                        =>  p_rndg_cd
      ,p_rndg_rl                        =>  p_rndg_rl
      ,p_val_calc_rl                    =>  p_val_calc_rl
      ,p_prem_asnmt_cd                  =>  p_prem_asnmt_cd
      ,p_prem_asnmt_lvl_cd              =>  p_prem_asnmt_lvl_cd
      ,p_actl_prem_typ_cd               =>  p_actl_prem_typ_cd
      ,p_prem_pyr_cd                    =>  p_prem_pyr_cd
      ,p_cr_lkbk_val                    =>  p_cr_lkbk_val
      ,p_cr_lkbk_uom                    =>  p_cr_lkbk_uom
      ,p_cr_lkbk_crnt_py_only_flag      =>  p_cr_lkbk_crnt_py_only_flag
      ,p_prsptv_r_rtsptv_cd             =>  p_prsptv_r_rtsptv_cd
      ,p_upr_lmt_val                    =>  p_upr_lmt_val
      ,p_upr_lmt_calc_rl                =>  p_upr_lmt_calc_rl
      ,p_lwr_lmt_val                    =>  p_lwr_lmt_val
      ,p_lwr_lmt_calc_rl                =>  p_lwr_lmt_calc_rl
      ,p_cost_allocation_keyflex_id     =>  p_cost_allocation_keyflex_id
      ,p_organization_id                =>  p_organization_id
      ,p_oipl_id                        =>  p_oipl_id
      ,p_pl_id                          =>  p_pl_id
      ,p_comp_lvl_fctr_id               =>  p_comp_lvl_fctr_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_apr_attribute_category         =>  p_apr_attribute_category
      ,p_apr_attribute1                 =>  p_apr_attribute1
      ,p_apr_attribute2                 =>  p_apr_attribute2
      ,p_apr_attribute3                 =>  p_apr_attribute3
      ,p_apr_attribute4                 =>  p_apr_attribute4
      ,p_apr_attribute5                 =>  p_apr_attribute5
      ,p_apr_attribute6                 =>  p_apr_attribute6
      ,p_apr_attribute7                 =>  p_apr_attribute7
      ,p_apr_attribute8                 =>  p_apr_attribute8
      ,p_apr_attribute9                 =>  p_apr_attribute9
      ,p_apr_attribute10                =>  p_apr_attribute10
      ,p_apr_attribute11                =>  p_apr_attribute11
      ,p_apr_attribute12                =>  p_apr_attribute12
      ,p_apr_attribute13                =>  p_apr_attribute13
      ,p_apr_attribute14                =>  p_apr_attribute14
      ,p_apr_attribute15                =>  p_apr_attribute15
      ,p_apr_attribute16                =>  p_apr_attribute16
      ,p_apr_attribute17                =>  p_apr_attribute17
      ,p_apr_attribute18                =>  p_apr_attribute18
      ,p_apr_attribute19                =>  p_apr_attribute19
      ,p_apr_attribute20                =>  p_apr_attribute20
      ,p_apr_attribute21                =>  p_apr_attribute21
      ,p_apr_attribute22                =>  p_apr_attribute22
      ,p_apr_attribute23                =>  p_apr_attribute23
      ,p_apr_attribute24                =>  p_apr_attribute24
      ,p_apr_attribute25                =>  p_apr_attribute25
      ,p_apr_attribute26                =>  p_apr_attribute26
      ,p_apr_attribute27                =>  p_apr_attribute27
      ,p_apr_attribute28                =>  p_apr_attribute28
      ,p_apr_attribute29                =>  p_apr_attribute29
      ,p_apr_attribute30                =>  p_apr_attribute30
      ,p_prtl_mo_det_mthd_cd            =>  p_prtl_mo_det_mthd_cd
      ,p_prtl_mo_det_mthd_rl            =>  p_prtl_mo_det_mthd_rl
      ,p_wsh_rl_dy_mo_num               =>  p_wsh_rl_dy_mo_num
      ,p_vrbl_rt_add_on_calc_rl         =>  p_vrbl_rt_add_on_calc_rl
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_actual_premium'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_actual_premium
    --
  end;
  --
  ben_apr_ins.ins
    (
     p_actl_prem_id                  => l_actl_prem_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_name                          => p_name
    ,p_acty_ref_perd_cd              => p_acty_ref_perd_cd
    ,p_uom                           => p_uom
    ,p_rt_typ_cd                     => p_rt_typ_cd
    ,p_bnft_rt_typ_cd                => p_bnft_rt_typ_cd
    ,p_val                           => p_val
    ,p_mlt_cd                        => p_mlt_cd
    ,p_prdct_cd                      => p_prdct_cd
    ,p_rndg_cd                       => p_rndg_cd
    ,p_rndg_rl                       => p_rndg_rl
    ,p_val_calc_rl                   => p_val_calc_rl
    ,p_prem_asnmt_cd                 => p_prem_asnmt_cd
    ,p_prem_asnmt_lvl_cd             => p_prem_asnmt_lvl_cd
    ,p_actl_prem_typ_cd              => p_actl_prem_typ_cd
    ,p_prem_pyr_cd                   => p_prem_pyr_cd
    ,p_cr_lkbk_val                   => p_cr_lkbk_val
    ,p_cr_lkbk_uom                   => p_cr_lkbk_uom
    ,p_cr_lkbk_crnt_py_only_flag     => p_cr_lkbk_crnt_py_only_flag
    ,p_prsptv_r_rtsptv_cd            => p_prsptv_r_rtsptv_cd
    ,p_upr_lmt_val                   => p_upr_lmt_val
    ,p_upr_lmt_calc_rl               => p_upr_lmt_calc_rl
    ,p_lwr_lmt_val                   => p_lwr_lmt_val
    ,p_lwr_lmt_calc_rl               => p_lwr_lmt_calc_rl
    ,p_cost_allocation_keyflex_id    => p_cost_allocation_keyflex_id
    ,p_organization_id               => p_organization_id
    ,p_oipl_id                       => p_oipl_id
    ,p_pl_id                         => p_pl_id
    ,p_comp_lvl_fctr_id              => p_comp_lvl_fctr_id
    ,p_business_group_id             => p_business_group_id
    ,p_apr_attribute_category        => p_apr_attribute_category
    ,p_apr_attribute1                => p_apr_attribute1
    ,p_apr_attribute2                => p_apr_attribute2
    ,p_apr_attribute3                => p_apr_attribute3
    ,p_apr_attribute4                => p_apr_attribute4
    ,p_apr_attribute5                => p_apr_attribute5
    ,p_apr_attribute6                => p_apr_attribute6
    ,p_apr_attribute7                => p_apr_attribute7
    ,p_apr_attribute8                => p_apr_attribute8
    ,p_apr_attribute9                => p_apr_attribute9
    ,p_apr_attribute10               => p_apr_attribute10
    ,p_apr_attribute11               => p_apr_attribute11
    ,p_apr_attribute12               => p_apr_attribute12
    ,p_apr_attribute13               => p_apr_attribute13
    ,p_apr_attribute14               => p_apr_attribute14
    ,p_apr_attribute15               => p_apr_attribute15
    ,p_apr_attribute16               => p_apr_attribute16
    ,p_apr_attribute17               => p_apr_attribute17
    ,p_apr_attribute18               => p_apr_attribute18
    ,p_apr_attribute19               => p_apr_attribute19
    ,p_apr_attribute20               => p_apr_attribute20
    ,p_apr_attribute21               => p_apr_attribute21
    ,p_apr_attribute22               => p_apr_attribute22
    ,p_apr_attribute23               => p_apr_attribute23
    ,p_apr_attribute24               => p_apr_attribute24
    ,p_apr_attribute25               => p_apr_attribute25
    ,p_apr_attribute26               => p_apr_attribute26
    ,p_apr_attribute27               => p_apr_attribute27
    ,p_apr_attribute28               => p_apr_attribute28
    ,p_apr_attribute29               => p_apr_attribute29
    ,p_apr_attribute30               => p_apr_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_prtl_mo_det_mthd_cd           => p_prtl_mo_det_mthd_cd
    ,p_prtl_mo_det_mthd_rl           => p_prtl_mo_det_mthd_rl
    ,p_wsh_rl_dy_mo_num              => p_wsh_rl_dy_mo_num
    ,p_vrbl_rt_add_on_calc_rl        => p_vrbl_rt_add_on_calc_rl
    ,p_effective_date                => trunc(p_effective_date)
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_actual_premium
    --
    ben_actual_premium_bk1.create_actual_premium_a
      (
       p_actl_prem_id                   =>  l_actl_prem_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_name                           =>  p_name
      ,p_acty_ref_perd_cd               =>  p_acty_ref_perd_cd
      ,p_uom                            =>  p_uom
      ,p_rt_typ_cd                      =>  p_rt_typ_cd
      ,p_bnft_rt_typ_cd                 =>  p_bnft_rt_typ_cd
      ,p_val                            =>  p_val
      ,p_mlt_cd                         =>  p_mlt_cd
      ,p_prdct_cd                       =>  p_prdct_cd
      ,p_rndg_cd                        =>  p_rndg_cd
      ,p_rndg_rl                        =>  p_rndg_rl
      ,p_val_calc_rl                    =>  p_val_calc_rl
      ,p_prem_asnmt_cd                  =>  p_prem_asnmt_cd
      ,p_prem_asnmt_lvl_cd              =>  p_prem_asnmt_lvl_cd
      ,p_actl_prem_typ_cd               =>  p_actl_prem_typ_cd
      ,p_prem_pyr_cd                    =>  p_prem_pyr_cd
      ,p_cr_lkbk_val                    =>  p_cr_lkbk_val
      ,p_cr_lkbk_uom                    =>  p_cr_lkbk_uom
      ,p_cr_lkbk_crnt_py_only_flag      =>  p_cr_lkbk_crnt_py_only_flag
      ,p_prsptv_r_rtsptv_cd             =>  p_prsptv_r_rtsptv_cd
      ,p_upr_lmt_val                    =>  p_upr_lmt_val
      ,p_upr_lmt_calc_rl                =>  p_upr_lmt_calc_rl
      ,p_lwr_lmt_val                    =>  p_lwr_lmt_val
      ,p_lwr_lmt_calc_rl                =>  p_lwr_lmt_calc_rl
      ,p_cost_allocation_keyflex_id     =>  p_cost_allocation_keyflex_id
      ,p_organization_id                =>  p_organization_id
      ,p_oipl_id                        =>  p_oipl_id
      ,p_pl_id                          =>  p_pl_id
      ,p_comp_lvl_fctr_id               =>  p_comp_lvl_fctr_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_apr_attribute_category         =>  p_apr_attribute_category
      ,p_apr_attribute1                 =>  p_apr_attribute1
      ,p_apr_attribute2                 =>  p_apr_attribute2
      ,p_apr_attribute3                 =>  p_apr_attribute3
      ,p_apr_attribute4                 =>  p_apr_attribute4
      ,p_apr_attribute5                 =>  p_apr_attribute5
      ,p_apr_attribute6                 =>  p_apr_attribute6
      ,p_apr_attribute7                 =>  p_apr_attribute7
      ,p_apr_attribute8                 =>  p_apr_attribute8
      ,p_apr_attribute9                 =>  p_apr_attribute9
      ,p_apr_attribute10                =>  p_apr_attribute10
      ,p_apr_attribute11                =>  p_apr_attribute11
      ,p_apr_attribute12                =>  p_apr_attribute12
      ,p_apr_attribute13                =>  p_apr_attribute13
      ,p_apr_attribute14                =>  p_apr_attribute14
      ,p_apr_attribute15                =>  p_apr_attribute15
      ,p_apr_attribute16                =>  p_apr_attribute16
      ,p_apr_attribute17                =>  p_apr_attribute17
      ,p_apr_attribute18                =>  p_apr_attribute18
      ,p_apr_attribute19                =>  p_apr_attribute19
      ,p_apr_attribute20                =>  p_apr_attribute20
      ,p_apr_attribute21                =>  p_apr_attribute21
      ,p_apr_attribute22                =>  p_apr_attribute22
      ,p_apr_attribute23                =>  p_apr_attribute23
      ,p_apr_attribute24                =>  p_apr_attribute24
      ,p_apr_attribute25                =>  p_apr_attribute25
      ,p_apr_attribute26                =>  p_apr_attribute26
      ,p_apr_attribute27                =>  p_apr_attribute27
      ,p_apr_attribute28                =>  p_apr_attribute28
      ,p_apr_attribute29                =>  p_apr_attribute29
      ,p_apr_attribute30                =>  p_apr_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_prtl_mo_det_mthd_cd            =>  p_prtl_mo_det_mthd_cd
      ,p_prtl_mo_det_mthd_rl            =>  p_prtl_mo_det_mthd_rl
      ,p_wsh_rl_dy_mo_num               =>  p_wsh_rl_dy_mo_num
      ,p_vrbl_rt_add_on_calc_rl         =>  p_vrbl_rt_add_on_calc_rl
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_actual_premium'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_actual_premium
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
  p_actl_prem_id := l_actl_prem_id;
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
    ROLLBACK TO create_actual_premium;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_actl_prem_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_actual_premium;
    /* Inserted for nocopy changes */
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number := l_object_version_number;
    raise;
    --
end create_actual_premium;
-- ----------------------------------------------------------------------------
-- |------------------------< update_actual_premium >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_actual_premium
  (p_validate                       in  boolean   default false
  ,p_actl_prem_id                   in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_name                           in  varchar2  default hr_api.g_varchar2
  ,p_acty_ref_perd_cd               in  varchar2  default hr_api.g_varchar2
  ,p_uom                            in  varchar2  default hr_api.g_varchar2
  ,p_rt_typ_cd                      in  varchar2  default hr_api.g_varchar2
  ,p_bnft_rt_typ_cd                 in  varchar2  default hr_api.g_varchar2
  ,p_val                            in  number    default hr_api.g_number
  ,p_mlt_cd                         in  varchar2  default hr_api.g_varchar2
  ,p_prdct_cd                       in  varchar2  default hr_api.g_varchar2
  ,p_rndg_cd                        in  varchar2  default hr_api.g_varchar2
  ,p_rndg_rl                        in  number    default hr_api.g_number
  ,p_val_calc_rl                    in  number    default hr_api.g_number
  ,p_prem_asnmt_cd                  in  varchar2  default hr_api.g_varchar2
  ,p_prem_asnmt_lvl_cd              in  varchar2  default hr_api.g_varchar2
  ,p_actl_prem_typ_cd               in  varchar2  default hr_api.g_varchar2
  ,p_prem_pyr_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_cr_lkbk_val                    in  number    default hr_api.g_number
  ,p_cr_lkbk_uom                    in  varchar2  default hr_api.g_varchar2
  ,p_cr_lkbk_crnt_py_only_flag      in  varchar2  default hr_api.g_varchar2
  ,p_prsptv_r_rtsptv_cd             in  varchar2  default hr_api.g_varchar2
  ,p_upr_lmt_val                    in  number    default hr_api.g_number
  ,p_upr_lmt_calc_rl                in  number    default hr_api.g_number
  ,p_lwr_lmt_val                    in  number    default hr_api.g_number
  ,p_lwr_lmt_calc_rl                in  number    default hr_api.g_number
  ,p_cost_allocation_keyflex_id     in  number    default hr_api.g_number
  ,p_organization_id                in  number    default hr_api.g_number
  ,p_oipl_id                        in  number    default hr_api.g_number
  ,p_pl_id                          in  number    default hr_api.g_number
  ,p_comp_lvl_fctr_id               in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_apr_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_apr_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_apr_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_apr_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_apr_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_apr_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_apr_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_apr_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_apr_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_apr_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_apr_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_apr_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_apr_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_apr_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_apr_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_apr_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_apr_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_apr_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_apr_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_apr_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_apr_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_apr_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_apr_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_apr_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_apr_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_apr_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_apr_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_apr_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_apr_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_apr_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_apr_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_prtl_mo_det_mthd_cd            in  varchar2  default hr_api.g_varchar2
  ,p_prtl_mo_det_mthd_rl            in  number    default hr_api.g_number
  ,p_wsh_rl_dy_mo_num               in  number    default hr_api.g_number
  ,p_vrbl_rt_add_on_calc_rl         in  number    default hr_api.g_number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_actual_premium';
  l_object_version_number ben_actl_prem_f.object_version_number%TYPE;
  l_effective_start_date ben_actl_prem_f.effective_start_date%TYPE;
  l_effective_end_date ben_actl_prem_f.effective_end_date%TYPE;
  l_in_object_version_number  number  := p_object_version_number ;

  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_actual_premium;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_actual_premium
    --
    ben_actual_premium_bk2.update_actual_premium_b
      (
       p_actl_prem_id                   =>  p_actl_prem_id
      ,p_name                           =>  p_name
      ,p_acty_ref_perd_cd               =>  p_acty_ref_perd_cd
      ,p_uom                            =>  p_uom
      ,p_rt_typ_cd                      =>  p_rt_typ_cd
      ,p_bnft_rt_typ_cd                 =>  p_bnft_rt_typ_cd
      ,p_val                            =>  p_val
      ,p_mlt_cd                         =>  p_mlt_cd
      ,p_prdct_cd                       =>  p_prdct_cd
      ,p_rndg_cd                        =>  p_rndg_cd
      ,p_rndg_rl                        =>  p_rndg_rl
      ,p_val_calc_rl                    =>  p_val_calc_rl
      ,p_prem_asnmt_cd                  =>  p_prem_asnmt_cd
      ,p_prem_asnmt_lvl_cd              =>  p_prem_asnmt_lvl_cd
      ,p_actl_prem_typ_cd               =>  p_actl_prem_typ_cd
      ,p_prem_pyr_cd                    =>  p_prem_pyr_cd
      ,p_cr_lkbk_val                    =>  p_cr_lkbk_val
      ,p_cr_lkbk_uom                    =>  p_cr_lkbk_uom
      ,p_cr_lkbk_crnt_py_only_flag      =>  p_cr_lkbk_crnt_py_only_flag
      ,p_prsptv_r_rtsptv_cd             =>  p_prsptv_r_rtsptv_cd
      ,p_upr_lmt_val                    =>  p_upr_lmt_val
      ,p_upr_lmt_calc_rl                =>  p_upr_lmt_calc_rl
      ,p_lwr_lmt_val                    =>  p_lwr_lmt_val
      ,p_lwr_lmt_calc_rl                =>  p_lwr_lmt_calc_rl
      ,p_cost_allocation_keyflex_id     =>  p_cost_allocation_keyflex_id
      ,p_organization_id                =>  p_organization_id
      ,p_oipl_id                        =>  p_oipl_id
      ,p_pl_id                          =>  p_pl_id
      ,p_comp_lvl_fctr_id               =>  p_comp_lvl_fctr_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_apr_attribute_category         =>  p_apr_attribute_category
      ,p_apr_attribute1                 =>  p_apr_attribute1
      ,p_apr_attribute2                 =>  p_apr_attribute2
      ,p_apr_attribute3                 =>  p_apr_attribute3
      ,p_apr_attribute4                 =>  p_apr_attribute4
      ,p_apr_attribute5                 =>  p_apr_attribute5
      ,p_apr_attribute6                 =>  p_apr_attribute6
      ,p_apr_attribute7                 =>  p_apr_attribute7
      ,p_apr_attribute8                 =>  p_apr_attribute8
      ,p_apr_attribute9                 =>  p_apr_attribute9
      ,p_apr_attribute10                =>  p_apr_attribute10
      ,p_apr_attribute11                =>  p_apr_attribute11
      ,p_apr_attribute12                =>  p_apr_attribute12
      ,p_apr_attribute13                =>  p_apr_attribute13
      ,p_apr_attribute14                =>  p_apr_attribute14
      ,p_apr_attribute15                =>  p_apr_attribute15
      ,p_apr_attribute16                =>  p_apr_attribute16
      ,p_apr_attribute17                =>  p_apr_attribute17
      ,p_apr_attribute18                =>  p_apr_attribute18
      ,p_apr_attribute19                =>  p_apr_attribute19
      ,p_apr_attribute20                =>  p_apr_attribute20
      ,p_apr_attribute21                =>  p_apr_attribute21
      ,p_apr_attribute22                =>  p_apr_attribute22
      ,p_apr_attribute23                =>  p_apr_attribute23
      ,p_apr_attribute24                =>  p_apr_attribute24
      ,p_apr_attribute25                =>  p_apr_attribute25
      ,p_apr_attribute26                =>  p_apr_attribute26
      ,p_apr_attribute27                =>  p_apr_attribute27
      ,p_apr_attribute28                =>  p_apr_attribute28
      ,p_apr_attribute29                =>  p_apr_attribute29
      ,p_apr_attribute30                =>  p_apr_attribute30
      ,p_object_version_number          =>  p_object_version_number
      ,p_prtl_mo_det_mthd_cd            =>  p_prtl_mo_det_mthd_cd
      ,p_prtl_mo_det_mthd_rl            =>  p_prtl_mo_det_mthd_rl
      ,p_wsh_rl_dy_mo_num               =>  p_wsh_rl_dy_mo_num
      ,p_vrbl_rt_add_on_calc_rl         =>  p_vrbl_rt_add_on_calc_rl
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_actual_premium'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_actual_premium
    --
  end;
  --
  ben_apr_upd.upd
    (
     p_actl_prem_id                  => p_actl_prem_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_name                          => p_name
    ,p_acty_ref_perd_cd              => p_acty_ref_perd_cd
    ,p_uom                           => p_uom
    ,p_rt_typ_cd                     => p_rt_typ_cd
    ,p_bnft_rt_typ_cd                => p_bnft_rt_typ_cd
    ,p_val                           => p_val
    ,p_mlt_cd                        => p_mlt_cd
    ,p_prdct_cd                      => p_prdct_cd
    ,p_rndg_cd                       => p_rndg_cd
    ,p_rndg_rl                       => p_rndg_rl
    ,p_val_calc_rl                   => p_val_calc_rl
    ,p_prem_asnmt_cd                 => p_prem_asnmt_cd
    ,p_prem_asnmt_lvl_cd             => p_prem_asnmt_lvl_cd
    ,p_actl_prem_typ_cd              => p_actl_prem_typ_cd
    ,p_prem_pyr_cd                   => p_prem_pyr_cd
    ,p_cr_lkbk_val                   => p_cr_lkbk_val
    ,p_cr_lkbk_uom                   => p_cr_lkbk_uom
    ,p_cr_lkbk_crnt_py_only_flag     => p_cr_lkbk_crnt_py_only_flag
    ,p_prsptv_r_rtsptv_cd            => p_prsptv_r_rtsptv_cd
    ,p_upr_lmt_val                   => p_upr_lmt_val
    ,p_upr_lmt_calc_rl               => p_upr_lmt_calc_rl
    ,p_lwr_lmt_val                   => p_lwr_lmt_val
    ,p_lwr_lmt_calc_rl               => p_lwr_lmt_calc_rl
    ,p_cost_allocation_keyflex_id    => p_cost_allocation_keyflex_id
    ,p_organization_id               => p_organization_id
    ,p_oipl_id                       => p_oipl_id
    ,p_pl_id                         => p_pl_id
    ,p_comp_lvl_fctr_id              => p_comp_lvl_fctr_id
    ,p_business_group_id             => p_business_group_id
    ,p_apr_attribute_category        => p_apr_attribute_category
    ,p_apr_attribute1                => p_apr_attribute1
    ,p_apr_attribute2                => p_apr_attribute2
    ,p_apr_attribute3                => p_apr_attribute3
    ,p_apr_attribute4                => p_apr_attribute4
    ,p_apr_attribute5                => p_apr_attribute5
    ,p_apr_attribute6                => p_apr_attribute6
    ,p_apr_attribute7                => p_apr_attribute7
    ,p_apr_attribute8                => p_apr_attribute8
    ,p_apr_attribute9                => p_apr_attribute9
    ,p_apr_attribute10               => p_apr_attribute10
    ,p_apr_attribute11               => p_apr_attribute11
    ,p_apr_attribute12               => p_apr_attribute12
    ,p_apr_attribute13               => p_apr_attribute13
    ,p_apr_attribute14               => p_apr_attribute14
    ,p_apr_attribute15               => p_apr_attribute15
    ,p_apr_attribute16               => p_apr_attribute16
    ,p_apr_attribute17               => p_apr_attribute17
    ,p_apr_attribute18               => p_apr_attribute18
    ,p_apr_attribute19               => p_apr_attribute19
    ,p_apr_attribute20               => p_apr_attribute20
    ,p_apr_attribute21               => p_apr_attribute21
    ,p_apr_attribute22               => p_apr_attribute22
    ,p_apr_attribute23               => p_apr_attribute23
    ,p_apr_attribute24               => p_apr_attribute24
    ,p_apr_attribute25               => p_apr_attribute25
    ,p_apr_attribute26               => p_apr_attribute26
    ,p_apr_attribute27               => p_apr_attribute27
    ,p_apr_attribute28               => p_apr_attribute28
    ,p_apr_attribute29               => p_apr_attribute29
    ,p_apr_attribute30               => p_apr_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_prtl_mo_det_mthd_cd           => p_prtl_mo_det_mthd_cd
    ,p_prtl_mo_det_mthd_rl           => p_prtl_mo_det_mthd_rl
    ,p_wsh_rl_dy_mo_num              => p_wsh_rl_dy_mo_num
    ,p_vrbl_rt_add_on_calc_rl        => p_vrbl_rt_add_on_calc_rl
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_actual_premium
    --
    ben_actual_premium_bk2.update_actual_premium_a
      (
       p_actl_prem_id                   =>  p_actl_prem_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_name                           =>  p_name
      ,p_acty_ref_perd_cd               =>  p_acty_ref_perd_cd
      ,p_uom                            =>  p_uom
      ,p_rt_typ_cd                      =>  p_rt_typ_cd
      ,p_bnft_rt_typ_cd                 =>  p_bnft_rt_typ_cd
      ,p_val                            =>  p_val
      ,p_mlt_cd                         =>  p_mlt_cd
      ,p_prdct_cd                       =>  p_prdct_cd
      ,p_rndg_cd                        =>  p_rndg_cd
      ,p_rndg_rl                        =>  p_rndg_rl
      ,p_val_calc_rl                    =>  p_val_calc_rl
      ,p_prem_asnmt_cd                  =>  p_prem_asnmt_cd
      ,p_prem_asnmt_lvl_cd              =>  p_prem_asnmt_lvl_cd
      ,p_actl_prem_typ_cd               =>  p_actl_prem_typ_cd
      ,p_prem_pyr_cd                    =>  p_prem_pyr_cd
      ,p_cr_lkbk_val                    =>  p_cr_lkbk_val
      ,p_cr_lkbk_uom                    =>  p_cr_lkbk_uom
      ,p_cr_lkbk_crnt_py_only_flag      =>  p_cr_lkbk_crnt_py_only_flag
      ,p_prsptv_r_rtsptv_cd             =>  p_prsptv_r_rtsptv_cd
      ,p_upr_lmt_val                    =>  p_upr_lmt_val
      ,p_upr_lmt_calc_rl                =>  p_upr_lmt_calc_rl
      ,p_lwr_lmt_val                    =>  p_lwr_lmt_val
      ,p_lwr_lmt_calc_rl                =>  p_lwr_lmt_calc_rl
      ,p_cost_allocation_keyflex_id     =>  p_cost_allocation_keyflex_id
      ,p_organization_id                =>  p_organization_id
      ,p_oipl_id                        =>  p_oipl_id
      ,p_pl_id                          =>  p_pl_id
      ,p_comp_lvl_fctr_id               =>  p_comp_lvl_fctr_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_apr_attribute_category         =>  p_apr_attribute_category
      ,p_apr_attribute1                 =>  p_apr_attribute1
      ,p_apr_attribute2                 =>  p_apr_attribute2
      ,p_apr_attribute3                 =>  p_apr_attribute3
      ,p_apr_attribute4                 =>  p_apr_attribute4
      ,p_apr_attribute5                 =>  p_apr_attribute5
      ,p_apr_attribute6                 =>  p_apr_attribute6
      ,p_apr_attribute7                 =>  p_apr_attribute7
      ,p_apr_attribute8                 =>  p_apr_attribute8
      ,p_apr_attribute9                 =>  p_apr_attribute9
      ,p_apr_attribute10                =>  p_apr_attribute10
      ,p_apr_attribute11                =>  p_apr_attribute11
      ,p_apr_attribute12                =>  p_apr_attribute12
      ,p_apr_attribute13                =>  p_apr_attribute13
      ,p_apr_attribute14                =>  p_apr_attribute14
      ,p_apr_attribute15                =>  p_apr_attribute15
      ,p_apr_attribute16                =>  p_apr_attribute16
      ,p_apr_attribute17                =>  p_apr_attribute17
      ,p_apr_attribute18                =>  p_apr_attribute18
      ,p_apr_attribute19                =>  p_apr_attribute19
      ,p_apr_attribute20                =>  p_apr_attribute20
      ,p_apr_attribute21                =>  p_apr_attribute21
      ,p_apr_attribute22                =>  p_apr_attribute22
      ,p_apr_attribute23                =>  p_apr_attribute23
      ,p_apr_attribute24                =>  p_apr_attribute24
      ,p_apr_attribute25                =>  p_apr_attribute25
      ,p_apr_attribute26                =>  p_apr_attribute26
      ,p_apr_attribute27                =>  p_apr_attribute27
      ,p_apr_attribute28                =>  p_apr_attribute28
      ,p_apr_attribute29                =>  p_apr_attribute29
      ,p_apr_attribute30                =>  p_apr_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_prtl_mo_det_mthd_cd            =>  p_prtl_mo_det_mthd_cd
      ,p_prtl_mo_det_mthd_rl            =>  p_prtl_mo_det_mthd_rl
      ,p_wsh_rl_dy_mo_num               =>  p_wsh_rl_dy_mo_num
      ,p_vrbl_rt_add_on_calc_rl         =>  p_vrbl_rt_add_on_calc_rl
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_actual_premium'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_actual_premium
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
    ROLLBACK TO update_actual_premium;
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
    p_object_version_number := l_in_object_version_number ;
    ROLLBACK TO update_actual_premium;
        /* Inserted for nocopy changes */
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end update_actual_premium;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_actual_premium >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_actual_premium
  (p_validate                       in  boolean  default false
  ,p_actl_prem_id                   in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_actual_premium';
  l_object_version_number ben_actl_prem_f.object_version_number%TYPE;
  l_effective_start_date ben_actl_prem_f.effective_start_date%TYPE;
  l_effective_end_date ben_actl_prem_f.effective_end_date%TYPE;
  --
  l_in_object_version_number  number  := p_object_version_number ;
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_actual_premium;
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
    -- Start of API User Hook for the before hook of delete_actual_premium
    --
    ben_actual_premium_bk3.delete_actual_premium_b
      (
       p_actl_prem_id                   =>  p_actl_prem_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_actual_premium'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_actual_premium
    --
  end;
  --
  ben_apr_del.del
    (
     p_actl_prem_id                  => p_actl_prem_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_actual_premium
    --
    ben_actual_premium_bk3.delete_actual_premium_a
      (
       p_actl_prem_id                   =>  p_actl_prem_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_actual_premium'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_actual_premium
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
    ROLLBACK TO delete_actual_premium;
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
    p_object_version_number := l_in_object_version_number ;
    --
    ROLLBACK TO delete_actual_premium;
    /* Inserted for nocopy changes */
    p_effective_start_date := null;
    p_effective_end_date := null;
    raise;
    --
end delete_actual_premium;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_actl_prem_id                   in     number
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
  ben_apr_shd.lck
    (
      p_actl_prem_id                 => p_actl_prem_id
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
end ben_actual_premium_api;

/
