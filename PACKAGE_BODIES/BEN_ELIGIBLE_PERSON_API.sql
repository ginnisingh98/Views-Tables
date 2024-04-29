--------------------------------------------------------
--  DDL for Package Body BEN_ELIGIBLE_PERSON_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ELIGIBLE_PERSON_API" as
/* $Header: bepepapi.pkb 120.0 2005/05/28 10:38:50 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_Eligible_Person_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_Eligible_Person >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_Eligible_Person
  (p_validate                       in boolean    default false
  ,p_elig_per_id                    out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default null
  ,p_pl_id                          in  number    default null
  ,p_pgm_id                         in  number    default null
  ,p_plip_id                        in  number    default null
  ,p_ptip_id                        in  number    default null
  ,p_ler_id                         in  number    default null
  ,p_person_id                      in  number    default null
  ,p_per_in_ler_id                      in  number    default null
  ,p_dpnt_othr_pl_cvrd_rl_flag      in  varchar2  default 'N'
  ,p_prtn_ovridn_thru_dt            in  date      default null
  ,p_pl_key_ee_flag                 in  varchar2  default 'N'
  ,p_pl_hghly_compd_flag            in  varchar2  default 'N'
  ,p_elig_flag                      in  varchar2  default 'N'
  ,p_comp_ref_amt                   in  number    default null
  ,p_cmbn_age_n_los_val             in  number    default null
  ,p_comp_ref_uom                   in  varchar2  default null
  ,p_age_val                        in  number    default null
  ,p_los_val                        in  number    default null
  ,p_prtn_end_dt                    in  date      default null
  ,p_prtn_strt_dt                   in  date      default null
  ,p_wait_perd_cmpltn_dt            in  date      default null
  ,p_wait_perd_strt_dt              in  date      default null
  ,p_wv_ctfn_typ_cd                 in  varchar2  default null
  ,p_hrs_wkd_val                    in  number    default null
  ,p_hrs_wkd_bndry_perd_cd          in  varchar2  default null
  ,p_prtn_ovridn_flag               in  varchar2  default null
  ,p_no_mx_prtn_ovrid_thru_flag     in  varchar2  default 'N'
  ,p_prtn_ovridn_rsn_cd             in  varchar2  default null
  ,p_age_uom                        in  varchar2  default null
  ,p_los_uom                        in  varchar2  default null
  ,p_ovrid_svc_dt                   in  date      default null
  ,p_inelg_rsn_cd                   in  varchar2  default null
  ,p_frz_los_flag                   in  varchar2  default 'N'
  ,p_frz_age_flag                   in  varchar2  default 'N'
  ,p_frz_cmp_lvl_flag               in  varchar2  default 'N'
  ,p_frz_pct_fl_tm_flag             in  varchar2  default 'N'
  ,p_frz_hrs_wkd_flag               in  varchar2  default 'N'
  ,p_frz_comb_age_and_los_flag      in  varchar2  default 'N'
  ,p_dstr_rstcn_flag                in  varchar2  default 'N'
  ,p_pct_fl_tm_val                  in  number    default null
  ,p_wv_prtn_rsn_cd                 in  varchar2  default null
  ,p_pl_wvd_flag                    in  varchar2  default 'N'
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
  ,p_once_r_cntug_cd                in  varchar2  default null
  ,p_pl_ordr_num                    in  number    default null
  ,p_plip_ordr_num                  in  number    default null
  ,p_ptip_ordr_num                  in  number    default null
  ,p_pep_attribute_category         in  varchar2  default null
  ,p_pep_attribute1                 in  varchar2  default null
  ,p_pep_attribute2                 in  varchar2  default null
  ,p_pep_attribute3                 in  varchar2  default null
  ,p_pep_attribute4                 in  varchar2  default null
  ,p_pep_attribute5                 in  varchar2  default null
  ,p_pep_attribute6                 in  varchar2  default null
  ,p_pep_attribute7                 in  varchar2  default null
  ,p_pep_attribute8                 in  varchar2  default null
  ,p_pep_attribute9                 in  varchar2  default null
  ,p_pep_attribute10                in  varchar2  default null
  ,p_pep_attribute11                in  varchar2  default null
  ,p_pep_attribute12                in  varchar2  default null
  ,p_pep_attribute13                in  varchar2  default null
  ,p_pep_attribute14                in  varchar2  default null
  ,p_pep_attribute15                in  varchar2  default null
  ,p_pep_attribute16                in  varchar2  default null
  ,p_pep_attribute17                in  varchar2  default null
  ,p_pep_attribute18                in  varchar2  default null
  ,p_pep_attribute19                in  varchar2  default null
  ,p_pep_attribute20                in  varchar2  default null
  ,p_pep_attribute21                in  varchar2  default null
  ,p_pep_attribute22                in  varchar2  default null
  ,p_pep_attribute23                in  varchar2  default null
  ,p_pep_attribute24                in  varchar2  default null
  ,p_pep_attribute25                in  varchar2  default null
  ,p_pep_attribute26                in  varchar2  default null
  ,p_pep_attribute27                in  varchar2  default null
  ,p_pep_attribute28                in  varchar2  default null
  ,p_pep_attribute29                in  varchar2  default null
  ,p_pep_attribute30                in  varchar2  default null
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
  l_elig_per_id ben_elig_per_f.elig_per_id%TYPE;
  l_effective_start_date ben_elig_per_f.effective_start_date%TYPE;
  l_effective_end_date ben_elig_per_f.effective_end_date%TYPE;
  l_proc varchar2(72) := g_package||'create_Eligible_Person';
  l_object_version_number ben_elig_per_f.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_Eligible_Person;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_Eligible_Person
    --
    ben_Eligible_Person_bk1.create_Eligible_Person_b
      (p_business_group_id              =>  p_business_group_id
      ,p_pl_id                          =>  p_pl_id
      ,p_pgm_id                         =>  p_pgm_id
      ,p_plip_id                        =>  p_plip_id
      ,p_ptip_id                        =>  p_ptip_id
      ,p_ler_id                         =>  p_ler_id
      ,p_person_id                      =>  p_person_id
      ,p_per_in_ler_id                      =>  p_per_in_ler_id
      ,p_dpnt_othr_pl_cvrd_rl_flag      =>  p_dpnt_othr_pl_cvrd_rl_flag
      ,p_prtn_ovridn_thru_dt            =>  p_prtn_ovridn_thru_dt
      ,p_pl_key_ee_flag                 =>  p_pl_key_ee_flag
      ,p_pl_hghly_compd_flag            =>  p_pl_hghly_compd_flag
      ,p_elig_flag                      =>  p_elig_flag
      ,p_comp_ref_amt                   =>  p_comp_ref_amt
      ,p_cmbn_age_n_los_val             =>  p_cmbn_age_n_los_val
      ,p_comp_ref_uom                   =>  p_comp_ref_uom
      ,p_age_val                        =>  p_age_val
      ,p_los_val                        =>  p_los_val
      ,p_prtn_end_dt                    =>  p_prtn_end_dt
      ,p_prtn_strt_dt                   =>  p_prtn_strt_dt
      ,p_wait_perd_cmpltn_dt            =>  p_wait_perd_cmpltn_dt
      ,p_wait_perd_strt_dt              =>  p_wait_perd_strt_dt
      ,p_wv_ctfn_typ_cd                 =>  p_wv_ctfn_typ_cd
      ,p_hrs_wkd_val                    =>  p_hrs_wkd_val
      ,p_hrs_wkd_bndry_perd_cd          =>  p_hrs_wkd_bndry_perd_cd
      ,p_prtn_ovridn_flag               =>  p_prtn_ovridn_flag
      ,p_no_mx_prtn_ovrid_thru_flag     =>  p_no_mx_prtn_ovrid_thru_flag
      ,p_prtn_ovridn_rsn_cd             =>  p_prtn_ovridn_rsn_cd
      ,p_age_uom                        =>  p_age_uom
      ,p_los_uom                        =>  p_los_uom
      ,p_ovrid_svc_dt                   =>  p_ovrid_svc_dt
      ,p_inelg_rsn_cd                   =>  p_inelg_rsn_cd
      ,p_frz_los_flag                   =>  p_frz_los_flag
      ,p_frz_age_flag                   =>  p_frz_age_flag
      ,p_frz_cmp_lvl_flag               =>  p_frz_cmp_lvl_flag
      ,p_frz_pct_fl_tm_flag             =>  p_frz_pct_fl_tm_flag
      ,p_frz_hrs_wkd_flag               =>  p_frz_hrs_wkd_flag
      ,p_frz_comb_age_and_los_flag      =>  p_frz_comb_age_and_los_flag
      ,p_dstr_rstcn_flag                =>  p_dstr_rstcn_flag
      ,p_pct_fl_tm_val                  =>  p_pct_fl_tm_val
      ,p_wv_prtn_rsn_cd                 =>  p_wv_prtn_rsn_cd
      ,p_pl_wvd_flag                    =>  p_pl_wvd_flag
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
      ,p_once_r_cntug_cd                =>  p_once_r_cntug_cd
      ,p_pl_ordr_num                    =>  p_pl_ordr_num
      ,p_plip_ordr_num                  =>  p_plip_ordr_num
      ,p_ptip_ordr_num                  =>  p_ptip_ordr_num
      ,p_pep_attribute_category         =>  p_pep_attribute_category
      ,p_pep_attribute1                 =>  p_pep_attribute1
      ,p_pep_attribute2                 =>  p_pep_attribute2
      ,p_pep_attribute3                 =>  p_pep_attribute3
      ,p_pep_attribute4                 =>  p_pep_attribute4
      ,p_pep_attribute5                 =>  p_pep_attribute5
      ,p_pep_attribute6                 =>  p_pep_attribute6
      ,p_pep_attribute7                 =>  p_pep_attribute7
      ,p_pep_attribute8                 =>  p_pep_attribute8
      ,p_pep_attribute9                 =>  p_pep_attribute9
      ,p_pep_attribute10                =>  p_pep_attribute10
      ,p_pep_attribute11                =>  p_pep_attribute11
      ,p_pep_attribute12                =>  p_pep_attribute12
      ,p_pep_attribute13                =>  p_pep_attribute13
      ,p_pep_attribute14                =>  p_pep_attribute14
      ,p_pep_attribute15                =>  p_pep_attribute15
      ,p_pep_attribute16                =>  p_pep_attribute16
      ,p_pep_attribute17                =>  p_pep_attribute17
      ,p_pep_attribute18                =>  p_pep_attribute18
      ,p_pep_attribute19                =>  p_pep_attribute19
      ,p_pep_attribute20                =>  p_pep_attribute20
      ,p_pep_attribute21                =>  p_pep_attribute21
      ,p_pep_attribute22                =>  p_pep_attribute22
      ,p_pep_attribute23                =>  p_pep_attribute23
      ,p_pep_attribute24                =>  p_pep_attribute24
      ,p_pep_attribute25                =>  p_pep_attribute25
      ,p_pep_attribute26                =>  p_pep_attribute26
      ,p_pep_attribute27                =>  p_pep_attribute27
      ,p_pep_attribute28                =>  p_pep_attribute28
      ,p_pep_attribute29                =>  p_pep_attribute29
      ,p_pep_attribute30                =>  p_pep_attribute30
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_effective_date                 => trunc(p_effective_date));
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_Eligible_Person'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of create_Eligible_Person
    --
  end;
  --
  ben_pep_ins.ins
    (p_elig_per_id                   => l_elig_per_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_business_group_id             => p_business_group_id
    ,p_pl_id                         => p_pl_id
    ,p_pgm_id                        => p_pgm_id
    ,p_plip_id                       => p_plip_id
    ,p_ptip_id                       => p_ptip_id
    ,p_ler_id                        => p_ler_id
    ,p_person_id                     => p_person_id
    ,p_per_in_ler_id                     => p_per_in_ler_id
    ,p_dpnt_othr_pl_cvrd_rl_flag     => p_dpnt_othr_pl_cvrd_rl_flag
    ,p_prtn_ovridn_thru_dt           => p_prtn_ovridn_thru_dt
    ,p_pl_key_ee_flag                => p_pl_key_ee_flag
    ,p_pl_hghly_compd_flag           => p_pl_hghly_compd_flag
    ,p_elig_flag                     => p_elig_flag
    ,p_comp_ref_amt                  => p_comp_ref_amt
    ,p_cmbn_age_n_los_val            => p_cmbn_age_n_los_val
    ,p_comp_ref_uom                  => p_comp_ref_uom
    ,p_age_val                       => p_age_val
    ,p_los_val                       => p_los_val
    ,p_prtn_end_dt                   => p_prtn_end_dt
    ,p_prtn_strt_dt                  => p_prtn_strt_dt
    ,p_wait_perd_cmpltn_dt           => p_wait_perd_cmpltn_dt
    ,p_wait_perd_strt_dt             => p_wait_perd_strt_dt
    ,p_wv_ctfn_typ_cd                => p_wv_ctfn_typ_cd
    ,p_hrs_wkd_val                   => p_hrs_wkd_val
    ,p_hrs_wkd_bndry_perd_cd         => p_hrs_wkd_bndry_perd_cd
    ,p_prtn_ovridn_flag              => p_prtn_ovridn_flag
    ,p_no_mx_prtn_ovrid_thru_flag    => p_no_mx_prtn_ovrid_thru_flag
    ,p_prtn_ovridn_rsn_cd            => p_prtn_ovridn_rsn_cd
    ,p_age_uom                       => p_age_uom
    ,p_los_uom                       => p_los_uom
    ,p_ovrid_svc_dt                  => p_ovrid_svc_dt
    ,p_inelg_rsn_cd                  => p_inelg_rsn_cd
    ,p_frz_los_flag                  => p_frz_los_flag
    ,p_frz_age_flag                  => p_frz_age_flag
    ,p_frz_cmp_lvl_flag              => p_frz_cmp_lvl_flag
    ,p_frz_pct_fl_tm_flag            => p_frz_pct_fl_tm_flag
    ,p_frz_hrs_wkd_flag              => p_frz_hrs_wkd_flag
    ,p_frz_comb_age_and_los_flag     => p_frz_comb_age_and_los_flag
    ,p_dstr_rstcn_flag               => p_dstr_rstcn_flag
    ,p_pct_fl_tm_val                 => p_pct_fl_tm_val
    ,p_wv_prtn_rsn_cd                => p_wv_prtn_rsn_cd
    ,p_pl_wvd_flag                   => p_pl_wvd_flag
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
    ,p_once_r_cntug_cd               => p_once_r_cntug_cd
    ,p_pl_ordr_num                    =>  p_pl_ordr_num
    ,p_plip_ordr_num                  =>  p_plip_ordr_num
    ,p_ptip_ordr_num                  =>  p_ptip_ordr_num
    ,p_pep_attribute_category        => p_pep_attribute_category
    ,p_pep_attribute1                => p_pep_attribute1
    ,p_pep_attribute2                => p_pep_attribute2
    ,p_pep_attribute3                => p_pep_attribute3
    ,p_pep_attribute4                => p_pep_attribute4
    ,p_pep_attribute5                => p_pep_attribute5
    ,p_pep_attribute6                => p_pep_attribute6
    ,p_pep_attribute7                => p_pep_attribute7
    ,p_pep_attribute8                => p_pep_attribute8
    ,p_pep_attribute9                => p_pep_attribute9
    ,p_pep_attribute10               => p_pep_attribute10
    ,p_pep_attribute11               => p_pep_attribute11
    ,p_pep_attribute12               => p_pep_attribute12
    ,p_pep_attribute13               => p_pep_attribute13
    ,p_pep_attribute14               => p_pep_attribute14
    ,p_pep_attribute15               => p_pep_attribute15
    ,p_pep_attribute16               => p_pep_attribute16
    ,p_pep_attribute17               => p_pep_attribute17
    ,p_pep_attribute18               => p_pep_attribute18
    ,p_pep_attribute19               => p_pep_attribute19
    ,p_pep_attribute20               => p_pep_attribute20
    ,p_pep_attribute21               => p_pep_attribute21
    ,p_pep_attribute22               => p_pep_attribute22
    ,p_pep_attribute23               => p_pep_attribute23
    ,p_pep_attribute24               => p_pep_attribute24
    ,p_pep_attribute25               => p_pep_attribute25
    ,p_pep_attribute26               => p_pep_attribute26
    ,p_pep_attribute27               => p_pep_attribute27
    ,p_pep_attribute28               => p_pep_attribute28
    ,p_pep_attribute29               => p_pep_attribute29
    ,p_pep_attribute30               => p_pep_attribute30
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
    -- Start of API User Hook for the after hook of create_Eligible_Person
    --
    ben_Eligible_Person_bk1.create_Eligible_Person_a
      (p_elig_per_id                    =>  l_elig_per_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_business_group_id              =>  p_business_group_id
      ,p_pl_id                          =>  p_pl_id
      ,p_pgm_id                         =>  p_pgm_id
      ,p_plip_id                        =>  p_plip_id
      ,p_ptip_id                        =>  p_ptip_id
      ,p_ler_id                         =>  p_ler_id
      ,p_person_id                      =>  p_person_id
      ,p_per_in_ler_id                      =>  p_per_in_ler_id
      ,p_dpnt_othr_pl_cvrd_rl_flag      =>  p_dpnt_othr_pl_cvrd_rl_flag
      ,p_prtn_ovridn_thru_dt            =>  p_prtn_ovridn_thru_dt
      ,p_pl_key_ee_flag                 =>  p_pl_key_ee_flag
      ,p_pl_hghly_compd_flag            =>  p_pl_hghly_compd_flag
      ,p_elig_flag                      =>  p_elig_flag
      ,p_comp_ref_amt                   =>  p_comp_ref_amt
      ,p_cmbn_age_n_los_val             =>  p_cmbn_age_n_los_val
      ,p_comp_ref_uom                   =>  p_comp_ref_uom
      ,p_age_val                        =>  p_age_val
      ,p_los_val                        =>  p_los_val
      ,p_prtn_end_dt                    =>  p_prtn_end_dt
      ,p_prtn_strt_dt                   =>  p_prtn_strt_dt
      ,p_wait_perd_cmpltn_dt            =>  p_wait_perd_cmpltn_dt
      ,p_wait_perd_strt_dt              =>  p_wait_perd_strt_dt
      ,p_wv_ctfn_typ_cd                 =>  p_wv_ctfn_typ_cd
      ,p_hrs_wkd_val                    =>  p_hrs_wkd_val
      ,p_hrs_wkd_bndry_perd_cd          =>  p_hrs_wkd_bndry_perd_cd
      ,p_prtn_ovridn_flag               =>  p_prtn_ovridn_flag
      ,p_no_mx_prtn_ovrid_thru_flag     =>  p_no_mx_prtn_ovrid_thru_flag
      ,p_prtn_ovridn_rsn_cd             =>  p_prtn_ovridn_rsn_cd
      ,p_age_uom                        =>  p_age_uom
      ,p_los_uom                        =>  p_los_uom
      ,p_ovrid_svc_dt                   =>  p_ovrid_svc_dt
      ,p_inelg_rsn_cd                   =>  p_inelg_rsn_cd
      ,p_frz_los_flag                   =>  p_frz_los_flag
      ,p_frz_age_flag                   =>  p_frz_age_flag
      ,p_frz_cmp_lvl_flag               =>  p_frz_cmp_lvl_flag
      ,p_frz_pct_fl_tm_flag             =>  p_frz_pct_fl_tm_flag
      ,p_frz_hrs_wkd_flag               =>  p_frz_hrs_wkd_flag
      ,p_frz_comb_age_and_los_flag      =>  p_frz_comb_age_and_los_flag
      ,p_dstr_rstcn_flag                =>  p_dstr_rstcn_flag
      ,p_pct_fl_tm_val                  =>  p_pct_fl_tm_val
      ,p_wv_prtn_rsn_cd                 =>  p_wv_prtn_rsn_cd
      ,p_pl_wvd_flag                    =>  p_pl_wvd_flag
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
      ,p_once_r_cntug_cd                =>  p_once_r_cntug_cd
      ,p_pl_ordr_num                    =>  p_pl_ordr_num
      ,p_plip_ordr_num                  =>  p_plip_ordr_num
      ,p_ptip_ordr_num                  =>  p_ptip_ordr_num
      ,p_pep_attribute_category         =>  p_pep_attribute_category
      ,p_pep_attribute1                 =>  p_pep_attribute1
      ,p_pep_attribute2                 =>  p_pep_attribute2
      ,p_pep_attribute3                 =>  p_pep_attribute3
      ,p_pep_attribute4                 =>  p_pep_attribute4
      ,p_pep_attribute5                 =>  p_pep_attribute5
      ,p_pep_attribute6                 =>  p_pep_attribute6
      ,p_pep_attribute7                 =>  p_pep_attribute7
      ,p_pep_attribute8                 =>  p_pep_attribute8
      ,p_pep_attribute9                 =>  p_pep_attribute9
      ,p_pep_attribute10                =>  p_pep_attribute10
      ,p_pep_attribute11                =>  p_pep_attribute11
      ,p_pep_attribute12                =>  p_pep_attribute12
      ,p_pep_attribute13                =>  p_pep_attribute13
      ,p_pep_attribute14                =>  p_pep_attribute14
      ,p_pep_attribute15                =>  p_pep_attribute15
      ,p_pep_attribute16                =>  p_pep_attribute16
      ,p_pep_attribute17                =>  p_pep_attribute17
      ,p_pep_attribute18                =>  p_pep_attribute18
      ,p_pep_attribute19                =>  p_pep_attribute19
      ,p_pep_attribute20                =>  p_pep_attribute20
      ,p_pep_attribute21                =>  p_pep_attribute21
      ,p_pep_attribute22                =>  p_pep_attribute22
      ,p_pep_attribute23                =>  p_pep_attribute23
      ,p_pep_attribute24                =>  p_pep_attribute24
      ,p_pep_attribute25                =>  p_pep_attribute25
      ,p_pep_attribute26                =>  p_pep_attribute26
      ,p_pep_attribute27                =>  p_pep_attribute27
      ,p_pep_attribute28                =>  p_pep_attribute28
      ,p_pep_attribute29                =>  p_pep_attribute29
      ,p_pep_attribute30                =>  p_pep_attribute30
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date));
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_Eligible_Person'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of create_Eligible_Person
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
  p_elig_per_id := l_elig_per_id;
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
    ROLLBACK TO create_Eligible_Person;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_elig_per_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_Eligible_Person;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;

    raise;
    --
end create_Eligible_Person;
--
-- ----------------------------------------------------------------------------
-- |---------------------< create_perf_Eligible_Person >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_perf_Eligible_Person
  (p_validate                       in boolean    default false
  ,p_elig_per_id                    out nocopy number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default null
  ,p_pl_id                          in  number    default null
  ,p_pgm_id                         in  number    default null
  ,p_plip_id                        in  number    default null
  ,p_ptip_id                        in  number    default null
  ,p_ler_id                         in  number    default null
  ,p_person_id                      in  number    default null
  ,p_per_in_ler_id                      in  number    default null
  ,p_dpnt_othr_pl_cvrd_rl_flag      in  varchar2  default 'N'
  ,p_prtn_ovridn_thru_dt            in  date      default null
  ,p_pl_key_ee_flag                 in  varchar2  default 'N'
  ,p_pl_hghly_compd_flag            in  varchar2  default 'N'
  ,p_elig_flag                      in  varchar2  default 'N'
  ,p_comp_ref_amt                   in  number    default null
  ,p_cmbn_age_n_los_val             in  number    default null
  ,p_comp_ref_uom                   in  varchar2  default null
  ,p_age_val                        in  number    default null
  ,p_los_val                        in  number    default null
  ,p_prtn_end_dt                    in  date      default null
  ,p_prtn_strt_dt                   in  date      default null
  ,p_wait_perd_cmpltn_dt            in  date      default null
  ,p_wait_perd_strt_dt              in  date      default null
  ,p_wv_ctfn_typ_cd                 in  varchar2  default null
  ,p_hrs_wkd_val                    in  number    default null
  ,p_hrs_wkd_bndry_perd_cd          in  varchar2  default null
  ,p_prtn_ovridn_flag               in  varchar2  default null
  ,p_no_mx_prtn_ovrid_thru_flag     in  varchar2  default 'N'
  ,p_prtn_ovridn_rsn_cd             in  varchar2  default null
  ,p_age_uom                        in  varchar2  default null
  ,p_los_uom                        in  varchar2  default null
  ,p_ovrid_svc_dt                   in  date      default null
  ,p_inelg_rsn_cd                   in  varchar2  default null
  ,p_frz_los_flag                   in  varchar2  default 'N'
  ,p_frz_age_flag                   in  varchar2  default 'N'
  ,p_frz_cmp_lvl_flag               in  varchar2  default 'N'
  ,p_frz_pct_fl_tm_flag             in  varchar2  default 'N'
  ,p_frz_hrs_wkd_flag               in  varchar2  default 'N'
  ,p_frz_comb_age_and_los_flag      in  varchar2  default 'N'
  ,p_dstr_rstcn_flag                in  varchar2  default 'N'
  ,p_pct_fl_tm_val                  in  number    default null
  ,p_wv_prtn_rsn_cd                 in  varchar2  default null
  ,p_pl_wvd_flag                    in  varchar2  default 'N'
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
  ,p_once_r_cntug_cd                in  varchar2  default null
  ,p_pl_ordr_num                    in  number    default null
  ,p_plip_ordr_num                  in  number    default null
  ,p_ptip_ordr_num                  in  number    default null
  ,p_pep_attribute_category         in  varchar2  default null
  ,p_pep_attribute1                 in  varchar2  default null
  ,p_pep_attribute2                 in  varchar2  default null
  ,p_pep_attribute3                 in  varchar2  default null
  ,p_pep_attribute4                 in  varchar2  default null
  ,p_pep_attribute5                 in  varchar2  default null
  ,p_pep_attribute6                 in  varchar2  default null
  ,p_pep_attribute7                 in  varchar2  default null
  ,p_pep_attribute8                 in  varchar2  default null
  ,p_pep_attribute9                 in  varchar2  default null
  ,p_pep_attribute10                in  varchar2  default null
  ,p_pep_attribute11                in  varchar2  default null
  ,p_pep_attribute12                in  varchar2  default null
  ,p_pep_attribute13                in  varchar2  default null
  ,p_pep_attribute14                in  varchar2  default null
  ,p_pep_attribute15                in  varchar2  default null
  ,p_pep_attribute16                in  varchar2  default null
  ,p_pep_attribute17                in  varchar2  default null
  ,p_pep_attribute18                in  varchar2  default null
  ,p_pep_attribute19                in  varchar2  default null
  ,p_pep_attribute20                in  varchar2  default null
  ,p_pep_attribute21                in  varchar2  default null
  ,p_pep_attribute22                in  varchar2  default null
  ,p_pep_attribute23                in  varchar2  default null
  ,p_pep_attribute24                in  varchar2  default null
  ,p_pep_attribute25                in  varchar2  default null
  ,p_pep_attribute26                in  varchar2  default null
  ,p_pep_attribute27                in  varchar2  default null
  ,p_pep_attribute28                in  varchar2  default null
  ,p_pep_attribute29                in  varchar2  default null
  ,p_pep_attribute30                in  varchar2  default null
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
  l_proc varchar2(72) := g_package||'create_Eligible_Person';
  --
  l_rec        ben_pep_shd.g_rec_type;
  --
  -- Declare cursors and local variables
  --
  l_elig_per_id           ben_elig_per_f.elig_per_id%TYPE;
  l_effective_start_date  ben_elig_per_f.effective_start_date%TYPE;
  l_effective_end_date    ben_elig_per_f.effective_end_date%TYPE;
  l_object_version_number ben_elig_per_f.object_version_number%TYPE;
  --
  l_created_by               ben_elig_per_f.created_by%TYPE;
  l_creation_date            ben_elig_per_f.creation_date%TYPE;
  l_last_update_date         ben_elig_per_f.last_update_date%TYPE;
  l_last_updated_by          ben_elig_per_f.last_updated_by%TYPE;
  l_last_update_login        ben_elig_per_f.last_update_login%TYPE;
  --
  l_minmax_rec   ben_batch_dt_api.gtyp_dtsum_row;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_perf_Eligible_Person;
  --
  -- Derive maximum start and end dates
  --
  l_effective_start_date := p_effective_date;
  l_effective_end_date   := hr_api.g_eot;
  --
  -- Person
  --
  ben_batch_dt_api.get_personobject
    (p_person_id => p_person_id
    ,p_rec       => l_minmax_rec
    );
  --
  ben_batch_dt_api.Get_DtIns_Start_and_End_Dates
    (p_effective_date => p_effective_date
    ,p_parcolumn_name => 'person_id'
    ,p_min_esd        => l_minmax_rec.min_esd
    ,p_max_eed        => l_minmax_rec.max_eed
    --
    ,p_esd            => l_effective_start_date
    ,p_eed            => l_effective_end_date
    );
  --
  -- Ler
  --
  if p_ler_id is not null then
    --
    ben_batch_dt_api.get_lerobject
      (p_ler_id => p_ler_id
      ,p_rec    => l_minmax_rec
      );
    --
    ben_batch_dt_api.Get_DtIns_Start_and_End_Dates
      (p_effective_date => p_effective_date
      ,p_parcolumn_name => 'ler_id'
      ,p_min_esd        => l_minmax_rec.min_esd
      ,p_max_eed        => l_minmax_rec.max_eed
      --
      ,p_esd            => l_effective_start_date
      ,p_eed            => l_effective_end_date
      );
    --
  end if;
  --
  -- Pgm
  --
  if p_pgm_id is not null then
    --
    ben_batch_dt_api.get_pgmobject
      (p_pgm_id => p_pgm_id
      ,p_rec    => l_minmax_rec
      );
    --
    ben_batch_dt_api.Get_DtIns_Start_and_End_Dates
      (p_effective_date => p_effective_date
      ,p_parcolumn_name => 'pgm_id'
      ,p_min_esd        => l_minmax_rec.min_esd
      ,p_max_eed        => l_minmax_rec.max_eed
      --
      ,p_esd            => l_effective_start_date
      ,p_eed            => l_effective_end_date
      );
    --
  end if;
  --
  -- Ptip
  --
  if p_ptip_id is not null then
    --
    ben_batch_dt_api.get_ptipobject
      (p_ptip_id => p_ptip_id
      ,p_rec     => l_minmax_rec
      );
    --
    ben_batch_dt_api.Get_DtIns_Start_and_End_Dates
      (p_effective_date => p_effective_date
      ,p_parcolumn_name => 'ptip_id'
      ,p_min_esd        => l_minmax_rec.min_esd
      ,p_max_eed        => l_minmax_rec.max_eed
      --
      ,p_esd            => l_effective_start_date
      ,p_eed            => l_effective_end_date
      );
    --
  end if;
  --
  -- Plip
  --
  if p_plip_id is not null then
    --
    ben_batch_dt_api.get_plipobject
      (p_plip_id => p_plip_id
      ,p_rec     => l_minmax_rec
      );
    --
    ben_batch_dt_api.Get_DtIns_Start_and_End_Dates
      (p_effective_date => p_effective_date
      ,p_parcolumn_name => 'plip_id'
      ,p_min_esd        => l_minmax_rec.min_esd
      ,p_max_eed        => l_minmax_rec.max_eed
      --
      ,p_esd            => l_effective_start_date
      ,p_eed            => l_effective_end_date
      );
    --
  end if;
  --
  -- Plan
  --
  if p_pl_id is not null then
    --
    ben_batch_dt_api.get_plobject
      (p_pl_id => p_pl_id
      ,p_rec   => l_minmax_rec
      );
    --
    ben_batch_dt_api.Get_DtIns_Start_and_End_Dates
      (p_effective_date => p_effective_date
      ,p_parcolumn_name => 'pl_id'
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
  ben_pep_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ben_elig_per_f
  --
  hr_utility.set_location('Insert: '||l_proc, 5);
  insert into ben_elig_per_f
  (
    elig_per_id,
    effective_start_date,
    effective_end_date,
    business_group_id,
    pl_id,
    pgm_id,
    plip_id,
    ptip_id,
    ler_id,
    person_id,
    per_in_ler_id,
    dpnt_othr_pl_cvrd_rl_flag,
    prtn_ovridn_thru_dt,
    pl_key_ee_flag,
    pl_hghly_compd_flag,
    elig_flag,
    comp_ref_amt,
    cmbn_age_n_los_val,
    comp_ref_uom,
    age_val,
    los_val,
    prtn_end_dt,
    prtn_strt_dt,
    wait_perd_cmpltn_dt,
    wait_perd_strt_dt  ,
    wv_ctfn_typ_cd,
    hrs_wkd_val,
    hrs_wkd_bndry_perd_cd,
    prtn_ovridn_flag,
    no_mx_prtn_ovrid_thru_flag,
    prtn_ovridn_rsn_cd,
    age_uom,
    los_uom,
    ovrid_svc_dt,
    inelg_rsn_cd,
    frz_los_flag,
    frz_age_flag,
    frz_cmp_lvl_flag,
    frz_pct_fl_tm_flag,
    frz_hrs_wkd_flag,
    frz_comb_age_and_los_flag,
    dstr_rstcn_flag,
    pct_fl_tm_val,
    wv_prtn_rsn_cd,
    pl_wvd_flag,
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
    once_r_cntug_cd,
    pep_attribute_category,
    pep_attribute1,
    pep_attribute2,
    pep_attribute3,
    pep_attribute4,
    pep_attribute5,
    pep_attribute6,
    pep_attribute7,
    pep_attribute8,
    pep_attribute9,
    pep_attribute10,
    pep_attribute11,
    pep_attribute12,
    pep_attribute13,
    pep_attribute14,
    pep_attribute15,
    pep_attribute16,
    pep_attribute17,
    pep_attribute18,
    pep_attribute19,
    pep_attribute20,
    pep_attribute21,
    pep_attribute22,
    pep_attribute23,
    pep_attribute24,
    pep_attribute25,
    pep_attribute26,
    pep_attribute27,
    pep_attribute28,
    pep_attribute29,
    pep_attribute30,
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
  (
    ben_elig_per_f_s.nextval,
    l_effective_start_date,
    l_effective_end_date,
    p_business_group_id,
    p_pl_id,
    p_pgm_id,
    p_plip_id,
    p_ptip_id,
    p_ler_id,
    p_person_id,
    p_per_in_ler_id,
    p_dpnt_othr_pl_cvrd_rl_flag,
    p_prtn_ovridn_thru_dt,
    p_pl_key_ee_flag,
    p_pl_hghly_compd_flag,
    p_elig_flag,
    p_comp_ref_amt,
    p_cmbn_age_n_los_val,
    p_comp_ref_uom,
    p_age_val,
    p_los_val,
    p_prtn_end_dt,
    p_prtn_strt_dt,
    p_wait_perd_cmpltn_dt,
    p_wait_perd_strt_dt ,
    p_wv_ctfn_typ_cd,
    p_hrs_wkd_val,
    p_hrs_wkd_bndry_perd_cd,
    p_prtn_ovridn_flag,
    p_no_mx_prtn_ovrid_thru_flag,
    p_prtn_ovridn_rsn_cd,
    p_age_uom,
    p_los_uom,
    p_ovrid_svc_dt,
    p_inelg_rsn_cd,
    p_frz_los_flag,
    p_frz_age_flag,
    p_frz_cmp_lvl_flag,
    p_frz_pct_fl_tm_flag,
    p_frz_hrs_wkd_flag,
    p_frz_comb_age_and_los_flag,
    p_dstr_rstcn_flag,
    p_pct_fl_tm_val,
    p_wv_prtn_rsn_cd,
    p_pl_wvd_flag,
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
    p_once_r_cntug_cd,
    p_pep_attribute_category,
    p_pep_attribute1,
    p_pep_attribute2,
    p_pep_attribute3,
    p_pep_attribute4,
    p_pep_attribute5,
    p_pep_attribute6,
    p_pep_attribute7,
    p_pep_attribute8,
    p_pep_attribute9,
    p_pep_attribute10,
    p_pep_attribute11,
    p_pep_attribute12,
    p_pep_attribute13,
    p_pep_attribute14,
    p_pep_attribute15,
    p_pep_attribute16,
    p_pep_attribute17,
    p_pep_attribute18,
    p_pep_attribute19,
    p_pep_attribute20,
    p_pep_attribute21,
    p_pep_attribute22,
    p_pep_attribute23,
    p_pep_attribute24,
    p_pep_attribute25,
    p_pep_attribute26,
    p_pep_attribute27,
    p_pep_attribute28,
    p_pep_attribute29,
    p_pep_attribute30,
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
      ) RETURNING elig_per_id into l_elig_per_id;
  hr_utility.set_location('Dn Insert: '||l_proc, 5);
  --
  ben_pep_shd.g_api_dml := false;   -- Unset the api dml status
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_elig_per_id           := l_elig_per_id;
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
    ROLLBACK TO create_perf_Eligible_Person;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_elig_per_id := null;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
     --
    ROLLBACK TO create_perf_Eligible_Person;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := l_object_version_number;

    raise;
    --
end create_perf_Eligible_Person;
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_Eligible_Person >------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_Eligible_Person
  (p_validate                       in  boolean   default false
  ,p_elig_per_id                    in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_pl_id                          in  number    default hr_api.g_number
  ,p_pgm_id                         in  number    default hr_api.g_number
  ,p_plip_id                        in  number    default hr_api.g_number
  ,p_ptip_id                        in  number    default hr_api.g_number
  ,p_ler_id                         in  number    default hr_api.g_number
  ,p_person_id                      in  number    default hr_api.g_number
  ,p_per_in_ler_id                      in  number    default hr_api.g_number
  ,p_dpnt_othr_pl_cvrd_rl_flag      in  varchar2  default hr_api.g_varchar2
  ,p_prtn_ovridn_thru_dt            in  date      default hr_api.g_date
  ,p_pl_key_ee_flag                 in  varchar2  default hr_api.g_varchar2
  ,p_pl_hghly_compd_flag            in  varchar2  default hr_api.g_varchar2
  ,p_elig_flag                      in  varchar2  default hr_api.g_varchar2
  ,p_comp_ref_amt                   in  number    default hr_api.g_number
  ,p_cmbn_age_n_los_val             in  number    default hr_api.g_number
  ,p_comp_ref_uom                   in  varchar2  default hr_api.g_varchar2
  ,p_age_val                        in  number    default hr_api.g_number
  ,p_los_val                        in  number    default hr_api.g_number
  ,p_prtn_end_dt                    in  date      default hr_api.g_date
  ,p_prtn_strt_dt                   in  date      default hr_api.g_date
  ,p_wait_perd_cmpltn_dt            in  date      default hr_api.g_date
  ,p_wait_perd_strt_dt              in  date      default hr_api.g_date
  ,p_wv_ctfn_typ_cd                 in  varchar2  default hr_api.g_varchar2
  ,p_hrs_wkd_val                    in  number    default hr_api.g_number
  ,p_hrs_wkd_bndry_perd_cd          in  varchar2  default hr_api.g_varchar2
  ,p_prtn_ovridn_flag               in  varchar2  default hr_api.g_varchar2
  ,p_no_mx_prtn_ovrid_thru_flag     in  varchar2  default hr_api.g_varchar2
  ,p_prtn_ovridn_rsn_cd             in  varchar2  default hr_api.g_varchar2
  ,p_age_uom                        in  varchar2  default hr_api.g_varchar2
  ,p_los_uom                        in  varchar2  default hr_api.g_varchar2
  ,p_ovrid_svc_dt                   in  date      default hr_api.g_date
  ,p_inelg_rsn_cd                   in  varchar2  default hr_api.g_varchar2
  ,p_frz_los_flag                   in  varchar2  default hr_api.g_varchar2
  ,p_frz_age_flag                   in  varchar2  default hr_api.g_varchar2
  ,p_frz_cmp_lvl_flag               in  varchar2  default hr_api.g_varchar2
  ,p_frz_pct_fl_tm_flag             in  varchar2  default hr_api.g_varchar2
  ,p_frz_hrs_wkd_flag               in  varchar2  default hr_api.g_varchar2
  ,p_frz_comb_age_and_los_flag      in  varchar2  default hr_api.g_varchar2
  ,p_dstr_rstcn_flag                in  varchar2  default hr_api.g_varchar2
  ,p_pct_fl_tm_val                  in  number    default hr_api.g_number
  ,p_wv_prtn_rsn_cd                 in  varchar2  default hr_api.g_varchar2
  ,p_pl_wvd_flag                    in  varchar2  default hr_api.g_varchar2
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
  ,p_once_r_cntug_cd                in  varchar2  default hr_api.g_varchar2
  ,p_pl_ordr_num                    in  number    default hr_api.g_number
  ,p_plip_ordr_num                  in  number    default hr_api.g_number
  ,p_ptip_ordr_num                  in  number    default hr_api.g_number
  ,p_pep_attribute_category         in  varchar2  default hr_api.g_varchar2
  ,p_pep_attribute1                 in  varchar2  default hr_api.g_varchar2
  ,p_pep_attribute2                 in  varchar2  default hr_api.g_varchar2
  ,p_pep_attribute3                 in  varchar2  default hr_api.g_varchar2
  ,p_pep_attribute4                 in  varchar2  default hr_api.g_varchar2
  ,p_pep_attribute5                 in  varchar2  default hr_api.g_varchar2
  ,p_pep_attribute6                 in  varchar2  default hr_api.g_varchar2
  ,p_pep_attribute7                 in  varchar2  default hr_api.g_varchar2
  ,p_pep_attribute8                 in  varchar2  default hr_api.g_varchar2
  ,p_pep_attribute9                 in  varchar2  default hr_api.g_varchar2
  ,p_pep_attribute10                in  varchar2  default hr_api.g_varchar2
  ,p_pep_attribute11                in  varchar2  default hr_api.g_varchar2
  ,p_pep_attribute12                in  varchar2  default hr_api.g_varchar2
  ,p_pep_attribute13                in  varchar2  default hr_api.g_varchar2
  ,p_pep_attribute14                in  varchar2  default hr_api.g_varchar2
  ,p_pep_attribute15                in  varchar2  default hr_api.g_varchar2
  ,p_pep_attribute16                in  varchar2  default hr_api.g_varchar2
  ,p_pep_attribute17                in  varchar2  default hr_api.g_varchar2
  ,p_pep_attribute18                in  varchar2  default hr_api.g_varchar2
  ,p_pep_attribute19                in  varchar2  default hr_api.g_varchar2
  ,p_pep_attribute20                in  varchar2  default hr_api.g_varchar2
  ,p_pep_attribute21                in  varchar2  default hr_api.g_varchar2
  ,p_pep_attribute22                in  varchar2  default hr_api.g_varchar2
  ,p_pep_attribute23                in  varchar2  default hr_api.g_varchar2
  ,p_pep_attribute24                in  varchar2  default hr_api.g_varchar2
  ,p_pep_attribute25                in  varchar2  default hr_api.g_varchar2
  ,p_pep_attribute26                in  varchar2  default hr_api.g_varchar2
  ,p_pep_attribute27                in  varchar2  default hr_api.g_varchar2
  ,p_pep_attribute28                in  varchar2  default hr_api.g_varchar2
  ,p_pep_attribute29                in  varchar2  default hr_api.g_varchar2
  ,p_pep_attribute30                in  varchar2  default hr_api.g_varchar2
  ,p_request_id                     in  number    default hr_api.g_number
  ,p_program_application_id         in  number    default hr_api.g_number
  ,p_program_id                     in  number    default hr_api.g_number
  ,p_program_update_date            in  date      default hr_api.g_date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Eligible_Person';
  l_object_version_number ben_elig_per_f.object_version_number%TYPE;
  l_effective_start_date ben_elig_per_f.effective_start_date%TYPE;
  l_effective_end_date ben_elig_per_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_Eligible_Person;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_Eligible_Person
    --
    ben_Eligible_Person_bk2.update_Eligible_Person_b
      (p_elig_per_id                    =>  p_elig_per_id
      ,p_business_group_id              =>  p_business_group_id
      ,p_pl_id                          =>  p_pl_id
      ,p_pgm_id                         =>  p_pgm_id
      ,p_plip_id                        =>  p_plip_id
      ,p_ptip_id                        =>  p_ptip_id
      ,p_ler_id                         =>  p_ler_id
      ,p_person_id                      =>  p_person_id
      ,p_per_in_ler_id                      =>  p_per_in_ler_id
      ,p_dpnt_othr_pl_cvrd_rl_flag      =>  p_dpnt_othr_pl_cvrd_rl_flag
      ,p_prtn_ovridn_thru_dt            =>  p_prtn_ovridn_thru_dt
      ,p_pl_key_ee_flag                 =>  p_pl_key_ee_flag
      ,p_pl_hghly_compd_flag            =>  p_pl_hghly_compd_flag
      ,p_elig_flag                      =>  p_elig_flag
      ,p_comp_ref_amt                   =>  p_comp_ref_amt
      ,p_cmbn_age_n_los_val             =>  p_cmbn_age_n_los_val
      ,p_comp_ref_uom                   =>  p_comp_ref_uom
      ,p_age_val                        =>  p_age_val
      ,p_los_val                        =>  p_los_val
      ,p_prtn_end_dt                    =>  p_prtn_end_dt
      ,p_prtn_strt_dt                   =>  p_prtn_strt_dt
      ,p_wait_perd_cmpltn_dt            =>  p_wait_perd_cmpltn_dt
      ,p_wait_perd_strt_dt              =>  p_wait_perd_strt_dt
      ,p_wv_ctfn_typ_cd                 =>  p_wv_ctfn_typ_cd
      ,p_hrs_wkd_val                    =>  p_hrs_wkd_val
      ,p_hrs_wkd_bndry_perd_cd          =>  p_hrs_wkd_bndry_perd_cd
      ,p_prtn_ovridn_flag               =>  p_prtn_ovridn_flag
      ,p_no_mx_prtn_ovrid_thru_flag     =>  p_no_mx_prtn_ovrid_thru_flag
      ,p_prtn_ovridn_rsn_cd             =>  p_prtn_ovridn_rsn_cd
      ,p_age_uom                        =>  p_age_uom
      ,p_los_uom                        =>  p_los_uom
      ,p_ovrid_svc_dt                   =>  p_ovrid_svc_dt
      ,p_inelg_rsn_cd                   =>  p_inelg_rsn_cd
      ,p_frz_los_flag                   =>  p_frz_los_flag
      ,p_frz_age_flag                   =>  p_frz_age_flag
      ,p_frz_cmp_lvl_flag               =>  p_frz_cmp_lvl_flag
      ,p_frz_pct_fl_tm_flag             =>  p_frz_pct_fl_tm_flag
      ,p_frz_hrs_wkd_flag               =>  p_frz_hrs_wkd_flag
      ,p_frz_comb_age_and_los_flag      =>  p_frz_comb_age_and_los_flag
      ,p_dstr_rstcn_flag                =>  p_dstr_rstcn_flag
      ,p_pct_fl_tm_val                  =>  p_pct_fl_tm_val
      ,p_wv_prtn_rsn_cd                 =>  p_wv_prtn_rsn_cd
      ,p_pl_wvd_flag                    =>  p_pl_wvd_flag
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
      ,p_once_r_cntug_cd                =>  p_once_r_cntug_cd
      ,p_pl_ordr_num                    =>  p_pl_ordr_num
      ,p_plip_ordr_num                  =>  p_plip_ordr_num
      ,p_ptip_ordr_num                  =>  p_ptip_ordr_num
      ,p_pep_attribute_category         =>  p_pep_attribute_category
      ,p_pep_attribute1                 =>  p_pep_attribute1
      ,p_pep_attribute2                 =>  p_pep_attribute2
      ,p_pep_attribute3                 =>  p_pep_attribute3
      ,p_pep_attribute4                 =>  p_pep_attribute4
      ,p_pep_attribute5                 =>  p_pep_attribute5
      ,p_pep_attribute6                 =>  p_pep_attribute6
      ,p_pep_attribute7                 =>  p_pep_attribute7
      ,p_pep_attribute8                 =>  p_pep_attribute8
      ,p_pep_attribute9                 =>  p_pep_attribute9
      ,p_pep_attribute10                =>  p_pep_attribute10
      ,p_pep_attribute11                =>  p_pep_attribute11
      ,p_pep_attribute12                =>  p_pep_attribute12
      ,p_pep_attribute13                =>  p_pep_attribute13
      ,p_pep_attribute14                =>  p_pep_attribute14
      ,p_pep_attribute15                =>  p_pep_attribute15
      ,p_pep_attribute16                =>  p_pep_attribute16
      ,p_pep_attribute17                =>  p_pep_attribute17
      ,p_pep_attribute18                =>  p_pep_attribute18
      ,p_pep_attribute19                =>  p_pep_attribute19
      ,p_pep_attribute20                =>  p_pep_attribute20
      ,p_pep_attribute21                =>  p_pep_attribute21
      ,p_pep_attribute22                =>  p_pep_attribute22
      ,p_pep_attribute23                =>  p_pep_attribute23
      ,p_pep_attribute24                =>  p_pep_attribute24
      ,p_pep_attribute25                =>  p_pep_attribute25
      ,p_pep_attribute26                =>  p_pep_attribute26
      ,p_pep_attribute27                =>  p_pep_attribute27
      ,p_pep_attribute28                =>  p_pep_attribute28
      ,p_pep_attribute29                =>  p_pep_attribute29
      ,p_pep_attribute30                =>  p_pep_attribute30
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_datetrack_mode                 =>  p_datetrack_mode);
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Eligible_Person'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of update_Eligible_Person
    --
  end;
  --
  ben_pep_upd.upd
    (p_elig_per_id                   => p_elig_per_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_business_group_id             => p_business_group_id
    ,p_pl_id                         => p_pl_id
    ,p_pgm_id                        => p_pgm_id
    ,p_plip_id                       => p_plip_id
    ,p_ptip_id                       => p_ptip_id
    ,p_ler_id                        => p_ler_id
    ,p_person_id                     => p_person_id
    ,p_per_in_ler_id                     => p_per_in_ler_id
    ,p_dpnt_othr_pl_cvrd_rl_flag     => p_dpnt_othr_pl_cvrd_rl_flag
    ,p_prtn_ovridn_thru_dt           => p_prtn_ovridn_thru_dt
    ,p_pl_key_ee_flag                => p_pl_key_ee_flag
    ,p_pl_hghly_compd_flag           => p_pl_hghly_compd_flag
    ,p_elig_flag                     => p_elig_flag
    ,p_comp_ref_amt                  => p_comp_ref_amt
    ,p_cmbn_age_n_los_val            => p_cmbn_age_n_los_val
    ,p_comp_ref_uom                  => p_comp_ref_uom
    ,p_age_val                       => p_age_val
    ,p_los_val                       => p_los_val
    ,p_prtn_end_dt                   => p_prtn_end_dt
    ,p_prtn_strt_dt                  => p_prtn_strt_dt
    ,p_wait_perd_cmpltn_dt           => p_wait_perd_cmpltn_dt
    ,p_wait_perd_strt_dt             => p_wait_perd_strt_dt
    ,p_wv_ctfn_typ_cd                => p_wv_ctfn_typ_cd
    ,p_hrs_wkd_val                   => p_hrs_wkd_val
    ,p_hrs_wkd_bndry_perd_cd         => p_hrs_wkd_bndry_perd_cd
    ,p_prtn_ovridn_flag              => p_prtn_ovridn_flag
    ,p_no_mx_prtn_ovrid_thru_flag    => p_no_mx_prtn_ovrid_thru_flag
    ,p_prtn_ovridn_rsn_cd            => p_prtn_ovridn_rsn_cd
    ,p_age_uom                       => p_age_uom
    ,p_los_uom                       => p_los_uom
    ,p_ovrid_svc_dt                  => p_ovrid_svc_dt
    ,p_inelg_rsn_cd                  => p_inelg_rsn_cd
    ,p_frz_los_flag                  => p_frz_los_flag
    ,p_frz_age_flag                  => p_frz_age_flag
    ,p_frz_cmp_lvl_flag              => p_frz_cmp_lvl_flag
    ,p_frz_pct_fl_tm_flag            => p_frz_pct_fl_tm_flag
    ,p_frz_hrs_wkd_flag              => p_frz_hrs_wkd_flag
    ,p_frz_comb_age_and_los_flag     => p_frz_comb_age_and_los_flag
    ,p_dstr_rstcn_flag               => p_dstr_rstcn_flag
    ,p_pct_fl_tm_val                 => p_pct_fl_tm_val
    ,p_wv_prtn_rsn_cd                => p_wv_prtn_rsn_cd
    ,p_pl_wvd_flag                   => p_pl_wvd_flag
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
    ,p_once_r_cntug_cd               => p_once_r_cntug_cd
    ,p_pl_ordr_num                    =>  p_pl_ordr_num
    ,p_plip_ordr_num                  =>  p_plip_ordr_num
    ,p_ptip_ordr_num                  =>  p_ptip_ordr_num
    ,p_pep_attribute_category        => p_pep_attribute_category
    ,p_pep_attribute1                => p_pep_attribute1
    ,p_pep_attribute2                => p_pep_attribute2
    ,p_pep_attribute3                => p_pep_attribute3
    ,p_pep_attribute4                => p_pep_attribute4
    ,p_pep_attribute5                => p_pep_attribute5
    ,p_pep_attribute6                => p_pep_attribute6
    ,p_pep_attribute7                => p_pep_attribute7
    ,p_pep_attribute8                => p_pep_attribute8
    ,p_pep_attribute9                => p_pep_attribute9
    ,p_pep_attribute10               => p_pep_attribute10
    ,p_pep_attribute11               => p_pep_attribute11
    ,p_pep_attribute12               => p_pep_attribute12
    ,p_pep_attribute13               => p_pep_attribute13
    ,p_pep_attribute14               => p_pep_attribute14
    ,p_pep_attribute15               => p_pep_attribute15
    ,p_pep_attribute16               => p_pep_attribute16
    ,p_pep_attribute17               => p_pep_attribute17
    ,p_pep_attribute18               => p_pep_attribute18
    ,p_pep_attribute19               => p_pep_attribute19
    ,p_pep_attribute20               => p_pep_attribute20
    ,p_pep_attribute21               => p_pep_attribute21
    ,p_pep_attribute22               => p_pep_attribute22
    ,p_pep_attribute23               => p_pep_attribute23
    ,p_pep_attribute24               => p_pep_attribute24
    ,p_pep_attribute25               => p_pep_attribute25
    ,p_pep_attribute26               => p_pep_attribute26
    ,p_pep_attribute27               => p_pep_attribute27
    ,p_pep_attribute28               => p_pep_attribute28
    ,p_pep_attribute29               => p_pep_attribute29
    ,p_pep_attribute30               => p_pep_attribute30
    ,p_request_id                    => p_request_id
    ,p_program_application_id        => p_program_application_id
    ,p_program_id                    => p_program_id
    ,p_program_update_date           => p_program_update_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => trunc(p_effective_date)
    ,p_datetrack_mode                => p_datetrack_mode);
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_Eligible_Person
    --
    ben_Eligible_Person_bk2.update_Eligible_Person_a
      (p_elig_per_id                    =>  p_elig_per_id
      ,p_effective_start_date           =>  l_effective_start_date
      ,p_effective_end_date             =>  l_effective_end_date
      ,p_business_group_id              =>  p_business_group_id
      ,p_pl_id                          =>  p_pl_id
      ,p_pgm_id                         =>  p_pgm_id
      ,p_plip_id                        =>  p_plip_id
      ,p_ptip_id                        =>  p_ptip_id
      ,p_ler_id                         =>  p_ler_id
      ,p_person_id                      =>  p_person_id
      ,p_per_in_ler_id                      =>  p_per_in_ler_id
      ,p_dpnt_othr_pl_cvrd_rl_flag      =>  p_dpnt_othr_pl_cvrd_rl_flag
      ,p_prtn_ovridn_thru_dt            =>  p_prtn_ovridn_thru_dt
      ,p_pl_key_ee_flag                 =>  p_pl_key_ee_flag
      ,p_pl_hghly_compd_flag            =>  p_pl_hghly_compd_flag
      ,p_elig_flag                      =>  p_elig_flag
      ,p_comp_ref_amt                   =>  p_comp_ref_amt
      ,p_cmbn_age_n_los_val             =>  p_cmbn_age_n_los_val
      ,p_comp_ref_uom                   =>  p_comp_ref_uom
      ,p_age_val                        =>  p_age_val
      ,p_los_val                        =>  p_los_val
      ,p_prtn_end_dt                    =>  p_prtn_end_dt
      ,p_prtn_strt_dt                   =>  p_prtn_strt_dt
      ,p_wait_perd_cmpltn_dt            =>  p_wait_perd_cmpltn_dt
      ,p_wait_perd_strt_dt              =>  p_wait_perd_strt_dt
      ,p_wv_ctfn_typ_cd                 =>  p_wv_ctfn_typ_cd
      ,p_hrs_wkd_val                    =>  p_hrs_wkd_val
      ,p_hrs_wkd_bndry_perd_cd          =>  p_hrs_wkd_bndry_perd_cd
      ,p_prtn_ovridn_flag               =>  p_prtn_ovridn_flag
      ,p_no_mx_prtn_ovrid_thru_flag     =>  p_no_mx_prtn_ovrid_thru_flag
      ,p_prtn_ovridn_rsn_cd             =>  p_prtn_ovridn_rsn_cd
      ,p_age_uom                        =>  p_age_uom
      ,p_los_uom                        =>  p_los_uom
      ,p_ovrid_svc_dt                   =>  p_ovrid_svc_dt
      ,p_inelg_rsn_cd                   =>  p_inelg_rsn_cd
      ,p_frz_los_flag                   =>  p_frz_los_flag
      ,p_frz_age_flag                   =>  p_frz_age_flag
      ,p_frz_cmp_lvl_flag               =>  p_frz_cmp_lvl_flag
      ,p_frz_pct_fl_tm_flag             =>  p_frz_pct_fl_tm_flag
      ,p_frz_hrs_wkd_flag               =>  p_frz_hrs_wkd_flag
      ,p_frz_comb_age_and_los_flag      =>  p_frz_comb_age_and_los_flag
      ,p_dstr_rstcn_flag                =>  p_dstr_rstcn_flag
      ,p_pct_fl_tm_val                  =>  p_pct_fl_tm_val
      ,p_wv_prtn_rsn_cd                 =>  p_wv_prtn_rsn_cd
      ,p_pl_wvd_flag                    =>  p_pl_wvd_flag
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
      ,p_once_r_cntug_cd                =>  p_once_r_cntug_cd
      ,p_pl_ordr_num                    =>  p_pl_ordr_num
      ,p_plip_ordr_num                  =>  p_plip_ordr_num
      ,p_ptip_ordr_num                  =>  p_ptip_ordr_num
      ,p_pep_attribute_category         =>  p_pep_attribute_category
      ,p_pep_attribute1                 =>  p_pep_attribute1
      ,p_pep_attribute2                 =>  p_pep_attribute2
      ,p_pep_attribute3                 =>  p_pep_attribute3
      ,p_pep_attribute4                 =>  p_pep_attribute4
      ,p_pep_attribute5                 =>  p_pep_attribute5
      ,p_pep_attribute6                 =>  p_pep_attribute6
      ,p_pep_attribute7                 =>  p_pep_attribute7
      ,p_pep_attribute8                 =>  p_pep_attribute8
      ,p_pep_attribute9                 =>  p_pep_attribute9
      ,p_pep_attribute10                =>  p_pep_attribute10
      ,p_pep_attribute11                =>  p_pep_attribute11
      ,p_pep_attribute12                =>  p_pep_attribute12
      ,p_pep_attribute13                =>  p_pep_attribute13
      ,p_pep_attribute14                =>  p_pep_attribute14
      ,p_pep_attribute15                =>  p_pep_attribute15
      ,p_pep_attribute16                =>  p_pep_attribute16
      ,p_pep_attribute17                =>  p_pep_attribute17
      ,p_pep_attribute18                =>  p_pep_attribute18
      ,p_pep_attribute19                =>  p_pep_attribute19
      ,p_pep_attribute20                =>  p_pep_attribute20
      ,p_pep_attribute21                =>  p_pep_attribute21
      ,p_pep_attribute22                =>  p_pep_attribute22
      ,p_pep_attribute23                =>  p_pep_attribute23
      ,p_pep_attribute24                =>  p_pep_attribute24
      ,p_pep_attribute25                =>  p_pep_attribute25
      ,p_pep_attribute26                =>  p_pep_attribute26
      ,p_pep_attribute27                =>  p_pep_attribute27
      ,p_pep_attribute28                =>  p_pep_attribute28
      ,p_pep_attribute29                =>  p_pep_attribute29
      ,p_pep_attribute30                =>  p_pep_attribute30
      ,p_request_id                     =>  p_request_id
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_datetrack_mode                 =>  p_datetrack_mode);
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_Eligible_Person'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of update_Eligible_Person
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
    ROLLBACK TO update_Eligible_Person;
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
    ROLLBACK TO update_Eligible_Person;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := l_object_version_number;
    raise;
    --
end update_Eligible_Person;
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_Eligible_Person >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_Eligible_Person
  (p_validate                       in  boolean  default false
  ,p_elig_per_id                    in  number
  ,p_effective_start_date           out nocopy date
  ,p_effective_end_date             out nocopy date
  ,p_object_version_number          in out nocopy number
  ,p_effective_date                 in  date
  ,p_datetrack_mode                 in  varchar2) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_Eligible_Person';
  l_object_version_number ben_elig_per_f.object_version_number%TYPE;
  l_effective_start_date ben_elig_per_f.effective_start_date%TYPE;
  l_effective_end_date ben_elig_per_f.effective_end_date%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_Eligible_Person;
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
    -- Start of API User Hook for the before hook of delete_Eligible_Person
    --
    ben_Eligible_Person_bk3.delete_Eligible_Person_b
      (p_elig_per_id                    =>  p_elig_per_id
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_datetrack_mode                 =>  p_datetrack_mode);
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_Eligible_Person'
        ,p_hook_type   => 'BP');
    --
    -- End of API User Hook for the before hook of delete_Eligible_Person
    --
  end;
  --
  ben_pep_del.del
    (p_elig_per_id                   => p_elig_per_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    ,p_datetrack_mode                => p_datetrack_mode);
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_Eligible_Person
    --
    ben_Eligible_Person_bk3.delete_Eligible_Person_a
      (p_elig_per_id                    =>  p_elig_per_id
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
        (p_module_name => 'DELETE_Eligible_Person'
        ,p_hook_type   => 'AP');
    --
    -- End of API User Hook for the after hook of delete_Eligible_Person
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
    ROLLBACK TO delete_Eligible_Person;
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
    ROLLBACK TO delete_Eligible_Person;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := l_object_version_number;

    raise;
    --
end delete_Eligible_Person;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (p_elig_per_id                    in     number
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
  ben_pep_shd.lck
     (p_elig_per_id                => p_elig_per_id
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
end ben_Eligible_Person_api;

/
