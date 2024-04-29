--------------------------------------------------------
--  DDL for Package Body BEN_ELIG_PERSON_OPTION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ELIG_PERSON_OPTION_API" as
/* $Header: beepoapi.pkb 120.0 2005/05/28 02:41:54 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_Elig_Person_Option_api.';
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_Elig_Person_Option >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_Elig_Person_Option
(
   p_validate                       in boolean    default false
  ,p_elig_per_opt_id                out nocopy number
  ,p_elig_per_id                    in  number    default null
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_prtn_ovridn_flag               in  varchar2  default null
  ,p_prtn_ovridn_thru_dt            in  date      default null
  ,p_no_mx_prtn_ovrid_thru_flag     in  varchar2  default null
  ,p_elig_flag                      in  varchar2  default null
  ,p_prtn_strt_dt                   in  date      default null
  ,p_prtn_end_dt                    in  date      default null
  ,p_wait_perd_cmpltn_date            in  date      default null
  ,p_wait_perd_strt_dt              in  date      default null
  ,p_prtn_ovridn_rsn_cd             in  varchar2  default null
  ,p_pct_fl_tm_val                  in  number    default null
  ,p_opt_id                         in  number    default null
  ,p_per_in_ler_id                  in  number    default null
  ,p_rt_comp_ref_amt                in  number    default null
  ,p_rt_cmbn_age_n_los_val          in  number    default null
  ,p_rt_comp_ref_uom                in  varchar2  default null
  ,p_rt_age_val                     in  number    default null
  ,p_rt_los_val                     in  number    default null
  ,p_rt_hrs_wkd_val                 in  number    default null
  ,p_rt_hrs_wkd_bndry_perd_cd       in  varchar2  default null
  ,p_rt_age_uom                     in  varchar2  default null
  ,p_rt_los_uom                     in  varchar2  default null
  ,p_rt_pct_fl_tm_val               in  number    default null
  ,p_rt_frz_los_flag                in  varchar2  default 'N'
  ,p_rt_frz_age_flag                in  varchar2  default 'N'
  ,p_rt_frz_cmp_lvl_flag            in  varchar2  default 'N'
  ,p_rt_frz_pct_fl_tm_flag          in  varchar2  default 'N'
  ,p_rt_frz_hrs_wkd_flag            in  varchar2  default 'N'
  ,p_rt_frz_comb_age_and_los_flag   in  varchar2  default 'N'
  ,p_comp_ref_amt                   in  number    default null
  ,p_cmbn_age_n_los_val             in  number    default null
  ,p_comp_ref_uom                   in  varchar2  default null
  ,p_age_val                        in  number    default null
  ,p_los_val                        in  number    default null
  ,p_hrs_wkd_val                    in  number    default null
  ,p_hrs_wkd_bndry_perd_cd          in  varchar2  default null
  ,p_age_uom                        in  varchar2  default null
  ,p_los_uom                        in  varchar2  default null
  ,p_frz_los_flag                   in  varchar2  default 'N'
  ,p_frz_age_flag                   in  varchar2  default 'N'
  ,p_frz_cmp_lvl_flag               in  varchar2  default 'N'
  ,p_frz_pct_fl_tm_flag             in  varchar2  default 'N'
  ,p_frz_hrs_wkd_flag               in  varchar2  default 'N'
  ,p_frz_comb_age_and_los_flag      in  varchar2  default 'N'
  ,p_ovrid_svc_dt                   in  date      default null
  ,p_inelg_rsn_cd                   in  varchar2  default null
  ,p_once_r_cntug_cd                in  varchar2  default null
  ,p_oipl_ordr_num                  in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_epo_attribute_category         in  varchar2  default null
  ,p_epo_attribute1                 in  varchar2  default null
  ,p_epo_attribute2                 in  varchar2  default null
  ,p_epo_attribute3                 in  varchar2  default null
  ,p_epo_attribute4                 in  varchar2  default null
  ,p_epo_attribute5                 in  varchar2  default null
  ,p_epo_attribute6                 in  varchar2  default null
  ,p_epo_attribute7                 in  varchar2  default null
  ,p_epo_attribute8                 in  varchar2  default null
  ,p_epo_attribute9                 in  varchar2  default null
  ,p_epo_attribute10                in  varchar2  default null
  ,p_epo_attribute11                in  varchar2  default null
  ,p_epo_attribute12                in  varchar2  default null
  ,p_epo_attribute13                in  varchar2  default null
  ,p_epo_attribute14                in  varchar2  default null
  ,p_epo_attribute15                in  varchar2  default null
  ,p_epo_attribute16                in  varchar2  default null
  ,p_epo_attribute17                in  varchar2  default null
  ,p_epo_attribute18                in  varchar2  default null
  ,p_epo_attribute19                in  varchar2  default null
  ,p_epo_attribute20                in  varchar2  default null
  ,p_epo_attribute21                in  varchar2  default null
  ,p_epo_attribute22                in  varchar2  default null
  ,p_epo_attribute23                in  varchar2  default null
  ,p_epo_attribute24                in  varchar2  default null
  ,p_epo_attribute25                in  varchar2  default null
  ,p_epo_attribute26                in  varchar2  default null
  ,p_epo_attribute27                in  varchar2  default null
  ,p_epo_attribute28                in  varchar2  default null
  ,p_epo_attribute29                in  varchar2  default null
  ,p_epo_attribute30                in  varchar2  default null
  ,p_request_id                     in  number    default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_program_update_date            in  date      default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_override_validation            in  boolean   default false
  )
is
  --
  -- Declare cursors and local variables
  --
  l_elig_per_opt_id ben_elig_per_opt_f.elig_per_opt_id%TYPE;
  l_effective_start_date ben_elig_per_opt_f.effective_start_date%TYPE;
  l_effective_end_date ben_elig_per_opt_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_Elig_Person_Option';
  l_object_version_number ben_elig_per_opt_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_Elig_Person_Option;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_Elig_Person_Option
    --
    ben_Elig_Person_Option_bk1.create_Elig_Person_Option_b
      (
       p_elig_per_id                    =>  p_elig_per_id
      ,p_prtn_ovridn_flag               =>  p_prtn_ovridn_flag
      ,p_prtn_ovridn_thru_dt            =>  p_prtn_ovridn_thru_dt
      ,p_no_mx_prtn_ovrid_thru_flag     =>  p_no_mx_prtn_ovrid_thru_flag
      ,p_elig_flag                      =>  p_elig_flag
      ,p_prtn_strt_dt                   =>  p_prtn_strt_dt
      ,p_prtn_end_dt                    =>  p_prtn_end_dt
      ,p_wait_perd_cmpltn_date            =>  p_wait_perd_cmpltn_date
      ,p_wait_perd_strt_dt              =>  p_wait_perd_strt_dt
      ,p_prtn_ovridn_rsn_cd             =>  p_prtn_ovridn_rsn_cd
      ,p_pct_fl_tm_val                  =>  p_pct_fl_tm_val
      ,p_opt_id                         =>  p_opt_id
      ,p_per_in_ler_id                  =>  p_per_in_ler_id
      ,p_rt_comp_ref_amt                =>  p_rt_comp_ref_amt
      ,p_rt_cmbn_age_n_los_val          =>  p_rt_cmbn_age_n_los_val
      ,p_rt_comp_ref_uom                =>  p_rt_comp_ref_uom
      ,p_rt_age_val                     =>  p_rt_age_val
      ,p_rt_los_val                     =>  p_rt_los_val
      ,p_rt_hrs_wkd_val                 =>  p_rt_hrs_wkd_val
      ,p_rt_hrs_wkd_bndry_perd_cd       =>  p_rt_hrs_wkd_bndry_perd_cd
      ,p_rt_age_uom                     =>  p_rt_age_uom
      ,p_rt_los_uom                     =>  p_rt_los_uom
      ,p_rt_pct_fl_tm_val               =>  p_rt_pct_fl_tm_val
      ,p_rt_frz_los_flag                =>  p_rt_frz_los_flag
      ,p_rt_frz_age_flag                =>  p_rt_frz_age_flag
      ,p_rt_frz_cmp_lvl_flag            =>  p_rt_frz_cmp_lvl_flag
      ,p_rt_frz_pct_fl_tm_flag          =>  p_rt_frz_pct_fl_tm_flag
      ,p_rt_frz_hrs_wkd_flag            =>  p_rt_frz_hrs_wkd_flag
      ,p_rt_frz_comb_age_and_los_flag   =>  p_rt_frz_comb_age_and_los_flag
      ,p_comp_ref_amt                   =>  p_comp_ref_amt
      ,p_cmbn_age_n_los_val             =>  p_cmbn_age_n_los_val
      ,p_comp_ref_uom                   =>  p_comp_ref_uom
      ,p_age_val                        =>  p_age_val
      ,p_los_val                        =>  p_los_val
      ,p_hrs_wkd_val                    =>  p_hrs_wkd_val
      ,p_hrs_wkd_bndry_perd_cd          =>  p_hrs_wkd_bndry_perd_cd
      ,p_age_uom                        =>  p_age_uom
      ,p_los_uom                        =>  p_los_uom
      ,p_frz_los_flag                   =>  p_frz_los_flag
      ,p_frz_age_flag                   =>  p_frz_age_flag
      ,p_frz_cmp_lvl_flag               =>  p_frz_cmp_lvl_flag
      ,p_frz_pct_fl_tm_flag             =>  p_frz_pct_fl_tm_flag
      ,p_frz_hrs_wkd_flag               =>  p_frz_hrs_wkd_flag
      ,p_frz_comb_age_and_los_flag      =>  p_frz_comb_age_and_los_flag
      ,p_ovrid_svc_dt                   =>  p_ovrid_svc_dt
      ,p_inelg_rsn_cd                   =>  p_inelg_rsn_cd
      ,p_once_r_cntug_cd                =>  p_once_r_cntug_cd
      ,p_oipl_ordr_num                  =>  p_oipl_ordr_num
      ,p_business_group_id              =>  p_business_group_id
      ,p_epo_attribute_category         =>  p_epo_attribute_category
      ,p_epo_attribute1                 =>  p_epo_attribute1
      ,p_epo_attribute2                 =>  p_epo_attribute2
      ,p_epo_attribute3                 =>  p_epo_attribute3
      ,p_epo_attribute4                 =>  p_epo_attribute4
      ,p_epo_attribute5                 =>  p_epo_attribute5
      ,p_epo_attribute6                 =>  p_epo_attribute6
      ,p_epo_attribute7                 =>  p_epo_attribute7
      ,p_epo_attribute8                 =>  p_epo_attribute8
      ,p_epo_attribute9                 =>  p_epo_attribute9
      ,p_epo_attribute10                =>  p_epo_attribute10
      ,p_epo_attribute11                =>  p_epo_attribute11
      ,p_epo_attribute12                =>  p_epo_attribute12
      ,p_epo_attribute13                =>  p_epo_attribute13
      ,p_epo_attribute14                =>  p_epo_attribute14
      ,p_epo_attribute15                =>  p_epo_attribute15
      ,p_epo_attribute16                =>  p_epo_attribute16
      ,p_epo_attribute17                =>  p_epo_attribute17
      ,p_epo_attribute18                =>  p_epo_attribute18
      ,p_epo_attribute19                =>  p_epo_attribute19
      ,p_epo_attribute20                =>  p_epo_attribute20
      ,p_epo_attribute21                =>  p_epo_attribute21
      ,p_epo_attribute22                =>  p_epo_attribute22
      ,p_epo_attribute23                =>  p_epo_attribute23
      ,p_epo_attribute24                =>  p_epo_attribute24
      ,p_epo_attribute25                =>  p_epo_attribute25
      ,p_epo_attribute26                =>  p_epo_attribute26
      ,p_epo_attribute27                =>  p_epo_attribute27
      ,p_epo_attribute28                =>  p_epo_attribute28
      ,p_epo_attribute29                =>  p_epo_attribute29
      ,p_epo_attribute30                =>  p_epo_attribute30
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_Elig_Person_Option'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_Elig_Person_Option
    --
  end;
  --
  ben_epo_ins.ins
    (
     p_elig_per_opt_id               => l_elig_per_opt_id
    ,p_elig_per_id                   => p_elig_per_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_prtn_ovridn_flag              => p_prtn_ovridn_flag
    ,p_prtn_ovridn_thru_dt           => p_prtn_ovridn_thru_dt
    ,p_no_mx_prtn_ovrid_thru_flag    => p_no_mx_prtn_ovrid_thru_flag
    ,p_elig_flag                     => p_elig_flag
    ,p_prtn_strt_dt                  => p_prtn_strt_dt
    ,p_prtn_end_dt                   => p_prtn_end_dt
    ,p_wait_perd_cmpltn_date           => p_wait_perd_cmpltn_date
    ,p_wait_perd_strt_dt             => p_wait_perd_strt_dt
    ,p_prtn_ovridn_rsn_cd            => p_prtn_ovridn_rsn_cd
    ,p_pct_fl_tm_val                 => p_pct_fl_tm_val
    ,p_opt_id                        => p_opt_id
    ,p_per_in_ler_id                 => p_per_in_ler_id
    ,p_rt_comp_ref_amt               => p_rt_comp_ref_amt
    ,p_rt_cmbn_age_n_los_val         => p_rt_cmbn_age_n_los_val
    ,p_rt_comp_ref_uom               => p_rt_comp_ref_uom
    ,p_rt_age_val                    => p_rt_age_val
    ,p_rt_los_val                    => p_rt_los_val
    ,p_rt_hrs_wkd_val                => p_rt_hrs_wkd_val
    ,p_rt_hrs_wkd_bndry_perd_cd      => p_rt_hrs_wkd_bndry_perd_cd
    ,p_rt_age_uom                    => p_rt_age_uom
    ,p_rt_los_uom                    => p_rt_los_uom
    ,p_rt_pct_fl_tm_val              => p_rt_pct_fl_tm_val
    ,p_rt_frz_los_flag               => p_rt_frz_los_flag
    ,p_rt_frz_age_flag               => p_rt_frz_age_flag
    ,p_rt_frz_cmp_lvl_flag           => p_rt_frz_cmp_lvl_flag
    ,p_rt_frz_pct_fl_tm_flag         => p_rt_frz_pct_fl_tm_flag
    ,p_rt_frz_hrs_wkd_flag           => p_rt_frz_hrs_wkd_flag
    ,p_rt_frz_comb_age_and_los_flag  => p_rt_frz_comb_age_and_los_flag
    ,p_comp_ref_amt                  => p_comp_ref_amt
    ,p_cmbn_age_n_los_val            => p_cmbn_age_n_los_val
    ,p_comp_ref_uom                  => p_comp_ref_uom
    ,p_age_val                       => p_age_val
    ,p_los_val                       => p_los_val
    ,p_hrs_wkd_val                   => p_hrs_wkd_val
    ,p_hrs_wkd_bndry_perd_cd         => p_hrs_wkd_bndry_perd_cd
    ,p_age_uom                       => p_age_uom
    ,p_los_uom                       => p_los_uom
    ,p_frz_los_flag                  => p_frz_los_flag
    ,p_frz_age_flag                  => p_frz_age_flag
    ,p_frz_cmp_lvl_flag              => p_frz_cmp_lvl_flag
    ,p_frz_pct_fl_tm_flag            => p_frz_pct_fl_tm_flag
    ,p_frz_hrs_wkd_flag              => p_frz_hrs_wkd_flag
    ,p_frz_comb_age_and_los_flag     => p_frz_comb_age_and_los_flag
    ,p_ovrid_svc_dt                  => p_ovrid_svc_dt
    ,p_inelg_rsn_cd                  => p_inelg_rsn_cd
    ,p_once_r_cntug_cd               => p_once_r_cntug_cd
    ,p_oipl_ordr_num                 =>  p_oipl_ordr_num
    ,p_business_group_id             => p_business_group_id
    ,p_epo_attribute_category        => p_epo_attribute_category
    ,p_epo_attribute1                => p_epo_attribute1
    ,p_epo_attribute2                => p_epo_attribute2
    ,p_epo_attribute3                => p_epo_attribute3
    ,p_epo_attribute4                => p_epo_attribute4
    ,p_epo_attribute5                => p_epo_attribute5
    ,p_epo_attribute6                => p_epo_attribute6
    ,p_epo_attribute7                => p_epo_attribute7
    ,p_epo_attribute8                => p_epo_attribute8
    ,p_epo_attribute9                => p_epo_attribute9
    ,p_epo_attribute10               => p_epo_attribute10
    ,p_epo_attribute11               => p_epo_attribute11
    ,p_epo_attribute12               => p_epo_attribute12
    ,p_epo_attribute13               => p_epo_attribute13
    ,p_epo_attribute14               => p_epo_attribute14
    ,p_epo_attribute15               => p_epo_attribute15
    ,p_epo_attribute16               => p_epo_attribute16
    ,p_epo_attribute17               => p_epo_attribute17
    ,p_epo_attribute18               => p_epo_attribute18
    ,p_epo_attribute19               => p_epo_attribute19
    ,p_epo_attribute20               => p_epo_attribute20
    ,p_epo_attribute21               => p_epo_attribute21
    ,p_epo_attribute22               => p_epo_attribute22
    ,p_epo_attribute23               => p_epo_attribute23
    ,p_epo_attribute24               => p_epo_attribute24
    ,p_epo_attribute25               => p_epo_attribute25
    ,p_epo_attribute26               => p_epo_attribute26
    ,p_epo_attribute27               => p_epo_attribute27
    ,p_epo_attribute28               => p_epo_attribute28
    ,p_epo_attribute29               => p_epo_attribute29
    ,p_epo_attribute30               => p_epo_attribute30
    ,p_request_id                    => p_request_id
    ,p_program_application_id        => p_program_application_id
    ,p_program_id                    => p_program_id
    ,p_program_update_date           => p_program_update_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_override_validation           => p_override_validation
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_Elig_Person_Option
    --
    ben_Elig_Person_Option_bk1.create_Elig_Person_Option_a
      (
       p_elig_per_opt_id                =>  l_elig_per_opt_id
      ,p_elig_per_id                    =>  p_elig_per_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_prtn_ovridn_flag               =>  p_prtn_ovridn_flag
      ,p_prtn_ovridn_thru_dt            =>  p_prtn_ovridn_thru_dt
      ,p_no_mx_prtn_ovrid_thru_flag     =>  p_no_mx_prtn_ovrid_thru_flag
      ,p_elig_flag                      =>  p_elig_flag
      ,p_prtn_strt_dt                   =>  p_prtn_strt_dt
      ,p_prtn_end_dt                    =>  p_prtn_end_dt
      ,p_wait_perd_cmpltn_date            =>  p_wait_perd_cmpltn_date
      ,p_wait_perd_strt_dt              =>  p_wait_perd_strt_dt
      ,p_prtn_ovridn_rsn_cd             =>  p_prtn_ovridn_rsn_cd
      ,p_pct_fl_tm_val                  =>  p_pct_fl_tm_val
      ,p_opt_id                         =>  p_opt_id
      ,p_per_in_ler_id                  =>  p_per_in_ler_id
      ,p_rt_comp_ref_amt                =>  p_rt_comp_ref_amt
      ,p_rt_cmbn_age_n_los_val          =>  p_rt_cmbn_age_n_los_val
      ,p_rt_comp_ref_uom                =>  p_rt_comp_ref_uom
      ,p_rt_age_val                     =>  p_rt_age_val
      ,p_rt_los_val                     =>  p_rt_los_val
      ,p_rt_hrs_wkd_val                 =>  p_rt_hrs_wkd_val
      ,p_rt_hrs_wkd_bndry_perd_cd       =>  p_rt_hrs_wkd_bndry_perd_cd
      ,p_rt_age_uom                     =>  p_rt_age_uom
      ,p_rt_los_uom                     =>  p_rt_los_uom
      ,p_rt_pct_fl_tm_val               =>  p_rt_pct_fl_tm_val
      ,p_rt_frz_los_flag                =>  p_rt_frz_los_flag
      ,p_rt_frz_age_flag                =>  p_rt_frz_age_flag
      ,p_rt_frz_cmp_lvl_flag            =>  p_rt_frz_cmp_lvl_flag
      ,p_rt_frz_pct_fl_tm_flag          =>  p_rt_frz_pct_fl_tm_flag
      ,p_rt_frz_hrs_wkd_flag            =>  p_rt_frz_hrs_wkd_flag
      ,p_rt_frz_comb_age_and_los_flag   =>  p_rt_frz_comb_age_and_los_flag
      ,p_comp_ref_amt                   =>  p_comp_ref_amt
      ,p_cmbn_age_n_los_val             =>  p_cmbn_age_n_los_val
      ,p_comp_ref_uom                   =>  p_comp_ref_uom
      ,p_age_val                        =>  p_age_val
      ,p_los_val                        =>  p_los_val
      ,p_hrs_wkd_val                    =>  p_hrs_wkd_val
      ,p_hrs_wkd_bndry_perd_cd          =>  p_hrs_wkd_bndry_perd_cd
      ,p_age_uom                        =>  p_age_uom
      ,p_los_uom                        =>  p_los_uom
      ,p_frz_los_flag                   =>  p_frz_los_flag
      ,p_frz_age_flag                   =>  p_frz_age_flag
      ,p_frz_cmp_lvl_flag               =>  p_frz_cmp_lvl_flag
      ,p_frz_pct_fl_tm_flag             =>  p_frz_pct_fl_tm_flag
      ,p_frz_hrs_wkd_flag               =>  p_frz_hrs_wkd_flag
      ,p_frz_comb_age_and_los_flag      =>  p_frz_comb_age_and_los_flag
      ,p_ovrid_svc_dt                   =>  p_ovrid_svc_dt
      ,p_inelg_rsn_cd                   =>  p_inelg_rsn_cd
      ,p_once_r_cntug_cd                =>  p_once_r_cntug_cd
      ,p_oipl_ordr_num                  =>  p_oipl_ordr_num
      ,p_business_group_id              =>  p_business_group_id
      ,p_epo_attribute_category         =>  p_epo_attribute_category
      ,p_epo_attribute1                 =>  p_epo_attribute1
      ,p_epo_attribute2                 =>  p_epo_attribute2
      ,p_epo_attribute3                 =>  p_epo_attribute3
      ,p_epo_attribute4                 =>  p_epo_attribute4
      ,p_epo_attribute5                 =>  p_epo_attribute5
      ,p_epo_attribute6                 =>  p_epo_attribute6
      ,p_epo_attribute7                 =>  p_epo_attribute7
      ,p_epo_attribute8                 =>  p_epo_attribute8
      ,p_epo_attribute9                 =>  p_epo_attribute9
      ,p_epo_attribute10                =>  p_epo_attribute10
      ,p_epo_attribute11                =>  p_epo_attribute11
      ,p_epo_attribute12                =>  p_epo_attribute12
      ,p_epo_attribute13                =>  p_epo_attribute13
      ,p_epo_attribute14                =>  p_epo_attribute14
      ,p_epo_attribute15                =>  p_epo_attribute15
      ,p_epo_attribute16                =>  p_epo_attribute16
      ,p_epo_attribute17                =>  p_epo_attribute17
      ,p_epo_attribute18                =>  p_epo_attribute18
      ,p_epo_attribute19                =>  p_epo_attribute19
      ,p_epo_attribute20                =>  p_epo_attribute20
      ,p_epo_attribute21                =>  p_epo_attribute21
      ,p_epo_attribute22                =>  p_epo_attribute22
      ,p_epo_attribute23                =>  p_epo_attribute23
      ,p_epo_attribute24                =>  p_epo_attribute24
      ,p_epo_attribute25                =>  p_epo_attribute25
      ,p_epo_attribute26                =>  p_epo_attribute26
      ,p_epo_attribute27                =>  p_epo_attribute27
      ,p_epo_attribute28                =>  p_epo_attribute28
      ,p_epo_attribute29                =>  p_epo_attribute29
      ,p_epo_attribute30                =>  p_epo_attribute30
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                      => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_Elig_Person_Option'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_Elig_Person_Option
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
  p_elig_per_opt_id := l_elig_per_opt_id;
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
    ROLLBACK TO create_Elig_Person_Option;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_elig_per_opt_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_Elig_Person_Option;
    --
    p_elig_per_opt_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
    raise;
    --
end create_Elig_Person_Option;
--
-- ----------------------------------------------------------------------------
-- |------------------< create_perf_Elig_Person_Option >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_perf_Elig_Person_Option
  (p_validate                       in boolean    default false
  ,p_elig_per_opt_id                out nocopy number
  ,p_elig_per_id                    in  number    default null
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_prtn_ovridn_flag               in  varchar2  default null
  ,p_prtn_ovridn_thru_dt            in  date      default null
  ,p_no_mx_prtn_ovrid_thru_flag     in  varchar2  default null
  ,p_elig_flag                      in  varchar2  default null
  ,p_prtn_strt_dt                   in  date      default null
  ,p_prtn_end_dt                    in  date      default null
  ,p_wait_perd_cmpltn_date            in  date      default null
  ,p_wait_perd_strt_dt              in  date      default null
  ,p_prtn_ovridn_rsn_cd             in  varchar2  default null
  ,p_pct_fl_tm_val                  in  number    default null
  ,p_opt_id                         in  number    default null
  ,p_per_in_ler_id                  in  number    default null
  ,p_rt_comp_ref_amt                in  number    default null
  ,p_rt_cmbn_age_n_los_val          in  number    default null
  ,p_rt_comp_ref_uom                in  varchar2  default null
  ,p_rt_age_val                     in  number    default null
  ,p_rt_los_val                     in  number    default null
  ,p_rt_hrs_wkd_val                 in  number    default null
  ,p_rt_hrs_wkd_bndry_perd_cd       in  varchar2  default null
  ,p_rt_age_uom                     in  varchar2  default null
  ,p_rt_los_uom                     in  varchar2  default null
  ,p_rt_pct_fl_tm_val               in  number    default null
  ,p_rt_frz_los_flag                in  varchar2  default 'N'
  ,p_rt_frz_age_flag                in  varchar2  default 'N'
  ,p_rt_frz_cmp_lvl_flag            in  varchar2  default 'N'
  ,p_rt_frz_pct_fl_tm_flag          in  varchar2  default 'N'
  ,p_rt_frz_hrs_wkd_flag            in  varchar2  default 'N'
  ,p_rt_frz_comb_age_and_los_flag   in  varchar2  default 'N'
  ,p_comp_ref_amt                   in  number    default null
  ,p_cmbn_age_n_los_val             in  number    default null
  ,p_comp_ref_uom                   in  varchar2  default null
  ,p_age_val                        in  number    default null
  ,p_los_val                        in  number    default null
  ,p_hrs_wkd_val                    in  number    default null
  ,p_hrs_wkd_bndry_perd_cd          in  varchar2  default null
  ,p_age_uom                        in  varchar2  default null
  ,p_los_uom                        in  varchar2  default null
  ,p_frz_los_flag                   in  varchar2  default 'N'
  ,p_frz_age_flag                   in  varchar2  default 'N'
  ,p_frz_cmp_lvl_flag               in  varchar2  default 'N'
  ,p_frz_pct_fl_tm_flag             in  varchar2  default 'N'
  ,p_frz_hrs_wkd_flag               in  varchar2  default 'N'
  ,p_frz_comb_age_and_los_flag      in  varchar2  default 'N'
  ,p_ovrid_svc_dt                   in  date      default null
  ,p_inelg_rsn_cd                   in  varchar2  default null
  ,p_once_r_cntug_cd                in  varchar2  default null
  ,p_oipl_ordr_num                  in  number    default null
  ,p_business_group_id              in  number    default null
  ,p_epo_attribute_category         in  varchar2  default null
  ,p_epo_attribute1                 in  varchar2  default null
  ,p_epo_attribute2                 in  varchar2  default null
  ,p_epo_attribute3                 in  varchar2  default null
  ,p_epo_attribute4                 in  varchar2  default null
  ,p_epo_attribute5                 in  varchar2  default null
  ,p_epo_attribute6                 in  varchar2  default null
  ,p_epo_attribute7                 in  varchar2  default null
  ,p_epo_attribute8                 in  varchar2  default null
  ,p_epo_attribute9                 in  varchar2  default null
  ,p_epo_attribute10                in  varchar2  default null
  ,p_epo_attribute11                in  varchar2  default null
  ,p_epo_attribute12                in  varchar2  default null
  ,p_epo_attribute13                in  varchar2  default null
  ,p_epo_attribute14                in  varchar2  default null
  ,p_epo_attribute15                in  varchar2  default null
  ,p_epo_attribute16                in  varchar2  default null
  ,p_epo_attribute17                in  varchar2  default null
  ,p_epo_attribute18                in  varchar2  default null
  ,p_epo_attribute19                in  varchar2  default null
  ,p_epo_attribute20                in  varchar2  default null
  ,p_epo_attribute21                in  varchar2  default null
  ,p_epo_attribute22                in  varchar2  default null
  ,p_epo_attribute23                in  varchar2  default null
  ,p_epo_attribute24                in  varchar2  default null
  ,p_epo_attribute25                in  varchar2  default null
  ,p_epo_attribute26                in  varchar2  default null
  ,p_epo_attribute27                in  varchar2  default null
  ,p_epo_attribute28                in  varchar2  default null
  ,p_epo_attribute29                in  varchar2  default null
  ,p_epo_attribute30                in  varchar2  default null
  ,p_request_id                     in  number    default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_program_update_date            in  date      default null
  ,p_object_version_number          out nocopy number
  ,p_effective_date                 in  date
  ,p_override_validation            in  boolean   default false
  )
is
  --
  l_proc varchar2(72) := g_package||'create_perf_Elig_Person_Option';
  --
  -- Declare cursors and local variables
  --
  l_object_version_number ben_elig_per_opt_f.object_version_number%TYPE;
  l_elig_per_opt_id       ben_elig_per_opt_f.elig_per_opt_id%TYPE;
  l_effective_start_date  ben_elig_per_opt_f.effective_start_date%TYPE;
  l_effective_end_date    ben_elig_per_opt_f.effective_end_date%TYPE;
  --
  l_created_by            ben_elig_per_opt_f.created_by%TYPE;
  l_creation_date         ben_elig_per_opt_f.creation_date%TYPE;
  l_last_update_date      ben_elig_per_opt_f.last_update_date%TYPE;
  l_last_updated_by       ben_elig_per_opt_f.last_updated_by%TYPE;
  l_last_update_login     ben_elig_per_opt_f.last_update_login%TYPE;
  --
  Cursor C_Sel1 is select ben_elig_per_opt_f_s.nextval from sys.dual;
  --
  l_minmax_rec            ben_batch_dt_api.gtyp_dtsum_row;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_perf_Elig_Person_Option;
  --
  -- Derive maximum start and end dates
  --
  l_effective_start_date := p_effective_date;
  l_effective_end_date   := hr_api.g_eot;
  --
  -- Elig Per
  --
  if p_elig_per_id is not null then
    --
    ben_batch_dt_api.get_elig_perobject
      (p_elig_per_id => p_elig_per_id
      ,p_rec         => l_minmax_rec
      );
    --
    ben_batch_dt_api.Get_DtIns_Start_and_End_Dates
      (p_effective_date => p_effective_date
      ,p_parcolumn_name => 'elig_per_id'
      ,p_min_esd        => l_minmax_rec.min_esd
      ,p_max_eed        => l_minmax_rec.max_eed
      --
      ,p_esd            => l_effective_start_date
      ,p_eed            => l_effective_end_date
      );
    --
  end if;
  --
  -- Insert the row
  --
  --   Set the object version number for the insert
  --
  l_object_version_number := 1;
  --
  ben_epo_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into l_elig_per_opt_id;
  Close C_Sel1;
  --
  -- Insert the row into: ben_elig_per_f
  --
  hr_utility.set_location('Insert: '||l_proc, 5);
    hr_utility.set_location('Ins EPO:'||l_proc, 5);
  insert into ben_elig_per_opt_f
  ( elig_per_opt_id,
    elig_per_id,
    effective_start_date,
    effective_end_date,
    prtn_ovridn_flag,
    prtn_ovridn_thru_dt,
    no_mx_prtn_ovrid_thru_flag,
    elig_flag,
    prtn_strt_dt,
    prtn_end_dt,
    wait_perd_cmpltn_date,
    wait_perd_strt_dt,
    prtn_ovridn_rsn_cd,
    pct_fl_tm_val,
    opt_id,
    per_in_ler_id,
    rt_comp_ref_amt,
    rt_cmbn_age_n_los_val,
    rt_comp_ref_uom,
    rt_age_val,
    rt_los_val,
    rt_hrs_wkd_val,
    rt_hrs_wkd_bndry_perd_cd,
    rt_age_uom,
    rt_los_uom,
    rt_pct_fl_tm_val,
    rt_frz_los_flag,
    rt_frz_age_flag,
    rt_frz_cmp_lvl_flag,
    rt_frz_pct_fl_tm_flag,
    rt_frz_hrs_wkd_flag,
    rt_frz_comb_age_and_los_flag,
    comp_ref_amt,
    cmbn_age_n_los_val,
    comp_ref_uom,
    age_val,
    los_val,
    hrs_wkd_val,
    hrs_wkd_bndry_perd_cd,
    age_uom,
    los_uom,
    frz_los_flag,
    frz_age_flag,
    frz_cmp_lvl_flag,
    frz_pct_fl_tm_flag,
    frz_hrs_wkd_flag,
    frz_comb_age_and_los_flag,
    ovrid_svc_dt,
    inelg_rsn_cd,
    once_r_cntug_cd,
    oipl_ordr_num,
    business_group_id,
    epo_attribute_category,
    epo_attribute1,
    epo_attribute2,
    epo_attribute3,
    epo_attribute4,
    epo_attribute5,
    epo_attribute6,
    epo_attribute7,
    epo_attribute8,
    epo_attribute9,
    epo_attribute10,
    epo_attribute11,
    epo_attribute12,
    epo_attribute13,
    epo_attribute14,
    epo_attribute15,
    epo_attribute16,
    epo_attribute17,
    epo_attribute18,
    epo_attribute19,
    epo_attribute20,
    epo_attribute21,
    epo_attribute22,
    epo_attribute23,
    epo_attribute24,
    epo_attribute25,
    epo_attribute26,
    epo_attribute27,
    epo_attribute28,
    epo_attribute29,
    epo_attribute30,
    request_id,
    program_application_id,
    program_id,
    program_update_date,
    object_version_number,
    created_by,
    creation_date,
    last_update_date,
    last_updated_by,
    last_update_login
  )
  Values
  ( l_elig_per_opt_id,
    p_elig_per_id,
    l_effective_start_date,
    l_effective_end_date,
    p_prtn_ovridn_flag,
    p_prtn_ovridn_thru_dt,
    p_no_mx_prtn_ovrid_thru_flag,
    p_elig_flag,
    p_prtn_strt_dt,
    p_prtn_end_dt,
    p_wait_perd_cmpltn_date,
    p_wait_perd_strt_dt,
    p_prtn_ovridn_rsn_cd,
    p_pct_fl_tm_val,
    p_opt_id,
    p_per_in_ler_id,
    p_rt_comp_ref_amt,
    p_rt_cmbn_age_n_los_val,
    p_rt_comp_ref_uom,
    p_rt_age_val,
    p_rt_los_val,
    p_rt_hrs_wkd_val,
    p_rt_hrs_wkd_bndry_perd_cd,
    p_rt_age_uom,
    p_rt_los_uom,
    p_rt_pct_fl_tm_val,
    p_rt_frz_los_flag,
    p_rt_frz_age_flag,
    p_rt_frz_cmp_lvl_flag,
    p_rt_frz_pct_fl_tm_flag,
    p_rt_frz_hrs_wkd_flag,
    p_rt_frz_comb_age_and_los_flag,
    p_comp_ref_amt,
    p_cmbn_age_n_los_val,
    p_comp_ref_uom,
    p_age_val,
    p_los_val,
    p_hrs_wkd_val,
    p_hrs_wkd_bndry_perd_cd,
    p_age_uom,
    p_los_uom,
    p_frz_los_flag,
    p_frz_age_flag,
    p_frz_cmp_lvl_flag,
    p_frz_pct_fl_tm_flag,
    p_frz_hrs_wkd_flag,
    p_frz_comb_age_and_los_flag,
    p_ovrid_svc_dt,
    p_inelg_rsn_cd,
    p_once_r_cntug_cd,
    p_oipl_ordr_num,
    p_business_group_id,
    p_epo_attribute_category,
    p_epo_attribute1,
    p_epo_attribute2,
    p_epo_attribute3,
    p_epo_attribute4,
    p_epo_attribute5,
    p_epo_attribute6,
    p_epo_attribute7,
    p_epo_attribute8,
    p_epo_attribute9,
    p_epo_attribute10,
    p_epo_attribute11,
    p_epo_attribute12,
    p_epo_attribute13,
    p_epo_attribute14,
    p_epo_attribute15,
    p_epo_attribute16,
    p_epo_attribute17,
    p_epo_attribute18,
    p_epo_attribute19,
    p_epo_attribute20,
    p_epo_attribute21,
    p_epo_attribute22,
    p_epo_attribute23,
    p_epo_attribute24,
    p_epo_attribute25,
    p_epo_attribute26,
    p_epo_attribute27,
    p_epo_attribute28,
    p_epo_attribute29,
    p_epo_attribute30,
    p_request_id,
    p_program_application_id,
    p_program_id,
    p_program_update_date,
    l_object_version_number,
    l_created_by,
    l_creation_date,
    l_last_update_date,
    l_last_updated_by,
    l_last_update_login
    );
  hr_utility.set_location('Dn Insert: '||l_proc, 5);
  --
  ben_epo_shd.g_api_dml := false;   -- Unset the api dml status
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_elig_per_opt_id       := l_elig_per_opt_id;
  p_effective_start_date  := l_effective_start_date;
  p_effective_end_date    := l_effective_end_date;
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
    ROLLBACK TO create_perf_Elig_Person_Option;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_elig_per_opt_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_perf_Elig_Person_Option;
    --
    p_elig_per_opt_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
    raise;
    --
end create_perf_Elig_Person_Option;
-- ----------------------------------------------------------------------------
-- |------------------------< update_Elig_Person_Option >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_Elig_Person_Option
  (p_validate                       in  boolean   default false
  ,p_elig_per_opt_id                in  number
  ,p_elig_per_id                    in  number    default hr_api.g_number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_prtn_ovridn_flag               in  varchar2  default hr_api.g_varchar2
  ,p_prtn_ovridn_thru_dt            in  date      default hr_api.g_date
  ,p_no_mx_prtn_ovrid_thru_flag     in  varchar2  default hr_api.g_varchar2
  ,p_elig_flag                      in  varchar2  default hr_api.g_varchar2
  ,p_prtn_strt_dt                   in  date      default hr_api.g_date
  ,p_prtn_end_dt                    in  date      default hr_api.g_date
  ,p_wait_perd_cmpltn_date            in  date      default hr_api.g_date
  ,p_wait_perd_strt_dt              in  date      default hr_api.g_date
  ,p_prtn_ovridn_rsn_cd             in  varchar2  default hr_api.g_varchar2
  ,p_pct_fl_tm_val                  in  number    default hr_api.g_number
  ,p_opt_id                         in  number    default hr_api.g_number
  ,p_per_in_ler_id                  in  number    default hr_api.g_number
  ,p_rt_comp_ref_amt                in  number    default hr_api.g_number
  ,p_rt_cmbn_age_n_los_val          in  number    default hr_api.g_number
  ,p_rt_comp_ref_uom                in  varchar2  default hr_api.g_varchar2
  ,p_rt_age_val                     in  number    default hr_api.g_number
  ,p_rt_los_val                     in  number    default hr_api.g_number
  ,p_rt_hrs_wkd_val                 in  number    default hr_api.g_number
  ,p_rt_hrs_wkd_bndry_perd_cd       in  varchar2  default hr_api.g_varchar2
  ,p_rt_age_uom                     in  varchar2  default hr_api.g_varchar2
  ,p_rt_los_uom                     in  varchar2  default hr_api.g_varchar2
  ,p_rt_pct_fl_tm_val               in  number    default hr_api.g_number
  ,p_rt_frz_los_flag                in  varchar2  default hr_api.g_varchar2
  ,p_rt_frz_age_flag                in  varchar2  default hr_api.g_varchar2
  ,p_rt_frz_cmp_lvl_flag            in  varchar2  default hr_api.g_varchar2
  ,p_rt_frz_pct_fl_tm_flag          in  varchar2  default hr_api.g_varchar2
  ,p_rt_frz_hrs_wkd_flag            in  varchar2  default hr_api.g_varchar2
  ,p_rt_frz_comb_age_and_los_flag   in  varchar2  default hr_api.g_varchar2
  ,p_comp_ref_amt                   in  number    default hr_api.g_number
  ,p_cmbn_age_n_los_val             in  number    default hr_api.g_number
  ,p_comp_ref_uom                   in  varchar2  default hr_api.g_varchar2
  ,p_age_val                        in  number    default hr_api.g_number
  ,p_los_val                        in  number    default hr_api.g_number
  ,p_hrs_wkd_val                    in  number    default hr_api.g_number
  ,p_hrs_wkd_bndry_perd_cd          in  varchar2  default hr_api.g_varchar2
  ,p_age_uom                        in  varchar2  default hr_api.g_varchar2
  ,p_los_uom                        in  varchar2  default hr_api.g_varchar2
  ,p_frz_los_flag                   in  varchar2  default hr_api.g_varchar2
  ,p_frz_age_flag                   in  varchar2  default hr_api.g_varchar2
  ,p_frz_cmp_lvl_flag               in  varchar2  default hr_api.g_varchar2
  ,p_frz_pct_fl_tm_flag             in  varchar2  default hr_api.g_varchar2
  ,p_frz_hrs_wkd_flag               in  varchar2  default hr_api.g_varchar2
  ,p_frz_comb_age_and_los_flag      in  varchar2  default hr_api.g_varchar2
  ,p_ovrid_svc_dt                   in  date      default hr_api.g_date
  ,p_inelg_rsn_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_once_r_cntug_cd                in  varchar2  default hr_api.g_varchar2
  ,p_oipl_ordr_num                  in  number    default hr_api.g_number
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_epo_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_epo_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_epo_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_epo_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_epo_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_epo_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_epo_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_epo_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_epo_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_epo_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_epo_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_epo_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_epo_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_epo_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_epo_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_epo_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_epo_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_epo_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_epo_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_epo_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_epo_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_epo_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_epo_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_epo_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_epo_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_epo_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_epo_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_epo_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_epo_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_epo_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_epo_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_request_id                     in  number    default hr_api.g_number
  ,p_program_application_id         in  number    default hr_api.g_number
  ,p_program_id                     in  number    default hr_api.g_number
  ,p_program_update_date            in  date      default hr_api.g_date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Elig_Person_Option';
  l_object_version_number ben_elig_per_opt_f.object_version_number%TYPE;
  l_effective_start_date ben_elig_per_opt_f.effective_start_date%TYPE;
  l_effective_end_date ben_elig_per_opt_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_Elig_Person_Option;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_Elig_Person_Option
    --
    ben_Elig_Person_Option_bk2.update_Elig_Person_Option_b
      (
       p_elig_per_opt_id                =>  p_elig_per_opt_id
      ,p_elig_per_id                    =>  p_elig_per_id
      ,p_prtn_ovridn_flag               =>  p_prtn_ovridn_flag
      ,p_prtn_ovridn_thru_dt            =>  p_prtn_ovridn_thru_dt
      ,p_no_mx_prtn_ovrid_thru_flag     =>  p_no_mx_prtn_ovrid_thru_flag
      ,p_elig_flag                      =>  p_elig_flag
      ,p_prtn_strt_dt                   =>  p_prtn_strt_dt
      ,p_prtn_end_dt                    =>  p_prtn_end_dt
      ,p_wait_perd_cmpltn_date            =>  p_wait_perd_cmpltn_date
      ,p_wait_perd_strt_dt              =>  p_wait_perd_strt_dt
      ,p_prtn_ovridn_rsn_cd             =>  p_prtn_ovridn_rsn_cd
      ,p_pct_fl_tm_val                  =>  p_pct_fl_tm_val
      ,p_opt_id                         =>  p_opt_id
      ,p_per_in_ler_id                  =>  p_per_in_ler_id
      ,p_rt_comp_ref_amt                =>  p_rt_comp_ref_amt
      ,p_rt_cmbn_age_n_los_val          =>  p_rt_cmbn_age_n_los_val
      ,p_rt_comp_ref_uom                =>  p_rt_comp_ref_uom
      ,p_rt_age_val                     =>  p_rt_age_val
      ,p_rt_los_val                     =>  p_rt_los_val
      ,p_rt_hrs_wkd_val                 =>  p_rt_hrs_wkd_val
      ,p_rt_hrs_wkd_bndry_perd_cd       =>  p_rt_hrs_wkd_bndry_perd_cd
      ,p_rt_age_uom                     =>  p_rt_age_uom
      ,p_rt_los_uom                     =>  p_rt_los_uom
      ,p_rt_pct_fl_tm_val               =>  p_rt_pct_fl_tm_val
      ,p_rt_frz_los_flag                =>  p_rt_frz_los_flag
      ,p_rt_frz_age_flag                =>  p_rt_frz_age_flag
      ,p_rt_frz_cmp_lvl_flag            =>  p_rt_frz_cmp_lvl_flag
      ,p_rt_frz_pct_fl_tm_flag          =>  p_rt_frz_pct_fl_tm_flag
      ,p_rt_frz_hrs_wkd_flag            =>  p_rt_frz_hrs_wkd_flag
      ,p_rt_frz_comb_age_and_los_flag   =>  p_rt_frz_comb_age_and_los_flag
      ,p_comp_ref_amt                   =>  p_comp_ref_amt
      ,p_cmbn_age_n_los_val             =>  p_cmbn_age_n_los_val
      ,p_comp_ref_uom                   =>  p_comp_ref_uom
      ,p_age_val                        =>  p_age_val
      ,p_los_val                        =>  p_los_val
      ,p_hrs_wkd_val                    =>  p_hrs_wkd_val
      ,p_hrs_wkd_bndry_perd_cd          =>  p_hrs_wkd_bndry_perd_cd
      ,p_age_uom                        =>  p_age_uom
      ,p_los_uom                        =>  p_los_uom
      ,p_frz_los_flag                   =>  p_frz_los_flag
      ,p_frz_age_flag                   =>  p_frz_age_flag
      ,p_frz_cmp_lvl_flag               =>  p_frz_cmp_lvl_flag
      ,p_frz_pct_fl_tm_flag             =>  p_frz_pct_fl_tm_flag
      ,p_frz_hrs_wkd_flag               =>  p_frz_hrs_wkd_flag
      ,p_frz_comb_age_and_los_flag      =>  p_frz_comb_age_and_los_flag
      ,p_ovrid_svc_dt                   =>  p_ovrid_svc_dt
      ,p_inelg_rsn_cd                   =>  p_inelg_rsn_cd
      ,p_once_r_cntug_cd                =>  p_once_r_cntug_cd
      ,p_oipl_ordr_num                  =>  p_oipl_ordr_num
      ,p_business_group_id              =>  p_business_group_id
      ,p_epo_attribute_category         =>  p_epo_attribute_category
      ,p_epo_attribute1                 =>  p_epo_attribute1
      ,p_epo_attribute2                 =>  p_epo_attribute2
      ,p_epo_attribute3                 =>  p_epo_attribute3
      ,p_epo_attribute4                 =>  p_epo_attribute4
      ,p_epo_attribute5                 =>  p_epo_attribute5
      ,p_epo_attribute6                 =>  p_epo_attribute6
      ,p_epo_attribute7                 =>  p_epo_attribute7
      ,p_epo_attribute8                 =>  p_epo_attribute8
      ,p_epo_attribute9                 =>  p_epo_attribute9
      ,p_epo_attribute10                =>  p_epo_attribute10
      ,p_epo_attribute11                =>  p_epo_attribute11
      ,p_epo_attribute12                =>  p_epo_attribute12
      ,p_epo_attribute13                =>  p_epo_attribute13
      ,p_epo_attribute14                =>  p_epo_attribute14
      ,p_epo_attribute15                =>  p_epo_attribute15
      ,p_epo_attribute16                =>  p_epo_attribute16
      ,p_epo_attribute17                =>  p_epo_attribute17
      ,p_epo_attribute18                =>  p_epo_attribute18
      ,p_epo_attribute19                =>  p_epo_attribute19
      ,p_epo_attribute20                =>  p_epo_attribute20
      ,p_epo_attribute21                =>  p_epo_attribute21
      ,p_epo_attribute22                =>  p_epo_attribute22
      ,p_epo_attribute23                =>  p_epo_attribute23
      ,p_epo_attribute24                =>  p_epo_attribute24
      ,p_epo_attribute25                =>  p_epo_attribute25
      ,p_epo_attribute26                =>  p_epo_attribute26
      ,p_epo_attribute27                =>  p_epo_attribute27
      ,p_epo_attribute28                =>  p_epo_attribute28
      ,p_epo_attribute29                =>  p_epo_attribute29
      ,p_epo_attribute30                =>  p_epo_attribute30
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Elig_Person_Option'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_Elig_Person_Option
    --
  end;
  --
  ben_epo_upd.upd
    (
     p_elig_per_opt_id               => p_elig_per_opt_id
    ,p_elig_per_id                   => p_elig_per_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_prtn_ovridn_flag              => p_prtn_ovridn_flag
    ,p_prtn_ovridn_thru_dt           => p_prtn_ovridn_thru_dt
    ,p_no_mx_prtn_ovrid_thru_flag    => p_no_mx_prtn_ovrid_thru_flag
    ,p_elig_flag                     => p_elig_flag
    ,p_prtn_strt_dt                  => p_prtn_strt_dt
    ,p_prtn_end_dt                   => p_prtn_end_dt
    ,p_wait_perd_cmpltn_date           => p_wait_perd_cmpltn_date
    ,p_wait_perd_strt_dt             => p_wait_perd_strt_dt
    ,p_prtn_ovridn_rsn_cd            => p_prtn_ovridn_rsn_cd
    ,p_pct_fl_tm_val                 => p_pct_fl_tm_val
    ,p_opt_id                        => p_opt_id
    ,p_per_in_ler_id                 => p_per_in_ler_id
    ,p_rt_comp_ref_amt               => p_rt_comp_ref_amt
    ,p_rt_cmbn_age_n_los_val         => p_rt_cmbn_age_n_los_val
    ,p_rt_comp_ref_uom               => p_rt_comp_ref_uom
    ,p_rt_age_val                    => p_rt_age_val
    ,p_rt_los_val                    => p_rt_los_val
    ,p_rt_hrs_wkd_val                => p_rt_hrs_wkd_val
    ,p_rt_hrs_wkd_bndry_perd_cd      => p_rt_hrs_wkd_bndry_perd_cd
    ,p_rt_age_uom                    => p_rt_age_uom
    ,p_rt_los_uom                    => p_rt_los_uom
    ,p_rt_pct_fl_tm_val              => p_rt_pct_fl_tm_val
    ,p_rt_frz_los_flag               => p_rt_frz_los_flag
    ,p_rt_frz_age_flag               => p_rt_frz_age_flag
    ,p_rt_frz_cmp_lvl_flag           => p_rt_frz_cmp_lvl_flag
    ,p_rt_frz_pct_fl_tm_flag         => p_rt_frz_pct_fl_tm_flag
    ,p_rt_frz_hrs_wkd_flag           => p_rt_frz_hrs_wkd_flag
    ,p_rt_frz_comb_age_and_los_flag  => p_rt_frz_comb_age_and_los_flag
    ,p_comp_ref_amt                  => p_comp_ref_amt
    ,p_cmbn_age_n_los_val            => p_cmbn_age_n_los_val
    ,p_comp_ref_uom                  => p_comp_ref_uom
    ,p_age_val                       => p_age_val
    ,p_los_val                       => p_los_val
    ,p_hrs_wkd_val                   => p_hrs_wkd_val
    ,p_hrs_wkd_bndry_perd_cd         => p_hrs_wkd_bndry_perd_cd
    ,p_age_uom                       => p_age_uom
    ,p_los_uom                       => p_los_uom
    ,p_frz_los_flag                  => p_frz_los_flag
    ,p_frz_age_flag                  => p_frz_age_flag
    ,p_frz_cmp_lvl_flag              => p_frz_cmp_lvl_flag
    ,p_frz_pct_fl_tm_flag            => p_frz_pct_fl_tm_flag
    ,p_frz_hrs_wkd_flag              => p_frz_hrs_wkd_flag
    ,p_frz_comb_age_and_los_flag     => p_frz_comb_age_and_los_flag
    ,p_ovrid_svc_dt                  => p_ovrid_svc_dt
    ,p_inelg_rsn_cd                  => p_inelg_rsn_cd
    ,p_once_r_cntug_cd               => p_once_r_cntug_cd
    ,p_oipl_ordr_num                  =>  p_oipl_ordr_num
    ,p_business_group_id             => p_business_group_id
    ,p_epo_attribute_category        => p_epo_attribute_category
    ,p_epo_attribute1                => p_epo_attribute1
    ,p_epo_attribute2                => p_epo_attribute2
    ,p_epo_attribute3                => p_epo_attribute3
    ,p_epo_attribute4                => p_epo_attribute4
    ,p_epo_attribute5                => p_epo_attribute5
    ,p_epo_attribute6                => p_epo_attribute6
    ,p_epo_attribute7                => p_epo_attribute7
    ,p_epo_attribute8                => p_epo_attribute8
    ,p_epo_attribute9                => p_epo_attribute9
    ,p_epo_attribute10               => p_epo_attribute10
    ,p_epo_attribute11               => p_epo_attribute11
    ,p_epo_attribute12               => p_epo_attribute12
    ,p_epo_attribute13               => p_epo_attribute13
    ,p_epo_attribute14               => p_epo_attribute14
    ,p_epo_attribute15               => p_epo_attribute15
    ,p_epo_attribute16               => p_epo_attribute16
    ,p_epo_attribute17               => p_epo_attribute17
    ,p_epo_attribute18               => p_epo_attribute18
    ,p_epo_attribute19               => p_epo_attribute19
    ,p_epo_attribute20               => p_epo_attribute20
    ,p_epo_attribute21               => p_epo_attribute21
    ,p_epo_attribute22               => p_epo_attribute22
    ,p_epo_attribute23               => p_epo_attribute23
    ,p_epo_attribute24               => p_epo_attribute24
    ,p_epo_attribute25               => p_epo_attribute25
    ,p_epo_attribute26               => p_epo_attribute26
    ,p_epo_attribute27               => p_epo_attribute27
    ,p_epo_attribute28               => p_epo_attribute28
    ,p_epo_attribute29               => p_epo_attribute29
    ,p_epo_attribute30               => p_epo_attribute30
    ,p_request_id                    => p_request_id
    ,p_program_application_id        => p_program_application_id
    ,p_program_id                    => p_program_id
    ,p_program_update_date           => p_program_update_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_Elig_Person_Option
    --
    ben_Elig_Person_Option_bk2.update_Elig_Person_Option_a
      (
       p_elig_per_opt_id                =>  p_elig_per_opt_id
      ,p_elig_per_id                    =>  p_elig_per_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_prtn_ovridn_flag               =>  p_prtn_ovridn_flag
      ,p_prtn_ovridn_thru_dt            =>  p_prtn_ovridn_thru_dt
      ,p_no_mx_prtn_ovrid_thru_flag     =>  p_no_mx_prtn_ovrid_thru_flag
      ,p_elig_flag                      =>  p_elig_flag
      ,p_prtn_strt_dt                   =>  p_prtn_strt_dt
      ,p_prtn_end_dt                    =>  p_prtn_end_dt
      ,p_wait_perd_cmpltn_date            =>  p_wait_perd_cmpltn_date
      ,p_wait_perd_strt_dt              =>  p_wait_perd_Strt_dt
      ,p_prtn_ovridn_rsn_cd             =>  p_prtn_ovridn_rsn_cd
      ,p_pct_fl_tm_val                  =>  p_pct_fl_tm_val
      ,p_opt_id                         =>  p_opt_id
      ,p_per_in_ler_id                  =>  p_per_in_ler_id
      ,p_rt_comp_ref_amt                =>  p_rt_comp_ref_amt
      ,p_rt_cmbn_age_n_los_val          =>  p_rt_cmbn_age_n_los_val
      ,p_rt_comp_ref_uom                =>  p_rt_comp_ref_uom
      ,p_rt_age_val                     =>  p_rt_age_val
      ,p_rt_los_val                     =>  p_rt_los_val
      ,p_rt_hrs_wkd_val                 =>  p_rt_hrs_wkd_val
      ,p_rt_hrs_wkd_bndry_perd_cd       =>  p_rt_hrs_wkd_bndry_perd_cd
      ,p_rt_age_uom                     =>  p_rt_age_uom
      ,p_rt_los_uom                     =>  p_rt_los_uom
      ,p_rt_pct_fl_tm_val               =>  p_rt_pct_fl_tm_val
      ,p_rt_frz_los_flag                =>  p_rt_frz_los_flag
      ,p_rt_frz_age_flag                =>  p_rt_frz_age_flag
      ,p_rt_frz_cmp_lvl_flag            =>  p_rt_frz_cmp_lvl_flag
      ,p_rt_frz_pct_fl_tm_flag          =>  p_rt_frz_pct_fl_tm_flag
      ,p_rt_frz_hrs_wkd_flag            =>  p_rt_frz_hrs_wkd_flag
      ,p_rt_frz_comb_age_and_los_flag   =>  p_rt_frz_comb_age_and_los_flag
      ,p_comp_ref_amt                   =>  p_comp_ref_amt
      ,p_cmbn_age_n_los_val             =>  p_cmbn_age_n_los_val
      ,p_comp_ref_uom                   =>  p_comp_ref_uom
      ,p_age_val                        =>  p_age_val
      ,p_los_val                        =>  p_los_val
      ,p_hrs_wkd_val                    =>  p_hrs_wkd_val
      ,p_hrs_wkd_bndry_perd_cd          =>  p_hrs_wkd_bndry_perd_cd
      ,p_age_uom                        =>  p_age_uom
      ,p_los_uom                        =>  p_los_uom
      ,p_frz_los_flag                   =>  p_frz_los_flag
      ,p_frz_age_flag                   =>  p_frz_age_flag
      ,p_frz_cmp_lvl_flag               =>  p_frz_cmp_lvl_flag
      ,p_frz_pct_fl_tm_flag             =>  p_frz_pct_fl_tm_flag
      ,p_frz_hrs_wkd_flag               =>  p_frz_hrs_wkd_flag
      ,p_frz_comb_age_and_los_flag      =>  p_frz_comb_age_and_los_flag
      ,p_ovrid_svc_dt                   =>  p_ovrid_svc_dt
      ,p_inelg_rsn_cd                   =>  p_inelg_rsn_cd
      ,p_once_r_cntug_cd                =>  p_once_r_cntug_cd
      ,p_oipl_ordr_num                  =>  p_oipl_ordr_num
      ,p_business_group_id              =>  p_business_group_id
      ,p_epo_attribute_category         =>  p_epo_attribute_category
      ,p_epo_attribute1                 =>  p_epo_attribute1
      ,p_epo_attribute2                 =>  p_epo_attribute2
      ,p_epo_attribute3                 =>  p_epo_attribute3
      ,p_epo_attribute4                 =>  p_epo_attribute4
      ,p_epo_attribute5                 =>  p_epo_attribute5
      ,p_epo_attribute6                 =>  p_epo_attribute6
      ,p_epo_attribute7                 =>  p_epo_attribute7
      ,p_epo_attribute8                 =>  p_epo_attribute8
      ,p_epo_attribute9                 =>  p_epo_attribute9
      ,p_epo_attribute10                =>  p_epo_attribute10
      ,p_epo_attribute11                =>  p_epo_attribute11
      ,p_epo_attribute12                =>  p_epo_attribute12
      ,p_epo_attribute13                =>  p_epo_attribute13
      ,p_epo_attribute14                =>  p_epo_attribute14
      ,p_epo_attribute15                =>  p_epo_attribute15
      ,p_epo_attribute16                =>  p_epo_attribute16
      ,p_epo_attribute17                =>  p_epo_attribute17
      ,p_epo_attribute18                =>  p_epo_attribute18
      ,p_epo_attribute19                =>  p_epo_attribute19
      ,p_epo_attribute20                =>  p_epo_attribute20
      ,p_epo_attribute21                =>  p_epo_attribute21
      ,p_epo_attribute22                =>  p_epo_attribute22
      ,p_epo_attribute23                =>  p_epo_attribute23
      ,p_epo_attribute24                =>  p_epo_attribute24
      ,p_epo_attribute25                =>  p_epo_attribute25
      ,p_epo_attribute26                =>  p_epo_attribute26
      ,p_epo_attribute27                =>  p_epo_attribute27
      ,p_epo_attribute28                =>  p_epo_attribute28
      ,p_epo_attribute29                =>  p_epo_attribute29
      ,p_epo_attribute30                =>  p_epo_attribute30
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                     => trunc(p_effective_date)
      ,p_datetrack_mode                     => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Elig_Person_Option'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_Elig_Person_Option
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
    ROLLBACK TO update_Elig_Person_Option;
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
    ROLLBACK TO update_Elig_Person_Option;
    --
    p_object_version_number := l_object_version_number;
    p_effective_start_date := l_effective_start_date;
    p_effective_end_date := l_effective_end_date;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 70);
    --
    raise;
    --
end update_Elig_Person_Option;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_Elig_Person_Option >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Elig_Person_Option
  (p_validate                       in  boolean  default false
  ,p_elig_per_opt_id                in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Elig_Person_Option';
  l_object_version_number ben_elig_per_opt_f.object_version_number%TYPE;
  l_effective_start_date ben_elig_per_opt_f.effective_start_date%TYPE;
  l_effective_end_date ben_elig_per_opt_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_Elig_Person_Option;
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
    -- Start of API User Hook for the before hook of delete_Elig_Person_Option
    --
    ben_Elig_Person_Option_bk3.delete_Elig_Person_Option_b
      (
       p_elig_per_opt_id                =>  p_elig_per_opt_id
      ,p_object_version_number          =>  p_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Elig_Person_Option'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_Elig_Person_Option
    --
  end;
  --
  ben_epo_del.del
    (
     p_elig_per_opt_id               => p_elig_per_opt_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_Elig_Person_Option
    --
    ben_Elig_Person_Option_bk3.delete_Elig_Person_Option_a
      (
       p_elig_per_opt_id                =>  p_elig_per_opt_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_object_version_number          =>  l_object_version_number
    ,p_effective_date                      => trunc(p_effective_date)
    ,p_datetrack_mode                      => p_datetrack_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Elig_Person_Option'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_Elig_Person_Option
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
    ROLLBACK TO delete_Elig_Person_Option;
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
    ROLLBACK TO delete_Elig_Person_Option;
    --
    p_object_version_number := l_object_version_number;
    p_effective_start_date := l_effective_start_date;
    p_effective_end_date := l_effective_end_date;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 70);
    --
    raise;
    --
end delete_Elig_Person_Option;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_elig_per_opt_id                   in     number
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
  ben_epo_shd.lck
    (
      p_elig_per_opt_id                 => p_elig_per_opt_id
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
end ben_Elig_Person_Option_api;

/
