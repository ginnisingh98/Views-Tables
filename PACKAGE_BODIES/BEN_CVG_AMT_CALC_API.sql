--------------------------------------------------------
--  DDL for Package Body BEN_CVG_AMT_CALC_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CVG_AMT_CALC_API" as
/* $Header: beccmapi.pkb 120.0 2005/05/28 00:57:00 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_Cvg_Amt_Calc_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_Cvg_Amt_Calc >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_Cvg_Amt_Calc
  (p_validate                       in  boolean   default false
  ,p_cvg_amt_calc_mthd_id           out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_name                           in  varchar2  default null
  ,p_incrmt_val                     in  number    default null
  ,p_mx_val                         in  number    default null
  ,p_mn_val                         in  number    default null
  ,p_no_mx_val_dfnd_flag            in  varchar2  default null
  ,p_no_mn_val_dfnd_flag            in  varchar2  default null
  ,p_rndg_cd                        in  varchar2  default null
  ,p_rndg_rl                        in  number    default null
  ,p_lwr_lmt_val                    in  number    default null
  ,p_lwr_lmt_calc_rl                in  number    default null
  ,p_upr_lmt_val                    in  number    default null
  ,p_upr_lmt_calc_rl                in  number    default null
  ,p_val                            in  number    default null
  ,p_val_ovrid_alwd_flag            in  varchar2  default null
  ,p_val_calc_rl                    in  number    default null
  ,p_uom                            in  varchar2  default null
  ,p_nnmntry_uom                    in  varchar2  default null
  ,p_bndry_perd_cd                  in  varchar2  default null
  ,p_bnft_typ_cd                    in  varchar2  default null
  ,p_cvg_mlt_cd                     in  varchar2  default null
  ,p_rt_typ_cd                      in  varchar2  default null
  ,p_dflt_val                       in  number    default null
  ,p_entr_val_at_enrt_flag          in  varchar2  default null
  ,p_dflt_flag                      in  varchar2  default null
  ,p_comp_lvl_fctr_id               in  number    default null
  ,p_oipl_id                        in  number    default null
  ,p_pl_id                          in  number    default null
  ,p_plip_id                        in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_ccm_attribute_category         in  varchar2  default null
  ,p_ccm_attribute1                 in  varchar2  default null
  ,p_ccm_attribute2                 in  varchar2  default null
  ,p_ccm_attribute3                 in  varchar2  default null
  ,p_ccm_attribute4                 in  varchar2  default null
  ,p_ccm_attribute5                 in  varchar2  default null
  ,p_ccm_attribute6                 in  varchar2  default null
  ,p_ccm_attribute7                 in  varchar2  default null
  ,p_ccm_attribute8                 in  varchar2  default null
  ,p_ccm_attribute9                 in  varchar2  default null
  ,p_ccm_attribute10                in  varchar2  default null
  ,p_ccm_attribute11                in  varchar2  default null
  ,p_ccm_attribute12                in  varchar2  default null
  ,p_ccm_attribute13                in  varchar2  default null
  ,p_ccm_attribute14                in  varchar2  default null
  ,p_ccm_attribute15                in  varchar2  default null
  ,p_ccm_attribute16                in  varchar2  default null
  ,p_ccm_attribute17                in  varchar2  default null
  ,p_ccm_attribute18                in  varchar2  default null
  ,p_ccm_attribute19                in  varchar2  default null
  ,p_ccm_attribute20                in  varchar2  default null
  ,p_ccm_attribute21                in  varchar2  default null
  ,p_ccm_attribute22                in  varchar2  default null
  ,p_ccm_attribute23                in  varchar2  default null
  ,p_ccm_attribute24                in  varchar2  default null
  ,p_ccm_attribute25                in  varchar2  default null
  ,p_ccm_attribute26                in  varchar2  default null
  ,p_ccm_attribute27                in  varchar2  default null
  ,p_ccm_attribute28                in  varchar2  default null
  ,p_ccm_attribute29                in  varchar2  default null
  ,p_ccm_attribute30                in  varchar2  default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date) is
  --
  -- Declare cursors and local variables
  --
  l_cvg_amt_calc_mthd_id ben_cvg_amt_calc_mthd_f.cvg_amt_calc_mthd_id%TYPE;
  l_effective_start_date ben_cvg_amt_calc_mthd_f.effective_start_date%TYPE;
  l_effective_end_date ben_cvg_amt_calc_mthd_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_Cvg_Amt_Calc';
  l_object_version_number ben_cvg_amt_calc_mthd_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_Cvg_Amt_Calc;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_Cvg_Amt_Calc
    --
    ben_Cvg_Amt_Calc_bk1.create_Cvg_Amt_Calc_b
      (p_name                           =>  p_name
      ,p_incrmt_val                     =>  p_incrmt_val
      ,p_mx_val                         =>  p_mx_val
      ,p_mn_val                         =>  p_mn_val
      ,p_no_mx_val_dfnd_flag            =>  p_no_mx_val_dfnd_flag
      ,p_no_mn_val_dfnd_flag            =>  p_no_mn_val_dfnd_flag
      ,p_rndg_cd                        =>  p_rndg_cd
      ,p_rndg_rl                        =>  p_rndg_rl
      ,p_lwr_lmt_val                    =>  p_lwr_lmt_val
      ,p_lwr_lmt_calc_rl                =>  p_lwr_lmt_calc_rl
      ,p_upr_lmt_val                    =>  p_upr_lmt_val
      ,p_upr_lmt_calc_rl                =>  p_upr_lmt_calc_rl
      ,p_val                            =>  p_val
      ,p_val_ovrid_alwd_flag            =>  p_val_ovrid_alwd_flag
      ,p_val_calc_rl                    =>  p_val_calc_rl
      ,p_uom                            =>  p_uom
      ,p_nnmntry_uom                    =>  p_nnmntry_uom
      ,p_bndry_perd_cd                  =>  p_bndry_perd_cd
      ,p_bnft_typ_cd                    =>  p_bnft_typ_cd
      ,p_cvg_mlt_cd                     =>  p_cvg_mlt_cd
      ,p_rt_typ_cd                      =>  p_rt_typ_cd
      ,p_dflt_val                       =>  p_dflt_val
      ,p_entr_val_at_enrt_flag          =>  p_entr_val_at_enrt_flag
      ,p_dflt_flag                      =>  p_dflt_flag
      ,p_comp_lvl_fctr_id               =>  p_comp_lvl_fctr_id
      ,p_oipl_id                        =>  p_oipl_id
      ,p_pl_id                          =>  p_pl_id
      ,p_plip_id                        =>  p_plip_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_ccm_attribute_category         =>  p_ccm_attribute_category
      ,p_ccm_attribute1                 =>  p_ccm_attribute1
      ,p_ccm_attribute2                 =>  p_ccm_attribute2
      ,p_ccm_attribute3                 =>  p_ccm_attribute3
      ,p_ccm_attribute4                 =>  p_ccm_attribute4
      ,p_ccm_attribute5                 =>  p_ccm_attribute5
      ,p_ccm_attribute6                 =>  p_ccm_attribute6
      ,p_ccm_attribute7                 =>  p_ccm_attribute7
      ,p_ccm_attribute8                 =>  p_ccm_attribute8
      ,p_ccm_attribute9                 =>  p_ccm_attribute9
      ,p_ccm_attribute10                =>  p_ccm_attribute10
      ,p_ccm_attribute11                =>  p_ccm_attribute11
      ,p_ccm_attribute12                =>  p_ccm_attribute12
      ,p_ccm_attribute13                =>  p_ccm_attribute13
      ,p_ccm_attribute14                =>  p_ccm_attribute14
      ,p_ccm_attribute15                =>  p_ccm_attribute15
      ,p_ccm_attribute16                =>  p_ccm_attribute16
      ,p_ccm_attribute17                =>  p_ccm_attribute17
      ,p_ccm_attribute18                =>  p_ccm_attribute18
      ,p_ccm_attribute19                =>  p_ccm_attribute19
      ,p_ccm_attribute20                =>  p_ccm_attribute20
      ,p_ccm_attribute21                =>  p_ccm_attribute21
      ,p_ccm_attribute22                =>  p_ccm_attribute22
      ,p_ccm_attribute23                =>  p_ccm_attribute23
      ,p_ccm_attribute24                =>  p_ccm_attribute24
      ,p_ccm_attribute25                =>  p_ccm_attribute25
      ,p_ccm_attribute26                =>  p_ccm_attribute26
      ,p_ccm_attribute27                =>  p_ccm_attribute27
      ,p_ccm_attribute28                =>  p_ccm_attribute28
      ,p_ccm_attribute29                =>  p_ccm_attribute29
      ,p_ccm_attribute30                =>  p_ccm_attribute30
      ,p_effective_date                 =>  trunc(p_effective_date));
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_Cvg_Amt_Calc'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of create_Cvg_Amt_Calc
    --
  end;
  --
  ben_ccm_ins.ins
    (p_cvg_amt_calc_mthd_id          => l_cvg_amt_calc_mthd_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_name                          => p_name
    ,p_incrmt_val                    => p_incrmt_val
    ,p_mx_val                        => p_mx_val
    ,p_mn_val                        => p_mn_val
    ,p_no_mx_val_dfnd_flag           => p_no_mx_val_dfnd_flag
    ,p_no_mn_val_dfnd_flag           => p_no_mn_val_dfnd_flag
    ,p_rndg_cd                       => p_rndg_cd
    ,p_rndg_rl                       => p_rndg_rl
    ,p_lwr_lmt_val                   => p_lwr_lmt_val
    ,p_lwr_lmt_calc_rl               => p_lwr_lmt_calc_rl
    ,p_upr_lmt_val                   => p_upr_lmt_val
    ,p_upr_lmt_calc_rl               => p_upr_lmt_calc_rl
    ,p_val                           => p_val
    ,p_val_ovrid_alwd_flag           => p_val_ovrid_alwd_flag
    ,p_val_calc_rl                   => p_val_calc_rl
    ,p_uom                           => p_uom
    ,p_nnmntry_uom                   => p_nnmntry_uom
    ,p_bndry_perd_cd                 => p_bndry_perd_cd
    ,p_bnft_typ_cd                   => p_bnft_typ_cd
    ,p_cvg_mlt_cd                    => p_cvg_mlt_cd
    ,p_rt_typ_cd                     => p_rt_typ_cd
    ,p_dflt_val                      => p_dflt_val
    ,p_entr_val_at_enrt_flag         => p_entr_val_at_enrt_flag
    ,p_dflt_flag                     => p_dflt_flag
    ,p_comp_lvl_fctr_id              => p_comp_lvl_fctr_id
    ,p_oipl_id                       => p_oipl_id
    ,p_pl_id                         => p_pl_id
    ,p_plip_id                       => p_plip_id
    ,p_business_group_id             => p_business_group_id
    ,p_ccm_attribute_category        => p_ccm_attribute_category
    ,p_ccm_attribute1                => p_ccm_attribute1
    ,p_ccm_attribute2                => p_ccm_attribute2
    ,p_ccm_attribute3                => p_ccm_attribute3
    ,p_ccm_attribute4                => p_ccm_attribute4
    ,p_ccm_attribute5                => p_ccm_attribute5
    ,p_ccm_attribute6                => p_ccm_attribute6
    ,p_ccm_attribute7                => p_ccm_attribute7
    ,p_ccm_attribute8                => p_ccm_attribute8
    ,p_ccm_attribute9                => p_ccm_attribute9
    ,p_ccm_attribute10               => p_ccm_attribute10
    ,p_ccm_attribute11               => p_ccm_attribute11
    ,p_ccm_attribute12               => p_ccm_attribute12
    ,p_ccm_attribute13               => p_ccm_attribute13
    ,p_ccm_attribute14               => p_ccm_attribute14
    ,p_ccm_attribute15               => p_ccm_attribute15
    ,p_ccm_attribute16               => p_ccm_attribute16
    ,p_ccm_attribute17               => p_ccm_attribute17
    ,p_ccm_attribute18               => p_ccm_attribute18
    ,p_ccm_attribute19               => p_ccm_attribute19
    ,p_ccm_attribute20               => p_ccm_attribute20
    ,p_ccm_attribute21               => p_ccm_attribute21
    ,p_ccm_attribute22               => p_ccm_attribute22
    ,p_ccm_attribute23               => p_ccm_attribute23
    ,p_ccm_attribute24               => p_ccm_attribute24
    ,p_ccm_attribute25               => p_ccm_attribute25
    ,p_ccm_attribute26               => p_ccm_attribute26
    ,p_ccm_attribute27               => p_ccm_attribute27
    ,p_ccm_attribute28               => p_ccm_attribute28
    ,p_ccm_attribute29               => p_ccm_attribute29
    ,p_ccm_attribute30               => p_ccm_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date));
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_Cvg_Amt_Calc
    --
    ben_Cvg_Amt_Calc_bk1.create_Cvg_Amt_Calc_a
      (p_cvg_amt_calc_mthd_id           =>  l_cvg_amt_calc_mthd_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_name                           =>  p_name
      ,p_incrmt_val                     =>  p_incrmt_val
      ,p_mx_val                         =>  p_mx_val
      ,p_mn_val                         =>  p_mn_val
      ,p_no_mx_val_dfnd_flag            =>  p_no_mx_val_dfnd_flag
      ,p_no_mn_val_dfnd_flag            =>  p_no_mn_val_dfnd_flag
      ,p_rndg_cd                        =>  p_rndg_cd
      ,p_rndg_rl                        =>  p_rndg_rl
      ,p_lwr_lmt_val                    =>  p_lwr_lmt_val
      ,p_lwr_lmt_calc_rl                =>  p_lwr_lmt_calc_rl
      ,p_upr_lmt_val                    =>  p_upr_lmt_val
      ,p_upr_lmt_calc_rl                =>  p_upr_lmt_calc_rl
      ,p_val                            =>  p_val
      ,p_val_ovrid_alwd_flag            =>  p_val_ovrid_alwd_flag
      ,p_val_calc_rl                    =>  p_val_calc_rl
      ,p_uom                            =>  p_uom
      ,p_nnmntry_uom                    =>  p_nnmntry_uom
      ,p_bndry_perd_cd                  =>  p_bndry_perd_cd
      ,p_bnft_typ_cd                    =>  p_bnft_typ_cd
      ,p_cvg_mlt_cd                     =>  p_cvg_mlt_cd
      ,p_rt_typ_cd                      =>  p_rt_typ_cd
      ,p_dflt_val                       =>  p_dflt_val
      ,p_entr_val_at_enrt_flag          =>  p_entr_val_at_enrt_flag
      ,p_dflt_flag                      =>  p_dflt_flag
      ,p_comp_lvl_fctr_id               =>  p_comp_lvl_fctr_id
      ,p_oipl_id                        =>  p_oipl_id
      ,p_pl_id                          =>  p_pl_id
      ,p_plip_id                        =>  p_plip_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_ccm_attribute_category         =>  p_ccm_attribute_category
      ,p_ccm_attribute1                 =>  p_ccm_attribute1
      ,p_ccm_attribute2                 =>  p_ccm_attribute2
      ,p_ccm_attribute3                 =>  p_ccm_attribute3
      ,p_ccm_attribute4                 =>  p_ccm_attribute4
      ,p_ccm_attribute5                 =>  p_ccm_attribute5
      ,p_ccm_attribute6                 =>  p_ccm_attribute6
      ,p_ccm_attribute7                 =>  p_ccm_attribute7
      ,p_ccm_attribute8                 =>  p_ccm_attribute8
      ,p_ccm_attribute9                 =>  p_ccm_attribute9
      ,p_ccm_attribute10                =>  p_ccm_attribute10
      ,p_ccm_attribute11                =>  p_ccm_attribute11
      ,p_ccm_attribute12                =>  p_ccm_attribute12
      ,p_ccm_attribute13                =>  p_ccm_attribute13
      ,p_ccm_attribute14                =>  p_ccm_attribute14
      ,p_ccm_attribute15                =>  p_ccm_attribute15
      ,p_ccm_attribute16                =>  p_ccm_attribute16
      ,p_ccm_attribute17                =>  p_ccm_attribute17
      ,p_ccm_attribute18                =>  p_ccm_attribute18
      ,p_ccm_attribute19                =>  p_ccm_attribute19
      ,p_ccm_attribute20                =>  p_ccm_attribute20
      ,p_ccm_attribute21                =>  p_ccm_attribute21
      ,p_ccm_attribute22                =>  p_ccm_attribute22
      ,p_ccm_attribute23                =>  p_ccm_attribute23
      ,p_ccm_attribute24                =>  p_ccm_attribute24
      ,p_ccm_attribute25                =>  p_ccm_attribute25
      ,p_ccm_attribute26                =>  p_ccm_attribute26
      ,p_ccm_attribute27                =>  p_ccm_attribute27
      ,p_ccm_attribute28                =>  p_ccm_attribute28
      ,p_ccm_attribute29                =>  p_ccm_attribute29
      ,p_ccm_attribute30                =>  p_ccm_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date));
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_Cvg_Amt_Calc'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of create_Cvg_Amt_Calc
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
  p_cvg_amt_calc_mthd_id := l_cvg_amt_calc_mthd_id;
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
    ROLLBACK TO create_Cvg_Amt_Calc;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_cvg_amt_calc_mthd_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_Cvg_Amt_Calc;
    -- NOCOPY Changes
    p_cvg_amt_calc_mthd_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number := null ;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
    --
end create_Cvg_Amt_Calc;
-- ----------------------------------------------------------------------------
-- |------------------------< update_Cvg_Amt_Calc >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_Cvg_Amt_Calc
  (p_validate                       in  boolean   default false
  ,p_cvg_amt_calc_mthd_id           in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_name                           in  varchar2  default hr_api.g_varchar2
  ,p_incrmt_val                     in  number    default hr_api.g_number
  ,p_mx_val                         in  number    default hr_api.g_number
  ,p_mn_val                         in  number    default hr_api.g_number
  ,p_no_mx_val_dfnd_flag            in  varchar2  default hr_api.g_varchar2
  ,p_no_mn_val_dfnd_flag            in  varchar2  default hr_api.g_varchar2
  ,p_rndg_cd                        in  varchar2  default hr_api.g_varchar2
  ,p_rndg_rl                        in  number    default hr_api.g_number
  ,p_lwr_lmt_val                    in  number    default hr_api.g_number
  ,p_lwr_lmt_calc_rl                in  number    default hr_api.g_number
  ,p_upr_lmt_val                    in  number    default hr_api.g_number
  ,p_upr_lmt_calc_rl                in  number    default hr_api.g_number
  ,p_val                            in  number    default hr_api.g_number
  ,p_val_ovrid_alwd_flag            in  varchar2  default hr_api.g_varchar2
  ,p_val_calc_rl                    in  number    default hr_api.g_number
  ,p_uom                            in  varchar2  default hr_api.g_varchar2
  ,p_nnmntry_uom                    in  varchar2  default hr_api.g_varchar2
  ,p_bndry_perd_cd                  in  varchar2  default hr_api.g_varchar2
  ,p_bnft_typ_cd                    in  varchar2  default hr_api.g_varchar2
  ,p_cvg_mlt_cd                     in  varchar2  default hr_api.g_varchar2
  ,p_rt_typ_cd                      in  varchar2  default hr_api.g_varchar2
  ,p_dflt_val                       in  number    default hr_api.g_number
  ,p_entr_val_at_enrt_flag          in  varchar2  default hr_api.g_varchar2
  ,p_dflt_flag                      in  varchar2  default hr_api.g_varchar2
  ,p_comp_lvl_fctr_id               in  number    default hr_api.g_number
  ,p_oipl_id                        in  number    default hr_api.g_number
  ,p_pl_id                          in  number    default hr_api.g_number
  ,p_plip_id                        in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_ccm_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_ccm_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_ccm_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_ccm_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_ccm_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_ccm_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_ccm_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_ccm_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_ccm_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_ccm_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_ccm_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_ccm_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_ccm_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_ccm_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_ccm_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_ccm_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_ccm_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_ccm_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_ccm_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_ccm_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_ccm_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_ccm_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_ccm_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_ccm_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_ccm_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_ccm_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_ccm_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_ccm_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_ccm_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_ccm_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_ccm_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Cvg_Amt_Calc';
  l_object_version_number ben_cvg_amt_calc_mthd_f.object_version_number%TYPE;
  l_effective_start_date ben_cvg_amt_calc_mthd_f.effective_start_date%TYPE;
  l_effective_end_date ben_cvg_amt_calc_mthd_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_Cvg_Amt_Calc;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_Cvg_Amt_Calc
    --
    ben_Cvg_Amt_Calc_bk2.update_Cvg_Amt_Calc_b
      (p_cvg_amt_calc_mthd_id           =>  p_cvg_amt_calc_mthd_id
      ,p_name                           =>  p_name
      ,p_incrmt_val                     =>  p_incrmt_val
      ,p_mx_val                         =>  p_mx_val
      ,p_mn_val                         =>  p_mn_val
      ,p_no_mx_val_dfnd_flag            =>  p_no_mx_val_dfnd_flag
      ,p_no_mn_val_dfnd_flag            =>  p_no_mn_val_dfnd_flag
      ,p_rndg_cd                        =>  p_rndg_cd
      ,p_rndg_rl                        =>  p_rndg_rl
      ,p_lwr_lmt_val                    =>  p_lwr_lmt_val
      ,p_lwr_lmt_calc_rl                =>  p_lwr_lmt_calc_rl
      ,p_upr_lmt_val                    =>  p_upr_lmt_val
      ,p_upr_lmt_calc_rl                =>  p_upr_lmt_calc_rl
      ,p_val                            =>  p_val
      ,p_val_ovrid_alwd_flag            =>  p_val_ovrid_alwd_flag
      ,p_val_calc_rl                    =>  p_val_calc_rl
      ,p_uom                            =>  p_uom
      ,p_nnmntry_uom                    =>  p_nnmntry_uom
      ,p_bndry_perd_cd                  =>  p_bndry_perd_cd
      ,p_bnft_typ_cd                    =>  p_bnft_typ_cd
      ,p_cvg_mlt_cd                     =>  p_cvg_mlt_cd
      ,p_rt_typ_cd                      =>  p_rt_typ_cd
      ,p_dflt_val                       =>  p_dflt_val
      ,p_entr_val_at_enrt_flag          =>  p_entr_val_at_enrt_flag
      ,p_dflt_flag                      =>  p_dflt_flag
      ,p_comp_lvl_fctr_id               =>  p_comp_lvl_fctr_id
      ,p_oipl_id                        =>  p_oipl_id
      ,p_pl_id                          =>  p_pl_id
      ,p_plip_id                        =>  p_plip_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_ccm_attribute_category         =>  p_ccm_attribute_category
      ,p_ccm_attribute1                 =>  p_ccm_attribute1
      ,p_ccm_attribute2                 =>  p_ccm_attribute2
      ,p_ccm_attribute3                 =>  p_ccm_attribute3
      ,p_ccm_attribute4                 =>  p_ccm_attribute4
      ,p_ccm_attribute5                 =>  p_ccm_attribute5
      ,p_ccm_attribute6                 =>  p_ccm_attribute6
      ,p_ccm_attribute7                 =>  p_ccm_attribute7
      ,p_ccm_attribute8                 =>  p_ccm_attribute8
      ,p_ccm_attribute9                 =>  p_ccm_attribute9
      ,p_ccm_attribute10                =>  p_ccm_attribute10
      ,p_ccm_attribute11                =>  p_ccm_attribute11
      ,p_ccm_attribute12                =>  p_ccm_attribute12
      ,p_ccm_attribute13                =>  p_ccm_attribute13
      ,p_ccm_attribute14                =>  p_ccm_attribute14
      ,p_ccm_attribute15                =>  p_ccm_attribute15
      ,p_ccm_attribute16                =>  p_ccm_attribute16
      ,p_ccm_attribute17                =>  p_ccm_attribute17
      ,p_ccm_attribute18                =>  p_ccm_attribute18
      ,p_ccm_attribute19                =>  p_ccm_attribute19
      ,p_ccm_attribute20                =>  p_ccm_attribute20
      ,p_ccm_attribute21                =>  p_ccm_attribute21
      ,p_ccm_attribute22                =>  p_ccm_attribute22
      ,p_ccm_attribute23                =>  p_ccm_attribute23
      ,p_ccm_attribute24                =>  p_ccm_attribute24
      ,p_ccm_attribute25                =>  p_ccm_attribute25
      ,p_ccm_attribute26                =>  p_ccm_attribute26
      ,p_ccm_attribute27                =>  p_ccm_attribute27
      ,p_ccm_attribute28                =>  p_ccm_attribute28
      ,p_ccm_attribute29                =>  p_ccm_attribute29
      ,p_ccm_attribute30                =>  p_ccm_attribute30
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_datetrack_mode                 =>  p_datetrack_mode);
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Cvg_Amt_Calc'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of update_Cvg_Amt_Calc
    --
  end;
  --
  ben_ccm_upd.upd
    (p_cvg_amt_calc_mthd_id          => p_cvg_amt_calc_mthd_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_name                          => p_name
    ,p_incrmt_val                    => p_incrmt_val
    ,p_mx_val                        => p_mx_val
    ,p_mn_val                        => p_mn_val
    ,p_no_mx_val_dfnd_flag           => p_no_mx_val_dfnd_flag
    ,p_no_mn_val_dfnd_flag           => p_no_mn_val_dfnd_flag
    ,p_rndg_cd                       => p_rndg_cd
    ,p_rndg_rl                       => p_rndg_rl
    ,p_lwr_lmt_val                   => p_lwr_lmt_val
    ,p_lwr_lmt_calc_rl               => p_lwr_lmt_calc_rl
    ,p_upr_lmt_val                   => p_upr_lmt_val
    ,p_upr_lmt_calc_rl               => p_upr_lmt_calc_rl
    ,p_val                           => p_val
    ,p_val_ovrid_alwd_flag           => p_val_ovrid_alwd_flag
    ,p_val_calc_rl                   => p_val_calc_rl
    ,p_uom                           => p_uom
    ,p_nnmntry_uom                   => p_nnmntry_uom
    ,p_bndry_perd_cd                 => p_bndry_perd_cd
    ,p_bnft_typ_cd                   => p_bnft_typ_cd
    ,p_cvg_mlt_cd                    => p_cvg_mlt_cd
    ,p_rt_typ_cd                     => p_rt_typ_cd
    ,p_dflt_val                      => p_dflt_val
    ,p_entr_val_at_enrt_flag         => p_entr_val_at_enrt_flag
    ,p_dflt_flag                     => p_dflt_flag
    ,p_comp_lvl_fctr_id              => p_comp_lvl_fctr_id
    ,p_oipl_id                       => p_oipl_id
    ,p_pl_id                         => p_pl_id
    ,p_plip_id                       => p_plip_id
    ,p_business_group_id             => p_business_group_id
    ,p_ccm_attribute_category        => p_ccm_attribute_category
    ,p_ccm_attribute1                => p_ccm_attribute1
    ,p_ccm_attribute2                => p_ccm_attribute2
    ,p_ccm_attribute3                => p_ccm_attribute3
    ,p_ccm_attribute4                => p_ccm_attribute4
    ,p_ccm_attribute5                => p_ccm_attribute5
    ,p_ccm_attribute6                => p_ccm_attribute6
    ,p_ccm_attribute7                => p_ccm_attribute7
    ,p_ccm_attribute8                => p_ccm_attribute8
    ,p_ccm_attribute9                => p_ccm_attribute9
    ,p_ccm_attribute10               => p_ccm_attribute10
    ,p_ccm_attribute11               => p_ccm_attribute11
    ,p_ccm_attribute12               => p_ccm_attribute12
    ,p_ccm_attribute13               => p_ccm_attribute13
    ,p_ccm_attribute14               => p_ccm_attribute14
    ,p_ccm_attribute15               => p_ccm_attribute15
    ,p_ccm_attribute16               => p_ccm_attribute16
    ,p_ccm_attribute17               => p_ccm_attribute17
    ,p_ccm_attribute18               => p_ccm_attribute18
    ,p_ccm_attribute19               => p_ccm_attribute19
    ,p_ccm_attribute20               => p_ccm_attribute20
    ,p_ccm_attribute21               => p_ccm_attribute21
    ,p_ccm_attribute22               => p_ccm_attribute22
    ,p_ccm_attribute23               => p_ccm_attribute23
    ,p_ccm_attribute24               => p_ccm_attribute24
    ,p_ccm_attribute25               => p_ccm_attribute25
    ,p_ccm_attribute26               => p_ccm_attribute26
    ,p_ccm_attribute27               => p_ccm_attribute27
    ,p_ccm_attribute28               => p_ccm_attribute28
    ,p_ccm_attribute29               => p_ccm_attribute29
    ,p_ccm_attribute30               => p_ccm_attribute30
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode);
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_Cvg_Amt_Calc
    --
    ben_Cvg_Amt_Calc_bk2.update_Cvg_Amt_Calc_a
      (p_cvg_amt_calc_mthd_id           =>  p_cvg_amt_calc_mthd_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_name                           =>  p_name
      ,p_incrmt_val                     =>  p_incrmt_val
      ,p_mx_val                         =>  p_mx_val
      ,p_mn_val                         =>  p_mn_val
      ,p_no_mx_val_dfnd_flag            =>  p_no_mx_val_dfnd_flag
      ,p_no_mn_val_dfnd_flag            =>  p_no_mn_val_dfnd_flag
      ,p_rndg_cd                        =>  p_rndg_cd
      ,p_rndg_rl                        =>  p_rndg_rl
      ,p_lwr_lmt_val                    =>  p_lwr_lmt_val
      ,p_lwr_lmt_calc_rl                =>  p_lwr_lmt_calc_rl
      ,p_upr_lmt_val                    =>  p_upr_lmt_val
      ,p_upr_lmt_calc_rl                =>  p_upr_lmt_calc_rl
      ,p_val                            =>  p_val
      ,p_val_ovrid_alwd_flag            =>  p_val_ovrid_alwd_flag
      ,p_val_calc_rl                    =>  p_val_calc_rl
      ,p_uom                            =>  p_uom
      ,p_nnmntry_uom                    =>  p_nnmntry_uom
      ,p_bndry_perd_cd                  =>  p_bndry_perd_cd
      ,p_bnft_typ_cd                    =>  p_bnft_typ_cd
      ,p_cvg_mlt_cd                     =>  p_cvg_mlt_cd
      ,p_rt_typ_cd                      =>  p_rt_typ_cd
      ,p_dflt_val                       =>  p_dflt_val
      ,p_entr_val_at_enrt_flag          =>  p_entr_val_at_enrt_flag
      ,p_dflt_flag                      =>  p_dflt_flag
      ,p_comp_lvl_fctr_id               =>  p_comp_lvl_fctr_id
      ,p_oipl_id                        =>  p_oipl_id
      ,p_pl_id                          =>  p_pl_id
      ,p_plip_id                        =>  p_plip_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_ccm_attribute_category         =>  p_ccm_attribute_category
      ,p_ccm_attribute1                 =>  p_ccm_attribute1
      ,p_ccm_attribute2                 =>  p_ccm_attribute2
      ,p_ccm_attribute3                 =>  p_ccm_attribute3
      ,p_ccm_attribute4                 =>  p_ccm_attribute4
      ,p_ccm_attribute5                 =>  p_ccm_attribute5
      ,p_ccm_attribute6                 =>  p_ccm_attribute6
      ,p_ccm_attribute7                 =>  p_ccm_attribute7
      ,p_ccm_attribute8                 =>  p_ccm_attribute8
      ,p_ccm_attribute9                 =>  p_ccm_attribute9
      ,p_ccm_attribute10                =>  p_ccm_attribute10
      ,p_ccm_attribute11                =>  p_ccm_attribute11
      ,p_ccm_attribute12                =>  p_ccm_attribute12
      ,p_ccm_attribute13                =>  p_ccm_attribute13
      ,p_ccm_attribute14                =>  p_ccm_attribute14
      ,p_ccm_attribute15                =>  p_ccm_attribute15
      ,p_ccm_attribute16                =>  p_ccm_attribute16
      ,p_ccm_attribute17                =>  p_ccm_attribute17
      ,p_ccm_attribute18                =>  p_ccm_attribute18
      ,p_ccm_attribute19                =>  p_ccm_attribute19
      ,p_ccm_attribute20                =>  p_ccm_attribute20
      ,p_ccm_attribute21                =>  p_ccm_attribute21
      ,p_ccm_attribute22                =>  p_ccm_attribute22
      ,p_ccm_attribute23                =>  p_ccm_attribute23
      ,p_ccm_attribute24                =>  p_ccm_attribute24
      ,p_ccm_attribute25                =>  p_ccm_attribute25
      ,p_ccm_attribute26                =>  p_ccm_attribute26
      ,p_ccm_attribute27                =>  p_ccm_attribute27
      ,p_ccm_attribute28                =>  p_ccm_attribute28
      ,p_ccm_attribute29                =>  p_ccm_attribute29
      ,p_ccm_attribute30                =>  p_ccm_attribute30
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_datetrack_mode                 =>  p_datetrack_mode);
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Cvg_Amt_Calc'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of update_Cvg_Amt_Calc
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
    ROLLBACK TO update_Cvg_Amt_Calc;
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
    ROLLBACK TO update_Cvg_Amt_Calc;
    -- NOCOPY Changes
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number := l_object_version_number ;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
    --
end update_Cvg_Amt_Calc;
-- ----------------------------------------------------------------------------
-- |-----------------------------< delete_Cvg_Amt_Calc >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Cvg_Amt_Calc
  (p_validate                       in  boolean  default false
  ,p_cvg_amt_calc_mthd_id           in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Cvg_Amt_Calc';
  l_object_version_number ben_cvg_amt_calc_mthd_f.object_version_number%TYPE;
  l_effective_start_date ben_cvg_amt_calc_mthd_f.effective_start_date%TYPE;
  l_effective_end_date ben_cvg_amt_calc_mthd_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_Cvg_Amt_Calc;
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
    -- Start of API User Hook for the before hook of delete_Cvg_Amt_Calc
    --
    ben_Cvg_Amt_Calc_bk3.delete_Cvg_Amt_Calc_b
      (p_cvg_amt_calc_mthd_id           =>  p_cvg_amt_calc_mthd_id
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_datetrack_mode                 =>  p_datetrack_mode);
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Cvg_Amt_Calc'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of delete_Cvg_Amt_Calc
    --
  end;
  --
  ben_ccm_del.del
    (p_cvg_amt_calc_mthd_id          => p_cvg_amt_calc_mthd_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode);
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_Cvg_Amt_Calc
    --
    ben_Cvg_Amt_Calc_bk3.delete_Cvg_Amt_Calc_a
      (p_cvg_amt_calc_mthd_id           =>  p_cvg_amt_calc_mthd_id
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
        (p_module_name => 'DELETE_Cvg_Amt_Calc'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of delete_Cvg_Amt_Calc
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
    ROLLBACK TO delete_Cvg_Amt_Calc;
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
    ROLLBACK TO delete_Cvg_Amt_Calc;
    -- NOCOPY Changes
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number := l_object_version_number ;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
    --
end delete_Cvg_Amt_Calc;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (p_cvg_amt_calc_mthd_id           in     number
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
  ben_ccm_shd.lck
     (p_cvg_amt_calc_mthd_id       => p_cvg_amt_calc_mthd_id
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
end ben_Cvg_Amt_Calc_api;

/
