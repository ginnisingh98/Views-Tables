--------------------------------------------------------
--  DDL for Package Body BEN_ELIGIBLE_PERSON_PERF_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ELIGIBLE_PERSON_PERF_API" as
/* $Header: bepepppi.pkb 120.6 2007/03/27 15:53:01 rtagarra noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ben_Eligible_Person_perf_api.';
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
  ,p_defer                          in boolean
  )
is
  --
  l_proc varchar2(72) := g_package||'create_Eligible_Person';
  --
  l_rec        ben_pep_shd.g_rec_type;
  l_pepinsplip g_pepapi_rectyp;
  l_pepinsplip_score_tab        ben_evaluate_elig_profiles.scoreTab;
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
  l_dummy_pep_id             number;
  l_dummy_esd                date;
  l_dummy_eed                date;
  l_dummy_ovn                number;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Check for PLIP level eligibility
  --
  if p_pgm_id is not null
    and p_plip_id is not null
    and p_pl_id is null
    and p_ptip_id is null
    and p_defer
  then
    --
    -- Defer PLIP insert to plan level write PEP Plip values to global
    g_pepinsplip := l_pepinsplip;
    --
    g_pepinsplip.p_validate := p_validate;
    g_pepinsplip.p_business_group_id := p_business_group_id;
    g_pepinsplip.p_pl_id := p_pl_id;
    g_pepinsplip.p_pgm_id := p_pgm_id;
    g_pepinsplip.p_plip_id := p_plip_id;
    g_pepinsplip.p_ptip_id := p_ptip_id;
    g_pepinsplip.p_ler_id := p_ler_id;
    g_pepinsplip.p_person_id := p_person_id;
    g_pepinsplip.p_per_in_ler_id := p_per_in_ler_id;
    g_pepinsplip.p_dpnt_othr_pl_cvrd_rl_flag := p_dpnt_othr_pl_cvrd_rl_flag;
    g_pepinsplip.p_prtn_ovridn_thru_dt := p_prtn_ovridn_thru_dt;
    g_pepinsplip.p_pl_key_ee_flag := p_pl_key_ee_flag;
    g_pepinsplip.p_pl_hghly_compd_flag := p_pl_hghly_compd_flag;
    g_pepinsplip.p_elig_flag := p_elig_flag;
    g_pepinsplip.p_comp_ref_amt := p_comp_ref_amt;
    g_pepinsplip.p_cmbn_age_n_los_val := p_cmbn_age_n_los_val;
    g_pepinsplip.p_comp_ref_uom := p_comp_ref_uom;
    g_pepinsplip.p_age_val := p_age_val;
    g_pepinsplip.p_los_val := p_los_val;
    g_pepinsplip.p_prtn_end_dt := p_prtn_end_dt;
    g_pepinsplip.p_prtn_strt_dt := p_prtn_strt_dt;
    g_pepinsplip.p_wait_perd_cmpltn_dt := p_wait_perd_cmpltn_dt;
    g_pepinsplip.p_wait_perd_strt_dt := p_wait_perd_strt_dt;
    g_pepinsplip.p_wv_ctfn_typ_cd := p_wv_ctfn_typ_cd;
    g_pepinsplip.p_hrs_wkd_val := p_hrs_wkd_val;
    g_pepinsplip.p_hrs_wkd_bndry_perd_cd := p_hrs_wkd_bndry_perd_cd;
    g_pepinsplip.p_prtn_ovridn_flag := p_prtn_ovridn_flag;
    g_pepinsplip.p_no_mx_prtn_ovrid_thru_flag := p_no_mx_prtn_ovrid_thru_flag;
    g_pepinsplip.p_prtn_ovridn_rsn_cd := p_prtn_ovridn_rsn_cd;
    g_pepinsplip.p_age_uom := p_age_uom;
    g_pepinsplip.p_los_uom := p_los_uom;
    g_pepinsplip.p_ovrid_svc_dt := p_ovrid_svc_dt;
    g_pepinsplip.p_inelg_rsn_cd := p_inelg_rsn_cd;
    g_pepinsplip.p_frz_los_flag := p_frz_los_flag;
    g_pepinsplip.p_frz_age_flag := p_frz_age_flag;
    g_pepinsplip.p_frz_cmp_lvl_flag := p_frz_cmp_lvl_flag;
    g_pepinsplip.p_frz_pct_fl_tm_flag := p_frz_pct_fl_tm_flag;
    g_pepinsplip.p_frz_hrs_wkd_flag := p_frz_hrs_wkd_flag;
    g_pepinsplip.p_frz_comb_age_and_los_flag := p_frz_comb_age_and_los_flag;
    g_pepinsplip.p_dstr_rstcn_flag := p_dstr_rstcn_flag;
    g_pepinsplip.p_pct_fl_tm_val := p_pct_fl_tm_val;
    g_pepinsplip.p_wv_prtn_rsn_cd := p_wv_prtn_rsn_cd;
    g_pepinsplip.p_pl_wvd_flag := p_pl_wvd_flag;
    g_pepinsplip.p_rt_comp_ref_amt := p_rt_comp_ref_amt;
    g_pepinsplip.p_rt_cmbn_age_n_los_val := p_rt_cmbn_age_n_los_val;
    g_pepinsplip.p_rt_comp_ref_uom := p_rt_comp_ref_uom;
    g_pepinsplip.p_rt_age_val := p_rt_age_val;
    g_pepinsplip.p_rt_los_val := p_rt_los_val;
    g_pepinsplip.p_rt_hrs_wkd_val := p_rt_hrs_wkd_val;
    g_pepinsplip.p_rt_hrs_wkd_bndry_perd_cd := p_rt_hrs_wkd_bndry_perd_cd;
    g_pepinsplip.p_rt_age_uom := p_rt_age_uom;
    g_pepinsplip.p_rt_los_uom := p_rt_los_uom;
    g_pepinsplip.p_rt_pct_fl_tm_val := p_rt_pct_fl_tm_val;
    g_pepinsplip.p_rt_frz_los_flag := p_rt_frz_los_flag;
    g_pepinsplip.p_rt_frz_age_flag := p_rt_frz_age_flag;
    g_pepinsplip.p_rt_frz_cmp_lvl_flag := p_rt_frz_cmp_lvl_flag;
    g_pepinsplip.p_rt_frz_pct_fl_tm_flag := p_rt_frz_pct_fl_tm_flag;
    g_pepinsplip.p_rt_frz_hrs_wkd_flag := p_rt_frz_hrs_wkd_flag;
    g_pepinsplip.p_rt_frz_comb_age_and_los_flag := p_rt_frz_comb_age_and_los_flag;
    g_pepinsplip.p_once_r_cntug_cd := p_once_r_cntug_cd;
    g_pepinsplip.p_pl_ordr_num := p_pl_ordr_num;
    g_pepinsplip.p_plip_ordr_num := p_plip_ordr_num;
    g_pepinsplip.p_ptip_ordr_num := p_ptip_ordr_num;
    g_pepinsplip.p_pep_attribute_category := p_pep_attribute_category;
    g_pepinsplip.p_pep_attribute1 := p_pep_attribute1;
    g_pepinsplip.p_pep_attribute2 := p_pep_attribute2;
    g_pepinsplip.p_pep_attribute3 := p_pep_attribute3;
    g_pepinsplip.p_pep_attribute4 := p_pep_attribute4;
    g_pepinsplip.p_pep_attribute5 := p_pep_attribute5;
    g_pepinsplip.p_pep_attribute6 := p_pep_attribute6;
    g_pepinsplip.p_pep_attribute7 := p_pep_attribute7;
    g_pepinsplip.p_pep_attribute8 := p_pep_attribute8;
    g_pepinsplip.p_pep_attribute9 := p_pep_attribute9;
    g_pepinsplip.p_pep_attribute10 := p_pep_attribute10;
    g_pepinsplip.p_pep_attribute11 := p_pep_attribute11;
    g_pepinsplip.p_pep_attribute12 := p_pep_attribute12;
    g_pepinsplip.p_pep_attribute13 := p_pep_attribute13;
    g_pepinsplip.p_pep_attribute14 := p_pep_attribute14;
    g_pepinsplip.p_pep_attribute15 := p_pep_attribute15;
    g_pepinsplip.p_pep_attribute16 := p_pep_attribute16;
    g_pepinsplip.p_pep_attribute17 := p_pep_attribute17;
    g_pepinsplip.p_pep_attribute18 := p_pep_attribute18;
    g_pepinsplip.p_pep_attribute19 := p_pep_attribute19;
    g_pepinsplip.p_pep_attribute20 := p_pep_attribute20;
    g_pepinsplip.p_pep_attribute21 := p_pep_attribute21;
    g_pepinsplip.p_pep_attribute22 := p_pep_attribute22;
    g_pepinsplip.p_pep_attribute23 := p_pep_attribute23;
    g_pepinsplip.p_pep_attribute24 := p_pep_attribute24;
    g_pepinsplip.p_pep_attribute25 := p_pep_attribute25;
    g_pepinsplip.p_pep_attribute26 := p_pep_attribute26;
    g_pepinsplip.p_pep_attribute27 := p_pep_attribute27;
    g_pepinsplip.p_pep_attribute28 := p_pep_attribute28;
    g_pepinsplip.p_pep_attribute29 := p_pep_attribute29;
    g_pepinsplip.p_pep_attribute30 := p_pep_attribute30;
    g_pepinsplip.p_request_id := p_request_id;
    g_pepinsplip.p_program_application_id := p_program_application_id;
    g_pepinsplip.p_program_id := p_program_id;
    g_pepinsplip.p_program_update_date := p_program_update_date;
    g_pepinsplip.p_effective_date := p_effective_date;
    g_pepinsplip.p_override_validation := p_override_validation;
  --
    hr_utility.set_location('Leaving - Defer'||l_proc,11);
    return;
  -- Check for deferred PLIP transactions
  --
  elsif p_pgm_id is not null
    and p_plip_id is null
    and p_pl_id is not null
    and p_ptip_id is null
    and g_pepinsplip.p_pgm_id is not null
    and g_pepinsplip.p_plip_id is not null
    and g_pepinsplip.p_pl_id is null
    and g_pepinsplip.p_ptip_id is null
    and p_defer
  then
    --
    ben_Eligible_Person_perf_api.create_perf_Eligible_Person
      (p_validate                     => g_pepinsplip.p_validate
      ,p_elig_per_id                  => l_dummy_pep_id
      ,p_effective_start_date         => l_dummy_esd
      ,p_effective_end_date           => l_dummy_eed
      ,p_business_group_id            => g_pepinsplip.p_business_group_id
      ,p_pl_id                        => g_pepinsplip.p_pl_id
      ,p_pgm_id                       => g_pepinsplip.p_pgm_id
      ,p_plip_id                      => g_pepinsplip.p_plip_id
      ,p_ptip_id                      => g_pepinsplip.p_ptip_id
      ,p_ler_id                       => g_pepinsplip.p_ler_id
      ,p_person_id                    => g_pepinsplip.p_person_id
      ,p_per_in_ler_id                => g_pepinsplip.p_per_in_ler_id
      ,p_dpnt_othr_pl_cvrd_rl_flag    => g_pepinsplip.p_dpnt_othr_pl_cvrd_rl_flag
      ,p_prtn_ovridn_thru_dt          => g_pepinsplip.p_prtn_ovridn_thru_dt
      ,p_pl_key_ee_flag               => g_pepinsplip.p_pl_key_ee_flag
      ,p_pl_hghly_compd_flag          => g_pepinsplip.p_pl_hghly_compd_flag
      ,p_elig_flag                    => g_pepinsplip.p_elig_flag
      ,p_comp_ref_amt                 => g_pepinsplip.p_comp_ref_amt
      ,p_cmbn_age_n_los_val           => g_pepinsplip.p_cmbn_age_n_los_val
      ,p_comp_ref_uom                 => g_pepinsplip.p_comp_ref_uom
      ,p_age_val                      => g_pepinsplip.p_age_val
      ,p_los_val                      => g_pepinsplip.p_los_val
      ,p_prtn_end_dt                  => g_pepinsplip.p_prtn_end_dt
      ,p_prtn_strt_dt                 => g_pepinsplip.p_prtn_strt_dt
      ,p_wait_perd_cmpltn_dt          => g_pepinsplip.p_wait_perd_cmpltn_dt
      ,p_wait_perd_strt_dt            => g_pepinsplip.p_wait_perd_strt_dt
      ,p_wv_ctfn_typ_cd               => g_pepinsplip.p_wv_ctfn_typ_cd
      ,p_hrs_wkd_val                  => g_pepinsplip.p_hrs_wkd_val
      ,p_hrs_wkd_bndry_perd_cd        => g_pepinsplip.p_hrs_wkd_bndry_perd_cd
      ,p_prtn_ovridn_flag             => g_pepinsplip.p_prtn_ovridn_flag
      ,p_no_mx_prtn_ovrid_thru_flag   => g_pepinsplip.p_no_mx_prtn_ovrid_thru_flag
      ,p_prtn_ovridn_rsn_cd           => g_pepinsplip.p_prtn_ovridn_rsn_cd
      ,p_age_uom                      => g_pepinsplip.p_age_uom
      ,p_los_uom                      => g_pepinsplip.p_los_uom
      ,p_ovrid_svc_dt                 => g_pepinsplip.p_ovrid_svc_dt
      ,p_inelg_rsn_cd                 => g_pepinsplip.p_inelg_rsn_cd
      ,p_frz_los_flag                 => g_pepinsplip.p_frz_los_flag
      ,p_frz_age_flag                 => g_pepinsplip.p_frz_age_flag
      ,p_frz_cmp_lvl_flag             => g_pepinsplip.p_frz_cmp_lvl_flag
      ,p_frz_pct_fl_tm_flag           => g_pepinsplip.p_frz_pct_fl_tm_flag
      ,p_frz_hrs_wkd_flag             => g_pepinsplip.p_frz_hrs_wkd_flag
      ,p_frz_comb_age_and_los_flag    => g_pepinsplip.p_frz_comb_age_and_los_flag
      ,p_dstr_rstcn_flag              => g_pepinsplip.p_dstr_rstcn_flag
      ,p_pct_fl_tm_val                => g_pepinsplip.p_pct_fl_tm_val
      ,p_wv_prtn_rsn_cd               => g_pepinsplip.p_wv_prtn_rsn_cd
      ,p_pl_wvd_flag                  => g_pepinsplip.p_pl_wvd_flag
      ,p_rt_comp_ref_amt              => g_pepinsplip.p_rt_comp_ref_amt
      ,p_rt_cmbn_age_n_los_val        => g_pepinsplip.p_rt_cmbn_age_n_los_val
      ,p_rt_comp_ref_uom              => g_pepinsplip.p_rt_comp_ref_uom
      ,p_rt_age_val                   => g_pepinsplip.p_rt_age_val
      ,p_rt_los_val                   => g_pepinsplip.p_rt_los_val
      ,p_rt_hrs_wkd_val               => g_pepinsplip.p_rt_hrs_wkd_val
      ,p_rt_hrs_wkd_bndry_perd_cd     => g_pepinsplip.p_rt_hrs_wkd_bndry_perd_cd
      ,p_rt_age_uom                   => g_pepinsplip.p_rt_age_uom
      ,p_rt_los_uom                   => g_pepinsplip.p_rt_los_uom
      ,p_rt_pct_fl_tm_val             => g_pepinsplip.p_rt_pct_fl_tm_val
      ,p_rt_frz_los_flag              => g_pepinsplip.p_rt_frz_los_flag
      ,p_rt_frz_age_flag              => g_pepinsplip.p_rt_frz_age_flag
      ,p_rt_frz_cmp_lvl_flag          => g_pepinsplip.p_rt_frz_cmp_lvl_flag
      ,p_rt_frz_pct_fl_tm_flag        => g_pepinsplip.p_rt_frz_pct_fl_tm_flag
      ,p_rt_frz_hrs_wkd_flag          => g_pepinsplip.p_rt_frz_hrs_wkd_flag
      ,p_rt_frz_comb_age_and_los_flag => g_pepinsplip.p_rt_frz_comb_age_and_los_flag
      ,p_once_r_cntug_cd              => g_pepinsplip.p_once_r_cntug_cd
      ,p_pl_ordr_num                  => g_pepinsplip.p_pl_ordr_num
      ,p_plip_ordr_num                => g_pepinsplip.p_plip_ordr_num
      ,p_ptip_ordr_num                => g_pepinsplip.p_ptip_ordr_num
      ,p_pep_attribute_category       => g_pepinsplip.p_pep_attribute_category
      ,p_pep_attribute1               => g_pepinsplip.p_pep_attribute1
      ,p_pep_attribute2               => g_pepinsplip.p_pep_attribute2
      ,p_pep_attribute3               => g_pepinsplip.p_pep_attribute3
      ,p_pep_attribute4               => g_pepinsplip.p_pep_attribute4
      ,p_pep_attribute5               => g_pepinsplip.p_pep_attribute5
      ,p_pep_attribute6               => g_pepinsplip.p_pep_attribute6
      ,p_pep_attribute7               => g_pepinsplip.p_pep_attribute7
      ,p_pep_attribute8               => g_pepinsplip.p_pep_attribute8
      ,p_pep_attribute9               => g_pepinsplip.p_pep_attribute9
      ,p_pep_attribute10              => g_pepinsplip.p_pep_attribute10
      ,p_pep_attribute11              => g_pepinsplip.p_pep_attribute11
      ,p_pep_attribute12              => g_pepinsplip.p_pep_attribute12
      ,p_pep_attribute13              => g_pepinsplip.p_pep_attribute13
      ,p_pep_attribute14              => g_pepinsplip.p_pep_attribute14
      ,p_pep_attribute15              => g_pepinsplip.p_pep_attribute15
      ,p_pep_attribute16              => g_pepinsplip.p_pep_attribute16
      ,p_pep_attribute17              => g_pepinsplip.p_pep_attribute17
      ,p_pep_attribute18              => g_pepinsplip.p_pep_attribute18
      ,p_pep_attribute19              => g_pepinsplip.p_pep_attribute19
      ,p_pep_attribute20              => g_pepinsplip.p_pep_attribute20
      ,p_pep_attribute21              => g_pepinsplip.p_pep_attribute21
      ,p_pep_attribute22              => g_pepinsplip.p_pep_attribute22
      ,p_pep_attribute23              => g_pepinsplip.p_pep_attribute23
      ,p_pep_attribute24              => g_pepinsplip.p_pep_attribute24
      ,p_pep_attribute25              => g_pepinsplip.p_pep_attribute25
      ,p_pep_attribute26              => g_pepinsplip.p_pep_attribute26
      ,p_pep_attribute27              => g_pepinsplip.p_pep_attribute27
      ,p_pep_attribute28              => g_pepinsplip.p_pep_attribute28
      ,p_pep_attribute29              => g_pepinsplip.p_pep_attribute29
      ,p_pep_attribute30              => g_pepinsplip.p_pep_attribute30
      ,p_request_id                   => g_pepinsplip.p_request_id
      ,p_program_application_id       => g_pepinsplip.p_program_application_id
      ,p_program_id                   => g_pepinsplip.p_program_id
      ,p_program_update_date          => g_pepinsplip.p_program_update_date
      ,p_object_version_number        => l_dummy_ovn
      ,p_effective_date               => g_pepinsplip.p_effective_date
      ,p_override_validation          => g_pepinsplip.p_override_validation
      ,p_defer                        => false
      );
    --
    -- Bug 4438430
    -- Since creation of BEN_ELIG_PER_F at PLIP level is DEFERRED until we create BEN_ELIG_PER_F
    -- record at PLN level, creation of BEN_ELIG_SCRE_WTG_F (PLIP) was also deferred. So now we create
    -- BEN_ELIG_SCRE_WTG_F record for ELPROs at PLIP level.
    -- In BEN_ELIG_SCRE_WTG_API.LOAD_SCORE_WEIGHT we store the P_SCORE_TAB in global table G_PEPINSPLIP
    --
    if g_pepinsplip_score_tab.count > 0
    then
      --
      ben_elig_scre_wtg_api.load_score_weight
        ( p_validate              => false
         ,p_score_tab             => g_pepinsplip_score_tab /* Bug 4449745 */
         ,p_effective_date        => g_pepinsplip.p_effective_date
         ,p_per_in_ler_id         => g_pepinsplip.p_per_in_ler_id
         ,p_elig_per_id           => l_dummy_pep_id
         ,p_elig_per_opt_id       => null
        );
      --
    end if;
    --
    g_pepinsplip := l_pepinsplip;
    g_pepinsplip_score_tab := l_pepinsplip_score_tab;  /* Bug 4449745 */
    --
  end if;
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
Procedure convert_defs
  (p_rec in out nocopy ben_pep_shd.g_rec_type
  )
is
--
  l_proc  varchar2(72) := g_package||'convert_defs';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    ben_pep_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.pl_id = hr_api.g_number) then
    p_rec.pl_id :=
    ben_pep_shd.g_old_rec.pl_id;
  End If;
  If (p_rec.pgm_id = hr_api.g_number) then
    p_rec.pgm_id :=
    ben_pep_shd.g_old_rec.pgm_id;
  End If;
  If (p_rec.plip_id = hr_api.g_number) then
    p_rec.plip_id :=
    ben_pep_shd.g_old_rec.plip_id;
  End If;
  If (p_rec.ptip_id = hr_api.g_number) then
    p_rec.ptip_id :=
    ben_pep_shd.g_old_rec.ptip_id;
  End If;
  If (p_rec.ler_id = hr_api.g_number) then
    p_rec.ler_id :=
    ben_pep_shd.g_old_rec.ler_id;
  End If;
  If (p_rec.person_id = hr_api.g_number) then
    p_rec.person_id :=
    ben_pep_shd.g_old_rec.person_id;
  End If;
  If (p_rec.per_in_ler_id = hr_api.g_number) then
    p_rec.per_in_ler_id :=
    ben_pep_shd.g_old_rec.per_in_ler_id;
  End If;
  If (p_rec.dpnt_othr_pl_cvrd_rl_flag = hr_api.g_varchar2) then
    p_rec.dpnt_othr_pl_cvrd_rl_flag :=
    ben_pep_shd.g_old_rec.dpnt_othr_pl_cvrd_rl_flag;
  End If;
  If (p_rec.prtn_ovridn_thru_dt = hr_api.g_date) then
    p_rec.prtn_ovridn_thru_dt :=
    ben_pep_shd.g_old_rec.prtn_ovridn_thru_dt;
  End If;
  If (p_rec.pl_key_ee_flag = hr_api.g_varchar2) then
    p_rec.pl_key_ee_flag :=
    ben_pep_shd.g_old_rec.pl_key_ee_flag;
  End If;
  If (p_rec.pl_hghly_compd_flag = hr_api.g_varchar2) then
    p_rec.pl_hghly_compd_flag :=
    ben_pep_shd.g_old_rec.pl_hghly_compd_flag;
  End If;
  If (p_rec.elig_flag = hr_api.g_varchar2) then
    p_rec.elig_flag :=
    ben_pep_shd.g_old_rec.elig_flag;
  End If;
  If (p_rec.comp_ref_amt = hr_api.g_number) then
    p_rec.comp_ref_amt :=
    ben_pep_shd.g_old_rec.comp_ref_amt;
  End If;
  If (p_rec.cmbn_age_n_los_val = hr_api.g_number) then
    p_rec.cmbn_age_n_los_val :=
    ben_pep_shd.g_old_rec.cmbn_age_n_los_val;
  End If;
  If (p_rec.comp_ref_uom = hr_api.g_varchar2) then
    p_rec.comp_ref_uom :=
    ben_pep_shd.g_old_rec.comp_ref_uom;
  End If;
  If (p_rec.age_val = hr_api.g_number) then
    p_rec.age_val :=
    ben_pep_shd.g_old_rec.age_val;
  End If;
  If (p_rec.los_val = hr_api.g_number) then
    p_rec.los_val :=
    ben_pep_shd.g_old_rec.los_val;
  End If;
  If (p_rec.prtn_end_dt = hr_api.g_date) then
    p_rec.prtn_end_dt :=
    ben_pep_shd.g_old_rec.prtn_end_dt;
  End If;
  If (p_rec.prtn_strt_dt = hr_api.g_date) then
    p_rec.prtn_strt_dt :=
    ben_pep_shd.g_old_rec.prtn_strt_dt;
  End If;
  If (p_rec.wait_perd_cmpltn_dt = hr_api.g_date) then
    p_rec.wait_perd_cmpltn_dt :=
    ben_pep_shd.g_old_rec.wait_perd_cmpltn_dt;
  End If;

  If (p_rec.wait_perd_strt_dt  = hr_api.g_date) then
    p_rec.wait_perd_strt_dt :=
    ben_pep_shd.g_old_rec.wait_perd_strt_dt;
  End If;
  If (p_rec.wv_ctfn_typ_cd = hr_api.g_varchar2) then
    p_rec.wv_ctfn_typ_cd :=
    ben_pep_shd.g_old_rec.wv_ctfn_typ_cd;
  End If;
  If (p_rec.hrs_wkd_val = hr_api.g_number) then
    p_rec.hrs_wkd_val :=
    ben_pep_shd.g_old_rec.hrs_wkd_val;
  End If;
  If (p_rec.hrs_wkd_bndry_perd_cd = hr_api.g_varchar2) then
    p_rec.hrs_wkd_bndry_perd_cd :=
    ben_pep_shd.g_old_rec.hrs_wkd_bndry_perd_cd;
  End If;
  If (p_rec.prtn_ovridn_flag = hr_api.g_varchar2) then
    p_rec.prtn_ovridn_flag :=
    ben_pep_shd.g_old_rec.prtn_ovridn_flag;
  End If;
  If (p_rec.no_mx_prtn_ovrid_thru_flag = hr_api.g_varchar2) then
    p_rec.no_mx_prtn_ovrid_thru_flag :=
    ben_pep_shd.g_old_rec.no_mx_prtn_ovrid_thru_flag;
  End If;
  If (p_rec.prtn_ovridn_rsn_cd = hr_api.g_varchar2) then
    p_rec.prtn_ovridn_rsn_cd :=
    ben_pep_shd.g_old_rec.prtn_ovridn_rsn_cd;
  End If;
  If (p_rec.age_uom = hr_api.g_varchar2) then
    p_rec.age_uom :=
    ben_pep_shd.g_old_rec.age_uom;
  End If;
  If (p_rec.los_uom = hr_api.g_varchar2) then
    p_rec.los_uom :=
    ben_pep_shd.g_old_rec.los_uom;
  End If;
  If (p_rec.ovrid_svc_dt = hr_api.g_date) then
    p_rec.ovrid_svc_dt :=
    ben_pep_shd.g_old_rec.ovrid_svc_dt;
  End If;
  If (p_rec.inelg_rsn_cd = hr_api.g_varchar2) then
    p_rec.inelg_rsn_cd :=
    ben_pep_shd.g_old_rec.inelg_rsn_cd;
  End If;
  If (p_rec.frz_los_flag = hr_api.g_varchar2) then
    p_rec.frz_los_flag :=
    ben_pep_shd.g_old_rec.frz_los_flag;
  End If;
  If (p_rec.frz_age_flag = hr_api.g_varchar2) then
    p_rec.frz_age_flag :=
    ben_pep_shd.g_old_rec.frz_age_flag;
  End If;
  If (p_rec.frz_cmp_lvl_flag = hr_api.g_varchar2) then
    p_rec.frz_cmp_lvl_flag :=
    ben_pep_shd.g_old_rec.frz_cmp_lvl_flag;
  End If;
  If (p_rec.frz_pct_fl_tm_flag = hr_api.g_varchar2) then
    p_rec.frz_pct_fl_tm_flag :=
    ben_pep_shd.g_old_rec.frz_pct_fl_tm_flag;
  End If;
  If (p_rec.frz_hrs_wkd_flag = hr_api.g_varchar2) then
    p_rec.frz_hrs_wkd_flag :=
    ben_pep_shd.g_old_rec.frz_hrs_wkd_flag;
  End If;
  If (p_rec.frz_comb_age_and_los_flag = hr_api.g_varchar2) then
    p_rec.frz_comb_age_and_los_flag :=
    ben_pep_shd.g_old_rec.frz_comb_age_and_los_flag;
  End If;
  If (p_rec.dstr_rstcn_flag = hr_api.g_varchar2) then
    p_rec.dstr_rstcn_flag :=
    ben_pep_shd.g_old_rec.dstr_rstcn_flag;
  End If;
  If (p_rec.pct_fl_tm_val = hr_api.g_number) then
    p_rec.pct_fl_tm_val :=
    ben_pep_shd.g_old_rec.pct_fl_tm_val;
  End If;
  If (p_rec.wv_prtn_rsn_cd = hr_api.g_varchar2) then
    p_rec.wv_prtn_rsn_cd :=
    ben_pep_shd.g_old_rec.wv_prtn_rsn_cd;
  End If;
  If (p_rec.pl_wvd_flag = hr_api.g_varchar2) then
    p_rec.pl_wvd_flag :=
    ben_pep_shd.g_old_rec.pl_wvd_flag;
  End If;
  If (p_rec.rt_comp_ref_amt = hr_api.g_number) then
    p_rec.rt_comp_ref_amt :=
    ben_pep_shd.g_old_rec.rt_comp_ref_amt;
  End If;
  If (p_rec.rt_cmbn_age_n_los_val = hr_api.g_number) then
    p_rec.rt_cmbn_age_n_los_val :=
    ben_pep_shd.g_old_rec.rt_cmbn_age_n_los_val;
  End If;
  If (p_rec.rt_comp_ref_uom = hr_api.g_varchar2) then
    p_rec.rt_comp_ref_uom :=
    ben_pep_shd.g_old_rec.rt_comp_ref_uom;
  End If;
  If (p_rec.rt_age_val = hr_api.g_number) then
    p_rec.rt_age_val :=
    ben_pep_shd.g_old_rec.rt_age_val;
  End If;
  If (p_rec.rt_los_val = hr_api.g_number) then
    p_rec.rt_los_val :=
    ben_pep_shd.g_old_rec.rt_los_val;
  End If;
  If (p_rec.rt_hrs_wkd_val = hr_api.g_number) then
    p_rec.rt_hrs_wkd_val :=
    ben_pep_shd.g_old_rec.rt_hrs_wkd_val;
  End If;
  If (p_rec.rt_hrs_wkd_bndry_perd_cd = hr_api.g_varchar2) then
    p_rec.rt_hrs_wkd_bndry_perd_cd :=
    ben_pep_shd.g_old_rec.rt_hrs_wkd_bndry_perd_cd;
  End If;
  If (p_rec.rt_age_uom = hr_api.g_varchar2) then
    p_rec.rt_age_uom :=
    ben_pep_shd.g_old_rec.rt_age_uom;
  End If;
  If (p_rec.rt_los_uom = hr_api.g_varchar2) then
    p_rec.rt_los_uom :=
    ben_pep_shd.g_old_rec.rt_los_uom;
  End If;
  If (p_rec.rt_pct_fl_tm_val = hr_api.g_number) then
    p_rec.rt_pct_fl_tm_val :=
    ben_pep_shd.g_old_rec.rt_pct_fl_tm_val;
  End If;
  If (p_rec.rt_frz_los_flag = hr_api.g_varchar2) then
    p_rec.rt_frz_los_flag :=
    ben_pep_shd.g_old_rec.rt_frz_los_flag;
  End If;
  If (p_rec.rt_frz_age_flag = hr_api.g_varchar2) then
    p_rec.rt_frz_age_flag :=
    ben_pep_shd.g_old_rec.rt_frz_age_flag;
  End If;
  If (p_rec.rt_frz_cmp_lvl_flag = hr_api.g_varchar2) then
    p_rec.rt_frz_cmp_lvl_flag :=
    ben_pep_shd.g_old_rec.rt_frz_cmp_lvl_flag;
  End If;
  If (p_rec.rt_frz_pct_fl_tm_flag = hr_api.g_varchar2) then
    p_rec.rt_frz_pct_fl_tm_flag :=
    ben_pep_shd.g_old_rec.rt_frz_pct_fl_tm_flag;
  End If;
  If (p_rec.rt_frz_hrs_wkd_flag = hr_api.g_varchar2) then
    p_rec.rt_frz_hrs_wkd_flag :=
    ben_pep_shd.g_old_rec.rt_frz_hrs_wkd_flag;
  End If;
  If (p_rec.rt_frz_comb_age_and_los_flag = hr_api.g_varchar2) then
    p_rec.rt_frz_comb_age_and_los_flag :=
    ben_pep_shd.g_old_rec.rt_frz_comb_age_and_los_flag;
  End If;
  If (p_rec.once_r_cntug_cd = hr_api.g_varchar2) then
    p_rec.once_r_cntug_cd :=
    ben_pep_shd.g_old_rec.once_r_cntug_cd;
  End If;
  If (p_rec.pl_ordr_num = hr_api.g_number) then
    p_rec.pl_ordr_num :=
    ben_pep_shd.g_old_rec.pl_ordr_num;
  End If;
  If (p_rec.plip_ordr_num = hr_api.g_number) then
    p_rec.plip_ordr_num :=
    ben_pep_shd.g_old_rec.plip_ordr_num;
  End If;
  If (p_rec.ptip_ordr_num = hr_api.g_number) then
    p_rec.ptip_ordr_num :=
    ben_pep_shd.g_old_rec.ptip_ordr_num;
  End If;
  If (p_rec.pep_attribute_category = hr_api.g_varchar2) then
    p_rec.pep_attribute_category :=
    ben_pep_shd.g_old_rec.pep_attribute_category;
  End If;
  If (p_rec.pep_attribute1 = hr_api.g_varchar2) then
    p_rec.pep_attribute1 :=
    ben_pep_shd.g_old_rec.pep_attribute1;
  End If;
  If (p_rec.pep_attribute2 = hr_api.g_varchar2) then
    p_rec.pep_attribute2 :=
    ben_pep_shd.g_old_rec.pep_attribute2;
  End If;
  If (p_rec.pep_attribute3 = hr_api.g_varchar2) then
    p_rec.pep_attribute3 :=
    ben_pep_shd.g_old_rec.pep_attribute3;
  End If;
  If (p_rec.pep_attribute4 = hr_api.g_varchar2) then
    p_rec.pep_attribute4 :=
    ben_pep_shd.g_old_rec.pep_attribute4;
  End If;
  If (p_rec.pep_attribute5 = hr_api.g_varchar2) then
    p_rec.pep_attribute5 :=
    ben_pep_shd.g_old_rec.pep_attribute5;
  End If;
  If (p_rec.pep_attribute6 = hr_api.g_varchar2) then
    p_rec.pep_attribute6 :=
    ben_pep_shd.g_old_rec.pep_attribute6;
  End If;
  If (p_rec.pep_attribute7 = hr_api.g_varchar2) then
    p_rec.pep_attribute7 :=
    ben_pep_shd.g_old_rec.pep_attribute7;
  End If;
  If (p_rec.pep_attribute8 = hr_api.g_varchar2) then
    p_rec.pep_attribute8 :=
    ben_pep_shd.g_old_rec.pep_attribute8;
  End If;
  If (p_rec.pep_attribute9 = hr_api.g_varchar2) then
    p_rec.pep_attribute9 :=
    ben_pep_shd.g_old_rec.pep_attribute9;
  End If;
  If (p_rec.pep_attribute10 = hr_api.g_varchar2) then
    p_rec.pep_attribute10 :=
    ben_pep_shd.g_old_rec.pep_attribute10;
  End If;
  If (p_rec.pep_attribute11 = hr_api.g_varchar2) then
    p_rec.pep_attribute11 :=
    ben_pep_shd.g_old_rec.pep_attribute11;
  End If;
  If (p_rec.pep_attribute12 = hr_api.g_varchar2) then
    p_rec.pep_attribute12 :=
    ben_pep_shd.g_old_rec.pep_attribute12;
  End If;
  If (p_rec.pep_attribute13 = hr_api.g_varchar2) then
    p_rec.pep_attribute13 :=
    ben_pep_shd.g_old_rec.pep_attribute13;
  End If;
  If (p_rec.pep_attribute14 = hr_api.g_varchar2) then
    p_rec.pep_attribute14 :=
    ben_pep_shd.g_old_rec.pep_attribute14;
  End If;
  If (p_rec.pep_attribute15 = hr_api.g_varchar2) then
    p_rec.pep_attribute15 :=
    ben_pep_shd.g_old_rec.pep_attribute15;
  End If;
  If (p_rec.pep_attribute16 = hr_api.g_varchar2) then
    p_rec.pep_attribute16 :=
    ben_pep_shd.g_old_rec.pep_attribute16;
  End If;
  If (p_rec.pep_attribute17 = hr_api.g_varchar2) then
    p_rec.pep_attribute17 :=
    ben_pep_shd.g_old_rec.pep_attribute17;
  End If;
  If (p_rec.pep_attribute18 = hr_api.g_varchar2) then
    p_rec.pep_attribute18 :=
    ben_pep_shd.g_old_rec.pep_attribute18;
  End If;
  If (p_rec.pep_attribute19 = hr_api.g_varchar2) then
    p_rec.pep_attribute19 :=
    ben_pep_shd.g_old_rec.pep_attribute19;
  End If;
  If (p_rec.pep_attribute20 = hr_api.g_varchar2) then
    p_rec.pep_attribute20 :=
    ben_pep_shd.g_old_rec.pep_attribute20;
  End If;
  If (p_rec.pep_attribute21 = hr_api.g_varchar2) then
    p_rec.pep_attribute21 :=
    ben_pep_shd.g_old_rec.pep_attribute21;
  End If;
  If (p_rec.pep_attribute22 = hr_api.g_varchar2) then
    p_rec.pep_attribute22 :=
    ben_pep_shd.g_old_rec.pep_attribute22;
  End If;
  If (p_rec.pep_attribute23 = hr_api.g_varchar2) then
    p_rec.pep_attribute23 :=
    ben_pep_shd.g_old_rec.pep_attribute23;
  End If;
  If (p_rec.pep_attribute24 = hr_api.g_varchar2) then
    p_rec.pep_attribute24 :=
    ben_pep_shd.g_old_rec.pep_attribute24;
  End If;
  If (p_rec.pep_attribute25 = hr_api.g_varchar2) then
    p_rec.pep_attribute25 :=
    ben_pep_shd.g_old_rec.pep_attribute25;
  End If;
  If (p_rec.pep_attribute26 = hr_api.g_varchar2) then
    p_rec.pep_attribute26 :=
    ben_pep_shd.g_old_rec.pep_attribute26;
  End If;
  If (p_rec.pep_attribute27 = hr_api.g_varchar2) then
    p_rec.pep_attribute27 :=
    ben_pep_shd.g_old_rec.pep_attribute27;
  End If;
  If (p_rec.pep_attribute28 = hr_api.g_varchar2) then
    p_rec.pep_attribute28 :=
    ben_pep_shd.g_old_rec.pep_attribute28;
  End If;
  If (p_rec.pep_attribute29 = hr_api.g_varchar2) then
    p_rec.pep_attribute29 :=
    ben_pep_shd.g_old_rec.pep_attribute29;
  End If;
  If (p_rec.pep_attribute30 = hr_api.g_varchar2) then
    p_rec.pep_attribute30 :=
    ben_pep_shd.g_old_rec.pep_attribute30;
  End If;
  If (p_rec.request_id = hr_api.g_number) then
    p_rec.request_id :=
    ben_pep_shd.g_old_rec.request_id;
  End If;
  If (p_rec.program_application_id = hr_api.g_number) then
    p_rec.program_application_id :=
    ben_pep_shd.g_old_rec.program_application_id;
  End If;
  If (p_rec.program_id = hr_api.g_number) then
    p_rec.program_id :=
    ben_pep_shd.g_old_rec.program_id;
  End If;
  If (p_rec.program_update_date = hr_api.g_date) then
    p_rec.program_update_date :=
    ben_pep_shd.g_old_rec.program_update_date;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< perf_lck >---------------------------------|
-- ----------------------------------------------------------------------------
--
procedure perf_lck
  (p_elig_per_id           in     number
  ,p_object_version_number in     number
  ,p_effective_date        in     date
  ,p_datetrack_mode        in     varchar2
  ,p_validation_start_date    out nocopy date
  ,p_validation_end_date      out nocopy date
  )
is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'perf_lck';
  --
  l_validation_start_date date;
  l_validation_end_date   date;
  --
  l_object_invalid        exception;
  --
  Cursor C_Sel1
  is
    select
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
    wait_perd_strt_dt,
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
    pl_ordr_num,
    plip_ordr_num,
    ptip_ordr_num,
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
    object_version_number
    from    ben_elig_per_f
    where   elig_per_id         = p_elig_per_id
    and        p_effective_date
    between effective_start_date and effective_end_date;
  --
begin
  --
  -- Check to ensure the datetrack mode is not INSERT.
  --
  If (p_datetrack_mode <> 'INSERT') then
    --
    -- We must select and lock the current row.
    --
    Open  C_Sel1;
    Fetch C_Sel1 Into ben_pep_shd.g_old_rec;
    If C_Sel1%notfound then
      Close C_Sel1;
      --
      -- The primary key is invalid therefore we must error
      --
      fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
      fnd_message.raise_error;
    End If;
    Close C_Sel1;
    If (p_object_version_number <> ben_pep_shd.g_old_rec.object_version_number)
    then
      fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
      fnd_message.raise_error;
    End If;
    hr_utility.set_location(l_proc, 15);
    --
    -- Validate the datetrack mode mode getting the validation start
    -- and end dates for the specified datetrack operation.
    --
    ben_batch_dt_api.validate_dt_mode_pep
      (p_effective_date        => p_effective_date
      ,p_datetrack_mode        => p_datetrack_mode
      ,p_elig_per_id           => p_elig_per_id
      --
      ,p_validation_start_date => l_validation_start_date
      ,p_validation_end_date   => l_validation_end_date
      );
    --
  Else
    --
    -- We are doing a datetrack 'INSERT' which is illegal within this
    -- procedure therefore we must error (note: to lck on insert the
    -- private procedure ins_lck should be called).
    --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','20');
    fnd_message.raise_error;
    --
  End If;
  --
  -- Set the validation start and end date OUT arguments
  --
  p_validation_start_date := l_validation_start_date;
  p_validation_end_date   := l_validation_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 30);
  --
Exception
  When HR_Api.Object_Locked then
    --
    -- The object is locked therefore we need to supply a meaningful
    -- error message.
    --
    fnd_message.set_name('PAY', 'HR_7165_OBJECT_LOCKED');
    fnd_message.set_token('TABLE_NAME', 'ben_elig_per_f');
    fnd_message.raise_error;
    --
  When l_object_invalid then
    --
    -- The object doesn't exist or is invalid
    --
    fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
    fnd_message.set_token('TABLE_NAME', 'ben_elig_per_f');
    fnd_message.raise_error;
    --
End perf_lck;
--
-- ----------------------------------------------------------------------------
-- |-------------------< update_perf_Eligible_Person >------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_perf_Eligible_Person
  (p_validate                       in boolean    default false
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
  ,p_wait_perd_strt_dt               in  date      default hr_api.g_date
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
  ,p_plip_ordr_num                    in  number    default hr_api.g_number
  ,p_ptip_ordr_num                    in  number    default hr_api.g_number
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
  ,p_datetrack_mode                 in  varchar2
  )
is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_perf_Eligible_Person';
  --
  l_rec                   ben_pep_shd.g_rec_type;
  l_object_version_number ben_elig_per_f.object_version_number%TYPE;
  l_effective_start_date  ben_elig_per_f.effective_start_date%TYPE;
  l_effective_end_date    ben_elig_per_f.effective_end_date%TYPE;
  --
  l_validation_start_date date;
  l_validation_end_date   date;
  l_dummy_version_number  number;
  --
  l_created_by            number;
  l_creation_date         date;
  l_last_update_date      date;
  l_last_updated_by       number;
  l_last_update_login     number;
  --
  l_base_table_name       varchar2(30);
  l_base_key_column       varchar2(30);
  l_base_key_value        number;
  --
  -- Cursor C_Sel1 selects the current locked row as of session date
  -- ensuring that the object version numbers match.
  --
  Cursor c_old_rec
  is
    select
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
    wait_perd_strt_dt,
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
    pl_ordr_num,
    plip_ordr_num,
    ptip_ordr_num,
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
    object_version_number
    from    ben_elig_per_f
    where   elig_per_id         = p_elig_per_id
    and        p_effective_date
    between effective_start_date and effective_end_date
    for update nowait;
  --
  Cursor C_Sel1
  Is
    select t.created_by,
           t.creation_date
    from   ben_elig_per_f t
    where  t.elig_per_id       = p_elig_per_id
    and    t.effective_start_date =
             ben_pep_shd.g_old_rec.effective_start_date
    and    t.effective_end_date = (l_validation_start_date - 1);
  --
  cursor c_effdates
    (c_eff_date date
    ,c_pep_id   number
    )
  is
    select pep.effective_start_date,
           pep.effective_end_date
    from ben_elig_per_f pep
    where pep.elig_per_id = c_pep_id
    and   c_eff_date
      between pep.effective_start_date and pep.effective_end_date;
  --
  cursor c_getovn
    (c_pep_id number
    )
  is
    select  nvl(max(pep.object_version_number),0) + 1
    from    ben_elig_per_f pep
    where   pep.elig_per_id = c_pep_id;
  --
  cursor c_plip
    (p_elig_per_id number, cv_pgm_id number) is
    select cpp.plip_id
    from ben_plip_f cpp,
         ben_elig_per_f pep
    where cpp.pl_id = pep.pl_id
    and   pep.elig_per_id = p_elig_per_id
    and cpp.pgm_id = cv_pgm_id                /* Bug 5098907 */
    and    p_effective_date
      between pep.effective_start_date and pep.effective_end_date
    and  p_effective_date
      between cpp.effective_start_date and cpp.effective_end_date;
  --
  l_pepinsplip g_pepapi_rectyp;
  l_plip_id   number;
  l_dummy_pep_id  number;
  l_dummy_esd     date;
  l_dummy_eed     date;
  l_dummy_ovn     number;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_perf_Eligible_Person;
  --
  hr_utility.set_location(l_proc, 20);
  --
  --bug#3974928 - to take care of wrong setup of track ineligible flag at plan
  --level and not at plip level
  if g_pepinsplip.p_pgm_id is not null
    and g_pepinsplip.p_plip_id is not null
    and g_pepinsplip.p_pl_id is null
    and g_pepinsplip.p_ptip_id is null then
    --
    open c_plip (p_elig_per_id, g_pepinsplip.p_pgm_id);
    fetch c_plip into l_plip_id;
    close c_plip;
    --
    if g_pepinsplip.p_plip_id = l_plip_id then
      --
       ben_Eligible_Person_perf_api.create_perf_Eligible_Person
      (p_validate                     => g_pepinsplip.p_validate
      ,p_elig_per_id                  => l_dummy_pep_id
      ,p_effective_start_date         => l_dummy_esd
      ,p_effective_end_date           => l_dummy_eed
      ,p_business_group_id            => g_pepinsplip.p_business_group_id
      ,p_pl_id                        => g_pepinsplip.p_pl_id
      ,p_pgm_id                       => g_pepinsplip.p_pgm_id
      ,p_plip_id                      => g_pepinsplip.p_plip_id
      ,p_ptip_id                      => g_pepinsplip.p_ptip_id
      ,p_ler_id                       => g_pepinsplip.p_ler_id
      ,p_person_id                    => g_pepinsplip.p_person_id
      ,p_per_in_ler_id                => g_pepinsplip.p_per_in_ler_id
      ,p_dpnt_othr_pl_cvrd_rl_flag    => g_pepinsplip.p_dpnt_othr_pl_cvrd_rl_flag
      ,p_prtn_ovridn_thru_dt          => g_pepinsplip.p_prtn_ovridn_thru_dt
      ,p_pl_key_ee_flag               => g_pepinsplip.p_pl_key_ee_flag
      ,p_pl_hghly_compd_flag          => g_pepinsplip.p_pl_hghly_compd_flag
      ,p_elig_flag                    => g_pepinsplip.p_elig_flag
      ,p_comp_ref_amt                 => g_pepinsplip.p_comp_ref_amt
      ,p_cmbn_age_n_los_val           => g_pepinsplip.p_cmbn_age_n_los_val
      ,p_comp_ref_uom                 => g_pepinsplip.p_comp_ref_uom
      ,p_age_val                      => g_pepinsplip.p_age_val
      ,p_los_val                      => g_pepinsplip.p_los_val
      ,p_prtn_end_dt                  => g_pepinsplip.p_prtn_end_dt
      ,p_prtn_strt_dt                 => g_pepinsplip.p_prtn_strt_dt
      ,p_wait_perd_cmpltn_dt          => g_pepinsplip.p_wait_perd_cmpltn_dt
      ,p_wait_perd_strt_dt            => g_pepinsplip.p_wait_perd_strt_dt
      ,p_wv_ctfn_typ_cd               => g_pepinsplip.p_wv_ctfn_typ_cd
      ,p_hrs_wkd_val                  => g_pepinsplip.p_hrs_wkd_val
      ,p_hrs_wkd_bndry_perd_cd        => g_pepinsplip.p_hrs_wkd_bndry_perd_cd
      ,p_prtn_ovridn_flag             => g_pepinsplip.p_prtn_ovridn_flag
      ,p_no_mx_prtn_ovrid_thru_flag   => g_pepinsplip.p_no_mx_prtn_ovrid_thru_flag
      ,p_prtn_ovridn_rsn_cd           => g_pepinsplip.p_prtn_ovridn_rsn_cd
      ,p_age_uom                      => g_pepinsplip.p_age_uom
      ,p_los_uom                      => g_pepinsplip.p_los_uom
      ,p_ovrid_svc_dt                 => g_pepinsplip.p_ovrid_svc_dt
      ,p_inelg_rsn_cd                 => g_pepinsplip.p_inelg_rsn_cd
      ,p_frz_los_flag                 => g_pepinsplip.p_frz_los_flag
      ,p_frz_age_flag                 => g_pepinsplip.p_frz_age_flag
      ,p_frz_cmp_lvl_flag             => g_pepinsplip.p_frz_cmp_lvl_flag
      ,p_frz_pct_fl_tm_flag           => g_pepinsplip.p_frz_pct_fl_tm_flag
      ,p_frz_hrs_wkd_flag             => g_pepinsplip.p_frz_hrs_wkd_flag
      ,p_frz_comb_age_and_los_flag    => g_pepinsplip.p_frz_comb_age_and_los_flag
      ,p_dstr_rstcn_flag              => g_pepinsplip.p_dstr_rstcn_flag
      ,p_pct_fl_tm_val                => g_pepinsplip.p_pct_fl_tm_val
      ,p_wv_prtn_rsn_cd               => g_pepinsplip.p_wv_prtn_rsn_cd
      ,p_pl_wvd_flag                  => g_pepinsplip.p_pl_wvd_flag
      ,p_rt_comp_ref_amt              => g_pepinsplip.p_rt_comp_ref_amt
      ,p_rt_cmbn_age_n_los_val        => g_pepinsplip.p_rt_cmbn_age_n_los_val
      ,p_rt_comp_ref_uom              => g_pepinsplip.p_rt_comp_ref_uom
      ,p_rt_age_val                   => g_pepinsplip.p_rt_age_val
      ,p_rt_los_val                   => g_pepinsplip.p_rt_los_val
      ,p_rt_hrs_wkd_val               => g_pepinsplip.p_rt_hrs_wkd_val
      ,p_rt_hrs_wkd_bndry_perd_cd     => g_pepinsplip.p_rt_hrs_wkd_bndry_perd_cd
      ,p_rt_age_uom                   => g_pepinsplip.p_rt_age_uom
      ,p_rt_los_uom                   => g_pepinsplip.p_rt_los_uom
      ,p_rt_pct_fl_tm_val             => g_pepinsplip.p_rt_pct_fl_tm_val
      ,p_rt_frz_los_flag              => g_pepinsplip.p_rt_frz_los_flag
      ,p_rt_frz_age_flag              => g_pepinsplip.p_rt_frz_age_flag
      ,p_rt_frz_cmp_lvl_flag          => g_pepinsplip.p_rt_frz_cmp_lvl_flag
      ,p_rt_frz_pct_fl_tm_flag        => g_pepinsplip.p_rt_frz_pct_fl_tm_flag
      ,p_rt_frz_hrs_wkd_flag          => g_pepinsplip.p_rt_frz_hrs_wkd_flag
      ,p_rt_frz_comb_age_and_los_flag => g_pepinsplip.p_rt_frz_comb_age_and_los_flag
      ,p_once_r_cntug_cd              => g_pepinsplip.p_once_r_cntug_cd
      ,p_pl_ordr_num                  => g_pepinsplip.p_pl_ordr_num
      ,p_plip_ordr_num                => g_pepinsplip.p_plip_ordr_num
      ,p_ptip_ordr_num                => g_pepinsplip.p_ptip_ordr_num
      ,p_pep_attribute_category       => g_pepinsplip.p_pep_attribute_category
      ,p_pep_attribute1               => g_pepinsplip.p_pep_attribute1
      ,p_pep_attribute2               => g_pepinsplip.p_pep_attribute2
      ,p_pep_attribute3               => g_pepinsplip.p_pep_attribute3
      ,p_pep_attribute4               => g_pepinsplip.p_pep_attribute4
      ,p_pep_attribute5               => g_pepinsplip.p_pep_attribute5
      ,p_pep_attribute6               => g_pepinsplip.p_pep_attribute6
      ,p_pep_attribute7               => g_pepinsplip.p_pep_attribute7
      ,p_pep_attribute8               => g_pepinsplip.p_pep_attribute8
      ,p_pep_attribute9               => g_pepinsplip.p_pep_attribute9
      ,p_pep_attribute10              => g_pepinsplip.p_pep_attribute10
      ,p_pep_attribute11              => g_pepinsplip.p_pep_attribute11
      ,p_pep_attribute12              => g_pepinsplip.p_pep_attribute12
      ,p_pep_attribute13              => g_pepinsplip.p_pep_attribute13
      ,p_pep_attribute14              => g_pepinsplip.p_pep_attribute14
      ,p_pep_attribute15              => g_pepinsplip.p_pep_attribute15
      ,p_pep_attribute16              => g_pepinsplip.p_pep_attribute16
      ,p_pep_attribute17              => g_pepinsplip.p_pep_attribute17
      ,p_pep_attribute18              => g_pepinsplip.p_pep_attribute18
      ,p_pep_attribute19              => g_pepinsplip.p_pep_attribute19
      ,p_pep_attribute20              => g_pepinsplip.p_pep_attribute20
      ,p_pep_attribute21              => g_pepinsplip.p_pep_attribute21
      ,p_pep_attribute22              => g_pepinsplip.p_pep_attribute22
      ,p_pep_attribute23              => g_pepinsplip.p_pep_attribute23
      ,p_pep_attribute24              => g_pepinsplip.p_pep_attribute24
      ,p_pep_attribute25              => g_pepinsplip.p_pep_attribute25
      ,p_pep_attribute26              => g_pepinsplip.p_pep_attribute26
      ,p_pep_attribute27              => g_pepinsplip.p_pep_attribute27
      ,p_pep_attribute28              => g_pepinsplip.p_pep_attribute28
      ,p_pep_attribute29              => g_pepinsplip.p_pep_attribute29
      ,p_pep_attribute30              => g_pepinsplip.p_pep_attribute30
      ,p_request_id                   => g_pepinsplip.p_request_id
      ,p_program_application_id       => g_pepinsplip.p_program_application_id
      ,p_program_id                   => g_pepinsplip.p_program_id
      ,p_program_update_date          => g_pepinsplip.p_program_update_date
      ,p_object_version_number        => l_dummy_ovn
      ,p_effective_date               => g_pepinsplip.p_effective_date
      ,p_override_validation          => g_pepinsplip.p_override_validation
      ,p_defer                        => false
      );
    --
      g_pepinsplip := l_pepinsplip;
      --
    end if;
    --
  end if;
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
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  l_rec :=
  ben_pep_shd.convert_args
  (
  p_elig_per_id,
  null,
  null,
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
  p_wait_perd_strt_dt  ,
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
  p_pl_ordr_num,
  p_plip_ordr_num,
  p_ptip_ordr_num,
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
  p_object_version_number
  );
  --
  -- We must lock the row which we need to update.
  --
  -- Check to ensure the datetrack mode is not INSERT.
  --
  If (p_datetrack_mode <> 'INSERT') then
    --
    -- We must select and lock the current row.
    --
    Open  c_old_rec;
    Fetch c_old_rec Into ben_pep_shd.g_old_rec;
    If c_old_rec%notfound then
      Close c_old_rec;
      --
      -- The primary key is invalid therefore we must error
      --
      fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
      fnd_message.raise_error;
    End If;
    Close c_old_rec;
    If (p_object_version_number <> ben_pep_shd.g_old_rec.object_version_number) Then
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
      End If;
    hr_utility.set_location(l_proc, 15);
    --
    -- Validate the datetrack mode mode getting the validation start
    -- and end dates for the specified datetrack operation.
    --
    ben_batch_dt_api.validate_dt_mode_pep
      (p_effective_date        => p_effective_date
      ,p_datetrack_mode        => p_datetrack_mode
      ,p_elig_per_id           => p_elig_per_id
      --
      ,p_validation_start_date => l_validation_start_date
      ,p_validation_end_date   => l_validation_end_date
      );
    --
  Else
    --
    -- We are doing a datetrack 'INSERT' which is illegal within this
    -- procedure therefore we must error (note: to lck on insert the
    -- private procedure ins_lck should be called).
    --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','20');
    fnd_message.raise_error;
    --
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 30);
  convert_defs(l_rec);
  --
  if  ben_manage_life_events.g_modified_mode in ('S','U','D') then  --ICM
    --compare values to decide whether to update or not
    if
      --
      nvl(ben_pep_shd.g_old_rec.pl_id,-1) <> nvl(l_rec.pl_id,-1) or
      nvl(ben_pep_shd.g_old_rec.pgm_id,-1) <> nvl(l_rec.pgm_id,-1) or
      nvl(ben_pep_shd.g_old_rec.plip_id,-1) <> nvl(l_rec.plip_id,-1) or
      nvl(ben_pep_shd.g_old_rec.ptip_id,-1) <> nvl(l_rec.ptip_id,-1) or
      nvl(ben_pep_shd.g_old_rec.ler_id,-1)  <> nvl(l_rec.ler_id,-1) or
      nvl(ben_pep_shd.g_old_rec.dpnt_othr_pl_cvrd_rl_flag,'N') <>
      nvl(l_rec.dpnt_othr_pl_cvrd_rl_flag,'N') or
      nvl(ben_pep_shd.g_old_rec.prtn_ovridn_thru_dt,to_date('01-01-1001','dd-mm-yyyy'))<>
      nvl(l_rec.prtn_ovridn_thru_dt,to_date('01-01-1001','dd-mm-yyyy'))  or
      nvl(ben_pep_shd.g_old_rec.pl_key_ee_flag,'N')<> nvl(l_rec.pl_key_ee_flag,'N') or
      nvl(ben_pep_shd.g_old_rec.pl_hghly_compd_flag,'N') <> nvl(l_rec.pl_hghly_compd_flag,'N') or
      nvl(ben_pep_shd.g_old_rec.elig_flag,'N') <>  nvl(l_rec.elig_flag,'N') or
      nvl(ben_pep_shd.g_old_rec.comp_ref_amt,-1) <> nvl(l_rec.comp_ref_amt,-1) or
      nvl(ben_pep_shd.g_old_rec.cmbn_age_n_los_val, -1) <> nvl(l_rec.cmbn_age_n_los_val, -1) or
      nvl(ben_pep_shd.g_old_rec.comp_ref_uom,'X') <>  nvl(l_rec.comp_ref_uom,'X') or
      nvl(ben_pep_shd.g_old_rec.age_val, -1) <> nvl(l_rec.age_val, -1) or
      nvl(ben_pep_shd.g_old_rec.los_val, -1) <> nvl(l_rec.los_val, -1) or
      nvl(ben_pep_shd.g_old_rec.prtn_end_dt,to_date('01-01-1001','dd-mm-yyyy')) <>
      nvl(l_rec.prtn_end_dt,to_date('01-01-1001','dd-mm-yyyy')) or
      nvl(ben_pep_shd.g_old_rec.wait_perd_cmpltn_dt,to_date('01-01-1001','dd-mm-yyyy')) <>
      nvl(l_rec.wait_perd_cmpltn_dt,to_date('01-01-1001','dd-mm-yyyy')) or
      nvl(ben_pep_shd.g_old_rec.wait_perd_strt_dt,to_date('01-01-1001','dd-mm-yyyy')) <>
      nvl(l_rec.wait_perd_strt_dt,to_date('01-01-1001','dd-mm-yyyy')) or
      nvl(ben_pep_shd.g_old_rec.wv_ctfn_typ_cd,'X') <> nvl(l_rec.wv_ctfn_typ_cd,'X') or
      nvl(ben_pep_shd.g_old_rec.hrs_wkd_val,-1) <> nvl(l_rec.hrs_wkd_val,-1) or
      nvl(ben_pep_shd.g_old_rec.hrs_wkd_bndry_perd_cd,'X') <> nvl(l_rec.hrs_wkd_bndry_perd_cd,'X') or
      nvl(ben_pep_shd.g_old_rec.prtn_ovridn_flag,'N') <> nvl(l_rec.prtn_ovridn_flag,'N') or
      nvl(ben_pep_shd.g_old_rec.no_mx_prtn_ovrid_thru_flag,'N') <>
      nvl(l_rec.no_mx_prtn_ovrid_thru_flag,'N') or
      nvl(ben_pep_shd.g_old_rec.prtn_ovridn_rsn_cd, 'X') <>
      nvl(l_rec.prtn_ovridn_rsn_cd, 'X') or
      nvl(ben_pep_shd.g_old_rec.age_uom,'X') <>  nvl(l_rec.age_uom,'X') or
      nvl(ben_pep_shd.g_old_rec.los_uom,'X') <> nvl(l_rec.los_uom,'X') or
      nvl(ben_pep_shd.g_old_rec.ovrid_svc_dt,to_date('01-01-1001','dd-mm-yyyy')) <>
      nvl(l_rec.ovrid_svc_dt,to_date('01-01-1001','dd-mm-yyyy')) or
      nvl(ben_pep_shd.g_old_rec.inelg_rsn_cd,'X') <> nvl(l_rec.inelg_rsn_cd,'X') or
      nvl(ben_pep_shd.g_old_rec.frz_los_flag,'N') <> nvl(l_rec.frz_los_flag,'N') or
      nvl(ben_pep_shd.g_old_rec.frz_age_flag,'N') <> nvl(l_rec.frz_age_flag,'N') or
      nvl(ben_pep_shd.g_old_rec.frz_cmp_lvl_flag,'N') <> nvl(l_rec.frz_cmp_lvl_flag,'N') or
      nvl(ben_pep_shd.g_old_rec.frz_pct_fl_tm_flag,'N') <> nvl(l_rec.frz_pct_fl_tm_flag,'N') or
      nvl(ben_pep_shd.g_old_rec.frz_hrs_wkd_flag,'N') <> nvl(l_rec.frz_hrs_wkd_flag,'N') or
      nvl(ben_pep_shd.g_old_rec.frz_comb_age_and_los_flag,'N') <> nvl(l_rec.frz_comb_age_and_los_flag,'N') or
      nvl(ben_pep_shd.g_old_rec.dstr_rstcn_flag,'N') <> nvl(l_rec.dstr_rstcn_flag,'N') or
      nvl(ben_pep_shd.g_old_rec.pct_fl_tm_val,-1) <> nvl(l_rec.pct_fl_tm_val,-1) or
      nvl(ben_pep_shd.g_old_rec.wv_prtn_rsn_cd,'X') <> nvl(l_rec.wv_prtn_rsn_cd,'X') or
      nvl(ben_pep_shd.g_old_rec.pl_wvd_flag,'N')  <> nvl(l_rec.pl_wvd_flag,'N') or
      nvl(ben_pep_shd.g_old_rec.rt_comp_ref_amt,-1) <> nvl(l_rec.rt_comp_ref_amt,-1) or
      nvl(ben_pep_shd.g_old_rec.rt_cmbn_age_n_los_val,-1) <> nvl(l_rec.rt_cmbn_age_n_los_val,-1) or
      nvl(ben_pep_shd.g_old_rec.rt_comp_ref_uom,'X') <> nvl(l_rec.rt_comp_ref_uom,'X') or
      nvl(ben_pep_shd.g_old_rec.rt_age_val,-1) <> nvl(l_rec.rt_age_val,-1) or
      nvl(ben_pep_shd.g_old_rec.rt_los_val,-1) <> nvl(l_rec.rt_los_val,-1) or
      nvl(ben_pep_shd.g_old_rec.rt_hrs_wkd_val,-1) <> nvl(l_rec.rt_hrs_wkd_val,-1) or
      nvl(ben_pep_shd.g_old_rec.rt_hrs_wkd_bndry_perd_cd,'X') <>
      nvl(l_rec.rt_hrs_wkd_bndry_perd_cd,'X') or
      nvl(ben_pep_shd.g_old_rec.rt_age_uom,'X') <> nvl(l_rec.rt_age_uom,'X') or
      nvl(ben_pep_shd.g_old_rec.rt_los_uom,'X') <> nvl(l_rec.rt_los_uom,'X') or
      nvl(ben_pep_shd.g_old_rec.rt_pct_fl_tm_val,-1) <> nvl(l_rec.rt_pct_fl_tm_val,-1) or
      nvl(ben_pep_shd.g_old_rec.rt_frz_los_flag,'N') <> nvl(l_rec.rt_frz_los_flag,'N') or
      nvl(ben_pep_shd.g_old_rec.rt_frz_age_flag,'N') <> nvl(l_rec.rt_frz_age_flag,'N') or
      nvl(ben_pep_shd.g_old_rec.rt_frz_cmp_lvl_flag,'N') <> nvl(l_rec.rt_frz_cmp_lvl_flag,'N') or
      nvl(ben_pep_shd.g_old_rec.rt_frz_pct_fl_tm_flag,'N') <> nvl(l_rec.rt_frz_pct_fl_tm_flag,'N') or
      nvl(ben_pep_shd.g_old_rec.rt_frz_hrs_wkd_flag,'N') <> nvl(l_rec.rt_frz_hrs_wkd_flag,'N') or
      nvl(ben_pep_shd.g_old_rec.rt_frz_comb_age_and_los_flag,'N') <>
      nvl(l_rec.rt_frz_comb_age_and_los_flag,'N') or
      nvl(ben_pep_shd.g_old_rec.once_r_cntug_cd,'X') <> nvl(l_rec.once_r_cntug_cd,'X') or
      nvl(ben_pep_shd.g_old_rec.pl_ordr_num,-1) <> nvl(l_rec.pl_ordr_num,-1) or
      nvl(ben_pep_shd.g_old_rec.plip_ordr_num,-1) <> nvl(l_rec.plip_ordr_num,-1) or
      nvl(ben_pep_shd.g_old_rec.ptip_ordr_num,-1) <> nvl(l_rec.ptip_ordr_num,-1)
       then
     -- do nothing
      null;
      --
    else
      --
      return;
      --
    end if;
    --
   end if;
  -- Call the supporting pre-update operation

  If (p_datetrack_mode <> 'CORRECTION') then
    hr_utility.set_location(l_proc, 10);
    --
    open c_getovn
      (c_pep_id => p_elig_per_id
      );
    fetch c_getovn into l_object_version_number;
    close c_getovn;
    --
    ben_pep_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Update the specified datetrack row setting the effective
    -- end date to the specified new effective end date.
    --
    update  ben_elig_per_f t
    set     t.effective_end_date    = l_validation_start_date - 1,
            t.object_version_number = l_object_version_number
    where   t.elig_per_id           = p_elig_per_id
    and     p_effective_date
    between t.effective_start_date and t.effective_end_date;
    --
    ben_pep_shd.g_api_dml := false;   -- Unset the api dml status
    --
    If (p_datetrack_mode = 'UPDATE_OVERRIDE') then
      hr_utility.set_location(l_proc, 15);
      --
      -- As the datetrack mode is 'UPDATE_OVERRIDE' then we must
      -- delete any future rows
      --
      If (p_datetrack_mode = 'DELETE_NEXT_CHANGE') then
        hr_utility.set_location(l_proc, 10);
        ben_pep_shd.g_api_dml := true;  -- Set the api dml status
        --
        -- Delete the where the effective start date is equal
        -- to the validation end date.
        --
        delete from ben_elig_per_f
        where elig_per_id = p_elig_per_id
        and   effective_start_date = l_validation_start_date;
        --
        ben_pep_shd.g_api_dml := false;   -- Unset the api dml status
      Else
        hr_utility.set_location(l_proc, 15);
        ben_pep_shd.g_api_dml := true;  -- Set the api dml status
        --
        -- Delete the row(s) where the effective start date is greater than
        -- or equal to the validation start date.
        --
        delete from ben_elig_per_f
        where elig_per_id = p_elig_per_id
        and   effective_start_date >= l_validation_start_date;
        --
        ben_pep_shd.g_api_dml := false;   -- Unset the api dml status
      End If;
      --
    End If;
    hr_utility.set_location(l_proc, 20);
    --
    -- We must now insert the updated row (insert_dml)
    --
    -- Get the object version number for the insert
    --
    open c_getovn
      (c_pep_id => p_elig_per_id
      );
    fetch c_getovn into l_rec.object_version_number;
    close c_getovn;
    --
    hr_utility.set_location('Dn DTAPI_GOVN:'||l_proc, 5);
    --
    -- Set the effective start and end dates to the corresponding
    -- validation start and end dates
    --
    l_rec.effective_start_date := l_validation_start_date;
    l_rec.effective_end_date   := l_validation_end_date;
    --
    -- If the datetrack_mode is not INSERT then we must populate the WHO
    -- columns with the 'old' creation values and 'new' updated values.
    --
    If (p_datetrack_mode <> 'INSERT') then
      hr_utility.set_location(l_proc, 10);
      --
      -- Select the 'old' created values
      --
      Open C_Sel1;
      Fetch C_Sel1 Into l_created_by, l_creation_date;
      If C_Sel1%notfound Then
        --
        -- The previous 'old' created row has not been found. We need
        -- to error as an internal datetrack problem exists.
        --
        Close C_Sel1;
        fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
        fnd_message.set_token('PROCEDURE', l_proc);
        fnd_message.set_token('STEP','10');
        fnd_message.raise_error;
      End If;
      Close C_Sel1;
      --
      -- Set the AOL updated WHO values
      --
      l_last_update_date   := sysdate;
      l_last_updated_by    := fnd_global.user_id;
      l_last_update_login  := fnd_global.login_id;
    End If;
    --
    ben_pep_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Insert the row into: ben_elig_per_f
    --
    hr_utility.set_location('Ins PEP:'||l_proc, 5);
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
      wait_perd_strt_dt ,
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
      pl_ordr_num,
      plip_ordr_num,
      ptip_ordr_num,
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
      l_rec.elig_per_id,
      l_rec.effective_start_date,
      l_rec.effective_end_date,
      l_rec.business_group_id,
      l_rec.pl_id,
      l_rec.pgm_id,
      l_rec.plip_id,
      l_rec.ptip_id,
      l_rec.ler_id,
      l_rec.person_id,
      l_rec.per_in_ler_id,
      l_rec.dpnt_othr_pl_cvrd_rl_flag,
      l_rec.prtn_ovridn_thru_dt,
      l_rec.pl_key_ee_flag,
      l_rec.pl_hghly_compd_flag,
      l_rec.elig_flag,
      l_rec.comp_ref_amt,
      l_rec.cmbn_age_n_los_val,
      l_rec.comp_ref_uom,
      l_rec.age_val,
      l_rec.los_val,
      l_rec.prtn_end_dt,
      l_rec.prtn_strt_dt,
      l_rec.wait_perd_cmpltn_dt,
      l_rec.wait_perd_strt_dt ,
      l_rec.wv_ctfn_typ_cd,
      l_rec.hrs_wkd_val,
      l_rec.hrs_wkd_bndry_perd_cd,
      l_rec.prtn_ovridn_flag,
      l_rec.no_mx_prtn_ovrid_thru_flag,
      l_rec.prtn_ovridn_rsn_cd,
      l_rec.age_uom,
      l_rec.los_uom,
      l_rec.ovrid_svc_dt,
      l_rec.inelg_rsn_cd,
      l_rec.frz_los_flag,
      l_rec.frz_age_flag,
      l_rec.frz_cmp_lvl_flag,
      l_rec.frz_pct_fl_tm_flag,
      l_rec.frz_hrs_wkd_flag,
      l_rec.frz_comb_age_and_los_flag,
      l_rec.dstr_rstcn_flag,
      l_rec.pct_fl_tm_val,
      l_rec.wv_prtn_rsn_cd,
      l_rec.pl_wvd_flag,
      l_rec.rt_comp_ref_amt,
      l_rec.rt_cmbn_age_n_los_val,
      l_rec.rt_comp_ref_uom,
      l_rec.rt_age_val,
      l_rec.rt_los_val,
      l_rec.rt_hrs_wkd_val,
      l_rec.rt_hrs_wkd_bndry_perd_cd,
      l_rec.rt_age_uom,
      l_rec.rt_los_uom,
      l_rec.rt_pct_fl_tm_val,
      l_rec.rt_frz_los_flag,
      l_rec.rt_frz_age_flag,
      l_rec.rt_frz_cmp_lvl_flag,
      l_rec.rt_frz_pct_fl_tm_flag,
      l_rec.rt_frz_hrs_wkd_flag,
      l_rec.rt_frz_comb_age_and_los_flag,
      l_rec.once_r_cntug_cd,
      l_rec.pl_ordr_num,
      l_rec.plip_ordr_num,
      l_rec.ptip_ordr_num,
      l_rec.pep_attribute_category,
      l_rec.pep_attribute1,
      l_rec.pep_attribute2,
      l_rec.pep_attribute3,
      l_rec.pep_attribute4,
      l_rec.pep_attribute5,
      l_rec.pep_attribute6,
      l_rec.pep_attribute7,
      l_rec.pep_attribute8,
      l_rec.pep_attribute9,
      l_rec.pep_attribute10,
      l_rec.pep_attribute11,
      l_rec.pep_attribute12,
      l_rec.pep_attribute13,
      l_rec.pep_attribute14,
      l_rec.pep_attribute15,
      l_rec.pep_attribute16,
      l_rec.pep_attribute17,
      l_rec.pep_attribute18,
      l_rec.pep_attribute19,
      l_rec.pep_attribute20,
      l_rec.pep_attribute21,
      l_rec.pep_attribute22,
      l_rec.pep_attribute23,
      l_rec.pep_attribute24,
      l_rec.pep_attribute25,
      l_rec.pep_attribute26,
      l_rec.pep_attribute27,
      l_rec.pep_attribute28,
      l_rec.pep_attribute29,
      l_rec.pep_attribute30,
      l_rec.request_id,
      l_rec.program_application_id,
      l_rec.program_id,
      l_rec.program_update_date,
      l_rec.object_version_number,
      l_created_by,
      l_creation_date,
      l_last_update_date,
      l_last_updated_by,
      l_last_update_login
    );
    --
    ben_pep_shd.g_api_dml := false;   -- Unset the api dml status
  End If;
  --
  -- update_dml
  --
  If (p_datetrack_mode = 'CORRECTION') then
    hr_utility.set_location(l_proc, 10);
    --
    -- Because we are updating a row we must get the next object
    -- version number.
    --
    open c_getovn
      (c_pep_id => l_rec.elig_per_id
      );
    fetch c_getovn into l_rec.object_version_number;
    close c_getovn;
    --
    ben_pep_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Update the ben_elig_per_f Row
    --
    update  ben_elig_per_f
    set
    elig_per_id                     = l_rec.elig_per_id,
    business_group_id               = l_rec.business_group_id,
    pl_id                           = l_rec.pl_id,
    pgm_id                          = l_rec.pgm_id,
    plip_id                         = l_rec.plip_id,
    ptip_id                         = l_rec.ptip_id,
    ler_id                          = l_rec.ler_id,
    person_id                       = l_rec.person_id,
    per_in_ler_id                       = l_rec.per_in_ler_id,
    dpnt_othr_pl_cvrd_rl_flag       = l_rec.dpnt_othr_pl_cvrd_rl_flag,
    prtn_ovridn_thru_dt             = l_rec.prtn_ovridn_thru_dt,
    pl_key_ee_flag                  = l_rec.pl_key_ee_flag,
    pl_hghly_compd_flag             = l_rec.pl_hghly_compd_flag,
    elig_flag                       = l_rec.elig_flag,
    comp_ref_amt                    = l_rec.comp_ref_amt,
    cmbn_age_n_los_val              = l_rec.cmbn_age_n_los_val,
    comp_ref_uom                    = l_rec.comp_ref_uom,
    age_val                         = l_rec.age_val,
    los_val                         = l_rec.los_val,
    prtn_end_dt                     = l_rec.prtn_end_dt,
    prtn_strt_dt                    = l_rec.prtn_strt_dt,
    wait_perd_cmpltn_dt             = l_rec.wait_perd_cmpltn_dt,
    wait_perd_strt_dt               = l_rec.wait_perd_strt_dt,
    wv_ctfn_typ_cd                  = l_rec.wv_ctfn_typ_cd,
    hrs_wkd_val                     = l_rec.hrs_wkd_val,
    hrs_wkd_bndry_perd_cd           = l_rec.hrs_wkd_bndry_perd_cd,
    prtn_ovridn_flag                = l_rec.prtn_ovridn_flag,
    no_mx_prtn_ovrid_thru_flag      = l_rec.no_mx_prtn_ovrid_thru_flag,
    prtn_ovridn_rsn_cd              = l_rec.prtn_ovridn_rsn_cd,
    age_uom                         = l_rec.age_uom,
    los_uom                         = l_rec.los_uom,
    ovrid_svc_dt                    = l_rec.ovrid_svc_dt,
    inelg_rsn_cd                    = l_rec.inelg_rsn_cd,
    frz_los_flag                    = l_rec.frz_los_flag,
    frz_age_flag                    = l_rec.frz_age_flag,
    frz_cmp_lvl_flag                = l_rec.frz_cmp_lvl_flag,
    frz_pct_fl_tm_flag              = l_rec.frz_pct_fl_tm_flag,
    frz_hrs_wkd_flag                = l_rec.frz_hrs_wkd_flag,
    frz_comb_age_and_los_flag       = l_rec.frz_comb_age_and_los_flag,
    dstr_rstcn_flag                 = l_rec.dstr_rstcn_flag,
    pct_fl_tm_val                   = l_rec.pct_fl_tm_val,
    wv_prtn_rsn_cd                  = l_rec.wv_prtn_rsn_cd,
    pl_wvd_flag                     = l_rec.pl_wvd_flag,
    rt_comp_ref_amt                 = l_rec.rt_comp_ref_amt,
    rt_cmbn_age_n_los_val           = l_rec.rt_cmbn_age_n_los_val,
    rt_comp_ref_uom                 = l_rec.rt_comp_ref_uom,
    rt_age_val                      = l_rec.rt_age_val,
    rt_los_val                      = l_rec.rt_los_val,
    rt_hrs_wkd_val                  = l_rec.rt_hrs_wkd_val,
    rt_hrs_wkd_bndry_perd_cd        = l_rec.rt_hrs_wkd_bndry_perd_cd,
    rt_age_uom                      = l_rec.rt_age_uom,
    rt_los_uom                      = l_rec.rt_los_uom,
    rt_pct_fl_tm_val                = l_rec.rt_pct_fl_tm_val,
    rt_frz_los_flag                 = l_rec.rt_frz_los_flag,
    rt_frz_age_flag                 = l_rec.rt_frz_age_flag,
    rt_frz_cmp_lvl_flag             = l_rec.rt_frz_cmp_lvl_flag,
    rt_frz_pct_fl_tm_flag           = l_rec.rt_frz_pct_fl_tm_flag,
    rt_frz_hrs_wkd_flag             = l_rec.rt_frz_hrs_wkd_flag,
    rt_frz_comb_age_and_los_flag    = l_rec.rt_frz_comb_age_and_los_flag,
    once_r_cntug_cd                 = l_rec.once_r_cntug_cd,
    pl_ordr_num                     = l_rec.pl_ordr_num,
    plip_ordr_num                   = l_rec.plip_ordr_num,
    ptip_ordr_num                   = l_rec.ptip_ordr_num,
    pep_attribute_category          = l_rec.pep_attribute_category,
    pep_attribute1                  = l_rec.pep_attribute1,
    pep_attribute2                  = l_rec.pep_attribute2,
    pep_attribute3                  = l_rec.pep_attribute3,
    pep_attribute4                  = l_rec.pep_attribute4,
    pep_attribute5                  = l_rec.pep_attribute5,
    pep_attribute6                  = l_rec.pep_attribute6,
    pep_attribute7                  = l_rec.pep_attribute7,
    pep_attribute8                  = l_rec.pep_attribute8,
    pep_attribute9                  = l_rec.pep_attribute9,
    pep_attribute10                 = l_rec.pep_attribute10,
    pep_attribute11                 = l_rec.pep_attribute11,
    pep_attribute12                 = l_rec.pep_attribute12,
    pep_attribute13                 = l_rec.pep_attribute13,
    pep_attribute14                 = l_rec.pep_attribute14,
    pep_attribute15                 = l_rec.pep_attribute15,
    pep_attribute16                 = l_rec.pep_attribute16,
    pep_attribute17                 = l_rec.pep_attribute17,
    pep_attribute18                 = l_rec.pep_attribute18,
    pep_attribute19                 = l_rec.pep_attribute19,
    pep_attribute20                 = l_rec.pep_attribute20,
    pep_attribute21                 = l_rec.pep_attribute21,
    pep_attribute22                 = l_rec.pep_attribute22,
    pep_attribute23                 = l_rec.pep_attribute23,
    pep_attribute24                 = l_rec.pep_attribute24,
    pep_attribute25                 = l_rec.pep_attribute25,
    pep_attribute26                 = l_rec.pep_attribute26,
    pep_attribute27                 = l_rec.pep_attribute27,
    pep_attribute28                 = l_rec.pep_attribute28,
    pep_attribute29                 = l_rec.pep_attribute29,
    pep_attribute30                 = l_rec.pep_attribute30,
    request_id                      = l_rec.request_id,
    program_application_id          = l_rec.program_application_id,
    program_id                      = l_rec.program_id,
    program_update_date             = l_rec.program_update_date,
    object_version_number           = l_rec.object_version_number
    where   elig_per_id = l_rec.elig_per_id
    and     effective_start_date = l_validation_start_date
    and     effective_end_date   = l_validation_end_date;
    --
    ben_pep_shd.g_api_dml := false;   -- Unset the api dml status
    --
    -- Set the effective start and end dates
    --
    l_rec.effective_start_date := l_validation_start_date;
    l_rec.effective_end_date   := l_validation_end_date;
  End If;
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_Eligible_Person
    --
    ben_Eligible_Person_bk2.update_Eligible_Person_a
      (p_elig_per_id                    =>  p_elig_per_id
      ,p_effective_start_date           =>  l_rec.effective_start_date
      ,p_effective_end_date             =>  l_rec.effective_end_date
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
  p_object_version_number := l_rec.object_version_number;
  p_effective_start_date := l_rec.effective_start_date;
  p_effective_end_date := l_rec.effective_end_date;
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
    ROLLBACK TO update_perf_Eligible_Person;
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
    ROLLBACK TO update_perf_Eligible_Person;
    p_effective_start_date := null;
    p_effective_end_date := null;
    p_object_version_number  := l_object_version_number;
    raise;
    --
end update_perf_Eligible_Person;
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
  -- ,p_wait_perd_cmpltn_dt            in  date      default null
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
    --wait_perd_cmpltn_dt,
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
    -- p_wait_perd_cmpltn_dt,
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
-- |----------------------< update_perf_Elig_Person_Option >------------------|
-- ----------------------------------------------------------------------------
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure lck
  (p_effective_date        in     date
  ,p_datetrack_mode        in     varchar2
  ,p_elig_per_opt_id       in     number
  ,p_object_version_number in     number
  ,p_validation_start_date    out nocopy date
  ,p_validation_end_date      out nocopy date
  )
is
  --
  l_proc          varchar2(72) := g_package||'lck';
  l_validation_start_date date;
  l_validation_end_date   date;
  l_object_invalid        exception;
  l_argument              varchar2(30);
  --
  -- Cursor C_Sel1 selects the current locked row as of session date
  -- ensuring that the object version numbers match.
  --
  Cursor C_Sel1 is
    select
    elig_per_opt_id,
    elig_per_id,
    effective_start_date,
    effective_end_date,
    prtn_ovridn_flag,
    prtn_ovridn_thru_dt,
    no_mx_prtn_ovrid_thru_flag,
    elig_flag,
    prtn_strt_dt,
    prtn_end_dt,
    -- wait_perd_cmpltn_dt,
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
    object_version_number
    from    ben_elig_per_opt_f
    where   elig_per_opt_id         = p_elig_per_opt_id
    and        p_effective_date
    between effective_start_date and effective_end_date;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that all the mandatory arguments are not null
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'effective_date',
                             p_argument_value => p_effective_date);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'datetrack_mode',
                             p_argument_value => p_datetrack_mode);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'elig_per_opt_id',
                             p_argument_value => p_elig_per_opt_id);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'object_version_number',
                             p_argument_value => p_object_version_number);
  --
  -- Check to ensure the datetrack mode is not INSERT.
  --
  If (p_datetrack_mode <> 'INSERT') then
    --
    -- We must select and lock the current row.
    --
    Open  C_Sel1;
    Fetch C_Sel1 Into ben_epo_shd.g_old_rec;
    If C_Sel1%notfound then
      Close C_Sel1;
      --
      -- The primary key is invalid therefore we must error
      --
      fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
      fnd_message.raise_error;
    End If;
    Close C_Sel1;
    If (p_object_version_number <> ben_epo_shd.g_old_rec.object_version_number) Then
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
      End If;
    hr_utility.set_location(l_proc, 15);
    --
    --
    -- Validate the datetrack mode mode getting the validation start
    -- and end dates for the specified datetrack operation.
    --
    dt_api.validate_dt_mode
    (p_effective_date       => p_effective_date,
     p_datetrack_mode       => p_datetrack_mode,
     p_base_table_name       => 'ben_elig_per_opt_f',
     p_base_key_column       => 'elig_per_opt_id',
     p_base_key_value        => p_elig_per_opt_id,
/*
     p_parent_table_name1      => 'ben_elig_per_f',
     p_parent_key_column1      => 'elig_per_id',
     p_parent_key_value1       => g_old_rec.elig_per_id,
*/
     p_parent_table_name2      => 'ben_opt_f',
     p_parent_key_column2      => 'opt_id',
     p_parent_key_value2       => ben_epo_shd.g_old_rec.opt_id,
     p_enforce_foreign_locking => false,
     p_validation_start_date   => l_validation_start_date,
     p_validation_end_date       => l_validation_end_date);
    --
  Else
    --
    -- We are doing a datetrack 'INSERT' which is illegal within this
    -- procedure therefore we must error (note: to lck on insert the
    -- private procedure ins_lck should be called).
    --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','20');
    fnd_message.raise_error;
  End If;
  --
  -- Set the validation start and end date OUT arguments
  --
  p_validation_start_date := l_validation_start_date;
  p_validation_end_date   := l_validation_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 30);
--
-- We need to trap the ORA LOCK exception
--
Exception
  When HR_Api.Object_Locked then
    --
    -- The object is locked therefore we need to supply a meaningful
    -- error message.
    --
    fnd_message.set_name('PAY', 'HR_7165_OBJECT_LOCKED');
    fnd_message.set_token('TABLE_NAME', 'ben_elig_per_opt_f');
    fnd_message.raise_error;
  When l_object_invalid then
    --
    -- The object doesn't exist or is invalid
    --
    fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
    fnd_message.set_token('TABLE_NAME', 'ben_elig_per_opt_f');
    fnd_message.raise_error;
End lck;
-- ----------------------------------------------------------------------------
-- |---------------------------< epo_convert_defs >---------------------------|
-- ----------------------------------------------------------------------------
--
Procedure epo_convert_defs
  (p_rec in out nocopy ben_epo_shd.g_rec_type
  )
is
--
  l_proc  varchar2(72) := g_package||'epo_convert_defs';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.elig_per_id = hr_api.g_number) then
    p_rec.elig_per_id :=
    ben_epo_shd.g_old_rec.elig_per_id;
  End If;
  If (p_rec.prtn_ovridn_flag = hr_api.g_varchar2) then
    p_rec.prtn_ovridn_flag :=
    ben_epo_shd.g_old_rec.prtn_ovridn_flag;
  End If;
  If (p_rec.prtn_ovridn_thru_dt = hr_api.g_date) then
    p_rec.prtn_ovridn_thru_dt :=
    ben_epo_shd.g_old_rec.prtn_ovridn_thru_dt;
  End If;
  If (p_rec.no_mx_prtn_ovrid_thru_flag = hr_api.g_varchar2) then
    p_rec.no_mx_prtn_ovrid_thru_flag :=
    ben_epo_shd.g_old_rec.no_mx_prtn_ovrid_thru_flag;
  End If;
  If (p_rec.elig_flag = hr_api.g_varchar2) then
    p_rec.elig_flag :=
    ben_epo_shd.g_old_rec.elig_flag;
  End If;
  If (p_rec.prtn_strt_dt = hr_api.g_date) then
    p_rec.prtn_strt_dt :=
    ben_epo_shd.g_old_rec.prtn_strt_dt;
  End If;
  If (p_rec.prtn_end_dt = hr_api.g_date) then
    p_rec.prtn_end_dt :=
    ben_epo_shd.g_old_rec.prtn_end_dt;
  End If;
  /*
 If (p_rec.wait_perd_cmpltn_dt = hr_api.g_date) then
    p_rec.wait_perd_cmpltn_dt :=
    ben_epo_shd.g_old_rec.wait_perd_cmpltn_dt;
  End If;
  */
 If (p_rec.wait_perd_cmpltn_date = hr_api.g_date) then
    p_rec.wait_perd_cmpltn_date :=
    ben_epo_shd.g_old_rec.wait_perd_cmpltn_date;
  End If;
  If (p_rec.wait_perd_strt_dt = hr_api.g_date) then
    p_rec.wait_perd_strt_dt :=
    ben_epo_shd.g_old_rec.wait_perd_strt_dt;
  End If;
  If (p_rec.prtn_ovridn_rsn_cd = hr_api.g_varchar2) then
    p_rec.prtn_ovridn_rsn_cd :=
    ben_epo_shd.g_old_rec.prtn_ovridn_rsn_cd;
  End If;
  If (p_rec.pct_fl_tm_val = hr_api.g_number) then
    p_rec.pct_fl_tm_val :=
    ben_epo_shd.g_old_rec.pct_fl_tm_val;
  End If;
  If (p_rec.opt_id = hr_api.g_number) then
    p_rec.opt_id :=
    ben_epo_shd.g_old_rec.opt_id;
  End If;
  If (p_rec.per_in_ler_id = hr_api.g_number) then
    p_rec.per_in_ler_id :=
    ben_epo_shd.g_old_rec.per_in_ler_id;
  End If;
  If (p_rec.rt_comp_ref_amt = hr_api.g_number) then
    p_rec.rt_comp_ref_amt :=
    ben_epo_shd.g_old_rec.rt_comp_ref_amt;
  End If;
  If (p_rec.rt_cmbn_age_n_los_val = hr_api.g_number) then
    p_rec.rt_cmbn_age_n_los_val :=
    ben_epo_shd.g_old_rec.rt_cmbn_age_n_los_val;
  End If;
  If (p_rec.rt_comp_ref_uom = hr_api.g_varchar2) then
    p_rec.rt_comp_ref_uom :=
    ben_epo_shd.g_old_rec.rt_comp_ref_uom;
  End If;
  If (p_rec.rt_age_val = hr_api.g_number) then
    p_rec.rt_age_val :=
    ben_epo_shd.g_old_rec.rt_age_val;
  End If;
  If (p_rec.rt_los_val = hr_api.g_number) then
    p_rec.rt_los_val :=
    ben_epo_shd.g_old_rec.rt_los_val;
  End If;
  If (p_rec.rt_hrs_wkd_val = hr_api.g_number) then
    p_rec.rt_hrs_wkd_val :=
    ben_epo_shd.g_old_rec.rt_hrs_wkd_val;
  End If;
  If (p_rec.rt_hrs_wkd_bndry_perd_cd = hr_api.g_varchar2) then
    p_rec.rt_hrs_wkd_bndry_perd_cd :=
    ben_epo_shd.g_old_rec.rt_hrs_wkd_bndry_perd_cd;
  End If;
  If (p_rec.rt_age_uom = hr_api.g_varchar2) then
    p_rec.rt_age_uom :=
    ben_epo_shd.g_old_rec.rt_age_uom;
  End If;
  If (p_rec.rt_los_uom = hr_api.g_varchar2) then
    p_rec.rt_los_uom :=
    ben_epo_shd.g_old_rec.rt_los_uom;
  End If;
  If (p_rec.rt_pct_fl_tm_val = hr_api.g_number) then
    p_rec.rt_pct_fl_tm_val :=
    ben_epo_shd.g_old_rec.rt_pct_fl_tm_val;
  End If;
  If (p_rec.rt_frz_los_flag = hr_api.g_varchar2) then
    p_rec.rt_frz_los_flag :=
    ben_epo_shd.g_old_rec.rt_frz_los_flag;
  End If;
  If (p_rec.rt_frz_age_flag = hr_api.g_varchar2) then
    p_rec.rt_frz_age_flag :=
    ben_epo_shd.g_old_rec.rt_frz_age_flag;
  End If;
  If (p_rec.rt_frz_cmp_lvl_flag = hr_api.g_varchar2) then
    p_rec.rt_frz_cmp_lvl_flag :=
    ben_epo_shd.g_old_rec.rt_frz_cmp_lvl_flag;
  End If;
  If (p_rec.rt_frz_pct_fl_tm_flag = hr_api.g_varchar2) then
    p_rec.rt_frz_pct_fl_tm_flag :=
    ben_epo_shd.g_old_rec.rt_frz_pct_fl_tm_flag;
  End If;
  If (p_rec.rt_frz_hrs_wkd_flag = hr_api.g_varchar2) then
    p_rec.rt_frz_hrs_wkd_flag :=
    ben_epo_shd.g_old_rec.rt_frz_hrs_wkd_flag;
  End If;
  If (p_rec.rt_frz_comb_age_and_los_flag = hr_api.g_varchar2) then
    p_rec.rt_frz_comb_age_and_los_flag :=
    ben_epo_shd.g_old_rec.rt_frz_comb_age_and_los_flag;
  End If;
  If (p_rec.comp_ref_amt = hr_api.g_number) then
    p_rec.comp_ref_amt :=
    ben_epo_shd.g_old_rec.comp_ref_amt;
  End If;
  If (p_rec.cmbn_age_n_los_val = hr_api.g_number) then
    p_rec.cmbn_age_n_los_val :=
    ben_epo_shd.g_old_rec.cmbn_age_n_los_val;
  End If;
  If (p_rec.comp_ref_uom = hr_api.g_varchar2) then
    p_rec.comp_ref_uom :=
    ben_epo_shd.g_old_rec.comp_ref_uom;
  End If;
  If (p_rec.age_val = hr_api.g_number) then
    p_rec.age_val :=
    ben_epo_shd.g_old_rec.age_val;
  End If;
  If (p_rec.los_val = hr_api.g_number) then
    p_rec.los_val :=
    ben_epo_shd.g_old_rec.los_val;
  End If;
  If (p_rec.hrs_wkd_val = hr_api.g_number) then
    p_rec.hrs_wkd_val :=
    ben_epo_shd.g_old_rec.hrs_wkd_val;
  End If;
  If (p_rec.hrs_wkd_bndry_perd_cd = hr_api.g_varchar2) then
    p_rec.hrs_wkd_bndry_perd_cd :=
    ben_epo_shd.g_old_rec.hrs_wkd_bndry_perd_cd;
  End If;
  If (p_rec.age_uom = hr_api.g_varchar2) then
    p_rec.age_uom :=
    ben_epo_shd.g_old_rec.age_uom;
  End If;
  If (p_rec.los_uom = hr_api.g_varchar2) then
    p_rec.los_uom :=
    ben_epo_shd.g_old_rec.los_uom;
  End If;
  If (p_rec.frz_los_flag = hr_api.g_varchar2) then
    p_rec.frz_los_flag :=
    ben_epo_shd.g_old_rec.frz_los_flag;
  End If;
  If (p_rec.frz_age_flag = hr_api.g_varchar2) then
    p_rec.frz_age_flag :=
    ben_epo_shd.g_old_rec.frz_age_flag;
  End If;
  If (p_rec.frz_cmp_lvl_flag = hr_api.g_varchar2) then
    p_rec.frz_cmp_lvl_flag :=
    ben_epo_shd.g_old_rec.frz_cmp_lvl_flag;
  End If;
  If (p_rec.frz_pct_fl_tm_flag = hr_api.g_varchar2) then
    p_rec.frz_pct_fl_tm_flag :=
    ben_epo_shd.g_old_rec.frz_pct_fl_tm_flag;
  End If;
  If (p_rec.frz_hrs_wkd_flag = hr_api.g_varchar2) then
    p_rec.frz_hrs_wkd_flag :=
    ben_epo_shd.g_old_rec.frz_hrs_wkd_flag;
  End If;
  If (p_rec.frz_comb_age_and_los_flag = hr_api.g_varchar2) then
    p_rec.frz_comb_age_and_los_flag :=
    ben_epo_shd.g_old_rec.frz_comb_age_and_los_flag;
  End If;
  If (p_rec.ovrid_svc_dt = hr_api.g_date) then
    p_rec.ovrid_svc_dt :=
    ben_epo_shd.g_old_rec.ovrid_svc_dt;
  End If;
  If (p_rec.inelg_rsn_cd = hr_api.g_varchar2) then
    p_rec.inelg_rsn_cd :=
    ben_epo_shd.g_old_rec.inelg_rsn_cd;
  End If;
  If (p_rec.once_r_cntug_cd = hr_api.g_varchar2) then
    p_rec.once_r_cntug_cd :=
    ben_epo_shd.g_old_rec.once_r_cntug_cd;
  End If;
  If (p_rec.oipl_ordr_num = hr_api.g_number) then
    p_rec.oipl_ordr_num :=
    ben_epo_shd.g_old_rec.oipl_ordr_num;
  End If;
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    ben_epo_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.epo_attribute_category = hr_api.g_varchar2) then
    p_rec.epo_attribute_category :=
    ben_epo_shd.g_old_rec.epo_attribute_category;
  End If;
  If (p_rec.epo_attribute1 = hr_api.g_varchar2) then
    p_rec.epo_attribute1 :=
    ben_epo_shd.g_old_rec.epo_attribute1;
  End If;
  If (p_rec.epo_attribute2 = hr_api.g_varchar2) then
    p_rec.epo_attribute2 :=
    ben_epo_shd.g_old_rec.epo_attribute2;
  End If;
  If (p_rec.epo_attribute3 = hr_api.g_varchar2) then
    p_rec.epo_attribute3 :=
    ben_epo_shd.g_old_rec.epo_attribute3;
  End If;
  If (p_rec.epo_attribute4 = hr_api.g_varchar2) then
    p_rec.epo_attribute4 :=
    ben_epo_shd.g_old_rec.epo_attribute4;
  End If;
  If (p_rec.epo_attribute5 = hr_api.g_varchar2) then
    p_rec.epo_attribute5 :=
    ben_epo_shd.g_old_rec.epo_attribute5;
  End If;
  If (p_rec.epo_attribute6 = hr_api.g_varchar2) then
    p_rec.epo_attribute6 :=
    ben_epo_shd.g_old_rec.epo_attribute6;
  End If;
  If (p_rec.epo_attribute7 = hr_api.g_varchar2) then
    p_rec.epo_attribute7 :=
    ben_epo_shd.g_old_rec.epo_attribute7;
  End If;
  If (p_rec.epo_attribute8 = hr_api.g_varchar2) then
    p_rec.epo_attribute8 :=
    ben_epo_shd.g_old_rec.epo_attribute8;
  End If;
  If (p_rec.epo_attribute9 = hr_api.g_varchar2) then
    p_rec.epo_attribute9 :=
    ben_epo_shd.g_old_rec.epo_attribute9;
  End If;
  If (p_rec.epo_attribute10 = hr_api.g_varchar2) then
    p_rec.epo_attribute10 :=
    ben_epo_shd.g_old_rec.epo_attribute10;
  End If;
  If (p_rec.epo_attribute11 = hr_api.g_varchar2) then
    p_rec.epo_attribute11 :=
    ben_epo_shd.g_old_rec.epo_attribute11;
  End If;
  If (p_rec.epo_attribute12 = hr_api.g_varchar2) then
    p_rec.epo_attribute12 :=
    ben_epo_shd.g_old_rec.epo_attribute12;
  End If;
  If (p_rec.epo_attribute13 = hr_api.g_varchar2) then
    p_rec.epo_attribute13 :=
    ben_epo_shd.g_old_rec.epo_attribute13;
  End If;
  If (p_rec.epo_attribute14 = hr_api.g_varchar2) then
    p_rec.epo_attribute14 :=
    ben_epo_shd.g_old_rec.epo_attribute14;
  End If;
  If (p_rec.epo_attribute15 = hr_api.g_varchar2) then
    p_rec.epo_attribute15 :=
    ben_epo_shd.g_old_rec.epo_attribute15;
  End If;
  If (p_rec.epo_attribute16 = hr_api.g_varchar2) then
    p_rec.epo_attribute16 :=
    ben_epo_shd.g_old_rec.epo_attribute16;
  End If;
  If (p_rec.epo_attribute17 = hr_api.g_varchar2) then
    p_rec.epo_attribute17 :=
    ben_epo_shd.g_old_rec.epo_attribute17;
  End If;
  If (p_rec.epo_attribute18 = hr_api.g_varchar2) then
    p_rec.epo_attribute18 :=
    ben_epo_shd.g_old_rec.epo_attribute18;
  End If;
  If (p_rec.epo_attribute19 = hr_api.g_varchar2) then
    p_rec.epo_attribute19 :=
    ben_epo_shd.g_old_rec.epo_attribute19;
  End If;
  If (p_rec.epo_attribute20 = hr_api.g_varchar2) then
    p_rec.epo_attribute20 :=
    ben_epo_shd.g_old_rec.epo_attribute20;
  End If;
  If (p_rec.epo_attribute21 = hr_api.g_varchar2) then
    p_rec.epo_attribute21 :=
    ben_epo_shd.g_old_rec.epo_attribute21;
  End If;
  If (p_rec.epo_attribute22 = hr_api.g_varchar2) then
    p_rec.epo_attribute22 :=
    ben_epo_shd.g_old_rec.epo_attribute22;
  End If;
  If (p_rec.epo_attribute23 = hr_api.g_varchar2) then
    p_rec.epo_attribute23 :=
    ben_epo_shd.g_old_rec.epo_attribute23;
  End If;
  If (p_rec.epo_attribute24 = hr_api.g_varchar2) then
    p_rec.epo_attribute24 :=
    ben_epo_shd.g_old_rec.epo_attribute24;
  End If;
  If (p_rec.epo_attribute25 = hr_api.g_varchar2) then
    p_rec.epo_attribute25 :=
    ben_epo_shd.g_old_rec.epo_attribute25;
  End If;
  If (p_rec.epo_attribute26 = hr_api.g_varchar2) then
    p_rec.epo_attribute26 :=
    ben_epo_shd.g_old_rec.epo_attribute26;
  End If;
  If (p_rec.epo_attribute27 = hr_api.g_varchar2) then
    p_rec.epo_attribute27 :=
    ben_epo_shd.g_old_rec.epo_attribute27;
  End If;
  If (p_rec.epo_attribute28 = hr_api.g_varchar2) then
    p_rec.epo_attribute28 :=
    ben_epo_shd.g_old_rec.epo_attribute28;
  End If;
  If (p_rec.epo_attribute29 = hr_api.g_varchar2) then
    p_rec.epo_attribute29 :=
    ben_epo_shd.g_old_rec.epo_attribute29;
  End If;
  If (p_rec.epo_attribute30 = hr_api.g_varchar2) then
    p_rec.epo_attribute30 :=
    ben_epo_shd.g_old_rec.epo_attribute30;
  End If;
  If (p_rec.request_id= hr_api.g_number) then
    p_rec.request_id :=
    ben_epo_shd.g_old_rec.request_id;
  End If;
  If (p_rec.program_application_id = hr_api.g_number) then
    p_rec.program_application_id :=
    ben_epo_shd.g_old_rec.program_application_id;
  End If;
  If (p_rec.program_id = hr_api.g_number) then
    p_rec.program_id :=
    ben_epo_shd.g_old_rec.program_id;
  End If;
  If (p_rec.program_update_date = hr_api.g_date) then
    p_rec.program_update_date :=
    ben_epo_shd.g_old_rec.program_update_date;
  End If;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
End epo_convert_defs;
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_pre_update >-----------------------------|
-- ----------------------------------------------------------------------------
--
Procedure dt_pre_update
  (p_rec                   in out nocopy ben_epo_shd.g_rec_type
  ,p_effective_date        in            date
  ,p_datetrack_mode        in            varchar2
  ,p_validation_start_date in            date
  ,p_validation_end_date   in            date
  )
is
--
  l_proc             varchar2(72) := g_package||'dt_pre_update';
  l_dummy_version_number number;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  If (p_datetrack_mode <> 'CORRECTION') then
    hr_utility.set_location(l_proc, 10);
    --
    -- Update the current effective end date
    --
    ben_epo_shd.upd_effective_end_date
     (p_effective_date           => p_effective_date,
      p_base_key_value           => p_rec.elig_per_opt_id,
      p_new_effective_end_date => (p_validation_start_date - 1),
      p_validation_start_date  => p_validation_start_date,
      p_validation_end_date    => p_validation_end_date,
      p_object_version_number  => l_dummy_version_number);
    --
    If (p_datetrack_mode = 'UPDATE_OVERRIDE') then
      hr_utility.set_location(l_proc, 15);
      --
      -- As the datetrack mode is 'UPDATE_OVERRIDE' then we must
      -- delete any future rows
      --
      ben_epo_del.delete_dml
        (p_rec             => p_rec,
     p_effective_date     => p_effective_date,
     p_datetrack_mode     => p_datetrack_mode,
     p_validation_start_date => p_validation_start_date,
     p_validation_end_date   => p_validation_end_date);
    End If;
    hr_utility.set_location(l_proc, 20);
    --
    -- We must now insert the updated row
    --
    ben_epo_ins.insert_dml
      (p_rec            => p_rec,
       p_effective_date        => p_effective_date,
       p_datetrack_mode        => p_datetrack_mode,
       p_validation_start_date    => p_validation_start_date,
       p_validation_end_date    => p_validation_end_date);
  End If;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End dt_pre_update;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_update >------------------------------|
-- ----------------------------------------------------------------------------
Procedure pre_update
  (p_rec                   in out nocopy ben_epo_shd.g_rec_type
  ,p_effective_date        in     date
  ,p_datetrack_mode        in     varchar2
  ,p_validation_start_date in     date
  ,p_validation_end_date   in     date
  )
is
--
  l_proc    varchar2(72) := g_package||'pre_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  dt_pre_update
    (p_rec              => p_rec,
     p_effective_date         => p_effective_date,
     p_datetrack_mode         => p_datetrack_mode,
     p_validation_start_date => p_validation_start_date,
     p_validation_end_date   => p_validation_end_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_update;
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_update_dml >-----------------------------|
-- ----------------------------------------------------------------------------
--
Procedure dt_update_dml
  (p_rec                   in out nocopy ben_epo_shd.g_rec_type
  ,p_effective_date        in     date
  ,p_datetrack_mode        in     varchar2
  ,p_validation_start_date in     date
  ,p_validation_end_date   in     date
  )
is
--
  l_proc    varchar2(72) := g_package||'dt_update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_datetrack_mode = 'CORRECTION') then
    hr_utility.set_location(l_proc, 10);
    --
    -- Because we are updating a row we must get the next object
    -- version number.
    --
    p_rec.object_version_number :=
      dt_api.get_object_version_number
      (p_base_table_name    => 'ben_elig_per_opt_f',
       p_base_key_column    => 'elig_per_opt_id',
       p_base_key_value    => p_rec.elig_per_opt_id);
    --
    ben_epo_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Update the ben_elig_per_opt_f Row
    --
    update  ben_elig_per_opt_f
    set
    elig_per_opt_id                 = p_rec.elig_per_opt_id,
    elig_per_id                     = p_rec.elig_per_id,
    prtn_ovridn_flag                = p_rec.prtn_ovridn_flag,
    prtn_ovridn_thru_dt             = p_rec.prtn_ovridn_thru_dt,
    no_mx_prtn_ovrid_thru_flag      = p_rec.no_mx_prtn_ovrid_thru_flag,
    elig_flag                       = p_rec.elig_flag,
    prtn_strt_dt                    = p_rec.prtn_strt_dt,
    prtn_end_dt                     = p_rec.prtn_end_dt,
    -- wait_perd_cmpltn_dt             = p_rec.wait_perd_cmpltn_dt,
    wait_perd_cmpltn_date             = p_rec.wait_perd_cmpltn_date,
    wait_perd_strt_dt               = p_rec.wait_perd_strt_dt,
    prtn_ovridn_rsn_cd              = p_rec.prtn_ovridn_rsn_cd,
    pct_fl_tm_val                   = p_rec.pct_fl_tm_val,
    opt_id                          = p_rec.opt_id,
    per_in_ler_id                   = p_rec.per_in_ler_id,
    rt_comp_ref_amt                 = p_rec.rt_comp_ref_amt,
    rt_cmbn_age_n_los_val           = p_rec.rt_cmbn_age_n_los_val,
    rt_comp_ref_uom                 = p_rec.rt_comp_ref_uom,
    rt_age_val                      = p_rec.rt_age_val,
    rt_los_val                      = p_rec.rt_los_val,
    rt_hrs_wkd_val                  = p_rec.rt_hrs_wkd_val,
    rt_hrs_wkd_bndry_perd_cd        = p_rec.rt_hrs_wkd_bndry_perd_cd,
    rt_age_uom                      = p_rec.rt_age_uom,
    rt_los_uom                      = p_rec.rt_los_uom,
    rt_pct_fl_tm_val                = p_rec.rt_pct_fl_tm_val,
    rt_frz_los_flag                 = p_rec.rt_frz_los_flag,
    rt_frz_age_flag                 = p_rec.rt_frz_age_flag,
    rt_frz_cmp_lvl_flag             = p_rec.rt_frz_cmp_lvl_flag,
    rt_frz_pct_fl_tm_flag           = p_rec.rt_frz_pct_fl_tm_flag,
    rt_frz_hrs_wkd_flag             = p_rec.rt_frz_hrs_wkd_flag,
    rt_frz_comb_age_and_los_flag    = p_rec.rt_frz_comb_age_and_los_flag,
    comp_ref_amt                    = p_rec.comp_ref_amt,
    cmbn_age_n_los_val              = p_rec.cmbn_age_n_los_val,
    comp_ref_uom                    = p_rec.comp_ref_uom,
    age_val                         = p_rec.age_val,
    los_val                         = p_rec.los_val,
    hrs_wkd_val                     = p_rec.hrs_wkd_val,
    hrs_wkd_bndry_perd_cd           = p_rec.hrs_wkd_bndry_perd_cd,
    age_uom                         = p_rec.age_uom,
    los_uom                         = p_rec.los_uom,
    frz_los_flag                    = p_rec.frz_los_flag,
    frz_age_flag                    = p_rec.frz_age_flag,
    frz_cmp_lvl_flag                = p_rec.frz_cmp_lvl_flag,
    frz_pct_fl_tm_flag              = p_rec.frz_pct_fl_tm_flag,
    frz_hrs_wkd_flag                = p_rec.frz_hrs_wkd_flag,
    frz_comb_age_and_los_flag       = p_rec.frz_comb_age_and_los_flag,
    ovrid_svc_dt                    = p_rec.ovrid_svc_dt,
    inelg_rsn_cd                    = p_rec.inelg_rsn_cd,
    once_r_cntug_cd                 = p_rec.once_r_cntug_cd,
    oipl_ordr_num                   = p_rec.oipl_ordr_num,
    business_group_id               = p_rec.business_group_id,
    epo_attribute_category          = p_rec.epo_attribute_category,
    epo_attribute1                  = p_rec.epo_attribute1,
    epo_attribute2                  = p_rec.epo_attribute2,
    epo_attribute3                  = p_rec.epo_attribute3,
    epo_attribute4                  = p_rec.epo_attribute4,
    epo_attribute5                  = p_rec.epo_attribute5,
    epo_attribute6                  = p_rec.epo_attribute6,
    epo_attribute7                  = p_rec.epo_attribute7,
    epo_attribute8                  = p_rec.epo_attribute8,
    epo_attribute9                  = p_rec.epo_attribute9,
    epo_attribute10                 = p_rec.epo_attribute10,
    epo_attribute11                 = p_rec.epo_attribute11,
    epo_attribute12                 = p_rec.epo_attribute12,
    epo_attribute13                 = p_rec.epo_attribute13,
    epo_attribute14                 = p_rec.epo_attribute14,
    epo_attribute15                 = p_rec.epo_attribute15,
    epo_attribute16                 = p_rec.epo_attribute16,
    epo_attribute17                 = p_rec.epo_attribute17,
    epo_attribute18                 = p_rec.epo_attribute18,
    epo_attribute19                 = p_rec.epo_attribute19,
    epo_attribute20                 = p_rec.epo_attribute20,
    epo_attribute21                 = p_rec.epo_attribute21,
    epo_attribute22                 = p_rec.epo_attribute22,
    epo_attribute23                 = p_rec.epo_attribute23,
    epo_attribute24                 = p_rec.epo_attribute24,
    epo_attribute25                 = p_rec.epo_attribute25,
    epo_attribute26                 = p_rec.epo_attribute26,
    epo_attribute27                 = p_rec.epo_attribute27,
    epo_attribute28                 = p_rec.epo_attribute28,
    epo_attribute29                 = p_rec.epo_attribute29,
    epo_attribute30                 = p_rec.epo_attribute30,
    request_id                = p_rec.request_id,
    program_application_id        = p_rec.program_application_id,
    program_id                = p_rec.program_id,
    program_update_date            = p_rec.program_update_date,
    object_version_number           = p_rec.object_version_number
    where   elig_per_opt_id = p_rec.elig_per_opt_id
    and     effective_start_date = p_validation_start_date
    and     effective_end_date   = p_validation_end_date;
    --
    ben_epo_shd.g_api_dml := false;   -- Unset the api dml status
    --
    -- Set the effective start and end dates
    --
    p_rec.effective_start_date := p_validation_start_date;
    p_rec.effective_end_date   := p_validation_end_date;
  End If;
--
hr_utility.set_location(' Leaving:'||l_proc, 15);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_epo_shd.g_api_dml := false;   -- Unset the api dml status
    ben_epo_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_epo_shd.g_api_dml := false;   -- Unset the api dml status
    ben_epo_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_epo_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End dt_update_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_dml >------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure update_dml
  (p_rec                   in out nocopy ben_epo_shd.g_rec_type
  ,p_effective_date        in     date
  ,p_datetrack_mode        in     varchar2
  ,p_validation_start_date in     date
  ,p_validation_end_date   in     date
  )
is
--
  l_proc    varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  dt_update_dml(p_rec            => p_rec,
        p_effective_date    => p_effective_date,
        p_datetrack_mode    => p_datetrack_mode,
               p_validation_start_date    => p_validation_start_date,
        p_validation_end_date    => p_validation_end_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_dml;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_rec            in out nocopy ben_epo_shd.g_rec_type
  ,p_effective_date in     date
  ,p_datetrack_mode in     varchar2
  )
is
--
  l_proc            varchar2(72) := g_package||'upd';
  l_validation_start_date    date;
  l_validation_end_date        date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  lck
    (p_effective_date        => p_effective_date
    ,p_datetrack_mode        => p_datetrack_mode
    ,p_elig_per_opt_id       => p_rec.elig_per_opt_id
    ,p_object_version_number => p_rec.object_version_number
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date
    );
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  epo_convert_defs(p_rec);
  --
  if ben_manage_life_events.g_modified_mode in ('U','S','D') then
    -- compare the values and if there is no difference come out
    if (
        nvl(p_rec.per_in_ler_id,-1) <> nvl(ben_epo_shd.g_old_rec.per_in_ler_id,-1) or -- bug 5478994 epo to be updated first-time by unrestricted run
        nvl(p_rec.opt_id,-1) <> nvl(ben_epo_shd.g_old_rec.opt_id,-1) or
        nvl(p_rec.prtn_ovridn_thru_dt,to_date('01-01-1001','dd-mm-yyyy'))<>
        nvl(ben_epo_shd.g_old_rec.prtn_ovridn_thru_dt,to_date('01-01-1001','dd-mm-yyyy'))  or
        nvl(p_rec.elig_flag,'N') <>  nvl(ben_epo_shd.g_old_rec.elig_flag,'N') or
        nvl(p_rec.comp_ref_amt,-1) <> nvl(ben_epo_shd.g_old_rec.comp_ref_amt,-1) or
        nvl(p_rec.cmbn_age_n_los_val, -1) <> nvl(ben_epo_shd.g_old_rec.cmbn_age_n_los_val, -1) or
        nvl(p_rec.comp_ref_uom,'X') <>  nvl(ben_epo_shd.g_old_rec.comp_ref_uom,'X') or
        nvl(p_rec.age_val, -1) <> nvl(ben_epo_shd.g_old_rec.age_val, -1) or
        nvl(p_rec.los_val, -1) <> nvl(ben_epo_shd.g_old_rec.los_val, -1) or
        nvl(p_rec.prtn_end_dt,to_date('01-01-1001','dd-mm-yyyy')) <>
        nvl(ben_epo_shd.g_old_rec.prtn_end_dt,to_date('01-01-1001','dd-mm-yyyy')) or
        nvl(p_rec.wait_perd_cmpltn_date,to_date('01-01-1001','dd-mm-yyyy')) <>
            nvl(ben_epo_shd.g_old_rec.wait_perd_cmpltn_date,to_date('01-01-1001','dd-mm-yyyy')) or
        nvl(p_rec.wait_perd_strt_dt,to_date('01-01-1001','dd-mm-yyyy')) <>
              nvl(ben_epo_shd.g_old_rec.wait_perd_strt_dt,to_date('01-01-1001','dd-mm-yyyy')) or
        nvl(p_rec.hrs_wkd_val,-1) <> nvl(ben_epo_shd.g_old_rec.hrs_wkd_val,-1) or
        nvl(p_rec.hrs_wkd_bndry_perd_cd,'X') <> nvl(ben_epo_shd.g_old_rec.hrs_wkd_bndry_perd_cd,'X') or
        nvl(p_rec.prtn_ovridn_flag,'N') <> nvl(ben_epo_shd.g_old_rec.prtn_ovridn_flag,'N') or
        nvl(p_rec.no_mx_prtn_ovrid_thru_flag,'N') <>
             nvl(ben_epo_shd.g_old_rec.no_mx_prtn_ovrid_thru_flag,'N') or
        nvl(p_rec.prtn_ovridn_rsn_cd, 'X') <>
           nvl(ben_epo_shd.g_old_rec.prtn_ovridn_rsn_cd, 'X') or
        nvl(p_rec.age_uom,'X') <>  nvl(ben_epo_shd.g_old_rec.age_uom,'X') or
        nvl(p_rec.los_uom,'X') <> nvl(ben_epo_shd.g_old_rec.los_uom,'X') or
        nvl(p_rec.ovrid_svc_dt,to_date('01-01-1001','dd-mm-yyyy')) <>
        nvl(ben_epo_shd.g_old_rec.ovrid_svc_dt,to_date('01-01-1001','dd-mm-yyyy')) or
        nvl(p_rec.inelg_rsn_cd,'X') <> nvl(ben_epo_shd.g_old_rec.inelg_rsn_cd,'X') or
        nvl(p_rec.frz_los_flag,'N') <> nvl(ben_epo_shd.g_old_rec.frz_los_flag,'N') or
        nvl(p_rec.frz_age_flag,'N') <> nvl(ben_epo_shd.g_old_rec.frz_age_flag,'N') or
        nvl(p_rec.frz_cmp_lvl_flag,'N') <> nvl(ben_epo_shd.g_old_rec.frz_cmp_lvl_flag,'N') or
        nvl(p_rec.frz_pct_fl_tm_flag,'N') <> nvl(ben_epo_shd.g_old_rec.frz_pct_fl_tm_flag,'N') or
        nvl(p_rec.frz_hrs_wkd_flag,'N') <> nvl(ben_epo_shd.g_old_rec.frz_hrs_wkd_flag,'N') or
        nvl(p_rec.frz_comb_age_and_los_flag,'N') <> nvl(ben_epo_shd.g_old_rec.frz_comb_age_and_los_flag,'N') or
        nvl(p_rec.pct_fl_tm_val,-1) <> nvl(ben_epo_shd.g_old_rec.pct_fl_tm_val,-1) or
        nvl(p_rec.rt_comp_ref_amt,-1) <> nvl(ben_epo_shd.g_old_rec.rt_comp_ref_amt,-1) or
        nvl(p_rec.rt_cmbn_age_n_los_val,-1) <> nvl(ben_epo_shd.g_old_rec.rt_cmbn_age_n_los_val,-1) or
        nvl(p_rec.rt_comp_ref_uom,'X') <> nvl(ben_epo_shd.g_old_rec.rt_comp_ref_uom,'X') or
        nvl(p_rec.rt_age_val,-1) <> nvl(ben_epo_shd.g_old_rec.rt_age_val,-1) or
        nvl(p_rec.rt_los_val,-1) <> nvl(ben_epo_shd.g_old_rec.rt_los_val,-1) or
        nvl(p_rec.rt_hrs_wkd_val,-1) <> nvl(ben_epo_shd.g_old_rec.rt_hrs_wkd_val,-1) or
        nvl(p_rec.rt_hrs_wkd_bndry_perd_cd,'X') <>
            nvl(ben_epo_shd.g_old_rec.rt_hrs_wkd_bndry_perd_cd,'X') or
        nvl(p_rec.rt_age_uom,'X') <> nvl(ben_epo_shd.g_old_rec.rt_age_uom,'X') or
        nvl(p_rec.rt_los_uom,'X') <> nvl(ben_epo_shd.g_old_rec.rt_los_uom,'X') or
        nvl(p_rec.rt_pct_fl_tm_val,-1) <> nvl(ben_epo_shd.g_old_rec.rt_pct_fl_tm_val,-1) or
        nvl(p_rec.rt_frz_los_flag,'N') <> nvl(ben_epo_shd.g_old_rec.rt_frz_los_flag,'N') or
        nvl(p_rec.rt_frz_age_flag,'N') <> nvl(ben_epo_shd.g_old_rec.rt_frz_age_flag,'N') or
        nvl(p_rec.rt_frz_cmp_lvl_flag,'N') <> nvl(ben_epo_shd.g_old_rec.rt_frz_cmp_lvl_flag,'N') or
        nvl(p_rec.rt_frz_pct_fl_tm_flag,'N') <> nvl(ben_epo_shd.g_old_rec.rt_frz_pct_fl_tm_flag,'N') or
        nvl(p_rec.rt_frz_hrs_wkd_flag,'N') <> nvl(ben_epo_shd.g_old_rec.rt_frz_hrs_wkd_flag,'N') or
        nvl(p_rec.rt_frz_comb_age_and_los_flag,'N') <>
                nvl(ben_epo_shd.g_old_rec.rt_frz_comb_age_and_los_flag,'N') or
        nvl(p_rec.once_r_cntug_cd,'X') <> nvl(ben_epo_shd.g_old_rec.once_r_cntug_cd,'X') or
        nvl(p_rec.oipl_ordr_num,-1) <> nvl(ben_epo_shd.g_old_rec.oipl_ordr_num,-1)
        ) then
      --
      null;
    else
      return;
    end if;
    --
  end if;
  -- Call the supporting pre-update operation
  --
  pre_update
    (p_rec             => p_rec,
     p_effective_date     => p_effective_date,
     p_datetrack_mode     => p_datetrack_mode,
     p_validation_start_date => l_validation_start_date,
     p_validation_end_date     => l_validation_end_date);
  --
  -- Update the row.
  --
  update_dml
    (p_rec             => p_rec,
     p_effective_date     => p_effective_date,
     p_datetrack_mode     => p_datetrack_mode,
     p_validation_start_date => l_validation_start_date,
     p_validation_end_date     => l_validation_end_date);
  --
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_elig_per_opt_id              in number,
  p_elig_per_id                  in number           default hr_api.g_number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_prtn_ovridn_flag             in varchar2         default hr_api.g_varchar2,
  p_prtn_ovridn_thru_dt          in date             default hr_api.g_date,
  p_no_mx_prtn_ovrid_thru_flag   in varchar2         default hr_api.g_varchar2,
  p_elig_flag                    in varchar2         default hr_api.g_varchar2,
  p_prtn_strt_dt                 in date             default hr_api.g_date,
  p_prtn_end_dt                  in date             default hr_api.g_date,
  -- p_wait_perd_cmpltn_dt          in date             default hr_api.g_date,
  p_wait_perd_cmpltn_date          in date             default hr_api.g_date,
  p_wait_perd_strt_dt            in date             default hr_api.g_date,
  p_prtn_ovridn_rsn_cd           in varchar2         default hr_api.g_varchar2,
  p_pct_fl_tm_val                in number           default hr_api.g_number,
  p_opt_id                       in number           default hr_api.g_number,
  p_per_in_ler_id                in number           default hr_api.g_number,
  p_rt_comp_ref_amt              in number           default hr_api.g_number,
  p_rt_cmbn_age_n_los_val        in number           default hr_api.g_number,
  p_rt_comp_ref_uom              in varchar2         default hr_api.g_varchar2,
  p_rt_age_val                   in number           default hr_api.g_number,
  p_rt_los_val                   in number           default hr_api.g_number,
  p_rt_hrs_wkd_val               in number           default hr_api.g_number,
  p_rt_hrs_wkd_bndry_perd_cd     in varchar2         default hr_api.g_varchar2,
  p_rt_age_uom                   in varchar2         default hr_api.g_varchar2,
  p_rt_los_uom                   in varchar2         default hr_api.g_varchar2,
  p_rt_pct_fl_tm_val             in number           default hr_api.g_number,
  p_rt_frz_los_flag              in varchar2         default hr_api.g_varchar2,
  p_rt_frz_age_flag              in varchar2         default hr_api.g_varchar2,
  p_rt_frz_cmp_lvl_flag          in varchar2         default hr_api.g_varchar2,
  p_rt_frz_pct_fl_tm_flag        in varchar2         default hr_api.g_varchar2,
  p_rt_frz_hrs_wkd_flag          in varchar2         default hr_api.g_varchar2,
  p_rt_frz_comb_age_and_los_flag in varchar2         default hr_api.g_varchar2,
  p_comp_ref_amt                 in number           default hr_api.g_number,
  p_cmbn_age_n_los_val           in number           default hr_api.g_number,
  p_comp_ref_uom                 in varchar2         default hr_api.g_varchar2,
  p_age_val                      in number           default hr_api.g_number,
  p_los_val                      in number           default hr_api.g_number,
  p_hrs_wkd_val                  in number           default hr_api.g_number,
  p_hrs_wkd_bndry_perd_cd        in varchar2         default hr_api.g_varchar2,
  p_age_uom                      in varchar2         default hr_api.g_varchar2,
  p_los_uom                      in varchar2         default hr_api.g_varchar2,
  p_frz_los_flag                 in varchar2         default hr_api.g_varchar2,
  p_frz_age_flag                 in varchar2         default hr_api.g_varchar2,
  p_frz_cmp_lvl_flag             in varchar2         default hr_api.g_varchar2,
  p_frz_pct_fl_tm_flag           in varchar2         default hr_api.g_varchar2,
  p_frz_hrs_wkd_flag             in varchar2         default hr_api.g_varchar2,
  p_frz_comb_age_and_los_flag    in varchar2         default hr_api.g_varchar2,
  p_ovrid_svc_dt                 in date             default hr_api.g_date,
  p_inelg_rsn_cd                 in varchar2         default hr_api.g_varchar2,
  p_once_r_cntug_cd              in varchar2         default hr_api.g_varchar2,
  p_oipl_ordr_num                in number           default hr_api.g_number,
  p_business_group_id            in number           default hr_api.g_number,
  p_epo_attribute_category       in varchar2         default hr_api.g_varchar2,
  p_epo_attribute1               in varchar2         default hr_api.g_varchar2,
  p_epo_attribute2               in varchar2         default hr_api.g_varchar2,
  p_epo_attribute3               in varchar2         default hr_api.g_varchar2,
  p_epo_attribute4               in varchar2         default hr_api.g_varchar2,
  p_epo_attribute5               in varchar2         default hr_api.g_varchar2,
  p_epo_attribute6               in varchar2         default hr_api.g_varchar2,
  p_epo_attribute7               in varchar2         default hr_api.g_varchar2,
  p_epo_attribute8               in varchar2         default hr_api.g_varchar2,
  p_epo_attribute9               in varchar2         default hr_api.g_varchar2,
  p_epo_attribute10              in varchar2         default hr_api.g_varchar2,
  p_epo_attribute11              in varchar2         default hr_api.g_varchar2,
  p_epo_attribute12              in varchar2         default hr_api.g_varchar2,
  p_epo_attribute13              in varchar2         default hr_api.g_varchar2,
  p_epo_attribute14              in varchar2         default hr_api.g_varchar2,
  p_epo_attribute15              in varchar2         default hr_api.g_varchar2,
  p_epo_attribute16              in varchar2         default hr_api.g_varchar2,
  p_epo_attribute17              in varchar2         default hr_api.g_varchar2,
  p_epo_attribute18              in varchar2         default hr_api.g_varchar2,
  p_epo_attribute19              in varchar2         default hr_api.g_varchar2,
  p_epo_attribute20              in varchar2         default hr_api.g_varchar2,
  p_epo_attribute21              in varchar2         default hr_api.g_varchar2,
  p_epo_attribute22              in varchar2         default hr_api.g_varchar2,
  p_epo_attribute23              in varchar2         default hr_api.g_varchar2,
  p_epo_attribute24              in varchar2         default hr_api.g_varchar2,
  p_epo_attribute25              in varchar2         default hr_api.g_varchar2,
  p_epo_attribute26              in varchar2         default hr_api.g_varchar2,
  p_epo_attribute27              in varchar2         default hr_api.g_varchar2,
  p_epo_attribute28              in varchar2         default hr_api.g_varchar2,
  p_epo_attribute29              in varchar2         default hr_api.g_varchar2,
  p_epo_attribute30              in varchar2         default hr_api.g_varchar2,
  p_request_id                   in number           default hr_api.g_number,
  p_program_application_id       in number           default hr_api.g_number,
  p_program_id                   in number           default hr_api.g_number,
  p_program_update_date          in date             default hr_api.g_date,
  p_object_version_number        in out nocopy number,
  p_effective_date         in date,
  p_datetrack_mode         in varchar2
  ) is
--
  l_rec        ben_epo_shd.g_rec_type;
  l_proc    varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  ben_epo_shd.convert_args
  (
  p_elig_per_opt_id,
  p_elig_per_id,
  null,
  null,
  p_prtn_ovridn_flag,
  p_prtn_ovridn_thru_dt,
  p_no_mx_prtn_ovrid_thru_flag,
  p_elig_flag,
  p_prtn_strt_dt,
  p_prtn_end_dt,
  --p_wait_perd_cmpltn_dt,
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
  p_object_version_number
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  upd(l_rec, p_effective_date, p_datetrack_mode);
  p_object_version_number       := l_rec.object_version_number;
  p_effective_start_date        := l_rec.effective_start_date;
  p_effective_end_date          := l_rec.effective_end_date;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
procedure update_perf_Elig_Person_Option
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
  --,p_wait_perd_cmpltn_dt            in  date      default hr_api.g_date
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
  l_proc varchar2(72) := g_package||'update_perf_Elig_Person_Option';
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
  savepoint update_perf_Elig_Person_Option;
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
      --,p_wait_perd_cmpltn_dt            =>  p_wait_perd_cmpltn_dt
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
  upd
    (p_elig_per_opt_id               => p_elig_per_opt_id
    ,p_elig_per_id                   => p_elig_per_id
    ,p_effective_start_date          => l_effective_start_date
    ,p_effective_end_date            => l_effective_end_date
    ,p_prtn_ovridn_flag              => p_prtn_ovridn_flag
    ,p_prtn_ovridn_thru_dt           => p_prtn_ovridn_thru_dt
    ,p_no_mx_prtn_ovrid_thru_flag    => p_no_mx_prtn_ovrid_thru_flag
    ,p_elig_flag                     => p_elig_flag
    ,p_prtn_strt_dt                  => p_prtn_strt_dt
    ,p_prtn_end_dt                   => p_prtn_end_dt
    --,p_wait_perd_cmpltn_dt           => p_wait_perd_cmpltn_dt
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
      --,p_wait_perd_cmpltn_dt            =>  p_wait_perd_cmpltn_dt
      ,p_wait_perd_cmpltn_date           => p_wait_perd_cmpltn_date
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
    ROLLBACK TO update_perf_Elig_Person_Option;
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
    ROLLBACK TO update_perf_Elig_Person_Option;
    --
    p_object_version_number := l_object_version_number;
    p_effective_start_date := l_effective_start_date;
    p_effective_end_date := l_effective_end_date;
    --
    raise;
    --
end update_perf_Elig_Person_Option;
--
PROCEDURE epecleanup(p_start_rowid     IN            rowid,
                     p_end_rowid       IN            rowid,
                     p_rows_processed OUT nocopy number) is
      --
      TYPE l_epo_id_type IS TABLE OF NUMBER(15) index by binary_integer;
      t_epo_id         l_epo_id_type;
      --
      l_rows_processed number := 0 ;
      cursor csr_get_epo_ids is
        select  distinct p.elig_per_opt_id
        from    ben_elig_per_opt_f p
        where   p.rowid
        between p_start_rowid and p_end_rowid
           and  p.wait_perd_cmpltn_dt||'' is not null ;
  begin
    -- bulk collect
    open csr_get_epo_ids;
    LOOP
      --
      fetch csr_get_epo_ids BULK COLLECT INTO t_epo_id LIMIT 2000;
      -- if no rows fetched exit out of proc
      if t_epo_id.COUNT = 0 THEN
        EXIT;
      end if;
      --
      l_rows_processed := l_rows_processed + t_epo_id.COUNT ;
      --
      forall i in t_epo_id.FIRST..t_epo_id.LAST
         update ben_elig_per_opt_f epo
            set wait_perd_cmpltn_date = fnd_date.string_to_date(wait_perd_cmpltn_dt,'DD-MON-RRRR')
           where epo.elig_per_opt_id = t_epo_id(i) ;
         --
      commit;
      t_epo_id.delete;
      EXIT WHEN csr_get_epo_ids%NOTFOUND;
      --
    END LOOP;
    --
    close csr_get_epo_ids;
    --
    p_rows_processed := l_rows_processed ;
    --
  end  epecleanup ;
  --
--
end ben_Eligible_Person_perf_api;

/
